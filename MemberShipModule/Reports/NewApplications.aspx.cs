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
    public partial class NewApplications : Page
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
                // Fields start empty; no data is loaded until filter button is pressed
                txtFromDate.Text = "";
                txtToDate.Text = "";
            }
        }

        private void BindGrid()
        {
            DataTable dt = GetReportData();
            gvApplications.DataSource = dt;
            gvApplications.DataBind();
            UpdateStats(dt);
        }

        private void UpdateStats(DataTable dt)
        {
            litTotalAdmissions.Text = dt.Rows.Count.ToString();

            if (!string.IsNullOrEmpty(txtFromDate.Text) && !string.IsNullOrEmpty(txtToDate.Text))
                litPeriod.Text = string.Format("{0:dd MMM} - {1:dd MMM yyyy}", DateTime.Parse(txtFromDate.Text), DateTime.Parse(txtToDate.Text));
            else
                litPeriod.Text = "All Pending Applications";
        }

        protected void gvApplications_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                string status = DataBinder.Eval(e.Row.DataItem, "Status").ToString();
                Literal litStatus = (Literal)e.Row.FindControl("litStatus");

                if (litStatus != null)
                {
                    string badgeBg = "#fef9c3"; // Pending/Default
                    string badgeColor = "#854d0e";

                    if (status.ToLower().Contains("active") || status.ToLower().Contains("approved"))
                    {
                        badgeBg = "#dcfce7";
                        badgeColor = "#166534";
                    }
                    else if (status.ToLower().Contains("inactive") || status.ToLower().Contains("rejected") || status.ToLower().Contains("closed"))
                    {
                        badgeBg = "#fee2e2";
                        badgeColor = "#991b1b";
                    }

                    litStatus.Text = string.Format("<span style='display: inline-flex; align-items: center; padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 600; text-transform: capitalize; background: {0}; color: {1};'>{2}</span>", badgeBg, badgeColor, status);
                }
            }
        }

        private DataTable GetReportData()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                bool hasFilter = !string.IsNullOrEmpty(txtFromDate.Text) && !string.IsNullOrEmpty(txtToDate.Text);

                using (SqlCommand cmd = new SqlCommand("usp_GetNewApplicationsReport", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@HasFilter", SqlDbType.Bit).Value = hasFilter;

                    if (hasFilter)
                    {
                        cmd.Parameters.Add("@Start", SqlDbType.NVarChar, 50).Value = txtFromDate.Text;
                        cmd.Parameters.Add("@End", SqlDbType.NVarChar, 50).Value = txtToDate.Text;
                    }

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                }
            }
            return dt;
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            BindGrid();
        }

        protected void btnPrintPDF_Click(object sender, EventArgs e)
        {
            DataTable dt = GetReportData();
            string fromDate = !string.IsNullOrEmpty(txtFromDate.Text) ? DateTime.Parse(txtFromDate.Text).ToString("dd-MMM-yyyy") : "All";
            string toDate = !string.IsNullOrEmpty(txtToDate.Text) ? DateTime.Parse(txtToDate.Text).ToString("dd-MMM-yyyy") : "All";
            string generatedDate = DateTime.Now.ToString("dd-MMM-yyyy HH:mm");

            // Build clean HTML report
            StringBuilder html = new StringBuilder();
            html.Append(@"<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>New Applications Report</title>
    <style>
        @page { size: A4; margin: 15mm; }
        @media print { body { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; } }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', Arial, sans-serif; font-size: 11px; color: #1a202c; background: #fff; padding: 20px; }
        .header { text-align: center; margin-bottom: 25px; padding-bottom: 15px; border-bottom: 2px solid #2c5282; }
        .logo { width: 100px; height: 100px; margin-bottom: 10px; }
        .title { font-size: 20px; font-weight: bold; color: #1a365d; margin-bottom: 5px; }
        .subtitle { font-size: 16px; font-weight: 600; color: #2d3748; margin-bottom: 8px; }
        .date-range { font-size: 11px; color: #718096; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th { background: #2c5282; color: white; font-weight: 600; padding: 10px 8px; text-align: left; font-size: 10px; }
        td { padding: 8px; border-bottom: 1px solid #e2e8f0; font-size: 10px; }
        tr:nth-child(even) { background: #f7fafc; }
        tr:hover { background: #edf2f7; }
        .id-col { font-weight: 600; color: #2c5282; }
        .status { font-weight: 600; }
        .footer { margin-top: 25px; padding-top: 15px; border-top: 1px solid #e2e8f0; text-align: center; font-size: 9px; color: #718096; }
        .no-data { text-align: center; padding: 40px; color: #718096; font-style: italic; }
    </style>
</head>
<body>
    <div class='header'>
        <div class='title'>Lahore Gymkhana Club</div>
        <div class='subtitle'>New Membership Applications Report</div>
        <div class='date-range'>Filter: " + (fromDate == "All" ? "All Pending" : fromDate + " to " + toDate) + @"</div>
    </div>
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Applicant Name</th>
                <th>Category / Class</th>
                <th>Submission Date</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>");

            if (dt.Rows.Count > 0)
            {
                foreach (DataRow row in dt.Rows)
                {
                    string createdOn = row["CreatedOn"] != DBNull.Value
                        ? Convert.ToDateTime(row["CreatedOn"]).ToString("dd-MMM-yyyy") : "-";

                    string applicantID = row["ApplicantID"] != DBNull.Value ? row["ApplicantID"].ToString() : "-";
                    string applicantName = row["ApplicantName"] != DBNull.Value ? row["ApplicantName"].ToString() : "-";
                    string fatherName = row["FatherName"] != DBNull.Value ? row["FatherName"].ToString() : "";
                    string membershipType = row["MembershipType"] != DBNull.Value ? row["MembershipType"].ToString() : "-";
                    string membershipClass = row["Membership_class"] != DBNull.Value ? row["Membership_class"].ToString() : "-";
                    string status = row["Status"] != DBNull.Value ? row["Status"].ToString() : "-";

                    html.Append("<tr>");
                    html.Append("<td class='id-col'>" + Server.HtmlEncode(applicantID) + "</td>");
                    html.Append("<td>" + Server.HtmlEncode(applicantName) + "<br/><small>S/O: " + Server.HtmlEncode(fatherName) + "</small></td>");
                    html.Append("<td>" + Server.HtmlEncode(membershipType) + " (" + Server.HtmlEncode(membershipClass) + ")</td>");
                    html.Append("<td>" + createdOn + "</td>");
                    html.Append("<td class='status'>" + Server.HtmlEncode(status) + "</td>");
                    html.Append("</tr>");
                }
            }
            else
            {
                html.Append("<tr><td colspan='5' class='no-data'>No pending applications found for the selected criteria.</td></tr>");
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
            Response.AddHeader("content-disposition", "attachment;filename=PendingApplicationsReport.xls");
            Response.Charset = "";
            Response.ContentType = "application/vnd.ms-excel";

            using (StringWriter sw = new StringWriter())
            {
                HtmlTextWriter hw = new HtmlTextWriter(sw);
                gvApplications.AllowPaging = false;
                this.BindGrid();
                gvApplications.RenderControl(hw);
                Response.Write(sw.ToString());
                Response.End();
            }
        }

        public override void VerifyRenderingInServerForm(Control control) { }
    }
}
