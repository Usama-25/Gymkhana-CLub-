-- =============================================================================
--  LAHORE GYMKHANA CLUB LIBRARY — MIGRATION: ADD DDC AND RENAME CATEGORIES VISUALLY
-- =============================================================================
USE GymkhanaLibraryDB;
GO

-- 1. Add DdcPrefix column to Categories table if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Categories') AND name = 'DdcPrefix')
BEGIN
    ALTER TABLE Categories ADD DdcPrefix VARCHAR(10) NULL;
END
GO

-- 2. Add DDC column to Books table if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Books') AND name = 'DDC')
BEGIN
    ALTER TABLE Books ADD DDC VARCHAR(50) NULL;
END
GO

-- 3. Update vw_Books view to include the DDC and DdcPrefix fields
CREATE OR ALTER VIEW dbo.vw_Books WITH SCHEMABINDING AS
SELECT
    b.BookID,
    b.ISBN13,
    dbo.fn_ISBN13Fmt(b.ISBN13)  AS ISBN13Fmt,
    b.ISBN10,
    b.Title,
    b.SubTitle,
    b.Edition,
    b.PublishYear,
    b.ClassNo,
    b.CoverFile,
    b.IsActive,
    b.DDC,
    c.CatCode,
    c.CatName,
    c.DdcPrefix,
    p.PubName,
    l.LangName,
    -- Live copy counts
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

-- 4. Update sp_SaveBook stored procedure to support saving DDC field
CREATE OR ALTER PROCEDURE dbo.sp_SaveBook
    @BookID     INT           = NULL,   -- NULL = new record
    @ISBN13     VARCHAR(50),
    @ISBN10     CHAR(10)      = NULL,
    @Title      NVARCHAR(250),
    @SubTitle   NVARCHAR(150) = NULL,
    @CatID      SMALLINT,
    @PubID      SMALLINT      = NULL,
    @LangID     TINYINT       = 1,
    @PubYear    SMALLINT      = NULL,
    @Edition    VARCHAR(30)   = NULL,
    @PageCount  SMALLINT      = NULL,
    @ClassNo    VARCHAR(30)   = NULL,
    @Tags       VARCHAR(300)  = NULL,
    @Synopsis   NVARCHAR(MAX) = NULL,
    @CoverFile  VARCHAR(50)   = NULL,
    @StaffID    SMALLINT      = NULL,
    @DDC        VARCHAR(50)   = NULL,
    -- OUTPUT
    @NewBookID  INT           OUTPUT,
    @Msg        VARCHAR(200)  OUTPUT
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
             Edition,PageCount,ClassNo,Tags,Synopsis,CoverFile,AddedByStaffID,DDC)
        VALUES
            (@ISBN13,@ISBN10,@Title,@SubTitle,@CatID,@PubID,@LangID,@PubYear,
             @Edition,@PageCount,@ClassNo,@Tags,@Synopsis,@CoverFile,@StaffID,@DDC);
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
            DDC        = @DDC
        WHERE BookID = @BookID;
        SET @NewBookID = @BookID;
        SET @Msg = 'OK:' + CAST(@BookID AS VARCHAR);
    END
END;
GO

-- 5. Update sp_GetBookDetail stored procedure to return the DDC column
CREATE OR ALTER PROCEDURE dbo.sp_GetBookDetail
    @BookID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- RS1: Book
    SELECT b.BookID, b.ISBN13, dbo.fn_ISBN13Fmt(b.ISBN13) AS ISBN13Fmt,
           b.ISBN10, b.Title, b.SubTitle, b.Edition, b.PublishYear,
           b.PageCount, b.ClassNo, b.Tags, b.Synopsis, b.CoverFile,
           c.CatName, c.DdcPrefix, p.PubName, l.LangName, b.DDC
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

