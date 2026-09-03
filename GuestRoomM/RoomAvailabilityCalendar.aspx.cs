using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GuestRoomApp.GuestRoomM
{
    public partial class RoomAvailabilityCalendar : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtStartDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                txtEndDate.Text = DateTime.Now.AddDays(14).ToString("yyyy-MM-dd");
                BindAvailabilityMatrix();
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindAvailabilityMatrix();
        }

        private void BindAvailabilityMatrix()
        {
            try
            {
                DateTime sDate = Convert.ToDateTime(txtStartDate.Text);
                DateTime eDate = Convert.ToDateTime(txtEndDate.Text);

                if ((eDate - sDate).TotalDays > 60)
                {
                    eDate = sDate.AddDays(60);
                    txtEndDate.Text = eDate.ToString("yyyy-MM-dd");
                    ShowMessage("Date range limited to 60 days for performance.", false);
                }

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    // Get total rooms count
                    SqlCommand cmdTotal = new SqlCommand("SELECT COUNT(*) FROM RoomDefinitionNew", con);
                    int totalRooms = Convert.ToInt32(cmdTotal.ExecuteScalar());

                    // Create DataTable
                    DataTable dt = new DataTable();
                    dt.Columns.Add("Date", typeof(DateTime));
                    dt.Columns.Add("DateFormatted", typeof(string));
                    dt.Columns.Add("DayName", typeof(string));
                    dt.Columns.Add("TotalRooms", typeof(int));
                    dt.Columns.Add("OccupiedRooms", typeof(int));
                    dt.Columns.Add("AvailableRooms", typeof(int));

                    // Loop through each date
                    for (DateTime date = sDate; date <= eDate; date = date.AddDays(1))
                    {
                        int occupiedRooms = GetOccupiedRoomsCount(date, con);
                        int availableRooms = totalRooms - occupiedRooms;
                        if (availableRooms < 0) availableRooms = 0;

                        DataRow row = dt.NewRow();
                        row["Date"] = date;
                        row["DateFormatted"] = date.ToString("dd-MMM-yyyy");
                        row["DayName"] = GetUrduDayName(date);
                        row["TotalRooms"] = totalRooms;
                        row["OccupiedRooms"] = occupiedRooms;
                        row["AvailableRooms"] = availableRooms;
                        dt.Rows.Add(row);
                    }

                    gvAvailability.DataSource = dt;
                    gvAvailability.DataBind();

                    if (dt.Rows.Count == 0)
                    {
                        ShowMessage("No data found for selected date range.", false);
                    }
                    else
                    {
                        lblMessage.Visible = false;
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        private int GetOccupiedRoomsCount(DateTime checkDate, SqlConnection con)
        {
            try
            {
                // Query to get booked/occupied rooms from RoomReservations
                // We sum NoOfRooms for all reservations that overlap with this date
                string query = @"
                    SELECT ISNULL(SUM(NoOfRooms), 0)
                    FROM RoomReservations
                    WHERE @CheckDate >= FromDate 
                      AND @CheckDate < ToDate
                      AND UPPER(LTRIM(RTRIM(Status))) IN ('CONFIRMED', 'OCCUPIED', 'AVAILED', 'PENDING')";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@CheckDate", checkDate.Date);
                object result = cmd.ExecuteScalar();
                return result != null ? Convert.ToInt32(result) : 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("GetOccupiedRoomsCount Error: " + ex.Message);
                return 0;
            }
        }

        private string GetUrduDayName(DateTime date)
        {
            string day = date.DayOfWeek.ToString();
            switch (day)
            {
                case "Monday": return "Monday ";
                case "Tuesday": return "Tuesday";
                case "Wednesday": return "Wednesday ";
                case "Thursday": return "Thursday";
                case "Friday": return "Friday";
                case "Saturday": return "Saturday";
                case "Sunday": return "Sunday";
                default: return day;
            }
        }

        protected void gvAvailability_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                int available = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "AvailableRooms"));
                System.Web.UI.WebControls.TableCell cell = e.Row.Cells[4]; // Available column

                if (available <= 0)
                {
                    cell.Text = "<span class='status-full'>? " + available + " (Full)</span>";
                }
                else if (available <= 5)
                {
                    cell.Text = "<span class='status-warning'>?? " + available + " (Limited)</span>";
                }
                else
                {
                    cell.Text = "<span class='status-good'>? " + available + " (Available)</span>";
                }
            }
        }

        private void ShowMessage(string msg, bool isSuccess)
        {
            lblMessage.Text = msg;
            lblMessage.Visible = true;
            if (!isSuccess)
            {
                lblMessage.CssClass = "alert alert-error";
            }
        }
    }
}



