-- =========================================================================
-- Migration: 43_MoveComplaintPagesToCompliantFolder.sql
-- Description: Documents the structural move of all complaints and feedback
--              pages and their Master page into the new "Compliant" folder.
--              No database schema changes were required as pages are
--              resolved via local routing and parent/sub-app web.config paths.
-- =========================================================================

USE GymkhanaLibraryDB;
GO

PRINT 'Migration 43: Moving complaints and feedback pages to the Compliant folder completed successfully in project configuration.';
GO
