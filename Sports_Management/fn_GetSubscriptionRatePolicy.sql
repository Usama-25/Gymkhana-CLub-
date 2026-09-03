USE [SportsModuleDB]
GO

IF OBJECT_ID('fn_GetSubscriptionRatePolicy', 'FN') IS NOT NULL
    DROP FUNCTION fn_GetSubscriptionRatePolicy;
GO

CREATE FUNCTION fn_GetSubscriptionRatePolicy (
    @MemberID INT,
    @DependentMemberNo NVARCHAR(100)
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @DOB DATETIME = NULL;
    DECLARE @FirstSubDate DATETIME = NULL;
    DECLARE @Age INT = 0;
    DECLARE @Tenure INT = 0;

    -- Normalize dependent no
    IF LTRIM(RTRIM(ISNULL(@DependentMemberNo, ''))) = ''
        SET @DependentMemberNo = NULL;

    -- 1. Determine DOB
    IF @DependentMemberNo IS NULL
    BEGIN
        SELECT TOP 1 @DOB = DOB FROM MemberShip.dbo.MemberProfile WHERE MemberID = @MemberID OR MemberID_New = @MemberID;
    END
    ELSE
    BEGIN
        -- Try Children first
        SELECT TOP 1 @DOB = DOB FROM MemberShip.dbo.MemberChildren WHERE MembershipNo = @DependentMemberNo;
        
        -- If not found (e.g. it's a Spouse and MemberSpouses has no DOB column), fallback to Main Member's DOB
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

    -- If no history, check main member profile created date (fallback for main member)
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

    -- 5. Determine Policy
    IF @Age >= 80 OR @Tenure >= 30 
        RETURN 'Senior';
    
    IF @Age >= 65 
        RETURN 'Half';

    RETURN 'Base';
END
GO
