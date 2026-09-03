//using System;
//using System.Configuration;
//using System.Data;
//using System.Data.SqlClient;
//using System.Web.UI;
//using System.Web.UI.WebControls;
//using System.Text;

//namespace GuestRoomApp.GuestRoomM
//{
//    public partial class ManageBills : System.Web.UI.Page
//    {
//        private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

//        protected void Page_Load(object sender, EventArgs e)
//        {
//            if (!IsPostBack)
//            {
//                LoadBillsHistory(null);
//                SetPanelsVisible(false);

//                if (!string.IsNullOrEmpty(Request.QueryString["ResNo"]))
//                {
//                    txtSearchRes.Text = Request.QueryString["ResNo"];
//                    LoadReservationDetails(txtSearchRes.Text);
//                }
//            }
//        }

//        protected void btnSearchRes_Click(object sender, EventArgs e)
//        {
//            string search = txtSearchRes.Text.Trim();
//            if (string.IsNullOrEmpty(search)) { ShowMessage("Please enter Reservation No or Receipt No.", false); return; }
//            LoadReservationDetails(search);
//        }

//        private void LoadReservationDetails(string searchNo)
//        {
//            try
//            {
//                using (SqlConnection con = new SqlConnection(connStr))
//                using (SqlCommand cmd = new SqlCommand("sp_GR_GetReservationForBill", con))
//                {
//                    cmd.CommandType = CommandType.StoredProcedure;
//                    cmd.Parameters.AddWithValue("@SearchNo", searchNo);
//                    con.Open();
//                    string resNo = "", recNo = "", guest = "", guestOf = "", club = "", status = "", allocRooms = "", existBill = "";
//                    int rooms = 0; DateTime from = DateTime.MinValue, to = DateTime.MinValue;
//                    decimal rent = 0, taxPct = 0;

//                    using (SqlDataReader dr = cmd.ExecuteReader())
//                    {
//                        if (!dr.Read())
//                        {
//                            ShowMessage("Reservation not found: " + searchNo, false);
//                            SetPanelsVisible(false);
//                            return;
//                        }

//                        resNo = dr["ReservationNo"].ToString();
//                        recNo = dr["ReceiptNo"].ToString();
//                        guest = dr["GuestName"].ToString();
//                        guestOf = dr["GuestOf"].ToString();
//                        club = dr["ClubName"].ToString();
//                        status = dr["Status"].ToString();
//                        rooms = Convert.ToInt32(dr["NoOfRooms"]);
//                        from = Convert.ToDateTime(dr["FromDate"]);
//                        to = Convert.ToDateTime(dr["ToDate"]);
//                        rent = Convert.ToDecimal(dr["RentPerRoom"]);
//                        taxPct = Convert.ToDecimal(dr["TaxPercent"]);
//                        allocRooms = dr["AllocatedRooms"].ToString();
//                        existBill = dr["ExistingBillNo"].ToString();
//                    }

//                    int nights = (to - from).Days;
//                    if (nights < 1) nights = 1;

//                    // Get the receipt number for group advance calculation
//                    string groupRecNo = recNo;
//                    if (string.IsNullOrEmpty(groupRecNo))
//                    {
//                        using (SqlCommand cmdR = new SqlCommand("SELECT TOP 1 ReceiptNo FROM RoomReservations WHERE ReservationNo = @ResNo", con))
//                        {
//                            cmdR.Parameters.AddWithValue("@ResNo", resNo);
//                            object r = cmdR.ExecuteScalar();
//                            if (r != null && r != DBNull.Value) groupRecNo = r.ToString();
//                        }
//                    }

//                    // Calculate detailed stay information
//                    double weightedNights = 0;
//                    decimal totalAccurateRent = 0;
//                    StringBuilder sbDesc = new StringBuilder();
//                    int actualCount = 0;

//                    CalculateDetailedStay(resNo, "0", to, out actualCount, out weightedNights, out totalAccurateRent, out sbDesc);

//                    if (actualCount > 0)
//                    {
//                        if (rooms < 1) rooms = 1;
//                        double avgNights = weightedNights / rooms;
//                        nights = (int)Math.Ceiling(avgNights);

//                        if (rooms > 0 && nights > 0)
//                            rent = totalAccurateRent / (rooms * (decimal)avgNights);

//                        txtNoOfNights.Text = avgNights.ToString("0.##");
//                    }
//                    else
//                    {
//                        sbDesc.Append("No allocations found");
//                        totalAccurateRent = (rooms * nights * rent);
//                    }

//                    hfRoomDescription.Value = sbDesc.ToString();

//                    // Check for existing bill - prioritize settled bills
//                    if (string.IsNullOrEmpty(existBill))
//                    {
//                        using (SqlCommand cmdEx = new SqlCommand(
//                            "SELECT TOP 1 BillNo FROM GR_Bills WHERE ReservationNo = @R AND RoomNo = '0' AND BillNo NOT LIKE 'ADV-MID-%' AND UPPER(BillStatus) IN ('SETTLED','REFUNDED') ORDER BY BillDate DESC", con))
//                        {
//                            cmdEx.Parameters.AddWithValue("@R", resNo);
//                            object b = cmdEx.ExecuteScalar();
//                            if (b != null)
//                                existBill = b.ToString();
//                            else
//                            {
//                                // Check for draft bill if no settled bill exists
//                                cmdEx.CommandText = "SELECT TOP 1 BillNo FROM GR_Bills WHERE ReservationNo = @R AND RoomNo = '0' AND BillNo NOT LIKE 'ADV-MID-%' AND UPPER(BillStatus) = 'DRAFT' ORDER BY BillDate DESC";
//                                b = cmdEx.ExecuteScalar();
//                                if (b != null) existBill = b.ToString();
//                            }
//                        }
//                    }

//                    // Set guest information labels
//                    lblGuestName.Text = guest;
//                    lblGuestOf.Text = guestOf;
//                    lblClubName.Text = string.IsNullOrEmpty(club) ? "" : club;
//                    lblResNo.Text = resNo;
//                    lblRecNo.Text = recNo;

//                    // Determine reservation status based on allocations
//                    string finalStatus = status;
//                    try
//                    {
//                        using (SqlCommand cmdStat = new SqlCommand(@"
//                SELECT 
//                    COUNT(*) as Total,
//                    SUM(CASE WHEN CheckOutDate IS NULL THEN 1 ELSE 0 END) as Occupied
//                FROM RoomAllocations WHERE ReservationNo = @R", con))
//                        {
//                            cmdStat.Parameters.AddWithValue("@R", resNo);
//                            using (SqlDataReader drStat = cmdStat.ExecuteReader())
//                            {
//                                if (drStat.Read())
//                                {
//                                    int total = Convert.ToInt32(drStat["Total"]);
//                                    int occupied = Convert.ToInt32(drStat["Occupied"]);
//                                    if (total > 0)
//                                        finalStatus = occupied > 0 ? "Occupied" : "Completed";
//                                }
//                            }
//                        }
//                    }
//                    catch { }
//                    lblResStatus.Text = finalStatus;

//                    // Store hidden values
//                    hfReservationNo.Value = resNo;
//                    hfReceiptNo.Value = recNo;
//                    lblAllocRooms.Text = string.IsNullOrEmpty(allocRooms) ? "Not allocated yet" : allocRooms;
//                    lblFromDate.Text = from.ToString("dd-MMM-yyyy");
//                    lblToDate.Text = to.ToString("dd-MMM-yyyy");

//                    // Reset input fields
//                    txtManualPay.Text = "0";
//                    txtCashPayBack.Text = "0";
//                    txtRemarks.Text = "";
//                    hfBillStatus.Value = "DRAFT";

//                    // Set basic room and rate information
//                    txtNoOfRooms.Text = rooms.ToString();
//                    txtNoOfNights.Text = nights.ToString();
//                    txtRentPerNight.Text = rent.ToString("0");
//                    txtTaxPercent.Text = taxPct.ToString("0");

//                    // FIX: Calculate advance for "All Rooms" view - this should NOT subtract settled room bills
//                    // because we're showing the total pending amount across ALL rooms
//                    decimal totalAdvance = 0;
//                    string groupCriteria = string.IsNullOrEmpty(groupRecNo) ? "ReservationNo = @ResNo" : "ReceiptNo = @RecNo";

//                    // Get total advances from reservations and mid-stay payments
//                    string qAdvTotal = string.Format(@"
//                SELECT 
//                    ISNULL((SELECT SUM(AdvancePayment) FROM RoomReservations WHERE {0}), 0) +
//                    ISNULL((SELECT SUM(AmountPaid) FROM GR_Bills WHERE {0} AND BillNo LIKE 'ADV-MID-%' AND UPPER(BillStatus) != 'VOID'), 0) 
//                AS TotalAdvance", groupCriteria);

//                    using (SqlCommand cmdSum = new SqlCommand(qAdvTotal, con))
//                    {
//                        cmdSum.Parameters.AddWithValue("@ResNo", resNo);
//                        if (!string.IsNullOrEmpty(groupRecNo)) cmdSum.Parameters.AddWithValue("@RecNo", groupRecNo);
//                        totalAdvance = Convert.ToDecimal(cmdSum.ExecuteScalar());
//                    }

//                    // For "All Rooms" view, DO NOT subtract settled bills - we want to show the total pending amount
//                    txtAdvancePaid.Text = totalAdvance.ToString("0");
//                    hfAdvancePaid.Value = totalAdvance.ToString("0");

//                    // Set bill number display
//                    lblBillNo.Text = string.IsNullOrEmpty(existBill) ? "NEW BILL" : existBill;

//                    // Load existing bill if it exists
//                    if (!string.IsNullOrEmpty(existBill))
//                        LoadExistingBill(existBill, con);

//                    // Re-apply live calculation figures after LoadExistingBill
//                    if (actualCount > 0)
//                    {
//                        int currentRooms = 1;
//                        if (!int.TryParse(txtNoOfRooms.Text, out currentRooms) || currentRooms < 1) currentRooms = rooms;

//                        double avgN = weightedNights / currentRooms;
//                        txtNoOfNights.Text = avgN.ToString("0.##");
//                        decimal perRoomPerNight = (currentRooms > 0 && avgN > 0)
//                            ? totalAccurateRent / (currentRooms * (decimal)avgN)
//                            : rent;
//                        txtRentPerNight.Text = perRoomPerNight.ToString("0");
//                    }

//                    // Always restore full advance for All Rooms view
//                    txtAdvancePaid.Text = totalAdvance.ToString("0");
//                    hfAdvancePaid.Value = totalAdvance.ToString("0");

//                    // Get pending service charges
//                    decimal pendingServices = GetPendingServiceCharges(resNo, "0");
//                    decimal existingOther = 0;
//                    decimal.TryParse(txtOtherCharges.Text, out existingOther);
//                    txtOtherCharges.Text = Math.Max(existingOther, pendingServices).ToString("0");

//                    // Setup ledger link
//                    lnkLedger.NavigateUrl = "GuestLedger.aspx?ResNo=" + resNo;
//                    lnkLedger.Visible = true;

//                    // Populate rooms dropdown and generate ledger
//                    PopulateRoomsDropdown(resNo);
//                    GenerateLedger(resNo, "0");

//                    // Show panels
//                    SetPanelsVisible(true);

//                    // Check if this reservation has any settled bill to lock the form
//                    bool hasSettledBill = false;
//                    string checkSettledSql = @"
//                SELECT COUNT(*) FROM GR_Bills 
//                WHERE ReservationNo = @ResNo 
//                AND UPPER(BillStatus) IN ('SETTLED','REFUNDED') 
//                AND BillNo NOT LIKE 'ADV-MID-%'";
//                    using (SqlCommand cmdCheck = new SqlCommand(checkSettledSql, con))
//                    {
//                        cmdCheck.Parameters.AddWithValue("@ResNo", resNo);
//                        int settledCount = Convert.ToInt32(cmdCheck.ExecuteScalar());
//                        hasSettledBill = settledCount > 0;
//                    }

//                    ToggleBillLock(hasSettledBill);

//                    if (hasSettledBill)
//                    {
//                        btnSaveBill.Text = "Reprint Settled Bill";
//                        btnSaveBill.Style["background"] = "linear-gradient(135deg,#2e7d32,#1b5e20)";
//                        hfBillStatus.Value = "SETTLED";
//                    }
//                    else
//                    {
//                        btnSaveBill.Text = "Save & Finalize Bill";
//                        btnSaveBill.Style["background"] = "linear-gradient(135deg,#1A1A2E,#2d2d5e)";
//                    }

//                    // Trigger JavaScript calculation
//                    ClientScript.RegisterStartupScript(GetType(), "calc", "calcBill();", true);

//                    // Load bills history for this reservation
//                    LoadBillsHistory(resNo);
//                }
//            }
//            catch (Exception ex)
//            {
//                ShowMessage("Error: " + ex.Message, false);
//            }
//        }

//        private void ToggleBillLock(bool isSettled)
//        {
//            bool isEditable = !isSettled;
//            txtManualPay.ReadOnly = isSettled;
//            txtCashPayBack.ReadOnly = isSettled;
//            txtRemarks.ReadOnly = isSettled;
//            txtInterimAmount.ReadOnly = isSettled;
//            txtInterimRemarks.ReadOnly = isSettled;
//            btnPost.Enabled = isEditable;

//            string bgColor = isSettled ? "#f5f0e8" : "#fff";
//            string textColor = isSettled ? "#7a7a7a" : "#1A1A2E";

//            txtManualPay.Style["background"] = bgColor;
//            txtManualPay.Style["color"] = textColor;
//            txtCashPayBack.Style["background"] = bgColor;
//            txtCashPayBack.Style["color"] = textColor;
//            txtRemarks.Style["background"] = bgColor;
//            txtRemarks.Style["color"] = textColor;
//            txtInterimAmount.Style["background"] = bgColor;
//            txtInterimRemarks.Style["background"] = bgColor;

//            txtNoOfRooms.ReadOnly = true;
//            txtNoOfNights.ReadOnly = true;
//            txtRentPerNight.ReadOnly = true;
//            txtTaxPercent.ReadOnly = true;
//            txtOtherCharges.ReadOnly = true;
//        }

//        private void GenerateLedger(string resNo, string roomNo = "0")
//        {
//            DataTable dtLedger = CreateLedgerSchema();

//            using (SqlConnection con = new SqlConnection(connStr))
//            {
//                con.Open();

//                string receiptNo = hfReceiptNo.Value;
//                DateTime resDate = DateTime.Now;
//                using (SqlCommand cmd = new SqlCommand("SELECT ResDate FROM RoomReservations WHERE ReservationNo = @ResNo", con))
//                {
//                    cmd.Parameters.AddWithValue("@ResNo", resNo);
//                    object resDateObj = cmd.ExecuteScalar();
//                    if (resDateObj != null && resDateObj != DBNull.Value) resDate = Convert.ToDateTime(resDateObj);
//                }

//                string resCriteria = "ReservationNo = @ResNo";
//                if (!string.IsNullOrEmpty(receiptNo))
//                    resCriteria = "ReservationNo IN (SELECT ReservationNo FROM RoomReservations WHERE ReceiptNo = @RecNo)";

//                // Advance Payment row
//                decimal totalAdvance = 0;
//                string qAdv = string.Format("SELECT ISNULL(SUM(AdvancePayment), 0) FROM RoomReservations WHERE {0}", resCriteria);
//                using (SqlCommand cmdSum = new SqlCommand(qAdv, con))
//                {
//                    cmdSum.Parameters.AddWithValue("@ResNo", resNo);
//                    if (!string.IsNullOrEmpty(receiptNo)) cmdSum.Parameters.AddWithValue("@RecNo", receiptNo);
//                    totalAdvance = Convert.ToDecimal(cmdSum.ExecuteScalar());
//                }

//                if (roomNo == "0")
//                    dtLedger.Rows.Add(resDate, "ADV-REC", "Initial Advance Payment", 0, totalAdvance, 0);

//                // Pre-fetch settled rooms to skip accrued rent projection for them
//                var settledBillRooms = new System.Collections.Generic.HashSet<string>(StringComparer.OrdinalIgnoreCase);
//                bool wholeResSettled = false;
//                try
//                {
//                    // FIX: Use UPPER() for case-insensitive status match
//                    string qSR = string.Format(
//                        "SELECT ISNULL(NULLIF(LTRIM(RTRIM(RoomNo)),'0'),'ALL') FROM GR_Bills WHERE {0} AND UPPER(BillStatus) IN ('SETTLED','REFUNDED') AND BillNo NOT LIKE 'ADV-MID-%'",
//                        resCriteria);
//                    using (SqlCommand cmdSR = new SqlCommand(qSR, con))
//                    {
//                        cmdSR.Parameters.AddWithValue("@ResNo", resNo);
//                        if (!string.IsNullOrEmpty(receiptNo)) cmdSR.Parameters.AddWithValue("@RecNo", receiptNo);
//                        using (SqlDataReader drSR = cmdSR.ExecuteReader())
//                        {
//                            while (drSR.Read())
//                            {
//                                string br = drSR[0].ToString();
//                                if (br == "ALL") { wholeResSettled = true; settledBillRooms.Clear(); break; }
//                                settledBillRooms.Add(br);
//                            }
//                        }
//                    }
//                }
//                catch { }

//                // Accrued Rent rows (only for unsettled rooms)
//                try
//                {
//                    string qStay = string.Format(@"
//                        SELECT ra.RoomNo, ra.AllocatedDate, ra.CheckOutDate, ISNULL(ra.StayFactor, 1.0) as StayFactor, rd.Rent, rd.TaxPercentage, ra.LastChargedDate
//                        FROM RoomAllocations ra
//                        INNER JOIN RoomDefinitionNew rd ON ra.RoomNo = rd.RoomNo
//                        WHERE {0}", resCriteria);

//                    using (SqlCommand cmd = new SqlCommand(qStay, con))
//                    {
//                        cmd.Parameters.AddWithValue("@ResNo", resNo);
//                        if (!string.IsNullOrEmpty(receiptNo)) cmd.Parameters.AddWithValue("@RecNo", receiptNo);
//                        using (SqlDataReader dr = cmd.ExecuteReader())
//                        {
//                            while (dr.Read())
//                            {
//                                string rNo = dr["RoomNo"].ToString();
//                                if (wholeResSettled) continue;
//                                if (settledBillRooms.Contains(rNo) || settledBillRooms.Contains(rNo.TrimStart('0'))) continue;

//                                DateTime chkIn = Convert.ToDateTime(dr["AllocatedDate"]);
//                                DateTime lastAudit = dr["LastChargedDate"] == DBNull.Value ? chkIn.Date : Convert.ToDateTime(dr["LastChargedDate"]).Date;
//                                DateTime effCheckOut = dr["CheckOutDate"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(dr["CheckOutDate"]);
//                                double stayFactor = Convert.ToDouble(dr["StayFactor"]);
//                                decimal rate = Convert.ToDecimal(dr["Rent"]);
//                                decimal taxPct = Convert.ToDecimal(dr["TaxPercentage"]);

//                                int fullNights = (effCheckOut.Date - chkIn.Date).Days;
//                                double totalSegmentNights = fullNights;
//                                if (stayFactor < 1.0) totalSegmentNights += stayFactor;
//                                else if (totalSegmentNights < 1) totalSegmentNights = 1.0;

//                                int auditedNights = dr["LastChargedDate"] == DBNull.Value ? 0 : (lastAudit - chkIn.Date).Days + 1;
//                                if (auditedNights < 0) auditedNights = 0;
//                                double pendingNights = totalSegmentNights - (double)auditedNights;

//                                if (pendingNights > 0)
//                                {
//                                    if (roomNo != "0" && rNo != roomNo.Trim() && rNo.TrimStart('0') != roomNo.Trim().TrimStart('0')) continue;

//                                    DateTime nextChargeDate = (dr["LastChargedDate"] == DBNull.Value) ? chkIn.Date : lastAudit.AddDays(1);
//                                    double nightsProcessed = 0;

//                                    while (nightsProcessed < pendingNights)
//                                    {
//                                        double currentNightFactor = 1.0;
//                                        if (pendingNights - nightsProcessed < 1.0)
//                                            currentNightFactor = pendingNights - nightsProcessed;

//                                        decimal nightRent = rate * (decimal)currentNightFactor;
//                                        decimal nightTax = Math.Round(nightRent * taxPct / 100, 2);
//                                        string dateLabel = nextChargeDate.ToString("dd-MMM");
//                                        string nightDesc = string.Format("Accrued Rent (Room {0}) - {1}", rNo, dateLabel);
//                                        if (currentNightFactor < 1.0) nightDesc += string.Format(" ({0:0.##} day)", currentNightFactor);

