using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Masters_Complaint : System.Web.UI.MasterPage
{
    protected void Page_Init(object sender, EventArgs e)
    {
        // 🔐 Forceful session check: strictly require valid Emp_ID in session
        if (Session["Emp_ID"] == null || string.IsNullOrEmpty(Session["Emp_ID"].ToString()))
        {
            Response.Redirect("~/Login.aspx", true);
            return;
        }

        int empId = 0;
        if (!int.TryParse(Session["Emp_ID"].ToString(), out empId) || empId <= 0)
        {
            Response.Redirect("~/Login.aspx", true);
            return;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        int empId = 0;
        if (Session["Emp_ID"] != null)
        {
            int.TryParse(Session["Emp_ID"].ToString(), out empId);
        }

        if (empId <= 0)
        {
            Response.Redirect("~/Login.aspx", true);
            return;
        }

        // 2. Load employee details dynamically from database
        if (empId > 0)
        {
            Load_Data(empId);
        }

        // 3. Bind dynamic nav stubs (database menu)
        BindDynamicNav();
    }

    private string GetMasterConnectionString()
    {
        return ConfigurationManager.ConnectionStrings["ComplaintsDB"] != null
            ? ConfigurationManager.ConnectionStrings["ComplaintsDB"].ConnectionString
            : ConfigurationManager.ConnectionStrings["Users_ConnectionString"].ConnectionString;
    }

    public void Load_Data(int empId)
    {
        try
        {
            string conString = GetMasterConnectionString();

            using (SqlConnection con = new SqlConnection(conString))
            {
                string qry = @"
                    SELECT  
                        ISNULL(de.Designation_Name, 'Librarian') AS Designation_Name,
                        ISNULL(sb.SubDept_Name, 'Operations') AS SubDept_Name,
                        ISNULL(d.Dept_Name, 'Library') AS Dept_Name,             
                        ISNULL(Employee.EFName, '') + ' ' + ISNULL(Employee.ELName, '') AS UserName
                    FROM User_management.dbo.Employee Employee
                    LEFT JOIN BasicDataInfo.dbo.SubDepartment sb ON sb.SubDept_Id = Employee.SubDeptId
                    LEFT JOIN BasicDataInfo.dbo.Department d ON d.Dept_Id = Employee.DeptId
                    LEFT JOIN BasicDataInfo.dbo.Designation de ON de.Designation_ID = Employee.DesignationID
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
                            string fullName = reader["UserName"].ToString().Trim();
                            string designationName = reader["Designation_Name"].ToString().Trim();
                            string deptName = reader["Dept_Name"].ToString().Trim();
                            string subDeptName = reader["SubDept_Name"].ToString().Trim();

                            if (string.IsNullOrEmpty(fullName))
                            {
                                fullName = Session["UserName"] != null ? Session["UserName"].ToString() : "Librarian";
                            }

                            // Populate employee strip controls
                            if (lblEmpName != null) lblEmpName.Text = fullName;
                            if (lblDesignation != null) lblDesignation.Text = designationName;
                            if (lblDepartment != null) lblDepartment.Text = deptName;
                            if (lblSubDept != null) lblSubDept.Text = subDeptName;

                            // Populate sidebar/header literal info
                            if (litStaffName != null) litStaffName.Text = fullName;
                            if (litStaffRole != null) litStaffRole.Text = designationName;

                            // Compute dynamic avatar initials
                            if (litAvatar != null && !string.IsNullOrEmpty(fullName))
                            {
                                string[] parts = fullName.Split(' ');
                                if (parts.Length > 1)
                                {
                                    litAvatar.Text = (parts[0][0].ToString() + parts[1][0].ToString()).ToUpper();
                                }
                                else if (parts.Length > 0 && parts[0].Length > 0)
                                {
                                    litAvatar.Text = parts[0][0].ToString().ToUpper();
                                }
                            }

                            if (divEmpInfo != null) divEmpInfo.Visible = true;
                        }
                        else
                        {
                            if (divEmpInfo != null) divEmpInfo.Visible = false;
                        }
                    }
                }
            }
        }
        catch (Exception)
        {
            // Failsafe fallback
            if (lblEmpName != null) lblEmpName.Text = Session["EFName"] != null ? Session["EFName"].ToString() : "Librarian";
            if (lblDesignation != null) lblDesignation.Text = Session["StaffRole"] != null ? Session["StaffRole"].ToString() : "Staff";
            if (lblDepartment != null) lblDepartment.Text = "Library";
            if (lblSubDept != null) lblSubDept.Text = "Operations";
            if (divEmpInfo != null) divEmpInfo.Visible = true;
        }
    }

    protected string GetActiveStyle(string pageName)
    {
        try
        {
            string currentFile = Path.GetFileName(Request.Url.AbsolutePath);
            string targetFile = Path.GetFileName(pageName);
            if (currentFile.Equals(targetFile, StringComparison.OrdinalIgnoreCase))
            {
                return "background: linear-gradient(90deg, #c5a059 0%, #b28e46 100%); color: #0f1e36; font-weight: 700; box-shadow: 0 4px 12px rgba(197, 160, 89, 0.25);";
            }
        }
        catch { }
        return "color: rgba(255,255,255,0.75);";
    }

    protected void lnkChangePassword_Click(object sender, EventArgs e)
    {
        Response.Redirect("~/change_password.aspx");
    }

    // ===========================
    // ⚓ DYNAMIC MENU BIND
    // ===========================
    private void BindDynamicNav()
    {
        int empId = 0;
        if (Session["Emp_ID"] != null)
            int.TryParse(Session["Emp_ID"].ToString(), out empId);

        if (empId == 0) return;

        try
        {
            string conn = GetMasterConnectionString();
            DataTable dtModules = new DataTable();

            using (SqlConnection con = new SqlConnection(conn))
            using (SqlCommand cmd = new SqlCommand("User_management.dbo.usp_MainMenu", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@EmpId", SqlDbType.Int).Value = empId;

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dtModules);
            }

            rptModules.DataSource = dtModules;
            rptModules.DataBind();

            // Show/Hide Load More button based on whether there are 10 or more modules
            if (dtModules.Rows.Count < 10)
            {
                liLoadMore.Visible = false;
            }
            else
            {
                liLoadMore.Visible = true;
            }
        }
        catch (Exception)
        {
        }
    }

    protected void rptModules_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
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
                string conn = GetMasterConnectionString();

                using (SqlConnection con = new SqlConnection(conn))
                using (SqlCommand cmd = new SqlCommand("User_management.dbo.usp_SubMenu", con))
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
            catch (Exception)
            {
            }
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
            string conn = GetMasterConnectionString();
            bool isExpanded = (ViewState["ModulesExpanded"] != null && (bool)ViewState["ModulesExpanded"]);

            if (!isExpanded)
            {
                // LOAD ALL MODULES (using the exact same table structures from procedure but without top limit)
                DataTable dtAllModules = new DataTable();
                string query = @"
                    SELECT DISTINCT 
                        Admin_User_Module.Module_ID, 
                        Admin_User_Module.Module_Name,
                        Admin_Employee_Module_Pages.ModulePriority AS val 
                    FROM User_management.dbo.Admin_User_Module Admin_User_Module 
                    INNER JOIN User_management.dbo.Admin_Employee_Module_Pages Admin_Employee_Module_Pages 
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

                btnLoadMore.Text = "<i class=\"fas fa-chevron-up\"></i> <span>Load Less</span>";
                ViewState["ModulesExpanded"] = true;
            }
            else
            {
                // Collapse back to normal dynamic view
                BindDynamicNav();
                btnLoadMore.Text = "<i class=\"fas fa-chevron-down\"></i> <span>Load More Modules</span>";
                ViewState["ModulesExpanded"] = false;
            }
        }
        catch (Exception)
        {
        }
    }

    public void RefreshSidebar()
    {
        BindDynamicNav();
        if (upSidebar != null)
        {
            upSidebar.Update();
        }
    }
}
