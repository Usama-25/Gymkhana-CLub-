using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

public partial class MembershipProfile : System.Web.UI.Page
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
            LoadEstimatedInterviewList();
            LoadLastInterviewList();
            BindApplicantGrid();
        }
    }

    private void LoadEstimatedInterviewList()
    {
        SqlConnection con = new SqlConnection(connStr);
        string query = @"
            SELECT top 100
                MIN(a.ApplicantID) AS FirstApplicantID,
                MAX(a.ApplicantID) AS LastApplicantID
            FROM ApplicationFForm a         
            WHERE a.Status = 'Pending';
        ";

        using (SqlCommand cmd = new SqlCommand(query, con))
        {
            con.Open();
            SqlDataReader dr = cmd.ExecuteReader();
            if (dr.Read())
            {
                var firstID = dr["FirstApplicantID"] != DBNull.Value ? dr["FirstApplicantID"].ToString() : "N/A";
                var lastID = dr["LastApplicantID"] != DBNull.Value ? dr["LastApplicantID"].ToString() : "N/A";

               
                lblEstimatedInterview.Text = string.Format("{0}-{1}", firstID, lastID);
            }
            con.Close();
        }
    }


    private void LoadLastInterviewList()
    {
        SqlConnection con = new SqlConnection(connStr);
        string query = @"
       SELECT 
           MIN(a.ApplicantID) AS FirstApplicantID,
           MAX(a.ApplicantID) AS LastApplicantID
       FROM ApplicationFForm a
       WHERE a.Status <> 'Pending'"; 

        using (SqlCommand cmd = new SqlCommand(query, con))
        {
            con.Open();
            SqlDataReader dr = cmd.ExecuteReader();
            if (dr.Read())
            {
                var firstID = dr["FirstApplicantID"] != DBNull.Value ? dr["FirstApplicantID"].ToString() : "N/A";
                var lastID = dr["LastApplicantID"] != DBNull.Value ? dr["LastApplicantID"].ToString() : "N/A";

                
                lblLastInterview.Text = string.Format("{0}-{1}", firstID, lastID);
            }
            con.Close();
        }

    }
    protected void btnSearch_Click(object sender, EventArgs e)
    {
        BindApplicantGrid(); 
    }

    private void BindApplicantGrid()
    {
       
        string name = string.IsNullOrEmpty(txtName.Text) ? null : txtName.Text.Trim();
        string nic = string.IsNullOrEmpty(txtcna.Text) ? null : txtcna.Text.Trim();
        string phone = string.IsNullOrEmpty(txtPhone.Text) ? null : txtPhone.Text.Trim();
        int? applicantId = null;
        if (!string.IsNullOrEmpty(txtIDApplicant.Text))
            applicantId = Convert.ToInt32(txtIDApplicant.Text.Trim());

        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString))
        {
            using (SqlCommand cmd = new SqlCommand("SerialView", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

               
                cmd.Parameters.AddWithValue("@Name", (object)name ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@NIC", (object)nic ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Phone", (object)phone ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@ApplicantID", (object)applicantId ?? DBNull.Value);

                
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvApplicants.DataSource = dt;
                gvApplicants.DataBind();
            }
        }
    }



}
