using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
// using Microsoft.Reporting.WebForms;
using System.Collections.Generic;

namespace InterviewList
{
    public partial class Interviewlist1 : System.Web.UI.Page
    {
        private string connStr
        {
            get
            {
                var s = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
                return s != null ? s.ConnectionString : "";
            }
        }

        protected override PageStatePersister PageStatePersister
        {
            get
            {
                return new SessionPageStatePersister(this);
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindMembershipDropdown();
                // BindInterviewersGrid(); // Interview Configuration hidden
            }
        }
        protected void btnSave1_Click(object sender, EventArgs e)
        {
            /* Section 1 is hidden. Functionality removed/commented out.
            string interviewer = txtInterviewBy.Text.Trim();
            string remarks = string.IsNullOrEmpty(TextBox1.Text.Trim()) ? null : TextBox1.Text.Trim();
            DateTime interviewDate;

            if (!DateTime.TryParse(txtInterviewDate.Text, out interviewDate))
            {
                interviewDate = DateTime.Today;
            }

            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("sp_InsertInterviewer", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Iby", interviewer);
                    cmd.Parameters.AddWithValue("@Remarks", (object)remarks ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Idate", interviewDate);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            txtInterviewBy.Text = "";
            txtRemarks.Text = "";
            txtInterviewDate.Text = DateTime.Today.ToString("yyyy-MM-dd");

            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Data saved successfully!');", true);
            BindInterviewersGrid();
            */
        }





        protected void gvInterviewers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            /* Section 1 is hidden. Functionality removed.
            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "View")
            {

                Response.Redirect("ViewInterviewer.aspx?Iid=" + id);
            }
            else if (e.CommandName == "Add")
            {
                int interviewerId = Convert.ToInt32(e.CommandArgument);

                int interviewId = Convert.ToInt32(e.CommandArgument);

                hfInterviewId.Value = interviewId.ToString();



                LoadInterviewRecord(interviewId);


                divFilter.Visible = false;
                divNewInterview.Visible = true;

                //ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Interviewer updated for Applicant successfully!');", true);
            }
            */
        }

        private void LoadInterviewRecord(int iid)
        {
            /* Section 1 is hidden. Functionality removed.
            string query = "SELECT Iid, Iby, Idate, Remarks FROM interviewer WHERE Iid = @Iid";

            using (SqlConnection con = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@Iid", iid);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {

                    lblIid.Text = dr["Iid"].ToString();
                    lblName.Text = dr["Iby"].ToString();
                    lblDate.Text = Convert.ToDateTime(dr["Idate"]).ToString("yyyy-MM-dd");
                }
            }
            */
        }

