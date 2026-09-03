//using System;
//using System.Configuration;
//using System.Data;
//using System.Data.SqlClient;
//using System.Web.UI;
//using System.Web.UI.WebControls;

//namespace GuestRoomApp.GuestRoomM
//{
//    public partial class Dashboard : System.Web.UI.Page
//    {
//        private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

//        protected void Page_Load(object sender, EventArgs e)
//        {
//            if (!IsPostBack)
//            {
//                txtFromDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
//                txtToDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
//                LoadDashboardCounts();
//            }
//        }

//        protected void btnSearch_Click(object sender, EventArgs e)
//        {
//            // Clear any active card selection and hide grid when searching a new date range
//            ResetCards();
//            pnlDetails.Visible = false;

//            LoadDashboardCounts();
//        }

//        private void ResetCards()
//        {
//            // Do not modify CssClass of LinkButton directly from code-behind,
//            // as it causes child HTML controls to be lost during UpdatePanel postback.
//        }

//        private void LoadDashboardCounts()
//        {
//            try
//            {
//                DateTime fromDate = string.IsNullOrEmpty(txtFromDate.Text) ? DateTime.Today : DateTime.Parse(txtFromDate.Text);
//                DateTime toDate = string.IsNullOrEmpty(txtToDate.Text) ? DateTime.Today : DateTime.Parse(txtToDate.Text);

//                using (SqlConnection con = new SqlConnection(connStr))
//                {
//                    con.Open();

//                    // 1. Pending
//                    SqlCommand cmdPending = new SqlCommand("SELECT COUNT(DISTINCT ReservationNo) FROM RoomReservations WHERE CAST(FromDate AS DATE) >= @FromDate AND CAST(FromDate AS DATE) <= @ToDate AND UPPER(LTRIM(RTRIM(Status))) = 'PENDING'", con);
//                    cmdPending.Parameters.AddWithValue("@FromDate", fromDate);
//                    cmdPending.Parameters.AddWithValue("@ToDate", toDate);
//                    lblPendingCount.Text = cmdPending.ExecuteScalar().ToString();

//                    // 2. Confirmed
//                    SqlCommand cmdConfirmed = new SqlCommand("SELECT COUNT(DISTINCT ReservationNo) FROM RoomReservations WHERE CAST(FromDate AS DATE) >= @FromDate AND CAST(FromDate AS DATE) <= @ToDate AND UPPER(LTRIM(RTRIM(Status))) = 'CONFIRMED'", con);
//                    cmdConfirmed.Parameters.AddWithValue("@FromDate", fromDate);
//                    cmdConfirmed.Parameters.AddWithValue("@ToDate", toDate);
//                    lblConfirmedCount.Text = cmdConfirmed.ExecuteScalar().ToString();

//                    // 3. Cancelled
//                    SqlCommand cmdCancelled = new SqlCommand("SELECT COUNT(DISTINCT ReservationNo) FROM RoomReservations WHERE CAST(FromDate AS DATE) >= @FromDate AND CAST(FromDate AS DATE) <= @ToDate AND UPPER(LTRIM(RTRIM(Status))) = 'CANCELLED'", con);
//                    cmdCancelled.Parameters.AddWithValue("@FromDate", fromDate);
//                    cmdCancelled.Parameters.AddWithValue("@ToDate", toDate);
//                    lblCancelledCount.Text = cmdCancelled.ExecuteScalar().ToString();

//                    // 4. Occupied (Occupied at any point in the date range)
//                    SqlCommand cmdOccupied = new SqlCommand("SELECT COUNT(DISTINCT ra.RoomNo) FROM RoomAllocations ra WHERE CAST(ra.AllocatedDate AS DATE) <= @ToDate AND (ra.CheckOutDate IS NULL OR CAST(ra.CheckOutDate AS DATE) >= @FromDate)", con);
//                    cmdOccupied.Parameters.AddWithValue("@FromDate", fromDate);
//                    cmdOccupied.Parameters.AddWithValue("@ToDate", toDate);
//                    lblOccupiedCount.Text = cmdOccupied.ExecuteScalar().ToString();

