-- ============================================================
--  LAHORE GYMKHANA CLUB LIBRARY
--  Stored Procedures
-- ============================================================
USE GymkhanaLibraryDB;
GO

-- ============================================================
--  SP: Add or Update a Book (with ISBN-13 validation)
-- ============================================================
CREATE PROCEDURE sp_SaveBook
    @BookID          INT           = NULL,   -- NULL = new book
    @ISBN13          CHAR(13),
    @ISBN10          CHAR(10)      = NULL,
    @Title           NVARCHAR(300),
    @SubTitle        NVARCHAR(200) = NULL,
    @CategoryID      INT,
    @PublisherID     INT           = NULL,
    @PublishYear     SMALLINT      = NULL,
    @Edition         VARCHAR(50)   = NULL,
    @Language        VARCHAR(50)   = 'English',
    @PageCount       INT           = NULL,
    @Description     NVARCHAR(MAX) = NULL,
    @Tags            NVARCHAR(500) = NULL,
    @ClassificationNo VARCHAR(50)  = NULL,
    @CoverImagePath  NVARCHAR(500) = NULL,
    @CoverImageThumb NVARCHAR(500) = NULL,
    @AddedBy         NVARCHAR(100) = NULL,
    @NewBookID       INT           OUTPUT,
    @Result          NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate ISBN-13
    IF dbo.fn_ValidateISBN13(@ISBN13) = 0
    BEGIN
        SET @Result = 'ERROR: Invalid ISBN-13 check digit for ' + @ISBN13;
        SET @NewBookID = -1;
        RETURN;
    END

    -- Duplicate ISBN check (for new books)
    IF @BookID IS NULL AND EXISTS (SELECT 1 FROM Books WHERE ISBN13 = @ISBN13)
    BEGIN
        SET @Result = 'ERROR: A book with ISBN-13 ' + @ISBN13 + ' already exists.';
        SET @NewBookID = -1;
        RETURN;
    END

    IF @BookID IS NULL
    BEGIN
        INSERT INTO Books (ISBN13, ISBN10, Title, SubTitle, CategoryID, PublisherID,
                           PublishYear, Edition, Language, PageCount, Description, Tags,
                           ClassificationNo, CoverImagePath, CoverImageThumb, AddedBy)
        VALUES (@ISBN13, @ISBN10, @Title, @SubTitle, @CategoryID, @PublisherID,
                @PublishYear, @Edition, @Language, @PageCount, @Description, @Tags,
                @ClassificationNo, @CoverImagePath, @CoverImageThumb, @AddedBy);
        SET @NewBookID = SCOPE_IDENTITY();
        SET @Result    = 'SUCCESS: Book added with ID ' + CAST(@NewBookID AS VARCHAR);
    END
    ELSE
    BEGIN
        UPDATE Books SET
            ISBN13 = @ISBN13, ISBN10 = @ISBN10, Title = @Title, SubTitle = @SubTitle,
            CategoryID = @CategoryID, PublisherID = @PublisherID, PublishYear = @PublishYear,
            Edition = @Edition, Language = @Language, PageCount = @PageCount,
            Description = @Description, Tags = @Tags, ClassificationNo = @ClassificationNo,
            CoverImagePath  = ISNULL(@CoverImagePath,  CoverImagePath),
            CoverImageThumb = ISNULL(@CoverImageThumb, CoverImageThumb)
        WHERE BookID = @BookID;
        SET @NewBookID = @BookID;
        SET @Result = 'SUCCESS: Book updated.';
    END
END
GO

