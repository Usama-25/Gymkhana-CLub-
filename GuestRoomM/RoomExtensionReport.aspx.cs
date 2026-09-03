using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GuestRoomApp.GuestRoomM
{
    public partial class RoomExtensionReport : System.Web.UI.Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtFromDate.Text = DateTime.Today.AddDays(-7).ToString("yyyy-MM-dd");
                txtToDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                LoadReport();
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadReport();
        }

        private void LoadReport()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string sql = @"
                        SELECT 
                            er.RequestID, er.ReservationNo, er.RoomNo, er.CurrentToDate, er.NewToDate, 
                            er.Remarks, er.Status, er.RequestDate, er.ApprovalDate, er.ApprovedBy,
                            (SELECT TOP 1 GuestName FROM RoomReservations WHERE LTRIM(RTRIM(ReservationNo)) = LTRIM(RTRIM(er.ReservationNo))) as GuestName
                        FROM GR_RoomExtensionRequests er
                        WHERE CAST(er.RequestDate AS DATE) BETWEEN @From AND @To";

                    string search = txtSearch.Text.Trim();
                    if (!string.IsNullOrEmpty(search))
                    {
                        sql += @" AND (er.ReservationNo LIKE @S OR er.RoomNo LIKE @S 
                                    OR EXISTS (SELECT 1 FROM RoomReservations WHERE LTRIM(RTRIM(ReservationNo)) = LTRIM(RTRIM(er.ReservationNo)) 
                                               AND (GuestName LIKE @S)))";
                    }

                    sql += " ORDER BY er.RequestDate DESC";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@From", txtFromDate.Text);
                        cmd.Parameters.AddWithValue("@To", txtToDate.Text);
                        if (!string.IsNullOrEmpty(search))
                        {
                            cmd.Parameters.AddWithValue("@S", "%" + search + "%");
                        }

                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        gvExtensions.DataSource = dt;
                        gvExtensions.DataBind();
                        
                        gvExtensionsPrint.DataSource = dt;
                        gvExtensionsPrint.DataBind();

                        lblCount.Text = dt.Rows.Count.ToString();
                        
                        lblPrintPeriod.Text = Convert.ToDateTime(txtFromDate.Text).ToString("dd-MMM-yyyy") + " to " + Convert.ToDateTime(txtToDate.Text).ToString("dd-MMM-yyyy");
                        lblPrintTime.Text = DateTime.Now.ToString("dd-MMM-yyyy HH:mm");
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        protected string GetExtensionStatusStyle(string status)
        {
            switch (status.ToUpper())
            {
                case "APPROVED":
                    return "background:#e8f5e9; color:#2e7d32; border:1px solid #c8e6c9; padding:3px 12px; border-radius:99px; font-size:.71rem; font-weight:700; white-space:nowrap;";
                case "PENDING":
                    return "background:#fff3e0; color:#e65100; border:1px solid #ffcc80; padding:3px 12px; border-radius:99px; font-size:.71rem; font-weight:700; white-space:nowrap;";
                case "REJECTED":
                    return "background:#fce4ec; color:#c62828; border:1px solid #f48fb1; padding:3px 12px; border-radius:99px; font-size:.71rem; font-weight:700; white-space:nowrap;";
                case "CANCELLED":
                    return "background:#fce4ec; color:#c62828; border:1px solid #f48fb1; padding:3px 12px; border-radius:99px; font-size:.71rem; font-weight:700; white-space:nowrap;";
                case "COMPLETED":
                    return "background:#e3f2fd; color:#1565C0; border:1px solid #90caf9; padding:3px 12px; border-radius:99px; font-size:.71rem; font-weight:700; white-space:nowrap;";
                default:
                    return "background:#f1f5f9; color:#64748b; border:1px solid #cbd5e1; padding:3px 12px; border-radius:99px; font-size:.71rem; font-weight:700; white-space:nowrap;";
            }
        }
        protected void btnPrintReport_Click(object sender, EventArgs e)
        {
            hfPrint.Value = "1";
            LoadReport();
        }

        private void ShowMessage(string msg, bool success)
        {
            lblMessage.Text = msg;
            lblMessage.CssClass = "alert show " + (success ? "alert-success" : "alert-error");
            ScriptManager.RegisterStartupScript(this, GetType(), "HideMsg", "setTimeout(function(){ document.getElementById('" + lblMessage.ClientID + "').style.display='none'; }, 5000);", true);
        }
    }
}


