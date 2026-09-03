USE [master]
GO

CREATE DATABASE [SportsModuleDB]
GO

USE [SportsModuleDB]
GO

-- ============================================
-- 1. Tables
-- ============================================

-- NOTE: Members table is omitted as we will be querying [MemberShip].[dbo].[MemberProfile] directly.

CREATE TABLE [Sports] (
    [SportID] INT IDENTITY(1,1) PRIMARY KEY,
    [SportName] NVARCHAR(100) NOT NULL, -- Cricket, Tennis, Golf, Gym, etc.
    [Description] NVARCHAR(255),
    [Status] BIT DEFAULT 1 -- 1 for Active, 0 for Inactive
);

CREATE TABLE [Subscriptions] (
    [SubscriptionID] INT IDENTITY(1,1) PRIMARY KEY,
    [SportID] INT FOREIGN KEY REFERENCES [Sports](SportID),
    [PackageName] NVARCHAR(100) NOT NULL,
    [SubscriptionType] NVARCHAR(50) NOT NULL, -- Monthly, Daily, Continuous
    [Fee] DECIMAL(18,2) NOT NULL,
    [Status] BIT DEFAULT 1
);

CREATE TABLE [MemberSubscriptions] (
    [MemberSubID] INT IDENTITY(1,1) PRIMARY KEY,
    [MemberID] INT NOT NULL, -- References [MemberShip].[dbo].[MemberProfile](MemberID)
    [SubscriptionID] INT FOREIGN KEY REFERENCES [Subscriptions](SubscriptionID),
    [StartDate] DATE NOT NULL,
    [EndDate] DATE NULL, -- Null for continuous
    [IsActive] BIT DEFAULT 1,
    [AssignedOn] DATETIME DEFAULT GETDATE()
);

-- ============================================
-- 2. Insert Sample Data
-- ============================================

INSERT INTO [Sports] (SportName, Description) VALUES
('Cricket', 'Cricket Ground Access'),
('Tennis', 'Tennis Courts Access'),
('Golf', 'Golf Course Access'),
('Gym', 'Gymnasium Access'),
('Swimming', 'Swimming Pool Access'),
('Squash', 'Squash Courts Access'),
('Billiards', 'Billiards Room Access');

GO

-- ============================================
-- 3. Stored Procedures for Sports
-- ============================================

CREATE PROCEDURE [sp_GetSports]
AS
BEGIN
    SELECT SportID, SportName, Description, Status
    FROM Sports
    ORDER BY SportName;
END
GO

CREATE PROCEDURE [sp_InsertSport]
    @SportName NVARCHAR(100),
    @Description NVARCHAR(255),
    @Status BIT
AS
BEGIN
    INSERT INTO Sports (SportName, Description, Status)
    VALUES (@SportName, @Description, @Status);
END
GO

CREATE PROCEDURE [sp_UpdateSport]
    @SportID INT,
    @SportName NVARCHAR(100),
    @Description NVARCHAR(255),
    @Status BIT
AS
BEGIN
    UPDATE Sports
    SET SportName = @SportName,
        Description = @Description,
        Status = @Status
    WHERE SportID = @SportID;
END
GO

-- ============================================
-- 4. Stored Procedures for Subscriptions
-- ============================================

CREATE PROCEDURE [sp_GetSubscriptions]
AS
BEGIN
    SELECT 
        s.SubscriptionID, 
        s.SportID, 
        sp.SportName, 
        s.PackageName, 
        s.SubscriptionType, 
        s.Fee, 
        s.Status
    FROM Subscriptions s
    INNER JOIN Sports sp ON s.SportID = sp.SportID
    ORDER BY sp.SportName, s.PackageName;
END
GO

CREATE PROCEDURE [sp_InsertSubscription]
    @SportID INT,
    @PackageName NVARCHAR(100),
    @SubscriptionType NVARCHAR(50),
    @Fee DECIMAL(18,2),
    @Status BIT
