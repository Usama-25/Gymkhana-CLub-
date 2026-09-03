USE [SportsModuleDB]
GO

-- 1. Get Active Subscriptions for a Member with Policy Rules
IF OBJECT_ID('sp_GetActiveSubscriptionsForCharge', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetActiveSubscriptionsForCharge;
GO

CREATE PROCEDURE sp_GetActiveSubscriptionsForCharge
    @MemberID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Create a temporary table to hold subscriptions with calculated Age and Tenure
    SELECT 
        ms.MemberSubID,
        ms.SubscriptionID,
        s.SportID,
        sp.SportName,
        s.PackageName,
        ms.DependentMemberNo,
        ms.DependentName,
        ms.DependentRelation,
        s.Fee AS BaseFee,
        s.GSTPercentage,
        ISNULL(s.Allow65PlusDiscount, 0) AS Allow65PlusDiscount,
        ISNULL(s.Allow30YearsDiscount, 0) AS Allow30YearsDiscount,
        ISNULL(s.Allow80PlusFree, 0) AS Allow80PlusFree,
        ISNULL(s.AllowChildHalfCharge, 0) AS AllowChildHalfCharge,
        ms.LastBilledDate,
        -- We will calculate these next
        0 AS MemberAge,
        0 AS MemberTenure
    INTO #ActiveSubs
    FROM MemberSubscriptions ms
    INNER JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
    INNER JOIN Sports sp ON s.SportID = sp.SportID
    WHERE ms.MemberID = @MemberID 
      AND ms.IsActive = 1;

    -- Calculate Age and Tenure for each row
    DECLARE @MemberSubID INT, @DepNo NVARCHAR(100);
    DECLARE @DOB DATETIME, @FirstSubDate DATETIME;
    DECLARE @Age INT, @Tenure INT;

    DECLARE cur CURSOR FOR SELECT MemberSubID, DependentMemberNo FROM #ActiveSubs;
    OPEN cur;
    FETCH NEXT FROM cur INTO @MemberSubID, @DepNo;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @DOB = NULL;
        SET @FirstSubDate = NULL;
        SET @Age = 0;
        SET @Tenure = 0;

        IF LTRIM(RTRIM(ISNULL(@DepNo, ''))) = '' SET @DepNo = NULL;

        -- Get DOB
        IF @DepNo IS NULL
        BEGIN
            SELECT TOP 1 @DOB = DOB FROM MemberShip.dbo.MemberProfile WHERE MemberID = @MemberID OR MemberID_New = @MemberID;
        END
        ELSE
        BEGIN
            SELECT TOP 1 @DOB = DOB FROM MemberShip.dbo.MemberChildren WHERE MembershipNo = @DepNo;
            IF @DOB IS NULL
                SELECT TOP 1 @DOB = DOB FROM MemberShip.dbo.MemberProfile WHERE MemberID = @MemberID OR MemberID_New = @MemberID;
        END

        IF @DOB IS NOT NULL
        BEGIN
            SET @Age = DATEDIFF(YEAR, @DOB, GETDATE());
            IF (DATEADD(YEAR, @Age, @DOB) > GETDATE()) SET @Age = @Age - 1;
        END

        -- Get Tenure
        SELECT @FirstSubDate = MIN(StartDate) 
        FROM MemberSubscriptions 
        WHERE MemberID = @MemberID AND ISNULL(DependentMemberNo, '') = ISNULL(@DepNo, '');

        IF @FirstSubDate IS NULL AND @DepNo IS NULL
        BEGIN
            SELECT TOP 1 @FirstSubDate = CreatedDate FROM MemberShip.dbo.MemberProfile WHERE MemberID = @MemberID OR MemberID_New = @MemberID;
        END

        IF @FirstSubDate IS NOT NULL
        BEGIN
            SET @Tenure = DATEDIFF(YEAR, @FirstSubDate, GETDATE());
            IF (DATEADD(YEAR, @Tenure, @FirstSubDate) > GETDATE()) SET @Tenure = @Tenure - 1;
        END

        UPDATE #ActiveSubs 
        SET MemberAge = @Age, MemberTenure = @Tenure 
        WHERE MemberSubID = @MemberSubID;

        FETCH NEXT FROM cur INTO @MemberSubID, @DepNo;
    END

    CLOSE cur;
    DEALLOCATE cur;

    SELECT * FROM #ActiveSubs;
    DROP TABLE #ActiveSubs;
END
GO

-- 2. Process Ledger Payment (Credit)
IF OBJECT_ID('sp_ProcessLedgerPayment', 'P') IS NOT NULL
    DROP PROCEDURE sp_ProcessLedgerPayment;
GO

CREATE PROCEDURE sp_ProcessLedgerPayment
    @MemberID INT,
    @AmountPaid DECIMAL(18,2),
    @PaymentMode NVARCHAR(50),
    @BankID INT = NULL,
    @CardNo NVARCHAR(50) = NULL,
    @ReferenceID NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @AmountPaid <= 0 RETURN;

    DECLARE @Desc NVARCHAR(255) = 'Payment Received';
    IF @PaymentMode IS NOT NULL AND @PaymentMode <> 'Cash'
    BEGIN
        SET @Desc = @Desc + ' [' + @PaymentMode + ' Ref: ' + ISNULL(@ReferenceID, '') + ']';
    END

    INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID)
    VALUES (@MemberID, GETDATE(), @Desc, 0, @AmountPaid, 'Payment', 0);
END
GO

-- 3. Charge Subscription To Ledger (Debit)
IF OBJECT_ID('sp_ChargeSubscriptionToLedger', 'P') IS NOT NULL
    DROP PROCEDURE sp_ChargeSubscriptionToLedger;
GO

CREATE PROCEDURE sp_ChargeSubscriptionToLedger
    @MemberID INT,
    @MemberSubID INT,
    @ChargeAmount DECIMAL(18,2),
    @BillingPeriod NVARCHAR(50) -- e.g., 'August 2026'
AS
BEGIN
    SET NOCOUNT ON;

    IF @ChargeAmount <= 0 RETURN;

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

    INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID, DependentMemberNo, DependentRelation)
    VALUES (@MemberID, GETDATE(), @Desc, @ChargeAmount, 0, 'SubscriptionCharge', @MemberSubID, @DepNo, @DepRelation);
    
    -- Update LastBilledDate in MemberSubscriptions
    UPDATE MemberSubscriptions
    SET LastBilledDate = GETDATE()
    WHERE MemberSubID = @MemberSubID;
END
GO