//                                        dtLedger.Rows.Add(nextChargeDate, "RENT-ACC", nightDesc, nightRent, 0, 0);
//                                        if (nightTax > 0)
//                                            dtLedger.Rows.Add(nextChargeDate, "TAX-ACC", "Accrued GST/Tax (Room " + rNo + ") - " + dateLabel, nightTax, 0, 0);

//                                        nextChargeDate = nextChargeDate.AddDays(1);
//                                        nightsProcessed += 1.0;
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//                catch { }

//                // Services
//                string qServices = string.Format("SELECT * FROM GR_RoomServices WHERE {0} {1} ORDER BY OrderDate",
//                    resCriteria,
//                    (roomNo == "0" ? "" : " AND RoomNo = @RoomNo"));

//                using (SqlCommand cmd = new SqlCommand(qServices, con))
//                {
//                    cmd.Parameters.AddWithValue("@ResNo", resNo);
//                    if (!string.IsNullOrEmpty(receiptNo)) cmd.Parameters.AddWithValue("@RecNo", receiptNo);
//                    if (roomNo != "0") cmd.Parameters.AddWithValue("@RoomNo", roomNo);
//                    using (SqlDataReader dr = cmd.ExecuteReader())
//                    {
//                        while (dr.Read())
//                        {
//                            decimal amt = dr["TotalAmount"] == DBNull.Value ? 0 : Convert.ToDecimal(dr["TotalAmount"]);
//                            string svcName = dr["ServiceName"].ToString();
//                            string rNo = dr["RoomNo"] == DBNull.Value || dr["RoomNo"].ToString() == "0" ? "" : " (Room " + dr["RoomNo"].ToString() + ")";
//                            string invNo = dr["InvoiceNo"] == DBNull.Value ? "SVC-" + dr["ServiceID"].ToString() : dr["InvoiceNo"].ToString();
//                            string desc = svcName + (dr["Qty"].ToString() == "1" ? "" : " (Qty: " + dr["Qty"] + ")") + rNo;
//                            dtLedger.Rows.Add(dr["OrderDate"], invNo, desc, amt, 0, 0);
//                        }
//                    }
//                }

//                // Bills & Payments
//                string qPayments = string.Format("SELECT * FROM GR_Bills WHERE {0} {1} ORDER BY BillDate",
//                    resCriteria,
//                    (roomNo == "0" ? "" : " AND RoomNo = @RoomNo"));

//                using (SqlCommand cmd = new SqlCommand(qPayments, con))
//                {
//                    cmd.Parameters.AddWithValue("@ResNo", resNo);
//                    if (!string.IsNullOrEmpty(receiptNo)) cmd.Parameters.AddWithValue("@RecNo", receiptNo);
//                    if (roomNo != "0") cmd.Parameters.AddWithValue("@RoomNo", roomNo);
//                    using (SqlDataReader dr = cmd.ExecuteReader())
//                    {
//                        while (dr.Read())
//                        {
//                            if (dr["BillNo"] != DBNull.Value)
//                            {
//                                string billNo = dr["BillNo"].ToString();
//                                DateTime bDate = Convert.ToDateTime(dr["BillDate"]);
//                                decimal paid = Convert.ToDecimal(dr["AmountPaid"]);
//                                string rNo = dr["RoomNo"].ToString();
//                                string roomInfo = (rNo == "0") ? "" : " (Room " + rNo + ")";

//                                if (billNo.StartsWith("ADV-MID-"))
//                                {
//                                    string desc = (paid < 0 ? "Payment Reversal / Adjustment" : "Mid-Stay Payment / Credit") + roomInfo;
//                                    dtLedger.Rows.Add(bDate, billNo, desc, 0, paid, 0);
//                                }
//                                else
//                                {
//                                    // â”€â”€ FIX: BREAK FINAL BILL INTO 3 ROWS (Rent + Tax + Other) â”€â”€
//                                    decimal bRooms = dr["NoOfRooms"] != DBNull.Value ? Convert.ToDecimal(dr["NoOfRooms"]) : 0;
//                                    decimal bNights = dr["NoOfNights"] != DBNull.Value ? Convert.ToDecimal(dr["NoOfNights"]) : 0;
//                                    decimal bRate = dr["RoomRentPerNight"] != DBNull.Value ? Convert.ToDecimal(dr["RoomRentPerNight"]) : 0;
//                                    decimal bTaxPct = dr["TaxPercent"] != DBNull.Value ? Convert.ToDecimal(dr["TaxPercent"]) : 0;
//                                    decimal bOther = dr["OtherCharges"] != DBNull.Value ? Convert.ToDecimal(dr["OtherCharges"]) : 0;

//                                    decimal bRoomRent = bRooms * bNights * bRate;
//                                    decimal bTax = Math.Round(bRoomRent * bTaxPct / 100, 2);

//                                    // Fallback: if rent columns are zero but GrossTotal exists, show as single row
//                                    if (bRoomRent == 0 && bOther == 0 && dr["GrossTotal"] != DBNull.Value)
//                                    {
//                                        decimal bGross = Convert.ToDecimal(dr["GrossTotal"]);
//                                        if (bGross != 0)
//                                            dtLedger.Rows.Add(bDate, billNo, "Final Bill Total" + roomInfo, bGross, 0, 0);
//                                    }
//                                    else
//                                    {
//                                        if (bRoomRent > 0)
//                                            dtLedger.Rows.Add(bDate, billNo,
//                                                string.Format("Room Rent: {0}R \u00d7 {1}N @ PKR {2:N0}{3}",
//                                                    bRooms, bNights, bRate, roomInfo),
//                                                bRoomRent, 0, 0);

//                                        if (bTax > 0)
//                                            dtLedger.Rows.Add(bDate, billNo,
//                                                string.Format("GST/Tax ({0}%){1}", bTaxPct, roomInfo),
//                                                bTax, 0, 0);

//                                        if (bOther > 0)
//                                            dtLedger.Rows.Add(bDate, billNo,
//                                                "Other Services & Charges" + roomInfo,
//                                                bOther, 0, 0);
//                                    }

//                                    // Credit: Advance adjusted
//                                    decimal bAdv = dr["AdvancePaid"] != DBNull.Value ? Convert.ToDecimal(dr["AdvancePaid"]) : 0;
//                                    if (bAdv != 0)
//                                        dtLedger.Rows.Add(bDate, billNo, "Advance Adjusted" + roomInfo, 0, bAdv, 0);

//                                    // Credit: Settlement payment
//                                    if (paid != 0)
//                                        dtLedger.Rows.Add(bDate, billNo, "Settlement Payment" + roomInfo, 0, paid, 0);
//                                }
//                            }
//                        }
//                    }
//                }
//            }

//            DataView dv = dtLedger.DefaultView;
//            dv.Sort = "Date ASC";
//            DataTable dtSorted = dv.ToTable();
//            decimal runningBal = 0;

//            foreach (DataRow row in dtSorted.Rows)
//            {
//                decimal dr2 = Convert.ToDecimal(row["Debit"]);
//                decimal cr2 = Convert.ToDecimal(row["Credit"]);
//                runningBal += (dr2 - cr2);
//                row["Balance"] = runningBal;
//            }

//            gvLedger.DataSource = dtSorted;
//            gvLedger.DataBind();
//            pnlDetailedLedger.Visible = true;
//        }

//        private DataTable CreateLedgerSchema()
//        {
//            DataTable dt = new DataTable();
//            dt.Columns.Add("Date", typeof(DateTime));
//            dt.Columns.Add("RefNo", typeof(string));
//            dt.Columns.Add("Description", typeof(string));
//            dt.Columns.Add("Debit", typeof(decimal));
//            dt.Columns.Add("Credit", typeof(decimal));
//            dt.Columns.Add("Balance", typeof(decimal));
//            return dt;
//        }

//        private void PopulateRoomsDropdown(string resNo)
//        {
//            ddlBillRooms.Items.Clear();
//            ddlBillRooms.Items.Add(new ListItem("  All Allocated Rooms  ", "0"));

//            using (SqlConnection con = new SqlConnection(connStr))
//            {
//                string receiptNo = hfReceiptNo.Value;
//                // FIX: Use UPPER() for case-insensitive settled status check
//                string sql = @"
//                    SELECT a.RoomNo, a.CheckOutDate, 
//                           (SELECT COUNT(*) FROM GR_Bills b 
//                            WHERE b.ReservationNo = a.ReservationNo 
//                            AND (b.RoomNo = a.RoomNo OR b.RoomNo = '0') 
//                            AND UPPER(b.BillStatus) IN ('SETTLED','REFUNDED')
//                            AND b.BillNo NOT LIKE 'ADV-MID-%') as SettledCount
//                    FROM RoomAllocations a WHERE a.ReservationNo = @Res";

//                if (!string.IsNullOrEmpty(receiptNo))
//                {
//                    sql = @"
//                        SELECT a.RoomNo, a.CheckOutDate,
//                               (SELECT COUNT(*) FROM GR_Bills b 
//                                WHERE b.ReservationNo = a.ReservationNo 
//                                AND (b.RoomNo = a.RoomNo OR b.RoomNo = '0') 
//                                AND UPPER(b.BillStatus) IN ('SETTLED','REFUNDED')
//                                AND b.BillNo NOT LIKE 'ADV-MID-%') as SettledCount
//                        FROM RoomAllocations a 
//                        WHERE a.ReservationNo IN (SELECT ReservationNo FROM RoomReservations WHERE ReceiptNo = @RecNo)";
//                }
//                sql += " ORDER BY a.RoomNo";

//                using (SqlCommand cmd = new SqlCommand(sql, con))
//                {
//                    cmd.Parameters.AddWithValue("@Res", resNo);
//                    if (!string.IsNullOrEmpty(receiptNo)) cmd.Parameters.AddWithValue("@RecNo", receiptNo);
//                    con.Open();
//                    StringBuilder sbRooms = new StringBuilder();
//                    using (SqlDataReader dr = cmd.ExecuteReader())
//                    {
//                        while (dr.Read())
//                        {
//                            string r = dr["RoomNo"].ToString();
//                            bool isCheckedOut = dr["CheckOutDate"] != DBNull.Value;
//                            bool isSettled = dr["SettledCount"] != DBNull.Value && Convert.ToInt32(dr["SettledCount"]) > 0;

//                            string statusLabel = isCheckedOut ? "COMPLETED" : "OCCUPIED";
//                            if (isSettled) statusLabel = "SETTLED";

//                            string label = string.Format("Room {0} ({1})", r, statusLabel);
//                            ddlBillRooms.Items.Add(new ListItem(label, r));

//                            if (sbRooms.Length > 0) sbRooms.Append(", ");
//                            sbRooms.Append(r);
//                        }
//                    }
//                    lblAllocRooms.Text = sbRooms.Length > 0 ? sbRooms.ToString() : "Not allocated yet";
//                }
//            }
//        }

//        protected void ddlBillRooms_SelectedIndexChanged(object sender, EventArgs e)
//        {
//            string resNo = hfReservationNo.Value;
//            if (string.IsNullOrEmpty(resNo)) return;
//            string selectedRoom = ddlBillRooms.SelectedValue;
//            double sNights = 0; decimal sRent = 0; int sCount = 0; StringBuilder sDesc = new StringBuilder();
//            DateTime toD = DateTime.Parse(lblToDate.Text);

//            if (selectedRoom == "0") // All Rooms
//            {
//                LoadReservationDetails(resNo);
//                lblBillNo.Text = "NEW BILL";
//                return;
//            }
//            else // Specific Room
//            {
//                txtManualPay.Text = "0";
//                txtCashPayBack.Text = "0";
//                txtRemarks.Text = "";
//                hfBillStatus.Value = "DRAFT";

//                CalculateDetailedStay(resNo, selectedRoom.Trim(), toD, out sCount, out sNights, out sRent, out sDesc);

//                txtNoOfRooms.Text = "1";
//                txtNoOfNights.Text = sNights.ToString("0.##");

//                decimal rate, tax; string descClean;
//                FetchRoomRate(selectedRoom.Trim(), out rate, out tax, out descClean);
//                txtRentPerNight.Text = rate.ToString("0");
//                txtTaxPercent.Text = tax.ToString("0");
//                hfRoomDescription.Value = sDesc.ToString();
//                txtOtherCharges.Text = GetPendingServiceCharges(resNo, selectedRoom.Trim()).ToString("0");

//                // FIX: For specific room, get advance that is NOT already consumed by this room's settled bill
//                decimal totalAdv = GetRemainingAdvanceForRoom(resNo, hfReceiptNo.Value, selectedRoom.Trim());
//                txtAdvancePaid.Text = totalAdv.ToString("0");
//                hfAdvancePaid.Value = totalAdv.ToString("0");

//                GenerateLedger(resNo, selectedRoom.Trim());

//                try
//                {
//                    using (SqlConnection con = new SqlConnection(connStr))
//                    {
//                        string sql = "SELECT CheckOutDate FROM RoomAllocations WHERE ReservationNo = @Res AND RoomNo = @Room";
//                        using (SqlCommand cmd = new SqlCommand(sql, con))
//                        {
//                            cmd.Parameters.AddWithValue("@Res", resNo);
//                            cmd.Parameters.AddWithValue("@Room", selectedRoom.Trim());
//                            con.Open();
//                            object co = cmd.ExecuteScalar();
//                            lblResStatus.Text = (co == null || co == DBNull.Value) ? "Occupied" : "Completed";
//                        }
//                    }
//                }
//                catch { }

//                CheckExistingRoomBill(resNo, selectedRoom.Trim());
//            }
//            ClientScript.RegisterStartupScript(GetType(), "calc", "calcBill();", true);
//        }

//        // Add this new helper method for room-specific remaining advance
//        private decimal GetRemainingAdvanceForRoom(string resNo, string receiptNo, string roomNo)
//        {
//            decimal remainingAdvance = 0;
//            string criteria = "ReservationNo = @ResNo";
//            if (!string.IsNullOrEmpty(receiptNo))
//                criteria = "ReservationNo IN (SELECT ReservationNo FROM RoomReservations WHERE ReceiptNo = @RecNo)";

//            try
//            {
//                using (SqlConnection con = new SqlConnection(connStr))
//                {
//                    con.Open();

//                    // Total advance from reservations and mid-stay payments
//                    string qTotal = string.Format(@"
//                SELECT 
//                    ISNULL((SELECT SUM(AdvancePayment) FROM RoomReservations WHERE {0}), 0) +
//                    ISNULL((SELECT SUM(AmountPaid) FROM GR_Bills WHERE {0} AND BillNo LIKE 'ADV-MID-%' AND UPPER(BillStatus) != 'VOID'), 0) 
//                AS TotalAdvance", criteria);

//                    decimal totalAdvance = 0;
//                    using (SqlCommand cmdTotal = new SqlCommand(qTotal, con))
//                    {
//                        cmdTotal.Parameters.AddWithValue("@ResNo", resNo);
//                        if (!string.IsNullOrEmpty(receiptNo)) cmdTotal.Parameters.AddWithValue("@RecNo", receiptNo);
//                        totalAdvance = Convert.ToDecimal(cmdTotal.ExecuteScalar());
//                    }

//                    // Subtract advance consumed by settled bills for THIS SPECIFIC room
//                    string qConsumed = @"
//                SELECT ISNULL(SUM(AdvancePaid), 0) FROM GR_Bills 
//                WHERE " + criteria + @"
//                AND UPPER(BillStatus) IN ('SETTLED','REFUNDED') 
//                AND BillNo NOT LIKE 'ADV-MID-%'
//                AND RoomNo = @RoomNo";

//                    decimal consumedAdvance = 0;
//                    using (SqlCommand cmdConsumed = new SqlCommand(qConsumed, con))
//                    {
//                        cmdConsumed.Parameters.AddWithValue("@ResNo", resNo);
//                        if (!string.IsNullOrEmpty(receiptNo)) cmdConsumed.Parameters.AddWithValue("@RecNo", receiptNo);
//                        cmdConsumed.Parameters.AddWithValue("@RoomNo", roomNo);
//                        consumedAdvance = Convert.ToDecimal(cmdConsumed.ExecuteScalar());
//                    }

//                    remainingAdvance = totalAdvance - consumedAdvance;
//                    if (remainingAdvance < 0) remainingAdvance = 0;
//                }
//            }
//            catch { }
//            return remainingAdvance;
//        }

//        private decimal GetTotalAdvance(string resNo, string receiptNo, string roomNo = "0")
//        {
//            decimal totalAdvance = 0;
//            string criteria = "ReservationNo = @ResNo";
//            if (!string.IsNullOrEmpty(receiptNo))
//                criteria = "ReservationNo IN (SELECT ReservationNo FROM RoomReservations WHERE ReceiptNo = @RecNo)";

//            try
//            {
//                using (SqlConnection con = new SqlConnection(connStr))
//                {
//                    con.Open();

//                    // 1. Total advance from RoomReservations (reservation-wide)
//                    string qRes = "SELECT SUM(ISNULL(AdvancePayment, 0)) FROM RoomReservations WHERE " + criteria;
//                    using (SqlCommand cmdRes = new SqlCommand(qRes, con))
//                    {
//                        cmdRes.Parameters.AddWithValue("@ResNo", resNo);
//                        if (!string.IsNullOrEmpty(receiptNo)) cmdRes.Parameters.AddWithValue("@RecNo", receiptNo);
//                        object r = cmdRes.ExecuteScalar();
//                        if (r != null && r != DBNull.Value) totalAdvance = Convert.ToDecimal(r);
//                    }

//                    // 2. Mid-stay interim payments
//                    string qBills = "SELECT SUM(ISNULL(AmountPaid, 0)) FROM GR_Bills WHERE " + criteria
//                                  + " AND BillNo LIKE 'ADV-MID-%' AND UPPER(BillStatus) != 'VOID'";
//                    using (SqlCommand cmdBills = new SqlCommand(qBills, con))
//                    {
//                        cmdBills.Parameters.AddWithValue("@ResNo", resNo);
//                        if (!string.IsNullOrEmpty(receiptNo)) cmdBills.Parameters.AddWithValue("@RecNo", receiptNo);
//                        object r = cmdBills.ExecuteScalar();
//                        if (r != null && r != DBNull.Value) totalAdvance += Convert.ToDecimal(r);
//                    }

//                    // 3. Subtract advance consumed by SETTLED/REFUNDED bills
//                    // FIX: For specific room, only subtract advance from bills for THAT room or '0' (all rooms)
//                    string qUsed;
//                    if (roomNo != "0")
//                    {
//                        // For specific room: subtract advance from bills that belong to this room OR '0' (all rooms)
//                        qUsed = @"SELECT ISNULL(SUM(AdvancePaid), 0) FROM GR_Bills 
//                          WHERE " + criteria + @"
//                          AND UPPER(BillStatus) IN ('SETTLED','REFUNDED') 
//                          AND BillNo NOT LIKE 'ADV-MID-%'
//                          AND (RoomNo = @RoomNo OR RoomNo = '0')";
//                    }
//                    else
//                    {
//                        // For "All Rooms": subtract advance from ALL settled bills
//                        qUsed = "SELECT SUM(ISNULL(AdvancePaid, 0)) FROM GR_Bills WHERE " + criteria
//                              + " AND UPPER(BillStatus) IN ('SETTLED','REFUNDED') AND BillNo NOT LIKE 'ADV-MID-%'";
//                    }

//                    using (SqlCommand cmdUsed = new SqlCommand(qUsed, con))
//                    {
//                        cmdUsed.Parameters.AddWithValue("@ResNo", resNo);
//                        if (!string.IsNullOrEmpty(receiptNo)) cmdUsed.Parameters.AddWithValue("@RecNo", receiptNo);
//                        if (roomNo != "0") cmdUsed.Parameters.AddWithValue("@RoomNo", roomNo);
//                        object r = cmdUsed.ExecuteScalar();
//                        if (r != null && r != DBNull.Value) totalAdvance -= Convert.ToDecimal(r);
//                    }
//                }
//            }
//            catch { }
//            return totalAdvance;
//        }

//        private void CheckExistingRoomBill(string resNo, string roomNo)
//        {
//            using (SqlConnection con = new SqlConnection(connStr))
//            {
//                // FIX: UPPER() for case-insensitive status check
//                string sql = @"
//                    SELECT TOP 1 BillNo FROM GR_Bills 
//                    WHERE ReservationNo = @Res 
//                    AND (RoomNo = @Room OR RoomNo = '0') 
//                    AND BillNo NOT LIKE 'ADV-MID-%' 
//                    AND UPPER(BillStatus) IN ('SETTLED','REFUNDED')
//                    ORDER BY (CASE WHEN RoomNo = @Room THEN 0 ELSE 1 END), BillDate DESC";

