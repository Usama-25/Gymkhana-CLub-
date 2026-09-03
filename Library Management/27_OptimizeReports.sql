USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Create missing indexes to speed up reports
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Loans_IssueDate' AND object_id = OBJECT_ID('dbo.Loans'))
BEGIN
    CREATE INDEX IX_Loans_IssueDate ON dbo.Loans (IssueDate) INCLUDE (MemberID, CopyID, DueDate, StatusID, IssuedByID);
    PRINT 'Created index IX_Loans_IssueDate.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Fines_CreatedAt' AND object_id = OBJECT_ID('dbo.Fines'))
BEGIN
    CREATE INDEX IX_Fines_CreatedAt ON dbo.Fines (CreatedAt) INCLUDE (LoanID, MemberID, ReasonID, FineAmount, IsPaid);
    PRINT 'Created index IX_Fines_CreatedAt.';
END
GO

-- 2. Optimize sp_Report_AuthorWise
CREATE OR ALTER PROCEDURE dbo.sp_Report_AuthorWise
    @AuthorID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Precompute copies counts to avoid correlated subqueries
    WITH CopyCounts AS (
        SELECT 
            BookID,
            COUNT(*) AS TotalCopies,
            SUM(CASE WHEN IsAvailable = 1 AND CondID NOT IN (5,6) THEN 1 ELSE 0 END) AS AvailableCopies
        FROM BookCopies
        GROUP BY BookID
    )
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
        ISNULL(cc.TotalCopies, 0) AS TotalCopies,
        ISNULL(cc.AvailableCopies, 0) AS AvailableCopies
    FROM Authors a
    JOIN BookAuthors ba    ON a.AuthorID = ba.AuthorID
    JOIN AuthorRoles ar    ON ba.RoleID  = ar.RoleID
    JOIN Books b           ON ba.BookID  = b.BookID
    JOIN Categories c      ON b.CatID   = c.CatID
    JOIN Languages l       ON b.LangID  = l.LangID
    LEFT JOIN Publishers p ON b.PubID   = p.PubID
    LEFT JOIN CopyCounts cc ON b.BookID = cc.BookID
    WHERE b.IsActive = 1 AND a.IsActive = 1
      AND (@AuthorID IS NULL OR a.AuthorID = @AuthorID)
    ORDER BY a.FullName, b.Title;
END;
GO

-- 3. Optimize sp_Report_PublisherWise
CREATE OR ALTER PROCEDURE dbo.sp_Report_PublisherWise
    @PubID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Precompute copies counts
    WITH CopyCounts AS (
        SELECT 
            BookID,
            COUNT(*) AS TotalCopies,
            SUM(CASE WHEN IsAvailable = 1 AND CondID NOT IN (5,6) THEN 1 ELSE 0 END) AS AvailableCopies
        FROM BookCopies
        GROUP BY BookID
    ),
    -- Precompute author strings
    AuthorStrings AS (
        SELECT 
            ba.BookID,
            STRING_AGG(a.FullName, ', ') WITHIN GROUP (ORDER BY ba.SortOrder) AS Authors
        FROM BookAuthors ba 
        JOIN Authors a ON ba.AuthorID = a.AuthorID
        GROUP BY ba.BookID
    )
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
        ISNULL(ast.Authors, '-') AS Authors,
        ISNULL(cc.TotalCopies, 0) AS TotalCopies,
        ISNULL(cc.AvailableCopies, 0) AS AvailableCopies
    FROM Books b
    JOIN Categories c      ON b.CatID   = c.CatID
    JOIN Languages l       ON b.LangID  = l.LangID
    LEFT JOIN Publishers p ON b.PubID   = p.PubID
    LEFT JOIN CopyCounts cc ON b.BookID = cc.BookID
    LEFT JOIN AuthorStrings ast ON b.BookID = ast.BookID
    WHERE b.IsActive = 1
      AND (@PubID IS NULL OR p.PubID = @PubID)
    ORDER BY ISNULL(p.PubName, 'ZZZ'), b.Title;
END;
GO

