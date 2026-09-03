USE GymkhanaLibraryDB;
GO

-- Drop foreign keys referencing Staff table
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Books_Staff' AND parent_object_id = OBJECT_ID('Books'))
BEGIN
    ALTER TABLE Books DROP CONSTRAINT FK_Books_Staff;
    PRINT 'Dropped constraint FK_Books_Staff';
END
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Loans_IssuedBy' AND parent_object_id = OBJECT_ID('Loans'))
BEGIN
    ALTER TABLE Loans DROP CONSTRAINT FK_Loans_IssuedBy;
    PRINT 'Dropped constraint FK_Loans_IssuedBy';
END
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Loans_ReturnedBy' AND parent_object_id = OBJECT_ID('Loans'))
BEGIN
    ALTER TABLE Loans DROP CONSTRAINT FK_Loans_ReturnedBy;
    PRINT 'Dropped constraint FK_Loans_ReturnedBy';
END
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Fines_CollectedBy' AND parent_object_id = OBJECT_ID('Fines'))
BEGIN
    ALTER TABLE Fines DROP CONSTRAINT FK_Fines_CollectedBy;
    PRINT 'Dropped constraint FK_Fines_CollectedBy';
END
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name LIKE 'FK__LoanRemin__SentB%' AND parent_object_id = OBJECT_ID('LoanReminders'))
BEGIN
    DECLARE @RemConstraint NVARCHAR(128);
    SELECT @RemConstraint = name FROM sys.foreign_keys WHERE name LIKE 'FK__LoanRemin__SentB%' AND parent_object_id = OBJECT_ID('LoanReminders');
    EXEC('ALTER TABLE LoanReminders DROP CONSTRAINT ' + @RemConstraint);
    PRINT 'Dropped constraint ' + @RemConstraint;
END
GO

-- Drop foreign key from BookWeedingLog referencing Staff
DECLARE @ConstraintName NVARCHAR(128);
SELECT @ConstraintName = fk.name
FROM sys.foreign_keys fk
WHERE fk.parent_object_id = OBJECT_ID('BookWeedingLog')
  AND OBJECT_NAME(fk.referenced_object_id) = 'Staff';

IF @ConstraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE BookWeedingLog DROP CONSTRAINT ' + @ConstraintName);
    PRINT 'Dropped weeding log staff constraint: ' + @ConstraintName;
END
GO

-- Drop Staff table
IF OBJECT_ID('Staff', 'U') IS NOT NULL
BEGIN
    DROP TABLE Staff;
    PRINT 'Dropped table Staff';
END
GO

-- Recompile/Alter stored procedures using cross-database joins to User_management
PRINT 'Recompiling stored procedures...';
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

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

CREATE OR ALTER PROCEDURE dbo.sp_GetWeedLogReport
    @FromDate DATE = NULL,
    @ToDate DATE = NULL,
    @SearchTerm NVARCHAR(100) = NULL,
    @ActionType VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        wl.LogID,
        wl.CopyID,
        bc.Barcode,
        b.Title AS BookTitle,
        wl.ActionType,
        wl.Remarks,
        wl.ActionedAt,
        ISNULL(s.EFName, '') + ' ' + ISNULL(s.ELName, '') AS ActionedByStaff,
        c1.CondName AS OldCondition,
        c2.CondName AS NewCondition,
        -- Old Location
        ISNULL(h1.HallCode + '-' + su1.UnitCode + '-R' + CAST(r1.RackNo AS VARCHAR(3)) + ' [Slot ' + CAST(wl.OldSlotNo AS VARCHAR(3)) + ']', 'N/A') AS OldLocation,
        -- New Location
        ISNULL(h2.HallCode + '-' + su2.UnitCode + '-R' + CAST(r2.RackNo AS VARCHAR(3)) + ' [Slot ' + CAST(wl.NewSlotNo AS VARCHAR(3)) + ']', 'N/A') AS NewLocation
    FROM BookWeedingLog wl
    JOIN BookCopies bc ON wl.CopyID = bc.CopyID
    JOIN Books b ON bc.BookID = b.BookID
    LEFT JOIN User_management.dbo.Employee s ON wl.ActionedByID = s.EmpID
    LEFT JOIN CopyConditions c1 ON wl.OldCondID = c1.CondID
    LEFT JOIN CopyConditions c2 ON wl.NewCondID = c2.CondID
    -- Joins for Old Location
    LEFT JOIN Racks r1 ON wl.OldRackID = r1.RackID
    LEFT JOIN ShelfUnits su1 ON r1.UnitID = su1.UnitID
    LEFT JOIN Halls h1 ON su1.HallID = h1.HallID
    -- Joins for New Location
    LEFT JOIN Racks r2 ON wl.NewRackID = r2.RackID
    LEFT JOIN ShelfUnits su2 ON r2.UnitID = su2.UnitID
    LEFT JOIN Halls h2 ON su2.HallID = h2.HallID
    WHERE (@FromDate IS NULL OR CAST(wl.ActionedAt AS DATE) >= @FromDate)
      AND (@ToDate IS NULL OR CAST(wl.ActionedAt AS DATE) <= @ToDate)
      AND (@ActionType IS NULL OR wl.ActionType = @ActionType)
      AND (@SearchTerm IS NULL OR b.Title LIKE '%' + @SearchTerm + '%' OR bc.Barcode LIKE '%' + @SearchTerm + '%' OR (ISNULL(s.EFName, '') + ' ' + ISNULL(s.ELName, '')) LIKE '%' + @SearchTerm + '%' OR wl.Remarks LIKE '%' + @SearchTerm + '%')
    ORDER BY wl.ActionedAt DESC;
END;
GO

PRINT 'Migration and procedure recompilation completed successfully.';
GO