-- ============================================================
--  SP: Add a physical copy to a book and assign to rack/slot
-- ============================================================
CREATE PROCEDURE sp_AddBookCopy
    @BookID          INT,
    @RackID          INT           = NULL,
    @SlotNumber      INT           = NULL,
    @Condition       VARCHAR(20)   = 'New',
    @AcquisitionCost DECIMAL(10,2) = NULL,
    @Notes           NVARCHAR(255) = NULL,
    @NewCopyID       INT           OUTPUT,
    @Barcode         VARCHAR(25)   OUTPUT,
    @Result          NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ISBN13 CHAR(13), @CopyCount INT;

    IF NOT EXISTS (SELECT 1 FROM Books WHERE BookID = @BookID AND IsActive = 1)
    BEGIN
        SET @Result = 'ERROR: Book not found.';
        SET @NewCopyID = -1;
        RETURN;
    END

    -- Validate rack slot availability
    IF @RackID IS NOT NULL
    BEGIN
        DECLARE @TotalSlots INT, @UsedSlots INT;
        SELECT @TotalSlots = TotalSlots, @UsedSlots = UsedSlots FROM Racks WHERE RackID = @RackID;
        IF @UsedSlots >= @TotalSlots
        BEGIN
            SET @Result = 'ERROR: Selected rack is full. Choose a different rack/slot.';
            SET @NewCopyID = -1;
            RETURN;
        END
        IF @SlotNumber IS NOT NULL AND EXISTS (
            SELECT 1 FROM BookCopies WHERE RackID = @RackID AND SlotNumber = @SlotNumber)
        BEGIN
            SET @Result = 'ERROR: Slot ' + CAST(@SlotNumber AS VARCHAR) + ' in this rack is already occupied.';
            SET @NewCopyID = -1;
            RETURN;
        END
    END

    -- Generate barcode: ISBN13 + zero-padded copy number
    SELECT @ISBN13 = ISBN13 FROM Books WHERE BookID = @BookID;
    SELECT @CopyCount = COUNT(*) + 1 FROM BookCopies WHERE BookID = @BookID;
    SET @Barcode = @ISBN13 + '-' + RIGHT('000' + CAST(@CopyCount AS VARCHAR), 3);

    -- Auto-assign next free slot if rack given but no slot
    IF @RackID IS NOT NULL AND @SlotNumber IS NULL
    BEGIN
        SELECT @SlotNumber = MIN(seq)
        FROM (
            SELECT TOP 100 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS seq
            FROM sys.objects
        ) nums
        WHERE seq NOT IN (
            SELECT ISNULL(SlotNumber,0) FROM BookCopies WHERE RackID = @RackID
        );
    END

    INSERT INTO BookCopies (BookID, Barcode, RackID, SlotNumber, Condition, AcquisitionDate, AcquisitionCost, Notes)
    VALUES (@BookID, @Barcode, @RackID, @SlotNumber, @Condition, GETDATE(), @AcquisitionCost, @Notes);

    SET @NewCopyID = SCOPE_IDENTITY();
    SET @Result    = 'SUCCESS: Copy added. Barcode: ' + @Barcode;
END
GO