        private string GetEmployeeEFName()
        {
            if (Session["EFName"] != null && !string.IsNullOrEmpty(Session["EFName"].ToString()))
            {
                return Session["EFName"].ToString();
            }

            object empIdObj = Session["Emp_ID"] ?? Session["Emp_Id"];
            if (empIdObj != null && !string.IsNullOrEmpty(empIdObj.ToString()))
            {
                int empId;
                if (int.TryParse(empIdObj.ToString(), out empId))
                {
                    using (SqlConnection con = new SqlConnection(connStr))
                    {
                        string query = "SELECT EFName FROM Employee WHERE EmpID = @EmpID";
                        using (SqlCommand cmd = new SqlCommand(query, con))
                        {
                            cmd.Parameters.AddWithValue("@EmpID", empId);
                            con.Open();
                            object res = cmd.ExecuteScalar();
                            if (res != null && res != DBNull.Value)
                            {
                                return res.ToString();
                            }
                        }
                    }
                }
            }

            return "System";
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            try
            {
                int interviewId = 0;
                string interviewerName = GetEmployeeEFName();

                if (!string.IsNullOrEmpty(hfInterviewId.Value))
                {
                    interviewId = Convert.ToInt32(hfInterviewId.Value);
                }
                else
                {
                    using (SqlConnection con = new SqlConnection(connStr))
                    {
                        con.Open();
                        string checkQuery = "SELECT TOP 1 Iid FROM Interviewer WHERE Status = 0 AND Iby = @Iby ORDER BY Iid DESC";
                        using (SqlCommand cmd = new SqlCommand(checkQuery, con))
                        {
                            cmd.Parameters.AddWithValue("@Iby", interviewerName);
                            object res = cmd.ExecuteScalar();
                            if (res != null && res != DBNull.Value)
                            {
                                interviewId = Convert.ToInt32(res);
                            }
                        }
                        if (interviewId == 0)
                        {
                            string insertQuery = "INSERT INTO Interviewer (Iby, Idate, Remarks, Status) OUTPUT INSERTED.Iid VALUES (@Iby, GETDATE(), 'Auto-Generated Session', 0)";
                            using (SqlCommand cmd = new SqlCommand(insertQuery, con))
                            {
                                cmd.Parameters.AddWithValue("@Iby", interviewerName);
                                interviewId = (int)cmd.ExecuteScalar();
                            }
                        }
                    }
                    hfInterviewId.Value = interviewId.ToString();
                }

                DataTable dtGrid2 = Session["Generate_Grid2"] as DataTable;

                if (dtGrid2 == null || dtGrid2.Rows.Count == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Grid2 has no data!');", true);
                    return;
                }

                // Quick validation of the list before database transaction
                HashSet<string> seenFathers = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                HashSet<string> seenMainMembers = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                List<string> validationErrors = new List<string>();

                foreach (DataRow dr in dtGrid2.Rows)
                {
                    string name = dr["ApplicantName"].ToString();
                    string father = dr["FatherName"].ToString().Trim();
                    string mainNo = dr["MainMemberNo"].ToString().Trim();
                    string nic = dr["NIC"].ToString().Trim();
                    string marital = dr["MaritalStatus"].ToString().Trim();

                    // Check same father/main member duplicate check in the list itself
                    if (!string.IsNullOrEmpty(father))
                    {
                        if (seenFathers.Contains(father))
                        {
                            validationErrors.Add(name + " shares the same father (" + father + ") as another candidate in this list.");
                        }
                        else
                        {
                            seenFathers.Add(father);
                        }
                    }
                    if (!string.IsNullOrEmpty(mainNo))
                    {
                        if (seenMainMembers.Contains(mainNo))
                        {
                            validationErrors.Add(name + " shares the same Main Member No (" + mainNo + ") as another candidate in this list.");
                        }
                        else
                        {
                            seenMainMembers.Add(mainNo);
                        }
                    }

                    // Check age check if child
                    bool isChild = IsChildApplicant(name, father, nic, mainNo);
                    bool isMarried = marital.Equals("Married", StringComparison.OrdinalIgnoreCase);

                    if (isChild && !isMarried)
                    {
                        using (SqlConnection con = new SqlConnection(connStr))
                        {
                            con.Open();
                            string dobQuery = "SELECT DOB FROM ApplicationFForm WHERE NIC = @NIC";
                            using (SqlCommand cmd = new SqlCommand(dobQuery, con))
                            {
                                cmd.Parameters.AddWithValue("@NIC", nic);
                                object dobVal = cmd.ExecuteScalar();
                                if (dobVal == null || dobVal == DBNull.Value)
                                {
                                    validationErrors.Add(name + " is a single child but Date of Birth is missing.");
                                }
                                else
                                {
                                    DateTime dob = Convert.ToDateTime(dobVal);
                                    int age = CalculateIntAge(dob);
                                    if (age <= 35)
                                    {
                                        validationErrors.Add(name + " is a single child and must be older than 35. Current age is " + age + ".");
                                    }
                                }
                            }
                        }
                    }
                }

                if (validationErrors.Count > 0)
                {
                    string errorMsg = "Cannot save changes due to business rule violations:\\n- " + string.Join("\\n- ", validationErrors);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + errorMsg.Replace("'", "\\'") + "');", true);
                    return;
                }

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();
                    int insertedCount = 0;
                    int duplicateCount = 0;

                    foreach (DataRow dr in dtGrid2.Rows)
                    {
                        string nic = dr["NIC"].ToString().Trim();


                        string checkQuery = "SELECT COUNT(*) FROM MainInterview WHERE NIC = @NIC";
                        using (SqlCommand checkCmd = new SqlCommand(checkQuery, con))
                        {
                            checkCmd.Parameters.AddWithValue("@NIC", nic);
                            int count = (int)checkCmd.ExecuteScalar();

                            if (count > 0)
                            {

                                duplicateCount++;
                                continue;
                            }
                        }


                        string insertQuery = @"
                    INSERT INTO MainInterview 
                    (IName, FatherName, NIC, Membership, Email, MFee, InterviewId, Dated, Status)
                    VALUES 
                    (@IName, @FatherName, @NIC, @Membership, @Email, @MFee, @InterviewId, GETDATE(), 'Shortlisted')
                ";

                        using (SqlCommand cmd = new SqlCommand(insertQuery, con))
                        {
                            cmd.Parameters.AddWithValue("@IName", dr["ApplicantName"].ToString());
                            cmd.Parameters.AddWithValue("@FatherName", dr["FatherName"].ToString());
                            cmd.Parameters.AddWithValue("@NIC", nic);
                            cmd.Parameters.AddWithValue("@Membership", dr["Membership"].ToString()); // Fixed: Now using Membership
                            cmd.Parameters.AddWithValue("@Email", dr["Email"].ToString());
                            cmd.Parameters.AddWithValue("@MFee", dr["MFee"]);
                            cmd.Parameters.AddWithValue("@InterviewId", interviewId);
                            cmd.ExecuteNonQuery();

                            // Also mark the applicant as processed in ApplicationFForm
                            string updateAppStatus = "UPDATE ApplicationFForm SET Status = 'Shortlisted' WHERE NIC = @NIC";
                            using (SqlCommand updateCmd = new SqlCommand(updateAppStatus, con))
                            {
                                updateCmd.Parameters.AddWithValue("@NIC", nic);
                                updateCmd.ExecuteNonQuery();
                            }

                            insertedCount++;
                        }
                    }


                    string updateStatusQuery = "UPDATE Interviewer SET Status = 1 WHERE Iid = @InterviewId";
                    using (SqlCommand statusCmd = new SqlCommand(updateStatusQuery, con))
                    {
                        statusCmd.Parameters.AddWithValue("@InterviewId", interviewId);
                        statusCmd.ExecuteNonQuery();
                    }


                    if (insertedCount > 0 && duplicateCount == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Interview records saved successfully!');", true);

                        // Clear the specific grid after successful save
                        Session["Generate_Grid2"] = null;
                        GridView2.DataSource = null;
                        GridView2.DataBind();
                    }
                    else if (insertedCount > 0 && duplicateCount > 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Some records saved successfully. " + duplicateCount + " NIC(s) already exist.');", true);

                        Session["Generate_Grid2"] = null;
                        GridView2.DataSource = null;
                        GridView2.DataBind();
                    }
                    else if (insertedCount == 0 && duplicateCount > 0)
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('All NIC(s) already exist. No record was saved.');", true);
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
        }




