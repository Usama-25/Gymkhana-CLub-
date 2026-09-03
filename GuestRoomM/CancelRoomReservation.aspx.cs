using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GuestRoomApp.GuestRoomM
{
    public partial class CancelRoomReservation : System.Web.UI.Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtFromDate.Text = DateTime.Now.AddDays(-7).ToString("yyyy-MM-dd");
                txtToDate.Text = DateTime.Now.AddMonths(1).ToString("yyyy-MM-dd");
                LoadReservations();
                LoadKPIs();
            }
        }

        private void LoadKPIs()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = @"
                        SELECT 
                            SUM(CASE WHEN Status = 'PENDING' THEN 1 ELSE 0 END) as Pending,
                            SUM(CASE WHEN Status = 'CONFIRMED' THEN 1 ELSE 0 END) as Confirmed,
                            SUM(CASE WHEN Status = 'OCCUPIED' OR Status = 'Availed' THEN 1 ELSE 0 END) as Occupied,
                            SUM(CASE WHEN Status = 'CANCELLED' THEN 1 ELSE 0 END) as Cancelled
                        FROM RoomReservations";
                    SqlCommand cmd = new SqlCommand(query, con);
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            lblPendingCount.Text = dr["Pending"].ToString();
                            lblConfirmedCount.Text = dr["Confirmed"].ToString();
                            lblAvailedCount.Text = dr["Occupied"].ToString(); // Note: Label ID from ASPX is lblAvailedCount
                            lblCancelledCount.Text = dr["Cancelled"].ToString();
                        }
                    }
                }
            }
            catch { }
        }

        private void LoadReservations()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = @"SELECT * FROM RoomReservations WHERE FromDate >= @From AND ToDate <= @To";
                    if (ddlStatusFilter.SelectedValue != "All")
                    {
                        query += " AND Status = @Status";
                    }
                    query += " ORDER BY ResDate DESC";

                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@From", DateTime.Parse(txtFromDate.Text));
                    cmd.Parameters.AddWithValue("@To", DateTime.Parse(txtToDate.Text));
                    if (ddlStatusFilter.SelectedValue != "All")
                    {
                        cmd.Parameters.AddWithValue("@Status", ddlStatusFilter.SelectedValue);
                    }

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvReservations.DataSource = dt;
                    gvReservations.DataBind();
                    lblRecordCount.Text = dt.Rows.Count.ToString();
                    lblFooterCount.Text = dt.Rows.Count.ToString();
                }
            }
            catch (Exception ex) { ShowMessage("Error: " + ex.Message, false); }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadReservations();
        }

        protected void gvReservations_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvReservations.PageIndex = e.NewPageIndex;
            LoadReservations();
        }

        protected void gvReservations_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string resNo = e.CommandArgument.ToString();
            if (e.CommandName == "Confirm")
            {
                UpdateStatus(resNo, "CONFIRMED");
            }
            else if (e.CommandName == "CheckIn")
            {
                // JavaScript handles the room selection dialog which eventually calls CompleteCheckIn
                // But for simple cases we might just trigger a status update if rooms are already allocated
            }
            else if (e.CommandName == "CancelRes")
            {
                CancelReservation(resNo);
            }
        }

        private void UpdateStatus(string resNo, string status)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = "UPDATE RoomReservations SET Status = @Status WHERE ReservationNo = @ResNo";
                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@Status", status);
                    cmd.Parameters.AddWithValue("@ResNo", resNo);
                    con.Open();
                    cmd.ExecuteNonQuery();
                    ShowMessage("Status updated to " + status, true);
                    LoadReservations();
                    LoadKPIs();
                }
            }
            catch (Exception ex) { ShowMessage("Error: " + ex.Message, false); }
        }

        private void CancelReservation(string resNo)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();
                    using (SqlTransaction trans = con.BeginTransaction())
                    {
                        try
                        {
                            // 1. Update Reservation Status
                            SqlCommand cmdRes = new SqlCommand("UPDATE RoomReservations SET Status = 'CANCELLED' WHERE ReservationNo = @ResNo", con, trans);
                            cmdRes.Parameters.AddWithValue("@ResNo", resNo);
                            cmdRes.ExecuteNonQuery();

                            // 2. Free Rooms in RoomDefinitionNew
                            SqlCommand cmdRoom = new SqlCommand(@"
                                UPDATE RoomDefinitionNew SET Status = 'Available' 
                                WHERE RoomNo IN (SELECT RoomNo FROM RoomAllocations WHERE ReservationNo = @ResNo)", con, trans);
                            cmdRoom.Parameters.AddWithValue("@ResNo", resNo);
                            cmdRoom.ExecuteNonQuery();

                            // 3. Mark Allocations as cancelled
                            SqlCommand cmdAlloc = new SqlCommand("UPDATE RoomAllocations SET CheckOutDate = GETDATE(), Remarks = 'CANCELLED' WHERE ReservationNo = @ResNo AND CheckOutDate IS NULL", con, trans);
                            cmdAlloc.Parameters.AddWithValue("@ResNo", resNo);
                            cmdAlloc.ExecuteNonQuery();

                            trans.Commit();
                            ShowMessage("Reservation " + resNo + " cancelled successfully.", true);
                            LoadReservations();
                            LoadKPIs();
                        }
                        catch { trans.Rollback(); throw; }
                    }
                }
            }
            catch (Exception ex) { ShowMessage("Error: " + ex.Message, false); }
        }

        protected void gvReservations_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                string resNo = gvReservations.DataKeys[e.Row.RowIndex].Value.ToString();
                string status = DataBinder.Eval(e.Row.DataItem, "Status").ToString().Trim().ToUpper();
                
                // Set button visibility based on status
                Button btnConfirm = (Button)e.Row.FindControl("btnConfirm");
                Button btnCheckIn = (Button)e.Row.FindControl("btnCheckIn");
                Button btnCancel = (Button)e.Row.FindControl("btnCancel");

                if (status == "PENDING")
                {
                    btnConfirm.Visible = true;
                    btnCheckIn.Visible = false;
                }
                else if (status == "CONFIRMED")
                {
                    btnConfirm.Visible = false;
                    btnCheckIn.Visible = true;
                }
                else
                {
                    btnConfirm.Visible = false;
                    btnCheckIn.Visible = false;
                }

                // Hide Cancel button if reservation is already Checked-in (Occupied/Availed) or Cancelled
                if (status == "CANCELLED" || status == "OCCUPIED" || status == "AVAILED" || status == "COMPLETED")
                {
                    btnCancel.Visible = false;
                }
                else
                {
                    btnCancel.Visible = true;
                }

                // Load Allocated Rooms
                Label lblAlloc = (Label)e.Row.FindControl("lblRoomAllocation");
                lblAlloc.Text = GetAllocatedRooms(resNo);
            }
        }

        private string GetAllocatedRooms(string resNo)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = "SELECT RoomNo FROM RoomAllocations WHERE ReservationNo = @ResNo";
                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@ResNo", resNo);
                    con.Open();
                    DataTable dt = new DataTable();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                    if (dt.Rows.Count > 0)
                    {
                        string rooms = "";
                        foreach (DataRow dr in dt.Rows) rooms += dr["RoomNo"].ToString() + ", ";
                        return rooms.TrimEnd(' ', ',');
                    }
                }
            }
            catch { }
            return "Not allocated";
        }

        public string GetStatusBadge(string status)
        {
            switch (status.ToUpper())
            {
                case "PENDING": return "background:#fff3e0; color:#e65100; border:1px solid #ffe0b2;";
                case "CONFIRMED": return "background:#e8f5e9; color:#2e7d32; border:1px solid #c8e6c9;";
                case "OCCUPIED": 
                case "AVAILED": return "background:#e3f2fd; color:#1565C0; border:1px solid #bbdefb;";
                case "CANCELLED": return "background:#ffebee; color:#c62828; border:1px solid #ffcdd2;";
                default: return "background:#f5f5f5; color:#757575; border:1px solid #e0e0e0;";
            }
        }

        [WebMethod]
        public static string GetAvailableRoomsList(int count)
        {
            string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;
            string rooms = "";
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "SELECT TOP (@Count) RoomNo FROM RoomDefinitionNew WHERE Status = 'Available' ORDER BY RoomNo";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@Count", count * 5); // Fetch more to give choice
                con.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read()) rooms += dr["RoomNo"].ToString() + ",";
                }
            }
            return rooms.TrimEnd(',');
        }

        [WebMethod]
        public static void CompleteCheckIn(string resNo, string roomNos)
        {
            string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;
            string[] rooms = roomNos.Split(',');
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                using (SqlTransaction trans = con.BeginTransaction())
                {
                    try
                    {
                        foreach (string room in rooms)
                        {
                            // 1. Create Allocation
                            SqlCommand cmdAlloc = new SqlCommand("INSERT INTO RoomAllocations (ReservationNo, RoomNo, AllocatedDate) VALUES (@Res, @Room, GETDATE())", con, trans);
                            cmdAlloc.Parameters.AddWithValue("@Res", resNo);
                            cmdAlloc.Parameters.AddWithValue("@Room", room);
                            cmdAlloc.ExecuteNonQuery();

                            // 2. Mark Room as Occupied
                            SqlCommand cmdRoom = new SqlCommand("UPDATE RoomDefinitionNew SET Status = 'Occupied' WHERE RoomNo = @Room", con, trans);
                            cmdRoom.Parameters.AddWithValue("@Room", room);
                            cmdRoom.ExecuteNonQuery();
                        }

                        // 3. Update Reservation Status
                        SqlCommand cmdRes = new SqlCommand("UPDATE RoomReservations SET Status = 'OCCUPIED' WHERE ReservationNo = @Res", con, trans);
                        cmdRes.Parameters.AddWithValue("@Res", resNo);
                        cmdRes.ExecuteNonQuery();

                        trans.Commit();
                    }
                    catch { trans.Rollback(); throw; }
                }
            }
        }

        private void ShowMessage(string msg, bool success)
        {
            lblMessage.Text = msg;
            lblMessage.Visible = true;
            lblMessage.CssClass = "alert " + (success ? "alert-success" : "alert-danger");
            lblMessage.Style["display"] = "block";
        }
    }
}



