USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

PRINT 'Altering stored procedure dbo.sp_GetActiveReservations to include BookNo, DDC and AcqNo...';
GO

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
        COALESCE(
            CAST((SELECT TOP 1 cp.BookNo FROM BookCopies cp WHERE cp.BookID = b.BookID AND cp.BookNo IS NOT NULL) AS VARCHAR(50)),
            b.AcqNo,
            CAST(b.BookID AS VARCHAR(50))
        ) AS BookNo,
        b.DDC,
        b.AcqNo,
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

PRINT 'dbo.sp_GetActiveReservations altered successfully.';
GO
