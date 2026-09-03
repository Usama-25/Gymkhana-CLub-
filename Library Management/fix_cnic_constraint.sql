-- =============================================================================
--  FIX: CNIC UNIQUE CONSTRAINT — One-time migration
--  Run this against the LIVE GymkhanaLibraryDB to fix the duplicate CNIC issue
-- =============================================================================
USE GymkhanaLibraryDB;
GO

-- Step 1: Nullify all placeholder/empty CNIC values in existing data
UPDATE dbo.Members
SET    CNIC = NULL
WHERE  CNIC IS NOT NULL
  AND  (
        LTRIM(RTRIM(CNIC)) = ''
        OR CNIC = '00000-0000000-0'
        OR CNIC = '000000000000000'
        OR REPLACE(REPLACE(CNIC, '-', ''), '0', '') = ''
       );

PRINT 'Cleaned ' + CAST(@@ROWCOUNT AS VARCHAR) + ' placeholder CNIC values.';

-- Step 2: Drop the old UNIQUE constraint (name may vary — find it dynamically)
DECLARE @ConstraintName NVARCHAR(200);
SELECT @ConstraintName = kc.name
FROM   sys.key_constraints kc
JOIN   sys.index_columns ic ON kc.unique_index_id = ic.index_id AND kc.parent_object_id = ic.object_id
JOIN   sys.columns c        ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE  kc.parent_object_id = OBJECT_ID('dbo.Members')
  AND  c.name = 'CNIC'
  AND  kc.type = 'UQ';

IF @ConstraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE dbo.Members DROP CONSTRAINT [' + @ConstraintName + ']');
    PRINT 'Dropped UNIQUE constraint: ' + @ConstraintName;
END

-- Also drop any existing index on CNIC (filtered or not)
DECLARE @IndexName NVARCHAR(200);
SELECT @IndexName = i.name
FROM   sys.indexes i
JOIN   sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN   sys.columns c        ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE  i.object_id = OBJECT_ID('dbo.Members')
  AND  c.name = 'CNIC'
  AND  i.is_primary_key = 0
  AND  i.type <> 0;

IF @IndexName IS NOT NULL
BEGIN
    EXEC('DROP INDEX [' + @IndexName + '] ON dbo.Members');
    PRINT 'Dropped index: ' + @IndexName;
END

-- Step 3: Create filtered UNIQUE index — allows multiple NULLs, enforces uniqueness on real CNICs only
CREATE UNIQUE NONCLUSTERED INDEX UX_Members_CNIC 
    ON dbo.Members (CNIC) 
    WHERE CNIC IS NOT NULL;

PRINT 'Created filtered UNIQUE index UX_Members_CNIC.';

-- Step 4: Update the stored procedure with CNIC sanitization
EXEC('
CREATE OR ALTER PROCEDURE dbo.sp_EnsureMemberExists
    @ProfileMemberID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Members WHERE MemberID = @ProfileMemberID)
    BEGIN
        DECLARE @MemberNo VARCHAR(14), @MemberName NVARCHAR(100), @CNIC CHAR(15), @Phone VARCHAR(15), @Email VARCHAR(80), @IsActive BIT;
        
        SELECT 
            @MemberNo   = MemberNo,
            @MemberName = MemberName,
            @CNIC       = NIC,
            @Phone      = Mobile,
            @Email      = ResidentialEmail,
            @IsActive   = IsActive
        FROM MemberShip.dbo.MemberProfile
        WHERE MemberID = @ProfileMemberID;

        IF @MemberNo IS NOT NULL AND @IsActive = 1
        BEGIN
            -- Sanitize CNIC: convert empty/placeholder values to NULL
            SET @CNIC = LTRIM(RTRIM(@CNIC));
            IF @CNIC IS NULL 
               OR @CNIC = '''' 
               OR @CNIC = ''00000-0000000-0''
               OR @CNIC = ''000000000000000''
               OR REPLACE(REPLACE(@CNIC, ''-'', ''''), ''0'', '''') = ''''
            BEGIN
                SET @CNIC = NULL;
            END

            SET IDENTITY_INSERT dbo.Members ON;
            
            INSERT INTO dbo.Members (MemberID, MembershipNo, FullName, CNIC, Phone, Email, MTypeID, IsActive)
            VALUES (@ProfileMemberID, @MemberNo, @MemberName, @CNIC, @Phone, @Email, 1, 1);
            
            SET IDENTITY_INSERT dbo.Members OFF;
        END
    END
END;
');

PRINT '=== CNIC constraint fix applied successfully ===';
GO
