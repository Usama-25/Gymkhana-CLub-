using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
namespace GuestRoomApp.GuestRoomM
{
    public partial class RoomReservationStatus : System.Web.UI.Page
    {
    private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtFromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            txtToDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            LoadReservationData();
        }
    }

    protected void btnCheck_Click(object sender, EventArgs e)
    {
        gvStatus.PageIndex = 0;
        LoadReservationData();
    }

    protected void btnPrintReport_Click(object sender, EventArgs e)
    {
        LoadTodayReportData();
        hfTriggerPrint.Value = "1";
    }

    protected void gvStatus_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvStatus.PageIndex = e.NewPageIndex;
        LoadReservationData();
    }

    private void LoadReservationData()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            SqlCommand cmd = new SqlCommand("sp_GetReservationStatus", con);
            cmd.CommandType = CommandType.StoredProcedure;

            DateTime fromDate = string.IsNullOrEmpty(txtFromDate.Text) ? DateTime.Parse("1900-01-01") : DateTime.Parse(txtFromDate.Text);
            DateTime toDate = string.IsNullOrEmpty(txtToDate.Text) ? DateTime.Parse("2099-12-31") : DateTime.Parse(txtToDate.Text);

            cmd.Parameters.AddWithValue("@FromDate", fromDate);
            cmd.Parameters.AddWithValue("@ToDate", toDate);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            if (!dt.Columns.Contains("HasPendingExtension"))
                dt.Columns.Add("HasPendingExtension", typeof(bool));
            
            if (!dt.Columns.Contains("MembershipNo"))
                dt.Columns.Add("MembershipNo", typeof(string));

            foreach (DataRow row in dt.Rows)
                row["Status"] = row["Status"].ToString().Trim().ToUpper();

            // ── DYNAMIC STATUS UPDATE (Phase 2 Refactoring) ──
            // We override the static status from RoomReservations with real-time allocation data
            if (con.State == ConnectionState.Closed) con.Open();
            foreach (DataRow row in dt.Rows)
            {
                string resNo = row["ReservationNo"].ToString();
                
                // 1. DYNAMIC STATUS & ADVANCE AGGREGATION
                using (SqlCommand cmdStat = new SqlCommand(@"
                    SELECT 
                        (SELECT COUNT(*) FROM RoomAllocations WHERE ReservationNo = @R) as TotalAlloc,
                        (SELECT COUNT(*) FROM RoomAllocations WHERE ReservationNo = @R AND CheckOutDate IS NULL) as OccupiedAlloc,
                        (SELECT SUM(AdvancePayment) FROM RoomReservations WHERE ReservationNo = @R) as TotalAdvance,
                        (SELECT TOP 1 MembershipNo FROM RoomReservations WHERE ReservationNo = @R) as MembershipNo", con))
                {
                    cmdStat.Parameters.AddWithValue("@R", resNo);
                    using (SqlDataReader drStat = cmdStat.ExecuteReader())
                    {
                        if (drStat.Read())
                        {
                            int totalAlloc = drStat["TotalAlloc"] != DBNull.Value ? Convert.ToInt32(drStat["TotalAlloc"]) : 0;
                            int occupiedAlloc = drStat["OccupiedAlloc"] != DBNull.Value ? Convert.ToInt32(drStat["OccupiedAlloc"]) : 0;
                            decimal totalAdvanceAmount = drStat["TotalAdvance"] != DBNull.Value ? Convert.ToDecimal(drStat["TotalAdvance"]) : 0;
                            string membershipNo = drStat["MembershipNo"] != DBNull.Value ? drStat["MembershipNo"].ToString() : "";

                            // Update Advance Payment to show total for group, not split per room
                            row["AdvancePayment"] = totalAdvanceAmount;
                            row["MembershipNo"] = membershipNo;
                            
                            if (totalAlloc > 0)
                            {
                                if (occupiedAlloc > 0) row["Status"] = "OCCUPIED";
                                else row["Status"] = "COMPLETED";
                            }
                        }
                    }
                }

                // 2. CHECK FOR PENDING EXTENSION REQUESTS
                using (SqlCommand cmdExt = new SqlCommand("SELECT COUNT(*) FROM GR_RoomExtensionRequests WHERE ReservationNo = @R AND Status = 'Pending'", con))
                {
                    cmdExt.Parameters.AddWithValue("@R", resNo);
                    int pendingExt = (int)cmdExt.ExecuteScalar();
                    row["HasPendingExtension"] = pendingExt > 0;
                }
            }
            con.Close();

            // KPI counts - Consistently calculated from the same dataset
            lblConfirmedCount.Text = CountByStatus(dt, "CONFIRMED");
            lblPendingCount.Text = CountByStatus(dt, "PENDING");
            lblCancelledCount.Text = CountByStatus(dt, "CANCELLED");
            lblOccupiedCount.Text = CountByStatus(dt, "OCCUPIED");
            lblCompletedCount.Text = CountByStatus(dt, "COMPLETED");

            // Overall totals for the selected date range (before status filtering)
            object totalRoomsOverall = dt.Compute("SUM(NoOfRooms)", "");
            lblTotalRooms.Text = (totalRoomsOverall != DBNull.Value) ? totalRoomsOverall.ToString() : "0";

            object totalAdvanceOverall = dt.Compute("SUM(AdvancePayment)", "");
            lblTotalAdvance.Text = (totalAdvanceOverall != DBNull.Value) ? Convert.ToDecimal(totalAdvanceOverall).ToString("N0") : "0";

            DataView dv = new DataView(dt);
            dv.Sort = "ResDate DESC";
            string selectedStatus = ddlStatusFilter.SelectedValue;

            if (selectedStatus != "All")
            {
                if (selectedStatus.Equals("OCCUPIED", StringComparison.OrdinalIgnoreCase))
                {
                    dv.RowFilter = "Status = 'OCCUPIED' OR Status = 'AVAILED' OR Status = 'OCCUPIED'";
                }
                else
                {
                    dv.RowFilter = string.Format("Status = '{0}'", selectedStatus.ToUpper().Trim());
                }
            }

            int recordCount = dv.Count;
            string totalRooms = "0";
            string totalAdvance = "0";

            if (recordCount > 0)
            {
                DataTable table = dv.ToTable();
                object sum = table.Compute("SUM(NoOfRooms)", "");
                totalRooms = (sum != DBNull.Value) ? sum.ToString() : "0";

                object sumAdv = table.Compute("SUM(AdvancePayment)", "");
                totalAdvance = (sumAdv != DBNull.Value) ? Convert.ToDecimal(sumAdv).ToString("N0") : "0";
            }

            lblTotalRoomsToolbar.Text = totalRooms;
            lblTotalRoomsFooter.Text = totalRooms;
            lblRecordCount.Text = recordCount.ToString();

            gvStatus.DataSource = dv;
            gvStatus.DataBind();
        }
    }

    private void LoadTodayReportData()
    {
        DateTime today = DateTime.Today;
        lblReportDate.Text = today.ToString("dd MMMM yyyy");
        lblPrintTime.Text  = DateTime.Now.ToString("dd-MMM-yyyy hh:mm tt");

        using (SqlConnection con = new SqlConnection(connStr))
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT r.ReservationNo, r.GuestName,
                       ISNULL(r.ClubName,'') AS Club,
                       r.ReservationType, r.FromDate, r.ToDate,
                       r.NoOfRooms, r.AdvancePayment,
                       UPPER(LTRIM(RTRIM(r.Status))) AS Status
                FROM RoomReservations r
                WHERE CAST(r.ResDate  AS DATE) = @Today
                   OR CAST(r.FromDate AS DATE) = @Today
                   OR CAST(r.ToDate   AS DATE) = @Today
                   OR EXISTS (
                       SELECT 1 FROM RoomAllocations ra
                       WHERE ra.ReservationNo = r.ReservationNo
                         AND ra.CheckOutDate IS NULL
                   )
                ORDER BY r.ResDate DESC", con);
            cmd.Parameters.AddWithValue("@Today", today);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            con.Open();
            foreach (DataRow row in dt.Rows)
            {
                row["Status"] = row["Status"].ToString().Trim().ToUpper();
                string resNo = row["ReservationNo"].ToString();
                using (SqlCommand cmdStat = new SqlCommand(@"
                    SELECT
                        (SELECT COUNT(*) FROM RoomAllocations WHERE ReservationNo=@R) AS TotalAlloc,
                        (SELECT COUNT(*) FROM RoomAllocations WHERE ReservationNo=@R AND CheckOutDate IS NULL) AS OccupiedAlloc,
                        (SELECT SUM(AdvancePayment) FROM RoomReservations WHERE ReservationNo=@R) AS TotalAdvance", con))
                {
                    cmdStat.Parameters.AddWithValue("@R", resNo);
                    using (SqlDataReader drStat = cmdStat.ExecuteReader())
                    {
                        if (drStat.Read())
                        {
                            int totalAlloc    = drStat["TotalAlloc"]    != DBNull.Value ? Convert.ToInt32(drStat["TotalAlloc"])     : 0;
                            int occupiedAlloc = drStat["OccupiedAlloc"] != DBNull.Value ? Convert.ToInt32(drStat["OccupiedAlloc"])  : 0;
                            decimal totalAdv  = drStat["TotalAdvance"]  != DBNull.Value ? Convert.ToDecimal(drStat["TotalAdvance"]) : 0m;
                            row["AdvancePayment"] = totalAdv;
                            if (totalAlloc > 0)
                                row["Status"] = occupiedAlloc > 0 ? "OCCUPIED" : "COMPLETED";
                        }
                    }
                }
            }
            con.Close();

            Func<string, int> countS = (s) =>
            {
                DataView dv2 = new DataView(dt);
                dv2.RowFilter = string.Format("Status = '{0}'", s);
                return dv2.Count;
            };

            lblRptPending.Text   = countS("PENDING").ToString();
            lblRptOccupied.Text  = countS("OCCUPIED").ToString();
            lblRptCancelled.Text = countS("CANCELLED").ToString();
            lblRptCompleted.Text = countS("COMPLETED").ToString();
            lblRptConfirmed.Text = countS("CONFIRMED").ToString();

            gvPrintReport.DataSource = dt;
            gvPrintReport.DataBind();
        }
    }

    private string CountByStatus(DataTable dt, params string[] statuses)
    {
        DataView dv = new DataView(dt);
        if (statuses.Length == 1)
            dv.RowFilter = string.Format("Status = '{0}'", statuses[0]);
        else
        {
            string filter = "";
            for (int i = 0; i < statuses.Length; i++)
                filter += (i == 0 ? "" : " OR ") + string.Format("Status = '{0}'", statuses[i]);
            dv.RowFilter = filter;
        }

        if (dv.Count == 0) return "0";
        object sum = dv.ToTable().Compute("SUM(NoOfRooms)", "");
        return (sum != DBNull.Value) ? sum.ToString() : "0";
    }

    protected string GetStatusStyle(string status)
    {
        switch (status.Trim().ToUpper())
        {
            case "CONFIRMED": return "background: #e8f5e9; color: #2e7d32; border: 1px solid #a5d6a7;";
            case "OCCUPIED":
            case "AVAILED": return "background: #e3f2fd; color: #1565C0; border: 1px solid #90caf9;";
            case "COMPLETED": return "background: #eceff1; color: #607d8b; border: 1px solid #cfd8dc;";
            case "CANCELLED": return "background: #fce4ec; color: #c62828; border: 1px solid #f8bbd0;";
            default: return "background: #fff3e0; color: #e65100; border: 1px solid #ffcc80;";
        }
    }
    
    protected string GetStatusBadge(string status)
    {
        string style = GetStatusStyle(status);
        string text = status.ToLower();
        string icon = "fa-clock";
        switch (status.Trim().ToUpper())
        {
            case "CONFIRMED": icon = "fa-check"; break;
            case "OCCUPIED":
            case "AVAILED": icon = "fa-door-open"; break;
            case "COMPLETED": icon = "fa-flag-checkered"; break;
            case "CANCELLED": icon = "fa-times"; break;
        }
        return string.Format("<span style='padding: 2px 10px; border-radius: 12px; font-size: .75rem; font-weight: 700; white-space: nowrap; {0}'><i class='fas {1}' style='font-size:0.6rem; margin-right:3px;'></i> {2}</span>", style, icon, text);
    }

    private string GetRoomCountByAllocationStatus(SqlConnection con, DateTime from, DateTime to, bool active)
    {
        try
        {
            string sql = active 
                ? "SELECT COUNT(*) FROM RoomAllocations WHERE CheckOutDate IS NULL"
                : "SELECT COUNT(*) FROM RoomAllocations WHERE CheckOutDate IS NOT NULL AND CheckOutDate BETWEEN @F AND @T";
            
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                if (!active)
                {
                    cmd.Parameters.AddWithValue("@F", from);
                    cmd.Parameters.AddWithValue("@T", to);
                }
                object result = cmd.ExecuteScalar();
                return result != null ? result.ToString() : "0";
            }
        }
        catch { return "0"; }
    }

    protected string GetRFIDStatusList(string reservationNo)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "SELECT RoomNo, RFIDCardNo, CheckOutDate, RFIDDeactive FROM RoomAllocations WHERE ReservationNo = @ResNo ORDER BY RoomNo";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@ResNo", reservationNo);
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                System.Text.StringBuilder sb = new System.Text.StringBuilder();
                while (dr.Read())
                {
                    if (sb.Length > 0) sb.Append("<br/>");
                    string card = dr["RFIDCardNo"] == DBNull.Value ? "No Card" : dr["RFIDCardNo"].ToString();
                    bool deactivated = dr["RFIDDeactive"] != DBNull.Value && dr["RFIDDeactive"].ToString() == "Yes";
                    bool checkedOut = dr["CheckOutDate"] != DBNull.Value;
                    
                    if (checkedOut)
                        sb.Append(string.Format("R{0}: <span style='color:var(--muted); font-weight:700;'>{1} (COMPLETED)</span>", dr["RoomNo"], card));
                    else if (deactivated)
                        sb.Append(string.Format("R{0}: <span style='color:var(--danger); font-weight:700;'>{1} (DEACTIVE)</span>", dr["RoomNo"], card));
                    else
                        sb.Append(string.Format("R{0}: <span style='color:var(--success); font-weight:700;'>{1}</span>", dr["RoomNo"], card));
                }
                return sb.Length > 0 ? sb.ToString() : "-";
            }
        }
        catch { return "Error"; }
    }

    protected void gvStatus_RowDataBound(object sender, GridViewRowEventArgs e) 
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView drv = (DataRowView)e.Row.DataItem;
            bool hasExtension = drv["HasPendingExtension"] != DBNull.Value && Convert.ToBoolean(drv["HasPendingExtension"]);
            
            if (hasExtension)
            {
                // Highlight the ReservationNo cell (Index 0) in Yellow
                e.Row.Cells[0].BackColor = System.Drawing.Color.Yellow;
                e.Row.Cells[0].ToolTip = "Pending Extension Request";
            }
        }
    }
}
}



