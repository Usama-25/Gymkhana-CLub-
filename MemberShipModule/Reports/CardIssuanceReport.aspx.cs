using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Text;

namespace Membership.Reports
{
    public partial class CardIssuanceReport : Page
    {
        private string connectionString
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
                BindGrid();
            }
        }

        private void BindGrid()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("usp_GetCardIssuanceReport", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvCardIssuance.DataSource = dt;
                    gvCardIssuance.DataBind();
                }
            }
        }

        private DataTable GetReportData()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("usp_GetCardIssuanceReport", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                }
            }
            return dt;
        }

        protected void btnPrintPDF_Click(object sender, EventArgs e)
        {
            DataTable dt = GetReportData();
            string generatedDate = DateTime.Now.ToString("dd-MMM-yyyy HH:mm");

            StringBuilder html = new StringBuilder();
            html.Append(@"<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>Card Issuance Report</title>
    <style>
        @page { size: A4; margin: 15mm; }
        @media print { body { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; } }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', Arial, sans-serif; font-size: 11px; color: #1a202c; background: #fff; padding: 20px; }
        .header { text-align: center; margin-bottom: 25px; padding-bottom: 15px; border-bottom: 2px solid #2c5282; }
        .logo { width: 100px; height: 100px; margin-bottom: 10px; }
        .title { font-size: 20px; font-weight: bold; color: #1a365d; margin-bottom: 5px; }
        .subtitle { font-size: 16px; font-weight: 600; color: #2d3748; margin-bottom: 8px; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th { background: #2c5282; color: white; font-weight: 600; padding: 10px 8px; text-align: left; font-size: 10px; }
        td { padding: 8px; border-bottom: 1px solid #e2e8f0; font-size: 10px; }
        tr:nth-child(even) { background: #f7fafc; }
        tr:hover { background: #edf2f7; }
        .member-no { font-weight: 600; color: #2c5282; }
        .card-no { font-family: monospace; color: #805ad5; }
        .footer { margin-top: 25px; padding-top: 15px; border-top: 1px solid #e2e8f0; text-align: center; font-size: 9px; color: #718096; }
        .no-data { text-align: center; padding: 40px; color: #718096; font-style: italic; }
    </style>
</head>
<body>
    <div class='header'>
        <img src='");
            html.Append(ResolveUrl("~/assets/images/report_logo.png"));
            html.Append(@"' alt='Logo' class='logo' onerror=""this.style.display='none'"">
        <div class='title'>Lahore Gymkhana Club</div>
        <div class='subtitle'>Card Issuance Report</div>
    </div>
    <table>
        <thead>
            <tr>
                <th>Member No</th>
                <th>Member Name</th>
                <th>Card No</th>
                <th>Issue Date</th>
                <th>Expiry Date</th>
                <th>RFID Tag</th>
            </tr>
        </thead>
        <tbody>");

            if (dt.Rows.Count > 0)
            {
                foreach (DataRow row in dt.Rows)
                {
                    string issueDate = row["CardIssueDate"] != DBNull.Value 
                        ? Convert.ToDateTime(row["CardIssueDate"]).ToString("yyyy-MM-dd") : "-";
                    string expiryDate = row["CardExpiryDate"] != DBNull.Value 
                        ? Convert.ToDateTime(row["CardExpiryDate"]).ToString("yyyy-MM-dd") : "-";

                    string memberNo = row["MemberNo"] != DBNull.Value ? row["MemberNo"].ToString() : "-";
                    string memberName = row["MemberName"] != DBNull.Value ? row["MemberName"].ToString() : "-";
                    string cardNo = row["CardNo"] != DBNull.Value ? row["CardNo"].ToString() : "-";
                    string rfid = row["RFID"] != DBNull.Value ? row["RFID"].ToString() : "-";

                    html.Append("<tr>");
                    html.Append("<td class='member-no'>" + Server.HtmlEncode(memberNo) + "</td>");
                    html.Append("<td>" + Server.HtmlEncode(memberName) + "</td>");
                    html.Append("<td class='card-no'>" + Server.HtmlEncode(cardNo) + "</td>");
                    html.Append("<td>" + issueDate + "</td>");
                    html.Append("<td>" + expiryDate + "</td>");
                    html.Append("<td style='font-family: monospace;'>" + Server.HtmlEncode(rfid) + "</td>");
                    html.Append("</tr>");
                }
            }
            else
            {
                html.Append("<tr><td colspan='6' class='no-data'>No card issuance records found.</td></tr>");
            }

            html.Append(@"
        </tbody>
    </table>
    <div class='footer'>
        <p>Generated on: " + generatedDate + @" | Total Records: " + dt.Rows.Count + @"</p>
        <br/>
        <p><strong>Powered by MegaPlus Technologies</strong></p>
        <p>&copy; 2024 All rights reserved by MegaPlus</p>
    </div>
    <script>window.onload = function() { window.print(); }</script>
</body>
</html>");

            Response.Clear();
            Response.ContentType = "text/html";
            Response.Write(html.ToString());
            Response.End();
        }

        protected void btnExport_Click(object sender, EventArgs e)
        {
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=CardIssuanceReport.xls");
            Response.Charset = "";
            Response.ContentType = "application/vnd.ms-excel";
            
            using (StringWriter sw = new StringWriter())
            {
                HtmlTextWriter hw = new HtmlTextWriter(sw);
                gvCardIssuance.AllowPaging = false;
                this.BindGrid();
                gvCardIssuance.RenderControl(hw);
                Response.Write(sw.ToString());
                Response.End();
            }
        }

        public override void VerifyRenderingInServerForm(Control control)
        {
        }
    }
}
