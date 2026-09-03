-- =============================================================================
--  LAHORE GYMKHANA LIBRARY — Add Staff Tracking Columns (EmpID from Session)
--  Migration 36: Adds ChargedByID to Fines & FacilityBookings,
--                IssuedByID & CollectedByID to Vouchers,
--                Updates sp_GenerateVoucher & sp_PayVoucher to accept staff IDs.
-- =============================================================================
USE GymkhanaLibraryDB;
GO

-- ────────────────────────────────────────────────────────────
-- 1. Add ChargedByID to Fines table (who logged the fine/charge)
-- ────────────────────────────────────────────────────────────
IF COL_LENGTH('dbo.Fines', 'ChargedByID') IS NULL
BEGIN
    ALTER TABLE dbo.Fines ADD ChargedByID SMALLINT NULL;
    PRINT 'Added ChargedByID column to Fines table.';
END
ELSE
    PRINT 'ChargedByID already exists in Fines — skipped.';
GO

-- ────────────────────────────────────────────────────────────
-- 2. Add ChargedByID to FacilityBookings table (who logged the booking)
-- ────────────────────────────────────────────────────────────
IF COL_LENGTH('dbo.FacilityBookings', 'ChargedByID') IS NULL
BEGIN
    ALTER TABLE dbo.FacilityBookings ADD ChargedByID SMALLINT NULL;
    PRINT 'Added ChargedByID column to FacilityBookings table.';
END
ELSE
    PRINT 'ChargedByID already exists in FacilityBookings — skipped.';
GO

-- ────────────────────────────────────────────────────────────
-- 3. Add IssuedByID to Vouchers table (who generated the voucher)
-- ────────────────────────────────────────────────────────────
IF COL_LENGTH('dbo.Vouchers', 'IssuedByID') IS NULL
BEGIN
    ALTER TABLE dbo.Vouchers ADD IssuedByID SMALLINT NULL;
    PRINT 'Added IssuedByID column to Vouchers table.';
END
ELSE
    PRINT 'IssuedByID already exists in Vouchers — skipped.';
GO

-- ────────────────────────────────────────────────────────────
-- 4. Add CollectedByID to Vouchers table (who collected the cash payment)
-- ────────────────────────────────────────────────────────────
IF COL_LENGTH('dbo.Vouchers', 'CollectedByID') IS NULL
BEGIN
    ALTER TABLE dbo.Vouchers ADD CollectedByID SMALLINT NULL;
    PRINT 'Added CollectedByID column to Vouchers table.';
END
ELSE
    PRINT 'CollectedByID already exists in Vouchers — skipped.';
GO

