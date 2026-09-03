USE [SportsModuleDB]
GO

-- ============================================
-- 1. Schema Changes: Add Dependent Columns
-- ============================================

-- Add dependent tracking columns to MemberSubscriptions
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('MemberSubscriptions') AND name = 'DependentMemberNo')
BEGIN
    ALTER TABLE MemberSubscriptions ADD 
        DependentMemberNo NVARCHAR(50) NULL,
        DependentName NVARCHAR(150) NULL,
        DependentRelation NVARCHAR(50) NULL;
END
GO

-- Add dependent tracking columns to LedgerEntries
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('LedgerEntries') AND name = 'DependentMemberNo')
BEGIN
    ALTER TABLE LedgerEntries ADD 
        DependentMemberNo NVARCHAR(50) NULL,
        DependentName NVARCHAR(150) NULL,
        DependentRelation NVARCHAR(50) NULL;
END
GO

-- ============================================
-- 2. ALTER sp_SearchMembers — Add Relationship
-- ============================================

ALTER PROCEDURE [dbo].[sp_SearchMembers]
    @SearchTerm NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF ISNULL(@SearchTerm, '') = ''
    BEGIN
        SELECT TOP 100
            MemberID,
            MemberNo AS MembershipNo,
            MemberName AS FullName,
            MemberNo + ' - ' + MemberName AS MemberDisplay,
            COALESCE(Mobile, ResidentialMobile, CompanyMobile, 'N/A') AS ContactNo,
            Status,
            'Self' AS Relationship
        FROM MemberShip.dbo.MemberProfile
        WHERE IsActive = '1'
        ORDER BY MemberName;
    END
    ELSE
    BEGIN
        SELECT TOP 200
            MemberID,
            MembershipNo,
            FullName,
            MemberDisplay,
            ContactNo,
            Status,
            Relationship
        FROM
        (
            -- Main Members
            SELECT
                MemberID,
                MemberNo AS MembershipNo,
                MemberName AS FullName,
                MemberNo + ' - ' + MemberName AS MemberDisplay,
                COALESCE(Mobile, ResidentialMobile, CompanyMobile, 'N/A') AS ContactNo,
                Status,
                'Self' AS Relationship,
                MemberName AS OrderName,
                1 AS Priority
            FROM MemberShip.dbo.MemberProfile
            WHERE IsActive = '1'
              AND (
                    MemberNo LIKE '%' + @SearchTerm + '%'
                 OR MemberName LIKE '%' + @SearchTerm + '%'
              )

            UNION ALL

            -- Spouses
            SELECT
                mp.MemberID,
                ms.MembershipNo,
                ms.SpouseName AS FullName,
                ms.MembershipNo + ' - ' + ms.SpouseName +
                ' (Spouse of ' + mp.MemberName + ')' AS MemberDisplay,
                COALESCE(mp.Mobile, mp.ResidentialMobile, mp.CompanyMobile, 'N/A') AS ContactNo,
                mp.Status,
                'Spouse' AS Relationship,
                mp.MemberName AS OrderName,
                2 AS Priority
            FROM MemberShip.dbo.MemberSpouses ms
            INNER JOIN MemberShip.dbo.MemberProfile mp
                ON ms.MemberID = mp.MemberID
            WHERE mp.IsActive = '1'
              AND ms.RecordStatus = 'Active'
              AND (
                    ms.MembershipNo LIKE '%' + @SearchTerm + '%'
                 OR ms.SpouseName LIKE '%' + @SearchTerm + '%'
              )

            UNION ALL

            -- Children
            SELECT
                mp.MemberID,
                mc.MembershipNo,
                mc.ChildName AS FullName,
                mc.MembershipNo + ' - ' + mc.ChildName +
                ' (' + mc.Relationship + ' of ' + mp.MemberName + ')' AS MemberDisplay,
                COALESCE(mp.Mobile, mp.ResidentialMobile, mp.CompanyMobile, 'N/A') AS ContactNo,
                mp.Status,
                mc.Relationship AS Relationship,
                mp.MemberName AS OrderName,
                3 AS Priority
            FROM MemberShip.dbo.MemberChildren mc
            INNER JOIN MemberShip.dbo.MemberProfile mp
                ON mc.MemberID = mp.MemberID
            WHERE mp.IsActive = '1'
              AND mc.RecordStatus = 'Active'
              AND (
                    mc.MembershipNo LIKE '%' + @SearchTerm + '%'
                 OR mc.ChildName LIKE '%' + @SearchTerm + '%'
              )
        ) AS Combined
        ORDER BY Priority, OrderName;
    END
