using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GuestRoomApp.GuestRoomM
{
    public partial class RoomExtension : System.Web.UI.Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Initialize page
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string search = txtSearch.Text.Trim();
            if (string.IsNullOrEmpty(search))
            {
                ShowMessage("Please enter a Reservation or Receipt No.", false);
                return;
            }

            LoadReservation(search);
        }

        private void LoadReservation(string search)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string sql = @"
                        SELECT 
                            rr.ReservationNo, rr.GuestName, rr.FromDate, rr.ToDate, rr.NoOfRooms, rr.Status, rr.ReceiptNo,
                            STUFF((SELECT ', ' + RoomNo 
                                   FROM RoomAllocations 
                                   WHERE ReservationNo = rr.ReservationNo AND CheckOutDate IS NULL 
                                   FOR XML PATH('')), 1, 2, '') as AllocatedRooms
                        FROM RoomReservations rr
                        WHERE (rr.ReservationNo = @S OR rr.ReceiptNo = @S)
                        ORDER BY rr.FromDate DESC";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@S", search);
                        con.Open();
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                string status = dr["Status"].ToString();
                                if (status != "Occupied" && status != "Availed")
                                {
                                    ShowMessage("Extension is only available for 'Occupied' or 'Availed' rooms. Current status: " + status, false);
                                    pnlExtensionForm.Visible = false;
                                    return;
                                }

                                hfReservationNo.Value = dr["ReservationNo"].ToString();
                                lblGuestName.Text = dr["GuestName"].ToString();
                                lblFromDate.Text = Convert.ToDateTime(dr["FromDate"]).ToString("dd-MMM-yyyy");
                                lblToDate.Text = Convert.ToDateTime(dr["ToDate"]).ToString("dd-MMM-yyyy");
                                hfCurrentToDate.Value = Convert.ToDateTime(dr["ToDate"]).ToString("yyyy-MM-dd");
                                lblNoOfRooms.Text = dr["NoOfRooms"].ToString();
                                lblRooms.Text = dr["AllocatedRooms"] != DBNull.Value ? dr["AllocatedRooms"].ToString() : "Not Allocated";

                                pnlExtensionForm.Visible = true;
                                txtNewToDate.Text = "";
                                txtNewToDate.Attributes["min"] = Convert.ToDateTime(dr["ToDate"]).AddDays(1).ToString("yyyy-MM-dd");
                                txtAddNights.Text = "0";
                                btnExtendStay.Enabled = false;
                                PopulateRoomsDropdown(dr["ReservationNo"].ToString());
                                ShowMessage("Reservation loaded. Please select a new check-out date.", true);
                            }
                            else
                            {
                                ShowMessage("No active record found for: " + search, false);
                                pnlExtensionForm.Visible = false;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        protected void txtNewToDate_TextChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtNewToDate.Text) || string.IsNullOrEmpty(hfCurrentToDate.Value)) return;

            DateTime oldTo = DateTime.Parse(hfCurrentToDate.Value);
            DateTime newTo = DateTime.Parse(txtNewToDate.Text);

            if (newTo <= oldTo)
            {
                ShowMessage("New Check-Out date must be after the current one.", false);
                txtAddNights.Text = "0";
                btnExtendStay.Enabled = false;
                return;
            }

            int nightsFromToday = (newTo - DateTime.Today).Days;
            txtAddNights.Text = (newTo - oldTo).Days.ToString();
            btnExtendStay.Enabled = false; // Must check availability first

            if (nightsFromToday > 15)
            {
                ShowMessage("âš ï¸ Note: Total stay exceeds 15 nights from today. Manager Approval will be required.", true);
            }
            else
            {
                ShowMessage("âœ… Extension within 15 nights. This will be auto-approved after availability check.", true);
            }
        }

        protected void btnCheckAvailability_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtNewToDate.Text))
            {
                ShowMessage("Please select a new Check-Out date.", false);
                return;
            }

            DateTime oldTo = DateTime.Parse(hfCurrentToDate.Value);
            DateTime newTo = DateTime.Parse(txtNewToDate.Text);
            int requestedRooms = ddlRoomToExtend.SelectedValue == "ALL" ? int.Parse(lblNoOfRooms.Text) : 1;

            // Availability Logic:
            // Check availability from oldTo to newTo.
            // Since the guest is already in the room, they are already counted in 'Occupied' for today.
            // But for future dates (after oldTo), we need to see if enough rooms remain.
            
            bool isAvailable = CheckAvailability(oldTo, newTo, requestedRooms);

            if (isAvailable)
            {
                ShowMessage("âœ… Rooms are available for the extension period.", true);
                btnExtendStay.Enabled = true;
            }
            else
            {
                ShowMessage("âŒ Cannot extend stay. One or more rooms are already booked for the selected period.", false);
                btnExtendStay.Enabled = false;
            }
        }

        private bool CheckAvailability(DateTime fromDate, DateTime toDate, int neededCount)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();
                    // Similar to GetAvailableRoomsCount but we check the specific period
                    // and we exclude the current reservation from the 'Occupied' count for the check
                    // because we are checking if there is room for THIS reservation to CONTINUE.
                    
                    string sql = @"
                        DECLARE @TotalRooms INT;
                        SELECT @TotalRooms = COUNT(*) FROM RoomDefinitionNew WHERE UPPER(Status) != 'MAINTENANCE';

                        WITH DateRange AS (
                            SELECT @FromDate AS DateVal
                            UNION ALL
                            SELECT DATEADD(DAY, 1, DateVal)
                            FROM DateRange
                            WHERE DateVal < DATEADD(DAY, -1, @ToDate)
                        ),
                        DailyOccupancy AS (
                            SELECT 
                                d.DateVal,
                                (SELECT ISNULL(SUM(NoOfRooms), 0) FROM RoomReservations rr
                                 WHERE d.DateVal >= rr.FromDate AND d.DateVal < rr.ToDate
                                 AND UPPER(rr.Status) IN ('PENDING', 'CONFIRMED', 'OCCUPIED', 'AVAILED')
                                 AND rr.ReservationNo != @CurrentResNo -- EXCLUDE CURRENT SO WE KNOW IF WE CAN STAY
                                ) AS OtherBookings
                            FROM DateRange d
                        )
                        SELECT MIN(@TotalRooms - OtherBookings) FROM DailyOccupancy
                        OPTION (MAXRECURSION 366);";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@FromDate", fromDate.Date);
                        cmd.Parameters.AddWithValue("@ToDate", toDate.Date);
                        cmd.Parameters.AddWithValue("@CurrentResNo", hfReservationNo.Value);
                        
                        object res = cmd.ExecuteScalar();
                        int minAvailable = res != DBNull.Value ? Convert.ToInt32(res) : 0;
                        
                        return minAvailable >= neededCount;
                    }
                }
            }
            catch { return false; }
        }

        protected void btnExtendStay_Click(object sender, EventArgs e)
        {
            string resNo = hfReservationNo.Value;
            DateTime oldTo = DateTime.Parse(hfCurrentToDate.Value);
            DateTime newTo = DateTime.Parse(txtNewToDate.Text);
            string selectedRoom = ddlRoomToExtend.SelectedValue;
            int diff = (newTo - oldTo).Days;

            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();
                    SqlTransaction trans = con.BeginTransaction();

                    try
                    {
                        int nightsFromToday = (newTo - DateTime.Today).Days;

                        if (nightsFromToday <= 15)
                        {
                            // AUTO-APPROVE
                            // 1. Update Reservation
                            string sqlUpdate = @"UPDATE RoomReservations 
                                               SET ToDate = @NewTo, 
                                                   Remarks = ISNULL(Remarks, '') + CHAR(13) + @AppRemarks 
                                               WHERE ReservationNo = @ResNo AND Status IN ('Occupied', 'Availed')";
                            
                            using (SqlCommand cmdUpd = new SqlCommand(sqlUpdate, con, trans))
                            {
                                cmdUpd.Parameters.AddWithValue("@NewTo", newTo);
                                cmdUpd.Parameters.AddWithValue("@ResNo", resNo);
                                cmdUpd.Parameters.AddWithValue("@AppRemarks", "[AUTO-EXTENSION] until " + newTo.ToString("dd-MMM-yyyy") + ". Reason: " + txtRemarks.Text.Trim());
                                cmdUpd.ExecuteNonQuery();
                            }

                            // 2. Insert Approved Request Record
                            string sqlIns = @"INSERT INTO GR_RoomExtensionRequests 
                                           (ReservationNo, RoomNo, CurrentToDate, NewToDate, Remarks, Status, RequestDate, ApprovalDate, ApprovedBy) 
                                           VALUES (@ResNo, @RoomNo, @OldTo, @NewTo, @Remarks, 'Approved', GETDATE(), GETDATE(), 'Auto-System')";
                            using (SqlCommand cmdIns = new SqlCommand(sqlIns, con, trans))
                            {
                                cmdIns.Parameters.AddWithValue("@ResNo", resNo);
                                cmdIns.Parameters.AddWithValue("@RoomNo", selectedRoom);
                                cmdIns.Parameters.AddWithValue("@OldTo", oldTo);
                                cmdIns.Parameters.AddWithValue("@NewTo", newTo);
                                cmdIns.Parameters.AddWithValue("@Remarks", txtRemarks.Text.Trim());
                                cmdIns.ExecuteNonQuery();
                            }

                            trans.Commit();
                            ShowMessage("âœ… Extension applied successfully! (Auto-approved for stay up to 15 nights from today)", true);
                        }
                        else
                        {
                            // PENDING APPROVAL
                            string sql = @"INSERT INTO GR_RoomExtensionRequests 
                                           (ReservationNo, RoomNo, CurrentToDate, NewToDate, Remarks, Status, RequestDate) 
                                           VALUES (@ResNo, @RoomNo, @OldTo, @NewTo, @Remarks, 'Pending', GETDATE())";

                            using (SqlCommand cmd = new SqlCommand(sql, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@ResNo", resNo);
                                cmd.Parameters.AddWithValue("@RoomNo", selectedRoom);
                                cmd.Parameters.AddWithValue("@OldTo", oldTo);
                                cmd.Parameters.AddWithValue("@NewTo", newTo);
                                cmd.Parameters.AddWithValue("@Remarks", txtRemarks.Text.Trim());
                                cmd.ExecuteNonQuery();
                            }

                            trans.Commit();
                            string alertScript = "alert('This extension exceeds 15 nights from today and has been sent for Manager Approval.');";
                            ScriptManager.RegisterStartupScript(this, GetType(), "ManagerApprovalAlert", alertScript, true);
                            ShowMessage("ðŸ“‹ Request Submitted: Total stay > 15 nights requires Manager Approval.", true);
                        }

                        pnlExtensionForm.Visible = false;
                        txtSearch.Text = "";
                    }
                    catch (Exception ex)
                    {
                        if (trans.Connection != null) trans.Rollback();
                        ShowMessage("Error processing transaction: " + ex.Message, false);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Database connection error: " + ex.Message, false);
            }
        }


        private void PopulateRoomsDropdown(string resNo)
        {
            ddlRoomToExtend.Items.Clear();
            ddlRoomToExtend.Items.Add(new ListItem("All Rooms", "ALL"));

            using (SqlConnection con = new SqlConnection(connStr))
            {
                string sql = "SELECT RoomNo FROM RoomAllocations WHERE ReservationNo = @Res AND CheckOutDate IS NULL ORDER BY RoomNo";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@Res", resNo);
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string r = dr["RoomNo"].ToString();
                            ddlRoomToExtend.Items.Add(new ListItem("Room " + r, r));
                        }
                    }
                }
            }
        }

        private void ShowMessage(string msg, bool success)
        {
            lblMessage.Text = msg;
            lblMessage.CssClass = "alert show " + (success ? "alert-success" : "alert-error");
            
            // Register timeout for the JS alert
            ScriptManager.RegisterStartupScript(this, GetType(), "HideMsg", "setTimeout(function(){ document.getElementById('" + lblMessage.ClientID + "').style.display='none'; }, 7000);", true);
        }
    }
}





