using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class AssignPermissions : System.Web.UI.Page
{
    private string connStr
    {
        get
        {
            var s = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
            return s != null ? s.ConnectionString : "";
        }
    }

    private string basicDataInfoConnStr
    {
        get
        {
            var s = ConfigurationManager.ConnectionStrings["Basic_Data_ConnectionString"];
            return s != null ? s.ConnectionString : "";
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            BindEmployees();
        }
    }

    private void BindEmployees()
    {
        using (SqlConnection con = new SqlConnection(basicDataInfoConnStr))
        {
            SqlDataAdapter da = new SqlDataAdapter(
                "SELECT EmpID, EFName + ' (' + CAST(EmpID AS VARCHAR) + ')' + ISNULL(' - ' + Designation_Detail, '') AS DisplayName FROM Employee WHERE ActiveStatus=1 ORDER BY EFName", con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            ddlEmployee.DataSource = dt;
            ddlEmployee.DataTextField = "DisplayName";
            ddlEmployee.DataValueField = "EmpID";
            ddlEmployee.DataBind();
            ddlEmployee.Items.Insert(0, new ListItem("-- Select Employee --", ""));
        }
    }

    protected void ddlEmployee_SelectedIndexChanged(object sender, EventArgs e)
    {
        string empId = ddlEmployee.SelectedValue;
        if (string.IsNullOrEmpty(empId))
        {
            pnlPermissions.Visible = false;
            return;
        }

        // Load employee info
        using (SqlConnection con = new SqlConnection(basicDataInfoConnStr))
        {
            SqlCommand cmd = new SqlCommand("SELECT EFName, Designation_Detail FROM Employee WHERE EmpID=@Id", con);
            cmd.Parameters.AddWithValue("@Id", empId);
            con.Open();
            SqlDataReader dr = cmd.ExecuteReader();
            if (dr.Read())
            {
                lblEmpName.Text = dr["EFName"].ToString();
                lblDept.Text = dr["Designation_Detail"] != DBNull.Value ? dr["Designation_Detail"].ToString() : "N/A";
                lblRole.Text = "Employee";
            }
            dr.Close();
            con.Close();
        }

        LoadPermissionTree();
        pnlPermissions.Visible = true;
    }

    private void LoadPermissionTree()
    {
        int targetEmpId = 0;
        int.TryParse(ddlEmployee.SelectedValue, out targetEmpId);
        LoadPermissionTree(targetEmpId);
    }

    private void LoadPermissionTree(int targetEmpId)
    {
        string connStr = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;
        DataTable dtModules = new DataTable();

        using (SqlConnection con = new SqlConnection(connStr))
        {
            // Get distinct modules that have pages assigned to this employee
            string sql = @"SELECT DISTINCT m.ModuleId, m.ModuleName 
                           FROM SysModules m 
                           INNER JOIN SysPages p ON m.ModuleId = p.ModuleId
                           INNER JOIN NavPermissions np ON p.PageId = np.PageId
                           WHERE np.EmployeeId = @EmpId AND m.IsActive = 1";
            
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@EmpId", targetEmpId);
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
            int moduleId = Convert.ToInt32(row["ModuleId"]);
            int targetEmpId = Convert.ToInt32(ddlEmployee.SelectedValue);

            Repeater rptPages = (Repeater)e.Item.FindControl("rptPages");
            string connStr = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;
            DataTable dtPages = new DataTable();

            using (SqlConnection con = new SqlConnection(connStr))
            {
                string sql = @"SELECT p.PageId, p.PageTitle, 
                               CASE WHEN np.PermissionId IS NOT NULL THEN 1 ELSE 0 END as IsGranted
                               FROM SysPages p
                               LEFT JOIN NavPermissions np ON p.PageId = np.PageId AND np.EmployeeId = @EmpId
                               WHERE p.ModuleId = @ModuleId AND p.IsActive = 1";
                
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@EmpId", targetEmpId);
                    cmd.Parameters.AddWithValue("@ModuleId", moduleId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dtPages);
                }
            }

            // We need 'IsGranted' and 'PageId' for the UI binding.
            // The stored procedure usp_SubMenu returns Page_Name, Page_URL, Priority, Page_ID.
            // We should check if we need to add a column for IsGranted or if it's implicitly handled.
            // Since this is for SETTING permissions for ANOTHER employee, 
            // the tree we show should be based on the LOGGED-IN user's access (what they CAN assign).
            // However, the checkboxes should show what the SELECTED employee HAS.
            
            string selectedEmpId = ddlEmployee.SelectedValue;
            if (!string.IsNullOrEmpty(selectedEmpId))
            {
                dtPages.Columns.Add("IsGranted", typeof(bool));
                foreach (DataRow dr in dtPages.Rows)
                {
                    dr["IsGranted"] = CheckIfGranted(selectedEmpId, dr["Page_ID"].ToString());
                }
            }

            rptPages.DataSource = dtPages;
            rptPages.DataBind();
        }
    }

    private bool CheckIfGranted(string empId, string pageId)
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM NavPermissions WHERE EmployeeId=@EmpId AND PageId=@PageId", con);
            cmd.Parameters.AddWithValue("@EmpId", empId);
            cmd.Parameters.AddWithValue("@PageId", pageId);
            con.Open();
            int count = (int)cmd.ExecuteScalar();
            return count > 0;
        }
    }

    protected void btnSavePermissions_Click(object sender, EventArgs e)
    {
        string empId = ddlEmployee.SelectedValue;
        if (string.IsNullOrEmpty(empId)) return;

        List<int> selectedPageIds = new List<int>();

        foreach (RepeaterItem modItem in rptModules.Items)
        {
            Repeater rptPages = (Repeater)modItem.FindControl("rptPages");
            foreach (RepeaterItem pageItem in rptPages.Items)
            {
                CheckBox chk = (CheckBox)pageItem.FindControl("chkPage");
                HiddenField hf = (HiddenField)pageItem.FindControl("hfPageId");
                if (chk.Checked)
                {
                    selectedPageIds.Add(Convert.ToInt32(hf.Value));
                }
            }
        }

        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();

            // Ensure employee exists in MemberShip.Employees (required by FK constraint)
            SqlCommand cmdCheck = new SqlCommand("SELECT COUNT(*) FROM Employees WHERE EmployeeId=@EmpId", con);
            cmdCheck.Parameters.AddWithValue("@EmpId", empId);
            int exists = (int)cmdCheck.ExecuteScalar();
            if (exists == 0)
            {
                // Fetch name from BasicDataInfo to create stub record
                string empName = "Employee";
                using (SqlConnection bdiCon = new SqlConnection(basicDataInfoConnStr))
                {
                    SqlCommand cmdName = new SqlCommand("SELECT EFName FROM Employee WHERE EmpID=@Id", bdiCon);
                    cmdName.Parameters.AddWithValue("@Id", empId);
                    bdiCon.Open();
                    object result = cmdName.ExecuteScalar();
                    if (result != null) empName = result.ToString();
                }

                SqlCommand cmdInsEmp = new SqlCommand(
                    "SET IDENTITY_INSERT Employees ON; INSERT INTO Employees (EmployeeId, EmployeeNo, FullName, IsActive, CreatedDate) VALUES (@EmpId, @EmpNo, @Name, 1, GETDATE()); SET IDENTITY_INSERT Employees OFF;", con);
                cmdInsEmp.Parameters.AddWithValue("@EmpId", empId);
                cmdInsEmp.Parameters.AddWithValue("@EmpNo", "EMP-" + empId);
                cmdInsEmp.Parameters.AddWithValue("@Name", empName);
                cmdInsEmp.ExecuteNonQuery();
            }

            // Delete existing permissions
            SqlCommand cmdDel = new SqlCommand("DELETE FROM NavPermissions WHERE EmployeeId=@EmpId", con);
            cmdDel.Parameters.AddWithValue("@EmpId", empId);
            cmdDel.ExecuteNonQuery();

            // Insert new permissions
            foreach (int pageId in selectedPageIds)
            {
                SqlCommand cmdIns = new SqlCommand("INSERT INTO NavPermissions (EmployeeId, PageId) VALUES (@EmpId, @PageId)", con);
                cmdIns.Parameters.AddWithValue("@EmpId", empId);
                cmdIns.Parameters.AddWithValue("@PageId", pageId);
                cmdIns.ExecuteNonQuery();
            }
        }

        ShowMessage("Permissions saved successfully! (" + selectedPageIds.Count + " pages assigned)", true);
        LoadPermissionTree();
        ((Masters_Site)this.Master).RefreshSidebar();
    }

    protected void btnSelectAll_Click(object sender, EventArgs e)
    {
        SetAllCheckboxes(true);
    }

    protected void btnDeselectAll_Click(object sender, EventArgs e)
    {
        SetAllCheckboxes(false);
    }

    private void SetAllCheckboxes(bool state)
    {
        foreach (RepeaterItem modItem in rptModules.Items)
        {
            Repeater rptPages = (Repeater)modItem.FindControl("rptPages");
            foreach (RepeaterItem pageItem in rptPages.Items)
            {
                CheckBox chk = (CheckBox)pageItem.FindControl("chkPage");
                chk.Checked = state;
            }
        }
    }

    private void ShowMessage(string msg, bool success)
    {
        lblMessage.Text = msg;
        lblMessage.CssClass = success ? "msg-success" : "msg-error";
        lblMessage.Visible = true;
    }
}
