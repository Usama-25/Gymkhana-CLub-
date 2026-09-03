using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace Membership
{
    public partial class DependentsDetails : System.Web.UI.Page
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
            using (SqlCommand cmd = new SqlCommand("usp_SearchMembersForDependents", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                
                cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = string.IsNullOrEmpty(txtSearchMemberNo.Text) ? (object)DBNull.Value : txtSearchMemberNo.Text.Trim();
                cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = string.IsNullOrEmpty(txtSearchName.Text) ? (object)DBNull.Value : txtSearchName.Text.Trim();
                cmd.Parameters.Add("@NIC", SqlDbType.NVarChar, 50).Value = string.IsNullOrEmpty(txtSearchNIC.Text) ? (object)DBNull.Value : txtSearchNIC.Text.Trim();
                cmd.Parameters.Add("@Mobile", SqlDbType.NVarChar, 50).Value = string.IsNullOrEmpty(txtSearchMobile.Text) ? (object)DBNull.Value : txtSearchMobile.Text.Trim();

                int pageSize = gvMembers.PageSize > 0 ? gvMembers.PageSize : 10;
                int pageIndex = gvMembers.PageIndex;
                int offset = pageIndex * pageSize;

                cmd.Parameters.Add("@Offset", SqlDbType.Int).Value = offset;
                cmd.Parameters.Add("@PageSize", SqlDbType.Int).Value = pageSize;

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    
                    int totalCount = 0;
                    if (dt.Rows.Count > 0)
                    {
                        totalCount = Convert.ToInt32(dt.Rows[0]["TotalCount"]);
                    }
                    gvMembers.VirtualItemCount = totalCount;
                    
                    gvMembers.DataSource = dt;
                    gvMembers.DataBind();
                }
            }
        }

        protected void gvMembers_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvMembers.PageIndex = e.NewPageIndex;
            BindMembers();
        }

        protected void gvMembers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ManageDependents")
            {
                int memberId = Convert.ToInt32(e.CommandArgument);
                hdnSelectedMemberID.Value = memberId.ToString();

                LoadDependentsDashboard(memberId);
            }
        }

        // --- DASHBOARD LOGIC ---

        private void LoadDependentsDashboard(int memberId)
        {
            HideAlert();

            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("usp_GetMemberInfoForDependents", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@ID", SqlDbType.Int).Value = memberId;
                con.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        hdnSelectedMemberNo.Value = dr["MemberNo"].ToString();
                        lblDashMemberNoS.Text = dr["MemberNo"].ToString();
                        lblDashMemberNameS.Text = dr["MemberName"].ToString();
                    }
                }
            }

            pnlMemberSearch.Visible = false;
            pnlDependentsDashboard.Visible = true;

            BindSpouses(memberId);
            BindChildren(memberId);
        }

        private void BindSpouses(int memberId)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("usp_GetMemberSpouses", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvSpouses.DataSource = dt;
                    gvSpouses.DataBind();
                }
            }
        }

        private void BindChildren(int memberId)
        {
            DataTable dt = new DataTable();
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("usp_GetMemberChildren_Dependents", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }

                // If no children found in MemberChildren, try ApplicationChildren
                if (dt.Rows.Count == 0)
                {
                    string nic = "";
                    using (SqlCommand cmdNIC = new SqlCommand("SELECT NIC FROM MemberProfile WHERE MemberID = @MemberID", con))
                    {
                        cmdNIC.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                        if (con.State == ConnectionState.Closed) con.Open();
                        object result = cmdNIC.ExecuteScalar();
                        nic = result != null ? result.ToString() : "";
                    }

                    if (!string.IsNullOrEmpty(nic))
                    {
                        int trackId = 0;
                        using (SqlCommand cmdTrack = new SqlCommand("SELECT TrackID FROM ApplicationFForm WHERE REPLACE(NIC, '-', '') = REPLACE(@NIC, '-', '')", con))
                        {
                            cmdTrack.Parameters.Add("@NIC", SqlDbType.NVarChar, 50).Value = nic;
                            object result = cmdTrack.ExecuteScalar();
                            trackId = result != null ? Convert.ToInt32(result) : 0;
                        }

                        if (trackId > 0)
                        {
                            DataTable dtAppChildren = new DataTable();
                            using (SqlCommand cmdApp = new SqlCommand("SELECT * FROM ApplicationChildren WHERE TrackID = @TrackID", con))
                            {
                                cmdApp.Parameters.Add("@TrackID", SqlDbType.Int).Value = trackId;
                                using (SqlDataAdapter daApp = new SqlDataAdapter(cmdApp))
                                {
                                    daApp.Fill(dtAppChildren);
                                }
                            }

                            if (dtAppChildren.Rows.Count > 0)
                            {
                                string memberNo = hdnSelectedMemberNo.Value;
                                foreach (DataRow row in dtAppChildren.Rows)
                                {
                                    string childName = row["ChildName"].ToString();
                                    string rel = row["Relationship"] != null ? row["Relationship"].ToString().Trim() : "";
                                    string cnic = row["CNICNo"] != null ? row["CNICNo"].ToString() : "";
                                    DateTime? dob = row["DOB"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(row["DOB"]) : null;

                                    // Normalize relationship
                                    if (rel.Equals("son", StringComparison.OrdinalIgnoreCase)) rel = "Son";
                                    else if (rel.Equals("daughter", StringComparison.OrdinalIgnoreCase)) rel = "Daughter";

                                    string allocatedNo = GetNextChildMembershipNo(memberId, memberNo, rel);

                                    using (SqlCommand cmdInsert = new SqlCommand("usp_InsertMemberChild", con))
                                      {
                                        cmdInsert.CommandType = CommandType.StoredProcedure;
                                        cmdInsert.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                                        cmdInsert.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = childName;
                                        cmdInsert.Parameters.Add("@Rel", SqlDbType.NVarChar, 50).Value = rel;
                                        cmdInsert.Parameters.Add("@CNIC", SqlDbType.NVarChar, 50).Value = cnic;
                                        cmdInsert.Parameters.Add("@DOB", SqlDbType.DateTime).Value = (object)dob ?? DBNull.Value;
                                        cmdInsert.Parameters.Add("@MemNo", SqlDbType.NVarChar, 50).Value = allocatedNo;
                                        cmdInsert.ExecuteNonQuery();
                                    }
                                }

                                // Reload from MemberChildren
                                using (SqlCommand cmdReload = new SqlCommand("usp_GetMemberChildren_Dependents", con))
                                {
                                    cmdReload.CommandType = CommandType.StoredProcedure;
                                    cmdReload.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                                    using (SqlDataAdapter da = new SqlDataAdapter(cmdReload))
                                    {
                                        dt.Clear();
                                        da.Fill(dt);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            gvChildren.DataSource = dt;
            gvChildren.DataBind();
        }

        protected void btnBackToSearch_Click(object sender, EventArgs e)
        {
            pnlDependentsDashboard.Visible = false;
            pnlMemberSearch.Visible = true;
            hdnSelectedMemberID.Value = "";
            hdnSelectedMemberNo.Value = "";
            HideAlert();
        }

        // --- AUTO-NUMBERING LOGIC ---

        private string GetNextSpouseMembershipNo(int memberId, string memberNo)
        {
            int maxSuffix = 0;
            string prefix = memberNo + "-W";

            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("usp_GetSpouseMembershipNos", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                cmd.Parameters.Add("@Prefix", SqlDbType.NVarChar, 50).Value = prefix;
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

        private string GetNextChildMembershipNo(int memberId, string memberNo, string relationship)
        {
            int maxSuffix = 0;
            string relationCode = relationship.Equals("Son", StringComparison.OrdinalIgnoreCase) ? "-S" : "-D";
            string prefix = memberNo + relationCode;

            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("usp_GetChildMembershipNos", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                cmd.Parameters.Add("@Prefix", SqlDbType.NVarChar, 50).Value = prefix;
                cmd.Parameters.Add("@Relationship", SqlDbType.NVarChar, 50).Value = relationship;
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

        // --- ADD SPOUSE LOGIC ---

        protected void btnOpenAddSpouseModal_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hdnSelectedMemberID.Value)) return;

            hdnEditSpouseID.Value = "";
            lblSpouseModalTitle.Text = "Register Spouse";

            int memberId = Convert.ToInt32(hdnSelectedMemberID.Value);
            string memberNo = hdnSelectedMemberNo.Value;

            lblSpousePreviewNo.Text = GetNextSpouseMembershipNo(memberId, memberNo);

            txtAddSpouseName.Text = "";
            txtAddSpouseCNIC.Text = "";
            txtAddSpousePhone.Text = "";
            txtAddSpouseProfession.Text = "";

            bool hasSpouses = false;
            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("usp_GetSpouseCountAndProfileInfo", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                con.Open();
                
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    // First result set: Count
                    if (dr.Read())
                    {
                        hasSpouses = Convert.ToInt32(dr["SpouseCount"]) > 0;
                    }
                    
                    // Second result set: Profile Info
                    if (dr.NextResult() && !hasSpouses)
                    {
                        if (dr.Read())
                        {
                            txtAddSpouseName.Text = dr["SpouseName"] != DBNull.Value ? dr["SpouseName"].ToString() : "";
                            txtAddSpouseCNIC.Text = dr["SpouseCNIC"] != DBNull.Value ? dr["SpouseCNIC"].ToString() : "";
                            txtAddSpousePhone.Text = dr["SpousePhone"] != DBNull.Value ? dr["SpousePhone"].ToString() : "";
                        }
                    }
                }
            }

            pnlAddSpouseModal.Visible = true;
        }

        protected void btnCancelSpouseAdd_Click(object sender, EventArgs e)
        {
            pnlAddSpouseModal.Visible = false;
        }

        protected void btnSaveNewSpouse_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hdnSelectedMemberID.Value)) return;

            if (string.IsNullOrEmpty(txtAddSpouseName.Text))
            {
                ShowAlert("Spouse Name is required.", true);
                return;
            }

            int memberId = Convert.ToInt32(hdnSelectedMemberID.Value);

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                if (string.IsNullOrEmpty(hdnEditSpouseID.Value))
                {
                    string memberNo = hdnSelectedMemberNo.Value;
                    string allocatedNo = GetNextSpouseMembershipNo(memberId, memberNo);

                    using (SqlCommand cmd = new SqlCommand("usp_InsertMemberSpouse", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                        cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = txtAddSpouseName.Text.Trim();
                        cmd.Parameters.Add("@CNIC", SqlDbType.NVarChar, 50).Value = txtAddSpouseCNIC.Text.Trim();
                        cmd.Parameters.Add("@Phone", SqlDbType.NVarChar, 50).Value = txtAddSpousePhone.Text.Trim();
                        cmd.Parameters.Add("@Prof", SqlDbType.NVarChar, 100).Value = txtAddSpouseProfession.Text.Trim();
                        cmd.Parameters.Add("@MemNo", SqlDbType.NVarChar, 50).Value = allocatedNo;
                        cmd.ExecuteNonQuery();
                    }
                    ShowAlert("Spouse successfully registered. Membership No: " + allocatedNo, false);
                }
                else
                {
                    string memNo = lblSpousePreviewNo.Text;
                    if (memNo == "Will be auto-generated on save" || string.IsNullOrEmpty(memNo))
                    {
                        memNo = GetNextSpouseMembershipNo(memberId, hdnSelectedMemberNo.Value);
                    }

                    using (SqlCommand cmd = new SqlCommand("usp_UpdateMemberSpouse", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@SpouseID", SqlDbType.Int).Value = Convert.ToInt32(hdnEditSpouseID.Value);
                        cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = txtAddSpouseName.Text.Trim();
                        cmd.Parameters.Add("@CNIC", SqlDbType.NVarChar, 50).Value = txtAddSpouseCNIC.Text.Trim();
                        cmd.Parameters.Add("@Phone", SqlDbType.NVarChar, 50).Value = txtAddSpousePhone.Text.Trim();
                        cmd.Parameters.Add("@Prof", SqlDbType.NVarChar, 100).Value = txtAddSpouseProfession.Text.Trim();
                        cmd.Parameters.Add("@MemNo", SqlDbType.NVarChar, 50).Value = memNo;
                        cmd.ExecuteNonQuery();
                    }
                    ShowAlert("Spouse successfully updated.", false);
                }
            }

            pnlAddSpouseModal.Visible = false;
            BindSpouses(memberId);
        }

        // --- ADD CHILD LOGIC ---

        protected void btnOpenAddChildModal_Click(object sender, EventArgs e)
        {
            hdnEditChildID.Value = "";
            lblChildModalTitle.Text = "Register Child";
            lblChildPreviewNo.Text = "";

            txtAddChildName.Text = "";
            txtAddChildCNIC.Text = "";
            txtAddChildDOB.Text = "";
            ddlAddChildRelation.SelectedIndex = 0;
            pnlAddChildModal.Visible = true;
        }

        protected void btnCancelChildAdd_Click(object sender, EventArgs e)
        {
            pnlAddChildModal.Visible = false;
        }

        protected void btnSaveNewChild_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hdnSelectedMemberID.Value)) return;

            if (string.IsNullOrEmpty(txtAddChildName.Text))
            {
                ShowAlert("Child Name is required.", true);
                return;
            }

            int memberId = Convert.ToInt32(hdnSelectedMemberID.Value);

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                if (string.IsNullOrEmpty(hdnEditChildID.Value))
                {
                    string memberNo = hdnSelectedMemberNo.Value;
                    string relationship = ddlAddChildRelation.SelectedValue;
                    string allocatedNo = GetNextChildMembershipNo(memberId, memberNo, relationship);

                    using (SqlCommand cmd = new SqlCommand("usp_InsertMemberChild", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                        cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = txtAddChildName.Text.Trim();
                        cmd.Parameters.Add("@Rel", SqlDbType.NVarChar, 50).Value = relationship;
                        cmd.Parameters.Add("@CNIC", SqlDbType.NVarChar, 50).Value = txtAddChildCNIC.Text.Trim();
                        if (string.IsNullOrEmpty(txtAddChildDOB.Text))
                            cmd.Parameters.Add("@DOB", SqlDbType.DateTime).Value = DBNull.Value;
                        else
                            cmd.Parameters.Add("@DOB", SqlDbType.DateTime).Value = Convert.ToDateTime(txtAddChildDOB.Text);
                        cmd.Parameters.Add("@MemNo", SqlDbType.NVarChar, 50).Value = allocatedNo;
                        cmd.ExecuteNonQuery();
                    }
                    ShowAlert("Child successfully registered. Membership No: " + allocatedNo, false);
                }
                else
                {
                    string memNo = lblChildPreviewNo.Text;
                    if (memNo == "Will be auto-generated on save" || string.IsNullOrEmpty(memNo))
                    {
                        memNo = GetNextChildMembershipNo(memberId, hdnSelectedMemberNo.Value, ddlAddChildRelation.SelectedValue);
                    }

                    using (SqlCommand cmd = new SqlCommand("usp_UpdateMemberChild", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@ChildID", SqlDbType.Int).Value = Convert.ToInt32(hdnEditChildID.Value);
                        cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = txtAddChildName.Text.Trim();
                        cmd.Parameters.Add("@Rel", SqlDbType.NVarChar, 50).Value = ddlAddChildRelation.SelectedValue;
                        cmd.Parameters.Add("@CNIC", SqlDbType.NVarChar, 50).Value = txtAddChildCNIC.Text.Trim();
                        if (string.IsNullOrEmpty(txtAddChildDOB.Text))
                            cmd.Parameters.Add("@DOB", SqlDbType.DateTime).Value = DBNull.Value;
                        else
                            cmd.Parameters.Add("@DOB", SqlDbType.DateTime).Value = Convert.ToDateTime(txtAddChildDOB.Text);
                        cmd.Parameters.Add("@MemNo", SqlDbType.NVarChar, 50).Value = memNo;
                        cmd.ExecuteNonQuery();
                    }
                    ShowAlert("Child successfully updated.", false);
                }
            }

            pnlAddChildModal.Visible = false;
            BindChildren(memberId);
        }

        // --- STATUS UPDATE LOGIC ---

        protected void gvSpouses_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandArgument == null || string.IsNullOrEmpty(e.CommandArgument.ToString())) return;

            int id;
            if (!int.TryParse(e.CommandArgument.ToString(), out id)) return;

            if (e.CommandName == "EditStatus")
            {
                hdnEditType.Value = "Spouse";
                OpenStatusModal(id, "MemberSpouses", "SpouseID");
            }
            else if (e.CommandName == "EditDetails")
            {
                hdnEditSpouseID.Value = id.ToString();
                lblSpouseModalTitle.Text = "Update Spouse";

                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand("usp_GetSpouseByID", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@ID", SqlDbType.Int).Value = id;
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            string existingNo = dr["MembershipNo"].ToString();
                            lblSpousePreviewNo.Text = string.IsNullOrEmpty(existingNo) ? "Will be auto-generated on save" : existingNo;
                            txtAddSpouseName.Text = dr["SpouseName"].ToString();
                            txtAddSpouseCNIC.Text = dr["SpouseCNIC"].ToString();
                            txtAddSpousePhone.Text = dr["SpousePhone"].ToString();
                            txtAddSpouseProfession.Text = dr["SpouseProfession"].ToString();
                        }
                    }
                }

                pnlAddSpouseModal.Visible = true;
            }
        }

        protected void gvChildren_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandArgument == null || string.IsNullOrEmpty(e.CommandArgument.ToString())) return;

            int id;
            if (!int.TryParse(e.CommandArgument.ToString(), out id)) return;

            if (e.CommandName == "EditStatus")
            {
                hdnEditType.Value = "Child";
                OpenStatusModal(id, "MemberChildren", "ChildID");
            }
            else if (e.CommandName == "EditDetails")
            {
                hdnEditChildID.Value = id.ToString();
                lblChildModalTitle.Text = "Update Child";

                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand("usp_GetChildByID", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@ID", SqlDbType.Int).Value = id;
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            string existingNo = dr["MembershipNo"].ToString();
                            lblChildPreviewNo.Text = string.IsNullOrEmpty(existingNo) ? "Will be auto-generated on save" : existingNo;
                            txtAddChildName.Text = dr["ChildName"].ToString();
                            txtAddChildCNIC.Text = dr["CNIC"].ToString();

                            string rel = dr["Relationship"].ToString();
                            try { ddlAddChildRelation.SelectedValue = rel; }
                            catch { }

                            if (dr["DOB"] != DBNull.Value)
                            {
                                txtAddChildDOB.Text = Convert.ToDateTime(dr["DOB"]).ToString("yyyy-MM-dd");
                            }
                            else
                            {
                                txtAddChildDOB.Text = "";
                            }
                        }
                    }
                }

                pnlAddChildModal.Visible = true;
            }
        }

        private void OpenStatusModal(int id, string tableName, string idCol)
        {
            hdnEditID.Value = id.ToString();

            string query = tableName == "MemberSpouses" ? 
                "SELECT ISNULL(RecordStatus, 'Active') AS RecordStatus, Remarks FROM MemberSpouses WHERE SpouseID = @ID" : 
                "SELECT ISNULL(RecordStatus, 'Active') AS RecordStatus, Remarks FROM MemberChildren WHERE ChildID = @ID";

            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.CommandType = CommandType.Text;
                cmd.Parameters.Add("@ID", SqlDbType.Int).Value = id;
                
                con.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        string status = dr["RecordStatus"].ToString();
                        if (string.IsNullOrEmpty(status)) status = "Active";

                        try { ddlEditStatus.SelectedValue = status; }
                        catch { }
                        txtEditRemarks.Text = dr["Remarks"].ToString();
                    }
                }
            }

            statusModal.Visible = true;
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            statusModal.Visible = false;
        }

        protected void btnSaveStatus_Click(object sender, EventArgs e)
        {
            int id = Convert.ToInt32(hdnEditID.Value);
            string type = hdnEditType.Value;
            string newStatus = ddlEditStatus.SelectedValue;
            string remarks = txtEditRemarks.Text.Trim();

            string query = type == "Spouse" ? 
                "UPDATE MemberSpouses SET RecordStatus = @Status, Remarks = @Remarks WHERE SpouseID = @ID" : 
                "UPDATE MemberChildren SET RecordStatus = @Status, Remarks = @Remarks WHERE ChildID = @ID";

            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.CommandType = CommandType.Text;
                cmd.Parameters.Add("@ID", SqlDbType.Int).Value = id;
                cmd.Parameters.Add("@Status", SqlDbType.NVarChar, 50).Value = newStatus;
                cmd.Parameters.Add("@Remarks", SqlDbType.NVarChar, 500).Value = remarks;
                
                con.Open();
                cmd.ExecuteNonQuery();
            }

            statusModal.Visible = false;
            ShowAlert(type + " status updated successfully.", false);

            if (!string.IsNullOrEmpty(hdnSelectedMemberID.Value))
            {
                int memberId = Convert.ToInt32(hdnSelectedMemberID.Value);
                if (type == "Spouse") BindSpouses(memberId);
                else BindChildren(memberId);
            }
        }

        public string GetStatusClass(object statusObj)
        {
            if (statusObj == null || statusObj == DBNull.Value)
                return "status-badge status-active";

            string status = statusObj.ToString().Trim();
            switch (status)
            {
                case "Active":
                    return "status-badge status-active";
                case "Blocked":
                    return "status-badge status-blocked";
                case "Died":
                    return "status-badge status-died";
                case "Suspend":
                    return "status-badge status-suspend";
                case "Cancle":
                case "Cancel":
                    return "status-badge status-cancle";
                default:
                    return "status-badge status-deactive";
            }
        }
    }
}
