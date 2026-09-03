USE [SportsModuleDB];
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
        s.ItemCode,
        s.GSTPercentage
    FROM Subscriptions s
    INNER JOIN Sports sp ON s.SportID = sp.SportID
    WHERE s.SubscriptionType = 'Daily' AND s.Status = 1
    ORDER BY sp.SportName, s.PackageName;
END
GO
