-- ==============================================================
-- Roles & Rights Permissions and SubDeptID Database Setup Script
-- ==============================================================

USE [SportsModuleDB]
GO

-- 1. Alter Sports Table to add SubDeptID if it does not exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Sports') AND name = 'SubDeptID')
BEGIN
    ALTER TABLE Sports ADD SubDeptID INT NULL;
END
GO

-- 2. Create SystemUsers and UserSports tables
IF OBJECT_ID('UserSports', 'U') IS NOT NULL DROP TABLE UserSports;
IF OBJECT_ID('SystemUsers', 'U') IS NOT NULL DROP TABLE SystemUsers;
GO

CREATE TABLE SystemUsers (
    Emp_ID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(100) UNIQUE NOT NULL,
    Password NVARCHAR(100) NOT NULL, -- Stored as plain text for simple verification
    Role NVARCHAR(50) NOT NULL,      -- 'Admin' or 'Operator'
    CreatedOn DATETIME DEFAULT GETDATE()
);

CREATE TABLE UserSports (
    Emp_ID INT FOREIGN KEY REFERENCES SystemUsers(Emp_ID) ON DELETE CASCADE,
    SportID INT FOREIGN KEY REFERENCES Sports(SportID) ON DELETE CASCADE,
    PRIMARY KEY (Emp_ID, SportID)
);
GO

-- 3. Seed Default Users
INSERT INTO SystemUsers (Username, Password, Role) VALUES 
('admin', 'admin123', 'Admin'),
('user1', 'op123', 'Operator'),
('user2', 'op456', 'Operator');

-- Link user1 to Cricket and Tennis, user2 to Gym
INSERT INTO UserSports (Emp_ID, SportID)
SELECT u.Emp_ID, s.SportID 
FROM SystemUsers u, Sports s 
WHERE u.Username = 'user1' AND s.SportName IN ('Cricket', 'Tennis');

INSERT INTO UserSports (Emp_ID, SportID)
SELECT u.Emp_ID, s.SportID 
FROM SystemUsers u, Sports s 
WHERE u.Username = 'user2' AND s.SportName IN ('Gym');
GO

-- 4. Stored Procedures for Sports (Modified to handle SubDeptID)
IF OBJECT_ID('sp_GetSports', 'P') IS NOT NULL DROP PROCEDURE sp_GetSports;
GO
CREATE PROCEDURE [sp_GetSports]
AS
BEGIN
    SELECT SportID, SportName, Description, Status, SubDeptID
    FROM Sports
    ORDER BY SportName;
END
GO

IF OBJECT_ID('sp_InsertSport', 'P') IS NOT NULL DROP PROCEDURE sp_InsertSport;
GO
CREATE PROCEDURE [sp_InsertSport]
    @SportName NVARCHAR(100),
    @Description NVARCHAR(255),
    @Status BIT,
    @SubDeptID INT = NULL,
    @MonthlyFee DECIMAL(18,2) = 0,
    @ContinuousFee DECIMAL(18,2) = 0,
    @PolicyIDs NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Sports (SportName, Description, Status, SubDeptID, MonthlyFee, ContinuousFee, PolicyIDs)
    VALUES (@SportName, @Description, @Status, @SubDeptID, @MonthlyFee, @ContinuousFee, @PolicyIDs);
END
GO

