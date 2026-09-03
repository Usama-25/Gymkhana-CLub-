using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
namespace GuestRoomApp.GuestRoomM
{
    public partial class ItemDefinition : System.Web.UI.Page
    {
    // ?? Connection String from Web.config ??
    private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

    // ????????????????????????????????????????
    //  PAGE LOAD
    // ????????????????????????????????????????
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadCategories();
            LoadLocations();
            LoadFilterCategories();
            LoadGrid(null, null);
            SetNextItemID();
        }
    }

    // ????????????????????????????????????????
    //  LOAD DROPDOWNS
    // ????????????????????????????????????????
    private void LoadCategories()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        using (SqlCommand cmd = new SqlCommand("sp_GR_GetCategories", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            con.Open();
            SqlDataReader dr = cmd.ExecuteReader();

            ddlCategory.Items.Clear();
            ddlCategory.Items.Add(new ListItem("?? Select Category ??", "0"));

            while (dr.Read())
            {
                ddlCategory.Items.Add(new ListItem(
                    dr["CategoryName"].ToString(),
                    dr["CategoryID"].ToString()
                ));
            }
        }
    }

    private void LoadLocations()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        using (SqlCommand cmd = new SqlCommand("sp_GR_GetLocations", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            con.Open();
            SqlDataReader dr = cmd.ExecuteReader();

            ddlLocation.Items.Clear();
            ddlLocation.Items.Add(new ListItem("?? Select Location ??", "0"));

            while (dr.Read())
            {
                ddlLocation.Items.Add(new ListItem(
                    dr["LocationName"].ToString(),
                    dr["LocationID"].ToString()
                ));
            }
        }
    }

    private void LoadFilterCategories()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        using (SqlCommand cmd = new SqlCommand("sp_GR_GetCategories", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            con.Open();
            SqlDataReader dr = cmd.ExecuteReader();

            ddlFilterCategory.Items.Clear();
            ddlFilterCategory.Items.Add(new ListItem("?? All Categories ??", ""));

            while (dr.Read())
            {
                ddlFilterCategory.Items.Add(new ListItem(
                    dr["CategoryName"].ToString(),
                    dr["CategoryID"].ToString()
                ));
            }
        }
    }

    // ????????????????????????????????????????
    //  SET NEXT ITEM ID (display only)
    // ????????????????????????????????????????
    private void SetNextItemID()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        using (SqlCommand cmd = new SqlCommand(
            "SELECT ISNULL(MAX(ItemID), 0) + 1 FROM GR_Items", con))
        {
            con.Open();
            int nextID = (int)cmd.ExecuteScalar();
            txtItemID.Text = nextID.ToString();
        }
    }

    // ????????????????????????????????????????
    //  CATEGORY CHANGED ? AUTO-GENERATE CODE
    // ????????????????????????????????????????
    protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlCategory.SelectedValue == "0")
        {
            txtItemCode.Text = "";
            return;
        }

        // Only generate new code when ADDING (not editing)
        if (hfItemID.Value == "0")
        {
            GenerateItemCode(int.Parse(ddlCategory.SelectedValue));
        }
    }

    private void GenerateItemCode(int categoryID)
    {
        using (SqlConnection con = new SqlConnection(connStr))
        using (SqlCommand cmd = new SqlCommand("sp_GR_GenerateItemCode", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@CategoryID", categoryID);

            SqlParameter outParam = new SqlParameter("@NewItemCode", SqlDbType.NVarChar, 20);
            outParam.Direction = ParameterDirection.Output;
            cmd.Parameters.Add(outParam);

            con.Open();
            cmd.ExecuteNonQuery();

            txtItemCode.Text = outParam.Value.ToString();
        }
    }

    // ????????????????????????????????????????
    //  LOAD GRID
    // ????????????????????????????????????????
    private void LoadGrid(string searchTerm, string categoryID)
    {
        DataTable dt = new DataTable();

        using (SqlConnection con = new SqlConnection(connStr))
        {
            SqlCommand cmd;

            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                // Search mode
                cmd = new SqlCommand("sp_GR_SearchItems", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SearchTerm", searchTerm.Trim());
            }
            else
            {
                // Filter by category
                cmd = new SqlCommand("sp_GR_GetItems", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@CategoryID", SqlDbType.Int).Value =
                    string.IsNullOrEmpty(categoryID) ? (object)DBNull.Value : int.Parse(categoryID);
                cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = DBNull.Value;
            }

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            con.Open();
            da.Fill(dt);
        }

        gvItems.DataSource = dt;
        gvItems.DataBind();

        lblItemCount.Text = dt.Rows.Count + " Item" + (dt.Rows.Count != 1 ? "s" : "");
    }

    // ????????????????????????????????????????
    //  SAVE NEW ITEM
    // ????????????????????????????????????????
    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!ValidateForm()) return;

        using (SqlConnection con = new SqlConnection(connStr))
        using (SqlCommand cmd = new SqlCommand("sp_GR_InsertItem", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ItemCode", txtItemCode.Text.Trim());
            cmd.Parameters.AddWithValue("@ItemName", txtItemName.Text.Trim());
            cmd.Parameters.AddWithValue("@CategoryID", int.Parse(ddlCategory.SelectedValue));
            cmd.Parameters.AddWithValue("@LocationID", int.Parse(ddlLocation.SelectedValue));
            cmd.Parameters.AddWithValue("@UnitPrice", decimal.Parse(txtUnitPrice.Text == "" ? "0" : txtUnitPrice.Text));
            cmd.Parameters.AddWithValue("@StockQty", int.Parse(txtStockQty.Text == "" ? "0" : txtStockQty.Text));
            cmd.Parameters.AddWithValue("@Description", txtDescription.Text.Trim());

            SqlParameter outID = new SqlParameter("@NewItemID", SqlDbType.Int);
            outID.Direction = ParameterDirection.Output;
            cmd.Parameters.Add(outID);

            con.Open();
            cmd.ExecuteNonQuery();

            int newID = (int)outID.Value;

            if (newID == -1)
            {
                ShowMessage("Item Code already exists. Please select a different category or check existing items.", false);
                return;
            }
            if (newID == -99)
            {
                ShowMessage("Database error occurred. Please try again.", false);
                return;
            }
        }

        ShowMessage("? Item saved successfully!", true);
        ClearForm();
        LoadGrid(null, null);
    }

    // ????????????????????????????????????????
    //  UPDATE ITEM
    // ????????????????????????????????????????
    protected void btnUpdate_Click(object sender, EventArgs e)
    {
        if (!ValidateForm()) return;

        using (SqlConnection con = new SqlConnection(connStr))
        using (SqlCommand cmd = new SqlCommand("sp_GR_UpdateItem", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ItemID", int.Parse(hfItemID.Value));
            cmd.Parameters.AddWithValue("@ItemCode", txtItemCode.Text.Trim());
            cmd.Parameters.AddWithValue("@ItemName", txtItemName.Text.Trim());
            cmd.Parameters.AddWithValue("@CategoryID", int.Parse(ddlCategory.SelectedValue));
            cmd.Parameters.AddWithValue("@LocationID", int.Parse(ddlLocation.SelectedValue));
            cmd.Parameters.AddWithValue("@UnitPrice", decimal.Parse(txtUnitPrice.Text == "" ? "0" : txtUnitPrice.Text));
            cmd.Parameters.AddWithValue("@StockQty", int.Parse(txtStockQty.Text == "" ? "0" : txtStockQty.Text));
            cmd.Parameters.AddWithValue("@Description", txtDescription.Text.Trim());
            cmd.Parameters.AddWithValue("@IsActive", ddlStatus.SelectedValue == "1");

            SqlParameter outRows = new SqlParameter("@RowsAffected", SqlDbType.Int);
            outRows.Direction = ParameterDirection.Output;
            cmd.Parameters.Add(outRows);

            con.Open();
            cmd.ExecuteNonQuery();
        }

        ShowMessage("? Item updated successfully!", true);
        ClearForm();
        LoadGrid(null, null);
    }

    // ????????????????????????????????????????
    //  GRID ROW COMMANDS (Edit / Delete)
    // ????????????????????????????????????????
    protected void gvItems_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int itemID = int.Parse(e.CommandArgument.ToString());

        if (e.CommandName == "EditItem")
        {
            LoadItemForEdit(itemID);
        }
        else if (e.CommandName == "DeleteItem")
        {
            DeleteItem(itemID);
        }
    }

    private void LoadItemForEdit(int itemID)
    {
        using (SqlConnection con = new SqlConnection(connStr))
        using (SqlCommand cmd = new SqlCommand("sp_GR_GetItemByID", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ItemID", itemID);

            con.Open();
            SqlDataReader dr = cmd.ExecuteReader();

            if (dr.Read())
            {
                hfItemID.Value = dr["ItemID"].ToString();
                txtItemID.Text = dr["ItemID"].ToString();
                txtItemCode.Text = dr["ItemCode"].ToString();
                txtItemName.Text = dr["ItemName"].ToString();
                txtUnitPrice.Text = dr["UnitPrice"].ToString();
                txtStockQty.Text = dr["StockQty"].ToString();
                txtDescription.Text = dr["Description"].ToString();

                ddlCategory.SelectedValue = dr["CategoryID"].ToString();
                ddlLocation.SelectedValue = dr["LocationID"].ToString();
                ddlStatus.SelectedValue = Convert.ToBoolean(dr["IsActive"]) ? "1" : "0";
            }
        }

        // Switch buttons
        btnSave.Visible = false;
        btnUpdate.Visible = true;
        lblFormTitle.Text = "?? Edit Item — " + txtItemCode.Text;

        // Scroll to top
        ScriptManager.RegisterStartupScript(this, GetType(), "scroll",
            "window.scrollTo(0,0);", true);
    }

    private void DeleteItem(int itemID)
    {
        using (SqlConnection con = new SqlConnection(connStr))
        using (SqlCommand cmd = new SqlCommand("sp_GR_DeleteItem", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ItemID", itemID);
            con.Open();
            cmd.ExecuteNonQuery();
        }

        ShowMessage("??? Item deactivated successfully.", true);
        LoadGrid(null, null);
    }

    // ????????????????????????????????????????
    //  SEARCH
    // ????????????????????????????????????????
    protected void btnSearch_Click(object sender, EventArgs e)
    {
        string search = txtSearch.Text.Trim();
        string catID = ddlFilterCategory.SelectedValue;

        if (!string.IsNullOrEmpty(search))
            LoadGrid(search, null);
        else
            LoadGrid(null, catID);
    }

    protected void btnShowAll_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        ddlFilterCategory.SelectedIndex = 0;
        LoadGrid(null, null);
    }

    // ????????????????????????????????????????
    //  CLEAR FORM
    // ????????????????????????????????????????
    protected void btnClear_Click(object sender, EventArgs e)
    {
        ClearForm();
    }

    private void ClearForm()
    {
        hfItemID.Value = "0";
        txtItemCode.Text = "";
        txtItemName.Text = "";
        txtUnitPrice.Text = "0";
        txtStockQty.Text = "0";
        txtDescription.Text = "";
        ddlCategory.SelectedIndex = 0;
        ddlLocation.SelectedIndex = 0;
        ddlStatus.SelectedValue = "1";

        btnSave.Visible = true;
        btnUpdate.Visible = false;
        lblFormTitle.Text = "? Add New Item";

        SetNextItemID();
    }

    // ????????????????????????????????????????
    //  VALIDATION
    // ????????????????????????????????????????
    private bool ValidateForm()
    {
        if (ddlCategory.SelectedValue == "0")
        {
            ShowMessage("Please select a Category.", false);
            return false;
        }
        if (ddlLocation.SelectedValue == "0")
        {
            ShowMessage("Please select a Location.", false);
            return false;
        }
        if (string.IsNullOrWhiteSpace(txtItemName.Text))
        {
            ShowMessage("Item Name is required.", false);
            return false;
        }
        return true;
    }

    // ????????????????????????????????????????
    //  SHOW MESSAGE
    // ????????????????????????????????????????
    private void ShowMessage(string msg, bool success)
    {
        lblMessage.Text = msg;
        lblMessage.CssClass = "alert show " + (success ? "alert-success" : "alert-error");
    }
}
}


