USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Alter Fines Table to support general fine charges
-- Make LoanID nullable
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fines') AND name = 'LoanID' AND is_nullable = 0)
BEGIN
    ALTER TABLE dbo.Fines ALTER COLUMN LoanID INT NULL;
    PRINT 'Altered Fines table: LoanID is now NULLABLE.';
END
GO

-- 2. Create Vouchers Table if it does not exist
IF OBJECT_ID('dbo.Vouchers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Vouchers (
        VoucherID       INT             IDENTITY(1,1) PRIMARY KEY,
        VoucherNo       VARCHAR(30)     NOT NULL UNIQUE,
        MemberID        INT             NOT NULL REFERENCES dbo.Members(MemberID),
        IssueDate       DATETIME2(0)    NOT NULL DEFAULT SYSDATETIME(),
        Amount          DECIMAL(8,2)    NOT NULL CHECK (Amount >= 0),
        PaymentMode     VARCHAR(20)     NOT NULL CHECK (PaymentMode IN ('Cash', 'Account Debit')),
        IsPaid          BIT             NOT NULL DEFAULT 0,
        PaidAt          DATETIME2(0)    NULL,
        Remarks         NVARCHAR(200)   NULL,
        CreatedAt       DATETIME2(0)    NOT NULL DEFAULT SYSDATETIME()
    );
    CREATE INDEX IX_Vouchers_MemberID ON dbo.Vouchers(MemberID);
    PRINT 'Created Vouchers table.';
END
GO

-- 3. Add VoucherID to Fines and FacilityBookings tables
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Fines') AND name = 'VoucherID')
BEGIN
    ALTER TABLE dbo.Fines ADD VoucherID INT NULL REFERENCES dbo.Vouchers(VoucherID);
    PRINT 'Added VoucherID column to Fines table.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.FacilityBookings') AND name = 'VoucherID')
BEGIN
    ALTER TABLE dbo.FacilityBookings ADD VoucherID INT NULL REFERENCES dbo.Vouchers(VoucherID);
    PRINT 'Added VoucherID column to FacilityBookings table.';
END
GO

-- 4. Seed new Fine Reason for Book Issuance Fee
IF NOT EXISTS (SELECT * FROM dbo.FineReasons WHERE ReasonID = 5)
BEGIN
    INSERT INTO dbo.FineReasons (ReasonID, ReasonName) VALUES (5, 'Book Issuance Fee');
    PRINT 'Seeded Book Issuance Fee to FineReasons.';
END
GO

-- 5. Stored Procedure: sp_GenerateVoucher
CREATE OR ALTER PROCEDURE dbo.sp_GenerateVoucher
    @MemberID    INT,
    @FineIDs     VARCHAR(MAX) = NULL, -- comma-separated Fine IDs
    @BookingIDs  VARCHAR(MAX) = NULL, -- comma-separated Booking IDs
    @PaymentMode VARCHAR(20),
    @Remarks     NVARCHAR(200) = NULL,
    @VoucherNo   VARCHAR(30) OUTPUT
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
            
            -- Insert Voucher
            DECLARE @IsPaid BIT = CASE WHEN @PaymentMode = 'Account Debit' THEN 1 ELSE 0 END;
            DECLARE @PaidAt DATETIME2(0) = CASE WHEN @PaymentMode = 'Account Debit' THEN SYSDATETIME() ELSE NULL END;
            
            INSERT INTO Vouchers (VoucherNo, MemberID, Amount, PaymentMode, IsPaid, PaidAt, Remarks)
            VALUES (@VoucherNo, @MemberID, @TotalAmount, @PaymentMode, @IsPaid, @PaidAt, @Remarks);
            
            DECLARE @VoucherID INT = SCOPE_IDENTITY();
            
            -- Link Fines
            IF @FineIDs IS NOT NULL AND LEN(@FineIDs) > 0
            BEGIN
                UPDATE Fines
                SET VoucherID = @VoucherID,
                    IsPaid = @IsPaid,
                    PaidAt = @PaidAt
                WHERE FineID IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(@FineIDs, ','))
                  AND MemberID = @MemberID;
            END
            
            -- Link Bookings
            IF @BookingIDs IS NOT NULL AND LEN(@BookingIDs) > 0
            BEGIN
                UPDATE FacilityBookings
                SET VoucherID = @VoucherID,
                    IsPaid = @IsPaid,
                    PaidAt = @PaidAt
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

