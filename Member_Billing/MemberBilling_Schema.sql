-- ============================================================================
-- LAHORE GYMKHANA CLUB - MEMBER BILLING & SUBSCRIPTIONS SCHEMA
-- Target Database: Member_Billing
-- ============================================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'Member_Billing')
BEGIN
    CREATE DATABASE Member_Billing;
END
GO

USE Member_Billing;
GO

-- ────────────────────────────────────────────────────────────────────────────
-- 1. Synonyms to MemberShip database master tables
-- ────────────────────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'FormTypeMain')
BEGIN
    CREATE SYNONYM FormTypeMain FOR MemberShip.dbo.FormTypeMain;
    PRINT 'Created Synonym FormTypeMain -> MemberShip.dbo.FormTypeMain';
END
GO

IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'MembershipType')
BEGIN
    CREATE SYNONYM MembershipType FOR MemberShip.dbo.MembershipType;
    PRINT 'Created Synonym MembershipType -> MemberShip.dbo.MembershipType';
END
GO

IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'MemberProfile')
BEGIN
    CREATE SYNONYM MemberProfile FOR MemberShip.dbo.MemberProfile;
    PRINT 'Created Synonym MemberProfile -> MemberShip.dbo.MemberProfile';
END
GO

IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'MemberSpouses')
BEGIN
    CREATE SYNONYM MemberSpouses FOR MemberShip.dbo.MemberSpouses;
    PRINT 'Created Synonym MemberSpouses -> MemberShip.dbo.MemberSpouses';
END
GO

IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'MemberChildren')
BEGIN
    CREATE SYNONYM MemberChildren FOR MemberShip.dbo.MemberChildren;
    PRINT 'Created Synonym MemberChildren -> MemberShip.dbo.MemberChildren';
END
GO

IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'MemberPayment')
BEGIN
    CREATE SYNONYM MemberPayment FOR MemberShip.dbo.MemberPayment;
    PRINT 'Created Synonym MemberPayment -> MemberShip.dbo.MemberPayment';
END
GO

-- ────────────────────────────────────────────────────────────────────────────
-- 2. Parent Table: MemberBilling_Subscriptions
-- ────────────────────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MemberBilling_Subscriptions')
BEGIN
    CREATE TABLE MemberBilling_Subscriptions (
        SubscriptionID         INT IDENTITY(1,1) PRIMARY KEY,
        SubscriptionCode       NVARCHAR(50) NOT NULL,
        SubscriptionName       NVARCHAR(150) NOT NULL,
        Amount                 DECIMAL(18,2) NOT NULL,
        HasAgeBenefit          BIT DEFAULT 0,                       -- 1 = Multi-Tier Age Concession
        HasCategoryRates       BIT DEFAULT 0,                       -- 1 = Differential Category & Type Pricing
        FinancialHeadCode      NVARCHAR(50) NULL,                   -- Chart of Accounts / Expenditure Code
        FinancialHeadName      NVARCHAR(200) NULL,                  -- Chart of Accounts / Expenditure Title
        Description            NVARCHAR(500) NULL,                  -- Remarks & Policy Notes
        IsActive               BIT DEFAULT 1,                       -- 1 = Active, 0 = Inactive
        CreatedBy              NVARCHAR(100) NULL,
        CreatedDate            DATETIME DEFAULT GETDATE(),
        UpdatedDate            DATETIME NULL,
        CONSTRAINT UQ_MB_SubscriptionCode UNIQUE (SubscriptionCode)
    );

    CREATE NONCLUSTERED INDEX IX_MemberBilling_Subscriptions_Code 
        ON MemberBilling_Subscriptions(SubscriptionCode);

    CREATE NONCLUSTERED INDEX IX_MemberBilling_Subscriptions_IsActive 
        ON MemberBilling_Subscriptions(IsActive) 
        INCLUDE (SubscriptionCode, SubscriptionName, Amount, HasAgeBenefit, HasCategoryRates);

    PRINT 'Table MemberBilling_Subscriptions created successfully.';
