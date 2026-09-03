using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace Membership
{
    public partial class VehicleDetails : System.Web.UI.Page
    {
        string connectionString = (ConfigurationManager.ConnectionStrings["MemberShipConnection"] != null) ? ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString : "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Initial state
            }
        }

        private void ShowAlert(string message, bool isError = false)
        {
            divAlert.Visible = true;
            lblAlertMsg.Text = message;
            if (isError)
            {
                divAlert.Style["background-color"] = "#fee2e2";
                divAlert.Style["border"] = "1px solid #fecaca";
                lblAlertMsg.Style["color"] = "#991b1b";
            }
            else
            {
                divAlert.Style["background-color"] = "#dcfce7";
                divAlert.Style["border"] = "1px solid #bbf7d0";
                lblAlertMsg.Style["color"] = "#166534";
            }
        }

        private void HideAlert()
        {
            divAlert.Visible = false;
        }

        // --- MEMBER SEARCH LOGIC ---

        protected void btnSearchMember_Click(object sender, EventArgs e)
        {
            BindMembers();
        }

        protected void btnClearMemberSearch_Click(object sender, EventArgs e)
        {
            txtSearchMemberNo.Text = "";
            txtSearchName.Text = "";
            txtSearchNIC.Text = "";
            txtSearchMobile.Text = "";
            gvMembers.DataSource = null;
            gvMembers.DataBind();
            HideAlert();
        }

        private void BindMembers()
        {
            HideAlert();
            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("usp_SearchMembers", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@PageNumber", SqlDbType.Int).Value = 1;
                cmd.Parameters.Add("@PageSize", SqlDbType.Int).Value = 100;

                if (!string.IsNullOrEmpty(txtSearchMemberNo.Text)) cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = txtSearchMemberNo.Text.Trim();
                if (!string.IsNullOrEmpty(txtSearchName.Text)) cmd.Parameters.Add("@MemberName", SqlDbType.NVarChar, 200).Value = txtSearchName.Text.Trim();
                if (!string.IsNullOrEmpty(txtSearchNIC.Text)) cmd.Parameters.Add("@NIC", SqlDbType.NVarChar, 50).Value = txtSearchNIC.Text.Trim();
                if (!string.IsNullOrEmpty(txtSearchMobile.Text)) cmd.Parameters.Add("@Mobile", SqlDbType.NVarChar, 50).Value = txtSearchMobile.Text.Trim();

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvMembers.DataSource = dt;
                    gvMembers.DataBind();
                }
            }
        }

        protected void gvMembers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ManageVehicles")
            {
                int memberId = Convert.ToInt32(e.CommandArgument);
                hdnSelectedMemberID.Value = memberId.ToString();

                LoadMemberDashboard(memberId);
            }
        }

        // --- DASHBOARD LOGIC ---

        private void LoadMemberDashboard(int memberId)
        {
            HideAlert();

            // Fetch Member Info
            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("usp_GetMemberNameByID", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@ID", SqlDbType.Int).Value = memberId;
                con.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        lblDashMemberNo.Text = dr["MemberNo"].ToString();
                        lblDashMemberName.Text = dr["MemberName"].ToString();
                    }
                }
            }

            pnlMemberSearch.Visible = false;
            pnlVehicleDashboard.Visible = true;

            BindMemberVehicles(memberId);
        }

        private void BindMemberVehicles(int memberId)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "SELECT VehicleID, StickerNo, RFIDTag, VehicleNo, Make, Model, IssueDate, ExpiryDate, RecordStatus, Remarks " +
                               "FROM MemberVehicles WHERE MemberID = @MemberID ORDER BY VehicleID DESC";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.CommandType = CommandType.Text;
                    cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        // Fallback columns just in case table schema is different from expected
                        if (!dt.Columns.Contains("VehicleID"))
                        {
                            dt.Columns.Add("VehicleID", typeof(string));
                            foreach (System.Data.DataRow row in dt.Rows)
                            {
                                row["VehicleID"] = row["VehicleNo"];
                            }
                        }

                        if (!dt.Columns.Contains("RFIDTag")) dt.Columns.Add("RFIDTag", typeof(string)).DefaultValue = "";
                        if (!dt.Columns.Contains("ExpiryDate")) dt.Columns.Add("ExpiryDate", typeof(DateTime)).DefaultValue = DBNull.Value;
                        if (!dt.Columns.Contains("RecordStatus")) dt.Columns.Add("RecordStatus", typeof(string)).DefaultValue = "Active";
                        if (!dt.Columns.Contains("Remarks")) dt.Columns.Add("Remarks", typeof(string)).DefaultValue = "";

                        gvVehicles.DataSource = dt;
                        gvVehicles.DataBind();
                    }
                }
            }
        }

        protected void btnBackToSearch_Click(object sender, EventArgs e)
        {
            pnlVehicleDashboard.Visible = false;
            pnlMemberSearch.Visible = true;
            hdnSelectedMemberID.Value = "";
            HideAlert();
        }

        // --- ADD VEHICLE MODAL LOGIC ---

        protected void btnOpenAddModal_Click(object sender, EventArgs e)
        {
            lblModalMemberNo.Text = lblDashMemberNo.Text;
            ClearAddFields();
            pnlAddVehicleModal.Visible = true;
        }

        protected void btnCancelAdd_Click(object sender, EventArgs e)
        {
            pnlAddVehicleModal.Visible = false;
        }

        protected void btnSaveNewVehicle_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hdnSelectedMemberID.Value))
            {
                ShowAlert("Member session lost. Please search again.", true);
                pnlAddVehicleModal.Visible = false;
                return;
            }

            if (string.IsNullOrEmpty(txtAddVehicleNo.Text))
            {
                ShowAlert("Vehicle No is required.", true);
                return;
            }

            int memberId = Convert.ToInt32(hdnSelectedMemberID.Value);

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                string query = "INSERT INTO MemberVehicles (MemberID, StickerNo, RFIDTag, VehicleNo, Model, Make, IssueDate, ExpiryDate, IsActive, RecordStatus, Remarks, CreatedDate) " +
                               "VALUES (@MemberID, @StickerNo, @RFIDTag, @VehicleNo, @Model, @Make, @IssueDate, @ExpiryDate, 'Active', 'Active', 'New Vehicle Added', GETDATE())";
                using (SqlCommand cmdIns = new SqlCommand(query, con))
                {
                    cmdIns.CommandType = CommandType.Text;
                    cmdIns.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                    cmdIns.Parameters.Add("@StickerNo", SqlDbType.NVarChar, 50).Value = txtAddStickerNo.Text.Trim();
                    cmdIns.Parameters.Add("@RFIDTag", SqlDbType.NVarChar, 50).Value = txtAddRFIDTag.Text.Trim();
                    cmdIns.Parameters.Add("@VehicleNo", SqlDbType.NVarChar, 50).Value = txtAddVehicleNo.Text.Trim();
                    cmdIns.Parameters.Add("@Model", SqlDbType.NVarChar, 50).Value = txtAddModel.Text.Trim();
                    cmdIns.Parameters.Add("@Make", SqlDbType.NVarChar, 50).Value = txtAddMake.Text.Trim();

                    if (!string.IsNullOrEmpty(txtAddIssueDate.Text))
                        cmdIns.Parameters.Add("@IssueDate", SqlDbType.DateTime).Value = Convert.ToDateTime(txtAddIssueDate.Text);
                    else
                        cmdIns.Parameters.Add("@IssueDate", SqlDbType.DateTime).Value = DBNull.Value;

                    if (!string.IsNullOrEmpty(txtAddExpiryDate.Text))
                        cmdIns.Parameters.Add("@ExpiryDate", SqlDbType.DateTime).Value = Convert.ToDateTime(txtAddExpiryDate.Text);
                    else
                        cmdIns.Parameters.Add("@ExpiryDate", SqlDbType.DateTime).Value = DBNull.Value;

                    cmdIns.ExecuteNonQuery();
                }
            }

            ShowAlert("Vehicle successfully registered for " + lblDashMemberName.Text, false);
            pnlAddVehicleModal.Visible = false;
            BindMemberVehicles(memberId);
        }

        private void ClearAddFields()
        {
            txtAddStickerNo.Text = "";
            txtAddRFIDTag.Text = "";
            txtAddVehicleNo.Text = "";
            txtAddMake.Text = "";
            txtAddModel.Text = "";
            txtAddColor.Text = "";
            txtAddOwnership.Text = "";
            txtAddIssueDate.Text = "";
            txtAddExpiryDate.Text = "";
        }

        // --- UPDATE STATUS LOGIC ---

        protected void gvVehicles_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandArgument == null || string.IsNullOrEmpty(e.CommandArgument.ToString())) return;

            string vehicleNo = e.CommandArgument.ToString();

            if (e.CommandName == "EditStatus")
            {
                hdnEditVehicleID.Value = vehicleNo;

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();
                    using (SqlCommand cmd = new SqlCommand("SELECT RecordStatus, Remarks FROM MemberVehicles WHERE VehicleNo = @VehicleNo", con))
                    {
                        cmd.CommandType = CommandType.Text;
                        cmd.Parameters.Add("@VehicleNo", SqlDbType.NVarChar, 50).Value = vehicleNo;
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                string status = dr["RecordStatus"].ToString();
                                if (string.IsNullOrEmpty(status)) status = "Active";
                                try { ddlEditStatus.SelectedValue = status; } catch { ddlEditStatus.SelectedIndex = 0; }
                                txtEditRemarks.Text = dr["Remarks"].ToString();
                            }
                        }
                    }
                }

                statusModal.Visible = true;
            }
            else if (e.CommandName == "ReplaceSticker")
            {
                // Fetch existing vehicle details to pre-fill the add modal
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();
                    using (SqlCommand cmd = new SqlCommand("SELECT VehicleNo, Make, Model FROM MemberVehicles WHERE VehicleNo = @VehicleNo", con))
                    {
                        cmd.CommandType = CommandType.Text;
                        cmd.Parameters.Add("@VehicleNo", SqlDbType.NVarChar, 50).Value = vehicleNo;
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                ClearAddFields();
                                txtAddVehicleNo.Text = dr["VehicleNo"].ToString();
                                txtAddMake.Text = dr["Make"].ToString();
                                txtAddModel.Text = dr["Model"].ToString();
                                lblModalMemberNo.Text = lblDashMemberNo.Text;
                                pnlAddVehicleModal.Visible = true;
                                ShowAlert("Replacing sticker for vehicle: " + txtAddVehicleNo.Text, false);
                            }
                        }
                    }
                }
            }
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            statusModal.Visible = false;
        }

        protected void btnSaveStatus_Click(object sender, EventArgs e)
        {
            string vehicleNo = hdnEditVehicleID.Value;
            string newStatus = ddlEditStatus.SelectedValue;
            string remarks = txtEditRemarks.Text.Trim();

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand("UPDATE MemberVehicles SET RecordStatus = @Status, IsActive = @Status, Remarks = @Remarks WHERE VehicleNo = @VehicleNo", con))
                {
                    cmd.CommandType = CommandType.Text;
                    cmd.Parameters.Add("@VehicleNo", SqlDbType.NVarChar, 50).Value = vehicleNo;
                    cmd.Parameters.Add("@Status", SqlDbType.NVarChar, 50).Value = newStatus;
                    cmd.Parameters.Add("@Remarks", SqlDbType.NVarChar, -1).Value = remarks;
                    cmd.ExecuteNonQuery();
                }
            }

            statusModal.Visible = false;
            ShowAlert("Vehicle status updated successfully.", false);

            if (!string.IsNullOrEmpty(hdnSelectedMemberID.Value))
            {
                BindMemberVehicles(Convert.ToInt32(hdnSelectedMemberID.Value));
            }
        }
    }
}
