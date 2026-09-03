using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class SearchWithdrawnApplications : System.Web.UI.Page
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
                WHERE Status = 'Withdrawn' ");

            if (!string.IsNullOrWhiteSpace(txtTrackID.Text))
            {
                sb.Append(" AND CAST(TrackID AS VARCHAR) LIKE @TrackID ");
            }
            if (!string.IsNullOrWhiteSpace(txtApplicantName.Text))
            {
                sb.Append(" AND ApplicantName LIKE @AppName ");
            }

            sb.Append(" ORDER BY TrackID DESC ");

            using (SqlCommand cmd = new SqlCommand(sb.ToString(), conn))
            {
                if (!string.IsNullOrWhiteSpace(txtTrackID.Text))
                    cmd.Parameters.AddWithValue("@TrackID", "%" + txtTrackID.Text.Trim() + "%");
                if (!string.IsNullOrWhiteSpace(txtApplicantName.Text))
                    cmd.Parameters.AddWithValue("@AppName", "%" + txtApplicantName.Text.Trim() + "%");

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvApplications.DataSource = dt;
                gvApplications.DataBind();
            }
        }
    }

    protected void gvApplications_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "PrintLetter")
        {
            int trackId = Convert.ToInt32(e.CommandArgument);
            
            // Re-use the existing printing logic from WithdrawApplication.aspx
            string printUrl = "WithdrawApplication.aspx?print=true&trackid=" + trackId;
            string script = "setTimeout(function() { window.open('" + printUrl + "', '_blank'); }, 100);";
            ScriptManager.RegisterStartupScript(this, GetType(), "PrintReport", script, true);
        }
    }
}
