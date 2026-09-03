-- =============================================================================
--  LAHORE GYMKHANA CLUB — LIBRARY MANAGEMENT SYSTEM
--  Database Design  v2.0  |  SQL Server 2019+
--  Standard : ISBN-13 / EAN-13
--
--  DESIGN PRINCIPLES APPLIED
--  ─────────────────────────
--  1. Smallest correct data types for every column (no INT where SMALLINT
--     fits, no VARCHAR(200) where VARCHAR(50) is the real max, etc.)
--  2. CHAR for truly fixed-width values (ISBN13=13, ISBN10=10, CNIC=15)
--  3. NVARCHAR only for columns that genuinely need Unicode (names, titles)
--     Plain VARCHAR everywhere else (codes, paths, statuses)
--  4. Lookup / status columns use TINYINT + a reference table (or a
--     tight CHECK) instead of VARCHAR — saves 1–4 bytes per row and keeps
--     the engine from storing free-text garbage
--  5. Derived / computed columns removed from base tables; exposed only
--     in views (TotalCopies, AvailableCopies counted live — no sync triggers
--     needed, no double-write risk)
--  6. Dates stored as DATE (3 bytes) where time-of-day is irrelevant;
--     DATETIME2(0) (6 bytes, 1-second precision) where timestamps are needed
--     instead of DATETIME (8 bytes, 3.33 ms precision nobody uses)
--  7. DECIMAL(8,2) for money (max PKR 999,999.99); DECIMAL(10,2) only where
--     larger values are plausible
--  8. BIT columns grouped last within each table so SQL Server can pack them
--  9. Indexes: clustered PK on every table; non-clustered covering indexes
--     only on columns used in WHERE / JOIN / ORDER BY
-- 10. No redundant NULLable columns that duplicate other columns
-- 11. All FOREIGN KEYS named; all CHECK constraints named
-- 12. Soft-delete via IsActive BIT; hard-delete never on transactional data
-- =============================================================================

USE master;
GO
IF DB_ID('GymkhanaLibraryDB') IS NOT NULL
BEGIN
    ALTER DATABASE GymkhanaLibraryDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE GymkhanaLibraryDB;
END;
GO
CREATE DATABASE GymkhanaLibraryDB
    COLLATE Latin1_General_100_CI_AS_SC;   -- modern, supports supplementary chars
GO
USE GymkhanaLibraryDB;
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================================================
--  SECTION 0 — LOOKUP / REFERENCE TABLES
--  These replace all the scattered VARCHAR status/type columns with tiny FKs.
-- =============================================================================

-- Language codes  (ISO 639-1 style — 2-char)
CREATE TABLE Languages (
    LangID      TINYINT      NOT NULL PRIMARY KEY,   -- 1-byte, max 255 languages
    LangCode    CHAR(2)      NOT NULL UNIQUE,         -- 'en','ur','ar','fr'
    LangName    VARCHAR(40)  NOT NULL UNIQUE          -- 'English','Urdu', ...
);
INSERT INTO Languages (LangID, LangCode, LangName) VALUES
(1,'en','English'),(2,'ur','Urdu'),(3,'ar','Arabic'),
(4,'fr','French'),(5,'de','German'),(6,'fa','Persian'),
(7,'hi','Hindi'),(8,'xx','Other');

-- Member types
CREATE TABLE MemberTypes (
    MTypeID     TINYINT     NOT NULL PRIMARY KEY,
    TypeName    VARCHAR(20) NOT NULL UNIQUE,
    MaxBooks    TINYINT     NOT NULL DEFAULT 3   -- default borrow limit
);
INSERT INTO MemberTypes VALUES
(1,'Regular',3),(2,'Life',5),(3,'Junior',2),
(4,'Corporate',5),(5,'Honorary',5),(6,'Staff',4);

-- Copy conditions
CREATE TABLE CopyConditions (
    CondID      TINYINT     NOT NULL PRIMARY KEY,
    CondName    VARCHAR(10) NOT NULL UNIQUE
);
INSERT INTO CopyConditions VALUES
(1,'New'),(2,'Good'),(3,'Fair'),(4,'Worn'),(5,'Damaged'),(6,'Lost');

