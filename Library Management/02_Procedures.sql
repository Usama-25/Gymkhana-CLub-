-- =============================================================================
--  LAHORE GYMKHANA CLUB LIBRARY — STORED PROCEDURES  v2.0
--  Run AFTER 01_Schema.sql
-- =============================================================================
USE GymkhanaLibraryDB;
GO

-- =============================================================================
--  1. sp_SaveBook  — Insert or Update a Book
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_SaveBook
    @BookID     INT           = NULL,   -- NULL = new record
    @ISBN13     VARCHAR(50),
    @ISBN10     CHAR(10)      = NULL,
    @Title      NVARCHAR(250),
    @SubTitle   NVARCHAR(150) = NULL,
    @CatID      SMALLINT,
    @PubID      SMALLINT      = NULL,
    @LangID     TINYINT       = 1,
    @PubYear    SMALLINT      = NULL,
    @Edition    VARCHAR(30)   = NULL,
    @PageCount  SMALLINT      = NULL,
    @ClassNo    VARCHAR(30)   = NULL,
    @Tags       VARCHAR(300)  = NULL,
    @Synopsis   NVARCHAR(MAX) = NULL,
    @CoverFile  VARCHAR(50)   = NULL,
    @StaffID    SMALLINT      = NULL,
    -- OUTPUT
    @NewBookID  INT           OUTPUT,
    @Msg        VARCHAR(200)  OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. ISBN-13 check digit validation (only for standard 13-digit numeric ISBNs)
    IF LEN(@ISBN13) = 13 AND @ISBN13 NOT LIKE '%[^0-9]%'
    BEGIN
        IF dbo.fn_ISBN13Valid(@ISBN13) = 0
        BEGIN
            SET @Msg = 'ERR:ISBN13_INVALID:' + @ISBN13;
            SET @NewBookID = -1; RETURN;
        END
    END

    -- 2. Duplicate check (insert only)
    IF @BookID IS NULL AND EXISTS (SELECT 1 FROM Books WHERE ISBN13 = @ISBN13)
    BEGIN
        SET @Msg = 'ERR:ISBN13_EXISTS:' + @ISBN13;
        SET @NewBookID = -1; RETURN;
    END

    IF @BookID IS NULL
    BEGIN
        INSERT INTO Books
            (ISBN13,ISBN10,Title,SubTitle,CatID,PubID,LangID,PublishYear,
             Edition,PageCount,ClassNo,Tags,Synopsis,CoverFile,AddedByStaffID)
        VALUES
            (@ISBN13,@ISBN10,@Title,@SubTitle,@CatID,@PubID,@LangID,@PubYear,
             @Edition,@PageCount,@ClassNo,@Tags,@Synopsis,@CoverFile,@StaffID);
        SET @NewBookID = SCOPE_IDENTITY();
        SET @Msg = 'OK:' + CAST(@NewBookID AS VARCHAR);
    END
    ELSE
    BEGIN
        UPDATE Books SET
            ISBN13     = @ISBN13,   ISBN10     = @ISBN10,
            Title      = @Title,    SubTitle   = @SubTitle,
            CatID      = @CatID,    PubID      = @PubID,    LangID = @LangID,
            PublishYear= @PubYear,  Edition    = @Edition,
            PageCount  = @PageCount,ClassNo    = @ClassNo,
            Tags       = @Tags,     Synopsis   = @Synopsis,
            CoverFile  = COALESCE(@CoverFile, CoverFile)   -- keep existing if NULL passed
        WHERE BookID = @BookID;
        SET @NewBookID = @BookID;
        SET @Msg = 'OK:' + CAST(@BookID AS VARCHAR);
    END
END;
GO

-- =============================================================================
--  2. sp_AddCopy  — Add a physical copy, auto-generate barcode
-- =============================================================================
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE OR ALTER PROCEDURE dbo.sp_AddCopy
    @BookID     INT,
    @RackID     SMALLINT      = NULL,
    @SlotNo     TINYINT       = NULL,
    @CondID     TINYINT       = 1,     -- 1=New
    @AcqCost    DECIMAL(8,2)  = NULL,
    @Notes      VARCHAR(200)  = NULL,
    -- OUTPUT
    @CopyID     INT           OUTPUT,
    @Barcode    VARCHAR(55)   OUTPUT,
    @Msg        VARCHAR(200)  OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ISBN13 VARCHAR(50), @Seq INT;

    IF NOT EXISTS (SELECT 1 FROM Books WHERE BookID = @BookID AND IsActive = 1)
    BEGIN SET @Msg = 'ERR:BOOK_NOT_FOUND'; RETURN; END

    -- Rack capacity check
    IF @RackID IS NOT NULL
    BEGIN
        DECLARE @TotalSlots TINYINT,
                @UsedSlots  INT;
        SELECT @TotalSlots = TotalSlots FROM Racks WHERE RackID = @RackID;
        SELECT @UsedSlots  = COUNT(*)    FROM BookCopies WHERE RackID = @RackID;

        IF @UsedSlots >= @TotalSlots
        BEGIN SET @Msg = 'ERR:RACK_FULL:' + CAST(@RackID AS VARCHAR); RETURN; END

        IF @SlotNo IS NOT NULL
           AND EXISTS (SELECT 1 FROM BookCopies WHERE RackID=@RackID AND SlotNo=@SlotNo)
        BEGIN SET @Msg = 'ERR:SLOT_TAKEN:' + CAST(@SlotNo AS VARCHAR); RETURN; END

        -- Auto-assign lowest free slot
        IF @SlotNo IS NULL
            SELECT TOP 1 @SlotNo = n.n
            FROM (VALUES(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),
                        (11),(12),(13),(14),(15),(16),(17),(18),(19),(20),
                        (21),(22),(23),(24),(25),(26),(27),(28),(29),(30),
                        (31),(32),(33),(34),(35),(36),(37),(38),(39),(40),
                        (41),(42),(43),(44),(45),(46),(47),(48),(49),(50),
                        (51),(52),(53),(54),(55),(56),(57),(58),(59),(60),
                        (61),(62),(63),(64),(65),(66),(67),(68),(69),(70),
                        (71),(72),(73),(74),(75),(76),(77),(78),(79),(80),
                        (81),(82),(83),(84),(85),(86),(87),(88),(89),(90),
                        (91),(92),(93),(94),(95),(96),(97),(98),(99),(100)
                  ) n(n)
            WHERE n NOT IN (SELECT ISNULL(SlotNo,0) FROM BookCopies WHERE RackID=@RackID)
            ORDER BY n.n;
    END

    SELECT @ISBN13 = ISBN13 FROM Books WHERE BookID = @BookID;
    SELECT @Seq = COUNT(*) + 1 FROM BookCopies WHERE BookID = @BookID;
    SET @Barcode = @ISBN13 + '-' + RIGHT('000' + CAST(@Seq AS VARCHAR(3)), 3);

    INSERT INTO BookCopies (BookID, Barcode, RackID, SlotNo, CondID, AcqDate, AcqCost, Notes)
    VALUES (@BookID, @Barcode, @RackID, @SlotNo, @CondID, CAST(GETDATE() AS DATE), @AcqCost, @Notes);

    SET @CopyID = SCOPE_IDENTITY();
    SET @Msg    = 'OK:' + @Barcode;
END;
GO

