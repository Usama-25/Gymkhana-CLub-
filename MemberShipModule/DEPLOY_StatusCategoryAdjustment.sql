-- ============================================================
-- Membership Status & Category Adjustment - Database Objects
-- Run this script on the MemberShip database
-- ============================================================

-- ============================================================
-- 1. Create MemberProfileChangeLog Table (Idempotent)
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MemberProfileChangeLog')
BEGIN
    CREATE TABLE [dbo].[MemberProfileChangeLog] (
        [LogID]              INT IDENTITY(1,1) PRIMARY KEY,
        [MemberProfileID]    INT NOT NULL,
        [MemberNo]           NVARCHAR(50) NULL,
        [ChangeType]         NVARCHAR(50) NOT NULL,      -- STATUS_CHANGE, CATEGORY_CHANGE, MEMBER_TYPE_CHANGE, RESIDENTIAL_STATUS_CHANGE, MEMBERSHIP_STATUS_CHANGE
        [FieldName]          NVARCHAR(100) NULL,          -- The specific field that was changed
        [OldValue]           NVARCHAR(500) NULL,          -- Previous value
        [NewValue]           NVARCHAR(500) NULL,          -- New value
        [Reason]             NVARCHAR(1000) NULL,         -- Reason for the change
        [RequestNo]          INT NULL,                    -- Request tracking number
        [RequestDate]        DATETIME NULL,               -- Date of the request
        [ModifiedBy]         NVARCHAR(200) NULL,          -- User who made the change
        [ModifiedByUserId]   NVARCHAR(50) NULL,           -- User ID of who made the change
        [ModifiedOn]         DATETIME NOT NULL DEFAULT GETDATE(),  -- When the change was made
        [IsMember]           BIT NULL DEFAULT 1           -- 1 = Member, 0 = Supplementary
    );
    
    PRINT 'Created table: MemberProfileChangeLog';
END
ELSE
BEGIN
    PRINT 'Table MemberProfileChangeLog already exists.';
END
GO

-- Add index for faster lookups
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_MemberProfileChangeLog_MemberProfileID')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_MemberProfileChangeLog_MemberProfileID] 
    ON [dbo].[MemberProfileChangeLog] ([MemberProfileID])
    INCLUDE ([ChangeType], [ModifiedOn]);
    
    PRINT 'Created index: IX_MemberProfileChangeLog_MemberProfileID';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_MemberProfileChangeLog_MemberNo')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_MemberProfileChangeLog_MemberNo] 
    ON [dbo].[MemberProfileChangeLog] ([MemberNo])
    INCLUDE ([ChangeType], [ModifiedOn]);
    
    PRINT 'Created index: IX_MemberProfileChangeLog_MemberNo';
END
GO

-- ============================================================
-- 2. SP: Get Member for Status Adjustment
-- ============================================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_GetMemberForStatusAdjustment')
    DROP PROCEDURE usp_GetMemberForStatusAdjustment;
GO

CREATE PROCEDURE [dbo].[usp_GetMemberForStatusAdjustment]
    @MemberNo NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP 1
        p.MemberID AS MemberProfileID,
        p.M_ID,
        p.MemberName,
        p.MemberNo,
        ISNULL(p.MemberCategory, '') AS MemberCategory,
        ISNULL(p.AccountStatus, '') AS AccountStatus,
        ISNULL(p.ResidentialStatus, '') AS ResidentialStatus,
        ISNULL(p.MemberType, '') AS MemberType
    FROM MemberProfile p
    WHERE p.MemberNo = @MemberNo
    ORDER BY p.MemberID DESC;
END
GO

PRINT 'Created SP: usp_GetMemberForStatusAdjustment';
GO

-- ============================================================
-- 3. SP: Get Member for Category Adjustment
-- ============================================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_GetMemberForCategoryAdjustment')
    DROP PROCEDURE usp_GetMemberForCategoryAdjustment;
GO

