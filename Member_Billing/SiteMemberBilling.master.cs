using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Member_Billing_SiteMemberBilling : MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Display user info if logged in
            object userNameObj = Session["UserName"] ?? Session["Username"];
            object empNameObj = Session["EmpName"] ?? Session["emp_name"];
            object empIdObj = Session["emp_id"] ?? Session["Emp_ID"];

            if (userNameObj != null || empNameObj != null)
            {
                string displayName = empNameObj != null ? empNameObj.ToString() : userNameObj.ToString();
                string empIdStr = empIdObj != null ? " (" + empIdObj.ToString() + ")" : "";
                lblUser.Text = displayName + empIdStr;
            }
            else
            {
                lblUser.Text = "Administrator";
            }

            if (Session["UserRole"] != null)
            {
                lblRole.Text = Session["UserRole"].ToString();
            }
            else
            {
                lblRole.Text = "Billing Officer";
            }

            // Load Dynamic Menus if logged in
            LoadDynamicMenu();
        }
    }

    private void LoadDynamicMenu()
    {
        int empId = 0;
        object empIdObj = Session["emp_id"] ?? Session["Emp_ID"];
        if (empIdObj != null)
            int.TryParse(empIdObj.ToString(), out empId);

        if (empId <= 0) return;

        var connObj = ConfigurationManager.ConnectionStrings["Users_ConnectionString"]
                   ?? ConfigurationManager.ConnectionStrings["UsersConnectionString"]
                   ?? ConfigurationManager.ConnectionStrings["MemberShipConnection"];
        if (connObj == null) return;

        string connStr = connObj.ConnectionString;
        DataTable dtModules = new DataTable();

        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("usp_MainMenu", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@EmpId", empId);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dtModules);
                }
            }

            if (rptModules != null && dtModules.Rows.Count > 0)
            {
                rptModules.DataSource = dtModules;
                rptModules.DataBind();
            }
        }
        catch
        {
            // Fallback silently if stored procedure is not configured for this user
        }
    }

    protected void rptModules_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            DataRowView row = (DataRowView)e.Item.DataItem;
            if (!row.Row.Table.Columns.Contains("Module_ID")) return;

            int moduleId = Convert.ToInt32(row["Module_ID"]);

            int empId = 0;
            object empIdObj = Session["emp_id"] ?? Session["Emp_ID"];
            if (empIdObj != null)
                int.TryParse(empIdObj.ToString(), out empId);

            if (empId <= 0) return;

            Repeater rptPages = (Repeater)e.Item.FindControl("rptPages");
            if (rptPages == null) return;

            var connObj = ConfigurationManager.ConnectionStrings["Users_ConnectionString"]
                       ?? ConfigurationManager.ConnectionStrings["UsersConnectionString"]
                       ?? ConfigurationManager.ConnectionStrings["MemberShipConnection"];
            if (connObj == null) return;

            string connStr = connObj.ConnectionString;
            DataTable dtPages = new DataTable();

            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    using (SqlCommand cmd = new SqlCommand("usp_SubMenu", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@EmpId", empId);
                        cmd.Parameters.AddWithValue("@ModuleId", moduleId);

                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        da.Fill(dtPages);
                    }
                }

                if (dtPages != null && dtPages.Rows.Count > 0)
                {
                    rptPages.DataSource = dtPages;
                    rptPages.DataBind();
                }
            }
            catch
            {
                // Ignore sub menu load failures gracefully
            }
        }
    }

    public string GetModuleName(object dataItem)
    {
        if (dataItem == null) return "";
        DataRowView row = dataItem as DataRowView;
        if (row == null) return "";

        if (row.Row.Table.Columns.Contains("Module_Name") && row["Module_Name"] != DBNull.Value)
            return row["Module_Name"].ToString();
        if (row.Row.Table.Columns.Contains("ModuleName") && row["ModuleName"] != DBNull.Value)
            return row["ModuleName"].ToString();

        return "";
    }

    protected void lnkLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        Response.Redirect("~/Login.aspx");
    }
}
