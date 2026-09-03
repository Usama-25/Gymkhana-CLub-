//using System;
//using System.Configuration;
//using System.Data;
//using System.Data.SqlClient;
//using System.Web.UI;
//using System.Web.UI.WebControls;

//namespace MemberShipModule
//{
//    public partial class MembershipCategoryAdjustment : System.Web.UI.Page
//    {
//        private string Con
//        {
//            get
//            {
//                var s = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
//                return s != null ? s.ConnectionString : "";
//            }
//        }

//        protected void Page_Load(object sender, EventArgs e)
//        {
//            if (!IsPostBack)
//            {
//                txtRequestDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
//                PopulateCategories();
//                GenerateRequestNo();
//            }
//        }

//        private void PopulateCategories()
//        {
//            try
//            {
//                using (SqlConnection con = new SqlConnection(Con))
//                using (SqlCommand cmd = new SqlCommand("SELECT id, MembershipType FROM MembershipType WHERE Status = 1 ORDER BY MembershipType", con))
//                {
//                    con.Open();
//                    SqlDataAdapter da = new SqlDataAdapter(cmd);
//                    DataTable dt = new DataTable();
//                    da.Fill(dt);

//                    ddlNewCategory.DataSource = dt;
//                    ddlNewCategory.DataTextField = "MembershipType";
//                    ddlNewCategory.DataValueField = "MembershipType";
//                    ddlNewCategory.DataBind();
//                    ddlNewCategory.Items.Insert(0, new ListItem("Select Category", ""));
//                }
//            }
//            catch (Exception ex)
//            {
//                System.Diagnostics.Debug.WriteLine("PopulateCategories Error: " + ex.Message);
//            }
//        }

//        private void GenerateRequestNo()
//        {
//            try
//            {
//                using (SqlConnection con = new SqlConnection(Con))
//                using (SqlCommand cmd = new SqlCommand(
//                    "SELECT ISNULL(MAX(RequestNo), 0) + 1 FROM MemberProfileChangeLog WHERE ChangeType LIKE '%CATEGORY%'", con))
//                {
//                    con.Open();
//                    object result = cmd.ExecuteScalar();
//                    txtRequestNo.Text = result != null ? result.ToString() : "1";
//                }
//            }
//            catch
//            {
//                txtRequestNo.Text = DateTime.Now.ToString("yyyyMMddHHmmss");
//            }
//        }

//        protected void txtMemberNo_TextChanged(object sender, EventArgs e)
//        {
//            string memberNo = txtMemberNo.Text.Trim();
//            if (string.IsNullOrEmpty(memberNo)) return;

//            try
//            {
//                using (SqlConnection con = new SqlConnection(Con))
//                using (SqlCommand cmd = new SqlCommand("usp_GetMemberForCategoryAdjustment", con))
//                {
//                    cmd.CommandType = CommandType.StoredProcedure;
//                    cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = memberNo;
//                    con.Open();

//                    using (SqlDataReader dr = cmd.ExecuteReader())
//                    {
//                        if (dr.Read())
//                        {
//                            hdnMemberProfileID.Value = dr["MemberProfileID"] != DBNull.Value ? dr["MemberProfileID"].ToString() : "0";
//                            hdnMID.Value = dr["MemberID"] != DBNull.Value ? dr["MemberID"].ToString() : "0";
//                            txtMemberName.Text = dr["MemberName"].ToString();
//                            txtDisplayMID.Text = hdnMID.Value;
//                            txtACStatus.Text = dr["AccountStatus"].ToString();


//                            txtExistingCategory.Text = dr["MemberCategory"].ToString();
//                            txtExistingMemberType.Text = dr["MemberType"].ToString();
//                            txtExistingTypeCode.Text = HasColumn(dr, "TypeCode") ? dr["TypeCode"].ToString() : "";
//                            txtExistingTypeSeq.Text = HasColumn(dr, "TypeSeq") ? dr["TypeSeq"].ToString() : "";
//                            txtExistingMFee.Text = HasColumn(dr, "MFee") ? dr["MFee"].ToString() : "0";
//                            txtExistingMFee2.Text = HasColumn(dr, "MFee2") ? dr["MFee2"].ToString() : "0";


//                            SafeSetSelectedValue(ddlNewMemberType, txtExistingMemberType.Text);


//                            LoadChangeLog();
//                        }
//                        else
//                        {
//                            ClearMemberFields();
//                            ShowMessage("error", "Member not found with Member No: " + memberNo);
//                        }
//                    }
//                }
//            }
//            catch (Exception ex)
//            {
//                ShowMessage("error", "Error loading member: " + ex.Message);
//            }
//        }

