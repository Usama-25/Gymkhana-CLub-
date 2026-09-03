-- 1. Ensure 'Martial Arts' exists
IF NOT EXISTS (SELECT 1 FROM Sports WHERE SportName = 'Martial Arts')
BEGIN
    INSERT INTO Sports (SportName, Description, Status) VALUES ('Martial Arts', 'Martial Arts', 1);
END

DECLARE @SportID_Cricket INT = (SELECT SportID FROM Sports WHERE SportName = 'Cricket');
DECLARE @SportID_Tennis INT = (SELECT SportID FROM Sports WHERE SportName = 'Tennis');
DECLARE @SportID_Golf INT = (SELECT SportID FROM Sports WHERE SportName = 'Golf');
DECLARE @SportID_Gym INT = (SELECT SportID FROM Sports WHERE SportName = 'Gym');
DECLARE @SportID_Swimming INT = (SELECT SportID FROM Sports WHERE SportName = 'Swimming');
DECLARE @SportID_Squash INT = (SELECT SportID FROM Sports WHERE SportName = 'Squash');
DECLARE @SportID_Billiards INT = (SELECT SportID FROM Sports WHERE SportName = 'Billiards');
DECLARE @SportID_Card INT = (SELECT SportID FROM Sports WHERE SportName = 'Card');
DECLARE @SportID_MartialArts INT = (SELECT SportID FROM Sports WHERE SportName = 'Martial Arts');

-- Helper variable for inserts
DECLARE @SportID INT;

-- ==============================================
-- TENNIS (SportID = 2)
-- ==============================================
SET @SportID = @SportID_Tennis;

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'TENNIS SUB MONTHLY')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'TENNIS SUB MONTHLY', 'Monthly', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'TENNIS SUB DAILY')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'TENNIS SUB DAILY', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'TENNIS')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'TENNIS', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'TENNIS COACHING')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'TENNIS COACHING', 'Daily', 1500, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'TENNIS GUEST FEE')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'TENNIS GUEST FEE', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'TENNIS BALL')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'TENNIS BALL', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'Tennis Misc Charges')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'Tennis Misc Charges', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'TENNIS LIGHT CHARGES')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'TENNIS LIGHT CHARGES', 'Daily', 1000, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'TENNIS COACHING CAMP')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'TENNIS COACHING CAMP', 'Daily', 1500, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'MY GUEST CHARGES')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'MY GUEST CHARGES', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'TOURNAMENT FEE')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'TOURNAMENT FEE', 'Daily', 0, 16, 1);

-- ==============================================
-- GYMNASIUM (SportID = 4)
-- ==============================================
SET @SportID = @SportID_Gym;

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'GYM')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'GYM', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'GYM GUEST')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'GYM GUEST', 'Daily', 1500, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'AFFILIATED CLUB MEMBER')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'AFFILIATED CLUB MEMBER', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'YOGA')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'YOGA', 'Daily', 1500, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'Squad / Yoga')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'Squad / Yoga', 'Monthly', 4000, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'AEROBICS')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'AEROBICS', 'Daily', 1500, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'STEAM BATH')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'STEAM BATH', 'Daily', 1500, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'SAUNA BATH')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'SAUNA BATH', 'Daily', 1500, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'DANCE AEROBICS')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'DANCE AEROBICS', 'Daily', 1500, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'MEDITATION YOGA')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'MEDITATION YOGA', 'Monthly', 3000, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'BOLLYWOOD DANCE')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'BOLLYWOOD DANCE', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'KARATE CLASSES')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'KARATE CLASSES', 'Daily', 1500, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'TABLE TENNIS')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'TABLE TENNIS', 'Daily', 1500, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'Evening Slot')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'Evening Slot', 'Monthly', 2000, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'LADIES YOGA')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'LADIES YOGA', 'Monthly', 4000, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'PILATES / CALLANETICS CLASS')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'PILATES / CALLANETICS CLASS', 'Monthly', 4000, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'Boot Camp')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'Boot Camp', 'Monthly', 6000, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'Zumba Class')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'Zumba Class', 'Monthly', 6000, 16, 1);

-- ==============================================
-- MARTIAL ARTS
-- ==============================================
SET @SportID = @SportID_MartialArts;
IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'KARATE CLASS - MASTER SALMAN')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'KARATE CLASS - MASTER SALMAN', 'Daily', 0, 16, 1);


