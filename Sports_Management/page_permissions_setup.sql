-- ==============================================================
-- Page Permissions Setup Script
-- ==============================================================

USE [SportsModuleDB]
GO

-- 1. Create UserPages table if it doesn't exist
IF OBJECT_ID('UserPages', 'U') IS NULL
BEGIN
    CREATE TABLE UserPages (
        Emp_ID INT FOREIGN KEY REFERENCES SystemUsers(Emp_ID) ON DELETE CASCADE,
        PageName NVARCHAR(100) NOT NULL,
        PRIMARY KEY (Emp_ID, PageName)
    );
END
GO

-- 2. Alter stored procedure sp_GetUsers to include AllowedPages
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
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS AllowedSports,
        STUFF((
            SELECT ', ' + REPLACE(up.PageName, '.aspx', '')
            FROM UserPages up
            WHERE up.Emp_ID = u.Emp_ID 
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS AllowedPages
    FROM SystemUsers u
    ORDER BY u.Username;
END
GO

-- 3. Seed Page Permissions for existing users
DECLARE @AdminEmpID INT;
SELECT @AdminEmpID = Emp_ID FROM SystemUsers WHERE Username = 'admin';

IF @AdminEmpID IS NOT NULL
BEGIN
    DELETE FROM UserPages WHERE Emp_ID = @AdminEmpID;
    INSERT INTO UserPages (Emp_ID, PageName) VALUES 
    (@AdminEmpID, 'MemberSubscriptions.aspx'),
    (@AdminEmpID, 'SubscriptionDefinition.aspx'),
    (@AdminEmpID, 'DiscountPolicy.aspx'),
    (@AdminEmpID, 'SportsDefinition.aspx'),
    (@AdminEmpID, 'ManageSportsCard.aspx'),
    (@AdminEmpID, 'IndividualMemberCheck.aspx'),
    (@AdminEmpID, 'DailyPOS.aspx'),
    (@AdminEmpID, 'MemberLedger.aspx'),
    (@AdminEmpID, 'PaymentProcess.aspx'),
    (@AdminEmpID, 'FacilityAccess.aspx'),
    (@AdminEmpID, 'ManagePermissions.aspx'),
    (@AdminEmpID, 'ReportMemberSubscriptions.aspx'),
    (@AdminEmpID, 'ReportIndividualMember.aspx'),
    (@AdminEmpID, 'ReportAccessLogs.aspx');
END

DECLARE @User1EmpID INT;
SELECT @User1EmpID = Emp_ID FROM SystemUsers WHERE Username = 'user1';

IF @User1EmpID IS NOT NULL
BEGIN
    DELETE FROM UserPages WHERE Emp_ID = @User1EmpID;
    INSERT INTO UserPages (Emp_ID, PageName) VALUES 
    (@User1EmpID, 'MemberSubscriptions.aspx'),
    (@User1EmpID, 'IndividualMemberCheck.aspx'),
    (@User1EmpID, 'ManageSportsCard.aspx');
END

DECLARE @User2EmpID INT;
SELECT @User2EmpID = Emp_ID FROM SystemUsers WHERE Username = 'user2';

IF @User2EmpID IS NOT NULL
BEGIN
    DELETE FROM UserPages WHERE Emp_ID = @User2EmpID;
    INSERT INTO UserPages (Emp_ID, PageName) VALUES 
    (@User2EmpID, 'DailyPOS.aspx'),
    (@User2EmpID, 'IndividualMemberCheck.aspx');
END
GO
