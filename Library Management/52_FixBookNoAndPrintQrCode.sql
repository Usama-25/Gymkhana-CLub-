-- Migration 52: Fix BookNo, remove Slot and Location checks from sp_AddCopy, and support saving Location in BookCopies
USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Add Location column to BookCopies if it does not exist
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.BookCopies') AND name = 'Location')
BEGIN
    ALTER TABLE dbo.BookCopies ADD Location VARCHAR(100) NULL;
    PRINT 'Added Location column to dbo.BookCopies.';
END
GO

-- 2. Drop unique constraint/index UX_CopySlot on BookCopies so slot/location checks/collisions are removed
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_CopySlot' AND object_id = OBJECT_ID('dbo.BookCopies'))
BEGIN
    DROP INDEX UX_CopySlot ON dbo.BookCopies;
    PRINT 'Dropped unique index UX_CopySlot from dbo.BookCopies.';
END
GO

-- 3. Populate any existing NULL BookNo values in BookCopies
IF EXISTS (SELECT 1 FROM dbo.BookCopies WHERE BookNo IS NULL)
BEGIN
    DECLARE @MaxBookNo INT = ISNULL((SELECT MAX(BookNo) FROM dbo.BookCopies WHERE BookNo IS NOT NULL), 29991);
    WITH CTE AS (
        SELECT CopyID, BookNo, ROW_NUMBER() OVER (ORDER BY CopyID) + @MaxBookNo AS NewBookNo
        FROM dbo.BookCopies
        WHERE BookNo IS NULL
    )
    UPDATE CTE SET BookNo = NewBookNo;
    PRINT 'Existing NULL BookNo values in BookCopies updated successfully.';
END
GO

-- 4. Create or Alter sp_AddCopy without rack/slot capacity checks, supporting @BookNo and @Location
CREATE OR ALTER PROCEDURE dbo.sp_AddCopy
    @BookID     INT,
    @RackID     SMALLINT      = NULL,
    @SlotNo     TINYINT       = NULL,
    @CondID     TINYINT       = 1,     -- 1=New
    @AcqCost    DECIMAL(8,2)  = NULL,
    @Notes      VARCHAR(200)  = NULL,
    @BookNo     INT           = NULL,
    @Location   VARCHAR(100)  = NULL,
    -- OUTPUT
    @CopyID     INT           OUTPUT,
    @Barcode    VARCHAR(60)   OUTPUT,
    @Msg        VARCHAR(200)  OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ISBN13 VARCHAR(50), @Seq INT;
    DECLARE @DDC VARCHAR(50);

    IF NOT EXISTS (SELECT 1 FROM Books WHERE BookID = @BookID AND IsActive = 1)
    BEGIN SET @Msg = 'ERR:BOOK_NOT_FOUND'; RETURN; END

    -- Auto-assign slot if rack is selected and slot is null
    IF @RackID IS NOT NULL AND @SlotNo IS NULL
    BEGIN
        SELECT TOP 1 @SlotNo = n.n
        FROM (VALUES(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),
                    (11),(12),(13),(14),(15),(16),(17),(18),(19),(20),
                    (21),(22),(23),(24),(25),(26),(27),(28),(29),(30),
                    (31),(32),(33),(34),(35),(36),(37),(38),(39),(40),
                    (41),(42),(43),(44),(45),(46),(47),(48),(49),(50),
                    (51),(52),(53),(54),(55),(56),(57),(58),(59),(60),
                    (61),(62),(63),(64),(65),(66),(67),(68),(69),(70),
                    (71),(72),(73),(74),(75),(76),(77),(78),(79),(80),
                    (81),(82),(83),(84),(85),(86),(87),(88),(89),(90),
                    (91),(92),(93),(94),(95),(96),(97),(98),(99),(100)
              ) n(n)
        WHERE n NOT IN (SELECT ISNULL(SlotNo,0) FROM BookCopies WHERE RackID=@RackID)
        ORDER BY n.n;
    END

    -- Check if book has a DDC call number
    SELECT @DDC = DDC FROM Books WHERE BookID = @BookID;

    IF @DDC IS NOT NULL AND LTRIM(RTRIM(@DDC)) <> ''
    BEGIN
        -- 1. Extract first range element if range exists
        DECLARE @FirstPart VARCHAR(100) = LTRIM(RTRIM(@DDC));
        IF CHARINDEX(' to ', @DDC) > 0
            SET @FirstPart = LTRIM(RTRIM(SUBSTRING(@DDC, 1, CHARINDEX(' to ', @DDC) - 1)));

        -- 2. Find trailing digits starting position
        DECLARE @Len INT = LEN(@FirstPart);
        DECLARE @Idx INT = @Len;
        WHILE @Idx > 0 AND SUBSTRING(@FirstPart, @Idx, 1) LIKE '[0-9]'
        BEGIN
            SET @Idx = @Idx - 1;
        END

        DECLARE @BaseDdc VARCHAR(100);
        DECLARE @StartNum INT = 1;

        IF @Idx > 0 AND @Idx < @Len
        BEGIN
            SET @StartNum = CAST(SUBSTRING(@FirstPart, @Idx + 1, @Len - @Idx) AS INT);
            SET @BaseDdc = SUBSTRING(@FirstPart, 1, @Idx);
            SET @BaseDdc = LTRIM(RTRIM(@BaseDdc));
            -- Strip trailing hyphens or spaces
            WHILE LEN(@BaseDdc) > 0 AND (RIGHT(@BaseDdc, 1) = '-' OR RIGHT(@BaseDdc, 1) = ' ')
            BEGIN
                SET @BaseDdc = SUBSTRING(@BaseDdc, 1, LEN(@BaseDdc) - 1);
                SET @BaseDdc = LTRIM(RTRIM(@BaseDdc));
            END
        END
        ELSE
        BEGIN
            SET @BaseDdc = @FirstPart;
            SET @StartNum = 1;
        END

        -- 3. Find maximum sequence number used in existing copy barcodes
        DECLARE @MaxSeq INT = 0;
        
        SELECT @MaxSeq = ISNULL(MAX(
            CASE 
                WHEN PatIndex('%[0-9]', Barcode) > 0 
                THEN 
                    CAST(
                        SUBSTRING(
                            Barcode, 
                            LEN(Barcode) - PatIndex('%[^0-9]%', REVERSE(Barcode)) + 2, 
                            LEN(Barcode)
                        ) AS INT
                    )
                ELSE 0 
            END
        ), 0)
        FROM BookCopies
        WHERE BookID = @BookID 
          AND REPLACE(Barcode, ' ', '-') LIKE REPLACE(@BaseDdc, ' ', '-') + '%';

        -- 4. Calculate next copy sequence number
        DECLARE @NextNum INT;
        IF @MaxSeq = 0
            SET @NextNum = @StartNum;
        ELSE
            SET @NextNum = @MaxSeq + 1;

        -- 5. Format barcode with a hyphen before the number
        SET @Barcode = @BaseDdc + '-' + CAST(@NextNum AS VARCHAR(10));
    END
    ELSE
    BEGIN
        -- Fallback to standard ISBN-based barcode generation
        SELECT @ISBN13 = ISBN13 FROM Books WHERE BookID = @BookID;
        SELECT @Seq = COUNT(*) + 1 FROM BookCopies WHERE BookID = @BookID;
        SET @Barcode = @ISBN13 + '-' + RIGHT('000' + CAST(@Seq AS VARCHAR(3)), 3);
    END;

    -- Calculate or validate BookNo
    IF @BookNo IS NULL OR @BookNo <= 0
    BEGIN
        SELECT @BookNo = ISNULL(MAX(BookNo), 29991) + 1 FROM dbo.BookCopies;
    END

    INSERT INTO BookCopies (BookID, Barcode, RackID, SlotNo, CondID, AcqDate, AcqCost, Notes, BookNo, Location)
    VALUES (@BookID, @Barcode, @RackID, @SlotNo, @CondID, CAST(GETDATE() AS DATE), @AcqCost, @Notes, @BookNo, @Location);

    SET @CopyID = SCOPE_IDENTITY();
    SET @Msg    = 'OK:' + @Barcode;
