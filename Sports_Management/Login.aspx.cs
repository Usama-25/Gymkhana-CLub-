using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Collections.Generic;

public partial class Login : System.Web.UI.Page
{
    string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Clear any existing session
            Session.Clear();

            if (Request.QueryString["error"] == "nopages")
            {
                ShowError("Your account has no pages assigned. Please contact the administrator.");
            }
        }
    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
        pnlError.Visible = false;

        string username = txtUsername.Text.Trim();
        string password = txtPassword.Text;

        if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
        {
            ShowError("Please enter both username and password.");
            return;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = "SELECT Emp_ID, Username, Role FROM SystemUsers WHERE Username = @Username AND Password = @Password";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Username", username);
                    cmd.Parameters.AddWithValue("@Password", password);

                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int empId = Convert.ToInt32(reader["Emp_ID"]);
                            string dbUsername = reader["Username"].ToString();
                            string role = reader["Role"].ToString();

                            // Close the reader so we can execute another command
                            reader.Close();

                            // Load user's allowed sports if they are an operator
                            List<int> allowedSports = new List<int>();
                            List<string> allowedSportsNames = new List<string>();
                            if (role == "Operator")
                            {
                                string sportsQuery = "SELECT us.SportID, s.SportName FROM UserSports us INNER JOIN Sports s ON us.SportID = s.SportID WHERE us.Emp_ID = @EmpID";
                                using (SqlCommand sportsCmd = new SqlCommand(sportsQuery, con))
                                {
                                    sportsCmd.Parameters.AddWithValue("@EmpID", empId);
                                    using (SqlDataReader sportsReader = sportsCmd.ExecuteReader())
                                    {
                                        while (sportsReader.Read())
                                        {
                                            allowedSports.Add(Convert.ToInt32(sportsReader["SportID"]));
                                            allowedSportsNames.Add(sportsReader["SportName"].ToString());
                                        }
                                    }
                                }
                            }

                            // Load user's allowed pages
                            List<string> allowedPages = new List<string>();
                            string pagesQuery = "SELECT PageName FROM UserPages WHERE Emp_ID = @EmpID";
                            using (SqlCommand pagesCmd = new SqlCommand(pagesQuery, con))
                            {
                                pagesCmd.Parameters.AddWithValue("@EmpID", empId);
                                using (SqlDataReader pagesReader = pagesCmd.ExecuteReader())
                                {
                                    while (pagesReader.Read())
                                    {
                                        allowedPages.Add(pagesReader["PageName"].ToString().ToLower());
                                    }
                                }
                            }

                            // Store user details in session
                            Session["Emp_ID"] = empId;
                            Session["Username"] = dbUsername;
                            Session["UserRole"] = role;
                            Session["AllowedSports"] = allowedSports;
                            Session["AllowedPages"] = allowedPages;
                            Session["AllowedSportsNames"] = role == "Admin" ? "All Sports" : (allowedSportsNames.Count > 0 ? string.Join(", ", allowedSportsNames) : "No Sports");

                            // Redirect to landing module page
                            string landingPage = "MemberSubscriptions.aspx";
                            if (role != "Admin")
                            {
                                if (allowedPages.Count > 0)
                                {
                                    // Set default landing to their first allowed page if they don't have access to MemberSubscriptions
                                    if (!allowedPages.Contains("membersubscriptions.aspx"))
                                    {
                                        landingPage = allowedPages[0];
                                    }
                                }
                                else
                                {
                                    // No pages assigned, show error on login screen
                                    ShowError("No pages assigned to your account. Please contact your administrator.");
                                    return;
                                }
                            }

                            Response.Redirect(landingPage);
                        }
                        else
                        {
                            ShowError("Invalid username or password.");
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowError("System Error: " + ex.Message);
        }
    }

    private void ShowError(string message)
    {
        pnlError.Visible = true;
        lblErrorMsg.Text = message;
    }
}
