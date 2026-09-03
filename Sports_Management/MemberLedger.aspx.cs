using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

public partial class MemberLedger : System.Web.UI.Page
{
    string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        lblMessage.Visible = false;
        pnlSearchResults.Visible = false;
        pnlLedgerArea.Visible = false;
        
        if (string.IsNullOrWhiteSpace(txtSearch.Text))
        {
            ShowMessage("Please enter a Member ID or Name to search.", false);
            return;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_SearchMembers", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SearchTerm", txtSearch.Text.Trim());

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            pnlSearchResults.Visible = true;
                            ddlMemberNames.Items.Clear();
                            ddlMemberNames.Items.Add(new ListItem("-- Select Member / Dependent --", "0"));

                            foreach (DataRow row in dt.Rows)
                            {
                                // Value will be MemberID|MembershipNo|FullName|Status|Relationship
                                string memberNo = row["MembershipNo"].ToString();
                                string rel = dt.Columns.Contains("Relationship") ? row["Relationship"].ToString() : "";
                                
                                if (string.IsNullOrEmpty(rel) || rel == "Self" || rel == "Dependent")
                                {
                                    rel = GetRelationFromMemberNo(memberNo);
                                }
                                
                                string val = row["MemberID"].ToString() + "|" + memberNo + "|" + row["FullName"].ToString() + "|" + row["Status"].ToString() + "|" + rel;
                                string text = row["MemberDisplay"].ToString();
                                ddlMemberNames.Items.Add(new ListItem(text, val));
                            }
                            
