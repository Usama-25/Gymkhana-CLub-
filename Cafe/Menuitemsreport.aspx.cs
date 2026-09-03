using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Menuitemsreport : System.Web.UI.Page
{
    string restaurantConnStr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
    string storeConnStr = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            pnlReport.Visible = false;
            btnPrint.Visible = false;
            lblNoResult.Visible = false;

            // Check if item code exists in session
            if (Session["ReportItemCode"] != null)
            {
                string itemCode = Session["ReportItemCode"].ToString();
                txtItemID.Text = itemCode;
                LoadMenuItemDetails(itemCode, "");

                // Clear the session after using
                Session.Remove("ReportItemCode");
            }
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        string itemID = txtItemID.Text.Trim();
        string itemName = txtItemName.Text.Trim();

        if (string.IsNullOrEmpty(itemID) && string.IsNullOrEmpty(itemName))
        {
            lblNoResult.Text = "Please enter Item ID or Item Name to search.";
            lblNoResult.Visible = true;
            pnlReport.Visible = false;
            btnPrint.Visible = false;
            return;
        }

        LoadMenuItemDetails(itemID, itemName);
    }

    private void LoadMenuItemDetails(string itemID, string itemName)
    {
        // ── 1. Main item query from Restaurant database ────────────────────
        string sqlMain = @"
            SELECT TOP 1
                ItemCode,
                ItemName,
                ItemName AS PrintAs,
                SubMenu_Name,
                MealType_Name,
                Course_Name,
                ISNULL(GST, 0) AS GST,
                Active,
                ISNULL(Cost, 0) AS TotalCost,
                RecipeWeight,
                DepartmentID,
                WeightUnit,
                PerPerson
            FROM MenuItems
            WHERE (@ItemCode = '' OR ItemCode = @ItemCode)
              AND (@ItemName = '' OR ItemName LIKE '%' + @ItemName + '%')";

        using (SqlConnection cn = new SqlConnection(restaurantConnStr))
        {
            cn.Open();

            // ── Load header info from Restaurant database ───────────────────
            using (SqlCommand cmd = new SqlCommand(sqlMain, cn))
            {
                cmd.Parameters.AddWithValue("@ItemCode", itemID);
                cmd.Parameters.AddWithValue("@ItemName", itemName);

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (!dr.Read())
                    {
                        lblNoResult.Text = "No record found for the given search criteria.";
                        lblNoResult.Visible = true;
                        pnlReport.Visible = false;
                        btnPrint.Visible = false;
                        return;
                    }

                    // Store hidden fields
                    hfDepartmentID.Value = dr["DepartmentID"] != DBNull.Value ? dr["DepartmentID"].ToString() : "";

                    // Fill header labels
                    lblItemID.Text = dr["ItemCode"].ToString();
                    lblItemName.Text = dr["ItemName"].ToString();
                    lblPrintAs.Text = dr["PrintAs"].ToString();

                    // Classification
                    lblSubMenu.Text = dr["SubMenu_Name"] != DBNull.Value ? dr["SubMenu_Name"].ToString() : "";
                    lblMealType.Text = dr["MealType_Name"] != DBNull.Value ? dr["MealType_Name"].ToString() : "";
                    lblCourse.Text = dr["Course_Name"] != DBNull.Value ? dr["Course_Name"].ToString() : "";
                    lblGST.Text = dr["GST"] != DBNull.Value ? string.Format("{0:N2}", dr["GST"]) : "0.00";
                    lblActive.Text = dr["Active"] != DBNull.Value ? (Convert.ToBoolean(dr["Active"]) ? "YES" : "NO") : "NO";

                    // Cost fields
                    lblTotalCost.Text = dr["TotalCost"] != DBNull.Value
                                        ? string.Format("{0:N2}", dr["TotalCost"])
                                        : "0.00";

                    // Store Recipe Weight details in ViewState for ingredients
                    ViewState["RecipeWeight"] = dr["RecipeWeight"] != DBNull.Value ? dr["RecipeWeight"] : 0;
                    ViewState["WeightUnit"] = dr["WeightUnit"] != DBNull.Value ? dr["WeightUnit"] : "";
                    ViewState["PerPerson"] = dr["PerPerson"] != DBNull.Value ? dr["PerPerson"] : 0;
                    ViewState["ItemCode"] = dr["ItemCode"].ToString();
                    ViewState["DepartmentID"] = dr["DepartmentID"] != DBNull.Value ? dr["DepartmentID"].ToString() : "";
                }
            }

            // ── 2. Load Recipe Cost from STORE database ──────────────────────
            LoadRecipeCostFromStore(ViewState["ItemCode"].ToString());

            // ── 3. Outlet/Department price query from STORE database ─────────
            LoadOutletPricesFromStore(ViewState["DepartmentID"].ToString());

            // ── 4. Load Recipe Ingredients from STORE database ────────────────
            LoadRecipeIngredientsFromStore(ViewState["ItemCode"].ToString());
        }

        // Show report
        pnlReport.Visible = true;
        btnPrint.Visible = true;
        lblNoResult.Visible = false;
    }

    private void LoadRecipeCostFromStore(string itemCode)
    {
        string sqlRecipeCost = @"
            SELECT 
                ISNULL(TotalCost, 0) AS RecipeCost,
                ISNULL(Garnish, 0) + ISNULL(Topping, 0) + ISNULL(Wastage, 0) AS AddOn
            FROM STORE.dbo.RecipeMain
            WHERE RecipeItemCode = @RecipeCode";

        try
        {
            using (SqlConnection storeCn = new SqlConnection(storeConnStr))
            {
                storeCn.Open();
                using (SqlCommand cmd = new SqlCommand(sqlRecipeCost, storeCn))
                {
                    cmd.Parameters.AddWithValue("@RecipeCode", itemCode);

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            lblRecipeCost.Text = dr["RecipeCost"] != DBNull.Value
                                ? string.Format("{0:N2}", dr["RecipeCost"])
                                : "0.00";
                            lblAddOn.Text = dr["AddOn"] != DBNull.Value
                                ? string.Format("{0:N2}", dr["AddOn"])
                                : "0.00";
                        }
                        else
                        {
                            lblRecipeCost.Text = "0.00";
                            lblAddOn.Text = "0.00";
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // Handle case when RecipeMain doesn't exist or other errors
            lblRecipeCost.Text = "0.00";
            lblAddOn.Text = "0.00";
            System.Diagnostics.Debug.WriteLine("Error loading recipe cost: " + ex.Message);
        }
    }

    private void LoadOutletPricesFromStore(string departmentID)
    {
        if (string.IsNullOrEmpty(departmentID))
        {
            gvOutlets.DataSource = null;
            gvOutlets.DataBind();
            return;
        }

        // Query SubDepartment from STORE database and join with MenuItems from Restaurant database
        string sqlOutlets = @"
            SELECT 
                sd.SubDept_Id AS OutletCode,
                sd.SubDept_Name AS SubDeptName,
                ISNULL(mi.Price, 0) AS Price,
                ISNULL(mi.OldPrice, 0) AS Cost
            FROM STORE.dbo.SubDepartment sd
            LEFT JOIN Restaurant.dbo.MenuItems mi ON sd.SubDept_Id = mi.DepartmentID AND mi.ItemCode = @ItemCode
            WHERE sd.SubDept_Id = @DeptID
            ORDER BY sd.SubDept_Id";

        try
        {
            using (SqlConnection storeCn = new SqlConnection(storeConnStr))
            {
                storeCn.Open();
                using (SqlCommand cmd = new SqlCommand(sqlOutlets, storeCn))
                {
                    cmd.Parameters.AddWithValue("@DeptID", departmentID);
                    cmd.Parameters.AddWithValue("@ItemCode", ViewState["ItemCode"].ToString());

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                        hfDeptName.Value = dt.Rows[0]["SubDeptName"].ToString();

                    gvOutlets.DataSource = dt;
                    gvOutlets.DataBind();
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading outlet prices: " + ex.Message);
            gvOutlets.DataSource = null;
            gvOutlets.DataBind();
        }
    }

    private void LoadRecipeIngredientsFromStore(string itemCode)
    {
        string sqlIngredients = @"
            SELECT 
                rs.ItemName,
                rs.Quantity,
                rs.Unit,
                rs.BaseCost,
                rs.TotalCost,
                rs.Category,
                ISNULL(rm.Garnish, 0) AS Garnish,
                ISNULL(rm.Topping, 0) AS Topping,
                ISNULL(rm.Wastage, 0) AS Wastage
            FROM STORE.dbo.RecipeSub rs
            LEFT JOIN STORE.dbo.RecipeMain rm ON rs.RecipeCode = rm.RecipeItemCode
            WHERE rs.RecipeCode = @RecipeCode
              AND rs.Active = 1
            ORDER BY rs.Category, rs.ItemName";

        DataTable dtIngredients = new DataTable();

        try
        {
            using (SqlConnection storeCn = new SqlConnection(storeConnStr))
            {
                storeCn.Open();
                using (SqlCommand cmd = new SqlCommand(sqlIngredients, storeCn))
                {
                    cmd.Parameters.AddWithValue("@RecipeCode", itemCode);

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        dtIngredients.Load(dr);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // Handle case when tables don't exist
            System.Diagnostics.Debug.WriteLine("Error loading ingredients: " + ex.Message);
            dtIngredients = new DataTable();
        }

        // Bind recipe details
        BindRecipeDetails(dtIngredients);
    }

    private void BindRecipeDetails(DataTable dtIngredients)
    {
        if (dtIngredients.Rows.Count > 0)
        {
            string html = "<table class='recipe-grid' style='width:100%; border-collapse: collapse;'>";
            html += "<thead>";
            html += "<tr style='background-color: #f0f0f0; border-bottom: 2px solid #333;'>";
            html += "<th style='padding: 8px; text-align: left;'>Ingredient</th>";
            html += "<th style='padding: 8px; text-align: center;'>Qty</th>";
            html += "<th style='padding: 8px; text-align: center;'>Unit</th>";
            html += "<th style='padding: 8px; text-align: right;'>Base Cost</th>";
            html += "<th style='padding: 8px; text-align: right;'>Total Cost</th>";
            html += "<th style='padding: 8px; text-align: center;'>Category</th>";

            // Check if we have garnish/topping/wastage data
            bool hasExtras = false;
            foreach (DataRow row in dtIngredients.Rows)
            {
                if (Convert.ToDecimal(row["Garnish"]) > 0 ||
                    Convert.ToDecimal(row["Topping"]) > 0 ||
                    Convert.ToDecimal(row["Wastage"]) > 0)
                {
                    hasExtras = true;
                    break;
                }
            }

            if (hasExtras)
            {
                html += "<th style='padding: 8px; text-align: right;'>Garnish</th>";
                html += "<th style='padding: 8px; text-align: right;'>Topping</th>";
                html += "<th style='padding: 8px; text-align: right;'>Wastage</th>";
            }

            html += "</tr></thead><tbody>";

            decimal totalRecipeCost = 0;

            foreach (DataRow row in dtIngredients.Rows)
            {
                decimal totalCost = Convert.ToDecimal(row["TotalCost"]);
                totalRecipeCost += totalCost;

                html += "<tr style='border-bottom: 1px solid #ddd;'>";
                html += "<td style='padding: 6px;'>" + row["ItemName"].ToString() + "</td>";
                html += "<td style='padding: 6px; text-align: center;'>" + Convert.ToDecimal(row["Quantity"]).ToString("N4") + "</td>";
                html += "<td style='padding: 6px; text-align: center;'>" + row["Unit"].ToString() + "</td>";
                html += "<td style='padding: 6px; text-align: right;'>" + Convert.ToDecimal(row["BaseCost"]).ToString("N4") + "</td>";
                html += "<td style='padding: 6px; text-align: right;'>" + totalCost.ToString("N4") + "</td>";
                html += "<td style='padding: 6px; text-align: center;'>" + row["Category"].ToString() + "</td>";

                if (hasExtras)
                {
                    html += "<td style='padding: 6px; text-align: right;'>" + Convert.ToDecimal(row["Garnish"]).ToString("N4") + "</td>";
                    html += "<td style='padding: 6px; text-align: right;'>" + Convert.ToDecimal(row["Topping"]).ToString("N4") + "</td>";
                    html += "<td style='padding: 6px; text-align: right;'>" + Convert.ToDecimal(row["Wastage"]).ToString("N4") + "</td>";
                }

                html += "</tr>";
            }

            html += "<tr style='background-color: #e8f5e9; font-weight: bold; border-top: 2px solid #333;'>";
            html += "<td colspan='4' style='padding: 8px; text-align: right;'>Total Recipe Cost:</td>";
            html += "<td style='padding: 8px; text-align: right; color: #800000;'>" + totalRecipeCost.ToString("N2") + "</td>";
            html += "<td colspan='4'></td>";
            html += "</tr>";

            html += "</tbody></table>";

            // Also display Recipe Weight info
            html += "<div class='recipe-summary'>";
            html += "<strong>Recipe Information:</strong><br/>";
            html += "Recipe Weight: " + ViewState["RecipeWeight"].ToString() + " " + ViewState["WeightUnit"].ToString() + "<br/>";
            html += "Per Person: " + ViewState["PerPerson"].ToString();

            // Calculate and display percentage of total cost if applicable
            decimal sellingPrice = 0;
            decimal.TryParse(lblTotalCost.Text, out sellingPrice);

            if (totalRecipeCost > 0 && sellingPrice > 0)
            {
                decimal costPercentage = (totalRecipeCost / sellingPrice) * 100;
                html += "<br/><strong>Food Cost Percentage:</strong> " + costPercentage.ToString("N2") + "%";

                // Add profitability indicator
                if (costPercentage <= 30)
                    html += " <span style='color: green;'>(Excellent)</span>";
                else if (costPercentage <= 40)
                    html += " <span style='color: #ffa500;'>(Good)</span>";
                else
                    html += " <span style='color: red;'>(Review Pricing)</span>";
            }

            html += "</div>";

            litRecipeDetails.Text = html;
        }
        else
        {
            litRecipeDetails.Text = "<div class='no-data'>No recipe ingredients found for this item.</div>";
        }
    }
}