-- Author roles in a book
CREATE TABLE AuthorRoles (
    RoleID      TINYINT     NOT NULL PRIMARY KEY,
    RoleName    VARCHAR(20) NOT NULL UNIQUE
);
INSERT INTO AuthorRoles VALUES
(1,'Author'),(2,'Co-Author'),(3,'Editor'),(4,'Translator'),(5,'Illustrator');

-- Transaction statuses
CREATE TABLE TxnStatuses (
    StatusID    TINYINT     NOT NULL PRIMARY KEY,
    StatusName  VARCHAR(12) NOT NULL UNIQUE
);
INSERT INTO TxnStatuses VALUES
(1,'Issued'),(2,'Returned'),(3,'Overdue'),(4,'Renewed'),(5,'Lost');

-- Reservation statuses
CREATE TABLE ResStatuses (
    StatusID    TINYINT     NOT NULL PRIMARY KEY,
    StatusName  VARCHAR(12) NOT NULL UNIQUE
);
INSERT INTO ResStatuses VALUES
(1,'Active'),(2,'Fulfilled'),(3,'Cancelled'),(4,'Expired');

-- Staff roles
CREATE TABLE StaffRoles (
    RoleID      TINYINT     NOT NULL PRIMARY KEY,
    RoleName    VARCHAR(15) NOT NULL UNIQUE
);
INSERT INTO StaffRoles VALUES
(1,'Admin'),(2,'Librarian'),(3,'Assistant');

-- Fine reasons
CREATE TABLE FineReasons (
    ReasonID    TINYINT     NOT NULL PRIMARY KEY,
    ReasonName  VARCHAR(20) NOT NULL UNIQUE
);
INSERT INTO FineReasons VALUES
(1,'Overdue'),(2,'Lost Book'),(3,'Damage'),(4,'Other');

GO
-- =============================================================================
--  SECTION 1 — ISBN-13 VALIDATION FUNCTION
-- =============================================================================

-- fn_ISBN13Valid: returns 1 if the 13-char string passes EAN-13 check digit
CREATE FUNCTION dbo.fn_ISBN13Valid (@v CHAR(13))
RETURNS BIT WITH SCHEMABINDING
AS
BEGIN
    -- Quick numeric guard  (LIKE pattern: NOT like non-digit = all digits)
    IF @v LIKE '%[^0-9]%' RETURN 0;
    RETURN CASE
        WHEN (  (CAST(SUBSTRING(@v, 1,1) AS INT)
               + CAST(SUBSTRING(@v, 3,1) AS INT)
               + CAST(SUBSTRING(@v, 5,1) AS INT)
               + CAST(SUBSTRING(@v, 7,1) AS INT)
               + CAST(SUBSTRING(@v, 9,1) AS INT)
               + CAST(SUBSTRING(@v,11,1) AS INT))
             + (CAST(SUBSTRING(@v, 2,1) AS INT)
               + CAST(SUBSTRING(@v, 4,1) AS INT)
               + CAST(SUBSTRING(@v, 6,1) AS INT)
               + CAST(SUBSTRING(@v, 8,1) AS INT)
               + CAST(SUBSTRING(@v,10,1) AS INT)
               + CAST(SUBSTRING(@v,12,1) AS INT)) * 3
             + CAST(SUBSTRING(@v,13,1) AS INT)
        ) % 10 = 0  THEN 1  ELSE 0
    END;
END;
GO

-- fn_ISBN13Fmt: display as 978-X-XXX-XXXXX-X
CREATE FUNCTION dbo.fn_ISBN13Fmt (@v CHAR(13))
RETURNS CHAR(17) WITH SCHEMABINDING
AS
BEGIN
    RETURN  SUBSTRING(@v,1,3)+'-'+SUBSTRING(@v,4,1)+'-'
           +SUBSTRING(@v,5,3)+'-'+SUBSTRING(@v,8,5)+'-'+SUBSTRING(@v,13,1);