-- ────────────────────────────────────────────────────────────
-- 5. Update sp_GenerateVoucher to accept and store IssuedByID
-- ────────────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE dbo.sp_GenerateVoucher
    @MemberID    INT,
    @FineIDs     VARCHAR(MAX)  = NULL,  -- comma-separated Fine IDs
    @BookingIDs  VARCHAR(MAX)  = NULL,  -- comma-separated Booking IDs
    @PaymentMode VARCHAR(20),
    @Remarks     NVARCHAR(200) = NULL,
    @IssuedByID  SMALLINT      = NULL,  -- session EmpID of staff generating voucher
    @VoucherNo   VARCHAR(30)   OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
            -- Generate unique Voucher number: VCH-YYYYMMDD-XXXX
            DECLARE @TodayStr VARCHAR(8) = CONVERT(VARCHAR(8), GETDATE(), 112);
            DECLARE @NextSeq INT = 1;
            
            SELECT @NextSeq = ISNULL(MAX(CAST(SUBSTRING(VoucherNo, 14, 4) AS INT)), 0) + 1
            FROM Vouchers
            WHERE VoucherNo LIKE 'VCH-' + @TodayStr + '-%';
            
            SET @VoucherNo = 'VCH-' + @TodayStr + '-' + RIGHT('0000' + CAST(@NextSeq AS VARCHAR(4)), 4);
            
            -- Calculate total amount
            DECLARE @TotalAmount DECIMAL(8,2) = 0.00;
            
            -- Calculate Fines Amount
            DECLARE @FinesTotal DECIMAL(8,2) = 0.00;
            IF @FineIDs IS NOT NULL AND LEN(@FineIDs) > 0
            BEGIN
                SELECT @FinesTotal = ISNULL(SUM(FineAmount), 0.00)
                FROM Fines
                WHERE FineID IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(@FineIDs, ','))
                  AND MemberID = @MemberID AND IsPaid = 0;
            END
            
            -- Calculate Bookings Amount
            DECLARE @BookingsTotal DECIMAL(8,2) = 0.00;
            IF @BookingIDs IS NOT NULL AND LEN(@BookingIDs) > 0
            BEGIN
                SELECT @BookingsTotal = ISNULL(SUM(TotalCharges), 0.00)
                FROM FacilityBookings
                WHERE BookingID IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(@BookingIDs, ','))
                  AND MemberID = @MemberID AND IsPaid = 0;
            END
            
            SET @TotalAmount = @FinesTotal + @BookingsTotal;
            
            -- Insert Voucher (now includes IssuedByID from session)
            DECLARE @IsPaid BIT = CASE WHEN @PaymentMode = 'Account Debit' THEN 1 ELSE 0 END;
            DECLARE @PaidAt DATETIME2(0) = CASE WHEN @PaymentMode = 'Account Debit' THEN SYSDATETIME() ELSE NULL END;
            DECLARE @CollectedBy SMALLINT = CASE WHEN @PaymentMode = 'Account Debit' THEN @IssuedByID ELSE NULL END;
            
            INSERT INTO Vouchers (VoucherNo, MemberID, Amount, PaymentMode, IsPaid, PaidAt, Remarks, IssuedByID, CollectedByID)
            VALUES (@VoucherNo, @MemberID, @TotalAmount, @PaymentMode, @IsPaid, @PaidAt, @Remarks, @IssuedByID, @CollectedBy);
            
            DECLARE @VoucherID INT = SCOPE_IDENTITY();
            
            -- Link Fines
            IF @FineIDs IS NOT NULL AND LEN(@FineIDs) > 0
            BEGIN
                UPDATE Fines
                SET VoucherID = @VoucherID,
                    IsPaid    = @IsPaid,
                    PaidAt    = @PaidAt,
                    CollectedByID = CASE WHEN @IsPaid = 1 THEN @IssuedByID ELSE CollectedByID END
                WHERE FineID IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(@FineIDs, ','))
                  AND MemberID = @MemberID;
            END
            
            -- Link Bookings
            IF @BookingIDs IS NOT NULL AND LEN(@BookingIDs) > 0
            BEGIN
                UPDATE FacilityBookings
                SET VoucherID = @VoucherID,
                    IsPaid    = @IsPaid,
                    PaidAt    = @PaidAt
                WHERE BookingID IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(@BookingIDs, ','))
                  AND MemberID = @MemberID;
            END
            
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

-- ────────────────────────────────────────────────────────────
-- 6. Update sp_PayVoucher to accept and store CollectedByID
-- ────────────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE dbo.sp_PayVoucher
    @VoucherNo      VARCHAR(30),
    @CollectedByID  SMALLINT     = NULL,  -- session EmpID of cashier collecting payment
    @Msg            VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VoucherID INT, @IsPaid BIT;
    
    SELECT @VoucherID = VoucherID, @IsPaid = IsPaid
    FROM Vouchers
    WHERE VoucherNo = @VoucherNo;
    
    IF @VoucherID IS NULL
    BEGIN
        SET @Msg = 'ERR:VOUCHER_NOT_FOUND';
        RETURN;
    END
    
    IF @IsPaid = 1
    BEGIN
        SET @Msg = 'ERR:VOUCHER_ALREADY_PAID';
        RETURN;
    END
    
    BEGIN TRY
        BEGIN TRAN;
            -- Update Voucher (now stamps CollectedByID from session)
            UPDATE Vouchers
            SET IsPaid         = 1,
                PaidAt         = SYSDATETIME(),
                CollectedByID  = @CollectedByID
            WHERE VoucherID = @VoucherID;
            
            -- Update linked Fines
            UPDATE Fines
            SET IsPaid        = 1,
                PaidAt        = SYSDATETIME(),
                CollectedByID = @CollectedByID
            WHERE VoucherID = @VoucherID;
            
            -- Update linked Facility Bookings
            UPDATE FacilityBookings
            SET IsPaid = 1,
                PaidAt = SYSDATETIME()
            WHERE VoucherID = @VoucherID;
            
            SET @Msg = 'OK';
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

PRINT '=== Migration 36: Staff ID tracking columns and SP updates applied successfully ===';
GO
