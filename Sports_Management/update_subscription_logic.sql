-- 1. Add LastBilledDate to MemberSubscriptions if it does not exist
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('MemberSubscriptions') AND name = 'LastBilledDate'
)
BEGIN
    ALTER TABLE MemberSubscriptions ADD LastBilledDate DATE;
END
GO

-- 2. Update existing Continuous subscriptions to set LastBilledDate to StartDate where it is NULL
UPDATE MemberSubscriptions
SET LastBilledDate = StartDate
WHERE LastBilledDate IS NULL;
GO

-- 3. Create or Alter sp_DailySubscriptionMaintenance
CREATE OR ALTER PROCEDURE sp_DailySubscriptionMaintenance
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
    -- Assuming 'Status' column exists, we set it to 'Expired'
    UPDATE POSTransactions
    SET Status = 'Expired'
    WHERE CAST(TransactionDate AS DATE) < @CurrentDate
      AND (Status IS NULL OR Status <> 'Expired');

    -- 3. Bill Continuous Subscriptions every month
    -- We look for Active subscriptions where EndDate IS NULL (Continuous)
    -- and 1 month has passed since the LastBilledDate.
    
    DECLARE @MemberSubID INT, @MemberID INT, @SubscriptionID INT, @LastBilledDate DATE;
    DECLARE @DependentMemberNo NVARCHAR(50), @DependentName NVARCHAR(150), @DependentRelation NVARCHAR(50);
    
    DECLARE curContinuous CURSOR FOR
    SELECT ms.MemberSubID, ms.MemberID, ms.SubscriptionID, ms.LastBilledDate,
           ms.DependentMemberNo, ms.DependentName, ms.DependentRelation
    FROM MemberSubscriptions ms
    INNER JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
    WHERE ms.IsActive = 1
      AND ms.EndDate IS NULL  -- Assuming EndDate IS NULL means Continuous
      AND DATEADD(month, 1, ms.LastBilledDate) <= @CurrentDate;

    OPEN curContinuous;
    FETCH NEXT FROM curContinuous INTO @MemberSubID, @MemberID, @SubscriptionID, @LastBilledDate,
                                       @DependentMemberNo, @DependentName, @DependentRelation;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Get Fee and Package Name
        DECLARE @Fee DECIMAL(18,2) = 0;
        DECLARE @PackageName NVARCHAR(100) = '';
        SELECT @Fee = Fee, @PackageName = PackageName FROM Subscriptions WHERE SubscriptionID = @SubscriptionID;

        IF @Fee > 0
        BEGIN
            -- Calculate new billed date (to avoid drift, add 1 month to LastBilledDate)
            -- But if it's very old, we might need a while loop. For now, just add 1 month.
            DECLARE @NewBilledDate DATE = DATEADD(month, 1, @LastBilledDate);

            DECLARE @Desc NVARCHAR(255) = 'Continuous Subscription Auto-Renewal: ' + @PackageName;
            IF @DependentMemberNo IS NOT NULL AND @DependentMemberNo <> ''
            BEGIN
                SET @Desc = @Desc + ' (' + @DependentRelation + ')';
            END

            -- Insert into Ledger
            INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID, DependentMemberNo, DependentName, DependentRelation)
            VALUES (@MemberID, GETDATE(), @Desc, @Fee, 0, 'Subscription_Auto', @MemberSubID, @DependentMemberNo, @DependentName, @DependentRelation);

            -- Update LastBilledDate
            UPDATE MemberSubscriptions
            SET LastBilledDate = @NewBilledDate
            WHERE MemberSubID = @MemberSubID;
        END
        
        FETCH NEXT FROM curContinuous INTO @MemberSubID, @MemberID, @SubscriptionID, @LastBilledDate,
                                           @DependentMemberNo, @DependentName, @DependentRelation;
    END

    CLOSE curContinuous;
    DEALLOCATE curContinuous;

END
GO
