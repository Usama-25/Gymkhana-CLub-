USE GymkhanaLibraryDB;
GO

-- 1. Add actual borrower columns to Loans table if they do not exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Loans') AND name = 'ActualBorrowerNo')
BEGIN
    ALTER TABLE dbo.Loans ADD ActualBorrowerNo VARCHAR(50) NULL;
    PRINT 'Added ActualBorrowerNo to Loans.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Loans') AND name = 'ActualBorrowerName')
BEGIN
    ALTER TABLE dbo.Loans ADD ActualBorrowerName NVARCHAR(150) NULL;
    PRINT 'Added ActualBorrowerName to Loans.';
END
GO

-- 2. Update sp_IssueBook
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

-- 3. Update sp_ReturnCollectReissue
CREATE OR ALTER PROCEDURE dbo.sp_ReturnCollectReissue
    @CopyID             INT,
    @StaffID            SMALLINT,
    @CondID             TINYINT      = 2,    -- default condition 'Good'
    @ReissueToMemberID  INT          = NULL, -- if NULL, reissue to the returning member
    @IssueDate          DATETIME     = NULL,
    @DueDate            DATE         = NULL,
    @CollectFines       BIT          = 1,    -- if 1, atomically mark the generated fine as paid
    @Msg                VARCHAR(200) OUTPUT,
    @ActualBorrowerNo   VARCHAR(50)  = NULL,
    @ActualBorrowerName NVARCHAR(150) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LoanID INT, @ReturningMemberID INT, @DueDateOrig DATE,
            @FPD DECIMAL(8,2), @Days INT, @Fine DECIMAL(8,2) = 0,
            @NewFineID INT = NULL;
    DECLARE @BookID INT, @AvailableCopies INT, @MemberRank INT, @TotalActiveReservations INT, @IsAllowedReissue BIT;
    DECLARE @ResHolderName NVARCHAR(100), @ResHolderNo VARCHAR(30);

    -- 1. Find active loan
    SELECT TOP 1
        @LoanID             = LoanID,
        @ReturningMemberID  = MemberID,
        @DueDateOrig        = DueDate
    FROM   dbo.Loans
    WHERE  CopyID=@CopyID AND StatusID IN (1,3,4)
    ORDER  BY IssueDate DESC;

    IF @LoanID IS NULL
    BEGIN
        SET @Msg='ERR:NO_ACTIVE_LOAN';
        RETURN;
    END

    -- Reissue target member
    DECLARE @TargetMemberID INT = COALESCE(@ReissueToMemberID, @ReturningMemberID);

    BEGIN TRAN;
        -- A. Return the book
        UPDATE dbo.Loans
        SET    ReturnDate = SYSDATETIME(), 
               StatusID = 2, 
               ReturnedByID = @StaffID
        WHERE  LoanID = @LoanID;

        -- We update the copy condition. IsAvailable will be updated by reissue.
        UPDATE dbo.BookCopies 
        SET    CondID = @CondID 
        WHERE  CopyID = @CopyID;

        -- B. Calculate overdue fine
        SET @Days = DATEDIFF(DAY, @DueDateOrig, CAST(GETDATE() AS DATE));
        IF @Days > 0
        BEGIN
            SELECT @FPD = CAST(SVal AS DECIMAL(8,2)) FROM dbo.Settings WHERE SKey='FinePerDay';
            SET @Fine = @Days * @FPD;
            
            -- Insert the fine
            INSERT INTO dbo.Fines (LoanID, MemberID, ReasonID, FineAmount, IsPaid, PaidAt, CollectedByID)
            VALUES (@LoanID, @ReturningMemberID, 1, @Fine, 
                    CASE WHEN @CollectFines = 1 THEN 1 ELSE 0 END,
                    CASE WHEN @CollectFines = 1 THEN SYSDATETIME() ELSE NULL END,
                    CASE WHEN @CollectFines = 1 THEN @StaffID ELSE NULL END);
            
            SET @NewFineID = SCOPE_IDENTITY();
        END

        -- C. Reissue the book
        -- Atomic Sync target member from MemberShip database if they don't exist locally
        EXEC dbo.sp_EnsureMemberExists @TargetMemberID;

        -- Inline validation for target member:
        -- Target member active?
        IF NOT EXISTS (SELECT 1 FROM dbo.Members WHERE MemberID=@TargetMemberID AND IsActive=1)
        BEGIN 
            ROLLBACK TRAN;
            SET @Msg='ERR:MEMBER_INACTIVE'; 
            RETURN; 
        END

        -- Priority check for reissue
        SET @BookID = (SELECT BookID FROM dbo.BookCopies WHERE CopyID = @CopyID);
        
        SELECT @AvailableCopies = COUNT(*)
        FROM dbo.BookCopies
        WHERE BookID = @BookID AND IsAvailable = 1 AND CondID NOT IN (5,6);
        
        IF @CondID NOT IN (5,6)
        BEGIN
            SET @AvailableCopies = @AvailableCopies + 1;
        END

        SELECT @MemberRank = MemberRank
        FROM (
            SELECT MemberID, ROW_NUMBER() OVER (ORDER BY QueuePos, ReservedAt) as MemberRank
            FROM dbo.Reservations
            WHERE BookID = @BookID AND StatusID = 1
        ) t
        WHERE MemberID = @TargetMemberID;

        SELECT @TotalActiveReservations = COUNT(*)
        FROM dbo.Reservations
        WHERE BookID = @BookID AND StatusID = 1;

        SET @IsAllowedReissue = 0;
        IF @MemberRank IS NOT NULL AND @MemberRank <= @AvailableCopies
        BEGIN
            SET @IsAllowedReissue = 1;
        END
        ELSE IF @MemberRank IS NULL AND @AvailableCopies > @TotalActiveReservations
        BEGIN
            SET @IsAllowedReissue = 1;
        END

        IF @IsAllowedReissue = 0
        BEGIN
            ROLLBACK TRAN;
            
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

        -- Borrow limit check (excluding the current loan that we just closed!)
        DECLARE @Active INT, @MaxBooks TINYINT;
        SELECT @Active = COUNT(*) FROM dbo.Loans
        WHERE  MemberID=@TargetMemberID AND StatusID IN (1,3,4);   -- Issued/Overdue/Renewed

        SELECT @MaxBooks = COALESCE(m.MaxBooksOverride, mt.MaxBooks)
        FROM   dbo.Members m JOIN dbo.MemberTypes mt ON m.MTypeID=mt.MTypeID
        WHERE  m.MemberID=@TargetMemberID;

        IF @Active >= @MaxBooks
        BEGIN 
            ROLLBACK TRAN;
            SET @Msg='ERR:BORROW_LIMIT:' + CAST(@MaxBooks AS VARCHAR); 
            RETURN; 
        END

        -- Fine ceiling check for target member.
        DECLARE @FineCeiling DECIMAL(8,2), @UnpaidFines DECIMAL(8,2);
        SELECT @FineCeiling = CAST(SVal AS DECIMAL(8,2)) FROM dbo.Settings WHERE SKey='FineCeiling';
        SELECT @UnpaidFines = ISNULL(SUM(FineAmount),0) FROM dbo.Fines
        WHERE  MemberID=@TargetMemberID AND IsPaid=0;

        IF @UnpaidFines >= @FineCeiling
        BEGIN 
            ROLLBACK TRAN;
            SET @Msg='ERR:UNPAID_FINES:' + CAST(@UnpaidFines AS VARCHAR); 
            RETURN; 
        END

        -- Standard duration
        DECLARE @LoanDays INT;
        SELECT @LoanDays = CAST(SVal AS INT) FROM dbo.Settings WHERE SKey='LoanDays';

        DECLARE @ActualIssueDate DATETIME = COALESCE(@IssueDate, SYSDATETIME());
        DECLARE @ActualDueDate DATE = COALESCE(@DueDate, DATEADD(DAY, @LoanDays, CAST(GETDATE() AS DATE)));

        -- Insert new loan
        INSERT INTO dbo.Loans (MemberID, CopyID, IssueDate, DueDate, StatusID, IssuedByID, ActualBorrowerNo, ActualBorrowerName)
        VALUES (@TargetMemberID, @CopyID, @ActualIssueDate, @ActualDueDate, 1, @StaffID, @ActualBorrowerNo, @ActualBorrowerName);

        -- Keep copy unavailable
        UPDATE dbo.BookCopies SET IsAvailable=0 WHERE CopyID=@CopyID;

        -- Fulfill any active reservation for this target member and book
        UPDATE dbo.Reservations
        SET StatusID = 2, NotifiedAt = COALESCE(NotifiedAt, SYSDATETIME())
        WHERE MemberID = @TargetMemberID AND BookID = @BookID AND StatusID = 1;

        -- Re-sequence remaining active reservations for this book
        WITH CTE AS (
            SELECT QueuePos, ROW_NUMBER() OVER (ORDER BY QueuePos, ReservedAt) as NewPos
            FROM dbo.Reservations
            WHERE BookID = @BookID AND StatusID = 1
        )
        UPDATE CTE SET QueuePos = NewPos;
    COMMIT;

    -- Return different status tokens based on overdue fine generation
    IF @Fine > 0
        SET @Msg = 'OK:REISSUED:FINE_PAID:' + CAST(@Fine AS VARCHAR(12)) + ':DUE:' + CONVERT(VARCHAR, @ActualDueDate, 106);
    ELSE
        SET @Msg = 'OK:REISSUED:NO_FINE:DUE:' + CONVERT(VARCHAR, @ActualDueDate, 106);
