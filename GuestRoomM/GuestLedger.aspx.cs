using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;

namespace GuestRoomApp.GuestRoomM
{
    public partial class GuestLedger : Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadActiveRooms();
                if (!string.IsNullOrEmpty(Request.QueryString["ResNo"]))
                {
                    txtSearch.Text = Request.QueryString["ResNo"];
                    GenerateLedger(txtSearch.Text);
                }
            }
        }

        private void LoadActiveRooms()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT DISTINCT a.RoomNo, ('Room ' + a.RoomNo) as Display 
                    FROM RoomAllocations a
                    INNER JOIN RoomReservations r ON a.ReservationNo = r.ReservationNo
                    WHERE a.CheckOutDate IS NULL OR a.CheckOutDate > DATEADD(day, -30, GETDATE())
                    ORDER BY a.RoomNo";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    DataTable dt = new DataTable();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    con.Open();
                    da.Fill(dt);
                    ddlActiveRooms.DataSource = dt;
                    ddlActiveRooms.DataTextField = "Display";
                    ddlActiveRooms.DataValueField = "RoomNo";
                    ddlActiveRooms.DataBind();
                    ddlActiveRooms.Items.Insert(0, new ListItem("-- Select Active Room --", "0"));
                }
            }
        }

        protected void ddlActiveRooms_Changed(object sender, EventArgs e)
        {
            // Global dropdown hidden, but keeping for compatibility if needed
        }

        protected void ddlResRooms_SelectedIndexChanged(object sender, EventArgs e)
        {
            GenerateLedger(lblResNo.Text, ddlResRooms.SelectedValue);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string term = txtSearch.Text.Trim();
            if (string.IsNullOrEmpty(term)) return;

            string resNo = term;

            // Try to find if it's a Member No instead of Res No
            using (SqlConnection con = new SqlConnection(connStr))
            {
                // 1. Check if it's a direct ReservationNo or ReceiptNo first
                string qCheck = "SELECT TOP 1 ReservationNo FROM RoomReservations WHERE ReservationNo = @T OR ReceiptNo = @T OR MembershipNo = @T ORDER BY ResDate DESC";
                using (SqlCommand cmd = new SqlCommand(qCheck, con))
                {
                    cmd.Parameters.AddWithValue("@T", term);
                    con.Open();
                    object r = cmd.ExecuteScalar();
                    if (r != null)
                    {
                        resNo = r.ToString();
                    }
                    else
                    {
                        // 2. If not found, check if it's a MembershipNo
                        // Prioritize active statuses, then latest date
                        string qMember = @"
                            SELECT TOP 1 ReservationNo 
                            FROM RoomReservations 
                            WHERE MembershipNo = @T 
                            ORDER BY 
                                CASE WHEN Status IN ('Occupied', 'Confirmed') THEN 0 ELSE 1 END,
                                ResDate DESC";
                        using (SqlCommand cmdM = new SqlCommand(qMember, con))
                        {
                            cmdM.Parameters.AddWithValue("@T", term);
                            object rM = cmdM.ExecuteScalar();
                            if (rM != null)
                            {
                                resNo = rM.ToString();
                            }
                        }
                    }
                }
            }

            GenerateLedger(resNo);
        }

        private void GenerateLedgerByRoom(string roomNo)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT DISTINCT r.ReservationNo 
                    FROM RoomReservations r
                    INNER JOIN RoomAllocations a ON r.ReservationNo = a.ReservationNo
                    WHERE a.RoomNo = @RoomNo";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@RoomNo", roomNo);
                    con.Open();
                    object resNo = cmd.ExecuteScalar();
                    if (resNo != null)
                    {
                        GenerateLedger(resNo.ToString());
                    }
                }
            }
        }

        private void FetchRoomRate(string roomNo, out decimal rent, out decimal tax)
        {
            rent = 5000; tax = 16;
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = "SELECT ISNULL(Rent, 5000) as Rent, ISNULL(TaxPercentage, 16) as Tax FROM RoomDefinitionNew WHERE RoomNo = @RoomNo";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@RoomNo", roomNo);
                        con.Open();
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                rent = Convert.ToDecimal(dr["Rent"]);
                                tax = Convert.ToDecimal(dr["Tax"]);
                            }
                        }
                    }
                }
            }
            catch { }
        }

        private void GenerateLedger(string resNo, string filterRoom = "0")
        {
            DataTable dtLedger = CreateLedgerSchema();

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();

                // 1. Header Info - Get reservation details (and check for related ones via ReceiptNo)
                string receiptNo = "";
                string qHeader = @"
                    SELECT TOP 1 * 
                    FROM RoomReservations 
                    WHERE ReservationNo = @ResNo 
                    ORDER BY 
                        CASE Status 
                            WHEN 'Occupied' THEN 1 
                            WHEN 'Completed' THEN 2 
                            WHEN 'Confirmed' THEN 3 
                            WHEN 'Pending' THEN 4 
                            ELSE 5 
                        END, 
                        ReservationID ASC";
                using (SqlCommand cmd = new SqlCommand(qHeader, con))
                {
                    cmd.Parameters.AddWithValue("@ResNo", resNo);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            receiptNo = dr["ReceiptNo"] == DBNull.Value ? "" : dr["ReceiptNo"].ToString();
                            lblGuestName.Text = dr["GuestName"].ToString();
                            lblResNo.Text = dr["ReservationNo"].ToString();
                            lblGuestOf.Text = dr["GuestOf"] == DBNull.Value ? "-" : dr["GuestOf"].ToString();
                            lblCheckIn.Text = Convert.ToDateTime(dr["FromDate"]).ToString("dd-MMM-yyyy");
                            lblCheckOut.Text = Convert.ToDateTime(dr["ToDate"]).ToString("dd-MMM-yyyy");
                            lblStatus.Text = dr["Status"].ToString();

                            // Capture the date for the ledger entry before closing
                            DateTime resDate = Convert.ToDateTime(dr["ResDate"]);
                            ViewState["ResDate_Temp"] = resDate;
                        }
                        else
                        {
                            pnlLedger.Visible = false;
                            pnlEmpty.Visible = true;
                            return;
                        }
                    }
                }

                // If we have a ReceiptNo, we should fetch charges for ALL reservations under this ReceiptNo (handling room shifts)
                string resCriteria = "ReservationNo = @ResNo";
                if (!string.IsNullOrEmpty(receiptNo))
                {
                    resCriteria = "ReservationNo IN (SELECT ReservationNo FROM RoomReservations WHERE ReceiptNo = @RecNo)";

                    // Adjust header dates to show the full stay range if shifted
                    using (SqlCommand cmdDates = new SqlCommand("SELECT MIN(FromDate), MAX(ToDate) FROM RoomReservations WHERE ReceiptNo = @RecNo", con))
                    {
                        cmdDates.Parameters.AddWithValue("@RecNo", receiptNo);
                        using (SqlDataReader drD = cmdDates.ExecuteReader())
                        {
                            if (drD.Read())
                            {
                                lblCheckIn.Text = Convert.ToDateTime(drD[0]).ToString("dd-MMM-yyyy");
                                lblCheckOut.Text = Convert.ToDateTime(drD[1]).ToString("dd-MMM-yyyy");
                            }
                        }
                    }
                }

                // Get allocated rooms and populate dropdown
                PopulateReservationRooms(resNo, receiptNo);

                string roomsList = GetAssignedRoomsAcrossSegments(resNo, receiptNo);
                lblRooms.Text = "Room(s) [" + roomsList + "]";

                // Ensure the filter dropdown matches the current selection
                if (filterRoom != "0")
                {
                    if (ddlResRooms.Items.FindByValue(filterRoom) != null)
                        ddlResRooms.SelectedValue = filterRoom;
                }

                // ── AGGREGATE ADVANCE PAYMENT ──
                decimal totalAdvance = 0;
                string qAdv = string.Format("SELECT ISNULL(SUM(AdvancePayment), 0) FROM RoomReservations WHERE {0}", resCriteria);
                using (SqlCommand cmdSum = new SqlCommand(qAdv, con))
                {
                    cmdSum.Parameters.AddWithValue("@ResNo", resNo);
                    if (!string.IsNullOrEmpty(receiptNo)) cmdSum.Parameters.AddWithValue("@RecNo", receiptNo);
                    totalAdvance = Convert.ToDecimal(cmdSum.ExecuteScalar());
                }

                DateTime ledgerDate = ViewState["ResDate_Temp"] != null ? (DateTime)ViewState["ResDate_Temp"] : DateTime.Now;
                dtLedger.Rows.Add(ledgerDate, "ADV-REC", "Initial Advance Payment", 0, totalAdvance, 0);

                // Add mid-stay payments
                try
                {
                    string qPaid = string.Format("SELECT ISNULL(SUM(AmountPaid), 0) FROM GR_Bills WHERE {0} AND BillNo LIKE 'ADV-MID-%'", resCriteria);
                    using (SqlCommand cmdPaid = new SqlCommand(qPaid, con))
                    {
                        cmdPaid.Parameters.AddWithValue("@ResNo", resNo);
                        if (!string.IsNullOrEmpty(receiptNo)) cmdPaid.Parameters.AddWithValue("@RecNo", receiptNo);
                        totalAdvance += Convert.ToDecimal(cmdPaid.ExecuteScalar());
                    }
                }
                catch { }
                lblSumAdvance.Text = totalAdvance.ToString("N0");

                // If filtering by room, only show advance if specifically selected or "All"
                if (filterRoom != "0")
                {
                    // Optionally hide advance if a specific room is selected? 
                    // Usually we keep advance visible for context.
                }

                // 2. Room Charges - Calculate Accrued Rent for all segments (not yet audited)
                // We use logic similar to ManageBills to handle stay factors and partial checkouts
                decimal totalAccrued = 0;
                try
                {
                    string qStay = string.Format(@"
                        SELECT ra.RoomNo, ra.AllocatedDate, ra.CheckOutDate, ISNULL(ra.StayFactor, 1.0) as StayFactor, rd.Rent, rd.TaxPercentage, ra.LastChargedDate, rr.ToDate
                        FROM RoomAllocations ra
                        INNER JOIN RoomDefinitionNew rd ON ra.RoomNo = rd.RoomNo
                        INNER JOIN RoomReservations rr ON ra.ReservationNo = rr.ReservationNo
                        WHERE {0}", resCriteria);

                    using (SqlCommand cmd = new SqlCommand(qStay, con))
                    {
                        cmd.Parameters.AddWithValue("@ResNo", resNo);
                        if (!string.IsNullOrEmpty(receiptNo)) cmd.Parameters.AddWithValue("@RecNo", receiptNo);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                DateTime chkIn = Convert.ToDateTime(dr["AllocatedDate"]);
                                DateTime plannedCheckOut = Convert.ToDateTime(dr["ToDate"]);
                                DateTime lastAudit = dr["LastChargedDate"] == DBNull.Value ? chkIn.Date : Convert.ToDateTime(dr["LastChargedDate"]).Date;

                                // For active stays, calculate up to planned ToDate, extending to today if overstayed
                                DateTime effCheckOut = dr["CheckOutDate"] == DBNull.Value
                                    ? (DateTime.Now.Date > plannedCheckOut.Date ? DateTime.Now : plannedCheckOut)
                                    : Convert.ToDateTime(dr["CheckOutDate"]);
                                double stayFactor = Convert.ToDouble(dr["StayFactor"]);
                                decimal rate = Convert.ToDecimal(dr["Rent"]);
                                decimal taxPct = Convert.ToDecimal(dr["TaxPercentage"]);

                                // Calculate total nights for this segment
                                int fullNights = (effCheckOut.Date - chkIn.Date).Days;
                                double totalSegmentNights = fullNights;

                                // Apply stay factor for partial days or enforce minimum 1 night for active stays
                                if (stayFactor < 1.0 && totalSegmentNights > 0)
                                {
                                    totalSegmentNights += stayFactor;
                                }
                                else if (totalSegmentNights < 1)
                                {
                                    // If active stay, always assume at least 1 night is accrued/planned for the current date
                                    if (dr["CheckOutDate"] == DBNull.Value)
                                        totalSegmentNights = 1.0;
                                    else
                                        totalSegmentNights = 1.0; // Minimum 1 night for any stay that actually happened
                                }

                                // Nights already audited/charged via Night Audit or Check-In
                                int auditedNights = dr["LastChargedDate"] == DBNull.Value ? 0 : (lastAudit - chkIn.Date).Days + 1;
                                if (auditedNights < 0) auditedNights = 0;

                                double pendingNights = totalSegmentNights - (double)auditedNights;

                                if (pendingNights > 0)
                                {
                                    string rNo = dr["RoomNo"].ToString().Trim();

                                    // FILTER: Skip if we are filtering by another room (flexible matching)
                                    if (filterRoom != "0" && rNo != filterRoom.Trim() && rNo.TrimStart('0') != filterRoom.Trim().TrimStart('0')) continue;

                                    // Loop through each pending night to show breakdown
                                    DateTime nextChargeDate = (dr["LastChargedDate"] == DBNull.Value) ? chkIn.Date : lastAudit.AddDays(1);
                                    double nightsProcessed = 0;

                                    while (nightsProcessed < pendingNights)
                                    {
                                        double currentNightFactor = 1.0;
                                        // Handle the last night if it's a fractional stay factor (e.g. 0.5)
                                        if (pendingNights - nightsProcessed < 1.0)
                                        {
                                            currentNightFactor = pendingNights - nightsProcessed;
                                        }

                                        decimal nightRent = rate * (decimal)currentNightFactor;
                                        decimal nightTax = Math.Round(nightRent * taxPct / 100, 2);

                                        totalAccrued += (nightRent + nightTax);

                                        string dateLabel = nextChargeDate.ToString("dd-MMM");
                                        string nightDesc = string.Format("Accrued Rent (Room {0}) - {1}", rNo, dateLabel);
                                        if (currentNightFactor < 1.0) nightDesc += string.Format(" ({0:0.##} day)", currentNightFactor);

                                        dtLedger.Rows.Add(nextChargeDate, "RENT-ACC", nightDesc, nightRent, 0, 0);
                                        if (nightTax > 0)
                                            dtLedger.Rows.Add(nextChargeDate, "TAX-ACC", "Accrued GST/Tax (Room " + rNo + ") - " + dateLabel, nightTax, 0, 0);

                                        nextChargeDate = nextChargeDate.AddDays(1);
                                        nightsProcessed += 1.0;
                                    }
                                }
                            }
                        }
                    }
                }
                catch { }

                // Force populate dropdown again in case it missed something the first time
                PopulateReservationRooms(resNo, receiptNo);

                lblSumRoomCharges.Text = totalAccrued.ToString("N0");

                // 3. Service Charges & Audited Rent from GR_RoomServices
                string qServices = string.Format("SELECT * FROM GR_RoomServices WHERE {0} ORDER BY OrderDate", resCriteria);
                using (SqlCommand cmd = new SqlCommand(qServices, con))
                {
                    cmd.Parameters.AddWithValue("@ResNo", resNo);
                    if (!string.IsNullOrEmpty(receiptNo)) cmd.Parameters.AddWithValue("@RecNo", receiptNo);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        decimal totalServices = 0;
                        decimal totalAuditedRent = 0;
                        // Use a dictionary to group facility services by InvoiceNo
                        var groupedServices = new Dictionary<string, FacilityGroup>();

                        while (dr.Read())
                        {
                            decimal amt = dr["TotalAmount"] == DBNull.Value ? 0 : Convert.ToDecimal(dr["TotalAmount"]);
                            string svcName = dr["ServiceName"].ToString();
                            DateTime orderDate = Convert.ToDateTime(dr["OrderDate"]);
                            string roomVal = dr["RoomNo"] == DBNull.Value ? "0" : dr["RoomNo"].ToString().Trim();

                            // FILTER: Skip if filtering by another room (flexible matching)
                            if (filterRoom != "0" && roomVal != "0" && roomVal != filterRoom.Trim() && roomVal.TrimStart('0') != filterRoom.Trim().TrimStart('0')) continue;

                            string roomNoLabel = roomVal == "0" ? "" : " (Room " + roomVal + ")";
                            string invNo = dr["InvoiceNo"] == DBNull.Value ? "SVC-" + dr["ServiceID"].ToString() : dr["InvoiceNo"].ToString();
                            string qtyStr = dr["Qty"].ToString() == "1" ? "" : " (Qty: " + dr["Qty"] + ")";

                            if (svcName.Contains("Room Rent") || svcName.Contains("GST on Room") || svcName.Contains("Facility Charge"))
                            {
                                totalAuditedRent += amt;
                                dtLedger.Rows.Add(orderDate, invNo, svcName + qtyStr + roomNoLabel, amt, 0, 0);
                            }
                            else
                            {
                                totalServices += amt;
                                if (groupedServices.ContainsKey(invNo))
                                {
                                    groupedServices[invNo].Names.Append(", " + svcName + qtyStr);
                                    groupedServices[invNo].Amount += amt;
                                }
                                else
                                {
                                    groupedServices[invNo] = new FacilityGroup { Date = orderDate, Names = new StringBuilder(svcName + qtyStr), Amount = amt, Room = roomNoLabel };
                                }
                            }
                        }

                        foreach (var kvp in groupedServices)
                        {
                            dtLedger.Rows.Add(kvp.Value.Date, kvp.Key, kvp.Value.Names.ToString() + kvp.Value.Room, kvp.Value.Amount, 0, 0);
                        }

                        // Update summaries
                        decimal pendingAudit = decimal.Parse(lblSumRoomCharges.Text);
                        lblSumRoomCharges.Text = (totalAuditedRent + pendingAudit).ToString("N0");
                        lblSumServices.Text = totalServices.ToString("N0");
                    }
                }

                // 4. Billed Totals & Payments from GR_Bills
                // To achieve 100% accuracy, we compare the total audited services against the final bill totals.
                string qPayments = string.Format(@"
                    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'GR_Bills')
                        SELECT * FROM GR_Bills WHERE {0} ORDER BY BillDate
                    ELSE
                        SELECT NULL as BillNo, NULL as BillDate, NULL as AmountPaid WHERE 1=0", resCriteria);

                using (SqlCommand cmd = new SqlCommand(qPayments, con))
                {
                    cmd.Parameters.AddWithValue("@ResNo", resNo);
                    if (!string.IsNullOrEmpty(receiptNo)) cmd.Parameters.AddWithValue("@RecNo", receiptNo);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        decimal totalMiscPay = 0;
                        while (dr.Read())
                        {
                            if (dr["BillNo"] != DBNull.Value)
                            {
                                string billNo = dr["BillNo"].ToString();
                                DateTime bDate = Convert.ToDateTime(dr["BillDate"]);
                                decimal paid = Convert.ToDecimal(dr["AmountPaid"]);
                                string roomVal = dr["RoomNo"].ToString().Trim();

                                // FILTER: Skip if filtering by another room (flexible matching)
                                if (filterRoom != "0" && roomVal != "0" && roomVal != filterRoom.Trim() && roomVal.TrimStart('0') != filterRoom.Trim().TrimStart('0')) continue;

                                string roomInfo = (roomVal == "0") ? "" : " (Room " + roomVal + ")";

                                if (billNo.StartsWith("ADV-MID-"))
                                {
                                    totalMiscPay += paid;
                                    // Show all mid-stay transactions in the Credit column for consistency (reversals as negative credits)
                                    string desc = (paid < 0 ? "Payment Reversal / Adjustment" : "Mid-Stay Payment / Credit") + roomInfo;
                                    dtLedger.Rows.Add(bDate, billNo, desc, 0, paid, 0);
                                }
                                else
                                {
                                    // FINAL BILL 
                                    decimal bRent = Convert.ToDecimal(dr["NoOfRooms"]) * Convert.ToDecimal(dr["NoOfNights"]) * Convert.ToDecimal(dr["RoomRentPerNight"]);
                                    decimal bTax = Math.Round(bRent * Convert.ToDecimal(dr["TaxPercent"]) / 100, 2);
                                    decimal bOther = Convert.ToDecimal(dr["OtherCharges"]);
                                    decimal bGross = bRent + bTax + bOther;

                                    // Check how much of this room's charges were already posted as Debits.
                                    // Scope to THIS bill's room to avoid absorbing other rooms' accrued rent.
                                    decimal alreadyPosted = 0;
                                    foreach (DataRow row in dtLedger.Rows)
                                    {
                                        string rowRef = row["RefNo"].ToString();
                                        if (rowRef == "ADV-REC" || rowRef.StartsWith("ADV-MID-")) continue;
                                        // For a room-specific bill, only count entries that belong to that room
                                        if (!string.IsNullOrEmpty(roomVal) && roomVal != "0")
                                        {
                                            string rowDesc = row["Description"].ToString();
                                            if (!rowDesc.Contains("Room " + roomVal)) continue;
                                        }
                                        alreadyPosted += Convert.ToDecimal(row["Debit"]);
                                    }

                                    decimal adjustment = bGross - alreadyPosted;
                                    if (adjustment != 0)
                                    {
                                        dtLedger.Rows.Add(bDate, billNo, "Closing Bill Adjustment" + roomInfo, (adjustment > 0 ? adjustment : 0), (adjustment < 0 ? Math.Abs(adjustment) : 0), 0);
                                    }

                                    dtLedger.Rows.Add(bDate, billNo, "Final Settlement Payment" + roomInfo, 0, paid, 0);
                                    totalMiscPay += paid;
                                }
                            }
                        }
                        lblSumPayments.Text = totalMiscPay.ToString("N0");
                    }
                }
            }

            // Calculate running balance
            DataView dv = dtLedger.DefaultView;
            dv.Sort = "LDate ASC";
            DataTable dtSorted = dv.ToTable();
            decimal runningBal = 0, totalDebit = 0, totalCredit = 0;

            foreach (DataRow row in dtSorted.Rows)
            {
                decimal dr = Convert.ToDecimal(row["Debit"]);
                decimal cr = Convert.ToDecimal(row["Credit"]);
                totalDebit += dr;
                totalCredit += cr;
                runningBal += (dr - cr);
                row["Balance"] = runningBal;
            }

            rptLedger.DataSource = dtSorted;
            rptLedger.DataBind();

            decimal netBalance = totalDebit - totalCredit;
            lblSumGross.Text = totalDebit.ToString("N0");
            lblNetBalance.Text = "PKR " + netBalance.ToString("N0");
            lblLedgerBalance.Text = netBalance.ToString("N0");

            pnlLedger.Visible = true;
            pnlEmpty.Visible = false;
        }

        private void PopulateReservationRooms(string resNo, string receiptNo)
        {
            if (ddlResRooms.Items.Count > 0 && !string.IsNullOrEmpty(lblResNo.Text) && lblResNo.Text == resNo) return;

            ddlResRooms.Items.Clear();
            ddlResRooms.Items.Add(new ListItem("All Rooms", "0"));

            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT DISTINCT ra.RoomNo, rd.Status 
                    FROM RoomAllocations ra
                    LEFT JOIN RoomDefinitionNew rd ON ra.RoomNo = rd.RoomNo
                    WHERE ra.ReservationNo = @ResNo";
                
                if (!string.IsNullOrEmpty(receiptNo))
                {
                    query = @"
                        SELECT DISTINCT ra.RoomNo, rd.Status 
                        FROM RoomAllocations ra
                        LEFT JOIN RoomDefinitionNew rd ON ra.RoomNo = rd.RoomNo
                        WHERE ra.ReservationNo IN (SELECT ReservationNo FROM RoomReservations WHERE ReceiptNo = @RecNo)";
                }

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@ResNo", resNo);
                    if (!string.IsNullOrEmpty(receiptNo)) cmd.Parameters.AddWithValue("@RecNo", receiptNo);
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string rNo = dr["RoomNo"].ToString();
                            string status = dr["Status"].ToString();
                            ListItem item = new ListItem("Room " + rNo, rNo);
                            
                            // Apply Colors based on status
                            if (status.Equals("Occupied", StringComparison.OrdinalIgnoreCase))
                                item.Attributes.Add("style", "color: #c62828; font-weight: bold; background: #ffebee;");
                            else
                                item.Attributes.Add("style", "color: #2e7d32; font-weight: bold; background: #e8f5e9;");

                            ddlResRooms.Items.Add(item);
                        }
                    }
                }
            }
        }

        private string GetAssignedRoomsAcrossSegments(string resNo, string receiptNo)
        {
            string rooms = "";
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "SELECT DISTINCT RoomNo FROM RoomAllocations WHERE ReservationNo = @ResNo";
                if (!string.IsNullOrEmpty(receiptNo))
                {
                    query = "SELECT DISTINCT RoomNo FROM RoomAllocations WHERE ReservationNo IN (SELECT ReservationNo FROM RoomReservations WHERE ReceiptNo = @RecNo)";
                }

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@ResNo", resNo);
                    if (!string.IsNullOrEmpty(receiptNo)) cmd.Parameters.AddWithValue("@RecNo", receiptNo);
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    List<string> roomList = new List<string>();
                    while (dr.Read())
                    {
                        roomList.Add(dr["RoomNo"].ToString());
                    }
                    rooms = string.Join(", ", roomList);
                }
            }
            return string.IsNullOrEmpty(rooms) ? "Not Assigned" : rooms;
        }

        private DataTable CreateLedgerSchema()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("LDate", typeof(DateTime));
            dt.Columns.Add("RefNo", typeof(string));
            dt.Columns.Add("Description", typeof(string));
            dt.Columns.Add("Debit", typeof(decimal));
            dt.Columns.Add("Credit", typeof(decimal));
            dt.Columns.Add("Balance", typeof(decimal));
            return dt;
        }

        private class FacilityGroup
        {
            public DateTime Date { get; set; }
            public StringBuilder Names { get; set; }
            public decimal Amount { get; set; }
            public string Room { get; set; }
        }
    }
}
