using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Collections.Generic;


public partial class MemberSubscriptions : System.Web.UI.Page
{
    string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;

    private string GetBasicDataConnString()
    {
        return ConfigurationManager.ConnectionStrings["BasicDataInfoConnString"] != null
            ? ConfigurationManager.ConnectionStrings["BasicDataInfoConnString"].ConnectionString
            : connString.Replace("SportsModuleDB", "BasicDataInfo");
    }

    private Dictionary<string, List<ActiveSubDetails>> _allActiveSubs = new Dictionary<string, List<ActiveSubDetails>>();

    public class ActiveSubDetails
    {
        public int MemberSubID { get; set; }
        public int SubscriptionID { get; set; }
        public int SportID { get; set; }
        public int DeptID { get; set; }
        public string PackageName { get; set; }
        public string SportName { get; set; }
        public string SubscriptionType { get; set; }
        public bool IsActive { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string ManualCardNo { get; set; }
    }

    private bool IsSportsCardSub(int subId, string sportName, string packageName)
    {
        if (subId >= 17 && subId <= 20) return true;
        if (!string.IsNullOrEmpty(sportName) && sportName.IndexOf("Sports Card", StringComparison.OrdinalIgnoreCase) >= 0) return true;
        if (!string.IsNullOrEmpty(packageName) && packageName.IndexOf("Sports Card", StringComparison.OrdinalIgnoreCase) >= 0) return true;
        return false;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadSportsDropdown();
            if (txtStartDate != null) txtStartDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            LoadActiveBankCards();
            LoadLockers();
        }
    }

