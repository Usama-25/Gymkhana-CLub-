-- =============================================================================
--  LAHORE GYMKHANA CLUB LIBRARY — FACILITY AND FINE DATABASE UPGRADES
-- =============================================================================
USE GymkhanaLibraryDB;
GO

-- ────────────────────────────────────────────────────────────
-- 1. Create Facilities Table
-- ────────────────────────────────────────────────────────────
IF OBJECT_ID('dbo.Facilities', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Facilities (
        FacilityID   INT            IDENTITY(1,1) PRIMARY KEY,
        FacilityName NVARCHAR(100)  NOT NULL UNIQUE,
        CostPerHour  DECIMAL(8,2)   NOT NULL DEFAULT 0.00 CHECK (CostPerHour >= 0),
        IsActive     BIT            NOT NULL DEFAULT 1
    );

    -- Seed default facilities
    INSERT INTO dbo.Facilities (FacilityName, CostPerHour, IsActive) VALUES
    (N'Seminar Room A', 150.00, 1),
    (N'Discussion Cubicle 1', 50.00, 1),
    (N'Multimedia/AV Lounge', 250.00, 1),
    (N'Quiet Study Room 3', 0.00, 1);

    PRINT 'Created Facilities table with seed data.';
END
ELSE
    PRINT 'Facilities table already exists — skipped.';
GO

-- ────────────────────────────────────────────────────────────
-- 2. Alter FineReasons Table
-- ────────────────────────────────────────────────────────────
IF COL_LENGTH('dbo.FineReasons', 'DefaultAmount') IS NULL
BEGIN
    ALTER TABLE dbo.FineReasons 
    ADD DefaultAmount DECIMAL(8,2) NOT NULL DEFAULT 0.00 CHECK (DefaultAmount >= 0);
    PRINT 'Added DefaultAmount column to FineReasons.';
END
ELSE
    PRINT 'DefaultAmount column already exists in FineReasons — skipped.';
GO

-- We need GO to split the batch so that the compiler recognizes that DefaultAmount has been added
-- before compiling the next statements that reference it.
-- ────────────────────────────────────────────────────────────
-- 3. Seed Default Fine Amounts
-- ────────────────────────────────────────────────────────────
IF COL_LENGTH('dbo.FineReasons', 'DefaultAmount') IS NOT NULL
BEGIN
    -- Update existing default amounts for seeded reasons if they are still 0
    UPDATE dbo.FineReasons SET DefaultAmount = 10.00 WHERE ReasonID = 1 AND DefaultAmount = 0.00;  -- Overdue
    UPDATE dbo.FineReasons SET DefaultAmount = 500.00 WHERE ReasonID = 2 AND DefaultAmount = 0.00; -- Lost Book
    UPDATE dbo.FineReasons SET DefaultAmount = 250.00 WHERE ReasonID = 3 AND DefaultAmount = 0.00; -- Damage
    PRINT 'Updated seed records in FineReasons.';
END
GO

-- ────────────────────────────────────────────────────────────
-- 4. Stored Procedures for Facilities
-- ────────────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE dbo.sp_GetFacilities
AS
BEGIN
    SET NOCOUNT ON;
    SELECT FacilityID, FacilityName, CostPerHour, IsActive 
    FROM dbo.Facilities 
    ORDER BY FacilityName;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_DefineFacility
    @FacilityID   INT            = NULL,
    @FacilityName NVARCHAR(100),
    @CostPerHour  DECIMAL(8,2),
    @IsActive     BIT            = 1,
    @Msg          NVARCHAR(200)  OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Clean inputs
    SET @FacilityName = LTRIM(RTRIM(@FacilityName));

    IF @FacilityName = ''
    BEGIN
        SET @Msg = 'Facility name cannot be empty.';
        RETURN;
    END

    IF @CostPerHour < 0
    BEGIN
        SET @Msg = 'Cost per hour cannot be negative.';
        RETURN;
    END

    -- Insert Mode
    IF @FacilityID IS NULL OR @FacilityID = 0
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Facilities WHERE FacilityName = @FacilityName)
        BEGIN
            SET @Msg = 'Facility with name "' + @FacilityName + '" already exists.';
            RETURN;
        END

        INSERT INTO dbo.Facilities (FacilityName, CostPerHour, IsActive)
        VALUES (@FacilityName, @CostPerHour, @IsActive);

        SET @Msg = 'Facility "' + @FacilityName + '" added successfully.';
    END
    -- Update Mode
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.Facilities WHERE FacilityID = @FacilityID)
        BEGIN
            SET @Msg = 'Facility not found.';
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM dbo.Facilities WHERE FacilityName = @FacilityName AND FacilityID <> @FacilityID)
        BEGIN
            SET @Msg = 'Another facility with name "' + @FacilityName + '" already exists.';
            RETURN;
        END

        UPDATE dbo.Facilities
        SET FacilityName = @FacilityName,
            CostPerHour  = @CostPerHour,
            IsActive     = @IsActive
        WHERE FacilityID = @FacilityID;

        SET @Msg = 'Facility updated successfully.';
    END
END;
GO

-- ────────────────────────────────────────────────────────────
-- 5. Stored Procedures for Fines & Reasons
-- ────────────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE dbo.sp_GetFineReasons
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ReasonID, ReasonName, DefaultAmount 
    FROM dbo.FineReasons 
    ORDER BY ReasonID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_DefineFineReason
    @ReasonID    TINYINT       = NULL,
    @ReasonName  VARCHAR(20),
    @DefaultAmount DECIMAL(8,2),
    @Msg         NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Clean inputs
    SET @ReasonName = LTRIM(RTRIM(@ReasonName));

    IF @ReasonName = ''
    BEGIN
        SET @Msg = 'Reason name cannot be empty.';
        RETURN;
    END

    IF @DefaultAmount < 0
    BEGIN
        SET @Msg = 'Default fine amount cannot be negative.';
        RETURN;
    END

    -- Insert Mode
    IF @ReasonID IS NULL OR @ReasonID = 0
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.FineReasons WHERE ReasonName = @ReasonName)
        BEGIN
            SET @Msg = 'Fine reason "' + @ReasonName + '" already exists.';
            RETURN;
        END

        -- Generate next TINYINT ID (max 255)
        DECLARE @NewID TINYINT = (SELECT ISNULL(MAX(ReasonID), 0) + 1 FROM dbo.FineReasons);

        INSERT INTO dbo.FineReasons (ReasonID, ReasonName, DefaultAmount)
        VALUES (@NewID, @ReasonName, @DefaultAmount);

        SET @Msg = 'Fine reason added successfully.';
    END
    -- Update Mode
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.FineReasons WHERE ReasonID = @ReasonID)
        BEGIN
            SET @Msg = 'Fine reason not found.';
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM dbo.FineReasons WHERE ReasonName = @ReasonName AND ReasonID <> @ReasonID)
        BEGIN
            SET @Msg = 'Another fine reason with name "' + @ReasonName + '" already exists.';
            RETURN;
        END

        UPDATE dbo.FineReasons
        SET ReasonName    = @ReasonName,
            DefaultAmount = @DefaultAmount
        WHERE ReasonID    = @ReasonID;

        SET @Msg = 'Fine reason updated successfully.';
    END
END;
GO

PRINT '=== Facility and Fine setup database upgrades completed successfully ===';
GO