-- 6. Stored Procedure: sp_PayVoucher
CREATE OR ALTER PROCEDURE dbo.sp_PayVoucher
    @VoucherNo VARCHAR(30),
    @Msg       VARCHAR(200) OUTPUT
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
            -- Update Voucher
            UPDATE Vouchers
            SET IsPaid = 1,
                PaidAt = SYSDATETIME()
            WHERE VoucherID = @VoucherID;
            
            -- Update linked Fines
            UPDATE Fines
            SET IsPaid = 1,
                PaidAt = SYSDATETIME()
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

-- 7. Stored Procedure: sp_ReturnBook (Updated for custom Return Date/Time override)
CREATE OR ALTER PROCEDURE dbo.sp_ReturnBook
    @CopyID         INT,
    @StaffID        SMALLINT,
    @CondID         TINYINT      = 2,    -- returned condition; default 'Good'
    @ReturnDateTime DATETIME2(0) = NULL,
    @Msg            VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LoanID INT, @MemberID INT, @DueDate DATE,
            @FPD DECIMAL(8,2), @Days INT, @Fine DECIMAL(8,2);

    SELECT TOP 1
        @LoanID   = LoanID,
        @MemberID = MemberID,
        @DueDate  = DueDate
    FROM   Loans
    WHERE  CopyID=@CopyID AND StatusID IN (1,3,4)
    ORDER  BY IssueDate DESC;

    IF @LoanID IS NULL
    BEGIN SET @Msg='ERR:NO_ACTIVE_LOAN'; RETURN; END

    DECLARE @ActualReturnDT DATETIME2(0) = ISNULL(@ReturnDateTime, SYSDATETIME());

    BEGIN TRAN;
        UPDATE Loans
        SET    ReturnDate=@ActualReturnDT, StatusID=2, ReturnedByID=@StaffID
        WHERE  LoanID=@LoanID;

        UPDATE BookCopies SET IsAvailable=1, CondID=@CondID WHERE CopyID=@CopyID;

        -- Overdue fine
        SET @Days = DATEDIFF(DAY, @DueDate, CAST(@ActualReturnDT AS DATE));
        IF @Days > 0
        BEGIN
            SELECT @FPD = CAST(SVal AS DECIMAL(8,2)) FROM Settings WHERE SKey='FinePerDay';
            SET @Fine = @Days * @FPD;
            INSERT INTO Fines (LoanID, MemberID, ReasonID, FineAmount)
            VALUES (@LoanID, @MemberID, 1, @Fine);
        END

        -- Activate next reservation (queue pos 1)
        DECLARE @BookID INT = (SELECT BookID FROM BookCopies WHERE CopyID=@CopyID);
        
        WITH CTE_NextRes AS (
            SELECT TOP(1) NotifiedAt
            FROM Reservations
            WHERE BookID = @BookID AND StatusID = 1 AND NotifiedAt IS NULL
            ORDER BY QueuePos, ReservedAt
        )
        UPDATE CTE_NextRes
        SET    NotifiedAt = SYSDATETIME();
    COMMIT;

    IF @Days > 0
        SET @Msg = 'OK:FINE:PKR ' + CAST(@Fine AS VARCHAR(12));
    ELSE IF @Days < 0
        SET @Msg = 'OK:EARLY:' + CAST(-@Days AS VARCHAR(12));
    ELSE
        SET @Msg = 'OK:ON_TIME';
END;
GO

