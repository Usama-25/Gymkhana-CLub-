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
    public partial class InterviewList : Page
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
                txtFromDate.Text = "";
                txtToDate.Text = "";
                LoadMembershipTypes();
            }
        }

        private void LoadMembershipTypes()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT DISTINCT MembershipType FROM ApplicationFForm WHERE MembershipType IS NOT NULL AND MembershipType <> '' ORDER BY MembershipType", conn))
                {
                    cmd.CommandType = CommandType.Text;
                    conn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    ddlType.Items.Clear();
                    ddlType.Items.Add(new ListItem("All Membership Types", ""));
                    while (dr.Read())
                    {
                        ddlType.Items.Add(new ListItem(dr[0].ToString(), dr[0].ToString()));
                    }
                }
            }
        }

        protected void btnGenerate_Click(object sender, EventArgs e)
        {
            BindGrid();
        }

        private void BindGrid()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                bool hasDateFilter = !string.IsNullOrEmpty(txtFromDate.Text) && !string.IsNullOrEmpty(txtToDate.Text);

                using (SqlCommand cmd = new SqlCommand("usp_GetInterviewListReport", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    if (hasDateFilter)
                    {
                        cmd.Parameters.Add("@Start", SqlDbType.NVarChar, 50).Value = txtFromDate.Text;
                        cmd.Parameters.Add("@End", SqlDbType.NVarChar, 50).Value = txtToDate.Text;
                    }
                    if (!string.IsNullOrEmpty(ddlType.SelectedValue))
                    {
                        cmd.Parameters.Add("@Type", SqlDbType.NVarChar, 50).Value = ddlType.SelectedValue;
                    }

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvInterviewList.DataSource = dt;
                    gvInterviewList.DataBind();
                }
            }
        }

        private DataTable GetReportData()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                bool hasDateFilter = !string.IsNullOrEmpty(txtFromDate.Text) && !string.IsNullOrEmpty(txtToDate.Text);
                using (SqlCommand cmd = new SqlCommand("usp_GetInterviewListReport", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    if (hasDateFilter)
                    {
                        cmd.Parameters.Add("@Start", SqlDbType.NVarChar, 50).Value = txtFromDate.Text;
                        cmd.Parameters.Add("@End", SqlDbType.NVarChar, 50).Value = txtToDate.Text;
                    }
                    if (!string.IsNullOrEmpty(ddlType.SelectedValue))
                    {
                        cmd.Parameters.Add("@Type", SqlDbType.NVarChar, 50).Value = ddlType.SelectedValue;
                    }

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                }
            }
            return dt;
        }

        protected void btnPrintPDF_Click(object sender, EventArgs e)
        {
            DataTable dt = GetReportData();
            string fromDate = !string.IsNullOrEmpty(txtFromDate.Text) ? DateTime.Parse(txtFromDate.Text).ToString("dd-MMM-yyyy") : "All";
            string toDate = !string.IsNullOrEmpty(txtToDate.Text) ? DateTime.Parse(txtToDate.Text).ToString("dd-MMM-yyyy") : "All";
            string type = string.IsNullOrEmpty(ddlType.SelectedValue) ? "All Types" : ddlType.SelectedItem.Text;

            StringBuilder html = new StringBuilder();
            html.Append(@"<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>Shortlisted Applicants Report</title>
    <style>
        @page { size: A4 landscape; margin: 10mm; }
        @media print { body { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; } }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', Arial, sans-serif; font-size: 10px; color: #1a202c; background: #fff; padding: 10px; }
        .header { text-align: center; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 2px solid #2c5282; }
        .logo { width: 80px; height: 80px; margin-bottom: 5px; }
        .title { font-size: 18px; font-weight: bold; color: #1a365d; margin-bottom: 3px; }
        .subtitle { font-size: 14px; font-weight: 600; color: #2d3748; margin-bottom: 5px; }
        .meta { font-size: 10px; color: #718096; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th { background: #2c5282; color: white; font-weight: 600; padding: 8px 6px; text-align: left; font-size: 9px; border: 1px solid #cbd5e1; }
        td { padding: 8px 6px; border: 1px solid #cbd5e1; font-size: 9px; vertical-align: top; }
        tr:nth-child(even) { background: #f8fafc; }
        .text-right { text-align: right; }
        .footer { margin-top: 20px; padding-top: 10px; border-top: 1px solid #e2e8f0; text-align: center; font-size: 8px; color: #a0aec0; }
    </style>
</head>
<body>
    <div class='header'>
        <img src='");
            html.Append(ResolveUrl("~/MemberShipModule/assets/images/report_logo.png"));
            html.Append(@"' alt='Logo' class='logo' onerror=""this.style.display='none'"">
        <div class='title'>Lahore Gymkhana Club</div>
        <div class='subtitle'>Shortlisted Applicants Report</div>
        <div class='meta'>Period: " + fromDate + " to " + toDate + " | Membership Type: " + type + @"</div>
    </div>
    <table>
        <thead>
            <tr>
                <th style='width: 4%;'>S. NO.</th>
                <th style='width: 18%;'>NAME</th>
                <th style='width: 20%;'>PROFESSION / STATUS</th>
                <th style='width: 9%;'>INCOME</th>
                <th style='width: 16%;'>PROPOSER</th>
                <th style='width: 16%;'>SECONDER</th>
                <th style='width: 9%;'>AMOUNT DEPOSITED</th>
                <th style='width: 8%;'>DATE OF APPL.</th>
            </tr>
        </thead>
        <tbody>");

            if (dt.Rows.Count > 0)
            {
                int counter = 1;
                foreach (DataRow row in dt.Rows)
                {
                    string applicantName = row["ApplicantName"] != DBNull.Value ? row["ApplicantName"].ToString() : "-";
                    
                    // Profession Status
                    string profession = row["Profession"] != DBNull.Value ? row["Profession"].ToString() : "";
                    string companyName = row["CompanyName"] != DBNull.Value ? row["CompanyName"].ToString() : "";
                    string designation = row["Designation"] != DBNull.Value ? row["Designation"].ToString() : "";
                    string profStatus = Server.HtmlEncode(profession);
                    if (!string.IsNullOrEmpty(companyName) && companyName != ".")
                    {
                        profStatus += "<br/><small style='color: #475569;'>" + Server.HtmlEncode(companyName);
                        if (!string.IsNullOrEmpty(designation) && designation != ".")
                        {
                            profStatus += " (" + Server.HtmlEncode(designation) + ")";
                        }
                        profStatus += "</small>";
                    }
                    else if (!string.IsNullOrEmpty(designation) && designation != ".")
                    {
                        profStatus += "<br/><small style='color: #475569;'>" + Server.HtmlEncode(designation) + "</small>";
                    }

                    // Income
                    string income = row["MonthlyIncome"] != DBNull.Value && Convert.ToDecimal(row["MonthlyIncome"]) > 0
                        ? Convert.ToDecimal(row["MonthlyIncome"]).ToString("#,##0") + "/-"
                        : "00/-";

                    // Proposer
                    string proposerName = row["ProposerName"] != DBNull.Value ? row["ProposerName"].ToString() : "";
                    string proposerMemberNo = row["ProposerMemberNo"] != DBNull.Value ? row["ProposerMemberNo"].ToString() : "";
                    string proposerCell = Server.HtmlEncode(proposerName);
                    if (!string.IsNullOrEmpty(proposerMemberNo))
                    {
                        proposerCell += "<br/><small style='color: #475569;'>(" + Server.HtmlEncode(proposerMemberNo) + ")</small>";
                    }

                    // Seconder
                    string seconderName = row["SeconderName"] != DBNull.Value ? row["SeconderName"].ToString() : "";
                    string seconderMemberNo = row["SeconderMemberNo"] != DBNull.Value ? row["SeconderMemberNo"].ToString() : "";
                    string seconderCell = Server.HtmlEncode(seconderName);
                    if (!string.IsNullOrEmpty(seconderMemberNo))
                    {
                        seconderCell += "<br/><small style='color: #475569;'>(" + Server.HtmlEncode(seconderMemberNo) + ")</small>";
                    }

                    // Amount Deposited
                    string amountDeposited = row["MFee"] != DBNull.Value && Convert.ToDecimal(row["MFee"]) > 0
                        ? Convert.ToDecimal(row["MFee"]).ToString("#,##0") + "/-"
                        : "00/-";

                    // Date of Appl.
                    string dateOfAppl = row["CreatedAt"] != DBNull.Value
                        ? Convert.ToDateTime(row["CreatedAt"]).ToString("dd-MM-yyyy")
                        : "-";

                    html.Append("<tr>");
                    html.Append("<td>" + string.Format("{0:00}", counter) + "</td>");
                    html.Append("<td>" + Server.HtmlEncode(applicantName) + "</td>");
                    html.Append("<td>" + profStatus + "</td>");
                    html.Append("<td>" + income + "</td>");
                    html.Append("<td>" + proposerCell + "</td>");
                    html.Append("<td>" + seconderCell + "</td>");
                    html.Append("<td>" + amountDeposited + "</td>");
                    html.Append("<td>" + dateOfAppl + "</td>");
                    html.Append("</tr>");
                    counter++;
                }
            }
            else
            {
                html.Append("<tr><td colspan='8' style='text-align:center; padding: 20px;'>No shortlisted applicants found.</td></tr>");
            }

            html.Append(@"
        </tbody>
    </table>
    <div class='footer'>
        <p>Report Generated on: " + DateTime.Now.ToString("dd MMM yyyy HH:mm") + @"</p>
        <p>&copy; Lahore Gymkhana Club - MemberShip Module</p>
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
            Response.AddHeader("content-disposition", "attachment;filename=ShortlistedApplicants.xls");
            Response.Charset = "";
            Response.ContentType = "application/vnd.ms-excel";

            using (StringWriter sw = new StringWriter())
            {
                HtmlTextWriter hw = new HtmlTextWriter(sw);
                gvInterviewList.RenderControl(hw);
                Response.Write(sw.ToString());
                Response.End();
            }
        }

        public override void VerifyRenderingInServerForm(Control control) { }
    }
}
