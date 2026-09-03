using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Serialization;

namespace GymkhanaLibrary
{
    public partial class Pages_ComplaintDashboard : System.Web.UI.Page
    {
        // Public properties to pass JSON data directly to JavaScript Chart.js in markup
        public string TrendLabelsJson { get; set; }
        public string MemberTrendDataJson { get; set; }
        public string FeedbackTrendDataJson { get; set; }

        public string StatusLabelsJson { get; set; }
        public string StatusDataJson { get; set; }

        public string DeptLabelsJson { get; set; }
        public string DeptDataJson { get; set; }

        protected void Page_Init(object sender, EventArgs e)
        {
            TrendLabelsJson = "[]";
            MemberTrendDataJson = "[]";
            FeedbackTrendDataJson = "[]";
            StatusLabelsJson = "[]";
            StatusDataJson = "[]";
            DeptLabelsJson = "[]";
            DeptDataJson = "[]";
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Emp_ID"] == null || string.IsNullOrEmpty(Session["Emp_ID"].ToString()))
            {
                Response.Redirect("~/Login.aspx", true);
                return;
            }

            if (!IsPostBack)
            {
                LoadKPIs();
                LoadChartData();
                LoadRecentComplaints();
            }
        }

        private void LoadKPIs()
        {
            try
            {
                DataTable dt = DBHelper.GetKPIStats();
                if (dt != null && dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];
                    int memberCount = Convert.ToInt32(row["MemberComplaints"]);
                    int feedbackCount = Convert.ToInt32(row["MemberFeedbacks"]);
                    int pendingCount = Convert.ToInt32(row["PendingComplaints"]);
                    int progressCount = Convert.ToInt32(row["InProgressComplaints"]);
                    int resolvedClosed = Convert.ToInt32(row["ResolvedClosedComplaints"]);

                    litMemberComplaints.Text = memberCount.ToString();
                    litMemberFeedbacks.Text = feedbackCount.ToString();
                    litPendingCount.Text = pendingCount.ToString();
                    litProgressCount.Text = progressCount.ToString();

                    int total = memberCount + feedbackCount;
                    if (total > 0)
                    {
                        double rate = ((double)resolvedClosed / total) * 100.0;
                        litResolutionRate.Text = Math.Round(rate, 1).ToString() + "%";
                    }
                    else
                    {
                        litResolutionRate.Text = "0%";
                    }
                }
            }
            catch (Exception)
            {
                litMemberComplaints.Text = "0";
                litMemberFeedbacks.Text = "0";
                litPendingCount.Text = "0";
                litProgressCount.Text = "0";
                litResolutionRate.Text = "0%";
            }
        }

        private void LoadChartData()
        {
            JavaScriptSerializer js = new JavaScriptSerializer();
            
            try
            {
                // 1. Load Monthly Trend (Last 6 Months)
                DataTable dtTrend = DBHelper.GetMonthlyTrendStats();
                List<string> trendLabels = new List<string>();
                List<int> memberData = new List<int>();
                List<int> feedbackData = new List<int>();

                // Initialize last 6 months labels
                DateTime now = DateTime.Now;
                for (int i = 5; i >= 0; i--)
                {
                    DateTime targetMonth = now.AddMonths(-i);
                    string monthLabel = targetMonth.ToString("MMM yyyy");
                    trendLabels.Add(monthLabel);
                    
                    int mCount = 0;
                    int fCount = 0;

                    foreach (DataRow row in dtTrend.Rows)
                    {
                        int rowYear = Convert.ToInt32(row["YearNum"]);
                        int rowMonth = Convert.ToInt32(row["MonthNum"]);

                        if (rowYear == targetMonth.Year && rowMonth == targetMonth.Month)
                        {
                            mCount = Convert.ToInt32(row["ComplaintCount"]);
                            fCount = Convert.ToInt32(row["FeedbackCount"]);
                            break;
                        }
                    }
                    memberData.Add(mCount);
                    feedbackData.Add(fCount);
                }

                TrendLabelsJson = js.Serialize(trendLabels);
                MemberTrendDataJson = js.Serialize(memberData);
                FeedbackTrendDataJson = js.Serialize(feedbackData);

                // 2. Load Status Distribution
                DataTable dtStatus = DBHelper.GetStatusStats();
                List<string> statusLabels = new List<string> { "Pending", "In Progress", "Resolved", "Closed" };
                List<int> statusData = new List<int> { 0, 0, 0, 0 };

                foreach (DataRow row in dtStatus.Rows)
                {
                    string status = row["Status"].ToString().Trim();
                    int count = Convert.ToInt32(row["StatusCount"]);

                    if (status.Equals("Pending", StringComparison.OrdinalIgnoreCase) || status.Equals("Submitted", StringComparison.OrdinalIgnoreCase)) 
                        statusData[0] += count;
                    else if (status.Equals("In Progress", StringComparison.OrdinalIgnoreCase)) 
                        statusData[1] += count;
                    else if (status.Equals("Resolved", StringComparison.OrdinalIgnoreCase)) 
                        statusData[2] += count;
                    else if (status.Equals("Closed", StringComparison.OrdinalIgnoreCase)) 
                        statusData[3] += count;
                }

                StatusLabelsJson = js.Serialize(statusLabels);
                StatusDataJson = js.Serialize(statusData);

                // 3. Load Department Hotspots (Top 5)
                DataTable dtDept = DBHelper.GetDepartmentStats();
                List<string> deptLabels = new List<string>();
                List<int> deptData = new List<int>();

                foreach (DataRow row in dtDept.Rows)
                {
                    deptLabels.Add(row["DeptName"].ToString());
                    deptData.Add(Convert.ToInt32(row["DeptCount"]));
                }

                DeptLabelsJson = js.Serialize(deptLabels);
                DeptDataJson = js.Serialize(deptData);
            }
            catch (Exception)
            {
                TrendLabelsJson = js.Serialize(new[] { "None" });
                MemberTrendDataJson = js.Serialize(new[] { 0 });
                FeedbackTrendDataJson = js.Serialize(new[] { 0 });
                StatusLabelsJson = js.Serialize(new[] { "Pending", "Resolved" });
                StatusDataJson = js.Serialize(new[] { 0, 0 });
                DeptLabelsJson = js.Serialize(new[] { "None" });
                DeptDataJson = js.Serialize(new[] { 0 });
            }
        }

