USE [SportsModuleDB]
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DiscountPolicies')
BEGIN
    CREATE TABLE DiscountPolicies (
        PolicyID INT IDENTITY(1,1) PRIMARY KEY,
        PolicyName NVARCHAR(100) NOT NULL,
        MinAge INT NULL,
        MaxAge INT NULL,
        MinMembershipYears INT NULL,
        IsChild BIT NOT NULL DEFAULT 0,
        ConditionOperator VARCHAR(5) NOT NULL DEFAULT 'OR', -- 'AND' or 'OR'
        DiscountPercentage DECIMAL(18,2) NOT NULL DEFAULT 0,
        IsActive BIT NOT NULL DEFAULT 1
    );

    -- Insert Default Policies
    INSERT INTO DiscountPolicies (PolicyName, MinAge, MinMembershipYears, IsChild, ConditionOperator, DiscountPercentage)
    VALUES ('65+ Years Discount (50% Off)', 65, NULL, 0, 'OR', 50.00);

    INSERT INTO DiscountPolicies (PolicyName, MinAge, MinMembershipYears, IsChild, ConditionOperator, DiscountPercentage)
    VALUES ('30 Years Membership Discount', NULL, 30, 0, 'OR', 50.00);

    INSERT INTO DiscountPolicies (PolicyName, MinAge, MinMembershipYears, IsChild, ConditionOperator, DiscountPercentage)
    VALUES ('80+ Years Free', 80, NULL, 0, 'OR', 100.00);

    INSERT INTO DiscountPolicies (PolicyName, MinAge, MinMembershipYears, IsChild, ConditionOperator, DiscountPercentage)
    VALUES ('Child Half Charge', NULL, NULL, 1, 'OR', 50.00);

    -- NEW RULE FROM USER
    INSERT INTO DiscountPolicies (PolicyName, MinAge, MinMembershipYears, IsChild, ConditionOperator, DiscountPercentage)
    VALUES ('30 Yrs Membership AND 80+ Age Free', 80, 30, 0, 'AND', 100.00);
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SubscriptionDiscountPolicies')
BEGIN
    CREATE TABLE SubscriptionDiscountPolicies (
        SubscriptionID INT NOT NULL,
        PolicyID INT NOT NULL,
        PRIMARY KEY (SubscriptionID, PolicyID),
        FOREIGN KEY (SubscriptionID) REFERENCES Subscriptions(SubscriptionID) ON DELETE CASCADE,
        FOREIGN KEY (PolicyID) REFERENCES DiscountPolicies(PolicyID) ON DELETE CASCADE
    );

    -- Migrate existing data
    INSERT INTO SubscriptionDiscountPolicies (SubscriptionID, PolicyID)
    SELECT SubscriptionID, (SELECT PolicyID FROM DiscountPolicies WHERE PolicyName = '65+ Years Discount (50% Off)')
    FROM Subscriptions WHERE Allow65PlusDiscount = 1;

    INSERT INTO SubscriptionDiscountPolicies (SubscriptionID, PolicyID)
    SELECT SubscriptionID, (SELECT PolicyID FROM DiscountPolicies WHERE PolicyName = '30 Years Membership Discount')
    FROM Subscriptions WHERE Allow30YearsDiscount = 1;

    INSERT INTO SubscriptionDiscountPolicies (SubscriptionID, PolicyID)
    SELECT SubscriptionID, (SELECT PolicyID FROM DiscountPolicies WHERE PolicyName = '80+ Years Free')
    FROM Subscriptions WHERE Allow80PlusFree = 1;

    INSERT INTO SubscriptionDiscountPolicies (SubscriptionID, PolicyID)
    SELECT SubscriptionID, (SELECT PolicyID FROM DiscountPolicies WHERE PolicyName = 'Child Half Charge')
    FROM Subscriptions WHERE AllowChildHalfCharge = 1;
END
GO

IF OBJECT_ID('fn_GetDynamicDiscountPercentage', 'FN') IS NOT NULL
    DROP FUNCTION fn_GetDynamicDiscountPercentage;
GO

