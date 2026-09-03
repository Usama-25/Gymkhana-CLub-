-- =============================================================================
--  LAHORE GYMKHANA CLUB LIBRARY — SEED DATA  v2.0
--  Run AFTER 01_Schema.sql and 02_Procedures.sql
-- =============================================================================
USE GymkhanaLibraryDB;
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================================================
--  Physical Layout
-- =============================================================================
INSERT INTO Halls (HallCode, HallName, FloorNo) VALUES
('MAIN', 'Main Reading Hall',      0),
('REF',  'Reference Section',      0),
('PER',  'Periodicals & Journals', 1);

INSERT INTO ShelfUnits (HallID, UnitCode, UnitName) VALUES
(1,'A-01','Fiction - Classics & Pakistani'),
(1,'A-02','Fiction - Modern & International'),
(1,'B-01','Non-Fiction & Biography'),
(2,'R-01','Reference & Encyclopedias'),
(3,'P-01','Magazines & Journals');

INSERT INTO Racks (UnitID, RackNo, TotalSlots, SubjectTag) VALUES
(1,1,25,'Pakistani Fiction'),
(1,2,25,'Classic Fiction'),
(1,3,25,'Urdu Literature'),
(2,1,30,'Contemporary Fiction'),
(2,2,30,'Science Fiction & Fantasy'),
(3,1,30,'Biography & Memoir'),
(3,2,30,'History - South Asia'),
(3,3,30,'History - World'),
(3,4,30,'Politics & Economics'),
(4,1,20,'Encyclopedias'),
(4,2,20,'Dictionaries & Atlases');

-- =============================================================================
--  Catalogue Reference Data
-- =============================================================================
INSERT INTO Categories (CatCode, CatName) VALUES
('FIC',  'Fiction'),
('NFIC', 'Non-Fiction'),
('HIS',  'History'),
('BIO',  'Biography & Memoir'),
('SCI',  'Science & Technology'),
('POL',  'Politics & Law'),
('REL',  'Religion & Philosophy'),
('URD',  'Urdu Literature'),
('REF',  'Reference');

-- Sub-categories
INSERT INTO Categories (CatCode, CatName, ParentCatID) VALUES
('FIC-PAK','Pakistani Fiction',  1),
('FIC-CLS','Classic Fiction',    1),
('HIS-SA', 'History: South Asia',3);

INSERT INTO Publishers (PubName, Country) VALUES
('Oxford University Press',   'UK'),
('Penguin Books',             'UK'),
('HarperCollins',             'USA'),
('Ferozsons (Pvt) Ltd',       'Pakistan'),
('Sang-e-Meel Publications',  'Pakistan'),
('Vanguard Books',            'Pakistan');

INSERT INTO Authors (FirstName, LastName, Nationality) VALUES
('Bapsi',       'Sidhwa',   'Pakistani'),
('Mohsin',      'Hamid',    'Pakistani'),
('Kamila',      'Shamsie',  'Pakistani'),
('Intizar',     'Husain',   'Pakistani'),
('George',      'Orwell',   'British'),
('Jane',        'Austen',   'British'),
('Yuval Noah',  'Harari',   'Israeli'),
('Nadeem',      'Aslam',    'British-Pakistani');

-- =============================================================================
--  Staff (Removed - Auth and Staff profiles are managed in User_management database)
-- =============================================================================

-- =============================================================================
--  Books  (ISBN-13 values are real, check-digit valid)
-- =============================================================================
DECLARE @R INT;
DECLARE @Msg VARCHAR(200), @NewID INT;

EXEC dbo.sp_SaveBook
    @ISBN13='9780140449327', @ISBN10='0140449329',
    @Title=N'Ice-Candy-Man',
    @SubTitle=N'A Novel of Partition',
    @CatID=10,  -- FIC-PAK
    @PubID=2,   -- Penguin
    @LangID=1, @PubYear=1988, @Edition='Penguin Classics',
    @PageCount=310, @ClassNo='823.914',
    @Tags='partition,lahore,1947,parsee,pakistan',
    @Synopsis=N'Seen through the eyes of a Parsee child in Lahore, this novel captures the horrors of Partition.',
    @CoverFile='9780140449327.jpg', @StaffID=1,
    @NewBookID=@NewID OUTPUT, @Msg=@Msg OUTPUT;
PRINT 'Book 1: ' + @Msg;

EXEC dbo.sp_SaveBook
    @ISBN13='9781594487347',
    @Title=N'The Reluctant Fundamentalist',
    @CatID=10, @PubID=3, @LangID=1, @PubYear=2007,
    @PageCount=184, @ClassNo='823.92',
    @Tags='pakistan,america,9/11,identity,lahore',
    @Synopsis=N'A Pakistani man tells a stranger in Lahore of his disillusionment with America after 9/11.',
    @CoverFile='9781594487347.jpg', @StaffID=1,
    @NewBookID=@NewID OUTPUT, @Msg=@Msg OUTPUT;
PRINT 'Book 2: ' + @Msg;

EXEC dbo.sp_SaveBook
    @ISBN13='9780451524935',
    @Title=N'Nineteen Eighty-Four',
    @CatID=11, @PubID=2, @LangID=1, @PubYear=1949, @Edition='Signet Classic',
    @PageCount=328, @Tags='dystopia,totalitarianism,politics,classic',
    @CoverFile='9780451524935.jpg', @StaffID=1,
    @NewBookID=@NewID OUTPUT, @Msg=@Msg OUTPUT;
