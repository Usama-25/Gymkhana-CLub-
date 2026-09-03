USE [SportsModuleDB];
GO

-- 1. Add ItemCode column
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Subscriptions') AND name = 'ItemCode')
BEGIN
    ALTER TABLE Subscriptions ADD ItemCode NVARCHAR(20) NULL;
END
GO

-- 2. Populate existing ItemCodes dynamically if they are NULL
DECLARE @SubscriptionID INT;
DECLARE @SportName NVARCHAR(100);
DECLARE @Prefix NVARCHAR(10);
DECLARE @Counter INT;
DECLARE @NewItemCode NVARCHAR(20);

DECLARE subCursor CURSOR FOR 
SELECT s.SubscriptionID, sp.SportName
FROM Subscriptions s
INNER JOIN Sports sp ON s.SportID = sp.SportID
WHERE s.ItemCode IS NULL
ORDER BY sp.SportName, s.SubscriptionID;

OPEN subCursor;
FETCH NEXT FROM subCursor INTO @SubscriptionID, @SportName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Determine Prefix based on SportName
    IF @SportName LIKE 'Tennis%' SET @Prefix = 'T';
    ELSE IF @SportName LIKE 'Gym%' SET @Prefix = 'G';
    ELSE IF @SportName LIKE 'Golf%' SET @Prefix = 'GL';
    ELSE IF @SportName LIKE 'Squash%' SET @Prefix = 'S';
    ELSE IF @SportName LIKE 'Cricket%' SET @Prefix = 'C';
    ELSE IF @SportName LIKE 'Swimming%' SET @Prefix = 'SW';
    ELSE IF @SportName LIKE 'Billiard%' SET @Prefix = 'B';
    ELSE SET @Prefix = SUBSTRING(@SportName, 1, 2);

    -- Find the next available number for this prefix
    SELECT @Counter = ISNULL(MAX(CAST(SUBSTRING(ItemCode, LEN(@Prefix) + 1, LEN(ItemCode)) AS INT)), 0) + 1
    FROM Subscriptions
    WHERE ItemCode LIKE @Prefix + '%' AND ISNUMERIC(SUBSTRING(ItemCode, LEN(@Prefix) + 1, LEN(ItemCode))) = 1;

    SET @NewItemCode = @Prefix + RIGHT('000' + CAST(@Counter AS NVARCHAR), 3);

    UPDATE Subscriptions SET ItemCode = @NewItemCode WHERE SubscriptionID = @SubscriptionID;

    FETCH NEXT FROM subCursor INTO @SubscriptionID, @SportName;
END

CLOSE subCursor;
DEALLOCATE subCursor;
GO

-- 3. Update Stored Procedures to handle ItemCode
ALTER PROCEDURE [sp_GetSubscriptions]
AS
BEGIN
    SELECT 
        s.SubscriptionID, 
        s.SportID, 
        sp.SportName, 
        s.PackageName, 
        s.SubscriptionType, 
        s.Fee, 
        s.Status,
        s.ItemCode,
        s.GSTPercentage,
        s.Allow65PlusDiscount,
        s.Allow30YearsDiscount,
        s.Allow80PlusFree,
        s.AllowChildHalfCharge
    FROM Subscriptions s
    INNER JOIN Sports sp ON s.SportID = sp.SportID
    ORDER BY sp.SportName, s.PackageName;
END
GO

ALTER PROCEDURE [sp_InsertSubscription]
    @SportID INT,
    @PackageName NVARCHAR(100),
    @SubscriptionType NVARCHAR(50),
    @Fee DECIMAL(18,2),
    @Status BIT,
    @Allow65PlusDiscount BIT = 0,
    @Allow30YearsDiscount BIT = 0,
    @Allow80PlusFree BIT = 0,
    @AllowChildHalfCharge BIT = 0,
    @ItemCode NVARCHAR(20) = NULL
AS
BEGIN
    -- If ItemCode is not provided, generate it based on Sport
    IF @ItemCode IS NULL OR LTRIM(RTRIM(@ItemCode)) = ''
    BEGIN
        DECLARE @SportName NVARCHAR(100);
        DECLARE @Prefix NVARCHAR(10);
        DECLARE @Counter INT;

        SELECT @SportName = SportName FROM Sports WHERE SportID = @SportID;

        IF @SportName LIKE 'Tennis%' SET @Prefix = 'T';
        ELSE IF @SportName LIKE 'Gym%' SET @Prefix = 'G';
        ELSE IF @SportName LIKE 'Golf%' SET @Prefix = 'GL';
        ELSE IF @SportName LIKE 'Squash%' SET @Prefix = 'S';
        ELSE IF @SportName LIKE 'Cricket%' SET @Prefix = 'C';
        ELSE IF @SportName LIKE 'Swimming%' SET @Prefix = 'SW';
        ELSE IF @SportName LIKE 'Billiard%' SET @Prefix = 'B';
        ELSE SET @Prefix = SUBSTRING(@SportName, 1, 2);

        SELECT @Counter = ISNULL(MAX(CAST(SUBSTRING(ItemCode, LEN(@Prefix) + 1, LEN(ItemCode)) AS INT)), 0) + 1
        FROM Subscriptions
        WHERE ItemCode LIKE @Prefix + '%' AND ISNUMERIC(SUBSTRING(ItemCode, LEN(@Prefix) + 1, LEN(ItemCode))) = 1;

        SET @ItemCode = @Prefix + RIGHT('000' + CAST(@Counter AS NVARCHAR), 3);
    END

    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, Status, 
                               Allow65PlusDiscount, Allow30YearsDiscount, Allow80PlusFree, AllowChildHalfCharge, ItemCode)
    VALUES (@SportID, @PackageName, @SubscriptionType, @Fee, @Status, 
            @Allow65PlusDiscount, @Allow30YearsDiscount, @Allow80PlusFree, @AllowChildHalfCharge, @ItemCode);
END
GO

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
    @AllowChildHalfCharge BIT = 0,
    @ItemCode NVARCHAR(20) = NULL
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
        AllowChildHalfCharge = @AllowChildHalfCharge,
        ItemCode = ISNULL(@ItemCode, ItemCode)
    WHERE SubscriptionID = @SubscriptionID;
END
GO

ALTER PROCEDURE [sp_GetDailyPackages]
AS
BEGIN
    SELECT 
        s.SubscriptionID, 
        s.SportID, 
        sp.SportName, 
        s.PackageName, 
        s.Fee,
        s.ItemCode
    FROM Subscriptions s
    INNER JOIN Sports sp ON s.SportID = sp.SportID
    WHERE s.SubscriptionType = 'Daily' AND s.Status = 1
    ORDER BY sp.SportName, s.PackageName;
END
GO