AS
BEGIN
    INSERT INTO Subscriptions (SportID, PackageName, SubscriptionType, Fee, Status)
    VALUES (@SportID, @PackageName, @SubscriptionType, @Fee, @Status);
END
GO

CREATE PROCEDURE [sp_UpdateSubscription]
    @SubscriptionID INT,
    @SportID INT,
    @PackageName NVARCHAR(100),
    @SubscriptionType NVARCHAR(50),
    @Fee DECIMAL(18,2),
    @Status BIT
AS
BEGIN
    UPDATE Subscriptions
    SET SportID = @SportID,
        PackageName = @PackageName,
        SubscriptionType = @SubscriptionType,
        Fee = @Fee,
        Status = @Status
    WHERE SubscriptionID = @SubscriptionID;
END
GO

-- ============================================
-- 5. Stored Procedures for Member Subscriptions
-- ============================================

CREATE PROCEDURE [sp_SearchMembers]
    @SearchTerm NVARCHAR(100)
AS
BEGIN
    -- Querying directly from the MemberShip database
    SELECT 
        MemberID, 
        MemberNo, 
        MemberName AS FullName, 
        COALESCE(Mobile, ResidentialMobile, CompanyMobile, 'N/A') AS ContactNo, 
        Status
    FROM [MemberShip].[dbo].[MemberProfile]
    WHERE MemberNo LIKE '%' + @SearchTerm + '%' 
       OR MemberName LIKE '%' + @SearchTerm + '%';
END
GO

CREATE PROCEDURE [sp_GetMemberSubscriptions]
    @MemberID INT
AS
BEGIN
    SELECT 
        ms.MemberSubID,
        sp.SportName,
        s.PackageName,
        s.SubscriptionType,
        ms.StartDate,
        ms.EndDate,
        ms.IsActive,
        s.Fee
    FROM MemberSubscriptions ms
    INNER JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
    INNER JOIN Sports sp ON s.SportID = sp.SportID
    WHERE ms.MemberID = @MemberID
    ORDER BY ms.StartDate DESC;
END
GO

CREATE PROCEDURE [sp_AssignSubscription]
    @MemberID INT,
    @SubscriptionID INT,
    @StartDate DATE,
    @EndDate DATE = NULL
AS
BEGIN
    DECLARE @Fee DECIMAL(18,2)
    DECLARE @Desc NVARCHAR(200)

    -- Get Fee and Description
    SELECT @Fee = s.Fee, @Desc = sp.SportName + ' - ' + s.PackageName + ' Subscription Assigned'
    FROM Subscriptions s INNER JOIN Sports sp ON s.SportID = sp.SportID
    WHERE s.SubscriptionID = @SubscriptionID;

    -- Insert Subscription
    INSERT INTO MemberSubscriptions (MemberID, SubscriptionID, StartDate, EndDate, IsActive)
    VALUES (@MemberID, @SubscriptionID, @StartDate, @EndDate, 1);

    DECLARE @NewSubID INT = SCOPE_IDENTITY();

    -- Post to Ledger (Debit)
    INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID)
    VALUES (@MemberID, GETDATE(), @Desc, @Fee, 0, 'Subscription', @NewSubID);
END
GO

-- ============================================
-- 6. POS Transactions Table & Procedures
-- ============================================

CREATE TABLE [POSTransactions] (
    [TransactionID] INT IDENTITY(1000,1) PRIMARY KEY,
    [CustomerType] NVARCHAR(50) NOT NULL, -- Member, Affiliated Member, Guest
    [MemberID] INT NULL, -- NULL if Guest or Affiliated
    [CustomerName] NVARCHAR(150) NOT NULL,
    [SubscriptionID] INT FOREIGN KEY REFERENCES [Subscriptions](SubscriptionID),
    [Amount] DECIMAL(18,2) NOT NULL,
    [TransactionDate] DATETIME DEFAULT GETDATE(),
    [ValidityPeriod] NVARCHAR(50) DEFAULT '1 Day',
    [Status] NVARCHAR(50) DEFAULT 'Completed'
);
GO

