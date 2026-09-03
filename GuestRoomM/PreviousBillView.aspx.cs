using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;

namespace GuestRoomApp.GuestRoomM
{
    public partial class PreviousBillView : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Page starts empty â€“ waits for search
        }

        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
        //  SEARCH BUTTON
        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string term = txtSearch.Text.Trim();
            if (string.IsNullOrEmpty(term))
            {
                lblMsg.Text = "Please enter a Reservation No., Bill No., Member No., or Guest Name.";
                return;
            }
            LoadAllBills(term);
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            lblMsg.Text = "";
            gvBills.DataSource = null;
            gvBills.DataBind();
            gvServices.DataSource = null;
            gvServices.DataBind();
            pnlSummary.Visible  = false;
            pnlServices.Visible = false;
        }

        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
        //  LOAD ALL BILLS (Settled + Unsettled) for a Reservation
        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
        private void LoadAllBills(string search)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    // Bring ALL bills (any status), excluding ADV-MID interim records
                    // BalanceDue = GrossTotal - AdvancePaid - AmountPaid
                    string sql = @"
                        SELECT 
                            b.BillNo,
                            b.ReservationNo,
                            b.BillDate,
                            b.GuestName,
                            b.GuestOf,
                            b.ClubName,
                            b.RoomNo,
                            b.FromDate,
                            b.ToDate,
                            b.NoOfRooms,
                            b.NoOfNights,
                            b.RoomRentPerNight,
                            b.TaxPercent,
                            b.OtherCharges,
                            ISNULL(b.GrossTotal, 0)    AS GrossTotal,
                            ISNULL(b.TotalRoomRent, 0) AS TotalRoomRent,
                            ISNULL(b.TaxAmount, 0)     AS TaxAmount,
                            ISNULL(b.AdvancePaid, 0)   AS AdvancePaid,
                            ISNULL(b.AmountPaid, 0)    AS AmountPaid,
                            ISNULL(b.Remarks, '')       AS Remarks,
                            b.BillStatus,
                            ISNULL(r.MembershipNo, '')  AS MembershipNo,
                            -- Compute balance
                            CASE 
                                WHEN UPPER(ISNULL(b.BillStatus,'')) IN ('SETTLED','REFUNDED') THEN 0
                                WHEN (ISNULL(b.GrossTotal,0) - ISNULL(b.AdvancePaid,0) - ISNULL(b.AmountPaid,0)) < 0 THEN 0
                                ELSE (ISNULL(b.GrossTotal,0) - ISNULL(b.AdvancePaid,0) - ISNULL(b.AmountPaid,0))
                            END AS BalanceDue
                        FROM GR_Bills b
                        LEFT JOIN RoomReservations r ON b.ReservationNo = r.ReservationNo
                        WHERE b.BillNo NOT LIKE 'ADV-MID-%'
                          AND (
                                b.ReservationNo LIKE @S
                             OR b.BillNo        LIKE @S
                             OR b.GuestName     LIKE @S
                             OR b.ReceiptNo     LIKE @S
                             OR r.MembershipNo  LIKE @S
                          )
                        ORDER BY b.BillDate DESC";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@S", "%" + search + "%");
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        // â”€â”€ Compute summary stats â”€â”€
                        int total = dt.Rows.Count;
                        int settled = 0, unsettled = 0;
                        decimal totalGross = 0;
                        foreach (DataRow row in dt.Rows)
                        {
                            string st = row["BillStatus"].ToString().ToUpper();
                            if (st == "SETTLED" || st == "REFUNDED") settled++;
                            else unsettled++;
                            totalGross += Convert.ToDecimal(row["GrossTotal"]);
                        }

                        lblTotalBills.Text    = total.ToString();
                        lblSettledCount.Text  = settled.ToString();
                        lblUnsettledCount.Text = unsettled.ToString();
                        lblTotalGross.Text    = totalGross.ToString("N0");
                        pnlSummary.Visible    = (total > 0);

                        if (total == 0)
                            lblMsg.Text = "\"" + search + "\" No bill Found Against This ResNo.";
                        else
                            lblMsg.Text = total + " bill(s) mila â€” " + settled + " Settled, " + unsettled + " Unsettled";

                        gvBills.DataSource = dt;
                        gvBills.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                lblMsg.Text = "Error: " + ex.Message;
            }
        }

        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
        //  ROW COMMAND â€” View Bill
        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
        protected void gvBills_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ViewBill")
            {
                string billNo = e.CommandArgument.ToString();
                LoadBillDetails(billNo);
            }
        }

        private void LoadBillDetails(string billNo)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string sql = @"
                        SELECT *,
                            CASE 
                                WHEN UPPER(ISNULL(BillStatus,'')) IN ('SETTLED','REFUNDED') THEN 0
                                WHEN (ISNULL(GrossTotal,0) - ISNULL(AdvancePaid,0) - ISNULL(AmountPaid,0)) < 0 THEN 0
                                ELSE (ISNULL(GrossTotal,0) - ISNULL(AdvancePaid,0) - ISNULL(AmountPaid,0))
                            END AS BalanceDue
                        FROM GR_Bills WHERE BillNo = @B";
                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@B", billNo);
                        new SqlDataAdapter(cmd).Fill(dt);
                    }

                    if (dt.Rows.Count > 0)
                    {
                        DataRow br = dt.Rows[0];
                        string resNo  = br["ReservationNo"].ToString();
                        string status = br["BillStatus"].ToString();

                        // â”€â”€ Load services for this reservation â”€â”€
                        LoadServices(resNo);
                        pnlServices.Visible = true;

                        // â”€â”€ Derived values â”€â”€
                        decimal rooms     = Convert.ToDecimal(br["NoOfRooms"]);
                        decimal nights    = Convert.ToDecimal(br["NoOfNights"]);
                        decimal rate      = Convert.ToDecimal(br["RoomRentPerNight"]);
                        decimal taxPct    = Convert.ToDecimal(br["TaxPercent"]);
                        decimal other     = Convert.ToDecimal(br["OtherCharges"]);
                        decimal advance   = Convert.ToDecimal(br["AdvancePaid"]);
                        decimal paid      = Convert.ToDecimal(br["AmountPaid"]);
                        decimal gross     = Convert.ToDecimal(br["GrossTotal"]);
                        decimal roomRent  = Convert.ToDecimal(br["TotalRoomRent"]);
                        decimal tax       = Convert.ToDecimal(br["TaxAmount"]);
                        decimal balance   = Convert.ToDecimal(br["BalanceDue"]);

                        if (gross == 0) gross = roomRent + tax + other;
                        if (roomRent == 0) roomRent = rooms * nights * rate;
                        if (tax == 0) tax = Math.Round(roomRent * taxPct / 100, 2);

                        // â”€â”€ Emit JS to populate detail panel â”€â”€
                        var sb = new StringBuilder();
                        sb.Append("showBillDetail({");
                        sb.Append("billNo:'"     + Esc(billNo) + "',");
                        sb.Append("statusLabel:'" + Esc(GetStatusLabel(status)) + "',");
                        sb.Append("badgeClass:'"  + Esc(GetStatusBadgeClass(status)) + "',");
                        sb.Append("date:'"        + (br["BillDate"] != DBNull.Value ? Convert.ToDateTime(br["BillDate"]).ToString("dd-MMM-yyyy") : "") + "',");
                        sb.Append("resNo:'"       + Esc(resNo) + "',");
                        sb.Append("guest:'"       + Esc(br["GuestName"].ToString()) + "',");
                        sb.Append("roomNo:'"      + Esc(br["RoomNo"].ToString()) + "',");
                        sb.Append("fromDate:'"    + (br["FromDate"] != DBNull.Value ? Convert.ToDateTime(br["FromDate"]).ToString("dd-MMM-yyyy") : "") + "',");
                        sb.Append("toDate:'"      + (br["ToDate"] != DBNull.Value   ? Convert.ToDateTime(br["ToDate"]).ToString("dd-MMM-yyyy")   : "") + "',");
                        sb.Append("rooms:"        + rooms + ",");
                        sb.Append("nights:"       + nights + ",");
                        sb.Append("rate:"         + rate + ",");
                        sb.Append("roomRent:"     + roomRent + ",");
                        sb.Append("tax:"          + tax + ",");
                        sb.Append("other:"        + other + ",");
                        sb.Append("gross:"        + gross + ",");
                        sb.Append("advance:"      + advance + ",");
                        sb.Append("paid:"         + paid + ",");
                        sb.Append("balance:"      + balance + ",");
                        sb.Append("remarks:'"     + Esc(br["Remarks"].ToString()) + "'");
                        sb.Append("});");

                        ScriptManager.RegisterStartupScript(this, GetType(), "ShowDetail", sb.ToString(), true);
                    }
                }
            }
            catch (Exception ex)
            {
                lblMsg.Text = "Error loading bill: " + ex.Message;
            }
        }

        private void LoadServices(string resNo)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string sql = @"SELECT OrderDate, ServiceName, Qty, UnitPrice,
                                          (Qty * UnitPrice) AS TotalAmount, Status
                                   FROM GR_RoomServices
                                   WHERE ReservationNo = @R
                                   ORDER BY OrderDate ASC";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@R", resNo);
                        DataTable dt = new DataTable();
                        new SqlDataAdapter(cmd).Fill(dt);
                        gvServices.DataSource = dt;
                        gvServices.DataBind();
                    }
                }
            }
            catch { }
        }

        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
        //  HELPER METHODS (called from ASPX via <%# ... %>)
        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
        protected string GetStatusBadgeClass(string status)
        {
            switch ((status ?? "").ToUpper())
            {
                case "SETTLED":  return "badge badge-settled";
                case "REFUNDED": return "badge badge-refunded";
                case "DRAFT":    return "badge badge-draft";
                default:         return "badge badge-unsettled";
            }
        }

        protected string GetStatusLabel(string status)
        {
            switch ((status ?? "").ToUpper())
            {
                case "SETTLED":  return "Settled âœ“";
                case "REFUNDED": return "Refunded";
                case "DRAFT":    return "Draft / Pending";
                default:         return string.IsNullOrEmpty(status) ? "Unsettled" : status;
            }
        }

        private string Esc(string s)
        {
            return (s ?? "").Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
        }
    }
}


