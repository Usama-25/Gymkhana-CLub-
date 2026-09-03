ALTER PROCEDURE [sp_ValidateMemberAccess]
    @MemberNo NVARCHAR(50) = NULL,
    @RFID NVARCHAR(100) = NULL,
    @SportID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MemberID INT = NULL;
    DECLARE @FullName NVARCHAR(150) = '';
    DECLARE @MemberStatus NVARCHAR(50) = '';
    DECLARE @NetBalance DECIMAL(18,2) = 0;
    
    DECLARE @AccessResult NVARCHAR(20) = 'Granted';
    DECLARE @DenialReason NVARCHAR(255) = '';
    DECLARE @FoundMemberNo NVARCHAR(50) = '';

    -- 1. Identify User by RFID or MemberNo
    IF @RFID IS NOT NULL AND @RFID <> ''
    BEGIN
        SELECT 
            @MemberID = MemberID,
            @FoundMemberNo = MemberNo,
            @FullName = MemberName,
            @MemberStatus = Status
        FROM [MemberShip].[dbo].[MemberProfile]
        WHERE RFID = @RFID;
    END
    ELSE IF @MemberNo IS NOT NULL AND @MemberNo <> ''
    BEGIN
        SELECT 
            @MemberID = MemberID,
            @FoundMemberNo = MemberNo,
            @FullName = MemberName,
            @MemberStatus = Status
        FROM [MemberShip].[dbo].[MemberProfile]
        WHERE MemberNo = @MemberNo;
    END

    IF @MemberID IS NULL
    BEGIN
        SET @AccessResult = 'Denied';
        SET @DenialReason = 'Member not found.';
        SET @FoundMemberNo = ISNULL(@MemberNo, 'Unknown');
    END
    ELSE
    BEGIN
        -- 2. Check Membership Status
        IF @MemberStatus <> 'Active'
        BEGIN
            SET @AccessResult = 'Denied';
            SET @DenialReason = 'Membership is not active (' + ISNULL(@MemberStatus, 'Unknown') + ').';
        END
        ELSE
        BEGIN
            -- 3. Check Subscription Access First
            DECLARE @HasAccess BIT = 0;

            -- Check regular subscriptions
            IF EXISTS (
                SELECT 1 
                FROM MemberSubscriptions ms
                INNER JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
                WHERE ms.MemberID = @MemberID 
                  AND s.SportID = @SportID
                  AND ms.IsActive = 1
                  AND (ms.EndDate IS NULL OR ms.EndDate >= CAST(GETDATE() AS DATE))
            )
            BEGIN
                SET @HasAccess = 1;
            END

            -- Check 1-Day POS passes for today
            IF @HasAccess = 0
            BEGIN
                IF EXISTS (
                    SELECT 1
                    FROM POSTransactions pos
                    INNER JOIN Subscriptions s ON pos.SubscriptionID = s.SubscriptionID
                    WHERE pos.MemberID = @MemberID
                      AND s.SportID = @SportID
                      AND CAST(pos.TransactionDate AS DATE) = CAST(GETDATE() AS DATE)
                )
                BEGIN
                    SET @HasAccess = 1;
                END
            END

            IF @HasAccess = 0
            BEGIN
                SET @AccessResult = 'Denied';
                SET @DenialReason = 'No active subscription or daily pass for this facility.';
            END
            ELSE
            BEGIN
                -- 4. Check Payment Clearance (Net Balance)
                SELECT @NetBalance = ISNULL(SUM(DebitAmount) - SUM(CreditAmount), 0)
                FROM LedgerEntries
                WHERE MemberID = @MemberID;

                IF @NetBalance > 0
                BEGIN
                    SET @AccessResult = 'Denied';
                    SET @DenialReason = 'Outstanding Dues: PKR ' + CAST(CAST(@NetBalance AS INT) AS NVARCHAR) + '. Please clear payments.';
                END
            END
        END
    END

    -- 5. Log the attempt
    INSERT INTO AccessLogs (MemberID, MemberNo, SportID, AccessResult, DenialReason)
    VALUES (@MemberID, @FoundMemberNo, @SportID, @AccessResult, @DenialReason);

    -- 6. Return Result
    SELECT 
        ISNULL(@MemberID, 0) AS MemberID,
        @FoundMemberNo AS MemberNo,
        ISNULL(@FullName, 'N/A') AS FullName,
        ISNULL(@MemberStatus, 'N/A') AS MemberStatus,
        @NetBalance AS NetBalance,
        @AccessResult AS AccessResult,
        @DenialReason AS DenialReason;
END
GO