END;
GO

-- =============================================================================
--  SECTION 2 — PHYSICAL LIBRARY LAYOUT
--  Hall  →  ShelfUnit  →  Rack  →  Slot  (4-level hierarchy, aisle removed;
--  aisles can be modelled as ShelfUnits within a Hall — reduces one join)
-- =============================================================================

CREATE TABLE Halls (
    HallID      SMALLINT     NOT NULL IDENTITY PRIMARY KEY,  -- max 32 767 halls
    HallCode    VARCHAR(10)  NOT NULL UNIQUE,
    HallName    NVARCHAR(80) NOT NULL,
    FloorNo     TINYINT      NOT NULL DEFAULT 0,  -- 0=Ground, 1=First …
    IsActive    BIT          NOT NULL DEFAULT 1
);

CREATE TABLE ShelfUnits (
    UnitID      SMALLINT     NOT NULL IDENTITY PRIMARY KEY,
    HallID      SMALLINT     NOT NULL REFERENCES Halls(HallID),
    UnitCode    VARCHAR(12)  NOT NULL,           -- e.g. 'A-01', 'B-03'
    UnitName    NVARCHAR(60) NULL,
    CONSTRAINT UQ_Unit UNIQUE (HallID, UnitCode)
);

CREATE TABLE Racks (
    RackID      SMALLINT     NOT NULL IDENTITY PRIMARY KEY,
    UnitID      SMALLINT     NOT NULL REFERENCES ShelfUnits(UnitID),
    RackNo      TINYINT      NOT NULL,           -- 1=top row, ↓ increasing
    TotalSlots  TINYINT      NOT NULL DEFAULT 30 CHECK (TotalSlots BETWEEN 1 AND 100),
    SubjectTag  NVARCHAR(60) NULL,               -- 'Fiction','History'…
    CONSTRAINT UQ_Rack UNIQUE (UnitID, RackNo)
);
-- UsedSlots is computed on the fly in the view — no trigger needed
GO



-- =============================================================================
--  SECTION 3 — CATALOGUE  (Books, Authors, Publishers, Categories)
-- =============================================================================

CREATE TABLE Categories (
    CatID       SMALLINT     NOT NULL IDENTITY PRIMARY KEY,
    CatCode     VARCHAR(8)   NOT NULL UNIQUE,    -- 'FIC','HIS','SCI' …
    CatName     NVARCHAR(80) NOT NULL UNIQUE,
    ParentCatID SMALLINT     NULL REFERENCES Categories(CatID),
    IsActive    BIT          NOT NULL DEFAULT 1
);

CREATE TABLE Publishers (
    PubID       SMALLINT     NOT NULL IDENTITY PRIMARY KEY,
    PubName     NVARCHAR(120) NOT NULL,
    Country     VARCHAR(60)  NULL,
    IsActive    BIT          NOT NULL DEFAULT 1
);

CREATE TABLE Authors (
    AuthorID    SMALLINT      NOT NULL IDENTITY PRIMARY KEY,
    FirstName   NVARCHAR(60)  NOT NULL,
    LastName    NVARCHAR(60)  NOT NULL,
    -- FullName as computed persisted column — zero extra storage join cost
    FullName    AS (LastName + ', ' + FirstName) PERSISTED,
    Nationality VARCHAR(50)   NULL,
    IsActive    BIT           NOT NULL DEFAULT 1
);
-- Index on FullName for author-search queries
CREATE INDEX IX_Authors_FullName ON Authors (FullName);

