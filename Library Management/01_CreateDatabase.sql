-- ============================================================
--  LAHORE GYMKHANA CLUB - LIBRARY MANAGEMENT SYSTEM
--  Database Script v1.0
--  SQL Server 2019+
--  Standard: ISBN-13 (EAN-13 compliant)
-- ============================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'GymkhanaLibraryDB')
    DROP DATABASE GymkhanaLibraryDB;
GO

CREATE DATABASE GymkhanaLibraryDB
    COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE GymkhanaLibraryDB;
GO

-- ============================================================
--  SECTION 1: PHYSICAL LIBRARY LAYOUT
--  Hall → Aisle → Shelf Unit → Rack (Row) → Slot (Position)
-- ============================================================

CREATE TABLE LibraryHalls (
    HallID          INT IDENTITY(1,1) PRIMARY KEY,
    HallCode        VARCHAR(10)  NOT NULL UNIQUE,   -- e.g. 'A', 'B', 'MAIN'
    HallName        NVARCHAR(100) NOT NULL,          -- e.g. 'Main Reading Hall'
    Floor           VARCHAR(20)  NOT NULL DEFAULT 'Ground',
    Description     NVARCHAR(255),
    IsActive        BIT          NOT NULL DEFAULT 1,
    CreatedAt       DATETIME     NOT NULL DEFAULT GETDATE()
);

CREATE TABLE Aisles (
    AisleID         INT IDENTITY(1,1) PRIMARY KEY,
    HallID          INT          NOT NULL REFERENCES LibraryHalls(HallID),
    AisleCode       VARCHAR(10)  NOT NULL,           -- e.g. 'A1', 'A2'
    AisleName       NVARCHAR(100),
    CONSTRAINT UQ_Aisle UNIQUE (HallID, AisleCode)
);

-- Shelf Units: physical standing shelving units
CREATE TABLE ShelfUnits (
    ShelfUnitID     INT IDENTITY(1,1) PRIMARY KEY,
    AisleID         INT          NOT NULL REFERENCES Aisles(AisleID),
    ShelfUnitCode   VARCHAR(20)  NOT NULL,           -- e.g. 'SU-A1-01'
    ShelfUnitName   NVARCHAR(100),
    TotalRacks      INT          NOT NULL DEFAULT 5, -- number of horizontal racks/rows
    CONSTRAINT UQ_ShelfUnit UNIQUE (AisleID, ShelfUnitCode)
);

-- Racks: horizontal rows/shelves inside a shelf unit
CREATE TABLE Racks (
    RackID          INT IDENTITY(1,1) PRIMARY KEY,
    ShelfUnitID     INT          NOT NULL REFERENCES ShelfUnits(ShelfUnitID),
    RackNumber      INT          NOT NULL,           -- 1 = top, increasing downward
    RackLabel       VARCHAR(20),                     -- e.g. 'R1', 'R2'
    TotalSlots      INT          NOT NULL DEFAULT 30,
    UsedSlots       INT          NOT NULL DEFAULT 0,
    SubjectTag      NVARCHAR(100),                  -- optional label e.g. 'Fiction', 'History'
    CONSTRAINT UQ_Rack UNIQUE (ShelfUnitID, RackNumber)
);

-- Full shelf address view
CREATE VIEW vw_ShelfAddress AS
SELECT
    r.RackID,
    h.HallCode,
    h.HallName,
    a.AisleCode,
    su.ShelfUnitCode,
    r.RackNumber,
    r.RackLabel,
    r.SubjectTag,
    r.TotalSlots,
    r.UsedSlots,
    (r.TotalSlots - r.UsedSlots) AS FreeSlots,
    -- Human-readable address: e.g. MAIN / A1 / SU-A1-01 / R3
    h.HallCode + ' / ' + a.AisleCode + ' / ' + su.ShelfUnitCode + ' / ' + ISNULL(r.RackLabel,'R'+CAST(r.RackNumber AS VARCHAR)) AS FullAddress
FROM Racks r
JOIN ShelfUnits su ON r.ShelfUnitID = su.ShelfUnitID
JOIN Aisles a      ON su.AisleID    = a.AisleID
JOIN LibraryHalls h ON a.HallID     = h.HallID;
GO

-- ============================================================
--  SECTION 2: BOOK CATALOG  (ISBN-13 / EAN-13)
-- ============================================================

/*  ISBN-13 FORMAT:
    978-[GroupCode]-[PublisherCode]-[TitleCode]-[CheckDigit]
    Stored as 13-digit string: '9780316769174'
    Display formatted: '978-0-316-76917-4'
    Validated by check digit algorithm (modulo 10, alternating 1/3 weights)
*/

