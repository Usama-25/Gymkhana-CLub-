using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class MemberStatementSummary_Page : System.Web.UI.Page
{
    string memberConnStr = ConfigurationManager.ConnectionStrings["MemberShipConnString"] != null 
        ? ConfigurationManager.ConnectionStrings["MemberShipConnString"].ConnectionString 
        : (ConfigurationManager.ConnectionStrings["MemberShipConnection"] != null 
            ? ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString 
            : "");

    private string GetBillingConnectionString()
    {
        if (ConfigurationManager.ConnectionStrings["MemberBillingConnection"] != null)
            return ConfigurationManager.ConnectionStrings["MemberBillingConnection"].ConnectionString;
        if (ConfigurationManager.ConnectionStrings["Member_Billing_ConnectionString"] != null)
            return ConfigurationManager.ConnectionStrings["Member_Billing_ConnectionString"].ConnectionString;
        if (ConfigurationManager.ConnectionStrings["MemberBillingConnectionString"] != null)
            return ConfigurationManager.ConnectionStrings["MemberBillingConnectionString"].ConnectionString;
        return memberConnStr;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            DateTime now = DateTime.Now;
            DateTime defaultStart = new DateTime(now.Year, now.Month, 1);
            DateTime defaultEnd = defaultStart.AddMonths(1).AddDays(-1);

            txtStartDate.Text = defaultStart.ToString("yyyy-MM-dd");
            txtEndDate.Text = defaultEnd.ToString("yyyy-MM-dd");

            if (!string.IsNullOrEmpty(Request.QueryString["memberNo"]))
            {
                txtMemberNo.Text = Request.QueryString["memberNo"].Trim();
                if (!string.IsNullOrEmpty(Request.QueryString["startDate"]))
                {
                    DateTime qsStart;
                    if (DateTime.TryParse(Request.QueryString["startDate"], out qsStart))
                        txtStartDate.Text = qsStart.ToString("yyyy-MM-dd");
                }
                if (!string.IsNullOrEmpty(Request.QueryString["endDate"]))
                {
                    DateTime qsEnd;
                    if (DateTime.TryParse(Request.QueryString["endDate"], out qsEnd))
                        txtEndDate.Text = qsEnd.ToString("yyyy-MM-dd");
                }

                btnSearch_Click(sender, e);
            }
        }

        UpdateDetailsLink();
    }

    private void UpdateDetailsLink()
    {
        string mNo = txtMemberNo.Text.Trim();
        string sDate = txtStartDate.Text.Trim();
        string eDate = txtEndDate.Text.Trim();
        lnkGoToDetails.NavigateUrl = "MemberStatementDetails.aspx?memberNo=" + Server.UrlEncode(mNo) + "&startDate=" + Server.UrlEncode(sDate) + "&endDate=" + Server.UrlEncode(eDate);
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        lblProcessMessage.Visible = false;
        string memberNo = txtMemberNo.Text.Trim();

        if (string.IsNullOrWhiteSpace(memberNo))
        {
            ShowMemberInfo("Please enter a Membership Number.", false);
            pnlStatement.Visible = false;
            return;
        }

        DateTime startDate, endDate;
        if (!DateTime.TryParse(txtStartDate.Text, out startDate))
        {
            ShowMemberInfo("Please enter a valid Start Date.", false);
            pnlStatement.Visible = false;
            return;
        }

        if (!DateTime.TryParse(txtEndDate.Text, out endDate))
        {
            ShowMemberInfo("Please enter a valid End Date.", false);
            pnlStatement.Visible = false;
            return;
        }

        if (startDate > endDate)
        {
            ShowMemberInfo("Start Date cannot be greater than End Date.", false);
            pnlStatement.Visible = false;
            return;
        }

        UpdateDetailsLink();

        // 1. Search member across MemberProfile, Member, MemberSpouses, MemberChildren
        string memberName = "";
        string memberAddress = "";
        string memberCity = "";
        string memberPhone = "";
        bool found = SearchMember(memberNo, out memberName, out memberAddress, out memberCity, out memberPhone);

        if (!found)
        {
            ShowMemberInfo("Member Not Found - '" + memberNo + "' was not found in MemberProfile or Member tables.", false);
            pnlStatement.Visible = false;
            return;
        }

        ShowMemberInfo("Member Found: " + memberNo + " - " + memberName, true);

        // 2. Load Summarized Statement
        LoadSummarizedStatement(memberNo, memberName, memberAddress, memberCity, memberPhone, startDate, endDate);
    }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        txtMemberNo.Text = "";
        DateTime now = DateTime.Now;
        DateTime defaultStart = new DateTime(now.Year, now.Month, 1);
        DateTime defaultEnd = defaultStart.AddMonths(1).AddDays(-1);

        txtStartDate.Text = defaultStart.ToString("yyyy-MM-dd");
        txtEndDate.Text = defaultEnd.ToString("yyyy-MM-dd");

        lblMemberInfo.Visible = false;
        lblProcessMessage.Visible = false;
        pnlStatement.Visible = false;
        UpdateDetailsLink();
    }

    // ═══════════════════════════════════════════════════════
    //  MEMBER SEARCH
    // ═══════════════════════════════════════════════════════
    private bool SearchMember(string memberNo, out string memberName, out string memberAddress, out string memberCity, out string memberPhone)
    {
        memberName = "";
        memberAddress = "";
        memberCity = "";
        memberPhone = "";

        using (SqlConnection con = new SqlConnection(memberConnStr))
        {
            con.Open();

            // Search MemberProfile first
            SqlCommand cmd = new SqlCommand(@"
                SELECT TOP 1
                    MemberName,
                    CASE 
                        WHEN ISNULL(MailingAddress1, '') <> '' THEN ISNULL(MailingAddress1, '') + ISNULL(', ' + NULLIF(MailingAddress2, ''), '')
                        WHEN ISNULL(ResidentialAddress1, '') <> '' THEN ISNULL(ResidentialAddress1, '') + ISNULL(', ' + NULLIF(ResidentialAddress2, ''), '')
                        WHEN ISNULL(OfficeAddress, '') <> '' THEN OfficeAddress
                        ELSE ''
                    END AS MemberAddress,
                    CASE 
                        WHEN ISNULL(MailingAddress1, '') <> '' THEN ISNULL(MailingCity, 'LAHORE')
                        WHEN ISNULL(ResidentialAddress1, '') <> '' THEN ISNULL(ResidentialCity, 'LAHORE')
                        WHEN ISNULL(OfficeAddress, '') <> '' THEN ISNULL(OfficeCity, 'LAHORE')
                        ELSE ISNULL(City, 'LAHORE')
                    END AS City,
                    ISNULL(Mobile, ISNULL(ResidentialPhone1, '')) AS Phone
                FROM MemberProfile
                WHERE MemberNo = @MemberNo", con);

            cmd.Parameters.AddWithValue("@MemberNo", memberNo);

            using (SqlDataReader rdr = cmd.ExecuteReader())
            {
                if (rdr.Read())
                {
                    memberName = rdr["MemberName"].ToString();
                    memberAddress = rdr["MemberAddress"].ToString();
                    memberCity = rdr["City"].ToString();
                    memberPhone = rdr["Phone"].ToString();
                    return true;
                }
            }

            // Search Member table
            SqlCommand cmdMember = new SqlCommand(@"
                SELECT TOP 1
                    ApplicantName AS MemberName,
                    ISNULL(Address, '') AS MemberAddress,
                    ISNULL(City, 'LAHORE') AS City,
                    ISNULL(Mobile, ISNULL(Phone, '')) AS Phone
                FROM Member
                WHERE MemberNo = @MemberNo
                ORDER BY MemberID DESC", con);

            cmdMember.Parameters.AddWithValue("@MemberNo", memberNo);

            using (SqlDataReader rdrM = cmdMember.ExecuteReader())
            {
                if (rdrM.Read())
                {
                    memberName = rdrM["MemberName"].ToString();
                    memberAddress = rdrM["MemberAddress"].ToString();
                    memberCity = rdrM["City"].ToString();
                    memberPhone = rdrM["Phone"].ToString();
                    return true;
                }
            }

            // Search MemberSpouses
            SqlCommand cmdSpouse = new SqlCommand(@"
                SELECT TOP 1 SpouseName AS MemberName, '' AS MemberAddress, '' AS City, ISNULL(SpousePhone, '') AS Phone
                FROM MemberSpouses WHERE MembershipNo = @MemberNo", con);
            cmdSpouse.Parameters.AddWithValue("@MemberNo", memberNo);
            using (SqlDataReader rdr2 = cmdSpouse.ExecuteReader())
            {
                if (rdr2.Read())
                {
                    memberName = rdr2["MemberName"].ToString();
                    memberPhone = rdr2["Phone"].ToString();
                    return true;
                }
            }

            // Search MemberChildren
            SqlCommand cmdChild = new SqlCommand(@"
                SELECT TOP 1 ChildName AS MemberName, '' AS MemberAddress, '' AS City, ISNULL(ChildPhone, '') AS Phone
                FROM MemberChildren WHERE MembershipNo = @MemberNo", con);
            cmdChild.Parameters.AddWithValue("@MemberNo", memberNo);
            using (SqlDataReader rdr3 = cmdChild.ExecuteReader())
            {
                if (rdr3.Read())
                {
                    memberName = rdr3["MemberName"].ToString();
                    memberPhone = rdr3["Phone"].ToString();
                    return true;
                }
            }
        }

        return false;
    }

    // ═══════════════════════════════════════════════════════
    //  LOAD SUMMARIZED STATEMENT
    // ═══════════════════════════════════════════════════════
    private void LoadSummarizedStatement(string memberNo, string memberName, string memberAddress, string memberCity, string memberPhone, DateTime startDate, DateTime endDate)
    {
        string billingConnStr = GetBillingConnectionString();
        string cleanMNo = memberNo.Replace("P-", "").Replace("R-", "").Replace("S-", "").Replace("I-", "").Trim();

        using (SqlConnection con = new SqlConnection(billingConnStr))
        {
            con.Open();

            // Populate header info
            litMembershipNo.Text = memberNo;
            if (startDate.Month == endDate.Month && startDate.Year == endDate.Year)
            {
                litBillingMonth.Text = startDate.ToString("MMM - yyyy");
            }
            else
            {
                litBillingMonth.Text = startDate.ToString("dd-MMM-yy") + " to " + endDate.ToString("dd-MMM-yy");
            }
            litStatementDate.Text = startDate.AddDays(-1).ToString("dd-MMM-yyyy");
            litDueDate.Text = endDate.ToString("dd-MMM-yyyy");
            litClosingDateLabel.Text = endDate.ToString("dd-MMM-yyyy");

            // Member address block
            litAddrMemberNo.Text = memberNo;
            litAddrName.Text = memberName;
            litAddrLine1.Text = memberAddress;
            litAddrLine2.Text = !string.IsNullOrEmpty(memberCity) ? memberCity : "";
            litAddrPhone.Text = memberPhone;

            // Load Member Profile ID & Category
            int memberProfileId = 0;
            int resolvedCatId = 0;
            int resolvedTypeId = 0;
            string resolvedCatName = "";
            string resolvedTypeName = "";
            int memberAge = 0;
            int membershipYears = 0;

            try
            {
                string sqlMemberInfo = @"
                    SELECT TOP 1
                        m.MemberType,
                        m.MemberShipCategory,
                        (SELECT TOP 1 id FROM FormTypeMain WHERE FormTypeName = m.MemberType OR FormTypeName = m.MemberShipCategory OR (LEN(m.MemberType) > 3 AND FormTypeName LIKE '%' + m.MemberType + '%') OR (LEN(m.MemberShipCategory) > 3 AND FormTypeName LIKE '%' + m.MemberShipCategory + '%')) AS CategoryID,
                        (SELECT TOP 1 FormTypeName FROM FormTypeMain WHERE FormTypeName = m.MemberType OR FormTypeName = m.MemberShipCategory OR (LEN(m.MemberType) > 3 AND FormTypeName LIKE '%' + m.MemberType + '%') OR (LEN(m.MemberShipCategory) > 3 AND FormTypeName LIKE '%' + m.MemberShipCategory + '%')) AS CategoryName,
                        (SELECT TOP 1 Id FROM MembershipType WHERE MembershipType = m.MemberShipCategory OR MembershipType = m.MemberType OR (LEN(m.MemberShipCategory) > 3 AND MembershipType LIKE '%' + m.MemberShipCategory + '%') OR (LEN(m.MemberType) > 3 AND MembershipType LIKE '%' + m.MemberType + '%')) AS MembershipTypeID,
                        (SELECT TOP 1 MembershipType FROM MembershipType WHERE MembershipType = m.MemberShipCategory OR MembershipType = m.MemberType OR (LEN(m.MemberShipCategory) > 3 AND MembershipType LIKE '%' + m.MemberShipCategory + '%') OR (LEN(m.MemberType) > 3 AND MembershipType LIKE '%' + m.MemberType + '%')) AS MembershipTypeName,
                        CASE WHEN m.DOB IS NOT NULL THEN DATEDIFF(YEAR, m.DOB, GETDATE()) 
                             WHEN p.DOB IS NOT NULL THEN DATEDIFF(YEAR, p.DOB, GETDATE()) 
                             ELSE 0 END AS Age,
                        CASE WHEN p.MemberSince IS NOT NULL THEN DATEDIFF(YEAR, p.MemberSince, GETDATE())
                             WHEN m.CreatedAt IS NOT NULL THEN DATEDIFF(YEAR, m.CreatedAt, GETDATE())
                             ELSE 0 END AS MemYears,
                        ISNULL(p.MemberID, 0) AS MemberProfileID
                    FROM Member m
                    LEFT JOIN MemberProfile p ON m.MemberNo = p.MemberNo
                    WHERE m.MemberNo = @MNo
                    ORDER BY m.MemberID DESC";

                using (SqlCommand cmdMI = new SqlCommand(sqlMemberInfo, con))
                {
                    cmdMI.Parameters.AddWithValue("@MNo", memberNo);
                    using (SqlDataReader rdrMI = cmdMI.ExecuteReader())
                    {
                        if (rdrMI.Read())
                        {
                            if (rdrMI["CategoryID"] != DBNull.Value) int.TryParse(rdrMI["CategoryID"].ToString(), out resolvedCatId);
                            if (rdrMI["CategoryName"] != DBNull.Value) resolvedCatName = rdrMI["CategoryName"].ToString().Trim();
                            if (rdrMI["MembershipTypeID"] != DBNull.Value) int.TryParse(rdrMI["MembershipTypeID"].ToString(), out resolvedTypeId);
                            if (rdrMI["MembershipTypeName"] != DBNull.Value) resolvedTypeName = rdrMI["MembershipTypeName"].ToString().Trim();
                            if (rdrMI["Age"] != DBNull.Value) int.TryParse(rdrMI["Age"].ToString(), out memberAge);
                            if (rdrMI["MemYears"] != DBNull.Value) int.TryParse(rdrMI["MemYears"].ToString(), out membershipYears);
                            if (rdrMI["MemberProfileID"] != DBNull.Value) int.TryParse(rdrMI["MemberProfileID"].ToString(), out memberProfileId);
                        }
                    }
                }
            }
            catch { }

            // Display Member Category, Type, Age
            string typeAndCatInfo = "";
            if (!string.IsNullOrEmpty(resolvedTypeName) || !string.IsNullOrEmpty(resolvedCatName))
            {
                typeAndCatInfo += "<div style='margin-top: 3px; font-weight: 600; color: #342867; font-size: 10px;'>";
                if (!string.IsNullOrEmpty(resolvedCatName)) typeAndCatInfo += "Category: " + resolvedCatName;
                if (!string.IsNullOrEmpty(resolvedTypeName)) typeAndCatInfo += (!string.IsNullOrEmpty(resolvedCatName) ? " | " : "") + "Type: " + resolvedTypeName;
                if (memberAge > 0) typeAndCatInfo += " | Age: " + memberAge + " Yrs";
                if (membershipYears > 0) typeAndCatInfo += " | Mem. Years: " + membershipYears;
                typeAndCatInfo += "</div>";
            }
            litMemberTypeAndCat.Text = typeAndCatInfo;

            // ── CHECK IF ANY PROCESS IS CHARGED IN THESE DATES ──
            // Criteria: In MemberBilling, IsCharged = 1 for any month falling within startDate and endDate
            DataTable dtChargedBills = new DataTable();
            DateTime filterStartMonth = new DateTime(startDate.Year, startDate.Month, 1);
            DateTime filterEndMonth = new DateTime(endDate.Year, endDate.Month, 1);

            string sqlCharged = @"
                SELECT BillingID, MemberNo, BillingMonth, StatementDate, DueDate,
                       PreviousBalance, PaymentReceived, BillAmount, Adjustments, DueAmount,
                       IsCharged, ChargedDate
                FROM MemberBilling
                WHERE MemberNo = @MemberNo
                  AND BillingMonth >= @StartMonth AND BillingMonth <= @EndMonth
                  AND IsCharged = 1
                ORDER BY BillingMonth ASC";

            using (SqlCommand cmdCh = new SqlCommand(sqlCharged, con))
            {
                cmdCh.Parameters.AddWithValue("@MemberNo", memberNo);
                cmdCh.Parameters.AddWithValue("@StartMonth", filterStartMonth);
                cmdCh.Parameters.AddWithValue("@EndMonth", filterEndMonth);
                new SqlDataAdapter(cmdCh).Fill(dtChargedBills);
            }

            bool hasChargedProcessInDates = (dtChargedBills.Rows.Count > 0);

            // ── FORCEFULLY GET BALANCE AS OF START DATE (OPENING) AND END DATE (CLOSING) ──
            decimal openingBalance = GetBalanceAsOfDate(con, memberNo, cleanMNo, startDate, true);
            decimal closingBalance = GetBalanceAsOfDate(con, memberNo, cleanMNo, endDate, false);
            decimal runningBalance = openingBalance;

            // ── LOAD BREAKDOWN OF TRANSACTIONS (SUMMARIZED) ──
            // Rule: ONLY show received payments and the bill charged for month which are in filters startdate and enddate
            DataTable dtTx = new DataTable();
            dtTx.Columns.Add("TransDate", typeof(DateTime));
            dtTx.Columns.Add("Particulars", typeof(string));
            dtTx.Columns.Add("Reference", typeof(string));
            dtTx.Columns.Add("Debit", typeof(decimal));
            dtTx.Columns.Add("Credit", typeof(decimal));
            dtTx.Columns.Add("SortKey", typeof(int));

            HashSet<string> seenTx = new HashSet<string>();
            decimal totalPaymentsInDateRange = 0;
            decimal totalChargedBillAmount = 0;
            decimal totalAdjustments = 0;

            // 1. Collect Received Payments between startDate and endDate
            // Source A: Finance / MemberReceipts_Main & Sub
            string finConnStr = ConfigurationManager.ConnectionStrings["FinanceConnectionString"] != null 
                ? ConfigurationManager.ConnectionStrings["FinanceConnectionString"].ConnectionString 
                : (ConfigurationManager.ConnectionStrings["Finance_ConnectionString"] != null 
                    ? ConfigurationManager.ConnectionStrings["Finance_ConnectionString"].ConnectionString 
                    : "");

            Action<SqlConnection> getReceipts = (dbCon) =>
            {
                try
                {
                    string sqlRec = @"
                        SELECT 
                            m.ReceiptDate,
                            m.ReceiptNo,
                            m.PaymentReference,
                            ISNULL(s.TotalAmount, s.ReceiptAmount) AS PaidAmount,
                            m.ReceiptType
                        FROM MemberReceipts_Main m
                        INNER JOIN MemberReceipts_Sub s ON m.ReceiptMainID = s.ReceiptMainID
                        WHERE (
                                s.MemberNo = @MNo OR s.MemberNo LIKE @MNo + '%' OR s.MemberNo LIKE '%' + @MNo + '%'
                                OR s.MemberNo = @CleanMNo OR s.MemberNo LIKE '%' + @CleanMNo + '%'
                                OR ISNULL(m.PaymentReference, '') LIKE '%' + @MNo + '%'
                                OR ISNULL(m.Notes, '') LIKE '%' + @MNo + '%'
                              )
                          AND m.ReceiptDate >= @StartDate AND m.ReceiptDate <= @EndDate";

                    using (SqlCommand cmdRec = new SqlCommand(sqlRec, dbCon))
                    {
                        cmdRec.Parameters.AddWithValue("@MNo", memberNo);
                        cmdRec.Parameters.AddWithValue("@CleanMNo", cleanMNo);
                        cmdRec.Parameters.AddWithValue("@StartDate", startDate);
                        cmdRec.Parameters.AddWithValue("@EndDate", endDate.AddDays(1).AddSeconds(-1));

                        using (SqlDataReader rdrRec = cmdRec.ExecuteReader())
                        {
                            while (rdrRec.Read())
                            {
                                string rType = rdrRec["ReceiptType"] != DBNull.Value ? rdrRec["ReceiptType"].ToString().Trim() : "";
                                if (rType == "2" || rType.Equals("New Memberships", StringComparison.OrdinalIgnoreCase))
                                    continue;

                                DateTime rDate = Convert.ToDateTime(rdrRec["ReceiptDate"]);
                                decimal paidAmt = SafeDecimal(rdrRec["PaidAmount"]);
                                if (paidAmt <= 0) continue;

                                string rNo = rdrRec["ReceiptNo"] != DBNull.Value ? rdrRec["ReceiptNo"].ToString().Trim() : "";
                                string pRef = rdrRec["PaymentReference"] != DBNull.Value ? rdrRec["PaymentReference"].ToString().Trim() : "";

                                string dedupeKey = "REC_" + rDate.ToString("yyyyMMdd") + "_" + rNo + "_" + paidAmt.ToString("0.##");
                                if (!seenTx.Contains(dedupeKey))
                                {
                                    seenTx.Add(dedupeKey);
                                    string part = "Payment Received - " + (string.IsNullOrEmpty(rNo) ? "Receipt" : rNo);
                                    if (!string.IsNullOrEmpty(pRef)) part += " (" + pRef + ")";
                                    string refNo = !string.IsNullOrEmpty(pRef) ? pRef : rNo;

                                    dtTx.Rows.Add(rDate, part, refNo, 0m, paidAmt, 1);
                                    totalPaymentsInDateRange += paidAmt;
                                }
                            }
                        }
                    }
                }
                catch { }
            };

            if (!string.IsNullOrEmpty(finConnStr))
            {
                try { using (SqlConnection fCon = new SqlConnection(finConnStr)) { fCon.Open(); getReceipts(fCon); } } catch { }
            }
            try { getReceipts(con); } catch { }

            // Source B: MemberPayment credit payments
            try
            {
                string sqlMP = @"
                    SELECT Date, Description, Credit
                    FROM MemberPayment
                    WHERE (MemberNo = @MNo OR MemberNo LIKE @MNo + '%' OR MemberNo LIKE '%' + @MNo + '%' OR MemberNo = @CleanMNo OR MemberNo LIKE '%' + @CleanMNo + '%')
                      AND Credit > 0
                      AND Date >= @StartDate AND Date <= @EndDate";

                using (SqlCommand cmdMP = new SqlCommand(sqlMP, con))
                {
                    cmdMP.Parameters.AddWithValue("@MNo", memberNo);
                    cmdMP.Parameters.AddWithValue("@CleanMNo", cleanMNo);
                    cmdMP.Parameters.AddWithValue("@StartDate", startDate);
                    cmdMP.Parameters.AddWithValue("@EndDate", endDate.AddDays(1).AddSeconds(-1));

                    using (SqlDataReader rdrMP = cmdMP.ExecuteReader())
                    {
                        while (rdrMP.Read())
                        {
                            DateTime pDate = Convert.ToDateTime(rdrMP["Date"]);
                            decimal cr = SafeDecimal(rdrMP["Credit"]);
                            string desc = rdrMP["Description"] != DBNull.Value && !string.IsNullOrWhiteSpace(rdrMP["Description"].ToString()) 
                                ? rdrMP["Description"].ToString().Trim() 
                                : "Payment Received";

                            string dedupeKey = "MP_" + pDate.ToString("yyyyMMdd") + "_" + cr.ToString("0.##");
                            if (!seenTx.Contains(dedupeKey))
                            {
                                seenTx.Add(dedupeKey);
                                dtTx.Rows.Add(pDate, desc, "", 0m, cr, 1);
                                totalPaymentsInDateRange += cr;
                            }
                        }
                    }
                }
            }
            catch { }

            // 2. Add Monthly Bill Charged for months which are charged in the filtered date range
            if (hasChargedProcessInDates)
            {
                foreach (DataRow bRow in dtChargedBills.Rows)
                {
                    DateTime bMonth = Convert.ToDateTime(bRow["BillingMonth"]);
                    decimal billAmt = SafeDecimal(bRow["BillAmount"]);
                    decimal adj = SafeDecimal(bRow["Adjustments"]);
                    totalChargedBillAmount += billAmt;
                    totalAdjustments += adj;

                    // The bill charge date is typically the last day of the billing month
                    DateTime chargeDate = new DateTime(bMonth.Year, bMonth.Month, 1).AddMonths(1).AddDays(-1);
                    if (chargeDate > endDate) chargeDate = endDate;
                    if (chargeDate < startDate) chargeDate = startDate;

                    string part = "Monthly Subscription - " + bMonth.ToString("MMM yyyy");
                    string refNo = bMonth.ToString("yyyy-MM");

                    dtTx.Rows.Add(chargeDate, part, refNo, billAmt, 0m, 2);

                    if (adj != 0)
                    {
                        string adjPart = "Adjustments - " + bMonth.ToString("MMM yyyy");
                        if (adj > 0)
                            dtTx.Rows.Add(chargeDate, adjPart, "ADJ-" + refNo, adj, 0m, 3);
                        else
                            dtTx.Rows.Add(chargeDate, adjPart, "ADJ-" + refNo, 0m, Math.Abs(adj), 3);
                    }
                }
            }

            // Sort transactions chronologically
            DataView dvTx = dtTx.DefaultView;
            dvTx.Sort = "TransDate ASC, SortKey ASC";
            DataTable sortedTx = dvTx.ToTable();

            // Build final summarized table for rptLedger
            DataTable dtFinalLedger = new DataTable();
            dtFinalLedger.Columns.Add("TransDateFormatted", typeof(string));
            dtFinalLedger.Columns.Add("Particulars", typeof(string));
            dtFinalLedger.Columns.Add("Reference", typeof(string));
            dtFinalLedger.Columns.Add("Debit", typeof(decimal));
            dtFinalLedger.Columns.Add("Credit", typeof(decimal));
            dtFinalLedger.Columns.Add("Balance", typeof(decimal));
            dtFinalLedger.Columns.Add("SortOrder", typeof(string));

            // Row 0: BALANCE BROUGHT FORWARD (exact opening balance as of Start Date)
            dtFinalLedger.Rows.Add(
                startDate.ToString("dd-MMM-yyyy"),
                "BALANCE BROUGHT FORWARD (Opening Balance as of " + startDate.ToString("dd-MMM-yyyy") + ")",
                "",
                0m,
                0m,
                runningBalance,
                "0"
            );

            // Progressive transactions
            foreach (DataRow row in sortedTx.Rows)
            {
                DateTime tDate = Convert.ToDateTime(row["TransDate"]);
                string part = row["Particulars"].ToString();
                string rNo = row["Reference"].ToString();
                decimal dr = SafeDecimal(row["Debit"]);
                decimal cr = SafeDecimal(row["Credit"]);

                runningBalance = runningBalance + dr - cr;

                dtFinalLedger.Rows.Add(
                    tDate.ToString("dd-MMM-yyyy"),
                    part,
                    rNo,
                    dr,
                    cr,
                    runningBalance,
                    "1"
                );
            }

            rptLedger.DataSource = dtFinalLedger;
            rptLedger.DataBind();

            litClosingBalance.Text = FormatAmount(closingBalance);

            // ── HANDLE ACCOUNT SUMMARY, SUBSCRIPTIONS, SPORTS PORTIONS ──
            // User Requirement:
            // "show this portion but with out data if no process charged.. and in both pages show the subscription section also sum up the sports as it was in Memberstatment.aspx page for family"
            if (!hasChargedProcessInDates)
            {
                // NO PROCESS CHARGED: Show portions with 0 / without data
                lblProcessStatusHeader.Text = "No Charged Process in Selected Dates";
                lblProcessStatusHeader.Visible = true;
                lblProcessStatusHeader.Style["background"] = "#fee2e2";
                lblProcessStatusHeader.Style["color"] = "#991b1b";

                // Account Summary cards: opening balance on startDate, payments received in range, 0 bill, 0 adjustments, and closing balance on endDate
                litPrevBal.Text = FormatAmount(openingBalance);
                litPayRec.Text = FormatAmount(totalPaymentsInDateRange);
                litBillAmt.Text = "0";
                litAdjustments.Text = "0";
                litDueAmt.Text = FormatAmount(closingBalance);

                // Render subscription cards with 0 (without charged data)
                LoadSubscriptionCards(con, resolvedCatId, resolvedTypeId, resolvedCatName, resolvedTypeName, memberAge, membershipYears, false);

                // Render sports grid with family aggregation with 0 (without charged data)
                LoadSportsGrid(con, memberNo, cleanMNo, memberProfileId, startDate, endDate, false);

                lblProcessStatusBadge.Text = "Pending / Not Charged";
                lblProcessStatusBadge.Style["background"] = "#fff8e1";
                lblProcessStatusBadge.Style["color"] = "#b45309";
                litProcessInfo.Text = "No monthly billing charge process has been executed for " + startDate.ToString("dd-MMM-yyyy") + " to " + endDate.ToString("dd-MMM-yyyy") + ". Closing balance as of " + endDate.ToString("dd-MMM-yyyy") + " is <strong>Rs. " + FormatAmount(closingBalance) + "</strong>.";

                btnChargeProcess.Text = "Charge Process";
                btnChargeProcess.Enabled = true;
                btnChargeProcess.Style["background"] = "#15803d";
                btnChargeProcess.Style["cursor"] = "pointer";
                btnChargeProcess.OnClientClick = "return confirm('Run charge process for this member for the billing period?');";
            }
            else
            {
                // POPULATED STATE: Process is charged!
                lblProcessStatusHeader.Text = "Process Charged";
                lblProcessStatusHeader.Visible = true;
                lblProcessStatusHeader.Style["background"] = "#dcfce7";
                lblProcessStatusHeader.Style["color"] = "#15803d";

                // Account Summary figures strictly for the filtered dates
                litPrevBal.Text = FormatAmount(openingBalance);
                litPayRec.Text = FormatAmount(totalPaymentsInDateRange);
                litBillAmt.Text = FormatAmount(totalChargedBillAmount);
                litAdjustments.Text = FormatAmount(totalAdjustments);
                litDueAmt.Text = FormatAmount(closingBalance);

                // Load Subscription Detail Cards from MemberBilling_Subscriptions
                LoadSubscriptionCards(con, resolvedCatId, resolvedTypeId, resolvedCatName, resolvedTypeName, memberAge, membershipYears, true);

                // Load Sports Grid with family aggregation
                LoadSportsGrid(con, memberNo, cleanMNo, memberProfileId, startDate, endDate, true);

                lblProcessStatusBadge.Text = "Process Charged";
                lblProcessStatusBadge.Style["background"] = "#dcfce7";
                lblProcessStatusBadge.Style["color"] = "#15803d";
                litProcessInfo.Text = "This statement includes charged billing for the selected dates. Closing Balance as of " + endDate.ToString("dd-MMM-yyyy") + " is <strong>Rs. " + FormatAmount(closingBalance) + "</strong>.";

                btnChargeProcess.Text = "Already Charged";
                btnChargeProcess.Enabled = false;
                btnChargeProcess.Style["background"] = "#9ca3af";
                btnChargeProcess.Style["cursor"] = "not-allowed";
                btnChargeProcess.OnClientClick = "";
            }

            pnlStatement.Visible = true;
        }
    }

    // ═══════════════════════════════════════════════════════
    //  FORCEFUL BALANCE AS OF A PARTICULAR DATE
    //  isStartOpening = true  => Balance on StartDate (Opening Balance)
    //  isStartOpening = false => Balance on EndDate (Closing Balance)
    // ═══════════════════════════════════════════════════════
    private decimal GetBalanceAsOfDate(SqlConnection con, string memberNo, string cleanMNo, DateTime targetDate, bool isStartOpening)
    {
        if (isStartOpening)
        {
            // For START DATE as Opening Balance:
            // 1. If targetDate is 1st of month, check MemberBilling PreviousBalance for that month
            if (targetDate.Day == 1)
            {
                try
                {
                    using (SqlCommand cmdMB = new SqlCommand(@"
                        SELECT TOP 1 PreviousBalance 
                        FROM MemberBilling 
                        WHERE (MemberNo = @MNo OR MemberNo = @CleanMNo)
                          AND YEAR(BillingMonth) = @Y AND MONTH(BillingMonth) = @M
                        ORDER BY IsCharged DESC, BillingID DESC", con))
                    {
                        cmdMB.Parameters.AddWithValue("@MNo", memberNo);
                        cmdMB.Parameters.AddWithValue("@CleanMNo", cleanMNo);
                        cmdMB.Parameters.AddWithValue("@Y", targetDate.Year);
                        cmdMB.Parameters.AddWithValue("@M", targetDate.Month);
                        object obj = cmdMB.ExecuteScalar();
                        if (obj != null && obj != DBNull.Value)
                        {
                            return SafeDecimal(obj);
                        }
                    }
                }
                catch { }
            }

            // 2. Look in MemberLedger for the balance prior to targetDate (or SortOrder=0 on targetDate)
            try
            {
                using (SqlCommand cmdL = new SqlCommand(@"
                    SELECT TOP 1 Balance 
                    FROM MemberLedger 
                    WHERE (MemberNo = @MNo OR MemberNo = @CleanMNo)
                      AND (TransDate < @TargetDate OR (TransDate <= @TargetDate AND SortOrder = 0) OR TransDate IS NULL)
                    ORDER BY CASE WHEN TransDate IS NULL THEN 0 ELSE 1 END DESC, TransDate DESC, SortOrder DESC, LedgerID DESC", con))
                {
                    cmdL.Parameters.AddWithValue("@MNo", memberNo);
                    cmdL.Parameters.AddWithValue("@CleanMNo", cleanMNo);
                    cmdL.Parameters.AddWithValue("@TargetDate", targetDate);
                    object obj = cmdL.ExecuteScalar();
                    if (obj != null && obj != DBNull.Value)
                    {
                        return SafeDecimal(obj);
                    }
                }
            }
            catch { }

            // 3. Fallback to most recent MemberBilling record prior to targetDate
            try
            {
                using (SqlCommand cmdMB2 = new SqlCommand(@"
                    SELECT TOP 1 DueAmount 
                    FROM MemberBilling 
                    WHERE (MemberNo = @MNo OR MemberNo = @CleanMNo)
                      AND BillingMonth < @TargetDate
                    ORDER BY BillingMonth DESC, IsCharged DESC", con))
                {
                    cmdMB2.Parameters.AddWithValue("@MNo", memberNo);
                    cmdMB2.Parameters.AddWithValue("@CleanMNo", cleanMNo);
                    cmdMB2.Parameters.AddWithValue("@TargetDate", targetDate);
                    object obj = cmdMB2.ExecuteScalar();
                    if (obj != null && obj != DBNull.Value)
                    {
                        return SafeDecimal(obj);
                    }
                }
            }
            catch { }

            // 4. Initial BALANCE BROUGHT FORWARD in MemberLedger
            try
            {
                using (SqlCommand cmdBF = new SqlCommand(@"
                    SELECT TOP 1 Balance 
                    FROM MemberLedger 
                    WHERE (MemberNo = @MNo OR MemberNo = @CleanMNo)
                      AND Particulars LIKE '%BALANCE BROUGHT FORWARD%'", con))
                {
                    cmdBF.Parameters.AddWithValue("@MNo", memberNo);
                    cmdBF.Parameters.AddWithValue("@CleanMNo", cleanMNo);
                    object obj = cmdBF.ExecuteScalar();
                    if (obj != null && obj != DBNull.Value)
                    {
                        return SafeDecimal(obj);
                    }
                }
            }
            catch { }
        }
        else
        {
            // For END DATE as Closing Balance:
            // 1. Look in MemberLedger on or before targetDate
            try
            {
                using (SqlCommand cmdL = new SqlCommand(@"
                    SELECT TOP 1 Balance 
                    FROM MemberLedger 
                    WHERE (MemberNo = @MNo OR MemberNo = @CleanMNo)
                      AND TransDate <= @TargetDate
                    ORDER BY TransDate DESC, SortOrder DESC, LedgerID DESC", con))
                {
                    cmdL.Parameters.AddWithValue("@MNo", memberNo);
                    cmdL.Parameters.AddWithValue("@CleanMNo", cleanMNo);
                    cmdL.Parameters.AddWithValue("@TargetDate", targetDate);
                    object obj = cmdL.ExecuteScalar();
                    if (obj != null && obj != DBNull.Value)
                    {
                        return SafeDecimal(obj);
                    }
                }
            }
            catch { }

            // 2. If end of month, check MemberBilling for that month
            try
            {
                using (SqlCommand cmdMB = new SqlCommand(@"
                    SELECT TOP 1 DueAmount 
                    FROM MemberBilling 
                    WHERE (MemberNo = @MNo OR MemberNo = @CleanMNo)
                      AND YEAR(BillingMonth) = @Y AND MONTH(BillingMonth) = @M
                    ORDER BY IsCharged DESC, BillingID DESC", con))
                {
                    cmdMB.Parameters.AddWithValue("@MNo", memberNo);
                    cmdMB.Parameters.AddWithValue("@CleanMNo", cleanMNo);
                    cmdMB.Parameters.AddWithValue("@Y", targetDate.Year);
                    cmdMB.Parameters.AddWithValue("@M", targetDate.Month);
                    object obj = cmdMB.ExecuteScalar();
                    if (obj != null && obj != DBNull.Value)
                    {
                        return SafeDecimal(obj);
                    }
                }
            }
            catch { }

            // 3. Fallback to BALANCE BROUGHT FORWARD in MemberLedger
            try
            {
                using (SqlCommand cmdBF = new SqlCommand(@"
                    SELECT TOP 1 Balance 
                    FROM MemberLedger 
                    WHERE (MemberNo = @MNo OR MemberNo = @CleanMNo)
                      AND Particulars LIKE '%BALANCE BROUGHT FORWARD%'", con))
                {
                    cmdBF.Parameters.AddWithValue("@MNo", memberNo);
                    cmdBF.Parameters.AddWithValue("@CleanMNo", cleanMNo);
                    object obj = cmdBF.ExecuteScalar();
                    if (obj != null && obj != DBNull.Value)
                    {
                        return SafeDecimal(obj);
                    }
                }
            }
            catch { }
        }

        return 0m;
    }

    // ═══════════════════════════════════════════════════════
    //  SUBSCRIPTION CARDS
    // ═══════════════════════════════════════════════════════
    private void LoadSubscriptionCards(SqlConnection con, int catId, int typeId, string catName, string typeName, int age, int years, bool isCharged)
    {
        DataTable dtCards = new DataTable();
        dtCards.Columns.Add("CardLabel", typeof(string));
        dtCards.Columns.Add("Amount", typeof(decimal));
        dtCards.Columns.Add("FormattedValue", typeof(string));
        dtCards.Columns.Add("CssClass", typeof(string));
        dtCards.Columns.Add("CustomStyle", typeof(string));
        dtCards.Columns.Add("BenefitNote", typeof(string));

        string[] paletteClasses = new string[]
        {
            "sc-general", "sc-library", "sc-film", "sc-musical",
            "sc-utilities", "sc-welfare", "sc-dev", "sc-sport",
            "sc-amber", "sc-cyan"
        };
        int colorIdx = 0;
        decimal subTotal = 0m;

        try
        {
            string sqlBillingSubs = @"
                SELECT SubscriptionID, SubscriptionName, Amount
                FROM MemberBilling_Subscriptions
                WHERE IsActive = 1 AND SubscriptionName NOT LIKE '%Sport%' AND SubscriptionName NOT LIKE '%Non Playing%'
                ORDER BY SubscriptionID ASC";

            DataTable dtDefSubs = new DataTable();
            using (SqlDataAdapter daSubs = new SqlDataAdapter(sqlBillingSubs, con))
            {
                daSubs.Fill(dtDefSubs);
            }

            if (dtDefSubs.Rows.Count > 0)
            {
                foreach (DataRow dRow in dtDefSubs.Rows)
                {
                    int subId = Convert.ToInt32(dRow["SubscriptionID"]);
                    string subName = dRow["SubscriptionName"].ToString().Trim().ToUpper();
                    decimal baseAmt = SafeDecimal(dRow["Amount"]);
                    decimal applicableAmt = isCharged ? baseAmt : 0m;
                    string benefitNote = "";

                    if (isCharged)
                    {
                        // Category rate lookup
                        try
                        {
                            string sqlCatRate = @"
                                SELECT TOP 1 Amount FROM MemberBilling_SubscriptionCategoryRates
                                WHERE SubscriptionID = @SubID AND ((CategoryID = @CatID) OR (CategoryName = @CatName))";
                            using (SqlCommand cmdCR = new SqlCommand(sqlCatRate, con))
                            {
                                cmdCR.Parameters.AddWithValue("@SubID", subId);
                                cmdCR.Parameters.AddWithValue("@CatID", catId);
                                cmdCR.Parameters.AddWithValue("@CatName", catName);
                                object crObj = cmdCR.ExecuteScalar();
                                if (crObj != null && crObj != DBNull.Value)
                                {
                                    decimal catAmt = SafeDecimal(crObj);
                                    if (catAmt != baseAmt)
                                    {
                                        applicableAmt = catAmt;
                                        if (catAmt < baseAmt)
                                            benefitNote = "Saved Rs. " + FormatAmount(baseAmt - catAmt);
                                    }
                                }
                            }
                        }
                        catch { }

                        // Age Benefit
                        if (age > 0)
                        {
                            try
                            {
                                string sqlAge = @"
                                    SELECT TOP 1 DiscountPercentage, DiscountFixed
                                    FROM MemberBilling_SubscriptionAgeBenefits
                                    WHERE SubscriptionID = @SubID AND MinAge <= @Age AND MaxAge >= @Age";
                                using (SqlCommand cmdAge = new SqlCommand(sqlAge, con))
                                {
                                    cmdAge.Parameters.AddWithValue("@SubID", subId);
                                    cmdAge.Parameters.AddWithValue("@Age", age);
                                    using (SqlDataReader rdrAge = cmdAge.ExecuteReader())
                                    {
                                        if (rdrAge.Read())
                                        {
                                            decimal discPct = SafeDecimal(rdrAge["DiscountPercentage"]);
                                            decimal discFixed = SafeDecimal(rdrAge["DiscountFixed"]);
                                            decimal deduction = (applicableAmt * discPct / 100m) + discFixed;
                                            if (deduction > 0)
                                            {
                                                applicableAmt = Math.Max(0, applicableAmt - deduction);
                                                benefitNote = "Age Benefit: Saved Rs. " + FormatAmount(deduction);
                                            }
                                        }
                                    }
                                }
                            }
                            catch { }
                        }
                    }

                    string cls = paletteClasses[colorIdx % paletteClasses.Length];
                    colorIdx++;
                    dtCards.Rows.Add(subName, applicableAmt, isCharged ? FormatAmount(applicableAmt) : "0", cls, "", benefitNote);
                    subTotal += applicableAmt;
                }
            }
        }
        catch { }

        // Fallback default 7 cards if dtCards is empty
        if (dtCards.Rows.Count == 0)
        {
            string[] defaultCards = new string[] { "GENERAL SUB", "LIBRARY SUB", "FILM SUB", "MUSICAL EVE", "WELFARE FUND", "DEV. FUND", "UTILITIES" };
            foreach (string dCard in defaultCards)
            {
                string cls = paletteClasses[colorIdx % paletteClasses.Length];
                colorIdx++;
                dtCards.Rows.Add(dCard, 0m, "0", cls, "", "");
            }
        }

        rptSubscriptionCards.DataSource = dtCards;
        rptSubscriptionCards.DataBind();
        litSubTotal.Text = isCharged ? FormatAmount(subTotal) : "0";
    }

    // ═══════════════════════════════════════════════════════
    //  SPORTS GRID (Summed up for family as in MemberStatement.aspx)
    // ═══════════════════════════════════════════════════════
    private void LoadSportsGrid(SqlConnection con, string memberNo, string cleanMNo, int memberProfileId, DateTime startDate, DateTime endDate, bool isCharged)
    {
        DataTable dtSports = new DataTable();
        dtSports.Columns.Add("SportName", typeof(string));
        dtSports.Columns.Add("Subscription", typeof(decimal));
        dtSports.Columns.Add("GST", typeof(decimal));
        dtSports.Columns.Add("Locker", typeof(decimal));
        dtSports.Columns.Add("Misc", typeof(decimal));

        decimal totalSportsSub = 0;
        decimal totalSportsGST = 0;
        decimal totalSportsLocker = 0;
        decimal totalSportsMisc = 0;

        Dictionary<string, decimal[]> sportsSummary = new Dictionary<string, decimal[]>(StringComparer.OrdinalIgnoreCase);

        string sportsConnStr = ConfigurationManager.ConnectionStrings["SportsConnString"] != null
            ? ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString
            : (ConfigurationManager.ConnectionStrings["GymkhanaDB"] != null
                ? ConfigurationManager.ConnectionStrings["GymkhanaDB"].ConnectionString
                : "");

        Action<SqlConnection, bool> loadSportsData = (dbCon, useCrossDb) =>
        {
            string dbPrefix = useCrossDb ? "SportsModuleDB.dbo." : "";
            string sqlSports = string.Format(@"
                SELECT 
                    ms.MemberSubID,
                    sp.SportID,
                    sp.SportName,
                    sub.PackageName,
                    sub.SubscriptionType,
                    ISNULL(sp.MonthlyFee, 0) AS DefinedMonthlyFee,
                    ISNULL(sp.ContinuousFee, 0) AS DefinedContinuousFee,
                    ISNULL(sub.Fee, 0) AS PackageFee,
                    ISNULL(sub.GSTPercentage, 16.00) AS GSTPercentage,
                    ISNULL(ms.PolicyDiscount, 0) AS PolicyDiscount,
                    ISNULL(ms.GSTAmount, 0) AS GSTAmount,
                    ISNULL(ms.ManualDiscount, 0) AS ManualDiscount,
                    ISNULL(ms.NetFee, 0) AS NetFee,
                    ISNULL(ms.LockerFee, 0) AS LockerFee,
                    ms.DependentMemberNo,
                    ms.DependentName,
                    ms.DependentRelation
                FROM {0}MemberSubscriptions ms
                INNER JOIN {0}Subscriptions sub ON ms.SubscriptionID = sub.SubscriptionID
                INNER JOIN {0}Sports sp ON sub.SportID = sp.SportID
                WHERE (
                        (ms.MemberID = @MemberID AND @MemberID > 0)
                        OR ms.DependentMemberNo = @MNo
                        OR ms.DependentMemberNo LIKE @MNo + '%'
                        OR ms.DependentMemberNo = @CleanMNo
                      )
                  AND ms.IsActive = 1
                  AND (ms.StartDate <= @EndDate AND (ms.EndDate IS NULL OR ms.EndDate >= @StartDate))
                  AND sp.SportName NOT LIKE '%Non Playing%'
                  AND (sub.SubscriptionType IN ('Monthly', 'Continuous') OR sub.SubscriptionType IS NULL)
                  AND ISNULL(sub.SubscriptionType, '') <> 'Daily'
                ORDER BY ms.MemberSubID ASC", dbPrefix);

            using (SqlCommand cmdSp = new SqlCommand(sqlSports, dbCon))
            {
                cmdSp.Parameters.AddWithValue("@MemberID", memberProfileId);
                cmdSp.Parameters.AddWithValue("@MNo", memberNo);
                cmdSp.Parameters.AddWithValue("@CleanMNo", cleanMNo);
                cmdSp.Parameters.AddWithValue("@StartDate", startDate);
                cmdSp.Parameters.AddWithValue("@EndDate", endDate);

                using (SqlDataReader rdrSp = cmdSp.ExecuteReader())
                {
                    while (rdrSp.Read())
                    {
                        string sName = rdrSp["SportName"] != DBNull.Value ? rdrSp["SportName"].ToString().Trim() : "Sport";
                        string subType = rdrSp["SubscriptionType"] != DBNull.Value ? rdrSp["SubscriptionType"].ToString().Trim() : "";

                        if (subType.Equals("Daily", StringComparison.OrdinalIgnoreCase) || subType.IndexOf("POS", StringComparison.OrdinalIgnoreCase) >= 0)
                            continue;

                        decimal defMonthly = SafeDecimal(rdrSp["DefinedMonthlyFee"]);
                        decimal defCont = SafeDecimal(rdrSp["DefinedContinuousFee"]);
                        decimal pkgFee = SafeDecimal(rdrSp["PackageFee"]);
                        decimal gstPct = SafeDecimal(rdrSp["GSTPercentage"]);
                        decimal netFee = SafeDecimal(rdrSp["NetFee"]);
                        decimal gstAmt = SafeDecimal(rdrSp["GSTAmount"]);
                        decimal lockerFee = SafeDecimal(rdrSp["LockerFee"]);
                        decimal manualDisc = SafeDecimal(rdrSp["ManualDiscount"]);
                        decimal policyDisc = SafeDecimal(rdrSp["PolicyDiscount"]);

                        decimal subFee = 0;
                        if (subType.Equals("Continuous", StringComparison.OrdinalIgnoreCase))
                        {
                            subFee = defCont > 0 ? defCont : (pkgFee > 0 ? pkgFee : netFee);
                        }
                        else if (subType.Equals("Monthly", StringComparison.OrdinalIgnoreCase))
                        {
                            subFee = defMonthly > 0 ? defMonthly : (pkgFee > 0 ? pkgFee : netFee);
                        }
                        else if (defMonthly > 0)
                            subFee = defMonthly;
                        else if (defCont > 0)
                            subFee = defCont;
                        else if (pkgFee > 0)
                            subFee = pkgFee;
                        else if (netFee > 0)
                            subFee = Math.Max(0, netFee - gstAmt - lockerFee + manualDisc);

                        decimal gst = 0;
                        if (subFee > 0)
                        {
                            decimal applicableGstPct = gstPct > 0 ? gstPct : 16.00m;
                            gst = Math.Round(subFee * (applicableGstPct / 100m), 2);
                        }
                        else if (gstAmt > 0)
                        {
                            gst = gstAmt;
                        }

                        decimal locker = lockerFee;
                        decimal misc = manualDisc;

                        // Sum across all family members (main member, child, spouse)
                        if (!sportsSummary.ContainsKey(sName))
                        {
                            sportsSummary[sName] = new decimal[] { 0m, 0m, 0m, 0m };
                        }
                        sportsSummary[sName][0] += subFee;
                        sportsSummary[sName][1] += gst;
                        sportsSummary[sName][2] += locker;
                        sportsSummary[sName][3] += misc;
                    }
                }
            }
        };

        if (!string.IsNullOrEmpty(sportsConnStr))
        {
            try
            {
                using (SqlConnection sCon = new SqlConnection(sportsConnStr))
                {
                    sCon.Open();
                    loadSportsData(sCon, false);
                }
            }
            catch
            {
                try
                {
                    using (SqlConnection mCon = new SqlConnection(memberConnStr))
                    {
                        mCon.Open();
                        loadSportsData(mCon, true);
                    }
                }
                catch { }
            }
        }

        // Fallback: If no records in MemberSubscriptions, check MemberSubscriptionMisc
        if (sportsSummary.Count == 0)
        {
            try
            {
                SqlCommand cmdMisc = new SqlCommand(@"
                    SELECT ItemName, Sports, Subs, GST, Locker, Misc
                    FROM MemberSubscriptionMisc
                    WHERE MemberNo = @MemberNo
                      AND ItemName NOT LIKE '%Non Playing%'
                      AND ItemName NOT LIKE '%POS%' AND ItemName NOT LIKE '%Daily%'", con);

                cmdMisc.Parameters.AddWithValue("@MemberNo", memberNo);

                using (SqlDataReader rdrMisc = cmdMisc.ExecuteReader())
                {
                    while (rdrMisc.Read())
                    {
                        string itm = rdrMisc["ItemName"].ToString().Trim();
                        decimal sFee = SafeDecimal(rdrMisc["Subs"]);
                        if (sFee == 0) sFee = SafeDecimal(rdrMisc["Sports"]);
                        decimal gVal = SafeDecimal(rdrMisc["GST"]);
                        if (gVal > 0 && gVal <= 25 && sFee > 100 && (gVal == 16 || gVal == 17 || gVal == 18 || gVal == 15))
                        {
                            gVal = Math.Round(sFee * (gVal / 100m), 2);
                        }
                        decimal lVal = SafeDecimal(rdrMisc["Locker"]);
                        decimal mVal = SafeDecimal(rdrMisc["Misc"]);

                        if (!sportsSummary.ContainsKey(itm))
                        {
                            sportsSummary[itm] = new decimal[] { 0m, 0m, 0m, 0m };
                        }
                        sportsSummary[itm][0] += sFee;
                        sportsSummary[itm][1] += gVal;
                        sportsSummary[itm][2] += lVal;
                        sportsSummary[itm][3] += mVal;
                    }
                }
            }
            catch { }
        }

        // If still empty and charged, fallback to Non Playing Contribution
        if (sportsSummary.Count == 0 && isCharged)
        {
            sportsSummary["Non Playing Contribution"] = new decimal[] { 500m, 0m, 0m, 0m };
        }

        foreach (var kvp in sportsSummary)
        {
            decimal sFee = isCharged ? kvp.Value[0] : 0m;
            decimal gst = isCharged ? kvp.Value[1] : 0m;
            decimal lck = isCharged ? kvp.Value[2] : 0m;
            decimal msc = isCharged ? kvp.Value[3] : 0m;

            dtSports.Rows.Add(kvp.Key, sFee, gst, lck, msc);
            totalSportsSub += sFee;
            totalSportsGST += gst;
            totalSportsLocker += lck;
            totalSportsMisc += msc;
        }

        rptSportsGrid.DataSource = dtSports;
        rptSportsGrid.DataBind();

        litSportsSubTotal.Text = FormatAmount(totalSportsSub);
        litSportsGSTTotal.Text = FormatAmount(totalSportsGST);
        litSportsLockerTotal.Text = FormatAmount(totalSportsLocker);
        litSportsMiscTotal.Text = FormatAmount(totalSportsMisc);
    }

    // ═══════════════════════════════════════════════════════
    //  CHARGE PROCESS
    // ═══════════════════════════════════════════════════════
    protected void btnChargeProcess_Click(object sender, EventArgs e)
    {
        string memberNo = txtMemberNo.Text.Trim();
        DateTime startDate, endDate;
        if (!DateTime.TryParse(txtStartDate.Text, out startDate) || !DateTime.TryParse(txtEndDate.Text, out endDate))
        {
            ShowMemberInfo("Invalid date range for charge process.", false);
            return;
        }

        string billingConnStr = GetBillingConnectionString();
        try
        {
            using (SqlConnection con = new SqlConnection(billingConnStr))
            {
                con.Open();
                DateTime billingMonth = new DateTime(startDate.Year, startDate.Month, 1);

                decimal closingBalance = SafeDecimal(litClosingBalance.Text.Replace("(", "-").Replace(")", "").Replace(",", ""));
                decimal billAmt = SafeDecimal(litBillAmt.Text.Replace("(", "-").Replace(")", "").Replace(",", ""));
                decimal prevBal = SafeDecimal(litPrevBal.Text.Replace("(", "-").Replace(")", "").Replace(",", ""));
                decimal payRec = SafeDecimal(litPayRec.Text.Replace("(", "-").Replace(")", "").Replace(",", ""));

                using (SqlCommand cmd = new SqlCommand(@"
                    IF EXISTS (SELECT 1 FROM MemberBilling WHERE MemberNo = @MNo AND BillingMonth = @BMonth)
                    BEGIN
                        UPDATE MemberBilling 
                        SET IsCharged = 1, ChargedDate = GETDATE(), DueAmount = @DueAmt, DueDate = @DueDate, StatementDate = @StmtDate
                        WHERE MemberNo = @MNo AND BillingMonth = @BMonth
                    END
                    ELSE
                    BEGIN
                        INSERT INTO MemberBilling (MemberNo, BillingMonth, StatementDate, DueDate, PreviousBalance, PaymentReceived, BillAmount, Adjustments, DueAmount, IsCharged, ChargedDate, CreatedDate)
                        VALUES (@MNo, @BMonth, @StmtDate, @DueDate, @PrevBal, @PayRec, @BillAmt, 0, @DueAmt, 1, GETDATE(), GETDATE())
                    END", con))
                {
                    cmd.Parameters.AddWithValue("@MNo", memberNo);
                    cmd.Parameters.AddWithValue("@BMonth", billingMonth);
                    cmd.Parameters.AddWithValue("@StmtDate", startDate.AddDays(-1));
                    cmd.Parameters.AddWithValue("@DueDate", endDate);
                    cmd.Parameters.AddWithValue("@PrevBal", prevBal);
                    cmd.Parameters.AddWithValue("@PayRec", payRec);
                    cmd.Parameters.AddWithValue("@BillAmt", billAmt);
                    cmd.Parameters.AddWithValue("@DueAmt", closingBalance);
                    cmd.ExecuteNonQuery();
                }
            }

            lblProcessMessage.Text = "Charge process successfully executed and recorded for " + startDate.ToString("MMM yyyy") + "!";
            lblProcessMessage.Visible = true;
            lblProcessMessage.Style["background"] = "#dcfce7";
            lblProcessMessage.Style["color"] = "#15803d";
            lblProcessMessage.Style["border"] = "1px solid #86efac";

            btnSearch_Click(sender, e);
        }
        catch (Exception ex)
        {
            lblProcessMessage.Text = "Error during charge process: " + ex.Message;
            lblProcessMessage.Visible = true;
            lblProcessMessage.Style["background"] = "#fee2e2";
            lblProcessMessage.Style["color"] = "#991b1b";
        }
    }

    private void ShowMemberInfo(string message, bool isSuccess)
    {
        lblMemberInfo.Text = message;
        lblMemberInfo.Visible = true;
        if (isSuccess)
        {
            lblMemberInfo.Style["background"] = "#e6f9e6";
            lblMemberInfo.Style["color"] = "#1a7a1a";
            lblMemberInfo.Style["border"] = "1px solid #a3d9a3";
        }
        else
        {
            lblMemberInfo.Style["background"] = "#fde8e8";
            lblMemberInfo.Style["color"] = "#b91c1c";
            lblMemberInfo.Style["border"] = "1px solid #f5a3a3";
        }
    }

    public string FormatAmount(object value)
    {
        decimal amount = SafeDecimal(value);
        if (amount < 0) return "(" + Math.Abs(amount).ToString("N0") + ")";
        return amount.ToString("N0");
    }

    private decimal SafeDecimal(object obj)
    {
        if (obj == null || obj == DBNull.Value) return 0;
        decimal result;
        return decimal.TryParse(obj.ToString(), out result) ? result : 0;
    }
}