-- =============================================================================
--  3. sp_SearchBooks  — Full catalogue search (all filters optional)
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_SearchBooks
    @Term       NVARCHAR(200) = NULL,   -- title / author / ISBN / tag / DDC
    @CatID      SMALLINT      = NULL,
    @LangID     TINYINT       = NULL,
    @PubID      SMALLINT      = NULL,
    @YearFrom   SMALLINT      = NULL,
    @YearTo     SMALLINT      = NULL,
    @AvailOnly  BIT           = 0,
    @RackID     SMALLINT      = NULL,
    @PageNumber INT           = NULL,
    @PageSize   INT           = NULL,
    @DDC        VARCHAR(50)   = NULL,
    @BookNo     INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Clean ISBN search term
    DECLARE @ISBNTerm CHAR(13) = NULL;
    IF @Term IS NOT NULL
    BEGIN
        DECLARE @cleaned VARCHAR(13) = REPLACE(REPLACE(@Term,'-',''),' ','');
        IF LEN(@cleaned) = 13 AND @cleaned NOT LIKE '%[^0-9]%'
            SET @ISBNTerm = @cleaned;
    END

    -- If pagination is NOT requested
    IF @PageNumber IS NULL OR @PageSize IS NULL
    BEGIN
        SELECT
            v.BookID, v.ISBN13, v.ISBN13Fmt, v.ISBN10, v.Title, v.SubTitle,
            v.Edition, v.PublishYear, v.CatName, v.PubName, v.LangName,
            v.CoverFile, v.TotalCopies, v.AvailableCopies, v.ClassNo, v.DDC,
            v.IsReference, v.IsAdults, v.IsChildren, v.BookNo,
            -- Authors concatenated for display
            (SELECT STRING_AGG(a.FullName + CASE WHEN ar.RoleID <> 1
                    THEN ' (' + ar.RoleName + ')' ELSE '' END, ', ')
                    WITHIN GROUP (ORDER BY ba.SortOrder)
             FROM   BookAuthors ba
             JOIN   Authors a  ON ba.AuthorID = a.AuthorID
             JOIN   AuthorRoles ar ON ba.RoleID = ar.RoleID
             WHERE  ba.BookID = v.BookID)                       AS Authors,
            -- First rack address
            (SELECT TOP 1 ro.FullAddress
             FROM   BookCopies cp
             JOIN   vw_RackOccupancy ro ON cp.RackID = ro.RackID
             WHERE  cp.BookID = v.BookID
             ORDER  BY cp.CopyID)                               AS PrimaryLocation,
            COUNT(*) OVER()                                     AS TotalRows
        FROM vw_Books v
        WHERE v.IsActive = 1
          AND (@CatID    IS NULL OR v.CatCode = (SELECT CatCode FROM Categories WHERE CatID = @CatID))
          AND (@LangID   IS NULL OR v.LangName = (SELECT LangName FROM Languages WHERE LangID = @LangID))
          AND (@PubID    IS NULL OR v.PubName  = (SELECT PubName  FROM Publishers  WHERE PubID  = @PubID))
          AND (@YearFrom IS NULL OR v.PublishYear >= @YearFrom)
          AND (@YearTo   IS NULL OR v.PublishYear <= @YearTo)
          AND (@AvailOnly= 0     OR v.AvailableCopies > 0)
          AND (@RackID   IS NULL OR EXISTS (
                  SELECT 1 FROM BookCopies cp WHERE cp.BookID=v.BookID AND cp.RackID=@RackID))
          AND (@DDC      IS NULL OR v.DDC LIKE '%' + @DDC + '%')
          AND (@BookNo   IS NULL OR EXISTS (
                  SELECT 1 FROM BookCopies cp WHERE cp.BookID=v.BookID AND cp.BookNo=@BookNo))
          AND (
                @Term IS NULL
                OR NOT EXISTS (
                    SELECT 1
                    FROM STRING_SPLIT(REPLACE(REPLACE(@Term, '+', ' '), ',', ' '), ' ') kw
                    WHERE TRIM(kw.value) <> ''
                      AND NOT (
                            REPLACE(v.Title, ' ', '') LIKE '%' + kw.value + '%'
                            OR REPLACE(COALESCE(v.SubTitle, ''), ' ', '') LIKE '%' + kw.value + '%'
                            OR REPLACE(REPLACE(v.ISBN13, ' ', ''), '-', '') LIKE '%' + REPLACE(REPLACE(kw.value, ' ', ''), '-', '') + '%'
                            OR REPLACE(COALESCE(v.CoverFile, ''), ' ', '') LIKE '%' + kw.value + '%'
                            OR REPLACE(COALESCE(v.DDC, ''), ' ', '') LIKE '%' + kw.value + '%'
                            OR EXISTS (
                                SELECT 1 FROM dbo.Books b
                                WHERE b.BookID = v.BookID
                                  AND REPLACE(COALESCE(b.Tags, ''), ' ', '') LIKE '%' + kw.value + '%'
                            )
                            OR EXISTS (
                                SELECT 1 FROM BookAuthors ba
                                JOIN Authors a ON ba.AuthorID = a.AuthorID
                                WHERE ba.BookID = v.BookID
                                  AND REPLACE(REPLACE(a.FullName, ' ', ''), ',', '') LIKE '%' + kw.value + '%'
                            )
                      )
                )
              )
        ORDER BY v.Title
        OPTION (RECOMPILE);
    END
    ELSE
    BEGIN
        -- High-performance database-level pagination
        WITH FilteredBookIDs AS (
            SELECT
                b.BookID,
                COUNT(*) OVER() AS TotalRows
            FROM Books b
            WHERE b.IsActive = 1
              AND (@CatID    IS NULL OR b.CatID = @CatID)
              AND (@LangID   IS NULL OR b.LangID = @LangID)
              AND (@PubID    IS NULL OR b.PubID = @PubID)
              AND (@YearFrom IS NULL OR b.PublishYear >= @YearFrom)
              AND (@YearTo   IS NULL OR b.PublishYear <= @YearTo)
              AND (@AvailOnly = 0 OR EXISTS (
                  SELECT 1 FROM dbo.BookCopies cp 
                  WHERE cp.BookID = b.BookID AND cp.IsAvailable = 1 AND cp.CondID NOT IN (5,6)
              ))
              AND (@RackID   IS NULL OR EXISTS (
                  SELECT 1 FROM BookCopies cp WHERE cp.BookID = b.BookID AND cp.RackID = @RackID
              ))
              AND (@DDC      IS NULL OR b.DDC LIKE '%' + @DDC + '%')
              AND (@BookNo   IS NULL OR EXISTS (
                  SELECT 1 FROM BookCopies cp WHERE cp.BookID = b.BookID AND cp.BookNo = @BookNo
              ))
              AND (
                    @Term IS NULL
                    OR NOT EXISTS (
                        SELECT 1
                        FROM STRING_SPLIT(REPLACE(REPLACE(@Term, '+', ' '), ',', ' '), ' ') kw
                        WHERE TRIM(kw.value) <> ''
                          AND NOT (
                             REPLACE(b.Title, ' ', '') LIKE '%' + kw.value + '%'
                                OR REPLACE(COALESCE(b.SubTitle, ''), ' ', '') LIKE '%' + kw.value + '%'
                                OR REPLACE(REPLACE(b.ISBN13, ' ', ''), '-', '') LIKE '%' + REPLACE(REPLACE(kw.value, ' ', ''), '-', '') + '%'
                                OR REPLACE(COALESCE(b.DDC, ''), ' ', '') LIKE '%' + kw.value + '%'
                                OR EXISTS (
                                    SELECT 1 FROM BookAuthors ba
                                    JOIN Authors a ON ba.AuthorID = a.AuthorID
                                    WHERE ba.BookID = b.BookID
                                      AND REPLACE(REPLACE(a.FullName, ' ', ''), ',', '') LIKE '%' + kw.value + '%'
                                )
                                OR REPLACE(COALESCE(b.Tags, ''), ' ', '') LIKE '%' + kw.value + '%'
                          )
                    )
                  )
            ORDER BY b.Title
            OFFSET (@PageNumber - 1) * @PageSize ROWS
            FETCH NEXT @PageSize ROWS ONLY
        )
        SELECT
            f.TotalRows,
            v.BookID, v.ISBN13, v.ISBN13Fmt, v.ISBN10, v.Title, v.SubTitle,
            v.Edition, v.PublishYear, v.CatName, v.PubName, v.LangName,
            v.CoverFile, v.TotalCopies, v.AvailableCopies, v.ClassNo, v.DDC,
            v.IsReference, v.IsAdults, v.IsChildren, v.BookNo,
            -- Concatenate authors only for the 20 returned rows
            (SELECT STRING_AGG(a.FullName + CASE WHEN ar.RoleID <> 1
                    THEN ' (' + ar.RoleName + ')' ELSE '' END, ', ')
                    WITHIN GROUP (ORDER BY ba.SortOrder)
             FROM   BookAuthors ba
             JOIN   Authors a  ON ba.AuthorID = a.AuthorID
             JOIN   AuthorRoles ar ON ba.RoleID = ar.RoleID
             WHERE  ba.BookID = v.BookID)                       AS Authors,
            -- First rack address only for the 20 returned rows
            (SELECT TOP 1 ro.FullAddress
             FROM   BookCopies cp
             JOIN   vw_RackOccupancy ro ON cp.RackID = ro.RackID
             WHERE  cp.BookID = v.BookID
             ORDER  BY cp.CopyID)                               AS PrimaryLocation
        FROM FilteredBookIDs f
        JOIN vw_Books v ON f.BookID = v.BookID
        ORDER BY v.Title
        OPTION (RECOMPILE);
    END
