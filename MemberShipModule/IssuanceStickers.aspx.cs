//using System;
//using System.Configuration;
//using System.Data;
//using System.Data.SqlClient;
//using System.Web.UI;
//using System.Web.UI.WebControls;

//namespace WebForms.MemberShipModule
//{
//    public partial class IssuanceStickers : System.Web.UI.Page
//    {
//        protected void Page_Load(object sender, EventArgs e)
//        {
//            if (!IsPostBack)
//            {
//                LoadAllVehicles();
//            }
//        }

//        // Load all vehicles (default view)
//        private void LoadAllVehicles()
//        {
//            string conStr = ConfigurationManager
//                .ConnectionStrings["MemberShipConnection"]
//                .ConnectionString;

//            using (SqlConnection con = new SqlConnection(conStr))
//            {
//                string query = @"
//                SELECT v.MemberID, mp.MemberNo, v.StickerNo, v.VehicleNo,
//                       v.Model, v.Make, v.IssueDate, v.IsActive, v.Remarks
//                FROM MemberVehicles v
//                LEFT JOIN MemberProfile mp ON v.MemberID = mp.MemberID
//                ORDER BY v.MemberID";

//                using (SqlCommand cmd = new SqlCommand(query, con))
//                {
//                    SqlDataAdapter da = new SqlDataAdapter(cmd);
//                    DataTable dt = new DataTable();
//                    da.Fill(dt);
//                    gvData.DataSource = dt;
//                    gvData.DataBind();
//                }
//            }
//        }

//        // SEARCH
//        protected void btnSearch_Click(object sender, EventArgs e)
//        {
//            string memberIDSearch = txtMemberID.Text.Trim();
//            string memberNoSearch = txtMemberNo.Text.Trim();
//            string stickerSearch = txtStickerNo.Text.Trim();
//            string vehicleSearch = txtVehicleNo.Text.Trim();

//            // If all fields are blank, reload all records
//            if (string.IsNullOrWhiteSpace(memberIDSearch) &&
//                string.IsNullOrWhiteSpace(memberNoSearch) &&
//                string.IsNullOrWhiteSpace(stickerSearch) &&
//                string.IsNullOrWhiteSpace(vehicleSearch))
//            {
//                LoadAllVehicles();
//                return;
//            }

//            string conStr = ConfigurationManager
//                .ConnectionStrings["MemberShipConnection"]
//                .ConnectionString;

//            using (SqlConnection con = new SqlConnection(conStr))
//            {
//                // Join with MemberProfile to allow searching by MemberNo (alphanumeric)
//                string query = @"
//                SELECT v.MemberID, mp.MemberNo, v.StickerNo, v.VehicleNo,
//                       v.Model, v.Make, v.IssueDate, v.IsActive, v.Remarks
//                FROM MemberVehicles v
//                LEFT JOIN MemberProfile mp ON v.MemberID = mp.MemberID
//                WHERE
//                (@MemberIDSearch <> '' AND TRY_CAST(v.MemberID AS NVARCHAR(50)) = @MemberIDSearch)
//                OR (@MemberNoSearch <> '' AND mp.MemberNo = @MemberNoSearch)
//                OR (@StickerSearch <> '' AND v.StickerNo = @StickerSearch)
//                OR (@VehicleSearch <> '' AND v.VehicleNo = @VehicleSearch)";

//                using (SqlCommand cmd = new SqlCommand(query, con))
//                {
//                    cmd.Parameters.AddWithValue("@MemberIDSearch", memberIDSearch);
//                    cmd.Parameters.AddWithValue("@MemberNoSearch", memberNoSearch);
//                    cmd.Parameters.AddWithValue("@StickerSearch", stickerSearch);
//                    cmd.Parameters.AddWithValue("@VehicleSearch", vehicleSearch);

//                    SqlDataAdapter da = new SqlDataAdapter(cmd);
//                    DataTable dt = new DataTable();
//                    da.Fill(dt);

//                    gvData.DataSource = dt;
//                    gvData.DataBind();
//                }
//            }
//        }

//        // SET DROPDOWN VALUE
//        protected void gvData_RowDataBound(object sender, GridViewRowEventArgs e)
//        {
//            if (e.Row.RowType == DataControlRowType.DataRow)
//            {
//                DropDownList ddl =
//                    (DropDownList)e.Row.FindControl("ddlStatus");

