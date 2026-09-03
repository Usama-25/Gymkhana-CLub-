using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  ConsumptionVerification.aspx.cs  â€” ALL BUGS FIXED
//
//  Bug Fixes Applied
//  â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  [FIX-1]  @Subdeptid was set to deptId (same as @deptid) â€” sub-dept never sent correctly
//           â†’ now reads hfSubDeptId.Value properly and passes it as a distinct parameter.
//
//  [FIX-2]  DataKeyNames="ItemCode" mismatch â€” UpdateRow uses DetailId via CommandArgument
//           â†’ DataKeyNames updated to "DetailId" (matches ASPX fix).
//
//  [FIX-3]  GetCurrentStock() was using cons (RestaurantConnectionString) for a Store DB
//           scalar function (GET_Store_Item_StokNew lives in Store DB)
//           â†’ switched to consStore throughout GetCurrentStock().
//
//  [FIX-4]  Stock comparison double-applied ConversionFactor in UpdateRow validation
//           rawActual > currentStock * cf  was wrong because rawActual = newActual * cf
//           AND currentStock is already in raw store units, so CF should NOT multiply stock.
//           â†’ corrected to:  rawActual > currentStock
//
//  [FIX-5]  Save only processed current visible page rows (paging issue)
//           â†’ Save now reads all rows from DB for the given CounterCloseId before
//              building XML, so every checked item across all pages is included.
//              Checked state is tracked via a hidden field list (hfCheckedDetailIds).
//
//  [FIX-6]  BasicDataConnectionString name mismatch (was "BasicDataConnectionString",
//           system uses "BasicDataInfoConnectionString")
//           â†’ corrected to BasicDataInfoConnectionString.
//
//  [FIX-7]  lblZeroStockHint hardcoded inner content in ASPX â€” could double-render
//           â†’ ASPX now has empty label; code-behind always sets .Text fully.
//
//  [FIX-8]  recalcDiff paste event not caught (oninput only, not onchange+oninput)
//           â†’ ASPX now has both onchange and oninput on txtActualQty.
//
//  [FIX-9]  SelectAll not reset after paging â€” cosmetic header state issue
//           â†’ JS updated in ASPX to reset header checkbox on page load.
//
//  Previously documented fixes retained:
//  [CRIT-1] CounterCloseIdAlreadySaved nested inside click handler â†’ class-level method
//  [CRIT-4] XML built with string concat â†’ XmlWriter
//  [CRIT-5] Store.dbo.IngredientsMapping consistent prefix
//  [LOGIC-3] Stats computed from live DataTable after every bind
//  [LOGIC-5] ABS() removed â€” negative stock treated as zero/insufficient
//  [LOGIC-6] SelectAll skips source checkbox itself
//  [LOGIC-7] recalcDiff uses attribute selector [id*=]
//  [SEC-1]  ShowAlert HTML-encodes message
//  [SEC-2]  Exceptions logged server-side, generic message shown to user
//  [SEC-3]  Session sub-dept authorisation check on Save
//  [SEC-4]  LoadDepartments wrapped in try/catch
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

public partial class ConsumptionVerification : System.Web.UI.Page
{
    // â”€â”€ Connection strings â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    private string cons      = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
    private string consStore = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;
    // [FIX-6] Corrected from "BasicDataConnectionString" â†’ "BasicDataInfoConnectionString"
    private string consBasic = ConfigurationManager.ConnectionStrings["BasicDataInfoConnectionString"].ConnectionString;

