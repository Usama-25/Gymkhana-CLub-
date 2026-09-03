ALTER PROCEDURE [sp_AssignSubscription]
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
    DECLARE @SportName NVARCHAR(100);
    DECLARE @PackageName NVARCHAR(100);

    SELECT @SportID = s.SportID, @SportName = sp.SportName, @PackageName = s.PackageName
    FROM Subscriptions s
    INNER JOIN Sports sp ON s.SportID = sp.SportID
    WHERE s.SubscriptionID = @SubscriptionID;

    -- Deactivate any existing active subscription for the same sport
    UPDATE ms
    SET ms.IsActive = 0, ms.EndDate = GETDATE()
    FROM MemberSubscriptions ms
    WHERE ms.MemberID = @MemberID 
      AND ms.SubscriptionID IN (SELECT SubscriptionID FROM Subscriptions WHERE SportID = @SportID)
      AND ms.IsActive = 1
      AND ISNULL(ms.DependentMemberNo, '') = ISNULL(@DependentMemberNo, '');

    -- Insert the main record
    INSERT INTO MemberSubscriptions (MemberID, SubscriptionID, StartDate, EndDate, IsActive, DependentMemberNo, DependentName, DependentRelation, PolicyDiscount, GSTAmount, ManualDiscount, NetFee)
    VALUES (@MemberID, @SubscriptionID, @StartDate, @EndDate, 1, @DependentMemberNo, @DependentName, @DependentRelation, @PolicyDiscount, @GSTAmount, @ManualDiscount, @NetFee);

    DECLARE @NewSubID INT = SCOPE_IDENTITY();

    -- Ledger charge
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

    -- AUTO-ASSIGN TO DEPENDENTS for 'Sports Cards'
    IF @SportName = 'Sports Cards' AND ISNULL(@DependentMemberNo, '') = ''
    BEGIN
        DECLARE @DepNo NVARCHAR(50), @DepName NVARCHAR(150), @DepRel NVARCHAR(50);
        
        DECLARE curDeps CURSOR FOR
        SELECT MembershipNo, SpouseName, 'Spouse' 
        FROM MemberShip.dbo.MemberSpouses 
        WHERE MemberID = @MemberID AND RecordStatus = 'Active'
        UNION ALL
        SELECT MembershipNo, ChildName, ISNULL(Relationship, 'Dependent')
        FROM MemberShip.dbo.MemberChildren 
        WHERE MemberID = @MemberID AND RecordStatus = 'Active';

        OPEN curDeps;
        FETCH NEXT FROM curDeps INTO @DepNo, @DepName, @DepRel;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Deactivate existing for this dependent
            UPDATE MemberSubscriptions
            SET IsActive = 0, EndDate = GETDATE()
            WHERE MemberID = @MemberID 
              AND SubscriptionID IN (SELECT SubscriptionID FROM Subscriptions WHERE SportID = @SportID)
              AND IsActive = 1
              AND DependentMemberNo = @DepNo;

            -- Insert for dependent with 0 fee (to avoid double charging)
            INSERT INTO MemberSubscriptions (MemberID, SubscriptionID, StartDate, EndDate, IsActive, DependentMemberNo, DependentName, DependentRelation, PolicyDiscount, GSTAmount, ManualDiscount, NetFee)
            VALUES (@MemberID, @SubscriptionID, @StartDate, @EndDate, 1, @DepNo, @DepName, @DepRel, 0, 0, 0, 0);

            FETCH NEXT FROM curDeps INTO @DepNo, @DepName, @DepRel;
        END

        CLOSE curDeps;
        DEALLOCATE curDeps;
    END
END
