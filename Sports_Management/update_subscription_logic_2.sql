USE [SportsModuleDB]
GO

IF OBJECT_ID('fn_GetSubscriptionRatePolicy', 'FN') IS NOT NULL
    DROP FUNCTION fn_GetSubscriptionRatePolicy;
GO

CREATE FUNCTION fn_GetSubscriptionRatePolicy (
    @MemberID INT,
    @DependentMemberNo NVARCHAR(100),
    @SubscriptionID INT = NULL
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @DOB DATETIME = NULL;
    DECLARE @FirstSubDate DATETIME = NULL;
    DECLARE @Age INT = 0;
    DECLARE @Tenure INT = 0;
    DECLARE @Rel NVARCHAR(50) = 'Self';

    IF LTRIM(RTRIM(ISNULL(@DependentMemberNo, ''))) = ''
        SET @DependentMemberNo = NULL;

    -- Determine Relationship (rough logic for child check)
    IF @DependentMemberNo IS NOT NULL
    BEGIN
        IF @DependentMemberNo LIKE '%-S%' OR @DependentMemberNo LIKE '%-D%' OR @DependentMemberNo LIKE '%-s%' OR @DependentMemberNo LIKE '%-d%'
            SET @Rel = 'Child';
    END

    -- 1. Determine DOB
    IF @DependentMemberNo IS NULL
    BEGIN
        SELECT TOP 1 @DOB = DOB FROM MemberShip.dbo.MemberProfile WHERE MemberID = @MemberID OR MemberID_New = @MemberID;
    END
    ELSE
    BEGIN
        SELECT TOP 1 @DOB = DOB FROM MemberShip.dbo.MemberChildren WHERE MembershipNo = @DependentMemberNo;
        IF @DOB IS NULL
        BEGIN
            SELECT TOP 1 @DOB = DOB FROM MemberShip.dbo.MemberProfile WHERE MemberID = @MemberID OR MemberID_New = @MemberID;
        END
    END

    -- 2. Calculate Age
    IF @DOB IS NOT NULL
    BEGIN
        SET @Age = DATEDIFF(YEAR, @DOB, GETDATE());
        IF (DATEADD(YEAR, @Age, @DOB) > GETDATE()) SET @Age = @Age - 1;
    END

    -- 3. Determine First Subscription Date
    SELECT @FirstSubDate = MIN(StartDate) 
    FROM MemberSubscriptions 
    WHERE MemberID = @MemberID 
    AND ISNULL(DependentMemberNo, '') = ISNULL(@DependentMemberNo, '');

    IF @FirstSubDate IS NULL AND @DependentMemberNo IS NULL
    BEGIN
        SELECT TOP 1 @FirstSubDate = CreatedDate FROM MemberShip.dbo.MemberProfile WHERE MemberID = @MemberID OR MemberID_New = @MemberID;
    END

    -- 4. Calculate Tenure
    IF @FirstSubDate IS NOT NULL
    BEGIN
        SET @Tenure = DATEDIFF(YEAR, @FirstSubDate, GETDATE());
        IF (DATEADD(YEAR, @Tenure, @FirstSubDate) > GETDATE()) SET @Tenure = @Tenure - 1;
    END

    -- 5. Fetch Package Flags
    DECLARE @Allow65 BIT = 0, @Allow30 BIT = 0, @Allow80 BIT = 0, @AllowChild BIT = 0;
    IF @SubscriptionID IS NOT NULL AND @SubscriptionID > 0
    BEGIN
        SELECT @Allow65 = Allow65PlusDiscount, @Allow30 = Allow30YearsDiscount,
               @Allow80 = Allow80PlusFree, @AllowChild = AllowChildHalfCharge
        FROM Subscriptions WHERE SubscriptionID = @SubscriptionID;
    END

    -- 6. Apply Rules
    IF @SubscriptionID IS NOT NULL AND @SubscriptionID > 0
    BEGIN
        IF @Allow80 = 1 AND @Age >= 80 
            RETURN 'Senior';
        IF @Allow30 = 1 AND @Tenure >= 30
            RETURN 'Senior';
        IF @Allow65 = 1 AND @Age >= 65 
            RETURN 'Half';
        IF @AllowChild = 1 AND (@Age <= 18 OR @Rel = 'Child')
            RETURN 'Half';
        
        RETURN 'Base';
    END
    ELSE
    BEGIN
        -- Default backward compatible behavior if no package provided
        IF @Age >= 80 OR @Tenure >= 30 
            RETURN 'Senior';
        IF @Age >= 65 
            RETURN 'Half';
        
        RETURN 'Base';
    END

    RETURN 'Base';
END
GO
