-- =========================================================================
-- Migration: 23_InterdepartmentalComplaintsSetup.sql
-- Description: Sets up the database schema and stored procedures for
--              interdepartmental complaints between employees.
-- =========================================================================

USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.EmployeeComplaint', 'U') IS NOT NULL
    DROP TABLE dbo.EmployeeComplaint;
GO

CREATE TABLE dbo.EmployeeComplaint (
    EmpComplaintID INT IDENTITY(1,1) PRIMARY KEY,
    SenderEmpID NUMERIC(18,0) NOT NULL, -- references BasicDataInfo.dbo.Employee(EmpID)
    TargetDeptID INT NOT NULL,         -- references BasicDataInfo.dbo.Department(Dept_ID)
    TargetSubDeptID INT NULL,          -- references BasicDataInfo.dbo.SubDepartment(SubDept_Id)
    Subject VARCHAR(150) NOT NULL,
    Detail VARCHAR(MAX) NOT NULL,
    Status VARCHAR(50) NOT NULL DEFAULT 'Pending', -- Pending, In Progress, Resolved, Closed
    Remarks VARCHAR(MAX) NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDate DATETIME NULL
);
GO


-- Stored Procedures

-- Submit Employee Complaint
IF OBJECT_ID('dbo.sp_SubmitEmployeeComplaint', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SubmitEmployeeComplaint;
GO
CREATE PROCEDURE dbo.sp_SubmitEmployeeComplaint
    @SenderEmpID NUMERIC(18,0),
    @TargetDeptID INT,
    @TargetSubDeptID INT = NULL,
    @Subject VARCHAR(150),
    @Detail VARCHAR(MAX),
    @Msg VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO dbo.EmployeeComplaint (SenderEmpID, TargetDeptID, TargetSubDeptID, Subject, Detail, Status, Remarks, CreatedDate)
        VALUES (@SenderEmpID, @TargetDeptID, @TargetSubDeptID, @Subject, @Detail, 'Pending', NULL, GETDATE());
        SET @Msg = 'Interdepartmental complaint registered successfully.';
    END TRY
    BEGIN CATCH
        SET @Msg = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Get Employee Complaints (with filters)
IF OBJECT_ID('dbo.sp_GetEmployeeComplaints', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetEmployeeComplaints;
GO
CREATE PROCEDURE dbo.sp_GetEmployeeComplaints
    @SenderDeptID INT = NULL,
    @TargetDeptID INT = NULL,
    @TargetSubDeptID INT = NULL,
    @Status VARCHAR(50) = NULL,
    @FromDate DATETIME = NULL,
    @ToDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ec.EmpComplaintID,
        ec.SenderEmpID,
        emp.EFName AS SenderEmployeeName,
        emp.DeptID AS SenderDeptID,
        sd_sender.Dept_Name AS SenderDepartmentName,
        ec.TargetDeptID,
        td.Dept_Name AS TargetDepartmentName,
        ec.TargetSubDeptID,
        tsd.SubDept_Name AS TargetSubDepartmentName,
        ec.Subject,
        ec.Detail,
        ec.Status,
        ec.Remarks,
        ec.CreatedDate,
        ec.UpdatedDate
    FROM dbo.EmployeeComplaint ec
    INNER JOIN BasicDataInfo.dbo.Employee emp ON ec.SenderEmpID = emp.EmpID
    LEFT JOIN BasicDataInfo.dbo.Department sd_sender ON emp.DeptID = sd_sender.Dept_ID
    LEFT JOIN BasicDataInfo.dbo.Department td ON ec.TargetDeptID = td.Dept_ID
    LEFT JOIN BasicDataInfo.dbo.SubDepartment tsd ON ec.TargetSubDeptID = tsd.SubDept_Id
    WHERE
        (@SenderDeptID IS NULL OR emp.DeptID = @SenderDeptID)
        AND (@TargetDeptID IS NULL OR ec.TargetDeptID = @TargetDeptID)
        AND (@TargetSubDeptID IS NULL OR ec.TargetSubDeptID = @TargetSubDeptID)
        AND (@Status IS NULL OR @Status = '' OR ec.Status = @Status)
        AND (@FromDate IS NULL OR ec.CreatedDate >= @FromDate)
        AND (@ToDate IS NULL OR ec.CreatedDate <= @ToDate)
    ORDER BY ec.CreatedDate DESC;
END;
GO

-- Update Employee Complaint Status & Action taken
IF OBJECT_ID('dbo.sp_UpdateEmployeeComplaintStatus', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_UpdateEmployeeComplaintStatus;
GO
CREATE PROCEDURE dbo.sp_UpdateEmployeeComplaintStatus
    @EmpComplaintID INT,
    @Status VARCHAR(50),
    @Remarks VARCHAR(MAX),
    @Msg VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.EmployeeComplaint
        SET Status = @Status,
            Remarks = @Remarks,
            UpdatedDate = GETDATE()
        WHERE EmpComplaintID = @EmpComplaintID;
        
        SET @Msg = 'Employee complaint updated successfully.';
    END TRY
    BEGIN CATCH
        SET @Msg = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
