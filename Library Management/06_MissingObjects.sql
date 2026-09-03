-- =============================================================================
--  LAHORE GYMKHANA CLUB LIBRARY — MISSING DATABASE OBJECTS FIX
--  Run AFTER 01_Schema.sql and 02_Procedures.sql
--
--  This script creates:
--    1. Floors lookup table (referenced by Define.aspx / DBHelper.cs)
--    2. All 9 sp_Define* stored procedures used by the Define page
-- =============================================================================
USE GymkhanaLibraryDB;
GO

-- =============================================================================
--  1. Floors Lookup Table
--     Referenced by DBHelper.GetFloors() and Define.aspx.cs BindDropdowns()
-- =============================================================================
IF OBJECT_ID('dbo.Floors', 'U') IS NULL
BEGIN
    CREATE TABLE Floors (
        FloorNo     TINYINT      NOT NULL PRIMARY KEY,   -- 0=Ground, 1=First, etc.
        FloorName   NVARCHAR(50) NOT NULL UNIQUE
    );

    -- Seed default floors
    INSERT INTO Floors (FloorNo, FloorName) VALUES
    (0, 'Ground Floor'),
    (1, 'First Floor'),
    (2, 'Second Floor'),
    (3, 'Third Floor');

    PRINT 'Created Floors table with seed data.';
END
ELSE
    PRINT 'Floors table already exists — skipped.';
GO

-- =============================================================================
--  2. sp_DefineFloor — Add a new floor
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_DefineFloor
    @FloorNo    TINYINT,
    @FloorName  NVARCHAR(50),
    @Msg        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Floors WHERE FloorNo = @FloorNo)
    BEGIN
        SET @Msg = 'Floor number ' + CAST(@FloorNo AS VARCHAR) + ' already exists.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Floors WHERE FloorName = @FloorName)
    BEGIN
        SET @Msg = 'Floor name "' + @FloorName + '" already exists.';
        RETURN;
    END

    INSERT INTO Floors (FloorNo, FloorName)
    VALUES (@FloorNo, @FloorName);

    SET @Msg = 'Floor added successfully.';
END;
GO

-- =============================================================================
--  3. sp_DefineAuthor — Add a new author
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_DefineAuthor
    @FirstName    NVARCHAR(60),
    @LastName     NVARCHAR(60),
    @Nationality  VARCHAR(50)   = NULL,
    @Msg          NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Authors WHERE FirstName = @FirstName AND LastName = @LastName)
    BEGIN
        SET @Msg = 'Author "' + @FirstName + ' ' + @LastName + '" already exists.';
        RETURN;
    END

    INSERT INTO Authors (FirstName, LastName, Nationality)
    VALUES (@FirstName, @LastName, @Nationality);

    SET @Msg = 'Author added successfully.';
END;
GO

-- =============================================================================
--  4. sp_DefineStaffRole — Add a new staff role
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_DefineStaffRole
    @RoleName   VARCHAR(15),
    @Msg        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM StaffRoles WHERE RoleName = @RoleName)
    BEGIN
        SET @Msg = 'Staff Role "' + @RoleName + '" already exists.';
        RETURN;
    END

    DECLARE @NewID TINYINT = (SELECT ISNULL(MAX(RoleID), 0) + 1 FROM StaffRoles);

    INSERT INTO StaffRoles (RoleID, RoleName)
    VALUES (@NewID, @RoleName);

    SET @Msg = 'Staff Role added successfully.';
END;
GO

-- =============================================================================
--  5. sp_DefineCategory — Add a new book category
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_DefineCategory
    @CatCode      VARCHAR(8),
    @CatName      NVARCHAR(80),
    @ParentCatID  SMALLINT      = NULL,
    @Msg          NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Categories WHERE CatCode = @CatCode)
    BEGIN
        SET @Msg = 'Category code "' + @CatCode + '" already exists.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Categories WHERE CatName = @CatName)
    BEGIN
        SET @Msg = 'Category name "' + @CatName + '" already exists.';
        RETURN;
    END

    -- Convert 0 to NULL for parent category (UI sends 0 for top-level)
    IF @ParentCatID = 0 SET @ParentCatID = NULL;

    INSERT INTO Categories (CatCode, CatName, ParentCatID)
    VALUES (@CatCode, @CatName, @ParentCatID);

    SET @Msg = 'Category added successfully.';
