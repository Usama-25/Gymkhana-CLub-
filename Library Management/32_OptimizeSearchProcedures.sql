USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Create indexes to speed up filtering on Books table
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Books_LangID' AND object_id = OBJECT_ID('dbo.Books'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Books_LangID ON dbo.Books (LangID);
    PRINT 'Index IX_Books_LangID created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Books_PublishYear' AND object_id = OBJECT_ID('dbo.Books'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Books_PublishYear ON dbo.Books (PublishYear);
    PRINT 'Index IX_Books_PublishYear created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Books_DDC' AND object_id = OBJECT_ID('dbo.Books'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Books_DDC ON dbo.Books (DDC) WHERE DDC IS NOT NULL;
    PRINT 'Index IX_Books_DDC created.';
END
GO


-- 2. Optimize sp_SearchBooks Stored Procedure
PRINT 'Updating dbo.sp_SearchBooks...';
GO
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
    @PageSize   INT           = NULL,
    @DDC        VARCHAR(50)   = NULL,
    @BookNo     INT           = NULL
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
            v.IsReference, v.IsAdults, v.IsChildren, v.BookNo,
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
          AND (@DDC      IS NULL OR v.DDC LIKE '%' + @DDC + '%')
          AND (@BookNo   IS NULL OR EXISTS (
                  SELECT 1 FROM BookCopies cp WHERE cp.BookID=v.BookID AND cp.BookNo=@BookNo))
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
        ORDER BY v.Title
        OPTION (RECOMPILE);
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
              AND (@DDC      IS NULL OR b.DDC LIKE '%' + @DDC + '%')
              AND (@BookNo   IS NULL OR EXISTS (
                  SELECT 1 FROM BookCopies cp WHERE cp.BookID = b.BookID AND cp.BookNo = @BookNo
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
            v.IsReference, v.IsAdults, v.IsChildren, v.BookNo,
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
        ORDER BY v.Title
        OPTION (RECOMPILE);
    END
END;
GO


-- 3. Optimize & Fix sp_SearchBooksAdvanced Stored Procedure (adding DDC support)
PRINT 'Updating dbo.sp_SearchBooksAdvanced...';
GO
CREATE OR ALTER PROCEDURE dbo.sp_SearchBooksAdvanced
    @Term       NVARCHAR(200) = NULL,   -- Global Google-like keyword
    @Author     NVARCHAR(100) = NULL,   -- Specific Author
    @BookName   NVARCHAR(200) = NULL,   -- Specific Title
    @Edition    NVARCHAR(50)  = NULL,   -- Specific Edition
    @PubID      SMALLINT      = NULL,   -- Specific Publisher
    @CatID      SMALLINT      = NULL,   -- Specific Category
    @LangID     TINYINT       = NULL,   -- Specific Language
    @Year       SMALLINT      = NULL,   -- Specific Year
    @DDC        NVARCHAR(100) = NULL,   -- Specific DDC
    @BookNo     INT           = NULL    -- Specific BookNo
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Parse keywords from @Term
    DECLARE @Keywords TABLE (Keyword VARCHAR(100) NOT NULL);
    IF @Term IS NOT NULL
    BEGIN
        INSERT INTO @Keywords (Keyword)
        SELECT DISTINCT TRIM(value)
        FROM STRING_SPLIT(REPLACE(REPLACE(@Term, '+', ' '), ',', ' '), ' ')
        WHERE TRIM(value) <> '';
    END

    -- 2. Build initial candidate list
    CREATE TABLE #MatchedIDs (BookID INT PRIMARY KEY);

    DECLARE @FirstKeyword NVARCHAR(100) = NULL;
    SELECT TOP 1 @FirstKeyword = Keyword FROM @Keywords;

    IF @FirstKeyword IS NOT NULL
    BEGIN
        -- If there's a search term, populate temp table with books matching the first keyword & other criteria
        INSERT INTO #MatchedIDs (BookID)
        SELECT b.BookID
        FROM dbo.Books b
        WHERE b.IsActive = 1
          AND (@CatID IS NULL OR b.CatID = @CatID)
          AND (@LangID IS NULL OR b.LangID = @LangID)
          AND (@PubID IS NULL OR b.PubID = @PubID)
          AND (@Year IS NULL OR b.PublishYear = @Year)
          AND (@DDC IS NULL OR b.DDC LIKE '%' + @DDC + '%')
          AND (@Edition IS NULL OR b.Edition LIKE '%' + @Edition + '%')
          AND (@BookName IS NULL OR b.Title LIKE '%' + @BookName + '%')
          AND (@Author IS NULL OR EXISTS (
              SELECT 1 FROM BookAuthors ba
              JOIN Authors a ON ba.AuthorID = a.AuthorID
              WHERE ba.BookID = b.BookID AND a.FullName LIKE '%' + @Author + '%'
          ))
          AND (@BookNo IS NULL OR EXISTS (
              SELECT 1 FROM BookCopies cp
              WHERE cp.BookID = b.BookID AND cp.BookNo = @BookNo
          ))
          -- Match first keyword
          AND (
              b.Title LIKE '%' + @FirstKeyword + '%'
              OR COALESCE(b.SubTitle, '') LIKE '%' + @FirstKeyword + '%'
              OR b.ISBN13 LIKE '%' + @FirstKeyword + '%'
              OR REPLACE(REPLACE(b.ISBN13, '-', ''), ' ', '') LIKE '%' + REPLACE(REPLACE(@FirstKeyword, '-', ''), ' ', '') + '%'
              OR COALESCE(b.CoverFile, '') LIKE '%' + @FirstKeyword + '%'
              OR COALESCE(b.Tags, '') LIKE '%' + @FirstKeyword + '%'
              OR COALESCE(b.DDC, '') LIKE '%' + @FirstKeyword + '%'
              OR EXISTS (
                  SELECT 1 FROM BookAuthors ba
                  JOIN Authors a ON ba.AuthorID = a.AuthorID
                  WHERE ba.BookID = b.BookID AND a.FullName LIKE '%' + @FirstKeyword + '%'
              )
          )
        OPTION (RECOMPILE);
    END
    ELSE
    BEGIN
        -- No search term, just insert all active books matching the other criteria
        INSERT INTO #MatchedIDs (BookID)
        SELECT b.BookID
        FROM dbo.Books b
        WHERE b.IsActive = 1
          AND (@CatID IS NULL OR b.CatID = @CatID)
          AND (@LangID IS NULL OR b.LangID = @LangID)
          AND (@PubID IS NULL OR b.PubID = @PubID)
          AND (@Year IS NULL OR b.PublishYear = @Year)
          AND (@DDC IS NULL OR b.DDC LIKE '%' + @DDC + '%')
          AND (@Edition IS NULL OR b.Edition LIKE '%' + @Edition + '%')
          AND (@BookName IS NULL OR b.Title LIKE '%' + @BookName + '%')
          AND (@Author IS NULL OR EXISTS (
              SELECT 1 FROM BookAuthors ba
              JOIN Authors a ON ba.AuthorID = a.AuthorID
              WHERE ba.BookID = b.BookID AND a.FullName LIKE '%' + @Author + '%'
          ))
          AND (@BookNo IS NULL OR EXISTS (
              SELECT 1 FROM BookCopies cp
              WHERE cp.BookID = b.BookID AND cp.BookNo = @BookNo
          ))
        OPTION (RECOMPILE);
    END

    -- 3. Filter by subsequent keywords sequentially
    DECLARE @kw NVARCHAR(100);
    DECLARE kw_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT Keyword FROM @Keywords WHERE Keyword <> @FirstKeyword;

    OPEN kw_cursor;
    FETCH NEXT FROM kw_cursor INTO @kw;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DELETE m
        FROM #MatchedIDs m
        WHERE NOT EXISTS (
            SELECT 1
            FROM dbo.Books b
            WHERE b.BookID = m.BookID
              AND (
                  b.Title LIKE '%' + @kw + '%'
                  OR b.SubTitle LIKE '%' + @kw + '%'
                  OR b.ISBN13 LIKE '%' + @kw + '%'
                  OR REPLACE(REPLACE(b.ISBN13, '-', ''), ' ', '') LIKE '%' + REPLACE(REPLACE(@kw, '-', ''), ' ', '') + '%'
                  OR b.CoverFile LIKE '%' + @kw + '%'
                  OR b.Tags LIKE '%' + @kw + '%'
                  OR b.DDC LIKE '%' + @kw + '%'
                  OR EXISTS (
                      SELECT 1 FROM BookAuthors ba
                      JOIN Authors a ON ba.AuthorID = a.AuthorID
                      WHERE ba.BookID = b.BookID AND a.FullName LIKE '%' + @kw + '%'
                  )
              )
        )
        OPTION (RECOMPILE);

        FETCH NEXT FROM kw_cursor INTO @kw;
    END

    CLOSE kw_cursor;
    DEALLOCATE kw_cursor;

    -- 4. Select the final details from vw_Books for matched IDs only
    SELECT
        v.BookID, v.ISBN13, v.ISBN13Fmt, v.Title, v.SubTitle,
        v.Edition, v.PublishYear, v.CatName, v.PubName, v.LangName,
        v.CoverFile, v.TotalCopies, v.AvailableCopies, v.ClassNo, v.DDC,
        v.IsReference, v.IsAdults, v.IsChildren, v.BookNo,
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
         ORDER  BY cp.CopyID)                               AS PrimaryLocation
    FROM vw_Books v
    JOIN #MatchedIDs m ON v.BookID = m.BookID
    ORDER BY v.Title
    OPTION (RECOMPILE);

    DROP TABLE #MatchedIDs;
END;
GO
