using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;  // â† ADD THIS for StringBuilder

namespace GuestRoomApp.GuestRoomM
{
    public partial class OccupancyReport : System.Web.UI.Page
    {
    private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtFromDate.Text = DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd");
            txtToDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            GenerateOccupancyReport();
        }
    }

        protected void btnGenerate_Click(object sender, EventArgs e)
        {
            GenerateOccupancyReport();
        }

        // ????????????????????????????????????????
        //  MAIN REPORT
        // ????????????????????????????????????????
        private void GenerateOccupancyReport()
    {
        try
        {
            DateTime fromDate = DateTime.Parse(txtFromDate.Text);
            DateTime toDate = DateTime.Parse(txtToDate.Text);

            if (toDate < fromDate) { ShowMessage("To Date must be after From Date.", false); return; }

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();

                // FIX: Use 'Available' not 'Active' â€” match RoomDefinitionNew actual values
                int totalRooms = GetTotalRooms(con);
                lblTotalRooms.Text = totalRooms.ToString();

                DataTable dt = BuildDailyTable(con, fromDate, toDate, totalRooms);

                if (dt.Rows.Count > 0)
                {
                    gvOccupancy.DataSource = dt;
                    gvOccupancy.DataBind();
                    lblRecordCount.Text = dt.Rows.Count.ToString();
                    CalculateSummary(dt, totalRooms);
                    EmitChartScript(dt);
                    PopulateWeeklySummary(dt, totalRooms);
                    PopulateMonthlySummary(dt, totalRooms);
                    chartContainer.Visible = true;
                }
                else
                {
                    gvOccupancy.DataSource = null;
                    gvOccupancy.DataBind();
                    lblRecordCount.Text = "0";
                    chartContainer.Visible = false;
                    ShowMessage("No data found for selected period.", false);
                }
            }
        }
        catch (Exception ex) { ShowMessage("Error: " + ex.Message, false); }
    }

    // ????????????????????????????????????????
    //  GET TOTAL ROOMS (Available + Occupied â€” NOT 'Active')
    // ????????????????????????????????????????
    private int GetTotalRooms(SqlConnection con)
    {
        // CAPACITY LOGIC: Include all rooms EXCEPT those in Maintenance. 
        // 'DIRTY' rooms are still part of the available capacity for occupancy % purposes.
        SqlCommand cmd = new SqlCommand(
            @"SELECT COUNT(*) FROM RoomDefinitionNew 
              WHERE UPPER(LTRIM(RTRIM(Status))) != 'MAINTENANCE'", con);
        int count = Convert.ToInt32(cmd.ExecuteScalar());
        if (count == 0)
        {
            cmd = new SqlCommand("SELECT COUNT(*) FROM RoomDefinitionNew", con);
            count = Convert.ToInt32(cmd.ExecuteScalar());
        }
        return count;
    }

    private DataTable BuildDailyTable(SqlConnection con, DateTime fromDate, DateTime toDate, int totalRooms)
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("OccupancyDate", typeof(DateTime));
        dt.Columns.Add("AvailedRooms", typeof(int));
        dt.Columns.Add("ConfirmedRooms", typeof(int));
        dt.Columns.Add("PendingRooms", typeof(int));
        dt.Columns.Add("DirtyRooms", typeof(int)); // Added Metric
        dt.Columns.Add("TotalBookedRooms", typeof(int));
        dt.Columns.Add("TotalRooms", typeof(int));
        dt.Columns.Add("OccupancyPercentage", typeof(decimal));
        dt.Columns.Add("TotalRevenue", typeof(decimal));

        // OPTIMIZED: One single query for the entire date range using a recursive CTE
        string sql = @"
            DECLARE @F Date = @FromDt;
            DECLARE @T Date = @ToDt;

            WITH Calendar AS (
                SELECT @F AS DateVal
                UNION ALL
                SELECT DATEADD(DAY, 1, DateVal)
                FROM Calendar
                WHERE DateVal < @T
            ),
            DailyStats AS (
                SELECT 
                    c.DateVal,
                    -- 1. AVAILED: Actual physical check-ins active on this night
                    (SELECT COUNT(*) FROM RoomAllocations ra 
                     WHERE c.DateVal >= CAST(ra.AllocatedDate AS DATE) 
                     AND (ra.CheckOutDate IS NULL OR c.DateVal < CAST(ra.CheckOutDate AS DATE))
                    ) AS Availed,
                    
                    -- 2. CONFIRMED: Reservations booked for this night but not yet checked in
                    (SELECT ISNULL(SUM(NoOfRooms), 0) FROM RoomReservations rr 
                     WHERE c.DateVal >= rr.FromDate AND c.DateVal < rr.ToDate 
                     AND UPPER(LTRIM(RTRIM(rr.Status))) = 'CONFIRMED'
                    ) AS Confirmed,
                    
                    -- 3. PENDING: Requests for this night
                    (SELECT ISNULL(SUM(NoOfRooms), 0) FROM RoomReservations rr 
                     WHERE c.DateVal >= rr.FromDate AND c.DateVal < rr.ToDate 
                     AND UPPER(LTRIM(RTRIM(rr.Status))) = 'PENDING'
                    ) AS Pending,
                    
                    -- 4. REVENUE: Sum of rent for rooms physically occupied on this night
                    (SELECT ISNULL(SUM(rd.Rent), 0) 
                     FROM RoomAllocations ra 
                     INNER JOIN RoomDefinitionNew rd ON ra.RoomNo = rd.RoomNo
                     WHERE c.DateVal >= CAST(ra.AllocatedDate AS DATE) 
                     AND (ra.CheckOutDate IS NULL OR c.DateVal < CAST(ra.CheckOutDate AS DATE))
                    ) AS Revenue,
                    
                    -- 5. DIRTY: Physical room state snapshot
                    (SELECT COUNT(*) FROM RoomDefinitionNew 
                     WHERE UPPER(Status) IN ('DIRTY', 'PENDING CLEANING')
                    ) AS DirtyCount
                FROM Calendar c
            )
            SELECT * FROM DailyStats
            ORDER BY DateVal
            OPTION (MAXRECURSION 366)";

        using (SqlCommand cmd = new SqlCommand(sql, con))
        {
            cmd.Parameters.AddWithValue("@FromDt", fromDate);
            cmd.Parameters.AddWithValue("@ToDt", toDate);
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                DataTable result = new DataTable();
                da.Fill(result);

                foreach (DataRow dr in result.Rows)
                {
                    int availed = Convert.ToInt32(dr["Availed"]);
                    int confirmed = Convert.ToInt32(dr["Confirmed"]);
                    int pending = Convert.ToInt32(dr["Pending"]);
                    int dirty = Convert.ToInt32(dr["DirtyCount"]);
                    decimal rev = Convert.ToDecimal(dr["Revenue"]);
                    
                    int totalBooked = availed + confirmed + pending;
                    decimal pct = totalRooms > 0 ? Math.Round((decimal)availed / totalRooms * 100, 1) : 0;

                    DataRow row = dt.NewRow();
                    row["OccupancyDate"] = dr["DateVal"];
                    row["AvailedRooms"] = availed;
                    row["ConfirmedRooms"] = confirmed;
                    row["PendingRooms"] = pending;
                    row["DirtyRooms"] = dirty;
                    row["TotalBookedRooms"] = totalBooked;
                    row["TotalRooms"] = totalRooms;
                    row["OccupancyPercentage"] = pct;
                    row["TotalRevenue"] = rev;
                    dt.Rows.Add(row);
                }
            }
        }
        return dt;
    }

    // ????????????????????????????????????????
    //  SUMMARY CARDS
    // ????????????????????????????????????????
    private void CalculateSummary(DataTable dt, int totalRooms)
    {
        int sumAvailed = 0;
        decimal sumRevenue = 0;
        int days = dt.Rows.Count;

        foreach (DataRow row in dt.Rows)
        {
            sumAvailed += Convert.ToInt32(row["AvailedRooms"]);
            sumRevenue += Convert.ToDecimal(row["TotalRevenue"]);
        }

        double avgAvailed = days > 0 ? (double)sumAvailed / days : 0;
        double pct = totalRooms > 0 ? Math.Round((avgAvailed / totalRooms) * 100, 1) : 0;
        double avgAvail = Math.Max(0, totalRooms - avgAvailed);

        lblOccupiedRooms.Text = avgAvailed.ToString();
        lblOccupancyPercent.Text = pct + "%";
        lblAvailableRooms.Text = avgAvail.ToString();
        lblTotalRevenue.Text = sumRevenue.ToString("N0");
    }

    // ????????????????????????????????????????
    //  EMIT CHART SCRIPT
    // ????????????????????????????????????????
    // ????????????????????????????????????????
    //  WEEKLY SUMMARY
    // ????????????????????????????????????????
    private void PopulateWeeklySummary(DataTable dt, int totalRooms)
    {
        DataTable weeklyDt = new DataTable();
        weeklyDt.Columns.Add("WeekNo", typeof(int));
        weeklyDt.Columns.Add("WeekStart", typeof(DateTime));
        weeklyDt.Columns.Add("WeekEnd", typeof(DateTime));
        weeklyDt.Columns.Add("TotalRooms", typeof(int));
        weeklyDt.Columns.Add("AvgOccupancy", typeof(decimal));
        weeklyDt.Columns.Add("Revenue", typeof(decimal));

        var ci = System.Globalization.CultureInfo.CurrentCulture;
        var weeks = new System.Collections.Generic.Dictionary<int, DataRow>();

        foreach (DataRow row in dt.Rows)
        {
            DateTime date = Convert.ToDateTime(row["OccupancyDate"]);
            int weekNum = ci.Calendar.GetWeekOfYear(date, ci.DateTimeFormat.CalendarWeekRule, ci.DateTimeFormat.FirstDayOfWeek);

            if (!weeks.ContainsKey(weekNum))
            {
                DataRow wRow = weeklyDt.NewRow();
                wRow["WeekNo"] = weekNum;
                wRow["WeekStart"] = date;
                wRow["WeekEnd"] = date;
                wRow["TotalRooms"] = 0;
                wRow["AvgOccupancy"] = 0m;
                wRow["Revenue"] = 0m;
                weeks[weekNum] = wRow;
                weeklyDt.Rows.Add(wRow);
            }

            DataRow weekRow = weeks[weekNum];
            weekRow["WeekEnd"] = date; // Last date in this week group
            weekRow["TotalRooms"] = Convert.ToInt32(weekRow["TotalRooms"]) + Convert.ToInt32(row["AvailedRooms"]);
            weekRow["Revenue"] = Convert.ToDecimal(weekRow["Revenue"]) + Convert.ToDecimal(row["TotalRevenue"]);
        }

        // Calculate averages
        foreach (DataRow wRow in weeklyDt.Rows)
        {
            DateTime start = Convert.ToDateTime(wRow["WeekStart"]);
            DateTime end = Convert.ToDateTime(wRow["WeekEnd"]);
            int dayCount = (end - start).Days + 1;
            if (dayCount > 0 && totalRooms > 0)
            {
                decimal totalAvailed = Convert.ToDecimal(wRow["TotalRooms"]);
                wRow["AvgOccupancy"] = Math.Round((totalAvailed / dayCount / (decimal)totalRooms) * 100, 1);
            }
        }

        gvWeekly.DataSource = weeklyDt;
        gvWeekly.DataBind();
    }

    // ????????????????????????????????????????
    //  MONTHLY SUMMARY
    // ????????????????????????????????????????
    private void PopulateMonthlySummary(DataTable dt, int totalRooms)
    {
        DataTable monthlyDt = new DataTable();
        monthlyDt.Columns.Add("Month", typeof(string));
        monthlyDt.Columns.Add("Year", typeof(int));
        monthlyDt.Columns.Add("Rooms", typeof(int));
        monthlyDt.Columns.Add("AvgPct", typeof(decimal));
        monthlyDt.Columns.Add("Revenue", typeof(decimal));

        var months = new System.Collections.Generic.Dictionary<string, DataRow>();

        foreach (DataRow row in dt.Rows)
        {
            DateTime date = Convert.ToDateTime(row["OccupancyDate"]);
            string monthKey = date.ToString("MMM-yyyy");

            if (!months.ContainsKey(monthKey))
            {
                DataRow mRow = monthlyDt.NewRow();
                mRow["Month"] = date.ToString("MMMM");
                mRow["Year"] = date.Year;
                mRow["Rooms"] = 0;
                mRow["AvgPct"] = 0m;
                mRow["Revenue"] = 0m;
                months[monthKey] = mRow;
                monthlyDt.Rows.Add(mRow);
            }

            DataRow monthRow = months[monthKey];
            monthRow["Rooms"] = Convert.ToInt32(monthRow["Rooms"]) + Convert.ToInt32(row["AvailedRooms"]);
            monthRow["Revenue"] = Convert.ToDecimal(monthRow["Revenue"]) + Convert.ToDecimal(row["TotalRevenue"]);
        }

        // Calculate averages
        foreach (DataRow mRow in monthlyDt.Rows)
        {
            int year = Convert.ToInt32(mRow["Year"]);
            string monthName = mRow["Month"].ToString();
            int monthNum = DateTime.ParseExact(monthName, "MMMM", System.Globalization.CultureInfo.CurrentCulture).Month;
            
            // Count days in this month that were in the data set
            int dayCount = 0;
            foreach (DataRow dr in dt.Rows)
            {
                DateTime d = Convert.ToDateTime(dr["OccupancyDate"]);
                if (d.Year == year && d.Month == monthNum) dayCount++;
            }

            if (dayCount > 0 && totalRooms > 0)
            {
                decimal totalAvailed = Convert.ToDecimal(mRow["Rooms"]);
                mRow["AvgPct"] = Math.Round((totalAvailed / dayCount / (decimal)totalRooms) * 100, 1);
            }
        }

        gvMonthly.DataSource = monthlyDt;
        gvMonthly.DataBind();
    }

    private void EmitChartScript(DataTable dt)
    {
        try
        {
            var sb = new StringBuilder();
            sb.Append("drawBars([");
            int max = Math.Min(dt.Rows.Count, 20);
            for (int i = 0; i < max; i++)
            {
                if (i > 0) sb.Append(",");
                string d = Convert.ToDateTime(dt.Rows[i]["OccupancyDate"]).ToString("dd/MM");
                decimal pct = Convert.ToDecimal(dt.Rows[i]["OccupancyPercentage"]);
                sb.Append("{dt:'" + d + "',p:" + Math.Round(pct, 0) + "}");
            }
            sb.Append("]);");
            ClientScript.RegisterStartupScript(GetType(), "chart", sb.ToString(), true);
        }
        catch { }
    }

    // ????????????????????????????????????????
    //  PAGING
    // ????????????????????????????????????????
    protected void gvOccupancy_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvOccupancy.PageIndex = e.NewPageIndex;
        GenerateOccupancyReport();
    }

    // ????????????????????????????????????????
    //  EXPORT EXCEL
    // ????????????????????????????????????????
    protected void btnExportExcel_Click(object sender, EventArgs e)
    {
        try
        {
            DateTime from = DateTime.Parse(txtFromDate.Text);
            DateTime to = DateTime.Parse(txtToDate.Text);

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                int totalRooms = GetTotalRooms(con);
                DataTable dt = BuildDailyTable(con, from, to, totalRooms);

                if (dt.Rows.Count == 0) { ShowMessage("No data to export.", false); return; }

                Response.Clear();
                Response.Buffer = true;
                Response.ContentType = "application/vnd.ms-excel";
                Response.AddHeader("Content-Disposition", "attachment;filename=OccupancyReport.xls");
                Response.Charset = "";

                var sb = new StringBuilder();
                sb.Append("<table border='1'><tr><th>Date</th><th>Occupied</th><th>Confirmed</th><th>Pending</th><th>Dirty</th><th>Total Booked</th><th>Total Rooms</th><th>Occupancy%</th><th>Revenue PKR</th></tr>");
                foreach (DataRow row in dt.Rows)
                {
                    sb.Append("<tr>");
                    sb.Append("<td>" + Convert.ToDateTime(row[0]).ToString("dd-MMM-yyyy") + "</td>");
                    sb.Append("<td>" + row[1] + "</td><td>" + row[2] + "</td><td>" + row[3] + "</td><td>" + row[4] + "</td>");
                    sb.Append("<td>" + row[5] + "</td><td>" + row[6] + "</td>");
                    sb.Append("<td>" + row[7] + "%</td>");
                    sb.Append("<td>" + Convert.ToDecimal(row[8]).ToString("N0") + "</td>");
                    sb.Append("</tr>");
                }
                sb.Append("</table>");
                Response.Write(sb.ToString());
                Response.End();
            }
        }
        catch (Exception ex) { ShowMessage("Export error: " + ex.Message, false); }
    }

    // ????????????????????????????????????????
    //  PERCENT CSS CLASS
    // ????????????????????????????????????????
    protected string GetPercentClass(object pct)
    {
        decimal p = Convert.ToDecimal(pct);
        if (p >= 80) return "high-occupancy";
        if (p >= 50) return "medium-occupancy";
        return "low-occupancy";
    }

    protected string GetOccupancyBarStyle(object pct)
    {
        decimal p = Convert.ToDecimal(pct);
        string color = "#10b981"; // Green
        if (p >= 90) color = "#ef4444"; // Red
        else if (p >= 70) color = "#f59e0b"; // Orange
        
        decimal width = Math.Min(p, 100);
        return string.Format("width: {0}%; background: {1}; height: 100%; border-radius: 4px; transition: width 0.6s cubic-bezier(0.4, 0, 0.2, 1);", width, color);
    }

    protected string GetOccupancyTextStyle(object pct)
    {
        decimal p = Convert.ToDecimal(pct);
        string color = "#10b981";
        if (p >= 90) color = "#ef4444";
        else if (p >= 70) color = "#f59e0b";
        return string.Format("font-size: 0.75rem; font-weight: 800; color: {0}; margin-top: 4px;", color);
    }

    protected string GetOverbookingIcon(object pct)
    {
        decimal p = Convert.ToDecimal(pct);
        if (p > 100) return "<i class='fas fa-exclamation-triangle' style='color:#ef4444; margin-left:4px;' title='Overbooked'></i>";
        return "";
    }

    protected string GetWeeklyOccupancyStyle(object pct)
    {
        decimal p = Convert.ToDecimal(pct);
        string bg = "#ecfdf5", fg = "#10b981";
        if (p >= 90) { bg = "#fef2f2"; fg = "#ef4444"; }
        else if (p >= 70) { bg = "#fffbe6"; fg = "#f59e0b"; }
        return string.Format("padding: 4px 12px; border-radius: 20px; background: {0}; color: {1}; font-weight: 700; font-size: 0.8rem;", bg, fg);
    }

    private void ShowMessage(string msg, bool success)
    {
        lblMessage.Visible = true;
        lblMessage.Text = msg;
        string bg = success ? "#ecfdf5" : "#fef2f2";
        string border = success ? "#10b981" : "#ef4444";
        string text = success ? "#065f46" : "#991b1b";
        lblMessage.Style["background-color"] = bg;
        lblMessage.Style["border-left-color"] = border;
        lblMessage.Style["color"] = text;
    }
}

}