    private void LoadActiveBankCards()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string sql = "SELECT Bank_ID AS BankID, Bank_Name AS BankName FROM BankDefination WHERE IsActive = 1 ORDER BY Bank_Name";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    DataTable dt = new DataTable();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);

                    if (ddlModalBankCard != null)
                    {
                        ddlModalBankCard.DataSource = dt;
                        ddlModalBankCard.DataTextField = "BankName";
                        ddlModalBankCard.DataValueField = "BankID";
                        ddlModalBankCard.DataBind();
                        ddlModalBankCard.Items.Insert(0, new ListItem("-- Select Bank --", "0"));
                    }
                }
            }
        }
        catch { }
    }



    private void LoadLockers()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetLockers", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IncludeInactive", 0);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        ddlLocker.Items.Clear();
                        ddlLocker.Items.Add(new ListItem("-- No Locker --", "0"));

                        foreach (DataRow row in dt.Rows)
                        {
                            string text = string.Format("{0} (PKR {1:N0})", row["LockerName"], row["Fee"]);
                            string val = string.Format("{0}|{1}", row["LockerID"], row["Fee"]);
                            ddlLocker.Items.Add(new ListItem(text, val));
                        }
                    }
                }
            }
        }
        catch { }
    }

    protected void ddlLocker_SelectedIndexChanged(object sender, EventArgs e)
    {
        CalculatePackageRate();
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        lblMessage.Visible = false;
        pnlSearchResults.Visible = false;
        pnlMemberArea.Visible = false;
        ucMemberSubInfo.Clear();

        if (string.IsNullOrWhiteSpace(txtSearch.Text))
        {
            ShowMessage("Please enter a Member ID or Name to search.", false);
            return;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand("sp_SearchMembers", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 60;
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
                            if (!dt.Columns.Contains("Age")) dt.Columns.Add("Age", typeof(string));
                            if (!dt.Columns.Contains("RatePolicy")) dt.Columns.Add("RatePolicy", typeof(string));
                            if (!dt.Columns.Contains("RFIDNumber")) dt.Columns.Add("RFIDNumber", typeof(string));
                            if (!dt.Columns.Contains("IsRFIDActive")) dt.Columns.Add("IsRFIDActive", typeof(int));
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

                                row["Age"] = FetchMemberAge(mid, rel, rel == "Self" ? "" : memberNo);

                                string policy = "Base (Full Charge)";
                                if (dt.Columns.Contains("CategoryName") && row["CategoryName"] != DBNull.Value && !string.IsNullOrEmpty(row["CategoryName"].ToString()))
                                {
                                    policy = row["CategoryName"].ToString();
                                }
                                else if (dt.Columns.Contains("MemberType") && row["MemberType"] != DBNull.Value && !string.IsNullOrEmpty(row["MemberType"].ToString()))
                                {
                                    policy = row["MemberType"].ToString();
                                }
                                else if (dt.Columns.Contains("RatePolicy") && row["RatePolicy"] != DBNull.Value && !string.IsNullOrEmpty(row["RatePolicy"].ToString()))
                                {
                                    policy = row["RatePolicy"].ToString();
                                }
                                row["RatePolicy"] = policy;

                                var rfidInfo = GetMemberRFIDInfo(mid, rel, rel == "Self" ? "" : memberNo);
                                row["RFIDNumber"] = rfidInfo.Item1;
                                row["IsRFIDActive"] = rfidInfo.Item2;
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

                            // Fetch active subscriptions and continuous for these MemberIDs
                            string idList = string.Join(",", memberIds);
                            _allActiveSubs.Clear();

                            if (!string.IsNullOrEmpty(idList))
                            {
                                string queryStr = string.Format(@"
                                    SELECT ms.MemberSubID, ms.MemberID, ms.DependentMemberNo, sub.PackageName, sub.SubscriptionType, ms.IsActive, 
                                           ISNULL(d.Dept_Name, sp.SportName) AS SportName, ms.StartDate, ms.EndDate, ms.ManualCardNo,
                                           sub.SubscriptionID, sub.SportID, ISNULL(sub.DepartmentID, sp.Dept_ID) AS DeptID 
                                    FROM MemberSubscriptions ms 
                                    INNER JOIN Subscriptions sub ON ms.SubscriptionID = sub.SubscriptionID 
                                    INNER JOIN Sports sp ON sub.SportID = sp.SportID 
                                    LEFT JOIN BasicDataInfo.dbo.Department d ON ISNULL(sub.DepartmentID, sp.Dept_ID) = d.Dept_ID
                                    WHERE ms.MemberID IN ({0}) 
                                       AND (ms.IsActive = 1 OR sub.SubscriptionType = 'Continuous')", idList);

                                if (!IsAdminOrMIS() && Session["UserRole"] != null && Session["UserRole"].ToString() == "Operator")
                                {
                                    List<int> allowedSports = Session["AllowedSports"] as List<int>;
                                    List<int> allowedDepts = Session["AllowedDepartments"] as List<int>;
                                    List<string> orConditions = new List<string>();
                                    if (allowedSports != null && allowedSports.Count > 0)
                                    {
                                        orConditions.Add("sub.SportID IN (" + string.Join(",", allowedSports) + ")");
                                    }
                                    if (allowedDepts != null && allowedDepts.Count > 0)
                                    {
                                        orConditions.Add("sp.Dept_ID IN (" + string.Join(",", allowedDepts) + ") OR sub.DepartmentID IN (" + string.Join(",", allowedDepts) + ")");
                                    }
                                    if (orConditions.Count > 0)
                                    {
                                        queryStr += " AND (" + string.Join(" OR ", orConditions) + ")";
                                    }
                                    else
                                    {
                                        queryStr += " AND sub.SportID = -1";
                                    }
                                }

                                queryStr += " ORDER BY ms.MemberSubID DESC";

                                using (SqlCommand subCmd = new SqlCommand(queryStr, con))
                                {
                                    subCmd.CommandTimeout = 60;
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
                                            sub.StartDate = dr.IsDBNull(7) ? (DateTime?)null : dr.GetDateTime(7);
                                            sub.EndDate = dr.IsDBNull(8) ? (DateTime?)null : dr.GetDateTime(8);
                                            sub.ManualCardNo = dr.FieldCount > 9 && !dr.IsDBNull(9) ? dr.GetString(9) : "";
                                            sub.SubscriptionID = dr.FieldCount > 10 && !dr.IsDBNull(10) ? dr.GetInt32(10) : 0;
                                            sub.SportID = dr.FieldCount > 11 && !dr.IsDBNull(11) ? dr.GetInt32(11) : 0;
                                            sub.DeptID = dr.FieldCount > 12 && !dr.IsDBNull(12) ? dr.GetInt32(12) : 0;

                                            string key = mid.ToString() + "_" + depNo;
                                            if (!_allActiveSubs.ContainsKey(key))
                                                _allActiveSubs[key] = new List<ActiveSubDetails>();

                                            // Avoid adding older duplicates for the same sport/package
                                            bool exists = _allActiveSubs[key].Exists(s => s.SportName == sub.SportName && s.SubscriptionType == sub.SubscriptionType);
                                            if (!exists)
                                            {
                                                _allActiveSubs[key].Add(sub);
                                            }
                                        }
                                    }
                                }
                            }

                            int selectedDeptId = 0;
                            if (ddlSports != null && ddlSports.SelectedIndex > 0)
                            {
                                int.TryParse(ddlSports.SelectedValue, out selectedDeptId);
                            }
                            int resolvedSportId = selectedDeptId > 0 && ddlSports.SelectedItem != null ? GetSportIdByDeptId(selectedDeptId, ddlSports.SelectedItem.Text) : 0;

                            foreach (DataRow row in dt.Rows)
                            {
                                int mid = Convert.ToInt32(row["MemberID"]);
                                string memberNo = row["MembershipNo"].ToString();
                                string rel = row["Relationship"].ToString();

                                string key = mid.ToString() + "_" + (rel == "Self" ? "" : memberNo);

                                string activeManualCard = "";
                                if (_allActiveSubs.ContainsKey(key) && _allActiveSubs[key].Count > 0)
                                {
                                    List<string> activeNames = new List<string>();
                                    foreach (var sub in _allActiveSubs[key])
                                    {
                                        if (sub.IsActive)
                                        {
                                            activeNames.Add(sub.SportName);
                                        }
                                    }
                                    row["SubscriptionStatus"] = activeNames.Count > 0 ? string.Join(", ", activeNames) : "None";

                                    // Filter out Sports Cards strictly
                                    var regularSubs = _allActiveSubs[key].FindAll(s => !IsSportsCardSub(s.SubscriptionID, s.SportName, s.PackageName));

                                    if (selectedDeptId > 0)
                                    {
                                        var match = regularSubs.Find(s => s.DeptID == selectedDeptId || s.SportID == resolvedSportId || (ddlSports.SelectedItem != null && s.SportName.Equals(ddlSports.SelectedItem.Text, StringComparison.OrdinalIgnoreCase)));
                                        if (match != null && !string.IsNullOrEmpty(match.ManualCardNo))
                                        {
                                            activeManualCard = match.ManualCardNo;
                                        }
                                    }
                                    else
                                    {
                                        var activeRegular = regularSubs.Find(s => s.IsActive && !string.IsNullOrEmpty(s.ManualCardNo));
                                        if (activeRegular != null)
                                        {
                                            activeManualCard = activeRegular.ManualCardNo;
                                        }
                                        else
                                        {
                                            var anyRegular = regularSubs.Find(s => !string.IsNullOrEmpty(s.ManualCardNo));
                                            if (anyRegular != null)
                                            {
                                                activeManualCard = anyRegular.ManualCardNo;
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    row["SubscriptionStatus"] = "None";
                                }
                                row["ManualCardNo"] = activeManualCard;
                            }

                            gvMemberResults.DataSource = dt;
                            gvMemberResults.DataBind();

                            // Load global family subscription card using the first row's MemberID
                            int mainMemberId = Convert.ToInt32(dt.Rows[0]["MemberID"]);
                            string mainMemberName = dt.Rows[0]["FullName"].ToString(); // fallback
                            foreach (DataRow row in dt.Rows)
                            {
                                if (row["Relationship"].ToString() == "Self")
                                {
                                    mainMemberName = row["FullName"].ToString();
                                    break;
                                }
                            }
                            ucMemberSubInfo.LoadFamilySubscriptions(mainMemberId, mainMemberName);

                            // If exactly one match, auto select it
                            int exactMatchIndex = -1;
                            string searchStr = txtSearch.Text.Trim();
                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                if (dt.Rows[i]["MembershipNo"].ToString().Equals(searchStr, StringComparison.OrdinalIgnoreCase))
                                {
                                    exactMatchIndex = i;
                                    break;
                                }
                            }

                            if (dt.Rows.Count == 1 || exactMatchIndex != -1)
                            {
                                int selIndex = exactMatchIndex != -1 ? exactMatchIndex : 0;
                                DataRow selRow = dt.Rows[selIndex];
                                SelectMember(selRow["MemberID"].ToString(), selRow["MembershipNo"].ToString(), selRow["FullName"].ToString(), selRow["Status"].ToString(), dt.Columns.Contains("ContactNo") && selRow["ContactNo"] != DBNull.Value ? selRow["ContactNo"].ToString() : "", selRow["Relationship"].ToString());
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

    private void SelectMember(string memberIdStr, string membershipNo, string fullName, string status, string contact, string relationship)
    {
        hfMemberID.Value = memberIdStr;
        lblMemberNo.Text = membershipNo;
        lblFullName.Text = fullName;
        lblStatus.Text = status;
        lblContact.Text = string.IsNullOrWhiteSpace(contact) ? "N/A" : contact.Trim();

        hfDependentRelation.Value = relationship;

        // Set dependent info based on relationship
        if (relationship != "Self")
        {
            hfDependentMemberNo.Value = membershipNo;
            hfDependentName.Value = fullName;
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

        pnlMemberArea.Visible = true;
        txtStartDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
        txtEndDate.Text = "";

        LoadSubscriptionDropdown();

        string depMemberNo = string.IsNullOrEmpty(hfDependentMemberNo.Value) ? null : hfDependentMemberNo.Value.Trim();

        LoadMemberDetails(Convert.ToInt32(hfMemberID.Value), relationship, depMemberNo);

        // Calculate Rate Policy dynamically from SQL function later when package is selected
        CalculatePackageRate();


        string activeCard = GetActiveSportsCard(Convert.ToInt32(hfMemberID.Value), depMemberNo);
        if (!string.IsNullOrEmpty(activeCard))
        {
            string alertHtml = string.Format("<i class='fas fa-exclamation-triangle' style='color:#d97706; font-size:14px; margin-right:6px;'></i> <span><strong>Active Sports Card:</strong> <strong>{0}</strong> is currently assigned to <strong>{1}</strong>. Please first turn off / deactivate from <a href='ManageSportsCard.aspx' style='color:#b45309; text-decoration:underline; font-weight:700;'>Manage Sports Card</a> then assign.</span>", activeCard, fullName);
            ShowMessage(alertHtml, false, true);

            string script = string.Format("return confirm('Active Sports Card ({0}) exists for this member! First turn off / deactivate the Sports Card from Manage Sports Card then assign. Are you sure you want to proceed?');", activeCard.Replace("'", "\\'"));
            btnAssign.OnClientClick = script;
            btnAssignRFID.OnClientClick = script;
        }
        else
        {
            btnAssign.OnClientClick = "";
            btnAssignRFID.OnClientClick = "";
        }
    }

    private string GetActiveSportsCard(int memberId, string dependentMemberNo)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = @"
                    SELECT TOP 1 sub.PackageName 
                    FROM MemberSubscriptions ms 
                    INNER JOIN Subscriptions sub ON ms.SubscriptionID = sub.SubscriptionID 
                    INNER JOIN Sports sp ON sub.SportID = sp.SportID
                    WHERE ms.MemberID = @MemberID 
                      AND ISNULL(ms.DependentMemberNo, '') = ISNULL(@DependentMemberNo, '') 
                      AND ms.IsActive = 1 
                      AND (sp.SportName LIKE '%Sports Card%' OR sub.PackageName LIKE '%Sports Card%' OR sub.SubscriptionID IN (17,18,19,20))";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@MemberID", memberId);
                    cmd.Parameters.AddWithValue("@DependentMemberNo", string.IsNullOrEmpty(dependentMemberNo) ? (object)DBNull.Value : dependentMemberNo);

                    con.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        return result.ToString();
                    }
                }
            }
        }
        catch (Exception)
        {
        }
        return null;
    }

    private void LoadMemberDetails(int memberId, string relationship, string dependentMemberNo)
    {
        try
        {
            string memberShipConn = ConfigurationManager.ConnectionStrings["MemberShipConnString"] != null ? ConfigurationManager.ConnectionStrings["MemberShipConnString"].ConnectionString : connString.Replace("SportsModuleDB", "MemberShip");
            using (SqlConnection con = new SqlConnection(memberShipConn))
            {
                // Get DOB based on Relationship
                string dobQuery = "";
                if (relationship == "Self" || string.IsNullOrEmpty(relationship))
                {
                    dobQuery = "SELECT TOP 1 DOB FROM MemberProfile WHERE MemberID = @MemberID OR MemberID_New = @MemberID";
                }
                else if (relationship == "Spouse" || relationship.StartsWith("W") || relationship.StartsWith("w"))
                {
                    dobQuery = "SELECT TOP 1 DOB FROM MemberSpouses WHERE MembershipNo = @DependentMemberNo";
                }
                else
                {
                    dobQuery = "SELECT TOP 1 DOB FROM MemberChildren WHERE MembershipNo = @DependentMemberNo";
                }

                using (SqlCommand cmdDob = new SqlCommand(dobQuery, con))
                {
                    cmdDob.Parameters.AddWithValue("@MemberID", memberId);
                    cmdDob.Parameters.AddWithValue("@DependentMemberNo", string.IsNullOrEmpty(dependentMemberNo) ? (object)DBNull.Value : dependentMemberNo);

                    con.Open();
                    object dobResult = cmdDob.ExecuteScalar();
                    if (dobResult != null && dobResult != DBNull.Value)
                    {
                        DateTime dob;
                        if (DateTime.TryParse(dobResult.ToString(), out dob))
                        {
                            int age = DateTime.Now.Year - dob.Year;
                            if (dob.Date > DateTime.Now.AddYears(-age)) age--;
                            lblAge.Text = age.ToString() + " Yrs";
                        }
                        else
                        {
                            lblAge.Text = "N/A";
                        }
                    }
                    else
                    {
                        lblAge.Text = "N/A";
                    }
                }
            }
        }
        catch (Exception ex)
        {
            lblAge.Text = "N/A";
            // Do not touch lblContact or lblStatus here as they are already set correctly from the dropdown parts
        }
    }

    private void LoadMemberRFIDStatus(int memberId)
    {
        try
        {
            string memberShipConn = ConfigurationManager.ConnectionStrings["MemberShipConnString"] != null ? ConfigurationManager.ConnectionStrings["MemberShipConnString"].ConnectionString : connString.Replace("SportsModuleDB", "MemberShip");
            using (SqlConnection con = new SqlConnection(memberShipConn))
            {
                string query = "SELECT ISNULL(RFID, '') AS RFID, ISNULL(IsCardActive, 0) AS IsCardActive FROM MemberProfile WHERE MemberID = @MemberID";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@MemberID", memberId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string rfid = reader["RFID"].ToString();
                            int isActive = Convert.ToInt32(reader["IsCardActive"]);

                            if (string.IsNullOrEmpty(rfid))
                            {
                                lblRFIDStatus.Text = "Not Assigned";
                                lblRFIDStatus.ForeColor = System.Drawing.Color.Gray;
                            }
                            else if (isActive == 1)
                            {
                                lblRFIDStatus.Text = "Active (" + rfid + ")";
                                lblRFIDStatus.ForeColor = System.Drawing.Color.Green;
                            }
                            else
                            {
                                lblRFIDStatus.Text = "Deactivated (" + rfid + ")";
                                lblRFIDStatus.ForeColor = System.Drawing.Color.Red;
                            }
                        }
                    }
                }
            }
        }
        catch (Exception)
        {
            lblRFIDStatus.Text = "Unknown";
        }
    }

    protected void btnAssignRFID_Click(object sender, EventArgs e)
    {
        string newRfid = txtAssignRFID.Text.Trim();
        if (string.IsNullOrEmpty(newRfid))
        {
            ShowMessage("Please scan or enter an RFID card.", false);
            return;
        }

        UpdateRFIDStatus(newRfid, 1);
        txtAssignRFID.Text = "";
    }

    protected void btnDeactivateRFID_Click(object sender, EventArgs e)
    {
        UpdateRFIDStatus(null, 0);
    }

    private void UpdateRFIDStatus(string rfid, int isActive)
    {
        try
        {
            string memberShipConn = ConfigurationManager.ConnectionStrings["MemberShipConnString"] != null ? ConfigurationManager.ConnectionStrings["MemberShipConnString"].ConnectionString : connString.Replace("SportsModuleDB", "MemberShip");
            using (SqlConnection con = new SqlConnection(memberShipConn))
            {
                string query = "UPDATE MemberProfile SET IsCardActive = @IsActive";
                if (rfid != null)
                {
                    query += ", RFID = @RFID, CardStatus = 'ACTIVE'";
                }
                else
                {
                    query += ", CardStatus = 'INACTIVE'";
                }
                query += " WHERE MemberID = @MemberID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@IsActive", isActive);
                    cmd.Parameters.AddWithValue("@MemberID", Convert.ToInt32(hfMemberID.Value));
                    if (rfid != null)
                        cmd.Parameters.AddWithValue("@RFID", rfid);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            LoadMemberRFIDStatus(Convert.ToInt32(hfMemberID.Value));
            ShowMessage("RFID card status updated successfully.", true);
        }
        catch (Exception ex)
        {
            ShowMessage("Error updating RFID status: " + ex.Message, false);
        }
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

    private void LoadSportsDropdown()
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
                // Administration, MIS, and Admin get access to ALL sports and can freely choose sports to assign
                ddlSports.Items.Insert(0, new ListItem("-- All Departments / Sports --", "0"));
                ddlSports.Enabled = true;
                ddlSports.Attributes["style"] = "width:190px; padding:4px 8px; font-weight:600;";

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
                    ddlSports.Attributes["style"] = "width:190px; padding:4px 8px; font-weight:600; background-color:#f1f5f9; cursor:not-allowed;";
                }
                else if (ddlSports.Items.Count > 1)
                {
                    ddlSports.Items.Insert(0, new ListItem("-- Select Sport / Dept --", "0"));
                    ddlSports.Enabled = true;
                    ddlSports.Attributes["style"] = "width:190px; padding:4px 8px; font-weight:600;";
                }
                else
                {
                    ddlSports.Items.Insert(0, new ListItem("-- All Departments / Sports --", "0"));
                }
            }

            int currentDeptId = 0;
            int.TryParse(ddlSports.SelectedValue, out currentDeptId);
            LoadSubDepartment(currentDeptId);
        }
        catch (Exception ex)
        {
            ddlSports.Items.Clear();
            ddlSports.Items.Insert(0, new ListItem("-- All Departments / Sports --", "0"));
            ShowMessage("Error loading departments: " + ex.Message, false);
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
            ddlSubDept.Attributes["style"] = "width:170px; padding:4px 8px; font-weight:600;";

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
            ddlSubDept.Attributes["style"] = "width:170px; padding:4px 8px; font-weight:600; background-color:#f1f5f9; cursor:not-allowed; pointer-events:none;";
        }
    }

    protected void ddlSports_SelectedIndexChanged(object sender, EventArgs e)
    {
        int selectedDeptId = 0;
        int.TryParse(ddlSports.SelectedValue, out selectedDeptId);
        LoadSubDepartment(selectedDeptId);

        if (!string.IsNullOrWhiteSpace(txtSearch.Text))
        {
            btnSearch_Click(null, null);
        }
        LoadSubscriptionDropdown();
        CalculatePackageRate();
    }

    protected void ddlSubDept_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (!string.IsNullOrWhiteSpace(txtSearch.Text))
        {
            btnSearch_Click(null, null);
        }
        LoadSubscriptionDropdown();
        CalculatePackageRate();
    }

    public int GetSportIdByDeptId(int deptId, string deptName = "")
    {
        if (deptId <= 0) return 0;
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                // 1. Check exact Dept_ID or SubDeptID mapping in Sports table
                string q = "SELECT TOP 1 SportID FROM Sports WHERE Dept_ID = @DeptID OR SubDeptID = @DeptID ORDER BY SportID";
                using (SqlCommand cmd = new SqlCommand(q, con))
                {
                    cmd.Parameters.AddWithValue("@DeptID", deptId);
                    object res = cmd.ExecuteScalar();
                    if (res != null && res != DBNull.Value)
                        return Convert.ToInt32(res);
                }

                // 2. Try matching by Department / Sport Name
                if (!string.IsNullOrEmpty(deptName))
                {
                    string nameQuery = @"
                        SELECT TOP 1 SportID FROM Sports 
                        WHERE SportName LIKE @Name OR @Name LIKE '%' + SportName + '%' 
                        ORDER BY SportID";
                    using (SqlCommand cmd = new SqlCommand(nameQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@Name", deptName.Trim());
                        object res = cmd.ExecuteScalar();
                        if (res != null && res != DBNull.Value)
                            return Convert.ToInt32(res);
                    }
                }

                // 3. Fallback check if deptId matches SportID directly
                string idQuery = "SELECT TOP 1 SportID FROM Sports WHERE SportID = @DeptID";
                using (SqlCommand cmd = new SqlCommand(idQuery, con))
                {
                    cmd.Parameters.AddWithValue("@DeptID", deptId);
                    object res = cmd.ExecuteScalar();
                    if (res != null && res != DBNull.Value)
                        return Convert.ToInt32(res);
                }
            }
        }
        catch { }
        return deptId;
    }

    private void LoadSubscriptionDropdown()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetSubscriptions", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        DataView dv = dt.DefaultView;
                        string filter = "Status = True AND SubscriptionType <> 'Daily'";
                        if (ddlSports.SelectedIndex > 0)
                        {
                            int selectedDeptId = Convert.ToInt32(ddlSports.SelectedValue);
                            int resolvedSportId = GetSportIdByDeptId(selectedDeptId, ddlSports.SelectedItem != null ? ddlSports.SelectedItem.Text : "");
                            if (dt.Columns.Contains("DepartmentID"))
                            {
                                filter += " AND (DepartmentID = " + selectedDeptId + " OR SportID = " + resolvedSportId + " OR SportID = " + selectedDeptId + ")";
                            }
                            else
                            {
                                filter += " AND (SportID = " + resolvedSportId + " OR SportID = " + selectedDeptId + ")";
                            }
                        }
                        else if (!IsAdminOrMIS() && Session["UserRole"] != null && Session["UserRole"].ToString() == "Operator")
                        {
                            List<int> allowedDepts = Session["AllowedDepartments"] as List<int>;
                            List<int> allowedSports = Session["AllowedSports"] as List<int>;
                            List<string> orConditions = new List<string>();
                            if (allowedSports != null && allowedSports.Count > 0)
                            {
                                orConditions.Add("SportID IN (" + string.Join(",", allowedSports) + ")");
                            }
                            if (allowedDepts != null && allowedDepts.Count > 0)
                            {
                                if (dt.Columns.Contains("DepartmentID"))
                                {
                                    orConditions.Add("DepartmentID IN (" + string.Join(",", allowedDepts) + ")");
                                }
                            }
                            if (orConditions.Count > 0)
                            {
                                filter += " AND (" + string.Join(" OR ", orConditions) + ")";
                            }
                            else
                            {
                                filter += " AND SportID = -1";
                            }
                        }
                        dv.RowFilter = filter;

                        ddlPackages.Items.Clear();

                        foreach (DataRowView dr in dv)
                        {
                            string itemCode = dr["ItemCode"] != DBNull.Value ? dr["ItemCode"].ToString() : "N/A";
                            string deptOrSport = dr.DataView.Table.Columns.Contains("DepartmentName") && dr["DepartmentName"] != DBNull.Value && !string.IsNullOrEmpty(dr["DepartmentName"].ToString())
                                ? dr["DepartmentName"].ToString()
                                : dr["SportName"].ToString();
                            string text = "[" + itemCode + "] " + deptOrSport + " - " + dr["PackageName"].ToString() + " (" + dr["SubscriptionType"].ToString() + " : " + Convert.ToDecimal(dr["Fee"]).ToString("N0") + " PKR)";
                            string val = dr["SubscriptionID"].ToString() + "|" + dr["SubscriptionType"].ToString() + "|" + Convert.ToDecimal(dr["Fee"]).ToString("0.00") + "|" + Convert.ToDecimal(dr["GSTPercentage"]).ToString("0.00");
                            ddlPackages.Items.Add(new ListItem(text, val));
                        }

                        ddlPackages.Items.Insert(0, new ListItem("-- Select Package --", "0"));
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading packages: " + ex.Message, false);
        }
    }


    protected void gvMemberResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Button btnSel = (Button)e.Row.FindControl("btnSelect");
            if (btnSel != null)
            {
                string topType = ddlTopSubscriptionType != null ? ddlTopSubscriptionType.SelectedValue : "0";
                if (topType == "Monthly" || topType == "Continuous")
                {
                    btnSel.Text = "Save";
                    btnSel.Style["background-color"] = "#10b981";
                    btnSel.Style["box-shadow"] = "0 2px 4px rgba(16,185,129,0.3)";
                }
                else
                {
                    btnSel.Text = "Select";
                    btnSel.Style["background-color"] = "#2563eb";
                    btnSel.Style["box-shadow"] = "none";
                }
            }
        }
    }

    protected void gvMemberResults_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "SelectMember")
        {
            string[] parts = e.CommandArgument.ToString().Split('|');
            if (parts.Length < 7) return;

            int rowIndex = Convert.ToInt32(parts[0]);
            int memberId = Convert.ToInt32(parts[1]);
            string memberNo = parts[2];
            string fullName = parts[3];
            string status = parts[4];
            string contactNo = parts[5];
            string rel = parts[6];

            string selectedType = ddlTopSubscriptionType != null ? ddlTopSubscriptionType.SelectedValue : "0";

            if (selectedType == "Monthly" || selectedType == "Continuous")
            {
                if (ddlSports.SelectedIndex <= 0)
                {
                    ShowMessage("Please select a Sport from the 'Select Sport' dropdown above first.", false);
                    return;
                }

                int sportId = Convert.ToInt32(ddlSports.SelectedValue);

                string manualCardNo = "";
                if (rowIndex >= 0 && rowIndex < gvMemberResults.Rows.Count)
                {
                    GridViewRow gvRow = gvMemberResults.Rows[rowIndex];
                    TextBox txtRowManual = gvRow.FindControl("txtRowManualCardNo") as TextBox;
                    if (txtRowManual != null)
                    {
                        manualCardNo = txtRowManual.Text.Trim();
                    }
                }
                if (string.IsNullOrEmpty(manualCardNo))
                {
                    foreach (string key in Request.Form.AllKeys)
                    {
                        if (key != null && key.EndsWith("$txtRowManualCardNo") && (key.Contains("ctl" + (rowIndex + 2).ToString("D2")) || key.Contains("ctl" + (rowIndex + 1).ToString("D2")) || key.Contains("gvMemberResults")))
                        {
                            manualCardNo = Request.Form[key].Trim();
                            if (!string.IsNullOrEmpty(manualCardNo)) break;
                        }
                    }
                }

                SaveSubscriptionFromGridRow(memberId, memberNo, fullName, rel, sportId, selectedType, manualCardNo);
            }
            else
            {
                // Normal Member Selection
                hfMemberID.Value = memberId.ToString();
                lblMemberNo.Text = memberNo;
                lblFullName.Text = fullName;
                lblContact.Text = contactNo;
                lblStatus.Text = status;
                lblRelationship.Text = rel;

                if (rel != "Self")
                {
                    hfDependentMemberNo.Value = memberNo;
                    hfDependentName.Value = fullName;
                    hfDependentRelation.Value = rel;
                }
                else
                {
                    hfDependentMemberNo.Value = "";
                    hfDependentName.Value = "";
                    hfDependentRelation.Value = "Self";
                }

                LoadMemberDetails(memberId, rel, rel == "Self" ? "" : memberNo);
                LoadMemberRFIDStatus(memberId);
                pnlMemberArea.Visible = true;
            }
        }
        else if (e.CommandName == "Open12MonthModal")
        {
            int rowIndex = Convert.ToInt32(e.CommandArgument);
            GridViewRow row = gvMemberResults.Rows[rowIndex];
            Button btnSel = row.FindControl("btnSelect") as Button;
            if (btnSel != null)
            {
                string[] parts = btnSel.CommandArgument.Split('|');
                if (parts.Length >= 7)
                {
                    int memberId = Convert.ToInt32(parts[1]);
                    string memberNo = parts[2];
                    string fullName = parts[3];
                    string rel = parts[6];
                    Open12MonthModal(memberId.ToString(), memberNo, fullName, rel);
                }
            }
        }
        else if (e.CommandName == "OpenRFIDModal")
        {
            int rowIndex = Convert.ToInt32(e.CommandArgument);
            GridViewRow row = gvMemberResults.Rows[rowIndex];
            Button btnSel = row.FindControl("btnSelect") as Button;
            if (btnSel != null)
            {
                string[] parts = btnSel.CommandArgument.Split('|');
                if (parts.Length >= 7)
                {
                    int memberId = Convert.ToInt32(parts[1]);
                    string memberNo = parts[2];
                    string fullName = parts[3];
                    string rel = parts[6];
                    OpenRFIDAssignmentModal(memberId.ToString(), memberNo, fullName, rel);
                }
            }
        }
    }

    private void SaveSubscriptionFromGridRow(int memberId, string memberNo, string fullName, string relationship, int sportId, string subType, string manualCardNo = "")
    {
        try
        {
            string depMemberNo = (relationship.Equals("Self", StringComparison.OrdinalIgnoreCase) || relationship.Equals("Main Member", StringComparison.OrdinalIgnoreCase)) ? null : memberNo;

            string selectedDeptName = ddlSports.SelectedItem != null && ddlSports.SelectedIndex > 0 ? ddlSports.SelectedItem.Text : "";
            int resolvedSportId = GetSportIdByDeptId(sportId, selectedDeptName);

            int subscriptionId = 0;
            string packageName = "";
            decimal fee = 0;
            decimal gstPercent = 0;

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                // 1. Try finding package with exact SportID/DeptID and SubscriptionType
                string pkgQuery = @"
                    SELECT TOP 1 s.SubscriptionID, s.PackageName, s.Fee, s.GSTPercentage 
                    FROM Subscriptions s
                    LEFT JOIN Sports sp ON s.SportID = sp.SportID
                    WHERE (s.SportID = @SportID OR s.DepartmentID = @DeptID OR sp.Dept_ID = @DeptID) 
                      AND s.SubscriptionType = @SubType 
                      AND s.Status = 1 
                    ORDER BY s.SubscriptionID DESC";
                using (SqlCommand cmd = new SqlCommand(pkgQuery, con))
                {
                    cmd.Parameters.AddWithValue("@SportID", resolvedSportId);
                    cmd.Parameters.AddWithValue("@DeptID", sportId);
                    cmd.Parameters.AddWithValue("@SubType", subType);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            subscriptionId = dr.GetInt32(0);
                            packageName = dr.GetString(1);
                            fee = dr.GetDecimal(2);
                            gstPercent = dr.IsDBNull(3) ? 0 : dr.GetDecimal(3);
                        }
                    }
                }

                // 2. Fallback: find ANY active package for that SportID/DeptID
                if (subscriptionId == 0)
                {
                    string fallbackQuery = @"
                        SELECT TOP 1 s.SubscriptionID, s.PackageName, s.Fee, s.GSTPercentage 
                        FROM Subscriptions s
                        LEFT JOIN Sports sp ON s.SportID = sp.SportID
                        WHERE (s.SportID = @SportID OR s.DepartmentID = @DeptID OR sp.Dept_ID = @DeptID) 
                        ORDER BY s.Status DESC, s.SubscriptionID DESC";
                    using (SqlCommand cmd = new SqlCommand(fallbackQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@SportID", resolvedSportId);
                        cmd.Parameters.AddWithValue("@DeptID", sportId);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                subscriptionId = dr.GetInt32(0);
                                packageName = dr.GetString(1);
                                fee = dr.GetDecimal(2);
                                gstPercent = dr.IsDBNull(3) ? 0 : dr.GetDecimal(3);
                            }
                        }
                    }

                    if (subscriptionId > 0)
                    {
                        string updatePkg = "UPDATE Subscriptions SET SubscriptionType = @SubType WHERE SubscriptionID = @SubID";
                        using (SqlCommand upCmd = new SqlCommand(updatePkg, con))
                        {
                            upCmd.Parameters.AddWithValue("@SubType", subType);
                            upCmd.Parameters.AddWithValue("@SubID", subscriptionId);
                            upCmd.ExecuteNonQuery();
                        }
                    }
                }

                // 3. Fallback: create default package for this sport if none exists
                if (subscriptionId == 0)
                {
                    string sportName = !string.IsNullOrEmpty(selectedDeptName) ? selectedDeptName : "Sport";
                    string createPkg = @"INSERT INTO Subscriptions (PackageName, SportID, DepartmentID, SubscriptionType, Fee, GSTPercentage, Status) 
                                         VALUES (@PkgName, @SportID, @DeptID, @SubType, 0, 0, 1);
                                         SELECT SCOPE_IDENTITY();";
                    using (SqlCommand insCmd = new SqlCommand(createPkg, con))
                    {
                        insCmd.Parameters.AddWithValue("@PkgName", sportName + " (" + subType + ")");
                        insCmd.Parameters.AddWithValue("@SportID", resolvedSportId);
                        insCmd.Parameters.AddWithValue("@DeptID", sportId);
                        insCmd.Parameters.AddWithValue("@SubType", subType);
                        object newId = insCmd.ExecuteScalar();
                        if (newId != null && newId != DBNull.Value)
                        {
                            subscriptionId = Convert.ToInt32(newId);
                            packageName = sportName + " (" + subType + ")";
                            fee = 0;
                            gstPercent = 0;
                        }
                    }
                }

                DateTime startDate = DateTime.Today;
                DateTime? endDate = null;
                if (subType == "Monthly")
                {
                    endDate = new DateTime(startDate.Year, startDate.Month, DateTime.DaysInMonth(startDate.Year, startDate.Month));
                }

                if (!string.IsNullOrWhiteSpace(manualCardNo))
                {
                    string conflict = CheckManualCardDuplicateInMonth(con, manualCardNo, startDate);
                    if (!string.IsNullOrEmpty(conflict))
                    {
                        ShowMessage("Manual Register / Card No '" + manualCardNo + "' has ALREADY been issued in " + startDate.ToString("MMMM yyyy") + " to " + conflict + "! Please enter a unique Register / Card No.", false);
                        return;
                    }
                }

                using (SqlCommand assignCmd = new SqlCommand("sp_AssignSubscription", con))
                {
                    assignCmd.CommandType = CommandType.StoredProcedure;
                    assignCmd.Parameters.AddWithValue("@MemberID", memberId);
                    assignCmd.Parameters.AddWithValue("@SubscriptionID", subscriptionId);
                    assignCmd.Parameters.AddWithValue("@StartDate", startDate);
                    assignCmd.Parameters.AddWithValue("@EndDate", endDate.HasValue ? (object)endDate.Value : DBNull.Value);
                    assignCmd.Parameters.AddWithValue("@GSTAmount", fee * (gstPercent / 100m));
                    assignCmd.Parameters.AddWithValue("@ManualDiscount", 0);
                    assignCmd.Parameters.AddWithValue("@NetFee", Math.Round(fee + (fee * (gstPercent / 100m))));
                    assignCmd.Parameters.AddWithValue("@LockerID", DBNull.Value);
                    assignCmd.Parameters.AddWithValue("@LockerFee", 0);

                    if (!string.IsNullOrEmpty(depMemberNo))
                    {
                        assignCmd.Parameters.AddWithValue("@DependentMemberNo", depMemberNo);
                        assignCmd.Parameters.AddWithValue("@DependentName", fullName);
                        assignCmd.Parameters.AddWithValue("@DependentRelation", relationship);
                    }

                    assignCmd.Parameters.AddWithValue("@PaymentMode", "Cash");
                    assignCmd.Parameters.AddWithValue("@BankID", DBNull.Value);
                    assignCmd.Parameters.AddWithValue("@BankDiscount", 0);
                    assignCmd.Parameters.AddWithValue("@CardNo", DBNull.Value);
                    assignCmd.Parameters.AddWithValue("@ReferenceID", DBNull.Value);
                    assignCmd.Parameters.AddWithValue("@ManualCardNo", string.IsNullOrEmpty(manualCardNo) ? (object)DBNull.Value : manualCardNo);

                    try
                    {
                        assignCmd.ExecuteNonQuery();
                    }
                    catch (SqlException ex)
                    {
                        if (ex.Number == 8144 || ex.Message.Contains("too many arguments"))
                        {
                            if (assignCmd.Parameters.Contains("@ManualCardNo")) assignCmd.Parameters.Remove(assignCmd.Parameters["@ManualCardNo"]);
                            if (assignCmd.Parameters.Contains("@DependentMemberNo")) assignCmd.Parameters.Remove(assignCmd.Parameters["@DependentMemberNo"]);
                            if (assignCmd.Parameters.Contains("@DependentName")) assignCmd.Parameters.Remove(assignCmd.Parameters["@DependentName"]);
                            if (assignCmd.Parameters.Contains("@DependentRelation")) assignCmd.Parameters.Remove(assignCmd.Parameters["@DependentRelation"]);
                            assignCmd.ExecuteNonQuery();
                        }
                        else throw;
                    }
                }

                ShowMessage(packageName + " (" + subType + ") saved & activated successfully for " + fullName + "!", true);

                btnSearch_Click(null, null);
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error saving subscription: " + ex.Message, false);
        }
    }

    protected void btnSaveSubscription_Click(object sender, EventArgs e)
    {
        lblMessage.Visible = false;

        string memberId = hfMemberID.Value;
        string memberNo = lblMemberNo.Text;
        string fullName = lblFullName.Text;
        string status = lblStatus.Text;

        if (string.IsNullOrEmpty(memberId) && gvMemberResults.Rows.Count > 0)
        {
            GridViewRow firstRow = gvMemberResults.Rows[0];
            Button btnSel = firstRow.FindControl("btnSelect") as Button;
            if (btnSel != null && !string.IsNullOrEmpty(btnSel.CommandArgument))
            {
                string[] parts = btnSel.CommandArgument.Split('|');
                if (parts.Length >= 4)
                {
                    memberId = parts[0];
                    memberNo = parts[1];
                    fullName = parts[2];
                    status = parts[3];
                    string rel = parts.Length >= 6 ? parts[5] : "Self";

                    hfMemberID.Value = memberId;
                    lblMemberNo.Text = memberNo;
                    lblFullName.Text = fullName;
                    lblStatus.Text = status;
                    hfDependentRelation.Value = rel;

                    if (rel != "Self")
                    {
                        hfDependentMemberNo.Value = memberNo;
                        hfDependentName.Value = fullName;
                    }
                    else
                    {
                        hfDependentMemberNo.Value = "";
                        hfDependentName.Value = "";
                    }
                }
            }
        }

        if (string.IsNullOrEmpty(memberId))
        {
            ShowMessage("Please search and select a member first.", false);
            return;
        }

        if (ddlSports.SelectedIndex <= 0)
        {
            ShowMessage("Please select a Sport to activate.", false);
            return;
        }

        string subType = ddlTopSubscriptionType != null ? ddlTopSubscriptionType.SelectedValue : "0";

        if (subType == "0" || string.IsNullOrEmpty(subType) || subType == "All")
        {
            ShowMessage("Please select a Subscription Type (Monthly or Continuous) from the top bar.", false);
            return;
        }

        int sportOrDeptId = Convert.ToInt32(ddlSports.SelectedValue);
        string selectedDeptName = ddlSports.SelectedItem != null && ddlSports.SelectedIndex > 0 ? ddlSports.SelectedItem.Text : "";
        int sportId = GetSportIdByDeptId(sportOrDeptId, selectedDeptName);

        int subscriptionId = 0;
        decimal fee = 0;
        decimal gstPercent = 0;
        string packageName = "";

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                // 1. Try finding package with exact SportID/DeptID and SubscriptionType
                string pkgQuery = @"
                    SELECT TOP 1 s.SubscriptionID, s.PackageName, s.Fee, s.GSTPercentage 
                    FROM Subscriptions s
                    LEFT JOIN Sports sp ON s.SportID = sp.SportID
                    WHERE (s.SportID = @SportID OR s.DepartmentID = @DeptID OR sp.Dept_ID = @DeptID) 
                      AND s.SubscriptionType = @SubType 
                      AND s.Status = 1 
                    ORDER BY s.SubscriptionID DESC";
                using (SqlCommand cmd = new SqlCommand(pkgQuery, con))
                {
                    cmd.Parameters.AddWithValue("@SportID", sportId);
                    cmd.Parameters.AddWithValue("@DeptID", sportOrDeptId);
                    cmd.Parameters.AddWithValue("@SubType", subType);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            subscriptionId = dr.GetInt32(0);
                            packageName = dr.GetString(1);
                            fee = dr.GetDecimal(2);
                            gstPercent = dr.IsDBNull(3) ? 0 : dr.GetDecimal(3);
                        }
                    }
                }

                // 2. Fallback: find ANY active package for that SportID/DeptID
                if (subscriptionId == 0)
                {
                    string fallbackQuery = @"
                        SELECT TOP 1 s.SubscriptionID, s.PackageName, s.Fee, s.GSTPercentage 
                        FROM Subscriptions s
                        LEFT JOIN Sports sp ON s.SportID = sp.SportID
                        WHERE (s.SportID = @SportID OR s.DepartmentID = @DeptID OR sp.Dept_ID = @DeptID) 
                        ORDER BY s.Status DESC, s.SubscriptionID DESC";
                    using (SqlCommand cmd = new SqlCommand(fallbackQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@SportID", sportId);
                        cmd.Parameters.AddWithValue("@DeptID", sportOrDeptId);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                subscriptionId = dr.GetInt32(0);
                                packageName = dr.GetString(1);
                                fee = dr.GetDecimal(2);
                                gstPercent = dr.IsDBNull(3) ? 0 : dr.GetDecimal(3);
                            }
                        }
                    }

                    if (subscriptionId > 0)
                    {
                        string updatePkg = "UPDATE Subscriptions SET SubscriptionType = @SubType WHERE SubscriptionID = @SubID";
                        using (SqlCommand upCmd = new SqlCommand(updatePkg, con))
                        {
                            upCmd.Parameters.AddWithValue("@SubType", subType);
                            upCmd.Parameters.AddWithValue("@SubID", subscriptionId);
                            upCmd.ExecuteNonQuery();
                        }
                    }
                }

                // 3. Fallback: create default package for this sport if none exists
                if (subscriptionId == 0)
                {
                    string sportName = !string.IsNullOrEmpty(selectedDeptName) ? selectedDeptName : "Sport";
                    string createPkg = @"INSERT INTO Subscriptions (PackageName, SportID, DepartmentID, SubscriptionType, Fee, GSTPercentage, Status) 
                                         VALUES (@PkgName, @SportID, @DeptID, @SubType, 0, 0, 1);
                                         SELECT SCOPE_IDENTITY();";
                    using (SqlCommand insCmd = new SqlCommand(createPkg, con))
                    {
                        insCmd.Parameters.AddWithValue("@PkgName", sportName + " (" + subType + ")");
                        insCmd.Parameters.AddWithValue("@SportID", sportId);
                        insCmd.Parameters.AddWithValue("@DeptID", sportOrDeptId);
                        insCmd.Parameters.AddWithValue("@SubType", subType);
                        object newId = insCmd.ExecuteScalar();
                        if (newId != null && newId != DBNull.Value)
                        {
                            subscriptionId = Convert.ToInt32(newId);
                            packageName = sportName + " (" + subType + ")";
                            fee = 0;
                            gstPercent = 0;
                        }
                    }
                }

                DateTime startDate = DateTime.Today;
                DateTime? endDate = null;
                if (subType == "Monthly")
                {
                    endDate = new DateTime(startDate.Year, startDate.Month, DateTime.DaysInMonth(startDate.Year, startDate.Month));
                }

                string manualCard = txtMemberSubManualCardNo != null ? txtMemberSubManualCardNo.Text.Trim() : "";
                if (!string.IsNullOrWhiteSpace(manualCard))
                {
                    string conflict = CheckManualCardDuplicateInMonth(con, manualCard, startDate);
                    if (!string.IsNullOrEmpty(conflict))
                    {
                        ShowMessage("Manual Register / Card No '" + manualCard + "' has ALREADY been issued in " + startDate.ToString("MMMM yyyy") + " to " + conflict + "! Please enter a unique Register / Card No.", false);
                        return;
                    }
                }

                using (SqlCommand assignCmd = new SqlCommand("sp_AssignSubscription", con))
                {
                    assignCmd.CommandType = CommandType.StoredProcedure;
                    assignCmd.Parameters.AddWithValue("@MemberID", memberId);
                    assignCmd.Parameters.AddWithValue("@SubscriptionID", subscriptionId);
                    assignCmd.Parameters.AddWithValue("@StartDate", startDate);
                    assignCmd.Parameters.AddWithValue("@EndDate", endDate.HasValue ? (object)endDate.Value : DBNull.Value);
                    assignCmd.Parameters.AddWithValue("@GSTAmount", fee * (gstPercent / 100m));
                    assignCmd.Parameters.AddWithValue("@ManualDiscount", 0);
                    assignCmd.Parameters.AddWithValue("@NetFee", Math.Round(fee + (fee * (gstPercent / 100m))));
                    assignCmd.Parameters.AddWithValue("@LockerID", DBNull.Value);
                    assignCmd.Parameters.AddWithValue("@LockerFee", 0);

                    string depRelation = hfDependentRelation.Value;
                    if (!string.IsNullOrEmpty(depRelation) && depRelation != "Self")
                    {
                        assignCmd.Parameters.AddWithValue("@DependentMemberNo", hfDependentMemberNo.Value);
                        assignCmd.Parameters.AddWithValue("@DependentName", hfDependentName.Value);
                        assignCmd.Parameters.AddWithValue("@DependentRelation", depRelation);
                    }

                    assignCmd.Parameters.AddWithValue("@PaymentMode", "Cash");
                    assignCmd.Parameters.AddWithValue("@BankID", DBNull.Value);
                    assignCmd.Parameters.AddWithValue("@BankDiscount", 0);
                    assignCmd.Parameters.AddWithValue("@CardNo", DBNull.Value);
                    assignCmd.Parameters.AddWithValue("@ReferenceID", DBNull.Value);
                    assignCmd.Parameters.AddWithValue("@ManualCardNo", string.IsNullOrEmpty(manualCard) ? (object)DBNull.Value : manualCard);

                    try
                    {
                        assignCmd.ExecuteNonQuery();
                    }
                    catch (SqlException ex)
                    {
                        if (ex.Number == 8144 || ex.Message.Contains("too many arguments"))
                        {
                            if (assignCmd.Parameters.Contains("@ManualCardNo")) assignCmd.Parameters.Remove(assignCmd.Parameters["@ManualCardNo"]);
                            if (assignCmd.Parameters.Contains("@DependentMemberNo")) assignCmd.Parameters.Remove(assignCmd.Parameters["@DependentMemberNo"]);
                            if (assignCmd.Parameters.Contains("@DependentName")) assignCmd.Parameters.Remove(assignCmd.Parameters["@DependentName"]);
                            if (assignCmd.Parameters.Contains("@DependentRelation")) assignCmd.Parameters.Remove(assignCmd.Parameters["@DependentRelation"]);
                            assignCmd.ExecuteNonQuery();
                        }
                        else throw;
                    }
                }

                ShowMessage(packageName + " (" + subType + ") activated successfully for " + fullName + "!", true);

                btnSearch_Click(null, null);
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error saving subscription: " + ex.Message, false);
        }
    }

    protected void btnAssign_Click(object sender, EventArgs e)
    {
        if (ddlPackages.SelectedValue == "0" || string.IsNullOrWhiteSpace(txtStartDate.Text))
        {
            ShowMessage("Please select a package and start date.", false);
            return;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_AssignSubscription", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@MemberID", hfMemberID.Value);
                    string[] packageParts = ddlPackages.SelectedValue.Split('|');
                    cmd.Parameters.AddWithValue("@SubscriptionID", packageParts[0]);
                    cmd.Parameters.AddWithValue("@StartDate", Convert.ToDateTime(txtStartDate.Text));

                    if (!string.IsNullOrWhiteSpace(txtEndDate.Text))
                    {
                        cmd.Parameters.AddWithValue("@EndDate", Convert.ToDateTime(txtEndDate.Text));
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@EndDate", DBNull.Value);
                    }

                    decimal baseFee = Convert.ToDecimal(packageParts[2]);
                    decimal gstPercent = Convert.ToDecimal(packageParts[3]);
                    decimal policyDiscount = 0;

                    if (lblRatePolicy.Text.Contains("Half"))
                    {
                        policyDiscount = baseFee * 0.5m;
                    }
                    else if (lblRatePolicy.Text.Contains("Free") || lblRatePolicy.Text.Contains("Senior"))
                    {
                        policyDiscount = baseFee; // 100% off
                    }

                    decimal feeAfterPolicy = baseFee - policyDiscount;
                    if (feeAfterPolicy < 0) feeAfterPolicy = 0;

                    decimal lockerFee = 0;
                    int? lockerId = null;
                    if (ddlLocker.SelectedValue != "0" && !string.IsNullOrEmpty(ddlLocker.SelectedValue))
                    {
                        string[] lockerParts = ddlLocker.SelectedValue.Split('|');
                        if (lockerParts.Length >= 2)
                        {
                            lockerId = Convert.ToInt32(lockerParts[0]);
                            decimal.TryParse(lockerParts[1], out lockerFee);
                        }
                    }

                    decimal gstAmount = feeAfterPolicy * (gstPercent / 100m);
                    decimal netTotal = feeAfterPolicy + gstAmount + lockerFee;

                    cmd.Parameters.AddWithValue("@PolicyDiscount", policyDiscount);
                    cmd.Parameters.AddWithValue("@GSTAmount", gstAmount);
                    cmd.Parameters.AddWithValue("@ManualDiscount", 0);
                    cmd.Parameters.AddWithValue("@NetFee", Math.Round(netTotal));

                    cmd.Parameters.AddWithValue("@LockerID", lockerId.HasValue ? (object)lockerId.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@LockerFee", lockerFee);

                    // Pass dependent info
                    string depRelation = hfDependentRelation.Value;
                    if (!string.IsNullOrEmpty(depRelation) && depRelation != "Self")
                    {
                        cmd.Parameters.AddWithValue("@DependentMemberNo", hfDependentMemberNo.Value);
                        cmd.Parameters.AddWithValue("@DependentName", hfDependentName.Value);
                        cmd.Parameters.AddWithValue("@DependentRelation", depRelation);
                    }

                    // Pass Payment Info
                    cmd.Parameters.AddWithValue("@PaymentMode", "Cash");
                    cmd.Parameters.AddWithValue("@BankID", DBNull.Value);
                    cmd.Parameters.AddWithValue("@BankDiscount", 0);
                    cmd.Parameters.AddWithValue("@CardNo", DBNull.Value);
                    cmd.Parameters.AddWithValue("@ReferenceID", DBNull.Value);
                    string manualCard = txtMemberSubManualCardNo != null ? txtMemberSubManualCardNo.Text.Trim() : "";
                    cmd.Parameters.AddWithValue("@ManualCardNo", string.IsNullOrEmpty(manualCard) ? (object)DBNull.Value : manualCard);

                    if (!string.IsNullOrWhiteSpace(manualCard))
                    {
                        DateTime sDate = Convert.ToDateTime(txtStartDate.Text);
                        string conflict = CheckManualCardDuplicateInMonth(con, manualCard, sDate);
                        if (!string.IsNullOrEmpty(conflict))
                        {
                            ShowMessage("Manual Register / Card No '" + manualCard + "' has ALREADY been issued in " + sDate.ToString("MMMM yyyy") + " to " + conflict + "! Please enter a unique Register / Card No.", false);
                            return;
                        }
                    }

                    try
                    {
                        con.Open();
                        cmd.ExecuteNonQuery();
                    }
                    catch (SqlException ex)
                    {
                        if (ex.Number == 8144 || ex.Message.Contains("too many arguments"))
                        {
                            if (cmd.Parameters.Contains("@ManualCardNo")) cmd.Parameters.Remove(cmd.Parameters["@ManualCardNo"]);
                            if (cmd.Parameters.Contains("@DependentMemberNo")) cmd.Parameters.Remove(cmd.Parameters["@DependentMemberNo"]);
                            if (cmd.Parameters.Contains("@DependentName")) cmd.Parameters.Remove(cmd.Parameters["@DependentName"]);
                            if (cmd.Parameters.Contains("@DependentRelation")) cmd.Parameters.Remove(cmd.Parameters["@DependentRelation"]);
                            cmd.ExecuteNonQuery();
                        }
                        else throw;
                    }
                }
            }

            if (txtMemberSubManualCardNo != null) txtMemberSubManualCardNo.Text = "";
            ShowMessage("Subscription assigned successfully!", true);

            // Reset form fields
            if (ddlPackages.Items.Count > 0) ddlPackages.SelectedIndex = 0;
            if (ddlLocker.Items.Count > 0) ddlLocker.SelectedIndex = 0;
            if (txtLockerFee != null) txtLockerFee.Text = "0";
            if (txtEndDate != null) txtEndDate.Text = "";

            string depMemberNo = string.IsNullOrEmpty(hfDependentMemberNo.Value) ? null : hfDependentMemberNo.Value;
            btnSearch_Click(null, null);
        }
        catch (Exception ex)
        {
            ShowMessage("Error assigning subscription: " + ex.Message, false);
        }
    }

    protected void btnConfirmMemberSubModal_Click(object sender, EventArgs e)
    {
        string manualCardNo = txtMemberSubManualCardNo != null ? txtMemberSubManualCardNo.Text.Trim() : "";
        string source = hfModalMemberSubSource != null ? hfModalMemberSubSource.Value : "";

        if (source == "formAssign")
        {
            btnAssign_Click(sender, e);
        }
        else
        {
            string args = hfModalMemberSubArgs != null ? hfModalMemberSubArgs.Value : "";
            if (!string.IsNullOrEmpty(args))
            {
                string[] parts = args.Split('|');
                if (parts.Length >= 7)
                {
                    int memberId = Convert.ToInt32(parts[1]);
                    string memberNo = parts[2];
                    string fullName = parts[3];
                    string rel = parts[6];

                    int sportId = 0;
                    if (hfModalMemberSportId != null && !string.IsNullOrEmpty(hfModalMemberSportId.Value))
                    {
                        int.TryParse(hfModalMemberSportId.Value, out sportId);
                    }
                    if (sportId == 0 && ddlSports != null && ddlSports.SelectedIndex > 0)
                    {
                        int.TryParse(ddlSports.SelectedValue, out sportId);
                    }

                    string subType = hfModalMemberSubType != null && !string.IsNullOrEmpty(hfModalMemberSubType.Value) && hfModalMemberSubType.Value != "0"
                        ? hfModalMemberSubType.Value
                        : (ddlTopSubscriptionType != null ? ddlTopSubscriptionType.SelectedValue : "Continuous");

                    SaveSubscriptionFromGridRow(memberId, memberNo, fullName, rel, sportId, subType, manualCardNo);
                }
                else
                {
                    ShowMessage("Invalid member selection data. Please try again.", false);
                }
            }
            else
            {
                ShowMessage("No member selected for subscription save.", false);
            }
        }
    }

    private string CheckManualCardDuplicateInMonth(SqlConnection con, string cardNo, DateTime startDate)
    {
        if (string.IsNullOrWhiteSpace(cardNo)) return null;
        try
        {
            if (con.State != ConnectionState.Open) con.Open();
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

    private void ShowMessage(string msg, bool isSuccess, bool isWarning = false)
    {
        lblMessage.Visible = true;
        lblMessage.Text = msg;
        if (isWarning)
        {
            lblMessage.Style["background-color"] = "#fffbeb";
            lblMessage.Style["color"] = "#92400e";
            lblMessage.Style["border"] = "1px solid #fcd34d";
            lblMessage.Style["border-left"] = "4px solid #f59e0b";
            lblMessage.Style["padding"] = "6px 14px";
            lblMessage.Style["font-size"] = "12px";
            lblMessage.Style["border-radius"] = "4px";
            lblMessage.Style["display"] = "flex";
            lblMessage.Style["align-items"] = "center";
            lblMessage.Style["gap"] = "8px";
            lblMessage.Style["margin-bottom"] = "10px";
        }
        else if (isSuccess)
        {
            lblMessage.Style["background-color"] = "#ecfdf5";
            lblMessage.Style["color"] = "#065f46";
            lblMessage.Style["border"] = "1px solid #a7f3d0";
            lblMessage.Style["border-left"] = "4px solid #10b981";
            lblMessage.Style["padding"] = "6px 14px";
            lblMessage.Style["font-size"] = "12px";
            lblMessage.Style["border-radius"] = "4px";
            lblMessage.Style["display"] = "block";
            lblMessage.Style["margin-bottom"] = "10px";
        }
        else
        {
            lblMessage.Style["background-color"] = "#fef2f2";
            lblMessage.Style["color"] = "#991b1b";
            lblMessage.Style["border"] = "1px solid #fecaca";
            lblMessage.Style["border-left"] = "4px solid #ef4444";
            lblMessage.Style["padding"] = "6px 14px";
            lblMessage.Style["font-size"] = "12px";
            lblMessage.Style["border-radius"] = "4px";
            lblMessage.Style["display"] = "block";
            lblMessage.Style["margin-bottom"] = "10px";
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

    private string FetchMemberAge(int memberId, string relationship, string dependentMemberNo)
    {
        try
        {
            string memberShipConn = ConfigurationManager.ConnectionStrings["MemberShipConnString"] != null ? ConfigurationManager.ConnectionStrings["MemberShipConnString"].ConnectionString : connString.Replace("SportsModuleDB", "MemberShip");
            using (SqlConnection con = new SqlConnection(memberShipConn))
            {
                string dobQuery = "";
                if (relationship == "Self" || string.IsNullOrEmpty(relationship))
                {
                    dobQuery = "SELECT TOP 1 DOB FROM MemberProfile WHERE MemberID = @MemberID OR MemberID_New = @MemberID";
                }
                else if (relationship == "Spouse" || relationship.StartsWith("W") || relationship.StartsWith("w"))
                {
                    dobQuery = "SELECT TOP 1 DOB FROM MemberSpouses WHERE MembershipNo = @DependentMemberNo";
                }
                else
                {
                    dobQuery = "SELECT TOP 1 DOB FROM MemberChildren WHERE MembershipNo = @DependentMemberNo";
                }

                using (SqlCommand cmdDob = new SqlCommand(dobQuery, con))
                {
                    cmdDob.Parameters.AddWithValue("@MemberID", memberId);
                    cmdDob.Parameters.AddWithValue("@DependentMemberNo", string.IsNullOrEmpty(dependentMemberNo) ? (object)DBNull.Value : dependentMemberNo);
                    con.Open();
                    object dobResult = cmdDob.ExecuteScalar();
                    if (dobResult != null && dobResult != DBNull.Value)
                    {
                        DateTime dob;
                        if (DateTime.TryParse(dobResult.ToString(), out dob))
                        {
                            int age = DateTime.Now.Year - dob.Year;
                            if (dob.Date > DateTime.Now.AddYears(-age)) age--;
                            return age.ToString() + " Yrs";
                        }
                    }
                }
            }
        }
        catch { }
        return "N/A";
    }

    private void EnsureAllRFIDColumns(SqlConnection con)
    {
        try
        {
            string[] tables = new string[] { "MemberProfile", "MemberSpouses", "MemberChildren" };
            foreach (string tbl in tables)
            {
                string checkSql = string.Format(@"
                    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '{0}')
                    BEGIN
                        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '{0}' AND COLUMN_NAME = 'RFID')
                            ALTER TABLE dbo.{0} ADD RFID NVARCHAR(100) NULL;
                        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '{0}' AND COLUMN_NAME = 'IsCardActive')
                            ALTER TABLE dbo.{0} ADD IsCardActive INT NULL DEFAULT 1;
                        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '{0}' AND COLUMN_NAME = 'CardStatus')
                            ALTER TABLE dbo.{0} ADD CardStatus NVARCHAR(50) NULL DEFAULT 'ACTIVE';
                    END", tbl);
                using (SqlCommand cmd = new SqlCommand(checkSql, con))
                {
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch { }
    }

    private Tuple<string, int> GetMemberRFIDInfo(int memberId, string relationship, string depMemberNo)
    {
        try
        {
            string memberShipConn = ConfigurationManager.ConnectionStrings["MemberShipConnString"] != null ? ConfigurationManager.ConnectionStrings["MemberShipConnString"].ConnectionString : connString.Replace("SportsModuleDB", "MemberShip");
            using (SqlConnection con = new SqlConnection(memberShipConn))
            {
                con.Open();
                EnsureAllRFIDColumns(con);

                string table = "MemberProfile";
                string whereCol = "(MemberID = @MemberID OR MemberID_New = @MemberID)";

                if (relationship == "Spouse" || relationship.StartsWith("W") || relationship.StartsWith("w"))
                {
                    table = "MemberSpouses";
                    whereCol = "MembershipNo = @DepNo";
                }
                else if (relationship != "Self" && !string.IsNullOrEmpty(relationship) && !string.IsNullOrEmpty(depMemberNo))
                {
                    table = "MemberChildren";
                    whereCol = "MembershipNo = @DepNo";
                }

                string selQuery = string.Format("SELECT TOP 1 ISNULL(RFID, '') AS RFID, ISNULL(IsCardActive, 0) AS IsCardActive FROM {0} WHERE {1}", table, whereCol);

                using (SqlCommand cmd = new SqlCommand(selQuery, con))
                {
                    cmd.Parameters.AddWithValue("@MemberID", memberId);
                    cmd.Parameters.AddWithValue("@DepNo", string.IsNullOrEmpty(depMemberNo) ? (object)DBNull.Value : depMemberNo);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            string rfid = dr.GetString(0);
                            int active = Convert.ToInt32(dr[1]);
                            return new Tuple<string, int>(rfid, active);
                        }
                    }
                }
            }
        }
        catch { }
        return new Tuple<string, int>("", 0);
    }

    private void OpenRFIDAssignmentModal(string memberId, string membershipNo, string fullName, string relationship)
    {
        lblRFIDModalMsg.Visible = false;
        hfRFIDMemberID.Value = memberId;
        hfRFIDMemberNo.Value = membershipNo;
        hfRFIDRelationship.Value = relationship;

        lblRFIDMemberDetails.Text = fullName + " (" + membershipNo + " - " + relationship + ")";

        var rfidInfo = GetMemberRFIDInfo(Convert.ToInt32(memberId), relationship, relationship == "Self" ? "" : membershipNo);
        string rfidNum = rfidInfo.Item1;
        int active = rfidInfo.Item2;

        txtModalRFIDInput.Text = rfidNum;

        if (active == 1 && !string.IsNullOrEmpty(rfidNum))
        {
            lblRFIDCurrentStatus.Text = "ACTIVE (" + rfidNum + ")";
            lblRFIDCurrentStatus.Style["color"] = "#10b981";
            btnModalDeactivateRFID.Visible = true;
        }
        else
        {
            lblRFIDCurrentStatus.Text = "Not Assigned / Inactive";
            lblRFIDCurrentStatus.Style["color"] = "#6b7280";
            btnModalDeactivateRFID.Visible = false;
        }

        pnlRFIDAssignmentModal.Style["display"] = "flex";
    }

    protected void btnModalCloseRFID_Click(object sender, EventArgs e)
    {
        pnlRFIDAssignmentModal.Style["display"] = "none";
    }

    protected void btnModalSaveRFID_Click(object sender, EventArgs e)
    {
        lblRFIDModalMsg.Visible = false;
        string newRfid = txtModalRFIDInput.Text.Trim();
        if (string.IsNullOrEmpty(newRfid))
        {
            ShowRFIDModalMessage("Please scan or enter an RFID card number.", false);
            pnlRFIDAssignmentModal.Style["display"] = "flex";
            return;
        }

        int memberId = Convert.ToInt32(hfRFIDMemberID.Value);
        string rel = hfRFIDRelationship.Value;
        string depNo = hfRFIDMemberNo.Value;

        string err;
        bool ok = UpdateMemberRFID(memberId, rel, rel == "Self" ? "" : depNo, newRfid, 1, out err);
        if (ok)
        {
            ShowMessage("RFID Card (" + newRfid + ") assigned & activated successfully for " + lblRFIDMemberDetails.Text + "!", true);
            pnlRFIDAssignmentModal.Style["display"] = "none";
            btnSearch_Click(null, null);
        }
        else
        {
            ShowRFIDModalMessage(err, false);
            pnlRFIDAssignmentModal.Style["display"] = "flex";
        }
    }

    protected void btnModalDeactivateRFID_Click(object sender, EventArgs e)
    {
        lblRFIDModalMsg.Visible = false;
        int memberId = Convert.ToInt32(hfRFIDMemberID.Value);
        string rel = hfRFIDRelationship.Value;
        string depNo = hfRFIDMemberNo.Value;

        string err;
        bool ok = UpdateMemberRFID(memberId, rel, rel == "Self" ? "" : depNo, null, 0, out err);
        if (ok)
        {
            ShowMessage("RFID Card deactivated successfully.", true);
            pnlRFIDAssignmentModal.Style["display"] = "none";
            btnSearch_Click(null, null);
        }
        else
        {
            ShowRFIDModalMessage("Error deactivating RFID card: " + err, false);
            pnlRFIDAssignmentModal.Style["display"] = "flex";
        }
    }

    private bool UpdateMemberRFID(int memberId, string relationship, string dependentMemberNo, string rfid, int isActive, out string errorMsg)
    {
        errorMsg = "";
        try
        {
            string memberShipConn = ConfigurationManager.ConnectionStrings["MemberShipConnString"] != null ? ConfigurationManager.ConnectionStrings["MemberShipConnString"].ConnectionString : connString.Replace("SportsModuleDB", "MemberShip");
            using (SqlConnection con = new SqlConnection(memberShipConn))
            {
                con.Open();
                EnsureAllRFIDColumns(con);

                string table = "MemberProfile";
                string whereCol = "(MemberID = @MemberID OR MemberID_New = @MemberID)";

                if (relationship == "Spouse" || relationship.StartsWith("W") || relationship.StartsWith("w"))
                {
                    table = "MemberSpouses";
                    whereCol = "MembershipNo = @DepNo";
                }
                else if (relationship != "Self" && !string.IsNullOrEmpty(relationship) && !string.IsNullOrEmpty(dependentMemberNo))
                {
                    table = "MemberChildren";
                    whereCol = "MembershipNo = @DepNo";
                }

                // Duplicate RFID check across all tables
                if (isActive == 1 && !string.IsNullOrEmpty(rfid))
                {
                    string dupCheckSql = @"
                        SELECT MemberName FROM dbo.MemberProfile WHERE RFID = @RFID AND MemberID <> @MemberID
                        UNION ALL
                        SELECT SpouseName FROM dbo.MemberSpouses WHERE RFID = @RFID AND (MembershipNo <> @DepNo OR @DepNo IS NULL)
                        UNION ALL
                        SELECT ChildName FROM dbo.MemberChildren WHERE RFID = @RFID AND (MembershipNo <> @DepNo OR @DepNo IS NULL)";

                    using (SqlCommand dupCmd = new SqlCommand(dupCheckSql, con))
                    {
                        dupCmd.Parameters.AddWithValue("@RFID", rfid);
                        dupCmd.Parameters.AddWithValue("@MemberID", memberId);
                        dupCmd.Parameters.AddWithValue("@DepNo", string.IsNullOrEmpty(dependentMemberNo) ? (object)DBNull.Value : dependentMemberNo);
                        object existing = dupCmd.ExecuteScalar();
                        if (existing != null && existing != DBNull.Value)
                        {
                            errorMsg = "RFID card '" + rfid + "' is already assigned to " + existing.ToString() + ". Please use a unique card.";
                            return false;
                        }
                    }
                }

                string updateSql = string.Format("UPDATE {0} SET RFID = @RFID, IsCardActive = @IsActive, CardStatus = @Status WHERE {1}", table, whereCol);

                using (SqlCommand cmd = new SqlCommand(updateSql, con))
                {
                    cmd.Parameters.AddWithValue("@IsActive", isActive);
                    cmd.Parameters.AddWithValue("@Status", isActive == 1 ? "ACTIVE" : "INACTIVE");
                    cmd.Parameters.AddWithValue("@RFID", rfid ?? "");
                    cmd.Parameters.AddWithValue("@MemberID", memberId);
                    cmd.Parameters.AddWithValue("@DepNo", string.IsNullOrEmpty(dependentMemberNo) ? (object)DBNull.Value : dependentMemberNo);

                    int rows = cmd.ExecuteNonQuery();
                    if (rows == 0)
                    {
                        errorMsg = "No record found in " + table + " for membership " + dependentMemberNo;
                        return false;
                    }
                }
            }
            return true;
        }
        catch (Exception ex)
        {
            errorMsg = ex.Message;
            return false;
        }
    }

    private void ShowRFIDModalMessage(string msg, bool isSuccess)
    {
        lblRFIDModalMsg.Visible = true;
        lblRFIDModalMsg.Text = msg;
        if (isSuccess)
        {
            lblRFIDModalMsg.Style["background-color"] = "#d4edda";
            lblRFIDModalMsg.Style["color"] = "#155724";
            lblRFIDModalMsg.Style["border"] = "1px solid #c3e6cb";
        }
        else
        {
            lblRFIDModalMsg.Style["background-color"] = "#f8d7da";
            lblRFIDModalMsg.Style["color"] = "#721c24";
            lblRFIDModalMsg.Style["border"] = "1px solid #f5c6cb";
        }
    }



    protected void ddlPackages_SelectedIndexChanged(object sender, EventArgs e)
    {
        UpdateEndDateBasedOnPackage();
        CalculatePackageRate();
    }

    protected void txtStartDate_TextChanged(object sender, EventArgs e)
    {
        UpdateEndDateBasedOnPackage();
    }

    private void UpdateEndDateBasedOnPackage()
    {
        if (ddlPackages.SelectedValue == "0") return;

        string[] packageParts = ddlPackages.SelectedValue.Split('|');
        if (packageParts.Length > 1)
        {
            string subType = packageParts[1];

            DateTime startDate;
            if (!DateTime.TryParse(txtStartDate.Text, out startDate))
            {
                startDate = DateTime.Today;
                txtStartDate.Text = startDate.ToString("yyyy-MM-dd");
            }

            if (subType.Equals("Monthly", StringComparison.OrdinalIgnoreCase))
            {
                DateTime lastDayOfMonth = new DateTime(startDate.Year, startDate.Month, DateTime.DaysInMonth(startDate.Year, startDate.Month));
                txtEndDate.Text = lastDayOfMonth.ToString("yyyy-MM-dd");
            }
            else if (subType.Equals("Continuous", StringComparison.OrdinalIgnoreCase))
            {
                txtEndDate.Text = ""; // Continuous does not have an end date
            }
        }
    }



    private void OpenQuickPaymentModal(string memberId, string membershipNo, string fullName, string status, string initialTab)
    {
        hfModalMemberID.Value = memberId;
        lblModalMemberNo.Text = membershipNo;
        lblModalFullName.Text = fullName;
        hfModalMemberStatus.Value = status;
        hfModalActiveTab.Value = string.IsNullOrEmpty(initialTab) ? "payment" : initialTab;

        // Reset forms
        txtModalAmountPaid.Text = "";
        ddlModalPaymentMode.SelectedIndex = 0;
        ddlModalPaymentMode_SelectedIndexChanged(null, null);

        // Load ledger balance & active subscriptions
        LoadModalLedgerBalance(memberId);
        LoadModalActiveSubscriptions(memberId);

        // Hide sub panels & messages
        pnlModalConfirmCharge.Visible = false;
        lblModalMessage.Visible = false;

        // Open modal
        pnlPaymentProcessModal.Style["display"] = "flex";
    }

    protected void CalculatePackageRate()
    {
        if (ddlPackages.SelectedValue == "0" || string.IsNullOrEmpty(hfMemberID.Value))
        {
            lblRatePolicy.Text = "No Package Selected";
            lblRatePolicy.Style["background-color"] = "var(--gray-500)";
            return;
        }

        string[] parts = ddlPackages.SelectedValue.Split('|');
        if (parts.Length < 4) return;

        int subscriptionId = Convert.ToInt32(parts[0]);

        decimal discountPercent = 0;
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT dbo.fn_GetDynamicDiscountPercentage(@MemberID, @DependentMemberNo, @SubID)", con))
                {
                    cmd.Parameters.AddWithValue("@MemberID", Convert.ToInt32(hfMemberID.Value));
                    cmd.Parameters.AddWithValue("@DependentMemberNo", string.IsNullOrEmpty(hfDependentMemberNo.Value) ? (object)DBNull.Value : hfDependentMemberNo.Value);
                    cmd.Parameters.AddWithValue("@SubID", subscriptionId);
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        discountPercent = Convert.ToDecimal(result);
                    }
                }
            }
        }
        catch { }

        if (discountPercent > 0)
        {
            lblRatePolicy.Text = discountPercent == 100 ? "Full Free (100% Off)" : "Discount Applied (" + discountPercent.ToString("0.##") + "% Off)";
            lblRatePolicy.Style["background-color"] = discountPercent == 100 ? "var(--success)" : "var(--warning)";
        }
        else
        {
            lblRatePolicy.Text = "Base (Full Charge)";
            lblRatePolicy.Style["background-color"] = "var(--primary)";
        }

        // Calculate numeric values for display
        decimal baseFee = Convert.ToDecimal(parts[2]);
        decimal gstPercent = Convert.ToDecimal(parts[3]);
        decimal policyDiscount = baseFee * (discountPercent / 100m);

        decimal feeAfterPolicy = baseFee - policyDiscount;
        if (feeAfterPolicy < 0) feeAfterPolicy = 0;

        decimal lockerFee = 0;
        if (ddlLocker.SelectedValue != "0" && !string.IsNullOrEmpty(ddlLocker.SelectedValue))
        {
            string[] lockerParts = ddlLocker.SelectedValue.Split('|');
            if (lockerParts.Length >= 2)
            {
                decimal.TryParse(lockerParts[1], out lockerFee);
            }
        }
        txtLockerFee.Text = lockerFee.ToString("0.00");

        decimal gstAmount = feeAfterPolicy * (gstPercent / 100m);
        decimal netTotal = feeAfterPolicy + gstAmount + lockerFee;
    }

    protected void btnTriggerAction_Click(object sender, EventArgs e)
    {
        string command = hfActionCommand.Value;
        string argument = hfActionArgument.Value;

        if (command == "ToggleContinuousSub")
        {
            string[] args = argument.Split('|');
            int memberSubId = Convert.ToInt32(args[0]);
            bool currentlyActive = Convert.ToBoolean(args[1]);
            bool newStatus = !currentlyActive;

            try
            {
                using (SqlConnection con = new SqlConnection(connString))
                {
                    con.Open();
                    if (newStatus)
                    {
                        // Insert NEW row for this reactivation cycle so previous history is preserved intact
                        string insertQuery = @"
                            INSERT INTO MemberSubscriptions (
                                MemberID, SubscriptionID, StartDate, EndDate, IsActive, AssignedOn,
                                DependentMemberNo, DependentName, DependentRelation, PolicyDiscount, GSTAmount,
                                ManualDiscount, NetFee, PaymentMode, ReferenceID, BankID, BankDiscount, LockerID, LockerFee, ManualCardNo
                            )
                            SELECT 
                                MemberID, SubscriptionID, CAST(GETDATE() AS DATE), NULL, 1, GETDATE(),
                                DependentMemberNo, DependentName, DependentRelation, PolicyDiscount, GSTAmount,
                                ManualDiscount, NetFee, PaymentMode, ReferenceID, BankID, BankDiscount, LockerID, LockerFee, ManualCardNo
                            FROM MemberSubscriptions 
                            WHERE MemberSubID = @MemberSubID;
                            SELECT SCOPE_IDENTITY();";

                        int newSubId = 0;
                        using (SqlCommand cmd = new SqlCommand(insertQuery, con))
                        {
                            cmd.Parameters.AddWithValue("@MemberSubID", memberSubId);
                            object oId = cmd.ExecuteScalar();
                            if (oId != null && oId != DBNull.Value) int.TryParse(oId.ToString(), out newSubId);
                        }

                        if (newSubId > 0)
                        {
                            using (SqlCommand cmd = new SqlCommand("sp_RenewContinuousSubscription", con))
                            {
                                cmd.CommandType = CommandType.StoredProcedure;
                                cmd.Parameters.AddWithValue("@MemberSubID", newSubId);
                                try { cmd.ExecuteNonQuery(); } catch { }
                            }
                        }
                    }
                    else
                    {
                        string query = "UPDATE MemberSubscriptions SET IsActive = 0, EndDate = GETDATE(), DeactivatedOn = GETDATE() WHERE MemberSubID = @MemberSubID";
                        using (SqlCommand cmd = new SqlCommand(query, con))
                        {
                            cmd.Parameters.AddWithValue("@MemberSubID", memberSubId);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
                ShowMessage(newStatus ? "Continuous subscription resumed. Auto-renewal has run and posted to the ledger." : "Continuous subscription stopped.", true);
                btnSearch_Click(null, null); // Refresh the grid
            }
            catch (Exception ex)
            {
                ShowMessage("Error toggling subscription: " + ex.Message, false);
            }
        }
        else if (command == "StopSub")
        {
            int memberSubId = Convert.ToInt32(argument);
            try
            {
                using (SqlConnection con = new SqlConnection(connString))
                {
                    string query = "UPDATE MemberSubscriptions SET IsActive = 0, EndDate = GETDATE(), DeactivatedOn = GETDATE() WHERE MemberSubID = @MemberSubID";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@MemberSubID", memberSubId);
                        con.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                ShowMessage("Subscription successfully stopped.", true);
                btnSearch_Click(null, null); // Refresh the grid
            }
            catch (Exception ex)
            {
                ShowMessage("Error stopping subscription: " + ex.Message, false);
            }
        }
        else if (command == "ToggleMonthlySub")
        {
            string[] args = argument.Split('|');
            int memberSubId = Convert.ToInt32(args[0]);
            bool currentlyActive = Convert.ToBoolean(args[1]);
            bool newStatus = !currentlyActive;

            try
            {
                using (SqlConnection con = new SqlConnection(connString))
                {
                    con.Open();
                    if (newStatus)
                    {
                        DateTime today = DateTime.Today;
                        DateTime endOfMonth = new DateTime(today.Year, today.Month, DateTime.DaysInMonth(today.Year, today.Month));

                        // Insert NEW row for this reactivation cycle so previous history is preserved intact
                        string insertQuery = @"
                            INSERT INTO MemberSubscriptions (
                                MemberID, SubscriptionID, StartDate, EndDate, IsActive, AssignedOn,
                                DependentMemberNo, DependentName, DependentRelation, PolicyDiscount, GSTAmount,
                                ManualDiscount, NetFee, PaymentMode, ReferenceID, BankID, BankDiscount, LockerID, LockerFee, ManualCardNo
                            )
                            SELECT 
                                MemberID, SubscriptionID, CAST(GETDATE() AS DATE), @EndDate, 1, GETDATE(),
                                DependentMemberNo, DependentName, DependentRelation, PolicyDiscount, GSTAmount,
                                ManualDiscount, NetFee, PaymentMode, ReferenceID, BankID, BankDiscount, LockerID, LockerFee, ManualCardNo
                            FROM MemberSubscriptions 
                            WHERE MemberSubID = @MemberSubID;";

                        using (SqlCommand cmd = new SqlCommand(insertQuery, con))
                        {
                            cmd.Parameters.AddWithValue("@EndDate", endOfMonth);
                            cmd.Parameters.AddWithValue("@MemberSubID", memberSubId);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        string query = "UPDATE MemberSubscriptions SET IsActive = 0, EndDate = GETDATE(), DeactivatedOn = GETDATE() WHERE MemberSubID = @MemberSubID";
                        using (SqlCommand cmd = new SqlCommand(query, con))
                        {
                            cmd.Parameters.AddWithValue("@MemberSubID", memberSubId);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
                string currentMonth = DateTime.Now.ToString("MMMM");
                ShowMessage(newStatus ? "Subscription reactivated for " + currentMonth + "." : "Subscription deactivated for " + currentMonth + ".", true);
                btnSearch_Click(null, null); // Refresh grid
            }
            catch (Exception ex)
            {
                ShowMessage("Error toggling monthly subscription: " + ex.Message, false);
            }
        }
    }



    protected string GetDatePeriodHtml(object memberIdObj, object relationshipObj, object depMemberNoObj)
    {
        if (memberIdObj == null) return "-";

        int memberId = Convert.ToInt32(memberIdObj);
        string relationship = relationshipObj != null ? relationshipObj.ToString() : "Self";
        string depMemberNo = depMemberNoObj != null ? depMemberNoObj.ToString() : "";

        string key = memberId.ToString() + "_" + (relationship == "Self" ? "" : depMemberNo);

        if (_allActiveSubs.ContainsKey(key) && _allActiveSubs[key].Count > 0)
        {
            List<string> periodList = new List<string>();
            foreach (var sub in _allActiveSubs[key])
            {
                string startStr = sub.StartDate.HasValue ? sub.StartDate.Value.ToString("dd MMM yyyy") : "N/A";
                string endStr = sub.SubscriptionType == "Continuous"
                    ? "<span style='color:#10b981; font-weight:700;'>Ongoing</span>"
                    : (sub.EndDate.HasValue ? sub.EndDate.Value.ToString("dd MMM yyyy") : "N/A");

                periodList.Add(string.Format("<span style='font-size:12px; font-weight:600; color:#374151;'>{0} - {1}</span>", startStr, endStr));
            }
            return string.Join("<br/>", periodList);
        }

        return "<span style='font-size: 12px; color: #9ca3af; font-style: italic;'>-</span>";
    }

    protected bool IsCurrentMonthActive(object memberIdObj, object relationshipObj, object depMemberNoObj)
    {
        if (memberIdObj == null) return false;
        int memberId = Convert.ToInt32(memberIdObj);
        string relationship = relationshipObj != null ? relationshipObj.ToString() : "Self";
        string depMemberNo = depMemberNoObj != null ? depMemberNoObj.ToString() : "";

        string key = memberId.ToString() + "_" + (relationship == "Self" ? "" : depMemberNo);
        if (_allActiveSubs.ContainsKey(key) && _allActiveSubs[key].Count > 0)
        {
            return _allActiveSubs[key].Exists(s => s.IsActive);
        }
        return false;
    }

    protected string GetCurrentMonthStatusText(object memberIdObj, object relationshipObj, object depMemberNoObj)
    {
        string currentMonth = DateTime.Now.ToString("MMM");
        bool isActive = IsCurrentMonthActive(memberIdObj, relationshipObj, depMemberNoObj);
        return currentMonth + " (" + (isActive ? "Active" : "Deactive") + ")";
    }

    protected void btn12MonthClose_Click(object sender, EventArgs e)
    {
        pnl12MonthModal.Style["display"] = "none";
    }

    private void Open12MonthModal(string memberIdStr, string membershipNo, string fullName, string relationship)
    {
        int memberId = Convert.ToInt32(memberIdStr);
        int currentYear = DateTime.Now.Year;
        lit12MonthYear.Text = currentYear.ToString();
        lbl12MonthMemberName.Text = fullName + " (" + relationship + ")";
        lbl12MonthMembershipNo.Text = membershipNo;

        string depNo = (relationship == "Self" || string.IsNullOrEmpty(relationship)) ? "" : membershipNo;

        DataTable dtSubs = GetMemberSubscriptionsFor12Month(memberId, depNo);

        DataTable dtMonths = new DataTable();
        dtMonths.Columns.Add("MonthNumber", typeof(int));
        dtMonths.Columns.Add("MonthName", typeof(string));
        dtMonths.Columns.Add("IsActive", typeof(bool));
        dtMonths.Columns.Add("SportsList", typeof(string));

        string[] monthNames = new string[] { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" };

        for (int m = 1; m <= 12; m++)
        {
            DateTime mStart = new DateTime(currentYear, m, 1);
            DateTime mEnd = new DateTime(currentYear, m, DateTime.DaysInMonth(currentYear, m));

            List<string> activeSports = new List<string>();
            bool isMonthActive = false;

            foreach (DataRow row in dtSubs.Rows)
            {
                bool isActive = row["IsActive"] != DBNull.Value && Convert.ToBoolean(row["IsActive"]);
                DateTime? startDate = row["StartDate"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(row["StartDate"]);
                DateTime? endDate = row["EndDate"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(row["EndDate"]);
                string sportName = row["SportName"] != DBNull.Value ? row["SportName"].ToString() : (row["PackageName"] != DBNull.Value ? row["PackageName"].ToString() : "Sports");

                if (isActive && startDate.HasValue)
                {
                    if (startDate.Value.Date <= mEnd.Date && (!endDate.HasValue || endDate.Value.Date >= mStart.Date))
                    {
                        isMonthActive = true;
                        if (!activeSports.Contains(sportName))
                        {
                            activeSports.Add(sportName);
                        }
                    }
                }
            }

            DataRow newRow = dtMonths.NewRow();
            newRow["MonthNumber"] = m;
            newRow["MonthName"] = monthNames[m - 1];
            newRow["IsActive"] = isMonthActive;
            newRow["SportsList"] = isMonthActive ? string.Join(", ", activeSports) : "-";
            dtMonths.Rows.Add(newRow);
        }

        rpt12Months.DataSource = dtMonths;
        rpt12Months.DataBind();

        pnl12MonthModal.Style["display"] = "flex";
    }

    private DataTable GetMemberSubscriptionsFor12Month(int memberId, string dependentMemberNo)
    {
        DataTable dt = new DataTable();
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string sql = @"
                    SELECT ms.MemberSubID, ms.MemberID, ms.DependentMemberNo, s.PackageName, s.SubscriptionType, ms.IsActive, 
                           sp.SportName, ms.StartDate, ms.EndDate
                    FROM MemberSubscriptions ms
                    INNER JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
                    LEFT JOIN Sports sp ON s.SportID = sp.SportID
                    WHERE ms.MemberID = @MemberID";

                if (!string.IsNullOrEmpty(dependentMemberNo))
                {
                    sql += " AND ms.DependentMemberNo = @DepNo";
                }
                else
                {
                    sql += " AND (ms.DependentMemberNo IS NULL OR ms.DependentMemberNo = '')";
                }

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@MemberID", memberId);
                    cmd.Parameters.AddWithValue("@DepNo", string.IsNullOrEmpty(dependentMemberNo) ? (object)DBNull.Value : dependentMemberNo);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }
        }
        catch { }
        return dt;
    }

    protected string GetActionsHtml(object memberIdObj, object relationshipObj, object depMemberNoObj)
    {
        if (memberIdObj == null) return "";

        int memberId = Convert.ToInt32(memberIdObj);
        string relationship = relationshipObj != null ? relationshipObj.ToString() : "Self";
        string depMemberNo = depMemberNoObj != null ? depMemberNoObj.ToString() : "";

        string key = memberId.ToString() + "_" + (relationship == "Self" ? "" : depMemberNo);

        System.Text.StringBuilder sb = new System.Text.StringBuilder();

        if (_allActiveSubs.ContainsKey(key))
        {
            foreach (var sub in _allActiveSubs[key])
            {
                sb.Append("<div style='margin-bottom: 6px; display: flex; align-items: center; gap: 8px; justify-content: flex-start;'>");

                string displayName = string.IsNullOrEmpty(sub.SportName) ? sub.PackageName : sub.SportName;

                if (sub.SubscriptionType == "Continuous")
                {
                    if (sub.IsActive)
                    {
                        sb.AppendFormat("<span style='font-size: 13px; font-weight: 700; color: #1e3a8a;'>Active {0}</span>", displayName);
                        sb.AppendFormat("<a href='javascript:void(0);' onclick='confirmToggle({0}, \"Active\")' title='Deactivate Continuous {1}' style='color: #10b981; font-size: 22px; display: inline-block; vertical-align: middle; text-decoration: none;'><i class='fas fa-toggle-on'></i></a>", sub.MemberSubID, displayName);
                    }
                    else
                    {
                        sb.AppendFormat("<span style='font-size: 13px; font-weight: 500; color: #9ca3af;'>Inactive {0}</span>", displayName);
                        sb.AppendFormat("<a href='javascript:void(0);' onclick='confirmToggle({0}, \"Stopped\")' title='Activate Continuous {1}' style='color: #9ca3af; font-size: 22px; display: inline-block; vertical-align: middle; text-decoration: none;'><i class='fas fa-toggle-off'></i></a>", sub.MemberSubID, displayName);
                    }
                }
                else
                {
                    if (sub.IsActive)
                    {
                        sb.AppendFormat("<span style='font-size: 12px; font-weight: 700; color: #065f46; background-color: #d1fae5; padding: 3px 8px; border-radius: 12px;'>Active {0}</span>", displayName);
                        sb.AppendFormat("<a href='javascript:void(0);' onclick='confirmStop({0})' style='background-color: #ef4444; color: #ffffff; padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; text-decoration: none; display: inline-block; cursor: pointer; box-shadow: 0 2px 4px rgba(239, 68, 68, 0.2); margin-left: 4px;'>Stop</a>", sub.MemberSubID);
                    }
                    else
                    {
                        sb.AppendFormat("<span style='font-size: 11px; color: #9ca3af; font-style: italic;'>Inactive {0}</span>", displayName);
                    }
                }
                sb.Append("</div>");
            }
        }

        if (sb.Length == 0)
        {
            return "<span style='font-size: 12px; color: #9ca3af; font-style: italic;'>No Active Sports</span>";
        }

        return sb.ToString();
    }

    protected void btnRunMaintenance_Click(object sender, EventArgs e)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_DailySubscriptionMaintenance", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            ShowMessage("Daily maintenance executed successfully. Subscriptions updated and Continuous bills charged.", true);

            if (!string.IsNullOrEmpty(hfMemberID.Value))
            {
                btnSearch_Click(null, null);
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error running daily maintenance: " + ex.Message, false);
        }
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

    private void LoadModalLedgerBalance(string memberId)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = "SELECT ISNULL(SUM(DebitAmount), 0) - ISNULL(SUM(CreditAmount), 0) FROM LedgerEntries WHERE MemberID = @MemberID";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@MemberID", memberId);
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        decimal balance = Convert.ToDecimal(result);
                        lblModalBalance.Text = "PKR " + Math.Abs(balance).ToString("N2");

                        if (balance > 0)
                        {
                            divModalBalance.Attributes["class"] = "balance-item-debit";
                            lblModalBalance.Text += " (Dr)";
                        }
                        else if (balance < 0)
                        {
                            divModalBalance.Attributes["class"] = "balance-item-credit";
                            lblModalBalance.Text += " (Cr)";
                        }
                        else
                        {
                            divModalBalance.Attributes["class"] = "";
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowModalMessage("Error loading balance: " + ex.Message, false);
        }
    }

    private void LoadModalActiveSubscriptions(string memberId)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetActiveSubscriptionsForCharge", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@MemberID", memberId);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        ViewState["ModalActiveSubs"] = dt;

                        gvModalActiveSubscriptions.DataSource = dt;
                        gvModalActiveSubscriptions.DataBind();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowModalMessage("Error loading active subscriptions: " + ex.Message, false);
        }
    }

    private void ShowModalMessage(string msg, bool isSuccess)
    {
        lblModalMessage.Visible = true;
        lblModalMessage.Text = msg;
        if (isSuccess)
        {
            lblModalMessage.Style["background-color"] = "#d4edda";
            lblModalMessage.Style["color"] = "#155724";
            lblModalMessage.Style["border"] = "1px solid #c3e6cb";
        }
        else
        {
            lblModalMessage.Style["background-color"] = "#f8d7da";
            lblModalMessage.Style["color"] = "#721c24";
            lblModalMessage.Style["border"] = "1px solid #f5c6cb";
        }
    }

    protected void ddlModalPaymentMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlModalPaymentMode.SelectedValue == "Credit Card" || ddlModalPaymentMode.SelectedValue == "Online Payment")
        {
            divModalCardNoPayment.Visible = true;
            divModalRefID.Visible = true;
            divModalBankCard.Visible = true;
            divModalCardType.Visible = true;
            divModalBankDiscountPercent.Visible = true;
            if (string.IsNullOrEmpty(txtModalReferenceID.Text))
            {
                txtModalReferenceID.Text = "PAY-" + DateTime.Now.ToString("yyyyMMdd") + "-" + new Random().Next(1000, 9999).ToString();
            }
        }
        else
        {
            divModalCardNoPayment.Visible = false;
            divModalRefID.Visible = false;
            divModalBankCard.Visible = false;
            divModalCardType.Visible = false;
            divModalBankDiscountPercent.Visible = false;
            divModalCardOfferInfo.Visible = false;
            txtModalPaymentCardNo.Text = "";
            txtModalCardType.Text = "";
            txtModalBankDiscountPercent.Text = "0%";
            txtModalReferenceID.Text = "";
            ddlModalBankCard.SelectedIndex = 0;
        }

        pnlPaymentProcessModal.Style["display"] = "flex";
    }

    protected void ddlModalBankCard_SelectedIndexChanged(object sender, EventArgs e)
    {
        pnlPaymentProcessModal.Style["display"] = "flex";
    }

    protected void txtModalPaymentCardNo_TextChanged(object sender, EventArgs e)
    {
        LookupModalCardPrefixOffer();
        pnlPaymentProcessModal.Style["display"] = "flex";
    }

    private void LookupModalCardPrefixOffer()
    {
        string rawCard = txtModalPaymentCardNo.Text.Trim();
        if (string.IsNullOrEmpty(rawCard) || rawCard.Length < 4)
        {
            divModalCardOfferInfo.Visible = false;
            return;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_LookupCardPrefixOffer", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@CardNo", rawCard);
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            string bankId = dr["BankID"] != DBNull.Value ? dr["BankID"].ToString() : "";
                            string bankName = dr["BankName"] != DBNull.Value ? dr["BankName"].ToString() : "";
                            string cardTypeName = dr["CardTypeName"] != DBNull.Value ? dr["CardTypeName"].ToString() : "";
                            string networkName = dr["NetworkName"] != DBNull.Value ? dr["NetworkName"].ToString() : "";
                            decimal discountPercent = dr["DiscountPercent"] != DBNull.Value ? Convert.ToDecimal(dr["DiscountPercent"]) : 0;
                            decimal surchargePercent = dr["SurchargePercent"] != DBNull.Value ? Convert.ToDecimal(dr["SurchargePercent"]) : 0;

                            string validTo = "";
                            if (dr["ValidTo"] != DBNull.Value)
                            {
                                DateTime dtValidTo = Convert.ToDateTime(dr["ValidTo"]);
                                validTo = dtValidTo.ToString("dd-MMM-yyyy");
                            }

                            bool modalBankSelected = false;
                            if (!string.IsNullOrEmpty(bankId) && bankId != "0")
                            {
                                ListItem item = ddlModalBankCard.Items.FindByValue(bankId);
                                if (item != null)
                                {
                                    ddlModalBankCard.SelectedValue = bankId;
                                    modalBankSelected = true;
                                }
                            }

                            if (!modalBankSelected && !string.IsNullOrEmpty(bankName))
                            {
                                foreach (ListItem item in ddlModalBankCard.Items)
                                {
                                    if (item.Text.IndexOf(bankName, StringComparison.OrdinalIgnoreCase) >= 0 ||
                                        bankName.IndexOf(item.Text, StringComparison.OrdinalIgnoreCase) >= 0)
                                    {
                                        ddlModalBankCard.SelectedValue = item.Value;
                                        break;
                                    }
                                }
                            }

                            txtModalCardType.Text = cardTypeName;
                            txtModalBankDiscountPercent.Text = discountPercent.ToString("0.##") + "%";

                            string infoText = string.Format("💳 <b>Type:</b> {0} ({1}) | 🏦 <b>Bank:</b> {2} | 🏷️ <b>Disc:</b> {3}% | ⚡ <b>Surplus:</b> {4}%{5}",
                                cardTypeName,
                                networkName,
                                bankName,
                                discountPercent.ToString("0.##"),
                                surchargePercent.ToString("0.##"),
                                !string.IsNullOrEmpty(validTo) ? " | 📅 <b>Valid till:</b> " + validTo : "");

                            lblModalCardOfferDetails.Text = infoText;
                            divModalCardOfferInfo.Visible = true;
                        }
                        else
                        {
                            txtModalCardType.Text = "";
                            txtModalBankDiscountPercent.Text = "0%";
                            divModalCardOfferInfo.Visible = false;
                        }
                    }
                }
            }
        }
        catch { }
    }

    protected void btnCloseModal_Click(object sender, EventArgs e)
    {
        pnlPaymentProcessModal.Style["display"] = "none";
    }

    protected void btnModalCancelCharge_Click(object sender, EventArgs e)
    {
        pnlModalConfirmCharge.Visible = false;
        pnlPaymentProcessModal.Style["display"] = "flex";
    }

    protected void btnModalReceivePayment_Click(object sender, EventArgs e)
    {
        lblModalMessage.Visible = false;

        if (string.IsNullOrWhiteSpace(txtModalAmountPaid.Text))
        {
            ShowModalMessage("Please enter amount.", false);
            pnlPaymentProcessModal.Style["display"] = "flex";
            return;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_ProcessLedgerPayment", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@MemberID", hfModalMemberID.Value);
                    cmd.Parameters.AddWithValue("@AmountPaid", Convert.ToDecimal(txtModalAmountPaid.Text));
                    cmd.Parameters.AddWithValue("@PaymentMode", ddlModalPaymentMode.SelectedValue);

                    int? bankId = null;
                    if (divModalBankCard.Visible && ddlModalBankCard.SelectedValue != "0")
                        bankId = Convert.ToInt32(ddlModalBankCard.SelectedValue);
                    cmd.Parameters.AddWithValue("@BankID", bankId.HasValue ? (object)bankId.Value : DBNull.Value);

                    string cardNo = null;
                    if (divModalCardNoPayment.Visible)
                    {
                        string rawCard = txtModalPaymentCardNo.Text.Trim();
                        if (rawCard.Length >= 4) cardNo = new string('*', rawCard.Length - 4) + rawCard.Substring(rawCard.Length - 4);
                        else if (!string.IsNullOrEmpty(rawCard)) cardNo = "****" + rawCard;
                    }
                    cmd.Parameters.AddWithValue("@CardNo", string.IsNullOrEmpty(cardNo) ? (object)DBNull.Value : cardNo);
                    cmd.Parameters.AddWithValue("@ReferenceID", string.IsNullOrEmpty(txtModalReferenceID.Text) ? (object)DBNull.Value : txtModalReferenceID.Text);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            LoadModalLedgerBalance(hfModalMemberID.Value);
            ShowModalMessage("Payment processed successfully and credited to ledger.", true);

            txtModalAmountPaid.Text = "";
            ddlModalPaymentMode.SelectedIndex = 0;
            ddlModalPaymentMode_SelectedIndexChanged(null, null);
        }
        catch (Exception ex)
        {
            ShowModalMessage("Error processing payment: " + ex.Message, false);
        }

        pnlPaymentProcessModal.Style["display"] = "flex";
    }

    protected void gvModalActiveSubscriptions_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        lblModalMessage.Visible = false;

        if (e.CommandName == "GenerateModalCharge")
        {
            int rowIndex = Convert.ToInt32(e.CommandArgument);
            DataTable dt = ViewState["ModalActiveSubs"] as DataTable;

            if (dt != null && rowIndex < dt.Rows.Count)
            {
                DataRow row = dt.Rows[rowIndex];
                int memberSubID = Convert.ToInt32(row["MemberSubID"]);

                hfModalChargeMemberSubID.Value = memberSubID.ToString();

                int sportId = Convert.ToInt32(row["SportID"]);
                int currentSubId = Convert.ToInt32(row["SubscriptionID"]);

                litModalChargePackageName.Text = row["SportName"].ToString() + " Active Subscription";
                litModalChargeMemberName.Text = string.IsNullOrEmpty(row["DependentName"].ToString()) ? "Self" : row["DependentName"] + " (" + row["DependentRelation"] + ")";

                ddlModalChargePackage.Items.Clear();
                ddlModalChargePackage.Items.Add(new ListItem("-- Select Package --", "0"));

                using (SqlConnection con = new SqlConnection(connString))
                {
                    string q = "SELECT SubscriptionID, PackageName, Fee FROM Subscriptions WHERE SportID = @SportID AND Status = 1 ORDER BY SubscriptionID DESC";
                    using (SqlCommand cmd = new SqlCommand(q, con))
                    {
                        cmd.Parameters.AddWithValue("@SportID", sportId);
                        con.Open();
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                int sId = dr.GetInt32(0);
                                string pName = dr.GetString(1);
                                decimal f = dr.GetDecimal(2);
                                ddlModalChargePackage.Items.Add(new ListItem(pName + " (PKR " + f.ToString("N0") + ")", sId.ToString()));
                            }
                        }
                    }
                }

                if (ddlModalChargePackage.Items.FindByValue(currentSubId.ToString()) != null)
                {
                    ddlModalChargePackage.SelectedValue = currentSubId.ToString();
                }
                else if (ddlModalChargePackage.Items.Count > 1)
                {
                    ddlModalChargePackage.SelectedIndex = 1;
                }

                RecalculateModalChargeDetails(row);

                txtModalBillingPeriod.Text = DateTime.Now.ToString("MMMM yyyy");
                pnlModalConfirmCharge.Visible = true;
            }
        }

        pnlPaymentProcessModal.Style["display"] = "flex";
    }

    protected void ddlModalChargePackage_SelectedIndexChanged(object sender, EventArgs e)
    {
        DataTable dt = ViewState["ModalActiveSubs"] as DataTable;
        if (dt != null && !string.IsNullOrEmpty(hfModalChargeMemberSubID.Value))
        {
            DataRow[] rows = dt.Select("MemberSubID = " + hfModalChargeMemberSubID.Value);
            if (rows.Length > 0)
            {
                RecalculateModalChargeDetails(rows[0]);
            }
        }
        pnlPaymentProcessModal.Style["display"] = "flex";
    }

    private void RecalculateModalChargeDetails(DataRow row)
    {
        if (ddlModalChargePackage.SelectedValue == "0")
        {
            litModalBaseFee.Text = "PKR 0.00";
            litModalDiscount.Text = "PKR 0.00";
            litModalGSTPercent.Text = "0.00";
            litModalGSTAmount.Text = "PKR 0.00";
            litModalNetFee.Text = "PKR 0.00";
            hfModalCalculatedNetFee.Value = "0";
            rptModalRules.DataSource = new List<object>();
            rptModalRules.DataBind();
            return;
        }

        int selectedSubId = Convert.ToInt32(ddlModalChargePackage.SelectedValue);
        decimal baseFee = 0;
        decimal gstPercent = 0;
        bool allow65 = false, allow30 = false, allow80 = false, allowChild = false;

        using (SqlConnection con = new SqlConnection(connString))
        {
            string q = "SELECT Fee, GSTPercentage, ISNULL(Allow65PlusDiscount, 0), ISNULL(Allow30YearsDiscount, 0), ISNULL(Allow80PlusFree, 0), ISNULL(AllowChildHalfCharge, 0) FROM Subscriptions WHERE SubscriptionID = @SubID";
            using (SqlCommand cmd = new SqlCommand(q, con))
            {
                cmd.Parameters.AddWithValue("@SubID", selectedSubId);
                con.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        baseFee = dr.GetDecimal(0);
                        gstPercent = dr.IsDBNull(1) ? 0 : dr.GetDecimal(1);
                        allow65 = dr.GetBoolean(2);
                        allow30 = dr.GetBoolean(3);
                        allow80 = dr.GetBoolean(4);
                        allowChild = dr.GetBoolean(5);
                    }
                }
            }
        }

        int age = Convert.ToInt32(row["MemberAge"]);
        int tenure = Convert.ToInt32(row["MemberTenure"]);
        string relation = row["DependentRelation"].ToString();

        decimal policyDiscount = 0;
        List<object> rules = new List<object>();

        bool applied80 = false;
        if (allow80 && age >= 80)
        {
            policyDiscount = baseFee;
            applied80 = true;
        }
        rules.Add(new { RuleName = "80+ Years Free", IsApplied = applied80 });

        bool applied30 = false;
        if (!applied80 && allow30 && tenure >= 30)
        {
            policyDiscount = baseFee;
            applied30 = true;
        }
        rules.Add(new { RuleName = "30 Years Membership Discount", IsApplied = applied30 });

        bool applied65 = false;
        if (!applied80 && !applied30 && allow65 && age >= 65)
        {
            policyDiscount = baseFee * 0.5m;
            applied65 = true;
        }
        rules.Add(new { RuleName = "65+ Years Discount (50% Off)", IsApplied = applied65 });

        bool appliedChild = false;
        if (!applied80 && !applied30 && !applied65 && allowChild && (relation == "Son" || relation == "Daughter" || relation == "Child"))
        {
            policyDiscount = baseFee * 0.5m;
            appliedChild = true;
        }
        rules.Add(new { RuleName = "Child Half Charge", IsApplied = appliedChild });

        rptModalRules.DataSource = rules;
        rptModalRules.DataBind();

        decimal feeAfterDiscount = baseFee - policyDiscount;
        if (feeAfterDiscount < 0) feeAfterDiscount = 0;

        decimal gstAmount = feeAfterDiscount * (gstPercent / 100m);
        decimal netFee = feeAfterDiscount + gstAmount;

        litModalBaseFee.Text = "PKR " + baseFee.ToString("N2");
        litModalDiscount.Text = "PKR " + policyDiscount.ToString("N2");
        litModalGSTPercent.Text = gstPercent.ToString("0.00");
        litModalGSTAmount.Text = "PKR " + gstAmount.ToString("N2");
        litModalNetFee.Text = "PKR " + netFee.ToString("N2");

        hfModalCalculatedNetFee.Value = netFee.ToString();
    }

    protected void btnModalConfirmCharge_Click(object sender, EventArgs e)
    {
        if (ddlModalChargePackage.SelectedValue == "0" || string.IsNullOrEmpty(ddlModalChargePackage.SelectedValue))
        {
            ShowModalMessage("Please select a package first.", false);
            pnlPaymentProcessModal.Style["display"] = "flex";
            return;
        }

        try
        {
            int selectedSubId = Convert.ToInt32(ddlModalChargePackage.SelectedValue);
            int memberSubId = Convert.ToInt32(hfModalChargeMemberSubID.Value);

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                string updateSub = "UPDATE MemberSubscriptions SET SubscriptionID = @SubID WHERE MemberSubID = @MemberSubID";
                using (SqlCommand upCmd = new SqlCommand(updateSub, con))
                {
                    upCmd.Parameters.AddWithValue("@SubID", selectedSubId);
                    upCmd.Parameters.AddWithValue("@MemberSubID", memberSubId);
                    upCmd.ExecuteNonQuery();
                }

                using (SqlCommand cmd = new SqlCommand("sp_ChargeSubscriptionToLedger", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@MemberID", hfModalMemberID.Value);
                    cmd.Parameters.AddWithValue("@MemberSubID", hfModalChargeMemberSubID.Value);
                    cmd.Parameters.AddWithValue("@ChargeAmount", Convert.ToDecimal(hfModalCalculatedNetFee.Value));
                    cmd.Parameters.AddWithValue("@BillingPeriod", txtModalBillingPeriod.Text.Trim());
                    cmd.ExecuteNonQuery();
                }
            }

            LoadModalLedgerBalance(hfModalMemberID.Value);
            LoadModalActiveSubscriptions(hfModalMemberID.Value);
            pnlModalConfirmCharge.Visible = false;
            ShowModalMessage("Subscription charged successfully to ledger.", true);
        }
        catch (Exception ex)
        {
            ShowModalMessage("Error charging subscription: " + ex.Message, false);
            pnlModalConfirmCharge.Visible = false;
        }

        pnlPaymentProcessModal.Style["display"] = "flex";
    }
}
