USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Add columns to Books table if they don't exist
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Books') AND name = 'IsReference')
BEGIN
    ALTER TABLE Books ADD IsReference BIT NOT NULL DEFAULT 0;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Books') AND name = 'NotToBeIssued')
BEGIN
    ALTER TABLE Books ADD NotToBeIssued BIT NOT NULL DEFAULT 0;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Books') AND name = 'PrintBookDetail')
BEGIN
    ALTER TABLE Books ADD PrintBookDetail BIT NOT NULL DEFAULT 0;
END
GO

-- 2. Update sp_SaveBook stored procedure
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
             IsReference, NotToBeIssued, PrintBookDetail)
        VALUES
            (@ISBN13,@ISBN10,@Title,@SubTitle,@CatID,@PubID,@LangID,@PubYear,
             @Edition,@PageCount,@ClassNo,@Tags,@Synopsis,@CoverFile,@StaffID,@DDC,
             @IsReference, @NotToBeIssued, @PrintBookDetail);
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
            PrintBookDetail = @PrintBookDetail
        WHERE BookID = @BookID;
        SET @NewBookID = @BookID;
        SET @Msg = 'OK:' + CAST(@BookID AS VARCHAR);
    END
END;
GO

-- 3. Update sp_GetBookDetail stored procedure
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
           b.IsReference, b.NotToBeIssued, b.PrintBookDetail
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

