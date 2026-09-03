USE [SportsModuleDB]
GO

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
