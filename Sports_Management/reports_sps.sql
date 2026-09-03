USE [SportsModuleDB]
GO

-- 1. Member Subscription Wise Report
IF OBJECT_ID('sp_RptMemberSubscriptions', 'P') IS NOT NULL DROP PROCEDURE sp_RptMemberSubscriptions;
GO
CREATE PROCEDURE [sp_RptMemberSubscriptions]
    @SportID INT = NULL,
    @Status INT = -1, -- -1: All, 1: Active, 0: Inactive
    @MemberNo NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        ISNULL(ms.DependentMemberNo COLLATE DATABASE_DEFAULT, mp.MemberNo COLLATE DATABASE_DEFAULT) AS MemberNo,
        CASE 
            WHEN ms.DependentName IS NOT NULL AND ms.DependentName <> '' 
            THEN mp.MemberName COLLATE DATABASE_DEFAULT + ' (' + ms.DependentName COLLATE DATABASE_DEFAULT + ' - ' + ISNULL(ms.DependentRelation COLLATE DATABASE_DEFAULT, 'Dep') + ')'
            ELSE mp.MemberName COLLATE DATABASE_DEFAULT 
        END AS MemberName,
        sp.SportName,
        s.PackageName,
        ms.StartDate,
        ms.EndDate,
        ms.IsActive,
        ISNULL(ms.NetFee, s.Fee) AS Fee,
        sp.SportID
    FROM MemberSubscriptions ms
    INNER JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
    INNER JOIN Sports sp ON s.SportID = sp.SportID
    INNER JOIN [MemberShip].[dbo].[MemberProfile] mp ON ms.MemberID = mp.MemberID
    WHERE (@SportID IS NULL OR @SportID = 0 OR s.SportID = @SportID)
      AND (@Status = -1 OR ms.IsActive = @Status)
      AND (@MemberNo IS NULL OR @MemberNo = '' 
           OR mp.MemberNo COLLATE DATABASE_DEFAULT LIKE '%' + @MemberNo + '%' 
           OR ms.DependentMemberNo COLLATE DATABASE_DEFAULT LIKE '%' + @MemberNo + '%')
    ORDER BY mp.MemberNo COLLATE DATABASE_DEFAULT, sp.SportName, ms.StartDate DESC;
END
GO

-- 2. Individual Member POS Report (for Individual Report Page)
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

-- 3. Access Log Summary Report
IF OBJECT_ID('sp_RptAccessLogSummary', 'P') IS NOT NULL DROP PROCEDURE sp_RptAccessLogSummary;
GO
CREATE PROCEDURE [sp_RptAccessLogSummary]
    @FromDate DATE = NULL,
    @ToDate DATE = NULL,
    @SportID INT = NULL
AS
BEGIN
    SELECT 
        al.MemberNo,
        MAX(mp.MemberName) AS MemberName,
        sp.SportName,
        COUNT(al.LogID) AS TotalAccesses,
        SUM(CASE WHEN al.AccessResult = 'Granted' THEN 1 ELSE 0 END) AS GrantedAccesses,
        SUM(CASE WHEN al.AccessResult = 'Denied' THEN 1 ELSE 0 END) AS DeniedAccesses,
        sp.SportID
    FROM AccessLogs al
    INNER JOIN Sports sp ON al.SportID = sp.SportID
    LEFT JOIN [MemberShip].[dbo].[MemberProfile] mp ON al.MemberID = mp.MemberID
    WHERE (@FromDate IS NULL OR CAST(al.AccessTime AS DATE) >= @FromDate)
      AND (@ToDate IS NULL OR CAST(al.AccessTime AS DATE) <= @ToDate)
      AND (@SportID IS NULL OR @SportID = 0 OR al.SportID = @SportID)
    GROUP BY al.MemberNo, sp.SportName, sp.SportID
    ORDER BY TotalAccesses DESC, al.MemberNo;
END
GO

-- 4. Access Log Details Report
IF OBJECT_ID('sp_RptAccessLogDetails', 'P') IS NOT NULL DROP PROCEDURE sp_RptAccessLogDetails;
GO
CREATE PROCEDURE [sp_RptAccessLogDetails]
    @MemberNo NVARCHAR(50) = NULL,
    @FromDate DATE = NULL,
    @ToDate DATE = NULL,
    @SportID INT = NULL
AS
BEGIN
    SELECT 
        al.LogID,
        al.MemberNo,
        mp.MemberName,
        sp.SportName,
        al.AccessTime,
        al.AccessResult,
        al.DenialReason,
        sp.SportID
    FROM AccessLogs al
    INNER JOIN Sports sp ON al.SportID = sp.SportID
    LEFT JOIN [MemberShip].[dbo].[MemberProfile] mp ON al.MemberID = mp.MemberID
    WHERE (@FromDate IS NULL OR CAST(al.AccessTime AS DATE) >= @FromDate)
      AND (@ToDate IS NULL OR CAST(al.AccessTime AS DATE) <= @ToDate)
      AND (@SportID IS NULL OR @SportID = 0 OR al.SportID = @SportID)
      AND (@MemberNo IS NULL OR @MemberNo = '' OR al.MemberNo = @MemberNo)
    ORDER BY al.AccessTime DESC;
END
GO
