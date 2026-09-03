using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GuestRoomApp.GuestRoomM
{
    public partial class TodayCheckOut : System.Web.UI.Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtReportDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                LoadTodayCheckOuts();
                UpdateKPIs();
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadTodayCheckOuts();
            UpdateKPIs();
        }

        private void UpdateKPIs()
        {
            try
            {
                DateTime reportDate = DateTime.Parse(txtReportDate.Text);
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();
                    
                    // 1. Total Occupied (Current Status)
                    SqlCommand cmdOccupied = new SqlCommand("SELECT COUNT(*) FROM RoomAllocations WHERE CheckOutDate IS NULL", con);
                    lblOccupiedCount.Text = cmdOccupied.ExecuteScalar().ToString();

                    // 2. Already Checked Out on Selected Date
                    SqlCommand cmdCheckedOut = new SqlCommand("SELECT COUNT(*) FROM RoomAllocations WHERE CAST(CheckOutDate AS DATE) = @ReportDate", con);
                    cmdCheckedOut.Parameters.AddWithValue("@ReportDate", reportDate);
                    lblCheckedOutCount.Text = cmdCheckedOut.ExecuteScalar().ToString();
                }
            }
            catch { }
        }

        private void LoadTodayCheckOuts()
        {
            try
            {
                DateTime reportDate = DateTime.Parse(txtReportDate.Text);
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    // 1. PENDING CHECK-OUTS (Due on Selected Date)
                    string queryPending = @"
                        SELECT 
                            a.AllocationID, a.ReservationNo, a.RoomNo, a.AllocatedDate,
                            r.GuestName, r.GuestOf, r.ToDate, r.AdvancePayment, r.MembershipNo,
                            DATEDIFF(DAY, a.AllocatedDate, @ReportDate) AS NightsStayed
                        FROM RoomAllocations a
                        INNER JOIN (
                            SELECT ReservationNo, MIN(GuestName) as GuestName, MIN(GuestOf) as GuestOf, MIN(ToDate) as ToDate, SUM(AdvancePayment) as AdvancePayment, MIN(MembershipNo) as MembershipNo
                            FROM RoomReservations GROUP BY ReservationNo
                        ) r ON a.ReservationNo = r.ReservationNo
                        WHERE a.CheckOutDate IS NULL
                        AND CAST(r.ToDate AS DATE) = @ReportDate
                        ORDER BY a.RoomNo";

                    SqlDataAdapter daPending = new SqlDataAdapter(queryPending, con);
                    daPending.SelectCommand.Parameters.AddWithValue("@ReportDate", reportDate);
                    DataTable dtPending = new DataTable();
                    daPending.Fill(dtPending);

                    gvTodayCheckOuts.DataSource = dtPending;
                    gvTodayCheckOuts.DataBind();
                    
                    lblTodayCount.Text = dtPending.Rows.Count.ToString();
                    lblRecordCount.Text = dtPending.Rows.Count.ToString();
                    lblFooterCount.Text = dtPending.Rows.Count.ToString();

                    // 2. COMPLETED CHECK-OUTS on Selected Date
                    string queryCompleted = @"
                        SELECT a.RoomNo, r.GuestName, r.MembershipNo, a.AllocatedDate, a.CheckOutDate
                        FROM RoomAllocations a
                        INNER JOIN (
                            SELECT ReservationNo, MIN(GuestName) as GuestName, MIN(MembershipNo) as MembershipNo FROM RoomReservations GROUP BY ReservationNo
                        ) r ON a.ReservationNo = r.ReservationNo
                        WHERE CAST(a.CheckOutDate AS DATE) = @ReportDate
                        ORDER BY a.CheckOutDate DESC";
                    
                    SqlDataAdapter daCompleted = new SqlDataAdapter(queryCompleted, con);
                    daCompleted.SelectCommand.Parameters.AddWithValue("@ReportDate", reportDate);
                    DataTable dtCompleted = new DataTable();
                    daCompleted.Fill(dtCompleted);

                    rptCompletedCheckouts.DataSource = dtCompleted;
                    rptCompletedCheckouts.DataBind();
                    
                    lblCheckedOutCount.Text = dtCompleted.Rows.Count.ToString();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading check-outs: " + ex.Message, false);
            }
        }

        protected void gvTodayCheckOuts_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvTodayCheckOuts.PageIndex = e.NewPageIndex;
            LoadTodayCheckOuts();
        }

        protected void gvTodayCheckOuts_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // Add custom logic if needed
        }

        protected void gvTodayCheckOuts_RowCommand(object sender, GridViewCommandEventArgs e)
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
                        // 1. Update RoomAllocations: Mark as checked out
                        SqlCommand cmdAlloc = new SqlCommand(
                            "UPDATE RoomAllocations SET CheckOutDate = GETDATE(), RFIDDeactive = 'Yes', StayFactor = 1.0 WHERE AllocationID = @ID",
                            con, trans);
                        cmdAlloc.Parameters.AddWithValue("@ID", allocationId);
                        cmdAlloc.ExecuteNonQuery();

                        // 2. Update RoomReservations: Mark as Completed
                        string updateResQuery = @"
                            WITH cte AS (
                                SELECT TOP 1 Status
                                FROM RoomReservations
                                WHERE ReservationNo = @ResNo 
                                AND Status IN ('Occupied', 'Availed')
                                ORDER BY ToDate ASC
                            )
                            UPDATE cte SET Status = 'Completed'";
                        SqlCommand cmdUpdateRes = new SqlCommand(updateResQuery, con, trans);
                        cmdUpdateRes.Parameters.AddWithValue("@ResNo", reservationNo);
                        cmdUpdateRes.ExecuteNonQuery();

                        // 3. Update Room Status: Set to Dirty for Housekeeping
                        SqlCommand cmdDirty = new SqlCommand(
                            "UPDATE RoomDefinitionNew SET Status = 'Dirty' WHERE RoomNo = @RoomNo",
                            con, trans);
                        cmdDirty.Parameters.AddWithValue("@RoomNo", roomNo);
                        cmdDirty.ExecuteNonQuery();

                        trans.Commit();

                        // Redirect to ManageBills to finalize billing
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
            
            // Register script to hide message after delay
            string script = "setTimeout(function(){ var msg = document.getElementById('" + lblMessage.ClientID + "'); if(msg) msg.style.display = 'none'; }, 5000);";
            ClientScript.RegisterStartupScript(GetType(), "HideMessage", script, true);
        }
    }
}




