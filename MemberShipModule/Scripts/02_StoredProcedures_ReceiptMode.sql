-- =============================================================================
-- Script 2: Stored Procedures for Receipt Mode Management & Popup Modal
-- Database: Finance
-- Page: Receipt.aspx
-- =============================================================================

USE [Finance];
GO

-- 1. sp_GetCostCenters
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetCostCenters')
    DROP PROCEDURE dbo.sp_GetCostCenters;
GO

CREATE PROCEDURE dbo.sp_GetCostCenters
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CostCenterID, CostCenterName 
    FROM CostCenter 
    ORDER BY CostCenterName;
END
GO

-- 2. sp_GetExpenditureHeads
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetExpenditureHeads')
    DROP PROCEDURE dbo.sp_GetExpenditureHeads;
GO

CREATE PROCEDURE dbo.sp_GetExpenditureHeads
AS
BEGIN
    SET NOCOUNT ON;
    SELECT E_Code, E_Name 
    FROM Expenditure 
    ORDER BY E_Name;
END
GO

-- 3. sp_GetDepartments
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetDepartments')
    DROP PROCEDURE dbo.sp_GetDepartments;
GO

CREATE PROCEDURE dbo.sp_GetDepartments
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Dept_ID, Dept_Name 
    FROM Department 
    ORDER BY Dept_Name;
END
GO

-- 4. sp_GetReceiptModesByType
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetReceiptModesByType')
    DROP PROCEDURE dbo.sp_GetReceiptModesByType;
GO

CREATE PROCEDURE dbo.sp_GetReceiptModesByType
    @ReceiptType INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        rm.ReceiptModeID, 
        rm.ReceiptType, 
        rm.ReceiptMode, 
        ISNULL(rm.ValidateMember, 0) AS ValidateMember, 
        rm.FinancialHead, 
        rm.Dept_ID, 
        ISNULL(rm.IsActive, 1) AS IsActive, 
        rm.CreatedAt, 
        rm.CreatedBy,
        c.CostCenterName AS Dept_Name, 
        e.E_Name
    FROM ReceiptModes rm
    LEFT JOIN CostCenter c ON rm.Dept_ID = c.CostCenterID
    LEFT JOIN Expenditure e ON rm.FinancialHead = e.E_Code
    WHERE rm.ReceiptType = @ReceiptType
    ORDER BY rm.ReceiptMode;
END
GO

-- 5. sp_InsertReceiptMode
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_InsertReceiptMode')
    DROP PROCEDURE dbo.sp_InsertReceiptMode;
GO

CREATE PROCEDURE dbo.sp_InsertReceiptMode
    @ReceiptType INT,
    @ReceiptMode NVARCHAR(100),
    @ValidateMember BIT = 0,
    @FinancialHead NVARCHAR(50) = NULL,
    @Dept_ID INT = NULL,
    @IsActive BIT = 1,
    @CreatedBy NVARCHAR(50) = NULL,
    @NewReceiptModeID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ReceiptModes (
        ReceiptType, 
        ReceiptMode, 
        ValidateMember, 
        FinancialHead, 
        Dept_ID, 
        IsActive, 
        CreatedAt, 
        CreatedBy
    )
    VALUES (
        @ReceiptType, 
        @ReceiptMode, 
        @ValidateMember, 
        @FinancialHead, 
        @Dept_ID, 
        @IsActive, 
        GETDATE(), 
        @CreatedBy
    );

    SET @NewReceiptModeID = SCOPE_IDENTITY();
END
GO

-- 6. sp_UpdateReceiptMode
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateReceiptMode')
    DROP PROCEDURE dbo.sp_UpdateReceiptMode;
GO

CREATE PROCEDURE dbo.sp_UpdateReceiptMode
    @ReceiptModeID INT,
    @ReceiptMode NVARCHAR(100),
    @ValidateMember BIT = 0,
    @FinancialHead NVARCHAR(50) = NULL,
    @Dept_ID INT = NULL,
    @IsActive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ReceiptModes
    SET 
        ReceiptMode = @ReceiptMode,
        ValidateMember = @ValidateMember,
        FinancialHead = @FinancialHead,
        Dept_ID = @Dept_ID,
        IsActive = @IsActive
    WHERE ReceiptModeID = @ReceiptModeID;
END
GO

PRINT 'Receipt Mode stored procedures created successfully.';
