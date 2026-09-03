-- =============================================================================
--  LAHORE GYMKHANA CLUB LIBRARY — REPORT STORED PROCEDURES
--  Run AFTER 02_Procedures.sql
-- =============================================================================
USE GymkhanaLibraryDB;
GO

-- =============================================================================
--  1. sp_Report_AuthorWise — Books grouped by Author
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_Report_AuthorWise
    @AuthorID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        a.AuthorID,
        a.FullName          AS AuthorName,
        a.Nationality,
        ar.RoleName         AS Role,
        b.BookID,
        b.ISBN13,
        dbo.fn_ISBN13Fmt(b.ISBN13) AS ISBN13Fmt,
        b.Title,
        b.Edition,
        b.PublishYear,
        c.CatName           AS Category,
        p.PubName           AS Publisher,
        l.LangName          AS Language,
        (SELECT COUNT(*) FROM BookCopies cp WHERE cp.BookID = b.BookID) AS TotalCopies,
        (SELECT COUNT(*) FROM BookCopies cp WHERE cp.BookID = b.BookID AND cp.IsAvailable = 1 AND cp.CondID NOT IN (5,6)) AS AvailableCopies
    FROM Authors a
    JOIN BookAuthors ba    ON a.AuthorID = ba.AuthorID
    JOIN AuthorRoles ar    ON ba.RoleID  = ar.RoleID
    JOIN Books b           ON ba.BookID  = b.BookID
    JOIN Categories c      ON b.CatID   = c.CatID
    JOIN Languages l       ON b.LangID  = l.LangID
    LEFT JOIN Publishers p ON b.PubID   = p.PubID
    WHERE b.IsActive = 1 AND a.IsActive = 1
      AND (@AuthorID IS NULL OR a.AuthorID = @AuthorID)
    ORDER BY a.FullName, b.Title;
END;
GO

-- =============================================================================
--  2. sp_Report_PublisherWise — Books grouped by Publisher
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_Report_PublisherWise
    @PubID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ISNULL(p.PubID, 0)    AS PubID,
        ISNULL(p.PubName, 'Unknown Publisher') AS PublisherName,
        ISNULL(p.Country, '-') AS Country,
        b.BookID,
        b.ISBN13,
        dbo.fn_ISBN13Fmt(b.ISBN13) AS ISBN13Fmt,
        b.Title,
        b.Edition,
        b.PublishYear,
        c.CatName              AS Category,
        l.LangName             AS Language,
        (SELECT STRING_AGG(a.FullName, ', ') WITHIN GROUP (ORDER BY ba.SortOrder)
         FROM BookAuthors ba JOIN Authors a ON ba.AuthorID = a.AuthorID
         WHERE ba.BookID = b.BookID) AS Authors,
        (SELECT COUNT(*) FROM BookCopies cp WHERE cp.BookID = b.BookID) AS TotalCopies,
        (SELECT COUNT(*) FROM BookCopies cp WHERE cp.BookID = b.BookID AND cp.IsAvailable = 1 AND cp.CondID NOT IN (5,6)) AS AvailableCopies
    FROM Books b
    JOIN Categories c      ON b.CatID   = c.CatID
    JOIN Languages l       ON b.LangID  = l.LangID
    LEFT JOIN Publishers p ON b.PubID   = p.PubID
    WHERE b.IsActive = 1
      AND (@PubID IS NULL OR p.PubID = @PubID)
    ORDER BY ISNULL(p.PubName, 'ZZZ'), b.Title;
END;
GO

-- =============================================================================
--  3. sp_Report_EditionWise — Books grouped by Edition
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_Report_EditionWise
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ISNULL(b.Edition, 'Not Specified') AS Edition,
        b.BookID,
        b.ISBN13,
        dbo.fn_ISBN13Fmt(b.ISBN13) AS ISBN13Fmt,
        b.Title,
        b.PublishYear,
        c.CatName              AS Category,
        ISNULL(p.PubName, '-') AS Publisher,
        l.LangName             AS Language,
        (SELECT STRING_AGG(a.FullName, ', ') WITHIN GROUP (ORDER BY ba.SortOrder)
         FROM BookAuthors ba JOIN Authors a ON ba.AuthorID = a.AuthorID
         WHERE ba.BookID = b.BookID) AS Authors,
        (SELECT COUNT(*) FROM BookCopies cp WHERE cp.BookID = b.BookID) AS TotalCopies,
        (SELECT COUNT(*) FROM BookCopies cp WHERE cp.BookID = b.BookID AND cp.IsAvailable = 1 AND cp.CondID NOT IN (5,6)) AS AvailableCopies
    FROM Books b
    JOIN Categories c      ON b.CatID   = c.CatID
    JOIN Languages l       ON b.LangID  = l.LangID
    LEFT JOIN Publishers p ON b.PubID   = p.PubID
    WHERE b.IsActive = 1
    ORDER BY ISNULL(b.Edition, 'ZZZ'), b.Title;
END;
GO

