
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Form_cell.Applicant_Form
{
    public partial class Applicant_formcell : System.Web.UI.Page
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
                LoadFormTypes();
                ShowNextReceiptNo();
                LoadMembershipTypes();
            }
        }

        private void LoadFormTypes()
        {
            using (SqlConnection con = new SqlConnection(cs))
            {
                SqlCommand cmd = new SqlCommand("GetFormPrice", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@FormType", DBNull.Value);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                DropDownList1.DataSource = dt;
                DropDownList1.DataTextField = "FormType";
                DropDownList1.DataValueField = "Price";
                DropDownList1.DataBind();

                DropDownList1.Items.Insert(0, new System.Web.UI.WebControls.ListItem("-- Select Form Type --", ""));
            }
        }

        protected void DropDownList1_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(DropDownList1.SelectedValue))
            {
                priceSpan.InnerText = "Price: Rs. " + DropDownList1.SelectedValue;
            }
            else
            {
                priceSpan.InnerText = "Price: Rs. 0";
            }
        }
        private void LoadMembershipTypes()
        {
            using (SqlConnection con = new SqlConnection(cs))
            {
                SqlCommand cmd = new SqlCommand("GetMembershipClass", con);
                cmd.CommandType = CommandType.StoredProcedure;
             
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                DropDownList2.DataSource = dt;
                DropDownList2.DataTextField = "Members_classes";
                DropDownList2.DataValueField = "ID";
                DropDownList2.DataBind();

                DropDownList2.Items.Insert(0, new System.Web.UI.WebControls.ListItem("-- Select class Type --", ""));
            }
            }


        protected void DropDownList2_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (DropDownList2.SelectedItem != null && DropDownList2.SelectedItem.Text.ToLower().Contains("non earning"))
            {
                divActiveMember.Visible = true;
                txtActiveMemberNo.Focus();
            }
            else
            {
                divActiveMember.Visible = false;
                txtActiveMemberNo.Text = "";
                lblActiveMemberName.Text = "";
            }
        }

        protected void txtActiveMemberNo_TextChanged(object sender, EventArgs e)
        {
            string memberNo = txtActiveMemberNo.Text.Trim();
            if (string.IsNullOrEmpty(memberNo))
            {
                lblActiveMemberName.Text = "";
                return;
            }

            using (SqlConnection con = new SqlConnection(cs))
            {
                // Check if member exists and is active
                // Using MemberProfile table which has MemberNo, MemberName, AccountStatus
                string query = "SELECT MemberName, AccountStatus FROM MemberProfile WHERE MemberNo = @MemberNo";
                
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                
                try
                {
                    con.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader.Read())
                    {
                        string name = reader["MemberName"].ToString();
                        string status = reader["AccountStatus"] != DBNull.Value ? reader["AccountStatus"].ToString() : "";
                        
                        lblActiveMemberName.Text = "✅ " + name + " (" + status + ")";
                        lblActiveMemberName.ForeColor = System.Drawing.Color.Green;
                    }
                    else
                    {
                        lblActiveMemberName.Text = "❌ Member Not Found";
                        lblActiveMemberName.ForeColor = System.Drawing.Color.Red;
                    }
                }
                catch (Exception ex)
                {
                    lblActiveMemberName.Text = "Error: " + ex.Message;
                }
            }
        }
     




        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (DropDownList1.SelectedIndex == 0)
            {
                lblMessage.Text = "⚠️ Please select a form type!";
                lblMessage.CssClass = "status-message text-error";
                return;
            }

            int newId = 0;
            string receiptNo = "";

            using (SqlConnection con = new SqlConnection(cs))
            {
                SqlCommand cmd = new SqlCommand("InsertFormPurchase", con);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@FormType", DropDownList1.SelectedItem.Text);
                cmd.Parameters.AddWithValue("@Price", DropDownList1.SelectedValue);
                cmd.Parameters.AddWithValue("@PurchaseBy", txtPurchaseBy.Text);
                cmd.Parameters.AddWithValue("@PhoneNo", txtPhoneNo.Text);
                cmd.Parameters.AddWithValue("@CNIC", CNIC.Text);
                cmd.Parameters.AddWithValue("@Membership_class", DropDownList2.SelectedItem.Text);
                
                // Add PrimaryMemberNo if Non Earning
                if (divActiveMember.Visible)
                {
                    if (string.IsNullOrEmpty(txtActiveMemberNo.Text)) 
                    {
                        lblMessage.Text = "⚠️ Please enter Primary Member No for Non-Earning Membership!";
                        lblMessage.CssClass = "status-message text-error";
                        return;
                    }
                     cmd.Parameters.AddWithValue("@PrimaryMemberNo", txtActiveMemberNo.Text.Trim());
                }
                else
                {
                     cmd.Parameters.AddWithValue("@PrimaryMemberNo", DBNull.Value);
                }

                con.Open();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        newId = Convert.ToInt32(dr["PurchaseID"]);
                        receiptNo = dr["ReceiptNo"].ToString();
                    }
                }

                Session["SavedFormID"] = newId;
            }

        

            
            if (newId > 0)
            {
                UpdateFormPurchaseStatus(newId, "Unpaid");
                GenerateHtmlReport(newId);
            }

            txtPurchaseBy.Text = "";
            txtPhoneNo.Text = "";
            CNIC.Text = "";
            DropDownList1.SelectedIndex = 0;
            priceSpan.InnerText = "Price: Rs. 0";

            lblMessage.Text = "✅ Record Saved Successfully! Saved ID = " + newId;
            lblMessage.CssClass = "status-message text-success";
        }

        private void UpdateFormPurchaseStatus(int id, string status)
        {
            using (SqlConnection con = new SqlConnection(cs))
            {
                string query = "UPDATE FormPurchase SET Status = @Status WHERE Id = @Id";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@Status", status);
                cmd.Parameters.AddWithValue("@Id", id);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        protected void GenerateHtmlReport(int id)
        {
            using (SqlConnection con = new SqlConnection(cs))
            {
                SqlCommand cmd = new SqlCommand("SELECT * FROM FormPurchase WHERE id = @Id", con);
                cmd.Parameters.AddWithValue("@Id", id);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count == 0) return;

                DataRow row = dt.Rows[0];
                string memberType = row["FormType"].ToString();
                string name = row["PurchaseBy"].ToString();
                string receiptNo = row["ReceiptNo"].ToString();
                string price = row["Price"].ToString();
                string date = Convert.ToDateTime(row["CreatedAt"]).ToString("dd-MMM-yyyy HH:mm");

                System.Text.StringBuilder html = new System.Text.StringBuilder();
                html.Append(@"<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>Form Purchase Receipt</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; font-size: 14px; padding: 40px; color: #333; }
        .receipt-box { max-width: 600px; margin: auto; border: 1px solid #eee; padding: 30px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .header { text-align: center; border-bottom: 2px solid #2c5282; margin-bottom: 20px; padding-bottom: 10px; }
        .logo { width: 80px; }
        .title { font-size: 20px; font-weight: bold; color: #1a365d; }
        .content { line-height: 2; }
        .row { display: flex; justify-content: space-between; border-bottom: 1px solid #f6f6f6; padding: 5px 0; }
        .label { font-weight: bold; color: #666; }
        .value { color: #000; }
        .footer { margin-top: 30px; text-align: center; font-size: 12px; color: #777; border-top: 1px solid #eee; padding-top: 10px; }
    </style>
</head>
<body onload='window.print()'>
    <div class='receipt-box'>
        <div class='header'>
            <div class='title'>Lahore Gymkhana Club</div>
            <div style='font-weight: 600;'>Membership Application Form Receipt</div>
        </div>
        <div class='content'>
            <div class='row'><span class='label'>Membership Type:</span> <span class='value'>" + memberType + @"</span></div>
            <div class='row'><span class='label'>Purchased By:</span> <span class='value'>" + name + @"</span></div>
            <div class='row'><span class='label'>Receipt Number:</span> <span class='value'>" + receiptNo + @"</span></div>
            <div class='row'><span class='label'>Amount:</span> <span class='value'>Rs. " + price + @"</span></div>
            <div class='row'><span class='label'>Date & Time:</span> <span class='value'>" + date + @"</span></div>
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


        protected void CNIC_TextChanged(object sender, EventArgs e)
        {
            string input = CNIC.Text.Trim().ToUpper();
            string formType = DropDownList1.SelectedItem.Text;

            bool isCNIC = System.Text.RegularExpressions.Regex.IsMatch(
                input, @"^\d{5}-\d{7}-\d$");

            bool isPassport = System.Text.RegularExpressions.Regex.IsMatch(
                input, @"^[A-Z]{2}\d{7}$");

            if (!isCNIC && !isPassport)
            {
                lblMessage.Text = "⛔ Invalid CNIC or Passport format!";
                lblMessage.CssClass = "status-message text-error";
                DisableFormControls(this);
                CNIC.Enabled = true;
                CNIC.Focus();
                return;
            }

            

            if (DropDownList1.SelectedIndex == 0)
            {
                lblMessage.Text = "⚠️ Please select Form Type first!";
                lblMessage.CssClass = "status-message text-error";
                DisableFormControls(this);
                CNIC.Enabled = true;
                return;
            }

            

            using (SqlConnection con = new SqlConnection(cs))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(1) FROM FormPurchase WHERE CNIC = @CNIC AND FormType = @FormType", con);

                cmd.Parameters.AddWithValue("@CNIC", input);
                cmd.Parameters.AddWithValue("@FormType", formType);

                con.Open();
                int exists = Convert.ToInt32(cmd.ExecuteScalar());
                con.Close();

                if (exists > 0)
                {
                    lblMessage.Text = "⛔ CNIC + Form Type already registered. Cannot proceed!";
                    lblMessage.CssClass = "status-message text-error";

                    DisableFormControls(this);
                    CNIC.Enabled = true;
                    CNIC.Focus();
                }
                else
                {
                    lblMessage.Text = "✅ You may continue. No duplicate combination found.";
                    lblMessage.CssClass = "status-message text-success";

                    EnableFormControls(this);
                    CNIC.Enabled = true;
                }
            }
        }



        private void DisableFormControls(Control parent)
        {
            foreach (Control c in parent.Controls)
            {
                if (c is TextBox)
                {
                    TextBox txt = (TextBox)c;
                    if (txt.ID != "CNIC")  
                        txt.Enabled = false;
                }
                else if (c is DropDownList)
                    ((DropDownList)c).Enabled = false;
                else if (c is Button)
                {
                    ((Button)c).Enabled = false;
                }
                else if (c is CheckBox)
                    ((CheckBox)c).Enabled = false;

                if (c.HasControls())
                    DisableFormControls(c);
            }
        }

        private void EnableFormControls(Control parent)
        {
            foreach (Control c in parent.Controls)
            {
                if (c is TextBox)
                {
                    TextBox txt = (TextBox)c;
                    if (txt.ID != "CNIC") 
                        txt.Enabled = true;
                }
                else if (c is DropDownList)
                    ((DropDownList)c).Enabled = true;
                else if (c is Button)
                    ((Button)c).Enabled = true;
                else if (c is CheckBox)
                    ((CheckBox)c).Enabled = true;

                if (c.HasControls())
                    EnableFormControls(c);
            }
        }

    

        private void ShowNextReceiptNo()
{
    using (SqlConnection con = new SqlConnection(cs))
    {
        SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 1 ReceiptNo 
            FROM FormPurchase
            WHERE ReceiptNo LIKE 'RCPT-%'
            ORDER BY Id DESC", con);

        con.Open();
        object result = cmd.ExecuteScalar();
        con.Close();

        string today = DateTime.Now.ToString("yyyyMMdd");
        string nextReceiptNo;

        if (result != null)
        {
            string lastReceipt = result.ToString();
            string[] parts = lastReceipt.Split('-');

            int lastNumber = 0;

            if (parts.Length == 6 && int.TryParse(parts[2], out lastNumber))
            {
                lastNumber++;
            }
            else
            {
                lastNumber = 1; 
            }

            nextReceiptNo = string.Format("RCPT-{0}-{1:D6}", today, lastNumber);
            Response.Write(lastNumber);
        }
        else
        {
            nextReceiptNo = string.Format("RCPT-{0}-000001", today);
        }

        lblReceiptNo.Text = nextReceiptNo;
    }
}






        protected void btnSearch_Click(object sender, EventArgs e)
        {
            Response.Redirect("ApplicantSearch.aspx");
        }
    }
}
