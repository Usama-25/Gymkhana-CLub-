using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.Security;
using System.Web.UI;

public partial class Controls_LoginControl : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // No auto session clear here, let the page handle that if needed
    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
        try
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            int memberId;
            string memberNo;
            string userRole;
            int employeeId; // Add employeeId for storing actual ID

            string displayName;
            if (AuthenticateUser(username, password, out memberId, out memberNo, out userRole, out displayName, out employeeId))
            {
                // Store session values
                Session["MemberId"] = memberId;
                Session["MemberNo"] = memberNo;
                Session["UserName"] = username;
                Session["UserRole"] = userRole;
                
                if (!string.IsNullOrEmpty(displayName))
                {
                    Session["EmpName"] = displayName;
                }

                if (userRole != "Member")
                {
                     Session["EmpID"] = employeeId; 
                     Session["Emp_ID"] = employeeId; // Store actual employee ID as integer
                     Session["EmployeeNo"] = memberNo; // Store employee number separately
                }


                Session["LoginTime"] = DateTime.Now;

                FormsAuthentication.SetAuthCookie(username, chkRememberMe.Checked);

                // Redirect based on Role
                // Sidebar is dynamically controlled by DB - no role restriction needed
                if (userRole.Equals("Member", StringComparison.OrdinalIgnoreCase))
                {
                    Response.Redirect("~/MemberShipModule/Dashbord.aspx");
                }
                else
                {
                    // All other roles (Employee, Admin, MembershipOfficer, Committee, etc.)
                    // go to AdminDashboard - sidebar pages are controlled by NavPermissions
                    Response.Redirect("~/MemberShipModule/AdminDashboard.aspx");
                }
            }
            else
            {
                ShowMessage("Invalid username or password!", "error");
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Login error: " + ex.Message, "error");
        }
    }

    private bool AuthenticateUser(string username, string password,
                                  out int memberId, out string memberNo, out string userRole, out string displayName, out int employeeId)
    {
        // Init output params
        memberId = 0;
        memberNo = "";
        userRole = "";
        displayName = "";
        employeeId = 0;

        var msConnObj = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
        if (msConnObj == null) throw new Exception("Connection string 'MemberShipConnection' not found.");
        string cs = msConnObj.ConnectionString;

        // 1. Try Authenticate as Member First
        if (CheckMemberLogin(username, password, cs, out memberId, out memberNo, out userRole, out displayName))
        {
            employeeId = 0; // Members don't have employee IDs
            return true;
        }

        // 2. Try Authenticate as Employee (if member failed)
        if (CheckEmployeeLogin(username, password, cs, out employeeId, out memberNo, out userRole, out displayName))
        {
            return true;
        }

        return false;
    }

    private bool CheckMemberLogin(string username, string password, string connectionString,
                                  out int memberId, out string memberNo, out string userRole, out string displayName)
    {
        memberId = 0;
        memberNo = "";
        userRole = "Member"; 
        displayName = "";

        string query = @"
            SELECT MemberId, MemberNo
            FROM MemberLogin
            WHERE Username = @Username
              AND Password = @Password
              AND IsActive = 1";

        using (SqlConnection con = new SqlConnection(connectionString))
        using (SqlCommand cmd = new SqlCommand(query, con))
        {
            cmd.Parameters.AddWithValue("@Username", username);
            cmd.Parameters.AddWithValue("@Password", password);

            con.Open();
            SqlDataReader dr = cmd.ExecuteReader();

            if (dr.Read())
            {
                memberId = dr["MemberId"] != DBNull.Value ? Convert.ToInt32(dr["MemberId"]) : 0;
                memberNo = dr["MemberNo"].ToString();
                return true;
            }
        }
        return false;
    }

    private bool CheckEmployeeLogin(string username, string password, string connectionString,
                                    out int employeeId, out string memberNo, out string userRole, out string displayName)
    {
        employeeId = 0; 
        memberNo = username; 
        userRole = ""; 
        displayName = "";

        // Use UserManagement connection
        var umConnObj = ConfigurationManager.ConnectionStrings["UserManagementConnection"];
        if (umConnObj == null) throw new Exception("Connection string 'UserManagementConnection' not found.");
        string umConn = umConnObj.ConnectionString;

        // Query Login table in User_management DB
        string query = @"
            SELECT EmpID
            FROM Login
            WHERE UserName = @UserName
              AND Password = @Password";

        try 
        {
            using (SqlConnection con = new SqlConnection(umConn))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@UserName", username);
                cmd.Parameters.AddWithValue("@Password", password);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    // Authenticated in User_management DB
                    userRole = "Employee";
                    memberNo = username;
                    employeeId = dr["EmpID"] != DBNull.Value ? Convert.ToInt32(dr["EmpID"]) : 0;
                    displayName = "";

                    dr.Close();
                    con.Close();

                    // FETCH FROM BasicDataInfo
                    FetchBasicDataInfoEmployee(employeeId, ref displayName);

                    return true;
                }
            }
        }
        catch (Exception)
        {
             // Debug.WriteLine("UserManagement Login Error: " + ex.Message);
        }
        return false;
    }

    private void FetchBasicDataInfoEmployee(int empId, ref string displayName)
    {
        var basicConnObj = ConfigurationManager.ConnectionStrings["Basic_Data_ConnectionString"];
        if (basicConnObj == null) throw new Exception("Connection string 'Basic_Data_ConnectionString' not found.");
        string basicConn = basicConnObj.ConnectionString;
        string query = "SELECT EFName FROM Employee WHERE EmpID = @EmpID";

        try
        {
            using (SqlConnection con = new SqlConnection(basicConn))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@EmpID", empId);
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    if (dr["EFName"] != DBNull.Value)
                        displayName = dr["EFName"].ToString();
                }
            }
        }
        catch (Exception) { /* Fallback to local data if sync fails */ }
    }

    private void ShowMessage(string message, string type)
    {
        lblMessage.Text = message;
        lblMessage.Visible = true;

        if (type == "error")
        {
            lblMessage.Style["background-color"] = "#fee";
            lblMessage.Style["color"] = "#c00";
            lblMessage.Style["border"] = "1px solid #c00";
        }
        else
        {
            lblMessage.Style["background-color"] = "#efe";
            lblMessage.Style["color"] = "#060";
            lblMessage.Style["border"] = "1px solid #060";
        }
    }
}


