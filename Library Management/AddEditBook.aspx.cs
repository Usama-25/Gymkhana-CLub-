using System.Configuration;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System;
using System.IO;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Pages_Books_AddEditBook : System.Web.UI.Page
{
    private short CurrentStaffID
    {
        get
        {
            if (Session["StaffID"] != null)
                return Convert.ToInt16(Session["StaffID"]);
            return 1; // default fallback (admin)
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.Form != null)
        {
            Page.Form.Enctype = "multipart/form-data";
        }
        if (!IsPostBack)
        {
            InitializeDropdowns();
            SetupSelectedAuthorsTable();
            
            // Check if we are in Edit Mode
            int bookID = 0;
            if (Request.QueryString["BookID"] != null && int.TryParse(Request.QueryString["BookID"], out bookID))
            {
                LoadBookDetails(bookID);
            }
            else
            {
                litPageTitle.Text = "Catalogue";
                btnSave.Visible = true;
                btnUpdate.Visible = false;
                btnSaveAddCopy.Visible = true;

                 // Book No should contain the increment of last copy's BookNo
                 int nextBookNo = 29992;
                 using (var con = DBHelper.GetConnection())
                 {
                     string query = "SELECT ISNULL(MAX(BookNo), 29991) + 1 FROM BookCopies WITH (NOLOCK)";
                     using (var cmd = new SqlCommand(query, con))
                     {
                         con.Open();
                         nextBookNo = Convert.ToInt32(cmd.ExecuteScalar());
                     }
                 }
                 txtBookNo.Text = nextBookNo.ToString();

                txtStatus.Text = "On Shelf";
            }
        }
    }

    // --------------------------------------------------------------
    //  Initialization
    // --------------------------------------------------------------
    private void InitializeDropdowns()
    {
        // 5. Physical Layout Halls
        ddlHall.DataSource = DBHelper.GetHalls();
        ddlHall.DataTextField = "HallDisplay";
        ddlHall.DataValueField = "HallID";
        ddlHall.DataBind();
        ddlHall.Items.Insert(0, new ListItem("- Select Hall -", "0"));

        // Copy Conditions from DB (restricted to New, Old, SH)
        DataTable dtCond = DBHelper.GetTableData("SELECT CondID, CondName FROM CopyConditions WHERE CondName IN ('New', 'Old', 'SH') ORDER BY CondID");
        if (dtCond != null && dtCond.Rows.Count > 0)
        {
            ddlCopyCondition.DataSource = dtCond;
            ddlCopyCondition.DataTextField = "CondName";
            ddlCopyCondition.DataValueField = "CondName";
            ddlCopyCondition.DataBind();
            ddlCopyCondition.Items.Insert(0, new ListItem("-- Select Condition --", ""));
        }
        else
        {
            ddlCopyCondition.Items.Clear();
            ddlCopyCondition.Items.Add(new ListItem("-- Select Condition --", ""));
            ddlCopyCondition.Items.Add(new ListItem("New", "New"));
            ddlCopyCondition.Items.Add(new ListItem("Old", "Old"));
            ddlCopyCondition.Items.Add(new ListItem("SH", "SH"));
        }
    }

    private void SetupSelectedAuthorsTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("AuthorID", typeof(int));
        dt.Columns.Add("AuthorName", typeof(string));
        dt.Columns.Add("Role", typeof(string));
        ViewState["SelectedAuthors"] = dt;
    }

    // --------------------------------------------------------------
    //  Load Book Details (Edit Mode)
    // --------------------------------------------------------------
    private void LoadBookDetails(int bookID)
    {
        DataSet ds = DBHelper.GetBookDetail(bookID);
        if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        {
            ShowAlert("Error: Book details not found.", "alert-error");
            return;
        }

        DataRow bookRow = ds.Tables[0].Rows[0];
        hfBookID.Value = bookID.ToString();
        
        // Set default fallback next Book No in case there are no copies
        int nextBookNo = 29992;
        using (var con = DBHelper.GetConnection())
        {
            string query = "SELECT ISNULL(MAX(BookNo), 29991) + 1 FROM BookCopies WITH (NOLOCK)";
            using (var cmd = new SqlCommand(query, con))
            {
                con.Open();
                nextBookNo = Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        int existingCopyCount = (ds.Tables.Count > 2) ? ds.Tables[2].Rows.Count : 0;
        txtCopyCount.Text = existingCopyCount > 0 ? existingCopyCount.ToString() : "1";

        if (ds.Tables.Count > 2 && ds.Tables[2].Rows.Count > 0)
        {
            DataRow firstCopyRow = ds.Tables[2].Rows[0];
            txtBookNo.Text = firstCopyRow["BookNo"] != DBNull.Value ? firstCopyRow["BookNo"].ToString() : nextBookNo.ToString();

            // Populate Condition
            string copyCond = firstCopyRow["CondName"] != DBNull.Value ? firstCopyRow["CondName"].ToString() : "";
            if (!string.IsNullOrEmpty(copyCond))
            {
                txtCopyCondition.Text = copyCond;
                if (ddlCopyCondition.Items.FindByValue(copyCond) != null)
                {
                    ddlCopyCondition.SelectedValue = copyCond;
                }
                else if (ddlCopyCondition.Items.FindByText(copyCond) != null)
                {
                    ddlCopyCondition.SelectedItem.Text = copyCond;
                }
            }

            // Populate Cost (PKR)
            string copyCost = firstCopyRow["AcqCost"] != DBNull.Value ? firstCopyRow["AcqCost"].ToString() : "";
            if (!string.IsNullOrEmpty(copyCost))
            {
                decimal costDec;
                if (decimal.TryParse(copyCost, out costDec))
                {
                    txtCopyCost.Text = (costDec % 1 == 0) ? ((int)costDec).ToString() : costDec.ToString("0.00");
                }
                else
                {
                    txtCopyCost.Text = copyCost;
                }
            }
        }
        else
        {
            txtBookNo.Text = nextBookNo.ToString();
        }

        litPageTitle.Text = "Catalogue — " + bookRow["Title"].ToString();
        btnSave.Visible = false;
        btnUpdate.Visible = true;
        btnSaveAddCopy.Visible = true;

        // Populate fields
        txtISBN13.Text = bookRow["ISBN13"] != DBNull.Value && bookRow["ISBN13"] != null ? bookRow["ISBN13"].ToString().Trim() : "";
        txtISBN13.Enabled = true;
        btnGenerateISBN.Visible = true;
        txtISBN10.Text = bookRow["ISBN10"] != DBNull.Value && bookRow["ISBN10"] != null ? bookRow["ISBN10"].ToString().Trim() : "";
        txtClassNo.Text = bookRow["ClassNo"].ToString();
        txtTitle.Text = bookRow["Title"].ToString();
        txtSubTitle.Text = bookRow["SubTitle"].ToString();
        
        string catName = bookRow["CatName"] != DBNull.Value && bookRow["CatName"] != null ? bookRow["CatName"].ToString() : "";
        txtCategory.Text = catName;

        string pubName = bookRow["PubName"] != DBNull.Value && bookRow["PubName"] != null ? bookRow["PubName"].ToString() : null;
        if (pubName != null)
        {
            txtPublisher.Text = pubName;
        }

        txtPubYear.Text = bookRow["PublishYear"].ToString();
        txtEdition.Text = bookRow["Edition"].ToString();
        
        string langName = bookRow["LangName"] != DBNull.Value && bookRow["LangName"] != null ? bookRow["LangName"].ToString() : "";
        txtLanguage.Text = langName;

        txtPageCount.Text = bookRow["PageCount"].ToString();
        txtTags.Text = bookRow["Tags"].ToString();
        txtDescription.Text = bookRow["Synopsis"].ToString();
        txtClassNo.Text = bookRow["ClassNo"] != DBNull.Value && bookRow["ClassNo"] != null ? bookRow["ClassNo"].ToString() : "";

        // Populate DDC Call Number
        string fullDdc = bookRow["DDC"] != DBNull.Value && bookRow["DDC"] != null ? bookRow["DDC"].ToString().Trim() : "";
        if (!string.IsNullOrEmpty(fullDdc))
        {
            hfIsDdcEdited.Value = "true";
            
            // If it contains " to ", take the first part
            string firstPart = fullDdc;
            if (fullDdc.Contains(" to "))
            {
                firstPart = fullDdc.Split(new[] { " to " }, StringSplitOptions.RemoveEmptyEntries)[0].Trim();
            }
            
            // Check if it's hyphenated (like 928.982-TUN-1) or space-separated (like 928.982 TUN 1)
            if (firstPart.Contains("-"))
            {
                var parts = firstPart.Split(new[] { '-' }, StringSplitOptions.RemoveEmptyEntries);
                if (parts.Length >= 1) txtDDC.Text = parts[0];
                if (parts.Length >= 2) txtDdcSuffix1.Text = parts[1];
                
                if (parts.Length >= 3)
                {
                    txtDdcSuffix2.Text = string.Join("-", parts, 2, parts.Length - 2);
                }
                else
                {
                    string nextSuffix2 = GetNextDdcSuffix2(txtDDC.Text, txtDdcSuffix1.Text);
                    if (!string.IsNullOrEmpty(nextSuffix2))
                    {
                        txtDdcSuffix2.Text = nextSuffix2;
                    }
                }
            }
            else
            {
                var parts = firstPart.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                if (parts.Length >= 1) txtDDC.Text = parts[0];
                if (parts.Length >= 2) txtDdcSuffix1.Text = parts[1];
                
                if (parts.Length >= 3)
                {
                    txtDdcSuffix2.Text = string.Join(" ", parts, 2, parts.Length - 2);
                }
                else
                {
                    string nextSuffix2 = GetNextDdcSuffix2(txtDDC.Text, txtDdcSuffix1.Text);
                    if (!string.IsNullOrEmpty(nextSuffix2))
                    {
                        txtDdcSuffix2.Text = nextSuffix2;
                    }
                }
            }
        }
        else
        {
            txtDDC.Text = "";
            txtDdcSuffix1.Text = "";
            txtDdcSuffix2.Text = "";
        }

        txtAcqNo.Text = GetColumnValue(bookRow, "AcqNo", bookID);
        txtPublishingPlace.Text = GetColumnValue(bookRow, "PublishingPlace", bookID);
        txtLiDate.Text = GetColumnValue(bookRow, "LiDate", bookID);
        txtVolume.Text = GetColumnValue(bookRow, "Volume", bookID);
        txtWwwLink.Text = GetColumnValue(bookRow, "WwwLink", bookID);
        txtSeries.Text = GetColumnValue(bookRow, "Series", bookID);
        txtRecBy.Text = GetColumnValue(bookRow, "RecBy", bookID);
        txtDonatedBy.Text = GetColumnValue(bookRow, "DonatedBy", bookID);
        txtMSNo.Text = GetColumnValue(bookRow, "MS_No", bookID);
        txtDonatedByName.Text = GetColumnValue(bookRow, "DonatedByName", bookID);
        txtPurchaseRef.Text = GetColumnValue(bookRow, "PurchaseRef", bookID);
        txtPurchaseDate.Text = GetColumnValue(bookRow, "PurchaseDate", bookID);
        txtPriceFcy.Text = GetColumnValue(bookRow, "PriceFcy", bookID);
        txtPricePkr.Text = GetColumnValue(bookRow, "PricePkr", bookID);
        txtFormat.Text = GetColumnValue(bookRow, "Format", bookID);
        txtSource.Text = GetColumnValue(bookRow, "Source", bookID);
        txtStatus.Text = GetColumnValue(bookRow, "Status", bookID);
        if (string.IsNullOrEmpty(txtStatus.Text)) txtStatus.Text = "On Shelf";
        txtClassSeq.Text = GetColumnValue(bookRow, "ClassSeq", bookID);
        txtLocation.Text = GetColumnValue(bookRow, "Location", bookID);

        string isRefStr = GetColumnValue(bookRow, "IsReference", bookID);
        cbReference.Checked = !string.IsNullOrEmpty(isRefStr) && Convert.ToBoolean(isRefStr);

        string notIssuedStr = GetColumnValue(bookRow, "NotToBeIssued", bookID);
        cbNotIssued.Checked = !string.IsNullOrEmpty(notIssuedStr) && Convert.ToBoolean(notIssuedStr);

        string printDetStr = GetColumnValue(bookRow, "PrintBookDetail", bookID);
        cbPrintDetails.Checked = !string.IsNullOrEmpty(printDetStr) && Convert.ToBoolean(printDetStr);

        string isAdultsStr = GetColumnValue(bookRow, "IsAdults", bookID);
        cbAdults.Checked = !string.IsNullOrEmpty(isAdultsStr) && Convert.ToBoolean(isAdultsStr);

        string isChildrenStr = GetColumnValue(bookRow, "IsChildren", bookID);
        cbChildren.Checked = !string.IsNullOrEmpty(isChildrenStr) && Convert.ToBoolean(isChildrenStr);

        // Image details
        string coverFile = bookRow["CoverFile"].ToString();
        if (!string.IsNullOrEmpty(coverFile))
        {
            string coverUrl = ResolveUrl("~/Library Management/Images/BookCovers/" + coverFile);
            imgCoverPreview.ImageUrl = coverUrl;
            imgCoverPreview.Style["display"] = "block";
            coverPlaceholder.Style["display"] = "none";
            pnlCurrentCover.Visible = true;
            lblCurrentCoverFile.Text = coverFile;
            
            // Client side needs to know cover zone state
            ScriptManager.RegisterStartupScript(this, this.GetType(), "CoverInit", 
                "document.getElementById('coverPlaceholder').style.display = 'none';" +
                "document.getElementById('coverZone').classList.add('has-image');", true);
        }
        else
        {
            imgCoverPreview.Style["display"] = "none";
            coverPlaceholder.Style["display"] = "block";
        }

        // Binds Authors Repeater and populates textboxes
        DataTable authorTable = ViewState["SelectedAuthors"] as DataTable ?? new DataTable();
        authorTable.Rows.Clear();
        int authorIdx = 1;
        foreach (DataRow authorRow in ds.Tables[1].Rows)
        {
            DataRow r = authorTable.NewRow();
            r["AuthorID"] = Convert.ToInt32(authorRow["AuthorID"]);
            r["AuthorName"] = authorRow["FullName"].ToString();
            r["Role"] = authorRow["RoleName"].ToString();
            authorTable.Rows.Add(r);

            string fullName = authorRow["FullName"].ToString();
            string role = authorRow["RoleName"].ToString();
            string firstName = "";
            string lastName = "";
            if (fullName.Contains(","))
            {
                string[] parts = fullName.Split(new char[] { ',' }, 2);
                lastName = parts[0].Trim();
                firstName = parts[1].Trim();
            }
            else
            {
                int lastSpaceIndex = fullName.LastIndexOf(' ');
                if (lastSpaceIndex >= 0)
                {
                    firstName = fullName.Substring(0, lastSpaceIndex).Trim();
                    lastName = fullName.Substring(lastSpaceIndex + 1).Trim();
                }
                else
                {
                    lastName = fullName;
                }
            }

            if (role.Equals("Editor", StringComparison.OrdinalIgnoreCase))
            {
                txtEditorCompiler.Text = fullName;
            }
            else
            {
                if (authorIdx == 1)
                {
                    txtAuthor1FN.Text = firstName;
                    txtAuthor1LN.Text = lastName;
                    authorIdx++;
                }
                else if (authorIdx == 2)
                {
                    txtAuthor2FN.Text = firstName;
                    txtAuthor2LN.Text = lastName;
                    authorIdx++;
                }
                else if (authorIdx == 3)
                {
                    txtAuthor3FN.Text = firstName;
                    txtAuthor3LN.Text = lastName;
                    authorIdx++;
                }
            }
        }
        ViewState["SelectedAuthors"] = authorTable;
        BindAuthorsRepeater();

        // Binds Copies
        if (ds.Tables.Count > 2 && ds.Tables[2].Rows.Count > 0)
        {
            pnlExistingCopies.Visible = true;
            rptCopies.DataSource = ds.Tables[2];
            rptCopies.DataBind();
        }
    }

    private string GetColumnValue(DataRow row, string colName, int bookID)
    {
        if (row != null && row.Table.Columns.Contains(colName) && row[colName] != DBNull.Value && row[colName] != null)
        {
            return row[colName].ToString();
        }

        try
        {
            string sqlCol = colName == "MS_No" ? "[MS_No]" : colName;
            DataTable dt = DBHelper.GetTableData("SELECT " + sqlCol + " FROM Books WHERE BookID = " + bookID);
            if (dt != null && dt.Rows.Count > 0 && dt.Rows[0][colName] != DBNull.Value && dt.Rows[0][colName] != null)
            {
                return dt.Rows[0][colName].ToString();
            }
        }
        catch { }

        return "";
    }

    // --------------------------------------------------------------
    //  Multi-Author Event Handlers
    // --------------------------------------------------------------
    protected void btnAddAuthor_Click(object sender, EventArgs e)
    {
        string authorName = txtAuthorName.Text.Trim();
        if (string.IsNullOrEmpty(authorName)) return;

        int authorID = GetOrCreateAuthor(authorName);
        string name = GetAuthorFullName(authorID);
        string role = ddlAuthorRole.SelectedValue;

        DataTable dt = ViewState["SelectedAuthors"] as DataTable;
        if (dt != null)
        {
            // Check duplicates
            foreach (DataRow row in dt.Rows)
            {
                if (Convert.ToInt32(row["AuthorID"]) == authorID)
                {
                    ShowAlert("Author is already added to this book.", "alert-info");
                    return;
                }
            }

            DataRow newRow = dt.NewRow();
            newRow["AuthorID"] = authorID;
            newRow["AuthorName"] = name;
            newRow["Role"] = role;
            dt.Rows.Add(newRow);

            ViewState["SelectedAuthors"] = dt;
            BindAuthorsRepeater();

            // Auto-regenerate DDC call number
            AutoGenerateDDC();
        }
        
        // Reset text field
        txtAuthorName.Text = "";
    }

    protected void rptAuthors_Command(object source, CommandEventArgs e)
    {
        if (e.CommandName == "RemoveAuthor")
        {
            int authorID = Convert.ToInt32(e.CommandArgument);
            DataTable dt = ViewState["SelectedAuthors"] as DataTable;
            if (dt != null)
            {
                for (int i = dt.Rows.Count - 1; i >= 0; i--)
                {
                    if (Convert.ToInt32(dt.Rows[i]["AuthorID"]) == authorID)
                    {
                        dt.Rows.RemoveAt(i);
                        break;
                    }
                }
                ViewState["SelectedAuthors"] = dt;
                BindAuthorsRepeater();
                
                // Regenerate DDC
                AutoGenerateDDC();
            }
        }
    }

    private void BindAuthorsRepeater()
    {
        DataTable dt = ViewState["SelectedAuthors"] as DataTable;
        rptAuthors.DataSource = dt;
        rptAuthors.DataBind();
    }

    // --------------------------------------------------------------
    //  AJAX WebMethods for Location Selection
    // --------------------------------------------------------------
    [System.Web.Services.WebMethod]
    public static object GetAisles(short hallID)
    {
        DataTable dt = DBHelper.GetAisles(hallID);
        var list = new System.Collections.Generic.List<object>();
        foreach (DataRow row in dt.Rows)
        {
            list.Add(new { Value = row["AisleID"], Text = row["AisleDisplay"] });
        }
        return list;
    }

    [System.Web.Services.WebMethod]
    public static object GetShelfUnits(int aisleID)
    {
        DataTable dt = DBHelper.GetShelfUnits(aisleID);
        var list = new System.Collections.Generic.List<object>();
        foreach (DataRow row in dt.Rows)
        {
            list.Add(new { Value = row["ShelfUnitID"], Text = row["ShelfUnitCode"] });
        }
        return list;
    }

    [System.Web.Services.WebMethod]
    public static object GetRacks(int unitID)
    {
        DataTable dt = DBHelper.GetRacks(unitID);
        var list = new System.Collections.Generic.List<object>();
        foreach (DataRow row in dt.Rows)
        {
            list.Add(new { Value = row["RackID"], Text = row["RackDisplay"] });
        }
        return list;
    }

    [System.Web.Services.WebMethod]
    public static object GetRackSlotsAndInfo(short rackID)
    {
        DataTable rackData = DBHelper.GetTableData("SELECT TotalSlots, SubjectTag FROM Racks WHERE RackID = " + rackID);
        if (rackData.Rows.Count > 0)
        {
            int totalSlots = Convert.ToInt32(rackData.Rows[0]["TotalSlots"]);
            string subject = rackData.Rows[0]["SubjectTag"] != DBNull.Value && rackData.Rows[0]["SubjectTag"] != null ? rackData.Rows[0]["SubjectTag"].ToString() : "N/A";
            
            DataTable slotsDt = DBHelper.GetRackSlots(rackID, totalSlots);
            var slotsList = new System.Collections.Generic.List<object>();
            foreach(DataRow row in slotsDt.Rows)
            {
                slotsList.Add(new {
                    SlotNumber = row["SlotNumber"],
                    IsOccupied = row["IsOccupied"],
                    BookTitle = row["BookTitle"] != DBNull.Value ? row["BookTitle"].ToString() : "",
                    RackID = row["RackID"]
                });
            }
            return new { TotalSlots = totalSlots, SubjectTag = subject, Slots = slotsList };
        }
        return null;
    }

    protected void lbClearLocation_Click(object sender, EventArgs e)
    {
        hfSelectedRack.Value = "";
        hfSelectedSlot.Value = "";
        pnlLocationSummary.Visible = false;
        ResetLocationPanel(0);
    }

    private void ResetLocationPanel(int level)
    {
        if (level <= 0)
        {
            ddlHall.SelectedValue = "0";
            ddlAisle.Items.Clear();
            ddlAisle.Items.Insert(0, new ListItem("- Aisle -", "0"));
            ddlAisle.Enabled = false;
        }
        if (level <= 1)
        {
            ddlShelfUnit.Items.Clear();
            ddlShelfUnit.Items.Insert(0, new ListItem("- Shelf Unit -", "0"));
            ddlShelfUnit.Enabled = false;
        }
        if (level <= 2)
        {
            ddlRack.Items.Clear();
            ddlRack.Items.Insert(0, new ListItem("- Rack -", "0"));
            ddlRack.Enabled = false;
        }
        pnlRackSlots.Style["display"] = "none";
    }

    // --------------------------------------------------------------
    //  Cover Image Upload Handlers
    // --------------------------------------------------------------
    protected void btnUploadCover_Click(object sender, EventArgs e)
    {
        if (!fuCover.HasFile)
        {
            lblCoverStatus.Text = "Please select an image file to upload first.";
            lblCoverStatus.ForeColor = System.Drawing.Color.Red;
            return;
        }

        // Use ISBN if available, otherwise use a timestamp-based filename
        string filePrefix = txtISBN13.Text.Trim();
        if (!string.IsNullOrEmpty(filePrefix))
        {
            // Clean up special characters to make a safe filename prefix
            string cleanISBN = System.Text.RegularExpressions.Regex.Replace(filePrefix, @"[^a-zA-Z0-9]", "");
            if (!string.IsNullOrEmpty(cleanISBN))
            {
                filePrefix = cleanISBN;
            }
            else
            {
                filePrefix = "COVER_" + DateTime.Now.ToString("yyyyMMddHHmmss");
            }
        }
        else
        {
            filePrefix = "COVER_" + DateTime.Now.ToString("yyyyMMddHHmmss");
        }

        try
        {
            string ext = Path.GetExtension(fuCover.FileName).ToLower();

            if (fuCover.PostedFile.ContentLength > 2 * 1024 * 1024)
            {
                lblCoverStatus.Text = "File too large (limit is 2 MB).";
                lblCoverStatus.ForeColor = System.Drawing.Color.Red;
                return;
            }

            string dirPath = Server.MapPath("~/Library Management/Images/BookCovers/");
            if (!Directory.Exists(dirPath))
            {
                Directory.CreateDirectory(dirPath);
            }

            string fileName = filePrefix + ext;
            string fullPath = Path.Combine(dirPath, fileName);
            fuCover.SaveAs(fullPath);

            hfCoverPath.Value = fileName;
            hfThumbPath.Value = fileName; // for now store the same file

            imgCoverPreview.ImageUrl = ResolveUrl("~/Library Management/Images/BookCovers/" + fileName);
            imgCoverPreview.Style["display"] = "block";
            coverPlaceholder.Style["display"] = "none";
            pnlCurrentCover.Visible = true;
            lblCurrentCoverFile.Text = fileName;
            
            lblCoverStatus.Text = "Image uploaded successfully!";
            lblCoverStatus.ForeColor = System.Drawing.Color.Green;
            
            // Client visual state sync
            ScriptManager.RegisterStartupScript(this, this.GetType(), "CoverSync", 
                "document.getElementById('coverPlaceholder').style.display = 'none';" +
                "document.getElementById('coverZone').classList.add('has-image');", true);
        }
        catch (Exception ex)
        {
            lblCoverStatus.Text = "Upload error: " + ex.Message;
            lblCoverStatus.ForeColor = System.Drawing.Color.Red;
        }
    }

    protected void btnClearCover_Click(object sender, EventArgs e)
    {
        hfCoverPath.Value = "";
        hfThumbPath.Value = "";
        imgCoverPreview.ImageUrl = "";
        imgCoverPreview.Style["display"] = "none";
        coverPlaceholder.Style["display"] = "block";
        pnlCurrentCover.Visible = false;
        lblCurrentCoverFile.Text = "";
        lblCoverStatus.Text = "";
        
        // Client visual state reset
        ScriptManager.RegisterStartupScript(this, this.GetType(), "CoverReset", 
            "document.getElementById('coverPlaceholder').style.display = 'block';" +
            "document.getElementById('coverZone').classList.remove('has-image');", true);
    }

    // --------------------------------------------------------------
    //  ISBN Auto-Generation Handlers
    //  Format: AUTHOR-PUBLISHER-EDITION-LANGUAGE-SEQ
    //  e.g.  HAM-PEN-3RD-EN-001
    // --------------------------------------------------------------
    protected void btnGenerateISBN_Click(object sender, EventArgs e)
    {
        // Regenerate ISBN when user explicitly clicks the button
        AutoGenerateISBN();
    }

    /// <summary>
    /// Auto-generates an ISBN code based on Author, Publisher, Edition, and Language.
    /// Falls back to a library-prefixed code if no author is available yet.
    /// Format: {Author3}-{Pub3}-{Edition}-{Lang}-{Seq3}
    /// </summary>
    private void AutoGenerateISBN()
    {
        string generated = GenerateISBN();
        if (string.IsNullOrEmpty(generated))
        {
            // Fallback when no author selected yet
            generated = GenerateISBNFallback();
        }
        txtISBN13.Text = generated;
        
        // Trigger Javascript validation to update badge visual state
        ScriptManager.RegisterStartupScript(this, this.GetType(), "ValidateISBNCall", "liveValidateISBN('" + generated + "');", true);
    }

    /// <summary>
    /// Generates ISBN: {Author3}-{Pub3}-{Edition}-{Lang}-{Seq3}
    /// Returns null if no author is available.
    /// </summary>
    private string GenerateISBN()
    {
        string author = GetAuthorPrefix();
        if (string.IsNullOrEmpty(author)) return null;

        string publisher = GetPublisherPrefix();
        string edition = GetEditionPrefix();
        string lang = GetLanguageCode();

        // Build: AUTHOR-PUBLISHER-EDITION-LANGUAGE-
        string basePrefix = author + "-" + publisher + "-" + edition + "-" + lang + "-";

        string suffix = DBHelper.GetNextISBNSuffix(basePrefix);
        return basePrefix + suffix;
    }

    /// <summary>
    /// Fallback ISBN when no author is selected yet.
    /// Format: LGC-{Pub3}-{Edition}-{Lang}-{Seq3}  e.g. LGC-GEN-1E-EN-001
    /// </summary>
    private string GenerateISBNFallback()
    {
        string publisher = GetPublisherPrefix();
        string edition = GetEditionPrefix();
        string lang = GetLanguageCode();

        string basePrefix = "LGC-" + publisher + "-" + edition + "-" + lang + "-";
        string suffix = DBHelper.GetNextISBNSuffix(basePrefix);
        return basePrefix + suffix;
    }

    /// <summary>
    /// Returns 3-letter uppercase prefix from author's last name.
    /// AuthorName format can be "LastName, FirstName" or "FirstName LastName".
    /// </summary>
    private string GetAuthorPrefix()
    {
        string authorName = "";
        DataTable dt = ViewState["SelectedAuthors"] as DataTable;
        if (dt != null && dt.Rows.Count > 0)
        {
            authorName = dt.Rows[0]["AuthorName"].ToString();
        }
        else if (!string.IsNullOrEmpty(txtAuthorName.Text))
        {
            authorName = txtAuthorName.Text.Trim();
        }

        if (string.IsNullOrEmpty(authorName)) return null;

        // Parse last name
        string lastName = "";
        if (authorName.Contains(","))
        {
            lastName = authorName.Split(',')[0].Trim();
        }
        else
        {
            int lastSpace = authorName.LastIndexOf(' ');
            if (lastSpace >= 0)
            {
                lastName = authorName.Substring(lastSpace + 1).Trim();
            }
            else
            {
                lastName = authorName;
            }
        }

        // Keep only letters
        string letters = System.Text.RegularExpressions.Regex.Replace(lastName, "[^a-zA-Z]", "").ToUpper();
        if (letters.Length >= 3) return letters.Substring(0, 3);
        if (letters.Length > 0) return letters.PadRight(3, 'X');
        return "UNK";
    }

    /// <summary>
    /// Returns 3-letter uppercase prefix from publisher name. "GEN" if none selected.
    /// </summary>
    private string GetPublisherPrefix()
    {
        string pubName = txtPublisher.Text.Trim();
        if (string.IsNullOrEmpty(pubName)) return "GEN";
        string letters = System.Text.RegularExpressions.Regex.Replace(pubName, "[^a-zA-Z]", "").ToUpper();
        if (letters.Length >= 3) return letters.Substring(0, 3);
        if (letters.Length > 0) return letters.PadRight(3, 'X');
        return "GEN";
    }

    /// <summary>
    /// Returns edition prefix from the Edition text field.
    /// Keeps only alphanumeric chars, max 4 chars. Defaults to "1E" (First Edition).
    /// </summary>
    private string GetEditionPrefix()
    {
        string edition = txtEdition.Text.Trim();
        if (string.IsNullOrEmpty(edition)) return "1E";
        string clean = System.Text.RegularExpressions.Regex.Replace(edition, "[^a-zA-Z0-9]", "").ToUpper();
        if (string.IsNullOrEmpty(clean)) return "1E";
        if (clean.Length > 4) return clean.Substring(0, 4);
        return clean;
    }

    /// <summary>
    /// Returns 2-letter ISO language code from the Language dropdown.
    /// </summary>
    private string GetLanguageCode()
    {
        string langName = txtLanguage.Text.Trim();
        if (string.IsNullOrEmpty(langName)) return "EN";
        DataTable dt = DBHelper.GetLanguages();
        foreach (DataRow row in dt.Rows)
        {
            if (row["LangName"].ToString().Equals(langName, System.StringComparison.OrdinalIgnoreCase))
            {
                return row["LangCode"].ToString().ToUpper();
            }
        }
        string clean = System.Text.RegularExpressions.Regex.Replace(langName, "[^a-zA-Z]", "");
        return clean.Length >= 2 ? clean.Substring(0, 2).ToUpper() : "EN";
    }

    private byte GetOrCreateLanguage(string langName)
    {
        string cleanName = langName.Trim();
        string query = "SELECT LangID FROM Languages WHERE LangName = @LangName";
        using (var con = DBHelper.GetConnection())
        using (var cmd = new SqlCommand(query, con))
        {
            cmd.Parameters.AddWithValue("@LangName", cleanName);
            con.Open();
            object result = cmd.ExecuteScalar();
            if (result != null && result != DBNull.Value)
            {
                return Convert.ToByte(result);
            }
        }
        
        string langCode = cleanName.Length >= 3 ? cleanName.Substring(0, 3).ToLower() : cleanName.ToLower();
        string insertQuery = "INSERT INTO Languages (LangCode, LangName, IsActive) VALUES (@LangCode, @LangName, 1); SELECT SCOPE_IDENTITY();";
        using (var con = DBHelper.GetConnection())
        using (var cmd = new SqlCommand(insertQuery, con))
        {
            cmd.Parameters.AddWithValue("@LangCode", langCode);
            cmd.Parameters.AddWithValue("@LangName", cleanName);
            con.Open();
            return Convert.ToByte(cmd.ExecuteScalar());
        }
    }

    private static bool ContainsUrdu(string input)
    {
        if (string.IsNullOrEmpty(input)) return false;
        foreach (char c in input)
        {
            if (c >= 0x0600 && c <= 0x06FF)
                return true;
        }
        return false;
    }

    private static string ConvertToUrduDigits(string input)
    {
        if (string.IsNullOrEmpty(input)) return input;
        char[] englishDigits = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' };
        char[] urduDigits = { '\u06F0', '\u06F1', '\u06F2', '\u06F3', '\u06F4', '\u06F5', '\u06F6', '\u06F7', '\u06F8', '\u06F9' };
        string result = input;
        for (int i = 0; i < 10; i++)
        {
            result = result.Replace(englishDigits[i], urduDigits[i]);
        }
        return result;
    }

    private short GetCategoryIDByName(string catName)
    {
        if (string.IsNullOrEmpty(catName)) return 0;
        string cleanName = catName.Trim();

        // Exact match
        string query = "SELECT CatID FROM Categories WHERE (CatName = @CatName OR CatCode = @CatName) AND IsActive = 1";
        using (var con = DBHelper.GetConnection())
        using (var cmd = new SqlCommand(query, con))
        {
            cmd.Parameters.AddWithValue("@CatName", cleanName);
            con.Open();
            object result = cmd.ExecuteScalar();
            if (result != null && result != DBNull.Value)
            {
                return Convert.ToInt16(result);
            }
        }

        // Substring / prefix match
        string queryFallback = "SELECT TOP 1 CatID FROM Categories WHERE (CatName LIKE @Pattern OR CatCode LIKE @Pattern) AND IsActive = 1 ORDER BY CatName";
        using (var con = DBHelper.GetConnection())
        using (var cmd = new SqlCommand(queryFallback, con))
        {
            cmd.Parameters.AddWithValue("@Pattern", "%" + cleanName + "%");
            con.Open();
            object result = cmd.ExecuteScalar();
            if (result != null && result != DBNull.Value)
            {
                return Convert.ToInt16(result);
            }
        }

        return 0;
    }

    private short GetOrCreateCategory(string catName)
    {
        string cleanName = catName.Trim();
        short existingID = GetCategoryIDByName(cleanName);
        if (existingID > 0) return existingID;

        // Generate unique code
        string baseCode = "CAT";
        if (ContainsUrdu(cleanName))
        {
            // For Urdu category name, clean up special characters and grab first 4 Urdu characters
            string cleanUrdu = System.Text.RegularExpressions.Regex.Replace(cleanName, @"[^\u0600-\u06FF]", "");
            if (cleanUrdu.Length >= 2)
            {
                baseCode = cleanUrdu.Substring(0, Math.Min(4, cleanUrdu.Length));
            }
        }
        else
        {
            string cleanEng = System.Text.RegularExpressions.Regex.Replace(cleanName, "[^a-zA-Z0-9]", "").ToUpper();
            if (cleanEng.Length >= 2)
            {
                baseCode = cleanEng.Substring(0, Math.Min(4, cleanEng.Length));
            }
        }

        string catCode = baseCode;
        int checkCount = 1;
        int attempt = 1;
        while (checkCount > 0 && attempt <= 20)
        {
            string checkQuery = "SELECT COUNT(*) FROM Categories WHERE CatCode = @CatCode";
            using (var con = DBHelper.GetConnection())
            using (var cmd = new SqlCommand(checkQuery, con))
            {
                cmd.Parameters.AddWithValue("@CatCode", catCode);
                con.Open();
                checkCount = Convert.ToInt32(cmd.ExecuteScalar());
            }

            if (checkCount > 0)
            {
                catCode = baseCode + new Random().Next(10, 99).ToString();
                attempt++;
            }
        }

        string insertQuery = "INSERT INTO Categories (CatCode, CatName, IsActive) VALUES (@CatCode, @CatName, 1); SELECT SCOPE_IDENTITY();";
        using (var con = DBHelper.GetConnection())
        using (var cmd = new SqlCommand(insertQuery, con))
        {
            cmd.Parameters.AddWithValue("@CatCode", catCode);
            cmd.Parameters.AddWithValue("@CatName", cleanName);
            con.Open();
            return Convert.ToInt16(cmd.ExecuteScalar());
        }
    }

    // --------------------------------------------------------------
    //  Saving Operations
    // --------------------------------------------------------------
    protected void btnSave_Click(object sender, EventArgs e)
    {
        SaveBookData(true);
    }

    protected void btnUpdate_Click(object sender, EventArgs e)
    {
        SaveBookData(false);
    }

    protected void btnSaveAddCopy_Click(object sender, EventArgs e)
    {
        // "New" button — clear form fields and load next Book No
        ClearForm();
    }

    private void ClearForm()
    {
        // Get next Book No
        int nextBookNo = 29992;
        using (var con = DBHelper.GetConnection())
        {
            string query = "SELECT ISNULL(MAX(BookNo), 29991) + 1 FROM BookCopies WITH (NOLOCK)";
            using (var cmd = new SqlCommand(query, con))
            {
                con.Open();
                nextBookNo = Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        // Reset hidden fields
        hfBookID.Value = "0";
        hfCoverPath.Value = "";
        hfThumbPath.Value = "";
        hfSelectedSlot.Value = "";
        hfSelectedRack.Value = "";
        hfIsDdcEdited.Value = "false";

        // Keep Book No
        txtBookNo.Text = nextBookNo.ToString();

        // Clear all text fields
        txtAcqNo.Text = "";
        txtCopyCondition.Text = "";
        txtDDC.Text = "";
        txtDdcSuffix1.Text = "";
        txtDdcSuffix2.Text = "";
        txtLocation.Text = "";
        txtClassNo.Text = "";
        txtLanguage.Text = "";
        txtFormat.Text = "";
        txtSource.Text = "";
        txtStatus.Text = "On Shelf";
        txtClassSeq.Text = "";
        txtCategory.Text = "";
        txtAuthor1FN.Text = "";
        txtAuthor1LN.Text = "";
        txtAuthor2FN.Text = "";
        txtAuthor2LN.Text = "";
        txtAuthor3FN.Text = "";
        txtAuthor3LN.Text = "";
        txtEditorCompiler.Text = "";
        txtTitle.Text = "";
        txtSubTitle.Text = "";
        txtPublisher.Text = "";
        txtLiDate.Text = "";
        txtPublishingPlace.Text = "";
        txtPubYear.Text = "";
        txtEdition.Text = "";
        txtPageCount.Text = "";
        txtISBN13.Text = "";
        txtISBN13.Enabled = true;
        btnGenerateISBN.Visible = true;
        txtISBN10.Text = "";
        txtVolume.Text = "";
        txtWwwLink.Text = "";
        txtSeries.Text = "";
        txtCopyCount.Text = "1";
        txtDonatedBy.Text = "";
        txtMSNo.Text = "";
        txtDonatedByName.Text = "";
        txtPurchaseRef.Text = "";
        txtPurchaseDate.Text = "";
        txtPriceFcy.Text = "";
        txtPricePkr.Text = "";
        txtCopyCost.Text = "";
        txtDescription.Text = "";
        txtRecBy.Text = "";
        txtAcqDate.Text = "";
        txtValue.Text = "";
        txtRemarks.Text = "";
        txtTags.Text = "";
        txtCopyNotes.Text = "";
        txtAuthorName.Text = "";

        // Reset checkboxes & dropdowns
        cbReference.Checked = false;
        cbNotIssued.Checked = false;
        cbPrintDetails.Checked = false;
        cbAdults.Checked = false;
        cbChildren.Checked = false;
        if (ddlCopyCondition.Items.Count > 0) ddlCopyCondition.SelectedIndex = 0;

        // Reset cover image
        imgCoverPreview.ImageUrl = "";
        imgCoverPreview.Style["display"] = "none";
        coverPlaceholder.Style["display"] = "block";
        pnlCurrentCover.Visible = false;
        lblCurrentCoverFile.Text = "";
        lblCoverStatus.Text = "";

        // Reset authors table
        SetupSelectedAuthorsTable();
        BindAuthorsRepeater();

        // Reset copies panel
        pnlExistingCopies.Visible = false;

        // Reset button visibility
        litPageTitle.Text = "Catalogue";
        btnSave.Visible = true;
        btnUpdate.Visible = false;
        btnSaveAddCopy.Visible = true;

        // Hide alert
        pnlAlert.Visible = false;

        upAddEditBook.Update();
    }

    private void SaveBookData(bool addCopy)
    {
        string categoryName = txtCategory.Text.Trim();
        if (string.IsNullOrEmpty(categoryName))
        {
            ShowAlert("Please enter a Subject.", "alert-error");
            return;
        }
        short catID = GetOrCreateCategory(categoryName);


        // Collect authors and editor/compiler from textboxes and populate datatable
        DataTable authorsDt = new DataTable();
        authorsDt.Columns.Add("AuthorID", typeof(int));
        authorsDt.Columns.Add("AuthorName", typeof(string));
        authorsDt.Columns.Add("Role", typeof(string));

        // Author 1
        string fn1 = txtAuthor1FN.Text.Trim();
        string ln1 = txtAuthor1LN.Text.Trim();
        if (!string.IsNullOrEmpty(fn1) || !string.IsNullOrEmpty(ln1))
        {
            string fullName = string.IsNullOrEmpty(fn1) ? ln1 : (string.IsNullOrEmpty(ln1) ? fn1 : fn1 + " " + ln1);
            int authorID = GetOrCreateAuthor(fullName);
            authorsDt.Rows.Add(authorID, fullName, "Author");
        }

        // Author 2
        string fn2 = txtAuthor2FN.Text.Trim();
        string ln2 = txtAuthor2LN.Text.Trim();
        if (!string.IsNullOrEmpty(fn2) || !string.IsNullOrEmpty(ln2))
        {
            string fullName = string.IsNullOrEmpty(fn2) ? ln2 : (string.IsNullOrEmpty(ln2) ? fn2 : fn2 + " " + ln2);
            int authorID = GetOrCreateAuthor(fullName);
            authorsDt.Rows.Add(authorID, fullName, "Author");
        }

        // Author 3
        string fn3 = txtAuthor3FN.Text.Trim();
        string ln3 = txtAuthor3LN.Text.Trim();
        if (!string.IsNullOrEmpty(fn3) || !string.IsNullOrEmpty(ln3))
        {
            string fullName = string.IsNullOrEmpty(fn3) ? ln3 : (string.IsNullOrEmpty(ln3) ? fn3 : fn3 + " " + ln3);
            int authorID = GetOrCreateAuthor(fullName);
            authorsDt.Rows.Add(authorID, fullName, "Author");
        }

        // Editor / Compiler
        string editorName = txtEditorCompiler.Text.Trim();
        if (!string.IsNullOrEmpty(editorName))
        {
            int authorID = GetOrCreateAuthor(editorName);
            authorsDt.Rows.Add(authorID, editorName, "Editor");
        }

        ViewState["SelectedAuthors"] = authorsDt;

        // Multi-author check (must have at least one author/editor)
        if (authorsDt.Rows.Count == 0)
        {
            ShowAlert("Please enter at least one Author or Editor for this book.", "alert-error");
            return;
        }

        int? bookID = null;
        if (!string.IsNullOrEmpty(hfBookID.Value) && hfBookID.Value != "0")
        {
            bookID = Convert.ToInt32(hfBookID.Value);
        }

        string isbn13 = txtISBN13.Text.Trim();
        if (string.IsNullOrEmpty(isbn13))
        {
            isbn13 = null;
        }
        else
        {
            // Only strip hyphens if it is numeric or matches ISBN-10 pattern
            string cleanISBN = isbn13.Replace("-", "").Replace(" ", "");
            if (System.Text.RegularExpressions.Regex.IsMatch(cleanISBN, @"^\d+$") || (cleanISBN.Length == 10 && System.Text.RegularExpressions.Regex.IsMatch(cleanISBN, @"^\d{9}[\dXx]$")))
            {
                isbn13 = cleanISBN;
            }
        }

        string isbn10 = !string.IsNullOrEmpty(txtISBN10.Text) ? txtISBN10.Text.Replace("-", "").Replace(" ", "") : null;
        string title = txtTitle.Text.Trim();
        string subTitle = !string.IsNullOrEmpty(txtSubTitle.Text) ? txtSubTitle.Text.Trim() : null;
        
        short? pubID = null;
        if (!string.IsNullOrEmpty(txtPublisher.Text))
        {
            pubID = GetOrCreatePublisher(txtPublisher.Text.Trim());
        }

        string languageName = txtLanguage.Text.Trim();
        if (string.IsNullOrEmpty(languageName))
        {
            ShowAlert("Please enter a Language.", "alert-error");
            return;
        }
        byte langID = GetOrCreateLanguage(languageName);
        
        short? pubYear = null;
        short yr;
        if (short.TryParse(txtPubYear.Text, out yr)) pubYear = yr;
        
        string edition = !string.IsNullOrEmpty(txtEdition.Text) ? txtEdition.Text.Trim() : null;
        
        short? pageCount = null;
        short pc;
        if (short.TryParse(txtPageCount.Text, out pc)) pageCount = pc;

        string classNo = !string.IsNullOrEmpty(txtClassNo.Text) ? txtClassNo.Text.Trim() : null;
        string tags = !string.IsNullOrEmpty(txtTags.Text) ? txtTags.Text.Trim() : null;
        string description = !string.IsNullOrEmpty(txtDescription.Text) ? txtDescription.Text.Trim() : null;
        
        // Use uploaded image file name (optional)
        string coverFile = !string.IsNullOrEmpty(hfCoverPath.Value) ? hfCoverPath.Value : null;

        string ddc = !string.IsNullOrEmpty(txtDDC.Text) ? txtDDC.Text.Trim() : null;
        string baseDdcForSync = null;
        int startNumForSync = 1;

        if (!string.IsNullOrEmpty(ddc))
        {
            string s1 = txtDdcSuffix1.Text.Trim();
            string s2 = txtDdcSuffix2.Text.Trim();
            
            // Format DDC as: ddc-s1-s2 (using hyphens)
            string baseDdc = ddc;
            if (!string.IsNullOrEmpty(s1)) baseDdc += "-" + s1;
            
            int startNum = 1;
            int.TryParse(s2, out startNum);
            if (startNum <= 0) startNum = 1;

            baseDdcForSync = baseDdc;
            startNumForSync = startNum;
            
            int count = 1;
            int.TryParse(txtCopyCount.Text, out count);
            if (count <= 0) count = 1;
            
            if (addCopy)
            {
                int endNum = startNum + count - 1;
                if (endNum > startNum)
                {
                    ddc = baseDdc + "-" + startNum + " to " + baseDdc + "-" + endNum;
                }
                else
                {
                    ddc = baseDdc + "-" + startNum;
                }
            }
            else
            {
                // If it's an update, let's see if there are already copies in the database
                if (bookID.HasValue)
                {
                    DataTable dtCopies = DBHelper.GetTableData("SELECT Barcode FROM BookCopies WHERE BookID = " + bookID.Value);
                    if (dtCopies.Rows.Count > 0)
                    {
                        // Find min and max numbers matching baseDdc
                        int minNum = int.MaxValue;
                        int maxNum = int.MinValue;
                        var regex = new System.Text.RegularExpressions.Regex(System.Text.RegularExpressions.Regex.Escape(s1) + @"[^\d]+(\d+)");
                        
                        foreach (DataRow row in dtCopies.Rows)
                        {
                            string barcode = row["Barcode"] != DBNull.Value ? row["Barcode"].ToString() : "";
                            var match = regex.Match(barcode);
                            if (match.Success)
                            {
                                int val;
                                if (int.TryParse(match.Groups[1].Value, out val))
                                {
                                    if (val < minNum) minNum = val;
                                    if (val > maxNum) maxNum = val;
                                }
                            }
                        }
                        
                        if (maxNum >= minNum)
                        {
                            if (maxNum > minNum)
                            {
                                ddc = baseDdc + "-" + minNum + " to " + baseDdc + "-" + maxNum;
                            }
                            else
                            {
                                ddc = baseDdc + "-" + minNum;
                            }
                        }
                        else
                        {
                            ddc = baseDdc + "-" + startNum;
                        }
                    }
                    else
                    {
                        ddc = baseDdc + "-" + startNum;
                    }
                }
                else
                {
                    ddc = baseDdc + "-" + startNum;
                }
            }
        }

        bool isReference = cbReference.Checked;
        bool notToBeIssued = cbNotIssued.Checked;
        bool printBookDetail = cbPrintDetails.Checked;
        bool isAdults = cbAdults.Checked;
        bool isChildren = cbChildren.Checked;

        if (ddlCopyCondition.SelectedItem != null && !string.IsNullOrEmpty(ddlCopyCondition.SelectedValue))
        {
            txtCopyCondition.Text = ddlCopyCondition.SelectedItem.Text;
        }

        string acqNo = !string.IsNullOrEmpty(txtAcqNo.Text) ? txtAcqNo.Text.Trim() : null;
        string publishingPlace = !string.IsNullOrEmpty(txtPublishingPlace.Text) ? txtPublishingPlace.Text.Trim() : null;
        string liDate = !string.IsNullOrEmpty(txtLiDate.Text) ? txtLiDate.Text.Trim() : null;
        string volume = !string.IsNullOrEmpty(txtVolume.Text) ? txtVolume.Text.Trim() : null;
        string wwwLink = !string.IsNullOrEmpty(txtWwwLink.Text) ? txtWwwLink.Text.Trim() : null;
        string series = !string.IsNullOrEmpty(txtSeries.Text) ? txtSeries.Text.Trim() : null;
        string recBy = !string.IsNullOrEmpty(txtRecBy.Text) ? txtRecBy.Text.Trim() : null;
        string purchaseRef = !string.IsNullOrEmpty(txtPurchaseRef.Text) ? txtPurchaseRef.Text.Trim() : null;
        string purchaseDate = !string.IsNullOrEmpty(txtPurchaseDate.Text) ? txtPurchaseDate.Text.Trim() : null;
        string priceFcy = !string.IsNullOrEmpty(txtPriceFcy.Text) ? txtPriceFcy.Text.Trim() : null;
        string pricePkr = !string.IsNullOrEmpty(txtPricePkr.Text) ? txtPricePkr.Text.Trim() : null;
        string format = !string.IsNullOrEmpty(txtFormat.Text) ? txtFormat.Text.Trim() : null;
        string source = !string.IsNullOrEmpty(txtSource.Text) ? txtSource.Text.Trim() : null;
        string status = !string.IsNullOrEmpty(txtStatus.Text) ? txtStatus.Text.Trim() : null;
        string classSeq = !string.IsNullOrEmpty(txtClassSeq.Text) ? txtClassSeq.Text.Trim() : null;
        string location = !string.IsNullOrEmpty(txtLocation.Text) ? txtLocation.Text.Trim() : null;

        string donatedBy = !string.IsNullOrEmpty(txtDonatedBy.Text) ? txtDonatedBy.Text.Trim() : null;
        string msNo = !string.IsNullOrEmpty(txtMSNo.Text) ? txtMSNo.Text.Trim() : null;
        string donatedByName = !string.IsNullOrEmpty(txtDonatedByName.Text) ? txtDonatedByName.Text.Trim() : null;

        // Perform Save Book Catalog with error handling
        SaveBookResult result;
        try
        {
            result = DBHelper.SaveBook(bookID, isbn13, isbn10, title, subTitle, catID, pubID, langID, pubYear, edition, pageCount, classNo, tags, description, coverFile, CurrentStaffID, ddc, isReference, notToBeIssued, printBookDetail, acqNo, publishingPlace, liDate, volume, wwwLink, series, recBy, purchaseRef, purchaseDate, priceFcy, pricePkr, format, source, status, classSeq, location, isAdults, isChildren, donatedBy, msNo, donatedByName);
        }
        catch (Exception ex)
        {
            ShowAlert("<strong>Database Operation Failed:</strong> " + ex.Message, "alert-error");
            return;
        }

        if (result.NewBookID <= 0)
        {
            if (!string.IsNullOrEmpty(result.Result) && result.Result.Contains("ERR:ISBN_EXISTS"))
            {
                ShowAlert("ISBN number already exists in database. Duplicate entries are not allowed.", "alert-error");
            }
            else
            {
                ShowAlert(result.Result, "alert-error");
            }
            return;
        }

        int actualBookID = result.NewBookID;

        // Align existing copy barcodes to the defined DDC pattern
        if (!string.IsNullOrEmpty(baseDdcForSync))
        {
            SyncBookCopiesBarcode(actualBookID, baseDdcForSync, startNumForSync);
            UpdateBookDdcRange(actualBookID);
        }

        // Link authors
        LinkAuthorsToBook(actualBookID);

        // Update existing copies condition and cost if updating book
        if (bookID.HasValue && bookID.Value > 0)
        {
            UpdateBookCopiesConditionAndCost(actualBookID);
        }

        // Synchronize physical copies table according to No of copies (txtCopyCount)
        int targetCopyCount = 1;
        if (!int.TryParse(txtCopyCount.Text.Trim(), out targetCopyCount) || targetCopyCount < 1)
        {
            targetCopyCount = 1;
        }

        try
        {
            SyncBookCopyCount(actualBookID, targetCopyCount);
        }
        catch (Exception ex)
        {
            ShowAlert("<strong>Book catalog saved, but copy synchronization failed:</strong> " + ex.Message, "alert-error");
            return;
        }

        // Success alert & form state management
        if (bookID.HasValue && bookID.Value > 0)
        {
            LoadBookDetails(actualBookID);
            ShowAlert("Book catalog updated successfully! <button type='button' class='v-btn' style='margin-left: 15px; display: inline-flex; width: auto; height: 30px; padding: 0 10px; font-size: 11px; align-items: center; background: #0f1e36; color: #fff; border: none; border-radius: 4px; cursor: pointer;' onclick='printBookCopies(" + actualBookID + ")'>Print QR Codes</button>", "alert-success");
        }
        else
        {
            ClearForm();
            ShowAlert("Book catalog saved successfully! <button type='button' class='v-btn' style='margin-left: 15px; display: inline-flex; width: auto; height: 30px; padding: 0 10px; font-size: 11px; align-items: center; background: #0f1e36; color: #fff; border: none; border-radius: 4px; cursor: pointer;' onclick='printBookCopies(" + actualBookID + ")'>Print QR Codes</button>", "alert-success");
        }
    }

    private void SyncBookCopyCount(int bookID, int targetCount)
    {
        if (targetCount < 1) targetCount = 1;

        DataTable dtCopies = DBHelper.GetTableData("SELECT CopyID, IsAvailable FROM BookCopies WHERE BookID = " + bookID + " ORDER BY CopyID ASC");
        int currentCount = dtCopies != null ? dtCopies.Rows.Count : 0;

        if (targetCount > currentCount)
        {
            int copiesToAdd = targetCount - currentCount;
            AddCopiesForBook(bookID, copiesToAdd);
        }
        else if (targetCount < currentCount)
        {
            int copiesToRemove = currentCount - targetCount;

            // Select unissued (IsAvailable = 1) copies starting from highest CopyID
            DataTable dtToDelete = DBHelper.GetTableData("SELECT TOP (" + copiesToRemove + ") CopyID FROM BookCopies WHERE BookID = " + bookID + " AND IsAvailable = 1 ORDER BY CopyID DESC");

            if (dtToDelete != null && dtToDelete.Rows.Count > 0)
            {
                List<string> ids = new List<string>();
                foreach (DataRow r in dtToDelete.Rows)
                {
                    ids.Add(r["CopyID"].ToString());
                }
                string idList = string.Join(",", ids);
                DBHelper.GetTableData("DELETE FROM BookCopies WHERE CopyID IN (" + idList + ")");
            }

            UpdateBookDdcRange(bookID);
        }
    }

    private void LinkAuthorsToBook(int bookID)
    {
        // First delete existing author mappings for this book to recreate cleanly
        DBHelper.GetTableData("DELETE FROM BookAuthors WHERE BookID = " + bookID);

        DataTable dt = ViewState["SelectedAuthors"] as DataTable;
        if (dt != null)
        {
            int order = 1;
            foreach (DataRow row in dt.Rows)
            {
                int authorID = Convert.ToInt32(row["AuthorID"]);
                string role = row["Role"].ToString();

                // Convert role text to database tinyint role ID
                byte roleID = 1; // Author
                if (role == "Co-Author") roleID = 2;
                else if (role == "Editor") roleID = 3;
                else if (role == "Translator") roleID = 4;
                else if (role == "Illustrator") roleID = 5;

                DBHelper.GetTableData("INSERT INTO BookAuthors (BookID, AuthorID, RoleID, SortOrder) VALUES (" + bookID + ", " + authorID + ", " + roleID + ", " + order + ")");
                
                order++;
            }
        }
    }

    private void AddCopiesForBook(int bookID, int copyCount)
    {
        if (copyCount <= 0) return;

        // Condition
        string conditionText = txtCopyCondition.Text.Trim();
        byte condID = 1; // default New
        if (conditionText.Equals("N", StringComparison.OrdinalIgnoreCase) || conditionText.StartsWith("New", StringComparison.OrdinalIgnoreCase))
        {
            condID = 1;
        }
        else if (conditionText.Equals("O", StringComparison.OrdinalIgnoreCase) || conditionText.StartsWith("Old", StringComparison.OrdinalIgnoreCase))
        {
            condID = 2;
        }
        else if (conditionText.Equals("S", StringComparison.OrdinalIgnoreCase) || conditionText.StartsWith("SecondHand", StringComparison.OrdinalIgnoreCase) || conditionText.StartsWith("Second Hand", StringComparison.OrdinalIgnoreCase))
        {
            condID = 3;
        }

        decimal? cost = null;
        decimal val;
        if (decimal.TryParse(txtCopyCost.Text, out val)) cost = val;

        string notes = !string.IsNullOrEmpty(txtCopyNotes.Text) ? txtCopyNotes.Text.Trim() : null;

        // Location text entered in the Location field
        string locationText = !string.IsNullOrEmpty(txtLocation.Text) ? txtLocation.Text.Trim() : null;

        // Shelf location
        short? rackID = null;
        byte? slotNo = null;

        // Check if user selected a visual slot
        // During Auto-Postback, the selected slot hidden field is populated
        if (!string.IsNullOrEmpty(Request.Form[hfSelectedRack.UniqueID]) && !string.IsNullOrEmpty(Request.Form[hfSelectedSlot.UniqueID]))
        {
            rackID = Convert.ToInt16(Request.Form[hfSelectedRack.UniqueID]);
            slotNo = Convert.ToByte(Request.Form[hfSelectedSlot.UniqueID]);
        }
        else if (!string.IsNullOrEmpty(hfSelectedRack.Value) && !string.IsNullOrEmpty(hfSelectedSlot.Value))
        {
            rackID = Convert.ToInt16(hfSelectedRack.Value);
            slotNo = Convert.ToByte(hfSelectedSlot.Value);
        }

        // If slot is not assigned yet and location text contains slot info, try to extract slot number
        if (!slotNo.HasValue && !string.IsNullOrEmpty(locationText))
        {
            var match = System.Text.RegularExpressions.Regex.Match(locationText, @"(?:slot|s)[\s:#\-]*(\d+)", System.Text.RegularExpressions.RegexOptions.IgnoreCase);
            if (match.Success)
            {
                byte parsedSlot;
                if (byte.TryParse(match.Groups[1].Value, out parsedSlot) && parsedSlot > 0 && parsedSlot <= 100)
                {
                    slotNo = parsedSlot;
                }
            }
        }

        int? startBookNo = null;
        int parsedBookNo;
        if (int.TryParse(txtBookNo.Text.Trim(), out parsedBookNo) && parsedBookNo > 0)
        {
            startBookNo = parsedBookNo;
        }

        // Loop to add multiple copies
        for (int i = 0; i < copyCount; i++)
        {
            // First copy takes the selected slot, subsequent copies in the loop auto-assign free slots to prevent slot-collisions
            short? rID = rackID;
            byte? sNo = (i == 0) ? slotNo : null;
            int? currentBookNo = startBookNo.HasValue ? (int?)(startBookNo.Value + i) : null;

            var copyResult = DBHelper.AddBookCopy(bookID, rID, sNo, condID, cost, notes, currentBookNo, locationText);
            if (copyResult.Result.StartsWith("ERR:"))
            {
                throw new Exception(copyResult.Result);
            }
        }

        // Auto-update parent book DDC range based on actual copies
        UpdateBookDdcRange(bookID);
    }

    private static void UpdateBookDdcRange(int bookID)
    {
        DataTable dtBook = DBHelper.GetTableData(@"
            SELECT b.DDC, c.CatCode, 
                   (SELECT TOP 1 a.FullName FROM BookAuthors ba JOIN Authors a ON ba.AuthorID = a.AuthorID WHERE ba.BookID = b.BookID ORDER BY ba.SortOrder) AS AuthorName
            FROM Books b
            JOIN Categories c ON b.CatID = c.CatID
            WHERE b.BookID = " + bookID);
        
        if (dtBook.Rows.Count == 0) return;
        
        string currentDdc = dtBook.Rows[0]["DDC"] != DBNull.Value ? dtBook.Rows[0]["DDC"].ToString().Trim() : "";
        if (string.IsNullOrEmpty(currentDdc)) return;
        
        string firstPart = currentDdc;
        if (currentDdc.Contains(" to "))
        {
            firstPart = currentDdc.Split(new[] { " to " }, StringSplitOptions.RemoveEmptyEntries)[0].Trim();
        }
        
        var match = System.Text.RegularExpressions.Regex.Match(firstPart, @"^(.*)[- ]+\d+$");
        string baseDdc = match.Success ? match.Groups[1].Value.Trim() : firstPart;
        
        var parts = baseDdc.Split(new[] { '-', ' ' }, StringSplitOptions.RemoveEmptyEntries);
        string authorSuffix = parts.Length > 0 ? parts[parts.Length - 1] : "";
        
        DataTable dtCopies = DBHelper.GetTableData("SELECT Barcode FROM BookCopies WHERE BookID = " + bookID);
        if (dtCopies.Rows.Count == 0) return;
        
        int minNum = int.MaxValue;
        int maxNum = int.MinValue;
        var regex = new System.Text.RegularExpressions.Regex(System.Text.RegularExpressions.Regex.Escape(authorSuffix) + @"[^\d]+(\d+)");
        
        foreach (DataRow row in dtCopies.Rows)
        {
            string barcode = row["Barcode"] != DBNull.Value ? row["Barcode"].ToString().Trim() : "";
            var m = regex.Match(barcode);
            if (m.Success)
            {
                int val;
                if (int.TryParse(m.Groups[1].Value, out val))
                {
                    if (val < minNum) minNum = val;
                    if (val > maxNum) maxNum = val;
                }
            }
        }
        
        if (maxNum >= minNum)
        {
            string newDdc = "";
            if (maxNum > minNum)
            {
                newDdc = baseDdc + "-" + minNum + " to " + baseDdc + "-" + maxNum;
            }
            else
            {
                newDdc = baseDdc + "-" + minNum;
            }
            
            using (var con = DBHelper.GetConnection())
            using (var cmd = new SqlCommand("UPDATE Books SET DDC = @DDC WHERE BookID = @BookID", con))
            {
                cmd.Parameters.AddWithValue("@DDC", newDdc);
                cmd.Parameters.AddWithValue("@BookID", bookID);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }

    private void UpdateBookCopiesConditionAndCost(int bookID)
    {
        string conditionText = txtCopyCondition.Text.Trim();
        if (ddlCopyCondition.SelectedItem != null && !string.IsNullOrEmpty(ddlCopyCondition.SelectedValue))
        {
            conditionText = ddlCopyCondition.SelectedValue;
        }

        byte condID = 1; // default New
        if (conditionText.Equals("N", StringComparison.OrdinalIgnoreCase) || conditionText.StartsWith("New", StringComparison.OrdinalIgnoreCase))
        {
            condID = 1;
        }
        else if (conditionText.Equals("O", StringComparison.OrdinalIgnoreCase) || conditionText.StartsWith("Old", StringComparison.OrdinalIgnoreCase))
        {
            condID = 2;
        }
        else if (conditionText.Equals("S", StringComparison.OrdinalIgnoreCase) || conditionText.StartsWith("SH", StringComparison.OrdinalIgnoreCase) || conditionText.StartsWith("Second", StringComparison.OrdinalIgnoreCase))
        {
            condID = 3;
        }

        decimal? cost = null;
        decimal val;
        if (decimal.TryParse(txtCopyCost.Text, out val)) cost = val;

        using (var con = DBHelper.GetConnection())
        {
            string query = "UPDATE BookCopies SET CondID = @CondID, AcqCost = @AcqCost WHERE BookID = @BookID";
            using (var cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@CondID", condID);
                cmd.Parameters.AddWithValue("@AcqCost", (object)cost ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@BookID", bookID);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }

    private static void SyncBookCopiesBarcode(int bookID, string baseDdc, int startNum)
    {
        DataTable dtCopies = DBHelper.GetTableData("SELECT CopyID FROM BookCopies WHERE BookID = " + bookID + " ORDER BY CopyID ASC");
        if (dtCopies.Rows.Count == 0) return;

        using (var con = DBHelper.GetConnection())
        {
            con.Open();
            for (int i = 0; i < dtCopies.Rows.Count; i++)
            {
                int copyID = Convert.ToInt32(dtCopies.Rows[i]["CopyID"]);
                string newBarcode = baseDdc + "-" + (startNum + i);
                
                using (var cmd = new SqlCommand("UPDATE BookCopies SET Barcode = @Barcode WHERE CopyID = @CopyID", con))
                {
                    cmd.Parameters.AddWithValue("@Barcode", newBarcode);
                    cmd.Parameters.AddWithValue("@CopyID", copyID);
                    cmd.ExecuteNonQuery();
                }
            }
        }
    }

    // Grid commands for existing copies (e.g. edit condition)
    protected void rptCopies_Command(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "EditCopy")
        {
            int copyID = Convert.ToInt32(e.CommandArgument);
            ShowAlert("Action needed: Copy editing (ID: " + copyID + ") can be managed at the Circulation Desk.", "alert-info");
        }
    }

    [System.Web.Services.WebMethod]
    public static object GetBookCopiesForPrinting(int bookID)
    {
        try
        {
            DataSet ds = DBHelper.GetBookDetail(bookID);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
            {
                return null;
            }

            DataRow bookRow = ds.Tables[0].Rows[0];

            List<string> authorsList = new List<string>();
            if (ds.Tables.Count > 1 && ds.Tables[1] != null)
            {
                foreach (DataRow authorRow in ds.Tables[1].Rows)
                {
                    if (authorRow["FullName"] != DBNull.Value)
                        authorsList.Add(authorRow["FullName"].ToString());
                }
            }
            string authors = authorsList.Count > 0 ? string.Join(", ", authorsList) : "Unknown";

            List<object> copies = new List<object>();
            if (ds.Tables.Count > 2 && ds.Tables[2] != null)
            {
                foreach (DataRow copyRow in ds.Tables[2].Rows)
                {
                    string copyBookNo = copyRow.Table.Columns.Contains("BookNo") && copyRow["BookNo"] != DBNull.Value ? copyRow["BookNo"].ToString() : "";
                    string barcode = copyRow.Table.Columns.Contains("Barcode") && copyRow["Barcode"] != DBNull.Value ? copyRow["Barcode"].ToString() : "";
                    string condition = "New";
                    if (copyRow.Table.Columns.Contains("CondName") && copyRow["CondName"] != DBNull.Value)
                        condition = copyRow["CondName"].ToString();
                    else if (copyRow.Table.Columns.Contains("Condition") && copyRow["Condition"] != DBNull.Value)
                        condition = copyRow["Condition"].ToString();

                    copies.Add(new {
                        BookNo = copyBookNo,
                        Barcode = barcode,
                        Condition = condition
                    });
                }
            }

            string bookNoStr = bookRow.Table.Columns.Contains("BookNo") && bookRow["BookNo"] != DBNull.Value ? bookRow["BookNo"].ToString() : (bookRow["AcqNo"] != DBNull.Value ? bookRow["AcqNo"].ToString() : bookRow["BookID"].ToString());

            return new {
                Title = bookRow["Title"] != DBNull.Value ? bookRow["Title"].ToString() : "",
                Authors = authors,
                PrintBookDetail = bookRow["PrintBookDetail"] != DBNull.Value ? Convert.ToBoolean(bookRow["PrintBookDetail"]) : false,
                IsAdults = bookRow["IsAdults"] != DBNull.Value ? Convert.ToBoolean(bookRow["IsAdults"]) : false,
                IsChildren = bookRow["IsChildren"] != DBNull.Value ? Convert.ToBoolean(bookRow["IsChildren"]) : false,
                BookNo = bookNoStr,
                AcqNo = bookRow["AcqNo"] != DBNull.Value ? bookRow["AcqNo"].ToString() : "",
                PurchaseDate = bookRow["PurchaseDate"] != DBNull.Value ? bookRow["PurchaseDate"].ToString() : "",
                Copies = copies
            };
        }
        catch
        {
            return null;
        }
    }

    [System.Web.Services.WebMethod]
    public static string UpdateBookCopyDetails(int copyID, string condition, string location, string status)
    {
        try
        {
            byte condID = 1; // 1 = New
            if (!string.IsNullOrEmpty(condition))
            {
                string c = condition.Trim();
                if (c.Equals("Old", StringComparison.OrdinalIgnoreCase) || c.Equals("Good", StringComparison.OrdinalIgnoreCase) || c.Equals("O", StringComparison.OrdinalIgnoreCase))
                    condID = 2; // Old
                else if (c.Equals("SecondHand", StringComparison.OrdinalIgnoreCase) || c.Equals("Second Hand", StringComparison.OrdinalIgnoreCase) || c.Equals("SH", StringComparison.OrdinalIgnoreCase) || c.Equals("Fair", StringComparison.OrdinalIgnoreCase) || c.Equals("Poor", StringComparison.OrdinalIgnoreCase) || c.Equals("S", StringComparison.OrdinalIgnoreCase))
                    condID = 3; // SecondHand
            }

            using (var con = DBHelper.GetConnection())
            {
                string query = "UPDATE BookCopies SET CondID = @CondID, Location = @Location WHERE CopyID = @CopyID";
                using (var cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@CondID", condID);
                    cmd.Parameters.AddWithValue("@Location", (object)location ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@CopyID", copyID);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            return "OK";
        }
        catch (Exception ex)
        {
            return "ERR:" + ex.Message;
        }
    }

    // --------------------------------------------------------------
    //  Alert display helper
    // --------------------------------------------------------------
    private void ShowAlert(string msg, string typeClass)
    {
        pnlAlert.Visible = true;
        
        // Clean and decode error messages if they are system codes
        string cleanMsg = msg;
        if (msg.StartsWith("ERR:ISBN13_INVALID:"))
        {
            cleanMsg = "<strong>Invalid ISBN-13 Check Digit!</strong> The ISBN entered failed standard check digit validation. Please check the digits and try again.";
        }
        else if (msg.StartsWith("ERR:ISBN13_EXISTS:"))
        {
            cleanMsg = "<strong>ISBN already exists!</strong> A book with this ISBN-13 is already registered in the system catalogue.";
        }
        else if (msg.Contains("ERR:SLOT_TAKEN"))
        {
            cleanMsg = "<strong>Slot Location Taken!</strong> The selected shelf slot is already occupied. Please choose a different slot.";
        }
        else if (msg.Contains("ERR:RACK_FULL"))
        {
            cleanMsg = "<strong>Rack Location is Full!</strong> The selected rack has no more available slots. Please choose a different rack.";
        }
        
        divAlert.InnerHtml = cleanMsg;
        
        // Define premium inline styles matching Gymkhana Library aesthetic
        string styles = "padding: 12px 20px; border-radius: 8px; font-size: 14px; margin-bottom: 20px; width: 100%; box-sizing: border-box; font-family: 'Outfit', sans-serif; display: block; ";
        if (typeClass.Contains("error"))
        {
            styles += "border-left: 4px solid #ef4444; background-color: #fee2e2; color: #991b1b; border-top: 1px solid #fca5a5; border-right: 1px solid #fca5a5; border-bottom: 1px solid #fca5a5;";
        }
        else if (typeClass.Contains("info"))
        {
            styles += "border-left: 4px solid #3b82f6; background-color: #dbeafe; color: #1e3a8a; border-top: 1px solid #bfdbfe; border-right: 1px solid #bfdbfe; border-bottom: 1px solid #bfdbfe;";
        }
        else if (typeClass.Contains("success"))
        {
            styles += "border-left: 4px solid #10b981; background-color: #d1fae5; color: #065f46; border-top: 1px solid #a7f3d0; border-right: 1px solid #a7f3d0; border-bottom: 1px solid #a7f3d0;";
        }
        else
        {
            styles += "border: 1px solid #cbd5e1; background-color: #f1f5f9; color: #1e293b;";
        }
        
        divAlert.Attributes["style"] = styles;
    }

    // --------------------------------------------------------------
    //  DDC & Autocomplete Helper Methods & WebMethods
    // --------------------------------------------------------------
    private short GetOrCreatePublisher(string pubName)
    {
        string query = "SELECT PubID FROM Publishers WHERE PubName = @PubName";
        using (var con = DBHelper.GetConnection())
        using (var cmd = new SqlCommand(query, con))
        {
            cmd.Parameters.AddWithValue("@PubName", pubName);
            con.Open();
            object result = cmd.ExecuteScalar();
            if (result != null && result != DBNull.Value)
            {
                return Convert.ToInt16(result);
            }
        }
        
        string insertQuery = "INSERT INTO Publishers (PubName, IsActive) VALUES (@PubName, 1); SELECT SCOPE_IDENTITY();";
        using (var con = DBHelper.GetConnection())
        using (var cmd = new SqlCommand(insertQuery, con))
        {
            cmd.Parameters.AddWithValue("@PubName", pubName);
            con.Open();
            return Convert.ToInt16(cmd.ExecuteScalar());
        }
    }

    private int GetOrCreateAuthor(string name)
    {
        string cleanName = name.Trim();
        string firstName = "";
        string lastName = "";
        if (cleanName.Contains(","))
        {
            string[] parts = cleanName.Split(new char[] { ',' }, 2);
            lastName = parts[0].Trim();
            firstName = parts[1].Trim();
        }
        else
        {
            int lastSpaceIndex = cleanName.LastIndexOf(' ');
            if (lastSpaceIndex >= 0)
            {
                firstName = cleanName.Substring(0, lastSpaceIndex).Trim();
                lastName = cleanName.Substring(lastSpaceIndex + 1).Trim();
            }
            else
            {
                firstName = "-";
                lastName = cleanName;
            }
        }

        string selectQuery = "SELECT AuthorID FROM Authors WHERE FirstName = @FirstName AND LastName = @LastName";
        using (var con = DBHelper.GetConnection())
        using (var cmd = new SqlCommand(selectQuery, con))
        {
            cmd.Parameters.AddWithValue("@FirstName", firstName);
            cmd.Parameters.AddWithValue("@LastName", lastName);
            con.Open();
            object result = cmd.ExecuteScalar();
            if (result != null && result != DBNull.Value)
            {
                return Convert.ToInt32(result);
            }
        }

        string selectQuery2 = "SELECT AuthorID FROM Authors WHERE FullName = @FullName";
        using (var con = DBHelper.GetConnection())
        using (var cmd = new SqlCommand(selectQuery2, con))
        {
            cmd.Parameters.AddWithValue("@FullName", cleanName);
            con.Open();
            object result = cmd.ExecuteScalar();
            if (result != null && result != DBNull.Value)
            {
                return Convert.ToInt32(result);
            }
        }

        string insertQuery = "INSERT INTO Authors (FirstName, LastName, IsActive) VALUES (@FirstName, @LastName, 1); SELECT SCOPE_IDENTITY();";
        using (var con = DBHelper.GetConnection())
        using (var cmd = new SqlCommand(insertQuery, con))
        {
            cmd.Parameters.AddWithValue("@FirstName", firstName);
            cmd.Parameters.AddWithValue("@LastName", lastName);
            con.Open();
            return Convert.ToInt32(cmd.ExecuteScalar());
        }
    }

    private string GetAuthorFullName(int authorID)
    {
        string query = "SELECT FullName FROM Authors WHERE AuthorID = " + authorID;
        DataTable dt = DBHelper.GetTableData(query);
        if (dt.Rows.Count > 0)
        {
            return dt.Rows[0]["FullName"].ToString();
        }
        return "Unknown Author";
    }

    private void AutoGenerateDDC()
    {
        // Auto-generation disabled as requested by the user
    }

    protected void txtPubYear_TextChanged(object sender, EventArgs e)
    {
        AutoGenerateDDC();
    }

    [System.Web.Services.WebMethod]
    public static string GetNextDdcSuffix2(string ddc, string suffix1)
    {
        if (string.IsNullOrEmpty(ddc) || string.IsNullOrEmpty(suffix1))
            return "";

        ddc = ddc.Trim();
        suffix1 = suffix1.Trim();

        string safeDdc = ddc.Replace("'", "''");
        string safeSuffix1 = suffix1.Replace("'", "''");

        // Query both Books.DDC and BookCopies.Barcode
        string sqlBooks = "SELECT DDC FROM Books WITH (NOLOCK) WHERE (DDC LIKE '%" + safeDdc + "%' AND DDC LIKE '%" + safeSuffix1 + "%') AND IsActive = 1";
        string sqlCopies = "SELECT Barcode FROM BookCopies WITH (NOLOCK) WHERE Barcode LIKE '%" + safeDdc + "%' AND Barcode LIKE '%" + safeSuffix1 + "%'";

        DataTable dtBooks = DBHelper.GetTableData(sqlBooks);
        DataTable dtCopies = DBHelper.GetTableData(sqlCopies);

        int maxNumber = 0;
        bool hasExactMatch = false;

        string escapedDdc = System.Text.RegularExpressions.Regex.Escape(ddc);
        string escapedSuffix1 = System.Text.RegularExpressions.Regex.Escape(suffix1);

        // Exact matching regex:
        // Pattern matches [ddc] exactly (not preceded or followed by digits)
        // followed by [suffix1] exactly (not followed by letters)
        // followed by separator and copy sequence digits
        string pattern = @"(?<!\d)" + escapedDdc + @"(?!\d)[- ]+" + escapedSuffix1 + @"(?![a-zA-Z])[- ]+(\d+)";
        var regex = new System.Text.RegularExpressions.Regex(pattern, System.Text.RegularExpressions.RegexOptions.IgnoreCase);

        foreach (DataRow row in dtBooks.Rows)
        {
            string dbVal = row["DDC"] != DBNull.Value ? row["DDC"].ToString() : "";
            var matches = regex.Matches(dbVal);
            if (matches.Count > 0)
            {
                hasExactMatch = true;
            }
            foreach (System.Text.RegularExpressions.Match m in matches)
            {
                int val;
                if (int.TryParse(m.Groups[1].Value, out val))
                {
                    if (val > maxNumber) maxNumber = val;
                }
            }
        }

        foreach (DataRow row in dtCopies.Rows)
        {
            string dbVal = row["Barcode"] != DBNull.Value ? row["Barcode"].ToString() : "";
            var matches = regex.Matches(dbVal);
            if (matches.Count > 0)
            {
                hasExactMatch = true;
            }
            foreach (System.Text.RegularExpressions.Match m in matches)
            {
                int val;
                if (int.TryParse(m.Groups[1].Value, out val))
                {
                    if (val > maxNumber) maxNumber = val;
                }
            }
        }

        if (hasExactMatch)
        {
            return (maxNumber + 1).ToString();
        }
        else
        {
            return "";
        }
    }

    [System.Web.Services.WebMethod]
    public static object GetPublisherSuggestions(string query)
    {
        string safeTerm = (query ?? "").Replace("'", "''");
        string sql = "SELECT TOP 10 PubName FROM Publishers WITH (NOLOCK) WHERE IsActive = 1 AND PubName LIKE '%" + safeTerm + "%' ORDER BY PubName";
        DataTable dt = DBHelper.GetTableData(sql);
        var list = new System.Collections.Generic.List<string>();
        foreach (DataRow row in dt.Rows)
        {
            list.Add(row["PubName"].ToString());
        }
        return list;
    }

    [System.Web.Services.WebMethod]
    public static object GetAuthorSuggestions(string query)
    {
        string safeTerm = (query ?? "").Replace("'", "''");
        string sql = "SELECT TOP 10 FullName FROM Authors WITH (NOLOCK) WHERE IsActive = 1 AND FullName LIKE '%" + safeTerm + "%' ORDER BY FullName";
        DataTable dt = DBHelper.GetTableData(sql);
        var list = new System.Collections.Generic.List<string>();
        foreach (DataRow row in dt.Rows)
        {
            list.Add(row["FullName"].ToString());
        }
        return list;
    }

    [System.Web.Services.WebMethod]
    public static object GetCategorySuggestions(string query)
    {
        string safeTerm = (query ?? "").Replace("'", "''");
        string sql = "SELECT TOP 10 CatName FROM Categories WITH (NOLOCK) WHERE IsActive = 1 AND CatName LIKE '%" + safeTerm + "%' ORDER BY CatName";
        DataTable dt = DBHelper.GetTableData(sql);
        var list = new System.Collections.Generic.List<string>();
        foreach (DataRow row in dt.Rows)
        {
            list.Add(row["CatName"].ToString());
        }
        return list;
    }

    [System.Web.Services.WebMethod]
    public static object GetLanguageSuggestions(string query)
    {
        string safeTerm = (query ?? "").Replace("'", "''");
        string sql = "SELECT TOP 10 LangName FROM Languages WITH (NOLOCK) WHERE IsActive = 1 AND LangName LIKE '%" + safeTerm + "%' ORDER BY LangName";
        DataTable dt = DBHelper.GetTableData(sql);
        var list = new System.Collections.Generic.List<string>();
        foreach (DataRow row in dt.Rows)
        {
            list.Add(row["LangName"].ToString());
        }
        return list;
    }

    private static string GenerateCategoryCode(string catName)
    {
        if (string.IsNullOrEmpty(catName)) return "CAT";
        
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        foreach (char c in catName)
        {
            if (char.IsLetterOrDigit(c))
            {
                sb.Append(c);
            }
        }
        string clean = sb.ToString().ToUpper();
        if (clean.Length == 0) clean = "CAT";
        
        string prefix = clean.Substring(0, Math.Min(3, clean.Length));
        if (prefix.Length < 3) prefix = prefix.PadRight(3, 'X');
        
        string cand = prefix;
        int count = 1;
        using (var con = DBHelper.GetConnection())
        {
            con.Open();
            while (true)
            {
                string sql = "SELECT COUNT(*) FROM Categories WITH (NOLOCK) WHERE CatCode = '" + cand.Replace("'", "''") + "'";
                using (var cmd = new SqlCommand(sql, con))
                {
                    int exists = Convert.ToInt32(cmd.ExecuteScalar());
                    if (exists == 0)
                    {
                        return cand;
                    }
                }
                
                string suffix = count.ToString();
                int maxPrefixLen = 8 - suffix.Length;
                cand = prefix.Substring(0, Math.Min(maxPrefixLen, prefix.Length)) + suffix;
                count++;
            }
        }
    }

    private static string GenerateLanguageCode(string langName)
    {
        if (string.IsNullOrEmpty(langName)) return "XX";
        
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        foreach (char c in langName)
        {
            if (char.IsLetter(c))
            {
                sb.Append(c);
            }
        }
        string clean = sb.ToString().ToLower();
        if (clean.Length == 0) clean = "xx";
        
        string prefix = clean.Substring(0, Math.Min(2, clean.Length));
        if (prefix.Length < 2) prefix = prefix.PadRight(2, 'x');
        
        string cand = prefix;
        int count = 1;
        using (var con = DBHelper.GetConnection())
        {
            con.Open();
            while (true)
            {
                string sql = "SELECT COUNT(*) FROM Languages WITH (NOLOCK) WHERE LangCode = '" + cand.Replace("'", "''") + "'";
                using (var cmd = new SqlCommand(sql, con))
                {
                    int exists = Convert.ToInt32(cmd.ExecuteScalar());
                    if (exists == 0)
                    {
                        return cand;
                    }
                }
                
                if (count <= 9)
                {
                    cand = prefix.Substring(0, 1) + count.ToString();
                }
                else
                {
                    char nextChar = (char)('a' + (count - 10) % 26);
                    cand = prefix.Substring(0, 1) + nextChar;
                }
                count++;
                if (count > 50) return "xx";
            }
        }
    }

    [System.Web.Services.WebMethod]
    public static string AddLanguageWeb(string name)
    {
        if (string.IsNullOrEmpty(name)) return "ERR:Name is empty";
        string trimmedName = name.Trim();
        
        using (var con = DBHelper.GetConnection())
        {
            con.Open();
            string checkSql = "SELECT LangName FROM Languages WITH (NOLOCK) WHERE LangName = @LangName";
            using (var cmd = new SqlCommand(checkSql, con))
            {
                cmd.Parameters.AddWithValue("@LangName", trimmedName);
                object dbVal = cmd.ExecuteScalar();
                if (dbVal != null && dbVal != DBNull.Value)
                {
                    return "EXISTS:" + dbVal.ToString();
                }
            }

            int nextLangID = 1;
            string idSql = "SELECT ISNULL(MAX(LangID), 0) + 1 FROM Languages";
            using (var cmd = new SqlCommand(idSql, con))
            {
                nextLangID = Convert.ToInt32(cmd.ExecuteScalar());
            }

            string uniqueCode = GenerateLanguageCode(trimmedName);

            string insertSql = "INSERT INTO Languages (LangID, LangCode, LangName, IsActive) VALUES (@LangID, @LangCode, @LangName, 1)";
            using (var cmd = new SqlCommand(insertSql, con))
            {
                cmd.Parameters.AddWithValue("@LangID", nextLangID);
                cmd.Parameters.AddWithValue("@LangCode", uniqueCode);
                cmd.Parameters.AddWithValue("@LangName", trimmedName);
                cmd.ExecuteNonQuery();
            }
        }
        return "OK:" + trimmedName;
    }

    [System.Web.Services.WebMethod]
    public static string AddCategoryWeb(string name)
    {
        if (string.IsNullOrEmpty(name)) return "ERR:Name is empty";
        string trimmedName = name.Trim();
        
        using (var con = DBHelper.GetConnection())
        {
            con.Open();
            string checkSql = "SELECT CatName FROM Categories WITH (NOLOCK) WHERE CatName = @CatName";
            using (var cmd = new SqlCommand(checkSql, con))
            {
                cmd.Parameters.AddWithValue("@CatName", trimmedName);
                object dbVal = cmd.ExecuteScalar();
                if (dbVal != null && dbVal != DBNull.Value)
                {
                    return "EXISTS:" + dbVal.ToString();
                }
            }

            string uniqueCode = GenerateCategoryCode(trimmedName);

            string insertSql = "INSERT INTO Categories (CatCode, CatName, IsActive) VALUES (@CatCode, @CatName, 1)";
            using (var cmd = new SqlCommand(insertSql, con))
            {
                cmd.Parameters.AddWithValue("@CatCode", uniqueCode);
                cmd.Parameters.AddWithValue("@CatName", trimmedName);
                cmd.ExecuteNonQuery();
            }
        }
        return "OK:" + trimmedName;
    }

    [System.Web.Services.WebMethod]
    public static object GetLanguagesList()
    {
        var list = new System.Collections.Generic.List<string>();
        string sql = "SELECT LangName FROM Languages WITH (NOLOCK) WHERE IsActive = 1 ORDER BY LangName";
        DataTable dt = DBHelper.GetTableData(sql);
        foreach (DataRow row in dt.Rows)
        {
            list.Add(row["LangName"].ToString());
        }
        return list;
    }

    [System.Web.Services.WebMethod]
    public static object GetCategoriesList()
    {
        var list = new System.Collections.Generic.List<string>();
        string sql = "SELECT CatName FROM Categories WITH (NOLOCK) WHERE IsActive = 1 ORDER BY CatName";
        DataTable dt = DBHelper.GetTableData(sql);
        foreach (DataRow row in dt.Rows)
        {
            list.Add(row["CatName"].ToString());
        }
        return list;
    }

    [System.Web.Services.WebMethod]
    public static object GetDistinctFormats()
    {
        var list = new System.Collections.Generic.List<string> { "Book", "Journal", "Magazine", "CD/DVD", "Manuscript" };
        string sql = "SELECT DISTINCT [Format] FROM Books WITH (NOLOCK) WHERE [Format] IS NOT NULL AND [Format] <> '' ORDER BY [Format]";
        DataTable dt = DBHelper.GetTableData(sql);
        foreach (DataRow row in dt.Rows)
        {
            string val = row["Format"].ToString().Trim();
            if (!list.Contains(val)) list.Add(val);
        }
        return list;
    }

    [System.Web.Services.WebMethod]
    public static object GetDistinctSources()
    {
        var list = new System.Collections.Generic.List<string> { "Donated", "Purchased", "Gift" };
        string sql = "SELECT DISTINCT Source FROM Books WITH (NOLOCK) WHERE Source IS NOT NULL AND Source <> '' ORDER BY Source";
        DataTable dt = DBHelper.GetTableData(sql);
        foreach (DataRow row in dt.Rows)
        {
            string val = row["Source"].ToString().Trim();
            if (!list.Contains(val)) list.Add(val);
        }
        return list;
    }

    [System.Web.Services.WebMethod]
    public static object GetDistinctEditions()
    {
        var list = new System.Collections.Generic.List<string> { "1st Edition", "2nd Edition", "3rd Edition", "4th Edition", "5th Edition" };
        string sql = "SELECT DISTINCT Edition FROM Books WITH (NOLOCK) WHERE Edition IS NOT NULL AND Edition <> '' ORDER BY Edition";
        DataTable dt = DBHelper.GetTableData(sql);
        foreach (DataRow row in dt.Rows)
        {
            string val = row["Edition"].ToString().Trim();
            if (!list.Contains(val)) list.Add(val);
        }
        return list;
    }

    [System.Web.Services.WebMethod]
    public static string GetMemberNameByNo(string memberNo)
    {
        if (string.IsNullOrEmpty(memberNo)) return "";
        string cleanNo = memberNo.Trim();
        string sql = @"
            SELECT TOP 1 
                MemberName, 
                COALESCE(Status, AccountStatus, CASE WHEN IsActive = '1' THEN 'Active' ELSE 'Inactive' END) AS MemberStatus 
            FROM MemberShip.dbo.MemberProfile WITH (NOLOCK) 
            WHERE MemberNo = @MemberNo";
        using (var con = DBHelper.GetConnection())
        using (var cmd = new SqlCommand(sql, con))
        {
            cmd.Parameters.AddWithValue("@MemberNo", cleanNo);
            con.Open();
            using (var reader = cmd.ExecuteReader())
            {
                if (reader.Read())
                {
                    string name = reader["MemberName"].ToString();
                    string status = reader["MemberStatus"].ToString();
                    return name + "|" + status;
                }
            }
        }
        return "";
    }

    [System.Web.Services.WebMethod]
    public static string GenerateISBNWeb(string authorName, string publisherName, string edition, string languageName)
    {
        string authorPrefix = "LGC";
        if (!string.IsNullOrEmpty(authorName))
        {
            string lastName = "";
            string cleanName = authorName.Trim();
            if (cleanName.Contains(","))
            {
                lastName = cleanName.Split(',')[0].Trim();
            }
            else
            {
                int lastSpace = cleanName.LastIndexOf(' ');
                if (lastSpace >= 0)
                {
                    lastName = cleanName.Substring(lastSpace + 1).Trim();
                }
                else
                {
                    lastName = cleanName;
                }
            }
            string letters = System.Text.RegularExpressions.Regex.Replace(lastName, "[^a-zA-Z]", "").ToUpper();
            authorPrefix = letters.Length >= 3 ? letters.Substring(0, 3) : (letters.Length > 0 ? letters.PadRight(3, 'X') : "UNK");
        }

        string pubPrefix = "GEN";
        if (!string.IsNullOrEmpty(publisherName))
        {
            string letters = System.Text.RegularExpressions.Regex.Replace(publisherName, "[^a-zA-Z]", "").ToUpper();
            pubPrefix = letters.Length >= 3 ? letters.Substring(0, 3) : (letters.Length > 0 ? letters.PadRight(3, 'X') : "GEN");
        }

        string editionPrefix = "1E";
        if (!string.IsNullOrEmpty(edition))
        {
            string clean = System.Text.RegularExpressions.Regex.Replace(edition, "[^a-zA-Z0-9]", "").ToUpper();
            if (!string.IsNullOrEmpty(clean))
            {
                editionPrefix = clean.Length > 4 ? clean.Substring(0, 4) : clean;
            }
        }

        string langCode = "EN";
        if (!string.IsNullOrEmpty(languageName))
        {
            using (var con = DBHelper.GetConnection())
            {
                string query = "SELECT LangCode FROM Languages WITH (NOLOCK) WHERE LangName = @LangName";
                using (var cmd = new SqlCommand(query, con) { CommandTimeout = 30 })
                {
                    cmd.Parameters.AddWithValue("@LangName", languageName.Trim());
                    con.Open();
                    object res = cmd.ExecuteScalar();
                    if (res != null && res != DBNull.Value)
                    {
                        langCode = res.ToString().Trim().ToUpper();
                    }
                    else
                    {
                        string clean = System.Text.RegularExpressions.Regex.Replace(languageName, "[^a-zA-Z]", "");
                        langCode = clean.Length >= 2 ? clean.Substring(0, 2).ToUpper() : "EN";
                    }
                }
            }
        }

        string basePrefix = authorPrefix + "-" + pubPrefix + "-" + editionPrefix + "-" + langCode + "-";
        string suffix = DBHelper.GetNextISBNSuffix(basePrefix);
        return basePrefix + suffix;
    }

    [System.Web.Services.WebMethod]
    public static string GenerateDDC(string categoryName, string authorName, string edition, string languageName)
    {
        string catCode = "UNK";
        if (!string.IsNullOrEmpty(categoryName))
        {
            using (var con = DBHelper.GetConnection())
            {
                string query = "SELECT CatCode FROM Categories WITH (NOLOCK) WHERE CatName = @CatName";
                using (var cmd = new SqlCommand(query, con) { CommandTimeout = 30 })
                {
                    cmd.Parameters.AddWithValue("@CatName", categoryName.Trim());
                    con.Open();
                    object res = cmd.ExecuteScalar();
                    if (res != null && res != DBNull.Value)
                    {
                        catCode = res.ToString().Trim().ToUpper();
                    }
                }
            }
        }

        bool isUrdu = (languageName != null && languageName.Equals("Urdu", StringComparison.OrdinalIgnoreCase)) || ContainsUrdu(categoryName) || ContainsUrdu(authorName);

        string authorPrefix = "UNK";
        if (!string.IsNullOrEmpty(authorName))
        {
            string lastName = "";
            string cleanName = authorName.Trim();
            if (cleanName.Contains(","))
            {
                lastName = cleanName.Split(',')[0].Trim();
            }
            else
            {
                int lastSpace = cleanName.LastIndexOf(' ');
                if (lastSpace >= 0)
                {
                    lastName = cleanName.Substring(lastSpace + 1).Trim();
                }
                else
                {
                    lastName = cleanName;
                }
            }
            
            if (isUrdu || ContainsUrdu(lastName))
            {
                string cleanUrdu = System.Text.RegularExpressions.Regex.Replace(lastName, @"[^\u0600-\u06FFa-zA-Z]", "");
                authorPrefix = cleanUrdu.Length >= 3 ? cleanUrdu.Substring(0, 3) : (cleanUrdu.Length > 0 ? cleanUrdu.PadRight(3, 'X') : "UNK");
            }
            else
            {
                string letters = System.Text.RegularExpressions.Regex.Replace(lastName, "[^a-zA-Z]", "").ToUpper();
                authorPrefix = letters.Length >= 3 ? letters.Substring(0, 3) : (letters.Length > 0 ? letters.PadRight(3, 'X') : "UNK");
            }
        }

        string editionPrefix = "1E";
        if (!string.IsNullOrEmpty(edition))
        {
            string clean = "";
            if (isUrdu)
            {
                clean = System.Text.RegularExpressions.Regex.Replace(edition, @"[^\u0600-\u06FFa-zA-Z0-9]", "").ToUpper();
            }
            else
            {
                clean = System.Text.RegularExpressions.Regex.Replace(edition, "[^a-zA-Z0-9]", "").ToUpper();
            }
            
            if (!string.IsNullOrEmpty(clean))
            {
                editionPrefix = clean.Length > 4 ? clean.Substring(0, 4) : clean;
            }
        }

        int compSeq = 100001;
        using (var con = DBHelper.GetConnection())
        {
            string query = "SELECT ISNULL(MAX(BookID), 0) FROM Books WITH (NOLOCK)";
            using (var cmd = new SqlCommand(query, con) { CommandTimeout = 30 })
            {
                con.Open();
                int maxBookID = Convert.ToInt32(cmd.ExecuteScalar());
                compSeq += maxBookID;
            }
        }
        string compCode = compSeq.ToString();

        string baseDdc = catCode + " " + authorPrefix + " " + editionPrefix + "-" + compCode;

        int increment = 1;
        using (var con = DBHelper.GetConnection())
        {
            string query = "SELECT COUNT(*) FROM Books WITH (NOLOCK) WHERE DDC LIKE @Pattern";
            using (var cmd = new SqlCommand(query, con) { CommandTimeout = 30 })
            {
                cmd.Parameters.AddWithValue("@Pattern", baseDdc + "-%");
                con.Open();
                int count = Convert.ToInt32(cmd.ExecuteScalar());
                increment += count;
            }
        }

        string ddcStr = baseDdc + "-" + increment;
        if (isUrdu)
        {
            ddcStr = ConvertToUrduDigits(ddcStr);
        }
        return ddcStr;
    }

    public string GetConditionDisplayName(object conditionObj)
    {
        string c = (conditionObj ?? "").ToString().Trim();
        if (string.IsNullOrEmpty(c)) return "New";
        if (c.Equals("Good", StringComparison.OrdinalIgnoreCase) || c.Equals("Old", StringComparison.OrdinalIgnoreCase) || c.Equals("O", StringComparison.OrdinalIgnoreCase))
            return "Old";
        if (c.Equals("Fair", StringComparison.OrdinalIgnoreCase) || c.Equals("Poor", StringComparison.OrdinalIgnoreCase) || c.Equals("SH", StringComparison.OrdinalIgnoreCase) || c.Equals("SecondHand", StringComparison.OrdinalIgnoreCase) || c.Equals("Second Hand", StringComparison.OrdinalIgnoreCase) || c.Equals("S", StringComparison.OrdinalIgnoreCase))
            return "SecondHand";
        return "New";
    }

    public string GetConditionStyle(object conditionObj)
    {
        string cond = GetConditionDisplayName(conditionObj);
        string bg = "#d1fae5";
        string fg = "#065f46";

        if (cond == "Old")
        {
            bg = "#fef9c3";
            fg = "#713f12";
        }
        else if (cond == "SecondHand")
        {
            bg = "#fee2e2";
            fg = "#991b1b";
        }

        return "padding:2px 8px; border-radius:12px; font-size:11px; font-weight:600; background: " + bg + "; color: " + fg + ";";
    }

    public string GetAvailabilityStyle(object isAvailableObj)
    {
        bool isAvailable = false;
        if (isAvailableObj != null && isAvailableObj != DBNull.Value)
        {
            isAvailable = Convert.ToBoolean(isAvailableObj);
        }
        string color = isAvailable ? "#059669" : "#dc2626";
        return "font-weight:600; color: " + color + ";";
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
        bool isAdults, bool isChildren,
        string donatedBy, string msNo, string donatedByName)
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
            new SqlParameter("@DonatedBy",        (object)donatedBy   ?? DBNull.Value),
            new SqlParameter("@MS_No",            (object)msNo        ?? DBNull.Value),
            new SqlParameter("@DonatedByName",    (object)donatedByName ?? DBNull.Value),
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
        byte condID, decimal? cost, string notes, int? bookNo = null, string location = null)
    {
        var prms = new[]
        {
            new SqlParameter("@BookID",   bookID),
            new SqlParameter("@RackID",   (object)rackID   ?? DBNull.Value),
            new SqlParameter("@SlotNo",   (object)slotNo   ?? DBNull.Value),
            new SqlParameter("@CondID",   condID),
            new SqlParameter("@AcqCost",  (object)cost     ?? DBNull.Value),
            new SqlParameter("@Notes",    (object)notes    ?? DBNull.Value),
            new SqlParameter("@BookNo",   (object)bookNo   ?? DBNull.Value),
            new SqlParameter("@Location", (object)location ?? DBNull.Value),
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

