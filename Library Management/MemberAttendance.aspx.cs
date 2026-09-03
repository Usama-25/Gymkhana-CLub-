using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GymkhanaLibrary
{
    public partial class MemberAttendance : System.Web.UI.Page
    {
        #region Page Lifecycle Events

        protected void Page_Load(object sender, EventArgs e)
        {
            // Dev/Test auto-login helper to ensure a logged-in user exists
            if (Session["Emp_ID"] == null) Session["Emp_ID"] = 1;
            if (Session["UserName"] == null) Session["UserName"] = "Admin";
            if (Session["StaffID"] == null) Session["StaffID"] = (short)1;
            if (Session["StaffName"] == null) Session["StaffName"] = "System Administrator";

            if (!IsPostBack)
            {
                LoadDashboard();
                LoadCurrentVisitors();
                LoadTodayAttendance();
            }
        }

        #endregion

        #region Database Connections & Helpers

        private static string GetConnectionString()
        {
            return ConfigurationManager.ConnectionStrings["GymkhanaLibraryDB"] != null
                ? ConfigurationManager.ConnectionStrings["GymkhanaLibraryDB"].ConnectionString
                : "Data Source=.\\LOCALHOST;Initial Catalog=GymkhanaLibraryDB;Integrated Security=True;TrustServerCertificate=True;";
        }

        private DataTable ExecuteStoredProcedure(string spName, params SqlParameter[] parameters)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    using (SqlCommand cmd = new SqlCommand(spName, conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        if (parameters != null)
                        {
                            cmd.Parameters.AddRange(parameters);
                        }
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            conn.Open();
                            da.Fill(dt);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Database error executing " + spName + ": " + ex.Message, false);
            }
            return dt;
        }

        private void ExecuteNonQueryProcedure(string spName, params SqlParameter[] parameters)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    using (SqlCommand cmd = new SqlCommand(spName, conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        if (parameters != null)
                        {
                            cmd.Parameters.AddRange(parameters);
                        }
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (SqlException ex)
            {
                // Bubble SQL Stored Procedure error message up to the UI
                throw new Exception(ex.Message);
            }
        }

        private void ShowAlert(string message, bool isSuccess)
        {
            pnlAlertMessage.Visible = true;
            lblAlertText.Text = message;
            if (isSuccess)
            {
                pnlAlertMessage.Style["background-color"] = "#d1fae5";
                pnlAlertMessage.Style["border-color"] = "#a7f3d0";
                pnlAlertMessage.Style["color"] = "#065f46";
            }
            else
            {
                pnlAlertMessage.Style["background-color"] = "#fef2f2";
                pnlAlertMessage.Style["border-color"] = "#fecaca";
                pnlAlertMessage.Style["color"] = "#b91c1c";
            }
        }

        #endregion

        #region Dashboard & Data Binding

        private void LoadDashboard()
        {
            DataTable dt = ExecuteStoredProcedure("sp_GetAttendanceDashboard");
            if (dt != null && dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                lblTodayVisitors.Text = r["TodayVisitors"].ToString();
                lblCurrentInside.Text = r["CurrentInside"].ToString();
                lblTotalCheckIns.Text = r["TotalCheckIns"].ToString();
                lblTotalCheckOuts.Text = r["TotalCheckOuts"].ToString();
                lblAvgStayTime.Text = r["AvgStayTime"].ToString();
                lblMonthlyVisitors.Text = r["MonthlyVisitors"].ToString();
            }
        }

        private void LoadCurrentVisitors()
        {
            DataTable dt = ExecuteStoredProcedure("sp_GetCurrentVisitors");
            gvCurrentVisitors.DataSource = dt;
            gvCurrentVisitors.DataBind();
        }

        private void LoadTodayAttendance()
        {
            DataTable dt = ExecuteStoredProcedure("sp_GetTodayAttendance");
            gvTodayAttendance.DataSource = dt;
            gvTodayAttendance.DataBind();
        }


        protected void gvCurrentVisitors_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.Header)
            {
                for (int i = 0; i < e.Row.Cells.Count; i++)
                {
                    e.Row.Cells[i].Attributes.Add("style", "background-color: #f1f5f9; color: #475569; font-weight: 600; padding: 12px; border-bottom: 2px solid #e2e8f0; text-align: left; vertical-align: middle;");
                }
            }
            else if (e.Row.RowType == DataControlRowType.DataRow)
            {
                for (int i = 0; i < e.Row.Cells.Count; i++)
                {
                    string style = "padding: 12px; border-bottom: 1px solid #e2e8f0; vertical-align: middle;";
                    if (i == 0) style += " font-weight: 600; color: #1e3a8a;";
                    else if (i == 1) style += " font-weight: 600; color: #334155;";
                    else if (i == 4) style += " font-weight: 600; color: #f59e0b;";
                    else if (i == 6) style += " text-align: center;";
                    e.Row.Cells[i].Attributes.Add("style", style);
                }
            }
        }

        protected void gvTodayAttendance_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.Header)
            {
                for (int i = 0; i < e.Row.Cells.Count; i++)
                {
                    e.Row.Cells[i].Attributes.Add("style", "background-color: #f1f5f9; color: #475569; font-weight: 600; padding: 12px; border-bottom: 2px solid #e2e8f0; text-align: left; vertical-align: middle;");
                }
            }
            else if (e.Row.RowType == DataControlRowType.DataRow)
            {
                for (int i = 0; i < e.Row.Cells.Count; i++)
                {
                    string style = "padding: 12px; border-bottom: 1px solid #e2e8f0; vertical-align: middle;";
                    if (i == 0) style += " color: #64748b;";
                    else if (i == 2) style += " font-weight: 600; color: #1e3a8a;";
                    else if (i == 3) style += " font-weight: 600; color: #334155;";
                    else if (i == 5) style += " color: #10b981; font-weight: 600;";
                    else if (i == 6) style += " color: #ef4444; font-weight: 600;";
                    else if (i == 7) style += " color: #f59e0b; font-weight: 600;";
                    e.Row.Cells[i].Attributes.Add("style", style);
                }
            }
        }

        protected void gvAttendanceHistory_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.Header)
            {
                for (int i = 0; i < e.Row.Cells.Count; i++)
                {
                    e.Row.Cells[i].Attributes.Add("style", "background-color: #f1f5f9; color: #475569; font-weight: 600; padding: 12px; border-bottom: 2px solid #e2e8f0; text-align: left; vertical-align: middle;");
                }
            }
            else if (e.Row.RowType == DataControlRowType.DataRow)
            {
                for (int i = 0; i < e.Row.Cells.Count; i++)
                {
                    string style = "padding: 12px; border-bottom: 1px solid #e2e8f0; vertical-align: middle;";
                    if (i == 0) style += " color: #64748b;";
                    else if (i == 2) style += " font-weight: 600; color: #1e3a8a;";
                    else if (i == 4) style += " color: #10b981; font-weight: 600;";
                    else if (i == 5) style += " color: #ef4444; font-weight: 600;";
                    else if (i == 6) style += " color: #f59e0b; font-weight: 600;";
                    e.Row.Cells[i].Attributes.Add("style", style);
                }
            }
        }

        #endregion

        #region Search Member & Profile Panel

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            pnlAlertMessage.Visible = false;
            string searchVal = txtSearch.Text.Trim();

            if (string.IsNullOrEmpty(searchVal))
            {
                ShowAlert("Please enter a membership number, name, RFID, CNIC, or mobile number to search.", false);
                return;
            }

            SearchMember(searchVal);
        }

        private void SearchMember(string searchVal)
        {
            string criteria = ddlSearchBy.SelectedValue;
            string query = @"
                SELECT TOP 1
                    mp.MemberID, 
                    sub.MembershipNo AS MemberNo, 
                    sub.FullName AS MemberName, 
                    sub.HolderType,
                    sub.HolderID,
                    COALESCE(sub.Phone, mp.Mobile) AS Mobile, 
                    mp.ResidentialEmail, 
                    mb.MemberShipCategory AS MemberType,
                    rc.ExpiryDate AS ExpiryDate, 
                    1 AS LibraryIsActive,
                    CASE WHEN (rc.CardStatus IS NULL OR UPPER(rc.CardStatus) = 'ACTIVE') AND mp.IsActive = '1' THEN 1 ELSE 0 END AS ProfileIsActive,
                    rc.CardNo AS RFID,
                    mp.PhotoPath AS PhotoFile,
                    rc.CardStatus,
                    rc.Remarks AS CardRemarks,
                    mp.AccountStatus,
                    mp.Status AS MemberStatus
                FROM (
                    SELECT 
                        MemberID,
                        MemberNo AS MembershipNo,
                        MemberName AS FullName,
                        'Primary' AS HolderType,
                        MemberID AS HolderID,
                        NIC AS CNIC,
                        Mobile AS Phone
                    FROM MemberShip.dbo.MemberProfile
                    
                    UNION ALL
                    
                    SELECT 
                        MemberID,
                        MembershipNo,
                        SpouseName AS FullName,
                        'Spouse' AS HolderType,
                        SpouseID AS HolderID,
                        SpouseCNIC AS CNIC,
                        SpousePhone AS Phone
                    FROM MemberShip.dbo.MemberSpouses
                    WHERE UPPER(RecordStatus) = 'ACTIVE'
                    
                    UNION ALL
                    
                    SELECT 
                        MemberID,
                        MembershipNo,
                        ChildName AS FullName,
                        'Child' AS HolderType,
                        ChildID AS HolderID,
                        NULL AS CNIC,
                        NULL AS Phone
                    FROM MemberShip.dbo.MemberChildren
                    WHERE UPPER(RecordStatus) = 'ACTIVE'
                ) AS sub
                INNER JOIN MemberShip.dbo.MemberProfile mp ON sub.MemberID = mp.MemberID
                INNER JOIN MemberShip.dbo.Member mb ON mp.MemberID = mb.MemberID
                LEFT JOIN MemberShip.dbo.RFIDCards rc ON rc.MemberNo COLLATE DATABASE_DEFAULT = sub.MembershipNo COLLATE DATABASE_DEFAULT
                WHERE ";

            switch (criteria)
            {
                case "MembershipNo":
                    query += "(sub.MembershipNo = @SearchVal OR rc.CardNo = @SearchVal)";
                    break;
                case "RFID":
                    query += "rc.CardNo = @SearchVal";
                    break;
                default:
                    query += "(sub.MembershipNo = @SearchVal OR rc.CardNo = @SearchVal)";
                    break;
            }

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@SearchVal", searchVal);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        conn.Open();
                        da.Fill(dt);
                    }
                }
            }

            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                int memberID = Convert.ToInt32(r["MemberID"]);
                hfMemberID.Value = memberID.ToString();
                LoadMemberInformation(r);
            }
            else
            {
                pnlMemberDetails.Visible = false;
                pnlNoMemberSelected.Visible = true;
                ShowAlert("No active member found matching the search criteria.", false);
            }
        }

        private bool SafeParseBool(object obj)
        {
            if (obj == null || obj == DBNull.Value)
                return false;

            string val = obj.ToString().Trim().ToLower();
            if (val == "true" || val == "1" || val == "active" || val == "yes" || val == "y")
                return true;

            return false;
        }

        private void LoadMemberInformation(DataRow r)
        {
            int memberID = Convert.ToInt32(r["MemberID"]);
            pnlNoMemberSelected.Visible = false;
            pnlMemberDetails.Visible = true;

            // Basic Info Labels
            lblMemberIdVal.Text = memberID.ToString();
            lblMemberNoVal.Text = r["MemberNo"].ToString();
            lblMemberNameVal.Text = r["MemberName"].ToString();
            
            // Format membership type to indicate relationship if spouse or child
            string holderType = r["HolderType"].ToString();
            string memberType = r["MemberType"].ToString();
            if (holderType != "Primary")
            {
                memberType += " (" + holderType + ")";
            }
            lblMemberTypeVal.Text = memberType;
            
            lblPhoneVal.Text = r["Mobile"] == DBNull.Value || string.IsNullOrEmpty(r["Mobile"].ToString()) ? "-" : r["Mobile"].ToString();
            lblEmailVal.Text = r["ResidentialEmail"] == DBNull.Value || string.IsNullOrEmpty(r["ResidentialEmail"].ToString()) ? "-" : r["ResidentialEmail"].ToString();

            // Handle Expiry Date (validating card expiry from RFID table)
            DateTime? expiryDate = null;
            if (r["ExpiryDate"] != DBNull.Value)
            {
                expiryDate = Convert.ToDateTime(r["ExpiryDate"]);
                lblExpiryVal.Text = expiryDate.Value.ToString("dd-MMM-yyyy");
            }
            else
            {
                lblExpiryVal.Text = "No RFID Card Expiry Registered";
            }

            // Sync/Verify status indicators
            bool isLibraryActive = SafeParseBool(r["LibraryIsActive"]);
            bool isProfileActive = SafeParseBool(r["ProfileIsActive"]);
            bool isActive = isLibraryActive && isProfileActive;

            bool isExpired = expiryDate.HasValue && expiryDate.Value < DateTime.Today;

            // Query fine and issued books counts
            double outstandingFine = GetOutstandingFine(memberID);
            int booksIssued = GetIssuedBooksCount(memberID, r["MemberNo"].ToString());

            lblFineVal.Text = outstandingFine.ToString("F2");
            lblBooksVal.Text = booksIssued.ToString();

            // === CARD STATUS CHECK ===
            string cardStatus = r["CardStatus"] != DBNull.Value ? r["CardStatus"].ToString().Trim() : "";
            string cardRemarks = r["CardRemarks"] != DBNull.Value ? r["CardRemarks"].ToString().Trim() : "";
            bool isCardActive = string.IsNullOrEmpty(cardStatus) || cardStatus.ToUpper() == "ACTIVE";
            bool isCardBlocked = !string.IsNullOrEmpty(cardStatus) && cardStatus.ToUpper() != "ACTIVE";
            bool isCardExpired = expiryDate.HasValue && expiryDate.Value < DateTime.Today;

            // Path 1: RFID Card is valid and active (not blocked, not expired)
            bool cardPathValid = isCardActive && !isCardExpired;

            // === ACCOUNT / MEMBER STATUS CHECK ===
            string accountStatus = r["AccountStatus"] != DBNull.Value ? r["AccountStatus"].ToString().Trim() : "";
            string memberStatus = r["MemberStatus"] != DBNull.Value ? r["MemberStatus"].ToString().Trim() : "";
            
            bool isAccountActive = !string.IsNullOrEmpty(accountStatus) && accountStatus.ToUpper() == "ACTIVE";
            bool isMemberStatusActive = !string.IsNullOrEmpty(memberStatus) && memberStatus.ToUpper() == "ACTIVE";
            bool isProfileOk = isAccountActive && isMemberStatusActive;

            // Path 2: AccountStatus and Status are both Active
            bool profilePathValid = isProfileOk;
            bool isAccountIssue = !profilePathValid;

            // === ACCESS DECISION (OR logic) ===
            // If EITHER path succeeds => allow check-in
            bool canCheckIn = cardPathValid || profilePathValid;

            // === UPDATE ALERTS AND MESSAGES ===
            
            // 1. Card Status Alert
            pnlCardStatusAlert.Visible = isCardBlocked;
            if (isCardBlocked)
            {
                string cardMsg = "RFID Card is " + cardStatus.ToUpper() + ".";
                if (!string.IsNullOrEmpty(cardRemarks))
                {
                    cardMsg += " (Remarks: " + cardRemarks + ")";
                }
                cardMsg += canCheckIn ? " (Access allowed via Active Profile Status)" : " Access Denied.";
                lblCardStatusAlertText.Text = cardMsg;
            }

            // 2. Account / Member Status Alert
            pnlAccountStatusAlert.Visible = isAccountIssue;
            if (isAccountIssue)
            {
                string accountMsg = "";
                if (!isAccountActive)
                {
                    string displayStatus = string.IsNullOrEmpty(accountStatus) ? "NOT SET" : accountStatus.ToUpper();
                    accountMsg = "Account Status is " + displayStatus + ".";
                }
                if (!isMemberStatusActive)
                {
                    string displayStatus = string.IsNullOrEmpty(memberStatus) ? "NOT SET" : memberStatus.ToUpper();
                    if (!string.IsNullOrEmpty(accountMsg))
                        accountMsg += " | ";
                    accountMsg += "Member Status is " + displayStatus + ".";
                }
                accountMsg += canCheckIn ? " (Access allowed via Active RFID Card)" : " Access Denied.";
                lblAccountStatusAlertText.Text = accountMsg;
            }

            // 3. Expired Alert
            pnlExpiredAlert.Visible = isCardExpired;
            if (isCardExpired)
            {
                string expiredMsg = "RFID Card Expired on " + expiryDate.Value.ToString("dd-MMM-yyyy") + ".";
                expiredMsg += canCheckIn ? " (Access allowed via Active Profile Status)" : " Access Denied.";
                lblExpiredAlertText.Text = expiredMsg;
            }

            // 4. Inactive Alert (IsActive = 0 but not already covered by account/card alerts)
            pnlInactiveAlert.Visible = !isActive && !isAccountIssue && !isCardBlocked;

            // 5. Fine Alert
            pnlFineAlert.Visible = outstandingFine > 0;

            // Set detailed expiry formatting
            if (isCardExpired)
            {
                lblExpiryVal.Style["color"] = "#ef4444";
                lblExpiryVal.Style["font-weight"] = "bold";
            }
            else
            {
                lblExpiryVal.Style["color"] = "#10b981";
                lblExpiryVal.Style["font-weight"] = "600";
            }

            // Check Attendance Status
            string currentStatus = GetMemberAttendanceStatus(r["MemberNo"].ToString());
            
            if (currentStatus == "Inside")
            {
                lblStatusVal.Text = "Currently INSIDE the Library";
                lblStatusVal.Style["color"] = "#10b981";
                
                btnCheckIn.Enabled = false;
                btnCheckIn.Style["background-color"] = "#94a3b8"; // disabled gray
                btnCheckIn.Style["cursor"] = "default";
                btnCheckIn.Style["box-shadow"] = "none";
                
                btnCheckOut.Enabled = true;
                btnCheckOut.Style["background-color"] = "#ef4444";
                btnCheckOut.Style["cursor"] = "pointer";
            }
            else
            {
                lblStatusVal.Text = "Checked Out / Not Checked In";
                lblStatusVal.Style["color"] = "#64748b";

                // Check-in allowed only if active, not expired, card not blocked, account not suspended
                if (canCheckIn)
                {
                    btnCheckIn.Enabled = true;
                    btnCheckIn.Style["background-color"] = "#10b981";
                    btnCheckIn.Style["cursor"] = "pointer";
                }
                else
                {
                    btnCheckIn.Enabled = false;
                    btnCheckIn.Style["background-color"] = "#94a3b8"; // disabled gray
                    btnCheckIn.Style["cursor"] = "default";
                    btnCheckIn.Style["box-shadow"] = "none";
                }

                btnCheckOut.Enabled = false;
                btnCheckOut.Style["background-color"] = "#94a3b8"; // disabled gray
                btnCheckOut.Style["cursor"] = "default";
                btnCheckOut.Style["box-shadow"] = "none";
            }
        }

        private double GetOutstandingFine(int memberID)
        {
            double fine = 0;
            string query = "SELECT ISNULL(SUM(FineAmount), 0) FROM dbo.Fines WHERE MemberID = @MemberID AND IsPaid = 0";
            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@MemberID", memberID);
                    conn.Open();
                    fine = Convert.ToDouble(cmd.ExecuteScalar());
                }
            }
            return fine;
        }

        private int GetIssuedBooksCount(int memberID, string memberNo)
        {
            int count = 0;
            string query = @"
                SELECT COUNT(*) 
                FROM dbo.Loans 
                WHERE MemberID = @MemberID 
                  AND StatusID IN (1,3,4) 
                  AND (ActualBorrowerNo COLLATE DATABASE_DEFAULT = @MemberNo COLLATE DATABASE_DEFAULT 
                       OR (ActualBorrowerNo IS NULL AND @MemberNo COLLATE DATABASE_DEFAULT = (SELECT MemberNo COLLATE DATABASE_DEFAULT FROM MemberShip.dbo.MemberProfile WHERE MemberID = @MemberID)))";
            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@MemberID", memberID);
                    cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                    conn.Open();
                    count = Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            return count;
        }

        private string GetMemberAttendanceStatus(string memberNo)
        {
            string status = "Checked Out";
            string query = "SELECT TOP 1 Status FROM dbo.MemberAttendance WHERE MemberNo = @MemberNo AND Status = 'Inside' AND CheckOutTime IS NULL ORDER BY CheckInTime DESC";
            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                    conn.Open();
                    object res = cmd.ExecuteScalar();
                    if (res != null) status = res.ToString();
                }
            }
            return status;
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            txtRemarks.Text = "";
            pnlMemberDetails.Visible = false;
            pnlNoMemberSelected.Visible = true;
            pnlAlertMessage.Visible = false;
            hfMemberID.Value = "";
        }

        #endregion

        #region Attendance Check In / Out Actions

        protected void btnCheckIn_Click(object sender, EventArgs e)
        {
            pnlAlertMessage.Visible = false;
            if (string.IsNullOrEmpty(hfMemberID.Value)) return;

            int memberID = Convert.ToInt32(hfMemberID.Value);
            string memberNo = lblMemberNoVal.Text.Trim();
            int staffID = Convert.ToInt32(Session["StaffID"]);
            string remarks = txtRemarks.Text.Trim();

            try
            {
                SqlParameter[] prms = {
                    new SqlParameter("@MemberID", memberID),
                    new SqlParameter("@MemberNo", memberNo),
                    new SqlParameter("@CreatedBy", staffID),
                    new SqlParameter("@Remarks", string.IsNullOrEmpty(remarks) ? DBNull.Value : (object)remarks)
                };

                ExecuteNonQueryProcedure("sp_CheckInMember", prms);

                ShowAlert("Check-in successful! Welcome " + lblMemberNameVal.Text + ".", true);

                // Clear/Reset panel
                txtRemarks.Text = "";
                
                // Reload dashboard, lists and search details
                LoadDashboard();
                LoadCurrentVisitors();
                LoadTodayAttendance();
                
                // Re-evaluate member info
                SearchMember(memberNo);
            }
            catch (Exception ex)
            {
                ShowAlert(ex.Message, false);
            }
        }

        protected void btnCheckOut_Click(object sender, EventArgs e)
        {
            pnlAlertMessage.Visible = false;
            if (string.IsNullOrEmpty(hfMemberID.Value)) return;

            string memberNo = lblMemberNoVal.Text.Trim();
            int staffID = Convert.ToInt32(Session["StaffID"]);

            try
            {
                SqlParameter[] prms = {
                    new SqlParameter("@MemberNo", memberNo),
                    new SqlParameter("@CreatedBy", staffID)
                };

                ExecuteNonQueryProcedure("sp_CheckOutMember", prms);

                ShowAlert("Check-out successful! Goodbye " + lblMemberNameVal.Text + ".", true);

                // Reload dashboard, lists and search details
                LoadDashboard();
                LoadCurrentVisitors();
                LoadTodayAttendance();

                // Re-evaluate member info
                SearchMember(memberNo);
            }
            catch (Exception ex)
            {
                ShowAlert(ex.Message, false);
            }
        }

        protected void gvCurrentVisitors_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            pnlAlertMessage.Visible = false;
            if (e.CommandName == "CheckOutRow")
            {
                string memberNo = e.CommandArgument.ToString();
                int staffID = Convert.ToInt32(Session["StaffID"]);

                try
                {
                    SqlParameter[] prms = {
                        new SqlParameter("@MemberNo", memberNo),
                        new SqlParameter("@CreatedBy", staffID)
                    };

                    ExecuteNonQueryProcedure("sp_CheckOutMember", prms);

                    ShowAlert("Checked out successfully.", true);

                    LoadDashboard();
                    LoadCurrentVisitors();
                    LoadTodayAttendance();

                    // If same member is selected in profile panel, refresh their buttons
                    if (lblMemberNoVal.Text == memberNo)
                    {
                        SearchMember(memberNo);
                    }
                }
                catch (Exception ex)
                {
                    ShowAlert(ex.Message, false);
                }
            }
        }

        #endregion

        #region Navigation Event Handlers

        protected void btnGoToHistory_Click(object sender, EventArgs e)
        {
            Response.Redirect("AttendanceHistory.aspx");
        }

        #endregion
    }
}
