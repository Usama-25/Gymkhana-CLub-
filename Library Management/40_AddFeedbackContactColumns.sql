-- =========================================================================
-- Migration: 40_AddFeedbackContactColumns.sql
-- Description: Adds MemberName, Email, and PhoneNumber columns to both
--              dbo.Complaint and dbo.FeedbackSubmission tables.
--              Updates stored procedures accordingly.
-- =========================================================================

USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Add Columns to dbo.Complaint
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Complaint') AND name = 'MemberName')
BEGIN
    ALTER TABLE dbo.Complaint ADD MemberName VARCHAR(150) NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Complaint') AND name = 'Email')
BEGIN
    ALTER TABLE dbo.Complaint ADD Email VARCHAR(100) NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Complaint') AND name = 'PhoneNumber')
BEGIN
    ALTER TABLE dbo.Complaint ADD PhoneNumber VARCHAR(50) NULL;
END;
GO

-- 2. Add Columns to dbo.FeedbackSubmission
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.FeedbackSubmission') AND name = 'MemberName')
BEGIN
    ALTER TABLE dbo.FeedbackSubmission ADD MemberName VARCHAR(150) NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.FeedbackSubmission') AND name = 'Email')
BEGIN
    ALTER TABLE dbo.FeedbackSubmission ADD Email VARCHAR(100) NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.FeedbackSubmission') AND name = 'PhoneNumber')
BEGIN
    ALTER TABLE dbo.FeedbackSubmission ADD PhoneNumber VARCHAR(50) NULL;
END;
GO

-- Also add Status, Remarks and UpdatedDate to FeedbackSubmission if they don't exist yet
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.FeedbackSubmission') AND name = 'Status')
BEGIN
    ALTER TABLE dbo.FeedbackSubmission ADD Status VARCHAR(50) NOT NULL DEFAULT 'Submitted';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.FeedbackSubmission') AND name = 'Remarks')
BEGIN
    ALTER TABLE dbo.FeedbackSubmission ADD Remarks VARCHAR(MAX) NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.FeedbackSubmission') AND name = 'UpdatedDate')
BEGIN
    ALTER TABLE dbo.FeedbackSubmission ADD UpdatedDate DATETIME NULL;
END;
GO


-- 3. Update Stored Procedures

-- Recreate sp_SubmitComplaint with MemberName, Email, PhoneNumber
IF OBJECT_ID('dbo.sp_SubmitComplaint', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SubmitComplaint;
GO

CREATE PROCEDURE dbo.sp_SubmitComplaint
    @DeptID INT = NULL,
    @SubDeptID INT = NULL,
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
            DeptID, SubDeptID, MemberNo, MemberName, Email, PhoneNumber, 
            ComplaintSubject, ComplaintDetail, Status, Remarks, CreatedDate
        )
        VALUES (
            @DeptID, @SubDeptID, @MemberNo, @MemberName, @Email, @PhoneNumber, 
            @ComplaintSubject, @ComplaintDetail, 'Pending', NULL, GETDATE()
        );
        SET @Msg = 'Complaint registered successfully.';
    END TRY
    BEGIN CATCH
        SET @Msg = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Recreate sp_SubmitFeedbackMultiple with MemberName, Email, PhoneNumber
IF OBJECT_ID('dbo.sp_SubmitFeedbackMultiple', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SubmitFeedbackMultiple;
GO

CREATE PROCEDURE dbo.sp_SubmitFeedbackMultiple
    @DeptID INT,
    @SubDeptID INT = NULL,
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
            DeptID, SubDeptID, MemberNo, MemberName, Email, PhoneNumber, 
            GeneralComments, CreatedDate, Status, Remarks, UpdatedDate
        )
        VALUES (
            @DeptID, @SubDeptID, @MemberNo, @MemberName, @Email, @PhoneNumber, 
            @GeneralComments, GETDATE(), 'Submitted', NULL, NULL
        );
        
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

