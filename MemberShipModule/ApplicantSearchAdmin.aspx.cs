using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Form_cell.Applicant_Form
{
    public partial class ApplicantSearchAdmin : System.Web.UI.Page
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
            if (string.IsNullOrWhiteSpace(txtPurchaseBy.Text) && 
                string.IsNullOrWhiteSpace(TxtIdCArd.Text))
            {
                lblResult.Text = "⚠️ Please enter at least one search criterion.";
                lblResult.ForeColor = System.Drawing.Color.Red;
                GridView1.Visible = false;
                return;
            }

            using (SqlConnection con = new SqlConnection(cs))
            {
                // Strict Filtering Logic (Same as ApplicantSearch)
                string sql = "SELECT * FROM FormPurchase WHERE 1=1 ";
                

                
                if (!string.IsNullOrWhiteSpace(txtPurchaseBy.Text))
                    sql += " AND PurchaseBy LIKE @PurchaseBy + '%'"; // Starts with check
                
                if (!string.IsNullOrWhiteSpace(TxtIdCArd.Text))
                    sql += " AND CNIC = @CNIC"; // Strict Equality

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
                        : "❌ No record found.";

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
                lblMessage.Text = "📥 Record ID {id} marked as received!";
                lblMessage.ForeColor = System.Drawing.Color.Blue;
                // optional DB update...
            }
            else if (e.CommandName == "Add")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                lblMessage.Text = "✅ Record ID {id} added successfully!";
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

