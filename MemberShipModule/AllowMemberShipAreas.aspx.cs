using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RefundFee
{
    public partial class AllowMemberShipAreas : Page
    {
        private string connStr
        {
            get
            {
                var s = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
                return s != null ? s.ConnectionString : "";
            }
        }
        private DataTable tempGridData;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindMembershipTypes();
                BindDepartments();

              
                InitializeTempGridData();
            }
            else
            {
                tempGridData = (DataTable)ViewState["TempGridData"];
            }
        }

        private void InitializeTempGridData()
        {
            tempGridData = new DataTable();
            tempGridData.Columns.Add("RowIndex", typeof(int));
            tempGridData.Columns.Add("FormType");
            tempGridData.Columns.Add("Dept_Name");
            tempGridData.Columns.Add("MembershipID", typeof(int));
            tempGridData.Columns.Add("DepartmentID", typeof(int));
            ViewState["TempGridData"] = tempGridData;
        }

        private void BindMembershipTypes()
        {
            string query = "SELECT id, FormType FROM FormTable where Status=1";

            using (SqlConnection con = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                ddlMembershipType.DataSource = dr;
                ddlMembershipType.DataTextField = "FormType";
                ddlMembershipType.DataValueField = "id";
                ddlMembershipType.DataBind();
            }

            ddlMembershipType.Items.Insert(0, new ListItem("-- Select Membership Type --", "0"));
        }

        private void BindDepartments()
        {
            string query = "SELECT Dept_Id, Dept_Name FROM Department";

            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["Basic_Data_ConnectionString"].ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                ddlAllowedAreas.DataSource = dr;
                ddlAllowedAreas.DataTextField = "Dept_Name";
                ddlAllowedAreas.DataValueField = "Dept_Id";
                ddlAllowedAreas.DataBind();
            }

            ddlAllowedAreas.Items.Insert(0, new ListItem("-- Select Department Area --", "0"));
        }

        protected void btnAllow_Click(object sender, EventArgs e)
        {
            // Validate selections
            if (ddlMembershipType.SelectedIndex == 0 || ddlAllowedAreas.SelectedIndex == 0)
            {
                ShowMessage("Please select both Membership Type & Department Area.", "red");
                return;
            }

            // Get values
            string membershipText = ddlMembershipType.SelectedItem.Text;
            string deptText = ddlAllowedAreas.SelectedItem.Text;
            int membershipId = Convert.ToInt32(ddlMembershipType.SelectedValue);
            int departmentId = Convert.ToInt32(ddlAllowedAreas.SelectedValue);

            // Check for duplicate entry
            foreach (DataRow row in tempGridData.Rows)
            {
                if (row["FormType"].ToString() == membershipText && row["Dept_Name"].ToString() == deptText)
                {
                    ShowMessage("This combination already exists in the list.", "red");
                    return;
                }
            }

            
            int newIndex = tempGridData.Rows.Count;
            tempGridData.Rows.Add(newIndex, membershipText, deptText, membershipId, departmentId);
            ViewState["TempGridData"] = tempGridData;

            
            GridView1.DataSource = tempGridData;
            GridView1.DataBind();

           
            ddlMembershipType.SelectedIndex = 0;
            ddlAllowedAreas.SelectedIndex = 0;

            ShowMessage("Item added to list. Click 'Save All' to save", "blue");
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (tempGridData == null || tempGridData.Rows.Count == 0)
            {
                ShowMessage("No items to save. Please add items using 'Allow' button first.", "red");
                return;
            }

            int successCount = 0;
            int errorCount = 0;

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();

                foreach (DataRow row in tempGridData.Rows)
                {
                    int membershipId = Convert.ToInt32(row["MembershipID"]);
                    int departmentId = Convert.ToInt32(row["DepartmentID"]);

                    try
                    {
                       
                        string checkQuery = "SELECT COUNT(*) FROM AllowedAreas WHERE MembershipID = @MembershipID AND DepartmentID = @DepartmentID";
                        using (SqlCommand checkCmd = new SqlCommand(checkQuery, con))
                        {
                            checkCmd.Parameters.AddWithValue("@MembershipID", membershipId);
                            checkCmd.Parameters.AddWithValue("@DepartmentID", departmentId);

                            int exists = Convert.ToInt32(checkCmd.ExecuteScalar());

                            if (exists == 0)
                            {
                                
                                string insertQuery = "INSERT INTO AllowedAreas (MembershipID, DepartmentID) VALUES (@MembershipID, @DepartmentID)";
                                using (SqlCommand insertCmd = new SqlCommand(insertQuery, con))
                                {
                                    insertCmd.Parameters.AddWithValue("@MembershipID", membershipId);
                                    insertCmd.Parameters.AddWithValue("@DepartmentID", departmentId);
                                    insertCmd.ExecuteNonQuery();
                                    successCount++;
                                }
                            }
                            else
                            {
                                errorCount++; 
                            }
                        }
                    }
                    catch (Exception)
                    {
                        errorCount++;
                        
                    }
                }
            }

            
            tempGridData.Rows.Clear();
            ViewState["TempGridData"] = tempGridData;
            GridView1.DataSource = tempGridData;
            GridView1.DataBind();

            
            if (successCount > 0)
            {
                ShowMessage("{successCount} item(s) saved successfully to database." +
                           (errorCount > 0 ? " {errorCount} item(s) were skipped (already exist)." : ""), "green");
            }
            else
            {
                ShowMessage("No items were saved. All items may already exist in the database.", "orange");
            }
        }

        private void BindAllowedAreasGrid()
        {
            string gridQuery = @"
                SELECT f.FormType AS FormType, d.Dept_Name AS Dept_Name
                FROM AllowedAreas a
                INNER JOIN MemberShip.dbo.FormTable f ON a.MembershipID = f.id
                INNER JOIN BasicDataInfo.dbo.Department d ON a.DepartmentID = d.Dept_Id";

            using (SqlConnection con = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(gridQuery, con))
            {
                con.Open();
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                GridView1.DataSource = dt;
                GridView1.DataBind();
            }
        }

        protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteRow")
            {
                int index = Convert.ToInt32(e.CommandArgument);

                
                if (tempGridData != null && tempGridData.Rows.Count > 0)
                {
                    if (index < tempGridData.Rows.Count)
                    {
                        tempGridData.Rows.RemoveAt(index);

                        
                        for (int i = 0; i < tempGridData.Rows.Count; i++)
                        {
                            tempGridData.Rows[i]["RowIndex"] = i;
                        }

                        ViewState["TempGridData"] = tempGridData;
                        GridView1.DataSource = tempGridData;
                        GridView1.DataBind();

                        ShowMessage("Item removed from list.", "green");
                    }
                }
            }
        }

        protected void GridView1_RowEditing(object sender, GridViewEditEventArgs e)
        {
            GridView1.EditIndex = e.NewEditIndex;
            GridView1.DataSource = tempGridData;
            GridView1.DataBind();

           
            GridViewRow row = GridView1.Rows[e.NewEditIndex];
            DropDownList ddlEditMembershipType = (DropDownList)row.FindControl("ddlEditMembershipType");
            DropDownList ddlEditDepartment = (DropDownList)row.FindControl("ddlEditDepartment");

            if (ddlEditMembershipType != null)
            {
                BindMembershipTypesToDropdown(ddlEditMembershipType);

                
                string currentFormType = tempGridData.Rows[e.NewEditIndex]["FormType"].ToString();
                ddlEditMembershipType.ClearSelection();
                ListItem selectedItem = ddlEditMembershipType.Items.FindByText(currentFormType);
                if (selectedItem != null)
                {
                    selectedItem.Selected = true;
                }
            }

            if (ddlEditDepartment != null)
            {
                BindDepartmentsToDropdown(ddlEditDepartment);

                
                string currentDeptName = tempGridData.Rows[e.NewEditIndex]["Dept_Name"].ToString();
                ddlEditDepartment.ClearSelection();
                ListItem selectedItem = ddlEditDepartment.Items.FindByText(currentDeptName);
                if (selectedItem != null)
                {
                    selectedItem.Selected = true;
                }
            }
        }

        protected void GridView1_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            GridViewRow row = GridView1.Rows[e.RowIndex];
            DropDownList ddlEditMembershipType = (DropDownList)row.FindControl("ddlEditMembershipType");
            DropDownList ddlEditDepartment = (DropDownList)row.FindControl("ddlEditDepartment");

            if (ddlEditMembershipType != null && ddlEditDepartment != null)
            {
                string newFormType = ddlEditMembershipType.SelectedItem.Text;
                string newDeptName = ddlEditDepartment.SelectedItem.Text;
                int newMembershipId = Convert.ToInt32(ddlEditMembershipType.SelectedValue);
                int newDepartmentId = Convert.ToInt32(ddlEditDepartment.SelectedValue);

                // Check for duplicates (excluding current row)
                for (int i = 0; i < tempGridData.Rows.Count; i++)
                {
                    if (i != e.RowIndex)
                    {
                        if (tempGridData.Rows[i]["FormType"].ToString() == newFormType &&
                            tempGridData.Rows[i]["Dept_Name"].ToString() == newDeptName)
                        {
                            ShowMessage("This combination already exists in the list.", "red");
                            GridView1.EditIndex = -1;
                            GridView1.DataSource = tempGridData;
                            GridView1.DataBind();
                            return;
                        }
                    }
                }

                
                tempGridData.Rows[e.RowIndex]["FormType"] = newFormType;
                tempGridData.Rows[e.RowIndex]["Dept_Name"] = newDeptName;
                tempGridData.Rows[e.RowIndex]["MembershipID"] = newMembershipId;
                tempGridData.Rows[e.RowIndex]["DepartmentID"] = newDepartmentId;

                ViewState["TempGridData"] = tempGridData;

                GridView1.EditIndex = -1;
                GridView1.DataSource = tempGridData;
                GridView1.DataBind();

                ShowMessage("Item updated successfully.", "green");
            }
        }

        protected void GridView1_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            GridView1.EditIndex = -1;
            GridView1.DataSource = tempGridData;
            GridView1.DataBind();
        }

        private void BindMembershipTypesToDropdown(DropDownList ddl)
        {
            string query = "SELECT id, FormType FROM FormTable where Status=1";

            using (SqlConnection con = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                ddl.DataSource = dr;
                ddl.DataTextField = "FormType";
                ddl.DataValueField = "id";
                ddl.DataBind();
            }

            ddl.Items.Insert(0, new ListItem("-- Select Membership Type --", "0"));
        }

        private void BindDepartmentsToDropdown(DropDownList ddl)
        {
            string query = "SELECT Dept_Id, Dept_Name FROM Department";

            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["Basic_Data_ConnectionString"].ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                ddl.DataSource = dr;
                ddl.DataTextField = "Dept_Name";
                ddl.DataValueField = "Dept_Id";
                ddl.DataBind();
            }

            ddl.Items.Insert(0, new ListItem("-- Select Department Area --", "0"));
        }

        private void ShowMessage(string message, string color)
        {
            lblMessage.Text = message;

            switch (color.ToLower())
            {
                case "red":
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                    break;
                case "green":
                    lblMessage.ForeColor = System.Drawing.Color.Green;
                    break;
                case "blue":
                    lblMessage.ForeColor = System.Drawing.Color.Blue;
                    break;
                case "orange":
                    lblMessage.ForeColor = System.Drawing.Color.Orange;
                    break;
                default:
                    lblMessage.ForeColor = System.Drawing.Color.Black;
                    break;
            }

            lblMessage.Visible = true;
        }
    }
}
