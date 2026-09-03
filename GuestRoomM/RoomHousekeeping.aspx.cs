using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GuestRoomApp.GuestRoomM
{
    public partial class RoomHousekeeping : System.Web.UI.Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDirtyRooms();
                UpdateKPICounts();
            }
        }

        private void UpdateKPICounts()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();
                    SqlCommand cmdDirty = new SqlCommand("SELECT COUNT(*) FROM RoomDefinitionNew WHERE Status = 'Dirty'", con);
                    int dirtyCount = Convert.ToInt32(cmdDirty.ExecuteScalar());

                    SqlCommand cmdMaint = new SqlCommand("SELECT COUNT(*) FROM RoomDefinitionNew WHERE Status = 'Maintenance'", con);
                    int maintCount = Convert.ToInt32(cmdMaint.ExecuteScalar());

                    lblDirtyCount.Text = dirtyCount.ToString();
                    lblMaintenanceCount.Text = maintCount.ToString();
                    lblPendingCount.Text = (dirtyCount + maintCount).ToString();

                    SqlCommand cmdAvailable = new SqlCommand("SELECT COUNT(*) FROM RoomDefinitionNew WHERE Status = 'Available'", con);
                    lblCleanCount.Text = cmdAvailable.ExecuteScalar().ToString();
                }
            }
            catch { }
        }

        //private void LoadDirtyRooms()
        //{
        //    try
        //    {
        //        using (SqlConnection con = new SqlConnection(connStr))
        //        {
        //            string sql = @"
        //                SELECT 
        //                    r.RoomNo, 
        //                    r.FloorNo, 
        //                    r.RoomType,
        //                    (SELECT MAX(CheckOutDate) FROM RoomAllocations WHERE RoomNo = r.RoomNo) AS LastReleased
        //                FROM RoomDefinitionNew r
        //                WHERE r.Status = 'Dirty'
        //                ORDER BY LastReleased ASC";
        //            SqlDataAdapter da = new SqlDataAdapter(sql, con);
        //            DataTable dt = new DataTable();
        //            da.Fill(dt);
        //            gvDirtyRooms.DataSource = dt;
        //            gvDirtyRooms.DataBind();
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        ShowMessage("Error loading dirty rooms: " + ex.Message, false);
        //    }
        //}


        private void LoadDirtyRooms()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string sql = @"
                        SELECT 
                            r.RoomNo, 
                            r.FloorNo, 
                            r.RoomType,
                            r.Status,
                            ra.LastReleased,
                            CASE WHEN ra.Remarks LIKE 'Shifted to:%' THEN sl.ShiftReason ELSE NULL END AS ShiftReason,
                            CASE WHEN ra.Remarks LIKE 'Shifted to:%' THEN sl.Remarks ELSE NULL END AS InternalRemark
                        FROM RoomDefinitionNew r
                        OUTER APPLY (
                            SELECT TOP 1 CheckOutDate AS LastReleased, Remarks 
                            FROM RoomAllocations 
                            WHERE RoomNo = r.RoomNo AND CheckOutDate IS NOT NULL 
                            ORDER BY CheckOutDate DESC
                        ) ra
                        OUTER APPLY (
                            SELECT TOP 1 ShiftReason, Remarks 
                            FROM GR_RoomShiftLog 
                            WHERE OldRoomNo = r.RoomNo 
                            ORDER BY ShiftDate DESC
                        ) sl
                        WHERE r.Status IN ('Dirty', 'Maintenance')
                        ORDER BY ra.LastReleased ASC";
                    SqlDataAdapter da = new SqlDataAdapter(sql, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvDirtyRooms.DataSource = dt;
                    gvDirtyRooms.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading dirty rooms: " + ex.Message, false);
            }
        }
        protected void gvDirtyRooms_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "MakeAvailable")
            {
                string roomNo = e.CommandArgument.ToString();
                MakeRoomAvailable(roomNo);
            }
        }

        private void MakeRoomAvailable(string roomNo)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    SqlCommand cmd = new SqlCommand("UPDATE RoomDefinitionNew SET Status = 'Available' WHERE RoomNo = @RoomNo AND Status IN ('Dirty', 'Maintenance')", con);
                    cmd.Parameters.AddWithValue("@RoomNo", roomNo);
                    con.Open();
                    int rows = cmd.ExecuteNonQuery();
                    if (rows > 0)
                    {
                        ShowMessage(string.Format(" Room {0} is now clean and available for guests!", roomNo), true);
                        LoadDirtyRooms();
                        UpdateKPICounts();
                    }
                    else
                    {
                        ShowMessage("(!) Could not update room status. It may already be available.", false);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error updating room status: " + ex.Message, false);
            }
        }

        private void ShowMessage(string msg, bool success)
        {
            lblMessage.Text = msg;
            lblMessage.CssClass = "alert show " + (success ? "alert-success" : "alert-error");
            if (success)
            {
                ClientScript.RegisterStartupScript(GetType(), "HideMsg", "setTimeout(function(){ var m=document.getElementById('" + lblMessage.ClientID + "'); if(m) m.style.display='none'; }, 5000);", true);
            }
        }
    }
}