-- User-defined function: validate ISBN-13 check digit
CREATE FUNCTION fn_ValidateISBN13 (@isbn VARCHAR(20))
RETURNS BIT
AS
BEGIN
    -- Strip hyphens and spaces
    DECLARE @clean VARCHAR(13) = REPLACE(REPLACE(@isbn, '-', ''), ' ', '');
    IF LEN(@clean) <> 13 OR @clean NOT LIKE '%[^0-9]%' -- must be exactly 13 digits
        -- extra guard: if contains non-digit, reject
        BEGIN
            IF @clean LIKE '%[^0-9]%' RETURN 0;
            RETURN 0;
        END;

    DECLARE @sum INT = 0, @i INT = 1, @digit INT, @weight INT;
    WHILE @i <= 12
    BEGIN
        SET @digit  = CAST(SUBSTRING(@clean, @i, 1) AS INT);
        SET @weight = CASE WHEN @i % 2 = 1 THEN 1 ELSE 3 END;
        SET @sum    = @sum + (@digit * @weight);
        SET @i      = @i + 1;
    END;
    DECLARE @check INT = (10 - (@sum % 10)) % 10;
    RETURN CASE WHEN @check = CAST(SUBSTRING(@clean,13,1) AS INT) THEN 1 ELSE 0 END;
END;
GO

-- Function: format ISBN-13 for display  978-X-XXX-XXXXX-X
CREATE FUNCTION fn_FormatISBN13 (@isbn VARCHAR(13))
RETURNS VARCHAR(17)
AS
BEGIN
    IF LEN(@isbn) <> 13 RETURN @isbn;
    RETURN SUBSTRING(@isbn,1,3) + '-' +
           SUBSTRING(@isbn,4,1) + '-' +
           SUBSTRING(@isbn,5,3) + '-' +
           SUBSTRING(@isbn,8,5) + '-' +
           SUBSTRING(@isbn,13,1);
END;
GO

CREATE TABLE Categories (
    CategoryID      INT IDENTITY(1,1) PRIMARY KEY,
    CategoryCode    VARCHAR(10)  NOT NULL UNIQUE,   -- e.g. 'FIC','HIS','SCI'
    CategoryName    NVARCHAR(100) NOT NULL UNIQUE,
    ParentCategoryID INT         REFERENCES Categories(CategoryID),
    Description     NVARCHAR(255),
    IsActive        BIT          NOT NULL DEFAULT 1
);

CREATE TABLE Publishers (
    PublisherID     INT IDENTITY(1,1) PRIMARY KEY,
    PublisherName   NVARCHAR(150) NOT NULL,
    Country         NVARCHAR(100),
    Website         NVARCHAR(200),
    IsActive        BIT          NOT NULL DEFAULT 1
);

CREATE TABLE Authors (
    AuthorID        INT IDENTITY(1,1) PRIMARY KEY,
    FirstName       NVARCHAR(100) NOT NULL,
    LastName        NVARCHAR(100) NOT NULL,
    FullName        AS (FirstName + ' ' + LastName),  -- computed
    Nationality     NVARCHAR(100),
    Biography       NVARCHAR(MAX),
    IsActive        BIT          NOT NULL DEFAULT 1
);

-- Master book catalog
CREATE TABLE Books (
    BookID          INT IDENTITY(1,1) PRIMARY KEY,

    -- ISBN-13 (EAN-13): stored as clean 13-digit string
    ISBN13          CHAR(13)     NOT NULL UNIQUE,
    -- ISBN-10 kept for legacy lookup only (nullable)
    ISBN10          CHAR(10)     NULL,

    Title           NVARCHAR(300) NOT NULL,
    SubTitle        NVARCHAR(200) NULL,
    CategoryID      INT          NOT NULL REFERENCES Categories(CategoryID),
    PublisherID     INT          NULL     REFERENCES Publishers(PublisherID),
    PublishYear     SMALLINT     NULL,
    Edition         VARCHAR(50)  NULL,    -- e.g. '3rd Edition', '2023 Revised'
    Language        VARCHAR(50)  NOT NULL DEFAULT 'English',
    PageCount       INT          NULL,
    Description     NVARCHAR(MAX) NULL,
    Tags            NVARCHAR(500) NULL,  -- comma-separated keywords

    -- Cover image: stored as relative path  ~/Images/BookCovers/978xxxxxxxxxx.jpg
    CoverImagePath  NVARCHAR(500) NULL,
    CoverImageThumb NVARCHAR(500) NULL,  -- thumbnail 120x160

    -- Aggregated from BookCopies (maintained by triggers)
    TotalCopies     INT          NOT NULL DEFAULT 0,
    AvailableCopies INT          NOT NULL DEFAULT 0,

    -- Dewey or LC classification (optional)
    ClassificationNo VARCHAR(50) NULL,

    AddedOn         DATETIME     NOT NULL DEFAULT GETDATE(),
    AddedBy         NVARCHAR(100) NULL,
    IsActive        BIT          NOT NULL DEFAULT 1,

    CONSTRAINT CK_ISBN13_Length   CHECK (LEN(ISBN13) = 13),
    CONSTRAINT CK_ISBN13_Numeric  CHECK (ISBN13 NOT LIKE '%[^0-9]%'),
    CONSTRAINT CK_PublishYear     CHECK (PublishYear BETWEEN 1000 AND 2100),
    CONSTRAINT CK_Copies          CHECK (AvailableCopies <= TotalCopies AND AvailableCopies >= 0)
);