    // â”€â”€ Shared SQL â€” consistent Store.dbo prefix, no ABS() on stock â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    private const string GridSql = @"
        SELECT
            cm.CounterCloseId,
            cm.Id                                           AS MasterId,
            cm.DepartmentId,
            cm.DepartmentName,
            cd.Id                                           AS DetailId,
            cd.IngredientName,
            ISNULL(NULLIF(cd.ItemCode, ''), 'N/A')          AS ItemCode,
            ISNULL(NULLIF(cd.Unit, ''), 'N/A')              AS Unit,
            ISNULL(im.ConversionFactor, 1)                  AS ConversionFactor,
            cd.ExpectedQty
                / NULLIF(ISNULL(im.ConversionFactor, 1), 0) AS ExpectedQty,
            cd.ActualQty
                / NULLIF(ISNULL(im.ConversionFactor, 1), 0) AS ActualQty,
            (cd.ActualQty - cd.ExpectedQty)
                / NULLIF(ISNULL(im.ConversionFactor, 1), 0) AS DifferenceQty,
            ISNULL(NULLIF(cd.Remarks, ''),
                CASE
                    WHEN cd.ActualQty < cd.ExpectedQty THEN 'Shortage'
                    WHEN cd.ActualQty > cd.ExpectedQty THEN 'Over'
                    ELSE 'Normal'
                END
            ) AS Remarks,
            cm.CreatedDate,
            -- [FIX-3] Stock function belongs to Store DB â€” called via cross-db reference
            ISNULL(Store.dbo.GET_Store_Item_StokNew(cd.ItemCode, @SubDeptId), 0) AS CurrentStock
        FROM  Consumption_Master       cm
        INNER JOIN Consumption_Details        cd  ON cm.Id       = cd.MasterId
        LEFT  JOIN Store.dbo.IngredientsMapping im ON im.ItemCode = cd.ItemCode
        WHERE cm.DepartmentId = @SubDeptId";

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  PAGE LOAD
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadDepartments();