CREATE PROCEDURE [sp_GetDailyPackages]
AS
BEGIN
    SELECT 
        s.SubscriptionID, 
        s.SportID, 
        sp.SportName, 
        s.PackageName, 
        s.Fee 
    FROM Subscriptions s
    INNER JOIN Sports sp ON s.SportID = sp.SportID
    WHERE s.SubscriptionType = 'Daily' AND s.Status = 1
    ORDER BY sp.SportName, s.PackageName;
END
GO

CREATE PROCEDURE [sp_InsertPOSTransaction]
    @CustomerType NVARCHAR(50),
    @MemberID INT = NULL,
    @CustomerName NVARCHAR(150),
    @SubscriptionID INT,
    @Amount DECIMAL(18,2)
AS
BEGIN
    INSERT INTO POSTransactions (CustomerType, MemberID, CustomerName, SubscriptionID, Amount)
    VALUES (@CustomerType, @MemberID, @CustomerName, @SubscriptionID, @Amount);

    DECLARE @NewTransID INT = SCOPE_IDENTITY();

    -- If Member, post to Ledger (Debit and Credit for POS since it's instantly paid)
    IF @MemberID IS NOT NULL
    BEGIN
        DECLARE @Desc NVARCHAR(200)
        SELECT @Desc = 'POS Service - ' + sp.SportName + ' (' + s.PackageName + ')'
        FROM Subscriptions s INNER JOIN Sports sp ON s.SportID = sp.SportID
        WHERE s.SubscriptionID = @SubscriptionID;

        -- Debit (Charge for service)
        INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID)
        VALUES (@MemberID, GETDATE(), @Desc, @Amount, 0, 'POS', @NewTransID);

        -- Credit (Instant POS Payment)
        INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID)
        VALUES (@MemberID, GETDATE(), 'POS Payment Received', 0, @Amount, 'POS_Pay', @NewTransID);
    END

    -- Return the inserted TransactionID to show on receipt
    SELECT @NewTransID AS NewTransactionID;
END
GO

-- ============================================
-- 7. Ledger Table & Procedures
-- ============================================

CREATE TABLE [LedgerEntries] (
    [EntryID] INT IDENTITY(1,1) PRIMARY KEY,
    [MemberID] INT NOT NULL, -- References MemberShip
    [TransactionDate] DATETIME DEFAULT GETDATE(),
    [Description] NVARCHAR(255) NOT NULL,
    [DebitAmount] DECIMAL(18,2) DEFAULT 0,
    [CreditAmount] DECIMAL(18,2) DEFAULT 0,
    [RefType] NVARCHAR(50), -- 'Subscription', 'POS', 'POS_Pay', 'Manual_Pay'
    [RefID] INT NULL
);
GO

CREATE PROCEDURE [sp_GetMemberLedger]
    @MemberID INT
AS
BEGIN
    SELECT 
        EntryID,
        TransactionDate,
        ISNULL(RefType, '') + CASE WHEN RefID IS NOT NULL THEN '-' + CAST(RefID AS NVARCHAR) ELSE '' END AS RefNo,
        Description,
        DebitAmount,
        CreditAmount
    FROM LedgerEntries
    WHERE MemberID = @MemberID
    ORDER BY TransactionDate ASC, EntryID ASC;
END
GO

CREATE PROCEDURE [sp_AddPayment]
    @MemberID INT,
    @Amount DECIMAL(18,2),
    @Description NVARCHAR(255)
AS
BEGIN
    INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID)
    VALUES (@MemberID, GETDATE(), @Description, 0, @Amount, 'Manual_Pay', NULL);
END
GO

-- ============================================
-- 8. Auto-Billing Procedure
-- ============================================

