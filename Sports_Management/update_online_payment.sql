-- ==============================================
-- Add Payment fields to MemberSubscriptions and POSTransactions
-- ==============================================

USE SportsModuleDB;
GO

-- 1. Add fields to POSTransactions
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[POSTransactions]') AND name = 'PaymentMode')
BEGIN
    ALTER TABLE [dbo].[POSTransactions] ADD [PaymentMode] VARCHAR(50) NULL DEFAULT 'Cash';
    ALTER TABLE [dbo].[POSTransactions] ADD [CardNo] VARCHAR(20) NULL;
    ALTER TABLE [dbo].[POSTransactions] ADD [ReferenceID] VARCHAR(50) NULL;
END
GO

-- 2. Add fields to MemberSubscriptions
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[MemberSubscriptions]') AND name = 'PaymentMode')
BEGIN
    ALTER TABLE [dbo].[MemberSubscriptions] ADD [PaymentMode] VARCHAR(50) NULL DEFAULT 'Cash';
    ALTER TABLE [dbo].[MemberSubscriptions] ADD [CardNo] VARCHAR(20) NULL;
    ALTER TABLE [dbo].[MemberSubscriptions] ADD [ReferenceID] VARCHAR(50) NULL;
END
GO

-- 3. Update sp_InsertPOSTransaction to accept new parameters
ALTER PROCEDURE [dbo].[sp_InsertPOSTransaction]
    @CustomerType VARCHAR(50),
    @MemberID INT = NULL,
    @DependentMemberNo VARCHAR(50) = NULL,
    @DependentName VARCHAR(100) = NULL,
    @DependentRelation VARCHAR(50) = NULL,
    @CustomerName VARCHAR(100),
    @SubscriptionID INT,
    @Amount DECIMAL(18,2),
    @PolicyDiscount DECIMAL(18,2) = 0,
    @GSTAmount DECIMAL(18,2) = 0,
    @ManualDiscount DECIMAL(18,2) = 0,
    @NetFee DECIMAL(18,2) = 0,
    @AmountPaid DECIMAL(18,2) = 0,
    @Remarks VARCHAR(MAX) = NULL,
    @PaymentMode VARCHAR(50) = 'Cash',
    @CardNo VARCHAR(20) = NULL,
    @ReferenceID VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert into POSTransactions
    INSERT INTO POSTransactions (
        TransactionDate, CustomerType, MemberID, DependentMemberNo, DependentName, DependentRelation, 
        CustomerName, SubscriptionID, Amount, PolicyDiscount, GSTAmount, ManualDiscount, NetFee, AmountPaid, Remarks, PaymentMode, CardNo, ReferenceID
    )
    VALUES (
        GETDATE(), @CustomerType, @MemberID, @DependentMemberNo, @DependentName, @DependentRelation, 
        @CustomerName, @SubscriptionID, @Amount, @PolicyDiscount, @GSTAmount, @ManualDiscount, @NetFee, @AmountPaid, @Remarks, @PaymentMode, @CardNo, @ReferenceID
    );

    DECLARE @NewTransactionID INT = SCOPE_IDENTITY();

    -- Return the new Transaction ID
    SELECT @NewTransactionID;
END
GO

-- 4. Update sp_AssignSubscription to accept new parameters
ALTER PROCEDURE [dbo].[sp_AssignSubscription]
    @MemberID INT,
    @SubscriptionID INT,
    @StartDate DATE,
    @EndDate DATE = NULL,
    @PolicyDiscount DECIMAL(18,2) = 0,
    @GSTAmount DECIMAL(18,2) = 0,
    @ManualDiscount DECIMAL(18,2) = 0,
    @NetFee DECIMAL(18,2) = 0,
    @DependentMemberNo VARCHAR(50) = NULL,
    @DependentName VARCHAR(100) = NULL,
    @DependentRelation VARCHAR(50) = NULL,
    @PaymentMode VARCHAR(50) = 'Cash',
    @CardNo VARCHAR(20) = NULL,
    @ReferenceID VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Update IsActive to 0 for any current active subscription of the same package for this user
    UPDATE MemberSubscriptions
    SET IsActive = 0, EndDate = GETDATE()
    WHERE MemberID = @MemberID 
      AND SubscriptionID = @SubscriptionID 
      AND IsActive = 1
      AND (
            (@DependentMemberNo IS NULL AND DependentMemberNo IS NULL) OR 
            (DependentMemberNo = @DependentMemberNo)
          );

    -- Insert new active subscription
    INSERT INTO MemberSubscriptions (
        MemberID, 
        SubscriptionID, 
        StartDate, 
        EndDate, 
        IsActive, 
        AssignedDate,
        PolicyDiscount,
        GSTAmount,
        ManualDiscount,
        NetFee,
        DependentMemberNo,
        DependentName,
        DependentRelation,
        PaymentMode,
        CardNo,
        ReferenceID
    )
    VALUES (
        @MemberID, 
        @SubscriptionID, 
        @StartDate, 
        @EndDate, 
        1, 
        GETDATE(),
        @PolicyDiscount,
        @GSTAmount,
        @ManualDiscount,
        @NetFee,
        @DependentMemberNo,
        @DependentName,
        @DependentRelation,
        @PaymentMode,
        @CardNo,
        @ReferenceID
    );

    DECLARE @NewMemberSubID INT = SCOPE_IDENTITY();
    SELECT @NewMemberSubID;
END
GO