END
ELSE
BEGIN
    -- Ensure HasCategoryRates column exists
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('MemberBilling_Subscriptions') AND name = 'HasCategoryRates')
    BEGIN
        ALTER TABLE MemberBilling_Subscriptions ADD HasCategoryRates BIT DEFAULT 0;
        PRINT 'Added HasCategoryRates column to MemberBilling_Subscriptions.';
    END
END
GO

-- ────────────────────────────────────────────────────────────────────────────
-- 3. Child Table: MemberBilling_SubscriptionAgeBenefits (Multi-Tier Age Slabs)
-- ────────────────────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MemberBilling_SubscriptionAgeBenefits')
BEGIN
    CREATE TABLE MemberBilling_SubscriptionAgeBenefits (
        BenefitID              INT IDENTITY(1,1) PRIMARY KEY,
        SubscriptionID         INT NOT NULL,
        BenefitTitle           NVARCHAR(100) NULL,                  -- e.g. Senior Tier 1 (60-69 yrs)
        MinAge                 INT NOT NULL,                        -- Minimum age for slab
        MaxAge                 INT NOT NULL,                        -- Maximum age for slab
        MinMembershipYears     INT DEFAULT 0,                       -- Minimum membership years required
        DiscountPercentage     DECIMAL(5,2) DEFAULT 0,              -- Percentage discount
        DiscountFixed          DECIMAL(18,2) DEFAULT 0,             -- Fixed amount discount (PKR)
        CreatedDate            DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_SubscriptionAgeBenefits FOREIGN KEY (SubscriptionID) 
            REFERENCES MemberBilling_Subscriptions(SubscriptionID) ON DELETE CASCADE
    );

    CREATE NONCLUSTERED INDEX IX_SubscriptionAgeBenefits_SubID 
        ON MemberBilling_SubscriptionAgeBenefits(SubscriptionID, MinAge, MaxAge);

    PRINT 'Table MemberBilling_SubscriptionAgeBenefits created successfully.';
END
GO

-- ────────────────────────────────────────────────────────────────────────────
-- 4. Child Table: MemberBilling_SubscriptionCategoryRates (Category & Type Pricing)
-- ────────────────────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MemberBilling_SubscriptionCategoryRates')
BEGIN
    CREATE TABLE MemberBilling_SubscriptionCategoryRates (
        RateID                 INT IDENTITY(1,1) PRIMARY KEY,
        SubscriptionID         INT NOT NULL,
        CategoryID             INT NULL,                            -- FormTypeMain.id (0/NULL = All Categories)
        CategoryName           NVARCHAR(150) NOT NULL,              -- FormTypeMain.FormTypeName or 'All Categories'
        MembershipTypeID       INT NULL,                            -- MembershipType.Id (0/NULL = All Types)
        MembershipTypeName     NVARCHAR(100) NOT NULL,              -- MembershipType.MembershipType or 'All Membership Types'
        Amount                 DECIMAL(18,2) NOT NULL,              -- Rate in PKR
        CreatedDate            DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_SubscriptionCategoryRates FOREIGN KEY (SubscriptionID) 
            REFERENCES MemberBilling_Subscriptions(SubscriptionID) ON DELETE CASCADE
    );

    CREATE NONCLUSTERED INDEX IX_SubscriptionCategoryRates_SubID 
        ON MemberBilling_SubscriptionCategoryRates(SubscriptionID, CategoryID, MembershipTypeID);

    PRINT 'Table MemberBilling_SubscriptionCategoryRates created successfully.';
END
GO

