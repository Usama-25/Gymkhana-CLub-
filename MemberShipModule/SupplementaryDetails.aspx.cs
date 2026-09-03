using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Membership
{
    public partial class SupplementaryDetails : System.Web.UI.Page
    {
        string connectionString = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!string.IsNullOrEmpty(Request.QueryString["MemberNo"]))
                {
                    string memNo = Request.QueryString["MemberNo"];
                    txtSearchMemberNo.Text = memNo;

                    // Try to auto-load if unique match
                    using (SqlConnection con = new SqlConnection(connectionString))
                    using (SqlCommand cmd = new SqlCommand("SELECT MemberID FROM MemberProfile WHERE MemberNo = @No", con))
                    {
                        cmd.Parameters.AddWithValue("@No", memNo);
                        con.Open();
                        object result = cmd.ExecuteScalar();
                        if (result != null)
                        {
                            hdnSelectedMemberID.Value = result.ToString();
                            LoadDashboard(Convert.ToInt32(result));
                        }
                        else
                        {
                            BindMembers();
                        }
                    }
                }
            }
            else
            {
                if (!string.IsNullOrEmpty(hdnSelectedMemberID.Value))
                {
                    pnlMemberSearch.Visible = false;
                    pnlDashboard.Visible = true;
                }
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
            if (e.CommandName == "ManageSupplementary")
            {
                int memberId = Convert.ToInt32(e.CommandArgument);
                hdnSelectedMemberID.Value = memberId.ToString();
                LoadDashboard(memberId);
            }
        }

        // --- DASHBOARD LOGIC ---

        private void LoadDashboard(int memberId)
        {
            HideAlert();

            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("SELECT MemberNo, MemberName FROM MemberProfile WHERE MemberID = @ID", con))
            {
                cmd.Parameters.AddWithValue("@ID", memberId);
                con.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        string memNo = dr["MemberNo"].ToString();
                        hdnSelectedMemberNo.Value = memNo;
                        lblDashMemberNo.Text = memNo;
                        lblDashMemberName.Text = dr["MemberName"].ToString();
                    }
                }
            }

            pnlMemberSearch.Visible = false;
            pnlDashboard.Visible = true;
            BindSupplementary(memberId);
        }

        protected void btnBackToSearch_Click(object sender, EventArgs e)
        {
            pnlDashboard.Visible = false;
            pnlMemberSearch.Visible = true;
            HideAlert();
        }

        private void BindSupplementary(int memberId)
        {
            string sql = @"
                SELECT MemberID, MembershipNo, SupplementaryName, Relationship, ValidityPeriod,
                       ISNULL(RecordStatus, 'Active') as RecordStatus, Remarks
                FROM SupplementaryMembers 
                WHERE MemberID = @MemberID
                ORDER BY MemberID DESC";

            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@MemberID", memberId);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvSupplementary.DataSource = dt;
                    gvSupplementary.DataBind();
                }
            }
        }

        // --- CRUD LOGIC ---

        protected void btnOpenAddModal_Click(object sender, EventArgs e)
        {
            hdnEditID.Value = "";
            lblModalTitle.Text = "Register Supplementary";
            lblPreviewNo.Text = "Will be auto-generated";

            txtName.Text = "";
            txtRelationship.Text = "";
            txtValidity.Text = "";
            pnlAddModal.Visible = true;
        }

        protected void btnCancelAdd_Click(object sender, EventArgs e)
        {
            pnlAddModal.Visible = false;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hdnSelectedMemberID.Value)) return;
            if (string.IsNullOrEmpty(txtName.Text))
            {
                ShowAlert("Supplementary Name is required.", true);
                return;
            }

            int memberId = Convert.ToInt32(hdnSelectedMemberID.Value);

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                if (string.IsNullOrEmpty(hdnEditID.Value))
                {
                    // INSERT
                    string memberNo = hdnSelectedMemberNo.Value;
                    string allocatedNo = GetNextSupplementaryNo(memberId, memberNo);

                    string sql = @"
                        INSERT INTO SupplementaryMembers (MemberID, SupplementaryName, Relationship, ValidityPeriod, MembershipNo, RecordStatus, Remarks, CreatedDate) 
                        VALUES (@MemberID, @Name, @Rel, @Val, @MemNo, 'Active', 'New registration', GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@MemberID", memberId);
                        cmd.Parameters.AddWithValue("@Name", txtName.Text.Trim());
                        cmd.Parameters.AddWithValue("@Rel", txtRelationship.Text.Trim());
                        cmd.Parameters.AddWithValue("@Val", string.IsNullOrEmpty(txtValidity.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtValidity.Text));
                        cmd.Parameters.AddWithValue("@MemNo", allocatedNo);
                        cmd.ExecuteNonQuery();
                    }
                    ShowAlert("Card successfully registered. No: " + allocatedNo, false);
                }
                else
                {
                    // UPDATE
                    string sql = @"
                        UPDATE SupplementaryMembers 
                        SET SupplementaryName = @Name, Relationship = @Rel, ValidityPeriod = @Val 
                        WHERE MemberID = @ID";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@ID", Convert.ToInt32(hdnEditID.Value));
                        cmd.Parameters.AddWithValue("@Name", txtName.Text.Trim());
                        cmd.Parameters.AddWithValue("@Rel", txtRelationship.Text.Trim());
                        cmd.Parameters.AddWithValue("@Val", string.IsNullOrEmpty(txtValidity.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtValidity.Text));
                        cmd.ExecuteNonQuery();
                    }
                    ShowAlert("Card successfully updated.", false);
                }
            }

            pnlAddModal.Visible = false;
            BindSupplementary(memberId);
        }

        private string GetNextSupplementaryNo(int memberId, string memberNo)
        {
            int maxSuffix = 0;
            string prefix = memberNo + "-SUP";
            string sql = "SELECT MembershipNo FROM SupplementaryMembers WHERE MemberID = @MemberID AND MembershipNo LIKE @Prefix + '%'";

            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@MemberID", memberId);
                cmd.Parameters.AddWithValue("@Prefix", prefix);
                con.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string memNo = dr["MembershipNo"].ToString();
                        string suffixStr = memNo.Replace(prefix, "");
                        int suffixVal;
                        if (int.TryParse(suffixStr, out suffixVal))
                        {
                            if (suffixVal > maxSuffix) maxSuffix = suffixVal;
                        }
                    }
                }
            }
            return prefix + (maxSuffix + 1).ToString();
        }

        protected void gvSupplementary_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditDetails" || e.CommandName == "EditStatus")
            {
                try
                {
                    int rowIndex = -1;

                    // Try to get row index from CommandArgument (default for buttons) or Source
                    if (!int.TryParse(e.CommandArgument.ToString(), out rowIndex))
                    {
                        LinkButton btn = (LinkButton)e.CommandSource;
                        GridViewRow row = (GridViewRow)btn.NamingContainer;
                        rowIndex = row.RowIndex;
                    }

                    if (rowIndex < 0 || rowIndex >= gvSupplementary.Rows.Count) return;

                    object keyVal = gvSupplementary.DataKeys[rowIndex].Value;
                    if (keyVal == null || keyVal == DBNull.Value)
                    {
                        ShowAlert("Error: DataKey 'MemberID' is null for this row. Please ensure the GridView is properly bound.", true);
                        return;
                    }
                    int id = Convert.ToInt32(keyVal);

                    if (e.CommandName == "EditDetails")
                    {
                        hdnEditID.Value = id.ToString();
                        lblModalTitle.Text = "Update Supplementary";

                        using (SqlConnection con = new SqlConnection(connectionString))
                        using (SqlCommand cmd = new SqlCommand("SELECT * FROM SupplementaryMembers WHERE MemberID = @ID", con))
                        {
                            cmd.Parameters.AddWithValue("@ID", id);
                            con.Open();
                            using (SqlDataReader dr = cmd.ExecuteReader())
                            {
                                if (dr.Read())
                                {
                                    lblPreviewNo.Text = dr["MembershipNo"].ToString();
                                    txtName.Text = dr["SupplementaryName"].ToString();
                                    txtRelationship.Text = dr["Relationship"].ToString();
                                    if (dr["ValidityPeriod"] != DBNull.Value)
                                        txtValidity.Text = Convert.ToDateTime(dr["ValidityPeriod"]).ToString("yyyy-MM-dd");
                                    else
                                        txtValidity.Text = "";
                                }
                            }
                        }
                        statusModal.Visible = false;
                        pnlAddModal.Visible = true;
                    }
                    else if (e.CommandName == "EditStatus")
                    {
                        hdnStatusID.Value = id.ToString();
                        using (SqlConnection con = new SqlConnection(connectionString))
                        using (SqlCommand cmd = new SqlCommand("SELECT RecordStatus, Remarks FROM SupplementaryMembers WHERE MemberID = @ID", con))
                        {
                            cmd.Parameters.AddWithValue("@ID", id);
                            con.Open();
                            using (SqlDataReader dr = cmd.ExecuteReader())
                            {
                                if (dr.Read())
                                {
                                    string status = dr["RecordStatus"].ToString();
                                    if (string.IsNullOrEmpty(status)) status = "Active";

                                    try { ddlStatus.SelectedValue = status; }
                                    catch { ddlStatus.SelectedIndex = 0; }

                                    txtRemarks.Text = dr["Remarks"].ToString();
                                }
                            }
                        }
                        pnlAddModal.Visible = false;
                        statusModal.Visible = true;
                    }
                }
                catch (Exception ex)
                {
                    ShowAlert("Error opening modal: " + ex.Message, true);
                }
            }
        }

        protected void btnCancelStatus_Click(object sender, EventArgs e)
        {
            statusModal.Visible = false;
        }

        protected void btnSaveStatus_Click(object sender, EventArgs e)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string sql = "UPDATE SupplementaryMembers SET RecordStatus = @Status, Remarks = @Remarks WHERE MemberID = @ID";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@ID", Convert.ToInt32(hdnStatusID.Value));
                    cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);
                    cmd.Parameters.AddWithValue("@Remarks", txtRemarks.Text.Trim());
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
                statusModal.Visible = false;
                ShowAlert("Status updated successfully.", false);

                if (!string.IsNullOrEmpty(hdnSelectedMemberID.Value))
                {
                    BindSupplementary(Convert.ToInt32(hdnSelectedMemberID.Value));
                }
            }
        }
    }
}