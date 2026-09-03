-- 1. Add columns to Subscriptions table
ALTER TABLE Subscriptions ADD Allow65PlusDiscount BIT NOT NULL DEFAULT 0;
ALTER TABLE Subscriptions ADD Allow30YearsDiscount BIT NOT NULL DEFAULT 0;
ALTER TABLE Subscriptions ADD Allow80PlusFree BIT NOT NULL DEFAULT 0;
ALTER TABLE Subscriptions ADD AllowChildHalfCharge BIT NOT NULL DEFAULT 0;
GO

-- 2. Update sp_InsertSubscription
ALTER PROCEDURE [sp_InsertSubscription]
    @SportID INT,
    @PackageName NVARCHAR(100),
    @SubscriptionType NVARCHAR(50),
    @Fee DECIMAL(18,2),
    @Status BIT,
    @Allow65PlusDiscount BIT = 0,
    @Allow30YearsDiscount BIT = 0,
    @Allow80PlusFree BIT = 0,
    @AllowChildHalfCharge BIT = 0
AS
BEGIN
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, Status, Allow65PlusDiscount, Allow30YearsDiscount, Allow80PlusFree, AllowChildHalfCharge)
    VALUES (@SportID, @PackageName, @SubscriptionType, @Fee, @Status, @Allow65PlusDiscount, @Allow30YearsDiscount, @Allow80PlusFree, @AllowChildHalfCharge);
END
GO

-- 3. Update sp_UpdateSubscription
ALTER PROCEDURE [sp_UpdateSubscription]
    @SubscriptionID INT,
    @SportID INT,
    @PackageName NVARCHAR(100),
    @SubscriptionType NVARCHAR(50),
    @Fee DECIMAL(18,2),
    @Status BIT,
    @Allow65PlusDiscount BIT = 0,
    @Allow30YearsDiscount BIT = 0,
    @Allow80PlusFree BIT = 0,
    @AllowChildHalfCharge BIT = 0
AS
BEGIN
    UPDATE Subscriptions
    SET SportID = @SportID,
        PackageName = @PackageName,
        SubscriptionType = @SubscriptionType,
        Fee = @Fee,
        Status = @Status,
        Allow65PlusDiscount = @Allow65PlusDiscount,
        Allow30YearsDiscount = @Allow30YearsDiscount,
        Allow80PlusFree = @Allow80PlusFree,
        AllowChildHalfCharge = @AllowChildHalfCharge
    WHERE SubscriptionID = @SubscriptionID;
END
GO

-- 4. Update sp_GetSubscriptions
ALTER PROCEDURE [sp_GetSubscriptions]
AS
BEGIN
    SELECT s.SubscriptionID, s.SportID, sp.SportName, s.PackageName, s.SubscriptionType, s.Fee, s.GSTPercentage, s.Status,
           s.Allow65PlusDiscount, s.Allow30YearsDiscount, s.Allow80PlusFree, s.AllowChildHalfCharge
    FROM Subscriptions s
    INNER JOIN Sports sp ON s.SportID = sp.SportID
    ORDER BY sp.SportName, s.PackageName;
END
GO
