using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Pages_Stock_StockTracking : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // 1. Session authorization check
        if (Session["Emp_ID"] == null || Session["UserName"] == null)
        {
            Response.Redirect("~/Login.aspx");
            return;
        }

        if (!IsPostBack)
        {
            // Set initial state
            ViewState["SortColumn"] = "Barcode";
            ViewState["SortDirection"] = "ASC";
            
            // Populate lookups
            BindFilterLookups();
            BindTransferHalls();
            
            // Sync audit session and statistics
            CheckActiveAuditSession();
            RefreshDashboardStats();
            
            // Bind default directory
            BindStockGrid();
        }
    }

    // =========================================================================
    //  LOOKUP BINDINGS
    // =========================================================================
    private void BindFilterLookups()
    {
        try
        {
            // Bind Categories
            DataTable dtCats = DBHelper.ExecuteReaderText("SELECT CatID, CatName FROM Categories WHERE IsActive = 1 ORDER BY CatName");
            ddlFilterCategory.DataSource = dtCats;
            ddlFilterCategory.DataValueField = "CatID";
            ddlFilterCategory.DataTextField = "CatName";
            ddlFilterCategory.DataBind();
            ddlFilterCategory.Items.Insert(0, new ListItem("-- All Categories --", ""));

            // Bind Languages
            DataTable dtLangs = DBHelper.ExecuteReaderText("SELECT LangID, LangName FROM Languages ORDER BY LangName");
            ddlFilterLanguage.DataSource = dtLangs;
            ddlFilterLanguage.DataValueField = "LangID";
            ddlFilterLanguage.DataTextField = "LangName";
            ddlFilterLanguage.DataBind();
            ddlFilterLanguage.Items.Insert(0, new ListItem("-- All Languages --", ""));

            // Bind Halls
            DataTable dtHalls = DBHelper.ExecuteReaderText("SELECT HallID, HallName FROM Halls WHERE IsActive = 1 ORDER BY HallName");
            ddlFilterHall.DataSource = dtHalls;
            ddlFilterHall.DataValueField = "HallID";
            ddlFilterHall.DataTextField = "HallName";
            ddlFilterHall.DataBind();
            ddlFilterHall.Items.Insert(0, new ListItem("-- All Halls --", ""));
            
            // Insert empty default for racks
            ddlFilterRack.Items.Clear();
            ddlFilterRack.Items.Insert(0, new ListItem("-- All Racks --", ""));
        }
        catch (Exception ex)
        {
            ShowAlert("Error loading filter options: " + ex.Message, false);
        }
    }

    private void BindTransferHalls()
    {
        try
        {
            DataTable dtHalls = DBHelper.ExecuteReaderText("SELECT HallID, HallName FROM Halls WHERE IsActive = 1 ORDER BY HallName");
            ddlTransferHall.DataSource = dtHalls;
            ddlTransferHall.DataValueField = "HallID";
            ddlTransferHall.DataTextField = "HallName";
            ddlTransferHall.DataBind();
            ddlTransferHall.Items.Insert(0, new ListItem("-- Select Hall --", ""));
            
            ddlTransferUnit.Items.Clear();
            ddlTransferUnit.Items.Insert(0, new ListItem("-- Select Unit --", ""));
            
            ddlTransferRack.Items.Clear();
            ddlTransferRack.Items.Insert(0, new ListItem("-- Select Rack --", ""));
        }
        catch (Exception ex)
        {
            ShowAlert("Error loading relocation halls: " + ex.Message, false);
        }
    }

    protected void ddlFilterHall_SelectedIndexChanged(object sender, EventArgs e)
    {
        try
        {
            ddlFilterRack.Items.Clear();
            ddlFilterRack.Items.Insert(0, new ListItem("-- All Racks --", ""));

            if (!string.IsNullOrEmpty(ddlFilterHall.SelectedValue))
            {
                int hallID = Convert.ToInt32(ddlFilterHall.SelectedValue);
                string qry = @"
                    SELECT r.RackID, h.HallCode + '-' + su.UnitCode + '-R' + CAST(r.RackNo AS VARCHAR) AS RackName
                    FROM Racks r
                    JOIN ShelfUnits su ON r.UnitID = su.UnitID
                    JOIN Halls h ON su.HallID = h.HallID
                    WHERE h.HallID = @HallID
                    ORDER BY su.UnitCode, r.RackNo";
                
                DataTable dtRacks = DBHelper.ExecuteReaderText(qry, new SqlParameter("@HallID", hallID));
                ddlFilterRack.DataSource = dtRacks;
                ddlFilterRack.DataValueField = "RackID";
                ddlFilterRack.DataTextField = "RackName";
                ddlFilterRack.DataBind();
                ddlFilterRack.Items.Insert(0, new ListItem("-- All Racks --", ""));
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Error loading racks: " + ex.Message, false);
        }
    }

    protected void ddlTransferHall_SelectedIndexChanged(object sender, EventArgs e)
    {
        try
        {
            ddlTransferUnit.Items.Clear();
            ddlTransferUnit.Items.Insert(0, new ListItem("-- Select Unit --", ""));
            ddlTransferRack.Items.Clear();
            ddlTransferRack.Items.Insert(0, new ListItem("-- Select Rack --", ""));

            if (!string.IsNullOrEmpty(ddlTransferHall.SelectedValue))
            {
                int hallID = Convert.ToInt32(ddlTransferHall.SelectedValue);
                DataTable dtUnits = DBHelper.ExecuteReaderText(
                    "SELECT UnitID, UnitCode + ' (' + ISNULL(UnitName, '') + ')' AS UnitName FROM ShelfUnits WHERE HallID = @HallID ORDER BY UnitCode",
                    new SqlParameter("@HallID", hallID)
                );
                
                ddlTransferUnit.DataSource = dtUnits;
                ddlTransferUnit.DataValueField = "UnitID";
                ddlTransferUnit.DataTextField = "UnitName";
                ddlTransferUnit.DataBind();
                ddlTransferUnit.Items.Insert(0, new ListItem("-- Select Unit --", ""));
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Error loading units: " + ex.Message, false);
        }
    }

    protected void ddlTransferUnit_SelectedIndexChanged(object sender, EventArgs e)
    {
        try
        {
            ddlTransferRack.Items.Clear();
            ddlTransferRack.Items.Insert(0, new ListItem("-- Select Rack --", ""));

            if (!string.IsNullOrEmpty(ddlTransferUnit.SelectedValue))
            {
                int unitID = Convert.ToInt32(ddlTransferUnit.SelectedValue);
                DataTable dtRacks = DBHelper.ExecuteReaderText(
                    "SELECT RackID, 'Rack ' + CAST(RackNo AS VARCHAR) + ' (' + ISNULL(SubjectTag, 'No Tag') + ')' AS RackName FROM Racks WHERE UnitID = @UnitID ORDER BY RackNo",
                    new SqlParameter("@UnitID", unitID)
                );
                
                ddlTransferRack.DataSource = dtRacks;
                ddlTransferRack.DataValueField = "RackID";
                ddlTransferRack.DataTextField = "RackName";
                ddlTransferRack.DataBind();
                ddlTransferRack.Items.Insert(0, new ListItem("-- Select Rack --", ""));
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Error loading racks: " + ex.Message, false);
        }
    }

    // =========================================================================
    //  DASHBOARD STATISTICS BINDING
    // =========================================================================
    private void RefreshDashboardStats()
    {
        try
        {
            DataTable dtStats = DBHelper.ExecuteReader("sp_GetStockTrackingDashboard");
            if (dtStats.Rows.Count > 0)
            {
                DataRow r = dtStats.Rows[0];
                litStatTitles.Text = r["TotalTitles"].ToString();
                litStatCopies.Text = r["TotalCopies"].ToString();
                litStatAvailable.Text = r["AvailableCount"].ToString();
                litStatIssued.Text = r["IssuedCount"].ToString();
                litStatReserved.Text = r["ReservedCount"].ToString();
                litStatOverdue.Text = r["OverdueCount"].ToString();
                litStatLost.Text = r["LostCount"].ToString();
                litStatDamaged.Text = r["DamagedCount"].ToString();
                litStatMissing.Text = r["MissingCount"].ToString();
                litStatWithdrawn.Text = r["WithdrawnCount"].ToString();
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Error loading dashboard metrics: " + ex.Message, false);
        }
    }

    // =========================================================================
    //  STOCK DIRECTORY BINDING (TAB 0)
    // =========================================================================
    private DataTable _dtCurrentCopies = null;

    private void BindStockGrid()
    {
        try
        {
            List<SqlParameter> prms = new List<SqlParameter>();

            prms.Add(new SqlParameter("@Title", string.IsNullOrEmpty(txtFilterTitle.Text.Trim()) ? (object)DBNull.Value : txtFilterTitle.Text.Trim()));
            prms.Add(new SqlParameter("@AcqNo", string.IsNullOrEmpty(txtFilterAcqNo.Text.Trim()) ? (object)DBNull.Value : txtFilterAcqNo.Text.Trim()));
            prms.Add(new SqlParameter("@BookNo", string.IsNullOrEmpty(txtFilterBookNo.Text.Trim()) ? (object)DBNull.Value : txtFilterBookNo.Text.Trim()));
            prms.Add(new SqlParameter("@Barcode", string.IsNullOrEmpty(txtFilterBarcode.Text.Trim()) ? (object)DBNull.Value : txtFilterBarcode.Text.Trim()));
            prms.Add(new SqlParameter("@ISBN", string.IsNullOrEmpty(txtFilterISBN.Text.Trim()) ? (object)DBNull.Value : txtFilterISBN.Text.Trim()));
            prms.Add(new SqlParameter("@Author", string.IsNullOrEmpty(txtFilterAuthor.Text.Trim()) ? (object)DBNull.Value : txtFilterAuthor.Text.Trim()));
            
            prms.Add(new SqlParameter("@CatID", string.IsNullOrEmpty(ddlFilterCategory.SelectedValue) ? (object)DBNull.Value : Convert.ToInt16(ddlFilterCategory.SelectedValue)));
            prms.Add(new SqlParameter("@Subject", string.IsNullOrEmpty(txtFilterSubject.Text.Trim()) ? (object)DBNull.Value : txtFilterSubject.Text.Trim()));
            prms.Add(new SqlParameter("@LangID", string.IsNullOrEmpty(ddlFilterLanguage.SelectedValue) ? (object)DBNull.Value : Convert.ToByte(ddlFilterLanguage.SelectedValue)));
            prms.Add(new SqlParameter("@Publisher", string.IsNullOrEmpty(txtFilterPublisher.Text.Trim()) ? (object)DBNull.Value : txtFilterPublisher.Text.Trim()));
            prms.Add(new SqlParameter("@DDC", string.IsNullOrEmpty(txtFilterDDC.Text.Trim()) ? (object)DBNull.Value : txtFilterDDC.Text.Trim()));
            
            prms.Add(new SqlParameter("@HallID", string.IsNullOrEmpty(ddlFilterHall.SelectedValue) ? (object)DBNull.Value : Convert.ToInt16(ddlFilterHall.SelectedValue)));
            prms.Add(new SqlParameter("@FloorNo", string.IsNullOrEmpty(ddlFilterFloor.SelectedValue) ? (object)DBNull.Value : Convert.ToByte(ddlFilterFloor.SelectedValue)));
            prms.Add(new SqlParameter("@UnitCode", string.IsNullOrEmpty(txtFilterSection.Text.Trim()) ? (object)DBNull.Value : txtFilterSection.Text.Trim()));
            prms.Add(new SqlParameter("@RackID", string.IsNullOrEmpty(ddlFilterRack.SelectedValue) ? (object)DBNull.Value : Convert.ToInt16(ddlFilterRack.SelectedValue)));
            prms.Add(new SqlParameter("@SlotNo", string.IsNullOrEmpty(txtFilterSlot.Text.Trim()) ? (object)DBNull.Value : Convert.ToByte(txtFilterSlot.Text.Trim())));
            
            prms.Add(new SqlParameter("@Status", string.IsNullOrEmpty(ddlFilterStatus.SelectedValue) ? (object)DBNull.Value : ddlFilterStatus.SelectedValue));
            prms.Add(new SqlParameter("@AcqDateFrom", string.IsNullOrEmpty(txtFilterDateFrom.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtFilterDateFrom.Text)));
            prms.Add(new SqlParameter("@AcqDateTo", string.IsNullOrEmpty(txtFilterDateTo.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtFilterDateTo.Text)));
            
            prms.Add(new SqlParameter("@PageNumber", 1));
            prms.Add(new SqlParameter("@PageSize", 0));
            prms.Add(new SqlParameter("@SortColumn", ViewState["SortColumn"].ToString()));
            prms.Add(new SqlParameter("@SortDirection", ViewState["SortDirection"].ToString()));

            DataTable dt = DBHelper.ExecuteReader("sp_GetStockTrackingData", prms.ToArray());
            _dtCurrentCopies = dt;

            DataTable dtBooks = new DataTable();
            dtBooks.Columns.Add("BookID", typeof(int));
            dtBooks.Columns.Add("Title", typeof(string));
            dtBooks.Columns.Add("Authors", typeof(string));
            dtBooks.Columns.Add("ISBN13", typeof(string));
            dtBooks.Columns.Add("DDC", typeof(string));
            dtBooks.Columns.Add("CatName", typeof(string));
            dtBooks.Columns.Add("CoverFile", typeof(string));
            dtBooks.Columns.Add("TotalCopies", typeof(int));
            dtBooks.Columns.Add("AvailableCopies", typeof(int));
            dtBooks.Columns.Add("TotalRows", typeof(int));

            if (dt != null && dt.Rows.Count > 0)
            {
                var bookGroups = dt.AsEnumerable().GroupBy(r => r.Field<int>("BookID"));
                foreach (var group in bookGroups)
                {
                    DataRow firstRow = group.First();
                    DataRow newBookRow = dtBooks.NewRow();
                    newBookRow["BookID"] = firstRow["BookID"];
                    newBookRow["Title"] = firstRow["Title"];
                    newBookRow["Authors"] = firstRow["Authors"];
                    newBookRow["ISBN13"] = firstRow["ISBN13"];
                    newBookRow["DDC"] = firstRow["DDC"];
                    newBookRow["CatName"] = firstRow["CatName"];
                    newBookRow["CoverFile"] = firstRow["CoverFile"];
                    newBookRow["TotalCopies"] = group.Count();
                    newBookRow["AvailableCopies"] = group.Count(r => r["ComputedStatus"].ToString() == "Available");
                    newBookRow["TotalRows"] = dt.Rows[0]["TotalRows"];
                    dtBooks.Rows.Add(newBookRow);
                }

                litGridRecordCount.Text = dt.Rows[0]["TotalRows"].ToString();
            }
            else
            {
                litGridRecordCount.Text = "0";
            }

            gvStock.DataSource = dtBooks;
            gvStock.DataBind();
        }
        catch (Exception ex)
        {
            ShowAlert("Error retrieving stock directory listing: " + ex.Message, false);
        }
    }

    protected void btnApplyFilters_Click(object sender, EventArgs e)
    {
        gvStock.PageIndex = 0;
        BindStockGrid();
    }

    protected void btnClearFilters_Click(object sender, EventArgs e)
    {
        txtFilterTitle.Text = "";
        txtFilterAcqNo.Text = "";
        txtFilterBookNo.Text = "";
        txtFilterBarcode.Text = "";
        txtFilterISBN.Text = "";
        txtFilterAuthor.Text = "";
        ddlFilterCategory.SelectedIndex = 0;
        txtFilterSubject.Text = "";
        ddlFilterLanguage.SelectedIndex = 0;
        txtFilterPublisher.Text = "";
        txtFilterDDC.Text = "";
        ddlFilterHall.SelectedIndex = 0;
        ddlFilterFloor.SelectedIndex = 0;
        txtFilterSection.Text = "";
        ddlFilterRack.Items.Clear();
        ddlFilterRack.Items.Insert(0, new ListItem("-- All Racks --", ""));
        txtFilterSlot.Text = "";
        ddlFilterStatus.SelectedIndex = 0;
        txtFilterDateFrom.Text = "";
        txtFilterDateTo.Text = "";

        gvStock.PageIndex = 0;
        BindStockGrid();
    }

    protected void gvStock_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvStock.PageIndex = e.NewPageIndex;
        BindStockGrid();
    }

    protected void gvStock_Sorting(object sender, GridViewSortEventArgs e)
    {
        string currentSortColumn = ViewState["SortColumn"].ToString();
        string currentSortDirection = ViewState["SortDirection"].ToString();

        if (e.SortExpression == currentSortColumn)
        {
            ViewState["SortDirection"] = (currentSortDirection == "ASC") ? "DESC" : "ASC";
        }
        else
        {
            ViewState["SortColumn"] = e.SortExpression;
            ViewState["SortDirection"] = "ASC";
        }

        gvStock.PageIndex = 0;
        BindStockGrid();
    }

    protected void gvStock_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (gvStock.DataKeys[e.Row.RowIndex] != null && gvStock.DataKeys[e.Row.RowIndex].Value != null)
            {
                int bookID = Convert.ToInt32(gvStock.DataKeys[e.Row.RowIndex].Value);
                Repeater rptChildCopies = (Repeater)e.Row.FindControl("rptChildCopies");
                if (rptChildCopies != null && _dtCurrentCopies != null)
                {
                    DataView dv = new DataView(_dtCurrentCopies);
                    dv.RowFilter = "BookID = " + bookID;
                    rptChildCopies.DataSource = dv;
                    rptChildCopies.DataBind();
                }
            }
        }
    }

    protected void btnCopyAction_Command(object sender, CommandEventArgs e)
    {
        int copyID = Convert.ToInt32(e.CommandArgument);
        if (e.CommandName == "ViewDetails")
        {
            LoadCopyDetails(copyID);
        }
        else if (e.CommandName == "TransferLocation")
        {
            LoadTransferDetails(copyID);
        }
        else if (e.CommandName == "ChangeStatus")
        {
            LoadStatusDetails(copyID);
        }
        else if (e.CommandName == "PrintBarcode")
        {
            LoadBarcodeDetails(copyID);
        }
    }

    // =========================================================================
    //  UI FORMATTING HELPERS
    // =========================================================================
    protected string GetStatusBadge(object statusObj)
    {
        if (statusObj == null || statusObj == DBNull.Value) return "";
        string status = statusObj.ToString().Trim();
        string styleClass = "badge-status";
        
        switch (status)
        {
            case "Available": styleClass += " badge-available"; break;
            case "Issued": styleClass += " badge-issued"; break;
            case "Reserved": styleClass += " badge-reserved"; break;
            case "Overdue": styleClass += " badge-overdue"; break;
            case "Lost": styleClass += " badge-lost"; break;
            case "Damaged": styleClass += " badge-damaged"; break;
            case "Missing": styleClass += " badge-missing"; break;
            case "Repair": styleClass += " badge-repair"; break;
            case "Withdrawn": styleClass += " badge-withdrawn"; break;
            default: styleClass += " badge-withdrawn"; break;
        }

        return string.Format("<span class='{0}'>{1}</span>", styleClass, status);
    }

    protected string GetBookCover(object coverFileObj)
    {
        string filename = (coverFileObj != null && coverFileObj != DBNull.Value) ? coverFileObj.ToString() : "";
        if (string.IsNullOrEmpty(filename))
        {
            return "<i class='fas fa-book' style='font-size: 20px; color: #cbd5e1;'></i>";
        }
        // Base image path
        return string.Format("<img src='{0}' alt='Book Cover' style='width:100%; height:100%; object-fit: cover;' />", ResolveUrl("~/Library Management/Images/" + filename));
    }

    // =========================================================================
    //  GRID ROW COMMAND DISPATCHER
    // =========================================================================
    protected void gvStock_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "ViewDetails")
        {
            int copyID = Convert.ToInt32(e.CommandArgument);
            LoadCopyDetails(copyID);
        }
        else if (e.CommandName == "TransferLocation")
        {
            int copyID = Convert.ToInt32(e.CommandArgument);
            LoadTransferDetails(copyID);
        }
        else if (e.CommandName == "ChangeStatus")
        {
            int copyID = Convert.ToInt32(e.CommandArgument);
            LoadStatusDetails(copyID);
        }
        else if (e.CommandName == "PrintBarcode")
        {
            int copyID = Convert.ToInt32(e.CommandArgument);
            LoadBarcodeDetails(copyID);
        }
    }

    // =========================================================================
    //  MODAL: STOCK COPY DETAILS
    // =========================================================================
    private void LoadCopyDetails(int copyID)
    {
        pnlAlert.Visible = false;
        try
        {
            DataSet ds = DBHelper.ExecuteDataSet("sp_GetStockDetails", new SqlParameter("@CopyID", copyID));
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                DataRow r = ds.Tables[0].Rows[0];
                ViewState["SelectedCopyID"] = copyID;

                // Bind Bibliographic data
                lblModalTitle.Text = (r["Title"] != DBNull.Value ? r["Title"].ToString() : "") + 
                                     ((r["SubTitle"] != DBNull.Value && !string.IsNullOrEmpty(r["SubTitle"].ToString())) ? " - " + r["SubTitle"].ToString() : "");
                lblModalAuthor.Text = r["Authors"] != DBNull.Value ? r["Authors"].ToString() : "Unknown Author";
                lblModalBarcode.Text = r["Barcode"] != DBNull.Value ? r["Barcode"].ToString() : "";
                lblPrintLabelBarcode.Text = r["Barcode"] != DBNull.Value ? r["Barcode"].ToString() : "";
                lblModalISBN.Text = r["ISBN13Fmt"] != DBNull.Value ? r["ISBN13Fmt"].ToString() : (r["ISBN13"] != DBNull.Value ? r["ISBN13"].ToString() : "N/A");
                lblModalCategory.Text = r["CatName"] != DBNull.Value ? r["CatName"].ToString() : "N/A";
                lblModalPublisher.Text = (r["PubName"] != DBNull.Value ? r["PubName"].ToString() : "N/A") + 
                                         (r["PublishYear"] != DBNull.Value ? " (" + r["PublishYear"].ToString() + ")" : "");
                lblModalAcqDate.Text = (r["AcqDate"] != DBNull.Value) ? Convert.ToDateTime(r["AcqDate"]).ToString("dd-MMM-yyyy") : "N/A";
                lblModalAcqCost.Text = (r["AcqCost"] != DBNull.Value) ? Convert.ToDecimal(r["AcqCost"]).ToString("N2") : "0.00";
                lblModalDDC.Text = r["DDC"] != DBNull.Value ? r["DDC"].ToString() : "N/A";
                lblModalAcqNo.Text = r["AcqNo"] != DBNull.Value ? r["AcqNo"].ToString() : "N/A";
                lblModalIsReference.Text = (r["IsReference"] != DBNull.Value && Convert.ToBoolean(r["IsReference"])) ? "Reference (Non-Circulating)" : "Circulating / Normal";
                lblModalCondition.Text = r["CondName"] != DBNull.Value ? r["CondName"].ToString() : "N/A";
                lblModalNotes.Text = (r["Notes"] == DBNull.Value || string.IsNullOrEmpty(r["Notes"].ToString())) ? "No Notes" : r["Notes"].ToString();

                // Cover Image
                string coverFile = r["CoverFile"].ToString();
                if (!string.IsNullOrEmpty(coverFile))
                    litModalCover.Text = string.Format("<img src='{0}' style='width: 100%; height: 100%; object-fit: cover;' />", ResolveUrl("~/Library Management/Images/" + coverFile));
                else
                    litModalCover.Text = "<i class='fas fa-book' style='font-size: 32px; color: #cbd5e1;'></i>";

                // Shelf location details
                if (r["HallName"] != DBNull.Value)
                {
                    lblModalLocationHall.Text = r["HallName"].ToString();
                    lblModalLocationDetails.Text = string.Format("Unit: {0} | Rack Row: {1} | Slot: {2}", r["UnitCode"], r["RackNo"], r["SlotNo"]);
                }
                else
                {
                    lblModalLocationHall.Text = "Unassigned";
                    lblModalLocationDetails.Text = "No designated shelf location assigned.";
                }

                // Status Badge
                litModalStatusBadge.Text = GetStatusBadge(r["ComputedStatus"]);

                // Active Loan details (RS1)
                pnlModalActiveLoan.Visible = false;
                if (ds.Tables.Count > 1 && ds.Tables[1].Rows.Count > 0)
                {
                    DataRow loanRow = ds.Tables[1].Rows[0];
                    pnlModalActiveLoan.Visible = true;
                    lblModalLoanMember.Text = loanRow["MemberName"].ToString();
                    lblModalLoanMemberNo.Text = loanRow["MembershipNo"].ToString();
                    lblModalLoanIssueDate.Text = Convert.ToDateTime(loanRow["IssueDate"]).ToString("dd-MMM-yyyy hh:mm tt");
                    lblModalLoanDueDate.Text = Convert.ToDateTime(loanRow["DueDate"]).ToString("dd-MMM-yyyy");
                    lblModalLoanRenewals.Text = loanRow["RenewalCount"].ToString();
                    lblModalLoanStatus.Text = loanRow["StatusName"].ToString();
                }

                // Bind Loan History (RS2)
                gvModalLoanHistory.DataSource = ds.Tables[2];
                gvModalLoanHistory.DataBind();

                // Bind Location Transfer history (RS3)
                gvModalLocationHistory.DataSource = ds.Tables[3];
                gvModalLocationHistory.DataBind();

                // Bind Weeding/Condition changes (RS4)
                gvModalWeedingHistory.DataSource = ds.Tables[4];
                gvModalWeedingHistory.DataBind();

                pnlDetailModal.Visible = true;
            }
            else
            {
                ShowAlert("Copy not found in data directories.", false);
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Error loading copy details: " + ex.Message, false);
        }
    }

    protected void btnCloseDetailModal_Click(object sender, EventArgs e)
    {
        pnlDetailModal.Visible = false;
    }

    // =========================================================================
    //  MODAL: PHYSICAL SHELF TRANSFER
    // =========================================================================
    private void LoadTransferDetails(int copyID)
    {
        pnlAlert.Visible = false;
        try
        {
            DataTable dt = DBHelper.ExecuteReaderText(
                "SELECT cp.CopyID, cp.Barcode, b.Title, cp.RackID, cp.SlotNo FROM BookCopies cp JOIN Books b ON cp.BookID = b.BookID WHERE cp.CopyID = @CopyID",
                new SqlParameter("@CopyID", copyID)
            );

            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                ViewState["SelectedCopyID"] = copyID;
                lblTransferBarcode.Text = r["Barcode"].ToString();
                lblTransferTitle.Text = r["Title"].ToString();
                
                txtTransferSlot.Text = r["SlotNo"] != DBNull.Value ? r["SlotNo"].ToString() : "";
                txtTransferRemarks.Text = "";

                // Reset transfer dropdowns
                BindTransferHalls();
                pnlTransferModal.Visible = true;
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Error loading transfer options: " + ex.Message, false);
        }
    }

    protected void btnSubmitTransfer_Click(object sender, EventArgs e)
    {
        if (ViewState["SelectedCopyID"] == null) return;
        int copyID = Convert.ToInt32(ViewState["SelectedCopyID"]);

        if (string.IsNullOrEmpty(ddlTransferRack.SelectedValue))
        {
            ShowAlert("Please select a valid destination Rack Row.", false);
            return;
        }

        short rackID = Convert.ToInt16(ddlTransferRack.SelectedValue);
        byte slotNo = 0;
        if (!byte.TryParse(txtTransferSlot.Text.Trim(), out slotNo) || slotNo < 1 || slotNo > 100)
        {
            ShowAlert("Please enter a valid shelf Slot number (1 - 100).", false);
            return;
        }

        short staffID = Convert.ToInt16(Session["Emp_ID"]);
        string remarks = string.IsNullOrEmpty(txtTransferRemarks.Text.Trim()) ? "Relocation of copy" : txtTransferRemarks.Text.Trim();

        try
        {
            List<SqlParameter> prms = new List<SqlParameter>();
            prms.Add(new SqlParameter("@CopyID", copyID));
            prms.Add(new SqlParameter("@NewRackID", rackID));
            prms.Add(new SqlParameter("@NewSlotNo", slotNo));
            prms.Add(new SqlParameter("@StaffID", staffID));
            prms.Add(new SqlParameter("@Remarks", remarks));

            DBHelper.ExecuteNonQuery("sp_UpdateStockLocation", prms.ToArray());
            
            pnlTransferModal.Visible = false;
            BindStockGrid();
            RefreshDashboardStats();
            ShowAlert("Shelf relocation completed successfully.", true);
        }
        catch (Exception ex)
        {
            ShowAlert("Relocation failed: " + ex.Message, false);
        }
    }

    protected void btnCloseTransferModal_Click(object sender, EventArgs e)
    {
        pnlTransferModal.Visible = false;
    }

    // =========================================================================
    //  MODAL: STATUS / CONDITION LOG
    // =========================================================================
    private void LoadStatusDetails(int copyID)
    {
        pnlAlert.Visible = false;
        try
        {
            DataTable dt = DBHelper.ExecuteReaderText(
                "SELECT cp.CopyID, cp.Barcode, b.Title, cp.CondID, cp.IsAvailable FROM BookCopies cp JOIN Books b ON cp.BookID = b.BookID WHERE cp.CopyID = @CopyID",
                new SqlParameter("@CopyID", copyID)
            );

            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                ViewState["SelectedCopyID"] = copyID;
                lblStatusBarcode.Text = r["Barcode"] != DBNull.Value ? r["Barcode"].ToString() : "";
                lblStatusTitle.Text = r["Title"] != DBNull.Value ? r["Title"].ToString() : "";
                ddlStatusCondition.SelectedValue = r["CondID"] != DBNull.Value ? r["CondID"].ToString() : "";
                chkStatusAvailable.Checked = r["IsAvailable"] != DBNull.Value && Convert.ToBoolean(r["IsAvailable"]);
                txtStatusRemarks.Text = "";

                pnlStatusModal.Visible = true;
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Error loading copy conditions: " + ex.Message, false);
        }
    }

    protected void btnSubmitStatus_Click(object sender, EventArgs e)
    {
        if (ViewState["SelectedCopyID"] == null) return;
        int copyID = Convert.ToInt32(ViewState["SelectedCopyID"]);

        byte condID = Convert.ToByte(ddlStatusCondition.SelectedValue);
        bool isAvailable = chkStatusAvailable.Checked;
        short staffID = Convert.ToInt16(Session["Emp_ID"]);
        string remarks = string.IsNullOrEmpty(txtStatusRemarks.Text.Trim()) ? "Status update" : txtStatusRemarks.Text.Trim();

        try
        {
            List<SqlParameter> prms = new List<SqlParameter>();
            prms.Add(new SqlParameter("@CopyID", copyID));
            prms.Add(new SqlParameter("@CondID", condID));
            prms.Add(new SqlParameter("@IsAvailable", isAvailable));
            prms.Add(new SqlParameter("@StaffID", staffID));
            prms.Add(new SqlParameter("@Remarks", remarks));

            DBHelper.ExecuteNonQuery("sp_UpdateStockStatus", prms.ToArray());
            
            pnlStatusModal.Visible = false;
            BindStockGrid();
            RefreshDashboardStats();
            ShowAlert("Stock condition and availability updated successfully.", true);
        }
        catch (Exception ex)
        {
            ShowAlert("Update failed: " + ex.Message, false);
        }
    }

    protected void btnCloseStatusModal_Click(object sender, EventArgs e)
    {
        pnlStatusModal.Visible = false;
    }

    // =========================================================================
    //  MODAL: BARCODE PRINT PREVIEW
    // =========================================================================
    private void LoadBarcodeDetails(int copyID)
    {
        pnlAlert.Visible = false;
        try
        {
            DataTable dt = DBHelper.ExecuteReaderText(@"
                SELECT cp.Barcode, b.Title, b.AcqNo, 
                       ISNULL(h.HallCode + '-' + su.UnitCode + '-R' + CAST(r.RackNo AS VARCHAR) + '-S' + CAST(cp.SlotNo AS VARCHAR), 'Unassigned') AS Location
                FROM BookCopies cp
                JOIN Books b ON cp.BookID = b.BookID
                LEFT JOIN Racks r ON cp.RackID = r.RackID
                LEFT JOIN ShelfUnits su ON r.UnitID = su.UnitID
                LEFT JOIN Halls h ON su.HallID = h.HallID
                WHERE cp.CopyID = @CopyID",
                new SqlParameter("@CopyID", copyID)
            );

            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                lblPrintLabelTitle.Text = r["Title"].ToString();
                lblPrintLabelBarcode.Text = r["Barcode"].ToString();
                lblPrintLabelLocation.Text = r["Location"].ToString();
                lblPrintLabelAcqNo.Text = string.IsNullOrEmpty(r["AcqNo"].ToString()) ? "N/A" : r["AcqNo"].ToString();
                
                pnlBarcodeModal.Visible = true;
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Error loading barcode details: " + ex.Message, false);
        }
    }

    protected void btnCloseBarcodeModal_Click(object sender, EventArgs e)
    {
        pnlBarcodeModal.Visible = false;
    }

    // =========================================================================
    //  TAB 1: INVENTORY AUDIT (STOCK VERIFICATION)
    // =========================================================================
    private void CheckActiveAuditSession()
    {
        try
        {
            DataTable dt = DBHelper.ExecuteReaderText(
                "SELECT SessionID, SessionName, CreatedAt, Status FROM StockVerificationSessions WHERE Status = 'Active'"
            );
            if (dt.Rows.Count > 0)
            {
                // Active session exists
                DataRow r = dt.Rows[0];
                int sessionID = Convert.ToInt32(r["SessionID"]);
                hfActiveSessionID.Value = sessionID.ToString();
                litActiveSessionName.Text = r["SessionName"].ToString();
                litActiveSessionDate.Text = Convert.ToDateTime(r["CreatedAt"]).ToString("dd-MMM-yyyy hh:mm tt");
                
                pnlStartAuditSession.Visible = false;
                pnlActiveAuditWorkflow.Visible = true;
                pnlReconcileNoActiveSession.Visible = false;
                pnlReconcileActiveSession.Visible = true;
                
                BindVerificationProgress(sessionID);
            }
            else
            {
                // No active session
                hfActiveSessionID.Value = "";
                pnlStartAuditSession.Visible = true;
                pnlActiveAuditWorkflow.Visible = false;
                pnlReconcileNoActiveSession.Visible = true;
                pnlReconcileActiveSession.Visible = false;
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Error checking inventory audit sessions: " + ex.Message, false);
        }
    }

    protected void btnStartAudit_Click(object sender, EventArgs e)
    {
        pnlAlert.Visible = false;
        string name = txtAuditSessionName.Text.Trim();
        if (string.IsNullOrEmpty(name))
        {
            ShowAlert("Please enter a descriptive audit session name.", false);
            return;
        }

        short staffID = Convert.ToInt16(Session["Emp_ID"]);
        string remarks = txtAuditRemarks.Text.Trim();

        try
        {
            List<SqlParameter> prms = new List<SqlParameter>();
            prms.Add(new SqlParameter("@SessionName", name));
            prms.Add(new SqlParameter("@CreatedByStaff", staffID));
            prms.Add(new SqlParameter("@Remarks", string.IsNullOrEmpty(remarks) ? (object)DBNull.Value : remarks));

            DataTable dt = DBHelper.ExecuteReader("sp_StartVerificationSession", prms.ToArray());
            if (dt.Rows.Count > 0)
            {
                txtAuditSessionName.Text = "";
                txtAuditRemarks.Text = "";
                CheckActiveAuditSession();
                ShowAlert("Inventory audit session launched successfully. You can begin scanning barcodes.", true);
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Error starting audit: " + ex.Message, false);
        }
    }

    private void BindVerificationProgress(int sessionID)
    {
        try
        {
            DataSet ds = DBHelper.ExecuteDataSet("sp_GetVerificationSessionProgress", new SqlParameter("@SessionID", sessionID));
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                DataRow statRow = ds.Tables[0].Rows[0];
                int expected = Convert.ToInt32(statRow["TotalExpected"]);
                int verified = Convert.ToInt32(statRow["TotalVerified"]);
                int matches = Convert.ToInt32(statRow["VerifiedMatches"]);
                int misplaced = Convert.ToInt32(statRow["MisplacedCount"]);
                int missing = Convert.ToInt32(statRow["MissingCount"]);

                litAuditCountExpected.Text = expected.ToString();
                litAuditCountMatches.Text = matches.ToString();
                litAuditCountMisplaced.Text = misplaced.ToString();
                litAuditCountMissing.Text = missing.ToString();

                // Compute progress percentage based on verified copies vs expected
                double pct = expected > 0 ? ((double)matches / expected) * 100.0 : 0.0;
                if (pct > 100.0) pct = 100.0;

                litAuditProgressPct.Text = pct.ToString("F1") + "%";
                litAuditProgressRatio.Text = string.Format("{0} of {1} shelf copies verified", matches, expected);
                divAuditProgressBar.Style["width"] = pct.ToString("F1") + "%";

                // Bind scan log (verified list)
                gvAuditVerified.DataSource = ds.Tables[1];
                gvAuditVerified.DataBind();

                // Bind reconcile list (expected but not verified)
                if (ds.Tables.Count > 2)
                {
                    gvReconcileMissing.DataSource = ds.Tables[2];
                    gvReconcileMissing.DataBind();
                    litReconcileSummaryText.Text = string.Format("{0} expected copies remaining to reconcile.", ds.Tables[2].Rows.Count);
                }
                else
                {
                    gvReconcileMissing.DataSource = null;
                    gvReconcileMissing.DataBind();
                    litReconcileSummaryText.Text = "0 expected copies remaining to reconcile.";
                }

            }
        }
        catch (Exception ex)
        {
            ShowAlert("Error calculating audit progress: " + ex.Message, false);
        }
    }

    protected void gvAuditVerified_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvAuditVerified.PageIndex = e.NewPageIndex;
        int sessionID;
        if (int.TryParse(hfActiveSessionID.Value, out sessionID))
        {
            BindVerificationProgress(sessionID);
        }
    }

    protected void txtScanBarcode_TextChanged(object sender, EventArgs e)
    {
        ProcessScannedBarcode();
    }

    protected void btnVerifyManual_Click(object sender, EventArgs e)
    {
        ProcessScannedBarcode();
    }

    private void ProcessScannedBarcode()
    {
        lblScanFeedback.Text = "";
        int sessionID;
        if (!int.TryParse(hfActiveSessionID.Value, out sessionID)) return;
        string barcode = txtScanBarcode.Text.Trim().ToUpper();

        if (string.IsNullOrEmpty(barcode)) return;

        txtScanBarcode.Text = ""; // Clear input immediately for next scan
        txtScanBarcode.Focus();

        try
        {
            short staffID = Convert.ToInt16(Session["Emp_ID"]);
            List<SqlParameter> prms = new List<SqlParameter>();
            prms.Add(new SqlParameter("@SessionID", sessionID));
            prms.Add(new SqlParameter("@Barcode", barcode));
            prms.Add(new SqlParameter("@VerifiedByStaff", staffID));

            DataTable dt = DBHelper.ExecuteReader("sp_VerifyBarcode", prms.ToArray());
            if (dt.Rows.Count > 0)
            {
                int code = Convert.ToInt32(dt.Rows[0]["ResultCode"]);
                string msg = dt.Rows[0]["Msg"].ToString();
                
                if (code == 1)
                {
                    lblScanFeedback.ForeColor = System.Drawing.Color.Green;
                    lblScanFeedback.Text = string.Format("<i class='fas fa-check-circle'></i> Verified barcode: {0} ({1})", barcode, msg);
                }
                else
                {
                    lblScanFeedback.ForeColor = System.Drawing.Color.Orange;
                    lblScanFeedback.Text = string.Format("<i class='fas fa-exclamation-triangle'></i> Barcode {0}: {1}", barcode, msg);
                }
            }
            
            BindVerificationProgress(sessionID);
        }
        catch (Exception ex)
        {
            lblScanFeedback.ForeColor = System.Drawing.Color.Red;
            lblScanFeedback.Text = string.Format("<i class='fas fa-times-circle'></i> Verification failed for: {0} ({1})", barcode, ex.Message);
        }
    }

    protected void btnCompleteAudit_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(hfActiveSessionID.Value)) return;
        int sessionID = Convert.ToInt32(hfActiveSessionID.Value);

        try
        {
            List<SqlParameter> prms = new List<SqlParameter>();
            prms.Add(new SqlParameter("@SessionID", sessionID));
            prms.Add(new SqlParameter("@Status", "Completed"));
            prms.Add(new SqlParameter("@Remarks", "Audit session finalized."));

            DBHelper.ExecuteNonQuery("sp_CloseVerificationSession", prms.ToArray());
            
            CheckActiveAuditSession();
            RefreshDashboardStats();
            BindStockGrid();
            ShowAlert("Inventory stock audit finalized successfully. Database stats reconciled.", true);
        }
        catch (Exception ex)
        {
            ShowAlert("Error closing audit session: " + ex.Message, false);
        }
    }

    protected void btnCancelAudit_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(hfActiveSessionID.Value)) return;
        int sessionID = Convert.ToInt32(hfActiveSessionID.Value);

        try
        {
            List<SqlParameter> prms = new List<SqlParameter>();
            prms.Add(new SqlParameter("@SessionID", sessionID));
            prms.Add(new SqlParameter("@Status", "Cancelled"));
            prms.Add(new SqlParameter("@Remarks", "Audit cancelled by librarian."));

            DBHelper.ExecuteNonQuery("sp_CloseVerificationSession", prms.ToArray());
            
            CheckActiveAuditSession();
            ShowAlert("Inventory stock audit session cancelled.", true);
        }
        catch (Exception ex)
        {
            ShowAlert("Error cancelling audit session: " + ex.Message, false);
        }
    }

    protected void btnViewActiveReport_Click(object sender, EventArgs e)
    {
        hfActiveTab.Value = "3"; // Switch to Reports tab (Index 3)
        ddlReportType.SelectedValue = "ActiveAuditScanned";
        divReportFilterVal.Visible = false;
        txtReportFilterVal.Text = "";
        BindReportsGrid();
    }

    protected void btnViewActiveMissingReport_Click(object sender, EventArgs e)
    {
        hfActiveTab.Value = "3"; // Switch to Reports tab (Index 3)
        ddlReportType.SelectedValue = "ActiveAuditMissing";
        divReportFilterVal.Visible = false;
        txtReportFilterVal.Text = "";
        BindReportsGrid();
    }

    // =========================================================================
    //  TAB 2: REPORTS & EXPORTS
    // =========================================================================
    private void BindReportsGrid()
    {
        try
        {
            string type = ddlReportType.SelectedValue;
            string filterVal = txtReportFilterVal.Text.Trim();

            List<SqlParameter> prms = new List<SqlParameter>();
            prms.Add(new SqlParameter("@ReportType", type));
            prms.Add(new SqlParameter("@FilterVal", string.IsNullOrEmpty(filterVal) ? (object)DBNull.Value : filterVal));

            DataTable dt = DBHelper.ExecuteReader("sp_GetStockReports", prms.ToArray());
            gvReports.DataSource = dt;
            gvReports.DataBind();

            litReportCount.Text = dt.Rows.Count.ToString();
            litReportTitle.Text = ddlReportType.SelectedItem.Text;
        }
        catch (Exception ex)
        {
            ShowAlert("Error generating inventory report: " + ex.Message, false);
        }
    }

    protected void btnGenerateReport_Click(object sender, EventArgs e)
    {
        BindReportsGrid();
    }

    protected void ddlReportType_SelectedIndexChanged(object sender, EventArgs e)
    {
        string type = ddlReportType.SelectedValue;
        // Show filter textbox only for segmented reports that need criteria
        if (type == "Shelf-wise" || type == "Category-wise" || type == "Author-wise" || type == "Language-wise")
        {
            divReportFilterVal.Visible = true;
            txtReportFilterVal.Text = "";
            txtReportFilterVal.Focus();
        }
        else
        {
            divReportFilterVal.Visible = false;
            txtReportFilterVal.Text = "";
        }
    }

    protected void gvReports_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvReports.PageIndex = e.NewPageIndex;
        BindReportsGrid();
    }

    // =========================================================================
    //  REPORT EXPORTS: EXCEL / CSV / PRINT
    // =========================================================================
    protected void btnExportExcel_Click(object sender, EventArgs e)
    {
        try
        {
            string type = ddlReportType.SelectedValue;
            string filterVal = txtReportFilterVal.Text.Trim();

            List<SqlParameter> prms = new List<SqlParameter>();
            prms.Add(new SqlParameter("@ReportType", type));
            prms.Add(new SqlParameter("@FilterVal", string.IsNullOrEmpty(filterVal) ? (object)DBNull.Value : filterVal));

            DataTable dt = DBHelper.ExecuteReader("sp_GetStockReports", prms.ToArray());
            
            // Clean table for excel formatting
            DataTable excelTable = new DataTable("StockReport");
            excelTable.Columns.Add("Barcode");
            excelTable.Columns.Add("Book Title");
            excelTable.Columns.Add("Authors");
            excelTable.Columns.Add("Category");
            excelTable.Columns.Add("Shelf Address");
            excelTable.Columns.Add("Status");
            excelTable.Columns.Add("Condition");
            excelTable.Columns.Add("Acq Cost");

            foreach (DataRow r in dt.Rows)
            {
                string shelf = (r["HallName"] != DBNull.Value) ? string.Format("{0} (U:{1} R:{2} S:{3})", r["HallName"], r["UnitCode"], r["RackNo"], r["SlotNo"]) : "Unassigned";
                excelTable.Rows.Add(
                    r["Barcode"].ToString(),
                    r["Title"].ToString(),
                    r["Authors"].ToString(),
                    r["CatName"].ToString(),
                    shelf,
                    r["ComputedStatus"].ToString(),
                    r["CondName"].ToString(),
                    Convert.ToDecimal(r["AcqCost"]).ToString("N2")
                );
            }

            ExportToExcel(excelTable, "StockReport_" + type + "_" + DateTime.Now.ToString("yyyyMMdd"));
        }
        catch (Exception ex)
        {
            ShowAlert("Excel export failed: " + ex.Message, false);
        }
    }

    protected void btnExportCSV_Click(object sender, EventArgs e)
    {
        try
        {
            string type = ddlReportType.SelectedValue;
            string filterVal = txtReportFilterVal.Text.Trim();

            List<SqlParameter> prms = new List<SqlParameter>();
            prms.Add(new SqlParameter("@ReportType", type));
            prms.Add(new SqlParameter("@FilterVal", string.IsNullOrEmpty(filterVal) ? (object)DBNull.Value : filterVal));

            DataTable dt = DBHelper.ExecuteReader("sp_GetStockReports", prms.ToArray());

            StringBuilder sb = new StringBuilder();
            sb.AppendLine("Barcode,Book Title,Authors,Category,Shelf Address,Status,Condition,Acq Cost");

            foreach (DataRow r in dt.Rows)
            {
                string shelf = (r["HallName"] != DBNull.Value) ? string.Format("{0} | U:{1} R:{2} S:{3}", r["HallName"], r["UnitCode"], r["RackNo"], r["SlotNo"]) : "Unassigned";
                
                string titleEsc = r["Title"].ToString().Replace("\"", "\"\"");
                string authEsc = r["Authors"].ToString().Replace("\"", "\"\"");
                string catEsc = r["CatName"].ToString().Replace("\"", "\"\"");
                
                sb.AppendLine(string.Format("\"{0}\",\"{1}\",\"{2}\",\"{3}\",\"{4}\",\"{5}\",\"{6}\",\"{7}\"",
                    r["Barcode"].ToString(),
                    titleEsc,
                    authEsc,
                    catEsc,
                    shelf,
                    r["ComputedStatus"].ToString(),
                    r["CondName"].ToString(),
                    Convert.ToDecimal(r["AcqCost"]).ToString("N2")
                ));
            }

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=StockReport_" + type + "_" + DateTime.Now.ToString("yyyyMMdd") + ".csv");
            Response.Charset = "";
            Response.ContentType = "text/csv";
            Response.Write(sb.ToString());
            Response.End();
        }
        catch (Exception ex)
        {
            ShowAlert("CSV export failed: " + ex.Message, false);
        }
    }

    private void ExportToExcel(DataTable dt, string filename)
    {
        Response.Clear();
        Response.Buffer = true;
        Response.AddHeader("content-disposition", "attachment;filename=" + filename + ".xls");
        Response.Charset = "";
        Response.ContentType = "application/vnd.ms-excel";
        
        using (StringWriter sw = new StringWriter())
        {
            using (HtmlTextWriter hw = new HtmlTextWriter(sw))
            {
                GridView gv = new GridView();
                gv.DataSource = dt;
                gv.DataBind();
                gv.RenderControl(hw);
                Response.Write(sw.ToString());
                Response.End();
            }
        }
    }

    public override void VerifyRenderingInServerForm(Control control)
    {
        // Avoids server-side rendering exception during GridView Export
    }

    // =========================================================================
    //  GLOBAL NOTIFICATION ALERTS
    // =========================================================================
    private void ShowAlert(string msg, bool isSuccess)
    {
        litAlertMsg.Text = msg;
        pnlAlert.Visible = true;
        if (isSuccess)
        {
            divAlert.Style["background"] = "#d1fae5";
            divAlert.Style["color"] = "#065f46";
            divAlert.Style["border-left-color"] = "#10b981";
        }
        else
        {
            divAlert.Style["background"] = "#fee2e2";
            divAlert.Style["color"] = "#991b1b";
            divAlert.Style["border-left-color"] = "#ef4444";
        }
    }

    protected void btnMarkSelectedMissing_Click(object sender, EventArgs e)
    {
        int sessionID;
        if (!int.TryParse(hfActiveSessionID.Value, out sessionID))
        {
            ShowAlert("No active audit session.", false);
            return;
        }
        
        short staffID = 142; // Fallback default operator
        if (Session["Emp_ID"] != null)
        {
            staffID = Convert.ToInt16(Session["Emp_ID"]);
        }

        List<string> selectedIDs = new List<string>();
        foreach (GridViewRow row in gvReconcileMissing.Rows)
        {
            if (row.RowType == DataControlRowType.DataRow)
            {
                CheckBox chk = (CheckBox)row.FindControl("chkSelectCopy");
                if (chk != null && chk.Checked)
                {
                    int copyID = Convert.ToInt32(gvReconcileMissing.DataKeys[row.RowIndex].Value);
                    selectedIDs.Add(copyID.ToString());
                }
            }
        }

        if (selectedIDs.Count == 0)
        {
            ShowAlert("Please select at least one copy to mark as missing.", false);
            return;
        }

        try
        {
            string copyIDsCsv = string.Join(",", selectedIDs);
            List<SqlParameter> prms = new List<SqlParameter>();
            prms.Add(new SqlParameter("@SessionID", sessionID));
            prms.Add(new SqlParameter("@StaffID", staffID));
            prms.Add(new SqlParameter("@Remarks", "Reconciliation: Marked missing manually from audit reconciliation tab"));
            prms.Add(new SqlParameter("@CopyIDs", copyIDsCsv));

            DBHelper.ExecuteNonQuery("sp_ReconcileMissingCopies", prms.ToArray());

            // Refresh stats and grids
            BindVerificationProgress(sessionID);
            RefreshDashboardStats();
            ShowAlert(string.Format("Successfully marked {0} selected copies as Missing.", selectedIDs.Count), true);
        }
        catch (Exception ex)
        {
            ShowAlert("Reconciliation failed: " + ex.Message, false);
        }
    }

    protected void btnMarkAllMissing_Click(object sender, EventArgs e)
    {
        int sessionID;
        if (!int.TryParse(hfActiveSessionID.Value, out sessionID))
        {
            ShowAlert("No active audit session.", false);
            return;
        }
        
        short staffID = 142; // Fallback default operator
        if (Session["Emp_ID"] != null)
        {
            staffID = Convert.ToInt16(Session["Emp_ID"]);
        }

        try
        {
            List<SqlParameter> prms = new List<SqlParameter>();
            prms.Add(new SqlParameter("@SessionID", sessionID));
            prms.Add(new SqlParameter("@StaffID", staffID));
            prms.Add(new SqlParameter("@Remarks", "Reconciliation: Marked remaining non-verified copies as missing"));
            prms.Add(new SqlParameter("@CopyIDs", DBNull.Value)); // NULL means ALL non-verified

            DBHelper.ExecuteNonQuery("sp_ReconcileMissingCopies", prms.ToArray());

            // Refresh stats and grids
            BindVerificationProgress(sessionID);
            RefreshDashboardStats();
            ShowAlert("Successfully marked all remaining non-verified expected copies as Missing.", true);
        }
        catch (Exception ex)
        {
            ShowAlert("Reconciliation failed: " + ex.Message, false);
        }
    }

    protected void gvReconcileMissing_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvReconcileMissing.PageIndex = e.NewPageIndex;
        int sessionID;
        if (int.TryParse(hfActiveSessionID.Value, out sessionID))
        {
            BindVerificationProgress(sessionID);
        }
    }
}

// =============================================================================
//  CENTRALIZED DATABASE RUNNER (LOCAL CLASS ENVELOPE)
// =============================================================================
public static class DBHelper
{
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

    public static DataTable ExecuteReaderText(string qryText, params SqlParameter[] prms)
    {
        var dt = new DataTable();
        using (var con = GetConnection())
        using (var cmd = new SqlCommand(qryText, con) { CommandType = CommandType.Text, CommandTimeout = 120 })
        using (var da  = new SqlDataAdapter(cmd))
        {
            if (prms != null) cmd.Parameters.AddRange(prms);
            con.Open();
            da.Fill(dt);
        }
        return dt;
    }
}