        protected void btnRemove_Click(object sender, EventArgs e)
        {
            /* Section 1 is hidden. Functionality removed.
            divFilter.Visible = true;
            divNewInterview.Visible = false;
            */
        }



        private void BindInterviewersGrid()
        {
            /* Section 1 is hidden. Functionality removed.
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "SELECT * FROM Interviewer WHERE Status = 0 ORDER BY Iid;";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    gvInterviewers.DataSource = dr;
                    gvInterviewers.DataBind();
                }
            }
            */
        }
        /// <summary>
        /// Rebinds GridView1 from Session on postback so data persists without ViewState bloat.
        /// </summary>
        private void RebindGrid1FromSession()
        {
            DataTable dt = Session["Generate_Grid1"] as DataTable;
            if (dt != null)
            {
                GridView1.DataSource = dt;
                GridView1.DataBind();
            }
        }



        private void BindMembershipDropdown()
        {

            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "SELECT id, FormTypeName FROM FormTypeMain ORDER BY FormTypeName";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    ddlMembership.DataSource = dr;
                    ddlMembership.DataTextField = "FormTypeName";
                    ddlMembership.DataValueField = "id";
                    ddlMembership.DataBind();
                }
            }

            ddlMembership.Items.Insert(0, new ListItem("Select Membership", ""));


        }





        protected void ddlMembership_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Smoothly Trigger Search
            btnFilter_Click(sender, e);
        }

        private void BindGrid1(string name, string nationality)
        {
            //DataTable dt = new DataTable();
            //using (SqlConnection con = new SqlConnection(connStr))
            //using (SqlCommand cmd = new SqlCommand("dbo.SearchApplicationSummary", con))
            //using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            //{
            //    cmd.CommandType = CommandType.StoredProcedure;
            //    da.Fill(dt);
            //}

            //RemoveSelectedFromGrid1(dt);

            //GridView1.DataSource = dt;
            //GridView1.DataBind();
        }

        private void RemoveSelectedFromGrid1(DataTable dt)
        {
            if (Session["Generate_Grid2"] != null)
            {
                DataTable dt2 = (DataTable)Session["Generate_Grid2"];
                foreach (DataRow row in dt2.Rows)
                {
                    DataRow[] foundRows = dt.Select(string.Format("NIC='{0}'", row["NIC"].ToString()));
                    foreach (DataRow r in foundRows)
                        dt.Rows.Remove(r);
                }
            }
        }




        protected void btnFilter_Click(object sender, EventArgs e)
        {
            DateTime? startDate = null;
            DateTime? endDate = null;

            DateTime sd;
            DateTime ed;

            if (DateTime.TryParse(txtStartDate.Text, out sd))
                startDate = sd;

            if (DateTime.TryParse(txtEndDate.Text, out ed))
                endDate = ed;

            BindGrid1(ddlMembership.SelectedValue, startDate, endDate);
        }


        private void BindGrid1(string membershipId, DateTime? startDate, DateTime? endDate)
        {
            DataTable dt = new DataTable();

            string searchInput = txtSearchKeyword.Text.Trim();
            List<string> terms = new List<string>();
            if (!string.IsNullOrEmpty(searchInput))
            {
                foreach (string term in searchInput.Split('+'))
                {
                    string cleaned = term.Trim();
                    if (!string.IsNullOrEmpty(cleaned))
                    {
                        terms.Add(cleaned);
                    }
                }
            }

            // Construct query with LEFT JOIN on MemberProfile
            System.Text.StringBuilder queryBuilder = new System.Text.StringBuilder(@"
                SELECT 
                    A.TrackID,
                    A.ApplicantName,
                    A.FatherName,
                    A.NIC,
                    A.Mobile,
                    A.Email,
                    A.MFee, 
                    A.City,
                    ISNULL(A.Membership_class, '') + ' - ' + ISNULL(A.MembershipType, '') AS Memberships,
                    A.Status,
                    A.DeferDate,
                    A.DeferYear,
                    A.MainMemberNo,
                    M.MemberName AS MainMemberName,
                    M.AccountStatus AS MainMemberStatus,
                    A.CreatedOn,
                    A.MaritalStatus,
                    A.DOB,
                    A.Nationality
                FROM ApplicationFForm A
                LEFT JOIN MemberProfile M ON A.MainMemberNo = M.MemberNo
                WHERE 
                    (@Membership = '' OR @Membership IS NULL OR A.MembershipTypeID = @Membership)
                    AND (A.Status = 'Pending' OR A.Status IS NULL OR A.Status = 'Deferred')
                    AND (@StartDate IS NULL OR A.CreatedOn >= @StartDate)
                    AND (@EndDate IS NULL OR A.CreatedOn <= DATEADD(day, 1, @EndDate))");

            for (int i = 0; i < terms.Count; i++)
            {
                queryBuilder.AppendFormat(" AND (A.ApplicantName LIKE @Term{0} OR A.FatherName LIKE @Term{0} OR A.NIC LIKE @Term{0})", i);
            }

            // FIFO sorting (oldest first by CreatedOn)
            queryBuilder.Append(" ORDER BY ISNULL(A.CreatedOn, '1900-01-01') ASC, A.TrackID ASC");

            using (SqlConnection con = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(queryBuilder.ToString(), con))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                cmd.Parameters.AddWithValue("@Membership", string.IsNullOrEmpty(membershipId) ? "" : membershipId);

                cmd.Parameters.AddWithValue("@StartDate",
                    startDate.HasValue ? (object)startDate.Value : DBNull.Value);

                cmd.Parameters.AddWithValue("@EndDate",
                    endDate.HasValue ? (object)endDate.Value : DBNull.Value);

                for (int i = 0; i < terms.Count; i++)
                {
                    cmd.Parameters.AddWithValue("@Term" + i, "%" + terms[i] + "%");
                }

                da.Fill(dt);
            }

            RemoveSelectedFromGrid1(dt);

            // Store in Session so GridView1 persists across postbacks (not ViewState — avoids maxfilesize)
            Session["Generate_Grid1"] = dt;

            GridView1.DataSource = dt;
            GridView1.DataBind();
        }

        protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // 1. Deferred Status Check
                string status = DataBinder.Eval(e.Row.DataItem, "Status").ToString();
                if (status == "Deferred")
                {
                    object deferDateObj = DataBinder.Eval(e.Row.DataItem, "DeferDate");
                    object deferYearObj = DataBinder.Eval(e.Row.DataItem, "DeferYear");

                    bool isEligible = false;
                    DateTime current = DateTime.Now;

                    if (deferDateObj != DBNull.Value && deferDateObj != null)
                    {
                        DateTime deferDate = Convert.ToDateTime(deferDateObj);
                        if (deferDate.Date <= current.Date)
                        {
                            isEligible = true;
                        }
                    }

                    if (!isEligible && deferYearObj != DBNull.Value && deferYearObj != null)
                    {
                        int deferYear;
                        if (int.TryParse(deferYearObj.ToString(), out deferYear))
                        {
                            if (deferYear <= current.Year)
                            {
                                isEligible = true;
                            }
                        }
                    }

                    if (!isEligible)
                    {
                        CheckBox chkSelect = (CheckBox)e.Row.FindControl("chkSelect");
                        if (chkSelect != null)
                        {
                            chkSelect.Enabled = false;
                            chkSelect.ToolTip = "Deferred case is not eligible for selection yet. (Wait for Deferred Date/Year)";
                        }
                    }
                }

                // 2. Main Member Status Check (Block Suspended/Terminated/Cancelled but show in results)
                object mainStatusObj = DataBinder.Eval(e.Row.DataItem, "MainMemberStatus");
                if (mainStatusObj != null && mainStatusObj != DBNull.Value)
                {
                    string mainStatus = mainStatusObj.ToString().Trim();
                    if (mainStatus.Equals("Suspended", StringComparison.OrdinalIgnoreCase) ||
                        mainStatus.Equals("Terminated", StringComparison.OrdinalIgnoreCase) ||
                        mainStatus.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
                    {
                        CheckBox chkSelect = (CheckBox)e.Row.FindControl("chkSelect");
                        if (chkSelect != null)
                        {
                            chkSelect.Enabled = false;
                            chkSelect.ToolTip = "Main Member is " + mainStatus + ". Selection is blocked.";
                        }
                    }
                }
            }
        }



        private int CalculateIntAge(DateTime dob)
        {
            int age = DateTime.Today.Year - dob.Year;
            if (dob.Date > DateTime.Today.AddYears(-age)) age--;
            return age;
        }

        private bool IsChildApplicant(string applicantName, string fatherName, string applicantNic, string mainMemberNo)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();

                // 1. Check in MemberChildren table using Applicant's NIC or Name + Parent's Member No
                string childQuery = @"
                    SELECT TOP 1 mc.ChildID 
                    FROM MemberChildren mc
                    JOIN Member m ON mc.MemberID = m.MemberID
                    WHERE (mc.CNIC = @NIC AND @NIC <> '')
                       OR (mc.ChildName = @ApplicantName AND m.MemberNo = @MainMemberNo AND @MainMemberNo <> '')";
                       
                using (SqlCommand cmd = new SqlCommand(childQuery, con))
                {
                    cmd.Parameters.AddWithValue("@NIC", applicantNic ?? "");
                    cmd.Parameters.AddWithValue("@ApplicantName", applicantName ?? "");
                    cmd.Parameters.AddWithValue("@MainMemberNo", mainMemberNo ?? "");
                    
                    object res = cmd.ExecuteScalar();
                    if (res != null && res != DBNull.Value)
                    {
                        return true;
                    }
                }

                // 2. Check in MemberProfile using MainMemberNo and FatherName
                if (!string.IsNullOrEmpty(mainMemberNo))
                {
                    string profileQuery = "SELECT TOP 1 MemberID FROM MemberProfile WHERE MemberNo = @MemberNo AND (MemberName = @FatherName OR @FatherName = '')";
                    using (SqlCommand cmd = new SqlCommand(profileQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@MemberNo", mainMemberNo);
                        cmd.Parameters.AddWithValue("@FatherName", fatherName ?? "");
                        
                        object res = cmd.ExecuteScalar();
                        if (res != null && res != DBNull.Value)
                        {
                            return true;
                        }
                    }
                }

                // 3. Fallback: Search MemberProfile by Father's Name only
                if (!string.IsNullOrEmpty(fatherName))
                {
                    string fatherQuery = "SELECT TOP 1 MemberID FROM MemberProfile WHERE MemberName = @FatherName";
                    using (SqlCommand cmd = new SqlCommand(fatherQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@FatherName", fatherName);
                        object res = cmd.ExecuteScalar();
                        if (res != null && res != DBNull.Value)
                        {
                            return true;
                        }
                    }
                }
            }
            return false;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            DataTable dtGrid2 = Session["Generate_Grid2"] as DataTable;

            if (dtGrid2 == null)
            {
                dtGrid2 = new DataTable();
                dtGrid2.Columns.Add("ApplicantName", typeof(string));
                dtGrid2.Columns.Add("FatherName", typeof(string));
                dtGrid2.Columns.Add("NIC", typeof(string));
                dtGrid2.Columns.Add("Nationality", typeof(string));
                dtGrid2.Columns.Add("City", typeof(string));
                dtGrid2.Columns.Add("Mobile", typeof(string));
                dtGrid2.Columns.Add("Email", typeof(string));
                dtGrid2.Columns.Add("MFee", typeof(decimal));
                dtGrid2.Columns.Add("Membership", typeof(string));
                dtGrid2.Columns.Add("Status", typeof(string));
                dtGrid2.Columns.Add("MainMemberNo", typeof(string));
                dtGrid2.Columns.Add("CreatedOn", typeof(DateTime));
                dtGrid2.Columns.Add("MaritalStatus", typeof(string));
            }

            // Track fathers and main member numbers already in Grid2 or being added in this batch
            HashSet<string> existingFathers = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            HashSet<string> existingMainMembers = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            foreach (DataRow row in dtGrid2.Rows)
            {
                string father = row["FatherName"].ToString().Trim();
                if (!string.IsNullOrEmpty(father))
                    existingFathers.Add(father);

                string mainNo = row["MainMemberNo"].ToString().Trim();
                if (!string.IsNullOrEmpty(mainNo))
                    existingMainMembers.Add(mainNo);
            }

            List<string> skippedNames = new List<string>();
            int addedCount = 0;

            // Add selected rows from GridView1 to Grid2
            for (int i = 0; i < GridView1.Rows.Count; i++)
            {
                GridViewRow row = GridView1.Rows[i];
                CheckBox chk = row.FindControl("chkSelect") as CheckBox;

                if (chk != null && chk.Checked)
                {
                    var dataKeys = GridView1.DataKeys[i];
                    string nic = dataKeys["NIC"] != null ? dataKeys["NIC"].ToString().Trim() : "";
                    string applicantName = dataKeys["ApplicantName"] != null ? dataKeys["ApplicantName"].ToString().Trim() : "";
                    string fatherName = dataKeys["FatherName"] != null ? dataKeys["FatherName"].ToString().Trim() : "";
                    string city = dataKeys["City"] != null ? dataKeys["City"].ToString().Trim() : "";
                    string email = dataKeys["Email"] != null ? dataKeys["Email"].ToString().Trim() : "";
                    string memberships = dataKeys["Memberships"] != null ? dataKeys["Memberships"].ToString().Trim() : "";
                    string status = dataKeys["Status"] != null ? dataKeys["Status"].ToString().Trim() : "";
                    string mainMemberNo = dataKeys["MainMemberNo"] != null ? dataKeys["MainMemberNo"].ToString().Trim() : "";
                    string mainMemberStatus = dataKeys["MainMemberStatus"] != null ? dataKeys["MainMemberStatus"].ToString().Trim() : "";
                    string maritalStatus = dataKeys["MaritalStatus"] != null ? dataKeys["MaritalStatus"].ToString().Trim() : "";
                    object deferDateObj = dataKeys["DeferDate"];
                    object deferYearObj = dataKeys["DeferYear"];
                    object createdOnObj = dataKeys["CreatedOn"];
                    object dobObj = dataKeys["DOB"];
                    string mobile = dataKeys["Mobile"] != null ? dataKeys["Mobile"].ToString().Trim() : "";
                    string nationality = dataKeys["Nationality"] != null ? dataKeys["Nationality"].ToString().Trim() : "";

                    // Check if NIC already exists in Grid2
                    bool exists = false;
                    foreach (DataRow existingRow in dtGrid2.Rows)
                    {
                        if (existingRow["NIC"].ToString() == nic)
                        {
                            exists = true;
                            break;
                        }
                    }

                    if (exists)
                    {
                        continue; // Already in Grid2, skip silently
                    }

                    // 1. Validate Deferred status
                    if (status.Equals("Deferred", StringComparison.OrdinalIgnoreCase))
                    {
                        bool isEligible = false;
                        DateTime current = DateTime.Now;

                        if (deferDateObj != DBNull.Value && deferDateObj != null)
                        {
                            DateTime deferDate = Convert.ToDateTime(deferDateObj);
                            if (deferDate.Date <= current.Date)
                            {
                                isEligible = true;
                            }
                        }

                        if (!isEligible && deferYearObj != DBNull.Value && deferYearObj != null)
                        {
                            int deferYear;
                            if (int.TryParse(deferYearObj.ToString(), out deferYear))
                            {
                                if (deferYear <= current.Year)
                                {
                                    isEligible = true;
                                }
                            }
                        }

                        if (!isEligible)
                        {
                            skippedNames.Add(applicantName + " (Deferred status not eligible yet)");
                            continue;
                        }
                    }

                    // 2. Validate Main Member Status (excluding Deceased, Resigned)
                    if (!string.IsNullOrEmpty(mainMemberStatus))
                    {
                        if (mainMemberStatus.Equals("Suspended", StringComparison.OrdinalIgnoreCase) ||
                            mainMemberStatus.Equals("Terminated", StringComparison.OrdinalIgnoreCase) ||
                            mainMemberStatus.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
                        {
                            skippedNames.Add(applicantName + " (Main member is " + mainMemberStatus + ")");
                            continue;
                        }
                    }

                    // 3. Validate Same Parent restriction (one child per interview list)
                    bool isDuplicateChild = false;
                    if (!string.IsNullOrEmpty(fatherName) && existingFathers.Contains(fatherName))
                    {
                        isDuplicateChild = true;
                    }
                    if (!string.IsNullOrEmpty(mainMemberNo) && existingMainMembers.Contains(mainMemberNo))
                    {
                        isDuplicateChild = true;
                    }

                    if (isDuplicateChild)
                    {
                        skippedNames.Add(applicantName + " (Another child of same parent is already in list)");
                        continue;
                    }

                    // 4. Validate Age Restriction if Child
                    bool isChild = IsChildApplicant(applicantName, fatherName, nic, mainMemberNo);
                    bool isMarried = maritalStatus.Equals("Married", StringComparison.OrdinalIgnoreCase);

                    if (isChild && !isMarried)
                    {
                        if (dobObj == null || dobObj == DBNull.Value || string.IsNullOrEmpty(dobObj.ToString()))
                        {
                            skippedNames.Add(applicantName + " (Single child, but DOB is missing/invalid)");
                            continue;
                        }
                        else
                        {
                            DateTime dob = Convert.ToDateTime(dobObj);
                            int age = CalculateIntAge(dob);
                            if (age <= 35)
                            {
                                skippedNames.Add(applicantName + " (Single child must be older than 35, current age: " + age + ")");
                                continue;
                            }
                        }
                    }

                    // If all validation checks pass, add applicant to Grid2
                    DataRow dr = dtGrid2.NewRow();
                    dr["ApplicantName"] = applicantName;
                    dr["FatherName"] = fatherName;
                    dr["NIC"] = nic;
                    dr["Nationality"] = nationality;
                    dr["City"] = city;
                    dr["Mobile"] = mobile;
                    dr["Email"] = email;
                    dr["Membership"] = memberships;
                    dr["MainMemberNo"] = mainMemberNo;
                    dr["CreatedOn"] = (createdOnObj != DBNull.Value && createdOnObj != null) ? Convert.ToDateTime(createdOnObj) : (object)DBNull.Value;
                    dr["MaritalStatus"] = maritalStatus;

                    decimal fee = 0;
                    if (dataKeys["MFee"] != null && dataKeys["MFee"] != DBNull.Value)
                        decimal.TryParse(dataKeys["MFee"].ToString(), out fee);

                    dr["MFee"] = fee;
                    dr["Status"] = "Shortlisted";
                    dtGrid2.Rows.Add(dr);

                    addedCount++;

                    // Add to batch tracking sets
                    if (!string.IsNullOrEmpty(fatherName))
                        existingFathers.Add(fatherName);
                    if (!string.IsNullOrEmpty(mainMemberNo))
                        existingMainMembers.Add(mainMemberNo);
                }
            }

            // Store in Session so GridView2 persists across postbacks (not ViewState — avoids maxfilesize)
            Session["Generate_Grid2"] = dtGrid2;

            // Bind GridView2 with the data
            GridView2.DataSource = dtGrid2;
            GridView2.DataBind();

            // Refresh GridView1 to remove selected items
            DateTime? startDate = null;
            DateTime? endDate = null;
            DateTime sd, ed;

            if (DateTime.TryParse(txtStartDate.Text, out sd)) startDate = sd;
            if (DateTime.TryParse(txtEndDate.Text, out ed)) endDate = ed;

            BindGrid1(ddlMembership.SelectedValue, startDate, endDate);

            // Optional: Show messages/alerts
            if (skippedNames.Count > 0)
            {
                string alertMsg = "Processed selected items.\\nAdded: " + addedCount + "\\nSkipped: " + skippedNames.Count + " due to business rules:\\n- " + string.Join("\\n- ", skippedNames);
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + alertMsg.Replace("'", "\\'") + "');", true);
            }
            else if (addedCount > 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Items added to interview list successfully!');", true);
            }
        }

        private void BindGrid2()
        {
            DataTable dt = Session["Generate_Grid2"] as DataTable;

            if (dt != null && dt.Rows.Count > 0)
            {
                GridView2.DataSource = dt;
                GridView2.DataBind();
            }
        }




        protected void GridView2_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteRow")
            {
                int index = Convert.ToInt32(e.CommandArgument);
                DataTable dtGrid2 = Session["Generate_Grid2"] as DataTable;

                if (dtGrid2 != null && index >= 0 && index < dtGrid2.Rows.Count)
                    dtGrid2.Rows.RemoveAt(index);

                Session["Generate_Grid2"] = dtGrid2;
                GridView2.DataSource = dtGrid2;
                GridView2.DataBind();

                GridView2.DataSource = Session["Generate_Grid2"] as DataTable;
                GridView2.DataBind();
            }
        }

        private List<int> GetSelectedRowsIndexes()
        {
            List<int> selectedIndexes = new List<int>();
            for (int i = 0; i < GridView2.Rows.Count; i++)
            {
                GridViewRow row = GridView2.Rows[i];
                CheckBox chk = (CheckBox)row.FindControl("chkSelect1");
                if (chk != null && chk.Checked)
                    selectedIndexes.Add(i);
            }
            return selectedIndexes;
        }

        protected void btnProcessAction_Click(object sender, EventArgs e)
        { }


        protected void btnReject_Click(object sender, EventArgs e)
        {
            hfActionType.Value = "Reject";
            ShowRemarksPanel("Reject Application");
        }

        protected void btnPostponed_Click(object sender, EventArgs e)
        {
            hfActionType.Value = "Postpone";
            ShowRemarksPanel("Postpone Application");
        }

        protected void btnFinalize_Click(object sender, EventArgs e)
        {
            hfActionType.Value = "Finalize";
            ShowRemarksPanel("Finalize Application");
        }

        protected void btnClosePanel_Click(object sender, EventArgs e)
        {
            pnlRemarks.Visible = false;
            txtRemarks.Text = "";
            hfActionType.Value = "";
        }

        protected void btnCancelAction_Click(object sender, EventArgs e)
        {
            pnlRemarks.Visible = false;
            txtRemarks.Text = "";
            hfActionType.Value = "";
        }

        protected void btnConfirmAction_Click(object sender, EventArgs e)
        {

            string remarks = txtRemarks.Text.Trim();
            string actionType = hfActionType.Value;


            hfRemarks.Value = remarks;


            switch (actionType)
            {
                case "Reject":
                    ProcessRejectAction(remarks);
                    break;
                case "Postpone":
                    ProcessPostponeAction(remarks);
                    break;
                case "Finalize":
                    ProcessFinalizeAction(remarks);
                    break;
            }


            pnlRemarks.Visible = false;
            txtRemarks.Text = "";
            hfActionType.Value = "";
        }

        private void ShowRemarksPanel(string title)
        {
            lblPanelTitle.Text = title;
            pnlRemarks.Visible = true;
            txtRemarks.Text = "";
        }


        private void ProcessRejectAction(string remarks)
        {
            DataTable dtGrid2 = Session["Generate_Grid2"] as DataTable;
            if (dtGrid2 == null)
            {
                lblActionIndicator.Text = "No data found to reject!";
                return;
            }

            List<int> selected = GetSelectedRowsIndexes();
            if (selected.Count == 0)
            {
                lblActionIndicator.Text = "Please select at least one candidate to reject!";
                return;
            }

            try
            {

                foreach (int idx in selected)
                {
                    string nic = dtGrid2.Rows[idx]["NIC"].ToString();


                    UpdateApplicationFFormStatus(nic, "Rejected", remarks);


                    UpdateInterviewListStatus(nic, "Rejected", remarks);


                    dtGrid2.Rows[idx]["Status"] = "Rejected";
                }


                Session["Generate_Grid2"] = dtGrid2;
                GridView2.DataSource = dtGrid2;
                GridView2.DataBind();


                lblActionIndicator.Text = "Selected candidates rejected! Remarks: {remarks}";
            }
            catch (Exception ex)
            {
                lblActionIndicator.Text = "Error rejecting candidates: {ex.Message}";
            }
        }

        private void ProcessPostponeAction(string remarks)
        {
            DataTable dtGrid2 = Session["Generate_Grid2"] as DataTable;
            if (dtGrid2 == null)
            {
                lblActionIndicator.Text = "No data found to postpone!";
                return;
            }

            List<int> selected = GetSelectedRowsIndexes();
            if (selected.Count == 0)
            {
                lblActionIndicator.Text = "Please select at least one candidate to postpone!";
                return;
            }

            try
            {

                foreach (int idx in selected)
                {
                    string nic = dtGrid2.Rows[idx]["NIC"].ToString();


                    UpdateApplicationFFormStatus(nic, "Deferred", remarks);
                    UpdateInterviewListStatus(nic, "Deferred", remarks);

                    dtGrid2.Rows[idx]["Status"] = "Deferred";
                    if (dtGrid2.Columns.Contains("Remarks"))
                    {
                        dtGrid2.Rows[idx]["Remarks"] = remarks;
                    }
                }


                Session["Generate_Grid2"] = dtGrid2;
                GridView2.DataSource = dtGrid2;
                GridView2.DataBind();


                lblActionIndicator.Text = "Selected candidates postponed! Remarks: {remarks}";
            }
            catch (Exception ex)
            {
                lblActionIndicator.Text = "Error postponing candidates: {ex.Message}";
            }
        }

        private void ProcessFinalizeAction(string remarks)
        {
            DataTable dtGrid2 = Session["Generate_Grid2"] as DataTable;
            if (dtGrid2 == null || dtGrid2.Rows.Count == 0)
            {
                lblActionIndicator.Text = "Grid is empty";
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("InsertInterviewData", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Month", DateTime.Now.ToString("MMMM"));
                    cmd.Parameters.AddWithValue("@Year", DateTime.Now.Year);
                    cmd.Parameters.Add("@Emp_Id", SqlDbType.Int).Value = DBNull.Value;
                    cmd.Parameters.Add("@EntryDate", SqlDbType.DateTime).Value = DateTime.Now;

                    DataTable tvp = new DataTable();
                    tvp.Columns.Add("ApplicantName", typeof(string));
                    tvp.Columns.Add("FatherName", typeof(string));
                    tvp.Columns.Add("NIC", typeof(string));
                    tvp.Columns.Add("Nationality", typeof(string));
                    tvp.Columns.Add("City", typeof(string));
                    tvp.Columns.Add("Mobile", typeof(string));
                    tvp.Columns.Add("Email", typeof(string));
                    tvp.Columns.Add("MFee", typeof(decimal));
                    tvp.Columns.Add("Status", typeof(string));

                    foreach (DataRow row in dtGrid2.Rows)
                    {
                        decimal fee = 0;
                        string feeStr = row["MFee"] != null ? row["MFee"].ToString() : "0";
                        decimal.TryParse(feeStr, out fee);

                        string status = row["Status"] != DBNull.Value ? row["Status"].ToString() : "Approved"; // Default to Approved if marking final?
                        // Or logic: if row has "Rejected" use rejected, else "Approved" via Finalize action?
                        // The loop iterates existing grid. If user clicked "Finalize", are we approving ALL leftover?
                        // ProcessFinalizeAction seems to be bulk insert.
                        // Assuming "Finalize" means Approve unless marked otherwise?
                        // But wait, the grid contains people added.
                        // Usually "Finalize" = Approve.
                        if (status == "Shortlisted" || string.IsNullOrEmpty(status)) status = "Approved";

                        tvp.Rows.Add(
                         row.Table.Columns.Contains("ApplicantName") ? row["ApplicantName"].ToString() : "",
                         row.Table.Columns.Contains("FatherName") ? row["FatherName"].ToString() : "",
                         row.Table.Columns.Contains("NIC") ? row["NIC"].ToString() : "",
                         row.Table.Columns.Contains("Nationality") ? row["Nationality"].ToString() : "",
                         row.Table.Columns.Contains("City") ? row["City"].ToString() : "",
                         row.Table.Columns.Contains("Mobile") ? row["Mobile"].ToString() : "",
                         row.Table.Columns.Contains("Email") ? row["Email"].ToString() : "",
                         fee,
                         status
                     );


                    }

                    SqlParameter p = cmd.Parameters.AddWithValue("@InterviewList", tvp);
                    p.SqlDbType = SqlDbType.Structured;
                    p.TypeName = "dbo.InterviewListType";

                    con.Open();
                    cmd.ExecuteNonQuery();
                    con.Close();
                }


                foreach (DataRow row in dtGrid2.Rows)
                {
                    string nic = row["NIC"].ToString();
                    UpdateApplicationFFormStatus(nic, "Approved", remarks);
                    UpdateInterviewListStatus(nic, "Approved", remarks);
                    row["Status"] = 1;
                }

                Session["Generate_Grid2"] = dtGrid2;
                GridView2.DataSource = dtGrid2;
                GridView2.DataBind();

                lblActionIndicator.Text = "Interview list finalized successfully! Remarks: " + remarks;
                GenerateGrid2PDF();
            }
            catch (Exception ex)
            {

                lblActionIndicator.Text = "Error finalizing interview list: " + ex.Message;
            }
        }





        private void UpdateApplicationFFormStatus(string nic, string status, string remarks)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "UPDATE ApplicationFForm SET Status = @Status, Remarks = @Remarks WHERE NIC = @NIC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Status", status);
                    cmd.Parameters.AddWithValue("@Remarks", remarks ?? (object)DBNull.Value);
                    cmd.Parameters.AddWithValue("@NIC", nic);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void UpdateInterviewListStatus(string nic, string status, string remarks)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "UPDATE InterviewList SET Status = @Status, Remarks = @Remarks WHERE NIC = @NIC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Status", status);
                    cmd.Parameters.AddWithValue("@Remarks", remarks ?? (object)DBNull.Value);
                    cmd.Parameters.AddWithValue("@NIC", nic);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void GenerateGrid2PDF()
        {
            /*
            DataTable dt = Session["Generate_Grid2"] as DataTable;
            // ... logic commented out ...
            */
        }

        protected string GetMainMemberStatusStyle(object mainMemberStatusObj)
        {
            if (mainMemberStatusObj == null || mainMemberStatusObj == DBNull.Value)
            {
                return "display: inline-block !important; padding: 0.2rem 0.6rem !important; background: #f0fdf4 !important; color: #16a34a !important; border-radius: 6px !important; font-size: 0.75rem !important; font-weight: 600 !important; border: 1px solid #bbf7d0 !important;";
            }

            string status = mainMemberStatusObj.ToString();
            if (status.Equals("Suspended", StringComparison.OrdinalIgnoreCase) ||
                status.Equals("Terminated", StringComparison.OrdinalIgnoreCase) ||
                status.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
            {
                return "display: inline-block !important; padding: 0.2rem 0.6rem !important; background: #fee2e2 !important; color: #dc2626 !important; border-radius: 6px !important; font-size: 0.75rem !important; font-weight: 600 !important; border: 1px solid #fca5a5 !important;";
            }

            return "display: inline-block !important; padding: 0.2rem 0.6rem !important; background: #f0fdf4 !important; color: #16a34a !important; border-radius: 6px !important; font-size: 0.75rem !important; font-weight: 600 !important; border: 1px solid #bbf7d0 !important;";
        }

        protected string GetStatusStyle(object statusObj)
        {
            if (statusObj == null || statusObj == DBNull.Value)
            {
                return "display: inline-block !important; padding: 0.2rem 0.6rem !important; background: #f0fdf4 !important; color: #16a34a !important; border-radius: 6px !important; font-size: 0.75rem !important; font-weight: 600 !important; border: 1px solid #bbf7d0 !important;";
            }

            string status = statusObj.ToString();
            if (status.Equals("Deferred", StringComparison.OrdinalIgnoreCase))
            {
                return "display: inline-block !important; padding: 0.2rem 0.6rem !important; background: #fffbeb !important; color: #d97706 !important; border-radius: 6px !important; font-size: 0.75rem !important; font-weight: 600 !important; border: 1px solid #fde68a !important;";
            }

            return "display: inline-block !important; padding: 0.2rem 0.6rem !important; background: #f0fdf4 !important; color: #16a34a !important; border-radius: 6px !important; font-size: 0.75rem !important; font-weight: 600 !important; border: 1px solid #bbf7d0 !important;";
        }

        protected string GetStatusText(object statusObj)
        {
            if (statusObj == null || statusObj == DBNull.Value)
            {
                return "Pending";
            }

            string status = statusObj.ToString();
            if (status.Equals("Deferred", StringComparison.OrdinalIgnoreCase))
            {
                return "Deferred";
            }

            return "Pending";
        }
    }
}