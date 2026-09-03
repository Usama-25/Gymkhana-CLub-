using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;

public partial class Pos : System.Web.UI.Page
{
    string cons = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // SESSION PROPERTIES
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    private int CounterCloseId
    {
        get
        {
            if (Session["CounterCloseIdForConsumption"] != null && Session["CounterCloseIdForConsumption"].ToString() != "0")
                return Convert.ToInt32(Session["CounterCloseIdForConsumption"]);
            if (Session["CounterCloseId"] != null)
                return Convert.ToInt32(Session["CounterCloseId"]);
            if (ViewState["CounterCloseId"] != null)
                return Convert.ToInt32(ViewState["CounterCloseId"]);
            return 0;
        }
        set
        {
            Session["CounterCloseIdForConsumption"] = value;
            ViewState["CounterCloseId"] = value;
        }
    }

    private int EmpId
    {
        get { return Session["Emp_ID"] != null ? Convert.ToInt32(Session["Emp_ID"]) : 0; }
    }

    private string DepartmentName
    {
        get { return Session["DepartmentName"] != null ? Session["DepartmentName"].ToString() : ""; }
    }

    private string DepartmentId
    {
        get { return Session["DepartmentID"] != null ? Session["DepartmentID"].ToString() : ""; }
    }

    private int CurrentMasterId
    {
        get { return ViewState["CurrentMasterId"] != null ? Convert.ToInt32(ViewState["CurrentMasterId"]) : 0; }
        set { ViewState["CurrentMasterId"] = value; }
    }

    private bool IsAlreadySaved
    {
        get { return ViewState["IsAlreadySaved"] != null && (bool)ViewState["IsAlreadySaved"]; }
        set { ViewState["IsAlreadySaved"] = value; }
    }