-- =============================================================================
--  4. sp_Report_LanguageWise — Books grouped by Language
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_Report_LanguageWise
    @LangID TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        l.LangID,
        l.LangCode,
        l.LangName             AS Language,
        b.BookID,
        b.ISBN13,
        dbo.fn_ISBN13Fmt(b.ISBN13) AS ISBN13Fmt,
        b.Title,
        b.Edition,
        b.PublishYear,
        c.CatName              AS Category,
        ISNULL(p.PubName, '-') AS Publisher,
        (SELECT STRING_AGG(a.FullName, ', ') WITHIN GROUP (ORDER BY ba.SortOrder)
         FROM BookAuthors ba JOIN Authors a ON ba.AuthorID = a.AuthorID
         WHERE ba.BookID = b.BookID) AS Authors,
        (SELECT COUNT(*) FROM BookCopies cp WHERE cp.BookID = b.BookID) AS TotalCopies,
        (SELECT COUNT(*) FROM BookCopies cp WHERE cp.BookID = b.BookID AND cp.IsAvailable = 1 AND cp.CondID NOT IN (5,6)) AS AvailableCopies
    FROM Books b
    JOIN Categories c      ON b.CatID   = c.CatID
    JOIN Languages l       ON b.LangID  = l.LangID
    LEFT JOIN Publishers p ON b.PubID   = p.PubID
    WHERE b.IsActive = 1
      AND (@LangID IS NULL OR l.LangID = @LangID)
    ORDER BY l.LangName, b.Title;
END;
GO

-- =============================================================================
--  5. sp_Report_BookIssuance — All issuances within date range
-- =============================================================================
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
        m.MembershipNo,
        m.FullName              AS MemberName,
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

-- =============================================================================
--  6. sp_Report_IssuedNotReturned — Currently issued, not yet returned
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_Report_IssuedNotReturned
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @FPD DECIMAL(8,2);
    SELECT @FPD = CAST(SVal AS DECIMAL(8,2)) FROM Settings WHERE SKey='FinePerDay';

    SELECT
        l.LoanID,
        m.MembershipNo,
        m.FullName              AS MemberName,
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

-- =============================================================================
--  7. sp_Report_Fines — Fine records with date filter
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_Report_Fines
    @FromDate   DATE = NULL,
    @ToDate     DATE = NULL,
    @PaidOnly   BIT  = NULL     -- NULL=All, 1=Paid, 0=Unpaid
AS
BEGIN
    SET NOCOUNT ON;

    -- Default: current month
    IF @FromDate IS NULL SET @FromDate = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
    IF @ToDate   IS NULL SET @ToDate   = CAST(GETDATE() AS DATE);

    SELECT
        f.FineID,
        m.MembershipNo,
        m.FullName              AS MemberName,
        m.Phone,
        b.Title,
        cp.Barcode,
        fr.ReasonName           AS FineReason,
        f.FineAmount,
        f.IsPaid,
        f.CreatedAt,
        f.PaidAt,
        l.IssueDate,
        l.DueDate,
        l.ReturnDate,
        ISNULL(sc.EFName, '') + ' ' + ISNULL(sc.ELName, '') AS CollectedBy
    FROM Fines f
    JOIN Loans l               ON f.LoanID     = l.LoanID
    JOIN Members m             ON f.MemberID   = m.MemberID
    JOIN BookCopies cp         ON l.CopyID     = cp.CopyID
    JOIN Books b               ON cp.BookID    = b.BookID
    JOIN FineReasons fr        ON f.ReasonID   = fr.ReasonID
    LEFT JOIN User_management.dbo.Employee sc  ON f.CollectedByID = sc.EmpID
    WHERE CAST(f.CreatedAt AS DATE) BETWEEN @FromDate AND @ToDate
      AND (@PaidOnly IS NULL OR f.IsPaid = @PaidOnly)
    ORDER BY f.CreatedAt DESC;
END;
GO

-- =============================================================================
--  8. sp_Report_MemberWise — Borrowing history per member
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_Report_MemberWise
    @MemberID   INT = NULL      -- NULL = all members summary
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @MemberID IS NOT NULL
    BEGIN
        -- Detail: all loans for a specific member
        SELECT
            l.LoanID,
            m.MembershipNo,
            m.FullName              AS MemberName,
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
        -- Summary: all members with their borrowing stats
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

-- =============================================================================
--  9. sp_Report_Books — Complete book catalogue report
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_Report_Books
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        b.BookID,
        b.ISBN13,
        dbo.fn_ISBN13Fmt(b.ISBN13) AS ISBN13Fmt,
        b.Title,
        b.SubTitle,
        b.Edition,
        b.PublishYear,
        b.PageCount,
        b.ClassNo,
        c.CatName              AS Category,
        ISNULL(p.PubName, '-') AS Publisher,
        l.LangName             AS Language,
        (SELECT STRING_AGG(a.FullName, ', ') WITHIN GROUP (ORDER BY ba.SortOrder)
         FROM BookAuthors ba JOIN Authors a ON ba.AuthorID = a.AuthorID
         WHERE ba.BookID = b.BookID) AS Authors,
        (SELECT COUNT(*) FROM BookCopies cp WHERE cp.BookID = b.BookID) AS TotalCopies,
        (SELECT COUNT(*) FROM BookCopies cp WHERE cp.BookID = b.BookID AND cp.IsAvailable = 1 AND cp.CondID NOT IN (5,6)) AS AvailableCopies,
        (SELECT COUNT(*) FROM Loans ln JOIN BookCopies cp2 ON ln.CopyID = cp2.CopyID WHERE cp2.BookID = b.BookID) AS TotalTimesIssued,
        b.AddedOn
    FROM Books b
    JOIN Categories c      ON b.CatID   = c.CatID
    JOIN Languages l       ON b.LangID  = l.LangID
    LEFT JOIN Publishers p ON b.PubID   = p.PubID
    WHERE b.IsActive = 1
    ORDER BY b.Title;
END;
GO

PRINT '=== Report stored procedures created successfully ===';
GO
