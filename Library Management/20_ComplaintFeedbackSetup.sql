-- =========================================================================
-- Migration: 20_ComplaintFeedbackSetup.sql
-- Description: Creates Complaint and Feedback tables and stored procedures.
--              Integrates with BasicDataInfo for departments and subdepartments.
-- =========================================================================

USE GymkhanaLibraryDB;
GO

-- 1. Create Tables
IF OBJECT_ID('dbo.FeedbackSubmission', 'U') IS NOT NULL
    DROP TABLE dbo.FeedbackSubmission;
GO

IF OBJECT_ID('dbo.FeedbackDefinition', 'U') IS NOT NULL
    DROP TABLE dbo.FeedbackDefinition;
GO

IF OBJECT_ID('dbo.Complaint', 'U') IS NOT NULL
    DROP TABLE dbo.Complaint;
GO

CREATE TABLE dbo.FeedbackDefinition (
    DefinitionID INT IDENTITY(1,1) PRIMARY KEY,
    DeptID INT NULL, -- References BasicDataInfo.dbo.Department(Dept_ID)
    SubDeptID INT NULL, -- References BasicDataInfo.dbo.SubDepartment(SubDept_Id)
    FeedbackTitle VARCHAR(150) NOT NULL,
    Description VARCHAR(500) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.FeedbackSubmission (
    SubmissionID INT IDENTITY(1,1) PRIMARY KEY,
    DefinitionID INT NOT NULL FOREIGN KEY REFERENCES dbo.FeedbackDefinition(DefinitionID),
    MemberNo VARCHAR(50) NULL, -- Optional gymkhana member number
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comments VARCHAR(MAX) NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.Complaint (
    ComplaintID INT IDENTITY(1,1) PRIMARY KEY,
    DeptID INT NULL, -- References BasicDataInfo.dbo.Department(Dept_ID)
    SubDeptID INT NULL, -- References BasicDataInfo.dbo.SubDepartment(SubDept_Id)
    MemberNo VARCHAR(50) NULL,
    ComplaintSubject VARCHAR(150) NOT NULL,
    ComplaintDetail VARCHAR(MAX) NOT NULL,
    Status VARCHAR(50) NOT NULL DEFAULT 'Pending', -- Pending, In Progress, Resolved, Closed
    Remarks VARCHAR(MAX) NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDate DATETIME NULL
);
GO


-- 2. Stored Procedures

-- Get Feedback Definitions
IF OBJECT_ID('dbo.sp_GetFeedbackDefinitions', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetFeedbackDefinitions;
GO
CREATE PROCEDURE dbo.sp_GetFeedbackDefinitions
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        fd.DefinitionID,
        fd.DeptID,
        d.Dept_Name AS DepartmentName,
        fd.SubDeptID,
        sd.SubDept_Name AS SubDepartmentName,
        fd.FeedbackTitle,
        fd.Description,
        fd.IsActive,
        fd.CreatedDate
    FROM dbo.FeedbackDefinition fd
    LEFT JOIN BasicDataInfo.dbo.Department d ON fd.DeptID = d.Dept_ID
    LEFT JOIN BasicDataInfo.dbo.SubDepartment sd ON fd.SubDeptID = sd.SubDept_Id
    ORDER BY fd.DefinitionID DESC;
END;
GO

-- Save/Update Feedback Definition
IF OBJECT_ID('dbo.sp_SaveFeedbackDefinition', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SaveFeedbackDefinition;
GO
CREATE PROCEDURE dbo.sp_SaveFeedbackDefinition
    @DefinitionID INT = NULL,
    @DeptID INT = NULL,
    @SubDeptID INT = NULL,
    @FeedbackTitle VARCHAR(150),
    @Description VARCHAR(500) = NULL,
    @IsActive BIT,
    @Msg VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @DefinitionID IS NULL
        BEGIN
            INSERT INTO dbo.FeedbackDefinition (DeptID, SubDeptID, FeedbackTitle, Description, IsActive, CreatedDate)
            VALUES (@DeptID, @SubDeptID, @FeedbackTitle, @Description, @IsActive, GETDATE());
            
            SET @Msg = 'Feedback definition created successfully.';
        END
        ELSE
        BEGIN
            UPDATE dbo.FeedbackDefinition
            SET DeptID = @DeptID,
                SubDeptID = @SubDeptID,
                FeedbackTitle = @FeedbackTitle,
                Description = @Description,
                IsActive = @IsActive
            WHERE DefinitionID = @DefinitionID;
            
            SET @Msg = 'Feedback definition updated successfully.';
        END
    END TRY
    BEGIN CATCH
        SET @Msg = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Submit Feedback
IF OBJECT_ID('dbo.sp_SubmitFeedback', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SubmitFeedback;
GO
CREATE PROCEDURE dbo.sp_SubmitFeedback
    @DefinitionID INT,
    @MemberNo VARCHAR(50) = NULL,
    @Rating INT,
    @Comments VARCHAR(MAX) = NULL,
    @Msg VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO dbo.FeedbackSubmission (DefinitionID, MemberNo, Rating, Comments, CreatedDate)
        VALUES (@DefinitionID, @MemberNo, @Rating, @Comments, GETDATE());
        SET @Msg = 'Feedback submitted successfully.';
    END TRY
    BEGIN CATCH
        SET @Msg = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Submit Complaint
IF OBJECT_ID('dbo.sp_SubmitComplaint', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SubmitComplaint;
GO
CREATE PROCEDURE dbo.sp_SubmitComplaint
    @DeptID INT = NULL,
    @SubDeptID INT = NULL,
    @MemberNo VARCHAR(50) = NULL,
    @ComplaintSubject VARCHAR(150),
    @ComplaintDetail VARCHAR(MAX),
    @Msg VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO dbo.Complaint (DeptID, SubDeptID, MemberNo, ComplaintSubject, ComplaintDetail, Status, Remarks, CreatedDate)
        VALUES (@DeptID, @SubDeptID, @MemberNo, @ComplaintSubject, @ComplaintDetail, 'Pending', NULL, GETDATE());
        SET @Msg = 'Complaint registered successfully.';
    END TRY
    BEGIN CATCH
        SET @Msg = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Get Complaints list
IF OBJECT_ID('dbo.sp_GetComplaints', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetComplaints;
GO
CREATE PROCEDURE dbo.sp_GetComplaints
    @DeptID INT = NULL,
    @SubDeptID INT = NULL,
    @Status VARCHAR(50) = NULL,
    @FromDate DATETIME = NULL,
    @ToDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        c.ComplaintID,
        c.DeptID,
        d.Dept_Name AS DepartmentName,
        c.SubDeptID,
        sd.SubDept_Name AS SubDepartmentName,
        c.MemberNo,
        mp.MemberName,
        c.ComplaintSubject,
        c.ComplaintDetail,
        c.Status,
        c.Remarks,
        c.CreatedDate,
        c.UpdatedDate
    FROM dbo.Complaint c
    LEFT JOIN BasicDataInfo.dbo.Department d ON c.DeptID = d.Dept_ID
    LEFT JOIN BasicDataInfo.dbo.SubDepartment sd ON c.SubDeptID = sd.SubDept_Id
    LEFT JOIN MemberShip.dbo.MemberProfile mp ON c.MemberNo COLLATE DATABASE_DEFAULT = mp.MemberNo COLLATE DATABASE_DEFAULT
    WHERE 
        (@DeptID IS NULL OR c.DeptID = @DeptID)
        AND (@SubDeptID IS NULL OR c.SubDeptID = @SubDeptID)
        AND (@Status IS NULL OR @Status = '' OR c.Status = @Status)
        AND (@FromDate IS NULL OR c.CreatedDate >= @FromDate)
        AND (@ToDate IS NULL OR c.CreatedDate <= @ToDate)
    ORDER BY c.CreatedDate DESC;
END;
GO

-- Update Complaint Status
IF OBJECT_ID('dbo.sp_UpdateComplaintStatus', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_UpdateComplaintStatus;
GO
CREATE PROCEDURE dbo.sp_UpdateComplaintStatus
    @ComplaintID INT,
    @Status VARCHAR(50),
    @Remarks VARCHAR(MAX),
    @Msg VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.Complaint
        SET Status = @Status,
            Remarks = @Remarks,
            UpdatedDate = GETDATE()
        WHERE ComplaintID = @ComplaintID;
        
        SET @Msg = 'Complaint updated successfully.';
    END TRY
    BEGIN CATCH
        SET @Msg = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
