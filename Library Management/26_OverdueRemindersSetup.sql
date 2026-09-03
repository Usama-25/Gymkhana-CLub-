USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Add reminder columns to Loans table if they do not exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Loans') AND name = 'Reminder1SentDate')
BEGIN
    ALTER TABLE dbo.Loans ADD Reminder1SentDate DATETIME2(0) NULL;
    PRINT 'Added Reminder1SentDate to Loans.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Loans') AND name = 'Reminder2SentDate')
BEGIN
    ALTER TABLE dbo.Loans ADD Reminder2SentDate DATETIME2(0) NULL;
    PRINT 'Added Reminder2SentDate to Loans.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Loans') AND name = 'Reminder3SentDate')
BEGIN
    ALTER TABLE dbo.Loans ADD Reminder3SentDate DATETIME2(0) NULL;
    PRINT 'Added Reminder3SentDate to Loans.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Loans') AND name = 'IsFinalCharged')
BEGIN
    ALTER TABLE dbo.Loans ADD IsFinalCharged BIT NOT NULL DEFAULT 0;
    PRINT 'Added IsFinalCharged to Loans.';
END
GO

-- 2. Seed 'Library Charges' fine reason
IF NOT EXISTS (SELECT * FROM dbo.FineReasons WHERE ReasonID = 6)
BEGIN
    -- Enable Identity Insert to preserve ReasonID sequence if applicable, though ReasonID is tinyint without identity by default (see 01_Schema.sql line 117)
    INSERT INTO dbo.FineReasons (ReasonID, ReasonName) VALUES (6, 'Library Charges');
    PRINT 'Seeded Library Charges to FineReasons.';
END
GO

-- 3. Stored Procedure: sp_GetOverdueReminderList
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
        m.MembershipNo,
        m.FullName AS MemberName,
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

-- 4. Stored Procedure: sp_SendOverdueReminder
CREATE OR ALTER PROCEDURE dbo.sp_SendOverdueReminder
    @LoanID   INT,
    @Scenario INT, -- 1, 2, or 3
    @Msg      VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM Loans WHERE LoanID = @LoanID AND StatusID IN (1,3,4))
    BEGIN
        SET @Msg = 'ERR:ACTIVE_LOAN_NOT_FOUND';
        RETURN;
    END

    DECLARE @MemberID INT, @CopyID INT, @DueDate DATE, @AcqCost DECIMAL(8,2), @FPD DECIMAL(8,2), @OverdueDays INT;
    SELECT 
        @MemberID = l.MemberID,
        @CopyID = l.CopyID,
        @DueDate = l.DueDate,
        @AcqCost = ISNULL(cp.AcqCost, 1000.00)
    FROM Loans l
    JOIN BookCopies cp ON l.CopyID = cp.CopyID
    WHERE l.LoanID = @LoanID;

    SELECT @FPD = CAST(SVal AS DECIMAL(8,2)) FROM Settings WHERE SKey='FinePerDay';
    SET @FPD = ISNULL(@FPD, 10.00);
    SET @OverdueDays = DATEDIFF(DAY, @DueDate, CAST(GETDATE() AS DATE));

    IF @Scenario = 1
    BEGIN
        UPDATE Loans 
        SET Reminder1SentDate = SYSDATETIME()
        WHERE LoanID = @LoanID;
        SET @Msg = 'OK:REMINDER1_RECORDED';
    END
    ELSE IF @Scenario = 2
    BEGIN
        UPDATE Loans 
        SET Reminder2SentDate = SYSDATETIME()
        WHERE LoanID = @LoanID;
        SET @Msg = 'OK:REMINDER2_RECORDED';
    END
    ELSE IF @Scenario = 3
    BEGIN
        -- Execute Scenario 3 actions: Update reminder date, mark charged, log Fines in Ledger
        BEGIN TRY
            BEGIN TRANSACTION;
                -- Update Loan Reminder Date and status
                UPDATE Loans 
                SET Reminder3SentDate = SYSDATETIME(),
                    IsFinalCharged = 1
                WHERE LoanID = @LoanID;

                -- Calculate Fines
                DECLARE @OverdueFine DECIMAL(8,2) = @OverdueDays * @FPD;
                DECLARE @Penalty DECIMAL(8,2) = @AcqCost * 2.0;

                -- Insert Overdue Days Fine (ReasonID = 1: Overdue)
                INSERT INTO Fines (LoanID, MemberID, ReasonID, FineAmount, IsPaid, CreatedAt, Remarks)
                VALUES (@LoanID, @MemberID, 1, @OverdueFine, 0, SYSDATETIME(), 'Scenario 3: Overdue Days Fine (' + CAST(@OverdueDays AS VARCHAR) + ' days)');

                -- Insert Book Cost (ReasonID = 6: Library Charges)
                INSERT INTO Fines (LoanID, MemberID, ReasonID, FineAmount, IsPaid, CreatedAt, Remarks)
                VALUES (@LoanID, @MemberID, 6, @AcqCost, 0, SYSDATETIME(), 'Scenario 3: Book Cost Charge (Reversible)');

                -- Insert 200% Penalty of Book Cost (ReasonID = 6: Library Charges)
                INSERT INTO Fines (LoanID, MemberID, ReasonID, FineAmount, IsPaid, CreatedAt, Remarks)
                VALUES (@LoanID, @MemberID, 6, @Penalty, 0, SYSDATETIME(), 'Scenario 3: 200% Penalty Charge (Reversible)');

            COMMIT TRANSACTION;
            SET @Msg = 'OK:FINAL_REMINDER_AND_CHARGES_RECORDED';
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            SET @Msg = 'ERR:TRANSACTION_FAILED:' + ERROR_MESSAGE();
        END CATCH
    END
    ELSE
    BEGIN
        SET @Msg = 'ERR:INVALID_SCENARIO';
    END