//        protected void btnSave_Click(object sender, EventArgs e)
//        {
//            // Validate
//            if (string.IsNullOrEmpty(hdnMemberProfileID.Value) || hdnMemberProfileID.Value == "0")
//            {
//                ShowMessage("error", "Please search and select a member first.");
//                return;
//            }

//            if (string.IsNullOrEmpty(ddlNewCategory.SelectedValue) && string.IsNullOrEmpty(ddlNewMemberType.SelectedValue))
//            {
//                ShowMessage("error", "Please select at least a new category or member type.");
//                return;
//            }

//            string userId = Session["UserId"] != null ? Session["UserId"].ToString() : "0";
//            string userName = Session["UserName"] != null ? Session["UserName"].ToString() : "System";

//            try
//            {
//                using (SqlConnection con = new SqlConnection(Con))
//                {
//                    con.Open();
//                    SqlTransaction transaction = con.BeginTransaction();

//                    try
//                    {
//                        int memberProfileId = Convert.ToInt32(hdnMemberProfileID.Value);
//                        string oldCategory = txtExistingCategory.Text.Trim();
//                        string newCategory = ddlNewCategory.SelectedValue;
//                        string oldMemberType = txtExistingMemberType.Text.Trim();
//                        string newMemberType = ddlNewMemberType.SelectedValue;
//                        string reason = txtReason.Text.Trim();
//                        int requestNo = 0;
//                        int.TryParse(txtRequestNo.Text.Trim(), out requestNo);

//                        // 1. Update MemberProfile table
//                        using (SqlCommand cmd = new SqlCommand("usp_UpdateMemberCategory", con, transaction))
//                        {
//                            cmd.CommandType = CommandType.StoredProcedure;
//                            cmd.Parameters.Add("@MemberProfileID", SqlDbType.Int).Value = memberProfileId;
//                            cmd.Parameters.Add("@NewMemberCategory", SqlDbType.NVarChar, 255).Value = string.IsNullOrEmpty(newCategory ? (object)DBNull.Value : newCategory);
//                            cmd.Parameters.Add("@NewMemberType", SqlDbType.NVarChar, 255).Value = string.IsNullOrEmpty(newMemberType ? (object)DBNull.Value : newMemberType);
//                            cmd.ExecuteNonQuery();
//                        }

//                        // 2. Log MemberCategory change (if changed)
//                        if (!string.IsNullOrEmpty(newCategory) && newCategory != oldCategory)
//                        {
//                            using (SqlCommand cmd = new SqlCommand("usp_InsertMemberProfileChangeLog", con, transaction))
//                            {
//                                cmd.CommandType = CommandType.StoredProcedure;
//                                cmd.Parameters.Add("@MemberProfileID", SqlDbType.Int).Value = memberProfileId;
//                                cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = txtMemberNo.Text.Trim();
//                                cmd.Parameters.Add("@ChangeType", SqlDbType.NVarChar, 255).Value = "CATEGORY_CHANGE";
//                                cmd.Parameters.Add("@FieldName", SqlDbType.NVarChar, 255).Value = "MemberCategory";
//                                cmd.Parameters.Add("@OldValue", SqlDbType.NVarChar, 255).Value = oldCategory;
//                                cmd.Parameters.Add("@NewValue", SqlDbType.NVarChar, 255).Value = newCategory;
//                                cmd.Parameters.Add("@Reason", SqlDbType.NVarChar, 255).Value = string.IsNullOrEmpty(reason ? (object)DBNull.Value : reason);
//                                cmd.Parameters.Add("@RequestNo", SqlDbType.NVarChar, 255).Value = requestNo;
//                                cmd.Parameters.Add("@RequestDate", SqlDbType.DateTime).Value = DateTime.Parse(txtRequestDate.Text);
//                                cmd.Parameters.Add("@ModifiedBy", SqlDbType.NVarChar, 255).Value = userName;
//                                cmd.Parameters.Add("@ModifiedByUserId", SqlDbType.Int).Value = userId;
//                                cmd.Parameters.Add("@IsMember", SqlDbType.Bit).Value = rbMember.Checked;
//                                cmd.ExecuteNonQuery();
//                            }
//                        }