END
GO

-- ============================================
-- 3. ALTER sp_AssignSubscription — Dependent Params
-- ============================================

ALTER PROCEDURE [dbo].[sp_AssignSubscription]
    @MemberID INT,
    @SubscriptionID INT,
    @StartDate DATE,
    @EndDate DATE = NULL,
    @DependentMemberNo NVARCHAR(50) = NULL,
    @DependentName NVARCHAR(150) = NULL,
    @DependentRelation NVARCHAR(50) = NULL
AS
BEGIN
    DECLARE @Fee DECIMAL(18,2)
    DECLARE @Desc NVARCHAR(255)
    DECLARE @DependentTag NVARCHAR(100) = ''

    -- Build dependent tag for description
    IF @DependentRelation IS NOT NULL AND @DependentRelation <> '' AND @DependentRelation <> 'Self'
    BEGIN
        SET @DependentTag = ' (' + @DependentRelation + ': ' + ISNULL(@DependentName, '') + ')'
    END

    -- Get Fee and Description
    SELECT @Fee = s.Fee, @Desc = sp.SportName + ' - ' + s.PackageName + ' Subscription Assigned' + @DependentTag
    FROM Subscriptions s INNER JOIN Sports sp ON s.SportID = sp.SportID
    WHERE s.SubscriptionID = @SubscriptionID;

    -- Insert Subscription with dependent info
    INSERT INTO MemberSubscriptions (MemberID, SubscriptionID, StartDate, EndDate, IsActive, DependentMemberNo, DependentName, DependentRelation)
    VALUES (@MemberID, @SubscriptionID, @StartDate, @EndDate, 1, 
            CASE WHEN @DependentRelation = 'Self' OR @DependentRelation IS NULL THEN NULL ELSE @DependentMemberNo END,
            CASE WHEN @DependentRelation = 'Self' OR @DependentRelation IS NULL THEN NULL ELSE @DependentName END,
            CASE WHEN @DependentRelation = 'Self' OR @DependentRelation IS NULL THEN NULL ELSE @DependentRelation END);

    DECLARE @NewSubID INT = SCOPE_IDENTITY();

    -- Post to Ledger (Debit) with dependent info
    INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID, DependentMemberNo, DependentName, DependentRelation)
    VALUES (@MemberID, GETDATE(), @Desc, @Fee, 0, 'Subscription', @NewSubID,
            CASE WHEN @DependentRelation = 'Self' OR @DependentRelation IS NULL THEN NULL ELSE @DependentMemberNo END,
            CASE WHEN @DependentRelation = 'Self' OR @DependentRelation IS NULL THEN NULL ELSE @DependentName END,
            CASE WHEN @DependentRelation = 'Self' OR @DependentRelation IS NULL THEN NULL ELSE @DependentRelation END);
END
GO

-- ============================================
-- 4. ALTER sp_GetMemberSubscriptions — Filter by Dependent
-- ============================================

ALTER PROCEDURE [dbo].[sp_GetMemberSubscriptions]
    @MemberID INT,
    @DependentMemberNo NVARCHAR(50) = NULL
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
        s.Fee,
        ms.DependentMemberNo,
        ms.DependentName,
        ms.DependentRelation
    FROM MemberSubscriptions ms
    INNER JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
    INNER JOIN Sports sp ON s.SportID = sp.SportID
    WHERE ms.MemberID = @MemberID
      AND (
            -- If DependentMemberNo is provided, filter by it
            (@DependentMemberNo IS NOT NULL AND ms.DependentMemberNo = @DependentMemberNo)
            OR
            -- If DependentMemberNo is NULL, show ALL (self = where DependentMemberNo IS NULL, plus all dependents)
            (@DependentMemberNo IS NULL)
          )
    ORDER BY ms.StartDate DESC;
END
GO

-- ============================================
-- 5. ALTER sp_GetMemberLedger — Filter by Dependent
-- ============================================

ALTER PROCEDURE [dbo].[sp_GetMemberLedger]
    @MemberID INT,
    @DependentMemberNo NVARCHAR(50) = NULL
