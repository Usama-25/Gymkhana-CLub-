using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MemberShipModule
{
    public partial class MembershipStatusAdjustment : System.Web.UI.Page
    {
        private string Con
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
            using (SqlConnection con = new SqlConnection(Con))
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
            if (e.CommandName == "ManageStatus")
            {
                string memberNo = e.CommandArgument.ToString();
                LoadMemberDashboard(memberNo);
            }
        }

        // --- DASHBOARD LOGIC ---

        private void LoadMemberDashboard(string memberNo)
        {
            HideAlert();
            using (SqlConnection con = new SqlConnection(Con))
            using (SqlCommand cmd = new SqlCommand("usp_GetMemberForStatusAdjustment", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = memberNo;
                con.Open();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        hdnMemberProfileID.Value = HasColumn(dr, "MemberProfileID") ? dr["MemberProfileID"].ToString() : "0";
                        hdnMID.Value = HasColumn(dr, "MemberID") ? dr["MemberID"].ToString() : "0";
                        
                        lblDashMemberNo.Text = memberNo;
                        lblDashMemberName.Text = dr["MemberName"].ToString();
                        
                        string accountStatus = HasColumn(dr, "AccountStatus") ? dr["AccountStatus"].ToString() : "N/A";
                        string residentialStatus = HasColumn(dr, "ResidentialStatus") ? dr["ResidentialStatus"].ToString() : "N/A";
                        string status = HasColumn(dr, "Status") ? dr["Status"].ToString() : "N/A";

                        lblCurrentAccountStatus.Text = accountStatus;
                        lblCurrentResidentialStatus.Text = residentialStatus;
                        lblCurrentMembershipStatus.Text = status;

                        pnlMemberSearch.Visible = false;
                        pnlDashboard.Visible = true;

                        LoadChangeLog();
                    }
                    else
                    {
                        ShowAlert("Member details not found.", true);
                    }
                }
            }
        }

        protected void btnBackToSearch_Click(object sender, EventArgs e)
        {
            pnlDashboard.Visible = false;
            pnlMemberSearch.Visible = true;
            hdnMemberProfileID.Value = "0";
            hdnMID.Value = "0";
            HideAlert();
        }

        private void LoadChangeLog()
        {
            if (string.IsNullOrEmpty(hdnMemberProfileID.Value) || hdnMemberProfileID.Value == "0") return;

            try
            {
                using (SqlConnection con = new SqlConnection(Con))
                using (SqlCommand cmd = new SqlCommand("usp_GetMemberStatusChangeLog", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@MemberProfileID", SqlDbType.Int).Value = Convert.ToInt32(hdnMemberProfileID.Value);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvChangeLog.DataSource = dt;
                    gvChangeLog.DataBind();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadChangeLog Error: " + ex.Message);
            }
        }

        // --- MODAL OPEN/CLOSE LOGIC ---

        protected void btnOpenAccountModal_Click(object sender, EventArgs e)
        {
            txtModalCurrentAccountStatus.Text = lblCurrentAccountStatus.Text;
            pnlAccountStatusModal.Visible = true;
        }

        protected void btnCancelAccountStatus_Click(object sender, EventArgs e)
        {
            pnlAccountStatusModal.Visible = false;
        }

        protected void btnOpenResidentialModal_Click(object sender, EventArgs e)
        {
            txtModalCurrentResidentialStatus.Text = lblCurrentResidentialStatus.Text;
            pnlResidentialStatusModal.Visible = true;
        }

        protected void btnCancelResidentialStatus_Click(object sender, EventArgs e)
        {
            pnlResidentialStatusModal.Visible = false;
        }

        protected void btnOpenMembershipModal_Click(object sender, EventArgs e)
        {
            txtModalCurrentMembershipStatus.Text = lblCurrentMembershipStatus.Text;
            pnlMembershipStatusModal.Visible = true;
        }

        protected void btnCancelMembershipStatus_Click(object sender, EventArgs e)
        {
            pnlMembershipStatusModal.Visible = false;
        }

        // --- SAVE LOGIC ---

        protected void btnSaveAccountStatus_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtAccountStatusStartDate.Text) || string.IsNullOrEmpty(txtAccountStatusEndDate.Text))
            {
                ShowAlert("Start Date and End Date are required for Account Status.", true);
                return;
            }

            UpdateStatus("AccountStatus", ddlNewAccountStatus.SelectedValue, txtAccountStatusStartDate.Text, txtAccountStatusEndDate.Text, txtAccountStatusReason.Text);
            pnlAccountStatusModal.Visible = false;
        }

        protected void btnSaveResidentialStatus_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtResidentialStatusStartDate.Text) || string.IsNullOrEmpty(txtResidentialStatusEndDate.Text))
            {
                ShowAlert("Start Date and End Date are required for Residential Status.", true);
                return;
            }

            UpdateStatus("ResidentialStatus", ddlNewResidentialStatus.SelectedValue, txtResidentialStatusStartDate.Text, txtResidentialStatusEndDate.Text, txtResidentialStatusReason.Text);
            pnlResidentialStatusModal.Visible = false;
        }

        protected void btnSaveMembershipStatus_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtMembershipStatusStartDate.Text) || string.IsNullOrEmpty(txtMembershipStatusEndDate.Text))
            {
                ShowAlert("Start Date and End Date are required for Membership Status.", true);
                return;
            }

            UpdateStatus("Status", ddlNewMembershipStatus.SelectedValue, txtMembershipStatusStartDate.Text, txtMembershipStatusEndDate.Text, txtMembershipStatusReason.Text);
            pnlMembershipStatusModal.Visible = false;
        }

        private void UpdateStatus(string fieldName, string newValue, string startDateStr, string endDateStr, string reason)
        {
            if (string.IsNullOrEmpty(newValue))
            {
                ShowAlert("Please select a new status.", true);
                return;
            }

            int memberProfileId = Convert.ToInt32(hdnMemberProfileID.Value);
            DateTime startDate = DateTime.Parse(startDateStr);
            DateTime endDate = DateTime.Parse(endDateStr);

            string userId = Session["UserId"] != null ? Session["UserId"].ToString() : "0";
            string userName = Session["UserName"] != null ? Session["UserName"].ToString() : "System";

            try
            {
                using (SqlConnection con = new SqlConnection(Con))
                {
                    con.Open();
                    SqlTransaction transaction = con.BeginTransaction();

                    try
                    {
                        // Update using existing procedure or specific update based on field
                        // Since usp_UpdateMemberStatus updates both Status and AccountStatus, we might need to use it or inline SQL.
                        // Let's use the stored procedure if it fits, or inline SQL to be precise as requested.
                        
                        string sql = "";
                        if (fieldName == "AccountStatus")
                        {
                            sql = "UPDATE MemberProfile SET AccountStatus = @Value, StatusStartDate = @StartDate, StatusEndDate = @EndDate WHERE MemberID = @MemberID";
                        }
                        else if (fieldName == "ResidentialStatus")
                        {
                            sql = "UPDATE MemberProfile SET ResidentialStatus = @Value, StatusStartDate = @StartDate, StatusEndDate = @EndDate WHERE MemberID = @MemberID";
                        }
                        else if (fieldName == "Status")
                        {
                            sql = "UPDATE MemberProfile SET Status = @Value, StatusStartDate = @StartDate, StatusEndDate = @EndDate WHERE MemberID = @MemberID";
                        }

                        using (SqlCommand cmd = new SqlCommand(sql, con, transaction))
                        {
                            cmd.Parameters.Add("@Value", SqlDbType.NVarChar, 100).Value = newValue;
                            cmd.Parameters.Add("@StartDate", SqlDbType.DateTime).Value = startDate;
                            cmd.Parameters.Add("@EndDate", SqlDbType.DateTime).Value = endDate;
                            cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberProfileId;
                            cmd.ExecuteNonQuery();
                        }

                        // Log the change
                        using (SqlCommand cmd = new SqlCommand("usp_InsertMemberProfileChangeLog", con, transaction))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@MemberProfileID", SqlDbType.Int).Value = memberProfileId;
                            cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = lblDashMemberNo.Text;
                            cmd.Parameters.Add("@ChangeType", SqlDbType.NVarChar, 50).Value = fieldName.ToUpper() + "_CHANGE";
                            cmd.Parameters.Add("@FieldName", SqlDbType.NVarChar, 100).Value = fieldName;
                            cmd.Parameters.Add("@OldValue", SqlDbType.NVarChar, 100).Value = fieldName == "AccountStatus" ? lblCurrentAccountStatus.Text : (fieldName == "ResidentialStatus" ? lblCurrentResidentialStatus.Text : lblCurrentMembershipStatus.Text);
                            cmd.Parameters.Add("@NewValue", SqlDbType.NVarChar, 100).Value = newValue;
                            cmd.Parameters.Add("@Reason", SqlDbType.NVarChar, -1).Value = reason;
                            cmd.Parameters.Add("@RequestNo", SqlDbType.NVarChar, 50).Value = "0"; // Default
                            cmd.Parameters.Add("@RequestDate", SqlDbType.DateTime).Value = DateTime.Now;
                            cmd.Parameters.Add("@ModifiedBy", SqlDbType.NVarChar, 100).Value = userName;
                            cmd.Parameters.Add("@ModifiedByUserId", SqlDbType.Int).Value = Convert.ToInt32(userId);
                            cmd.Parameters.Add("@IsMember", SqlDbType.Bit).Value = true;
                            cmd.ExecuteNonQuery();
                        }

                        transaction.Commit();
                        ShowAlert(fieldName + " updated successfully!", false);
                        
                        // Refresh display
                        LoadMemberDashboard(lblDashMemberNo.Text);
                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        ShowAlert("Transaction failed: " + ex.Message, true);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Save failed: " + ex.Message, true);
            }
        }

        private bool HasColumn(SqlDataReader dr, string columnName)
        {
            for (int i = 0; i < dr.FieldCount; i++)
            {
                if (dr.GetName(i).Equals(columnName, StringComparison.InvariantCultureIgnoreCase))
                    return true;
            }
            return false;
        }
    }
}
