using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Store_SelectedDateStockReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if(!Page.IsPostBack)
        {
            txtStartDate.Value = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).ToString("yyyy-MM-dd");
            txtEndDate.Value = DateTime.Now.ToString("yyyy-MM-dd");
            if (Session["hospitalid"] != null)
                ddlHospital.SelectedValue= Session["hospitalid"].ToString();
        }
    }
    protected void btnSearch_Click(object sender, EventArgs e)
    {
        bindReport();
    }
    
    protected void bindReport()
    {
        DbManager dbMgr = new DbManager();
        string StartDate = Convert.ToDateTime(txtStartDate.Value).ToString("yyyy-MM-dd");
        string EndDate = Convert.ToDateTime(txtEndDate.Value).ToString("yyyy-MM-dd");

        SqlParameter[] sqlParam = { new SqlParameter("@StartDate",StartDate),
                                    new SqlParameter("@EndDate", EndDate),
                                    new SqlParameter("@SubDept_Id", DDL_Branch.SelectedValue),
                                    new SqlParameter("@Item_Name", txtItemName.Text),
                                    new SqlParameter("@Category", DropDownList_Category.SelectedValue),
                                    new SqlParameter("@SubCategory", ddlSubCategory.SelectedValue),
                                    new SqlParameter("@Dept_ID", Dropdownlistdepartment.SelectedValue)}; 
        DataTable dt = dbMgr.ExecuteDataTable("uspSelectedDateStockReport", "STOREConnectionString", sqlParam);
        // ReportViewer disabled
    }

    [System.Web.Script.Services.ScriptMethod(), System.Web.Services.WebMethod()]
    public static List<string> SearchItems(string prefixText, int count)
    {
        List<string> items = new List<string>();
        SqlConnection conn = new SqlConnection();
        conn.ConnectionString = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "Select Item_Code,Item_Name Item_Name From Store_Items Where Item_Name LIKE '%' + @Search + '%' Or Item_Code like '%' + @Search + '%' and Is_Active=1";
        cmd.CommandType = CommandType.Text;
        cmd.Parameters.AddWithValue("@Search", prefixText);
        cmd.Connection = conn;
        conn.Open();
        SqlDataReader sdr = cmd.ExecuteReader();
        while (sdr.Read())
        {
            items.Add(sdr["Item_Name"].ToString());
        }
        return items;
    }

    public void subReports(object sender, object e)
    {
        try
        {
            DataTable dt = (DataTable)Session["DynamicHeader"];
        }
        catch (Exception)
        {
        }
    }
}