        private void LoadRecentComplaints()
        {
            try
            {
                DataTable dt = DBHelper.GetRecentComplaints();
                gvRecentComplaints.DataSource = dt;
                gvRecentComplaints.DataBind();
            }
            catch (Exception)
            {
                gvRecentComplaints.DataSource = null;
                gvRecentComplaints.DataBind();
            }
        }

        protected void gvRecentComplaints_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ViewDetails")
            {
                try
                {
                    Response.Redirect("~/Complaint/ComplaintPanel.aspx");
                }
                catch { }
            }
        }

        // =====================================================================
        // LOCAL DATABASE HELPER FOR COMPLAINT & FEEDBACK STATS
        // =====================================================================
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

            private static SqlConnection GetConnection()
            {
                return new SqlConnection(ConnStr);
            }

            private static DataTable GetTableData(string query)
            {
                DataTable dt = new DataTable();
                using (SqlConnection con = GetConnection())
                using (SqlCommand cmd = new SqlCommand(query, con) { CommandTimeout = 120 })
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    con.Open();
                    da.Fill(dt);
                }
                return dt;
            }

            public static DataTable GetKPIStats()
            {
                string qry = @"
                    SELECT 
                        (SELECT COUNT(*) FROM dbo.Complaint) AS MemberComplaints,
                        (SELECT COUNT(*) FROM dbo.FeedbackSubmission) AS MemberFeedbacks,
                        (SELECT COUNT(*) FROM dbo.Complaint WHERE Status = 'Pending') + 
                            (SELECT COUNT(*) FROM dbo.FeedbackSubmission WHERE Status IN ('Pending', 'Submitted')) AS PendingComplaints,
                        (SELECT COUNT(*) FROM dbo.Complaint WHERE Status = 'In Progress') + 
                            (SELECT COUNT(*) FROM dbo.FeedbackSubmission WHERE Status = 'In Progress') AS InProgressComplaints,
                        (SELECT COUNT(*) FROM dbo.Complaint WHERE Status IN ('Resolved', 'Closed')) + 
                            (SELECT COUNT(*) FROM dbo.FeedbackSubmission WHERE Status IN ('Resolved', 'Closed')) AS ResolvedClosedComplaints,
                        (SELECT AVG(CAST(DATEDIFF(day, CreatedDate, UpdatedDate) AS FLOAT)) 
                         FROM (
                             SELECT CreatedDate, UpdatedDate FROM dbo.Complaint WHERE Status IN ('Resolved', 'Closed') AND UpdatedDate IS NOT NULL
                             UNION ALL
                             SELECT CreatedDate, UpdatedDate FROM dbo.FeedbackSubmission WHERE Status IN ('Resolved', 'Closed') AND UpdatedDate IS NOT NULL
                         ) t) AS AvgResolutionDays";
                return GetTableData(qry);
            }

            public static DataTable GetMonthlyTrendStats()
            {
                string qry = @"
                    SELECT 
                        YEAR(CreatedDate) AS YearNum,
                        MONTH(CreatedDate) AS MonthNum, 
                        SUM(CASE WHEN Type = 'Complaint' THEN 1 ELSE 0 END) AS ComplaintCount,
                        SUM(CASE WHEN Type = 'Feedback' THEN 1 ELSE 0 END) AS FeedbackCount
                    FROM (
                        SELECT CreatedDate, 'Complaint' AS Type FROM dbo.Complaint WHERE CreatedDate >= DATEADD(month, -5, GETDATE())
                        UNION ALL
                        SELECT CreatedDate, 'Feedback' AS Type FROM dbo.FeedbackSubmission WHERE CreatedDate >= DATEADD(month, -5, GETDATE())
                    ) t
                    GROUP BY YEAR(CreatedDate), MONTH(CreatedDate)
                    ORDER BY YEAR(CreatedDate) ASC, MONTH(CreatedDate) ASC";
                return GetTableData(qry);
            }

            public static DataTable GetStatusStats()
            {
                string qry = @"
                    SELECT Status, COUNT(*) AS StatusCount 
                    FROM (
                        SELECT Status FROM dbo.Complaint
                        UNION ALL
                        SELECT CASE WHEN Status = 'Submitted' THEN 'Pending' ELSE Status END AS Status FROM dbo.FeedbackSubmission
                    ) t
                    GROUP BY Status";
                return GetTableData(qry);
            }

            public static DataTable GetDepartmentStats()
            {
                string qry = @"
                    SELECT TOP 5 DeptName, COUNT(*) AS DeptCount
                    FROM (
                        SELECT d.Dept_Name AS DeptName 
                        FROM dbo.Complaint c
                        INNER JOIN BasicDataInfo.dbo.Department d ON c.DeptID = d.Dept_ID
                        UNION ALL
                        SELECT d.Dept_Name AS DeptName 
                        FROM dbo.FeedbackSubmission fs
                        INNER JOIN BasicDataInfo.dbo.Department d ON fs.DeptID = d.Dept_ID
                    ) t
                    WHERE DeptName IS NOT NULL
                    GROUP BY DeptName
                    ORDER BY DeptCount DESC";
                return GetTableData(qry);
            }

            public static DataTable GetRecentComplaints()
            {
                string qry = @"
                    SELECT TOP 5 ID, RecordType, CreatedDate, DepartmentName, Subject, SenderName, MemberNo, Status
                    FROM (
                        SELECT 
                            c.ComplaintID AS ID, 
                            'Complaint' AS RecordType, 
                            c.CreatedDate, 
                            ISNULL(d.Dept_Name, 'General') AS DepartmentName, 
                            c.ComplaintSubject AS Subject, 
                            ISNULL(mp.MemberName, 'Member') AS SenderName, 
                            c.MemberNo, 
                            c.Status
                        FROM dbo.Complaint c
                        LEFT JOIN BasicDataInfo.dbo.Department d ON c.DeptID = d.Dept_ID
                        LEFT JOIN MemberShip.dbo.MemberProfile mp ON c.MemberNo COLLATE DATABASE_DEFAULT = mp.MemberNo COLLATE DATABASE_DEFAULT
                        UNION ALL
                        SELECT 
                            fs.SubmissionID AS ID, 
                            'Feedback' AS RecordType, 
                            fs.CreatedDate, 
                            ISNULL(d.Dept_Name, 'General') AS DepartmentName, 
                            'Member Feedback' AS Subject, 
                            ISNULL(fs.MemberName, ISNULL(mp.MemberName, 'Member')) AS SenderName, 
                            fs.MemberNo, 
                            CASE WHEN fs.Status = 'Submitted' THEN 'Pending' ELSE fs.Status END AS Status
                        FROM dbo.FeedbackSubmission fs
                        LEFT JOIN BasicDataInfo.dbo.Department d ON fs.DeptID = d.Dept_ID
                        LEFT JOIN MemberShip.dbo.MemberProfile mp ON fs.MemberNo COLLATE DATABASE_DEFAULT = mp.MemberNo COLLATE DATABASE_DEFAULT
                    ) t
                    ORDER BY CreatedDate DESC";
                return GetTableData(qry);
            }
        }
    }
}
