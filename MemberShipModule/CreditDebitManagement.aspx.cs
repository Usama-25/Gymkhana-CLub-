using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class CreditDebitManagement : System.Web.UI.Page
{
    private string connStr
    {
        get
        {
            var s = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
            return s != null ? s.ConnectionString : "";
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
    }

    // Search Member
    protected void btnSearch_Click(object sender, EventArgs e)
    {
        string memberNo = txtMemberNo.Text.Trim();
        string memberName = txtMemberName.Text.Trim();

        if (string.IsNullOrEmpty(memberNo) && string.IsNullOrEmpty(memberName))
        {
            ShowMessage("Please enter Member No or Name to search.", false);
            return;
        }

        using (SqlConnection con = new SqlConnection(connStr))
        {
            string query = @"
                SELECT TOP 1 
                    m.MemberID, m.MemberNo, m.ApplicantName, m.MemberType, m.ApplicantPhotoPath,
                    ISNULL(TRY_CAST(mp.CreditLimit AS DECIMAL(18,2)), 0) AS CreditLimit,
                    c.CardNo
                FROM Member m
                LEFT JOIN MemberProfile mp ON CAST(m.MemberNo AS NVARCHAR(50)) = CAST(mp.MemberNo AS NVARCHAR(50))
                LEFT JOIN MemberIssueCard c ON m.MemberID = c.MemberID AND c.IsActive = 1
                WHERE 1=1";

            if (!string.IsNullOrEmpty(memberNo))
                query += " AND m.MemberNo = @MemberNo";
            if (!string.IsNullOrEmpty(memberName))
                query += " AND m.ApplicantName LIKE @MemberName";

            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                if (!string.IsNullOrEmpty(memberNo))
                    cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                if (!string.IsNullOrEmpty(memberName))
                    cmd.Parameters.AddWithValue("@MemberName", "%" + memberName + "%");

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    // Store member info
                    hfMemberId.Value = dr["MemberID"].ToString();
                    hfMemberNo.Value = dr["MemberNo"].ToString();
                    lblMemberName.Text = dr["ApplicantName"].ToString();
                    lblMemberNo.Text = dr["MemberNo"].ToString();
                    lblMemberType.Text = dr["MemberType"].ToString();
                    
                    // CreditLimit is now returned as decimal from SQL via TRY_CAST
                    decimal creditLimit = Convert.ToDecimal(dr["CreditLimit"]);
                    lblCreditLimit.Text = string.Format("Rs {0:N2}", creditLimit);

                    // Set photo
                    if (dr["ApplicantPhotoPath"] != DBNull.Value)
                    {
                        imgMemberPhoto.ImageUrl = ResolveUrl(dr["ApplicantPhotoPath"].ToString());
                    }
                    else
                    {
                        imgMemberPhoto.ImageUrl = "~/Images/user.png";
                    }

                    dr.Close();

                    // Refresh balance and history
                    LoadBalance();
                    LoadTransactionHistory();

                    pnlMemberDetails.Visible = true;
                    lblMessage.Text = "";
                }
                else
                {
                    pnlMemberDetails.Visible = false;
                    ShowMessage("No member found with the specified criteria.", false);
                }
            }
        }
    }

    // Load Member Balance
    private void LoadBalance()
    {
        string memberId = hfMemberId.Value;
        if (string.IsNullOrEmpty(memberId)) return;

        using (SqlConnection con = new SqlConnection(connStr))
        {
            // Fetch raw data - no conversions in SQL
            string query = @"
                SELECT Credit, Dept
                FROM MemberPayment
                WHERE MemberNo = @MemberId";

            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@MemberId", memberId);
                con.Open();
                
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                decimal totalCredit = 0;
                decimal totalDebit = 0;

                foreach (DataRow row in dt.Rows)
                {
                    string creditStr = row["Credit"].ToString() ?? "";  
                    string deptStr = row["Dept"].ToString() ?? "";

                    decimal creditVal = 0;
                    decimal debitVal = 0;

                    if (decimal.TryParse(creditStr, out creditVal))
                        totalCredit += creditVal;
                    if (decimal.TryParse(deptStr, out debitVal))
                        totalDebit += debitVal;
                }

                decimal balance = totalCredit - totalDebit;

                lblTotalCredit.Text = string.Format("Rs {0:N2}", totalCredit);
                lblTotalDebit.Text = string.Format("Rs {0:N2}", totalDebit);
                lblCurrentBalance.Text = string.Format("Rs {0:N2}", balance);
            }
        }
    }

    // Load Transaction History
    private void LoadTransactionHistory()
    {
        string memberId = hfMemberId.Value;
        if (string.IsNullOrEmpty(memberId)) return;

        string filterType = ddlFilterType.SelectedValue;

        using (SqlConnection con = new SqlConnection(connStr))
        {
            // Fetch raw data - no conversions in SQL
            string query = @"
                SELECT 
                    MemberNo,
                    Description,
                    Dept,
                    Credit
                FROM MemberPayment
                WHERE MemberNo = @MemberId";

            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@MemberId", memberId);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable rawDt = new DataTable();
                da.Fill(rawDt);

                // Create result table with formatted columns
                DataTable dt = new DataTable();
                dt.Columns.Add("TransactionType", typeof(string));
                dt.Columns.Add("Description", typeof(string));
                dt.Columns.Add("Department", typeof(string));
                dt.Columns.Add("Credit", typeof(string));
                dt.Columns.Add("DebitAmount", typeof(string));

                foreach (DataRow row in rawDt.Rows)
                {
                    string creditStr = row["Credit"].ToString() ?? "";
                    string deptStr = row["Dept"].ToString() ?? "";
                    string description = row["Description"].ToString() ?? "";

                    decimal creditVal = 0;
                    decimal debitVal = 0;

                    decimal.TryParse(creditStr, out creditVal);
                    decimal.TryParse(deptStr, out debitVal);

                    // Apply filters in C#
                    if (filterType == "Credit" && creditVal <= 0) continue;
                    if (filterType == "Debit" && debitVal <= 0) continue;

                    DataRow newRow = dt.NewRow();
                    newRow["TransactionType"] = creditVal > 0 ? "CREDIT" : "DEBIT";
                    newRow["Description"] = description;
                    newRow["Department"] = deptStr;
                    newRow["Credit"] = creditVal > 0 ? string.Format("Rs {0:N2}", creditVal) : "-";
                    newRow["DebitAmount"] = debitVal > 0 ? string.Format("Rs {0:N2}", debitVal) : "-";
                    dt.Rows.Add(newRow);
                }

                gvTransactions.DataSource = dt;
                gvTransactions.DataBind();
            }
        }
    }

    // Apply Filter
    protected void btnFilter_Click(object sender, EventArgs e)
    {
        LoadTransactionHistory();
    }

    // Show Message Helper
    private void ShowMessage(string message, bool isSuccess)
    {
        lblMessage.Text = message;
        lblMessage.CssClass = isSuccess 
            ? "mt-4 block text-center font-semibold text-success" 
            : "mt-4 block text-center font-semibold text-danger";
    }
}
