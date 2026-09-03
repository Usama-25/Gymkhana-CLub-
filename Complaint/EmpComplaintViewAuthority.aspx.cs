using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GymkhanaLibrary
{
    public partial class Pages_EmpComplaintViewAuthority : System.Web.UI.Page
    {
        public string AlertMessage { get; set; }
        public string AlertCssClass { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            if (!IsPostBack)
            {
                BindSubDepartments();
                BindFilterEmployees(null);
                BindAuthorities();
            }
        }

        private void BindSubDepartments()
        {
            try
            {
                DataTable dt = DBHelper.GetAllSubDepartments();
                ddlFilterSubDept.DataSource = dt;
                ddlFilterSubDept.DataTextField = "SubDept_Name";
                ddlFilterSubDept.DataValueField = "SubDept_Id";
                ddlFilterSubDept.DataBind();
                ddlFilterSubDept.Items.Insert(0, new ListItem("- All SubDepartments -", "0"));
            }
            catch (Exception ex)
            {
                ShowAlert("Error loading subdepartments: " + ex.Message, "alert-error");
            }
        }

        private void BindFilterEmployees(int? subDeptId)
        {
            try
            {
                DataTable dt = DBHelper.GetEmployeesBySubDept(subDeptId);
                var list = new System.Collections.Generic.List<object>();
                foreach (DataRow dr in dt.Rows)
                {
                    string full = dr["EmployeeName"].ToString();
                    string empId = dr["EmpID"].ToString();
                    string nameOnly = full;
                    var match = System.Text.RegularExpressions.Regex.Match(full, @"^(.*?)\s*\((\d+)\)$");
                    if (match.Success)
                    {
                        nameOnly = match.Groups[1].Value.Trim();
                    }
                    list.Add(new { id = empId, name = nameOnly, display = full });
                }
                string json = new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(list);
                litFilterEmployeesJson.Text = "<script>window.filterEmployeesData = " + json + ";</script>";

                txtFilterEmp.Text = "";
                hfFilterEmpID.Value = "";
                txtFilterEmp.Attributes["placeholder"] = "Type employee name or ID to filter...";
            }
            catch (Exception ex)
            {
                ShowAlert("Error loading employees for filter: " + ex.Message, "alert-error");
            }
        }

        protected void ddlFilterSubDept_SelectedIndexChanged(object sender, EventArgs e)
        {
            int subDeptId = 0;
            if (int.TryParse(ddlFilterSubDept.SelectedValue, out subDeptId) && subDeptId > 0)
            {
                BindFilterEmployees(subDeptId);
            }
            else
            {
                BindFilterEmployees(null);
            }
            BindAuthorities();
        }

        private void BindAuthorities()
        {
            try
            {
                int? subDeptId = null;
                if (!string.IsNullOrEmpty(ddlFilterSubDept.SelectedValue) && ddlFilterSubDept.SelectedValue != "0")
                {
                    int parsedSubDeptId;
                    if (int.TryParse(ddlFilterSubDept.SelectedValue, out parsedSubDeptId))
                        subDeptId = parsedSubDeptId;
                }

                decimal? empId = null;
                if (!string.IsNullOrEmpty(hfFilterEmpID.Value))
                {
                    decimal parsedEmpId;
                    if (decimal.TryParse(hfFilterEmpID.Value, out parsedEmpId))
                        empId = parsedEmpId;
                }
                else if (!string.IsNullOrEmpty(txtFilterEmp.Text))
                {
                    var match = System.Text.RegularExpressions.Regex.Match(txtFilterEmp.Text, @"\((\d+)\)$");
                    if (match.Success)
                    {
                        decimal parsedEmpId;
                        if (decimal.TryParse(match.Groups[1].Value, out parsedEmpId))
                            empId = parsedEmpId;
                    }
                }

                bool? isActive = null;
                if (!string.IsNullOrEmpty(ddlFilterStatus.SelectedValue))
                {
                    isActive = ddlFilterStatus.SelectedValue == "1";
                }

                DataTable dt = DBHelper.GetEmployeeComplaintAuthorities(empId, subDeptId, null, isActive);
                gvAuthorities.DataSource = dt;
                gvAuthorities.DataBind();
            }
            catch (Exception ex)
            {
                ShowAlert("Error loading authority mappings: " + ex.Message, "alert-error");
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            BindAuthorities();
        }

        protected void btnFilterReset_Click(object sender, EventArgs e)
        {
            ddlFilterSubDept.SelectedIndex = 0;
            BindFilterEmployees(null);
            ddlFilterStatus.SelectedIndex = 0;
            BindAuthorities();
        }

        protected void gvAuthorities_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int authorityID = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "ToggleStatus")
            {
                try
                {
                    string result = DBHelper.ToggleEmployeeComplaintAuthorityStatus(authorityID);
                    ShowAlert(result, result.Contains("successfully") ? "alert-success" : "alert-error");
                    BindAuthorities();
                }
                catch (Exception ex)
                {
                    ShowAlert("Error updating status: " + ex.Message, "alert-error");
                }
            }
        }

        private void ShowAlert(string msg, string cssClass)
        {
            AlertMessage = msg;
            AlertCssClass = cssClass;
            pnlAlert.Visible = true;
        }

        public static class DBHelper
        {
            private static string ConnStr
            {
                get
                {
                    return ConfigurationManager.ConnectionStrings["ComplaintsDB"] != null 
                        ? ConfigurationManager.ConnectionStrings["ComplaintsDB"].ConnectionString 
                        : ConfigurationManager.ConnectionStrings["Users_ConnectionString"].ConnectionString;
                }
            }

            public static SqlConnection GetConnection()
            {
                return new SqlConnection(ConnStr);
            }

            public static DataTable ExecuteReader(string spName, params SqlParameter[] prms)
            {
                var dt = new DataTable();
                using (var con = GetConnection())
                using (var cmd = new SqlCommand(spName, con) { CommandType = CommandType.StoredProcedure, CommandTimeout = 120 })
                using (var da  = new SqlDataAdapter(cmd))
                {
                    if (prms != null && prms.Length > 0) cmd.Parameters.AddRange(prms);
                    con.Open();
                    da.Fill(dt);
                }
                return dt;
            }

            public static int ExecuteNonQuery(string spName, params SqlParameter[] prms)
            {
                using (var con = GetConnection())
                using (var cmd = new SqlCommand(spName, con) { CommandType = CommandType.StoredProcedure, CommandTimeout = 120 })
                {
                    if (prms != null && prms.Length > 0) cmd.Parameters.AddRange(prms);
                    con.Open();
                    int rows = cmd.ExecuteNonQuery();
                    return rows;
                }
            }

            public static T GetOutputValue<T>(SqlParameter[] prms, string paramName)
            {
                if (prms == null) return default(T);
                foreach (var p in prms)
                {
                    if (p.ParameterName.Equals(paramName, StringComparison.OrdinalIgnoreCase))
                    {
                        if (p.Value == null || p.Value == DBNull.Value) return default(T);
                        return (T)Convert.ChangeType(p.Value, typeof(T));
                    }
                }
                return default(T);
            }

            public static DataTable GetAllSubDepartments()
            {
                var dt = new DataTable();
                using (var con = GetConnection())
                using (var cmd = new SqlCommand("SELECT SubDept_Id, SubDept_Name FROM BasicDataInfo.dbo.SubDepartment WHERE SubDept_Name IS NOT NULL AND SubDept_Name <> '' ORDER BY SubDept_Name", con))
                using (var da = new SqlDataAdapter(cmd))
                {
                    con.Open();
                    da.Fill(dt);
                }
                return dt;
            }

            public static DataTable GetEmployeesBySubDept(int? subDeptID)
            {
                var dt = new DataTable();
                using (var con = GetConnection())
                {
                    string sql = @"
                        SELECT EmpID, ISNULL(EFName, '') + ' ' + ISNULL(ELName, '') + ' (' + CAST(EmpID AS VARCHAR) + ')' AS EmployeeName 
                        FROM BasicDataInfo.dbo.Employee 
                        WHERE EFName IS NOT NULL AND EFName <> '' ";

                    if (subDeptID.HasValue && subDeptID.Value > 0)
                    {
                        sql += @" AND (
                            SubDeptId = @SubDeptID 
                            OR DeptID = (SELECT TOP 1 Dept_Id FROM BasicDataInfo.dbo.SubDepartment WHERE SubDept_Id = @SubDeptID)
                        ) ";
                    }

                    sql += " ORDER BY EFName, ELName";

                    using (var cmd = new SqlCommand(sql, con))
                    {
                        if (subDeptID.HasValue && subDeptID.Value > 0)
                        {
                            cmd.Parameters.AddWithValue("@SubDeptID", subDeptID.Value);
                        }
                        using (var da = new SqlDataAdapter(cmd))
                        {
                            con.Open();
                            da.Fill(dt);
                        }
                    }
                }
                return dt;
            }

            public static DataTable GetEmployeeComplaintAuthorities(decimal? empID = null, int? subDeptID = null, int? deptID = null, bool? isActive = null)
            {
                var prms = new[]
                {
                    new SqlParameter("@EmpID",     (object)empID ?? DBNull.Value),
                    new SqlParameter("@SubDeptID", (object)subDeptID ?? DBNull.Value),
                    new SqlParameter("@DeptID",    (object)deptID ?? DBNull.Value),
                    new SqlParameter("@IsActive",  (object)isActive ?? DBNull.Value)
                };
                return ExecuteReader("dbo.sp_GetEmployeeComplaintAuthorities", prms);
            }

            public static string ToggleEmployeeComplaintAuthorityStatus(int authorityID)
            {
                var prms = new[]
                {
                    new SqlParameter("@AuthorityID", authorityID),
                    new SqlParameter("@Msg",         SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
                };
                ExecuteNonQuery("dbo.sp_ToggleEmployeeComplaintAuthorityStatus", prms);
                return GetOutputValue<string>(prms, "@Msg");
            }
        }
    }
}
