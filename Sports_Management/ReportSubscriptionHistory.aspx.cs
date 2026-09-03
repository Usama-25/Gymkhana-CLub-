using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.Linq;
using System.Globalization;

public partial class ReportSubscriptionHistory : System.Web.UI.Page
{
    string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            DateTime today = DateTime.Today;
            DateTime firstDayOfMonth = new DateTime(today.Year, today.Month, 1);

            txtFromDate.Text = firstDayOfMonth.ToString("yyyy-MM-dd");
            txtToDate.Text = today.ToString("yyyy-MM-dd");

            LoadSports();
            LoadReport();
        }
    }

    protected void gvHistory_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvHistory.PageIndex = e.NewPageIndex;
        LoadReport();
    }

    protected void btnGenerate_Click(object sender, EventArgs e)
    {
        gvHistory.PageIndex = 0;
        LoadReport();
    }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        txtSearchMember.Text = "";

        int userDeptId = 0;
        if (Session["DeptID"] != null) int.TryParse(Session["DeptID"].ToString(), out userDeptId);
        else if (Session["Dept_ID"] != null) int.TryParse(Session["Dept_ID"].ToString(), out userDeptId);

        if (userDeptId > 0 && ddlSports.Items.FindByValue(userDeptId.ToString()) != null)
        {
            ddlSports.SelectedValue = userDeptId.ToString();
        }
        else if (ddlSports.Items.FindByValue("0") != null)
            ddlSports.SelectedValue = "0";
        else if (ddlSports.Items.Count > 0)
            ddlSports.SelectedIndex = 0;

        ddlActionType.SelectedValue = "ALL";

        DateTime today = DateTime.Today;
        DateTime firstDayOfMonth = new DateTime(today.Year, today.Month, 1);

        txtFromDate.Text = firstDayOfMonth.ToString("yyyy-MM-dd");
        txtToDate.Text = today.ToString("yyyy-MM-dd");

        gvHistory.PageIndex = 0;
        LoadReport();
    }

    private string GetBasicDataConnString()
    {
        return ConfigurationManager.ConnectionStrings["BasicDataInfoConnString"] != null
            ? ConfigurationManager.ConnectionStrings["BasicDataInfoConnString"].ConnectionString
            : connString.Replace("SportsModuleDB", "BasicDataInfo");
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

    private void LoadSports()
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

            bool adminOrMIS = IsAdminOrMIS();

            DataView dv = dt.DefaultView;
            int userDeptId = 0;
            if (Session["DeptID"] != null) int.TryParse(Session["DeptID"].ToString(), out userDeptId);
            else if (Session["Dept_ID"] != null) int.TryParse(Session["Dept_ID"].ToString(), out userDeptId);
            else if (Session["DepartmentID"] != null) int.TryParse(Session["DepartmentID"].ToString(), out userDeptId);

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

            ddlSports.DataSource = dv;
            ddlSports.DataTextField = "Dept_Name";
            ddlSports.DataValueField = "Dept_ID";
            ddlSports.DataBind();

            if (adminOrMIS)
            {
                // Administration, MIS, and Admin get access to ALL sports in reporting
                ddlSports.Items.Insert(0, new ListItem("-- All Sports / Departments --", "0"));
                ddlSports.Enabled = true;
                ddlSports.Attributes["style"] = "";

                if (userDeptId > 0 && ddlSports.Items.FindByValue(userDeptId.ToString()) != null)
                {
                    ddlSports.SelectedValue = userDeptId.ToString();
                }
                else
                {
                    ddlSports.SelectedIndex = 0;
                }
            }
            else
            {
                // Department-specific operator gets only their department sports
                if (userDeptId > 0 && ddlSports.Items.FindByValue(userDeptId.ToString()) != null)
                {
                    ddlSports.SelectedValue = userDeptId.ToString();
                }

                if (dv.Count == 1 || (userDeptId > 0 && ddlSports.Items.Count <= 1))
                {
                    ddlSports.Enabled = false;
                    ddlSports.Attributes["style"] = "background-color:#f1f5f9; cursor:not-allowed;";
                }
                else if (ddlSports.Items.Count > 1)
                {
                    ddlSports.Items.Insert(0, new ListItem("-- Select Sport / Dept --", "0"));
                    ddlSports.Enabled = true;
                    ddlSports.Attributes["style"] = "";
                }
                else
                {
                    ddlSports.Items.Insert(0, new ListItem("-- All Sports / Departments --", "0"));
                }
            }

            int currentDeptId = 0;
            int.TryParse(ddlSports.SelectedValue, out currentDeptId);
            LoadSubDepartment(currentDeptId);
        }
        catch (Exception ex)
        {
            ddlSports.Items.Clear();
            ddlSports.Items.Insert(0, new ListItem("-- All Sports / Departments --", "0"));
            ShowMessage("Error loading sports: " + ex.Message, false);
        }
    }

    private void LoadSubDepartment(int deptId)
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
            ddlSubDept.Attributes["style"] = "";

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
            ddlSubDept.Attributes["style"] = "background-color:#f1f5f9; cursor:not-allowed; pointer-events:none;";
        }
    }

    protected void ddlSports_SelectedIndexChanged(object sender, EventArgs e)
    {
        int selectedDeptId = 0;
        int.TryParse(ddlSports.SelectedValue, out selectedDeptId);
        LoadSubDepartment(selectedDeptId);
        LoadReport();
    }

    protected void ddlSubDept_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadReport();
    }

    private DateTime? ParseDateSafe(string dateStr)
    {
        if (string.IsNullOrWhiteSpace(dateStr)) return null;
        DateTime dt;
        string[] formats = new string[] { "yyyy-MM-dd", "dd/MM/yyyy", "MM/dd/yyyy", "d/M/yyyy", "d-M-yyyy", "yyyy/MM/dd", "dd-MM-yyyy", "dd.MM.yyyy" };
        if (DateTime.TryParseExact(dateStr.Trim(), formats, CultureInfo.InvariantCulture, DateTimeStyles.None, out dt))
        {
            return dt;
        }
        if (DateTime.TryParse(dateStr.Trim(), out dt))
        {
            return dt;
        }
        return null;
    }

    private void LoadReport()
    {
        lblMessage.Visible = false;
        try
        {
            int selectedSportOrDept = 0;
            if (!string.IsNullOrEmpty(ddlSports.SelectedValue))
                int.TryParse(ddlSports.SelectedValue, out selectedSportOrDept);

            if (selectedSportOrDept == 0 && !IsAdminOrMIS())
            {
                if (Session["DeptID"] != null) int.TryParse(Session["DeptID"].ToString(), out selectedSportOrDept);
                else if (Session["Dept_ID"] != null) int.TryParse(Session["Dept_ID"].ToString(), out selectedSportOrDept);
            }

            string memberSearch = txtSearchMember.Text.Trim();
            string actionType = ddlActionType.SelectedValue;
            DateTime? fromDt = ParseDateSafe(txtFromDate.Text);
            DateTime? toDt = ParseDateSafe(txtToDate.Text);

            int selectedSubDept = 0;
            if (ddlSubDept != null && !string.IsNullOrEmpty(ddlSubDept.SelectedValue))
                int.TryParse(ddlSubDept.SelectedValue, out selectedSubDept);

            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(connString))
            {
                string sql = @"
                SELECT 
                    ms.MemberSubID,
                    ms.MemberID,
                    ms.ManualCardNo,
                    ISNULL(NULLIF(ms.DependentMemberNo COLLATE DATABASE_DEFAULT, ''), mp.MemberNo COLLATE DATABASE_DEFAULT) AS MemberNo,
                    CASE 
                        WHEN ms.DependentName IS NOT NULL AND ms.DependentName <> '' 
                        THEN ms.DependentName COLLATE DATABASE_DEFAULT
                        WHEN ms_sp.SpouseName IS NOT NULL AND ms_sp.SpouseName <> ''
                        THEN ms_sp.SpouseName COLLATE DATABASE_DEFAULT
                        WHEN mc_ch.ChildName IS NOT NULL AND mc_ch.ChildName <> ''
                        THEN mc_ch.ChildName COLLATE DATABASE_DEFAULT
                        ELSE mp.MemberName COLLATE DATABASE_DEFAULT 
                    END AS MemberName,
                    CASE 
                        WHEN ms.DependentRelation IS NOT NULL AND ms.DependentRelation <> '' 
                        THEN ms.DependentRelation COLLATE DATABASE_DEFAULT
                        WHEN ms_sp.SpouseName IS NOT NULL AND ms_sp.SpouseName <> ''
                        THEN (CASE WHEN ms.DependentMemberNo LIKE '%-H%' THEN 'Husband' ELSE 'Spouse' END)
                        WHEN mc_ch.ChildName IS NOT NULL AND mc_ch.ChildName <> ''
                        THEN ISNULL(mc_ch.Relationship, 'Dependent') COLLATE DATABASE_DEFAULT
                        WHEN ms.DependentMemberNo IS NOT NULL AND ms.DependentMemberNo <> '' AND ms.DependentMemberNo COLLATE DATABASE_DEFAULT <> mp.MemberNo COLLATE DATABASE_DEFAULT
                        THEN (CASE 
                                WHEN ms.DependentMemberNo LIKE '%-H%' THEN 'Husband'
                                WHEN ms.DependentMemberNo LIKE '%-W%' THEN 'Spouse'
                                WHEN ms.DependentMemberNo LIKE '%-S%' THEN 'Son'
                                WHEN ms.DependentMemberNo LIKE '%-D%' THEN 'Daughter'
                                ELSE 'Dependent'
                              END)
                        ELSE 'Self'
                    END AS Relationship,
                    sp.SportID,
                    sp.SportName,
                    sub.PackageName,
                    sub.SubscriptionType,
                    CAST(ISNULL(ms.AssignedOn, ms.StartDate) AS DATETIME) AS ActivatedOn,
                    ms.StartDate,
                    ms.EndDate,
                    ms.DeactivatedOn,
                    ISNULL(ms.NetFee, sub.Fee) AS Fee,
                    ISNULL(ms.PaymentMode, 'Cash') AS PaymentMode,
                    ms.IsActive,
                    ISNULL(sp.Dept_ID, sub.DepartmentID) AS Dept_ID
                FROM MemberSubscriptions ms
                INNER JOIN Subscriptions sub ON ms.SubscriptionID = sub.SubscriptionID
                INNER JOIN Sports sp ON sub.SportID = sp.SportID
                INNER JOIN [MemberShip].[dbo].[MemberProfile] mp ON ms.MemberID = mp.MemberID
                LEFT JOIN [MemberShip].[dbo].[MemberSpouses] ms_sp ON ms.DependentMemberNo COLLATE DATABASE_DEFAULT = ms_sp.MembershipNo COLLATE DATABASE_DEFAULT
                LEFT JOIN [MemberShip].[dbo].[MemberChildren] mc_ch ON ms.DependentMemberNo COLLATE DATABASE_DEFAULT = mc_ch.MembershipNo COLLATE DATABASE_DEFAULT
                WHERE (@SportID = 0 OR sp.SportID = @SportID OR sp.Dept_ID = @SportID OR sub.DepartmentID = @SportID)
                  AND (@SubDeptID = 0 OR sp.SubDeptID = @SubDeptID)
                  AND (
                      @ActionType = 'ALL' 
                      OR (@ActionType = 'Active' AND ms.IsActive = 1)
                      OR (@ActionType = 'Deactivated' AND ms.IsActive = 0)
                      OR (@ActionType = 'Subscribed' AND ms.IsActive = 1)
                      OR (@ActionType = 'Unsubscribed' AND ms.IsActive = 0)
                  )
                  AND (
                      @MemberNo IS NULL 
                      OR @MemberNo = '' 
                      OR mp.MemberNo COLLATE SQL_Latin1_General_CP1_CI_AS LIKE '%' + @MemberNo + '%'
                      OR ms.DependentMemberNo COLLATE SQL_Latin1_General_CP1_CI_AS LIKE '%' + @MemberNo + '%'
                      OR REPLACE(mp.MemberNo, '-', '') COLLATE SQL_Latin1_General_CP1_CI_AS LIKE '%' + REPLACE(@MemberNo, '-', '') + '%'
                      OR mp.MemberName COLLATE SQL_Latin1_General_CP1_CI_AS LIKE '%' + @MemberNo + '%'
                      OR ms_sp.SpouseName COLLATE SQL_Latin1_General_CP1_CI_AS LIKE '%' + @MemberNo + '%'
                      OR mc_ch.ChildName COLLATE SQL_Latin1_General_CP1_CI_AS LIKE '%' + @MemberNo + '%'
                      OR ms.DependentName COLLATE SQL_Latin1_General_CP1_CI_AS LIKE '%' + @MemberNo + '%'
                      OR ms.ManualCardNo COLLATE SQL_Latin1_General_CP1_CI_AS LIKE '%' + @MemberNo + '%'
                  )
                  AND (
                      @FromDate IS NULL 
                      OR CAST(ISNULL(ms.AssignedOn, ms.StartDate) AS DATE) >= @FromDate 
                      OR (ms.DeactivatedOn IS NOT NULL AND CAST(ms.DeactivatedOn AS DATE) >= @FromDate)
                  )
                  AND (
                      @ToDate IS NULL 
                      OR CAST(ISNULL(ms.AssignedOn, ms.StartDate) AS DATE) <= @ToDate 
                      OR (ms.DeactivatedOn IS NOT NULL AND CAST(ms.DeactivatedOn AS DATE) <= @ToDate)
                  )
                ORDER BY ms.MemberSubID DESC";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@MemberNo", string.IsNullOrEmpty(memberSearch) ? (object)DBNull.Value : memberSearch);
                    cmd.Parameters.AddWithValue("@SportID", selectedSportOrDept);
                    cmd.Parameters.AddWithValue("@SubDeptID", selectedSubDept);
                    cmd.Parameters.AddWithValue("@ActionType", string.IsNullOrEmpty(actionType) ? "ALL" : actionType);
                    cmd.Parameters.AddWithValue("@FromDate", fromDt.HasValue ? (object)fromDt.Value.Date : DBNull.Value);
                    cmd.Parameters.AddWithValue("@ToDate", toDt.HasValue ? (object)toDt.Value.Date : DBNull.Value);

                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dt);
                    }
                }

                if (!dt.Columns.Contains("DeactivatedOn"))
                {
                    dt.Columns.Add("DeactivatedOn", typeof(DateTime));
                }

                if (!dt.Columns.Contains("ManualCardNo"))
                {
                    dt.Columns.Add("ManualCardNo", typeof(string));
                }

                EnrichMemberDetails(dt, con);
                FilterDataTableByAllowedSports(dt);
                UpdateKpis(dt);

                gvHistory.DataSource = dt;
                gvHistory.DataBind();
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error generating subscription history: " + ex.Message, false);
        }
    }

    private void EnrichMemberDetails(DataTable dt, SqlConnection con)
    {
        if (dt == null || dt.Rows.Count == 0) return;

        List<string> depNos = new List<string>();
        foreach (DataRow row in dt.Rows)
        {
            string memNo = row["MemberNo"] != null ? row["MemberNo"].ToString().Trim() : "";
            string rel = row.Table.Columns.Contains("Relationship") && row["Relationship"] != null ? row["Relationship"].ToString().Trim() : "";

            if (memNo.Contains("-") && (memNo.IndexOf("-H", StringComparison.OrdinalIgnoreCase) >= 0 ||
                                        memNo.IndexOf("-W", StringComparison.OrdinalIgnoreCase) >= 0 ||
                                        memNo.IndexOf("-S", StringComparison.OrdinalIgnoreCase) >= 0 ||
                                        memNo.IndexOf("-D", StringComparison.OrdinalIgnoreCase) >= 0 ||
                                        !rel.Equals("Self", StringComparison.OrdinalIgnoreCase)))
            {
                if (!depNos.Contains(memNo))
                    depNos.Add(memNo);
            }
        }

        if (depNos.Count == 0) return;

        Dictionary<string, Tuple<string, string>> depMap = new Dictionary<string, Tuple<string, string>>(StringComparer.OrdinalIgnoreCase);

        try
        {
            if (con.State != ConnectionState.Open) con.Open();

            string inClause = "'" + string.Join("','", depNos.Select(d => d.Replace("'", "''"))) + "'";

            string query = string.Format(@"
                SELECT MembershipNo, SpouseName AS DependentName, 'Spouse' AS Relationship 
                FROM MemberShip.dbo.MemberSpouses 
                WHERE MembershipNo IN ({0})
                UNION ALL
                SELECT MembershipNo, ChildName AS DependentName, ISNULL(Relationship, 'Dependent') AS Relationship 
                FROM MemberShip.dbo.MemberChildren 
                WHERE MembershipNo IN ({0})", inClause);

            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string no = dr.GetString(0).Trim();
                        string name = dr.IsDBNull(1) ? "" : dr.GetString(1).Trim();
                        string rel = dr.IsDBNull(2) ? "Dependent" : dr.GetString(2).Trim();

                        if (!depMap.ContainsKey(no))
                            depMap[no] = new Tuple<string, string>(name, rel);
                    }
                }
            }

            foreach (DataRow row in dt.Rows)
            {
                string memNo = row["MemberNo"] != null ? row["MemberNo"].ToString().Trim() : "";
                if (depMap.ContainsKey(memNo))
                {
                    var info = depMap[memNo];
                    if (!string.IsNullOrEmpty(info.Item1))
                        row["MemberName"] = info.Item1;

                    string derivedRel = info.Item2;
                    if (memNo.IndexOf("-H", StringComparison.OrdinalIgnoreCase) >= 0) derivedRel = "Husband";
                    else if (memNo.IndexOf("-W", StringComparison.OrdinalIgnoreCase) >= 0) derivedRel = "Spouse";
                    else if (memNo.IndexOf("-S", StringComparison.OrdinalIgnoreCase) >= 0 && derivedRel.Equals("Dependent", StringComparison.OrdinalIgnoreCase)) derivedRel = "Son";
                    else if (memNo.IndexOf("-D", StringComparison.OrdinalIgnoreCase) >= 0 && derivedRel.Equals("Dependent", StringComparison.OrdinalIgnoreCase)) derivedRel = "Daughter";

                    row["Relationship"] = derivedRel;
                }
                else if (memNo.Contains("-"))
                {
                    if (memNo.IndexOf("-H", StringComparison.OrdinalIgnoreCase) >= 0) row["Relationship"] = "Husband";
                    else if (memNo.IndexOf("-W", StringComparison.OrdinalIgnoreCase) >= 0) row["Relationship"] = "Spouse";
                    else if (memNo.IndexOf("-S", StringComparison.OrdinalIgnoreCase) >= 0) row["Relationship"] = "Son";
                    else if (memNo.IndexOf("-D", StringComparison.OrdinalIgnoreCase) >= 0) row["Relationship"] = "Daughter";
                }
            }
        }
        catch (Exception)
        {
            foreach (DataRow row in dt.Rows)
            {
                string memNo = row["MemberNo"] != null ? row["MemberNo"].ToString().Trim() : "";
                if (memNo.IndexOf("-H", StringComparison.OrdinalIgnoreCase) >= 0) row["Relationship"] = "Husband";
                else if (memNo.IndexOf("-W", StringComparison.OrdinalIgnoreCase) >= 0) row["Relationship"] = "Spouse";
                else if (memNo.IndexOf("-S", StringComparison.OrdinalIgnoreCase) >= 0) row["Relationship"] = "Son";
                else if (memNo.IndexOf("-D", StringComparison.OrdinalIgnoreCase) >= 0) row["Relationship"] = "Daughter";
            }
        }
    }

    private void UpdateKpis(DataTable dt)
    {
        if (dt == null || dt.Rows.Count == 0)
        {
            lblTotalLogs.Text = "0";
            lblSubscribedCount.Text = "0";
            lblUnsubscribedCount.Text = "0";
            lblUniqueMembers.Text = "0";
            return;
        }

        lblTotalLogs.Text = dt.Rows.Count.ToString();

        int activeCount = dt.AsEnumerable().Count(r => r.Field<bool>("IsActive"));
        int deactCount = dt.AsEnumerable().Count(r => !r.Field<bool>("IsActive"));
        int uniqueMembers = dt.AsEnumerable().Select(r => r.Field<string>("MemberNo")).Distinct().Count();

        lblSubscribedCount.Text = activeCount.ToString();
        lblUnsubscribedCount.Text = deactCount.ToString();
        lblUniqueMembers.Text = uniqueMembers.ToString();
    }

    private void FilterDataTableByAllowedSports(DataTable dt)
    {
        if (dt == null || dt.Rows.Count == 0) return;

        if (!IsAdminOrMIS() && Session["UserRole"] != null && Session["UserRole"].ToString() == "Operator")
        {
            List<int> allowedSports = Session["AllowedSports"] as List<int>;
            List<int> allowedDepts = Session["AllowedDepartments"] as List<int>;
            if ((allowedSports != null && allowedSports.Count > 0) || (allowedDepts != null && allowedDepts.Count > 0))
            {
                for (int i = dt.Rows.Count - 1; i >= 0; i--)
                {
                    bool keep = false;
                    if (dt.Columns.Contains("SportID") && dt.Rows[i]["SportID"] != DBNull.Value)
                    {
                        int sportId = Convert.ToInt32(dt.Rows[i]["SportID"]);
                        if (allowedSports != null && allowedSports.Contains(sportId))
                            keep = true;
                    }
                    if (!keep && dt.Columns.Contains("Dept_ID") && dt.Rows[i]["Dept_ID"] != DBNull.Value)
                    {
                        int deptId = Convert.ToInt32(dt.Rows[i]["Dept_ID"]);
                        if (allowedDepts != null && allowedDepts.Contains(deptId))
                            keep = true;
                    }
                    if (!keep)
                    {
                        dt.Rows.RemoveAt(i);
                    }
                }
            }
        }
    }

    protected string GetSportDisplay(object sportIdObj, object sportNameObj, object packageNameObj)
    {
        string sportName = sportNameObj != null && sportNameObj != DBNull.Value ? sportNameObj.ToString().Trim() : "";
        string packageName = packageNameObj != null && packageNameObj != DBNull.Value ? packageNameObj.ToString().Trim() : "";
        int sportId = 0;
        if (sportIdObj != null && sportIdObj != DBNull.Value)
            int.TryParse(sportIdObj.ToString(), out sportId);

        bool isSportsCard = (sportId >= 17 && sportId <= 20) ||
                            sportName.IndexOf("Sports Card", StringComparison.OrdinalIgnoreCase) >= 0 ||
                            packageName.IndexOf("Sports Card", StringComparison.OrdinalIgnoreCase) >= 0;

        if (isSportsCard)
        {
            return "Sports Card";
        }

        if (!string.IsNullOrEmpty(sportName))
            return sportName;

        return "Sport";
    }

    protected string GetPackageDisplay(object sportIdObj, object sportNameObj, object packageNameObj, object subTypeObj, object endDateObj)
    {
        string sportName = sportNameObj != null && sportNameObj != DBNull.Value ? sportNameObj.ToString().Trim() : "";
        string packageName = packageNameObj != null && packageNameObj != DBNull.Value ? packageNameObj.ToString().Trim() : "";
        string subType = subTypeObj != null && subTypeObj != DBNull.Value ? subTypeObj.ToString().Trim() : "";
        int sportId = 0;
        if (sportIdObj != null && sportIdObj != DBNull.Value)
            int.TryParse(sportIdObj.ToString(), out sportId);

        string durationType = "Continuous";
        if (subType.IndexOf("Month", StringComparison.OrdinalIgnoreCase) >= 0 || packageName.IndexOf("Monthly", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            durationType = "Monthly";
        }
        else
        {
            durationType = "Continuous";
        }

        bool isSportsCard = (sportId >= 17 && sportId <= 20) ||
                            sportName.IndexOf("Sports Card", StringComparison.OrdinalIgnoreCase) >= 0 ||
                            packageName.IndexOf("Sports Card", StringComparison.OrdinalIgnoreCase) >= 0;

        if (isSportsCard)
        {
            string cardName = "Sports Card";
            if (sportId == 17 || packageName.IndexOf("Family", StringComparison.OrdinalIgnoreCase) >= 0)
                cardName = "Family Sports Card";
            else if (sportId == 18 || packageName.IndexOf("Couple", StringComparison.OrdinalIgnoreCase) >= 0)
                cardName = "Couple Sports Card";
            else if (sportId == 19 || packageName.IndexOf("Individual", StringComparison.OrdinalIgnoreCase) >= 0 || packageName.IndexOf("Child", StringComparison.OrdinalIgnoreCase) >= 0)
                cardName = "Individual / Child Sports Card";
            else if (sportId == 20 || packageName.IndexOf("Non Earning", StringComparison.OrdinalIgnoreCase) >= 0)
                cardName = "Non Earning Sports Card";
            else if (!string.IsNullOrEmpty(packageName))
                cardName = packageName;

            return cardName + " (" + durationType + ")";
        }

        return "(" + durationType + ")";
    }

    protected string GetDeactivationDisplay(object deactOnObj, object endDateObj, object isActiveObj)
    {
        bool isActive = isActiveObj != null && isActiveObj != DBNull.Value && Convert.ToBoolean(isActiveObj);

        if (deactOnObj != null && deactOnObj != DBNull.Value)
        {
            DateTime deactOn;
            if (DateTime.TryParse(deactOnObj.ToString(), out deactOn))
            {
                return string.Format("<span style='font-weight:700; color:#dc2626;'>{0}</span>", deactOn.ToString("dd-MMM-yyyy hh:mm tt"));
            }
        }

        if (!isActive && endDateObj != null && endDateObj != DBNull.Value)
        {
            DateTime endDate;
            if (DateTime.TryParse(endDateObj.ToString(), out endDate))
            {
                return string.Format("<span style='font-weight:700; color:#dc2626;'>{0}</span>", endDate.ToString("dd-MMM-yyyy hh:mm tt"));
            }
        }

        if (isActive)
        {
            return "<span style='color:#059669; font-weight:700;'><i class='fas fa-check-circle' style='margin-right:3px;'></i>Active (Ongoing)</span>";
        }

        return "<span style='color:#64748b;'>-</span>";
    }

    protected string GetDurationDisplay(object actOnObj, object deactOnObj, object isActiveObj)
    {
        if (actOnObj == null || actOnObj == DBNull.Value) return "-";
        DateTime actOn;
        if (!DateTime.TryParse(actOnObj.ToString(), out actOn)) return "-";

        bool isActive = isActiveObj != null && isActiveObj != DBNull.Value && Convert.ToBoolean(isActiveObj);

        if (!isActive && deactOnObj != null && deactOnObj != DBNull.Value)
        {
            DateTime deactOn;
            if (DateTime.TryParse(deactOnObj.ToString(), out deactOn))
            {
                TimeSpan span = deactOn - actOn;
                if (span.TotalDays >= 1)
                {
                    int days = (int)Math.Ceiling(span.TotalDays);
                    return string.Format("<span style='font-weight:700; color:#b91c1c;'>{0} {1}</span>", days, days == 1 ? "Day" : "Days");
                }
                else if (span.TotalHours >= 1)
                {
                    int hours = (int)Math.Ceiling(span.TotalHours);
                    return string.Format("<span style='font-weight:700; color:#b91c1c;'>{0} {1}</span>", hours, hours == 1 ? "Hour" : "Hours");
                }
                else
                {
                    int mins = Math.Max(1, (int)Math.Ceiling(span.TotalMinutes));
                    return string.Format("<span style='font-weight:700; color:#b91c1c;'>{0} {1}</span>", mins, mins == 1 ? "Min" : "Mins");
                }
            }
        }

        TimeSpan activeSpan = DateTime.Now - actOn;
        int activeDays = Math.Max(1, (int)Math.Ceiling(activeSpan.TotalDays));
        return string.Format("<span style='font-weight:700; color:#059669;'>{0} {1} Active</span>", activeDays, activeDays == 1 ? "Day" : "Days");
    }

    protected string GetFormattedSportName(object sportIdObj, string sportName, string packageName)
    {
        return GetSportDisplay(sportIdObj, sportName, packageName);
    }

    private void ShowMessage(string msg, bool isSuccess)
    {
        lblMessage.Visible = true;
        lblMessage.Text = msg;
        lblMessage.CssClass = isSuccess ? "alert alert-success" : "alert alert-danger";
        lblMessage.Style["background-color"] = isSuccess ? "#d1fae5" : "#fee2e2";
        lblMessage.Style["color"] = isSuccess ? "#065f46" : "#991b1b";
        lblMessage.Style["border"] = isSuccess ? "1px solid #a7f3d0" : "1px solid #fca5a5";
    }
}
