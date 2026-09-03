-- =========================================================================
-- Migration: 42_AddFeedbackLocations.sql
-- Description: Creates FeedbackLocations table and alters FeedbackQuestion,
--              FeedbackSubmission, and Complaint tables to add LocationID.
--              Updates/Adds stored procedures for locations.
-- =========================================================================

USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Create dbo.FeedbackLocations
IF OBJECT_ID('dbo.FeedbackLocations', 'U') IS NOT NULL
    DROP TABLE dbo.FeedbackLocations;
GO

CREATE TABLE dbo.FeedbackLocations (
    LocationID INT IDENTITY(1,1) PRIMARY KEY,
    DeptID INT NOT NULL,
    SubDeptID INT NULL,
    LocationName NVARCHAR(250) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 2. Add columns to dbo.FeedbackQuestion, dbo.FeedbackSubmission, dbo.Complaint
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.FeedbackQuestion') AND name = 'LocationID')
BEGIN
    ALTER TABLE dbo.FeedbackQuestion ADD LocationID INT NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.FeedbackSubmission') AND name = 'LocationID')
BEGIN
    ALTER TABLE dbo.FeedbackSubmission ADD LocationID INT NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Complaint') AND name = 'LocationID')
BEGIN
    ALTER TABLE dbo.Complaint ADD LocationID INT NULL;
END;
GO


-- 3. Stored Procedures Updates

-- Create sp_GetFeedbackLocations
IF OBJECT_ID('dbo.sp_GetFeedbackLocations', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetFeedbackLocations;
GO
CREATE PROCEDURE dbo.sp_GetFeedbackLocations
    @DeptID INT,
    @SubDeptID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT LocationID, LocationName 
    FROM dbo.FeedbackLocations
    WHERE DeptID = @DeptID 
      AND (SubDeptID = @SubDeptID OR (SubDeptID IS NULL AND @SubDeptID IS NULL))
      AND IsActive = 1
    ORDER BY LocationName;
END;
GO

-- Create sp_SaveFeedbackLocation
IF OBJECT_ID('dbo.sp_SaveFeedbackLocation', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SaveFeedbackLocation;
GO
CREATE PROCEDURE dbo.sp_SaveFeedbackLocation
    @DeptID INT,
    @SubDeptID INT = NULL,
    @LocationName NVARCHAR(250),
    @Msg VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM dbo.FeedbackLocations WHERE DeptID = @DeptID AND (SubDeptID = @SubDeptID OR (SubDeptID IS NULL AND @SubDeptID IS NULL)) AND LocationName = @LocationName)
        BEGIN
            SET @Msg = 'Error: Location already exists.';
        END
        ELSE
        BEGIN
            INSERT INTO dbo.FeedbackLocations (DeptID, SubDeptID, LocationName, IsActive, CreatedDate)
            VALUES (@DeptID, @SubDeptID, @LocationName, 1, GETDATE());
            SET @Msg = 'Location saved successfully.';
        END
    END TRY
    BEGIN CATCH
        SET @Msg = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Update sp_GetFeedbackQuestions
IF OBJECT_ID('dbo.sp_GetFeedbackQuestions', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetFeedbackQuestions;
GO
CREATE PROCEDURE dbo.sp_GetFeedbackQuestions
    @DeptID INT,
    @SubDeptID INT = NULL,
    @LocationID INT = NULL,
    @ActiveOnly BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        q.QuestionID,
        q.DeptID,
        d.Dept_Name AS DepartmentName,
        q.SubDeptID,
        sd.SubDept_Name AS SubDepartmentName,
        q.LocationID,
        l.LocationName,
        q.QuestionText,
        ISNULL(q.QuestionType, 'Rating') AS QuestionType,
        q.Options,
        q.IsActive,
        q.CreatedDate
    FROM dbo.FeedbackQuestion q
    LEFT JOIN BasicDataInfo.dbo.Department d ON q.DeptID = d.Dept_ID
    LEFT JOIN BasicDataInfo.dbo.SubDepartment sd ON q.SubDeptID = sd.SubDept_Id
    LEFT JOIN dbo.FeedbackLocations l ON q.LocationID = l.LocationID
    WHERE 
        q.DeptID = @DeptID
        AND (@SubDeptID IS NULL OR q.SubDeptID = @SubDeptID)
        AND (@LocationID IS NULL OR q.LocationID = @LocationID)
        AND (@ActiveOnly = 0 OR q.IsActive = 1)
    ORDER BY q.QuestionID ASC;
END;
GO

-- Update sp_GetAllFeedbackQuestions
IF OBJECT_ID('dbo.sp_GetAllFeedbackQuestions', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetAllFeedbackQuestions;
GO
CREATE PROCEDURE dbo.sp_GetAllFeedbackQuestions
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        q.QuestionID,
        q.DeptID,
        d.Dept_Name AS DepartmentName,
        q.SubDeptID,
        sd.SubDept_Name AS SubDepartmentName,
        q.LocationID,
        l.LocationName,
        q.QuestionText,
        ISNULL(q.QuestionType, 'Rating') AS QuestionType,
        q.Options,
        q.IsActive,
        q.CreatedDate
    FROM dbo.FeedbackQuestion q
    LEFT JOIN BasicDataInfo.dbo.Department d ON q.DeptID = d.Dept_ID
    LEFT JOIN BasicDataInfo.dbo.SubDepartment sd ON q.SubDeptID = sd.SubDept_Id
    LEFT JOIN dbo.FeedbackLocations l ON q.LocationID = l.LocationID
    ORDER BY q.DeptID ASC, q.SubDeptID ASC, q.LocationID ASC, q.QuestionID ASC;
END;
GO

-- Update sp_SaveFeedbackQuestion
IF OBJECT_ID('dbo.sp_SaveFeedbackQuestion', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SaveFeedbackQuestion;
GO
CREATE PROCEDURE dbo.sp_SaveFeedbackQuestion
    @QuestionID INT = NULL,
    @DeptID INT,
    @SubDeptID INT = NULL,
    @LocationID INT = NULL,
    @QuestionText VARCHAR(250),
    @QuestionType VARCHAR(50) = 'Rating',
    @Options VARCHAR(500) = NULL,
    @IsActive BIT,
    @Msg VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @QuestionID IS NULL
        BEGIN
            INSERT INTO dbo.FeedbackQuestion (DeptID, SubDeptID, LocationID, QuestionText, QuestionType, Options, IsActive, CreatedDate)
            VALUES (@DeptID, @SubDeptID, @LocationID, @QuestionText, ISNULL(@QuestionType, 'Rating'), @Options, @IsActive, GETDATE());
            SET @Msg = 'Feedback question created successfully.';
        END
        ELSE
        BEGIN
            UPDATE dbo.FeedbackQuestion
            SET DeptID = @DeptID,
                SubDeptID = @SubDeptID,
                LocationID = @LocationID,
                QuestionText = @QuestionText,
                QuestionType = ISNULL(@QuestionType, 'Rating'),
                Options = @Options,
                IsActive = @IsActive
            WHERE QuestionID = @QuestionID;
            SET @Msg = 'Feedback question updated successfully.';
        END
    END TRY
    BEGIN CATCH
        SET @Msg = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Update sp_SubmitFeedbackMultiple
IF OBJECT_ID('dbo.sp_SubmitFeedbackMultiple', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SubmitFeedbackMultiple;
GO
CREATE PROCEDURE dbo.sp_SubmitFeedbackMultiple
    @DeptID INT,
    @SubDeptID INT = NULL,
    @LocationID INT = NULL,
    @MemberNo VARCHAR(50) = NULL,
    @MemberName VARCHAR(150) = NULL,
    @Email VARCHAR(100) = NULL,
    @PhoneNumber VARCHAR(50) = NULL,
    @GeneralComments VARCHAR(MAX) = NULL,
    @RatingsXml XML,
    @Msg VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Insert Main Submission
        DECLARE @SubmissionID INT;
        INSERT INTO dbo.FeedbackSubmission (
            DeptID, SubDeptID, LocationID, MemberNo, MemberName, Email, PhoneNumber, 
            GeneralComments, CreatedDate, Status, Remarks, UpdatedDate
        )
        VALUES (
            @DeptID, @SubDeptID, @LocationID, @MemberNo, @MemberName, @Email, @PhoneNumber, 
            @GeneralComments, GETDATE(), 'Submitted', NULL, NULL
        );
        
        SET @SubmissionID = SCOPE_IDENTITY();

        -- Insert Details from XML
        INSERT INTO dbo.FeedbackSubmissionDetail (SubmissionID, QuestionID, Rating, AnswerText)
        SELECT 
            @SubmissionID,
            r.value('@questionId', 'int'),
            CASE WHEN r.value('@value', 'varchar(20)') IS NULL OR r.value('@value', 'varchar(20)') = '' THEN NULL ELSE r.value('@value', 'int') END,
            r.value('@answerText', 'varchar(250)')
        FROM @RatingsXml.nodes('/ratings/rating') AS T(r);

        COMMIT TRANSACTION;
        SET @Msg = 'Feedback submitted successfully.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @Msg = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Update sp_SubmitComplaint
IF OBJECT_ID('dbo.sp_SubmitComplaint', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SubmitComplaint;
GO
CREATE PROCEDURE dbo.sp_SubmitComplaint
    @DeptID INT = NULL,
    @SubDeptID INT = NULL,
    @LocationID INT = NULL,
    @MemberNo VARCHAR(50) = NULL,
    @MemberName VARCHAR(150) = NULL,
    @Email VARCHAR(100) = NULL,
    @PhoneNumber VARCHAR(50) = NULL,
    @ComplaintSubject VARCHAR(150),
    @ComplaintDetail VARCHAR(MAX),
    @Msg VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO dbo.Complaint (
            DeptID, SubDeptID, LocationID, MemberNo, MemberName, Email, PhoneNumber, 
            ComplaintSubject, ComplaintDetail, Status, Remarks, CreatedDate
        )
        VALUES (
            @DeptID, @SubDeptID, @LocationID, @MemberNo, @MemberName, @Email, @PhoneNumber, 
            @ComplaintSubject, @ComplaintDetail, 'Pending', NULL, GETDATE()
        );
        SET @Msg = 'Complaint registered successfully.';
    END TRY
    BEGIN CATCH
        SET @Msg = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