END;
GO

-- 4. Update sp_Report_BookIssuance
CREATE OR ALTER PROCEDURE dbo.sp_Report_BookIssuance
    @FromDate   DATE = NULL,
    @ToDate     DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Default: current month
    IF @FromDate IS NULL SET @FromDate = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
    IF @ToDate   IS NULL SET @ToDate   = CAST(GETDATE() AS DATE);

    SELECT
        l.LoanID,
        COALESCE(l.ActualBorrowerNo, m.MembershipNo) AS MembershipNo,
        COALESCE(l.ActualBorrowerName, m.FullName)   AS MemberName,
        m.Phone,
        b.ISBN13,
        dbo.fn_ISBN13Fmt(b.ISBN13) AS ISBN13Fmt,
        b.Title,
        cp.Barcode,
        l.IssueDate,
        l.DueDate,
        l.ReturnDate,
        l.RenewalCount,
        ts.StatusName           AS Status,
        ISNULL(s.EFName, '') + ' ' + ISNULL(s.ELName, '') AS IssuedBy
    FROM Loans l
    JOIN Members m             ON l.MemberID   = m.MemberID
    JOIN BookCopies cp         ON l.CopyID     = cp.CopyID
    JOIN Books b               ON cp.BookID    = b.BookID
    JOIN TxnStatuses ts        ON l.StatusID   = ts.StatusID
    LEFT JOIN User_management.dbo.Employee s  ON l.IssuedByID = s.EmpID
    WHERE CAST(l.IssueDate AS DATE) BETWEEN @FromDate AND @ToDate
    ORDER BY l.IssueDate DESC;