//                        // 3. Log MemberType change (if changed)
//                        if (!string.IsNullOrEmpty(newMemberType) && newMemberType != oldMemberType)
//                        {
//                            using (SqlCommand cmd = new SqlCommand("usp_InsertMemberProfileChangeLog", con, transaction))
//                            {
//                                cmd.CommandType = CommandType.StoredProcedure;
//                                cmd.Parameters.Add("@MemberProfileID", SqlDbType.Int).Value = memberProfileId;
//                                cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = txtMemberNo.Text.Trim();
//                                cmd.Parameters.Add("@ChangeType", SqlDbType.NVarChar, 255).Value = "MEMBER_TYPE_CHANGE";
//                                cmd.Parameters.Add("@FieldName", SqlDbType.NVarChar, 255).Value = "MemberType";
//                                cmd.Parameters.Add("@OldValue", SqlDbType.NVarChar, 255).Value = oldMemberType;
//                                cmd.Parameters.Add("@NewValue", SqlDbType.NVarChar, 255).Value = newMemberType;
//                                cmd.Parameters.Add("@Reason", SqlDbType.NVarChar, 255).Value = string.IsNullOrEmpty(reason ? (object)DBNull.Value : reason);
//                                cmd.Parameters.Add("@RequestNo", SqlDbType.NVarChar, 255).Value = requestNo;
//                                cmd.Parameters.Add("@RequestDate", SqlDbType.DateTime).Value = DateTime.Parse(txtRequestDate.Text);
//                                cmd.Parameters.Add("@ModifiedBy", SqlDbType.NVarChar, 255).Value = userName;
//                                cmd.Parameters.Add("@ModifiedByUserId", SqlDbType.Int).Value = userId;
//                                cmd.Parameters.Add("@IsMember", SqlDbType.Bit).Value = rbMember.Checked;
//                                cmd.ExecuteNonQuery();
//                            }
//                        }

//                        // 4. Also log to AuditLogs table
//                        string auditOld = "Category: " + oldCategory + ", Type: " + oldMemberType;
//                        string auditNew = "Category: " + (string.IsNullOrEmpty(newCategory) ? oldCategory : newCategory)
//                            + ", Type: " + (string.IsNullOrEmpty(newMemberType) ? oldMemberType : newMemberType);
//                        AuditLogger.LogUpdate("MemberProfile", memberProfileId.ToString(), userId, userName, auditOld, auditNew,
//                            "Membership Category Adjustment. Reason: " + reason);

//                        transaction.Commit();

//                        ShowMessage("success", "Membership category updated successfully!");

//                        // Refresh existing fields
//                        if (!string.IsNullOrEmpty(newCategory))
//                            txtExistingCategory.Text = newCategory;
//                        if (!string.IsNullOrEmpty(newMemberType))
//                            txtExistingMemberType.Text = newMemberType;

//                        LoadChangeLog();
//                        GenerateRequestNo();
//                    }
//                    catch (Exception ex)
//                    {
//                        transaction.Rollback();
//                        ShowMessage("error", "Transaction failed: " + ex.Message);
//                    }
//                }
//            }
//            catch (Exception ex)
//            {
//                ShowMessage("error", "Save failed: " + ex.Message);
//            }
//        }

//        protected void btnClear_Click(object sender, EventArgs e)
//        {
//            ClearMemberFields();
//            txtMemberNo.Text = "";
//            txtReason.Text = "";
//            ddlNewCategory.SelectedIndex = 0;
//            ddlNewMemberType.SelectedIndex = 0;
//            txtNewTypeCode.Text = "";
//            txtNewTypeSeq.Text = "";
//            txtNewTypeFlag.Text = "";
//            txtNewMFee.Text = "0";
//            txtNewMFee2.Text = "0";
//            rbMember.Checked = true;
//            rbSupplementary.Checked = false;
//            gvChangeLog.DataSource = null;
//            gvChangeLog.DataBind();
//            GenerateRequestNo();
//        }

//        private void ClearMemberFields()
//        {
//            hdnMemberProfileID.Value = "0";
//            hdnMID.Value = "0";
//            txtMemberName.Text = "";
//            txtDisplayMID.Text = "";
//            txtACStatus.Text = "";
//            txtExistingCategory.Text = "";
//            txtExistingMemberType.Text = "";
//            txtExistingTypeCode.Text = "";
//            txtExistingTypeSeq.Text = "";
//            txtExistingMFee.Text = "0";
//            txtExistingMFee2.Text = "0";
//        }

//        private void LoadChangeLog()
//        {
//            if (string.IsNullOrEmpty(hdnMemberProfileID.Value) || hdnMemberProfileID.Value == "0") return;

//            try
//            {
//                using (SqlConnection con = new SqlConnection(Con))
//                using (SqlCommand cmd = new SqlCommand(
//                    @"SELECT ChangeType, FieldName, OldValue, NewValue, Reason, ModifiedBy, ModifiedOn, RequestNo 
//                      FROM MemberProfileChangeLog 
//                      WHERE MemberProfileID = @MemberProfileID 
//                      ORDER BY ModifiedOn DESC", con))
//                {
//                    cmd.Parameters.Add("@MemberProfileID", SqlDbType.Int).Value = Convert.ToInt32(hdnMemberProfileID.Value);
//                    SqlDataAdapter da = new SqlDataAdapter(cmd);
//                    DataTable dt = new DataTable();
//                    da.Fill(dt);
//                    gvChangeLog.DataSource = dt;
//                    gvChangeLog.DataBind();
//                }
//            }
//            catch (Exception ex)
//            {
//                System.Diagnostics.Debug.WriteLine("LoadChangeLog Error: " + ex.Message);
//            }
//        }