-- ==============================================
-- GOLF (SportID = 3)
-- ==============================================
SET @SportID = @SportID_Golf;

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'CAPTAIN CUP ENTRY')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'CAPTAIN CUP ENTRY', 'Daily', 100, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'GOLF CONTINUOUS SUB')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'GOLF CONTINUOUS SUB', 'Continuous', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'Golf Misc Chrgs')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'Golf Misc Chrgs', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'BAYER''S SHOP SALE')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'BAYER''S SHOP SALE', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'GOLF - LOCKER')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'GOLF - LOCKER', 'Monthly', 300, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'GREEN FEE')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'GREEN FEE', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'GOLF COACHING')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'GOLF COACHING', 'Daily', 300, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'GOLF COMPETITION FEE')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'GOLF COMPETITION FEE', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'GOLF - CADDY')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'GOLF - CADDY', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'GOLF CHILD')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'GOLF CHILD', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'GOLF - COURSE LOG - GYM')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'GOLF - COURSE LOG - GYM', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'SPORTS SHOP')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'SPORTS SHOP', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'DRIVING PRACTICE - REGULAR')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'DRIVING PRACTICE - REGULAR', 'Daily', 25, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'DRIVING PRACTICE (Tee) Member')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'DRIVING PRACTICE (Tee) Member', 'Daily', 50, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'DRIVING PRACTICE (Tee) Guest')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'DRIVING PRACTICE (Tee) Guest', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'DRIVING PRACTICE (Tee) AMU')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'DRIVING PRACTICE (Tee) AMU', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'DRIVING PRACTICE (Tee) BMIJ')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'DRIVING PRACTICE (Tee) BMIJ', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'DRIVING PRACTICE (Tee) A.M.B')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'DRIVING PRACTICE (Tee) A.M.B', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'BALL (25)')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'BALL (25)', 'Daily', 25, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'GOLF LOCKERS')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'GOLF LOCKERS', 'Monthly', 100, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'DRIVING MATT / GUN SPOOL (25)')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'DRIVING MATT / GUN SPOOL (25)', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'Golf 18 Hole Booking Charges')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'Golf 18 Hole Booking Charges', 'Daily', 0, 16, 1);


-- ==============================================
-- SQUASH (SportID = 6)
-- ==============================================
SET @SportID = @SportID_Squash;

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'SQUASH CONTINUOUS SUB')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'SQUASH CONTINUOUS SUB', 'Continuous', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'SQUASH COACHING')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'SQUASH COACHING', 'Daily', 150, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'SQUASH MEMBER DAILY')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'SQUASH MEMBER DAILY', 'Daily', 50, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'SQUASH GUEST')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'SQUASH GUEST', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'SQUASH CAMP')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'SQUASH CAMP', 'Monthly', 150, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'Squash Misc chrgs')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'Squash Misc chrgs', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'SQUASH GRIP')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'SQUASH GRIP', 'Daily', 0, 16, 1);

-- ==============================================
-- CARD ROOM (SportID = 9)
-- ==============================================
SET @SportID = @SportID_Card;

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'CARDS CONTINUOUS SUB')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'CARDS CONTINUOUS SUB', 'Continuous', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'CARDS')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'CARDS', 'Daily', 10, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'BILLIARDS FEE')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'BILLIARDS FEE', 'Daily', 50, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'OLD CARDS')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'OLD CARDS', 'Daily', 100, 16, 1);

-- ==============================================
-- BILLIARDS (SportID = 7)
-- ==============================================
SET @SportID = @SportID_Billiards;

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'BILLIARD MONTHLY SUB')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'BILLIARD MONTHLY SUB', 'Monthly', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'BILLIARD GUEST')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'BILLIARD GUEST', 'Daily', 10, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'BILLIARD FRAME MEMBER')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'BILLIARD FRAME MEMBER', 'Daily', 20, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'BILLIARD FRAME GUEST')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'BILLIARD FRAME GUEST', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'BILLIARD COACHING')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'BILLIARD COACHING', 'Daily', 50, 16, 1);


-- ==============================================
-- SWIMMING POOL (SportID = 5)
-- ==============================================
SET @SportID = @SportID_Swimming;

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'SWIMMING MONTHLY SUB')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'SWIMMING MONTHLY SUB', 'Monthly', 4500, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'SWIMMING GUEST')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'SWIMMING GUEST', 'Daily', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'STEAM BATH MONTHLY')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'STEAM BATH MONTHLY', 'Monthly', 2000, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'STEAM BATH DAILY')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'STEAM BATH DAILY', 'Daily', 100, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'GUEST SWIMMING')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'GUEST SWIMMING', 'Daily', 1200, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'SAUNA MONTHLY')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'SAUNA MONTHLY', 'Monthly', 2000, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'SAUNA DAILY')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'SAUNA DAILY', 'Daily', 200, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'ICE')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'ICE', 'Daily', 100, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'Affiliated Club')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'Affiliated Club', 'Monthly', 4500, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'LKR / PPR MONTHLY')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'LKR / PPR MONTHLY', 'Monthly', 2000, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'Lkr/Towel / Steam Sauna GuesT')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'Lkr/Towel / Steam Sauna GuesT', 'Daily', 200, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'LKR / PPR DAILY')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'LKR / PPR DAILY', 'Daily', 100, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'SWIMMING COACHING')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'SWIMMING COACHING', 'Monthly', 5000, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'Advance Coaching')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'Advance Coaching', 'Monthly', 6000, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'PENSIONER MEMBER')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'PENSIONER MEMBER', 'Monthly', 2250, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'MING / SWI P PENSIONER AFFILIATED GUEST')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'MING / SWI P PENSIONER AFFILIATED GUEST', 'Daily', 100, 16, 1);

-- ==============================================
-- CRICKET (SportID = 1)
-- ==============================================
SET @SportID = @SportID_Cricket;

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'CRICKET CONTINUOUS SUB')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'CRICKET CONTINUOUS SUB', 'Continuous', 0, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'CRICKET COACHING CAMP')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'CRICKET COACHING CAMP', 'Monthly', 100, 16, 1);

IF NOT EXISTS (SELECT 1 FROM Subscriptions WHERE SportID = @SportID AND PackageName = 'Cricket Guest Fee')
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, GSTPercentage, Status) VALUES (@SportID, 'Cricket Guest Fee', 'Daily', 0, 16, 1);

