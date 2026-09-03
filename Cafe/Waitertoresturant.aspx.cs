using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Pos : System.Web.UI.Page
{
    string constr = ConfigurationManager
        .ConnectionStrings["MemberShipConnection"].ConnectionString;

    string cons = ConfigurationManager
        .ConnectionStrings["RestaurantConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            GetCafeName();
            BindGrid();
        }
    }

    // ===================== BIND RESTAURANT / CAFE =====================
    private void GetCafeName()
    {
        using (SqlConnection conn = new SqlConnection(constr))
        {
            SqlCommand cmd = new SqlCommand(
                @"SELECT SubDept_Id, SubDept_Name 
                  FROM SubDepartment 
                  WHERE Dept_Id = 9 
                  ORDER BY SubDept_Name", conn);

            conn.Open();
            ddlCafe.DataSource = cmd.ExecuteReader();
            ddlCafe.DataTextField = "SubDept_Name";
            ddlCafe.DataValueField = "SubDept_Id";
            ddlCafe.DataBind();
        }

        ddlCafe.Items.Insert(0, new ListItem("-- Select Restaurant or Cafe --", ""));
    }

    // ===================== AUTOCOMPLETE EMPLOYEE =====================
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<Employee> GetEmployeeList(string prefix)
    {
        List<Employee> employees = new List<Employee>();

        string constr = ConfigurationManager
            .ConnectionStrings["MemberShipConnection"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(constr))
        {
            string query = @"
            SELECT EmpID,
                   EFName + ' - ' + CAST(Emp_No AS VARCHAR(20)) AS EmployeeName
            FROM STORE.dbo.Employee
            WHERE EFName LIKE '%' + @prefix + '%'";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@prefix", prefix);
                conn.Open();

                SqlDataReader dr = cmd.ExecuteReader();
                while (dr.Read())
                {
                    employees.Add(new Employee
                    {
                        id = dr["EmpID"].ToString(),
                        label = dr["EmployeeName"].ToString()
                    });
                }
            }
        }
        return employees;
    }

    // ===================== ADD BUTTON =====================
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        lblMessage.Text = "";

        string subDeptId = ddlCafe.SelectedValue;
        string restaurantName = ddlCafe.SelectedItem.Text;
        string employeeName = txtEmployeeName.Text.Trim();
        string role = ddlRole.SelectedValue;
        string empID = hfEmployeeID.Value;

        // ---------- VALIDATION ----------
        if (string.IsNullOrEmpty(subDeptId) ||
            string.IsNullOrEmpty(employeeName) ||
            string.IsNullOrEmpty(role) ||
            string.IsNullOrEmpty(empID))
        {
            ShowAlert("⚠ Please fill all fields.", false);
            return;
        }

        using (SqlConnection conn = new SqlConnection(cons))
        {
            conn.Open();

            // ---------- DUPLICATE CHECK ----------
            string checkQuery = @"
            SELECT COUNT(*) 
            FROM EmployeeRestaurantMap
            WHERE SubDeptID = @SubDeptID
              AND Emp_ID = @Emp_ID
              AND Role = @Role";

            SqlCommand checkCmd = new SqlCommand(checkQuery, conn);
            checkCmd.Parameters.AddWithValue("@SubDeptID", subDeptId);
            checkCmd.Parameters.AddWithValue("@Emp_ID", empID);
            checkCmd.Parameters.AddWithValue("@Role", role);

            int exists = Convert.ToInt32(checkCmd.ExecuteScalar());

            if (exists > 0)
            {
                ShowAlert("⚠ This employee is already assigned to this restaurant with same role.", false);
                return;
            }

            // ---------- INSERT ----------
            string insertQuery = @"
            INSERT INTO EmployeeRestaurantMap
            (SubDeptID, RestaurantName, EmployeeName, Role, Emp_ID, CreatedDate)
            VALUES
            (@SubDeptID, @RestaurantName, @EmployeeName, @Role, @Emp_ID, GETDATE())";

            SqlCommand cmd = new SqlCommand(insertQuery, conn);
            cmd.Parameters.AddWithValue("@SubDeptID", subDeptId);
            cmd.Parameters.AddWithValue("@RestaurantName", restaurantName);
            cmd.Parameters.AddWithValue("@EmployeeName", employeeName);
            cmd.Parameters.AddWithValue("@Role", role);
            cmd.Parameters.AddWithValue("@Emp_ID", empID);

            cmd.ExecuteNonQuery();
        }

        // ---------- CLEAR FORM ----------
        txtEmployeeName.Text = "";
        hfEmployeeID.Value = "";
        ddlCafe.SelectedIndex = 0;
        ddlRole.SelectedIndex = 0;

        BindGrid();
        ShowAlert("✅ Employee assigned successfully.", true);
    }

    // ===================== ALERT MESSAGE =====================
    private void ShowAlert(string message, bool isSuccess)
    {
        string cssClass = isSuccess ? "top-alert-success" : "top-alert-error";

        lblMessage.Text = @"
        <div id='tempAlert' class='top-alert {cssClass}'>
            {message}
        </div>
        <script>
            setTimeout(function () {{
                var el = document.getElementById('tempAlert');
                if (el) el.style.display = 'none';
            }}, 5000);
        </script>";
    }

    // ===================== GRID BIND =====================
    private void BindGrid()
    {
        using (SqlConnection con = new SqlConnection(cons))
        {
            SqlCommand cmd = new SqlCommand(
                @"SELECT RestaurantName, EmployeeName, Role, Emp_ID 
                  FROM EmployeeRestaurantMap 
                  ORDER BY CreatedDate DESC", con);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            rptEmployeeRestaurant.DataSource = dt;
            rptEmployeeRestaurant.DataBind();
        }
    }
}

// ===================== EMPLOYEE CLASS =====================
public class Employee
{
    public string id { get; set; }
    public string label { get; set; }
}
