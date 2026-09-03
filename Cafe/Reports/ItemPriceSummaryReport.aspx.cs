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

    protected void Button_Report_Click(object sender, EventArgs e)
    {
        ShowReport();
    }
    public void subReports(object sender, object e)
    {
        try
        {
//             e.DataSources.Clear();
            DataTable dt = (DataTable)Session["DynamicHeader"];
//             e.DataSources.Add(new object("DataSet2", dt));
//             e.DataSources.Add(new object("DataSetFooter", dt));
        }
        catch (Exception)
        {

        }
    }


    private void ShowReport()
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
                Response.Write("No data returned from procedure");
                return;
            }
//             ReportViewer1.Reset();

//             ReportViewer1.LocalReport.ReportPath = // Server.MapPath(...);

//             // object rds = new object("DataSet2", dt);

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



