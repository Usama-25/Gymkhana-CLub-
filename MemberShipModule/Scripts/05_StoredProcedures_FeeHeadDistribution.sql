-- =============================================================================
-- Script 5: Create MemberFeeHeadDistribution Table
-- Target Database: Finance
-- Description: Stores fee head distribution for converted members
-- =============================================================================

USE [Finance];
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MemberFeeHeadDistribution')
BEGIN
    CREATE TABLE [dbo].[MemberFeeHeadDistribution] (
        [ID] INT IDENTITY(1,1) PRIMARY KEY,
        [NIC] NVARCHAR(50) NOT NULL,
        [MemberNo] NVARCHAR(50) NULL,
        [MemberID] INT NULL,
        [HeadId] INT NULL,
        [ECode] NVARCHAR(50) NULL,
        [HeadType] NVARCHAR(150) NULL,
        [Amount] DECIMAL(18, 2) NOT NULL,
        [TotalMFee] DECIMAL(18, 2) NOT NULL,
        [CreatedDate] DATETIME DEFAULT GETDATE()
    );
    PRINT 'Created MemberFeeHeadDistribution table.';
END
ELSE
BEGIN
    PRINT 'MemberFeeHeadDistribution table already exists.';
END
GO