-- ────────────────────────────────────────────────────────────────────────────
-- 5. Monthly Billing Tables
-- ────────────────────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MemberBilling')
BEGIN
    CREATE TABLE MemberBilling (
        BillingID          INT IDENTITY(1,1) PRIMARY KEY,
        MemberNo           NVARCHAR(50) NOT NULL,
        BillingMonth       DATE NOT NULL,
        StatementDate      DATE NOT NULL,
        DueDate            DATE NOT NULL,
        PreviousBalance    DECIMAL(18,2) DEFAULT 0,
        PaymentReceived    DECIMAL(18,2) DEFAULT 0,
        BillAmount         DECIMAL(18,2) DEFAULT 0,
        Adjustments        DECIMAL(18,2) DEFAULT 0,
        DueAmount          DECIMAL(18,2) DEFAULT 0,
        CreatedDate        DATETIME DEFAULT GETDATE()
    );
    PRINT 'Table MemberBilling created successfully.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MemberSubscriptionDetail')
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
    PRINT 'Table MemberSubscriptionDetail created successfully.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MemberSubscriptionMisc')
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
    PRINT 'Table MemberSubscriptionMisc created successfully.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MemberLedger')
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
        SortOrder          INT DEFAULT 0
    );
    PRINT 'Table MemberLedger created successfully.';
END
GO

