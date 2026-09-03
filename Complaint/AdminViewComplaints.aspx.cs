using System;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI.WebControls;

namespace GuestRoomApp.GuestRoomM
{
    public partial class CancelRoomReservation : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["ComplaintsDB"] != null 
            ? ConfigurationManager.ConnectionStrings["ComplaintsDB"].ConnectionString 
            : ConfigurationManager.ConnectionStrings["Basic_Data_ConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDepartments();
                LoadFeedbackOptions();   // loads all distinct answer texts
                LoadComplaints();
            }
        }

        private void LoadDepartments()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "SELECT Dept_ID, Dept_name FROM BasicDataInfo.dbo.Department ORDER BY Dept_name";
                SqlDataAdapter da = new SqlDataAdapter(query, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlFilterDept.DataTextField = "Dept_name";
                ddlFilterDept.DataValueField = "Dept_ID";
                ddlFilterDept.Items.Clear();
                ddlFilterDept.DataSource = dt;
                ddlFilterDept.DataBind();
                ddlFilterDept.Items.Insert(0, new ListItem("-- All --", ""));
            }
        }

        private void LoadSubDepartments(int deptId)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "SELECT SubDept_Id, SubDept_Name FROM BasicDataInfo.dbo.SubDepartment WHERE Dept_ID = @DeptId ORDER BY SubDept_Name";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@DeptId", deptId);
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                ddlFilterSubDept.DataSource = reader;
                ddlFilterSubDept.DataTextField = "SubDept_Name";
                ddlFilterSubDept.DataValueField = "SubDept_Id";
                ddlFilterSubDept.DataBind();
                conn.Close();
            }
            ddlFilterSubDept.Items.Insert(0, new ListItem("-- All --", ""));
        }

        // Loads all distinct answer texts from MCQ responses (from the AnswerText column)
        private void LoadFeedbackOptions()
        {
            ddlFilterFeedback.Items.Clear();
            ddlFilterFeedback.Items.Insert(0, new ListItem("-- All Feedback --", ""));

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = @"SELECT DISTINCT AnswerText 
                                 FROM Complaints 
                                 WHERE AnswerText IS NOT NULL AND AnswerText <> '' 
                                   AND AnswerOptionId IS NOT NULL
                                 ORDER BY AnswerText";
                SqlCommand cmd = new SqlCommand(query, conn);
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    string answer = reader["AnswerText"].ToString();
                    ddlFilterFeedback.Items.Add(new ListItem(answer, answer));
                }
                conn.Close();
            }
        }

        protected void ddlFilterDept_SelectedIndexChanged(object sender, EventArgs e)
        {
            string selectedValue = ddlFilterDept.SelectedValue;
            int deptId;
            if (!string.IsNullOrEmpty(selectedValue) && int.TryParse(selectedValue, out deptId))
            {
                LoadSubDepartments(deptId);
            }
            else
            {
                ddlFilterSubDept.Items.Clear();
                ddlFilterSubDept.Items.Insert(0, new ListItem("-- All --", ""));
            }
            LoadComplaints();
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadComplaints();
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtFilterMemberNo.Text = "";
            ddlFilterDept.SelectedIndex = 0;
            ddlFilterSubDept.Items.Clear();
            ddlFilterSubDept.Items.Insert(0, new ListItem("-- All --", ""));
            txtFromDate.Text = "";
            txtToDate.Text = "";
            ddlFilterFeedback.SelectedIndex = 0;
            LoadComplaints();
        }

        private void LoadComplaints()
        {
            string memberNo = txtFilterMemberNo.Text.Trim();
            string deptId = ddlFilterDept.SelectedValue;
            string subDeptId = ddlFilterSubDept.SelectedValue;
            string fromDate = txtFromDate.Text;
            string toDate = txtToDate.Text;
            string feedback = ddlFilterFeedback.SelectedValue;  // text of selected answer

            StringBuilder query = new StringBuilder();
            query.Append(@"
                SELECT 
                    ROW_NUMBER() OVER (ORDER BY MAX(c.SubmittedDate) DESC, c.MemberNumber) AS SerialNumber,
                    c.MemberNumber,
                    c.MemberName,
                    d.Dept_name,
                    sd.SubDept_Name,
                    MAX(c.SubmittedDate) AS SubmittedDate,
                    STUFF(
                        (SELECT '<br />' + q2.QuestionText + ': ' + c2.AnswerText
                         FROM Complaints c2
                         INNER JOIN Questions q2 ON c2.QuestionId = q2.Id
                         WHERE c2.SurveyHeaderId = c.SurveyHeaderId
                         ORDER BY c2.Id
                         FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 6, '')
                    AS QA_Concat
                FROM Complaints c
                INNER JOIN BasicDataInfo.dbo.Department d ON c.Dept_ID = d.Dept_ID
                INNER JOIN BasicDataInfo.dbo.SubDepartment sd ON c.SubDept_ID = sd.SubDept_Id
                WHERE 1=1
            ");

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                SqlCommand cmd = new SqlCommand();
                cmd.Connection = conn;

                // Existing filters
                if (!string.IsNullOrEmpty(memberNo))
                {
                    query.Append(" AND c.MemberNumber LIKE @memberNo");
                    cmd.Parameters.AddWithValue("@memberNo", "%" + memberNo + "%");
                }
                int dId;
                if (!string.IsNullOrEmpty(deptId) && int.TryParse(deptId, out dId))
                {
                    query.Append(" AND c.Dept_ID = @deptId");
                    cmd.Parameters.AddWithValue("@deptId", dId);
                }
                int sdId;
                if (!string.IsNullOrEmpty(subDeptId) && int.TryParse(subDeptId, out sdId))
                {
                    query.Append(" AND c.SubDept_ID = @subDeptId");
                    cmd.Parameters.AddWithValue("@subDeptId", sdId);
                }
                if (!string.IsNullOrEmpty(fromDate))
                {
                    query.Append(" AND CAST(c.SubmittedDate AS DATE) >= @fromDate");
                    cmd.Parameters.AddWithValue("@fromDate", fromDate);
                }
                if (!string.IsNullOrEmpty(toDate))
                {
                    query.Append(" AND CAST(c.SubmittedDate AS DATE) <= @toDate");
                    cmd.Parameters.AddWithValue("@toDate", toDate);
                }

                // NEW single feedback filter
                if (!string.IsNullOrEmpty(feedback))
                {
                    query.Append(@" AND EXISTS (
                        SELECT 1 FROM Complaints c3
                        WHERE c3.SurveyHeaderId = c.SurveyHeaderId
                          AND c3.AnswerText = @feedback
                    )");
                    cmd.Parameters.AddWithValue("@feedback", feedback);
                }

                query.Append(@"
                    GROUP BY c.SurveyHeaderId, c.MemberNumber, c.MemberName, d.Dept_name, sd.SubDept_Name
                    ORDER BY SubmittedDate DESC, c.MemberNumber
                ");

                cmd.CommandText = query.ToString();
                conn.Open();
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                conn.Close();

                gvComplaints.DataSource = dt;
                gvComplaints.DataBind();

                if (dt.Rows.Count == 0)
                {
                    lblMessage.Text = "No complaints found with the selected filters.";
                    lblMessage.ForeColor = System.Drawing.Color.FromArgb(226, 92, 92);
                    lblMessage.Style.Add("background", "#fee2e2");
                    lblMessage.Style.Add("border-left", "4px solid #e25c5c");
                }
                else
                {
                    lblMessage.Text = "";
                }
            }
        }

        protected void gvComplaints_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Attributes.Add("onmouseover", "this.style.backgroundColor='#fef3e8'");
                e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=''");
            }
        }
    }
}