-- ── Books (master catalogue) ──────────────────────────────────────────────────
CREATE TABLE Books (
    BookID          INT           NOT NULL IDENTITY PRIMARY KEY,

    -- ISBN-13: stored clean, validated at INSERT/UPDATE via CHECK
    ISBN13          CHAR(13)      NOT NULL UNIQUE,
    -- ISBN-10: 10-char legacy  (nullable — older books pre-978 era)
    ISBN10          CHAR(10)      NULL,

    Title           NVARCHAR(250) NOT NULL,
    SubTitle        NVARCHAR(150) NULL,
    CatID           SMALLINT      NOT NULL REFERENCES Categories(CatID),
    PubID           SMALLINT      NULL     REFERENCES Publishers(PubID),
    LangID          TINYINT       NOT NULL DEFAULT 1 REFERENCES Languages(LangID),
    PublishYear     SMALLINT      NULL,           -- 2-byte integer, range ±32 767
    Edition         VARCHAR(30)   NULL,           -- '3rd', '2023 Rev.'
    PageCount       SMALLINT      NULL,           -- max 32 767 pages
    ClassNo         VARCHAR(30)   NULL,           -- Dewey/LC  e.g. '823.914'
    Tags            VARCHAR(300)  NULL,           -- ASCII tags; no NVARCHAR needed
    Synopsis        NVARCHAR(MAX) NULL,           -- large text — kept sparse

    -- Cover image: filename only (e.g. '9780316769174.jpg')
    -- Full path = base path in Settings + this filename
    -- Separating base path avoids storing ~25 chars × every row
    CoverFile       VARCHAR(50)   NULL,           -- '9780316769174.jpg'

    AddedOn         DATE          NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    AddedByStaffID  SMALLINT      NULL,           -- FK added after Staff table
    IsActive        BIT           NOT NULL DEFAULT 1,

    CONSTRAINT CK_ISBN13_Fmt    CHECK (LEN(ISBN13) = 13),
    CONSTRAINT CK_ISBN13_Digits CHECK (ISBN13 NOT LIKE '%[^0-9]%'),
    CONSTRAINT CK_ISBN13_Check  CHECK (dbo.fn_ISBN13Valid(ISBN13) = 1),
    CONSTRAINT CK_PubYear       CHECK (PublishYear BETWEEN 1000 AND 2100),
    CONSTRAINT CK_Pages         CHECK (PageCount   > 0)
);
-- Frequent search patterns
CREATE INDEX IX_Books_Title   ON Books (Title);
CREATE INDEX IX_Books_CatID   ON Books (CatID)  INCLUDE (Title, ISBN13);
CREATE INDEX IX_Books_PubID   ON Books (PubID);

-- ── Book ↔ Author  (many-to-many) ─────────────────────────────────────────────
CREATE TABLE BookAuthors (
    BookID      INT      NOT NULL REFERENCES Books(BookID)   ON DELETE CASCADE,
    AuthorID    SMALLINT NOT NULL REFERENCES Authors(AuthorID),
    RoleID      TINYINT  NOT NULL DEFAULT 1 REFERENCES AuthorRoles(RoleID),
    SortOrder   TINYINT  NOT NULL DEFAULT 1,  -- 1=primary author
    CONSTRAINT PK_BookAuthors PRIMARY KEY (BookID, AuthorID)
);

-- ── Physical copies ────────────────────────────────────────────────────────────
CREATE TABLE BookCopies (
    CopyID          INT           NOT NULL IDENTITY PRIMARY KEY,
    BookID          INT           NOT NULL REFERENCES Books(BookID),

    -- Barcode: ISBN13(13) + '-' + 3-digit seq  =  17 chars max
    Barcode         CHAR(17)      NOT NULL UNIQUE,

    RackID          SMALLINT      NULL REFERENCES Racks(RackID),
    SlotNo          TINYINT       NULL CHECK (SlotNo BETWEEN 1 AND 100),

    CondID          TINYINT       NOT NULL DEFAULT 2 REFERENCES CopyConditions(CondID),
    IsAvailable     BIT           NOT NULL DEFAULT 1,
    AcqDate         DATE          NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    AcqCost         DECIMAL(8,2)  NULL,           -- PKR, max 999 999.99
    Notes           VARCHAR(200)  NULL
);
CREATE UNIQUE NONCLUSTERED INDEX UX_CopySlot ON BookCopies (RackID, SlotNo) WHERE RackID IS NOT NULL AND SlotNo IS NOT NULL;
CREATE INDEX IX_Copies_BookID ON BookCopies (BookID) INCLUDE (IsAvailable, CondID);
CREATE INDEX IX_Copies_RackID ON BookCopies (RackID, SlotNo);
GO