//                using (SqlCommand cmd = new SqlCommand(sql, con))
//                {
//                    cmd.Parameters.AddWithValue("@Res", resNo);
//                    cmd.Parameters.AddWithValue("@Room", roomNo);
//                    con.Open();
//                    object billNo = cmd.ExecuteScalar();
//                    if (billNo != null)
//                    {
//                        lblBillNo.Text = billNo.ToString();
//                        LoadExistingBill(billNo.ToString(), con);
//                    }
//                    else
//                    {
//                        cmd.CommandText = @"
//                            SELECT TOP 1 BillNo FROM GR_Bills 
//                            WHERE ReservationNo = @Res 
//                            AND (RoomNo = @Room OR RoomNo = '0') 
//                            AND BillNo NOT LIKE 'ADV-MID-%' 
//                            AND UPPER(BillStatus) = 'DRAFT'
//                            ORDER BY (CASE WHEN RoomNo = @Room THEN 0 ELSE 1 END), BillDate DESC";
//                        billNo = cmd.ExecuteScalar();
//                        if (billNo != null)
//                        {
//                            lblBillNo.Text = billNo.ToString();
//                            LoadExistingBill(billNo.ToString(), con);
//                        }
//                        else
//                        {
//                            lblBillNo.Text = "NEW BILL";
//                        }
//                    }
//                }
//            }
//        }

//        private void CalculateDetailedStay(string resNo, string roomNo, DateTime expectedToDate, out int roomCount, out double totalWeightedNights, out decimal totalRent, out StringBuilder description)
//        {
//            roomCount = 0;
//            totalWeightedNights = 0;
//            totalRent = 0;
//            description = new StringBuilder();

//            try
//            {
//                using (SqlConnection con = new SqlConnection(connStr))
//                {
//                    string receiptNo = hfReceiptNo.Value;
//                    // FIX: UPPER() for case-insensitive settled status check
//                    string settledFilter = @" AND NOT EXISTS (
//                        SELECT 1 FROM GR_Bills 
//                        WHERE ReservationNo = ra.ReservationNo 
//                        AND UPPER(BillStatus) IN ('SETTLED','REFUNDED')
//                        AND BillNo NOT LIKE 'ADV-MID-%'
//                        AND (RoomNo = ra.RoomNo OR RoomNo = '0')
//                    )";

//                    string sql = string.Format(@"
//                        SELECT ra.RoomNo, ra.AllocatedDate, ra.CheckOutDate, ISNULL(ra.StayFactor, 1.0) as StayFactor, rd.Rent
//                        FROM RoomAllocations ra
//                        INNER JOIN RoomDefinitionNew rd ON ra.RoomNo = rd.RoomNo
//                        WHERE (ra.ReservationNo = @ResNo OR (@RecNo <> '' AND ra.ReservationNo IN (SELECT ReservationNo FROM RoomReservations WHERE ReceiptNo = @RecNo)))
//                        {0}", settledFilter);

//                    SqlCommand cmd = new SqlCommand(sql, con);
//                    cmd.Parameters.AddWithValue("@ResNo", resNo);
//                    cmd.Parameters.AddWithValue("@RecNo", receiptNo ?? "");

//                    con.Open();
//                    using (SqlDataReader dr = cmd.ExecuteReader())
//                    {
//                        while (dr.Read())
//                        {
//                            string rNo = dr["RoomNo"].ToString();
//                            if (roomNo != "0" && rNo != roomNo.Trim() && rNo.TrimStart('0') != roomNo.Trim().TrimStart('0')) continue;

//                            roomCount++;
//                            DateTime chkIn = Convert.ToDateTime(dr["AllocatedDate"]);
//                            DateTime chkOut = dr["CheckOutDate"] == DBNull.Value
//                                ? (DateTime.Now.Date > expectedToDate.Date ? DateTime.Now : expectedToDate)
//                                : Convert.ToDateTime(dr["CheckOutDate"]);
//                            double stayFactor = Convert.ToDouble(dr["StayFactor"]);

//                            int fullDays = (chkOut.Date - chkIn.Date).Days;
//                            double sNights = fullDays;
//                            if (stayFactor < 1.0) sNights += stayFactor;
//                            else if (sNights < 1) sNights = 1.0;

//                            decimal rate = Convert.ToDecimal(dr["Rent"]);
//                            totalRent += ((decimal)sNights * rate);
//                            totalWeightedNights += sNights;

//                            if (description.Length > 0) description.Append(", ");
//                            description.Append(dr["RoomNo"].ToString() + " (" + sNights + " nts)");
//                        }
//                    }
//                }
//            }
//            catch { }
//        }

//        private decimal GetPendingServiceCharges(string resNo, string roomNo)
//        {
//            decimal total = 0;
//            try
//            {
//                using (SqlConnection con = new SqlConnection(connStr))
//                {
//                    string receiptNo = hfReceiptNo.Value;
//                    // FIX: UPPER() for case-insensitive settled status check
//                    string settledFilter = @" AND NOT EXISTS (
//                        SELECT 1 FROM GR_Bills 
//                        WHERE ReservationNo = @Res 
//                        AND UPPER(BillStatus) IN ('SETTLED','REFUNDED')
//                        AND BillNo NOT LIKE 'ADV-MID-%'
//                        AND (RoomNo = GR_RoomServices.RoomNo OR RoomNo = '0')
//                    )";

//                    string sql = @"
//                        SELECT TotalAmount, RoomNo 
//                        FROM GR_RoomServices 
//                        WHERE (ReservationNo = @Res OR (@RecNo <> '' AND ReservationNo IN (SELECT ReservationNo FROM RoomReservations WHERE ReceiptNo = @RecNo)))
//                        AND Status IN ('Pending', 'Confirmed')
//                        AND ServiceName NOT LIKE 'Room Rent (Automatic)%'
//                        AND ServiceName NOT LIKE 'GST on Room Rent%' " + settledFilter;

//                    SqlCommand cmd = new SqlCommand(sql, con);
//                    cmd.Parameters.AddWithValue("@Res", resNo);
//                    cmd.Parameters.AddWithValue("@RecNo", receiptNo ?? "");

//                    con.Open();
//                    using (SqlDataReader dr = cmd.ExecuteReader())
//                    {
//                        while (dr.Read())
//                        {
//                            string rNo = dr["RoomNo"] == DBNull.Value ? "" : dr["RoomNo"].ToString();
//                            if (roomNo != "0" && rNo != roomNo.Trim() && rNo.TrimStart('0') != roomNo.Trim().TrimStart('0')) continue;
//                            total += dr["TotalAmount"] == DBNull.Value ? 0 : Convert.ToDecimal(dr["TotalAmount"]);
//                        }
//                    }
//                }
//            }
//            catch { }
//            return total;
//        }

//        private void LoadExistingBill(string billNo, SqlConnection con)
//        {
//            if (string.IsNullOrEmpty(billNo) || billNo.StartsWith("ADV-MID-")) return;

//            try
//            {
//                using (SqlCommand cmd = new SqlCommand("SELECT * FROM GR_Bills WHERE BillNo = @BillNo", con))
//                {
//                    cmd.Parameters.AddWithValue("@BillNo", billNo);
//                    using (SqlDataReader dr = cmd.ExecuteReader())
//                    {
//                        if (dr.Read())
//                        {
//                            txtNoOfRooms.Text = dr["NoOfRooms"].ToString();
//                            txtNoOfNights.Text = dr["NoOfNights"].ToString();
//                            txtRentPerNight.Text = Convert.ToDecimal(dr["RoomRentPerNight"]).ToString("0");
//                            txtTaxPercent.Text = Convert.ToDecimal(dr["TaxPercent"]).ToString("0");
//                            txtOtherCharges.Text = Convert.ToDecimal(dr["OtherCharges"]).ToString("0");
//                            txtRemarks.Text = dr["Remarks"].ToString();

//                            decimal paid = Convert.ToDecimal(dr["AmountPaid"]);
//                            string bStatus = dr["BillStatus"].ToString();

//                            // FIX: Case-insensitive status check
//                            if (bStatus.ToUpper() == "SETTLED" || bStatus.ToUpper() == "REFUNDED")
//                            {
//                                decimal historicalAdv = dr["AdvancePaid"] != DBNull.Value ? Convert.ToDecimal(dr["AdvancePaid"]) : 0;
//                                txtAdvancePaid.Text = historicalAdv.ToString("0");
//                                hfAdvancePaid.Value = historicalAdv.ToString("0");
//                            }

//                            if (paid > 0) { txtManualPay.Text = paid.ToString("0"); txtCashPayBack.Text = "0"; }
//                            else if (paid < 0) { txtCashPayBack.Text = Math.Abs(paid).ToString("0"); txtManualPay.Text = "0"; }

//                            if (dr["TotalRoomRent"] != DBNull.Value)
//                                hfRoomDescription.Value = dr["Remarks"].ToString();

//                            string status = dr["BillStatus"].ToString();
//                            hfBillStatus.Value = status;

//                            // FIX: Case-insensitive status check
//                            if (status.ToUpper() == "SETTLED" || status.ToUpper() == "REFUNDED")
//                            {
//                                btnSaveBill.Text = "Reprint Settled Bill";
//                                btnSaveBill.Style["background"] = "linear-gradient(135deg,#2e7d32,#1b5e20)";
//                                ToggleBillLock(true);

//                                try
//                                {
//                                    decimal rRooms = 0; decimal.TryParse(dr["NoOfRooms"].ToString(), out rRooms);
//                                    decimal rNights = 0; decimal.TryParse(dr["NoOfNights"].ToString(), out rNights);
//                                    decimal rRate = 0; decimal.TryParse(dr["RoomRentPerNight"].ToString(), out rRate);
//                                    decimal rTaxPct = 0; decimal.TryParse(dr["TaxPercent"].ToString(), out rTaxPct);
//                                    decimal rOther = 0; decimal.TryParse(dr["OtherCharges"].ToString(), out rOther);
//                                    decimal rAdv = 0;
//                                    decimal.TryParse(hfAdvancePaid.Value, out rAdv);

//                                    decimal roomRent = rRooms * rNights * rRate;
//                                    decimal tax = Math.Round(roomRent * rTaxPct / 100, 2);
//                                    decimal gross = roomRent + tax + rOther;
//                                    decimal netBal = gross - (rAdv + paid);
//                                    decimal payBack = (rAdv + paid) > gross ? (rAdv + paid) - gross : 0;

//                                    string rJs = BuildReceiptScript(billNo, gross, roomRent, tax, rOther, rAdv, paid, netBal, payBack, dr["RoomNo"].ToString());
//                                    ClientScript.RegisterStartupScript(GetType(), "receipt_" + billNo, rJs, true);
//                                }
//                                catch { }
//                            }
//                            else
//                            {
//                                btnSaveBill.Text = "Save & Finalize Bill";
//                                btnSaveBill.Style["background"] = "linear-gradient(135deg,#1A1A2E,#2d2d5e)";
//                                ToggleBillLock(false);
//                            }
//                        }
//                        else
//                        {
//                            hfBillStatus.Value = "";
//                            btnSaveBill.Text = "Save & Finalize Bill";
//                            btnSaveBill.Style["background"] = "linear-gradient(135deg,#1A1A2E,#2d2d5e)";
//                        }
//                    }
//                }
//            }
//            catch { }
//        }

//        //protected void btnSaveBill_Click(object sender, EventArgs e)
//        //{
//        //    if (string.IsNullOrEmpty(hfReservationNo.Value))
//        //    {
//        //        ShowMessage("Please search and load a reservation first.", false);
//        //        return;
//        //    }

//        //    // FIX: Case-insensitive status check
//        //    if (hfBillStatus.Value.ToUpper() == "SETTLED" || hfBillStatus.Value.ToUpper() == "REFUNDED")
//        //    {
//        //        decimal rRent = ParseDecimal(txtRentPerNight.Text) * ParseInt(txtNoOfRooms.Text) * (decimal)ParseDecimal(txtNoOfNights.Text);
//        //        decimal rTax = Math.Round(rRent * ParseDecimal(txtTaxPercent.Text) / 100, 2);
//        //        decimal rGross = rRent + rTax + ParseDecimal(txtOtherCharges.Text);
//        //        decimal rAdv = ParseDecimal(txtAdvancePaid.Text);
//        //        decimal rManual = ParseDecimal(txtManualPay.Text) - ParseDecimal(txtCashPayBack.Text);

//        //        decimal rNet = rGross - (rAdv + rManual);
//        //        decimal rPB = (rAdv + rManual) > rGross ? (rAdv + rManual) - rGross : 0;

//        //        string rJs = BuildReceiptScript(lblBillNo.Text, rGross, rRent, rTax, ParseDecimal(txtOtherCharges.Text), rAdv, rManual, rNet, rPB, ddlBillRooms.SelectedValue);

//        //        if (hfAutoPrint.Value == "true" || true)
//        //        {
//        //            rJs += " window.print(); ";
//        //            hfAutoPrint.Value = "false";
//        //        }

//        //        ClientScript.RegisterStartupScript(GetType(), "receipt", rJs, true);
//        //        ShowMessage("Viewing existing settled bill: " + lblBillNo.Text, true);
//        //        return;
//        //    }

//        //    if (!IsCheckoutAllowed(hfReservationNo.Value))
//        //    {
//        //        ShowMessage("Bill cannot be finalized until Room Checkout or Partial Checkout is processed.", false);
//        //        return;
//        //    }

//        //    try
//        //    {
//        //        decimal rentPerNight = ParseDecimal(txtRentPerNight.Text);
//        //        int rooms = ParseInt(txtNoOfRooms.Text);
//        //        decimal nightsDecimal = ParseDecimal(txtNoOfNights.Text);
//        //        int nights = (nightsDecimal > 0 && nightsDecimal < 1) ? 1 : (int)Math.Ceiling(nightsDecimal);
//        //        decimal taxPct = ParseDecimal(txtTaxPercent.Text);
//        //        decimal other = ParseDecimal(txtOtherCharges.Text);
//        //        decimal adv = ParseDecimal(txtAdvancePaid.Text);
//        //        decimal manual = ParseDecimal(txtManualPay.Text) - ParseDecimal(txtCashPayBack.Text);

//        //        if (rooms <= 0 || nightsDecimal <= 0 || rentPerNight <= 0)
//        //        {
//        //            ShowMessage("Please fill in Rooms, Nights, and Rent per Night.", false);
//        //            return;
//        //        }

//        //        using (SqlConnection con = new SqlConnection(connStr))
//        //        using (SqlCommand cmd = new SqlCommand("sp_GR_SaveBill", con))
//        //        {
//        //            cmd.CommandType = CommandType.StoredProcedure;
//        //            cmd.Parameters.AddWithValue("@ReservationNo", hfReservationNo.Value);
//        //            cmd.Parameters.AddWithValue("@ReceiptNo", hfReceiptNo.Value);
//        //            cmd.Parameters.AddWithValue("@GuestName", lblGuestName.Text);
//        //            cmd.Parameters.AddWithValue("@GuestOf", lblGuestOf.Text);
//        //            cmd.Parameters.AddWithValue("@ClubName", lblClubName.Text == "â€”" ? "" : lblClubName.Text);
//        //            cmd.Parameters.AddWithValue("@FromDate", DateTime.Parse(lblFromDate.Text));
//        //            cmd.Parameters.AddWithValue("@ToDate", DateTime.Parse(lblToDate.Text));
//        //            cmd.Parameters.AddWithValue("@NoOfRooms", rooms);
//        //            cmd.Parameters.AddWithValue("@NoOfNights", nightsDecimal);
//        //            cmd.Parameters.AddWithValue("@RoomRentPerNight", rentPerNight);
//        //            cmd.Parameters.AddWithValue("@TaxPercent", taxPct);
//        //            cmd.Parameters.AddWithValue("@OtherCharges", other);
//        //            cmd.Parameters.AddWithValue("@AdvancePaid", adv);
//        //            cmd.Parameters.AddWithValue("@AmountPaid", manual);
//        //            cmd.Parameters.AddWithValue("@Remarks", txtRemarks.Text.Trim());
//        //            cmd.Parameters.AddWithValue("@RoomNo", ddlBillRooms.SelectedValue);

//        //            SqlParameter pBillNo = new SqlParameter("@BillNo", SqlDbType.VarChar, 20) { Direction = ParameterDirection.Output };
//        //            SqlParameter pNet = new SqlParameter("@NetBalance", SqlDbType.Decimal) { Direction = ParameterDirection.Output };
//        //            SqlParameter pPayBack = new SqlParameter("@PayBack", SqlDbType.Decimal) { Direction = ParameterDirection.Output };
//        //            cmd.Parameters.Add(pBillNo); cmd.Parameters.Add(pNet); cmd.Parameters.Add(pPayBack);

//        //            con.Open();
//        //            cmd.ExecuteNonQuery();

//        //            string billNo = pBillNo.Value.ToString();
//        //            decimal netBal = Convert.ToDecimal(pNet.Value);
//        //            decimal payBack = Convert.ToDecimal(pPayBack.Value);

//        //            lblBillNo.Text = billNo;

//        //            decimal roomRent = rooms * nightsDecimal * rentPerNight;
//        //            decimal tax = Math.Round(roomRent * taxPct / 100, 2);
//        //            decimal gross = roomRent + tax + other;

//        //            string js = BuildReceiptScript(billNo, gross, roomRent, tax, other, adv, manual, netBal, payBack, ddlBillRooms.SelectedValue);

//        //            if (hfAutoPrint.Value == "true" || true)
//        //            {
//        //                js += " window.print(); ";
//        //                hfAutoPrint.Value = "false";
//        //            }

//        //            ClientScript.RegisterStartupScript(GetType(), "receipt", js, true);
//        //            LoadBillsHistory(hfReservationNo.Value);

//        //            string statusMsg = netBal <= 0 && payBack == 0
//        //                ? "Bill saved & settled! Services and Advance integrated."
//        //                : payBack > 0
//        //                    ? "Bill saved! Pay back PKR " + payBack.ToString("N0") + " to guest."
//        //                    : "Bill saved! Amount due: PKR " + netBal.ToString("N0");

//        //            ShowMessage(statusMsg, true);

//        //            PostToLedger(hfReservationNo.Value, ddlBillRooms.SelectedValue, billNo, "Final Bill Settlement: Room Rent (" + rooms + " R Ã— " + nightsDecimal + " N)", roomRent, 0, con, null, null);
//        //            if (tax > 0)
//        //                PostToLedger(hfReservationNo.Value, ddlBillRooms.SelectedValue, billNo, "Final Bill Settlement: GST/Tax", tax, 0, con, null, null);
//        //            if (manual > 0)
//        //                PostToLedger(hfReservationNo.Value, ddlBillRooms.SelectedValue, billNo, "Final Bill Settlement: Cash/Card Payment", 0, manual, con, null, null);
//        //        }
//        //    }
//        //    catch (Exception ex) { ShowMessage("Error saving bill: " + ex.Message, false); }
//        //}


//        protected void btnSaveBill_Click(object sender, EventArgs e)
//        {
//            if (string.IsNullOrEmpty(hfReservationNo.Value))
//            {
//                ShowMessage("Please search and load a reservation first.", false);
//                return;
//            }

//            // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//            // EMP_ID VALIDATION - Check if user is logged in
//            // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//            if (Session["Emp_ID"] == null)
//            {
//                ShowMessage("Session expired. Please login again to save bill.", false);
//                return;
//            }

//            int empId;
//            if (!int.TryParse(Session["Emp_ID"].ToString(), out empId))
//            {
//                ShowMessage("Invalid Employee ID in session. Please login again.", false);
//                return;
//            }

//            if (hfBillStatus.Value.ToUpper() == "SETTLED" || hfBillStatus.Value.ToUpper() == "REFUNDED")
//            {
//                decimal rRent = ParseDecimal(txtRentPerNight.Text) * ParseInt(txtNoOfRooms.Text) * (decimal)ParseDecimal(txtNoOfNights.Text);
//                decimal rTax = Math.Round(rRent * ParseDecimal(txtTaxPercent.Text) / 100, 2);
//                decimal rGross = rRent + rTax + ParseDecimal(txtOtherCharges.Text);
//                decimal rAdv = ParseDecimal(txtAdvancePaid.Text);
//                decimal rManual = ParseDecimal(txtManualPay.Text) - ParseDecimal(txtCashPayBack.Text);

//                decimal rNet = rGross - (rAdv + rManual);
//                decimal rPB = (rAdv + rManual) > rGross ? (rAdv + rManual) - rGross : 0;

//                string rJs = BuildReceiptScript(lblBillNo.Text, rGross, rRent, rTax, ParseDecimal(txtOtherCharges.Text), rAdv, rManual, rNet, rPB, ddlBillRooms.SelectedValue);

//                if (hfAutoPrint.Value == "true" || true)
//                {
//                    rJs += " window.print(); ";
//                    hfAutoPrint.Value = "false";
//                }

//                ClientScript.RegisterStartupScript(GetType(), "receipt", rJs, true);
//                ShowMessage("Viewing existing settled bill: " + lblBillNo.Text, true);
//                return;
//            }