                            // If exactly one match, auto select it
                            if (dt.Rows.Count == 1)
                            {
                                ddlMemberNames.SelectedIndex = 1;
                                ddlMemberNames_SelectedIndexChanged(null, null);
                            }
                        }
                        else
                        {
                            ShowMessage("No member found with that criteria.", false);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error searching member: " + ex.Message, false);
        }
    }

    protected void ddlMemberNames_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlMemberNames.SelectedValue == "0")
        {
            pnlLedgerArea.Visible = false;
            return;
        }

        string[] parts = ddlMemberNames.SelectedValue.Split('|');
        if (parts.Length >= 5)
        {
            hfMemberID.Value = parts[0];
            lblMemberNo.Text = parts[1];
            lblMemberNoHeader.Text = parts[1];
            lblFullName.Text = parts[2];
            lblStatus.Text = parts[3];

            string relationship = parts[4];
            hfDependentRelation.Value = relationship;
            
            // Set dependent info based on relationship
            if (relationship != "Self")
            {
                hfDependentMemberNo.Value = parts[1]; // The dependent's own MembershipNo
                hfDependentName.Value = parts[2];      // The dependent's name
                lblRelationship.Text = relationship;
                lblRelationship.Style["background-color"] = "#dbeafe";
                lblRelationship.Style["color"] = "#1e40af";
            }
            else
            {
                hfDependentMemberNo.Value = "";
                hfDependentName.Value = "";
                lblRelationship.Text = "Self (Main Member)";
                lblRelationship.Style["background-color"] = "#d1fae5";
                lblRelationship.Style["color"] = "#065f46";
            }

            // Print header labels
            lblPrintMemberNo.Text = parts[1];
            lblPrintMemberName.Text = parts[2];

            pnlLedgerArea.Visible = true;
            
            // Pass DependentMemberNo for filtering (null for Self to show ALL entries)
            string depMemberNo = string.IsNullOrEmpty(hfDependentMemberNo.Value) ? null : hfDependentMemberNo.Value;
            LoadMemberLedger(Convert.ToInt32(hfMemberID.Value), depMemberNo);
        }
    }

    private void LoadMemberLedger(int memberId, string dependentMemberNo = null)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetMemberLedger", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@MemberID", memberId);
                    
                    if (!string.IsNullOrEmpty(dependentMemberNo))
                        cmd.Parameters.AddWithValue("@DependentMemberNo", dependentMemberNo);
                    
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        try
                        {
                            da.Fill(dt);
                        }
                        catch (SqlException ex)
                        {
                            if (ex.Number == 8144 || ex.Message.Contains("too many arguments"))
                            {
                                if (cmd.Parameters.Contains("@DependentMemberNo"))
                                {
                                    cmd.Parameters.Remove(cmd.Parameters["@DependentMemberNo"]);
                                    da.Fill(dt);
                                }
                                else throw;
                            }
                            else throw;
                        }

                        if (!dt.Columns.Contains("DependentRelation")) dt.Columns.Add("DependentRelation", typeof(string));
                        if (!dt.Columns.Contains("DependentName")) dt.Columns.Add("DependentName", typeof(string));
                        if (!dt.Columns.Contains("DependentMemberNo")) dt.Columns.Add("DependentMemberNo", typeof(string));

                        // Add RunningBalance column
                        dt.Columns.Add("RunningBalance", typeof(decimal));

                        decimal totalDebit = 0;
                        decimal totalCredit = 0;
                        decimal runningBal = 0;

                        foreach (DataRow row in dt.Rows)
                        {
                            decimal debit = Convert.ToDecimal(row["DebitAmount"]);
                            decimal credit = Convert.ToDecimal(row["CreditAmount"]);
                            totalDebit += debit;
                            totalCredit += credit;
                            runningBal += (debit - credit);
                            row["RunningBalance"] = runningBal;
                            
                            // Fill derived relationship if we have a DependentMemberNo but no Relation
                            string depMemberNo = row["DependentMemberNo"].ToString();
                            if (!string.IsNullOrEmpty(depMemberNo))
                            {
                                string rel = row["DependentRelation"].ToString();
                                if (string.IsNullOrEmpty(rel) || rel == "Self")
                                {
                                    row["DependentRelation"] = GetRelationFromMemberNo(depMemberNo);
                                }
                            }
                        }

                        decimal balance = totalDebit - totalCredit;

                        lblTotalDebit.Text = totalDebit.ToString("N0");
                        lblTotalCredit.Text = totalCredit.ToString("N0");

                        // Handle UI display for Balance vs Credit
                        if (balance > 0)
                        {
                            // Member owes money
                            divOutstanding.Visible = true;
                            divMemberCredit.Visible = false;
                            lblBalance.Text = balance.ToString("N0");
                        }
                        else if (balance < 0)
                        {
                            // Member has credit (paid in advance)
                            divOutstanding.Visible = false;
                            divMemberCredit.Visible = true;
                            lblMemberCredit.Text = Math.Abs(balance).ToString("N0");
                        }
                        else
                        {
                            // Zero balance
                            divOutstanding.Visible = true;
                            divMemberCredit.Visible = false;
                            lblBalance.Text = "0";
                        }

                        if (dt.Rows.Count > 0)
                        {
                            rptLedger.DataSource = dt;
                            rptLedger.DataBind();
                            rptLedger.Visible = true;
                            pnlNoRecords.Visible = false;
                        }
                        else
                        {
                            rptLedger.Visible = false;
                            pnlNoRecords.Visible = true;
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading ledger: " + ex.Message, false);
        }
    }

    // private void AutoGenerateBilling(int memberId)
    // {
    //     try
    //     {
    //         using (SqlConnection con = new SqlConnection(connString))
    //         {
    //             using (SqlCommand cmd = new SqlCommand("sp_AutoGenerateMemberBilling", con))
    //             {
    //                 cmd.CommandType = CommandType.StoredProcedure;
    //                 cmd.Parameters.AddWithValue("@MemberID", memberId);
    //
    //                 con.Open();
    //                 cmd.ExecuteNonQuery();
    //             }
    //         }
    //     }
    //     catch (Exception ex)
    //     {
    //         ShowMessage("Auto-billing error: " + ex.Message, false);
    //     }
    // }

    protected void btnAddPayment_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtPayAmount.Text) || string.IsNullOrWhiteSpace(txtPayDesc.Text))
        {
            ShowMessage("Please enter an amount and description.", false);
            return;
        }

        try
        {
            decimal amount = Convert.ToDecimal(txtPayAmount.Text);
            
            if (amount <= 0)
            {
                ShowMessage("Amount must be greater than zero.", false);
                return;
            }

            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_AddPayment", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@MemberID", hfMemberID.Value);
                    cmd.Parameters.AddWithValue("@Amount", amount);
                    cmd.Parameters.AddWithValue("@Description", txtPayDesc.Text.Trim());

                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            ShowMessage("Payment successfully posted to the ledger!", true);
            txtPayAmount.Text = "";
            txtPayDesc.Text = "";

            LoadMemberLedger(Convert.ToInt32(hfMemberID.Value));
        }
        catch (Exception ex)
        {
            ShowMessage("Error posting payment: " + ex.Message, false);
        }
    }

    protected void btnPostReversal_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(hfMemberID.Value))
        {
            ShowMessage("Please search and select a member first.", false);
            return;
        }

        try
        {
            decimal amount = Convert.ToDecimal(txtReversalAmount.Text);
            
            if (amount <= 0)
            {
                ShowMessage("Amount must be greater than zero.", false);
                return;
            }

            string type = ddlReversalType.SelectedValue;
            decimal debit = type == "Debit" ? amount : 0;
            decimal credit = type == "Credit" ? amount : 0;
            string desc = txtReversalDesc.Text.Trim();

            if (string.IsNullOrEmpty(desc))
                desc = "Manual Adjustment (" + type + ")";

            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = @"INSERT INTO LedgerEntries (MemberID, TransactionDate, Description, DebitAmount, CreditAmount, RefType) 
                               VALUES (@MemberID, GETDATE(), @Description, @DebitAmount, @CreditAmount, 'ManualAdjustment')";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@MemberID", hfMemberID.Value);
                    cmd.Parameters.AddWithValue("@Description", desc);
                    cmd.Parameters.AddWithValue("@DebitAmount", debit);
                    cmd.Parameters.AddWithValue("@CreditAmount", credit);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            ShowMessage("Manual adjustment successfully posted to the ledger!", true);
            txtReversalAmount.Text = "";
            txtReversalDesc.Text = "";

            LoadMemberLedger(Convert.ToInt32(hfMemberID.Value));
        }
        catch (Exception ex)
        {
            ShowMessage("Error posting adjustment: " + ex.Message, false);
        }
    }

    private void ShowMessage(string msg, bool isSuccess)
    {
        lblMessage.Visible = true;
        lblMessage.Text = msg;
        if (isSuccess)
        {
            lblMessage.Style["background-color"] = "#d4edda";
            lblMessage.Style["color"] = "#155724";
            lblMessage.Style["border"] = "1px solid #c3e6cb";
        }
        else
        {
            lblMessage.Style["background-color"] = "#f8d7da";
            lblMessage.Style["color"] = "#721c24";
            lblMessage.Style["border"] = "1px solid #f5c6cb";
        }
    }

    private string GetRelationFromMemberNo(string memberNo)
    {
        if (string.IsNullOrEmpty(memberNo)) return "Self";
        string upper = memberNo.ToUpper();
        int dashIndex = upper.LastIndexOf('-');
        if (dashIndex >= 0 && dashIndex < upper.Length - 1)
        {
            string suffix = upper.Substring(dashIndex + 1);
            if (suffix.StartsWith("W")) return "Spouse";
            if (suffix.StartsWith("H")) return "Husband";
            if (suffix.StartsWith("S")) return "Son";
            if (suffix.StartsWith("D")) return "Daughter";
        }
        return "Self";
    }
}
