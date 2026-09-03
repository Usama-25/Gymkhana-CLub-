using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MemberShipModule
{
    public partial class CashierPage : System.Web.UI.Page
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
                LoadReceiptModes();
                txtReceiptDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }

        private void LoadReceiptModes()
        {
            using (SqlConnection con = new SqlConnection(cs))
            {
                SqlCommand cmd = new SqlCommand("SELECT ReceiptModeID, ReceiptMode FROM ReceiptModes WHERE IsActive = 1 ORDER BY ReceiptMode", con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlReceiptMode.DataSource = dt;
                ddlReceiptMode.DataTextField = "ReceiptMode";
                ddlReceiptMode.DataValueField = "ReceiptModeID";
                ddlReceiptMode.DataBind();

                ddlReceiptMode.Items.Insert(0, new ListItem("-- Select Receipt Mode --", ""));
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlReceiptMode.SelectedValue) || 
                string.IsNullOrEmpty(txtReceiptDate.Text) || 
                string.IsNullOrEmpty(txtAmount.Text))
            {
                lblMessage.Text = "⚠️ Receipt Mode, Date, and Amount are required!";
                lblMessage.CssClass = "status-message text-error alert alert-danger";
                lblMessage.ForeColor = System.Drawing.Color.Red;
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alertError", "alert('Receipt Mode, Date, and Amount are required!');", true);
                return;
            }

            int transactionId = 0;
            string receiptRefNo = GetNextReceiptRefNo();
            int receiptModeId = int.Parse(ddlReceiptMode.SelectedValue);
            int receiptType = GetReceiptTypeForMode(receiptModeId);

            using (SqlConnection con = new SqlConnection(cs))
            {
                string query = @"
                    INSERT INTO Receipts 
                    (ReceiptType, ReceiptModeID, PaymentRefrence, ReceiptRefNo, ReceiptDate, 
                     Amount, TaxAmount, Notes, ModeOfPayment, CreatedAt, CreatedBy, ModifiedAt, ModifiedBy, PaymentHead, VoucherTransID) 
                    OUTPUT INSERTED.ReceiptID 
                    VALUES 
                    (@ReceiptType, @ReceiptModeID, @PaymentRefrence, @ReceiptRefNo, @ReceiptDate, 
                     @Amount, @TaxAmount, @Notes, @ModeOfPayment, GETDATE(), @CreatedBy, @ModifiedAt, @ModifiedBy, @PaymentHead, @VoucherTransID)";

                SqlCommand cmd = new SqlCommand(query, con);
                
                string currentUser = (this.User != null && this.User.Identity != null && !string.IsNullOrEmpty(this.User.Identity.Name)) ? this.User.Identity.Name : "Admin";

                cmd.Parameters.AddWithValue("@ReceiptType", receiptType);
                cmd.Parameters.AddWithValue("@ReceiptModeID", receiptModeId);
                
                string paymentModeText = ddlModeOfPayment.SelectedItem.Text;
                string paymentRefText = txtPaymentRefrence.Text.Trim();
                string finalPaymentRefrence = paymentModeText;
                if (!string.IsNullOrEmpty(paymentRefText))
                {
                    finalPaymentRefrence += " - " + paymentRefText;
                }
                cmd.Parameters.AddWithValue("@PaymentRefrence", finalPaymentRefrence);
                
                cmd.Parameters.AddWithValue("@ReceiptRefNo", receiptRefNo);
                cmd.Parameters.AddWithValue("@ReceiptDate", DateTime.Parse(txtReceiptDate.Text));
                cmd.Parameters.AddWithValue("@Amount", decimal.Parse(txtAmount.Text.Trim()));
                
                decimal taxAmount = 0;
                decimal.TryParse(txtTaxAmount.Text.Trim(), out taxAmount);
                cmd.Parameters.AddWithValue("@TaxAmount", taxAmount);
                
                cmd.Parameters.AddWithValue("@Notes", string.IsNullOrEmpty(txtNotes.Text.Trim()) ? (object)DBNull.Value : txtNotes.Text.Trim());
                cmd.Parameters.AddWithValue("@ModeOfPayment", byte.Parse(ddlModeOfPayment.SelectedValue));
                cmd.Parameters.AddWithValue("@CreatedBy", currentUser);
                cmd.Parameters.AddWithValue("@ModifiedAt", DBNull.Value);
                cmd.Parameters.AddWithValue("@ModifiedBy", DBNull.Value);
                cmd.Parameters.AddWithValue("@PaymentHead", string.IsNullOrEmpty(txtPaymentHead.Text.Trim()) ? (object)DBNull.Value : txtPaymentHead.Text.Trim());
                cmd.Parameters.AddWithValue("@VoucherTransID", DBNull.Value); // Update string or logic if you generate voucher transaction ID

                con.Open();
                object result = cmd.ExecuteScalar();
                if (result != null)
                {
                    transactionId = Convert.ToInt32(result);
                }
            }

            if (transactionId > 0)
            {
                lblMessage.Text = "✅ Transaction Saved Successfully! Receipt: " + receiptRefNo;
                lblMessage.CssClass = "status-message text-success";
                
                GenerateHtmlReport(transactionId);
            }
        }

        private int GetReceiptTypeForMode(int modeId)
        {
            using (SqlConnection con = new SqlConnection(cs))
            {
                SqlCommand cmd = new SqlCommand("SELECT ReceiptType FROM ReceiptModes WHERE ReceiptModeID = @Id", con);
                cmd.Parameters.AddWithValue("@Id", modeId);
                con.Open();
                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    return Convert.ToInt32(result);
                }
                return 1; // Default
            }
        }

        private string GetNextReceiptRefNo()
        {
            using (SqlConnection con = new SqlConnection(cs))
            {
                SqlCommand cmd = new SqlCommand(@"
                    SELECT TOP 1 ReceiptRefNo 
                    FROM Receipts 
                    WHERE ReceiptRefNo LIKE 'RCPT-%' 
                    ORDER BY ReceiptID DESC", con);

                con.Open();
                object result = cmd.ExecuteScalar();
                con.Close();

                string today = DateTime.Now.ToString("yyyyMMdd");
                int lastNumber = 0;

                if (result != null && result != DBNull.Value)
                {
                    string lastReceipt = result.ToString();
                    string[] parts = lastReceipt.Split('-');
                    if (parts.Length == 3 && parts[1] == today)
                    {
                        int.TryParse(parts[2], out lastNumber);
                    }
                }

                return string.Format("RCPT-{0}-{1:D6}", today, lastNumber + 1);
            }
        }

        private string NumberToWords(int number)
        {
            if (number == 0) return "Zero";
            if (number < 0) return "Minus " + NumberToWords(Math.Abs(number));
            string words = "";
            if ((number / 10000000) > 0) { words += NumberToWords(number / 10000000) + " Crore "; number %= 10000000; }
            if ((number / 100000) > 0) { words += NumberToWords(number / 100000) + " Lakh "; number %= 100000; }
            if ((number / 1000) > 0) { words += NumberToWords(number / 1000) + " Thousand "; number %= 1000; }
            if ((number / 100) > 0) { words += NumberToWords(number / 100) + " Hundred "; number %= 100; }
            if (number > 0)
            {
                if (words != "") words += "and ";
                var unitsMap = new[] { "Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen" };
                var tensMap = new[] { "Zero", "Ten", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety" };
                if (number < 20) words += unitsMap[number];
                else { words += tensMap[number / 10]; if ((number % 10) > 0) words += " " + unitsMap[number % 10]; }
            }
            return words.Replace("  ", " ").Trim();
        }

        private void GenerateHtmlReport(int id)
        {
            using (SqlConnection con = new SqlConnection(cs))
            {
                string query = "SELECT r.*, rm.ReceiptMode FROM Receipts r LEFT JOIN ReceiptModes rm ON r.ReceiptModeID = rm.ReceiptModeID WHERE r.ReceiptID = @Id";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@Id", id);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count == 0) return;

                DataRow row = dt.Rows[0];
                
                string receiptNo = row["ReceiptRefNo"].ToString();
                string date = Convert.ToDateTime(row["ReceiptDate"]).ToString("dd-MMM-yyyy");
                int amount = Convert.ToInt32(Convert.ToDecimal(row["Amount"]));
                string amountStr = amount.ToString("N0") + "/-";
                string words = NumberToWords(amount) + " Only";
                
                byte modeByte = row["ModeOfPayment"] != DBNull.Value ? Convert.ToByte(row["ModeOfPayment"]) : (byte)1;
                string paymentMode = modeByte == 2 ? "Cheque" : "Cash";
                string paymentDetail = paymentMode;
                if (paymentMode == "Cheque" && row["PaymentRefrence"] != DBNull.Value)
                {
                    paymentDetail += " - " + row["PaymentRefrence"].ToString();
                }
                string receivedFrom = row["Notes"] != DBNull.Value ? row["Notes"].ToString() : "";
                string onAccountOf = row["ReceiptMode"].ToString() + (row["PaymentHead"] != DBNull.Value && !string.IsNullOrEmpty(row["PaymentHead"].ToString()) ? " - " + row["PaymentHead"].ToString() : "");
                string currentUser = (this.User != null && this.User.Identity != null && !string.IsNullOrEmpty(this.User.Identity.Name)) ? this.User.Identity.Name : "Admin";
                string printTime = DateTime.Now.ToString("dd/MM/yyyy, h:mm:ss tt");

                // Assuming the application runs from root or virtual directory, resolve path relative to site root
                // For printing, base64 encoding the image guarantees it shows up without pathing issues
                string logoPath = Server.MapPath("assets/images/logo for report.jpeg");
                string logoBase64 = "";
                if (System.IO.File.Exists(logoPath))
                {
                    byte[] imageBytes = System.IO.File.ReadAllBytes(logoPath);
                    logoBase64 = "data:image/jpeg;base64," + Convert.ToBase64String(imageBytes);
                }

                System.Text.StringBuilder html = new System.Text.StringBuilder();
                html.Append(@"<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>Transaction Receipt</title>
    <style>
        @media print {
            @page { size: A4 portrait; margin: 0; }
            body { margin: 0; padding: 0; -webkit-print-color-adjust: exact; }
            .print-half { height: 50vh; padding: 40px 50px; box-sizing: border-box; }
        }
        body { font-family: 'Segoe UI', Arial, sans-serif; color: #333; margin: 0; padding: 20px; background: #fff; }
        .print-half { width: 100%; max-width: 800px; margin: 0 auto; padding: 20px 40px; box-sizing: border-box; position: relative; }
        .header-row { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 5px; }
        .header-info-left { margin-top: 10px; }
        .header-info-left h1 { font-size: 24px; font-weight: normal; margin: 0; color: #2c3e50; font-family: 'Arial', sans-serif; letter-spacing: 0.5px; }
        .header-info-left p { margin: 3px 0; font-size: 15px; font-style: italic; color: #444; }
        .doc-title { text-align: center; font-size: 16px; font-weight: bold; margin-top: 0px; margin-bottom: 25px; color: #555; position: relative; left: 60px;}
        .logo-placeholder { width: 95px; display: flex; flex-direction: column; align-items: center; justify-content: flex-start; margin-right: 15px; margin-top: -5px; }
        .logo-placeholder img { width: 100%; height: auto; mix-blend-mode: multiply; }
        
        .row-line { display: flex; font-size: 16px; font-style: italic; margin-bottom: 18px; align-items: flex-end; }
        .label { color: #666; white-space: nowrap; margin-right: 15px; }
        .value-underline { flex: 1; border-bottom: 1px solid #444; font-style: normal; font-weight: 500; color: #000; padding: 0 10px; min-height: 22px; }
        .value-underline-inline { border-bottom: 1px solid #444; font-style: normal; font-weight: 500; color: #000; padding: 0 10px; min-width: 120px; text-align: center; margin-right: 15px; }
        
        .footer-signatures { display: flex; justify-content: space-between; margin-top: 60px; font-size: 14px; font-style: italic; align-items: flex-end; }
        .sign-box-left { text-align: center; width: 220px; }
        .sign-box { text-align: center; width: 220px; text-align: center; }
        .sign-line { border-top: 1px solid #444; padding-top: 5px; color: #555; }
        
        .bottom-info { display: flex; justify-content: space-between; margin-top: 20px; font-size: 12px; color: #666; font-style: italic; }
    </style>
</head>
<body onload='window.print()'>
    <div class='print-half'>
        <div class='header-row'>
            <div class='header-info-left'>
                <h1>LAHORE GYMKHANA</h1>
                <p>The Mall, Upper Shahrah-e-Quaid-e-Azam, Lahore</p>
                <p>Lahore 54840, Pakistan</p>
            </div>
            <div class='logo-placeholder'>");
                if (!string.IsNullOrEmpty(logoBase64))
                {
                    html.Append("<img src='" + logoBase64 + "' alt='LGC Logo' />");
                }
                else
                {
                    html.Append("<div>LGC</div>");
                }
            html.Append(@"
            </div>
        </div>
        <div class='doc-title'>Duplicate Receipt</div>

        <div>
            <div class='row-line'>
                <span class='label' style='width: 160px;'>Receipt # / Date</span>
                <span class='value-underline' style='flex: 0.4;'>" + receiptNo + @"</span>
                <span class='value-underline' style='flex: 0.6; padding-left: 20px;'>" + date + @"</span>
            </div>
            
            <div class='row-line'>
                <span class='label' style='width: 270px;'>Received with thanks a sum of Rs.</span>
                <span class='value-underline-inline' style='flex:1; text-align: left;'>" + amountStr + @"</span>
                <span class='label' style='margin-left: 10px;'>Bank Charges:</span>
                <span class='value-underline-inline' style='width: 60px;'>0/-</span>
                <span class='label' style='margin-left: 10px;'>Net Amount:</span>
                <span class='value-underline-inline' style='flex:1; text-align: right;'>" + amountStr + @"</span>
            </div>

            <div class='row-line'>
                <span class='label' style='width: 130px;'>Rupees in Words:</span>
                <span class='value-underline'>" + words + @"</span>
            </div>

            <div class='row-line'>
                <span class='label' style='width: 320px;'>Cash/Cheque No/PO/DD/Credit Card:</span>
                <span class='value-underline'>" + paymentDetail + @"</span>
            </div>

            <div class='row-line'>
                <span class='label' style='width: 130px;'>Receipt against:</span>
                <span class='value-underline'>" + onAccountOf + @"</span>
            </div>

            <div class='row-line'>
                <span class='label' style='width: 130px;'>Received From:</span>
                <span class='value-underline'>" + receivedFrom + @"</span>
            </div>

            <div class='row-line'>
                <span class='label' style='width: 130px;'>On Account of:</span>
                <span class='value-underline'>&nbsp;</span>
            </div>
        </div>

        <div class='footer-signatures'>
            <div class='sign-box-left'>
                <div style='text-align: left; font-style: normal; font-weight: bold; margin-bottom: 5px; margin-left: 10px; color: #333;'>" + currentUser + @"</div>
                <div class='sign-line'>Received by</div>
            </div>
            <div class='sign-box'>
                <div class='sign-line'>Checked by</div>
            </div>
        </div>
        
        <div class='bottom-info'>
            <div>" + currentUser + @", " + printTime + @", MR00.04</div>
            <div>(Cheques/PO/DD are subject to clearance)</div>
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
}
