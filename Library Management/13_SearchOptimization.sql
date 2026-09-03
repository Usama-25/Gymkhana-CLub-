SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

USE GymkhanaLibraryDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_BookCopies_BookID_CondID' AND object_id = OBJECT_ID('dbo.BookCopies'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_BookCopies_BookID_CondID ON BookCopies (BookID) INCLUDE (IsAvailable, CondID, RackID);
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_SearchBooksAdvanced
    @Term       NVARCHAR(200) = NULL,   -- Global Google-like keyword
    @Author     NVARCHAR(100) = NULL,   -- Specific Author
    @BookName   NVARCHAR(200) = NULL,   -- Specific Title
    @Edition    NVARCHAR(50)  = NULL,   -- Specific Edition
    @PubID      SMALLINT      = NULL,   -- Specific Publisher
    @CatID      SMALLINT      = NULL,   -- Specific Category
    @LangID     TINYINT       = NULL,   -- Specific Language
    @Year       SMALLINT      = NULL    -- Specific Year
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
          AND (@Edition IS NULL OR b.Edition LIKE '%' + @Edition + '%')
          AND (@BookName IS NULL OR b.Title LIKE '%' + @BookName + '%')
          AND (@Author IS NULL OR EXISTS (
              SELECT 1 FROM BookAuthors ba
              JOIN Authors a ON ba.AuthorID = a.AuthorID
              WHERE ba.BookID = b.BookID AND a.FullName LIKE '%' + @Author + '%'
          ))
          -- Match first keyword
          AND (
              b.Title LIKE '%' + @FirstKeyword + '%'
              OR COALESCE(b.SubTitle, '') LIKE '%' + @FirstKeyword + '%'
              OR b.ISBN13 LIKE '%' + @FirstKeyword + '%'
              OR REPLACE(REPLACE(b.ISBN13, '-', ''), ' ', '') LIKE '%' + REPLACE(REPLACE(@FirstKeyword, '-', ''), ' ', '') + '%'
              OR COALESCE(b.CoverFile, '') LIKE '%' + @FirstKeyword + '%'
              OR COALESCE(b.Tags, '') LIKE '%' + @FirstKeyword + '%'
              OR EXISTS (
                  SELECT 1 FROM BookAuthors ba
                  JOIN Authors a ON ba.AuthorID = a.AuthorID
                  WHERE ba.BookID = b.BookID AND a.FullName LIKE '%' + @FirstKeyword + '%'
              )
          );
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
          AND (@Edition IS NULL OR b.Edition LIKE '%' + @Edition + '%')
          AND (@BookName IS NULL OR b.Title LIKE '%' + @BookName + '%')
          AND (@Author IS NULL OR EXISTS (
              SELECT 1 FROM BookAuthors ba
              JOIN Authors a ON ba.AuthorID = a.AuthorID
              WHERE ba.BookID = b.BookID AND a.FullName LIKE '%' + @Author + '%'
          ));
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
                  OR EXISTS (
                      SELECT 1 FROM BookAuthors ba
                      JOIN Authors a ON ba.AuthorID = a.AuthorID
                      WHERE ba.BookID = b.BookID AND a.FullName LIKE '%' + @kw + '%'
                  )
              )
        );

        FETCH NEXT FROM kw_cursor INTO @kw;
    END

    CLOSE kw_cursor;
    DEALLOCATE kw_cursor;

    -- 4. Select the final details from vw_Books for matched IDs only
    SELECT
        v.BookID, v.ISBN13, v.ISBN13Fmt, v.Title, v.SubTitle,
        v.Edition, v.PublishYear, v.CatName, v.PubName, v.LangName,
        v.CoverFile, v.TotalCopies, v.AvailableCopies, v.ClassNo,
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
    ORDER BY v.Title;

    DROP TABLE #MatchedIDs;
END;
GO
