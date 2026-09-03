using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Membership
{
    public partial class MemberFeeDisbursementReport : Page
    {
        private decimal m_grandTotalDisbursed = 0;
        private int m_grandTotalMembers = 0;

        private string membershipConnStr
        {
            get
            {
                var s = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
                return s != null ? s.ConnectionString : "";
            }
        }

        private string financeConnStr
        {
            get
            {
                if (ConfigurationManager.ConnectionStrings["FinanceConnectionString"] != null)
                    return ConfigurationManager.ConnectionStrings["FinanceConnectionString"].ConnectionString;
                if (ConfigurationManager.ConnectionStrings["Finance_ConnectionString"] != null)
                    return ConfigurationManager.ConnectionStrings["Finance_ConnectionString"].ConnectionString;
                return "";
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindFinanceHeadsDropdown();

                bool hasExplicitFilter = false;

                // Check query string parameters for direct filtering (e.g. redirected on save)
                if (!string.IsNullOrEmpty(Request.QueryString["MemberNo"]))
                {
                    txtMemberNo.Text = Request.QueryString["MemberNo"].Trim();
                    hasExplicitFilter = true;
                }
                if (!string.IsNullOrEmpty(Request.QueryString["NIC"]))
                {
                    txtCNIC.Text = Request.QueryString["NIC"].Trim();
                    hasExplicitFilter = true;
                }
                if (!string.IsNullOrEmpty(Request.QueryString["ApplicationNo"]))
                {
                    txtApplicationNo.Text = Request.QueryString["ApplicationNo"].Trim();
                    hasExplicitFilter = true;
                }
                if (!string.IsNullOrEmpty(Request.QueryString["TrackID"]))
                {
                    txtApplicationNo.Text = Request.QueryString["TrackID"].Trim();
                    hasExplicitFilter = true;
                }

                if (Request.QueryString["Converted"] == "1" || Request.QueryString["Success"] == "1")
                {
                    pnlConversionSuccess.Visible = true;
                    string memNo = !string.IsNullOrEmpty(txtMemberNo.Text) ? txtMemberNo.Text : "New Member";
                    litSuccessDetails.Text = "Fee disbursement successfully generated and logged for Member No: <strong>" + Server.HtmlEncode(memNo) + "</strong>";
                    hasExplicitFilter = true;
                }

                // Show data ONLY when explicit search/query filter is provided
                if (hasExplicitFilter)
                {
                    if (pnlKPIs != null) pnlKPIs.Visible = true;
                    BindReport();
                }
                else
                {
                    if (pnlKPIs != null) pnlKPIs.Visible = false;
                    litRecordsCount.Text = "0";
                    gvDisbursement.DataSource = new List<MemberDisbursementGroup>();
                    gvDisbursement.DataBind();
                }
            }
        }

        private void BindFinanceHeadsDropdown()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(financeConnStr))
                {
                    con.Open();
                    string sql = @"SELECT hm.ID, e.E_Name, hm.E_Code 
                                   FROM Head_Master_Table hm 
                                   INNER JOIN Expenditure e ON e.E_Code = hm.E_Code 
                                   WHERE hm.Head_Type = 'App Fee Distribution' 
                                   ORDER BY hm.ID DESC";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        dt.Columns.Add("DisplayText", typeof(string));
                        foreach (DataRow row in dt.Rows)
                        {
                            row["DisplayText"] = row["E_Code"].ToString() + " - " + row["E_Name"].ToString();
                        }

                        ddlFinanceHead.DataSource = dt;
                        ddlFinanceHead.DataTextField = "DisplayText";
                        ddlFinanceHead.DataValueField = "ID";
                        ddlFinanceHead.DataBind();
                        ddlFinanceHead.Items.Insert(0, new ListItem("- All Finance Heads -", "0"));
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error binding finance heads dropdown: " + ex.Message);
            }
        }

        private DataTable GetRawDisbursementData()
        {
            DataTable dtFinance = new DataTable();

            // 1. Fetch from Finance DB MemberFeeHeadDistribution
            try
            {
                using (SqlConnection con = new SqlConnection(financeConnStr))
                {
                    con.Open();

                    StringBuilder sb = new StringBuilder();
                    sb.Append(@"SELECT 
                                    ID, NIC, MemberNo, MemberID, HeadId, ECode, HeadType, Amount, TotalMFee, CreatedDate
                                FROM MemberFeeHeadDistribution
                                WHERE 1 = 1 ");

                    if (!string.IsNullOrWhiteSpace(txtMemberNo.Text))
                        sb.Append(" AND MemberNo LIKE @MemberNo ");

                    if (!string.IsNullOrWhiteSpace(txtCNIC.Text))
                        sb.Append(" AND REPLACE(NIC, '-', '') LIKE @NIC ");

                    if (ddlFinanceHead.SelectedIndex > 0 && ddlFinanceHead.SelectedValue != "0")
                        sb.Append(" AND HeadId = @HeadId ");

                    if (!string.IsNullOrWhiteSpace(txtFromDate.Text))
                        sb.Append(" AND CreatedDate >= @FromDate ");

                    if (!string.IsNullOrWhiteSpace(txtToDate.Text))
                        sb.Append(" AND CreatedDate <= @ToDate ");

                    sb.Append(" ORDER BY CreatedDate DESC, MemberNo, ID ");

                    using (SqlCommand cmd = new SqlCommand(sb.ToString(), con))
                    {
                        if (!string.IsNullOrWhiteSpace(txtMemberNo.Text))
                            cmd.Parameters.AddWithValue("@MemberNo", "%" + txtMemberNo.Text.Trim() + "%");

                        if (!string.IsNullOrWhiteSpace(txtCNIC.Text))
                            cmd.Parameters.AddWithValue("@NIC", "%" + txtCNIC.Text.Trim().Replace("-", "") + "%");

                        if (ddlFinanceHead.SelectedIndex > 0 && ddlFinanceHead.SelectedValue != "0")
                            cmd.Parameters.AddWithValue("@HeadId", Convert.ToInt32(ddlFinanceHead.SelectedValue));

                        DateTime fromDt;
                        if (!string.IsNullOrWhiteSpace(txtFromDate.Text) && DateTime.TryParse(txtFromDate.Text, out fromDt))
                            cmd.Parameters.AddWithValue("@FromDate", fromDt.Date);

                        DateTime toDt;
                        if (!string.IsNullOrWhiteSpace(txtToDate.Text) && DateTime.TryParse(txtToDate.Text, out toDt))
                            cmd.Parameters.AddWithValue("@ToDate", toDt.Date.AddDays(1).AddSeconds(-1));

                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        da.Fill(dtFinance);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error reading finance disbursement: " + ex.Message);
            }

            // 2. Add enriched columns: ApplicationNo, MemberName, MembershipCategory
            if (!dtFinance.Columns.Contains("ApplicationNo"))
                dtFinance.Columns.Add("ApplicationNo", typeof(string));

            if (!dtFinance.Columns.Contains("MemberName"))
                dtFinance.Columns.Add("MemberName", typeof(string));

            if (!dtFinance.Columns.Contains("MembershipCategory"))
                dtFinance.Columns.Add("MembershipCategory", typeof(string));

            if (dtFinance.Rows.Count == 0)
                return dtFinance;

            // 3. Collect unique NICs and MemberNos for fast enrichment from MemberShip DB
            HashSet<string> nics = new HashSet<string>();
            HashSet<string> memNos = new HashSet<string>();

            foreach (DataRow row in dtFinance.Rows)
            {
                string nic = row["NIC"] != DBNull.Value ? row["NIC"].ToString().Trim() : "";
                string memNo = row["MemberNo"] != DBNull.Value ? row["MemberNo"].ToString().Trim() : "";

                if (!string.IsNullOrEmpty(nic)) nics.Add(nic);
                if (!string.IsNullOrEmpty(memNo)) memNos.Add(memNo);
            }

            // Dictionaries for fast lookup
            Dictionary<string, string> nicToAppNo = new Dictionary<string, string>();
            Dictionary<string, string> nicToName = new Dictionary<string, string>();
            Dictionary<string, string> nicToCategory = new Dictionary<string, string>();

            Dictionary<string, string> memNoToAppNo = new Dictionary<string, string>();
            Dictionary<string, string> memNoToName = new Dictionary<string, string>();
            Dictionary<string, string> memNoToCategory = new Dictionary<string, string>();

            try
            {
                using (SqlConnection con = new SqlConnection(membershipConnStr))
                {
                    con.Open();

                    // Query ApplicationFForm by NIC
                    if (nics.Count > 0)
                    {
                        string appSql = "SELECT TrackID, ApplicantName, NIC, MembershipType, Membership_class FROM ApplicationFForm";
                        using (SqlCommand cmdApp = new SqlCommand(appSql, con))
                        using (SqlDataReader dr = cmdApp.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                string cnicClean = dr["NIC"] != DBNull.Value ? dr["NIC"].ToString().Replace("-", "").Trim() : "";
                                if (!string.IsNullOrEmpty(cnicClean))
                                {
                                    string track = dr["TrackID"] != DBNull.Value ? dr["TrackID"].ToString() : "";
                                    string name = dr["ApplicantName"] != DBNull.Value ? dr["ApplicantName"].ToString() : "";
                                    string cat = dr["Membership_class"] != DBNull.Value ? dr["Membership_class"].ToString() : "";
                                    if (string.IsNullOrEmpty(cat) && dr["MembershipType"] != DBNull.Value)
                                        cat = dr["MembershipType"].ToString();

                                    if (!nicToAppNo.ContainsKey(cnicClean)) nicToAppNo[cnicClean] = track;
                                    if (!nicToName.ContainsKey(cnicClean)) nicToName[cnicClean] = name;
                                    if (!nicToCategory.ContainsKey(cnicClean)) nicToCategory[cnicClean] = cat;
                                }
                            }
                        }
                    }

                    // Query MemberProfile by MemberNo
                    if (memNos.Count > 0)
                    {
                        string memSql = "SELECT MemberNo, MemberName, MemberType, MemberShipCategory, NIC, ApplicationNo FROM MemberProfile";
                        using (SqlCommand cmdMem = new SqlCommand(memSql, con))
                        using (SqlDataReader dr = cmdMem.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                string mNo = dr["MemberNo"] != DBNull.Value ? dr["MemberNo"].ToString().Trim() : "";
                                if (!string.IsNullOrEmpty(mNo))
                                {
                                    string appNo = dr["ApplicationNo"] != DBNull.Value ? dr["ApplicationNo"].ToString() : "";
                                    string name = dr["MemberName"] != DBNull.Value ? dr["MemberName"].ToString() : "";
                                    string cat = dr["MemberShipCategory"] != DBNull.Value ? dr["MemberShipCategory"].ToString() : "";
                                    if (string.IsNullOrEmpty(cat) && dr["MemberType"] != DBNull.Value)
                                        cat = dr["MemberType"].ToString();

                                    if (!memNoToAppNo.ContainsKey(mNo)) memNoToAppNo[mNo] = appNo;
                                    if (!memNoToName.ContainsKey(mNo)) memNoToName[mNo] = name;
                                    if (!memNoToCategory.ContainsKey(mNo)) memNoToCategory[mNo] = cat;
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error enriching disbursement member data: " + ex.Message);
            }

            // 4. Populate enriched fields in DataTable
            foreach (DataRow row in dtFinance.Rows)
            {
                string nic = row["NIC"] != DBNull.Value ? row["NIC"].ToString().Trim() : "";
                string nicClean = nic.Replace("-", "");
                string memNo = row["MemberNo"] != DBNull.Value ? row["MemberNo"].ToString().Trim() : "";

                string appNo = "";
                string name = "";
                string cat = "";

                if (!string.IsNullOrEmpty(memNo) && memNoToAppNo.ContainsKey(memNo) && !string.IsNullOrEmpty(memNoToAppNo[memNo]))
                    appNo = memNoToAppNo[memNo];
                else if (nicToAppNo.ContainsKey(nicClean))
                    appNo = nicToAppNo[nicClean];

                if (!string.IsNullOrEmpty(memNo) && memNoToName.ContainsKey(memNo) && !string.IsNullOrEmpty(memNoToName[memNo]))
                    name = memNoToName[memNo];
                else if (nicToName.ContainsKey(nicClean))
                    name = nicToName[nicClean];

                if (!string.IsNullOrEmpty(memNo) && memNoToCategory.ContainsKey(memNo) && !string.IsNullOrEmpty(memNoToCategory[memNo]))
                    cat = memNoToCategory[memNo];
                else if (nicToCategory.ContainsKey(nicClean))
                    cat = nicToCategory[nicClean];

                row["ApplicationNo"] = string.IsNullOrEmpty(appNo) ? "—" : appNo;
                row["MemberName"] = string.IsNullOrEmpty(name) ? "—" : name;
                row["MembershipCategory"] = string.IsNullOrEmpty(cat) ? "General" : cat;
            }

            // 5. Filter by ApplicationNo or MemberName if specified in filter
            string appNoFilter = txtApplicationNo.Text.Trim();
            string nameFilter = txtMemberName.Text.Trim().ToLower();

            if (!string.IsNullOrEmpty(appNoFilter) || !string.IsNullOrEmpty(nameFilter))
            {
                DataTable dtFiltered = dtFinance.Clone();
                foreach (DataRow row in dtFinance.Rows)
                {
                    bool match = true;
                    if (!string.IsNullOrEmpty(appNoFilter))
                    {
                        string rowAppNo = row["ApplicationNo"].ToString();
                        if (!rowAppNo.Contains(appNoFilter)) match = false;
                    }
                    if (!string.IsNullOrEmpty(nameFilter))
                    {
                        string rowName = row["MemberName"].ToString().ToLower();
                        if (!rowName.Contains(nameFilter)) match = false;
                    }
                    if (match)
                    {
                        dtFiltered.ImportRow(row);
                    }
                }
                return dtFiltered;
            }

            return dtFinance;
        }

        private List<MemberDisbursementGroup> GetGroupedDisbursementData(out DataTable rawDataTable)
        {
            rawDataTable = GetRawDisbursementData();
            var memberGroups = new List<MemberDisbursementGroup>();
            var groupDict = new Dictionary<string, MemberDisbursementGroup>();

            int sr = 1;
            foreach (DataRow row in rawDataTable.Rows)
            {
                string memNo = row["MemberNo"] != DBNull.Value ? row["MemberNo"].ToString().Trim() : "";
                string nic = row["NIC"] != DBNull.Value ? row["NIC"].ToString().Trim() : "";
                string appNo = row["ApplicationNo"] != DBNull.Value ? row["ApplicationNo"].ToString().Trim() : "";

                // Group key based on MemberNo (or NIC / AppNo)
                string groupKey = !string.IsNullOrEmpty(memNo) && memNo != "—" 
                    ? memNo 
                    : (!string.IsNullOrEmpty(nic) ? nic : appNo);

                if (string.IsNullOrEmpty(groupKey)) groupKey = Guid.NewGuid().ToString();

                if (!groupDict.ContainsKey(groupKey))
                {
                    decimal totalMFee = row["TotalMFee"] != DBNull.Value ? Convert.ToDecimal(row["TotalMFee"]) : 0;
                    DateTime? createdDate = row["CreatedDate"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(row["CreatedDate"]) : null;

                    var grp = new MemberDisbursementGroup
                    {
                        SrNo = sr++,
                        ApplicationNo = appNo,
                        MemberNo = memNo,
                        MemberName = row["MemberName"] != DBNull.Value ? row["MemberName"].ToString() : "",
                        NIC = nic,
                        MembershipCategory = row["MembershipCategory"] != DBNull.Value ? row["MembershipCategory"].ToString() : "",
                        TotalAmount = totalMFee,
                        CreatedDate = createdDate,
                        Heads = new List<FeeHeadItem>()
                    };
                    groupDict[groupKey] = grp;
                    memberGroups.Add(grp);
                }

                // Add disbursed head item
                decimal amount = row["Amount"] != DBNull.Value ? Convert.ToDecimal(row["Amount"]) : 0;
                groupDict[groupKey].Heads.Add(new FeeHeadItem
                {
                    HeadId = row["HeadId"] != DBNull.Value ? row["HeadId"].ToString() : "",
                    ECode = row["ECode"] != DBNull.Value ? row["ECode"].ToString() : "",
                    HeadType = row["HeadType"] != DBNull.Value ? row["HeadType"].ToString() : "",
                    Amount = amount
                });
            }

            // If TotalAmount was 0 on record, fallback to sum of heads
            foreach (var grp in memberGroups)
            {
                if (grp.TotalAmount == 0 && grp.Heads.Count > 0)
                {
                    grp.TotalAmount = grp.Heads.Sum(h => h.Amount);
                }
            }

            return memberGroups;
        }

        private void BindReport()
        {
            DataTable rawData;
            List<MemberDisbursementGroup> groups = GetGroupedDisbursementData(out rawData);

            gvDisbursement.DataSource = groups;
            gvDisbursement.DataBind();
            litRecordsCount.Text = groups.Count.ToString("N0");

            if (litPageInfo != null)
            {
                int totalPages = gvDisbursement.PageCount > 0 ? gvDisbursement.PageCount : 1;
                int currentPage = gvDisbursement.PageCount > 0 ? gvDisbursement.PageIndex + 1 : 1;
                litPageInfo.Text = string.Format("Page {0} of {1}", currentPage, totalPages);
            }

            CalculateMetricsAndHeadSummary(rawData, groups);

            // Update footer totals
            UpdateFooterTotals(groups);
        }

        private void UpdateFooterTotals(List<MemberDisbursementGroup> groups)
        {
            if (gvDisbursement.FooterRow != null)
            {
                var litGrandTotal = gvDisbursement.FooterRow.FindControl("litFooterGrandTotal") as Literal;
                if (litGrandTotal != null)
                {
                    litGrandTotal.Text = m_grandTotalDisbursed.ToString("N2");
                }

                var litMembers = gvDisbursement.FooterRow.FindControl("litFooterMembersCount") as Literal;
                if (litMembers != null)
                {
                    litMembers.Text = m_grandTotalMembers.ToString("N0");
                }
            }
        }

        private void CalculateMetricsAndHeadSummary(DataTable rawData, List<MemberDisbursementGroup> groups)
        {
            decimal totalDisbursed = 0;
            HashSet<string> uniqueMembers = new HashSet<string>();
            HashSet<string> uniqueHeads = new HashSet<string>();

            // For Head summary breakdown
            var headAggregates = new Dictionary<string, HeadSummaryItem>();

            foreach (DataRow row in rawData.Rows)
            {
                decimal amount = row["Amount"] != DBNull.Value ? Convert.ToDecimal(row["Amount"]) : 0;
                totalDisbursed += amount;

                string memIdentifier = row["MemberNo"] != DBNull.Value && !string.IsNullOrEmpty(row["MemberNo"].ToString())
                    ? row["MemberNo"].ToString()
                    : (row["NIC"] != DBNull.Value ? row["NIC"].ToString() : "");

                if (!string.IsNullOrEmpty(memIdentifier))
                    uniqueMembers.Add(memIdentifier);

                string headKey = row["HeadId"] != DBNull.Value ? row["HeadId"].ToString() : "";
                string eCode = row["ECode"] != DBNull.Value ? row["ECode"].ToString() : "";
                string headType = row["HeadType"] != DBNull.Value ? row["HeadType"].ToString() : "";

                if (string.IsNullOrEmpty(headKey)) headKey = eCode + "_" + headType;
                uniqueHeads.Add(headKey);

                if (!headAggregates.ContainsKey(headKey))
                {
                    headAggregates[headKey] = new HeadSummaryItem
                    {
                        HeadId = headKey,
                        ECode = eCode,
                        HeadType = headType,
                        TotalAmount = 0,
                        Members = new HashSet<string>()
                    };
                }

                headAggregates[headKey].TotalAmount += amount;
                if (!string.IsNullOrEmpty(memIdentifier))
                    headAggregates[headKey].Members.Add(memIdentifier);
            }

            int memberCount = groups.Count > 0 ? groups.Count : uniqueMembers.Count;
            decimal avgPerMember = memberCount > 0 ? totalDisbursed / memberCount : 0;

            m_grandTotalDisbursed = totalDisbursed;
            m_grandTotalMembers = memberCount;

            litTotalDisbursed.Text = totalDisbursed.ToString("N2");
            litAvgPerMember.Text = avgPerMember.ToString("N2");

            // Bind Head Summary Repeater sorted in specific requested order:
            // 1. ENTRANCE FEE, 2. CONTIGENCY FUND, 3. DEVELOPMENT FUND, 4. SALE OF MEMBERSHIP FORM, then Others
            var summaryList = headAggregates.Values.Select(h => new
            {
                ECode = string.IsNullOrEmpty(h.ECode) ? "—" : h.ECode,
                HeadType = string.IsNullOrEmpty(h.HeadType) ? "Fee Head" : h.HeadType,
                MemberCount = h.Members.Count,
                TotalAmount = h.TotalAmount,
                Percentage = totalDisbursed > 0 ? (h.TotalAmount / totalDisbursed) * 100 : 0
            }).OrderBy(x => GetHeadSortOrder(x.HeadType)).ThenByDescending(x => x.TotalAmount).ToList();

            if (rptHeadCards != null)
            {
                rptHeadCards.DataSource = summaryList;
                rptHeadCards.DataBind();
            }
        }

        private int GetHeadSortOrder(string headType)
        {
            if (string.IsNullOrEmpty(headType)) return 99;
            string upper = headType.ToUpper().Trim();
            if (upper.Contains("ENTRANCE")) return 1;
            if (upper.Contains("CONTIGEN") || upper.Contains("CONTINGEN")) return 2;
            if (upper.Contains("DEVELOPMENT")) return 3;
            if (upper.Contains("SALE") || upper.Contains("FORM")) return 4;
            return 50;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            gvDisbursement.PageIndex = 0;
            pnlConversionSuccess.Visible = false;
            if (pnlKPIs != null) pnlKPIs.Visible = true;
            BindReport();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtMemberNo.Text = "";
            txtApplicationNo.Text = "";
            txtCNIC.Text = "";
            txtMemberName.Text = "";
            txtFromDate.Text = "";
            txtToDate.Text = "";
            if (ddlFinanceHead.Items.Count > 0)
                ddlFinanceHead.SelectedIndex = 0;

            gvDisbursement.PageIndex = 0;
            pnlConversionSuccess.Visible = false;

            if (pnlKPIs != null) pnlKPIs.Visible = false;
            litRecordsCount.Text = "0";
            gvDisbursement.DataSource = new List<MemberDisbursementGroup>();
            gvDisbursement.DataBind();
        }

        protected void gvDisbursement_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvDisbursement.PageIndex = e.NewPageIndex;
            BindReport();
        }

        protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
        {
            int pageSize = 25;
            if (int.TryParse(ddlPageSize.SelectedValue, out pageSize))
            {
                gvDisbursement.PageSize = pageSize;
            }
            gvDisbursement.PageIndex = 0;
            BindReport();
        }

        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            DataTable rawData;
            List<MemberDisbursementGroup> groups = GetGroupedDisbursementData(out rawData);

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=MemberFeeDisbursementGroupedReport_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".csv");
            Response.Charset = "";
            Response.ContentType = "text/csv; charset=utf-8";

            StringBuilder sb = new StringBuilder();
            sb.AppendLine("Sr#,Application No,Member No,Member Name,CNIC,Membership Category,E-Code,Finance Head,Head Disbursed Amount (Rs.),Total Amount (Rs.),Disbursement Date");

            int sr = 1;
            decimal grandTotal = 0;

            foreach (var grp in groups)
            {
                string appNo = EscapeCsv(grp.ApplicationNo);
                string memNo = EscapeCsv(grp.MemberNo);
                string name = EscapeCsv(grp.MemberName);
                string nic = EscapeCsv(grp.NIC);
                string cat = EscapeCsv(grp.MembershipCategory);
                decimal totalAmt = grp.TotalAmount;
                grandTotal += totalAmt;
                string date = grp.CreatedDate.HasValue ? grp.CreatedDate.Value.ToString("dd-MMM-yyyy") : "";

                if (grp.Heads != null && grp.Heads.Count > 0)
                {
                    for (int i = 0; i < grp.Heads.Count; i++)
                    {
                        var h = grp.Heads[i];
                        string eCode = EscapeCsv(h.ECode);
                        string headType = EscapeCsv(h.HeadType);
                        decimal headAmt = h.Amount;

                        if (i == 0)
                        {
                            // First row of the member group shows ApplicationNo, MemberNo, Name, CNIC, Category, and TotalAmount
                            sb.AppendLine(string.Format("{0},{1},{2},{3},{4},{5},{6},{7},{8:F2},{9:F2},{10}",
                                sr, appNo, memNo, name, nic, cat, eCode, headType, headAmt, totalAmt, date));
                        }
                        else
                        {
                            // Sub-rows under the same member group without repeating member info
                            sb.AppendLine(string.Format("{0},{1},{2},{3},{4},{5},{6},{7},{8:F2},{9},{10}",
                                "\"\"", "\"\"", "\"\"", "\"\"", "\"\"", "\"\"", eCode, headType, headAmt, "\"\"", "\"\""));
                        }
                    }
                }
                else
                {
                    sb.AppendLine(string.Format("{0},{1},{2},{3},{4},{5},{6},{7},{8:F2},{9:F2},{10}",
                        sr, appNo, memNo, name, nic, cat, "\"—\"", "\"—\"", 0, totalAmt, date));
                }
                sr++;
            }

            // Summary Totals Row
            sb.AppendLine(string.Format(",,,,,,,,Total Summary ({0} Members):,{1:F2},", groups.Count, grandTotal));

            Response.Output.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }

        protected void btnPrintReport_Click(object sender, EventArgs e)
        {
            DataTable rawData;
            List<MemberDisbursementGroup> groups = GetGroupedDisbursementData(out rawData);
            string generatedDate = DateTime.Now.ToString("dd-MMM-yyyy hh:mm tt");

            decimal grandTotal = groups.Sum(g => g.TotalAmount);
            int totalMembers = groups.Count;

            StringBuilder html = new StringBuilder();
            html.Append(@"<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>Member Fee Disbursement Report - Lahore Gymkhana</title>
    <style>
        @page { 
            size: A4 portrait; 
            margin: 10mm 12mm 15mm 12mm; 
        }
        @media print { 
            body { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
            .no-print { display: none !important; }
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { 
            font-family: 'Segoe UI', Arial, Helvetica, sans-serif; 
            font-size: 10pt; 
            color: #0f172a; 
            background: #fff; 
            padding: 15px; 
            width: 100%;
            max-width: 100%;
        }
        .header { 
            text-align: center; 
            margin-bottom: 14px; 
            padding-bottom: 10px; 
            border-bottom: 2px solid #0f1e36; 
        }
        .title { 
            font-size: 18pt; 
            font-weight: bold; 
            color: #0f1e36; 
            text-transform: uppercase; 
            letter-spacing: 0.5px;
            margin-bottom: 2px; 
        }
        .subtitle { 
            font-size: 12pt; 
            font-weight: 700; 
            color: #8B5E3C; 
            margin-bottom: 4px; 
        }
        .meta-info { 
            font-size: 9pt; 
            color: #475569; 
            display: flex;
            justify-content: space-between;
            border-top: 1px solid #e2e8f0;
            padding-top: 4px;
            margin-top: 4px;
        }
        table { 
            width: 100%; 
            border-collapse: collapse; 
            margin-top: 8px; 
            page-break-inside: auto;
        }
        thead {
            display: table-header-group;
        }
        tr {
            page-break-inside: avoid;
            page-break-after: auto;
        }
        th { 
            background-color: #0f1e36 !important; 
            color: #ffffff !important; 
            font-weight: 700; 
            padding: 7px 6px; 
            text-align: left; 
            font-size: 9pt; 
            border: 1px solid #0f1e36; 
            text-transform: uppercase;
        }
        td { 
            padding: 6px; 
            border: 1px solid #cbd5e1; 
            font-size: 9pt; 
            vertical-align: top; 
        }
        .text-right { text-align: right; }
        .text-center { text-align: center; }
        .bold { font-weight: bold; }
        .app-no { font-weight: bold; color: #8B5E3C; font-family: monospace; }
        .mem-no { font-weight: bold; color: #0f172a; font-family: monospace; background: #f8fafc; padding: 2px 5px; border-radius: 3px; border: 1px solid #e2e8f0; }
        .code-badge { font-family: monospace; font-size: 8pt; background: #e0f2fe; padding: 1px 4px; border-radius: 3px; font-weight: bold; border: 1px solid #bae6fd; }
        .head-row { display: flex; justify-content: space-between; align-items: center; padding: 3px 0; border-bottom: 1px dashed #e2e8f0; font-size: 8.5pt; gap: 8px; }
        .head-row:last-child { border-bottom: none; }
        .total-row { background-color: #f1ede4 !important; font-weight: bold; font-size: 10pt; border-top: 2px solid #0f1e36 !important; }
        .signature-section { 
            margin-top: 45px; 
            padding-top: 10px; 
            display: flex; 
            justify-content: space-between; 
            page-break-inside: avoid;
        }
        .sig-box { 
            width: 22%; 
            text-align: center; 
            border-top: 1.5px solid #0f1e36; 
            padding-top: 6px; 
            font-size: 9pt; 
            font-weight: 700; 
            color: #1e293b; 
        }
        .print-btn-bar {
            text-align: right;
            margin-bottom: 15px;
        }
        .print-btn {
            background: #0f1e36;
            color: #fff;
            border: none;
            padding: 8px 18px;
            font-size: 12px;
            font-weight: 600;
            border-radius: 6px;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <div class='print-btn-bar no-print'>
        <button onclick='window.print();' class='print-btn'>Print / Save as PDF</button>
    </div>
    <div class='header'>
        <div class='title'>Lahore Gymkhana Club</div>
        <div class='subtitle'>Member Fee Disbursement &amp; Head Allocation Report</div>
        <div class='meta-info'>
            <span><strong>Scope:</strong> Grouped by Member</span>
            <span><strong>Total Members:</strong> " + totalMembers + @"</span>
            <span><strong>Generated On:</strong> " + generatedDate + @"</span>
        </div>
    </div>

    <table>
        <thead>
            <tr>
                <th style='width: 35px; text-align: center;'>Sr#</th>
                <th style='width: 65px;'>App No</th>
                <th style='width: 85px;'>Member No</th>
                <th style='width: 140px;'>Member Name</th>
                <th style='width: 115px;'>CNIC</th>
                <th>Disbursed Finance Heads &amp; Breakdown</th>
                <th style='width: 110px;' class='text-right'>Total Amount</th>
                <th style='width: 85px;' class='text-center'>Date</th>
            </tr>
        </thead>
        <tbody>");

            if (groups.Count > 0)
            {
                foreach (var grp in groups)
                {
                    html.Append("<tr>");
                    html.Append("<td class='text-center'>" + grp.SrNo + "</td>");
                    html.Append("<td class='app-no'>#" + Server.HtmlEncode(grp.ApplicationNo) + "</td>");
                    html.Append("<td><span class='mem-no'>" + Server.HtmlEncode(grp.MemberNo) + "</span></td>");
                    html.Append("<td><strong>" + Server.HtmlEncode(grp.MemberName) + "</strong><br/><small style='color:#64748b;'>" + Server.HtmlEncode(grp.MembershipCategory) + "</small></td>");
                    html.Append("<td style='font-family:monospace;'>" + Server.HtmlEncode(grp.NIC) + "</td>");

                    // Heads Breakdown HTML
                    StringBuilder headsHtml = new StringBuilder();
                    if (grp.Heads != null && grp.Heads.Count > 0)
                    {
                        foreach (var h in grp.Heads)
                        {
                            headsHtml.Append("<div class='head-row'>");
                            headsHtml.Append("<div><span class='code-badge'>" + Server.HtmlEncode(h.ECode) + "</span> <span>" + Server.HtmlEncode(h.HeadType) + "</span></div>");
                            headsHtml.Append("<span style='font-weight:bold; color:#16a34a; white-space:nowrap;'>Rs. " + h.Amount.ToString("N2") + "</span>");
                            headsHtml.Append("</div>");
                        }
                    }
                    else
                    {
                        headsHtml.Append("<span style='color:#94a3b8; font-style:italic;'>No heads allocated</span>");
                    }
                    html.Append("<td>" + headsHtml.ToString() + "</td>");

                    html.Append("<td class='text-right bold' style='font-size:9.5pt;'>Rs. " + grp.TotalAmount.ToString("N2") + "</td>");
                    html.Append("<td class='text-center' style='font-size:8.5pt; color:#475569;'>" + (grp.CreatedDate.HasValue ? grp.CreatedDate.Value.ToString("dd-MMM-yyyy") : "—") + "</td>");
                    html.Append("</tr>");
                }

                // Add Totals Summary Row
                html.Append("<tr class='total-row'>");
                html.Append("<td colspan='6' class='text-right bold'>Grand Total (" + totalMembers + " Members):</td>");
                html.Append("<td class='text-right bold' style='font-size:10.5pt; color:#16a34a;'>Rs. " + grandTotal.ToString("N2") + "</td>");
                html.Append("<td></td>");
                html.Append("</tr>");
            }
            else
            {
                html.Append("<tr><td colspan='8' class='text-center' style='padding: 25px; color: #64748b;'>No fee disbursement records found matching the criteria.</td></tr>");
            }

            string preparedBy = GetPreparedByName();
            string checkedBy = GetCheckedByName();

            html.Append(@"
        </tbody>
    </table>

    <div class='signature-section' style='display: flex; justify-content: space-between; margin-top: 50px; padding: 0 40px;'>
        <div class='sig-box' style='width: 38%; text-align: center; border-top: 1.5px solid #0f1e36; padding-top: 8px; font-size: 9pt; font-weight: 700; color: #1e293b;'>
            <div>Prepared By: <span style='font-weight: 600;'>" + Server.HtmlEncode(preparedBy) + @"</span></div>
        </div>
        <div class='sig-box' style='width: 38%; text-align: center; border-top: 1.5px solid #0f1e36; padding-top: 8px; font-size: 9pt; font-weight: 700; color: #1e293b;'>
            <div>Checked By: <span style='font-weight: 600;'>" + Server.HtmlEncode(checkedBy) + @"</span></div>
        </div>
    </div>
</body>
</html>");

            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = "text/html";
            Response.Output.Write(html.ToString());
            Response.Flush();
            Response.End();
        }

        public string GetPreparedByName()
        {
            if (Session["Emp_Name"] != null && !string.IsNullOrWhiteSpace(Session["Emp_Name"].ToString()))
                return Session["Emp_Name"].ToString().Trim();
            if (Session["EmpName"] != null && !string.IsNullOrWhiteSpace(Session["EmpName"].ToString()))
                return Session["EmpName"].ToString().Trim();
            if (Session["EFName"] != null && !string.IsNullOrWhiteSpace(Session["EFName"].ToString()))
                return Session["EFName"].ToString().Trim();
            if (Session["UserName"] != null && !string.IsNullOrWhiteSpace(Session["UserName"].ToString()))
                return Session["UserName"].ToString().Trim();
            if (Session["User_Name"] != null && !string.IsNullOrWhiteSpace(Session["User_Name"].ToString()))
                return Session["User_Name"].ToString().Trim();

            return "Accounts Staff";
        }

        public string GetCheckedByName()
        {
            if (Session["CheckedBy"] != null && !string.IsNullOrWhiteSpace(Session["CheckedBy"].ToString()))
                return Session["CheckedBy"].ToString().Trim();
            if (Session["Checked_By"] != null && !string.IsNullOrWhiteSpace(Session["Checked_By"].ToString()))
                return Session["Checked_By"].ToString().Trim();
            if (Session["SupervisorName"] != null && !string.IsNullOrWhiteSpace(Session["SupervisorName"].ToString()))
                return Session["SupervisorName"].ToString().Trim();
            if (Session["Supervisor"] != null && !string.IsNullOrWhiteSpace(Session["Supervisor"].ToString()))
                return Session["Supervisor"].ToString().Trim();
            if (Session["ApprovedBy"] != null && !string.IsNullOrWhiteSpace(Session["ApprovedBy"].ToString()))
                return Session["ApprovedBy"].ToString().Trim();
            if (Session["ManagerName"] != null && !string.IsNullOrWhiteSpace(Session["ManagerName"].ToString()))
                return Session["ManagerName"].ToString().Trim();
            if (Session["UserRole"] != null && !string.IsNullOrWhiteSpace(Session["UserRole"].ToString()) && Session["UserRole"].ToString() != "Member")
                return Session["UserRole"].ToString().Trim();

            return "";
        }

        private string EscapeCsv(string val)
        {
            if (string.IsNullOrEmpty(val)) return "\"\"";
            return "\"" + val.Replace("\"", "\"\"").Trim() + "\"";
        }

        public class MemberDisbursementGroup
        {
            public int SrNo { get; set; }
            public string ApplicationNo { get; set; }
            public string MemberNo { get; set; }
            public string MemberName { get; set; }
            public string NIC { get; set; }
            public string MembershipCategory { get; set; }
            public decimal TotalAmount { get; set; }
            public DateTime? CreatedDate { get; set; }
            public List<FeeHeadItem> Heads { get; set; }
        }

        public class FeeHeadItem
        {
            public string HeadId { get; set; }
            public string ECode { get; set; }
            public string HeadType { get; set; }
            public decimal Amount { get; set; }
        }

        private class HeadSummaryItem
        {
            public string HeadId { get; set; }
            public string ECode { get; set; }
            public string HeadType { get; set; }
            public decimal TotalAmount { get; set; }
            public HashSet<string> Members { get; set; }
        }
    }
}
