using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RefundFee
{
    public partial class Interviewlist1 : Page
    {
        private string connStr
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
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "SELECT ApplicantID, ApplicantName, NIC, MFee, Remarks FROM ApplicationFForm where Status=2";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvApplicants.DataSource = dt;
                gvApplicants.DataBind();
            }
        }

        protected void gvApplicants_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Refund")
            {
                int applicantId = Convert.ToInt32(e.CommandArgument);

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = "SELECT ApplicantName, MFee, NIC FROM ApplicationFForm WHERE ApplicantID=@id And Status=2";
                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@id", applicantId);
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        lblApplicantName.Text = dr["ApplicantName"] != DBNull.Value ? dr["ApplicantName"].ToString() : "";
                        lblMFee.Text = dr["MFee"] != DBNull.Value ? dr["MFee"].ToString() : "0";

                        ViewState["SelectedApplicantID"] = applicantId;
                        ViewState["NIC"] = dr["NIC"] != DBNull.Value ? dr["NIC"].ToString() : "";
                        ViewState["MFee"] = dr["MFee"] != DBNull.Value ? dr["MFee"] : 0m;
                    }
                    dr.Close();
                    con.Close();
                }

                ScriptManager.RegisterStartupScript(this, this.GetType(), "showModal", "showModal();", true);
            }
        }

        protected void btnOkRefund_Click(object sender, EventArgs e)
        {
            if (ViewState["SelectedApplicantID"] == null)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error", "alert('No applicant selected!');", true);
                BindGrid();
                return;
            }

            int applicantId = Convert.ToInt32(ViewState["SelectedApplicantID"]);
            string applicantName = lblApplicantName.Text.Trim();
            string nic = ViewState["NIC"].ToString() ?? "";
            decimal mFee = ViewState["MFee"] != null ? Convert.ToDecimal(ViewState["MFee"]) : 0m;
            string remarks = txtRefundRemarks.Text.Trim();

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();

                
                string insertQuery = @"INSERT INTO Refund(ApplicationID, ApplicantName, NIC, MFee, Remarks, Status)
                               VALUES(@ApplicationID, @ApplicantName, @NIC, @MFee, @Remarks, 0)";

                using (SqlCommand cmd = new SqlCommand(insertQuery, con))
                {
                    cmd.Parameters.AddWithValue("@ApplicationID", applicantId);
                    cmd.Parameters.AddWithValue("@ApplicantName", applicantName);
                    cmd.Parameters.AddWithValue("@NIC", nic);
                    cmd.Parameters.AddWithValue("@MFee", mFee);
                    cmd.Parameters.AddWithValue("@Remarks", remarks);
                    cmd.ExecuteNonQuery();
                }

                
                string updateStatusQuery = "UPDATE ApplicationFForm SET Status = 2 WHERE ApplicantID = @id";

                using (SqlCommand cmd2 = new SqlCommand(updateStatusQuery, con))
                {
                    cmd2.Parameters.AddWithValue("@id", applicantId);
                    cmd2.ExecuteNonQuery();
                }

                con.Close();
            }

            
            txtRefundRemarks.Text = "";

            
            ScriptManager.RegisterStartupScript(this, GetType(), "closeModal", "closeModal(); alert('Refunded successfully!');", true);

            
            BindGrid();
        }



        protected void btnSearch_Click(object sender, EventArgs e)
        {

        }
    }
}




