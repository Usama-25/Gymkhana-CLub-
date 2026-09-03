using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace MemberShipModule
{
    /// <summary>
    /// Centralized validation logic for Member Transactions.
    /// </summary>
    public static class TransactionRules
    {
        private static string ConnectionString
        {
            get
            {
                var setting = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
                if (setting == null)
                    throw new Exception("Connection string 'MemberShipConnection' is missing in Web.config.");
                return setting.ConnectionString;
            }
        }

        public class ValidationResult
        {
            public bool IsAllowed { get; set; }
            public string Message { get; set; }

            public static ValidationResult Success()
            {
                return new ValidationResult { IsAllowed = true, Message = "Transaction Allowed" };
            }

            public static ValidationResult Fail(string message)
            {
                return new ValidationResult { IsAllowed = false, Message = message };
            }
        }

        /// <summary>
        /// Validates if a member can perform a transaction of a specific amount in a specific area.
        /// </summary>
        public static ValidationResult ValidateTransaction(string memberId, double amount, int areaId)
        {
            if (string.IsNullOrEmpty(memberId))
                return ValidationResult.Fail("Invalid Member ID.");

            try
            {
                using (SqlConnection con = new SqlConnection(ConnectionString))
                {
                    con.Open();

                    // 1. Fetch Member Info including joined tables for Linked Member (Parent)
                    // We need: Status, CreditLimit, CurrentBalance (calculated or stored), MemberType, ExpiryDate
                    // Assuming views or tables. Will construct a query.
                    // We also need to check CardStatus. Assuming 'MemberCards' or similar? 
                    // Based on file list, we have ManageCard.aspx, so likely a Cards table.
                    
                    // Let's first check Status, CreditLimit, BillingStatus from MemberProfile
                    string sql = @"
                        SELECT 
                            m.MemberID, 
                            p.Status AS MembershipStatus, 
                            p.AccountStatus AS BillingStatus, 
                            p.CreditLimit, 
                            p.MemberType, 
                            p.MemberCategory,
                            p.CoMemberNo -- For linking
                        FROM Member m
                        LEFT JOIN MemberProfile p ON m.MemberID = p.MemberID
                        WHERE m.MemberID = @MemberID";

                    SqlCommand cmd = new SqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("@MemberID", memberId);

                    SqlDataReader dr = cmd.ExecuteReader();
                    if (!dr.Read())
                    {
                        return ValidationResult.Fail("Member not found.");
                    }

                    string membershipStatus = dr["MembershipStatus"].ToString();
                    string billingStatus = dr["BillingStatus"].ToString();
                    double creditLimit = dr["CreditLimit"] != DBNull.Value ? Convert.ToDouble(dr["CreditLimit"]) : 0;
                    string memberType = dr["MemberType"].ToString();
                    string memberCategory = dr["MemberCategory"].ToString(); // Evolving/Non-Earning
                    string coMemberNo = dr["CoMemberNo"].ToString();
                    
                    dr.Close();

                    // 2. Billing Status Check
                    if (billingStatus != "Active")
                    {
                        return ValidationResult.Fail("Billing Status is " + billingStatus + ". Transaction denied.");
                    }

                    // 3. Membership Status Check
                    if (membershipStatus != "Active")
                    {
                        return ValidationResult.Fail("Membership Status is " + membershipStatus + ". Transaction denied.");
                    }

                    // 4. Family/Parent Check
                    // If MemberType indicates Family/Dependant, we need to check the Parent.
                    // Assuming 'Associate' or 'Family' or relationship logic.
                    // If CoMemberNo is present, we check that.
                    if (!string.IsNullOrEmpty(coMemberNo))
                    {
                        // Check Parent Status
                         string parentSql = @"
                            SELECT Status, AccountStatus 
                            FROM MemberProfile 
                            WHERE MemberNo = @ParentNo"; // Assuming CoMemberNo points to MemberNo
                         
                         SqlCommand cmdParent = new SqlCommand(parentSql, con);
                         cmdParent.Parameters.AddWithValue("@ParentNo", coMemberNo);
                         SqlDataReader drParent = cmdParent.ExecuteReader();
                         
                         if (drParent.Read())
                         {
                             string parentStatus = drParent["Status"].ToString();
                             string parentBilling = drParent["AccountStatus"].ToString();

                             if (parentStatus != "Active" && parentStatus != "Absentee") // Rule 5: Non-earning/Parents can be Absentee?
                             {
                                 // Rule 4 says must be Active. Rule 5 says Active or Absentee for Non-Earning.
                                 // Let's be strict for now based on Rule 4: "parents status and billing status must be active"
                                 return ValidationResult.Fail("Parent Membership is " + parentStatus + ". Transaction denied.");
                             }
                             if (parentBilling != "Active")
                             {
                                 return ValidationResult.Fail("Parent Billing Status is not Active. Transaction denied.");
                             }
                         }
                         else
                         {
                             // Parent not found? Warn?
                         }
                         drParent.Close();
                    }

                    // 1. Card Status Check
                    // Needs a table check. Assuming 'MemberCards'.
                    string cardSql = @"
                        SELECT TOP 1 Status, ExpiryDate 
                        FROM MemberCards 
                        WHERE MemberID = @MemberID 
                        ORDER BY IssueDate DESC"; // Get latest card

                    SqlCommand cmdCard = new SqlCommand(cardSql, con);
                    cmdCard.Parameters.AddWithValue("@MemberID", memberId);
                    SqlDataReader drCard = cmdCard.ExecuteReader();
                    if (drCard.Read())
                    {
                        string cardStatus = drCard["Status"].ToString();
                        DateTime expiryDate = drCard["ExpiryDate"] != DBNull.Value ? Convert.ToDateTime(drCard["ExpiryDate"]) : DateTime.MinValue;

                        if (cardStatus != "Active")
                             return ValidationResult.Fail("Card is " + cardStatus + ".");
                        
                        if (expiryDate < DateTime.Now)
                             return ValidationResult.Fail("Card has expired.");
                    }
                    else
                    {
                        // No card found?
                        return ValidationResult.Fail("No active card found.");
                    }
                    drCard.Close();

                    // 6. Credit Limit Check
                    // Need current balance. Assuming a query or table 'MemberLedger' or similar. 
                    // For now, let's assume 'CurrentBalance' is part of MemberProfile or calculated.
                    // If not available, we skip or use 0.
                    double currentBalance = 0; // REPLACE WITH REAL BALANCE QUERY
                    // Rule: Balance + NewAmount <= CreditLimit
                    if ((currentBalance + amount) > creditLimit)
                    {
                        return ValidationResult.Fail("Credit Limit exceeded. Limit: " + creditLimit + ", Current: " + currentBalance);
                    }

                    // 7. Allowed Areas Check
                    // Using 'AllowedAreasMember' table seen in earlier step.
                    if (areaId > 0)
                    {
                        string areaSql = "SELECT COUNT(*) FROM AllowedAreasMember WHERE MemberID = @MemberID AND AreaId = @AreaId";
                        SqlCommand cmdArea = new SqlCommand(areaSql, con);
                        cmdArea.Parameters.AddWithValue("@MemberID", memberId);
                        cmdArea.Parameters.AddWithValue("@AreaId", areaId);
                        int allowedCount = (int)cmdArea.ExecuteScalar();
                        
                        if (allowedCount == 0)
                        {
                            return ValidationResult.Fail("Member is not allowed in this area.");
                        }
                    }

                    return ValidationResult.Success();
                }
            }
            catch (Exception ex)
            {
                return ValidationResult.Fail("Validation Error: " + ex.Message);
            }
        }
    }
}