//        private bool HasColumn(SqlDataReader reader, string columnName)
//        {
//            for (int i = 0; i < reader.FieldCount; i++)
//            {
//                if (reader.GetName(i).Equals(columnName, StringComparison.OrdinalIgnoreCase))
//                    return true;
//            }
//            return false;
//        }

//        private void SafeSetSelectedValue(DropDownList ddl, string value)
//        {
//            if (ddl.Items.FindByValue(value) != null)
//            {
//                ddl.SelectedValue = value;
//            }
//            else
//            {
//                ddl.SelectedIndex = 0;
//            }
//        }

//        private void ShowMessage(string type, string message)
//        {
//            message = message.Replace("'", "\\'").Replace("\n", "\\n").Replace("\r", "\\r");

//            string script;
//            if (type.ToLower() == "success")
//            {
//                script = "<script type='text/javascript'>alert('" + message + "');</script>";
//            }
//            else
//            {
//                script = "<script type='text/javascript'>alert('Error: " + message + "');</script>";
//            }

//            if (!ClientScript.IsStartupScriptRegistered("ShowMessageScript"))
//            {
//                ClientScript.RegisterStartupScript(this.GetType(), "ShowMessageScript", script);
//            }
//        }
//    }
//    public static class AuditLogger
//    {
//        /// <summary>
//        /// Logs an action to the audit trail
//        /// </summary>
//        /// <param name="tableName">Name of the table being affected</param>
//        /// <param name="recordId">ID of the record being affected</param>
//        /// <param name="action">Action being performed (INSERT, UPDATE, DELETE, etc.)</param>
//        /// <param name="userId">ID of the user performing the action</param>
//        /// <param name="userName">Username of the user performing the action</param>
//        /// <param name="oldValue">Previous value (for updates) - optional</param>
//        /// <param name="newValue">New value (for inserts/updates) - optional</param>
//        /// <param name="details">Additional details about the action - optional</param>
//        /// <returns>LogID if successful, -1 if failed</returns>
//        public static int Log(
//            string tableName,
//            string recordId,
//            string action,
//            string userId = null,
//            string userName = null,
//            string oldValue = null,
//            string newValue = null,
//            string details = null)
//        {
//            // Validate required parameters
//            if (string.IsNullOrWhiteSpace(tableName))
//                throw new ArgumentException("TableName cannot be null or empty", "tableName");

//            if (string.IsNullOrWhiteSpace(recordId))
//                throw new ArgumentException("RecordID cannot be null or empty", "recordId");

//            if (string.IsNullOrWhiteSpace(action))
//                throw new ArgumentException("Action cannot be null or empty", "action");

//            int logId = -1;
//            var msConnObj = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
//            string connectionString = msConnObj != null ? msConnObj.ConnectionString : "";

//            try
//            {
//                using (SqlConnection conn = new SqlConnection(connectionString))
//                {
//                    using (SqlCommand cmd = new SqlCommand("sp_InsertAuditLog", conn))
//                    {
//                        cmd.CommandType = CommandType.StoredProcedure;

//                        // Add parameters
//                        cmd.Parameters.Add("@TableName", SqlDbType.NVarChar, 255).Value = tableName;
//                        cmd.Parameters.Add("@RecordID", SqlDbType.Int).Value = recordId;
//                        cmd.Parameters.Add("@Action", SqlDbType.NVarChar, 255).Value = action;
//                        cmd.Parameters.Add("@UserId", SqlDbType.Int).Value = (objectuserId ?? DBNull.Value);
//                        cmd.Parameters.Add("@UserName", SqlDbType.NVarChar, 255).Value = (objectuserName ?? DBNull.Value);
//                        cmd.Parameters.Add("@OldValue", SqlDbType.NVarChar, 255).Value = (objectoldValue ?? DBNull.Value);
//                        cmd.Parameters.Add("@NewValue", SqlDbType.NVarChar, 255).Value = (objectnewValue ?? DBNull.Value);
//                        cmd.Parameters.Add("@Details", SqlDbType.NVarChar, 255).Value = (objectdetails ?? DBNull.Value);

//                        conn.Open();

