using System;
using System.Data;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Data.SqlClient;

namespace RefundFee
{
    public partial class MemberSurvey : System.Web.UI.Page
    {
        private string questionsConn = ConfigurationManager.ConnectionStrings["ComplaintsDB"] != null 
            ? ConfigurationManager.ConnectionStrings["ComplaintsDB"].ConnectionString 
            : ConfigurationManager.ConnectionStrings["Basic_Data_ConnectionString"].ConnectionString;
        private string membershipConn = ConfigurationManager.ConnectionStrings["MembershipConnection"].ConnectionString;

        private int? UrlDeptId = null;
        private int? UrlSubDeptId = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            string deptParam = Request.QueryString["DeptId"];
            string subDeptParam = Request.QueryString["SubDeptId"];
            int tmp;
            if (!string.IsNullOrEmpty(deptParam) && int.TryParse(deptParam, out tmp))
                UrlDeptId = tmp;
            else
                UrlDeptId = null;
            if (!string.IsNullOrEmpty(subDeptParam) && int.TryParse(subDeptParam, out tmp))
                UrlSubDeptId = tmp;
            else
                UrlSubDeptId = null;

            if (!IsPostBack)
            {
                LoadDepartments();
                ViewState["IsSubmitted"] = false;

                if (UrlDeptId.HasValue && UrlSubDeptId.HasValue)
                {
                    pnlMemberPanel.Visible = false;
                    pnlDeptSelection.Visible = false;
                    pnlWelcomeBanner.Visible = true;
                    pnlDirectAccess.Visible = true;

                    string subDeptName = GetSubDepartmentName(UrlSubDeptId.Value);
                    if (!string.IsNullOrEmpty(subDeptName))
                        litSubDeptWelcome.Text = "<span style=\"font-size:1.35rem;font-weight:700;color:#B45309;letter-spacing:0.3px;\">Welcome to " + subDeptName + " Feedback</span>";
                    else
                        litSubDeptWelcome.Text = "<span style=\"font-size:1.35rem;font-weight:700;color:#B45309;letter-spacing:0.3px;\">Welcome to the Feedback Portal</span>";

                    LoadQuestions(UrlDeptId.Value, UrlSubDeptId.Value);
                    DataTable dt = ViewState["QuestionsTable"] as DataTable;
                    if (dt != null)
                    {
                        rptQuestionsInline.DataSource = dt;
                        rptQuestionsInline.DataBind();
                    }
                }
                else
                {
                    pnlWelcomeBanner.Visible = false;
                    pnlDirectAccess.Visible = false;
                }
            }
            else
            {
                DataTable dt = ViewState["QuestionsTable"] as DataTable;
                if (dt == null) return;

                if (UrlDeptId.HasValue && UrlSubDeptId.HasValue)
                {
                    rptQuestionsInline.DataSource = dt;
                    rptQuestionsInline.DataBind();
                }
                else
                {
                    rptQuestions.DataSource = dt;
                    rptQuestions.DataBind();
                }

                if (ViewState["IsSubmitted"] != null && (bool)ViewState["IsSubmitted"])
                {
                    DisableAllInputs();
                    btnSubmit.Visible = false;
                    btnSubmitInline.Visible = false;
                }
            }
        }

        private string GetSubDepartmentName(int subDeptId)
        {
            using (SqlConnection conn = new SqlConnection(questionsConn))
            {
                string query = "SELECT SubDept_Name FROM BasicDataInfo.dbo.SubDepartment WHERE SubDept_Id = @Id";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Id", subDeptId);
                conn.Open();
                object result = cmd.ExecuteScalar();
                conn.Close();
                return result != null ? result.ToString() : null;
            }
        }

        private void LoadDepartments()
        {
            using (SqlConnection conn = new SqlConnection(questionsConn))
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

        private void LoadSubDepartments(int deptId)
        {
            using (SqlConnection conn = new SqlConnection(questionsConn))
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

        protected void btnFetchMember_Click(object sender, EventArgs e)
        {
            string memberNo = txtMemberNo.Text.Trim();
            if (string.IsNullOrEmpty(memberNo))
            {
                ShowError("Please enter a member number.");
                return;
            }

            using (SqlConnection conn = new SqlConnection(membershipConn))
            {
                string query = "SELECT MemberName FROM MemberProfile WHERE MemberNo = @MemberNo";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                conn.Open();
                object result = cmd.ExecuteScalar();
                conn.Close();

                if (result != null)
                {
                    string memberName = result.ToString();
                    lblMemberName.Text = "Welcome, " + memberName + " (Member No: " + memberNo + ")";
                    pnlMemberInfo.Visible = true;
                    pnlDeptSelection.Visible = true;
                    ViewState["MemberID"] = memberNo;
                    ViewState["MemberName"] = memberName;
                    ShowSuccess("Member verified successfully.");
                }
                else
                {
                    ShowError("Member number not found.");
                    pnlMemberInfo.Visible = false;
                    pnlDeptSelection.Visible = false;
                }
            }
        }

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

        protected void ddlSubDepartment_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlSubDepartment.SelectedValue))
                return;

