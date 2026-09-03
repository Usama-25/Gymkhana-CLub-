using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
namespace GuestRoomApp.GuestRoomM
{
    public partial class RoomCheckOut : System.Web.UI.Page
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
            using (SqlConnection con = new SqlConnection(connStr))
            {
                // FIX: Use a subquery with MIN() to get one reservation row per ReservationNo
                // This prevents duplicate room cards when a reservation has multiple rows
                // in RoomReservations (e.g. group bookings with multiple rooms).
                string query = @"
                    SELECT
                        a.AllocationID,
                        a.ReservationNo,
                        a.RoomNo,
                        a.AllocatedDate,
                        r.GuestName,
                        r.GuestOf,
                        r.FromDate,
                        r.ToDate,
                        r.AdvancePayment,
                        DATEDIFF(DAY, a.AllocatedDate, GETDATE()) AS NightsStayed
                    FROM RoomAllocations a
                    INNER JOIN (
                        -- One row per ReservationNo: sum the advance to avoid split-value display issues
                        SELECT
                            ReservationNo,
                            MIN(GuestName)      AS GuestName,
                            MIN(GuestOf)        AS GuestOf,
                            MIN(FromDate)       AS FromDate,
                            MIN(ToDate)         AS ToDate,
                            SUM(AdvancePayment) AS AdvancePayment
                        FROM RoomReservations
                        GROUP BY ReservationNo
                    ) r ON a.ReservationNo = r.ReservationNo
                    WHERE a.CheckOutDate IS NULL
                    ORDER BY a.RoomNo";

                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    rptOccupiedRooms.DataSource = dt;
                    rptOccupiedRooms.DataBind();
                    pnlEmpty.Visible = false;
                    lblOccupiedCount.Text = dt.Rows.Count.ToString();
                }
                else
                {
                    pnlEmpty.Visible = true;
                    lblOccupiedCount.Text = "0";
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void rptOccupiedRooms_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "CheckOut")
        {
            string[] args = e.CommandArgument.ToString().Split('|');
            int allocationId = Convert.ToInt32(args[0]);
            string reservationNo = args[1];
            string roomNo = args[2];

            ProcessCheckOut(allocationId, reservationNo, roomNo);
        }
    }

    private void ProcessCheckOut(int allocationId, string reservationNo, string roomNo)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                SqlTransaction trans = con.BeginTransaction();

                try
                {
                    // Update allocation with checkout date and set full day factor
                    SqlCommand cmdAlloc = new SqlCommand(
                        "UPDATE RoomAllocations SET CheckOutDate = GETDATE(), RFIDDeactive = 'Yes', StayFactor = 1.0 WHERE AllocationID = @ID",
                        con, trans);
                    cmdAlloc.Parameters.AddWithValue("@ID", allocationId);
                    cmdAlloc.ExecuteNonQuery();

                    // Update one active RoomReservations row to Completed so Availability decreases correctly
                    // We order by ToDate ASC so that un-extended rows are completed first
                    string updateResQuery = @"
                        WITH cte AS (
                            SELECT TOP 1 Status
                            FROM RoomReservations
                            WHERE ReservationNo = @ResNo 
                            AND UPPER(LTRIM(RTRIM(Status))) IN ('OCCUPIED', 'AVAILED')
                            ORDER BY ToDate ASC
                        )
                        UPDATE cte SET Status = 'Completed'";
                    SqlCommand cmdUpdateRes = new SqlCommand(updateResQuery, con, trans);
                    cmdUpdateRes.Parameters.AddWithValue("@ResNo", reservationNo);
                    cmdUpdateRes.ExecuteNonQuery();

                    // â”€â”€ HOUSEKEEPING INTEGRATION â”€â”€
                    // Mark room as 'Dirty' so it shows up in housekeeping
                    SqlCommand cmdDirty = new SqlCommand(
                        "UPDATE RoomDefinitionNew SET Status = 'Dirty' WHERE RoomNo = @RoomNo",
                        con, trans);
                    cmdDirty.Parameters.AddWithValue("@RoomNo", roomNo);
                    cmdDirty.ExecuteNonQuery();

                    trans.Commit();

                    string redirectUrl = string.Format("ManageBills.aspx?ResNo={0}&AutoOpen=true", reservationNo);
                    Response.Redirect(redirectUrl, false);
                }
                catch (Exception ex)
                {
                    trans.Rollback();
                    throw ex;
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error during check-out: " + ex.Message, false);
        }
    }

    private void ShowMessage(string msg, bool success)
    {
        lblMessage.Text = msg;
        lblMessage.CssClass = "alert show " + (success ? "alert-success" : "alert-error");

        if (success)
        {
            ClientScript.RegisterStartupScript(GetType(), "HideMessage",
                "setTimeout(function(){ var msg = document.getElementById('" + lblMessage.ClientID + "'); if(msg) msg.style.display = 'none'; }, 5000);", true);
        }
    }
}
}




