USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Create FacilityBookings Table if it does not exist
IF OBJECT_ID('dbo.FacilityBookings', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FacilityBookings (
        BookingID    INT             IDENTITY(1,1) PRIMARY KEY,
        MemberID     INT             NOT NULL REFERENCES dbo.Members(MemberID),
        FacilityID   INT             NOT NULL REFERENCES dbo.Facilities(FacilityID),
        UsageDate    DATE            NOT NULL,
        HoursUsed    DECIMAL(5,2)    NOT NULL CHECK (HoursUsed > 0),
        TotalCharges DECIMAL(8,2)    NOT NULL CHECK (TotalCharges >= 0),
        IsPaid       BIT             NOT NULL DEFAULT 0,
        PaidAt       DATETIME2(0)    NULL,
        Remarks      NVARCHAR(200)   NULL,
        CreatedAt    DATETIME2(0)    NOT NULL DEFAULT SYSDATETIME()
    );
    CREATE INDEX IX_FacilityBookings_MemberID ON dbo.FacilityBookings(MemberID) INCLUDE (FacilityID, UsageDate, TotalCharges, IsPaid);
    PRINT 'Created FacilityBookings table.';
END
GO

-- Clear failed seeds if any
DELETE FROM dbo.FacilityBookings;

-- Seed FacilityBookings with mock data mapping to IDs 1, 2, 3, 4
INSERT INTO dbo.FacilityBookings (MemberID, FacilityID, UsageDate, HoursUsed, TotalCharges, IsPaid, PaidAt, Remarks) VALUES
(1, 1, '2026-05-10', 2.00, 300.00, 1, '2026-05-10 12:00:00', N'Seminar A booking for study circle'),
(1, 3, '2026-05-20', 1.50, 375.00, 0, NULL, N'AV Lounge used for presentation rehearsal'),
(2, 2, '2026-06-02', 3.00, 3000.00, 1, '2026-06-02 15:45:00', N'Discussion cubicle reservation'),
(3, 1, '2026-05-15', 4.00, 600.00, 0, NULL, N'Study room booking'),
(4, 3, '2026-05-12', 2.50, 625.00, 0, NULL, N'AV Lounge booking');

PRINT 'Seeded FacilityBookings table with mock transactions.';
GO

-- 3. Stored Procedure to get Member Ledger
CREATE OR ALTER PROCEDURE dbo.sp_GetMemberLedger
    @MemberID   INT,
    @StartDate  DATE = NULL,
    @EndDate    DATE = NULL,
    @Month      INT = NULL,
    @Year       INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- CTE of all transactions
    WITH LedgerCTE AS (
        -- Book Loans
        SELECT 
            CAST(l.IssueDate AS DATE) AS TxnDate,
            'Book Loan' AS TxnType,
            'Borrowed: ' + b.Title AS Description,
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
            fr.ReasonName AS Description,
            'Fine #' + CAST(f.FineID AS VARCHAR) AS Reference,
            f.FineAmount AS Amount,
            CASE WHEN f.IsPaid = 1 THEN 'Paid' ELSE 'Unpaid' END AS Status,
            CAST(f.PaidAt AS DATE) AS ActionDate
        FROM Fines f
        JOIN FineReasons fr ON f.ReasonID = fr.ReasonID
        WHERE f.MemberID = @MemberID

        UNION ALL

        -- Facility Bookings
        SELECT 
            fb.UsageDate AS TxnDate,
            'Facility Booking' AS TxnType,
            'Used: ' + fac.FacilityName + ' (' + CAST(CAST(fb.HoursUsed AS DECIMAL(5,1)) AS VARCHAR) + ' hrs)' AS Description,
            'Booking #' + CAST(fb.BookingID AS VARCHAR) AS Reference,
            fb.TotalCharges AS Amount,
            CASE WHEN fb.IsPaid = 1 THEN 'Paid' ELSE 'Unpaid' END AS Status,
            CAST(fb.PaidAt AS DATE) AS ActionDate
        FROM FacilityBookings fb
        JOIN Facilities fac ON fb.FacilityID = fac.FacilityID
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
