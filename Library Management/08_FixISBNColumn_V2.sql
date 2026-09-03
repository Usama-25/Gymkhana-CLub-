SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
USE GymkhanaLibraryDB;
GO

-- =============================================================================
--  Step 1: Drop dependent objects that reference ISBN13
-- =============================================================================

-- Drop the view that uses fn_ISBN13Fmt on ISBN13
IF OBJECT_ID('dbo.vw_Books', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Books;
GO

-- Drop CHECK constraints on Books.ISBN13
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ISBN13_Fmt')
    ALTER TABLE Books DROP CONSTRAINT CK_ISBN13_Fmt;
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ISBN13_Digits')
    ALTER TABLE Books DROP CONSTRAINT CK_ISBN13_Digits;
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ISBN13_Check')
    ALTER TABLE Books DROP CONSTRAINT CK_ISBN13_Check;
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ISBN13_Length')
    ALTER TABLE Books DROP CONSTRAINT CK_ISBN13_Length;
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ISBN13_Numeric')
    ALTER TABLE Books DROP CONSTRAINT CK_ISBN13_Numeric;
GO

-- Drop IX_Books_CatID if it exists (it apparently includes ISBN13)
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Books_CatID' AND object_id = OBJECT_ID('Books'))
    DROP INDEX IX_Books_CatID ON Books;
GO

-- Drop any unique constraints on ISBN13
DECLARE @ixName NVARCHAR(128);
SELECT TOP 1 @ixName = i.name
FROM sys.indexes i
JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('Books') AND c.name = 'ISBN13' AND i.is_unique = 1 AND i.is_primary_key = 0;

IF @ixName IS NOT NULL
    EXEC('ALTER TABLE Books DROP CONSTRAINT [' + @ixName + ']');
GO

-- =============================================================================
--  Step 2: Alter Books.ISBN13
-- =============================================================================

ALTER TABLE Books ALTER COLUMN ISBN13 VARCHAR(50) NOT NULL;
GO

ALTER TABLE Books ADD CONSTRAINT UQ_Books_ISBN13 UNIQUE (ISBN13);
GO

ALTER TABLE Books ADD CONSTRAINT CK_ISBN13_Valid CHECK (
    LEN(ISBN13) > 0
    AND (
        ISBN13 LIKE '%[^0-9]%'
        OR (LEN(ISBN13) = 13 AND ISBN13 NOT LIKE '%[^0-9]%' AND dbo.fn_ISBN13Valid(ISBN13) = 1)
        OR (ISBN13 NOT LIKE '%[^0-9]%' AND LEN(ISBN13) <> 13)
    )
);
GO

-- Recreate IX_Books_CatID without ISBN13 (or just on CatID)
CREATE NONCLUSTERED INDEX IX_Books_CatID ON Books (CatID);
GO

-- =============================================================================
--  Step 3: Alter BookCopies.Barcode
-- =============================================================================

-- Drop unique index/constraint on Barcode
DECLARE @bcIxName NVARCHAR(128);
SELECT TOP 1 @bcIxName = i.name
FROM sys.indexes i
JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('BookCopies') AND c.name = 'Barcode' AND i.is_unique = 1 AND i.is_primary_key = 0;

IF @bcIxName IS NOT NULL
    EXEC('ALTER TABLE BookCopies DROP CONSTRAINT [' + @bcIxName + ']');
GO

ALTER TABLE BookCopies ALTER COLUMN Barcode VARCHAR(60) NOT NULL;
GO

ALTER TABLE BookCopies ADD CONSTRAINT UQ_BookCopies_Barcode UNIQUE (Barcode);
GO

-- =============================================================================
--  Step 4: Recreate vw_Books view
-- =============================================================================
CREATE VIEW vw_Books WITH SCHEMABINDING AS
SELECT
    b.BookID,
    b.ISBN13,
    CASE 
        WHEN LEN(b.ISBN13) = 13 AND b.ISBN13 NOT LIKE '%[^0-9]%'
        THEN dbo.fn_ISBN13Fmt(b.ISBN13)
        ELSE b.ISBN13
    END AS ISBN13Fmt,
    b.ISBN10,
    b.Title,
    b.SubTitle,
    b.Edition,
    b.PublishYear,
    b.ClassNo,
    b.CoverFile,
    b.IsActive,
    c.CatCode,
    c.CatName,
    p.PubName,
    l.LangName,
    (SELECT COUNT(*)
     FROM dbo.BookCopies cp
     WHERE cp.BookID = b.BookID)                              AS TotalCopies,
    (SELECT COUNT(*)
     FROM dbo.BookCopies cp
     WHERE cp.BookID = b.BookID AND cp.IsAvailable = 1
       AND cp.CondID NOT IN (5,6))                            AS AvailableCopies
FROM dbo.Books     b
JOIN dbo.Categories c  ON b.CatID  = c.CatID
JOIN dbo.Languages  l  ON b.LangID = l.LangID
LEFT JOIN dbo.Publishers p ON b.PubID = p.PubID;
GO

-- =============================================================================
--  Step 5: Update sp_AddCopy
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_AddCopy
    @BookID     INT,
    @RackID     SMALLINT      = NULL,
    @SlotNo     TINYINT       = NULL,
    @CondID     TINYINT       = 1,
    @AcqCost    DECIMAL(8,2)  = NULL,
    @Notes      VARCHAR(200)  = NULL,
    @CopyID     INT           OUTPUT,
    @Barcode    VARCHAR(60)   OUTPUT,
    @Msg        VARCHAR(200)  OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ISBN13 VARCHAR(50), @Seq INT;

    IF NOT EXISTS (SELECT 1 FROM Books WHERE BookID = @BookID AND IsActive = 1)
    BEGIN SET @Msg = 'ERR:BOOK_NOT_FOUND'; RETURN; END

    IF @RackID IS NOT NULL
    BEGIN
        DECLARE @TotalSlots TINYINT, @UsedSlots INT;
        SELECT @TotalSlots = TotalSlots FROM Racks WHERE RackID = @RackID;
        SELECT @UsedSlots  = COUNT(*)    FROM BookCopies WHERE RackID = @RackID;

        IF @UsedSlots >= @TotalSlots
        BEGIN SET @Msg = 'ERR:RACK_FULL:' + CAST(@RackID AS VARCHAR); RETURN; END

        IF @SlotNo IS NOT NULL
           AND EXISTS (SELECT 1 FROM BookCopies WHERE RackID=@RackID AND SlotNo=@SlotNo)
        BEGIN SET @Msg = 'ERR:SLOT_TAKEN:' + CAST(@SlotNo AS VARCHAR); RETURN; END

        IF @SlotNo IS NULL
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

    SELECT @ISBN13 = ISBN13 FROM Books WHERE BookID = @BookID;
    SELECT @Seq = COUNT(*) + 1 FROM BookCopies WHERE BookID = @BookID;
    SET @Barcode = @ISBN13 + '-' + RIGHT('000' + CAST(@Seq AS VARCHAR(3)), 3);

    INSERT INTO BookCopies (BookID, Barcode, RackID, SlotNo, CondID, AcqDate, AcqCost, Notes)
    VALUES (@BookID, @Barcode, @RackID, @SlotNo, @CondID, CAST(GETDATE() AS DATE), @AcqCost, @Notes);

    SET @CopyID = SCOPE_IDENTITY();
    SET @Msg    = 'OK:' + @Barcode;
END;
GO

-- =============================================================================
--  Step 6: Update sp_GetBookDetail
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_GetBookDetail
    @BookID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT b.BookID, b.ISBN13,
           CASE WHEN LEN(b.ISBN13) = 13 AND b.ISBN13 NOT LIKE '%[^0-9]%'
                THEN dbo.fn_ISBN13Fmt(b.ISBN13) ELSE b.ISBN13 END AS ISBN13Fmt,
           b.ISBN10, b.Title, b.SubTitle, b.Edition, b.PublishYear,
           b.PageCount, b.ClassNo, b.Tags, b.Synopsis, b.CoverFile,
           c.CatName, p.PubName, l.LangName
    FROM   Books b
    JOIN   Categories c  ON b.CatID  = c.CatID
    JOIN   Languages  l  ON b.LangID = l.LangID
    LEFT JOIN Publishers p ON b.PubID = p.PubID
    WHERE  b.BookID = @BookID;

    SELECT a.AuthorID, a.FullName, a.Nationality, ar.RoleName, ba.SortOrder
    FROM   BookAuthors ba
    JOIN   Authors     a  ON ba.AuthorID = a.AuthorID
    JOIN   AuthorRoles ar ON ba.RoleID   = ar.RoleID
    WHERE  ba.BookID = @BookID
    ORDER  BY ba.SortOrder;

    SELECT cp.CopyID, cp.Barcode, cc.CondName, cc.CondName AS Condition, cp.IsAvailable,
           cp.AcqDate, cp.AcqDate AS AcquisitionDate, cp.AcqCost, cp.SlotNo, cp.Notes,
           ro.FullAddress, ro.FullAddress AS ShelfAddress, ro.HallName, ro.UnitCode, ro.RackNo
    FROM   BookCopies cp
    JOIN   CopyConditions cc ON cp.CondID = cc.CondID
    LEFT JOIN vw_RackOccupancy ro ON cp.RackID = ro.RackID
    WHERE  cp.BookID = @BookID
    ORDER  BY ro.FullAddress, cp.SlotNo;
END;
GO

PRINT '=== SQL executed successfully ===';
GO
