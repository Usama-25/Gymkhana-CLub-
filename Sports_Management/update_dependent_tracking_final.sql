-- 1. Add columns to MemberSubscriptions
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('MemberSubscriptions') AND name = 'DependentMemberNo')
BEGIN
    ALTER TABLE MemberSubscriptions ADD DependentMemberNo NVARCHAR(50) NULL;
    ALTER TABLE MemberSubscriptions ADD DependentName NVARCHAR(150) NULL;
    ALTER TABLE MemberSubscriptions ADD DependentRelation NVARCHAR(50) NULL;
END
GO

-- 2. Add columns to POSTransactions
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('POSTransactions') AND name = 'DependentMemberNo')
BEGIN
    ALTER TABLE POSTransactions ADD DependentMemberNo NVARCHAR(50) NULL;
    ALTER TABLE POSTransactions ADD DependentName NVARCHAR(150) NULL;
    ALTER TABLE POSTransactions ADD DependentRelation NVARCHAR(50) NULL;
END
GO

-- 3. Add columns to LedgerEntries
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('LedgerEntries') AND name = 'DependentMemberNo')
BEGIN
    ALTER TABLE LedgerEntries ADD DependentMemberNo NVARCHAR(50) NULL;
    ALTER TABLE LedgerEntries ADD DependentName NVARCHAR(150) NULL;
    ALTER TABLE LedgerEntries ADD DependentRelation NVARCHAR(50) NULL;
END
GO

-- 4. Update sp_AssignSubscription
ALTER PROCEDURE [sp_AssignSubscription]
    @MemberID INT,
    @SubscriptionID INT,
    @DependentMemberNo NVARCHAR(50) = NULL,
    @DependentName NVARCHAR(150) = NULL,
    @DependentRelation NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Deactivate any existing active subscription for this member/dependent and same sport
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

    -- Insert new subscription
    INSERT INTO MemberSubscriptions (MemberID, SubscriptionID, StartDate, IsActive, DependentMemberNo, DependentName, DependentRelation)
    VALUES (@MemberID, @SubscriptionID, GETDATE(), 1, @DependentMemberNo, @DependentName, @DependentRelation);

    DECLARE @NewSubID INT = SCOPE_IDENTITY();

    -- Generate Billing Entry
    DECLARE @Fee DECIMAL(18,2);
    DECLARE @PackageName NVARCHAR(100);
    SELECT @Fee = Fee, @PackageName = PackageName FROM Subscriptions WHERE SubscriptionID = @SubscriptionID;

    IF @Fee > 0
    BEGIN
        DECLARE @Desc NVARCHAR(255) = 'Subscription Charge: ' + @PackageName;
        IF @DependentMemberNo IS NOT NULL AND @DependentMemberNo <> ''
        BEGIN
            SET @Desc = @Desc + ' (' + @DependentRelation + ')';
        END

        INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID, DependentMemberNo, DependentName, DependentRelation)
        VALUES (@MemberID, GETDATE(), @Desc, @Fee, 0, 'Subscription', @NewSubID, @DependentMemberNo, @DependentName, @DependentRelation);
    END
END
GO

-- 5. Update sp_GetMemberSubscriptions
ALTER PROCEDURE [sp_GetMemberSubscriptions]
    @MemberID INT
AS
BEGIN
    SELECT 
        ms.MemberSubID,
        ms.SubscriptionID,
        s.SportID,
        sp.SportName,
        s.PackageName,
        s.Fee,
        ms.StartDate,
        ms.EndDate,
        ms.IsActive,
        ms.DependentMemberNo,
        ms.DependentName,
        ms.DependentRelation
    FROM MemberSubscriptions ms
    INNER JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
    INNER JOIN Sports sp ON s.SportID = sp.SportID
    WHERE ms.MemberID = @MemberID
    ORDER BY ms.IsActive DESC, ms.StartDate DESC;
END
GO

-- 6. Update sp_InsertPOSTransaction
ALTER PROCEDURE [sp_InsertPOSTransaction]
    @CustomerType NVARCHAR(50),
    @MemberID INT = NULL,
    @CustomerName NVARCHAR(150),
    @SubscriptionID INT,
    @Amount DECIMAL(18,2),
    @AmountPaid DECIMAL(18,2),
    @Remarks NVARCHAR(255),
    @DependentMemberNo NVARCHAR(50) = NULL,
    @DependentName NVARCHAR(150) = NULL,
    @DependentRelation NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO POSTransactions (CustomerType, MemberID, CustomerName, SubscriptionID, Amount, TransactionDate, DependentMemberNo, DependentName, DependentRelation)
    VALUES (@CustomerType, @MemberID, @CustomerName, @SubscriptionID, @Amount, GETDATE(), @DependentMemberNo, @DependentName, @DependentRelation);

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
        VALUES (@MemberID, GETDATE(), @DescCharge, @Amount, 0, 'POS', @NewTxnID, @DependentMemberNo, @DependentName, @DependentRelation);

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

-- 7. Update sp_GetMemberLedger
ALTER PROCEDURE [sp_GetMemberLedger]
    @MemberID INT
AS
BEGIN
    SELECT 
        EntryID,
        TransactionDate,
        ISNULL(RefType, '') + CASE WHEN RefID IS NOT NULL THEN '-' + CAST(RefID AS NVARCHAR) ELSE '' END AS RefNo,
        Description,
        DebitAmount,
        CreditAmount,
        DependentMemberNo,
        DependentName,
        DependentRelation
    FROM LedgerEntries
    WHERE MemberID = @MemberID
    ORDER BY TransactionDate ASC, EntryID ASC;
END
GO
