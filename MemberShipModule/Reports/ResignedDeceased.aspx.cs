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
    public partial class ResignedDeceased : Page
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
                using (SqlCommand cmd = new SqlCommand("usp_GetResignedDeceasedMembersReport", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvResignedDeceased.DataSource = dt;
                    gvResignedDeceased.DataBind();
                }
            }
        }

        private DataTable GetReportData()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("usp_GetResignedDeceasedMembersReport", conn))
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
    <title>Resigned / Deceased Members Report</title>
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
        th { background: #744210; color: white; font-weight: 600; padding: 10px 8px; text-align: left; font-size: 10px; }
        td { padding: 8px; border-bottom: 1px solid #e2e8f0; font-size: 10px; }
        tr:nth-child(even) { background: #fffaf0; }
        tr:hover { background: #fefcbf; }
        .member-no { font-weight: 600; color: #2c5282; }
        .status { font-weight: 600; color: #c53030; }
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
        <div class='subtitle'>Resigned / Deceased Members Report</div>
    </div>
    <table>
        <thead>
            <tr>
                <th>Member No</th>
                <th>Member Name</th>
                <th>Category</th>
                <th>Status</th>
                <th>Effective Date</th>
            </tr>
        </thead>
        <tbody>");

            if (dt.Rows.Count > 0)
            {
                foreach (DataRow row in dt.Rows)
                {
                    string lastUpdated = row["LastUpdated"] != DBNull.Value 
                        ? Convert.ToDateTime(row["LastUpdated"]).ToString("yyyy-MM-dd") : "-";

                    string memberNo = row["MemberNo"] != DBNull.Value ? row["MemberNo"].ToString() : "-";
                    string memberName = row["MemberName"] != DBNull.Value ? row["MemberName"].ToString() : "-";
                    string memberCategory = row["MemberCategory"] != DBNull.Value ? row["MemberCategory"].ToString() : "-";
                    string accountStatus = row["AccountStatus"] != DBNull.Value ? row["AccountStatus"].ToString() : "-";

                    html.Append("<tr>");
                    html.Append("<td class='member-no'>" + Server.HtmlEncode(memberNo) + "</td>");
                    html.Append("<td>" + Server.HtmlEncode(memberName) + "</td>");
                    html.Append("<td>" + Server.HtmlEncode(memberCategory) + "</td>");
                    html.Append("<td class='status'>" + Server.HtmlEncode(accountStatus) + "</td>");
                    html.Append("<td>" + lastUpdated + "</td>");
                    html.Append("</tr>");
                }
            }
            else
            {
                html.Append("<tr><td colspan='5' class='no-data'>No resigned or deceased members found.</td></tr>");
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
            Response.AddHeader("content-disposition", "attachment;filename=ResignedDeceasedReport.xls");
            Response.Charset = "";
            Response.ContentType = "application/vnd.ms-excel";
            
            using (StringWriter sw = new StringWriter())
            {
                HtmlTextWriter hw = new HtmlTextWriter(sw);
                gvResignedDeceased.AllowPaging = false;
                this.BindGrid();
                gvResignedDeceased.RenderControl(hw);
                Response.Write(sw.ToString());
                Response.End();
            }
        }

        public override void VerifyRenderingInServerForm(Control control)
        {
        }
    }
}
