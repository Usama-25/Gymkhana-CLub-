-- 1. Add GSTPercentage to Subscriptions if not exists
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Subscriptions') AND name = 'GSTPercentage')
BEGIN
    ALTER TABLE Subscriptions ADD GSTPercentage DECIMAL(18,2) NOT NULL DEFAULT 16.00;
END
GO

-- 2. Add columns to MemberSubscriptions
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('MemberSubscriptions') AND name = 'ManualDiscount')
BEGIN
    ALTER TABLE MemberSubscriptions ADD PolicyDiscount DECIMAL(18,2) DEFAULT 0;
    ALTER TABLE MemberSubscriptions ADD GSTAmount DECIMAL(18,2) DEFAULT 0;
    ALTER TABLE MemberSubscriptions ADD ManualDiscount DECIMAL(18,2) DEFAULT 0;
    ALTER TABLE MemberSubscriptions ADD NetFee DECIMAL(18,2) DEFAULT 0;
END
GO

-- 3. Add columns to POSTransactions
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('POSTransactions') AND name = 'ManualDiscount')
BEGIN
    ALTER TABLE POSTransactions ADD PolicyDiscount DECIMAL(18,2) DEFAULT 0;
    ALTER TABLE POSTransactions ADD GSTAmount DECIMAL(18,2) DEFAULT 0;
    ALTER TABLE POSTransactions ADD ManualDiscount DECIMAL(18,2) DEFAULT 0;
    ALTER TABLE POSTransactions ADD NetFee DECIMAL(18,2) DEFAULT 0;
END
GO

-- 4. Update sp_AssignSubscription
CREATE OR ALTER PROCEDURE [sp_AssignSubscription]
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
    @NetFee DECIMAL(18,2) = 0
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

    INSERT INTO MemberSubscriptions (MemberID, SubscriptionID, StartDate, EndDate, IsActive, DependentMemberNo, DependentName, DependentRelation, PolicyDiscount, GSTAmount, ManualDiscount, NetFee)
    VALUES (@MemberID, @SubscriptionID, @StartDate, @EndDate, 1, @DependentMemberNo, @DependentName, @DependentRelation, @PolicyDiscount, @GSTAmount, @ManualDiscount, @NetFee);

    DECLARE @NewSubID INT = SCOPE_IDENTITY();

    DECLARE @Fee DECIMAL(18,2);
    DECLARE @PackageName NVARCHAR(100);
    SELECT @Fee = Fee, @PackageName = PackageName FROM Subscriptions WHERE SubscriptionID = @SubscriptionID;

    -- The ledger charge should be the NetFee (after discounts and GST)
    IF @NetFee > 0
    BEGIN
        DECLARE @Desc NVARCHAR(255) = 'Subscription Charge: ' + @PackageName;
        IF @DependentMemberNo IS NOT NULL AND @DependentMemberNo <> ''
        BEGIN
            SET @Desc = @Desc + ' (' + @DependentRelation + ')';
        END

        INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID, DependentMemberNo, DependentName, DependentRelation)
        VALUES (@MemberID, GETDATE(), @Desc, @NetFee, 0, 'Subscription', @NewSubID, @DependentMemberNo, @DependentName, @DependentRelation);
    END
END
GO

-- 5. Update sp_InsertPOSTransaction
CREATE OR ALTER PROCEDURE [sp_InsertPOSTransaction]
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
    @NetFee DECIMAL(18,2) = 0
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO POSTransactions (CustomerType, MemberID, CustomerName, SubscriptionID, Amount, TransactionDate, DependentMemberNo, DependentName, DependentRelation, PolicyDiscount, GSTAmount, ManualDiscount, NetFee)
    VALUES (@CustomerType, @MemberID, @CustomerName, @SubscriptionID, @Amount, GETDATE(), @DependentMemberNo, @DependentName, @DependentRelation, @PolicyDiscount, @GSTAmount, @ManualDiscount, @NetFee);

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
        IF @DependentMemberNo IS NOT NULL AND @DependentMemberNo <> ''
        BEGIN
            SET @DescCharge = @DescCharge + ' (' + @DependentRelation + ')';
        END

        -- 1. Charge Entry
        INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID, DependentMemberNo, DependentName, DependentRelation)
        VALUES (@MemberID, GETDATE(), @DescCharge, @NetFee, 0, 'POS', @NewTxnID, @DependentMemberNo, @DependentName, @DependentRelation);

        -- 2. Payment Entry (if any paid immediately)
        IF @AmountPaid > 0
        BEGIN
            DECLARE @DescPay NVARCHAR(255) = 'Payment Received (POS-' + CAST(@NewTxnID AS NVARCHAR) + ') - ' + @Remarks;
            INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID, DependentMemberNo, DependentName, DependentRelation)
            VALUES (@MemberID, GETDATE(), @DescPay, 0, @AmountPaid, 'POS_Pay', @NewTxnID, @DependentMemberNo, @DependentName, @DependentRelation);
        END
    END

    SELECT @NewTxnID;
END
GO