PRINT 'Book 3: ' + @Msg;

EXEC dbo.sp_SaveBook
    @ISBN13='9780062316097',
    @Title=N'Sapiens',
    @SubTitle=N'A Brief History of Humankind',
    @CatID=3, @PubID=3, @LangID=1, @PubYear=2015,
    @PageCount=443, @Tags='history,humanity,evolution,anthropology',
    @CoverFile='9780062316097.jpg', @StaffID=1,
    @NewBookID=@NewID OUTPUT, @Msg=@Msg OUTPUT;
PRINT 'Book 4: ' + @Msg;

EXEC dbo.sp_SaveBook
    @ISBN13='9780143106586',
    @Title=N'Home Fire',
    @CatID=10, @PubID=2, @LangID=1, @PubYear=2017,
    @PageCount=272, @Tags='pakistan,identity,family,isis,british',
    @CoverFile='9780143106586.jpg', @StaffID=1,
    @NewBookID=@NewID OUTPUT, @Msg=@Msg OUTPUT;
PRINT 'Book 5: ' + @Msg;

-- Link Authors to Books
INSERT INTO BookAuthors (BookID, AuthorID, RoleID, SortOrder) VALUES
(1,1,1,1),  -- Ice-Candy-Man → Sidhwa
(2,2,1,1),  -- Reluctant Fundamentalist → Hamid
(3,5,1,1),  -- 1984 → Orwell
(4,7,1,1),  -- Sapiens → Harari
(5,3,1,1);  -- Home Fire → Shamsie

-- =============================================================================
--  Physical Copies
-- =============================================================================
DECLARE @CopyID INT; DECLARE @Barcode CHAR(17);

-- Ice-Candy-Man: 2 copies on Rack 1 (Pakistani Fiction)
EXEC dbo.sp_AddCopy @BookID=1, @RackID=1, @CondID=2, @AcqCost=850,
     @CopyID=@CopyID OUTPUT, @Barcode=@Barcode OUTPUT, @Msg=@Msg OUTPUT;
PRINT 'Copy: ' + @Barcode + ' | ' + @Msg;

EXEC dbo.sp_AddCopy @BookID=1, @RackID=1, @CondID=3, @AcqCost=850,
     @CopyID=@CopyID OUTPUT, @Barcode=@Barcode OUTPUT, @Msg=@Msg OUTPUT;
PRINT 'Copy: ' + @Barcode + ' | ' + @Msg;

-- Reluctant Fundamentalist: 2 copies
EXEC dbo.sp_AddCopy @BookID=2, @RackID=1, @CondID=1, @AcqCost=950,
     @CopyID=@CopyID OUTPUT, @Barcode=@Barcode OUTPUT, @Msg=@Msg OUTPUT;
PRINT 'Copy: ' + @Barcode + ' | ' + @Msg;

EXEC dbo.sp_AddCopy @BookID=2, @RackID=4, @CondID=2, @AcqCost=950,
     @CopyID=@CopyID OUTPUT, @Barcode=@Barcode OUTPUT, @Msg=@Msg OUTPUT;
PRINT 'Copy: ' + @Barcode + ' | ' + @Msg;

-- 1984
EXEC dbo.sp_AddCopy @BookID=3, @RackID=2, @CondID=3, @AcqCost=700,
     @CopyID=@CopyID OUTPUT, @Barcode=@Barcode OUTPUT, @Msg=@Msg OUTPUT;
PRINT 'Copy: ' + @Barcode + ' | ' + @Msg;

-- Sapiens: 2 copies
EXEC dbo.sp_AddCopy @BookID=4, @RackID=6, @CondID=1, @AcqCost=1200,
     @CopyID=@CopyID OUTPUT, @Barcode=@Barcode OUTPUT, @Msg=@Msg OUTPUT;
PRINT 'Copy: ' + @Barcode + ' | ' + @Msg;

EXEC dbo.sp_AddCopy @BookID=4, @RackID=6, @CondID=2, @AcqCost=1200,
     @CopyID=@CopyID OUTPUT, @Barcode=@Barcode OUTPUT, @Msg=@Msg OUTPUT;
PRINT 'Copy: ' + @Barcode + ' | ' + @Msg;

-- Home Fire
EXEC dbo.sp_AddCopy @BookID=5, @RackID=1, @CondID=1, @AcqCost=1050,
     @CopyID=@CopyID OUTPUT, @Barcode=@Barcode OUTPUT, @Msg=@Msg OUTPUT;
PRINT 'Copy: ' + @Barcode + ' | ' + @Msg;

-- =============================================================================
--  Members
-- =============================================================================
INSERT INTO Members (MembershipNo, FullName, CNIC, Phone, Email, MTypeID) VALUES
('LGC-2024-0001', N'Ahmed Raza Khan',        '42101-1234567-1','0300-1234567','ahmed@email.com',2),
('LGC-2024-0002', N'Sara Malik',             NULL,            '0321-9876543', NULL,            1),
('LGC-2024-0003', N'Col (R) Tariq Mehmood',  '42301-7654321-3','0333-1122334', NULL,           5),
('LGC-2024-0004', N'Ayesha Farooq',          '35202-8765432-2','0311-5544332','ayesha@g.com', 3);

PRINT '=== Seed data inserted successfully ===';
GO