-- 4. Update sp_IssueBook stored procedure
CREATE OR ALTER PROCEDURE dbo.sp_IssueBook
    @MemberID   INT,
    @CopyID     INT,
    @StaffID    SMALLINT,
    @Msg        VARCHAR(200) OUTPUT,
    @IssueDate  DATETIME     = NULL,
    @DueDate    DATE         = NULL,
    @ActualBorrowerNo   VARCHAR(50) = NULL,
    @ActualBorrowerName NVARCHAR(150) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LoanDays INT, @Active INT, @MaxBooks TINYINT,
            @FineCeiling DECIMAL(8,2), @UnpaidFines DECIMAL(8,2);
    DECLARE @BookID INT, @AvailableCopies INT, @MemberRank INT, @TotalActiveReservations INT, @IsAllowedIssue BIT;
    DECLARE @ResHolderName NVARCHAR(100), @ResHolderNo VARCHAR(30);

    -- Atomic Sync member from MemberShip database if they don't exist locally
    EXEC dbo.sp_EnsureMemberExists @MemberID;

    -- Member active?
    IF NOT EXISTS (SELECT 1 FROM Members WHERE MemberID=@MemberID AND IsActive=1)
    BEGIN SET @Msg='ERR:MEMBER_INACTIVE'; RETURN; END

    -- Copy available?
    IF NOT EXISTS (SELECT 1 FROM BookCopies WHERE CopyID=@CopyID AND IsAvailable=1 AND CondID NOT IN (5,6))
    BEGIN SET @Msg='ERR:COPY_UNAVAILABLE'; RETURN; END

    -- Reference or Not For Issuance check
    IF EXISTS (
        SELECT 1 
        FROM BookCopies cp 
        JOIN Books b ON cp.BookID = b.BookID 
        WHERE cp.CopyID = @CopyID 
          AND (b.IsReference = 1 OR b.NotToBeIssued = 1 OR b.PrintBookDetail = 1)
    )
    BEGIN
        SET @Msg = 'ERR:REFERENCE_ONLY';
        RETURN;
    END

    -- Priority check
    SET @BookID = (SELECT BookID FROM BookCopies WHERE CopyID = @CopyID);
    
    SELECT @AvailableCopies = COUNT(*)
    FROM dbo.BookCopies
    WHERE BookID = @BookID AND IsAvailable = 1 AND CondID NOT IN (5,6);

    SELECT @MemberRank = MemberRank
    FROM (
        SELECT MemberID, ROW_NUMBER() OVER (ORDER BY QueuePos, ReservedAt) AS MemberRank
        FROM dbo.Reservations
        WHERE BookID = @BookID AND StatusID = 1
    ) t
    WHERE MemberID = @MemberID;

    SELECT @TotalActiveReservations = COUNT(*)
    FROM dbo.Reservations
    WHERE BookID = @BookID AND StatusID = 1;

    SET @IsAllowedIssue = 0;
    IF @MemberRank IS NOT NULL AND @MemberRank <= @AvailableCopies
    BEGIN
        SET @IsAllowedIssue = 1;
    END
    ELSE IF @MemberRank IS NULL AND @AvailableCopies > @TotalActiveReservations
    BEGIN
        SET @IsAllowedIssue = 1;
    END

    IF @IsAllowedIssue = 0
    BEGIN
        SELECT TOP 1 @ResHolderName = m.FullName, @ResHolderNo = m.MembershipNo
        FROM dbo.Reservations r
        JOIN dbo.Members m ON r.MemberID = m.MemberID
        WHERE r.BookID = @BookID AND r.StatusID = 1
        ORDER BY r.QueuePos, r.ReservedAt;
        
        IF @ResHolderName IS NOT NULL
            SET @Msg = 'ERR:RESERVED_FOR_OTHER:' + @ResHolderName + ' (' + @ResHolderNo + ')';
        ELSE
            SET @Msg = 'ERR:RESERVED_FOR_OTHER:Another Member';
            
        RETURN;
    END

    -- Borrow limit
    SELECT @Active = COUNT(*) FROM Loans
    WHERE  MemberID=@MemberID AND StatusID IN (1,3,4);   -- Issued/Overdue/Renewed
    SELECT @MaxBooks = COALESCE(m.MaxBooksOverride, mt.MaxBooks)
    FROM   Members m JOIN MemberTypes mt ON m.MTypeID=mt.MTypeID
    WHERE  m.MemberID=@MemberID;
    IF @Active >= @MaxBooks
    BEGIN SET @Msg='ERR:BORROW_LIMIT:' + CAST(@MaxBooks AS VARCHAR); RETURN; END

    -- Fine ceiling
    SELECT @FineCeiling = CAST(SVal AS DECIMAL(8,2)) FROM Settings WHERE SKey='FineCeiling';
    SELECT @UnpaidFines = ISNULL(SUM(FineAmount),0) FROM Fines
    WHERE  MemberID=@MemberID AND IsPaid=0;
    IF @UnpaidFines >= @FineCeiling
    BEGIN SET @Msg='ERR:UNPAID_FINES:' + CAST(@UnpaidFines AS VARCHAR); RETURN; END

    SELECT @LoanDays = CAST(SVal AS INT) FROM Settings WHERE SKey='LoanDays';

    DECLARE @ActualIssueDate DATETIME = COALESCE(@IssueDate, SYSDATETIME());
    DECLARE @ActualDueDate DATE = COALESCE(@DueDate, DATEADD(DAY, @LoanDays, CAST(GETDATE() AS DATE)));

    BEGIN TRAN;
        INSERT INTO Loans (MemberID, CopyID, IssueDate, DueDate, StatusID, IssuedByID, ActualBorrowerNo, ActualBorrowerName)
        VALUES (@MemberID, @CopyID, @ActualIssueDate, @ActualDueDate, 1, @StaffID, @ActualBorrowerNo, @ActualBorrowerName);

        UPDATE BookCopies SET IsAvailable=0 WHERE CopyID=@CopyID;

        -- Fulfill any active reservation for this member and book
        UPDATE Reservations
        SET StatusID = 2, NotifiedAt = COALESCE(NotifiedAt, SYSDATETIME())
        WHERE MemberID = @MemberID AND BookID = @BookID AND StatusID = 1;

        -- Re-sequence remaining active reservations for this book
        WITH CTE AS (
            SELECT QueuePos, ROW_NUMBER() OVER (ORDER BY QueuePos, ReservedAt) as NewPos
            FROM Reservations
            WHERE BookID = @BookID AND StatusID = 1
        )
        UPDATE CTE SET QueuePos = NewPos;
    COMMIT;

    SET @Msg = 'OK:DUE:' + CONVERT(VARCHAR, @ActualDueDate, 106);
END;
GO
