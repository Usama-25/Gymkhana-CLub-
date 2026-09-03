USE GymkhanaLibraryDB;
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Insert 'Weeded Out' copy condition if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM CopyConditions WHERE CondID = 7)
BEGIN
    INSERT INTO CopyConditions (CondID, CondName) VALUES (7, 'Weeded Out');
END
GO

-- 2. Create BookWeedingLog table if it doesn't exist
IF OBJECT_ID('BookWeedingLog', 'U') IS NULL
BEGIN
    CREATE TABLE BookWeedingLog (
        LogID           INT             NOT NULL IDENTITY PRIMARY KEY,
        CopyID          INT             NOT NULL REFERENCES BookCopies(CopyID),
        ActionType      VARCHAR(10)     NOT NULL CHECK (ActionType IN ('WEED', 'RESTORE')),
        Remarks         NVARCHAR(500)   NULL,
        ActionedByID    SMALLINT        NOT NULL,
        ActionedAt      DATETIME2(0)    NOT NULL DEFAULT SYSDATETIME(),
        OldCondID       TINYINT         NULL REFERENCES CopyConditions(CondID),
        NewCondID       TINYINT         NULL REFERENCES CopyConditions(CondID),
        OldRackID       SMALLINT        NULL REFERENCES Racks(RackID),
        OldSlotNo       TINYINT         NULL,
        NewRackID       SMALLINT        NULL REFERENCES Racks(RackID),
        NewSlotNo       TINYINT         NULL
    );
    CREATE NONCLUSTERED INDEX IX_BookWeedingLog_ActionedAt ON BookWeedingLog (ActionedAt);
    CREATE NONCLUSTERED INDEX IX_BookWeedingLog_CopyID ON BookWeedingLog (CopyID);
END
GO

-- 3. Stored Procedure: sp_WeedFullBook
CREATE OR ALTER PROCEDURE sp_WeedFullBook
    @BookID INT,
    @Remarks NVARCHAR(500),
    @StaffID SMALLINT,
    @Msg NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            -- Log existing info for copies that are not already weeded out
            INSERT INTO BookWeedingLog (CopyID, ActionType, Remarks, ActionedByID, ActionedAt, OldCondID, NewCondID, OldRackID, OldSlotNo, NewRackID, NewSlotNo)
            SELECT 
                CopyID, 
                'WEED', 
                @Remarks, 
                @StaffID, 
                SYSDATETIME(), 
                CondID, 
                7, -- Weeded Out
                RackID, 
                SlotNo, 
                NULL, 
                NULL
            FROM BookCopies
            WHERE BookID = @BookID AND CondID <> 7;

            -- Mark all copies as weeded out and not available, and clear their rack/slot
            UPDATE BookCopies
            SET CondID = 7, IsAvailable = 0, RackID = NULL, SlotNo = NULL
            WHERE BookID = @BookID AND CondID <> 7;

            SET @Msg = 'SUCCESS: All copies of the book have been weeded out.';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @Msg = 'ERROR: ' + ERROR_MESSAGE();
    END CATCH
END
GO

-- 4. Stored Procedure: sp_WeedSingleCopy
CREATE OR ALTER PROCEDURE sp_WeedSingleCopy
    @CopyID INT,
    @Remarks NVARCHAR(500),
    @StaffID SMALLINT,
    @Msg NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM BookCopies WHERE CopyID = @CopyID)
    BEGIN
        SET @Msg = 'ERROR: Book copy not found.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM BookCopies WHERE CopyID = @CopyID AND CondID = 7)
    BEGIN
        SET @Msg = 'ERROR: This copy is already weeded out.';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
            -- Log weeding
            INSERT INTO BookWeedingLog (CopyID, ActionType, Remarks, ActionedByID, ActionedAt, OldCondID, NewCondID, OldRackID, OldSlotNo, NewRackID, NewSlotNo)
            SELECT 
                CopyID, 
                'WEED', 
                @Remarks, 
                @StaffID, 
                SYSDATETIME(), 
                CondID, 
                7, 
                RackID, 
                SlotNo, 
                NULL, 
                NULL
            FROM BookCopies
            WHERE CopyID = @CopyID;

            -- Mark copy as weeded out, unavailable and clear location
            UPDATE BookCopies
            SET CondID = 7, IsAvailable = 0, RackID = NULL, SlotNo = NULL
            WHERE CopyID = @CopyID;

            SET @Msg = 'SUCCESS: Copy has been weeded out.';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @Msg = 'ERROR: ' + ERROR_MESSAGE();
    END CATCH
END
GO

