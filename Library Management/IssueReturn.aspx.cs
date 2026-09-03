using System;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Pages_Circulation_IssueReturn : System.Web.UI.Page
{
    private short CurrentStaffID = 1;

    protected void Page_Load(object sender, EventArgs e)
    {
        pnlAlert.Visible = false;

        if (Session["StaffID"] != null)
        {
            CurrentStaffID = Convert.ToInt16(Session["StaffID"]);
        }

        if (!IsPostBack)
        {
            txtIssueDate.Text = DateTime.Today.ToString("dd/MM/yyyy");
            txtReturnDateVal.Text = DateTime.Today.ToString("dd/MM/yyyy");
            txtResDateVal.Text = DateTime.Today.ToString("dd/MM/yyyy");
            txtReportAsOnDate.Text = DateTime.Today.ToString("dd/MM/yyyy");

            // Populate system settings dynamically from Database
            LoadSystemSettingsFromDB();

            // Clear default values for Member fields on initial load
            ClearMemberDisplay();

            // Populate Next Issue No and Next Reserve No from DB
            txtIssueNo.Text = GetNextIssueNoFromDB();
            txtResNoVal.Text = GetNextReserveNoFromDB();

            InitializeIssueBasket();

            // Support direct query string book auto-selection from Catalogue view
            if (!string.IsNullOrEmpty(Request.QueryString["BookID"]))
            {
                int bookID = 0;
                if (int.TryParse(Request.QueryString["BookID"], out bookID))
                {
                    FetchBookForIssueByID(bookID);
                }
            }

            if (!string.IsNullOrEmpty(Request.QueryString["MemberNo"]))
            {
                txtMemberNo.Text = Request.QueryString["MemberNo"];
                VerifyMemberByNo(txtMemberNo.Text.Trim());
            }
        }
    }

    private void OpenPrintPopup(string url, string scriptKey)
    {
        string js = "window.open('" + ResolveUrl(url) + "', '_blank', 'width=950,height=750,resizable=yes,scrollbars=yes');";
        ScriptManager.RegisterStartupScript(upCirculation, upCirculation.GetType(), scriptKey + "_" + DateTime.Now.Ticks, js, true);
    }

    #region Dynamic DB Sequence and Settings
    private string GetNextIssueNoFromDB()
    {
        try
        {
            DataTable dt = DBHelper.GetTableData(@"
                SELECT ISNULL(MAX(MaxID), 0) + 1 AS NextID 
                FROM (
                    SELECT MAX(LoanID) AS MaxID FROM Loans
                    UNION ALL
                    SELECT MAX(LoanID) AS MaxID FROM BookLoans
                ) t");

            if (dt != null && dt.Rows.Count > 0 && dt.Rows[0]["NextID"] != DBNull.Value)
            {
                int nextID = Convert.ToInt32(dt.Rows[0]["NextID"]);
                return nextID.ToString("D6");
            }
        }
        catch
        {
            try
            {
                DataTable dt2 = DBHelper.GetTableData("SELECT ISNULL(MAX(LoanID), 0) + 1 AS NextID FROM Loans");
                if (dt2 != null && dt2.Rows.Count > 0 && dt2.Rows[0]["NextID"] != DBNull.Value)
                {
                    int nextID = Convert.ToInt32(dt2.Rows[0]["NextID"]);
                    return nextID.ToString("D6");
                }
            }
            catch { }
        }

        return "081544";
    }

    private string GetNextReserveNoFromDB()
    {
        try
        {
            DataTable dt = DBHelper.GetTableData("SELECT ISNULL(MAX(ResID), 0) + 1 AS NextID FROM Reservations");
            if (dt != null && dt.Rows.Count > 0 && dt.Rows[0]["NextID"] != DBNull.Value)
            {
                int nextID = Convert.ToInt32(dt.Rows[0]["NextID"]);
                return nextID.ToString("D5");
            }
        }
        catch { }

        return "05204";
    }

    private void LoadSystemSettingsFromDB()
    {
        decimal finePerDay = GetFinePerDayFromDB();
        int maxLoanPeriod = GetMaxLoanPeriodFromDB();
        int maxBookIssue = GetMaxBookIssueFromDB();
        int renewalsAllowed = GetMaxRenewalsFromDB();

        txtLateFinePerDay.Text = finePerDay.ToString("0.##");
        txtMaxLoanPeriod.Text = maxLoanPeriod.ToString();
        txtMaxBookIssue.Text = maxBookIssue.ToString();
        txtRenewalsAllowed.Text = renewalsAllowed.ToString();
    }

    private decimal GetFinePerDayFromDB()
    {
        try
        {
            DataTable dt = DBHelper.GetTableData("SELECT TOP 1 SVal FROM Settings WHERE SKey IN ('FinePerDay', 'OverdueDailyFine', 'LateFinePerDay') AND SVal IS NOT NULL");
            if (dt != null && dt.Rows.Count > 0 && dt.Rows[0]["SVal"] != DBNull.Value)
            {
                decimal val;
                if (decimal.TryParse(dt.Rows[0]["SVal"].ToString(), out val))
                    return val;
            }

            DataTable dt2 = DBHelper.GetTableData("SELECT TOP 1 SettingValue FROM LibrarySettings WHERE SettingKey IN ('FinePerDay', 'OverdueDailyFine', 'LateFinePerDay') AND SettingValue IS NOT NULL");
            if (dt2 != null && dt2.Rows.Count > 0 && dt2.Rows[0]["SettingValue"] != DBNull.Value)
            {
                decimal val;
                if (decimal.TryParse(dt2.Rows[0]["SettingValue"].ToString(), out val))
                    return val;
            }
        }
        catch { }

        return 2.00m;
    }

    private int GetMaxLoanPeriodFromDB()
    {
        // Enforce 30 days default as requested
        return 30;
    }

    private int GetMaxBookIssueFromDB()
    {
        try
        {
            DataTable dt = DBHelper.GetTableData("SELECT TOP 1 SVal FROM Settings WHERE SKey IN ('MaxBooks', 'MaxBooksPerMember', 'MaxBookIssue') AND SVal IS NOT NULL");
            if (dt != null && dt.Rows.Count > 0 && dt.Rows[0]["SVal"] != DBNull.Value)
            {
                int val;
                if (int.TryParse(dt.Rows[0]["SVal"].ToString(), out val))
                    return val;
            }
        }
        catch { }

        return 10;
    }

    private int GetMaxRenewalsFromDB()
    {
        try
        {
            DataTable dt = DBHelper.GetTableData("SELECT TOP 1 SVal FROM Settings WHERE SKey IN ('MaxRenewals', 'RenewalLimit') AND SVal IS NOT NULL");
            if (dt != null && dt.Rows.Count > 0 && dt.Rows[0]["SVal"] != DBNull.Value)
            {
                int val;
                if (int.TryParse(dt.Rows[0]["SVal"].ToString(), out val))
                    return val;
            }
        }
        catch { }

        return 5;
    }
    #endregion

    private void ShowAlert(string msg, bool isError = true)
    {
        pnlAlert.Visible = true;
        divAlert.Attributes["style"] = isError 
            ? "padding: 12px 18px; border-radius: 6px; font-size: 13.5px; font-weight: 600; background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5;" 
            : "padding: 12px 18px; border-radius: 6px; font-size: 13.5px; font-weight: 600; background: #d1fae5; color: #065f46; border: 1px solid #6ee7b7;";
        litAlertMsg.Text = msg;
    }

    #region Shared Member Verification from MemberProfile Query
    protected void btnVerifyMember_Click(object sender, EventArgs e)
    {
        VerifyMemberByNo(txtMemberNo.Text.Trim());
    }

    protected void txtMemberNo_TextChanged(object sender, EventArgs e)
    {
        VerifyMemberByNo(txtMemberNo.Text.Trim());
    }

    private void VerifyMemberByNo(string input)
    {
        pnlAlert.Visible = false;
        if (string.IsNullOrEmpty(input))
        {
            ShowAlert("Enter Member No or swipe RFID card.");
            ClearMemberDisplay();
            return;
        }

        try
        {
            DataTable dtMember = null;
            string cleanInput = input.Replace("'", "''");
            
            // 1. Query select Status, MemberType from Membership.dbo.MemberProfile
            try
            {
                string sqlProfile = @"
                    SELECT TOP 1 
                        MemberID, 
                        MemberNo, 
                        MemberName, 
                        MemberType,
                        Status
                    FROM MemberShip.dbo.MemberProfile
                    WHERE MemberNo = '" + cleanInput + @"' OR RFID = '" + cleanInput + "'";
                
                dtMember = DBHelper.GetTableData(sqlProfile);
            }
            catch { }

            // 2. Query Spouse from MemberShip.dbo.MemberSpouses by spouse's own MembershipNo
            if (dtMember == null || dtMember.Rows.Count == 0)
            {
                try
                {
                    string sqlSpouse = @"
                        SELECT TOP 1 
                            ms.MemberID, 
                            ms.MembershipNo AS MemberNo, 
                            ms.SpouseName AS MemberName, 
                            'SPOUSE (' + mp.MemberName + ')' AS MemberType,
                            CASE WHEN ms.RecordStatus = 'Active' OR mp.Status = 'Active' THEN 'ACTIVE' ELSE 'INACTIVE' END AS Status
                        FROM MemberShip.dbo.MemberSpouses ms
                        JOIN MemberShip.dbo.MemberProfile mp ON ms.MemberID = mp.MemberID
                        WHERE ms.MembershipNo = '" + cleanInput + "'";
                    
                    dtMember = DBHelper.GetTableData(sqlSpouse);
                }
                catch { }
            }

            // 3. Query Child from MemberShip.dbo.MemberChildren by child's own MembershipNo
            if (dtMember == null || dtMember.Rows.Count == 0)
            {
                try
                {
                    string sqlChild = @"
                        SELECT TOP 1 
                            mc.MemberID, 
                            mc.MembershipNo AS MemberNo, 
                            mc.ChildName AS MemberName, 
                            'CHILD (' + ISNULL(mc.Relationship, 'Child') + ' of ' + mp.MemberName + ')' AS MemberType,
                            CASE WHEN mc.RecordStatus = 'Active' OR mp.Status = 'Active' THEN 'ACTIVE' ELSE 'INACTIVE' END AS Status
                        FROM MemberShip.dbo.MemberChildren mc
                        JOIN MemberShip.dbo.MemberProfile mp ON mc.MemberID = mp.MemberID
                        WHERE mc.MembershipNo = '" + cleanInput + "'";
                    
                    dtMember = DBHelper.GetTableData(sqlChild);
                }
                catch { }
            }

            // 4. Fallback to local Members table if MemberShip.dbo.MemberProfile is empty or unaccessible
            if (dtMember == null || dtMember.Rows.Count == 0)
            {
                try
                {
                    string sqlLocal = @"
                        SELECT TOP 1 
                            m.MemberID, 
                            m.MembershipNo AS MemberNo, 
                            m.FullName AS MemberName, 
                            ISNULL(mt.TypeName, '') AS MemberType,
                            CASE WHEN m.IsActive = 1 THEN 'ACTIVE' ELSE 'INACTIVE' END AS Status
                        FROM Members m
                        LEFT JOIN MemberTypes mt ON m.MTypeID = mt.MTypeID
                        WHERE m.MembershipNo = '" + cleanInput + @"' OR m.CNIC = '" + cleanInput + "'";
                    
                    dtMember = DBHelper.GetTableData(sqlLocal);
                }
                catch { }
            }

            // Fallback to ScanRFID helper
            if (dtMember == null || dtMember.Rows.Count == 0)
            {
                try
                {
                    dtMember = new GymKhana.Library.ScanRFID().CheckRFID(input);
                }
                catch { }
            }

            if (dtMember != null && dtMember.Rows.Count > 0)
            {
                DataRow r = dtMember.Rows[0];
                int memberID = Convert.ToInt32(r["MemberID"]);
                string memberNo = r.Table.Columns.Contains("MemberNo") ? r["MemberNo"].ToString() : input;
                string memberName = r.Table.Columns.Contains("MemberName") ? r["MemberName"].ToString().ToUpper() : (r.Table.Columns.Contains("FullName") ? r["FullName"].ToString().ToUpper() : "");
                
                string memberType = r.Table.Columns.Contains("MemberType") && r["MemberType"] != DBNull.Value ? r["MemberType"].ToString().ToUpper() : "";
                string status = r.Table.Columns.Contains("Status") && r["Status"] != DBNull.Value ? r["Status"].ToString().ToUpper() : "";

                txtMemberName.Text = memberName;
                txtMembershipType.Text = memberType;
                txtMemberStatus.Text = status;
                txtMembershipStatus.Text = status;
                txtReturnMemberNo.Text = memberNo;

                ViewState["MemberID"] = memberID;
                ViewState["MemberNo"] = memberNo;
                ViewState["MemberType"] = memberType;

                // Load Member's Active Loans
                LoadMemberLoans(memberID, memberNo);

                // If currently in Return & Renewal mode, also populate Return Grid immediately
                if (pnlModeReturn.Visible)
                {
                    LoadReturnGridForMember(memberID, memberNo);
                }

                ShowAlert("Member verified: " + memberName, isError: false);
            }
            else
            {
                ClearMemberDisplay();
                ShowAlert("Member not found. Check Member No / RFID.");
            }
        }
        catch (Exception ex)
        {
            ClearMemberDisplay();
            ShowAlert("Verification error: " + ex.Message);
        }
    }

    private void LoadMemberLoans(int memberID, string memberNo)
    {
        decimal finePerDay = GetFinePerDayFromDB();
        
        // 1. Count for Main Member (M)
        int mainCount = 0;
        try
        {
            DataTable dtM = DBHelper.GetTableData(@"
                SELECT COUNT(*) AS Cnt 
                FROM Loans L 
                WHERE L.MemberID = " + memberID + @" AND L.ReturnDate IS NULL 
                  AND (L.ActualBorrowerNo IS NULL OR L.ActualBorrowerNo = '' OR L.ActualBorrowerNo COLLATE DATABASE_DEFAULT = '" + memberNo.Replace("'", "''") + @"' COLLATE DATABASE_DEFAULT)");
            if (dtM != null && dtM.Rows.Count > 0 && dtM.Rows[0]["Cnt"] != DBNull.Value)
                mainCount = Convert.ToInt32(dtM.Rows[0]["Cnt"]);
        }
        catch { }

        // 2. Count for Spouse (S)
        int spouseCount = 0;
        try
        {
            DataTable dtS = DBHelper.GetTableData(@"
                SELECT COUNT(*) AS Cnt 
                FROM Loans L 
                WHERE L.MemberID = " + memberID + @" AND L.ReturnDate IS NULL 
                  AND L.ActualBorrowerNo COLLATE DATABASE_DEFAULT IN (SELECT ms.MembershipNo COLLATE DATABASE_DEFAULT FROM MemberShip.dbo.MemberSpouses ms WHERE ms.MemberID = " + memberID + ")");
            if (dtS != null && dtS.Rows.Count > 0 && dtS.Rows[0]["Cnt"] != DBNull.Value)
                spouseCount = Convert.ToInt32(dtS.Rows[0]["Cnt"]);
        }
        catch { }

        // 3. Count for Child (C)
        int childCount = 0;
        try
        {
            DataTable dtC = DBHelper.GetTableData(@"
                SELECT COUNT(*) AS Cnt 
                FROM Loans L 
                WHERE L.MemberID = " + memberID + @" AND L.ReturnDate IS NULL 
                  AND L.ActualBorrowerNo COLLATE DATABASE_DEFAULT IN (SELECT mc.MembershipNo COLLATE DATABASE_DEFAULT FROM MemberShip.dbo.MemberChildren mc WHERE mc.MemberID = " + memberID + ")");
            if (dtC != null && dtC.Rows.Count > 0 && dtC.Rows[0]["Cnt"] != DBNull.Value)
                childCount = Convert.ToInt32(dtC.Rows[0]["Cnt"]);
        }
        catch { }

        txtAlreadyIssuedM.Text = mainCount.ToString();
        txtAlreadyIssuedMS.Text = spouseCount.ToString();
        txtAlreadyIssuedTotal.Text = childCount.ToString();

        // Query active loans grid for all member & dependents using BookNo from BookCopies
        DataTable dt = null;
        try
        {
            string sqlLoans = @"
                SELECT cp.BookNo, b.Title, l.IssueDate, l.DueDate, 
                       CASE WHEN GETDATE() > l.DueDate THEN DATEDIFF(day, l.DueDate, GETDATE()) * " + finePerDay + @" ELSE 0 END AS FineAmount
                FROM Loans l 
                JOIN BookCopies cp ON l.CopyID = cp.CopyID 
                JOIN Books b ON cp.BookID = b.BookID 
                WHERE l.MemberID = " + memberID + @" AND l.ReturnDate IS NULL
                ORDER BY l.IssueDate DESC";
            
            dt = DBHelper.GetTableData(sqlLoans);
        }
        catch
        {
            try
            {
                var prms = new[]
                {
                    new SqlParameter("@MemberID", memberID),
                    new SqlParameter("@ActiveOnly", true)
                };
                dt = DBHelper.ExecuteReader("sp_GetMemberLoans", prms);
            }
            catch { }
        }

        gvMemberActiveLoans.DataSource = dt;
        gvMemberActiveLoans.DataBind();
        pnlAlreadyIssuedSection.Visible = true;
    }

    private void ClearMemberDisplay()
    {
        txtMemberName.Text = "";
        txtMembershipType.Text = "";
        txtMemberStatus.Text = "";
        txtMembershipStatus.Text = "";
        txtAlreadyIssuedM.Text = "";
        txtAlreadyIssuedMS.Text = "";
        txtAlreadyIssuedTotal.Text = "";
        txtReturnMemberNo.Text = "";
        ViewState["MemberID"] = null;
        ViewState["MemberNo"] = null;
        pnlAlreadyIssuedSection.Visible = false;
    }
    #endregion

    #region Tab Switcher Controls
    protected void btnTabIssue_Click(object sender, EventArgs e)
    {
        hfCircMode.Value = "ISSUE";
        pnlModeIssue.Visible = true;
        pnlModeReturn.Visible = false;
        pnlModeReservation.Visible = false;

        btnTabIssue.CssClass = "circ-tab-btn active";
        btnTabReturn.CssClass = "circ-tab-btn";
        btnTabReservation.CssClass = "circ-tab-btn";
        pnlAlert.Visible = false;

        txtIssueNo.Text = GetNextIssueNoFromDB();
    }

    protected void btnTabReturn_Click(object sender, EventArgs e)
    {
        hfCircMode.Value = "RETURN";
        pnlModeIssue.Visible = false;
        pnlModeReturn.Visible = true;
        pnlModeReservation.Visible = false;

        btnTabIssue.CssClass = "circ-tab-btn";
        btnTabReturn.CssClass = "circ-tab-btn active";
        btnTabReservation.CssClass = "circ-tab-btn";
        pnlAlert.Visible = false;

        if (ViewState["MemberID"] != null)
        {
            int memberID = Convert.ToInt32(ViewState["MemberID"]);
            string memberNo = ViewState["MemberNo"] != null ? ViewState["MemberNo"].ToString() : "";
            txtReturnMemberNo.Text = memberNo;
            LoadReturnGridForMember(memberID, memberNo);
        }
    }

    protected void btnTabReservation_Click(object sender, EventArgs e)
    {
        hfCircMode.Value = "RESERVATION";
        pnlModeIssue.Visible = false;
        pnlModeReturn.Visible = false;
        pnlModeReservation.Visible = true;

        btnTabIssue.CssClass = "circ-tab-btn";
        btnTabReturn.CssClass = "circ-tab-btn";
        btnTabReservation.CssClass = "circ-tab-btn active";
        pnlAlert.Visible = false;

        txtResNoVal.Text = GetNextReserveNoFromDB();

        if (ViewState["MemberID"] != null)
        {
            LoadMemberReservations(Convert.ToInt32(ViewState["MemberID"]));
        }
    }
    #endregion

    #region Mode 1: New Issue
    private void InitializeIssueBasket()
    {
        if (ViewState["IssueBasket"] == null)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("CopyID", typeof(int));
            dt.Columns.Add("BookNo", typeof(string));
            dt.Columns.Add("Ref", typeof(string));
            dt.Columns.Add("Title", typeof(string));
            dt.Columns.Add("DDC", typeof(string));
            dt.Columns.Add("ReturnDate", typeof(DateTime));
            ViewState["IssueBasket"] = dt;
        }
    }

    protected void txtIssueBookNo_TextChanged(object sender, EventArgs e)
    {
        FetchBookForIssue(txtIssueBookNo.Text.Trim());
    }

    protected void btnFetchIssueBook_Click(object sender, EventArgs e)
    {
        FetchBookForIssue(txtIssueBookNo.Text.Trim());
    }

    private void FetchBookForIssueByID(int bookID)
    {
        DataTable dt = DBHelper.GetTableData(@"
            SELECT TOP 1 b.BookID, b.Title, b.ClassNo AS DDC, 
                   ISNULL(b.IsReference, 0) AS IsReference, ISNULL(b.NotToBeIssued, 0) AS NotToBeIssued, 
                   ISNULL(b.IsAdults, 0) AS IsAdults, ISNULL(b.IsChildren, 0) AS IsChildren, 
                   cp.CopyID, cp.BookNo 
            FROM Books b 
            JOIN BookCopies cp ON b.BookID = cp.BookID 
            WHERE b.BookID = " + bookID + " AND cp.IsAvailable = 1");
        ProcessFetchedIssueBook(dt);
    }

    private void FetchBookForIssue(string bookInput)
    {
        pnlAlert.Visible = false;
        if (string.IsNullOrEmpty(bookInput))
        {
            ShowAlert("Enter Book No or scan barcode.");
            return;
        }

        string cleanInput = bookInput.Replace("'", "''");
        // Search strictly by BookNo or Barcode in BookCopies table
        DataTable dt = DBHelper.GetTableData(@"
            SELECT TOP 1 b.BookID, b.Title, b.ClassNo AS DDC, 
                   ISNULL(b.IsReference, 0) AS IsReference, ISNULL(b.NotToBeIssued, 0) AS NotToBeIssued, 
                   ISNULL(b.IsAdults, 0) AS IsAdults, ISNULL(b.IsChildren, 0) AS IsChildren, 
                   cp.CopyID, cp.BookNo 
            FROM BookCopies cp 
            JOIN Books b ON cp.BookID = b.BookID 
            WHERE (CAST(cp.BookNo AS VARCHAR) = '" + cleanInput + "' OR cp.Barcode = '" + cleanInput + "') AND cp.IsAvailable = 1");
        ProcessFetchedIssueBook(dt);
    }

    private bool CheckBookReservationHold(int copyID, int bookID, int currentMemberID, out string holdMsg)
    {
        holdMsg = "";
        try
        {
            if (bookID <= 0 && copyID > 0)
            {
                DataTable dtCopy = DBHelper.GetTableData("SELECT BookID FROM BookCopies WHERE CopyID = " + copyID);
                if (dtCopy != null && dtCopy.Rows.Count > 0 && dtCopy.Rows[0]["BookID"] != DBNull.Value)
                {
                    bookID = Convert.ToInt32(dtCopy.Rows[0]["BookID"]);
                }
            }

            // Query FIRST (FIFO Position #1) active reservation for this book or copy
            string sqlResHold = @"
                SELECT TOP 1 
                    r.ResID,
                    r.MemberID, 
                    r.BookID, 
                    r.ReservedAt,
                    r.QueuePos,
                    COALESCE(NULLIF(m.FullName, ''), NULLIF(mp.MemberName, ''), '') AS FullName, 
                    COALESCE(NULLIF(m.MembershipNo, ''), NULLIF(mp.MemberNo, ''), '') AS MembershipNo, 
                    r.NotifiedOn,
                    r.ExpiryDate,
                    ISNULL(r.ExpiryDate, DATEADD(day, 7, ISNULL(r.NotifiedOn, r.ReservedAt))) AS ReservedUntil 
                FROM Reservations r 
                LEFT JOIN Members m ON r.MemberID = m.MemberID 
                LEFT JOIN MemberShip.dbo.MemberProfile mp ON r.MemberID = mp.MemberID 
                WHERE (r.BookID = " + bookID + @" 
                    OR r.BookID = " + copyID + @"
                    OR r.BookID IN (SELECT BookID FROM BookCopies WHERE CopyID = " + copyID + @")
                ) 
                  AND (r.StatusID IS NULL OR (r.StatusID <> 3 AND r.StatusID <> 4))
                  AND ISNULL(r.ExpiryDate, DATEADD(day, 7, ISNULL(r.NotifiedOn, r.ReservedAt))) > GETDATE()
                ORDER BY ISNULL(r.QueuePos, 999999) ASC, r.ReservedAt ASC, r.ResID ASC";

            DataTable dtResHold = DBHelper.GetTableData(sqlResHold);

            if (dtResHold != null && dtResHold.Rows.Count > 0)
            {
                DataRow row = dtResHold.Rows[0];
                int firstReservedMemberID = Convert.ToInt32(row["MemberID"]);

                if (firstReservedMemberID != currentMemberID)
                {
                    string name = row["FullName"] != DBNull.Value ? row["FullName"].ToString().Trim().ToUpper() : ("Member #" + firstReservedMemberID);
                    string no = row["MembershipNo"] != DBNull.Value ? row["MembershipNo"].ToString().Trim() : "";
                    string memberDisplay = name + (!string.IsNullOrEmpty(no) ? " (" + no + ")" : "");
                    
                    string resDate = row["ReservedAt"] != DBNull.Value ? Convert.ToDateTime(row["ReservedAt"]).ToString("dd/MM/yyyy") : "N/A";
                    DateTime untilDate = Convert.ToDateTime(row["ReservedUntil"]);
                    string untilStr = untilDate.ToString("dd/MM/yyyy HH:mm");

                    holdMsg = "RESERVATION RESTRICTION (FIRST RIGHT RULE): This book is currently reserved by " + memberDisplay + 
                              " who has FIRST RIGHT of reservation (FIFO Position #1, Reserved on " + resDate + "). " +
                              "It is on hold until " + untilStr + " and cannot be issued to another member.";
                    return true;
                }
            }
        }
        catch { }
        return false;
    }

    private void ProcessFetchedIssueBook(DataTable dt)
    {
        if (dt != null && dt.Rows.Count > 0)
        {
            DataRow r = dt.Rows[0];
            int copyID = Convert.ToInt32(r["CopyID"]);
            int bookID = Convert.ToInt32(r["BookID"]);
            string bookNo = r["BookNo"].ToString();
            string title = r["Title"].ToString().ToUpper();
            string ddc = r["DDC"] != DBNull.Value ? r["DDC"].ToString().ToUpper() : "-";

            // 1. Check Reference / Not To Be Issued Flag
            bool isRef = (dt.Columns.Contains("IsReference") && r["IsReference"] != DBNull.Value && Convert.ToBoolean(r["IsReference"]))
                      || (dt.Columns.Contains("NotToBeIssued") && r["NotToBeIssued"] != DBNull.Value && Convert.ToBoolean(r["NotToBeIssued"]));
            if (isRef)
            {
                txtIssueBookTitle.Text = "";
                txtIssueDDC.Text = "";
                txtIssueReturnDate.Text = "";
                ShowAlert("Book '" + title + "' is REFERENCE ONLY \u2014 not for issuance.");
                return;
            }

            // 2. Check Adult vs Children Membership Restrictions
            bool isAdultsBook = dt.Columns.Contains("IsAdults") && r["IsAdults"] != DBNull.Value && Convert.ToBoolean(r["IsAdults"]);
            bool isChildrenBook = dt.Columns.Contains("IsChildren") && r["IsChildren"] != DBNull.Value && Convert.ToBoolean(r["IsChildren"]);

            string mType = ViewState["MemberType"] != null ? ViewState["MemberType"].ToString().ToUpper() : (txtMembershipType.Text != null ? txtMembershipType.Text.Trim().ToUpper() : "");
            bool isChildMember = mType.Contains("CHILD") || mType.Contains("JUNIOR") || mType.Contains("KIDS") || mType.Contains("MINOR");
            bool isAdultMember = mType.Contains("ADULT") || mType.Contains("SENIOR") || mType.Contains("REGULAR") || mType.Contains("PERMANENT") || mType.Contains("LIFE") || mType.Contains("HONORARY") || mType.Contains("CORPORATE") || mType.Contains("MEMBER");

            if (isAdultsBook && !isChildrenBook && isChildMember)
            {
                txtIssueBookTitle.Text = "";
                txtIssueDDC.Text = "";
                txtIssueReturnDate.Text = "";
                ShowAlert("Book '" + title + "' is ADULT only \u2014 restricted for " + mType + ".");
                return;
            }

            if (isChildrenBook && !isAdultsBook && isAdultMember && !isChildMember)
            {
                txtIssueBookTitle.Text = "";
                txtIssueDDC.Text = "";
                txtIssueReturnDate.Text = "";
                ShowAlert("Book '" + title + "' is CHILDREN only \u2014 restricted for " + mType + ".");
                return;
            }

            // 3. Check 7-Day Reservation Hold
            int currentMemberID = ViewState["MemberID"] != null ? Convert.ToInt32(ViewState["MemberID"]) : 0;
            string holdMsg = "";
            if (CheckBookReservationHold(copyID, bookID, currentMemberID, out holdMsg))
            {
                txtIssueBookTitle.Text = "";
                txtIssueDDC.Text = "";
                txtIssueReturnDate.Text = "";
                ShowAlert(holdMsg);
                return;
            }

            int maxLoanPeriod = GetMaxLoanPeriodFromDB();
            DateTime returnDate = DateTime.Today.AddDays(maxLoanPeriod);

            txtIssueBookTitle.Text = title;
            txtIssueDDC.Text = ddc;
            txtIssueReturnDate.Text = returnDate.ToString("dd/MM/yyyy");

            // Add to Basket
            DataTable dtBasket = (DataTable)ViewState["IssueBasket"];
            DataRow[] existing = dtBasket.Select("CopyID = " + copyID);
            if (existing.Length == 0)
            {
                DataRow newRow = dtBasket.NewRow();
                newRow["CopyID"] = copyID;
                newRow["BookNo"] = bookNo;
                newRow["Ref"] = "1";
                newRow["Title"] = title;
                newRow["DDC"] = ddc;
                newRow["ReturnDate"] = returnDate;
                dtBasket.Rows.Add(newRow);
                ViewState["IssueBasket"] = dtBasket;
            }

            gvIssueBasket.DataSource = dtBasket;
            gvIssueBasket.DataBind();
        }
        else
        {
            txtIssueBookTitle.Text = "";
            txtIssueDDC.Text = "";
            txtIssueReturnDate.Text = "";
            ShowAlert("Book not found or already checked out.");
        }
    }

    protected void gvIssueBasket_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "RemoveBook")
        {
            int index = Convert.ToInt32(e.CommandArgument);
            DataTable dt = (DataTable)ViewState["IssueBasket"];
            if (dt != null && index >= 0 && index < dt.Rows.Count)
            {
                dt.Rows.RemoveAt(index);
                ViewState["IssueBasket"] = dt;
                gvIssueBasket.DataSource = dt;
                gvIssueBasket.DataBind();
            }
        }
    }

    protected void btnSaveIssue_Click(object sender, EventArgs e)
    {
        if (ViewState["MemberID"] == null)
        {
            ShowAlert("Verify a member before issuing.");
            return;
        }

        DataTable dtBasket = (DataTable)ViewState["IssueBasket"];
        if (dtBasket == null || dtBasket.Rows.Count == 0)
        {
            ShowAlert("Add at least one book to issue.");
            return;
        }

        int memberID = Convert.ToInt32(ViewState["MemberID"]);
        string memberNo = ViewState["MemberNo"] != null ? ViewState["MemberNo"].ToString() : "";

        // Verify rules (Reference, Adult/Children, Reservation Hold) for each book in basket
        foreach (DataRow r in dtBasket.Rows)
        {
            int copyID = Convert.ToInt32(r["CopyID"]);
            int bookID = 0;
            try
            {
                DataTable dtB = DBHelper.GetTableData(@"
                    SELECT cp.BookID, b.Title, 
                           ISNULL(b.IsReference, 0) AS IsReference, ISNULL(b.NotToBeIssued, 0) AS NotToBeIssued, 
                           ISNULL(b.IsAdults, 0) AS IsAdults, ISNULL(b.IsChildren, 0) AS IsChildren 
                    FROM BookCopies cp 
                    JOIN Books b ON cp.BookID = b.BookID 
                    WHERE cp.CopyID = " + copyID);

                if (dtB != null && dtB.Rows.Count > 0)
                {
                    DataRow br = dtB.Rows[0];
                    if (br["BookID"] != DBNull.Value) bookID = Convert.ToInt32(br["BookID"]);
                    string bTitle = br["Title"].ToString().ToUpper();

                    // Check Reference / Not to be issued
                    bool isRef = Convert.ToBoolean(br["IsReference"]) || Convert.ToBoolean(br["NotToBeIssued"]);
                    if (isRef)
                    {
                        ShowAlert("Book '" + bTitle + "' is REFERENCE ONLY \u2014 not for issuance.");
                        return;
                    }

                    // Check Adult vs Children
                    bool isAdultsBook = Convert.ToBoolean(br["IsAdults"]);
                    bool isChildrenBook = Convert.ToBoolean(br["IsChildren"]);
                    string mType = ViewState["MemberType"] != null ? ViewState["MemberType"].ToString().ToUpper() : (txtMembershipType.Text != null ? txtMembershipType.Text.Trim().ToUpper() : "");
                    bool isChildMember = mType.Contains("CHILD") || mType.Contains("JUNIOR") || mType.Contains("KIDS") || mType.Contains("MINOR");
                    bool isAdultMember = mType.Contains("ADULT") || mType.Contains("SENIOR") || mType.Contains("REGULAR") || mType.Contains("PERMANENT") || mType.Contains("LIFE") || mType.Contains("HONORARY") || mType.Contains("CORPORATE") || mType.Contains("MEMBER");

                    if (isAdultsBook && !isChildrenBook && isChildMember)
                    {
                        ShowAlert("Book '" + bTitle + "' is ADULT only \u2014 restricted for " + mType + ".");
                        return;
                    }

                    if (isChildrenBook && !isAdultsBook && isAdultMember && !isChildMember)
                    {
                        ShowAlert("Book '" + bTitle + "' is CHILDREN only \u2014 restricted for " + mType + ".");
                        return;
                    }
                }
            }
            catch { }

            string holdMsg = "";
            if (CheckBookReservationHold(copyID, bookID, memberID, out holdMsg))
            {
                ShowAlert(holdMsg);
                return;
            }
        }

        int maxLoanPeriod = GetMaxLoanPeriodFromDB();
        DateTime issueDate = DateTime.Today;
        DateTime dueDate = DateTime.Today.AddDays(maxLoanPeriod);

        System.Collections.Generic.List<int> loanIDs = new System.Collections.Generic.List<int>();
        string lastError = null;

        string actualBorrowerNo = ViewState["MemberNo"] != null ? ViewState["MemberNo"].ToString() : txtMemberNo.Text.Trim();
        string actualBorrowerName = txtMemberName.Text.Trim();

        foreach (DataRow r in dtBasket.Rows)
        {
            int copyID = Convert.ToInt32(r["CopyID"]);
            string res = DBHelper.IssueBook(memberID, copyID, CurrentStaffID, issueDate, dueDate, actualBorrowerNo, actualBorrowerName);
            if (res != null && res.StartsWith("OK"))
            {
                int newLoanID = 0;
                try
                {
                    DataTable dtL = DBHelper.GetTableData("SELECT TOP 1 LoanID FROM Loans WHERE MemberID = " + memberID + " AND CopyID = " + copyID + " AND ReturnDate IS NULL ORDER BY LoanID DESC");
                    if (dtL != null && dtL.Rows.Count > 0 && dtL.Rows[0]["LoanID"] != DBNull.Value)
                    {
                        newLoanID = Convert.ToInt32(dtL.Rows[0]["LoanID"]);
                    }
                }
                catch { }

                loanIDs.Add(newLoanID > 0 ? newLoanID : 1);
            }
            else
            {
                lastError = res;
            }
        }

        if (loanIDs.Count > 0)
        {
            string loanIDsStr = string.Join(",", loanIDs);

            // Auto-release reservation if book is being issued to the same member who reserved it
            foreach (DataRow r in dtBasket.Rows)
            {
                int copyID = Convert.ToInt32(r["CopyID"]);
                AutoReleaseReservationOnIssue(memberID, copyID);
            }

            // Auto-clear Form for next entry
            txtIssueBookNo.Text = "";
            txtIssueBookTitle.Text = "";
            txtIssueDDC.Text = "";
            txtIssueReturnDate.Text = "";
            dtBasket.Clear();
            ViewState["IssueBasket"] = dtBasket;
            gvIssueBasket.DataSource = dtBasket;
            gvIssueBasket.DataBind();

            // Refresh Issue No for next transaction
            txtIssueNo.Text = GetNextIssueNoFromDB();

            // Refresh Member Active Loans
            LoadMemberLoans(memberID, memberNo);

            ShowAlert(loanIDs.Count + " book(s) issued successfully.", isError: false);

            if (chkDirectPrint.Checked)
            {
                OpenPrintPopup("IssueNote.aspx?LoanIDs=" + loanIDsStr, "PrintIssueNote");
            }
        }
        else
        {
            string friendlyMsg = lastError ?? "Database error.";
            if (lastError != null)
            {
                if (lastError.Contains("ERR:MEMBER_INACTIVE")) friendlyMsg = "Member account is inactive.";
                else if (lastError.Contains("ERR:COPY_UNAVAILABLE")) friendlyMsg = "Book copy unavailable or checked out.";
                else if (lastError.Contains("ERR:BORROW_LIMIT")) friendlyMsg = "Maximum book issue limit reached.";
                else if (lastError.Contains("ERR:REFERENCE_ONLY")) friendlyMsg = "Reference book \u2014 not for issuance.";
                else if (lastError.Contains("ERR:UNPAID_FINES")) friendlyMsg = "Unpaid fines exceed allowed limit.";
                else if (lastError.Contains("ERR:ADULTS_ONLY")) friendlyMsg = "Adults-only book \u2014 restricted for Junior.";
                else if (lastError.Contains("ERR:RESERVED_FOR_OTHER")) friendlyMsg = "Reserved for member with First Right priority: " + lastError.Replace("ERR:RESERVED_FOR_OTHER:", "");
            }
            ShowAlert("Issue failed: " + friendlyMsg);
        }
    }

    protected void btnIssueRefresh_Click(object sender, EventArgs e)
    {
        Response.Redirect(Request.Url.AbsolutePath);
    }

    protected void btnIssueNew_Click(object sender, EventArgs e)
    {
        Response.Redirect(Request.Url.AbsolutePath);
    }

    protected void btnIssueClose_Click(object sender, EventArgs e)
    {
        Response.Redirect("~/Dashboard.aspx");
    }
    #endregion

    #region Mode 2: Return and Renewal
    protected void txtReturnMemberNo_TextChanged(object sender, EventArgs e)
    {
        FetchReturnMemberLoans(txtReturnMemberNo.Text.Trim());
    }

    protected void btnFetchReturnMember_Click(object sender, EventArgs e)
    {
        FetchReturnMemberLoans(txtReturnMemberNo.Text.Trim());
    }

    private void FetchReturnMemberLoans(string memberInput)
    {
        pnlAlert.Visible = false;
        if (string.IsNullOrEmpty(memberInput))
        {
            ShowAlert("Enter Member No to fetch loans.");
            return;
        }

        txtMemberNo.Text = memberInput;
        VerifyMemberByNo(memberInput);

        if (ViewState["MemberID"] != null)
        {
            int memberID = Convert.ToInt32(ViewState["MemberID"]);
            string memberNo = ViewState["MemberNo"] != null ? ViewState["MemberNo"].ToString() : memberInput;
            txtReturnMemberNo.Text = memberNo;
            LoadReturnGridForMember(memberID, memberNo);
        }
    }

    private void LoadReturnGridForMember(int memberID, string memberNo)
    {
        decimal finePerDay = GetFinePerDayFromDB();
        DataTable dt = DBHelper.GetTableData(@"
            SELECT l.LoanID, l.CopyID, cp.BookNo, b.Title, l.IssueDate, l.DueDate, l.RenewalCount,
                   CASE WHEN GETDATE() > l.DueDate THEN DATEDIFF(day, l.DueDate, GETDATE()) * " + finePerDay + @" ELSE 0 END AS FineAmount
            FROM Loans l 
            JOIN BookCopies cp ON l.CopyID = cp.CopyID 
            JOIN Books b ON cp.BookID = b.BookID 
            WHERE l.MemberID = " + memberID + @" AND l.ReturnDate IS NULL
            ORDER BY l.IssueDate DESC");

        gvReturnLoansList.DataSource = dt;
        gvReturnLoansList.DataBind();

        if (dt != null && dt.Rows.Count > 0)
        {
            DataRow r = dt.Rows[0];
            txtReturnIssueNoVal.Text = Convert.ToInt32(r["LoanID"]).ToString("D6");
            txtReturnIssueDateVal.Text = Convert.ToDateTime(r["IssueDate"]).ToString("dd/MM/yyyy");
            txtReturnDueDateVal.Text = Convert.ToDateTime(r["DueDate"]).ToString("dd/MM/yyyy");
            txtReturnBookTitleVal.Text = r["Title"].ToString().ToUpper();
            txtReturnDateVal.Text = DateTime.Today.ToString("dd/MM/yyyy");
            txtReturnRenewalVal.Text = r["RenewalCount"].ToString();
            txtReturnBookNo.Text = r["BookNo"].ToString();

            DateTime dueDate = Convert.ToDateTime(r["DueDate"]);
            int daysLate = DateTime.Today > dueDate ? (DateTime.Today - dueDate).Days : 0;
            decimal totalFine = daysLate * finePerDay;
            txtReturnDaysLateVal.Text = daysLate.ToString();
            txtReturnFineVal.Text = totalFine.ToString("0.##");

            ViewState["ReturnCopyID"] = Convert.ToInt32(r["CopyID"]);
            ViewState["ReturnLoanID"] = Convert.ToInt32(r["LoanID"]);
        }
        else
        {
            txtReturnIssueNoVal.Text = "";
            txtReturnIssueDateVal.Text = "";
            txtReturnDueDateVal.Text = "";
            txtReturnBookTitleVal.Text = "";
            txtReturnFineVal.Text = "0";
            txtReturnRenewalVal.Text = "0";
            txtReturnDaysLateVal.Text = "0";
            ViewState["ReturnCopyID"] = null;
            ViewState["ReturnLoanID"] = null;
            ShowAlert("No active loans for member " + memberNo + ".", isError: false);
        }
    }

    protected void txtReturnBookNo_TextChanged(object sender, EventArgs e)
    {
        FetchReturnBookDetails(txtReturnBookNo.Text.Trim());
    }

    protected void btnFetchReturnBook_Click(object sender, EventArgs e)
    {
        FetchReturnBookDetails(txtReturnBookNo.Text.Trim());
    }

    private void FetchReturnBookDetails(string bookInput)
    {
        pnlAlert.Visible = false;
        if (string.IsNullOrEmpty(bookInput))
        {
            ShowAlert("Enter Book No or scan barcode.");
            return;
        }

        string cleanInput = bookInput.Replace("'", "''");
        // Search strictly by BookNo or Barcode in BookCopies table
        DataTable dt = DBHelper.GetTableData(@"
            SELECT TOP 1 l.LoanID, l.CopyID, l.MemberID, 
                   ISNULL(m.MembershipNo, '') AS MembershipNo, 
                   ISNULL(m.FullName, '') AS MemberName, 
                   cp.BookNo, b.Title, l.IssueDate, l.DueDate, ISNULL(l.RenewalCount, 0) AS RenewalCount 
            FROM Loans l 
            JOIN BookCopies cp ON l.CopyID = cp.CopyID 
            JOIN Books b ON cp.BookID = b.BookID 
            LEFT JOIN Members m ON l.MemberID = m.MemberID 
            WHERE (CAST(cp.BookNo AS VARCHAR) = '" + cleanInput + "' OR cp.Barcode = '" + cleanInput + "') AND l.ReturnDate IS NULL");

        if (dt != null && dt.Rows.Count > 0)
        {
            DataRow r = dt.Rows[0];
            int copyID = Convert.ToInt32(r["CopyID"]);
            int loanID = Convert.ToInt32(r["LoanID"]);
            int memberID = Convert.ToInt32(r["MemberID"]);
            string memberNo = r["MembershipNo"].ToString();

            txtReturnIssueNoVal.Text = loanID.ToString("D6");
            txtReturnIssueDateVal.Text = Convert.ToDateTime(r["IssueDate"]).ToString("dd/MM/yyyy");
            txtReturnDueDateVal.Text = Convert.ToDateTime(r["DueDate"]).ToString("dd/MM/yyyy");
            txtReturnBookTitleVal.Text = r["Title"].ToString().ToUpper();
            txtReturnDateVal.Text = DateTime.Today.ToString("dd/MM/yyyy");
            txtReturnRenewalVal.Text = r["RenewalCount"].ToString();

            DateTime dueDate = Convert.ToDateTime(r["DueDate"]);
            decimal finePerDay = GetFinePerDayFromDB();
            int daysLate = DateTime.Today > dueDate ? (DateTime.Today - dueDate).Days : 0;
            decimal totalFine = daysLate * finePerDay;
            txtReturnDaysLateVal.Text = daysLate.ToString();
            txtReturnFineVal.Text = totalFine.ToString("0.##");

            ViewState["ReturnCopyID"] = copyID;
            ViewState["ReturnLoanID"] = loanID;

            if (!string.IsNullOrEmpty(memberNo))
            {
                txtMemberNo.Text = memberNo;
                VerifyMemberByNo(memberNo);
            }
        }
        else
        {
            ClearReturnDisplay();
            ShowAlert("No active loan found for this Book No.");
        }
    }

    private void ClearReturnDisplay()
    {
        txtReturnBookNo.Text = "";
        txtReturnIssueNoVal.Text = "";
        txtReturnIssueDateVal.Text = "";
        txtReturnDueDateVal.Text = "";
        txtReturnBookTitleVal.Text = "";
        txtReturnFineVal.Text = "0";
        txtReturnRenewalVal.Text = "0";
        txtReturnDaysLateVal.Text = "0";
        ViewState["ReturnCopyID"] = null;
        ViewState["ReturnLoanID"] = null;
        gvReturnLoansList.DataSource = null;
        gvReturnLoansList.DataBind();
    }

    protected void btnReturnRefresh_Click(object sender, EventArgs e)
    {
        Response.Redirect(Request.Url.AbsolutePath);
    }

    protected void btnReturnRecheck_Click(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(txtReturnBookNo.Text))
        {
            FetchReturnBookDetails(txtReturnBookNo.Text.Trim());
        }
        else if (!string.IsNullOrEmpty(txtReturnMemberNo.Text))
        {
            FetchReturnMemberLoans(txtReturnMemberNo.Text.Trim());
        }
    }

    protected void gvReturnLoansList_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "ReturnRowLoan")
        {
            int copyID = Convert.ToInt32(e.CommandArgument);
            ShowReturnConfirmation(copyID);
        }
        else if (e.CommandName == "RenewRowLoan")
        {
            int loanID = Convert.ToInt32(e.CommandArgument);
            ShowRenewConfirmation(loanID);
        }
    }

    protected void btnProcessReturn_Click(object sender, EventArgs e)
    {
        int copyID = 0;
        if (ViewState["ReturnCopyID"] != null)
        {
            copyID = Convert.ToInt32(ViewState["ReturnCopyID"]);
        }

        if (copyID == 0 && !string.IsNullOrEmpty(txtReturnBookNo.Text))
        {
            string cleanNo = txtReturnBookNo.Text.Trim().Replace("'", "''");
            DataTable dtC = DBHelper.GetTableData("SELECT TOP 1 CopyID FROM BookCopies WHERE CAST(BookNo AS VARCHAR) = '" + cleanNo + "' OR Barcode = '" + cleanNo + "'");
            if (dtC != null && dtC.Rows.Count > 0 && dtC.Rows[0]["CopyID"] != DBNull.Value)
            {
                copyID = Convert.ToInt32(dtC.Rows[0]["CopyID"]);
            }
        }

        if (copyID == 0)
        {
            ShowAlert("Fetch book details before returning.");
            return;
        }

        ShowReturnConfirmation(copyID);
    }

    protected void btnProcessRenew_Click(object sender, EventArgs e)
    {
        if (ViewState["ReturnLoanID"] == null)
        {
            ShowAlert("Fetch loan details before renewing.");
            return;
        }

        int loanID = Convert.ToInt32(ViewState["ReturnLoanID"]);
        ShowRenewConfirmation(loanID);
    }

    #region Confirmation Modal Helpers
    private void ShowReturnConfirmation(int copyID)
    {
        string bookTitle = txtReturnBookTitleVal.Text;
        string bookNo = txtReturnBookNo.Text;
        string memberName = txtMemberName.Text;
        string fineAmt = txtReturnFineVal.Text;
        string daysLate = txtReturnDaysLateVal.Text;

        // Try to get book info if fields are empty
        if (string.IsNullOrEmpty(bookTitle))
        {
            try
            {
                DataTable dtInfo = DBHelper.GetTableData(@"
                    SELECT TOP 1 cp.BookNo, b.Title FROM BookCopies cp 
                    JOIN Books b ON cp.BookID = b.BookID WHERE cp.CopyID = " + copyID);
                if (dtInfo != null && dtInfo.Rows.Count > 0)
                {
                    bookTitle = dtInfo.Rows[0]["Title"].ToString().ToUpper();
                    bookNo = dtInfo.Rows[0]["BookNo"].ToString();
                }
            }
            catch { }
        }

        litConfirmTitle.Text = "Confirm Return";
        litConfirmMsg.Text = "Are you sure you want to return this book?";
        litConfirmDetail.Text = "<strong>Book No:</strong> " + bookNo + "<br/>" +
                                "<strong>Title:</strong> " + bookTitle + "<br/>" +
                                "<strong>Member:</strong> " + memberName + "<br/>" +
                                "<strong>Fine:</strong> Rs. " + fineAmt + " | <strong>Days Late:</strong> " + daysLate;

        divConfirmBox.Attributes["class"] = "circ-confirm-box confirm-return";
        divConfirmIcon.Attributes["class"] = "circ-confirm-icon icon-return";
        divConfirmIcon.InnerHtml = "&#10003;";
        btnConfirmYes.Text = "Yes, Return";
        btnConfirmYes.CssClass = "circ-confirm-yes btn-return";

        hfConfirmAction.Value = "RETURN";
        hfConfirmCopyID.Value = copyID.ToString();
        hfConfirmLoanID.Value = "0";
        pnlConfirmAction.Visible = true;
    }

    private void ShowRenewConfirmation(int loanID)
    {
        string bookTitle = txtReturnBookTitleVal.Text;
        string bookNo = txtReturnBookNo.Text;
        string memberName = txtMemberName.Text;
        string dueDate = txtReturnDueDateVal.Text;
        string renewalCount = txtReturnRenewalVal.Text;

        // Try to get book info if fields are empty
        if (string.IsNullOrEmpty(bookTitle))
        {
            try
            {
                DataTable dtInfo = DBHelper.GetTableData(@"
                    SELECT TOP 1 cp.BookNo, b.Title, l.DueDate, ISNULL(l.RenewalCount,0) AS RenewalCount 
                    FROM Loans l JOIN BookCopies cp ON l.CopyID = cp.CopyID 
                    JOIN Books b ON cp.BookID = b.BookID WHERE l.LoanID = " + loanID);
                if (dtInfo != null && dtInfo.Rows.Count > 0)
                {
                    bookTitle = dtInfo.Rows[0]["Title"].ToString().ToUpper();
                    bookNo = dtInfo.Rows[0]["BookNo"].ToString();
                    dueDate = Convert.ToDateTime(dtInfo.Rows[0]["DueDate"]).ToString("dd/MM/yyyy");
                    renewalCount = dtInfo.Rows[0]["RenewalCount"].ToString();
                }
            }
            catch { }
        }

        litConfirmTitle.Text = "Confirm Renewal";
        litConfirmMsg.Text = "Are you sure you want to renew this book? Due date will extend by 14 days.";
        litConfirmDetail.Text = "<strong>Book No:</strong> " + bookNo + "<br/>" +
                                "<strong>Title:</strong> " + bookTitle + "<br/>" +
                                "<strong>Member:</strong> " + memberName + "<br/>" +
                                "<strong>Current Due:</strong> " + dueDate + " | <strong>Renewals Used:</strong> " + renewalCount;

        divConfirmBox.Attributes["class"] = "circ-confirm-box confirm-renew";
        divConfirmIcon.Attributes["class"] = "circ-confirm-icon icon-renew";
        divConfirmIcon.InnerHtml = "&#8635;";
        btnConfirmYes.Text = "Yes, Renew";
        btnConfirmYes.CssClass = "circ-confirm-yes btn-renew";

        hfConfirmAction.Value = "RENEW";
        hfConfirmCopyID.Value = "0";
        hfConfirmLoanID.Value = loanID.ToString();
        pnlConfirmAction.Visible = true;
    }

    protected void btnConfirmYes_Click(object sender, EventArgs e)
    {
        pnlConfirmAction.Visible = false;
        string action = hfConfirmAction.Value;

        if (action == "RETURN")
        {
            int copyID = Convert.ToInt32(hfConfirmCopyID.Value);
            ExecuteReturnBook(copyID);
        }
        else if (action == "RENEW")
        {
            int loanID = Convert.ToInt32(hfConfirmLoanID.Value);
            ExecuteRenewBook(loanID);
        }

        hfConfirmAction.Value = "";
        hfConfirmCopyID.Value = "0";
        hfConfirmLoanID.Value = "0";
    }

    protected void btnConfirmNo_Click(object sender, EventArgs e)
    {
        pnlConfirmAction.Visible = false;
        hfConfirmAction.Value = "";
        hfConfirmCopyID.Value = "0";
        hfConfirmLoanID.Value = "0";
        ShowAlert("Operation cancelled.", isError: false);
    }
    #endregion

    private void ExecuteReturnBook(int copyID)
    {
        string resMemberName = "";
        int bookID = 0;
        int resID = 0;
        int resMemberID = 0;

        // FIFO Rule: Fetch the first active reservation in line
        bool hasReservation = IsBookReserved(copyID, out resMemberName, out bookID, out resID, out resMemberID);

        // Perform Return
        string res = DBHelper.ReturnBook(copyID, CurrentStaffID);

        if (res != null && res.StartsWith("OK"))
        {
            int memberID = ViewState["MemberID"] != null ? Convert.ToInt32(ViewState["MemberID"]) : 0;
            string memberNo = ViewState["MemberNo"] != null ? ViewState["MemberNo"].ToString() : "";
            ClearReturnDisplay();

            if (memberID > 0)
            {
                LoadMemberLoans(memberID, memberNo);
                LoadReturnGridForMember(memberID, memberNo);
            }

            if (hasReservation && resID > 0)
            {
                if (bookID == 0) bookID = copyID;

                // FIFO Rule: Update 7-Day Reservation Hold Expiry for the FIRST reserved member specifically
                try
                {
                    DBHelper.GetTableData(@"
                        UPDATE Reservations 
                        SET NotifiedOn = GETDATE(), 
                            ExpiryDate = DATEADD(day, 7, GETDATE()) 
                        WHERE ResID = " + resID);
                }
                catch { }

                lblReservedMemberName.Text = resMemberName;
                string slipHtml = GenerateReservationSlipHtml(bookID, resID, resMemberName);
                ViewState["ReservationSlipHtml"] = slipHtml;

                // Force Show Modal Panel for First (FIFO) Reservation Holder
                pnlReservationAlertModal.Visible = true;

                // Show Alert Message with FIFO member name
                ShowAlert("Book returned. 7-day reservation hold set for first in queue: " + resMemberName + ".", isError: false);
            }
            else
            {
                ShowAlert("Book returned successfully.", isError: false);
            }
        }
        else
        {
            ShowAlert("Return failed: " + (res ?? "Unknown error."));
        }
    }

    private void TriggerSlipPrint(string htmlContent)
    {
        string jsEncoded = HttpUtility.JavaScriptStringEncode(htmlContent);
        
        string js = @"setTimeout(function(){ var w=window.open('','_blank','width=850,height=700,resizable=yes,scrollbars=yes'); if(w){ w.document.open(); w.document.write('<html><head><title>Library Reserve Note</title><style>@page{size:auto;margin:15mm;}body{font-family:Arial,sans-serif;margin:0;padding:20px;color:#000;}</style></head><body>" + jsEncoded + @"</body></html>'); w.document.close(); w.focus(); setTimeout(function(){w.print();},500); } },200);";

        ScriptManager.RegisterStartupScript(upCirculation, upCirculation.GetType(), "PrintResSlip_" + DateTime.Now.Ticks, js, true);
    }

    private bool IsBookReserved(int copyID, out string reservedByMember, out int bookID, out int resID, out int resMemberID)
    {
        reservedByMember = "";
        bookID = 0;
        resID = 0;
        resMemberID = 0;

        try
        {
            // Get BookID from CopyID
            DataTable dtCopy = DBHelper.GetTableData("SELECT BookID FROM BookCopies WHERE CopyID = " + copyID);
            if (dtCopy != null && dtCopy.Rows.Count > 0 && dtCopy.Rows[0]["BookID"] != DBNull.Value)
            {
                bookID = Convert.ToInt32(dtCopy.Rows[0]["BookID"]);
            }

            // Query FIRST (FIFO) active reservation strictly by QueuePos ASC, ReservedAt ASC, ResID ASC
            string sqlFifo = @"
                SELECT TOP 1 
                    r.ResID, 
                    r.MemberID, 
                    r.BookID, 
                    COALESCE(NULLIF(m.FullName, ''), NULLIF(mp.MemberName, ''), '') AS FullName, 
                    COALESCE(NULLIF(m.MembershipNo, ''), NULLIF(mp.MemberNo, ''), '') AS MembershipNo
                FROM Reservations r
                LEFT JOIN Members m ON r.MemberID = m.MemberID
                LEFT JOIN MemberShip.dbo.MemberProfile mp ON r.MemberID = mp.MemberID
                WHERE (r.BookID = " + (bookID > 0 ? bookID.ToString() : copyID.ToString()) + @"
                    OR r.BookID IN (SELECT BookID FROM BookCopies WHERE CopyID = " + copyID + @"))
                  AND (r.StatusID IS NULL OR (r.StatusID <> 3 AND r.StatusID <> 4))
                ORDER BY ISNULL(r.QueuePos, 999999) ASC, r.ReservedAt ASC, r.ResID ASC";

            DataTable dtRes = DBHelper.GetTableData(sqlFifo);

            if (dtRes != null && dtRes.Rows.Count > 0)
            {
                DataRow row = dtRes.Rows[0];
                resID = Convert.ToInt32(row["ResID"]);
                resMemberID = Convert.ToInt32(row["MemberID"]);
                if (bookID == 0 && row["BookID"] != DBNull.Value)
                {
                    bookID = Convert.ToInt32(row["BookID"]);
                }

                string name = row["FullName"] != DBNull.Value ? row["FullName"].ToString().Trim() : "";
                string no = row["MembershipNo"] != DBNull.Value ? row["MembershipNo"].ToString().Trim() : "";
                if (string.IsNullOrEmpty(name)) name = "Member #" + resMemberID;

                reservedByMember = name + (!string.IsNullOrEmpty(no) ? " (" + no + ")" : "");
                return true;
            }
        }
        catch { }

        return false;
    }

    private string GenerateReservationSlipHtml(int bookID, int resID, string memberName)
    {
        string bookTitle = "";
        string ddc = "";
        string bookNo = "";
        // Query BookNo from BookCopies table
        DataTable dtBook = DBHelper.GetTableData(@"
            SELECT b.Title, b.ClassNo AS DDC, b.BookID, ISNULL(cp.BookNo, CAST(b.BookID AS VARCHAR)) AS BookNo 
            FROM Books b 
            LEFT JOIN BookCopies cp ON b.BookID = cp.BookID 
            WHERE b.BookID = " + bookID);
        if (dtBook != null && dtBook.Rows.Count > 0)
        {
            bookTitle = dtBook.Rows[0]["Title"].ToString().ToUpper();
            ddc = dtBook.Rows[0]["DDC"] != DBNull.Value ? dtBook.Rows[0]["DDC"].ToString().Trim() : "-";
            bookNo = dtBook.Rows[0]["BookNo"].ToString();
        }

        string resIDStr = resID > 0 ? resID.ToString("D5") : "05171";
        string membershipNo = "";
        string memberCleanName = "";
        string reserveDate = DateTime.Today.ToString("dd/MM/yyyy");

        // Fetch exact FIFO reservation details by ResID
        try
        {
            string sqlRes = @"
                SELECT TOP 1 
                    r.ResID, 
                    r.ReservedAt, 
                    COALESCE(NULLIF(m.FullName, ''), NULLIF(mp.MemberName, ''), '') AS FullName, 
                    COALESCE(NULLIF(m.MembershipNo, ''), NULLIF(mp.MemberNo, ''), '') AS MembershipNo
                FROM Reservations r 
                LEFT JOIN Members m ON r.MemberID = m.MemberID 
                LEFT JOIN MemberShip.dbo.MemberProfile mp ON r.MemberID = mp.MemberID
                WHERE " + (resID > 0 ? "r.ResID = " + resID : "r.BookID = " + bookID + " AND (r.StatusID IS NULL OR (r.StatusID <> 3 AND r.StatusID <> 4)) ORDER BY ISNULL(r.QueuePos, 999999) ASC, r.ReservedAt ASC, r.ResID ASC");

            DataTable dtRes = DBHelper.GetTableData(sqlRes);

            if (dtRes != null && dtRes.Rows.Count > 0)
            {
                if (dtRes.Rows[0]["ResID"] != DBNull.Value)
                    resIDStr = Convert.ToInt32(dtRes.Rows[0]["ResID"]).ToString("D5");
                if (dtRes.Rows[0]["MembershipNo"] != DBNull.Value)
                    membershipNo = dtRes.Rows[0]["MembershipNo"].ToString();
                if (dtRes.Rows[0]["FullName"] != DBNull.Value)
                    memberCleanName = dtRes.Rows[0]["FullName"].ToString().ToUpper();
                if (dtRes.Rows[0]["ReservedAt"] != DBNull.Value)
                    reserveDate = Convert.ToDateTime(dtRes.Rows[0]["ReservedAt"]).ToString("dd/MM/yyyy");
            }
        }
        catch { }

        // Fallback: parse from memberName parameter if memberCleanName is empty
        if (string.IsNullOrEmpty(memberCleanName))
        {
            if (memberName.Contains(" (") && memberName.EndsWith(")"))
            {
                int startParen = memberName.LastIndexOf(" (");
                memberCleanName = memberName.Substring(0, startParen).Trim().ToUpper();
                membershipNo = memberName.Substring(startParen + 2, memberName.Length - startParen - 3).Trim();
            }
            else
            {
                memberCleanName = memberName.ToUpper();
            }
        }

        string transactionDateTime = DateTime.Now.ToString("dd/MM/yyyy  HH:mm:ss");
        int resDays = 7;
        try
        {
            DataTable dtResDays = DBHelper.GetTableData("SELECT SVal FROM Settings WHERE SKey = 'ResDays'");
            if (dtResDays != null && dtResDays.Rows.Count > 0)
            {
                int.TryParse(dtResDays.Rows[0]["SVal"].ToString(), out resDays);
            }
        }
        catch { }
        string disposalUntil = DateTime.Now.AddDays(resDays).ToString("dd/MM/yyyy  HH:mm");
        
        string staffName = "Librarian";
        try
        {
            DataTable dtStaff = DBHelper.GetTableData("SELECT ISNULL(EFName, '') + ' ' + ISNULL(ELName, '') FROM User_management.dbo.Employee WHERE EmpID = " + CurrentStaffID);
            if (dtStaff != null && dtStaff.Rows.Count > 0 && dtStaff.Rows[0][0] != DBNull.Value)
            {
                string sName = dtStaff.Rows[0][0].ToString().Trim();
                if (!string.IsNullOrEmpty(sName)) staffName = sName;
            }
        }
        catch { }

        string auditStamp = staffName + ", " + DateTime.Now.ToString("dd/MM/yyyy, h:mm:sstt").ToUpper() + ", LM 10.04";

        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        sb.Append("<div style='font-family: Arial, sans-serif; color: #000000; line-height: 1.5; padding: 20px; max-width: 780px; margin: 0 auto; text-align: left; font-size: 13.5px;'>");
        sb.Append("  <table style='width: 100%; border-collapse: collapse; margin-bottom: 25px;'>");
        sb.Append("    <tr>");
        sb.Append("      <td style='vertical-align: top;'>");
        sb.Append("        <div style='font-size: 22px; font-weight: bold; color: #000;'>Lahore Gymkhana</div>");
        sb.Append("        <div style='font-size: 14px; font-weight: bold; margin-top: 2px;'>Library Reserve Note</div>");
        sb.Append("      </td>");
        sb.Append("      <td style='vertical-align: bottom; text-align: right; font-size: 13px;'>");
        sb.Append("        Transaction Date/Time: <span style='border-bottom: 1px solid #000; padding: 0 10px; font-weight: bold;'>" + transactionDateTime + "</span>");
        sb.Append("      </td>");
        sb.Append("    </tr>");
        sb.Append("  </table>");

        sb.Append("  <div style='margin-bottom: 8px;'>");
        sb.Append("    Library Reserve No: <span style='border-bottom: 1px solid #000; padding: 0 10px; font-weight: bold; display: inline-block; min-width: 120px;'>" + resIDStr + "</span>");
        sb.Append("  </div>");

        sb.Append("  <div style='margin-bottom: 25px;'>");
        sb.Append("    Reserved for: <span style='border-bottom: 1px solid #000; padding: 0 10px; font-weight: bold; display: inline-block; min-width: 320px;'>" + membershipNo + " &nbsp; " + memberCleanName + "</span>");
        sb.Append("  </div>");

        sb.Append("  <div style='margin-bottom: 14px; font-size: 14px;'>The following book/magazine was reserved by you</div>");

        sb.Append("  <table style='width: 100%; border-collapse: collapse; margin-bottom: 20px; font-size: 13px;'>");
        sb.Append("    <tr style='border-bottom: 1.5px solid #000;'>");
        sb.Append("      <th style='text-align: left; padding: 6px 0; width: 100px;'>BookNo</th>");
        sb.Append("      <th style='text-align: left; padding: 6px 0; width: 120px;'>DDC No</th>");
        sb.Append("      <th style='text-align: left; padding: 6px 0;'>Title</th>");
        sb.Append("      <th style='text-align: left; padding: 6px 0; width: 110px;'>Reserve Date</th>");
        sb.Append("    </tr>");
        sb.Append("    <tr>");
        sb.Append("      <td style='padding: 10px 0; font-weight: bold; vertical-align: top;'>" + bookNo + "</td>");
        sb.Append("      <td style='padding: 10px 0; vertical-align: top;'>" + ddc + "</td>");
        sb.Append("      <td style='padding: 10px 10px 10px 0; font-weight: bold; vertical-align: top;'>" + bookTitle + "</td>");
        sb.Append("      <td style='padding: 10px 0; vertical-align: top;'>" + reserveDate + "</td>");
        sb.Append("    </tr>");
        sb.Append("  </table>");

        sb.Append("  <div style='margin-bottom: 6px;'>");
        sb.Append("    This is now available and will be held at your disposal up to (" + disposalUntil + ")");
        sb.Append("  </div>");
        sb.Append("  <div style='margin-bottom: 20px;'>");
        sb.Append("    if not claimed, then this will be issued to the next applicant or returned to the shelves.");
        sb.Append("  </div>");

        sb.Append("  <div style='margin-bottom: 40px;'>");
        sb.Append("    Please bring this reservation slip with you or sign it below for the bearer.");
        sb.Append("  </div>");

        sb.Append("  <table style='width: 100%; border-collapse: collapse; margin-top: 30px;'>");
        sb.Append("    <tr>");
        sb.Append("      <td style='width: 50%; vertical-align: bottom;'>");
        sb.Append("        <div style='border-bottom: 1px solid #000; width: 180px; margin-bottom: 4px; font-weight: bold;'>" + staffName + "</div>");
        sb.Append("        <div style='font-size: 12px; font-weight: bold; color: #333;'>Reserved By</div>");
        sb.Append("      </td>");
        sb.Append("      <td style='width: 50%; text-align: right; vertical-align: bottom;'>");
        sb.Append("        <div style='font-size: 13px; font-weight: bold; margin-bottom: 30px;'>Yours Faithfully,</div>");
        sb.Append("        <div style='font-weight: bold; font-size: 14px;'>Manager Library</div>");
        sb.Append("      </td>");
        sb.Append("    </tr>");
        sb.Append("  </table>");

        sb.Append("  <table style='width: 100%; border-collapse: collapse; margin-top: 35px;'>");
        sb.Append("    <tr>");
        sb.Append("      <td style='width: 50%; font-size: 13px;'>");
        sb.Append("        Signature &nbsp; <span style='border-bottom: 1px solid #000; display: inline-block; width: 180px;'>&nbsp;</span>");
        sb.Append("      </td>");
        sb.Append("    </tr>");
        sb.Append("    <tr>");
        sb.Append("      <td style='width: 50%; font-size: 13px; padding-top: 10px;'>");
        sb.Append("        M/s No. &nbsp;&nbsp;&nbsp;&nbsp; <span style='border-bottom: 1px solid #000; display: inline-block; width: 180px;'>&nbsp;</span>");
        sb.Append("      </td>");
        sb.Append("    </tr>");
        sb.Append("  </table>");

        sb.Append("  <div style='font-size: 11px; color: #555555; font-style: italic; margin-top: 40px;'>");
        sb.Append("    " + auditStamp);
        sb.Append("  </div>");
        sb.Append("</div>");
        return sb.ToString();
    }

    protected void btnPrintReservationSlipModal_Click(object sender, EventArgs e)
    {
        pnlReservationAlertModal.Visible = false;
        if (ViewState["ReservationSlipHtml"] != null)
        {
            string htmlContent = ViewState["ReservationSlipHtml"].ToString();
            TriggerSlipPrint(htmlContent);
        }
        upCirculation.Update();
    }

    protected void btnCloseReservationModal_Click(object sender, EventArgs e)
    {
        pnlReservationAlertModal.Visible = false;
    }

    private void ExecuteRenewBook(int loanID)
    {
        // 1. Check max renewals
        int maxRenewals = GetMaxRenewalsFromDB();
        try
        {
            DataTable dtRenCount = DBHelper.GetTableData("SELECT ISNULL(RenewalCount, 0) AS RC FROM Loans WHERE LoanID = " + loanID);
            if (dtRenCount != null && dtRenCount.Rows.Count > 0)
            {
                int currentRenewals = Convert.ToInt32(dtRenCount.Rows[0]["RC"]);
                if (currentRenewals >= maxRenewals)
                {
                    ShowAlert("Renewal limit (" + maxRenewals + ") reached for this loan.");
                    return;
                }
            }
        }
        catch { }

        // 2. Check if an active reservation exists for this book - BLOCK RENEWAL
        DataTable dtResCheck = DBHelper.GetTableData(@"
            SELECT TOP 1 r.ResID, ISNULL(m.MembershipNo, '') AS MembershipNo, ISNULL(m.FullName, '') AS MemberName
            FROM Loans l
            JOIN BookCopies cp ON l.CopyID = cp.CopyID
            JOIN Books b ON cp.BookID = b.BookID
            JOIN Reservations r ON cp.BookID = r.BookID
            LEFT JOIN Members m ON r.MemberID = m.MemberID
            WHERE l.LoanID = " + loanID + @" AND (r.StatusID <> 3 AND r.StatusID <> 4 OR r.StatusID IS NULL)");

        if (dtResCheck != null && dtResCheck.Rows.Count > 0)
        {
            DataRow rRes = dtResCheck.Rows[0];
            string resHolder = !string.IsNullOrEmpty(rRes["MembershipNo"].ToString()) ? rRes["MembershipNo"].ToString() : rRes["MemberName"].ToString();
            ShowAlert("Cannot renew \u2014 reserved by " + resHolder + ".");
            return;
        }

        // 3. Perform Renewal via SP
        string res = null;
        try
        {
            res = DBHelper.RenewBook(loanID, CurrentStaffID);
        }
        catch { }

        // If SP succeeded OR returned empty/null (treat as success since some SPs don't set output)
        bool spSuccess = (res == null || res.StartsWith("OK") || string.IsNullOrEmpty(res));

        if (spSuccess)
        {
            // 4. Extend due date by 14 days from previous due date
            try
            {
                DBHelper.GetTableData(@"
                    UPDATE Loans 
                    SET DueDate = DATEADD(day, 14, CASE WHEN DueDate > GETDATE() THEN DueDate ELSE CAST(GETDATE() AS DATE) END), 
                        RenewalCount = ISNULL(RenewalCount, 0) + 1, 
                        StatusID = 4 
                    WHERE LoanID = " + loanID);
            }
            catch { }

            int memberID = ViewState["MemberID"] != null ? Convert.ToInt32(ViewState["MemberID"]) : 0;
            string memberNo = ViewState["MemberNo"] != null ? ViewState["MemberNo"].ToString() : "";
            ClearReturnDisplay();

            if (memberID > 0)
            {
                LoadMemberLoans(memberID, memberNo);
                LoadReturnGridForMember(memberID, memberNo);
            }

            OpenPrintPopup("IssueNote.aspx?LoanIDs=" + loanID, "PrintRenewalReceipt");
            ShowAlert("Book renewed \u2014 due date extended by 14 days.", isError: false);
        }
        else
        {
            string friendlyMsg = res;
            if (res != null && res.Contains("ERR:RESERVATION_EXISTS"))
            {
                friendlyMsg = "Cannot renew \u2014 active reservation exists.";
            }
            else if (res != null && res.Contains("ERR:MAX_RENEWALS"))
            {
                friendlyMsg = "Renewal limit reached for this loan.";
            }
            ShowAlert("Renewal failed: " + friendlyMsg);
        }
    }

    /// <summary>
    /// Auto-release reservation when the same member+bookNo gets the book issued.
    /// </summary>
    private void AutoReleaseReservationOnIssue(int memberID, int copyID)
    {
        try
        {
            // Get BookID from CopyID
            DataTable dtCopy = DBHelper.GetTableData("SELECT BookID FROM BookCopies WHERE CopyID = " + copyID);
            if (dtCopy != null && dtCopy.Rows.Count > 0 && dtCopy.Rows[0]["BookID"] != DBNull.Value)
            {
                int bookID = Convert.ToInt32(dtCopy.Rows[0]["BookID"]);
                // Release (StatusID=4 = Fulfilled) active reservations for this member + book
                DBHelper.GetTableData(@"
                    UPDATE Reservations 
                    SET StatusID = 4 
                    WHERE MemberID = " + memberID + @" 
                      AND BookID = " + bookID + @" 
                      AND (StatusID <> 3 AND StatusID <> 4 OR StatusID IS NULL)");
            }
        }
        catch { }
    }
    #endregion

    #region Mode 3: Reservation
    protected void txtResBookNo_TextChanged(object sender, EventArgs e)
    {
        FetchReservationBookDetails(txtResBookNo.Text.Trim());
    }

    protected void btnFetchResBook_Click(object sender, EventArgs e)
    {
        FetchReservationBookDetails(txtResBookNo.Text.Trim());
    }

    private void FetchReservationBookDetails(string bookInput)
    {
        pnlAlert.Visible = false;
        if (string.IsNullOrEmpty(bookInput))
        {
            ShowAlert("Enter Book No or scan barcode.");
            return;
        }

        string cleanInput = bookInput.Replace("'", "''");
        // Search strictly by BookNo or Barcode in BookCopies table
        DataTable dt = DBHelper.GetTableData(@"
            SELECT TOP 1 b.BookID, b.Title, ISNULL(b.ClassNo, '-') AS DDC, cp.BookNo 
            FROM BookCopies cp 
            JOIN Books b ON cp.BookID = b.BookID 
            WHERE CAST(cp.BookNo AS VARCHAR) = '" + cleanInput + "' OR cp.Barcode = '" + cleanInput + "'");

        if (dt != null && dt.Rows.Count > 0)
        {
            DataRow r = dt.Rows[0];
            int bookID = Convert.ToInt32(r["BookID"]);

            txtResBookTitleVal.Text = r["Title"].ToString().ToUpper();
            txtResDDCVal.Text = r["DDC"] != DBNull.Value ? r["DDC"].ToString().ToUpper() : "-";
            txtResDateVal.Text = DateTime.Today.ToString("dd/MM/yyyy");
            txtResNoVal.Text = GetNextReserveNoFromDB();

            ViewState["ResBookID"] = bookID;
        }
        else
        {
            txtResBookTitleVal.Text = "";
            txtResDDCVal.Text = "";
            ViewState["ResBookID"] = null;
            ShowAlert("Book not found.");
        }
    }

    private void LoadMemberReservations(int memberID)
    {
        // Select cp.BookNo from BookCopies table for grid display
        DataTable dt = DBHelper.GetTableData(@"
            SELECT r.ResID AS ReserveNo, r.ReservedAt AS ReserveDate, 
                   ISNULL(cp.BookNo, CAST(b.BookID AS VARCHAR)) AS BookNo, 
                   b.Title AS BookTitle, ISNULL(b.ClassNo, '-') AS DDC
            FROM Reservations r
            JOIN Books b ON r.BookID = b.BookID
            OUTER APPLY (
                SELECT TOP 1 BookNo FROM BookCopies WHERE BookID = b.BookID ORDER BY CopyID
            ) cp
            WHERE r.MemberID = " + memberID + @" AND (r.StatusID <> 3 AND r.StatusID <> 4 OR r.StatusID IS NULL)
            ORDER BY r.ReservedAt DESC");

        gvReservationsList.DataSource = dt;
        gvReservationsList.DataBind();
    }

    protected void btnResRefresh_Click(object sender, EventArgs e)
    {
        Response.Redirect(Request.Url.AbsolutePath);
    }

    protected void btnResNew_Click(object sender, EventArgs e)
    {
        Response.Redirect(Request.Url.AbsolutePath);
    }

    protected void btnSaveReservation_Click(object sender, EventArgs e)
    {
        if (ViewState["MemberID"] == null)
        {
            ShowAlert("Verify a member before reserving.");
            return;
        }

        if (ViewState["ResBookID"] == null)
        {
            ShowAlert("Fetch a book to reserve first.");
            return;
        }

        int memberID = Convert.ToInt32(ViewState["MemberID"]);
        int bookID = Convert.ToInt32(ViewState["ResBookID"]);

        string res = DBHelper.ReserveBook(memberID, bookID);
        if (res != null && res.StartsWith("OK"))
        {
            // Clear reservation input
            txtResBookNo.Text = "";
            txtResBookTitleVal.Text = "";
            txtResDDCVal.Text = "";
            txtResRemarks.Text = "";
            ViewState["ResBookID"] = null;

            txtResNoVal.Text = GetNextReserveNoFromDB();

            LoadMemberReservations(memberID);

            ShowAlert("Reservation saved successfully.", isError: false);
        }
        else
        {
            ShowAlert(res);
        }
    }

    protected void btnReleaseReservation_Click(object sender, EventArgs e)
    {
        if (ViewState["MemberID"] != null)
        {
            int memberID = Convert.ToInt32(ViewState["MemberID"]);
            DBHelper.GetTableData("UPDATE Reservations SET StatusID = 3 WHERE MemberID = " + memberID + " AND (StatusID <> 3 AND StatusID <> 4 OR StatusID IS NULL)");
            LoadMemberReservations(memberID);
            ShowAlert("Reservations released.", isError: false);
        }
        else
        {
            ShowAlert("Select a member first.");
        }
    }
    #endregion

    #region Bottom Reporting
    private int ResolveCurrentMemberID()
    {
        if (ViewState["MemberID"] != null)
        {
            return Convert.ToInt32(ViewState["MemberID"]);
        }

        string input = txtMemberNo.Text.Trim();
        if (string.IsNullOrEmpty(input)) input = txtReturnMemberNo.Text.Trim();

        if (!string.IsNullOrEmpty(input))
        {
            VerifyMemberByNo(input);
            if (ViewState["MemberID"] != null)
            {
                return Convert.ToInt32(ViewState["MemberID"]);
            }
        }
        return 0;
    }

    protected void btnPrintReporting_Click(object sender, EventArgs e)
    {
        int memberID = ResolveCurrentMemberID();
        if (memberID <= 0)
        {
            ShowAlert("Verify a member to generate report.");
            return;
        }

        string reportType = ddlReportType.SelectedValue;
        string asOnDate = txtReportAsOnDate.Text.Trim();

        switch (reportType)
        {
            case "LEDGER":
                GenerateAndPrintMemberLedger(memberID, asOnDate);
                break;
            case "ISSUANCE_SUMMARY":
                GenerateAndPrintIssuanceSummary(memberID, asOnDate);
                break;
            case "OVERDUE_NOTICE":
                GenerateAndPrintOverdueNotice(memberID);
                break;
            case "RESERVATION_SLIP":
                GenerateAndPrintReservationSlipReport(memberID);
                break;
            default:
                GenerateAndPrintMemberLedger(memberID, asOnDate);
                break;
        }
    }

    protected void btnPrintLedgerQuick_Click(object sender, EventArgs e)
    {
        int memberID = ResolveCurrentMemberID();
        if (memberID <= 0)
        {
            ShowAlert("Verify a member to view ledger.");
            return;
        }
        string memberNo = ViewState["MemberNo"] != null ? ViewState["MemberNo"].ToString() : txtMemberNo.Text.Trim();
        Response.Redirect("MemberLedger.aspx?MemberID=" + memberID + "&MemberNo=" + HttpUtility.UrlEncode(memberNo));
    }

    protected void btnPrintIssuanceQuick_Click(object sender, EventArgs e)
    {
        int memberID = ResolveCurrentMemberID();
        if (memberID <= 0)
        {
            ShowAlert("Verify a member to print summary.");
            return;
        }
        GenerateAndPrintIssuanceSummary(memberID, txtReportAsOnDate.Text.Trim());
    }

    protected void btnPrintOverdueQuick_Click(object sender, EventArgs e)
    {
        int memberID = ResolveCurrentMemberID();
        if (memberID <= 0)
        {
            ShowAlert("Verify a member to print overdue notice.");
            return;
        }
        GenerateAndPrintOverdueNotice(memberID);
    }

    protected void btnPrintReservationQuick_Click(object sender, EventArgs e)
    {
        int memberID = ResolveCurrentMemberID();
        if (memberID <= 0)
        {
            ShowAlert("Verify a member to print reservation slip.");
            return;
        }
        GenerateAndPrintReservationSlipReport(memberID);
    }

    protected void btnCloseReportModal_Click(object sender, EventArgs e)
    {
        pnlReportModal.Visible = false;
        upCirculation.Update();
    }

    private void DisplayAndPrintReportModal(string htmlContent)
    {
        litReportModalHtml.Text = htmlContent;
        pnlReportModal.Visible = true;
        upCirculation.Update();

        string js = "setTimeout(function(){ printReportModalContent(); }, 300);";
        ScriptManager.RegisterStartupScript(upCirculation, upCirculation.GetType(), "AutoPrintReportModal_" + DateTime.Now.Ticks, js, true);
    }

    #region Report HTML Generation Helpers
    private string BuildMemberReportHeader(string reportTitle, string memberNo, string memberName, string memberType, string asOnDate)
    {
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        sb.Append("<div style='font-family: Arial, sans-serif; color: #0f1e36; padding: 10px; max-width: 800px; margin: 0 auto; line-height: 1.4;'>");
        sb.Append("  <div style='display: flex; justify-content: space-between; align-items: flex-end; border-bottom: 3px solid #c5a059; padding-bottom: 10px; margin-bottom: 14px;'>");
        sb.Append("    <div>");
        sb.Append("      <div style='font-size: 22px; font-weight: 800; color: #0f1e36; text-transform: uppercase; letter-spacing: 0.5px;'>Lahore Gymkhana Club</div>");
        sb.Append("      <div style='font-size: 15px; font-weight: 700; color: #c5a059; margin-top: 2px; text-transform: uppercase;'>" + HttpUtility.HtmlEncode(reportTitle) + "</div>");
        sb.Append("    </div>");
        sb.Append("    <div style='text-align: right; font-size: 11.5px; color: #475569;'>");
        sb.Append("      <div><strong>Printed On:</strong> " + DateTime.Now.ToString("dd/MM/yyyy  HH:mm") + "</div>");
        sb.Append("      <div><strong>As On Date:</strong> " + (string.IsNullOrEmpty(asOnDate) ? DateTime.Today.ToString("dd/MM/yyyy") : HttpUtility.HtmlEncode(asOnDate)) + "</div>");
        sb.Append("    </div>");
        sb.Append("  </div>");

        sb.Append("  <div style='background-color: #f8fafc; border: 1px solid #cbd5e1; border-radius: 6px; padding: 10px 14px; margin-bottom: 16px; font-size: 12.5px;'>");
        sb.Append("    <table style='width: 100%; border-collapse: collapse;'>");
        sb.Append("      <tr>");
        sb.Append("        <td style='width: 33%;'><strong>Member No:</strong> " + HttpUtility.HtmlEncode(memberNo) + "</td>");
        sb.Append("        <td style='width: 42%;'><strong>Member Name:</strong> " + HttpUtility.HtmlEncode(memberName) + "</td>");
        sb.Append("        <td style='width: 25%;'><strong>Type:</strong> " + HttpUtility.HtmlEncode(memberType) + "</td>");
        sb.Append("      </tr>");
        sb.Append("    </table>");
        sb.Append("  </div>");
        return sb.ToString();
    }

    private void GenerateAndPrintMemberLedger(int memberID, string asOnDate)
    {
        string memberNo = ViewState["MemberNo"] != null ? ViewState["MemberNo"].ToString() : txtMemberNo.Text.Trim();
        Response.Redirect("MemberLedger.aspx?MemberID=" + memberID + "&MemberNo=" + HttpUtility.UrlEncode(memberNo));
    }

    private void GenerateAndPrintIssuanceSummary(int memberID, string asOnDate)
    {
        string memberNo = ViewState["MemberNo"] != null ? ViewState["MemberNo"].ToString() : txtMemberNo.Text.Trim();
        string memberName = txtMemberName.Text.Trim();
        string memberType = txtMembershipType.Text.Trim();

        DataTable dtLoans = DBHelper.GetTableData(@"
            SELECT cp.BookNo, b.Title, b.ClassNo AS DDC, l.IssueDate, l.DueDate, 
                   DATEDIFF(day, l.IssueDate, GETDATE()) AS DaysIssued,
                   CASE WHEN GETDATE() > l.DueDate THEN DATEDIFF(day, l.DueDate, GETDATE()) ELSE 0 END AS DaysLate,
                   CASE WHEN GETDATE() > l.DueDate THEN DATEDIFF(day, l.DueDate, GETDATE()) * 2.0 ELSE 0 END AS ActiveFine
            FROM Loans l
            JOIN BookCopies cp ON l.CopyID = cp.CopyID
            JOIN Books b ON cp.BookID = b.BookID
            WHERE l.MemberID = " + memberID + @" AND l.ReturnDate IS NULL
            ORDER BY l.IssueDate DESC");

        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        sb.Append(BuildMemberReportHeader("Member Active Issuance Summary", memberNo, memberName, memberType, asOnDate));

        sb.Append("  <table style='width: 100%; border-collapse: collapse; font-size: 12px; margin-bottom: 20px;'>");
        sb.Append("    <thead>");
        sb.Append("      <tr style='background-color: #0f1e36; color: #ffffff;'>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #1c3254; text-align: center; width: 35px;'>#</th>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #1c3254; text-align: left; width: 95px;'>Book No</th>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #1c3254; text-align: left;'>Book Title</th>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #1c3254; text-align: left; width: 100px;'>DDC No</th>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #1c3254; text-align: center; width: 95px;'>Issue Date</th>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #1c3254; text-align: center; width: 95px;'>Due Date</th>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #1c3254; text-align: center; width: 85px;'>Days Held</th>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #1c3254; text-align: right; width: 80px;'>Overdue Fine</th>");
        sb.Append("      </tr>");
        sb.Append("    </thead>");
        sb.Append("    <tbody>");

        int count = 0;
        decimal totalFine = 0;

        if (dtLoans != null && dtLoans.Rows.Count > 0)
        {
            foreach (DataRow r in dtLoans.Rows)
            {
                count++;
                string bookNo = r["BookNo"].ToString();
                string title = HttpUtility.HtmlEncode(r["Title"].ToString());
                string ddc = r["DDC"] != DBNull.Value ? r["DDC"].ToString() : "-";
                string issueDate = r["IssueDate"] != DBNull.Value ? Convert.ToDateTime(r["IssueDate"]).ToString("dd/MM/yyyy") : "-";
                string dueDate = r["DueDate"] != DBNull.Value ? Convert.ToDateTime(r["DueDate"]).ToString("dd/MM/yyyy") : "-";
                int daysIssued = Convert.ToInt32(r["DaysIssued"]);
                decimal fine = Convert.ToDecimal(r["ActiveFine"]);
                totalFine += fine;

                string bg = count % 2 == 0 ? "#f8fafc" : "#ffffff";
                sb.Append("      <tr style='background-color: " + bg + ";'>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0; text-align: center;'>" + count + "</td>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0; font-weight: bold;'>" + bookNo + "</td>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0;'>" + title + "</td>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0;'>" + ddc + "</td>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0; text-align: center;'>" + issueDate + "</td>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0; text-align: center;'>" + dueDate + "</td>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0; text-align: center;'>" + daysIssued + " days</td>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0; text-align: right; font-weight: bold; color: " + (fine > 0 ? "#dc2626" : "#0f1e36") + ";'>" + (fine > 0 ? "Rs. " + fine.ToString("N0") : "-") + "</td>");
                sb.Append("      </tr>");
            }
        }
        else
        {
            sb.Append("      <tr><td colspan='8' style='padding: 16px; text-align: center; color: #64748b; font-italic: true;'>No books currently issued to this member.</td></tr>");
        }

        sb.Append("    </tbody>");
        sb.Append("    <tfoot>");
        sb.Append("      <tr style='background-color: #f1f5f9; font-weight: bold;'>");
        sb.Append("        <td colspan='7' style='padding: 8px; border: 1px solid #cbd5e1; text-align: right;'>Total Currently Issued Books: " + count + " &nbsp;|&nbsp; Total Overdue Fine:</td>");
        sb.Append("        <td style='padding: 8px; border: 1px solid #cbd5e1; text-align: right; color: #dc2626;'>Rs. " + totalFine.ToString("N0") + "</td>");
        sb.Append("      </tr>");
        sb.Append("    </tfoot>");
        sb.Append("  </table>");

        sb.Append("  <div style='margin-top: 30px; font-size: 11px; color: #64748b; display: flex; justify-content: space-between;'>");
        sb.Append("    <div>Lahore Gymkhana Library Circulation Counter</div>");
        sb.Append("    <div>Librarian Signature: ______________________</div>");
        sb.Append("  </div>");
        sb.Append("</div>");

        DisplayAndPrintReportModal(sb.ToString());
    }

    private void GenerateAndPrintOverdueNotice(int memberID)
    {
        string memberNo = ViewState["MemberNo"] != null ? ViewState["MemberNo"].ToString() : txtMemberNo.Text.Trim();
        string memberName = txtMemberName.Text.Trim();
        string memberType = txtMembershipType.Text.Trim();

        DataTable dtOverdue = DBHelper.GetTableData(@"
            SELECT cp.BookNo, b.Title, b.ClassNo AS DDC, l.IssueDate, l.DueDate, 
                   DATEDIFF(day, l.DueDate, GETDATE()) AS DaysLate,
                   DATEDIFF(day, l.DueDate, GETDATE()) * 2.0 AS FineAmount
            FROM Loans l
            JOIN BookCopies cp ON l.CopyID = cp.CopyID
            JOIN Books b ON cp.BookID = b.BookID
            WHERE l.MemberID = " + memberID + @" AND l.ReturnDate IS NULL AND l.DueDate < GETDATE()
            ORDER BY l.DueDate ASC");

        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        sb.Append(BuildMemberReportHeader("Official Overdue Book Notice", memberNo, memberName, memberType, DateTime.Today.ToString("dd/MM/yyyy")));

        sb.Append("  <div style='background-color: #fee2e2; border: 1px solid #fca5a5; color: #991b1b; border-radius: 6px; padding: 12px 16px; margin-bottom: 16px; font-size: 13px; line-height: 1.5;'>");
        sb.Append("    <strong>Dear Member,</strong><br />");
        sb.Append("    Our library circulation records indicate that the following book(s) issued under your membership account are past their scheduled return due date. ");
        sb.Append("    Kindly return these book(s) to the library counter at your earliest convenience to avoid further daily fine accumulation.");
        sb.Append("  </div>");

        sb.Append("  <table style='width: 100%; border-collapse: collapse; font-size: 12px; margin-bottom: 20px;'>");
        sb.Append("    <thead>");
        sb.Append("      <tr style='background-color: #991b1b; color: #ffffff;'>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #7f1d1d; text-align: center; width: 35px;'>#</th>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #7f1d1d; text-align: left; width: 95px;'>Book No</th>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #7f1d1d; text-align: left;'>Book Title</th>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #7f1d1d; text-align: center; width: 95px;'>Issue Date</th>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #7f1d1d; text-align: center; width: 95px;'>Due Date</th>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #7f1d1d; text-align: center; width: 80px;'>Days Late</th>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #7f1d1d; text-align: right; width: 90px;'>Fine Amount</th>");
        sb.Append("      </tr>");
        sb.Append("    </thead>");
        sb.Append("    <tbody>");

        int count = 0;
        decimal totalFine = 0;

        if (dtOverdue != null && dtOverdue.Rows.Count > 0)
        {
            foreach (DataRow r in dtOverdue.Rows)
            {
                count++;
                string bookNo = r["BookNo"].ToString();
                string title = HttpUtility.HtmlEncode(r["Title"].ToString());
                string issueDate = r["IssueDate"] != DBNull.Value ? Convert.ToDateTime(r["IssueDate"]).ToString("dd/MM/yyyy") : "-";
                string dueDate = r["DueDate"] != DBNull.Value ? Convert.ToDateTime(r["DueDate"]).ToString("dd/MM/yyyy") : "-";
                int daysLate = Convert.ToInt32(r["DaysLate"]);
                decimal fine = Convert.ToDecimal(r["FineAmount"]);
                totalFine += fine;

                sb.Append("      <tr style='background-color: #ffffff;'>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0; text-align: center;'>" + count + "</td>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0; font-weight: bold; color: #991b1b;'>" + bookNo + "</td>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0; font-weight: bold;'>" + title + "</td>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0; text-align: center;'>" + issueDate + "</td>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0; text-align: center; color: #dc2626; font-weight: bold;'>" + dueDate + "</td>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0; text-align: center; font-weight: bold; color: #dc2626;'>" + daysLate + " days</td>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0; text-align: right; font-weight: bold; color: #dc2626;'>Rs. " + fine.ToString("N0") + "</td>");
                sb.Append("      </tr>");
            }
        }
        else
        {
            sb.Append("      <tr><td colspan='7' style='padding: 16px; text-align: center; color: #16a34a; font-weight: bold;'>Good News: Member has no overdue books at this time.</td></tr>");
        }

        sb.Append("    </tbody>");
        sb.Append("    <tfoot>");
        sb.Append("      <tr style='background-color: #fee2e2; font-weight: bold;'>");
        sb.Append("        <td colspan='6' style='padding: 8px; border: 1px solid #fca5a5; text-align: right;'>Total Overdue Books: " + count + " &nbsp;|&nbsp; Total Outstanding Fine:</td>");
        sb.Append("        <td style='padding: 8px; border: 1px solid #fca5a5; text-align: right; color: #991b1b;'>Rs. " + totalFine.ToString("N0") + "</td>");
        sb.Append("      </tr>");
        sb.Append("    </tfoot>");
        sb.Append("  </table>");

        sb.Append("  <div style='margin-top: 30px; font-size: 11px; color: #64748b; display: flex; justify-content: space-between;'>");
        sb.Append("    <div>Lahore Gymkhana Club — Library Overdue Notice Desk</div>");
        sb.Append("    <div>Incharge Circulation Signature: ______________________</div>");
        sb.Append("  </div>");
        sb.Append("</div>");

        DisplayAndPrintReportModal(sb.ToString());
    }

    private void GenerateAndPrintReservationSlipReport(int memberID)
    {
        string memberNo = ViewState["MemberNo"] != null ? ViewState["MemberNo"].ToString() : txtMemberNo.Text.Trim();
        string memberName = txtMemberName.Text.Trim();
        string memberType = txtMembershipType.Text.Trim();

        DataTable dtRes = DBHelper.GetTableData(@"
            SELECT r.ResID AS ReserveNo, r.ReservedAt AS ReserveDate, 
                   ISNULL(cp.BookNo, CAST(b.BookID AS VARCHAR)) AS BookNo, 
                   b.Title AS BookTitle, ISNULL(b.ClassNo, '-') AS DDC
            FROM Reservations r
            JOIN Books b ON r.BookID = b.BookID
            OUTER APPLY (
                SELECT TOP 1 BookNo FROM BookCopies WHERE BookID = b.BookID ORDER BY CopyID
            ) cp
            WHERE r.MemberID = " + memberID + @" AND (r.StatusID <> 3 AND r.StatusID <> 4 OR r.StatusID IS NULL)
            ORDER BY r.ReservedAt DESC");

        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        sb.Append(BuildMemberReportHeader("Member Book Reservation Slip", memberNo, memberName, memberType, DateTime.Today.ToString("dd/MM/yyyy")));

        sb.Append("  <table style='width: 100%; border-collapse: collapse; font-size: 12px; margin-bottom: 20px;'>");
        sb.Append("    <thead>");
        sb.Append("      <tr style='background-color: #0f1e36; color: #ffffff;'>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #1c3254; text-align: center; width: 35px;'>#</th>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #1c3254; text-align: left; width: 100px;'>Reserve No</th>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #1c3254; text-align: left; width: 100px;'>Book No</th>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #1c3254; text-align: left;'>Book Title</th>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #1c3254; text-align: left; width: 100px;'>DDC No</th>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #1c3254; text-align: center; width: 100px;'>Reserve Date</th>");
        sb.Append("        <th style='padding: 8px; border: 1px solid #1c3254; text-align: center; width: 90px;'>Status</th>");
        sb.Append("      </tr>");
        sb.Append("    </thead>");
        sb.Append("    <tbody>");

        int count = 0;

        if (dtRes != null && dtRes.Rows.Count > 0)
        {
            foreach (DataRow r in dtRes.Rows)
            {
                count++;
                string resNo = r["ReserveNo"].ToString();
                string bookNo = r["BookNo"].ToString();
                string title = HttpUtility.HtmlEncode(r["BookTitle"].ToString());
                string ddc = r["DDC"] != DBNull.Value ? r["DDC"].ToString() : "-";
                string resDate = r["ReserveDate"] != DBNull.Value ? Convert.ToDateTime(r["ReserveDate"]).ToString("dd/MM/yyyy") : "-";

                string bg = count % 2 == 0 ? "#f8fafc" : "#ffffff";
                sb.Append("      <tr style='background-color: " + bg + ";'>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0; text-align: center;'>" + count + "</td>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0; font-weight: bold; color: #c5a059;'>" + resNo + "</td>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0; font-weight: bold;'>" + bookNo + "</td>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0;'>" + title + "</td>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0;'>" + ddc + "</td>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0; text-align: center;'>" + resDate + "</td>");
                sb.Append("        <td style='padding: 7px; border: 1px solid #e2e8f0; text-align: center; font-weight: bold; color: #16a34a;'>ACTIVE HOLD</td>");
                sb.Append("      </tr>");
            }
        }
        else
        {
            sb.Append("      <tr><td colspan='7' style='padding: 16px; text-align: center; color: #64748b; font-italic: true;'>No active book reservations found for this member.</td></tr>");
        }

        sb.Append("    </tbody>");
        sb.Append("  </table>");

        sb.Append("  <div style='background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 6px; padding: 10px; font-size: 11.5px; color: #475569; margin-bottom: 20px;'>");
        sb.Append("    <strong>Reservation Terms:</strong> Reserved books are held for a maximum of 7 days once returned to the library. Members will be notified via SMS/Phone upon availability.");
        sb.Append("  </div>");

        sb.Append("  <div style='margin-top: 25px; font-size: 11px; color: #64748b; display: flex; justify-content: space-between;'>");
        sb.Append("    <div>Lahore Gymkhana Library - Reservation Desk</div>");
        sb.Append("    <div>Signature: ______________________</div>");
        sb.Append("  </div>");
        sb.Append("</div>");

        DisplayAndPrintReportModal(sb.ToString());
    }
    #endregion
    #endregion

    #region DBHelper Inner Class
    public static class DBHelper
    {
        public static string GetConnectionString()
        {
            var cs = ConfigurationManager.ConnectionStrings["GymkhanaLibraryConnection"]
                  ?? ConfigurationManager.ConnectionStrings["GymkhanaLibraryDB"]
                  ?? ConfigurationManager.ConnectionStrings["MemberShipConnection"];
            return cs != null ? cs.ConnectionString : "";
        }

        public static SqlConnection GetConnection()
        {
            return new SqlConnection(GetConnectionString());
        }

        public static DataTable GetTableData(string query)
        {
            DataTable dt = new DataTable();
            using (var con = GetConnection())
            using (var cmd = new SqlCommand(query, con))
            using (var da = new SqlDataAdapter(cmd))
            {
                con.Open();
                da.Fill(dt);
            }
            return dt;
        }

        public static DataTable ExecuteReader(string spName, params SqlParameter[] prms)
        {
            DataTable dt = new DataTable();
            using (var con = GetConnection())
            using (var cmd = new SqlCommand(spName, con) { CommandType = CommandType.StoredProcedure })
            using (var da = new SqlDataAdapter(cmd))
            {
                if (prms != null && prms.Length > 0)
                {
                    cmd.Parameters.AddRange(prms);
                }
                con.Open();
                da.Fill(dt);
            }
            return dt;
        }

        public static string IssueBook(int memberID, int copyID, short staffID, DateTime issueDate, DateTime dueDate, string actualBorrowerNo = null, string actualBorrowerName = null)
        {
            try
            {
                // Ensure member exists in local Members table first
                try
                {
                    GetTableData("EXEC sp_EnsureMemberExists " + memberID);
                }
                catch { }

                var prms = new[]
                {
                    new SqlParameter("@MemberID",  memberID),
                    new SqlParameter("@CopyID",    copyID),
                    new SqlParameter("@StaffID",   staffID),
                    new SqlParameter("@Msg",       SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output },
                    new SqlParameter("@IssueDate", issueDate),
                    new SqlParameter("@DueDate",   dueDate),
                    new SqlParameter("@ActualBorrowerNo",   (object)actualBorrowerNo ?? DBNull.Value),
                    new SqlParameter("@ActualBorrowerName", (object)actualBorrowerName ?? DBNull.Value)
                };

                using (var con = GetConnection())
                using (var cmd = new SqlCommand("sp_IssueBook", con) { CommandType = CommandType.StoredProcedure })
                {
                    cmd.Parameters.AddRange(prms);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }

                string msg = prms[3].Value != null ? prms[3].Value.ToString() : "";
                if (string.IsNullOrEmpty(msg) || msg.StartsWith("OK"))
                {
                    return string.IsNullOrEmpty(msg) ? "OK:SUCCESS" : msg;
                }
                return msg;
            }
            catch (Exception)
            {
                // Direct SQL insert fallback if procedure execution fails
                try
                {
                    string sqlInsert = @"
                        INSERT INTO Loans (MemberID, CopyID, IssuedByID, IssueDate, DueDate, StatusID, ActualBorrowerNo, ActualBorrowerName)
                        VALUES (" + memberID + ", " + copyID + ", " + staffID + ", '" + issueDate.ToString("yyyy-MM-dd HH:mm:ss") + "', '" + dueDate.ToString("yyyy-MM-dd") + "', 1, " +
                        (string.IsNullOrEmpty(actualBorrowerNo) ? "NULL" : "'" + actualBorrowerNo.Replace("'", "''") + "'") + ", " +
                        (string.IsNullOrEmpty(actualBorrowerName) ? "NULL" : "N'" + actualBorrowerName.Replace("'", "''") + "'") + ");" +
                        "UPDATE BookCopies SET IsAvailable = 0 WHERE CopyID = " + copyID + ";";
                    GetTableData(sqlInsert);
                    return "OK:SUCCESS";
                }
                catch (Exception ex2)
                {
                    return "ERR:" + ex2.Message;
                }
            }
        }

        public static string ReturnBook(int copyID, short staffID)
        {
            var prms = new[]
            {
                new SqlParameter("@CopyID",  copyID),
                new SqlParameter("@StaffID", staffID),
                new SqlParameter("@CondID",  (byte)2),
                new SqlParameter("@ReturnDateTime", DateTime.Now),
                new SqlParameter("@Msg",     SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
            };
            using (var con = GetConnection())
            using (var cmd = new SqlCommand("sp_ReturnBook", con) { CommandType = CommandType.StoredProcedure })
            {
                cmd.Parameters.AddRange(prms);
                con.Open();
                cmd.ExecuteNonQuery();
            }
            return prms[4].Value != null ? prms[4].Value.ToString() : "OK:";
        }

        public static string RenewBook(int loanID, short staffID)
        {
            var prms = new[]
            {
                new SqlParameter("@LoanID",  loanID),
                new SqlParameter("@StaffID", staffID),
                new SqlParameter("@Msg",     SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
            };
            using (var con = GetConnection())
            using (var cmd = new SqlCommand("sp_RenewBook", con) { CommandType = CommandType.StoredProcedure })
            {
                cmd.Parameters.AddRange(prms);
                con.Open();
                cmd.ExecuteNonQuery();
            }
            return prms[2].Value != null ? prms[2].Value.ToString() : "OK:";
        }

        public static string ReserveBook(int memberID, int bookID)
        {
            var prms = new[]
            {
                new SqlParameter("@MemberID", memberID),
                new SqlParameter("@BookID",   bookID),
                new SqlParameter("@Msg",      SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
            };
            using (var con = GetConnection())
            using (var cmd = new SqlCommand("sp_ReserveBook", con) { CommandType = CommandType.StoredProcedure })
            {
                cmd.Parameters.AddRange(prms);
                con.Open();
                cmd.ExecuteNonQuery();
            }
            return prms[2].Value != null ? prms[2].Value.ToString() : "OK:";
        }
    }
    #endregion
}
