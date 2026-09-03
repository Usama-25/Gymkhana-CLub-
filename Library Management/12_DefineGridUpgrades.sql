-- =============================================================================
--  LAHORE GYMKHANA CLUB LIBRARY — CORE LOOKUPS SCHEMA & SP UPGRADES
-- =============================================================================
USE GymkhanaLibraryDB;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ────────────────────────────────────────────────────────────
-- 1. Add IsActive columns to lookup tables if they don't exist
-- ────────────────────────────────────────────────────────────
IF COL_LENGTH('dbo.StaffRoles', 'IsActive') IS NULL
BEGIN
    ALTER TABLE dbo.StaffRoles ADD IsActive BIT NOT NULL DEFAULT 1;
    PRINT 'Added IsActive to StaffRoles.';
END
GO

IF COL_LENGTH('dbo.ShelfUnits', 'IsActive') IS NULL
BEGIN
    ALTER TABLE dbo.ShelfUnits ADD IsActive BIT NOT NULL DEFAULT 1;
    PRINT 'Added IsActive to ShelfUnits.';
END
GO

IF COL_LENGTH('dbo.Racks', 'IsActive') IS NULL
BEGIN
    ALTER TABLE dbo.Racks ADD IsActive BIT NOT NULL DEFAULT 1;
    PRINT 'Added IsActive to Racks.';
END
GO

IF COL_LENGTH('dbo.Languages', 'IsActive') IS NULL
BEGIN
    ALTER TABLE dbo.Languages ADD IsActive BIT NOT NULL DEFAULT 1;
    PRINT 'Added IsActive to Languages.';
END
GO

IF COL_LENGTH('dbo.Floors', 'IsActive') IS NULL
BEGIN
    ALTER TABLE dbo.Floors ADD IsActive BIT NOT NULL DEFAULT 1;
    PRINT 'Added IsActive to Floors.';
END
GO

-- ────────────────────────────────────────────────────────────
-- 2. Stored Procedure Upgrades
-- ────────────────────────────────────────────────────────────

-- 2.1 Author Setup Procedure
CREATE OR ALTER PROCEDURE dbo.sp_DefineAuthor
    @AuthorID     SMALLINT      = NULL,
    @FirstName    NVARCHAR(60),
    @LastName     NVARCHAR(60),
    @Nationality  VARCHAR(50)   = NULL,
    @IsActive     BIT           = 1,
    @Msg          NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @FirstName = LTRIM(RTRIM(@FirstName));
    SET @LastName  = LTRIM(RTRIM(@LastName));

    IF @FirstName = '' OR @LastName = ''
    BEGIN
        SET @Msg = 'First Name and Last Name are required.';
        RETURN;
    END

    IF @AuthorID IS NULL OR @AuthorID = 0
    BEGIN
        IF EXISTS (SELECT 1 FROM Authors WHERE FirstName = @FirstName AND LastName = @LastName)
        BEGIN
            SET @Msg = 'Author "' + @FirstName + ' ' + @LastName + '" already exists.';
            RETURN;
        END

        INSERT INTO Authors (FirstName, LastName, Nationality, IsActive)
        VALUES (@FirstName, @LastName, @Nationality, @IsActive);

        SET @Msg = 'Author added successfully.';
    END
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Authors WHERE AuthorID = @AuthorID)
        BEGIN
            SET @Msg = 'Author not found.';
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Authors WHERE FirstName = @FirstName AND LastName = @LastName AND AuthorID <> @AuthorID)
        BEGIN
            SET @Msg = 'Another author named "' + @FirstName + ' ' + @LastName + '" already exists.';
            RETURN;
        END

        UPDATE Authors
        SET FirstName   = @FirstName,
            LastName    = @LastName,
            Nationality = @Nationality,
            IsActive    = @IsActive
        WHERE AuthorID  = @AuthorID;

        SET @Msg = 'Author updated successfully.';
    END
END;
GO

