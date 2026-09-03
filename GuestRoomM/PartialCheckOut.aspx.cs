using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
namespace GuestRoomApp.GuestRoomM
{
    public partial class PartialCheckOut : System.Web.UI.Page
    {
    private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadOccupiedRooms();
            }
        }

        private void LoadOccupiedRooms()
        {
            try
            {
                DataTable dtReservations = new DataTable();
                dtReservations.Columns.Add("ReservationNo", typeof(string));
                dtReservations.Columns.Add("GuestName", typeof(string));
                dtReservations.Columns.Add("TotalBookedRooms", typeof(int));
                dtReservations.Columns.Add("RentPerRoom", typeof(decimal));
                dtReservations.Columns.Add("Rooms", typeof(object));

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();
                    string query = @"
                        SELECT DISTINCT 
                            a.ReservationNo, 
                            r.GuestName,
                            r.NoOfRooms AS TotalBookedRooms
                        FROM RoomAllocations a
                        INNER JOIN RoomReservations r ON a.ReservationNo = r.ReservationNo
                        WHERE a.CheckOutDate IS NULL
                        ORDER BY a.ReservationNo";

                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dtMain = new DataTable();
                    da.Fill(dtMain);

                    foreach (DataRow mainRow in dtMain.Rows)
                    {
                        string reservationNo = mainRow["ReservationNo"].ToString();
                        string guestName = mainRow["GuestName"].ToString();
                        int totalRooms = Convert.ToInt32(mainRow["TotalBookedRooms"]);

                        DataTable dtRooms = new DataTable();
                        dtRooms.Columns.Add("RoomNo", typeof(string));
                        dtRooms.Columns.Add("ReservationNo", typeof(string));

                        string roomsQuery = @"
                            SELECT a.RoomNo, a.ReservationNo, rd.Rent 
                            FROM RoomAllocations a
                            INNER JOIN RoomDefinitionNew rd ON a.RoomNo = rd.RoomNo
                            WHERE a.ReservationNo = @ResNo AND a.CheckOutDate IS NULL";
                        SqlDataAdapter daRooms = new SqlDataAdapter(roomsQuery, con);
                        daRooms.SelectCommand.Parameters.AddWithValue("@ResNo", reservationNo);
                        daRooms.Fill(dtRooms);

                        DataRow row = dtReservations.NewRow();
                        row["ReservationNo"] = reservationNo;
                        row["GuestName"] = guestName;
                        row["TotalBookedRooms"] = totalRooms;
                        
                        // Use the rent of the first room as the reference rate for the reservation
                        row["RentPerRoom"] = dtRooms.Rows.Count > 0 ? Convert.ToDecimal(dtRooms.Rows[0]["Rent"]) : 0;
                        
                        row["Rooms"] = dtRooms;
                        dtReservations.Rows.Add(row);
                    }
                }

                if (dtReservations.Rows.Count > 0)
                {
                    rptReservations.DataSource = dtReservations;
                    rptReservations.DataBind();
                    pnlEmpty.Visible = false;

                    int totalOccupied = 0;
                    foreach (DataRow row in dtReservations.Rows)
                    {
                        totalOccupied += Convert.ToInt32(row["TotalBookedRooms"]);
                    }
                    lblOccupiedCount.Text = totalOccupied.ToString();
                }
                else
                {
                    pnlEmpty.Visible = true;
                    lblOccupiedCount.Text = "0";
                    rptReservations.DataSource = null;
                    rptReservations.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        protected void rptReservations_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "FullCheckOut")
            {
                string resNo = e.CommandArgument.ToString();
                Response.Redirect("RoomCheckOut.aspx?ResNo=" + resNo);
            }
        }

        // THIS IS THE MISSING METHOD - Add this method
        protected void btnConfirmPartial_Click(object sender, EventArgs e)
        {
            try
            {
                string reservationNo = hfReservationNo.Value;
                string selectedRooms = hfSelectedRooms.Value;
                string reason = ddlReason.SelectedValue;
                string remarks = txtRemarks.Text.Trim();

                // Validate inputs
                if (string.IsNullOrEmpty(reservationNo))
                {
                    ShowMessage("No reservation selected.", false);
                    return;
                }

                if (string.IsNullOrEmpty(selectedRooms))
                {
                    ShowMessage("No rooms selected for checkout.", false);
                    return;
                }

                string[] roomsToRelease = selectedRooms.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

                if (roomsToRelease.Length == 0)
                {
                    ShowMessage("No valid rooms selected.", false);
                    return;
                }

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();
                    using (SqlTransaction trans = con.BeginTransaction())
                    {
                        try
                        {
                            decimal factor = Convert.ToDecimal(ddlStayType.SelectedValue);
                            string stayLabel = factor == 0.5m ? "Half Day" : "Full Day";

                            // Process each selected room
                            foreach (string roomNo in roomsToRelease)
                            {
                                string cleanRoomNo = roomNo.Trim();
                                
                                // Fetch daily rate for THIS specific room from RoomDefinitionNew
                                decimal roomRent = 0;
                                using (SqlCommand cmdRate = new SqlCommand("SELECT Rent FROM RoomDefinitionNew WHERE RoomNo = @RoomNo", con, trans))
                                {
                                    cmdRate.Parameters.AddWithValue("@RoomNo", cleanRoomNo);
                                    object rateObj = cmdRate.ExecuteScalar();
                                    if (rateObj != null) roomRent = Convert.ToDecimal(rateObj);
                                }

                                decimal chargeAmount = roomRent * factor;

                                // Explicitly record the 50% rent and GST to the Ledger (GR_RoomServices) for Half Day checkout
                                if (factor == 0.5m)
                                {
                                    // 1. Void any existing 'Full Day' or 'Automatic' rent entries for TODAY to prevent double charging
                                    string qVoid = @"UPDATE GR_RoomServices 
                                                   SET Status = 'Void'
                                                   WHERE ReservationNo = @ResNo AND RoomNo = @RoomNo 
                                                   AND ServiceName LIKE 'Room Rent (Automatic)%' 
                                                   AND CAST(OrderDate AS DATE) = CAST(GETDATE() AS DATE)
                                                   AND Status != 'Void'";
                                    using (SqlCommand cmdVoid = new SqlCommand(qVoid, con, trans))
                                    {
                                        cmdVoid.Parameters.AddWithValue("@ResNo", reservationNo);
                                        cmdVoid.Parameters.AddWithValue("@RoomNo", cleanRoomNo);
                                        cmdVoid.ExecuteNonQuery();
                                    }

                                    // Also void existing GST for today
                                    string qVoidGst = @"UPDATE GR_RoomServices 
                                                      SET Status = 'Void'
                                                      WHERE ReservationNo = @ResNo AND RoomNo = @RoomNo 
                                                      AND ServiceName LIKE 'GST on Room Rent%' 
                                                      AND CAST(OrderDate AS DATE) = CAST(GETDATE() AS DATE)
                                                      AND Status != 'Void'";
                                    using (SqlCommand cmdVoidGst = new SqlCommand(qVoidGst, con, trans))
                                    {
                                        cmdVoidGst.Parameters.AddWithValue("@ResNo", reservationNo);
                                        cmdVoidGst.Parameters.AddWithValue("@RoomNo", cleanRoomNo);
                                        cmdVoidGst.ExecuteNonQuery();
                                    }

                                    decimal taxPct = 0;
                                    using (SqlCommand cmdTax = new SqlCommand("SELECT TaxPercentage FROM RoomDefinitionNew WHERE RoomNo = @RoomNo", con, trans))
                                    {
                                        cmdTax.Parameters.AddWithValue("@RoomNo", cleanRoomNo);
                                        object taxObj = cmdTax.ExecuteScalar();
                                        if (taxObj != null && taxObj != DBNull.Value) taxPct = Convert.ToDecimal(taxObj);
                                    }

                                    decimal taxAmt = Math.Round(chargeAmount * taxPct / 100, 2);
                                    string invoiceNo = "AUTO-" + DateTime.Now.ToString("yyyyMMddHHmm");

                                    string qRent = @"INSERT INTO GR_RoomServices (ReservationNo, RoomNo, ServiceName, Qty, UnitPrice, TaxPercentage, TaxAmount, Status, OrderDate, InvoiceNo) 
                                                   VALUES (@ResNo, @RoomNo, 'Room Rent (Automatic) - Half Day', 1, @Price, 0, 0, 'Pending', GETDATE(), @Invoice)";
                                    using (SqlCommand cmdRent = new SqlCommand(qRent, con, trans))
                                    {
                                        cmdRent.Parameters.AddWithValue("@ResNo", reservationNo);
                                        cmdRent.Parameters.AddWithValue("@RoomNo", cleanRoomNo);
                                        cmdRent.Parameters.AddWithValue("@Price", chargeAmount);
                                        cmdRent.Parameters.AddWithValue("@Invoice", invoiceNo);
                                        cmdRent.ExecuteNonQuery();
                                    }

                                    if (taxAmt > 0)
                                    {
                                        string qTax = @"INSERT INTO GR_RoomServices (ReservationNo, RoomNo, ServiceName, Qty, UnitPrice, TaxPercentage, TaxAmount, Status, OrderDate, InvoiceNo) 
                                                       VALUES (@ResNo, @RoomNo, 'GST on Room Rent - Half Day', 1, @Price, @TaxPct, @Price, 'Pending', GETDATE(), @Invoice)";
                                        using (SqlCommand cmdTax2 = new SqlCommand(qTax, con, trans))
                                        {
                                            cmdTax2.Parameters.AddWithValue("@ResNo", reservationNo);
                                            cmdTax2.Parameters.AddWithValue("@RoomNo", cleanRoomNo);
                                            cmdTax2.Parameters.AddWithValue("@Price", taxAmt);
                                            cmdTax2.Parameters.AddWithValue("@TaxPct", taxPct);
                                            cmdTax2.Parameters.AddWithValue("@Invoice", invoiceNo);
                                            cmdTax2.ExecuteNonQuery();
                                        }
                                    }
                                }

                                // 2. Update RoomAllocations - set checkout date and stay factor
                                string updateAllocationQuery = @"
                                    UPDATE RoomAllocations 
                                    SET CheckOutDate = GETDATE(), RFIDDeactive = 'Yes', StayFactor = @Factor,
                                        LastChargedDate = GETDATE()
                                    WHERE RoomNo = @RoomNo 
                                    AND ReservationNo = @ReservationNo 
                                    AND CheckOutDate IS NULL";
                                
                                using (SqlCommand cmd = new SqlCommand(updateAllocationQuery, con, trans))
                                {
                                    cmd.Parameters.AddWithValue("@Factor", factor);
                                    cmd.Parameters.AddWithValue("@RoomNo", cleanRoomNo);
                                    cmd.Parameters.AddWithValue("@ReservationNo", reservationNo);
                                    cmd.ExecuteNonQuery();
                                }

                                // 3. Update Room status to Dirty
                                string updateRoomQuery = "UPDATE RoomDefinitionNew SET Status = 'Dirty' WHERE RoomNo = @RoomNo";
                                using (SqlCommand cmd = new SqlCommand(updateRoomQuery, con, trans))
                                {
                                    cmd.Parameters.AddWithValue("@RoomNo", cleanRoomNo);
                                    cmd.ExecuteNonQuery();
                                }

                                // 4. Release one RoomReservations row to Completed to update Availability properly
                                // We order by ToDate ASC so that if some rooms were extended, we cancel the un-extended ones first.
                                string updateResQuery = @"
                                    WITH cte AS (
                                        SELECT TOP 1 Status
                                        FROM RoomReservations
                                        WHERE ReservationNo = @ReservationNo 
                                        AND UPPER(LTRIM(RTRIM(Status))) IN ('OCCUPIED', 'AVAILED')
                                        ORDER BY ToDate ASC
                                    )
                                    UPDATE cte SET Status = 'Completed'";
                                using (SqlCommand cmd = new SqlCommand(updateResQuery, con, trans))
                                {
                                    cmd.Parameters.AddWithValue("@ReservationNo", reservationNo);
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            trans.Commit();

                            string redirectUrl = string.Format("ManageBills.aspx?ResNo={0}&AutoOpen=true", reservationNo);
                            ScriptManager.RegisterStartupScript(this, GetType(), "redirect", "window.location.href='" + redirectUrl + "';", true);
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
                ShowMessage("Check-out error: " + ex.Message, false);
            }
        }


        private void ShowMessage(string msg, bool success)
        {
            lblMessage.Text = msg;
            lblMessage.Visible = true;

            if (success)
            {
                lblMessage.ForeColor = System.Drawing.Color.Green;
                lblMessage.Style.Add("background-color", "#d4edda");
                lblMessage.Style.Add("padding", "12px");
                lblMessage.Style.Add("border-radius", "8px");
                lblMessage.Style.Add("margin-bottom", "20px");
                lblMessage.Style.Add("display", "block");
            }
            else
            {
                lblMessage.ForeColor = System.Drawing.Color.Red;
                lblMessage.Style.Add("background-color", "#f8d7da");
                lblMessage.Style.Add("padding", "12px");
                lblMessage.Style.Add("border-radius", "8px");
                lblMessage.Style.Add("margin-bottom", "20px");
                lblMessage.Style.Add("display", "block");
            }
        }
    }}




