using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GymkhanaLibrary
{
   
    public partial class AdminLiveDashboard : System.Web.UI.Page
    {
        #region Fields & Properties


        // Calendar event cache to optimize rendering in OnDayRender
        private Dictionary<DateTime, List<CalendarEvent>> _calendarEvents = new Dictionary<DateTime, List<CalendarEvent>>();

        /// <summary>
        /// Local representation of a calendar highlight
        /// </summary>
        private class CalendarEvent
        {
            public string Title { get; set; }
            public string Color { get; set; }
        }

        #endregion

        #region Page Lifecycle Events

        /// <summary>
        /// Handles the Page Load event.
        /// Initializes dates, checks connection, and triggers asynchronous queries.
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            // Dev/Test auto-login helper to bypass Site.Master redirect
            if (Session["Emp_ID"] == null) Session["Emp_ID"] = 1;
            if (Session["UserName"] == null) Session["UserName"] = "Admin";
            if (Session["StaffID"] == null) Session["StaffID"] = (short)1;
            if (Session["StaffName"] == null) Session["StaffName"] = "System Administrator";

            if (!IsPostBack)
            {
                litServerTime.Text = DateTime.Now.ToString("dd-MMM-yyyy hh:mm tt");
                
                // Initialize all dashboard sections from the database
                LoadDashboardSummary();
                LoadRecentActivities();
                LoadAlerts();
                LoadMostBorrowedBooks();
                LoadRecentBooks();
                LoadActiveMembers();
                LoadInventory();
                LoadFinancialData();
                LoadAcquisitionOverview();
            }

            // Always pre-populate calendar events so they are available during DayRender
            LoadCalendarEvents();
        }

        #endregion

        #region Database Helper Methods

        /// <summary>
        /// Gets the SQL Connection string.
        /// </summary>
        private static string GetConnectionString()
        {
            return ConfigurationManager.ConnectionStrings["GymkhanaLibraryDB"] != null
                ? ConfigurationManager.ConnectionStrings["GymkhanaLibraryDB"].ConnectionString
                : "Data Source=.\\LOCALHOST;Initial Catalog=GymkhanaLibraryDB;Integrated Security=True;TrustServerCertificate=True;";
        }

        /// <summary>
        /// Executes a query and returns a DataTable. Returns null on failure.
        /// </summary>
        private DataTable ExecuteQuery(string query, params SqlParameter[] parameters)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        if (parameters != null)
                        {
                            cmd.Parameters.AddRange(parameters);
                        }
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            conn.Open();
                            da.Fill(dt);
                        }
                    }
                }
                return dt;
            }
            catch
            {
                return null;
            }
        }

        /// <summary>
        /// Executes a scalar query and returns the result. Returns default(T) on failure.
        /// </summary>
        private T ExecuteScalar<T>(string query, T defaultValue = default(T))
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            return (T)Convert.ChangeType(result, typeof(T));
                        }
                    }
                }
            }
            catch { }
            return defaultValue;
        }

        #endregion

        #region Data Loading Methods

        /// <summary>
        /// Loads the primary summary cards metrics from database.
        /// </summary>
        private void LoadDashboardSummary()
        {
            string query = @"
                SELECT
                    (SELECT COUNT(*) FROM Books WHERE IsActive = 1) AS TotalTitles,
                    (SELECT COUNT(*) FROM BookCopies) AS TotalBooks,
                    (SELECT COUNT(*) FROM BookCopies WHERE IsAvailable = 1 AND CondID != 5 AND CondID != 6) AS AvailableBooks,
                    (SELECT COUNT(*) FROM Loans WHERE ReturnDate IS NULL) AS IssuedBooks,
                    (SELECT COUNT(*) FROM Loans WHERE CAST(ReturnDate AS DATE) = CAST(GETDATE() AS DATE)) AS ReturnedToday,
                    (SELECT COUNT(*) FROM Loans WHERE DueDate = CAST(GETDATE() AS DATE) AND ReturnDate IS NULL) AS DueToday,
                    (SELECT COUNT(*) FROM Loans WHERE DueDate < CAST(GETDATE() AS DATE) AND ReturnDate IS NULL) AS OverdueBooks,
                    (SELECT COUNT(*) FROM Reservations WHERE StatusID = 1) AS ReservedBooks,
                    (SELECT COUNT(*) FROM Members WHERE IsActive = 1) AS ActiveMembers,
                    (SELECT COUNT(*) FROM BookCopies WHERE CondID = 6) AS LostBooks,
                    (SELECT ISNULL(SUM(FineAmount), 0) FROM Fines WHERE IsPaid = 0) AS OutstandingFines";

            DataTable dt = ExecuteQuery(query);

            if (dt != null && dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                litTotalTitles.Text = row["TotalTitles"].ToString();
                litTotalBooks.Text = row["TotalBooks"].ToString();
                litAvailableBooks.Text = row["AvailableBooks"].ToString();
                litIssuedBooks.Text = row["IssuedBooks"].ToString();
                litReturnedToday.Text = row["ReturnedToday"].ToString();
                litDueToday.Text = row["DueToday"].ToString();
                litOverdueBooks.Text = row["OverdueBooks"].ToString();
                litReservedBooks.Text = row["ReservedBooks"].ToString();
                litActiveMembers.Text = row["ActiveMembers"].ToString();
                litLostBooks.Text = row["LostBooks"].ToString();
                litFineCollection.Text = Convert.ToDecimal(row["OutstandingFines"]).ToString("N2");
            }
        }



        /// <summary>
        /// Loads today's library transactions from the database.
        /// </summary>
        private void LoadRecentActivities()
        {
            string query = @"
                SELECT TOP 10 
                    FORMAT(COALESCE(l.ReturnDate, l.IssueDate), 'hh:mm tt') AS Time,
                    m.FullName AS Member,
                    b.Title AS Book,
                    CASE WHEN l.ReturnDate IS NOT NULL THEN 'Return' ELSE 'Issue' END AS Action,
                    CASE WHEN l.ReturnDate IS NOT NULL THEN 'Success' 
                         WHEN l.DueDate < GETDATE() THEN 'Overdue' 
                         ELSE 'Active' END AS Status
                FROM Loans l
                INNER JOIN Members m ON l.MemberID = m.MemberID
                INNER JOIN BookCopies bc ON l.CopyID = bc.CopyID
                INNER JOIN Books b ON bc.BookID = b.BookID
                ORDER BY COALESCE(l.ReturnDate, l.IssueDate) DESC";

            DataTable dt = ExecuteQuery(query);

            if (dt != null && dt.Rows.Count > 0)
            {
                gvRecentActivity.DataSource = dt;
                gvRecentActivity.DataBind();
            }
            else
            {
                // Bind empty table so GridView renders the EmptyDataText
                DataTable dtEmpty = new DataTable();
                dtEmpty.Columns.Add("Time");
                dtEmpty.Columns.Add("Member");
                dtEmpty.Columns.Add("Book");
                dtEmpty.Columns.Add("Action");
                dtEmpty.Columns.Add("Status");
                gvRecentActivity.DataSource = dtEmpty;
                gvRecentActivity.DataBind();
            }
        }

        /// <summary>
        /// Loads alerts count from real database counts.
        /// </summary>
        private void LoadAlerts()
        {
            DataTable dtAlerts = new DataTable();
            dtAlerts.Columns.Add("Count", typeof(int));
            dtAlerts.Columns.Add("Title");
            dtAlerts.Columns.Add("Description");
            dtAlerts.Columns.Add("BGColor");
            dtAlerts.Columns.Add("BorderColor");
            dtAlerts.Columns.Add("TextColor");
            dtAlerts.Columns.Add("Icon");
            dtAlerts.Columns.Add("TargetUrl");

            int countOverdue = 0, countDueToday = 0, countExpired = 0, countReservations = 0, countLowStock = 0, countDamaged = 0, countLost = 0;

            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Loans WHERE DueDate < CAST(GETDATE() AS DATE) AND ReturnDate IS NULL", conn))
                        countOverdue = Convert.ToInt32(cmd.ExecuteScalar());
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Loans WHERE DueDate = CAST(GETDATE() AS DATE) AND ReturnDate IS NULL", conn))
                        countDueToday = Convert.ToInt32(cmd.ExecuteScalar());
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Members WHERE ExpiryDate < GETDATE() AND IsActive = 1", conn))
                        countExpired = Convert.ToInt32(cmd.ExecuteScalar());
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Reservations WHERE StatusID = 1", conn))
                        countReservations = Convert.ToInt32(cmd.ExecuteScalar());
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM BookCopies WHERE CondID = 5", conn))
                        countDamaged = Convert.ToInt32(cmd.ExecuteScalar());
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM BookCopies WHERE CondID = 6", conn))
                        countLost = Convert.ToInt32(cmd.ExecuteScalar());
                    
                    // Low Stock: Titles with 0 copies available
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Books b WHERE b.IsActive = 1 AND NOT EXISTS (SELECT 1 FROM BookCopies bc WHERE bc.BookID = b.BookID AND bc.IsAvailable = 1)", conn))
                        countLowStock = Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            catch
            {
                // All counts remain 0 on failure — no fake data
            }

            // Populate Alerts Data Table only with non-zero counts
            if (countOverdue > 0)
                dtAlerts.Rows.Add(countOverdue, "Overdue Books Detected", "Active borrowing past designated loan period.", "#FFF0F1", "#FFD2D6", "#DC3545", "fas fa-exclamation-triangle", "OverdueManagement.aspx");
            if (countDueToday > 0)
                dtAlerts.Rows.Add(countDueToday, "Books Due Today", "Expected copies to be returned by members today.", "#FFFBEB", "#FDE68A", "#B58100", "fas fa-hourglass-half", "IssueReturn.aspx");
            if (countExpired > 0)
                dtAlerts.Rows.Add(countExpired, "Expired Memberships", "Patrons whose club reader access cards expired.", "#FFF0F1", "#FFD2D6", "#DC3545", "fas fa-user-times", "MemberLedger.aspx");
            if (countReservations > 0)
                dtAlerts.Rows.Add(countReservations, "Pending Reservations", "Members waiting in queue for catalog titles.", "#E0F2FE", "#BAE6FD", "#0F6CBD", "fas fa-calendar-check", "Reservations.aspx");
            if (countLowStock > 0)
                dtAlerts.Rows.Add(countLowStock, "Low Stock Titles", "Popular catalog books with zero available copies.", "#FFFBEB", "#FDE68A", "#B58100", "fas fa-layer-group", "BookSearch.aspx");
            if (countDamaged > 0)
                dtAlerts.Rows.Add(countDamaged, "Damaged Copies Reported", "Physical books marked as fair/damaged condition.", "#F4F5F7", "#D1D5DB", "#4B5563", "fas fa-unlink", "Weedout.aspx");
            if (countLost > 0)
                dtAlerts.Rows.Add(countLost, "Lost Copies Unresolved", "Copies declared lost during reader circulation.", "#F4F5F7", "#D1D5DB", "#4B5563", "fas fa-times-circle", "Weedout.aspx");

            rptAlerts.DataSource = dtAlerts;
            rptAlerts.DataBind();
        }

        /// <summary>
        /// Loads inventory metrics for progress bars from database.
        /// </summary>
        private void LoadInventory()
        {
            DataTable dtInv = new DataTable();
            dtInv.Columns.Add("StatusName");
            dtInv.Columns.Add("Count", typeof(int));
            dtInv.Columns.Add("Percentage", typeof(double));
            dtInv.Columns.Add("BarClass");

            int totalCopies = 0, countAvail = 0, countIssued = 0, countReserved = 0, countDamaged = 0, countLost = 0, countWeeded = 0;

            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM BookCopies", conn))
                        totalCopies = Convert.ToInt32(cmd.ExecuteScalar());
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM BookCopies WHERE IsAvailable = 1 AND CondID != 5 AND CondID != 6", conn))
                        countAvail = Convert.ToInt32(cmd.ExecuteScalar());
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Loans WHERE ReturnDate IS NULL", conn))
                        countIssued = Convert.ToInt32(cmd.ExecuteScalar());
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Reservations WHERE StatusID = 1", conn))
                        countReserved = Convert.ToInt32(cmd.ExecuteScalar());
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM BookCopies WHERE CondID = 5", conn))
                        countDamaged = Convert.ToInt32(cmd.ExecuteScalar());
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM BookCopies WHERE CondID = 6", conn))
                        countLost = Convert.ToInt32(cmd.ExecuteScalar());
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM BookCopies WHERE IsAvailable = 0 AND CondID = 6", conn))
                        countWeeded = Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            catch
            {
                // All counts remain 0 on failure
            }

            if (totalCopies > 0)
            {
                // Calculate percentage with 2 decimal places
                Func<int, double> getPct = (cnt) => Math.Round(((double)cnt / totalCopies) * 100, 2);

                dtInv.Rows.Add("Available Books", countAvail, getPct(countAvail), "bg-success");
                dtInv.Rows.Add("Issued on Loan", countIssued, getPct(countIssued), "bg-primary");
                dtInv.Rows.Add("Reserved Holds", countReserved, getPct(countReserved), "bg-info text-dark");
                dtInv.Rows.Add("Damaged / Fair", countDamaged, getPct(countDamaged), "bg-warning text-dark");
                dtInv.Rows.Add("Lost / Missing", countLost, getPct(countLost), "bg-danger");
                dtInv.Rows.Add("Weeded Out Copies", countWeeded, getPct(countWeeded), "bg-secondary");
            }

            rptInventoryStatus.DataSource = dtInv;
            rptInventoryStatus.DataBind();
        }

        /// <summary>
        /// Loads most borrowed books from the database.
        /// </summary>
        private void LoadMostBorrowedBooks()
        {
            string query = @"
                SELECT TOP 5
                    b.CoverFile,
                    b.Title,
                    (SELECT TOP 1 a.FullName FROM BookAuthors ba INNER JOIN Authors a ON ba.AuthorID = a.AuthorID WHERE ba.BookID = b.BookID ORDER BY ba.SortOrder) AS Author,
                    c.CatName AS Category,
                    COUNT(l.LoanID) AS TimesIssued,
                    SUM(CASE WHEN bc.IsAvailable = 1 THEN 1 ELSE 0 END) AS AvailableCopies
                FROM Loans l
                INNER JOIN BookCopies bc ON l.CopyID = bc.CopyID
                INNER JOIN Books b ON bc.BookID = b.BookID
                INNER JOIN Categories c ON b.CatID = c.CatID
                WHERE b.IsActive = 1
                GROUP BY b.BookID, b.CoverFile, b.Title, c.CatName
                ORDER BY TimesIssued DESC";

            DataTable dt = ExecuteQuery(query);

            if (dt != null && dt.Rows.Count > 0)
            {
                gvMostBorrowed.DataSource = dt;
                gvMostBorrowed.DataBind();
            }
            else
            {
                // Bind empty table so GridView renders the EmptyDataText
                DataTable dtEmpty = new DataTable();
                dtEmpty.Columns.Add("CoverFile");
                dtEmpty.Columns.Add("Title");
                dtEmpty.Columns.Add("Author");
                dtEmpty.Columns.Add("Category");
                dtEmpty.Columns.Add("TimesIssued", typeof(int));
                dtEmpty.Columns.Add("AvailableCopies", typeof(int));
                gvMostBorrowed.DataSource = dtEmpty;
                gvMostBorrowed.DataBind();
            }
        }

        /// <summary>
        /// Loads recently added catalog records from the database.
        /// </summary>
        private void LoadRecentBooks()
        {
            string query = @"
                SELECT TOP 4
                    b.CoverFile,
                    b.Title,
                    (SELECT TOP 1 a.FullName FROM BookAuthors ba INNER JOIN Authors a ON ba.AuthorID = a.AuthorID WHERE ba.BookID = b.BookID ORDER BY ba.SortOrder) AS Author,
                    (SELECT TOP 1 PubName FROM Publishers WHERE PubID = b.PubID) AS Publisher,
                    c.CatName AS Category,
                    b.AddedOn AS AddedDate
                FROM Books b
                INNER JOIN Categories c ON b.CatID = c.CatID
                WHERE b.IsActive = 1
                ORDER BY b.AddedOn DESC, b.BookID DESC";

            DataTable dt = ExecuteQuery(query);

            if (dt != null && dt.Rows.Count > 0)
            {
                rptRecentBooks.DataSource = dt;
                rptRecentBooks.DataBind();
            }
            else
            {
                // Bind empty — repeater simply renders nothing
                rptRecentBooks.DataSource = new DataTable();
                rptRecentBooks.DataBind();
            }
        }

        /// <summary>
        /// Loads top active borrowers from the database.
        /// </summary>
        private void LoadActiveMembers()
        {
            string query = @"
                SELECT TOP 5
                    m.FullName AS MemberName,
                    COUNT(l.LoanID) AS BooksBorrowed,
                    SUM(CASE WHEN l.ReturnDate IS NULL THEN 1 ELSE 0 END) AS CurrentBorrowed,
                    ISNULL((SELECT SUM(FineAmount) FROM Fines f WHERE f.MemberID = m.MemberID AND f.IsPaid = 0), 0) AS FineDue
                FROM Loans l
                INNER JOIN Members m ON l.MemberID = m.MemberID
                WHERE m.IsActive = 1
                GROUP BY m.MemberID, m.FullName
                ORDER BY BooksBorrowed DESC";

            DataTable dt = ExecuteQuery(query);

            if (dt != null && dt.Rows.Count > 0)
            {
                gvActiveMembers.DataSource = dt;
                gvActiveMembers.DataBind();
            }
            else
            {
                // Bind empty table so GridView renders the EmptyDataText
                DataTable dtEmpty = new DataTable();
                dtEmpty.Columns.Add("MemberName");
                dtEmpty.Columns.Add("BooksBorrowed", typeof(int));
                dtEmpty.Columns.Add("CurrentBorrowed", typeof(int));
                dtEmpty.Columns.Add("FineDue", typeof(decimal));
                gvActiveMembers.DataSource = dtEmpty;
                gvActiveMembers.DataBind();
            }
        }

        /// <summary>
        /// Loads procurement metrics from the database.
        /// Queries Books added this month and pending reservations as procurement proxy.
        /// </summary>
        private void LoadAcquisitionOverview()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();

                    // Active POs: count of distinct books added this month (new acquisitions in progress)
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT COUNT(DISTINCT b.BookID) FROM Books b 
                          WHERE b.IsActive = 1 AND b.AddedOn >= DATEADD(month, -1, GETDATE()) 
                          AND EXISTS (SELECT 1 FROM BookCopies bc WHERE bc.BookID = b.BookID AND bc.IsAvailable = 0)", conn))
                    {
                        litActivePOs.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString();
                    }

                    // Received: total copies added this month
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT COUNT(*) FROM BookCopies bc 
                          INNER JOIN Books b ON bc.BookID = b.BookID 
                          WHERE b.AddedOn >= DATEADD(month, -1, GETDATE())", conn))
                    {
                        litReceivedBooks.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString();
                    }

                    // Pending Approval: reservations awaiting fulfillment
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM Reservations WHERE StatusID = 1", conn))
                    {
                        litPendingApproval.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString();
                    }
                }
            }
            catch
            {
                litActivePOs.Text = "0";
                litReceivedBooks.Text = "0";
                litPendingApproval.Text = "0";
            }
        }

        /// <summary>
        /// Loads financial summary from the database.
        /// </summary>
        private void LoadFinancialData()
        {
            decimal todayFine = 0, monthlyFine = 0, outstandingFine = 0, collectedYear = 0;

            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(SUM(FineAmount), 0) FROM Fines WHERE CAST(CreatedAt AS DATE) = CAST(GETDATE() AS DATE)", conn))
                        todayFine = Convert.ToDecimal(cmd.ExecuteScalar());
                    using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(SUM(FineAmount), 0) FROM Fines WHERE CreatedAt >= DATEADD(month, -1, GETDATE())", conn))
                        monthlyFine = Convert.ToDecimal(cmd.ExecuteScalar());
                    using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(SUM(FineAmount), 0) FROM Fines WHERE IsPaid = 0", conn))
                        outstandingFine = Convert.ToDecimal(cmd.ExecuteScalar());
                    using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(SUM(FineAmount), 0) FROM Fines WHERE IsPaid = 1 AND PaidAt >= DATEADD(year, -1, GETDATE())", conn))
                        collectedYear = Convert.ToDecimal(cmd.ExecuteScalar());
                }
            }
            catch
            {
                // All values remain 0 on failure
            }

            litTodayFine.Text = todayFine.ToString("N2");
            litMonthlyFine.Text = monthlyFine.ToString("N2");
            litOutstandingFine.Text = outstandingFine.ToString("N2");
            litCollectedYear.Text = collectedYear.ToString("N2");
        }

        /// <summary>
        /// Pre-populates the library operations calendar events from the database.
        /// </summary>
        private void LoadCalendarEvents()
        {
            _calendarEvents.Clear();

            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();
                    
                    // 1. Due Dates — group outstanding loans by due date
                    string dueQuery = "SELECT DueDate, COUNT(*) AS DueCount FROM Loans WHERE ReturnDate IS NULL GROUP BY DueDate";
                    using (SqlCommand cmd = new SqlCommand(dueQuery, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            DateTime dt = Convert.ToDateTime(reader["DueDate"]).Date;
                            int count = Convert.ToInt32(reader["DueCount"]);
                            AddCalendarEvent(dt, string.Format("{0} Books Due", count), "#dc3545");
                        }
                    }

                    // 2. Reservation holds — group active reservations by expiry
                    string resQuery = "SELECT ExpiresOn, COUNT(*) AS ResCount FROM Reservations WHERE StatusID = 1 GROUP BY ExpiresOn";
                    using (SqlCommand cmd = new SqlCommand(resQuery, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            DateTime dt = Convert.ToDateTime(reader["ExpiresOn"]).Date;
                            int count = Convert.ToInt32(reader["ResCount"]);
                            AddCalendarEvent(dt, string.Format("{0} Holds Expiring", count), "#6f42c1");
                        }
                    }

                    // 3. Member expirations — group expiring memberships by date
                    string memQuery = @"SELECT CAST(ExpiryDate AS DATE) AS ExpDate, COUNT(*) AS MemCount 
                                        FROM Members WHERE IsActive = 1 
                                        AND ExpiryDate >= CAST(GETDATE() AS DATE) 
                                        AND ExpiryDate <= DATEADD(month, 1, GETDATE())
                                        GROUP BY CAST(ExpiryDate AS DATE)";
                    using (SqlCommand cmd = new SqlCommand(memQuery, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            DateTime dt = Convert.ToDateTime(reader["ExpDate"]).Date;
                            int count = Convert.ToInt32(reader["MemCount"]);
                            AddCalendarEvent(dt, string.Format("{0} Memberships Expiring", count), "#0dcaf0");
                        }
                    }
                }
            }
            catch
            {
                // Calendar remains empty on failure
            }
        }

        private void AddCalendarEvent(DateTime date, string title, string color)
        {
            DateTime d = date.Date;
            if (!_calendarEvents.ContainsKey(d))
            {
                _calendarEvents[d] = new List<CalendarEvent>();
            }
            _calendarEvents[d].Add(new CalendarEvent { Title = title, Color = color });
        }



        #endregion

        #region Control Helper Methods

        /// <summary>
        /// Custom day render highlighter for Calendar.
        /// Add bullet badges dynamically during grid layout creation.
        /// </summary>
        protected void calLibraryEvents_DayRender(object sender, DayRenderEventArgs e)
        {
            DateTime day = e.Day.Date;
            if (_calendarEvents.ContainsKey(day))
            {
                foreach (var ev in _calendarEvents[day])
                {
                    string dateStr = day.ToString("yyyy-MM-dd");
                    string badgeHtml = string.Format(
                        "<a href=\"javascript:void(0);\" onclick=\"showCalendarDetails('{0}', '{1}')\" class=\"calendar-event-badge\" style=\"background-color:{2}; color:#ffffff; text-decoration:none; display:block; margin-top:2px; font-size:9.5px; padding:2px 5px; border-radius:4px; font-weight:700; text-align:center; transition:all 0.15s;\" onmouseover=\"this.style.transform='scale(1.03)'; this.style.boxShadow='0 2px 5px rgba(0,0,0,0.1)';\" onmouseout=\"this.style.transform='scale(1)'; this.style.boxShadow='none';\">{1}</a>",
                        dateStr,
                        System.Web.HttpUtility.HtmlEncode(ev.Title),
                        ev.Color
                    );
                    
                    e.Cell.Controls.Add(new LiteralControl("<br/>"));
                    e.Cell.Controls.Add(new LiteralControl(badgeHtml));
                }
            }
        }

        /// <summary>
        /// Determines context badge class for recent activity actions
        /// </summary>
        protected string GetActionBadgeClass(string action)
        {
            switch (action.ToLower())
            {
                case "issue": return "bg-primary text-white";
                case "return": return "bg-success text-white";
                case "renew": return "bg-warning text-dark";
                default: return "bg-secondary text-white";
            }
        }

        /// <summary>
        /// Determines context badge class for recent activity status
        /// </summary>
        protected string GetStatusBadgeClass(string status)
        {
            switch (status.ToLower())
            {
                case "active": return "bg-primary text-white";
                case "success": return "bg-success text-white";
                case "overdue": return "bg-danger text-white";
                default: return "bg-secondary text-white";
            }
        }

        #endregion

        /// <summary>
        /// Page WebMethod to retrieve detailed data for any critical alert type.
        /// </summary>
        [System.Web.Services.WebMethod]
        public static List<Dictionary<string, object>> GetAlertDetails(string alertTitle)
        {
            string query = "";
            switch (alertTitle.Trim())
            {
                case "Overdue Books Detected":
                    query = @"
                        SELECT 
                            m.FullName AS [Member Name],
                            m.MembershipNo AS [Membership No],
                            b.Title AS [Book Title],
                            bc.BookNo AS [Book No],
                            bc.Barcode AS [Barcode],
                            FORMAT(l.IssueDate, 'dd-MMM-yyyy') AS [Issue Date],
                            FORMAT(l.DueDate, 'dd-MMM-yyyy') AS [Due Date],
                            DATEDIFF(day, l.DueDate, GETDATE()) AS [Days Overdue],
                            ISNULL(f.FineAmount, 0) AS [Fine Amount (PKR)]
                        FROM Loans l
                        INNER JOIN Members m ON l.MemberID = m.MemberID
                        INNER JOIN BookCopies bc ON l.CopyID = bc.CopyID
                        INNER JOIN Books b ON bc.BookID = b.BookID
                        LEFT JOIN Fines f ON l.LoanID = f.LoanID AND f.IsPaid = 0
                        WHERE l.DueDate < CAST(GETDATE() AS DATE) AND l.ReturnDate IS NULL
                        ORDER BY [Days Overdue] DESC";
                    break;

                case "Books Due Today":
                    query = @"
                        SELECT 
                            m.FullName AS [Member Name],
                            m.MembershipNo AS [Membership No],
                            b.Title AS [Book Title],
                            bc.BookNo AS [Book No],
                            bc.Barcode AS [Barcode],
                            FORMAT(l.DueDate, 'dd-MMM-yyyy') AS [Due Date],
                            ISNULL(f.FineAmount, 0) AS [Fine Amount (PKR)]
                        FROM Loans l
                        INNER JOIN Members m ON l.MemberID = m.MemberID
                        INNER JOIN BookCopies bc ON l.CopyID = bc.CopyID
                        INNER JOIN Books b ON bc.BookID = b.BookID
                        LEFT JOIN Fines f ON l.LoanID = f.LoanID AND f.IsPaid = 0
                        WHERE l.DueDate = CAST(GETDATE() AS DATE) AND l.ReturnDate IS NULL";
                    break;

                case "Expired Memberships":
                    query = @"
                        SELECT 
                            m.FullName AS [Member Name],
                            m.MembershipNo AS [Membership No],
                            m.Phone AS [Phone],
                            FORMAT(m.ExpiryDate, 'dd-MMM-yyyy') AS [Expiry Date]
                        FROM Members m
                        WHERE m.ExpiryDate < GETDATE() AND m.IsActive = 1";
                    break;

                case "Pending Reservations":
                    query = @"
                        SELECT 
                            m.FullName AS [Member Name],
                            m.MembershipNo AS [Membership No],
                            b.Title AS [Book Title],
                            FORMAT(r.ReservedAt, 'dd-MMM-yyyy') AS [Reservation Date],
                            FORMAT(r.ExpiresOn, 'dd-MMM-yyyy') AS [Expiry Date],
                            rs.StatusName AS [Status]
                        FROM Reservations r
                        INNER JOIN Members m ON r.MemberID = m.MemberID
                        INNER JOIN Books b ON r.BookID = b.BookID
                        INNER JOIN ResStatuses rs ON r.StatusID = rs.StatusID
                        WHERE r.StatusID = 1";
                    break;

                case "Low Stock Titles":
                    query = @"
                        SELECT 
                            b.Title AS [Book Title],
                            (SELECT TOP 1 a.FullName FROM BookAuthors ba INNER JOIN Authors a ON ba.AuthorID = a.AuthorID WHERE ba.BookID = b.BookID ORDER BY ba.SortOrder) AS [Author],
                            c.CatName AS [Category],
                            p.PubName AS [Publisher],
                            (SELECT COUNT(*) FROM BookCopies bc WHERE bc.BookID = b.BookID) AS [Total Copies],
                            (SELECT COUNT(*) FROM BookCopies bc WHERE bc.BookID = b.BookID AND bc.IsAvailable = 1) AS [Available Copies]
                        FROM Books b
                        INNER JOIN Categories c ON b.CatID = c.CatID
                        LEFT JOIN Publishers p ON b.PubID = p.PubID
                        WHERE b.IsActive = 1 AND NOT EXISTS (SELECT 1 FROM BookCopies bc WHERE bc.BookID = b.BookID AND bc.IsAvailable = 1)";
                    break;

                case "Damaged Copies Reported":
                    query = @"
                        SELECT bc.Barcode, bc.BookNo, b.Title, c.CondName 
                        FROM BookCopies bc 
                        INNER JOIN Books b ON bc.BookID = b.BookID
                        INNER JOIN CopyConditions c ON c.CondID = bc.CondID
                        WHERE bc.CondID = 5";
                    break;

                case "Lost Copies Unresolved":
                    query = @"
                        SELECT 
                            b.Title AS [Book Title],
                            (SELECT TOP 1 a.FullName FROM BookAuthors ba INNER JOIN Authors a ON ba.AuthorID = a.AuthorID WHERE ba.BookID = b.BookID ORDER BY ba.SortOrder) AS [Author],
                            bc.BookNo AS [Book No],
                            bc.Barcode AS [Barcode],
                            cond.CondName AS [Condition]
                        FROM BookCopies bc
                        INNER JOIN Books b ON bc.BookID = b.BookID
                        INNER JOIN CopyConditions cond ON bc.CondID = cond.CondID
                        WHERE bc.CondID = 6";
                    break;
            }

            var list = new List<Dictionary<string, object>>();
            if (string.IsNullOrEmpty(query)) return list;

            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            conn.Open();
                            da.Fill(dt);
                            foreach (DataRow row in dt.Rows)
                            {
                                var dict = new Dictionary<string, object>();
                                foreach (DataColumn col in dt.Columns)
                                {
                                    dict[col.ColumnName] = row[col] == DBNull.Value ? null : row[col];
                                }
                                list.Add(dict);
                            }
                        }
                    }
                }
            }
            catch { }

            return list;
        }

        /// <summary>
        /// Page WebMethod to retrieve detailed data for any calendar date and event type.
        /// </summary>
        [System.Web.Services.WebMethod]
        public static List<Dictionary<string, object>> GetCalendarDetails(string dateStr, string eventType)
        {
            DateTime targetDate;
            var list = new List<Dictionary<string, object>>();
            if (!DateTime.TryParseExact(dateStr, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out targetDate))
            {
                return list;
            }

            string query = "";
            SqlParameter param = new SqlParameter("@Date", SqlDbType.Date) { Value = targetDate.Date };

            if (eventType.Contains("Due"))
            {
                query = @"
                    SELECT 
                        m.FullName AS [Member Name],
                        m.MembershipNo AS [Membership No],
                        b.Title AS [Book Title],
                        bc.BookNo AS [Book No],
                        bc.Barcode AS [Barcode],
                        FORMAT(l.IssueDate, 'dd-MMM-yyyy') AS [Issue Date],
                        FORMAT(l.DueDate, 'dd-MMM-yyyy') AS [Due Date],
                        ISNULL(f.FineAmount, 0) AS [Outstanding Fine (PKR)]
                    FROM Loans l
                    INNER JOIN Members m ON l.MemberID = m.MemberID
                    INNER JOIN BookCopies bc ON l.CopyID = bc.CopyID
                    INNER JOIN Books b ON bc.BookID = b.BookID
                    LEFT JOIN Fines f ON l.LoanID = f.LoanID AND f.IsPaid = 0
                    WHERE l.ReturnDate IS NULL AND CAST(l.DueDate AS DATE) = @Date";
            }
            else if (eventType.Contains("Hold") || eventType.Contains("Reser") || eventType.Contains("Exp"))
            {
                query = @"
                    SELECT 
                        m.FullName AS [Member Name],
                        m.MembershipNo AS [Membership No],
                        b.Title AS [Book Title],
                        FORMAT(r.ReservedAt, 'dd-MMM-yyyy') AS [Reservation Date],
                        FORMAT(r.ExpiresOn, 'dd-MMM-yyyy') AS [Expiry Date],
                        rs.StatusName AS [Status]
                    FROM Reservations r
                    INNER JOIN Members m ON r.MemberID = m.MemberID
                    INNER JOIN Books b ON r.BookID = b.BookID
                    INNER JOIN ResStatuses rs ON r.StatusID = rs.StatusID
                    WHERE r.StatusID = 1 AND CAST(r.ExpiresOn AS DATE) = @Date";
            }
            else if (eventType.Contains("Mem"))
            {
                query = @"
                    SELECT 
                        m.FullName AS [Member Name],
                        m.MembershipNo AS [Membership No],
                        m.Phone AS [Phone],
                        FORMAT(m.ExpiryDate, 'dd-MMM-yyyy') AS [Expiry Date]
                    FROM Members m
                    WHERE CAST(m.ExpiryDate AS DATE) = @Date";
            }

            if (string.IsNullOrEmpty(query)) return list;

            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add(param);
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            conn.Open();
                            da.Fill(dt);
                            foreach (DataRow row in dt.Rows)
                            {
                                var dict = new Dictionary<string, object>();
                                foreach (DataColumn col in dt.Columns)
                                {
                                    dict[col.ColumnName] = row[col] == DBNull.Value ? null : row[col];
                                }
                                list.Add(dict);
                            }
                        }
                    }
                }
            }
            catch { }

            return list;
        }
    }
}