-- ============================================================
--  SP: Search Books (comprehensive)
-- ============================================================
CREATE PROCEDURE sp_SearchBooks
    @SearchTerm    NVARCHAR(300) = NULL,
    @CategoryID    INT           = NULL,
    @AuthorID      INT           = NULL,
    @PublisherID   INT           = NULL,
    @Language      VARCHAR(50)   = NULL,
    @AvailableOnly BIT           = 0,
    @PublishYearFrom SMALLINT    = NULL,
    @PublishYearTo   SMALLINT    = NULL,
    @RackID        INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        b.BookID,
        b.ISBN13,
        dbo.fn_FormatISBN13(b.ISBN13) AS ISBN13Formatted,
        b.ISBN10,
        b.Title,
        b.SubTitle,
        b.Edition,
        b.PublishYear,
        b.Language,
        b.PageCount,
        b.Tags,
        b.ClassificationNo,
        b.CoverImagePath,
        b.CoverImageThumb,
        b.TotalCopies,
        b.AvailableCopies,
        b.Description,
        c.CategoryName,
        p.PublisherName,
        -- concatenated authors
        STUFF((
            SELECT ', ' + a2.FullName
            FROM BookAuthors ba2
            JOIN Authors a2 ON ba2.AuthorID = a2.AuthorID
            WHERE ba2.BookID = b.BookID
            ORDER BY ba2.AuthorOrder
            FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'), 1, 2, '') AS Authors,
        -- shelf address of first copy
        (SELECT TOP 1 va.FullAddress
         FROM BookCopies bc2
         JOIN vw_ShelfAddress va ON bc2.RackID = va.RackID
         WHERE bc2.BookID = b.BookID) AS ShelfAddress
    FROM Books b
    LEFT JOIN Categories c  ON b.CategoryID  = c.CategoryID
    LEFT JOIN Publishers p  ON b.PublisherID  = p.PublisherID
    WHERE b.IsActive = 1
      AND (@CategoryID  IS NULL OR b.CategoryID  = @CategoryID)
      AND (@PublisherID IS NULL OR b.PublisherID  = @PublisherID)
      AND (@Language    IS NULL OR b.Language     = @Language)
      AND (@AvailableOnly = 0   OR b.AvailableCopies > 0)
      AND (@PublishYearFrom IS NULL OR b.PublishYear >= @PublishYearFrom)
      AND (@PublishYearTo   IS NULL OR b.PublishYear <= @PublishYearTo)
      AND (@AuthorID IS NULL OR EXISTS (
              SELECT 1 FROM BookAuthors ba WHERE ba.BookID = b.BookID AND ba.AuthorID = @AuthorID))
      AND (@RackID IS NULL OR EXISTS (
              SELECT 1 FROM BookCopies bc WHERE bc.BookID = b.BookID AND bc.RackID = @RackID))
      AND (@SearchTerm IS NULL OR
           b.Title     LIKE '%' + @SearchTerm + '%' OR
           b.ISBN13                    = REPLACE(REPLACE(@SearchTerm,'-',''),' ','') OR
           b.ISBN10                    = @SearchTerm OR
           b.Tags      LIKE '%' + @SearchTerm + '%' OR
           EXISTS (SELECT 1 FROM Authors a
                   JOIN BookAuthors ba ON a.AuthorID = ba.AuthorID
                   WHERE ba.BookID = b.BookID
                   AND (a.FullName LIKE '%' + @SearchTerm + '%')))
    ORDER BY b.Title;
END
GO

-- ============================================================
--  SP: Get full book detail (single book)
-- ============================================================
CREATE PROCEDURE sp_GetBookDetail
    @BookID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Book info
    SELECT
        b.BookID,
        b.ISBN13,
        dbo.fn_FormatISBN13(b.ISBN13) AS ISBN13Formatted,
        b.ISBN10,
        b.Title, b.SubTitle, b.Edition, b.PublishYear, b.Language,
        b.PageCount, b.Description, b.Tags, b.ClassificationNo,
        b.CoverImagePath, b.CoverImageThumb,
        b.TotalCopies, b.AvailableCopies,
        c.CategoryName, p.PublisherName, p.Country AS PublisherCountry
    FROM Books b
    LEFT JOIN Categories c ON b.CategoryID = c.CategoryID
    LEFT JOIN Publishers p ON b.PublisherID = p.PublisherID
    WHERE b.BookID = @BookID;

    -- Authors
    SELECT a.AuthorID, a.FullName, a.Nationality, ba.AuthorRole, ba.AuthorOrder
    FROM BookAuthors ba JOIN Authors a ON ba.AuthorID = a.AuthorID
    WHERE ba.BookID = @BookID ORDER BY ba.AuthorOrder;

    -- Physical copies with shelf addresses
    SELECT
        bc.CopyID, bc.Barcode, bc.Condition, bc.IsAvailable,
        bc.AcquisitionDate, bc.SlotNumber, bc.Notes,
        va.FullAddress AS ShelfAddress,
        va.HallName, va.AisleCode, va.ShelfUnitCode, va.RackLabel, va.RackNumber
    FROM BookCopies bc
    LEFT JOIN vw_ShelfAddress va ON bc.RackID = va.RackID
    WHERE bc.BookID = @BookID
    ORDER BY va.FullAddress, bc.SlotNumber;
END
GO

-- ============================================================
--  SP: Issue Book
-- ============================================================
CREATE PROCEDURE sp_IssueBook
    @MemberID   INT,
    @CopyID     INT,
    @IssuedBy   NVARCHAR(100),
    @Result     NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LoanDays INT, @CurrentCount INT, @MaxAllowed INT;

    IF NOT EXISTS (SELECT 1 FROM Members WHERE MemberID = @MemberID AND IsActive = 1)
    BEGIN SET @Result = 'ERROR: Member not found or inactive.'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM BookCopies WHERE CopyID = @CopyID AND IsAvailable = 1)
    BEGIN SET @Result = 'ERROR: This copy is not available for issue.'; RETURN; END

    IF EXISTS (SELECT 1 FROM BookCopies WHERE CopyID = @CopyID AND Condition IN ('Lost','Damaged'))
    BEGIN SET @Result = 'ERROR: Copy condition prevents issue.'; RETURN; END

    SELECT @CurrentCount = COUNT(*) FROM BorrowTransactions
    WHERE MemberID = @MemberID AND Status IN ('Issued','Overdue','Renewed');
    SELECT @MaxAllowed = MaxBooksAllowed FROM Members WHERE MemberID = @MemberID;
    IF @CurrentCount >= @MaxAllowed
    BEGIN SET @Result = 'ERROR: Member has reached the borrow limit of ' + CAST(@MaxAllowed AS VARCHAR) + ' books.'; RETURN; END

    IF EXISTS (SELECT 1 FROM Fines WHERE MemberID = @MemberID AND IsPaid = 0)
    BEGIN
        DECLARE @FineTotal DECIMAL(10,2);
        SELECT @FineTotal = SUM(FineAmount) FROM Fines WHERE MemberID = @MemberID AND IsPaid = 0;
        IF @FineTotal > 500
        BEGIN SET @Result = 'ERROR: Outstanding fines of PKR ' + CAST(@FineTotal AS VARCHAR) + '. Please clear dues first.'; RETURN; END
    END

    SELECT @LoanDays = CAST(SettingValue AS INT) FROM LibrarySettings WHERE SettingKey = 'LoanDurationDays';

    BEGIN TRANSACTION;
        INSERT INTO BorrowTransactions (MemberID, CopyID, IssueDate, DueDate, Status, IssuedBy)
        VALUES (@MemberID, @CopyID, GETDATE(), DATEADD(DAY, @LoanDays, GETDATE()), 'Issued', @IssuedBy);

        UPDATE BookCopies SET IsAvailable = 0 WHERE CopyID = @CopyID;
        UPDATE Books SET AvailableCopies = AvailableCopies - 1
        WHERE BookID = (SELECT BookID FROM BookCopies WHERE CopyID = @CopyID);
    COMMIT TRANSACTION;

    SET @Result = 'SUCCESS: Book issued. Due date: ' + CONVERT(VARCHAR, DATEADD(DAY, @LoanDays, GETDATE()), 106);
END
GO

-- ============================================================
--  SP: Return Book
-- ============================================================
CREATE PROCEDURE sp_ReturnBook
    @CopyID      INT,
    @ReturnedBy  NVARCHAR(100),
    @Condition   VARCHAR(20)   = 'Good',
    @Result      NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TransID INT, @MemberID INT, @DueDate DATETIME,
            @FinePerDay DECIMAL(10,2), @OverdueDays INT, @FineAmt DECIMAL(10,2);

    SELECT TOP 1 @TransID = TransactionID, @MemberID = MemberID, @DueDate = DueDate
    FROM BorrowTransactions
    WHERE CopyID = @CopyID AND Status IN ('Issued','Overdue','Renewed')
    ORDER BY IssueDate DESC;

    IF @TransID IS NULL
    BEGIN SET @Result = 'ERROR: No active borrow record found for this copy.'; RETURN; END

    BEGIN TRANSACTION;
        UPDATE BorrowTransactions
        SET ReturnDate = GETDATE(), Status = 'Returned', ReturnedBy = @ReturnedBy
        WHERE TransactionID = @TransID;

        UPDATE BookCopies SET IsAvailable = 1, Condition = @Condition WHERE CopyID = @CopyID;
        UPDATE Books SET AvailableCopies = AvailableCopies + 1
        WHERE BookID = (SELECT BookID FROM BookCopies WHERE CopyID = @CopyID);

        -- Overdue fine
        IF GETDATE() > @DueDate
        BEGIN
            SET @OverdueDays = DATEDIFF(DAY, @DueDate, GETDATE());
            SELECT @FinePerDay = CAST(SettingValue AS DECIMAL(10,2))
            FROM LibrarySettings WHERE SettingKey = 'FinePerDay';
            SET @FineAmt = @OverdueDays * @FinePerDay;

            INSERT INTO Fines (TransactionID, MemberID, FineAmount, FineReason)
            VALUES (@TransID, @MemberID, @FineAmt,
                    'Overdue - ' + CAST(@OverdueDays AS VARCHAR) + ' day(s)');

            SET @Result = 'SUCCESS: Returned with overdue fine of PKR ' + CAST(@FineAmt AS VARCHAR);
        END
        ELSE
            SET @Result = 'SUCCESS: Book returned on time. No fine.';

        -- Advance queue for reservations on this book
        DECLARE @BookID INT = (SELECT BookID FROM BookCopies WHERE CopyID = @CopyID);
        UPDATE TOP(1) Reservations
        SET Status = 'Fulfilled', NotifiedOn = GETDATE()
        WHERE BookID = @BookID AND Status = 'Active'
        ORDER BY ReservedOn;
    COMMIT TRANSACTION;
END
GO

-- ============================================================
--  SP: Renew Book
-- ============================================================
CREATE PROCEDURE sp_RenewBook
    @TransactionID INT,
    @RenewedBy     NVARCHAR(100),
    @Result        NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MaxRenewals INT, @CurrentRenewals INT, @BookID INT, @MemberID INT, @CopyID INT;

    SELECT @CurrentRenewals = RenewalCount, @MemberID = MemberID, @CopyID = CopyID
    FROM BorrowTransactions WHERE TransactionID = @TransactionID AND Status IN ('Issued','Renewed');

    IF @CurrentRenewals IS NULL
    BEGIN SET @Result = 'ERROR: Transaction not found or book already returned.'; RETURN; END

    SELECT @MaxRenewals = CAST(SettingValue AS INT) FROM LibrarySettings WHERE SettingKey = 'MaxRenewals';
    IF @CurrentRenewals >= @MaxRenewals
    BEGIN SET @Result = 'ERROR: Maximum renewals (' + CAST(@MaxRenewals AS VARCHAR) + ') already reached.'; RETURN; END

    SET @BookID = (SELECT BookID FROM BookCopies WHERE CopyID = @CopyID);
    IF EXISTS (SELECT 1 FROM Reservations WHERE BookID = @BookID AND Status = 'Active')
    BEGIN SET @Result = 'ERROR: Cannot renew — another member has reserved this book.'; RETURN; END

    DECLARE @LoanDays INT;
    SELECT @LoanDays = CAST(SettingValue AS INT) FROM LibrarySettings WHERE SettingKey = 'LoanDurationDays';

    UPDATE BorrowTransactions
    SET DueDate = DATEADD(DAY, @LoanDays, GETDATE()),
        Status  = 'Renewed',
        RenewalCount = RenewalCount + 1
    WHERE TransactionID = @TransactionID;

    SET @Result = 'SUCCESS: Renewed. New due date: ' + CONVERT(VARCHAR, DATEADD(DAY, @LoanDays, GETDATE()), 106);
END
GO

-- ============================================================
--  SP: Reserve a Book
-- ============================================================
CREATE PROCEDURE sp_ReserveBook
    @MemberID INT,
    @BookID   INT,
    @Result   NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM Books WHERE BookID = @BookID AND AvailableCopies > 0)
    BEGIN SET @Result = 'INFO: Book is currently available. Please issue directly.'; RETURN; END

    IF EXISTS (SELECT 1 FROM Reservations WHERE MemberID = @MemberID AND BookID = @BookID AND Status = 'Active')
    BEGIN SET @Result = 'ERROR: You already have an active reservation for this book.'; RETURN; END

    DECLARE @Queue INT;
    SELECT @Queue = COUNT(*) + 1 FROM Reservations WHERE BookID = @BookID AND Status = 'Active';
    DECLARE @ResDays INT;
    SELECT @ResDays = CAST(SettingValue AS INT) FROM LibrarySettings WHERE SettingKey = 'ReservationDays';

    INSERT INTO Reservations (MemberID, BookID, ExpiryDate, QueuePosition)
    VALUES (@MemberID, @BookID, DATEADD(DAY, @ResDays, GETDATE()), @Queue);

    SET @Result = 'SUCCESS: Reservation placed. Queue position: ' + CAST(@Queue AS VARCHAR);
