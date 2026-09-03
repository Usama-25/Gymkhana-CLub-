-- =============================================================================
-- SQL Script: 04_StoredProcedures_ApplicantReceiptReports.sql
-- Description: Stored procedures for Applicant-Wise and Date/Year-Wise Receipt Reports
-- Target DB: MemberShip
-- =============================================================================

USE [MemberShip];
GO

PRINT '---------------------------------------------------------------------';
PRINT 'Creating Procedure: sp_GetApplicantWiseReceiptReport';
PRINT '---------------------------------------------------------------------';

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetApplicantWiseReceiptReport')
    DROP PROCEDURE dbo.sp_GetApplicantWiseReceiptReport;
GO

CREATE PROCEDURE dbo.sp_GetApplicantWiseReceiptReport
    @ApplicantNo INT = NULL,
    @ApplicantName NVARCHAR(200) = NULL,
    @CNIC NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @ApplicantName = NULLIF(LTRIM(RTRIM(@ApplicantName)), '');
    SET @CNIC = NULLIF(LTRIM(RTRIM(@CNIC)), '');

    CREATE TABLE #ApplicantBase (
        TrackID INT,
        ApplicantName NVARCHAR(200),
        FatherName NVARCHAR(200),
        CNIC NVARCHAR(50),
        Mobile NVARCHAR(50),
        Membership_class NVARCHAR(100),
        MembershipType NVARCHAR(100),
        FormFee DECIMAL(18,2),
        MFee DECIMAL(18,2),
        ReceiptNo NVARCHAR(100),
        CreatedOn DATETIME
    );

    INSERT INTO #ApplicantBase
    SELECT 
        a.TrackID,
        ISNULL(a.ApplicantName, ''),
        ISNULL(a.FatherName, ''),
        ISNULL(a.NIC, ''),
        ISNULL(a.Mobile, ISNULL(a.Phone, '')),
        ISNULL(a.Membership_class, ''),
        ISNULL(a.MembershipType, ''),
        ISNULL(a.FormFee, 0),
        ISNULL(a.MFee, 0),
        ISNULL(a.ReceiptNo, ''),
        ISNULL(a.CreatedOn, GETDATE())
    FROM ApplicationFForm a
    WHERE (@ApplicantNo IS NULL OR @ApplicantNo = 0 OR a.TrackID = @ApplicantNo)
      AND (@ApplicantName IS NULL OR a.ApplicantName LIKE '%' + @ApplicantName + '%')
      AND (@CNIC IS NULL OR REPLACE(a.NIC, '-', '') LIKE '%' + REPLACE(@CNIC, '-', '') + '%');

    WITH FinanceReceipts AS (
        SELECT 
            s.CNIC,
            s.ContactPerson,
            m.ReceiptNo,
            m.ReceiptDate,
            m.Notes,
            ISNULL(s.ReceiptAmount, ISNULL(s.TotalAmount, 0)) AS ReceiptPaidAmount,
            CASE 
                WHEN LOWER(ISNULL(m.Notes, '')) LIKE '%form%' THEN 'FormFee'
                WHEN LOWER(ISNULL(m.Notes, '')) LIKE '%member%' OR LOWER(ISNULL(m.Notes, '')) LIKE '%advance%' THEN 'MembershipFee'
                ELSE 'Unspecified'
            END AS FeeCategory
        FROM Finance.dbo.MemberReceipts_Main m
        JOIN Finance.dbo.MemberReceipts_Sub s ON m.ReceiptMainID = s.ReceiptMainID
    ),
    ReceiptUnion AS (
        SELECT 
            ar.TrackID,
            ar.ReceiptNo,
            ISNULL(fr.ReceiptDate, ar.CreatedAt) AS ReceiptDate,
            ISNULL(fr.Notes, 'ApplicationReceipt') AS Notes,
            ISNULL(fr.ReceiptPaidAmount, ISNULL(mf.MemberFee, ISNULL(fp.Price, ISNULL(fp.MemberFee, 0)))) AS ReceiptPaidAmount,
            ISNULL(fr.FeeCategory, 'Unspecified') AS FeeCategory
        FROM ApplicationReceipts ar
        JOIN #ApplicantBase b ON ar.TrackID = b.TrackID
        LEFT JOIN FinanceReceipts fr ON ar.ReceiptNo = fr.ReceiptNo
        LEFT JOIN MemberFee mf ON ar.TrackID = mf.TrackId AND ar.ReceiptNo = mf.ReciptNo
        LEFT JOIN FormPurchase fp ON ar.TrackID = fp.id AND ar.ReceiptNo = fp.ReceiptNo

        UNION ALL

        SELECT 
            b.TrackID,
            fr.ReceiptNo,
            fr.ReceiptDate,
            fr.Notes,
            fr.ReceiptPaidAmount,
            fr.FeeCategory
        FROM FinanceReceipts fr
        JOIN #ApplicantBase b ON (b.ReceiptNo <> '' AND b.ReceiptNo = fr.ReceiptNo) 
                             OR (fr.CNIC <> '' AND REPLACE(b.CNIC, '-', '') = REPLACE(fr.CNIC, '-', ''))
        WHERE fr.ReceiptNo NOT IN (SELECT ReceiptNo FROM ApplicationReceipts WHERE TrackID = b.TrackID)

        UNION ALL

        SELECT 
            mf.TrackId AS TrackID,
            mf.ReciptNo AS ReceiptNo,
            mf.CreatedAt AS ReceiptDate,
            'MemberFee' AS Notes,
            ISNULL(mf.MemberFee, 0) AS ReceiptPaidAmount,
            'MembershipFee' AS FeeCategory
        FROM MemberFee mf
        JOIN #ApplicantBase b ON mf.TrackId = b.TrackID
        WHERE mf.ReciptNo IS NOT NULL AND mf.ReciptNo <> ''
          AND mf.ReciptNo NOT IN (SELECT ReceiptNo FROM FinanceReceipts)
          AND mf.ReciptNo NOT IN (SELECT ISNULL(ReceiptNo, '') FROM ApplicationReceipts WHERE TrackID = mf.TrackId)
    ),
    DistinctReceipts AS (
        SELECT DISTINCT 
            TrackID, ReceiptNo, ReceiptDate, Notes, ReceiptPaidAmount, FeeCategory
        FROM ReceiptUnion
    ),
    ReceiptsWithRunningTotal AS (
        SELECT 
            TrackID,
            ReceiptNo,
            ReceiptDate,
            Notes,
            ReceiptPaidAmount,
            FeeCategory,
            SUM(ReceiptPaidAmount) OVER (
                PARTITION BY TrackID 
                ORDER BY ReceiptDate ASC, ReceiptNo ASC 
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS CumulativePaidAmount
        FROM DistinctReceipts
    )
    SELECT 
        ROW_NUMBER() OVER (ORDER BY b.TrackID DESC, dr.ReceiptDate DESC, dr.ReceiptNo DESC) AS SrNo,
        b.TrackID AS ApplicantNo,
        b.ApplicantName,
        b.FatherName,
        b.CNIC,
        b.Mobile,
        b.Membership_class,
        b.MembershipType,
        
        ISNULL(dr.ReceiptNo, 'No Receipt') AS ReceiptNo,
        dr.ReceiptDate,
        ISNULL(dr.ReceiptPaidAmount, 0) AS ReceiptPaidAmount,

        -- Form Fee per receipt (0 if this receipt is for Membership Fee)
        CASE 
            WHEN dr.ReceiptNo IS NULL OR dr.ReceiptNo = 'No Receipt' THEN ISNULL(ft.Price, 0)
            WHEN dr.FeeCategory = 'FormFee' THEN dr.ReceiptPaidAmount
            WHEN dr.FeeCategory = 'MembershipFee' THEN 0
            WHEN dr.ReceiptPaidAmount <= ISNULL(ft.Price, 0) AND ft.Price > 0 THEN dr.ReceiptPaidAmount
            ELSE 0
        END AS FormFee,

        -- Advance / MemberShip Fee per receipt (0 if this receipt is for Form Fee)
        CASE 
            WHEN dr.ReceiptNo IS NULL OR dr.ReceiptNo = 'No Receipt' THEN ISNULL(ft.EntranceFee, 0)
            WHEN dr.FeeCategory = 'MembershipFee' THEN dr.ReceiptPaidAmount
            WHEN dr.FeeCategory = 'FormFee' THEN 0
            WHEN dr.ReceiptPaidAmount > ISNULL(ft.Price, 0) OR ft.Price = 0 THEN dr.ReceiptPaidAmount
            ELSE 0
        END AS AdvanceOrMembershipFee,

        -- Total Amount from FormTable TotalAmount controlled by FormTypeMainId and SubTypeId
        ISNULL(ft.TotalAmountRequired, CASE WHEN (b.FormFee + b.MFee) > 0 THEN (b.FormFee + b.MFee) ELSE 0 END) AS TotalAmount,

        ISNULL(dr.CumulativePaidAmount, 0) AS TotalPaidAmount,

        -- Running Balance per receipt row = TotalAmount - CumulativePaidAmount up to this receipt
        CASE 
            WHEN dr.ReceiptNo IS NULL OR dr.ReceiptNo = 'No Receipt' THEN 
                ISNULL(ft.TotalAmountRequired, CASE WHEN (b.FormFee + b.MFee) > 0 THEN (b.FormFee + b.MFee) ELSE 0 END)
            WHEN (ISNULL(ft.TotalAmountRequired, CASE WHEN (b.FormFee + b.MFee) > 0 THEN (b.FormFee + b.MFee) ELSE 0 END) - ISNULL(dr.CumulativePaidAmount, 0)) <= 0 THEN 0
            ELSE (ISNULL(ft.TotalAmountRequired, CASE WHEN (b.FormFee + b.MFee) > 0 THEN (b.FormFee + b.MFee) ELSE 0 END) - ISNULL(dr.CumulativePaidAmount, 0))
        END AS BalanceRemaining

    FROM #ApplicantBase b
    LEFT JOIN ReceiptsWithRunningTotal dr ON b.TrackID = dr.TrackID
    OUTER APPLY (
        SELECT TOP 1 
            ISNULL(f.Price, 0) AS Price,
            ISNULL(f.EntranceFee, 0) AS EntranceFee,
            ISNULL(f.ExtraCharges, 0) AS ExtraCharges,
            ISNULL(f.TotalAmount, (ISNULL(f.Price, 0) + ISNULL(f.EntranceFee, 0) + ISNULL(f.ExtraCharges, 0))) AS TotalAmountRequired
        FROM FormTable f
        LEFT JOIN FormTypeMain m ON f.FormTypeMainId = m.id
        LEFT JOIN FormTypeSub s ON f.SubTypeId = s.id
        WHERE 
            (
                (b.Membership_class <> '' AND (m.FormTypeName = b.Membership_class OR f.FormTypeName = b.Membership_class))
                AND 
                (b.MembershipType <> '' AND (s.SubTypeName = b.MembershipType OR f.FormType = b.MembershipType))
            )
            OR
            (
                (b.Membership_class <> '' AND (m.FormTypeName = b.Membership_class OR f.FormTypeName = b.Membership_class))
                AND 
                (b.MembershipType IS NULL OR b.MembershipType = '' OR f.SubTypeId IS NULL)
            )
            OR
            (
                f.FormTypeName = b.Membership_class 
                OR m.FormTypeName = b.Membership_class
            )
        ORDER BY 
            CASE WHEN (m.FormTypeName = b.Membership_class OR f.FormTypeName = b.Membership_class)
                  AND (s.SubTypeName = b.MembershipType OR f.FormType = b.MembershipType) THEN 0
                 WHEN (m.FormTypeName = b.Membership_class OR f.FormTypeName = b.Membership_class) THEN 1
                 ELSE 2 END,
            f.id DESC
    ) ft
    ORDER BY b.TrackID DESC, dr.ReceiptDate DESC, dr.ReceiptNo DESC;

    DROP TABLE #ApplicantBase;
END
GO


PRINT '---------------------------------------------------------------------';
PRINT 'Creating Procedure: sp_GetDateOrYearWiseReceiptReport';
PRINT '---------------------------------------------------------------------';

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetDateOrYearWiseReceiptReport')
    DROP PROCEDURE dbo.sp_GetDateOrYearWiseReceiptReport;
GO

CREATE PROCEDURE dbo.sp_GetDateOrYearWiseReceiptReport
    @FromDate DATE = NULL,
    @ToDate DATE = NULL,
    @Year INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #ApplicantBaseDate (
        TrackID INT,
        ApplicantName NVARCHAR(200),
        FatherName NVARCHAR(200),
        CNIC NVARCHAR(50),
        Mobile NVARCHAR(50),
        Membership_class NVARCHAR(100),
        MembershipType NVARCHAR(100),
        FormFee DECIMAL(18,2),
        MFee DECIMAL(18,2),
        ReceiptNo NVARCHAR(100),
        CreatedOn DATETIME
    );

    INSERT INTO #ApplicantBaseDate
    SELECT 
        a.TrackID,
        ISNULL(a.ApplicantName, ''),
        ISNULL(a.FatherName, ''),
        ISNULL(a.NIC, ''),
        ISNULL(a.Mobile, ISNULL(a.Phone, '')),
        ISNULL(a.Membership_class, ''),
        ISNULL(a.MembershipType, ''),
        ISNULL(a.FormFee, 0),
        ISNULL(a.MFee, 0),
        ISNULL(a.ReceiptNo, ''),
        ISNULL(a.CreatedOn, GETDATE())
    FROM ApplicationFForm a
    WHERE (@FromDate IS NULL OR CAST(a.CreatedOn AS DATE) >= @FromDate)
      AND (@ToDate IS NULL OR CAST(a.CreatedOn AS DATE) <= @ToDate)
      AND (@Year IS NULL OR @Year = 0 OR YEAR(a.CreatedOn) = @Year);

    WITH FinanceReceipts AS (
        SELECT 
            s.CNIC,
            s.ContactPerson,
            m.ReceiptNo,
            m.ReceiptDate,
            m.Notes,
            ISNULL(s.ReceiptAmount, ISNULL(s.TotalAmount, 0)) AS ReceiptPaidAmount,
            CASE 
                WHEN LOWER(ISNULL(m.Notes, '')) LIKE '%form%' THEN 'FormFee'
                WHEN LOWER(ISNULL(m.Notes, '')) LIKE '%member%' OR LOWER(ISNULL(m.Notes, '')) LIKE '%advance%' THEN 'MembershipFee'
                ELSE 'Unspecified'
            END AS FeeCategory
        FROM Finance.dbo.MemberReceipts_Main m
        JOIN Finance.dbo.MemberReceipts_Sub s ON m.ReceiptMainID = s.ReceiptMainID
    ),
    ReceiptUnion AS (
        SELECT 
            ar.TrackID,
            ar.ReceiptNo,
            ISNULL(fr.ReceiptDate, ar.CreatedAt) AS ReceiptDate,
            ISNULL(fr.Notes, 'ApplicationReceipt') AS Notes,
            ISNULL(fr.ReceiptPaidAmount, ISNULL(mf.MemberFee, ISNULL(fp.Price, ISNULL(fp.MemberFee, 0)))) AS ReceiptPaidAmount,
            ISNULL(fr.FeeCategory, 'Unspecified') AS FeeCategory
        FROM ApplicationReceipts ar
        JOIN #ApplicantBaseDate b ON ar.TrackID = b.TrackID
        LEFT JOIN FinanceReceipts fr ON ar.ReceiptNo = fr.ReceiptNo
        LEFT JOIN MemberFee mf ON ar.TrackID = mf.TrackId AND ar.ReceiptNo = mf.ReciptNo
        LEFT JOIN FormPurchase fp ON ar.TrackID = fp.id AND ar.ReceiptNo = fp.ReceiptNo

        UNION ALL

        SELECT 
            b.TrackID,
            fr.ReceiptNo,
            fr.ReceiptDate,
            fr.Notes,
            fr.ReceiptPaidAmount,
            fr.FeeCategory
        FROM FinanceReceipts fr
        JOIN #ApplicantBaseDate b ON (b.ReceiptNo <> '' AND b.ReceiptNo = fr.ReceiptNo) 
                                 OR (fr.CNIC <> '' AND REPLACE(b.CNIC, '-', '') = REPLACE(fr.CNIC, '-', ''))
        WHERE fr.ReceiptNo NOT IN (SELECT ReceiptNo FROM ApplicationReceipts WHERE TrackID = b.TrackID)

        UNION ALL

        SELECT 
            mf.TrackId AS TrackID,
            mf.ReciptNo AS ReceiptNo,
            mf.CreatedAt AS ReceiptDate,
            'MemberFee' AS Notes,
            ISNULL(mf.MemberFee, 0) AS ReceiptPaidAmount,
            'MembershipFee' AS FeeCategory
        FROM MemberFee mf
        JOIN #ApplicantBaseDate b ON mf.TrackId = b.TrackID
        WHERE mf.ReciptNo IS NOT NULL AND mf.ReciptNo <> ''
          AND mf.ReciptNo NOT IN (SELECT ReceiptNo FROM FinanceReceipts)
          AND mf.ReciptNo NOT IN (SELECT ISNULL(ReceiptNo, '') FROM ApplicationReceipts WHERE TrackID = mf.TrackId)
    ),
    DistinctReceipts AS (
        SELECT DISTINCT 
            TrackID, ReceiptNo, ReceiptDate, Notes, ReceiptPaidAmount, FeeCategory
        FROM ReceiptUnion
    ),
    ReceiptsWithRunningTotal AS (
        SELECT 
            TrackID,
            ReceiptNo,
            ReceiptDate,
            Notes,
            ReceiptPaidAmount,
            FeeCategory,
            SUM(ReceiptPaidAmount) OVER (
                PARTITION BY TrackID 
                ORDER BY ReceiptDate ASC, ReceiptNo ASC 
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS CumulativePaidAmount
        FROM DistinctReceipts
    )
    SELECT 
        ROW_NUMBER() OVER (ORDER BY b.TrackID DESC, dr.ReceiptDate DESC, dr.ReceiptNo DESC) AS SrNo,
        b.TrackID AS ApplicantNo,
        b.ApplicantName,
        b.FatherName,
        b.CNIC,
        b.Mobile,
        b.Membership_class,
        b.MembershipType,
        b.CreatedOn AS ApplicationDate,
        
        ISNULL(dr.ReceiptNo, 'No Receipt') AS ReceiptNo,
        dr.ReceiptDate,
        ISNULL(dr.ReceiptPaidAmount, 0) AS ReceiptPaidAmount,

        -- Form Fee per receipt (0 if this receipt is for Membership Fee)
        CASE 
            WHEN dr.ReceiptNo IS NULL OR dr.ReceiptNo = 'No Receipt' THEN ISNULL(ft.Price, 0)
            WHEN dr.FeeCategory = 'FormFee' THEN dr.ReceiptPaidAmount
            WHEN dr.FeeCategory = 'MembershipFee' THEN 0
            WHEN dr.ReceiptPaidAmount <= ISNULL(ft.Price, 0) AND ft.Price > 0 THEN dr.ReceiptPaidAmount
            ELSE 0
        END AS FormFee,

        -- Advance / MemberShip Fee per receipt (0 if this receipt is for Form Fee)
        CASE 
            WHEN dr.ReceiptNo IS NULL OR dr.ReceiptNo = 'No Receipt' THEN ISNULL(ft.EntranceFee, 0)
            WHEN dr.FeeCategory = 'MembershipFee' THEN dr.ReceiptPaidAmount
            WHEN dr.FeeCategory = 'FormFee' THEN 0
            WHEN dr.ReceiptPaidAmount > ISNULL(ft.Price, 0) OR ft.Price = 0 THEN dr.ReceiptPaidAmount
            ELSE 0
        END AS AdvanceOrMembershipFee,

        -- Total Amount from FormTable TotalAmount controlled by FormTypeMainId and SubTypeId
        ISNULL(ft.TotalAmountRequired, CASE WHEN (b.FormFee + b.MFee) > 0 THEN (b.FormFee + b.MFee) ELSE 0 END) AS TotalAmount,

        ISNULL(dr.CumulativePaidAmount, 0) AS TotalPaidAmount,

        -- Running Balance per receipt row = TotalAmount - CumulativePaidAmount up to this receipt
        CASE 
            WHEN dr.ReceiptNo IS NULL OR dr.ReceiptNo = 'No Receipt' THEN 
                ISNULL(ft.TotalAmountRequired, CASE WHEN (b.FormFee + b.MFee) > 0 THEN (b.FormFee + b.MFee) ELSE 0 END)
            WHEN (ISNULL(ft.TotalAmountRequired, CASE WHEN (b.FormFee + b.MFee) > 0 THEN (b.FormFee + b.MFee) ELSE 0 END) - ISNULL(dr.CumulativePaidAmount, 0)) <= 0 THEN 0
            ELSE (ISNULL(ft.TotalAmountRequired, CASE WHEN (b.FormFee + b.MFee) > 0 THEN (b.FormFee + b.MFee) ELSE 0 END) - ISNULL(dr.CumulativePaidAmount, 0))
        END AS BalanceRemaining

    FROM #ApplicantBaseDate b
    LEFT JOIN ReceiptsWithRunningTotal dr ON b.TrackID = dr.TrackID
    OUTER APPLY (
        SELECT TOP 1 
            ISNULL(f.Price, 0) AS Price,
            ISNULL(f.EntranceFee, 0) AS EntranceFee,
            ISNULL(f.ExtraCharges, 0) AS ExtraCharges,
            ISNULL(f.TotalAmount, (ISNULL(f.Price, 0) + ISNULL(f.EntranceFee, 0) + ISNULL(f.ExtraCharges, 0))) AS TotalAmountRequired
        FROM FormTable f
        LEFT JOIN FormTypeMain m ON f.FormTypeMainId = m.id
        LEFT JOIN FormTypeSub s ON f.SubTypeId = s.id
        WHERE 
            (
                (b.Membership_class <> '' AND (m.FormTypeName = b.Membership_class OR f.FormTypeName = b.Membership_class))
                AND 
                (b.MembershipType <> '' AND (s.SubTypeName = b.MembershipType OR f.FormType = b.MembershipType))
            )
            OR
            (
                (b.Membership_class <> '' AND (m.FormTypeName = b.Membership_class OR f.FormTypeName = b.Membership_class))
                AND 
                (b.MembershipType IS NULL OR b.MembershipType = '' OR f.SubTypeId IS NULL)
            )
            OR
            (
                f.FormTypeName = b.Membership_class 
                OR m.FormTypeName = b.Membership_class
            )
        ORDER BY 
            CASE WHEN (m.FormTypeName = b.Membership_class OR f.FormTypeName = b.Membership_class)
                  AND (s.SubTypeName = b.MembershipType OR f.FormType = b.MembershipType) THEN 0
                 WHEN (m.FormTypeName = b.Membership_class OR f.FormTypeName = b.Membership_class) THEN 1
                 ELSE 2 END,
            f.id DESC
    ) ft
    ORDER BY b.TrackID DESC, dr.ReceiptDate DESC, dr.ReceiptNo DESC;

    DROP TABLE #ApplicantBaseDate;
END
GO
