using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Web.Services;
using System.Linq;

namespace Membership
{
    public partial class MemberProfile : System.Web.UI.Page
    {
        private string connectionString
        {
            get
            {
                var s = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
                return s != null ? s.ConnectionString : "";
            }
        }
        private int _queryStringMemberId = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtMemberSince.Text = DateTime.Now.ToString("dd-MM-yyyy");

                BindDropdowns();
                LoadProposers();
                InitializeSpousesGrid();
                InitializeChildrenGrid();
                InitializeVehiclesGrid();
                InitializeSupplementaryGrid();
                InitializeClubsGrid();

                if (Request.QueryString["MemberID"] != null)
                {
                    int.TryParse(Request.QueryString["MemberID"], out _queryStringMemberId);

                    if (_queryStringMemberId > 0)
                    {
                        LoadMember(_queryStringMemberId);
                        LoadMemberData(_queryStringMemberId);
                        LoadMemberBalance(_queryStringMemberId);

                        // Ensure we have a NIC to work with
                        string memberNIC = txtNIC.Text.Trim();
                        if (string.IsNullOrEmpty(memberNIC))
                        {
                            memberNIC = GetMemberNIC(_queryStringMemberId);
                            if (!string.IsNullOrEmpty(memberNIC)) txtNIC.Text = memberNIC;
                        }

                        // Always try to load/refresh from Application Form on page load if we have a NIC
                        if (!string.IsNullOrEmpty(memberNIC))
                        {
                            LoadFromApplicationForm(memberNIC, true);
                        }

                        if (!string.IsNullOrEmpty(hdnMemberID.Value) && hdnMemberID.Value != "0")
                        {
                            SetFormReadOnly(this.Controls, true);
                            btnSave.Visible = false;
                            btnUpdate.Visible = true;
                            btnUpdate.Text = "Update";
                            ViewState["IsEditing"] = false;
                        }
                        else
                        {
                            btnSave.Visible = true;
                            btnUpdate.Visible = false;
                        }

                        upMain.Update();
                    }
                }
            }
            else
            {
                // Restore ViewState for GridViews
                RestoreGridViewData();
            }
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            lblMemberNoTop.Text = txtMemberNo.Text;
            lblMemberNameTop.Text = txtMemberName.Text;
        }

        private void RestoreGridViewData()
        {
            RestoreGridFromViewState(gvSpouses, "SpousesData");
            RestoreGridFromViewState(gvChildren, "ChildrenData");
            RestoreGridFromViewState(gvVehicles, "VehiclesData");

            RestoreGridFromViewState(gvSupplementary, "SupplementaryData");
            RestoreGridFromViewState(gvClubs, "ClubsData");
        }

        private void RestoreGridFromViewState(GridView gv, string viewStateKey)
        {
            if (gv == null) return;
            if (ViewState[viewStateKey] != null)
            {
                DataTable dt = ViewState[viewStateKey] as DataTable;
                if (dt != null && dt.Rows.Count > 0)
                {
                    // Only restore when the grid has no rows yet (i.e., ViewState didn't re-populate it).
                    // Do NOT check gv.DataSource == null � it is always null after a ViewState restore,
                    // which would cause us to re-bind old data and overwrite user edits in grid TextBoxes.
                    if (gv.Rows.Count == 0)
                    {
                        gv.DataSource = dt;
                        gv.DataBind();
                    }
                }
            }
        }

        // Helper method to get existing MemberProfile ID
        private int GetExistingMemberProfileId(int queryStringMemberId)
        {
            string sql = "SELECT MemberID FROM MemberProfile WHERE M_ID = @M_ID";
            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@M_ID", SqlDbType.Int).Value = queryStringMemberId;
                conn.Open();
                object result = cmd.ExecuteScalar();
                return result != null ? Convert.ToInt32(result) : 0;
            }
        }

        // Helper method to get QueryString MemberID
        private int GetQueryStringMemberID()
        {
            return _queryStringMemberId;
        }

        private string GetMemberNIC(int memberId)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string sql = "SELECT NIC FROM Member WHERE MemberID = @MemberID";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    return result != null ? result.ToString() : string.Empty;
                }
            }
        }

        // Helper method to get M_Id parameter value
        private object GetM_IdParameter()
        {
            int queryStringMemberId = GetQueryStringMemberID();
            return queryStringMemberId > 0 ? (object)queryStringMemberId : DBNull.Value;
        }

        private string GetBaseMemberNo(string memberNo)
        {
            if (string.IsNullOrEmpty(memberNo)) return memberNo;
            int dashIndex = memberNo.LastIndexOf('-');
            if (dashIndex > 0)
            {
                string suffix = memberNo.Substring(dashIndex);
                if (suffix == "-W" || suffix == "-S" || suffix == "-D" || suffix == "-C")
                {
                    return memberNo.Substring(0, dashIndex);
                }
            }
            return memberNo;
        }

        protected void txtNIC_TextChanged(object sender, EventArgs e)
        {
            string nic = txtNIC.Text.Trim();
            if (string.IsNullOrEmpty(nic)) return;

            // Only auto-load if it's a new profile (hdnMemberID is 0 or empty)
            if (string.IsNullOrEmpty(hdnMemberID.Value) || hdnMemberID.Value == "0")
            {
                LoadFromApplicationForm(nic, false);
            }
        }

        protected void txtProposer1MemberNo_TextChanged(object sender, EventArgs e)
        {
            string memberNo = txtProposer1MemberNo.Text.Trim();
            if (!string.IsNullOrEmpty(memberNo))
            {
                txtProposer1.Text = GetMemberNameByNo(memberNo);
                upMain.Update();
            }
        }

        protected void txtProposer2MemberNo_TextChanged(object sender, EventArgs e)
        {
            string memberNo = txtProposer2MemberNo.Text.Trim();
            if (!string.IsNullOrEmpty(memberNo))
            {
                txtProposer2.Text = GetMemberNameByNo(memberNo);
                upMain.Update();
            }
        }

        private string GetMemberNameByNo(string memberNo)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string sql = "SELECT MemberName FROM MemberProfile WHERE MemberNo = @MemberNo";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = memberNo;
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    return result != null ? result.ToString() : string.Empty;
                }
            }
        }

        private void LoadProposers()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string sql = "SELECT DISTINCT MemberNo, MemberName FROM MemberProfile WHERE MemberNo IS NOT NULL AND MemberNo <> ''";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptProposers.DataSource = dt;
                        rptProposers.DataBind();
                    }
                }
            }
        }

        private void LoadFromApplicationForm(string nic, bool isPageLoad)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                // 1. First search in ApplicationFForm
                string queryApp = "SELECT * FROM ApplicationFForm WHERE REPLACE(NIC, '-', '') = REPLACE(@NIC, '-', '')";
                using (SqlCommand cmd = new SqlCommand(queryApp, con))
                {
                    cmd.Parameters.Add("@NIC", SqlDbType.NVarChar, 50).Value = nic;
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            PopulateFromApplicationReader(dr);
                            int trackId = Convert.ToInt32(dr["TrackID"]);
                            dr.Close();

                            if (!isPageLoad)
                                ShowMessageAjax("success", "Data auto-loaded from Application Form (Track ID: " + trackId + ")");
                            return;
                        }
                    }
                }

                // 2. Fallback to Member table if not found in Application Form (Only on manual entry/search)
                if (!isPageLoad)
                {
                    string queryMember = "SELECT * FROM Member WHERE REPLACE(NIC, '-', '') = REPLACE(@NIC, '-', '')";
                    using (SqlCommand cmd = new SqlCommand(queryMember, con))
                    {
                        cmd.Parameters.Add("@NIC", SqlDbType.NVarChar, 50).Value = nic;
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                int memberId = Convert.ToInt32(dr["MemberID"]);
                                PopulateFromMemberReader(dr);
                                dr.Close();

                                // Load children from MemberChildren table
                                LoadChildrenData(memberId);

                                // Try fallback to Application for spouse/children if not in member tables
                                LoadAdditionalInfoFromApplication(nic, con);

                                ShowMessageAjax("success", "Data auto-loaded from Member Table (Member No: " + txtMemberNo.Text + ")");
                                return;
                            }
                        }
                    }
                }
            }
            if (!isPageLoad) upMain.Update();
        }

        private void LoadAdditionalInfoFromApplication(string nic, SqlConnection con)
        {
            string appQuery = @"SELECT TrackID, SpouseName, SpouseCNIC, SpousePhone, NoOfSpouse, NoOfSons, NoOfDaughters 
                               FROM ApplicationFForm 
                               WHERE REPLACE(NIC, '-', '') = REPLACE(@NIC, '-', '')";
            using (SqlCommand cmdApp = new SqlCommand(appQuery, con))
            {
                cmdApp.Parameters.Add("@NIC", SqlDbType.NVarChar, 50).Value = nic;
                using (SqlDataReader drApp = cmdApp.ExecuteReader())
                {
                    if (drApp.Read())
                    {
                        string sName = drApp["SpouseName"].ToString();
                        if (!string.IsNullOrEmpty(sName) && gvSpouses.Rows.Count == 0)
                        {
                            DataTable dtSpouses = ViewState["SpousesData"] as DataTable ?? GetSpousesTable();
                            DataRow sRow = dtSpouses.NewRow();
                            sRow["SpouseName"] = sName;
                            sRow["SpouseCNIC"] = drApp["SpouseCNIC"].ToString();
                            sRow["SpousePhone"] = drApp["SpousePhone"].ToString();
                            sRow["SpouseProfession"] = "";
                            sRow["SpouseEducation"] = "";
                            string mainNo = txtMemberNo.Text.Trim();
                            sRow["MembershipNo"] = !string.IsNullOrEmpty(mainNo) ? mainNo + "-W" : "";
                            sRow["RecordStatus"] = "Active";
                            sRow["Remarks"] = "";
                            dtSpouses.Rows.Add(sRow);

                            ViewState["SpousesData"] = dtSpouses;
                            gvSpouses.DataSource = dtSpouses;
                            gvSpouses.DataBind();
                            UpdateSpousesCount();
                        }


                    }
                }
            }
        }

        private void PopulateFromApplicationReader(SqlDataReader dr)
        {
            if (HasColumn(dr, "Prefix") && dr["Prefix"] != DBNull.Value)
                SafeSetSelectedValue(ddlTitle, dr["Prefix"].ToString());

            if (HasColumn(dr, "ApplicantName")) txtMemberName.Text = dr["ApplicantName"].ToString();
            if (HasColumn(dr, "FatherName")) txtFatherName.Text = dr["FatherName"].ToString();
            if (HasColumn(dr, "DOB") && dr["DOB"] != DBNull.Value)
                txtDOB.Text = Convert.ToDateTime(dr["DOB"]).ToString("dd-MM-yyyy");

            if (HasColumn(dr, "MaritalStatus") && dr["MaritalStatus"] != DBNull.Value)
                SafeSetSelectedValue(ddlMaritalStatus, dr["MaritalStatus"].ToString());

            if (HasColumn(dr, "Profession")) txtOccupation.Text = dr["Profession"].ToString();
            if (HasColumn(dr, "CompanyName")) txtCompanyName.Text = dr["CompanyName"].ToString();
            if (HasColumn(dr, "Designation")) txtDesignation.Text = dr["Designation"].ToString();

            if (HasColumn(dr, "Nationality") && dr["Nationality"] != DBNull.Value)
                SafeSetSelectedValue(ddlNationality, dr["Nationality"].ToString());

            if (HasColumn(dr, "MonthlyIncome")) txtMonthlyIncome.Text = dr["MonthlyIncome"].ToString();

            if (HasColumn(dr, "MemberShipCategory") && dr["MemberShipCategory"] != DBNull.Value)
            {
                txtMemberCategory.Text = dr["MemberShipCategory"].ToString();
            }

            if (HasColumn(dr, "Membership_class") && dr["Membership_class"] != DBNull.Value)
            {
                txtMemberType.Text = dr["Membership_class"].ToString();
            }

            if (HasColumn(dr, "Address"))
            {
                string address = dr["Address"].ToString();
                txtResidentialAddress1.Text = address;
                txtMailingAddress1.Text = address;
            }
            if (HasColumn(dr, "City"))
            {
                txtResidentialCity.Text = dr["City"].ToString();
                txtMailingCity.Text = dr["City"].ToString();
            }

            if (HasColumn(dr, "Country"))
            {
                string country = dr["Country"].ToString();
                txtResidentialCountry.Text = country;
                txtMailingCountry.Text = country;
            }

            if (HasColumn(dr, "Province"))
            {
                txtResidentialAddress2.Text = dr["Province"].ToString();
                txtMailingAddress2.Text = dr["Province"].ToString();
            }

            if (HasColumn(dr, "Phone"))
            {
                txtResidentialPhone1.Text = dr["Phone"].ToString();
                txtMailingPhone.Text = dr["Phone"].ToString();
            }
            if (HasColumn(dr, "Mobile")) txtResidentialMobile.Text = dr["Mobile"].ToString();
            if (HasColumn(dr, "Email"))
            {
                txtResidentialEmail.Text = dr["Email"].ToString();
                txtMailingEmail.Text = dr["Email"].ToString();
            }

            if (HasColumn(dr, "Degree"))
            {
                txtEducation.Text = dr["Degree"].ToString() + (HasColumn(dr, "Institute") && dr["Institute"] != DBNull.Value ? " from " + dr["Institute"].ToString() : "");
            }
            if (HasColumn(dr, "Facilities")) txtInterestFacilities.Text = dr["Facilities"].ToString();

            if (HasColumn(dr, "Proposer1")) 
                txtProposer1.Text = dr["Proposer1"].ToString();
                
            if (HasColumn(dr, "Proposer1MemberNo"))
            {
                string p1No = dr["Proposer1MemberNo"].ToString();
                txtProposer1MemberNo.Text = p1No;
                if (!string.IsNullOrEmpty(p1No))
                {
                    string fetchedName = GetMemberNameByNo(p1No);
                    if (!string.IsNullOrEmpty(fetchedName))
                    {
                        txtProposer1.Text = fetchedName;
                    }
                }
            }

            if (HasColumn(dr, "Proposer2")) 
                txtProposer2.Text = dr["Proposer2"].ToString();
                
            if (HasColumn(dr, "Proposer2MemberNo"))
            {
                string p2No = dr["Proposer2MemberNo"].ToString();
                txtProposer2MemberNo.Text = p2No;
                if (!string.IsNullOrEmpty(p2No))
                {
                    string fetchedName = GetMemberNameByNo(p2No);
                    if (!string.IsNullOrEmpty(fetchedName))
                    {
                        txtProposer2.Text = fetchedName;
                    }
                }
            }
            if (HasColumn(dr, "OtherMemberships")) txtOtherMemberships.Text = dr["OtherMemberships"].ToString();

            if (HasColumn(dr, "SpouseName"))
            {
                string sName = dr["SpouseName"].ToString();
                if (!string.IsNullOrEmpty(sName) && gvSpouses.Rows.Count == 0)
                {
                    DataTable dtSpouses = ViewState["SpousesData"] as DataTable ?? GetSpousesTable();
                    string sCNIC = HasColumn(dr, "SpouseCNIC") ? dr["SpouseCNIC"].ToString() : "";
                    string sPhone = HasColumn(dr, "SpousePhone") ? dr["SpousePhone"].ToString() : "";
                    
                    DataRow sRow = dtSpouses.NewRow();
                    sRow["SpouseName"] = sName;
                    sRow["SpouseCNIC"] = sCNIC;
                    sRow["SpousePhone"] = sPhone;
                    sRow["SpouseProfession"] = "";
                    sRow["SpouseEducation"] = "";
                    string mainNo = txtMemberNo.Text.Trim();
                    sRow["MembershipNo"] = !string.IsNullOrEmpty(mainNo) ? mainNo + "-W" : "";
                    sRow["RecordStatus"] = "Active";
                    sRow["Remarks"] = "";
                    dtSpouses.Rows.Add(sRow);

                    ViewState["SpousesData"] = dtSpouses;
                    gvSpouses.DataSource = dtSpouses;
                    gvSpouses.DataBind();
                    UpdateSpousesCount();
                }
            }
        }

        private void PopulateFromMemberReader(SqlDataReader dr)
        {
            if (HasColumn(dr, "ApplicantName")) txtMemberName.Text = dr["ApplicantName"].ToString();
            if (HasColumn(dr, "FatherName")) txtFatherName.Text = dr["FatherName"].ToString();
            if (HasColumn(dr, "DOB") && dr["DOB"] != DBNull.Value)
                txtDOB.Text = Convert.ToDateTime(dr["DOB"]).ToString("dd-MM-yyyy");

            if (HasColumn(dr, "CreatedAt") && dr["CreatedAt"] != DBNull.Value)
                txtMemberSince.Text = Convert.ToDateTime(dr["CreatedAt"]).ToString("dd-MM-yyyy");

            if (HasColumn(dr, "MaritalStatus") && dr["MaritalStatus"] != DBNull.Value)
                SafeSetSelectedValue(ddlMaritalStatus, dr["MaritalStatus"].ToString());

            if (HasColumn(dr, "Profession")) txtOccupation.Text = dr["Profession"].ToString();
            if (HasColumn(dr, "CompanyName")) txtCompanyName.Text = dr["CompanyName"].ToString();
            if (HasColumn(dr, "Designation")) txtDesignation.Text = dr["Designation"].ToString();

            if (HasColumn(dr, "Nationality") && dr["Nationality"] != DBNull.Value)
                SafeSetSelectedValue(ddlNationality, dr["Nationality"].ToString());

            if (HasColumn(dr, "MonthlyIncome")) txtMonthlyIncome.Text = dr["MonthlyIncome"].ToString();

            if (HasColumn(dr, "MemberShipCategory") && dr["MemberShipCategory"] != DBNull.Value)
            {
                txtMemberCategory.Text = dr["MemberShipCategory"].ToString();
            }

            if (HasColumn(dr, "MemberShipCategory") && dr["MemberShipCategory"] != DBNull.Value)
            {
                txtMemberType.Text = dr["MemberShipCategory"].ToString();
            }

            if (HasColumn(dr, "Address"))
            {
                string address = dr["Address"].ToString();
                txtResidentialAddress1.Text = address;
                txtMailingAddress1.Text = address;
            }
            if (HasColumn(dr, "City"))
            {
                txtResidentialCity.Text = dr["City"].ToString();
                txtMailingCity.Text = dr["City"].ToString();
            }

            if (HasColumn(dr, "Country"))
            {
                string country = dr["Country"].ToString();
                txtResidentialCountry.Text = country;
                txtMailingCountry.Text = country;
            }

            if (HasColumn(dr, "Phone"))
            {
                txtResidentialPhone1.Text = dr["Phone"].ToString();
                txtMailingPhone.Text = dr["Phone"].ToString();
            }
            if (HasColumn(dr, "Mobile")) txtResidentialMobile.Text = dr["Mobile"].ToString();
            if (HasColumn(dr, "Email"))
            {
                txtResidentialEmail.Text = dr["Email"].ToString();
                txtMailingEmail.Text = dr["Email"].ToString();
            }

            if (HasColumn(dr, "Degree"))
            {
                txtEducation.Text = dr["Degree"].ToString() + (HasColumn(dr, "Institute") && dr["Institute"] != DBNull.Value ? " from " + dr["Institute"].ToString() : "");
            }
            if (HasColumn(dr, "Facilities")) txtInterestFacilities.Text = dr["Facilities"].ToString();
            if (HasColumn(dr, "OtherMemberships")) txtOtherMemberships.Text = dr["OtherMemberships"].ToString();
        }


        private void LoadMember(int memberId)
        {
            string cs = this.connectionString;

            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();
                string query = @"SELECT * FROM Member WHERE MemberID=@MemberID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            // Basic Info
                            txtMemberNo.Text = dr["MemberNo"].ToString();
                            txtMemberName.Text = dr["ApplicantName"].ToString();
                            txtFatherName.Text = dr["FatherName"].ToString();

                            if (dr["DOB"] != DBNull.Value)
                                txtDOB.Text = Convert.ToDateTime(dr["DOB"]).ToString("dd-MM-yyyy");

                            if (dr["CreatedAt"] != DBNull.Value)
                                txtMemberSince.Text = Convert.ToDateTime(dr["CreatedAt"]).ToString("dd-MM-yyyy");

                            txtNIC.Text = dr["NIC"].ToString();

                            // Auto-fill other fields from Member table
                            if (dr["MemberType"] != DBNull.Value)
                                txtMemberCategory.Text = dr["MemberShipCategory"].ToString();

                            if (dr["MemberShipCategory"] != DBNull.Value)
                                txtMemberType.Text = dr["MemberShipCategory"].ToString();
                            SafeSetSelectedValue(ddlMaritalStatus, dr["MaritalStatus"].ToString());
                            txtOccupation.Text = dr["Profession"].ToString();
                            txtCompanyName.Text = dr["CompanyName"].ToString();
                            txtDesignation.Text = dr["Designation"].ToString();
                            SafeSetSelectedValue(ddlNationality, dr["Nationality"].ToString());
                            txtMonthlyIncome.Text = dr["MonthlyIncome"].ToString();

                            // Address Mapping (Assuming Member Address maps to Residential)
                            string address = dr["Address"].ToString();
                            txtResidentialAddress1.Text = address;
                            txtMailingAddress1.Text = address; // Default mailing to residential

                            txtResidentialCity.Text = dr["City"].ToString();
                            txtMailingCity.Text = dr["City"].ToString();

                            // Map Country
                            string country = dr["Country"].ToString();
                            txtResidentialCountry.Text = country;
                            txtMailingCountry.Text = country;

                            txtResidentialPhone1.Text = dr["Phone"].ToString();
                            txtMailingPhone.Text = dr["Phone"].ToString();
                            txtResidentialMobile.Text = dr["Mobile"].ToString();
                            txtResidentialEmail.Text = dr["Email"].ToString();
                            txtMailingEmail.Text = dr["Email"].ToString();

                            // Educational / Professional
                            txtEducation.Text = dr["Degree"].ToString() + " from " + dr["Institute"].ToString();
                            // txtWorkExperience.Text = dr["WorkExperience"].ToString(); // Control does not exist yet
                            txtInterestFacilities.Text = dr["Facilities"].ToString();
                            txtOtherMemberships.Text = dr["OtherMemberships"].ToString();

                            // Read-only specific fields that are 'Fixed' identity
                            txtMemberNo.ReadOnly = true;
                            // txtMemberName.ReadOnly = true; // Allow editing name for corrections?
                            // txtFatherName.ReadOnly = true;
                            txtDOB.ReadOnly = true;
                            // txtNIC.ReadOnly = true;

                            // Membership Fee
                            if (dr["MFee"] != DBNull.Value)
                            {
                                // Auto-set some billing info if needed?
                                // txtJoiningFee.Text = dr["MFee"].ToString();
                            }
                        }
                        else
                        {
                            ShowMessage("error", "No member found with ID: " + memberId);
                        }
                    }
                }
            }

            int profileId = GetExistingMemberProfileId(memberId);
            if (profileId > 0)
            {
                // Get spouse details from MemberSpouses
                LoadSpousesData(profileId);
                
                // Get children details from MemberChildren
                LoadChildrenData(profileId);
            }
            else
            {
                // Fallback: Load Spouse Info from ApplicationFForm (since Member table doesn't have spouse columns)
                using (SqlConnection con2 = new SqlConnection(cs))
                {
                    con2.Open();
                    string spouseQuery = @"SELECT SpouseName, SpouseCNIC, SpousePhone, NoOfSpouse, NoOfSons, NoOfDaughters 
                                           FROM ApplicationFForm 
                                           WHERE REPLACE(NIC, '-', '') = REPLACE(@NIC, '-', '')";
                    using (SqlCommand cmdSpouse = new SqlCommand(spouseQuery, con2))
                    {
                        cmdSpouse.Parameters.Add("@NIC", SqlDbType.NVarChar, 50).Value = txtNIC.Text.Trim();
                        using (SqlDataReader drSpouse = cmdSpouse.ExecuteReader())
                        {
                            if (drSpouse.Read())
                            {
                                if (drSpouse["SpouseName"] != DBNull.Value)
                                {
                                    string sName = drSpouse["SpouseName"].ToString();
                                    if (!string.IsNullOrEmpty(sName) && gvSpouses.Rows.Count == 0)
                                    {
                                        DataTable dtSpouses = ViewState["SpousesData"] as DataTable ?? GetSpousesTable();
                                        string sCNIC = drSpouse["SpouseCNIC"] != DBNull.Value ? drSpouse["SpouseCNIC"].ToString() : "";
                                        string sPhone = drSpouse["SpousePhone"] != DBNull.Value ? drSpouse["SpousePhone"].ToString() : "";
                                        
                                        DataRow sRow = dtSpouses.NewRow();
                                        sRow["SpouseName"] = sName;
                                        sRow["SpouseCNIC"] = sCNIC;
                                        sRow["SpousePhone"] = sPhone;
                                        sRow["SpouseProfession"] = "";
                                        sRow["SpouseEducation"] = "";
                                        string mainNo = txtMemberNo.Text.Trim();
                                        sRow["MembershipNo"] = !string.IsNullOrEmpty(mainNo) ? mainNo + "-W" : "";
                                        sRow["RecordStatus"] = "Active";
                                        sRow["Remarks"] = "";
                                        dtSpouses.Rows.Add(sRow);

                                        ViewState["SpousesData"] = dtSpouses;
                                        gvSpouses.DataSource = dtSpouses;
                                        gvSpouses.DataBind();
                                        UpdateSpousesCount();
                                    }
                                }
                            }
                        }
                    }
                }

                // Fallback: Load Children automatically from MemberChildren (using memberId as fallback)
                LoadChildrenData(memberId);
            }


        }

        protected void SwitchTab_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string tab = btn.CommandArgument;

            btnTabPersonal.CssClass = "btn btn-secondary";
            btnTabContact.CssClass = "btn btn-secondary";
            btnTabMembership.CssClass = "btn btn-secondary";
            btnTabFamily.CssClass = "btn btn-secondary";
            btnTabBilling.CssClass = "btn btn-secondary";
            btnTabHistory.CssClass = "btn btn-secondary";

            btn.CssClass = "btn btn-primary";

            switch (tab)
            {
                case "personal": mvTabs.ActiveViewIndex = 0; break;
                case "contact": mvTabs.ActiveViewIndex = 1; break;
                case "membership": mvTabs.ActiveViewIndex = 2; break;
                case "family": mvTabs.ActiveViewIndex = 3; break;
                case "billing": mvTabs.ActiveViewIndex = 4; break;
                case "history":
                    mvTabs.ActiveViewIndex = 5;
                    BindAuditLog();
                    break;
            }
        }

        private void BindAuditLog()
        {
            BindAuditLog(null, null);
        }

        private void BindAuditLog(DateTime? startDate, DateTime? endDate)
        {
            string memberId = hdnMemberID.Value;
            if (!string.IsNullOrEmpty(memberId))
            {
                gvAuditLog.DataSource = AuditLogger.GetLogs(memberId, startDate, endDate);
                gvAuditLog.DataBind();
            }
        }

        protected void btnSearchHistory_Click(object sender, EventArgs e)
        {
            // Keep History tab active
            mvTabs.ActiveViewIndex = 5;

            DateTime? startDate = null;
            DateTime? endDate = null;

            if (!string.IsNullOrEmpty(txtHistoryStartDate.Text))
            {
                DateTime dt;
                if (TryParseDate(txtHistoryStartDate.Text, out dt))
                    startDate = dt;
            }

            if (!string.IsNullOrEmpty(txtHistoryEndDate.Text))
            {
                DateTime dt;
                if (TryParseDate(txtHistoryEndDate.Text, out dt))
                    endDate = dt.Date.AddDays(1).AddSeconds(-1); // End of that day
            }

            BindAuditLog(startDate, endDate);
        }

        protected void btnClearHistory_Click(object sender, EventArgs e)
        {
            mvTabs.ActiveViewIndex = 5;
            txtHistoryStartDate.Text = "";
            txtHistoryEndDate.Text = "";
            BindAuditLog(null, null);
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                int memberId = string.IsNullOrEmpty(hdnMemberID.Value) ? 0 : Convert.ToInt32(hdnMemberID.Value);

                // ================= DUPLICATE CHECK =================
                string err = CheckForDuplicates(memberId);
                if (!string.IsNullOrEmpty(err))
                {
                    ShowMessage("error", err);
                    return;
                }
                // ===================================================

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    SqlTransaction transaction = conn.BeginTransaction();

                    try
                    {
                        memberId = SaveMainMember(conn, transaction, memberId);
                        // SaveSpouses and SaveChildren logic moved to standalone page.
                        SaveUploadedFiles(memberId);

                        transaction.Commit();

                        // Log the action
                        string userId = Session["UserId"] != null ? Session["UserId"].ToString() : "0";
                        string userName = Session["UserName"] != null ? Session["UserName"].ToString() : "System";

                        string details = "Member profile saved successfully with updated/new fields.";
                        if (ViewState["PendingChangeLog"] != null && !string.IsNullOrEmpty(ViewState["PendingChangeLog"].ToString()))
                        {
                            details += " Changes: " + ViewState["PendingChangeLog"].ToString();
                            ViewState["PendingChangeLog"] = null;
                        }

                        AuditLogger.LogAction("MemberProfile", memberId.ToString(), "UPDATE/INSERT", userId, userName, details);

                        string opType = (hdnMemberID.Value == "0" || hdnMemberID.Value == "") ? "INSERTED New" : "UPDATED Existing";
                        ShowMessage("success", opType + " Member profile saved successfully! Profile ID: " + memberId);
                        hdnMemberID.Value = memberId.ToString();

                        SetFormReadOnly(this.Controls, true);
                        btnSave.Visible = false;
                        btnUpdate.Visible = true;
                        btnUpdate.Text = "Update";
                        ViewState["IsEditing"] = false;
                        ScriptManager.RegisterStartupScript(this, GetType(), "UpdateEditMode", "var isEditing = false;", true);
                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        ShowMessage("error", "Transaction failed: " + ex.Message + (ex.InnerException != null ? ". Inner Exception: " + ex.InnerException.Message : ""));
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("error", "Save failed: " + ex.Message + (ex.InnerException != null ? " | Inner: " + ex.InnerException.Message : ""));
            }
        }

        private string CheckForDuplicates(int memberId)
        {
            string nic = txtNIC.Text.Trim();
            string passport = txtPassportNo.Text.Trim();
            string memberNo = txtMemberNo.Text.Trim();
            bool isExistingMember = memberId > 0;

            // Skip placeholder CNICs (all zeros or dashes only)
            string nicDigits = nic.Replace("-", "").Replace(" ", "");
            bool isPlaceholderNIC = string.IsNullOrEmpty(nicDigits) || nicDigits.All(c => c == '0');

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // For NEW members only: Check NIC uniqueness (skip placeholder CNICs)
                if (!isExistingMember && !string.IsNullOrEmpty(nic) && !isPlaceholderNIC)
                {
                    string sql = "SELECT COUNT(*) FROM MemberProfile WHERE NIC = @NIC AND MemberID != @MemberID";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@NIC", SqlDbType.NVarChar, 50).Value = nic;
                        cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                        if ((int)cmd.ExecuteScalar() > 0)
                            return "Duplicate Member found with same CNIC: " + nic;
                    }
                }

                // For NEW members only: Check Passport uniqueness
                if (!isExistingMember && !string.IsNullOrEmpty(passport))
                {
                    string sql = "SELECT COUNT(*) FROM MemberProfile WHERE PassportNo = @Passport AND MemberID != @MemberID";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@Passport", SqlDbType.NVarChar, 50).Value = passport;
                        cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                        if ((int)cmd.ExecuteScalar() > 0)
                            return "Duplicate Member found with same Passport No: " + passport;
                    }
                }

                // Always check MemberNo uniqueness (for both new and existing members)
                if (!string.IsNullOrEmpty(memberNo))
                {
                    string sql = "SELECT COUNT(*) FROM MemberProfile WHERE MemberNo = @MemberNo AND MemberID != @MemberID";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = memberNo;
                        cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                        if ((int)cmd.ExecuteScalar() > 0)
                            return "Duplicate Member found with same Member Number: " + memberNo;
                    }
                }
            }
            return null;
        }

        private int SaveMainMember(SqlConnection conn, SqlTransaction transaction, int existingMemberId)
        {
            string sql = @"IF EXISTS(SELECT 1 FROM MemberProfile WHERE MemberID = @MemberID)
                           BEGIN
                               UPDATE MemberProfile SET 
                                   MemberNo = @MemberNo, MemberName = @MemberName, Title = @Title,
                                   FatherName = @FatherName, Gender = @Gender, DOB = @DOB,
                                   MemberSince = @MemberSince, NIC = @NIC, OldNIC = @OldNIC,
                                   PassportNo = @PassportNo, Religion = @Religion, Nationality = @Nationality,
                                   MaritalStatus = @MaritalStatus, Sector = @Sector, Occupation = @Occupation,
                                   Status = @Status, CoMemberNo = @CoMemberNo, CompanyName = @CompanyName,
                                   TransferFrom = @TransferFrom, TransferTo = @TransferTo, EffectiveDate = @EffectiveDate,
                                   CategoryChange = @CategoryChange, TransferFee = @TransferFee,
                                   MemberCategory = @MemberCategory, MemberType = @MemberType,
                                   AccountStatus = @AccountStatus, ResidentialStatus = @ResidentialStatus,
                                   Supplementary = @Supplementary,
                                   CompanyAddress1 = @CompanyAddress1, CompanyAddress2 = @CompanyAddress2,
                                   CompanyCity = @CompanyCity, CompanyCountry = @CompanyCountry,
                                   CompanyPhone1 = @CompanyPhone1, CompanyPhone2 = @CompanyPhone2,
                                   CompanyFax = @CompanyFax, CompanyMobile = @CompanyMobile,
                                   CompanyEmail = @CompanyEmail, CompanyEmail2 = @CompanyEmail2,
                                   ResidentialAddress1 = @ResidentialAddress1, ResidentialAddress2 = @ResidentialAddress2,
                                   ResidentialCity = @ResidentialCity, ResidentialCountry = @ResidentialCountry,
                                   ResidentialPhone1 = @ResidentialPhone1, ResidentialPhone2 = @ResidentialPhone2,
                                   ResidentialFax = @ResidentialFax, ResidentialMobile = @ResidentialMobile,
                                   ResidentialEmail = @ResidentialEmail, ResidentialEmail2 = @ResidentialEmail2,
                                   MailingAddress1 = @MailingAddress1, MailingAddress2 = @MailingAddress2,
                                   MailingCity = @MailingCity, MailingCountry = @MailingCountry,
                                   MailingPhone = @MailingPhone, MailingEmail = @MailingEmail,
                                   CreditLimit = @CreditLimit,
                                   Designation = @Designation,
                                   AutoDebit = @AutoDebit, BankName = @BankName,
                                   BankAccountNo = @BankAccountNo, BankAccountTitle = @BankAccountTitle,
                                   ApplicationNo = @ApplicationNo, ApplicationDate = @ApplicationDate,
                                   JoiningFee = @JoiningFee, SecurityDeposit = @SecurityDeposit,
                                   AnnualSubscription = @AnnualSubscription, ApprovedBy = @ApprovedBy,
                                   ApprovalDate = @ApprovalDate, PostedBy = @PostedBy,
                                   Proposer1 = @Proposer1, Proposer1MemberNo = @Proposer1MemberNo,
                                   Proposer2 = @Proposer2, Proposer2MemberNo = @Proposer2MemberNo,
                                   SalesOfficer = @SalesOfficer, Commission = @Commission,
                                   BillTo = @BillTo, StatementFrequency = @StatementFrequency,
                                   EmailStatement = @EmailStatement, PrintStatement = @PrintStatement,
                                   Remarks = @Remarks,
                                   SpouseName = @SpouseName, NumberOfSpouse = @NumberOfSpouse,
                                   NumberOfSons = @NumberOfSons, NumberOfDaughters = @NumberOfDaughters,
                                   NumberOfSupplementary = @NumberOfSupplementary, TotalAllowed = @TotalAllowed, SpouseCNIC = @SP_CNIC,
                                   SpousePhone = @SpousePhone,
                                   Education = @Education, MonthlyIncome = @MonthlyIncome,
                                   EmergencyContact = @EmergencyContact, InterestFacilities = @InterestFacilities,
                                   OtherMemberships = @OtherMemberships, PreferredContact = @PreferredContact,
                                   M_ID = @M_ID,
                                   LastUpdated = GETDATE()
                               WHERE MemberID = @MemberID
                               SELECT @MemberID
                           END
                           ELSE
                           BEGIN
                               INSERT INTO MemberProfile (
                                   MemberNo, MemberName, Title, FatherName, Gender, DOB, MemberSince,
                                   NIC, OldNIC, PassportNo, Religion, Nationality, MaritalStatus,
                                   Sector, Occupation, Status, CoMemberNo, CompanyName, TransferFrom,
                                   TransferTo, EffectiveDate, CategoryChange, TransferFee,
                                   MemberCategory, MemberType, AccountStatus, ResidentialStatus, Supplementary,
                                   CompanyAddress1, CompanyAddress2, CompanyCity, CompanyCountry,
                                   CompanyPhone1, CompanyPhone2, CompanyFax, CompanyMobile,
                                   CompanyEmail, CompanyEmail2,
                                   ResidentialAddress1, ResidentialAddress2, ResidentialCity, ResidentialCountry,
                                   ResidentialPhone1, ResidentialPhone2, ResidentialFax, ResidentialMobile,
                                   ResidentialEmail, ResidentialEmail2,
                                   MailingAddress1, MailingAddress2, MailingCity, MailingCountry,
                                   MailingPhone, MailingEmail,
                                   CreditLimit,
                                                                      Designation,

                                   AutoDebit, BankName, BankAccountNo, BankAccountTitle,
                                   ApplicationNo, ApplicationDate, JoiningFee, SecurityDeposit,
                                   AnnualSubscription, ApprovedBy, ApprovalDate, PostedBy,
                                   Proposer1, Proposer1MemberNo, Proposer2, Proposer2MemberNo,
                                   SalesOfficer, Commission,
                                   BillTo, StatementFrequency, EmailStatement, PrintStatement, Remarks,
                                   SpouseName, NumberOfSpouse, NumberOfSons, NumberOfDaughters,
                                   NumberOfSupplementary, TotalAllowed, SpouseCNIC, SpousePhone, Education, MonthlyIncome, EmergencyContact, InterestFacilities, OtherMemberships, PreferredContact,
                                   CreatedDate, LastUpdated, M_ID
                               ) VALUES (
                                   @MemberNo, @MemberName, @Title, @FatherName, @Gender, @DOB, @MemberSince,
                                   @NIC, @OldNIC, @PassportNo, @Religion, @Nationality, @MaritalStatus,
                                   @Sector, @Occupation, @Status, @CoMemberNo, @CompanyName, @TransferFrom,
                                   @TransferTo, @EffectiveDate, @CategoryChange, @TransferFee,
                                   @MemberCategory, @MemberType, @AccountStatus, @ResidentialStatus, @Supplementary,
                                   @CompanyAddress1, @CompanyAddress2, @CompanyCity, @CompanyCountry,
                                   @CompanyPhone1, @CompanyPhone2, @CompanyFax, @CompanyMobile,
                                   @CompanyEmail, @CompanyEmail2,
                                   @ResidentialAddress1, @ResidentialAddress2, @ResidentialCity, @ResidentialCountry,
                                   @ResidentialPhone1, @ResidentialPhone2, @ResidentialFax, @ResidentialMobile,
                                   @ResidentialEmail, @ResidentialEmail2,
                                   @MailingAddress1, @MailingAddress2, @MailingCity, @MailingCountry,
                                   @MailingPhone, @MailingEmail,
                                   @CreditLimit,
                                                                      @Designation,
                                   @AutoDebit, @BankName, @BankAccountNo, @BankAccountTitle,
                                   @ApplicationNo, @ApplicationDate, @JoiningFee, @SecurityDeposit,
                                   @AnnualSubscription, @ApprovedBy, @ApprovalDate, @PostedBy,
                                   @Proposer1, @Proposer1MemberNo, @Proposer2, @Proposer2MemberNo,
                                   @SalesOfficer, @Commission,
                                   @BillTo, @StatementFrequency, @EmailStatement, @PrintStatement, @Remarks,
                                   @SpouseName, @NumberOfSpouse, @NumberOfSons, @NumberOfDaughters,
                                   @NumberOfSupplementary, @TotalAllowed, @SP_CNIC, @SpousePhone, @Education, @MonthlyIncome, @EmergencyContact, @InterestFacilities, @OtherMemberships, @PreferredContact,
                                   GETDATE(), GETDATE(), @M_ID
                               )
                               SELECT SCOPE_IDENTITY()
                           END";

            using (SqlCommand cmd = new SqlCommand(sql, conn, transaction))
            {
                cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = existingMemberId;
                cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = GetValue(txtMemberNo.Text);
                cmd.Parameters.Add("@MemberName", SqlDbType.NVarChar, 255).Value = GetValue(txtMemberName.Text);
                cmd.Parameters.Add("@Title", SqlDbType.NVarChar, 255).Value = GetValue(ddlTitle.SelectedValue);
                cmd.Parameters.Add("@FatherName", SqlDbType.NVarChar, 255).Value = GetValue(txtFatherName.Text);
                cmd.Parameters.Add("@Gender", SqlDbType.NVarChar, 255).Value = GetValue(ddlGender.SelectedValue);
                cmd.Parameters.Add("@DOB", SqlDbType.DateTime).Value = GetDateValue(txtDOB.Text);
                cmd.Parameters.Add("@MemberSince", SqlDbType.DateTime).Value = GetDateValue(txtMemberSince.Text);
                cmd.Parameters.Add("@NIC", SqlDbType.NVarChar, 50).Value = GetValue(txtNIC.Text);
                cmd.Parameters.Add("@OldNIC", SqlDbType.NVarChar, 50).Value = GetValue(txtOldNIC.Text);
                cmd.Parameters.Add("@PassportNo", SqlDbType.NVarChar, 50).Value = GetValue(txtPassportNo.Text);
                cmd.Parameters.Add("@Religion", SqlDbType.NVarChar, 255).Value = GetValue(ddlReligion.SelectedValue);
                cmd.Parameters.Add("@Nationality", SqlDbType.NVarChar, 255).Value = GetValue(ddlNationality.SelectedValue);
                cmd.Parameters.Add("@MaritalStatus", SqlDbType.NVarChar, 255).Value = GetValue(ddlMaritalStatus.SelectedValue);
                cmd.Parameters.Add("@Sector", SqlDbType.NVarChar, 255).Value = GetValue(ddlSector.SelectedValue);
                cmd.Parameters.Add("@Occupation", SqlDbType.NVarChar, 255).Value = GetValue(txtOccupation.Text);
                cmd.Parameters.Add("@Status", SqlDbType.NVarChar, 255).Value = GetValue(txtStatus.Text);
                cmd.Parameters.Add("@CoMemberNo", SqlDbType.NVarChar, 50).Value = GetValue(txtCoMemberNo.Text);
                cmd.Parameters.Add("@CompanyName", SqlDbType.NVarChar, 255).Value = GetValue(txtCompanyName.Text);
                cmd.Parameters.Add("@TransferFrom", SqlDbType.NVarChar, 50).Value = GetValue(txtTransferFrom.Text);
                cmd.Parameters.Add("@TransferTo", SqlDbType.NVarChar, 50).Value = GetValue(txtTransferTo.Text);
                cmd.Parameters.Add("@EffectiveDate", SqlDbType.DateTime).Value = GetDateValue(txtEffectiveDate.Text);
                cmd.Parameters.Add("@CategoryChange", SqlDbType.DateTime).Value = GetDateValue(txtCategoryChange.Text);
                cmd.Parameters.Add("@TransferFee", SqlDbType.Decimal).Value = GetDecimalValue(txtTransferFee.Text);
                cmd.Parameters.Add("@MemberCategory", SqlDbType.NVarChar, 255).Value = GetValue(txtMemberCategory.Text);
                cmd.Parameters.Add("@MemberType", SqlDbType.NVarChar, 255).Value = GetValue(txtMemberType.Text);
                cmd.Parameters.Add("@AccountStatus", SqlDbType.NVarChar, 255).Value = GetValue(txtAccountStatus.Text);
                cmd.Parameters.Add("@ResidentialStatus", SqlDbType.NVarChar, 255).Value = GetValue(txtResidentialStatus.Text);
                cmd.Parameters.Add("@Supplementary", SqlDbType.NVarChar, 255).Value = GetValue(txtSupplementary.Text);
                cmd.Parameters.Add("@CompanyAddress1", SqlDbType.NVarChar, 255).Value = GetValue(txtCompanyAddress1.Text);
                cmd.Parameters.Add("@CompanyAddress2", SqlDbType.NVarChar, 255).Value = GetValue(txtCompanyAddress2.Text);
                cmd.Parameters.Add("@CompanyCity", SqlDbType.NVarChar, 255).Value = GetValue(txtCompanyCity.Text);
                cmd.Parameters.Add("@CompanyCountry", SqlDbType.NVarChar, 255).Value = GetValue(ddlCompanyCountry.SelectedValue);
                cmd.Parameters.Add("@CompanyPhone1", SqlDbType.NVarChar, 255).Value = GetValue(txtCompanyPhone1.Text);
                cmd.Parameters.Add("@CompanyPhone2", SqlDbType.NVarChar, 255).Value = GetValue(txtCompanyPhone2.Text);
                cmd.Parameters.Add("@CompanyFax", SqlDbType.NVarChar, 255).Value = GetValue(txtCompanyFax.Text);
                cmd.Parameters.Add("@CompanyMobile", SqlDbType.NVarChar, 255).Value = GetValue(txtCompanyMobile.Text);
                cmd.Parameters.Add("@CompanyEmail", SqlDbType.NVarChar, 255).Value = GetValue(txtCompanyEmail.Text);
                cmd.Parameters.Add("@CompanyEmail2", SqlDbType.NVarChar, 255).Value = GetValue(txtCompanyEmail2.Text);
                cmd.Parameters.Add("@ResidentialAddress1", SqlDbType.NVarChar, 255).Value = GetValue(txtResidentialAddress1.Text);
                cmd.Parameters.Add("@ResidentialAddress2", SqlDbType.NVarChar, 255).Value = GetValue(txtResidentialAddress2.Text);
                cmd.Parameters.Add("@ResidentialCity", SqlDbType.NVarChar, 255).Value = GetValue(txtResidentialCity.Text);
                cmd.Parameters.Add("@ResidentialCountry", SqlDbType.NVarChar, 255).Value = GetValue(txtResidentialCountry.Text);
                cmd.Parameters.Add("@ResidentialPhone1", SqlDbType.NVarChar, 255).Value = GetValue(txtResidentialPhone1.Text);
                cmd.Parameters.Add("@ResidentialPhone2", SqlDbType.NVarChar, 255).Value = GetValue(txtResidentialPhone2.Text);
                cmd.Parameters.Add("@ResidentialFax", SqlDbType.NVarChar, 255).Value = GetValue(txtResidentialFax.Text);
                cmd.Parameters.Add("@ResidentialMobile", SqlDbType.NVarChar, 255).Value = GetValue(txtResidentialMobile.Text);
                cmd.Parameters.Add("@ResidentialEmail", SqlDbType.NVarChar, 255).Value = GetValue(txtResidentialEmail.Text);
                cmd.Parameters.Add("@ResidentialEmail2", SqlDbType.NVarChar, 255).Value = GetValue(txtResidentialEmail2.Text);
                cmd.Parameters.Add("@MailingAddress1", SqlDbType.NVarChar, 255).Value = GetValue(txtMailingAddress1.Text);
                cmd.Parameters.Add("@MailingAddress2", SqlDbType.NVarChar, 255).Value = GetValue(txtMailingAddress2.Text);
                cmd.Parameters.Add("@MailingCity", SqlDbType.NVarChar, 255).Value = GetValue(txtMailingCity.Text);
                cmd.Parameters.Add("@MailingCountry", SqlDbType.NVarChar, 255).Value = GetValue(txtMailingCountry.Text);
                cmd.Parameters.Add("@MailingPhone", SqlDbType.NVarChar, 255).Value = GetValue(txtMailingPhone.Text);
                cmd.Parameters.Add("@MailingEmail", SqlDbType.NVarChar, 255).Value = GetValue(txtMailingEmail.Text);
                cmd.Parameters.Add("@CreditLimit", SqlDbType.Decimal).Value = GetDecimalValue(txtCreditLimit.Text);

                cmd.Parameters.Add("@Designation", SqlDbType.NVarChar, 255).Value = GetValue(txtDesignation.Text);
                cmd.Parameters.Add("@AutoDebit", SqlDbType.Bit).Value = GetBoolValue(ddlAutoDebit.SelectedValue);
                cmd.Parameters.Add("@BankName", SqlDbType.NVarChar, 255).Value = GetValue(txtBankName.Text);
                cmd.Parameters.Add("@BankAccountNo", SqlDbType.NVarChar, 255).Value = GetValue(txtBankAccountNo.Text);
                cmd.Parameters.Add("@BankAccountTitle", SqlDbType.NVarChar, 255).Value = GetValue(txtBankAccountTitle.Text);
                cmd.Parameters.Add("@ApplicationNo", SqlDbType.NVarChar, 255).Value = DBNull.Value;
                cmd.Parameters.Add("@ApplicationDate", SqlDbType.DateTime).Value = DBNull.Value;
                cmd.Parameters.Add("@JoiningFee", SqlDbType.Decimal).Value = DBNull.Value;
                cmd.Parameters.Add("@SecurityDeposit", SqlDbType.Decimal).Value = DBNull.Value;
                cmd.Parameters.Add("@AnnualSubscription", SqlDbType.Decimal).Value = DBNull.Value;
                cmd.Parameters.Add("@ApprovedBy", SqlDbType.NVarChar, 255).Value = DBNull.Value;
                cmd.Parameters.Add("@ApprovalDate", SqlDbType.DateTime).Value = DBNull.Value;
                cmd.Parameters.Add("@PostedBy", SqlDbType.NVarChar, 255).Value = DBNull.Value;
                cmd.Parameters.Add("@Proposer1", SqlDbType.NVarChar, 255).Value = GetValue(txtProposer1.Text);
                cmd.Parameters.Add("@Proposer1MemberNo", SqlDbType.NVarChar, 255).Value = GetValue(txtProposer1MemberNo.Text);
                cmd.Parameters.Add("@Proposer2", SqlDbType.NVarChar, 255).Value = GetValue(txtProposer2.Text);
                cmd.Parameters.Add("@Proposer2MemberNo", SqlDbType.NVarChar, 255).Value = GetValue(txtProposer2MemberNo.Text);
                cmd.Parameters.Add("@SalesOfficer", SqlDbType.NVarChar, 255).Value = GetValue(txtSalesOfficer.Text);
                cmd.Parameters.Add("@Commission", SqlDbType.Int).Value = 0;
                cmd.Parameters.Add("@BillTo", SqlDbType.NVarChar, 255).Value = GetValue(ddlBillTo.SelectedValue);
                cmd.Parameters.Add("@StatementFrequency", SqlDbType.NVarChar, 255).Value = GetValue(ddlStatementFrequency.SelectedValue);
                cmd.Parameters.Add("@EmailStatement", SqlDbType.NVarChar, 255).Value = GetBoolValue(ddlEmailStatement.SelectedValue);
                cmd.Parameters.Add("@PrintStatement", SqlDbType.NVarChar, 255).Value = GetBoolValue(ddlPrintStatement.SelectedValue);
                cmd.Parameters.Add("@Remarks", SqlDbType.NVarChar, 255).Value = GetValue(txtRemarks.Text);
                string firstSpouseName = "";
                string firstSpouseCNIC = "";
                string firstSpousePhone = "";
                if (gvSpouses.Rows.Count > 0 && gvSpouses.Rows[0].RowType == DataControlRowType.DataRow)
                {
                    TextBox txtSName = (TextBox)gvSpouses.Rows[0].FindControl("txtSpouseNameGrid");
                    TextBox txtSCNIC = (TextBox)gvSpouses.Rows[0].FindControl("txtSpouseCNICGrid");
                    TextBox txtSPhone = (TextBox)gvSpouses.Rows[0].FindControl("txtSpousePhoneGrid");
                    if (txtSName != null) firstSpouseName = txtSName.Text;
                    if (txtSCNIC != null) firstSpouseCNIC = txtSCNIC.Text;
                    if (txtSPhone != null) firstSpousePhone = txtSPhone.Text;
                }

                cmd.Parameters.Add("@SpouseName", SqlDbType.NVarChar, 255).Value = GetValue(firstSpouseName);
                cmd.Parameters.Add("@NumberOfSpouse", SqlDbType.NVarChar, 255).Value = 0;
                cmd.Parameters.Add("@NumberOfSons", SqlDbType.NVarChar, 255).Value = 0;
                cmd.Parameters.Add("@NumberOfDaughters", SqlDbType.NVarChar, 255).Value = 0;
                cmd.Parameters.Add("@NumberOfSupplementary", SqlDbType.NVarChar, 255).Value = 0;
                cmd.Parameters.Add("@TotalAllowed", SqlDbType.NVarChar, 255).Value = 0;
                cmd.Parameters.Add("@SP_CNIC", SqlDbType.NVarChar, 255).Value = GetValue(firstSpouseCNIC);
                cmd.Parameters.Add("@SpousePhone", SqlDbType.NVarChar, 255).Value = GetValue(firstSpousePhone);

                // New fields parameters
                cmd.Parameters.Add("@Education", SqlDbType.NVarChar, 255).Value = GetValue(txtEducation.Text);
                cmd.Parameters.Add("@MonthlyIncome", SqlDbType.NVarChar, 255).Value = GetDecimalValue(txtMonthlyIncome.Text);
                cmd.Parameters.Add("@EmergencyContact", SqlDbType.NVarChar, 255).Value = GetValue(txtEmergencyContact.Text);
                cmd.Parameters.Add("@InterestFacilities", SqlDbType.NVarChar, 255).Value = GetValue(txtInterestFacilities.Text);
                cmd.Parameters.Add("@OtherMemberships", SqlDbType.NVarChar, 255).Value = GetValue(txtOtherMemberships.Text);
                cmd.Parameters.Add("@PreferredContact", SqlDbType.NVarChar, 255).Value = GetValue(ddlPreferredContact.SelectedValue);

                int mId = 0;
                if (Request.QueryString["MemberID"] != null)
                    int.TryParse(Request.QueryString["MemberID"], out mId);
                cmd.Parameters.Add("@M_ID", SqlDbType.Int).Value = mId;

                // Status Automation Logic
                string accountStatus = txtAccountStatus.Text;

                try
                {
                    return Convert.ToInt32(cmd.ExecuteScalar());
                }
                catch (Exception ex)
                {
                    throw new Exception("Error in SaveMainMember SQL execution: " + ex.Message);
                }
            }
        }

        // SaveSpouses and SaveChildren logic moved to standalone page.

        // SaveVehicles logic moved to standalone page.
        // SaveNominees removed

        // SaveSupplementary logic removed


        // SaveClubs logic moved to standalone page.
        private void SaveUploadedFiles(int memberId)
        {
            if (fuPicture.HasFile)
            {
                try
                {
                    string fileName = "Picture_" + memberId + "_" + DateTime.Now.ToString("yyyyMMddHHmmss") + Path.GetExtension(fuPicture.FileName);
                    string uploadPath = Server.MapPath("~/Uploads/Pictures/");

                    if (!Directory.Exists(uploadPath))
                        Directory.CreateDirectory(uploadPath);

                    string filePath = Path.Combine(uploadPath, fileName);
                    fuPicture.SaveAs(filePath);

                    SaveDocumentToDB(memberId, "Picture", fileName, filePath, fuPicture.FileBytes.Length);
                }
                catch (Exception ex)
                {
                    ShowMessage("error", "Error saving picture: " + ex.Message);
                }
            }

            if (fuSignature.HasFile)
            {
                try
                {
                    string fileName = "Signature_" + memberId + "_" + DateTime.Now.ToString("yyyyMMddHHmmss") + Path.GetExtension(fuSignature.FileName);
                    string uploadPath = Server.MapPath("~/Uploads/Signatures/");

                    if (!Directory.Exists(uploadPath))
                        Directory.CreateDirectory(uploadPath);

                    string filePath = Path.Combine(uploadPath, fileName);
                    fuSignature.SaveAs(filePath);

                    SaveDocumentToDB(memberId, "Signature", fileName, filePath, fuSignature.FileBytes.Length);
                }
                catch (Exception ex)
                {
                    ShowMessage("error", "Error saving signature: " + ex.Message);
                }
            }
        }

        private void SaveDocumentToDB(int memberId, string docType, string fileName, string filePath, int fileSize)
        {
            string sql = @"INSERT INTO MemberDocuments 
                (MemberID, DocumentType, FileName, FilePath, FileSize, UploadDate, M_Id) 
                VALUES (@MemberID, @DocumentType, @FileName, @FilePath, @FileSize, GETDATE(), @M_ID)";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                cmd.Parameters.Add("@DocumentType", SqlDbType.NVarChar, 255).Value = docType;
                cmd.Parameters.Add("@FileName", SqlDbType.NVarChar, 255).Value = fileName;
                cmd.Parameters.Add("@FilePath", SqlDbType.NVarChar, 255).Value = filePath;
                cmd.Parameters.Add("@FileSize", SqlDbType.NVarChar, 255).Value = fileSize;
                cmd.Parameters.Add("@M_ID", SqlDbType.Int).Value = hdnMemberID.Value;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // btnAddSpouse_Click and btnAddChild_Click logic removed
        private string CalculateAge(DateTime dob)
        {
            DateTime today = DateTime.Today;
            int years = today.Year - dob.Year;
            int months = today.Month - dob.Month;
            int days = today.Day - dob.Day;

            if (days < 0)
            {
                months--;
                DateTime previousMonth = today.AddMonths(-1);
                days += DateTime.DaysInMonth(previousMonth.Year, previousMonth.Month);
            }

            if (months < 0)
            {
                years--;
                months += 12;
            }

            return FormatAgeString(years, months, days);
        }

        private string FormatAgeString(int years, int months, int days)
        {
            List<string> parts = new List<string>();

            if (years > 0)
            {
                parts.Add(years + " year" + (years != 1 ? "s" : ""));
            }

            if (months > 0)
            {
                parts.Add(months + " month" + (months != 1 ? "s" : ""));
            }

            if (days > 0 || (years == 0 && months == 0))
            {
                parts.Add(days + " day" + (days != 1 ? "s" : ""));
            }

            if (parts.Count == 0)
            {
                return "0 days";
            }

            return string.Join(", ", parts);
        }

        
        private void InitializeSpousesGrid()
        {
            DataTable dt = GetSpousesTable();
            ViewState["SpousesData"] = dt;
            gvSpouses.DataSource = dt;
            gvSpouses.DataBind();
        }

        private void InitializeChildrenGrid()
        {
            DataTable dt = GetChildrenTable();
            ViewState["ChildrenData"] = dt;
            gvChildren.DataSource = dt;
            gvChildren.DataBind();
        }

        private void InitializeVehiclesGrid()
        {
            DataTable dt = GetVehiclesTable();
            ViewState["VehiclesData"] = dt;
            gvVehicles.DataSource = dt;
            gvVehicles.DataBind();
        }

        private void InitializeGrids()
        {
            InitializeSpousesGrid();
            InitializeChildrenGrid();
            InitializeVehiclesGrid();
            InitializeSupplementaryGrid();
            InitializeClubsGrid();
        }

        private void InitializeClubsGrid()
        {
            DataTable dt = GetClubsTable();
            ViewState["ClubsData"] = dt;
            gvClubs.DataSource = dt;
            gvClubs.DataBind();
        }

        private DataTable GetSpousesTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("SpouseName", typeof(string));
            dt.Columns.Add("SpouseCNIC", typeof(string));
            dt.Columns.Add("SpousePhone", typeof(string));
            dt.Columns.Add("SpouseProfession", typeof(string));
            dt.Columns.Add("SpouseEducation", typeof(string));
            dt.Columns.Add("MembershipNo", typeof(string));
            dt.Columns.Add("RecordStatus", typeof(string));
            dt.Columns.Add("Remarks", typeof(string));
            return dt;
        }

        private DataTable GetChildrenTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("ChildName", typeof(string));
            dt.Columns.Add("Relationship", typeof(string));
            dt.Columns.Add("DOB", typeof(string));
            dt.Columns.Add("Age", typeof(string));
            dt.Columns.Add("CardNo", typeof(string));
            dt.Columns.Add("CNICNo", typeof(string));
            dt.Columns.Add("ChildPhone", typeof(string)); // Child Phone
            dt.Columns.Add("ValidityPeriod", typeof(string));
            dt.Columns.Add("MembershipNo", typeof(string));
            dt.Columns.Add("RecordStatus", typeof(string));
            dt.Columns.Add("Remarks", typeof(string));
            return dt;
        }

        private DataTable GetVehiclesTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("StickerNo", typeof(string));
            dt.Columns.Add("VehicleNo", typeof(string));
            dt.Columns.Add("Model", typeof(string));
            dt.Columns.Add("Make", typeof(string));
            dt.Columns.Add("IssueDate", typeof(string));
            return dt;
        }

        private void InitializeSupplementaryGrid()
        {
            DataTable dt = GetSupplementaryTable();
            ViewState["SupplementaryData"] = dt;
            gvSupplementary.DataSource = dt;
            gvSupplementary.DataBind();
        }

        private DataTable GetSupplementaryTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("MembershipNo", typeof(string));
            dt.Columns.Add("SupplementaryName", typeof(string));
            dt.Columns.Add("Relationship", typeof(string));
            dt.Columns.Add("ValidityPeriod", typeof(string));
            dt.Columns.Add("RecordStatus", typeof(string));
            dt.Columns.Add("Remarks", typeof(string));
            return dt;
        }


        private DataTable GetClubsTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("ClubName", typeof(string));
            dt.Columns.Add("MembershipNo", typeof(string));
            return dt;
        }

        private void LoadMemberData(int mId)
        {
            // First attempt: Search by M_ID (foreign key to Member table)
            string sql = "SELECT * FROM MemberProfile WHERE M_ID = @MID";

            // Fallback: Search by MemberNo if M_ID fails (handles legacy or unlinked records)
            string sqlFallback = "SELECT * FROM MemberProfile WHERE MemberNo = @MemberNo";

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Try M_ID first
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@MID", SqlDbType.Int).Value = mId;
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            PopulateFromReader(reader);
                            return;
                        }
                    }
                }

                // If not found, try MemberNo from the screen (strip suffix first)
                string displayNo = txtMemberNo.Text.Trim();
                string baseNo = GetBaseMemberNo(displayNo);

                if (!string.IsNullOrEmpty(baseNo))
                {
                    using (SqlCommand cmd = new SqlCommand(sqlFallback, conn))
                    {
                        cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = baseNo;
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                PopulateFromReader(reader);
                                // Restore the suffixed version for display if it was used for search
                                txtMemberNo.Text = displayNo;
                                return;
                            }
                        }
                    }
                }
            }
        }

        private void PopulateFromReader(SqlDataReader reader)
        {
            int profileId = Convert.ToInt32(reader["MemberID"]);
            hdnMemberID.Value = profileId.ToString();

            txtMemberNo.Text = reader["MemberNo"].ToString();
            txtMemberName.Text = reader["MemberName"].ToString();
            SafeSetSelectedValue(ddlTitle, reader["Title"].ToString());
            txtFatherName.Text = reader["FatherName"].ToString();
            SafeSetSelectedValue(ddlGender, reader["Gender"].ToString());
            txtDOB.Text = FormatDate(reader["DOB"]);
            // txtMemberSince.Text = FormatDate(reader["MemberSince"]); // Loaded from Member.CreatedAt instead
            txtNIC.Text = reader["NIC"].ToString();
            txtOldNIC.Text = reader["OldNIC"].ToString();
            txtPassportNo.Text = reader["PassportNo"].ToString();
            SafeSetSelectedValue(ddlReligion, reader["Religion"].ToString());
            SafeSetSelectedValue(ddlNationality, reader["Nationality"].ToString());
            SafeSetSelectedValue(ddlMaritalStatus, reader["MaritalStatus"].ToString());
            SafeSetSelectedValue(ddlSector, reader["Sector"].ToString());
            txtOccupation.Text = reader["Occupation"].ToString();
            txtStatus.Text = reader["Status"].ToString();
            txtCoMemberNo.Text = reader["CoMemberNo"].ToString();
            txtCompanyName.Text = reader["CompanyName"].ToString();
            txtTransferFrom.Text = reader["TransferFrom"].ToString();
            txtTransferTo.Text = reader["TransferTo"].ToString();
            txtEffectiveDate.Text = FormatDate(reader["EffectiveDate"]);
            txtCategoryChange.Text = FormatDate(reader["CategoryChange"]);
            txtTransferFee.Text = reader["TransferFee"].ToString();
            //txtMemberCategory.Text = reader["MemberShipCategory"].ToString();
            txtMemberType.Text = reader["MemberType"].ToString();

            string accStatus = reader["AccountStatus"].ToString();
            txtAccountStatus.Text = accStatus;

            txtResidentialStatus.Text = reader["ResidentialStatus"].ToString();
            txtSupplementary.Text = reader["Supplementary"].ToString();
            txtCompanyAddress1.Text = reader["CompanyAddress1"].ToString();
            txtCompanyAddress2.Text = reader["CompanyAddress2"].ToString();
            txtCompanyCity.Text = reader["CompanyCity"].ToString();
            SafeSetSelectedValue(ddlCompanyCountry, reader["CompanyCountry"].ToString());
            txtCompanyPhone1.Text = reader["CompanyPhone1"].ToString();
            txtCompanyPhone2.Text = reader["CompanyPhone2"].ToString();
            txtCompanyFax.Text = reader["CompanyFax"].ToString();
            txtCompanyMobile.Text = reader["CompanyMobile"].ToString();
            txtCompanyEmail.Text = reader["CompanyEmail"].ToString();
            txtCompanyEmail2.Text = reader["CompanyEmail2"].ToString();
            txtResidentialAddress1.Text = reader["ResidentialAddress1"].ToString();
            txtResidentialAddress2.Text = reader["ResidentialAddress2"].ToString();
            txtResidentialCity.Text = reader["ResidentialCity"].ToString();
            txtResidentialCountry.Text = reader["ResidentialCountry"].ToString();
            txtResidentialPhone1.Text = reader["ResidentialPhone1"].ToString();
            txtResidentialPhone2.Text = reader["ResidentialPhone2"].ToString();
            txtResidentialFax.Text = reader["ResidentialFax"].ToString();
            txtResidentialMobile.Text = reader["ResidentialMobile"].ToString();
            txtResidentialEmail.Text = reader["ResidentialEmail"].ToString();
            txtResidentialEmail2.Text = reader["ResidentialEmail2"].ToString();
            txtMailingAddress1.Text = reader["MailingAddress1"].ToString();
            txtMailingAddress2.Text = reader["MailingAddress2"].ToString();
            txtMailingCity.Text = reader["MailingCity"].ToString();
            txtMailingCountry.Text = reader["MailingCountry"].ToString();
            txtMailingPhone.Text = reader["MailingPhone"].ToString();
            txtMailingEmail.Text = reader["MailingEmail"].ToString();
            txtCreditLimit.Text = reader["CreditLimit"].ToString();

            txtDesignation.Text = reader["Designation"].ToString();
            SafeSetSelectedValue(ddlAutoDebit, reader["AutoDebit"].ToString());
            txtBankName.Text = reader["BankName"].ToString();
            txtBankAccountNo.Text = reader["BankAccountNo"].ToString();
            txtBankAccountTitle.Text = reader["BankAccountTitle"].ToString();
            // Application Processing fields removed from UI

            if (HasColumn(reader, "Proposer1")) 
                txtProposer1.Text = reader["Proposer1"].ToString();
                
            if (HasColumn(reader, "Proposer1MemberNo"))
            {
                string p1No = reader["Proposer1MemberNo"].ToString();
                txtProposer1MemberNo.Text = p1No;
                if (!string.IsNullOrEmpty(p1No))
                {
                    string fetchedName = GetMemberNameByNo(p1No);
                    if (!string.IsNullOrEmpty(fetchedName))
                    {
                        txtProposer1.Text = fetchedName;
                    }
                }
            }

            if (HasColumn(reader, "Proposer2")) 
                txtProposer2.Text = reader["Proposer2"].ToString();
                
            if (HasColumn(reader, "Proposer2MemberNo"))
            {
                string p2No = reader["Proposer2MemberNo"].ToString();
                txtProposer2MemberNo.Text = p2No;
                if (!string.IsNullOrEmpty(p2No))
                {
                    string fetchedName = GetMemberNameByNo(p2No);
                    if (!string.IsNullOrEmpty(fetchedName))
                    {
                        txtProposer2.Text = fetchedName;
                    }
                }
            }

            txtRemarks.Text = reader["Remarks"].ToString();
            // Count fields removed from UI

            // New fields
            txtEducation.Text = reader["Education"].ToString();
            txtMonthlyIncome.Text = reader["MonthlyIncome"].ToString();
            txtEmergencyContact.Text = reader["EmergencyContact"].ToString();
            txtInterestFacilities.Text = reader["InterestFacilities"].ToString();
            txtOtherMemberships.Text = reader["OtherMemberships"].ToString();
            SafeSetSelectedValue(ddlPreferredContact, reader["PreferredContact"].ToString());
            int currentProfileId = 0;
            int.TryParse(hdnMemberID.Value, out currentProfileId);

            if (currentProfileId > 0)
            {
                LoadSpousesData(currentProfileId);
                LoadChildrenData(currentProfileId);
                LoadVehiclesData(currentProfileId);
                LoadSupplementaryData(currentProfileId);
                LoadClubsData(currentProfileId);
            }
        }

        private void SafeSetSelectedValue(DropDownList ddl, string value)
        {
            if (ddl == null || string.IsNullOrEmpty(value)) return;
            string val = value.Trim().ToLower();
            ListItem item = ddl.Items.FindByValue(val);
            if (item != null)
            {
                ddl.SelectedValue = val;
            }
            else
            {
                // Try case-insensitive exact match
                foreach (ListItem li in ddl.Items)
                {
                    if (string.Equals(li.Value, value.Trim(), StringComparison.OrdinalIgnoreCase))
                    {
                        ddl.SelectedValue = li.Value;
                        return;
                    }
                }
            }
        }

        // Helper methods for parameter values
        private object GetValue(string value)
        {
            return string.IsNullOrEmpty(value) ? DBNull.Value : (object)value;
        }

        private object GetDateValue(string dateString)
        {
            if (string.IsNullOrEmpty(dateString)) return DBNull.Value;
            DateTime date;
            if (DateTime.TryParseExact(dateString.Trim(), "dd-MM-yyyy", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out date))
                return date;
            return DateTime.TryParse(dateString.Trim(), out date) ? (object)date : DBNull.Value;
        }

        private bool TryParseDate(string dateStr, out DateTime dt)
        {
            dt = DateTime.MinValue;
            if (string.IsNullOrEmpty(dateStr)) return false;
            if (DateTime.TryParseExact(dateStr.Trim(), "dd-MM-yyyy", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out dt))
                return true;
            return DateTime.TryParse(dateStr.Trim(), out dt);
        }

        private object GetDecimalValue(string decimalString)
        {
            if (string.IsNullOrEmpty(decimalString)) return DBNull.Value;
            decimal value;
            return decimal.TryParse(decimalString, out value) ? (object)value : DBNull.Value;
        }

        private object GetIntValue(string intString)
        {
            if (string.IsNullOrEmpty(intString)) return DBNull.Value;
            int value;
            return int.TryParse(intString, out value) ? (object)value : DBNull.Value;
        }

        private object GetBoolValue(string boolString)
        {
            if (string.IsNullOrEmpty(boolString)) return DBNull.Value;
            return boolString.ToLower() == "yes" || boolString.ToLower() == "true" || boolString == "1";
        }

        private string FormatDate(object dateObj)
        {
            if (dateObj == DBNull.Value || dateObj == null) return "";
            DateTime date = Convert.ToDateTime(dateObj);
            return date.ToString("dd-MM-yyyy");
        }

        private bool HasColumn(SqlDataReader reader, string columnName)
        {
            for (int i = 0; i < reader.FieldCount; i++)
            {
                if (reader.GetName(i).Equals(columnName, StringComparison.OrdinalIgnoreCase))
                {
                    return true;
                }
            }
            return false;
        }

        // VS2013 Compatible Alert Method
        private void ShowMessage(string type, string message)
        {
            // Escape single quotes and newlines for JavaScript
            message = message.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\n", "\\n").Replace("\r", "\\r");

            string script;
            if (type.ToLower() == "success")
            {
                script = "alert('SUCCESS: " + message + "');";
            }
            else
            {
                script = "alert('ERROR: " + message + "');";
            }

            // Use ScriptManager to work inside UpdatePanel async postbacks
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowMessage_" + DateTime.Now.Ticks, script, true);
        }

        // Alternative method using ScriptManager (for AJAX UpdatePanel)
        private void ShowMessageAjax(string type, string message)
        {
            string script = string.Empty;
            message = message.Replace("'", "\\'").Replace("\n", "\\n").Replace("\r", "\\r");

            if (type.ToLower() == "success")
            {
                script = "alert('" + message + "');";
            }
            else
            {
                script = "alert('Error: " + message + "');";
            }

            ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowMessageAjax", script, true);
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/MemberList.aspx");
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            try
            {
                bool isEditing = ViewState["IsEditing"] != null && (bool)ViewState["IsEditing"];

                if (!isEditing)
                {
                    // Enter Edit Mode
                    ViewState["OldFieldValues"] = GetCurrentFieldValues(this.Controls);
                    SetFormReadOnly(this.Controls, false);
                    btnUpdate.Text = "Save Changes";
                    ViewState["IsEditing"] = true;

                    ScriptManager.RegisterStartupScript(this, GetType(), "UpdateEditMode", "var isEditing = true;", true);
                }
                else
                {
                    // Save Changes Mode
                    Dictionary<string, string> oldValues = ViewState["OldFieldValues"] as Dictionary<string, string>;
                    if (oldValues != null)
                    {
                        Dictionary<string, string> newValues = GetCurrentFieldValues(this.Controls);
                        string changes = BuildChangeLog(oldValues, newValues);

                        if (!string.IsNullOrEmpty(changes))
                        {
                            ViewState["PendingChangeLog"] = changes;
                        }
                    }

                    // Trigger the save action
                    btnSave_Click(sender, e);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("error", "Update/Save error: " + ex.Message + (ex.InnerException != null ? " | Inner: " + ex.InnerException.Message : ""));
            }
        }

        // Fields that must ALWAYS remain readonly, even when Update mode is active
        private static readonly HashSet<string> _alwaysReadOnlyFields = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "txtMemberCategory", "txtMemberType", "txtMemberNo",
            "txtAccountStatus", "txtMemberSince", "txtCoMemberNo",
            "txtProposer1", "txtProposer2", "txtResidentialStatus",
            "txtDOB"
        };

        private void SetFormReadOnly(ControlCollection controls, bool readOnly)
        {
            foreach (Control c in controls)
            {
                if (c.ID == "btnUpdate" || c.ID == "btnCancel" || c.ID == "btnSave")
                    continue;

                // Check if this field should always stay readonly
                bool forceReadOnly = c.ID != null && _alwaysReadOnlyFields.Contains(c.ID);

                if (c is TextBox)
                {
                    if (forceReadOnly)
                        ((TextBox)c).Enabled = false;
                    else
                        ((TextBox)c).Enabled = !readOnly;
                }
                else if (c is DropDownList)
                {
                    if (forceReadOnly)
                        ((DropDownList)c).Enabled = false;
                    else
                        ((DropDownList)c).Enabled = !readOnly;
                }
                else if (c is System.Web.UI.WebControls.FileUpload)
                    ((System.Web.UI.WebControls.FileUpload)c).Enabled = !readOnly;
                else if (c is CheckBox)
                    ((CheckBox)c).Enabled = !readOnly;

                // Disable GridView action buttons (add/delete)
                if (c.ID != null && (c.ID.StartsWith("btnAdd") || c.ID.StartsWith("btnUpload") || c.ID.StartsWith("btnShow")))
                {
                    if (c is Button) ((Button)c).Enabled = !readOnly;
                    if (c is LinkButton) ((LinkButton)c).Enabled = !readOnly;
                }

                if (c.HasControls())
                {
                    SetFormReadOnly(c.Controls, readOnly);
                }
            }
        }

        private Dictionary<string, string> GetCurrentFieldValues(ControlCollection controls)
        {
            Dictionary<string, string> values = new Dictionary<string, string>();
            CollectFieldValues(controls, values);
            return values;
        }

        private void CollectFieldValues(ControlCollection controls, Dictionary<string, string> values)
        {
            foreach (Control c in controls)
            {
                if (c is TextBox)
                {
                    TextBox tb = (TextBox)c;
                    if (!string.IsNullOrEmpty(tb.ID)) values[tb.ID] = tb.Text;
                }
                else if (c is DropDownList)
                {
                    DropDownList ddl = (DropDownList)c;
                    if (!string.IsNullOrEmpty(ddl.ID)) values[ddl.ID] = ddl.SelectedValue;
                }
                else if (c is CheckBox)
                {
                    CheckBox cb = (CheckBox)c;
                    if (!string.IsNullOrEmpty(cb.ID)) values[cb.ID] = cb.Checked.ToString();
                }

                if (c.HasControls())
                {
                    CollectFieldValues(c.Controls, values);
                }
            }
        }

        private string BuildChangeLog(Dictionary<string, string> oldValues, Dictionary<string, string> newValues)
        {
            List<string> changes = new List<string>();
            foreach (var kvp in oldValues)
            {
                if (newValues.ContainsKey(kvp.Key))
                {
                    if (kvp.Value != newValues[kvp.Key])
                    {
                        string fieldName = kvp.Key.Replace("txt", "").Replace("ddl", "").Replace("cb", "");
                        if (string.IsNullOrWhiteSpace(kvp.Value) && string.IsNullOrWhiteSpace(newValues[kvp.Key])) continue;

                        // Limit size just to be safe if content is crazy huge
                        string oldVal = kvp.Value.Length > 100 ? kvp.Value.Substring(0, 100) + "..." : kvp.Value;
                        string newVal = newValues[kvp.Key].Length > 100 ? newValues[kvp.Key].Substring(0, 100) + "..." : newValues[kvp.Key];

                        changes.Add(string.Format("{0}: '{1}' to '{2}'", fieldName, oldVal, newVal));
                    }
                }
            }
            return string.Join(" | ", changes);
        }

        private void LoadSpousesData(int memberId)
        {
            string sql = "SELECT SpouseName, SpouseCNIC, SpousePhone, SpouseProfession, SpouseEducation, MembershipNo, RecordStatus, Remarks FROM MemberSpouses WHERE MemberID = @MemberID OR MemberID = @MID";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                cmd.Parameters.Add("@MID", SqlDbType.Int).Value = _queryStringMemberId;
                conn.Open();

                DataTable dt = GetSpousesTable();
                int spouseCount = 0;

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        DataRow row = dt.NewRow();
                        row["SpouseName"] = reader["SpouseName"].ToString();
                        row["SpouseCNIC"] = reader["SpouseCNIC"].ToString();
                        row["SpousePhone"] = reader["SpousePhone"].ToString();
                        row["SpouseProfession"] = reader["SpouseProfession"].ToString();
                        row["SpouseEducation"] = reader["SpouseEducation"].ToString();
                        
                        string mNo = reader["MembershipNo"].ToString();
                        if (string.IsNullOrEmpty(mNo))
                        {
                            string mainMemberNo = txtMemberNo.Text.Trim();
                            if (!string.IsNullOrEmpty(mainMemberNo))
                            {
                                mNo = mainMemberNo + (spouseCount == 0 ? "-W" : "-W" + spouseCount);
                            }
                        }
                        row["MembershipNo"] = mNo;
                        spouseCount++;

                        row["RecordStatus"] = string.IsNullOrEmpty(reader["RecordStatus"].ToString()) ? "Active" : reader["RecordStatus"].ToString();
                        row["Remarks"] = reader["Remarks"].ToString();
                        dt.Rows.Add(row);
                    }
                }

                ViewState["SpousesData"] = dt;
                gvSpouses.DataSource = dt;
                gvSpouses.DataBind();
                UpdateSpousesCount();
            }
        }

        private void LoadChildrenData(int memberId)
        {
            string sql = "SELECT ChildName, Relationship, DOB, CardNo, CNIC, ChildPhone, ValidityPeriod, MembershipNo, RecordStatus, Remarks FROM MemberChildren WHERE MemberID = @MemberID OR MemberID = @MID";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                cmd.Parameters.Add("@MID", SqlDbType.Int).Value = _queryStringMemberId;
                conn.Open();

                // Create DataTable with all columns including Age
                DataTable dt = GetChildrenTable();
                string mainMemberNo = txtMemberNo.Text.Trim();
                int sonCount = 0;
                int daughterCount = 0;
                int otherCount = 0;

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        DataRow row = dt.NewRow();
                        row["ChildName"] = reader["ChildName"].ToString();
                        string rel = reader["Relationship"].ToString().Trim();
                        if (rel.Equals("daughter", StringComparison.OrdinalIgnoreCase))
                            rel = "Daughter";
                        else if (rel.Equals("son", StringComparison.OrdinalIgnoreCase))
                            rel = "Son";
                        else
                            rel = "";
                        row["Relationship"] = rel;
                        row["DOB"] = FormatDate(reader["DOB"]);
                        row["CardNo"] = reader["CardNo"].ToString();
                        row["CNICNo"] = reader["CNIC"].ToString();
                        row["ChildPhone"] = reader["ChildPhone"].ToString(); // Load Child Phone
                        row["ValidityPeriod"] = FormatDate(reader["ValidityPeriod"]);
                        
                        string mNo = reader["MembershipNo"].ToString();
                        if (string.IsNullOrEmpty(mNo) && !string.IsNullOrEmpty(mainMemberNo))
                        {
                            if (rel == "Son")
                            {
                                sonCount++;
                                mNo = mainMemberNo + "-S" + sonCount;
                            }
                            else if (rel == "Daughter")
                            {
                                daughterCount++;
                                mNo = mainMemberNo + "-D" + daughterCount;
                            }
                            else
                            {
                                otherCount++;
                                mNo = mainMemberNo + "-C" + otherCount;
                            }
                        }
                        else
                        {
                            if (rel == "Son") sonCount++;
                            else if (rel == "Daughter") daughterCount++;
                            else otherCount++;
                        }
                        row["MembershipNo"] = mNo;

                        row["RecordStatus"] = string.IsNullOrEmpty(reader["RecordStatus"].ToString()) ? "Active" : reader["RecordStatus"].ToString();
                        row["Remarks"] = reader["Remarks"].ToString();
                        // CALCULATE AND ADD AGE
                        if (reader["DOB"] != DBNull.Value)
                        {
                            DateTime dob;
                            if (DateTime.TryParse(reader["DOB"].ToString(), out dob))
                            {
                                row["Age"] = CalculateAge(dob);
                            }
                            else
                            {
                                row["Age"] = "";
                            }
                        }
                        else
                        {
                            row["Age"] = "";
                        }

                        dt.Rows.Add(row);
                    }
                }

                ViewState["ChildrenData"] = dt;
                gvChildren.DataSource = dt;
                gvChildren.DataBind();
                UpdateChildrenCount();
                upChildren.Update();
            }
        }

        private void LoadVehiclesData(int memberId)
        {
            DataTable dt = GetVehiclesTable();
            string sql = "SELECT StickerNo, VehicleNo, Model, Make, IssueDate FROM MemberVehicles WHERE MemberID = @MemberID AND RecordStatus = 'Active'";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                conn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        DataRow row = dt.NewRow();
                        row["StickerNo"] = dr["StickerNo"].ToString();
                        row["VehicleNo"] = dr["VehicleNo"].ToString();
                        row["Model"] = dr["Model"].ToString();
                        row["Make"] = dr["Make"].ToString();
                        row["IssueDate"] = dr["IssueDate"] != DBNull.Value ?
                            Convert.ToDateTime(dr["IssueDate"]).ToString("dd-MM-yyyy") : "";
                        dt.Rows.Add(row);
                    }
                }
            }
            ViewState["VehiclesData"] = dt;
            gvVehicles.DataSource = dt;
            gvVehicles.DataBind();
         
        }

        private void LoadSupplementaryData(int memberId)
        {
            string sql = "SELECT MembershipNo, SupplementaryName, Relationship, ValidityPeriod, RecordStatus, Remarks FROM SupplementaryMembers WHERE MemberID = @MemberID";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                conn.Open();

                DataTable dt = GetSupplementaryTable();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        DataRow row = dt.NewRow();
                        row["MembershipNo"] = reader["MembershipNo"].ToString();
                        row["SupplementaryName"] = reader["SupplementaryName"].ToString();
                        row["Relationship"] = reader["Relationship"].ToString();
                        row["ValidityPeriod"] = FormatDate(reader["ValidityPeriod"]);
                        row["RecordStatus"] = string.IsNullOrEmpty(reader["RecordStatus"].ToString()) ? "Active" : reader["RecordStatus"].ToString();
                        row["Remarks"] = reader["Remarks"].ToString();
                        dt.Rows.Add(row);
                    }
                }

                ViewState["SupplementaryData"] = dt;
                gvSupplementary.DataSource = dt;
                gvSupplementary.DataBind();
                UpdateSupplementaryCount();
            }
        }


        private void LoadClubsData(int memberId)
        {
            string sql = "SELECT ClubName, MembershipNo FROM MemberOtherClubs WHERE MemberID = @MemberID AND RecordStatus = 'Active'";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                conn.Open();

                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());
                ViewState["ClubsData"] = dt;
                gvClubs.DataSource = dt;
                gvClubs.DataBind();
                UpdateClubsCount();
            }
        }

        protected void cbCopyFromCompany_CheckedChanged(object sender, EventArgs e)
        {
            if (cbCopyFromCompany.Checked)
            {
                txtResidentialAddress1.Text = txtCompanyAddress1.Text;
                txtResidentialAddress2.Text = txtCompanyAddress2.Text;
                txtResidentialCity.Text = txtCompanyCity.Text;
                txtResidentialCountry.Text = ddlCompanyCountry.SelectedValue;
                txtResidentialPhone1.Text = txtCompanyPhone1.Text;
                txtResidentialPhone2.Text = txtCompanyPhone2.Text;
                txtResidentialFax.Text = txtCompanyFax.Text;
                txtResidentialMobile.Text = txtCompanyMobile.Text;
                txtResidentialEmail.Text = txtCompanyEmail.Text;
                txtResidentialEmail2.Text = txtCompanyEmail2.Text;

                if (string.IsNullOrEmpty(txtMailingAddress1.Text))
                {
                    txtMailingAddress1.Text = txtCompanyAddress1.Text;
                    txtMailingAddress2.Text = txtCompanyAddress2.Text;
                    txtMailingCity.Text = txtCompanyCity.Text;
                    txtMailingCountry.Text = ddlCompanyCountry.SelectedValue;
                    txtMailingPhone.Text = txtCompanyPhone1.Text;
                    txtMailingEmail.Text = txtCompanyEmail.Text;
                }

                cbCopyFromResidential.Checked = false;
            }
        }

        protected void cbCopyFromResidential_CheckedChanged(object sender, EventArgs e)
        {
            if (cbCopyFromResidential.Checked)
            {
                txtMailingAddress1.Text = txtResidentialAddress1.Text;
                txtMailingAddress2.Text = txtResidentialAddress2.Text;
                txtMailingCity.Text = txtResidentialCity.Text;
                txtMailingCountry.Text = txtResidentialCountry.Text;
                txtMailingPhone.Text = txtResidentialPhone1.Text;
                txtMailingEmail.Text = txtResidentialEmail.Text;

                cbCopyFromCompany.Checked = false;
            }
        }

        private int ParseInt(string textValue)
        {
            if (string.IsNullOrEmpty(textValue)) return 0;
            int result;
            return int.TryParse(textValue, out result) ? result : 0;
        }

        // Count update methods removed or cleaned
        private void UpdateSpousesCount() { }
        private void UpdateChildrenCount() { }
        private void UpdateNomineesCount() { }
        private void UpdateSupplementaryCount()
        {
            DataTable dt = ViewState["SupplementaryData"] as DataTable;
            if (dt != null)
            {
                hdnSupplementaryCount.Value = dt.Rows.Count.ToString();
            }
        }

        private void UpdateClubsCount()
        {
            DataTable dt = ViewState["ClubsData"] as DataTable;
            if (dt != null)
            {
                hdnClubsCount.Value = dt.Rows.Count.ToString();
            }
        }

        // Unused Children Grid events and methods removed
        private void LoadMemberBalance(int memberId)
        {
            if (memberId <= 0) return;

            // First, get the actual MemberNo string from the Member table
            string memberNo = txtMemberNo.Text.Trim();
            if (string.IsNullOrEmpty(memberNo))
            {
                using (SqlConnection conLookup = new SqlConnection(connectionString))
                {
                    conLookup.Open();
                    using (SqlCommand cmdLookup = new SqlCommand("SELECT MemberNo FROM Member WHERE MemberID = @MemberID", conLookup))
                    {
                        cmdLookup.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                        object result = cmdLookup.ExecuteScalar();
                        if (result != null) memberNo = result.ToString();
                    }
                }
            }
            if (string.IsNullOrEmpty(memberNo)) return;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "SELECT Credit, Dept FROM MemberPayment WHERE MemberNo = @MemberNo";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    // MemberPayment.MemberNo is varchar (e.g. 'P-2152'), so pass the string MemberNo
                    cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = memberNo;
                    con.Open();

                    decimal totalCredit = 0;
                    decimal totalDebit = 0;

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            decimal credit = 0;
                            decimal debit = 0;
                            decimal.TryParse(dr["Credit"].ToString(), out credit);
                            decimal.TryParse(dr["Dept"].ToString(), out debit);
                            totalCredit += credit;
                            totalDebit += debit;
                        }
                    }

                    decimal balance = totalCredit - totalDebit;
                    txtRemainingBalance.Text = string.Format("{0:N2}", balance);
                }
            }
        }

        protected void btnViewLedger_Click(object sender, EventArgs e)
        {
            int memberId = 0;
            if (!int.TryParse(hdnMemberID.Value, out memberId) || memberId <= 0)
            {
                // Try from query string if hdn is not set (e.g. initial view)
                if (!int.TryParse(Request.QueryString["MemberID"], out memberId))
                    return;
            }

            string memberNo = txtMemberNo.Text.Trim();
            DateTime? startDate = null;
            DateTime? endDate = null;

            if (!string.IsNullOrEmpty(txtLedgerStartDate.Text))
            {
                DateTime dt;
                if (TryParseDate(txtLedgerStartDate.Text, out dt))
                    startDate = dt;
            }
            if (!string.IsNullOrEmpty(txtLedgerEndDate.Text))
            {
                DateTime dt;
                if (TryParseDate(txtLedgerEndDate.Text, out dt))
                    endDate = dt;
            }

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "SELECT Date, Description, Dept, Credit FROM MemberPayment WHERE MemberNo = @MemberNo";

                if (startDate.HasValue)
                    query += " AND CAST(Date AS DATE) >= @StartDate";
                if (endDate.HasValue)
                    query += " AND CAST(Date AS DATE) <= @EndDate";

                query += " ORDER BY Date ASC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    // MemberPayment.MemberNo is varchar (e.g. 'P-2152'), so pass the string MemberNo
                    cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = memberNo;
                    if (startDate.HasValue) cmd.Parameters.Add("@StartDate", SqlDbType.DateTime).Value = startDate.Value;
                    if (endDate.HasValue) cmd.Parameters.Add("@EndDate", SqlDbType.DateTime).Value = endDate.Value;

                    con.Open();
                    DataTable ledgerDt = new DataTable();
                    ledgerDt.Columns.Add("Date", typeof(DateTime));
                    ledgerDt.Columns.Add("Description", typeof(string));
                    ledgerDt.Columns.Add("Debit", typeof(decimal));
                    ledgerDt.Columns.Add("Credit", typeof(decimal));
                    ledgerDt.Columns.Add("Balance", typeof(decimal));

                    decimal runningBalance = 0;

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            decimal credit = 0;
                            decimal debit = 0;
                            decimal.TryParse(dr["Credit"].ToString(), out credit);
                            decimal.TryParse(dr["Dept"].ToString(), out debit);

                            runningBalance += (credit - debit);

                            DataRow row = ledgerDt.NewRow();
                            row["Date"] = dr["Date"] != DBNull.Value ? Convert.ToDateTime(dr["Date"]) : DateTime.MinValue;
                            row["Description"] = dr["Description"].ToString();
                            row["Debit"] = debit;
                            row["Credit"] = credit;
                            row["Balance"] = runningBalance;
                            ledgerDt.Rows.Add(row);
                        }
                    }

                    gvLedger.DataSource = ledgerDt;
                    gvLedger.DataBind();

                    // Show the modal via Script - assuming standard JS approach
                    ScriptManager.RegisterStartupScript(this, GetType(), "showLedger", "document.getElementById('ledgerModal').style.display='flex';", true);
                }
            }
        }

        private void BindDropdowns()
        {
            try
            {
                // Category and Type are now TextBoxes and handled in LoadMember/LoadMemberData

                // Account Status and Residential Status are now readonly TextBoxes, no binding needed

                // Also bind other lookup dropdowns that are currently empty but needed
                BindDropdown(ddlTitle, "Title", "Prefix");
                // BindDropdown(ddlNationality, "Nationality", "Nationality");
                // BindDropdown(ddlMaritalStatus, "MaritalStatus", "MaritalStatus");
                // BindDropdown(ddlReligion, "Religion");
                // BindDropdown(ddlSector, "Sector");
                // BindDropdown(ddlPreferredContact, "PreferredContact");

                // Bind Country dropdowns if data exists
                // BindDropdown(ddlResidentialCountry, "Country");
                BindDropdown(ddlCompanyCountry, "CompanyCountry", "Country");
                // BindDropdown(ddlMailingCountry, "MailingCountry", "Country");
            }
            catch (Exception ex)
            {
                // Log error but don't crash the page
                System.Diagnostics.Debug.WriteLine("Error binding dropdowns: " + ex.Message);
            }
        }

        private void BindDropdown(DropDownList ddl, string profileColumn, string memberColumn = null)
        {
            if (ddl == null) return;
            if (memberColumn == null) memberColumn = profileColumn;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Dynamic check for column existence to prevent SQL errors if columns differ between tables
                bool hasProfileCol = false;
                bool hasMemberCol = false;

                using (SqlCommand cmdCheck = new SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @Table AND COLUMN_NAME = @Column", conn))
                {
                    cmdCheck.Parameters.Add("@Table", SqlDbType.NVarChar, 255).Value = "MemberProfile";
                    cmdCheck.Parameters.Add("@Column", SqlDbType.NVarChar, 255).Value = profileColumn;
                    hasProfileCol = (int)cmdCheck.ExecuteScalar() > 0;

                    cmdCheck.Parameters["@Table"].Value = "Member";
                    cmdCheck.Parameters["@Column"].Value = memberColumn;
                    hasMemberCol = (int)cmdCheck.ExecuteScalar() > 0;
                }

                if (!hasProfileCol && !hasMemberCol) return;

                List<string> subQueries = new List<string>();
                if (hasProfileCol) subQueries.Add(string.Format("SELECT DISTINCT [{0}] as Val FROM MemberProfile WHERE [{0}] IS NOT NULL AND [{0}] <> ''", profileColumn));
                if (hasMemberCol) subQueries.Add(string.Format("SELECT DISTINCT [{0}] as Val FROM Member WHERE [{0}] IS NOT NULL AND [{0}] <> ''", memberColumn));

                string sql = string.Format("SELECT DISTINCT Val FROM ({0}) AS combined WHERE Val IS NOT NULL ORDER BY Val", string.Join(" UNION ", subQueries));

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        string previousValue = ddl.SelectedValue;
                        ddl.Items.Clear();
                        ddl.Items.Add(new ListItem("-- Select --", ""));

                        while (reader.Read())
                        {
                            string text = reader["Val"].ToString();
                            ddl.Items.Add(new ListItem(text, text));
                        }

                        // Try to restore selected value if it still exists
                        if (!string.IsNullOrEmpty(previousValue))
                        {
                            ListItem item = ddl.Items.FindByValue(previousValue);
                            if (item != null) item.Selected = true;
                        }
                    }
                }
            }
        }
    }
}






















