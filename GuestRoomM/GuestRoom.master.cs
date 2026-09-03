using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class GuestRoomMaster : MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 🔐 Session check (always)
        if (Session["UserName"] == null)
        {
            Response.Redirect("~/Login.aspx");
            return;
        }

        // 👤 User display (always)
        string efName = "";
        if (Session["EFName"] != null)
            efName = Session["EFName"].ToString();

        string userName = Session["UserName"].ToString();

        string empIdText = "";
        if (Session["Emp_ID"] != null)
            empIdText = " (" + Session["Emp_ID"].ToString() + ")";

        lblUser.Text = string.IsNullOrEmpty(efName)
            ? userName + empIdText
            : efName + " (" + userName + ")" + empIdText;

        // 🔥 Convert Emp_ID properly for DB use
        int empId = 0;
        if (Session["Emp_ID"] != null)
            int.TryParse(Session["Emp_ID"].ToString(), out empId);

        // 🔹 Existing logic
        ApplyRoleSecurity();
        BindDynamicNav();

        // ✅ CALL LOAD DATA CORRECTLY
        if (empId > 0)
        {
            Load_Data(empId);
        }
    }

    // ===========================
    // 🔹 LOAD EMPLOYEE DATA
    // ===========================
    public void Load_Data(int empId)
    {
        string conString = ConfigurationManager
            .ConnectionStrings["Users_ConnectionString"]
            .ConnectionString;

        using (SqlConnection con = new SqlConnection(conString))
        {
            string qry = @"
                SELECT  
                    ISNULL(Employee.DesignationID, 0) AS DesignationID,
                    ISNULL(de.Designation_Name, '') AS Designation_Name,
                    ISNULL(Employee.SubDeptId, 0) AS SubDeptId,
                    ISNULL(sb.SubDept_Name, '') AS SubDept_Name,
                    ISNULL(Employee.DeptID, 0) AS DeptID,
                    ISNULL(d.Dept_Name, '') AS Dept_Name,             
                    ISNULL(Employee.EFName, '') + ' ' + ISNULL(Employee.ELName, '') AS UserName
                FROM Employee
                INNER JOIN BasicDataInfo.dbo.SubDepartment sb ON sb.SubDept_Id = Employee.SubDeptId
                INNER JOIN BasicDataInfo.dbo.Department d ON d.Dept_Id = Employee.DeptId
                INNER JOIN BasicDataInfo.dbo.Designation de ON de.Designation_ID = Employee.DesignationID
                WHERE Employee.EmpID = @EmpID";

            using (SqlCommand cmd = new SqlCommand(qry, con))
            {
                cmd.CommandType = CommandType.Text;

                cmd.Parameters.Add("@EmpID", SqlDbType.Int).Value = empId;

                con.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        lblEmpName.Text = reader["UserName"].ToString().Trim();
                        lblDesignation.Text = reader["Designation_Name"].ToString();
                        lblDepartment.Text = reader["Dept_Name"].ToString();
                        lblSubDept.Text = reader["SubDept_Name"].ToString();
                    }
                    else
                    {
                        // No record found — hide the info strip
                        divEmpInfo.Visible = false;
                    }
                }
            }
        }
    }

    // ===========================
    // 🔹 ROLE SECURITY (EMPTY)
    // ===========================
    private void ApplyRoleSecurity()
    {
        // Role logic if needed
    }

    // ===========================
    // 🔹 DYNAMIC MENU
    // ===========================
    private void BindDynamicNav()
    {
        string role = "";
        if (Session["UserRole"] != null)
            role = Session["UserRole"].ToString();

        if (role == "Member") return;

        int empId = 0;
        if (Session["Emp_ID"] != null)
            int.TryParse(Session["Emp_ID"].ToString(), out empId);

        if (empId == 0) return;

        try
        {
            string conn = ConfigurationManager
                .ConnectionStrings["Users_ConnectionString"]
                .ConnectionString;

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

            // Show/Hide Load More button based on whether there are more modules
            if (dtModules.Rows.Count < 10)
            {
                liLoadMore.Visible = false;
            }
            else
            {
                liLoadMore.Visible = true;
            }
        }
        catch (Exception ex)
        {
            Response.Write("<br><b>Menu Error:</b> " + ex.Message);
        }
    }

    // ===========================
    // 🔹 SUB MENU BIND
    // ===========================
    protected void rptModules_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item ||
            e.Item.ItemType == ListItemType.AlternatingItem)
        {
            try
            {
                DataRowView row = (DataRowView)e.Item.DataItem;

                int moduleId = Convert.ToInt32(row["Module_ID"]);

                int empId = 0;
                if (Session["Emp_ID"] != null)
                    int.TryParse(Session["Emp_ID"].ToString(), out empId);

                Repeater rptPages = (Repeater)e.Item.FindControl("rptPages");
                if (rptPages == null) return;

                DataTable dtPages = new DataTable();

                string conn = ConfigurationManager
                    .ConnectionStrings["Users_ConnectionString"]
                    .ConnectionString;

                using (SqlConnection con = new SqlConnection(conn))
                using (SqlCommand cmd = new SqlCommand("usp_SubMenu", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@ModuleId", SqlDbType.Int).Value = moduleId;
                    cmd.Parameters.Add("@EmpId", SqlDbType.Int).Value = empId;

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dtPages);
                }

                rptPages.DataSource = dtPages;
                rptPages.DataBind();
            }
            catch (Exception ex)
            {
                Response.Write("<br><b>SubMenu Error:</b> " + ex.Message);
            }
        }
    }

    // ===========================
    // 🔹 LOAD MORE / LOAD LESS MODULES
    // ===========================
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
        BindDynamicNav();

        if (upSidebar != null)
            upSidebar.Update();
    }
}