END;
GO

-- =============================================================================
--  4. sp_GetBookDetail  — Full detail (3 result sets)
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_GetBookDetail
    @BookID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- RS1: Book
    SELECT b.BookID, b.ISBN13, dbo.fn_ISBN13Fmt(b.ISBN13) AS ISBN13Fmt,
           b.ISBN10, b.Title, b.SubTitle, b.Edition, b.PublishYear,
           b.PageCount, b.ClassNo, b.Tags, b.Synopsis, b.CoverFile,
           c.CatName, p.PubName, l.LangName
    FROM   Books b
    JOIN   Categories c  ON b.CatID  = c.CatID
    JOIN   Languages  l  ON b.LangID = l.LangID
    LEFT JOIN Publishers p ON b.PubID = p.PubID
    WHERE  b.BookID = @BookID;

    -- RS2: Authors
    SELECT a.AuthorID, a.FullName, a.Nationality, ar.RoleName, ba.SortOrder
    FROM   BookAuthors ba
    JOIN   Authors     a  ON ba.AuthorID = a.AuthorID
    JOIN   AuthorRoles ar ON ba.RoleID   = ar.RoleID
    WHERE  ba.BookID = @BookID
    ORDER  BY ba.SortOrder;

    -- RS3: Copies with location
    SELECT cp.CopyID, cp.Barcode, cc.CondName, cc.CondName AS Condition, cp.IsAvailable,
           cp.AcqDate, cp.AcqDate AS AcquisitionDate, cp.AcqCost, cp.SlotNo, cp.Notes,
           ro.FullAddress, ro.FullAddress AS ShelfAddress, ro.HallName, ro.UnitCode, ro.RackNo
    FROM   BookCopies cp
    JOIN   CopyConditions cc ON cp.CondID = cc.CondID
    LEFT JOIN vw_RackOccupancy ro ON cp.RackID = ro.RackID
    WHERE  cp.BookID = @BookID
    ORDER  BY ro.FullAddress, cp.SlotNo;
END;
GO

-- =============================================================================
--  4.5 sp_EnsureMemberExists  — Dynamic Sync from MemberShip DB
-- =============================================================================
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE OR ALTER PROCEDURE dbo.sp_EnsureMemberExists
    @ProfileMemberID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Check if member already exists in local Members table
    IF NOT EXISTS (SELECT 1 FROM dbo.Members WHERE MemberID = @ProfileMemberID)
    BEGIN
        -- Get member info from MemberShip.dbo.MemberProfile (Active only)
        DECLARE @MemberNo VARCHAR(14), @MemberName NVARCHAR(100), @CNIC CHAR(15), @Phone VARCHAR(15), @Email VARCHAR(80), @IsActive BIT;
        
        SELECT 
            @MemberNo   = MemberNo,
            @MemberName = MemberName,
            @CNIC       = NIC,
            @Phone      = Mobile,
            @Email      = ResidentialEmail,
            @IsActive   = IsActive
        FROM MemberShip.dbo.MemberProfile
        WHERE MemberID = @ProfileMemberID;

        -- Only insert if active member exists in MemberProfile
        IF @MemberNo IS NOT NULL AND @IsActive = 1
        BEGIN
            -- Sanitize CNIC: convert empty, whitespace-only, or placeholder values to NULL
            -- to avoid UNIQUE constraint violations on non-real CNIC values
            SET @CNIC = LTRIM(RTRIM(@CNIC));
            IF @CNIC IS NULL 
               OR @CNIC = '' 
               OR @CNIC = '00000-0000000-0'
               OR @CNIC = '000000000000000'
               OR REPLACE(REPLACE(@CNIC, '-', ''), '0', '') = ''
            BEGIN
                SET @CNIC = NULL;
            END

            -- Enable identity insert to keep MemberID consistent
            SET IDENTITY_INSERT dbo.Members ON;
            
            INSERT INTO dbo.Members (MemberID, MembershipNo, FullName, CNIC, Phone, Email, MTypeID, IsActive)
            VALUES (@ProfileMemberID, @MemberNo, @MemberName, @CNIC, @Phone, @Email, 1, 1);
            
            SET IDENTITY_INSERT dbo.Members OFF;
        END
    END
END;
GO

-- =============================================================================
--  5. sp_IssueBook
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_IssueBook
    @MemberID   INT,
    @CopyID     INT,
    @StaffID    SMALLINT,
    @Msg        VARCHAR(200) OUTPUT,
    @IssueDate  DATETIME     = NULL,
    @DueDate    DATE         = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LoanDays INT, @Active INT, @MaxBooks TINYINT,
            @FineCeiling DECIMAL(8,2), @UnpaidFines DECIMAL(8,2);
    DECLARE @BookID INT, @AvailableCopies INT, @MemberRank INT, @TotalActiveReservations INT, @IsAllowedIssue BIT;
    DECLARE @ResHolderName NVARCHAR(100), @ResHolderNo VARCHAR(30);

    -- Atomic Sync member from MemberShip database if they don't exist locally
    EXEC dbo.sp_EnsureMemberExists @MemberID;

    -- Member active?
    IF NOT EXISTS (SELECT 1 FROM Members WHERE MemberID=@MemberID AND IsActive=1)
    BEGIN SET @Msg='ERR:MEMBER_INACTIVE'; RETURN; END

    -- Copy available?
    IF NOT EXISTS (SELECT 1 FROM BookCopies WHERE CopyID=@CopyID AND IsAvailable=1 AND CondID NOT IN (5,6))
    BEGIN SET @Msg='ERR:COPY_UNAVAILABLE'; RETURN; END

    -- Priority check
    SET @BookID = (SELECT BookID FROM BookCopies WHERE CopyID = @CopyID);
    
    SELECT @AvailableCopies = COUNT(*)
    FROM dbo.BookCopies
    WHERE BookID = @BookID AND IsAvailable = 1 AND CondID NOT IN (5,6);

    SELECT @MemberRank = MemberRank
    FROM (
        SELECT MemberID, ROW_NUMBER() OVER (ORDER BY QueuePos, ReservedAt) AS MemberRank
        FROM dbo.Reservations
        WHERE BookID = @BookID AND StatusID = 1
    ) t
    WHERE MemberID = @MemberID;

    SELECT @TotalActiveReservations = COUNT(*)
    FROM dbo.Reservations
    WHERE BookID = @BookID AND StatusID = 1;

    SET @IsAllowedIssue = 0;
    IF @MemberRank IS NOT NULL AND @MemberRank <= @AvailableCopies
    BEGIN
        SET @IsAllowedIssue = 1;
    END
    ELSE IF @MemberRank IS NULL AND @AvailableCopies > @TotalActiveReservations
    BEGIN
        SET @IsAllowedIssue = 1;
    END

    IF @IsAllowedIssue = 0
    BEGIN
        SELECT TOP 1 @ResHolderName = m.FullName, @ResHolderNo = m.MembershipNo
        FROM dbo.Reservations r
        JOIN dbo.Members m ON r.MemberID = m.MemberID
        WHERE r.BookID = @BookID AND r.StatusID = 1
        ORDER BY r.QueuePos, r.ReservedAt;
        
        IF @ResHolderName IS NOT NULL
            SET @Msg = 'ERR:RESERVED_FOR_OTHER:' + @ResHolderName + ' (' + @ResHolderNo + ')';
        ELSE
            SET @Msg = 'ERR:RESERVED_FOR_OTHER:Another Member';
            
        RETURN;
    END

    -- Borrow limit
    SELECT @Active = COUNT(*) FROM Loans
    WHERE  MemberID=@MemberID AND StatusID IN (1,3,4);   -- Issued/Overdue/Renewed
    SELECT @MaxBooks = COALESCE(m.MaxBooksOverride, mt.MaxBooks)
    FROM   Members m JOIN MemberTypes mt ON m.MTypeID=mt.MTypeID
    WHERE  m.MemberID=@MemberID;
    IF @Active >= @MaxBooks
    BEGIN SET @Msg='ERR:BORROW_LIMIT:' + CAST(@MaxBooks AS VARCHAR); RETURN; END

    -- Fine ceiling
    SELECT @FineCeiling = CAST(SVal AS DECIMAL(8,2)) FROM Settings WHERE SKey='FineCeiling';
    SELECT @UnpaidFines = ISNULL(SUM(FineAmount),0) FROM Fines
    WHERE  MemberID=@MemberID AND IsPaid=0;
    IF @UnpaidFines >= @FineCeiling
    BEGIN SET @Msg='ERR:UNPAID_FINES:' + CAST(@UnpaidFines AS VARCHAR); RETURN; END

    SELECT @LoanDays = CAST(SVal AS INT) FROM Settings WHERE SKey='LoanDays';

    DECLARE @ActualIssueDate DATETIME = COALESCE(@IssueDate, SYSDATETIME());
    DECLARE @ActualDueDate DATE = COALESCE(@DueDate, DATEADD(DAY, @LoanDays, CAST(GETDATE() AS DATE)));

    BEGIN TRAN;
        INSERT INTO Loans (MemberID, CopyID, IssueDate, DueDate, StatusID, IssuedByID)
        VALUES (@MemberID, @CopyID, @ActualIssueDate, @ActualDueDate, 1, @StaffID);

        UPDATE BookCopies SET IsAvailable=0 WHERE CopyID=@CopyID;

        -- Fulfill any active reservation for this member and book
        UPDATE Reservations
        SET StatusID = 2, NotifiedAt = COALESCE(NotifiedAt, SYSDATETIME())
        WHERE MemberID = @MemberID AND BookID = @BookID AND StatusID = 1;

        -- Re-sequence remaining active reservations for this book
        WITH CTE AS (
            SELECT QueuePos, ROW_NUMBER() OVER (ORDER BY QueuePos, ReservedAt) as NewPos
            FROM Reservations
            WHERE BookID = @BookID AND StatusID = 1
        )
        UPDATE CTE SET QueuePos = NewPos;
    COMMIT;

    SET @Msg = 'OK:DUE:' + CONVERT(VARCHAR, @ActualDueDate, 106);
