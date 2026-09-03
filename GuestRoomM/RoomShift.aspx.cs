using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;
using System.Collections.Generic;

namespace GuestRoomApp.GuestRoomM
{
    public partial class RoomShift : System.Web.UI.Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtFromDate.Text = DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd");
                txtToDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                LoadOccupiedRooms();
                LoadShiftHistory();
            }
        }

        private void LoadOccupiedRooms()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = @"
                        SELECT DISTINCT a.RoomNo, a.ReservationNo, r.GuestName, r.GuestOf, r.FromDate, r.ToDate, a.AllocatedDate, a.LastChargedDate
                        FROM RoomAllocations a
                        INNER JOIN RoomReservations r ON a.ReservationNo = r.ReservationNo
                        WHERE a.CheckOutDate IS NULL ORDER BY a.RoomNo";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlOccupiedRooms.Items.Clear();
                    ddlOccupiedRooms.Items.Add(new ListItem("-- Select Room --", ""));
                    foreach (DataRow row in dt.Rows)
                    {
                        string lastCI = row["AllocatedDate"] != DBNull.Value ? Convert.ToDateTime(row["AllocatedDate"]).ToString("dd-MMM") : "N/A";
                        ddlOccupiedRooms.Items.Add(new ListItem(row["RoomNo"].ToString() + " (" + lastCI + ") - " + row["GuestName"].ToString(), row["RoomNo"].ToString()));
                    }
                }
            }
            catch (Exception ex) { ShowMessage("Error loading rooms: " + ex.Message, false); }
        }

        protected void ddlOccupiedRooms_SelectedIndexChanged(object sender, EventArgs e)
        {
            string roomNo = ddlOccupiedRooms.SelectedValue;
            if (string.IsNullOrEmpty(roomNo))
            {
                txtGuestDetails.Text = "";
                LoadAvailableRooms("");
                return;
            }
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = @"
                        SELECT a.ReservationNo, r.ReceiptNo, r.GuestName, r.GuestOf, r.FromDate, r.ToDate, r.NoOfRooms,
                                r.AdvancePayment, r.ReservationType, r.ClubName, r.Address, r.MobileNo, 
                                r.NIC, r.PassportNo, r.PassportIssueDate, r.PassportExpiryDate, r.Remarks,
                                a.AllocatedDate, a.LastChargedDate, rd.RoomType as OldRoomType
                        FROM RoomAllocations a
                        INNER JOIN RoomReservations r ON a.ReservationNo = r.ReservationNo
                        LEFT JOIN RoomDefinitionNew rd ON a.RoomNo = rd.RoomNo
                        WHERE a.RoomNo = @RoomNo AND a.CheckOutDate IS NULL";
                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@RoomNo", roomNo);
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            txtGuestDetails.Text = string.Format("{0} | Guest Of: {1} | Room: {2} ({3})\r\nLast Check-in: {4:dd-MMM-yy HH:mm} | Stay: {5:dd-MMM} to {6:dd-MMM}",
                                dr["GuestName"], dr["GuestOf"], roomNo, dr["OldRoomType"], dr["AllocatedDate"], dr["FromDate"], dr["ToDate"]);

                            ViewState["OldReservationNo"] = dr["ReservationNo"].ToString();
                            ViewState["ReceiptNo"] = dr["ReceiptNo"].ToString();
                            ViewState["GuestName"] = dr["GuestName"].ToString();
                            ViewState["OldAllocatedDate"] = dr["AllocatedDate"];
                            ViewState["OldLastChargedDate"] = dr["LastChargedDate"];
                            ViewState["OldRoomType"] = dr["OldRoomType"].ToString();

                            ViewState["GuestOf"] = dr["GuestOf"].ToString();
                            ViewState["FromDate"] = dr["FromDate"];
                            ViewState["ToDate"] = dr["ToDate"];
                            ViewState["NoOfRooms"] = dr["NoOfRooms"];
                            ViewState["AdvancePayment"] = dr["AdvancePayment"];
                            ViewState["ReservationType"] = dr["ReservationType"];
                            ViewState["ClubName"] = dr["ClubName"];
                            ViewState["Address"] = dr["Address"];
                            ViewState["MobileNo"] = dr["MobileNo"];
                            ViewState["NIC"] = dr["NIC"];
                            ViewState["PassportNo"] = dr["PassportNo"];
                            ViewState["PassportIssueDate"] = dr["PassportIssueDate"];
                            ViewState["PassportExpiryDate"] = dr["PassportExpiryDate"];
                            ViewState["Remarks"] = dr["Remarks"];
                        }
                    }
                }
                LoadAvailableRooms(roomNo);
            }
            catch (Exception ex) { ShowMessage("Error: " + ex.Message, false); }
        }

        private void LoadAvailableRooms(string currentRoomNo)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();
                    List<string> occupiedRooms = new List<string>();
                    using (SqlCommand cmdOcc = new SqlCommand("SELECT DISTINCT RoomNo FROM RoomAllocations WHERE CheckOutDate IS NULL", con))
                    using (SqlDataReader drOcc = cmdOcc.ExecuteReader())
                    {
                        while (drOcc.Read()) occupiedRooms.Add(drOcc["RoomNo"].ToString());
                    }

                    using (SqlCommand cmdAvail = new SqlCommand("SELECT RoomNo, RoomType FROM RoomDefinitionNew WHERE Status = 'Available' ORDER BY RoomNo", con))
                    using (SqlDataReader drAvail = cmdAvail.ExecuteReader())
                    {
                        ddlAvailableRooms.Items.Clear();
                        ddlAvailableRooms.Items.Add(new ListItem("-- Select New Room --", ""));
                        int count = 0;
                        while (drAvail.Read())
                        {
                            string roomNo = drAvail["RoomNo"].ToString();
                            if (roomNo != currentRoomNo && !occupiedRooms.Contains(roomNo))
                            {
                                ddlAvailableRooms.Items.Add(new ListItem(roomNo + " (" + drAvail["RoomType"] + ")", roomNo));
                                count++;
                            }
                        }
                        if (count == 0)
                        {
                            ddlAvailableRooms.Items.Add(new ListItem("-- No Available Rooms --", ""));
                            ShowMessage("No available rooms for shift.", false);
                        }
                    }
                }
            }
            catch (Exception ex) { ShowMessage("Error loading available rooms: " + ex.Message, false); }
        }

        protected void btnShiftRoom_Click(object sender, EventArgs e)
        {
            string oldRoomNo = ddlOccupiedRooms.SelectedValue;
            string newRoomNo = ddlAvailableRooms.SelectedValue;
            string reason = ddlShiftReason.SelectedValue;
            string remarks = txtShiftRemarks.Text.Trim();
            string oldResNo = ViewState["OldReservationNo"] as string;

            if (string.IsNullOrEmpty(oldRoomNo) || string.IsNullOrEmpty(newRoomNo) || string.IsNullOrEmpty(reason) || string.IsNullOrEmpty(oldResNo))
            {
                ShowMessage("Please check selection and try again.", false);
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();
                    using (SqlTransaction trans = con.BeginTransaction())
                    {
                        try
                        {
                            // 0. Catch-up Rent for OLD Room (up to Yesterday)
                            DateTime oldAllocDate = ViewState["OldAllocatedDate"] != null ? Convert.ToDateTime(ViewState["OldAllocatedDate"]) : DateTime.Now;
                            DateTime oldLastCharged = ViewState["OldLastChargedDate"] != DBNull.Value && ViewState["OldLastChargedDate"] != null
                                ? Convert.ToDateTime(ViewState["OldLastChargedDate"]) : oldAllocDate.Date;

                            DateTime yesterday = DateTime.Now.Date.AddDays(-1);
                            DateTime processDate = oldLastCharged.Date;

                            // Fetch Old Room Rate info
                            decimal oldRent = 0, oldTaxPct = 0;
                            SqlCommand cmdOldRate = new SqlCommand("SELECT Rent, TaxPercentage FROM RoomDefinitionNew WHERE RoomNo = @R", con, trans);
                            cmdOldRate.Parameters.AddWithValue("@R", oldRoomNo);
                            using (SqlDataReader drOldRate = cmdOldRate.ExecuteReader())
                            {
                                if (drOldRate.Read())
                                {
                                    oldRent = drOldRate["Rent"] != DBNull.Value ? Convert.ToDecimal(drOldRate["Rent"]) : 0;
                                    oldTaxPct = drOldRate["TaxPercentage"] != DBNull.Value ? Convert.ToDecimal(drOldRate["TaxPercentage"]) : 0;
                                }
                            }

                            // Loop through missed days up to Yesterday
                            while (processDate < yesterday)
                            {
                                processDate = processDate.AddDays(1);
                                string dateStr = processDate.ToString("dd-MMM");
                                string invoiceNo = "AUTO-SHIFT-" + DateTime.Now.ToString("yyyyMMddHHmmss");

                                // Insert Room Rent for missed day - FIXED: Removed TotalAmount
                                SqlCommand cmdSRentOld = new SqlCommand(@"INSERT INTO GR_RoomServices (ReservationNo, RoomNo, ServiceName, Qty, UnitPrice, TaxPercentage, TaxAmount, Status, OrderDate, InvoiceNo) VALUES (@ResNo, @RoomNo, @ServiceName, 1, @Price, 0, 0, 'Pending', GETDATE(), @Invoice)", con, trans);
                                cmdSRentOld.Parameters.AddWithValue("@ResNo", oldResNo);
                                cmdSRentOld.Parameters.AddWithValue("@RoomNo", oldRoomNo);
                                cmdSRentOld.Parameters.AddWithValue("@ServiceName", "Room Rent (Automatic) - " + dateStr);
                                cmdSRentOld.Parameters.AddWithValue("@Price", oldRent);
                                cmdSRentOld.Parameters.AddWithValue("@Invoice", invoiceNo);
                                cmdSRentOld.ExecuteNonQuery();

                                // Insert Tax for missed day if applicable - FIXED: Removed TotalAmount
                                if (oldTaxPct > 0)
                                {
                                    decimal taxAmt = Math.Round(oldRent * oldTaxPct / 100, 2);
                                    SqlCommand cmdSTaxOld = new SqlCommand(@"INSERT INTO GR_RoomServices (ReservationNo, RoomNo, ServiceName, Qty, UnitPrice, TaxPercentage, TaxAmount, Status, OrderDate, InvoiceNo) VALUES (@ResNo, @RoomNo, @ServiceName, 1, @Price, @TaxPct, @TaxAmt, 'Pending', GETDATE(), @Invoice)", con, trans);
                                    cmdSTaxOld.Parameters.AddWithValue("@ResNo", oldResNo);
                                    cmdSTaxOld.Parameters.AddWithValue("@RoomNo", oldRoomNo);
                                    cmdSTaxOld.Parameters.AddWithValue("@ServiceName", "GST on Room Rent - " + dateStr);
                                    cmdSTaxOld.Parameters.AddWithValue("@Price", taxAmt);
                                    cmdSTaxOld.Parameters.AddWithValue("@TaxPct", oldTaxPct);
                                    cmdSTaxOld.Parameters.AddWithValue("@TaxAmt", taxAmt);
                                    cmdSTaxOld.Parameters.AddWithValue("@Invoice", invoiceNo);
                                    cmdSTaxOld.ExecuteNonQuery();
                                }
                            }

                            // Check if old room was charged TODAY
                            bool oldChargedToday = (processDate.Date == DateTime.Now.Date || oldLastCharged.Date == DateTime.Now.Date);

                            // 1. Create New Room Allocation
                            SqlCommand cmdNewAlloc = new SqlCommand(@"
                                INSERT INTO RoomAllocations (
                                    ReservationNo, RoomNo, AllocatedDate, LastChargedDate, 
                                    GuestAddress, CNIC_Passport, Country, RFIDCardNo, RFIDDeactive,
                                    Men, Women, Child, NoOfGuests, DriverName, DriverStay, VehicleNo, 
                                    CheckInBy, StayFactor, ApplyFacilityCharges, Remarks
                                ) 
                                SELECT 
                                    ReservationNo, @NewRoomNo, GETDATE(), @NewLastCharged,
                                    GuestAddress, CNIC_Passport, Country, RFIDCardNo, RFIDDeactive,
                                    Men, Women, Child, NoOfGuests, DriverName, DriverStay, VehicleNo, 
                                    CheckInBy, StayFactor, ApplyFacilityCharges,
                                    'Shifted from Room: ' + @OldRoomNo + ' | ' + ISNULL(Remarks,'')
                                FROM RoomAllocations 
                                WHERE ReservationNo = @OldResNo AND RoomNo = @OldRoomNo AND CheckOutDate IS NULL", con, trans);

                            cmdNewAlloc.Parameters.AddWithValue("@OldResNo", oldResNo);
                            cmdNewAlloc.Parameters.AddWithValue("@NewRoomNo", newRoomNo);
                            cmdNewAlloc.Parameters.AddWithValue("@OldRoomNo", oldRoomNo);
                            cmdNewAlloc.Parameters.AddWithValue("@NewLastCharged", oldChargedToday ? DateTime.Now.Date : yesterday);
                            cmdNewAlloc.ExecuteNonQuery();

                            // Get new room details
                            decimal newRent = 0, newTaxPct = 0;
                            string newRoomType = "";
                            SqlCommand cmdRate = new SqlCommand("SELECT Rent, TaxPercentage, RoomType FROM RoomDefinitionNew WHERE RoomNo = @R", con, trans);
                            cmdRate.Parameters.AddWithValue("@R", newRoomNo);
                            using (SqlDataReader drRate = cmdRate.ExecuteReader())
                            {
                                if (drRate.Read())
                                {
                                    newRent = drRate["Rent"] != DBNull.Value ? Convert.ToDecimal(drRate["Rent"]) : 0;
                                    newTaxPct = drRate["TaxPercentage"] != DBNull.Value ? Convert.ToDecimal(drRate["TaxPercentage"]) : 0;
                                    newRoomType = drRate["RoomType"].ToString();
                                }
                            }
                            ViewState["NewRoomType"] = newRoomType;

                            // 1.5 Post Initial Rent for NEW room if OLD room wasn't charged today
                            if (!oldChargedToday)
                            {
                                if (newRent > 0)
                                {
                                    string dateStr = DateTime.Now.ToString("dd-MMM");
                                    string invoiceNo = "AUTO-SHIFT-" + DateTime.Now.ToString("yyyyMMddHHmmss");

                                    // Insert Room Rent for new room - FIXED: Removed TotalAmount
                                    SqlCommand cmdSRent = new SqlCommand(@"INSERT INTO GR_RoomServices (ReservationNo, RoomNo, ServiceName, Qty, UnitPrice, TaxPercentage, TaxAmount, Status, OrderDate, InvoiceNo) VALUES (@ResNo, @RoomNo, @ServiceName, 1, @Price, 0, 0, 'Pending', GETDATE(), @Invoice)", con, trans);
                                    cmdSRent.Parameters.AddWithValue("@ResNo", oldResNo);
                                    cmdSRent.Parameters.AddWithValue("@RoomNo", newRoomNo);
                                    cmdSRent.Parameters.AddWithValue("@ServiceName", "Room Rent (Automatic) - " + dateStr);
                                    cmdSRent.Parameters.AddWithValue("@Price", newRent);
                                    cmdSRent.Parameters.AddWithValue("@Invoice", invoiceNo);
                                    cmdSRent.ExecuteNonQuery();

                                    // Insert Tax for new room if applicable - FIXED: Removed TotalAmount
                                    if (newTaxPct > 0)
                                    {
                                        decimal taxAmt = Math.Round(newRent * newTaxPct / 100, 2);
                                        SqlCommand cmdSTax = new SqlCommand(@"INSERT INTO GR_RoomServices (ReservationNo, RoomNo, ServiceName, Qty, UnitPrice, TaxPercentage, TaxAmount, Status, OrderDate, InvoiceNo) VALUES (@ResNo, @RoomNo, @ServiceName, 1, @Price, @TaxPct, @TaxAmt, 'Pending', GETDATE(), @Invoice)", con, trans);
                                        cmdSTax.Parameters.AddWithValue("@ResNo", oldResNo);
                                        cmdSTax.Parameters.AddWithValue("@RoomNo", newRoomNo);
                                        cmdSTax.Parameters.AddWithValue("@ServiceName", "GST on Room Rent - " + dateStr);
                                        cmdSTax.Parameters.AddWithValue("@Price", taxAmt);
                                        cmdSTax.Parameters.AddWithValue("@TaxPct", newTaxPct);
                                        cmdSTax.Parameters.AddWithValue("@TaxAmt", taxAmt);
                                        cmdSTax.Parameters.AddWithValue("@Invoice", invoiceNo);
                                        cmdSTax.ExecuteNonQuery();
                                    }

                                    // Update New Room's LastChargedDate to Today since we just charged it
                                    SqlCommand cmdUpdNewCharged = new SqlCommand("UPDATE RoomAllocations SET LastChargedDate = CAST(GETDATE() AS DATE) WHERE ReservationNo = @Res AND RoomNo = @Room AND CheckOutDate IS NULL", con, trans);
                                    cmdUpdNewCharged.Parameters.AddWithValue("@Res", oldResNo);
                                    cmdUpdNewCharged.Parameters.AddWithValue("@Room", newRoomNo);
                                    cmdUpdNewCharged.ExecuteNonQuery();
                                }
                            }

                            // 2. Close Old Room Allocation
                            SqlCommand cmdOldAlloc = new SqlCommand(@"UPDATE RoomAllocations SET CheckOutDate = GETDATE(), LastChargedDate = @LCD, Remarks = 'Shifted to: ' + @NewRoomNo + ' | Reason: ' + @Reason WHERE ReservationNo = @OldResNo AND RoomNo = @OldRoomNo AND CheckOutDate IS NULL", con, trans);
                            cmdOldAlloc.Parameters.AddWithValue("@NewRoomNo", newRoomNo);
                            cmdOldAlloc.Parameters.AddWithValue("@OldResNo", oldResNo);
                            cmdOldAlloc.Parameters.AddWithValue("@OldRoomNo", oldRoomNo);
                            cmdOldAlloc.Parameters.AddWithValue("@Reason", reason);
                            cmdOldAlloc.Parameters.AddWithValue("@LCD", oldChargedToday ? DateTime.Now.Date : yesterday);
                            cmdOldAlloc.ExecuteNonQuery();

                            // 3. Mark Old Room as Dirty
                            //SqlCommand cmdOldRoom = new SqlCommand("UPDATE RoomDefinitionNew SET Status = 'Dirty' WHERE RoomNo = @OldRoomNo", con, trans);
                            //cmdOldRoom.Parameters.AddWithValue("@OldRoomNo", oldRoomNo);
                            //cmdOldRoom.ExecuteNonQuery();


                            // 3. Mark Old Room as Dirty or Maintenance
                            string newStatus = (reason == "Maintenance Issue" || reason == "Cleaning" || reason == "Management") ? "Maintenance" : "Dirty";
                            SqlCommand cmdOldRoom = new SqlCommand("UPDATE RoomDefinitionNew SET Status = @NewStatus WHERE RoomNo = @OldRoomNo", con, trans);
                            cmdOldRoom.Parameters.AddWithValue("@NewStatus", newStatus);
                            cmdOldRoom.Parameters.AddWithValue("@OldRoomNo", oldRoomNo);
                            cmdOldRoom.ExecuteNonQuery();

                            // 4. Mark New Room as Occupied
                            SqlCommand cmdNewRoom = new SqlCommand("UPDATE RoomDefinitionNew SET Status = 'Occupied' WHERE RoomNo = @NewRoomNo", con, trans);
                            cmdNewRoom.Parameters.AddWithValue("@NewRoomNo", newRoomNo);
                            cmdNewRoom.ExecuteNonQuery();

                            // 5. Log the Shift
                            SqlCommand cmdLog = new SqlCommand(@"INSERT INTO GR_RoomShiftLog (ReservationNo, NewReservationNo, GuestName, OldRoomNo, NewRoomNo, ShiftReason, Remarks, ShiftedBy, LastCheckIn, OldRoomType, NewRoomType) VALUES (@OldResNo, @OldResNo, @GuestName, @OldRoomNo, @NewRoomNo, @Reason, @Remarks, @User, @LastCI, @OldType, @NewType)", con, trans);
                            cmdLog.Parameters.AddWithValue("@OldResNo", oldResNo);
                            cmdLog.Parameters.AddWithValue("@GuestName", ViewState["GuestName"] ?? "");
                            cmdLog.Parameters.AddWithValue("@OldRoomNo", oldRoomNo);
                            cmdLog.Parameters.AddWithValue("@NewRoomNo", newRoomNo);
                            cmdLog.Parameters.AddWithValue("@Reason", reason);
                            cmdLog.Parameters.AddWithValue("@Remarks", remarks);
                            string empId = Session["Emp_ID"] != null ? Session["Emp_ID"].ToString() : "";
                            cmdLog.Parameters.AddWithValue("@User", empId);
                            cmdLog.Parameters.AddWithValue("@LastCI", ViewState["OldAllocatedDate"] ?? DBNull.Value);
                            cmdLog.Parameters.AddWithValue("@OldType", ViewState["OldRoomType"] ?? "");
                            cmdLog.Parameters.AddWithValue("@NewType", ViewState["NewRoomType"] ?? "");
                            cmdLog.ExecuteNonQuery();

                            trans.Commit();
                            ShowMessage("Room shifted successfully! Billing consolidated under Reservation: " + oldResNo, true);

                            // UI Reset
                            ddlOccupiedRooms.SelectedIndex = 0;
                            ddlAvailableRooms.Items.Clear();
                            txtGuestDetails.Text = "";
                            txtShiftRemarks.Text = "";
                            LoadOccupiedRooms();
                            LoadShiftHistory();
                        }
                        catch (Exception ex)
                        {
                            trans.Rollback();
                            throw ex;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error during room shift: " + ex.Message, false);
            }
        }

        private void LoadShiftHistory()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = @"SELECT * FROM GR_RoomShiftLog WHERE CAST(ShiftDate AS DATE) BETWEEN @From AND @To ORDER BY ShiftDate DESC";
                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@From", DateTime.Parse(txtFromDate.Text));
                    cmd.Parameters.AddWithValue("@To", DateTime.Parse(txtToDate.Text));
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvShiftHistory.DataSource = dt;
                    gvShiftHistory.DataBind();
                    lblRecordCount.Text = dt.Rows.Count.ToString();
                }
            }
            catch (Exception ex)
            {
                // Silent fail for history load
                System.Diagnostics.Debug.WriteLine("Error loading history: " + ex.Message);
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadShiftHistory();
        }

        protected void gvShiftHistory_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvShiftHistory.PageIndex = e.NewPageIndex;
            LoadShiftHistory();
        }

        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = @"SELECT ShiftDate, GuestName, OldRoomNo, NewRoomNo, OldRoomType, NewRoomType, LastCheckIn, ShiftReason, Remarks, ShiftedBy 
                                    FROM GR_RoomShiftLog 
                                    WHERE CAST(ShiftDate AS DATE) BETWEEN @From AND @To 
                                    ORDER BY ShiftDate DESC";

                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@From", DateTime.Parse(txtFromDate.Text));
                    cmd.Parameters.AddWithValue("@To", DateTime.Parse(txtToDate.Text));

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    con.Open();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        Response.Clear();
                        Response.ContentType = "application/vnd.ms-excel";
                        Response.AddHeader("Content-Disposition", "attachment;filename=RoomShiftReport_" + DateTime.Now.ToString("yyyyMMddHHmmss") + ".xls");
                        Response.ContentEncoding = System.Text.Encoding.UTF8;

                        Response.Write("<table border='1'>");
                        Response.Write("<tr>");
                        Response.Write("<th>S.No</th>");
                        Response.Write("<th>Shift Date</th>");
                        Response.Write("<th>Guest Name</th>");
                        Response.Write("<th>From Room</th>");
                        Response.Write("<th>Old Type</th>");
                        Response.Write("<th>To Room</th>");
                        Response.Write("<th>New Type</th>");
                        Response.Write("<th>Last Check-in</th>");
                        Response.Write("<th>Reason</th>");
                        Response.Write("<th>Remarks</th>");
                        Response.Write("<th>Shifted By</th>");
                        Response.Write("</tr>");

                        int sno = 1;
                        foreach (DataRow row in dt.Rows)
                        {
                            Response.Write("<tr>");
                            Response.Write("<td>" + sno++ + "</td>");
                            Response.Write("<td>" + Convert.ToDateTime(row["ShiftDate"]).ToString("dd-MMM-yyyy HH:mm") + "</td>");
                            Response.Write("<td>" + row["GuestName"].ToString() + "</td>");
                            Response.Write("<td>" + row["OldRoomNo"].ToString() + "</td>");
                            Response.Write("<td>" + row["OldRoomType"].ToString() + "</td>");
                            Response.Write("<td>" + row["NewRoomNo"].ToString() + "</td>");
                            Response.Write("<td>" + row["NewRoomType"].ToString() + "</td>");
                            Response.Write("<td>" + (row["LastCheckIn"] != DBNull.Value ? Convert.ToDateTime(row["LastCheckIn"]).ToString("dd-MMM-yyyy") : "N/A") + "</td>");
                            Response.Write("<td>" + row["ShiftReason"].ToString() + "</td>");
                            Response.Write("<td>" + row["Remarks"].ToString() + "</td>");
                            Response.Write("<td>" + row["ShiftedBy"].ToString() + "</td>");
                            Response.Write("</tr>");
                        }
                        Response.Write("</table>");
                        Response.End();
                    }
                    else
                    {
                        ShowMessage("No data found to export.", false);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error exporting to Excel: " + ex.Message, false);
            }
        }

        private void ShowMessage(string msg, bool success)
        {
            lblMessage.Text = msg;
            lblMessage.CssClass = "alert show " + (success ? "alert-success" : "alert-error");
        }
    }
}



