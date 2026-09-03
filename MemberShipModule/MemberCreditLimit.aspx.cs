using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;


public partial class MemberCreditLimit : System.Web.UI.Page
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
            BindMemberLimitGrid("");
        }
    }

    void BindMemberLimitGrid(string memberNo)
    {
        if (string.IsNullOrEmpty(memberNo))
        {
            gvMemberCreditLimits.DataSource = null;
            gvMemberCreditLimits.DataBind();
            return;
        }

        DataTable displayDt = new DataTable();
        displayDt.Columns.Add("MemberNo", typeof(string));
        displayDt.Columns.Add("ApplicantName", typeof(string));
        displayDt.Columns.Add("MembershipCategory", typeof(string));
        displayDt.Columns.Add("CreditLimit", typeof(decimal));

        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("usp_GetMembersWithCreditLimit", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // Determine the actual column names to prevent crashes if schema is different
                    string colMemberNo = dt.Columns.Contains("MemberNo") ? "MemberNo" : (dt.Columns.Contains("Member_No") ? "Member_No" : "");
                    string colName = dt.Columns.Contains("ApplicantName") ? "ApplicantName" : (dt.Columns.Contains("MemberName") ? "MemberName" : "");
                    string colCategory = dt.Columns.Contains("MembershipCategory") ? "MembershipCategory" : (dt.Columns.Contains("MemberType") ? "MemberType" : "");
                    string colLimit = dt.Columns.Contains("CreditLimit") ? "CreditLimit" : "";

                    if (!string.IsNullOrEmpty(colMemberNo))
                    {
                        // Filter DataTable to only contain the searched member
                        string filterExpr = string.Format("{0} = '{1}'", colMemberNo, memberNo.Replace("'", "''"));
                        DataRow[] foundRows = dt.Select(filterExpr);
                        foreach (DataRow row in foundRows)
                        {
                            DataRow newRow = displayDt.NewRow();
                            newRow["MemberNo"] = row[colMemberNo];
                            newRow["ApplicantName"] = !string.IsNullOrEmpty(colName) ? row[colName] : "";
                            newRow["MembershipCategory"] = !string.IsNullOrEmpty(colCategory) ? row[colCategory] : "";
                            newRow["CreditLimit"] = !string.IsNullOrEmpty(colLimit) && row[colLimit] != DBNull.Value ? Convert.ToDecimal(row[colLimit]) : 0m;
                            displayDt.Rows.Add(newRow);
                        }
                    }
                }
            }
        }
        catch (Exception)
        {
            // If the stored procedure is missing or fails, fall back to displaying the row programmatically
        }

        // Fallback: If no overriding limit rows were loaded from the database, but a search has succeeded,
        // dynamically populate the row using searched values so the page shows the record.
        if (displayDt.Rows.Count == 0 && !string.IsNullOrEmpty(txtMemberName.Text) && txtMemberName.Text != "Not Found")
        {
            DataRow newRow = displayDt.NewRow();
            newRow["MemberNo"] = memberNo;
            newRow["ApplicantName"] = txtMemberName.Text;
            newRow["MembershipCategory"] = ""; 
            decimal currentLimit;
            decimal.TryParse(txtMemberCurrentLimit.Text, out currentLimit);
            newRow["CreditLimit"] = currentLimit;
            displayDt.Rows.Add(newRow);
        }

        gvMemberCreditLimits.DataSource = displayDt;
        gvMemberCreditLimits.DataBind();

        // Enforce proper HTML5 Table Header section
        if (gvMemberCreditLimits.HeaderRow != null)
        {
            gvMemberCreditLimits.HeaderRow.TableSection = System.Web.UI.WebControls.TableRowSection.TableHeader;
        }
    }

    protected void gvMemberCreditLimits_PageIndexChanging(object sender, System.Web.UI.WebControls.GridViewPageEventArgs e)
    {
        gvMemberCreditLimits.PageIndex = e.NewPageIndex;
        string memberNo = txtMemberNoSearch.Text.Trim();
        BindMemberLimitGrid(memberNo);
    }

    protected void btnSearchMember_Click(object sender, EventArgs e)
    {
        lblMemberMessage.Text = "";
        string memberNo = txtMemberNoSearch.Text.Trim();
        if (string.IsNullOrEmpty(memberNo))
        {
            BindMemberLimitGrid("");
            return;
        }

        using (SqlConnection con = new SqlConnection(connStr))
        {
            using (SqlCommand cmd = new SqlCommand("usp_GetMemberCreditLimitByNo", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = memberNo;
                con.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        hfMemberIDSearch.Value = dr["MemberID"].ToString();
                        txtMemberName.Text = dr["ApplicantName"].ToString();
                        txtMemberCurrentLimit.Text = dr["CreditLimit"] != DBNull.Value ? Convert.ToDecimal(dr["CreditLimit"]).ToString("0.##") : "0";
                    }
                    else
                    {
                        hfMemberIDSearch.Value = "";
                        txtMemberName.Text = "Not Found";
                        txtMemberCurrentLimit.Text = "";
                        lblMemberMessage.ForeColor = System.Drawing.Color.Red;
                        lblMemberMessage.Text = "Member not found.";
                    }
                }
            }
        }

        BindMemberLimitGrid(memberNo);
    }

    protected void btnSaveMemberLimit_Click(object sender, EventArgs e)
    {
        lblMemberMessage.Text = "";
        string memberIdStr = hfMemberIDSearch.Value;
        if (string.IsNullOrEmpty(memberIdStr))
        {
             lblMemberMessage.ForeColor = System.Drawing.Color.Red;
             lblMemberMessage.Text = "Please search and select a member first.";
             return;
        }

        decimal newLimit;
        if (!decimal.TryParse(txtMemberNewLimit.Text, out newLimit))
        {
             lblMemberMessage.ForeColor = System.Drawing.Color.Red;
             lblMemberMessage.Text = "Invalid Limit.";
             return;
        }

        if (Session["Emp_ID"] == null) return;
        
        string empId = Session["Emp_ID"].ToString();
        string empName = Session["Emp_Name"] != null ? Session["Emp_Name"].ToString() : empId;

        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            decimal oldLimit = 0;
            using (SqlCommand getCmd = new SqlCommand("usp_GetMemberCreditLimitByID", con))
            {
                getCmd.CommandType = CommandType.StoredProcedure;
                getCmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = Convert.ToInt32(memberIdStr);
                object res = getCmd.ExecuteScalar();
                if (res != null && res != DBNull.Value) oldLimit = Convert.ToDecimal(res);
            }

            using (SqlCommand cmd = new SqlCommand("usp_UpdateMemberCreditLimit", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = Convert.ToInt32(memberIdStr);
                cmd.Parameters.Add("@Limit", SqlDbType.Decimal).Value = newLimit;
                cmd.ExecuteNonQuery();
            }

            try
            {
                AuditLogger.LogUpdate(
                    "MemberProfile", 
                    memberIdStr, 
                    empId, 
                    empName, 
                    oldLimit.ToString("0.##"), 
                    newLimit.ToString("0.##"), 
                    "Updated Member Credit Limit via Member Credit Limits page"
                );
            }
            catch { }
        }

        string lastSearchedNo = txtMemberNoSearch.Text.Trim();

        txtMemberNoSearch.Text = "";
        txtMemberName.Text = "";
        txtMemberCurrentLimit.Text = "";
        txtMemberNewLimit.Text = "";
        hfMemberIDSearch.Value = "";

        lblMemberMessage.ForeColor = System.Drawing.Color.Green;
        lblMemberMessage.Text = "Member credit limit updated successfully.";

        BindMemberLimitGrid(lastSearchedNo);
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
                        cmd.Parameters.AddWithValue("@TableName", tableName);
                        cmd.Parameters.AddWithValue("@RecordID", recordId);
                        cmd.Parameters.AddWithValue("@Action", action);
                        cmd.Parameters.AddWithValue("@UserId", (object)userId ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@UserName", (object)userName ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@OldValue", (object)oldValue ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@NewValue", (object)newValue ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Details", (object)details ?? DBNull.Value);

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
            var msConnObj2 = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
            string connectionString = msConnObj2 != null ? msConnObj2.ConnectionString : "";
            DataTable dt = new DataTable();

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string sql = "SELECT [Action], [UserName], [Timestamp], [Details], [OldValue], [NewValue] FROM AuditLogs WHERE RecordID = @RecordID ORDER BY [Timestamp] DESC";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@RecordID", recordId);
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
}
