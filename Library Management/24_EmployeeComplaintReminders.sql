-- =========================================================================
-- Migration: 24_EmployeeComplaintReminders.sql
-- Description: Adds reminder columns to EmployeeComplaint and creates
--              sp_SendEmployeeComplaintReminder.
-- =========================================================================

USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- Add ReminderCount column if it does not exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.EmployeeComplaint') AND name = 'ReminderCount')
BEGIN
    ALTER TABLE dbo.EmployeeComplaint ADD ReminderCount INT NOT NULL DEFAULT 0;
END;
GO

-- Add LastReminderDate column if it does not exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.EmployeeComplaint') AND name = 'LastReminderDate')
BEGIN
    ALTER TABLE dbo.EmployeeComplaint ADD LastReminderDate DATETIME NULL;
END;
GO

-- Stored Procedure to Send Reminder
IF OBJECT_ID('dbo.sp_SendEmployeeComplaintReminder', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SendEmployeeComplaintReminder;
GO

CREATE PROCEDURE dbo.sp_SendEmployeeComplaintReminder
    @EmpComplaintID INT,
    @Msg VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @CurrentStatus VARCHAR(50);
        SELECT @CurrentStatus = Status FROM dbo.EmployeeComplaint WHERE EmpComplaintID = @EmpComplaintID;
        
        IF @CurrentStatus IS NULL
        BEGIN
            SET @Msg = 'Error: Complaint record not found.';
            RETURN;
        END
        
        IF @CurrentStatus <> 'Pending'
        BEGIN
            SET @Msg = 'Warning: Action has already been taken on this complaint (Status: ' + @CurrentStatus + '). Reminders can only be sent for Pending complaints.';
            RETURN;
        END

        UPDATE dbo.EmployeeComplaint
        SET ReminderCount = ReminderCount + 1,
            LastReminderDate = GETDATE()
        WHERE EmpComplaintID = @EmpComplaintID;
        
        SET @Msg = 'Reminder sent successfully to the target department.';
    END TRY
    BEGIN CATCH
        SET @Msg = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