    // â”€â”€ FIX: Store DataTable in Session so grid survives postbacks â”€â”€
    private DataTable ConsumptionDT
    {
        get { return Session["ConsumptionDT"] as DataTable; }
        set { Session["ConsumptionDT"] = value; }
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // PAGE LOAD
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            ClearGrids();

            if (Request.QueryString["CCID"] != null && Request.QueryString["CCID"] != "")
            {
                int ccId;
                if (int.TryParse(Request.QueryString["CCID"], out ccId) && ccId > 0)
                {
                    CounterCloseId = ccId;
                    txtCounterCloseId.Text = ccId.ToString();
                    txtCounterCloseId.Enabled = false;
                    btnLoad_Click(null, null);
                }
            }
            else if (CounterCloseId > 0)
            {
                txtCounterCloseId.Text = CounterCloseId.ToString();
                txtCounterCloseId.Enabled = false;
                btnLoad_Click(null, null);
            }

            if (!string.IsNullOrEmpty(DepartmentName))
            {
                lblDeptInfo.Text = "<div class='dept-badge'><i class='fa fa-building'></i> " + DepartmentName + "</div>";
                lblDeptInfo.Visible = true;
            }
        }
        else
        {
            // FIX: On postback (e.g. txtActualQty_TextChanged), rebind grid from Session
            // so TemplateField controls are recreated and FindControl works
            if (ConsumptionDT != null && gvSelectedIngredients.Rows.Count == 0)
            {
                gvSelectedIngredients.DataSource = ConsumptionDT;
                gvSelectedIngredients.DataBind();
                pnlSelectionStats.Visible = true;
            }
        }
    }

    private void ClearGrids()
    {
        gvItems.DataSource = null;
        gvItems.DataBind();
        gvSelectedIngredients.DataSource = null;
        gvSelectedIngredients.DataBind();
        gvAllIngredients.DataSource = null;
        gvAllIngredients.DataBind();
        pnlAllIngredients.Visible = false;
        pnlSelectionStats.Visible = false;
        IsAlreadySaved = false;
        ConsumptionDT = null;
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // LOAD DATA
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    protected void btnLoad_Click(object sender, EventArgs e)
    {
        int id = CounterCloseId;

        if (id == 0)
        {
            if (!int.TryParse(txtCounterCloseId.Text.Trim(), out id) || id == 0)
            {
                ShowAlert("Please enter valid Counter Close ID.", "warning");
                return;
            }
            CounterCloseId = id;
        }

        using (SqlConnection con = new SqlConnection(cons))
        {
            con.Open();

            // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            // 1. Validate CounterClose
            // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            SqlCommand validateCmd = new SqlCommand(@"
            SELECT COUNT(*) 
            FROM CounterClose 
            WHERE CounterCloseId = @Id", con);

            validateCmd.Parameters.AddWithValue("@Id", id);

            if ((int)validateCmd.ExecuteScalar() == 0)
            {
                ShowAlert("Counter Close ID not found.", "error");
                return;
            }

            // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            // 2. Check existing consumption
            // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if (CheckIfConsumptionExists(con, id))
            {
                IsAlreadySaved = true;
                lblLoadedBadge.Text = "CC#{id} (Saved)";
                lblLoadedBadge.Visible = true;

                LoadExistingConsumption(con, id);
                ShowAlert("Consumption already exists.", "info");
                return;
            }

            lblLoadedBadge.Text = "CC #{id}";
            lblLoadedBadge.Visible = true;

            // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            // 3. LOAD BILL ITEMS
            // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            string itemQuery = @"
            SELECT 
                bi.Name,
                SUM(bi.Quantity) AS Quantity
            FROM Bills b
            INNER JOIN BillItems bi ON b.Id = bi.BillId
            WHERE b.CounterCloseId = @Id
              AND b.Status IN ('Paid','GH')";

            if (!string.IsNullOrEmpty(DepartmentId))
                itemQuery += " AND b.DepartmentID = @DeptId";

            itemQuery += " GROUP BY bi.Name ORDER BY bi.Name";

            SqlCommand itemCmd = new SqlCommand(itemQuery, con);
            itemCmd.Parameters.AddWithValue("@Id", id);
            if (!string.IsNullOrEmpty(DepartmentId))
                itemCmd.Parameters.AddWithValue("@DeptId", DepartmentId);

            DataTable itemDt = new DataTable();
            new SqlDataAdapter(itemCmd).Fill(itemDt);

            gvItems.DataSource = itemDt;
            gvItems.DataBind();

            // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            // 4. Missing recipe check
            // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            int missingRecipe = 0;

            foreach (DataRow r in itemDt.Rows)
            {
                SqlCommand chk = new SqlCommand(@"
                SELECT COUNT(*) 
                FROM Restaurant.dbo.MenuItems
                WHERE ItemName = @Name 
                  AND RecipeId IS NOT NULL", con);

                chk.Parameters.AddWithValue("@Name", r["Name"].ToString());

                if ((int)chk.ExecuteScalar() == 0)
                    missingRecipe++;
            }

            // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            // 5. INGREDIENT CALCULATION (FIXED)
            // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            string ingQuery = @"
            SELECT
                rs.ItemName AS IngredientName,
                rs.ItemCode,
                rs.Unit,
                SUM(bi.Quantity * rs.Quantity) AS TotalIngredientQty,
                STORE.dbo.GET_Store_Item_StokNew(rs.ItemCode, @DeptId) AS CurrentStock
            FROM Bills b
            INNER JOIN BillItems bi
                ON b.Id = bi.BillId
            INNER JOIN Restaurant.dbo.MenuItems mi
                ON bi.MenuItemId = mi.Id
            INNER JOIN STORE.dbo.RecipeMain rm
                ON rm.RecipeId = mi.RecipeId
            INNER JOIN STORE.dbo.RecipeSub rs
                ON rs.RecipeId = rm.RecipeId
            WHERE b.CounterCloseId = @Id
              AND b.Status IN ('Paid','GH')
              AND mi.RecipeId IS NOT NULL";

            if (!string.IsNullOrEmpty(DepartmentId))
                ingQuery += " AND b.DepartmentID = @DeptId";

            ingQuery += @"
            GROUP BY rs.ItemName, rs.ItemCode, rs.Unit
            ORDER BY rs.ItemName";

            SqlCommand ingCmd = new SqlCommand(ingQuery, con);
            ingCmd.Parameters.AddWithValue("@Id", id);
            if (!string.IsNullOrEmpty(DepartmentId))
                ingCmd.Parameters.AddWithValue("@DeptId", DepartmentId);

            DataTable ingDt = new DataTable();
            new SqlDataAdapter(ingCmd).Fill(ingDt);

            // IMPORTANT: FIX GRIDVIEW ERROR
            gvAllIngredients.DataSource = ingDt;
            gvAllIngredients.DataBind();

            pnlAllIngredients.Visible = ingDt.Rows.Count > 0;
            lblIngCount.Text = "(" + ingDt.Rows.Count + ")";

            // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            // 6. MESSAGE
            // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            string dept = string.IsNullOrEmpty(DepartmentName) ? "All Departments" : DepartmentName;

            string msg = "Loaded {itemDt.Rows.Count} items | {ingDt.Rows.Count} ingredients for {dept}";
            if (missingRecipe > 0)
                msg += " | {missingRecipe} items missing recipe";

            ShowAlert(msg, missingRecipe > 0 ? "warning" : "success");
        }
    }

    private bool CheckIfConsumptionExists(SqlConnection con, int counterCloseId)
    {
        string query = "SELECT COUNT(*) FROM Consumption_Master WHERE CounterCloseId = @CCId";
        if (!string.IsNullOrEmpty(DepartmentId))
            query += " AND DepartmentId = @DeptId";

        SqlCommand cmd = new SqlCommand(query, con);
        cmd.Parameters.AddWithValue("@CCId", counterCloseId);
        if (!string.IsNullOrEmpty(DepartmentId))
            cmd.Parameters.AddWithValue("@DeptId", DepartmentId);

        return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
    }

    private void LoadExistingConsumption(SqlConnection con, int counterCloseId)
    {
        string query = @"
            SELECT cm.Id as MasterId, cd.IngredientName, cd.ItemCode, cd.Unit,
                   cd.ExpectedQty, cd.ActualQty, cd.DifferenceQty, cd.Remarks,
                   STORE.dbo.GET_Store_Item_StokNew(cd.ItemCode, @DeptId) AS CurrentStock
            FROM Consumption_Details cd
            INNER JOIN Consumption_Master cm ON cd.MasterId = cm.Id
            WHERE cm.CounterCloseId = @CCId";

        if (!string.IsNullOrEmpty(DepartmentId))
            query += " AND cm.DepartmentId = @DeptId";

        SqlCommand cmd = new SqlCommand(query, con);
        cmd.Parameters.AddWithValue("@CCId", counterCloseId);
        if (!string.IsNullOrEmpty(DepartmentId))
            cmd.Parameters.AddWithValue("@DeptId", DepartmentId);

        SqlDataAdapter da = new SqlDataAdapter(cmd);
        DataTable dt = new DataTable();
        da.Fill(dt);

        if (dt.Rows.Count > 0)
        {
            CurrentMasterId = Convert.ToInt32(dt.Rows[0]["MasterId"]);
            DataTable displayDt = BuildDisplayTable();

            foreach (DataRow row in dt.Rows)
            {
                decimal expectedQty = GetDecimal(row, "ExpectedQty");
                decimal actualQty = GetDecimal(row, "ActualQty");
                decimal variance = actualQty - expectedQty;
                decimal currentStock = GetDecimal(row, "CurrentStock");
                string autoStatus = ComputeStatus(actualQty, expectedQty);

                displayDt.Rows.Add(
                    row["IngredientName"].ToString(),
                    row["ItemCode"] != DBNull.Value ? row["ItemCode"].ToString() : "",
                    row["Unit"] != DBNull.Value ? row["Unit"].ToString() : "",
                    expectedQty,
                    actualQty,
                    variance,
                    row["Remarks"] != DBNull.Value ? row["Remarks"].ToString() : autoStatus,
                    currentStock,
                    autoStatus
                );
            }

            // FIX: Save to Session for postback persistence
            ConsumptionDT = displayDt;

            gvSelectedIngredients.DataSource = displayDt;
            gvSelectedIngredients.DataBind();
            UpdateSelectionStats(displayDt);
        }
    }

    private DataTable BuildDisplayTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("IngredientName");
        dt.Columns.Add("ItemCode");
        dt.Columns.Add("Unit");
        dt.Columns.Add("TotalIngredientQty", typeof(decimal));
        dt.Columns.Add("ActualQty", typeof(decimal));
        dt.Columns.Add("Variance", typeof(decimal));
        dt.Columns.Add("Remarks");
        dt.Columns.Add("CurrentStock", typeof(decimal));
        dt.Columns.Add("AutoStatus");
        return dt;
    }

    private decimal GetDecimal(DataRow row, string col)
    {
        return row[col] != DBNull.Value ? Convert.ToDecimal(row[col]) : 0m;
    }

    private string ComputeStatus(decimal actual, decimal expected)
    {
        if (actual == 0m && expected > 0m) return "Missing Entry";
        if (actual == expected) return "Normal";
        if (actual > expected) return "Over Usage";
        return "Under Usage";
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // ROW DATA BOUND
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    protected void gvSelectedIngredients_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;

        DataRowView drv = e.Row.DataItem as DataRowView;
        if (drv == null) return;

        decimal expected = drv.Row.Table.Columns.Contains("TotalIngredientQty") && drv["TotalIngredientQty"] != DBNull.Value
                           ? Convert.ToDecimal(drv["TotalIngredientQty"]) : 0m;
        decimal actual = drv.Row.Table.Columns.Contains("ActualQty") && drv["ActualQty"] != DBNull.Value
                           ? Convert.ToDecimal(drv["ActualQty"]) : expected;

        decimal variance = actual - expected;

        Label lblVar = (Label)e.Row.FindControl("lblVariance");
        HiddenField hfVar = (HiddenField)e.Row.FindControl("hfVariance");
        DropDownList ddlRem = (DropDownList)e.Row.FindControl("ddlRemarks");

        // FIX: Set hidden raw expected qty for save
        HiddenField hfExpQty = (HiddenField)e.Row.FindControl("hfExpectedQty");
        if (hfExpQty != null) hfExpQty.Value = expected.ToString();

        if (hfVar != null) hfVar.Value = variance.ToString();

        if (lblVar != null)
        {
            if (variance > 0)
            { lblVar.Text = "+" + variance.ToString("N3"); lblVar.CssClass = "var-save"; }
            else if (variance < 0)
            { lblVar.Text = variance.ToString("N3"); lblVar.CssClass = "var-over"; }
            else
            { lblVar.Text = "0.000"; lblVar.CssClass = "var-zero"; }
        }

        string autoStatus = ComputeStatus(actual, expected);
        string savedRemark = autoStatus;
        if (drv.Row.Table.Columns.Contains("Remarks") && drv["Remarks"] != null && drv["Remarks"] != DBNull.Value && drv["Remarks"].ToString() != "")
            savedRemark = drv["Remarks"].ToString();

        if (ddlRem != null)
        {
            ListItem li = ddlRem.Items.FindByValue(savedRemark);
            if (li != null) { ddlRem.ClearSelection(); li.Selected = true; }
        }
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // FIX: Smart decimal formatting
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    protected string FormatQty(object value, object unitObj)
    {
        if (value == DBNull.Value || value == null) return "0.000";
        decimal result;
        if (!decimal.TryParse(value.ToString(), out result)) return "0.000";

        string unit = unitObj != null && unitObj != DBNull.Value ? unitObj.ToString().ToLower().Trim() : "";

        if (unit == "pcs" || unit == "pieces" || unit == "nos" || unit == "number")
            return result.ToString("N0");

        if (unit == "tsp" || unit == "tbsp" || unit == "ml" || unit == "l" || unit == "liter" || unit == "litre")
            return result.ToString("N2");

        return result.ToString("N3");
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // CHECK ALL
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    protected void chkAll_CheckedChanged(object sender, EventArgs e)
    {
        CheckBox chkAll = (CheckBox)gvItems.HeaderRow.FindControl("chkAll");
        foreach (GridViewRow row in gvItems.Rows)
        {
            CheckBox chk = (CheckBox)row.FindControl("chkSelect");
            if (chk != null) chk.Checked = chkAll.Checked;
        }
        UpdateSelectionCountLabel();
    }

    private void UpdateSelectionCountLabel()
    {
        int count = 0;
        foreach (GridViewRow row in gvItems.Rows)
        {
            CheckBox chk = (CheckBox)row.FindControl("chkSelect");
            if (chk != null && chk.Checked) count++;
        }
        lblSelectedCount.Text = count.ToString();
    }

    private void UpdateSelectionStats(DataTable dt)
    {
        if (dt == null || dt.Rows.Count == 0)
        {
            pnlSelectionStats.Visible = false;
            return;
        }

        int normal = 0, overUse = 0, underUse = 0, missing = 0;
        foreach (DataRow r in dt.Rows)
        {
            string s = r.Table.Columns.Contains("AutoStatus") && r["AutoStatus"] != DBNull.Value ? r["AutoStatus"].ToString() : "";
            switch (s)
            {
                case "Normal": normal++; break;
                case "Over Usage": overUse++; break;
                case "Under Usage": underUse++; break;
                case "Missing Entry": missing++; break;
            }
        }

        lblStatsNormal.Text = normal.ToString();
        lblStatsOver.Text = overUse.ToString();
        lblStatsUnder.Text = underUse.ToString();
        lblStatsMissing.Text = missing.ToString();
        lblStatsTotalIng.Text = dt.Rows.Count.ToString();
        lblStatsPending.Text = dt.Rows.Count.ToString();
        pnlSelectionStats.Visible = true;
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // SHOW INGREDIENTS
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    protected void btnShowIngredients_Click(object sender, EventArgs e)
    {
        int id = CounterCloseId;
        if (id == 0) { ShowAlert("Please load data first.", "warning"); return; }

        List<string> selectedItems = new List<string>();
        foreach (GridViewRow row in gvItems.Rows)
        {
            CheckBox chk = (CheckBox)row.FindControl("chkSelect");
            if (chk != null && chk.Checked)
            {
                // FIX: Use HiddenField hfItemName for reliable item name extraction
                HiddenField hfItemName = (HiddenField)row.FindControl("hfItemName");
                string name = hfItemName != null ? hfItemName.Value.Trim() : "";

                // Fallback: try BoundField cell if HiddenField missing
                if (string.IsNullOrEmpty(name))
                    name = row.Cells[1].Text.Trim().Replace("&nbsp;", "").Trim();

                if (!string.IsNullOrEmpty(name))
                    selectedItems.Add(name.Replace("'", "''"));
            }
        }

        if (selectedItems.Count == 0) { ShowAlert("Please select at least one item.", "warning"); return; }

        string selected = string.Join(",", selectedItems.ConvertAll(s => "'" + s + "'"));

        using (SqlConnection con = new SqlConnection(cons))
        {
            con.Open();
            string query = @"
SELECT
    rs.ItemName AS IngredientName,
    rs.ItemCode,
    rs.Unit,
    SUM(bi.Quantity * rs.Quantity) AS TotalIngredientQty,
    STORE.dbo.GET_Store_Item_StokNew(rs.ItemCode, @DeptId) AS CurrentStock
FROM Bills b
INNER JOIN BillItems bi ON b.Id = bi.BillId
INNER JOIN Restaurant.dbo.MenuItems mi ON bi.MenuItemId = mi.Id
INNER JOIN STORE.dbo.RecipeMain rm ON rm.RecipeId = mi.RecipeId
INNER JOIN STORE.dbo.RecipeSub rs ON rs.RecipeId = rm.RecipeId
WHERE b.CounterCloseId = @Id
  AND b.Status IN ('Paid','GH')
";

            if (!string.IsNullOrEmpty(DepartmentId))
                query += " AND b.DepartmentID = @DeptId";

            query += " GROUP BY rs.ItemName, rs.ItemCode, rs.Unit ORDER BY rs.ItemName";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@Id", id);
            if (!string.IsNullOrEmpty(DepartmentId))
                cmd.Parameters.AddWithValue("@DeptId", DepartmentId);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            if (dt.Rows.Count == 0)
            {
                ShowAlert("No ingredients found. Ensure MenuItems.RecipeId is linked.", "warning");
                return;
            }

            dt.Columns.Add("ActualQty", typeof(decimal));
            dt.Columns.Add("Variance", typeof(decimal));
            dt.Columns.Add("Remarks", typeof(string));
            dt.Columns.Add("AutoStatus", typeof(string));

            foreach (DataRow r in dt.Rows)
            {
                decimal expected = r["TotalIngredientQty"] != DBNull.Value ? Convert.ToDecimal(r["TotalIngredientQty"]) : 0m;
                decimal actual = expected;
                decimal variance = 0m;
                string status = ComputeStatus(actual, expected);

                r["ActualQty"] = actual;
                r["Variance"] = variance;
                r["Remarks"] = status;
                r["AutoStatus"] = status;
            }

            // FIX: Persist for postback survival
            ConsumptionDT = dt;

            gvSelectedIngredients.DataSource = dt;
            gvSelectedIngredients.DataBind();
            UpdateSelectionStats(dt);

            lblSelectedCount.Text = selectedItems.Count.ToString();
            pnlSelectionStats.Visible = true;

            ShowAlert(
                "Loaded " + dt.Rows.Count + " ingredients for " + selectedItems.Count + " item(s). Adjust Actual quantities as needed.",
                "success");
        }
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // ACTUAL QTY CHANGED
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    protected void txtActualQty_TextChanged(object sender, EventArgs e)
    {
        TextBox txt = (TextBox)sender;
        GridViewRow row = (GridViewRow)txt.NamingContainer;

        Label lblVar = (Label)row.FindControl("lblVariance");
        HiddenField hfVar = (HiddenField)row.FindControl("hfVariance");
        DropDownList ddlRem = (DropDownList)row.FindControl("ddlRemarks");

        // FIX: Read expected from HiddenField, not cell text (TemplateField cell text = empty)
        HiddenField hfExpQty = (HiddenField)row.FindControl("hfExpectedQty");
        decimal expected = 0;
        if (hfExpQty != null)
            decimal.TryParse(hfExpQty.Value, out expected);
        else
        {
            // fallback
            decimal.TryParse(row.Cells[3].Text.Replace(",", ""), out expected);
        }

        decimal actual;
        if (!decimal.TryParse(txt.Text, out actual) || actual < 0)
        {
            ShowAlert("Invalid actual quantity. Please enter a non-negative number.", "warning");
            txt.Text = expected.ToString("N3");
            actual = expected;
        }

        decimal variance = actual - expected;
        if (hfVar != null) hfVar.Value = variance.ToString();

        if (lblVar != null)
        {
            if (variance > 0)
            { lblVar.Text = "+" + variance.ToString("N3"); lblVar.CssClass = "var-save"; }
            else if (variance < 0)
            { lblVar.Text = variance.ToString("N3"); lblVar.CssClass = "var-over"; }
            else
            { lblVar.Text = "0.000"; lblVar.CssClass = "var-zero"; }
        }

        string autoRemark = ComputeStatus(actual, expected);
        if (ddlRem != null)
        {
            ListItem li = ddlRem.Items.FindByValue(autoRemark);
            if (li != null) { ddlRem.ClearSelection(); li.Selected = true; }
        }

        // FIX: Update the Session DataTable with new actual values
        UpdateSessionDT(row.RowIndex, actual, variance, autoRemark);
    }

    // FIX: Keep Session DataTable in sync with user edits
    private void UpdateSessionDT(int rowIndex, decimal actual, decimal variance, string status)
    {
        DataTable dt = ConsumptionDT;
        if (dt == null || rowIndex >= dt.Rows.Count) return;
        dt.Rows[rowIndex]["ActualQty"] = actual;
        dt.Rows[rowIndex]["Variance"] = variance;
        dt.Rows[rowIndex]["AutoStatus"] = status;
        ConsumptionDT = dt;
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // SAVE CONSUMPTION â€” FIX: use HiddenFields for all TemplateField values
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    protected void btnSave_Click(object sender, EventArgs e)
    {
        int counterCloseId = CounterCloseId;
        int empId = EmpId;

        if (counterCloseId == 0)
        { ShowAlert("Invalid Counter Close ID. Please load data first.", "error"); return; }

        if (gvSelectedIngredients.Rows.Count == 0)
        { ShowAlert("No ingredient data to save.", "warning"); return; }

        List<string> validationErrors = new List<string>();
        foreach (GridViewRow row in gvSelectedIngredients.Rows)
        {
            if (row.RowType != DataControlRowType.DataRow) continue;
            TextBox txtActual = (TextBox)row.FindControl("txtActualQty");

            // FIX: Get ingredient name from HiddenField, not cell text
            HiddenField hfIngName = (HiddenField)row.FindControl("hfIngredientName");
            string ingName = hfIngName != null ? hfIngName.Value : "Row " + row.RowIndex;

            if (txtActual != null && !string.IsNullOrWhiteSpace(txtActual.Text))
            {
                decimal actualCheck;
                if (!decimal.TryParse(txtActual.Text, out actualCheck) || actualCheck < 0)
                    validationErrors.Add(ingName + ": invalid quantity");
            }
        }

        if (validationErrors.Count > 0)
        {
            ShowAlert("Fix these before saving: " + string.Join(" | ", validationErrors), "error");
            return;
        }

        using (SqlConnection con = new SqlConnection(cons))
        {
            con.Open();
            SqlTransaction transaction = con.BeginTransaction();

            try
            {
                int masterId = CurrentMasterId;

                if (masterId == 0)
                {
                    string checkQuery = "SELECT Id FROM Consumption_Master WHERE CounterCloseId = @CCId";
                    if (!string.IsNullOrEmpty(DepartmentId))
                        checkQuery += " AND DepartmentId = @DeptId";

                    SqlCommand checkCmd = new SqlCommand(checkQuery, con, transaction);
                    checkCmd.Parameters.AddWithValue("@CCId", counterCloseId);
                    if (!string.IsNullOrEmpty(DepartmentId))
                        checkCmd.Parameters.AddWithValue("@DeptId", DepartmentId);

                    object existingId = checkCmd.ExecuteScalar();

                    if (existingId != null)
                    {
                        masterId = Convert.ToInt32(existingId);
                        CurrentMasterId = masterId;
                        new SqlCommand("DELETE FROM Consumption_Details WHERE MasterId = @MasterId", con, transaction) { Parameters = { new SqlParameter("@MasterId", masterId) } }
                            .ExecuteNonQuery();
                    }
                    else
                    {
                        string insertMaster = @"
                            INSERT INTO Consumption_Master 
                            (CounterCloseId, DepartmentId, DepartmentName, CreatedBy, Status, IsFullyConsumed, CreatedDate)
                            VALUES (@CCId, @DeptId, @DeptName, @CreatedBy, 'Active', 0, GETDATE());
                            SELECT SCOPE_IDENTITY();";

                        SqlCommand masterCmd = new SqlCommand(insertMaster, con, transaction);
                        masterCmd.Parameters.AddWithValue("@CCId", counterCloseId);
                        masterCmd.Parameters.AddWithValue("@DeptId", string.IsNullOrEmpty(DepartmentId) ? (object)DBNull.Value : DepartmentId);
                        masterCmd.Parameters.AddWithValue("@DeptName", string.IsNullOrEmpty(DepartmentName) ? (object)"All Departments" : DepartmentName);
                        masterCmd.Parameters.AddWithValue("@CreatedBy", empId);

                        object newId = masterCmd.ExecuteScalar();
                        if (newId == null || newId == DBNull.Value)
                            throw new Exception("Failed to create Consumption_Master record.");

                        masterId = Convert.ToInt32(newId);
                        CurrentMasterId = masterId;
                    }
                }
                else
                {
                    new SqlCommand("DELETE FROM Consumption_Details WHERE MasterId = @MasterId", con, transaction) { Parameters = { new SqlParameter("@MasterId", masterId) } }
                        .ExecuteNonQuery();
                }

                int savedCount = 0;
                foreach (GridViewRow row in gvSelectedIngredients.Rows)
                {
                    if (row.RowType != DataControlRowType.DataRow) continue;

                    // â”€â”€ FIX: All values read from HiddenFields, not cell text â”€â”€
                    HiddenField hfIngName = (HiddenField)row.FindControl("hfIngredientName");
                    HiddenField hfExpQty = (HiddenField)row.FindControl("hfExpectedQty");
                    HiddenField hfItemCode = (HiddenField)row.FindControl("hfItemCode");
                    HiddenField hfUnit = (HiddenField)row.FindControl("hfUnit");
                    TextBox txtActual = (TextBox)row.FindControl("txtActualQty");
                    DropDownList ddlRemarks = (DropDownList)row.FindControl("ddlRemarks");

                    string ingredientName = hfIngName != null ? hfIngName.Value.Trim() : "";
                    if (string.IsNullOrEmpty(ingredientName)) continue; // Skip rows with no name

                    decimal expectedQty = 0;
                    if (hfExpQty != null) decimal.TryParse(hfExpQty.Value, out expectedQty);

                    decimal actualQty = 0;
                    if (txtActual != null && !string.IsNullOrEmpty(txtActual.Text))
                        decimal.TryParse(txtActual.Text, out actualQty);

                    decimal variance = actualQty - expectedQty;
                    string remarks = ddlRemarks != null ? ddlRemarks.SelectedValue : ComputeStatus(actualQty, expectedQty);
                    string itemCode = hfItemCode != null ? hfItemCode.Value : "";
                    string unit = hfUnit != null ? hfUnit.Value : "";
                    string autoStatus = ComputeStatus(actualQty, expectedQty);

                    SqlCommand detailCmd = new SqlCommand(@"
                        INSERT INTO Consumption_Details 
                        (MasterId, IngredientName, ItemCode, Unit, ExpectedQty, ActualQty, DifferenceQty, Remarks, AutoStatus)
                        VALUES (@MasterId, @IngredientName, @ItemCode, @Unit, @ExpectedQty, @ActualQty, @DifferenceQty, @Remarks, @AutoStatus)",
                        con, transaction);

                    detailCmd.Parameters.AddWithValue("@MasterId", masterId);
                    detailCmd.Parameters.AddWithValue("@IngredientName", ingredientName);
                    detailCmd.Parameters.AddWithValue("@ItemCode", string.IsNullOrEmpty(itemCode) ? (object)DBNull.Value : itemCode);
                    detailCmd.Parameters.AddWithValue("@Unit", string.IsNullOrEmpty(unit) ? (object)DBNull.Value : unit);
                    detailCmd.Parameters.AddWithValue("@ExpectedQty", expectedQty);
                    detailCmd.Parameters.AddWithValue("@ActualQty", actualQty);
                    detailCmd.Parameters.AddWithValue("@DifferenceQty", variance);
                    detailCmd.Parameters.AddWithValue("@Remarks", remarks);
                    detailCmd.Parameters.AddWithValue("@AutoStatus", autoStatus);
                    detailCmd.ExecuteNonQuery();
                    savedCount++;
                }

                if (savedCount == 0)
                    throw new Exception("No records were saved. IngredientName values may be missing â€” check hfIngredientName hidden fields in the grid.");

                SqlCommand flagCmd = new SqlCommand(@"
                    UPDATE Consumption_Master 
                    SET IsFullyConsumed = 1, UpdatedDate = GETDATE()
                    WHERE Id = @MasterId", con, transaction);
                flagCmd.Parameters.AddWithValue("@MasterId", masterId);
                flagCmd.ExecuteNonQuery();

                transaction.Commit();
                IsAlreadySaved = true;
                ConsumptionDT = null; // Clear so fresh load re-fetches

                string deptDisplay = string.IsNullOrEmpty(DepartmentName) ? "All Departments" : DepartmentName;
                ShowAlert("Saved " + savedCount + " consumption records for " + deptDisplay + ".", "success");
                btnLoad_Click(null, null);
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                ShowAlert("Error saving: " + ex.Message, "error");
                System.Diagnostics.Debug.WriteLine("Save Error: " + ex);
            }
        }
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // STOCK BADGE
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    protected string GetStockBadge(object stockVal, object expectedVal)
    {
        decimal stock = stockVal != null && stockVal != DBNull.Value ? Convert.ToDecimal(stockVal) : 0m;
        decimal expected = expectedVal != null && expectedVal != DBNull.Value ? Convert.ToDecimal(expectedVal) : 0m;

        string css;
        if (stock <= 0) css = "stock-zero";
        else if (stock < expected) css = "stock-low";
        else css = "stock-ok";

        return string.Format("<span class='{0}'>{1}</span>", css, stock.ToString("N3"));
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // SHOW ALERT
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    private void ShowAlert(string message, string type = "info")
    {
        string icon;
        string cssClass = "alert-box";

        switch (type)
        {
            case "success": cssClass += " alert-success"; icon = "fa-circle-check"; break;
            case "error": cssClass += " alert-error"; icon = "fa-circle-xmark"; break;
            case "warning": cssClass += " alert-warning"; icon = "fa-triangle-exclamation"; break;
            default: cssClass += " alert-info"; icon = "fa-circle-info"; break;
        }

        pnlAlertMain.Visible = true;
        divAlertMain.Attributes["class"] = cssClass;
        lblAlertMain.Text = "<i class='fas " + icon + "'></i><span class='atxt'>" + Server.HtmlEncode(message) + "</span>";
    }
}