END;
GO

-- =============================================================================
--  6. sp_ReturnBook
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_ReturnBook
    @CopyID         INT,
    @StaffID        SMALLINT,
    @CondID         TINYINT      = 2,    -- returned condition; default 'Good'
    @ReturnDateTime DATETIME2(0) = NULL,
    @Msg            VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LoanID INT, @MemberID INT, @DueDate DATE,
            @FPD DECIMAL(8,2), @Days INT, @Fine DECIMAL(8,2);

    SELECT TOP 1
        @LoanID   = LoanID,
        @MemberID = MemberID,
        @DueDate  = DueDate
    FROM   Loans
    WHERE  CopyID=@CopyID AND StatusID IN (1,3,4)
    ORDER  BY IssueDate DESC;

    IF @LoanID IS NULL
    BEGIN SET @Msg='ERR:NO_ACTIVE_LOAN'; RETURN; END

    DECLARE @ActualReturnDT DATETIME2(0) = ISNULL(@ReturnDateTime, SYSDATETIME());

    BEGIN TRAN;
        UPDATE Loans
        SET    ReturnDate=@ActualReturnDT, StatusID=2, ReturnedByID=@StaffID
        WHERE  LoanID=@LoanID;

        UPDATE BookCopies SET IsAvailable=1, CondID=@CondID WHERE CopyID=@CopyID;

        -- Overdue fine
        SET @Days = DATEDIFF(DAY, @DueDate, CAST(@ActualReturnDT AS DATE));
        IF @Days > 0
        BEGIN
            SELECT @FPD = CAST(SVal AS DECIMAL(8,2)) FROM Settings WHERE SKey='FinePerDay';
            SET @Fine = @Days * @FPD;
            INSERT INTO Fines (LoanID, MemberID, ReasonID, FineAmount)
            VALUES (@LoanID, @MemberID, 1, @Fine);
        END

        -- Activate next reservation (queue pos 1)
        DECLARE @BookID INT = (SELECT BookID FROM BookCopies WHERE CopyID=@CopyID);
        
        WITH CTE_NextRes AS (
            SELECT TOP(1) NotifiedAt
            FROM Reservations
            WHERE BookID = @BookID AND StatusID = 1 AND NotifiedAt IS NULL
            ORDER BY QueuePos, ReservedAt
        )
        UPDATE CTE_NextRes
        SET    NotifiedAt = SYSDATETIME();
    COMMIT;

    IF @Days > 0
        SET @Msg = 'OK:FINE:PKR ' + CAST(@Fine AS VARCHAR(12));
    ELSE IF @Days < 0
        SET @Msg = 'OK:EARLY:' + CAST(-@Days AS VARCHAR(12));
    ELSE
        SET @Msg = 'OK:ON_TIME';
END;
GO

-- =============================================================================
--  7. sp_RenewLoan
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_RenewLoan
    @LoanID     INT,
    @StaffID    SMALLINT,
    @Msg        VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MaxR TINYINT, @CurrR TINYINT, @BookID INT, @CopyID INT;

    SELECT @CurrR=RenewalCount, @CopyID=CopyID
    FROM   Loans WHERE LoanID=@LoanID AND StatusID IN (1,4);

    IF @CurrR IS NULL BEGIN SET @Msg='ERR:LOAN_NOT_FOUND'; RETURN; END

    SELECT @MaxR = CAST(SVal AS TINYINT) FROM Settings WHERE SKey='MaxRenewals';
    IF @CurrR >= @MaxR
    BEGIN SET @Msg='ERR:MAX_RENEWALS:'+CAST(@MaxR AS VARCHAR); RETURN; END

    SET @BookID=(SELECT BookID FROM BookCopies WHERE CopyID=@CopyID);
    IF EXISTS (SELECT 1 FROM Reservations WHERE BookID=@BookID AND StatusID=1)
    BEGIN SET @Msg='ERR:RESERVATION_EXISTS'; RETURN; END

    DECLARE @Days INT;
    SELECT @Days=CAST(SVal AS INT) FROM Settings WHERE SKey='LoanDays';

    UPDATE Loans
    SET    DueDate=DATEADD(DAY,@Days,CAST(GETDATE() AS DATE)),
           StatusID=4, RenewalCount=RenewalCount+1, IssuedByID=@StaffID
    WHERE  LoanID=@LoanID;

    SET @Msg='OK:NEW_DUE:'+CONVERT(VARCHAR,DATEADD(DAY,@Days,GETDATE()),106);
END;
GO

-- =============================================================================
--  7.5 fn_GetReservationForecast  — Forecast availability date of reserved book
-- =============================================================================
CREATE OR ALTER FUNCTION dbo.fn_GetReservationForecast
(
    @BookID INT,
    @QueuePos INT
)
RETURNS DATE
AS
BEGIN
    IF @QueuePos <= 0
        RETURN NULL;

    DECLARE @Today DATE = CAST(GETDATE() AS DATE);
    DECLARE @LoanDays INT;
    SELECT @LoanDays = CAST(SVal AS INT) FROM Settings WHERE SKey = 'LoanDays';
    SET @LoanDays = COALESCE(@LoanDays, 14);

    DECLARE @CopyDates TABLE (AvailDate DATE);

    INSERT INTO @CopyDates (AvailDate)
    SELECT 
        CASE 
            WHEN cp.IsAvailable = 1 THEN @Today
            ELSE COALESCE(
                (SELECT TOP 1 CASE WHEN DueDate < @Today THEN @Today ELSE DueDate END 
                 FROM Loans l 
                 WHERE l.CopyID = cp.CopyID AND l.StatusID IN (1,3,4) 
                 ORDER BY l.IssueDate DESC), 
                @Today
            )
        END
    FROM BookCopies cp
    WHERE cp.BookID = @BookID AND cp.CondID NOT IN (5,6);

    IF NOT EXISTS (SELECT 1 FROM @CopyDates)
        RETURN NULL;

    DECLARE @i INT = 1;
    DECLARE @ForecastDate DATE;

    WHILE @i <= @QueuePos
    BEGIN
        SELECT TOP 1 @ForecastDate = AvailDate 
        FROM @CopyDates 
        ORDER BY AvailDate ASC;

        IF @i = @QueuePos
            BREAK;

        WITH CTE AS (
            SELECT TOP 1 AvailDate 
            FROM @CopyDates 
            ORDER BY AvailDate ASC
        )
        UPDATE CTE 
        SET AvailDate = DATEADD(DAY, @LoanDays, AvailDate);

        SET @i = @i + 1;
    END

    RETURN @ForecastDate;