END
GO

-- ============================================================
--  SP: Dashboard Statistics
-- ============================================================
CREATE PROCEDURE sp_GetDashboardStats
AS
BEGIN
    SELECT
        (SELECT COUNT(*) FROM Books WHERE IsActive = 1)                          AS TotalTitles,
        (SELECT SUM(TotalCopies) FROM Books WHERE IsActive = 1)                  AS TotalCopies,
        (SELECT COUNT(*) FROM Members WHERE IsActive = 1)                        AS ActiveMembers,
        (SELECT COUNT(*) FROM BorrowTransactions WHERE Status IN ('Issued','Renewed','Overdue')) AS BooksOutOnLoan,
        (SELECT COUNT(*) FROM BorrowTransactions WHERE Status IN ('Issued','Renewed','Overdue') AND DueDate < GETDATE()) AS OverdueCount,
        (SELECT COUNT(*) FROM Reservations WHERE Status = 'Active')              AS PendingReservations,
        (SELECT ISNULL(SUM(FineAmount),0) FROM Fines WHERE IsPaid = 0)           AS UnpaidFinesTotal,
        (SELECT COUNT(*) FROM LibraryHalls WHERE IsActive = 1)                   AS TotalHalls,
        (SELECT COUNT(*) FROM Racks)                                             AS TotalRacks,
        (SELECT SUM(UsedSlots) FROM Racks)                                       AS TotalBooksOnShelves;
