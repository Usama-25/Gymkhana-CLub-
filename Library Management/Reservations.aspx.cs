using System.Configuration;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Pages_Circulation_Reservations : System.Web.UI.Page
{
    private short CurrentStaffID = 1;
    private DataTable activeReservationsDt;

    protected void Page_Load(object sender, EventArgs e)
    {
        pnlAlert.Visible = false;

        // Retrieve librarian ID from Session
        if (Session["StaffID"] != null)
        {
            CurrentStaffID = Convert.ToInt16(Session["StaffID"]);
        }

        if (!IsPostBack)
        {
            BindMembersDropdown();
            
            // Check for book pre-selection in query string
            int selectBookID = 0;
            if (Request.QueryString["BookID"] != null && int.TryParse(Request.QueryString["BookID"], out selectBookID))
            {
                BindBookCatalogDropdown(null, selectBookID);
                try { ddlBookCatalog.SelectedValue = selectBookID.ToString(); } catch { }
                UpdateForecastPreview();
            }
            else
            {
                BindBookCatalogDropdown();
            }

            BindActiveReservations();
            PopulateFilterDropdowns();

            // Default dates
            txtStartDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            int resDays = 7;
            DataTable dtResDays = DBHelper.GetTableData("SELECT SVal FROM Settings WHERE SKey = 'ResDays'");
            if (dtResDays.Rows.Count > 0) int.TryParse(dtResDays.Rows[0]["SVal"].ToString(), out resDays);
            txtEndDate.Text = DateTime.Today.AddDays(resDays).ToString("yyyy-MM-dd");

            BindBasket();
        }
    }

    private void BindMembersDropdown(string search = null)
    {
        ddlMember.Items.Clear();
        ddlMember.ClearSelection();
        ddlMember.SelectedIndex = -1;
        ddlMember.SelectedValue = null;

        DataTable dt = DBHelper.GetMembers(search);
        ddlMember.DataSource = dt;
        ddlMember.DataTextField = "MemberDisplay";
        ddlMember.DataValueField = "UniqueMemberValue";
        ddlMember.DataBind();

        if (string.IsNullOrEmpty(search))
        {
            ddlMember.Items.Insert(0, new ListItem("- Select Club Member -", "0"));
        }
        else
        {
            ddlMember.Items.Insert(0, new ListItem("- Select Club Member (" + dt.Rows.Count + " matches) -", "0"));
        }
        UpdateMemberNameField();
    }

    private void BindBookCatalogDropdown(string search = null, int? selectBookID = null)
    {
        string query;
        if (selectBookID.HasValue)
        {
            query = @"
                SELECT BookID, Title FROM Books WHERE BookID = " + selectBookID.Value + @"
                UNION
                SELECT TOP 100 BookID, Title FROM Books WHERE IsActive = 1 ORDER BY Title";
        }
        else if (string.IsNullOrEmpty(search))
        {
            query = "SELECT TOP 100 BookID, Title FROM Books WHERE IsActive = 1 ORDER BY Title";
        }
        else
        {
            query = @"
                SELECT DISTINCT TOP 200 b.BookID, b.Title 
                FROM Books b 
                LEFT JOIN BookCopies cp ON b.BookID = cp.BookID
                WHERE b.IsActive = 1 AND (
                       b.Title LIKE '%" + search.Replace("'", "''") + @"%' 
                    OR b.ISBN13 LIKE '%" + search.Replace("'", "''") + @"%' 
                    OR b.ISBN10 LIKE '%" + search.Replace("'", "''") + @"%' 
                    OR b.DDC LIKE '%" + search.Replace("'", "''") + @"%' 
                    OR b.AcqNo LIKE '%" + search.Replace("'", "''") + @"%' 
                    OR CAST(b.BookID AS VARCHAR(15)) LIKE '%" + search.Replace("'", "''") + @"%'
                    OR cp.Barcode LIKE '%" + search.Replace("'", "''") + @"%'
                    OR CAST(cp.BookNo AS VARCHAR(15)) LIKE '%" + search.Replace("'", "''") + @"%'
                ) 
                ORDER BY b.Title";
        }

        DataTable dt = DBHelper.GetTableData(query);
        ddlBookCatalog.Items.Clear();
        ddlBookCatalog.ClearSelection();
        ddlBookCatalog.SelectedIndex = -1;

        if (string.IsNullOrEmpty(search))
        {
            ddlBookCatalog.Items.Add(new ListItem("- Select Book -", "0"));
        }
        else
        {
            ddlBookCatalog.Items.Add(new ListItem("- Select Book (" + dt.Rows.Count + " matches) -", "0"));
        }

        ddlBookCatalog.AppendDataBoundItems = true;
        ddlBookCatalog.DataSource = dt;
        ddlBookCatalog.DataTextField = "Title";
        ddlBookCatalog.DataValueField = "BookID";
        ddlBookCatalog.DataBind();
        ddlBookCatalog.AppendDataBoundItems = false;
    }

    private void BindActiveReservations()
    {
        int? memberID = null;
        int? bookID = null;

        if (ddlFilterMember.SelectedValue != "0" && !string.IsNullOrEmpty(ddlFilterMember.SelectedValue))
        {
            memberID = Convert.ToInt32(ddlFilterMember.SelectedValue);
        }
        if (ddlFilterBook.SelectedValue != "0" && !string.IsNullOrEmpty(ddlFilterBook.SelectedValue))
        {
            bookID = Convert.ToInt32(ddlFilterBook.SelectedValue);
        }

        activeReservationsDt = DBHelper.GetActiveReservations(memberID, bookID);
        gvReservations.DataSource = activeReservationsDt;
        gvReservations.DataBind();

        // Update active reservations counter label
        if (activeReservationsDt != null)
        {
            lblTotalActiveReservations.Text = activeReservationsDt.Rows.Count.ToString();
        }
        else
        {
            lblTotalActiveReservations.Text = "0";
        }
    }

    private void PopulateFilterDropdowns()
    {
        // Get all active reservations without filters to build dropdown list
        DataTable dtAll = DBHelper.GetActiveReservations(null, null);

        // Populate Book Filter
        ddlFilterBook.Items.Clear();
        ddlFilterBook.Items.Add(new ListItem("- Filter by Book -", "0"));
        
        // Populate Member Filter
        ddlFilterMember.Items.Clear();
        ddlFilterMember.Items.Add(new ListItem("- Filter by Member -", "0"));

        if (dtAll != null && dtAll.Rows.Count > 0)
        {
            DataTable uniqueBooks = dtAll.DefaultView.ToTable(true, "BookID", "BookTitle");
            foreach (DataRow row in uniqueBooks.Rows)
            {
                ddlFilterBook.Items.Add(new ListItem(row["BookTitle"].ToString(), row["BookID"].ToString()));
            }

            DataTable uniqueMembers = dtAll.DefaultView.ToTable(true, "MemberID", "MemberName");
            foreach (DataRow row in uniqueMembers.Rows)
            {
                ddlFilterMember.Items.Add(new ListItem(row["MemberName"].ToString(), row["MemberID"].ToString()));
            }
        }
    }

    protected void btnSearchMember_Click(object sender, EventArgs e)
    {
        string term = txtMemberSearch.Text.Trim();
        string searchKey = term;
        if (searchKey.Contains(" - "))
        {
            searchKey = searchKey.Split(new string[] { " - " }, StringSplitOptions.None)[0].Trim();
        }

        BindMembersDropdown(searchKey);

        // Auto-select first matching member (same behavior as IssueReturn page)
        DataTable dt = DBHelper.GetMembers(searchKey);
        if (dt != null && dt.Rows.Count > 0)
        {
            string autoSelectValue = null;
            foreach (DataRow row in dt.Rows)
            {
                string display = row["MemberDisplay"].ToString();
                if (display.IndexOf(term, StringComparison.OrdinalIgnoreCase) >= 0 || term.IndexOf(display, StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    autoSelectValue = row["UniqueMemberValue"].ToString();
                    break;
                }
            }

            if (autoSelectValue == null)
            {
                DataRow[] mainMembers = dt.Select("Priority = 1");
                if (mainMembers.Length > 0)
                {
                    autoSelectValue = mainMembers[0]["UniqueMemberValue"].ToString();
                }
                else if (dt.Rows.Count == 1)
                {
                    autoSelectValue = dt.Rows[0]["UniqueMemberValue"].ToString();
                }
            }

            if (autoSelectValue != null)
            {
                ddlMember.SelectedValue = autoSelectValue;
                BasketTable = null;
                BindBasket();
            }
        }
        UpdateMemberNameField();
    }

    protected void txtMemberSearch_TextChanged(object sender, EventArgs e)
    {
        btnSearchMember_Click(sender, e);
    }

    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        Response.Redirect(Request.RawUrl);
    }

    private void UpdateMemberNameField()
    {
        if (txtMemberName == null) return;
        if (ddlMember.SelectedItem != null && ddlMember.SelectedValue != "0" && !string.IsNullOrEmpty(ddlMember.SelectedValue))
        {
            string selectedText = ddlMember.SelectedItem.Text;
            if (selectedText.Contains(" - "))
            {
                int dashIndex = selectedText.IndexOf(" - ");
                string rest = selectedText.Substring(dashIndex + 3).Trim();
                if (rest.Contains(" (") && rest.EndsWith(")"))
                {
                    int suffixIndex = rest.LastIndexOf(" (");
                    txtMemberName.Text = rest.Substring(0, suffixIndex).Trim();
                }
                else
                {
                    txtMemberName.Text = rest;
                }
            }
            else
            {
                txtMemberName.Text = selectedText;
            }
        }
        else
        {
            txtMemberName.Text = "";
        }
    }

    protected void btnSearchBook_Click(object sender, EventArgs e)
    {
        string search = txtBookSearch.Text.Trim();
        if (search.Contains(" ["))
        {
            search = search.Split(new string[] { " [" }, StringSplitOptions.None)[0].Trim();
        }
        BindBookCatalogDropdown(search);
        pnlForecastPreview.Visible = false;
    }

    protected void ddlBookCatalog_Changed(object sender, EventArgs e)
    {
        UpdateForecastPreview();
    }

    protected void txtReservationDate_TextChanged(object sender, EventArgs e)
    {
        UpdateForecastPreview();
    }

    private void UpdateForecastPreview()
    {
        if (ddlBookCatalog.SelectedValue == "0" || string.IsNullOrEmpty(ddlBookCatalog.SelectedValue))
        {
            pnlForecastPreview.Visible = false;
            return;
        }

        int bookID = Convert.ToInt32(ddlBookCatalog.SelectedValue);
        
        DateTime startDate = DateTime.Today;
        DateTime endDate = DateTime.Today.AddDays(7);
        
        if (!DateTime.TryParse(txtStartDate.Text, out startDate))
        {
            startDate = DateTime.Today;
        }
        if (!DateTime.TryParse(txtEndDate.Text, out endDate))
        {
            endDate = startDate.AddDays(7);
        }

        if (endDate < startDate)
        {
            lblForecastDate.Text = "Invalid range: End Date is before Start Date";
            lblForecastDate.Attributes["style"] = "font-size: 14px; color: #ef4444; font-weight: bold;";
            pnlForecastPreview.Visible = true;
            return;
        }

        // 1. Total usable copies
        object tCopies = DBHelper.GetTableData("SELECT COUNT(*) FROM BookCopies WHERE BookID = " + bookID + " AND CondID NOT IN (5,6)").Rows[0][0];
        int totalCopies = tCopies != DBNull.Value ? Convert.ToInt32(tCopies) : 0;
        
        // 2. Available copies today
        object aCopies = DBHelper.GetTableData("SELECT COUNT(*) FROM BookCopies WHERE BookID = " + bookID + " AND IsAvailable = 1 AND CondID NOT IN (5,6)").Rows[0][0];
        int availCopies = aCopies != DBNull.Value ? Convert.ToInt32(aCopies) : 0;

        // 3. Queue size
        object qSize = DBHelper.GetTableData("SELECT COUNT(*) FROM Reservations WHERE BookID = " + bookID + " AND StatusID = 1").Rows[0][0];
        int queueSize = qSize != DBNull.Value ? Convert.ToInt32(qSize) : 0;

        // 4. Verify range availability via DBHelper
        bool isAvailable = DBHelper.CheckBookAvailabilityForRange(bookID, startDate, endDate);

        lblTotalCopies.Text = totalCopies.ToString() + " copy/copies";
        lblAvailableCopies.Text = availCopies.ToString() + " copy/copies";
        lblQueueSize.Text = queueSize.ToString() + " active member(s)";

        if (isAvailable)
        {
            lblForecastDate.Text = "âœ“ Available: No conflicts found for this range";
            lblForecastDate.Attributes["style"] = "font-size: 14px; color: #065f46; font-weight: bold;";
        }
        else
        {
            lblForecastDate.Text = "âš  Conflicted: Copy limit reached during this range";
            lblForecastDate.Attributes["style"] = "font-size: 14px; color: #991b1b; font-weight: bold;";
        }

        pnlForecastPreview.Visible = true;
    }

    private DataTable BasketTable
    {
        get
        {
            DataTable dt = ViewState["ReservationBasket"] as DataTable;
            if (dt == null)
            {
                dt = new DataTable();
                dt.Columns.Add("BookID", typeof(int));
                dt.Columns.Add("Title", typeof(string));
                dt.Columns.Add("StartDate", typeof(DateTime));
                dt.Columns.Add("EndDate", typeof(DateTime));
                ViewState["ReservationBasket"] = dt;
            }
            return dt;
        }
        set
        {
            ViewState["ReservationBasket"] = value;
        }
    }

    private void BindBasket()
    {
        DataTable dt = BasketTable;
        gvBasket.DataSource = dt;
        gvBasket.DataBind();

        bool hasItems = dt != null && dt.Rows.Count > 0;
        pnlBasketEmpty.Visible = !hasItems;
        divConfirmReservations.Style["display"] = hasItems ? "block" : "none";
    }

    protected void ddlMember_SelectedIndexChanged(object sender, EventArgs e)
    {
        BasketTable = null;
        BindBasket();
        UpdateMemberNameField();
    }

    protected void btnAddToBasket_Click(object sender, EventArgs e)
    {
        if (ddlMember.SelectedValue == "0" || string.IsNullOrEmpty(ddlMember.SelectedValue))
        {
            ShowAlert("Please select a valid member.", "error");
            return;
        }

        int memberIDVal = GetMemberIDFromValue(ddlMember.SelectedValue);
        if (memberIDVal <= 0)
        {
            ShowAlert("Invalid member selection.", "error");
            return;
        }

        if (ddlBookCatalog.SelectedValue == "0" || string.IsNullOrEmpty(ddlBookCatalog.SelectedValue))
        {
            ShowAlert("Please select a valid book title.", "error");
            return;
        }

        int memberID = GetMemberIDFromValue(ddlMember.SelectedValue);
        int bookID = Convert.ToInt32(ddlBookCatalog.SelectedValue);

        DateTime startDate;
        DateTime endDate;

        if (!DateTime.TryParse(txtStartDate.Text, out startDate) || !DateTime.TryParse(txtEndDate.Text, out endDate))
        {
            ShowAlert("Please enter valid start and end dates.", "error");
            return;
        }

        if (startDate < DateTime.Today)
        {
            ShowAlert("The Start Date cannot be in the past.", "error");
            return;
        }

        if (endDate < startDate)
        {
            ShowAlert("The End Date cannot be earlier than the Start Date.", "error");
            return;
        }

        // Strictly verify that the book has all its copies on loan
        DataTable dtCopiesCount = DBHelper.GetTableData(@"
            SELECT 
                COUNT(*) as Total,
                SUM(CASE WHEN IsAvailable = 1 THEN 1 ELSE 0 END) as Available
            FROM BookCopies 
            WHERE BookID = " + bookID + " AND CondID NOT IN (5,6)");
        
        int totalCopies = 0;
        int availableCopies = 0;
        if (dtCopiesCount != null && dtCopiesCount.Rows.Count > 0)
        {
            totalCopies = Convert.ToInt32(dtCopiesCount.Rows[0]["Total"]);
            availableCopies = dtCopiesCount.Rows[0]["Available"] != DBNull.Value ? Convert.ToInt32(dtCopiesCount.Rows[0]["Available"]) : 0;
        }

        if (totalCopies == 0)
        {
            ShowAlert("Reservation blocked: This book has no active copies registered in the library.", "error");
            return;
        }

        if (availableCopies > 0)
        {
            ShowAlert("Reservation blocked: This book has available copies on shelves. Please borrow them directly instead of reserving.", "error");
            return;
        }

        // Check if book is already in the basket
        DataTable basket = BasketTable;
        foreach (DataRow row in basket.Rows)
        {
            if (Convert.ToInt32(row["BookID"]) == bookID)
            {
                ShowAlert("This book is already in the pending reservation basket.", "error");
                return;
            }
        }

        // Add to basket
        DataRow nr = basket.NewRow();
        nr["BookID"] = bookID;
        nr["Title"] = ddlBookCatalog.SelectedItem.Text;
        nr["StartDate"] = startDate;
        nr["EndDate"] = endDate;
        basket.Rows.Add(nr);

        BasketTable = basket;
        BindBasket();

        // Clear selection
        ddlBookCatalog.SelectedValue = "0";
        txtBookSearch.Text = "";
        pnlForecastPreview.Visible = false;
        BindBookCatalogDropdown();
        
        ShowAlert("Book added to the pending basket.", "success");
    }

    protected void gvBasket_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "RemoveItem")
        {
            int idx = Convert.ToInt32(e.CommandArgument);
            DataTable basket = BasketTable;
            if (idx >= 0 && idx < basket.Rows.Count)
            {
                basket.Rows.RemoveAt(idx);
                BasketTable = basket;
                BindBasket();
                ShowAlert("Item removed from basket.", "info");
            }
        }
    }

    protected void btnPlaceReservation_Click(object sender, EventArgs e)
    {
        if (ddlMember.SelectedValue == "0" || string.IsNullOrEmpty(ddlMember.SelectedValue))
        {
            ShowAlert("Please select a valid member.", "error");
            return;
        }

        int memberIDVal2 = GetMemberIDFromValue(ddlMember.SelectedValue);
        if (memberIDVal2 <= 0)
        {
            ShowAlert("Invalid member selection.", "error");
            return;
        }

        DataTable basket = BasketTable;
        if (basket.Rows.Count == 0)
        {
            ShowAlert("The reservation basket is empty.", "error");
            return;
        }

        int memberID = GetMemberIDFromValue(ddlMember.SelectedValue);
        string actualBorrowerNo = null;
        string actualBorrowerName = null;
        if (ddlMember.SelectedItem != null)
        {
            string selectedText = ddlMember.SelectedItem.Text;
            if (!string.IsNullOrEmpty(selectedText) && selectedText.Contains(" - "))
            {
                int dashIndex = selectedText.IndexOf(" - ");
                actualBorrowerNo = selectedText.Substring(0, dashIndex).Trim();
                string rest = selectedText.Substring(dashIndex + 3).Trim();
                if (rest.Contains(" (") && rest.EndsWith(")"))
                {
                    int suffixIndex = rest.LastIndexOf(" (");
                    actualBorrowerName = rest.Substring(0, suffixIndex).Trim();
                }
                else
                {
                    actualBorrowerName = rest;
                }
            }
        }

        int successCount = 0;
        int failCount = 0;
        System.Text.StringBuilder errors = new System.Text.StringBuilder();

        foreach (DataRow row in basket.Rows)
        {
            int bookID = Convert.ToInt32(row["BookID"]);
            string title = row["Title"].ToString();
            DateTime startDate = Convert.ToDateTime(row["StartDate"]);
            DateTime endDate = Convert.ToDateTime(row["EndDate"]);

            // Re-validate at place/confirm time
            DataTable dtCopiesCount = DBHelper.GetTableData(@"
                SELECT 
                    COUNT(*) as Total,
                    SUM(CASE WHEN IsAvailable = 1 THEN 1 ELSE 0 END) as Available
                FROM BookCopies 
                WHERE BookID = " + bookID + " AND CondID NOT IN (5,6)");
            
            int totalCopies = 0;
            int availableCopies = 0;
            if (dtCopiesCount != null && dtCopiesCount.Rows.Count > 0)
            {
                totalCopies = Convert.ToInt32(dtCopiesCount.Rows[0]["Total"]);
                availableCopies = dtCopiesCount.Rows[0]["Available"] != DBNull.Value ? Convert.ToInt32(dtCopiesCount.Rows[0]["Available"]) : 0;
            }

            if (totalCopies == 0)
            {
                failCount++;
                errors.AppendLine("'" + title + "': has no active copies registered.");
                continue;
            }

            if (availableCopies > 0)
            {
                failCount++;
                errors.AppendLine("'" + title + "': has available copies on shelves and cannot be reserved.");
                continue;
            }

            string result = DBHelper.ReserveBook(memberID, bookID, startDate, endDate, actualBorrowerNo, actualBorrowerName);
            if (result == "OK")
            {
                successCount++;
            }
            else
            {
                failCount++;
                string err = result;
                if (err == "ERR:ALREADY_RESERVED")
                {
                    err = "overlapping active reservation already exists.";
                }
                else if (err == "ERR:OVERLAPPING_RESERVATION")
                {
                    err = "capacity limit reached for this range.";
                }
                errors.AppendLine("'" + title + "': " + err);
            }
        }

        if (successCount > 0)
        {
            ShowAlert("Successfully placed " + successCount + " reservation(s)!", "success");
            
            // Reset fields & basket
            BasketTable = null;
            BindBasket();
            
            ddlMember.SelectedValue = "0";
            ddlBookCatalog.SelectedValue = "0";
            txtBookSearch.Text = "";
            txtMemberSearch.Text = "";
            pnlForecastPreview.Visible = false;
            
            // Reset dates
            txtStartDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            int resDays = 7;
            DataTable dtResDays = DBHelper.GetTableData("SELECT SVal FROM Settings WHERE SKey = 'ResDays'");
            if (dtResDays.Rows.Count > 0) int.TryParse(dtResDays.Rows[0]["SVal"].ToString(), out resDays);
            txtEndDate.Text = DateTime.Today.AddDays(resDays).ToString("yyyy-MM-dd");

            // Refresh catalog and grid
            BindBookCatalogDropdown();
            BindMembersDropdown();
            BindActiveReservations();
            PopulateFilterDropdowns();
        }

        if (failCount > 0)
        {
            ShowAlert("Failed to place " + failCount + " reservation(s):<br />" + errors.ToString().Replace(Environment.NewLine, "<br />"), "error");
        }
    }

    protected void ddlFilter_Changed(object sender, EventArgs e)
    {
        BindActiveReservations();
    }

    protected void btnClearFilters_Click(object sender, EventArgs e)
    {
        ddlFilterBook.SelectedValue = "0";
        ddlFilterMember.SelectedValue = "0";
        BindActiveReservations();
    }

    protected void gvReservations_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView rowView = (DataRowView)e.Row.DataItem;
            int bookID = Convert.ToInt32(rowView["BookID"]);
            int queuePos = Convert.ToInt32(rowView["DynamicQueuePos"]);
            
            // Forecast label styling
            Label lblForecast = (Label)e.Row.FindControl("lblForecast");
            if (lblForecast != null)
            {
                if (rowView["ForecastDate"] != DBNull.Value)
                {
                    DateTime forecastDate = Convert.ToDateTime(rowView["ForecastDate"]);
                    if (forecastDate.Date == DateTime.Today)
                    {
                        lblForecast.Text = "Starts Today";
                        lblForecast.Attributes["style"] = "padding: 4px 8px; border-radius: 4px; font-size: 11.5px; font-weight: 600; background-color: #d1fae5; color: #065f46;";
                    }
                    else
                    {
                        lblForecast.Text = forecastDate.ToString("dd-MMM-yyyy");
                        lblForecast.Attributes["style"] = "padding: 4px 8px; border-radius: 4px; font-size: 11.5px; font-weight: 600; background-color: #eff6ff; color: #1d4ed8;";
                    }
                }
                else
                {
                    lblForecast.Text = "Unknown";
                    lblForecast.Attributes["style"] = "padding: 4px 8px; border-radius: 4px; font-size: 11.5px; font-weight: 600; background-color: #f1f5f9; color: #475569;";
                }
            }

            // Up/Down button state management based on position in queue
            LinkButton btnMoveUp = (LinkButton)e.Row.FindControl("btnMoveUp");
            LinkButton btnMoveDown = (LinkButton)e.Row.FindControl("btnMoveDown");

            if (btnMoveUp != null && btnMoveDown != null && activeReservationsDt != null)
            {
                // Find total count for this BookID in the datatable
                int totalForBook = activeReservationsDt.Select("BookID = " + bookID).Length;

                if (queuePos == 1)
                {
                    btnMoveUp.Enabled = false;
                    btnMoveUp.Style["opacity"] = "0.4";
                    btnMoveUp.Style["cursor"] = "default";
                }
                if (queuePos == totalForBook)
                {
                    btnMoveDown.Enabled = false;
                    btnMoveDown.Style["opacity"] = "0.4";
                    btnMoveDown.Style["cursor"] = "default";
                }
            }

            // Print Slip and Issue Direct buttons visibility based on available copies
            LinkButton btnPrintSlip = (LinkButton)e.Row.FindControl("btnPrintSlip");
            LinkButton btnIssueDirect = (LinkButton)e.Row.FindControl("btnIssueDirect");
            if (btnPrintSlip != null || btnIssueDirect != null)
            {
                DataTable dtAvail = DBHelper.GetTableData("SELECT COUNT(*) FROM BookCopies WHERE BookID = " + bookID + " AND IsAvailable = 1 AND CondID NOT IN (5,6)");
                int availCopies = (dtAvail != null && dtAvail.Rows.Count > 0) ? Convert.ToInt32(dtAvail.Rows[0][0]) : 0;
                
                if (btnPrintSlip != null)
                {
                    btnPrintSlip.Visible = (queuePos <= availCopies);
                }
                
                if (btnIssueDirect != null)
                {
                    btnIssueDirect.Visible = (availCopies > 0);
                }
            }
        }
    }

    protected void gvReservations_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "MoveUp" || e.CommandName == "MoveDown")
        {
            int resID = Convert.ToInt32(e.CommandArgument);
            
            // Find current position in grid to calculate new position
            DataTable dt = DBHelper.GetActiveReservations(null, null);
            DataRow[] found = dt.Select("ResID = " + resID);
            if (found.Length > 0)
            {
                int currentQueuePos = Convert.ToInt32(found[0]["CurrentQueuePos"]);
                int newPos = e.CommandName == "MoveUp" ? currentQueuePos - 1 : currentQueuePos + 1;

                string result = DBHelper.SetReservationPriority(resID, newPos);
                if (result == "OK")
                {
                    ShowAlert("Queue priority updated successfully.", "success");
                    BindActiveReservations();
                }
                else
                {
                    ShowAlert("Failed to update queue position: " + result, "error");
                }
            }
        }
        else if (e.CommandName == "CancelRes")
        {
            int resID = Convert.ToInt32(e.CommandArgument);
            string result = DBHelper.CancelReservation(resID);
            
            if (result == "OK")
            {
                ShowAlert("Reservation has been cancelled successfully.", "success");
                BindActiveReservations();
                PopulateFilterDropdowns();
            }
            else
            {
                ShowAlert("Failed to cancel reservation: " + result, "error");
            }
        }
        else if (e.CommandName == "IssueDirect")
        {
            int index = Convert.ToInt32(e.CommandArgument);
            GridViewRow row = gvReservations.Rows[index];

            int resID = Convert.ToInt32(gvReservations.DataKeys[index]["ResID"]);
            int bookID = Convert.ToInt32(gvReservations.DataKeys[index]["BookID"]);
            int memberID = Convert.ToInt32(gvReservations.DataKeys[index]["MemberID"]);
            string memberName = gvReservations.DataKeys[index]["MemberName"].ToString();
            string bookTitle = gvReservations.DataKeys[index]["BookTitle"].ToString();
            string membershipNo = gvReservations.DataKeys[index]["MembershipNo"].ToString();

            hdnIssueResID.Value = resID.ToString();
            hdnIssueMemberID.Value = memberID.ToString();
            hdnIssueBookID.Value = bookID.ToString();
            hdnIssueBorrowerNo.Value = membershipNo;
            hdnIssueBorrowerName.Value = memberName;
            lblIssueMemberName.Text = memberName;
            lblIssueBookTitle.Text = bookTitle;

            // Load available physical copies for direct issue
            DataTable dtCopies = DBHelper.GetTableData(@"
                SELECT cp.CopyID, cp.Barcode, cc.CondName 
                FROM BookCopies cp 
                JOIN CopyConditions cc ON cp.CondID = cc.CondID 
                WHERE cp.BookID = " + bookID + " AND cp.IsAvailable = 1 AND cp.CondID NOT IN (5,6)");

            ddlIssueCopies.Items.Clear();
            if (dtCopies != null && dtCopies.Rows.Count > 0)
            {
                foreach (DataRow r in dtCopies.Rows)
                {
                    string label = r["Barcode"].ToString().Trim() + " (Condition: " + r["CondName"].ToString() + ")";
                    ddlIssueCopies.Items.Add(new ListItem(label, r["CopyID"].ToString()));
                }
                ddlIssueCopies.Items.Insert(0, new ListItem("- Select Available Copy -", "0"));
                btnConfirmIssueDirect.Enabled = true;
            }
            else
            {
                ddlIssueCopies.Items.Add(new ListItem("No copies available on shelves", "0"));
                btnConfirmIssueDirect.Enabled = false;
            }

            pnlIssueDirect.Visible = true;
        }
        else if (e.CommandName == "PrintSlip")
        {
            int index = Convert.ToInt32(e.CommandArgument);
            int resID = Convert.ToInt32(gvReservations.DataKeys[index]["ResID"]);

            // Calculate holding duration based on system settings
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

            // Update reservation in the database with NotifiedAt and ExpiresOn
            using (SqlConnection con = DBHelper.GetConnection())
            {
                con.Open();
                string updateSql = "UPDATE Reservations SET NotifiedAt = SYSDATETIME(), ExpiresOn = DATEADD(day, @resDays, CAST(GETDATE() AS DATE)) WHERE ResID = @resID";
                using (SqlCommand cmd = new SqlCommand(updateSql, con))
                {
                    cmd.Parameters.AddWithValue("@resDays", resDays);
                    cmd.Parameters.AddWithValue("@resID", resID);
                    cmd.ExecuteNonQuery();
                }
            }

            // Refresh UI Grid to show updated status
            BindActiveReservations();

            // Re-fetch reservation data including DDC & AcqNo
            DataTable dt = DBHelper.GetActiveReservations(null, null);
            DataRow[] rows = dt.Select("ResID = " + resID);
            if (rows.Length > 0)
            {
                litPrintableReserveSlip.Text = GenerateReserveSlipHtml(rows[0]);
                pnlReserveSlipModal.Visible = true;
            }
            else
            {
                ShowAlert("Unable to load reservation details for printing.", "error");
            }
        }
    }

    protected void btnConfirmIssueDirect_Click(object sender, EventArgs e)
    {
        if (ddlIssueCopies.SelectedValue == "0" || string.IsNullOrEmpty(ddlIssueCopies.SelectedValue))
        {
            ShowAlert("Please select an available physical copy to issue.", "error");
            return;
        }

        int memberID = Convert.ToInt32(hdnIssueMemberID.Value);
        int copyID = Convert.ToInt32(ddlIssueCopies.SelectedValue);
        string borrowerNo = hdnIssueBorrowerNo.Value;
        string borrowerName = hdnIssueBorrowerName.Value;

        // Restrict direct issuance if copy is not in the available list
        DataTable dtCheck = DBHelper.GetTableData("SELECT COUNT(*) FROM BookCopies WHERE CopyID = " + copyID + " AND IsAvailable = 1 AND CondID NOT IN (5,6)");
        int isStillAvail = (dtCheck != null && dtCheck.Rows.Count > 0) ? Convert.ToInt32(dtCheck.Rows[0][0]) : 0;
        if (isStillAvail == 0)
        {
            ShowAlert("Direct Checkout Failed: The selected book copy is not in the available list.", "error");
            return;
        }

        string result = DBHelper.IssueBook(memberID, copyID, CurrentStaffID, null, null, borrowerNo, borrowerName);

        if (result.StartsWith("OK:"))
        {
            string dueInfo = result.Substring(7);
            ShowAlert("Book issued successfully directly to the reserving member! <strong>Due Date: " + dueInfo + "</strong>", "success");
            
            pnlIssueDirect.Visible = false;
            BindActiveReservations();
            PopulateFilterDropdowns();
        }
        else
        {
            string err = result;
            if (err == "ERR:MEMBER_INACTIVE") err = "Member account is inactive. Checkout blocked.";
            else if (err.StartsWith("ERR:BORROW_LIMIT")) err = "Borrow limit reached! Member cannot checkout more than " + err.Split(':')[2] + " books.";
            else if (err.StartsWith("ERR:UNPAID_FINES")) err = "Checkout blocked! Member has outstanding unpaid fines of PKR " + err.Split(':')[2] + ".";
            else if (err == "ERR:COPY_UNAVAILABLE") err = "The selected book copy is not available.";
            else if (err.StartsWith("ERR:RESERVED_FOR_OTHER"))
            {
                string[] parts = err.Split(':');
                string holder = parts.Length > 2 ? parts[2] : "another member";
                err = "Checkout blocked! This book is reserved for " + holder + " who has higher priority in the reservation queue.";
            }

            ShowAlert("Direct Checkout Failed: " + err, "error");
        }
    }

    protected void btnCancelIssueDirect_Click(object sender, EventArgs e)
    {
        pnlIssueDirect.Visible = false;
    }

    private int GetMemberIDFromValue(string val)
    {
        if (string.IsNullOrEmpty(val) || val == "0") return 0;
        if (val.Contains("|"))
        {
            int id;
            if (int.TryParse(val.Split('|')[0], out id)) return id;
        }
        else
        {
            int id;
            if (int.TryParse(val, out id)) return id;
        }
        return 0;
    }

    private void ShowAlert(string msg, string type)
    {
        pnlAlert.Visible = true;
        litAlertMsg.Text = msg;
        if (type == "success")
        {
            divAlert.Attributes["style"] = "padding: 16px 24px; border-radius: 8px; font-size: 14px; margin-bottom: 24px; border-left: 4px solid #10b981; background-color: #d1fae5; color: #065f46; width: 100%; box-sizing: border-box;";
        }
        else if (type == "info")
        {
            divAlert.Attributes["style"] = "padding: 16px 24px; border-radius: 8px; font-size: 14px; margin-bottom: 24px; border-left: 4px solid #3b82f6; background-color: #eff6ff; color: #1e3a8a; width: 100%; box-sizing: border-box;";
        }
        else // error
        {
            divAlert.Attributes["style"] = "padding: 16px 24px; border-radius: 8px; font-size: 14px; margin-bottom: 24px; border-left: 4px solid #ef4444; background-color: #fee2e2; color: #991b1b; width: 100%; box-sizing: border-box;";
        }
    }

    protected void btnCloseReserveSlip_Click(object sender, EventArgs e)
    {
        pnlReserveSlipModal.Visible = false;
    }

    private string GetStaffName(short staffID)
    {
        try
        {
            DataTable dt = DBHelper.GetTableData("SELECT ISNULL(EFName, '') + ' ' + ISNULL(ELName, '') FROM User_management.dbo.Employee WHERE EmpID = " + staffID);
            if (dt != null && dt.Rows.Count > 0)
            {
                string name = Convert.ToString(dt.Rows[0][0]).Trim();
                if (!string.IsNullOrEmpty(name)) return name;
            }
        }
        catch { }
        return "Librarian";
    }

    private string GenerateReserveSlipHtml(DataRow row)
    {
        string resID = Convert.ToInt32(row["ResID"]).ToString("D5");
        string membershipNo = row["MembershipNo"].ToString();
        string memberName = row["MemberName"].ToString().ToUpper();
        string bookNo = row.Table.Columns.Contains("BookNo") && row["BookNo"] != DBNull.Value && !string.IsNullOrEmpty(row["BookNo"].ToString()) 
            ? row["BookNo"].ToString().Trim() 
            : (row.Table.Columns.Contains("AcqNo") && row["AcqNo"] != DBNull.Value && !string.IsNullOrEmpty(row["AcqNo"].ToString())
                ? row["AcqNo"].ToString().Trim() 
                : Convert.ToInt32(row["BookID"]).ToString("D6"));
        string ddc = row["DDC"] != DBNull.Value ? row["DDC"].ToString().Trim() : "N/A";
        string bookTitle = row["BookTitle"].ToString().ToUpper();
        string reserveDate = Convert.ToDateTime(row["ReservedAt"]).ToString("dd/MM/yyyy");
        string transactionDateTime = DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss");
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
        string disposalUntil = DateTime.Now.AddDays(resDays).ToString("dd/MM/yyyy HH:mm");
        string staffName = GetStaffName(CurrentStaffID);
        string auditStamp = staffName + ", " + DateTime.Now.ToString("dd/MM/yyyy, h:mm:sstt").ToUpper() + ", LM 10.04";

        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        sb.Append("<div style='font-family: Arial, sans-serif; color: #000000; line-height: 1.6; padding: 20px; max-width: 750px; margin: 0 auto; text-align: left;'>");
        
        // Header
        sb.Append("  <table style='width: 100%; border-collapse: collapse; margin-bottom: 25px;'>");
        sb.Append("    <tr>");
        sb.Append("      <td style='vertical-align: top; text-align: left;'>");
        sb.Append("        <div style='font-size: 20px; font-weight: bold; letter-spacing: 0.5px;'>Lahore Gymkhana</div>");
        sb.Append("        <div style='font-size: 13px; font-weight: bold; margin-top: 3px;'>Library Reserve Note</div>");
        sb.Append("      </td>");
        sb.Append("      <td style='vertical-align: bottom; text-align: right; font-size: 13px;'>");
        sb.Append("        Transaction Date/Time: <span style='border-bottom: 1px solid #000; padding-bottom: 2px;'>" + transactionDateTime + "</span>");
        sb.Append("      </td>");
        sb.Append("    </tr>");
        sb.Append("  </table>");

        // Reserve Info lines
        sb.Append("  <table style='width: 100%; border-collapse: collapse; margin-bottom: 20px; font-size: 13.5px;'>");
        sb.Append("    <tr>");
        sb.Append("      <td style='padding: 6px 0; width: 140px;'>Library Reserve No:</td>");
        sb.Append("      <td style='padding: 6px 0; font-weight: bold;'><span style='border-bottom: 1px solid #000; padding-bottom: 2px;'>" + resID + "</span></td>");
        sb.Append("    </tr>");
        sb.Append("    <tr>");
        sb.Append("      <td style='padding: 6px 0;'>Reserved for:</td>");
        sb.Append("      <td style='padding: 6px 0; font-weight: bold;'><span style='border-bottom: 1px solid #000; padding-bottom: 2px;'>" + membershipNo + " &nbsp; " + memberName + "</span></td>");
        sb.Append("    </tr>");
        sb.Append("  </table>");

        // Book details introduction
        sb.Append("  <div style='font-size: 13.5px; margin-bottom: 15px;'>The following book/magazine was reserved by you</div>");

        // Book Details Table
        sb.Append("  <table style='width: 100%; border-collapse: collapse; margin-bottom: 20px; font-size: 13px;'>");
        sb.Append("    <thead>");
        sb.Append("      <tr style='border-bottom: 1.5px solid #000;'>");
        sb.Append("        <th style='text-align: left; padding: 6px 0; font-weight: bold; width: 110px;'>BookNo</th>");
        sb.Append("        <th style='text-align: left; padding: 6px 0; font-weight: bold; width: 130px;'>DDC No</th>");
        sb.Append("        <th style='text-align: left; padding: 6px 0; font-weight: bold;'>Title</th>");
        sb.Append("        <th style='text-align: right; padding: 6px 0; font-weight: bold; width: 120px;'>Reserve Date</th>");
        sb.Append("      </tr>");
        sb.Append("    </thead>");
        sb.Append("    <tbody>");
        sb.Append("      <tr style='border-bottom: 1.5px solid #000;'>");
        sb.Append("        <td style='padding: 10px 0; font-family: monospace;'>" + bookNo + "</td>");
        sb.Append("        <td style='padding: 10px 0;'>" + ddc + "</td>");
        sb.Append("        <td style='padding: 10px 0; font-weight: bold;'>" + bookTitle + "</td>");
        sb.Append("        <td style='padding: 10px 0; text-align: right;'>" + reserveDate + "</td>");
        sb.Append("      </tr>");
        sb.Append("    </tbody>");
        sb.Append("  </table>");

        // Expiration/Action body
        sb.Append("  <div style='font-size: 13.5px; margin-bottom: 12px; text-align: justify;'>");
        sb.Append("    This is now available and will be held at your disposal up to <strong>(" + disposalUntil + ")</strong>");
        sb.Append("  </div>");
        sb.Append("  <div style='font-size: 13.5px; margin-bottom: 20px; text-align: justify;'>");
        sb.Append("    if not claimed, then this will be issued to the next applicant or returned to the shelves.");
        sb.Append("  </div>");
        sb.Append("  <div style='font-size: 13.5px; margin-bottom: 60px;'>");
        sb.Append("    Please bring this reservation slip with you or sign it below for the bearer.");
        sb.Append("  </div>");

        // Footer and Signatures
        sb.Append("  <table style='width: 100%; border-collapse: collapse;'>");
        sb.Append("    <tr>");
        sb.Append("      <td style='width: 50%; vertical-align: top; text-align: left;'>");
        sb.Append("        <div style='display: inline-block; text-align: center;'>");
        sb.Append("          <div style='font-size: 13.5px; border-bottom: 1px solid #000; width: 220px; padding-bottom: 3px; font-weight: bold; height: 25px;'>" + staffName + "</div>");
        sb.Append("          <div style='font-size: 12px; font-weight: bold; margin-top: 5px;'>Reserved By</div>");
        sb.Append("        </div>");
        sb.Append("      </td>");
        sb.Append("      <td style='width: 50%; vertical-align: top; text-align: right; font-size: 13.5px;'>");
        sb.Append("        <div style='margin-bottom: 40px;'>Yours Faithfully,</div>");
        sb.Append("        <div style='font-weight: bold;'>Manager Library</div>");
        sb.Append("      </td>");
        sb.Append("    </tr>");
        sb.Append("    <tr>");
        sb.Append("      <td style='padding-top: 40px; font-size: 10px; color: #555; font-style: italic; vertical-align: bottom;'>" + auditStamp + "</td>");
        sb.Append("      <td style='padding-top: 40px; text-align: right; vertical-align: top;'>");
        sb.Append("        <table style='float: right; font-size: 13px;'>");
        sb.Append("          <tr><td style='padding: 3px 0; text-align: left; width: 80px;'>Signature</td><td style='border-bottom: 1px solid #000; width: 150px;'></td></tr>");
        sb.Append("          <tr><td style='padding: 3px 0; text-align: left;'>M/s No.</td><td style='border-bottom: 1px solid #000;'></td></tr>");
        sb.Append("        </table>");
        sb.Append("      </td>");
        sb.Append("    </tr>");
        sb.Append("  </table>");
        sb.Append("</div>");

        return sb.ToString();
    }

    #region Nested Helper Classes (DBHelper & ISBN13Helper)