            int deptId = Convert.ToInt32(ddlDepartment.SelectedValue);
            int subDeptId = Convert.ToInt32(ddlSubDepartment.SelectedValue);
            LoadQuestions(deptId, subDeptId);
        }

        private void LoadQuestions(int deptId, int subDeptId)
        {
            DataTable dtQuestions = new DataTable();
            using (SqlConnection conn = new SqlConnection(questionsConn))
            {
                string query = @"SELECT Id, QuestionText, QuestionType 
                                 FROM Questions 
                                 WHERE Dept_ID = @DeptId AND SubDept_ID = @SubDeptId AND IsDeleted = 0
                                 ORDER BY Id";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@DeptId", deptId);
                cmd.Parameters.AddWithValue("@SubDeptId", subDeptId);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dtQuestions);
            }
            ViewState["QuestionsTable"] = dtQuestions;
        }

        protected void rptQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView row = (DataRowView)e.Item.DataItem;
                int questionId = Convert.ToInt32(row["Id"]);
                string questionType = row["QuestionType"].ToString();
                PlaceHolder phOptions = (PlaceHolder)e.Item.FindControl("phOptions");

                if (questionType == "MCQ")
                {
                    DataTable dtOptions = GetOptionsForQuestion(questionId);
                    RadioButtonList rbl = new RadioButtonList();
                    rbl.ID = "rbl_" + questionId;
                    rbl.DataSource = dtOptions;
                    rbl.DataTextField = "OptionText";
                    rbl.DataValueField = "Id";
                    rbl.DataBind();
                    rbl.RepeatDirection = RepeatDirection.Vertical;
                    rbl.CssClass = "radio-group";
                    rbl.Style.Add("margin-top", "8px");
                    phOptions.Controls.Add(rbl);
                }
                else
                {
                    TextBox txtAnswer = new TextBox();
                    txtAnswer.ID = "txt_" + questionId;
                    txtAnswer.TextMode = TextBoxMode.MultiLine;
                    txtAnswer.Rows = 3;
                    txtAnswer.Width = Unit.Percentage(100);
                    txtAnswer.Style.Add("background", "#f8fafc");
                    txtAnswer.Style.Add("border", "1px solid #dee2e6");
                    txtAnswer.Style.Add("border-radius", "14px");
                    txtAnswer.Style.Add("padding", "10px");
                    txtAnswer.Style.Add("font-family", "inherit");
                    phOptions.Controls.Add(txtAnswer);
                }
            }
        }

        protected void rptQuestionsInline_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView row = (DataRowView)e.Item.DataItem;
                int questionId = Convert.ToInt32(row["Id"]);
                string questionType = row["QuestionType"].ToString();
                PlaceHolder phOptions = (PlaceHolder)e.Item.FindControl("phOptionsInline");

                if (questionType == "MCQ")
                {
                    DataTable dtOptions = GetOptionsForQuestion(questionId);
                    RadioButtonList rbl = new RadioButtonList();
                    rbl.ID = "in_rbl_" + questionId;
                    rbl.DataSource = dtOptions;
                    rbl.DataTextField = "OptionText";
                    rbl.DataValueField = "Id";
                    rbl.DataBind();
                    rbl.RepeatDirection = RepeatDirection.Vertical;
                    rbl.CssClass = "radio-group";
                    rbl.Style.Add("margin-top", "8px");
                    phOptions.Controls.Add(rbl);
                }
                else
                {
                    TextBox txtAnswer = new TextBox();
                    txtAnswer.ID = "in_txt_" + questionId;
                    txtAnswer.TextMode = TextBoxMode.MultiLine;
                    txtAnswer.Rows = 3;
                    txtAnswer.Width = Unit.Percentage(100);
                    txtAnswer.Style.Add("background", "#f8fafc");
                    txtAnswer.Style.Add("border", "1px solid #dee2e6");
                    txtAnswer.Style.Add("border-radius", "14px");
                    txtAnswer.Style.Add("padding", "10px");
                    txtAnswer.Style.Add("font-family", "inherit");
                    phOptions.Controls.Add(txtAnswer);
                }
            }
        }

        private DataTable GetOptionsForQuestion(int questionId)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(questionsConn))
            {
                string query = "SELECT Id, OptionText FROM QuestionOptions WHERE QuestionId = @Qid AND IsDeleted = 0 ORDER BY DisplayOrder";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Qid", questionId);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }
            return dt;
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            if (ViewState["IsSubmitted"] != null && (bool)ViewState["IsSubmitted"])
            {
                ShowError("You have already submitted your answers.");
                return;
            }

            DataTable dtQuestions = ViewState["QuestionsTable"] as DataTable;
            if (dtQuestions == null || dtQuestions.Rows.Count == 0)
            {
                ShowError("No questions to submit.");
                return;
            }

            bool isDirectMode = (UrlDeptId.HasValue && UrlSubDeptId.HasValue);

            string memberNo = "";
            string memberName = "";
            string phoneNumber = "";
            string remarks = "";

            if (isDirectMode)
            {
                phoneNumber = txtPhoneNumberDirect.Text.Trim();
                remarks = txtRemarksDirect.Text.Trim();
                memberNo = txtMemberNoDirect.Text.Trim();
            }
            else
            {
                if (pnlMemberPanel.Visible && ViewState["MemberID"] != null)
                {
                    memberNo = ViewState["MemberID"].ToString();
                    memberName = ViewState["MemberName"] != null ? ViewState["MemberName"].ToString() : "";
                }
                phoneNumber = txtPhoneNumber.Text.Trim();
                remarks = txtRemarks.Text.Trim();
            }

            if (string.IsNullOrWhiteSpace(phoneNumber))
            {
                ShowError("Phone number is required.");
                return;
            }
            if (string.IsNullOrWhiteSpace(remarks))
            {
                ShowError("Remarks are required.");
                return;
            }

            int deptId = UrlDeptId ?? Convert.ToInt32(ddlDepartment.SelectedValue);
            int subDeptId = UrlSubDeptId ?? Convert.ToInt32(ddlSubDepartment.SelectedValue);

            using (SqlConnection conn = new SqlConnection(questionsConn))
            {
                conn.Open();
                SqlTransaction transaction = conn.BeginTransaction();
                try
                {
                    string headerSql = @"
                        INSERT INTO SurveyHeaders (MemberNumber, MemberName, Dept_ID, SubDept_ID, PhoneNumber, Remarks, SubmittedDate)
                        VALUES (@MemberNo, @MemberName, @DeptId, @SubDeptId, @PhoneNumber, @Remarks, GETDATE());
                        SELECT SCOPE_IDENTITY();";

                    SqlCommand headerCmd = new SqlCommand(headerSql, conn, transaction);
                    headerCmd.Parameters.AddWithValue("@MemberNo", memberNo);
                    headerCmd.Parameters.AddWithValue("@MemberName", memberName);
                    headerCmd.Parameters.AddWithValue("@DeptId", deptId);
                    headerCmd.Parameters.AddWithValue("@SubDeptId", subDeptId);
                    headerCmd.Parameters.AddWithValue("@PhoneNumber", phoneNumber);
                    headerCmd.Parameters.AddWithValue("@Remarks", remarks);
                    int surveyHeaderId = Convert.ToInt32(headerCmd.ExecuteScalar());

                    Repeater repeater = isDirectMode ? rptQuestionsInline : rptQuestions;
                    string prefix = isDirectMode ? "in_" : "";

                    foreach (RepeaterItem item in repeater.Items)
                    {
                        HiddenField hfQuestionId = (HiddenField)item.FindControl(isDirectMode ? "hfQuestionIdInline" : "hfQuestionId");
                        int qid = Convert.ToInt32(hfQuestionId.Value);
                        HiddenField hfType = (HiddenField)item.FindControl(isDirectMode ? "hfQuestionTypeInline" : "hfQuestionType");
                        string qType = hfType.Value;

                        string answerText = null;
                        int? answerOptionId = null;

                        if (qType == "MCQ")
                        {
                            RadioButtonList rbl = (RadioButtonList)item.FindControl(prefix + "rbl_" + qid);
                            if (rbl != null && rbl.SelectedItem != null)
                            {
                                answerText = rbl.SelectedItem.Text;
                                answerOptionId = Convert.ToInt32(rbl.SelectedValue);
                            }
                        }
                        else
                        {
                            TextBox txt = (TextBox)item.FindControl(prefix + "txt_" + qid);
                            if (txt != null)
                                answerText = txt.Text;
                        }

                        string insertSql = @"
                            INSERT INTO Complaints (MemberNumber, MemberName, Dept_ID, SubDept_ID, QuestionId, AnswerText, AnswerOptionId, SurveyHeaderId)
                            VALUES (@MemberNo, @MemberName, @DeptId, @SubDeptId, @QuestionId, @AnswerText, @AnswerOptionId, @SurveyHeaderId)";

                        SqlCommand cmd = new SqlCommand(insertSql, conn, transaction);
                        cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                        cmd.Parameters.AddWithValue("@MemberName", memberName);
                        cmd.Parameters.AddWithValue("@DeptId", deptId);
                        cmd.Parameters.AddWithValue("@SubDeptId", subDeptId);
                        cmd.Parameters.AddWithValue("@QuestionId", qid);
                        cmd.Parameters.AddWithValue("@AnswerText", (object)answerText ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@AnswerOptionId", (object)answerOptionId ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@SurveyHeaderId", surveyHeaderId);
                        cmd.ExecuteNonQuery();
                    }

                    transaction.Commit();

                    ViewState["IsSubmitted"] = true;
                    DisableAllInputs();
                    btnSubmit.Visible = false;
                    btnSubmitInline.Visible = false;

                    if (isDirectMode)
                    {
                        // Set the hidden flag – the client‑side script will read it and show the popup
                        hfShowPopup.Value = "1";
                    }
                    else
                    {
                        ShowSuccess("Your complaint has been submitted. Thank you!");
                    }
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    ShowError("Error saving complaint: " + ex.Message);
                }
                finally
                {
                    conn.Close();
                }
            }
        }

        private void DisableAllInputs()
        {
            txtMemberNo.Enabled = false;
            txtPhoneNumber.Enabled = false;
            txtRemarks.Enabled = false;
            txtMemberNoDirect.Enabled = false;
            txtPhoneNumberDirect.Enabled = false;
            txtRemarksDirect.Enabled = false;
            btnFetchMember.Enabled = false;
            ddlDepartment.Enabled = false;
            ddlSubDepartment.Enabled = false;

            foreach (RepeaterItem item in rptQuestions.Items)
                DisableItemControls(item, "");
            foreach (RepeaterItem item in rptQuestionsInline.Items)
                DisableItemControls(item, "in_");
        }

        private void DisableItemControls(RepeaterItem item, string prefix)
        {
            HiddenField hfType = (HiddenField)item.FindControl(prefix + "hfQuestionType");
            if (hfType == null)
            {
                hfType = (HiddenField)item.FindControl("hfQuestionType");
                if (hfType == null) return;
            }
            string qType = hfType.Value;
            HiddenField hfQid = (HiddenField)item.FindControl(prefix + "hfQuestionId");
            if (hfQid == null) hfQid = (HiddenField)item.FindControl("hfQuestionId");
            int qid = Convert.ToInt32(hfQid.Value);

            if (qType == "MCQ")
            {
                RadioButtonList rbl = (RadioButtonList)item.FindControl(prefix + "rbl_" + qid);
                if (rbl != null) rbl.Enabled = false;
            }
            else
            {
                TextBox txt = (TextBox)item.FindControl(prefix + "txt_" + qid);
                if (txt != null) txt.Enabled = false;
            }
        }

        private void ShowError(string msg)
        {
            lblMessage.Text = msg;
            lblMessage.ForeColor = System.Drawing.Color.FromArgb(226, 92, 92);
            lblMessage.Style.Add("background", "#fee2e2");
            lblMessage.Style.Add("border-left", "4px solid #e25c5c");
        }

        private void ShowSuccess(string msg)
        {
            lblMessage.Text = msg;
            lblMessage.ForeColor = System.Drawing.Color.FromArgb(46, 125, 50);
            lblMessage.Style.Add("background", "#e8f5e9");
            lblMessage.Style.Add("border-left", "4px solid #2e7d32");
        }
    }
}