//                    // 5. Completed (Checked out within the date range)
//                    SqlCommand cmdCompleted = new SqlCommand("SELECT COUNT(DISTINCT a.AllocationID) FROM RoomAllocations a WHERE CAST(a.CheckOutDate AS DATE) >= @FromDate AND CAST(a.CheckOutDate AS DATE) <= @ToDate", con);
//                    cmdCompleted.Parameters.AddWithValue("@FromDate", fromDate);
//                    cmdCompleted.Parameters.AddWithValue("@ToDate", toDate);
//                    lblCompletedCount.Text = cmdCompleted.ExecuteScalar().ToString();

//                    // 6. Billing Done - Completed reservations that have a SETTLED bill
//                    SqlCommand cmdBillingDone = new SqlCommand(@"
//                        SELECT COUNT(DISTINCT rr.ReservationNo)
//                        FROM RoomReservations rr
//                        INNER JOIN GR_Bills b ON b.ReservationNo = rr.ReservationNo
//                        WHERE UPPER(b.BillStatus) IN ('SETTLED','REFUNDED')
//                          AND b.BillNo NOT LIKE 'ADV-MID-%'
//                          AND CAST(rr.FromDate AS DATE) >= @FromDate
//                          AND CAST(rr.FromDate AS DATE) <= @ToDate", con);
//                    cmdBillingDone.Parameters.AddWithValue("@FromDate", fromDate);
//                    cmdBillingDone.Parameters.AddWithValue("@ToDate", toDate);
//                    lblBillingDoneCount.Text = cmdBillingDone.ExecuteScalar().ToString();

//                    // 7. Today Occupied - rooms currently physically in-house (checked-in today or earlier, not yet checked out)
//                    SqlCommand cmdTodayOcc = new SqlCommand(@"
//                        SELECT COUNT(DISTINCT ra.RoomNo)
//                        FROM RoomAllocations ra
//                        WHERE CAST(ra.AllocatedDate AS DATE) <= CAST(GETDATE() AS DATE)
//                          AND ra.CheckOutDate IS NULL", con);
//                    lblTodayOccupiedCount.Text = cmdTodayOcc.ExecuteScalar().ToString();
//                }
//            }
//            catch (Exception ex)
//            {
//                // Optionally handle exception
//                System.Diagnostics.Debug.WriteLine("Error loading counts: " + ex.Message);
//            }
//            LoadLiveRoomStatus();
//        }

//        private void LoadLiveRoomStatus()
//        {
//            try
//            {
//                using (SqlConnection con = new SqlConnection(connStr))
//                {
//                    string query = @"
//                        SELECT 
//                            r.RoomNo,
//                            r.RoomType,
//                            r.FloorNo,
//                            CASE 
//                                WHEN a.RoomNo IS NOT NULL THEN 'Occupied'
//                                WHEN r.Status = 'Available' THEN 'Available'
//                                ELSE r.Status
//                            END AS Status
//                        FROM RoomDefinitionNew r
//                        LEFT JOIN (
//                            SELECT DISTINCT RoomNo 
//                            FROM RoomAllocations 
//                            WHERE CheckOutDate IS NULL
//                        ) a ON r.RoomNo = a.RoomNo
//                        ORDER BY 
//                            CASE WHEN ISNUMERIC(SUBSTRING(r.RoomNo,4,LEN(r.RoomNo)))=1 
//                                 THEN CAST(SUBSTRING(r.RoomNo,4,LEN(r.RoomNo)) AS INT) 
//                                 ELSE 999 END";

//                    SqlDataAdapter da = new SqlDataAdapter(query, con);
//                    DataTable dt = new DataTable();
//                    da.Fill(dt);
//                    rptRooms.DataSource = dt;
//                    rptRooms.DataBind();
//                }
//            }
//            catch (Exception ex)
//            {
//                System.Diagnostics.Debug.WriteLine("Error loading live room status: " + ex.Message);
//            }
//        }

