USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Create or Alter stored procedure sp_SaveBook
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

    -- 2. Duplicate check (insert only)
    IF @BookID IS NULL AND EXISTS (SELECT 1 FROM Books WHERE ISBN13 = @ISBN13)
    BEGIN
        SET @Msg = 'ERR:ISBN13_EXISTS:' + @ISBN13;
        SET @NewBookID = -1; RETURN;
    END

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

-- 2. Update sp_GetBookDetail stored procedure
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
           b.PurchaseRef, b.PurchaseDate, b.PriceFcy, b.PricePkr, b.Format, b.Source, b.Status, b.ClassSeq, b.Location
    FROM   Books b
    JOIN   Categories c  ON b.CatID  = c.CatID
    JOIN   Languages  l  ON b.LangID = l.LangID
    LEFT JOIN Publishers p ON b.PubID = p.PubID
    WHERE  b.BookID = @BookID;

    -- RS2: Authors
    SELECT a.AuthorID, a.FullName, a.Nationality, ar.RoleName, ba.SortOrder
    FROM   BookAuthors ba
    JOIN   Authors     a  ON ba.AuthorID = a.AuthorID
    JOIN   AuthorRoles ar ON ba.RoleID   = ar.RoleID
    WHERE  ba.BookID = @BookID
    ORDER  BY ba.SortOrder;

    -- RS3: Copies with location
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