END;
GO
PRINT 'sp_AddCopy updated without rack/slot capacity checks and with @Location parameter.';
GO

-- 5. Create or Alter sp_GetBookDetail to include BookNo, Location and use LEFT JOINs
CREATE OR ALTER PROCEDURE dbo.sp_GetBookDetail
    @BookID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- RS1: Book
    SELECT b.BookID, b.ISBN13, dbo.fn_ISBN13Fmt(b.ISBN13) AS ISBN13Fmt,
           b.ISBN10, b.Title, b.SubTitle, b.Edition, b.PublishYear,
           b.PageCount, b.ClassNo, b.Tags, b.Synopsis, b.CoverFile,
           c.CatName, c.DdcPrefix, p.PubName, l.LangName, b.DDC,
           b.IsReference, b.NotToBeIssued, b.PrintBookDetail,
           b.AcqNo, b.PublishingPlace, b.LiDate, b.Volume, b.WwwLink, b.Series, b.RecBy,
           b.PurchaseRef, b.PurchaseDate, b.PriceFcy, b.PricePkr, b.Format, b.Source, b.Status, b.ClassSeq, b.Location,
           b.IsAdults, b.IsChildren
    FROM   Books b
    LEFT JOIN Categories c  ON b.CatID  = c.CatID
    LEFT JOIN Languages  l  ON b.LangID = l.LangID
    LEFT JOIN Publishers p  ON b.PubID  = p.PubID
    WHERE  b.BookID = @BookID;

    -- RS2: Authors
    SELECT a.AuthorID, a.FullName, a.Nationality, ar.RoleName, ba.SortOrder
    FROM   BookAuthors ba
    JOIN   Authors     a  ON ba.AuthorID = a.AuthorID
    JOIN   AuthorRoles ar ON ba.RoleID   = ar.RoleID
    WHERE  ba.BookID = @BookID
    ORDER  BY ba.SortOrder;

    -- RS3: Copies with BookNo, Location, and full address
    SELECT cp.CopyID, cp.BookNo, cp.Barcode, cc.CondName, cc.CondName AS Condition, cp.IsAvailable,
           cp.AcqDate, cp.AcqDate AS AcquisitionDate, cp.AcqCost, cp.SlotNo, cp.Notes, cp.Location,
           ISNULL(ro.FullAddress, ISNULL(cp.Location, b.Location)) AS FullAddress,
           ISNULL(ro.FullAddress, ISNULL(cp.Location, b.Location)) AS ShelfAddress,
           ro.HallName, ro.UnitCode, ro.RackNo
    FROM   BookCopies cp
    JOIN   Books b ON cp.BookID = b.BookID
    JOIN   CopyConditions cc ON cp.CondID = cc.CondID
    LEFT JOIN vw_RackOccupancy ro ON cp.RackID = ro.RackID
    WHERE  cp.BookID = @BookID
    ORDER  BY cp.CopyID ASC;
END;
GO
PRINT 'sp_GetBookDetail updated with Location fallback and LEFT JOINs.';
GO
