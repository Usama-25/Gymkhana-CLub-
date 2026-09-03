using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GymkhanaLibrary
{
    public partial class Pages_EmpComplaintAuthority : System.Web.UI.Page
    {
        public string AlertMessage { get; set; }
        public string AlertCssClass { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            if (!IsPostBack)
            {
                BindAllEmployeesList();
            }
        }

        private void BindAllEmployeesList()
        {
            try
            {
                DataTable dt = DBHelper.GetAllEmployees();
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
                litAllEmployeesJson.Text = "<script>window.allEmployeesData = " + json + ";</script>";
            }
            catch (Exception ex)
            {
                ShowAlert("Error loading employee list: " + ex.Message, "alert-error");
            }
        }

        protected void btnLoadEmployee_Click(object sender, EventArgs e)
        {
            decimal empId = GetSelectedEmpID();
            if (empId <= 0)
            {
                ShowAlert("Please select a valid employee from the autocomplete list.", "alert-error");
                pnlGridCard.Visible = false;
                return;
            }

            LoadSubDepartmentsForEmployee(empId);
        }

        private decimal GetSelectedEmpID()
        {
            decimal empId = 0;
            if (!string.IsNullOrEmpty(hfEmpID.Value) && decimal.TryParse(hfEmpID.Value, out empId) && empId > 0)
            {
                return empId;
            }

            if (!string.IsNullOrEmpty(txtEmployee.Text))
            {
                var match = System.Text.RegularExpressions.Regex.Match(txtEmployee.Text, @"\((\d+)\)$");
                if (match.Success && decimal.TryParse(match.Groups[1].Value, out empId))
                {
                    return empId;
                }
            }
            return 0;
        }

        private void LoadSubDepartmentsForEmployee(decimal empId)
        {
            try
            {
                DataTable dt = DBHelper.GetSubDepartmentsWithAccess(empId);
                gvSubDeptAccess.DataSource = dt;
                gvSubDeptAccess.DataBind();

                if (gvSubDeptAccess.HeaderRow != null)
                {
                    gvSubDeptAccess.HeaderRow.TableSection = TableRowSection.TableHeader;
                }

                if (dt != null && dt.Rows.Count > 0)
                {
                    DataView view = new DataView(dt);
                    DataTable distinctDepts = view.ToTable(true, "Dept_Id", "Dept_Name");

                    ddlDeptSelect.DataSource = distinctDepts;
                    ddlDeptSelect.DataTextField = "Dept_Name";
                    ddlDeptSelect.DataValueField = "Dept_Id";
                    ddlDeptSelect.DataBind();
                    ddlDeptSelect.Items.Insert(0, new ListItem("-- Select Department --", "0"));

                    ddlDeptFilter.DataSource = distinctDepts;
                    ddlDeptFilter.DataTextField = "Dept_Name";
                    ddlDeptFilter.DataValueField = "Dept_Id";
                    ddlDeptFilter.DataBind();
                    ddlDeptFilter.Items.Insert(0, new ListItem("All Departments", "0"));
                }

                litSelectedEmpName.Text = txtEmployee.Text;
                pnlGridCard.Visible = true;
            }
            catch (Exception ex)
            {
                ShowAlert("Error loading subdepartments: " + ex.Message, "alert-error");
            }
        }

        protected void gvSubDeptAccess_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.Header)
            {
                e.Row.Attributes["style"] = "background-color: #0f1e36; color: #ffffff;";
                foreach (TableCell cell in e.Row.Cells)
                {
                    cell.Attributes["style"] = "background-color: #0f1e36 !important; color: #ffffff !important; font-weight: 700 !important; text-transform: uppercase !important; font-size: 11.5px !important; letter-spacing: 0.5px !important; padding: 14px 16px !important; border-bottom: 2px solid #c5a059 !important; text-align: left !important; font-family: 'Outfit', sans-serif !important;";
                }
            }
            else if (e.Row.RowType == DataControlRowType.DataRow)
            {
                DataRowView drv = (DataRowView)e.Row.DataItem;
                if (drv != null)
                {
                    string deptId = drv["Dept_Id"].ToString();
                    string deptName = drv["Dept_Name"].ToString();
                    e.Row.Attributes["data-dept-id"] = deptId;
                    e.Row.Attributes["data-dept-name"] = deptName;
                }

                string bg = (e.Row.RowIndex % 2 == 0) ? "#ffffff" : "#f8fafc";
                e.Row.Attributes["style"] = "background-color: " + bg + "; border-bottom: 1px solid #e2e8f0; font-size: 13.5px; color: #1e293b; text-align: left; vertical-align: middle; font-family: 'Outfit', sans-serif;";
                foreach (TableCell cell in e.Row.Cells)
                {
                    cell.Attributes["style"] = "background-color: " + bg + "; border-bottom: 1px solid #e2e8f0; padding: 12px 16px; font-size: 13.5px; color: #1e293b; text-align: left; vertical-align: middle; font-family: 'Outfit', sans-serif;";
                }
            }
        }

        protected void btnSaveAuthorities_Click(object sender, EventArgs e)
        {
            decimal empId = GetSelectedEmpID();
            if (empId <= 0)
            {
                ShowAlert("Invalid employee selection.", "alert-error");
                return;
            }

            try
            {
                int updatedCount = 0;
                foreach (GridViewRow row in gvSubDeptAccess.Rows)
                {
                    if (row.RowType == DataControlRowType.DataRow)
                    {
                        int subDeptId = Convert.ToInt32(gvSubDeptAccess.DataKeys[row.RowIndex].Value);
                        CheckBox chkHasAccess = (CheckBox)row.FindControl("chkHasAccess");

                        HiddenField hfExistingAuthID = (HiddenField)row.FindControl("hfExistingAuthID");
                        int? existingAuthId = string.IsNullOrEmpty(hfExistingAuthID.Value) ? (int?)null : Convert.ToInt32(hfExistingAuthID.Value);

                        bool grantAccess = chkHasAccess.Checked;

                        if (grantAccess || existingAuthId.HasValue)
                        {
                            string msg = DBHelper.SaveEmployeeComplaintAuthority(existingAuthId, empId, subDeptId, grantAccess);
                            updatedCount++;
                        }
                    }
                }

                ShowAlert("Subdepartment authority permissions saved successfully.", "alert-success");
                LoadSubDepartmentsForEmployee(empId);
            }
            catch (Exception ex)
            {
                ShowAlert("Error saving permissions: " + ex.Message, "alert-error");
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

            public static DataTable GetAllEmployees()
            {
                var dt = new DataTable();
                using (var con = GetConnection())
                using (var cmd = new SqlCommand("SELECT EmpID, ISNULL(EFName, '') + ' ' + ISNULL(ELName, '') + ' (' + CAST(EmpID AS VARCHAR) + ')' AS EmployeeName FROM BasicDataInfo.dbo.Employee WHERE EFName IS NOT NULL AND EFName <> '' ORDER BY EFName", con))
                using (var da = new SqlDataAdapter(cmd))
                {
                    con.Open();
                    da.Fill(dt);
                }
                return dt;
            }

            public static DataTable GetSubDepartmentsWithAccess(decimal empID)
            {
                var dt = new DataTable();
                using (var con = GetConnection())
                {
                    string sql = @"
                        SELECT 
                            sd.SubDept_Id,
                            sd.SubDept_Name,
                            sd.Dept_Id,
                            ISNULL(d.Dept_Name, 'General') AS Dept_Name,
                            CASE WHEN eca.AuthorityID IS NOT NULL AND eca.IsActive = 1 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS HasAccess,
                            ISNULL(eca.IsActive, CAST(1 AS BIT)) AS IsActiveStatus,
                            eca.AuthorityID
                        FROM BasicDataInfo.dbo.SubDepartment sd
                        LEFT JOIN BasicDataInfo.dbo.Department d ON sd.Dept_Id = d.Dept_ID
                        LEFT JOIN dbo.EmployeeComplaintAuthority eca ON sd.SubDept_Id = eca.SubDeptID AND eca.EmpID = @EmpID
                        WHERE sd.SubDept_Name IS NOT NULL AND sd.SubDept_Name <> ''
                        ORDER BY d.Dept_Name, sd.SubDept_Name";

                    using (var cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@EmpID", empID);
                        using (var da = new SqlDataAdapter(cmd))
                        {
                            con.Open();
                            da.Fill(dt);
                        }
                    }
                }
                return dt;
            }

            public static string SaveEmployeeComplaintAuthority(int? authorityID, decimal empID, int subDeptID, bool isActive = true)
            {
                var prms = new[]
                {
                    new SqlParameter("@AuthorityID", (object)authorityID ?? DBNull.Value),
                    new SqlParameter("@EmpID",       empID),
                    new SqlParameter("@SubDeptID",   subDeptID),
                    new SqlParameter("@IsActive",    isActive),
                    new SqlParameter("@Msg",         SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
                };
                ExecuteNonQuery("dbo.sp_SaveEmployeeComplaintAuthority", prms);
                return GetOutputValue<string>(prms, "@Msg");
            }
        }
    }
}
