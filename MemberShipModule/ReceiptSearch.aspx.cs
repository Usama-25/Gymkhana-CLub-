using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ReceiptSearch : System.Web.UI.Page
{
    string connStr = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Initial load - show latest 20 receipts for New Memberships
            BindResults();
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        gvResults.PageIndex = 0;
        BindResults();
    }

    protected void gvResults_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvResults.PageIndex = e.NewPageIndex;
        BindResults();
    }


    private void BindResults()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();

            // SQL to search for New Memberships (ReceiptType = 2)
            using (SqlCommand cmd = new SqlCommand("usp_SearchReceipts", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                
                if (!string.IsNullOrWhiteSpace(txtSearchReceiptNo.Text))
                    cmd.Parameters.Add("@ReceiptNo", SqlDbType.NVarChar, 50).Value = txtSearchReceiptNo.Text.Trim();

                if (!string.IsNullOrWhiteSpace(txtSearchApplicantNo.Text))
                    cmd.Parameters.Add("@ApplicantNo", SqlDbType.NVarChar, 50).Value = txtSearchApplicantNo.Text.Trim();

                if (!string.IsNullOrWhiteSpace(txtFromDate.Text))
                    cmd.Parameters.Add("@FromDate", SqlDbType.DateTime).Value = Convert.ToDateTime(txtFromDate.Text);

                if (!string.IsNullOrWhiteSpace(txtToDate.Text))
                    cmd.Parameters.Add("@ToDate", SqlDbType.DateTime).Value = Convert.ToDateTime(txtToDate.Text);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvResults.DataSource = dt;
                gvResults.DataBind();
            }
        }
    }
}