//                if (ddl != null)
//                {
//                    string status = DataBinder.Eval(e.Row.DataItem, "IsActive").ToString();
//                    // Ensure the value exists in the dropdown before setting
//                    if (ddl.Items.FindByValue(status) != null)
//                    {
//                        ddl.SelectedValue = status;
//                    }
//                }
//            }
//        }

//        // SAVE
//        protected void btnSave_Click(object sender, EventArgs e)
//        {
//            if (Session["Emp_ID"] == null) return;

//            int empId = 0;
//            if (!int.TryParse(Session["Emp_ID"].ToString(), out empId))
//            {
//                ScriptManager.RegisterStartupScript(this, this.GetType(), "error",
//                    "alert('Invalid employee ID in session.');", true);
//                return;
//            }

//            string conStr = ConfigurationManager
//                .ConnectionStrings["MemberShipConnection"]
//                .ConnectionString;

//            using (SqlConnection con = new SqlConnection(conStr))
//            {
//                con.Open();

//                foreach (GridViewRow row in gvData.Rows)
//                {
//                    if (row.RowType == DataControlRowType.DataRow)
//                    {
//                        HiddenField hf =
//                            (HiddenField)row.FindControl("hfStickerNo");

//                        DropDownList ddl =
//                            (DropDownList)row.FindControl("ddlStatus");

//                        TextBox txtRemarks =
//                            (TextBox)row.FindControl("txtRemarks");

//                        if (hf == null || ddl == null || txtRemarks == null) continue;

//                        string stickerNo = hf.Value;
//                        string status = ddl.SelectedValue;
//                        string remarks = txtRemarks.Text.Trim();

//                        string query = @"
//                        UPDATE MemberVehicles
//                        SET IsActive = @IsActive,
//                            Emp_ID = @Emp_ID,
//                            Remarks = @Remarks
//                        WHERE StickerNo = @StickerNo";

//                        using (SqlCommand cmd = new SqlCommand(query, con))
//                        {
//                            cmd.Parameters.AddWithValue("@IsActive", status);
//                            cmd.Parameters.AddWithValue("@Emp_ID", empId);
//                            cmd.Parameters.AddWithValue("@Remarks", remarks);
//                            cmd.Parameters.AddWithValue("@StickerNo", stickerNo);
//                            cmd.ExecuteNonQuery();
//                        }
//                    }
//                }
//            }

//            // Re-bind to show updated data
//            btnSearch_Click(null, null);
//            ScriptManager.RegisterStartupScript(this, this.GetType(), "success",
//                "alert('Changes saved successfully.');", true);
//        }

//    }
//}





