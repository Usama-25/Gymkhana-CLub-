using System;
using System.Configuration;
using System.Data;             // Added for CommandType
using System.Data.SqlClient;
using System.Web.UI;

public partial class MembershipProfile : System.Web.UI.Page
{
    private string cs
    {
        get
        {
            var s = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
            return s != null ? s.ConnectionString : "";
        }
    }
    private SqlConnection con { get { return new SqlConnection(cs); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            decimal feeAmount;

            if (decimal.TryParse(txtPrice.Text, out feeAmount) && feeAmount > 0)
            {
                btnSearch.Visible = false;
            }
            else
            {
                btnSearch.Visible = true;
            }
            int id;
            if (int.TryParse(Request.QueryString["id"], out id))
            {
                LoadMemberFeeDetails(id);
                LoadMemberFeeOnly(id);
            }
            else
            {
                lblMessage.Text = "⚠ Invalid ID!";
                lblMessage.ForeColor = System.Drawing.Color.Red;
            }
        }
    }

    private void LoadMemberFeeOnly(int id)
    {
        using (SqlCommand cmd = new SqlCommand(@"
            SELECT 
                (SELECT SUM(MemberFee) FROM MemberFee WHERE TrackId = t.id) as TotalFee,
                (SELECT COUNT(*) FROM MemberFee WHERE TrackId = t.id) as PaidCount,
                t.Price,
                t.Status
            FROM FormPurchase t
            WHERE t.id = @id", con))
        {
            cmd.Parameters.AddWithValue("@id", id);
            con.Open();

            using (SqlDataReader reader = cmd.ExecuteReader())
            {
                if (reader.Read())
                {
                    decimal totalFee = reader["TotalFee"] != DBNull.Value ? Convert.ToDecimal(reader["TotalFee"]) : 0;
                    int paidCount = reader["PaidCount"] != DBNull.Value ? Convert.ToInt32(reader["PaidCount"]) : 0;
                    decimal formPrice = reader["Price"] != DBNull.Value ? Convert.ToDecimal(reader["Price"]) : 0;
                    string status = reader["Status"] != DBNull.Value ? reader["Status"].ToString() : "";

                    if (status.Equals("Paid", StringComparison.OrdinalIgnoreCase))
                    {
                        txtPrice.Text = totalFee.ToString();
                        txtPrice.ReadOnly = true;
                        txtPrice.CssClass += " bg-gray-100 cursor-not-allowed";
                        btnSearch.Enabled = false;
                        btnSearch.ToolTip = "Payment already completed.";
                        lblMessage.Text = "✅ This form is already marked as PAID.";
                        lblMessage.ForeColor = System.Drawing.Color.Green;
                    }
                    else if (paidCount > 0)
                    {
                        // Some payments exist but not full/marked paid
                        txtPrice.Text = "0"; // Don't pre-fill total again
                        txtPrice.ReadOnly = false;
                        txtPrice.CssClass = txtPrice.CssClass.Replace("bg-gray-100", "").Replace("cursor-not-allowed", "");
                        lblMessage.Text = "ℹ Partial payment of Rs. " + totalFee + " already received.";
                        lblMessage.ForeColor = System.Drawing.Color.Blue;
                    }
                    else
                    {
                        // Fallback to FormPurchase Price if no payments exist
                        txtPrice.Text = formPrice.ToString();
                        txtPrice.ReadOnly = false;
                        txtPrice.CssClass = txtPrice.CssClass.Replace("bg-gray-100", "").Replace("cursor-not-allowed", "");
                    }
                }
            }
            con.Close();
        }
    }

    protected void ddlMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        SetPaymentFields(ddlMode.SelectedValue);
    }

    private void LoadMemberFeeDetails(int id)
    {
        string query = "SELECT PurchaseBy, MemberFee, Mode, BankAccount, CashType, ChequeNo, Status FROM FormPurchase WHERE id = @id";

        using (SqlCommand cmd = new SqlCommand(query, con))
        {
            cmd.Parameters.AddWithValue("@id", id);
            con.Open();

            using (SqlDataReader reader = cmd.ExecuteReader())
            {
                if (reader.Read())
                {

                    lblPurchaseBy.Text = reader["PurchaseBy"].ToString();
                    //txtPrice.Text = reader["MemberFee"] != DBNull.Value ? reader["MemberFee"].ToString() : "";

                    string mode = reader["Mode"] != DBNull.Value ? reader["Mode"].ToString() : "Cash";
                    ddlMode.SelectedValue = mode;

                    string status = reader["Status"] != DBNull.Value ? reader["Status"].ToString() : "";

                    SetPaymentFields(mode);

                    if (mode == "Cash")
                        ddlCashType.SelectedValue = reader["CashType"] != DBNull.Value ? reader["CashType"].ToString() : "PettyCash";
                    else if (mode == "Cheque")
                        txtCheque.Text = reader["ChequeNo"] != DBNull.Value ? reader["ChequeNo"].ToString() : "";
                    else if (mode == "Online")
                        txtBankAccount.Text = reader["BankAccount"] != DBNull.Value ? reader["BankAccount"].ToString() : "";

                    if (status.Equals("Paid", StringComparison.OrdinalIgnoreCase))
                    {
                        btnSearch.Enabled = false;
                        Button1.Enabled = false; // Disable Add Installment if needed? User said "does not allow to pay again"
                    }
                }
                else
                {
                    lblMessage.Text = "⚠ No record found for this ID!";
                    lblMessage.ForeColor = System.Drawing.Color.Orange;
                }
            }

            con.Close();
        }
    }

    private void SetPaymentFields(string mode)
    {
        pnlCash.Visible = false;
        pnlCheque.Visible = false;
        pnlOnline.Visible = false;

        if (mode == "Cash")
        {
            pnlCash.Visible = true;
        }
        else if (mode == "Cheque")
        {
            pnlCheque.Visible = true;
        }
        else if (mode == "Online")
        {
            pnlOnline.Visible = true;
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        int id;
        if (!int.TryParse(Request.QueryString["ID"], out id))
        {
            lblMessage.Text = "⚠ Invalid ID!";
            lblMessage.ForeColor = System.Drawing.Color.Red;
            return;
        }

        // Double check status before saving
        using (SqlCommand cmdCheck = new SqlCommand("SELECT Status FROM FormPurchase WHERE id = @id", con))
        {
            cmdCheck.Parameters.AddWithValue("@id", id);
            con.Open();
            object statusObj = cmdCheck.ExecuteScalar();
            con.Close();
            if (statusObj != null && statusObj.ToString().Equals("Paid", StringComparison.OrdinalIgnoreCase))
            {
                lblMessage.Text = "⛔ Already Paid. Payment cannot be processed again.";
                lblMessage.ForeColor = System.Drawing.Color.Red;
                btnSearch.Enabled = false;
                return;
            }
        }

        decimal feeAmount;
        if (!decimal.TryParse(txtPrice.Text, out feeAmount) || feeAmount <= 0)
        {
            lblMessage.Text = "⚠ Enter a valid positive fee amount.";
            lblMessage.ForeColor = System.Drawing.Color.Red;
            return;
        }

        string mode = ddlMode.SelectedValue;
        string cashTypeValue = null;
        string chequeValue = null;
        string onlineValue = null;

        if (mode == "Cash")
            cashTypeValue = ddlCashType.SelectedValue;
        else if (mode == "Cheque")
            chequeValue = txtCheque.Text.Trim();
        else if (mode == "Online")
            onlineValue = txtBankAccount.Text.Trim();

        using (SqlCommand cmd = new SqlCommand("InsertMemberFee", con))
        {
            cmd.CommandType = System.Data.CommandType.StoredProcedure;

            cmd.Parameters.AddWithValue("@TrackId", id);
            cmd.Parameters.AddWithValue("@MemberFee", feeAmount);
            cmd.Parameters.AddWithValue("@Mode", mode);
            cmd.Parameters.AddWithValue("@CashType", (object)cashTypeValue ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ChequeNo", (object)chequeValue ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@BankAccount", (object)onlineValue ?? DBNull.Value);

            con.Open();
            cmd.ExecuteNonQuery(); // just insert, no need to read
            con.Close();

            UpdateFormPurchaseStatus(id, "Paid");
        }


        lblMessage.Text = "✅ Fee received successfully!";
        lblMessage.ForeColor = System.Drawing.Color.LimeGreen;

        string receiptNo = GenerateNextReceiptNo();
        string script = string.Format("window.open('MemberFeeReceipt.aspx?id={0}&type=Form&receipt={1}', '_blank');", id, receiptNo);
        ScriptManager.RegisterStartupScript(this, this.GetType(), "openReport", script, true);
        
        // Update the MemberFee record with the unique receipt number
        UpdateMemberFeeReceiptNo(id, receiptNo);

        // Refresh UI state
        LoadMemberFeeOnly(id);
    }

    private void UpdateMemberFeeReceiptNo(int trackId, string receiptNo)
    {
        using (SqlConnection conn = new SqlConnection(cs))
        {
            // Update the most recent MemberFee record for this trackId
            string query = @"
                UPDATE MemberFee 
                SET ReciptNo = @ReceiptNo 
                WHERE id = (SELECT TOP 1 id FROM MemberFee WHERE TrackId = @TrackId ORDER BY id DESC)";
            
            SqlCommand cmd = new SqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@ReceiptNo", receiptNo);
            cmd.Parameters.AddWithValue("@TrackId", trackId);
            
            conn.Open();
            cmd.ExecuteNonQuery();
            conn.Close();
        }
    }

    private string GenerateNextReceiptNo()
    {
        using (SqlConnection conn = new SqlConnection(cs))
        {
            string datePrefix = DateTime.Now.ToString("yyyyMMdd");
            string searchPattern = "RCPT-" + datePrefix + "-%";
            
            string query = @"
                SELECT TOP 1 ReciptNo 
                FROM MemberFee 
                WHERE ReciptNo LIKE @Pattern 
                ORDER BY ReciptNo DESC";
            
            SqlCommand cmd = new SqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@Pattern", searchPattern);
            
            conn.Open();
            object result = cmd.ExecuteScalar();
            conn.Close();
            
            int nextIncremental = 1;
            if (result != null && result != DBNull.Value)
            {
                string lastReceipt = result.ToString();
                string[] parts = lastReceipt.Split('-');
                int lastNum;
                if (parts.Length == 3 && int.TryParse(parts[2], out lastNum))
                {
                    nextIncremental = lastNum + 1;
                }
            }
            
            return string.Format("RCPT-{0}-{1:D6}", datePrefix, nextIncremental);
        }
    }

    private void UpdateFormPurchaseStatus(int id, string status)
    {
        string cs = this.cs;
        using (SqlConnection con = new SqlConnection(cs))
        {
            string query = "UPDATE FormPurchase SET Status = @Status WHERE Id = @Id";
            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@Status", status);
            cmd.Parameters.AddWithValue("@Id", id);
            con.Open();
            cmd.ExecuteNonQuery();
        }
    }


    protected void UpdateInstallment_Click(object sender, EventArgs e)
    {
        decimal installment;
        if (!decimal.TryParse(txtInstallment.Text, out installment))
        {
            lblMessage.Text = "⚠ Enter a valid fee amount.";
            lblMessage.ForeColor = System.Drawing.Color.Red;
            return;
        }

        int trackId;
        if (!int.TryParse(Request.QueryString["id"], out trackId))
        {
            lblMessage.Text = "⚠ Invalid ID!";
            lblMessage.ForeColor = System.Drawing.Color.Red;
            return;
        }

        decimal currentTotal = 0;

        using (SqlConnection con = new SqlConnection(this.cs))
        {
            con.Open();

            // 1️⃣ Get current total MemberFee from FormPurchase
            using (SqlCommand cmdTotal = new SqlCommand("SELECT ISNULL(MemberFee, 0) FROM FormPurchase WHERE ID = @TrackId", con))
            {
                cmdTotal.Parameters.AddWithValue("@TrackId", trackId);
                currentTotal = Convert.ToDecimal(cmdTotal.ExecuteScalar());
            }

            // 2️⃣ Insert new installment in MemberFee table
            using (SqlCommand cmdInsert = new SqlCommand("InsertMemberFee", con))
            {
                cmdInsert.CommandType = System.Data.CommandType.StoredProcedure;
                cmdInsert.Parameters.AddWithValue("@TrackId", trackId);
                cmdInsert.Parameters.AddWithValue("@MemberFee", installment);
                cmdInsert.Parameters.AddWithValue("@Mode", "Cash"); // Can add dropdown later for Cash/Cheque/Online
                cmdInsert.Parameters.AddWithValue("@CashType", DBNull.Value);
                cmdInsert.Parameters.AddWithValue("@ChequeNo", DBNull.Value);
                cmdInsert.Parameters.AddWithValue("@BankAccount", DBNull.Value);

                cmdInsert.ExecuteNonQuery();
            }

            // 3️⃣ Update total MemberFee in FormPurchase
            using (SqlCommand cmdUpdate = new SqlCommand("UPDATE FormPurchase SET MemberFee = @TotalFee WHERE ID = @TrackId", con))
            {
                cmdUpdate.Parameters.AddWithValue("@TotalFee", currentTotal + installment);
                cmdUpdate.Parameters.AddWithValue("@TrackId", trackId);
                cmdUpdate.ExecuteNonQuery();
            }

            con.Close();
        }

        lblMessage.Text = "✅ Installment saved successfully!";
        lblMessage.ForeColor = System.Drawing.Color.LimeGreen;

        txtInstallment.Text = "";
        
        // Refresh the Main Fee Amount (Show the SUM, not the old value)
        LoadMemberFeeOnly(trackId);
        
        string receiptNo = GenerateNextReceiptNo();
        UpdateMemberFeeReceiptNo(trackId, receiptNo);

        string script = string.Format("window.open('MemberFeeReceipt.aspx?id={0}&type=Installment&receipt={1}', '_blank'); hideModal();", trackId, receiptNo);
        ScriptManager.RegisterStartupScript(this, this.GetType(), "openReportInstallment", script, true);
    }



}
