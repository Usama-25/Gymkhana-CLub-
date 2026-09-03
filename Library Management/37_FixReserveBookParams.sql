USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================================
-- Fix sp_ReserveBook: Add missing @ActualBorrowerNo and @ActualBorrowerName
-- parameters that the C# code is sending but the SP doesn't have yet.
-- ============================================================================

-- 1. Ensure ActualBorrowerNo / ActualBorrowerName columns exist on Reservations table
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Reservations') AND name = 'ActualBorrowerNo')
BEGIN
    ALTER TABLE dbo.Reservations ADD ActualBorrowerNo VARCHAR(50) NULL;
    PRINT 'Added ActualBorrowerNo column to Reservations table.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Reservations') AND name = 'ActualBorrowerName')
BEGIN
    ALTER TABLE dbo.Reservations ADD ActualBorrowerName NVARCHAR(150) NULL;
    PRINT 'Added ActualBorrowerName column to Reservations table.';
END
GO

-- 2. Replace UQ_ActiveReservation with a filtered unique index supporting dependents
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UQ_ActiveReservation]') AND type = 'UQ')
BEGIN
    ALTER TABLE dbo.Reservations DROP CONSTRAINT UQ_ActiveReservation;
    PRINT 'Dropped UQ_ActiveReservation unique constraint.';
END
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'UQ_ActiveReservation' AND object_id = OBJECT_ID('dbo.Reservations'))
BEGIN
    ALTER TABLE dbo.Reservations DROP CONSTRAINT UQ_ActiveReservation;
    PRINT 'Dropped UQ_ActiveReservation unique constraint index.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_ActiveReservation_Actual' AND object_id = OBJECT_ID('dbo.Reservations'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_ActiveReservation_Actual
    ON dbo.Reservations (MemberID, BookID, ActualBorrowerNo)
    WHERE StatusID = 1;
    PRINT 'Created UX_ActiveReservation_Actual unique index.';
END
GO

-- 3. Update sp_ReserveBook with ActualBorrower parameters
CREATE OR ALTER PROCEDURE dbo.sp_ReserveBook
    @MemberID  INT,
    @BookID    INT,
    @StartDate DATE = NULL,
    @EndDate   DATE = NULL,
    @Msg       VARCHAR(200) OUTPUT,
    @ActualBorrowerNo   VARCHAR(50) = NULL,
    @ActualBorrowerName NVARCHAR(150) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Dynamic Sync member from MemberShip database if they don't exist locally
    EXEC dbo.sp_EnsureMemberExists @MemberID;

    -- Member active?
    IF NOT EXISTS (SELECT 1 FROM Members WHERE MemberID=@MemberID AND IsActive=1)
    BEGIN SET @Msg='ERR:MEMBER_INACTIVE'; RETURN; END

    DECLARE @Today DATE = CAST(GETDATE() AS DATE);
    SET @StartDate = COALESCE(@StartDate, @Today);
    
    DECLARE @ExpDays INT;
    SELECT @ExpDays=CAST(SVal AS INT) FROM Settings WHERE SKey='ResDays';
    SET @ExpDays = COALESCE(@ExpDays, 7);
    SET @EndDate = COALESCE(@EndDate, DATEADD(DAY, @ExpDays, @StartDate));

    -- Check if dates are valid
    IF @StartDate < @Today
    BEGIN SET @Msg='ERR:INVALID_START_DATE'; RETURN; END

    IF @EndDate < @StartDate
    BEGIN SET @Msg='ERR:INVALID_END_DATE'; RETURN; END

    -- Check overlap for same family member/borrower
    IF EXISTS (
        SELECT 1 
        FROM Reservations 
        WHERE MemberID=@MemberID 
          AND BookID=@BookID 
          AND StatusID=1 
          AND StartDate <= @EndDate 
          AND EndDate >= @StartDate
          AND ISNULL(ActualBorrowerNo, '') = ISNULL(@ActualBorrowerNo, '')
    )
    BEGIN SET @Msg='ERR:ALREADY_RESERVED'; RETURN; END

    -- Check available physical copies and notified reservations to set initial NotifiedAt state
    DECLARE @AvailableCopies INT, @HeldCopies INT, @NotifiedAt DATETIME2(0) = NULL;
    
    SELECT @AvailableCopies = COUNT(*)
    FROM dbo.BookCopies
    WHERE BookID = @BookID AND IsAvailable = 1 AND CondID NOT IN (5,6);
    
    SELECT @HeldCopies = COUNT(*)
    FROM dbo.Reservations
    WHERE BookID = @BookID AND StatusID = 1 AND NotifiedAt IS NOT NULL;
    
    IF @AvailableCopies > @HeldCopies
    BEGIN
        SET @NotifiedAt = SYSDATETIME();
    END

    -- Join at the end of the active queue
    DECLARE @Queue INT;
    SELECT @Queue = ISNULL(MAX(QueuePos), 0) + 1 
    FROM dbo.Reservations 
    WHERE BookID = @BookID AND StatusID = 1;

    -- Insert reservation
    INSERT INTO Reservations (MemberID, BookID, ExpiresOn, StatusID, QueuePos, StartDate, EndDate, NotifiedAt, ActualBorrowerNo, ActualBorrowerName)
    VALUES (@MemberID, @BookID, @EndDate, 1, @Queue, @StartDate, @EndDate, @NotifiedAt, @ActualBorrowerNo, @ActualBorrowerName);

    SET @Msg='OK';
END;
GO

PRINT '=== sp_ReserveBook fixed with ActualBorrower parameters ==='
GO