END;
GO

-- 5. Update sp_Report_IssuedNotReturned
CREATE OR ALTER PROCEDURE dbo.sp_Report_IssuedNotReturned
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @FPD DECIMAL(8,2);
    SELECT @FPD = CAST(SVal AS DECIMAL(8,2)) FROM Settings WHERE SKey='FinePerDay';

    SELECT
        l.LoanID,
        COALESCE(l.ActualBorrowerNo, m.MembershipNo) AS MembershipNo,
        COALESCE(l.ActualBorrowerName, m.FullName)   AS MemberName,
        m.Phone,
        b.ISBN13,
        dbo.fn_ISBN13Fmt(b.ISBN13) AS ISBN13Fmt,
        b.Title,
        cp.Barcode,
        l.IssueDate,
        l.DueDate,
        l.RenewalCount,
        ts.StatusName           AS Status,
        CASE WHEN l.DueDate < CAST(GETDATE() AS DATE)
             THEN DATEDIFF(DAY, l.DueDate, GETDATE()) ELSE 0 END AS DaysOverdue,
        CASE WHEN l.DueDate < CAST(GETDATE() AS DATE)
             THEN DATEDIFF(DAY, l.DueDate, GETDATE()) * @FPD ELSE 0 END AS EstimatedFine,
        ISNULL(s.EFName, '') + ' ' + ISNULL(s.ELName, '') AS IssuedBy
    FROM Loans l
    JOIN Members m             ON l.MemberID   = m.MemberID
    JOIN BookCopies cp         ON l.CopyID     = cp.CopyID
    JOIN Books b               ON cp.BookID    = b.BookID
    JOIN TxnStatuses ts        ON l.StatusID   = ts.StatusID
    LEFT JOIN User_management.dbo.Employee s  ON l.IssuedByID = s.EmpID
    WHERE l.StatusID IN (1, 3, 4)   -- Issued / Overdue / Renewed
      AND l.ReturnDate IS NULL
    ORDER BY l.DueDate ASC;
END;
GO

