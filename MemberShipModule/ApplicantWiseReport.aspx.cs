using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Text;
using System.Collections.Generic;

namespace Membership
{
    public partial class ApplicantWiseReport : Page
    {
        private string m_prevApplicantNo = null;
        private int m_applicantSrCounter = 0;

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
                BindReportGrid();
            }
        }

        private DataTable GetReportData()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetApplicantWiseReceiptReport", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    int applicantNo = 0;
                    if (txtApplicantNo != null && !string.IsNullOrEmpty(txtApplicantNo.Text.Trim()) && int.TryParse(txtApplicantNo.Text.Trim(), out applicantNo))
                    {
                        cmd.Parameters.Add("@ApplicantNo", SqlDbType.Int).Value = applicantNo;
                    }
                    else
                    {
                        cmd.Parameters.Add("@ApplicantNo", SqlDbType.Int).Value = DBNull.Value;
                    }

                    cmd.Parameters.Add("@ApplicantName", SqlDbType.NVarChar, 200).Value = 
                        (txtApplicantName != null && !string.IsNullOrEmpty(txtApplicantName.Text.Trim())) ? (object)txtApplicantName.Text.Trim() : DBNull.Value;

                    cmd.Parameters.Add("@CNIC", SqlDbType.NVarChar, 50).Value = 
                        (txtCNIC != null && !string.IsNullOrEmpty(txtCNIC.Text.Trim())) ? (object)txtCNIC.Text.Trim() : DBNull.Value;

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                }
            }
            return dt;
        }

        private void BindReportGrid()
        {
            m_prevApplicantNo = null;
            m_applicantSrCounter = 0;

            DataTable dt = GetReportData();
            if (gvReport != null)
            {
                gvReport.DataSource = dt;
                gvReport.DataBind();
            }
            UpdateMetrics(dt);
        }

        private void CalculateTotals(DataTable dt, out decimal totalFormFee, out decimal totalMFee, out decimal totalPaid, out decimal totalAmount, out decimal totalBalance, out int totalApplicants)
        {
            totalFormFee = 0;
            totalMFee = 0;
            totalPaid = 0;
            totalAmount = 0;
            totalBalance = 0;

            HashSet<string> uniqueApplicants = new HashSet<string>();
            Dictionary<string, decimal> applicantTotalAmount = new Dictionary<string, decimal>();
            Dictionary<string, decimal> applicantFinalBalance = new Dictionary<string, decimal>();

            if (dt != null && dt.Rows.Count > 0)
            {
                foreach (DataRow row in dt.Rows)
                {
                    string appNo = row["ApplicantNo"] != DBNull.Value ? row["ApplicantNo"].ToString() : "";

                    decimal fFee = row["FormFee"] != DBNull.Value ? Convert.ToDecimal(row["FormFee"]) : 0;
                    decimal mFee = row["AdvanceOrMembershipFee"] != DBNull.Value ? Convert.ToDecimal(row["AdvanceOrMembershipFee"]) : 0;
                    decimal paid = row["ReceiptPaidAmount"] != DBNull.Value ? Convert.ToDecimal(row["ReceiptPaidAmount"]) : 0;
                    decimal tAmt = row["TotalAmount"] != DBNull.Value ? Convert.ToDecimal(row["TotalAmount"]) : 0;
                    decimal bal = row["BalanceRemaining"] != DBNull.Value ? Convert.ToDecimal(row["BalanceRemaining"]) : 0;

                    totalFormFee += fFee;
                    totalMFee += mFee;
                    totalPaid += paid;

                    if (!string.IsNullOrEmpty(appNo))
                    {
                        if (!uniqueApplicants.Contains(appNo))
                        {
                            uniqueApplicants.Add(appNo);
                            applicantTotalAmount[appNo] = tAmt;
                            applicantFinalBalance[appNo] = bal;
                        }
                    }
                }

                foreach (KeyValuePair<string, decimal> kvp in applicantTotalAmount)
                {
                    totalAmount += kvp.Value;
                }

                foreach (KeyValuePair<string, decimal> kvp in applicantFinalBalance)
                {
                    totalBalance += kvp.Value;
                }
            }

            totalApplicants = uniqueApplicants.Count > 0 ? uniqueApplicants.Count : (dt != null ? dt.Rows.Count : 0);
        }

        private void UpdateMetrics(DataTable dt)
        {
            decimal totalFormFee, totalMFee, totalPaid, totalAmount, totalBalance;
            int totalApplicants;
            CalculateTotals(dt, out totalFormFee, out totalMFee, out totalPaid, out totalAmount, out totalBalance, out totalApplicants);

            if (litTotalApplicants != null) litTotalApplicants.Text = totalApplicants.ToString("N0");
            if (litTotalFormFee != null) litTotalFormFee.Text = totalFormFee.ToString("N0");
            if (litTotalMFee != null) litTotalMFee.Text = totalMFee.ToString("N0");
            if (litTotalPaid != null) litTotalPaid.Text = totalPaid.ToString("N0");
            if (litTotalBalance != null) litTotalBalance.Text = totalBalance.ToString("N0");
        }

        protected void gvReport_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            if (gvReport != null)
            {
                gvReport.PageIndex = e.NewPageIndex;
                BindReportGrid();
            }
        }

        protected void gvReport_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                DataRowView drv = (DataRowView)e.Row.DataItem;

                string currentAppNo = drv["ApplicantNo"] != DBNull.Value ? drv["ApplicantNo"].ToString() : "";
                bool isFirstRowForApplicant = (currentAppNo != m_prevApplicantNo);

                if (isFirstRowForApplicant)
                {
                    m_applicantSrCounter++;
                    m_prevApplicantNo = currentAppNo;
                    e.Row.Cells[0].Text = m_applicantSrCounter.ToString();
                    e.Row.Attributes["style"] = "border-top: 2px solid #cbd5e1;";
                }
                else
                {
                    e.Row.Cells[0].Text = "&nbsp;";
                    e.Row.Cells[1].Text = "&nbsp;";
                    e.Row.Cells[2].Text = "&nbsp;";
                    e.Row.Attributes["style"] = "border-top: 1px dashed #e2e8f0;";
                }

                // Format Receipt Details
                Literal litAttachedReceipts = (Literal)e.Row.FindControl("litAttachedReceipts");
                if (litAttachedReceipts != null)
                {
                    string rcptNo = drv["ReceiptNo"] != DBNull.Value ? drv["ReceiptNo"].ToString() : "No Receipt";
                    string rcptDateStr = "-";
                    DateTime rDate;
                    if (drv["ReceiptDate"] != DBNull.Value && DateTime.TryParse(drv["ReceiptDate"].ToString(), out rDate))
                    {
                        rcptDateStr = rDate.ToString("dd-MMM-yyyy");
                    }
                    decimal paidAmount = drv["ReceiptPaidAmount"] != DBNull.Value ? Convert.ToDecimal(drv["ReceiptPaidAmount"]) : 0;

                    if (rcptNo.Equals("No Receipt", StringComparison.OrdinalIgnoreCase) || string.IsNullOrEmpty(rcptNo))
                    {
                        litAttachedReceipts.Text = "<span style='color: #94a3b8; font-style: italic;'>No Receipt</span>";
                    }
                    else
                    {
                        StringBuilder sb = new StringBuilder();
                        sb.Append(string.Format("<span class='receipt-chip'><i class='fas fa-ticket-alt' style='color:#c5a059; margin-right:4px;'></i>{0}</span>", Server.HtmlEncode(rcptNo)));
                        sb.Append(string.Format("<br/><span style='font-size:0.78rem; color:#64748b;'>Date: {0} | Paid: <strong style='color:#16a34a;'>Rs. {1:N0}</strong></span>", rcptDateStr, paidAmount));
                        litAttachedReceipts.Text = sb.ToString();
                    }
                }

                // Format Balance / Remaining
                Literal litBalance = (Literal)e.Row.FindControl("litBalance");
                if (litBalance != null)
                {
                    decimal balance = drv["BalanceRemaining"] != DBNull.Value ? Convert.ToDecimal(drv["BalanceRemaining"]) : 0;
                    if (balance <= 0)
                    {
                        litBalance.Text = "<span class='badge-balance-zero'>Paid (Rs. 0)</span>";
                    }
                    else
                    {
                        litBalance.Text = string.Format("<span class='badge-balance-pending'>Rs. {0:N0}</span>", balance);
                    }
                }
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            if (gvReport != null) gvReport.PageIndex = 0;
            BindReportGrid();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            if (txtApplicantNo != null) txtApplicantNo.Text = "";
            if (txtApplicantName != null) txtApplicantName.Text = "";
            if (txtCNIC != null) txtCNIC.Text = "";
            if (gvReport != null) gvReport.PageIndex = 0;
            BindReportGrid();
        }

        protected void btnPrintReport_Click(object sender, EventArgs e)
        {
            DataTable dt = GetReportData();
            string generatedDate = DateTime.Now.ToString("dd-MMM-yyyy HH:mm");

            decimal sumFormFee, sumMFee, sumTotalPaid, sumTotalAmount, sumBalance;
            int totalApplicants;
            CalculateTotals(dt, out sumFormFee, out sumMFee, out sumTotalPaid, out sumTotalAmount, out sumBalance, out totalApplicants);

            StringBuilder html = new StringBuilder();
            html.Append(@"<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>Applicant-Wise Receipt Report</title>
    <style>
        @page { size: A4 landscape; margin: 12mm; }
        @media print { body { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; } }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', Arial, sans-serif; font-size: 11px; color: #0f172a; background: #fff; padding: 15px; }
        .header { text-align: center; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 2px solid #0f1e36; }
        .title { font-size: 22px; font-weight: bold; color: #0f1e36; margin-bottom: 4px; }
        .subtitle { font-size: 14px; font-weight: 600; color: #c5a059; margin-bottom: 6px; }
        .meta-info { font-size: 11px; color: #64748b; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th { background: #0f1e36; color: #ffffff; font-weight: 700; padding: 8px 6px; text-align: left; font-size: 10px; border: 1px solid #0f1e36; }
        td { padding: 7px 6px; border-bottom: 1px solid #cbd5e1; border-right: 1px solid #f1f5f9; font-size: 10px; vertical-align: top; }
        tr:nth-child(even) { background: #f8fafc; }
        .text-right { text-align: right; }
        .text-center { text-align: center; }
        .bold { font-weight: bold; }
        .balance-pending { color: #dc2626; font-weight: bold; }
        .balance-cleared { color: #16a34a; font-weight: bold; }
        .total-row { background: #e2e8f0 !important; font-weight: bold; font-size: 11px; }
        .footer { margin-top: 25px; padding-top: 12px; border-top: 1px solid #cbd5e1; display: flex; justify-content: space-between; font-size: 10px; color: #64748b; }
    </style>
</head>
<body>
    <div class='header'>
        <div class='title'>Lahore Gymkhana Club</div>
        <div class='subtitle'>Applicant-Wise Receipt & Balance Report</div>
        <div class='meta-info'>Generated On: " + generatedDate + @" | Filter: Applicant Wise</div>
    </div>

    <table>
        <thead>
            <tr>
                <th style='width: 40px; text-align: center;'>Sr#</th>
                <th style='width: 80px;'>ApplicantNo</th>
                <th>Applicant Name</th>
                <th style='width: 180px;'>Receipt Details</th>
                <th style='width: 90px;' class='text-right'>Form Fee</th>
                <th style='width: 130px;' class='text-right'>Advance / Membership Fee</th>
                <th style='width: 110px;' class='text-right'>Total Amount</th>
                <th style='width: 110px;' class='text-right'>Balance / Remaining</th>
            </tr>
        </thead>
        <tbody>");

            string printPrevAppNo = null;
            int printSrCounter = 0;

            if (dt.Rows.Count > 0)
            {
                foreach (DataRow row in dt.Rows)
                {
                    string appNo = row["ApplicantNo"] != DBNull.Value ? row["ApplicantNo"].ToString() : "";
                    bool isFirstForApp = (appNo != printPrevAppNo);

                    string srStr = "";
                    string appNoHtml = "";
                    string appNameHtml = "";
                    string rowBorderStyle = "border-top: 1px dashed #e2e8f0;";

                    if (isFirstForApp)
                    {
                        printSrCounter++;
                        printPrevAppNo = appNo;
                        srStr = printSrCounter.ToString();
                        appNoHtml = "<span class='bold' style='color:#c5a059;'>" + Server.HtmlEncode(appNo) + "</span>";
                        appNameHtml = Server.HtmlEncode(row["ApplicantName"].ToString()) + "<br/><small style='color:#64748b;'>S/O: " + Server.HtmlEncode(row["FatherName"].ToString()) + " | CNIC: " + Server.HtmlEncode(row["CNIC"].ToString()) + "</small>";
                        rowBorderStyle = "border-top: 2px solid #0f1e36;";
                    }

                    string rcptNo = row["ReceiptNo"] != DBNull.Value ? row["ReceiptNo"].ToString() : "No Receipt";
                    string rcptDateStr = "-";
                    DateTime rDate;
                    if (row["ReceiptDate"] != DBNull.Value && DateTime.TryParse(row["ReceiptDate"].ToString(), out rDate))
                    {
                        rcptDateStr = rDate.ToString("dd-MMM-yyyy");
                    }
                    decimal rcptPaid = row["ReceiptPaidAmount"] != DBNull.Value ? Convert.ToDecimal(row["ReceiptPaidAmount"]) : 0;

                    decimal formFee = row["FormFee"] != DBNull.Value ? Convert.ToDecimal(row["FormFee"]) : 0;
                    decimal mFee = row["AdvanceOrMembershipFee"] != DBNull.Value ? Convert.ToDecimal(row["AdvanceOrMembershipFee"]) : 0;
                    decimal totalAmt = row["TotalAmount"] != DBNull.Value ? Convert.ToDecimal(row["TotalAmount"]) : (formFee + mFee);
                    decimal balance = row["BalanceRemaining"] != DBNull.Value ? Convert.ToDecimal(row["BalanceRemaining"]) : 0;

                    html.Append("<tr style='" + rowBorderStyle + "'>");
                    html.Append("<td class='text-center'>" + srStr + "</td>");
                    html.Append("<td>" + appNoHtml + "</td>");
                    html.Append("<td>" + appNameHtml + "</td>");
                    html.Append("<td><strong>" + Server.HtmlEncode(rcptNo) + "</strong><br/><small style='color:#64748b;'>Date: " + rcptDateStr + " | Paid: Rs. " + rcptPaid.ToString("N0") + "</small></td>");
                    html.Append("<td class='text-right'>Rs. " + formFee.ToString("N0") + "</td>");
                    html.Append("<td class='text-right'>Rs. " + mFee.ToString("N0") + "</td>");
                    html.Append("<td class='text-right bold'>Rs. " + totalAmt.ToString("N0") + "</td>");
                    html.Append("<td class='text-right " + (balance > 0 ? "balance-pending" : "balance-cleared") + "'>Rs. " + balance.ToString("N0") + "</td>");
                    html.Append("</tr>");
                }

                // Add Totals Summary Row
                html.Append("<tr class='total-row' style='border-top: 2px solid #0f1e36;'>");
                html.Append("<td colspan='4' class='text-right'>Total Summary (" + dt.Rows.Count + " Entries, " + totalApplicants + " Applicants):</td>");
                html.Append("<td class='text-right'>Rs. " + sumFormFee.ToString("N0") + "</td>");
                html.Append("<td class='text-right'>Rs. " + sumMFee.ToString("N0") + "</td>");
                html.Append("<td class='text-right'>Rs. " + sumTotalAmount.ToString("N0") + "</td>");
                html.Append("<td class='text-right'>Rs. " + sumBalance.ToString("N0") + "</td>");
                html.Append("</tr>");
            }
            else
            {
                html.Append("<tr><td colspan='8' class='text-center' style='padding: 30px;'>No applicant receipt records found.</td></tr>");
            }

            html.Append(@"
        </tbody>
    </table>

    <div class='footer'>
        <span>MegaPlus Technologies | Lahore Gymkhana Club</span>
        <span>Authorized Signature: _______________________</span>
    </div>

    <script>window.onload = function() { window.print(); }</script>
</body>
</html>");

            Response.Clear();
            Response.ContentType = "text/html";
            Response.Write(html.ToString());
            Response.End();
        }

        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=ApplicantWiseReceiptReport.xls");
            Response.Charset = "";
            Response.ContentType = "application/vnd.ms-excel";

            using (StringWriter sw = new StringWriter())
            {
                HtmlTextWriter hw = new HtmlTextWriter(sw);
                if (gvReport != null)
                {
                    gvReport.AllowPaging = false;
                    BindReportGrid();
                    gvReport.RenderControl(hw);
                }
                Response.Write(sw.ToString());
                Response.End();
            }
        }

        public override void VerifyRenderingInServerForm(Control control) { }
    }
}
