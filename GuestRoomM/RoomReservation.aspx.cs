using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;  // â† ADD THIS for List<T>

namespace GuestRoomApp.GuestRoomM
{
    public partial class RoomReservation : System.Web.UI.Page
    {
    private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            if (!string.IsNullOrEmpty(Request.QueryString["dt"]))
            {
                txtFromDate.Text = Request.QueryString["dt"];
                DateTime fromDate;
                if (DateTime.TryParse(txtFromDate.Text, out fromDate))
                    txtToDate.Text = fromDate.AddDays(1).ToString("yyyy-MM-dd");
                else
                    txtToDate.Text = DateTime.Now.AddDays(1).ToString("yyyy-MM-dd");
            }
            else
            {
                txtFromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                txtToDate.Text = DateTime.Now.AddDays(1).ToString("yyyy-MM-dd");
            }

            txtFromDate.Attributes["min"] = DateTime.Now.ToString("yyyy-MM-dd");
            txtToDate.Attributes["min"] = DateTime.Now.ToString("yyyy-MM-dd");
            LoadClubs();
            BindGrid();
            ShowCurrentRoomStatus();
            ToggleCategoryFields();

            // Auto-check availability if coming from Calendar
            if (!string.IsNullOrEmpty(Request.QueryString["dt"]))
            {
                btnCheckAvail_Click(null, null);
            }
        }
    }

    protected void btnSearchMember_Click(object sender, EventArgs e)
    {
        string memberNo = txtMemberNo.Text.Trim();
        if (string.IsNullOrEmpty(memberNo)) { MemberNameLHR.Text = ""; hfMemberNo.Value = ""; return; }
        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("SELECT MemberName FROM Membership.dbo.MemberProfile WHERE MemberNo=@M AND IsActive=1", con);
                cmd.Parameters.AddWithValue("@M", memberNo);
                con.Open();
                object r = cmd.ExecuteScalar();
                if (r != null) { MemberNameLHR.Text = r.ToString(); hfMemberNo.Value = memberNo; }
                else { MemberNameLHR.Text = "Member not found!"; hfMemberNo.Value = ""; }
            }
        }
        catch (Exception ex) { MemberNameLHR.Text = "Error: " + ex.Message; }
    }

    private void ShowCurrentRoomStatus()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                // Pool = All physical rooms except those permanently out (Maintenance)
                SqlCommand cmdTotal = new SqlCommand(
                    "SELECT ISNULL(COUNT(*),0) FROM RoomDefinitionNew WHERE UPPER(LTRIM(RTRIM(Status))) != 'MAINTENANCE'", con);
                int total = Convert.ToInt32(cmdTotal.ExecuteScalar());
                if (total == 0) { cmdTotal = new SqlCommand("SELECT ISNULL(COUNT(*),0) FROM RoomDefinitionNew", con); total = Convert.ToInt32(cmdTotal.ExecuteScalar()); }

                // Define "today" for Pending/Confirmed filtering
                string today = DateTime.Now.ToString("yyyy-MM-dd");
                string dateCond = string.Format(" AND '{0}' >= FromDate AND '{0}' < ToDate", today);

                // 1. Pending & Confirmed are date-sensitive (today's arrivals/stays)
                int pending = ScalarInt("SELECT ISNULL(SUM(NoOfRooms),0) FROM RoomReservations WHERE UPPER(LTRIM(RTRIM(Status)))='PENDING'" + dateCond, con);
                int confirmed = ScalarInt("SELECT ISNULL(SUM(NoOfRooms),0) FROM RoomReservations WHERE UPPER(LTRIM(RTRIM(Status)))='CONFIRMED'" + dateCond, con);
                
                // 2. Occupied/Availed are counted from physical allocations that haven't checked out yet.
                // This correctly handles partial checkouts where some rooms are released but the reservation stays active.
                int occupied = ScalarInt("SELECT COUNT(*) FROM RoomAllocations WHERE CheckOutDate IS NULL", con);
                
                int cancelled = ScalarInt("SELECT ISNULL(SUM(NoOfRooms),0) FROM RoomReservations WHERE UPPER(LTRIM(RTRIM(Status)))='CANCELLED'" + dateCond, con);
                
                // 3. Physical status counts (Dirty rooms are also unavailable for today)
                int dirtyRooms = ScalarInt("SELECT COUNT(*) FROM RoomDefinitionNew WHERE UPPER(LTRIM(RTRIM(Status))) = 'DIRTY'", con);
                
                int totalBookedByRes = pending + confirmed + occupied;
                int totalUnavailable = totalBookedByRes + dirtyRooms;
                int available = Math.Max(0, total - totalUnavailable);

                lblRoomSummary.Text = string.Format(
                    " total: {0} |  booked: {1} (p:{2} c:{3} o:{4}) |  dirty: {5} |  available: {6} |  cancelled: {7}",
                    total, totalBookedByRes, pending, confirmed, occupied, dirtyRooms, available, cancelled);
            }
        }
        catch (Exception ex) { lblRoomSummary.Text = " " + ex.Message; }
    }

    private int ScalarInt(string sql, SqlConnection con)
    {
        try { return Convert.ToInt32(new SqlCommand(sql, con).ExecuteScalar()); } catch { return 0; }
    }

    private int GetAvailableRoomsCount(DateTime fromDate, DateTime toDate)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                string sql = @"
                    DECLARE @TotalSystemRooms INT;
                    -- Include all potential rooms except those permanently out (Maintenance)
                    SELECT @TotalSystemRooms = COUNT(*) FROM RoomDefinitionNew WHERE UPPER(LTRIM(RTRIM(Status))) != 'MAINTENANCE';

                    WITH DateRange AS (
                        SELECT @FromDate AS DateVal
                        UNION ALL
                        SELECT DATEADD(DAY, 1, DateVal)
                        FROM DateRange
                        WHERE DateVal < DATEADD(DAY, -1, @ToDate)
                    ),
                    DailyOccupancy AS (
                        SELECT 
                            ISNULL(MAX(BlockedRooms), 0) as MaxBooked
                        FROM (
                            SELECT 
                                d.DateVal,
                                (
                                    -- 1. Count active reservations for this specific date
                                    (SELECT ISNULL(SUM(NoOfRooms), 0) FROM RoomReservations rr
                                     WHERE d.DateVal >= rr.FromDate AND d.DateVal < rr.ToDate
                                     AND UPPER(LTRIM(RTRIM(rr.Status))) IN ('PENDING', 'CONFIRMED', 'AVAILED', 'OCCUPIED'))
                                    +
                                    -- 2. Subtract rooms marked 'Dirty' ONLY if the check date is Today
                                    (CASE WHEN CAST(d.DateVal AS DATE) = CAST(GETDATE() AS DATE) 
                                          THEN (SELECT COUNT(*) FROM RoomDefinitionNew WHERE UPPER(LTRIM(RTRIM(Status))) = 'DIRTY')
                                          ELSE 0 END)
                                ) AS BlockedRooms
                            FROM DateRange d
                        ) t
                    )
                    SELECT (@TotalSystemRooms - MaxBooked) FROM DailyOccupancy
                    OPTION (MAXRECURSION 366);";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@FromDate", fromDate.Date);
                    cmd.Parameters.AddWithValue("@ToDate", toDate.Date);
                    
                    // â”€â”€ EXTENSION FIX â”€â”€
                    // If we are extending an existing reservation, we exclude it from the 'Occupied' count
                    // so the guest can extend into their own room.
                    string currentResNo = txtReservationNo.Text.Trim();
                    if (!string.IsNullOrEmpty(currentResNo))
                    {
                        sql = sql.Replace("AND UPPER(LTRIM(RTRIM(rr.Status))) IN ('PENDING', 'CONFIRMED', 'AVAILED', 'OCCUPIED'))", 
                                          "AND UPPER(LTRIM(RTRIM(rr.Status))) IN ('PENDING', 'CONFIRMED', 'AVAILED', 'OCCUPIED') AND rr.ReservationNo != @ExRes)");
                        cmd.CommandText = sql;
                        cmd.Parameters.AddWithValue("@ExRes", currentResNo);
                    }

                    object result = cmd.ExecuteScalar();
                    return result != null ? Math.Max(0, Convert.ToInt32(result)) : 0;
                }
            }
        }
        catch (Exception ex) 
        { 
            System.Diagnostics.Debug.WriteLine("GetAvailableRoomsCount Error: " + ex.Message);
            return 0; 
        }
    }

        protected void btnCheckAvail_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtFromDate.Text) || string.IsNullOrEmpty(txtToDate.Text))
            { ShowMessage("Please select From Date and To Date first.", false); return; }
            DateTime from = DateTime.Parse(txtFromDate.Text);
            DateTime to = DateTime.Parse(txtToDate.Text);
            if (to < from) { ShowMessage("To Date cannot be before From Date.", false); return; }
            int available = GetAvailableRoomsCount(from, to);
            if (available > 0)
            {
                ShowMessage(string.Format(" {0} rooms available for the selected period  ", available), true);
                txtNoOfRooms.Enabled = true;
                txtNoOfRooms.Text = "1";
                ShowCurrentRoomStatus();
            }
            else
            {
                ShowMessage("âŒ No rooms available for the selected dates.", false);
                txtNoOfRooms.Enabled = false;
            }
        }

        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
        //  SAVE â€” 1 ResNo per room
        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // Validation
            if (string.IsNullOrWhiteSpace(txtGuestName.Text))
            {
                ShowMessage("Guest Name is required.", false);
                return;
            }

            if (string.IsNullOrEmpty(txtFromDate.Text) || string.IsNullOrEmpty(txtToDate.Text))
            {
                ShowMessage("Dates are required.", false);
                return;
            }

            DateTime fromDate = DateTime.Parse(txtFromDate.Text);
            DateTime toDate = DateTime.Parse(txtToDate.Text);

            if (toDate < fromDate)
            {
                ShowMessage("To Date must be after From Date.", false);
                return;
            }

            int noOfRooms = 1;
            int.TryParse(txtNoOfRooms.Text, out noOfRooms);

            // Check availability with overlapping prevention
            if (!IsRoomAvailableForDates(fromDate, toDate, noOfRooms))
            {
                ShowMessage("Selected rooms are not available for these dates. Please check availability calendar.", false);
                return;
            }

            try
            {
                string firstResNo = txtReservationNo.Text.Trim();
                string firstRecNo = txtReceiptNo.Text.Trim();

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    // â”€â”€ UPDATE vs INSERT LOGIC â”€â”€
                    if (!string.IsNullOrEmpty(firstResNo))
                    {
                        // UPDATE EXISTING RESERVATION (Extension)
                        string updateSql = @"
                            UPDATE RoomReservations SET 
                                ToDate = @ToDate,
                                GuestName = @GuestName,
                                Address = @Address,
                                MobileNo = @MobileNo,
                                NIC = @NIC,
                                PassportNo = @PassportNo,
                                PassportIssueDate = @PassportIssueDate,
                                PassportExpiryDate = @PassportExpiryDate,
                                Remarks = ISNULL(Remarks,'') + CHAR(13) + @ExtRemarks,
                                Status = @Status,
                                AdvancePayment = @AdvancePayment,
                                NoOfRooms = @NoOfRooms,
                                CardExpiryDate = @CardExpiryDate
                            WHERE ReservationNo = @ResNo";
                        
                        using (SqlCommand cmdUp = new SqlCommand(updateSql, con))
                        {
                            cmdUp.Parameters.AddWithValue("@ToDate", toDate);
                            cmdUp.Parameters.AddWithValue("@GuestName", txtGuestName.Text.Trim());
                            cmdUp.Parameters.AddWithValue("@Address", txtAddress.Text.Trim());
                            cmdUp.Parameters.AddWithValue("@MobileNo", txtMobile.Text.Trim());
                            cmdUp.Parameters.AddWithValue("@NIC", txtNIC.Text.Trim());
                            cmdUp.Parameters.AddWithValue("@PassportNo", txtPassport.Text.Trim());
                            cmdUp.Parameters.AddWithValue("@PassportIssueDate", string.IsNullOrEmpty(txtPassportIssue.Text) ? (object)DBNull.Value : DateTime.Parse(txtPassportIssue.Text));
                            cmdUp.Parameters.AddWithValue("@PassportExpiryDate", string.IsNullOrEmpty(txtPassportExpiry.Text) ? (object)DBNull.Value : DateTime.Parse(txtPassportExpiry.Text));
                            cmdUp.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);
                            cmdUp.Parameters.AddWithValue("@NoOfRooms", noOfRooms);
                            cmdUp.Parameters.AddWithValue("@ResNo", firstResNo);
                            
                            decimal advance = 0;
                            decimal.TryParse(txtPayment.Text, out advance);
                            cmdUp.Parameters.AddWithValue("@AdvancePayment", advance);
                            cmdUp.Parameters.AddWithValue("@CardExpiryDate", string.IsNullOrEmpty(txtExpiryDate.Text) ? (object)DBNull.Value : DateTime.Parse(txtExpiryDate.Text));
                            
                            cmdUp.Parameters.AddWithValue("@ExtRemarks", "[Update/Extension] " + txtRemarks.Text.Trim());
                            
                            cmdUp.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        // INSERT NEW RESERVATION
                        using (SqlTransaction trans = con.BeginTransaction())
                        {
                            try
                            {
                                using (SqlCommand cmd = new SqlCommand("sp_InsertRoomReservation", con, trans))

                                {
                                    cmd.CommandType = CommandType.StoredProcedure;
                                    string empId = Session["Emp_ID"] != null
       ? Session["Emp_ID"].ToString()
       : "";
                                    cmd.Parameters.AddWithValue("@FromDate", fromDate);
                                    cmd.Parameters.AddWithValue("@ToDate", toDate);

                                    string resType = "Guest";
                                    if (rbMember.Checked) resType = "Member";
                                    else if (rbAffiliated.Checked) resType = "Affiliated";
                                    cmd.Parameters.AddWithValue("@ReservationType", resType);

                                    string memberNo = string.IsNullOrEmpty(hfMemberNo.Value) ? txtMemberNo.Text.Trim() : hfMemberNo.Value;
                                    string guestOf = "";
                                    if (rbAffiliated.Checked)
                                        guestOf = txtClubMemberName.Text.Trim();
                                    else if (!string.IsNullOrEmpty(hfMemberNo.Value))
                                        guestOf = MemberNameLHR.Text.Trim();

                                    cmd.Parameters.AddWithValue("@MembershipNo", string.IsNullOrEmpty(memberNo) ? (object)DBNull.Value : memberNo);
                                    cmd.Parameters.AddWithValue("@GuestOf", string.IsNullOrEmpty(guestOf) ? (object)DBNull.Value : guestOf);
                                    cmd.Parameters.AddWithValue("@IntroductoryCardNo", string.IsNullOrEmpty(txtIntroCard.Text) ? (object)DBNull.Value : txtIntroCard.Text.Trim());
                                    cmd.Parameters.AddWithValue("@CardExpiryDate", string.IsNullOrEmpty(txtExpiryDate.Text) ? (object)DBNull.Value : DateTime.Parse(txtExpiryDate.Text));
                                    cmd.Parameters.AddWithValue("@GuestName", txtGuestName.Text.Trim());
                                    cmd.Parameters.AddWithValue("@ClubName", ddlClubName.SelectedValue);
                                    cmd.Parameters.AddWithValue("@Address", txtAddress.Text.Trim());
                                    cmd.Parameters.AddWithValue("@MobileNo", txtMobile.Text.Trim());
                                    cmd.Parameters.AddWithValue("@NIC", txtNIC.Text.Trim());
                                    cmd.Parameters.AddWithValue("@PassportNo", txtPassport.Text.Trim());
                                    cmd.Parameters.AddWithValue("@PassportIssueDate", string.IsNullOrEmpty(txtPassportIssue.Text) ? (object)DBNull.Value : DateTime.Parse(txtPassportIssue.Text));
                                    cmd.Parameters.AddWithValue("@PassportExpiryDate", string.IsNullOrEmpty(txtPassportExpiry.Text) ? (object)DBNull.Value : DateTime.Parse(txtPassportExpiry.Text));
                                    cmd.Parameters.AddWithValue("@NoOfRooms", noOfRooms);
                                    cmd.Parameters.AddWithValue("@ArrivalTime", string.IsNullOrEmpty(txtArrivalTime.Text) ? (object)DBNull.Value : TimeSpan.Parse(txtArrivalTime.Text));

                                    // New Guest Counts
                                    cmd.Parameters.AddWithValue("@Men", int.Parse(string.IsNullOrEmpty(txtMen.Text) ? "0" : txtMen.Text));
                                    cmd.Parameters.AddWithValue("@Women", int.Parse(string.IsNullOrEmpty(txtWomen.Text) ? "0" : txtWomen.Text));
                                    cmd.Parameters.AddWithValue("@Child", int.Parse(string.IsNullOrEmpty(txtChild.Text) ? "0" : txtChild.Text));
                                    cmd.Parameters.AddWithValue("@CheckInTime", DateTime.Now.TimeOfDay); // Required by SP
                                    cmd.Parameters.AddWithValue("@EmpID",
        string.IsNullOrEmpty(empId)
        ? (object)DBNull.Value
        : empId);
                                    // Set status: If payment is made, auto-confirm. Otherwise use dropdown selection.
                                    decimal advance = 0;
                                    decimal.TryParse(txtPayment.Text, out advance);

                                    string status = ddlStatus.SelectedValue;
                                    if (advance > 0)
                                    {
                                        status = "Confirmed";
                                    }
                                    cmd.Parameters.AddWithValue("@Status", status);

                                    cmd.Parameters.AddWithValue("@AdvancePayment", decimal.Parse(string.IsNullOrEmpty(txtPayment.Text) ? "0" : txtPayment.Text));
                                    cmd.Parameters.AddWithValue("@Remarks", txtRemarks.Text.Trim());

                                    SqlParameter outRes = new SqlParameter("@NewReservationNo", SqlDbType.VarChar, 20) { Direction = ParameterDirection.Output };
                                    SqlParameter outRec = new SqlParameter("@NewReceiptNo", SqlDbType.VarChar, 50) { Direction = ParameterDirection.Output };
                                    cmd.Parameters.Add(outRes);
                                    cmd.Parameters.Add(outRec);
                                    cmd.ExecuteNonQuery();

                                    firstResNo = outRes.Value.ToString();
                                    firstRecNo = outRec.Value.ToString();

                                    // â”€â”€ LEDGER POSTING â”€â”€
                                    if (advance > 0)
                                    {
                                        PostToLedger(firstResNo, "0", firstRecNo, "Initial Advance Payment (Receipt: " + firstRecNo + ")", 0, advance, con, trans, null);
                                    }
                                }

                                trans.Commit();
                            }
                            catch
                            {
                                trans.Rollback();
                                throw;
                            }
                        }
                    }
                }

                lblResNo.Text = firstResNo;
                txtReservationNo.Text = firstResNo;
                txtReceiptNo.Text = firstRecNo;
                txtReceiptDisplay.Text = firstRecNo;
                TextBox1.Text = firstRecNo;

                BindGrid();
                ShowCurrentRoomStatus();
                ClearForm();
                ShowMessage(string.Format("âœ… Reservation saved! Res No: {0} | Receipt: {1}", firstResNo, firstRecNo), true);
            }
            catch (Exception ex)
            {
                ShowMessage("âŒ Error: " + ex.Message, false);
            }
        }

        private bool IsRoomAvailableForDates(DateTime fromDate, DateTime toDate, int requestedRooms)
        {
            try
            {
                // Align with GetAvailableRoomsCount logic
                int available = GetAvailableRoomsCount(fromDate, toDate);
                return available >= requestedRooms;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Availability Check Error: " + ex.Message);
                return false;
            }
        }

        protected void btnSearchHistory_Click(object sender, EventArgs e)
        {
            BindGrid();
        }

        protected void btnClearHistory_Click(object sender, EventArgs e)
        {
            txtSearchMember.Text = "";
            BindGrid();
        }
        private void ClearForm()
    {
        txtMemberNo.Text = ""; txtGuestName.Text = ""; MemberNameLHR.Text = "";
        txtIntroCard.Text = ""; txtAddress.Text = ""; txtMobile.Text = "";
        txtNIC.Text = ""; txtPhone.Text = ""; txtPassport.Text = "";
        txtPassportIssue.Text = ""; txtPassportExpiry.Text = "";
        txtArrivalTime.Text = ""; txtRemarks.Text = ""; txtPayment.Text = "";
        txtExpiryDate.Text = ""; txtNoOfRooms.Text = "1";
        txtMen.Text = "1"; txtWomen.Text = "0"; txtChild.Text = "0";
        hfMemberNo.Value = ""; hfSelectedRooms.Value = "";
    }

    protected void btnAddNew_Click(object sender, EventArgs e)
    {
        ClearForm();
        txtFromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        txtToDate.Text = DateTime.Now.AddDays(1).ToString("yyyy-MM-dd");
        ddlClubName.SelectedIndex = 0;
        ddlStatus.SelectedValue = "Pending";
        rbGuest.Checked = true;
        txtReservationNo.Text = ""; txtReceiptNo.Text = ""; txtReceiptDisplay.Text = "";
        lblResNo.Text = "RES-XXXXXX";
        lblMessage.Text = ""; lblMessage.CssClass = "alert";
        ToggleCategoryFields();
    }

    private void LoadClubs()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                // Fetch active clubs from Membership.dbo.AffiliatedClubs
                // Schema uses 'Id' as PK and 'Status' for active state
                string sql = "SELECT Id, ClubName FROM Membership.dbo.AffiliatedClubs WHERE Status = 1 ORDER BY ClubName";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    con.Open(); da.Fill(dt);
                    ddlClubName.Items.Clear();
                    ddlClubName.Items.Add(new ListItem("Select Club ", ""));
                    foreach (DataRow row in dt.Rows)
                    {
                        // Use Id as DataValueField to match ClubId in IncomingClubMembers
                        ddlClubName.Items.Add(new ListItem(row["ClubName"].ToString(), row["Id"].ToString()));
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading clubs: " + ex.Message, false);
            ddlClubName.Items.Clear();
            ddlClubName.Items.Add(new ListItem("â”€â”€ Select Club â”€â”€", ""));
            // Fallback list of major Gymkhana and affiliated clubs in Pakistan
            string[] clubs = { 
                "Lahore Gymkhana", "Karachi Gymkhana", "Islamabad Club", "Rawalpindi Gymkhana", 
                "Gujranwala Gymkhana", "Chenab Club (Faisalabad)", "Multan Gymkhana", "Quetta Gymkhana", 
                "Peshawar Gymkhana", "Bahawalpur Gymkhana", "Sialkot Gymkhana", "Sargodha Gymkhana", 
                "Hyderabad Gymkhana", "Jhang Gymkhana", "Abbottabad Gymkhana", "Sahiwal Gymkhana", 
                "Sukkur Gymkhana", "Larkana Gymkhana", "Mardan Gymkhana", "Jhelum Gymkhana", 
                "Okara Gymkhana", "Vehari Gymkhana", "Nawabshah Gymkhana", "Mirpurkhas Gymkhana"
            };
            foreach (var c in clubs) ddlClubName.Items.Add(new ListItem(c, c));
        }
    }

        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
        //  BIND GRID â€” Grouped by GroupResNo
        // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
        private void BindGrid()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string searchFilter = "";
                    string searchTerm = txtSearchMember.Text.Trim();
                    if (!string.IsNullOrEmpty(searchTerm))
                    {
                        searchFilter = " WHERE rr.MembershipNo = @SearchTerm OR rr.GuestOf LIKE '%' + @SearchTerm + '%' OR rr.GuestName LIKE '%' + @SearchTerm + '%' OR rr.MobileNo LIKE '%' + @SearchTerm + '%' ";
                    }

                    string sql = @"
                    SELECT TOP 100
                        ISNULL(rr.GroupResNo, rr.ReservationNo) AS GroupResNo,
                        MIN(rr.ReceiptNo)      AS ReceiptNo,
                        MIN(rr.ResDate)        AS ResDate,
                        rr.GuestName, rr.GuestOf,
                        MIN(rr.IntroductoryCardNo) AS IntroCardNo,
                        MIN(ISNULL(ac.ClubName, rr.ClubName)) AS Club,
                        MIN(COALESCE(inc.MemberName, mp.MemberName, rr.GuestOf)) AS ClubMemberName,
                        rr.FromDate, rr.ToDate,
                        COUNT(*)            AS NoOfRooms,
                        rr.[Status],
                        SUM(rr.AdvancePayment) AS AdvancePayment
                    FROM RoomReservations rr
                    LEFT JOIN Membership.dbo.AffiliatedClubs ac ON rr.ClubName = CAST(ac.Id AS VARCHAR(50))
                    LEFT JOIN Membership.dbo.IncomingClubMembers inc ON rr.IntroductoryCardNo = inc.IntroductoryNo
                    LEFT JOIN Membership.dbo.MemberProfile mp ON rr.MembershipNo = mp.MemberNo
                    " + searchFilter + @"
                    GROUP BY ISNULL(rr.GroupResNo,rr.ReservationNo),
                             rr.GuestName, rr.GuestOf, rr.FromDate, rr.ToDate, rr.[Status]
                    ORDER BY MIN(rr.ResDate) DESC";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        if (!string.IsNullOrEmpty(searchTerm))
                        {
                            cmd.Parameters.AddWithValue("@SearchTerm", searchTerm);
                        }

                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        // â”€â”€ DYNAMIC STATUS UPDATE â”€â”€
                        con.Open();
                        foreach (DataRow row in dt.Rows)
                        {
                            string resNo = row["GroupResNo"].ToString();
                            using (SqlCommand cmdStat = new SqlCommand(@"
                        SELECT 
                            (SELECT COUNT(*) FROM RoomAllocations WHERE ReservationNo = @R) as TotalAlloc,
                            (SELECT COUNT(*) FROM RoomAllocations WHERE ReservationNo = @R AND CheckOutDate IS NULL) as OccupiedAlloc", con))
                            {
                                cmdStat.Parameters.AddWithValue("@R", resNo);
                                using (SqlDataReader drStat = cmdStat.ExecuteReader())
                                {
                                    if (drStat.Read())
                                    {
                                        int totalAlloc = drStat["TotalAlloc"] != DBNull.Value ? Convert.ToInt32(drStat["TotalAlloc"]) : 0;
                                        int occupiedAlloc = drStat["OccupiedAlloc"] != DBNull.Value ? Convert.ToInt32(drStat["OccupiedAlloc"]) : 0;

                                        if (totalAlloc > 0)
                                        {
                                            if (occupiedAlloc > 0) row["Status"] = "OCCUPIED";
                                            else row["Status"] = "COMPLETED";
                                        }
                                    }
                                }
                            }
                        }
                        con.Close();

                        gvStatus.DataSource = dt;
                        gvStatus.DataBind();
                    }
                }
            }
            catch { }
        }

        protected void gvStatus_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "EditRes")
        {
            string resNo = e.CommandArgument.ToString();
            LoadReservationForEdit(resNo);
        }
    }

    private void LoadReservationForEdit(string resNo)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string sql = "SELECT TOP 1 * FROM RoomReservations WHERE ReservationNo = @Res OR GroupResNo = @Res ORDER BY ResDate DESC";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@Res", resNo);
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            txtReservationNo.Text = dr["ReservationNo"].ToString();
                            lblResNo.Text = dr["ReservationNo"].ToString();
                            txtReceiptNo.Text = dr["ReceiptNo"].ToString();
                            TextBox1.Text = dr["ReceiptNo"].ToString();
                            
                            txtGuestName.Text = dr["GuestName"].ToString();
                            txtFromDate.Text = Convert.ToDateTime(dr["FromDate"]).ToString("yyyy-MM-dd");
                            txtToDate.Text = Convert.ToDateTime(dr["ToDate"]).ToString("yyyy-MM-dd");
                            txtNoOfRooms.Text = dr["NoOfRooms"].ToString();
                            txtAddress.Text = dr["Address"].ToString();
                            txtMobile.Text = dr["MobileNo"].ToString();
                            txtNIC.Text = dr["NIC"].ToString();
                            txtPassport.Text = dr["PassportNo"].ToString();
                            if (dr["PassportIssueDate"] != DBNull.Value)
                                txtPassportIssue.Text = Convert.ToDateTime(dr["PassportIssueDate"]).ToString("yyyy-MM-dd");
                            if (dr["PassportExpiryDate"] != DBNull.Value)
                                txtPassportExpiry.Text = Convert.ToDateTime(dr["PassportExpiryDate"]).ToString("yyyy-MM-dd");
                            txtPayment.Text = Convert.ToDecimal(dr["AdvancePayment"]).ToString("0");
                            txtRemarks.Text = dr["Remarks"].ToString();
                            ddlStatus.SelectedValue = dr["Status"].ToString();
                            if (dr["CardExpiryDate"] != DBNull.Value)
                                txtExpiryDate.Text = Convert.ToDateTime(dr["CardExpiryDate"]).ToString("yyyy-MM-dd");
                            
                            if (dr["ReservationType"].ToString() == "Member") rbMember.Checked = true;
                            else if (dr["ReservationType"].ToString() == "Affiliated") rbAffiliated.Checked = true;
                            else rbGuest.Checked = true;
                            
                            ToggleCategoryFields();
                            ShowMessage("Reservation " + resNo + " loaded for edit. Change To Date to extend stay.", true);
                        }
                    }
                }
            }
        }
        catch (Exception ex) { ShowMessage("Error loading: " + ex.Message, false); }
    }

    protected string GetStatusStyle(string status)
    {
        switch (status.Trim().ToUpper())
        {
            case "CONFIRMED": return "background: #e8f5e9; color: #2e7d32; border: 1px solid #a5d6a7;";
            case "OCCUPIED":
            case "AVAILED": return "background: #e3f2fd; color: #1565C0; border: 1px solid #90caf9;";
            case "CANCELLED": return "background: #fce4ec; color: #c62828; border: 1px solid #f8bbd0;";
            case "COMPLETED": return "background: #eceff1; color: #607d8b; border: 1px solid #cfd8dc;";
            default: return "background: #fff3e0; color: #e65100; border: 1px solid #ffcc80;";
        }
    }

    private void ShowMessage(string msg, bool success)
    {
        lblMessage.Text = msg;
        lblMessage.CssClass = "alert show " + (success ? "alert-success" : "alert-error");
        if (success)
            ClientScript.RegisterStartupScript(GetType(), "HideMsg",
                "setTimeout(function(){var m=document.getElementById('" + lblMessage.ClientID + "');if(m)m.style.display='none';},7000);", true);
    }

    protected void rptRooms_ItemCommand(object source, RepeaterCommandEventArgs e) { }

    protected void btnVerifyIntroCard_Click(object sender, EventArgs e)
    {
        string introNo = txtIntroCard.Text.Trim();
        if (string.IsNullOrEmpty(introNo)) return;
        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                // Query matching the schema provided: [IntroductoryNo], [MemberName], [ClubId], [DateTo], [Mobile], etc.
                string sql = @"SELECT MemberName, ClubId, DateTo, Mobile, Address1, Address2, NTN_CNIC 
                               FROM Membership.dbo.IncomingClubMembers 
                               WHERE IntroductoryNo = @C AND ISNULL(IsActive, 1) = 1";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@C", introNo);
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            txtClubMemberName.Text = dr["MemberName"].ToString();
                            txtGuestName.Text = dr["MemberName"].ToString();
                            
                            // Select Club by Id
                            string clubId = dr["ClubId"].ToString();
                            if (ddlClubName.Items.FindByValue(clubId) != null)
                                ddlClubName.SelectedValue = clubId;
                            
                            // Populate Expiry Date from DateTo
                            if (dr["DateTo"] != DBNull.Value)
                                txtExpiryDate.Text = Convert.ToDateTime(dr["DateTo"]).ToString("yyyy-MM-dd");

                            // Populate additional fields for convenience
                            if (dr["Mobile"] != DBNull.Value) txtMobile.Text = dr["Mobile"].ToString();
                            if (dr["NTN_CNIC"] != DBNull.Value) txtNIC.Text = dr["NTN_CNIC"].ToString();
                            
                            string addr = dr["Address1"].ToString();
                            if (dr["Address2"] != DBNull.Value && !string.IsNullOrEmpty(dr["Address2"].ToString()))
                                addr += ", " + dr["Address2"].ToString();
                            txtAddress.Text = addr;
                            
                            ShowMessage("âœ… Intro Card verified. Records loaded for " + dr["MemberName"].ToString(), true);
                        }
                        else
                        {
                            ShowMessage("âŒ Intro Card No. '" + introNo + "' not found or inactive.", false);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("âŒ Database Error: " + ex.Message, false);
        }
    }

    protected void rbGuest_CheckedChanged(object sender, EventArgs e)
        {
            ToggleCategoryFields();
        }
    protected void rbMember_CheckedChanged(object sender, EventArgs e)
        {
            ToggleCategoryFields();
        }
    protected void rbAffiliated_CheckedChanged(object sender, EventArgs e)
        {
            ToggleCategoryFields();
        }

        private void ToggleCategoryFields()
        {
            bool isAffiliated = rbAffiliated.Checked;

            // Show / Hide Sections
            divAffiliatedFields.Visible = isAffiliated;
            divMemberFields.Visible = !isAffiliated;
            divGuestFields.Visible = true;

            if (!isAffiliated)
            {
                // Guest / Member
                ddlClubName.Enabled = false;
                divClubMemberName.Visible = false;

                // HARD CODED Lahore Gymkhana
                ddlClubName.Items.Clear();
                ddlClubName.Items.Add(new ListItem("Lahore Gymkhana", "Lahore Gymkhana"));
                ddlClubName.SelectedIndex = 0;
            }
            else
            {
                // Affiliated
                ddlClubName.Enabled = true;
                divClubMemberName.Visible = true;

                // Reload clubs from DB
                LoadClubs();

                ddlClubName.SelectedIndex = 0;
            }
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






