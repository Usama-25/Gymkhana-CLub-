using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;

namespace GuestRoomApp.GuestRoomM
{
    public partial class ReservationForecast : System.Web.UI.Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtStartDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                txtEndDate.Text = DateTime.Now.AddDays(30).ToString("yyyy-MM-dd");
                GenerateForecast();
            }
        }

        protected void btnGenerate_Click(object sender, EventArgs e)
        {
            GenerateForecast();
        }

        private void GenerateForecast()
        {
            try
            {
                if (string.IsNullOrEmpty(txtStartDate.Text) || string.IsNullOrEmpty(txtEndDate.Text))
                {
                    ShowMessage("Please select both start and end dates.", false);
                    return;
                }

                DateTime startDate = DateTime.Parse(txtStartDate.Text);
                DateTime endDate = DateTime.Parse(txtEndDate.Text);
                
                if (endDate < startDate) 
                { 
                    ShowMessage("End Date must be greater than Start Date", false); 
                    return; 
                }

                GenerateDailyForecast(startDate, endDate);
                GenerateWeeklyForecast(startDate, endDate);
                GenerateMonthlyForecast(startDate, endDate);
                UpdateSummaryCards(startDate, endDate);
                
                lblMessage.Visible = false;
            }
            catch (Exception ex) 
            { 
                ShowMessage("Analysis Error: " + ex.Message, false); 
            }
        }

        private void GenerateDailyForecast(DateTime startDate, DateTime endDate)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("ForecastDate", typeof(DateTime));
            dt.Columns.Add("TotalReservations", typeof(int));
            dt.Columns.Add("RoomsBooked", typeof(int));
            dt.Columns.Add("PendingRooms", typeof(int));
            dt.Columns.Add("ConfirmedRooms", typeof(int));
            dt.Columns.Add("OccupiedRooms", typeof(int));
            dt.Columns.Add("OccupancyPercentage", typeof(decimal));
            dt.Columns.Add("ExpectedRevenue", typeof(decimal));

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                
                // Get Total Capacity (Excluding maintenance)
                int totalRooms = GetCapacity(con);

                string sql = @"
                    DECLARE @S Date = @FromDt;
                    DECLARE @E Date = @ToDt;

                    WITH Calendar AS (
                        SELECT @S AS DateVal
                        UNION ALL
                        SELECT DATEADD(DAY, 1, DateVal)
                        FROM Calendar
                        WHERE DateVal < @E
                    )
                    SELECT 
                        c.DateVal,
                        COUNT(DISTINCT CASE WHEN rr.FromDate = c.DateVal THEN rr.ReservationNo ELSE NULL END) AS TotalReservations,
                        ISNULL(SUM(rr.NoOfRooms), 0) AS RoomsBooked,
                        ISNULL(SUM(CASE WHEN UPPER(rr.Status) = 'PENDING' THEN rr.NoOfRooms ELSE 0 END), 0) AS PendingRooms,
                        ISNULL(SUM(CASE WHEN UPPER(rr.Status) = 'CONFIRMED' THEN rr.NoOfRooms ELSE 0 END), 0) AS ConfirmedRooms,
                        ISNULL(SUM(CASE WHEN UPPER(rr.Status) IN ('AVAILED', 'OCCUPIED', 'COMPLETED') THEN rr.NoOfRooms ELSE 0 END), 0) AS OccupiedRooms,
                        ISNULL(SUM(RentCalc.CalculatedDailyRent), 0) AS ProjectedRevenue
                    FROM Calendar c
                    LEFT JOIN RoomReservations rr ON c.DateVal >= rr.FromDate AND c.DateVal < rr.ToDate
                         AND UPPER(rr.Status) NOT IN ('CANCELLED', 'NOSHOW', 'VOID', 'CANCELED')
                    OUTER APPLY (
                        SELECT COALESCE(
                            (SELECT SUM(rd.Rent) FROM RoomAllocations ra 
                             INNER JOIN RoomDefinitionNew rd ON ra.RoomNo = rd.RoomNo 
                             WHERE ra.ReservationNo = rr.ReservationNo),
                            (SELECT ISNULL(AVG(Rent), 5000) FROM RoomDefinitionNew) * rr.NoOfRooms
                        ) AS CalculatedDailyRent
                    ) AS RentCalc
                    GROUP BY c.DateVal
                    ORDER BY c.DateVal
                    OPTION (MAXRECURSION 1000)";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@FromDt", startDate);
                    cmd.Parameters.AddWithValue("@ToDt", endDate);
                    
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable result = new DataTable();
                        da.Fill(result);
                        
                        foreach (DataRow dr in result.Rows)
                        {
                            int booked = Convert.ToInt32(dr["RoomsBooked"]);
                            decimal percentage = totalRooms > 0 ? Math.Round((decimal)booked / totalRooms * 100, 1) : 0;

                            DataRow row = dt.NewRow();
                            row["ForecastDate"] = dr["DateVal"];
                            row["TotalReservations"] = dr["TotalReservations"];
                            row["RoomsBooked"] = dr["RoomsBooked"];
                            row["PendingRooms"] = dr["PendingRooms"];
                            row["ConfirmedRooms"] = dr["ConfirmedRooms"];
                            row["OccupiedRooms"] = dr["OccupiedRooms"];
                            row["OccupancyPercentage"] = percentage;
                            row["ExpectedRevenue"] = dr["ProjectedRevenue"];
                            dt.Rows.Add(row);
                        }
                    }
                }
            }
            gvDaily.DataSource = dt;
            gvDaily.DataBind();
        }

        private void GenerateWeeklyForecast(DateTime startDate, DateTime endDate)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("WeekStart", typeof(DateTime));
            dt.Columns.Add("WeekEnd", typeof(DateTime));
            dt.Columns.Add("WeekNo", typeof(int));
            dt.Columns.Add("TotalReservations", typeof(int));
            dt.Columns.Add("TotalRoomsBooked", typeof(int));
            dt.Columns.Add("AvgOccupancyPercentage", typeof(decimal));
            dt.Columns.Add("ExpectedRevenue", typeof(decimal));

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                int totalRooms = GetCapacity(con);

                DateTime current = startDate;
                while (current <= endDate)
                {
                    DateTime weekStart = current;
                    DateTime weekEnd = current.AddDays(6);
                    if (weekEnd > endDate) weekEnd = endDate;
                    int daysInPeriod = (weekEnd - weekStart).Days + 1;

                    // Calculate accurate room-nights within this week
                    using (SqlCommand cmd = new SqlCommand(@"
                        SELECT 
                            COUNT(DISTINCT CASE WHEN rr.FromDate >= @WStart AND rr.FromDate <= @WEnd THEN rr.ReservationNo ELSE NULL END) AS UniqueReservations,
                            SUM(rr.NoOfRooms * 
                                CASE 
                                    WHEN DATEDIFF(day, CASE WHEN rr.FromDate < @WStart THEN @WStart ELSE rr.FromDate END, 
                                                       CASE WHEN rr.ToDate > DATEADD(day, 1, @WEnd) THEN DATEADD(day, 1, @WEnd) ELSE rr.ToDate END) > 0 
                                    THEN DATEDIFF(day, CASE WHEN rr.FromDate < @WStart THEN @WStart ELSE rr.FromDate END, 
                                                       CASE WHEN rr.ToDate > DATEADD(day, 1, @WEnd) THEN DATEADD(day, 1, @WEnd) ELSE rr.ToDate END)
                                    ELSE 0 
                                END) AS PeriodRoomNights,
                            SUM(RentCalc.DailyRent * 
                                CASE 
                                    WHEN DATEDIFF(day, CASE WHEN rr.FromDate < @WStart THEN @WStart ELSE rr.FromDate END, 
                                                       CASE WHEN rr.ToDate > DATEADD(day, 1, @WEnd) THEN DATEADD(day, 1, @WEnd) ELSE rr.ToDate END) > 0 
                                    THEN DATEDIFF(day, CASE WHEN rr.FromDate < @WStart THEN @WStart ELSE rr.FromDate END, 
                                                       CASE WHEN rr.ToDate > DATEADD(day, 1, @WEnd) THEN DATEADD(day, 1, @WEnd) ELSE rr.ToDate END)
                                    ELSE 0 
                                END) AS PeriodRevenue
                        FROM RoomReservations rr
                        OUTER APPLY (
                            SELECT COALESCE(
                                (SELECT SUM(rd.Rent) FROM RoomAllocations ra INNER JOIN RoomDefinitionNew rd ON ra.RoomNo = rd.RoomNo WHERE ra.ReservationNo = rr.ReservationNo),
                                (SELECT ISNULL(AVG(Rent), 5000) FROM RoomDefinitionNew) * rr.NoOfRooms
                            ) AS DailyRent
                        ) AS RentCalc
                        WHERE (rr.FromDate < DATEADD(day, 1, @WEnd) AND rr.ToDate > @WStart)
                          AND UPPER(rr.Status) NOT IN ('CANCELLED', 'NOSHOW', 'VOID', 'CANCELED')", con))
                    {
                        cmd.Parameters.AddWithValue("@WStart", weekStart);
                        cmd.Parameters.AddWithValue("@WEnd", weekEnd);
                        
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                int roomNights = dr["PeriodRoomNights"] != DBNull.Value ? Convert.ToInt32(dr["PeriodRoomNights"]) : 0;
                                decimal revenue = dr["PeriodRevenue"] != DBNull.Value ? Convert.ToDecimal(dr["PeriodRevenue"]) : 0;
                                decimal avgPercentage = totalRooms > 0 ? Math.Round((decimal)roomNights / daysInPeriod / totalRooms * 100, 1) : 0;
                                
                                DataRow row = dt.NewRow();
                                row["WeekStart"] = weekStart;
                                row["WeekEnd"] = weekEnd;
                                row["WeekNo"] = GetWeekNumber(weekStart);
                                row["TotalReservations"] = dr["UniqueReservations"] != DBNull.Value ? Convert.ToInt32(dr["UniqueReservations"]) : 0;
                                row["TotalRoomsBooked"] = roomNights;
                                row["AvgOccupancyPercentage"] = avgPercentage;
                                row["ExpectedRevenue"] = revenue;
                                dt.Rows.Add(row);
                            }
                        }
                    }
                    current = current.AddDays(7);
                }
            }
            gvWeekly.DataSource = dt;
            gvWeekly.DataBind();
        }

        private void GenerateMonthlyForecast(DateTime startDate, DateTime endDate)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("MonthName", typeof(string));
            dt.Columns.Add("Year", typeof(int));
            dt.Columns.Add("MonthNo", typeof(int));
            dt.Columns.Add("TotalReservations", typeof(int));
            dt.Columns.Add("TotalRoomsBooked", typeof(int));
            dt.Columns.Add("AvgOccupancyPercentage", typeof(decimal));
            dt.Columns.Add("TotalAdvanceReceived", typeof(decimal));
            dt.Columns.Add("ExpectedRevenue", typeof(decimal));

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                int totalRooms = GetCapacity(con);

                // We need to iterate months to get accurate period boundaries
                DateTime current = new DateTime(startDate.Year, startDate.Month, 1);
                while (current <= endDate)
                {
                    DateTime monthStart = current;
                    DateTime monthEnd = current.AddMonths(1).AddDays(-1);
                    if (monthStart < startDate) monthStart = startDate;
                    if (monthEnd > endDate) monthEnd = endDate;
                    int daysInPeriod = (monthEnd - monthStart).Days + 1;

                    using (SqlCommand cmd = new SqlCommand(@"
                        SELECT 
                            COUNT(DISTINCT CASE WHEN rr.FromDate >= @MStart AND rr.FromDate <= @MEnd THEN rr.ReservationNo ELSE NULL END) AS UniqueReservations,
                            SUM(rr.NoOfRooms * 
                                CASE 
                                    WHEN DATEDIFF(day, CASE WHEN rr.FromDate < @MStart THEN @MStart ELSE rr.FromDate END, 
                                                       CASE WHEN rr.ToDate > DATEADD(day, 1, @MEnd) THEN DATEADD(day, 1, @MEnd) ELSE rr.ToDate END) > 0 
                                    THEN DATEDIFF(day, CASE WHEN rr.FromDate < @MStart THEN @MStart ELSE rr.FromDate END, 
                                                       CASE WHEN rr.ToDate > DATEADD(day, 1, @MEnd) THEN DATEADD(day, 1, @MEnd) ELSE rr.ToDate END)
                                    ELSE 0 
                                END) AS PeriodRoomNights,
                            SUM(RentCalc.DailyRent * 
                                CASE 
                                    WHEN DATEDIFF(day, CASE WHEN rr.FromDate < @MStart THEN @MStart ELSE rr.FromDate END, 
                                                       CASE WHEN rr.ToDate > DATEADD(day, 1, @MEnd) THEN DATEADD(day, 1, @MEnd) ELSE rr.ToDate END) > 0 
                                    THEN DATEDIFF(day, CASE WHEN rr.FromDate < @MStart THEN @MStart ELSE rr.FromDate END, 
                                                       CASE WHEN rr.ToDate > DATEADD(day, 1, @MEnd) THEN DATEADD(day, 1, @MEnd) ELSE rr.ToDate END)
                                    ELSE 0 
                                END) AS PeriodRevenue,
                            SUM(CASE WHEN rr.FromDate BETWEEN @MStart AND @MEnd THEN rr.AdvancePayment ELSE 0 END) AS PeriodAdvance
                        FROM RoomReservations rr
                        OUTER APPLY (
                            SELECT COALESCE(
                                (SELECT SUM(rd.Rent) FROM RoomAllocations ra INNER JOIN RoomDefinitionNew rd ON ra.RoomNo = rd.RoomNo WHERE ra.ReservationNo = rr.ReservationNo),
                                (SELECT ISNULL(AVG(Rent), 5000) FROM RoomDefinitionNew) * rr.NoOfRooms
                            ) AS DailyRent
                        ) AS RentCalc
                        WHERE (rr.FromDate < DATEADD(day, 1, @MEnd) AND rr.ToDate > @MStart)
                          AND UPPER(rr.Status) NOT IN ('CANCELLED', 'NOSHOW', 'VOID', 'CANCELED')", con))
                    {
                        cmd.Parameters.AddWithValue("@MStart", monthStart);
                        cmd.Parameters.AddWithValue("@MEnd", monthEnd);
                        
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                int roomNights = dr["PeriodRoomNights"] != DBNull.Value ? Convert.ToInt32(dr["PeriodRoomNights"]) : 0;
                                decimal revenue = dr["PeriodRevenue"] != DBNull.Value ? Convert.ToDecimal(dr["PeriodRevenue"]) : 0;
                                decimal avgPercentage = totalRooms > 0 ? Math.Round((decimal)roomNights / daysInPeriod / totalRooms * 100, 1) : 0;
                                
                                DataRow row = dt.NewRow();
                                row["MonthName"] = current.ToString("MMMM");
                                row["Year"] = current.Year;
                                row["MonthNo"] = current.Month;
                                row["TotalReservations"] = dr["UniqueReservations"] != DBNull.Value ? Convert.ToInt32(dr["UniqueReservations"]) : 0;
                                row["TotalRoomsBooked"] = roomNights;
                                row["AvgOccupancyPercentage"] = avgPercentage;
                                row["TotalAdvanceReceived"] = dr["PeriodAdvance"] != DBNull.Value ? Convert.ToDecimal(dr["PeriodAdvance"]) : 0;
                                row["ExpectedRevenue"] = revenue;
                                dt.Rows.Add(row);
                            }
                        }
                    }
                    current = current.AddMonths(1);
                }
            }
            gvMonthly.DataSource = dt;
            gvMonthly.DataBind();
        }

        private void UpdateSummaryCards(DateTime startDate, DateTime endDate)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                int totalRoomsCount = GetCapacity(con);
                int days = (endDate - startDate).Days + 1;

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT 
                        COUNT(DISTINCT CASE WHEN rr.FromDate >= @Start AND rr.FromDate <= @End THEN rr.ReservationNo ELSE NULL END) AS UniqueReservations,
                        SUM(rr.NoOfRooms * 
                            CASE 
                                WHEN DATEDIFF(day, CASE WHEN rr.FromDate < @Start THEN @Start ELSE rr.FromDate END, 
                                                   CASE WHEN rr.ToDate > DATEADD(day, 1, @End) THEN DATEADD(day, 1, @End) ELSE rr.ToDate END) > 0 
                                THEN DATEDIFF(day, CASE WHEN rr.FromDate < @Start THEN @Start ELSE rr.FromDate END, 
                                                   CASE WHEN rr.ToDate > DATEADD(day, 1, @End) THEN DATEADD(day, 1, @End) ELSE rr.ToDate END)
                                ELSE 0 
                            END) AS TotalRoomNights,
                        SUM(RentCalc.DailyRent * 
                            CASE 
                                WHEN DATEDIFF(day, CASE WHEN rr.FromDate < @Start THEN @Start ELSE rr.FromDate END, 
                                                   CASE WHEN rr.ToDate > DATEADD(day, 1, @End) THEN DATEADD(day, 1, @End) ELSE rr.ToDate END) > 0 
                                THEN DATEDIFF(day, CASE WHEN rr.FromDate < @Start THEN @Start ELSE rr.FromDate END, 
                                                   CASE WHEN rr.ToDate > DATEADD(day, 1, @End) THEN DATEADD(day, 1, @End) ELSE rr.ToDate END)
                                ELSE 0 
                            END) AS TotalRevenue
                    FROM RoomReservations rr
                    OUTER APPLY (
                        SELECT COALESCE(
                            (SELECT SUM(rd.Rent) FROM RoomAllocations ra INNER JOIN RoomDefinitionNew rd ON ra.RoomNo = rd.RoomNo WHERE ra.ReservationNo = rr.ReservationNo),
                            (SELECT ISNULL(AVG(Rent), 5000) FROM RoomDefinitionNew) * rr.NoOfRooms
                        ) AS DailyRent
                    ) AS RentCalc
                    WHERE (rr.FromDate < DATEADD(day, 1, @End) AND rr.ToDate > @Start)
                      AND UPPER(rr.Status) NOT IN ('CANCELLED', 'NOSHOW', 'VOID', 'CANCELED')", con))
                {
                    cmd.Parameters.AddWithValue("@Start", startDate);
                    cmd.Parameters.AddWithValue("@End", endDate);
                    
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            int totalRes = dr["UniqueReservations"] != DBNull.Value ? Convert.ToInt32(dr["UniqueReservations"]) : 0;
                            int totalRoomNightsCount = dr["TotalRoomNights"] != DBNull.Value ? Convert.ToInt32(dr["TotalRoomNights"]) : 0;
                            decimal totalRev = dr["TotalRevenue"] != DBNull.Value ? Convert.ToDecimal(dr["TotalRevenue"]) : 0;
                            
                            decimal avgDaily = days > 0 ? (decimal)totalRoomNightsCount / days : 0;
                            
                            lblTotalReservations.Text = totalRes.ToString("N0");
                            lblTotalRoomsBooked.Text = totalRoomNightsCount.ToString("N0");
                            lblTotalRevenue.Text = totalRev.ToString("N0");
                            lblAvgDailyOccupancy.Text = avgDaily.ToString("F1");
                            
                            double percent = totalRoomsCount > 0 ? (double)avgDaily / totalRoomsCount * 100 : 0;
                            lblAvgPercent.Text = percent.ToString("F1") + "%";
                        }
                    }
                }
            }
        }

        private int GetCapacity(SqlConnection con)
        {
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM RoomDefinitionNew WHERE UPPER(LTRIM(RTRIM(Status))) != 'MAINTENANCE'", con))
            {
                int count = Convert.ToInt32(cmd.ExecuteScalar());
                return count > 0 ? count : 50; 
            }
        }

        private int GetWeekNumber(DateTime date)
        {
            System.Globalization.CultureInfo ci = System.Globalization.CultureInfo.CurrentCulture;
            return ci.Calendar.GetWeekOfYear(date, System.Globalization.CalendarWeekRule.FirstFourDayWeek, DayOfWeek.Monday);
        }

        protected void gvDaily_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvDaily.PageIndex = e.NewPageIndex;
            GenerateForecast();
        }

        protected void gvWeekly_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvWeekly.PageIndex = e.NewPageIndex;
            GenerateForecast();
        }

        protected void gvMonthly_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvMonthly.PageIndex = e.NewPageIndex;
            GenerateForecast();
        }

        protected void gvDaily_SelectedIndexChanged(object sender, EventArgs e)
        {
            DateTime selectedDate = (DateTime)gvDaily.SelectedValue;
            ShowReservationDetails(selectedDate, selectedDate, "Daily Breakdown for " + selectedDate.ToString("dd-MMM-yyyy"));
        }

        protected void gvWeekly_SelectedIndexChanged(object sender, EventArgs e)
        {
            DateTime weekStart = (DateTime)gvWeekly.SelectedValue;
            DateTime weekEnd = weekStart.AddDays(6);
            ShowReservationDetails(weekStart, weekEnd, "Weekly Summary: " + weekStart.ToString("dd MMM") + " to " + weekEnd.ToString("dd MMM yyyy"));
        }

        protected void gvMonthly_SelectedIndexChanged(object sender, EventArgs e)
        {
            int year = (int)gvMonthly.DataKeys[gvMonthly.SelectedIndex].Values["Year"];
            int month = (int)gvMonthly.DataKeys[gvMonthly.SelectedIndex].Values["MonthNo"];
            DateTime monthStart = new DateTime(year, month, 1);
            DateTime monthEnd = monthStart.AddMonths(1).AddDays(-1);
            ShowReservationDetails(monthStart, monthEnd, "Monthly Analysis: " + monthStart.ToString("MMMM yyyy"));
        }

        private void ShowReservationDetails(DateTime fromDate, DateTime toDate, string title)
        {
            StringBuilder html = new StringBuilder();
            html.Append("<div style='margin-bottom: 20px; border-bottom: 2px solid #C9A84C; padding-bottom: 10px;'>");
            html.Append("<h5 style='margin:0; color:#1A1A2E; font-weight:700;'>" + title + "</h5>");
            html.Append("</div>");
            
            html.Append("<table style='width:100%; border-collapse:collapse; font-size:0.85rem;'>");
            html.Append("<tr style='background:#f1f5f9; text-align:left;'>");
            html.Append("<th style='padding:10px; border-bottom:1px solid #e2e8f0;'>Res #</th>");
            html.Append("<th style='padding:10px; border-bottom:1px solid #e2e8f0;'>Guest Name</th>");
            html.Append("<th style='padding:10px; border-bottom:1px solid #e2e8f0;'>Rooms</th>");
            html.Append("<th style='padding:10px; border-bottom:1px solid #e2e8f0;'>Dates</th>");
            html.Append("<th style='padding:10px; border-bottom:1px solid #e2e8f0;'>Status</th>");
            html.Append("</tr>");

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT ReservationNo, GuestName, FromDate, ToDate, NoOfRooms, Status
                    FROM RoomReservations 
                    WHERE (FromDate < DATEADD(day, 1, @ToDate) AND ToDate > @FromDate)
                      AND UPPER(Status) NOT IN ('CANCELLED', 'NOSHOW', 'VOID', 'CANCELED')
                    ORDER BY FromDate", con))
                {
                    cmd.Parameters.AddWithValue("@FromDate", fromDate);
                    cmd.Parameters.AddWithValue("@ToDate", toDate);
                    
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        int count = 0;
                        while (dr.Read())
                        {
                            count++;
                            string status = dr["Status"].ToString();
                            string statusStyle = "padding:2px 8px; border-radius:12px; font-size:0.7rem; font-weight:700; background:#f1f5f9; color:#475569;";
                            
                            if (status.ToUpper() == "CONFIRMED") statusStyle = "padding:2px 8px; border-radius:12px; font-size:0.7rem; font-weight:700; background:#dcfce7; color:#15803d;";
                            else if (status.ToUpper() == "OCCUPIED" || status.ToUpper() == "AVAILED" || status.ToUpper() == "COMPLETED") statusStyle = "padding:2px 8px; border-radius:12px; font-size:0.7rem; font-weight:700; background:#dbeafe; color:#1d4ed8;";

                            html.Append("<tr>");
                            html.Append("<td style='padding:10px; border-bottom:1px solid #f1f5f9;'>#" + dr["ReservationNo"] + "</td>");
                            html.Append("<td style='padding:10px; border-bottom:1px solid #f1f5f9;'><strong>" + dr["GuestName"] + "</strong></td>");
                            html.Append("<td style='padding:10px; border-bottom:1px solid #f1f5f9;'>" + dr["NoOfRooms"] + "</td>");
                            html.Append("<td style='padding:10px; border-bottom:1px solid #f1f5f9;'>" + Convert.ToDateTime(dr["FromDate"]).ToString("dd MMM") + " - " + Convert.ToDateTime(dr["ToDate"]).ToString("dd MMM") + "</td>");
                            html.Append("<td style='padding:10px; border-bottom:1px solid #f1f5f9;'><span style='" + statusStyle + "'>" + status + "</span></td>");
                            html.Append("</tr>");
                        }
                        if (count == 0)
                        {
                            html.Append("<tr><td colspan='5' style='padding:30px; text-align:center; color:#94a3b8;'>No reservations found for this period.</td></tr>");
                        }
                    }
                }
            }
            html.Append("</table>");

            string script = "showDetail(`" + html.ToString().Replace("`", "\\`") + "`);";
            ScriptManager.RegisterStartupScript(this, GetType(), "ShowDetail", script, true);
        }

        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            try
            {
                DateTime startDate = DateTime.Parse(txtStartDate.Text);
                DateTime endDate = DateTime.Parse(txtEndDate.Text);
                
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();
                    int totalRooms = GetCapacity(con);

                    string sql = @"
                        DECLARE @S Date = @From;
                        DECLARE @E Date = @To;
                        WITH Calendar AS (
                            SELECT @S AS DateVal UNION ALL SELECT DATEADD(DAY, 1, DateVal) FROM Calendar WHERE DateVal < @E
                        )
                        SELECT 
                            c.DateVal AS [Date],
                            COUNT(DISTINCT CASE WHEN rr.FromDate = c.DateVal THEN rr.ReservationNo ELSE NULL END) AS [Reservations],
                            ISNULL(SUM(rr.NoOfRooms), 0) AS [Rooms Booked],
                            ISNULL(SUM(CASE WHEN UPPER(rr.Status) = 'PENDING' THEN rr.NoOfRooms ELSE 0 END), 0) AS [Pending],
                            ISNULL(SUM(CASE WHEN UPPER(rr.Status) = 'CONFIRMED' THEN rr.NoOfRooms ELSE 0 END), 0) AS [Confirmed],
                            ISNULL(SUM(CASE WHEN UPPER(rr.Status) IN ('AVAILED', 'OCCUPIED', 'COMPLETED') THEN rr.NoOfRooms ELSE 0 END), 0) AS [Occupied],
                            ISNULL(SUM(RentCalc.DailyRent), 0) AS [Expected Revenue]
                        FROM Calendar c
                        LEFT JOIN RoomReservations rr ON c.DateVal >= rr.FromDate AND c.DateVal < rr.ToDate 
                             AND UPPER(rr.Status) NOT IN ('CANCELLED', 'NOSHOW', 'VOID', 'CANCELED')
                        OUTER APPLY (
                            SELECT COALESCE(
                                (SELECT SUM(rd.Rent) FROM RoomAllocations ra INNER JOIN RoomDefinitionNew rd ON ra.RoomNo = rd.RoomNo WHERE ra.ReservationNo = rr.ReservationNo),
                                (SELECT ISNULL(AVG(Rent), 5000) FROM RoomDefinitionNew) * rr.NoOfRooms
                            ) AS DailyRent
                        ) AS RentCalc
                        GROUP BY c.DateVal ORDER BY c.DateVal OPTION (MAXRECURSION 1000)";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@From", startDate);
                        cmd.Parameters.AddWithValue("@To", endDate);
                        
                        DataTable dt = new DataTable();
                        new SqlDataAdapter(cmd).Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            Response.Clear();
                            Response.Buffer = true;
                            Response.AddHeader("content-disposition", "attachment;filename=ReservationForecast_" + DateTime.Now.ToString("yyyyMMdd") + ".xls");
                            Response.Charset = "";
                            Response.ContentType = "application/vnd.ms-excel";
                            
                            StringBuilder sb = new StringBuilder();
                            sb.Append("<table border='1'>");
                            sb.Append("<tr style='background-color:#1A1A2E; color:#ffffff; font-weight:bold;'>");
                            foreach (DataColumn col in dt.Columns) sb.Append("<th>" + col.ColumnName + "</th>");
                            sb.Append("<th>Occupancy %</th></tr>");

                            foreach (DataRow row in dt.Rows)
                            {
                                sb.Append("<tr>");
                                sb.Append("<td>" + Convert.ToDateTime(row["Date"]).ToString("dd-MMM-yyyy") + "</td>");
                                sb.Append("<td>" + row["Reservations"] + "</td>");
                                sb.Append("<td>" + row["Rooms Booked"] + "</td>");
                                sb.Append("<td>" + row["Pending"] + "</td>");
                                sb.Append("<td>" + row["Confirmed"] + "</td>");
                                sb.Append("<td>" + row["Occupied"] + "</td>");
                                sb.Append("<td>" + Convert.ToDecimal(row["Expected Revenue"]).ToString("N0") + "</td>");
                                
                                decimal occ = totalRooms > 0 ? Math.Round(Convert.ToDecimal(row["Rooms Booked"]) / totalRooms * 100, 1) : 0;
                                sb.Append("<td>" + occ + "%</td>");
                                sb.Append("</tr>");
                            }
                            sb.Append("</table>");
                            Response.Write(sb.ToString());
                            Response.End();
                        }
                    }
                }
            }
            catch (Exception ex) { ShowMessage("Export error: " + ex.Message, false); }
        }

        private void ShowMessage(string msg, bool success)
        {
            lblMessage.Text = (success ? "âœ… " : "âŒ ") + msg;
            lblMessage.Visible = true;
            lblMessage.Style["background-color"] = success ? "#f0fdf4" : "#fef2f2";
            lblMessage.Style["color"] = success ? "#15803d" : "#b91c1c";
            lblMessage.Style["border-color"] = success ? "#10b981" : "#ef4444";
        }

        // --- HELPER METHODS FOR DYNAMIC STYLING ---

        protected string GetOccupancyBarStyle(object percentObj)
        {
            decimal percent = Convert.ToDecimal(percentObj);
            decimal width = Math.Min(100m, percent);
            string color = "#10b981"; // Green (Default)

            if (percent > 100) color = "#000000"; // Black (Overbooked)
            else if (percent > 80) color = "#ef4444"; // Red (High)
            else if (percent > 50) color = "#f59e0b"; // Orange (Medium)

            return string.Format("width: {0}%; background: {1}; height: 100%; border-radius: 4px;", width, color);
        }

        protected string GetOccupancyTextStyle(object percentObj)
        {
            decimal percent = Convert.ToDecimal(percentObj);
            string color = (percent > 100) ? "#ef4444" : "#444444";
            return string.Format("font-weight: 700; font-size: 0.75rem; margin-top: 2px; color: {0};", color);
        }

        protected string GetWeeklyOccupancyStyle(object percentObj)
        {
            decimal percent = Convert.ToDecimal(percentObj);
            string style = "padding: 4px 12px; border-radius: 20px; font-weight: 700; font-size: 0.8rem; ";

            if (percent > 100) style += "background:#1A1A2E; color:#ef4444;";
            else if (percent > 70) style += "background:#fef2f2; color:#b91c1c;";
            else style += "background:#f0fdf4; color:#15803d;";

            return style;
        }

        protected string GetOverbookingIcon(object percentObj)
        {
            decimal percent = Convert.ToDecimal(percentObj);
            if (percent > 100)
            {
                return "<i class='fas fa-exclamation-triangle' title='Overbooked' style='margin-left:4px;'></i>";
            }
            return "";
        }
    }
}