-- 2.2 Staff Role Setup Procedure
CREATE OR ALTER PROCEDURE dbo.sp_DefineStaffRole
    @RoleID     TINYINT       = NULL,
    @RoleName   VARCHAR(15),
    @IsActive   BIT           = 1,
    @Msg        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @RoleName = LTRIM(RTRIM(@RoleName));

    IF @RoleName = ''
    BEGIN
        SET @Msg = 'Staff Role name is required.';
        RETURN;
    END

    IF @RoleID IS NULL OR @RoleID = 0
    BEGIN
        IF EXISTS (SELECT 1 FROM StaffRoles WHERE RoleName = @RoleName)
        BEGIN
            SET @Msg = 'Staff Role "' + @RoleName + '" already exists.';
            RETURN;
        END

        DECLARE @NewID TINYINT = (SELECT ISNULL(MAX(RoleID), 0) + 1 FROM StaffRoles);

        INSERT INTO StaffRoles (RoleID, RoleName, IsActive)
        VALUES (@NewID, @RoleName, @IsActive);

        SET @Msg = 'Staff Role added successfully.';
    END
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM StaffRoles WHERE RoleID = @RoleID)
        BEGIN
            SET @Msg = 'Staff Role not found.';
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM StaffRoles WHERE RoleName = @RoleName AND RoleID <> @RoleID)
        BEGIN
            SET @Msg = 'Another Staff Role named "' + @RoleName + '" already exists.';
            RETURN;
        END

        UPDATE StaffRoles
        SET RoleName = @RoleName,
            IsActive = @IsActive
        WHERE RoleID = @RoleID;

        SET @Msg = 'Staff Role updated successfully.';
    END
END;
GO

-- 2.3 Category Setup Procedure
CREATE OR ALTER PROCEDURE dbo.sp_DefineCategory
    @CatID        SMALLINT      = NULL,
    @CatCode      VARCHAR(8),
    @CatName      NVARCHAR(80),
    @ParentCatID  SMALLINT      = NULL,
    @IsActive     BIT           = 1,
    @Msg          NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @CatCode = LTRIM(RTRIM(UPPER(@CatCode)));
    SET @CatName = LTRIM(RTRIM(@CatName));

    IF @CatCode = '' OR @CatName = ''
    BEGIN
        SET @Msg = 'Category Code and Name are required.';
        RETURN;
    END

    IF @ParentCatID = 0 SET @ParentCatID = NULL;

    IF @CatID IS NULL OR @CatID = 0
    BEGIN
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

        INSERT INTO Categories (CatCode, CatName, ParentCatID, IsActive)
        VALUES (@CatCode, @CatName, @ParentCatID, @IsActive);

        SET @Msg = 'Category added successfully.';
    END
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Categories WHERE CatID = @CatID)
        BEGIN
            SET @Msg = 'Category not found.';
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Categories WHERE CatCode = @CatCode AND CatID <> @CatID)
        BEGIN
            SET @Msg = 'Another category with code "' + @CatCode + '" already exists.';
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Categories WHERE CatName = @CatName AND CatID <> @CatID)
        BEGIN
            SET @Msg = 'Another category with name "' + @CatName + '" already exists.';
            RETURN;
        END

        UPDATE Categories
        SET CatCode     = @CatCode,
            CatName     = @CatName,
            ParentCatID = @ParentCatID,
            IsActive    = @IsActive
        WHERE CatID     = @CatID;

        SET @Msg = 'Category updated successfully.';
    END
END;
GO

-- 2.4 Publisher Setup Procedure
CREATE OR ALTER PROCEDURE dbo.sp_DefinePublisher
    @PubID      SMALLINT      = NULL,
    @PubName    NVARCHAR(120),
    @Country    VARCHAR(60)   = NULL,
    @IsActive   BIT           = 1,
    @Msg        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @PubName = LTRIM(RTRIM(@PubName));

    IF @PubName = ''
    BEGIN
        SET @Msg = 'Publisher Name is required.';
        RETURN;
    END

    IF @PubID IS NULL OR @PubID = 0
    BEGIN
        IF EXISTS (SELECT 1 FROM Publishers WHERE PubName = @PubName)
        BEGIN
            SET @Msg = 'Publisher "' + @PubName + '" already exists.';
            RETURN;
        END

        INSERT INTO Publishers (PubName, Country, IsActive)
        VALUES (@PubName, @Country, @IsActive);

        SET @Msg = 'Publisher added successfully.';
    END
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Publishers WHERE PubID = @PubID)
        BEGIN
            SET @Msg = 'Publisher not found.';
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Publishers WHERE PubName = @PubName AND PubID <> @PubID)
        BEGIN
            SET @Msg = 'Another publisher named "' + @PubName + '" already exists.';
            RETURN;
        END

        UPDATE Publishers
        SET PubName  = @PubName,
            Country  = @Country,
            IsActive = @IsActive
        WHERE PubID  = @PubID;

        SET @Msg = 'Publisher updated successfully.';
    END
