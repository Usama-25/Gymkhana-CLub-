//using System;
//using System.Collections.Generic;
//using System.Configuration;
//using System.Data;
//using System.Data.SqlClient;
//using System.Web.UI;
//using System.Web.UI.WebControls;

//public partial class SiteSports : MasterPage
//{
//    protected void Page_Load(object sender, EventArgs e)
//    {
//        if (!IsPostBack)
//        {
//            // Display user info if logged in
//            object userNameObj = Session["UserName"] ?? Session["Username"];
//            object empNameObj = Session["EmpName"] ?? Session["emp_name"];
//            object empIdObj = Session["emp_id"] ?? Session["Emp_ID"];

//            if (userNameObj != null || empNameObj != null)
//            {
//                string displayName = empNameObj != null ? empNameObj.ToString() : userNameObj.ToString();
//                string empIdStr = empIdObj != null ? " (" + empIdObj.ToString() + ")" : "";
//                lblUser.Text = displayName + empIdStr;
//            }
//            else
//            {
//                lblUser.Text = "Guest User";
//            }

//            if (Session["UserRole"] != null)
//            {
//                lblRole.Text = Session["UserRole"].ToString();
//            }
//            else
//            {
//                lblRole.Text = "Staff Member";
//            }

//            // Session check - redirect to Login.aspx if not authenticated
//            if (empIdObj == null && userNameObj == null)
//            {
//                if (!Request.RawUrl.ToLower().Contains("~/Login.aspx"))
//                {
//                    Response.Redirect("~/Login.aspx");
//                }
//            }
//            else
//            {
//                // Load dynamic menu if user is logged in
//                LoadDynamicMenu();

//                // Fallback initialization of AllowedSportsNames if null
//                if (Session["AllowedSportsNames"] == null)
//                {
//                    InitializeUserSportsNames();
//                }
//            }
//        }
//    }

//    private void LoadDynamicMenu()
//    {
//        int empId = 0;
//        object empIdObj = Session["emp_id"] ?? Session["Emp_ID"];
//        if (empIdObj != null)
//            int.TryParse(empIdObj.ToString(), out empId);

//        if (empId <= 0)
//        {
//            if (rptModules != null)
//            {
//                rptModules.DataSource = null;
//                rptModules.DataBind();
//            }
//            return;
//        }

//        var connObj = ConfigurationManager.ConnectionStrings["Users_ConnectionString"]
//                   ?? ConfigurationManager.ConnectionStrings["SportsConnString"];
//        if (connObj == null) return;

//        string connStr = connObj.ConnectionString;

//        DataTable dtModules = new DataTable();

//        try
//        {
//            using (SqlConnection con = new SqlConnection(connStr))
//            {
//                using (SqlCommand cmd = new SqlCommand("usp_MainMenu", con))
//                {
//                    cmd.CommandType = CommandType.StoredProcedure;
//                    cmd.Parameters.AddWithValue("@EmpId", empId);

//                    SqlDataAdapter da = new SqlDataAdapter(cmd);
//                    da.Fill(dtModules);
//                }
//            }

//            if (rptModules != null)
//            {
//                rptModules.DataSource = dtModules;
//                rptModules.DataBind();
//            }
//        }
//        catch (Exception ex)
//        {
//            System.Diagnostics.Debug.WriteLine("Error loading dynamic menu: " + ex.Message);
//        }
//    }

//    protected void rptModules_ItemDataBound(object sender, RepeaterItemEventArgs e)
//    {
//        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
//        {
//            DataRowView row = (DataRowView)e.Item.DataItem;
//            if (!row.Row.Table.Columns.Contains("Module_ID")) return;

//            int moduleId = Convert.ToInt32(row["Module_ID"]);

//            int empId = 0;
//            object empIdObj = Session["emp_id"] ?? Session["Emp_ID"];
//            if (empIdObj != null)
//                int.TryParse(empIdObj.ToString(), out empId);

//            if (empId <= 0) return;

//            Repeater rptPages = (Repeater)e.Item.FindControl("rptPages");
//            if (rptPages == null) return;

//            var connObj = ConfigurationManager.ConnectionStrings["Users_ConnectionString"]
//                       ?? ConfigurationManager.ConnectionStrings["SportsConnString"];
//            if (connObj == null) return;

//            string connStr = connObj.ConnectionString;

//            DataTable dtPages = new DataTable();

//            try
//            {
//                using (SqlConnection con = new SqlConnection(connStr))
//                {
//                    using (SqlCommand cmd = new SqlCommand("usp_SubMenu", con))
//                    {
//                        cmd.CommandType = CommandType.StoredProcedure;
//                        cmd.Parameters.AddWithValue("@EmpId", empId);
//                        cmd.Parameters.AddWithValue("@ModuleId", moduleId);