END;
GO

-- =============================================================================
--  6. sp_DefinePublisher — Add a new publisher
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_DefinePublisher
    @PubName    NVARCHAR(120),
    @Country    VARCHAR(60)   = NULL,
    @Msg        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Publishers WHERE PubName = @PubName)
    BEGIN
        SET @Msg = 'Publisher "' + @PubName + '" already exists.';
        RETURN;
    END

    INSERT INTO Publishers (PubName, Country)
    VALUES (@PubName, @Country);

    SET @Msg = 'Publisher added successfully.';
END;
GO

-- =============================================================================
--  7. sp_DefineHall — Add a new library hall
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_DefineHall
    @HallCode   VARCHAR(10),
    @HallName   NVARCHAR(80),
    @FloorNo    TINYINT       = 0,
    @Msg        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Halls WHERE HallCode = @HallCode)
    BEGIN
        SET @Msg = 'Hall code "' + @HallCode + '" already exists.';
        RETURN;
    END

    INSERT INTO Halls (HallCode, HallName, FloorNo)
    VALUES (@HallCode, @HallName, @FloorNo);

    SET @Msg = 'Hall added successfully.';
END;
GO

-- =============================================================================
--  8. sp_DefineShelfUnit — Add a new shelf unit within a hall
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_DefineShelfUnit
    @HallID     SMALLINT,
    @UnitCode   VARCHAR(12),
    @UnitName   NVARCHAR(60)  = NULL,
    @Msg        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Halls WHERE HallID = @HallID AND IsActive = 1)
    BEGIN
        SET @Msg = 'Hall not found or inactive.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM ShelfUnits WHERE HallID = @HallID AND UnitCode = @UnitCode)
    BEGIN
        SET @Msg = 'Unit code "' + @UnitCode + '" already exists in this hall.';
        RETURN;
    END

    INSERT INTO ShelfUnits (HallID, UnitCode, UnitName)
    VALUES (@HallID, @UnitCode, @UnitName);

    SET @Msg = 'Shelf Unit added successfully.';
END;
GO

-- =============================================================================
--  9. sp_DefineRack — Add a new rack row within a shelf unit
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_DefineRack
    @UnitID     SMALLINT,
    @RackNo     TINYINT,
    @TotalSlots TINYINT       = 30,
    @SubjectTag NVARCHAR(60)  = NULL,
    @Msg        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM ShelfUnits WHERE UnitID = @UnitID)
    BEGIN
        SET @Msg = 'Shelf Unit not found.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Racks WHERE UnitID = @UnitID AND RackNo = @RackNo)
    BEGIN
        SET @Msg = 'Rack row ' + CAST(@RackNo AS VARCHAR) + ' already exists in this unit.';
        RETURN;
    END

    INSERT INTO Racks (UnitID, RackNo, TotalSlots, SubjectTag)
    VALUES (@UnitID, @RackNo, @TotalSlots, @SubjectTag);

    SET @Msg = 'Rack added successfully.';
END;
GO

-- =============================================================================
-- 10. sp_DefineLanguage — Add a new language
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_DefineLanguage
    @LangCode   CHAR(2),
    @LangName   VARCHAR(40),
    @Msg        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Languages WHERE LangCode = @LangCode)
    BEGIN
        SET @Msg = 'Language code "' + @LangCode + '" already exists.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Languages WHERE LangName = @LangName)
    BEGIN
        SET @Msg = 'Language name "' + @LangName + '" already exists.';
        RETURN;
    END

    DECLARE @NewID TINYINT = (SELECT ISNULL(MAX(LangID), 0) + 1 FROM Languages);

    INSERT INTO Languages (LangID, LangCode, LangName)
    VALUES (@NewID, @LangCode, @LangName);

    SET @Msg = 'Language added successfully.';
END;
GO

PRINT '=== All missing objects created successfully ===';
GO
