-- ============================================================
-- Member Statement Report — Sample Tables & Data
-- Database: MemberShip
-- ============================================================

USE MemberShip;
GO

-- ────────────────────────────────────────────────────────────
-- 1. MemberBilling — Monthly billing header per member
-- ────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'MemberBilling')
BEGIN
    CREATE TABLE MemberBilling (
        BillingID          INT IDENTITY(1,1) PRIMARY KEY,
        MemberNo           NVARCHAR(50) NOT NULL,
        BillingMonth       DATE NOT NULL,           -- e.g. 2026-07-01 for Jul-2026
        StatementDate      DATE NOT NULL,
        DueDate            DATE NOT NULL,
        PreviousBalance    DECIMAL(18,2) DEFAULT 0,
        PaymentReceived    DECIMAL(18,2) DEFAULT 0,
        BillAmount         DECIMAL(18,2) DEFAULT 0,
        Adjustments        DECIMAL(18,2) DEFAULT 0,
        DueAmount          DECIMAL(18,2) DEFAULT 0,
        CreatedDate        DATETIME DEFAULT GETDATE()
    );
END
GO

-- ────────────────────────────────────────────────────────────
-- 2. MemberSubscriptionDetail — Subscription breakdown
-- ────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'MemberSubscriptionDetail')
BEGIN
    CREATE TABLE MemberSubscriptionDetail (
        DetailID           INT IDENTITY(1,1) PRIMARY KEY,
        BillingID          INT NOT NULL,
        MemberNo           NVARCHAR(50) NOT NULL,
        GeneralSub         DECIMAL(18,2) DEFAULT 0,
        LibrarySub         DECIMAL(18,2) DEFAULT 0,
        FilmSub            DECIMAL(18,2) DEFAULT 0,
        MusicalEve         DECIMAL(18,2) DEFAULT 0,
        Utilities          DECIMAL(18,2) DEFAULT 0,
        WelfareFund        DECIMAL(18,2) DEFAULT 0,
        DevFund            DECIMAL(18,2) DEFAULT 0,
        SportTotal         DECIMAL(18,2) DEFAULT 0,
        SubTotal           DECIMAL(18,2) DEFAULT 0
    );
END
GO

-- ────────────────────────────────────────────────────────────
-- 3. MemberSubscriptionMisc — Misc / additional charges
-- ────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'MemberSubscriptionMisc')
BEGIN
    CREATE TABLE MemberSubscriptionMisc (
        MiscID             INT IDENTITY(1,1) PRIMARY KEY,
        BillingID          INT NOT NULL,
        MemberNo           NVARCHAR(50) NOT NULL,
        ItemName           NVARCHAR(100) NOT NULL,
        Sports             DECIMAL(18,2) DEFAULT 0,
        Subs               DECIMAL(18,2) DEFAULT 0,
        GST                DECIMAL(18,2) DEFAULT 0,
        Locker             DECIMAL(18,2) DEFAULT 0,
        Misc               DECIMAL(18,2) DEFAULT 0
    );
END
GO

-- ────────────────────────────────────────────────────────────
-- 4. MemberLedger — Transaction-level entries
-- ────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'MemberLedger')
BEGIN
    CREATE TABLE MemberLedger (
        LedgerID           INT IDENTITY(1,1) PRIMARY KEY,
        MemberNo           NVARCHAR(50) NOT NULL,
        TransDate          DATE NULL,
        Particulars        NVARCHAR(200) NOT NULL,
        Reference          NVARCHAR(100) NULL,
        Debit              DECIMAL(18,2) DEFAULT 0,
        Credit             DECIMAL(18,2) DEFAULT 0,
        Balance            DECIMAL(18,2) DEFAULT 0,
        SortOrder          INT DEFAULT 0               -- for ordering (0 = BF, then chronological)
    );
END
GO


-- ============================================================
-- SAMPLE DATA — Member R-15553
-- ============================================================

-- Billing header
IF NOT EXISTS (SELECT 1 FROM MemberBilling WHERE MemberNo = 'R-15553' AND BillingMonth = '2026-07-01')
BEGIN
    INSERT INTO MemberBilling (MemberNo, BillingMonth, StatementDate, DueDate,
                               PreviousBalance, PaymentReceived, BillAmount, Adjustments, DueAmount)
    VALUES ('R-15553', '2026-07-01', '2026-07-31', '2026-08-31',
            4890, 4890, 4890, 0, 4890);
END
GO

-- Subscription detail
DECLARE @BillingID1 INT = (SELECT TOP 1 BillingID FROM MemberBilling WHERE MemberNo = 'R-15553' AND BillingMonth = '2026-07-01');