END;
GO

-- 2.5 Hall Setup Procedure
CREATE OR ALTER PROCEDURE dbo.sp_DefineHall
    @HallID     SMALLINT      = NULL,
    @HallCode   VARCHAR(10),
    @HallName   NVARCHAR(80),
    @FloorNo    TINYINT       = 0,
    @IsActive   BIT           = 1,
    @Msg        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @HallCode = LTRIM(RTRIM(@HallCode));
    SET @HallName = LTRIM(RTRIM(@HallName));

    IF @HallCode = '' OR @HallName = ''
    BEGIN
        SET @Msg = 'Hall Code and Name are required.';
        RETURN;
    END

    IF @HallID IS NULL OR @HallID = 0
    BEGIN
        IF EXISTS (SELECT 1 FROM Halls WHERE HallCode = @HallCode)
        BEGIN
            SET @Msg = 'Hall code "' + @HallCode + '" already exists.';
            RETURN;
        END

        INSERT INTO Halls (HallCode, HallName, FloorNo, IsActive)
        VALUES (@HallCode, @HallName, @FloorNo, @IsActive);

        SET @Msg = 'Hall added successfully.';
    END
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Halls WHERE HallID = @HallID)
        BEGIN
            SET @Msg = 'Hall not found.';
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Halls WHERE HallCode = @HallCode AND HallID <> @HallID)
        BEGIN
            SET @Msg = 'Another hall with code "' + @HallCode + '" already exists.';
            RETURN;
        END

        UPDATE Halls
        SET HallCode = @HallCode,
            HallName = @HallName,
            FloorNo  = @FloorNo,
            IsActive = @IsActive
        WHERE HallID = @HallID;

        SET @Msg = 'Hall updated successfully.';
    END
END;
GO

-- 2.6 Shelf Unit Setup Procedure
CREATE OR ALTER PROCEDURE dbo.sp_DefineShelfUnit
    @UnitID     SMALLINT      = NULL,
    @HallID     SMALLINT,
    @UnitCode   VARCHAR(12),
    @UnitName   NVARCHAR(60)  = NULL,
    @IsActive   BIT           = 1,
    @Msg        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @UnitCode = LTRIM(RTRIM(@UnitCode));

    IF @UnitCode = ''
    BEGIN
        SET @Msg = 'Shelf Unit Code is required.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Halls WHERE HallID = @HallID)
    BEGIN
        SET @Msg = 'Hall wing not found.';
        RETURN;
    END

    IF @UnitID IS NULL OR @UnitID = 0
    BEGIN
        IF EXISTS (SELECT 1 FROM ShelfUnits WHERE HallID = @HallID AND UnitCode = @UnitCode)
        BEGIN
            SET @Msg = 'Unit code "' + @UnitCode + '" already exists in this hall wing.';
            RETURN;
        END

        INSERT INTO ShelfUnits (HallID, UnitCode, UnitName, IsActive)
        VALUES (@HallID, @UnitCode, @UnitName, @IsActive);

        SET @Msg = 'Shelf Unit added successfully.';
    END
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM ShelfUnits WHERE UnitID = @UnitID)
        BEGIN
            SET @Msg = 'Shelf Unit not found.';
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM ShelfUnits WHERE HallID = @HallID AND UnitCode = @UnitCode AND UnitID <> @UnitID)
        BEGIN
            SET @Msg = 'Another unit with code "' + @UnitCode + '" already exists in this hall wing.';
            RETURN;
        END

        UPDATE ShelfUnits
        SET HallID   = @HallID,
            UnitCode = @UnitCode,
            UnitName = @UnitName,
            IsActive = @IsActive
        WHERE UnitID = @UnitID;

        SET @Msg = 'Shelf Unit updated successfully.';
    END
END;
GO

