USE SportsModuleDB;
GO

ALTER PROCEDURE sp_ChargeSubscriptionToLedger
    @MemberID INT,
    @MemberSubID INT,
    @ChargeAmount DECIMAL(18,2),
    @BillingPeriod NVARCHAR(50) -- e.g., 'August 2026'
AS
BEGIN
    SET NOCOUNT ON;

    -- Allow 0 amount so free subscriptions still get a ledger entry and get marked as billed.
    IF @ChargeAmount < 0 RETURN;

    DECLARE @PackageName NVARCHAR(100);
    DECLARE @DepNo NVARCHAR(50);
    DECLARE @DepRelation NVARCHAR(50);
    
    SELECT 
        @PackageName = s.PackageName,
        @DepNo = ms.DependentMemberNo,
        @DepRelation = ms.DependentRelation
    FROM MemberSubscriptions ms
    INNER JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
    WHERE ms.MemberSubID = @MemberSubID;

    DECLARE @Desc NVARCHAR(255) = 'Subscription Bill (' + @BillingPeriod + '): ' + ISNULL(@PackageName, '');
    IF @DepNo IS NOT NULL AND @DepNo <> ''
    BEGIN
        SET @Desc = @Desc + ' (' + ISNULL(@DepRelation, 'Dependent') + ')';
    END

    -- Insert the record, even if ChargeAmount is 0
    INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID, DependentMemberNo, DependentRelation)
    VALUES (@MemberID, GETDATE(), @Desc, @ChargeAmount, 0, 'SubscriptionCharge', @MemberSubID, @DepNo, @DepRelation);
    
    -- Update LastBilledDate in MemberSubscriptions
    UPDATE MemberSubscriptions
    SET LastBilledDate = GETDATE()
    WHERE MemberSubID = @MemberSubID;
END
GO
