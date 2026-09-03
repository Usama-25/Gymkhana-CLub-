SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
USE GymkhanaLibraryDB;
GO

-- =============================================================================
--  Migration: Update sp_AddCopy to support DDC Last Number copy barcode generation
-- =============================================================================

CREATE OR ALTER PROCEDURE dbo.sp_AddCopy
    @BookID     INT,
    @RackID     SMALLINT      = NULL,
    @SlotNo     TINYINT       = NULL,
    @CondID     TINYINT       = 1,     -- 1=New
    @AcqCost    DECIMAL(8,2)  = NULL,
    @Notes      VARCHAR(200)  = NULL,
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

    -- Rack capacity check
    IF @RackID IS NOT NULL
    BEGIN
        DECLARE @TotalSlots TINYINT,
                @UsedSlots  INT;
        SELECT @TotalSlots = TotalSlots FROM Racks WHERE RackID = @RackID;
        SELECT @UsedSlots  = COUNT(*)    FROM BookCopies WHERE RackID = @RackID;

        IF @UsedSlots >= @TotalSlots
        BEGIN SET @Msg = 'ERR:RACK_FULL:' + CAST(@RackID AS VARCHAR); RETURN; END

        IF @SlotNo IS NOT NULL
           AND EXISTS (SELECT 1 FROM BookCopies WHERE RackID=@RackID AND SlotNo=@SlotNo)
        BEGIN SET @Msg = 'ERR:SLOT_TAKEN:' + CAST(@SlotNo AS VARCHAR); RETURN; END

        -- Auto-assign lowest free slot
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

    -- Check if book has a DDC call number
    SELECT @DDC = DDC FROM Books WHERE BookID = @BookID;

    IF @DDC IS NOT NULL AND LTRIM(RTRIM(@DDC)) <> ''
    BEGIN
        -- 1. Extract first range element if range exists (e.g. "928.982-TUN-1 to 928.982-TUN-10")
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

    INSERT INTO BookCopies (BookID, Barcode, RackID, SlotNo, CondID, AcqDate, AcqCost, Notes)
    VALUES (@BookID, @Barcode, @RackID, @SlotNo, @CondID, CAST(GETDATE() AS DATE), @AcqCost, @Notes);

    SET @CopyID = SCOPE_IDENTITY();
    SET @Msg    = 'OK:' + @Barcode;
END;
GO

PRINT 'sp_AddCopy updated successfully with DDC copy sequence support.';
GO
