using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class itemwithrecipe : System.Web.UI.Page
{
    string conStr = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ToString();
    string basic = ConfigurationManager.ConnectionStrings["BasicDataInfoConnectionString"].ToString();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadDepartments();
            LoadReport();
        }
    }

    private void LoadDepartments()
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(basic))
            {
                string query = "SELECT SubDept_Id, SubDept_Name FROM SubDepartment WHERE Dept_id = 9 ORDER BY SubDept_Name";
                SqlDataAdapter da = new SqlDataAdapter(query, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlDepartment.DataSource = dt;
                ddlDepartment.DataTextField = "SubDept_Name";
                ddlDepartment.DataValueField = "SubDept_Id";
                ddlDepartment.DataBind();

                // Add "All Departments" option
                ddlDepartment.Items.Insert(0, new System.Web.UI.WebControls.ListItem("-- All Departments --", "0"));
            }
        }
        catch (Exception ex)
        {
            string errorScript = "<script>alert('Error loading departments: " + ex.Message.Replace("'", "\\'") + "');</script>";
            Response.Write(errorScript);
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        LoadReport();
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        txtItemCode.Text = string.Empty;
        ddlDepartment.SelectedIndex = 0;
        LoadReport();
    }

    private void LoadReport()
    {
        try
        {
            string departmentId = ddlDepartment.SelectedValue;
            string itemCode = txtItemCode.Text.Trim();

            DataTable dt = GetRecipeData(departmentId, itemCode);

            if (dt.Rows.Count > 0)
            {
                phReport.Controls.Clear();
                phReport.Controls.Add(BuildReportTable(dt));
            }
            else
            {
                phReport.Controls.Clear();
                phReport.Controls.Add(new LiteralControl("<div class='no-data'>No records found matching the search criteria.</div>"));
            }
        }
        catch (Exception ex)
        {
            phReport.Controls.Clear();
            string errorMessage = "<div class='no-data' style='color:red;'>Error loading report: " + ex.Message + "</div>";
            phReport.Controls.Add(new LiteralControl(errorMessage));
        }
    }

    private DataTable GetRecipeData(string departmentId, string itemCode)
    {
        DataTable dt = new DataTable();

        using (SqlConnection conn = new SqlConnection(conStr))
        {
            StringBuilder query = new StringBuilder();
            query.Append(@"
                SELECT 
                    rm.RecipeItemCode,
                    rm.RecipeName,
                    rm.DeptId,
                    rm.SubDeptId,
                    rs.ItemCode,
                    rs.ItemName,
                    rs.Unit,
                    rs.Quantity,
                    rs.BaseCost AS Rate,
                    rs.TotalCost,
                    rct.CategoryTypeName
                FROM RecipeMain rm
                INNER JOIN RecipeSub rs ON rm.RecipeId = rs.RecipeId
                INNER JOIN Recipe_Category_Type rct ON rs.Category_Type = rct.CategoryTypeID
                WHERE 1=1
            ");

            if (!string.IsNullOrEmpty(departmentId) && departmentId != "0")
            {
                query.Append(" AND rm.SubDeptId = @DepartmentId");
            }

            if (!string.IsNullOrEmpty(itemCode))
            {
                query.Append(" AND (rm.RecipeItemCode LIKE @ItemCode OR rs.ItemCode LIKE @ItemCode)");
            }

            query.Append(" ORDER BY rm.RecipeItemCode, rm.RecipeName, rct.CategoryTypeName, rs.ItemCode");

            SqlCommand cmd = new SqlCommand(query.ToString(), conn);

            if (!string.IsNullOrEmpty(departmentId) && departmentId != "0")
            {
                cmd.Parameters.AddWithValue("@DepartmentId", departmentId);
            }

            if (!string.IsNullOrEmpty(itemCode))
            {
                cmd.Parameters.AddWithValue("@ItemCode", "%" + itemCode + "%");
            }

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            da.Fill(dt);
        }

        return dt;
    }

    private Table BuildReportTable(DataTable dt)
    {
        Table table = new Table();
        table.CssClass = "report-grid";

        // Create Header Row
        TableRow headerRow = new TableRow();
        headerRow.CssClass = "header-row";

        string[] headers = { "Recipe Code", "Recipe Name", "Item Code", "Item Name", "Unit", "Qty Req", "Rate", "Amount", "Category" };
        foreach (string header in headers)
        {
            TableCell cell = new TableCell();
            cell.Text = header;
            cell.Font.Bold = true;
            headerRow.Cells.Add(cell);
        }
        table.Rows.Add(headerRow);

        // Add Data Rows
        string currentRecipe = "";
        string currentCategory = "";
        decimal recipeTotal = 0;
        bool recipeStarted = false;
        int rowCount = 0;

        foreach (DataRow row in dt.Rows)
        {
            string recipeItemCode = row["RecipeItemCode"].ToString();
            string recipeName = row["RecipeName"].ToString();
            string categoryType = row["CategoryTypeName"].ToString();

            // Check if this is a new recipe group
            if (currentRecipe != recipeItemCode + recipeName)
            {
                // Add total row for previous recipe if any
                if (recipeStarted)
                {
                    AddTotalRow(table, currentRecipe, currentCategory, recipeTotal);
                }

                // Start new recipe group
                currentRecipe = recipeItemCode + recipeName;
                currentCategory = categoryType;
                recipeTotal = 0;
                recipeStarted = true;
                rowCount = 0;

                // Add recipe header row (with background color)
                TableRow recipeHeader = new TableRow();
                recipeHeader.CssClass = "category-header";

                TableCell cell1 = new TableCell();
                cell1.Text = recipeItemCode;
                recipeHeader.Cells.Add(cell1);

                TableCell cell2 = new TableCell();
                cell2.Text = recipeName;
                cell2.ColumnSpan = 2;
                recipeHeader.Cells.Add(cell2);

                TableCell cell3 = new TableCell();
                cell3.Text = "FOOD ITEMS";
                cell3.ColumnSpan = 6;
                recipeHeader.Cells.Add(cell3);

                table.Rows.Add(recipeHeader);
            }

            // Add detail row
            TableRow dataRow = new TableRow();
            dataRow.CssClass = (rowCount % 2 == 0) ? "item-row" : "item-row";

            // Recipe Code (empty for detail rows)
            dataRow.Cells.Add(CreateCell(""));

            // Recipe Name (empty for detail rows)
            dataRow.Cells.Add(CreateCell(""));

            // Item Code
            dataRow.Cells.Add(CreateCell(row["ItemCode"].ToString()));

            // Item Name
            dataRow.Cells.Add(CreateCell(row["ItemName"].ToString()));

            // Unit
            dataRow.Cells.Add(CreateCell(row["Unit"].ToString()));

            // Quantity
            dataRow.Cells.Add(CreateCell(Convert.ToDecimal(row["Quantity"]).ToString("0.0000")));

            // Rate
            dataRow.Cells.Add(CreateCell(Convert.ToDecimal(row["Rate"]).ToString("0.00")));

            // Amount
            decimal amount = Convert.ToDecimal(row["TotalCost"]);
            dataRow.Cells.Add(CreateCell(amount.ToString("0.00")));
            recipeTotal += amount;

            // Category
            dataRow.Cells.Add(CreateCell(row["CategoryTypeName"].ToString()));

            table.Rows.Add(dataRow);
            rowCount++;
        }

        // Add total row for last recipe
        if (recipeStarted)
        {
            AddTotalRow(table, currentRecipe, currentCategory, recipeTotal);
        }

        return table;
    }

    private TableCell CreateCell(string text)
    {
        TableCell cell = new TableCell();
        cell.Text = text;
        return cell;
    }

    private void AddTotalRow(Table table, string recipeKey, string category, decimal total)
    {
        TableRow totalRow = new TableRow();
        totalRow.CssClass = "total-row";

        TableCell cell1 = new TableCell();
        cell1.Text = "";
        totalRow.Cells.Add(cell1);

        TableCell cell2 = new TableCell();
        cell2.Text = "Total:";
        cell2.ColumnSpan = 7;
        cell2.Font.Bold = true;
        totalRow.Cells.Add(cell2);

        TableCell cell3 = new TableCell();
        cell3.Text = total.ToString("0.00");
        cell3.Font.Bold = true;
        totalRow.Cells.Add(cell3);

        TableCell cell4 = new TableCell();
        cell4.Text = "";
        totalRow.Cells.Add(cell4);

        table.Rows.Add(totalRow);
    }
}


