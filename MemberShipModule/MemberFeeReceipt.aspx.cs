using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

public partial class MemberShipModule_MemberFeeReceipt : Page
{
    private string cs
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
            int trackId;
            string type = Request.QueryString["type"];
            string receiptNo = Request.QueryString["receipt"];

            if (int.TryParse(Request.QueryString["id"], out trackId))
            {
                GenerateReceipt(trackId, type, receiptNo);
            }
            else
            {
                Response.Write("<h3>Invalid Request</h3>");
            }
        }
    }

    private void GenerateReceipt(int trackId, string type, string receiptNo)
    {
        using (SqlConnection con = new SqlConnection(cs))
        {
            // Fetch the specific payment (or most recent) for this trackId from MemberFee table
            string query = @"
                SELECT TOP 1 
                    f.PurchaseBy, f.FormType,
                    m.MemberFee, m.Mode, m.CreatedAt as PaymentDate, m.ReciptNo,
                    ISNULL((SELECT SUM(MemberFee) FROM MemberFee WHERE TrackId = f.id AND id < m.id), 0) as PreviouslyReceived,
                    ISNULL((SELECT SUM(MemberFee) FROM MemberFee WHERE TrackId = f.id AND id <= m.id), 0) as TotalPaidSoFar
                FROM FormPurchase f
                JOIN MemberFee m ON f.id = m.TrackId
                WHERE f.id = @TrackId AND (@ReceiptNo IS NULL OR m.ReciptNo = @ReceiptNo)
                ORDER BY m.id DESC";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@TrackId", trackId);
            cmd.Parameters.AddWithValue("@ReceiptNo", string.IsNullOrEmpty(receiptNo) ? (object)DBNull.Value : receiptNo);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            if (dt.Rows.Count == 0)
            {
                Response.Write("<h3>Receipt not found.</h3>");
                return;
            }

            DataRow row = dt.Rows[0];
            string name = row["PurchaseBy"].ToString();
            string memberType = row["FormType"].ToString();
            decimal previousAmount = Convert.ToDecimal(row["PreviouslyReceived"]);
            decimal amount = Convert.ToDecimal(row["MemberFee"]);
            string mode = row["Mode"].ToString();
            string date = Convert.ToDateTime(row["PaymentDate"]).ToString("dd-MMM-yyyy HH:mm");
            string finalReceiptNo = row["ReciptNo"].ToString();
            decimal totalPaid = Convert.ToDecimal(row["TotalPaidSoFar"]);

            string feeLabel = (type != null && type.ToLower() == "form") ? "Form Fee" : "Member Fee";
            string receiptTitle = feeLabel + " Receipt";

            StringBuilder html = new StringBuilder();
            html.Append(@"<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>Member Fee Receipt</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; font-size: 14px; padding: 40px; color: #333; }
        .receipt-box { max-width: 600px; margin: auto; border: 1px solid #eee; padding: 30px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .header { text-align: center; border-bottom: 2px solid #2c5282; margin-bottom: 20px; padding-bottom: 10px; }
        .title { font-size: 20px; font-weight: bold; color: #1a365d; }
        .content { line-height: 2; }
        .row { display: flex; justify-content: space-between; border-bottom: 1px solid #f6f6f6; padding: 5px 0; }
        .label { font-weight: bold; color: #666; }
        .value { color: #000; }
        .footer { margin-top: 30px; text-align: center; font-size: 12px; color: #777; border-top: 1px solid #eee; padding-top: 10px; }
        .highlight { font-weight: bold; color: #2c5282; font-size: 1.1em; }
    </style>
</head>
<body onload='window.print()'>
    <div class='receipt-box'>
        <div class='header'>
            <div class='title'>Lahore Gymkhana Club</div>
            <div style='font-weight: 600;'>" + receiptTitle + @"</div>
            <div style='font-size: 12px; color: #666; margin-top: 5px;'>Receipt No: " + finalReceiptNo + @"</div>
        </div>
        <div class='content'>
            <div class='row'><span class='label'>Purchased By:</span> <span class='value'>" + name + @"</span></div>
            <div class='row'><span class='label'>Membership Type:</span> <span class='value'>" + memberType + @"</span></div>
            <div class='row'><span class='label'>Payment Mode:</span> <span class='value'>" + mode + @"</span></div>
            <div class='row'><span class='label'>Date & Time:</span> <span class='value'>" + date + @"</span></div>
            <hr style='border: 0; border-top: 1px dashed #eee;' />
            <div class='row'><span class='label'>Previous Received:</span> <span class='value'>Rs. " + previousAmount.ToString("N2") + @"</span></div>
            <div class='row highlight'><span class='label' style='color:#2c5282'>Current Received (" + feeLabel + @"):</span> <span class='value'>Rs. " + amount.ToString("N2") + @"</span></div>
            <div class='row'><span class='label'>Total Received:</span> <span class='value' style='font-weight:bold;'>Rs. " + totalPaid.ToString("N2") + @"</span></div>
        </div>
        <div class='footer'>
            <p>This is a computer generated receipt.</p>
            <p>MegaPlus Technologies</p>
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
}
