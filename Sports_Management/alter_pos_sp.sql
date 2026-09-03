ALTER PROCEDURE [sp_InsertPOSTransaction]
    @CustomerType NVARCHAR(50),
    @MemberID INT = NULL,
    @CustomerName NVARCHAR(150),
    @SubscriptionID INT,
    @Amount DECIMAL(18,2), -- Fee amount (Debit)
    @AmountPaid DECIMAL(18,2), -- Payment amount (Credit)
    @Remarks NVARCHAR(255) = 'POS Payment Received'
AS
BEGIN
    INSERT INTO POSTransactions (CustomerType, MemberID, CustomerName, SubscriptionID, Amount)
    VALUES (@CustomerType, @MemberID, @CustomerName, @SubscriptionID, @Amount);

    DECLARE @NewTransID INT = SCOPE_IDENTITY();

    -- If Member, post to Ledger
    IF @MemberID IS NOT NULL
    BEGIN
        DECLARE @Desc NVARCHAR(200)
        SELECT @Desc = 'POS Service - ' + sp.SportName + ' (' + s.PackageName + ')'
        FROM Subscriptions s INNER JOIN Sports sp ON s.SportID = sp.SportID
        WHERE s.SubscriptionID = @SubscriptionID;

        -- Debit (Charge for service)
        INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID)
        VALUES (@MemberID, GETDATE(), @Desc, @Amount, 0, 'POS', @NewTransID);

        -- Credit (If they paid any amount)
        IF @AmountPaid > 0
        BEGIN
            INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType, RefID)
            VALUES (@MemberID, GETDATE(), @Remarks, 0, @AmountPaid, 'POS_Pay', @NewTransID);
        END
    END

    -- Return the inserted TransactionID to show on receipt
    SELECT @NewTransID AS NewTransactionID;
END
GO
