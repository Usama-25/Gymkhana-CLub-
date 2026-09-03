USE [SportsModuleDB];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Add IsEditable column to Subscriptions table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Subscriptions') AND name = 'IsEditable')
BEGIN
    ALTER TABLE Subscriptions ADD IsEditable BIT NOT NULL CONSTRAINT DF_Subscriptions_IsEditable DEFAULT 1;
END
GO

-- 2. Update sp_GetDailyPackages to include IsEditable
IF OBJECT_ID('sp_GetDailyPackages', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetDailyPackages;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [dbo].[sp_GetDailyPackages]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        s.SubscriptionID, 
        s.SportID, 
        sp.SportName, 
        s.PackageName, 
        s.Fee,
        s.ItemCode,
        s.GSTPercentage,
        ISNULL(s.IsEditable, 1) AS IsEditable
    FROM Subscriptions s
    INNER JOIN Sports sp ON s.SportID = sp.SportID
    WHERE s.SubscriptionType = 'Daily' AND s.Status = 1
    ORDER BY sp.SportName, s.PackageName;
END
GO

-- 3. Update sp_GetSubscriptions to include IsEditable and handle XML PATH correctly
IF OBJECT_ID('sp_GetSubscriptions', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetSubscriptions;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [dbo].[sp_GetSubscriptions]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        s.SubscriptionID, 
        s.SportID, 
        sp.SportName, 
        s.PackageName, 
        s.SubscriptionType, 
        s.Fee, 
        s.Status,
        s.ItemCode,
        ISNULL(s.IsEditable, 1) AS IsEditable,
        STUFF((
            SELECT ',' + CAST(sdp.PolicyID AS VARCHAR(10))
            FROM SubscriptionDiscountPolicies sdp
            WHERE sdp.SubscriptionID = s.SubscriptionID
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') AS PolicyIDs
    FROM Subscriptions s
    INNER JOIN Sports sp ON s.SportID = sp.SportID
    ORDER BY sp.SportName, s.PackageName;
END
GO

-- 4. Update sp_InsertSubscription to accept @IsEditable
IF OBJECT_ID('sp_InsertSubscription', 'P') IS NOT NULL
    DROP PROCEDURE sp_InsertSubscription;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [dbo].[sp_InsertSubscription]
    @SportID INT,
    @PackageName NVARCHAR(100),
    @SubscriptionType NVARCHAR(50),
    @Fee DECIMAL(18,2),
    @Status BIT,
    @PolicyIDs NVARCHAR(MAX) = NULL,
    @ItemCode NVARCHAR(20) = NULL,
    @IsEditable BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    -- If ItemCode is not provided, generate it based on Sport
    IF @ItemCode IS NULL OR LTRIM(RTRIM(@ItemCode)) = ''
    BEGIN
        DECLARE @Prefix NVARCHAR(10);
        SELECT @Prefix = UPPER(LEFT(REPLACE(SportName, ' ', ''), 3)) FROM Sports WHERE SportID = @SportID;
        IF @Prefix IS NULL OR @Prefix = '' SET @Prefix = 'SUB';

        DECLARE @Counter INT = 1;
        SELECT @Counter = ISNULL(MAX(CAST(SUBSTRING(ItemCode, LEN(@Prefix) + 1, LEN(ItemCode)) AS INT)), 0) + 1
        FROM Subscriptions
        WHERE ItemCode LIKE @Prefix + '%' AND ISNUMERIC(SUBSTRING(ItemCode, LEN(@Prefix) + 1, LEN(ItemCode))) = 1;

        SET @ItemCode = @Prefix + RIGHT('000' + CAST(@Counter AS NVARCHAR), 3);
    END

    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, Status, ItemCode, IsEditable)
    VALUES (@SportID, @PackageName, @SubscriptionType, @Fee, @Status, @ItemCode, @IsEditable);

    DECLARE @NewID INT = SCOPE_IDENTITY();

    IF @PolicyIDs IS NOT NULL AND LTRIM(RTRIM(@PolicyIDs)) <> ''
    BEGIN
        INSERT INTO SubscriptionDiscountPolicies (SubscriptionID, PolicyID)
        SELECT @NewID, CAST(Value AS INT)
        FROM dbo.fn_SplitString(@PolicyIDs, ',');
    END

    SELECT @NewID AS SubscriptionID;
END
GO

-- 5. Update sp_UpdateSubscription to accept @IsEditable
IF OBJECT_ID('sp_UpdateSubscription', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateSubscription;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [dbo].[sp_UpdateSubscription]
    @SubscriptionID INT,
    @SportID INT,
    @PackageName NVARCHAR(100),
    @SubscriptionType NVARCHAR(50),
    @Fee DECIMAL(18,2),
    @Status BIT,
    @PolicyIDs NVARCHAR(MAX) = NULL,
    @ItemCode NVARCHAR(20) = NULL,
    @IsEditable BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Subscriptions
    SET SportID = @SportID,
        PackageName = @PackageName,
        SubscriptionType = @SubscriptionType,
        Fee = @Fee,
        Status = @Status,
        ItemCode = ISNULL(@ItemCode, ItemCode),
        IsEditable = @IsEditable
    WHERE SubscriptionID = @SubscriptionID;

    DELETE FROM SubscriptionDiscountPolicies WHERE SubscriptionID = @SubscriptionID;

    IF @PolicyIDs IS NOT NULL AND LTRIM(RTRIM(@PolicyIDs)) <> ''
    BEGIN
        INSERT INTO SubscriptionDiscountPolicies (SubscriptionID, PolicyID)
        SELECT @SubscriptionID, CAST(Value AS INT)
        FROM dbo.fn_SplitString(@PolicyIDs, ',');
    END
END
GO