CREATE PROCEDURE [sp_AutoGenerateMemberBilling]
    @MemberID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Temporary table to hold active monthly/continuous subscriptions
    DECLARE @ActiveSubs TABLE (
        MemberSubID INT,
        SubscriptionID INT,
        Fee DECIMAL(18,2),
        SportName NVARCHAR(100),
        PackageName NVARCHAR(100),
        StartDate DATE
    );

    INSERT INTO @ActiveSubs
    SELECT 
        ms.MemberSubID, 
        s.SubscriptionID, 
        s.Fee,
        sp.SportName,
        s.PackageName,
        ms.StartDate
    FROM MemberSubscriptions ms
    INNER JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
    INNER JOIN Sports sp ON s.SportID = sp.SportID
    WHERE ms.MemberID = @MemberID 
      AND ms.IsActive = 1 
      AND s.SubscriptionType IN ('Monthly', 'Continuous');

    DECLARE @MemberSubID INT, @Fee DECIMAL(18,2), @SportName NVARCHAR(100), @PackageName NVARCHAR(100), @StartDate DATE;
    DECLARE @ExpectedMonths INT, @BilledMonths INT, @MonthsDiff INT;
    DECLARE @Desc NVARCHAR(255);

    DECLARE subCursor CURSOR FOR 
    SELECT MemberSubID, Fee, SportName, PackageName, StartDate FROM @ActiveSubs;

    OPEN subCursor;
    FETCH NEXT FROM subCursor INTO @MemberSubID, @Fee, @SportName, @PackageName, @StartDate;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Calculate expected billing cycles securely
        SET @MonthsDiff = 0;
        WHILE DATEADD(month, @MonthsDiff, @StartDate) <= CAST(GETDATE() AS DATE)
        BEGIN
            SET @MonthsDiff = @MonthsDiff + 1;
        END
        SET @ExpectedMonths = @MonthsDiff; 

        -- Count how many times this subscription was already billed
        SELECT @BilledMonths = COUNT(*) 
        FROM LedgerEntries 
        WHERE RefType = 'Subscription' AND RefID = @MemberSubID;

        -- Generate missing bills
        WHILE @BilledMonths < @ExpectedMonths
        BEGIN
            -- Calculate the exact date this bill was supposed to be generated
            DECLARE @BillingDate DATETIME = DATEADD(month, @BilledMonths, @StartDate);
            
            -- Set the description for the specific month being billed
            SET @Desc = 'Auto Bill: ' + @SportName + ' - ' + @PackageName + ' (' + DATENAME(month, @BillingDate) + ' ' + CAST(YEAR(@BillingDate) AS NVARCHAR) + ')';

            INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID)
            VALUES (@MemberID, @BillingDate, @Desc, @Fee, 0, 'Subscription', @MemberSubID);

            SET @BilledMonths = @BilledMonths + 1;
        END

        FETCH NEXT FROM subCursor INTO @MemberSubID, @Fee, @SportName, @PackageName, @StartDate;
    END

    CLOSE subCursor;
    DEALLOCATE subCursor;
END
GO