-- Lightweight view: full shelf address + live occupancy
CREATE VIEW vw_RackOccupancy AS
SELECT
    r.RackID,
    h.HallCode,
    h.HallName,
    su.UnitCode,
    r.RackNo,
    r.TotalSlots,
    r.SubjectTag,
    COUNT_BIG(bc.CopyID)                            AS UsedSlots,
    CAST(r.TotalSlots - COUNT_BIG(bc.CopyID) AS TINYINT) AS FreeSlots,
    h.HallCode + '-' + su.UnitCode + '-R'
        + CAST(r.RackNo AS VARCHAR(3))              AS FullAddress
FROM dbo.Racks r
JOIN dbo.ShelfUnits su ON r.UnitID  = su.UnitID
JOIN dbo.Halls      h  ON su.HallID = h.HallID
LEFT JOIN dbo.BookCopies bc ON bc.RackID     = r.RackID
GROUP BY r.RackID, h.HallCode, h.HallName, su.UnitCode,
         r.RackNo, r.TotalSlots, r.SubjectTag;
GO

-- =============================================================================
--  SECTION 4 — MEMBERS
-- =============================================================================

CREATE TABLE Members (
    MemberID        INT           NOT NULL IDENTITY PRIMARY KEY,
    -- LGC-YYYY-NNNN  max 14 chars
    MembershipNo    VARCHAR(14)   NOT NULL UNIQUE,
    FullName        NVARCHAR(100) NOT NULL,
    -- CNIC: 42101-1234567-1 = exactly 15 chars
    CNIC            CHAR(15)      NULL,
    Phone           VARCHAR(15)   NULL,
    Email           VARCHAR(80)   NULL,
    MTypeID         TINYINT       NOT NULL DEFAULT 1 REFERENCES MemberTypes(MTypeID),
    -- MaxBooks per member overrides the type default when set
    MaxBooksOverride TINYINT      NULL,
    JoinDate        DATE          NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    ExpiryDate      DATE          NULL,
    -- Photo: filename only (same pattern as CoverFile)
    PhotoFile       VARCHAR(50)   NULL,
    IsActive        BIT           NOT NULL DEFAULT 1
);
CREATE INDEX IX_Members_MembershipNo ON Members (MembershipNo);
CREATE UNIQUE INDEX UX_Members_CNIC  ON Members (CNIC) WHERE CNIC IS NOT NULL;
CREATE INDEX IX_Members_Name         ON Members (FullName);

-- =============================================================================
--  SECTION 5 — TRANSACTIONS
-- =============================================================================

CREATE TABLE Loans (
    LoanID          INT             NOT NULL IDENTITY PRIMARY KEY,
    MemberID        INT             NOT NULL REFERENCES Members(MemberID),
    CopyID          INT             NOT NULL REFERENCES BookCopies(CopyID),
    IssueDate       DATETIME2(0)    NOT NULL DEFAULT SYSDATETIME(),
    DueDate         DATE            NOT NULL,
    ReturnDate      DATETIME2(0)    NULL,
    RenewalCount    TINYINT         NOT NULL DEFAULT 0,
    StatusID        TINYINT         NOT NULL DEFAULT 1 REFERENCES TxnStatuses(StatusID),
    IssuedByID      SMALLINT        NULL,   -- FK to Staff; added below
    ReturnedByID    SMALLINT        NULL,   -- FK to Staff; added below
    Remarks         VARCHAR(200)    NULL
);
-- Hot query: overdue check, member current loans
CREATE INDEX IX_Loans_MemberID  ON Loans (MemberID) INCLUDE (StatusID, DueDate);
CREATE INDEX IX_Loans_CopyID    ON Loans (CopyID)   INCLUDE (StatusID);
CREATE INDEX IX_Loans_DueStatus ON Loans (DueDate, StatusID);

