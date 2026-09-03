using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace MemberShipModule
{
    /// <summary>
    /// Audit Log Helper Class
    /// Provides static methods for logging user actions to the AuditLogs table
    /// </summary>
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
