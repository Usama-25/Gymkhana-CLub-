using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;

public partial class GymkhanaStatement : Page
{
    string conMember = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;
    string conRestaurant = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;

    // ── Page Load ────────────────────────────────────────────────────────────
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["Emp_Id"] == null)
            Response.Redirect("/Login.aspx");

        // ── Autocomplete AJAX request ─────────────────────────────────────
        // Called by JS: GymkhanaStatement.aspx?ac=1&q=P-61
        if (Request.QueryString["ac"] == "1"
            && Request.Headers["X-Requested-With"] == "XMLHttpRequest")
        {
            HandleAutoComplete();
            Response.End();
            return;
        }

        // Set default date range on first load: 1st of current month → today
        if (!IsPostBack)
        {
            DateTime now = DateTime.Now;
            txtDateFrom.Text = new DateTime(now.Year, now.Month, 1).ToString("yyyy-MM-dd");
            txtDateTo.Text = now.ToString("yyyy-MM-dd");
        }
    }

    // ── Autocomplete JSON handler ────────────────────────────────────────────
    // Returns: [{"MemberNo":"P-6158","MemberName":"Mr. John Smith"}, ...]
    private void HandleAutoComplete()
    {
        string q = (Request.QueryString["q"] ?? "").Trim();
        var results = new List<object>();

        if (q.Length >= 1)
        {
            // Search by MemberNo prefix OR MemberName contains
            string sql =
                "SELECT TOP 10 MemberNo, " +
                "LTRIM(RTRIM(ISNULL(Title,'') + ' ' + ISNULL(MemberName,''))) AS MemberName " +
                "FROM MemberProfile " +
                "WHERE IsActive = 1 " +
                "  AND (MemberNo LIKE @q + '%' OR MemberName LIKE '%' + @q + '%') " +
                "ORDER BY MemberNo";

            using (SqlConnection con = new SqlConnection(conMember))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@q", q);
                con.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                    while (dr.Read())
                        results.Add(new
                        {
                            MemberNo = dr["MemberNo"].ToString(),
                            MemberName = dr["MemberName"].ToString()
                        });
            }
        }

        Response.ContentType = "application/json";
        Response.Write(new JavaScriptSerializer().Serialize(results));
    }

    // ── Search Button ────────────────────────────────────────────────────────
    protected void btnSearch_Click(object sender, EventArgs e)
    {
        lblError.Text = "";
        string memberNo = txtMemberNo.Text.Trim().ToUpper();

        if (string.IsNullOrEmpty(memberNo))
        {
            lblError.Text = "⚠ Please enter a Membership No.";
            return;
        }

        // Parse date range — fall back to current month if blank/invalid
        DateTime dateFrom, dateTo;
        if (!DateTime.TryParse(txtDateFrom.Text, out dateFrom))
            dateFrom = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
        if (!DateTime.TryParse(txtDateTo.Text, out dateTo))
            dateTo = DateTime.Now;

        // Make dateTo inclusive (end of the selected day)
        dateTo = dateTo.Date.AddDays(1).AddSeconds(-1);

        // 1. Member profile
        DataRow member = GetMemberProfile(memberNo);
        if (member == null)
        {
            lblError.Text = "❌ Member not found: " + memberNo;
            pnlStatement.Visible = false;
            pnlEmpty.Visible = true;
            return;
        }

        // 2. Subscription detail for chosen period
        DataRow subs = GetSubscriptionDetail(memberNo, dateFrom, dateTo);

        // 3. Transaction ledger for chosen period
        DataTable transactions = GetTransactions(memberNo, dateFrom, dateTo);

        // 4. Account summary
        decimal prevBalance = GetPreviousBalance(memberNo);
        decimal paymentRec = GetTransactionSum(transactions, "Credit");
        decimal billAmount = GetTransactionSum(transactions, "Debit");
        decimal adjustments = 0;
        decimal dueAmount = prevBalance + billAmount - paymentRec + adjustments;

        // 5. Running balance
        decimal bbf = prevBalance;
        decimal running = bbf;
        foreach (DataRow row in transactions.Rows)
        {
            running += -Convert.ToDecimal(row["Debit"]) + Convert.ToDecimal(row["Credit"]);
            row["RunningBalance"] = running;
        }

        // 6. Bind
        BindMeta(member, memberNo, dateFrom, dateTo);
        BindAccountSummary(prevBalance, paymentRec, billAmount, adjustments, dueAmount);
        BindSubscriptionDetail(subs);
        BindTransactions(transactions, bbf, dueAmount);
        BindPaymentSlip(member, memberNo, dueAmount);

        pnlStatement.Visible = true;
        pnlEmpty.Visible = false;
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  DATA ACCESS
    // ══════════════════════════════════════════════════════════════════════════

    private DataRow GetMemberProfile(string memberNo)
    {
        string sql = @"
            SELECT TOP 1
                MemberNo,
                ISNULL(LTRIM(RTRIM(ISNULL(Title,'') + ' ' + ISNULL(MemberName,''))), '') AS MemberName,
                ISNULL(Address, '')             AS Address,
                ISNULL(ResidentialAddress1, '') AS ResidentialAddress1,
                ISNULL(City, '')                AS City,
                ISNULL(Phone, '')               AS Phone,
                ISNULL(Mobile, '')              AS Mobile,
                ISNULL(CreditLimit, 0)          AS CreditLimit
            FROM MemberProfile
            WHERE MemberNo = @MemberNo
              AND IsActive = 1";

        using (SqlConnection con = new SqlConnection(conMember))
        using (SqlCommand cmd = new SqlCommand(sql, con))
        {
            cmd.Parameters.AddWithValue("@MemberNo", memberNo);
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            return dt.Rows.Count > 0 ? dt.Rows[0] : null;
        }
    }

    // Subscription amounts aggregated from Bills for the selected date range
    private DataRow GetSubscriptionDetail(string memberNo, DateTime from, DateTime to)
    {
        string sql = @"
            SELECT
                ISNULL(SUM(CASE WHEN DepartmentID = 1  THEN ISNULL(FinalAmount,Total) ELSE 0 END), 0) AS GeneralSub,
                ISNULL(SUM(CASE WHEN DepartmentID = 2  THEN ISNULL(FinalAmount,Total) ELSE 0 END), 0) AS LibrarySub,
                ISNULL(SUM(CASE WHEN DepartmentID = 3  THEN ISNULL(FinalAmount,Total) ELSE 0 END), 0) AS FilmSub,
                ISNULL(SUM(CASE WHEN DepartmentID = 4  THEN ISNULL(FinalAmount,Total) ELSE 0 END), 0) AS MusicalEve,
                ISNULL(SUM(CASE WHEN DepartmentID = 5  THEN ISNULL(FinalAmount,Total) ELSE 0 END), 0) AS Utilities,
                ISNULL(SUM(CASE WHEN DepartmentID = 6  THEN ISNULL(FinalAmount,Total) ELSE 0 END), 0) AS WelfareFund,
                ISNULL(SUM(CASE WHEN DepartmentID = 7  THEN ISNULL(FinalAmount,Total) ELSE 0 END), 0) AS DevFund,
                ISNULL(SUM(CASE WHEN DepartmentID = 8  THEN ISNULL(FinalAmount,Total) ELSE 0 END), 0) AS SportTotal,
                ISNULL(SUM(CASE WHEN DepartmentID = 10 THEN ISNULL(FinalAmount,Total) ELSE 0 END), 0) AS Sports,
                ISNULL(SUM(CASE WHEN DepartmentID = 11 THEN ISNULL(FinalAmount,Total) ELSE 0 END), 0) AS SportsSubs,
                ISNULL(SUM(CASE WHEN DepartmentID = 12 THEN ISNULL(FinalAmount,Total) ELSE 0 END), 0) AS GST,
                ISNULL(SUM(CASE WHEN DepartmentID = 13 THEN ISNULL(FinalAmount,Total) ELSE 0 END), 0) AS Locker,
                ISNULL(SUM(CASE WHEN DepartmentID = 14 THEN ISNULL(FinalAmount,Total) ELSE 0 END), 0) AS Misc,
                ISNULL(SUM(ISNULL(FinalAmount,Total)), 0) AS GrandTotal,
                ISNULL(SUM(ISNULL(FinalAmount,Total)), 0) AS SubTotal
            FROM Bills
            WHERE MemberNo = @MemberNo
              AND CreatedAt >= @From
              AND CreatedAt <= @To";

        using (SqlConnection con = new SqlConnection(conRestaurant))
        using (SqlCommand cmd = new SqlCommand(sql, con))
        {
            cmd.Parameters.AddWithValue("@MemberNo", memberNo);
            cmd.Parameters.AddWithValue("@From", from);
            cmd.Parameters.AddWithValue("@To", to);
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            return dt.Rows.Count > 0 ? dt.Rows[0] : null;
        }
    }

    private decimal GetPreviousBalance(string memberNo)
    {
        // Resolve MemberID first (MemberBalance uses int FK, not card string)
        string sqlId = "SELECT TOP 1 MemberID FROM MemberProfile WHERE MemberNo = @MemberNo AND IsActive = 1";
        int memberId = 0;
        using (SqlConnection con = new SqlConnection(conMember))
        using (SqlCommand cmd = new SqlCommand(sqlId, con))
        {
            cmd.Parameters.AddWithValue("@MemberNo", memberNo);
            con.Open();
            object r = cmd.ExecuteScalar();
            if (r == null || r == DBNull.Value) return 0;
            memberId = Convert.ToInt32(r);
        }

        string sql = "SELECT ISNULL(Credit, 0) FROM MemberBalance WHERE MemberNo = @MemberID";
        using (SqlConnection con = new SqlConnection(conMember))
        using (SqlCommand cmd = new SqlCommand(sql, con))
        {
            cmd.Parameters.AddWithValue("@MemberID", memberId);
            con.Open();
            object r = cmd.ExecuteScalar();
            return r != null && r != DBNull.Value ? Convert.ToDecimal(r) : 0;
        }
    }

    // Transaction ledger filtered by the user-selected date range using CreatedAt
    private DataTable GetTransactions(string memberNo, DateTime from, DateTime to)
    {
        string sql = @"
            SELECT
                CreatedAt                                AS TxDate,
                ISNULL(DepartmentName, 'Bill')           AS Particulars,
                ISNULL(
                    CASE
                        WHEN PaymentMethod = 'Credit Card' AND CardNumber IS NOT NULL
                            THEN PaymentMethod + ' - ' + CardNumber
                        WHEN PaymentMethod IS NOT NULL
                            THEN PaymentMethod
                        ELSE ''
                    END, '')                             AS SubRef,
                ISNULL(KOT_Number, CAST(Id AS NVARCHAR)) AS Reference,
                CASE
                    WHEN Status = 'Paid' THEN 0
                    ELSE ISNULL(FinalAmount, Total)
                END                                      AS Debit,
                CASE
                    WHEN Status = 'Paid' THEN ISNULL(AmountPaid, 0)
                    ELSE 0
                END                                      AS Credit
            FROM Bills
            WHERE MemberNo = @MemberNo
              AND CreatedAt >= @From
              AND CreatedAt <= @To
            ORDER BY CreatedAt ASC, Id ASC";

        using (SqlConnection con = new SqlConnection(conRestaurant))
        using (SqlCommand cmd = new SqlCommand(sql, con))
        {
            cmd.Parameters.AddWithValue("@MemberNo", memberNo);
            cmd.Parameters.AddWithValue("@From", from);
            cmd.Parameters.AddWithValue("@To", to);
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            dt.Columns.Add("RunningBalance", typeof(decimal)); // added BEFORE Fill
            da.Fill(dt);
            return dt;
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  BIND HELPERS
    // ══════════════════════════════════════════════════════════════════════════

    private void BindMeta(DataRow member, string memberNo, DateTime from, DateTime to)
    {
        DateTime now = DateTime.Now;
        DateTime due = new DateTime(now.Year, now.Month, 1).AddMonths(2).AddDays(-1);

        string periodStr = from.ToString("dd-MMM-yyyy") + " → " + to.Date.ToString("dd-MMM-yyyy");

        litPeriodBadge.Text = periodStr;
        litMemberNo.Text = memberNo;
        litBillingMonth.Text = from.ToString("dd MMM") + " – " + to.Date.ToString("dd MMM yyyy");
        litStatementDate.Text = now.ToString("dd-MMM-yyyy");
        litDueDate.Text = due.ToString("dd-MMM-yyyy");
        litMemberName.Text = member["MemberName"].ToString().ToUpper();

        string addr = member["Address"].ToString().Trim();
        string city = member["City"].ToString().Trim();
        litAddress.Text = string.IsNullOrEmpty(city) ? addr : addr + ", " + city;

        string phone = member["Phone"].ToString().Trim();
        string mobile = member["Mobile"].ToString().Trim();
        litPhone.Text = !string.IsNullOrEmpty(mobile) ? mobile : phone;

        litMemberNoPill.Text = memberNo;
    }

    private void BindAccountSummary(decimal prev, decimal paid, decimal bill, decimal adj, decimal due)
    {
        litPrevBalance.Text = FormatN(prev);
        litPaymentReceived.Text = FormatN(paid);
        litBillAmount.Text = FormatN(bill);
        litAdjustments.Text = FormatN(adj);
        litDueAmount.Text = FormatN(due);
    }

    private void BindSubscriptionDetail(DataRow subs)
    {
        if (subs == null)
        {
            foreach (var lit in new[] { litGenSub, litLibSub, litFilmSub, litMusical,
                                        litUtilities, litWelfare, litDevFund, litSportTotal,
                                        litSubTotal, litSports, litSportsSubs, litGST,
                                        litLocker, litMisc, litGrandTotal })
                lit.Text = "—";
            return;
        }
        litGenSub.Text = FormatN(subs, "GeneralSub");
        litLibSub.Text = FormatN(subs, "LibrarySub");
        litFilmSub.Text = FormatN(subs, "FilmSub");
        litMusical.Text = FormatN(subs, "MusicalEve");
        litUtilities.Text = FormatN(subs, "Utilities");
        litWelfare.Text = FormatN(subs, "WelfareFund");
        litDevFund.Text = FormatN(subs, "DevFund");
        litSportTotal.Text = FormatN(subs, "SportTotal");
        litSubTotal.Text = FormatN(subs, "SubTotal");
        litSports.Text = FormatN(subs, "Sports");
        litSportsSubs.Text = FormatN(subs, "SportsSubs");
        litGST.Text = FormatN(subs, "GST");
        litLocker.Text = FormatN(subs, "Locker");
        litMisc.Text = FormatN(subs, "Misc");
        litGrandTotal.Text = FormatN(subs, "GrandTotal");
    }

    private void BindTransactions(DataTable dt, decimal bbf, decimal dueAmount)
    {
        litBBF.Text = FormatN(bbf);
        rptTransactions.DataSource = dt;
        rptTransactions.DataBind();
        litNoData.Text = dt.Rows.Count == 0
            ? "<tr class=\"no-data-row\"><td colspan=\"6\">No transactions found for this period.</td></tr>"
            : "";
        decimal closing = bbf;
        if (dt.Rows.Count > 0)
            closing = Convert.ToDecimal(dt.Rows[dt.Rows.Count - 1]["RunningBalance"]);
        litClosingBalance.Text = FormatN(closing);
    }

    private void BindPaymentSlip(DataRow member, string memberNo, decimal dueAmount)
    {
        litSlipMemberNo.Text = memberNo;
        litSlipName.Text = member["MemberName"].ToString().ToUpper();
        litSlipDate.Text = DateTime.Now.ToString("dd-MMM-yyyy");
        litSlipDueAmount.Text = FormatN(dueAmount);
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  UTILITIES
    // ══════════════════════════════════════════════════════════════════════════

    private decimal GetValue(DataRow row, string col)
    {
        if (row == null || !row.Table.Columns.Contains(col) || row[col] == DBNull.Value) return 0;
        return Convert.ToDecimal(row[col]);
    }

    private decimal GetTransactionSum(DataTable dt, string col)
    {
        if (dt == null || !dt.Columns.Contains(col)) return 0;
        decimal sum = 0;
        foreach (DataRow r in dt.Rows)
            if (r[col] != DBNull.Value) sum += Convert.ToDecimal(r[col]);
        return sum;
    }

    private string FormatN(decimal val) { return val.ToString("N0"); }
    private string FormatN(DataRow row, string col) { return FormatN(GetValue(row, col)); }
}