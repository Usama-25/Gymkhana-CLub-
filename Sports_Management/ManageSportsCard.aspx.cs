using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Collections.Generic;

public partial class ManageSportsCard : System.Web.UI.Page
{
    string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;

    private Dictionary<string, List<ActiveSubDetails>> _allActiveSubs = new Dictionary<string, List<ActiveSubDetails>>();

    public class ActiveSubDetails
    {
        public int MemberSubID { get; set; }
        public int SubscriptionID { get; set; }
        public string PackageName { get; set; }
        public string SportName { get; set; }
        public string SubscriptionType { get; set; }
        public bool IsActive { get; set; }
        public string ManualCardNo { get; set; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadDepartmentAndSubDepartment();
        }
    }

    private string GetBasicDataConnString()
    {
        return ConfigurationManager.ConnectionStrings["BasicDataInfoConnString"] != null
            ? ConfigurationManager.ConnectionStrings["BasicDataInfoConnString"].ConnectionString
            : (ConfigurationManager.ConnectionStrings["BasicDataInfoConnectionString"] != null
                ? ConfigurationManager.ConnectionStrings["BasicDataInfoConnectionString"].ConnectionString
                : connString.Replace("SportsModuleDB", "BasicDataInfo"));
    }

    private bool IsAdminOrMIS()
    {
        if (Session["UserRole"] != null)
        {
            string role = Session["UserRole"].ToString();
            if (role.Equals("Admin", StringComparison.OrdinalIgnoreCase) ||
                role.Equals("Administrator", StringComparison.OrdinalIgnoreCase))
                return true;
        }

        string deptName = Session["DeptName"] != null ? Session["DeptName"].ToString() : "";
        string subDeptName = Session["SubDeptName"] != null ? Session["SubDeptName"].ToString() : "";
        string empType = Session["Emp_Type"] != null ? Session["Emp_Type"].ToString() : "";
        string username = Session["Username"] != null ? Session["Username"].ToString() : (Session["UserName"] != null ? Session["UserName"].ToString() : "");

        if (username.Equals("admin", StringComparison.OrdinalIgnoreCase) ||
            empType.IndexOf("Admin", StringComparison.OrdinalIgnoreCase) >= 0 ||
            deptName.IndexOf("Admin", StringComparison.OrdinalIgnoreCase) >= 0 ||
            subDeptName.IndexOf("MIS", StringComparison.OrdinalIgnoreCase) >= 0 ||
            subDeptName.IndexOf("IT", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            return true;
        }

        return false;
    }

    private void LoadDepartmentAndSubDepartment()
    {
        try
        {
            DataTable dt = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = @"
                    SELECT DISTINCT ISNULL(sp.Dept_ID, sp.SportID) AS Dept_ID, 
                           ISNULL(d.Dept_Name, sp.SportName) AS Dept_Name 
                    FROM Sports sp 
                    LEFT JOIN BasicDataInfo.dbo.Department d ON sp.Dept_ID = d.Dept_ID 
                    WHERE sp.Status = 1 
                    ORDER BY ISNULL(d.Dept_Name, sp.SportName)";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            if (dt == null || dt.Rows.Count == 0)
            {
                using (SqlConnection con = new SqlConnection(connString))
                {
                    string query = "SELECT DISTINCT ISNULL(Dept_ID, SportID) AS Dept_ID, SportName AS Dept_Name FROM Sports WHERE Status = 1 ORDER BY SportName";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }
                    }
                }
            }

            bool adminOrMIS = IsAdminOrMIS();

            DataView dv = dt.DefaultView;
            int userDeptId = 0;
            if (Session["DeptID"] != null) int.TryParse(Session["DeptID"].ToString(), out userDeptId);
            else if (Session["Dept_ID"] != null) int.TryParse(Session["Dept_ID"].ToString(), out userDeptId);
            else if (Session["DepartmentID"] != null) int.TryParse(Session["DepartmentID"].ToString(), out userDeptId);

            string sessionDeptName = Session["DeptName"] != null ? Session["DeptName"].ToString() : (Session["Dept_Name"] != null ? Session["Dept_Name"].ToString() : "");

            if (!adminOrMIS)
            {
                List<int> allowedDepts = Session["AllowedDepartments"] as List<int>;
                if (allowedDepts != null && allowedDepts.Count > 0)
                {
                    dv.RowFilter = "Dept_ID IN (" + string.Join(",", allowedDepts) + ")";
                }
                else if (userDeptId > 0)
                {
                    dv.RowFilter = "Dept_ID = " + userDeptId;
                }
            }

            if (ddlDepartment != null)
            {
                ddlDepartment.DataSource = dv;
                ddlDepartment.DataTextField = "Dept_Name";
                ddlDepartment.DataValueField = "Dept_ID";
                ddlDepartment.DataBind();

                if (adminOrMIS)
                {
                    ddlDepartment.Items.Insert(0, new ListItem("-- All Departments --", "0"));
                    ddlDepartment.Enabled = true;
                    ddlDepartment.Attributes["style"] = "font-size:12px; padding:2px 8px; height:30px; font-weight:600; border-color:#93c5fd;";

                    if (userDeptId > 0 && ddlDepartment.Items.FindByValue(userDeptId.ToString()) != null)
                    {
                        ddlDepartment.SelectedValue = userDeptId.ToString();
                    }
                    else
                    {
                        ddlDepartment.SelectedIndex = 0;
                    }
                }
                else
                {
                    // Department-specific operator
                    if (userDeptId > 0 && ddlDepartment.Items.FindByValue(userDeptId.ToString()) != null)
                    {
                        ddlDepartment.SelectedValue = userDeptId.ToString();
                    }
                    else if (!string.IsNullOrEmpty(sessionDeptName))
                    {
                        ddlDepartment.Items.Clear();
                        ddlDepartment.Items.Add(new ListItem(sessionDeptName, userDeptId.ToString()));
                        ddlDepartment.SelectedIndex = 0;
                    }

                    if (dv.Count <= 1)
                    {
                        ddlDepartment.Enabled = false;
                        ddlDepartment.Attributes["style"] = "font-size:12px; padding:2px 8px; height:30px; font-weight:600; border-color:#93c5fd; background-color:#f1f5f9; cursor:not-allowed;";
                    }
                    else
                    {
                        ddlDepartment.Items.Insert(0, new ListItem("-- Select Department --", "0"));
                        ddlDepartment.Enabled = true;
                        ddlDepartment.Attributes["style"] = "font-size:12px; padding:2px 8px; height:30px; font-weight:600; border-color:#93c5fd;";
                    }
                }
            }

            int currentDeptId = 0;
            if (ddlDepartment != null && !string.IsNullOrEmpty(ddlDepartment.SelectedValue))
            {
                int.TryParse(ddlDepartment.SelectedValue, out currentDeptId);
            }
            if (currentDeptId == 0 && userDeptId > 0)
            {
                currentDeptId = userDeptId;
            }

            LoadSubDepartments(currentDeptId);
        }
        catch (Exception ex)
        {
            if (ddlDepartment != null)
            {
                ddlDepartment.Items.Clear();
                ddlDepartment.Items.Add(new ListItem("-- All Departments --", "0"));
            }
            ShowMessage("Error loading departments: " + ex.Message, false);
        }
    }

    private void LoadSubDepartments(int deptId)
    {
        if (ddlSubDept == null) return;
        ddlSubDept.Items.Clear();

        int userSubDeptId = 0;
        if (Session["SubDeptID"] != null) int.TryParse(Session["SubDeptID"].ToString(), out userSubDeptId);
        else if (Session["subdept_id"] != null) int.TryParse(Session["subdept_id"].ToString(), out userSubDeptId);
        else if (Session["SubDeptId"] != null) int.TryParse(Session["SubDeptId"].ToString(), out userSubDeptId);

        string subDeptName = Session["SubDeptName"] != null ? Session["SubDeptName"].ToString() : (Session["subdept_name"] != null ? Session["subdept_name"].ToString() : "");

        try
        {
            DataTable dtSub = new DataTable();
            using (SqlConnection con = new SqlConnection(GetBasicDataConnString()))
            {
                string query = "SELECT SubDept_Id, SubDept_Name FROM SubDepartment WHERE (Dept_ID = @DeptID OR @DeptID = 0) ORDER BY SubDept_Name";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@DeptID", deptId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dtSub);
                    }
                }
            }

            if (dtSub.Rows.Count > 0)
            {
                ddlSubDept.DataSource = dtSub;
                ddlSubDept.DataTextField = "SubDept_Name";
                ddlSubDept.DataValueField = "SubDept_Id";
                ddlSubDept.DataBind();
            }
        }
        catch { }

        bool adminOrMIS = IsAdminOrMIS();

        if (adminOrMIS)
        {
            ddlSubDept.Items.Insert(0, new ListItem("-- All Sub Departments --", "0"));
            ddlSubDept.Enabled = true;
            ddlSubDept.Attributes["style"] = "font-size:12px; padding:2px 8px; height:30px; font-weight:600; border-color:#93c5fd;";

            if (userSubDeptId > 0 && ddlSubDept.Items.FindByValue(userSubDeptId.ToString()) != null)
            {
                ddlSubDept.SelectedValue = userSubDeptId.ToString();
            }
            else
            {
                ddlSubDept.SelectedIndex = 0;
            }
        }
        else
        {
            if (userSubDeptId > 0 && ddlSubDept.Items.FindByValue(userSubDeptId.ToString()) != null)
            {
                ddlSubDept.SelectedValue = userSubDeptId.ToString();
            }
            else if (!string.IsNullOrEmpty(subDeptName))
            {
                ddlSubDept.Items.Clear();
                ddlSubDept.Items.Add(new ListItem(subDeptName, userSubDeptId.ToString()));
                ddlSubDept.SelectedIndex = 0;
            }
            else if (ddlSubDept.Items.Count == 0)
            {
                ddlSubDept.Items.Add(new ListItem("-- General --", "0"));
            }

            ddlSubDept.Enabled = false;
            ddlSubDept.Attributes["style"] = "font-size:12px; padding:2px 8px; height:30px; font-weight:600; border-color:#93c5fd; background-color:#f1f5f9; cursor:not-allowed; pointer-events:none;";
        }
    }

    protected void ddlDepartment_SelectedIndexChanged(object sender, EventArgs e)
    {
        int selectedDeptId = 0;
        if (ddlDepartment != null)
        {
            int.TryParse(ddlDepartment.SelectedValue, out selectedDeptId);
        }
        LoadSubDepartments(selectedDeptId);
    }

    protected void ddlSubDept_SelectedIndexChanged(object sender, EventArgs e)
    {
    }

    /* Default date helpers used by GridView item templates */
    protected string GetDefaultStartDate()
    {
        return DateTime.Today.ToString("yyyy-MM-dd");
    }
    protected string GetDefaultEndDate()
    {
        var today = DateTime.Today;
        return new DateTime(today.Year, today.Month, DateTime.DaysInMonth(today.Year, today.Month)).ToString("yyyy-MM-dd");
    }

    protected void ShowMessage(string msg, bool isSuccess)
    {
        lblMessage.Visible = true;
        lblMessage.Text = msg;
        lblMessage.CssClass = isSuccess ? "alert alert-success" : "alert alert-danger";
        lblMessage.Style["background-color"] = isSuccess ? "#d4edda" : "#f8d7da";
        lblMessage.Style["color"] = isSuccess ? "#155724" : "#721c24";
        lblMessage.Style["border"] = isSuccess ? "1px solid #c3e6cb" : "1px solid #f5c6cb";
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        lblMessage.Visible = false;
        pnlSearchResults.Visible = false;
        pnlActiveSportsWarning.Visible = false;
        ucMemberSubInfo.Clear();

        if (string.IsNullOrWhiteSpace(txtSearch.Text))
        {
            ShowMessage("Enter search criteria.", false);
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

                            // Add required columns
                            if (!dt.Columns.Contains("Relationship")) dt.Columns.Add("Relationship", typeof(string));
                            if (!dt.Columns.Contains("SubscriptionStatus")) dt.Columns.Add("SubscriptionStatus", typeof(string));
                            if (!dt.Columns.Contains("ActiveCardTypeID")) dt.Columns.Add("ActiveCardTypeID", typeof(string));
                            if (!dt.Columns.Contains("ActiveSubType")) dt.Columns.Add("ActiveSubType", typeof(string));
                            if (!dt.Columns.Contains("ActiveSportsCardSubID")) dt.Columns.Add("ActiveSportsCardSubID", typeof(int));
                            if (!dt.Columns.Contains("HasActiveSportsCard")) dt.Columns.Add("HasActiveSportsCard", typeof(bool));
                            if (!dt.Columns.Contains("ManualCardNo")) dt.Columns.Add("ManualCardNo", typeof(string));

                            // Get unique MemberIDs
                            List<int> memberIds = new List<int>();
                            foreach (DataRow row in dt.Rows)
                            {
                                int mid = Convert.ToInt32(row["MemberID"]);
                                if (!memberIds.Contains(mid)) memberIds.Add(mid);

                                string memberNo = row["MembershipNo"].ToString();
                                string rel = row["Relationship"].ToString();
                                if (string.IsNullOrEmpty(rel) || rel == "Self" || rel == "Dependent")
                                {
                                    rel = GetRelationFromMemberNo(memberNo);
                                    row["Relationship"] = rel;
                                }
                            }

                            // Auto-check and apply Non Playing Contribution for members with no active sports
                            if (con.State != ConnectionState.Open) con.Open();
                            foreach (int mid in memberIds)
                            {
                                using (SqlCommand npCmd = new SqlCommand("sp_CheckAndApplyNonPlayingContribution", con))
                                {
                                    npCmd.CommandType = CommandType.StoredProcedure;
                                    npCmd.Parameters.AddWithValue("@MemberID", mid);
                                    npCmd.ExecuteNonQuery();
                                }
                            }

                            // Fetch active subscriptions and latest continuous for these MemberIDs
                            string idList = string.Join(",", memberIds);
                            _allActiveSubs.Clear();

                            if (!string.IsNullOrEmpty(idList))
                            {
                                string queryStr = string.Format(@"
                                    SELECT ms.MemberSubID, ms.MemberID, ms.DependentMemberNo, sub.PackageName, sub.SubscriptionType, ms.IsActive, sp.SportName, ms.SubscriptionID, ms.ManualCardNo 
                                    FROM MemberSubscriptions ms 
                                    INNER JOIN Subscriptions sub ON ms.SubscriptionID = sub.SubscriptionID 
                                    INNER JOIN Sports sp ON sub.SportID = sp.SportID 
                                    WHERE ms.MemberID IN ({0}) 
                                      AND (ms.IsActive = 1 OR (sub.SubscriptionType = 'Continuous' AND ms.MemberSubID IN (
                                          SELECT MAX(ms2.MemberSubID) 
                                          FROM MemberSubscriptions ms2 
                                          INNER JOIN Subscriptions sub2 ON ms2.SubscriptionID = sub2.SubscriptionID 
                                          WHERE ms2.MemberID = ms.MemberID 
                                            AND sub2.SubscriptionType = 'Continuous' 
                                          GROUP BY ms2.SubscriptionID, ms2.DependentMemberNo
                                      )))", idList);

                                if (Session["UserRole"] != null && Session["UserRole"].ToString() == "Operator")
                                {
                                    List<int> allowedSports = Session["AllowedSports"] as List<int>;
                                    if (allowedSports != null && allowedSports.Count > 0)
                                    {
                                        queryStr += " AND sub.SportID IN (" + string.Join(",", allowedSports) + ")";
                                    }
                                    else
                                    {
                                        queryStr += " AND sub.SportID = -1";
                                    }
                                }

                                using (SqlCommand subCmd = new SqlCommand(queryStr, con))
                                {
                                    if (con.State != System.Data.ConnectionState.Open) con.Open();
                                    using (SqlDataReader dr = subCmd.ExecuteReader())
                                    {
                                        while (dr.Read())
                                        {
                                            ActiveSubDetails sub = new ActiveSubDetails();
                                            sub.MemberSubID = dr.GetInt32(0);
                                            int mid = dr.GetInt32(1);
                                            string depNo = dr.IsDBNull(2) ? "" : dr.GetString(2);
                                            sub.PackageName = dr.GetString(3);
                                            sub.SubscriptionType = dr.GetString(4);
                                            sub.IsActive = dr.GetBoolean(5);
                                            sub.SportName = dr.IsDBNull(6) ? sub.PackageName : dr.GetString(6);
                                            sub.SubscriptionID = dr.GetInt32(7);
                                            sub.ManualCardNo = dr.FieldCount > 8 && !dr.IsDBNull(8) ? dr.GetString(8) : "";

                                            string key = mid.ToString() + "_" + depNo;
                                            if (!_allActiveSubs.ContainsKey(key))
                                                _allActiveSubs[key] = new List<ActiveSubDetails>();

                                            _allActiveSubs[key].Add(sub);
                                        }
                                    }
                                }
                            }

                            List<string> allActiveSportsList = new List<string>();
                            foreach (DataRow row in dt.Rows)
                            {
                                int mid = Convert.ToInt32(row["MemberID"]);
                                string memberNo = row["MembershipNo"].ToString();
                                string rel = row["Relationship"].ToString();

                                string key = mid.ToString() + "_" + (rel == "Self" ? "" : memberNo);

                                string activeCardTypeId = "";
                                string activeSubType = "Monthly";
                                int activeCardSubId = 0;
                                bool hasActiveCard = false;
                                string activeManualCard = "";

                                if (_allActiveSubs.ContainsKey(key) && _allActiveSubs[key].Count > 0)
                                {
                                    List<string> activeNames = new List<string>();
                                    foreach (var sub in _allActiveSubs[key])
                                    {
                                        if (sub.IsActive && sub.SportName != "Non Playing")
                                        {
                                            string displayName = sub.SportName;

                                            bool isCard = (sub.SubscriptionID >= 17 && sub.SubscriptionID <= 20) ||
                                                          (!string.IsNullOrEmpty(sub.SportName) && sub.SportName.StartsWith("Sports Card", StringComparison.OrdinalIgnoreCase)) ||
                                                          (!string.IsNullOrEmpty(sub.PackageName) && sub.PackageName.IndexOf("Sports Card", StringComparison.OrdinalIgnoreCase) >= 0);

                                            if (isCard)
                                            {
                                                displayName = GetCardTypeName(sub.SubscriptionID, sub.PackageName);
                                                activeCardTypeId = sub.SubscriptionID.ToString();
                                                if (!string.IsNullOrEmpty(sub.SubscriptionType))
                                                    activeSubType = sub.SubscriptionType;

                                                activeCardSubId = sub.MemberSubID;
                                                hasActiveCard = true;

                                                if (!string.IsNullOrEmpty(sub.ManualCardNo))
                                                    activeManualCard = sub.ManualCardNo;
                                            }

                                            activeNames.Add(displayName);
                                            if (!allActiveSportsList.Contains(displayName))
                                                allActiveSportsList.Add(displayName);
                                        }
                                    }
                                    row["SubscriptionStatus"] = activeNames.Count > 0 ? string.Join(", ", activeNames) : "None";
                                }
                                else
                                {
                                    row["SubscriptionStatus"] = "None";
                                }

                                row["HasActiveSportsCard"] = hasActiveCard;
                                row["ActiveSportsCardSubID"] = activeCardSubId;

                                if (string.IsNullOrEmpty(activeCardTypeId))
                                {
                                    activeCardTypeId = GetDefaultCardType(rel);
                                }

                                row["ActiveCardTypeID"] = activeCardTypeId;
                                row["ActiveSubType"] = activeSubType;
                                row["ManualCardNo"] = activeManualCard;
                            }

                            if (allActiveSportsList.Count > 0)
                            {
                                string sportsStr = string.Join(", ", allActiveSportsList);
                                pnlActiveSportsWarning.Visible = true;
                                lblActiveSportsList.Text = sportsStr;
                                hfHasActiveMonthly.Value = sportsStr;
                            }
                            else
                            {
                                pnlActiveSportsWarning.Visible = false;
                                hfHasActiveMonthly.Value = "none";
                            }

                            gvMemberResults.DataSource = dt;
                            gvMemberResults.DataBind();

                            if (dt.Rows.Count > 0)
                            {
                                string defaultCardType = dt.Rows[0]["ActiveCardTypeID"].ToString();
                                string defaultSubType = dt.Rows[0]["ActiveSubType"].ToString();

                                if (!string.IsNullOrEmpty(defaultCardType) && ddlCardType.Items.FindByValue(defaultCardType) != null)
                                {
                                    ddlCardType.SelectedValue = defaultCardType;
                                }
                                if (!string.IsNullOrEmpty(defaultSubType) && ddlSubType.Items.FindByValue(defaultSubType) != null)
                                {
                                    ddlSubType.SelectedValue = defaultSubType;
                                }
                            }
                        }
                        else
                        {
                            ShowMessage("No members found.", false);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, false);
        }
    }





    protected void ddlPaymentMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        pnlRefID.Visible = (ddlPaymentMode.SelectedValue != "Cash");
    }

    protected string GetCardTypeName(int subId, string packageName = null)
    {
        switch (subId)
        {
            case 17: return "Family Sports Card";
            case 18: return "Couple Sports Card";
            case 19: return "Individual / Child Sports Card";
            case 20: return "Non Earning Sports Card";
            default:
                if (!string.IsNullOrWhiteSpace(packageName))
                    return packageName;
                return "Sports Card";
        }
    }

    protected string GetDefaultCardType(string relationship)
    {
        if (string.IsNullOrEmpty(relationship)) return "17";
        string r = relationship.Trim();
        if (r.Equals("Self", StringComparison.OrdinalIgnoreCase) || r.Equals("Main Member", StringComparison.OrdinalIgnoreCase))
            return "17"; // Family Sports Card
        else if (r.Equals("Spouse", StringComparison.OrdinalIgnoreCase))
            return "18"; // Couple Sports Card
        else
            return "19"; // Individual / Child Sports Card
    }

    protected void btnAssign_Click(object sender, EventArgs e)
    {
        string[] checkedRows = Request.Form.GetValues("cbMember");
        if (checkedRows == null || checkedRows.Length == 0)
        {
            ShowMessage("Please select at least one member from the grid.", false);
            return;
        }

        string globalCardType = ddlCardType.SelectedValue;
        string globalSubType = ddlSubType.SelectedValue;
        string manualCardNo = txtManualCardNo != null ? txtManualCardNo.Text.Trim() : "";

        int successCount = 0;
        var errors = new List<string>();

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();

                // --- Pre-validate Manual Register / Card No month-wise duplicate check ---
                var usedInBatch = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                foreach (string itemVal in checkedRows)
                {
                    string[] parts = itemVal.Split('|');
                    if (parts.Length < 4) continue;
                    string idxStr = parts[0];
                    string membershipNo = parts[2];
                    string rowManualCardNo = Request.Form["mc_" + idxStr];
                    if (rowManualCardNo != null) rowManualCardNo = rowManualCardNo.Trim();
                    if (string.IsNullOrEmpty(rowManualCardNo) && !string.IsNullOrEmpty(manualCardNo))
                    {
                        rowManualCardNo = manualCardNo;
                    }

                    if (!string.IsNullOrWhiteSpace(rowManualCardNo))
                    {
                        string startDateStr = Request.Form["sd_" + idxStr];
                        DateTime rowStartDate = DateTime.Today;
                        if (!string.IsNullOrEmpty(startDateStr)) DateTime.TryParse(startDateStr, out rowStartDate);

                        string batchKey = rowManualCardNo.ToUpper() + "_" + rowStartDate.Year + "_" + rowStartDate.Month;
                        if (usedInBatch.Contains(batchKey))
                        {
                            ShowMessage("Duplicate Manual Register / Card No '" + rowManualCardNo + "' entered for multiple members in the current batch for " + rowStartDate.ToString("MMMM yyyy") + "! Please enter unique card numbers.", false);
                            return;
                        }
                        usedInBatch.Add(batchKey);

                        string conflict = CheckCardDuplicateInMonth(con, rowManualCardNo, rowStartDate);
                        if (!string.IsNullOrEmpty(conflict))
                        {
                            ShowMessage("Manual Register / Card No '" + rowManualCardNo + "' has ALREADY been issued in " + rowStartDate.ToString("MMMM yyyy") + " to " + conflict + "! Please enter a unique Register / Card No.", false);
                            return;
                        }
                    }
                }

                foreach (string itemVal in checkedRows)
                {
                    // itemVal = "DataItemIndex|MemberID|MembershipNo|Relationship"
                    string[] parts = itemVal.Split('|');
                    if (parts.Length < 4) continue;

                    string idxStr = parts[0];
                    int memberId = Convert.ToInt32(parts[1]);
                    string membershipNo = parts[2];
                    string relationship = parts[3];
                    string status = parts.Length >= 5 ? parts[4] : "Active";

                    if (!IsAccountActive(status))
                    {
                        errors.Add(membershipNo + ": Cannot assign Sports Card (Account Status is " + status + ")");
                        continue;
                    }

                    string cardTypeStr = globalCardType;
                    string subTypeStr = globalSubType;
                    string startDateStr = Request.Form["sd_" + idxStr];
                    string endDateStr = Request.Form["ed_" + idxStr];

                    if (string.IsNullOrEmpty(cardTypeStr) || cardTypeStr == "0")
                        cardTypeStr = GetDefaultCardType(relationship);

                    int subId = Convert.ToInt32(cardTypeStr);

                    DateTime startDate = DateTime.Today;
                    DateTime? endDate = new DateTime(DateTime.Today.Year, DateTime.Today.Month,
                                          DateTime.DaysInMonth(DateTime.Today.Year, DateTime.Today.Month));

                    if (!string.IsNullOrEmpty(startDateStr)) DateTime.TryParse(startDateStr, out startDate);

                    if (subTypeStr == "Continuous")
                    {
                        endDate = null;
                    }
                    else
                    {
                        if (!string.IsNullOrEmpty(endDateStr))
                        {
                            DateTime dtTmp;
                            if (DateTime.TryParse(endDateStr, out dtTmp))
                                endDate = dtTmp;
                        }
                    }

                    bool isSelf = relationship.Equals("Self", StringComparison.OrdinalIgnoreCase) ||
                                  relationship.Equals("Main Member", StringComparison.OrdinalIgnoreCase) ||
                                  relationship.Equals("Master", StringComparison.OrdinalIgnoreCase);

                    string targetDep = isSelf ? null : membershipNo;

                    decimal paidAmt = 0m;
                    if (isSelf)
                    {
                        paidAmt = string.IsNullOrWhiteSpace(txtFee.Text) ? 0m : Convert.ToDecimal(txtFee.Text);
                    }
                    else
                    {
                        if (subId == 19 || subId == 20)
                            paidAmt = string.IsNullOrWhiteSpace(txtFee.Text) ? 0m : Convert.ToDecimal(txtFee.Text);
                        else
                            paidAmt = 0m; // Covered under Main Member's card payment
                    }

                    string rowManualCardNo = Request.Form["mc_" + idxStr];
                    if (rowManualCardNo != null) rowManualCardNo = rowManualCardNo.Trim();
                    if (string.IsNullOrEmpty(rowManualCardNo) && !string.IsNullOrEmpty(manualCardNo))
                    {
                        rowManualCardNo = manualCardNo;
                    }

                    try
                    {
                        using (SqlCommand cmd = new SqlCommand("sp_AssignSportsCardBulk", con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.AddWithValue("@MemberID", memberId);
                            cmd.Parameters.AddWithValue("@SubscriptionID", subId);
                            cmd.Parameters.AddWithValue("@TargetDependentNo", (object)targetDep ?? DBNull.Value);
                            cmd.Parameters.AddWithValue("@LockerID", 0);
                            cmd.Parameters.AddWithValue("@StartDate", startDate);
                            cmd.Parameters.AddWithValue("@EndDate", (object)endDate ?? DBNull.Value);
                            cmd.Parameters.AddWithValue("@PaymentMode", ddlPaymentMode.SelectedValue);
                            cmd.Parameters.AddWithValue("@RefID", ddlPaymentMode.SelectedValue != "Cash" ? txtRefID.Text : "");
                            cmd.Parameters.AddWithValue("@PaidAmount", paidAmt);
                            cmd.Parameters.AddWithValue("@ManualCardNo", string.IsNullOrEmpty(rowManualCardNo) ? (object)DBNull.Value : rowManualCardNo);

                            try
                            {
                                cmd.ExecuteNonQuery();
                            }
                            catch (SqlException ex)
                            {
                                if (ex.Number == 8144 || ex.Message.Contains("too many arguments"))
                                {
                                    if (cmd.Parameters.Contains("@ManualCardNo")) cmd.Parameters.Remove(cmd.Parameters["@ManualCardNo"]);
                                    cmd.ExecuteNonQuery();
                                }
                                else throw;
                            }
                            successCount++;
                        }
                    }
                    catch (Exception rowEx)
                    {
                        errors.Add(membershipNo + ": " + rowEx.Message);
                    }
                }
            }

            if (errors.Count == 0)
            {
                if (txtManualCardNo != null) txtManualCardNo.Text = "";
                ShowMessage(string.Format("Sports Card assigned successfully to {0} member(s)!", successCount), true);
            }
            else
            {
                ShowMessage(string.Format("{0} assigned. {1} error(s): " + string.Join("; ", errors), successCount, errors.Count),
                            errors.Count < checkedRows.Length);
            }

            btnSearch_Click(null, null);
        }
        catch (Exception ex)
        {
            ShowMessage("Error assigning card: " + ex.Message, false);
        }
    }

    private string CheckCardDuplicateInMonth(SqlConnection con, string cardNo, DateTime startDate)
    {
        if (string.IsNullOrWhiteSpace(cardNo)) return null;
        try
        {
            string sql = @"SELECT TOP 1 ISNULL(ms.DependentMemberNo, mp.MemberNo) AS MemberNo, 
                                  ISNULL(ms.DependentName, mp.FullName) AS PersonName
                           FROM MemberSubscriptions ms
                           LEFT JOIN Member_Profile mp ON ms.MemberID = mp.MemberID
                           WHERE UPPER(LTRIM(RTRIM(ms.ManualCardNo))) = @CardNo
                             AND YEAR(ms.StartDate) = @Year
                             AND MONTH(ms.StartDate) = @Month";
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@CardNo", cardNo.Trim().ToUpper());
                cmd.Parameters.AddWithValue("@Year", startDate.Year);
                cmd.Parameters.AddWithValue("@Month", startDate.Month);
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        string mNo = rdr["MemberNo"] != DBNull.Value ? rdr["MemberNo"].ToString() : "";
                        string pName = rdr["PersonName"] != DBNull.Value ? rdr["PersonName"].ToString() : "";
                        return pName + " (" + mNo + ")";
                    }
                }
            }
        }
        catch { }
        return null;
    }

    private static void EnsureDeactivatedOnColumn(SqlConnection con)
    {
        try
        {
            string sql = @"
                IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.MemberSubscriptions') AND name = 'DeactivatedOn')
                BEGIN
                    ALTER TABLE dbo.MemberSubscriptions ADD DeactivatedOn DATETIME NULL;
                END";
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }

    private static bool ColumnExists(SqlConnection con, string tableName, string columnName)
    {
        try
        {
            string sql = "SELECT COUNT(1) FROM sys.columns WHERE object_id = OBJECT_ID(@Table) AND name = @Column";
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@Table", "dbo." + tableName);
                cmd.Parameters.AddWithValue("@Column", columnName);
                int count = Convert.ToInt32(cmd.ExecuteScalar());
                return count > 0;
            }
        }
        catch
        {
            return false;
        }
    }

    protected void gvMemberResults_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "DeactivateCard")
        {
            string[] parts = e.CommandArgument.ToString().Split('|');
            int memberSubId = 0;
            if (parts.Length > 0) int.TryParse(parts[0], out memberSubId);
            string memberNo = parts.Length > 1 ? parts[1] : "";
            int memberId = parts.Length > 2 ? Convert.ToInt32(parts[2]) : 0;
            string rel = parts.Length > 3 ? parts[3] : "";

            try
            {
                using (SqlConnection con = new SqlConnection(connString))
                {
                    con.Open();
                    EnsureDeactivatedOnColumn(con);
                    bool hasDeactCol = ColumnExists(con, "MemberSubscriptions", "DeactivatedOn");

                    if (memberSubId > 0)
                    {
                        string query = hasDeactCol
                            ? "UPDATE MemberSubscriptions SET IsActive = 0, EndDate = CAST(GETDATE() AS DATE), DeactivatedOn = GETDATE() WHERE MemberSubID = @MemberSubID"
                            : "UPDATE MemberSubscriptions SET IsActive = 0, EndDate = CAST(GETDATE() AS DATE) WHERE MemberSubID = @MemberSubID";

                        using (SqlCommand cmd = new SqlCommand(query, con))
                        {
                            cmd.Parameters.AddWithValue("@MemberSubID", memberSubId);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else if (memberId > 0)
                    {
                        bool isSelf = rel.Equals("Self", StringComparison.OrdinalIgnoreCase) ||
                                      rel.Equals("Main Member", StringComparison.OrdinalIgnoreCase);
                        string targetDep = isSelf ? null : memberNo;

                        string setClause = hasDeactCol
                            ? "ms.IsActive = 0, ms.EndDate = CAST(GETDATE() AS DATE), ms.DeactivatedOn = GETDATE()"
                            : "ms.IsActive = 0, ms.EndDate = CAST(GETDATE() AS DATE)";

                        string query = string.Format(@"
                            UPDATE ms
                            SET {0}
                            FROM MemberSubscriptions ms
                            INNER JOIN Subscriptions sub ON ms.SubscriptionID = sub.SubscriptionID
                            INNER JOIN Sports sp ON sub.SportID = sp.SportID
                            WHERE ms.MemberID = @MemberID
                              AND ms.IsActive = 1
                              AND (sp.SportName LIKE '%Sports Card%' OR sub.PackageName LIKE '%Sports Card%' OR sub.SubscriptionID IN (17,18,19,20))
                              AND ISNULL(ms.DependentMemberNo, '') = ISNULL(@TargetDep, '')", setClause);

                        using (SqlCommand cmd = new SqlCommand(query, con))
                        {
                            cmd.Parameters.AddWithValue("@MemberID", memberId);
                            cmd.Parameters.AddWithValue("@TargetDep", (object)targetDep ?? DBNull.Value);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }

                ShowMessage(string.Format("Sports Card for {0} has been deactivated successfully.", memberNo), true);
                btnSearch_Click(null, null);
            }
            catch (Exception ex)
            {
                ShowMessage("Error deactivating sports card: " + ex.Message, false);
            }
        }
    }

    protected void btnDeactivateSelected_Click(object sender, EventArgs e)
    {
        string[] checkedRows = Request.Form.GetValues("cbMember");
        if (checkedRows == null || checkedRows.Length == 0)
        {
            ShowMessage("Please select at least one member from the grid to deactivate.", false);
            return;
        }

        int deactivatedCount = 0;
        var errors = new List<string>();

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                EnsureDeactivatedOnColumn(con);
                bool hasDeactCol = ColumnExists(con, "MemberSubscriptions", "DeactivatedOn");

                foreach (string itemVal in checkedRows)
                {
                    string[] parts = itemVal.Split('|');
                    if (parts.Length < 4) continue;

                    int memberId = Convert.ToInt32(parts[1]);
                    string membershipNo = parts[2];
                    string relationship = parts[3];

                    bool isSelf = relationship.Equals("Self", StringComparison.OrdinalIgnoreCase) ||
                                  relationship.Equals("Main Member", StringComparison.OrdinalIgnoreCase);

                    string targetDep = isSelf ? null : membershipNo;

                    string setClause = hasDeactCol
                        ? "ms.IsActive = 0, ms.EndDate = CAST(GETDATE() AS DATE), ms.DeactivatedOn = GETDATE()"
                        : "ms.IsActive = 0, ms.EndDate = CAST(GETDATE() AS DATE)";

                    string query = string.Format(@"
                        UPDATE ms
                        SET {0}
                        FROM MemberSubscriptions ms
                        INNER JOIN Subscriptions sub ON ms.SubscriptionID = sub.SubscriptionID
                        INNER JOIN Sports sp ON sub.SportID = sp.SportID
                        WHERE ms.MemberID = @MemberID
                          AND ms.IsActive = 1
                          AND (sp.SportName LIKE '%Sports Card%' OR sub.PackageName LIKE '%Sports Card%' OR sub.SubscriptionID IN (17,18,19,20))
                          AND ISNULL(ms.DependentMemberNo, '') = ISNULL(@TargetDep, '')", setClause);

                    try
                    {
                        using (SqlCommand cmd = new SqlCommand(query, con))
                        {
                            cmd.Parameters.AddWithValue("@MemberID", memberId);
                            cmd.Parameters.AddWithValue("@TargetDep", (object)targetDep ?? DBNull.Value);
                            int affected = cmd.ExecuteNonQuery();
                            if (affected > 0)
                                deactivatedCount++;
                        }
                    }
                    catch (Exception rowEx)
                    {
                        errors.Add(membershipNo + ": " + rowEx.Message);
                    }
                }
            }

            if (deactivatedCount > 0)
                ShowMessage(string.Format("Sports Card(s) successfully deactivated for {0} member(s).", deactivatedCount), true);
            else
                ShowMessage("No active sports cards found to deactivate for the selected member(s).", false);

            btnSearch_Click(null, null);
        }
        catch (Exception ex)
        {
            ShowMessage("Error deactivating sports cards: " + ex.Message, false);
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

    protected string GetRelationshipBadgeStyle(string relationship)
    {
        string baseStyle = "padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 700; text-transform: uppercase; display: inline-block;";
        if (relationship == "Self" || relationship == "Main Member")
        {
            return baseStyle + " background-color: #d1fae5; color: #065f46;";
        }
        else if (relationship == "Spouse")
        {
            return baseStyle + " background-color: #dbeafe; color: #1e40af;";
        }
        else
        {
            return baseStyle + " background-color: #f3f4f6; color: #374151;";
        }
    }

    protected string GetAccountStatusBadgeStyle(string status)
    {
        string baseStyle = "padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 700; text-transform: uppercase; display: inline-block;";
        if (status == "Active" || status == "True")
        {
            return baseStyle + " background-color: #d1fae5; color: #065f46;";
        }
        else if (status == "Deactive" || status == "Inactive" || status == "False")
        {
            return baseStyle + " background-color: #fee2e2; color: #991b1b;";
        }
        else if (status == "Block")
        {
            return baseStyle + " background-color: #fef3c7; color: #92400e;";
        }
        else // Terminate
        {
            return baseStyle + " background-color: #e5e7eb; color: #1f2937;";
        }
    }

    protected bool IsAccountActive(string status)
    {
        if (string.IsNullOrEmpty(status)) return false;
        string s = status.Trim().ToLower();
        return s == "active" || s == "true";
    }

    protected string GetSubStatusStyle(string subStatus)
    {
        string baseStyle = "padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 600; display: inline-block; word-break: break-all; max-width: 250px;";
        if (string.IsNullOrEmpty(subStatus) || subStatus.Equals("None", StringComparison.OrdinalIgnoreCase))
        {
            return baseStyle + " background-color: #f3f4f6; color: #9ca3af; font-style: italic;";
        }
        else
        {
            return baseStyle + " background-color: #ecfdf5; color: #047857; border: 1px solid #a7f3d0;";
        }
    }
}