CREATE FUNCTION fn_GetDynamicDiscountPercentage (
    @MemberID INT,
    @DependentMemberNo NVARCHAR(100),
    @SubscriptionID INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @DOB DATETIME = NULL;
    DECLARE @FirstSubDate DATETIME = NULL;
    DECLARE @Age INT = 0;
    DECLARE @Tenure INT = 0;
    DECLARE @Rel NVARCHAR(50) = '';
    
    IF LTRIM(RTRIM(ISNULL(@DependentMemberNo, ''))) = ''
        SET @DependentMemberNo = NULL;

    IF @DependentMemberNo IS NULL
    BEGIN
        SELECT TOP 1 @DOB = DOB FROM MemberShip.dbo.MemberProfile WHERE MemberID = @MemberID OR MemberID_New = @MemberID;
        SET @Rel = 'Self';
    END
    ELSE
    BEGIN
        IF EXISTS (SELECT 1 FROM MemberShip.dbo.MemberChildren WHERE MembershipNo = @DependentMemberNo)
        BEGIN
            SELECT TOP 1 @DOB = DOB FROM MemberShip.dbo.MemberChildren WHERE MembershipNo = @DependentMemberNo;
            SET @Rel = 'Child';
        END
        ELSE
        BEGIN
            SELECT TOP 1 @DOB = DOB FROM MemberShip.dbo.MemberProfile WHERE MemberID = @MemberID OR MemberID_New = @MemberID;
            SET @Rel = 'Spouse';
        END
    END

    IF @DOB IS NOT NULL
    BEGIN
        SET @Age = DATEDIFF(YEAR, @DOB, GETDATE());
        IF (DATEADD(YEAR, @Age, @DOB) > GETDATE()) SET @Age = @Age - 1;
    END

    SELECT @FirstSubDate = MIN(StartDate) 
    FROM MemberSubscriptions 
    WHERE MemberID = @MemberID 
    AND ISNULL(DependentMemberNo, '') = ISNULL(@DependentMemberNo, '');

    IF @FirstSubDate IS NULL AND @DependentMemberNo IS NULL
    BEGIN
        SELECT TOP 1 @FirstSubDate = CreatedDate FROM MemberShip.dbo.MemberProfile WHERE MemberID = @MemberID OR MemberID_New = @MemberID;
    END

    IF @FirstSubDate IS NOT NULL
    BEGIN
        SET @Tenure = DATEDIFF(YEAR, @FirstSubDate, GETDATE());
        IF (DATEADD(YEAR, @Tenure, @FirstSubDate) > GETDATE()) SET @Tenure = @Tenure - 1;
    END

    DECLARE @MaxDiscount DECIMAL(18,2) = 0;

    SELECT @MaxDiscount = ISNULL(MAX(DiscountPercentage), 0)
    FROM DiscountPolicies dp
    INNER JOIN SubscriptionDiscountPolicies sdp ON dp.PolicyID = sdp.PolicyID
    WHERE sdp.SubscriptionID = @SubscriptionID
      AND dp.IsActive = 1
      AND (
          (dp.ConditionOperator = 'AND' AND
             (@Age >= ISNULL(dp.MinAge, 0) OR dp.MinAge IS NULL) AND 
             (@Tenure >= ISNULL(dp.MinMembershipYears, 0) OR dp.MinMembershipYears IS NULL) AND
             (dp.IsChild = 0 OR @Rel = 'Child')
          )
          OR
          (dp.ConditionOperator = 'OR' AND
             (
                (dp.MinAge IS NOT NULL AND @Age >= dp.MinAge) OR
                (dp.MinMembershipYears IS NOT NULL AND @Tenure >= dp.MinMembershipYears) OR
                (dp.IsChild = 1 AND @Rel = 'Child')
             )
          )
      );

    RETURN @MaxDiscount;
END
GO

IF OBJECT_ID('sp_GetDiscountPolicies', 'P') IS NOT NULL DROP PROCEDURE sp_GetDiscountPolicies;
GO
CREATE PROCEDURE sp_GetDiscountPolicies
    @IncludeInactive BIT = 0
AS
BEGIN
    SELECT * FROM DiscountPolicies
    WHERE IsActive = 1 OR @IncludeInactive = 1
    ORDER BY PolicyID;
END
GO

IF OBJECT_ID('sp_InsertDiscountPolicy', 'P') IS NOT NULL DROP PROCEDURE sp_InsertDiscountPolicy;
GO
CREATE PROCEDURE sp_InsertDiscountPolicy
    @PolicyName NVARCHAR(100),
    @MinAge INT,
    @MinMembershipYears INT,
    @IsChild BIT,
    @ConditionOperator VARCHAR(5),
    @DiscountPercentage DECIMAL(18,2),
    @IsActive BIT
AS
BEGIN
    INSERT INTO DiscountPolicies (PolicyName, MinAge, MinMembershipYears, IsChild, ConditionOperator, DiscountPercentage, IsActive)
    VALUES (@PolicyName, @MinAge, @MinMembershipYears, @IsChild, @ConditionOperator, @DiscountPercentage, @IsActive);
END
GO

IF OBJECT_ID('sp_UpdateDiscountPolicy', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateDiscountPolicy;
GO
CREATE PROCEDURE sp_UpdateDiscountPolicy
    @PolicyID INT,
    @PolicyName NVARCHAR(100),
    @MinAge INT,
    @MinMembershipYears INT,
    @IsChild BIT,
    @ConditionOperator VARCHAR(5),
    @DiscountPercentage DECIMAL(18,2),
    @IsActive BIT
AS
BEGIN
    UPDATE DiscountPolicies
    SET PolicyName = @PolicyName,
        MinAge = @MinAge,
        MinMembershipYears = @MinMembershipYears,
        IsChild = @IsChild,
        ConditionOperator = @ConditionOperator,
        DiscountPercentage = @DiscountPercentage,
        IsActive = @IsActive
    WHERE PolicyID = @PolicyID;
END
GO

IF OBJECT_ID('sp_InsertSubscription', 'P') IS NOT NULL DROP PROCEDURE sp_InsertSubscription;
GO
CREATE PROCEDURE [sp_InsertSubscription]
    @SportID INT,
    @PackageName NVARCHAR(100),
    @SubscriptionType NVARCHAR(50),
    @Fee DECIMAL(18,2),
    @Status BIT,
    @PolicyIDs NVARCHAR(MAX) = ''
AS
BEGIN
    BEGIN TRAN;
    BEGIN TRY
        INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, Status, Allow65PlusDiscount, Allow30YearsDiscount, Allow80PlusFree, AllowChildHalfCharge)
        VALUES (@SportID, @PackageName, @SubscriptionType, @Fee, @Status, 0, 0, 0, 0);
        
        DECLARE @NewSubID INT = SCOPE_IDENTITY();
        
        IF LTRIM(RTRIM(@PolicyIDs)) <> ''
        BEGIN
            INSERT INTO SubscriptionDiscountPolicies (SubscriptionID, PolicyID)
            SELECT @NewSubID, CAST(value AS INT)
            FROM string_split(@PolicyIDs, ',')
            WHERE RTRIM(value) <> '';
        END
        
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO

IF OBJECT_ID('sp_UpdateSubscription', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateSubscription;
GO
CREATE PROCEDURE [sp_UpdateSubscription]
    @SubscriptionID INT,
    @SportID INT,
    @PackageName NVARCHAR(100),
    @SubscriptionType NVARCHAR(50),
    @Fee DECIMAL(18,2),
    @Status BIT,
    @PolicyIDs NVARCHAR(MAX) = ''
AS
BEGIN
    BEGIN TRAN;
    BEGIN TRY
        UPDATE Subscriptions
        SET SportID = @SportID,
            PackageName = @PackageName,
            SubscriptionType = @SubscriptionType,
            Fee = @Fee,
            Status = @Status
        WHERE SubscriptionID = @SubscriptionID;
        
        DELETE FROM SubscriptionDiscountPolicies WHERE SubscriptionID = @SubscriptionID;

        IF LTRIM(RTRIM(@PolicyIDs)) <> ''
        BEGIN
            INSERT INTO SubscriptionDiscountPolicies (SubscriptionID, PolicyID)
            SELECT @SubscriptionID, CAST(value AS INT)
            FROM string_split(@PolicyIDs, ',')
            WHERE RTRIM(value) <> '';
        END

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO

IF OBJECT_ID('sp_GetSubscriptions', 'P') IS NOT NULL DROP PROCEDURE sp_GetSubscriptions;
GO
CREATE PROCEDURE [sp_GetSubscriptions]
AS
BEGIN
    SELECT s.SubscriptionID, s.SportID, sp.SportName, s.PackageName, s.SubscriptionType, s.Fee, s.GSTPercentage, s.Status,
           (SELECT STRING_AGG(CAST(PolicyID AS VARCHAR(10)), ',') FROM SubscriptionDiscountPolicies WHERE SubscriptionID = s.SubscriptionID) AS PolicyIDs
    FROM Subscriptions s
    INNER JOIN Sports sp ON s.SportID = sp.SportID
    ORDER BY sp.SportName, s.PackageName;
END
GO
