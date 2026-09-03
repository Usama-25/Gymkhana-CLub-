using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
// using Microsoft.Reporting;

public partial class ItemPriceSummaryReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
    }

    protected void btnShow_Click(object sender, EventArgs e)
    {
        LoadReport();
    }

    private void LoadReport()
    {
        try
        {
            string connStr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;

            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("GetActiveMenuItems", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    conn.Open();
                    da.Fill(dt);
                }
            }

            if (dt.Rows.Count == 0)
            {
                Response.Write("No data found");
                return;
            }

            // ?? IMPORTANT
//             ReportViewer1.Reset();

            // RDLC Path
//             ReportViewer1.LocalReport.ReportPath = // Server.MapPath(...);

            // Dataset must match RDLC ? DataSet1
//             // object rds = new object("DataSet1", dt);

//             ReportViewer1.LocalReport.DataSources.Clear();
//             ReportViewer1.LocalReport.DataSources.Add(rds);

//             ReportViewer1.LocalReport.Refresh();
        }
        catch (Exception ex)
        {
            Response.Write("ERROR: " + ex.Message);
        }
    }
}