-- ────────────────────────────────────────────────────────────────────────────
-- 6. Stored Procedure: usp_GetApplicableSubscriptionFee
-- ────────────────────────────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE usp_GetApplicableSubscriptionFee
    @SubscriptionCode NVARCHAR(50) = NULL,
    @SubscriptionID   INT = NULL,
    @MemberAge        INT = NULL,
    @MembershipYears  INT = NULL,
    @CategoryID       INT = NULL,
    @MembershipTypeID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ResolvedSubID INT;
    DECLARE @BaseAmount DECIMAL(18,2) = 0;
    DECLARE @ApplicableAmount DECIMAL(18,2) = 0;
    DECLARE @HasAgeBenefit BIT = 0;
    DECLARE @HasCategoryRates BIT = 0;
    DECLARE @SubName NVARCHAR(150);

    IF @SubscriptionID IS NOT NULL
    BEGIN
        SELECT 
            @ResolvedSubID = SubscriptionID,
            @BaseAmount = Amount,
            @HasAgeBenefit = ISNULL(HasAgeBenefit, 0),
            @HasCategoryRates = ISNULL(HasCategoryRates, 0),
            @SubName = SubscriptionName
        FROM MemberBilling_Subscriptions
        WHERE SubscriptionID = @SubscriptionID AND IsActive = 1;
    END
    ELSE IF @SubscriptionCode IS NOT NULL
    BEGIN
        SELECT 
            @ResolvedSubID = SubscriptionID,
            @BaseAmount = Amount,
            @HasAgeBenefit = ISNULL(HasAgeBenefit, 0),
            @HasCategoryRates = ISNULL(HasCategoryRates, 0),
            @SubName = SubscriptionName
        FROM MemberBilling_Subscriptions
        WHERE SubscriptionCode = @SubscriptionCode AND IsActive = 1;
    END

    IF @ResolvedSubID IS NULL
    BEGIN
        SELECT 
            0 AS SubscriptionID,
            @SubscriptionCode AS SubscriptionCode,
            'Invalid or Inactive Subscription' AS SubscriptionName,
            0.00 AS BaseAmount,
            0.00 AS DiscountAmount,
            0.00 AS NetPayable,
            0 AS QualifiesForConcession,
            'None' AS MatchedTier,
            'Invalid or Inactive Subscription' AS StatusMessage;
        RETURN;
    END

    SET @ApplicableAmount = @BaseAmount;
    DECLARE @RateSource NVARCHAR(100) = 'Standard Base Rate';

    -- 1. Check for specific Category & Membership Type Rate
    IF @HasCategoryRates = 1 AND (@CategoryID IS NOT NULL OR @MembershipTypeID IS NOT NULL)
    BEGIN
        DECLARE @SpecificAmount DECIMAL(18,2) = NULL;
        DECLARE @CatName NVARCHAR(150), @TypeName NVARCHAR(100);

        -- Priority A: Exact Category & Exact Type
        SELECT TOP 1 @SpecificAmount = Amount, @CatName = CategoryName, @TypeName = MembershipTypeName
        FROM MemberBilling_SubscriptionCategoryRates
        WHERE SubscriptionID = @ResolvedSubID 
          AND CategoryID = @CategoryID 
          AND MembershipTypeID = @MembershipTypeID;

        -- Priority B: Exact Category & All Types (or NULL)
        IF @SpecificAmount IS NULL AND @CategoryID IS NOT NULL
        BEGIN
            SELECT TOP 1 @SpecificAmount = Amount, @CatName = CategoryName, @TypeName = MembershipTypeName
            FROM MemberBilling_SubscriptionCategoryRates
            WHERE SubscriptionID = @ResolvedSubID 
              AND CategoryID = @CategoryID 
              AND (MembershipTypeID IS NULL OR MembershipTypeID = 0);
        END

        -- Priority C: All Categories (or NULL) & Exact Type
        IF @SpecificAmount IS NULL AND @MembershipTypeID IS NOT NULL
        BEGIN
            SELECT TOP 1 @SpecificAmount = Amount, @CatName = CategoryName, @TypeName = MembershipTypeName
            FROM MemberBilling_SubscriptionCategoryRates
            WHERE SubscriptionID = @ResolvedSubID 
              AND (CategoryID IS NULL OR CategoryID = 0)
              AND MembershipTypeID = @MembershipTypeID;
        END

        IF @SpecificAmount IS NOT NULL
        BEGIN
            SET @ApplicableAmount = @SpecificAmount;
            SET @RateSource = 'Differential Rate: ' + ISNULL(@CatName, 'All') + ' / ' + ISNULL(@TypeName, 'All');
        END
    END

    -- 2. Check Age Concession
    DECLARE @DiscPct DECIMAL(5,2) = 0;
    DECLARE @DiscFixed DECIMAL(18,2) = 0;
    DECLARE @CalculatedDiscount DECIMAL(18,2) = 0;
    DECLARE @NetPayable DECIMAL(18,2) = 0;
    DECLARE @QualifiesForConcession BIT = 0;
    DECLARE @MatchedTierTitle NVARCHAR(100) = @RateSource;

    IF @HasAgeBenefit = 1 AND @MemberAge IS NOT NULL
    BEGIN
        SELECT TOP 1
            @DiscPct = ISNULL(DiscountPercentage, 0),
            @DiscFixed = ISNULL(DiscountFixed, 0),
            @MatchedTierTitle = ISNULL(BenefitTitle, 'Age Concession'),
            @QualifiesForConcession = 1
        FROM MemberBilling_SubscriptionAgeBenefits
        WHERE SubscriptionID = @ResolvedSubID
          AND @MemberAge >= MinAge AND @MemberAge <= MaxAge
          AND (@MembershipYears IS NULL OR @MembershipYears >= ISNULL(MinMembershipYears, 0))
        ORDER BY DiscountPercentage DESC, DiscountFixed DESC;

        IF @QualifiesForConcession = 1
        BEGIN
            IF @DiscPct > 0
                SET @CalculatedDiscount = (@ApplicableAmount * @DiscPct) / 100.00;

            IF @DiscFixed > 0
                SET @CalculatedDiscount = @CalculatedDiscount + @DiscFixed;

            IF @CalculatedDiscount > @ApplicableAmount
                SET @CalculatedDiscount = @ApplicableAmount;
        END
    END

    SET @NetPayable = @ApplicableAmount - @CalculatedDiscount;

    SELECT 
        @ResolvedSubID AS SubscriptionID,
        @SubscriptionCode AS SubscriptionCode,
        @SubName AS SubscriptionName,
        @ApplicableAmount AS BaseAmount,
        @CalculatedDiscount AS DiscountAmount,
        @NetPayable AS NetPayable,
        @QualifiesForConcession AS QualifiesForConcession,
        @MatchedTierTitle AS MatchedTier,
        CASE WHEN @QualifiesForConcession = 1 THEN 'Age Concession Applied: ' + @MatchedTierTitle ELSE @RateSource END AS StatusMessage;
END
GO

PRINT 'Member Billing SQL Schema in database Member_Billing successfully initialized.';
