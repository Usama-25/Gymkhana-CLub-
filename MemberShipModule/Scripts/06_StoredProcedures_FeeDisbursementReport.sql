-- =============================================================================
-- Script 6: Create Stored Procedure for Member Fee Disbursement Report
-- Target Database: Finance
-- Description: Retrieves fee disbursement records with member and application details
-- =============================================================================

USE [Finance];
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetMemberFeeDisbursementReport')
    DROP PROCEDURE dbo.sp_GetMemberFeeDisbursementReport;
GO

CREATE PROCEDURE dbo.sp_GetMemberFeeDisbursementReport
    @MemberNo NVARCHAR(50) = NULL,
    @NIC NVARCHAR(50) = NULL,
    @HeadId INT = NULL,
    @FromDate DATETIME = NULL,
    @ToDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @MemberNo = NULLIF(LTRIM(RTRIM(@MemberNo)), '');
    SET @NIC = NULLIF(LTRIM(RTRIM(@NIC)), '');

    SELECT 
        d.ID,
        d.NIC,
        d.MemberNo,
        d.MemberID,
        d.HeadId,
        d.ECode,
        d.HeadType,
        d.Amount,
        d.TotalMFee,
        d.CreatedDate
    FROM MemberFeeHeadDistribution d
    WHERE (@MemberNo IS NULL OR d.MemberNo LIKE '%' + @MemberNo + '%')
      AND (@NIC IS NULL OR REPLACE(d.NIC, '-', '') LIKE '%' + REPLACE(@NIC, '-', '') + '%')
      AND (@HeadId IS NULL OR @HeadId = 0 OR d.HeadId = @HeadId)
      AND (@FromDate IS NULL OR d.CreatedDate >= @FromDate)
      AND (@ToDate IS NULL OR d.CreatedDate <= DATEADD(day, 1, @ToDate))
    ORDER BY d.CreatedDate DESC, d.MemberNo, d.ID;
END
GO