-- 2.7 Rack Setup Procedure
CREATE OR ALTER PROCEDURE dbo.sp_DefineRack
    @RackID     SMALLINT      = NULL,
    @UnitID     SMALLINT,
    @RackNo     TINYINT,
    @TotalSlots TINYINT       = 30,
    @SubjectTag NVARCHAR(60)  = NULL,
    @IsActive   BIT           = 1,
    @Msg        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM ShelfUnits WHERE UnitID = @UnitID)
    BEGIN
        SET @Msg = 'Shelf Unit not found.';
        RETURN;
    END

    IF @TotalSlots < 1 OR @TotalSlots > 100
    BEGIN
        SET @Msg = 'Total slots must be between 1 and 100.';
        RETURN;
    END

    IF @RackID IS NULL OR @RackID = 0
    BEGIN
        IF EXISTS (SELECT 1 FROM Racks WHERE UnitID = @UnitID AND RackNo = @RackNo)
        BEGIN
            SET @Msg = 'Rack row ' + CAST(@RackNo AS VARCHAR) + ' already exists in this shelf unit.';
            RETURN;
        END

        INSERT INTO Racks (UnitID, RackNo, TotalSlots, SubjectTag, IsActive)
        VALUES (@UnitID, @RackNo, @TotalSlots, @SubjectTag, @IsActive);

        SET @Msg = 'Rack added successfully.';
    END
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Racks WHERE RackID = @RackID)
        BEGIN
            SET @Msg = 'Rack row not found.';
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Racks WHERE UnitID = @UnitID AND RackNo = @RackNo AND RackID <> @RackID)
        BEGIN
            SET @Msg = 'Another rack row ' + CAST(@RackNo AS VARCHAR) + ' already exists in this shelf unit.';
            RETURN;
        END

        UPDATE Racks
        SET UnitID     = @UnitID,
            RackNo     = @RackNo,
            TotalSlots = @TotalSlots,
            SubjectTag = @SubjectTag,
            IsActive   = @IsActive
        WHERE RackID   = @RackID;

        SET @Msg = 'Rack updated successfully.';
    END
END;
GO

-- 2.8 Language Setup Procedure
CREATE OR ALTER PROCEDURE dbo.sp_DefineLanguage
    @LangID     TINYINT       = NULL,
    @LangCode   CHAR(2),
    @LangName   VARCHAR(40),
    @IsActive   BIT           = 1,
    @Msg        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @LangCode = LTRIM(RTRIM(LOWER(@LangCode)));
    SET @LangName = LTRIM(RTRIM(@LangName));

    IF LEN(@LangCode) <> 2 OR @LangName = ''
    BEGIN
        SET @Msg = 'Language Code (2-letters) and Language Name are required.';
        RETURN;
    END

    IF @LangID IS NULL OR @LangID = 0
    BEGIN
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

        INSERT INTO Languages (LangID, LangCode, LangName, IsActive)
        VALUES (@NewID, @LangCode, @LangName, @IsActive);

        SET @Msg = 'Language added successfully.';
    END
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Languages WHERE LangID = @LangID)
        BEGIN
            SET @Msg = 'Language not found.';
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Languages WHERE LangCode = @LangCode AND LangID <> @LangID)
        BEGIN
            SET @Msg = 'Another language with code "' + @LangCode + '" already exists.';
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Languages WHERE LangName = @LangName AND LangID <> @LangID)
        BEGIN
            SET @Msg = 'Another language named "' + @LangName + '" already exists.';
            RETURN;
        END

        UPDATE Languages
        SET LangCode = @LangCode,
            LangName = @LangName,
            IsActive = @IsActive
        WHERE LangID = @LangID;

        SET @Msg = 'Language updated successfully.';
    END
END;
GO

-- 2.9 Floor Setup Procedure
CREATE OR ALTER PROCEDURE dbo.sp_DefineFloor
    @FloorNo    TINYINT,
    @FloorName  NVARCHAR(50),
    @IsActive   BIT           = 1,
    @Msg        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @FloorName = LTRIM(RTRIM(@FloorName));

    IF @FloorName = ''
    BEGIN
        SET @Msg = 'Floor Name is required.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Floors WHERE FloorNo = @FloorNo)
    BEGIN
        -- Existing FloorNo - treat as UPDATE
        UPDATE Floors
        SET FloorName = @FloorName,
            IsActive  = @IsActive
        WHERE FloorNo = @FloorNo;

        SET @Msg = 'Floor updated successfully.';
    END
    ELSE
    BEGIN
        -- New FloorNo - treat as INSERT
        IF EXISTS (SELECT 1 FROM Floors WHERE FloorName = @FloorName)
        BEGIN
            SET @Msg = 'Floor name "' + @FloorName + '" already exists.';
            RETURN;
        END

        INSERT INTO Floors (FloorNo, FloorName, IsActive)
        VALUES (@FloorNo, @FloorName, @IsActive);

        SET @Msg = 'Floor added successfully.';
    END
END;
GO

PRINT '=== Lookup Tables schema modifications and stored procedures upgraded successfully ===';
GO