//                        SqlDataAdapter da = new SqlDataAdapter(cmd);
//                        da.Fill(dtPages);
//                    }
//                }

//                if (dtPages != null && dtPages.Rows.Count > 0)
//                {
//                    rptPages.DataSource = dtPages;
//                    rptPages.DataBind();
//                }
//                else
//                {
//                    rptPages.DataSource = null;
//                    rptPages.DataBind();
//                }
//            }
//            catch (Exception ex)
//            {
//                System.Diagnostics.Debug.WriteLine("Error loading sub menu: " + ex.Message);
//                rptPages.DataSource = null;
//                rptPages.DataBind();
//            }
//        }
//    }

//    public string GetModuleName(object dataItem)
//    {
//        if (dataItem == null) return "";
//        DataRowView row = dataItem as DataRowView;
//        if (row == null) return "";

//        if (row.Row.Table.Columns.Contains("Module_Name") && row["Module_Name"] != DBNull.Value)
//            return row["Module_Name"].ToString();
//        if (row.Row.Table.Columns.Contains("ModuleName") && row["ModuleName"] != DBNull.Value)
//            return row["ModuleName"].ToString();

//        return "";
//    }

//    protected void btnLoadMore_Click(object sender, EventArgs e)
//    {
//        int empId = 0;
//        object empIdObj = Session["Emp_ID"] ?? Session["emp_id"];
//        if (empIdObj != null)
//            int.TryParse(empIdObj.ToString(), out empId);

//        if (empId == 0) return;

//        try
//        {
//            var connObj = ConfigurationManager.ConnectionStrings["Users_ConnectionString"]
//                       ?? ConfigurationManager.ConnectionStrings["SportsConnString"];
//            if (connObj == null) return;

//            string conn = connObj.ConnectionString;

//            bool isExpanded = (ViewState["ModulesExpanded"] != null && (bool)ViewState["ModulesExpanded"]);

//            if (!isExpanded)
//            {
//                DataTable dtAllModules = new DataTable();

//                string query = @"
//                    SELECT DISTINCT 
//                        Admin_User_Module.Module_ID, 
//                        Admin_User_Module.Module_Name,
//                        Admin_Employee_Module_Pages.ModulePriority AS val 
//                    FROM Admin_User_Module 
//                    INNER JOIN Admin_Employee_Module_Pages 
//                        ON Admin_User_Module.Module_ID = Admin_Employee_Module_Pages.Module_ID 
//                    WHERE Admin_Employee_Module_Pages.Emp_ID = @EmpId
//                        AND (Admin_User_Module.type = 1 OR Admin_User_Module.For_Main_Page = 1)
//                    ORDER BY val ASC";

//                using (SqlConnection con = new SqlConnection(conn))
//                using (SqlCommand cmd = new SqlCommand(query, con))
//                {
//                    cmd.CommandType = CommandType.Text;
//                    cmd.Parameters.Add("@EmpId", SqlDbType.Int).Value = empId;

//                    SqlDataAdapter da = new SqlDataAdapter(cmd);
//                    da.Fill(dtAllModules);
//                }

//                if (rptModules != null)
//                {
//                    rptModules.DataSource = dtAllModules;
//                    rptModules.DataBind();
//                }

//                if (btnLoadMore != null)
//                {
//                    btnLoadMore.Text = "<i class='fas fa-chevron-up'></i> Load Less";
//                }
//                ViewState["ModulesExpanded"] = true;
//            }
//            else
//            {
//                DataTable dtModules = new DataTable();

//                using (SqlConnection con = new SqlConnection(conn))
//                using (SqlCommand cmd = new SqlCommand("usp_MainMenu", con))
//                {
//                    cmd.CommandType = CommandType.StoredProcedure;
//                    cmd.Parameters.Add("@EmpId", SqlDbType.Int).Value = empId;

//                    SqlDataAdapter da = new SqlDataAdapter(cmd);
//                    da.Fill(dtModules);
//                }

//                if (rptModules != null)
//                {
//                    rptModules.DataSource = dtModules;
//                    rptModules.DataBind();
//                }

//                if (btnLoadMore != null)
//                {
//                    btnLoadMore.Text = "<i class='fas fa-chevron-down'></i> Load More Modules";
//                }
//                ViewState["ModulesExpanded"] = false;
//            }

//            if (upSidebar != null)
//                upSidebar.Update();
//        }
//        catch (Exception ex)
//        {
//            Response.Write("<br><b>Load More Error:</b> " + ex.Message);
//        }
//    }

//    public void RefreshSidebar()
//    {
//        LoadDynamicMenu();

//        if (upSidebar != null)
//            upSidebar.Update();
//    }

//    private void InitializeUserSportsNames()
//    {
//        object empIdObj = Session["Emp_ID"] ?? Session["emp_id"];
//        if (empIdObj == null) return;
//        int empId = Convert.ToInt32(empIdObj);
//        string role = Session["UserRole"] != null ? Session["UserRole"].ToString() : "";