using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebForms.MemberShipModule
{
    public partial class IssuanceStickers : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadAllVehicles();
                ClearSelectedMember();
            }
            gvData.EnablePersistedSelection = false;

        }

        // Load all vehicles (default view)
        private void LoadAllVehicles()
        {
            string conStr = ConfigurationManager
                .ConnectionStrings["MemberShipConnection"]
                .ConnectionString;

            using (SqlConnection con = new SqlConnection(conStr))
            {
                string query = @"
                SELECT v.VehicleID, v.MemberID, mp.MemberNo, v.StickerNo, v.VehicleNo,
                       v.Model, v.Make, v.IssueDate, v.IsActive, v.Remarks, v.RecordStatus
                FROM MemberVehicles v
                LEFT JOIN MemberProfile mp ON v.MemberID = mp.MemberID
                WHERE v.RecordStatus = 'Active'
                ORDER BY v.VehicleID DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvData.DataSource = dt;
                    gvData.DataBind();
                }
            }
        }

        // SEARCH - Also stores selected member info for adding vehicles
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string memberIDSearch = txtMemberID.Text.Trim();
            string memberNoSearch = txtMemberNo.Text.Trim();
            string stickerSearch = txtStickerNo.Text.Trim();
            string vehicleSearch = txtVehicleNo.Text.Trim();

            // If all fields are blank, reload all records
            if (string.IsNullOrWhiteSpace(memberIDSearch) &&
                string.IsNullOrWhiteSpace(memberNoSearch) &&
                string.IsNullOrWhiteSpace(stickerSearch) &&
                string.IsNullOrWhiteSpace(vehicleSearch))
            {
                LoadAllVehicles();
                ClearSelectedMember();
                return;
            }

            string conStr = ConfigurationManager
                .ConnectionStrings["MemberShipConnection"]
                .ConnectionString;

            using (SqlConnection con = new SqlConnection(conStr))
            {
                string query = @"
                SELECT v.VehicleID, v.MemberID, mp.MemberNo, v.StickerNo, v.VehicleNo,
                       v.Model, v.Make, v.IssueDate, v.IsActive, v.Remarks, v.RecordStatus
                FROM MemberVehicles v
                LEFT JOIN MemberProfile mp ON v.MemberID = mp.MemberID
                WHERE v.RecordStatus = 'Active'
                AND (
                    (@MemberIDSearch = '' OR TRY_CAST(v.MemberID AS NVARCHAR(50)) = @MemberIDSearch)
                    OR (@MemberNoSearch = '' OR mp.MemberNo = @MemberNoSearch)
                    OR (@StickerSearch = '' OR v.StickerNo = @StickerSearch)
                    OR (@VehicleSearch = '' OR v.VehicleNo = @VehicleSearch)
                )";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@MemberIDSearch", memberIDSearch);
                    cmd.Parameters.AddWithValue("@MemberNoSearch", memberNoSearch);
                    cmd.Parameters.AddWithValue("@StickerSearch", stickerSearch);
                    cmd.Parameters.AddWithValue("@VehicleSearch", vehicleSearch);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvData.DataSource = dt;
                    gvData.DataBind();

                    // Store the member info from first record if exists for adding new vehicle
                    if (dt.Rows.Count > 0)
                    {
                        DataRow firstRow = dt.Rows[0];
                        if (firstRow["MemberID"] != DBNull.Value)
                        {
                            hdnSelectedMemberID.Value = firstRow["MemberID"].ToString();
                            hdnSelectedMemberNo.Value = firstRow["MemberNo"] != DBNull.Value ? firstRow["MemberNo"].ToString() : "";
                            lblSelectedMemberInfo.Text = "Selected Member: " + hdnSelectedMemberNo.Value + " (ID: " + hdnSelectedMemberID.Value + ")";
                        }
                        else
                        {
                            ClearSelectedMember();
                        }
                    }
                    else
                    {
                        ClearSelectedMember();
                    }
                }
            }
        }

        // ADD NEW VEHICLE - Pre-fills member info from selected member
        protected void btnAddVehicle_Click(object sender, EventArgs e)
        {
            DataTable dt = GetCurrentDataTable();

            // Add new empty row
            DataRow newRow = dt.NewRow();
            newRow["VehicleID"] = 0;

            // Pre-fill member info from selected member (from search)
            if (!string.IsNullOrEmpty(hdnSelectedMemberID.Value))
            {
                newRow["MemberID"] = Convert.ToInt32(hdnSelectedMemberID.Value);
                newRow["MemberNo"] = hdnSelectedMemberNo.Value;
            }
            else
            {
                newRow["MemberID"] = DBNull.Value;
                newRow["MemberNo"] = "";
            }

            newRow["StickerNo"] = "";
            newRow["VehicleNo"] = "";
            newRow["Model"] = "";
            newRow["Make"] = "";
            newRow["IssueDate"] = DateTime.Now;
            newRow["IsActive"] = "Active";
            newRow["Remarks"] = "";
            newRow["RecordStatus"] = "Active";
            dt.Rows.InsertAt(newRow, 0);

            gvData.DataSource = dt;
            gvData.DataBind();

            // Set the new row to edit mode
            if (gvData.Rows.Count > 0)
            {
                GridViewRow firstRow = gvData.Rows[0];
                SetRowEditMode(firstRow, true);

                // Focus on sticker number field
                ScriptManager.RegisterStartupScript(this, GetType(), "focus",
                    "setTimeout(function(){ var input = document.getElementById('" + ((TextBox)firstRow.FindControl("txtEditStickerNo")).ClientID + "'); if(input) input.focus(); }, 100);", true);
            }
        }

        // EDIT button click
        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            GridViewRow row = (GridViewRow)btn.NamingContainer;
            SetRowEditMode(row, true);
        }

        // UPDATE button click - Insert or Update
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            GridViewRow row = (GridViewRow)btn.NamingContainer;

            // Get values from edit controls
            TextBox txtEditStickerNo = (TextBox)row.FindControl("txtEditStickerNo");
            TextBox txtEditVehicleNo = (TextBox)row.FindControl("txtEditVehicleNo");
            TextBox txtEditModel = (TextBox)row.FindControl("txtEditModel");
            TextBox txtEditMake = (TextBox)row.FindControl("txtEditMake");
            TextBox txtEditIssueDate = (TextBox)row.FindControl("txtEditIssueDate");
            TextBox txtEditRemarks = (TextBox)row.FindControl("txtEditRemarks");
            DropDownList ddlEditStatus = (DropDownList)row.FindControl("ddlEditStatus");
            HiddenField hfVehicleID = (HiddenField)row.FindControl("hfVehicleID");
            HiddenField hfMemberID = (HiddenField)row.FindControl("hfMemberID");
            HiddenField hfMemberNo = (HiddenField)row.FindControl("hfMemberNo");

            int vehicleID = Convert.ToInt32(hfVehicleID.Value);
            int memberID = 0;

            // If it's a new row (VehicleID = 0) and we have selected member info
            if (vehicleID == 0 && !string.IsNullOrEmpty(hdnSelectedMemberID.Value))
            {
                memberID = Convert.ToInt32(hdnSelectedMemberID.Value);
            }
            else if (hfMemberID.Value != "")
            {
                memberID = Convert.ToInt32(hfMemberID.Value);
            }

            string stickerNo = txtEditStickerNo.Text.Trim();
            string vehicleNo = txtEditVehicleNo.Text.Trim();
            string model = txtEditModel.Text.Trim();
            string make = txtEditMake.Text.Trim();
            DateTime? issueDate = string.IsNullOrEmpty(txtEditIssueDate.Text) ? (DateTime?)null : Convert.ToDateTime(txtEditIssueDate.Text);
            string remarks = txtEditRemarks.Text.Trim();
            string status = ddlEditStatus.SelectedValue;

            if (string.IsNullOrEmpty(vehicleNo))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error", "alert('Vehicle Number is required!');", true);
                return;
            }

            if (memberID == 0)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error", "alert('Please select a member first by searching!');", true);
                return;
            }

            string conStr = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(conStr))
            {
                con.Open();

                if (vehicleID == 0)
                {
                    // INSERT new vehicle
                    string insertQuery = @"
                    INSERT INTO MemberVehicles (MemberID, StickerNo, VehicleNo, Model, Make, IssueDate, IsActive, Remarks, CreatedDate, RecordStatus)
                    VALUES (@MemberID, @StickerNo, @VehicleNo, @Model, @Make, @IssueDate, @IsActive, @Remarks, GETDATE(), 'Active');
                    SELECT SCOPE_IDENTITY();";

                    using (SqlCommand cmd = new SqlCommand(insertQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@MemberID", memberID);
                        cmd.Parameters.AddWithValue("@StickerNo", string.IsNullOrEmpty(stickerNo) ? (object)DBNull.Value : stickerNo);
                        cmd.Parameters.AddWithValue("@VehicleNo", vehicleNo);
                        cmd.Parameters.AddWithValue("@Model", string.IsNullOrEmpty(model) ? (object)DBNull.Value : model);
                        cmd.Parameters.AddWithValue("@Make", string.IsNullOrEmpty(make) ? (object)DBNull.Value : make);
                        cmd.Parameters.AddWithValue("@IssueDate", issueDate.HasValue ? (object)issueDate.Value : DBNull.Value);
                        cmd.Parameters.AddWithValue("@IsActive", status);
                        cmd.Parameters.AddWithValue("@Remarks", string.IsNullOrEmpty(remarks) ? (object)DBNull.Value : remarks);
                        object newId = cmd.ExecuteScalar();
                    }
                }
                else
                {
                    // UPDATE existing vehicle
                    string updateQuery = @"
                    UPDATE MemberVehicles 
                    SET StickerNo = @StickerNo,
                        VehicleNo = @VehicleNo,
                        Model = @Model,
                        Make = @Make,
                        IssueDate = @IssueDate,
                        IsActive = @IsActive,
                        Remarks = @Remarks
                    WHERE VehicleID = @VehicleID";

                    using (SqlCommand cmd = new SqlCommand(updateQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@VehicleID", vehicleID);
                        cmd.Parameters.AddWithValue("@StickerNo", string.IsNullOrEmpty(stickerNo) ? (object)DBNull.Value : stickerNo);
                        cmd.Parameters.AddWithValue("@VehicleNo", vehicleNo);
                        cmd.Parameters.AddWithValue("@Model", string.IsNullOrEmpty(model) ? (object)DBNull.Value : model);
                        cmd.Parameters.AddWithValue("@Make", string.IsNullOrEmpty(make) ? (object)DBNull.Value : make);
                        cmd.Parameters.AddWithValue("@IssueDate", issueDate.HasValue ? (object)issueDate.Value : DBNull.Value);
                        cmd.Parameters.AddWithValue("@IsActive", status);
                        cmd.Parameters.AddWithValue("@Remarks", string.IsNullOrEmpty(remarks) ? (object)DBNull.Value : remarks);
                        cmd.ExecuteNonQuery();
                    }
                }
            }

            // Reload data while preserving selected member
            if (!string.IsNullOrEmpty(hdnSelectedMemberID.Value))
            {
                // Reload with the same member filter
                txtMemberID.Text = hdnSelectedMemberID.Value;
                btnSearch_Click(null, null);
            }
            else
            {
                LoadAllVehicles();
            }

            ScriptManager.RegisterStartupScript(this, GetType(), "success", "alert('Vehicle saved successfully.');", true);
        }

        // CANCEL button click
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(hdnSelectedMemberID.Value))
            {
                txtMemberID.Text = hdnSelectedMemberID.Value;
                btnSearch_Click(null, null);
            }
            else
            {
                LoadAllVehicles();
            }
        }

        // DELETE button click (Soft Delete)
        protected void btnDelete_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            GridViewRow row = (GridViewRow)btn.NamingContainer;
            HiddenField hfVehicleID = (HiddenField)row.FindControl("hfVehicleID");
            int vehicleID = Convert.ToInt32(hfVehicleID.Value);

            string conStr = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(conStr))
            {
                string deleteQuery = "UPDATE MemberVehicles SET RecordStatus = 'Deactive' WHERE VehicleID = @VehicleID";
                using (SqlCommand cmd = new SqlCommand(deleteQuery, con))
                {
                    cmd.Parameters.AddWithValue("@VehicleID", vehicleID);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            if (!string.IsNullOrEmpty(hdnSelectedMemberID.Value))
            {
                txtMemberID.Text = hdnSelectedMemberID.Value;
                btnSearch_Click(null, null);
            }
            else
            {
                LoadAllVehicles();
            }

            ScriptManager.RegisterStartupScript(this, GetType(), "success", "alert('Vehicle deleted successfully.');", true);
        }

        // SET DROPDOWN VALUE & Show/Hide Edit/Delete buttons
        protected void gvData_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                DropDownList ddl = (DropDownList)e.Row.FindControl("ddlStatus");
                if (ddl != null)
                {
                    string status = DataBinder.Eval(e.Row.DataItem, "IsActive").ToString();
                    if (ddl.Items.FindByValue(status) != null)
                    {
                        ddl.SelectedValue = status;
                    }
                }

                // For Edit/Delete mode visibility
                Button btnEdit = (Button)e.Row.FindControl("btnEdit");
                Button btnDelete = (Button)e.Row.FindControl("btnDelete");
                Button btnUpdate = (Button)e.Row.FindControl("btnUpdate");
                Button btnCancel = (Button)e.Row.FindControl("btnCancel");
                Panel pnlView = (Panel)e.Row.FindControl("pnlView");
                Panel pnlEdit = (Panel)e.Row.FindControl("pnlEdit");

                if (btnEdit != null && btnDelete != null && btnUpdate != null && btnCancel != null && pnlView != null && pnlEdit != null)
                {
                    // Initially show view mode
                    pnlView.Visible = true;
                    pnlEdit.Visible = false;
                }
            }
        }

        // Helper: Set row to edit mode
        private void SetRowEditMode(GridViewRow row, bool isEditMode)
        {
            Panel pnlView = (Panel)row.FindControl("pnlView");
            Panel pnlEdit = (Panel)row.FindControl("pnlEdit");

            if (pnlView != null && pnlEdit != null)
            {
                pnlView.Visible = !isEditMode;
                pnlEdit.Visible = isEditMode;
            }

            // Populate edit controls with current values
            if (isEditMode)
            {
                Label lblMemberID = (Label)row.FindControl("lblMemberID");
                Label lblMemberNo = (Label)row.FindControl("lblMemberNo");
                Label lblStickerNo = (Label)row.FindControl("lblStickerNo");
                Label lblVehicleNo = (Label)row.FindControl("lblVehicleNo");
                Label lblModel = (Label)row.FindControl("lblModel");
                Label lblMake = (Label)row.FindControl("lblMake");
                Label lblIssueDate = (Label)row.FindControl("lblIssueDate");
                Label lblRemarks = (Label)row.FindControl("lblRemarks");
                DropDownList ddlStatus = (DropDownList)row.FindControl("ddlStatus");

                TextBox txtEditStickerNo = (TextBox)row.FindControl("txtEditStickerNo");
                TextBox txtEditVehicleNo = (TextBox)row.FindControl("txtEditVehicleNo");
                TextBox txtEditModel = (TextBox)row.FindControl("txtEditModel");
                TextBox txtEditMake = (TextBox)row.FindControl("txtEditMake");
                TextBox txtEditIssueDate = (TextBox)row.FindControl("txtEditIssueDate");
                TextBox txtEditRemarks = (TextBox)row.FindControl("txtEditRemarks");
                DropDownList ddlEditStatus = (DropDownList)row.FindControl("ddlEditStatus");

                if (txtEditStickerNo != null && lblStickerNo != null)
                    txtEditStickerNo.Text = lblStickerNo.Text;
                if (txtEditVehicleNo != null && lblVehicleNo != null)
                    txtEditVehicleNo.Text = lblVehicleNo.Text;
                if (txtEditModel != null && lblModel != null)
                    txtEditModel.Text = lblModel.Text;
                if (txtEditMake != null && lblMake != null)
                    txtEditMake.Text = lblMake.Text;
                if (txtEditIssueDate != null && lblIssueDate != null)
                    txtEditIssueDate.Text = lblIssueDate.Text;
                if (txtEditRemarks != null && lblRemarks != null)
                    txtEditRemarks.Text = lblRemarks.Text;
                if (ddlEditStatus != null && ddlStatus != null)
                    ddlEditStatus.SelectedValue = ddlStatus.SelectedValue;
            }
        }

        // Helper: Get current DataTable from GridView
        private DataTable GetCurrentDataTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("VehicleID", typeof(int));
            dt.Columns.Add("MemberID", typeof(int));
            dt.Columns.Add("MemberNo", typeof(string));
            dt.Columns.Add("StickerNo", typeof(string));
            dt.Columns.Add("VehicleNo", typeof(string));
            dt.Columns.Add("Model", typeof(string));
            dt.Columns.Add("Make", typeof(string));
            dt.Columns.Add("IssueDate", typeof(DateTime));
            dt.Columns.Add("IsActive", typeof(string));
            dt.Columns.Add("Remarks", typeof(string));
            dt.Columns.Add("RecordStatus", typeof(string));

            foreach (GridViewRow row in gvData.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    DataRow dr = dt.NewRow();

                    HiddenField hfVehicleID = (HiddenField)row.FindControl("hfVehicleID");
                    Label lblMemberID = (Label)row.FindControl("lblMemberID");
                    Label lblMemberNo = (Label)row.FindControl("lblMemberNo");
                    Label lblStickerNo = (Label)row.FindControl("lblStickerNo");
                    Label lblVehicleNo = (Label)row.FindControl("lblVehicleNo");
                    Label lblModel = (Label)row.FindControl("lblModel");
                    Label lblMake = (Label)row.FindControl("lblMake");
                    Label lblIssueDate = (Label)row.FindControl("lblIssueDate");
                    Label lblRemarks = (Label)row.FindControl("lblRemarks");
                    DropDownList ddlStatus = (DropDownList)row.FindControl("ddlStatus");

                    dr["VehicleID"] = hfVehicleID != null ? Convert.ToInt32(hfVehicleID.Value) : 0;
                    dr["MemberID"] = lblMemberID != null && !string.IsNullOrEmpty(lblMemberID.Text) ? (object)Convert.ToInt32(lblMemberID.Text) : DBNull.Value;
                    dr["MemberNo"] = lblMemberNo != null ? lblMemberNo.Text : "";
                    dr["StickerNo"] = lblStickerNo != null ? lblStickerNo.Text : "";
                    dr["VehicleNo"] = lblVehicleNo != null ? lblVehicleNo.Text : "";
                    dr["Model"] = lblModel != null ? lblModel.Text : "";
                    dr["Make"] = lblMake != null ? lblMake.Text : "";
                    dr["IssueDate"] = lblIssueDate != null && !string.IsNullOrEmpty(lblIssueDate.Text) ? (object)Convert.ToDateTime(lblIssueDate.Text) : DBNull.Value;
                    dr["IsActive"] = ddlStatus != null ? ddlStatus.SelectedValue : "Active";
                    dr["Remarks"] = lblRemarks != null ? lblRemarks.Text : "";
                    dr["RecordStatus"] = "Active";

                    dt.Rows.Add(dr);
                }
            }

            return dt;
        }

        // Helper: Clear selected member
        private void ClearSelectedMember()
        {
            hdnSelectedMemberID.Value = "";
            hdnSelectedMemberNo.Value = "";
            lblSelectedMemberInfo.Text = "No member selected. Search first to add vehicles.";
        }

        // SAVE Status Changes only (from dropdown and remarks)
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (Session["Emp_ID"] == null) return;

            int empId = 0;
            if (!int.TryParse(Session["Emp_ID"].ToString(), out empId))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "error",
                    "alert('Invalid employee ID in session.');", true);
                return;
            }

            string conStr = ConfigurationManager
                .ConnectionStrings["MemberShipConnection"]
                .ConnectionString;

            using (SqlConnection con = new SqlConnection(conStr))
            {
                con.Open();

                foreach (GridViewRow row in gvData.Rows)
                {
                    if (row.RowType == DataControlRowType.DataRow)
                    {
                        // Skip if in edit mode
                        Panel pnlEdit = (Panel)row.FindControl("pnlEdit");
                        if (pnlEdit != null && pnlEdit.Visible)
                            continue;

                        HiddenField hfVehicleID = (HiddenField)row.FindControl("hfVehicleID");
                        DropDownList ddl = (DropDownList)row.FindControl("ddlStatus");
                        TextBox txtRemarks = (TextBox)row.FindControl("txtRemarks");

                        if (hfVehicleID == null || ddl == null || txtRemarks == null) continue;

                        int vehicleID = Convert.ToInt32(hfVehicleID.Value);
                        if (vehicleID == 0) continue; // Skip new unsaved rows

                        string status = ddl.SelectedValue;
                        string remarks = txtRemarks.Text.Trim();

                        string query = @"
                        UPDATE MemberVehicles
                        SET IsActive = @IsActive,
                            Emp_ID = @Emp_ID,
                            Remarks = @Remarks
                        WHERE VehicleID = @VehicleID";

                        using (SqlCommand cmd = new SqlCommand(query, con))
                        {
                            cmd.Parameters.AddWithValue("@IsActive", status);
                            cmd.Parameters.AddWithValue("@Emp_ID", empId);
                            cmd.Parameters.AddWithValue("@Remarks", remarks);
                            cmd.Parameters.AddWithValue("@VehicleID", vehicleID);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
            }

            // Re-bind to show updated data while preserving selected member
            if (!string.IsNullOrEmpty(hdnSelectedMemberID.Value))
            {
                txtMemberID.Text = hdnSelectedMemberID.Value;
                btnSearch_Click(null, null);
            }
            else
            {
                LoadAllVehicles();
            }

            ScriptManager.RegisterStartupScript(this, this.GetType(), "success",
                "alert('Status changes saved successfully.');", true);
        }
    }
}