//            if (!IsCheckoutAllowed(hfReservationNo.Value))
//            {
//                ShowMessage("Bill cannot be finalized until Room Checkout or Partial Checkout is processed.", false);
//                return;
//            }

//            try
//            {
//                decimal rentPerNight = ParseDecimal(txtRentPerNight.Text);
//                int rooms = ParseInt(txtNoOfRooms.Text);
//                decimal nightsDecimal = ParseDecimal(txtNoOfNights.Text);
//                int nights = (nightsDecimal > 0 && nightsDecimal < 1) ? 1 : (int)Math.Ceiling(nightsDecimal);
//                decimal taxPct = ParseDecimal(txtTaxPercent.Text);
//                decimal other = ParseDecimal(txtOtherCharges.Text);
//                decimal adv = ParseDecimal(txtAdvancePaid.Text);
//                decimal manual = ParseDecimal(txtManualPay.Text) - ParseDecimal(txtCashPayBack.Text);

//                if (rooms <= 0 || nightsDecimal <= 0 || rentPerNight <= 0)
//                {
//                    ShowMessage("Please fill in Rooms, Nights, and Rent per Night.", false);
//                    return;
//                }

//                using (SqlConnection con = new SqlConnection(connStr))
//                using (SqlCommand cmd = new SqlCommand("sp_GR_SaveBill", con))
//                {
//                    cmd.CommandType = CommandType.StoredProcedure;
//                    cmd.Parameters.AddWithValue("@ReservationNo", hfReservationNo.Value);
//                    cmd.Parameters.AddWithValue("@ReceiptNo", hfReceiptNo.Value);
//                    cmd.Parameters.AddWithValue("@GuestName", lblGuestName.Text);
//                    cmd.Parameters.AddWithValue("@GuestOf", lblGuestOf.Text);
//                    cmd.Parameters.AddWithValue("@ClubName", lblClubName.Text == "â€”" ? "" : lblClubName.Text);
//                    cmd.Parameters.AddWithValue("@FromDate", DateTime.Parse(lblFromDate.Text));
//                    cmd.Parameters.AddWithValue("@ToDate", DateTime.Parse(lblToDate.Text));
//                    cmd.Parameters.AddWithValue("@NoOfRooms", rooms);
//                    cmd.Parameters.AddWithValue("@NoOfNights", nightsDecimal);
//                    cmd.Parameters.AddWithValue("@RoomRentPerNight", rentPerNight);
//                    cmd.Parameters.AddWithValue("@TaxPercent", taxPct);
//                    cmd.Parameters.AddWithValue("@OtherCharges", other);
//                    cmd.Parameters.AddWithValue("@AdvancePaid", adv);
//                    cmd.Parameters.AddWithValue("@AmountPaid", manual);
//                    cmd.Parameters.AddWithValue("@Remarks", txtRemarks.Text.Trim());
//                    cmd.Parameters.AddWithValue("@RoomNo", ddlBillRooms.SelectedValue);

//                    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//                    // EMP_ID PASSED TO STORED PROCEDURE
//                    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//                    cmd.Parameters.AddWithValue("@EmpID", empId);

//                    SqlParameter pBillNo = new SqlParameter("@BillNo", SqlDbType.VarChar, 20) { Direction = ParameterDirection.Output };
//                    SqlParameter pNet = new SqlParameter("@NetBalance", SqlDbType.Decimal) { Direction = ParameterDirection.Output };
//                    SqlParameter pPayBack = new SqlParameter("@PayBack", SqlDbType.Decimal) { Direction = ParameterDirection.Output };
//                    cmd.Parameters.Add(pBillNo); cmd.Parameters.Add(pNet); cmd.Parameters.Add(pPayBack);

//                    con.Open();
//                    cmd.ExecuteNonQuery();

//                    string billNo = pBillNo.Value.ToString();
//                    decimal netBal = Convert.ToDecimal(pNet.Value);
//                    decimal payBack = Convert.ToDecimal(pPayBack.Value);

//                    lblBillNo.Text = billNo;

//                    decimal roomRent = rooms * nightsDecimal * rentPerNight;
//                    decimal tax = Math.Round(roomRent * taxPct / 100, 2);
//                    decimal gross = roomRent + tax + other;

//                    string js = BuildReceiptScript(billNo, gross, roomRent, tax, other, adv, manual, netBal, payBack, ddlBillRooms.SelectedValue);

//                    if (hfAutoPrint.Value == "true" || true)
//                    {
//                        js += " window.print(); ";
//                        hfAutoPrint.Value = "false";
//                    }

//                    ClientScript.RegisterStartupScript(GetType(), "receipt", js, true);
//                    LoadBillsHistory(hfReservationNo.Value);

//                    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//                    // MESSAGE SHOWING EMPLOYEE ID WHO PROCESSED THE BILL
//                    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//                    string statusMsg = netBal <= 0 && payBack == 0
//                        ? "Bill saved & settled! Services and Advance integrated. (Processed by Employee ID: " + empId + ")"
//                        : payBack > 0
//                            ? "Bill saved! Pay back PKR " + payBack.ToString("N0") + " to guest. (Processed by Employee ID: " + empId + ")"
//                            : "Bill saved! Amount due: PKR " + netBal.ToString("N0") + " (Processed by Employee ID: " + empId + ")";

//                    ShowMessage(statusMsg, true);

//                    PostToLedger(hfReservationNo.Value, ddlBillRooms.SelectedValue, billNo, "Final Bill Settlement: Room Rent (" + rooms + " R Ã— " + nightsDecimal + " N)", roomRent, 0, con, null, null);
//                    if (tax > 0)
//                        PostToLedger(hfReservationNo.Value, ddlBillRooms.SelectedValue, billNo, "Final Bill Settlement: GST/Tax", tax, 0, con, null, null);
//                    if (manual > 0)
//                        PostToLedger(hfReservationNo.Value, ddlBillRooms.SelectedValue, billNo, "Final Bill Settlement: Cash/Card Payment", 0, manual, con, null, null);
//                }
//            }
//            catch (Exception ex) { ShowMessage("Error saving bill: " + ex.Message, false); }
//        }
//        //protected void btnPostPayment_Click(object sender, EventArgs e)
//        //{
//        //    if (string.IsNullOrEmpty(hfReservationNo.Value))
//        //    {
//        //        ShowMessage("Please search and load a reservation first.", false);
//        //        return;
//        //    }

//        //    // FIX: Case-insensitive check
//        //    if (hfBillStatus.Value.ToUpper() == "SETTLED" || hfBillStatus.Value.ToUpper() == "REFUNDED")
//        //    {
//        //        ShowMessage("Cannot record transactions for a settled bill.", false);
//        //        return;
//        //    }

//        //    decimal amount = ParseDecimal(txtInterimAmount.Text);
//        //    string remarks = txtInterimRemarks.Text.Trim();

//        //    if (ddlTransType.SelectedValue == "VOID" && amount > 0)
//        //        amount = -amount;

//        //    if (amount == 0)
//        //    {
//        //        ShowMessage("Please enter a valid payment or reversal amount.", false);
//        //        return;
//        //    }

//        //    if (Session["Emp_ID"] == null)
//        //    {
//        //        ShowMessage("Session expired. Please login again.", false);
//        //        return;
//        //    }

//        //    int empId;
//        //    if (!int.TryParse(Session["Emp_ID"].ToString(), out empId))
//        //    {
//        //        ShowMessage("Invalid Employee ID in session. Please login again.", false);
//        //        return;
//        //    }

//        //    try
//        //    {
//        //        using (SqlConnection con = new SqlConnection(connStr))
//        //        {
//        //            string billNo = "ADV-MID-" + DateTime.Now.ToString("yyyyMMddHHmm");
//        //            string descr = (amount < 0 ? "Reversal / Adjustment: " : "Mid-Stay Advance / Credit: ") + remarks;

//        //            string qInsert = @"
//        //                INSERT INTO GR_Bills (BillNo, BillDate, ReservationNo, ReceiptNo, GuestName, GuestOf, ClubName, FromDate, ToDate,
//        //                    NoOfRooms, NoOfNights, RoomRentPerNight, TaxPercent, OtherCharges, AdvancePaid, AmountPaid, Remarks, BillStatus, RoomNo, GrossTotal, TotalRoomRent, TaxAmount, EmpID)
//        //                VALUES (@BillNo, GETDATE(), @ResNo, @RecNo, @Guest, @GuestOf, @Club, @From, @To,
//        //                    0, 0, 0, 0, 0, 0, @Amount, @Remarks, 'SETTLED', @RoomNo, @Amount, 0, 0, @EmpID)";

//        //            using (SqlCommand cmd = new SqlCommand(qInsert, con))
//        //            {
//        //                cmd.Parameters.AddWithValue("@BillNo", billNo);
//        //                cmd.Parameters.AddWithValue("@ResNo", hfReservationNo.Value);
//        //                cmd.Parameters.AddWithValue("@RecNo", hfReceiptNo.Value);
//        //                cmd.Parameters.AddWithValue("@Guest", lblGuestName.Text);
//        //                cmd.Parameters.AddWithValue("@GuestOf", lblGuestOf.Text);
//        //                cmd.Parameters.AddWithValue("@Club", lblClubName.Text == "â€”" ? "" : lblClubName.Text);
//        //                cmd.Parameters.AddWithValue("@From", DateTime.Parse(lblFromDate.Text));
//        //                cmd.Parameters.AddWithValue("@To", DateTime.Parse(lblToDate.Text));
//        //                cmd.Parameters.AddWithValue("@Amount", amount);
//        //                cmd.Parameters.AddWithValue("@Remarks", descr);
//        //                cmd.Parameters.AddWithValue("@RoomNo", ddlBillRooms.SelectedValue);
//        //                cmd.Parameters.Add("@EmpID", SqlDbType.Int).Value = empId;

//        //                con.Open();
//        //                cmd.ExecuteNonQuery();

//        //                string desc = (amount < 0) ? "Mid-Stay Adjustment / Reversal" : "Mid-Stay Payment / Credit";

//        //                if (amount < 0)
//        //                    PostToLedger(hfReservationNo.Value, ddlBillRooms.SelectedValue, billNo, desc, Math.Abs(amount), 0, con, null, null);
//        //                else
//        //                    PostToLedger(hfReservationNo.Value, ddlBillRooms.SelectedValue, billNo, desc, 0, amount, con, null, null);

//        //                try
//        //                {
//        //                    string qSync = @"
//        //                        DECLARE @TotalGross DECIMAL(18,2) = (SELECT ISNULL(SUM(GrossTotal),0) FROM GR_Bills WHERE ReservationNo = @ResNo AND BillNo NOT LIKE 'ADV-MID-%');
//        //                        DECLARE @TotalPaid DECIMAL(18,2) =
//        //                            (SELECT ISNULL(SUM(AmountPaid),0) FROM GR_Bills WHERE ReservationNo = @ResNo)
//        //                            + (SELECT ISNULL(SUM(AdvancePayment),0) FROM RoomReservations WHERE ReservationNo = @ResNo);
//        //                        IF (@TotalPaid >= @TotalGross AND @TotalGross > 0)
//        //                        BEGIN
//        //                            UPDATE GR_Bills SET BillStatus = 'Settled' WHERE ReservationNo = @ResNo AND UPPER(BillStatus) = 'DRAFT';
//        //                        END";
//        //                    using (SqlCommand cmdSync = new SqlCommand(qSync, con))
//        //                    {
//        //                        cmdSync.Parameters.AddWithValue("@ResNo", hfReservationNo.Value);
//        //                        cmdSync.ExecuteNonQuery();
//        //                    }
//        //                }
//        //                catch { }
//        //            }

//        //            ShowMessage("Interim Payment of PKR " + amount.ToString("N0") + " recorded successfully and added as credit to ledger.", true);
//        //            txtInterimAmount.Text = "";
//        //            txtInterimRemarks.Text = "";

//        //            LoadReservationDetails(hfReservationNo.Value);
//        //            LoadBillsHistory(hfReservationNo.Value);
//        //        }
//        //    }
//        //    catch (Exception ex)
//        //    {
//        //        ShowMessage("Error recording payment: " + ex.Message, false);
//        //    }
//        //}

//        protected void btnPostPayment_Click(object sender, EventArgs e)
//        {
//            if (string.IsNullOrEmpty(hfReservationNo.Value))
//            {
//                ShowMessage("Please search and load a reservation first.", false);
//                return;
//            }

//            // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//            // EMP_ID VALIDATION - Check if user is logged in
//            // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//            if (Session["Emp_ID"] == null)
//            {
//                ShowMessage("Session expired. Please login again to record payment.", false);
//                return;
//            }

//            int empId;
//            if (!int.TryParse(Session["Emp_ID"].ToString(), out empId))
//            {
//                ShowMessage("Invalid Employee ID in session. Please login again.", false);
//                return;
//            }

//            if (hfBillStatus.Value.ToUpper() == "SETTLED" || hfBillStatus.Value.ToUpper() == "REFUNDED")
//            {
//                ShowMessage("Cannot record transactions for a settled bill.", false);
//                return;
//            }

//            decimal amount = ParseDecimal(txtInterimAmount.Text);
//            string remarks = txtInterimRemarks.Text.Trim();

//            if (ddlTransType.SelectedValue == "VOID" && amount > 0)
//                amount = -amount;

//            if (amount == 0)
//            {
//                ShowMessage("Please enter a valid payment or reversal amount.", false);
//                return;
//            }

//            try
//            {
//                using (SqlConnection con = new SqlConnection(connStr))
//                {
//                    string billNo = "ADV-MID-" + DateTime.Now.ToString("yyyyMMddHHmm");
//                    string descr = (amount < 0 ? "Reversal / Adjustment: " : "Mid-Stay Advance / Credit: ") + remarks;

//                    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//                    // INSERT QUERY WITH EMP_ID
//                    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//                    string qInsert = @"
//                INSERT INTO GR_Bills (BillNo, BillDate, ReservationNo, ReceiptNo, GuestName, GuestOf, ClubName, FromDate, ToDate,
//                    NoOfRooms, NoOfNights, RoomRentPerNight, TaxPercent, OtherCharges, AdvancePaid, AmountPaid, Remarks, BillStatus, RoomNo, GrossTotal, TotalRoomRent, TaxAmount, EmpID)
//                VALUES (@BillNo, GETDATE(), @ResNo, @RecNo, @Guest, @GuestOf, @Club, @From, @To,
//                    0, 0, 0, 0, 0, 0, @Amount, @Remarks, 'SETTLED', @RoomNo, @Amount, 0, 0, @EmpID)";

//                    using (SqlCommand cmd = new SqlCommand(qInsert, con))
//                    {
//                        cmd.Parameters.AddWithValue("@BillNo", billNo);
//                        cmd.Parameters.AddWithValue("@ResNo", hfReservationNo.Value);
//                        cmd.Parameters.AddWithValue("@RecNo", hfReceiptNo.Value);
//                        cmd.Parameters.AddWithValue("@Guest", lblGuestName.Text);
//                        cmd.Parameters.AddWithValue("@GuestOf", lblGuestOf.Text);
//                        cmd.Parameters.AddWithValue("@Club", lblClubName.Text == "â€”" ? "" : lblClubName.Text);
//                        cmd.Parameters.AddWithValue("@From", DateTime.Parse(lblFromDate.Text));
//                        cmd.Parameters.AddWithValue("@To", DateTime.Parse(lblToDate.Text));
//                        cmd.Parameters.AddWithValue("@Amount", amount);
//                        cmd.Parameters.AddWithValue("@Remarks", descr);
//                        cmd.Parameters.AddWithValue("@RoomNo", ddlBillRooms.SelectedValue);

//                        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//                        // EMP_ID PASSED TO INSERT QUERY
//                        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//                        cmd.Parameters.AddWithValue("@EmpID", empId);

//                        con.Open();
//                        cmd.ExecuteNonQuery();

//                        string desc = (amount < 0) ? "Mid-Stay Adjustment / Reversal" : "Mid-Stay Payment / Credit";

//                        if (amount < 0)
//                            PostToLedger(hfReservationNo.Value, ddlBillRooms.SelectedValue, billNo, desc, Math.Abs(amount), 0, con, null, null);
//                        else
//                            PostToLedger(hfReservationNo.Value, ddlBillRooms.SelectedValue, billNo, desc, 0, amount, con, null, null);

//                        try
//                        {
//                            string qSync = @"
//                        DECLARE @TotalGross DECIMAL(18,2) = (SELECT ISNULL(SUM(GrossTotal),0) FROM GR_Bills WHERE ReservationNo = @ResNo AND BillNo NOT LIKE 'ADV-MID-%');
//                        DECLARE @TotalPaid DECIMAL(18,2) =
//                            (SELECT ISNULL(SUM(AmountPaid),0) FROM GR_Bills WHERE ReservationNo = @ResNo)
//                            + (SELECT ISNULL(SUM(AdvancePayment),0) FROM RoomReservations WHERE ReservationNo = @ResNo);
//                        IF (@TotalPaid >= @TotalGross AND @TotalGross > 0)
//                        BEGIN
//                            UPDATE GR_Bills SET BillStatus = 'Settled' WHERE ReservationNo = @ResNo AND UPPER(BillStatus) = 'DRAFT';
//                        END";
//                            using (SqlCommand cmdSync = new SqlCommand(qSync, con))
//                            {
//                                cmdSync.Parameters.AddWithValue("@ResNo", hfReservationNo.Value);
//                                cmdSync.ExecuteNonQuery();
//                            }
//                        }
//                        catch { }
//                    }

//                    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//                    // MESSAGE SHOWING EMPLOYEE ID WHO PROCESSED THE PAYMENT
//                    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//                    ShowMessage("Interim Payment of PKR " + amount.ToString("N0") + " recorded successfully by Employee ID: " + empId, true);
//                    txtInterimAmount.Text = "";
//                    txtInterimRemarks.Text = "";

//                    LoadReservationDetails(hfReservationNo.Value);
//                    LoadBillsHistory(hfReservationNo.Value);
//                }
//            }
//            catch (Exception ex)
//            {
//                ShowMessage("Error recording payment: " + ex.Message, false);
//            }
//        }


//        private string BuildReceiptScript(string billNo, decimal gross, decimal roomRent,
//            decimal tax, decimal other, decimal adv, decimal manual, decimal netBal, decimal payBack, string roomNo)
//        {
//            var d = new StringBuilder();
//            d.Append("showReceipt({");
//            d.Append("billNo:'" + billNo + "',");
//            d.Append("date:'" + DateTime.Now.ToString("dd-MMM-yyyy hh:mm tt") + "',");
//            d.Append("guest:'" + Esc(lblGuestName.Text) + "',");
//            d.Append("guestOf:'" + Esc(lblGuestOf.Text) + "',");
//            d.Append("club:'" + Esc(lblClubName.Text) + "',");
//            d.Append("resNo:'" + Esc(hfReservationNo.Value) + "',");
//            d.Append("checkIn:'" + Esc(lblFromDate.Text) + "',");
//            d.Append("checkOut:'" + Esc(lblToDate.Text) + "',");
//            d.Append("rooms:'" + txtNoOfRooms.Text + "',");
//            d.Append("nights:'" + txtNoOfNights.Text + "',");
//            d.Append("roomNo:'" + (roomNo == "0" ? "All" : roomNo) + "',");
//            d.Append("roomDesc:'" + Esc(hfRoomDescription.Value) + "',");
//            d.Append("roomRent:'" + roomRent.ToString("N0") + "',");
//            d.Append("tax:'" + tax.ToString("N0") + "',");
//            d.Append("other:'" + other.ToString("N0") + "',");
//            d.Append("gross:'" + gross.ToString("N0") + "',");
//            d.Append("advance:'" + adv.ToString("N0") + "',");
//            d.Append("manual:'" + manual.ToString("N0") + "',");
//            d.Append("balance:'" + netBal.ToString("N0") + "',");
//            d.Append("payback:'" + payBack.ToString("N0") + "'");
//            d.Append("});");
//            return d.ToString();
//        }

//        private string Esc(string s)
//        {
//            return (s ?? "").Replace("'", "\\'");
//        }

//        private void LoadBillsHistory(string searchTerm)
//        {
//            try
//            {
//                if (string.IsNullOrEmpty(searchTerm))
//                {
//                    gvBills.DataSource = null;
//                    gvBills.DataBind();
//                    lblBillCount.Text = "0";
//                    return;
//                }