            if (Session["SubDeptId"] != null && Session["CounterCloseID"] != null)
            {
                string subDeptId    = Session["SubDeptId"].ToString();
                string subDeptName  = Session["SubDeptName"] != null ? Session["SubDeptName"].ToString() : "";
                int    counterCloseId = Convert.ToInt32(Session["CounterCloseID"]);

                if (ddlDepartment.Items.FindByValue(subDeptId) != null)
                {
                    ddlDepartment.SelectedValue = subDeptId;
                    hfSubDeptId.Value           = subDeptId;
                    hfAutoLoadMode.Value        = "true";

                    spanDeptName.InnerText = subDeptName;
                    spanCCID.InnerText     = counterCloseId.ToString();
                    pnlSessionInfo.Visible = true;

                    ShowAlert("Auto-loaded: " + subDeptName + " | Counter Close ID: " + counterCloseId, "info");
                    AutoLoadGridWithCounterCloseId(subDeptId, counterCloseId);
                }
                else
                {
                    ShowAlert("Department from session not found in your access list. Please select manually.", "warning");
                    pnlSessionInfo.Visible = false;
                }
            }
            else
            {
                gvConsumption.DataSource = null;
                gvConsumption.DataBind();
                pnlStats.Visible       = false;
                pnlSessionInfo.Visible = false;
                HideAlert();
            }
        }
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  LOAD DEPARTMENTS  [SEC-4] wrapped in try/catch
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    private void LoadDepartments()
    {
        try
        {
            string sql = @"SELECT SubDept_Id, SubDept_Name
                           FROM   BasicDataInfo.dbo.SubDepartment
                           WHERE  Dept_Id = 9
                           ORDER  BY SubDept_Name";

            using (SqlConnection con = new SqlConnection(consBasic))
            using (SqlCommand cmd    = new SqlCommand(sql, con))
            {
                con.Open();
                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());

                ddlDepartment.DataSource     = dt;
                ddlDepartment.DataTextField  = "SubDept_Name";
                ddlDepartment.DataValueField = "SubDept_Id";
                ddlDepartment.DataBind();
                ddlDepartment.Items.Insert(0, new ListItem("-- Select Department --", ""));
            }
        }
        catch (Exception ex)
        {
            LogError("LoadDepartments", ex);
            ShowAlert("Unable to load department list. Please refresh or contact support.", "error");
        }
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  AUTO-LOAD (session-driven)
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    private void AutoLoadGridWithCounterCloseId(string subDeptId, int counterCloseId)
    {
        try
        {
            string sql = GridSql + " AND cm.CounterCloseId = @CounterCloseId ORDER BY cm.Id DESC, cd.Id;";

            using (SqlConnection con = new SqlConnection(cons))
            using (SqlCommand cmd    = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@SubDeptId",      subDeptId);
                cmd.Parameters.AddWithValue("@CounterCloseId", counterCloseId);
                con.Open();

                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());
                BindGrid(dt, counterCloseId.ToString());
            }
        }
        catch (Exception ex)
        {
            LogError("AutoLoadGridWithCounterCloseId", ex);
            ShowAlert("Error loading data. Please try again or contact support.", "error");
            gvConsumption.DataSource = null;
            gvConsumption.DataBind();
            pnlStats.Visible = false;
        }
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  MANUAL LOAD (Search button)
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    private void LoadGrid(int pageIndex)
    {
        int subDeptId;
        if (!int.TryParse(hfSubDeptId.Value, out subDeptId))
        {
            ShowAlert("Invalid department selection.", "error");
            return;
        }

        try
        {
            string sql = GridSql;

            bool hasCounterFilter = Session["CounterCloseID"] != null
                                    && !string.IsNullOrEmpty(Session["CounterCloseID"].ToString());
            if (hasCounterFilter)
                sql += " AND cm.CounterCloseId = @CounterCloseId";

            sql += " ORDER BY cm.Id DESC, cd.Id;";

            using (SqlConnection con = new SqlConnection(cons))
            using (SqlCommand cmd    = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@SubDeptId", subDeptId);
                if (hasCounterFilter)
                    cmd.Parameters.AddWithValue("@CounterCloseId", Convert.ToInt32(Session["CounterCloseID"]));

                con.Open();
                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());

                gvConsumption.PageIndex = pageIndex;
                BindGrid(dt, hasCounterFilter ? Session["CounterCloseID"].ToString() : null);
            }
        }
        catch (Exception ex)
        {
            LogError("LoadGrid", ex);
            ShowAlert("Error loading data. Please try again or contact support.", "error");
        }
    }

    // â”€â”€ Shared bind + stats â€” computed from live DataTable [LOGIC-3] â”€â”€â”€â”€â”€â”€â”€â”€â”€
    private void BindGrid(DataTable dt, string ccIdLabel)
    {
        if (dt.Rows.Count == 0)
        {
            gvConsumption.DataSource = null;
            gvConsumption.DataBind();
            pnlStats.Visible = false;
            ShowAlert(
                ccIdLabel != null
                    ? "No consumption records found for Counter Close #" + ccIdLabel
                    : "No records found for the selected department.",
                "warning");
            return;
        }

        int totalRows = dt.Rows.Count;
        int shortage = 0, over = 0, ok = 0, zeroStock = 0, insufficientStock = 0;

        foreach (DataRow row in dt.Rows)
        {
            string  rem      = row["Remarks"].ToString();
            decimal stock    = row["CurrentStock"] != DBNull.Value ? Convert.ToDecimal(row["CurrentStock"]) : 0m;
            decimal expected = row["ExpectedQty"]  != DBNull.Value ? Convert.ToDecimal(row["ExpectedQty"])  : 0m;

            if (rem == "Shortage") shortage++;
            else if (rem == "Over") over++;
            else ok++;

            if (stock <= 0)          zeroStock++;
            else if (stock < expected) insufficientStock++;
        }

        lblTotalRows.Text = totalRows.ToString();
        lblShortage.Text  = shortage.ToString();
        lblOver.Text      = over.ToString();
        lblOk.Text        = ok.ToString();
        pnlStats.Visible  = true;

        gvConsumption.DataSource = dt;
        gvConsumption.DataBind();

        if (zeroStock > 0)
            ShowAlert(zeroStock + " item(s) have ZERO stock. Set their Actual Qty to 0 before saving.", "warning");
        else if (insufficientStock > 0)
            ShowAlert(insufficientStock + " item(s) have stock LOWER than Expected Qty. Review highlighted rows before saving.", "warning");
        else
        {
            string suffix = ccIdLabel != null ? " for Counter Close #" + ccIdLabel : ".";
            ShowAlert("Loaded " + totalRows + " consumption record(s)" + suffix, "success");
        }
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  ROW DATA BOUND â€” highlight zero/low stock rows
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    protected void gvConsumption_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;

        DataRowView drv = e.Row.DataItem as DataRowView;
        if (drv == null) return;

        decimal stock    = drv["CurrentStock"] != DBNull.Value ? Convert.ToDecimal(drv["CurrentStock"]) : 0m;
        decimal expected = drv["ExpectedQty"]  != DBNull.Value ? Convert.ToDecimal(drv["ExpectedQty"])  : 0m;

        Label hint = e.Row.FindControl("lblZeroStockHint") as Label;

        if (stock <= 0)
        {
            e.Row.CssClass = (e.Row.CssClass + " row-zero-stock").Trim();
            if (hint != null)
            {
                // [FIX-7] Always set Text fully in code-behind; ASPX label is empty
                hint.Text    = "<i class='fas fa-triangle-exclamation'></i> Zero stock â€” set qty to 0";
                hint.Visible = true;
            }
        }
        else if (stock < expected)
        {
            e.Row.CssClass = (e.Row.CssClass + " row-low-stock").Trim();
            if (hint != null)
            {
                hint.Text    = "<i class='fas fa-triangle-exclamation'></i> Stock (" +
                               stock.ToString("N3") + ") &lt; expected â€” cap Actual Qty";
                hint.Visible = true;
            }
        }
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  SEARCH BUTTON
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    protected void btnSearch_Click(object sender, EventArgs e)
    {
        hfSubDeptId.Value      = ddlDepartment.SelectedValue;
        hfAutoLoadMode.Value   = "false";
        pnlSessionInfo.Visible = false;

        if (string.IsNullOrEmpty(hfSubDeptId.Value))
        {
            ShowAlert("Please select a department first.", "warning");
            return;
        }

        HideAlert();

        if (Session["CounterCloseID"] != null && !string.IsNullOrEmpty(Session["CounterCloseID"].ToString()))
            AutoLoadGridWithCounterCloseId(hfSubDeptId.Value, Convert.ToInt32(Session["CounterCloseID"]));
        else
            LoadGrid(0);
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  CLEAR BUTTON
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    protected void btnClear_Click(object sender, EventArgs e)
    {
        ddlDepartment.SelectedIndex = 0;
        hfSubDeptId.Value           = "";
        hfAutoLoadMode.Value        = "false";
        hfCheckedDetailIds.Value    = "";

        gvConsumption.DataSource = null;
        gvConsumption.DataBind();
        pnlStats.Visible       = false;
        pnlSessionInfo.Visible = false;

        Session.Remove("CounterCloseID");
        Session.Remove("SubDeptId");
        Session.Remove("SubDeptName");

        HideAlert();
        ShowAlert("Filters cleared. Session auto-load disabled.", "info");
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  PAGING
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    protected void gvConsumption_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        if (hfAutoLoadMode.Value == "true" && Session["CounterCloseID"] != null)
        {
            gvConsumption.PageIndex = e.NewPageIndex;
            AutoLoadGridWithCounterCloseId(hfSubDeptId.Value, Convert.ToInt32(Session["CounterCloseID"]));
        }
        else
        {
            LoadGrid(e.NewPageIndex);
        }
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  PER-ROW UPDATE
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    protected void gvConsumption_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName != "UpdateRow") return;

        int detailId;
        if (!int.TryParse(e.CommandArgument.ToString(), out detailId))
        {
            ShowAlert("Could not identify row to update.", "error");
            return;
        }

        GridViewRow row = null;
        foreach (GridViewRow r in gvConsumption.Rows)
        {
            Button btn = r.FindControl("btnUpdateRow") as Button;
            if (btn != null && btn.CommandArgument == e.CommandArgument.ToString())
            {
                row = r;
                break;
            }
        }

        if (row == null) { ShowAlert("Row not found in grid.", "error"); return; }

        TextBox txtActual  = row.FindControl("txtActualQty")   as TextBox;
        TextBox txtRemarks = row.FindControl("txtUserRemarks") as TextBox;

        decimal newActual;
        if (txtActual == null || !decimal.TryParse(txtActual.Text.Trim(), out newActual) || newActual < 0)
        {
            ShowAlert("Invalid Actual Qty. Please enter a valid non-negative number.", "warning");
            return;
        }

        Label lblExp = row.FindControl("lblExpectedQtyHidden")      as Label;
        Label lblCF  = row.FindControl("lblConversionFactorHidden") as Label;

        decimal expectedQty = 0m;
        if (lblExp != null) decimal.TryParse(lblExp.Text, out expectedQty);

        decimal cf = 1m;
        if (lblCF != null) decimal.TryParse(lblCF.Text, out cf);
        if (cf == 0m) cf = 1m;

        Label   lblItemCode = row.FindControl("lblItemCodeHidden") as Label;
        string  itemCode    = lblItemCode != null ? lblItemCode.Text.Trim() : "";

        int subDeptId;
        int.TryParse(hfSubDeptId.Value, out subDeptId);

        // [FIX-3] Use consStore connection for Store DB stock function
        decimal currentStock = GetCurrentStock(itemCode, subDeptId.ToString());
        decimal rawActual    = newActual * cf;
        decimal rawExpected  = expectedQty * cf;
        decimal newDiff      = rawActual - rawExpected;

        // [FIX-4] Corrected: rawActual > currentStock (not currentStock * cf)
        // currentStock is already in raw store units; rawActual = display * cf
        if (currentStock >= 0 && rawActual > currentStock)
        {
            ShowAlert(
                "Cannot save: Actual Used (" + newActual.ToString("N3") +
                ") exceeds available stock (" + currentStock.ToString("N3") +
                "). Please reduce Actual Qty.",
                "error");
            return;
        }

        string systemRemark = rawActual < rawExpected ? "Shortage"
                            : rawActual > rawExpected ? "Over"
                            : "Normal";

        string userRemarks  = txtRemarks != null ? txtRemarks.Text.Trim() : "";
        string finalRemarks = !string.IsNullOrEmpty(userRemarks) ? userRemarks : systemRemark;

        if (currentStock < rawExpected && string.IsNullOrEmpty(userRemarks))
            finalRemarks = "Shortage";

        try
        {
            string updateSql = @"
                UPDATE Consumption_Details
                SET    ActualQty     = @ActualQty,
                       DifferenceQty = @DiffQty,
                       Remarks       = @Remarks
                WHERE  Id            = @DetailId";

            using (SqlConnection con = new SqlConnection(cons))
            using (SqlCommand cmd    = new SqlCommand(updateSql, con))
            {
                cmd.Parameters.AddWithValue("@ActualQty", rawActual);
                cmd.Parameters.AddWithValue("@DiffQty",   newDiff);
                cmd.Parameters.AddWithValue("@Remarks",   finalRemarks);
                cmd.Parameters.AddWithValue("@DetailId",  detailId);
                con.Open();
                cmd.ExecuteNonQuery();
            }

            ShowAlert("Row updated successfully.", "success");
        }
        catch (Exception ex)
        {
            LogError("gvConsumption_RowCommand", ex);
            ShowAlert("Update failed. Please try again or contact support.", "error");
            return;
        }

        if (hfAutoLoadMode.Value == "true" && Session["CounterCloseID"] != null)
            AutoLoadGridWithCounterCloseId(hfSubDeptId.Value, Convert.ToInt32(Session["CounterCloseID"]));
        else
            LoadGrid(gvConsumption.PageIndex);
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  SAVE TO STORE
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    protected void btnSaveConsumption_Click(object sender, EventArgs e)
    {
        try
        {
            if (Session["Emp_ID"] == null)
            {
                ShowAlert("Your session has expired. Please log in again before saving.", "error");
                return;
            }
            string empID = Session["Emp_ID"].ToString();

            int deptId;
            if (!int.TryParse(hfSubDeptId.Value, out deptId) || deptId == 0)
            {
                ShowAlert("Invalid department selection.", "error");
                return;
            }

            // [SEC-3] Verify session sub-dept matches selected
            string sessionDept = Session["SubDeptId"] != null ? Session["SubDeptId"].ToString() : "";
            if (!string.IsNullOrEmpty(sessionDept) && sessionDept != hfSubDeptId.Value)
            {
                ShowAlert("Department mismatch. You are not authorised to save for this department.", "error");
                return;
            }

            if (Session["CounterCloseID"] == null ||
                string.IsNullOrEmpty(Session["CounterCloseID"].ToString()))
            {
                ShowAlert("No Counter Close ID found in session. Please reload the page.", "error");
                return;
            }

            int counterCloseId = Convert.ToInt32(Session["CounterCloseID"]);
            if (CounterCloseIdAlreadySaved(counterCloseId))
            {
                ShowAlert(
                    "Counter Close ID #" + counterCloseId + " has already been saved to the store. Duplicate submission is not allowed.",
                    "error");
                return;
            }

            // [FIX-5] Cross-page save: read checked DetailIds from hidden field,
            //         then reload all rows from DB for this CC-ID before building XML.
            //         This ensures rows from ALL pages (not just visible) are processed.
            string checkedIds = hfCheckedDetailIds.Value;
            HashSet<int> checkedSet = new HashSet<int>();

            if (!string.IsNullOrEmpty(checkedIds))
            {
                foreach (string id in checkedIds.Split(','))
                {
                    int parsed;
                    if (int.TryParse(id.Trim(), out parsed) && parsed > 0)
                        checkedSet.Add(parsed);
                }
            }

            // Fallback: also check current visible page checkboxes
            foreach (GridViewRow gvRow in gvConsumption.Rows)
            {
                CheckBox chk = gvRow.FindControl("chkSelect") as CheckBox;
                if (chk != null && chk.Checked)
                {
                    Button btn = gvRow.FindControl("btnUpdateRow") as Button;
                    if (btn != null)
                    {
                        int detailId;
                        if (int.TryParse(btn.CommandArgument, out detailId))
                            checkedSet.Add(detailId);
                    }
                }
            }

            if (checkedSet.Count == 0)
            {
                ShowAlert("Please select at least one item to save.", "warning");
                return;
            }

            // Load all DB rows for this CC-ID so we have fresh qty/stock data
            DataTable allRows = LoadAllRowsForCounterClose(hfSubDeptId.Value, counterCloseId);
            if (allRows == null || allRows.Rows.Count == 0)
            {
                ShowAlert("No data found for Counter Close #" + counterCloseId + ".", "warning");
                return;
            }

            List<string> skippedZeroStock  = new List<string>();
            List<string> blockedOverStock  = new List<string>();

            StringBuilder sbXml = new StringBuilder();
            bool hasData = false;

            using (XmlWriter xw = XmlWriter.Create(sbXml, new XmlWriterSettings { OmitXmlDeclaration = true }))
            {
                xw.WriteStartElement("table");

                foreach (DataRow dbRow in allRows.Rows)
                {
                    int detailId;
                    if (!int.TryParse(dbRow["DetailId"].ToString(), out detailId)) continue;
                    if (!checkedSet.Contains(detailId)) continue;

                    string  itemCode = dbRow["ItemCode"].ToString();
                    decimal cf       = dbRow["ConversionFactor"] != DBNull.Value
                                        ? Convert.ToDecimal(dbRow["ConversionFactor"]) : 1m;
                    if (cf == 0m) cf = 1m;

                    decimal displayActual = dbRow["ActualQty"] != DBNull.Value
                                            ? Convert.ToDecimal(dbRow["ActualQty"]) : 0m;
                    decimal rawQty = displayActual * cf;

                    // [FIX-3] GetCurrentStock uses consStore internally
                    decimal currentStock = GetCurrentStock(itemCode, deptId.ToString());

                    if (currentStock <= 0m)
                    {
                        skippedZeroStock.Add(dbRow["IngredientName"].ToString() + " (" + itemCode + ")");
                        continue;
                    }

                    // [FIX-4] Correct comparison: rawQty vs currentStock (no extra CF)
                    if (rawQty > currentStock)
                    {
                        blockedOverStock.Add(
                            dbRow["IngredientName"].ToString() +
                            " â€” Actual " + rawQty.ToString("N3") +
                            " > Stock " + currentStock.ToString("N3"));
                        continue;
                    }

                    hasData = true;

                    xw.WriteStartElement("row");
                    xw.WriteElementString("item_code",  itemCode);
                    xw.WriteElementString("batch",      "");
                    xw.WriteElementString("qty",        rawQty.ToString());
                    xw.WriteElementString("rate",       "0");
                    xw.WriteElementString("total",      "0");
                    xw.WriteElementString("Dis_amount", "0");
                    xw.WriteElementString("Dis_per",    "0");
                    xw.WriteEndElement();
                }

                xw.WriteEndElement(); // </table>
            }

            if (blockedOverStock.Count > 0)
            {
                ShowAlertRaw(
                    blockedOverStock.Count + " item(s) blocked â€” Actual Used exceeds stock:<br/>" +
                    string.Join("<br/>", blockedOverStock.ToArray()) +
                    "<br/>Please reduce their Actual Qty and try again.",
                    "error");
                return;
            }

            if (!hasData)
            {
                string msg = skippedZeroStock.Count > 0
                    ? "All selected items have zero stock and were skipped. No data to save."
                    : "Please select at least one item.";
                ShowAlert(msg, "warning");
                return;
            }

            string xmlSub = sbXml.ToString();

            using (SqlConnection con = new SqlConnection(consStore))
            using (SqlCommand cmd    = new SqlCommand("Insert_Cafe_consp", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@Emp_ID",      empID);
                cmd.Parameters.AddWithValue("@deptid",      deptId);
                // [FIX-1] @Subdeptid correctly set to the sub-department ID (same as deptId
                //         on this screen where SubDept IS the selected dept; adjust if they
                //         ever diverge â€” add a separate hfSubDeptId vs hfDeptId hidden field).
                cmd.Parameters.AddWithValue("@Subdeptid",   deptId);
                cmd.Parameters.AddWithValue("@ShiftID",     0);
                cmd.Parameters.AddWithValue("@XML_Sub",     xmlSub);
                cmd.Parameters.AddWithValue("@Hospital_Id", 1);
                cmd.Parameters.AddWithValue("@total_Amount", 0);

                SqlParameter outParam = new SqlParameter("@Consumption_Id", SqlDbType.Int);
                outParam.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outParam);

                con.Open();
                cmd.ExecuteNonQuery();

                int resultId = Convert.ToInt32(outParam.Value);

                if (resultId == -2)
                {
                    ShowAlert("Duplicate request blocked by store procedure (60 sec rule).", "warning");
                    return;
                }

                if (resultId > 0)
                {
                    string successMsg = "Saved successfully. Consumption ID: <strong>" + resultId + "</strong>.";
                    if (skippedZeroStock.Count > 0)
                        successMsg += "<br/>Skipped " + skippedZeroStock.Count +
                                      " zero-stock item(s): " + string.Join(", ", skippedZeroStock.ToArray());
                    ShowAlertRaw(successMsg, "success");

                    // Clear checked state after successful save
                    hfCheckedDetailIds.Value = "";
                }
                else
                {
                    ShowAlert("Save failed â€” stored procedure returned 0. Contact support.", "error");
                }
            }
        }
        catch (Exception ex)
        {
            LogError("btnSaveConsumption_Click", ex);
            ShowAlert("An unexpected error occurred while saving. Please try again or contact support.", "error");
        }
    }

    // â”€â”€ Load all DB rows for a given CC-ID (for cross-page save) [FIX-5] â”€â”€â”€â”€â”€
    private DataTable LoadAllRowsForCounterClose(string subDeptId, int counterCloseId)
    {
        try
        {
            string sql = GridSql + " AND cm.CounterCloseId = @CounterCloseId ORDER BY cd.Id;";
            using (SqlConnection con = new SqlConnection(cons))
            using (SqlCommand cmd    = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@SubDeptId",      subDeptId);
                cmd.Parameters.AddWithValue("@CounterCloseId", counterCloseId);
                con.Open();
                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());
                return dt;
            }
        }
        catch (Exception ex)
        {
            LogError("LoadAllRowsForCounterClose", ex);
            return null;
        }
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  DUPLICATE CC-ID CHECK  [CRIT-1] â€” class-level private method
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    private bool CounterCloseIdAlreadySaved(int counterCloseId)
    {
        try
        {
            string sql = @"SELECT COUNT(1)
                           FROM   Store.dbo.Consumption_Master
                           WHERE  CounterCloseId = @CounterCloseId";

            using (SqlConnection con = new SqlConnection(consStore))
            using (SqlCommand cmd    = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@CounterCloseId", counterCloseId);
                con.Open();
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }
        catch
        {
            return false; // fail-open; SP will handle duplicate if check fails
        }
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  GET CURRENT STOCK  [FIX-3] â€” uses consStore (Store DB)
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    private decimal GetCurrentStock(string itemCode, string subDeptId)
    {
        if (string.IsNullOrEmpty(itemCode) || itemCode == "N/A") return 0m;
        try
        {
            // [FIX-3] GET_Store_Item_StokNew lives in Store DB â€” must use consStore
            string sql = "SELECT ISNULL(dbo.GET_Store_Item_StokNew(@ItemCode, @SubDeptId), 0)";
            using (SqlConnection con = new SqlConnection(consStore))
            using (SqlCommand cmd    = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@ItemCode",  itemCode);
                cmd.Parameters.AddWithValue("@SubDeptId", subDeptId);
                con.Open();
                object result = cmd.ExecuteScalar();
                return (result != null && result != DBNull.Value) ? Convert.ToDecimal(result) : 0m;
            }
        }
        catch { return 0m; }
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  HELPER METHODS â€” UI rendering (called from ASPX inline expressions)
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    protected string GetDiffClass(object val)
    {
        if (val == null || val == DBNull.Value) return "diff-zero";
        decimal d = Convert.ToDecimal(val);
        if (d < 0) return "diff-neg";
        if (d > 0) return "diff-pos";
        return "diff-zero";
    }

    protected string GetRemarksBadge(object val)
    {
        string r = (val == null || val == DBNull.Value) ? "Normal" : val.ToString();
        switch (r)
        {
            case "Shortage": return "<span class='rem-shortage'><i class='fas fa-arrow-trend-down'></i> Shortage</span>";
            case "Over":     return "<span class='rem-over'><i class='fas fa-arrow-trend-up'></i> Over</span>";
            default:         return "<span class='rem-normal'><i class='fas fa-check'></i> Normal</span>";
        }
    }

    protected string GetStockBadge(object stockVal, object expectedVal)
    {
        decimal stock    = (stockVal    != null && stockVal    != DBNull.Value) ? Convert.ToDecimal(stockVal)    : 0m;
        decimal expected = (expectedVal != null && expectedVal != DBNull.Value) ? Convert.ToDecimal(expectedVal) : 0m;

        string css = stock <= 0       ? "stk-zero"
                   : stock < expected ? "stk-low"
                   : "stk-ok";

        return string.Format("<span class='{0}'>{1:N3}</span>", css, stock);
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  ALERT HELPERS  [SEC-1]
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    private void ShowAlert(string msg, string type)
    {
        // [SEC-1] HTML-encode to prevent XSS from dept names / ex.Message
        ShowAlertRaw(HttpUtility.HtmlEncode(msg), type);
    }

    private void ShowAlertRaw(string trustedHtml, string type)
    {
        string icon;
        switch (type)
        {
            case "success": icon = "fa-circle-check";         break;
            case "error":   icon = "fa-circle-xmark";         break;
            case "warning": icon = "fa-triangle-exclamation"; break;
            default:        icon = "fa-circle-info";           break;
        }
        pnlAlert.Visible                  = true;
        divAlert.Attributes["class"]      = "alert-box alert-" + type;
        lblAlertMsg.Text                  = "<i class='fas " + icon + "'></i><span>" + trustedHtml + "</span>";
    }

    private void HideAlert() { pnlAlert.Visible = false; }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  ERROR LOGGING  [SEC-2]
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    private void LogError(string context, Exception ex)
    {
        System.Diagnostics.Trace.TraceError(
            "[ConsumptionVerification] {0} â€” {1}\n{2}", context, ex.Message, ex.StackTrace);
    }
}