/// <summary>
/// Centralised database access helper for Lahore Gymkhana Library.
/// All communication uses Stored Procedures Ã¢â‚¬â€ no inline SQL.
/// Aligned with the highly optimized Database Schema v2.0.
/// </summary>
public static class DBHelper
{
    // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    //  Connection
    // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    private static string ConnStr
    {
        get
        {
            return ConfigurationManager.ConnectionStrings["GymkhanaLibraryDB"] != null 
                ? ConfigurationManager.ConnectionStrings["GymkhanaLibraryDB"].ConnectionString 
                : "Data Source=.\\LOCALHOST;Initial Catalog=GymkhanaLibraryDB;Integrated Security=True;TrustServerCertificate=True;";
        }
    }

    public static SqlConnection GetConnection()
    {
        return new SqlConnection(ConnStr);
    }

    // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    //  Execute SP Ã¢â€ â€™ DataTable  (SELECT results)
    // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    public static DataTable ExecuteReader(string spName, params SqlParameter[] prms)
    {
        var dt = new DataTable();
        using (var con = GetConnection())
        using (var cmd = new SqlCommand(spName, con) { CommandType = CommandType.StoredProcedure, CommandTimeout = 120 })
        using (var da  = new SqlDataAdapter(cmd))
        {
            if (prms != null) cmd.Parameters.AddRange(prms);
            con.Open();
            da.Fill(dt);
        }
        return dt;
    }

