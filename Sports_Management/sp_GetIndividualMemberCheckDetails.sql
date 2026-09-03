USE [SportsModuleDB]
GO

IF OBJECT_ID('dbo.sp_GetIndividualMemberCheckDetails', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetIndividualMemberCheckDetails
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_GetIndividualMemberCheckDetails]
    @SearchMemberNo NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MemberID INT = NULL;
    DECLARE @FullName NVARCHAR(150) = NULL;
    DECLARE @Relation NVARCHAR(50) = NULL;
    DECLARE @Status NVARCHAR(50) = NULL;
    DECLARE @ContactNo NVARCHAR(50) = NULL;
    DECLARE @ActualMemberNo NVARCHAR(50) = NULL;

    -- Trim spaces
    SET @SearchMemberNo = LTRIM(RTRIM(@SearchMemberNo));

    -- 1. Check if it's a Main Member
    SELECT 
        @MemberID = MemberID,
        @FullName = MemberName,
        @Relation = 'Self',
        @Status = ISNULL(Status, 'Inactive'),
        @ContactNo = Mobile,
        @ActualMemberNo = MemberNo
    FROM MemberShip.dbo.MemberProfile
    WHERE MemberNo = @SearchMemberNo;

    -- 2. If not found, check if it's a Spouse
    IF @MemberID IS NULL
    BEGIN
        SELECT 
            @MemberID = ms.MemberID,
            @FullName = ms.SpouseName,
            @Relation = 'Spouse',
            @Status = CASE 
                WHEN mp.Status IS NULL THEN 'Inactive'
                WHEN mp.Status <> 'Active' THEN mp.Status
                WHEN ms.RecordStatus = 'Active' THEN 'Active'
                WHEN ms.RecordStatus = 'Deactive' THEN 'Inactive'
                ELSE ms.RecordStatus 
            END,
            @ContactNo = ISNULL(ms.SpousePhone, mp.Mobile),
            @ActualMemberNo = ms.MembershipNo
        FROM MemberShip.dbo.MemberSpouses ms
        INNER JOIN MemberShip.dbo.MemberProfile mp ON ms.MemberID = mp.MemberID
        WHERE ms.MembershipNo = @SearchMemberNo;
    END

    -- 3. If not found, check if it's a Child/Dependent
    IF @MemberID IS NULL
    BEGIN
        SELECT 
            @MemberID = mc.MemberID,
            @FullName = mc.ChildName,
            @Relation = ISNULL(mc.Relationship, 'Dependent'),
            @Status = CASE 
                WHEN mp.Status IS NULL THEN 'Inactive'
                WHEN mp.Status <> 'Active' THEN mp.Status
                WHEN mc.RecordStatus = 'Active' THEN 'Active'
                WHEN mc.RecordStatus = 'Deactive' THEN 'Inactive'
                ELSE mc.RecordStatus 
            END,
            @ContactNo = ISNULL(mc.ChildPhone, mp.Mobile),
            @ActualMemberNo = mc.MembershipNo
        FROM MemberShip.dbo.MemberChildren mc
        INNER JOIN MemberShip.dbo.MemberProfile mp ON mc.MemberID = mp.MemberID
        WHERE mc.MembershipNo = @SearchMemberNo;
    END

    -- Return Member Details Result Set (Result Set 1)
    SELECT 
        ISNULL(@MemberID, 0) AS MemberID,
        ISNULL(@ActualMemberNo, @SearchMemberNo) AS MemberNo,
        ISNULL(@FullName, 'N/A') AS FullName,
        ISNULL(@Relation, 'N/A') AS Relation,
        ISNULL(@Status, 'N/A') AS Status,
        ISNULL(@ContactNo, 'N/A') AS ContactNo;

    -- Return Active Subscriptions for the searched member number (Result Set 2)
    -- If main member, look for DependentMemberNo IS NULL or empty.
    -- If dependent, look for DependentMemberNo = @SearchMemberNo.
    IF @MemberID IS NOT NULL
    BEGIN
        IF @Relation = 'Self'
        BEGIN
            SELECT 
                sp.SportName,
                s.PackageName,
                s.SubscriptionType,
                s.Fee AS BaseFee,
                ISNULL(s.GSTPercentage, 0) AS GSTPercentage,
                CAST(s.Fee * ISNULL(s.GSTPercentage, 0) / 100.0 AS DECIMAL(18,2)) AS GSTAmount,
                CAST(s.Fee + (s.Fee * ISNULL(s.GSTPercentage, 0) / 100.0) AS DECIMAL(18,2)) AS TotalAmount,
                ms.StartDate,
                ms.IsActive,
                s.SubscriptionID,
                s.SportID
            FROM MemberSubscriptions ms
            INNER JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
            INNER JOIN Sports sp ON s.SportID = sp.SportID
            WHERE ms.MemberID = @MemberID
              AND (ms.DependentMemberNo IS NULL OR ms.DependentMemberNo = '')
              AND ms.IsActive = 1;
        END
        ELSE
        BEGIN
            SELECT 
                sp.SportName,
                s.PackageName,
                s.SubscriptionType,
                s.Fee AS BaseFee,
                ISNULL(s.GSTPercentage, 0) AS GSTPercentage,
                CAST(s.Fee * ISNULL(s.GSTPercentage, 0) / 100.0 AS DECIMAL(18,2)) AS GSTAmount,
                CAST(s.Fee + (s.Fee * ISNULL(s.GSTPercentage, 0) / 100.0) AS DECIMAL(18,2)) AS TotalAmount,
                ms.StartDate,
                ms.IsActive,
                s.SubscriptionID,
                s.SportID
            FROM MemberSubscriptions ms
            INNER JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
            INNER JOIN Sports sp ON s.SportID = sp.SportID
            WHERE ms.MemberID = @MemberID
              AND ms.DependentMemberNo = @SearchMemberNo
              AND ms.IsActive = 1;
        END
    END
    ELSE
    BEGIN
        -- Return empty schema for Subscriptions
        SELECT TOP 0 
            CAST('' AS NVARCHAR(100)) AS SportName,
            CAST('' AS NVARCHAR(100)) AS PackageName,
            CAST('' AS NVARCHAR(50)) AS SubscriptionType,
            CAST(0 AS DECIMAL(18,2)) AS BaseFee,
            CAST(0 AS DECIMAL(18,2)) AS GSTPercentage,
            CAST(0 AS DECIMAL(18,2)) AS GSTAmount,
            CAST(0 AS DECIMAL(18,2)) AS TotalAmount,
            CAST(GETDATE() AS DATE) AS StartDate,
            CAST(0 AS BIT) AS IsActive,
            CAST(0 AS INT) AS SubscriptionID,
            CAST(0 AS INT) AS SportID;
    END

    -- Return Dependents list if the searched member is Main Member (Result Set 3)
    IF @Relation = 'Self' AND @MemberID IS NOT NULL
    BEGIN
        SELECT 
            ms.MembershipNo AS MemberNo,
            ms.SpouseName AS FullName,
            'Spouse' AS Relation,
            CASE 
                WHEN mp.Status IS NULL THEN 'Inactive'
                WHEN mp.Status <> 'Active' THEN mp.Status
                WHEN ms.RecordStatus = 'Active' THEN 'Active'
                WHEN ms.RecordStatus = 'Deactive' THEN 'Inactive'
                ELSE ms.RecordStatus 
            END AS Status
        FROM MemberShip.dbo.MemberSpouses ms
        INNER JOIN MemberShip.dbo.MemberProfile mp ON ms.MemberID = mp.MemberID
        WHERE ms.MemberID = @MemberID

        UNION ALL

        SELECT 
            mc.MembershipNo AS MemberNo,
            mc.ChildName AS FullName,
            ISNULL(mc.Relationship, 'Dependent') AS Relation,
            CASE 
                WHEN mp.Status IS NULL THEN 'Inactive'
                WHEN mp.Status <> 'Active' THEN mp.Status
                WHEN mc.RecordStatus = 'Active' THEN 'Active'
                WHEN mc.RecordStatus = 'Deactive' THEN 'Inactive'
                ELSE mc.RecordStatus 
            END AS Status
        FROM MemberShip.dbo.MemberChildren mc
        INNER JOIN MemberShip.dbo.MemberProfile mp ON mc.MemberID = mp.MemberID
        WHERE mc.MemberID = @MemberID;
    END
    ELSE
    BEGIN
        -- Return empty schema for Dependents
        SELECT TOP 0 
            CAST('' AS NVARCHAR(50)) AS MemberNo,
            CAST('' AS NVARCHAR(150)) AS FullName,
            CAST('' AS NVARCHAR(50)) AS Relation,
            CAST('' AS NVARCHAR(50)) AS Status;
    END

    -- Return All Sports Cards for the family/member (Result Set 4)
    -- This helps us alert if anyone in the family has an active sports card
    -- We filter by SubscriptionID IN (17,18,19,20) or SportID = 10
    IF @MemberID IS NOT NULL
    BEGIN
        SELECT 
            ms.MemberSubID,
            CASE WHEN ISNULL(ms.DependentMemberNo, '') = '' THEN 'Main Member' ELSE ISNULL(ms.DependentName, ms.DependentMemberNo) END AS PersonName,
            CASE WHEN ISNULL(ms.DependentMemberNo, '') = '' THEN 'Self' ELSE ISNULL(ms.DependentRelation, 'Dependent') END AS Relation,
            ms.DependentMemberNo AS MemberNo,
            s.PackageName,
            s.SubscriptionType,
            ms.StartDate,
            s.SportID
        FROM MemberSubscriptions ms
        INNER JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
        WHERE ms.MemberID = @MemberID
          AND ms.IsActive = 1
          AND (s.SubscriptionID IN (17,18,19,20) OR s.SportID = 10);
    END
    ELSE
    BEGIN
        -- Return empty schema for Sports Cards
        SELECT TOP 0 
            CAST(0 AS INT) AS MemberSubID,
            CAST('' AS NVARCHAR(150)) AS PersonName,
            CAST('' AS NVARCHAR(50)) AS Relation,
            CAST('' AS NVARCHAR(50)) AS MemberNo,
            CAST('' AS NVARCHAR(100)) AS PackageName,
            CAST('' AS NVARCHAR(50)) AS SubscriptionType,
            CAST(GETDATE() AS DATE) AS StartDate,
            CAST(0 AS INT) AS SportID;
    END
END
GO