- -   C r e a t e   A c c e s s L o g s   T a b l e  
 C R E A T E   T A B L E   [ A c c e s s L o g s ]   (  
         [ L o g I D ]   I N T   I D E N T I T Y ( 1 , 1 )   P R I M A R Y   K E Y ,  
         [ M e m b e r I D ]   I N T   N U L L ,  
         [ M e m b e r N o ]   N V A R C H A R ( 5 0 )   N O T   N U L L ,  
         [ S p o r t I D ]   I N T   N O T   N U L L ,  
         [ A c c e s s T i m e ]   D A T E T I M E   D E F A U L T   G E T D A T E ( ) ,  
         [ A c c e s s R e s u l t ]   N V A R C H A R ( 2 0 )   N O T   N U L L ,   - -   ' G r a n t e d '   o r   ' D e n i e d '  
         [ D e n i a l R e a s o n ]   N V A R C H A R ( 2 5 5 )   N U L L  
 ) ;  
 G O  
  
 - -   S t o r e d   P r o c e d u r e   f o r   V a l i d a t i o n  
 C R E A T E   P R O C E D U R E   [ s p _ V a l i d a t e M e m b e r A c c e s s ]  
         @ M e m b e r N o   N V A R C H A R ( 5 0 ) ,  
         @ S p o r t I D   I N T  
 A S  
 B E G I N  
         S E T   N O C O U N T   O N ;  
  
         D E C L A R E   @ M e m b e r I D   I N T   =   N U L L ;  
         D E C L A R E   @ F u l l N a m e   N V A R C H A R ( 1 5 0 )   =   ' ' ;  
         D E C L A R E   @ M e m b e r S t a t u s   N V A R C H A R ( 5 0 )   =   ' ' ;  
         D E C L A R E   @ N e t B a l a n c e   D E C I M A L ( 1 8 , 2 )   =   0 ;  
          
         D E C L A R E   @ A c c e s s R e s u l t   N V A R C H A R ( 2 0 )   =   ' G r a n t e d ' ;  
         D E C L A R E   @ D e n i a l R e a s o n   N V A R C H A R ( 2 5 5 )   =   ' ' ;  
  
         - -   1 .   I d e n t i f y   U s e r  
         S E L E C T    
                 @ M e m b e r I D   =   M e m b e r I D ,  
                 @ F u l l N a m e   =   M e m b e r N a m e ,  
                 @ M e m b e r S t a t u s   =   S t a t u s  
         F R O M   [ M e m b e r S h i p ] . [ d b o ] . [ M e m b e r P r o f i l e ]  
         W H E R E   M e m b e r N o   =   @ M e m b e r N o ;  
  
         I F   @ M e m b e r I D   I S   N U L L  
         B E G I N  
                 S E T   @ A c c e s s R e s u l t   =   ' D e n i e d ' ;  
                 S E T   @ D e n i a l R e a s o n   =   ' M e m b e r   n o t   f o u n d . ' ;  
         E N D  
         E L S E  
         B E G I N  
                 - -   2 .   C h e c k   M e m b e r s h i p   S t a t u s  
                 I F   @ M e m b e r S t a t u s   < >   ' A c t i v e '  
                 B E G I N  
                         S E T   @ A c c e s s R e s u l t   =   ' D e n i e d ' ;  
                         S E T   @ D e n i a l R e a s o n   =   ' M e m b e r s h i p   i s   n o t   a c t i v e   ( '   +   I S N U L L ( @ M e m b e r S t a t u s ,   ' U n k n o w n ' )   +   ' ) . ' ;  
                 E N D  
                 E L S E  
                 B E G I N  
                         - -   3 .   C h e c k   P a y m e n t   C l e a r a n c e   ( N e t   B a l a n c e )  
                         S E L E C T   @ N e t B a l a n c e   =   I S N U L L ( S U M ( D e b i t A m o u n t )   -   S U M ( C r e d i t A m o u n t ) ,   0 )  
                         F R O M   L e d g e r E n t r i e s  
                         W H E R E   M e m b e r I D   =   @ M e m b e r I D ;  
  
                         I F   @ N e t B a l a n c e   >   0  
                         B E G I N  
                                 S E T   @ A c c e s s R e s u l t   =   ' D e n i e d ' ;  
                                 S E T   @ D e n i a l R e a s o n   =   ' O u t s t a n d i n g   D u e s :   P K R   '   +   C A S T ( C A S T ( @ N e t B a l a n c e   A S   I N T )   A S   N V A R C H A R )   +   ' .   P l e a s e   c l e a r   p a y m e n t s . ' ;  
                         E N D  
                         E L S E  
                         B E G I N  
                                 - -   4 .   C h e c k   S u b s c r i p t i o n   A c c e s s  
                                 D E C L A R E   @ H a s A c c e s s   B I T   =   0 ;  
  
                                 - -   C h e c k   r e g u l a r   s u b s c r i p t i o n s  
                                 I F   E X I S T S   (  
                                         S E L E C T   1    
                                         F R O M   M e m b e r S u b s c r i p t i o n s   m s  
                                         I N N E R   J O I N   S u b s c r i p t i o n s   s   O N   m s . S u b s c r i p t i o n I D   =   s . S u b s c r i p t i o n I D  
                                         W H E R E   m s . M e m b e r I D   =   @ M e m b e r I D    
                                             A N D   s . S p o r t I D   =   @ S p o r t I D  
                                             A N D   m s . I s A c t i v e   =   1  
                                             A N D   ( m s . E n d D a t e   I S   N U L L   O R   m s . E n d D a t e   > =   C A S T ( G E T D A T E ( )   A S   D A T E ) )  
                                 )  
                                 B E G I N  
                                         S E T   @ H a s A c c e s s   =   1 ;  
                                 E N D  
  
                                 - -   C h e c k   1 - D a y   P O S   p a s s e s   f o r   t o d a y  
                                 I F   @ H a s A c c e s s   =   0  
                                 B E G I N  
                                         I F   E X I S T S   (  
                                                 S E L E C T   1  
                                                 F R O M   P O S T r a n s a c t i o n s   p o s  
                                                 I N N E R   J O I N   S u b s c r i p t i o n s   s   O N   p o s . S u b s c r i p t i o n I D   =   s . S u b s c r i p t i o n I D  
                                                 W H E R E   p o s . M e m b e r I D   =   @ M e m b e r I D  
                                                     A N D   s . S p o r t I D   =   @ S p o r t I D  
                                                     A N D   C A S T ( p o s . T r a n s a c t i o n D a t e   A S   D A T E )   =   C A S T ( G E T D A T E ( )   A S   D A T E )  
                                         )  
                                         B E G I N  
                                                 S E T   @ H a s A c c e s s   =   1 ;  
                                         E N D  
                                 E N D  
  
                                 I F   @ H a s A c c e s s   =   0  
                                 B E G I N  
                                         S E T   @ A c c e s s R e s u l t   =   ' D e n i e d ' ;  
                                         S E T   @ D e n i a l R e a s o n   =   ' N o   a c t i v e   s u b s c r i p t i o n   o r   d a i l y   p a s s   f o r   t h i s   f a c i l i t y . ' ;  
                                 E N D  
                         E N D  
                 E N D  
         E N D  
  
         - -   5 .   L o g   t h e   a t t e m p t  
         I N S E R T   I N T O   A c c e s s L o g s   ( M e m b e r I D ,   M e m b e r N o ,   S p o r t I D ,   A c c e s s R e s u l t ,   D e n i a l R e a s o n )  
         V A L U E S   ( @ M e m b e r I D ,   @ M e m b e r N o ,   @ S p o r t I D ,   @ A c c e s s R e s u l t ,   @ D e n i a l R e a s o n ) ;  
  
         - -   6 .   R e t u r n   R e s u l t  
         S E L E C T    
                 I S N U L L ( @ M e m b e r I D ,   0 )   A S   M e m b e r I D ,  
                 @ M e m b e r N o   A S   M e m b e r N o ,  
                 I S N U L L ( @ F u l l N a m e ,   ' N / A ' )   A S   F u l l N a m e ,  
                 I S N U L L ( @ M e m b e r S t a t u s ,   ' N / A ' )   A S   M e m b e r S t a t u s ,  
                 @ N e t B a l a n c e   A S   N e t B a l a n c e ,  
                 @ A c c e s s R e s u l t   A S   A c c e s s R e s u l t ,  
                 @ D e n i a l R e a s o n   A S   D e n i a l R e a s o n ;  
 E N D  
 G O  
 