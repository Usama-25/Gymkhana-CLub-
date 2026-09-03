USE SportsModuleDB;
GO

-- 1. Create Lockers table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Lockers')
BEGIN
    CREATE TABLE Lockers (
        LockerID INT IDENTITY(1,1) PRIMARY KEY,
        LockerName NVARCHAR(100) NOT NULL,
        Fee DECIMAL(18,2) NOT NULL DEFAULT 0,
        IsActive BIT NOT NULL DEFAULT 1
    );
END
GO

-- 2. Add Columns to MemberSubscriptions
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('MemberSubscriptions') AND name = 'LockerID')
BEGIN
    ALTER TABLE MemberSubscriptions ADD LockerID INT NULL;
    ALTER TABLE MemberSubscriptions ADD LockerFee DECIMAL(18,2) NOT NULL DEFAULT 0;
END
GO

-- 3. Add Columns to POSTransactions
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('POSTransactions') AND name = 'LockerID')
BEGIN
    ALTER TABLE POSTransactions ADD LockerID INT NULL;
    ALTER TABLE POSTransactions ADD LockerFee DECIMAL(18,2) NOT NULL DEFAULT 0;
END
GO

-- 4. Create SPs for Lockers
CREATE OR ALTER PROCEDURE sp_GetLockers
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    IF @IncludeInactive = 1
        SELECT LockerID, LockerName, Fee, IsActive FROM Lockers ORDER BY LockerName;
    ELSE
        SELECT LockerID, LockerName, Fee, IsActive FROM Lockers WHERE IsActive = 1 ORDER BY LockerName;
END
GO

CREATE OR ALTER PROCEDURE sp_InsertLocker
    @LockerName NVARCHAR(100),
    @Fee DECIMAL(18,2),
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Lockers (LockerName, Fee, IsActive)
    VALUES (@LockerName, @Fee, @IsActive);
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateLocker
    @LockerID INT,
    @LockerName NVARCHAR(100),
    @Fee DECIMAL(18,2),
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Lockers
    SET LockerName = @LockerName,
        Fee = @Fee,
        IsActive = @IsActive
    WHERE LockerID = @LockerID;
END
GO

-- 5. Alter sp_AssignSubscription
CREATE OR ALTER PROCEDURE [dbo].[sp_AssignSubscription]
    @MemberID INT,
    @SubscriptionID INT,
    @StartDate DATE,
    @EndDate DATE = NULL,
    @DependentMemberNo NVARCHAR(50) = NULL,
    @DependentName NVARCHAR(150) = NULL,
    @DependentRelation NVARCHAR(50) = NULL,
    @PolicyDiscount DECIMAL(18,2) = 0,
    @GSTAmount DECIMAL(18,2) = 0,
    @ManualDiscount DECIMAL(18,2) = 0,
    @NetFee DECIMAL(18,2) = 0,
    @PaymentMode NVARCHAR(50) = NULL,
    @CardNo NVARCHAR(50) = NULL,
    @ReferenceID NVARCHAR(50) = NULL,
    @BankID INT = NULL,
    @BankDiscount DECIMAL(18,2) = 0,
    @LockerID INT = NULL,
    @LockerFee DECIMAL(18,2) = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SportID INT;
    SELECT @SportID = SportID FROM Subscriptions WHERE SubscriptionID = @SubscriptionID;

    UPDATE ms
    SET ms.IsActive = 0, ms.EndDate = GETDATE()
    FROM MemberSubscriptions ms
    INNER JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
    WHERE ms.MemberID = @MemberID 
      AND s.SportID = @SportID
      AND ms.IsActive = 1
      AND ISNULL(ms.DependentMemberNo, '') = ISNULL(@DependentMemberNo, '');

    INSERT INTO MemberSubscriptions (MemberID, SubscriptionID, StartDate, EndDate, IsActive, DependentMemberNo, DependentName, DependentRelation, PolicyDiscount, GSTAmount, ManualDiscount, NetFee, BankID, BankDiscount, LockerID, LockerFee)
    VALUES (@MemberID, @SubscriptionID, @StartDate, @EndDate, 1, @DependentMemberNo, @DependentName, @DependentRelation, @PolicyDiscount, @GSTAmount, @ManualDiscount, @NetFee, @BankID, @BankDiscount, @LockerID, @LockerFee);

    DECLARE @NewSubID INT = SCOPE_IDENTITY();

    DECLARE @PackageName NVARCHAR(100);
    SELECT @PackageName = PackageName FROM Subscriptions WHERE SubscriptionID = @SubscriptionID;

    -- The ledger charge should be the NetFee (after discounts and GST, including LockerFee if it was added to NetFee on the front-end)
    IF @NetFee > 0
    BEGIN
        DECLARE @Desc NVARCHAR(255) = 'Subscription Charge: ' + @PackageName;
        
        IF @LockerID IS NOT NULL AND @LockerFee > 0
        BEGIN
            DECLARE @LockerName NVARCHAR(100);
            SELECT @LockerName = LockerName FROM Lockers WHERE LockerID = @LockerID;
            SET @Desc = @Desc + ' (Incl. ' + ISNULL(@LockerName, 'Locker') + ')';
        END

        IF @DependentMemberNo IS NOT NULL AND @DependentMemberNo <> ''
        BEGIN
            SET @Desc = @Desc + ' (' + @DependentRelation + ')';
        END

        IF @PaymentMode IS NOT NULL AND @PaymentMode <> 'Cash'
        BEGIN
            SET @Desc = @Desc + ' [' + @PaymentMode + ' Ref: ' + ISNULL(@ReferenceID, '') + ']';
        END

        INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID, DependentMemberNo, DependentName, DependentRelation)
        VALUES (@MemberID, GETDATE(), @Desc, @NetFee, 0, 'Subscription', @NewSubID, @DependentMemberNo, @DependentName, @DependentRelation);
    END