IF OBJECT_ID('sp_UpdateSport', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateSport;
GO
CREATE PROCEDURE [sp_UpdateSport]
    @SportID INT,
    @SportName NVARCHAR(100),
    @Description NVARCHAR(255),
    @Status BIT,
    @SubDeptID INT = NULL,
    @MonthlyFee DECIMAL(18,2) = 0,
    @ContinuousFee DECIMAL(18,2) = 0,
    @PolicyIDs NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Sports
    SET SportName = @SportName,
        Description = @Description,
        Status = @Status,
        SubDeptID = @SubDeptID,
        MonthlyFee = @MonthlyFee,
        ContinuousFee = @ContinuousFee,
        PolicyIDs = @PolicyIDs
    WHERE SportID = @SportID;
END
GO

-- 5. Alter sp_GetFamilySubscriptions to include SportID (used for operator filtering)
IF OBJECT_ID('sp_GetFamilySubscriptions', 'P') IS NOT NULL DROP PROCEDURE sp_GetFamilySubscriptions;
GO
CREATE PROCEDURE sp_GetFamilySubscriptions 
    @MemberID INT 
AS 
BEGIN 
    SELECT 
        ms.MemberSubID, 
        CASE WHEN ISNULL(ms.DependentMemberNo, '') = '' THEN 'Main Member' ELSE ISNULL(ms.DependentName, ms.DependentMemberNo) END AS PersonName, 
        CASE WHEN ISNULL(ms.DependentMemberNo, '') = '' THEN mp.MemberNo COLLATE DATABASE_DEFAULT ELSE ms.DependentMemberNo COLLATE DATABASE_DEFAULT END AS MemberNo, 
        CASE WHEN ISNULL(ms.DependentMemberNo, '') = '' THEN mp.Status COLLATE DATABASE_DEFAULT ELSE ISNULL((SELECT TOP 1 RecordStatus FROM MemberShip.dbo.MemberSpouses WHERE MembershipNo COLLATE DATABASE_DEFAULT = ms.DependentMemberNo COLLATE DATABASE_DEFAULT), (SELECT TOP 1 RecordStatus FROM MemberShip.dbo.MemberChildren WHERE MembershipNo COLLATE DATABASE_DEFAULT = ms.DependentMemberNo COLLATE DATABASE_DEFAULT)) COLLATE DATABASE_DEFAULT END AS MemberStatus, 
        CASE WHEN ISNULL(ms.DependentMemberNo, '') = '' THEN 'Self' ELSE ISNULL(ms.DependentRelation, 'Dependent') END AS Relation, 
        sp.SportName, 
        sub.PackageName, 
        sub.SubscriptionType, 
        ms.IsActive,
        sp.SportID
    FROM MemberSubscriptions ms 
    INNER JOIN Subscriptions sub ON ms.SubscriptionID = sub.SubscriptionID 
    INNER JOIN Sports sp ON sub.SportID = sp.SportID 
    INNER JOIN MemberShip.dbo.MemberProfile mp ON ms.MemberID = mp.MemberID 
    WHERE ms.MemberID = @MemberID 
      AND ms.IsActive = 1 
    ORDER BY Relation DESC, PersonName; 
END;
GO

-- 6. New Stored Procedures for System Users Management
IF OBJECT_ID('sp_GetUsers', 'P') IS NOT NULL DROP PROCEDURE sp_GetUsers;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sp_GetUsers
AS
BEGIN
    SELECT 
        u.Emp_ID, 
        u.Username, 
        u.Password,
        u.Role, 
        u.CreatedOn,
        STUFF((
            SELECT ', ' + s.SportName 
            FROM UserSports us 
            INNER JOIN Sports s ON us.SportID = s.SportID 
            WHERE us.Emp_ID = u.Emp_ID 
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS AllowedSports
    FROM SystemUsers u
    ORDER BY u.Username;
END
GO

IF OBJECT_ID('sp_InsertUser', 'P') IS NOT NULL DROP PROCEDURE sp_InsertUser;
GO
CREATE PROCEDURE sp_InsertUser
    @Username NVARCHAR(100),
    @Password NVARCHAR(100),
    @Role NVARCHAR(50)
AS
BEGIN
    INSERT INTO SystemUsers (Username, Password, Role)
    VALUES (@Username, @Password, @Role);
    SELECT SCOPE_IDENTITY() AS Emp_ID;
END
GO

IF OBJECT_ID('sp_UpdateUser', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateUser;
GO
CREATE PROCEDURE sp_UpdateUser
    @Emp_ID INT,
    @Username NVARCHAR(100),
    @Password NVARCHAR(100),
    @Role NVARCHAR(50)
AS
BEGIN
    IF @Password IS NOT NULL AND @Password <> ''
    BEGIN
        UPDATE SystemUsers
        SET Username = @Username,
            Password = @Password,
            Role = @Role
        WHERE Emp_ID = @Emp_ID;
    END
    ELSE
    BEGIN
        UPDATE SystemUsers
        SET Username = @Username,
            Role = @Role
        WHERE Emp_ID = @Emp_ID;
    END
END
GO