//                using (SqlConnection con = new SqlConnection(connStr))
//                using (SqlCommand cmd = new SqlCommand("sp_GR_GetBills", con))
//                {
//                    cmd.CommandType = CommandType.StoredProcedure;
//                    cmd.Parameters.Add("@SearchTerm", SqlDbType.VarChar, 50).Value = searchTerm;
//                    SqlDataAdapter da = new SqlDataAdapter(cmd);
//                    DataTable dt = new DataTable();
//                    con.Open();
//                    da.Fill(dt);
//                    gvBills.DataSource = dt;
//                    gvBills.DataBind();
//                    lblBillCount.Text = dt.Rows.Count.ToString();
//                }
//            }
//            catch { }
//        }

//        protected void gvBills_RowCommand(object sender, GridViewCommandEventArgs e)
//        {
//            if (e.CommandName == "LoadBill")
//            {
//                string resNo = e.CommandArgument.ToString();
//                LoadReservationDetails(resNo);
//                ShowMessage("Loaded billing profile for Reservation " + resNo, true);
//            }
//            else if (e.CommandName == "VoidPayment")
//            {
//                string billNo = e.CommandArgument.ToString();
//                VoidInterimPayment(billNo);
//            }
//        }

//        //private void VoidInterimPayment(string billNo)
//        //{
//        //    try
//        //    {
//        //        using (SqlConnection con = new SqlConnection(connStr))
//        //        {
//        //            con.Open();

//        //            decimal amountPaid = 0;
//        //            string roomNo = "";
//        //            // FIX: UPPER() for case-insensitive void check
//        //            string qAmt = "SELECT AmountPaid, RoomNo FROM GR_Bills WHERE BillNo = @BillNo AND UPPER(BillStatus) != 'VOID'";
//        //            using (SqlCommand cmd = new SqlCommand(qAmt, con))
//        //            {
//        //                cmd.Parameters.AddWithValue("@BillNo", billNo);
//        //                using (SqlDataReader dr = cmd.ExecuteReader())
//        //                {
//        //                    if (dr.Read())
//        //                    {
//        //                        amountPaid = dr["AmountPaid"] != DBNull.Value ? Convert.ToDecimal(dr["AmountPaid"]) : 0;
//        //                        roomNo = dr["RoomNo"].ToString();
//        //                    }
//        //                }
//        //            }

//        //            if (amountPaid > 0)
//        //            {
//        //                string qVoid = "UPDATE GR_Bills SET BillStatus = 'VOID', AmountPaid = 0, GrossTotal = 0, Remarks = Remarks + ' [VOIDED]' WHERE BillNo = @BillNo";
//        //                using (SqlCommand cmd = new SqlCommand(qVoid, con))
//        //                {
//        //                    cmd.Parameters.AddWithValue("@BillNo", billNo);
//        //                    cmd.ExecuteNonQuery();
//        //                }

//        //                string reversalRef = "VOID-" + DateTime.Now.ToString("yyyyMMddHHmm");
//        //                PostToLedger(hfReservationNo.Value, roomNo, reversalRef, "Reversal / Void of " + billNo, amountPaid, 0, con, null, null);

//        //                ShowMessage("Payment " + billNo + " voided successfully.", true);
//        //                LoadReservationDetails(hfReservationNo.Value);
//        //                LoadBillsHistory(hfReservationNo.Value);
//        //            }
//        //            else
//        //            {
//        //                ShowMessage("Payment is already voided or invalid.", false);
//        //            }
//        //        }
//        //    }
//        //    catch (Exception ex)
//        //    {
//        //        ShowMessage("Error voiding payment: " + ex.Message, false);
//        //    }
//        //}




//        private void VoidInterimPayment(string billNo)
//        {
//            // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//            // EMP_ID VALIDATION - Check if user is logged in
//            // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//            if (Session["Emp_ID"] == null)
//            {
//                ShowMessage("Session expired. Please login again to void payment.", false);
//                return;
//            }

//            string empIdFromSession = Session["Emp_ID"].ToString();

//            try
//            {
//                using (SqlConnection con = new SqlConnection(connStr))
//                {
//                    con.Open();

//                    decimal amountPaid = 0;
//                    string roomNo = "";
//                    string qAmt = "SELECT AmountPaid, RoomNo FROM GR_Bills WHERE BillNo = @BillNo AND UPPER(BillStatus) != 'VOID'";
//                    using (SqlCommand cmd = new SqlCommand(qAmt, con))
//                    {
//                        cmd.Parameters.AddWithValue("@BillNo", billNo);
//                        using (SqlDataReader dr = cmd.ExecuteReader())
//                        {
//                            if (dr.Read())
//                            {
//                                amountPaid = dr["AmountPaid"] != DBNull.Value ? Convert.ToDecimal(dr["AmountPaid"]) : 0;
//                                roomNo = dr["RoomNo"].ToString();
//                            }
//                        }
//                    }

//                    if (amountPaid > 0)
//                    {
//                        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//                        // UPDATE QUERY WITH EMP_ID IN REMARKS (AUDIT TRAIL)
//                        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//                        string qVoid = @"UPDATE GR_Bills 
//                                 SET BillStatus = 'VOID', 
//                                     AmountPaid = 0, 
//                                     GrossTotal = 0, 
//                                     Remarks = Remarks + ' [VOIDED by EmpID: " + empIdFromSession + " on " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + " WHERE BillNo = @BillNo";

//                using (SqlCommand cmd = new SqlCommand(qVoid, con))
//                        {
//                            cmd.Parameters.AddWithValue("@BillNo", billNo);
//                            cmd.ExecuteNonQuery();
//                        }

//                        string reversalRef = "VOID-" + DateTime.Now.ToString("yyyyMMddHHmm");
//                        PostToLedger(hfReservationNo.Value, roomNo, reversalRef, "Reversal / Void of " + billNo + " by EmpID: " + empIdFromSession, amountPaid, 0, con, null, null);

//                        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//                        // MESSAGE SHOWING EMPLOYEE ID WHO VOIDED THE PAYMENT
//                        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//                        ShowMessage("Payment " + billNo + " voided successfully by Employee ID: " + empIdFromSession, true);
//                        LoadReservationDetails(hfReservationNo.Value);
//                        LoadBillsHistory(hfReservationNo.Value);
//                    }
//                    else
//                    {
//                        ShowMessage("Payment is already voided or invalid.", false);
//                    }
//                }
//            }
//            catch (Exception ex)
//            {
//                ShowMessage("Error voiding payment: " + ex.Message, false);
//            }
//        }

//        protected void btnClear_Click(object sender, EventArgs e)
//        {
//            SetPanelsVisible(false);
//            hfReservationNo.Value = "";
//            hfReceiptNo.Value = "";
//            hfAdvancePaid.Value = "0";
//            txtSearchRes.Text = "";
//            lblBillNo.Text = "NEW BILL";
//            LoadBillsHistory(null);
//        }

//        protected string GetBillStatusChip(string status)
//        {
//            switch ((status ?? "").ToUpper())
//            {
//                case "SETTLED": return "status-chip chip-settled";
//                case "REFUNDED": return "status-chip chip-refund";
//                default: return "status-chip chip-draft";
//            }
//        }

//        private bool IsCheckoutAllowed(string resNo)
//        {
//            if (string.IsNullOrEmpty(resNo)) return false;
//            bool allowed = false;
//            try
//            {
//                using (SqlConnection con = new SqlConnection(connStr))
//                {
//                    string sql = @"
//                        SELECT 
//                            (SELECT COUNT(*) FROM RoomAllocations WHERE LTRIM(RTRIM(ReservationNo)) = LTRIM(RTRIM(@Res)) AND CheckOutDate IS NOT NULL) as CheckedOutRooms,
//                            (SELECT COUNT(*) FROM RoomReservations WHERE LTRIM(RTRIM(ReservationNo)) = LTRIM(RTRIM(@Res)) AND UPPER(LTRIM(RTRIM(Status))) IN ('COMPLETED','CHECKOUT','CHECKED OUT','COMPLETE')) as IsCompleted";

//                    using (SqlCommand cmd = new SqlCommand(sql, con))
//                    {
//                        cmd.Parameters.AddWithValue("@Res", resNo.Trim());
//                        con.Open();
//                        using (SqlDataReader dr = cmd.ExecuteReader())
//                        {
//                            if (dr.Read())
//                            {
//                                int coRooms = dr["CheckedOutRooms"] != DBNull.Value ? Convert.ToInt32(dr["CheckedOutRooms"]) : 0;
//                                int isComp = dr["IsCompleted"] != DBNull.Value ? Convert.ToInt32(dr["IsCompleted"]) : 0;
//                                if (coRooms > 0 || isComp > 0) allowed = true;
//                            }
//                        }
//                    }
//                }
//            }
//            catch { allowed = false; }
//            return allowed;
//        }

//        private decimal ParseDecimal(string s) { decimal v; decimal.TryParse(s, out v); return v; }
//        private int ParseInt(string s) { int v; int.TryParse(s, out v); return v; }

//        private void FetchRoomRate(string roomNo, out decimal rent, out decimal tax, out string description)
//        {
//            rent = 0; tax = 16; description = "";
//            try
//            {
//                using (SqlConnection con = new SqlConnection(connStr))
//                {
//                    string sql = "SELECT TOP 1 Rent, TaxPercentage, Description FROM RoomDefinitionNew WHERE LTRIM(RTRIM(RoomNo)) = @Room";
//                    using (SqlCommand cmd = new SqlCommand(sql, con))
//                    {
//                        cmd.Parameters.AddWithValue("@Room", (roomNo ?? "").Trim());
//                        con.Open();
//                        using (SqlDataReader dr = cmd.ExecuteReader())
//                        {
//                            if (dr.Read())
//                            {
//                                rent = dr["Rent"] != DBNull.Value ? Convert.ToDecimal(dr["Rent"]) : 0;
//                                tax = dr["TaxPercentage"] != DBNull.Value ? Convert.ToDecimal(dr["TaxPercentage"]) : 16;
//                                description = dr["Description"] != DBNull.Value ? dr["Description"].ToString() : "";
//                            }
//                        }
//                    }
//                }
//            }
//            catch { }
//        }

//        private void SetPanelsVisible(bool visible)
//        {
//            pnlBillForm.Visible = visible;
//            pnlSummarySide.Visible = visible;
//            pnlDetailedLedger.Visible = visible;
//        }

//        private void ShowMessage(string msg, bool success)
//        {
//            lblMessage.Text = msg;
//            lblMessage.CssClass = "alert show " + (success ? "alert-success" : "alert-error");
//            if (success)
//                ClientScript.RegisterStartupScript(GetType(), "HideMsg",
//                    "setTimeout(function(){ var m=document.getElementById('" + lblMessage.ClientID + "'); if(m) m.style.display='none'; },6000);", true);
//        }

//        private void PostToLedger(string resNo, string roomNo, string refNo, string desc, decimal debit, decimal credit, SqlConnection con, SqlTransaction trans, int? subDeptId)
//        {
//            string sql = "INSERT INTO GR_GuestLedger (ReservationNo, RoomNo, RefNo, Description, Debit, Credit, TransDate, SubDeptID) VALUES (@Res, @Room, @Ref, @Desc, @Dr, @Cr, GETDATE(), @SubID)";
//            using (SqlCommand cmd = new SqlCommand(sql, con, trans))
//            {
//                cmd.Parameters.AddWithValue("@Res", resNo);
//                cmd.Parameters.AddWithValue("@Room", roomNo);
//                cmd.Parameters.AddWithValue("@Ref", refNo);
//                cmd.Parameters.AddWithValue("@Desc", desc);
//                cmd.Parameters.AddWithValue("@Dr", debit);
//                cmd.Parameters.AddWithValue("@Cr", credit);
//                cmd.Parameters.AddWithValue("@SubID", (object)subDeptId ?? DBNull.Value);
//                cmd.ExecuteNonQuery();
//            }
//        }
//    }
//}



using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;


namespace GuestRoomApp.GuestRoomM
{
    public partial class ManageBills : System.Web.UI.Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadBillsHistory(null);
                SetPanelsVisible(false);

