using System;
using System.Data;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Data.SqlClient;

namespace RefundFee
{
    public partial class AdminComplaint : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["ComplaintsDB"] != null 
            ? ConfigurationManager.ConnectionStrings["ComplaintsDB"].ConnectionString 
            : ConfigurationManager.ConnectionStrings["Basic_Data_ConnectionString"].ConnectionString;
        private const string OptionsTableKey = "OptionsDataTable";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDepartments();
                LoadQuestions();
                ClearAddEditPanel();
            }
        }

        // ---------- Load Departments ----------
        private void LoadDepartments()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "SELECT Dept_ID, Dept_name FROM BasicDataInfo.dbo.Department ORDER BY Dept_name";
                SqlDataAdapter da = new SqlDataAdapter(query, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                ddlDepartment.DataSource = dt;
                ddlDepartment.DataBind();
                ddlDepartment.Items.Insert(0, new ListItem("-- Select Department --", ""));
            }
        }

        // ---------- Load SubDepartments based on selected Dept_ID ----------
        private void LoadSubDepartments(int deptId)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "SELECT SubDept_Id, SubDept_Name FROM BasicDataInfo.dbo.SubDepartment WHERE Dept_ID = @DeptId ORDER BY SubDept_Name";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@DeptId", deptId);
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                ddlSubDepartment.DataSource = reader;
                ddlSubDepartment.DataTextField = "SubDept_Name";
                ddlSubDepartment.DataValueField = "SubDept_Id";
                ddlSubDepartment.DataBind();
                conn.Close();
            }
            ddlSubDepartment.Items.Insert(0, new ListItem("-- Select Sub-Department --", ""));
        }

        // ---------- Load questions (only active, not soft-deleted) with Dept/SubDept names ----------
        private void LoadQuestions()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = @"SELECT q.Id, q.QuestionText, q.QuestionType, 
                                        d.Dept_name, sd.SubDept_Name
                                 FROM Questions q
                                 INNER JOIN BasicDataInfo.dbo.Department d ON q.Dept_ID = d.Dept_ID
                                 INNER JOIN BasicDataInfo.dbo.SubDepartment sd ON q.SubDept_ID = sd.SubDept_Id
                                 WHERE q.IsDeleted = 0
                                 ORDER BY q.Id DESC";
                SqlDataAdapter da = new SqlDataAdapter(query, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvQuestions.DataSource = dt;
                gvQuestions.DataBind();
            }
        }

        // ---------- Clear Add/Edit Panel ----------
        private void ClearAddEditPanel()
        {
            hfQuestionId.Value = "0";
            txtQuestionText.Text = "";
            ddlQuestionType.SelectedValue = "TEXT";
            litMode.Text = "Add New Question";
            pnlOptions.Visible = false;
            ViewState[OptionsTableKey] = null;
            gvOptions.DataSource = null;
            gvOptions.DataBind();
            // Reset dropdowns (but keep department list)
            ddlDepartment.ClearSelection();
            ddlSubDepartment.Items.Clear();
            ddlSubDepartment.Items.Insert(0, new ListItem("-- Select Sub-Department --", ""));
        }

        // ---------- Load question for editing ----------
        private void LoadQuestionForEdit(int questionId)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "SELECT QuestionText, QuestionType, Dept_ID, SubDept_ID FROM Questions WHERE Id = @Id AND IsDeleted = 0";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Id", questionId);
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    hfQuestionId.Value = questionId.ToString();
                    txtQuestionText.Text = reader["QuestionText"].ToString();
                    string qType = reader["QuestionType"].ToString();
                    ddlQuestionType.SelectedValue = qType;
                    litMode.Text = "Edit Question";

                    int deptId = Convert.ToInt32(reader["Dept_ID"]);
                    int subDeptId = Convert.ToInt32(reader["SubDept_ID"]);

                    // Set department
                    ddlDepartment.SelectedValue = deptId.ToString();
                    // Load subdepartments based on this department
                    LoadSubDepartments(deptId);
                    // Set subdepartment
                    ddlSubDepartment.SelectedValue = subDeptId.ToString();

                    // Load options if MCQ
                    if (qType == "MCQ")
                    {
                        pnlOptions.Visible = true;
                        LoadOptionsDataTable(questionId);
                    }
                    else
                    {
                        pnlOptions.Visible = false;
                        ViewState[OptionsTableKey] = null;
                        gvOptions.DataSource = null;
                        gvOptions.DataBind();
                    }
                }
                else
                {
                    lblMessage.Text = "Question not found or already deleted.";
                    ClearAddEditPanel();
                }
                conn.Close();
            }
        }

        // Load options from DB into DataTable
        private void LoadOptionsDataTable(int questionId)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Id", typeof(int));
            dt.Columns.Add("OptionText", typeof(string));
            dt.Columns.Add("IsDeleted", typeof(bool));

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "SELECT Id, OptionText, IsDeleted FROM QuestionOptions WHERE QuestionId = @Qid ORDER BY DisplayOrder";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Qid", questionId);
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    dt.Rows.Add(reader["Id"], reader["OptionText"], Convert.ToBoolean(reader["IsDeleted"]));
                }
                conn.Close();
            }
            ViewState[OptionsTableKey] = dt;
            BindOptionsGrid();
        }

        private void BindOptionsGrid()
        {
            DataTable dt = ViewState[OptionsTableKey] as DataTable;
            if (dt != null)
            {
                gvOptions.DataSource = dt;
                gvOptions.DataBind();
            }
            else
            {
                gvOptions.DataSource = null;
                gvOptions.DataBind();
            }
        }

        // ---------- Event: Department changed (update SubDepartment dropdown) ----------
        protected void ddlDepartment_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(ddlDepartment.SelectedValue))
            {
                int deptId = Convert.ToInt32(ddlDepartment.SelectedValue);
                LoadSubDepartments(deptId);
            }
            else
            {
                ddlSubDepartment.Items.Clear();
                ddlSubDepartment.Items.Insert(0, new ListItem("-- Select Sub-Department --", ""));
            }
        }

        // ---------- Event: Type changed (show/hide options) ----------
        protected void ddlQuestionType_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlQuestionType.SelectedValue == "MCQ")
            {
                pnlOptions.Visible = true;
                if (hfQuestionId.Value == "0" && ViewState[OptionsTableKey] == null)
                {
                    DataTable dt = new DataTable();
                    dt.Columns.Add("Id", typeof(int));
                    dt.Columns.Add("OptionText", typeof(string));
                    dt.Columns.Add("IsDeleted", typeof(bool));
                    ViewState[OptionsTableKey] = dt;
                    BindOptionsGrid();
                }
                else
                {
                    BindOptionsGrid();
                }
            }
            else
            {
                pnlOptions.Visible = false;
                ViewState[OptionsTableKey] = null;
                gvOptions.DataSource = null;
                gvOptions.DataBind();
            }
        }

        // Add option to in-memory table
        protected void btnAddOption_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtNewOption.Text))
            {
                lblMessage.Text = "Option text cannot be empty.";
                return;
            }

            DataTable dt = ViewState[OptionsTableKey] as DataTable;
            if (dt == null)
            {
                dt = new DataTable();
                dt.Columns.Add("Id", typeof(int));
                dt.Columns.Add("OptionText", typeof(string));
                dt.Columns.Add("IsDeleted", typeof(bool));
                ViewState[OptionsTableKey] = dt;
            }
            dt.Rows.Add(0, txtNewOption.Text.Trim(), false);
            txtNewOption.Text = "";
            BindOptionsGrid();
        }

        // Save Question with Department and SubDepartment
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtQuestionText.Text))
            {
                lblMessage.Text = "Question text is required.";
                return;
            }
            if (string.IsNullOrEmpty(ddlDepartment.SelectedValue))
            {
                lblMessage.Text = "Please select a department.";
                return;
            }
            if (string.IsNullOrEmpty(ddlSubDepartment.SelectedValue))
            {
                lblMessage.Text = "Please select a sub-department.";
                return;
            }

            int deptId = Convert.ToInt32(ddlDepartment.SelectedValue);
            int subDeptId = Convert.ToInt32(ddlSubDepartment.SelectedValue);
            string questionType = ddlQuestionType.SelectedValue;
            int questionId = Convert.ToInt32(hfQuestionId.Value);

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                SqlTransaction transaction = conn.BeginTransaction();

                try
                {
                    if (questionId == 0) // Insert
                    {
                        string insertQ = @"INSERT INTO Questions (QuestionText, QuestionType, Dept_ID, SubDept_ID) 
                                           VALUES (@Text, @Type, @DeptId, @SubDeptId); SELECT SCOPE_IDENTITY();";
                        SqlCommand cmd = new SqlCommand(insertQ, conn, transaction);
                        cmd.Parameters.AddWithValue("@Text", txtQuestionText.Text);
                        cmd.Parameters.AddWithValue("@Type", questionType);
                        cmd.Parameters.AddWithValue("@DeptId", deptId);
                        cmd.Parameters.AddWithValue("@SubDeptId", subDeptId);
                        questionId = Convert.ToInt32(cmd.ExecuteScalar());
                    }
                    else // Update
                    {
                        string updateQ = @"UPDATE Questions SET QuestionText = @Text, QuestionType = @Type, 
                                           Dept_ID = @DeptId, SubDept_ID = @SubDeptId, ModifiedDate = GETDATE() 
                                           WHERE Id = @Id";
                        SqlCommand cmd = new SqlCommand(updateQ, conn, transaction);
                        cmd.Parameters.AddWithValue("@Text", txtQuestionText.Text);
                        cmd.Parameters.AddWithValue("@Type", questionType);
                        cmd.Parameters.AddWithValue("@DeptId", deptId);
                        cmd.Parameters.AddWithValue("@SubDeptId", subDeptId);
                        cmd.Parameters.AddWithValue("@Id", questionId);
                        cmd.ExecuteNonQuery();
                    }

                    // Handle options
                    if (questionType == "MCQ")
                    {
                        DataTable dt = ViewState[OptionsTableKey] as DataTable;
                        if (dt != null)
                        {
                            foreach (DataRow row in dt.Rows)
                            {
                                int optId = Convert.ToInt32(row["Id"]);
                                string optText = row["OptionText"].ToString();
                                bool isDeleted = Convert.ToBoolean(row["IsDeleted"]);

                                if (optId == 0) // New
                                {
                                    string insertOpt = @"INSERT INTO QuestionOptions (QuestionId, OptionText, IsDeleted, DisplayOrder) 
                                                          VALUES (@Qid, @Text, @Deleted, 0)";
                                    SqlCommand cmdOpt = new SqlCommand(insertOpt, conn, transaction);
                                    cmdOpt.Parameters.AddWithValue("@Qid", questionId);
                                    cmdOpt.Parameters.AddWithValue("@Text", optText);
                                    cmdOpt.Parameters.AddWithValue("@Deleted", isDeleted);
                                    cmdOpt.ExecuteNonQuery();
                                }
                                else // Update
                                {
                                    string updateOpt = "UPDATE QuestionOptions SET OptionText = @Text, IsDeleted = @Deleted WHERE Id = @Id";
                                    SqlCommand cmdOpt = new SqlCommand(updateOpt, conn, transaction);
                                    cmdOpt.Parameters.AddWithValue("@Text", optText);
                                    cmdOpt.Parameters.AddWithValue("@Deleted", isDeleted);
                                    cmdOpt.Parameters.AddWithValue("@Id", optId);
                                    cmdOpt.ExecuteNonQuery();
                                }
                            }
                        }
                    }
                    else // TEXT type: soft delete all options for this question
                    {
                        string delOpts = "UPDATE QuestionOptions SET IsDeleted = 1 WHERE QuestionId = @Qid";
                        SqlCommand cmdDel = new SqlCommand(delOpts, conn, transaction);
                        cmdDel.Parameters.AddWithValue("@Qid", questionId);
                        cmdDel.ExecuteNonQuery();
                    }

                    transaction.Commit();
                    lblMessage.Text = "Question saved successfully.";
                    lblMessage.CssClass = "success";
                    LoadQuestions();
                    ClearAddEditPanel();
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    lblMessage.Text = "Error: " + ex.Message;
                    lblMessage.CssClass = "error";
                }
                finally
                {
                    conn.Close();
                }
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ClearAddEditPanel();
            lblMessage.Text = "";
        }

        // GridView commands
        protected void gvQuestions_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int questionId = Convert.ToInt32(e.CommandArgument);
            if (e.CommandName == "EditQuestion")
            {
                LoadQuestionForEdit(questionId);
            }
            else if (e.CommandName == "DeleteQuestion")
            {
                SoftDeleteQuestion(questionId);
            }
        }

        private void SoftDeleteQuestion(int questionId)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "UPDATE Questions SET IsDeleted = 1 WHERE Id = @Id";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Id", questionId);
                conn.Open();
                cmd.ExecuteNonQuery();
                conn.Close();
            }
            lblMessage.Text = "Question soft-deleted.";
            lblMessage.CssClass = "success";
            LoadQuestions();
            ClearAddEditPanel();
        }
    }
}