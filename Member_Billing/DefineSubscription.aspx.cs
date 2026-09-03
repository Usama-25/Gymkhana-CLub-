using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Member_Billing_DefineSubscription : Page
{
    /// <summary>
    /// Returns the dedicated Member_Billing database connection string
    /// </summary>
    private string GetConnectionString()
    {
        var connObj = ConfigurationManager.ConnectionStrings["MemberBillingConnection"]
                   ?? ConfigurationManager.ConnectionStrings["Member_Billing_ConnectionString"]
                   ?? ConfigurationManager.ConnectionStrings["MemberBillingConnectionString"]
                   ?? ConfigurationManager.ConnectionStrings["MemberShipConnection"]
                   ?? ConfigurationManager.ConnectionStrings["GymkhanaDB"];

        if (connObj != null && !string.IsNullOrEmpty(connObj.ConnectionString))
        {
            return connObj.ConnectionString;
        }

        return "Data Source=.\\LOCALHOST;Initial Catalog=Member_Billing;Integrated Security=True;";
    }

    /// <summary>
    /// Returns connection string to MemberShip database (for FormTypeMain, MembershipType)
    /// </summary>
    private string GetMembershipConnectionString()
    {
        var connObj = ConfigurationManager.ConnectionStrings["MemberShipConnection"]
                   ?? ConfigurationManager.ConnectionStrings["MemberShipConnString"]
                   ?? ConfigurationManager.ConnectionStrings["GymkhanaDB"];

        if (connObj != null && !string.IsNullOrEmpty(connObj.ConnectionString))
        {
            return connObj.ConnectionString;
        }

        return "Data Source=.\\LOCALHOST;Initial Catalog=MemberShip;Integrated Security=True;";
    }

    /// <summary>
    /// Returns connection string to Finance database (for Expenditure / Financial Heads)
    /// </summary>
    private string GetFinanceConnectionString()
    {
        var connObj = ConfigurationManager.ConnectionStrings["Finance_ConnectionString"]
                   ?? ConfigurationManager.ConnectionStrings["FinanceConnectionString"]
                   ?? ConfigurationManager.ConnectionStrings["MemberShipConnection"];

        if (connObj != null && !string.IsNullOrEmpty(connObj.ConnectionString))
        {
            return connObj.ConnectionString;
        }

        return GetConnectionString();
    }

    /// <summary>
    /// In-memory table of Age Benefit Slabs for current subscription
    /// </summary>
    private DataTable BenefitTiersTable
    {
        get
        {
            if (ViewState["CurrentBenefitTiers"] != null)
            {
                return (DataTable)ViewState["CurrentBenefitTiers"];
            }
            DataTable dt = new DataTable();
            dt.Columns.Add("BenefitID", typeof(int));
            dt.Columns.Add("BenefitTitle", typeof(string));
            dt.Columns.Add("MinAge", typeof(int));
            dt.Columns.Add("MaxAge", typeof(int));
            dt.Columns.Add("MinMembershipYears", typeof(int));
            dt.Columns.Add("DiscountPercentage", typeof(decimal));
            dt.Columns.Add("DiscountFixed", typeof(decimal));
            ViewState["CurrentBenefitTiers"] = dt;
            return dt;
        }
        set
        {
            ViewState["CurrentBenefitTiers"] = value;
        }
    }

    /// <summary>
    /// In-memory table of Category & Membership Type Rates for current subscription
    /// </summary>
    private DataTable CategoryRatesTable
    {
        get
        {
            if (ViewState["CurrentCategoryRates"] != null)
            {
                return (DataTable)ViewState["CurrentCategoryRates"];
            }
            DataTable dt = new DataTable();
            dt.Columns.Add("RateID", typeof(int));
            dt.Columns.Add("CategoryID", typeof(int));
            dt.Columns.Add("CategoryName", typeof(string));
            dt.Columns.Add("MembershipTypeID", typeof(int));
            dt.Columns.Add("MembershipTypeName", typeof(string));
            dt.Columns.Add("Amount", typeof(decimal));
            ViewState["CurrentCategoryRates"] = dt;
            return dt;
        }
        set
        {
            ViewState["CurrentCategoryRates"] = value;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            EnsureDatabaseTable();
            LoadFinancialHeads();
            LoadMemberCategories();
            LoadMembershipTypes();
            LoadSubscriptionsGrid();
            UpdateKpiStats();
            GenerateNextSubscriptionCode();
            BindBenefitTiersGrid();
            BindCategoryRatesGrid();
        }
    }

    /// <summary>
    /// Auto-generates the next sequential unique Subscription Code (e.g. SUB-001)
    /// </summary>
    private void GenerateNextSubscriptionCode()
    {
        string connStr = GetConnectionString();
        string nextCode = "SUB-001";

        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string sql = "SELECT ISNULL(MAX(SubscriptionID), 0) + 1 FROM MemberBilling_Subscriptions";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null)
                    {
                        int nextId = Convert.ToInt32(result);
                        nextCode = "SUB-" + nextId.ToString("D3");
                    }
                }
            }
        }
        catch
        {
            nextCode = "SUB-" + new Random().Next(100, 999);
        }

        txtSubscriptionCode.Text = nextCode;
    }

    /// <summary>
    /// Ensures that all database tables, columns, and synonyms exist in Member_Billing.
    /// </summary>
    private void EnsureDatabaseTable()
    {
        string connStr = GetConnectionString();

        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();

                // 1. Create MemberBilling_Subscriptions if not exists
                string sqlCreateParent = @"
                IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MemberBilling_Subscriptions')
                BEGIN
                    CREATE TABLE MemberBilling_Subscriptions (
                        SubscriptionID         INT IDENTITY(1,1) PRIMARY KEY,
                        SubscriptionCode       NVARCHAR(50) NOT NULL,
                        SubscriptionName       NVARCHAR(150) NOT NULL,
                        Amount                 DECIMAL(18,2) NOT NULL,
                        HasAgeBenefit          BIT DEFAULT 0,
                        HasCategoryRates       BIT DEFAULT 0,
                        FinancialHeadCode      NVARCHAR(50) NULL,
                        FinancialHeadName      NVARCHAR(200) NULL,
                        Description            NVARCHAR(500) NULL,
                        IsActive               BIT DEFAULT 1,
                        CreatedBy              NVARCHAR(100) NULL,
                        CreatedDate            DATETIME DEFAULT GETDATE(),
                        UpdatedDate            DATETIME NULL,
                        CONSTRAINT UQ_MB_SubscriptionCode UNIQUE (SubscriptionCode)
                    );
                END";
                using (SqlCommand cmd = new SqlCommand(sqlCreateParent, con))
                {
                    cmd.ExecuteNonQuery();
                }

                // 2. Ensure HasCategoryRates column exists
                string sqlAddCatCol = @"
                IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('MemberBilling_Subscriptions') AND name = 'HasCategoryRates')
                BEGIN
                    ALTER TABLE MemberBilling_Subscriptions ADD HasCategoryRates BIT DEFAULT 0;
                END";
                using (SqlCommand cmd = new SqlCommand(sqlAddCatCol, con))
                {
                    cmd.ExecuteNonQuery();
                }

                // 3. Create child table MemberBilling_SubscriptionAgeBenefits if not exists
                string sqlCreateAge = @"
                IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MemberBilling_SubscriptionAgeBenefits')
                BEGIN
                    CREATE TABLE MemberBilling_SubscriptionAgeBenefits (
                        BenefitID              INT IDENTITY(1,1) PRIMARY KEY,
                        SubscriptionID         INT NOT NULL,
                        BenefitTitle           NVARCHAR(100) NULL,
                        MinAge                 INT NOT NULL,
                        MaxAge                 INT NOT NULL,
                        MinMembershipYears     INT DEFAULT 0,
                        DiscountPercentage     DECIMAL(5,2) DEFAULT 0,
                        DiscountFixed          DECIMAL(18,2) DEFAULT 0,
                        CreatedDate            DATETIME DEFAULT GETDATE(),
                        CONSTRAINT FK_SubscriptionAgeBenefits FOREIGN KEY (SubscriptionID) REFERENCES MemberBilling_Subscriptions(SubscriptionID) ON DELETE CASCADE
                    );
                END";
                using (SqlCommand cmd = new SqlCommand(sqlCreateAge, con))
                {
                    cmd.ExecuteNonQuery();
                }

                // 4. Create child table MemberBilling_SubscriptionCategoryRates if not exists
                string sqlCreateCatRates = @"
                IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MemberBilling_SubscriptionCategoryRates')
                BEGIN
                    CREATE TABLE MemberBilling_SubscriptionCategoryRates (
                        RateID                 INT IDENTITY(1,1) PRIMARY KEY,
                        SubscriptionID         INT NOT NULL,
                        CategoryID             INT NULL,
                        CategoryName           NVARCHAR(150) NOT NULL,
                        MembershipTypeID       INT NULL,
                        MembershipTypeName     NVARCHAR(100) NOT NULL,
                        Amount                 DECIMAL(18,2) NOT NULL,
                        CreatedDate            DATETIME DEFAULT GETDATE(),
                        CONSTRAINT FK_SubscriptionCategoryRates FOREIGN KEY (SubscriptionID) REFERENCES MemberBilling_Subscriptions(SubscriptionID) ON DELETE CASCADE
                    );
                END";
                using (SqlCommand cmd = new SqlCommand(sqlCreateCatRates, con))
                {
                    cmd.ExecuteNonQuery();
                }

                // 5. Ensure Synonyms for FormTypeMain and MembershipType exist
                string sqlSynonyms = @"
                IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'FormTypeMain')
                BEGIN
                    CREATE SYNONYM FormTypeMain FOR MemberShip.dbo.FormTypeMain;
                END;
                IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = 'MembershipType')
                BEGIN
                    CREATE SYNONYM MembershipType FOR MemberShip.dbo.MembershipType;
                END;";
                using (SqlCommand cmd = new SqlCommand(sqlSynonyms, con))
                {
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("EnsureDatabaseTable Exception: " + ex.Message);
        }
    }

    /// <summary>
    /// Loads Member Categories from FormTypeMain (meant to be Category)
    /// </summary>
    private void LoadMemberCategories()
    {
        ddlCategory.Items.Clear();
        cblCategories.Items.Clear();
        ddlFilterCategory.Items.Clear();

        ddlCategory.Items.Add(new ListItem("-- Select Member Category --", ""));
        ddlCategory.Items.Add(new ListItem("-- All Member Categories --", "-1"));
        ddlFilterCategory.Items.Add(new ListItem("All Categories", ""));

        DataTable dt = new DataTable();
        string query = "SELECT id, FormTypeName FROM FormTypeMain WHERE Status = 1 ORDER BY FormTypeName";

        // Try primary connection (via synonym in Member_Billing)
        bool loaded = false;
        try
        {
            using (SqlConnection con = new SqlConnection(GetConnectionString()))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                    loaded = (dt.Rows.Count > 0);
                }
            }
        }
        catch { loaded = false; }

        // Fallback to MemberShip connection directly
        if (!loaded)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(GetMembershipConnectionString()))
                {
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        da.Fill(dt);
                    }
                }
            }
            catch { }
        }

        foreach (DataRow row in dt.Rows)
        {
            string id = row["id"].ToString();
            string name = row["FormTypeName"].ToString().Trim();

            ddlCategory.Items.Add(new ListItem(name, id));
            cblCategories.Items.Add(new ListItem(" " + name, id));
            ddlFilterCategory.Items.Add(new ListItem(name, id));
        }
    }

    /// <summary>
    /// Loads Membership Types from MembershipType (meant to be type)
    /// </summary>
    private void LoadMembershipTypes()
    {
        ddlMembershipType.Items.Clear();
        cblMembershipTypes.Items.Clear();
        ddlFilterMembershipType.Items.Clear();

        ddlMembershipType.Items.Add(new ListItem("-- Select Membership Type --", ""));
        ddlMembershipType.Items.Add(new ListItem("-- All Membership Types --", "-1"));
        ddlFilterMembershipType.Items.Add(new ListItem("All Types", ""));

        DataTable dt = new DataTable();
        string query = "SELECT Id, MembershipType FROM MembershipType WHERE Status = 1 ORDER BY MembershipType";

        // Try primary connection (via synonym in Member_Billing)
        bool loaded = false;
        try
        {
            using (SqlConnection con = new SqlConnection(GetConnectionString()))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                    loaded = (dt.Rows.Count > 0);
                }
            }
        }
        catch { loaded = false; }

        // Fallback to MemberShip connection directly
        if (!loaded)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(GetMembershipConnectionString()))
                {
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        da.Fill(dt);
                    }
                }
            }
            catch { }
        }

        foreach (DataRow row in dt.Rows)
        {
            string id = row["Id"].ToString();
            string name = row["MembershipType"].ToString().Trim();

            ddlMembershipType.Items.Add(new ListItem(name, id));
            cblMembershipTypes.Items.Add(new ListItem(" " + name, id));
            ddlFilterMembershipType.Items.Add(new ListItem(name, id));
        }
    }

    /// <summary>
    /// Loads Financial Heads from Expenditure table
    /// </summary>
    private void LoadFinancialHeads()
    {
        ddlFilterFinancialHead.Items.Clear();
        ddlFilterFinancialHead.Items.Add(new ListItem("All Financial Heads", ""));

        System.Text.StringBuilder sbJson = new System.Text.StringBuilder();
        sbJson.Append("[");
        bool first = true;
        bool loadedFromDb = false;
        string financeConnStr = GetFinanceConnectionString();

        try
        {
            using (SqlConnection con = new SqlConnection(financeConnStr))
            {
                con.Open();
                string checkSql = @"
                    IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetExpenditureHeads')
                        SELECT 1
                    ELSE IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Expenditure')
                        SELECT 2
                    ELSE
                        SELECT 0";

                int method = 0;
                using (SqlCommand chkCmd = new SqlCommand(checkSql, con))
                {
                    object result = chkCmd.ExecuteScalar();
                    if (result != null) int.TryParse(result.ToString(), out method);
                }

                DataTable dtExp = new DataTable();

                if (method == 1)
                {
                    using (SqlCommand cmd = new SqlCommand("sp_GetExpenditureHeads", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        da.Fill(dtExp);
                    }
                }
                else if (method == 2)
                {
                    using (SqlCommand cmd = new SqlCommand("SELECT E_Code, E_Name FROM Expenditure ORDER BY E_Name", con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        da.Fill(dtExp);
                    }
                }

                if (dtExp != null && dtExp.Rows.Count > 0)
                {
                    foreach (DataRow row in dtExp.Rows)
                    {
                        string code = row["E_Code"].ToString().Trim();
                        string name = row["E_Name"].ToString().Trim();
                        string displayText = code + " - " + name;

                        if (!first) sbJson.Append(",");
                        sbJson.AppendFormat("{{\"code\":{0},\"name\":{1},\"display\":{2}}}",
                            HttpUtility.JavaScriptStringEncode(code, true),
                            HttpUtility.JavaScriptStringEncode(name, true),
                            HttpUtility.JavaScriptStringEncode(displayText, true));
                        first = false;

                        ListItem filterItem = new ListItem(displayText, code + "|" + name);
                        ddlFilterFinancialHead.Items.Add(filterItem);
                    }
                    loadedFromDb = true;
                }
            }
        }
        catch
        {
            loadedFromDb = false;
        }

        // Fallback default Financial Heads if DB table is not yet linked
        if (!loadedFromDb || ddlFilterFinancialHead.Items.Count <= 1)
        {
            var defaultHeads = new[]
            {
                new { Code = "FH001", Name = "General Membership Subscription" },
                new { Code = "FH002", Name = "Annual Maintenance & Development Fund" },
                new { Code = "FH003", Name = "Sports & Fitness Subscription" },
                new { Code = "FH004", Name = "Library Subscription" },
                new { Code = "FH005", Name = "Golf Course Annual Subscription" },
                new { Code = "FH006", Name = "Tennis & Squash Subscription" },
                new { Code = "FH007", Name = "Swimming Pool & Health Club" },
                new { Code = "FH008", Name = "Members Welfare & Benevolent Fund" },
                new { Code = "FH009", Name = "Billiards & Indoor Games" },
                new { Code = "FH010", Name = "Miscellaneous Services & Utilities" }
            };

            foreach (var head in defaultHeads)
            {
                string displayText = head.Code + " - " + head.Name;
                string value = head.Code + "|" + head.Name;

                if (!first) sbJson.Append(",");
                sbJson.AppendFormat("{{\"code\":{0},\"name\":{1},\"display\":{2}}}",
                    HttpUtility.JavaScriptStringEncode(head.Code, true),
                    HttpUtility.JavaScriptStringEncode(head.Name, true),
                    HttpUtility.JavaScriptStringEncode(displayText, true));
                first = false;

                ddlFilterFinancialHead.Items.Add(new ListItem(displayText, value));
            }
        }

        sbJson.Append("]");
        hfFinancialHeadsJson.Value = sbJson.ToString();
    }

    #region Category & Membership Type Rates

    /// <summary>
    /// Adds a single rate for selected Category and Membership Type
    /// </summary>
    protected void btnAddCategoryRate_Click(object sender, EventArgs e)
    {
        decimal amount = 0;
        if (!decimal.TryParse(txtCategoryRateAmount.Text.Trim(), out amount) || amount <= 0)
        {
            ShowAlert("Please enter a valid positive amount (PKR) for this category & type rate.", "error");
            ScriptManager.RegisterStartupScript(this, GetType(), "togglePanelCat", "toggleCategoryPricingPanel();", true);
            return;
        }

        int catId = 0;
        string catName = "All Categories";
        if (!string.IsNullOrEmpty(ddlCategory.SelectedValue) && ddlCategory.SelectedValue != "-1")
        {
            int.TryParse(ddlCategory.SelectedValue, out catId);
            catName = ddlCategory.SelectedItem.Text;
        }

        int typeId = 0;
        string typeName = "All Membership Types";
        if (!string.IsNullOrEmpty(ddlMembershipType.SelectedValue) && ddlMembershipType.SelectedValue != "-1")
        {
            int.TryParse(ddlMembershipType.SelectedValue, out typeId);
            typeName = ddlMembershipType.SelectedItem.Text;
        }

        AddOrUpdateCategoryRate(catId, catName, typeId, typeName, amount);

        txtCategoryRateAmount.Text = "";
        chkCategoryPricing.Checked = true;
        BindCategoryRatesGrid();

        ShowAlert("Rate of <strong>PKR " + amount.ToString("N2") + "</strong> added for <strong>" + Server.HtmlEncode(catName) + " / " + Server.HtmlEncode(typeName) + "</strong>.", "success");
        ScriptManager.RegisterStartupScript(this, GetType(), "togglePanelCat", "toggleCategoryPricingPanel();", true);
    }

    /// <summary>
    /// Bulk adds multiple selected categories and multiple selected membership types with one amount
    /// </summary>
    protected void btnBulkAddCategoryRates_Click(object sender, EventArgs e)
    {
        decimal amount = 0;
        if (!decimal.TryParse(txtBulkRateAmount.Text.Trim(), out amount) || amount <= 0)
        {
            ShowAlert("Please enter a valid positive bulk rate amount (PKR).", "error");
            ScriptManager.RegisterStartupScript(this, GetType(), "togglePanelCat", "toggleCategoryPricingPanel(); switchCategoryMode('bulk');", true);
            return;
        }

        var selectedCats = new System.Collections.Generic.List<ListItem>();
        foreach (ListItem item in cblCategories.Items)
        {
            if (item.Selected) selectedCats.Add(item);
        }

        var selectedTypes = new System.Collections.Generic.List<ListItem>();
        foreach (ListItem item in cblMembershipTypes.Items)
        {
            if (item.Selected) selectedTypes.Add(item);
        }

        if (selectedCats.Count == 0 || selectedTypes.Count == 0)
        {
            ShowAlert("Please select at least one Category and at least one Membership Type for bulk addition.", "error");
            ScriptManager.RegisterStartupScript(this, GetType(), "togglePanelCat", "toggleCategoryPricingPanel(); switchCategoryMode('bulk');", true);
            return;
        }

        int addedCount = 0;
        foreach (var cat in selectedCats)
        {
            int catId = Convert.ToInt32(cat.Value);
            string catName = cat.Text.Trim();

            foreach (var typ in selectedTypes)
            {
                int typeId = Convert.ToInt32(typ.Value);
                string typeName = typ.Text.Trim();

                AddOrUpdateCategoryRate(catId, catName, typeId, typeName, amount);
                addedCount++;
            }
        }

        txtBulkRateAmount.Text = "";
        chkCategoryPricing.Checked = true;
        BindCategoryRatesGrid();

        ShowAlert("Successfully applied rate of <strong>PKR " + amount.ToString("N2") + "</strong> to " + addedCount + " Category & Type combinations.", "success");
        ScriptManager.RegisterStartupScript(this, GetType(), "togglePanelCat", "toggleCategoryPricingPanel();", true);
    }

    private void AddOrUpdateCategoryRate(int catId, string catName, int typeId, string typeName, decimal amount)
    {
        DataTable dt = CategoryRatesTable;
        bool found = false;

        foreach (DataRow row in dt.Rows)
        {
            int rCatId = row["CategoryID"] != DBNull.Value ? Convert.ToInt32(row["CategoryID"]) : 0;
            int rTypeId = row["MembershipTypeID"] != DBNull.Value ? Convert.ToInt32(row["MembershipTypeID"]) : 0;

            if (rCatId == catId && rTypeId == typeId)
            {
                row["Amount"] = amount;
                row["CategoryName"] = catName;
                row["MembershipTypeName"] = typeName;
                found = true;
                break;
            }
        }

        if (!found)
        {
            DataRow dr = dt.NewRow();
            dr["RateID"] = 0;
            dr["CategoryID"] = catId;
            dr["CategoryName"] = catName;
            dr["MembershipTypeID"] = typeId;
            dr["MembershipTypeName"] = typeName;
            dr["Amount"] = amount;
            dt.Rows.Add(dr);
        }

        CategoryRatesTable = dt;
    }

    protected void gvCategoryRates_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "RemoveRate")
        {
            int index = Convert.ToInt32(e.CommandArgument);
            DataTable dt = CategoryRatesTable;
            if (index >= 0 && index < dt.Rows.Count)
            {
                dt.Rows.RemoveAt(index);
                CategoryRatesTable = dt;
                BindCategoryRatesGrid();
            }
            ScriptManager.RegisterStartupScript(this, GetType(), "togglePanelCat", "toggleCategoryPricingPanel();", true);
        }
    }

    protected void btnClearAllCategoryRates_Click(object sender, EventArgs e)
    {
        DataTable dt = CategoryRatesTable;
        dt.Rows.Clear();
        CategoryRatesTable = dt;
        BindCategoryRatesGrid();
        ScriptManager.RegisterStartupScript(this, GetType(), "togglePanelCat", "toggleCategoryPricingPanel();", true);
    }

    private void BindCategoryRatesGrid()
    {
        DataTable dt = CategoryRatesTable;
        gvCategoryRates.DataSource = dt;
        gvCategoryRates.DataBind();
        litCategoryRateCount.Text = dt.Rows.Count.ToString();
    }

    /// <summary>
    /// Helper method called from GridView to format all category rates for a given subscription
    /// </summary>
    public string GetFormattedCategoryRates(object subscriptionIdObj)
    {
        if (subscriptionIdObj == null || subscriptionIdObj == DBNull.Value)
            return "<span style='color:#94a3b8; font-size:10px;'>Standard Rate</span>";

        int subId = Convert.ToInt32(subscriptionIdObj);
        string connStr = GetConnectionString();
        DataTable dtRates = new DataTable();

        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string sql = @"
                IF EXISTS (SELECT * FROM sys.tables WHERE name = 'MemberBilling_SubscriptionCategoryRates')
                    SELECT * FROM MemberBilling_SubscriptionCategoryRates WHERE SubscriptionID = @SubID ORDER BY CategoryName, MembershipTypeName";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@SubID", subId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dtRates);
                }
            }

            if (dtRates.Rows.Count == 0)
            {
                return "<span style='color:#94a3b8; font-size:10px;'>Standard Rate</span>";
            }

            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            sb.Append("<div style='display:flex; flex-direction:column; gap:2.5px;'>");

            int maxDisplay = 2;
            int count = 0;

            foreach (DataRow row in dtRates.Rows)
            {
                if (count < maxDisplay)
                {
                    string cat = row["CategoryName"].ToString();
                    string typ = row["MembershipTypeName"].ToString();
                    decimal amt = Convert.ToDecimal(row["Amount"]);

                    sb.Append("<div style='font-size:10px; display:inline-flex; align-items:center; gap:4px;'>");
                    sb.Append("<span style='background:#f1f5f9; color:#1e293b; border:1px solid #cbd5e1; padding:0.5px 5px; border-radius:3px; font-weight:700; font-size:9.5px;'>");
                    sb.Append(Server.HtmlEncode(cat + " / " + typ));
                    sb.Append("</span>");
                    sb.Append("<span style='color:#065f46; font-weight:800; font-size:10.5px;'>PKR " + amt.ToString("N0") + "</span>");
                    sb.Append("</div>");
                }
                count++;
            }

            if (dtRates.Rows.Count > maxDisplay)
            {
                int remaining = dtRates.Rows.Count - maxDisplay;
                sb.Append("<span style='background:#e0f2fe; color:#0369a1; border:1px solid #bae6fd; padding:1px 6px; border-radius:8px; font-weight:700; font-size:9.5px; width:fit-content;' title='Total " + dtRates.Rows.Count + " rates configured'>");
                sb.Append("+" + remaining + " more rates");
                sb.Append("</span>");
            }

            sb.Append("</div>");
            return sb.ToString();
        }
        catch
        {
            return "<span style='color:#94a3b8; font-size:10px;'>Standard Rate</span>";
        }
    }

    #endregion

    #region Age Benefit Slabs

    /// <summary>
    /// Adds a new Age Benefit Tier to the in-memory table for the current subscription.
    /// </summary>
    protected void btnAddTier_Click(object sender, EventArgs e)
    {
        int minAge, maxAge;
        if (!int.TryParse(txtMinAge.Text.Trim(), out minAge) || minAge < 0)
        {
            ShowAlert("Please enter a valid Minimum Age for this tier.", "error");
            ScriptManager.RegisterStartupScript(this, GetType(), "togglePanelAge", "toggleAgeBenefitPanel();", true);
            return;
        }

        if (!int.TryParse(txtMaxAge.Text.Trim(), out maxAge) || maxAge < minAge)
        {
            ShowAlert("Maximum Age must be greater than or equal to Minimum Age.", "error");
            ScriptManager.RegisterStartupScript(this, GetType(), "togglePanelAge", "toggleAgeBenefitPanel();", true);
            return;
        }

        int minYears = 0;
        int.TryParse(txtMinMembershipYears.Text.Trim(), out minYears);

        decimal discPct = 0;
        decimal.TryParse(txtDiscountPercentage.Text.Trim(), out discPct);

        decimal discFixed = 0;
        decimal.TryParse(txtDiscountFixed.Text.Trim(), out discFixed);

        if (discPct <= 0 && discFixed <= 0)
        {
            ShowAlert("Please specify either a Discount Percentage (%) or a Fixed Discount Amount (PKR) for this tier.", "error");
            ScriptManager.RegisterStartupScript(this, GetType(), "togglePanelAge", "toggleAgeBenefitPanel();", true);
            return;
        }

        string title = txtTierTitle.Text.Trim();
        if (string.IsNullOrEmpty(title))
        {
            title = "Age " + minAge + " - " + maxAge + " yrs";
        }

        DataTable dt = BenefitTiersTable;
        DataRow dr = dt.NewRow();
        dr["BenefitID"] = 0;
        dr["BenefitTitle"] = title;
        dr["MinAge"] = minAge;
        dr["MaxAge"] = maxAge;
        dr["MinMembershipYears"] = minYears;
        dr["DiscountPercentage"] = discPct;
        dr["DiscountFixed"] = discFixed;
        dt.Rows.Add(dr);
        BenefitTiersTable = dt;

        BindBenefitTiersGrid();

        // Clear tier input fields
        txtTierTitle.Text = "";
        txtMinAge.Text = "";
        txtMaxAge.Text = "";
        txtMinMembershipYears.Text = "";
        txtDiscountPercentage.Text = "";
        txtDiscountFixed.Text = "";

        chkAgeBenefit.Checked = true;
        ScriptManager.RegisterStartupScript(this, GetType(), "togglePanelAge", "toggleAgeBenefitPanel(); updateLiveDiscountPreview();", true);
    }

    /// <summary>
    /// Handles removing an age tier from the in-memory list
    /// </summary>
    protected void gvBenefitTiers_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "RemoveTier")
        {
            int index = Convert.ToInt32(e.CommandArgument);
            DataTable dt = BenefitTiersTable;
            if (index >= 0 && index < dt.Rows.Count)
            {
                dt.Rows.RemoveAt(index);
                BenefitTiersTable = dt;
                BindBenefitTiersGrid();
            }
            ScriptManager.RegisterStartupScript(this, GetType(), "togglePanelAge", "toggleAgeBenefitPanel(); updateLiveDiscountPreview();", true);
        }
    }

    private void BindBenefitTiersGrid()
    {
        DataTable dt = BenefitTiersTable;
        gvBenefitTiers.DataSource = dt;
        gvBenefitTiers.DataBind();
        litTierCount.Text = dt.Rows.Count.ToString();
    }

    /// <summary>
    /// Helper method called from GridView to format all age benefit tiers for a given subscription
    /// </summary>
    public string GetFormattedAgeBenefitTiers(object subscriptionIdObj)
    {
        if (subscriptionIdObj == null || subscriptionIdObj == DBNull.Value)
            return "<span style='color:#94a3b8; font-size:11px;'>No Age Benefit</span>";

        int subId = Convert.ToInt32(subscriptionIdObj);
        string connStr = GetConnectionString();
        DataTable dtTiers = new DataTable();

        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string sql = @"
                IF EXISTS (SELECT * FROM sys.tables WHERE name = 'MemberBilling_SubscriptionAgeBenefits')
                    SELECT * FROM MemberBilling_SubscriptionAgeBenefits WHERE SubscriptionID = @SubID ORDER BY MinAge ASC";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@SubID", subId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dtTiers);
                }
            }

            if (dtTiers.Rows.Count == 0)
            {
                return "<span style='background:#fbf8f2; color:#854d0e; border:1px solid #c5a572; padding:1px 6px; border-radius:10px; font-weight:700; font-size:10.5px;'>Custom Slabs</span>";
            }

            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            sb.Append("<div style='display:flex; flex-direction:column; gap:3px;'>");

            foreach (DataRow row in dtTiers.Rows)
            {
                string title = row["BenefitTitle"] != DBNull.Value && !string.IsNullOrEmpty(row["BenefitTitle"].ToString())
                    ? row["BenefitTitle"].ToString()
                    : "Age " + row["MinAge"] + "-" + row["MaxAge"] + " yrs";

                decimal discPct = row["DiscountPercentage"] != DBNull.Value ? Convert.ToDecimal(row["DiscountPercentage"]) : 0;
                decimal discFixed = row["DiscountFixed"] != DBNull.Value ? Convert.ToDecimal(row["DiscountFixed"]) : 0;
                string discStr = (discPct > 0 ? discPct.ToString("0.##") + "%" : "") +
                                 (discFixed > 0 ? (discPct > 0 ? " + " : "") + "Rs. " + discFixed.ToString("N0") : "");

                sb.Append("<div style='font-size:11px; display:flex; align-items:center; gap:6px;'>");
                sb.Append("<span style='background:#fbf8f2; color:#0f2b48; border:1px solid #c5a572; padding:1px 6px; border-radius:10px; font-weight:700; font-size:10px;'>");
                sb.Append(Server.HtmlEncode(title));
                sb.Append("</span>");
                sb.Append("<span style='color:#1e3a5f; font-weight:800; font-size:10.5px;'>" + discStr + " off</span>");
                sb.Append("</div>");
            }

            sb.Append("</div>");
            return sb.ToString();
        }
        catch
        {
            return "<span style='background:#fbf8f2; color:#854d0e; border:1px solid #c5a572; padding:1px 6px; border-radius:10px; font-weight:700; font-size:10.5px;'>Active Slabs</span>";
        }
    }

    #endregion

    /// <summary>
    /// Loads the Subscriptions Grid with filtering support
    /// </summary>
    private void LoadSubscriptionsGrid(string searchKeyword = "", string financialHead = "", string status = "", string categoryId = "", string membershipTypeId = "")
    {
        string connStr = GetConnectionString();
        DataTable dt = new DataTable();

        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT 
                        SubscriptionID,
                        ISNULL(SubscriptionCode, 'SUB-' + RIGHT('000' + CAST(SubscriptionID AS VARCHAR(10)), 3)) AS SubscriptionCode,
                        SubscriptionName,
                        Amount,
                        ISNULL(HasAgeBenefit, 0) AS HasAgeBenefit,
                        ISNULL(HasCategoryRates, 0) AS HasCategoryRates,
                        FinancialHeadCode,
                        FinancialHeadName,
                        Description,
                        IsActive,
                        CreatedDate
                    FROM MemberBilling_Subscriptions
                    WHERE 1 = 1";

                if (!string.IsNullOrEmpty(searchKeyword))
                {
                    query += " AND (SubscriptionCode LIKE @Keyword OR SubscriptionName LIKE @Keyword OR Description LIKE @Keyword OR FinancialHeadName LIKE @Keyword OR FinancialHeadCode LIKE @Keyword)";
                }

                if (!string.IsNullOrEmpty(financialHead))
                {
                    query += " AND (FinancialHeadCode = @HeadCode OR FinancialHeadName = @HeadName)";
                }

                if (!string.IsNullOrEmpty(status))
                {
                    query += " AND IsActive = @IsActive";
                }

                if (!string.IsNullOrEmpty(categoryId) && categoryId != "0" && categoryId != "-1")
                {
                    query += " AND SubscriptionID IN (SELECT SubscriptionID FROM MemberBilling_SubscriptionCategoryRates WHERE CategoryID = @CategoryID)";
                }

                if (!string.IsNullOrEmpty(membershipTypeId) && membershipTypeId != "0" && membershipTypeId != "-1")
                {
                    query += " AND SubscriptionID IN (SELECT SubscriptionID FROM MemberBilling_SubscriptionCategoryRates WHERE MembershipTypeID = @MembershipTypeID)";
                }

                query += " ORDER BY SubscriptionID DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    if (!string.IsNullOrEmpty(searchKeyword))
                    {
                        cmd.Parameters.AddWithValue("@Keyword", "%" + searchKeyword.Trim() + "%");
                    }

                    if (!string.IsNullOrEmpty(financialHead))
                    {
                        string headCode = financialHead.Contains("|") ? financialHead.Split('|')[0] : financialHead;
                        string headName = financialHead.Contains("|") ? financialHead.Split('|')[1] : financialHead;
                        cmd.Parameters.AddWithValue("@HeadCode", headCode);
                        cmd.Parameters.AddWithValue("@HeadName", headName);
                    }

                    if (!string.IsNullOrEmpty(status))
                    {
                        cmd.Parameters.AddWithValue("@IsActive", status == "1");
                    }

                    if (!string.IsNullOrEmpty(categoryId) && categoryId != "0" && categoryId != "-1")
                    {
                        cmd.Parameters.AddWithValue("@CategoryID", Convert.ToInt32(categoryId));
                    }

                    if (!string.IsNullOrEmpty(membershipTypeId) && membershipTypeId != "0" && membershipTypeId != "-1")
                    {
                        cmd.Parameters.AddWithValue("@MembershipTypeID", Convert.ToInt32(membershipTypeId));
                    }

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                }
            }

            gvSubscriptions.DataSource = dt;
            gvSubscriptions.DataBind();

            litRecordCount.Text = dt.Rows.Count.ToString();
        }
        catch (Exception ex)
        {
            ShowAlert("Error loading subscriptions: " + ex.Message, "error");
        }
    }

    /// <summary>
    /// Computes and displays KPI widgets at the top.
    /// </summary>
    private void UpdateKpiStats()
    {
        string connStr = GetConnectionString();

        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string sql = @"
                    SELECT 
                        COUNT(*) AS TotalCount,
                        ISNULL(SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END), 0) AS ActiveCount,
                        ISNULL(SUM(CASE WHEN HasAgeBenefit = 1 AND IsActive = 1 THEN 1 ELSE 0 END), 0) AS AgeBenefitCount,
                        ISNULL(SUM(CASE WHEN HasCategoryRates = 1 AND IsActive = 1 THEN 1 ELSE 0 END), 0) AS CategoryRatesCount
                    FROM MemberBilling_Subscriptions";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    con.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            lblTotalPackages.Text = rdr["TotalCount"].ToString();
                            lblActivePackages.Text = rdr["ActiveCount"].ToString();
                            lblAgeBenefitCount.Text = rdr["AgeBenefitCount"].ToString();
                            lblCategoryRatesCount.Text = rdr["CategoryRatesCount"].ToString();
                        }
                    }
                }
            }
        }
        catch
        {
            // Silently maintain default values if stats query fails
        }
    }

    /// <summary>
    /// Save or Update Subscription Record & Child Tables (Category Rates & Age Slabs)
    /// </summary>
    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        string code = txtSubscriptionCode.Text.Trim().ToUpper();
        if (string.IsNullOrEmpty(code))
        {
            ShowAlert("Please enter a Unique Subscription ID / Code.", "error");
            return;
        }

        string name = txtSubscriptionName.Text.Trim();
        decimal amount = 0;
        if (!decimal.TryParse(txtAmount.Text.Trim(), out amount) || amount <= 0)
        {
            ShowAlert("Please enter a valid positive base subscription amount.", "error");
            return;
        }

        bool hasAgeBenefit = chkAgeBenefit.Checked;
        DataTable dtTiers = BenefitTiersTable;

        if (hasAgeBenefit && dtTiers.Rows.Count == 0)
        {
            int minAge, maxAge;
            decimal discPct = 0, discFixed = 0;
            if (int.TryParse(txtMinAge.Text.Trim(), out minAge) && int.TryParse(txtMaxAge.Text.Trim(), out maxAge))
            {
                decimal.TryParse(txtDiscountPercentage.Text.Trim(), out discPct);
                decimal.TryParse(txtDiscountFixed.Text.Trim(), out discFixed);
                if (discPct > 0 || discFixed > 0)
                {
                    int minYears = 0;
                    int.TryParse(txtMinMembershipYears.Text.Trim(), out minYears);
                    DataRow dr = dtTiers.NewRow();
                    dr["BenefitID"] = 0;
                    dr["BenefitTitle"] = !string.IsNullOrEmpty(txtTierTitle.Text.Trim()) ? txtTierTitle.Text.Trim() : "Age " + minAge + " - " + maxAge + " yrs";
                    dr["MinAge"] = minAge;
                    dr["MaxAge"] = maxAge;
                    dr["MinMembershipYears"] = minYears;
                    dr["DiscountPercentage"] = discPct;
                    dr["DiscountFixed"] = discFixed;
                    dtTiers.Rows.Add(dr);
                    BenefitTiersTable = dtTiers;
                }
            }

            if (dtTiers.Rows.Count == 0)
            {
                ShowAlert("You enabled Age Benefit. Please configure at least one Age Benefit Slab.", "error");
                ScriptManager.RegisterStartupScript(this, GetType(), "togglePanelAge", "toggleAgeBenefitPanel();", true);
                return;
            }
        }

        bool hasCategoryRates = chkCategoryPricing.Checked && CategoryRatesTable.Rows.Count > 0;
        DataTable dtCatRates = CategoryRatesTable;

        // Parse Auto-Fill Financial Head (Concatenated E_Code - E_Name)
        string inputHead = txtFinancialHead.Text.Trim();
        string headCode = "";
        string headName = "";
        if (!string.IsNullOrEmpty(inputHead))
        {
            if (inputHead.Contains(" - "))
            {
                int dashIdx = inputHead.IndexOf(" - ");
                headCode = inputHead.Substring(0, dashIdx).Trim();
                headName = inputHead.Substring(dashIdx + 3).Trim();
            }
            else if (inputHead.Contains("-"))
            {
                int dashIdx = inputHead.IndexOf("-");
                headCode = inputHead.Substring(0, dashIdx).Trim();
                headName = inputHead.Substring(dashIdx + 1).Trim();
            }
            else
            {
                headCode = inputHead;
                headName = inputHead;
            }
        }

        string description = txtDescription.Text.Trim();
        bool isActive = chkIsActive.Checked;

        int subscriptionId = 0;
        int.TryParse(hfSubscriptionID.Value, out subscriptionId);

        string connStr = GetConnectionString();

        try
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();

                // 1. Validate Uniqueness of SubscriptionCode
                string checkUniqueSql = "SELECT COUNT(*) FROM MemberBilling_Subscriptions WHERE SubscriptionCode = @Code AND SubscriptionID <> @ID";
                using (SqlCommand chkCmd = new SqlCommand(checkUniqueSql, con))
                {
                    chkCmd.Parameters.AddWithValue("@Code", code);
                    chkCmd.Parameters.AddWithValue("@ID", subscriptionId);
                    int exists = Convert.ToInt32(chkCmd.ExecuteScalar());
                    if (exists > 0)
                    {
                        ShowAlert("Subscription ID / Code <strong>'" + Server.HtmlEncode(code) + "'</strong> is already in use by another subscription. Please choose a unique code.", "error");
                        return;
                    }
                }

                int savedSubscriptionId = subscriptionId;

                if (subscriptionId <= 0)
                {
                    // INSERT Parent
                    string insertSql = @"
                        INSERT INTO MemberBilling_Subscriptions
                        (
                            SubscriptionCode, SubscriptionName, Amount, HasAgeBenefit, HasCategoryRates,
                            FinancialHeadCode, FinancialHeadName, Description, IsActive,
                            CreatedBy, CreatedDate
                        )
                        OUTPUT INSERTED.SubscriptionID
                        VALUES
                        (
                            @SubscriptionCode, @SubscriptionName, @Amount, @HasAgeBenefit, @HasCategoryRates,
                            @FinancialHeadCode, @FinancialHeadName, @Description, @IsActive,
                            @CreatedBy, GETDATE()
                        );";

                    using (SqlCommand cmd = new SqlCommand(insertSql, con))
                    {
                        cmd.Parameters.AddWithValue("@SubscriptionCode", code);
                        cmd.Parameters.AddWithValue("@SubscriptionName", name);
                        cmd.Parameters.AddWithValue("@Amount", amount);
                        cmd.Parameters.AddWithValue("@HasAgeBenefit", hasAgeBenefit);
                        cmd.Parameters.AddWithValue("@HasCategoryRates", hasCategoryRates);
                        cmd.Parameters.AddWithValue("@FinancialHeadCode", (object)headCode ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@FinancialHeadName", (object)headName ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Description", (object)description ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@IsActive", isActive);
                        cmd.Parameters.AddWithValue("@CreatedBy", Session["UserName"] != null ? Session["UserName"].ToString() : "Admin");

                        object newId = cmd.ExecuteScalar();
                        if (newId != null && newId != DBNull.Value)
                        {
                            savedSubscriptionId = Convert.ToInt32(newId);
                        }
                    }
                }
                else
                {
                    // UPDATE Parent
                    string updateSql = @"
                        UPDATE MemberBilling_Subscriptions
                        SET
                            SubscriptionCode = @SubscriptionCode,
                            SubscriptionName = @SubscriptionName,
                            Amount = @Amount,
                            HasAgeBenefit = @HasAgeBenefit,
                            HasCategoryRates = @HasCategoryRates,
                            FinancialHeadCode = @FinancialHeadCode,
                            FinancialHeadName = @FinancialHeadName,
                            Description = @Description,
                            IsActive = @IsActive,
                            UpdatedDate = GETDATE()
                        WHERE SubscriptionID = @SubscriptionID;";

                    using (SqlCommand cmd = new SqlCommand(updateSql, con))
                    {
                        cmd.Parameters.AddWithValue("@SubscriptionID", subscriptionId);
                        cmd.Parameters.AddWithValue("@SubscriptionCode", code);
                        cmd.Parameters.AddWithValue("@SubscriptionName", name);
                        cmd.Parameters.AddWithValue("@Amount", amount);
                        cmd.Parameters.AddWithValue("@HasAgeBenefit", hasAgeBenefit);
                        cmd.Parameters.AddWithValue("@HasCategoryRates", hasCategoryRates);
                        cmd.Parameters.AddWithValue("@FinancialHeadCode", (object)headCode ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@FinancialHeadName", (object)headName ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Description", (object)description ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@IsActive", isActive);

                        cmd.ExecuteNonQuery();
                    }
                }

                if (savedSubscriptionId > 0)
                {
                    // 2. Save Child Category Rates (Delete existing + insert current)
                    string delCatSql = "DELETE FROM MemberBilling_SubscriptionCategoryRates WHERE SubscriptionID = @SubID";
                    using (SqlCommand delCmd = new SqlCommand(delCatSql, con))
                    {
                        delCmd.Parameters.AddWithValue("@SubID", savedSubscriptionId);
                        delCmd.ExecuteNonQuery();
                    }

                    if (hasCategoryRates && dtCatRates.Rows.Count > 0)
                    {
                        string insertCatSql = @"
                            INSERT INTO MemberBilling_SubscriptionCategoryRates
                            (SubscriptionID, CategoryID, CategoryName, MembershipTypeID, MembershipTypeName, Amount, CreatedDate)
                            VALUES
                            (@SubID, @CatID, @CatName, @TypeID, @TypeName, @Amount, GETDATE())";

                        foreach (DataRow row in dtCatRates.Rows)
                        {
                            using (SqlCommand catCmd = new SqlCommand(insertCatSql, con))
                            {
                                catCmd.Parameters.AddWithValue("@SubID", savedSubscriptionId);
                                catCmd.Parameters.AddWithValue("@CatID", row["CategoryID"] != DBNull.Value ? row["CategoryID"] : (object)DBNull.Value);
                                catCmd.Parameters.AddWithValue("@CatName", row["CategoryName"].ToString());
                                catCmd.Parameters.AddWithValue("@TypeID", row["MembershipTypeID"] != DBNull.Value ? row["MembershipTypeID"] : (object)DBNull.Value);
                                catCmd.Parameters.AddWithValue("@TypeName", row["MembershipTypeName"].ToString());
                                catCmd.Parameters.AddWithValue("@Amount", Convert.ToDecimal(row["Amount"]));

                                catCmd.ExecuteNonQuery();
                            }
                        }
                    }

                    // 3. Save Child Age Benefit Slabs (Delete existing + insert current)
                    string delTiersSql = "DELETE FROM MemberBilling_SubscriptionAgeBenefits WHERE SubscriptionID = @SubID";
                    using (SqlCommand delCmd = new SqlCommand(delTiersSql, con))
                    {
                        delCmd.Parameters.AddWithValue("@SubID", savedSubscriptionId);
                        delCmd.ExecuteNonQuery();
                    }

                    if (hasAgeBenefit && dtTiers.Rows.Count > 0)
                    {
                        string insertTierSql = @"
                            INSERT INTO MemberBilling_SubscriptionAgeBenefits
                            (SubscriptionID, BenefitTitle, MinAge, MaxAge, MinMembershipYears, DiscountPercentage, DiscountFixed, CreatedDate)
                            VALUES
                            (@SubID, @Title, @MinAge, @MaxAge, @MinYears, @DiscPct, @DiscFixed, GETDATE())";

                        foreach (DataRow row in dtTiers.Rows)
                        {
                            using (SqlCommand tierCmd = new SqlCommand(insertTierSql, con))
                            {
                                tierCmd.Parameters.AddWithValue("@SubID", savedSubscriptionId);
                                tierCmd.Parameters.AddWithValue("@Title", row["BenefitTitle"] != DBNull.Value ? row["BenefitTitle"].ToString() : "");
                                tierCmd.Parameters.AddWithValue("@MinAge", Convert.ToInt32(row["MinAge"]));
                                tierCmd.Parameters.AddWithValue("@MaxAge", Convert.ToInt32(row["MaxAge"]));
                                tierCmd.Parameters.AddWithValue("@MinYears", Convert.ToInt32(row["MinMembershipYears"]));
                                tierCmd.Parameters.AddWithValue("@DiscPct", Convert.ToDecimal(row["DiscountPercentage"]));
                                tierCmd.Parameters.AddWithValue("@DiscFixed", Convert.ToDecimal(row["DiscountFixed"]));

                                tierCmd.ExecuteNonQuery();
                            }
                        }
                    }
                }

                ShowAlert("Subscription package <strong>[" + Server.HtmlEncode(code) + "] '" + Server.HtmlEncode(name) + "'</strong> saved successfully with " + dtCatRates.Rows.Count + " Category/Type rates.", "success");
            }

            ResetForm();
            LoadSubscriptionsGrid(txtSearchKeyword.Text, ddlFilterFinancialHead.SelectedValue, ddlFilterStatus.SelectedValue, ddlFilterCategory.SelectedValue, ddlFilterMembershipType.SelectedValue);
            UpdateKpiStats();
        }
        catch (Exception ex)
        {
            ShowAlert("Error saving subscription: " + ex.Message, "error");
        }
    }

    /// <summary>
    /// Handles Edit and ToggleStatus commands on GridView.
    /// </summary>
    protected void gvSubscriptions_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (string.IsNullOrEmpty(e.CommandArgument.ToString())) return;

        int subscriptionId = 0;
        if (!int.TryParse(e.CommandArgument.ToString(), out subscriptionId)) return;

        if (subscriptionId <= 0)
        {
            ShowAlert("Unable to identify subscription record ID.", "error");
            return;
        }

        string connStr = GetConnectionString();

        if (e.CommandName == "EditRecord")
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    // 1. Load Parent Subscription
                    string sql = "SELECT * FROM MemberBilling_Subscriptions WHERE SubscriptionID = @ID";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@ID", subscriptionId);
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                hfSubscriptionID.Value = rdr["SubscriptionID"].ToString();
                                txtSubscriptionCode.Text = rdr["SubscriptionCode"] != DBNull.Value ? rdr["SubscriptionCode"].ToString() : "SUB-" + subscriptionId.ToString("D3");
                                txtSubscriptionName.Text = rdr["SubscriptionName"].ToString();
                                txtAmount.Text = Convert.ToDecimal(rdr["Amount"]).ToString("0.00");

                                bool ageBenefit = Convert.ToBoolean(rdr["HasAgeBenefit"]);
                                chkAgeBenefit.Checked = ageBenefit;

                                bool catRates = rdr["HasCategoryRates"] != DBNull.Value && Convert.ToBoolean(rdr["HasCategoryRates"]);
                                chkCategoryPricing.Checked = catRates;

                                string headCode = rdr["FinancialHeadCode"] != DBNull.Value ? rdr["FinancialHeadCode"].ToString() : "";
                                string headName = rdr["FinancialHeadName"] != DBNull.Value ? rdr["FinancialHeadName"].ToString() : "";
                                
                                if (!string.IsNullOrEmpty(headCode) && !string.IsNullOrEmpty(headName))
                                {
                                    txtFinancialHead.Text = headCode + " - " + headName;
                                }
                                else if (!string.IsNullOrEmpty(headName))
                                {
                                    txtFinancialHead.Text = headName;
                                }
                                else
                                {
                                    txtFinancialHead.Text = headCode;
                                }

                                txtDescription.Text = rdr["Description"] != DBNull.Value ? rdr["Description"].ToString() : "";
                                chkIsActive.Checked = Convert.ToBoolean(rdr["IsActive"]);

                                litFormTitle.Text = "Edit Subscription (" + txtSubscriptionCode.Text + ")";
                                lblEditModeBadge.Visible = true;
                                btnSave.Text = "Update Subscription";
                                btnCancelEdit.Visible = true;
                            }
                        }
                    }

                    // 2. Load Child Category Rates
                    DataTable dtCatRates = new DataTable();
                    string catRatesSql = @"
                    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'MemberBilling_SubscriptionCategoryRates')
                        SELECT RateID, CategoryID, CategoryName, MembershipTypeID, MembershipTypeName, Amount 
                        FROM MemberBilling_SubscriptionCategoryRates 
                        WHERE SubscriptionID = @SubID 
                        ORDER BY CategoryName, MembershipTypeName";

                    using (SqlCommand cmdCat = new SqlCommand(catRatesSql, con))
                    {
                        cmdCat.Parameters.AddWithValue("@SubID", subscriptionId);
                        SqlDataAdapter da = new SqlDataAdapter(cmdCat);
                        da.Fill(dtCatRates);
                    }

                    CategoryRatesTable = dtCatRates;
                    BindCategoryRatesGrid();
                    if (dtCatRates.Rows.Count > 0)
                    {
                        chkCategoryPricing.Checked = true;
                    }

                    // 3. Load Child Age Benefit Tiers
                    DataTable dtTiers = new DataTable();
                    string tiersSql = @"
                    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'MemberBilling_SubscriptionAgeBenefits')
                        SELECT BenefitID, BenefitTitle, MinAge, MaxAge, MinMembershipYears, DiscountPercentage, DiscountFixed 
                        FROM MemberBilling_SubscriptionAgeBenefits 
                        WHERE SubscriptionID = @SubID 
                        ORDER BY MinAge ASC";

                    using (SqlCommand cmdTiers = new SqlCommand(tiersSql, con))
                    {
                        cmdTiers.Parameters.AddWithValue("@SubID", subscriptionId);
                        SqlDataAdapter da = new SqlDataAdapter(cmdTiers);
                        da.Fill(dtTiers);
                    }

                    BenefitTiersTable = dtTiers;
                    BindBenefitTiersGrid();

                    ShowAlert("Editing subscription package <strong>[" + txtSubscriptionCode.Text + "] " + Server.HtmlEncode(txtSubscriptionName.Text) + "</strong>.", "info");

                    ScriptManager.RegisterStartupScript(this, GetType(), "togglePanelScript", "toggleAgeBenefitPanel(); toggleCategoryPricingPanel(); updateLiveDiscountPreview();", true);
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Error loading subscription for edit: " + ex.Message, "error");
            }
        }
        else if (e.CommandName == "ToggleStatus")
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string sql = "UPDATE MemberBilling_Subscriptions SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END WHERE SubscriptionID = @ID";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@ID", subscriptionId);
                        con.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

                LoadSubscriptionsGrid(txtSearchKeyword.Text, ddlFilterFinancialHead.SelectedValue, ddlFilterStatus.SelectedValue, ddlFilterCategory.SelectedValue, ddlFilterMembershipType.SelectedValue);
                UpdateKpiStats();
                ShowAlert("Subscription status toggled.", "success");
            }
            catch (Exception ex)
            {
                ShowAlert("Error toggling status: " + ex.Message, "error");
            }
        }
    }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        ResetForm();
        pnlAlert.Visible = false;
    }

    protected void btnCancelEdit_Click(object sender, EventArgs e)
    {
        ResetForm();
        ShowAlert("Edit mode cancelled.", "info");
    }

    private void ResetForm()
    {
        hfSubscriptionID.Value = "0";
        txtSubscriptionName.Text = "";
        txtAmount.Text = "";
        chkAgeBenefit.Checked = false;
        chkCategoryPricing.Checked = false;
        txtTierTitle.Text = "";
        txtMinAge.Text = "";
        txtMaxAge.Text = "";
        txtMinMembershipYears.Text = "";
        txtDiscountPercentage.Text = "";
        txtDiscountFixed.Text = "";
        txtFinancialHead.Text = "";
        txtDescription.Text = "";
        chkIsActive.Checked = true;

        if (ddlCategory.Items.Count > 0) ddlCategory.SelectedIndex = 0;
        if (ddlMembershipType.Items.Count > 0) ddlMembershipType.SelectedIndex = 0;
        txtCategoryRateAmount.Text = "";
        txtBulkRateAmount.Text = "";

        foreach (ListItem item in cblCategories.Items) item.Selected = false;
        foreach (ListItem item in cblMembershipTypes.Items) item.Selected = false;

        // Reset in-memory tables
        ViewState["CurrentBenefitTiers"] = null;
        ViewState["CurrentCategoryRates"] = null;
        BindBenefitTiersGrid();
        BindCategoryRatesGrid();

        GenerateNextSubscriptionCode();

        litFormTitle.Text = "Create New Subscription";
        lblEditModeBadge.Visible = false;
        btnSave.Text = "Save Subscription";
        btnCancelEdit.Visible = false;

        ScriptManager.RegisterStartupScript(this, GetType(), "resetPanelScript", "toggleAgeBenefitPanel(); toggleCategoryPricingPanel(); updateLiveDiscountPreview();", true);
    }

    protected void btnFilter_Click(object sender, EventArgs e)
    {
        LoadSubscriptionsGrid(txtSearchKeyword.Text, ddlFilterFinancialHead.SelectedValue, ddlFilterStatus.SelectedValue, ddlFilterCategory.SelectedValue, ddlFilterMembershipType.SelectedValue);
    }

    protected void btnResetFilter_Click(object sender, EventArgs e)
    {
        txtSearchKeyword.Text = "";
        ddlFilterFinancialHead.SelectedIndex = 0;
        ddlFilterStatus.SelectedIndex = 0;
        if (ddlFilterCategory.Items.Count > 0) ddlFilterCategory.SelectedIndex = 0;
        if (ddlFilterMembershipType.Items.Count > 0) ddlFilterMembershipType.SelectedIndex = 0;

        LoadSubscriptionsGrid();
    }

    private void ShowAlert(string message, string type)
    {
        pnlAlert.Visible = true;
        lblAlertText.Text = message;

        if (type == "success")
        {
            divAlertBox.Attributes["style"] = "padding:6px 12px; border-radius:5px; margin-bottom:8px; font-size:12px; font-weight:600; display:flex; align-items:center; gap:8px; background-color:#ecfdf5; color:#065f46; border:1px solid #a7f3d0;";
        }
        else if (type == "error")
        {
            divAlertBox.Attributes["style"] = "padding:6px 12px; border-radius:5px; margin-bottom:8px; font-size:12px; font-weight:600; display:flex; align-items:center; gap:8px; background-color:#fef2f2; color:#991b1b; border:1px solid #fecaca;";
        }
        else
        {
            divAlertBox.Attributes["style"] = "padding:6px 12px; border-radius:5px; margin-bottom:8px; font-size:12px; font-weight:600; display:flex; align-items:center; gap:8px; background-color:#eff6ff; color:#1e40af; border:1px solid #bfdbfe;";
        }
    }
}