IF @BillingID1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM MemberSubscriptionDetail WHERE BillingID = @BillingID1)
BEGIN
    INSERT INTO MemberSubscriptionDetail (BillingID, MemberNo,
        GeneralSub, LibrarySub, FilmSub, MusicalEve, Utilities, WelfareFund, DevFund, SportTotal, SubTotal)
    VALUES (@BillingID1, 'R-15553',
        2500, 200, 110, 150, 630, 300, 500, 500, 4890);
END
GO

-- Misc charges
DECLARE @BillingID1m INT = (SELECT TOP 1 BillingID FROM MemberBilling WHERE MemberNo = 'R-15553' AND BillingMonth = '2026-07-01');

IF @BillingID1m IS NOT NULL AND NOT EXISTS (SELECT 1 FROM MemberSubscriptionMisc WHERE BillingID = @BillingID1m)
BEGIN
    INSERT INTO MemberSubscriptionMisc (BillingID, MemberNo, ItemName, Sports, Subs, GST, Locker, Misc)
    VALUES (@BillingID1m, 'R-15553', 'Non Playing Fixed Contribution', 500, 0, 0, 0, 0);
END
GO

-- Ledger entries
IF NOT EXISTS (SELECT 1 FROM MemberLedger WHERE MemberNo = 'R-15553')
BEGIN
    INSERT INTO MemberLedger (MemberNo, TransDate, Particulars, Reference, Debit, Credit, Balance, SortOrder)
    VALUES 
        ('R-15553', NULL,             'BALANCE BROUGHT FORWARD',        NULL,            0,    0,    4890, 0),
        ('R-15553', '2026-07-15',     'Payment Received - CI 9265',     '26600004999',   0,    4890, 0,    1),
        ('R-15553', '2026-07-31',     'Monthly Subscription',           '2026-07',       4890, 0,    4890, 2);
END
GO


-- ============================================================
-- SAMPLE DATA — Member R-10200  (second sample member)
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM MemberBilling WHERE MemberNo = 'R-10200' AND BillingMonth = '2026-07-01')
BEGIN
    INSERT INTO MemberBilling (MemberNo, BillingMonth, StatementDate, DueDate,
                               PreviousBalance, PaymentReceived, BillAmount, Adjustments, DueAmount)
    VALUES ('R-10200', '2026-07-01', '2026-07-31', '2026-08-31',
            12500, 10000, 7800, 500, 10800);
END
GO

DECLARE @BillingID2 INT = (SELECT TOP 1 BillingID FROM MemberBilling WHERE MemberNo = 'R-10200' AND BillingMonth = '2026-07-01');

IF @BillingID2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM MemberSubscriptionDetail WHERE BillingID = @BillingID2)
BEGIN
    INSERT INTO MemberSubscriptionDetail (BillingID, MemberNo,
        GeneralSub, LibrarySub, FilmSub, MusicalEve, Utilities, WelfareFund, DevFund, SportTotal, SubTotal)
    VALUES (@BillingID2, 'R-10200',
        3500, 300, 150, 200, 850, 500, 800, 1500, 7800);
END
GO

DECLARE @BillingID2m INT = (SELECT TOP 1 BillingID FROM MemberBilling WHERE MemberNo = 'R-10200' AND BillingMonth = '2026-07-01');

IF @BillingID2m IS NOT NULL AND NOT EXISTS (SELECT 1 FROM MemberSubscriptionMisc WHERE BillingID = @BillingID2m)
BEGIN
    INSERT INTO MemberSubscriptionMisc (BillingID, MemberNo, ItemName, Sports, Subs, GST, Locker, Misc)
    VALUES 
        (@BillingID2m, 'R-10200', 'Swimming Pool', 800, 0, 0, 0, 0),
        (@BillingID2m, 'R-10200', 'Tennis Court',  700, 0, 0, 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM MemberLedger WHERE MemberNo = 'R-10200')
BEGIN
    INSERT INTO MemberLedger (MemberNo, TransDate, Particulars, Reference, Debit, Credit, Balance, SortOrder)
    VALUES 
        ('R-10200', NULL,             'BALANCE BROUGHT FORWARD',           NULL,            0,     0,     12500, 0),
        ('R-10200', '2026-07-05',     'Payment Received - Cheque 4421',    '26600009101',   0,     10000, 2500,  1),
        ('R-10200', '2026-07-15',     'Adjustment - Late Fee Waiver',      'ADJ-2026-07',   0,     500,   2000,  2),
        ('R-10200', '2026-07-31',     'Monthly Subscription',              '2026-07',       7800,  0,     9800,  3),
        ('R-10200', '2026-07-31',     'Sports Charges',                    '2026-07',       1500,  0,     11300, 4);
END
GO

PRINT 'Member Statement tables and sample data created successfully.';
GO
