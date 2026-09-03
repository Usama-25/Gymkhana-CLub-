USE [SportsModuleDB];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Ensure DiscountPolicies table exists
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
END
GO

-- 2. Upsert default policy definitions (65+ Years, Child Half Charge, 30 Yrs Membership AND 80+ Age Free)
IF NOT EXISTS (SELECT 1 FROM DiscountPolicies WHERE PolicyName LIKE '%65+%')
BEGIN
    INSERT INTO DiscountPolicies (PolicyName, MinAge, MinMembershipYears, IsChild, ConditionOperator, DiscountPercentage, IsActive)
    VALUES ('65+ Years Discount (50% Off)', 65, NULL, 0, 'OR', 50.00, 1);
END

IF NOT EXISTS (SELECT 1 FROM DiscountPolicies WHERE PolicyName LIKE '%Child%')
BEGIN
    INSERT INTO DiscountPolicies (PolicyName, MinAge, MinMembershipYears, IsChild, ConditionOperator, DiscountPercentage, IsActive)
    VALUES ('Child Half Charge', NULL, NULL, 1, 'OR', 50.00, 1);
END

IF NOT EXISTS (SELECT 1 FROM DiscountPolicies WHERE PolicyName LIKE '%30 Yrs%' OR PolicyName LIKE '%80+%')
BEGIN
    INSERT INTO DiscountPolicies (PolicyName, MinAge, MinMembershipYears, IsChild, ConditionOperator, DiscountPercentage, IsActive)
    VALUES ('30 Yrs Membership AND 80+ Age Free', 80, 30, 0, 'AND', 100.00, 1);
END
GO

-- 3. Update fn_GetDynamicDiscountPercentage function to apply active policies to Monthly and Continuous subscriptions
IF OBJECT_ID('fn_GetDynamicDiscountPercentage', 'FN') IS NOT NULL
    DROP FUNCTION fn_GetDynamicDiscountPercentage;
GO

CREATE FUNCTION dbo.fn_GetDynamicDiscountPercentage (
    @MemberID INT,
    @DependentMemberNo NVARCHAR(100),
    @SubscriptionID INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @SubType NVARCHAR(50) = '';
    SELECT @SubType = ISNULL(SubscriptionType, '') FROM Subscriptions WHERE SubscriptionID = @SubscriptionID;

    -- Discount policies ONLY apply to Monthly and Continuous subscriptions
    IF @SubType NOT IN ('Monthly', 'Continuous')
        RETURN 0;

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
    WHERE dp.IsActive = 1
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
