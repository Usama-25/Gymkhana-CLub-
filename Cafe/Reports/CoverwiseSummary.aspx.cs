using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Data;
using System.Configuration;
// using Microsoft.Reporting;

public partial class CoverwiseSummary : System.Web.UI.Page
{
    String conStr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ToString();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            txtEndDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        }
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

            if (Session["DynamicHeader"] != null)
            {
                DataTable dt = (DataTable)Session["DynamicHeader"];

//                 e.DataSources.Add(new object("DataSet1", dt));
//                 e.DataSources.Add(new object("DataSetFooter", dt));
            }
        }
        catch
        {
        }
    }

    private void ShowReport()
    {
        try
        {
            DbManager dbMgr = new DbManager();

            SqlParameter[] sqlParam =
{
    new SqlParameter("@StartDate", txtStartDate.Text),
    new SqlParameter("@EndDate", txtEndDate.Text)
};

            DataTable dt = dbMgr.ExecuteDataTable(
                "CoverwiseSummary",
                "RestaurantConnectionString",
                sqlParam);

//             ReportViewer1.Reset();

            // object rds =
//                 new object("DataSet1", dt);

//             ReportViewer1.LocalReport.ReportPath =
    // Server.MapPath(...);

//             ReportViewer1.LocalReport.DataSources.Clear();
//             ReportViewer1.LocalReport.DataSources.Add(rds);

            object[] rptParams = new object[0];

            try
            {
//                 ReportViewer1.LocalReport.SetParameters(rptParams);
            }
            catch
            {
                // Ignore if RDLC parameters not created
            }

//             ReportViewer1.LocalReport.SubreportProcessing +=
//                 new SubreportProcessingEventHandler(subReports);

//             ReportViewer1.LocalReport.Refresh();

            if (Request.Browser.Browser.ToUpper() == "CHROME")
            {
//                 byte[] bytes = ReportViewer1.LocalReport.Render("PDF");

                Response.Clear();
                Response.Buffer = true;
                Response.ContentType = "application/pdf";
                Response.AddHeader(
                    "content-disposition",
                    "inline; filename=KotwiseSale.pdf");

//                 Response.BinaryWrite(bytes);
                Response.Flush();
                Response.End();
            }
            else
            {
//                 ReportViewer1.Visible = true;
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(
                this,
                this.GetType(),
                "msg",
                "alert('" + ex.Message.Replace("'", "") + "');",
                true);
        }
    }

    [System.Web.Services.WebMethod]
    [System.Web.Script.Services.ScriptMethod]
    public static List<string> SearchItems(string prefixText, int count)
    {
        List<string> items = new List<string>();

        using (SqlConnection conn = new SqlConnection(
            ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString))
        {
            SqlCommand cmd = new SqlCommand(
                "SELECT ItemCode, ItemName FROM MenuItems WHERE ItemName LIKE '%' + @Search + '%'",
                conn);

            cmd.Parameters.AddWithValue("@Search", prefixText);

            conn.Open();

            SqlDataReader sdr = cmd.ExecuteReader();

            while (sdr.Read())
            {
                items.Add(sdr["ItemCode"].ToString());
            }
        }

        return items;
    }

    protected void txtItemName_TextChanged(object sender, EventArgs e)
    {
        if (String.IsNullOrEmpty(txtItemName.Text))
        {
            hfItemCode.Value = "";
        }
    }
}