CREATE PROCEDURE [dbo].[usp_GetMemberForCategoryAdjustment]
    @MemberNo NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InNo NVARCHAR(50) = LTRIM(RTRIM(@MemberNo));
    
    -- Resolve Member internal ID
    DECLARE @MID INT = (SELECT TOP 1 MemberID FROM Member WITH (NOLOCK) WHERE LTRIM(RTRIM(MemberNo)) = @InNo);
    
    IF @MID IS NULL AND CHARINDEX('-', @InNo) > 0
        SET @MID = (SELECT TOP 1 MemberID FROM Member WITH (NOLOCK) WHERE LTRIM(RTRIM(MemberNo)) = LEFT(@InNo, CHARINDEX('-', @InNo)-1));
        
    IF @MID IS NULL
        SET @MID = (SELECT TOP 1 M_ID FROM MemberProfile WITH (NOLOCK) WHERE LTRIM(RTRIM(MemberNo)) = @InNo);

    -- Return results with aggressive fallbacks to capture data from various possible columns
    SELECT TOP 1
        ISNULL(p.MemberID, 0) AS MemberProfileID,
        m.MemberID AS M_ID,
        COALESCE(NULLIF(p.MemberName, ''), NULLIF(m.ApplicantName, ''), '') AS MemberName,
        COALESCE(NULLIF(p.MemberNo, ''), NULLIF(m.MemberNo, ''), @InNo) AS MemberNo,
        -- Category: try MemberCategory first, then MemberType as fallback
        COALESCE(NULLIF(p.MemberCategory, ''), NULLIF(p.MemberType, ''), NULLIF(m.MemberType, ''), '') AS MemberCategory,
        -- Member Type: try MemberType from both tables
        COALESCE(NULLIF(m.MemberType, ''), NULLIF(p.MemberType, ''), NULLIF(p.MemberCategory, ''), '') AS MemberType,
        ISNULL(p.AccountStatus, ISNULL(m.Status, 'Active')) AS AccountStatus,
        '' AS TypeCode,
        '' AS TypeSeq,
        ISNULL(m.MFee, 0) AS MFee,
        CAST(0 AS DECIMAL(18,2)) AS MFee2
    FROM Member m WITH (NOLOCK)
    LEFT JOIN MemberProfile p WITH (NOLOCK) ON m.MemberID = p.M_ID
    WHERE m.MemberID = @MID
    ORDER BY p.MemberID DESC;
END
GO

PRINT 'Updated SP: usp_GetMemberForCategoryAdjustment with data fallbacks';
GO

PRINT 'Created SP: usp_GetMemberForCategoryAdjustment';
GO

-- ============================================================
-- 4. SP: Update Member Status (in MemberProfile table)
-- ============================================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_UpdateMemberStatus')
    DROP PROCEDURE usp_UpdateMemberStatus;
GO

CREATE PROCEDURE [dbo].[usp_UpdateMemberStatus]
    @MemberProfileID INT,
    @NewResidentialStatus NVARCHAR(100) = NULL,
    @NewAccountStatus NVARCHAR(100),
    @NewMemberNo NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE MemberProfile
    SET 
        AccountStatus = @NewAccountStatus,
        ResidentialStatus = CASE 
            WHEN @NewResidentialStatus IS NOT NULL THEN @NewResidentialStatus 
            ELSE ResidentialStatus 
        END,
        MemberNo = CASE 
            WHEN @NewMemberNo IS NOT NULL AND @NewMemberNo != '' THEN @NewMemberNo 
            ELSE MemberNo 
        END
    WHERE MemberID = @MemberProfileID;
END
GO

PRINT 'Created SP: usp_UpdateMemberStatus';
GO

-- ============================================================
-- 5. SP: Update Member Category (in MemberProfile table)
-- ============================================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_UpdateMemberCategory')
    DROP PROCEDURE usp_UpdateMemberCategory;
GO

CREATE PROCEDURE [dbo].[usp_UpdateMemberCategory]
    @MemberProfileID INT,
    @NewMemberCategory NVARCHAR(200) = NULL,
    @NewMemberType NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Update MemberProfile table
    UPDATE MemberProfile
    SET 
        MemberCategory = CASE 
            WHEN @NewMemberCategory IS NOT NULL THEN @NewMemberCategory 
            ELSE MemberCategory 
        END,
        MemberType = CASE 
            WHEN @NewMemberType IS NOT NULL THEN @NewMemberType 
            ELSE MemberType 
        END
    WHERE MemberID = @MemberProfileID;

    -- Synchronize with main Member table if MemberType changed
    IF @NewMemberType IS NOT NULL AND @NewMemberType != ''
    BEGIN
        UPDATE m
        SET m.MemberType = @NewMemberType
        FROM Member m
        JOIN MemberProfile p ON m.MemberID = p.M_ID
        WHERE p.MemberID = @MemberProfileID;
    END
END
GO

PRINT 'Created SP: usp_UpdateMemberCategory';
GO

-- ============================================================
-- 6. SP: Insert log entry into MemberProfileChangeLog
-- ============================================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_InsertMemberProfileChangeLog')
    DROP PROCEDURE usp_InsertMemberProfileChangeLog;
GO

