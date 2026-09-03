using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GuestRoomApp.GuestRoomM
{
    public partial class TodayConfirmations : System.Web.UI.Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtArrivalDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                DateTime initialDate = DateTime.Today;
                LoadPendingBookings();
                UpdateKPIs(initialDate);
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            DateTime arrivalDate = string.IsNullOrEmpty(txtArrivalDate.Text) ? DateTime.Today : DateTime.Parse(txtArrivalDate.Text);
            LoadPendingBookings();
            UpdateKPIs(arrivalDate);
        }

        private void UpdateKPIs(DateTime arrivalDate)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    // 1. Pending (Arrival date and status PENDING)
                    SqlCommand cmdPending = new SqlCommand("SELECT ISNULL(SUM(NoOfRooms),0) FROM RoomReservations WHERE CAST(FromDate AS DATE) = @ArrivalDate AND UPPER(LTRIM(RTRIM(Status))) = 'PENDING'", con);
                    cmdPending.Parameters.AddWithValue("@ArrivalDate", arrivalDate);
                    lblPendingToday.Text = cmdPending.ExecuteScalar().ToString();

                    // 2. Confirmed (Arrival date and status CONFIRMED)
                    SqlCommand cmdConfirmed = new SqlCommand("SELECT ISNULL(SUM(NoOfRooms),0) FROM RoomReservations WHERE CAST(FromDate AS DATE) = @ArrivalDate AND UPPER(LTRIM(RTRIM(Status))) = 'CONFIRMED'", con);
                    cmdConfirmed.Parameters.AddWithValue("@ArrivalDate", arrivalDate);
                    lblConfirmedToday.Text = cmdConfirmed.ExecuteScalar().ToString();

                    // 3. Total Arrivals (All statuses except CANCELLED for arrival date)
                    SqlCommand cmdArrivals = new SqlCommand("SELECT ISNULL(SUM(NoOfRooms),0) FROM RoomReservations WHERE CAST(FromDate AS DATE) = @ArrivalDate AND UPPER(LTRIM(RTRIM(Status))) != 'CANCELLED'", con);
                    cmdArrivals.Parameters.AddWithValue("@ArrivalDate", arrivalDate);
                    lblTotalArrivals.Text = cmdArrivals.ExecuteScalar().ToString();

                    // 4. Cancelled (Arrival date and status CANCELLED)
                    SqlCommand cmdCancelled = new SqlCommand("SELECT ISNULL(SUM(NoOfRooms),0) FROM RoomReservations WHERE CAST(FromDate AS DATE) = @ArrivalDate AND UPPER(LTRIM(RTRIM(Status))) = 'CANCELLED'", con);
                    cmdCancelled.Parameters.AddWithValue("@ArrivalDate", arrivalDate);
                    lblCancelledToday.Text = cmdCancelled.ExecuteScalar().ToString();
                }
            }
            catch { }
        }

        private void LoadPendingBookings()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    DateTime arrivalDate = string.IsNullOrEmpty(txtArrivalDate.Text) ? DateTime.Today : DateTime.Parse(txtArrivalDate.Text);
                    string search = txtSearch.Text.Trim();

                    string sql = @"
                        SELECT ReservationNo, GuestName, GuestOf, MembershipNo, FromDate, ToDate, NoOfRooms, AdvancePayment, Status
                        FROM RoomReservations
                        WHERE UPPER(LTRIM(RTRIM(Status))) = 'PENDING'
                        AND CAST(FromDate AS DATE) = @ArrivalDate";

                    if (!string.IsNullOrEmpty(search))
                    {
                        sql += " AND (GuestName LIKE @Search OR GuestOf LIKE @Search OR MembershipNo LIKE @Search OR ReservationNo LIKE @Search)";
                    }

                    sql += " ORDER BY ResDate DESC";

                    SqlCommand cmd = new SqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("@ArrivalDate", arrivalDate);
                    if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@Search", "%" + search + "%");

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvPending.DataSource = dt;
                    gvPending.DataBind();
                    lblCount.Text = dt.Rows.Count.ToString();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading bookings: " + ex.Message, false);
            }
        }

        protected void gvPending_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string resNo = e.CommandArgument.ToString();
            if (e.CommandName == "Confirm")
            {
                UpdateStatus(resNo, "Confirmed");
            }
            else if (e.CommandName == "CancelRes")
            {
                UpdateStatus(resNo, "Cancelled");
            }
        }

        protected void gvPending_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            // Required handler: prevents 'RowCancelingEdit not handled' error
            gvPending.EditIndex = -1;
            LoadPendingBookings();
        }

        private void UpdateStatus(string resNo, string newStatus)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string sql = "UPDATE RoomReservations SET Status = @Status, Remarks = ISNULL(Remarks,'') + CHAR(13) + @UpdateNote WHERE ReservationNo = @ResNo";
                    SqlCommand cmd = new SqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("@Status", newStatus);
                    cmd.Parameters.AddWithValue("@ResNo", resNo);
                    cmd.Parameters.AddWithValue("@UpdateNote", string.Format("[Status Update] Changed to {0} on {1} via Confirmation Page", newStatus, DateTime.Now.ToString("dd-MMM-yyyy HH:mm")));

                    con.Open();
                    int rows = cmd.ExecuteNonQuery();
                    if (rows > 0)
                    {
                        ShowMessage(string.Format(" Reservation {0} has been {1} successfully.", resNo, newStatus.ToLower()), true);
                        DateTime arrivalDate = string.IsNullOrEmpty(txtArrivalDate.Text) ? DateTime.Today : DateTime.Parse(txtArrivalDate.Text);
                        LoadPendingBookings();
                        UpdateKPIs(arrivalDate);
                    }
                    else
                    {
                        ShowMessage(" Failed to update reservation status.", false);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        protected void btnPrintReport_Click(object sender, EventArgs e)
        {
            LoadTodayReportData();
            hfPrint.Value = "1";
        }

        private void LoadTodayReportData()
        {
            DateTime rptDate = string.IsNullOrEmpty(txtArrivalDate.Text) ? DateTime.Today : DateTime.Parse(txtArrivalDate.Text);
            string rptDateStr = rptDate.ToString("dd-MMM-yyyy");

            lblRptDate.Text = rptDate.ToString("dd MMMM yyyy");
            lblRptTime.Text = DateTime.Now.ToString("dd-MMM-yyyy hh:mm tt");

            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    // 1. Calculate activity totals for TODAY (actions taken today)
                    string sqlActivity = @"
                        SELECT 
                            ISNULL(SUM(CASE WHEN UPPER(Status) = 'CONFIRMED' THEN NoOfRooms ELSE 0 END), 0) as Confirmed,
                            ISNULL(SUM(CASE WHEN UPPER(Status) = 'CANCELLED' THEN NoOfRooms ELSE 0 END), 0) as Cancelled
                        FROM RoomReservations 
                        WHERE Remarks LIKE @TodayPattern";

                    SqlCommand cmdAct = new SqlCommand(sqlActivity, con);
                    cmdAct.Parameters.AddWithValue("@TodayPattern", "%on " + rptDateStr + "%via Confirmation Page%");

                    using (SqlDataReader dr = cmdAct.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            lblRptConfirmed.Text = dr["Confirmed"].ToString();
                            lblRptCancelled.Text = dr["Cancelled"].ToString();
                        }
                    }

                    // 2. Keep "Still Pending" as Arrivals for the selected date for context
                    lblRptPending.Text = lblPendingToday.Text;

                    // â”€â”€ NEW: Fetch Pending Arrivals for the selected date â”€â”€
                    string sqlPending = @"
                        SELECT ReservationNo, GuestName, MembershipNo, FromDate, ToDate, NoOfRooms, AdvancePayment
                        FROM RoomReservations
                        WHERE Status = 'Pending'
                        AND CAST(FromDate AS DATE) = @ArrivalDate
                        ORDER BY ReservationNo";
                    SqlCommand cmdPending = new SqlCommand(sqlPending, con);
                    cmdPending.Parameters.AddWithValue("@ArrivalDate", rptDate);

                    SqlDataAdapter daP = new SqlDataAdapter(cmdPending);
                    DataTable dtP = new DataTable();
                    daP.Fill(dtP);
                    gvPendingRpt.DataSource = dtP;
                    gvPendingRpt.DataBind();

                    // 3. Load the grid with reservations confirmed TODAY
                    string sqlGrid = @"
                        SELECT ReservationNo, GuestName, MembershipNo, FromDate, ToDate, NoOfRooms, AdvancePayment
                        FROM RoomReservations
                        WHERE Status = 'Confirmed'
                        AND Remarks LIKE @TodayPattern
                        ORDER BY ReservationNo";

                    SqlCommand cmdGrid = new SqlCommand(sqlGrid, con);
                    cmdGrid.Parameters.AddWithValue("@TodayPattern", "%on " + rptDateStr + "%via Confirmation Page%");

                    SqlDataAdapter da = new SqlDataAdapter(cmdGrid);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvConfirmedRpt.DataSource = dt;
                    gvConfirmedRpt.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading report: " + ex.Message, false);
            }
        }

        private void ShowMessage(string msg, bool success)
        {
            lblMessage.Text = msg;
            lblMessage.CssClass = "alert show " + (success ? "alert-success" : "alert-error");
            string script = "setTimeout(function(){ var m=document.getElementById('" + lblMessage.ClientID + "'); if(m)m.style.display='none'; }, 5000);";
            ClientScript.RegisterStartupScript(GetType(), "HideMsg", script, true);
        }
    }
}