-- 5. Stored Procedure: sp_RestoreCopy
CREATE OR ALTER PROCEDURE sp_RestoreCopy
    @CopyID INT,
    @CondID TINYINT,
    @RackID SMALLINT,
    @SlotNo TINYINT,
    @Remarks NVARCHAR(500),
    @StaffID SMALLINT,
    @Msg NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM BookCopies WHERE CopyID = @CopyID)
    BEGIN
        SET @Msg = 'ERROR: Book copy not found.';
        RETURN;
    END

    -- Check slot occupancy if rack/slot are provided
    IF @RackID IS NOT NULL AND @SlotNo IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM BookCopies WHERE RackID = @RackID AND SlotNo = @SlotNo AND CopyID <> @CopyID)
        BEGIN
            SET @Msg = 'ERROR: Selected slot ' + CAST(@SlotNo AS VARCHAR) + ' in this rack is already occupied.';
            RETURN;
        END
    END

    BEGIN TRY
        BEGIN TRANSACTION;
            -- Log restoration
            INSERT INTO BookWeedingLog (CopyID, ActionType, Remarks, ActionedByID, ActionedAt, OldCondID, NewCondID, OldRackID, OldSlotNo, NewRackID, NewSlotNo)
            SELECT 
                CopyID, 
                'RESTORE', 
                @Remarks, 
                @StaffID, 
                SYSDATETIME(), 
                CondID, 
                @CondID, 
                RackID, 
                SlotNo, 
                @RackID, 
                @SlotNo
            FROM BookCopies
            WHERE CopyID = @CopyID;

            -- Mark copy as available again with new condition and location
            UPDATE BookCopies
            SET CondID = @CondID, IsAvailable = 1, RackID = @RackID, SlotNo = @SlotNo
            WHERE CopyID = @CopyID;

            SET @Msg = 'SUCCESS: Book copy has been restored and made available.';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @Msg = 'ERROR: ' + ERROR_MESSAGE();
    END CATCH
END
GO

-- 6. Stored Procedure: sp_GetWeedLogReport
CREATE OR ALTER PROCEDURE sp_GetWeedLogReport
    @FromDate DATE = NULL,
    @ToDate DATE = NULL,
    @SearchTerm NVARCHAR(100) = NULL,
    @ActionType VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        wl.LogID,
        wl.CopyID,
        bc.Barcode,
        b.Title AS BookTitle,
        wl.ActionType,
        wl.Remarks,
        wl.ActionedAt,
        ISNULL(s.EFName, '') + ' ' + ISNULL(s.ELName, '') AS ActionedByStaff,
        c1.CondName AS OldCondition,
        c2.CondName AS NewCondition,
        -- Old Location
        ISNULL(h1.HallCode + '-' + su1.UnitCode + '-R' + CAST(r1.RackNo AS VARCHAR(3)) + ' [Slot ' + CAST(wl.OldSlotNo AS VARCHAR(3)) + ']', 'N/A') AS OldLocation,
        -- New Location
        ISNULL(h2.HallCode + '-' + su2.UnitCode + '-R' + CAST(r2.RackNo AS VARCHAR(3)) + ' [Slot ' + CAST(wl.NewSlotNo AS VARCHAR(3)) + ']', 'N/A') AS NewLocation
    FROM BookWeedingLog wl
    JOIN BookCopies bc ON wl.CopyID = bc.CopyID
    JOIN Books b ON bc.BookID = b.BookID
    LEFT JOIN User_management.dbo.Employee s ON wl.ActionedByID = s.EmpID
    LEFT JOIN CopyConditions c1 ON wl.OldCondID = c1.CondID
    LEFT JOIN CopyConditions c2 ON wl.NewCondID = c2.CondID
    -- Joins for Old Location
    LEFT JOIN Racks r1 ON wl.OldRackID = r1.RackID
    LEFT JOIN ShelfUnits su1 ON r1.UnitID = su1.UnitID
    LEFT JOIN Halls h1 ON su1.HallID = h1.HallID
    -- Joins for New Location
    LEFT JOIN Racks r2 ON wl.NewRackID = r2.RackID
    LEFT JOIN ShelfUnits su2 ON r2.UnitID = su2.UnitID
    LEFT JOIN Halls h2 ON su2.HallID = h2.HallID
    WHERE (@FromDate IS NULL OR CAST(wl.ActionedAt AS DATE) >= @FromDate)
      AND (@ToDate IS NULL OR CAST(wl.ActionedAt AS DATE) <= @ToDate)
      AND (@ActionType IS NULL OR wl.ActionType = @ActionType)
      AND (@SearchTerm IS NULL OR b.Title LIKE '%' + @SearchTerm + '%' OR bc.Barcode LIKE '%' + @SearchTerm + '%' OR (ISNULL(s.EFName, '') + ' ' + ISNULL(s.ELName, '')) LIKE '%' + @SearchTerm + '%' OR wl.Remarks LIKE '%' + @SearchTerm + '%')
    ORDER BY wl.ActionedAt DESC;
END
GO

-- 7. Stored Procedure: sp_GetBookCopiesForWeeding
CREATE OR ALTER PROCEDURE sp_GetBookCopiesForWeeding
    @BookID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        bc.CopyID,
        bc.Barcode,
        bc.CondID,
        cc.CondName,
        bc.IsAvailable,
        bc.RackID,
        bc.SlotNo,
        ISNULL(h.HallCode + '-' + su.UnitCode + '-R' + CAST(r.RackNo AS VARCHAR(3)) + ' [Slot ' + CAST(bc.SlotNo AS VARCHAR(3)) + ']', 'Unassigned') AS CurrentRack,
        bc.Notes
    FROM BookCopies bc
    JOIN CopyConditions cc ON bc.CondID = cc.CondID
    LEFT JOIN Racks r ON bc.RackID = r.RackID
    LEFT JOIN ShelfUnits su ON r.UnitID = su.UnitID
    LEFT JOIN Halls h ON su.HallID = h.HallID
    WHERE bc.BookID = @BookID
    ORDER BY bc.Barcode;
END
GO

PRINT 'Weeding setup script generated successfully.';
GO
