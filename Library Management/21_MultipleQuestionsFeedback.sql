-- =========================================================================
-- Migration: 21_MultipleQuestionsFeedback.sql
-- Description: Sets up dynamic multiple questions for feedback per department.
--              Routes feedback by DeptId and SubDeptId.
-- =========================================================================

USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Drop old tables/procedures
IF OBJECT_ID('dbo.FeedbackSubmissionDetail', 'U') IS NOT NULL
    DROP TABLE dbo.FeedbackSubmissionDetail;
GO

IF OBJECT_ID('dbo.FeedbackSubmission', 'U') IS NOT NULL
    DROP TABLE dbo.FeedbackSubmission;
GO

IF OBJECT_ID('dbo.FeedbackQuestion', 'U') IS NOT NULL
    DROP TABLE dbo.FeedbackQuestion;
GO

-- Drop old definition table
IF OBJECT_ID('dbo.FeedbackDefinition', 'U') IS NOT NULL
    DROP TABLE dbo.FeedbackDefinition;
GO


-- 2. Create New Schema
CREATE TABLE dbo.FeedbackQuestion (
    QuestionID INT IDENTITY(1,1) PRIMARY KEY,
    DeptID INT NOT NULL, -- References BasicDataInfo.dbo.Department(Dept_ID)
    SubDeptID INT NULL,  -- References BasicDataInfo.dbo.SubDepartment(SubDept_Id)
    QuestionText VARCHAR(250) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.FeedbackSubmission (
    SubmissionID INT IDENTITY(1,1) PRIMARY KEY,
    DeptID INT NOT NULL,
    SubDeptID INT NULL,
    MemberNo VARCHAR(50) NULL,
    GeneralComments VARCHAR(MAX) NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.FeedbackSubmissionDetail (
    SubmissionDetailID INT IDENTITY(1,1) PRIMARY KEY,
    SubmissionID INT NOT NULL FOREIGN KEY REFERENCES dbo.FeedbackSubmission(SubmissionID) ON DELETE CASCADE,
    QuestionID INT NOT NULL FOREIGN KEY REFERENCES dbo.FeedbackQuestion(QuestionID),
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5)
);
GO


-- 3. Stored Procedures

-- Get Feedback Questions per Dept/SubDept
IF OBJECT_ID('dbo.sp_GetFeedbackQuestions', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetFeedbackQuestions;
GO
CREATE PROCEDURE dbo.sp_GetFeedbackQuestions
    @DeptID INT,
    @SubDeptID INT = NULL,
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
        q.QuestionText,
        q.IsActive,
        q.CreatedDate
    FROM dbo.FeedbackQuestion q
    LEFT JOIN BasicDataInfo.dbo.Department d ON q.DeptID = d.Dept_ID
    LEFT JOIN BasicDataInfo.dbo.SubDepartment sd ON q.SubDeptID = sd.SubDept_Id
    WHERE 
        q.DeptID = @DeptID
        AND (@SubDeptID IS NULL OR q.SubDeptID = @SubDeptID)
        AND (@ActiveOnly = 0 OR q.IsActive = 1)
    ORDER BY q.QuestionID ASC;
END;
GO

-- Get All Defined Questions (for Setup Grid)
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
        q.QuestionText,
        q.IsActive,
        q.CreatedDate
    FROM dbo.FeedbackQuestion q
    LEFT JOIN BasicDataInfo.dbo.Department d ON q.DeptID = d.Dept_ID
    LEFT JOIN BasicDataInfo.dbo.SubDepartment sd ON q.SubDeptID = sd.SubDept_Id
    ORDER BY q.DeptID ASC, q.SubDeptID ASC, q.QuestionID ASC;
END;
GO

-- Save/Update Feedback Question
IF OBJECT_ID('dbo.sp_SaveFeedbackQuestion', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SaveFeedbackQuestion;
GO
CREATE PROCEDURE dbo.sp_SaveFeedbackQuestion
    @QuestionID INT = NULL,
    @DeptID INT,
    @SubDeptID INT = NULL,
    @QuestionText VARCHAR(250),
    @IsActive BIT,
    @Msg VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @QuestionID IS NULL
        BEGIN
            INSERT INTO dbo.FeedbackQuestion (DeptID, SubDeptID, QuestionText, IsActive, CreatedDate)
            VALUES (@DeptID, @SubDeptID, @QuestionText, @IsActive, GETDATE());
            SET @Msg = 'Feedback question created successfully.';
        END
        ELSE
        BEGIN
            UPDATE dbo.FeedbackQuestion
            SET DeptID = @DeptID,
                SubDeptID = @SubDeptID,
                QuestionText = @QuestionText,
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

-- Submit Feedback Submission (XML format for detail insertion)
IF OBJECT_ID('dbo.sp_SubmitFeedbackMultiple', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SubmitFeedbackMultiple;
GO
CREATE PROCEDURE dbo.sp_SubmitFeedbackMultiple
    @DeptID INT,
    @SubDeptID INT = NULL,
    @MemberNo VARCHAR(50) = NULL,
    @GeneralComments VARCHAR(MAX) = NULL,
    @RatingsXml XML, -- Format: <ratings><rating questionId="1" value="4"/><rating questionId="2" value="5"/></ratings>
    @Msg VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Insert Main Submission
        DECLARE @SubmissionID INT;
        INSERT INTO dbo.FeedbackSubmission (DeptID, SubDeptID, MemberNo, GeneralComments, CreatedDate)
        VALUES (@DeptID, @SubDeptID, @MemberNo, @GeneralComments, GETDATE());
        
        SET @SubmissionID = SCOPE_IDENTITY();

        -- Insert Details from XML
        INSERT INTO dbo.FeedbackSubmissionDetail (SubmissionID, QuestionID, Rating)
        SELECT 
            @SubmissionID,
            r.value('@questionId', 'int'),
            r.value('@value', 'int')
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
