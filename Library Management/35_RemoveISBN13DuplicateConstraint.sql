USE GymkhanaLibraryDB;
GO

-- 1. Drop the Unique Constraint on ISBN13 if it exists
IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'UQ_Books_ISBN13' AND parent_object_id = OBJECT_ID('Books') AND type_desc = 'UNIQUE_CONSTRAINT')
BEGIN
    ALTER TABLE Books DROP CONSTRAINT UQ_Books_ISBN13;
END;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- 2. Update sp_SaveBook stored procedure to remove duplicate ISBN check
CREATE OR ALTER PROCEDURE dbo.sp_SaveBook
    @BookID          INT           = NULL,   -- NULL = new record
    @ISBN13          VARCHAR(50),
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
    -- OUTPUT
    @NewBookID       INT           OUTPUT,
    @Msg             VARCHAR(200)  OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. ISBN-13 check digit validation
    IF LEN(@ISBN13) = 13 AND @ISBN13 NOT LIKE '%[^0-9]%'
    BEGIN
        IF dbo.fn_ISBN13Valid(@ISBN13) = 0
        BEGIN
            SET @Msg = 'ERR:ISBN13_INVALID:' + @ISBN13;
            SET @NewBookID = -1; RETURN;
        END
    END

    -- Duplicate check is REMOVED as requested

    IF @BookID IS NULL
    BEGIN
        INSERT INTO Books
            (ISBN13,ISBN10,Title,SubTitle,CatID,PubID,LangID,PublishYear,
             Edition,PageCount,ClassNo,Tags,Synopsis,CoverFile,AddedByStaffID,DDC,
             IsReference, NotToBeIssued, PrintBookDetail,
             AcqNo, PublishingPlace, LiDate, Volume, WwwLink, Series, RecBy,
             PurchaseRef, PurchaseDate, PriceFcy, PricePkr, Format, Source, Status, ClassSeq, Location)
        VALUES
            (@ISBN13,@ISBN10,@Title,@SubTitle,@CatID,@PubID,@LangID,@PubYear,
             @Edition,@PageCount,@ClassNo,@Tags,@Synopsis,@CoverFile,@StaffID,@DDC,
             @IsReference, @NotToBeIssued, @PrintBookDetail,
             @AcqNo, @PublishingPlace, @LiDate, @Volume, @WwwLink, @Series, @RecBy,
             @PurchaseRef, @PurchaseDate, @PriceFcy, @PricePkr, @Format, @Source, @Status, @ClassSeq, @Location);
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
            Location   = @Location
        WHERE BookID = @BookID;
        SET @NewBookID = @BookID;
        SET @Msg = 'OK:' + CAST(@BookID AS VARCHAR);
    END
END;
GO

PRINT 'Duplicate ISBN13 validation removed successfully.';
GO
