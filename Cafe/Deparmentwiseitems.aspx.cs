using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class Store_Add_Unit : System.Web.UI.Page
{
    string conString = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
    string conString1 = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadDepartments();
        }
    }

    // ── Load Department Dropdown ──────────────────────────────────
    private void LoadDepartments()
    {
        using (SqlConnection con = new SqlConnection(conString1))
        {
            string query = @"SELECT SubDept_Id, SubDept_Name 
                             FROM SubDepartment
                             WHERE Dept_Id = 9
                             ORDER BY SubDept_Name";
            SqlDataAdapter da = new SqlDataAdapter(query, con);
            DataTable dt = new DataTable();
            da.Fill(dt);

            ddlDepartment.DataSource = dt;
            ddlDepartment.DataTextField = "SubDept_Name";
            ddlDepartment.DataValueField = "SubDept_Id";
            ddlDepartment.DataBind();

            // "All Departments" option at top
            ddlDepartment.Items.Insert(0, new ListItem("-- All Departments --", "0"));
        }
    }

    // ── Search Button ─────────────────────────────────────────────
    // FIX: value "0" now loads ALL records instead of returning empty
    protected void btnSearch_Click(object sender, EventArgs e)
    {
        LoadItems();
    }

    // ── Dropdown AutoPostBack ─────────────────────────────────────
    protected void ddlDepartment_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadItems();
    }

    // ── Load Items ────────────────────────────────────────────────
    private void LoadItems()
    {
        bool allDepts = (ddlDepartment.SelectedValue == "0");

        using (SqlConnection con = new SqlConnection(conString))
        {
            // When "All Departments" selected, skip the WHERE DepartmentID filter
            string query = allDepts
                ? @"SELECT ID, ItemName, Price, Cost, GST, Active, DepartmentID
                    FROM MenuItems
                    WHERE Active = 1
                    ORDER BY DepartmentID, ItemName"
                : @"SELECT ID, ItemName, Price, Cost, GST, Active, DepartmentID
                    FROM MenuItems
                    WHERE Active = 1
                      AND DepartmentID = @DeptID
                    ORDER BY ItemName";

            SqlCommand cmd = new SqlCommand(query, con);

            if (!allDepts)
                cmd.Parameters.AddWithValue("@DeptID", Convert.ToInt32(ddlDepartment.SelectedValue));

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            gvItems.DataSource = dt;
            gvItems.DataBind();

            // Update stat labels
            lblTotal.Text = dt.Rows.Count.ToString();
            lblDeptName.Text = allDepts
                ? "All"
                : ddlDepartment.SelectedItem.Text;
        }
    }
}