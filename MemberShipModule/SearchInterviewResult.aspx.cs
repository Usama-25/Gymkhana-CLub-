using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RefundFee
{
    public partial class SearchInterviewResult : System.Web.UI.Page
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
            if (!IsPostBack)
            {
                BindLookupData();

                if (!string.IsNullOrEmpty(Request.QueryString["NIC"]))
                {
                    string nic = Request.QueryString["NIC"];
                    BindPanel(nic);
                }
                else if (!string.IsNullOrEmpty(Request.QueryString["ApplicantID"]))
                {
                    string applicantId = Request.QueryString["ApplicantID"];
                    string nic = "";
                    using (SqlConnection conn = new SqlConnection(connStr))
                    using (SqlCommand cmd = new SqlCommand("usp_GetApplicantByTrackId", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@TrackID", SqlDbType.NVarChar, 50).Value = applicantId;
                        conn.Open();
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                nic = dr["NIC"].ToString();
                            }
                        }
                    }
                    if (!string.IsNullOrEmpty(nic))
                    {
                        BindPanel(nic);
                    }
                }
            }
        }

        private void BindLookupData()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();

                // Bind MembershipType
                using (SqlCommand cmd = new SqlCommand("usp_GetMembershipTypes", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlMembershipTypeSelected.DataSource = dt;
                    ddlMembershipTypeSelected.DataTextField = "MembershipType";
                    ddlMembershipTypeSelected.DataValueField = "id";
                    ddlMembershipTypeSelected.DataBind();
                    ddlMembershipTypeSelected.Items.Insert(0, new ListItem("- Select Membership Type -", "0"));
                }
            }

            // Bind Finance Heads for fee distribution modal
            BindFinanceHeads();
        }

        private void BindFinanceHeads()
        {
            try
            {
                string financeConnStr = ConfigurationManager.ConnectionStrings["FinanceConnectionString"] != null
                    ? ConfigurationManager.ConnectionStrings["FinanceConnectionString"].ConnectionString
                    : (ConfigurationManager.ConnectionStrings["Finance_ConnectionString"] != null 
                        ? ConfigurationManager.ConnectionStrings["Finance_ConnectionString"].ConnectionString 
                        : "");

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

                        // Build display text as "E_Code - E_Name"
                        dt.Columns.Add("DisplayText", typeof(string));
                        foreach (DataRow row in dt.Rows)
                        {
                            row["DisplayText"] = row["E_Code"].ToString() + " - " + row["E_Name"].ToString();
                        }

                        ddlFinanceHeads.DataSource = dt;
                        ddlFinanceHeads.DataTextField = "DisplayText";
                        ddlFinanceHeads.DataValueField = "ID";
                        ddlFinanceHeads.DataBind();
                        ddlFinanceHeads.Items.Insert(0, new ListItem("- Select Finance Head -", "0"));
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error binding finance heads: " + ex.Message);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string selectedStatus = ddlMembershipType.SelectedValue;

            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("usp_GetInterviewsByStatus", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@Status", SqlDbType.NVarChar, 50).Value = selectedStatus;
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        // Ensure ApplicationNo column exists
                        if (!dt.Columns.Contains("ApplicationNo"))
                        {
                            dt.Columns.Add("ApplicationNo", typeof(string));
                        }

                        // Collect TrackID / ApplicationNo from ApplicationFForm by matching NIC
                        Dictionary<string, string> nicToTrackId = new Dictionary<string, string>();
                        try
                        {
                            string sqlApp = "SELECT TrackID, NIC FROM ApplicationFForm";
                            using (SqlCommand cmdApp = new SqlCommand(sqlApp, con))
                            {
                                if (con.State != ConnectionState.Open) con.Open();
                                using (SqlDataReader dr = cmdApp.ExecuteReader())
                                {
                                    while (dr.Read())
                                    {
                                        string nic = dr["NIC"] != DBNull.Value ? dr["NIC"].ToString().Replace("-", "").Trim() : "";
                                        string track = dr["TrackID"] != DBNull.Value ? dr["TrackID"].ToString() : "";
                                        if (!string.IsNullOrEmpty(nic) && !nicToTrackId.ContainsKey(nic))
                                        {
                                            nicToTrackId[nic] = track;
                                        }
                                    }
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine("Error enriching ApplicationNo: " + ex.Message);
                        }

                        foreach (DataRow row in dt.Rows)
                        {
                            string appNo = row.Table.Columns.Contains("TrackID") && row["TrackID"] != DBNull.Value ? row["TrackID"].ToString() : "";
                            if (string.IsNullOrEmpty(appNo))
                            {
                                string nic = row.Table.Columns.Contains("NIC") && row["NIC"] != DBNull.Value ? row["NIC"].ToString().Replace("-", "").Trim() : "";
                                if (!string.IsNullOrEmpty(nic) && nicToTrackId.ContainsKey(nic))
                                {
                                    appNo = nicToTrackId[nic];
                                }
                            }
                            row["ApplicationNo"] = string.IsNullOrEmpty(appNo) ? "—" : appNo;
                        }

                        gvResults.DataSource = dt;
                        gvResults.DataBind();
                        gvResults.Visible = true;
                        lblMessage.Visible = false;
                    }
                    else
                    {
                        gvResults.Visible = false;
                        lblMessage.Text = "No records found for selected status.";
                        lblMessage.Visible = true;
                    }
                    btnAction.Visible = true;
                }
            }
        }

        protected void gvResults_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "OpenForm")
            {
                string nic = e.CommandArgument.ToString();
                BindPanel(nic);
            }
        }

        protected void btnAction_Click(object sender, EventArgs e)
        {
            if (btnAction.Text == "Refund")
            {
                Response.Redirect("RefundMemberFee.aspx");
            }
            else if (btnAction.Text.Contains("Convert into Member"))
            {
                string selectedNIC = string.Empty;
                foreach (GridViewRow row in gvResults.Rows)
                {
                    CheckBox chk = (CheckBox)row.FindControl("chkSelect");
                    if (chk != null && chk.Checked)
                    {
                        LinkButton lnk = (LinkButton)row.FindControl("lnkOpenForm");
                        if (lnk != null && !string.IsNullOrEmpty(lnk.CommandArgument))
                        {
                            selectedNIC = lnk.CommandArgument.Trim();
                        }
                        else
                        {
                            selectedNIC = row.Cells[4].Text;
                        }
                        break;
                    }
                }

                if (!string.IsNullOrEmpty(selectedNIC))
                {
                    BindPanel(selectedNIC);
                }
                else
                {
                    lblMessage.Text = "Please select at least one applicant to convert.";
                    lblMessage.Visible = true;
                }
            }
        }

        private void BindPanel(string nic)
        {
            try
            {
                nic = Server.HtmlDecode(nic).Trim();

                using (SqlConnection con = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("usp_GetApplicantDetailsForConversion", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@NIC", SqlDbType.NVarChar, 50).Value = nic;
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            pnlApplicantDetails.Visible = true;
                            hfApplicantPhotoPath.Value = dr["ApplicantPhotoPath"] != DBNull.Value ? dr["ApplicantPhotoPath"].ToString() : "";

                            txtApplicantName.Text = dr["ApplicantName"].ToString();
                            txtFatherName.Text = dr["FatherName"].ToString();
                            txtDOB.Text = dr["DOB"].ToString();
                            txtNIC.Text = dr["NIC"].ToString();
                            txtMaritalStatus.Text = dr["MaritalStatus"].ToString();
                            txtProfession.Text = dr["Profession"].ToString();
                            txtCompanyName.Text = dr["CompanyName"].ToString();
                            txtDesignation.Text = dr["Designation"].ToString();
                            txtNationality.Text = dr["Nationality"].ToString();
                            txtMonthlyIncome.Text = dr["MonthlyIncome"].ToString();
                            txtCurrency.Text = dr["Currency"].ToString();
                            txtAddressType.Text = dr["AddressType"].ToString();
                            txtAddress.Text = dr["Address"].ToString();
                            txtCity.Text = dr["City"].ToString();
                            txtProvince.Text = dr["Province"].ToString();
                            txtCountry.Text = dr["Country"].ToString();
                            txtZipCode.Text = dr["ZipCode"].ToString();
                            txtPhone.Text = dr["Phone"].ToString();
                            txtMobile.Text = dr["Mobile"].ToString();
                            txtEmail.Text = dr["Email"].ToString();
                            txtInstitute.Text = dr["Institute"].ToString();
                            txtDegree.Text = dr["Degree"].ToString();
                            txtYear.Text = dr["Year"].ToString();
                            txtWorkExperience.Text = dr["WorkExperience"].ToString();
                            txtAreaOfInterest.Text = dr["AreaOfInterest"].ToString();
                            txtFacilities.Text = dr["Facilities"].ToString();
                            txtOtherMemberships.Text = dr["OtherMemberships"].ToString();
                            txtPreferredNo.Text = dr["PreferredNo"].ToString();
                            string appMFee = dr["MFee"] != DBNull.Value ? dr["MFee"].ToString() : "";
                            if (string.IsNullOrEmpty(appMFee) || appMFee == "0" || appMFee == "0.00" || appMFee == "0.0000")
                            {
                                appMFee = dr["FinalFee"] != DBNull.Value ? dr["FinalFee"].ToString() : "0";
                            }
                            txtMFee.Text = appMFee;
                            
                            // Auto-fill Main Member No and Name if available in the application
                            try { txtMainMemberNo.Text = dr["MainMemberNo"] != DBNull.Value ? dr["MainMemberNo"].ToString() : ""; } catch { }
                            try { txtMainMemberName.Text = dr["MainMemberName"] != DBNull.Value ? dr["MainMemberName"].ToString() : ""; } catch { }

                            txtSpouseName.Text = dr["SpouseName"] != DBNull.Value ? dr["SpouseName"].ToString() : "";
                            txtSpouseProfession.Text = dr["SpouseProfession"] != DBNull.Value ? dr["SpouseProfession"].ToString() : "";
                            txtSpouseEducation.Text = dr["SpouseEducation"] != DBNull.Value ? dr["SpouseEducation"].ToString() : "";
                            txtSpouseCNIC.Text = dr["SpouseCNIC"] != DBNull.Value ? dr["SpouseCNIC"].ToString() : "";
                            txtSpousePhone.Text = dr["SpousePhone"] != DBNull.Value ? dr["SpousePhone"].ToString() : "";

                            txtOfficeAddress.Text = dr["OfficeAddress"] != DBNull.Value ? dr["OfficeAddress"].ToString() : "";
                            txtOfficeCity.Text = dr["OfficeCity"] != DBNull.Value ? dr["OfficeCity"].ToString() : "";
                            txtOfficeProvince.Text = dr["OfficeProvince"] != DBNull.Value ? dr["OfficeProvince"].ToString() : "";
                            txtOfficeCountry.Text = dr["OfficeCountry"] != DBNull.Value ? dr["OfficeCountry"].ToString() : "";

                            txtProposer1.Text = dr["Proposer1"] != DBNull.Value ? dr["Proposer1"].ToString() : "";
                            txtRelation1.Text = dr["Relation1"] != DBNull.Value ? dr["Relation1"].ToString() : "";
                            txtProposer2.Text = dr["Proposer2"] != DBNull.Value ? dr["Proposer2"].ToString() : "";
                            txtRelation2.Text = dr["Relation2"] != DBNull.Value ? dr["Relation2"].ToString() : "";

                            txtNoOfChildren.Text = dr["NoOfChildren"] != DBNull.Value ? dr["NoOfChildren"].ToString() : "";
                            txtNoOfSons.Text = dr["NoOfSons"] != DBNull.Value ? dr["NoOfSons"].ToString() : "";
                            txtNoOfDaughters.Text = dr["NoOfDaughters"] != DBNull.Value ? dr["NoOfDaughters"].ToString() : "";

                            hfPurchaseDate.Value = dr["PurchaseDate"] != DBNull.Value ? Convert.ToDateTime(dr["PurchaseDate"]).ToString("yyyy-MM-dd") : "";
                            hfReceiptNo.Value = dr["ReceiptNo"] != DBNull.Value ? dr["ReceiptNo"].ToString() : "";

                            string interviewerName = "";
                            try { interviewerName = dr["InterviewerName"] != DBNull.Value ? dr["InterviewerName"].ToString() : ""; }
                            catch { }

                            string fType = dr["FormType"] == DBNull.Value ? "" : dr["FormType"].ToString();
                            string appMemType = dr["AppMembershipType"] == DBNull.Value ? "" : dr["AppMembershipType"].ToString();

                            if (string.IsNullOrEmpty(fType)) fType = appMemType;
                            if (string.IsNullOrEmpty(fType)) fType = "Invitation Member";

                            // Populate Form Type Main with Membership_class from ApplicationFForm
                            string memClass = "";
                            if (dr["Membership_class"] != DBNull.Value)
                            {
                                memClass = dr["Membership_class"].ToString();
                            }
                            else
                            {
                                // Fallback query to get Membership_class if not in current result set
                                using (SqlCommand cmdClass = new SqlCommand("usp_GetMembershipClassByTrackID", con))
                                {
                                    cmdClass.CommandType = CommandType.StoredProcedure;
                                    cmdClass.Parameters.Add("@TrackID", SqlDbType.Int).Value = Convert.ToInt32(dr["TrackID"]);
                                    object classObj = cmdClass.ExecuteScalar();
                                    if (classObj != null)
                                        memClass = classObj.ToString();
                                }
                            }
                            txtFormTypeMain.Text = memClass;

                            // Fetch Children Grid
                            if (dr["TrackID"] != DBNull.Value)
                            {
                                int trackId = Convert.ToInt32(dr["TrackID"]);
                                dr.Close();

                                using (SqlCommand cmdChild = new SqlCommand("usp_GetApplicationChildrenByTrackID", con))
                                {
                                    cmdChild.CommandType = CommandType.StoredProcedure;
                                    cmdChild.Parameters.Add("@TrackID", SqlDbType.Int).Value = trackId;
                                    SqlDataAdapter da = new SqlDataAdapter(cmdChild);
                                    DataTable dtChild = new DataTable();
                                    da.Fill(dtChild);
                                    gvChildren.DataSource = dtChild;
                                    gvChildren.DataBind();
                                }
                            }
                            else
                            {
                                dr.Close();
                                gvChildren.DataSource = null;
                                gvChildren.DataBind();
                            }

                            txtInterviewerName.Text = interviewerName;

                            if (ddlMembershipTypeSelected.Items.FindByText(appMemType) != null)
                            {
                                ddlMembershipTypeSelected.SelectedValue = ddlMembershipTypeSelected.Items.FindByText(appMemType).Value;
                                ddlMembershipTypeSelected_SelectedIndexChanged(null, null);
                            }
                            else
                            {
                                lblMemberPrefix.Text = "I";
                                MmberNo.Text = "";
                            }
                        }
                        else
                        {
                            if (!dr.IsClosed) dr.Close();
                            ScriptManager.RegisterStartupScript(this, GetType(), "err", "alert('Applicant not found in database for NIC: " + nic + "');", true);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "err", "alert('Error loading details: " + ex.Message.Replace("'", "") + "');", true);
            }
        }

        protected void ddlMembershipTypeSelected_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlMembershipTypeSelected.SelectedIndex > 0)
            {
                string prefix = "I";
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();
                    using (SqlCommand cmd = new SqlCommand("usp_GetMembershipPrefixByID", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@id", SqlDbType.Int).Value = Convert.ToInt32(ddlMembershipTypeSelected.SelectedValue);
                        object p = cmd.ExecuteScalar();
                        if (p != null) prefix = p.ToString();
                    }
                }
                lblMemberPrefix.Text = prefix;
                MmberNo.Text = GenerateMemberNo(prefix);
            }
            else
            {
                lblMemberPrefix.Text = "Prefix";
                MmberNo.Text = "";
            }

            // Toggle Supplementary fields visibility
            bool isNonEarning = (ddlMembershipTypeSelected.SelectedValue == "9" || 
                                 (ddlMembershipTypeSelected.SelectedItem != null && ddlMembershipTypeSelected.SelectedItem.Text == "Non Earning MemberShip") ||
                                 txtFormTypeMain.Text.Trim() == "Non Earning MemberShip");
                                 
            divSupplementaryLink.Visible = isNonEarning;
            
            if (!isNonEarning)
            {
                txtMainMemberNo.Text = "";
                txtMainMemberName.Text = "";
            }
        }

        private string GenerateMemberNo(string prefix)
        {
            string nextNo = "1";
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                string sql = "SELECT MAX(CAST(SUBSTRING(MemberNo, LEN(@Prefix) + 1, 100) AS INT)) FROM MemberProfile WHERE MemberNo LIKE @Prefix + '%' AND ISNUMERIC(SUBSTRING(MemberNo, LEN(@Prefix) + 1, 100)) = 1";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.Add("@Prefix", SqlDbType.NVarChar, 50).Value = prefix;
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        nextNo = (Convert.ToInt32(result) + 1).ToString();
                    }
                }
            }
            return nextNo;
        }

        protected void ddlMembershipType_SelectedIndexChanged(object sender, EventArgs e)
        {
            switch (ddlMembershipType.SelectedValue)
            {
                case "Approved":
                    btnAction.Text = "Convert into Members";
                    btnAction.Enabled = true;
                    break;
                case "Rejected":
                    btnAction.Text = "Refund";
                    btnAction.Enabled = true;
                    break;
                case "Deferred":
                    btnAction.Text = "Action Pending";
                    btnAction.Enabled = false;
                    break;
                default:
                    btnAction.Text = "Convert into Member";
                    btnAction.Enabled = true;
                    break;
            }
        }

        protected void btnClosePanel_Click(object sender, EventArgs e)
        {
            pnlApplicantDetails.Visible = false;
        }

        protected void txtMainMemberNo_TextChanged(object sender, EventArgs e)
        {
            string memberNo = txtMainMemberNo.Text.Trim();
            if (string.IsNullOrEmpty(memberNo))
            {
                txtMainMemberName.Text = "";
                return;
            }

            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "SELECT MemberName, Status, AccountStatus FROM MemberProfile WHERE MemberNo = @MemberNo";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = memberNo;
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            txtMainMemberName.Text = dr["MemberName"].ToString();
                            // Status and AccountStatus are selected as requested
                        }
                        else
                        {
                            dr.Close();
                            // Fallback to Member table if not found in MemberProfile
                            string queryMember = "SELECT ApplicantName, Status FROM Member WHERE MemberNo = @MemberNo";
                            using (SqlCommand cmdMember = new SqlCommand(queryMember, con))
                            {
                                cmdMember.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = memberNo;
                                try
                                {
                                    using (SqlDataReader drMember = cmdMember.ExecuteReader())
                                    {
                                        if (drMember.Read())
                                        {
                                            txtMainMemberName.Text = drMember["ApplicantName"].ToString();
                                        }
                                        else
                                        {
                                            txtMainMemberName.Text = "";
                                            ShowAlert("Member not found with ID: " + memberNo);
                                        }
                                    }
                                }
                                catch
                                {
                                    // If fallback fails (e.g. columns or table don't exist), show original message
                                    txtMainMemberName.Text = "";
                                    ShowAlert("Member not found with ID: " + memberNo);
                                }
                            }
                        }
                    }
                }
            }
        }

        protected void btnSaveApplicant_Click(object sender, EventArgs e)
        {
            try
            {
                // Log start of operation for debugging
                System.Diagnostics.Debug.WriteLine("btnSaveApplicant_Click started");

                // Validate required fields
                if (string.IsNullOrWhiteSpace(txtApplicantName.Text))
                {
                    ShowAlert("Applicant Name is required");
                    return;
                }

                if (string.IsNullOrWhiteSpace(txtNIC.Text))
                {
                    ShowAlert("NIC is required");
                    return;
                }

                if (string.IsNullOrWhiteSpace(MmberNo.Text) || MmberNo.Text.Trim() == "I-" || MmberNo.Text.Trim() == "I")
                {
                    ShowAlert("Member No is required");
                    return;
                }

                if (ddlMembershipTypeSelected.SelectedIndex <= 0)
                {
                    ShowAlert("Please select a Membership Type");
                    return;
                }

                bool isNonEarning = (ddlMembershipTypeSelected.SelectedValue == "9" || 
                                     ddlMembershipTypeSelected.SelectedItem.Text == "Non Earning MemberShip" ||
                                     txtFormTypeMain.Text.Trim() == "Non Earning MemberShip");

                if (isNonEarning && string.IsNullOrWhiteSpace(txtMainMemberNo.Text))
                {
                    ShowAlert("Main Member ID is required for Non Earning Membership!");
                    return;
                }

                // Check pending dues against selected FormType and FormTable
                decimal totalRequired = 0;
                decimal totalPaid = 0;
                decimal pendingDues = CheckPendingDues(out totalRequired, out totalPaid);

                if (pendingDues > 0)
                {
                    string formTypeName = txtFormTypeMain.Text.Trim();
                    string subTypeName = (ddlMembershipTypeSelected.SelectedIndex > 0 && ddlMembershipTypeSelected.SelectedItem != null)
                        ? ddlMembershipTypeSelected.SelectedItem.Text.Trim() : "";

                    string alertMsg = string.Format(
                        "Cannot proceed with Member Conversion.\\n\\nThis applicant has pending dues of Rs. {0:N0} against the selected Application Form Type ({1}) and Application Type ({2}).\\n\\nTotal Fee Required: Rs. {3:N0}\\nTotal Paid: Rs. {4:N0}\\nPending Dues: Rs. {0:N0}",
                        pendingDues,
                        string.IsNullOrEmpty(formTypeName) ? "N/A" : formTypeName,
                        string.IsNullOrEmpty(subTypeName) ? "N/A" : subTypeName,
                        totalRequired,
                        totalPaid
                    );

                    ShowAlert(alertMsg);
                    return;
                }

                ShowAlert("Processing... Please wait", false);

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    System.Diagnostics.Debug.WriteLine("Connection opened");
                    con.Open();

                    using (SqlTransaction tran = con.BeginTransaction())
                    {
                        try
                        {
                            // First, check if member already exists
                            using (SqlCommand checkCmd = new SqlCommand("usp_CheckMemberExistsByNIC", con, tran))
                            {
                                checkCmd.CommandType = CommandType.StoredProcedure;
                                checkCmd.Parameters.Add("@NIC", SqlDbType.NVarChar, 50).Value = txtNIC.Text.Trim();
                                int exists = (int)checkCmd.ExecuteScalar();
                                if (exists > 0)
                                {
                                    tran.Rollback();
                                    ShowAlert("Member with this NIC already exists!");
                                    return;
                                }
                            }

                            using (SqlCommand cmd = new SqlCommand("sp_InsertMember", con, tran))
                            {
                                cmd.CommandType = CommandType.StoredProcedure;
                                cmd.CommandTimeout = 120; // Increase timeout

                                // Add all parameters
                                cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = lblMemberPrefix.Text + "-" + MmberNo.Text.Trim();
                                cmd.Parameters.Add("@MemberType", SqlDbType.NVarChar, 50).Value = txtFormTypeMain.Text.Trim();
                                cmd.Parameters.Add("@MemberShipCategory", SqlDbType.VarChar, 50).Value = ddlMembershipTypeSelected.SelectedItem.Text;
                                cmd.Parameters.Add("@CatID", SqlDbType.Int).Value = Convert.ToInt32(ddlMembershipTypeSelected.SelectedValue);
                                cmd.Parameters.Add("@ApplicantName", SqlDbType.NVarChar, 100).Value = txtApplicantName.Text.Trim();
                                cmd.Parameters.Add("@NIC", SqlDbType.NVarChar, 20).Value = txtNIC.Text.Trim();
                                cmd.Parameters.Add("@FatherName", SqlDbType.NVarChar, 100).Value = string.IsNullOrWhiteSpace(txtFatherName.Text) ? (object)DBNull.Value : txtFatherName.Text.Trim();

                                DateTime dob;
                                cmd.Parameters.Add("@DOB", SqlDbType.Date).Value = DateTime.TryParse(txtDOB.Text, out dob) ? (object)dob : DBNull.Value;

                                cmd.Parameters.Add("@MaritalStatus", SqlDbType.NVarChar, 50).Value = string.IsNullOrWhiteSpace(txtMaritalStatus.Text) ? (object)DBNull.Value : txtMaritalStatus.Text.Trim();
                                cmd.Parameters.Add("@Profession", SqlDbType.NVarChar, 50).Value = string.IsNullOrWhiteSpace(txtProfession.Text) ? (object)DBNull.Value : txtProfession.Text.Trim();
                                cmd.Parameters.Add("@CompanyName", SqlDbType.NVarChar, 50).Value = string.IsNullOrWhiteSpace(txtCompanyName.Text) ? (object)DBNull.Value : txtCompanyName.Text.Trim();
                                cmd.Parameters.Add("@Designation", SqlDbType.NVarChar, 50).Value = string.IsNullOrWhiteSpace(txtDesignation.Text) ? (object)DBNull.Value : txtDesignation.Text.Trim();
                                cmd.Parameters.Add("@Nationality", SqlDbType.NVarChar, 100).Value = string.IsNullOrWhiteSpace(txtNationality.Text) ? (object)DBNull.Value : txtNationality.Text.Trim();

                                decimal income;
                                cmd.Parameters.Add("@MonthlyIncome", SqlDbType.Decimal).Value = decimal.TryParse(txtMonthlyIncome.Text, out income) ? (object)income : DBNull.Value;
                                cmd.Parameters.Add("@Currency", SqlDbType.NVarChar, 20).Value = string.IsNullOrWhiteSpace(txtCurrency.Text) ? (object)DBNull.Value : txtCurrency.Text.Trim();
                                cmd.Parameters.Add("@AddressType", SqlDbType.NVarChar, 20).Value = string.IsNullOrWhiteSpace(txtAddressType.Text) ? (object)DBNull.Value : txtAddressType.Text.Trim();
                                cmd.Parameters.Add("@Address", SqlDbType.NVarChar, 200).Value = string.IsNullOrWhiteSpace(txtAddress.Text) ? (object)DBNull.Value : txtAddress.Text.Trim();
                                cmd.Parameters.Add("@City", SqlDbType.NVarChar, 100).Value = string.IsNullOrWhiteSpace(txtCity.Text) ? (object)DBNull.Value : txtCity.Text.Trim();
                                cmd.Parameters.Add("@Province", SqlDbType.NVarChar, 100).Value = string.IsNullOrWhiteSpace(txtProvince.Text) ? (object)DBNull.Value : txtProvince.Text.Trim();
                                cmd.Parameters.Add("@Country", SqlDbType.NVarChar, 100).Value = string.IsNullOrWhiteSpace(txtCountry.Text) ? (object)DBNull.Value : txtCountry.Text.Trim();
                                cmd.Parameters.Add("@ZipCode", SqlDbType.NVarChar, 20).Value = string.IsNullOrWhiteSpace(txtZipCode.Text) ? (object)DBNull.Value : txtZipCode.Text.Trim();
                                cmd.Parameters.Add("@Phone", SqlDbType.NVarChar, 20).Value = string.IsNullOrWhiteSpace(txtPhone.Text) ? (object)DBNull.Value : txtPhone.Text.Trim();
                                cmd.Parameters.Add("@Mobile", SqlDbType.NVarChar, 20).Value = string.IsNullOrWhiteSpace(txtMobile.Text) ? (object)DBNull.Value : txtMobile.Text.Trim();
                                cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 50).Value = string.IsNullOrWhiteSpace(txtEmail.Text) ? (object)DBNull.Value : txtEmail.Text.Trim();
                                cmd.Parameters.Add("@Institute", SqlDbType.NVarChar, 100).Value = string.IsNullOrWhiteSpace(txtInstitute.Text) ? (object)DBNull.Value : txtInstitute.Text.Trim();
                                cmd.Parameters.Add("@Degree", SqlDbType.NVarChar, 50).Value = string.IsNullOrWhiteSpace(txtDegree.Text) ? (object)DBNull.Value : txtDegree.Text.Trim();
                                cmd.Parameters.Add("@Year", SqlDbType.NVarChar, 10).Value = string.IsNullOrWhiteSpace(txtYear.Text) ? (object)DBNull.Value : txtYear.Text.Trim();
                                cmd.Parameters.Add("@WorkExperience", SqlDbType.NVarChar, 200).Value = string.IsNullOrWhiteSpace(txtWorkExperience.Text) ? (object)DBNull.Value : txtWorkExperience.Text.Trim();
                                cmd.Parameters.Add("@AreaOfInterest", SqlDbType.NVarChar, 200).Value = string.IsNullOrWhiteSpace(txtAreaOfInterest.Text) ? (object)DBNull.Value : txtAreaOfInterest.Text.Trim();
                                cmd.Parameters.Add("@Facilities", SqlDbType.NVarChar, 200).Value = string.IsNullOrWhiteSpace(txtFacilities.Text) ? (object)DBNull.Value : txtFacilities.Text.Trim();
                                cmd.Parameters.Add("@OtherMemberships", SqlDbType.NVarChar, 200).Value = string.IsNullOrWhiteSpace(txtOtherMemberships.Text) ? (object)DBNull.Value : txtOtherMemberships.Text.Trim();
                                cmd.Parameters.Add("@PreferredNo", SqlDbType.NVarChar, 20).Value = string.IsNullOrWhiteSpace(txtPreferredNo.Text) ? (object)DBNull.Value : txtPreferredNo.Text.Trim();

                                decimal mfee;
                                cmd.Parameters.Add("@MFee", SqlDbType.Decimal).Value = decimal.TryParse(txtMFee.Text, out mfee) ? (object)mfee : DBNull.Value;
                                cmd.Parameters.Add("@ApplicantPhotoPath", SqlDbType.NVarChar, -1).Value = string.IsNullOrEmpty(hfApplicantPhotoPath.Value) ? (object)DBNull.Value : hfApplicantPhotoPath.Value;

                                // MemberProfile parameters
                                cmd.Parameters.Add("@SpouseName", SqlDbType.NVarChar, 100).Value = string.IsNullOrWhiteSpace(txtSpouseName.Text) ? (object)DBNull.Value : txtSpouseName.Text.Trim();
                                cmd.Parameters.Add("@SpouseProfession", SqlDbType.NVarChar, 100).Value = string.IsNullOrWhiteSpace(txtSpouseProfession.Text) ? (object)DBNull.Value : txtSpouseProfession.Text.Trim();
                                cmd.Parameters.Add("@SpouseEducation", SqlDbType.NVarChar, 100).Value = string.IsNullOrWhiteSpace(txtSpouseEducation.Text) ? (object)DBNull.Value : txtSpouseEducation.Text.Trim();
                                cmd.Parameters.Add("@OfficeAddress", SqlDbType.NVarChar, 255).Value = string.IsNullOrWhiteSpace(txtOfficeAddress.Text) ? (object)DBNull.Value : txtOfficeAddress.Text.Trim();
                                cmd.Parameters.Add("@OfficeCity", SqlDbType.NVarChar, 50).Value = string.IsNullOrWhiteSpace(txtOfficeCity.Text) ? (object)DBNull.Value : txtOfficeCity.Text.Trim();
                                cmd.Parameters.Add("@OfficeProvince", SqlDbType.NVarChar, 50).Value = string.IsNullOrWhiteSpace(txtOfficeProvince.Text) ? (object)DBNull.Value : txtOfficeProvince.Text.Trim();
                                cmd.Parameters.Add("@OfficeCountry", SqlDbType.NVarChar, 50).Value = string.IsNullOrWhiteSpace(txtOfficeCountry.Text) ? (object)DBNull.Value : txtOfficeCountry.Text.Trim();
                                cmd.Parameters.Add("@Proposer1", SqlDbType.NVarChar, 100).Value = string.IsNullOrWhiteSpace(txtProposer1.Text) ? (object)DBNull.Value : txtProposer1.Text.Trim();
                                cmd.Parameters.Add("@Relation1", SqlDbType.NVarChar, 50).Value = string.IsNullOrWhiteSpace(txtRelation1.Text) ? (object)DBNull.Value : txtRelation1.Text.Trim();
                                cmd.Parameters.Add("@Proposer2", SqlDbType.NVarChar, 100).Value = string.IsNullOrWhiteSpace(txtProposer2.Text) ? (object)DBNull.Value : txtProposer2.Text.Trim();
                                cmd.Parameters.Add("@Relation2", SqlDbType.NVarChar, 50).Value = string.IsNullOrWhiteSpace(txtRelation2.Text) ? (object)DBNull.Value : txtRelation2.Text.Trim();

                                int nChild;
                                cmd.Parameters.Add("@NoOfChildren", SqlDbType.Int).Value = int.TryParse(txtNoOfChildren.Text, out nChild) ? (object)nChild : DBNull.Value;
                                int nSons;
                                cmd.Parameters.Add("@NoOfSons", SqlDbType.Int).Value = int.TryParse(txtNoOfSons.Text, out nSons) ? (object)nSons : DBNull.Value;
                                int nDaughters;
                                cmd.Parameters.Add("@NoOfDaughters", SqlDbType.Int).Value = int.TryParse(txtNoOfDaughters.Text, out nDaughters) ? (object)nDaughters : DBNull.Value;
                                cmd.Parameters.Add("@SpouseCNIC", SqlDbType.NVarChar, 50).Value = string.IsNullOrWhiteSpace(txtSpouseCNIC.Text) ? (object)DBNull.Value : txtSpouseCNIC.Text.Trim();
                                cmd.Parameters.Add("@SpousePhone", SqlDbType.NVarChar, 50).Value = string.IsNullOrWhiteSpace(txtSpousePhone.Text) ? (object)DBNull.Value : txtSpousePhone.Text.Trim();

                                int nSpouse = string.IsNullOrWhiteSpace(txtSpouseName.Text) ? 0 : 1;
                                cmd.Parameters.Add("@NoOfSpouse", SqlDbType.Int).Value = nSpouse;

                                DateTime pDate;
                                cmd.Parameters.Add("@PurchaseDate", SqlDbType.DateTime).Value = DateTime.TryParse(hfPurchaseDate.Value, out pDate) ? (object)pDate : DBNull.Value;
                                cmd.Parameters.Add("@ReceiptNo", SqlDbType.NVarChar, 50).Value = string.IsNullOrWhiteSpace(hfReceiptNo.Value) ? (object)DBNull.Value : hfReceiptNo.Value;

                                // Log parameter count for debugging (removed string interpolation)
                                System.Diagnostics.Debug.WriteLine("Total parameters: " + cmd.Parameters.Count.ToString());

                                // Execute stored procedure
                                object result = cmd.ExecuteScalar();
                                System.Diagnostics.Debug.WriteLine("Stored procedure executed, result: " + (result != null ? result.ToString() : "null"));

                                int newMemberID = 0;
                                if (result != null && result != DBNull.Value)
                                {
                                    newMemberID = Convert.ToInt32(result);
                                }

                                if (newMemberID > 0)
                                {
                                    // Update AccountStatus and Status to Active in MemberProfile and Member tables
                                    using (SqlCommand cmdStatus = new SqlCommand("UPDATE MemberProfile SET AccountStatus = 'Active', Status = 'Active' WHERE MemberID = @MemberID; UPDATE Member SET Status = 'Active' WHERE MemberID = @MemberID;", con, tran))
                                    {
                                        cmdStatus.Parameters.Add("@MemberID", SqlDbType.Int).Value = newMemberID;
                                        cmdStatus.ExecuteNonQuery();
                                        System.Diagnostics.Debug.WriteLine("Updated MemberProfile and Member status to Active for MemberID: " + newMemberID);
                                    }

                                    // Update maininterview status
                                    using (SqlCommand cmdUpdate = new SqlCommand("usp_UpdateInterviewStatusToConverted", con, tran))
                                    {
                                        cmdUpdate.CommandType = CommandType.StoredProcedure;
                                        cmdUpdate.Parameters.Add("@NIC", SqlDbType.NVarChar, 50).Value = txtNIC.Text.Trim();
                                        int rowsAffected = cmdUpdate.ExecuteNonQuery();
                                        System.Diagnostics.Debug.WriteLine("Updated maininterview, rows affected: " + rowsAffected.ToString());
                                    }

                                    // Update ApplicationFForm status to Converted
                                    using (SqlCommand cmdUpdateFForm = new SqlCommand("UPDATE ApplicationFForm SET Status = 'Converted' WHERE REPLACE(NIC, '-', '') = REPLACE(@NIC, '-', '')", con, tran))
                                    {
                                        cmdUpdateFForm.Parameters.Add("@NIC", SqlDbType.NVarChar, 50).Value = txtNIC.Text.Trim();
                                        cmdUpdateFForm.ExecuteNonQuery();
                                        System.Diagnostics.Debug.WriteLine("Updated ApplicationFForm status to Converted for NIC: " + txtNIC.Text.Trim());
                                    }

                                    // Insert Spouse Info if available
                                    if (!string.IsNullOrWhiteSpace(txtSpouseName.Text))
                                    {
                                        string mainMemberNo = lblMemberPrefix.Text.Trim() + "-" + MmberNo.Text.Trim();
                                        string spouseMemNo = mainMemberNo + "-W";
                                        
                                        using (SqlCommand cmdCheckSpouse = new SqlCommand("SELECT COUNT(*) FROM MemberSpouses WHERE MemberID = @MemberID", con, tran))
                                        {
                                            cmdCheckSpouse.Parameters.Add("@MemberID", SqlDbType.Int).Value = newMemberID;
                                            int existingSpouseCount = (int)cmdCheckSpouse.ExecuteScalar();
                                            if (existingSpouseCount > 0)
                                            {
                                                spouseMemNo = mainMemberNo + "-W" + existingSpouseCount;
                                            }
                                        }

                                        using (SqlCommand cmdSpouse = new SqlCommand("usp_InsertMemberSpouse", con, tran))
                                        {
                                            cmdSpouse.CommandType = CommandType.StoredProcedure;
                                            cmdSpouse.Parameters.Add("@MemberID", SqlDbType.Int).Value = newMemberID;
                                            cmdSpouse.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = txtSpouseName.Text.Trim();
                                            cmdSpouse.Parameters.Add("@CNIC", SqlDbType.NVarChar, 50).Value = txtSpouseCNIC.Text.Trim();
                                            cmdSpouse.Parameters.Add("@Phone", SqlDbType.NVarChar, 50).Value = txtSpousePhone.Text.Trim();
                                            cmdSpouse.Parameters.Add("@Prof", SqlDbType.NVarChar, 100).Value = txtSpouseProfession.Text.Trim();
                                            cmdSpouse.Parameters.Add("@MemNo", SqlDbType.NVarChar, 50).Value = spouseMemNo;
                                            cmdSpouse.ExecuteNonQuery();
                                        }
                                    }

                                    // Insert Children Info if available
                                    int trackId = 0;
                                    using (SqlCommand cmdGetTrack = new SqlCommand("SELECT TrackID FROM ApplicationFForm WHERE REPLACE(NIC, '-', '') = REPLACE(@NIC, '-', '')", con, tran))
                                    {
                                        cmdGetTrack.Parameters.Add("@NIC", SqlDbType.NVarChar, 50).Value = txtNIC.Text.Trim();
                                        object objTrack = cmdGetTrack.ExecuteScalar();
                                        if (objTrack != null && objTrack != DBNull.Value)
                                        {
                                            trackId = Convert.ToInt32(objTrack);
                                        }
                                    }

                                    if (trackId > 0)
                                    {
                                        // Retrieve children from ApplicationChildren
                                        DataTable dtAppChildren = new DataTable();
                                        using (SqlCommand cmdApp = new SqlCommand("SELECT * FROM ApplicationChildren WHERE TrackID = @TrackID", con, tran))
                                        {
                                            cmdApp.Parameters.Add("@TrackID", SqlDbType.Int).Value = trackId;
                                            using (SqlDataAdapter daApp = new SqlDataAdapter(cmdApp))
                                            {
                                                daApp.Fill(dtAppChildren);
                                            }
                                        }

                                        if (dtAppChildren.Rows.Count > 0)
                                        {
                                            string mainMemberNo = lblMemberPrefix.Text.Trim() + "-" + MmberNo.Text.Trim();
                                            
                                            // Get starting indices based on existing children in MemberChildren
                                            int sonCount = 0;
                                            int daughterCount = 0;

                                            using (SqlCommand cmdCount = new SqlCommand("SELECT COUNT(*) FROM MemberChildren WHERE MemberID = @MemberID AND Relationship = 'Son'", con, tran))
                                            {
                                                cmdCount.Parameters.Add("@MemberID", SqlDbType.Int).Value = newMemberID;
                                                sonCount = (int)cmdCount.ExecuteScalar();
                                            }

                                            using (SqlCommand cmdCount = new SqlCommand("SELECT COUNT(*) FROM MemberChildren WHERE MemberID = @MemberID AND Relationship = 'Daughter'", con, tran))
                                            {
                                                cmdCount.Parameters.Add("@MemberID", SqlDbType.Int).Value = newMemberID;
                                                daughterCount = (int)cmdCount.ExecuteScalar();
                                            }

                                            foreach (DataRow row in dtAppChildren.Rows)
                                            {
                                                string childName = row["ChildName"].ToString().Trim();
                                                if (string.IsNullOrEmpty(childName)) continue;

                                                string rel = row["Relationship"] != null ? row["Relationship"].ToString().Trim() : "";
                                                string cnic = row["CNICNo"] != null ? row["CNICNo"].ToString().Trim() : "";
                                                DateTime? childDob = row["DOB"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(row["DOB"]) : null;

                                                // Normalize relationship
                                                if (rel.Equals("son", StringComparison.OrdinalIgnoreCase)) rel = "Son";
                                                else if (rel.Equals("daughter", StringComparison.OrdinalIgnoreCase)) rel = "Daughter";

                                                string childMemNo = "";
                                                if (rel == "Son")
                                                {
                                                    sonCount++;
                                                    childMemNo = mainMemberNo + "-S" + sonCount;
                                                }
                                                else if (rel == "Daughter")
                                                {
                                                    daughterCount++;
                                                    childMemNo = mainMemberNo + "-D" + daughterCount;
                                                }
                                                else
                                                {
                                                     childMemNo = mainMemberNo + "-C" + (sonCount + daughterCount + 1);
                                                }

                                                using (SqlCommand cmdInsert = new SqlCommand("usp_InsertMemberChild", con, tran))
                                                {
                                                    cmdInsert.CommandType = CommandType.StoredProcedure;
                                                    cmdInsert.Parameters.Add("@MemberID", SqlDbType.Int).Value = newMemberID;
                                                    cmdInsert.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = childName;
                                                    cmdInsert.Parameters.Add("@Rel", SqlDbType.NVarChar, 50).Value = rel;
                                                    cmdInsert.Parameters.Add("@CNIC", SqlDbType.NVarChar, 50).Value = cnic;
                                                    cmdInsert.Parameters.Add("@DOB", SqlDbType.DateTime).Value = (object)childDob ?? DBNull.Value;
                                                    cmdInsert.Parameters.Add("@MemNo", SqlDbType.NVarChar, 50).Value = childMemNo;
                                                    cmdInsert.ExecuteNonQuery();
                                                }
                                            }
                                        }
                                    }

                                    // Insert supplementary member if specified
                                    if (!string.IsNullOrEmpty(txtMainMemberNo.Text))
                                    {
                                        if (isNonEarning)
                                        {
                                            int existingMemberID = 0;
                                            using (SqlCommand cmdGetId = new SqlCommand("SELECT MemberID FROM MemberProfile WHERE MemberNo = @MemberNo", con, tran))
                                            {
                                                cmdGetId.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = txtMainMemberNo.Text.Trim();
                                                object objId = cmdGetId.ExecuteScalar();
                                                if (objId != null && objId != DBNull.Value)
                                                {
                                                    existingMemberID = Convert.ToInt32(objId);
                                                }
                                            }

                                            if (existingMemberID > 0)
                                            {
                                                using (SqlCommand cmdSupp = new SqlCommand("usp_InsertSupplementaryMember", con, tran))
                                                {
                                                    cmdSupp.CommandType = CommandType.StoredProcedure;
                                                    cmdSupp.Parameters.Add("@MemberID", SqlDbType.Int).Value = existingMemberID;
                                                    cmdSupp.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = txtApplicantName.Text.Trim();
                                                    cmdSupp.Parameters.Add("@Rel", SqlDbType.NVarChar, 100).Value = "Supplementary";
                                                    cmdSupp.Parameters.Add("@Val", SqlDbType.DateTime).Value = DBNull.Value;
                                                    cmdSupp.Parameters.Add("@MemNo", SqlDbType.NVarChar, 50).Value = lblMemberPrefix.Text + "-" + MmberNo.Text.Trim();
                                                    cmdSupp.ExecuteNonQuery();
                                                }
                                            }
                                            else
                                            {
                                                tran.Rollback();
                                                ShowAlert("Main Member not found with ID: " + txtMainMemberNo.Text);
                                                return;
                                            }
                                        }
                                        else
                                        {
                                            using (SqlCommand cmdSupp = new SqlCommand("usp_InsertSupplementaryMember", con, tran))
                                            {
                                                cmdSupp.CommandType = CommandType.StoredProcedure;
                                                cmdSupp.Parameters.Add("@MemberID", SqlDbType.Int).Value = newMemberID;
                                                cmdSupp.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = txtMainMemberName.Text.Trim();
                                                cmdSupp.Parameters.Add("@Rel", SqlDbType.NVarChar, 100).Value = "Supplementary";
                                                cmdSupp.Parameters.Add("@Val", SqlDbType.DateTime).Value = DBNull.Value;
                                                cmdSupp.Parameters.Add("@MemNo", SqlDbType.NVarChar, 50).Value = txtMainMemberNo.Text.Trim();
                                                cmdSupp.ExecuteNonQuery();
                                            }
                                        }
                                    }

                                    // Insert Fee Distribution records into Finance DB
                                    if (!string.IsNullOrEmpty(hfFeeDistributionJson.Value))
                                    {
                                        try
                                        {
                                            JavaScriptSerializer serializer = new JavaScriptSerializer();
                                            var feeItems = serializer.Deserialize<List<Dictionary<string, object>>>(hfFeeDistributionJson.Value);
                                            string memberNo = lblMemberPrefix.Text + "-" + MmberNo.Text.Trim();
                                            decimal totalMFee = 0;
                                            decimal.TryParse(txtMFee.Text.Trim().Replace(",", ""), out totalMFee);

                                            string financeConnStr = ConfigurationManager.ConnectionStrings["FinanceConnectionString"] != null
                                                ? ConfigurationManager.ConnectionStrings["FinanceConnectionString"].ConnectionString
                                                : (ConfigurationManager.ConnectionStrings["Finance_ConnectionString"] != null 
                                                    ? ConfigurationManager.ConnectionStrings["Finance_ConnectionString"].ConnectionString 
                                                    : "");

                                            using (SqlConnection finCon = new SqlConnection(financeConnStr))
                                            {
                                                finCon.Open();
                                                foreach (var item in feeItems)
                                                {
                                                    string headIdStr = "0";
                                                    string eCodeVal = "";
                                                    string headTypeVal = "";
                                                    decimal amountVal = 0;

                                                    foreach (var key in item.Keys)
                                                    {
                                                        if (key.Equals("HeadId", StringComparison.OrdinalIgnoreCase)) headIdStr = item[key] != null ? item[key].ToString() : "0";
                                                        else if (key.Equals("ECode", StringComparison.OrdinalIgnoreCase)) eCodeVal = item[key] != null ? item[key].ToString() : "";
                                                        else if (key.Equals("HeadType", StringComparison.OrdinalIgnoreCase)) headTypeVal = item[key] != null ? item[key].ToString() : "";
                                                        else if (key.Equals("Amount", StringComparison.OrdinalIgnoreCase)) decimal.TryParse(item[key] != null ? item[key].ToString().Replace(",", "") : "0", out amountVal);
                                                    }

                                                    int headId = 0;
                                                    int.TryParse(headIdStr, out headId);

                                                    using (SqlCommand cmdFee = new SqlCommand(
                                                        "INSERT INTO MemberFeeHeadDistribution (NIC, MemberNo, MemberID, HeadId, ECode, HeadType, Amount, TotalMFee) " +
                                                        "VALUES (@NIC, @MemberNo, @MemberID, @HeadId, @ECode, @HeadType, @Amount, @TotalMFee)", finCon))
                                                    {
                                                        cmdFee.Parameters.Add("@NIC", SqlDbType.NVarChar, 50).Value = txtNIC.Text.Trim();
                                                        cmdFee.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = memberNo;
                                                        cmdFee.Parameters.Add("@MemberID", SqlDbType.Int).Value = newMemberID;
                                                        cmdFee.Parameters.Add("@HeadId", SqlDbType.Int).Value = headId;
                                                        cmdFee.Parameters.Add("@ECode", SqlDbType.NVarChar, 50).Value = (object)eCodeVal ?? DBNull.Value;
                                                        cmdFee.Parameters.Add("@HeadType", SqlDbType.NVarChar, 150).Value = (object)headTypeVal ?? DBNull.Value;
                                                        cmdFee.Parameters.Add("@Amount", SqlDbType.Decimal).Value = amountVal;
                                                        cmdFee.Parameters.Add("@TotalMFee", SqlDbType.Decimal).Value = totalMFee;
                                                        cmdFee.ExecuteNonQuery();
                                                    }
                                                }
                                            }
                                            System.Diagnostics.Debug.WriteLine("Fee distribution saved: " + feeItems.Count + " records");
                                        }
                                        catch (Exception feeEx)
                                        {
                                            System.Diagnostics.Debug.WriteLine("Fee distribution error (non-fatal): " + feeEx.Message);
                                        }
                                    }

                                    tran.Commit();
                                    System.Diagnostics.Debug.WriteLine("Transaction committed successfully");

                                    string createdMemberNo = lblMemberPrefix.Text.Trim() + "-" + MmberNo.Text.Trim();
                                    string createdNIC = txtNIC.Text.Trim();

                                    // Clear fields on successful insertion
                                    ClearAllFields();

                                    // Hide the panel
                                    pnlApplicantDetails.Visible = false;

                                    // Refresh the grid if needed
                                    if (ddlMembershipType.SelectedIndex > 0)
                                    {
                                        btnSave_Click(null, null);
                                    }

                                    // Automatically open Fee Disbursement Report for the converted member
                                    string redirectScript = "alert('Member created successfully! Member No: " + createdMemberNo.Replace("'", "\\'") + "'); window.location.href='MemberFeeDisbursementReport.aspx?MemberNo=" + Server.UrlEncode(createdMemberNo) + "&NIC=" + Server.UrlEncode(createdNIC) + "&Converted=1';";
                                    ScriptManager.RegisterStartupScript(this, GetType(), "MemberCreatedRedirect", redirectScript, true);
                                    return;
                                }
                                else
                                {
                                    tran.Rollback();
                                    ShowAlert("Failed to create member. No Member ID was returned.");
                                }
                            }
                        }
                        catch (SqlException sqlEx)
                        {
                            tran.Rollback();
                            System.Diagnostics.Debug.WriteLine("SQL Error: " + sqlEx.Message);
                            System.Diagnostics.Debug.WriteLine("SQL Error Number: " + sqlEx.Number.ToString());
                            ShowAlert("Database Error: " + sqlEx.Message);
                            throw;
                        }
                        catch (Exception ex)
                        {
                            tran.Rollback();
                            System.Diagnostics.Debug.WriteLine("General Error: " + ex.Message);
                            System.Diagnostics.Debug.WriteLine("Stack Trace: " + ex.StackTrace);
                            ShowAlert("Error: " + ex.Message);
                            throw;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Outer catch: " + ex.Message);
                ShowAlert("Error during insertion: " + ex.Message);
            }
        }

        // Helper method to show alerts consistently
        private void ShowAlert(string message, bool isError = true)
        {
            string script = "alert('" + message.Replace("'", "\\'") + "');";
            ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(), script, true);
        }

        private void ClearAllFields()
        {
            // Clear all textboxes
            txtApplicantName.Text = "";
            txtFatherName.Text = "";
            txtMainMemberNo.Text = "";
            txtMainMemberName.Text = "";
            txtDOB.Text = "";
            txtNIC.Text = "";
            txtMaritalStatus.Text = "";
            txtProfession.Text = "";
            txtCompanyName.Text = "";
            txtDesignation.Text = "";
            txtNationality.Text = "";
            txtMonthlyIncome.Text = "";
            txtCurrency.Text = "";
            txtAddressType.Text = "";
            txtAddress.Text = "";
            txtCity.Text = "";
            txtProvince.Text = "";
            txtCountry.Text = "";
            txtZipCode.Text = "";
            txtPhone.Text = "";
            txtMobile.Text = "";
            txtEmail.Text = "";
            txtInstitute.Text = "";
            txtDegree.Text = "";
            txtYear.Text = "";
            txtWorkExperience.Text = "";
            txtAreaOfInterest.Text = "";
            txtFacilities.Text = "";
            txtOtherMemberships.Text = "";
            txtPreferredNo.Text = "";
            txtMFee.Text = "";
            txtSpouseName.Text = "";
            txtSpouseProfession.Text = "";
            txtSpouseEducation.Text = "";
            txtSpouseCNIC.Text = "";
            txtSpousePhone.Text = "";
            txtOfficeAddress.Text = "";
            txtOfficeCity.Text = "";
            txtOfficeProvince.Text = "";
            txtOfficeCountry.Text = "";
            txtProposer1.Text = "";
            txtRelation1.Text = "";
            txtProposer2.Text = "";
            txtRelation2.Text = "";
            txtNoOfChildren.Text = "";
            txtNoOfSons.Text = "";
            txtNoOfDaughters.Text = "";
            txtFormTypeMain.Text = "";
            txtInterviewerName.Text = "";

            // Clear hidden fields
            hfApplicantPhotoPath.Value = "";
            hfPurchaseDate.Value = "";
            hfReceiptNo.Value = "";
            hfFeeDistributionJson.Value = "";

            // Reset dropdown
            if (ddlMembershipTypeSelected.Items.Count > 0)
                ddlMembershipTypeSelected.SelectedIndex = 0;

            // Clear member prefix and number
            lblMemberPrefix.Text = "Prefix";
            MmberNo.Text = "";

            // Clear children grid
            gvChildren.DataSource = null;
            gvChildren.DataBind();
        }

        private string GenerateUniqueMemberNo()
        {
            string memberNo;
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                do
                {
                    memberNo = "I" + DateTime.Now.ToString("yyyyMMddHHmmss");
                    using (SqlCommand cmd = new SqlCommand("usp_CheckMemberExistsByNo", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = memberNo;
                        int count = (int)cmd.ExecuteScalar();
                        if (count == 0)
                            break;
                    }
                } while (true);
            }
            return memberNo;
        }
        private decimal CheckPendingDues(out decimal totalRequired, out decimal totalPaid)
        {
            totalRequired = 0;
            totalPaid = 0;

            try
            {
                string formTypeMainName = txtFormTypeMain.Text.Trim();
                string subTypeName = (ddlMembershipTypeSelected.SelectedIndex > 0 && ddlMembershipTypeSelected.SelectedItem != null)
                    ? ddlMembershipTypeSelected.SelectedItem.Text.Trim() : "";

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    string query = @"
                        SELECT TOP 1 
                            CASE 
                                WHEN ISNULL(TotalAmount, 0) > 0 THEN TotalAmount 
                                ELSE (ISNULL(Price, 0) + ISNULL(EntranceFee, 0) + ISNULL(ExtraCharges, 0)) 
                            END AS TotalFeeRequired
                        FROM FormTable
                        WHERE 
                            (
                                (@SubTypeName <> '' AND (FormTypeName = @SubTypeName OR FormTypeName = @FormTypeMainName))
                                OR 
                                (@FormTypeMainName <> '' AND (FormTypeName = @FormTypeMainName OR FormTypeName = @SubTypeName))
                            )
                        ORDER BY 
                            CASE WHEN @SubTypeName <> '' AND FormTypeName = @SubTypeName THEN 0 
                                 WHEN @FormTypeMainName <> '' AND FormTypeName = @FormTypeMainName THEN 1 
                                 ELSE 2 END,
                            CASE WHEN ISNULL(status, 1) = 1 THEN 0 ELSE 1 END,
                            id DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@FormTypeMainName", SqlDbType.NVarChar, 200).Value = formTypeMainName;
                        cmd.Parameters.Add("@SubTypeName", SqlDbType.NVarChar, 200).Value = subTypeName;

                        object res = cmd.ExecuteScalar();
                        if (res != null && res != DBNull.Value)
                        {
                            totalRequired = Convert.ToDecimal(res);
                        }
                    }

                    // Calculate Paid Amount for this applicant using valid schema columns (TrackId in MemberFee, CNIC in FormPurchase)
                    string nic = txtNIC.Text.Trim();
                    string paidQuery = @"
                        SELECT ISNULL(SUM(Amount), 0) FROM (
                            SELECT ISNULL(MemberFee, 0) AS Amount FROM MemberFee WHERE TrackId IN (SELECT TrackID FROM ApplicationFForm WHERE REPLACE(NIC, '-', '') = REPLACE(@NIC, '-', ''))
                            UNION ALL
                            SELECT ISNULL(Price, 0) + ISNULL(MemberFee, 0) AS Amount FROM FormPurchase WHERE REPLACE(CNIC, '-', '') = REPLACE(@NIC, '-', '')
                        ) T";

                    using (SqlCommand cmdPaid = new SqlCommand(paidQuery, conn))
                    {
                        cmdPaid.Parameters.Add("@NIC", SqlDbType.NVarChar, 50).Value = nic;
                        object resPaid = cmdPaid.ExecuteScalar();
                        if (resPaid != null && resPaid != DBNull.Value)
                        {
                            totalPaid = Convert.ToDecimal(resPaid);
                        }
                    }
                }

                decimal mfeeTxt = 0;
                decimal.TryParse(txtMFee.Text.Trim().Replace(",", ""), out mfeeTxt);
                if (mfeeTxt > totalPaid)
                {
                    totalPaid = mfeeTxt;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("CheckPendingDues error: " + ex.Message);
            }

            decimal pending = totalRequired - totalPaid;
            return pending > 0 ? pending : 0;
        }
    }
}