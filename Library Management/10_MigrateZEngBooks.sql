-- =============================================================================
--  LAHORE GYMKHANA CLUB LIBRARY — LEGACY DATA MIGRATION
--  Merges Z_EngBooksData into normalized target tables
-- =============================================================================
USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;
BEGIN TRY
    PRINT 'Starting migration of Z_EngBooksData...';

    -- Reseed IDENTITY seeds to prevent overflow from failed runs
    DECLARE @MaxCatID INT = ISNULL((SELECT MAX(CatID) FROM Categories), 0);
    DBCC CHECKIDENT ('Categories', RESEED, @MaxCatID);

    DECLARE @MaxPubID INT = ISNULL((SELECT MAX(PubID) FROM Publishers), 0);
    DBCC CHECKIDENT ('Publishers', RESEED, @MaxPubID);

    DECLARE @MaxAuthorID INT = ISNULL((SELECT MAX(AuthorID) FROM Authors), 0);
    DBCC CHECKIDENT ('Authors', RESEED, @MaxAuthorID);

    -- -------------------------------------------------------------------------
    --  0. Alter Authors Table Schema (To support NULL FirstName)
    -- -------------------------------------------------------------------------
    PRINT 'Altering Authors schema...';
    IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Authors_FullName' AND object_id = OBJECT_ID('Authors'))
        DROP INDEX IX_Authors_FullName ON Authors;

    IF EXISTS (SELECT 1 FROM sys.columns WHERE name = 'FullName' AND object_id = OBJECT_ID('Authors'))
        ALTER TABLE Authors DROP COLUMN FullName;

    ALTER TABLE Authors ALTER COLUMN FirstName NVARCHAR(60) NULL;

    -- Re-create computed column FullName to handle NULL FirstName
    DECLARE @sql NVARCHAR(MAX) = 'ALTER TABLE Authors ADD FullName AS (ISNULL(LastName, '''') + CASE WHEN LastName IS NOT NULL AND FirstName IS NOT NULL THEN '', '' + FirstName ELSE '''' END) PERSISTED;';
    EXEC sp_executesql @sql;

    CREATE INDEX IX_Authors_FullName ON Authors (FullName);
    PRINT 'Authors schema altered successfully.';

    -- -------------------------------------------------------------------------
    --  1. Categories Migration
    -- -------------------------------------------------------------------------
    PRINT 'Migrating categories...';
    WITH RawCategories AS (
        SELECT DISTINCT
            LEFT(LTRIM(RTRIM(LEFT(code, CHARINDEX('-', code) - 1))), 8) AS CatCode
        FROM Z_EngBooksData
    )
    INSERT INTO Categories (CatCode, CatName)
    SELECT 
        rc.CatCode, 
        CASE rc.CatCode
            WHEN '823' THEN 'English Fiction (823)'
            WHEN '954' THEN 'History of South Asia (954)'
            WHEN '821' THEN 'English Poetry (821)'
            WHEN '940.3' THEN 'World War I (940.3)'
            WHEN '940.4' THEN 'World War I Operations (940.4)'
            WHEN '942' THEN 'English History (942)'
            WHEN '920' THEN 'Biographies (920)'
            WHEN '910.4' THEN 'Travel & Voyages (910.4)'
            WHEN '828' THEN 'English Misc Literature (828)'
            WHEN '940.53' THEN 'World War II (940.53)'
            WHEN '940.54' THEN 'World War II Operations (940.54)'
            WHEN '910' THEN 'Geography & Travel (910)'
            WHEN '822' THEN 'English Drama (822)'
            WHEN '796.358' THEN 'Cricket (796.358)'
            WHEN '843' THEN 'French Fiction (843)'
            WHEN '359' THEN 'Naval Forces & Warfare (359)'
            WHEN '954.91' THEN 'History of Pakistan (954.91)'
            WHEN '915.4' THEN 'Travel in South Asia (915.4)'
            WHEN '824' THEN 'English Essays (824)'
            ELSE 'Class ' + rc.CatCode
        END AS CatName
    FROM RawCategories rc
    WHERE NOT EXISTS (
        SELECT 1 FROM Categories c WHERE c.CatCode = rc.CatCode
    );
    PRINT 'Categories migrated successfully: ' + CAST(@@ROWCOUNT AS VARCHAR);

    -- -------------------------------------------------------------------------
    --  2. Publishers Migration
    -- -------------------------------------------------------------------------
    PRINT 'Migrating publishers...';
    INSERT INTO Publishers (PubName, Country)
    SELECT 
        LTRIM(RTRIM(publisher)) AS PubName,
        MAX(ISNULL(NULLIF(LTRIM(RTRIM(city)), ''), 'Unknown')) AS Country
    FROM Z_EngBooksData
    WHERE publisher IS NOT NULL AND LTRIM(RTRIM(publisher)) <> ''
      AND LTRIM(RTRIM(publisher)) NOT IN (SELECT PubName FROM Publishers)
    GROUP BY LTRIM(RTRIM(publisher));
    PRINT 'Publishers migrated successfully: ' + CAST(@@ROWCOUNT AS VARCHAR);

    -- -------------------------------------------------------------------------
    --  3. Authors Migration
    -- -------------------------------------------------------------------------
    PRINT 'Migrating authors...';
    WITH SplitAuthors AS (
        SELECT DISTINCT
            CASE 
                WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(author)))) > 0
                THEN LTRIM(RTRIM(SUBSTRING(LTRIM(RTRIM(author)), 1, LEN(LTRIM(RTRIM(author))) - CHARINDEX(' ', REVERSE(LTRIM(RTRIM(author)))))))
                ELSE NULL
            END AS FirstName,
            CASE 
                WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(author)))) > 0
                THEN LTRIM(RTRIM(SUBSTRING(LTRIM(RTRIM(author)), LEN(LTRIM(RTRIM(author))) - CHARINDEX(' ', REVERSE(LTRIM(RTRIM(author)))) + 2, CHARINDEX(' ', REVERSE(LTRIM(RTRIM(author)))))))
                ELSE ISNULL(NULLIF(LTRIM(RTRIM(author)), ''), 'Unknown')
            END AS LastName
        FROM Z_EngBooksData
    )
    INSERT INTO Authors (FirstName, LastName)
    SELECT FirstName, LastName
    FROM SplitAuthors sa
    WHERE NOT EXISTS (
        SELECT 1 
        FROM Authors a 
        WHERE (a.FirstName = sa.FirstName OR (a.FirstName IS NULL AND sa.FirstName IS NULL))
          AND a.LastName = sa.LastName
    );
    PRINT 'Authors migrated successfully: ' + CAST(@@ROWCOUNT AS VARCHAR);

    -- -------------------------------------------------------------------------
    --  4. Clean & Stage Distinct Books and Resolve Duplicate ISBNs
    -- -------------------------------------------------------------------------
    PRINT 'Staging and deduplicating books...';
    
    -- Drop temp tables if they exist
    IF OBJECT_ID('tempdb..#StagedBooks') IS NOT NULL
        DROP TABLE #StagedBooks;
    IF OBJECT_ID('tempdb..#BookCatalog') IS NOT NULL
        DROP TABLE #BookCatalog;

    -- Step A: Stage cleaned unique book records
    SELECT 
        MIN(book_no) AS MinBookNo,
        LTRIM(RTRIM(title)) AS RawTitle,
        LTRIM(RTRIM(author)) AS RawAuthor,
        LTRIM(RTRIM(publisher)) AS RawPublisher,
        TRY_CAST(y_pub AS SMALLINT) AS RawYear,
        REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(isbn_no)), '-', ''), ' ', ''), '/', ''), '''', '') AS CleanedISBN,
        LEFT(LTRIM(RTRIM(LEFT(code, CHARINDEX('-', code) - 1))), 8) AS CatCode,
        MAX(pages) AS MaxPages,
        MAX(NULLIF(LTRIM(RTRIM(stitle)), '')) AS RawSubTitle,
        MIN(ISNULL(TRY_CONVERT(DATE, li_dt, 111), TRY_CONVERT(DATE, pur_dt, 103))) AS MinAddedDate
    INTO #StagedBooks
    FROM Z_EngBooksData
    GROUP BY 
        LTRIM(RTRIM(title)), 
        LTRIM(RTRIM(author)), 
        LTRIM(RTRIM(publisher)), 
        TRY_CAST(y_pub AS SMALLINT),
        REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(isbn_no)), '-', ''), ' ', ''), '/', ''), '''', ''),
        LEFT(LTRIM(RTRIM(LEFT(code, CHARINDEX('-', code) - 1))), 8);

    -- Step B: Partition by CleanedISBN to resolve duplicates
    WITH RankedBooks AS (
        SELECT 
            MinBookNo, RawTitle, RawAuthor, RawPublisher, RawYear, CleanedISBN, CatCode, MaxPages, RawSubTitle, MinAddedDate,
            ROW_NUMBER() OVER (
                PARTITION BY CASE WHEN CleanedISBN <> '' THEN CleanedISBN ELSE NULL END 
                ORDER BY MinBookNo
            ) AS ISBNRank
        FROM #StagedBooks
    )
    SELECT 
        MinBookNo, RawTitle, RawAuthor, RawPublisher, RawYear, CleanedISBN, CatCode, MaxPages, RawSubTitle, MinAddedDate,
        CASE 
            WHEN CleanedISBN <> '' AND ISBNRank = 1 THEN CleanedISBN
            ELSE 'LGC-TEMP-' + CAST(CAST(MinBookNo AS INT) AS VARCHAR)
        END AS ResolvedISBN
    INTO #BookCatalog
    FROM RankedBooks;

    DECLARE @StagedCount INT = (SELECT COUNT(*) FROM #BookCatalog);
    PRINT 'Staged and resolved distinct books: ' + CAST(@StagedCount AS VARCHAR);

    -- -------------------------------------------------------------------------
    --  5. Books Migration
    -- -------------------------------------------------------------------------
    PRINT 'Migrating books into Master Catalog...';
    
    INSERT INTO Books (ISBN13, ISBN10, Title, SubTitle, CatID, PubID, LangID, PublishYear, PageCount, ClassNo, AddedOn, AddedByStaffID, IsActive)
    SELECT 
        -- ISBN13
        bc.ResolvedISBN AS ISBN13,
        -- ISBN10
        CASE WHEN LEN(bc.CleanedISBN) = 10 THEN bc.CleanedISBN ELSE NULL END AS ISBN10,
        -- Title
        LEFT(bc.RawTitle, 250) AS Title,
        -- SubTitle
        LEFT(bc.RawSubTitle, 150) AS SubTitle,
        -- CatID
        ISNULL(c.CatID, 2) AS CatID, -- Fallback to Non-Fiction
        -- PubID
        p.PubID,
        -- LangID (English = 1)
        1 AS LangID,
        -- PublishYear
        CASE WHEN bc.RawYear BETWEEN 1000 AND 2100 THEN bc.RawYear ELSE NULL END AS PublishYear,
        -- PageCount
        CASE WHEN bc.MaxPages > 0 AND bc.MaxPages <= 32767 THEN CAST(bc.MaxPages AS SMALLINT) ELSE NULL END AS PageCount,
        -- ClassNo
        bc.CatCode AS ClassNo,
        -- AddedOn
        ISNULL(bc.MinAddedDate, CAST(GETDATE() AS DATE)) AS AddedOn,
        -- AddedByStaffID (Admin = 1)
        1 AS AddedByStaffID,
        1 AS IsActive
    FROM #BookCatalog bc
    LEFT JOIN Categories c ON c.CatCode = bc.CatCode
    LEFT JOIN Publishers p ON p.PubName = bc.RawPublisher
    WHERE NOT EXISTS (
        SELECT 1 FROM Books b WHERE b.ISBN13 = bc.ResolvedISBN
    );
    PRINT 'Books migrated successfully: ' + CAST(@@ROWCOUNT AS VARCHAR);

    -- -------------------------------------------------------------------------
    --  6. BookAuthors Migration
    -- -------------------------------------------------------------------------
    PRINT 'Migrating book author linkages...';
    
    INSERT INTO BookAuthors (BookID, AuthorID, RoleID, SortOrder)
    SELECT DISTINCT
        b.BookID,
        a.AuthorID,
        1 AS RoleID, -- Author
        1 AS SortOrder
    FROM #BookCatalog bc
    JOIN Books b ON b.ISBN13 = bc.ResolvedISBN
    -- Join back to Authors using split logic
    CROSS APPLY (
        SELECT 
            CASE 
                WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(bc.RawAuthor)))) > 0
                THEN LTRIM(RTRIM(SUBSTRING(LTRIM(RTRIM(bc.RawAuthor)), 1, LEN(LTRIM(RTRIM(bc.RawAuthor))) - CHARINDEX(' ', REVERSE(LTRIM(RTRIM(bc.RawAuthor)))))))
                ELSE NULL
            END AS FirstName,
            CASE 
                WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(bc.RawAuthor)))) > 0
                THEN LTRIM(RTRIM(SUBSTRING(LTRIM(RTRIM(bc.RawAuthor)), LEN(LTRIM(RTRIM(bc.RawAuthor))) - CHARINDEX(' ', REVERSE(LTRIM(RTRIM(bc.RawAuthor)))) + 2, CHARINDEX(' ', REVERSE(LTRIM(RTRIM(bc.RawAuthor)))))))
                ELSE ISNULL(NULLIF(LTRIM(RTRIM(bc.RawAuthor)), ''), 'Unknown')
            END AS LastName
    ) sa
    JOIN Authors a ON (a.FirstName = sa.FirstName OR (a.FirstName IS NULL AND sa.FirstName IS NULL)) AND a.LastName = sa.LastName
    WHERE NOT EXISTS (
        SELECT 1 FROM BookAuthors ba WHERE ba.BookID = b.BookID AND ba.AuthorID = a.AuthorID
    );
    PRINT 'BookAuthor links migrated: ' + CAST(@@ROWCOUNT AS VARCHAR);

    -- -------------------------------------------------------------------------
    --  7. BookCopies Migration
    -- -------------------------------------------------------------------------
    PRINT 'Migrating physical book copies...';
    
    -- We insert every row from Z_EngBooksData
    INSERT INTO BookCopies (BookID, Barcode, RackID, SlotNo, CondID, IsAvailable, AcqDate, AcqCost, Notes)
    SELECT 
        -- BookID
        b.BookID,
        -- Barcode (Handle duplicates by appending book_no if needed)
        CASE 
            WHEN ROW_NUMBER() OVER (PARTITION BY z.code ORDER BY z.book_no) > 1
            THEN z.code + '-' + CAST(CAST(z.book_no AS INT) AS VARCHAR)
            ELSE z.code
        END AS Barcode,
        -- RackID
        NULL AS RackID,
        NULL AS SlotNo,
        -- CondID (NEW -> 1, OLD/S.H -> 3, Default -> 2)
        CASE 
            WHEN z.b_condtion = 'NEW' OR z.b_condtion = ']NE' THEN 1
            WHEN z.b_condtion = 'OLD' OR z.b_condtion IN ('S.H', 'S,H') THEN 3
            ELSE 2
        END AS CondID,
        -- IsAvailable (status 'I' -> 0, else -> 1)
        CASE WHEN z.status = 'I' THEN 0 ELSE 1 END AS IsAvailable,
        -- AcqDate (purchased date, fallback to current date)
        ISNULL(TRY_CONVERT(DATE, z.pur_dt, 103), CAST(GETDATE() AS DATE)) AS AcqDate,
        -- AcqCost
        CASE WHEN z.cost > 0 THEN TRY_CAST(z.cost AS DECIMAL(8,2)) ELSE NULL END AS AcqCost,
        -- Notes (concatenating reference status and recommendation)
        LEFT(
            LTRIM(RTRIM(
                CASE WHEN z.reference = 1 THEN '[Reference Book] ' ELSE '' END + 
                CASE WHEN z.recmnd_by IS NOT NULL AND LTRIM(RTRIM(z.recmnd_by)) <> '' THEN 'Rec by: ' + LTRIM(RTRIM(z.recmnd_by)) ELSE '' END
            )), 200
        ) AS Notes
    FROM Z_EngBooksData z
    JOIN #BookCatalog bc ON 
        LTRIM(RTRIM(z.title)) = bc.RawTitle
        AND LTRIM(RTRIM(z.author)) = bc.RawAuthor
        AND LTRIM(RTRIM(z.publisher)) = bc.RawPublisher
        AND ISNULL(TRY_CAST(z.y_pub AS SMALLINT), 0) = ISNULL(bc.RawYear, 0)
        AND REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(z.isbn_no)), '-', ''), ' ', ''), '/', ''), '''', '') = bc.CleanedISBN
        AND LEFT(LTRIM(RTRIM(LEFT(z.code, CHARINDEX('-', z.code) - 1))), 8) = bc.CatCode
    JOIN Books b ON b.ISBN13 = bc.ResolvedISBN;
    PRINT 'BookCopies migrated successfully: ' + CAST(@@ROWCOUNT AS VARCHAR);

    -- Clean up temp tables
    IF OBJECT_ID('tempdb..#StagedBooks') IS NOT NULL
        DROP TABLE #StagedBooks;
    IF OBJECT_ID('tempdb..#BookCatalog') IS NOT NULL
        DROP TABLE #BookCatalog;

    COMMIT TRANSACTION;
    PRINT 'Migration completed successfully!';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Migration failed! Transaction rolled back.';
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
END CATCH;
GO