END
GO

-- 6. Alter sp_InsertPOSTransaction
CREATE OR ALTER PROCEDURE [dbo].[sp_InsertPOSTransaction]
    @CustomerType NVARCHAR(50),
    @MemberID INT = NULL,
    @CustomerName NVARCHAR(150),
    @SubscriptionID INT,
    @Amount DECIMAL(18,2), -- Represents Base Amount
    @AmountPaid DECIMAL(18,2),
    @Remarks NVARCHAR(255),
    @DependentMemberNo NVARCHAR(50) = NULL,
    @DependentName NVARCHAR(150) = NULL,
    @DependentRelation NVARCHAR(50) = NULL,
    @PolicyDiscount DECIMAL(18,2) = 0,
    @GSTAmount DECIMAL(18,2) = 0,
    @ManualDiscount DECIMAL(18,2) = 0,
    @NetFee DECIMAL(18,2) = 0,
    @ValidFrom DATE = NULL,
    @ValidTo DATE = NULL,
    @NumberOfDays INT = NULL,
    @PaymentMode NVARCHAR(50) = NULL,
    @CardNo NVARCHAR(50) = NULL,
    @ReferenceID NVARCHAR(50) = NULL,
    @BankID INT = NULL,
    @BankDiscount DECIMAL(18,2) = 0,
    @LockerID INT = NULL,
    @LockerFee DECIMAL(18,2) = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- Ensure PaymentMode is not null if payment was received
    IF @PaymentMode IS NULL SET @PaymentMode = 'Online Payment';

    INSERT INTO POSTransactions (CustomerType, MemberID, CustomerName, SubscriptionID, Amount, TransactionDate, DependentMemberNo, DependentName, DependentRelation, PolicyDiscount, GSTAmount, ManualDiscount, NetFee, ValidFrom, ValidTo, NumberOfDays, PaymentMode, BankID, BankDiscount, LockerID, LockerFee)
    VALUES (@CustomerType, @MemberID, @CustomerName, @SubscriptionID, @Amount, GETDATE(), @DependentMemberNo, @DependentName, @DependentRelation, @PolicyDiscount, @GSTAmount, @ManualDiscount, @NetFee, @ValidFrom, @ValidTo, @NumberOfDays, @PaymentMode, @BankID, @BankDiscount, @LockerID, @LockerFee);

    DECLARE @NewTxnID INT = SCOPE_IDENTITY();

    -- If Member, generate ledger entries
    IF @CustomerType = 'Member' AND @MemberID IS NOT NULL
    BEGIN
        DECLARE @SportName NVARCHAR(100);
        DECLARE @PackageName NVARCHAR(100);
        
        SELECT @SportName = sp.SportName, @PackageName = s.PackageName 
        FROM Subscriptions s
        INNER JOIN Sports sp ON s.SportID = sp.SportID
        WHERE s.SubscriptionID = @SubscriptionID;

        DECLARE @DescCharge NVARCHAR(255) = 'Daily POS Charge: ' + @SportName + ' - ' + @PackageName;
        
        IF @LockerID IS NOT NULL AND @LockerFee > 0
        BEGIN
            DECLARE @LockerName NVARCHAR(100);
            SELECT @LockerName = LockerName FROM Lockers WHERE LockerID = @LockerID;
            SET @DescCharge = @DescCharge + ' (Incl. ' + ISNULL(@LockerName, 'Locker') + ')';
        END

        IF @DependentMemberNo IS NOT NULL AND @DependentMemberNo <> ''
        BEGIN
            SET @DescCharge = @DescCharge + ' (' + @DependentRelation + ')';
        END
        
        IF @NumberOfDays > 1
        BEGIN
            SET @DescCharge = @DescCharge + ' (' + CAST(@NumberOfDays AS NVARCHAR(10)) + ' Days)';
        END

        -- 1. Charge Entry
        INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID, DependentMemberNo, DependentName, DependentRelation)
        VALUES (@MemberID, GETDATE(), @DescCharge, @NetFee, 0, 'POS', @NewTxnID, @DependentMemberNo, @DependentName, @DependentRelation);

        -- 2. Payment Entry (if any paid immediately)
        IF @AmountPaid > 0
        BEGIN
            DECLARE @DescPay NVARCHAR(255) = 'Payment Received (POS-' + CAST(@NewTxnID AS NVARCHAR) + ') - ' + @Remarks;
            -- Include PaymentMode/RefID info if not cash
            IF @PaymentMode IS NOT NULL AND @PaymentMode <> 'Cash'
            BEGIN
                SET @DescPay = @DescPay + ' [' + @PaymentMode + ' Ref: ' + ISNULL(@ReferenceID, '') + ']';
            END

            INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID, DependentMemberNo, DependentName, DependentRelation)
            VALUES (@MemberID, GETDATE(), @DescPay, 0, @AmountPaid, 'POS_Pay', @NewTxnID, @DependentMemberNo, @DependentName, @DependentRelation);
        END
    END

    SELECT @NewTxnID;
END
GO