//        if (role == "Admin")
//        {
//            Session["AllowedSportsNames"] = "All Sports";
//            return;
//        }

//        List<string> sports = new List<string>();
//        string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;
//        try
//        {
//            using (SqlConnection con = new SqlConnection(connString))
//            {
//                string query = "SELECT s.SportName FROM UserSports us INNER JOIN Sports s ON us.SportID = s.SportID WHERE us.Emp_ID = @EmpID";
//                using (SqlCommand cmd = new SqlCommand(query, con))
//                {
//                    cmd.Parameters.AddWithValue("@EmpID", empId);
//                    con.Open();
//                    using (SqlDataReader reader = cmd.ExecuteReader())
//                    {
//                        while (reader.Read())
//                        {
//                            sports.Add(reader["SportName"].ToString());
//                        }
//                    }
//                }
//            }
//            Session["AllowedSportsNames"] = sports.Count > 0 ? string.Join(", ", sports) : "No Sports";
//        }
//        catch
//        {
//            Session["AllowedSportsNames"] = "No Sports";
//        }
//    }

//    protected void lnkLogout_Click(object sender, EventArgs e)
//    {
//        Session.Clear();
//        Session.Abandon();
//        Response.Redirect("~/Login.aspx");
//    }
//}




using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class SiteSports : MasterPage
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
                lblUser.Text = "Guest User";
            }

            if (Session["UserRole"] != null)
            {
                lblRole.Text = Session["UserRole"].ToString();
            }
            else
            {
                lblRole.Text = "Staff Member";
            }

            // Session check - redirect to Login.aspx if not authenticated
            if (empIdObj == null && userNameObj == null)
            {
                if (!Request.RawUrl.ToLower().Contains("login.aspx"))
                {
                    Response.Redirect("~/Login.aspx");
                }
            }
            else
            {
                // Load dynamic menu if user is logged in
                LoadDynamicMenu();

                // Fallback initialization of AllowedSportsNames if null
                if (Session["AllowedSportsNames"] == null)
                {
                    InitializeUserSportsNames();
                }
            }
        }
    }

    private void LoadDynamicMenu()
    {
        int empId = 0;
        object empIdObj = Session["emp_id"] ?? Session["Emp_ID"];
        if (empIdObj != null)
            int.TryParse(empIdObj.ToString(), out empId);

        if (empId <= 0)
        {
            if (rptModules != null)
            {
                rptModules.DataSource = null;
                rptModules.DataBind();
            }
            return;
        }

        var connObj = ConfigurationManager.ConnectionStrings["Users_ConnectionString"]
                   ?? ConfigurationManager.ConnectionStrings["SportsConnString"];
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

            if (rptModules != null)
            {
                rptModules.DataSource = dtModules;
                rptModules.DataBind();
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading dynamic menu: " + ex.Message);
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
                       ?? ConfigurationManager.ConnectionStrings["SportsConnString"];
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
                else
                {
                    rptPages.DataSource = null;
                    rptPages.DataBind();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading sub menu: " + ex.Message);
                rptPages.DataSource = null;
                rptPages.DataBind();
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

    public string GetPageUrl(object dataItem)
    {
        if (dataItem == null) return "#";
        DataRowView row = dataItem as DataRowView;
        if (row == null) return "#";

        if (row.Row.Table.Columns.Contains("Page_Url") && row["Page_Url"] != DBNull.Value)
            return row["Page_Url"].ToString();
        if (row.Row.Table.Columns.Contains("PageUrl") && row["PageUrl"] != DBNull.Value)
            return row["PageUrl"].ToString();
        if (row.Row.Table.Columns.Contains("URL") && row["URL"] != DBNull.Value)
            return row["URL"].ToString();
        if (row.Row.Table.Columns.Contains("Url") && row["Url"] != DBNull.Value)
            return row["Url"].ToString();
        if (row.Row.Table.Columns.Contains("Page_Name") && row["Page_Name"] != DBNull.Value && row["Page_Name"].ToString().EndsWith(".aspx", StringComparison.OrdinalIgnoreCase))
            return row["Page_Name"].ToString();

        return "#";
    }

    public string GetPageName(object dataItem)
    {
        if (dataItem == null) return "";
        DataRowView row = dataItem as DataRowView;
        if (row == null) return "";

        if (row.Row.Table.Columns.Contains("Page_Name") && row["Page_Name"] != DBNull.Value)
            return row["Page_Name"].ToString();
        if (row.Row.Table.Columns.Contains("PageName") && row["PageName"] != DBNull.Value)
            return row["PageName"].ToString();
        if (row.Row.Table.Columns.Contains("Page_Title") && row["Page_Title"] != DBNull.Value)
            return row["Page_Title"].ToString();
        if (row.Row.Table.Columns.Contains("Title") && row["Title"] != DBNull.Value)
            return row["Title"].ToString();

        return "";
    }

    public string GetPageIcon(object dataItem)
    {
        if (dataItem == null) return "fas fa-circle";
        DataRowView row = dataItem as DataRowView;
        if (row == null) return "fas fa-circle";

        if (row.Row.Table.Columns.Contains("Page_Icon") && row["Page_Icon"] != DBNull.Value && !string.IsNullOrWhiteSpace(row["Page_Icon"].ToString()))
            return row["Page_Icon"].ToString();
        if (row.Row.Table.Columns.Contains("Icon") && row["Icon"] != DBNull.Value && !string.IsNullOrWhiteSpace(row["Icon"].ToString()))
            return row["Icon"].ToString();

        return "fas fa-circle";
    }

    protected void btnLoadMore_Click(object sender, EventArgs e)
    {
        int empId = 0;
        object empIdObj = Session["Emp_ID"] ?? Session["emp_id"];
        if (empIdObj != null)
            int.TryParse(empIdObj.ToString(), out empId);

        if (empId == 0) return;

        try
        {
            var connObj = ConfigurationManager.ConnectionStrings["Users_ConnectionString"]
                       ?? ConfigurationManager.ConnectionStrings["SportsConnString"];
            if (connObj == null) return;

            string conn = connObj.ConnectionString;

            bool isExpanded = (ViewState["ModulesExpanded"] != null && (bool)ViewState["ModulesExpanded"]);

            if (!isExpanded)
            {
                DataTable dtAllModules = new DataTable();

                string query = @"
                    SELECT DISTINCT 
                        Admin_User_Module.Module_ID, 
                        Admin_User_Module.Module_Name,
                        Admin_Employee_Module_Pages.ModulePriority AS val 
                    FROM Admin_User_Module 
                    INNER JOIN Admin_Employee_Module_Pages 
                        ON Admin_User_Module.Module_ID = Admin_Employee_Module_Pages.Module_ID 
                    WHERE Admin_Employee_Module_Pages.Emp_ID = @EmpId
                        AND (Admin_User_Module.type = 1 OR Admin_User_Module.For_Main_Page = 1)
                    ORDER BY val ASC";

                using (SqlConnection con = new SqlConnection(conn))
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.CommandType = CommandType.Text;
                    cmd.Parameters.Add("@EmpId", SqlDbType.Int).Value = empId;

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dtAllModules);
                }

                if (rptModules != null)
                {
                    rptModules.DataSource = dtAllModules;
                    rptModules.DataBind();
                }

                if (btnLoadMore != null)
                {
                    btnLoadMore.Text = "<i class='fas fa-chevron-up'></i> Load Less";
                }
                ViewState["ModulesExpanded"] = true;
            }
            else
            {
                DataTable dtModules = new DataTable();

                using (SqlConnection con = new SqlConnection(conn))
                using (SqlCommand cmd = new SqlCommand("usp_MainMenu", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@EmpId", SqlDbType.Int).Value = empId;

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dtModules);
                }

                if (rptModules != null)
                {
                    rptModules.DataSource = dtModules;
                    rptModules.DataBind();
                }

                if (btnLoadMore != null)
                {
                    btnLoadMore.Text = "<i class='fas fa-chevron-down'></i> Load More Modules";
                }
                ViewState["ModulesExpanded"] = false;
            }

            if (upSidebar != null)
                upSidebar.Update();
        }
        catch (Exception ex)
        {
            Response.Write("<br><b>Load More Error:</b> " + ex.Message);
        }
    }

    public void RefreshSidebar()
    {
        LoadDynamicMenu();

        if (upSidebar != null)
            upSidebar.Update();
    }

    private void InitializeUserSportsNames()
    {
        object empIdObj = Session["Emp_ID"] ?? Session["emp_id"];
        if (empIdObj == null) return;
        int empId = Convert.ToInt32(empIdObj);
        string role = Session["UserRole"] != null ? Session["UserRole"].ToString() : "";

        if (role == "Admin")
        {
            Session["AllowedSportsNames"] = "All Sports";
            return;
        }

        List<string> sports = new List<string>();
        string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = "SELECT s.SportName FROM UserSports us INNER JOIN Sports s ON us.SportID = s.SportID WHERE us.Emp_ID = @EmpID";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@EmpID", empId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            sports.Add(reader["SportName"].ToString());
                        }
                    }
                }
            }
            Session["AllowedSportsNames"] = sports.Count > 0 ? string.Join(", ", sports) : "No Sports";
        }
        catch
        {
            Session["AllowedSportsNames"] = "No Sports";
        }
    }

    protected void lnkLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        Response.Redirect("~/Login.aspx");
    }
}