-- =============================================================================
--  SECTION 6 — FINES
-- =============================================================================

CREATE TABLE Fines (
    FineID          INT             NOT NULL IDENTITY PRIMARY KEY,
    LoanID          INT             NOT NULL REFERENCES Loans(LoanID),
    MemberID        INT             NOT NULL REFERENCES Members(MemberID),
    ReasonID        TINYINT         NOT NULL DEFAULT 1 REFERENCES FineReasons(ReasonID),
    FineAmount      DECIMAL(8,2)    NOT NULL CHECK (FineAmount > 0),
    IsPaid          BIT             NOT NULL DEFAULT 0,
    CreatedAt       DATETIME2(0)    NOT NULL DEFAULT SYSDATETIME(),
    PaidAt          DATETIME2(0)    NULL,
    CollectedByID   SMALLINT        NULL    -- FK to Staff; added below
);
CREATE INDEX IX_Fines_MemberID ON Fines (MemberID) INCLUDE (IsPaid, FineAmount);
CREATE INDEX IX_Fines_LoanID   ON Fines (LoanID);

-- =============================================================================
--  SECTION 7 — RESERVATIONS
-- =============================================================================

CREATE TABLE Reservations (
    ResID           INT             NOT NULL IDENTITY PRIMARY KEY,
    MemberID        INT             NOT NULL REFERENCES Members(MemberID),
    BookID          INT             NOT NULL REFERENCES Books(BookID),
    ReservedAt      DATETIME2(0)    NOT NULL DEFAULT SYSDATETIME(),
    ExpiresOn       DATE            NOT NULL,
    StatusID        TINYINT         NOT NULL DEFAULT 1 REFERENCES ResStatuses(StatusID),
    QueuePos        TINYINT         NOT NULL DEFAULT 1,
    NotifiedAt      DATETIME2(0)    NULL,
    StartDate       DATE            NULL,
    EndDate         DATE            NULL,
    CONSTRAINT UQ_ActiveReservation UNIQUE (MemberID, BookID, StatusID)  -- prevent duplicate active
);
CREATE INDEX IX_Res_BookID   ON Reservations (BookID, StatusID);
CREATE INDEX IX_Res_MemberID ON Reservations (MemberID, StatusID);

-- =============================================================================
--  SECTION 8 — STAFF / AUTH (Removed)
-- =============================================================================


-- =============================================================================
--  SECTION 9 — SETTINGS  (key-value; strongly typed)
-- =============================================================================

CREATE TABLE Settings (
    SKey        VARCHAR(40)     NOT NULL PRIMARY KEY,
    SVal        VARCHAR(200)    NOT NULL,
    SType       CHAR(1)         NOT NULL DEFAULT 'S'
                CHECK (SType IN ('I','D','S')),  -- Integer / Decimal / String
    Note        VARCHAR(120)    NULL
);

INSERT INTO Settings (SKey, SVal, SType, Note) VALUES
('LoanDays',      '14',                              'I', 'Default loan period in days'),
('FinePerDay',    '10.00',                           'D', 'Overdue fine per day (PKR)'),
('MaxRenewals',   '2',                               'I', 'Renewals allowed per copy'),
('ResDays',       '7',                               'I', 'Reservation hold period (days)'),
('FineCeiling',   '500.00',                          'D', 'Max outstanding fine before issue blocked (PKR)'),
('CoverBasePath', 'Images/BookCovers/',              'S', 'Relative folder for cover images'),
('PhotoBasePath', 'Images/MemberPhotos/',            'S', 'Relative folder for member photos'),
('LibraryName',   'Lahore Gymkhana Club Library',    'S', 'Display name');

GO

-- =============================================================================
--  SUMMARY VIEW — used by most UI grids
-- =============================================================================

CREATE VIEW vw_Books WITH SCHEMABINDING AS
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
    c.CatCode,
    c.CatName,
    p.PubName,
    l.LangName,
    -- Live copy counts — no denormalised column, no trigger risk
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

PRINT '=== GymkhanaLibraryDB schema created successfully ===';
GO
