using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Collections.Generic;

public partial class ManagePermissions : System.Web.UI.Page
{
    string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        // 1. Authorize Admin role
        if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
        {
            Response.Redirect("MemberSubscriptions.aspx");
            return;
        }

        if (!IsPostBack)
        {
            LoadSportsChecklist();
            LoadUsers();
        }
    }

    private void LoadUsers()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetUsers", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvUsers.DataSource = dt;
                        gvUsers.DataBind();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading users: " + ex.Message, false);
        }
    }

    private void LoadSportsChecklist()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetSports", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        
                        DataView dv = dt.DefaultView;
                        dv.RowFilter = "Status = True AND SportName <> 'Sports Cards'";
                        
                        cblSports.DataSource = dv;
                        cblSports.DataTextField = "SportName";
                        cblSports.DataValueField = "SportID";
                        cblSports.DataBind();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading sports checklist: " + ex.Message, false);
        }
    }

    protected void ddlRole_SelectedIndexChanged(object sender, EventArgs e)
    {
        pnlSportsAccess.Visible = (ddlRole.SelectedValue == "Operator");
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        string username = txtUsername.Text.Trim();
        string password = txtPassword.Text;
        string role = ddlRole.SelectedValue;
        bool isEdit = !string.IsNullOrEmpty(hfEmpID.Value);

        if (string.IsNullOrEmpty(username))
        {
            ShowMessage("Username is required.", false);
            return;
        }

        if (!isEdit && string.IsNullOrEmpty(password))
        {
            ShowMessage("Password is required for new users.", false);
            return;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                using (SqlTransaction trans = con.BeginTransaction())
                {
                    try
                    {
                        int empId = 0;
                        if (isEdit)
                        {
                            empId = Convert.ToInt32(hfEmpID.Value);
                            using (SqlCommand cmd = new SqlCommand("sp_UpdateUser", con, trans))
                            {
                                cmd.CommandType = CommandType.StoredProcedure;
                                cmd.Parameters.AddWithValue("@Emp_ID", empId);
                                cmd.Parameters.AddWithValue("@Username", username);
                                cmd.Parameters.AddWithValue("@Password", password); // empty string or value handled by procedure
                                cmd.Parameters.AddWithValue("@Role", role);
                                cmd.ExecuteNonQuery();
                            }
                        }
                        else
                        {
                            using (SqlCommand cmd = new SqlCommand("sp_InsertUser", con, trans))
                            {
                                cmd.CommandType = CommandType.StoredProcedure;
                                cmd.Parameters.AddWithValue("@Username", username);
                                cmd.Parameters.AddWithValue("@Password", password);
                                cmd.Parameters.AddWithValue("@Role", role);
                                object res = cmd.ExecuteScalar();
                                empId = Convert.ToInt32(res);
                            }
                        }

                        // Update operator sports mappings
                        // Clear existing mapping first
                        string clearQuery = "DELETE FROM UserSports WHERE Emp_ID = @EmpID";
                        using (SqlCommand deleteCmd = new SqlCommand(clearQuery, con, trans))
                        {
                            deleteCmd.Parameters.AddWithValue("@EmpID", empId);
                            deleteCmd.ExecuteNonQuery();
                        }

                        // Map selected sports if Operator
                        if (role == "Operator")
                        {
                            foreach (ListItem item in cblSports.Items)
                            {
                                if (item.Selected)
                                {
                                    string insertMapQuery = "INSERT INTO UserSports (Emp_ID, SportID) VALUES (@EmpID, @SportID)";
                                    using (SqlCommand mapCmd = new SqlCommand(insertMapQuery, con, trans))
                                    {
                                        mapCmd.Parameters.AddWithValue("@EmpID", empId);
                                        mapCmd.Parameters.AddWithValue("@SportID", Convert.ToInt32(item.Value));
                                        mapCmd.ExecuteNonQuery();
                                    }
                                }
                            }
                        }

                        // Update page mappings
                        // Clear existing mapping first
                        string clearPagesQuery = "DELETE FROM UserPages WHERE Emp_ID = @EmpID";
                        using (SqlCommand deletePagesCmd = new SqlCommand(clearPagesQuery, con, trans))
                        {
                            deletePagesCmd.Parameters.AddWithValue("@EmpID", empId);
                            deletePagesCmd.ExecuteNonQuery();
                        }

                        // Map selected pages
                        foreach (ListItem item in cblPages.Items)
                        {
                            if (item.Selected)
                            {
                                string insertPageMapQuery = "INSERT INTO UserPages (Emp_ID, PageName) VALUES (@EmpID, @PageName)";
                                using (SqlCommand mapPageCmd = new SqlCommand(insertPageMapQuery, con, trans))
                                {
                                    mapPageCmd.Parameters.AddWithValue("@EmpID", empId);
                                    mapPageCmd.Parameters.AddWithValue("@PageName", item.Value);
                                    mapPageCmd.ExecuteNonQuery();
                                }
                            }
                        }

                        trans.Commit();
                        ShowMessage(isEdit ? "User updated successfully!" : "User created successfully!", true);
                        ClearForm();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        throw ex;
                    }
                }
            }

            LoadUsers();
        }
        catch (Exception ex)
        {
            ShowMessage("Error saving user: " + ex.Message, false);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ClearForm();
        lblMessage.Visible = false;
    }

    protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "EditUser")
        {
            int empId = Convert.ToInt32(e.CommandArgument);
            LoadUserForEdit(empId);
        }
        else if (e.CommandName == "DeleteUser")
        {
            int empId = Convert.ToInt32(e.CommandArgument);
            DeleteUser(empId);
        }
    }

    private void LoadUserForEdit(int empId)
    {
        try
        {
            ClearForm();

            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = "SELECT Username, Role FROM SystemUsers WHERE Emp_ID = @EmpID";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@EmpID", empId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            hfEmpID.Value = empId.ToString();
                            txtUsername.Text = reader["Username"].ToString();
                            ddlRole.SelectedValue = reader["Role"].ToString();
                            ddlRole_SelectedIndexChanged(null, null);

                            reader.Close();

                            // Load user's selected sports
                            List<int> mappedSports = new List<int>();
                            string mappedQuery = "SELECT SportID FROM UserSports WHERE Emp_ID = @EmpID";
                            using (SqlCommand mapCmd = new SqlCommand(mappedQuery, con))
                            {
                                mapCmd.Parameters.AddWithValue("@EmpID", empId);
                                using (SqlDataReader mapReader = mapCmd.ExecuteReader())
                                {
                                    while (mapReader.Read())
                                    {
                                        mappedSports.Add(Convert.ToInt32(mapReader["SportID"]));
                                    }
                                }
                            }

                            // Check active sports
                            foreach (ListItem item in cblSports.Items)
                            {
                                int sportId = Convert.ToInt32(item.Value);
                                item.Selected = mappedSports.Contains(sportId);
                            }

                            // Load user's selected pages
                            List<string> mappedPages = new List<string>();
                            string mappedPagesQuery = "SELECT PageName FROM UserPages WHERE Emp_ID = @EmpID";
                            using (SqlCommand mapPagesCmd = new SqlCommand(mappedPagesQuery, con))
                            {
                                mapPagesCmd.Parameters.AddWithValue("@EmpID", empId);
                                using (SqlDataReader mapPagesReader = mapPagesCmd.ExecuteReader())
                                {
                                    while (mapPagesReader.Read())
                                    {
                                        mappedPages.Add(mapPagesReader["PageName"].ToString().ToLower());
                                    }
                                }
                            }

                            // Check active pages
                            foreach (ListItem item in cblPages.Items)
                            {
                                item.Selected = mappedPages.Contains(item.Value.ToLower());
                            }

                            litFormTitle.Text = "Edit User: " + txtUsername.Text;
                            litPassHint.Text = "Leave blank to keep current password.";
                            btnSave.Text = "Update User";
                            btnCancel.Visible = true;
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading user for edit: " + ex.Message, false);
        }
    }

    private void DeleteUser(int empId)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                // Cascade delete is defined in table FK, so deleting from SystemUsers handles UserSports
                string query = "DELETE FROM SystemUsers WHERE Emp_ID = @EmpID";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@EmpID", empId);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            ShowMessage("User deleted successfully.", true);
            ClearForm();
            LoadUsers();
        }
        catch (Exception ex)
        {
            ShowMessage("Error deleting user: " + ex.Message, false);
        }
    }

    private void ClearForm()
    {
        hfEmpID.Value = "";
        txtUsername.Text = "";
        txtPassword.Text = "";
        ddlRole.SelectedIndex = 0;
        ddlRole_SelectedIndexChanged(null, null);
        
        foreach (ListItem item in cblSports.Items)
        {
            item.Selected = false;
        }

        foreach (ListItem item in cblPages.Items)
        {
            item.Selected = false;
        }

        litFormTitle.Text = "Add New User";
        litPassHint.Text = "Password is required for new users.";
        btnSave.Text = "Save User";
        btnCancel.Visible = false;
    }

    private void ShowMessage(string msg, bool isSuccess)
    {
        lblMessage.Visible = true;
        lblMessage.Text = msg;
        if (isSuccess)
        {
            lblMessage.Style["background-color"] = "#d4edda";
            lblMessage.Style["color"] = "#155724";
            lblMessage.Style["border"] = "1px solid #c3e6cb";
        }
        else
        {
            lblMessage.Style["background-color"] = "#f8d7da";
            lblMessage.Style["color"] = "#721c24";
            lblMessage.Style["border"] = "1px solid #f5c6cb";
        }
    }
}