                if (!string.IsNullOrEmpty(Request.QueryString["ResNo"]))
                {
                    txtSearchRes.Text = Request.QueryString["ResNo"];
                    LoadReservationDetails(txtSearchRes.Text);
                }
            }
        }

        protected void btnSearchRes_Click(object sender, EventArgs e)
        {
            string search = txtSearchRes.Text.Trim();
            if (string.IsNullOrEmpty(search)) { ShowMessage("Please enter Reservation No or Receipt No.", false); return; }
            LoadReservationDetails(search);
        }

        // ======================== NEW HELPER METHODS FOR ROOM-SPECIFIC SETTLEMENT CHECK ========================

        private bool IsRoomSettled(string resNo, string roomNo)
        {
            if (string.IsNullOrEmpty(resNo) || roomNo == "0") return false;

            bool isSettled = false;
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string sql = @"
                        SELECT COUNT(*) FROM GR_Bills 
                        WHERE ReservationNo = @ResNo 
                        AND (RoomNo = @RoomNo OR RoomNo = '0')
                        AND UPPER(BillStatus) IN ('SETTLED','REFUNDED')
                        AND BillNo NOT LIKE 'ADV-MID-%'";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@ResNo", resNo);
                        cmd.Parameters.AddWithValue("@RoomNo", roomNo);
                        con.Open();
                        int count = Convert.ToInt32(cmd.ExecuteScalar());
                        isSettled = count > 0;
                    }
                }
            }
            catch { }
            return isSettled;
        }

        private int GetUnsettledRoomsCount(string resNo)
        {
            int unsettledCount = 0;
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string sql = @"
                        SELECT COUNT(DISTINCT a.RoomNo) 
                        FROM RoomAllocations a
                        WHERE a.ReservationNo = @ResNo
                        AND NOT EXISTS (
                            SELECT 1 FROM GR_Bills b 
                            WHERE b.ReservationNo = a.ReservationNo 
                            AND (b.RoomNo = a.RoomNo OR b.RoomNo = '0')
                            AND UPPER(b.BillStatus) IN ('SETTLED','REFUNDED')
                            AND b.BillNo NOT LIKE 'ADV-MID-%'
                        )";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@ResNo", resNo);
                        con.Open();
                        unsettledCount = Convert.ToInt32(cmd.ExecuteScalar());
                    }
                }
            }
            catch { }
            return unsettledCount;
        }

        private void LoadReservationDetails(string searchNo)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_GR_GetReservationForBill", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SearchNo", searchNo);
                    con.Open();
                    string resNo = "", recNo = "", guest = "", guestOf = "", club = "", status = "", allocRooms = "", existBill = "";
                    int rooms = 0; DateTime from = DateTime.MinValue, to = DateTime.MinValue;
                    decimal rent = 0, taxPct = 0;

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (!dr.Read())
                        {
                            ShowMessage("Reservation not found: " + searchNo, false);
                            SetPanelsVisible(false);
                            return;
                        }

                        resNo = dr["ReservationNo"].ToString();
                        recNo = dr["ReceiptNo"].ToString();
                        guest = dr["GuestName"].ToString();
                        guestOf = dr["GuestOf"].ToString();
                        club = dr["ClubName"].ToString();
                        status = dr["Status"].ToString();
                        rooms = Convert.ToInt32(dr["NoOfRooms"]);
                        from = Convert.ToDateTime(dr["FromDate"]);
                        to = Convert.ToDateTime(dr["ToDate"]);
                        rent = Convert.ToDecimal(dr["RentPerRoom"]);
                        taxPct = Convert.ToDecimal(dr["TaxPercent"]);
                        allocRooms = dr["AllocatedRooms"].ToString();
                        existBill = dr["ExistingBillNo"].ToString();
                    }

                    int nights = (to - from).Days;
                    if (nights < 1) nights = 1;

                    string groupRecNo = recNo;
                    if (string.IsNullOrEmpty(groupRecNo))
                    {
                        using (SqlCommand cmdR = new SqlCommand("SELECT TOP 1 ReceiptNo FROM RoomReservations WHERE ReservationNo = @ResNo", con))
                        {
                            cmdR.Parameters.AddWithValue("@ResNo", resNo);
                            object r = cmdR.ExecuteScalar();
                            if (r != null && r != DBNull.Value) groupRecNo = r.ToString();
                        }
                    }

                    double weightedNights = 0;
                    decimal totalAccurateRent = 0;
                    StringBuilder sbDesc = new StringBuilder();
                    int actualCount = 0;

                    CalculateDetailedStay(resNo, "0", to, out actualCount, out weightedNights, out totalAccurateRent, out sbDesc);

                    if (actualCount > 0)
                    {
                        if (rooms < 1) rooms = 1;
                        double avgNights = weightedNights / rooms;
                        nights = (int)Math.Ceiling(avgNights);

                        if (rooms > 0 && nights > 0)
                            rent = totalAccurateRent / (rooms * (decimal)avgNights);

                        txtNoOfNights.Text = avgNights.ToString("0.##");
                    }
                    else
                    {
                        sbDesc.Append("No allocations found");
                        totalAccurateRent = (rooms * nights * rent);
                    }

                    hfRoomDescription.Value = sbDesc.ToString();

                    if (string.IsNullOrEmpty(existBill))
                    {
                        using (SqlCommand cmdEx = new SqlCommand(
                            "SELECT TOP 1 BillNo FROM GR_Bills WHERE ReservationNo = @R AND RoomNo = '0' AND BillNo NOT LIKE 'ADV-MID-%' AND UPPER(BillStatus) IN ('SETTLED','REFUNDED') ORDER BY BillDate DESC", con))
                        {
                            cmdEx.Parameters.AddWithValue("@R", resNo);
                            object b = cmdEx.ExecuteScalar();
                            if (b != null)
                                existBill = b.ToString();
                            else
                            {
                                cmdEx.CommandText = "SELECT TOP 1 BillNo FROM GR_Bills WHERE ReservationNo = @R AND RoomNo = '0' AND BillNo NOT LIKE 'ADV-MID-%' AND UPPER(BillStatus) = 'DRAFT' ORDER BY BillDate DESC";
                                b = cmdEx.ExecuteScalar();
                                if (b != null) existBill = b.ToString();
                            }
                        }
                    }

                    lblGuestName.Text = guest;
                    lblGuestOf.Text = guestOf;
                    lblClubName.Text = string.IsNullOrEmpty(club) ? "" : club;
                    lblResNo.Text = resNo;
                    lblRecNo.Text = recNo;

                    string finalStatus = status;
                    try
                    {
                        using (SqlCommand cmdStat = new SqlCommand(@"
                SELECT 
                    COUNT(*) as Total,
                    SUM(CASE WHEN CheckOutDate IS NULL THEN 1 ELSE 0 END) as Occupied
                FROM RoomAllocations WHERE ReservationNo = @R", con))
                        {
                            cmdStat.Parameters.AddWithValue("@R", resNo);
                            using (SqlDataReader drStat = cmdStat.ExecuteReader())
                            {
                                if (drStat.Read())
                                {
                                    int total = Convert.ToInt32(drStat["Total"]);
                                    int occupied = Convert.ToInt32(drStat["Occupied"]);
                                    if (total > 0)
                                        finalStatus = occupied > 0 ? "Occupied" : "Completed";
                                }
                            }
                        }
                    }
                    catch { }
                    lblResStatus.Text = finalStatus;

                    hfReservationNo.Value = resNo;
                    hfReceiptNo.Value = recNo;
                    lblAllocRooms.Text = string.IsNullOrEmpty(allocRooms) ? "Not allocated yet" : allocRooms;
                    lblFromDate.Text = from.ToString("dd-MMM-yyyy");
                    lblToDate.Text = to.ToString("dd-MMM-yyyy");

                    txtManualPay.Text = "0";
                    txtCashPayBack.Text = "0";
                    txtRemarks.Text = "";
                    hfBillStatus.Value = "DRAFT";

                    txtNoOfRooms.Text = rooms.ToString();
                    txtNoOfNights.Text = nights.ToString();
                    txtRentPerNight.Text = rent.ToString("0");
                    txtTaxPercent.Text = taxPct.ToString("0");

                    decimal totalAdvance = 0;
                    string groupCriteria = string.IsNullOrEmpty(groupRecNo) ? "ReservationNo = @ResNo" : "ReceiptNo = @RecNo";

                    string qAdvTotal = string.Format(@"
                SELECT 
                    ISNULL((SELECT SUM(AdvancePayment) FROM RoomReservations WHERE {0}), 0) +
                    ISNULL((SELECT SUM(AmountPaid) FROM GR_Bills WHERE {0} AND BillNo LIKE 'ADV-MID-%' AND UPPER(BillStatus) != 'VOID'), 0) 
                AS TotalAdvance", groupCriteria);

                    using (SqlCommand cmdSum = new SqlCommand(qAdvTotal, con))
                    {
                        cmdSum.Parameters.AddWithValue("@ResNo", resNo);
                        if (!string.IsNullOrEmpty(groupRecNo)) cmdSum.Parameters.AddWithValue("@RecNo", groupRecNo);
                        totalAdvance = Convert.ToDecimal(cmdSum.ExecuteScalar());
                    }

                    txtAdvancePaid.Text = totalAdvance.ToString("0");
                    hfAdvancePaid.Value = totalAdvance.ToString("0");
                    lblBillNo.Text = string.IsNullOrEmpty(existBill) ? "NEW BILL" : existBill;

                    if (!string.IsNullOrEmpty(existBill))
                        LoadExistingBill(existBill, con);

                    if (actualCount > 0)
                    {
                        int currentRooms = 1;
                        if (!int.TryParse(txtNoOfRooms.Text, out currentRooms) || currentRooms < 1) currentRooms = rooms;

                        double avgN = weightedNights / currentRooms;
                        txtNoOfNights.Text = avgN.ToString("0.##");
                        decimal perRoomPerNight = (currentRooms > 0 && avgN > 0)
                            ? totalAccurateRent / (currentRooms * (decimal)avgN)
                            : rent;
                        txtRentPerNight.Text = perRoomPerNight.ToString("0");
                    }

                    txtAdvancePaid.Text = totalAdvance.ToString("0");
                    hfAdvancePaid.Value = totalAdvance.ToString("0");

                    decimal pendingServices = GetPendingServiceCharges(resNo, "0");
                    decimal existingOther = 0;
                    decimal.TryParse(txtOtherCharges.Text, out existingOther);
                    txtOtherCharges.Text = Math.Max(existingOther, pendingServices).ToString("0");

                    lnkLedger.NavigateUrl = "GuestLedger.aspx?ResNo=" + resNo;
                    lnkLedger.Visible = true;

                    PopulateRoomsDropdown(resNo);
                    GenerateLedger(resNo, "0");

                    SetPanelsVisible(true);

                    // ======================== FIX: Room-specific settlement check ========================
                    string selectedRoom = ddlBillRooms.SelectedValue;
                    bool isCurrentRoomSettled = false;
                    int unsettledRoomsCount = 0;

                    if (selectedRoom != "0")
                    {
                        isCurrentRoomSettled = IsRoomSettled(resNo, selectedRoom);
                        unsettledRoomsCount = GetUnsettledRoomsCount(resNo);
                    }
                    else
                    {
                        unsettledRoomsCount = GetUnsettledRoomsCount(resNo);
                        isCurrentRoomSettled = unsettledRoomsCount == 0;
                    }

                    ToggleBillLock(isCurrentRoomSettled);

                    if (isCurrentRoomSettled)
                    {
                        btnSaveBill.Text = "Reprint Settled Bill";
                        btnSaveBill.Style["background"] = "linear-gradient(135deg,#2e7d32,#1b5e20)";
                        hfBillStatus.Value = "SETTLED";
                        txtManualPay.ReadOnly = true;
                        txtManualPay.Style["background"] = "#f5f0e8";
                        txtManualPay.Style["color"] = "#7a7a7a";
                    }
                    else
                    {
                        if (unsettledRoomsCount > 0 && selectedRoom != "0")
                        {
                            btnSaveBill.Text = "Save & Finalize Bill for Room " + selectedRoom;
                        }
                        else if (unsettledRoomsCount > 0 && selectedRoom == "0")
                        {
                            btnSaveBill.Text = "Save & Finalize Bill for All Rooms";
                        }
                        else
                        {
                            btnSaveBill.Text = "Save & Finalize Bill";
                        }
                        btnSaveBill.Style["background"] = "linear-gradient(135deg,#1A1A2E,#2d2d5e)";
                        hfBillStatus.Value = "DRAFT";
                        txtManualPay.ReadOnly = false;
                        txtManualPay.Style["background"] = "#fff";
                        txtManualPay.Style["color"] = "#1A1A2E";
                    }

                    ClientScript.RegisterStartupScript(GetType(), "calc", "calcBill();", true);
                    LoadBillsHistory(resNo);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        private void ToggleBillLock(bool isSettled)
        {
            bool isEditable = !isSettled;
            txtManualPay.ReadOnly = isSettled;
            txtCashPayBack.ReadOnly = isSettled;
            txtRemarks.ReadOnly = isSettled;
            txtInterimAmount.ReadOnly = isSettled;
            txtInterimRemarks.ReadOnly = isSettled;
            btnPost.Enabled = isEditable;
            ddlPaymentMode.Enabled = isEditable;
            txtBankTillID.ReadOnly = isSettled;
            txtRefID.ReadOnly = isSettled;

            string bgColor = isSettled ? "#f5f0e8" : "#fff";
            string textColor = isSettled ? "#7a7a7a" : "#1A1A2E";

            txtManualPay.Style["background"] = bgColor;
            txtManualPay.Style["color"] = textColor;
            txtCashPayBack.Style["background"] = bgColor;
            txtCashPayBack.Style["color"] = textColor;
            txtRemarks.Style["background"] = bgColor;
            txtRemarks.Style["color"] = textColor;
            txtInterimAmount.Style["background"] = bgColor;
            txtInterimRemarks.Style["background"] = bgColor;

            txtNoOfRooms.ReadOnly = true;
            txtNoOfNights.ReadOnly = true;
            txtRentPerNight.ReadOnly = true;
            txtTaxPercent.ReadOnly = true;
            txtOtherCharges.ReadOnly = true;
        }

        private void GenerateLedger(string resNo, string roomNo = "0")
        {
            DataTable dtLedger = CreateLedgerSchema();

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();

                string receiptNo = hfReceiptNo.Value;
                DateTime resDate = DateTime.Now;
                using (SqlCommand cmd = new SqlCommand("SELECT ResDate FROM RoomReservations WHERE ReservationNo = @ResNo", con))
                {
                    cmd.Parameters.AddWithValue("@ResNo", resNo);
                    object resDateObj = cmd.ExecuteScalar();
                    if (resDateObj != null && resDateObj != DBNull.Value) resDate = Convert.ToDateTime(resDateObj);
                }

                string resCriteria = "ReservationNo = @ResNo";
                if (!string.IsNullOrEmpty(receiptNo))
                    resCriteria = "ReservationNo IN (SELECT ReservationNo FROM RoomReservations WHERE ReceiptNo = @RecNo)";

                // Advance Payment row with Club Name in description
                decimal totalAdvance = 0;
                string qAdv = string.Format("SELECT ISNULL(SUM(AdvancePayment), 0) FROM RoomReservations WHERE {0}", resCriteria);
                using (SqlCommand cmdSum = new SqlCommand(qAdv, con))
                {
                    cmdSum.Parameters.AddWithValue("@ResNo", resNo);
                    if (!string.IsNullOrEmpty(receiptNo)) cmdSum.Parameters.AddWithValue("@RecNo", receiptNo);
                    totalAdvance = Convert.ToDecimal(cmdSum.ExecuteScalar());
                }

                string clubName = lblClubName.Text;
                string clubDesc = string.IsNullOrEmpty(clubName) ? "" : " - Club: " + clubName;

                if (roomNo == "0")
                    dtLedger.Rows.Add(resDate, "ADV-REC", "Initial Advance Payment" + clubDesc, 0, totalAdvance, 0);

                var settledBillRooms = new System.Collections.Generic.HashSet<string>(StringComparer.OrdinalIgnoreCase);
                bool wholeResSettled = false;
                try
                {
                    string qSR = string.Format(
                        "SELECT ISNULL(NULLIF(LTRIM(RTRIM(RoomNo)),'0'),'ALL') FROM GR_Bills WHERE {0} AND UPPER(BillStatus) IN ('SETTLED','REFUNDED') AND BillNo NOT LIKE 'ADV-MID-%'",
                        resCriteria);
                    using (SqlCommand cmdSR = new SqlCommand(qSR, con))
                    {
                        cmdSR.Parameters.AddWithValue("@ResNo", resNo);
                        if (!string.IsNullOrEmpty(receiptNo)) cmdSR.Parameters.AddWithValue("@RecNo", receiptNo);
                        using (SqlDataReader drSR = cmdSR.ExecuteReader())
                        {
                            while (drSR.Read())
                            {
                                string br = drSR[0].ToString();
                                if (br == "ALL") { wholeResSettled = true; settledBillRooms.Clear(); break; }
                                settledBillRooms.Add(br);
                            }
                        }
                    }
                }
                catch { }

                // Accrued Rent rows with Club Name
                try
                {
                    string qStay = string.Format(@"
                        SELECT ra.RoomNo, ra.AllocatedDate, ra.CheckOutDate, ISNULL(ra.StayFactor, 1.0) as StayFactor, rd.Rent, rd.TaxPercentage, ra.LastChargedDate
                        FROM RoomAllocations ra
                        INNER JOIN RoomDefinitionNew rd ON ra.RoomNo = rd.RoomNo
                        WHERE {0}", resCriteria);

                    using (SqlCommand cmd = new SqlCommand(qStay, con))
                    {
                        cmd.Parameters.AddWithValue("@ResNo", resNo);
                        if (!string.IsNullOrEmpty(receiptNo)) cmd.Parameters.AddWithValue("@RecNo", receiptNo);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                string rNo = dr["RoomNo"].ToString();
                                if (wholeResSettled) continue;
                                if (settledBillRooms.Contains(rNo) || settledBillRooms.Contains(rNo.TrimStart('0'))) continue;

                                DateTime chkIn = Convert.ToDateTime(dr["AllocatedDate"]);
                                DateTime lastAudit = dr["LastChargedDate"] == DBNull.Value ? chkIn.Date : Convert.ToDateTime(dr["LastChargedDate"]).Date;
                                DateTime effCheckOut = dr["CheckOutDate"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(dr["CheckOutDate"]);
                                double stayFactor = Convert.ToDouble(dr["StayFactor"]);
                                decimal rate = Convert.ToDecimal(dr["Rent"]);
                                decimal taxPct = Convert.ToDecimal(dr["TaxPercentage"]);

                                int fullNights = (effCheckOut.Date - chkIn.Date).Days;
                                double totalSegmentNights = fullNights;
                                if (stayFactor < 1.0) totalSegmentNights += stayFactor;
                                else if (totalSegmentNights < 1) totalSegmentNights = 1.0;

                                int auditedNights = dr["LastChargedDate"] == DBNull.Value ? 0 : (lastAudit - chkIn.Date).Days + 1;
                                if (auditedNights < 0) auditedNights = 0;
                                double pendingNights = totalSegmentNights - (double)auditedNights;

                                if (pendingNights > 0)
                                {
                                    if (roomNo != "0" && rNo != roomNo.Trim() && rNo.TrimStart('0') != roomNo.Trim().TrimStart('0')) continue;

                                    DateTime nextChargeDate = (dr["LastChargedDate"] == DBNull.Value) ? chkIn.Date : lastAudit.AddDays(1);
                                    double nightsProcessed = 0;

                                    while (nightsProcessed < pendingNights)
                                    {
                                        double currentNightFactor = 1.0;
                                        if (pendingNights - nightsProcessed < 1.0)
                                            currentNightFactor = pendingNights - nightsProcessed;

                                        decimal nightRent = rate * (decimal)currentNightFactor;
                                        decimal nightTax = Math.Round(nightRent * taxPct / 100, 2);
                                        string dateLabel = nextChargeDate.ToString("dd-MMM");
                                        string nightDesc = "Accrued Rent (Room " + rNo + ") - " + dateLabel + clubDesc;
                                        if (currentNightFactor < 1.0) nightDesc += string.Format(" ({0:0.##} day)", currentNightFactor);

                                        dtLedger.Rows.Add(nextChargeDate, "RENT-ACC", nightDesc, nightRent, 0, 0);
                                        if (nightTax > 0)
                                            dtLedger.Rows.Add(nextChargeDate, "TAX-ACC", "Accrued GST/Tax (Room " + rNo + ") - " + dateLabel + clubDesc, nightTax, 0, 0);

                                        nextChargeDate = nextChargeDate.AddDays(1);
                                        nightsProcessed += 1.0;
                                    }
                                }
                            }
                        }
                    }
                }
                catch { }

                // Services with Club Name
                string qServices = string.Format("SELECT * FROM GR_RoomServices WHERE {0} {1} ORDER BY OrderDate",
                    resCriteria,
                    (roomNo == "0" ? "" : " AND RoomNo = @RoomNo"));

                using (SqlCommand cmd = new SqlCommand(qServices, con))
                {
                    cmd.Parameters.AddWithValue("@ResNo", resNo);
                    if (!string.IsNullOrEmpty(receiptNo)) cmd.Parameters.AddWithValue("@RecNo", receiptNo);
                    if (roomNo != "0") cmd.Parameters.AddWithValue("@RoomNo", roomNo);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            decimal amt = dr["TotalAmount"] == DBNull.Value ? 0 : Convert.ToDecimal(dr["TotalAmount"]);
                            string svcName = dr["ServiceName"].ToString();
                            string rNo = dr["RoomNo"] == DBNull.Value || dr["RoomNo"].ToString() == "0" ? "" : " (Room " + dr["RoomNo"].ToString() + ")";
                            string invNo = dr["InvoiceNo"] == DBNull.Value ? "SVC-" + dr["ServiceID"].ToString() : dr["InvoiceNo"].ToString();
                            string desc = svcName + (dr["Qty"].ToString() == "1" ? "" : " (Qty: " + dr["Qty"] + ")") + rNo + clubDesc;
                            dtLedger.Rows.Add(dr["OrderDate"], invNo, desc, amt, 0, 0);
                        }
                    }
                }

                // Bills & Payments with detailed breakdown
                string qPayments = string.Format("SELECT * FROM GR_Bills WHERE {0} {1} ORDER BY BillDate",
                    resCriteria,
                    (roomNo == "0" ? "" : " AND RoomNo = @RoomNo"));

                using (SqlCommand cmd = new SqlCommand(qPayments, con))
                {
                    cmd.Parameters.AddWithValue("@ResNo", resNo);
                    if (!string.IsNullOrEmpty(receiptNo)) cmd.Parameters.AddWithValue("@RecNo", receiptNo);
                    if (roomNo != "0") cmd.Parameters.AddWithValue("@RoomNo", roomNo);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            if (dr["BillNo"] != DBNull.Value)
                            {
                                string billNo = dr["BillNo"].ToString();
                                DateTime bDate = Convert.ToDateTime(dr["BillDate"]);
                                decimal paid = Convert.ToDecimal(dr["AmountPaid"]);
                                string rNo = dr["RoomNo"].ToString();
                                string roomInfo = (rNo == "0") ? "" : " (Room " + rNo + ")";
                                string paymentModeInfo = "";

                                // VS2015 Compatible - No string interpolation
                                if (dr["PaymentMode"] != DBNull.Value && !string.IsNullOrEmpty(dr["PaymentMode"].ToString()))
                                {
                                    paymentModeInfo = " - Payment Mode: " + dr["PaymentMode"].ToString();
                                    if (dr["BankTillID"] != DBNull.Value && !string.IsNullOrEmpty(dr["BankTillID"].ToString()))
                                        paymentModeInfo += ", Bank: " + dr["BankTillID"].ToString();
                                    if (dr["RefID"] != DBNull.Value && !string.IsNullOrEmpty(dr["RefID"].ToString()))
                                        paymentModeInfo += ", Ref: " + dr["RefID"].ToString();
                                }

                                if (billNo.StartsWith("ADV-MID-"))
                                {
                                    string desc = (paid < 0 ? "Payment Reversal / Adjustment" : "Mid-Stay Payment / Credit") + roomInfo + clubDesc;
                                    dtLedger.Rows.Add(bDate, billNo, desc, 0, paid, 0);
                                }
                                else
                                {
                                    decimal bRooms = dr["NoOfRooms"] != DBNull.Value ? Convert.ToDecimal(dr["NoOfRooms"]) : 0;
                                    decimal bNights = dr["NoOfNights"] != DBNull.Value ? Convert.ToDecimal(dr["NoOfNights"]) : 0;
                                    decimal bRate = dr["RoomRentPerNight"] != DBNull.Value ? Convert.ToDecimal(dr["RoomRentPerNight"]) : 0;
                                    decimal bTaxPct = dr["TaxPercent"] != DBNull.Value ? Convert.ToDecimal(dr["TaxPercent"]) : 0;
                                    decimal bOther = dr["OtherCharges"] != DBNull.Value ? Convert.ToDecimal(dr["OtherCharges"]) : 0;

                                    decimal bRoomRent = bRooms * bNights * bRate;
                                    decimal bTax = Math.Round(bRoomRent * bTaxPct / 100, 2);

                                    if (bRoomRent == 0 && bOther == 0 && dr["GrossTotal"] != DBNull.Value)
                                    {
                                        decimal bGross = Convert.ToDecimal(dr["GrossTotal"]);
                                        if (bGross != 0)
                                            dtLedger.Rows.Add(bDate, billNo, "Final Bill Total" + roomInfo + clubDesc + paymentModeInfo, bGross, 0, 0);
                                    }
                                    else
                                    {
                                        if (bRoomRent > 0)
                                        {
                                            string rentDesc = string.Format("Room Rent: {0}R \u00d7 {1}N @ PKR {2:N0}{3}{4}",
                                                bRooms, bNights, bRate, roomInfo, clubDesc);
                                            dtLedger.Rows.Add(bDate, billNo, rentDesc, bRoomRent, 0, 0);
                                        }

                                        if (bTax > 0)
                                        {
                                            string taxDesc = string.Format("GST/Tax ({0}%){1}{2}", bTaxPct, roomInfo, clubDesc);
                                            dtLedger.Rows.Add(bDate, billNo, taxDesc, bTax, 0, 0);
                                        }

                                        if (bOther > 0)
                                            dtLedger.Rows.Add(bDate, billNo, "Other Services & Charges" + roomInfo + clubDesc, bOther, 0, 0);
                                    }

                                    decimal bAdv = dr["AdvancePaid"] != DBNull.Value ? Convert.ToDecimal(dr["AdvancePaid"]) : 0;
                                    if (bAdv != 0)
                                        dtLedger.Rows.Add(bDate, billNo, "Advance Adjusted" + roomInfo + clubDesc, 0, bAdv, 0);

                                    if (paid != 0)
                                        dtLedger.Rows.Add(bDate, billNo, "Settlement Payment" + roomInfo + clubDesc + paymentModeInfo, 0, paid, 0);
                                }
                            }
                        }
                    }
                }
            }

            DataView dv = dtLedger.DefaultView;
            dv.Sort = "Date ASC";
            DataTable dtSorted = dv.ToTable();
            decimal runningBal = 0;

            foreach (DataRow row in dtSorted.Rows)
            {
                decimal dr2 = Convert.ToDecimal(row["Debit"]);
                decimal cr2 = Convert.ToDecimal(row["Credit"]);
                runningBal += (dr2 - cr2);
                row["Balance"] = runningBal;
            }

            gvLedger.DataSource = dtSorted;
            gvLedger.DataBind();
            pnlDetailedLedger.Visible = true;
        }

        private DataTable CreateLedgerSchema()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Date", typeof(DateTime));
            dt.Columns.Add("RefNo", typeof(string));
            dt.Columns.Add("Description", typeof(string));
            dt.Columns.Add("Debit", typeof(decimal));
            dt.Columns.Add("Credit", typeof(decimal));
            dt.Columns.Add("Balance", typeof(decimal));
            return dt;
        }

        private void PopulateRoomsDropdown(string resNo)
        {
            ddlBillRooms.Items.Clear();
            ddlBillRooms.Items.Add(new ListItem("  All Allocated Rooms  ", "0"));

            using (SqlConnection con = new SqlConnection(connStr))
            {
                string receiptNo = hfReceiptNo.Value;
                string sql = @"
                    SELECT a.RoomNo, a.CheckOutDate, 
                           (SELECT COUNT(*) FROM GR_Bills b 
                            WHERE b.ReservationNo = a.ReservationNo 
                            AND (b.RoomNo = a.RoomNo OR b.RoomNo = '0') 
                            AND UPPER(b.BillStatus) IN ('SETTLED','REFUNDED')
                            AND b.BillNo NOT LIKE 'ADV-MID-%') as SettledCount
                    FROM RoomAllocations a WHERE a.ReservationNo = @Res";

                if (!string.IsNullOrEmpty(receiptNo))
                {
                    sql = @"
                        SELECT a.RoomNo, a.CheckOutDate,
                               (SELECT COUNT(*) FROM GR_Bills b 
                                WHERE b.ReservationNo = a.ReservationNo 
                                AND (b.RoomNo = a.RoomNo OR b.RoomNo = '0') 
                                AND UPPER(b.BillStatus) IN ('SETTLED','REFUNDED')
                                AND b.BillNo NOT LIKE 'ADV-MID-%') as SettledCount
                        FROM RoomAllocations a 
                        WHERE a.ReservationNo IN (SELECT ReservationNo FROM RoomReservations WHERE ReceiptNo = @RecNo)";
                }
                sql += " ORDER BY a.RoomNo";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@Res", resNo);
                    if (!string.IsNullOrEmpty(receiptNo)) cmd.Parameters.AddWithValue("@RecNo", receiptNo);
                    con.Open();
                    StringBuilder sbRooms = new StringBuilder();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string r = dr["RoomNo"].ToString();
                            bool isCheckedOut = dr["CheckOutDate"] != DBNull.Value;
                            bool isSettled = dr["SettledCount"] != DBNull.Value && Convert.ToInt32(dr["SettledCount"]) > 0;

                            string statusLabel = isCheckedOut ? "COMPLETED" : "OCCUPIED";
                            if (isSettled) statusLabel = "SETTLED";

                            string label = string.Format("Room {0} ({1})", r, statusLabel);
                            ddlBillRooms.Items.Add(new ListItem(label, r));

                            if (sbRooms.Length > 0) sbRooms.Append(", ");
                            sbRooms.Append(r);
                        }
                    }
                    lblAllocRooms.Text = sbRooms.Length > 0 ? sbRooms.ToString() : "Not allocated yet";
                }
            }
        }

        protected void ddlBillRooms_SelectedIndexChanged(object sender, EventArgs e)
        {
            string resNo = hfReservationNo.Value;
            if (string.IsNullOrEmpty(resNo)) return;
            string selectedRoom = ddlBillRooms.SelectedValue;
            double sNights = 0; decimal sRent = 0; int sCount = 0; StringBuilder sDesc = new StringBuilder();
            DateTime toD = DateTime.Parse(lblToDate.Text);

            if (selectedRoom == "0")
            {
                LoadReservationDetails(resNo);
                lblBillNo.Text = "NEW BILL";
                return;
            }
            else
            {
                txtManualPay.Text = "0";
                txtCashPayBack.Text = "0";
                txtRemarks.Text = "";
                hfBillStatus.Value = "DRAFT";

                CalculateDetailedStay(resNo, selectedRoom.Trim(), toD, out sCount, out sNights, out sRent, out sDesc);

                txtNoOfRooms.Text = "1";
                txtNoOfNights.Text = sNights.ToString("0.##");

                decimal rate, tax; string descClean;
                FetchRoomRate(selectedRoom.Trim(), out rate, out tax, out descClean);
                txtRentPerNight.Text = rate.ToString("0");
                txtTaxPercent.Text = tax.ToString("0");
                hfRoomDescription.Value = sDesc.ToString();
                txtOtherCharges.Text = GetPendingServiceCharges(resNo, selectedRoom.Trim()).ToString("0");

                decimal totalAdv = GetRemainingAdvanceForRoom(resNo, hfReceiptNo.Value, selectedRoom.Trim());
                txtAdvancePaid.Text = totalAdv.ToString("0");
                hfAdvancePaid.Value = totalAdv.ToString("0");

                GenerateLedger(resNo, selectedRoom.Trim());

                try
                {
                    using (SqlConnection con = new SqlConnection(connStr))
                    {
                        string sql = "SELECT CheckOutDate FROM RoomAllocations WHERE ReservationNo = @Res AND RoomNo = @Room";
                        using (SqlCommand cmd = new SqlCommand(sql, con))
                        {
                            cmd.Parameters.AddWithValue("@Res", resNo);
                            cmd.Parameters.AddWithValue("@Room", selectedRoom.Trim());
                            con.Open();
                            object co = cmd.ExecuteScalar();
                            lblResStatus.Text = (co == null || co == DBNull.Value) ? "Occupied" : "Completed";
                        }
                    }
                }
                catch { }

                CheckExistingRoomBill(resNo, selectedRoom.Trim());

                // ======================== FIX: Check if this specific room is already settled ========================
                bool isRoomSettled = IsRoomSettled(resNo, selectedRoom.Trim());

                if (isRoomSettled)
                {
                    ToggleBillLock(true);
                    btnSaveBill.Text = "Room Already Settled - View Only";
                    btnSaveBill.Enabled = false;
                    txtManualPay.ReadOnly = true;
                    txtManualPay.Style["background"] = "#f5f0e8";
                    ShowMessage("This room has already been billed and settled. You cannot modify it.", false);
                }
                else
                {
                    ToggleBillLock(false);
                    btnSaveBill.Enabled = true;
                    btnSaveBill.Text = "Save & Finalize Bill for Room " + selectedRoom;
                    txtManualPay.ReadOnly = false;
                    txtManualPay.Style["background"] = "#fff";
                    txtManualPay.Style["color"] = "#1A1A2E";
                }
            }
            ClientScript.RegisterStartupScript(GetType(), "calc", "calcBill();", true);
        }

        private decimal GetRemainingAdvanceForRoom(string resNo, string receiptNo, string roomNo)
        {
            decimal remainingAdvance = 0;
            string criteria = "ReservationNo = @ResNo";
            if (!string.IsNullOrEmpty(receiptNo))
                criteria = "ReservationNo IN (SELECT ReservationNo FROM RoomReservations WHERE ReceiptNo = @RecNo)";

            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    string qTotal = string.Format(@"
                SELECT 
                    ISNULL((SELECT SUM(AdvancePayment) FROM RoomReservations WHERE {0}), 0) +
                    ISNULL((SELECT SUM(AmountPaid) FROM GR_Bills WHERE {0} AND BillNo LIKE 'ADV-MID-%' AND UPPER(BillStatus) != 'VOID'), 0) 
                AS TotalAdvance", criteria);

                    decimal totalAdvance = 0;
                    using (SqlCommand cmdTotal = new SqlCommand(qTotal, con))
                    {
                        cmdTotal.Parameters.AddWithValue("@ResNo", resNo);
                        if (!string.IsNullOrEmpty(receiptNo)) cmdTotal.Parameters.AddWithValue("@RecNo", receiptNo);
                        totalAdvance = Convert.ToDecimal(cmdTotal.ExecuteScalar());
                    }

                    string qConsumed = @"
                SELECT ISNULL(SUM(AdvancePaid), 0) FROM GR_Bills 
                WHERE " + criteria + @"
                AND UPPER(BillStatus) IN ('SETTLED','REFUNDED') 
                AND BillNo NOT LIKE 'ADV-MID-%'
                AND RoomNo = @RoomNo";

                    decimal consumedAdvance = 0;
                    using (SqlCommand cmdConsumed = new SqlCommand(qConsumed, con))
                    {
                        cmdConsumed.Parameters.AddWithValue("@ResNo", resNo);
                        if (!string.IsNullOrEmpty(receiptNo)) cmdConsumed.Parameters.AddWithValue("@RecNo", receiptNo);
                        cmdConsumed.Parameters.AddWithValue("@RoomNo", roomNo);
                        consumedAdvance = Convert.ToDecimal(cmdConsumed.ExecuteScalar());
                    }

                    remainingAdvance = totalAdvance - consumedAdvance;
                    if (remainingAdvance < 0) remainingAdvance = 0;
                }
            }
            catch { }
            return remainingAdvance;
        }

        private void CheckExistingRoomBill(string resNo, string roomNo)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string sql = @"
                    SELECT TOP 1 BillNo FROM GR_Bills 
                    WHERE ReservationNo = @Res 
                    AND (RoomNo = @Room OR RoomNo = '0') 
                    AND BillNo NOT LIKE 'ADV-MID-%' 
                    AND UPPER(BillStatus) IN ('SETTLED','REFUNDED')
                    ORDER BY (CASE WHEN RoomNo = @Room THEN 0 ELSE 1 END), BillDate DESC";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@Res", resNo);
                    cmd.Parameters.AddWithValue("@Room", roomNo);
                    con.Open();
                    object billNo = cmd.ExecuteScalar();
                    if (billNo != null)
                    {
                        lblBillNo.Text = billNo.ToString();
                        LoadExistingBill(billNo.ToString(), con);
                    }
                    else
                    {
                        cmd.CommandText = @"
                            SELECT TOP 1 BillNo FROM GR_Bills 
                            WHERE ReservationNo = @Res 
                            AND (RoomNo = @Room OR RoomNo = '0') 
                            AND BillNo NOT LIKE 'ADV-MID-%' 
                            AND UPPER(BillStatus) = 'DRAFT'
                            ORDER BY (CASE WHEN RoomNo = @Room THEN 0 ELSE 1 END), BillDate DESC";
                        billNo = cmd.ExecuteScalar();
                        if (billNo != null)
                        {
                            lblBillNo.Text = billNo.ToString();
                            LoadExistingBill(billNo.ToString(), con);
                        }
                        else
                        {
                            lblBillNo.Text = "NEW BILL";
                        }
                    }
                }
            }
        }

        private void CalculateDetailedStay(string resNo, string roomNo, DateTime expectedToDate, out int roomCount, out double totalWeightedNights, out decimal totalRent, out StringBuilder description)
        {
            roomCount = 0;
            totalWeightedNights = 0;
            totalRent = 0;
            description = new StringBuilder();

            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string receiptNo = hfReceiptNo.Value;
                    string settledFilter = @" AND NOT EXISTS (
                        SELECT 1 FROM GR_Bills 
                        WHERE ReservationNo = ra.ReservationNo 
                        AND UPPER(BillStatus) IN ('SETTLED','REFUNDED')
                        AND BillNo NOT LIKE 'ADV-MID-%'
                        AND (RoomNo = ra.RoomNo OR RoomNo = '0')
                    )";

                    string sql = string.Format(@"
                        SELECT ra.RoomNo, ra.AllocatedDate, ra.CheckOutDate, ISNULL(ra.StayFactor, 1.0) as StayFactor, rd.Rent
                        FROM RoomAllocations ra
                        INNER JOIN RoomDefinitionNew rd ON ra.RoomNo = rd.RoomNo
                        WHERE (ra.ReservationNo = @ResNo OR (@RecNo <> '' AND ra.ReservationNo IN (SELECT ReservationNo FROM RoomReservations WHERE ReceiptNo = @RecNo)))
                        {0}", settledFilter);

                    SqlCommand cmd = new SqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("@ResNo", resNo);
                    cmd.Parameters.AddWithValue("@RecNo", receiptNo ?? "");

                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string rNo = dr["RoomNo"].ToString();
                            if (roomNo != "0" && rNo != roomNo.Trim() && rNo.TrimStart('0') != roomNo.Trim().TrimStart('0')) continue;

                            roomCount++;
                            DateTime chkIn = Convert.ToDateTime(dr["AllocatedDate"]);
                            DateTime chkOut = dr["CheckOutDate"] == DBNull.Value
                                ? (DateTime.Now.Date > expectedToDate.Date ? DateTime.Now : expectedToDate)
                                : Convert.ToDateTime(dr["CheckOutDate"]);
                            double stayFactor = Convert.ToDouble(dr["StayFactor"]);

                            int fullDays = (chkOut.Date - chkIn.Date).Days;
                            double sNights = fullDays;
                            if (stayFactor < 1.0) sNights += stayFactor;
                            else if (sNights < 1) sNights = 1.0;

                            decimal rate = Convert.ToDecimal(dr["Rent"]);
                            totalRent += ((decimal)sNights * rate);
                            totalWeightedNights += sNights;

                            if (description.Length > 0) description.Append(", ");
                            description.Append(dr["RoomNo"].ToString() + " (" + sNights + " nts)");
                        }
                    }
                }
            }
            catch { }
        }

        private decimal GetPendingServiceCharges(string resNo, string roomNo)
        {
            decimal total = 0;
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string receiptNo = hfReceiptNo.Value;
                    string settledFilter = @" AND NOT EXISTS (
                        SELECT 1 FROM GR_Bills 
                        WHERE ReservationNo = @Res 
                        AND UPPER(BillStatus) IN ('SETTLED','REFUNDED')
                        AND BillNo NOT LIKE 'ADV-MID-%'
                        AND (RoomNo = GR_RoomServices.RoomNo OR RoomNo = '0')
                    )";

                    string sql = @"
                        SELECT TotalAmount, RoomNo 
                        FROM GR_RoomServices 
                        WHERE (ReservationNo = @Res OR (@RecNo <> '' AND ReservationNo IN (SELECT ReservationNo FROM RoomReservations WHERE ReceiptNo = @RecNo)))
                        AND Status IN ('Pending', 'Confirmed')
                        AND ServiceName NOT LIKE 'Room Rent (Automatic)%'
                        AND ServiceName NOT LIKE 'GST on Room Rent%' " + settledFilter;

                    SqlCommand cmd = new SqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("@Res", resNo);
                    cmd.Parameters.AddWithValue("@RecNo", receiptNo ?? "");

                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string rNo = dr["RoomNo"] == DBNull.Value ? "" : dr["RoomNo"].ToString();
                            if (roomNo != "0" && rNo != roomNo.Trim() && rNo.TrimStart('0') != roomNo.Trim().TrimStart('0')) continue;
                            total += dr["TotalAmount"] == DBNull.Value ? 0 : Convert.ToDecimal(dr["TotalAmount"]);
                        }
                    }
                }
            }
            catch { }
            return total;
        }

        private void LoadExistingBill(string billNo, SqlConnection con)
        {
            if (string.IsNullOrEmpty(billNo) || billNo.StartsWith("ADV-MID-")) return;

            try
            {
                using (SqlCommand cmd = new SqlCommand("SELECT * FROM GR_Bills WHERE BillNo = @BillNo", con))
                {
                    cmd.Parameters.AddWithValue("@BillNo", billNo);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            txtNoOfRooms.Text = dr["NoOfRooms"].ToString();
                            txtNoOfNights.Text = dr["NoOfNights"].ToString();
                            txtRentPerNight.Text = Convert.ToDecimal(dr["RoomRentPerNight"]).ToString("0");
                            txtTaxPercent.Text = Convert.ToDecimal(dr["TaxPercent"]).ToString("0");
                            txtOtherCharges.Text = Convert.ToDecimal(dr["OtherCharges"]).ToString("0");
                            txtRemarks.Text = dr["Remarks"].ToString();

                            decimal paid = Convert.ToDecimal(dr["AmountPaid"]);
                            string bStatus = dr["BillStatus"].ToString();

                            if (bStatus.ToUpper() == "SETTLED" || bStatus.ToUpper() == "REFUNDED")
                            {
                                decimal historicalAdv = dr["AdvancePaid"] != DBNull.Value ? Convert.ToDecimal(dr["AdvancePaid"]) : 0;
                                txtAdvancePaid.Text = historicalAdv.ToString("0");
                                hfAdvancePaid.Value = historicalAdv.ToString("0");
                            }

                            if (paid > 0) { txtManualPay.Text = paid.ToString("0"); txtCashPayBack.Text = "0"; }
                            else if (paid < 0) { txtCashPayBack.Text = Math.Abs(paid).ToString("0"); txtManualPay.Text = "0"; }

                            if (dr["TotalRoomRent"] != DBNull.Value)
                                hfRoomDescription.Value = dr["Remarks"].ToString();

                            string status = dr["BillStatus"].ToString();
                            hfBillStatus.Value = status;

                            // Load Payment Details from saved bill
                            try
                            {
                                if (dr["PaymentMode"] != DBNull.Value && !string.IsNullOrEmpty(dr["PaymentMode"].ToString()))
                                    ddlPaymentMode.SelectedValue = dr["PaymentMode"].ToString();

                                if (dr["BankTillID"] != DBNull.Value && !string.IsNullOrEmpty(dr["BankTillID"].ToString()))
                                    txtBankTillID.Text = dr["BankTillID"].ToString();

                                if (dr["RefID"] != DBNull.Value && !string.IsNullOrEmpty(dr["RefID"].ToString()))
                                    txtRefID.Text = dr["RefID"].ToString();
                            }
                            catch { }

                            if (status.ToUpper() == "SETTLED" || status.ToUpper() == "REFUNDED")
                            {
                                btnSaveBill.Text = "Reprint Settled Bill";
                                btnSaveBill.Style["background"] = "linear-gradient(135deg,#2e7d32,#1b5e20)";
                                ToggleBillLock(true);

                                try
                                {
                                    decimal rRooms = 0; decimal.TryParse(dr["NoOfRooms"].ToString(), out rRooms);
                                    decimal rNights = 0; decimal.TryParse(dr["NoOfNights"].ToString(), out rNights);
                                    decimal rRate = 0; decimal.TryParse(dr["RoomRentPerNight"].ToString(), out rRate);
                                    decimal rTaxPct = 0; decimal.TryParse(dr["TaxPercent"].ToString(), out rTaxPct);
                                    decimal rOther = 0; decimal.TryParse(dr["OtherCharges"].ToString(), out rOther);
                                    decimal rAdv = 0;
                                    decimal.TryParse(hfAdvancePaid.Value, out rAdv);

                                    decimal roomRent = rRooms * rNights * rRate;
                                    decimal tax = Math.Round(roomRent * rTaxPct / 100, 2);
                                    decimal gross = roomRent + tax + rOther;
                                    decimal netBal = gross - (rAdv + paid);
                                    decimal payBack = (rAdv + paid) > gross ? (rAdv + paid) - gross : 0;

                                    string rJs = BuildReceiptScript(billNo, gross, roomRent, tax, rOther, rAdv, paid, netBal, payBack, dr["RoomNo"].ToString());
                                    ClientScript.RegisterStartupScript(GetType(), "receipt_" + billNo, rJs, true);
                                }
                                catch { }
                            }
                            else
                            {
                                btnSaveBill.Text = "Save & Finalize Bill";
                                btnSaveBill.Style["background"] = "linear-gradient(135deg,#1A1A2E,#2d2d5e)";
                                ToggleBillLock(false);
                            }
                        }
                        else
                        {
                            hfBillStatus.Value = "";
                            btnSaveBill.Text = "Save & Finalize Bill";
                            btnSaveBill.Style["background"] = "linear-gradient(135deg,#1A1A2E,#2d2d5e)";
                        }
                    }
                }
            }
            catch { }
        }

        protected void btnSaveBill_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hfReservationNo.Value))
            {
                ShowMessage("Please search and load a reservation first.", false);
                return;
            }

            // ======================== FIX: Check if this specific room is already settled ========================
            string selectedRoom = ddlBillRooms.SelectedValue;
            if (selectedRoom != "0")
            {
                bool isRoomSettled = IsRoomSettled(hfReservationNo.Value, selectedRoom);
                if (isRoomSettled)
                {
                    ShowMessage("This room has already been billed and settled. Cannot save again.", false);
                    return;
                }
            }

            if (Session["Emp_ID"] == null)
            {
                ShowMessage("Session expired. Please login again to save bill.", false);
                return;
            }

            int empId;
            if (!int.TryParse(Session["Emp_ID"].ToString(), out empId))
            {
                ShowMessage("Invalid Employee ID in session. Please login again.", false);
                return;
            }

            if (hfBillStatus.Value.ToUpper() == "SETTLED" || hfBillStatus.Value.ToUpper() == "REFUNDED")
            {
                decimal rRent = ParseDecimal(txtRentPerNight.Text) * ParseInt(txtNoOfRooms.Text) * (decimal)ParseDecimal(txtNoOfNights.Text);
                decimal rTax = Math.Round(rRent * ParseDecimal(txtTaxPercent.Text) / 100, 2);
                decimal rGross = rRent + rTax + ParseDecimal(txtOtherCharges.Text);
                decimal rAdv = ParseDecimal(txtAdvancePaid.Text);
                decimal rManual = ParseDecimal(txtManualPay.Text) - ParseDecimal(txtCashPayBack.Text);

                decimal rNet = rGross - (rAdv + rManual);
                decimal rPB = (rAdv + rManual) > rGross ? (rAdv + rManual) - rGross : 0;

                string rJs = BuildReceiptScript(lblBillNo.Text, rGross, rRent, rTax, ParseDecimal(txtOtherCharges.Text), rAdv, rManual, rNet, rPB, ddlBillRooms.SelectedValue);

                if (hfAutoPrint.Value == "true" || true)
                {
                    rJs += " window.print(); ";
                    hfAutoPrint.Value = "false";
                }

                ClientScript.RegisterStartupScript(GetType(), "receipt", rJs, true);
                ShowMessage("Viewing existing settled bill: " + lblBillNo.Text, true);
                return;
            }

            if (!IsCheckoutAllowed(hfReservationNo.Value))
            {
                ShowMessage("Bill cannot be finalized until Room Checkout or Partial Checkout is processed.", false);
                return;
            }

            try
            {
                decimal rentPerNight = ParseDecimal(txtRentPerNight.Text);
                int rooms = ParseInt(txtNoOfRooms.Text);
                decimal nightsDecimal = ParseDecimal(txtNoOfNights.Text);
                decimal taxPct = ParseDecimal(txtTaxPercent.Text);
                decimal other = ParseDecimal(txtOtherCharges.Text);
                decimal adv = ParseDecimal(txtAdvancePaid.Text);
                decimal manual = ParseDecimal(txtManualPay.Text) - ParseDecimal(txtCashPayBack.Text);

                if (rooms <= 0 || nightsDecimal <= 0 || rentPerNight <= 0)
                {
                    ShowMessage("Please fill in Rooms, Nights, and Rent per Night.", false);
                    return;
                }

                using (SqlConnection con = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_GR_SaveBill", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@ReservationNo", hfReservationNo.Value);
                    cmd.Parameters.AddWithValue("@ReceiptNo", hfReceiptNo.Value);
                    cmd.Parameters.AddWithValue("@GuestName", lblGuestName.Text);
                    cmd.Parameters.AddWithValue("@GuestOf", lblGuestOf.Text);
                    cmd.Parameters.AddWithValue("@ClubName", lblClubName.Text == "â€”" ? "" : lblClubName.Text);
                    cmd.Parameters.AddWithValue("@FromDate", DateTime.Parse(lblFromDate.Text));
                    cmd.Parameters.AddWithValue("@ToDate", DateTime.Parse(lblToDate.Text));
                    cmd.Parameters.AddWithValue("@NoOfRooms", rooms);
                    cmd.Parameters.AddWithValue("@NoOfNights", nightsDecimal);
                    cmd.Parameters.AddWithValue("@RoomRentPerNight", rentPerNight);
                    cmd.Parameters.AddWithValue("@TaxPercent", taxPct);
                    cmd.Parameters.AddWithValue("@OtherCharges", other);
                    cmd.Parameters.AddWithValue("@AdvancePaid", adv);
                    cmd.Parameters.AddWithValue("@AmountPaid", manual);
                    cmd.Parameters.AddWithValue("@Remarks", txtRemarks.Text.Trim());
                    cmd.Parameters.AddWithValue("@RoomNo", ddlBillRooms.SelectedValue);
                    cmd.Parameters.AddWithValue("@EmpID", empId);

                    // Payment Mode Details
                    string paymentMode = ddlPaymentMode.SelectedValue;
                    string bankTillID = txtBankTillID.Text.Trim();
                    string refID = txtRefID.Text.Trim();

                    cmd.Parameters.AddWithValue("@PaymentMode", paymentMode);
                    cmd.Parameters.AddWithValue("@BankTillID", bankTillID);
                    cmd.Parameters.AddWithValue("@RefID", refID);

                    SqlParameter pBillNo = new SqlParameter("@BillNo", SqlDbType.VarChar, 20) { Direction = ParameterDirection.Output };
                    SqlParameter pNet = new SqlParameter("@NetBalance", SqlDbType.Decimal) { Direction = ParameterDirection.Output };
                    SqlParameter pPayBack = new SqlParameter("@PayBack", SqlDbType.Decimal) { Direction = ParameterDirection.Output };
                    cmd.Parameters.Add(pBillNo); cmd.Parameters.Add(pNet); cmd.Parameters.Add(pPayBack);

                    con.Open();
                    cmd.ExecuteNonQuery();

                    string billNo = pBillNo.Value.ToString();
                    decimal netBal = Convert.ToDecimal(pNet.Value);
                    decimal payBack = Convert.ToDecimal(pPayBack.Value);

                    lblBillNo.Text = billNo;

                    decimal roomRent = rooms * nightsDecimal * rentPerNight;
                    decimal tax = Math.Round(roomRent * taxPct / 100, 2);
                    decimal gross = roomRent + tax + other;

                    string js = BuildReceiptScript(billNo, gross, roomRent, tax, other, adv, manual, netBal, payBack, ddlBillRooms.SelectedValue);

                    if (hfAutoPrint.Value == "true" || true)
                    {
                        js += " window.print(); ";
                        hfAutoPrint.Value = "false";
                    }

                    ClientScript.RegisterStartupScript(GetType(), "receipt", js, true);
                    LoadBillsHistory(hfReservationNo.Value);

                    string statusMsg = netBal <= 0 && payBack == 0
                        ? "Bill saved & settled! Services and Advance integrated. (Processed by Employee ID: " + empId + ")"
                        : payBack > 0
                            ? "Bill saved! Pay back PKR " + payBack.ToString("N0") + " to guest. (Processed by Employee ID: " + empId + ")"
                            : "Bill saved! Amount due: PKR " + netBal.ToString("N0") + " (Processed by Employee ID: " + empId + ")";

                    ShowMessage(statusMsg, true);

                    PostToLedger(hfReservationNo.Value, ddlBillRooms.SelectedValue, billNo, "Final Bill Settlement: Room Rent (" + rooms + " R Ã— " + nightsDecimal + " N)", roomRent, 0, con, null, null);
                    if (tax > 0)
                        PostToLedger(hfReservationNo.Value, ddlBillRooms.SelectedValue, billNo, "Final Bill Settlement: GST/Tax", tax, 0, con, null, null);
                    if (manual > 0)
                        PostToLedger(hfReservationNo.Value, ddlBillRooms.SelectedValue, billNo, "Final Bill Settlement: " + paymentMode + " Payment", 0, manual, con, null, null);
                }
            }
            catch (Exception ex) { ShowMessage("Error saving bill: " + ex.Message, false); }
        }

        protected void btnPostPayment_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hfReservationNo.Value))
            {
                ShowMessage("Please search and load a reservation first.", false);
                return;
            }

            // Check if this specific room is already settled
            string selectedRoom = ddlBillRooms.SelectedValue;
            if (selectedRoom != "0")
            {
                bool isRoomSettled = IsRoomSettled(hfReservationNo.Value, selectedRoom);
                if (isRoomSettled)
                {
                    ShowMessage("This room has already been billed and settled. Cannot record payments.", false);
                    return;
                }
            }

            if (Session["Emp_ID"] == null)
            {
                ShowMessage("Session expired. Please login again to record payment.", false);
                return;
            }

            int empId;
            if (!int.TryParse(Session["Emp_ID"].ToString(), out empId))
            {
                ShowMessage("Invalid Employee ID in session. Please login again.", false);
                return;
            }

            if (hfBillStatus.Value.ToUpper() == "SETTLED" || hfBillStatus.Value.ToUpper() == "REFUNDED")
            {
                ShowMessage("Cannot record transactions for a settled bill.", false);
                return;
            }

            decimal amount = ParseDecimal(txtInterimAmount.Text);
            string remarks = txtInterimRemarks.Text.Trim();

            if (ddlTransType.SelectedValue == "VOID" && amount > 0)
                amount = -amount;

            if (amount == 0)
            {
                ShowMessage("Please enter a valid payment or reversal amount.", false);
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string billNo = "ADV-MID-" + DateTime.Now.ToString("yyyyMMddHHmm");
                    string descr = (amount < 0 ? "Reversal / Adjustment: " : "Mid-Stay Advance / Credit: ") + remarks;

                    string qInsert = @"
                INSERT INTO GR_Bills (BillNo, BillDate, ReservationNo, ReceiptNo, GuestName, GuestOf, ClubName, FromDate, ToDate,
                    NoOfRooms, NoOfNights, RoomRentPerNight, TaxPercent, OtherCharges, AdvancePaid, AmountPaid, Remarks, BillStatus, RoomNo, GrossTotal, TotalRoomRent, TaxAmount, EmpID, PaymentMode, BankTillID, RefID)
                VALUES (@BillNo, GETDATE(), @ResNo, @RecNo, @Guest, @GuestOf, @Club, @From, @To,
                    0, 0, 0, 0, 0, 0, @Amount, @Remarks, 'SETTLED', @RoomNo, @Amount, 0, 0, @EmpID, @PaymentMode, @BankTillID, @RefID)";

                    using (SqlCommand cmd = new SqlCommand(qInsert, con))
                    {
                        cmd.Parameters.AddWithValue("@BillNo", billNo);
                        cmd.Parameters.AddWithValue("@ResNo", hfReservationNo.Value);
                        cmd.Parameters.AddWithValue("@RecNo", hfReceiptNo.Value);
                        cmd.Parameters.AddWithValue("@Guest", lblGuestName.Text);
                        cmd.Parameters.AddWithValue("@GuestOf", lblGuestOf.Text);
                        cmd.Parameters.AddWithValue("@Club", lblClubName.Text == "â€”" ? "" : lblClubName.Text);
                        cmd.Parameters.AddWithValue("@From", DateTime.Parse(lblFromDate.Text));
                        cmd.Parameters.AddWithValue("@To", DateTime.Parse(lblToDate.Text));
                        cmd.Parameters.AddWithValue("@Amount", amount);
                        cmd.Parameters.AddWithValue("@Remarks", descr);
                        cmd.Parameters.AddWithValue("@RoomNo", ddlBillRooms.SelectedValue);
                        cmd.Parameters.AddWithValue("@EmpID", empId);

                        string paymentMode = ddlPaymentMode.SelectedValue;
                        string bankTillID = txtBankTillID.Text.Trim();
                        string refID = txtRefID.Text.Trim();
                        cmd.Parameters.AddWithValue("@PaymentMode", paymentMode);
                        cmd.Parameters.AddWithValue("@BankTillID", bankTillID);
                        cmd.Parameters.AddWithValue("@RefID", refID);

                        con.Open();
                        cmd.ExecuteNonQuery();

                        string desc = (amount < 0) ? "Mid-Stay Adjustment / Reversal" : "Mid-Stay Payment / Credit";
                        string paymentInfo = (paymentMode != "Cash") ? " (" + paymentMode + (bankTillID != "" ? ", Bank: " + bankTillID : "") + (refID != "" ? ", Ref: " + refID : "") + ")" : "";

                        if (amount < 0)
                            PostToLedger(hfReservationNo.Value, ddlBillRooms.SelectedValue, billNo, desc + paymentInfo, Math.Abs(amount), 0, con, null, null);
                        else
                            PostToLedger(hfReservationNo.Value, ddlBillRooms.SelectedValue, billNo, desc + paymentInfo, 0, amount, con, null, null);

                        try
                        {
                            string qSync = @"
                        DECLARE @TotalGross DECIMAL(18,2) = (SELECT ISNULL(SUM(GrossTotal),0) FROM GR_Bills WHERE ReservationNo = @ResNo AND BillNo NOT LIKE 'ADV-MID-%');
                        DECLARE @TotalPaid DECIMAL(18,2) =
                            (SELECT ISNULL(SUM(AmountPaid),0) FROM GR_Bills WHERE ReservationNo = @ResNo)
                            + (SELECT ISNULL(SUM(AdvancePayment),0) FROM RoomReservations WHERE ReservationNo = @ResNo);
                        IF (@TotalPaid >= @TotalGross AND @TotalGross > 0)
                        BEGIN
                            UPDATE GR_Bills SET BillStatus = 'Settled' WHERE ReservationNo = @ResNo AND UPPER(BillStatus) = 'DRAFT';
                        END";
                            using (SqlCommand cmdSync = new SqlCommand(qSync, con))
                            {
                                cmdSync.Parameters.AddWithValue("@ResNo", hfReservationNo.Value);
                                cmdSync.ExecuteNonQuery();
                            }
                        }
                        catch { }
                    }

                    ShowMessage("Interim Payment of PKR " + amount.ToString("N0") + " recorded successfully by Employee ID: " + empId, true);
                    txtInterimAmount.Text = "";
                    txtInterimRemarks.Text = "";

                    LoadReservationDetails(hfReservationNo.Value);
                    LoadBillsHistory(hfReservationNo.Value);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error recording payment: " + ex.Message, false);
            }
        }

        private string BuildReceiptScript(string billNo, decimal gross, decimal roomRent,
            decimal tax, decimal other, decimal adv, decimal manual, decimal netBal, decimal payBack, string roomNo)
        {
            var d = new StringBuilder();
            d.Append("showReceipt({");
            d.Append("billNo:'" + Esc(billNo) + "',");
            d.Append("date:'" + DateTime.Now.ToString("dd-MMM-yyyy hh:mm tt") + "',");
            d.Append("guest:'" + Esc(lblGuestName.Text) + "',");
            d.Append("guestOf:'" + Esc(lblGuestOf.Text) + "',");
            d.Append("club:'" + Esc(lblClubName.Text) + "',");
            d.Append("resNo:'" + Esc(hfReservationNo.Value) + "',");
            d.Append("checkIn:'" + Esc(lblFromDate.Text) + "',");
            d.Append("checkOut:'" + Esc(lblToDate.Text) + "',");
            d.Append("rooms:'" + txtNoOfRooms.Text + "',");
            d.Append("nights:'" + txtNoOfNights.Text + "',");
            d.Append("roomNo:'" + (roomNo == "0" ? "All" : roomNo) + "',");
            d.Append("roomDesc:'" + Esc(hfRoomDescription.Value) + "',");
            d.Append("roomRent:'" + roomRent.ToString("N0") + "',");
            d.Append("tax:'" + tax.ToString("N0") + "',");
            d.Append("other:'" + other.ToString("N0") + "',");
            d.Append("gross:'" + gross.ToString("N0") + "',");
            d.Append("advance:'" + adv.ToString("N0") + "',");
            d.Append("manual:'" + manual.ToString("N0") + "',");
            d.Append("balance:'" + netBal.ToString("N0") + "',");
            d.Append("payback:'" + payBack.ToString("N0") + "'");
            d.Append("});");
            return d.ToString();
        }

        private string Esc(string s)
        {
            return (s ?? "").Replace("'", "\\'");
        }

        private void LoadBillsHistory(string searchTerm)
        {
            try
            {
                if (string.IsNullOrEmpty(searchTerm))
                {
                    gvBills.DataSource = null;
                    gvBills.DataBind();
                    lblBillCount.Text = "0";
                    return;
                }

                using (SqlConnection con = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_GR_GetBills", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@SearchTerm", SqlDbType.VarChar, 50).Value = searchTerm;
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    con.Open();
                    da.Fill(dt);
                    gvBills.DataSource = dt;
                    gvBills.DataBind();
                    lblBillCount.Text = dt.Rows.Count.ToString();
                }
            }
            catch { }
        }

        protected void gvBills_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "LoadBill")
            {
                string resNo = e.CommandArgument.ToString();
                LoadReservationDetails(resNo);
                ShowMessage("Loaded billing profile for Reservation " + resNo, true);
            }
            else if (e.CommandName == "VoidPayment")
            {
                string billNo = e.CommandArgument.ToString();
                VoidInterimPayment(billNo);
            }
        }

        private void VoidInterimPayment(string billNo)
        {
            if (Session["Emp_ID"] == null)
            {
                ShowMessage("Session expired. Please login again to void payment.", false);
                return;
            }

            string empIdFromSession = Session["Emp_ID"].ToString();

            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    decimal amountPaid = 0;
                    string roomNo = "";
                    string qAmt = "SELECT AmountPaid, RoomNo FROM GR_Bills WHERE BillNo = @BillNo AND UPPER(BillStatus) != 'VOID'";
                    using (SqlCommand cmd = new SqlCommand(qAmt, con))
                    {
                        cmd.Parameters.AddWithValue("@BillNo", billNo);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                amountPaid = dr["AmountPaid"] != DBNull.Value ? Convert.ToDecimal(dr["AmountPaid"]) : 0;
                                roomNo = dr["RoomNo"].ToString();
                            }
                        }
                    }

                    if (amountPaid > 0)
                    {
                        string qVoid = @"UPDATE GR_Bills 
                                 SET BillStatus = 'VOID', 
                                     AmountPaid = 0, 
                                     GrossTotal = 0, 
                                     Remarks = Remarks + ' [VOIDED by EmpID: " + empIdFromSession + " on " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "]'  WHERE BillNo = @BillNo";


                        using (SqlCommand cmd = new SqlCommand(qVoid, con))
                        {
                            cmd.Parameters.AddWithValue("@BillNo", billNo);
                            cmd.ExecuteNonQuery();
                        }

                        string reversalRef = "VOID-" + DateTime.Now.ToString("yyyyMMddHHmm");
                        PostToLedger(hfReservationNo.Value, roomNo, reversalRef, "Reversal / Void of " + billNo + " by EmpID: " + empIdFromSession, amountPaid, 0, con, null, null);

                        ShowMessage("Payment " + billNo + " voided successfully by Employee ID: " + empIdFromSession, true);
                        LoadReservationDetails(hfReservationNo.Value);
                        LoadBillsHistory(hfReservationNo.Value);
                    }
                    else
                    {
                        ShowMessage("Payment is already voided or invalid.", false);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error voiding payment: " + ex.Message, false);
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            SetPanelsVisible(false);
            hfReservationNo.Value = "";
            hfReceiptNo.Value = "";
            hfAdvancePaid.Value = "0";
            txtSearchRes.Text = "";
            lblBillNo.Text = "NEW BILL";
            LoadBillsHistory(null);
        }

        protected string GetBillStatusChip(string status)
        {
            switch ((status ?? "").ToUpper())
            {
                case "SETTLED": return "chip chip-settled";
                case "REFUNDED": return "chip chip-refund";
                default: return "chip chip-draft";
            }
        }

        private bool IsCheckoutAllowed(string resNo)
        {
            if (string.IsNullOrEmpty(resNo)) return false;
            bool allowed = false;
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string sql = @"
                        SELECT 
                            (SELECT COUNT(*) FROM RoomAllocations WHERE LTRIM(RTRIM(ReservationNo)) = LTRIM(RTRIM(@Res)) AND CheckOutDate IS NOT NULL) as CheckedOutRooms,
                            (SELECT COUNT(*) FROM RoomReservations WHERE LTRIM(RTRIM(ReservationNo)) = LTRIM(RTRIM(@Res)) AND UPPER(LTRIM(RTRIM(Status))) IN ('COMPLETED','CHECKOUT','CHECKED OUT','COMPLETE')) as IsCompleted";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@Res", resNo.Trim());
                        con.Open();
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                int coRooms = dr["CheckedOutRooms"] != DBNull.Value ? Convert.ToInt32(dr["CheckedOutRooms"]) : 0;
                                int isComp = dr["IsCompleted"] != DBNull.Value ? Convert.ToInt32(dr["IsCompleted"]) : 0;
                                if (coRooms > 0 || isComp > 0) allowed = true;
                            }
                        }
                    }
                }
            }
            catch { allowed = false; }
            return allowed;
        }

        private decimal ParseDecimal(string s) { decimal v; decimal.TryParse(s, out v); return v; }
        private int ParseInt(string s) { int v; int.TryParse(s, out v); return v; }

        private void FetchRoomRate(string roomNo, out decimal rent, out decimal tax, out string description)
        {
            rent = 0; tax = 16; description = "";
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string sql = "SELECT TOP 1 Rent, TaxPercentage, Description FROM RoomDefinitionNew WHERE LTRIM(RTRIM(RoomNo)) = @Room";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@Room", (roomNo ?? "").Trim());
                        con.Open();
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                rent = dr["Rent"] != DBNull.Value ? Convert.ToDecimal(dr["Rent"]) : 0;
                                tax = dr["TaxPercentage"] != DBNull.Value ? Convert.ToDecimal(dr["TaxPercentage"]) : 16;
                                description = dr["Description"] != DBNull.Value ? dr["Description"].ToString() : "";
                            }
                        }
                    }
                }
            }
            catch { }
        }

        private void SetPanelsVisible(bool visible)
        {
            pnlBillForm.Visible = visible;
            pnlSummarySide.Visible = visible;
            pnlDetailedLedger.Visible = visible;
        }

        private void ShowMessage(string msg, bool success)
        {
            lblMessage.Text = msg;
            lblMessage.CssClass = "alert show " + (success ? "alert-success" : "alert-error");
            lblMessage.Style["display"] = "block";
            if (success)
                ClientScript.RegisterStartupScript(GetType(), "HideMsg",
                    "setTimeout(function(){ var m=document.getElementById('" + lblMessage.ClientID + "'); if(m) m.style.display='none'; },6000);", true);
        }

        private void PostToLedger(string resNo, string roomNo, string refNo, string desc, decimal debit, decimal credit, SqlConnection con, SqlTransaction trans, int? subDeptId)
        {
            string sql = "INSERT INTO GR_GuestLedger (ReservationNo, RoomNo, RefNo, Description, Debit, Credit, TransDate, SubDeptID) VALUES (@Res, @Room, @Ref, @Desc, @Dr, @Cr, GETDATE(), @SubID)";
            using (SqlCommand cmd = new SqlCommand(sql, con, trans))
            {
                cmd.Parameters.AddWithValue("@Res", resNo);
                cmd.Parameters.AddWithValue("@Room", roomNo);
                cmd.Parameters.AddWithValue("@Ref", refNo);
                cmd.Parameters.AddWithValue("@Desc", desc);
                cmd.Parameters.AddWithValue("@Dr", debit);
                cmd.Parameters.AddWithValue("@Cr", credit);
                cmd.Parameters.AddWithValue("@SubID", (object)subDeptId ?? DBNull.Value);
                cmd.ExecuteNonQuery();
            }
        }
    }
}












