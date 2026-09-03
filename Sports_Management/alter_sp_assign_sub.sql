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

    -- The ledger charge should be the NetFee (after discounts and GST) minus BankDiscount
    DECLARE @FinalAmount DECIMAL(18,2) = @NetFee - ISNULL(@BankDiscount, 0);
    IF @FinalAmount > 0
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
        VALUES (@MemberID, GETDATE(), @Desc, @FinalAmount, 0, 'Subscription', @NewSubID, @DependentMemberNo, @DependentName, @DependentRelation);
    END
END
