-- 1. Insert 'Sports Cards' into Sports table if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM Sports WHERE SportName = 'Sports Cards')
BEGIN
    INSERT INTO Sports (SportName, Description, Status) 
    VALUES ('Sports Cards', 'Sports Cards Subscriptions', 1);
END

-- 2. Variables for SportIDs
DECLARE @SportID_Cricket INT = (SELECT SportID FROM Sports WHERE SportName = 'Cricket');
DECLARE @SportID_CardsRoom INT = (SELECT SportID FROM Sports WHERE SportName = 'Card');
DECLARE @SportID_Billiards INT = (SELECT SportID FROM Sports WHERE SportName = 'Billiards');
DECLARE @SportID_Squash INT = (SELECT SportID FROM Sports WHERE SportName = 'Squash');
DECLARE @SportID_Swimming INT = (SELECT SportID FROM Sports WHERE SportName = 'Swimming');
DECLARE @SportID_Tennis INT = (SELECT SportID FROM Sports WHERE SportName = 'Tennis');
DECLARE @SportID_Golf INT = (SELECT SportID FROM Sports WHERE SportName = 'Golf');
DECLARE @SportID_Gym INT = (SELECT SportID FROM Sports WHERE SportName = 'Gym');
DECLARE @SportID_SportsCards INT = (SELECT SportID FROM Sports WHERE SportName = 'Sports Cards');
DECLARE @SportID_General INT = (SELECT SportID FROM Sports WHERE SportName = 'Non Playing Fixed Contribution');

-- 3. Insert Packages
-- We use a MERGE or IF NOT EXISTS approach. To keep it simple, just IF NOT EXISTS.
-- (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status)

-- SPORTS SUBS
IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID_Cricket AND PackageName = 'Monthly Subscription')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID_Cricket, 'Monthly Subscription', 'Monthly', 3700, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID_CardsRoom AND PackageName = 'Monthly Subscription')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID_CardsRoom, 'Monthly Subscription', 'Monthly', 3700, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID_Billiards AND PackageName = 'Monthly Subscription')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID_Billiards, 'Monthly Subscription', 'Monthly', 3700, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID_Squash AND PackageName = 'Monthly Subscription')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID_Squash, 'Monthly Subscription', 'Monthly', 3700, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID_Swimming AND PackageName = 'Monthly Subscription')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID_Swimming, 'Monthly Subscription', 'Monthly', 4500, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID_Tennis AND PackageName = 'Monthly Subscription')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID_Tennis, 'Monthly Subscription', 'Monthly', 4200, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID_Golf AND PackageName = 'Monthly Subscription')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID_Golf, 'Monthly Subscription', 'Monthly', 5000, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID_Gym AND PackageName = 'Monthly Subscription')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID_Gym, 'Monthly Subscription', 'Monthly', 4500, 16, 1);


-- SPORTS CARDS SUBS
IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID_SportsCards AND PackageName = 'Family Sports Cards')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID_SportsCards, 'Family Sports Cards', 'Monthly', 9000, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID_SportsCards AND PackageName = 'Couple Sports Cards')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID_SportsCards, 'Couple Sports Cards', 'Monthly', 7000, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID_SportsCards AND PackageName = 'Individual / Child Sports Cards')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID_SportsCards, 'Individual / Child Sports Cards', 'Monthly', 6000, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID_SportsCards AND PackageName = 'Non Earning Sports Cards')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID_SportsCards, 'Non Earning Sports Cards', 'Monthly', 6000, 16, 1);


-- Non Playing Fixed Contribution
IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID_General AND PackageName = 'General Sports Contribution')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID_General, 'General Sports Contribution', 'Monthly', 500, 0, 1);
