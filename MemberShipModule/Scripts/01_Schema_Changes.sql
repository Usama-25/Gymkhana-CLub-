-- =============================================================================
-- Script 1: Database Schema Modifications & Column Additions
-- Database: Finance
-- Pages: Receipt.aspx, ReceiptVoucherSearch.aspx
-- =============================================================================

USE [Finance];
GO

-- 1. Add ValidateMember column to ReceiptModes table if not exists
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[ReceiptModes]') 
      AND name = N'ValidateMember'
)
BEGIN
    ALTER TABLE [dbo].[ReceiptModes] 
    ADD [ValidateMember] BIT NULL CONSTRAINT [DF_ReceiptModes_ValidateMember] DEFAULT ((0));
    PRINT 'Added ValidateMember column to ReceiptModes table.';
END
GO

-- 2. Add Dept_ID column to ReceiptModes table if not exists
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[ReceiptModes]') 
      AND name = N'Dept_ID'
)
BEGIN
    ALTER TABLE [dbo].[ReceiptModes] 
    ADD [Dept_ID] INT NULL;
    PRINT 'Added Dept_ID column to ReceiptModes table.';
END
GO

-- 3. Update/Fix Account_Titles View definition
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[Account_Titles]'))
BEGIN
    EXEC('
    ALTER VIEW dbo.Account_Titles
    AS
    SELECT 
        [Party_Id] AS [Account_No], 
        [Party_Name] AS [Account_Title], 
        Created_On AS [Created_On], 
        0 AS [is_deleted], 
        0 AS [Id], 
        2 AS [Entity_Type_Id], 
        [Party_Id] AS [Entity_ID], 
        LEFT([Party_Type], 1) AS A_Type, 
        ISNULL(Email, '''') AS Email, 
        ISNULL(Address, '''') AS Address, 
        ISNULL(Party_Phone, '''') AS Party_Phone, 
        ISNULL(Contact_Person_Name, '''') AS Contact_Person_Name, 
        ISNULL(STRN, '''') AS STRN, 
        Party_Type_Id, 
        NTN_No, 
        Party_Fax
    FROM Parties;
    ');
    PRINT 'Updated Account_Titles view definition.';
END
GO

-- 4. Backfill Cost_Centre_ID in Receipt_Disbursement_AccountHeads from detail lines
UPDATE h
SET h.Cost_Centre_ID = (
    SELECT TOP 1 d.CostCenterID 
    FROM Reciept_Disbursement_Detail d 
    WHERE d.Voucher_Trans_Id = h.Voucher_Trans_Id AND d.CostCenterID IS NOT NULL
)
FROM Receipt_Disbursement_AccountHeads h
WHERE h.Cost_Centre_ID IS NULL OR h.Cost_Centre_ID = 0;
GO

-- 5. Backfill Reference_No in Receipt_Disbursement_AccountHeads from MemberReceipts_Main
UPDATE h
SET h.Reference_No = m.ReceiptNo
FROM Receipt_Disbursement_AccountHeads h
JOIN MemberReceipts_Main m ON (h.Description = m.Notes AND m.Notes <> '' AND CAST(m.ReceiptDate AS DATE) = CAST(h.For_Date AS DATE))
WHERE h.Reference_No IS NULL OR h.Reference_No = '';

UPDATE h
SET h.Reference_No = m.ReceiptNo
FROM Receipt_Disbursement_AccountHeads h
OUTER APPLY (
    SELECT TOP 1 m2.ReceiptNo 
    FROM MemberReceipts_Main m2 
    WHERE CAST(m2.ReceiptDate AS DATE) = CAST(h.For_Date AS DATE) 
    ORDER BY m2.ReceiptMainID DESC
) m
WHERE (h.Reference_No IS NULL OR h.Reference_No = '')
  AND h.Voucher_Type IN ('Reciept', 'Receipt')
  AND m.ReceiptNo IS NOT NULL;
GO

PRINT 'Schema changes and backfills completed successfully.';
