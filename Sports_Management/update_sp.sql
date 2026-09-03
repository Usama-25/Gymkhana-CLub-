USE [SportsModuleDB]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_ValidateMemberAccess]
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
    DECLARE @IsCardActive INT = 1;
    
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
            @MemberStatus = Status,
            @IsCardActive = ISNULL(IsCardActive, 1)
        FROM [MemberShip].[dbo].[MemberProfile]
        WHERE RFID = @RFID;

        IF @MemberID IS NULL
        BEGIN
            SELECT TOP 1
                @MemberID = c.MemberID,
                @FoundMemberNo = c.MembershipNo,
                @FullName = c.ChildName,
                @MemberStatus = p.Status,
                @IsCardActive = ISNULL(p.IsCardActive, 1)
            FROM [MemberShip].[dbo].[MemberChildren] c
            INNER JOIN [MemberShip].[dbo].[MemberProfile] p ON c.MemberID = p.MemberID
            WHERE c.RFID = @RFID AND c.RecordStatus = 'Active';
        END
    END
    ELSE IF @MemberNo IS NOT NULL AND @MemberNo <> ''
    BEGIN
        SELECT 
            @MemberID = MemberID,
            @FoundMemberNo = MemberNo,
            @FullName = MemberName,
            @MemberStatus = Status,
            @IsCardActive = ISNULL(IsCardActive, 1)
        FROM [MemberShip].[dbo].[MemberProfile]
        WHERE MemberNo = @MemberNo;

        IF @MemberID IS NULL
        BEGIN
            SELECT TOP 1
                @MemberID = s.MemberID,
                @FoundMemberNo = s.MembershipNo,
                @FullName = s.SpouseName,
                @MemberStatus = p.Status,
                @IsCardActive = ISNULL(p.IsCardActive, 1)
            FROM [MemberShip].[dbo].[MemberSpouses] s
            INNER JOIN [MemberShip].[dbo].[MemberProfile] p ON s.MemberID = p.MemberID
            WHERE s.MembershipNo = @MemberNo AND s.RecordStatus = 'Active';
        END

        IF @MemberID IS NULL
        BEGIN
            SELECT TOP 1
                @MemberID = c.MemberID,
                @FoundMemberNo = c.MembershipNo,
                @FullName = c.ChildName,
                @MemberStatus = p.Status,
                @IsCardActive = ISNULL(p.IsCardActive, 1)
            FROM [MemberShip].[dbo].[MemberChildren] c
            INNER JOIN [MemberShip].[dbo].[MemberProfile] p ON c.MemberID = p.MemberID
            WHERE c.MembershipNo = @MemberNo AND c.RecordStatus = 'Active';
        END
    END

    IF @MemberID IS NULL
    BEGIN
        SET @AccessResult = 'Denied';
        SET @DenialReason = 'Member not found.';
        SET @FoundMemberNo = ISNULL(@MemberNo, 'Unknown');
    END
    ELSE
    BEGIN
        IF @IsCardActive = 0
        BEGIN
            SET @AccessResult = 'Denied';
            SET @DenialReason = 'Access denied. Please contact relevant department.';
        END
        ELSE
        BEGIN
            IF @MemberStatus <> 'Active'
            BEGIN
                SET @AccessResult = 'Denied';
                SET @DenialReason = 'Membership is not active (' + ISNULL(@MemberStatus, 'Unknown') + ').';
            END
            ELSE
            BEGIN
                SELECT @NetBalance = ISNULL(SUM(DebitAmount) - SUM(CreditAmount), 0)
                FROM LedgerEntries
                WHERE MemberID = @MemberID;

                IF @NetBalance > 0
                BEGIN
                    SET @AccessResult = 'Denied';
                    SET @DenialReason = 'Outstanding Dues: PKR ' + CAST(CAST(@NetBalance AS INT) AS NVARCHAR) + '. Please clear payments.';
                END
                ELSE
                BEGIN
                    DECLARE @HasAccess BIT = 0;

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
                END
            END
        END
    END

    INSERT INTO AccessLogs (MemberID, MemberNo, SportID, AccessResult, DenialReason)
    VALUES (@MemberID, @FoundMemberNo, @SportID, @AccessResult, @DenialReason);

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
