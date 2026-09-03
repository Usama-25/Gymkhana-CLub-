USE GymkhanaLibraryDB;
GO

-- 1. Add actual borrower columns to Reservations table if they do not exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Reservations') AND name = 'ActualBorrowerNo')
BEGIN
    ALTER TABLE dbo.Reservations ADD ActualBorrowerNo VARCHAR(50) NULL;
    PRINT 'Added ActualBorrowerNo to Reservations.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Reservations') AND name = 'ActualBorrowerName')
BEGIN
    ALTER TABLE dbo.Reservations ADD ActualBorrowerName NVARCHAR(150) NULL;
    PRINT 'Added ActualBorrowerName to Reservations.';
END
GO

-- 2. Update sp_ReserveBook
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

    -- Check overlap for same member
    IF EXISTS (
        SELECT 1 
        FROM Reservations 
        WHERE MemberID=@MemberID 
          AND BookID=@BookID 
          AND StatusID=1 
          AND StartDate <= @EndDate 
          AND EndDate >= @StartDate
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

-- 3. Update sp_GetActiveReservations
CREATE OR ALTER PROCEDURE dbo.sp_GetActiveReservations
    @MemberID INT = NULL,
    @BookID   INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        r.ResID,
        r.MemberID,
        COALESCE(r.ActualBorrowerNo, m.MembershipNo) AS MembershipNo,
        COALESCE(r.ActualBorrowerName, m.FullName)   AS MemberName,
        r.BookID,
        b.Title AS BookTitle,
        r.ReservedAt,
        r.ExpiresOn,
        r.StatusID,
        rs.StatusName,
        r.QueuePos AS CurrentQueuePos,
        ROW_NUMBER() OVER (PARTITION BY r.BookID ORDER BY r.QueuePos, r.ReservedAt) AS DynamicQueuePos,
        r.StartDate AS ForecastDate,
        r.StartDate,
        r.EndDate,
        r.NotifiedAt
    FROM Reservations r
    JOIN Members m ON r.MemberID = m.MemberID
    JOIN Books b ON r.BookID = b.BookID
    JOIN ResStatuses rs ON r.StatusID = rs.StatusID
    WHERE r.StatusID = 1 -- Active
      AND (@MemberID IS NULL OR r.MemberID = @MemberID)
      AND (@BookID IS NULL OR r.BookID = @BookID)
    ORDER BY b.Title, r.StartDate, r.ReservedAt;
END;
GO
