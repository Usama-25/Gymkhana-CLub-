USE GymkhanaLibraryDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- Reset tables to prevent duplicates and constraint violations
DELETE FROM Fines;
DELETE FROM Loans;
DELETE FROM Reservations;
DELETE FROM Members;

-- Re-insert members with correct shared MemberID values
SET IDENTITY_INSERT Members ON;

INSERT INTO Members (MemberID, MembershipNo, FullName, CNIC, Phone, Email, MTypeID, JoinDate, IsActive) VALUES
(80486, 'N-11992', N'Ahmed Raza Khan',        '42101-1234567-1','0300-1234567','ahmed@email.com',2, '2024-01-15', 1),
(57450, 'R-8407',  N'Sara Aslam Malik',       NULL,            '0321-9876543', NULL,            1, '2024-03-20', 1),
(81815, 'R-14873', N'Tariq Mahmood',          '42301-7654321-3','0333-1122334', NULL,           5, '2024-05-10', 1),
(75875, 'R-12608', N'Ayesha Farooq',          '35202-8765432-2','0311-5544332','ayesha@g.com', 3, '2024-08-05', 1);

SET IDENTITY_INSERT Members OFF;

DECLARE @LoanID1 INT, @LoanID2 INT, @LoanID3 INT;

-- Insert mock loans using correct shared MemberIDs
-- Ahmed Raza Khan (80486), Copy 1 (Ice-Candy-Man) - Returned
INSERT INTO Loans (MemberID, CopyID, IssueDate, DueDate, ReturnDate, RenewalCount, StatusID, IssuedByID, ReturnedByID)
VALUES (80486, 1, '2026-05-01 10:00:00', '2026-05-15', '2026-05-14 16:30:00', 0, 2, 2, 2);
SET @LoanID1 = SCOPE_IDENTITY();

-- Sara Aslam Malik (57450), Copy 3 (Reluctant Fundamentalist) - Issued (Active)
INSERT INTO Loans (MemberID, CopyID, IssueDate, DueDate, ReturnDate, RenewalCount, StatusID, IssuedByID)
VALUES (57450, 3, '2026-06-01 11:15:00', '2026-06-15', NULL, 0, 1, 2);
SET @LoanID2 = SCOPE_IDENTITY();

-- Ayesha Farooq (75875), Copy 5 (1984) - Overdue
INSERT INTO Loans (MemberID, CopyID, IssueDate, DueDate, ReturnDate, RenewalCount, StatusID, IssuedByID)
VALUES (75875, 5, '2026-05-10 09:00:00', '2026-05-24', NULL, 0, 3, 2);
SET @LoanID3 = SCOPE_IDENTITY();

-- Update availability in BookCopies (Sara Malik's copy and Ayesha's copy are currently out)
UPDATE BookCopies SET IsAvailable = 1; -- Reset all to available first
UPDATE BookCopies SET IsAvailable = 0 WHERE CopyID IN (3, 5);

-- Insert mock fines
-- Ahmed Raza Khan (80486) - Paid fine
INSERT INTO Fines (LoanID, MemberID, FineAmount, ReasonID, IsPaid, CreatedAt, PaidAt, CollectedByID)
VALUES (@LoanID1, 80486, 50.00, 1, 1, '2026-05-14 16:30:00', '2026-05-14 16:35:00', 2);

-- Ayesha Farooq (75875) - Unpaid fine
INSERT INTO Fines (LoanID, MemberID, FineAmount, ReasonID, IsPaid, CreatedAt)
VALUES (@LoanID3, 75875, 150.00, 1, 0, '2026-05-25 08:00:00');

PRINT '=== Mock transactions updated with shared member IDs successfully ===';
GO
