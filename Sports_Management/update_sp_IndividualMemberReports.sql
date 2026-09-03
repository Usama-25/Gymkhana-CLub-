USE [SportsModuleDB]
GO

-- 1. Update sp_GetMemberSubscriptions
IF OBJECT_ID('sp_GetMemberSubscriptions', 'P') IS NOT NULL DROP PROCEDURE sp_GetMemberSubscriptions;
GO

CREATE PROCEDURE [dbo].[sp_GetMemberSubscriptions]
    @MemberID INT,
    @MemberNo NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        ms.MemberSubID,
        ms.SubscriptionID,
        s.SportID,
        sp.SportName,
        s.PackageName,
        ISNULL(s.SubscriptionType, 
            CASE 
                WHEN ms.DependentMemberNo IS NOT NULL AND ms.DependentMemberNo <> '' 
                THEN 'Dependent (' + ISNULL(ms.DependentRelation COLLATE DATABASE_DEFAULT, 'Dep') + ')'
                ELSE 'Primary Member'
            END
        ) AS SubscriptionType,
        ISNULL(ms.NetFee, s.Fee) AS Fee,
        ms.StartDate,
        ms.EndDate,
        ms.IsActive,
        ms.DependentMemberNo,
        ms.DependentName,
        ms.DependentRelation
    FROM MemberSubscriptions ms
    INNER JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
    INNER JOIN Sports sp ON s.SportID = sp.SportID
    INNER JOIN [MemberShip].[dbo].[MemberProfile] mp ON ms.MemberID = mp.MemberID
    WHERE ms.MemberID = @MemberID
      AND (
          @MemberNo IS NULL OR @MemberNo = ''
          OR
          -- Primary Member searched: match primary member no & exclude dependents
          (
              @MemberNo COLLATE DATABASE_DEFAULT = mp.MemberNo COLLATE DATABASE_DEFAULT 
              AND (ms.DependentMemberNo IS NULL OR ms.DependentMemberNo = '')
          )
          OR
          -- Dependent Member searched: match dependent member no only
          (
              ms.DependentMemberNo COLLATE DATABASE_DEFAULT = @MemberNo COLLATE DATABASE_DEFAULT
          )
      )
    ORDER BY ms.IsActive DESC, ms.StartDate DESC;
END
GO

-- 2. Update sp_RptIndividualMemberPOS
IF OBJECT_ID('sp_RptIndividualMemberPOS', 'P') IS NOT NULL DROP PROCEDURE sp_RptIndividualMemberPOS;
GO

CREATE PROCEDURE [dbo].[sp_RptIndividualMemberPOS]
    @MemberID INT,
    @MemberNo NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        pos.TransactionID,
        sp.SportName,
        s.PackageName,
        pos.Amount,
        pos.TransactionDate,
        pos.ValidityPeriod,
        pos.Status,
        sp.SportID,
        pos.DependentMemberNo,
        pos.DependentName
    FROM POSTransactions pos
    INNER JOIN Subscriptions s ON pos.SubscriptionID = s.SubscriptionID
    INNER JOIN Sports sp ON s.SportID = sp.SportID
    INNER JOIN [MemberShip].[dbo].[MemberProfile] mp ON pos.MemberID = mp.MemberID
    WHERE pos.MemberID = @MemberID
      AND (
          @MemberNo IS NULL OR @MemberNo = ''
          OR
          -- Primary Member searched: match primary member no & exclude dependents
          (
              @MemberNo COLLATE DATABASE_DEFAULT = mp.MemberNo COLLATE DATABASE_DEFAULT 
              AND (pos.DependentMemberNo IS NULL OR pos.DependentMemberNo = '')
          )
          OR
          -- Dependent Member searched: match dependent member no only
          (
              pos.DependentMemberNo COLLATE DATABASE_DEFAULT = @MemberNo COLLATE DATABASE_DEFAULT
          )
      )
    ORDER BY pos.TransactionDate DESC;
END
GO
