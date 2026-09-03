-- =========================================================================
-- Migration: 22_GetFeedbackAndComplaints.sql
-- Description: Creates unified stored procedure to fetch both complaints
--              and detailed feedback ratings in a single query.
-- =========================================================================

USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

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
            mp.MemberName,
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
            mp.MemberName,
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

-- Recreate Update Status procedure to handle both Complaints and Feedbacks
IF OBJECT_ID('dbo.sp_UpdateComplaintStatus', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_UpdateComplaintStatus;
GO

CREATE PROCEDURE dbo.sp_UpdateComplaintStatus
    @ComplaintID INT,
    @RecordType VARCHAR(50), -- 'Complaint' or 'Feedback'
    @Status VARCHAR(50),
    @Remarks VARCHAR(MAX),
    @Msg VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @RecordType = 'Feedback'
        BEGIN
            UPDATE dbo.FeedbackSubmission
            SET Status = @Status,
                Remarks = @Remarks,
                UpdatedDate = GETDATE()
            WHERE SubmissionID = @ComplaintID;
            SET @Msg = 'Feedback updated successfully.';
        END
        ELSE
        BEGIN
            UPDATE dbo.Complaint
            SET Status = @Status,
                Remarks = @Remarks,
                UpdatedDate = GETDATE()
            WHERE ComplaintID = @ComplaintID;
            SET @Msg = 'Complaint updated successfully.';
        END
    END TRY
    BEGIN CATCH
        SET @Msg = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