AS
BEGIN
    SELECT 
        EntryID,
        TransactionDate,
        ISNULL(RefType, '') + CASE WHEN RefID IS NOT NULL THEN '-' + CAST(RefID AS NVARCHAR) ELSE '' END AS RefNo,
        Description,
        DebitAmount,
        CreditAmount,
        DependentMemberNo,
        DependentName,
        DependentRelation
    FROM LedgerEntries
    WHERE MemberID = @MemberID
      AND (
            -- If DependentMemberNo is provided, show only that dependent's entries
            (@DependentMemberNo IS NOT NULL AND DependentMemberNo = @DependentMemberNo)
            OR
            -- If DependentMemberNo is NULL (Self selected), show ALL entries
            (@DependentMemberNo IS NULL)
          )
    ORDER BY TransactionDate ASC, EntryID ASC;
END
GO

-- ============================================
-- 6. ALTER sp_AutoGenerateMemberBilling — Dependent Info in Description
-- ============================================

ALTER PROCEDURE [dbo].[sp_AutoGenerateMemberBilling]
    @MemberID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ActiveSubs TABLE (
        MemberSubID INT,
        SubscriptionID INT,
        Fee DECIMAL(18,2),
        SportName NVARCHAR(100),
        PackageName NVARCHAR(100),
        StartDate DATE,
        DependentMemberNo NVARCHAR(50),
        DependentName NVARCHAR(150),
        DependentRelation NVARCHAR(50)
    );

    INSERT INTO @ActiveSubs
    SELECT 
        ms.MemberSubID, 
        s.SubscriptionID, 
        s.Fee,
        sp.SportName,
        s.PackageName,
        ms.StartDate,
        ms.DependentMemberNo,
        ms.DependentName,
        ms.DependentRelation
    FROM MemberSubscriptions ms
    INNER JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
    INNER JOIN Sports sp ON s.SportID = sp.SportID
    WHERE ms.MemberID = @MemberID 
      AND ms.IsActive = 1 
      AND s.SubscriptionType IN ('Monthly', 'Continuous');

    DECLARE @MemberSubID INT, @Fee DECIMAL(18,2), @SportName NVARCHAR(100), @PackageName NVARCHAR(100), @StartDate DATE;
    DECLARE @DepMemberNo NVARCHAR(50), @DepName NVARCHAR(150), @DepRelation NVARCHAR(50);
    DECLARE @ExpectedMonths INT, @BilledMonths INT, @MonthsDiff INT;
    DECLARE @Desc NVARCHAR(255);
    DECLARE @DependentTag NVARCHAR(100);

    DECLARE subCursor CURSOR FOR 
    SELECT MemberSubID, Fee, SportName, PackageName, StartDate, DependentMemberNo, DependentName, DependentRelation FROM @ActiveSubs;

    OPEN subCursor;
    FETCH NEXT FROM subCursor INTO @MemberSubID, @Fee, @SportName, @PackageName, @StartDate, @DepMemberNo, @DepName, @DepRelation;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Build dependent tag
        SET @DependentTag = '';
        IF @DepRelation IS NOT NULL AND @DepRelation <> ''
        BEGIN
            SET @DependentTag = ' [' + @DepRelation + ': ' + ISNULL(@DepName, '') + ']';
        END

        -- Calculate expected billing cycles
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
            DECLARE @BillingDate DATETIME = DATEADD(month, @BilledMonths, @StartDate);
            
            SET @Desc = 'Auto Bill: ' + @SportName + ' - ' + @PackageName + ' (' + DATENAME(month, @BillingDate) + ' ' + CAST(YEAR(@BillingDate) AS NVARCHAR) + ')' + @DependentTag;

            INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID, DependentMemberNo, DependentName, DependentRelation)
            VALUES (@MemberID, @BillingDate, @Desc, @Fee, 0, 'Subscription', @MemberSubID, @DepMemberNo, @DepName, @DepRelation);

            SET @BilledMonths = @BilledMonths + 1;
        END

        FETCH NEXT FROM subCursor INTO @MemberSubID, @Fee, @SportName, @PackageName, @StartDate, @DepMemberNo, @DepName, @DepRelation;
    END

    CLOSE subCursor;
    DEALLOCATE subCursor;
END
GO
