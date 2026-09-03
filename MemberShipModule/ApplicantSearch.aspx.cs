using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Form_cell.Applicant_Form
{
    public partial class ApplicantSearch : System.Web.UI.Page
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

                GridView1.Visible = false;
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {

           
            using (SqlConnection con = new SqlConnection(cs))
            {
                // Select from ApplicationFForm with specific statuses and aliasing for GridView compatibility
                string sql = @"
                    SELECT 
                        TrackID AS Id, 
                        ApplicantName AS PurchaseBy, 
                        Mobile AS PhoneNo, 
                        FormFee AS Price, 
                        Status,
                        NIC AS CNIC
                    FROM ApplicationFForm 
                    WHERE (Status = 'Pending' OR Status = 'Call for interview') ";
                
                if (!string.IsNullOrWhiteSpace(txtPurchaseBy.Text))
                    sql += " AND ApplicantName LIKE @PurchaseBy + '%'"; 
                
                if (!string.IsNullOrWhiteSpace(TxtIdCArd.Text))
                    sql += " AND NIC = @CNIC"; 

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    if (!string.IsNullOrWhiteSpace(txtPurchaseBy.Text))
                        cmd.Parameters.AddWithValue("@PurchaseBy", txtPurchaseBy.Text.Trim());

                    if (!string.IsNullOrWhiteSpace(TxtIdCArd.Text))
                        cmd.Parameters.AddWithValue("@CNIC", TxtIdCArd.Text.Trim());

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    GridView1.DataSource = dt;
                    GridView1.DataBind();
                    GridView1.Visible = true;

                    lblResult.Text = dt.Rows.Count > 0
                        ? "✅ Record(s) Found: " + dt.Rows.Count
                        : "❌ No record found with specified status.";

                    lblResult.ForeColor = dt.Rows.Count > 0
                        ? System.Drawing.Color.Green
                        : System.Drawing.Color.Red;
                }
            }
        }




        protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Receive")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                lblMessage.Text = string.Format("📥 Record ID {0} marked as received!", id);
                lblMessage.ForeColor = System.Drawing.Color.Blue;
                // optional DB update...
            }
            else if (e.CommandName == "Add")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                lblMessage.Text = string.Format("✅ Record ID {0} added successfully!", id);
                lblMessage.ForeColor = System.Drawing.Color.Green;
                // optional logic...
            }
        }

        

        protected void Recived_Click(object sender, EventArgs e)
        {
           
            Button btn = (Button)sender;

            
            GridViewRow row = (GridViewRow)btn.NamingContainer;

            
            int id;
            if (int.TryParse(btn.CommandArgument, out id))
            {
                
                Response.Redirect("ApplicationProcessing.aspx?id=" + id);
            }
            else
            {
                
                Response.Write("<script>alert('Invalid ID');</script>");
            }
        }



       

        protected void Addbtn(object sender, EventArgs e)
        {

            Button btn = (Button)sender;
            GridViewRow row = (GridViewRow)btn.NamingContainer;

            int id = Convert.ToInt32(btn.CommandArgument); 
            Response.Redirect("MemberFee.aspx?ID=" + id);
           
        }


    }

}

