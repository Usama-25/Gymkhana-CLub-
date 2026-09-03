using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ManageMembershipTypes : System.Web.UI.Page
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
            LoadCurrencies();
            BindTypeGrid();
            LoadFormTypesForFormDropdown();
            BindFormGrid();
            LoadFormTypesForCategory();
            BindCategoryGrid();
            LoadStats();
        }
    }

    private void LoadCurrencies()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            try
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT CurrencyCode FROM CurrencyTable WHERE Status = 1 ORDER BY CurrencyCode", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                ddlCurrency.DataSource = dt;
                ddlCurrency.DataTextField = "CurrencyCode";
                ddlCurrency.DataValueField = "CurrencyCode";
                ddlCurrency.DataBind();
                ddlCurrency.Items.Insert(0, new ListItem("-- Select --", ""));
                if (ddlCurrency.Items.FindByValue("PKR") != null) ddlCurrency.SelectedValue = "PKR";
            }
            catch
            {
                ddlCurrency.Items.Add(new ListItem("PKR", "PKR"));
                ddlCurrency.Items.Add(new ListItem("USD", "USD"));
            }
        }
    }

    private void LoadFormTypesForFormDropdown()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            try
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT id, FormTypeName FROM FormTypeMain WHERE Status = 1 ORDER BY FormTypeName", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                ddlFormTypeName.DataSource = dt;
                ddlFormTypeName.DataTextField = "FormTypeName";
                ddlFormTypeName.DataValueField = "id";
                ddlFormTypeName.DataBind();
                ddlFormTypeName.Items.Insert(0, new ListItem("-- Select Form Type --", "0"));
            }
            catch { }
        }
    }

    private void LoadFormTypesForCategory()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            try
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT id, FormTypeName FROM FormTypeMain WHERE Status = 1 ORDER BY FormTypeName", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                ddlCategoryFormType.DataSource = dt;
                ddlCategoryFormType.DataTextField = "FormTypeName";
                ddlCategoryFormType.DataValueField = "id";
                ddlCategoryFormType.DataBind();
                ddlCategoryFormType.Items.Insert(0, new ListItem("-- Select Type --", "0"));
            }
            catch { }
        }
    }

    protected void btnSaveFormType_Click(object sender, EventArgs e)
    {
        string mainType = txtModalMainType.Text.Trim();

        if (string.IsNullOrEmpty(mainType))
        {
            ShowMessage(lblFormMsg, "Please enter Main Category Name.", false);
            return;
        }

        // Collect all subtypes from Request.Form (handles dynamic inputs from JS)
        System.Collections.Generic.List<string> subtypes = new System.Collections.Generic.List<string>();
        for (int i = 1; i <= 50; i++)
        {
            string key = "txtSubType" + i;
            string val = Request.Form[key];

            // If i=1, also try to check the server control directly if not found in Form
            if (i == 1 && string.IsNullOrEmpty(val))
            {
                val = txtSubType1.Text;
            }

            if (!string.IsNullOrEmpty(val))
            {
                val = val.Trim();
                if (!string.IsNullOrEmpty(val) && !subtypes.Contains(val))
                {
                    subtypes.Add(val);
                }
            }
        }

        if (subtypes.Count == 0)
        {
            ShowMessage(lblFormMsg, "Please add at least one Sub Type.", false);
            return;
        }

        int mainId = 0;

        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            SqlTransaction tran = con.BeginTransaction();
            try
            {
                // Check if Main Category already exists
                SqlCommand cmdCheckMain = new SqlCommand("SELECT id FROM FormTypeMain WHERE FormTypeName = @Name", con, tran);
                cmdCheckMain.Parameters.AddWithValue("@Name", mainType);
                object existingMainId = cmdCheckMain.ExecuteScalar();

                if (existingMainId != null)
                {
                    mainId = Convert.ToInt32(existingMainId);
                }
                else
                {
                    // Insert into FormTypeMain
                    SqlCommand cmdMain = new SqlCommand("INSERT INTO FormTypeMain (FormTypeName, Status) VALUES (@Name, 1); SELECT SCOPE_IDENTITY();", con, tran);
                    cmdMain.Parameters.AddWithValue("@Name", mainType);
                    mainId = Convert.ToInt32(cmdMain.ExecuteScalar());
                }

                // Insert subtypes into FormTypeSub (only if they don't already exist)
                foreach (string sub in subtypes)
                {
                    SqlCommand cmdCheckSub = new SqlCommand("SELECT COUNT(*) FROM FormTypeSub WHERE MainId = @MainId AND SubTypeName = @SubName", con, tran);
                    cmdCheckSub.Parameters.AddWithValue("@MainId", mainId);
                    cmdCheckSub.Parameters.AddWithValue("@SubName", sub);

                    if ((int)cmdCheckSub.ExecuteScalar() == 0)
                    {
                        SqlCommand cmdSub = new SqlCommand("INSERT INTO FormTypeSub (MainId, SubTypeName, Status) VALUES (@MainId, @SubName, 1)", con, tran);
                        cmdSub.Parameters.AddWithValue("@MainId", mainId);
                        cmdSub.Parameters.AddWithValue("@SubName", sub);
                        cmdSub.ExecuteNonQuery();
                    }
                }

                tran.Commit();

                // Refresh the dropdown
                LoadFormTypesForFormDropdown();

                // Select the newly added item
                if (ddlFormTypeName.Items.FindByValue(mainId.ToString()) != null)
                {
                    ddlFormTypeName.SelectedValue = mainId.ToString();
                    ddlFormTypeName_SelectedIndexChanged(null, null);
                }

                ShowMessage(lblFormMsg, "Form Type Category saved successfully!", true);

                // Close modal via JavaScript
                ScriptManager.RegisterStartupScript(this, GetType(), "closeModal", "closeFormTypeModal();", true);
            }
            catch (Exception ex)
            {
                tran.Rollback();
                ShowMessage(lblFormMsg, "Error saving Form Type: " + ex.Message, false);
            }
        }
    }

    protected void ddlFormTypeName_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadSubTypesForDropdown();
    }

    protected void ddlSubType_SelectedIndexChanged(object sender, EventArgs e)
    {
        int mainId = 0;
        int.TryParse(ddlFormTypeName.SelectedValue, out mainId);
        int subId = 0;
        int.TryParse(ddlSubType.SelectedValue, out subId);

        if (mainId > 0)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "SELECT id FROM FormTable WHERE FormTypeMainId = @MainId AND (SubTypeId = @SubId OR (SubTypeId IS NULL AND @SubId = 0))";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@MainId", mainId);
                cmd.Parameters.AddWithValue("@SubId", subId > 0 ? (object)subId : DBNull.Value);
                con.Open();
                object result = cmd.ExecuteScalar();
                if (result != null)
                {
                    PopulateFormFields(Convert.ToInt32(result));
                }
                else
                {
                    // No existing record, clear fields for new entry
                    int currentMain = mainId;
                    int currentSub = subId;
                    ClearFormForm();
                    // Restore dropdown selections
                    ddlFormTypeName.SelectedValue = currentMain.ToString();
                    LoadSubTypesForDropdown();
                    if (currentSub > 0 && ddlSubType.Items.FindByValue(currentSub.ToString()) != null)
                        ddlSubType.SelectedValue = currentSub.ToString();
                }
            }
        }
        hfActiveTab.Value = "tabForm";
    }

    private void LoadSubTypesForDropdown()
    {
        int mainId = 0;
        int.TryParse(ddlFormTypeName.SelectedValue, out mainId);
        hfModalSubTypes.Value = ""; // Clear first

        if (mainId > 0)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT id, SubTypeName FROM FormTypeSub WHERE MainId = @MainId AND Status = 1 ORDER BY SubTypeName", con);
                da.SelectCommand.Parameters.AddWithValue("@MainId", mainId);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlSubType.DataSource = dt;
                ddlSubType.DataTextField = "SubTypeName";
                ddlSubType.DataValueField = "id";
                ddlSubType.DataBind();
                ddlSubType.Items.Insert(0, new ListItem("-- Select Sub Type --", "0"));

                // Also populate hidden field for modal pre-fill
                System.Collections.Generic.List<string> subTypeNames = new System.Collections.Generic.List<string>();
                foreach (DataRow row in dt.Rows)
                {
                    subTypeNames.Add(row["SubTypeName"].ToString());
                }
                hfModalSubTypes.Value = string.Join("|", subTypeNames);
            }
        }
        else
        {
            ddlSubType.Items.Clear();
            ddlSubType.Items.Insert(0, new ListItem("-- Select Sub Type --", "0"));
        }
    }

    protected void btnConfirmToggle_Click(object sender, EventArgs e)
    {
        string tableName = hfToggleTable.Value;
        int recordId = 0;
        int.TryParse(hfToggleId.Value, out recordId);
        int currentStatus = 0;
        int.TryParse(hfToggleCurrentStatus.Value, out currentStatus);
        string reason = txtToggleReason.Text.Trim();

        if (string.IsNullOrEmpty(reason))
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Please enter a reason.');", true);
            return;
        }

        int newStatus = (currentStatus == 1) ? 0 : 1;
        string changedBy = Session["Emp_Name"] != null ? Session["Emp_Name"].ToString() :
                           (Session["Emp_ID"] != null ? Session["Emp_ID"].ToString() : "System");

        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            SqlTransaction tran = con.BeginTransaction();
            try
            {
                string recordName = "";
                string sqlSelection = "";
                if (tableName == "MembershipType") sqlSelection = "SELECT MembershipType FROM MembershipType WHERE id = @ID";
                else if (tableName == "FormTable") sqlSelection = "SELECT FormTypeName FROM FormTable WHERE id = @ID";
                else if (tableName == "MembershipCategories") sqlSelection = "SELECT Category FROM MembershipCategories WHERE id = @ID";

                using (SqlCommand cmdName = new SqlCommand(sqlSelection, con, tran))
                {
                    cmdName.Parameters.AddWithValue("@ID", recordId);
                    object result = cmdName.ExecuteScalar();
                    if (result != null) recordName = result.ToString();
                }

                string sqlUpdate = "";
                if (tableName == "MembershipType") sqlUpdate = "UPDATE MembershipType SET Status = @NewStatus WHERE id = @ID";
                else if (tableName == "FormTable") sqlUpdate = "UPDATE FormTable SET status = @NewStatus WHERE id = @ID";
                else if (tableName == "MembershipCategories") sqlUpdate = "UPDATE MembershipCategories SET Status = @NewStatus WHERE id = @ID";

                using (SqlCommand cmdUpdate = new SqlCommand(sqlUpdate, con, tran))
                {
                    cmdUpdate.Parameters.AddWithValue("@NewStatus", newStatus);
                    cmdUpdate.Parameters.AddWithValue("@ID", recordId);
                    cmdUpdate.ExecuteNonQuery();
                }

                using (SqlCommand cmdLog = new SqlCommand(@"
                    INSERT INTO StatusChangeLog (TableName, RecordID, RecordName, OldStatus, NewStatus, Reason, ChangedBy, ChangedAt)
                    VALUES (@TableName, @RecordID, @RecordName, @OldStatus, @NewStatus, @Reason, @ChangedBy, GETDATE())", con, tran))
                {
                    cmdLog.Parameters.AddWithValue("@TableName", tableName);
                    cmdLog.Parameters.AddWithValue("@RecordID", recordId);
                    cmdLog.Parameters.AddWithValue("@RecordName", recordName);
                    cmdLog.Parameters.AddWithValue("@OldStatus", currentStatus);
                    cmdLog.Parameters.AddWithValue("@NewStatus", newStatus);
                    cmdLog.Parameters.AddWithValue("@Reason", reason);
                    cmdLog.Parameters.AddWithValue("@ChangedBy", changedBy);
                    cmdLog.ExecuteNonQuery();
                }
                tran.Commit();
            }
            catch { tran.Rollback(); throw; }
        }

        txtToggleReason.Text = "";
        hfToggleTable.Value = "";
        hfToggleId.Value = "";
        hfToggleCurrentStatus.Value = "";

        if (tableName == "MembershipType") hfActiveTab.Value = "tabType";
        else if (tableName == "FormTable") hfActiveTab.Value = "tabForm";
        else if (tableName == "MembershipCategories") hfActiveTab.Value = "tabCategory";

        BindTypeGrid();
        BindFormGrid();
        BindCategoryGrid();
        LoadStats();
        ShowMessage(tableName == "MembershipType" ? lblTypeMsg : tableName == "FormTable" ? lblFormMsg : lblCategoryMsg, "Successfully updated status.", true);
    }

    private void LoadStats()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM MembershipType", con))
                lblTypeCount.Text = cmd.ExecuteScalar().ToString();
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM FormTable", con))
                lblFormCount.Text = cmd.ExecuteScalar().ToString();
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM MembershipCategories", con))
            {
                try { lblCategoryCount.Text = cmd.ExecuteScalar().ToString(); }
                catch { lblCategoryCount.Text = "0"; }
            }
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM FormTypeMain WHERE Status = 1", con))
            {
                try { lblFormTypeMainCount.Text = cmd.ExecuteScalar().ToString(); }
                catch { lblFormTypeMainCount.Text = "0"; }
            }
        }
        upStats.Update();
    }

    private void BindTypeGrid()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            SqlDataAdapter da = new SqlDataAdapter("SELECT Id, MembershipType, Status, Prefix FROM MembershipType", con);
            DataTable dt = new DataTable(); da.Fill(dt); gvType.DataSource = dt; gvType.DataBind();
        }
    }

    protected void btnSaveType_Click(object sender, EventArgs e)
    {
        string name = txtTypeName.Text.Trim(); if (string.IsNullOrEmpty(name)) { ShowMessage(lblTypeMsg, "Please enter a type name.", false); return; }
        string prefix = txtPrefix.Text.Trim(); if (string.IsNullOrEmpty(prefix)) { ShowMessage(lblTypeMsg, "Please enter a prefix.", false); return; }
        int id = 0; int.TryParse(hfTypeId.Value, out id);

        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            string checkSql = (id > 0) ? "SELECT COUNT(*) FROM MembershipType WHERE Prefix = @Prefix AND id != @ID" : "SELECT COUNT(*) FROM MembershipType WHERE Prefix = @Prefix";
            using (SqlCommand cmdCheck = new SqlCommand(checkSql, con))
            {
                cmdCheck.Parameters.AddWithValue("@Prefix", prefix);
                if (id > 0) cmdCheck.Parameters.AddWithValue("@ID", id);
                if ((int)cmdCheck.ExecuteScalar() > 0)
                {
                    ShowMessage(lblTypeMsg, "This Prefix already exists. Please enter a unique one.", false);
                    return;
                }
            }

            SqlCommand cmd;
            if (id > 0) { cmd = new SqlCommand("UPDATE MembershipType SET MembershipType = @Name, Prefix = @Prefix WHERE id = @ID", con); cmd.Parameters.AddWithValue("@ID", id); }
            else cmd = new SqlCommand("INSERT INTO MembershipType (MembershipType, Prefix, Status) VALUES (@Name, @Prefix, 1)", con);
            cmd.Parameters.AddWithValue("@Name", name); cmd.Parameters.AddWithValue("@Prefix", prefix); cmd.ExecuteNonQuery();
        }
        ClearTypeForm(); BindTypeGrid(); LoadStats(); ShowMessage(lblTypeMsg, "Saved successfully.", true); hfActiveTab.Value = "tabType";
    }

    protected void btnClearType_Click(object sender, EventArgs e) { ClearTypeForm(); hfActiveTab.Value = "tabType"; }

    protected void gvType_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "EditItem")
        {
            int id = Convert.ToInt32(e.CommandArgument);
            using (SqlConnection con = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("SELECT id, MembershipType, Prefix FROM MembershipType WHERE id = @ID", con);
                cmd.Parameters.AddWithValue("@ID", id); con.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read()) { hfTypeId.Value = id.ToString(); txtTypeName.Text = dr["MembershipType"].ToString(); txtPrefix.Text = dr["Prefix"].ToString(); }
            }
        }
        hfActiveTab.Value = "tabType";
    }

    private void ClearTypeForm() { hfTypeId.Value = "0"; txtTypeName.Text = ""; txtPrefix.Text = ""; }

    private void BindFormGrid()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            string query = @"SELECT f.id, f.FormTypeName, f.Prefix, f.Price, f.Status, f.EntranceFee, f.ExtraCharges, 
                                    f.TotalAmount, f.Currency, f.Remarks, 
                                    f.IsFormFeeRefundable, f.IsEntranceFeeRefundable, f.IsExtraChargesRefundable,
                                    f.FormFeeRefundFixed, f.FormFeeRefundPercent, f.EntranceFeeRefundFixed, 
                                    f.EntranceFeeRefundPercent, f.ExtraChargesRefundFixed, f.ExtraChargesRefundPercent,
                                    ISNULL(s.SubTypeName, '') AS SubType
                             FROM FormTable f
                             LEFT JOIN FormTypeSub s ON f.SubTypeId = s.id";
            SqlDataAdapter da = new SqlDataAdapter(query, con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            gvForm.DataSource = dt;
            gvForm.DataBind();
        }
    }

    protected string GetRefundPill(object isRefundable, object fixedAmount, object percent, string label)
    {
        if (Convert.ToBoolean(isRefundable))
        {
            decimal fixedAmt = Convert.ToDecimal(fixedAmount);
            decimal perc = Convert.ToDecimal(percent);
            if (perc > 0 && fixedAmt > 0)
                return string.Format("<span class='refund-pill refund-pill-pct'>{0} {1}%=₨{2:N0}</span>", label, perc, fixedAmt);
            else if (perc > 0)
                return string.Format("<span class='refund-pill refund-pill-pct'>{0} {1}%</span>", label, perc);
            else if (fixedAmt > 0)
                return string.Format("<span class='refund-pill refund-pill-fixed'>{0} ₨{1:N0}</span>", label, fixedAmt);
            else
                return string.Format("<span class='refund-pill refund-pill-yes'>{0} ✓</span>", label);
        }
        return "";
    }

    protected void btnSaveForm_Click(object sender, EventArgs e)
    {
        if (PerformSaveForm())
        {
            ShowMessage(lblFormMsg, "Form type saved successfully.", true);
        }
        hfActiveTab.Value = "tabForm";
    }

    protected void AutoSaveForm(object sender, EventArgs e)
    {
        int id = 0;
        int.TryParse(hfFormId.Value, out id);

        // Only auto-save if we are updating an existing record
        if (id > 0)
        {
            if (PerformSaveForm())
            {
                // Silent save, maybe a small toast or just status text
                lblFormMsg.Text = "Auto-updated at " + DateTime.Now.ToString("HH:mm:ss");
                lblFormMsg.Visible = true;
                lblFormMsg.CssClass = "mmt-msg-success";
            }
        }
        hfActiveTab.Value = "tabForm";
    }

    private bool PerformSaveForm()
    {
        string formTypeName = "";
        int formTypeMainId = 0;
        int.TryParse(ddlFormTypeName.SelectedValue, out formTypeMainId);

        if (formTypeMainId > 0)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("SELECT FormTypeName FROM FormTypeMain WHERE id = @Id", con);
                cmd.Parameters.AddWithValue("@Id", formTypeMainId);
                con.Open();
                object result = cmd.ExecuteScalar();
                if (result != null) formTypeName = result.ToString();
            }
        }

        if (string.IsNullOrEmpty(formTypeName))
        {
            ShowMessage(lblFormMsg, "Please select a Form Type.", false);
            return false;
        }

        int subTypeId = 0;
        int.TryParse(ddlSubType.SelectedValue, out subTypeId);

        string prefix = txtFormPrefix.Text.Trim();
        if (string.IsNullOrEmpty(prefix))
        {
            ShowMessage(lblFormMsg, "Please enter a prefix.", false);
            return false;
        }

        int id = 0;
        int.TryParse(hfFormId.Value, out id);

        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            string checkSql = (id > 0) ? "SELECT COUNT(*) FROM FormTable WHERE Prefix = @Prefix AND id != @ID" : "SELECT COUNT(*) FROM FormTable WHERE Prefix = @Prefix";
            using (SqlCommand cmdCheck = new SqlCommand(checkSql, con))
            {
                cmdCheck.Parameters.AddWithValue("@Prefix", prefix);
                if (id > 0) cmdCheck.Parameters.AddWithValue("@ID", id);
                if ((int)cmdCheck.ExecuteScalar() > 0)
                {
                    ShowMessage(lblFormMsg, "This Prefix already exists. Please enter a unique one.", false);
                    return false;
                }
            }

            int status = Convert.ToInt32(ddlFormStatus.SelectedValue);
            decimal fee = 0; decimal.TryParse(txtFormFee.Text, out fee);
            decimal entrance = 0; decimal.TryParse(txtEntranceFee.Text, out entrance);
            decimal extra = 0; decimal.TryParse(txtExtraCharges.Text, out extra);
            decimal total = fee + entrance + extra;
            string currency = ddlCurrency.SelectedValue;
            string remarks = txtRemarks.Text.Trim();

            int isFormRef = chkRefFormFee.Checked ? 1 : 0;
            int isEntRef = chkRefEntranceFee.Checked ? 1 : 0;
            int isExtRef = chkRefExtraCharges.Checked ? 1 : 0;

            decimal formFeeRefundFixed = 0; decimal.TryParse(txtFormFeeRefundFixed.Text, out formFeeRefundFixed);
            decimal formFeeRefundPercent = 0; decimal.TryParse(txtFormFeeRefundPercent.Text, out formFeeRefundPercent);
            decimal entranceFeeRefundFixed = 0; decimal.TryParse(txtEntranceFeeRefundFixed.Text, out entranceFeeRefundFixed);
            decimal entranceFeeRefundPercent = 0; decimal.TryParse(txtEntranceFeeRefundPercent.Text, out entranceFeeRefundPercent);
            decimal extraChargesRefundFixed = 0; decimal.TryParse(txtExtraChargesRefundFixed.Text, out extraChargesRefundFixed);
            decimal extraChargesRefundPercent = 0; decimal.TryParse(txtExtraChargesRefundPercent.Text, out extraChargesRefundPercent);

            string formFeeRefType = hfFormFeeRefundType.Value;
            string entranceFeeRefType = hfEntranceFeeRefundType.Value;
            string extraChargesRefType = hfExtraChargesRefundType.Value;

            if (isFormRef == 1 && formFeeRefType == "Percentage")
            {
                formFeeRefundFixed = Math.Round(fee * formFeeRefundPercent / 100);
            }
            else if (isFormRef == 1 && formFeeRefType == "Fixed")
            {
                formFeeRefundPercent = 0;
            }

            if (isEntRef == 1 && entranceFeeRefType == "Percentage")
            {
                entranceFeeRefundFixed = Math.Round(entrance * entranceFeeRefundPercent / 100);
            }
            else if (isEntRef == 1 && entranceFeeRefType == "Fixed")
            {
                entranceFeeRefundPercent = 0;
            }

            if (isExtRef == 1 && extraChargesRefType == "Percentage")
            {
                extraChargesRefundFixed = Math.Round(extra * extraChargesRefundPercent / 100);
            }
            else if (isExtRef == 1 && extraChargesRefType == "Fixed")
            {
                extraChargesRefundPercent = 0;
            }

            SqlCommand cmd;
            if (id > 0)
            {
                cmd = new SqlCommand(@"UPDATE FormTable SET 
                        FormTypeName = @FormTypeName, FormTypeMainId = @FormTypeMainId, SubTypeId = @SubTypeId,
                        Prefix = @Prefix, Price = @Price, EntranceFee = @EntranceFee, 
                        ExtraCharges = @ExtraCharges, TotalAmount = @TotalAmount, 
                        Currency = @Currency, Remarks = @Remarks, status = @Status,
                        IsFormFeeRefundable = @IsFormFeeRefundable, IsEntranceFeeRefundable = @IsEntranceFeeRefundable, IsExtraChargesRefundable = @IsExtraChargesRefundable,
                        FormFeeRefundFixed = @FormFeeRefundFixed, FormFeeRefundPercent = @FormFeeRefundPercent,
                        EntranceFeeRefundFixed = @EntranceFeeRefundFixed, EntranceFeeRefundPercent = @EntranceFeeRefundPercent,
                        ExtraChargesRefundFixed = @ExtraChargesRefundFixed, ExtraChargesRefundPercent = @ExtraChargesRefundPercent
                        WHERE id = @ID", con);
                cmd.Parameters.AddWithValue("@ID", id);
            }
            else
            {
                cmd = new SqlCommand(@"INSERT INTO FormTable 
                        (FormTypeName, FormTypeMainId, SubTypeId, Prefix, Price, EntranceFee, ExtraCharges, TotalAmount, Currency, Remarks, status, 
                         IsFormFeeRefundable, IsEntranceFeeRefundable, IsExtraChargesRefundable,
                         FormFeeRefundFixed, FormFeeRefundPercent, EntranceFeeRefundFixed, EntranceFeeRefundPercent,
                         ExtraChargesRefundFixed, ExtraChargesRefundPercent) 
                        VALUES (@FormTypeName, @FormTypeMainId, @SubTypeId, @Prefix, @Price, @EntranceFee, @ExtraCharges, @TotalAmount, @Currency, @Remarks, @Status, 
                                @IsFormFeeRefundable, @IsEntranceFeeRefundable, @IsExtraChargesRefundable,
                                @FormFeeRefundFixed, @FormFeeRefundPercent, @EntranceFeeRefundFixed, @EntranceFeeRefundPercent,
                                @ExtraChargesRefundFixed, @ExtraChargesRefundPercent)", con);
            }

            cmd.Parameters.AddWithValue("@FormTypeName", formTypeName);
            cmd.Parameters.AddWithValue("@FormTypeMainId", formTypeMainId);
            cmd.Parameters.AddWithValue("@SubTypeId", subTypeId > 0 ? (object)subTypeId : DBNull.Value);
            cmd.Parameters.AddWithValue("@Prefix", prefix);
            cmd.Parameters.AddWithValue("@Price", fee);
            cmd.Parameters.AddWithValue("@EntranceFee", entrance);
            cmd.Parameters.AddWithValue("@ExtraCharges", extra);
            cmd.Parameters.AddWithValue("@TotalAmount", total);
            cmd.Parameters.AddWithValue("@Currency", currency);
            cmd.Parameters.AddWithValue("@Remarks", remarks);
            cmd.Parameters.AddWithValue("@Status", status);
            cmd.Parameters.AddWithValue("@IsFormFeeRefundable", isFormRef);
            cmd.Parameters.AddWithValue("@IsEntranceFeeRefundable", isEntRef);
            cmd.Parameters.AddWithValue("@IsExtraChargesRefundable", isExtRef);
            cmd.Parameters.AddWithValue("@FormFeeRefundFixed", formFeeRefundFixed);
            cmd.Parameters.AddWithValue("@FormFeeRefundPercent", formFeeRefundPercent);
            cmd.Parameters.AddWithValue("@EntranceFeeRefundFixed", entranceFeeRefundFixed);
            cmd.Parameters.AddWithValue("@EntranceFeeRefundPercent", entranceFeeRefundPercent);
            cmd.Parameters.AddWithValue("@ExtraChargesRefundFixed", extraChargesRefundFixed);
            cmd.Parameters.AddWithValue("@ExtraChargesRefundPercent", extraChargesRefundPercent);

            try { cmd.ExecuteNonQuery(); }
            catch (Exception ex) { ShowMessage(lblFormMsg, "Error: " + ex.Message, false); return false; }
        }

        if (id == 0) // Only clear if it was a new record
            ClearFormForm();

        BindFormGrid();
        LoadStats();
        LoadFormTypesForFormDropdown();
        return true;
    }

    protected void btnClearForm_Click(object sender, EventArgs e)
    {
        ClearFormForm();
        hfActiveTab.Value = "tabForm";
    }

    protected void gvForm_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "EditItem")
        {
            int id = Convert.ToInt32(e.CommandArgument);
            PopulateFormFields(id);
        }
        hfActiveTab.Value = "tabForm";
    }

    private void PopulateFormFields(int id)
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            SqlCommand cmd = new SqlCommand(@"SELECT id, FormTypeName, FormTypeMainId, SubTypeId, Prefix, 
                                            ISNULL(Price, 0) AS Price, 
                                            ISNULL(EntranceFee, 0) AS EntranceFee, 
                                            ISNULL(ExtraCharges, 0) AS ExtraCharges, 
                                            ISNULL(TotalAmount, 0) AS TotalAmount,
                                            ISNULL(Currency, '') AS Currency,
                                            ISNULL(Remarks, '') AS Remarks,
                                            ISNULL(status, 1) AS status,
                                            ISNULL(IsFormFeeRefundable, 0) AS IsFormFeeRefundable,
                                            ISNULL(IsEntranceFeeRefundable, 0) AS IsEntranceFeeRefundable,
                                            ISNULL(IsExtraChargesRefundable, 0) AS IsExtraChargesRefundable,
                                            ISNULL(FormFeeRefundFixed, 0) AS FormFeeRefundFixed,
                                            ISNULL(FormFeeRefundPercent, 0) AS FormFeeRefundPercent,
                                            ISNULL(EntranceFeeRefundFixed, 0) AS EntranceFeeRefundFixed,
                                            ISNULL(EntranceFeeRefundPercent, 0) AS EntranceFeeRefundPercent,
                                            ISNULL(ExtraChargesRefundFixed, 0) AS ExtraChargesRefundFixed,
                                            ISNULL(ExtraChargesRefundPercent, 0) AS ExtraChargesRefundPercent
                                            FROM FormTable WHERE id = @ID", con);
            cmd.Parameters.AddWithValue("@ID", id);
            con.Open();
            SqlDataReader dr = cmd.ExecuteReader();
            if (dr.Read())
            {
                hfFormId.Value = id.ToString();

                // Set FormType dropdown
                int mainId = Convert.ToInt32(dr["FormTypeMainId"]);
                if (mainId > 0 && ddlFormTypeName.Items.FindByValue(mainId.ToString()) != null)
                {
                    ddlFormTypeName.SelectedValue = mainId.ToString();
                    LoadSubTypesForDropdown();

                    // Set SubType dropdown
                    int subId = dr["SubTypeId"] != DBNull.Value ? Convert.ToInt32(dr["SubTypeId"]) : 0;
                    if (subId > 0 && ddlSubType.Items.FindByValue(subId.ToString()) != null)
                    {
                        ddlSubType.SelectedValue = subId.ToString();
                    }
                }

                txtFormPrefix.Text = dr["Prefix"].ToString();
                txtFormFee.Text = dr["Price"].ToString();
                txtEntranceFee.Text = dr["EntranceFee"].ToString();
                txtExtraCharges.Text = dr["ExtraCharges"].ToString();
                txtTotal.Text = dr["TotalAmount"].ToString();
                txtRemarks.Text = dr["Remarks"].ToString();
                ddlFormStatus.SelectedValue = dr["status"].ToString();

                chkRefFormFee.Checked = Convert.ToBoolean(dr["IsFormFeeRefundable"]);
                chkRefEntranceFee.Checked = Convert.ToBoolean(dr["IsEntranceFeeRefundable"]);
                chkRefExtraCharges.Checked = Convert.ToBoolean(dr["IsExtraChargesRefundable"]);

                txtFormFeeRefundFixed.Text = dr["FormFeeRefundFixed"].ToString();
                txtFormFeeRefundPercent.Text = dr["FormFeeRefundPercent"].ToString();
                txtEntranceFeeRefundFixed.Text = dr["EntranceFeeRefundFixed"].ToString();
                txtEntranceFeeRefundPercent.Text = dr["EntranceFeeRefundPercent"].ToString();
                txtExtraChargesRefundFixed.Text = dr["ExtraChargesRefundFixed"].ToString();
                txtExtraChargesRefundPercent.Text = dr["ExtraChargesRefundPercent"].ToString();

                if (ddlCurrency.Items.FindByValue(dr["Currency"].ToString()) != null)
                    ddlCurrency.SelectedValue = dr["Currency"].ToString();

                decimal ffPercent = Convert.ToDecimal(dr["FormFeeRefundPercent"]);
                decimal efPercent = Convert.ToDecimal(dr["EntranceFeeRefundPercent"]);
                decimal ecPercent = Convert.ToDecimal(dr["ExtraChargesRefundPercent"]);

                hfFormFeeRefundType.Value = (chkRefFormFee.Checked && ffPercent > 0) ? "Percentage" : "Fixed";
                hfEntranceFeeRefundType.Value = (chkRefEntranceFee.Checked && efPercent > 0) ? "Percentage" : "Fixed";
                hfExtraChargesRefundType.Value = (chkRefExtraCharges.Checked && ecPercent > 0) ? "Percentage" : "Fixed";

                ScriptManager.RegisterStartupScript(this, GetType(), "restoreRefundUI", "restoreRefundTypeState();", true);
            }
        }
    }

    private void ClearFormForm()
    {
        hfFormId.Value = "0";
        if (ddlFormTypeName.Items.Count > 0) ddlFormTypeName.SelectedIndex = 0;
        ddlSubType.Items.Clear();
        ddlSubType.Items.Insert(0, new ListItem("-- Select Sub Type --", "0"));
        txtFormPrefix.Text = "";
        txtFormFee.Text = "";
        txtEntranceFee.Text = "";
        txtExtraCharges.Text = "";
        txtTotal.Text = "";
        txtRemarks.Text = "";
        ddlFormStatus.SelectedValue = "1";
        chkRefFormFee.Checked = false;
        chkRefEntranceFee.Checked = false;
        chkRefExtraCharges.Checked = false;
        txtFormFeeRefundFixed.Text = "";
        txtFormFeeRefundPercent.Text = "";
        txtEntranceFeeRefundFixed.Text = "";
        txtEntranceFeeRefundPercent.Text = "";
        txtExtraChargesRefundFixed.Text = "";
        txtExtraChargesRefundPercent.Text = "";
        hfFormFeeRefundType.Value = "Fixed";
        hfEntranceFeeRefundType.Value = "Fixed";
        hfExtraChargesRefundType.Value = "Fixed";
        if (ddlCurrency.Items.FindByValue("PKR") != null) ddlCurrency.SelectedValue = "PKR";
        else if (ddlCurrency.Items.Count > 0) ddlCurrency.SelectedIndex = 0;
    }

    private void BindCategoryGrid()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            try
            {
                string query = @"SELECT id, Category, CategoryDescription, MonthlyFee, FormTypeID, MemberType, AdvanceSub, LibrarySub, FilmSub, MusicalEve, ACCharges, WelfareFund, DevFund, CreditLimit, Status, MiscCharges, AdditionalCharges FROM MembershipCategories";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvCategory.DataSource = dt;
                gvCategory.DataBind();
            }
            catch { }
        }
    }

    protected void btnSaveCategory_Click(object sender, EventArgs e)
    {
        string category = txtCategoryCode.Text.Trim();
        string description = txtCategoryDesc.Text.Trim();
        if (string.IsNullOrEmpty(category))
        {
            ShowMessage(lblCategoryMsg, "Please enter a category code.", false);
            return;
        }

        int id = 0;
        int.TryParse(hfCategoryId.Value, out id);

        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            string checkSql = (id > 0) ? "SELECT COUNT(*) FROM MembershipCategories WHERE Category = @Category AND id != @ID" : "SELECT COUNT(*) FROM MembershipCategories WHERE Category = @Category";
            using (SqlCommand cmdCheck = new SqlCommand(checkSql, con))
            {
                cmdCheck.Parameters.AddWithValue("@Category", category);
                if (id > 0) cmdCheck.Parameters.AddWithValue("@ID", id);
                try
                {
                    if ((int)cmdCheck.ExecuteScalar() > 0)
                    {
                        ShowMessage(lblCategoryMsg, "This Category Code already exists. Please enter a unique one.", false);
                        return;
                    }
                }
                catch { }
            }

            int formTypeID = 0;
            int.TryParse(ddlCategoryFormType.SelectedValue, out formTypeID);

            int status = Convert.ToInt32(ddlCategoryStatus.SelectedValue);

            string memberType = ddlCategoryMemberType.SelectedValue;
            if (memberType == "Other")
            {
                memberType = txtCategoryMemberTypeCustom.Text.Trim();
            }

            decimal fee = 0; decimal.TryParse(txtCategoryMonthlyFee.Text, out fee);
            decimal advSub = 0; decimal.TryParse(txtCatAdvanceSub.Text, out advSub);
            decimal libSub = 0; decimal.TryParse(txtCatLibrarySub.Text, out libSub);
            decimal filmSub = 0; decimal.TryParse(txtCatFilmSub.Text, out filmSub);
            decimal musEve = 0; decimal.TryParse(txtCatMusicalEve.Text, out musEve);
            decimal acChar = 0; decimal.TryParse(txtCatACCharges.Text, out acChar);
            decimal welFund = 0; decimal.TryParse(txtCatWelfareFund.Text, out welFund);
            decimal devFund = 0; decimal.TryParse(txtCatDevFund.Text, out devFund);
            decimal credLimit = 0; decimal.TryParse(txtCatCreditLimit.Text, out credLimit);
            decimal miscChg = 0; decimal.TryParse(txtCatMiscCharges.Text, out miscChg);
            decimal addChg = 0; decimal.TryParse(txtCatAddCharges.Text, out addChg);

            SqlCommand cmd;
            if (id > 0)
            {
                cmd = new SqlCommand(@"UPDATE MembershipCategories SET 
                        Category = @Category, CategoryDescription = @CategoryDescription, MonthlyFee = @MonthlyFee, 
                        FormTypeID = @FormTypeID, MemberType = @MemberType, 
                        AdvanceSub = @AdvanceSub, LibrarySub = @LibrarySub, FilmSub = @FilmSub, 
                        MusicalEve = @MusicalEve, ACCharges = @ACCharges, WelfareFund = @WelfareFund, 
                        DevFund = @DevFund, CreditLimit = @CreditLimit, MiscCharges = @MiscCharges, 
                        AdditionalCharges = @AdditionalCharges, Status = @Status 
                        WHERE id = @ID", con);
                cmd.Parameters.AddWithValue("@ID", id);
            }
            else
            {
                cmd = new SqlCommand(@"INSERT INTO MembershipCategories 
                        (Category, CategoryDescription, MonthlyFee, FormTypeID, MemberType, AdvanceSub, LibrarySub, FilmSub, MusicalEve, ACCharges, WelfareFund, DevFund, CreditLimit, MiscCharges, AdditionalCharges, Status) 
                        VALUES (@Category, @CategoryDescription, @MonthlyFee, @FormTypeID, @MemberType, @AdvanceSub, @LibrarySub, @FilmSub, @MusicalEve, @ACCharges, @WelfareFund, @DevFund, @CreditLimit, @MiscCharges, @AdditionalCharges, @Status)", con);
            }

            cmd.Parameters.AddWithValue("@Category", category);
            cmd.Parameters.AddWithValue("@CategoryDescription", description);
            cmd.Parameters.AddWithValue("@MonthlyFee", fee);
            cmd.Parameters.AddWithValue("@FormTypeID", formTypeID);
            cmd.Parameters.AddWithValue("@MemberType", memberType);
            cmd.Parameters.AddWithValue("@AdvanceSub", advSub);
            cmd.Parameters.AddWithValue("@LibrarySub", libSub);
            cmd.Parameters.AddWithValue("@FilmSub", filmSub);
            cmd.Parameters.AddWithValue("@MusicalEve", musEve);
            cmd.Parameters.AddWithValue("@ACCharges", acChar);
            cmd.Parameters.AddWithValue("@WelfareFund", welFund);
            cmd.Parameters.AddWithValue("@DevFund", devFund);
            cmd.Parameters.AddWithValue("@CreditLimit", credLimit);
            cmd.Parameters.AddWithValue("@MiscCharges", miscChg);
            cmd.Parameters.AddWithValue("@AdditionalCharges", addChg);
            cmd.Parameters.AddWithValue("@Status", status);
            try
            {
                cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                ShowMessage(lblCategoryMsg, "Error saving: " + ex.Message, false);
                hfActiveTab.Value = "tabCategory";
                return;
            }
        }

        ClearCategoryForm();
        BindCategoryGrid();
        LoadStats();
        ShowMessage(lblCategoryMsg, "Category saved successfully.", true);
        hfActiveTab.Value = "tabCategory";
    }

    protected void btnClearCategory_Click(object sender, EventArgs e)
    {
        ClearCategoryForm();
        hfActiveTab.Value = "tabCategory";
    }

    protected void gvCategory_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "EditItem")
        {
            int id = Convert.ToInt32(e.CommandArgument);
            using (SqlConnection con = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand(@"SELECT * FROM MembershipCategories WHERE id = @ID", con);
                cmd.Parameters.AddWithValue("@ID", id);
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    hfCategoryId.Value = id.ToString();
                    txtCategoryCode.Text = dr["Category"].ToString();
                    txtCategoryDesc.Text = dr["CategoryDescription"].ToString();
                    txtCategoryMonthlyFee.Text = dr["MonthlyFee"].ToString();

                    if (ddlCategoryFormType.Items.FindByValue(dr["FormTypeID"].ToString()) != null)
                        ddlCategoryFormType.SelectedValue = dr["FormTypeID"].ToString();

                    string mType = dr["MemberType"].ToString();
                    if (ddlCategoryMemberType.Items.FindByValue(mType) != null)
                    {
                        ddlCategoryMemberType.SelectedValue = mType;
                        txtCategoryMemberTypeCustom.Text = "";
                    }
                    else
                    {
                        ddlCategoryMemberType.SelectedValue = "Other";
                        txtCategoryMemberTypeCustom.Text = mType;
                    }
                    ScriptManager.RegisterStartupScript(this, GetType(), "toggleMemberType", "toggleCustomMemberType(document.getElementById('" + ddlCategoryMemberType.ClientID + "'));", true);

                    txtCatAdvanceSub.Text = dr["AdvanceSub"].ToString();
                    txtCatLibrarySub.Text = dr["LibrarySub"].ToString();
                    txtCatFilmSub.Text = dr["FilmSub"].ToString();
                    txtCatMusicalEve.Text = dr["MusicalEve"].ToString();
                    txtCatACCharges.Text = dr["ACCharges"].ToString();
                    txtCatWelfareFund.Text = dr["WelfareFund"].ToString();
                    txtCatDevFund.Text = dr["DevFund"].ToString();
                    txtCatCreditLimit.Text = dr["CreditLimit"].ToString();
                    txtCatMiscCharges.Text = dr["MiscCharges"].ToString();
                    txtCatAddCharges.Text = dr["AdditionalCharges"].ToString();

                    ddlCategoryStatus.SelectedValue = dr["Status"].ToString();
                }
            }
        }
        hfActiveTab.Value = "tabCategory";
    }

    private void ClearCategoryForm()
    {
        hfCategoryId.Value = "0";
        txtCategoryCode.Text = "";
        txtCategoryDesc.Text = "";
        txtCategoryMonthlyFee.Text = "";
        ddlCategoryMemberType.SelectedIndex = 0;
        txtCategoryMemberTypeCustom.Text = "";
        if (ddlCategoryFormType.Items.Count > 0) ddlCategoryFormType.SelectedIndex = 0;
        txtCatAdvanceSub.Text = "";
        txtCatLibrarySub.Text = "";
        txtCatFilmSub.Text = "";
        txtCatMusicalEve.Text = "";
        txtCatACCharges.Text = "";
        txtCatWelfareFund.Text = "";
        txtCatDevFund.Text = "";
        txtCatCreditLimit.Text = "";
        txtCatMiscCharges.Text = "";
        txtCatAddCharges.Text = "";
        ddlCategoryStatus.SelectedValue = "1";
    }

    private void ShowMessage(Label lbl, string msg, bool success)
    {
        lbl.Text = msg;
        lbl.CssClass = success ? "mmt-msg-success" : "mmt-msg-error";
        lbl.Visible = true;
    }
}