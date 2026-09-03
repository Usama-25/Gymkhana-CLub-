using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Reflection;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ApplicationProcessing : System.Web.UI.Page
{
    private string financeConnStr = ConfigurationManager.ConnectionStrings["Finance_ConnectionString"].ConnectionString;

    private string con
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
            // Debugging: Show table schema to identify field length limits
            if (Request.QueryString["debug_schema"] == "1")
            {
                ShowSchemaInfo();
            }

            LoadMemberTypes();
            LoadMembershipClasses();
            LoadCountries();
            LoadProvinces();
            LoadCities(0);
            LoadProfessions();
            LoadDegrees();

            if (!string.IsNullOrEmpty(Request.QueryString["id"]))
            {
                txtAppTrackNo.Text = Request.QueryString["id"];
                LoadApplicantData();
                LoadDocuments();
                LoadPaymentTabData();
                ToggleFormControls(false);
                phFormContent.Visible = true;
                ViewState["IsExistingRecord"] = true;
            }
            else
            {
                ToggleFormControls(false);
                phFormContent.Visible = false;
                ViewState["IsExistingRecord"] = false;
            }
        }
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(txtMemberFee.Text))
        {
            txtMFee.Text = txtMemberFee.Text;
        }
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // Receipt ViewState Properties
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    public List<string> AllocatedReceipts
    {
        get
        {
            List<string> list = new List<string>();
            foreach (DataRow row in ReceiptDataTable.Rows)
                list.Add(row["ReceiptNo"].ToString());
            return list;
        }
    }

    public DataTable ReceiptDataTable
    {
        get
        {
            if (ViewState["ReceiptDataTable"] == null)
            {
                DataTable dt = new DataTable();
                dt.Columns.Add("ReceiptNo");
                dt.Columns.Add("ReceiptDate");
                dt.Columns.Add("Amount");
                dt.Columns.Add("IsSaved");
                ViewState["ReceiptDataTable"] = dt;
            }
            return (DataTable)ViewState["ReceiptDataTable"];
        }
        set { ViewState["ReceiptDataTable"] = value; }
    }

    private void BindAllocatedReceipts()
    {
        gvPaymentReceipts.DataSource = ReceiptDataTable;
        gvPaymentReceipts.DataBind();
        upPayment.Update();
    }

    protected void gvPaymentReceipts_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView drv = (DataRowView)e.Row.DataItem;
            string isSaved = drv["IsSaved"] != null ? drv["IsSaved"].ToString() : "false";
            if (isSaved.Equals("true", StringComparison.OrdinalIgnoreCase))
            {
                Button btnDelete = (Button)e.Row.FindControl("btnDeleteRcp");
                if (btnDelete != null)
                {
                    btnDelete.Visible = false;
                }
            }
        }
    }

    protected void gvAllocatedReceipts_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        string receiptNo = e.CommandArgument != null ? e.CommandArgument.ToString().Trim() : "";
        if (string.IsNullOrEmpty(receiptNo)) return;

        if (e.CommandName == "ViewReceipt")
        {
            string url = ResolveUrl("~/MemberShipModule/ReceiptReport.aspx?ReceiptNo=" + receiptNo);
            string script = "window.open('" + url + "', '_blank', 'width=800,height=900,scrollbars=yes');";
            ScriptManager.RegisterStartupScript(this, GetType(), "OpenReceipt", script, true);
        }
        else if (e.CommandName == "DeleteReceipt")
        {
            DataTable dt = ReceiptDataTable;
            if (dt != null)
            {
                for (int i = dt.Rows.Count - 1; i >= 0; i--)
                {
                    string curRNo = dt.Rows[i]["ReceiptNo"] != DBNull.Value ? dt.Rows[i]["ReceiptNo"].ToString().Trim() : "";
                    if (curRNo.Equals(receiptNo, StringComparison.OrdinalIgnoreCase))
                    {
                        dt.Rows.RemoveAt(i);
                        break;
                    }
                }
                dt.AcceptChanges();
                ReceiptDataTable = dt;
            }
            BindAllocatedReceipts();
            SyncWithCashierPaymentsByReceipts(AllocatedReceipts);
            if (upPayment != null) upPayment.Update();
            if (upPaymentSummary != null) upPaymentSummary.Update();
        }
    }

    private List<string> AllAllocatedReceipts()
    {
        return AllocatedReceipts;
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // Load Applicant Data
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    private void LoadApplicantData(string trackId = null)
    {
        string idToLoad = trackId ?? Request.QueryString["id"];
        if (string.IsNullOrEmpty(idToLoad)) return;

        txtAppTrackNo.Text = idToLoad;
        ViewState["IsExistingRecord"] = true;

        using (SqlConnection conn = new SqlConnection(con))
        using (SqlCommand cmd = new SqlCommand("usp_GetApplicantByTrackId", conn))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("@TrackID", SqlDbType.NVarChar, 50).Value = idToLoad;
            conn.Open();
            SqlDataReader dr = cmd.ExecuteReader();

            if (dr.Read())
            {
                txtFormFee.Text = dr["FormFee"] != DBNull.Value ? dr["FormFee"].ToString() : "0";

                if (dr["FormReceiptDate"] != DBNull.Value)
                    txtFormReceiptDate.Text = Convert.ToDateTime(dr["FormReceiptDate"]).ToString("dd-MM-yyyy");

                LoadAllocatedReceipts(Convert.ToInt32(idToLoad));
                SyncWithCashierPaymentsByReceipts(AllAllocatedReceipts());

                txtApplicantName.Text = dr["ApplicantName"].ToString();
                txtFatherName.Text = dr["FatherName"].ToString();
                txtDOB.Text = dr["DOB"] != DBNull.Value ? Convert.ToDateTime(dr["DOB"]).ToString("dd-MM-yyyy") : "";
                txtNIC.Text = dr["NIC"].ToString();
                ddlMaritalStatus.SelectedValue = dr["MaritalStatus"].ToString();
                txtProfession.Text = dr["Profession"].ToString();
                txtCompanyName.Text = dr["CompanyName"].ToString();
                txtDesignation.Text = dr["Designation"].ToString();
                ddlNationality.SelectedValue = dr["Nationality"].ToString();
                txtMonthlyIncome.Text = dr["MonthlyIncome"].ToString();
                ddlCurrency.SelectedValue = dr["Currency"].ToString();

                if (dr["Membership_class"] != DBNull.Value)
                {
                    string mClass = dr["Membership_class"].ToString();
                    ListItem item = ddlMembershipClass.Items.FindByText(mClass);
                    if (item != null)
                    {
                        ddlMembershipClass.SelectedValue = item.Value;
                        LoadMemberTypes(int.Parse(item.Value));

                        if (dr["MembershipType"] != DBNull.Value)
                        {
                            string mType = dr["MembershipType"].ToString();
                            ListItem typeItem = ddlMemberTypes.Items.FindByText(mType);
                            if (typeItem != null)
                                ddlMemberTypes.SelectedValue = typeItem.Value;
                        }
                    }
                }

                txtAddress.Text = dr["Address"].ToString();
                if (dr["Country"] != DBNull.Value && ddlCountry.Items.FindByText(dr["Country"].ToString()) != null)
                {
                    ddlCountry.SelectedValue = ddlCountry.Items.FindByText(dr["Country"].ToString()).Value;
                    int cId = 0;
                    int.TryParse(ddlCountry.SelectedValue, out cId);
                    LoadProvinces(cId, ddlProvince);
                }
                if (dr["Province"] != DBNull.Value && ddlProvince.Items.FindByText(dr["Province"].ToString()) != null)
                {
                    ddlProvince.SelectedValue = ddlProvince.Items.FindByText(dr["Province"].ToString()).Value;
                    int pId = 0;
                    int.TryParse(ddlProvince.SelectedValue, out pId);
                    LoadCities(pId, ddlCity);
                }
                if (dr["City"] != DBNull.Value && ddlCity.Items.FindByText(dr["City"].ToString()) != null)
                    ddlCity.SelectedValue = ddlCity.Items.FindByText(dr["City"].ToString()).Value;

                txtOfficeAddress.Text = dr["OfficeAddress"] != DBNull.Value ? dr["OfficeAddress"].ToString() : "";
                if (dr["OfficeCountry"] != DBNull.Value && ddlOfficeCountry.Items.FindByText(dr["OfficeCountry"].ToString()) != null)
                {
                    ddlOfficeCountry.SelectedValue = ddlOfficeCountry.Items.FindByText(dr["OfficeCountry"].ToString()).Value;
                    int coId = 0;
                    int.TryParse(ddlOfficeCountry.SelectedValue, out coId);
                    LoadProvinces(coId, ddlOfficeProvince);
                }
                if (dr["OfficeProvince"] != DBNull.Value && ddlOfficeProvince.Items.FindByText(dr["OfficeProvince"].ToString()) != null)
                {
                    ddlOfficeProvince.SelectedValue = ddlOfficeProvince.Items.FindByText(dr["OfficeProvince"].ToString()).Value;
                    int poId = 0;
                    int.TryParse(ddlOfficeProvince.SelectedValue, out poId);
                    LoadCities(poId, ddlOfficeCity);
                }
                if (dr["OfficeCity"] != DBNull.Value && ddlOfficeCity.Items.FindByText(dr["OfficeCity"].ToString()) != null)
                    ddlOfficeCity.SelectedValue = ddlOfficeCity.Items.FindByText(dr["OfficeCity"].ToString()).Value;

                txtZip.Text = dr["ZipCode"].ToString();
                txtPhone.Text = dr["Phone"].ToString();
                txtMobile.Text = dr["Mobile"].ToString();
                txtEmail.Text = dr["Email"].ToString();

                txtInstitute.Text = dr["Institute"].ToString();
                ddlDegree.SelectedValue = dr["Degree"].ToString();
                txtYear.Text = dr["Year"].ToString();
                txtWorkExperience.Text = dr["WorkExperience"].ToString();
                txtAreaInterest.Text = dr["AreaOfInterest"].ToString();
                txtFacilities.Text = dr["Facilities"].ToString();
                txtOtherMemberships.Text = dr["OtherMemberships"].ToString();
                txtPreferredNo.Text = dr["PreferredNo"].ToString();
                txtMFee.Text = dr["MFee"].ToString();

                txtSpouseName.Text = dr["SpouseName"] != DBNull.Value ? dr["SpouseName"].ToString() : "";
                txtNumberOfSpouse.Text = dr["NoOfSpouse"] != DBNull.Value ? dr["NoOfSpouse"].ToString() : "0";
                txtNumberOfSons.Text = dr["NoOfSons"] != DBNull.Value ? dr["NoOfSons"].ToString() : "0";
                txtNumberOfDaughters.Text = dr["NoOfDaughters"] != DBNull.Value ? dr["NoOfDaughters"].ToString() : "0";
                txtSP_CNIC.Text = dr["SpouseCNIC"] != DBNull.Value ? dr["SpouseCNIC"].ToString() : "";
                txtSpousePhone.Text = dr["SpousePhone"] != DBNull.Value ? dr["SpousePhone"].ToString() : "";
                ddlSpouseProfession.SelectedValue = dr["SpouseProfession"] != DBNull.Value ? dr["SpouseProfession"].ToString() : "";
                ddlEducation.SelectedValue = dr["SpouseEducation"] != DBNull.Value ? dr["SpouseEducation"].ToString() : "";

                LoadChildrenData(Convert.ToInt32(dr["TrackID"]));

                txtProposer1.Text = dr["Proposer1"] != DBNull.Value ? dr["Proposer1"].ToString() : "";
                txtRelation1.Text = dr["Relation1"] != DBNull.Value ? dr["Relation1"].ToString() : "";
                txtProposer2.Text = dr["Proposer2"] != DBNull.Value ? dr["Proposer2"].ToString() : "";
                txtRelation2.Text = dr["Relation2"] != DBNull.Value ? dr["Relation2"].ToString() : "";

                if (!string.IsNullOrEmpty(txtProposer1.Text)) txtProposer1_TextChanged(null, null);
                if (!string.IsNullOrEmpty(txtProposer2.Text)) txtProposer2_TextChanged(null, null);

                // Load Main Member No and fetch Name from MemberProfile
                try
                {
                    string mainMemberNo = dr["MainMemberNo"] != DBNull.Value ? dr["MainMemberNo"].ToString() : "";
                    if (!string.IsNullOrEmpty(mainMemberNo))
                    {
                        txtMainMemberNo.Text = mainMemberNo;
                        
                        using (SqlConnection conn2 = new SqlConnection(con))
                        {
                            string query = "SELECT MemberName FROM MemberProfile WHERE MemberNo = @MemberNo";
                            using (SqlCommand cmdName = new SqlCommand(query, conn2))
                            {
                                cmdName.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = mainMemberNo;
                                conn2.Open();
                                object nameObj = cmdName.ExecuteScalar();
                                if (nameObj != null && nameObj != DBNull.Value)
                                    txtMainMemberName.Text = nameObj.ToString();
                                else
                                    txtMainMemberName.Text = "Not Found";
                            }
                        }
                    }
                }
                catch { }

                if (dr["ApplicantPhotoPath"] != DBNull.Value)
                    Image1.ImageUrl = ResolveUrl(dr["ApplicantPhotoPath"].ToString());

                if (upApplicantForm != null) upApplicantForm.Update();

                LoadPaymentTabData();
                UpdateSaveButtonLabels("Update");
                ToggleFormControls(false);
                phFormContent.Visible = true;
                btnUpdate.Visible = true;
                upHeaderActions.Update();
                upMainFormContainer.Update();
            }
        }
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // Get Existing File Paths from DB
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    private Dictionary<string, string> GetExistingFilePaths(int trackId)
    {
        var paths = new Dictionary<string, string>();
        using (SqlConnection conn = new SqlConnection(con))
        using (SqlCommand cmd = new SqlCommand("usp_GetApplicantFilePaths", conn))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("@TrackID", SqlDbType.Int).Value = trackId;
            conn.Open();
            using (SqlDataReader dr = cmd.ExecuteReader())
            {
                if (dr.Read())
                {
                    if (dr["ApplicantPhotoPath"] != DBNull.Value && !string.IsNullOrEmpty(dr["ApplicantPhotoPath"].ToString()))
                        paths["Photo"] = dr["ApplicantPhotoPath"].ToString();
                    if (dr["CNICPath"] != DBNull.Value && !string.IsNullOrEmpty(dr["CNICPath"].ToString()))
                        paths["CNIC"] = dr["CNICPath"].ToString();
                    if (dr["ApplicationFormPath"] != DBNull.Value && !string.IsNullOrEmpty(dr["ApplicationFormPath"].ToString()))
                        paths["Form"] = dr["ApplicationFormPath"].ToString();
                }
            }
        }
        return paths;
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // Save Uploaded Files
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    private Dictionary<string, string> SaveUploadedFiles(int trackId)
    {
        var paths = GetExistingFilePaths(trackId);

        try
        {
            string uploadDir = Server.MapPath("~/Uploads/Documents/" + trackId + "/");
            if (!System.IO.Directory.Exists(uploadDir))
                System.IO.Directory.CreateDirectory(uploadDir);

            if (FileUpload1 != null && FileUpload1.HasFile)
            {
                string fileName = "Photo_" + trackId + "_" + DateTime.Now.ToString("yyyyMMddHHmmss") + System.IO.Path.GetExtension(FileUpload1.FileName);
                string filePath = System.IO.Path.Combine(uploadDir, fileName);
                FileUpload1.SaveAs(filePath);
                paths["Photo"] = "~/Uploads/Documents/" + trackId + "/" + fileName;
            }

            if (fuCNIC != null && fuCNIC.HasFile)
            {
                string fileName = "CNIC_" + trackId + "_" + DateTime.Now.ToString("yyyyMMddHHmmss") + System.IO.Path.GetExtension(fuCNIC.FileName);
                string filePath = System.IO.Path.Combine(uploadDir, fileName);
                fuCNIC.SaveAs(filePath);
                paths["CNIC"] = "~/Uploads/Documents/" + trackId + "/" + fileName;
                SaveDocumentRecord(trackId, "CNIC", fileName, filePath, fuCNIC.PostedFile.ContentLength);
            }

            if (fuForm != null && fuForm.HasFile)
            {
                string fileName = "Form_" + trackId + "_" + DateTime.Now.ToString("yyyyMMddHHmmss") + System.IO.Path.GetExtension(fuForm.FileName);
                string filePath = System.IO.Path.Combine(uploadDir, fileName);
                fuForm.SaveAs(filePath);
                paths["Form"] = "~/Uploads/Documents/" + trackId + "/" + fileName;
                SaveDocumentRecord(trackId, "Form", fileName, filePath, fuForm.PostedFile.ContentLength);
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("File Upload Error: " + ex.Message);
        }

        return paths;
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // UI Helpers
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    private void UpdateSaveButtonLabels(string text)
    {
        btnUpdate.Text = text;
        if (btnSavePersonal != null) btnSavePersonal.Text = text;
        if (btnSaveAddress != null) btnSaveAddress.Text = text;
        if (btnSaveFamily != null) btnSaveFamily.Text = text;
        if (btnSaveEducation != null) btnSaveEducation.Text = text;
        if (btnSaveReferences != null) btnSaveReferences.Text = text;
        if (btnSaveMembershipFinal != null) btnSaveMembershipFinal.Text = text;
        if (btnSavePaymentTab != null) btnSavePaymentTab.Text = text;

        string script = text == "Update" ? "" : "return confirm('Are you sure you want to save this application?');";
        if (btnSavePersonal != null) btnSavePersonal.OnClientClick = script;
        if (btnSaveAddress != null) btnSaveAddress.OnClientClick = script;
        if (btnSaveFamily != null) btnSaveFamily.OnClientClick = script;
        if (btnSaveEducation != null) btnSaveEducation.OnClientClick = script;
        if (btnSaveReferences != null) btnSaveReferences.OnClientClick = script;
        if (btnSaveMembershipFinal != null) btnSaveMembershipFinal.OnClientClick = script;
        if (btnSavePaymentTab != null) btnSavePaymentTab.OnClientClick = script;
    }

    private void ToggleFormControls(bool enabled)
    {
        if (phFormContent != null)
            ToggleRecursive(phFormContent, enabled);

        gvChildren.Enabled = enabled;
    }

    private void ToggleRecursive(Control parent, bool enabled)
    {
        foreach (Control c in parent.Controls)
        {
            if (c is TextBox && ((TextBox)c).ID != "txtAppTrackNo" && ((TextBox)c).ID != "txtPopupReceiptNo")
                ((TextBox)c).ReadOnly = !enabled;
            else if (c is DropDownList && ((DropDownList)c).ID != "ddlNationality")
                ((DropDownList)c).Enabled = enabled;
            else if (c is CheckBox)
                ((CheckBox)c).Enabled = enabled;
            else if (c is System.Web.UI.WebControls.FileUpload)
                ((System.Web.UI.WebControls.FileUpload)c).Enabled = enabled;
            else if (c is Button)
            {
                Button b = (Button)c;
                if (b.ID != "btnNewApplication" && b.ID != "btnUpdate" && b.ID != "btnSavePopupReceipt" && b.Text != "Previous" && b.Text != "Next")
                    b.Enabled = enabled;
            }

            if (c.HasControls())
                ToggleRecursive(c, enabled);
        }
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // Button Events
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    protected void btnNewApplication_Click(object sender, EventArgs e)
    {
        ClearFormFields();
        int nextTrackId = 1;
        using (SqlConnection conn = new SqlConnection(con))
        using (SqlCommand cmd = new SqlCommand("usp_GetNextTrackId", conn))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            conn.Open();
            nextTrackId = Convert.ToInt32(cmd.ExecuteScalar());
        }
        txtAppTrackNo.Text = nextTrackId.ToString();
        ToggleFormControls(true);
        UpdateSaveButtonLabels("Save");
        phFormContent.Visible = true;
        btnUpdate.Visible = true;
        btnUpdate.Text = "Save";
        ViewState["IsExistingRecord"] = false;
        upHeaderActions.Update();
        upMainFormContainer.Update();
        ScriptManager.RegisterStartupScript(this, GetType(), "newApp", "showSection('divPayment', null);", true);
    }

    protected void btnUpdate_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(txtAppTrackNo.Text))
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "err", "alert('No application loaded.');", true);
            return;
        }

        if (btnUpdate.Text == "Update")
        {
            ToggleFormControls(true);
            UpdateSaveButtonLabels("Save Changes");
            btnUpdate.Text = "Save Changes";
            txtAppTrackNo.ReadOnly = true;
        }
        else
        {
            btnSaveMembership_Click(sender, e);
        }
        upHeaderActions.Update();
        upMainFormContainer.Update();
    }

    private void ClearFormFields()
    {
        txtApplicantName.Text = "";
        txtFatherName.Text = "";
        txtDOB.Text = "";
        txtNIC.Text = "";
        ddlMaritalStatus.SelectedIndex = 0;
        txtProfession.Text = "";
        txtCompanyName.Text = "";
        txtDesignation.Text = "";
        ddlNationality.SelectedIndex = 0;
        txtMonthlyIncome.Text = "0";
        ddlCurrency.SelectedIndex = 0;
        txtAddress.Text = "";
        ddlCountry.SelectedIndex = 0;
        LoadProvinces(0);
        LoadCities(0);
        txtOfficeAddress.Text = "";
        ddlOfficeCountry.SelectedIndex = 0;
        txtZip.Text = "";
        txtPhone.Text = "";
        txtMobile.Text = "";
        txtEmail.Text = "";
        txtInstitute.Text = "";
        ddlDegree.SelectedIndex = 0;
        txtYear.Text = "";
        txtWorkExperience.Text = "";
        txtAreaInterest.Text = "";
        txtFacilities.Text = "";
        txtOtherMemberships.Text = "";
        txtPreferredNo.Text = "";
        txtMFee.Text = "0";
        txtSpouseName.Text = "";
        txtNumberOfSpouse.Text = "0";
        txtNumberOfSons.Text = "0";
        txtNumberOfDaughters.Text = "0";
        txtSP_CNIC.Text = "";
        txtSpousePhone.Text = "";
        ddlSpouseProfession.SelectedIndex = 0;
        LoadProfessions();
        LoadDegrees();
        ddlEducation.SelectedIndex = 0;
        ddlMembershipClass.SelectedIndex = 0;
        LoadMemberTypes(0);
        txtProposer1.Text = "";
        txtRelation1.Text = "";
        if (lblProposer1Badge != null) { lblProposer1Badge.Text = ""; lblProposer1Badge.Visible = false; }
        txtProposer2.Text = "";
        txtRelation2.Text = "";
        if (lblProposer2Badge != null) { lblProposer2Badge.Text = ""; lblProposer2Badge.Visible = false; }
        txtMainMemberNo.Text = "";
        txtMainMemberName.Text = "";
        if (lblMainMemberBadge != null) { lblMainMemberBadge.Text = ""; lblMainMemberBadge.Visible = false; }
        Image1.ImageUrl = "";
        childrenList = new List<ChildItem>();
        BindChildrenGrid();
        txtFormReceiptNo.Text = "";
        txtFormReceiptDate.Text = "";
        txtFormFee.Text = "0";
        txtMemberReceiptNo.Text = "";
        txtMemberReceiptDate.Text = "";
        txtMemberFee.Text = "";
        ReceiptDataTable.Clear();
        BindAllocatedReceipts();
        ViewState["IsExistingRecord"] = false;
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // MAIN SAVE - FIXED for UPDATE
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    protected void btnSaveMembership_Click(object sender, EventArgs e)
    {
        // 0. If button text is "Update", only allow fields to edit (toggle logic)
        Button clickedBtn = sender as Button;
        if (clickedBtn != null && clickedBtn.Text == "Update")
        {
            ToggleFormControls(true);
            UpdateSaveButtonLabels("Save Changes");
            btnUpdate.Text = "Save Changes";
            txtAppTrackNo.ReadOnly = true;
            upMainFormContainer.Update();
            upHeaderActions.Update();
            return;
        }

        // Validate Proposer 1
        if (!string.IsNullOrEmpty(txtProposer1.Text.Trim()))
        {
            string mNo1 = GetMemberNoOnly(txtProposer1.Text.Trim());
            string p1Name, p1Status;
            if (!GetMemberNameAndStatus(mNo1, out p1Name, out p1Status))
            {
                SetStatusBadge(lblProposer1Badge, "Not Found", false);
                ScriptManager.RegisterStartupScript(this, GetType(), "alertNoSaveP1",
                    "alert('Cannot save application: Proposer 1 Member No (" + mNo1 + ") was not found.');", true);
                return;
            }
        }

        // Validate Proposer 2
        if (!string.IsNullOrEmpty(txtProposer2.Text.Trim()))
        {
            string mNo2 = GetMemberNoOnly(txtProposer2.Text.Trim());
            string p2Name, p2Status;
            if (!GetMemberNameAndStatus(mNo2, out p2Name, out p2Status))
            {
                SetStatusBadge(lblProposer2Badge, "Not Found", false);
                ScriptManager.RegisterStartupScript(this, GetType(), "alertNoSaveP2",
                    "alert('Cannot save application: Proposer 2 Member No (" + mNo2 + ") was not found.');", true);
                return;
            }
        }

        try
        {
            int trackId = 0;
            bool isUpdate = false;

            // 1. Try to get TrackID from the textbox
            if (!string.IsNullOrEmpty(txtAppTrackNo.Text.Trim()))
            {
                if (int.TryParse(txtAppTrackNo.Text.Trim(), out trackId))
                {
                    // Check if it exists in DB to determine if it's an update or just a pre-allocated ID
                    using (SqlConnection conn = new SqlConnection(con))
                    using (SqlCommand cmd = new SqlCommand("usp_CheckTrackIdExists", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@TrackID", SqlDbType.Int).Value = trackId;
                        conn.Open();
                        isUpdate = (int)cmd.ExecuteScalar() > 0;
                    }
                }
            }

            // 2. If no valid ID found or generated yet, handle new record logic
            if (trackId == 0)
            {
                // New record - check for duplicate NIC first
                string currentNIC = txtNIC.Text.Trim();
                if (!string.IsNullOrEmpty(currentNIC))
                {
                    using (SqlConnection connCheck = new SqlConnection(con))
                    using (SqlCommand cmdCheck = new SqlCommand("usp_GetTrackIdByNic", connCheck))
                    {
                        cmdCheck.CommandType = CommandType.StoredProcedure;
                        cmdCheck.Parameters.Add("@NIC", SqlDbType.NVarChar, 50).Value = currentNIC;
                        connCheck.Open();
                        object existingTracker = cmdCheck.ExecuteScalar();
                        if (existingTracker != null)
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "alertDup",
                                "alert('An application with this NIC already exists under Track ID: " + existingTracker.ToString() + ". Please load that record instead.');", true);
                            return;
                        }
                    }
                }

                // Generate new TrackID since we don't have one
                using (SqlConnection conn = new SqlConnection(con))
                using (SqlCommand cmd = new SqlCommand("usp_GetNextTrackId", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    conn.Open();
                    trackId = Convert.ToInt32(cmd.ExecuteScalar());
                    txtAppTrackNo.Text = trackId.ToString();
                }
                isUpdate = false;
            }

            // Save files - merges with existing paths
            var filePaths = SaveUploadedFiles(trackId);

            using (SqlConnection conn = new SqlConnection(con))
            {
                if (conn.State != ConnectionState.Open) conn.Open();

                // UPSERT Logic: Use IF EXISTS to ensure only one record per TrackID
                using (SqlCommand cmd = new SqlCommand("usp_UpsertApplicant", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    AddCommonParameters(cmd, filePaths, trackId);
                    cmd.ExecuteNonQuery();
                }

                // Log the action
                string empId = Session["EmpID"] != null ? Session["EmpID"].ToString() : (Session["Emp_ID"] != null ? Session["Emp_ID"].ToString() : "0");
                string empName = Session["EmpName"] != null ? Session["EmpName"].ToString() : (Session["UserName"] != null ? Session["UserName"].ToString() : "System");
                string logAction = isUpdate ? "UPDATE" : "INSERT";
                string logDetails = string.Format("{0} application for {1} (Track ID: {2})", logAction, txtApplicantName.Text.Trim(), trackId);
                AuditLogger.Log("ApplicationFForm", trackId.ToString(), logAction, empId, empName, details: logDetails);

                // Save receipts (only new ones)
                if (AllAllocatedReceipts().Count > 0)
                {
                    DataTable dtReceipts = ReceiptDataTable;
                    foreach (DataRow rcpRow in dtReceipts.Rows)
                    {
                        if (rcpRow["IsSaved"].ToString().Equals("true", StringComparison.OrdinalIgnoreCase))
                            continue;

                        string rcp = rcpRow["ReceiptNo"].ToString();

                        using (SqlCommand cmdCheckInfo = new SqlCommand("usp_CheckReceiptAllocated", conn))
                        {
                            cmdCheckInfo.CommandType = CommandType.StoredProcedure;
                            cmdCheckInfo.Parameters.Add("@TrackID", SqlDbType.Int).Value = trackId;
                            cmdCheckInfo.Parameters.Add("@ReceiptNo", SqlDbType.NVarChar, 50).Value = rcp;
                            int exists = (int)cmdCheckInfo.ExecuteScalar();

                            if (exists == 0)
                            {
                                using (SqlCommand cmdInsertReceipt = new SqlCommand("usp_InsertApplicationReceipt", conn))
                                {
                                    cmdInsertReceipt.CommandType = CommandType.StoredProcedure;
                                    cmdInsertReceipt.Parameters.Add("@TrackID", SqlDbType.Int).Value = trackId;
                                    cmdInsertReceipt.Parameters.Add("@CNIC", SqlDbType.NVarChar, 50).Value = txtNIC.Text.Trim();
                                    cmdInsertReceipt.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = txtApplicantName.Text.Trim();
                                    cmdInsertReceipt.Parameters.Add("@ReceiptNo", SqlDbType.NVarChar, 50).Value = rcp;
                                    cmdInsertReceipt.ExecuteNonQuery();
                                }
                            }
                        }
                    }
                }

                // Mark all receipts as saved
                DataTable dtSync = ReceiptDataTable;
                foreach (DataRow row in dtSync.Rows)
                    row["IsSaved"] = "true";
                ReceiptDataTable = dtSync;
                
                BindAllocatedReceipts();

                SaveChildrenData(trackId);
                LoadDocuments(trackId);
                ToggleFormControls(false);
                UpdateSaveButtonLabels("Update");
                btnUpdate.Text = "Update";
                btnUpdate.Visible = true;
                ViewState["IsExistingRecord"] = true;
                upHeaderActions.Update();

                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    string.Format("alert('Application {0} successfully.');", isUpdate ? "updated" : "saved"), true);
            }
        }
        catch (SqlException sqlEx)
        {
            string errorMsg = "Database error: " + sqlEx.Message;
            if (sqlEx.Message.ToLower().Contains("cannot insert"))
                errorMsg = "Cannot insert duplicate record. Please check if this application already exists.";
            else if (sqlEx.Message.ToLower().Contains("truncated"))
                errorMsg = "One or more fields contain text that is too long.\n\nDetails: " + sqlEx.Message;

            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                string.Format("alert('{0}');", errorMsg.Replace("'", "\\'").Replace("\n", "\\n")), true);
        }
        catch (Exception ex)
        {
            string errorMsg = "Error saving application: " + ex.Message;
            if (ex.InnerException != null)
                errorMsg += "\nDetails: " + ex.InnerException.Message;

            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                string.Format("alert('{0}');", errorMsg.Replace("'", "\\'")), true);
        }
    }

    private string CleanValue(string val)
    {
        if (string.IsNullOrEmpty(val)) return "";
        val = val.Trim();
        if (val.Contains(","))
        {
            string[] parts = val.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length > 1)
            {
                // Check if all parts are identical (ignoring case/whitespace)
                bool allSame = true;
                string first = parts[0].Trim();
                for (int i = 1; i < parts.Length; i++)
                {
                    if (!string.Equals(parts[i].Trim(), first, StringComparison.OrdinalIgnoreCase))
                    {
                        allSame = false;
                        break;
                    }
                }
                if (allSame) return first;
            }
        }
        return val;
    }

    private void AddCommonParameters(SqlCommand cmd, Dictionary<string, string> filePaths, int trackId)
    {
        cmd.Parameters.Add("@TrackID", SqlDbType.Int).Value = trackId;
        cmd.Parameters.Add("@ApplicantName", SqlDbType.NVarChar, 200).Value = CleanValue(txtApplicantName.Text);
        cmd.Parameters.Add("@Membership_class", SqlDbType.NVarChar, 100).Value = ddlMembershipClass.SelectedIndex > 0 ? ddlMembershipClass.SelectedItem.Text : "";
        cmd.Parameters.Add("@MembershipType", SqlDbType.NVarChar, 100).Value = ddlMemberTypes.SelectedIndex > 0 ? ddlMemberTypes.SelectedItem.Text : "";
        cmd.Parameters.Add("@FatherName", SqlDbType.NVarChar, 200).Value = CleanValue(txtFatherName.Text);
        cmd.Parameters.Add("@NIC", SqlDbType.NVarChar, 50).Value = CleanValue(txtNIC.Text);

        DateTime dob;
        cmd.Parameters.Add("@DOB", SqlDbType.DateTime).Value = DateTime.TryParseExact(txtDOB.Text.Trim(), "dd-MM-yyyy", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out dob) ? dob : (DateTime.TryParse(txtDOB.Text.Trim(), out dob) ? dob : (object)DBNull.Value);

        cmd.Parameters.Add("@MaritalStatus", SqlDbType.NVarChar, 50).Value = ddlMaritalStatus.SelectedValue;
        cmd.Parameters.Add("@Profession", SqlDbType.NVarChar, 100).Value = CleanValue(txtProfession.Text);
        cmd.Parameters.Add("@CompanyName", SqlDbType.NVarChar, 200).Value = CleanValue(txtCompanyName.Text);
        cmd.Parameters.Add("@Designation", SqlDbType.NVarChar, 100).Value = CleanValue(txtDesignation.Text);
        cmd.Parameters.Add("@Nationality", SqlDbType.NVarChar, 100).Value = ddlNationality.SelectedValue;

        decimal income;
        cmd.Parameters.Add("@MonthlyIncome", SqlDbType.Decimal).Value = decimal.TryParse(txtMonthlyIncome.Text.Trim(), out income) ? income : (object)DBNull.Value;
        cmd.Parameters.Add("@Currency", SqlDbType.NVarChar, 50).Value = ddlCurrency.SelectedValue;

        cmd.Parameters.Add("@Address", SqlDbType.NVarChar, 500).Value = CleanValue(txtAddress.Text);
        cmd.Parameters.Add("@City", SqlDbType.NVarChar, 100).Value = ddlCity.SelectedItem != null && ddlCity.SelectedItem.Text != "--Select--" ? ddlCity.SelectedItem.Text : "";
        cmd.Parameters.Add("@Province", SqlDbType.NVarChar, 100).Value = ddlProvince.SelectedItem != null && ddlProvince.SelectedItem.Text != "--Select--" ? ddlProvince.SelectedItem.Text : "";
        cmd.Parameters.Add("@Country", SqlDbType.NVarChar, 100).Value = ddlCountry.SelectedItem != null && ddlCountry.SelectedItem.Text != "--Select--" ? ddlCountry.SelectedItem.Text : "";
        cmd.Parameters.Add("@ZipCode", SqlDbType.NVarChar, 50).Value = CleanValue(txtZip.Text);
        cmd.Parameters.Add("@Phone", SqlDbType.NVarChar, 50).Value = CleanValue(txtPhone.Text);
        cmd.Parameters.Add("@Mobile", SqlDbType.NVarChar, 50).Value = CleanValue(txtMobile.Text);
        cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 200).Value = CleanValue(txtEmail.Text);

        cmd.Parameters.Add("@OfficeAddress", SqlDbType.NVarChar, 500).Value = CleanValue(txtOfficeAddress.Text);
        cmd.Parameters.Add("@OfficeCity", SqlDbType.NVarChar, 100).Value = ddlOfficeCity.SelectedItem != null && ddlOfficeCity.SelectedItem.Text != "--Select--" ? ddlOfficeCity.SelectedItem.Text : "";
        cmd.Parameters.Add("@OfficeProvince", SqlDbType.NVarChar, 100).Value = ddlOfficeProvince.SelectedItem != null && ddlOfficeProvince.SelectedItem.Text != "--Select--" ? ddlOfficeProvince.SelectedItem.Text : "";
        cmd.Parameters.Add("@OfficeCountry", SqlDbType.NVarChar, 100).Value = ddlOfficeCountry.SelectedItem != null && ddlOfficeCountry.SelectedItem.Text != "--Select--" ? ddlOfficeCountry.SelectedItem.Text : "";

        cmd.Parameters.Add("@Institute", SqlDbType.NVarChar, 200).Value = CleanValue(txtInstitute.Text);
        cmd.Parameters.Add("@Degree", SqlDbType.NVarChar, 100).Value = ddlDegree.SelectedValue;
        cmd.Parameters.Add("@Year", SqlDbType.NVarChar, 50).Value = CleanValue(txtYear.Text);
        cmd.Parameters.Add("@WorkExperience", SqlDbType.NVarChar, 200).Value = CleanValue(txtWorkExperience.Text);
        cmd.Parameters.Add("@AreaOfInterest", SqlDbType.NVarChar, 200).Value = CleanValue(txtAreaInterest.Text);
        cmd.Parameters.Add("@Facilities", SqlDbType.NVarChar, 500).Value = CleanValue(txtFacilities.Text);
        cmd.Parameters.Add("@OtherMemberships", SqlDbType.NVarChar, 500).Value = CleanValue(txtOtherMemberships.Text);
        cmd.Parameters.Add("@PreferredNo", SqlDbType.NVarChar, 50).Value = CleanValue(txtPreferredNo.Text);

        decimal mf = 0;
        cmd.Parameters.Add("@MFee", SqlDbType.Decimal).Value = decimal.TryParse(txtMFee.Text.Trim(), out mf) ? (object)mf : DBNull.Value;

        cmd.Parameters.Add("@SpouseName", SqlDbType.NVarChar, 200).Value = CleanValue(txtSpouseName.Text);
        cmd.Parameters.Add("@SpouseCNIC", SqlDbType.NVarChar, 50).Value = CleanValue(txtSP_CNIC.Text);
        cmd.Parameters.Add("@SpousePhone", SqlDbType.NVarChar, 50).Value = CleanValue(txtSpousePhone.Text);
        cmd.Parameters.Add("@SpouseProfession", SqlDbType.NVarChar, 100).Value = ddlSpouseProfession.SelectedValue;
        cmd.Parameters.Add("@SpouseEducation", SqlDbType.NVarChar, 100).Value = ddlEducation.SelectedValue;

        int nSpouse, nSons, nDaughters;
        cmd.Parameters.Add("@NoOfSpouse", SqlDbType.Int).Value = int.TryParse(txtNumberOfSpouse.Text.Trim(), out nSpouse) ? nSpouse : 0;
        cmd.Parameters.Add("@NoOfSons", SqlDbType.Int).Value = int.TryParse(txtNumberOfSons.Text.Trim(), out nSons) ? nSons : 0;
        cmd.Parameters.Add("@NoOfDaughters", SqlDbType.Int).Value = int.TryParse(txtNumberOfDaughters.Text.Trim(), out nDaughters) ? nDaughters : 0;

        cmd.Parameters.Add("@Proposer1", SqlDbType.NVarChar, 100).Value = CleanValue(txtProposer1.Text);
        cmd.Parameters.Add("@Relation1", SqlDbType.NVarChar, 100).Value = CleanValue(txtRelation1.Text);
        cmd.Parameters.Add("@Proposer2", SqlDbType.NVarChar, 100).Value = CleanValue(txtProposer2.Text);
        cmd.Parameters.Add("@Relation2", SqlDbType.NVarChar, 100).Value = CleanValue(txtRelation2.Text);

        cmd.Parameters.Add("@ApplicantPhotoPath", SqlDbType.NVarChar, 500).Value = filePaths.ContainsKey("Photo") ? filePaths["Photo"] : "";
        cmd.Parameters.Add("@CNICPath", SqlDbType.NVarChar, 500).Value = filePaths.ContainsKey("CNIC") ? filePaths["CNIC"] : "";
        cmd.Parameters.Add("@ApplicationFormPath", SqlDbType.NVarChar, 500).Value = filePaths.ContainsKey("Form") ? filePaths["Form"] : "";

        cmd.Parameters.Add("@ReceiptNo", SqlDbType.NVarChar, 50).Value = CleanValue(txtFormReceiptNo.Text);
        decimal ff;
        cmd.Parameters.Add("@FormFee", SqlDbType.Decimal).Value = decimal.TryParse(txtFormFee.Text.Trim(), out ff) ? ff : 0;
        DateTime frd;
        cmd.Parameters.Add("@FormReceiptDate", SqlDbType.DateTime).Value = DateTime.TryParseExact(txtFormReceiptDate.Text.Trim(), "dd-MM-yyyy", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out frd) ? frd : (DateTime.TryParse(txtFormReceiptDate.Text.Trim(), out frd) ? frd : (object)DBNull.Value);
        
        // Add Main Member No and Name for Supplementary Membership
        string mainMemberNo = txtMainMemberNo.Text;
        string mainMemberName = txtMainMemberName.Text;

        // Fallback to Request.Form if controls are empty (due to visibility toggling)
        if (string.IsNullOrEmpty(mainMemberNo))
        {
            foreach (string key in Request.Form.AllKeys)
            {
                if (key != null && key.EndsWith("txtMainMemberNo"))
                {
                    mainMemberNo = Request.Form[key];
                    break;
                }
            }
        }
        if (string.IsNullOrEmpty(mainMemberName))
        {
            foreach (string key in Request.Form.AllKeys)
            {
                if (key != null && key.EndsWith("txtMainMemberName"))
                {
                    mainMemberName = Request.Form[key];
                    break;
                }
            }
        }

        cmd.Parameters.Add("@MainMemberNo", SqlDbType.NVarChar, 50).Value = CleanValue(mainMemberNo);
        cmd.Parameters.Add("@MainMemberName", SqlDbType.NVarChar, 100).Value = CleanValue(mainMemberName);
        int membershipTypeId;
        cmd.Parameters.Add("@MemberShipTypeID", SqlDbType.Int).Value = int.TryParse(ddlMembershipClass.SelectedValue, out membershipTypeId) ? membershipTypeId : (object)DBNull.Value;
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // Receipt Popup - Fixed
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    protected void btnSavePopupReceipt_Click(object sender, EventArgs e)
    {
        string receiptNo = txtPopupReceiptNo.Text.Trim();
        string receiptDate = txtPopupReceiptDate.Text.Trim();
        string amountStr = txtPopupReceiptAmount.Text.Trim();

        if (string.IsNullOrEmpty(receiptNo))
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alertError", "alert('Please enter Receipt No.');", true);
            return;
        }

        if (AllAllocatedReceipts().Contains(receiptNo))
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alertError", "alert('This receipt is already added.');", true);
            return;
        }

        using (SqlConnection conn = new SqlConnection(con))
        {
            using (SqlCommand cmdCheck = new SqlCommand("usp_CheckReceiptUsage", conn))
            {
                cmdCheck.CommandType = CommandType.StoredProcedure;
                cmdCheck.Parameters.Add("@ReceiptNo", SqlDbType.NVarChar, 50).Value = receiptNo;
                conn.Open();
                using (SqlDataReader rdr = cmdCheck.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        string allocatedTrackId = rdr["TrackID"].ToString();
                        ScriptManager.RegisterStartupScript(this, GetType(), "alertError",
                            "alert('This Receipt No is already allocated to Track ID: " + allocatedTrackId + "');", true);
                        return;
                    }
                }
            }
        }

        DataTable dt = ReceiptDataTable;
        DataRow dr = dt.NewRow();
        dr["ReceiptNo"] = receiptNo;
        dr["ReceiptDate"] = receiptDate;
        dr["Amount"] = amountStr;
        dr["IsSaved"] = "false";
        dt.Rows.Add(dr);
        ReceiptDataTable = dt;

        BindAllocatedReceipts();
        SyncWithCashierPaymentsByReceipts(AllAllocatedReceipts());

        txtPopupReceiptNo.Text = "";
        txtPopupReceiptDate.Text = "";
        txtPopupReceiptAmount.Text = "";
        upPayment.Update();

        ScriptManager.RegisterStartupScript(this, GetType(), "closeModal", "closeReceiptModal();", true);
    }

    protected void txtPopupReceiptNo_TextChanged(object sender, EventArgs e)
    {
        string receiptNo = txtPopupReceiptNo.Text.Trim();
        if (string.IsNullOrEmpty(receiptNo)) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(financeConnStr))
            {
                using (SqlCommand cmd = new SqlCommand("usp_GetReceiptDetails", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@ReceiptNo", SqlDbType.NVarChar, 255).Value = receiptNo;
                    conn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            if (dr["ReceiptDate"] != DBNull.Value)
                                txtPopupReceiptDate.Text = Convert.ToDateTime(dr["ReceiptDate"]).ToString("dd-MM-yyyy");

                            if (dr["Amount"] != DBNull.Value)
                                txtPopupReceiptAmount.Text = dr["Amount"].ToString();

                            ScriptManager.RegisterStartupScript(this, GetType(), "showModal", "openReceiptModal();", true);
                        }
                        else
                        {
                            txtPopupReceiptDate.Text = "";
                            txtPopupReceiptAmount.Text = "";
                            ScriptManager.RegisterStartupScript(this, GetType(), "alertNotFound",
                                "alert('Receipt details not found in finance records.');", true);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alertError",
                "alert('Error fetching receipt: " + ex.Message.Replace("'", "\\'") + "');", true);
        }
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // Allocated Receipts
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    private void LoadAllocatedReceipts(int trackId)
    {
        DataTable dt = ReceiptDataTable;
        dt.Rows.Clear();

        List<string> receiptNumbers = new List<string>();
        using (SqlConnection conn = new SqlConnection(con))
        {
            using (SqlCommand cmd = new SqlCommand("usp_GetApplicantReceipts", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@TrackID", SqlDbType.Int).Value = trackId;
                conn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                    while (dr.Read())
                        receiptNumbers.Add(dr["ReceiptNo"].ToString());
            }
        }

        if (receiptNumbers.Count > 0)
        {
            using (SqlConnection conn = new SqlConnection(financeConnStr))
            {
                conn.Open();
                foreach (string rNo in receiptNumbers)
                {
                    using (SqlCommand cmd = new SqlCommand("usp_GetReceiptDetails", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@ReceiptNo", SqlDbType.NVarChar, 255).Value = rNo;
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            DataRow row = dt.NewRow();
                            row["ReceiptNo"] = rNo;
                            row["IsSaved"] = "true";
                            if (dr.Read())
                            {
                                row["ReceiptDate"] = dr["ReceiptDate"] != DBNull.Value ? Convert.ToDateTime(dr["ReceiptDate"]).ToString("dd-MM-yyyy") : "";
                                row["Amount"] = dr["Amount"] != DBNull.Value ? dr["Amount"].ToString() : "0";
                            }
                            else
                            {
                                row["ReceiptDate"] = "";
                                row["Amount"] = "0";
                            }
                            dt.Rows.Add(row);
                        }
                    }
                }
            }
        }

        ReceiptDataTable = dt;
        BindAllocatedReceipts();
    }

    private void SyncWithCashierPaymentsByReceipts(List<string> receiptNos)
    {
        if (receiptNos == null || receiptNos.Count == 0)
        {
            txtFormFee.Text = "0";
            txtMemberFee.Text = "0";
            txtMFee.Text = "0";
            txtFormReceiptNo.Text = "";
            txtFormReceiptDate.Text = "";
            txtMemberReceiptNo.Text = "";
            txtMemberReceiptDate.Text = "";
            upTopFees.Update();
            return;
        }

        string receiptList = string.Join(",", receiptNos);

        using (SqlConnection conConn = new SqlConnection(financeConnStr))
        using (SqlCommand cmdPayment = new SqlCommand("usp_GetPaymentSummaryByReceipts", conConn))
        {
            cmdPayment.CommandType = CommandType.StoredProcedure;
            cmdPayment.Parameters.Add("@ReceiptList", SqlDbType.NVarChar, 255).Value = receiptList;
                conConn.Open();
                using (SqlDataReader dr = cmdPayment.ExecuteReader())
                {
                    if (dr.Read() && Convert.ToInt32(dr["TransactionCount"]) > 0)
                    {
                        decimal formFee = dr["FormFeeTotal"] != DBNull.Value ? Convert.ToDecimal(dr["FormFeeTotal"]) : 0;
                        decimal memberFee = dr["MemberFeeTotal"] != DBNull.Value ? Convert.ToDecimal(dr["MemberFeeTotal"]) : 0;

                        txtFormFee.Text = formFee.ToString("N0");
                        txtMemberFee.Text = memberFee.ToString("N0");
                        txtMFee.Text = txtMemberFee.Text;

                        txtFormReceiptNo.Text = dr["LatestFormReceiptNo"] != DBNull.Value ? dr["LatestFormReceiptNo"].ToString() : "";
                        txtMemberReceiptNo.Text = dr["LatestMemberReceiptNo"] != DBNull.Value ? dr["LatestMemberReceiptNo"].ToString() : "";

                        txtFormReceiptDate.Text = dr["LatestFormFeeDate"] != DBNull.Value
                            ? Convert.ToDateTime(dr["LatestFormFeeDate"]).ToString("dd-MM-yyyy") : "";
                        txtMemberReceiptDate.Text = dr["LatestMemberFeeDate"] != DBNull.Value
                            ? Convert.ToDateTime(dr["LatestMemberFeeDate"]).ToString("dd-MM-yyyy") : "";

                        upTopFees.Update();
                    }
                }
            }

        // Calculate total payments from all allocated receipts in ReceiptDataTable
        decimal totalAmount = 0;
        DataTable dtRecs = ReceiptDataTable;
        if (dtRecs != null)
        {
            foreach (DataRow row in dtRecs.Rows)
            {
                if (row["Amount"] != DBNull.Value)
                {
                    decimal amt = 0;
                    if (decimal.TryParse(row["Amount"].ToString().Replace(",", ""), out amt))
                    {
                        totalAmount += amt;
                    }
                }
            }
        }

        if (txtTotalPaymentsDisplay != null)
        {
            txtTotalPaymentsDisplay.Text = totalAmount.ToString("N0");
        }
        if (upPaymentSummary != null)
        {
            upPaymentSummary.Update();
        }
        }

    protected void LoadPaymentTabData(string searchReceipt = "", string searchCnic = "")
    {
        BindAllocatedReceipts();
    }

    protected void btnSearchPayment_Click(object sender, EventArgs e) { }
    protected void btnClearSearch_Click(object sender, EventArgs e) { }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // Dropdowns
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    private void LoadMemberTypes(int mainId = 0)
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(con))
            {
                DataTable dt = new DataTable();
                if (mainId > 0)
                {
                    using (SqlCommand cmd = new SqlCommand("usp_GetSubTypesByMainId", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@MainId", SqlDbType.Int).Value = mainId;
                        conn.Open();
                        new SqlDataAdapter(cmd).Fill(dt);
                    }
                }
                ddlMemberTypes.DataSource = dt;
                ddlMemberTypes.DataTextField = "SubTypeName";
                ddlMemberTypes.DataValueField = "Id";
                ddlMemberTypes.DataBind();
            }
        }
        catch { }
        if (ddlMemberTypes.Items.Count == 0 || ddlMemberTypes.Items[0].Value != "0")
        {
            ddlMemberTypes.Items.Insert(0, new ListItem("--Select--", "0"));
        }
    }

    private void LoadMembershipClasses()
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(con))
            {
                using (SqlCommand cmd = new SqlCommand("usp_GetFormTypeMainForDropdown", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    conn.Open();
                    DataTable dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);
                    ddlMembershipClass.DataSource = dt;
                    ddlMembershipClass.DataTextField = "FormTypeName";
                    ddlMembershipClass.DataValueField = "Id";
                    ddlMembershipClass.DataBind();
                }
            }
        }
        catch { }
        if (ddlMembershipClass.Items.Count == 0 || ddlMembershipClass.Items[0].Value != "0")
        {
            ddlMembershipClass.Items.Insert(0, new ListItem("--Select--", "0"));
        }
    }

    protected void ddlMembershipClass_SelectedIndexChanged(object sender, EventArgs e)
    {
        int mainId = 0;
        int.TryParse(ddlMembershipClass.SelectedValue, out mainId);
        LoadMemberTypes(mainId);
        
        // Toggle Supplementary fields
        if (mainId == 9 || (ddlMembershipClass.SelectedItem != null && ddlMembershipClass.SelectedItem.Text == "Non Earning MemberShip"))
        {
            divSupplementary.Visible = true;
        }
        else
        {
            divSupplementary.Visible = false;
            txtMainMemberNo.Text = "";
            txtMainMemberName.Text = "";
        }
        
        if (upTopFees != null) upTopFees.Update();
    }

    private string GetMemberNoOnly(string input)
    {
        if (string.IsNullOrEmpty(input)) return "";
        string val = input.Trim();
        if (val.Contains(" - "))
        {
            string[] parts = val.Split(new[] { " - " }, StringSplitOptions.None);
            if (parts.Length > 0 && !string.IsNullOrEmpty(parts[0].Trim()))
                return parts[0].Trim();
        }
        return val;
    }

    private void SetStatusBadge(Label lblBadge, string status, bool found)
    {
        if (lblBadge == null) return;
        if (!found || string.IsNullOrEmpty(status))
        {
            lblBadge.Text = "Not Found";
            lblBadge.Visible = true;
            lblBadge.Style["background-color"] = "#fee2e2";
            lblBadge.Style["color"] = "#dc2626";
            lblBadge.Style["border"] = "1px solid #fca5a5";
        }
        else
        {
            lblBadge.Text = status;
            lblBadge.Visible = true;
            if (status.Equals("Active", StringComparison.OrdinalIgnoreCase))
            {
                lblBadge.Style["background-color"] = "#dcfce7";
                lblBadge.Style["color"] = "#166534";
                lblBadge.Style["border"] = "1px solid #86efac";
            }
            else
            {
                lblBadge.Style["background-color"] = "#fef3c7";
                lblBadge.Style["color"] = "#92400e";
                lblBadge.Style["border"] = "1px solid #fde68a";
            }
        }
    }

    protected void txtMainMemberNo_TextChanged(object sender, EventArgs e)
    {
        string raw = txtMainMemberNo.Text.Trim();
        if (string.IsNullOrEmpty(raw))
        {
            txtMainMemberName.Text = "";
            if (lblMainMemberBadge != null) { lblMainMemberBadge.Text = ""; lblMainMemberBadge.Visible = false; }
            return;
        }

        string memberNo = GetMemberNoOnly(raw);
        string name, status;
        if (GetMemberNameAndStatus(memberNo, out name, out status))
        {
            txtMainMemberNo.Text = string.Format("{0} - {1}", memberNo, name);
            txtMainMemberName.Text = name;
            if (lblMainMemberBadge != null) SetStatusBadge(lblMainMemberBadge, status, true);
        }
        else
        {
            txtMainMemberNo.Text = memberNo;
            txtMainMemberName.Text = "Not Found";
            if (lblMainMemberBadge != null) SetStatusBadge(lblMainMemberBadge, "Not Found", false);
            ScriptManager.RegisterStartupScript(this, GetType(), "alertMainMember", "alert('Main Member No (" + memberNo + ") not found.');", true);
        }
        if (upTopFees != null) upTopFees.Update();
        if (upApplicantForm != null) upApplicantForm.Update();
    }

    private bool GetMemberNameAndStatus(string memberNo, out string name, out string status)
    {
        name = "";
        status = "";
        if (string.IsNullOrEmpty(memberNo)) return false;

        using (SqlConnection conn = new SqlConnection(con))
        {
            string query = "SELECT MemberName, ISNULL(Status, ISNULL(AccountStatus, 'Active')) AS Status FROM MemberProfile WHERE MemberNo = @MemberNo";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = memberNo;
                conn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        name = dr["MemberName"] != DBNull.Value ? dr["MemberName"].ToString() : "";
                        status = dr["Status"] != DBNull.Value ? dr["Status"].ToString() : "Active";
                        return true;
                    }
                }
            }
        }
        return false;
    }

    protected void txtProposer1_TextChanged(object sender, EventArgs e)
    {
        string raw = txtProposer1.Text.Trim();
        if (string.IsNullOrEmpty(raw))
        {
            if (lblProposer1Badge != null) { lblProposer1Badge.Text = ""; lblProposer1Badge.Visible = false; }
            return;
        }

        string memberNo = GetMemberNoOnly(raw);
        string name, status;
        if (GetMemberNameAndStatus(memberNo, out name, out status))
        {
            txtProposer1.Text = string.Format("{0} - {1}", memberNo, name);
            SetStatusBadge(lblProposer1Badge, status, true);
        }
        else
        {
            txtProposer1.Text = memberNo;
            SetStatusBadge(lblProposer1Badge, "Not Found", false);
            ScriptManager.RegisterStartupScript(this, GetType(), "alertProp1", "alert('Proposer 1 Member No (" + memberNo + ") not found.');", true);
        }
        if (upApplicantForm != null) upApplicantForm.Update();
    }

    protected void txtProposer2_TextChanged(object sender, EventArgs e)
    {
        string raw = txtProposer2.Text.Trim();
        if (string.IsNullOrEmpty(raw))
        {
            if (lblProposer2Badge != null) { lblProposer2Badge.Text = ""; lblProposer2Badge.Visible = false; }
            return;
        }

        string memberNo = GetMemberNoOnly(raw);
        string name, status;
        if (GetMemberNameAndStatus(memberNo, out name, out status))
        {
            txtProposer2.Text = string.Format("{0} - {1}", memberNo, name);
            SetStatusBadge(lblProposer2Badge, status, true);
        }
        else
        {
            txtProposer2.Text = memberNo;
            SetStatusBadge(lblProposer2Badge, "Not Found", false);
            ScriptManager.RegisterStartupScript(this, GetType(), "alertProp2", "alert('Proposer 2 Member No (" + memberNo + ") not found.');", true);
        }
        if (upApplicantForm != null) upApplicantForm.Update();
    }

    private void LoadCountries()
    {
        using (SqlConnection conn = new SqlConnection(con))
        {
            DataTable dt = new DataTable();
            using (SqlCommand cmd = new SqlCommand("usp_GetCountries", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                conn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
            }

            ddlCountry.DataSource = dt;
            ddlCountry.DataTextField = "CountryName";
            ddlCountry.DataValueField = "CountryID";
            ddlCountry.DataBind();
            ddlCountry.Items.Insert(0, new ListItem("--Select--", "0"));

            ddlOfficeCountry.DataSource = dt;
            ddlOfficeCountry.DataTextField = "CountryName";
            ddlOfficeCountry.DataValueField = "CountryID";
            ddlOfficeCountry.DataBind();
            ddlOfficeCountry.Items.Insert(0, new ListItem("--Select--", "0"));
        }
    }

    private void LoadProvinces(int countryId = 0, DropDownList ddl = null)
    {
        DataTable dt = new DataTable();
        if (countryId > 0)
        {
            using (SqlConnection conn = new SqlConnection(con))
            using (SqlCommand cmd = new SqlCommand("usp_GetProvincesByCountryId", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@CountryID", SqlDbType.Int).Value = countryId;
                conn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
            }
        }

        if (ddl != null)
        {
            ddl.DataSource = dt;
            ddl.DataTextField = "ProvinceName";
            ddl.DataValueField = "ProvinceID";
            ddl.DataBind();
            ddl.Items.Insert(0, new ListItem("--Select--", "0"));
        }
        else
        {
            ddlProvince.DataSource = dt;
            ddlProvince.DataTextField = "ProvinceName";
            ddlProvince.DataValueField = "ProvinceID";
            ddlProvince.DataBind();
            ddlProvince.Items.Insert(0, new ListItem("--Select--", "0"));

            ddlOfficeProvince.DataSource = dt;
            ddlOfficeProvince.DataTextField = "ProvinceName";
            ddlOfficeProvince.DataValueField = "ProvinceID";
            ddlOfficeProvince.DataBind();
            ddlOfficeProvince.Items.Insert(0, new ListItem("--Select--", "0"));
        }
    }

    private void LoadCities(int provinceId = 0, DropDownList ddl = null)
    {
        DataTable dt = new DataTable();
        if (provinceId > 0)
        {
            using (SqlConnection conn = new SqlConnection(con))
            using (SqlCommand cmd = new SqlCommand("usp_GetCitiesByProvinceId", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@ProvinceID", SqlDbType.Int).Value = provinceId;
                conn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
            }
        }

        if (ddl != null)
        {
            ddl.DataSource = dt;
            ddl.DataTextField = "CityName";
            ddl.DataValueField = "CityID";
            ddl.DataBind();
            ddl.Items.Insert(0, new ListItem("--Select--", "0"));
        }
        else
        {
            ddlCity.DataSource = dt;
            ddlCity.DataTextField = "CityName";
            ddlCity.DataValueField = "CityID";
            ddlCity.DataBind();
            ddlCity.Items.Insert(0, new ListItem("--Select--", "0"));

            ddlOfficeCity.DataSource = dt;
            ddlOfficeCity.DataTextField = "CityName";
            ddlOfficeCity.DataValueField = "CityID";
            ddlOfficeCity.DataBind();
            ddlOfficeCity.Items.Insert(0, new ListItem("--Select--", "0"));
        }
    }

    private void LoadProfessions()
    {
        using (SqlConnection conn = new SqlConnection(con))
        {
            DataTable dt = new DataTable();
            using (SqlCommand cmd = new SqlCommand("usp_GetProfessions", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                conn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
            }
            ddlSpouseProfession.DataSource = dt;
            ddlSpouseProfession.DataTextField = "ProfessionName";
            ddlSpouseProfession.DataValueField = "ProfessionName";
            ddlSpouseProfession.DataBind();
            ddlSpouseProfession.Items.Insert(0, new ListItem("--Select--", ""));
            ddlSpouseProfession.SelectedIndex = 0;
        }
    }

    private void LoadDegrees()
    {
        using (SqlConnection conn = new SqlConnection(con))
        {
            DataTable dt = new DataTable();
            using (SqlCommand cmd = new SqlCommand("usp_GetDegrees", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                conn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
            }

            ddlEducation.DataSource = dt;
            ddlEducation.DataTextField = "DegreeName";
            ddlEducation.DataValueField = "DegreeName";
            ddlEducation.DataBind();
            ddlEducation.Items.Insert(0, new ListItem("--Select--", ""));
            ddlEducation.SelectedIndex = 0;

            ddlDegree.DataSource = dt;
            ddlDegree.DataTextField = "DegreeName";
            ddlDegree.DataValueField = "DegreeName";
            ddlDegree.DataBind();
            ddlDegree.Items.Insert(0, new ListItem("--Select--", ""));
            ddlDegree.SelectedIndex = 0;
        }
    }

    protected void ddlCountry_SelectedIndexChanged(object sender, EventArgs e)
    {
        int countryId = 0;
        int.TryParse(ddlCountry.SelectedValue, out countryId);
        LoadProvinces(countryId, ddlProvince);
        LoadCities(0, ddlCity);
        if (upMainFormContainer != null) upMainFormContainer.Update();
    }

    protected void ddlOfficeCountry_SelectedIndexChanged(object sender, EventArgs e)
    {
        int countryId = 0;
        int.TryParse(ddlOfficeCountry.SelectedValue, out countryId);
        LoadProvinces(countryId, ddlOfficeProvince);
        LoadCities(0, ddlOfficeCity);
        if (upMainFormContainer != null) upMainFormContainer.Update();
    }

    protected void ddlProvince_SelectedIndexChanged(object sender, EventArgs e)
    {
        int provinceId = 0;
        int.TryParse(ddlProvince.SelectedValue, out provinceId);
        LoadCities(provinceId, ddlCity);
        if (upMainFormContainer != null) upMainFormContainer.Update();
    }

    protected void ddlOfficeProvince_SelectedIndexChanged(object sender, EventArgs e)
    {
        int provinceId = 0;
        int.TryParse(ddlOfficeProvince.SelectedValue, out provinceId);
        LoadCities(provinceId, ddlOfficeCity);
        if (upMainFormContainer != null) upMainFormContainer.Update();
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // Documents
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    private void LoadDocuments(int? explicitTrackId = null)
    {
        string id = explicitTrackId.HasValue ? explicitTrackId.Value.ToString() : Request.QueryString["id"];
        if (string.IsNullOrEmpty(id)) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(con))
            using (SqlCommand cmd = new SqlCommand("usp_GetApplicantDocuments", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@TrackID", SqlDbType.Int).Value = id;
                conn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        if (dr["CNICPath"] != DBNull.Value)
                        {
                            string cnicPath = dr["CNICPath"].ToString();
                            lnkCNIC.NavigateUrl = ResolveUrl(cnicPath);
                            divCNICLink.Visible = true;
                            lblCNICStatus.Text = "Current: " + System.IO.Path.GetFileName(cnicPath);
                        }
                        if (dr["ApplicationFormPath"] != DBNull.Value)
                        {
                            string formPath = dr["ApplicationFormPath"].ToString();
                            lnkForm.NavigateUrl = ResolveUrl(formPath);
                            divFormLink.Visible = true;
                            lblFormStatus.Text = "Current: " + System.IO.Path.GetFileName(formPath);
                        }
                    }
                }
            }
        }
        catch (Exception) { }
    }

    private void SaveDocumentRecord(int trackId, string docType, string fileName, string filePath, int fileSize)
    {
        using (SqlConnection conn = new SqlConnection(con))
        using (SqlCommand cmd = new SqlCommand("usp_InsertMemberDocument", conn))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("@TrackID", SqlDbType.Int).Value = trackId;
            cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = DBNull.Value;
            cmd.Parameters.Add("@DocumentType", SqlDbType.NVarChar, 255).Value = docType;
            cmd.Parameters.Add("@FileName", SqlDbType.NVarChar, 255).Value = fileName;
            cmd.Parameters.Add("@FilePath", SqlDbType.NVarChar, 255).Value = filePath;
            cmd.Parameters.Add("@FileSize", SqlDbType.NVarChar, 255).Value = fileSize;
            conn.Open();
            cmd.ExecuteNonQuery();
        }
    }

    private bool IsValidActiveMember(string memberNo)
    {
        using (SqlConnection conn = new SqlConnection(con))
        using (SqlCommand cmd = new SqlCommand("usp_CheckActiveMember", conn))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = memberNo;
            conn.Open();
            return (int)cmd.ExecuteScalar() > 0;
        }
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // Children Grid
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    [Serializable]
    public class ChildItem
    {
        public int ID { get; set; }
        public string ChildName { get; set; }
        public string Relationship { get; set; }
        public DateTime? DOB { get; set; }
        public string Age { get; set; }
        public string CNICNo { get; set; }
    }
    // Helper method that returns the options
    protected List<ListItem> GetRelationOptions()
    {
        List<ListItem> options = new List<ListItem>();
        options.Add(new ListItem("Select Relation", ""));
        options.Add(new ListItem("Son", "SON"));
        options.Add(new ListItem("Daughter", "DAUGHTER"));
        return options;
    }
    private List<ChildItem> childrenList
    {
        get
        {
            if (ViewState["ChildrenList"] == null)
                ViewState["ChildrenList"] = new List<ChildItem>();
            return (List<ChildItem>)ViewState["ChildrenList"];
        }
        set { ViewState["ChildrenList"] = value; }
    }
    protected void gvChildren_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DropDownList ddlRel = (DropDownList)e.Row.FindControl("ddlChildRelation");

            if (ddlRel != null)
            {
                // CRITICAL: Populate the DropDownList with valid options
                ddlRel.Items.Clear();
                ddlRel.Items.Add(new ListItem("Select Relation", ""));
                ddlRel.Items.Add(new ListItem("Son", "SON"));
                ddlRel.Items.Add(new ListItem("Daughter", "DAUGHTER"));

                // Now safely set the selected value with case-insensitive check
                var dataItem = (ChildItem)e.Row.DataItem;
                if (dataItem != null && !string.IsNullOrEmpty(dataItem.Relationship))
                {
                    string relVal = dataItem.Relationship.Trim().ToUpper();
                    ListItem selectedItem = ddlRel.Items.FindByValue(relVal);
                    if (selectedItem != null)
                    {
                        ddlRel.SelectedValue = relVal;
                    }
                    else
                    {
                        ddlRel.SelectedValue = "";
                    }
                }
            }

            // Also handle the DOB TextBox to enforce date format
            TextBox txtDOBChild = (TextBox)e.Row.FindControl("txtChildDOB");
            if (txtDOBChild != null && e.Row.DataItem != null)
            {
                var child = (ChildItem)e.Row.DataItem;
                if (child.DOB.HasValue)
                {
                    txtDOBChild.Text = child.DOB.Value.ToString("dd-MM-yyyy");
                }
            }
        }
    }

    private void LoadChildrenData(int trackId)
    {
        List<ChildItem> list = new List<ChildItem>();
        using (SqlConnection conn = new SqlConnection(con))
        using (SqlCommand cmd = new SqlCommand("usp_GetApplicationChildren", conn))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("@TrackID", SqlDbType.Int).Value = trackId;
            conn.Open();
            using (SqlDataReader dr = cmd.ExecuteReader())
            {
                while (dr.Read())
                {
                    list.Add(new ChildItem
                    {
                        ID = (int)dr["ID"],
                        ChildName = dr["ChildName"] != DBNull.Value ? dr["ChildName"].ToString() : "",
                        Relationship = dr["Relationship"] != DBNull.Value ? dr["Relationship"].ToString() : "SON",
                        DOB = dr["DOB"] != DBNull.Value ? (DateTime?)dr["DOB"] : null,
                        Age = dr["Age"] != DBNull.Value ? dr["Age"].ToString() : "",
                        CNICNo = dr["CNICNo"] != DBNull.Value ? dr["CNICNo"].ToString() : ""
                    });
                }
            }
        }
        childrenList = list;
        BindChildrenGrid();
    }

    private void BindChildrenGrid()
    {
        gvChildren.DataSource = childrenList;
        gvChildren.DataBind();
        UpdateFamilyCounts();
    }

    protected void btnAddChild_Click(object sender, EventArgs e)
    {
        UpdateChildrenListFromGrid();
        childrenList.Add(new ChildItem { ChildName = "", Relationship = "SON", CNICNo = "" });
        BindChildrenGrid();
    }

    protected void gvChildren_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "DeleteChild")
        {
            UpdateChildrenListFromGrid();
            int index = Convert.ToInt32(e.CommandArgument);
            if (index >= 0 && index < childrenList.Count)
            {
                childrenList.RemoveAt(index);
                BindChildrenGrid();
            }
        }
    }

    protected void ddlChildRelation_SelectedIndexChanged(object sender, EventArgs e)
    {
        // Update the childrenList with the new selection
        UpdateChildrenListFromGrid();

        // Instead of full rebind, just update the counts and UI
        UpdateFamilyCounts();

        // Mark that the grid needs to maintain its state
        // Do NOT call BindChildrenGrid() here as it will cause the error
    }

    private void UpdateFamilyCounts()
    {
        int sons = 0, daughters = 0;
        foreach (var child in childrenList)
        {
            if (child.Relationship == "SON")
                sons++;
            else if (child.Relationship == "DAUGHTER")
                daughters++;
        }

        txtNumberOfSons.Text = sons.ToString();
        txtNumberOfDaughters.Text = daughters.ToString();
        upFamilyCounts.Update();
    }
    protected void txtChildDOB_TextChanged(object sender, EventArgs e)
    {
        TextBox txtDOBChild = (TextBox)sender;
        GridViewRow row = (GridViewRow)txtDOBChild.NamingContainer;

        // Only update the specific row instead of full update
        int index = row.RowIndex;
        if (index >= 0 && index < childrenList.Count)
        {
            DateTime dob;
            if (DateTime.TryParseExact(txtDOBChild.Text.Trim(), "dd-MM-yyyy",
                System.Globalization.CultureInfo.InvariantCulture,
                System.Globalization.DateTimeStyles.None, out dob) ||
                DateTime.TryParse(txtDOBChild.Text, out dob))
            {
                int age = DateTime.Today.Year - dob.Year;
                if (dob.Date > DateTime.Today.AddYears(-age)) age--;

                childrenList[index].DOB = dob;
                childrenList[index].Age = age.ToString();
            }
            else
            {
                childrenList[index].DOB = null;
                childrenList[index].Age = "";
            }

            // Update just the age display without full rebind
            TextBox txtAge = (TextBox)row.FindControl("txtChildAge");
            if (txtAge != null)
            {
                txtAge.Text = childrenList[index].Age;
            }
        }

        // Don't call BindChildrenGrid() here
    }

    private void UpdateChildrenListFromGrid()
    {
        if (childrenList.Count != gvChildren.Rows.Count) return;

        for (int i = 0; i < gvChildren.Rows.Count; i++)
        {
            GridViewRow row = gvChildren.Rows[i];
            if (row.RowType == DataControlRowType.DataRow)
            {
                TextBox txtName = (TextBox)row.FindControl("txtChildName");
                DropDownList ddlRel = (DropDownList)row.FindControl("ddlChildRelation");
                TextBox txtDOBChild = (TextBox)row.FindControl("txtChildDOB");
                TextBox txtCNIC = (TextBox)row.FindControl("txtChildCNIC");

                var item = childrenList[i];
                item.ChildName = txtName.Text;

                // SAFE: Check if DropDownList has a valid selection
                if (ddlRel != null && ddlRel.SelectedIndex > 0) // Index 0 is "Select Relation"
                {
                    item.Relationship = ddlRel.SelectedValue;
                }
                else if (ddlRel != null && ddlRel.SelectedIndex == 0)
                {
                    item.Relationship = ""; // Or keep existing value
                }

                // Parse DOB safely
                if (!string.IsNullOrEmpty(txtDOBChild.Text))
                {
                    DateTime d;
                    if (DateTime.TryParseExact(txtDOBChild.Text.Trim(), "dd-MM-yyyy",
                        System.Globalization.CultureInfo.InvariantCulture,
                        System.Globalization.DateTimeStyles.None, out d) ||
                        DateTime.TryParse(txtDOBChild.Text, out d))
                    {
                        item.DOB = d;
                        int age = DateTime.Now.Year - d.Year;
                        if (DateTime.Now < d.AddYears(age)) age--;
                        item.Age = age.ToString();
                    }
                    else
                    {
                        item.DOB = null;
                        item.Age = "";
                    }
                }
                else
                {
                    item.DOB = null;
                    item.Age = "";
                }

                item.CNICNo = txtCNIC.Text;
            }
        }
    }

    private void SaveChildrenData(int trackId)
    {
        UpdateChildrenListFromGrid();
        using (SqlConnection conn = new SqlConnection(con))
        {
            conn.Open();
            using (SqlCommand cmdDel = new SqlCommand("usp_DeleteApplicationChildren", conn))
            {
                cmdDel.CommandType = CommandType.StoredProcedure;
                cmdDel.Parameters.Add("@TrackID", SqlDbType.Int).Value = trackId;
                cmdDel.ExecuteNonQuery();
            }

            foreach (var child in childrenList)
            {
                // Only save children with valid names
                if (string.IsNullOrEmpty(child.ChildName))
                    continue;

                using (SqlCommand cmdIns = new SqlCommand("usp_InsertApplicationChild", conn))
                {
                    cmdIns.CommandType = CommandType.StoredProcedure;
                    cmdIns.Parameters.Add("@TrackID", SqlDbType.Int).Value = trackId;
                    cmdIns.Parameters.Add("@ChildName", SqlDbType.NVarChar, 200).Value = child.ChildName ?? "";
                    cmdIns.Parameters.Add("@Relationship", SqlDbType.NVarChar, 50).Value = child.Relationship ?? "Son";
                    cmdIns.Parameters.Add("@DOB", SqlDbType.DateTime).Value = (object)child.DOB ?? DBNull.Value;
                    cmdIns.Parameters.Add("@Age", SqlDbType.Int).Value = (object)child.Age ?? DBNull.Value;
                    cmdIns.Parameters.Add("@CNICNo", SqlDbType.NVarChar, 50).Value = child.CNICNo ?? "";
                    cmdIns.ExecuteNonQuery();
                }
            }
        }
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // Audit Logger
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    public static class AuditLogger
    {
        public static int Log(
            string tableName, string recordId, string action,
            string userId = null, string userName = null,
            string oldValue = null, string newValue = null, string details = null)
        {
            if (string.IsNullOrWhiteSpace(tableName)) throw new ArgumentException("TableName cannot be null or empty", "tableName");
            if (string.IsNullOrWhiteSpace(recordId)) throw new ArgumentException("RecordID cannot be null or empty", "recordId");
            if (string.IsNullOrWhiteSpace(action)) throw new ArgumentException("Action cannot be null or empty", "action");

            int logId = -1;
            var msConnObj = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
            string connectionString = msConnObj != null ? msConnObj.ConnectionString : "";

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand("sp_InsertAuditLog", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@TableName", SqlDbType.NVarChar, 100).Value = tableName;
                    cmd.Parameters.Add("@RecordID", SqlDbType.NVarChar, 50).Value = recordId;
                    cmd.Parameters.Add("@Action", SqlDbType.NVarChar, 50).Value = action;
                    cmd.Parameters.Add("@UserId", SqlDbType.NVarChar, 50).Value = (object)userId ?? DBNull.Value;
                    cmd.Parameters.Add("@UserName", SqlDbType.NVarChar, 100).Value = (object)userName ?? DBNull.Value;
                    cmd.Parameters.Add("@OldValue", SqlDbType.NVarChar, 4000).Value = (object)oldValue ?? DBNull.Value;
                    cmd.Parameters.Add("@NewValue", SqlDbType.NVarChar, 4000).Value = (object)newValue ?? DBNull.Value;
                    cmd.Parameters.Add("@Details", SqlDbType.NVarChar, 4000).Value = (object)details ?? DBNull.Value;
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        logId = Convert.ToInt32(result);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(string.Format("AuditLog Error: {0}", ex.Message));
                throw new Exception(string.Format("Failed to insert audit log: {0}", ex.Message), ex);
            }
            return logId;
        }

        public static int LogInsert(string tableName, string recordId, string userId, string userName, string newValue = null, string details = null)
        {
            return Log(tableName, recordId, "INSERT", userId, userName, null, newValue, details);
        }

        public static int LogUpdate(string tableName, string recordId, string userId, string userName, string oldValue = null, string newValue = null, string details = null)
        {
            return Log(tableName, recordId, "UPDATE", userId, userName, oldValue, newValue, details);
        }

        public static int LogDelete(string tableName, string recordId, string userId, string userName, string oldValue = null, string details = null)
        {
            return Log(tableName, recordId, "DELETE", userId, userName, oldValue, null, details);
        }

        public static int LogAction(string tableName, string recordId, string action, string userId, string userName, string details = null)
        {
            return Log(tableName, recordId, action, userId, userName, null, null, details);
        }

        public static DataTable GetLogs(string recordId)
        {
            var msConnObj = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
            string connectionString = msConnObj != null ? msConnObj.ConnectionString : "";
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand("usp_GetLogsByRecordId", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@RecordID", SqlDbType.NVarChar, 50).Value = recordId;
                    new SqlDataAdapter(cmd).Fill(dt);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(string.Format("AuditLog GetLogs Error: {0}", ex.Message));
            }
            return dt;
        }
    }
    protected void txtAppTrackNo_TextChanged(object sender, EventArgs e)
    {
        string trackIdStr = txtAppTrackNo.Text.Trim();
        if (string.IsNullOrEmpty(trackIdStr)) return;

        using (SqlConnection conConn = new SqlConnection(con))
        using (SqlCommand cmd = new SqlCommand("usp_CheckTrackIdExists", conConn))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("@TrackID", SqlDbType.Int).Value = trackIdStr;
            conConn.Open();
            int count = Convert.ToInt32(cmd.ExecuteScalar());
            if (count > 0)
            {
                LoadApplicantData(trackIdStr);
                int tid;
                if (int.TryParse(trackIdStr, out tid))
                    LoadDocuments(tid);
                ViewState["IsExistingRecord"] = true;
            }
            else
            {
                // Clear all fields but keep the TrackID for new application
                txtApplicantName.Text = "";
                txtFatherName.Text = "";
                txtDOB.Text = "";
                txtNIC.Text = "";
                ddlMaritalStatus.SelectedIndex = 0;
                txtProfession.Text = "";
                txtCompanyName.Text = "";
                txtDesignation.Text = "";
                ddlNationality.SelectedIndex = 0;
                txtMonthlyIncome.Text = "0";
                ddlCurrency.SelectedIndex = 0;
                txtAddress.Text = "";
                txtOfficeAddress.Text = "";
                txtZip.Text = "";
                txtPhone.Text = "";
                txtMobile.Text = "";
                txtEmail.Text = "";
                txtInstitute.Text = "";
                ddlDegree.SelectedIndex = 0;
                txtYear.Text = "";
                txtWorkExperience.Text = "";
                txtAreaInterest.Text = "";
                txtFacilities.Text = "";
                txtOtherMemberships.Text = "";
                txtPreferredNo.Text = "";
                txtMFee.Text = "0";
                txtSpouseName.Text = "";
                txtNumberOfSpouse.Text = "0";
                txtNumberOfSons.Text = "0";
                txtNumberOfDaughters.Text = "0";
                txtSP_CNIC.Text = "";
                txtSpousePhone.Text = "";
                ddlSpouseProfession.SelectedIndex = 0;
                ddlEducation.SelectedIndex = 0;
                txtProposer1.Text = "";
                txtRelation1.Text = "";
                txtProposer2.Text = "";
                txtRelation2.Text = "";
                Image1.ImageUrl = "";
                childrenList = new List<ChildItem>();
                BindChildrenGrid();
                ViewState["IsExistingRecord"] = false;

                ScriptManager.RegisterStartupScript(this, GetType(), "alert",
                    "alert('Track ID not found. You can create a new application.');", true);
            }
        }
    }

    protected void txtNIC_TextChanged(object sender, EventArgs e)
    {
        string nic = txtNIC.Text.Trim();
        if (string.IsNullOrEmpty(nic)) return;

        var _cs = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
        using (SqlConnection conn = new SqlConnection(_cs != null ? _cs.ConnectionString : ""))
        using (SqlCommand cmd = new SqlCommand("usp_GetTrackIdByNic", conn))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("@NIC", SqlDbType.NVarChar, 50).Value = nic;
            conn.Open();
            object result = cmd.ExecuteScalar();
            if (result != null)
            {
                string existingTrackId = result.ToString();

                // Check if we have a label control for showing the message
                if (lblNICExists != null)
                {
                    lblNICExists.Text = "Form auto-loaded from existing NIC.";
                    lblNICExists.Visible = true;
                    lblNICExists.ForeColor = System.Drawing.Color.Green;
                }

                LoadApplicantData(existingTrackId);
                LoadDocuments(Convert.ToInt32(existingTrackId));
                ViewState["IsExistingRecord"] = true;
                upMainFormContainer.Update();
            }
            else
            {
                if (lblNICExists != null)
                    lblNICExists.Visible = false;
            }
        }
    }

    private void ShowSchemaInfo()
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(con))
            {
                using (SqlCommand cmd = new SqlCommand("usp_GetSchemaInfo", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    conn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        string schema = "Table Schema (ApplicationFForm):\\n";
                        while (dr.Read())
                        {
                            schema += string.Format("{0}: {1}\\n", dr["COLUMN_NAME"], dr["CHARACTER_MAXIMUM_LENGTH"] == DBNull.Value ? "MAX" : dr["CHARACTER_MAXIMUM_LENGTH"].ToString());
                        }
                        ScriptManager.RegisterStartupScript(this, GetType(), "schema", "alert('" + schema + "');", true);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "schemaErr", "alert('Schema Error: " + ex.Message.Replace("'", "") + "');", true);
        }
    }
}

