using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Serialization;
using System.Collections.Generic;
namespace GuestRoomApp.GuestRoomM
{
    public partial class RoomCheckIn : System.Web.UI.Page
    {
    private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;
    private int bookedRoomsCount = 0;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Show logged-in employee in textbox
            txtCheckInBy.Text = Session["Emp_ID"] != null
                ? Session["Emp_ID"].ToString()
                : "";

            // Optional: make readonly
            txtCheckInBy.ReadOnly = true;
            EnsureRoomAllocationsTable();
            LoadAvailableRooms();
        }
        if (ViewState["BookedRoomsCount"] != null)
            bookedRoomsCount = (int)ViewState["BookedRoomsCount"];
    }

    private void EnsureRoomAllocationsTable()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                // Also add new columns to RoomAllocations if they don't exist yet
                string sql = @"
                IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='RoomAllocations' AND xtype='U')
                BEGIN
                    CREATE TABLE RoomAllocations (
                        AllocationID      INT IDENTITY(1,1) PRIMARY KEY,
                        ReservationNo     VARCHAR(20)  NOT NULL,
                        RoomNo            VARCHAR(20)  NOT NULL,
                        AllocatedDate     DATETIME     DEFAULT GETDATE(),
                        CheckOutDate      DATETIME     NULL,
                        -- Fields from physical Check-In Card
                        GuestAddress      NVARCHAR(300) NULL,
                        CNIC_Passport     VARCHAR(50)   NULL,
                        Country           NVARCHAR(100) NULL,
                        DriverName        NVARCHAR(200) NULL,
                        DriverStay        BIT           NULL,   -- 1=Yes, 0=No
                        VehicleNo         VARCHAR(50)   NULL,
                        Remarks           NVARCHAR(500) NULL,
                        CheckInBy         NVARCHAR(100) NULL,
                        NoOfGuests        INT           NULL,
                        Men               INT           NULL,
                        Women             INT           NULL,
                        Child             INT           NULL
                    )
                END
                ELSE
                BEGIN
                    -- Add columns if upgrading existing table
                    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('RoomAllocations') AND name='GuestAddress')
                        ALTER TABLE RoomAllocations ADD GuestAddress NVARCHAR(300) NULL;
                    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('RoomAllocations') AND name='CNIC_Passport')
                        ALTER TABLE RoomAllocations ADD CNIC_Passport VARCHAR(50) NULL;
                    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('RoomAllocations') AND name='Country')
                        ALTER TABLE RoomAllocations ADD Country NVARCHAR(100) NULL;
                    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('RoomAllocations') AND name='DriverName')
                        ALTER TABLE RoomAllocations ADD DriverName NVARCHAR(200) NULL;
                    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('RoomAllocations') AND name='DriverStay')
                        ALTER TABLE RoomAllocations ADD DriverStay BIT NULL;
                    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('RoomAllocations') AND name='VehicleNo')
                        ALTER TABLE RoomAllocations ADD VehicleNo VARCHAR(50) NULL;
                    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('RoomAllocations') AND name='Remarks')
                        ALTER TABLE RoomAllocations ADD Remarks NVARCHAR(500) NULL;
                    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('RoomAllocations') AND name='CheckInBy')
                        ALTER TABLE RoomAllocations ADD CheckInBy NVARCHAR(100) NULL;
                    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('RoomAllocations') AND name='NoOfGuests')
                        ALTER TABLE RoomAllocations ADD NoOfGuests INT NULL;
                    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('RoomAllocations') AND name='Men')
                        ALTER TABLE RoomAllocations ADD Men INT NULL;
                    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('RoomAllocations') AND name='Women')
                        ALTER TABLE RoomAllocations ADD Women INT NULL;
                    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('RoomAllocations') AND name = 'Child')
                        ALTER TABLE RoomAllocations ADD Child INT NULL;
                    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('RoomAllocations') AND name = 'LastChargedDate')
                        ALTER TABLE RoomAllocations ADD LastChargedDate DATE NULL;
                    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('RoomAllocations') AND name = 'ApplyFacilityCharges')
                        ALTER TABLE RoomAllocations ADD ApplyFacilityCharges BIT NULL DEFAULT 0;
                END";
                SqlCommand cmd = new SqlCommand(sql, con);
                con.Open();
                cmd.ExecuteNonQuery();

                if (!isColumnExists("RFIDCardNo"))
                    addColumn("RFIDCardNo", "NVARCHAR(100) NULL");
                if (!isColumnExists("RFIDDeactive"))
                    addColumn("RFIDDeactive", "NVARCHAR(50) NULL");
                if (!isColumnExists("StayFactor"))
                    addColumn("StayFactor", "DECIMAL(3,2) NULL DEFAULT 1.0");
            }
        }
        catch { }
    }

    private bool isColumnExists(string columnName)
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            string sql = "SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('RoomAllocations') AND name = @Col";
            SqlCommand cmd = new SqlCommand(sql, con);
            cmd.Parameters.AddWithValue("@Col", columnName);
            con.Open();
            return cmd.ExecuteScalar() != null;
        }
    }

    private void addColumn(string name, string type)
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            try {
                string sql = "ALTER TABLE RoomAllocations ADD " + name + " " + type;
                SqlCommand cmd = new SqlCommand(sql, con);
                con.Open();
                cmd.ExecuteNonQuery();
            } catch { }
        }
    }

    private void LoadAvailableRooms()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT 
                        r.RoomNo,
                        r.RoomType,
                        r.FloorNo,
                        CASE 
                            WHEN a.RoomNo IS NOT NULL THEN 'Occupied'
                            WHEN r.Status = 'Available' THEN 'Available'
                            ELSE r.Status
                        END AS Status
                    FROM RoomDefinitionNew r
                    LEFT JOIN (
                        SELECT DISTINCT RoomNo 
                        FROM RoomAllocations 
                        WHERE CheckOutDate IS NULL
                    ) a ON r.RoomNo = a.RoomNo
                    WHERE r.Status != 'Maintenance'
                    ORDER BY 
                        CASE WHEN ISNUMERIC(SUBSTRING(r.RoomNo,4,LEN(r.RoomNo)))=1 
                             THEN CAST(SUBSTRING(r.RoomNo,4,LEN(r.RoomNo)) AS INT) 
                             ELSE 999 END";

                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                rptRooms.DataSource = dt;
                rptRooms.DataBind();
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading rooms: " + ex.Message, false);
        }
    }

    private void LoadAllocatedRooms(string reservationNo)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT RoomNo, CheckOutDate, RFIDDeactive 
                    FROM RoomAllocations 
                    WHERE ReservationNo = @ResNo 
                    ORDER BY RoomNo";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@ResNo", reservationNo);
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                DataTable dt = new DataTable();
                dt.Load(dr);
                rptAllocatedRooms.DataSource = dt;
                rptAllocatedRooms.DataBind();
            }
        }
        catch { }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        string search = txtSearch.Text.Trim();
        if (string.IsNullOrEmpty(search))
        {
            ShowMessage("Please enter a Reservation No.", false);
            return;
        }
        SearchReservation(search);
    }

    private void SearchReservation(string search)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT 
                        rr.ReservationNo,
                        MIN(rr.ReceiptNo)            AS ReceiptNo,
                        MIN(rr.GuestName)            AS GuestName,
                        MIN(rr.GuestOf)              AS GuestOf,
                        MIN(rr.FromDate)             AS FromDate,
                        MIN(rr.ToDate)               AS ToDate,
                        COUNT(*)                     AS NoOfRooms,
                        MIN(rr.Status)               AS Status,
                        MIN(rr.ReservationType)      AS ReservationType,
                        MIN(ISNULL(ac.ClubName, rr.ClubName)) AS ClubName,
                        MIN(rr.IntroductoryCardNo)   AS IntroductoryCardNo,
                        MIN(rr.CardExpiryDate)       AS CardExpiryDate,
                        MIN(rr.MembershipNo)         AS MembershipNo,
                        MAX(rr.Men)                  AS MenCount,
                        MAX(rr.Women)                AS WomenCount,
                        MAX(rr.Child)                AS ChildCount,
                        SUM(rr.AdvancePayment)       AS AdvancePayment,
                        SUM(CASE WHEN rr.Status = 'Confirmed' OR rr.Status = 'Pending' THEN 1 ELSE 0 END) AS RemainingRooms
                    FROM RoomReservations rr
                    LEFT JOIN Membership.dbo.AffiliatedClubs ac ON rr.ClubName = CAST(ac.Id AS VARCHAR(50))
                    WHERE rr.ReservationNo = @Search
                    GROUP BY rr.ReservationNo";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Search", search);
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            string resNo = dr["ReservationNo"].ToString();
                            string status = dr["Status"].ToString();
                            string reservationType = dr["ReservationType"].ToString();
                            int remainingRooms = dr["RemainingRooms"] != DBNull.Value ? Convert.ToInt32(dr["RemainingRooms"]) : 0;
                            bookedRoomsCount = Convert.ToInt32(dr["NoOfRooms"]);
                            ViewState["BookedRoomsCount"] = bookedRoomsCount;
                            ViewState["RemainingRooms"] = remainingRooms;
                            ViewState["CurrentReservationNo"] = resNo;

                            // Populate basic labels
                            lblReservationNo.Text = resNo;
                            lblReceiptNo.Text = dr["ReceiptNo"].ToString();
                            lblGuestName.Text = dr["GuestName"].ToString();
                            lblFromDate.Text = Convert.ToDateTime(dr["FromDate"]).ToString("dd-MMM-yyyy");
                            lblToDate.Text = Convert.ToDateTime(dr["ToDate"]).ToString("dd-MMM-yyyy");
                            lblNoOfRooms.Text = bookedRoomsCount.ToString();
                            lblRequiredCount.Text = remainingRooms.ToString();
                            lblRequiredCount2.Text = remainingRooms.ToString();
                            lblStatus.Text = status.ToLower();
                            lblCategory.Text = reservationType;
                            lblAdvancePaid.Text = dr["AdvancePayment"] != DBNull.Value ? Convert.ToDecimal(dr["AdvancePayment"]).ToString("N0") : "0";

                            // Pre-fill check-in card fields from reservation data
                            int men = dr["MenCount"] != DBNull.Value ? Convert.ToInt32(dr["MenCount"]) : 0;
                            int women = dr["WomenCount"] != DBNull.Value ? Convert.ToInt32(dr["WomenCount"]) : 0;
                            int child = dr["ChildCount"] != DBNull.Value ? Convert.ToInt32(dr["ChildCount"]) : 0;

                            if (txtMen != null) txtMen.Text = men.ToString();
                            if (txtWomen != null) txtWomen.Text = women.ToString();
                            if (txtChild != null) txtChild.Text = child.ToString();
                            if (txtNoOfGuests != null) txtNoOfGuests.Text = (men + women + child).ToString();
                            if (txtGuestAddress != null) txtGuestAddress.Text = "";
                            if (txtCNIC != null) txtCNIC.Text = "";
                            if (txtCountry != null) txtCountry.Text = "Pakistan";
                            if (txtDriverName != null) txtDriverName.Text = "";
                            if (txtVehicleNo != null) txtVehicleNo.Text = "";
                            if (txtRemarks != null) txtRemarks.Text = "";
                            if (rbDriverStayYes != null) rbDriverStayYes.Checked = false;
                            if (rbDriverStayNo != null) rbDriverStayNo.Checked = true;

                            // Populate card labels directly from C# too
                            if (lblGuestOfCard != null) lblGuestOfCard.Text = dr["GuestOf"] != DBNull.Value ? dr["GuestOf"].ToString() : "";
                            if (lblMemberNoCard != null) lblMemberNoCard.Text = dr["MembershipNo"] != DBNull.Value ? dr["MembershipNo"].ToString() : "";
                            if (lblArrivalDateCard != null) lblArrivalDateCard.Text = Convert.ToDateTime(dr["FromDate"]).ToString("dd-MMM-yyyy");
                                if (txtDepartureDateCard != null && dr["ToDate"] != DBNull.Value)
                                {
                                    txtDepartureDateCard.Text =
                                        Convert.ToDateTime(dr["ToDate"]).ToString("yyyy-MM-dd");
                                }
                                if (lblBillNoCard != null) lblBillNoCard.Text = dr["ReceiptNo"].ToString();
                            if (lblAffiliatedClubCard != null) lblAffiliatedClubCard.Text = dr["ClubName"].ToString();

                            // Visibility logic for Check-In Card internal fields
                            if (divGuestOfCard != null) divGuestOfCard.Visible = (reservationType == "Member" || reservationType == "Guest");
                            if (divMemberNoCard != null) divMemberNoCard.Visible = (reservationType == "Member");
                            if (divAffiliatedClubCard != null) divAffiliatedClubCard.Visible = (reservationType == "Affiliated");

                            // Hide all panels first
                            pnlMemberDetails.Visible = false;
                            pnlAffiliatedDetails.Visible = false;
                            pnlAllocatedRooms.Visible = false;
                            pnlRoomSelection.Visible = true;
                            pnlCheckInCard.Visible = true;

                            if (remainingRooms == 0)
                            {
                                ShowMessage(" All rooms for this booking are already occupied!", false);
                                pnlRoomSelection.Visible = false;
                                pnlCheckInCard.Visible = false;
                                pnlAllocatedRooms.Visible = true;
                                LoadAllocatedRooms(resNo);
                                pnlReservation.Visible = true;
                                return;
                            }

                            // Category-specific panels
                            if (reservationType == "Member")
                            {
                                pnlMemberDetails.Visible = true;
                                lblGuestOf.Text = dr["GuestOf"].ToString();
                                lblMemberNo.Text = dr["MembershipNo"].ToString();

                                string memberNo = dr["MembershipNo"].ToString();
                                if (!string.IsNullOrEmpty(memberNo))
                                {
                                    try
                                    {
                                        using (SqlConnection memCon = new SqlConnection(ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString))
                                        {
                                            SqlCommand memCmd = new SqlCommand(
                                                "SELECT MemberName FROM MemberProfile WHERE MemberNo = @M", memCon);
                                            memCmd.Parameters.AddWithValue("@M", memberNo);
                                            memCon.Open();
                                            object memName = memCmd.ExecuteScalar();
                                            lblMemberName.Text = memName != null ? memName.ToString() : "N/A";
                                        }
                                    }
                                    catch { lblMemberName.Text = "Member name not found"; }
                                }
                                else { lblMemberName.Text = "N/A"; }
                            }
                            else if (reservationType == "Affiliated")
                            {
                                pnlAffiliatedDetails.Visible = true;
                                lblClubName.Text = dr["ClubName"].ToString();
                                lblAffiliatedClubCard.Text = dr["ClubName"].ToString();
                                lblIntroCard.Text = dr["IntroductoryCardNo"].ToString();
                                lblExpiryDate.Text = dr["CardExpiryDate"] != DBNull.Value ?
                                    Convert.ToDateTime(dr["CardExpiryDate"]).ToString("dd-MMM-yyyy") : "N/A";
                            }

                            // Status badge CSS
                            switch (status.ToUpper())
                            {
                                case "CONFIRMED": lblStatus.CssClass = "status-badge status-confirmed"; break;
                                case "PENDING": lblStatus.CssClass = "status-badge status-pending"; break;
                                case "OCCUPIED":
                                case "AVAILED": lblStatus.CssClass = "status-badge status-availed"; break;
                                case "CANCELLED": lblStatus.CssClass = "status-badge status-cancelled"; break;
                                default: lblStatus.CssClass = "status-badge status-pending"; break;
                            }

                            if (status.ToUpper() != "CONFIRMED")
                            {
                                ShowMessage("?? Booking must be 'confirmed' before check-in. Current status: " + status.ToLower(), false);
                                pnlReservation.Visible = false;
                                return;
                            }

                            pnlReservation.Visible = true;
                            btnConfirmCheckIn.Enabled = true;
                            LoadAvailableRooms();
                        }
                        else
                        {
                            ShowMessage("? No booking found with number: " + search, false);
                            pnlReservation.Visible = false;
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void btnConfirmCheckIn_Click(object sender, EventArgs e)
    {
        string selectedRooms = hfSelectedRooms.Value;
        if (string.IsNullOrEmpty(selectedRooms))
        {
            ShowMessage("Please select rooms to allocate.", false);
            return;
        }

        string[] rooms = selectedRooms.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
        string currentReservationNo = ViewState["CurrentReservationNo"] as string ?? "";
        bookedRoomsCount = ViewState["BookedRoomsCount"] != null ? (int)ViewState["BookedRoomsCount"] : 0;

        if (string.IsNullOrEmpty(currentReservationNo))
        {
            ShowMessage("Session expired. Please search the booking again.", false);
            return;
        }

        int remainingRooms = ViewState["RemainingRooms"] != null ? (int)ViewState["RemainingRooms"] : 0;
        if (rooms.Length == 0)
        {
            ShowMessage("Please select at least one room to allocate.", false);
            return;
        }
        if (rooms.Length > remainingRooms)
        {
            ShowMessage(string.Format("You can select AT MOST {0} room(s). Currently selected: {1}", remainingRooms, rooms.Length), false);
            return;
        }

        // Collect check-in card values
        string guestAddress = txtGuestAddress.Text.Trim();
        string cnic = txtCNIC.Text.Trim();
        string country = txtCountry.Text.Trim();
        string driverName = txtDriverName.Text.Trim();
        bool driverStay = rbDriverStayYes.Checked;
        string vehicleNo = txtVehicleNo.Text.Trim();
        string remarks = txtRemarks.Text.Trim();
        string checkInBy = Session["Emp_ID"] != null
    ? Session["Emp_ID"].ToString()
    : "";
        int noOfGuests = 0, men = 0, women = 0, child = 0;
        int.TryParse(txtNoOfGuests.Text.Trim(), out noOfGuests);
        int.TryParse(txtMen.Text.Trim(), out men);
        int.TryParse(txtWomen.Text.Trim(), out women);
        int.TryParse(txtChild.Text.Trim(), out child);
        // bool applyFacility = chkApplyFacility.Checked; // Removed as requested

        // Parse RFID Data
        Dictionary<string, string> rfidMap = new Dictionary<string, string>();
        if (!string.IsNullOrEmpty(hfRFIDData.Value))
        {
            try {
                var serializer = new JavaScriptSerializer();
                rfidMap = serializer.Deserialize<Dictionary<string, string>>(hfRFIDData.Value);
            } catch { }
        }

        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                SqlTransaction trans = con.BeginTransaction();
                try
                {
                    // Update ONLY the required number of reservation rows to Occupied
                    SqlCommand cmdStatus = new SqlCommand(@"
                        UPDATE RoomReservations 
                        SET Status = 'Occupied', GuestName = @G 
                        WHERE ReservationID IN (
                            SELECT TOP (@Count) ReservationID 
                            FROM RoomReservations 
                            WHERE ReservationNo = @ResNo AND (Status = 'Confirmed' OR Status = 'Pending')
                        )",
                        con, trans);
                    cmdStatus.Parameters.AddWithValue("@ResNo", currentReservationNo);
                    cmdStatus.Parameters.AddWithValue("@G", txtGuestName.Text.Trim());
                    cmdStatus.Parameters.AddWithValue("@Count", rooms.Length);
                    cmdStatus.ExecuteNonQuery();
                        // Update ToDate for the entire reservation based on the Check-in Card departure date
                        DateTime newToDate = DateTime.Now.AddDays(1);
                        if (!string.IsNullOrEmpty(txtDepartureDateCard.Text))
                            DateTime.TryParse(txtDepartureDateCard.Text, out newToDate);

                        SqlCommand cmdDate = new SqlCommand(@"
                        UPDATE RoomReservations 
                        SET ToDate = @NewToDate 
                        WHERE ReservationNo = @ResNo",
                            con, trans);
                        cmdDate.Parameters.AddWithValue("@ResNo", currentReservationNo);
                        cmdDate.Parameters.AddWithValue("@NewToDate", newToDate);
                        cmdDate.ExecuteNonQuery();
                        // Insert room allocations with check-in card data
                        string firstRoom = "";
                    DateTime checkInTime = DateTime.Now;
                    foreach (string roomNo in rooms)
                    {
                        string rNo = roomNo.Trim();
                        if (string.IsNullOrWhiteSpace(rNo)) continue;
                        if (string.IsNullOrEmpty(firstRoom)) firstRoom = rNo;

                        // 1. Fetch Room Rate and Tax
                        decimal roomRent = 0, taxPct = 0;
                        using (SqlCommand cmdRate = new SqlCommand("SELECT Rent, TaxPercentage FROM RoomDefinitionNew WHERE RoomNo = @R", con, trans))
                        {
                            cmdRate.Parameters.AddWithValue("@R", rNo);
                            using (SqlDataReader drRate = cmdRate.ExecuteReader())
                            {
                                if (drRate.Read())
                                {
                                    roomRent = drRate["Rent"] != DBNull.Value ? Convert.ToDecimal(drRate["Rent"]) : 0;
                                    taxPct = drRate["TaxPercentage"] != DBNull.Value ? Convert.ToDecimal(drRate["TaxPercentage"]) : 0;
                                }
                            }
                        }

                        // 2. Update Room Status in RoomDefinitionNew
                        SqlCommand cmdRoom = new SqlCommand(
                            "UPDATE RoomDefinitionNew SET Status = 'Occupied' WHERE RoomNo = @R", con, trans);
                        cmdRoom.Parameters.AddWithValue("@R", rNo);
                        cmdRoom.ExecuteNonQuery();

                        // 3. Insert Room Allocations (Setting LastChargedDate to Today)
                        SqlCommand cmdAlloc = new SqlCommand(@"
                            INSERT INTO RoomAllocations 
                                (ReservationNo, RoomNo, AllocatedDate,
                                 GuestAddress, CNIC_Passport, Country,
                                 DriverName, DriverStay, VehicleNo,
                                 Remarks, CheckInBy, NoOfGuests,
                                 Men, Women, Child, RFIDCardNo, LastChargedDate)
                            VALUES 
                                (@ResNo, @RoomNo, @CheckInTime,
                                 @GuestAddress, @CNIC, @Country,
                                 @DriverName, @DriverStay, @VehicleNo,
                                 @Remarks, @CheckInBy, @NoOfGuests,
                                 @Men, @Women, @Child, @RFID,
                                 CAST(@CheckInTime AS DATE))",
                            con, trans);

                        string rfidValue = "";
                        if (rfidMap.ContainsKey(rNo)) rfidValue = rfidMap[rNo];

                        cmdAlloc.Parameters.AddWithValue("@ResNo", currentReservationNo);
                        cmdAlloc.Parameters.AddWithValue("@RoomNo", rNo);
                        cmdAlloc.Parameters.AddWithValue("@GuestAddress", guestAddress);
                        cmdAlloc.Parameters.AddWithValue("@CNIC", cnic);
                        cmdAlloc.Parameters.AddWithValue("@Country", country);
                        cmdAlloc.Parameters.AddWithValue("@DriverName", driverName);
                        cmdAlloc.Parameters.AddWithValue("@DriverStay", driverStay);
                        cmdAlloc.Parameters.AddWithValue("@VehicleNo", vehicleNo);
                        cmdAlloc.Parameters.AddWithValue("@Remarks", remarks);
                        cmdAlloc.Parameters.AddWithValue("@CheckInBy", checkInBy);
                        cmdAlloc.Parameters.AddWithValue("@NoOfGuests", noOfGuests > 0 ? (object)noOfGuests : DBNull.Value);
                        cmdAlloc.Parameters.AddWithValue("@Men", men);
                        cmdAlloc.Parameters.AddWithValue("@Women", women);
                        cmdAlloc.Parameters.AddWithValue("@Child", child);
                        cmdAlloc.Parameters.AddWithValue("@RFID", rfidValue);
                        cmdAlloc.Parameters.AddWithValue("@CheckInTime", checkInTime);
                        cmdAlloc.ExecuteNonQuery();

                        // 4. Post Initial Rent & GST to Ledger (GR_RoomServices)
                        if (roomRent > 0)
                        {
                            string dateStr = DateTime.Now.ToString("dd-MMM");
                            string invoiceNo = "AUTO-" + DateTime.Now.ToString("yyyyMMddHHmm");
                            
                            // Room Rent Entry
                            string qRent = @"INSERT INTO GR_RoomServices (ReservationNo, RoomNo, ServiceName, Qty, UnitPrice, TaxPercentage, TaxAmount, Status, OrderDate, InvoiceNo) 
                                           VALUES (@ResNo, @RoomNo, @ServiceName, 1, @Price, 0, 0, 'Pending', @OrderDate, @Invoice)";
                            using (SqlCommand cmdSRent = new SqlCommand(qRent, con, trans))
                            {
                                cmdSRent.Parameters.AddWithValue("@ResNo", currentReservationNo);
                                cmdSRent.Parameters.AddWithValue("@RoomNo", rNo);
                                cmdSRent.Parameters.AddWithValue("@ServiceName", "Room Rent (Automatic) - " + dateStr);
                                cmdSRent.Parameters.AddWithValue("@Price", roomRent);
                                cmdSRent.Parameters.AddWithValue("@Invoice", invoiceNo);
                                cmdSRent.Parameters.AddWithValue("@OrderDate", checkInTime);
                                cmdSRent.ExecuteNonQuery();
                            }

                            // GST Entry
                            if (taxPct > 0)
                            {
                                decimal taxAmt = Math.Round(roomRent * taxPct / 100, 2);
                                string qTax = @"INSERT INTO GR_RoomServices (ReservationNo, RoomNo, ServiceName, Qty, UnitPrice, TaxPercentage, TaxAmount, Status, OrderDate, InvoiceNo) 
                                               VALUES (@ResNo, @RoomNo, @ServiceName, 1, @Price, 0, 0, 'Pending', @OrderDate, @Invoice)";
                                using (SqlCommand cmdSTax = new SqlCommand(qTax, con, trans))
                                {
                                    cmdSTax.Parameters.AddWithValue("@ResNo", currentReservationNo);
                                    cmdSTax.Parameters.AddWithValue("@RoomNo", rNo);
                                    cmdSTax.Parameters.AddWithValue("@ServiceName", "GST on Room Rent - " + dateStr);
                                    cmdSTax.Parameters.AddWithValue("@Price", taxAmt);
                                    cmdSTax.Parameters.AddWithValue("@Invoice", invoiceNo);
                                    cmdSTax.Parameters.AddWithValue("@OrderDate", checkInTime);
                                    cmdSTax.ExecuteNonQuery();
                                }
                            }
                        }
                    }

                    trans.Commit();

                    string msg = string.Format(" {0} room(s) checked in successfully for booking {1}.<br/>" + 
                        (rooms.Length < remainingRooms ? string.Format("<b>{0} rooms still remaining</b> in this group booking.", (remainingRooms - rooms.Length)) : "Group check-in complete.") +
                        "<br/><br/><a href='FacilityDefinition.aspx?RoomNo={2}' class='btn-gold' style='text-decoration:none; display:inline-block; margin-top:10px;'> Proceed to Room Services (Facility)</a>",
                        rooms.Length, currentReservationNo, firstRoom);

                    ShowMessage(msg, true);

                    pnlRoomSelection.Visible = false;
                    pnlCheckInCard.Visible = false;
                    pnlAllocatedRooms.Visible = true;
                    lblStatus.Text = "occupied";
                    lblStatus.CssClass = "status-badge status-availed";

                    LoadAllocatedRooms(currentReservationNo);
                    LoadAvailableRooms();

                    hfSelectedRooms.Value = "";
                    lblSelectedCount.Text = "0";
                }
                catch (Exception ex)
                {
                    trans.Rollback();
                    throw ex;
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error during check-in: " + ex.Message, false);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        pnlReservation.Visible = false;
        txtSearch.Text = "";
        hfSelectedRooms.Value = "";
        lblSelectedCount.Text = "0";
        ViewState.Remove("CurrentReservationNo");
        ViewState.Remove("BookedRoomsCount");
    }

    protected string GetRoomStatusClass(string status)
    {
        if (status == "Occupied") return "occupied";
        if (status == "Available") return "available";
        return "occupied";
    }

    private void ShowMessage(string msg, bool success)
    {
        lblMessage.Text = msg;
        lblMessage.CssClass = "alert show " + (success ? "alert-success" : "alert-error");
        if (success)
        {
            ClientScript.RegisterStartupScript(GetType(), "HideMsg",
                "setTimeout(function(){ var m=document.getElementById('" + lblMessage.ClientID + "'); if(m) m.style.display='none'; }, 5000);", true);
        }
    }
}
}





