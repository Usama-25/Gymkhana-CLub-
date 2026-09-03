USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Replace UQ_ActiveReservation with a filtered unique index supporting dependents
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UQ_ActiveReservation]') AND type = 'UQ')
BEGIN
    ALTER TABLE dbo.Reservations DROP CONSTRAINT UQ_ActiveReservation;
    PRINT 'Dropped UQ_ActiveReservation unique constraint.';
END
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'UQ_ActiveReservation' AND object_id = OBJECT_ID('dbo.Reservations'))
BEGIN
    ALTER TABLE dbo.Reservations DROP CONSTRAINT UQ_ActiveReservation;
    PRINT 'Dropped UQ_ActiveReservation unique constraint index.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_ActiveReservation_Actual' AND object_id = OBJECT_ID('dbo.Reservations'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_ActiveReservation_Actual
    ON dbo.Reservations (MemberID, BookID, ActualBorrowerNo)
    WHERE StatusID = 1;
    PRINT 'Created UX_ActiveReservation_Actual unique index.';
END
GO

-- 2. Update sp_ReserveBook to check overlapping dates per family member (matching ActualBorrowerNo)
CREATE OR ALTER PROCEDURE dbo.sp_ReserveBook
    @MemberID  INT,
    @BookID    INT,
    @StartDate DATE = NULL,
    @EndDate   DATE = NULL,
    @Msg       VARCHAR(200) OUTPUT,
    @ActualBorrowerNo   VARCHAR(50) = NULL,
    @ActualBorrowerName NVARCHAR(150) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Dynamic Sync member from MemberShip database if they don't exist locally
    EXEC dbo.sp_EnsureMemberExists @MemberID;

    -- Member active?
    IF NOT EXISTS (SELECT 1 FROM Members WHERE MemberID=@MemberID AND IsActive=1)
    BEGIN SET @Msg='ERR:MEMBER_INACTIVE'; RETURN; END

    DECLARE @Today DATE = CAST(GETDATE() AS DATE);
    SET @StartDate = COALESCE(@StartDate, @Today);
    
    DECLARE @ExpDays INT;
    SELECT @ExpDays=CAST(SVal AS INT) FROM Settings WHERE SKey='ResDays';
    SET @ExpDays = COALESCE(@ExpDays, 7);
    SET @EndDate = COALESCE(@EndDate, DATEADD(DAY, @ExpDays, @StartDate));

    -- Check if dates are valid
    IF @StartDate < @Today
    BEGIN SET @Msg='ERR:INVALID_START_DATE'; RETURN; END

    IF @EndDate < @StartDate
    BEGIN SET @Msg='ERR:INVALID_END_DATE'; RETURN; END

    -- Check overlap for same family member/borrower
    IF EXISTS (
        SELECT 1 
        FROM Reservations 
        WHERE MemberID=@MemberID 
          AND BookID=@BookID 
          AND StatusID=1 
          AND StartDate <= @EndDate 
          AND EndDate >= @StartDate
          AND ISNULL(ActualBorrowerNo, '') = ISNULL(@ActualBorrowerNo, '')
    )
    BEGIN SET @Msg='ERR:ALREADY_RESERVED'; RETURN; END

    -- Check available physical copies and notified reservations to set initial NotifiedAt state
    DECLARE @AvailableCopies INT, @HeldCopies INT, @NotifiedAt DATETIME2(0) = NULL;
    
    SELECT @AvailableCopies = COUNT(*)
    FROM dbo.BookCopies
    WHERE BookID = @BookID AND IsAvailable = 1 AND CondID NOT IN (5,6);
    
    SELECT @HeldCopies = COUNT(*)
    FROM dbo.Reservations
    WHERE BookID = @BookID AND StatusID = 1 AND NotifiedAt IS NOT NULL;
    
    IF @AvailableCopies > @HeldCopies
    BEGIN
        SET @NotifiedAt = SYSDATETIME();
    END

    -- Join at the end of the active queue
    DECLARE @Queue INT;
    SELECT @Queue = ISNULL(MAX(QueuePos), 0) + 1 
    FROM dbo.Reservations 
    WHERE BookID = @BookID AND StatusID = 1;

    -- Insert reservation
    INSERT INTO Reservations (MemberID, BookID, ExpiresOn, StatusID, QueuePos, StartDate, EndDate, NotifiedAt, ActualBorrowerNo, ActualBorrowerName)
    VALUES (@MemberID, @BookID, @EndDate, 1, @Queue, @StartDate, @EndDate, @NotifiedAt, @ActualBorrowerNo, @ActualBorrowerName);

    SET @Msg='OK';
END;
GO

-- 3. Update sp_Report_MemberWise to return actual borrower details
CREATE OR ALTER PROCEDURE dbo.sp_Report_MemberWise
    @MemberID   INT = NULL      -- NULL = all members summary
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @MemberID IS NOT NULL
    BEGIN
        -- Detail: all loans for a specific member showing actual borrowing dependent
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
            ISNULL(f.FineAmount, 0) AS FineAmount,
            ISNULL(f.IsPaid, 1)     AS FinePaid
        FROM Loans l
        JOIN Members m         ON l.MemberID = m.MemberID
        JOIN BookCopies cp     ON l.CopyID   = cp.CopyID
        JOIN Books b           ON cp.BookID  = b.BookID
        JOIN TxnStatuses ts    ON l.StatusID = ts.StatusID
        LEFT JOIN Fines f      ON f.LoanID   = l.LoanID
        WHERE l.MemberID = @MemberID
        ORDER BY l.IssueDate DESC;
    END
    ELSE
    BEGIN
        -- Summary: all members with their borrowing stats (stays aggregated at primary account level)
        SELECT
            m.MemberID,
            m.MembershipNo,
            m.FullName              AS MemberName,
            m.Phone,
            mt.TypeName             AS MemberType,
            COUNT(l.LoanID)         AS TotalLoans,
            SUM(CASE WHEN l.StatusID IN (1,3,4) THEN 1 ELSE 0 END) AS ActiveLoans,
            SUM(CASE WHEN l.StatusID = 3 THEN 1 ELSE 0 END)        AS OverdueLoans,
            ISNULL((SELECT SUM(f2.FineAmount) FROM Fines f2 WHERE f2.MemberID = m.MemberID AND f2.IsPaid = 0), 0) AS UnpaidFines
        FROM Members m
        JOIN MemberTypes mt    ON m.MTypeID = mt.MTypeID
        LEFT JOIN Loans l      ON l.MemberID = m.MemberID
        WHERE m.IsActive = 1
        GROUP BY m.MemberID, m.MembershipNo, m.FullName, m.Phone, mt.TypeName
        HAVING COUNT(l.LoanID) > 0
        ORDER BY m.FullName;
    END
END;
GO

-- 4. Update sp_GetMemberLedger to display borrowing dependent name/no in descriptions
CREATE OR ALTER PROCEDURE dbo.sp_GetMemberLedger
    @MemberID   INT,
    @StartDate  DATE = NULL,
    @EndDate    DATE = NULL,
    @Month      INT = NULL,
    @Year       INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    WITH LedgerCTE AS (
        -- Book Loans
        SELECT 
            CAST(l.IssueDate AS DATE) AS TxnDate,
            'Book Loan' AS TxnType,
            'Borrowed: ' + b.Title + COALESCE(' (by ' + l.ActualBorrowerName + ' - ' + l.ActualBorrowerNo + ')', '') AS Description,
            cp.Barcode AS Reference,
            0.00 AS Amount,
            CASE 
                WHEN l.StatusID = 2 THEN 'Returned'
                WHEN l.StatusID = 3 THEN 'Overdue'
                ELSE 'Issued'
            END AS Status,
            CAST(l.ReturnDate AS DATE) AS ActionDate
        FROM Loans l
        JOIN BookCopies cp ON l.CopyID = cp.CopyID
        JOIN Books b ON cp.BookID = b.BookID
        WHERE l.MemberID = @MemberID

        UNION ALL

        -- Fines
        SELECT 
            CAST(f.CreatedAt AS DATE) AS TxnDate,
            'Library Fine' AS TxnType,
            fr.ReasonName + COALESCE(' (for ' + l.ActualBorrowerName + ' - ' + l.ActualBorrowerNo + ')', '') AS Description,
            'Fine #' + CAST(f.FineID AS VARCHAR) AS Reference,
            f.FineAmount AS Amount,
            CASE WHEN f.IsPaid = 1 THEN 'Paid' ELSE 'Unpaid' END AS Status,
            CAST(f.PaidAt AS DATE) AS ActionDate
        FROM Fines f
        JOIN FineReasons fr ON f.ReasonID = fr.ReasonID
        LEFT JOIN Loans l ON f.LoanID = l.LoanID
        WHERE f.MemberID = @MemberID

        UNION ALL

        -- Facility Bookings
        SELECT 
            fb.UsageDate AS TxnDate,
            'Facility Booking' AS TxnType,
            'Used: ' + fac.FacilityName + ' (' + CAST(CAST(fb.HoursUsed AS DECIMAL(5,1)) AS VARCHAR) + ' hrs)' AS Description,
            'Booking #' + CAST(fb.BookingID AS VARCHAR) AS Reference,
            fb.TotalCharges AS Amount,
            CASE WHEN fb.IsPaid = 1 THEN 'Paid' ELSE 'Unpaid' END AS Status,
            CAST(fb.PaidAt AS DATE) AS ActionDate
        FROM FacilityBookings fb
        JOIN Facilities fac ON fb.FacilityID = fac.FacilityID
        WHERE fb.MemberID = @MemberID
    )
    SELECT *
    FROM LedgerCTE
    WHERE (@StartDate IS NULL OR TxnDate >= @StartDate)
      AND (@EndDate IS NULL OR TxnDate <= @EndDate)
      AND (@Month IS NULL OR @Month = 0 OR MONTH(TxnDate) = @Month)
      AND (@Year IS NULL OR @Year = 0 OR YEAR(TxnDate) = @Year)
    ORDER BY TxnDate DESC, TxnType;
END;
GO

-- 5. Create new stored procedure sp_Report_Reservations to generate reservations report
CREATE OR ALTER PROCEDURE dbo.sp_Report_Reservations
    @FromDate DATE = NULL,
    @ToDate   DATE = NULL,
    @StatusID TINYINT = NULL -- NULL = All
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Default: current month
    IF @FromDate IS NULL SET @FromDate = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
    IF @ToDate   IS NULL SET @ToDate   = CAST(GETDATE() AS DATE);

    SELECT 
        r.ResID,
        COALESCE(r.ActualBorrowerNo, m.MembershipNo) AS MembershipNo,
        COALESCE(r.ActualBorrowerName, m.FullName)   AS MemberName,
        m.Phone,
        b.ISBN13,
        dbo.fn_ISBN13Fmt(b.ISBN13) AS ISBN13Fmt,
        b.Title AS BookTitle,
        r.ReservedAt,
        r.StartDate,
        r.EndDate,
        r.ExpiresOn,
        rs.StatusName AS Status,
        r.QueuePos
    FROM dbo.Reservations r
    JOIN dbo.Members m ON r.MemberID = m.MemberID
    JOIN dbo.Books b ON r.BookID = b.BookID
    JOIN dbo.ResStatuses rs ON r.StatusID = rs.StatusID
    WHERE CAST(r.ReservedAt AS DATE) BETWEEN @FromDate AND @ToDate
      AND (@StatusID IS NULL OR r.StatusID = @StatusID)
    ORDER BY r.ReservedAt DESC;
END;
GO

PRINT '=== Reservations and Reporting updates executed successfully ===';
GO
