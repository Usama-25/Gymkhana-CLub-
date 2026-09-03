-- =========================================================================
-- Migration: 41_AddFeedbackQuestionTypes.sql
-- Description: Adds QuestionType and Options to dbo.FeedbackQuestion.
--              Adds AnswerText to dbo.FeedbackSubmissionDetail and allows NULL Rating.
--              Updates stored procedures accordingly.
-- =========================================================================

USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Alter dbo.FeedbackQuestion
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.FeedbackQuestion') AND name = 'QuestionType')
BEGIN
    ALTER TABLE dbo.FeedbackQuestion ADD QuestionType VARCHAR(50) NOT NULL DEFAULT 'Rating';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.FeedbackQuestion') AND name = 'Options')
BEGIN
    ALTER TABLE dbo.FeedbackQuestion ADD Options VARCHAR(500) NULL;
END;
GO

-- 2. Alter dbo.FeedbackSubmissionDetail
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.FeedbackSubmissionDetail') AND name = 'Rating')
BEGIN
    ALTER TABLE dbo.FeedbackSubmissionDetail ALTER COLUMN Rating INT NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.FeedbackSubmissionDetail') AND name = 'AnswerText')
BEGIN
    ALTER TABLE dbo.FeedbackSubmissionDetail ADD AnswerText VARCHAR(250) NULL;
END;
GO

-- Drop CHECK constraint on Rating if it exists
DECLARE @ChkName VARCHAR(250);
SELECT @ChkName = name FROM sys.check_constraints WHERE parent_object_id = OBJECT_ID('dbo.FeedbackSubmissionDetail') AND name LIKE '%Rating%';
IF @ChkName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE dbo.FeedbackSubmissionDetail DROP CONSTRAINT ' + @ChkName);
END;
GO


-- 3. Stored Procedures Updates

-- Update sp_GetFeedbackQuestions
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
        ISNULL(q.QuestionType, 'Rating') AS QuestionType,
        q.Options,
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
        q.QuestionText,
        ISNULL(q.QuestionType, 'Rating') AS QuestionType,
        q.Options,
        q.IsActive,
        q.CreatedDate
    FROM dbo.FeedbackQuestion q
    LEFT JOIN BasicDataInfo.dbo.Department d ON q.DeptID = d.Dept_ID
    LEFT JOIN BasicDataInfo.dbo.SubDepartment sd ON q.SubDeptID = sd.SubDept_Id
    ORDER BY q.DeptID ASC, q.SubDeptID ASC, q.QuestionID ASC;
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
            INSERT INTO dbo.FeedbackQuestion (DeptID, SubDeptID, QuestionText, QuestionType, Options, IsActive, CreatedDate)
            VALUES (@DeptID, @SubDeptID, @QuestionText, ISNULL(@QuestionType, 'Rating'), @Options, @IsActive, GETDATE());
            SET @Msg = 'Feedback question created successfully.';
        END
        ELSE
        BEGIN
            UPDATE dbo.FeedbackQuestion
            SET DeptID = @DeptID,
                SubDeptID = @SubDeptID,
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

-- Update sp_GetFeedbackAndComplaints
IF OBJECT_ID('dbo.sp_GetFeedbackAndComplaints', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetFeedbackAndComplaints;
GO

CREATE PROCEDURE dbo.sp_GetFeedbackAndComplaints
    @DeptID INT = NULL,
    @SubDeptID INT = NULL,
    @RecordType VARCHAR(50) = NULL,
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
        
        -- 2. Feedback Submissions
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
                SELECT STRING_AGG(q.QuestionText + ': ' + ISNULL(fd.AnswerText, CAST(fd.Rating AS VARCHAR) + '/5 Stars'), ' | ') 
                FROM dbo.FeedbackSubmissionDetail fd
                JOIN dbo.FeedbackQuestion q ON fd.QuestionID = q.QuestionID
                WHERE fd.SubmissionID = fs.SubmissionID
            ), 'No details submitted') + CHAR(13) + CHAR(10) + 'Comments: ' + ISNULL(fs.GeneralComments, '') AS Detail,
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
