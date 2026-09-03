<%@ Page Language="C#" AutoEventWireup="true" %>
    <%@ Import Namespace="System.Data.SqlClient" %>
        <%@ Import Namespace="System.Configuration" %>
            <!DOCTYPE html>
            <html>

            <head runat="server">
                <title>Fix Schema</title>
            </head>

            <body>
                <form id="form1" runat="server">
                    <asp:ScriptManager ID="ScriptManager1" runat="server" />
                    <div>
                        <h2>Database Schema Fixer</h2>
                        <asp:Button ID="btnFix" runat="server" Text="Fix MemberDocuments table"
                            OnClick="btnFix_Click" />
                        <br /><br />
                        <asp:Label ID="lblStatus" runat="server" ForeColor="Green"></asp:Label>
                    </div>
                </form>
            </body>
            <script runat="server">
    protected void btnFix_Click(object sender, EventArgs e)
                {
                    var connStringObj = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
                    if (connStringObj == null) throw new Exception("Connection string 'MemberShipConnection' not found.");
        string connStr = connStringObj.ConnectionString;
                    try {
                        using(SqlConnection conn = new SqlConnection(connStr))
                        {
                            conn.Open();
                string sql = "ALTER table MemberDocuments ALTER COLUMN MemberID INT NULL";
                            using(SqlCommand cmd = new SqlCommand(sql, conn))
                            {
                                cmd.ExecuteNonQuery();
                            }
                            conn.Close();
                        }
                        lblStatus.Text = "✅ Success! MemberDocuments.MemberID is now nullable.";
                    }
                    catch (Exception ex)
                    {
                        lblStatus.Text = "❌ Error: " + ex.Message;
                        lblStatus.ForeColor = System.Drawing.Color.Red;
                    }
                }
            </script>

            </html>




