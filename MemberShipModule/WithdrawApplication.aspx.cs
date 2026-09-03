using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class WithdrawApplication : System.Web.UI.Page
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
        if (Request.QueryString["print"] == "true" && !string.IsNullOrEmpty(Request.QueryString["trackid"]))
        {
            int trackId = 0;
            if (int.TryParse(Request.QueryString["trackid"], out trackId))
            {
                GenerateRefundLetter(trackId);
                return;
            }
        }

        if (!IsPostBack)
        {
            BindGrid();
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        BindGrid();
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        txtTrackID.Text = "";
        txtApplicantName.Text = "";
        ddlStatus.SelectedIndex = 0;
        pnlMessage.Visible = false;
        BindGrid();
    }

    private void BindGrid()
    {
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            StringBuilder sb = new StringBuilder(@"
                SELECT 
                    TrackID,
                    ApplicantName,
                    NIC,
                    Status,
                    MembershipType,
                    CONVERT(varchar, CreatedOn, 106) AS ApplyDate
                FROM ApplicationFForm
                WHERE Status IN ('Pending', 'Deferred') ");

            if (!string.IsNullOrWhiteSpace(txtTrackID.Text))
            {
                sb.Append(" AND CAST(TrackID AS VARCHAR) LIKE @TrackID ");
            }
            if (!string.IsNullOrWhiteSpace(txtApplicantName.Text))
            {
                sb.Append(" AND ApplicantName LIKE @AppName ");
            }
            if (!string.IsNullOrEmpty(ddlStatus.SelectedValue))
            {
                sb.Append(" AND Status = @Status ");
            }

            sb.Append(" ORDER BY TrackID DESC ");

            using (SqlCommand cmd = new SqlCommand(sb.ToString(), conn))
            {
                if (!string.IsNullOrWhiteSpace(txtTrackID.Text))
                    cmd.Parameters.AddWithValue("@TrackID", "%" + txtTrackID.Text.Trim() + "%");
                if (!string.IsNullOrWhiteSpace(txtApplicantName.Text))
                    cmd.Parameters.AddWithValue("@AppName", "%" + txtApplicantName.Text.Trim() + "%");
                if (!string.IsNullOrEmpty(ddlStatus.SelectedValue))
                    cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvApplications.DataSource = dt;
                gvApplications.DataBind();
            }
        }
    }

    protected string GetStatusClass(object statusObj)
    {
        string status = statusObj != null ? statusObj.ToString().ToLower().Trim() : "";
        if (status.Contains("pending")) return "status-badge status-pending";
        if (status.Contains("deferred")) return "status-badge status-deferred";
        if (status.Contains("withdrawn")) return "status-badge status-withdrawn";
        return "status-badge";
    }

    protected void gvApplications_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "WithdrawApp")
        {
            int trackId = Convert.ToInt32(e.CommandArgument);

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand("UPDATE ApplicationFForm SET Status = 'Withdrawn' WHERE TrackID = @TrackID", conn);
                cmd.Parameters.AddWithValue("@TrackID", trackId);
                int rows = cmd.ExecuteNonQuery();

                if (rows > 0)
                {
                    ShowMessage("Application Track ID " + trackId + " has been successfully withdrawn.", true);
                    BindGrid();

                    string printUrl = "WithdrawApplication.aspx?print=true&trackid=" + trackId;
                    string script = "setTimeout(function() { window.open('" + printUrl + "', '_blank'); }, 100);";
                    ScriptManager.RegisterStartupScript(this, GetType(), "PrintReport", script, true);
                }
                else
                {
                    ShowMessage("Error withdrawing application. Please try again.", false);
                }
            }
        }
    }

    private void GenerateRefundLetter(int trackId)
    {
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            string sql = @"
                SELECT 
                    a.TrackID,a.ApplicantID, a.ApplicantName, a.FatherName, a.NIC, a.Mobile, a.City, 
                    a.MembershipType, a.CreatedOn, a.FormFee, a.Status,
                    f.Price AS FormFeeTable, f.EntranceFee, f.ExtraCharges,
                    f.IsFormFeeRefundable, f.IsEntranceFeeRefundable, f.IsExtraChargesRefundable
                FROM ApplicationFForm a
                LEFT JOIN FormTable f ON (f.FormTypeName = a.MembershipType OR f.FormTypeName = a.Membership_class OR f.FormType = a.MembershipType)
                WHERE a.TrackID = @TrackID";

            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@TrackID", trackId);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            if (dt.Rows.Count == 0) return;

            DataRow row = dt.Rows[0];
            string logoPath = ResolveUrl("~/MemberShipModule/assets/images/logo for report.jpeg");
            string preparedBy = Session["Emp_Name"] != null ? Session["Emp_Name"].ToString() : "System";
            string printDateTime = DateTime.Now.ToString("dd/MM/yyyy hh:mm:ss tt");

            decimal formFee = 0;
            if (row["FormFee"] != DBNull.Value) formFee = Convert.ToDecimal(row["FormFee"]);
            else if (row["FormFeeTable"] != DBNull.Value) formFee = Convert.ToDecimal(row["FormFeeTable"]);

            decimal entranceFee = row["EntranceFee"] != DBNull.Value ? Convert.ToDecimal(row["EntranceFee"]) : 0;
            decimal extraCharges = row["ExtraCharges"] != DBNull.Value ? Convert.ToDecimal(row["ExtraCharges"]) : 0;

            bool formRef = row["IsFormFeeRefundable"] != DBNull.Value && Convert.ToBoolean(row["IsFormFeeRefundable"]);
            bool entRef = row["IsEntranceFeeRefundable"] != DBNull.Value && Convert.ToBoolean(row["IsEntranceFeeRefundable"]);
            bool extRef = row["IsExtraChargesRefundable"] != DBNull.Value && Convert.ToBoolean(row["IsExtraChargesRefundable"]);

            decimal refundForm = formRef ? formFee : 0;
            decimal refundEnt = entRef ? entranceFee : 0;
            decimal refundExt = extRef ? extraCharges : 0;
            decimal totalRefund = refundForm + refundEnt + refundExt;

            string cityName = row["City"] != DBNull.Value ? row["City"].ToString() : "Lahore";

            StringBuilder html = new StringBuilder();
            html.Append(@"<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>Withdrawal & Refund Letter - " + row["ApplicantID"].ToString() + @"</title>
    <style>
        @page { size: A4; margin: 0; }
        body { font-family: 'Arial', sans-serif; font-size: 13px; margin: 0; padding: 0; color: #000; background: #fff; line-height: 1.3; }
        .report-page { width: 210mm; height: 297mm; padding: 12mm 15mm; margin: auto; box-sizing: border-box; display: flex; flex-direction: column; position: relative; overflow: hidden; }
        
        .header { display: flex; align-items: flex-start; justify-content: space-between; border-bottom: 2px solid #000; padding-bottom: 6px; margin-bottom: 20px; }
        .header-left { display: flex; align-items: center; gap: 12px; }
        .logo { height: 60px; width: auto; }
        .club-info h1 { font-family: 'Times New Roman', Times, serif; font-size: 26px; font-weight: bold; margin: 0; color: #000; letter-spacing: 0.5px; }
        .club-info p { font-size: 10px; margin: 1px 0; color: #333; font-weight: bold; }
        
        .meta-info { text-align: right; font-size: 12px; line-height: 1.5; padding-top: 5px; }
        .meta-info strong { width: 85px; display: inline-block; text-align: left; }

        .recipient-info { margin-bottom: 12px; font-size: 13px; line-height: 1.4; }
        .recipient-info div { font-weight: bold; }

        .subject { text-align: center; margin: 12px 0; font-size: 15px; font-weight: bold; text-decoration: underline; text-transform: uppercase; font-style: italic; }

        .welcome-text { margin-bottom: 20px; text-align: justify; font-size: 13px; line-height: 1.5; }

        .signature-area { display: flex; justify-content: flex-end; margin: 15px 0 25px; }
        .sig-box { width: 140px; text-align: center; font-weight: bold; font-size: 13px; }

        .info-card { border: 1px solid #000; padding: 10px 15px; width: 88%; margin: 10px auto; }
        .info-card-title { text-align: center; font-weight: bold; text-decoration: underline; margin-bottom: 8px; font-size: 14px; font-style: italic; }
        
        .card-table { width: 100%; border-collapse: collapse; }
        .card-table th { padding: 4px 8px; text-align: left; border-bottom: 1px solid #000; font-size: 12px; }
        .card-table td { padding: 4px 8px; vertical-align: top; font-size: 12px; }
        .card-table .label { font-weight: bold; width: 150px; }
        .card-table .separator { width: 10px; text-align: center; }

        .footer { position: absolute; bottom: 10mm; left: 15mm; right: 15mm; font-size: 9px; color: #333; border-top: 1px solid #ccc; padding-top: 4px; display: flex; justify-content: space-between; }

        @media print { 
            .no-print { display: none; } 
            body { background: none; }
            .report-page { border: none; box-shadow: none; margin: 0; padding: 20mm; }
        }
    </style>
</head>
<body onload='window.print()'>
    <div class='report-page'>
        <div class='header'>
            <div class='header-left'>
                <img src='" + logoPath + @"' class='logo' alt='Logo' />
                <div class='club-info'>
                    <h1>LAHORE GYMKHANA</h1>
                    <p><strong>Upper Shahrah-e-Quaid-e-Azam, Lahore, Pakistan</strong></p>
                    <p><strong>Phone: 111-111-231 Email: secretary@lahoregymkhana.org.pk</strong></p>
                </div>
            </div>
        </div>

        <div style='display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px;'>
            <div class='recipient-info'>
                <div>" + row["ApplicantName"].ToString().ToUpper() + @"</div>
                <div>S/D/W of " + row["FatherName"].ToString() + @"</div>
                <div>NIC: " + row["NIC"].ToString() + @"</div>
                <div style='text-decoration: underline;'>" + cityName + @".</div>
            </div>
            <div class='meta-info' style='text-align: right; font-size: 13px;'>
                <table style='margin-left: auto; border-collapse: collapse; text-align: left;'>
                    <tr>
                        <td style='font-weight: bold; padding-right: 5px; width: 85px;'>Track ID</td>
                        <td>: " + row["ApplicantID"].ToString() + @"</td>
                    </tr>
                    <tr>
                        <td style='font-weight: bold; padding-right: 5px;'>Apply Date</td>
                        <td>: " + Convert.ToDateTime(row["CreatedOn"]).ToString("dd/MM/yyyy") + @"</td>
                    </tr>
                    <tr>
                        <td style='font-weight: bold; padding-right: 5px;'>Print Date</td>
                        <td>: " + DateTime.Now.ToString("dd/MM/yyyy") + @"</td>
                    </tr>
                </table>
            </div>
        </div>

        <div class='subject'>APPLICATION WITHDRAWAL & REFUND LETTER</div>

        <div class='welcome-text'>
            This is to inform you that your application for <strong>" + row["MembershipType"].ToString() + @"</strong> bearing Track ID <strong>" + row["ApplicantID"].ToString() + @"</strong> has been successfully withdrawn. 
            Below are the details regarding your paid fees and the corresponding refund amounts based on our club policies.
        </div>

        <div class='info-card'>
            <div class='info-card-title'>FEE REFUND DETAILS</div>
            <table class='card-table'>
                <thead>
                    <tr>
                        <th style='width: 40%;'>Fee Type</th>
                        <th style='width: 30%;'>Amount (Rs.)</th>
                        <th style='width: 30%;'>Refundable (Rs.)</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><strong>Form Fee</strong><br/><small>(" + (formRef ? "Refundable" : "Non-Refundable") + @")</small></td>
                        <td>" + formFee.ToString("N2") + @"</td>
                        <td>" + refundForm.ToString("N2") + @"</td>
                    </tr>
                    <tr>
                        <td><strong>Entrance Fee</strong><br/><small>(" + (entRef ? "Refundable" : "Non-Refundable") + @")</small></td>
                        <td>" + entranceFee.ToString("N2") + @"</td>
                        <td>" + refundEnt.ToString("N2") + @"</td>
                    </tr>
                    <tr>
                        <td><strong>Extra Charges</strong><br/><small>(" + (extRef ? "Refundable" : "Non-Refundable") + @")</small></td>
                        <td>" + extraCharges.ToString("N2") + @"</td>
                        <td>" + refundExt.ToString("N2") + @"</td>
                    </tr>
                    <tr>
                        <td colspan='3' style='border-top: 1px solid #ccc; margin-top: 5px; padding-top: 5px;'></td>
                    </tr>
                    <tr>
                        <td style='font-size: 14px;'><strong>Total Amount</strong></td>
                        <td style='font-size: 14px;'><strong>" + (formFee + entranceFee + extraCharges).ToString("N2") + @"</strong></td>
                        <td style='font-size: 14px; color: " + (totalRefund > 0 ? "green" : "red") + @";'><strong>" + totalRefund.ToString("N2") + @"</strong></td>
                    </tr>
                </tbody>
            </table>
        </div>

        <div class='welcome-text' style='margin-top: 20px;'>
            <strong>Note:</strong> The total refundable amount of <strong>Rs. " + totalRefund.ToString("N2") + @"</strong> will be processed as per standard operating procedures. Please contact the accounts department for any queries.
        </div>

        <div class='signature-area' style='margin-top: auto;'>
            <div class='sig-box'>
                <br/><br/>
                Secretary / Authorized Signatory
            </div>
        </div>

        <div class='footer'>
            <div>Prepared By: " + preparedBy + " | " + printDateTime + @"</div>
            <div style='text-align: right;'>Page 1 of 1</div>
        </div>
    </div>
</body>
</html>");

            Response.Clear();
            Response.ContentType = "text/html";
            Response.Write(html.ToString());
            Response.End();
        }
    }

    private void ShowMessage(string msg, bool success)
    {
        lblMsg.Text = msg;
        pnlMessage.CssClass = success ? "msg-container msg-success" : "msg-container msg-error";
        lblMsg.Text = success ? "<i class='fas fa-check-circle'></i> " + msg : "<i class='fas fa-exclamation-circle'></i> " + msg;
        pnlMessage.Visible = true;
    }
}