END;
GO

-- =============================================================================
--  7.6 fn_CheckBookAvailabilityForRange  — Check availability over a date range
-- =============================================================================
CREATE OR ALTER FUNCTION dbo.fn_CheckBookAvailabilityForRange
(
    @BookID INT,
    @StartDate DATE,
    @EndDate DATE
)
RETURNS BIT
AS
BEGIN
    IF @StartDate IS NULL OR @EndDate IS NULL OR @StartDate > @EndDate
        RETURN 0;

    DECLARE @TotalCopies INT;
    SELECT @TotalCopies = COUNT(*) 
    FROM BookCopies 
    WHERE BookID = @BookID AND CondID NOT IN (5,6);

    IF @TotalCopies = 0
        RETURN 0;

    DECLARE @CurrentDate DATE = @StartDate;
    DECLARE @Today DATE = CAST(GETDATE() AS DATE);

    WHILE @CurrentDate <= @EndDate
    BEGIN
        DECLARE @Occupied INT = 0;

        -- Count loans active on @CurrentDate
        SELECT @Occupied = COUNT(*)
        FROM Loans l
        JOIN BookCopies cp ON l.CopyID = cp.CopyID
        WHERE cp.BookID = @BookID
          AND cp.CondID NOT IN (5,6)
          AND CAST(l.IssueDate AS DATE) <= @CurrentDate
          AND (l.ReturnDate IS NULL OR CAST(l.ReturnDate AS DATE) > @CurrentDate)
          AND (@CurrentDate <= CAST(l.DueDate AS DATE) OR (l.ReturnDate IS NULL AND @CurrentDate <= @Today));

        -- Add active reservations on @CurrentDate
        DECLARE @Reserved INT = 0;
        SELECT @Reserved = COUNT(*)
        FROM Reservations r
        WHERE r.BookID = @BookID
          AND r.StatusID = 1
          AND r.StartDate <= @CurrentDate
          AND r.EndDate >= @CurrentDate;

        IF (@Occupied + @Reserved) >= @TotalCopies
            RETURN 0;

        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END;

    RETURN 1;
END;
GO

-- =============================================================================
--  8. sp_ReserveBook  — Modify to support start/end dates and range validation
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_ReserveBook
    @MemberID  INT,
    @BookID    INT,
    @StartDate DATE = NULL,
    @EndDate   DATE = NULL,
    @Msg       VARCHAR(200) OUTPUT
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
    INSERT INTO Reservations (MemberID, BookID, ExpiresOn, StatusID, QueuePos, StartDate, EndDate, NotifiedAt)
    VALUES (@MemberID, @BookID, @EndDate, 1, @Queue, @StartDate, @EndDate, @NotifiedAt);

    SET @Msg='OK';
END;
GO

-- =============================================================================
--  8.1 sp_CancelReservation  — Cancel reservation and re-sequence queue
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_CancelReservation
    @ResID INT,
    @Msg   VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @BookID INT, @StatusID TINYINT;
    SELECT @BookID = BookID, @StatusID = StatusID FROM Reservations WHERE ResID = @ResID;

    IF @BookID IS NULL
    BEGIN
        SET @Msg = 'ERR:RESERVATION_NOT_FOUND';
        RETURN;
    END

    IF @StatusID <> 1
    BEGIN
        SET @Msg = 'ERR:RESERVATION_NOT_ACTIVE';
        RETURN;
    END

    DECLARE @WasNotified DATETIME2(0);
    SELECT @WasNotified = NotifiedAt FROM Reservations WHERE ResID = @ResID;

    BEGIN TRAN;
        UPDATE Reservations 
        SET StatusID = 3 -- Cancelled
        WHERE ResID = @ResID;

        -- Re-sequence the queue
        WITH CTE AS (
            SELECT QueuePos, ROW_NUMBER() OVER (ORDER BY QueuePos, ReservedAt) as NewPos
            FROM Reservations
            WHERE BookID = @BookID AND StatusID = 1
        )
        UPDATE CTE SET QueuePos = NewPos;

        -- If it was notified, notify the next one in queue that is not notified
        IF @WasNotified IS NOT NULL
        BEGIN
            WITH CTE_NextRes AS (
                SELECT TOP(1) NotifiedAt
                FROM Reservations
                WHERE BookID = @BookID AND StatusID = 1 AND NotifiedAt IS NULL
                ORDER BY QueuePos, ReservedAt
            )
            UPDATE CTE_NextRes
            SET    NotifiedAt = SYSDATETIME();
        END
    COMMIT;

    SET @Msg = 'OK';
END;
GO

-- =============================================================================
--  8.2 sp_SetReservationPriority  — Set priority and re-sequence queue
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_SetReservationPriority
    @ResID  INT,
    @NewPos INT,
    @Msg    VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BookID INT, @OldPos INT, @StatusID TINYINT;
    SELECT @BookID = BookID, @OldPos = QueuePos, @StatusID = StatusID
    FROM Reservations 
    WHERE ResID = @ResID;

    IF @BookID IS NULL
    BEGIN
        SET @Msg = 'ERR:RESERVATION_NOT_FOUND';
        RETURN;
    END

    IF @StatusID <> 1
    BEGIN
        SET @Msg = 'ERR:RESERVATION_NOT_ACTIVE';
        RETURN;
    END

    DECLARE @MaxPos INT;
    SELECT @MaxPos = COUNT(*) FROM Reservations WHERE BookID = @BookID AND StatusID = 1;

    IF @NewPos < 1 SET @NewPos = 1;
    IF @NewPos > @MaxPos SET @NewPos = @MaxPos;

    IF @OldPos = @NewPos
    BEGIN
        SET @Msg = 'OK';
        RETURN;
    END

    BEGIN TRAN;
        IF @NewPos < @OldPos
        BEGIN
            -- Moving UP (closer to 1)
            UPDATE Reservations 
            SET QueuePos = QueuePos + 1 
            WHERE BookID = @BookID 
              AND StatusID = 1 
              AND QueuePos >= @NewPos 
              AND QueuePos < @OldPos 
              AND ResID <> @ResID;
        END
        ELSE
        BEGIN
            -- Moving DOWN (further from 1)
            UPDATE Reservations 
            SET QueuePos = QueuePos - 1 
            WHERE BookID = @BookID 
              AND StatusID = 1 
              AND QueuePos > @OldPos 
              AND QueuePos <= @NewPos 
              AND ResID <> @ResID;
        END

        UPDATE Reservations 
        SET QueuePos = @NewPos 
        WHERE ResID = @ResID;

        -- Re-sequence to ensure clean sequence 1..N
        WITH CTE AS (
            SELECT QueuePos, ROW_NUMBER() OVER (ORDER BY QueuePos, ReservedAt) as NewPos
            FROM Reservations
            WHERE BookID = @BookID AND StatusID = 1
        )
        UPDATE CTE SET QueuePos = NewPos;

    COMMIT;

    SET @Msg = 'OK';
END;
GO

-- =============================================================================
--  8.3 sp_GetActiveReservations  — Get active reservations with forecasts
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_GetActiveReservations
    @MemberID INT = NULL,
    @BookID   INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        r.ResID,
        r.MemberID,
        m.MembershipNo,
        m.FullName AS MemberName,
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

