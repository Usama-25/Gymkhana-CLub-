USE [SportsModuleDB]
GO

ALTER PROCEDURE sp_DailySubscriptionMaintenance
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentDate DATE = CAST(GETDATE() AS DATE);

    -- 1. Expire Subscriptions (Monthly, etc.) where EndDate has passed
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
    DECLARE @PolicyDiscount DECIMAL(18,2), @ManualDiscount DECIMAL(18,2), @NetFee DECIMAL(18,2);
    
    DECLARE curContinuous CURSOR FOR
    SELECT ms.MemberSubID, ms.MemberID, ms.SubscriptionID, ms.LastBilledDate,
           ms.DependentMemberNo, ms.DependentName, ms.DependentRelation,
           ISNULL(ms.PolicyDiscount, 0), ISNULL(ms.ManualDiscount, 0), ms.NetFee
    FROM MemberSubscriptions ms
    INNER JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
    WHERE ms.IsActive = 1
      AND ms.EndDate IS NULL
      AND DATEADD(month, 1, ms.LastBilledDate) <= @CurrentDate;

    OPEN curContinuous;
    FETCH NEXT FROM curContinuous INTO @MemberSubID, @MemberID, @SubscriptionID, @LastBilledDate,
                                       @DependentMemberNo, @DependentName, @DependentRelation,
                                       @PolicyDiscount, @ManualDiscount, @NetFee;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @BaseFee DECIMAL(18,2) = 0;
        DECLARE @GSTPercent DECIMAL(18,2) = 0;
        DECLARE @PackageName NVARCHAR(100) = '';
        SELECT @BaseFee = Fee, @GSTPercent = ISNULL(GSTPercentage, 16), @PackageName = PackageName FROM Subscriptions WHERE SubscriptionID = @SubscriptionID;

        -- Dynamically calculate Policy (Age / Tenure)
        DECLARE @RatePolicy NVARCHAR(50) = dbo.fn_GetSubscriptionRatePolicy(@MemberID, @DependentMemberNo);
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
        
        DECLARE @FinalFeeToCharge DECIMAL(18,2) = @CalculatedFee;
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
                                           @PolicyDiscount, @ManualDiscount, @NetFee;
    END

    CLOSE curContinuous;
    DEALLOCATE curContinuous;

END
GO