public static class AuditLogger
{
    /// <summary>
    /// Logs an action to the audit trail
    /// </summary>
    /// <param name="tableName">Name of the table being affected</param>
    /// <param name="recordId">ID of the record being affected</param>
    /// <param name="action">Action being performed (INSERT, UPDATE, DELETE, etc.)</param>
    /// <param name="userId">ID of the user performing the action</param>
    /// <param name="userName">Username of the user performing the action</param>
    /// <param name="oldValue">Previous value (for updates) - optional</param>
    /// <param name="newValue">New value (for inserts/updates) - optional</param>
    /// <param name="details">Additional details about the action - optional</param>
    /// <returns>LogID if successful, -1 if failed</returns>
    public static int Log(
        string tableName,
        string recordId,
        string action,
        string userId = null,
        string userName = null,
        string oldValue = null,
        string newValue = null,
        string details = null)
    {
        // Validate required parameters
        if (string.IsNullOrWhiteSpace(tableName))
            throw new ArgumentException("TableName cannot be null or empty", "tableName");

        if (string.IsNullOrWhiteSpace(recordId))
            throw new ArgumentException("RecordID cannot be null or empty", "recordId");

        if (string.IsNullOrWhiteSpace(action))
            throw new ArgumentException("Action cannot be null or empty", "action");

        int logId = -1;
        var msConnObj = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
        string connectionString = msConnObj != null ? msConnObj.ConnectionString : "";

        try
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_InsertAuditLog", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Add parameters
                    cmd.Parameters.Add("@TableName", SqlDbType.NVarChar, 255).Value = tableName;
                    cmd.Parameters.Add("@RecordID", SqlDbType.Int).Value = recordId;
                    cmd.Parameters.Add("@Action", SqlDbType.NVarChar, 255).Value = action;
                    int uId;
                    cmd.Parameters.Add("@UserId", SqlDbType.Int).Value = int.TryParse(userId, out uId) ? (object)uId : DBNull.Value;
                    cmd.Parameters.Add("@UserName", SqlDbType.NVarChar, 255).Value = string.IsNullOrEmpty(userName) ? (object)DBNull.Value : userName;
                    cmd.Parameters.Add("@OldValue", SqlDbType.NVarChar, 255).Value = string.IsNullOrEmpty(oldValue) ? (object)DBNull.Value : oldValue;
                    cmd.Parameters.Add("@NewValue", SqlDbType.NVarChar, 255).Value = string.IsNullOrEmpty(newValue) ? (object)DBNull.Value : newValue;
                    cmd.Parameters.Add("@Details", SqlDbType.NVarChar, 255).Value = string.IsNullOrEmpty(details) ? (object)DBNull.Value : details;

                    conn.Open();

                    // Execute and get the LogID
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        logId = Convert.ToInt32(result);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // Log the error (you could add error logging here)
            System.Diagnostics.Debug.WriteLine(string.Format("AuditLog Error: {0}", ex.Message));
            // Rethrow or handle as needed
            throw new Exception(string.Format("Failed to insert audit log: {0}", ex.Message), ex);
        }

