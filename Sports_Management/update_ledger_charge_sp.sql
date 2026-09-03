-- 1. Alter sp_AssignSubscription to use Final Fee (NetFee - BankDiscount) for Ledger
ALTER PROCEDURE [dbo].[sp_AssignSubscription]
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
    @BankDiscount DECIMAL(18,2) = 0
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

    INSERT INTO MemberSubscriptions (MemberID, SubscriptionID, StartDate, EndDate, IsActive, DependentMemberNo, DependentName, DependentRelation, PolicyDiscount, GSTAmount, ManualDiscount, NetFee, BankID, BankDiscount)
    VALUES (@MemberID, @SubscriptionID, @StartDate, @EndDate, 1, @DependentMemberNo, @DependentName, @DependentRelation, @PolicyDiscount, @GSTAmount, @ManualDiscount, @NetFee, @BankID, @BankDiscount);

    DECLARE @NewSubID INT = SCOPE_IDENTITY();

    DECLARE @Fee DECIMAL(18,2);
    DECLARE @PackageName NVARCHAR(100);
    SELECT @Fee = Fee, @PackageName = PackageName FROM Subscriptions WHERE SubscriptionID = @SubscriptionID;

    -- The ledger charge should be the FinalFee (NetFee - BankDiscount)
    DECLARE @LedgerFee DECIMAL(18,2) = @NetFee - ISNULL(@BankDiscount, 0);
    IF @LedgerFee < 0 SET @LedgerFee = 0;

    IF @LedgerFee > 0
    BEGIN
        DECLARE @Desc NVARCHAR(255) = 'Subscription Charge: ' + @PackageName;
        IF @DependentMemberNo IS NOT NULL AND @DependentMemberNo <> ''
        BEGIN
            SET @Desc = @Desc + ' (' + @DependentRelation + ')';
        END

        IF @PaymentMode IS NOT NULL AND @PaymentMode <> 'Cash'
        BEGIN
            SET @Desc = @Desc + ' [' + @PaymentMode + ' Ref: ' + ISNULL(@ReferenceID, '') + ']';
        END

        INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID, DependentMemberNo, DependentName, DependentRelation)
        VALUES (@MemberID, GETDATE(), @Desc, @LedgerFee, 0, 'Subscription', @NewSubID, @DependentMemberNo, @DependentName, @DependentRelation);
    END
END
GO

-- 2. Alter sp_InsertPOSTransaction to use Final Fee (NetFee - BankDiscount) for Ledger
ALTER PROCEDURE [dbo].[sp_InsertPOSTransaction]
    @CustomerType NVARCHAR(50),
    @MemberID INT = NULL,
    @CustomerName NVARCHAR(150),
    @SubscriptionID INT,
    @Amount DECIMAL(18,2),
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
    @BankDiscount DECIMAL(18,2) = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @PaymentMode IS NULL SET @PaymentMode = 'Online Payment';

    INSERT INTO POSTransactions (CustomerType, MemberID, CustomerName, SubscriptionID, Amount, TransactionDate, DependentMemberNo, DependentName, DependentRelation, PolicyDiscount, GSTAmount, ManualDiscount, NetFee, ValidFrom, ValidTo, NumberOfDays, PaymentMode, BankID, BankDiscount)
    VALUES (@CustomerType, @MemberID, @CustomerName, @SubscriptionID, @Amount, GETDATE(), @DependentMemberNo, @DependentName, @DependentRelation, @PolicyDiscount, @GSTAmount, @ManualDiscount, @NetFee, @ValidFrom, @ValidTo, @NumberOfDays, @PaymentMode, @BankID, @BankDiscount);

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

        -- The ledger charge should be the FinalFee (NetFee - BankDiscount)
        DECLARE @LedgerFee DECIMAL(18,2) = @NetFee - ISNULL(@BankDiscount, 0);
        IF @LedgerFee < 0 SET @LedgerFee = 0;

        -- 1. Charge Entry
        INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID, DependentMemberNo, DependentName, DependentRelation)
        VALUES (@MemberID, GETDATE(), @DescCharge, @LedgerFee, 0, 'POS', @NewTxnID, @DependentMemberNo, @DependentName, @DependentRelation);

        -- 2. Payment Entry (if any paid immediately)
        IF @AmountPaid > 0
        BEGIN
            DECLARE @DescPay NVARCHAR(255) = 'Payment Received (POS-' + CAST(@NewTxnID AS NVARCHAR) + ') - ' + @Remarks;
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