-- 8. Stored Procedure: sp_GetMemberLedger (Updated to show returned datetime and voucher references)
CREATE OR ALTER PROCEDURE dbo.sp_GetMemberLedger
    @MemberID   INT,
    @StartDate  DATE = NULL,
    @EndDate    DATE = NULL,
    @Month      INT = NULL,
    @Year       INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    WITH LedgerCTE AS (
        -- Book Loans
        SELECT 
            CAST(l.IssueDate AS DATE) AS TxnDate,
            'Book Loan' AS TxnType,
            'Borrowed: ' + b.Title + 
                CASE 
                    WHEN l.ReturnDate IS NOT NULL 
                    THEN ' (Returned: ' + CONVERT(VARCHAR(19), l.ReturnDate, 120) + ')' 
                    ELSE '' 
                END AS Description,
            cp.Barcode AS Reference,
            0.00 AS Amount,
            CASE 
                WHEN l.StatusID = 2 THEN 'Returned'
                WHEN l.StatusID = 3 THEN 'Overdue'
                ELSE 'Issued'
            END AS Status,
            CAST(l.ReturnDate AS DATE) AS ActionDate
        FROM Loans l
        JOIN BookCopies cp ON l.CopyID = cp.CopyID
        JOIN Books b ON cp.BookID = b.BookID
        WHERE l.MemberID = @MemberID

        UNION ALL

        -- Fines
        SELECT 
            CAST(f.CreatedAt AS DATE) AS TxnDate,
            'Library Fine' AS TxnType,
            fr.ReasonName + 
                CASE 
                    WHEN f.VoucherID IS NOT NULL 
                    THEN ' (Voucher: ' + v.VoucherNo + ')' 
                    ELSE '' 
                END AS Description,
            'Fine #' + CAST(f.FineID AS VARCHAR) AS Reference,
            f.FineAmount AS Amount,
            CASE 
                WHEN f.IsPaid = 1 AND v.PaymentMode = 'Account Debit' THEN 'Paid (Account)'
                WHEN f.IsPaid = 1 THEN 'Paid' 
                ELSE 'Unpaid' 
            END AS Status,
            CAST(f.PaidAt AS DATE) AS ActionDate
        FROM Fines f
        JOIN FineReasons fr ON f.ReasonID = fr.ReasonID
        LEFT JOIN Vouchers v ON f.VoucherID = v.VoucherID
        WHERE f.MemberID = @MemberID

        UNION ALL

        -- Facility Bookings
        SELECT 
            fb.UsageDate AS TxnDate,
            'Facility Booking' AS TxnType,
            'Used: ' + fac.FacilityName + ' (' + CAST(CAST(fb.HoursUsed AS DECIMAL(5,1)) AS VARCHAR) + ' hrs)' + 
                CASE 
                    WHEN fb.VoucherID IS NOT NULL 
                    THEN ' (Voucher: ' + v.VoucherNo + ')' 
                    ELSE '' 
                END AS Description,
            'Booking #' + CAST(fb.BookingID AS VARCHAR) AS Reference,
            fb.TotalCharges AS Amount,
            CASE 
                WHEN fb.IsPaid = 1 AND v.PaymentMode = 'Account Debit' THEN 'Paid (Account)'
                WHEN fb.IsPaid = 1 THEN 'Paid' 
                ELSE 'Unpaid' 
            END AS Status,
            CAST(fb.PaidAt AS DATE) AS ActionDate
        FROM FacilityBookings fb
        JOIN Facilities fac ON fb.FacilityID = fac.FacilityID
        LEFT JOIN Vouchers v ON fb.VoucherID = v.VoucherID
        WHERE fb.MemberID = @MemberID
    )
    SELECT *
    FROM LedgerCTE
    WHERE (@StartDate IS NULL OR TxnDate >= @StartDate)
      AND (@EndDate IS NULL OR TxnDate <= @EndDate)
      AND (@Month IS NULL OR @Month = 0 OR MONTH(TxnDate) = @Month)
      AND (@Year IS NULL OR @Year = 0 OR YEAR(TxnDate) = @Year)
    ORDER BY TxnDate DESC, TxnType;
END;
GO
