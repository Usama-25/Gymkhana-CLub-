IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('POSTransactions') AND name = 'PaymentMode')
BEGIN
    ALTER TABLE POSTransactions ADD PaymentMode NVARCHAR(50) DEFAULT 'Cash';
END
GO

ALTER PROCEDURE [dbo].[sp_InsertPOSTransaction]
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
    @ReferenceID NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Ensure PaymentMode is not null if payment was received
    IF @PaymentMode IS NULL SET @PaymentMode = 'Cash';

    INSERT INTO POSTransactions (CustomerType, MemberID, CustomerName, SubscriptionID, Amount, TransactionDate, DependentMemberNo, DependentName, DependentRelation, PolicyDiscount, GSTAmount, ManualDiscount, NetFee, ValidFrom, ValidTo, NumberOfDays, PaymentMode)
    VALUES (@CustomerType, @MemberID, @CustomerName, @SubscriptionID, @Amount, GETDATE(), @DependentMemberNo, @DependentName, @DependentRelation, @PolicyDiscount, @GSTAmount, @ManualDiscount, @NetFee, @ValidFrom, @ValidTo, @NumberOfDays, @PaymentMode);

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
