using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Store_Cash_Sale_Invoice_Wise : System.Web.UI.Page
{
    string conStr = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ToString();

    // ================= MODELS =================
    private class RecipeHeader
    {
        public int RecipeId { get; set; }
        public string RecipeName { get; set; }
        public string RecipeItemCode { get; set; }
        public decimal OverheadPct { get; set; }
        public decimal InflationPct { get; set; }
        public decimal RecipeWeight { get; set; }
        public string ServingUtensil { get; set; }
        public decimal SellingPrice { get; set; }
        public decimal SavedTotalCost { get; set; }
        public decimal SavedCostPerPortion { get; set; }
        public decimal SavedOverheadValue { get; set; }
        public decimal SavedInflationValue { get; set; }
        public string ImagePath { get; set; }
    }

    private class IngredientLine
    {
        public int RecipeItemId { get; set; }
        public string RecipeCode { get; set; }
        public string ItemCode { get; set; }
        public string ItemName { get; set; }
        public string Unit { get; set; }

        public decimal ConversionFactor { get; set; }
        public decimal Quantity { get; set; }

        public decimal SavedBaseCost { get; set; }
        public decimal SavedTotalCost { get; set; }

        public string Category { get; set; }
        public int? CategoryID { get; set; }
        public int Category_Type { get; set; }

        public decimal LiveRate { get; set; }
        public decimal LiveBaseCost { get; set; }
        public decimal LiveTotalCost { get; set; }

        public decimal Variance { get; set; }
    }

    // ================= ALERT =================
    private void ShowAlert(string message)
    {
        lblAlert.Text = message;
        pnlAlert.Visible = true;
    }

    // ================= SEARCH =================
    protected void btnSearch_Click(object sender, EventArgs e)
    {
        string name = txtName.Text.Trim();
        string code = txtCode.Text.Trim();

        pnlAlert.Visible = false;
        pnlReport.Visible = false;
        pnlEmpty.Visible = false;

        if (string.IsNullOrEmpty(name) && string.IsNullOrEmpty(code))
        {
            ShowAlert("Please enter a Recipe Name or Item Code to search.");
            return;
        }

        LoadReport(name, code);
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        txtName.Text = "";
        txtCode.Text = "";
        pnlAlert.Visible = false;
        pnlReport.Visible = false;
        pnlEmpty.Visible = false;
    }

    // ================= CORE =================
    private void LoadReport(string searchName, string searchCode)
    {
        DataSet ds = new DataSet();

        using (SqlConnection con = new SqlConnection(conStr))
        using (SqlCommand cmd = new SqlCommand("sp_GetLiveRecipeCost", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.Add("@SearchName", SqlDbType.NVarChar, 200).Value =
                string.IsNullOrWhiteSpace(searchName) ? (object)DBNull.Value : searchName;

            cmd.Parameters.Add("@SearchItemCode", SqlDbType.VarChar, 100).Value =
                string.IsNullOrWhiteSpace(searchCode) ? (object)DBNull.Value : searchCode;

            new SqlDataAdapter(cmd).Fill(ds);
        }

        RecipeHeader header = null;

        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
        {
            DataRow dr = ds.Tables[0].Rows[0];

            header = new RecipeHeader
            {
                RecipeId = Convert.ToInt32(dr["RecipeId"]),
                RecipeName = dr["RecipeName"].ToString(),
                RecipeItemCode = dr["RecipeItemCode"].ToString(),
                OverheadPct = Convert.ToDecimal(dr["OverheadPct"]),
                InflationPct = Convert.ToDecimal(dr["InflationPct"]),
                RecipeWeight = Convert.ToDecimal(dr["RecipeWeight"]),
                ServingUtensil = dr["ServingUtensil"].ToString(),
                SellingPrice = Convert.ToDecimal(dr["SellingPrice"]),
                SavedTotalCost = Convert.ToDecimal(dr["SavedTotalCost"]),
                SavedCostPerPortion = Convert.ToDecimal(dr["SavedCostPerPortion"]),
                SavedOverheadValue = Convert.ToDecimal(dr["SavedOverheadValue"]),
                SavedInflationValue = Convert.ToDecimal(dr["SavedInflationValue"]),
                ImagePath = dr["ImagePath"].ToString()
            };
        }

        List<IngredientLine> items = new List<IngredientLine>();

        if (ds.Tables.Count > 1)
        {
            foreach (DataRow dr in ds.Tables[1].Rows)
            {
                items.Add(new IngredientLine
                {
                    RecipeItemId = Convert.ToInt32(dr["RecipeItemId"]),
                    RecipeCode = dr["RecipeCode"].ToString(),
                    ItemCode = dr["ItemCode"].ToString(),
                    ItemName = dr["ItemName"].ToString(),
                    Unit = dr["Unit"].ToString(),

                    ConversionFactor = dr["ConversionFactor"] == DBNull.Value ? 0 : Convert.ToDecimal(dr["ConversionFactor"]),
                    Quantity = Convert.ToDecimal(dr["Quantity"]),

                    SavedBaseCost = Convert.ToDecimal(dr["SavedBaseCost"]),
                    SavedTotalCost = Convert.ToDecimal(dr["SavedTotalCost"]),

                    Category = dr["Category"].ToString(),
                    CategoryID = dr["CategoryID"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["CategoryID"]),
                    Category_Type = Convert.ToInt32(dr["Category_Type"]),

                    LiveRate = Convert.ToDecimal(dr["LiveRate"]),
                    LiveBaseCost = Convert.ToDecimal(dr["LiveBaseCost"]),
                    LiveTotalCost = Convert.ToDecimal(dr["LiveTotalCost"]),
                    Variance = Convert.ToDecimal(dr["Variance"])
                });
            }
        }

        if (header == null)
        {
            pnlEmpty.Visible = true;
            return;
        }

        // HEADER
        lblRecipeName.Text = header.RecipeName;
        lblRecipeCode.Text = header.RecipeItemCode;
        lblGenDate.Text = DateTime.Now.ToString("dd-MMM-yyyy hh:mm tt");
        lblWeight.Text = header.RecipeWeight + " g";
        lblUtensil.Text = header.ServingUtensil;
        lblSellPrice.Text = "Rs. " + header.SellingPrice.ToString("N2");

        lblOverhead.Text = header.OverheadPct + "%";
        lblInflation.Text = header.InflationPct + "%";

        var main = items.Where(x => x.Category_Type == 1).ToList();
        var garnish = items.Where(x => x.Category_Type == 2).ToList();
        var topping = items.Where(x => x.Category_Type == 3).ToList();
        var wastage = items.Where(x => x.Category_Type == 4).ToList();

        decimal t1 = BindSection(gvMain, main, pnlMain, lblTotMain);
        decimal t2 = BindSection(gvGarnish, garnish, pnlGarnish, lblTotGarnish);
        decimal t3 = BindSection(gvTopping, topping, pnlTopping, lblTotTopping);
        decimal t4 = BindSection(gvWastage, wastage, pnlWastage, lblTotWastage);

        decimal liveCost = t1 + t2 + t3 + t4;

        decimal overhead = liveCost * header.OverheadPct / 100m;
        decimal inflation = liveCost * header.InflationPct / 100m;
        decimal cpp = liveCost + overhead + inflation;

        decimal saved = header.SavedTotalCost;
        decimal varAmt = liveCost - saved;
        decimal varPct = saved != 0 ? (varAmt / saved) * 100m : 0;

        lblSavedCost.Text = "Rs. " + saved.ToString("N2");
        lblLiveCost.Text = "Rs. " + liveCost.ToString("N2");
        lblLiveOverhead.Text = "Rs. " + overhead.ToString("N2");
        lblLiveInflation.Text = "Rs. " + inflation.ToString("N2");
        lblLiveCPP.Text = "Rs. " + cpp.ToString("N2");

        string sign = varAmt >= 0 ? "+" : "";
        lblVarAmt.Text = sign + "Rs. " + Math.Abs(varAmt).ToString("N2");
        lblVarPct.Text = sign + varPct.ToString("N2") + "% vs saved";

        pnlReport.Visible = true;
    }

    // ================= GRID =================
    private decimal BindSection(GridView gv, List<IngredientLine> rows, Panel panel, Label totalLabel)
    {
        if (rows.Count == 0)
        {
            panel.Visible = false;
            return 0m;
        }

        decimal total = rows.Sum(x => x.LiveTotalCost);

        gv.DataSource = rows;
        gv.DataBind();

        totalLabel.Text = "Rs. " + total.ToString("N2");
        panel.Visible = true;

        return total;
    }

    // ================= VARIANCE HELPERS =================
    protected string GetVarianceClass(object varianceObj)
    {
        decimal v = 0;

        if (varianceObj != null && varianceObj != DBNull.Value)
            decimal.TryParse(varianceObj.ToString(), out v);

        if (v > 0) return "var-pos";
        if (v < 0) return "var-neg";
        return "var-zero";
    }

    protected string FormatVariance(object varianceObj)
    {
        decimal v = 0;

        if (varianceObj != null && varianceObj != DBNull.Value)
            decimal.TryParse(varianceObj.ToString(), out v);

        return v.ToString("0.##");
    }
}

