<%@ Page Language="C#" %>
    <%@ Import Namespace="System.Data" %>
        <%@ Import Namespace="System.Data.SqlClient" %>
            <%@ Import Namespace="System.Configuration" %>

                <!DOCTYPE html>
                <html>

                <head>
                    <title>DB Update</title>
                </head>

                <body>
                    <form id="form1" runat="server">
                        <asp:ScriptManager ID="ScriptManager1" runat="server" />
                        <div>
                            <h2>Database Update Status</h2>
                            <asp:Label ID="lblStatus" runat="server" Text="Running..."></asp:Label>
                        </div>
                    </form>

                    <script runat="server">
    protected void Page_Load(object sender, EventArgs e)
                        {
        var connStringObj = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
        if (connStringObj == null) throw new Exception("Connection string 'MemberShipConnection' not found.");
        string connStr = connStringObj.ConnectionString;
        string log = "Starting updates...<br/>";
        string scriptPath = Server.MapPath("~/SQL_Scripts/GuestRoomModule_Setup.sql");

                            try {
            string scriptContent = System.IO.File.ReadAllText(scriptPath);
                                // Split by GO command
                                string[] commands = System.Text.RegularExpressions.Regex.Split(
                                    scriptContent,
                                    @"^\s*GO\s*$",
                                    System.Text.RegularExpressions.RegexOptions.Multiline | System.Text.RegularExpressions.RegexOptions.IgnoreCase
                                );

                                using(SqlConnection conn = new SqlConnection(connStr))
                                {
                                    conn.Open();
                                    foreach(string commandText in commands)
                                    {
                                        if (!string.IsNullOrWhiteSpace(commandText)) {
                                            try {
                            SqlCommand cmd = new SqlCommand(commandText, conn);
                                                cmd.ExecuteNonQuery();
                                                log += "Executed batch successfully.<br/>";
                                            }
                                            catch (Exception ex)
                                            {
                                                log += "<span>Error executing batch: " + ex.Message + "</span><br/>";
                                                // log += "<pre>" + commandText + "</pre><br/>";
                                            }
                                        }
                                    }
                                }
                                log += "<b>Guest Room Module Setup Completed.</b><br/>";
                            }
                            catch (Exception ex)
                            {
                                log += "<span>Fatal Error: " + ex.Message + "</span>";
                            }

                            lblStatus.Text = log;
                        }

    private string AddColumnIfNotExists(SqlConnection conn, string tableName, string columnName, string columnDef)
                        {
                            // ... (Existing implementation kept for reference if needed, but not used in this run)
                            return "";
                        }

                    </script>
                </body>

                </html>