-- =============================================================================
--  9. sp_GetMemberLoans  — current + history
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_GetMemberLoans
    @MemberID INT,
    @ActiveOnly BIT = 0,
    @ActualBorrowerNo VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        l.LoanID, b.ISBN13, dbo.fn_ISBN13Fmt(b.ISBN13) AS ISBN13Fmt,
        b.Title, cp.Barcode, cp.CopyID, cp.BookNo,
        l.IssueDate, l.DueDate, l.ReturnDate, l.RenewalCount,
        ts.StatusName,
        CASE WHEN l.DueDate < CAST(GETDATE() AS DATE) AND l.ReturnDate IS NULL
             THEN DATEDIFF(DAY, l.DueDate, GETDATE()) ELSE 0 END  AS DaysOverdue,
        ro.FullAddress AS ShelfAddress,
        ISNULL(f.FineAmount, 0)                                    AS Fine,
        f.IsPaid
    FROM   Loans l
    JOIN   BookCopies cp ON l.CopyID  = cp.CopyID
    JOIN   Books b       ON cp.BookID = b.BookID
    JOIN   TxnStatuses ts ON l.StatusID = ts.StatusID
    LEFT JOIN vw_RackOccupancy ro ON cp.RackID = ro.RackID
    LEFT JOIN Fines f ON f.LoanID = l.LoanID
    WHERE  l.MemberID = @MemberID
      AND  (@ActiveOnly=0 OR l.StatusID IN (1,3,4))
      AND  (@ActualBorrowerNo IS NULL OR @ActualBorrowerNo = '' OR COALESCE(l.ActualBorrowerNo, '') = @ActualBorrowerNo)
    ORDER  BY l.IssueDate DESC;
END;
GO

-- =============================================================================
-- 10. sp_GetOverdueReport
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_GetOverdueReport
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @FPD DECIMAL(8,2);
    SELECT  @FPD = CAST(SVal AS DECIMAL(8,2)) FROM Settings WHERE SKey='FinePerDay';

    SELECT
        l.LoanID,
        m.MembershipNo, m.FullName AS MemberName, m.Phone,
        dbo.fn_ISBN13Fmt(b.ISBN13) AS ISBN13Fmt, b.Title, cp.Barcode,
        l.IssueDate, l.DueDate,
        DATEDIFF(DAY, l.DueDate, GETDATE())           AS DaysOverdue,
        DATEDIFF(DAY, l.DueDate, GETDATE()) * @FPD    AS EstFine,
        ro.FullAddress                                 AS ShelfAddress
    FROM   Loans l
    JOIN   Members   m  ON l.MemberID = m.MemberID
    JOIN   BookCopies cp ON l.CopyID  = cp.CopyID
    JOIN   Books b       ON cp.BookID = b.BookID
    LEFT JOIN vw_RackOccupancy ro ON cp.RackID = ro.RackID
    WHERE  l.StatusID IN (1,3,4)
      AND  l.DueDate < CAST(GETDATE() AS DATE)
    ORDER  BY DaysOverdue DESC;
END;
GO

-- =============================================================================
-- 11. sp_DashboardStats
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_DashboardStats
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        (SELECT COUNT(*)             FROM Books        WHERE IsActive=1)        AS TotalTitles,
        (SELECT COUNT(*)             FROM BookCopies)                           AS TotalCopies,
        (SELECT COUNT(*)             FROM BookCopies   WHERE IsAvailable=1)     AS AvailableCopies,
        (SELECT COUNT(*)             FROM Members      WHERE IsActive=1)        AS ActiveMembers,
        (SELECT COUNT(*)             FROM Loans        WHERE StatusID IN(1,3,4)) AS LoansActive,
        (SELECT COUNT(*)             FROM Loans
         WHERE StatusID IN(1,3,4)   AND DueDate < CAST(GETDATE() AS DATE))     AS Overdue,
        (SELECT COUNT(*)             FROM Reservations WHERE StatusID=1)        AS PendingReservations,
        (SELECT ISNULL(SUM(FineAmount),0)
         FROM Fines WHERE IsPaid=0)                                             AS UnpaidFinesPKR,
        -- Reminders Stats
        (SELECT COUNT(*) FROM Loans WHERE StatusID IN(1,3,4) AND DATEDIFF(DAY, DueDate, CAST(GETDATE() AS DATE)) >= 7 AND Reminder3SentDate IS NULL AND Reminder2SentDate IS NULL AND Reminder1SentDate IS NULL) AS RemindersGentle,
        (SELECT COUNT(*) FROM Loans WHERE StatusID IN(1,3,4) AND DATEDIFF(DAY, DueDate, CAST(GETDATE() AS DATE)) >= 15 AND Reminder3SentDate IS NULL AND Reminder2SentDate IS NULL) AS RemindersHarsh,
        (SELECT COUNT(*) FROM Loans WHERE StatusID IN(1,3,4) AND DATEDIFF(DAY, DueDate, CAST(GETDATE() AS DATE)) >= 30 AND Reminder3SentDate IS NULL) AS RemindersFinal,
        -- Today's Expected Returns
        (SELECT COUNT(*) FROM Loans WHERE StatusID IN(1,3,4) AND DueDate = CAST(GETDATE() AS DATE)) AS TodayReturns;
END;
GO

-- =============================================================================
-- 12. sp_MarkOverdue  — scheduled daily job
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_MarkOverdue
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Loans SET StatusID=3
    WHERE  StatusID IN (1,4)
      AND  DueDate < CAST(GETDATE() AS DATE);
    SELECT @@ROWCOUNT AS MarkedOverdue;
END;
GO

-- =============================================================================
-- 13. sp_RackOccupancy
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_RackOccupancy
    @HallID   SMALLINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ro.HallName, ro.UnitCode, ro.RackNo, ro.SubjectTag,
        ro.TotalSlots, ro.UsedSlots, ro.FreeSlots,
        CAST(ro.UsedSlots * 100.0 / NULLIF(ro.TotalSlots,0) AS DECIMAL(5,1)) AS OccupancyPct,
        ro.FullAddress
    FROM vw_RackOccupancy ro
    JOIN ShelfUnits su ON ro.UnitCode = su.UnitCode
    JOIN Halls h       ON su.HallID   = h.HallID
    WHERE (@HallID IS NULL OR h.HallID = @HallID)
    ORDER BY ro.HallName, ro.UnitCode, ro.RackNo;
END;
GO

