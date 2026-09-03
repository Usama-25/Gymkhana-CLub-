USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Drop the schema-bound view first to allow column modifications
IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_Books' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    DROP VIEW dbo.vw_Books;
    PRINT 'Dropped view dbo.vw_Books';
END
GO

-- 2. Recreate the vw_Books view with DDC included
CREATE VIEW dbo.vw_Books WITH SCHEMABINDING AS
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
    b.IsAdults,
    b.IsChildren,
    b.DDC, -- Restore the missing DDC column
    c.CatCode,
    c.CatName,
    p.PubName,
    l.LangName,
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
PRINT 'Recreated view dbo.vw_Books with b.DDC column';
GO