-- 6. Update sp_GetOverdueReminderList
CREATE OR ALTER PROCEDURE dbo.sp_GetOverdueReminderList
    @Scenario INT = NULL -- 1, 2, or 3
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @FPD DECIMAL(8,2);
    SELECT @FPD = CAST(SVal AS DECIMAL(8,2)) FROM Settings WHERE SKey='FinePerDay';
    SET @FPD = ISNULL(@FPD, 10.00);

    SELECT 
        l.LoanID,
        m.MemberID,
        COALESCE(l.ActualBorrowerNo, m.MembershipNo) AS MembershipNo,
        COALESCE(l.ActualBorrowerName, m.FullName)   AS MemberName,
        m.Phone,
        m.Email,
        ISNULL(mp.Address, 'Lahore Gymkhana Club, Lahore, Pakistan') AS MemberAddress,
        b.Title AS BookTitle,
        cp.Barcode,
        ISNULL(cp.AcqCost, 1000.00) AS AcqCost,
        l.IssueDate,
        l.DueDate,
        DATEDIFF(DAY, l.DueDate, CAST(GETDATE() AS DATE)) AS DaysOverdue,
        DATEDIFF(DAY, l.DueDate, CAST(GETDATE() AS DATE)) * @FPD AS EstFine,
        ISNULL(cp.AcqCost, 1000.00) * 2.0 AS PenaltyAmount,
        (DATEDIFF(DAY, l.DueDate, CAST(GETDATE() AS DATE)) * @FPD) + ISNULL(cp.AcqCost, 1000.00) + (ISNULL(cp.AcqCost, 1000.00) * 2.0) AS TotalOverdueCharge,
        l.Reminder1SentDate,
        l.Reminder2SentDate,
        l.Reminder3SentDate,
        l.IsFinalCharged,
        -- Determine applicable scenario
        CASE 
            WHEN DATEDIFF(DAY, l.DueDate, CAST(GETDATE() AS DATE)) >= 30 AND l.Reminder3SentDate IS NULL THEN 3
            WHEN DATEDIFF(DAY, l.DueDate, CAST(GETDATE() AS DATE)) >= 15 AND l.Reminder3SentDate IS NULL AND l.Reminder2SentDate IS NULL THEN 2
            WHEN DATEDIFF(DAY, l.DueDate, CAST(GETDATE() AS DATE)) >= 7 AND l.Reminder3SentDate IS NULL AND l.Reminder2SentDate IS NULL AND l.Reminder1SentDate IS NULL THEN 1
            ELSE 0
        END AS ApplicableScenario
    INTO #Reminders
    FROM Loans l
    JOIN Members m ON l.MemberID = m.MemberID
    JOIN BookCopies cp ON l.CopyID = cp.CopyID
    JOIN Books b ON cp.BookID = b.BookID
    LEFT JOIN MemberShip.dbo.MemberProfile mp ON m.MemberID = mp.MemberID
    WHERE l.StatusID IN (1,3,4) -- Issued, Overdue, Renewed
      AND l.DueDate <= DATEADD(DAY, -7, CAST(GETDATE() AS DATE));

    -- Return filtered list
    SELECT * 
    FROM #Reminders
    WHERE (@Scenario IS NULL OR ApplicableScenario = @Scenario)
      AND ApplicableScenario > 0
    ORDER BY DaysOverdue DESC;

    DROP TABLE #Reminders;
END;
GO

-- 7. Update sp_GetFinalChargedLoans
CREATE OR ALTER PROCEDURE dbo.sp_GetFinalChargedLoans
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        l.LoanID,
        m.MemberID,
        COALESCE(l.ActualBorrowerNo, m.MembershipNo) AS MembershipNo,
        COALESCE(l.ActualBorrowerName, m.FullName)   AS MemberName,
        b.Title AS BookTitle,
        cp.Barcode,
        l.IssueDate,
        l.DueDate,
        l.Reminder3SentDate AS ChargedDate,
        -- Overdue Fine
        (SELECT ISNULL(SUM(FineAmount), 0.00) FROM Fines WHERE LoanID = l.LoanID AND ReasonID = 1) AS OverdueFine,
        -- Book Cost
        (SELECT ISNULL(SUM(FineAmount), 0.00) FROM Fines WHERE LoanID = l.LoanID AND ReasonID = 6 AND Remarks LIKE '%Book Cost%') AS BookCostCharge,
        -- Penalty
        (SELECT ISNULL(SUM(FineAmount), 0.00) FROM Fines WHERE LoanID = l.LoanID AND ReasonID = 6 AND Remarks LIKE '%Penalty%') AS PenaltyCharge,
        -- Total Charged
        (SELECT ISNULL(SUM(FineAmount), 0.00) FROM Fines WHERE LoanID = l.LoanID) AS TotalCharged
    FROM Loans l
    JOIN Members m ON l.MemberID = m.MemberID
    JOIN BookCopies cp ON l.CopyID = cp.CopyID
    JOIN Books b ON cp.BookID = b.BookID
    WHERE l.IsFinalCharged = 1
      AND NOT EXISTS (
          SELECT 1 FROM Fines f WHERE f.LoanID = l.LoanID AND f.IsPaid = 1
      )
    ORDER BY l.Reminder3SentDate DESC;
END;
GO