-- =============================================================================
-- 14. sp_ReturnCollectReissue
-- =============================================================================
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE OR ALTER PROCEDURE dbo.sp_ReturnCollectReissue
    @CopyID             INT,
    @StaffID            SMALLINT,
    @CondID             TINYINT      = 2,    -- default condition 'Good'
    @ReissueToMemberID  INT          = NULL, -- if NULL, reissue to the returning member
    @IssueDate          DATETIME     = NULL,
    @DueDate            DATE         = NULL,
    @CollectFines       BIT          = 1,    -- if 1, atomically mark the generated fine as paid
    @Msg                VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LoanID INT, @ReturningMemberID INT, @DueDateOrig DATE,
            @FPD DECIMAL(8,2), @Days INT, @Fine DECIMAL(8,2) = 0,
            @NewFineID INT = NULL;
    DECLARE @BookID INT, @AvailableCopies INT, @MemberRank INT, @TotalActiveReservations INT, @IsAllowedReissue BIT;
    DECLARE @ResHolderName NVARCHAR(100), @ResHolderNo VARCHAR(30);

    -- 1. Find active loan
    SELECT TOP 1
        @LoanID             = LoanID,
        @ReturningMemberID  = MemberID,
        @DueDateOrig        = DueDate
    FROM   dbo.Loans
    WHERE  CopyID=@CopyID AND StatusID IN (1,3,4)
    ORDER  BY IssueDate DESC;

    IF @LoanID IS NULL
    BEGIN
        SET @Msg='ERR:NO_ACTIVE_LOAN';
        RETURN;
    END

    -- Reissue target member
    DECLARE @TargetMemberID INT = COALESCE(@ReissueToMemberID, @ReturningMemberID);

    BEGIN TRAN;
        -- A. Return the book
        UPDATE dbo.Loans
        SET    ReturnDate = SYSDATETIME(), 
               StatusID = 2, 
               ReturnedByID = @StaffID
        WHERE  LoanID = @LoanID;

        -- We update the copy condition. IsAvailable will be updated by reissue.
        UPDATE dbo.BookCopies 
        SET    CondID = @CondID 
        WHERE  CopyID = @CopyID;

        -- B. Calculate overdue fine
        SET @Days = DATEDIFF(DAY, @DueDateOrig, CAST(GETDATE() AS DATE));
        IF @Days > 0
        BEGIN
            SELECT @FPD = CAST(SVal AS DECIMAL(8,2)) FROM dbo.Settings WHERE SKey='FinePerDay';
            SET @Fine = @Days * @FPD;
            
            -- Insert the fine
            INSERT INTO dbo.Fines (LoanID, MemberID, ReasonID, FineAmount, IsPaid, PaidAt, CollectedByID)
            VALUES (@LoanID, @ReturningMemberID, 1, @Fine, 
                    CASE WHEN @CollectFines = 1 THEN 1 ELSE 0 END,
                    CASE WHEN @CollectFines = 1 THEN SYSDATETIME() ELSE NULL END,
                    CASE WHEN @CollectFines = 1 THEN @StaffID ELSE NULL END);
            
            SET @NewFineID = SCOPE_IDENTITY();
        END

        -- C. Reissue the book
        -- Atomic Sync target member from MemberShip database if they don't exist locally
        EXEC dbo.sp_EnsureMemberExists @TargetMemberID;

        -- Inline validation for target member:
        -- Target member active?
        IF NOT EXISTS (SELECT 1 FROM dbo.Members WHERE MemberID=@TargetMemberID AND IsActive=1)
        BEGIN 
            ROLLBACK TRAN;
            SET @Msg='ERR:MEMBER_INACTIVE'; 
            RETURN; 
        END

        -- Priority check for reissue
        SET @BookID = (SELECT BookID FROM dbo.BookCopies WHERE CopyID = @CopyID);
        
        SELECT @AvailableCopies = COUNT(*)
        FROM dbo.BookCopies
        WHERE BookID = @BookID AND IsAvailable = 1 AND CondID NOT IN (5,6);
        
        IF @CondID NOT IN (5,6)
        BEGIN
            SET @AvailableCopies = @AvailableCopies + 1;
        END

        SELECT @MemberRank = MemberRank
        FROM (
            SELECT MemberID, ROW_NUMBER() OVER (ORDER BY QueuePos, ReservedAt) as MemberRank
            FROM dbo.Reservations
            WHERE BookID = @BookID AND StatusID = 1
        ) t
        WHERE MemberID = @TargetMemberID;

        SELECT @TotalActiveReservations = COUNT(*)
        FROM dbo.Reservations
        WHERE BookID = @BookID AND StatusID = 1;

        SET @IsAllowedReissue = 0;
        IF @MemberRank IS NOT NULL AND @MemberRank <= @AvailableCopies
        BEGIN
            SET @IsAllowedReissue = 1;
        END
        ELSE IF @MemberRank IS NULL AND @AvailableCopies > @TotalActiveReservations
        BEGIN
            SET @IsAllowedReissue = 1;
        END

        IF @IsAllowedReissue = 0
        BEGIN
            ROLLBACK TRAN;
            
            SELECT TOP 1 @ResHolderName = m.FullName, @ResHolderNo = m.MembershipNo
            FROM dbo.Reservations r
            JOIN dbo.Members m ON r.MemberID = m.MemberID
            WHERE r.BookID = @BookID AND r.StatusID = 1
            ORDER BY r.QueuePos, r.ReservedAt;
            
            IF @ResHolderName IS NOT NULL
                SET @Msg = 'ERR:RESERVED_FOR_OTHER:' + @ResHolderName + ' (' + @ResHolderNo + ')';
            ELSE
                SET @Msg = 'ERR:RESERVED_FOR_OTHER:Another Member';
                
            RETURN;
        END

        -- Borrow limit check (excluding the current loan that we just closed!)
        DECLARE @Active INT, @MaxBooks TINYINT;
        SELECT @Active = COUNT(*) FROM dbo.Loans
        WHERE  MemberID=@TargetMemberID AND StatusID IN (1,3,4);   -- Issued/Overdue/Renewed

        SELECT @MaxBooks = COALESCE(m.MaxBooksOverride, mt.MaxBooks)
        FROM   dbo.Members m JOIN dbo.MemberTypes mt ON m.MTypeID=mt.MTypeID
        WHERE  m.MemberID=@TargetMemberID;

        IF @Active >= @MaxBooks
        BEGIN 
            ROLLBACK TRAN;
            SET @Msg='ERR:BORROW_LIMIT:' + CAST(@MaxBooks AS VARCHAR); 
            RETURN; 
        END

        -- Fine ceiling check for target member.
        -- Note: If target member is the returning member, we just paid/collected the fine.
        -- But let's check total unpaid fines.
        DECLARE @FineCeiling DECIMAL(8,2), @UnpaidFines DECIMAL(8,2);
        SELECT @FineCeiling = CAST(SVal AS DECIMAL(8,2)) FROM dbo.Settings WHERE SKey='FineCeiling';
        SELECT @UnpaidFines = ISNULL(SUM(FineAmount),0) FROM dbo.Fines
        WHERE  MemberID=@TargetMemberID AND IsPaid=0;

        IF @UnpaidFines >= @FineCeiling
        BEGIN 
            ROLLBACK TRAN;
            SET @Msg='ERR:UNPAID_FINES:' + CAST(@UnpaidFines AS VARCHAR); 
            RETURN; 
        END

        -- Standard duration
        DECLARE @LoanDays INT;
        SELECT @LoanDays = CAST(SVal AS INT) FROM dbo.Settings WHERE SKey='LoanDays';

        DECLARE @ActualIssueDate DATETIME = COALESCE(@IssueDate, SYSDATETIME());
        DECLARE @ActualDueDate DATE = COALESCE(@DueDate, DATEADD(DAY, @LoanDays, CAST(GETDATE() AS DATE)));

        -- Insert new loan
        INSERT INTO dbo.Loans (MemberID, CopyID, IssueDate, DueDate, StatusID, IssuedByID)
        VALUES (@TargetMemberID, @CopyID, @ActualIssueDate, @ActualDueDate, 1, @StaffID);

        -- Keep copy unavailable
        UPDATE dbo.BookCopies SET IsAvailable=0 WHERE CopyID=@CopyID;

        -- Fulfill any active reservation for this target member and book
        UPDATE dbo.Reservations
        SET StatusID = 2, NotifiedAt = COALESCE(NotifiedAt, SYSDATETIME())
        WHERE MemberID = @TargetMemberID AND BookID = @BookID AND StatusID = 1;

        -- Re-sequence remaining active reservations for this book
        WITH CTE AS (
            SELECT QueuePos, ROW_NUMBER() OVER (ORDER BY QueuePos, ReservedAt) as NewPos
            FROM dbo.Reservations
            WHERE BookID = @BookID AND StatusID = 1
        )
        UPDATE CTE SET QueuePos = NewPos;

    COMMIT TRAN;

    -- Return success message with fine and due date details
    IF @Fine > 0
    BEGIN
        IF @CollectFines = 1
            SET @Msg = 'OK:REISSUED:FINE_PAID:' + CAST(@Fine AS VARCHAR(12)) + ':DUE:' + CONVERT(VARCHAR, @ActualDueDate, 106);
        ELSE
            SET @Msg = 'OK:REISSUED:FINE_UNPAID:' + CAST(@Fine AS VARCHAR(12)) + ':DUE:' + CONVERT(VARCHAR, @ActualDueDate, 106);
    END
    ELSE
    BEGIN
        SET @Msg = 'OK:REISSUED:NO_FINE:DUE:' + CONVERT(VARCHAR, @ActualDueDate, 106);
    END
END;
GO