    // Execute SP Ã¢â€ â€™ DataSet  (multiple result sets, e.g. sp_GetBookDetail)
    public static DataSet ExecuteDataSet(string spName, params SqlParameter[] prms)
    {
        var ds = new DataSet();
        using (var con = GetConnection())
        using (var cmd = new SqlCommand(spName, con) { CommandType = CommandType.StoredProcedure, CommandTimeout = 120 })
        using (var da  = new SqlDataAdapter(cmd))
        {
            if (prms != null) cmd.Parameters.AddRange(prms);
            con.Open();
            da.Fill(ds);
        }
        return ds;
    }

    // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    //  Execute SP Ã¢â€ â€™ no return value (fire-and-forget DML)
    // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    public static void ExecuteNonQuery(string spName, params SqlParameter[] prms)
    {
        using (var con = GetConnection())
        using (var cmd = new SqlCommand(spName, con) { CommandType = CommandType.StoredProcedure, CommandTimeout = 120 })
        {
            if (prms != null) cmd.Parameters.AddRange(prms);
            con.Open();
            cmd.ExecuteNonQuery();
        }
    }

    // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    //  Helper: get OUTPUT param value from a parameter array
    // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    public static T GetOutputValue<T>(SqlParameter[] prms, string paramName)
    {
        foreach (var p in prms)
            if (p.ParameterName.Equals(paramName, StringComparison.OrdinalIgnoreCase))
                return (p.Value == null || p.Value == DBNull.Value) ? default(T) : (T)Convert.ChangeType(p.Value, typeof(T));
        return default(T);
    }

    // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    //  Helper: Run direct query for dropdowns (failsafe lookup)
    // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    public static DataTable GetTableData(string query)
    {
        var dt = new DataTable();
        using (var con = GetConnection())
        using (var cmd = new SqlCommand(query, con) { CommandTimeout = 120 })
        using (var da = new SqlDataAdapter(cmd))
        {
            con.Open();
            da.Fill(dt);
        }
        return dt;
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  In-Memory Caching Helpers
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    private static DataTable GetCachedTable(string cacheKey, string query)
    {
        var cache = System.Web.HttpRuntime.Cache;
        if (cache == null) return GetTableData(query);

        DataTable dt = cache[cacheKey] as DataTable;
        if (dt == null)
        {
            dt = GetTableData(query);
            if (dt != null)
            {
                cache.Insert(cacheKey, dt, null, DateTime.Now.AddMinutes(15), System.Web.Caching.Cache.NoSlidingExpiration);
            }
        }
        return dt;
    }

    private static void ClearCache(string cacheKey)
    {
        var cache = System.Web.HttpRuntime.Cache;
        if (cache != null && cache[cacheKey] != null)
        {
            cache.Remove(cacheKey);
        }
    }


    // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    //  Business Methods: Books
    // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    public static SaveBookResult SaveBook(
        int? bookID, string isbn13, string isbn10,
        string title, string subTitle, short catID,
        short? pubID, byte langID, short? pubYear,
        string edition, short? pageCount, string classNo,
        string tags, string synopsis, string coverFile, short staffID, string ddc,
        bool isReference, bool notToBeIssued, bool printBookDetail,
        string acqNo, string publishingPlace, string liDate, string volume,
        string wwwLink, string series, string recBy, string purchaseRef,
        string purchaseDate, string priceFcy, string pricePkr, string format,
        string source, string status, string classSeq, string location,
        bool isAdults, bool isChildren)
    {
        var prms = new[]
        {
            new SqlParameter("@BookID",          (object)bookID      ?? DBNull.Value),
            new SqlParameter("@ISBN13",           isbn13),
            new SqlParameter("@ISBN10",           (object)isbn10      ?? DBNull.Value),
            new SqlParameter("@Title",            title),
            new SqlParameter("@SubTitle",         (object)subTitle    ?? DBNull.Value),
            new SqlParameter("@CatID",            catID),
            new SqlParameter("@PubID",            (object)pubID       ?? DBNull.Value),
            new SqlParameter("@LangID",           langID),
            new SqlParameter("@PubYear",          (object)pubYear     ?? DBNull.Value),
            new SqlParameter("@Edition",          (object)edition     ?? DBNull.Value),
            new SqlParameter("@PageCount",        (object)pageCount   ?? DBNull.Value),
            new SqlParameter("@ClassNo",          (object)classNo     ?? DBNull.Value),
            new SqlParameter("@Tags",             (object)tags        ?? DBNull.Value),
            new SqlParameter("@Synopsis",         (object)synopsis    ?? DBNull.Value),
            new SqlParameter("@CoverFile",        (object)coverFile   ?? DBNull.Value),
            new SqlParameter("@StaffID",          staffID),
            new SqlParameter("@DDC",              (object)ddc         ?? DBNull.Value),
            new SqlParameter("@IsReference",      isReference),
            new SqlParameter("@NotToBeIssued",    notToBeIssued),
            new SqlParameter("@PrintBookDetail",  printBookDetail),
            new SqlParameter("@AcqNo",            (object)acqNo       ?? DBNull.Value),
            new SqlParameter("@PublishingPlace",   (object)publishingPlace ?? DBNull.Value),
            new SqlParameter("@LiDate",           (object)liDate      ?? DBNull.Value),
            new SqlParameter("@Volume",           (object)volume      ?? DBNull.Value),
            new SqlParameter("@WwwLink",          (object)wwwLink     ?? DBNull.Value),
            new SqlParameter("@Series",           (object)series      ?? DBNull.Value),
            new SqlParameter("@RecBy",            (object)recBy       ?? DBNull.Value),
            new SqlParameter("@PurchaseRef",      (object)purchaseRef ?? DBNull.Value),
            new SqlParameter("@PurchaseDate",     (object)purchaseDate ?? DBNull.Value),
            new SqlParameter("@PriceFcy",         (object)priceFcy    ?? DBNull.Value),
            new SqlParameter("@PricePkr",         (object)pricePkr    ?? DBNull.Value),
            new SqlParameter("@Format",           (object)format      ?? DBNull.Value),
            new SqlParameter("@Source",           (object)source      ?? DBNull.Value),
            new SqlParameter("@Status",           (object)status      ?? DBNull.Value),
            new SqlParameter("@ClassSeq",         (object)classSeq    ?? DBNull.Value),
            new SqlParameter("@Location",         (object)location    ?? DBNull.Value),
            new SqlParameter("@IsAdults",         isAdults),
            new SqlParameter("@IsChildren",       isChildren),
            new SqlParameter("@NewBookID", SqlDbType.Int) { Direction = ParameterDirection.Output },
            new SqlParameter("@Msg",       SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
        };

        using (var con = GetConnection())
        using (var cmd = new SqlCommand("sp_SaveBook", con) { CommandType = CommandType.StoredProcedure })
        {
            cmd.Parameters.AddRange(prms);
            con.Open();
            cmd.ExecuteNonQuery();
        }
        int newID = GetOutputValue<int>(prms, "@NewBookID");
        string result = GetOutputValue<string>(prms, "@Msg");
        return new SaveBookResult { NewBookID = newID, Result = result };
    }

    public static AddBookCopyResult AddBookCopy(
        int bookID, short? rackID, byte? slotNo,
        byte condID, decimal? cost, string notes)
    {
        var prms = new[]
        {
            new SqlParameter("@BookID",   bookID),
            new SqlParameter("@RackID",   (object)rackID  ?? DBNull.Value),
            new SqlParameter("@SlotNo",   (object)slotNo  ?? DBNull.Value),
            new SqlParameter("@CondID",   condID),
            new SqlParameter("@AcqCost",  (object)cost    ?? DBNull.Value),
            new SqlParameter("@Notes",    (object)notes   ?? DBNull.Value),
            new SqlParameter("@CopyID",   SqlDbType.Int) { Direction = ParameterDirection.Output },
            new SqlParameter("@Barcode",  SqlDbType.VarChar, 60) { Direction = ParameterDirection.Output },
            new SqlParameter("@Msg",      SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
        };

        using (var con = GetConnection())
        using (var cmd = new SqlCommand("sp_AddCopy", con) { CommandType = CommandType.StoredProcedure })
        {
            cmd.Parameters.AddRange(prms);
            con.Open();
            cmd.ExecuteNonQuery();
        }
        string barcodeVal = GetOutputValue<string>(prms, "@Barcode");
        int copyID = GetOutputValue<int>(prms, "@CopyID");
        string msg = GetOutputValue<string>(prms, "@Msg");
        return new AddBookCopyResult
        {
            CopyID = copyID,
            Barcode = barcodeVal != null ? barcodeVal.Trim() : null,
            Result = msg
        };
    }

    public static string IssueBook(int memberID, int copyID, short staffID, DateTime? issueDate = null, DateTime? dueDate = null, string actualBorrowerNo = null, string actualBorrowerName = null)
    {
        var prms = new[]
        {
            new SqlParameter("@MemberID",  memberID),
            new SqlParameter("@CopyID",    copyID),
            new SqlParameter("@StaffID",   staffID),
            new SqlParameter("@Msg",       SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output },
            new SqlParameter("@IssueDate", (object)issueDate ?? DBNull.Value),
            new SqlParameter("@DueDate",   (object)dueDate   ?? DBNull.Value),
            new SqlParameter("@ActualBorrowerNo", (object)actualBorrowerNo ?? DBNull.Value),
            new SqlParameter("@ActualBorrowerName", (object)actualBorrowerName ?? DBNull.Value)
        };
        using (var con = GetConnection())
        using (var cmd = new SqlCommand("sp_IssueBook", con) { CommandType = CommandType.StoredProcedure })
        {
            cmd.Parameters.AddRange(prms);
            con.Open();
            cmd.ExecuteNonQuery();
        }
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static string ReturnBook(int copyID, short staffID, byte condID = 2, DateTime? returnDateTime = null)
    {
        var prms = new[]
        {
            new SqlParameter("@CopyID",  copyID),
            new SqlParameter("@StaffID", staffID),
            new SqlParameter("@CondID",  condID),
            new SqlParameter("@ReturnDateTime", (object)returnDateTime ?? DBNull.Value),
            new SqlParameter("@Msg",     SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
        };
        using (var con = GetConnection())
        using (var cmd = new SqlCommand("sp_ReturnBook", con) { CommandType = CommandType.StoredProcedure })
        {
            cmd.Parameters.AddRange(prms);
            con.Open();
            cmd.ExecuteNonQuery();
        }
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static string ReturnCollectReissue(int copyID, short staffID, byte condID, int? reissueToMemberID, DateTime? issueDate, DateTime? dueDate, bool collectFines, string actualBorrowerNo = null, string actualBorrowerName = null)
    {
        var prms = new[]
        {
            new SqlParameter("@CopyID",             copyID),
            new SqlParameter("@StaffID",            staffID),
            new SqlParameter("@CondID",             condID),
            new SqlParameter("@ReissueToMemberID",  (object)reissueToMemberID ?? DBNull.Value),
            new SqlParameter("@IssueDate",          (object)issueDate         ?? DBNull.Value),
            new SqlParameter("@DueDate",            (object)dueDate           ?? DBNull.Value),
            new SqlParameter("@CollectFines",       collectFines),
            new SqlParameter("@Msg",                SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output },
            new SqlParameter("@ActualBorrowerNo",   (object)actualBorrowerNo ?? DBNull.Value),
            new SqlParameter("@ActualBorrowerName", (object)actualBorrowerName ?? DBNull.Value)
        };
        using (var con = GetConnection())
        using (var cmd = new SqlCommand("sp_ReturnCollectReissue", con) { CommandType = CommandType.StoredProcedure })
        {
            cmd.Parameters.AddRange(prms);
            con.Open();
            cmd.ExecuteNonQuery();
        }
        return GetOutputValue<string>(prms, "@Msg");
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
        using (var cmd = new SqlCommand("sp_RenewLoan", con) { CommandType = CommandType.StoredProcedure })
        {
            cmd.Parameters.AddRange(prms);
            con.Open();
            cmd.ExecuteNonQuery();
        }
        return GetOutputValue<string>(prms, "@Msg");
    }

    // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    //  Business Methods: Book Reservations
    // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    public static string ReserveBook(int memberID, int bookID, DateTime? startDate = null, DateTime? endDate = null, string actualBorrowerNo = null, string actualBorrowerName = null)
    {
        var prms = new[]
        {
            new SqlParameter("@MemberID", memberID),
            new SqlParameter("@BookID", bookID),
            new SqlParameter("@StartDate", (object)startDate ?? DBNull.Value),
            new SqlParameter("@EndDate", (object)endDate ?? DBNull.Value),
            new SqlParameter("@Msg", SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output },
            new SqlParameter("@ActualBorrowerNo", (object)actualBorrowerNo ?? DBNull.Value),
            new SqlParameter("@ActualBorrowerName", (object)actualBorrowerName ?? DBNull.Value)
        };
        using (var con = GetConnection())
        using (var cmd = new SqlCommand("sp_ReserveBook", con) { CommandType = CommandType.StoredProcedure })
        {
            cmd.Parameters.AddRange(prms);
            con.Open();
            cmd.ExecuteNonQuery();
        }
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static bool CheckBookAvailabilityForRange(int bookID, DateTime startDate, DateTime endDate)
    {
        using (var con = GetConnection())
        using (var cmd = new SqlCommand("SELECT dbo.fn_CheckBookAvailabilityForRange(@BookID, @StartDate, @EndDate)", con))
        {
            cmd.Parameters.AddWithValue("@BookID", bookID);
            cmd.Parameters.AddWithValue("@StartDate", startDate.Date);
            cmd.Parameters.AddWithValue("@EndDate", endDate.Date);
            con.Open();
            var result = cmd.ExecuteScalar();
            if (result == null || result == DBNull.Value)
                return false;
            return Convert.ToBoolean(result);
        }
    }

    public static string CancelReservation(int resID)
    {
        var prms = new[]
        {
            new SqlParameter("@ResID", resID),
            new SqlParameter("@Msg", SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
        };
        using (var con = GetConnection())
        using (var cmd = new SqlCommand("sp_CancelReservation", con) { CommandType = CommandType.StoredProcedure })
        {
            cmd.Parameters.AddRange(prms);
            con.Open();
            cmd.ExecuteNonQuery();
        }
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static string SetReservationPriority(int resID, int newPos)
    {
        var prms = new[]
        {
            new SqlParameter("@ResID", resID),
            new SqlParameter("@NewPos", newPos),
            new SqlParameter("@Msg", SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
        };
        using (var con = GetConnection())
        using (var cmd = new SqlCommand("sp_SetReservationPriority", con) { CommandType = CommandType.StoredProcedure })
        {
            cmd.Parameters.AddRange(prms);
            con.Open();
            cmd.ExecuteNonQuery();
        }
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static DataTable GetActiveReservations(int? memberID = null, int? bookID = null)
    {
        var prms = new[]
        {
            new SqlParameter("@MemberID", (object)memberID ?? DBNull.Value),
            new SqlParameter("@BookID", (object)bookID ?? DBNull.Value)
        };
        return ExecuteReader("sp_GetActiveReservations", prms);
    }

    public static DateTime? GetBookReservationForecast(int bookID, int queuePos)
    {
        using (var con = GetConnection())
        using (var cmd = new SqlCommand("SELECT dbo.fn_GetReservationForecast(@BookID, @QueuePos)", con))
        {
            cmd.Parameters.AddWithValue("@BookID", bookID);
            cmd.Parameters.AddWithValue("@QueuePos", queuePos);
            con.Open();
            var result = cmd.ExecuteScalar();
            if (result == null || result == DBNull.Value)
                return null;
            return Convert.ToDateTime(result);
        }
    }

    // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    //  Business Methods: Queries & Reports
    // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    public static DataTable SearchBooks(string term, short? catID, byte? langID, short? pubID, short? yearFrom, short? yearTo, bool availOnly, short? rackID, int? pageNumber = null, int? pageSize = null, string ddc = null)
    {
        var prms = new[]
        {
            new SqlParameter("@Term",      (object)term       ?? DBNull.Value),
            new SqlParameter("@CatID",     (object)catID      ?? DBNull.Value),
            new SqlParameter("@LangID",    (object)langID     ?? DBNull.Value),
            new SqlParameter("@PubID",     (object)pubID      ?? DBNull.Value),
            new SqlParameter("@YearFrom",  (object)yearFrom   ?? DBNull.Value),
            new SqlParameter("@YearTo",    (object)yearTo     ?? DBNull.Value),
            new SqlParameter("@AvailOnly", availOnly),
            new SqlParameter("@RackID",    (object)rackID     ?? DBNull.Value),
            new SqlParameter("@PageNumber", (object)pageNumber ?? DBNull.Value),
            new SqlParameter("@PageSize",   (object)pageSize   ?? DBNull.Value),
            new SqlParameter("@DDC",        (object)ddc        ?? DBNull.Value)
        };
        return ExecuteReader("sp_SearchBooks", prms);
    }

    public static DataSet GetBookDetail(int bookID)
    {
        return ExecuteDataSet("sp_GetBookDetail", new SqlParameter("@BookID", bookID));
    }

    public static DataTable GetDashboardStats()
    {
        return ExecuteReader("sp_DashboardStats");
    }

    public static DataTable GetOverdueReport()
    {
        return ExecuteReader("sp_GetOverdueReport");
    }

    public static DataTable GetTodayReturnsReport()
    {
        return ExecuteReader("dbo.sp_GetTodayReturnsReport");
    }

    public static DataTable GetRackOccupancy(short? hallID = null)
    {
        return ExecuteReader("sp_RackOccupancy", new SqlParameter("@HallID", (object)hallID ?? DBNull.Value));
    }

    public static DataTable GetMemberLoans(int memberID, bool activeOnly = false)
    {
        return ExecuteReader("sp_GetMemberLoans", 
            new SqlParameter("@MemberID", memberID),
            new SqlParameter("@ActiveOnly", activeOnly));
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Business Methods: Reports
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    public static DataTable GetReportAuthorWise(int? authorID = null)
    {
        var prms = new[]
        {
            new SqlParameter("@AuthorID", (object)authorID ?? DBNull.Value)
        };
        return ExecuteReader("dbo.sp_Report_AuthorWise", prms);
    }

    public static DataTable GetReportPublisherWise(int? pubID = null)
    {
        var prms = new[]
        {
            new SqlParameter("@PubID", (object)pubID ?? DBNull.Value)
        };
        return ExecuteReader("dbo.sp_Report_PublisherWise", prms);
    }

    public static DataTable GetReportEditionWise()
    {
        return ExecuteReader("dbo.sp_Report_EditionWise");
    }

    public static DataTable GetReportLanguageWise(byte? langID = null)
    {
        var prms = new[]
        {
            new SqlParameter("@LangID", (object)langID ?? DBNull.Value)
        };
        return ExecuteReader("dbo.sp_Report_LanguageWise", prms);
    }

    public static DataTable GetReportBookIssuance(DateTime? fromDate, DateTime? toDate)
    {
        var prms = new[]
        {
            new SqlParameter("@FromDate", (object)fromDate ?? DBNull.Value),
            new SqlParameter("@ToDate",   (object)toDate   ?? DBNull.Value)
        };
        return ExecuteReader("dbo.sp_Report_BookIssuance", prms);
    }

    public static DataTable GetReportIssuedNotReturned()
    {
        return ExecuteReader("dbo.sp_Report_IssuedNotReturned");
    }

    public static DataTable GetReportFines(DateTime? fromDate, DateTime? toDate, bool? paidOnly)
    {
        var prms = new[]
        {
            new SqlParameter("@FromDate", (object)fromDate ?? DBNull.Value),
            new SqlParameter("@ToDate",   (object)toDate   ?? DBNull.Value),
            new SqlParameter("@PaidOnly", (object)paidOnly   ?? DBNull.Value)
        };
        return ExecuteReader("dbo.sp_Report_Fines", prms);
    }

    public static DataTable GetReportMemberWise(int? memberID)
    {
        var prms = new[]
        {
            new SqlParameter("@MemberID", (object)memberID ?? DBNull.Value)
        };
        return ExecuteReader("dbo.sp_Report_MemberWise", prms);
    }

    public static DataTable GetReportBooks()
    {
        return ExecuteReader("dbo.sp_Report_Books");
    }

    public static DataTable GetReportReservations(DateTime? fromDate, DateTime? toDate, byte? statusID)
    {
        var prms = new[]
        {
            new SqlParameter("@FromDate", (object)fromDate ?? DBNull.Value),
            new SqlParameter("@ToDate",   (object)toDate   ?? DBNull.Value),
            new SqlParameter("@StatusID", (object)statusID ?? DBNull.Value)
        };
        return ExecuteReader("dbo.sp_Report_Reservations", prms);
    }

    public static DataTable GetReportShelfBooks()
    {
        string query = @"
            SELECT 
                cp.CopyID,
                cp.Barcode,
                b.Title,
                c.CatName AS Category,
                l.LangName AS Language,
                (SELECT STRING_AGG(a.FullName, ', ') WITHIN GROUP (ORDER BY ba.SortOrder)
                 FROM BookAuthors ba JOIN Authors a ON ba.AuthorID = a.AuthorID
                 WHERE ba.BookID = b.BookID) AS Authors,
                ISNULL(h.HallCode + ' - ' + h.HallName, '-') AS Hall,
                ISNULL(su.UnitCode, '-') AS [Aisle/Unit],
                ISNULL(CAST(r.RackNo AS VARCHAR(5)), '-') AS [Rack#],
                ISNULL(CAST(cp.SlotNo AS VARCHAR(5)), '-') AS [Slot#],
                cond.CondName AS [Condition],
                CASE WHEN cp.IsAvailable = 1 THEN 'On Shelf' ELSE 'Checked Out' END AS [Status]
            FROM BookCopies cp
            JOIN Books b ON cp.BookID = b.BookID
            JOIN Categories c ON b.CatID = c.CatID
            JOIN Languages l ON b.LangID = l.LangID
            JOIN CopyConditions cond ON cp.CondID = cond.CondID
            LEFT JOIN Racks r ON cp.RackID = r.RackID
            LEFT JOIN ShelfUnits su ON r.UnitID = su.UnitID
            LEFT JOIN Halls h ON su.HallID = h.HallID
            ORDER BY h.HallCode, su.UnitCode, r.RackNo, cp.SlotNo, b.Title";
        return GetTableData(query);
    }



    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Lookups for DropDowns
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    public static DataTable GetCategories()
    {
        return GetCachedTable("Categories", "SELECT CatID, CatName FROM Categories WHERE IsActive = 1 ORDER BY CatName");
    }

    public static DataTable GetPublishers()
    {
        return GetCachedTable("Publishers", "SELECT PubID, PubName FROM Publishers WHERE IsActive = 1 ORDER BY PubName");
    }

    public static DataTable GetAuthors()
    {
        return GetCachedTable("Authors", "SELECT AuthorID, FullName FROM Authors WHERE IsActive = 1 ORDER BY FullName");
    }

    public static DataTable GetLanguages()
    {
        return GetCachedTable("Languages", "SELECT LangID, LangCode, LangName FROM Languages ORDER BY LangName");
    }

    public static DataTable GetHalls()
    {
        return GetCachedTable("Halls", "SELECT HallID, HallCode + ' - ' + HallName AS HallDisplay FROM Halls WHERE IsActive = 1 ORDER BY HallName");
    }

    public static DataTable GetAisles(short hallID)
    {
        return GetTableData("SELECT UnitID AS AisleID, UnitCode + ' (' + ISNULL(UnitName, 'Unit') + ')' AS AisleDisplay FROM ShelfUnits WHERE HallID = " + hallID + " ORDER BY UnitCode");
    }

    public static DataTable GetShelfUnits(int unitID)
    {
        return GetTableData("SELECT RackID AS ShelfUnitID, 'Rack ' + CAST(RackNo AS VARCHAR) + ' - ' + ISNULL(SubjectTag, '') AS ShelfUnitCode FROM Racks WHERE UnitID = " + unitID + " ORDER BY RackNo");
    }

    public static DataTable GetRacks(int rackID)
    {
        return GetTableData("SELECT RackID, 'Visual Slots Mapping' AS RackDisplay, TotalSlots FROM Racks WHERE RackID = " + rackID);
    }

    public static DataTable GetMembers(string search = null)
    {
        if (string.IsNullOrEmpty(search))
        {
            return GetTableData("SELECT TOP 100 MemberID, MemberNo AS MembershipNo, MemberName AS FullName, MemberNo + ' - ' + MemberName AS MemberDisplay, 1 AS Priority, CAST(MemberID AS VARCHAR(20)) + '|' + MemberNo AS UniqueMemberValue FROM MemberShip.dbo.MemberProfile WHERE IsActive = '1' ORDER BY MemberName");
        }
        else
        {
            string cleanSearch = search.Replace("'", "''");
            string query = @"
                SELECT TOP 200 MemberID, MembershipNo, FullName, MemberDisplay, Priority, CAST(MemberID AS VARCHAR(20)) + '|' + MembershipNo AS UniqueMemberValue
                FROM (
                    SELECT 
                        MemberID, 
                        MemberNo AS MembershipNo, 
                        MemberName AS FullName, 
                        MemberNo + ' - ' + MemberName AS MemberDisplay,
                        MemberName AS OrderName,
                        1 AS Priority
                    FROM MemberShip.dbo.MemberProfile
                    WHERE IsActive = '1' 
                      AND (MemberNo LIKE '%" + cleanSearch + @"%' OR MemberName LIKE '%" + cleanSearch + @"%')
                      
                    UNION ALL
                    
                    SELECT 
                        mp.MemberID,
                        ms.MembershipNo,
                        ms.SpouseName AS FullName,
                        ms.MembershipNo + ' - ' + ms.SpouseName + ' (Spouse of ' + mp.MemberName + ')' AS MemberDisplay,
                        mp.MemberName AS OrderName,
                        2 AS Priority
                    FROM MemberShip.dbo.MemberSpouses ms
                    JOIN MemberShip.dbo.MemberProfile mp ON ms.MemberID = mp.MemberID
                    WHERE mp.IsActive = '1' 
                      AND ms.RecordStatus = 'Active'
                      AND (ms.MembershipNo LIKE '%" + cleanSearch + @"%' OR ms.SpouseName LIKE '%" + cleanSearch + @"%')
                      
                    UNION ALL
                    
                    SELECT 
                        mp.MemberID,
                        mc.MembershipNo,
                        mc.ChildName AS FullName,
                        mc.MembershipNo + ' - ' + mc.ChildName + ' (' + mc.Relationship + ' of ' + mp.MemberName + ')' AS MemberDisplay,
                        mp.MemberName AS OrderName,
                        3 AS Priority
                    FROM MemberShip.dbo.MemberChildren mc
                    JOIN MemberShip.dbo.MemberProfile mp ON mc.MemberID = mp.MemberID
                    WHERE mp.IsActive = '1' 
                      AND mc.RecordStatus = 'Active'
                      AND (mc.MembershipNo LIKE '%" + cleanSearch + @"%' OR mc.ChildName LIKE '%" + cleanSearch + @"%')
                ) AS Combined
                ORDER BY Priority, OrderName";
            return GetTableData(query);
        }
    }

    public static DataTable GetCopyConditions()
    {
        return GetCachedTable("CopyConditions", "SELECT CondID, CondName FROM CopyConditions ORDER BY CondID");
    }

    public static DataTable GetStaffList()
    {
        return GetCachedTable("StaffList", @"
            SELECT e.EmpID AS StaffID, 
                   ISNULL(e.EFName, '') + ' ' + ISNULL(e.ELName, '') AS FullName, 
                   l.UserName AS Username 
            FROM User_management.dbo.Employee e
            INNER JOIN User_management.dbo.Login l ON e.EmpID = l.EmpID
            ORDER BY e.EFName");
    }

    /// <summary>
    /// Returns the occupancy grid list of 1 to TotalSlots with IsOccupied indicator for slot mapping.
    /// </summary>
    public static DataTable GetRackSlots(short rackID, int totalSlots)
    { 
        var dt = new DataTable();
        dt.Columns.Add("SlotNumber", typeof(int));
        dt.Columns.Add("IsOccupied", typeof(bool));
        dt.Columns.Add("BookTitle", typeof(string));
        dt.Columns.Add("RackID", typeof(short));

        // Get occupied slots in this rack
        var occupiedDt = GetTableData("SELECT cp.SlotNo, b.Title FROM BookCopies cp JOIN Books b ON cp.BookID = b.BookID WHERE cp.RackID = " + rackID + " AND cp.SlotNo IS NOT NULL");

        var occupied = new Dictionary<int, string>();
        foreach (DataRow row in occupiedDt.Rows)
        {
            int slot = Convert.ToInt32(row["SlotNo"]);
            occupied[slot] = row["Title"] != DBNull.Value && row["Title"] != null ? row["Title"].ToString() : "";
        }

        for (int i = 1; i <= totalSlots; i++)
        {
            var r = dt.NewRow();
            r["SlotNumber"] = i;
            r["IsOccupied"] = occupied.ContainsKey(i);
            r["BookTitle"] = occupied.ContainsKey(i) ? occupied[i] : "";
            r["RackID"] = rackID;
            dt.Rows.Add(r);
        }

        return dt;
    }

    // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    //  Define / Setup Helpers (Stored Procedures Only)
    // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    public static string DefineAuthor(int? authorID, string firstName, string lastName, string nationality, bool isActive)
    {
        var prms = new[]
        {
            new SqlParameter("@AuthorID",    (object)authorID ?? DBNull.Value),
            new SqlParameter("@FirstName",   firstName),
            new SqlParameter("@LastName",    lastName),
            new SqlParameter("@Nationality", (object)nationality ?? DBNull.Value),
            new SqlParameter("@IsActive",    isActive),
            new SqlParameter("@Msg",         SqlDbType.NVarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("sp_DefineAuthor", prms);
        ClearCache("Authors");
        ClearCache("AuthorsGrid");
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static string DefineStaffRole(byte? roleID, string roleName, bool isActive)
    {
        var prms = new[]
        {
            new SqlParameter("@RoleID",   (object)roleID ?? DBNull.Value),
            new SqlParameter("@RoleName", roleName),
            new SqlParameter("@IsActive", isActive),
            new SqlParameter("@Msg",      SqlDbType.NVarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("sp_DefineStaffRole", prms);
        ClearCache("StaffRolesGrid");
        ClearCache("StaffList");
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static string DefineCategory(short? catID, string catCode, string catName, short? parentCatID, bool isActive, string ddcPrefix)
    {
        var prms = new[]
        {
            new SqlParameter("@CatID",        (object)catID ?? DBNull.Value),
            new SqlParameter("@CatCode",      catCode),
            new SqlParameter("@CatName",      catName),
            new SqlParameter("@ParentCatID",  (object)parentCatID ?? DBNull.Value),
            new SqlParameter("@IsActive",     isActive),
            new SqlParameter("@DdcPrefix",    (object)ddcPrefix ?? DBNull.Value),
            new SqlParameter("@Msg",          SqlDbType.NVarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("sp_DefineCategory", prms);
        ClearCache("Categories");
        ClearCache("CategoriesGrid");
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static string DefinePublisher(short? pubID, string pubName, string country, bool isActive)
    {
        var prms = new[]
        {
            new SqlParameter("@PubID",    (object)pubID ?? DBNull.Value),
            new SqlParameter("@PubName",  pubName),
            new SqlParameter("@Country",  (object)country ?? DBNull.Value),
            new SqlParameter("@IsActive", isActive),
            new SqlParameter("@Msg",      SqlDbType.NVarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("sp_DefinePublisher", prms);
        ClearCache("Publishers");
        ClearCache("PublishersGrid");
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static string DefineHall(short? hallID, string hallCode, string hallName, byte floorNo, bool isActive)
    {
        var prms = new[]
        {
            new SqlParameter("@HallID",   (object)hallID ?? DBNull.Value),
            new SqlParameter("@HallCode", hallCode),
            new SqlParameter("@HallName", hallName),
            new SqlParameter("@FloorNo",  floorNo),
            new SqlParameter("@IsActive", isActive),
            new SqlParameter("@Msg",      SqlDbType.NVarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("sp_DefineHall", prms);
        ClearCache("Halls");
        ClearCache("HallsGrid");
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static string DefineShelfUnit(short? unitID, short hallID, string unitCode, string unitName, bool isActive)
    {
        var prms = new[]
        {
            new SqlParameter("@UnitID",   (object)unitID ?? DBNull.Value),
            new SqlParameter("@HallID",   hallID),
            new SqlParameter("@UnitCode", unitCode),
            new SqlParameter("@UnitName", (object)unitName ?? DBNull.Value),
            new SqlParameter("@IsActive", isActive),
            new SqlParameter("@Msg",      SqlDbType.NVarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("sp_DefineShelfUnit", prms);
        ClearCache("ShelfUnitsGrid");
        ClearCache("RacksGrid");
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static string DefineRack(short? rackID, short unitID, byte rackNo, byte totalSlots, string subjectTag, bool isActive)
    {
        var prms = new[]
        {
            new SqlParameter("@RackID",     (object)rackID ?? DBNull.Value),
            new SqlParameter("@UnitID",     unitID),
            new SqlParameter("@RackNo",     rackNo),
            new SqlParameter("@TotalSlots", totalSlots),
            new SqlParameter("@SubjectTag", (object)subjectTag ?? DBNull.Value),
            new SqlParameter("@IsActive",   isActive),
            new SqlParameter("@Msg",        SqlDbType.NVarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("sp_DefineRack", prms);
        ClearCache("RacksGrid");
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static string DefineLanguage(byte? langID, string langCode, string langName, bool isActive)
    {
        var prms = new[]
        {
            new SqlParameter("@LangID",   (object)langID ?? DBNull.Value),
            new SqlParameter("@LangCode", langCode),
            new SqlParameter("@LangName", langName),
            new SqlParameter("@IsActive", isActive),
            new SqlParameter("@Msg",      SqlDbType.NVarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("sp_DefineLanguage", prms);
        ClearCache("Languages");
        ClearCache("LanguagesGrid");
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static DataTable GetFloors()
    {
        return GetCachedTable("Floors", "SELECT FloorNo, FloorName FROM Floors ORDER BY FloorNo");
    }

    public static string DefineFloor(byte? floorNo, string floorName, bool isActive)
    {
        var prms = new[]
        {
            new SqlParameter("@FloorNo",   (object)floorNo ?? DBNull.Value),
            new SqlParameter("@FloorName", floorName),
            new SqlParameter("@IsActive",  isActive),
            new SqlParameter("@Msg",       SqlDbType.NVarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("sp_DefineFloor", prms);
        ClearCache("Floors");
        ClearCache("FloorsGrid");
        return GetOutputValue<string>(prms, "@Msg");
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Data Queries for Setup Grids (Retrieving Active & Inactive)
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    public static DataTable GetAuthorsGrid()
    {
        return GetCachedTable("AuthorsGrid", "SELECT AuthorID, FirstName, LastName, Nationality, IsActive FROM Authors ORDER BY FullName");
    }

    public static DataTable GetStaffRolesGrid()
    {
        return GetCachedTable("StaffRolesGrid", "SELECT RoleID, RoleName, IsActive FROM StaffRoles ORDER BY RoleID");
    }

    public static DataTable GetHallsGrid()
    {
        return GetCachedTable("HallsGrid", "SELECT h.HallID, h.HallCode, h.HallName, h.FloorNo, f.FloorName, h.IsActive FROM Halls h LEFT JOIN Floors f ON h.FloorNo = f.FloorNo ORDER BY h.HallName");
    }

    public static DataTable GetShelfUnitsGrid()
    {
        return GetCachedTable("ShelfUnitsGrid", "SELECT su.UnitID, su.HallID, h.HallName, su.UnitCode, su.UnitName, su.IsActive FROM ShelfUnits su JOIN Halls h ON su.HallID = h.HallID ORDER BY su.UnitCode");
    }

    public static DataTable GetRacksGrid()
    {
        return GetCachedTable("RacksGrid", "SELECT r.RackID, r.UnitID, su.UnitCode, r.RackNo, r.TotalSlots, r.SubjectTag, r.IsActive FROM Racks r JOIN ShelfUnits su ON r.UnitID = su.UnitID ORDER BY su.UnitCode, r.RackNo");
    }

    public static DataTable GetCategoriesGrid()
    {
        return GetCachedTable("CategoriesGrid", "SELECT c.CatID, c.CatCode, c.CatName, c.ParentCatID, p.CatName AS ParentCatName, c.IsActive, c.DdcPrefix FROM Categories c LEFT JOIN Categories p ON c.ParentCatID = p.CatID ORDER BY c.CatName");
    }

    public static DataTable GetPublishersGrid()
    {
        return GetCachedTable("PublishersGrid", "SELECT PubID, PubName, Country, IsActive FROM Publishers ORDER BY PubName");
    }

    public static DataTable GetLanguagesGrid()
    {
        return GetCachedTable("LanguagesGrid", "SELECT LangID, LangCode, LangName, IsActive FROM Languages ORDER BY LangName");
    }

    public static DataTable GetFloorsGrid()
    {
        return GetCachedTable("FloorsGrid", "SELECT FloorNo, FloorName, IsActive FROM Floors ORDER BY FloorNo");
    }

    public static DataTable SearchBooksAdvanced(
        string term, string author, string bookName, 
        string edition, short? pubID, short? catID, 
        byte? langID, short? year, string ddc = null)
    {
        var prms = new[]
        {
            new SqlParameter("@Term",      (object)term     ?? DBNull.Value),
            new SqlParameter("@Author",    (object)author   ?? DBNull.Value),
            new SqlParameter("@BookName",  (object)bookName ?? DBNull.Value),
            new SqlParameter("@Edition",   (object)edition  ?? DBNull.Value),
            new SqlParameter("@PubID",     (object)pubID    ?? DBNull.Value),
            new SqlParameter("@CatID",     (object)catID    ?? DBNull.Value),
            new SqlParameter("@LangID",    (object)langID   ?? DBNull.Value),
            new SqlParameter("@Year",      (object)year     ?? DBNull.Value),
            new SqlParameter("@DDC",       (object)ddc      ?? DBNull.Value)
        };
        return ExecuteReader("sp_SearchBooksAdvanced", prms);
    }

    public static string GetNextISBNSuffix(string basePrefix)
    {
        string query = "SELECT ISBN13 FROM Books WHERE ISBN13 LIKE '" + basePrefix.Replace("'", "''") + "%'";
        DataTable dt = GetTableData(query);
        int maxSeq = 0;
        foreach (DataRow row in dt.Rows)
        {
            string isbn = row["ISBN13"].ToString();
            if (isbn.StartsWith(basePrefix))
            {
                string suffixPart = isbn.Substring(basePrefix.Length);
                suffixPart = System.Text.RegularExpressions.Regex.Replace(suffixPart, "[^0-9]", "");
                int seq;
                if (int.TryParse(suffixPart, out seq))
                {
                    if (seq > maxSeq) maxSeq = seq;
                }
            }
        }
        return (maxSeq + 1).ToString("000");
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Facilities & Fine Reasons Setup
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    public static DataTable GetFacilities()
    {
        return ExecuteReader("sp_GetFacilities");
    }

    public static string DefineFacility(int? facilityID, string facilityName, decimal costPerHour, bool isActive)
    {
        var prms = new[]
        {
            new SqlParameter("@FacilityID",   (object)facilityID ?? DBNull.Value),
            new SqlParameter("@FacilityName", facilityName),
            new SqlParameter("@CostPerHour",  costPerHour),
            new SqlParameter("@IsActive",     isActive),
            new SqlParameter("@Msg",          SqlDbType.NVarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("sp_DefineFacility", prms);
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static DataTable GetFineReasons()
    {
        return ExecuteReader("sp_GetFineReasons");
    }

    public static string DefineFineReason(byte? reasonID, string reasonName, decimal defaultAmount)
    {
        var prms = new[]
        {
            new SqlParameter("@ReasonID",      (object)reasonID ?? DBNull.Value),
            new SqlParameter("@ReasonName",    reasonName),
            new SqlParameter("@DefaultAmount", defaultAmount),
            new SqlParameter("@Msg",           SqlDbType.NVarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("sp_DefineFineReason", prms);
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static DataTable GetMemberLedger(int memberID, DateTime? startDate, DateTime? endDate, int? month, int? year)
    {
        var prms = new[]
        {
            new SqlParameter("@MemberID",   memberID),
            new SqlParameter("@StartDate",  (object)startDate ?? DBNull.Value),
            new SqlParameter("@EndDate",    (object)endDate   ?? DBNull.Value),
            new SqlParameter("@Month",      (object)month     ?? DBNull.Value),
            new SqlParameter("@Year",       (object)year      ?? DBNull.Value)
        };
        return ExecuteReader("dbo.sp_GetMemberLedger", prms);
    }

    public static DataRow GetMemberDetails(int memberID)
    {
        string query = @"
           SELECT 
                m.MemberID, mt.MemberNo, mt.MemberName, mt.NIC, mt.Phone, mt.ResidentialEmail, mt.MemberSince, m.ExpiryDate, m.IsActive,
                mt.MemberType AS MemberType,
                (SELECT COUNT(*) FROM Loans WHERE MemberID = mt.MemberID) AS TotalLoans,
                (SELECT COUNT(*) FROM Loans WHERE MemberID = mt.MemberID AND StatusID IN (1,3,4)) AS ActiveLoans,
                (SELECT ISNULL(SUM(FineAmount), 0) FROM Fines WHERE MemberID = mt.MemberID) AS TotalFines,
                (SELECT ISNULL(SUM(FineAmount), 0) FROM Fines WHERE MemberID = mt.MemberID AND IsPaid = 0) AS OutstandingFines
            FROM membership.dbo.memberprofile mt
            JOIN Members m ON m.MemberID = mt.Memberid
            WHERE m.MemberID = " + memberID;
        DataTable dt = GetTableData(query);
        if (dt.Rows.Count > 0) return dt.Rows[0];
        return null;
    }

    public static void ExecuteSql(string sql)
    {
        using (var con = GetConnection())
        using (var cmd = new SqlCommand(sql, con) { CommandTimeout = 120 })
        {
            con.Open();
            cmd.ExecuteNonQuery();
        }
    }

    public static void PayFine(int fineID, short staffID = 0)
    {
        ExecuteSql("UPDATE Fines SET IsPaid = 1, PaidAt = SYSDATETIME(), CollectedByID = " + staffID + " WHERE FineID = " + fineID);
    }

    public static void PayFacilityBooking(int bookingID)
    {
        ExecuteSql("UPDATE FacilityBookings SET IsPaid = 1, PaidAt = SYSDATETIME() WHERE BookingID = " + bookingID);
    }

    public static void ChargeFacility(int memberID, int facilityID, DateTime usageDate, decimal hoursUsed, decimal totalCharges, string remarks, short staffID = 0)
    {
        string query = @"
            EXEC dbo.sp_EnsureMemberExists @MemberID;
            INSERT INTO FacilityBookings (MemberID, FacilityID, UsageDate, HoursUsed, TotalCharges, IsPaid, Remarks, ChargedByID)
            VALUES (@MemberID, @FacilityID, @UsageDate, @HoursUsed, @TotalCharges, 0, @Remarks, @StaffID)";
        
        using (var con = GetConnection())
        using (var cmd = new SqlCommand(query, con))
        {
            cmd.Parameters.AddWithValue("@MemberID", memberID);
            cmd.Parameters.AddWithValue("@FacilityID", facilityID);
            cmd.Parameters.AddWithValue("@UsageDate", usageDate.Date);
            cmd.Parameters.AddWithValue("@HoursUsed", hoursUsed);
            cmd.Parameters.AddWithValue("@TotalCharges", totalCharges);
            cmd.Parameters.AddWithValue("@Remarks", (object)remarks ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@StaffID", staffID > 0 ? (object)staffID : DBNull.Value);
            con.Open();
            cmd.ExecuteNonQuery();
        }
    }

    public static void ChargeFine(int memberID, byte reasonID, int? loanID, decimal fineAmount, string remarks, short staffID = 0)
    {
        string query = @"
            EXEC dbo.sp_EnsureMemberExists @MemberID;
            INSERT INTO Fines (LoanID, MemberID, ReasonID, FineAmount, IsPaid, Remarks, ChargedByID)
            VALUES (@LoanID, @MemberID, @ReasonID, @FineAmount, 0, @Remarks, @StaffID)";
        
        using (var con = GetConnection())
        using (var cmd = new SqlCommand(query, con))
        {
            cmd.Parameters.AddWithValue("@LoanID", (object)loanID ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@MemberID", memberID);
            cmd.Parameters.AddWithValue("@ReasonID", reasonID);
            cmd.Parameters.AddWithValue("@FineAmount", fineAmount);
            cmd.Parameters.AddWithValue("@Remarks", (object)remarks ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@StaffID", staffID > 0 ? (object)staffID : DBNull.Value);
            con.Open();
            cmd.ExecuteNonQuery();
        }
    }

    public static DataSet GetUnpaidItemsForVoucher(int memberID)
    {
        var ds = new DataSet();
        string query = @"
            SELECT f.FineID, f.CreatedAt AS TxnDate, fr.ReasonName AS Description, f.FineAmount AS Amount, ISNULL(f.Remarks, '') AS Remarks
            FROM Fines f
            JOIN FineReasons fr ON f.ReasonID = fr.ReasonID
            WHERE f.MemberID = @MemberID AND f.IsPaid = 0 AND f.VoucherID IS NULL;

            SELECT fb.BookingID, fb.UsageDate AS TxnDate, fac.FacilityName AS Description, fb.TotalCharges AS Amount, ISNULL(fb.Remarks, '') AS Remarks
            FROM FacilityBookings fb
            JOIN Facilities fac ON fb.FacilityID = fac.FacilityID
            WHERE fb.MemberID = @MemberID AND fb.IsPaid = 0 AND fb.VoucherID IS NULL;";

        using (var con = GetConnection())
        using (var cmd = new SqlCommand(query, con))
        using (var da = new SqlDataAdapter(cmd))
        {
            cmd.Parameters.AddWithValue("@MemberID", memberID);
            con.Open();
            da.Fill(ds);
        }
        return ds;
    }

    public static string GenerateVoucher(int memberID, string fineIDs, string bookingIDs, string paymentMode, string remarks, short staffID = 0)
    {
        var prms = new[]
        {
            new SqlParameter("@MemberID", memberID),
            new SqlParameter("@FineIDs", (object)fineIDs ?? DBNull.Value),
            new SqlParameter("@BookingIDs", (object)bookingIDs ?? DBNull.Value),
            new SqlParameter("@PaymentMode", paymentMode),
            new SqlParameter("@Remarks", (object)remarks ?? DBNull.Value),
            new SqlParameter("@IssuedByID", staffID > 0 ? (object)staffID : DBNull.Value),
            new SqlParameter("@VoucherNo", SqlDbType.VarChar, 30) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("dbo.sp_GenerateVoucher", prms);
        return GetOutputValue<string>(prms, "@VoucherNo");
    }

    public static string PayVoucher(string voucherNo, short staffID = 0)
    {
        var prms = new[]
        {
            new SqlParameter("@VoucherNo", voucherNo),
            new SqlParameter("@CollectedByID", staffID > 0 ? (object)staffID : DBNull.Value),
            new SqlParameter("@Msg", SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("dbo.sp_PayVoucher", prms);
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static DataSet GetVoucherDetails(string voucherNo)
    {
        var ds = new DataSet();
        string query = @"
            SELECT v.VoucherID, v.VoucherNo, v.IssueDate, v.Amount, v.PaymentMode, v.IsPaid, v.PaidAt, v.Remarks,
                   m.MembershipNo, m.FullName, mt.TypeName AS MemberType
            FROM Vouchers v
            JOIN Members m ON v.MemberID = m.MemberID
            JOIN MemberTypes mt ON m.MTypeID = mt.MTypeID
            WHERE v.VoucherNo = @VoucherNo;

            -- Get linked Fines
            SELECT 'Library Fine' AS ItemType, fr.ReasonName AS Description, f.FineAmount AS Amount, ISNULL(f.Remarks, '') AS Remarks
            FROM Fines f
            JOIN FineReasons fr ON f.ReasonID = fr.ReasonID
            JOIN Vouchers v ON f.VoucherID = v.VoucherID
            WHERE v.VoucherNo = @VoucherNo;

            -- Get linked Bookings
            SELECT 'Facility Booking' AS ItemType, fac.FacilityName AS Description, fb.TotalCharges AS Amount, ISNULL(fb.Remarks, '') AS Remarks
            FROM FacilityBookings fb
            JOIN Facilities fac ON fb.FacilityID = fac.FacilityID
            JOIN Vouchers v ON fb.VoucherID = v.VoucherID
            WHERE v.VoucherNo = @VoucherNo;";

        using (var con = GetConnection())
        using (var cmd = new SqlCommand(query, con))
        using (var da = new SqlDataAdapter(cmd))
        {
            cmd.Parameters.AddWithValue("@VoucherNo", voucherNo);
            con.Open();
            da.Fill(ds);
        }
        return ds;
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Complaint & Feedback System
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    public static SqlConnection GetBasicDataConnection()
    {
        string connStr = ConfigurationManager.ConnectionStrings["Basic_Data_ConnectionString"] != null 
            ? ConfigurationManager.ConnectionStrings["Basic_Data_ConnectionString"].ConnectionString 
            : "Data Source=.\\LOCALHOST;Initial Catalog=BasicDataInfo;Integrated Security=True;TrustServerCertificate=True;";
        return new SqlConnection(connStr);
    }

    public static DataTable GetBasicDataTableData(string query)
    {
        var dt = new DataTable();
        using (var con = GetBasicDataConnection())
        using (var cmd = new SqlCommand(query, con) { CommandTimeout = 120 })
        using (var da = new SqlDataAdapter(cmd))
        {
            con.Open();
            da.Fill(dt);
        }
        return dt;
    }

    public static DataTable GetDepartments()
    {
        return GetBasicDataTableData("SELECT Dept_ID, Dept_Name FROM Department ORDER BY Dept_Name");
    }

    public static DataTable GetSubDepartments(int deptID)
    {
        return GetBasicDataTableData("SELECT SubDept_Id, SubDept_Name FROM SubDepartment WHERE Dept_Id = " + deptID + " ORDER BY SubDept_Name");
    }

    public static DataTable GetFeedbackQuestions(int deptID, int? subDeptID, bool activeOnly)
    {
        var prms = new[]
        {
            new SqlParameter("@DeptID", deptID),
            new SqlParameter("@SubDeptID", (object)subDeptID ?? DBNull.Value),
            new SqlParameter("@ActiveOnly", activeOnly)
        };
        return ExecuteReader("dbo.sp_GetFeedbackQuestions", prms);
    }

    public static DataTable GetAllFeedbackQuestions()
    {
        return ExecuteReader("dbo.sp_GetAllFeedbackQuestions");
    }

    public static string SaveFeedbackQuestion(int? questionID, int deptID, int? subDeptID, string text, bool isActive)
    {
        var prms = new[]
        {
            new SqlParameter("@QuestionID",   (object)questionID ?? DBNull.Value),
            new SqlParameter("@DeptID",       deptID),
            new SqlParameter("@SubDeptID",    (object)subDeptID ?? DBNull.Value),
            new SqlParameter("@QuestionText", text),
            new SqlParameter("@IsActive",      isActive),
            new SqlParameter("@Msg",           SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("dbo.sp_SaveFeedbackQuestion", prms);
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static string SubmitFeedbackMultiple(int deptID, int? subDeptID, string memberNo, string comments, string ratingsXml)
    {
        var prms = new[]
        {
            new SqlParameter("@DeptID",          deptID),
            new SqlParameter("@SubDeptID",       (object)subDeptID ?? DBNull.Value),
            new SqlParameter("@MemberNo",        (object)memberNo ?? DBNull.Value),
            new SqlParameter("@GeneralComments", (object)comments ?? DBNull.Value),
            new SqlParameter("@RatingsXml",      ratingsXml),
            new SqlParameter("@Msg",             SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("dbo.sp_SubmitFeedbackMultiple", prms);
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static string SubmitComplaint(int? deptID, int? subDeptID, string memberNo, string subject, string detail)
    {
        var prms = new[]
        {
            new SqlParameter("@DeptID",           (object)deptID ?? DBNull.Value),
            new SqlParameter("@SubDeptID",        (object)subDeptID ?? DBNull.Value),
            new SqlParameter("@MemberNo",         (object)memberNo ?? DBNull.Value),
            new SqlParameter("@ComplaintSubject",  subject),
            new SqlParameter("@ComplaintDetail",   detail),
            new SqlParameter("@Msg",              SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("dbo.sp_SubmitComplaint", prms);
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static DataTable GetComplaints(int? deptID, int? subDeptID, string recordType, string status, DateTime? fromDate, DateTime? toDate)
    {
        var prms = new[]
        {
            new SqlParameter("@DeptID",     (object)deptID ?? DBNull.Value),
            new SqlParameter("@SubDeptID",  (object)subDeptID ?? DBNull.Value),
            new SqlParameter("@RecordType", (object)recordType ?? DBNull.Value),
            new SqlParameter("@Status",     (object)status ?? DBNull.Value),
            new SqlParameter("@FromDate",   (object)fromDate ?? DBNull.Value),
            new SqlParameter("@ToDate",     (object)toDate ?? DBNull.Value)
        };
        return ExecuteReader("dbo.sp_GetFeedbackAndComplaints", prms);
    }

    public static string UpdateComplaintStatus(int complaintID, string recordType, string status, string remarks)
    {
        var prms = new[]
        {
            new SqlParameter("@ComplaintID", complaintID),
            new SqlParameter("@RecordType",  recordType),
            new SqlParameter("@Status",      status),
            new SqlParameter("@Remarks",     remarks),
            new SqlParameter("@Msg",         SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("dbo.sp_UpdateComplaintStatus", prms);
        return GetOutputValue<string>(prms, "@Msg");
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Employee Interdepartmental Complaints
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    public static DataTable GetEmployees()
    {
        return GetBasicDataTableData("SELECT EmpID, EFName AS EmployeeName FROM Employee WHERE EFName IS NOT NULL AND EFName <> '' ORDER BY EFName");
    }

    public static string SubmitEmployeeComplaint(decimal senderEmpID, int targetDeptID, int? targetSubDeptID, string subject, string detail)
    {
        var prms = new[]
        {
            new SqlParameter("@SenderEmpID",     senderEmpID),
            new SqlParameter("@TargetDeptID",     targetDeptID),
            new SqlParameter("@TargetSubDeptID",  (object)targetSubDeptID ?? DBNull.Value),
            new SqlParameter("@Subject",          subject),
            new SqlParameter("@Detail",           detail),
            new SqlParameter("@Msg",              SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("dbo.sp_SubmitEmployeeComplaint", prms);
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static DataTable GetEmployeeComplaints(int? senderDeptID, int? targetDeptID, int? targetSubDeptID, string status, DateTime? fromDate, DateTime? toDate)
    {
        var prms = new[]
        {
            new SqlParameter("@SenderDeptID",    (object)senderDeptID ?? DBNull.Value),
            new SqlParameter("@TargetDeptID",    (object)targetDeptID ?? DBNull.Value),
            new SqlParameter("@TargetSubDeptID", (object)targetSubDeptID ?? DBNull.Value),
            new SqlParameter("@Status",          (object)status ?? DBNull.Value),
            new SqlParameter("@FromDate",        (object)fromDate ?? DBNull.Value),
            new SqlParameter("@ToDate",          (object)toDate ?? DBNull.Value)
        };
        return ExecuteReader("dbo.sp_GetEmployeeComplaints", prms);
    }

    public static string UpdateEmployeeComplaintStatus(int empComplaintID, string status, string remarks)
    {
        var prms = new[]
        {
            new SqlParameter("@EmpComplaintID", empComplaintID),
            new SqlParameter("@Status",         status),
            new SqlParameter("@Remarks",        remarks),
            new SqlParameter("@Msg",            SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("dbo.sp_UpdateEmployeeComplaintStatus", prms);
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static string SendEmployeeComplaintReminder(int empComplaintID)
    {
        var prms = new[]
        {
            new SqlParameter("@EmpComplaintID", empComplaintID),
            new SqlParameter("@Msg",            SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("dbo.sp_SendEmployeeComplaintReminder", prms);
        return GetOutputValue<string>(prms, "@Msg");
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Book Weeding & Restoration Methods
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    public static string WeedFullBook(int bookID, string remarks, short staffID)
    {
        var prms = new[]
        {
            new SqlParameter("@BookID",  bookID),
            new SqlParameter("@Remarks", (object)remarks ?? DBNull.Value),
            new SqlParameter("@StaffID", staffID),
            new SqlParameter("@Msg",     SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("dbo.sp_WeedFullBook", prms);
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static string WeedSingleCopy(int copyID, string remarks, short staffID)
    {
        var prms = new[]
        {
            new SqlParameter("@CopyID",  copyID),
            new SqlParameter("@Remarks", (object)remarks ?? DBNull.Value),
            new SqlParameter("@StaffID", staffID),
            new SqlParameter("@Msg",     SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("dbo.sp_WeedSingleCopy", prms);
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static string RestoreCopy(int copyID, byte condID, short rackID, byte slotNo, string remarks, short staffID)
    {
        var prms = new[]
        {
            new SqlParameter("@CopyID",  copyID),
            new SqlParameter("@CondID",  condID),
            new SqlParameter("@RackID",  rackID),
            new SqlParameter("@SlotNo",  slotNo),
            new SqlParameter("@Remarks", (object)remarks ?? DBNull.Value),
            new SqlParameter("@StaffID", staffID),
            new SqlParameter("@Msg",     SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("dbo.sp_RestoreCopy", prms);
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static DataTable GetWeedLogReport(DateTime? fromDate, DateTime? toDate, string searchTerm, string actionType)
    {
        var prms = new[]
        {
            new SqlParameter("@FromDate",   (object)fromDate ?? DBNull.Value),
            new SqlParameter("@ToDate",     (object)toDate   ?? DBNull.Value),
            new SqlParameter("@SearchTerm", (object)searchTerm ?? DBNull.Value),
            new SqlParameter("@ActionType", (object)actionType ?? DBNull.Value)
        };
        return ExecuteReader("dbo.sp_GetWeedLogReport", prms);
    }

    public static DataTable GetBookCopiesForWeeding(int bookID)
    {
        return ExecuteReader("dbo.sp_GetBookCopiesForWeeding", new SqlParameter("@BookID", bookID));
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Overdue Reminders and Reversals Methods
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    public static DataTable GetOverdueReminderList(int? scenario)
    {
        var prms = new[]
        {
            new SqlParameter("@Scenario", (object)scenario ?? DBNull.Value)
        };
        return ExecuteReader("dbo.sp_GetOverdueReminderList", prms);
    }

    public static string SendOverdueReminder(int loanID, int scenario)
    {
        var prms = new[]
        {
            new SqlParameter("@LoanID", loanID),
            new SqlParameter("@Scenario", scenario),
            new SqlParameter("@Msg", SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("dbo.sp_SendOverdueReminder", prms);
        return GetOutputValue<string>(prms, "@Msg");
    }

    public static DataTable GetFinalChargedLoans()
    {
        return ExecuteReader("dbo.sp_GetFinalChargedLoans");
    }

    public static string ReverseOverdueCharges(int loanID, short staffID, out string voucherNo)
    {
        var prms = new[]
        {
            new SqlParameter("@LoanID", loanID),
            new SqlParameter("@StaffID", staffID),
            new SqlParameter("@VoucherNo", SqlDbType.VarChar, 30) { Direction = ParameterDirection.Output },
            new SqlParameter("@Msg", SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
        };
        ExecuteNonQuery("dbo.sp_ReverseOverdueCharges", prms);
        voucherNo = GetOutputValue<string>(prms, "@VoucherNo");
        return GetOutputValue<string>(prms, "@Msg");
    }
}


public class SaveBookResult
{
    public int NewBookID { get; set; }
    public string Result { get; set; }
}

public class AddBookCopyResult
{
    public int CopyID { get; set; }
    public string Barcode { get; set; }
    public string Result { get; set; }
}





/// <summary>
/// ISBN-13 (EAN-13) validation, formatting, and conversion utilities.
/// Spec: https://www.isbn-international.org/content/what-isbn
/// </summary>
public static class ISBN13Helper
{
    // Strip hyphens and spaces â†’ clean 13-digit string
    public static string Normalise(string isbn)
    {
        return isbn == null ? "" : Regex.Replace(isbn, @"[\s\-]", "");
    }

    /// <summary>Validate ISBN-13 check digit (modulo-10, weights 1 and 3).</summary>
    public static bool IsValid(string isbn)
    {
        string clean = Normalise(isbn);
        if (clean.Length != 13 || !Regex.IsMatch(clean, @"^\d{13}$")) return false;
        if (!clean.StartsWith("978") && !clean.StartsWith("979")) return false;

        int sum = 0;
        for (int i = 0; i < 12; i++)
            sum += (int)char.GetNumericValue(clean[i]) * (i % 2 == 0 ? 1 : 3);

        int check = (10 - (sum % 10)) % 10;
        return check == (int)char.GetNumericValue(clean[12]);
    }

    /// <summary>Calculate correct check digit for a 12-digit ISBN prefix.</summary>
    public static int CalculateCheckDigit(string first12)
    {
        string clean = Normalise(first12);
        if (clean.Length != 12 || !Regex.IsMatch(clean, @"^\d{12}$"))
            throw new ArgumentException("Input must be exactly 12 digits.");
        int sum = 0;
        for (int i = 0; i < 12; i++)
            sum += (int)char.GetNumericValue(clean[i]) * (i % 2 == 0 ? 1 : 3);
        return (10 - (sum % 10)) % 10;
    }

    /// <summary>
    /// Format ISBN-13 as 978-X-XXX-XXXXX-X for display.
    /// Uses a simple 3-1-3-5-1 split (standard Bookland/EAN prefix groups).
    /// </summary>
    public static string Format(string isbn)
    {
        string clean = Normalise(isbn);
        if (clean.Length != 13) return isbn;
        // 978-[1]-[3]-[5]-[1]
        return clean.Substring(0,3) + "-" + clean[3] + "-" + clean.Substring(4,3) + "-" + clean.Substring(7,5) + "-" + clean[12];
    }

    /// <summary>Convert legacy ISBN-10 to ISBN-13.</summary>
    public static string FromISBN10(string isbn10)
    {
        string clean = Normalise(isbn10);
        if (clean.Length != 10 || !Regex.IsMatch(clean.Substring(0,9), @"^\d{9}$"))
            throw new ArgumentException("Invalid ISBN-10.");
        string prefix12 = "978" + clean.Substring(0, 9);
        int check = CalculateCheckDigit(prefix12);
        return prefix12 + check;
    }

    /// <summary>Returns just the clean 13-digit string or throws if invalid.</summary>
    public static string Parse(string input)
    {
        string clean = Normalise(input);
        if (!IsValid(clean))
            throw new FormatException("'" + input + "' is not a valid ISBN-13.");
        return clean;
    }

    /// <summary>Generate a barcode string for a physical copy: ISBN13-001, ISBN13-002â€¦</summary>
    public static string GenerateCopyBarcode(string isbn13, int copyNumber)
    {
        return Normalise(isbn13) + "-" + copyNumber.ToString("000");
    }
}

    #endregion
}

