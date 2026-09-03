USE GymkhanaLibraryDB;
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
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