CREATE PROCEDURE [dbo].[usp_InsertMemberProfileChangeLog]
    @MemberProfileID INT,
    @MemberNo NVARCHAR(50),
    @ChangeType NVARCHAR(50),
    @FieldName NVARCHAR(100),
    @OldValue NVARCHAR(500),
    @NewValue NVARCHAR(500),
    @Reason NVARCHAR(1000) = NULL,
    @RequestNo INT = NULL,
    @RequestDate DATETIME = NULL,
    @ModifiedBy NVARCHAR(200) = NULL,
    @ModifiedByUserId NVARCHAR(50) = NULL,
    @IsMember BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO MemberProfileChangeLog (
        MemberProfileID, MemberNo, ChangeType, FieldName,
        OldValue, NewValue, Reason, RequestNo, RequestDate,
        ModifiedBy, ModifiedByUserId, ModifiedOn, IsMember
    )
    VALUES (
        @MemberProfileID, @MemberNo, @ChangeType, @FieldName,
        @OldValue, @NewValue, @Reason, @RequestNo, @RequestDate,
        @ModifiedBy, @ModifiedByUserId, GETDATE(), @IsMember
    );
    
    SELECT SCOPE_IDENTITY() AS LogID;
END
GO

PRINT 'Created SP: usp_InsertMemberProfileChangeLog';
GO

-- ============================================================
-- 7. SP: Get Change Log for a Member
-- ============================================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_GetMemberProfileChangeLog')
    DROP PROCEDURE usp_GetMemberProfileChangeLog;
GO

CREATE PROCEDURE [dbo].[usp_GetMemberProfileChangeLog]
    @MemberProfileID INT = NULL,
    @MemberNo NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        LogID,
        MemberProfileID,
        MemberNo,
        ChangeType,
        FieldName,
        OldValue,
        NewValue,
        Reason,
        RequestNo,
        RequestDate,
        ModifiedBy,
        ModifiedByUserId,
        ModifiedOn,
        IsMember
    FROM MemberProfileChangeLog
    WHERE 
        (@MemberProfileID IS NULL OR MemberProfileID = @MemberProfileID)
        AND (@MemberNo IS NULL OR MemberNo = @MemberNo)
    ORDER BY ModifiedOn DESC;
END
GO

PRINT 'Created SP: usp_GetMemberProfileChangeLog';
GO

-- ============================================================
-- 8. Ensure AuditLogs table exists (for AuditLogger class)
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AuditLogs')
BEGIN
    CREATE TABLE [dbo].[AuditLogs] (
        [LogID]     INT IDENTITY(1,1) PRIMARY KEY,
        [TableName] NVARCHAR(100) NOT NULL,
        [RecordID]  NVARCHAR(100) NOT NULL,
        [Action]    NVARCHAR(50) NOT NULL,
        [UserId]    NVARCHAR(50) NULL,
        [UserName]  NVARCHAR(200) NULL,
        [OldValue]  NVARCHAR(MAX) NULL,
        [NewValue]  NVARCHAR(MAX) NULL,
        [Details]   NVARCHAR(MAX) NULL,
        [Timestamp] DATETIME NOT NULL DEFAULT GETDATE()
    );
    
    PRINT 'Created table: AuditLogs';
END
GO

-- Ensure sp_InsertAuditLog exists
IF NOT EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_InsertAuditLog')
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_InsertAuditLog]
        @TableName NVARCHAR(100),
        @RecordID NVARCHAR(100),
        @Action NVARCHAR(50),
        @UserId NVARCHAR(50) = NULL,
        @UserName NVARCHAR(200) = NULL,
        @OldValue NVARCHAR(MAX) = NULL,
        @NewValue NVARCHAR(MAX) = NULL,
        @Details NVARCHAR(MAX) = NULL
    AS
    BEGIN
        SET NOCOUNT ON;
        
        INSERT INTO AuditLogs (TableName, RecordID, Action, UserId, UserName, OldValue, NewValue, Details, [Timestamp])
        VALUES (@TableName, @RecordID, @Action, @UserId, @UserName, @OldValue, @NewValue, @Details, GETDATE());
        
        SELECT SCOPE_IDENTITY() AS LogID;
    END
    ');
    
    PRINT 'Created SP: sp_InsertAuditLog';
END
GO

PRINT '';
PRINT '============================================================';
PRINT 'All database objects created successfully!';
PRINT '============================================================';
PRINT 'Tables:  MemberProfileChangeLog, AuditLogs';
PRINT 'SPs:     usp_GetMemberForStatusAdjustment';
PRINT '         usp_GetMemberForCategoryAdjustment';
PRINT '         usp_UpdateMemberStatus';
PRINT '         usp_UpdateMemberCategory';
PRINT '         usp_InsertMemberProfileChangeLog';
PRINT '         usp_GetMemberProfileChangeLog';
PRINT '         sp_InsertAuditLog';
PRINT '============================================================';
GO
