using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Data;
using System.Configuration;
using System.Text;

public partial class CancelKot : System.Web.UI.Page
{
    String conStr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ToString();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            txtEndDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            LoadSubDepartments();
        }
    }

    private void LoadSubDepartments()
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(conStr))
            {
                string query = "SELECT SubDept_Id, SubDept_Name FROM BasicDataInfo.dbo.SubDepartment WHERE Dept_Id = 9 ORDER BY SubDept_Name";
                SqlDataAdapter da = new SqlDataAdapter(query, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlSubDept.DataSource = dt;
                ddlSubDept.DataTextField = "SubDept_Name";
                ddlSubDept.DataValueField = "SubDept_Name";
                ddlSubDept.DataBind();

                ddlSubDept.Items.Insert(0, new ListItem("-- All Departments --", ""));
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "msg", "alert('Error loading departments: " + ex.Message.Replace("'", "") + "');", true);
        }
    }

    protected void Button_Report_Click(object sender, EventArgs e)
    {
        GenerateReport();
    }

    private void GenerateReport()
    {
        try
        {
            DataTable dt = GetReportData(
                Convert.ToDateTime(txtStartDate.Text),
                Convert.ToDateTime(txtEndDate.Text)
            );

            if (dt.Rows.Count == 0)
            {
                reportContainer.InnerHtml = "<div class='no-data'>No data found for selected criteria.</div>";
                btnPrint.Visible = false;
                return;
            }

            DataTable filteredDt = ApplyDepartmentFilter(dt);

            if (filteredDt.Rows.Count == 0)
            {
                reportContainer.InnerHtml = "<div class='no-data'>No data found for selected department.</div>";
                btnPrint.Visible = false;
                return;
            }

            string htmlReport = GenerateHtmlReport(filteredDt);
            reportContainer.InnerHtml = htmlReport;
            btnPrint.Visible = true;
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "msg", "alert('" + ex.Message.Replace("'", "") + "');", true);
        }
    }

    private string GenerateHtmlReport(DataTable dt)
    {
        StringBuilder html = new StringBuilder();

        // Group by KOT_Number
        Dictionary<string, List<DataRow>> kotGroups = new Dictionary<string, List<DataRow>>();
        foreach (DataRow row in dt.Rows)
        {
            string kotNumber = row["KOT_Number"].ToString();
            if (!kotGroups.ContainsKey(kotNumber))
                kotGroups[kotNumber] = new List<DataRow>();
            kotGroups[kotNumber].Add(row);
        }

        string deptName = ddlSubDept.SelectedItem.Text;
        if (deptName == "-- All Departments --") deptName = "All Departments";

        string fromDate = Convert.ToDateTime(txtStartDate.Text).ToString("dd-MMM-yyyy");
        string toDate = Convert.ToDateTime(txtEndDate.Text).ToString("dd-MMM-yyyy");

        // -- Report Header ------------------------------------------
        html.AppendLine("<div class='rpt-header'>");
        html.AppendLine("  <div class='rpt-org'>LAHORE GYMKHANA</div>");
        html.AppendLine("  <div class='rpt-title'>Cancelled / Delivered KOT Report</div>");
        html.AppendLine("  <div class='rpt-meta'>");
        html.AppendLine("    <span><strong>Period:</strong> " + fromDate + " &ndash; " + toDate + "</span>");
        html.AppendLine("    <span><strong>Department:</strong> " + deptName + "</span>");
        html.AppendLine("  </div>");
        html.AppendLine("</div>");

        int grandTotalKOTs = 0;
        int grandTotalItems = 0;

        // -- One table per KOT --------------------------------------
        foreach (var kot in kotGroups)
        {
            string kotNumber = kot.Key;
            var rows = kot.Value;
            var firstRow = rows[0];
            string memberNo = firstRow["MemberNo"].ToString();
            string status = firstRow["Status"].ToString();
            DateTime kotDate = Convert.ToDateTime(firstRow["CreatedAt"]);

            int kotTotalItems = 0;
            foreach (DataRow row in rows)
                kotTotalItems += Convert.ToInt32(row["Quantity"]);

            grandTotalKOTs++;
            grandTotalItems += kotTotalItems;

            // Badge colour by status
            string badgeClass = status.ToLower().Contains("cancel") ? "badge-cancelled" : "badge-delivered";

            html.AppendLine("<div class='kot-block'>");

            // KOT meta bar
            html.AppendLine("  <div class='kot-meta-bar'>");
            html.AppendLine("    <div class='kot-meta-left'>");
            html.AppendLine("      <span class='kot-label'>KOT No</span><span class='kot-value'>" + kotNumber + "</span>");
            html.AppendLine("      <span class='kot-label'>Member</span><span class='kot-value'>" + memberNo + "</span>");
            html.AppendLine("      <span class='kot-label'>Date</span><span class='kot-value'>" + kotDate.ToString("dd-MMM-yyyy") + "</span>");
            html.AppendLine("    </div>");
            html.AppendLine("    <div class='kot-meta-right'><span class='badge " + badgeClass + "'>" + status + "</span></div>");
            html.AppendLine("  </div>");

            // Items table
            html.AppendLine("  <table class='items-table'>");
            html.AppendLine("    <thead>");
            html.AppendLine("      <tr><th class='col-code'>Item Code</th><th class='col-name'>Item Name</th><th class='col-qty'>Qty</th></tr>");
            html.AppendLine("    </thead>");
            html.AppendLine("    <tbody>");
            foreach (DataRow row in rows)
            {
                html.AppendLine("      <tr>");
                html.AppendLine("        <td class='col-code'>" + row["ItemCode"].ToString() + "</td>");
                html.AppendLine("        <td class='col-name'>" + row["ItemName"].ToString() + "</td>");
                html.AppendLine("        <td class='col-qty'>" + row["Quantity"].ToString() + "</td>");
                html.AppendLine("      </tr>");
            }
            html.AppendLine("    </tbody>");
            html.AppendLine("    <tfoot>");
            html.AppendLine("      <tr><td colspan='2' class='foot-label'>Total Items</td><td class='col-qty foot-val'>" + kotTotalItems + "</td></tr>");
            html.AppendLine("    </tfoot>");
            html.AppendLine("  </table>");

            html.AppendLine("</div>"); // end kot-block
        }

        // -- Grand Total --------------------------------------------
        html.AppendLine("<div class='grand-total-bar'>");
        html.AppendLine("  <span>Grand Total KOTs: <strong>" + grandTotalKOTs + "</strong></span>");
        html.AppendLine("  <span>Grand Total Items: <strong>" + grandTotalItems + "</strong></span>");
        html.AppendLine("</div>");

        return html.ToString();
    }

    private DataTable ApplyDepartmentFilter(DataTable dt)
    {
        if (string.IsNullOrEmpty(ddlSubDept.SelectedValue) || ddlSubDept.SelectedValue == "-- All Departments --")
            return dt;

        string selectedDeptName = ddlSubDept.SelectedValue;
        DataTable filteredDt = dt.Clone();

        foreach (DataRow row in dt.Rows)
        {
            if (row["DepartmentName"].ToString() == selectedDeptName)
                filteredDt.ImportRow(row);
        }

        return filteredDt;
    }

    private DataTable GetReportData(DateTime startDate, DateTime endDate)
    {
        DataTable dt = new DataTable();

        using (SqlConnection conn = new SqlConnection(conStr))
        {
            using (SqlCommand cmd = new SqlCommand("SP_KOTCancelledDeliveredReport", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@StartDate", startDate);
                cmd.Parameters.AddWithValue("@EndDate", endDate);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }
        }

        return dt;
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
                "SELECT TOP 10 ItemCode, ItemName FROM MenuItems WHERE ItemName LIKE '%' + @Search + '%'",
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
            hfItemCode.Value = "";
    }
}