END
GO

-- ============================================================
--  SP: Overdue Books Report
-- ============================================================
CREATE PROCEDURE sp_GetOverdueReport
AS
BEGIN
    SELECT
        bt.TransactionID,
        m.MembershipNo, m.FullName AS MemberName, m.Phone,
        b.ISBN13, dbo.fn_FormatISBN13(b.ISBN13) AS ISBN13Formatted,
        b.Title, bc.Barcode,
        bt.IssueDate, bt.DueDate,
        DATEDIFF(DAY, bt.DueDate, GETDATE()) AS DaysOverdue,
        DATEDIFF(DAY, bt.DueDate, GETDATE()) *
            CAST((SELECT SettingValue FROM LibrarySettings WHERE SettingKey='FinePerDay') AS DECIMAL)
            AS EstimatedFine,
        va.FullAddress AS ShelfAddress
    FROM BorrowTransactions bt
    JOIN Members m         ON bt.MemberID = m.MemberID
    JOIN BookCopies bc     ON bt.CopyID   = bc.CopyID
    JOIN Books b           ON bc.BookID   = b.BookID
    LEFT JOIN vw_ShelfAddress va ON bc.RackID = va.RackID
    WHERE bt.Status IN ('Issued','Renewed','Overdue')
      AND bt.DueDate < GETDATE()
    ORDER BY DaysOverdue DESC;