        return logId;
    }

    /// <summary>
    /// Logs an INSERT action
    /// </summary>
    public static int LogInsert(string tableName, string recordId, string userId, string userName, string newValue = null, string details = null)
    {
        return Log(tableName, recordId, "INSERT", userId, userName, null, newValue, details);
    }

    /// <summary>
    /// Logs an UPDATE action
    /// </summary>
    public static int LogUpdate(string tableName, string recordId, string userId, string userName, string oldValue = null, string newValue = null, string details = null)
    {
        return Log(tableName, recordId, "UPDATE", userId, userName, oldValue, newValue, details);
    }

    /// <summary>
    /// Logs a DELETE action
    /// </summary>
    public static int LogDelete(string tableName, string recordId, string userId, string userName, string oldValue = null, string details = null)
    {
        return Log(tableName, recordId, "DELETE", userId, userName, oldValue, null, details);
    }

    /// <summary>
    /// Logs a custom action
    /// </summary>
    public static int LogAction(string tableName, string recordId, string action, string userId, string userName, string details = null)
    {
        return Log(tableName, recordId, action, userId, userName, null, null, details);
    }

    /// <summary>
    /// Fetches audit logs for a specific record
    /// </summary>
    /// <param name="recordId">Member ID or record ID</param>
    /// <returns>DataTable of logs</returns>
    public static DataTable GetLogs(string recordId)
    {
        return GetLogs(recordId, null, null);
    }

    public static DataTable GetLogs(string recordId, DateTime? startDate, DateTime? endDate)
    {
        var msConnObj2 = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
        string connectionString = msConnObj2 != null ? msConnObj2.ConnectionString : "";
        DataTable dt = new DataTable();

        try
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string sql = "SELECT [Action], [UserName], [Timestamp], [Details], [OldValue], [NewValue] FROM AuditLogs WHERE RecordID = @RecordID";

                if (startDate.HasValue)
                    sql += " AND [Timestamp] >= @StartDate";
                if (endDate.HasValue)
                    sql += " AND [Timestamp] <= @EndDate";

                sql += " ORDER BY [Timestamp] DESC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@RecordID", SqlDbType.Int).Value = recordId;

                    if (startDate.HasValue)
                        cmd.Parameters.Add("@StartDate", SqlDbType.DateTime).Value = startDate.Value;
                    if (endDate.HasValue)
                        cmd.Parameters.Add("@EndDate", SqlDbType.DateTime).Value = endDate.Value;

                    SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                    adapter.Fill(dt);
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine(string.Format("AuditLog GetLogs Error: {0}", ex.Message));
        }

        return dt;
    }
}
    



