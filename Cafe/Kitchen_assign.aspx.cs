using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Kitchen_assign : System.Web.UI.Page
{
    // Connection Strings
    private readonly string conStr = ConfigurationManager
        .ConnectionStrings["RestaurantConnectionString"].ConnectionString;

    private readonly string conStr1 = ConfigurationManager
        .ConnectionStrings["BasicDataInfoConnectionString"].ConnectionString;

    // Page Load
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            BindKitchenDropdown();
            BindDepartmentsCheckboxList();
        }
    }

    // Bind Kitchen Dropdown
    private void BindKitchenDropdown()
    {
        string query = @"SELECT SubDept_Id, SubDept_Name 
                         FROM SubDepartment 
                         WHERE SubDept_Type = 4 AND Dept_id = 9
                         ORDER BY SubDept_Name";

        using (SqlConnection con = new SqlConnection(conStr1))
        {
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                con.Open();
                ddlKitchen.DataSource = cmd.ExecuteReader();
                ddlKitchen.DataTextField = "SubDept_Name";
                ddlKitchen.DataValueField = "SubDept_Id";
                ddlKitchen.DataBind();
            }
        }

        ddlKitchen.Items.Insert(0, new ListItem("-- Select Kitchen --", "0"));
    }

    // Bind Departments Checkbox List
    private void BindDepartmentsCheckboxList()
    {
        string query = @"SELECT SubDept_Id, SubDept_Name 
                         FROM SubDepartment 
                         WHERE Dept_id = 9 
                         ORDER BY SubDept_Name";

        using (SqlConnection con = new SqlConnection(conStr1))
        {
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                con.Open();
                chkDepartments.DataSource = cmd.ExecuteReader();
                chkDepartments.DataTextField = "SubDept_Name";
                chkDepartments.DataValueField = "SubDept_Id";
                chkDepartments.DataBind();
            }
        }
    }

    // Kitchen Selection Changed Event
    protected void ddlKitchen_SelectedIndexChanged(object sender, EventArgs e)
    {
        // Clear all selections
        foreach (ListItem item in chkDepartments.Items)
        {
            item.Selected = false;
        }

        // Load existing mappings for selected kitchen
        if (ddlKitchen.SelectedValue != "0")
        {
            LoadExistingMappings();
            UpdateSelectedCount(); // Update label using C#
        }
    }

    // Load Existing Mappings for Selected Kitchen
    private void LoadExistingMappings()
    {
        int kitchenId = Convert.ToInt32(ddlKitchen.SelectedValue);

        string query = @"SELECT Department_SubDept_Id 
                         FROM Kitchen_Department_Map 
                         WHERE Kitchen_SubDept_Id = @KitchenId 
                         AND Active = 1";

        using (SqlConnection con = new SqlConnection(conStr))
        {
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@KitchenId", kitchenId);
                con.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    int deptId = Convert.ToInt32(reader["Department_SubDept_Id"]);
                    ListItem item = chkDepartments.Items.FindByValue(deptId.ToString());
                    if (item != null)
                    {
                        item.Selected = true;
                    }
                }
            }
        }
    }

    // Update selected count label using C#
    private void UpdateSelectedCount()
    {
        int count = 0;
        foreach (ListItem item in chkDepartments.Items)
        {
            if (item.Selected)
                count++;
        }
        lblSelectedCount.Text = count.ToString();
        lblSelectedCount.ForeColor = count > 0 ? System.Drawing.Color.Green : System.Drawing.Color.Red;
    }

    // Save Mapping (Soft Delete Implementation)
    protected void btnSave_Click(object sender, EventArgs e)
    {
        // Validation
        if (ddlKitchen.SelectedValue == "0")
        {
            ShowMessage("Please select a kitchen first", "warning");
            return;
        }

        if (Session["Emp_ID"] == null)
        {
            ShowMessage("Session expired. Please login again", "error");
            return;
        }

        int kitchenId = Convert.ToInt32(ddlKitchen.SelectedValue);
        int empId = Convert.ToInt32(Session["Emp_ID"]);

        // Count selected departments
        int selectedCount = 0;
        foreach (ListItem item in chkDepartments.Items)
        {
            if (item.Selected) selectedCount++;
        }

        if (selectedCount == 0)
        {
            ShowMessage("Please select at least one department", "warning");
            return;
        }

        using (SqlConnection con = new SqlConnection(conStr))
        {
            con.Open();
            SqlTransaction transaction = con.BeginTransaction();

            try
            {
                // Soft delete all existing mappings for this kitchen (set Active = 0)
                string softDeleteQuery = @"UPDATE Kitchen_Department_Map 
                                           SET Active = 0, 
                                               ModifiedDate = GETDATE()
                                           WHERE Kitchen_SubDept_Id = @KitchenId";

                using (SqlCommand delCmd = new SqlCommand(softDeleteQuery, con, transaction))
                {
                    delCmd.Parameters.AddWithValue("@KitchenId", kitchenId);
                    delCmd.ExecuteNonQuery();
                }

                // Insert new mappings with Active = 1
                int insertedCount = 0;
                foreach (ListItem item in chkDepartments.Items)
                {
                    if (item.Selected)
                    {
                        int deptId = Convert.ToInt32(item.Value);

                        // Check if mapping already exists (for reactivation)
                        string checkQuery = @"SELECT id FROM Kitchen_Department_Map 
                                              WHERE Kitchen_SubDept_Id = @KitchenId 
                                              AND Department_SubDept_Id = @DeptId";

                        using (SqlCommand checkCmd = new SqlCommand(checkQuery, con, transaction))
                        {
                            checkCmd.Parameters.AddWithValue("@KitchenId", kitchenId);
                            checkCmd.Parameters.AddWithValue("@DeptId", deptId);
                            object result = checkCmd.ExecuteScalar();

                            if (result != null)
                            {
                                // Reactivate existing mapping
                                string reactivateQuery = @"UPDATE Kitchen_Department_Map 
                                                           SET Active = 1,
                                                               Emp_ID = @EmpId,
                                                               ModifiedDate = GETDATE()
                                                           WHERE Kitchen_SubDept_Id = @KitchenId 
                                                           AND Department_SubDept_Id = @DeptId";

                                using (SqlCommand reactivateCmd = new SqlCommand(reactivateQuery, con, transaction))
                                {
                                    reactivateCmd.Parameters.AddWithValue("@KitchenId", kitchenId);
                                    reactivateCmd.Parameters.AddWithValue("@DeptId", deptId);
                                    reactivateCmd.Parameters.AddWithValue("@EmpId", empId);
                                    reactivateCmd.ExecuteNonQuery();
                                    insertedCount++;
                                }
                            }
                            else
                            {
                                // Insert new mapping with Active = 1
                                string insertQuery = @"INSERT INTO Kitchen_Department_Map
                                                       (Kitchen_SubDept_Id, Department_SubDept_Id, Emp_ID, Active, CreatedDate)
                                                       VALUES
                                                       (@KitchenId, @DeptId, @EmpId, 1, GETDATE())";

                                using (SqlCommand insertCmd = new SqlCommand(insertQuery, con, transaction))
                                {
                                    insertCmd.Parameters.AddWithValue("@KitchenId", kitchenId);
                                    insertCmd.Parameters.AddWithValue("@DeptId", deptId);
                                    insertCmd.Parameters.AddWithValue("@EmpId", empId);
                                    insertCmd.ExecuteNonQuery();
                                    insertedCount++;
                                }
                            }
                        }
                    }
                }

                transaction.Commit();
                ShowMessage("Success! {insertedCount} department(s) linked to kitchen", "success");

                // Refresh the display
                UpdateSelectedCount();
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                ShowMessage("Error: " + ex.Message, "error");
            }
        }
    }

    // Show Message using C# with Label instead of JavaScript
    private void ShowMessage(string message, string type)
    {
        lblMessage.Text = message;
        lblMessage.Visible = true;
        lblMessage.Style.Remove("display");
        lblMessage.Style.Add("display", "block");

        // Set color based on message type
        if (type == "success")
        {
            lblMessage.ForeColor = System.Drawing.Color.Green;
            lblMessage.BackColor = System.Drawing.Color.LightGreen;
        }
        else if (type == "error")
        {
            lblMessage.ForeColor = System.Drawing.Color.Red;
            lblMessage.BackColor = System.Drawing.Color.LightPink;
        }
        else if (type == "warning")
        {
            lblMessage.ForeColor = System.Drawing.Color.Orange;
            lblMessage.BackColor = System.Drawing.Color.LightYellow;
        }

        // Hide message after 5 seconds using Timer
        lblMessage.Style.Add("transition", "opacity 0.5s");
        System.Text.StringBuilder script = new System.Text.StringBuilder();
        script.Append("setTimeout(function() { ");
        script.Append("var msg = document.getElementById('");
        script.Append(lblMessage.ClientID);
        script.Append("'); if(msg) { msg.style.opacity = '0'; setTimeout(function() { msg.style.display = 'none'; }, 500); } }, 5000);");
        ClientScript.RegisterStartupScript(this.GetType(), "HideMessage", script.ToString(), true);
    }

    // Select All Button Click Event - FIXED
    protected void btnSelectAll_Click(object sender, EventArgs e)
    {
        // Check if all items are already selected
        bool allSelected = true;
        foreach (ListItem item in chkDepartments.Items)
        {
            if (!item.Selected)
            {
                allSelected = false;
                break;
            }
        }

        // If all are selected, unselect all; otherwise select all
        foreach (ListItem item in chkDepartments.Items)
        {
            item.Selected = !allSelected;
        }

        // Update the count after selection
        UpdateSelectedCount();

        // Show message
        if (!allSelected)
        {
            ShowMessage("All departments selected", "success");
        }
        else
        {
            ShowMessage("All departments unselected", "warning");
        }
    }

    // Checkbox List Selection Changed Event - ADD THIS
    protected void chkDepartments_SelectedIndexChanged(object sender, EventArgs e)
    {
        UpdateSelectedCount();
    }
}