END;
GO

-- 5. Stored Procedure: sp_GetFinalChargedLoans (For Reversal Panel)
CREATE OR ALTER PROCEDURE dbo.sp_GetFinalChargedLoans
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        l.LoanID,
        m.MemberID,
        m.MembershipNo,
        m.FullName AS MemberName,
        b.Title AS BookTitle,
        cp.Barcode,
        l.IssueDate,
        l.DueDate,
        l.Reminder3SentDate AS ChargedDate,
        -- Overdue Fine
        (SELECT ISNULL(SUM(FineAmount), 0.00) FROM Fines WHERE LoanID = l.LoanID AND ReasonID = 1) AS OverdueFine,
        -- Book Cost (ReasonID = 6 and remarks like 'Scenario 3: Book Cost%')
        (SELECT ISNULL(SUM(FineAmount), 0.00) FROM Fines WHERE LoanID = l.LoanID AND ReasonID = 6 AND Remarks LIKE '%Book Cost%') AS BookCostCharge,
        -- Penalty (ReasonID = 6 and remarks like 'Scenario 3: 200%%')
        (SELECT ISNULL(SUM(FineAmount), 0.00) FROM Fines WHERE LoanID = l.LoanID AND ReasonID = 6 AND Remarks LIKE '%Penalty%') AS PenaltyCharge,
        -- Total Charged
        (SELECT ISNULL(SUM(FineAmount), 0.00) FROM Fines WHERE LoanID = l.LoanID) AS TotalCharged
    FROM Loans l
    JOIN Members m ON l.MemberID = m.MemberID
    JOIN BookCopies cp ON l.CopyID = cp.CopyID
    JOIN Books b ON cp.BookID = b.BookID
    WHERE l.IsFinalCharged = 1
      AND NOT EXISTS (
          SELECT 1 FROM Fines f WHERE f.LoanID = l.LoanID AND f.IsPaid = 1
      )
    ORDER BY l.Reminder3SentDate DESC;
END;
GO

-- 6. Stored Procedure: sp_ReverseOverdueCharges
CREATE OR ALTER PROCEDURE dbo.sp_ReverseOverdueCharges
    @LoanID     INT,
    @StaffID    SMALLINT,
    @VoucherNo  VARCHAR(30) OUTPUT,
    @Msg        VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM Loans WHERE LoanID = @LoanID AND IsFinalCharged = 1)
    BEGIN
        SET @Msg = 'ERR:LOAN_NOT_FINAL_CHARGED';
        RETURN;
    END

    DECLARE @MemberID INT;
    SELECT @MemberID = MemberID FROM Loans WHERE LoanID = @LoanID;

    -- Verify that we have an unpaid Overdue fine and other reversible charges
    DECLARE @OverdueFineID INT;
    SELECT @OverdueFineID = FineID 
    FROM Fines 
    WHERE LoanID = @LoanID AND ReasonID = 1 AND IsPaid = 0 AND VoucherID IS NULL;

    IF @OverdueFineID IS NULL
    BEGIN
        SET @Msg = 'ERR:OVERDUE_FINE_NOT_FOUND_OR_ALREADY_PAID';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
            
            -- Delete reversible charges: Book Cost and Penalty from Fines table
            DELETE FROM Fines 
            WHERE LoanID = @LoanID 
              AND ReasonID = 6 
              AND Remarks LIKE '%Scenario 3%'
              AND IsPaid = 0;

            -- Update Loan final charged flag to 0
            UPDATE Loans 
            SET IsFinalCharged = 0
            WHERE LoanID = @LoanID;

            -- Generate Voucher for the remaining overdue fine using sp_GenerateVoucher
            DECLARE @FineIDsStr VARCHAR(50) = CAST(@OverdueFineID AS VARCHAR(50));
            
            EXEC dbo.sp_GenerateVoucher 
                @MemberID = @MemberID,
                @FineIDs = @FineIDsStr,
                @BookingIDs = NULL,
                @PaymentMode = 'Cash',
                @Remarks = 'Reversal executed. Voucher created for remaining Overdue Fine.',
                @VoucherNo = @VoucherNo OUTPUT;

            SET @Msg = 'OK';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @Msg = 'ERR:REVERSAL_FAILED:' + ERROR_MESSAGE();
    END CATCH
END;
GO

PRINT '=== Overdue Reminders and Reversals Setup completed ===';
GO
