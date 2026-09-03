USE [SportsModuleDB]
GO

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
    DECLARE @SubscriptionType NVARCHAR(50);
    
    SELECT @SportID = SportID, @SubscriptionType = SubscriptionType 
    FROM Subscriptions 
    WHERE SubscriptionID = @SubscriptionID;

    UPDATE ms
    SET ms.IsActive = 0, ms.EndDate = GETDATE()
    FROM MemberSubscriptions ms
    INNER JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
    WHERE ms.MemberID = @MemberID 
      AND s.SportID = @SportID
      AND ms.IsActive = 1
      AND ISNULL(ms.DependentMemberNo, '') = ISNULL(@DependentMemberNo, '');

    INSERT INTO MemberSubscriptions (
        MemberID, SubscriptionID, StartDate, EndDate, IsActive, 
        DependentMemberNo, DependentName, DependentRelation, 
        PolicyDiscount, GSTAmount, ManualDiscount, NetFee, 
        BankID, BankDiscount, LockerID, LockerFee, LastBilledDate
    )
    VALUES (
        @MemberID, @SubscriptionID, @StartDate, @EndDate, 1, 
        @DependentMemberNo, @DependentName, @DependentRelation, 
        @PolicyDiscount, @GSTAmount, @ManualDiscount, @NetFee, 
        @BankID, @BankDiscount, @LockerID, @LockerFee, NULL
    );
END
GO