//        protected void Card_Click(object sender, EventArgs e)
//        {
//            LinkButton btn = sender as LinkButton;
//            if (btn != null)
//            {
//                string status = btn.CommandArgument;

//                litGridTitle.Text = status + " Details";
//                pnlDetails.Visible = true;

//                LoadGridData(status);
//            }
//        }

//        private void LoadGridData(string status)
//        {
//            try
//            {
//                DateTime fromDate = string.IsNullOrEmpty(txtFromDate.Text) ? DateTime.Today : DateTime.Parse(txtFromDate.Text);
//                DateTime toDate = string.IsNullOrEmpty(txtToDate.Text) ? DateTime.Today : DateTime.Parse(txtToDate.Text);

//                using (SqlConnection con = new SqlConnection(connStr))
//                {
//                    string sql = "";

//                    switch (status)
//                    {
//                        case "Pending":
//                            sql = @"SELECT ReservationNo, GuestName, MembershipNo, MobileNo, '' as RoomNo, FromDate as CheckInDate, ToDate as CheckOutDate, Status 
//                                    FROM RoomReservations 
//                                    WHERE CAST(FromDate AS DATE) >= @FromDate AND CAST(FromDate AS DATE) <= @ToDate AND UPPER(LTRIM(RTRIM(Status))) = 'PENDING'
//                                    ORDER BY ResDate DESC";
//                            break;
//                        case "Confirmed":
//                            sql = @"SELECT ReservationNo, GuestName, MembershipNo, MobileNo, '' as RoomNo, FromDate as CheckInDate, ToDate as CheckOutDate, Status 
//                                    FROM RoomReservations 
//                                    WHERE CAST(FromDate AS DATE) >= @FromDate AND CAST(FromDate AS DATE) <= @ToDate AND UPPER(LTRIM(RTRIM(Status))) = 'CONFIRMED'
//                                    ORDER BY ResDate DESC";
//                            break;
//                        case "Cancelled":
//                            sql = @"SELECT ReservationNo, GuestName, MembershipNo, MobileNo, '' as RoomNo, FromDate as CheckInDate, ToDate as CheckOutDate, Status 
//                                    FROM RoomReservations 
//                                    WHERE CAST(FromDate AS DATE) >= @FromDate AND CAST(FromDate AS DATE) <= @ToDate AND UPPER(LTRIM(RTRIM(Status))) = 'CANCELLED'
//                                    ORDER BY ResDate DESC";
//                            break;
//                        case "Occupied":
//                            sql = @"SELECT rr.ReservationNo, rr.GuestName, rr.MembershipNo, rr.MobileNo, ra.RoomNo, ra.AllocatedDate as CheckInDate, rr.ToDate as CheckOutDate, 'Occupied' as Status 
//                                    FROM RoomAllocations ra 
//                                    INNER JOIN (
//                                        SELECT ReservationNo, GuestName, MembershipNo, MobileNo, ToDate, 
//                                               ROW_NUMBER() OVER(PARTITION BY ReservationNo ORDER BY ReservationID) as rn 
//                                        FROM RoomReservations
//                                    ) rr ON ra.ReservationNo = rr.ReservationNo AND rr.rn = 1 
//                                    WHERE CAST(ra.AllocatedDate AS DATE) <= @ToDate AND (ra.CheckOutDate IS NULL OR CAST(ra.CheckOutDate AS DATE) >= @FromDate)
//                                    ORDER BY ra.AllocatedDate DESC";
//                            break;
//                        case "Completed":
//                            sql = @"SELECT r.ReservationNo, r.GuestName, r.MembershipNo, r.MobileNo, a.RoomNo, a.AllocatedDate as CheckInDate, a.CheckOutDate as CheckOutDate, 'Completed' as Status 
//                                    FROM RoomAllocations a 
//                                    INNER JOIN (
//                                        SELECT ReservationNo, MIN(GuestName) as GuestName, MIN(MembershipNo) as MembershipNo, MIN(MobileNo) as MobileNo 
//                                        FROM RoomReservations GROUP BY ReservationNo
//                                    ) r ON a.ReservationNo = r.ReservationNo 
//                                    WHERE CAST(a.CheckOutDate AS DATE) >= @FromDate AND CAST(a.CheckOutDate AS DATE) <= @ToDate
//                                    ORDER BY a.CheckOutDate DESC";
//                            break;