//                        // Execute and get the LogID
//                        object result = cmd.ExecuteScalar();
//                        if (result != null && result != DBNull.Value)
//                        {
//                            logId = Convert.ToInt32(result);
//                        }
//                    }
//                }
//            }
//            catch (Exception ex)
//            {
//                // Log the error (you could add error logging here)
//                System.Diagnostics.Debug.WriteLine(string.Format("AuditLog Error: {0}", ex.Message));
//                // Rethrow or handle as needed
//                throw new Exception(string.Format("Failed to insert audit log: {0}", ex.Message), ex);
//            }

//            return logId;
//        }

//        /// <summary>
//        /// Logs an INSERT action
//        /// </summary>
//        public static int LogInsert(string tableName, string recordId, string userId, string userName, string newValue = null, string details = null)
//        {
//            return Log(tableName, recordId, "INSERT", userId, userName, null, newValue, details);
//        }

//        /// <summary>
//        /// Logs an UPDATE action
//        /// </summary>
//        public static int LogUpdate(string tableName, string recordId, string userId, string userName, string oldValue = null, string newValue = null, string details = null)
//        {
//            return Log(tableName, recordId, "UPDATE", userId, userName, oldValue, newValue, details);
//        }

//        /// <summary>
//        /// Logs a DELETE action
//        /// </summary>
//        public static int LogDelete(string tableName, string recordId, string userId, string userName, string oldValue = null, string details = null)
//        {
//            return Log(tableName, recordId, "DELETE", userId, userName, oldValue, null, details);
//        }

//        /// <summary>
//        /// Logs a custom action
//        /// </summary>
//        public static int LogAction(string tableName, string recordId, string action, string userId, string userName, string details = null)
//        {
//            return Log(tableName, recordId, action, userId, userName, null, null, details);
//        }

//        /// <summary>
//        /// Fetches audit logs for a specific record
//        /// </summary>
//        /// <param name="recordId">Member ID or record ID</param>
//        /// <returns>DataTable of logs</returns>
//        public static DataTable GetLogs(string recordId)
//        {
//            var msConnObj2 = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
//            string connectionString = msConnObj2 != null ? msConnObj2.ConnectionString : "";
//            DataTable dt = new DataTable();

//            try
//            {
//                using (SqlConnection conn = new SqlConnection(connectionString))
//                {
//                    string sql = "SELECT [Action], [UserName], [Timestamp], [Details], [OldValue], [NewValue] FROM AuditLogs WHERE RecordID = @RecordID ORDER BY [Timestamp] DESC";
//                    using (SqlCommand cmd = new SqlCommand(sql, conn))
//                    {
//                        cmd.Parameters.Add("@RecordID", SqlDbType.Int).Value = recordId;
//                        SqlDataAdapter adapter = new SqlDataAdapter(cmd);
//                        adapter.Fill(dt);
//                    }
//                }
//            }
//            catch (Exception ex)
//            {
//                System.Diagnostics.Debug.WriteLine(string.Format("AuditLog GetLogs Error: {0}", ex.Message));
//            }

//            return dt;
//        }
//    }
//}



