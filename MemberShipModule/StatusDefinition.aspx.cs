using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class MemberShipModule_StatusDefinition : System.Web.UI.Page
{
    private string connectionString = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            BindGrids();
        }
    }

    private void BindGrids()
    {
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            string query = "SELECT TypeID, TypeName, StatusCategory FROM StatusDefinition";
            using (SqlDataAdapter da = new SqlDataAdapter(query, conn))
            {
                DataTable dt = new DataTable();
                da.Fill(dt);

                DataView dvMembership = new DataView(dt);
                dvMembership.RowFilter = "StatusCategory = 'Membership'";
                gvMembershipStatus.DataSource = dvMembership;
                gvMembershipStatus.DataBind();

                DataView dvResidential = new DataView(dt);
                dvResidential.RowFilter = "StatusCategory = 'Residential'";
                gvResidentialStatus.DataSource = dvResidential;
                gvResidentialStatus.DataBind();
            }
        }
    }

    protected void btnAddMembershipStatus_Click(object sender, EventArgs e)
    {
        string newStatus = txtNewMembershipStatus.Text.Trim();
        if (!string.IsNullOrEmpty(newStatus))
        {
            AddStatus(newStatus, "Membership");
            txtNewMembershipStatus.Text = string.Empty;
        }
    }

    protected void btnAddResidentialStatus_Click(object sender, EventArgs e)
    {
        string newStatus = txtNewResidentialStatus.Text.Trim();
        if (!string.IsNullOrEmpty(newStatus))
        {
            AddStatus(newStatus, "Residential");
            txtNewResidentialStatus.Text = string.Empty;
        }
    }

    private void AddStatus(string typeName, string statusCategory)
    {
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            string query = "INSERT INTO StatusDefinition (TypeName, StatusCategory) VALUES (@TypeName, @StatusCategory)";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@TypeName", typeName);
                cmd.Parameters.AddWithValue("@StatusCategory", statusCategory);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }
        lblMessage.Text = "{statusCategory} status added successfully.";
        lblMessage.Visible = true;
        BindGrids();
    }

    protected void gvMembershipStatus_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        int typeId = Convert.ToInt32(gvMembershipStatus.DataKeys[e.RowIndex].Value);
        DeleteStatus(typeId);
    }

    protected void gvResidentialStatus_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        int typeId = Convert.ToInt32(gvResidentialStatus.DataKeys[e.RowIndex].Value);
        DeleteStatus(typeId);
    }

    private void DeleteStatus(int typeId)
    {
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            string query = "DELETE FROM StatusDefinition WHERE TypeID = @TypeID";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@TypeID", typeId);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }
        lblMessage.Text = "Status deleted successfully.";
        lblMessage.Visible = true;
        BindGrids();
    }
}
