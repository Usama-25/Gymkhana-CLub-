using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Data;
using System.Configuration;
// using Microsoft.Reporting;

public partial class Store_Cash_Sale_Invoice_Wise : System.Web.UI.Page
{
    String conStr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ToString();
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            txtStartDate.Text = (DateTime.Now.AddYears(0)).ToString("yyyy-MM-dd");
            txtEndDate.Text = (DateTime.Now).ToString("yyyy-MM-dd");
            getSubDepts();
            ddlSubDept.SelectedValue = "408";
        }
    }
    private void getSubDepts()
    {
        SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString);

        SqlCommand cmd = new SqlCommand("select * from SubDepartment ", conn);

        SqlDataAdapter sda = new SqlDataAdapter(cmd);
        DataTable dt = new DataTable();
        sda.Fill(dt);
        ddlSubDept.DataSource = dt;

        ddlSubDept.DataTextField = "SubDept_Name";
        ddlSubDept.DataValueField = "SubDept_Id";
        ddlSubDept.DataBind();
        try
        {
            DbManager dbm = new DbManager();
            SqlParameter[] sp = new[] { new SqlParameter("@EmpID", Session["emp_id"]) };
            string str = "Select Main_Subdept_ID From requisition_department_filter Where Requisition_Type='PHARMACY' and EmpID=@EmpID";

            DataTable dt1 = dbm.ExecuteDataTableWithQuery(str, "STOREConnectionString", sp);
            if ((dt1.Rows.Count > 0))
            {
                if ((dt1.Rows.Count == 1))
                    ddlSubDept.SelectedValue = dt1.Rows[0][0].ToString();
                else
                    ddlSubDept.SelectedValue = Session["subdeptid"].ToString();
            }
        }
        catch (Exception)
        {
        }
    }

    protected void Button_Report_Click(object sender, EventArgs e)
    {
        try
        {
            ShowReport();
        }
        catch (Exception)
        {

        }

    }

    public void subReports(object sender, object e)
    {
        try
        {
//             e.DataSources.Clear();
            DataTable dt = (DataTable)Session["DynamicHeader"];
//             e.DataSources.Add(new object("DataSet1", dt));
//             e.DataSources.Add(new object("DataSetFooter", dt));
        }
        catch (Exception)
        {

        }
    }

    private void ShowReport()
    {
        string StartDate = Convert.ToDateTime(txtStartDate.Text).ToString("yyyy-MM-dd");
        string EndDate = Convert.ToDateTime(txtEndDate.Text).ToString("yyyy-MM-dd");
        try
        {
            if (txtItemName.Text == "")
            {
                hfItemCode.Value = "";
            }
            DbManager dbMgr = new DbManager();
            SqlParameter[] sqlParam = { new SqlParameter("@start_Date", txtStartDate.Text),
                                        new SqlParameter("@End_Date", txtEndDate.Text)
                                        //new SqlParameter("@item_code", hfItemCode.Value),
                                        //new SqlParameter("@SubdeptID", ddlSubDept.SelectedValue)
                                        };
            DataTable dt = new DataTable();
            dt = dbMgr.ExecuteDataTable("sp_GetSaleByMenu_Type", "RestaurantConnectionString", sqlParam);
//             object object = new object();

            // Must match the DataSource in the RDLC
            // object.Name = "DataSet1";//coordinates in your case.
            // object.Value = dt;

//             ReportViewer1.LocalReport.DataSources.Clear();
//             ReportViewer1.LocalReport.ReportPath = // Server.MapPath(...);
//             ReportViewer1.LocalReport.DataSources.Clear();

//             ReportViewer1.LocalReport.DataSources.Add(object);
//             object rp = new object("Satrt_Date", StartDate);
//             object rp2 = new object("End_Date", EndDate);

//             ReportViewer1.LocalReport.SetParameters(new object[] { rp,rp2 });
//             ReportViewer1.LocalReport.DataSources.Add(object);
//             ReportViewer1.LocalReport.SubreportProcessing += new SubreportProcessingEventHandler(subReports);
//             ReportViewer1.LocalReport.Refresh();
            if (Request.Browser.Browser == "Chrome")
            {
//                 byte[] bytes = ReportViewer1.LocalReport.Render("PDF");

                Response.Clear();
                Response.AddHeader("Content-Disposition", "inline; filename=MyReport.pdf");
                Response.ContentType = "application/pdf";
//                 Response.BinaryWrite(bytes);
                Response.End();
            }
            else
            {
//                 ReportViewer1.Visible = true;
            }
        }
        catch (Exception)
        {
        }

    }

    [System.Web.Script.Services.ScriptMethod(), System.Web.Services.WebMethod()]
    public static List<string> SearchItems(string prefixText, int count)
    {
        List<string> items = new List<string>();
        SqlConnection conn = new SqlConnection();
        conn.ConnectionString = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "Select ItemCode,ItemName From MenuItems Where ItemName LIKE '%' + @Search + '%'";
        cmd.CommandType = CommandType.Text;
        cmd.Parameters.AddWithValue("@Search", prefixText);
        cmd.Connection = conn;
        conn.Open();
        SqlDataReader sdr = cmd.ExecuteReader();
        while (sdr.Read())
        {
            items.Add(sdr["ItemCode"].ToString());
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