-- 3. Alter sp_DailySubscriptionMaintenance to use Final Fee (NetFee - BankDiscount) for Auto Billing
ALTER PROCEDURE [dbo].[sp_DailySubscriptionMaintenance]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentDate DATE = CAST(GETDATE() AS DATE);

    -- 1. Expire Subscriptions
    UPDATE MemberSubscriptions
    SET IsActive = 0
    WHERE IsActive = 1 
      AND EndDate IS NOT NULL 
      AND EndDate < @CurrentDate;

    -- 2. Expire POS Daily Transactions older than 1 day
    UPDATE POSTransactions
    SET Status = 'Expired'
    WHERE CAST(TransactionDate AS DATE) < @CurrentDate
      AND (Status IS NULL OR Status <> 'Expired');

    -- 3. Bill Continuous Subscriptions every month
    DECLARE @MemberSubID INT, @MemberID INT, @SubscriptionID INT, @LastBilledDate DATE;
    DECLARE @DependentMemberNo NVARCHAR(50), @DependentName NVARCHAR(150), @DependentRelation NVARCHAR(50);
    DECLARE @PolicyDiscount DECIMAL(18,2), @ManualDiscount DECIMAL(18,2), @NetFee DECIMAL(18,2), @BankDiscount DECIMAL(18,2);
    
    DECLARE curContinuous CURSOR FOR
    SELECT ms.MemberSubID, ms.MemberID, ms.SubscriptionID, ms.LastBilledDate,
           ms.DependentMemberNo, ms.DependentName, ms.DependentRelation,
           ISNULL(ms.PolicyDiscount, 0), ISNULL(ms.ManualDiscount, 0), ms.NetFee, ISNULL(ms.BankDiscount, 0)
    FROM MemberSubscriptions ms
    INNER JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
    WHERE ms.IsActive = 1
      AND ms.EndDate IS NULL
      AND DATEADD(month, 1, ms.LastBilledDate) <= @CurrentDate;

    OPEN curContinuous;
    FETCH NEXT FROM curContinuous INTO @MemberSubID, @MemberID, @SubscriptionID, @LastBilledDate,
                                       @DependentMemberNo, @DependentName, @DependentRelation,
                                       @PolicyDiscount, @ManualDiscount, @NetFee, @BankDiscount;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @BaseFee DECIMAL(18,2) = 0;
        DECLARE @GSTPercent DECIMAL(18,2) = 0;
        DECLARE @PackageName NVARCHAR(100) = '';
        SELECT @BaseFee = Fee, @GSTPercent = ISNULL(GSTPercentage, 16), @PackageName = PackageName FROM Subscriptions WHERE SubscriptionID = @SubscriptionID;

        -- Dynamically calculate Policy (Age / Tenure)
        DECLARE @RatePolicy NVARCHAR(50) = dbo.fn_GetSubscriptionRatePolicy(@MemberID, @DependentMemberNo, @SubscriptionID);
        IF @RatePolicy = 'Senior'
            SET @PolicyDiscount = @BaseFee; -- 100% off
        ELSE IF @RatePolicy = 'Half'
            SET @PolicyDiscount = @BaseFee * 0.5;
        ELSE
            SET @PolicyDiscount = 0;

        -- Calculate Fee
        DECLARE @FeeAfterPolicy DECIMAL(18,2) = @BaseFee - @PolicyDiscount;
        IF @FeeAfterPolicy < 0 SET @FeeAfterPolicy = 0;
        
        DECLARE @GSTAmount DECIMAL(18,2) = @FeeAfterPolicy * (@GSTPercent / 100.0);
        
        DECLARE @CalculatedFee DECIMAL(18,2) = @FeeAfterPolicy + @GSTAmount - @ManualDiscount;
        IF @CalculatedFee < 0 SET @CalculatedFee = 0;
        
        DECLARE @FinalFeeToCharge DECIMAL(18,2) = @CalculatedFee - @BankDiscount;
        IF @FinalFeeToCharge < 0 SET @FinalFeeToCharge = 0;

        IF @NetFee IS NULL AND @FinalFeeToCharge = 0 SET @FinalFeeToCharge = @BaseFee; -- fallback for old records

        IF @FinalFeeToCharge >= 0
        BEGIN
            DECLARE @NewBilledDate DATE = DATEADD(month, 1, @LastBilledDate);

            DECLARE @Desc NVARCHAR(255) = 'Continuous Subscription Auto-Renewal: ' + @PackageName;
            IF @DependentMemberNo IS NOT NULL AND @DependentMemberNo <> ''
            BEGIN
                SET @Desc = @Desc + ' (' + @DependentRelation + ')';
            END

            -- Insert into Ledger
            INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID, DependentMemberNo, DependentName, DependentRelation)
            VALUES (@MemberID, GETDATE(), @Desc, @FinalFeeToCharge, 0, 'Subscription_Auto', @MemberSubID, @DependentMemberNo, @DependentName, @DependentRelation);

            -- Update LastBilledDate
            UPDATE MemberSubscriptions
            SET LastBilledDate = @NewBilledDate
            WHERE MemberSubID = @MemberSubID;
        END
        
        FETCH NEXT FROM curContinuous INTO @MemberSubID, @MemberID, @SubscriptionID, @LastBilledDate,
                                           @DependentMemberNo, @DependentName, @DependentRelation,
                                           @PolicyDiscount, @ManualDiscount, @NetFee, @BankDiscount;
    END

    CLOSE curContinuous;
    DEALLOCATE curContinuous;

END
GO
