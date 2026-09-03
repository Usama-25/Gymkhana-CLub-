using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GuestRoomApp.GuestRoomM
{
    public partial class ExtensionApproval : System.Web.UI.Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadPendingRequests();
            }
        }

        private void LoadPendingRequests()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string sql = "SELECT * FROM GR_RoomExtensionRequests WHERE Status = 'Pending' ORDER BY RequestDate DESC";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvRequests.DataSource = dt;
                    gvRequests.DataBind();
                }
            }
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            ProcessRequest("Approved");
        }

        protected void btnReject_Click(object sender, EventArgs e)
        {
            ProcessRequest("Rejected");
        }

        private void ProcessRequest(string decision)
        {
            string requestId = hfSelectedRequestId.Value;
            string remarks = txtApprovalRemarks.Text.Trim();

            if (string.IsNullOrEmpty(remarks))
            {
                ShowMessage("Remarks are mandatory for " + decision.ToLower() + ".", false);
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();
                    SqlTransaction trans = con.BeginTransaction();

                    try
                    {
                        // 1. Get Request Details
                        string resNo = "";
                        DateTime newTo = DateTime.Now;
                        string roomNo = "";
                        using (SqlCommand cmdReq = new SqlCommand("SELECT ReservationNo, NewToDate, RoomNo FROM GR_RoomExtensionRequests WHERE RequestID = @RID", con, trans))
                        {
                            cmdReq.Parameters.AddWithValue("@RID", requestId);
                            using (SqlDataReader dr = cmdReq.ExecuteReader())
                            {
                                if (dr.Read())
                                {
                                    resNo = dr["ReservationNo"].ToString();
                                    newTo = Convert.ToDateTime(dr["NewToDate"]);
                                    roomNo = dr["RoomNo"].ToString();
                                }
                            }
                        }

                        if (decision == "Approved")
                        {
                            // 2. Update Reservation
                            string sqlUpdate = roomNo == "ALL" 
                                ? "UPDATE RoomReservations SET ToDate = @NewTo, Remarks = ISNULL(Remarks, '') + CHAR(13) + @AppRemarks WHERE ReservationNo = @ResNo AND Status IN ('Occupied', 'Availed')"
                                : "UPDATE TOP (1) RoomReservations SET ToDate = @NewTo, Remarks = ISNULL(Remarks, '') + CHAR(13) + @AppRemarks WHERE ReservationNo = @ResNo AND Status IN ('Occupied', 'Availed')";

                            using (SqlCommand cmdUpd = new SqlCommand(sqlUpdate, con, trans))
                            {
                                cmdUpd.Parameters.AddWithValue("@NewTo", newTo);
                                cmdUpd.Parameters.AddWithValue("@ResNo", resNo);
                                cmdUpd.Parameters.AddWithValue("@AppRemarks", "EXTENSION APPROVED until " + newTo.ToString("dd-MMM-yyyy") + ". Remarks: " + remarks);
                                cmdUpd.ExecuteNonQuery();
                            }
                        }

                        // 3. Update Request Status
                        using (SqlCommand cmdFinal = new SqlCommand("UPDATE GR_RoomExtensionRequests SET Status = @Status, ApprovalDate = GETDATE(), ApprovedBy = 'Manager' WHERE RequestID = @RID", con, trans))
                        {
                            cmdFinal.Parameters.AddWithValue("@Status", decision);
                            cmdFinal.Parameters.AddWithValue("@RID", requestId);
                            cmdFinal.ExecuteNonQuery();
                        }

                        trans.Commit();
                        ShowMessage("âœ… Extension request " + decision.ToLower() + " successfully.", true);
                        txtApprovalRemarks.Text = "";
                        LoadPendingRequests();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        ShowMessage("Error processing transaction: " + ex.Message, false);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Database connection error: " + ex.Message, false);
            }
        }

        protected void gvRequests_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // Handled via Client-side JS and Modal Buttons
        }

        private void ShowMessage(string msg, bool success)
        {
            lblMessage.Text = msg;
            lblMessage.CssClass = "alert show " + (success ? "alert-success" : "alert-error");
            ScriptManager.RegisterStartupScript(this, GetType(), "HideMsg", "setTimeout(function(){ document.getElementById('" + lblMessage.ClientID + "').style.display='none'; }, 5000);", true);
        }
    }
}



