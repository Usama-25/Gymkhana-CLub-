using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RefundFee
{
    public partial class MemberSearchFroSupport : Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;
        string basicConnStr = ConfigurationManager.ConnectionStrings["BasicDataInfoConnectionString"].ConnectionString;
        string storeConnStr = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
               
            }
            BindDepartments();

            lblMessage.Text = "";
        }

        private void BindDepartments()
        {
            using (SqlConnection con = new SqlConnection(basicConnStr))
            {
                SqlCommand cmd = new SqlCommand("select Dept_ID,Dept_Name from Department order by Dept_Name asc", con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlDepartment.DataSource = dt;
                ddlDepartment.DataTextField = "Dept_Name";
                ddlDepartment.DataValueField = "Dept_ID";
                ddlDepartment.DataBind();

                ddlDepartment.Items.Insert(0, new ListItem("--Select Department--", "0"));
            }
        }



        private void BindMembers()
        {
            int? deptId = null;

            if (!string.IsNullOrEmpty(ddlDepartment.SelectedValue))
                deptId = Convert.ToInt32(ddlDepartment.SelectedValue);

            BindMembers_SP(
                deptId,
                txtMemberNo.Text.Trim(),
                txtCardNo.Text.Trim(),
                Name.Text.Trim(),
                txtNIC.Text.Trim()
            );
        }


        private void BindMembers_SP(
            int? deptId,
            string memberNo,
            string cardNo,
            string applicantName,
            string nic
        )
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd =
                    new SqlCommand("sp_SearchMemberForSport", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    
                    cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                    cmd.Parameters.AddWithValue("@CardNo", cardNo);
                    cmd.Parameters.AddWithValue("@ApplicantName", applicantName);
                    cmd.Parameters.AddWithValue("@NIC", nic);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    GridViewBatchStock.DataSource = dt;
                    GridViewBatchStock.DataBind();
                }
            }
        }


        protected void btnSaveCard_Click(object sender, EventArgs e)
        {
            BindMembers();
        }


        

    }
}