//                        case "BillingDone":
//                            sql = @"SELECT DISTINCT rr.ReservationNo, rr.GuestName, rr.MembershipNo, rr.MobileNo, '' as RoomNo,
//                                        rr.FromDate as CheckInDate, rr.ToDate as CheckOutDate,
//                                        'Billing Done' as Status
//                                    FROM RoomReservations rr
//                                    INNER JOIN GR_Bills b ON b.ReservationNo = rr.ReservationNo
//                                    WHERE UPPER(b.BillStatus) IN ('SETTLED','REFUNDED')
//                                      AND b.BillNo NOT LIKE 'ADV-MID-%'
//                                      AND CAST(rr.FromDate AS DATE) >= @FromDate
//                                      AND CAST(rr.FromDate AS DATE) <= @ToDate
//                                    ORDER BY rr.FromDate DESC";
//                            break;

//                        case "TodayOccupied":
//                            sql = @"SELECT rr.ReservationNo, rr.GuestName, rr.MembershipNo, rr.MobileNo, ra.RoomNo,
//                                        ra.AllocatedDate as CheckInDate, rr.ToDate as CheckOutDate,
//                                        'In-House' as Status
//                                    FROM RoomAllocations ra
//                                    INNER JOIN (
//                                        SELECT ReservationNo, MIN(GuestName) as GuestName, MIN(MembershipNo) as MembershipNo, MIN(MobileNo) as MobileNo, MIN(ToDate) as ToDate
//                                        FROM RoomReservations GROUP BY ReservationNo
//                                    ) rr ON ra.ReservationNo = rr.ReservationNo
//                                    WHERE CAST(ra.AllocatedDate AS DATE) <= CAST(GETDATE() AS DATE)
//                                      AND ra.CheckOutDate IS NULL
//                                    ORDER BY ra.AllocatedDate DESC";
//                            break;
//                    }

//                    if (!string.IsNullOrEmpty(sql))
//                    {
//                        SqlCommand cmd = new SqlCommand(sql, con);
//                        cmd.Parameters.AddWithValue("@FromDate", fromDate);
//                        cmd.Parameters.AddWithValue("@ToDate", toDate);

//                        SqlDataAdapter da = new SqlDataAdapter(cmd);
//                        DataTable dt = new DataTable();
//                        da.Fill(dt);

//                        gvDetails.DataSource = dt;
//                        gvDetails.DataBind();
//                    }
//                }
//            }
//            catch (Exception ex)
//            {
//                System.Diagnostics.Debug.WriteLine("Error loading grid data: " + ex.Message);
//            }
//        }

//        protected void gvDetails_RowDataBound(object sender, GridViewRowEventArgs e)
//        {
//            if (e.Row.RowType == DataControlRowType.DataRow)
//            {
//                Label lblStatus = (Label)e.Row.FindControl("lblStatus");
//                if (lblStatus != null)
//                {
//                    string status = lblStatus.Text.Trim().ToUpper();
//                    string cssClass = "badge ";

//                    if (status == "PENDING") cssClass += "badge-pending";
//                    else if (status == "CONFIRMED") cssClass += "badge-confirmed";
//                    else if (status == "CANCELLED") cssClass += "badge-cancelled";
//                    else if (status == "OCCUPIED" || status == "AVAILED") cssClass += "badge-occupied";
//                    else if (status == "COMPLETED") cssClass += "badge-completed";
//                    else cssClass += "badge-pending"; // Default