-- =============================================================================
--  10. sp_SearchBooksAdvanced  — Advanced catalogue search (custom Google-like)
CREATE OR ALTER PROCEDURE dbo.sp_SearchBooksAdvanced
    @Term       NVARCHAR(200) = NULL,   -- Global Google-like keyword
    @Author     NVARCHAR(100) = NULL,   -- Specific Author
    @BookName   NVARCHAR(200) = NULL,   -- Specific Title
    @Edition    NVARCHAR(50)  = NULL,   -- Specific Edition
    @PubID      SMALLINT      = NULL,   -- Specific Publisher
    @CatID      SMALLINT      = NULL,   -- Specific Category
    @LangID     TINYINT       = NULL,   -- Specific Language
    @Year       SMALLINT      = NULL,   -- Specific Year
    @DDC        NVARCHAR(100) = NULL,   -- Specific DDC
    @BookNo     INT           = NULL    -- Specific BookNo
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Parse keywords from @Term
    DECLARE @Keywords TABLE (Keyword VARCHAR(100) NOT NULL);
    IF @Term IS NOT NULL
    BEGIN
        INSERT INTO @Keywords (Keyword)
        SELECT DISTINCT TRIM(value)
        FROM STRING_SPLIT(REPLACE(REPLACE(@Term, '+', ' '), ',', ' '), ' ')
        WHERE TRIM(value) <> '';
    END

    -- 2. Build initial candidate list
    CREATE TABLE #MatchedIDs (BookID INT PRIMARY KEY);

    DECLARE @FirstKeyword NVARCHAR(100) = NULL;
    SELECT TOP 1 @FirstKeyword = Keyword FROM @Keywords;

    IF @FirstKeyword IS NOT NULL
    BEGIN
        -- If there's a search term, populate temp table with books matching the first keyword & other criteria
        INSERT INTO #MatchedIDs (BookID)
        SELECT b.BookID
        FROM dbo.Books b
        WHERE b.IsActive = 1
          AND (@CatID IS NULL OR b.CatID = @CatID)
          AND (@LangID IS NULL OR b.LangID = @LangID)
          AND (@PubID IS NULL OR b.PubID = @PubID)
          AND (@Year IS NULL OR b.PublishYear = @Year)
          AND (@DDC IS NULL OR b.DDC LIKE '%' + @DDC + '%')
          AND (@Edition IS NULL OR b.Edition LIKE '%' + @Edition + '%')
          AND (@BookName IS NULL OR b.Title LIKE '%' + @BookName + '%')
          AND (@Author IS NULL OR EXISTS (
              SELECT 1 FROM BookAuthors ba
              JOIN Authors a ON ba.AuthorID = a.AuthorID
              WHERE ba.BookID = b.BookID AND a.FullName LIKE '%' + @Author + '%'
          ))
          AND (@BookNo IS NULL OR EXISTS (
              SELECT 1 FROM BookCopies cp
              WHERE cp.BookID = b.BookID AND cp.BookNo = @BookNo
          ))
          -- Match first keyword
          AND (
              b.Title LIKE '%' + @FirstKeyword + '%'
              OR COALESCE(b.SubTitle, '') LIKE '%' + @FirstKeyword + '%'
              OR b.ISBN13 LIKE '%' + @FirstKeyword + '%'
              OR REPLACE(REPLACE(b.ISBN13, '-', ''), ' ', '') LIKE '%' + REPLACE(REPLACE(@FirstKeyword, '-', ''), ' ', '') + '%'
              OR COALESCE(b.CoverFile, '') LIKE '%' + @FirstKeyword + '%'
              OR COALESCE(b.Tags, '') LIKE '%' + @FirstKeyword + '%'
              OR COALESCE(b.DDC, '') LIKE '%' + @FirstKeyword + '%'
              OR EXISTS (
                  SELECT 1 FROM BookAuthors ba
                  JOIN Authors a ON ba.AuthorID = a.AuthorID
                  WHERE ba.BookID = b.BookID AND a.FullName LIKE '%' + @FirstKeyword + '%'
              )
          )
        OPTION (RECOMPILE);
    END
    ELSE
    BEGIN
        -- No search term, just insert all active books matching the other criteria
        INSERT INTO #MatchedIDs (BookID)
        SELECT b.BookID
        FROM dbo.Books b
        WHERE b.IsActive = 1
          AND (@CatID IS NULL OR b.CatID = @CatID)
          AND (@LangID IS NULL OR b.LangID = @LangID)
          AND (@PubID IS NULL OR b.PubID = @PubID)
          AND (@Year IS NULL OR b.PublishYear = @Year)
          AND (@DDC IS NULL OR b.DDC LIKE '%' + @DDC + '%')
          AND (@Edition IS NULL OR b.Edition LIKE '%' + @Edition + '%')
          AND (@BookName IS NULL OR b.Title LIKE '%' + @BookName + '%')
          AND (@Author IS NULL OR EXISTS (
              SELECT 1 FROM BookAuthors ba
              JOIN Authors a ON ba.AuthorID = a.AuthorID
              WHERE ba.BookID = b.BookID AND a.FullName LIKE '%' + @Author + '%'
          ))
          AND (@BookNo IS NULL OR EXISTS (
              SELECT 1 FROM BookCopies cp
              WHERE cp.BookID = b.BookID AND cp.BookNo = @BookNo
          ))
        OPTION (RECOMPILE);
    END

    -- 3. Filter by subsequent keywords sequentially
    DECLARE @kw NVARCHAR(100);
    DECLARE kw_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT Keyword FROM @Keywords WHERE Keyword <> @FirstKeyword;

    OPEN kw_cursor;
    FETCH NEXT FROM kw_cursor INTO @kw;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DELETE m
        FROM #MatchedIDs m
        WHERE NOT EXISTS (
            SELECT 1
            FROM dbo.Books b
            WHERE b.BookID = m.BookID
              AND (
                  b.Title LIKE '%' + @kw + '%'
                  OR b.SubTitle LIKE '%' + @kw + '%'
                  OR b.ISBN13 LIKE '%' + @kw + '%'
                  OR REPLACE(REPLACE(b.ISBN13, '-', ''), ' ', '') LIKE '%' + REPLACE(REPLACE(@kw, '-', ''), ' ', '') + '%'
                  OR b.CoverFile LIKE '%' + @kw + '%'
                  OR b.Tags LIKE '%' + @kw + '%'
                  OR b.DDC LIKE '%' + @kw + '%'
                  OR EXISTS (
                      SELECT 1 FROM BookAuthors ba
                      JOIN Authors a ON ba.AuthorID = a.AuthorID
                      WHERE ba.BookID = b.BookID AND a.FullName LIKE '%' + @kw + '%'
                  )
              )
        )
        OPTION (RECOMPILE);

        FETCH NEXT FROM kw_cursor INTO @kw;
    END

    CLOSE kw_cursor;
    DEALLOCATE kw_cursor;

    -- 4. Select the final details from vw_Books for matched IDs only
    SELECT
        v.BookID, v.ISBN13, v.ISBN13Fmt, v.Title, v.SubTitle,
        v.Edition, v.PublishYear, v.CatName, v.PubName, v.LangName,
        v.CoverFile, v.TotalCopies, v.AvailableCopies, v.ClassNo, v.DDC,
        v.IsReference, v.IsAdults, v.IsChildren, v.BookNo,
        -- Authors concatenated for display
        (SELECT STRING_AGG(a.FullName + CASE WHEN ar.RoleID <> 1
                THEN ' (' + ar.RoleName + ')' ELSE '' END, ', ')
                WITHIN GROUP (ORDER BY ba.SortOrder)
         FROM   BookAuthors ba
         JOIN   Authors a  ON ba.AuthorID = a.AuthorID
         JOIN   AuthorRoles ar ON ba.RoleID = ar.RoleID
         WHERE  ba.BookID = v.BookID)                       AS Authors,
        -- First rack address
        (SELECT TOP 1 ro.FullAddress
         FROM   BookCopies cp
         JOIN   vw_RackOccupancy ro ON cp.RackID = ro.RackID
         WHERE  cp.BookID = v.BookID
         ORDER  BY cp.CopyID)                               AS PrimaryLocation
    FROM vw_Books v
    JOIN #MatchedIDs m ON v.BookID = m.BookID
    ORDER BY v.Title
    OPTION (RECOMPILE);

    DROP TABLE #MatchedIDs;
END;
GO

PRINT '=== All stored procedures created successfully ===';
GO
