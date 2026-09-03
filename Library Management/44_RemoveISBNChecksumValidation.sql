USE GymkhanaLibraryDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- 1. Drop the schema-bound view first to allow column modifications
IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_Books' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    DROP VIEW dbo.vw_Books;
    PRINT 'Dropped view dbo.vw_Books';
END
GO

-- 2. Drop existing ISBN check constraints if they exist
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
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ISBN13_Valid')
    ALTER TABLE Books DROP CONSTRAINT CK_ISBN13_Valid;
GO

-- 3. Drop unique constraint on ISBN13 if it exists
IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'UQ_Books_ISBN13' AND parent_object_id = OBJECT_ID('Books') AND type_desc = 'UNIQUE_CONSTRAINT')
BEGIN
    ALTER TABLE Books DROP CONSTRAINT UQ_Books_ISBN13;
END;
GO

-- 4. Alter ISBN13 column to allow NULL
ALTER TABLE Books ALTER COLUMN ISBN13 VARCHAR(50) NULL;
GO

-- 5. Add a relaxed constraint that allows NULL or any non-empty string
ALTER TABLE Books ADD CONSTRAINT CK_ISBN13_Valid CHECK (ISBN13 IS NULL OR LEN(ISBN13) > 0);
GO

-- 6. Recreate the vw_Books view with safe formatting (returns raw ISBN if not standard 13-digit)
CREATE VIEW dbo.vw_Books WITH SCHEMABINDING AS
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
    b.IsAdults,
    b.IsChildren,
    b.DDC,
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
PRINT 'Recreated view dbo.vw_Books';
GO

-- 7. Recreate/Update sp_SaveBook stored procedure without ISBN validation and keeping all donation parameters
CREATE OR ALTER PROCEDURE dbo.sp_SaveBook
    @BookID          INT           = NULL,   -- NULL = new record
    @ISBN13          VARCHAR(50)   = NULL,
    @ISBN10          CHAR(10)      = NULL,
    @Title           NVARCHAR(250),
    @SubTitle        NVARCHAR(150) = NULL,
    @CatID           SMALLINT,
    @PubID           SMALLINT      = NULL,
    @LangID          TINYINT       = 1,
    @PubYear         SMALLINT      = NULL,
    @Edition         VARCHAR(30)   = NULL,
    @PageCount       SMALLINT      = NULL,
    @ClassNo         VARCHAR(30)   = NULL,
    @Tags            VARCHAR(300)  = NULL,
    @Synopsis        NVARCHAR(MAX) = NULL,
    @CoverFile       VARCHAR(50)   = NULL,
    @StaffID         SMALLINT      = NULL,
    @DDC             VARCHAR(50)   = NULL,
    @IsReference     BIT           = 0,
    @NotToBeIssued   BIT           = 0,
    @PrintBookDetail BIT           = 0,
    @AcqNo           VARCHAR(100)  = NULL,
    @PublishingPlace NVARCHAR(150) = NULL,
    @LiDate          VARCHAR(50)   = NULL,
    @Volume          VARCHAR(50)   = NULL,
    @WwwLink         VARCHAR(255)  = NULL,
    @Series          NVARCHAR(150) = NULL,
    @RecBy           NVARCHAR(150) = NULL,
    @PurchaseRef     VARCHAR(100)  = NULL,
    @PurchaseDate    VARCHAR(50)   = NULL,
    @PriceFcy        VARCHAR(50)   = NULL,
    @PricePkr        VARCHAR(50)   = NULL,
    @Format          VARCHAR(50)   = NULL,
    @Source          VARCHAR(50)   = NULL,
    @Status          VARCHAR(50)   = NULL,
    @ClassSeq        VARCHAR(50)   = NULL,
    @Location        VARCHAR(150)  = NULL,
    @IsAdults        BIT           = 0,
    @IsChildren      BIT           = 0,
    @DonatedBy       NVARCHAR(100) = NULL,
    @MS_No           VARCHAR(50)   = NULL,
    @DonatedByName   NVARCHAR(150) = NULL,
    -- OUTPUT
    @NewBookID       INT           OUTPUT,
    @Msg             VARCHAR(200)  OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- EAN-13 / ISBN-13 check digit validation removed

    -- Duplicate check is REMOVED as requested in V3 migration

    IF @BookID IS NULL
    BEGIN
        INSERT INTO Books
            (ISBN13,ISBN10,Title,SubTitle,CatID,PubID,LangID,PublishYear,
             Edition,PageCount,ClassNo,Tags,Synopsis,CoverFile,AddedByStaffID,DDC,
             IsReference, NotToBeIssued, PrintBookDetail,
             AcqNo, PublishingPlace, LiDate, Volume, WwwLink, Series, RecBy,
             PurchaseRef, PurchaseDate, PriceFcy, PricePkr, Format, Source, Status, ClassSeq, Location,
             IsAdults, IsChildren, DonatedBy, MS_No, DonatedByName)
        VALUES
            (@ISBN13,@ISBN10,@Title,@SubTitle,@CatID,@PubID,@LangID,@PubYear,
             @Edition,@PageCount,@ClassNo,@Tags,@Synopsis,@CoverFile,@StaffID,@DDC,
             @IsReference, @NotToBeIssued, @PrintBookDetail,
             @AcqNo, @PublishingPlace, @LiDate, @Volume, @WwwLink, @Series, @RecBy,
             @PurchaseRef, @PurchaseDate, @PriceFcy, @PricePkr, @Format, @Source, @Status, @ClassSeq, @Location,
             @IsAdults, @IsChildren, @DonatedBy, @MS_No, @DonatedByName);
        SET @NewBookID = SCOPE_IDENTITY();
        SET @Msg = 'OK:' + CAST(@NewBookID AS VARCHAR);
    END
    ELSE
    BEGIN
        UPDATE Books SET
            ISBN13     = @ISBN13,   ISBN10     = @ISBN10,
            Title      = @Title,    SubTitle   = @SubTitle,
            CatID      = @CatID,    PubID      = @PubID,    LangID = @LangID,
            PublishYear= @PubYear,  Edition    = @Edition,
            PageCount  = @PageCount,ClassNo    = @ClassNo,
            Tags       = @Tags,     Synopsis   = @Synopsis,
            CoverFile  = COALESCE(@CoverFile, CoverFile),
            DDC        = @DDC,
            IsReference = @IsReference,
            NotToBeIssued = @NotToBeIssued,
            PrintBookDetail = @PrintBookDetail,
            AcqNo      = @AcqNo,
            PublishingPlace = @PublishingPlace,
            LiDate     = @LiDate,
            Volume     = @Volume,
            WwwLink    = @WwwLink,
            Series     = @Series,
            RecBy      = @RecBy,
            PurchaseRef = @PurchaseRef,
            PurchaseDate = @PurchaseDate,
            PriceFcy   = @PriceFcy,
            PricePkr   = @PricePkr,
            Format     = @Format,
            Source     = @Source,
            Status     = @Status,
            ClassSeq   = @ClassSeq,
            Location   = @Location,
            IsAdults   = @IsAdults,
            IsChildren = @IsChildren,
            DonatedBy  = @DonatedBy,
            MS_No      = @MS_No,
            DonatedByName = @DonatedByName
        WHERE BookID = @BookID;
        SET @NewBookID = @BookID;
        SET @Msg = 'OK:' + CAST(@BookID AS VARCHAR);
    END
END;
GO

PRINT 'Database changes applied successfully: Nullable ISBN13, view vw_Books recreated, relaxed check constraint, and updated sp_SaveBook with donation columns.';
GO
