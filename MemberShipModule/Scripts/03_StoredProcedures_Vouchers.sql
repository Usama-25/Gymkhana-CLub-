-- =============================================================================
-- Script 3: Stored Procedures for Financial Voucher Posting & Voucher Search
-- Database: Finance
-- Pages: Receipt.aspx, ReceiptVoucherSearch.aspx
-- =============================================================================

USE [Finance];
GO

-- 1. dbo.JV_Receipt (Financial Voucher Posting Procedure)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'JV_Receipt')
    DROP PROCEDURE dbo.JV_Receipt;
GO

CREATE PROCEDURE [dbo].[JV_Receipt] 
	@Company_Branch_Id numeric(18,0),	@By_Emp_Id int,				@Designation_Id int,
	@Amount int,						@Party_Id int,				@CostCenter int,
	@Cr_Head Varchar(50),				@Dr_Head varchar(50),		@Description varchar(50),
	@bankCharges  numeric(18,0),		@ChargesHead varchar(50),	@V_T_ID numeric(18,0) output,
	@ReceiptNo varchar(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	Declare @Company_Id numeric(18,0)	, @Financial_Company_Id int	, @Voucher_Trans_Id numeric(18,0)	, @CompanyName varchar(50),
			@voucherNo varchar(50),  @Cdate as datetime= getdate();
    set @Company_Id=@Party_Id;	

	--------------------------------------
	SELECT     @Company_Branch_Id=ISNULL(Group_Company_Branches.Company_Branch_Id, @Company_Branch_Id),
				@Financial_Company_Id= Group_Company_Branches.Financial_Company_Id
	FROM       Group_Company_Branches 
	where Company_Branch_Id=@Company_Branch_Id;	 
            	
	--------------------------------------
	SELECT     @CompanyName=Account_Title FROM Account_Titles where Account_No=@Party_Id;
	--------------------------------------
	
	-----------------------------------------   
	exec dbo.Generate_VoucherNo_Monthly 1, @Company_Branch_Id, @CDate, @voucherNo out;
	-----------------------------------------   
	BEGIN
		INSERT INTO [Finance].[dbo].[Receipt_Disbursement_AccountHeads]
				   ([Account_No]		,[Voucher_No]			,[Trans_Datetime]		,[For_Date]			,[Voucher_Type]		
				   ,[Description]		,[Trans_By_Emp_Id]		,[Trans_By_Desg_Id]		,[Approval_Status]  ,[From_Dept_Id]
				   ,[Prepared_By]		,[Checked_By]			,[Authorized_By]  	    ,[Party_ID] 	    ,[Financial_Company_Id]
				   ,[Company_Branch_Id] ,Branch_Access			,Reference_No			,Cost_Centre_ID)
		VALUES   (  @Company_Branch_Id	,@voucherNo				,@Cdate					,@Cdate				,'Reciept'		
				   ,@Description		,@By_Emp_Id				,@Designation_Id 		,0					,NULL
				   ,@By_Emp_Id			,@By_Emp_Id				,@By_Emp_Id				,@Company_Id		,@Financial_Company_Id 
				   ,@Company_Branch_Id	,2						,ISNULL(@ReceiptNo, '')	,@CostCenter	);

		SET @Voucher_Trans_Id = SCOPE_IDENTITY();
		SET @V_T_ID = @Voucher_Trans_Id;

		-- Credit Entry
		INSERT INTO [Finance].[dbo].[Reciept_Disbursement_Detail]
				   ([Voucher_Trans_Id]		,[Account_Head_id]		,[Amount]	,[Cr_Dr_Action_Id]	,[Party_ID]
				   ,[Description]		   ,[SubDept_Id],   CostCenterID)
		VALUES     ( @Voucher_Trans_Id	   ,@Cr_Head			   ,@Amount	   ,2				   ,@company_Id
					,@Description		   ,NULL,     @CostCenter);

		-- Debit Entry
		INSERT INTO [Finance].[dbo].[Reciept_Disbursement_Detail]
				   ([Voucher_Trans_Id]		,[Account_Head_id]		,[Amount]	,[Cr_Dr_Action_Id]	,[Party_ID]
				   ,[Description]		   ,[SubDept_Id],   CostCenterID)
		VALUES     ( @Voucher_Trans_Id	   ,@Dr_Head			   ,@Amount-@bankCharges   ,1				   ,@company_Id
					,@Description		   ,NULL,     @CostCenter);

		-- Bank Charges Entry
		IF @bankCharges > 0
		BEGIN
			INSERT INTO [Finance].[dbo].[Reciept_Disbursement_Detail]
						([Voucher_Trans_Id]		,[Account_Head_id]		,[Amount]	,[Cr_Dr_Action_Id]	,[Party_ID]
						,[Description]		   ,[SubDept_Id],   CostCenterID)
			VALUES     ( @Voucher_Trans_Id	   ,@ChargesHead		,@bankCharges	 ,1				   ,@company_Id
						,@Description		   ,NULL,     @CostCenter);
		END
	END
END
GO

-- 2. sp_GetReceiptVouchers (Voucher Search Query)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetReceiptVouchers')
    DROP PROCEDURE dbo.sp_GetReceiptVouchers;
GO

CREATE PROCEDURE dbo.sp_GetReceiptVouchers
    @ReceiptNo NVARCHAR(50) = NULL,
    @VoucherNo NVARCHAR(50) = NULL,
    @FromDate DATE = NULL,
    @ToDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        h.Voucher_Trans_Id,
        h.Voucher_No,
        h.For_Date AS VoucherDate,
        h.Voucher_Type,
        h.Description AS VoucherDescription,
        h.Amount AS VoucherAmount,
        ISNULL(cc.CostCenterName, ISNULL(cd.CostCenterName, ISNULL(cm.CostCenterName, '-'))) AS CostCenterName,
        ISNULL(NULLIF(h.Reference_No, ''), ISNULL(m.ReceiptNo, ISNULL(mf.ReceiptNo, '-'))) AS ReceiptNo,
        ISNULL(m.ReceiptDate, h.For_Date) AS ReceiptDate,
        ISNULL(rm.ReceiptMode, '-') AS ReceiptMode,
        ISNULL(e.E_Name, '-') AS PaymentHeadName
    FROM Receipt_Disbursement_AccountHeads h
    LEFT JOIN CostCenter cc ON h.Cost_Centre_ID = cc.CostCenterID
    OUTER APPLY (
        SELECT TOP 1 c2.CostCenterName 
        FROM Reciept_Disbursement_Detail d 
        JOIN CostCenter c2 ON d.CostCenterID = c2.CostCenterID
        WHERE d.Voucher_Trans_Id = h.Voucher_Trans_Id AND d.CostCenterID IS NOT NULL
    ) cd
    OUTER APPLY (
        SELECT TOP 1 m1.ReceiptNo, m1.ReceiptDate, m1.CostCenterID, m1.ReceiptModeID, m1.PaymentHead
        FROM MemberReceipts_Main m1
        WHERE (h.Reference_No <> '' AND m1.ReceiptNo = h.Reference_No)
           OR h.Voucher_No LIKE '%' + m1.ReceiptNo + '%'
           OR (m1.Notes <> '' AND h.Description LIKE '%' + m1.Notes + '%')
        ORDER BY m1.ReceiptMainID DESC
    ) m
    OUTER APPLY (
        SELECT TOP 1 m2.ReceiptNo 
        FROM MemberReceipts_Main m2 
        WHERE CAST(m2.ReceiptDate AS DATE) = CAST(h.For_Date AS DATE) 
        ORDER BY m2.ReceiptMainID DESC
    ) mf
    LEFT JOIN CostCenter cm ON m.CostCenterID = cm.CostCenterID
    LEFT JOIN ReceiptModes rm ON m.ReceiptModeID = rm.ReceiptModeID
    LEFT JOIN Expenditure e ON m.PaymentHead = e.E_Code
    WHERE (h.Voucher_Type IN ('Reciept', 'Receipt') OR m.ReceiptNo IS NOT NULL)
      AND (@ReceiptNo IS NULL OR @ReceiptNo = '' OR h.Reference_No LIKE '%' + @ReceiptNo + '%' OR m.ReceiptNo LIKE '%' + @ReceiptNo + '%' OR mf.ReceiptNo LIKE '%' + @ReceiptNo + '%' OR h.Description LIKE '%' + @ReceiptNo + '%')
      AND (@VoucherNo IS NULL OR @VoucherNo = '' OR h.Voucher_No LIKE '%' + @VoucherNo + '%')
      AND (@FromDate IS NULL OR CAST(h.For_Date AS DATE) >= @FromDate)
      AND (@ToDate IS NULL OR CAST(h.For_Date AS DATE) <= @ToDate)
    ORDER BY h.Voucher_Trans_Id DESC;
END
GO

-- 3. sp_GetVoucherDetails (Voucher Detail Modal Popup Query)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetVoucherDetails')
    DROP PROCEDURE dbo.sp_GetVoucherDetails;
GO

CREATE PROCEDURE dbo.sp_GetVoucherDetails
    @Voucher_Trans_Id NUMERIC(18,0)
AS
BEGIN
    SET NOCOUNT ON;

    -- Master Info
    SELECT TOP 1
        h.Voucher_Trans_Id,
        h.Voucher_No,
        h.For_Date AS VoucherDate,
        h.Voucher_Type,
        h.Description,
        h.Amount AS TotalAmount,
        ISNULL(cc.CostCenterName, ISNULL(cd.CostCenterName, ISNULL(cm.CostCenterName, '-'))) AS CostCenterName,
        ISNULL(NULLIF(h.Reference_No, ''), ISNULL(m.ReceiptNo, ISNULL(mf.ReceiptNo, '-'))) AS ReceiptNo,
        h.Trans_Datetime
    FROM Receipt_Disbursement_AccountHeads h
    LEFT JOIN CostCenter cc ON h.Cost_Centre_ID = cc.CostCenterID
    OUTER APPLY (
        SELECT TOP 1 c2.CostCenterName 
        FROM Reciept_Disbursement_Detail d 
        JOIN CostCenter c2 ON d.CostCenterID = c2.CostCenterID
        WHERE d.Voucher_Trans_Id = h.Voucher_Trans_Id AND d.CostCenterID IS NOT NULL
    ) cd
    OUTER APPLY (
        SELECT TOP 1 m1.ReceiptNo, m1.CostCenterID
        FROM MemberReceipts_Main m1
        WHERE (h.Reference_No <> '' AND m1.ReceiptNo = h.Reference_No)
           OR h.Voucher_No LIKE '%' + m1.ReceiptNo + '%'
           OR (m1.Notes <> '' AND h.Description LIKE '%' + m1.Notes + '%')
        ORDER BY m1.ReceiptMainID DESC
    ) m
    OUTER APPLY (
        SELECT TOP 1 m2.ReceiptNo 
        FROM MemberReceipts_Main m2 
        WHERE CAST(m2.ReceiptDate AS DATE) = CAST(h.For_Date AS DATE) 
        ORDER BY m2.ReceiptMainID DESC
    ) mf
    LEFT JOIN CostCenter cm ON m.CostCenterID = cm.CostCenterID
    WHERE h.Voucher_Trans_Id = @Voucher_Trans_Id;

    -- Details Info (Debit & Credit Lines)
    SELECT 
        d.Reciept_Disbursement_Detail_Id,
        d.Voucher_Trans_Id,
        d.Account_Head_id,
        ISNULL(e.E_Name, d.Account_Head_id) AS AccountTitle,
        d.Amount,
        d.Cr_Dr_Action_Id,
        CASE WHEN d.Cr_Dr_Action_Id = 1 THEN d.Amount ELSE 0 END AS DebitAmount,
        CASE WHEN d.Cr_Dr_Action_Id = 2 THEN d.Amount ELSE 0 END AS CreditAmount,
        CASE WHEN d.Cr_Dr_Action_Id = 1 THEN 'Debit (Dr)' ELSE 'Credit (Cr)' END AS ActionType,
        ISNULL(c.CostCenterName, '-') AS DetailCostCenter,
        ISNULL(d.Description, '') AS DetailDescription
    FROM Reciept_Disbursement_Detail d
    LEFT JOIN Expenditure e ON d.Account_Head_id = e.E_Code
    LEFT JOIN CostCenter c ON d.CostCenterID = c.CostCenterID
    WHERE d.Voucher_Trans_Id = @Voucher_Trans_Id
    ORDER BY d.Cr_Dr_Action_Id ASC, d.Reciept_Disbursement_Detail_Id ASC;
END
GO

PRINT 'Voucher stored procedures created successfully.';
