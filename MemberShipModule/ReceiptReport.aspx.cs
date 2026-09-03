using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

public partial class Finance_ReceiptReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string receiptNo = Request.QueryString["ReceiptNo"];

        if (string.IsNullOrEmpty(receiptNo))
        {
            Response.Write("No receipt number provided.");
            Response.End();
            return;
        }

        LoadReceiptData(receiptNo);
    }

    private void LoadReceiptData(string receiptNo)
    {
        string finConn = ConfigurationManager.ConnectionStrings["Finance_ConnectionString"].ConnectionString;

        using (SqlConnection con = new SqlConnection(finConn))
        {
            con.Open();

            // SQL query with MembersList calculation and totals
            // Note: We use ContactPerson as MemberName if we don't have a join to MemberProfile here.
            string sql = @"
    WITH ReceiptData AS (
        SELECT 
            m.ReceiptNo,
            m.ReceiptType,
            m.ReceiptDate,
            m.PaymentReference,
            m.BankPercent,
            m.BankAmount AS TotalBankAmount,
            m.Notes,
            s.MemberNo,
            s.ContactPerson,
            s.ContactPerson AS MemberName, -- Fallback to ContactPerson
            s.CNIC,
            s.Phone,
            s.ReceiptAmount,
            s.BankAmount AS MemberBankAmount,
            s.TotalAmount,
            cc.CostCenterName,
            rm.ReceiptMode,
            e.EFName AS EmployeeName,
            m.ReceiptMainID
        FROM MemberReceipts_Main m
        INNER JOIN MemberReceipts_Sub s ON m.ReceiptMainID = s.ReceiptMainID
        INNER JOIN CostCenter cc ON m.CostCenterID = cc.CostCenterID
        INNER JOIN ReceiptModes rm ON m.ReceiptModeID = rm.ReceiptModeID
        LEFT JOIN BasicDataInfo.dbo.Employee e ON m.EmpId = e.EmpID
        WHERE m.ReceiptNo = @ReceiptNo
    )
    SELECT 
        rd.*,
        -- Get comma-separated list of all members for this receipt
        STUFF((
            SELECT ', ' + MemberNo 
            FROM MemberReceipts_Sub 
            WHERE ReceiptMainID = rd.ReceiptMainID 
            FOR XML PATH('')
        ), 1, 2, '') AS MembersList,
        -- Get total receipt amount (sum of all member receipt amounts)
        (SELECT SUM(ReceiptAmount) FROM MemberReceipts_Sub WHERE ReceiptMainID = rd.ReceiptMainID) AS TotalReceiptSum,
        -- Get total bank amount (from main table)
        rd.TotalBankAmount AS TotalBankAmount2,
        -- Get grand total (sum of all member totals)
        (SELECT SUM(TotalAmount) FROM MemberReceipts_Sub WHERE ReceiptMainID = rd.ReceiptMainID) AS GrandTotal
    FROM ReceiptData rd";

            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@ReceiptNo", receiptNo);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];

                    // Receipt No & Date
                    litReceiptNo.Text = dr["ReceiptNo"].ToString();
                    litDate.Text = Convert.ToDateTime(dr["ReceiptDate"]).ToString("dd-MMM-yyyy");

                    // Totals
                    decimal totalReceiptSum = ConvertDecimal(dr["TotalReceiptSum"]);
                    decimal totalBankAmount = ConvertDecimal(dr["TotalBankAmount"]);
                    decimal grandTotal = ConvertDecimal(dr["GrandTotal"]);

                    litReceiptAmount.Text = FormatPKR(totalReceiptSum);
                    litBankAmt.Text = FormatPKR(totalBankAmount);
                    litNetAmount.Text = FormatPKR(grandTotal);

                    // Amount in words
                    litAmountWords.Text = AmountToWords((long)Math.Round(grandTotal)) + " Only";

                    // Payment mode and reference
                    litPaymentMode.Text = dr["ReceiptMode"].ToString();
                    // litReceiptAgainst.Text = dr["PaymentReference"].ToString(); // MOVED BELOW
                    litReceivedFrom.Text = dr["PaymentReference"].ToString(); // Payment Ref goes to Received From

                    // Received From
                    string contactPerson = dr["ContactPerson"] != DBNull.Value ? dr["ContactPerson"].ToString() : "";
                    string membersList = dr["MembersList"] != DBNull.Value ? dr["MembersList"].ToString() : "";

                    if (!string.IsNullOrEmpty(membersList))
                    {
                        litReceiptAgainst.Text = string.Format("{0} ({1})", contactPerson, membersList);
                    }
                    else
                    {
                        litReceiptAgainst.Text = contactPerson;
                    }

                    // On Account of
                    litPayHead.Text = dr["CostCenterName"].ToString();

                    // Received By
                    litReceivedBy.Text = dr["EmployeeName"] != DBNull.Value ? dr["EmployeeName"].ToString() : "";

                    // Footer left
                    if (!string.IsNullOrEmpty(membersList))
                    {
                        litFooterLeft.Text = string.Format("{0}, {1}",
                            DateTime.Now.ToString("MM/dd/yyyy, h:mm:ss tt"),
                            membersList);
                    }
                    else
                    {
                        litFooterLeft.Text = DateTime.Now.ToString("MM/dd/yyyy, h:mm:ss tt");
                    }

                    // Bind Members Grid
                    gvMembers.DataSource = dt;
                    gvMembers.DataBind();

                    // Set dynamic title
                    litReportTitle.Text = GetReceiptTypeText(dr["ReceiptType"]) + " Receipt";

                    ViewState["ReceiptType"] = dr["ReceiptType"].ToString();

                    // ── Update Grid Headers based on Type & Data ──
                    UpdateGridHeaders(dr["ReceiptType"].ToString(), dt);
                }
                else
                {
                    Response.Write("Receipt not found.");
                    Response.End();
                }
            }
        }
    }

    private void UpdateGridHeaders(string type, DataTable dt)
    {
        if (gvMembers.Columns.Count < 5) return;

        // Default Header Labels
        string col0 = "Member No/Ref#";
        string col1 = "Name";
        string col2 = "Amount";
        string col3 = "Bank Charges";
        string col4 = "Total";

        switch (type)
        {
            case "2": // New Memberships
                col0 = "Applicant No";
                col1 = "Applicant Name";
                col2 = "Registration Fee";
                break;
            case "4": // Other
                col0 = "Reference No";
                col1 = "Name";
                col2 = "Misc. Amount";
                break;
            case "5": // Guest Room
                col0 = "Member No";
                col1 = "Guest Name";
                col2 = "Room Rent";
                break;
        }

        gvMembers.Columns[0].HeaderText = col0;
        gvMembers.Columns[1].HeaderText = col1;
        gvMembers.Columns[2].HeaderText = col2;
        gvMembers.Columns[3].HeaderText = col3;
        gvMembers.Columns[4].HeaderText = col4;

        // Check if Bank Charges column should be visible (if any row has bank charges > 0)
        bool hasBankCharges = false;
        foreach (DataRow row in dt.Rows)
        {
            if (ConvertDecimal(row["MemberBankAmount"]) > 0)
            {
                hasBankCharges = true;
                break;
            }
        }
        gvMembers.Columns[3].Visible = hasBankCharges;
    }

    // Helper for safe decimal conversion
    private decimal ConvertDecimal(object obj)
    {
        if (obj == null || obj == DBNull.Value) return 0;
        return Convert.ToDecimal(obj);
    }

    /// <summary>Formats as Pakistani style: 15,000/-</summary>
    private string FormatPKR(decimal amount)
    {
        return string.Format("{0:N0}/-", amount);
    }

    /// <summary>Converts a number to English words (up to crores).</summary>
    private string AmountToWords(long number)
    {
        if (number == 0) return "Zero";

        string[] ones = { "", "One", "Two", "Three", "Four", "Five", "Six", "Seven",
                          "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen",
                          "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen" };
        string[] tens = { "", "", "Twenty", "Thirty", "Forty", "Fifty",
                          "Sixty", "Seventy", "Eighty", "Ninety" };

        if (number < 0) return "Minus " + AmountToWords(-number);
        if (number < 20) return ones[number];
        if (number < 100)
            return tens[number / 10] + (number % 10 > 0 ? " " + ones[number % 10] : "");
        if (number < 1000)
            return ones[number / 100] + " Hundred"
                   + (number % 100 > 0 ? " " + AmountToWords(number % 100) : "");
        if (number < 100000)
            return AmountToWords(number / 1000) + " Thousand"
                   + (number % 1000 > 0 ? " " + AmountToWords(number % 1000) : "");
        if (number < 10000000)
            return AmountToWords(number / 100000) + " Lakh"
                   + (number % 100000 > 0 ? " " + AmountToWords(number % 100000) : "");

        return AmountToWords(number / 10000000) + " Crore"
               + (number % 10000000 > 0 ? " " + AmountToWords(number % 10000000) : "");
    }
    // Helper to get text representation of Receipt Type
    public string GetReceiptTypeText(object receiptType)
    {
        if (receiptType == null || receiptType == DBNull.Value) return "Receipt";

        switch (receiptType.ToString())
        {
            case "1": return "Billing / Membership";
            case "2": return "New Membership";
            case "3": return "Activity / Event";
            case "4": return "Other";
            case "5": return "Guest Room";
            default: return "Receipt";
        }
    }
}