-- Book ↔ Author (many-to-many)
CREATE TABLE BookAuthors (
    BookID          INT NOT NULL REFERENCES Books(BookID)   ON DELETE CASCADE,
    AuthorID        INT NOT NULL REFERENCES Authors(AuthorID),
    AuthorRole      VARCHAR(50) DEFAULT 'Author',          -- 'Author','Editor','Translator'
    AuthorOrder     INT NOT NULL DEFAULT 1,
    PRIMARY KEY (BookID, AuthorID)
);

-- Physical copies of a book
CREATE TABLE BookCopies (
    CopyID          INT IDENTITY(1,1) PRIMARY KEY,
    BookID          INT          NOT NULL REFERENCES Books(BookID),

    -- Barcode = ISBN13 + copy suffix: '9780316769174-001'
    Barcode         VARCHAR(25)  NOT NULL UNIQUE,

    -- Shelf location (FK to Rack)
    RackID          INT          NULL REFERENCES Racks(RackID),
    SlotNumber      INT          NULL,   -- position within the rack (1..TotalSlots)

    Condition       VARCHAR(20)  NOT NULL DEFAULT 'Good'
                    CHECK (Condition IN ('New','Good','Fair','Worn','Damaged','Lost')),
    IsAvailable     BIT          NOT NULL DEFAULT 1,
    AcquisitionDate DATE         NOT NULL DEFAULT GETDATE(),
    AcquisitionCost DECIMAL(10,2) NULL,
    Notes           NVARCHAR(255) NULL,

    CONSTRAINT CK_SlotNumber CHECK (SlotNumber > 0)
);

-- Trigger: keep Books.TotalCopies and AvailableCopies in sync
CREATE TRIGGER trg_BookCopies_AfterInsert
ON BookCopies AFTER INSERT
AS
BEGIN
    UPDATE Books
    SET TotalCopies     = TotalCopies + 1,
        AvailableCopies = AvailableCopies + 1
    WHERE BookID IN (SELECT BookID FROM inserted);

    -- Update rack used slots
    UPDATE r SET r.UsedSlots = r.UsedSlots + 1
    FROM Racks r
    JOIN inserted i ON r.RackID = i.RackID
    WHERE i.RackID IS NOT NULL;
END;
GO

CREATE TRIGGER trg_BookCopies_AfterDelete
ON BookCopies AFTER DELETE
AS
BEGIN
    UPDATE Books
    SET TotalCopies     = TotalCopies - 1,
        AvailableCopies = AvailableCopies - (CASE WHEN d.IsAvailable = 1 THEN 1 ELSE 0 END)
    FROM Books b JOIN deleted d ON b.BookID = d.BookID;

    UPDATE r SET r.UsedSlots = r.UsedSlots - 1
    FROM Racks r
    JOIN deleted d ON r.RackID = d.RackID
    WHERE d.RackID IS NOT NULL;
END;
GO

-- ============================================================
--  SECTION 3: MEMBERS
-- ============================================================

CREATE TABLE Members (
    MemberID        INT IDENTITY(1,1) PRIMARY KEY,
    MembershipNo    VARCHAR(20)  NOT NULL UNIQUE,   -- e.g. 'LGC-2024-0001'
    FullName        NVARCHAR(100) NOT NULL,
    CNIC            VARCHAR(15)  NULL,               -- 42101-1234567-1
    Phone           VARCHAR(20)  NULL,
    Email           NVARCHAR(100) NULL,
    MemberType      VARCHAR(30)  NOT NULL DEFAULT 'Regular'
                    CHECK (MemberType IN ('Regular','Life','Junior','Corporate','Honorary','Staff')),
    JoinDate        DATE         NOT NULL DEFAULT GETDATE(),
    ExpiryDate      DATE         NULL,
    IsActive        BIT          NOT NULL DEFAULT 1,
    MaxBooksAllowed INT          NOT NULL DEFAULT 3,
    PhotoPath       NVARCHAR(500) NULL,
    Address         NVARCHAR(500) NULL,
    CreatedAt       DATETIME     NOT NULL DEFAULT GETDATE()
);