//                    lblStatus.CssClass = cssClass;
//                }
//            }
//        }
//    }
//}





using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GuestRoomApp.GuestRoomM
{
    public partial class Dashboard : System.Web.UI.Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtFromDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtToDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                LoadDashboardCounts();
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            // Clear any active card selection and hide grid when searching a new date range
            ResetCards();
            pnlDetails.Visible = false;

            LoadDashboardCounts();
        }

        private void ResetCards()
        {
            // Do not modify CssClass of LinkButton directly from code-behind,
            // as it causes child HTML controls to be lost during UpdatePanel postback.
        }

        private void LoadDashboardCounts()
        {
            try
            {
                DateTime fromDate = string.IsNullOrEmpty(txtFromDate.Text) ? DateTime.Today : DateTime.Parse(txtFromDate.Text);
                DateTime toDate = string.IsNullOrEmpty(txtToDate.Text) ? DateTime.Today : DateTime.Parse(txtToDate.Text);

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    // 1. Pending
                    SqlCommand cmdPending = new SqlCommand("SELECT COUNT(DISTINCT ReservationNo) FROM RoomReservations WHERE CAST(FromDate AS DATE) >= @FromDate AND CAST(FromDate AS DATE) <= @ToDate AND UPPER(LTRIM(RTRIM(Status))) = 'PENDING'", con);
                    cmdPending.Parameters.AddWithValue("@FromDate", fromDate);
                    cmdPending.Parameters.AddWithValue("@ToDate", toDate);
                    lblPendingCount.Text = cmdPending.ExecuteScalar().ToString();

                    // 2. Confirmed
                    SqlCommand cmdConfirmed = new SqlCommand("SELECT COUNT(DISTINCT ReservationNo) FROM RoomReservations WHERE CAST(FromDate AS DATE) >= @FromDate AND CAST(FromDate AS DATE) <= @ToDate AND UPPER(LTRIM(RTRIM(Status))) = 'CONFIRMED'", con);
                    cmdConfirmed.Parameters.AddWithValue("@FromDate", fromDate);
                    cmdConfirmed.Parameters.AddWithValue("@ToDate", toDate);
                    lblConfirmedCount.Text = cmdConfirmed.ExecuteScalar().ToString();

                    // 3. Cancelled
                    SqlCommand cmdCancelled = new SqlCommand("SELECT COUNT(DISTINCT ReservationNo) FROM RoomReservations WHERE CAST(FromDate AS DATE) >= @FromDate AND CAST(FromDate AS DATE) <= @ToDate AND UPPER(LTRIM(RTRIM(Status))) = 'CANCELLED'", con);
                    cmdCancelled.Parameters.AddWithValue("@FromDate", fromDate);
                    cmdCancelled.Parameters.AddWithValue("@ToDate", toDate);
                    lblCancelledCount.Text = cmdCancelled.ExecuteScalar().ToString();

                    // 4. Occupied (Occupied at any point in the date range)
                    SqlCommand cmdOccupied = new SqlCommand("SELECT COUNT(DISTINCT ra.RoomNo) FROM RoomAllocations ra WHERE CAST(ra.AllocatedDate AS DATE) <= @ToDate AND (ra.CheckOutDate IS NULL OR CAST(ra.CheckOutDate AS DATE) >= @FromDate)", con);
                    cmdOccupied.Parameters.AddWithValue("@FromDate", fromDate);
                    cmdOccupied.Parameters.AddWithValue("@ToDate", toDate);
                    lblOccupiedCount.Text = cmdOccupied.ExecuteScalar().ToString();

                    // 5. Completed (Checked out within the date range)
                    SqlCommand cmdCompleted = new SqlCommand("SELECT COUNT(DISTINCT a.AllocationID) FROM RoomAllocations a WHERE CAST(a.CheckOutDate AS DATE) >= @FromDate AND CAST(a.CheckOutDate AS DATE) <= @ToDate AND NOT EXISTS (     SELECT 1    FROM GR_Bills b    WHERE b.ReservationNo = a.ReservationNo      AND UPPER(b.BillStatus) IN ('SETTLED','REFUNDED')      AND b.BillNo NOT LIKE 'ADV-MID-%')", con);
                    cmdCompleted.Parameters.AddWithValue("@FromDate", fromDate);
                    cmdCompleted.Parameters.AddWithValue("@ToDate", toDate);
                    lblCompletedCount.Text = cmdCompleted.ExecuteScalar().ToString();

                    // 6. Billing Done - Completed reservations that have a SETTLED bill
                    SqlCommand cmdBillingDone = new SqlCommand(@"
                        SELECT COUNT(DISTINCT rr.ReservationNo)
                        FROM RoomReservations rr
                        INNER JOIN GR_Bills b ON b.ReservationNo = rr.ReservationNo
                        WHERE UPPER(b.BillStatus) IN ('SETTLED','REFUNDED')
                          AND b.BillNo NOT LIKE 'ADV-MID-%'
                          AND CAST(rr.FromDate AS DATE) >= @FromDate
                          AND CAST(rr.FromDate AS DATE) <= @ToDate", con);
                    cmdBillingDone.Parameters.AddWithValue("@FromDate", fromDate);
                    cmdBillingDone.Parameters.AddWithValue("@ToDate", toDate);
                    lblBillingDoneCount.Text = cmdBillingDone.ExecuteScalar().ToString();

                    // 7. Today Occupied - rooms currently physically in-house (checked-in today or earlier, not yet checked out)
                    SqlCommand cmdTodayOcc = new SqlCommand(@"
                        SELECT COUNT(DISTINCT ra.RoomNo)
                        FROM RoomAllocations ra
                        WHERE CAST(ra.AllocatedDate AS DATE) <= CAST(GETDATE() AS DATE)
                          AND ra.CheckOutDate IS NULL", con);
                    lblTodayOccupiedCount.Text = cmdTodayOcc.ExecuteScalar().ToString();
                }
            }
            catch (Exception ex)
            {
                // Optionally handle exception
                System.Diagnostics.Debug.WriteLine("Error loading counts: " + ex.Message);
            }
            LoadLiveRoomStatus();
        }

        private void LoadLiveRoomStatus()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = @"
                        SELECT 
                            r.RoomNo,
                            r.RoomType,
                            r.FloorNo,
                            CASE 
                                WHEN a.RoomNo IS NOT NULL THEN 'Occupied'
                                WHEN r.Status = 'Available' THEN 'Available'
                                ELSE r.Status
                            END AS Status
                        FROM RoomDefinitionNew r
                        LEFT JOIN (
                            SELECT DISTINCT RoomNo 
                            FROM RoomAllocations 
                            WHERE CheckOutDate IS NULL
                        ) a ON r.RoomNo = a.RoomNo
                        ORDER BY 
                            CASE WHEN ISNUMERIC(SUBSTRING(r.RoomNo,4,LEN(r.RoomNo)))=1 
                                 THEN CAST(SUBSTRING(r.RoomNo,4,LEN(r.RoomNo)) AS INT) 
                                 ELSE 999 END";

                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    rptRooms.DataSource = dt;
                    rptRooms.DataBind();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading live room status: " + ex.Message);
            }
        }

        protected void Card_Click(object sender, EventArgs e)
        {
            LinkButton btn = sender as LinkButton;
            if (btn != null)
            {
                string status = btn.CommandArgument;

                litGridTitle.Text = status + " Details";
                pnlDetails.Visible = true;

                LoadGridData(status);
            }
        }

        private void LoadGridData(string status)
        {
            try
            {
                DateTime fromDate = string.IsNullOrEmpty(txtFromDate.Text) ? DateTime.Today : DateTime.Parse(txtFromDate.Text);
                DateTime toDate = string.IsNullOrEmpty(txtToDate.Text) ? DateTime.Today : DateTime.Parse(txtToDate.Text);

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string sql = "";

                    switch (status)
                    {
                        case "Pending":
                            sql = @"SELECT ReservationNo, GuestName, MembershipNo, MobileNo, '' as RoomNo, FromDate as CheckInDate, ToDate as CheckOutDate, Status 
                                    FROM RoomReservations 
                                    WHERE CAST(FromDate AS DATE) >= @FromDate AND CAST(FromDate AS DATE) <= @ToDate AND UPPER(LTRIM(RTRIM(Status))) = 'PENDING'
                                    ORDER BY ResDate DESC";
                            break;
                        case "Confirmed":
                            sql = @"SELECT ReservationNo, GuestName, MembershipNo, MobileNo, '' as RoomNo, FromDate as CheckInDate, ToDate as CheckOutDate, Status 
                                    FROM RoomReservations 
                                    WHERE CAST(FromDate AS DATE) >= @FromDate AND CAST(FromDate AS DATE) <= @ToDate AND UPPER(LTRIM(RTRIM(Status))) = 'CONFIRMED'
                                    ORDER BY ResDate DESC";
                            break;
                        case "Cancelled":
                            sql = @"SELECT ReservationNo, GuestName, MembershipNo, MobileNo, '' as RoomNo, FromDate as CheckInDate, ToDate as CheckOutDate, Status 
                                    FROM RoomReservations 
                                    WHERE CAST(FromDate AS DATE) >= @FromDate AND CAST(FromDate AS DATE) <= @ToDate AND UPPER(LTRIM(RTRIM(Status))) = 'CANCELLED'
                                    ORDER BY ResDate DESC";
                            break;
                        case "Occupied":
                            sql = @"SELECT rr.ReservationNo, rr.GuestName, rr.MembershipNo, rr.MobileNo, ra.RoomNo, ra.AllocatedDate as CheckInDate, rr.ToDate as CheckOutDate, 'Occupied' as Status 
                                    FROM RoomAllocations ra 
                                    INNER JOIN (
                                        SELECT ReservationNo, GuestName, MembershipNo, MobileNo, ToDate, 
                                               ROW_NUMBER() OVER(PARTITION BY ReservationNo ORDER BY ReservationID) as rn 
                                        FROM RoomReservations
                                    ) rr ON ra.ReservationNo = rr.ReservationNo AND rr.rn = 1 
                                    WHERE CAST(ra.AllocatedDate AS DATE) <= @ToDate AND (ra.CheckOutDate IS NULL OR CAST(ra.CheckOutDate AS DATE) >= @FromDate)
                                    ORDER BY ra.AllocatedDate DESC";
                            break;
                        case "Completed":
                            sql = @"SELECT r.ReservationNo, r.GuestName, r.MembershipNo, r.MobileNo, a.RoomNo, a.AllocatedDate as CheckInDate, a.CheckOutDate as CheckOutDate, 'Completed' as Status 
                                    FROM RoomAllocations a 
                                    INNER JOIN (
                                        SELECT ReservationNo, MIN(GuestName) as GuestName, MIN(MembershipNo) as MembershipNo, MIN(MobileNo) as MobileNo 
                                        FROM RoomReservations GROUP BY ReservationNo
                                    ) r ON a.ReservationNo = r.ReservationNo 
                                    WHERE CAST(a.CheckOutDate AS DATE) >= @FromDate
AND CAST(a.CheckOutDate AS DATE) <= @ToDate
AND NOT EXISTS
(
    SELECT 1
    FROM GR_Bills b
    WHERE b.ReservationNo = a.ReservationNo
      AND UPPER(b.BillStatus) IN ('SETTLED','REFUNDED')
      AND b.BillNo NOT LIKE 'ADV-MID-%'
)";
                            break;

                        case "BillingDone":
                            //sql = @"SELECT DISTINCT rr.ReservationNo, rr.GuestName, rr.MembershipNo, rr.MobileNo, '' as RoomNo,
                            //            rr.FromDate as CheckInDate, rr.ToDate as CheckOutDate,
                            //            'Billing Done' as Status
                            //        FROM RoomReservations rr
                            //        INNER JOIN GR_Bills b ON b.ReservationNo = rr.ReservationNo
                            //        WHERE UPPER(b.BillStatus) IN ('SETTLED','REFUNDED')
                            //          AND b.BillNo NOT LIKE 'ADV-MID-%'
                            //          AND CAST(rr.FromDate AS DATE) >= @FromDate
                            //          AND CAST(rr.FromDate AS DATE) <= @ToDate
                            //        ORDER BY rr.FromDate DESC";         


                            sql = @"SELECT DISTINCT
       rr.ReservationNo,
       rr.GuestName,
       rr.MembershipNo,
       rr.MobileNo,
       ra.RoomNo,
       ra.AllocatedDate as CheckInDate,
       ra.CheckOutDate as CheckOutDate,
       'Billing Done' as Status
FROM RoomReservations rr
INNER JOIN GR_Bills b
    ON b.ReservationNo = rr.ReservationNo
INNER JOIN RoomAllocations ra
    ON ra.ReservationNo = rr.ReservationNo
WHERE UPPER(b.BillStatus) IN ('SETTLED','REFUNDED')
  AND b.BillNo NOT LIKE 'ADV-MID-%'
  AND CAST(ra.CheckOutDate AS DATE) >= @FromDate
  AND CAST(ra.CheckOutDate AS DATE) <= @ToDate
ORDER BY ra.CheckOutDate DESC";
                            break;

                        case "TodayOccupied":
                            sql = @"SELECT rr.ReservationNo, rr.GuestName, rr.MembershipNo, rr.MobileNo, ra.RoomNo,
                                        ra.AllocatedDate as CheckInDate, rr.ToDate as CheckOutDate,
                                        'In-House' as Status
                                    FROM RoomAllocations ra
                                    INNER JOIN (
                                        SELECT ReservationNo, MIN(GuestName) as GuestName, MIN(MembershipNo) as MembershipNo, MIN(MobileNo) as MobileNo, MIN(ToDate) as ToDate
                                        FROM RoomReservations GROUP BY ReservationNo
                                    ) rr ON ra.ReservationNo = rr.ReservationNo
                                    WHERE CAST(ra.AllocatedDate AS DATE) <= CAST(GETDATE() AS DATE)
                                      AND ra.CheckOutDate IS NULL
                                    ORDER BY ra.AllocatedDate DESC";
                            break;
                    }

                    if (!string.IsNullOrEmpty(sql))
                    {
                        SqlCommand cmd = new SqlCommand(sql, con);
                        cmd.Parameters.AddWithValue("@FromDate", fromDate);
                        cmd.Parameters.AddWithValue("@ToDate", toDate);

                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        gvDetails.DataSource = dt;
                        gvDetails.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading grid data: " + ex.Message);
            }
        }

        protected void gvDetails_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                Label lblStatus = (Label)e.Row.FindControl("lblStatus");
                if (lblStatus != null)
                {
                    string status = lblStatus.Text.Trim().ToUpper();
                    string cssClass = "badge ";

                    if (status == "PENDING") cssClass += "badge-pending";
                    else if (status == "CONFIRMED") cssClass += "badge-confirmed";
                    else if (status == "CANCELLED") cssClass += "badge-cancelled";
                    else if (status == "OCCUPIED" || status == "AVAILED") cssClass += "badge-occupied";
                    else if (status == "COMPLETED") cssClass += "badge-completed";
                    else cssClass += "badge-pending"; // Default

                    lblStatus.CssClass = cssClass;
                }
            }
        }
    }
}


