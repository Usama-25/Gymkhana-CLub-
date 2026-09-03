using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GuestRoomApp.GuestRoomM
{
    public partial class OccupiedRooms : System.Web.UI.Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadOccupiedRooms();
            }
        }

        private void LoadOccupiedRooms(string search = "")
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string sql = @"
                        SELECT 
                            ra.RoomNo,
                            ra.AllocatedDate,
                            rr.ReservationNo,
                            rr.GuestName,
                            rr.GuestOf,
                            rr.MembershipNo,
                            rr.ClubName,
                            rd.RoomType,
                            rr.ToDate as ExpectedCheckOut,
                            DATEDIFF(day, ra.AllocatedDate, GETDATE()) as Nights
                        FROM RoomAllocations ra
                        INNER JOIN (
                            SELECT ReservationNo, GuestName, GuestOf, MembershipNo, ClubName, ToDate,
                                   ROW_NUMBER() OVER(PARTITION BY ReservationNo ORDER BY ReservationID) as rn
                            FROM RoomReservations
                        ) rr ON ra.ReservationNo = rr.ReservationNo AND rr.rn = 1
                        INNER JOIN RoomDefinitionNew rd ON ra.RoomNo = rd.RoomNo
                        WHERE ra.CheckOutDate IS NULL";

                    if (!string.IsNullOrEmpty(search))
                    {
                        sql += " AND (ra.RoomNo LIKE @search OR rr.GuestName LIKE @search OR rr.GuestOf LIKE @search OR rr.MembershipNo LIKE @search OR rr.ClubName LIKE @search)";
                    }

                    sql += " ORDER BY ra.RoomNo";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        if (!string.IsNullOrEmpty(search))
                        {
                            cmd.Parameters.AddWithValue("@search", "%" + search + "%");
                        }

                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        con.Open();
                        da.Fill(dt);

                        gvOccupiedRooms.DataSource = dt;
                        gvOccupiedRooms.DataBind();

                        lblTotalOccupied.Text = dt.Rows.Count + " Room(s) Currently Occupied";
                    }
                }
            }
            catch (Exception ex)
            {
                // In a real app, log the error. Here we'll just show it in the empty text if it fails.
                gvOccupiedRooms.EmptyDataText = "Error loading data: " + ex.Message;
                gvOccupiedRooms.DataBind();
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadOccupiedRooms(txtSearch.Text.Trim());
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            LoadOccupiedRooms();
        }

        protected void gvOccupiedRooms_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // Any specific row processing can go here
                // For example, highlight if ExpectedCheckout is today
                DateTime expectedOut;
                if (DateTime.TryParse(DataBinder.Eval(e.Row.DataItem, "ExpectedCheckOut").ToString(), out expectedOut))
                {
                    if (expectedOut.Date == DateTime.Today)
                    {
                        e.Row.Style["background-color"] = "#e8f5e9"; // Light green for today's checkout
                        e.Row.Style["font-weight"] = "600";
                    }
                    else if (expectedOut.Date < DateTime.Today)
                    {
                        e.Row.Style["background-color"] = "#fef2f2"; // Light red for overdue checkout
                    }
                }
            }
        }
    }
}