-- ============================================================
--  SECTION 4: TRANSACTIONS, FINES, RESERVATIONS
-- ============================================================

CREATE TABLE BorrowTransactions (
    TransactionID   INT IDENTITY(1,1) PRIMARY KEY,
    MemberID        INT          NOT NULL REFERENCES Members(MemberID),
    CopyID          INT          NOT NULL REFERENCES BookCopies(CopyID),
    IssueDate       DATETIME     NOT NULL DEFAULT GETDATE(),
    DueDate         DATETIME     NOT NULL,
    ReturnDate      DATETIME     NULL,
    RenewalCount    TINYINT      NOT NULL DEFAULT 0,
    Status          VARCHAR(20)  NOT NULL DEFAULT 'Issued'
                    CHECK (Status IN ('Issued','Returned','Overdue','Lost','Renewed')),
    IssuedBy        NVARCHAR(100) NULL,
    ReturnedBy      NVARCHAR(100) NULL,
    Remarks         NVARCHAR(255) NULL
);

CREATE TABLE Fines (
    FineID          INT IDENTITY(1,1) PRIMARY KEY,
    TransactionID   INT          NOT NULL REFERENCES BorrowTransactions(TransactionID),
    MemberID        INT          NOT NULL REFERENCES Members(MemberID),
    FineAmount      DECIMAL(10,2) NOT NULL,
    FineReason      VARCHAR(100) NOT NULL,
    IsPaid          BIT          NOT NULL DEFAULT 0,
    PaidOn          DATETIME     NULL,
    CollectedBy     NVARCHAR(100) NULL,
    CreatedAt       DATETIME     NOT NULL DEFAULT GETDATE()
);

CREATE TABLE Reservations (
    ReservationID   INT IDENTITY(1,1) PRIMARY KEY,
    MemberID        INT          NOT NULL REFERENCES Members(MemberID),
    BookID          INT          NOT NULL REFERENCES Books(BookID),
    ReservedOn      DATETIME     NOT NULL DEFAULT GETDATE(),
    ExpiryDate      DATETIME     NOT NULL,
    Status          VARCHAR(20)  NOT NULL DEFAULT 'Active'
                    CHECK (Status IN ('Active','Fulfilled','Cancelled','Expired')),
    NotifiedOn      DATETIME     NULL,
    QueuePosition   INT          NOT NULL DEFAULT 1
);

-- ============================================================
--  SECTION 5: STAFF / AUTH
-- ============================================================

CREATE TABLE LibraryStaff (
    StaffID         INT IDENTITY(1,1) PRIMARY KEY,
    Username        VARCHAR(50)  NOT NULL UNIQUE,
    PasswordHash    VARCHAR(256) NOT NULL,
    FullName        NVARCHAR(100) NOT NULL,
    Role            VARCHAR(30)  NOT NULL DEFAULT 'Librarian'
                    CHECK (Role IN ('Admin','Librarian','Assistant')),
    IsActive        BIT          NOT NULL DEFAULT 1,
    LastLogin       DATETIME     NULL,
    CreatedAt       DATETIME     NOT NULL DEFAULT GETDATE()
);

-- ============================================================
--  SECTION 6: SETTINGS
-- ============================================================

CREATE TABLE LibrarySettings (
    SettingKey      VARCHAR(100) PRIMARY KEY,
    SettingValue    NVARCHAR(500) NOT NULL,
    DataType        VARCHAR(20)  NOT NULL DEFAULT 'string',
    Description     NVARCHAR(255)
);

INSERT INTO LibrarySettings VALUES
('LoanDurationDays', '14',    'int',    'Default loan period in days'),
('FinePerDay',       '10',    'decimal','Fine per overdue day in PKR'),
('MaxRenewals',      '2',     'int',    'Maximum renewals per copy per member'),
('MaxBooksPerMember','3',     'int',    'Default max simultaneous borrows'),
('ReservationDays',  '7',     'int',    'How many days a reservation is held'),
('LibraryName',      'Lahore Gymkhana Club Library','string','Library display name'),
('CoverImagePath',   '~/Images/BookCovers/', 'string', 'Base path for book cover images'),
('AllowedImageTypes','jpg,jpeg,png,gif,webp', 'string','Allowed image extensions for covers');

PRINT 'GymkhanaLibraryDB created successfully.';
GO