-- 6. Update sp_SearchBooks stored procedure to enable searching by DDC and return it
CREATE OR ALTER PROCEDURE dbo.sp_SearchBooks
    @Term       NVARCHAR(200) = NULL,   -- title / author / ISBN / tag / DDC
    @CatID      SMALLINT      = NULL,
    @LangID     TINYINT       = NULL,
    @PubID      SMALLINT      = NULL,
    @YearFrom   SMALLINT      = NULL,
    @YearTo     SMALLINT      = NULL,
    @AvailOnly  BIT           = 0,
    @RackID     SMALLINT      = NULL,
    @PageNumber INT           = NULL,
    @PageSize   INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- Clean ISBN search term
    DECLARE @ISBNTerm CHAR(13) = NULL;
    IF @Term IS NOT NULL
    BEGIN
        DECLARE @cleaned VARCHAR(13) = REPLACE(REPLACE(@Term,'-',''),' ','');
        IF LEN(@cleaned) = 13 AND @cleaned NOT LIKE '%[^0-9]%'
            SET @ISBNTerm = @cleaned;
    END

    -- If pagination is NOT requested
    IF @PageNumber IS NULL OR @PageSize IS NULL
    BEGIN
        SELECT
            v.BookID, v.ISBN13, v.ISBN13Fmt, v.ISBN10, v.Title, v.SubTitle,
            v.Edition, v.PublishYear, v.CatName, v.PubName, v.LangName,
            v.CoverFile, v.TotalCopies, v.AvailableCopies, v.ClassNo, v.DDC,
            -- Authors concatenated for display
            (SELECT STRING_AGG(a.FullName + CASE WHEN ar.RoleID <> 1
                    THEN ' (' + ar.RoleName + ')' ELSE '' END, ', ')
                    WITHIN GROUP (ORDER BY ba.SortOrder)
             FROM   BookAuthors ba
             JOIN   Authors a  ON ba.AuthorID = a.AuthorID
             JOIN   AuthorRoles ar ON ba.RoleID = ar.RoleID
             WHERE  ba.BookID = v.BookID)                       AS Authors,
            -- First rack address
            (SELECT TOP 1 ro.FullAddress
             FROM   BookCopies cp
             JOIN   vw_RackOccupancy ro ON cp.RackID = ro.RackID
             WHERE  cp.BookID = v.BookID
             ORDER  BY cp.CopyID)                               AS PrimaryLocation,
            COUNT(*) OVER()                                     AS TotalRows
        FROM vw_Books v
        WHERE v.IsActive = 1
          AND (@CatID    IS NULL OR v.CatCode = (SELECT CatCode FROM Categories WHERE CatID = @CatID))
          AND (@LangID   IS NULL OR v.LangName = (SELECT LangName FROM Languages WHERE LangID = @LangID))
          AND (@PubID    IS NULL OR v.PubName  = (SELECT PubName  FROM Publishers  WHERE PubID  = @PubID))
          AND (@YearFrom IS NULL OR v.PublishYear >= @YearFrom)
          AND (@YearTo   IS NULL OR v.PublishYear <= @YearTo)
          AND (@AvailOnly= 0     OR v.AvailableCopies > 0)
          AND (@RackID   IS NULL OR EXISTS (
                  SELECT 1 FROM BookCopies cp WHERE cp.BookID=v.BookID AND cp.RackID=@RackID))
          AND (
                @Term IS NULL
                OR NOT EXISTS (
                    SELECT 1
                    FROM STRING_SPLIT(REPLACE(REPLACE(@Term, '+', ' '), ',', ' '), ' ') kw
                    WHERE TRIM(kw.value) <> ''
                      AND NOT (
                            REPLACE(v.Title, ' ', '') LIKE '%' + kw.value + '%'
                            OR REPLACE(COALESCE(v.SubTitle, ''), ' ', '') LIKE '%' + kw.value + '%'
                            OR REPLACE(REPLACE(v.ISBN13, ' ', ''), '-', '') LIKE '%' + REPLACE(REPLACE(kw.value, ' ', ''), '-', '') + '%'
                            OR REPLACE(COALESCE(v.CoverFile, ''), ' ', '') LIKE '%' + kw.value + '%'
                            OR REPLACE(COALESCE(v.DDC, ''), ' ', '') LIKE '%' + kw.value + '%'
                            OR EXISTS (
                                SELECT 1 FROM dbo.Books b
                                WHERE b.BookID = v.BookID
                                  AND REPLACE(COALESCE(b.Tags, ''), ' ', '') LIKE '%' + kw.value + '%'
                            )
                            OR EXISTS (
                                SELECT 1 FROM BookAuthors ba
                                JOIN Authors a ON ba.AuthorID = a.AuthorID
                                WHERE ba.BookID = v.BookID
                                  AND REPLACE(REPLACE(a.FullName, ' ', ''), ',', '') LIKE '%' + kw.value + '%'
                            )
                      )
                )
              )
        ORDER BY v.Title;
    END
    ELSE
    BEGIN
        -- High-performance database-level pagination
        WITH FilteredBookIDs AS (
            SELECT
                b.BookID,
                COUNT(*) OVER() AS TotalRows
            FROM Books b
            WHERE b.IsActive = 1
              AND (@CatID    IS NULL OR b.CatID = @CatID)
              AND (@LangID   IS NULL OR b.LangID = @LangID)
              AND (@PubID    IS NULL OR b.PubID = @PubID)
              AND (@YearFrom IS NULL OR b.PublishYear >= @YearFrom)
              AND (@YearTo   IS NULL OR b.PublishYear <= @YearTo)
              AND (@AvailOnly = 0 OR EXISTS (
                  SELECT 1 FROM dbo.BookCopies cp 
                  WHERE cp.BookID = b.BookID AND cp.IsAvailable = 1 AND cp.CondID NOT IN (5,6)
              ))
              AND (@RackID   IS NULL OR EXISTS (
                  SELECT 1 FROM BookCopies cp WHERE cp.BookID = b.BookID AND cp.RackID = @RackID
              ))
              AND (
                    @Term IS NULL
                    OR NOT EXISTS (
                        SELECT 1
                        FROM STRING_SPLIT(REPLACE(REPLACE(@Term, '+', ' '), ',', ' '), ' ') kw
                        WHERE TRIM(kw.value) <> ''
                          AND NOT (
                             REPLACE(b.Title, ' ', '') LIKE '%' + kw.value + '%'
                                OR REPLACE(COALESCE(b.SubTitle, ''), ' ', '') LIKE '%' + kw.value + '%'
                                OR REPLACE(REPLACE(b.ISBN13, ' ', ''), '-', '') LIKE '%' + REPLACE(REPLACE(kw.value, ' ', ''), '-', '') + '%'
                                OR REPLACE(COALESCE(b.DDC, ''), ' ', '') LIKE '%' + kw.value + '%'
                                OR EXISTS (
                                    SELECT 1 FROM BookAuthors ba
                                    JOIN Authors a ON ba.AuthorID = a.AuthorID
                                    WHERE ba.BookID = b.BookID
                                      AND REPLACE(REPLACE(a.FullName, ' ', ''), ',', '') LIKE '%' + kw.value + '%'
                                )
                                OR REPLACE(COALESCE(b.Tags, ''), ' ', '') LIKE '%' + kw.value + '%'
                          )
                    )
                  )
            ORDER BY b.Title
            OFFSET (@PageNumber - 1) * @PageSize ROWS
            FETCH NEXT @PageSize ROWS ONLY
        )
        SELECT
            f.TotalRows,
            v.BookID, v.ISBN13, v.ISBN13Fmt, v.ISBN10, v.Title, v.SubTitle,
            v.Edition, v.PublishYear, v.CatName, v.PubName, v.LangName,
            v.CoverFile, v.TotalCopies, v.AvailableCopies, v.ClassNo, v.DDC,
            -- Concatenate authors only for the 20 returned rows
            (SELECT STRING_AGG(a.FullName + CASE WHEN ar.RoleID <> 1
                    THEN ' (' + ar.RoleName + ')' ELSE '' END, ', ')
                    WITHIN GROUP (ORDER BY ba.SortOrder)
             FROM   BookAuthors ba
             JOIN   Authors a  ON ba.AuthorID = a.AuthorID
             JOIN   AuthorRoles ar ON ba.RoleID = ar.RoleID
             WHERE  ba.BookID = v.BookID)                       AS Authors,
            -- First rack address only for the 20 returned rows
            (SELECT TOP 1 ro.FullAddress
             FROM   BookCopies cp
             JOIN   vw_RackOccupancy ro ON cp.RackID = ro.RackID
             WHERE  cp.BookID = v.BookID
             ORDER  BY cp.CopyID)                               AS PrimaryLocation
        FROM FilteredBookIDs f
        JOIN vw_Books v ON f.BookID = v.BookID
        ORDER BY v.Title;
    END
END;
GO
