using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace Membership
{
    public partial class ClubDetails : System.Web.UI.Page
    {
        string connectionString = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;

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
            string sql = "SELECT TOP 100 MemberID, MemberNo, MemberName, NIC, Mobile FROM MemberProfile WHERE 1=1 ";

            if (!string.IsNullOrEmpty(txtSearchMemberNo.Text)) sql += " AND MemberNo LIKE '%' + @MemberNo + '%' ";
            if (!string.IsNullOrEmpty(txtSearchName.Text)) sql += " AND MemberName LIKE '%' + @Name + '%' ";
            if (!string.IsNullOrEmpty(txtSearchNIC.Text)) sql += " AND NIC LIKE '%' + @NIC + '%' ";
            if (!string.IsNullOrEmpty(txtSearchMobile.Text)) sql += " AND Mobile LIKE '%' + @Mobile + '%' ";

            sql += " ORDER BY MemberID DESC";

            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                if (!string.IsNullOrEmpty(txtSearchMemberNo.Text)) cmd.Parameters.AddWithValue("@MemberNo", txtSearchMemberNo.Text.Trim());
                if (!string.IsNullOrEmpty(txtSearchName.Text)) cmd.Parameters.AddWithValue("@Name", txtSearchName.Text.Trim());
                if (!string.IsNullOrEmpty(txtSearchNIC.Text)) cmd.Parameters.AddWithValue("@NIC", txtSearchNIC.Text.Trim());
                if (!string.IsNullOrEmpty(txtSearchMobile.Text)) cmd.Parameters.AddWithValue("@Mobile", txtSearchMobile.Text.Trim());

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
            if (e.CommandName == "ManageClubs")
            {
                int memberId = Convert.ToInt32(e.CommandArgument);
                hdnSelectedMemberID.Value = memberId.ToString();

                LoadClubDashboard(memberId);
            }
        }

        // --- DASHBOARD LOGIC ---

        private void LoadClubDashboard(int memberId)
        {
            HideAlert();
            
            // Fetch Member Info
            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("SELECT MemberNo, MemberName FROM MemberProfile WHERE MemberID = @ID", con))
            {
                cmd.Parameters.AddWithValue("@ID", memberId);
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
            pnlClubDashboard.Visible = true;

            BindMemberClubs(memberId);
        }

        private void BindMemberClubs(int memberId)
        {
            string sql = @"
                SELECT ClubID, ClubName, MembershipNo, 
                       ISNULL(RecordStatus, 'Active') as RecordStatus, Remarks
                FROM MemberOtherClubs 
                WHERE MemberID = @MemberID
                ORDER BY ClubID DESC";

            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@MemberID", memberId);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvClubs.DataSource = dt;
                    gvClubs.DataBind();
                }
            }
        }

        protected void btnBackToSearch_Click(object sender, EventArgs e)
        {
            pnlClubDashboard.Visible = false;
            pnlMemberSearch.Visible = true;
            hdnSelectedMemberID.Value = "";
            HideAlert();
        }

        // --- ADD CLUB MODAL LOGIC ---

        protected void btnOpenAddModal_Click(object sender, EventArgs e)
        {
            lblModalMemberNo.Text = lblDashMemberNo.Text;
            txtAddClubName.Text = "";
            txtAddMembershipNo.Text = "";
            pnlAddClubModal.Visible = true;
        }

        protected void btnCancelAdd_Click(object sender, EventArgs e)
        {
            pnlAddClubModal.Visible = false;
        }

        protected void btnSaveNewClub_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hdnSelectedMemberID.Value))
            {
                ShowAlert("Member session lost. Please search again.", true);
                pnlAddClubModal.Visible = false;
                return;
            }

            if (string.IsNullOrEmpty(txtAddClubName.Text) || string.IsNullOrEmpty(txtAddMembershipNo.Text))
            {
                ShowAlert("Club Name and Membership No are required.", true);
                return;
            }

            int memberId = Convert.ToInt32(hdnSelectedMemberID.Value);

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                string sqlInsert = @"
                    INSERT INTO MemberOtherClubs (MemberID, ClubName, MembershipNo, RecordStatus, Remarks, CreatedDate) 
                    VALUES (@MemberID, @ClubName, @MembershipNo, 'Active', 'New Club Added', GETDATE())";
                
                using (SqlCommand cmdIns = new SqlCommand(sqlInsert, con))
                {
                    cmdIns.Parameters.AddWithValue("@MemberID", memberId);
                    cmdIns.Parameters.AddWithValue("@ClubName", txtAddClubName.Text.Trim());
                    cmdIns.Parameters.AddWithValue("@MembershipNo", txtAddMembershipNo.Text.Trim());
                    cmdIns.ExecuteNonQuery();
                }
            }

            ShowAlert("Club successfully registered for " + lblDashMemberName.Text, false);
            pnlAddClubModal.Visible = false;
            BindMemberClubs(memberId);
        }

        // --- UPDATE STATUS LOGIC ---

        protected void gvClubs_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditStatus")
            {
                int clubId = Convert.ToInt32(e.CommandArgument);
                hdnEditClubID.Value = clubId.ToString();
                
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();
                    using (SqlCommand cmd = new SqlCommand("SELECT RecordStatus, Remarks FROM MemberOtherClubs WHERE ClubID = @ID", con))
                    {
                        cmd.Parameters.AddWithValue("@ID", clubId);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                string status = dr["RecordStatus"].ToString();
                                if (string.IsNullOrEmpty(status)) status = "Active";
                                ddlEditStatus.SelectedValue = status;
                                txtEditRemarks.Text = dr["Remarks"].ToString();
                            }
                        }
                    }
                }
                
                statusModal.Visible = true;
            }
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            statusModal.Visible = false;
        }

        protected void btnSaveStatus_Click(object sender, EventArgs e)
        {
            int clubId = Convert.ToInt32(hdnEditClubID.Value);
            string newStatus = ddlEditStatus.SelectedValue;
            string remarks = txtEditRemarks.Text.Trim();

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                string sqlUpdate = "UPDATE MemberOtherClubs SET RecordStatus = @Status, Remarks = @Remarks WHERE ClubID = @ID";
                using (SqlCommand cmd = new SqlCommand(sqlUpdate, con))
                {
                    cmd.Parameters.AddWithValue("@ID", clubId);
                    cmd.Parameters.AddWithValue("@Status", newStatus);
                    cmd.Parameters.AddWithValue("@Remarks", remarks);
                    cmd.ExecuteNonQuery();
                }
            }

            statusModal.Visible = false;
            ShowAlert("Club status updated successfully.", false);
            
            if (!string.IsNullOrEmpty(hdnSelectedMemberID.Value))
            {
                BindMemberClubs(Convert.ToInt32(hdnSelectedMemberID.Value));
            }
        }
        protected void gvMembers_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvMembers.PageIndex = e.NewPageIndex;
            BindMembers();
        }
    }
}