-- 4. Optimize sp_Report_EditionWise
CREATE OR ALTER PROCEDURE dbo.sp_Report_EditionWise
AS
BEGIN
    SET NOCOUNT ON;

    WITH CopyCounts AS (
        SELECT 
            BookID,
            COUNT(*) AS TotalCopies,
            SUM(CASE WHEN IsAvailable = 1 AND CondID NOT IN (5,6) THEN 1 ELSE 0 END) AS AvailableCopies
        FROM BookCopies
        GROUP BY BookID
    ),
    AuthorStrings AS (
        SELECT 
            ba.BookID,
            STRING_AGG(a.FullName, ', ') WITHIN GROUP (ORDER BY ba.SortOrder) AS Authors
        FROM BookAuthors ba 
        JOIN Authors a ON ba.AuthorID = a.AuthorID
        GROUP BY ba.BookID
    )
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
        ISNULL(ast.Authors, '-') AS Authors,
        ISNULL(cc.TotalCopies, 0) AS TotalCopies,
        ISNULL(cc.AvailableCopies, 0) AS AvailableCopies
    FROM Books b
    JOIN Categories c      ON b.CatID   = c.CatID
    JOIN Languages l       ON b.LangID  = l.LangID
    LEFT JOIN Publishers p ON b.PubID   = p.PubID
    LEFT JOIN CopyCounts cc ON b.BookID = cc.BookID
    LEFT JOIN AuthorStrings ast ON b.BookID = ast.BookID
    WHERE b.IsActive = 1
    ORDER BY ISNULL(b.Edition, 'ZZZ'), b.Title;
END;
GO

-- 5. Optimize sp_Report_LanguageWise
CREATE OR ALTER PROCEDURE dbo.sp_Report_LanguageWise
    @LangID TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    WITH CopyCounts AS (
        SELECT 
            BookID,
            COUNT(*) AS TotalCopies,
            SUM(CASE WHEN IsAvailable = 1 AND CondID NOT IN (5,6) THEN 1 ELSE 0 END) AS AvailableCopies
        FROM BookCopies
        GROUP BY BookID
    ),
    AuthorStrings AS (
        SELECT 
            ba.BookID,
            STRING_AGG(a.FullName, ', ') WITHIN GROUP (ORDER BY ba.SortOrder) AS Authors
        FROM BookAuthors ba 
        JOIN Authors a ON ba.AuthorID = a.AuthorID
        GROUP BY ba.BookID
    )
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
        ISNULL(ast.Authors, '-') AS Authors,
        ISNULL(cc.TotalCopies, 0) AS TotalCopies,
        ISNULL(cc.AvailableCopies, 0) AS AvailableCopies
    FROM Books b
    JOIN Categories c      ON b.CatID   = c.CatID
    JOIN Languages l       ON b.LangID  = l.LangID
    LEFT JOIN Publishers p ON b.PubID   = p.PubID
    LEFT JOIN CopyCounts cc ON b.BookID = cc.BookID
    LEFT JOIN AuthorStrings ast ON b.BookID = ast.BookID
    WHERE b.IsActive = 1
      AND (@LangID IS NULL OR l.LangID = @LangID)
    ORDER BY l.LangName, b.Title;
END;
GO

-- 6. Optimize sp_Report_Books
CREATE OR ALTER PROCEDURE dbo.sp_Report_Books
AS
BEGIN
    SET NOCOUNT ON;

    WITH CopyCounts AS (
        SELECT 
            BookID,
            COUNT(*) AS TotalCopies,
            SUM(CASE WHEN IsAvailable = 1 AND CondID NOT IN (5,6) THEN 1 ELSE 0 END) AS AvailableCopies
        FROM BookCopies
        GROUP BY BookID
    ),
    AuthorStrings AS (
        SELECT 
            ba.BookID,
            STRING_AGG(a.FullName, ', ') WITHIN GROUP (ORDER BY ba.SortOrder) AS Authors
        FROM BookAuthors ba 
        JOIN Authors a ON ba.AuthorID = a.AuthorID
        GROUP BY ba.BookID
    ),
    LoanCounts AS (
        SELECT 
            cp.BookID,
            COUNT(*) AS TotalTimesIssued
        FROM Loans ln
        JOIN BookCopies cp ON ln.CopyID = cp.CopyID
        GROUP BY cp.BookID
    )
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
        ISNULL(ast.Authors, '-') AS Authors,
        ISNULL(cc.TotalCopies, 0) AS TotalCopies,
        ISNULL(cc.AvailableCopies, 0) AS AvailableCopies,
        ISNULL(lc.TotalTimesIssued, 0) AS TotalTimesIssued,
        b.AddedOn
    FROM Books b
    JOIN Categories c      ON b.CatID   = c.CatID
    JOIN Languages l       ON b.LangID  = l.LangID
    LEFT JOIN Publishers p ON b.PubID   = p.PubID
    LEFT JOIN CopyCounts cc ON b.BookID = cc.BookID
    LEFT JOIN AuthorStrings ast ON b.BookID = ast.BookID
    LEFT JOIN LoanCounts lc ON b.BookID = lc.BookID
    WHERE b.IsActive = 1
    ORDER BY b.Title;
END;
GO

PRINT '=== Report Stored Procedures Optimization Completed ===';
GO
