using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class SiteGuestroom : MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Display user info if logged in
            if (Session["UserName"] != null)
            {
                string displayName = Session["EmpName"] != null
                    ? Session["EmpName"].ToString()
                    : Session["UserName"].ToString();

                string empId = Session["emp_id"] != null
                    ? " (" + Session["emp_id"].ToString() + ")"
                    : "";

                lblUser.Text = displayName + empId;
            }
            else
            {
                lblUser.Text = "Guest User";
            }

            // Load dynamic menu if user is logged in
            if (Session["emp_id"] != null)
            {
                LoadDynamicMenu();
                //ApplyRoleSecurity();
            }
        }
    }

    //private void ApplyRoleSecurity()
    //{
    //    string role = Session["UserRole"] != null
    //        ? Session["UserRole"].ToString()
    //        : "";

    //    // Dashboard visibility based on role
    //    liDashboard.Visible = (role == "Member" || role == "Admin");
    //    liAdminDashboard.Visible = (role == "Employee" || role == "Admin" || role == "MembershipOfficer" || role == "Committee");

    //    // Admin navigation management visible only to Admin
    //    pnlAdminNav.Visible = (role == "Admin");
    //}

    private void LoadDynamicMenu()
    {
        int empId = 0;

        if (Session["emp_id"] != null)
            int.TryParse(Session["emp_id"].ToString(), out empId);

        if (empId <= 0) return;

        var connObj = ConfigurationManager.ConnectionStrings["Users_ConnectionString"];
        if (connObj == null) return;

        string connStr = connObj.ConnectionString;

        DataTable dtModules = new DataTable();

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

        rptModules.DataSource = dtModules;
        rptModules.DataBind();
    }

    protected void rptModules_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            DataRowView row = (DataRowView)e.Item.DataItem;
            int moduleId = Convert.ToInt32(row["Module_ID"]);

            int empId = 0;

            if (Session["emp_id"] != null)
                int.TryParse(Session["emp_id"].ToString(), out empId);

            if (empId <= 0) return;

            Repeater rptPages = (Repeater)e.Item.FindControl("rptPages");

            var connObj = ConfigurationManager.ConnectionStrings["Users_ConnectionString"];
            if (connObj == null) return;

            string connStr = connObj.ConnectionString;

            DataTable dtPages = new DataTable();

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

            rptPages.DataSource = dtPages;
            rptPages.DataBind();
        }
    }

     protected void btnLoadMore_Click(object sender, EventArgs e)
    {
        int empId = 0;
        if (Session["Emp_ID"] != null)
            int.TryParse(Session["Emp_ID"].ToString(), out empId);

        if (empId == 0) return;

        try
        {
            string conn = ConfigurationManager
                .ConnectionStrings["Users_ConnectionString"]
                .ConnectionString;

            // Check current state: if already expanded, collapse back to top 10
            bool isExpanded = (ViewState["ModulesExpanded"] != null && (bool)ViewState["ModulesExpanded"]);

            if (!isExpanded)
            {
                // === LOAD MORE: Fetch ALL modules (inline query, no TOP 10) ===
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

                rptModules.DataSource = dtAllModules;
                rptModules.DataBind();

                // Switch button text to "Load Less"
                btnLoadMore.Text = "<i class='fas fa-chevron-up'></i> Load Less";
                ViewState["ModulesExpanded"] = true;
            }
            else
            {
                // === LOAD LESS: Go back to top 10 via stored procedure ===
                DataTable dtModules = new DataTable();

                using (SqlConnection con = new SqlConnection(conn))
                using (SqlCommand cmd = new SqlCommand("usp_MainMenu", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@EmpId", SqlDbType.Int).Value = empId;

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dtModules);
                }

                rptModules.DataSource = dtModules;
                rptModules.DataBind();

                // Switch button text back to "Load More"
                btnLoadMore.Text = "<i class='fas fa-chevron-down'></i> Load More Modules";
                ViewState["ModulesExpanded"] = false;
            }

            // Refresh the UpdatePanel
            upSidebar.Update();
        }
        catch (Exception ex)
        {
            Response.Write("<br><b>Load More Error:</b> " + ex.Message);
        }
    }

    // ===========================
    // 🔹 REFRESH SIDEBAR
    // ===========================
    public void RefreshSidebar()
    {
        LoadDynamicMenu();

        if (upSidebar != null)
            upSidebar.Update();
    }
}


