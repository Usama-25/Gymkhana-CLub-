USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================================================
--  Migration: Update sp_GetOverdueReminderList to select BookID, AcqNo and DDC
-- =============================================================================

CREATE OR ALTER PROCEDURE dbo.sp_GetOverdueReminderList
    @Scenario INT = NULL -- 1, 2, or 3
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @FPD DECIMAL(8,2);
    SELECT @FPD = CAST(SVal AS DECIMAL(8,2)) FROM Settings WHERE SKey='FinePerDay';
    SET @FPD = ISNULL(@FPD, 10.00);

    SELECT 
        l.LoanID,
        m.MemberID,
        b.BookID,
        b.AcqNo,
        b.DDC,
        COALESCE(l.ActualBorrowerNo, m.MembershipNo) AS MembershipNo,
        COALESCE(l.ActualBorrowerName, m.FullName)   AS MemberName,
        m.Phone,
        m.Email,
        ISNULL(mp.Address, 'Lahore Gymkhana Club, Lahore, Pakistan') AS MemberAddress,
        b.Title AS BookTitle,
        cp.Barcode,
        ISNULL(cp.AcqCost, 1000.00) AS AcqCost,
        l.IssueDate,
        l.DueDate,
        DATEDIFF(DAY, l.DueDate, CAST(GETDATE() AS DATE)) AS DaysOverdue,
        DATEDIFF(DAY, l.DueDate, CAST(GETDATE() AS DATE)) * @FPD AS EstFine,
        ISNULL(cp.AcqCost, 1000.00) * 2.0 AS PenaltyAmount,
        (DATEDIFF(DAY, l.DueDate, CAST(GETDATE() AS DATE)) * @FPD) + ISNULL(cp.AcqCost, 1000.00) + (ISNULL(cp.AcqCost, 1000.00) * 2.0) AS TotalOverdueCharge,
        l.Reminder1SentDate,
        l.Reminder2SentDate,
        l.Reminder3SentDate,
        l.IsFinalCharged,
        -- Determine applicable scenario
        CASE 
            WHEN DATEDIFF(DAY, l.DueDate, CAST(GETDATE() AS DATE)) >= 30 AND l.Reminder3SentDate IS NULL THEN 3
            WHEN DATEDIFF(DAY, l.DueDate, CAST(GETDATE() AS DATE)) >= 15 AND l.Reminder3SentDate IS NULL AND l.Reminder2SentDate IS NULL THEN 2
            WHEN DATEDIFF(DAY, l.DueDate, CAST(GETDATE() AS DATE)) >= 7 AND l.Reminder3SentDate IS NULL AND l.Reminder2SentDate IS NULL AND l.Reminder1SentDate IS NULL THEN 1
            ELSE 0
        END AS ApplicableScenario
    INTO #Reminders
    FROM Loans l
    JOIN Members m ON l.MemberID = m.MemberID
    JOIN BookCopies cp ON l.CopyID = cp.CopyID
    JOIN Books b ON cp.BookID = b.BookID
    LEFT JOIN MemberShip.dbo.MemberProfile mp ON m.MemberID = mp.MemberID
    WHERE l.StatusID IN (1,3,4) -- Issued, Overdue, Renewed
      AND l.DueDate <= DATEADD(DAY, -7, CAST(GETDATE() AS DATE));

    -- Return filtered list
    SELECT * 
    FROM #Reminders
    WHERE (@Scenario IS NULL OR ApplicableScenario = @Scenario)
      AND ApplicableScenario > 0
    ORDER BY DaysOverdue DESC;

    DROP TABLE #Reminders;
END;
GO

PRINT 'dbo.sp_GetOverdueReminderList updated successfully with BookID, AcqNo and DDC columns.';
GO
