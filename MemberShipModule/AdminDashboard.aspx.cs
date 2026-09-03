using System;
using System.Text;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class AdminDashboard : System.Web.UI.Page
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
        rptAlerts.ItemDataBound += rptAlerts_ItemDataBound;
        if (!IsPostBack)
        {
            // Security Check
            if (Session["UserName"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            // Display User Name
            string EFName = Session["EFName"] as string;
            string userName = Session["UserName"] as string;
            litUserName.Text = !string.IsNullOrEmpty(EFName) ? EFName : userName;

            // Card navigation only for Admin
            string role = Session["UserRole"] != null ? Session["UserRole"].ToString() : "";
            if (role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
            {
                cardActiveMembers.Attributes["onclick"] = "window.location.href='Reports/ActiveMembers.aspx'";
                cardPendingApps.Attributes["onclick"] = "window.location.href='ApplicantSearchAdmin.aspx'";
                cardApprovedApps.Attributes["onclick"] = "window.location.href='SearchInterviewResult.aspx'";
                cardBlockedCards.Attributes["onclick"] = "window.location.href='ManageCard.aspx'";
                cardBlockedVehicles.Attributes["onclick"] = "window.location.href='IssuanceStickers.aspx'";
                cardTotalCards.Attributes["onclick"] = "window.location.href='Reports/CardIssuanceReport.aspx'";
            }
            else
            {
                // Remove pointer cursor for non-admin
                cardActiveMembers.Attributes["style"] = "cursor:default;";
                cardPendingApps.Attributes["style"] = "cursor:default;";
                cardApprovedApps.Attributes["style"] = "cursor:default;";
                cardBlockedCards.Attributes["style"] = "cursor:default;";
                cardBlockedVehicles.Attributes["style"] = "cursor:default;";
                cardTotalCards.Attributes["style"] = "cursor:default;";
            }

            LoadDashboardStats();
            LoadAlertCounts();
        }
    }

    private void LoadDashboardStats()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("usp_GetDashboardStats", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            litActiveMembers.Text = Convert.ToInt32(dr["ActiveMembers"]).ToString("N0");
                            litPendingApps.Text = Convert.ToInt32(dr["PendingApps"]).ToString("N0");
                            litApprovedApps.Text = Convert.ToInt32(dr["ApprovedApps"]).ToString("N0");
                            litBlockedCards.Text = Convert.ToInt32(dr["BlockedCards"]).ToString("N0");
                            litBlockedVehicles.Text = Convert.ToInt32(dr["BlockedVehicles"]).ToString("N0");
                            litTotalCards.Text = Convert.ToInt32(dr["ActiveCards"]).ToString("N0");
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Dashboard Error: " + ex.Message);
            litActiveMembers.Text = "ERR";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "dashErr", 
                "console.error('Dashboard Error: " + ex.Message.Replace("'", "\\'") + "'); alert('Dashboard Error: " + ex.Message.Replace("'", "\\'") + "');", true);
        }
    }

    private void LoadAlertCounts()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            try { con.Open(); } catch { return; }

            try
            {
                using (SqlCommand cmd = new SqlCommand("usp_GetAlertCounts", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            litSonsCount.Text = dr["SonsCount"].ToString();
                            litNonEarningCount.Text = dr["NonEarningCount"].ToString();
                            litSeniorCount.Text = dr["SeniorCount"].ToString();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadAlertCounts Error: " + ex.Message);
                litSonsCount.Text = "0";
                litNonEarningCount.Text = "0";
                litSeniorCount.Text = "0";
            }
        }
    }

    protected void lnkSonsAlert_Click(object sender, EventArgs e)
    {
        pnlSelectAlert.Visible = false;
        lblAlertHeader.Text = "Sons Reaching 18 Years Old";
        LoadSpecificAlerts(1);
    }

    protected void lnkNonEarningAlert_Click(object sender, EventArgs e)
    {
        pnlSelectAlert.Visible = false;
        lblAlertHeader.Text = "Non-Earning Members Reaching 27 Years";
        LoadSpecificAlerts(2);
    }

    protected void lnkSeniorAlert_Click(object sender, EventArgs e)
    {
        pnlSelectAlert.Visible = false;
        lblAlertHeader.Text = "Senior Citizens (65+)";
        LoadSpecificAlerts(3);
    }

    private void LoadSpecificAlerts(int type)
    {
        DataTable dtAlerts = new DataTable();
        dtAlerts.Columns.Add("Title");
        dtAlerts.Columns.Add("Message");
        dtAlerts.Columns.Add("Type");
        dtAlerts.Columns.Add("BadgeBg");
        dtAlerts.Columns.Add("BadgeFg");

        using (SqlConnection con = new SqlConnection(connStr))
        {
            try { con.Open(); } catch { return; }

            using (SqlCommand cmd = new SqlCommand("usp_GetSpecificAlerts", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@Type", SqlDbType.NVarChar, 50).Value = type;
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        if (type == 1)
                        {
                            dtAlerts.Rows.Add(
                                "Son Reached 18",
                                string.Format("Member's Son <b>{0}</b> (Son of {1} - {2}) has reached the age of {3}.", dr["ChildName"], dr["MemberName"], dr["MemberNo"], dr["Age"]),
                                "Age Alert",
                                "#fee2e2",
                                "#991b1b"
                            );
                        }
                        else if (type == 2)
                        {
                            dtAlerts.Rows.Add(
                                "Non-Earning Member Reached 27",
                                string.Format("Member <b>{0}</b> ({1}) has reached the age of {2} under 'Non Earning MemberShip'.", dr["MemberName"], dr["MemberNo"], dr["Age"]),
                                "Category Alert",
                                "#fefce8",
                                "#854d0e"
                            );
                        }
                        else if (type == 3)
                        {
                            dtAlerts.Rows.Add(
                                "Senior Citizen (65+)",
                                string.Format("Member <b>{0}</b> ({1}) has reached the age of {2}.", dr["MemberName"], dr["MemberNo"], dr["Age"]),
                                "Senior Alert",
                                "#dcfce7",
                                "#166534"
                            );
                        }
                    }
                }
            }
        }

        ViewState["AlertsData"] = dtAlerts;

        if (dtAlerts.Rows.Count > 0)
        {
            rptAlerts.DataSource = dtAlerts;
            rptAlerts.DataBind();
            pnlNoAlerts.Visible = false;
        }
        else
        {
            rptAlerts.DataSource = null;
            rptAlerts.DataBind();
            pnlNoAlerts.Visible = true;
        }
    }

    public void rptAlerts_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            DataRowView drv = (DataRowView)e.Item.DataItem;
            Label lblBadge = (Label)e.Item.FindControl("lblBadge");
            if (lblBadge != null)
            {
                lblBadge.Style["background-color"] = drv["BadgeBg"].ToString();
                lblBadge.Style["color"] = drv["BadgeFg"].ToString();
            }
        }
    }

    protected void btnExportExcel_Click(object sender, EventArgs e)
    {
        DataTable dt = ViewState["AlertsData"] as DataTable;
        if (dt == null || dt.Rows.Count == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('No data available to export. Please select an alert category first.');", true);
            return;
        }

        // Create a clean DataTable for export
        DataTable dtExport = new DataTable();
        dtExport.Columns.Add("Alert Type");
        dtExport.Columns.Add("Message");
        dtExport.Columns.Add("Category");

        foreach (DataRow row in dt.Rows)
        {
            dtExport.Rows.Add(
                row["Title"],
                row["Message"].ToString().Replace("<b>", "").Replace("</b>", ""),
                row["Type"]
            );
        }

        Response.Clear();
        Response.Buffer = true;
        Response.AddHeader("content-disposition", "attachment;filename=SystemAlerts.csv");
        Response.Charset = "utf-8";
        Response.ContentType = "text/csv";

        // Add UTF-8 BOM to make Excel happy with UTF-8 content
        Response.BinaryWrite(new byte[] { 0xEF, 0xBB, 0xBF });

        StringBuilder sb = new StringBuilder();
        
        // Add header
        for (int k = 0; k < dtExport.Columns.Count; k++)
        {
            sb.Append(dtExport.Columns[k].ColumnName + (k < dtExport.Columns.Count - 1 ? "," : ""));
        }
        sb.Append("\r\n");
        
        // Add rows
        foreach (DataRow row in dtExport.Rows)
        {
            for (int k = 0; k < dtExport.Columns.Count; k++)
            {
                string value = row[k].ToString();
                // Escape quotes and wrap in quotes if contains comma or quote
                if (value.Contains(",") || value.Contains("\"") || value.Contains("\n") || value.Contains("\r"))
                {
                    value = "\"" + value.Replace("\"", "\"\"") + "\"";
                }
                sb.Append(value + (k < dtExport.Columns.Count - 1 ? "," : ""));
            }
            sb.Append("\r\n");
        }
        
        Response.Write(sb.ToString());
        Response.End();
    }

    protected void btnExportPDF_Click(object sender, EventArgs e)
    {
        DataTable dt = ViewState["AlertsData"] as DataTable;
        if (dt == null || dt.Rows.Count == 0) return;

        string generatedDate = DateTime.Now.ToString("dd-MMM-yyyy HH:mm");

        // Build clean HTML report as seen in NewApplications.aspx
        StringBuilder html = new StringBuilder();
        html.Append(@"<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>System Alerts Report</title>
    <style>
        @page { size: A4; margin: 15mm; }
        @media print { body { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; } }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', Arial, sans-serif; font-size: 11px; color: #1a202c; background: #fff; padding: 20px; }
        .header { text-align: center; margin-bottom: 25px; padding-bottom: 15px; border-bottom: 2px solid #2c5282; }
        .title { font-size: 20px; font-weight: bold; color: #1a365d; margin-bottom: 5px; }
        .subtitle { font-size: 16px; font-weight: 600; color: #2d3748; margin-bottom: 8px; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th { background: #2c5282; color: white; font-weight: 600; padding: 10px 8px; text-align: left; font-size: 10px; }
        td { padding: 8px; border-bottom: 1px solid #e2e8f0; font-size: 10px; }
        tr:nth-child(even) { background: #f7fafc; }
        tr:hover { background: #edf2f7; }
        .footer { margin-top: 25px; padding-top: 15px; border-top: 1px solid #e2e8f0; text-align: center; font-size: 9px; color: #718096; }
    </style>
</head>
<body>
    <div class='header'>
        <div class='title'>Lahore Gymkhana Club</div>
        <div class='subtitle'>" + lblAlertHeader.Text + @"</div>
    </div>
    <table>
        <thead>
            <tr>
                <th>Alert Type</th>
                <th>Message</th>
                <th>Category</th>
            </tr>
        </thead>
        <tbody>");

        foreach (DataRow row in dt.Rows)
        {
            html.Append("<tr>");
            html.Append("<td>" + Server.HtmlEncode(row["Title"].ToString()) + "</td>");
            html.Append("<td>" + row["Message"].ToString() + "</td>"); // Message may contain safe HTML like <b>
            html.Append("<td>" + Server.HtmlEncode(row["Type"].ToString()) + "</td>");
            html.Append("</tr>");
        }

        html.Append(@"
        </tbody>
    </table>
    <div class='footer'>
        <p>Generated on: " + generatedDate + @" | Total Records: " + dt.Rows.Count + @"</p>
        <br/>
        <p><strong>Powered by MegaPlus Technologies</strong></p>
    </div>
    <script>window.onload = function() { window.print(); }</script>
</body>
</html>");

        Response.Clear();
        Response.ContentType = "text/html";
        Response.Write(html.ToString());
        Response.End();
    }

    public override void VerifyRenderingInServerForm(Control control)
    {
        // Required for GridView export
    }
}