-- Recreate sp_GetFeedbackAndComplaints returning new guest details
IF OBJECT_ID('dbo.sp_GetFeedbackAndComplaints', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetFeedbackAndComplaints;
GO

CREATE PROCEDURE dbo.sp_GetFeedbackAndComplaints
    @DeptID INT = NULL,
    @SubDeptID INT = NULL,
    @RecordType VARCHAR(50) = NULL, -- 'Complaint' or 'Feedback' or NULL
    @Status VARCHAR(50) = NULL,
    @FromDate DATETIME = NULL,
    @ToDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT * FROM (
        -- 1. Complaints
        SELECT 
            c.ComplaintID AS ID,
            'Complaint' AS RecordType,
            c.DeptID,
            d.Dept_Name AS DepartmentName,
            c.SubDeptID,
            sd.SubDept_Name AS SubDepartmentName,
            c.MemberNo,
            ISNULL(c.MemberName, mp.MemberName) AS MemberName,
            c.Email,
            c.PhoneNumber,
            c.ComplaintSubject AS Subject,
            c.ComplaintDetail AS Detail,
            c.Status,
            c.Remarks,
            c.CreatedDate,
            c.UpdatedDate
        FROM dbo.Complaint c
        LEFT JOIN BasicDataInfo.dbo.Department d ON c.DeptID = d.Dept_ID
        LEFT JOIN BasicDataInfo.dbo.SubDepartment sd ON c.SubDeptID = sd.SubDept_Id
        LEFT JOIN MemberShip.dbo.MemberProfile mp ON c.MemberNo COLLATE DATABASE_DEFAULT = mp.MemberNo COLLATE DATABASE_DEFAULT
        
        UNION ALL
        
        -- 2. Feedback Submissions (with aggregated rating details)
        SELECT 
            fs.SubmissionID AS ID,
            'Feedback' AS RecordType,
            fs.DeptID,
            d.Dept_Name AS DepartmentName,
            fs.SubDeptID,
            sd.SubDept_Name AS SubDepartmentName,
            fs.MemberNo,
            ISNULL(fs.MemberName, mp.MemberName) AS MemberName,
            fs.Email,
            fs.PhoneNumber,
            'Member Feedback Submission' AS Subject,
            ISNULL((
                SELECT STRING_AGG(q.QuestionText + ': ' + CAST(fd.Rating AS VARCHAR) + '/5 Stars', ' | ') 
                FROM dbo.FeedbackSubmissionDetail fd
                JOIN dbo.FeedbackQuestion q ON fd.QuestionID = q.QuestionID
                WHERE fd.SubmissionID = fs.SubmissionID
            ), 'No ratings submitted') + CHAR(13) + CHAR(10) + 'Comments: ' + ISNULL(fs.GeneralComments, '') AS Detail,
            fs.Status,
            fs.Remarks,
            fs.CreatedDate,
            fs.UpdatedDate
        FROM dbo.FeedbackSubmission fs
        LEFT JOIN BasicDataInfo.dbo.Department d ON fs.DeptID = d.Dept_ID
        LEFT JOIN BasicDataInfo.dbo.SubDepartment sd ON fs.SubDeptID = sd.SubDept_Id
        LEFT JOIN MemberShip.dbo.MemberProfile mp ON fs.MemberNo COLLATE DATABASE_DEFAULT = mp.MemberNo COLLATE DATABASE_DEFAULT
    ) AS Combined
    WHERE
        (@DeptID IS NULL OR Combined.DeptID = @DeptID)
        AND (@SubDeptID IS NULL OR Combined.SubDeptID = @SubDeptID)
        AND (@RecordType IS NULL OR @RecordType = '' OR Combined.RecordType = @RecordType)
        AND (@Status IS NULL OR @Status = '' OR Combined.Status = @Status)
        AND (@FromDate IS NULL OR Combined.CreatedDate >= @FromDate)
        AND (@ToDate IS NULL OR Combined.CreatedDate <= @ToDate)
    ORDER BY Combined.CreatedDate DESC;
END;
GO