END
GO

-- ============================================================
--  SP: Rack Occupancy Report
-- ============================================================
CREATE PROCEDURE sp_GetRackOccupancy
    @HallID   INT = NULL,
    @AisleID  INT = NULL
AS
BEGIN
    SELECT
        va.HallName, va.AisleCode, va.ShelfUnitCode,
        va.RackLabel, va.SubjectTag,
        va.TotalSlots, va.UsedSlots, va.FreeSlots,
        CAST(va.UsedSlots * 100.0 / NULLIF(va.TotalSlots,0) AS DECIMAL(5,2)) AS OccupancyPct,
        va.FullAddress
    FROM vw_ShelfAddress va
    JOIN ShelfUnits su ON va.ShelfUnitCode = su.ShelfUnitCode
    JOIN Aisles a      ON su.AisleID       = a.AisleID
    WHERE (@HallID  IS NULL OR a.HallID  = @HallID)
      AND (@AisleID IS NULL OR su.AisleID = @AisleID)
    ORDER BY va.HallName, va.AisleCode, va.ShelfUnitCode, va.RackNumber;
END
GO

-- ============================================================
--  SP: Bulk mark overdue transactions
-- ============================================================
CREATE PROCEDURE sp_MarkOverdueTransactions
AS
BEGIN
    UPDATE BorrowTransactions
    SET Status = 'Overdue'
    WHERE Status IN ('Issued','Renewed')
      AND DueDate < GETDATE();
    SELECT @@ROWCOUNT AS MarkedOverdue;
END
GO

PRINT 'All stored procedures created successfully.';
GO