using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MemberShipModule
{
    public partial class MembershipCategoryAdjustment : System.Web.UI.Page
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
                txtRequestDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                PopulateMemberTypes();
                GenerateRequestNo();
                ddlNewMemberType.Enabled = true;
            }
        }



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
        }

        private void BindMembers()
        {
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
            if (e.CommandName == "AdjustCategory")
            {
                string memberNo = e.CommandArgument.ToString();
                LoadMemberForAdjustment(memberNo);
            }
        }

        private void LoadMemberForAdjustment(string memberNo)
        {
            txtMemberNo.Text = memberNo;
            txtMemberNo_TextChanged(null, null);
            
            pnlMemberSearch.Visible = false;
            pnlCategoryAdjustment.Visible = true;
        }

        protected void btnBackToSearch_Click(object sender, EventArgs e)
        {
            pnlCategoryAdjustment.Visible = false;
            pnlMemberSearch.Visible = true;
        }

        private void PopulateMemberTypes()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(Con))
                using (SqlCommand cmd = new SqlCommand("usp_GetActiveMembershipTypes", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    con.Open();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlNewMemberType.DataSource = dt;
                    ddlNewMemberType.DataTextField = "MembershipType";
                    ddlNewMemberType.DataValueField = "Prefix"; // Using Prefix as Value for auto-computation
                    ddlNewMemberType.DataBind();
                    ddlNewMemberType.Items.Insert(0, new ListItem("Select Member Type", ""));
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("PopulateMemberTypes Error: " + ex.Message);
            }
        }

        protected void ddlNewMemberType_SelectedIndexChanged(object sender, EventArgs e)
        {
            string prefix = ddlNewMemberType.SelectedValue;
            if (string.IsNullOrEmpty(prefix))
            {
                txtNewMemberNo.Text = "";
                return;
            }

            string existingNo = txtExistingMemberNo.Text.Trim();
            if (string.IsNullOrEmpty(existingNo)) return;

            string numericPart = "";
            int dashIndex = existingNo.IndexOf('-');
            if (dashIndex >= 0)
            {
                numericPart = existingNo.Substring(dashIndex + 1);
            }
            else
            {
                numericPart = System.Text.RegularExpressions.Regex.Replace(existingNo, "[^0-9]", "");
            }

            txtNewMemberNo.Text = prefix + "-" + numericPart;
        }

        private void GenerateRequestNo()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(Con))
                using (SqlCommand cmd = new SqlCommand("usp_GetNextRequestNo", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    txtRequestNo.Text = result != null ? result.ToString() : "1";
                }
            }
            catch
            {
                txtRequestNo.Text = DateTime.Now.ToString("yyyyMMddHHmmss");
            }
        }

        protected void txtMemberNo_TextChanged(object sender, EventArgs e)
        {
            string memberNo = txtMemberNo.Text.Trim();
            if (string.IsNullOrEmpty(memberNo)) return;

            try
            {
                using (SqlConnection con = new SqlConnection(Con))
                using (SqlCommand cmd = new SqlCommand("usp_GetMemberDetailsForAdjustment", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = memberNo;
                    con.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            hdnMemberProfileID.Value = dr["MemberProfileID"] != DBNull.Value ? dr["MemberProfileID"].ToString() : "0";
                            hdnMID.Value = dr["MemberID"] != DBNull.Value ? dr["MemberID"].ToString() : "0";
                            txtMemberName.Text = dr["MemberName"].ToString();
                            txtDisplayMID.Text = hdnMID.Value;
                            txtACStatus.Text = dr["AccountStatus"] != DBNull.Value ? dr["AccountStatus"].ToString() : "";

                            txtExistingCategory.Text = dr["MemberType"] != DBNull.Value ? dr["MemberType"].ToString() : ""; // "Category should load same as MemberType"
                            txtExistingMemberType.Text = dr["MemberShipCategory"] != DBNull.Value ? dr["MemberShipCategory"].ToString() : "";
                            txtExistingMemberNo.Text = dr["MemberNo"] != DBNull.Value ? dr["MemberNo"].ToString() : "";

                            // ddlNewCategory removed
                            // Note: ddlNewMemberType now uses Prefix as value, so setting it by text might be tricky
                            // We will try to find it by text if possible
                            ListItem item = ddlNewMemberType.Items.FindByText(txtExistingMemberType.Text);
                            if (item != null) ddlNewMemberType.SelectedValue = item.Value;

                            LoadChangeLog();
                        }
                        else
                        {
                            ClearMemberFields();
                            ShowMessage("error", "Member not found with Member No: " + memberNo);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("error", "Error loading member: " + ex.Message);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hdnMemberProfileID.Value) || hdnMemberProfileID.Value == "0")
            {
                ShowMessage("error", "Please search and select a member first.");
                return;
            }

            if (string.IsNullOrEmpty(ddlNewMemberType.SelectedValue))
            {
                ShowMessage("error", "Please select a new member type.");
                return;
            }

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
                        int memberProfileId = Convert.ToInt32(hdnMemberProfileID.Value);
                        string oldCategory = txtExistingCategory.Text.Trim();
                        string oldMemberType = txtExistingMemberType.Text.Trim();
                        string newMemberType = ddlNewMemberType.SelectedItem.Text == "Select Member Type" ? "" : ddlNewMemberType.SelectedItem.Text;
                        string newCategory = txtExistingCategory.Text.Trim(); // Synced with MemberType as requested
                        string oldMemberNo = txtExistingMemberNo.Text.Trim();
                        string newMemberNoVal = txtNewMemberNo.Text.Trim();
                        string reason = txtReason.Text.Trim();
                        int requestNo = 0;
                        int.TryParse(txtRequestNo.Text.Trim(), out requestNo);

                        // Update MemberProfile table
                        using (SqlCommand cmd = new SqlCommand("usp_UpdateMemberProfileCategory", con, transaction))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@MemberProfileID", SqlDbType.Int).Value = memberProfileId;
                            cmd.Parameters.Add("@NewMemberType", SqlDbType.NVarChar, 50).Value = string.IsNullOrEmpty(newMemberType) ? (object)DBNull.Value : newMemberType;
                            cmd.Parameters.Add("@NewMemberNo", SqlDbType.NVarChar, 50).Value = string.IsNullOrEmpty(newMemberNoVal) ? (object)DBNull.Value : newMemberNoVal;
                            cmd.ExecuteNonQuery();
                        }

                        // Update Member table
                        using (SqlCommand cmd = new SqlCommand("usp_UpdateMemberCategory", con, transaction))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@MemberProfileID", SqlDbType.Int).Value = memberProfileId;
                            cmd.Parameters.Add("@NewMemberCategory", SqlDbType.NVarChar, 50).Value = string.IsNullOrEmpty(newCategory) ? (object)DBNull.Value : newCategory;
                            cmd.Parameters.Add("@NewMemberType", SqlDbType.NVarChar, 50).Value = string.IsNullOrEmpty(newMemberType) ? (object)DBNull.Value : newMemberType;
                            cmd.ExecuteNonQuery();
                        }

                        // Update dependents (Spouses and Children) membership numbers
                        if (!string.IsNullOrEmpty(newMemberNoVal))
                        {
                            string actualOldMemberNo = oldMemberNo;
                            // Fetch the current MembershipNo from dependents table to use as old prefix
                            using (SqlCommand cmdOld = new SqlCommand("SELECT TOP 1 MembershipNo FROM MemberSpouses WHERE MemberID = @MemberID", con, transaction))
                            {
                                cmdOld.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberProfileId;
                                object result = cmdOld.ExecuteScalar();
                                if (result != null && result != DBNull.Value && !string.IsNullOrEmpty(result.ToString()))
                                {
                                    string fullNo = result.ToString().Trim();
                                    int lastDash = fullNo.LastIndexOf('-');
                                    if (lastDash >= 0)
                                    {
                                        actualOldMemberNo = fullNo.Substring(0, lastDash);
                                    }
                                }
                                else
                                {
                                    // Try Children table if Spouse not found
                                    cmdOld.CommandText = "SELECT TOP 1 MembershipNo FROM MemberChildren WHERE MemberID = @MemberID";
                                    result = cmdOld.ExecuteScalar();
                                    if (result != null && result != DBNull.Value && !string.IsNullOrEmpty(result.ToString()))
                                    {
                                        string fullNo = result.ToString().Trim();
                                        int lastDash = fullNo.LastIndexOf('-');
                                        if (lastDash >= 0)
                                        {
                                            actualOldMemberNo = fullNo.Substring(0, lastDash);
                                        }
                                    }
                                }
                            }

                            // Update Spouses
                            using (SqlCommand cmd = new SqlCommand(
                                @"UPDATE MemberSpouses 
                                  SET MembershipNo = REPLACE(MembershipNo, @OldMemberNo, @NewMemberNo)
                                  WHERE MemberID = @MemberID", con, transaction))
                            {
                                cmd.Parameters.Add("@NewMemberNo", SqlDbType.NVarChar, 50).Value = newMemberNoVal;
                                cmd.Parameters.Add("@OldMemberNo", SqlDbType.NVarChar, 50).Value = actualOldMemberNo;
                                cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberProfileId;
                                cmd.ExecuteNonQuery();
                            }

                            // Update Children
                            using (SqlCommand cmd = new SqlCommand(
                                @"UPDATE MemberChildren 
                                  SET MembershipNo = REPLACE(MembershipNo, @OldMemberNo, @NewMemberNo)
                                  WHERE MemberID = @MemberID", con, transaction))
                            {
                                cmd.Parameters.Add("@NewMemberNo", SqlDbType.NVarChar, 50).Value = newMemberNoVal;
                                cmd.Parameters.Add("@OldMemberNo", SqlDbType.NVarChar, 50).Value = actualOldMemberNo;
                                cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberProfileId;
                                cmd.ExecuteNonQuery();
                            }
                        }

                        // Log Category Change
                        if (!string.IsNullOrEmpty(newCategory) && newCategory != oldCategory)
                        {
                            LogChange(con, transaction, memberProfileId, "CATEGORY_CHANGE", "MemberCategory",
                                     oldCategory, newCategory, reason, requestNo, userId, userName);
                        }

                        // Log Member Type Change
                        if (!string.IsNullOrEmpty(newMemberType) && newMemberType != oldMemberType)
                        {
                            LogChange(con, transaction, memberProfileId, "MEMBER_TYPE_CHANGE", "MemberType",
                                     oldMemberType, newMemberType, reason, requestNo, userId, userName);
                        }

                        // Log Member No Change
                        if (!string.IsNullOrEmpty(newMemberNoVal) && newMemberNoVal != oldMemberNo)
                        {
                            LogChange(con, transaction, memberProfileId, "MEMBER_NO_CHANGE", "MemberNo",
                                     oldMemberNo, newMemberNoVal, reason, requestNo, userId, userName);
                        }

                        transaction.Commit();

                        ShowMessage("success", "Membership updated successfully!");

                        // Refresh display
                        if (!string.IsNullOrEmpty(newMemberType))
                            txtExistingMemberType.Text = newMemberType;
                        txtExistingCategory.Text = txtExistingMemberType.Text; // Sync category display

                        if (!string.IsNullOrEmpty(newMemberNoVal))
                        {
                            txtExistingMemberNo.Text = newMemberNoVal;
                            txtMemberNo.Text = newMemberNoVal;
                        }

                        ddlNewMemberType.SelectedIndex = 0;
                        txtNewMemberNo.Text = "";
                        txtReason.Text = "";

                        LoadChangeLog();
                        GenerateRequestNo();
                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        ShowMessage("error", "Transaction failed: " + ex.Message);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("error", "Save failed: " + ex.Message);
            }
        }

        private void LogChange(SqlConnection con, SqlTransaction transaction, int memberProfileId,
                               string changeType, string fieldName, string oldValue, string newValue,
                               string reason, int requestNo, string userId, string userName)
        {
            using (SqlCommand cmd = new SqlCommand("usp_InsertMemberProfileChangeLog", con, transaction))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@MemberProfileID", SqlDbType.Int).Value = memberProfileId;
                cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = txtMemberNo.Text.Trim();
                cmd.Parameters.Add("@ChangeType", SqlDbType.NVarChar, 50).Value = changeType;
                cmd.Parameters.Add("@FieldName", SqlDbType.NVarChar, 100).Value = fieldName;
                cmd.Parameters.Add("@OldValue", SqlDbType.NVarChar, 100).Value = string.IsNullOrEmpty(oldValue) ? (object)DBNull.Value : oldValue;
                cmd.Parameters.Add("@NewValue", SqlDbType.NVarChar, 100).Value = string.IsNullOrEmpty(newValue) ? (object)DBNull.Value : newValue;
                cmd.Parameters.Add("@Reason", SqlDbType.NVarChar, -1).Value = string.IsNullOrEmpty(reason) ? (object)DBNull.Value : reason;
                cmd.Parameters.Add("@RequestNo", SqlDbType.Int).Value = requestNo;
                cmd.Parameters.Add("@RequestDate", SqlDbType.DateTime).Value = DateTime.Parse(txtRequestDate.Text);
                cmd.Parameters.Add("@ModifiedBy", SqlDbType.NVarChar, 100).Value = userName;
                cmd.Parameters.Add("@ModifiedByUserId", SqlDbType.Int).Value = Convert.ToInt32(userId);
                cmd.Parameters.Add("@IsMember", SqlDbType.Bit).Value = rbMember.Checked;
                cmd.ExecuteNonQuery();
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearMemberFields();
            txtMemberNo.Text = "";
            txtReason.Text = "";
            ddlNewMemberType.SelectedIndex = 0;
            txtNewMemberNo.Text = "";
            rbMember.Checked = true;
            rbSupplementary.Checked = false;
            gvChangeLog.DataSource = null;
            gvChangeLog.DataBind();
            GenerateRequestNo();
        }

        private void ClearMemberFields()
        {
            hdnMemberProfileID.Value = "0";
            hdnMID.Value = "0";
            txtMemberName.Text = "";
            txtDisplayMID.Text = "";
            txtACStatus.Text = "";
            txtExistingCategory.Text = "";
            txtExistingMemberType.Text = "";
            txtExistingMemberNo.Text = "";
            txtNewMemberNo.Text = "";
        }

        private void LoadChangeLog()
        {
            if (string.IsNullOrEmpty(hdnMemberProfileID.Value) || hdnMemberProfileID.Value == "0") return;

            try
            {
                using (SqlConnection con = new SqlConnection(Con))
                using (SqlCommand cmd = new SqlCommand(@"SELECT ChangeType, FieldName, OldValue, NewValue, Reason, ModifiedBy, ModifiedOn, RequestNo 
                      FROM MemberProfileChangeLog 
                      WHERE MemberProfileID = @MemberProfileID 
                      ORDER BY ModifiedOn DESC", con))
                {
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

        private void SafeSetSelectedValue(DropDownList ddl, string value)
        {
            if (!string.IsNullOrEmpty(value) && ddl.Items.FindByValue(value) != null)
            {
                ddl.SelectedValue = value;
            }
            else
            {
                ddl.SelectedIndex = 0;
            }
        }

        private void ShowMessage(string type, string message)
        {
            message = message.Replace("'", "\\'").Replace("\n", "\\n").Replace("\r", "\\r");

            string prefix = (type == "success") ? "" : "Error: ";
            string script = "<script type='text/javascript'>alert('" + prefix + message + "');</script>";

            if (!ClientScript.IsStartupScriptRegistered("ShowMessageScript"))
            {
                ClientScript.RegisterStartupScript(this.GetType(), "ShowMessageScript", script);
            }
        }
    }
}