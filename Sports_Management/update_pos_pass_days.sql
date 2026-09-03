ALTER TABLE POSTransactions
ADD ValidFrom DATE NULL,
    ValidTo DATE NULL,
    NumberOfDays INT NULL;
GO

ALTER PROCEDURE [sp_InsertPOSTransaction]
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
    @NumberOfDays INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO POSTransactions (CustomerType, MemberID, CustomerName, SubscriptionID, Amount, TransactionDate, DependentMemberNo, DependentName, DependentRelation, PolicyDiscount, GSTAmount, ManualDiscount, NetFee, ValidFrom, ValidTo, NumberOfDays)
    VALUES (@CustomerType, @MemberID, @CustomerName, @SubscriptionID, @Amount, GETDATE(), @DependentMemberNo, @DependentName, @DependentRelation, @PolicyDiscount, @GSTAmount, @ManualDiscount, @NetFee, @ValidFrom, @ValidTo, @NumberOfDays);

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
            INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID, DependentMemberNo, DependentName, DependentRelation)
            VALUES (@MemberID, GETDATE(), @DescPay, 0, @AmountPaid, 'POS_Pay', @NewTxnID, @DependentMemberNo, @DependentName, @DependentRelation);
        END
    END

    SELECT @NewTxnID;
END
GO
