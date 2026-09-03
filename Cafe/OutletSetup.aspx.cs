using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class OutletSetup : System.Web.UI.Page
{
    string conString = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (ConfigurationManager.ConnectionStrings["RestaurantConnectionString"] == null)
        {
            ShowMessage("Database connection not configured in web.config", "error");
            return;
        }

        if (!IsPostBack)
        {
            // Check for OutletID in query string
            if (!string.IsNullOrEmpty(Request.QueryString["OutletID"]))
            {
                int outletId;
                if (int.TryParse(Request.QueryString["OutletID"], out outletId))
                {
                    LoadOutletData(outletId);
                }
                else
                {
                    LoadOutletData(23); // Default
                }
            }
            else
            {
                LoadOutletData(23); // Default
            }

            // Load search grid
            LoadSearchGrid("");
        }
    }

    private void LoadOutletData(int outletId)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(conString))
            {
                con.Open();
                string query = "SELECT * FROM OutletSetup WHERE OutletID = @OutletID";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@OutletID", outletId);

                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    lblOutletID.Text = reader["OutletID"].ToString();
                    hdnOutletID.Value = reader["OutletID"].ToString();

                    txtMessage1.Text = reader["Message1"] != DBNull.Value ? reader["Message1"].ToString() : "";
                    txtMessage2.Text = reader["Message2"] != DBNull.Value ? reader["Message2"].ToString() : "";
                    txtMessage3.Text = reader["Message3"] != DBNull.Value ? reader["Message3"].ToString() : "";
                    txtAddress1.Text = reader["Address1"] != DBNull.Value ? reader["Address1"].ToString() : "";
                    txtAddress2.Text = reader["Address2"] != DBNull.Value ? reader["Address2"].ToString() : "";
                    txtAddress3.Text = reader["Address3"] != DBNull.Value ? reader["Address3"].ToString() : "";
                    txtNaration.Text = reader["Naration"] != DBNull.Value ? reader["Naration"].ToString() : "";
                    txtCostBudgetID.Text = reader["CostBudgetID"] != DBNull.Value ? reader["CostBudgetID"].ToString() : "";
                    txtChargeCode.Text = reader["ChargeCode"] != DBNull.Value ? reader["ChargeCode"].ToString() : "";
                    txtCashID.Text = reader["CashID"] != DBNull.Value ? reader["CashID"].ToString() : "";
                    txtCreditCardID.Text = reader["CreditCardID"] != DBNull.Value ? reader["CreditCardID"].ToString() : "";
                    txtIncome.Text = reader["Income"] != DBNull.Value ? reader["Income"].ToString() : "";
                    txtDiscount.Text = reader["Discount"] != DBNull.Value ? reader["Discount"].ToString() : "";
                    txtTaxAC1.Text = reader["TaxAC1"] != DBNull.Value ? reader["TaxAC1"].ToString() : "";
                    txtTaxPercentage1.Text = reader["TaxPercentage1"] != DBNull.Value ? reader["TaxPercentage1"].ToString() : "";
                    txtTaxAC2.Text = reader["TaxAC2"] != DBNull.Value ? reader["TaxAC2"].ToString() : "";
                    txtTaxPercentage2.Text = reader["TaxPercentage2"] != DBNull.Value ? reader["TaxPercentage2"].ToString() : "";
                    txtServiceChrAC.Text = reader["ServiceChrAC"] != DBNull.Value ? reader["ServiceChrAC"].ToString() : "";
                    txtServiceChrPercentage.Text = reader["ServiceChrPercentage"] != DBNull.Value ? reader["ServiceChrPercentage"].ToString() : "";
                    txtMemberAccount.Text = reader["MemberAccount"] != DBNull.Value ? reader["MemberAccount"].ToString() : "";
                    txtSalesAccount.Text = reader["SalesAccount"] != DBNull.Value ? reader["SalesAccount"].ToString() : "";
                    txtTaxPayableAccount.Text = reader["TaxPayableAccount"] != DBNull.Value ? reader["TaxPayableAccount"].ToString() : "";
                    txtTrBankCharges.Text = reader["TrBankCharges"] != DBNull.Value ? reader["TrBankCharges"].ToString() : "";
                    txtLodderAccount.Text = reader["LodderAccount"] != DBNull.Value ? reader["LodderAccount"].ToString() : "";
                    txtOtherAccount.Text = reader["OtherAccount"] != DBNull.Value ? reader["OtherAccount"].ToString() : "";

                    ShowMessage("Data loaded successfully", "info");
                }
                else
                {
                    ClearFields();
                    ShowMessage("No data found for Outlet ID: " + outletId, "info");
                }
                reader.Close();
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading data: " + ex.Message, "error");
        }
    }

    private void ClearFields()
    {
        txtMessage1.Text = "WE HOPE YOU HAVE ENJOYED YOUR VISIT. WE WELCOME YOUR COMMENTS AND SUGGESTIONS.";
        txtMessage2.Text = "";
        txtMessage3.Text = "";
        txtAddress1.Text = "";
        txtAddress2.Text = "";
        txtAddress3.Text = "";
        txtNaration.Text = "OUTLET SALE";
        txtCostBudgetID.Text = "";
        txtChargeCode.Text = "";
        txtCashID.Text = "";
        txtCreditCardID.Text = "";
        txtIncome.Text = "";
        txtDiscount.Text = "";
        txtTaxAC1.Text = "";
        txtTaxPercentage1.Text = "";
        txtTaxAC2.Text = "";
        txtTaxPercentage2.Text = "";
        txtServiceChrAC.Text = "";
        txtServiceChrPercentage.Text = "";
        txtMemberAccount.Text = "";
        txtSalesAccount.Text = "";
        txtTaxPayableAccount.Text = "";
        txtTrBankCharges.Text = "";
        txtLodderAccount.Text = "";
        txtOtherAccount.Text = "";
        hdnOutletID.Value = "0";
        lblOutletID.Text = "New";
    }

    private void ShowMessage(string message, string type)
    {
        lblStatus.Text = message;
        lblStatus.Visible = true;
        lblStatus.CssClass = "status-message " + type;
    }

    private bool ValidateInputs()
    {
        if (string.IsNullOrEmpty(txtAddress1.Text))
        {
            ShowMessage("Address 1 is required", "error");
            return false;
        }

        // Validate numeric fields
        if (!string.IsNullOrEmpty(txtCostBudgetID.Text))
        {
            int result;
            if (!int.TryParse(txtCostBudgetID.Text, out result))
            {
                ShowMessage("Cost/Budget ID must be a valid number", "error");
                return false;
            }
        }

        if (!string.IsNullOrEmpty(txtChargeCode.Text))
        {
            int result;
            if (!int.TryParse(txtChargeCode.Text, out result))
            {
                ShowMessage("Charge Code must be a valid number", "error");
                return false;
            }
        }

        if (!string.IsNullOrEmpty(txtCashID.Text))
        {
            int result;
            if (!int.TryParse(txtCashID.Text, out result))
            {
                ShowMessage("Cash ID must be a valid number", "error");
                return false;
            }
        }

        if (!string.IsNullOrEmpty(txtCreditCardID.Text))
        {
            int result;
            if (!int.TryParse(txtCreditCardID.Text, out result))
            {
                ShowMessage("Credit Card ID must be a valid number", "error");
                return false;
            }
        }

        return true;
    }

    private void LoadSearchGrid(string searchText)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(conString))
            {
                con.Open();
                string query = "SELECT OutletID, Address1, Message1 FROM OutletSetup";

                if (!string.IsNullOrEmpty(searchText))
                {
                    query += " WHERE OutletID LIKE @Search + '%' OR Address1 LIKE '%' + @Search + '%' OR Message1 LIKE '%' + @Search + '%'";
                }

                query += " ORDER BY OutletID";

                SqlCommand cmd = new SqlCommand(query, con);

                if (!string.IsNullOrEmpty(searchText))
                {
                    cmd.Parameters.AddWithValue("@Search", searchText);
                }

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvOutlets.DataSource = dt;
                gvOutlets.DataBind();
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading search results: " + ex.Message, "error");
        }
    }

    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(hdnOutletID.Value) && hdnOutletID.Value != "0")
        {
            LoadOutletData(Convert.ToInt32(hdnOutletID.Value));
        }
        else
        {
            LoadOutletData(23); // Default
        }
    }

    protected void btnNew_Click(object sender, EventArgs e)
    {
        ClearFields();
        ShowMessage("Enter new outlet data and click Save", "info");
    }

    protected void btnFind_Click(object sender, EventArgs e)
    {
        // Handled by OnClientClick
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!ValidateInputs())
        {
            return;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(conString))
            {
                con.Open();

                string query = @"INSERT INTO OutletSetup (
                    Message1, Message2, Message3, Address1, Address2, Address3,
                    Naration, CostBudgetID, ChargeCode, CashID, CreditCardID,
                    Income, Discount, TaxAC1, TaxPercentage1, TaxAC2, TaxPercentage2,
                    ServiceChrAC, ServiceChrPercentage, MemberAccount, SalesAccount,
                    TaxPayableAccount, TrBankCharges, LodderAccount, OtherAccount,
                    CreatedBy, CreatedOn
                ) VALUES (
                    @Message1, @Message2, @Message3, @Address1, @Address2, @Address3,
                    @Naration, @CostBudgetID, @ChargeCode, @CashID, @CreditCardID,
                    @Income, @Discount, @TaxAC1, @TaxPercentage1, @TaxAC2, @TaxPercentage2,
                    @ServiceChrAC, @ServiceChrPercentage, @MemberAccount, @SalesAccount,
                    @TaxPayableAccount, @TrBankCharges, @LodderAccount, @OtherAccount,
                    @CreatedBy, GETDATE()
                ); SELECT SCOPE_IDENTITY();";

                SqlCommand cmd = new SqlCommand(query, con);

                // Add parameters
                cmd.Parameters.AddWithValue("@Message1", txtMessage1.Text ?? "");
                cmd.Parameters.AddWithValue("@Message2", txtMessage2.Text ?? "");
                cmd.Parameters.AddWithValue("@Message3", txtMessage3.Text ?? "");
                cmd.Parameters.AddWithValue("@Address1", txtAddress1.Text ?? "");
                cmd.Parameters.AddWithValue("@Address2", txtAddress2.Text ?? "");
                cmd.Parameters.AddWithValue("@Address3", txtAddress3.Text ?? "");
                cmd.Parameters.AddWithValue("@Naration", txtNaration.Text ?? "");

                cmd.Parameters.AddWithValue("@CostBudgetID", string.IsNullOrEmpty(txtCostBudgetID.Text) ? (object)DBNull.Value : Convert.ToInt32(txtCostBudgetID.Text));
                cmd.Parameters.AddWithValue("@ChargeCode", string.IsNullOrEmpty(txtChargeCode.Text) ? (object)DBNull.Value : Convert.ToInt32(txtChargeCode.Text));
                cmd.Parameters.AddWithValue("@CashID", string.IsNullOrEmpty(txtCashID.Text) ? (object)DBNull.Value : Convert.ToInt32(txtCashID.Text));
                cmd.Parameters.AddWithValue("@CreditCardID", string.IsNullOrEmpty(txtCreditCardID.Text) ? (object)DBNull.Value : Convert.ToInt32(txtCreditCardID.Text));
                cmd.Parameters.AddWithValue("@Income", string.IsNullOrEmpty(txtIncome.Text) ? (object)DBNull.Value : Convert.ToInt32(txtIncome.Text));
                cmd.Parameters.AddWithValue("@Discount", string.IsNullOrEmpty(txtDiscount.Text) ? (object)DBNull.Value : Convert.ToInt32(txtDiscount.Text));

                cmd.Parameters.AddWithValue("@TaxAC1", string.IsNullOrEmpty(txtTaxAC1.Text) ? (object)DBNull.Value : Convert.ToInt32(txtTaxAC1.Text));
                cmd.Parameters.AddWithValue("@TaxPercentage1", string.IsNullOrEmpty(txtTaxPercentage1.Text) ? (object)DBNull.Value : Convert.ToDecimal(txtTaxPercentage1.Text));
                cmd.Parameters.AddWithValue("@TaxAC2", string.IsNullOrEmpty(txtTaxAC2.Text) ? (object)DBNull.Value : Convert.ToInt32(txtTaxAC2.Text));
                cmd.Parameters.AddWithValue("@TaxPercentage2", string.IsNullOrEmpty(txtTaxPercentage2.Text) ? (object)DBNull.Value : Convert.ToDecimal(txtTaxPercentage2.Text));
                cmd.Parameters.AddWithValue("@ServiceChrAC", string.IsNullOrEmpty(txtServiceChrAC.Text) ? (object)DBNull.Value : Convert.ToInt32(txtServiceChrAC.Text));
                cmd.Parameters.AddWithValue("@ServiceChrPercentage", string.IsNullOrEmpty(txtServiceChrPercentage.Text) ? (object)DBNull.Value : Convert.ToDecimal(txtServiceChrPercentage.Text));

                cmd.Parameters.AddWithValue("@MemberAccount", string.IsNullOrEmpty(txtMemberAccount.Text) ? (object)DBNull.Value : Convert.ToInt32(txtMemberAccount.Text));
                cmd.Parameters.AddWithValue("@SalesAccount", string.IsNullOrEmpty(txtSalesAccount.Text) ? (object)DBNull.Value : Convert.ToInt32(txtSalesAccount.Text));
                cmd.Parameters.AddWithValue("@TaxPayableAccount", string.IsNullOrEmpty(txtTaxPayableAccount.Text) ? (object)DBNull.Value : Convert.ToInt32(txtTaxPayableAccount.Text));
                cmd.Parameters.AddWithValue("@TrBankCharges", string.IsNullOrEmpty(txtTrBankCharges.Text) ? (object)DBNull.Value : Convert.ToInt32(txtTrBankCharges.Text));
                cmd.Parameters.AddWithValue("@LodderAccount", string.IsNullOrEmpty(txtLodderAccount.Text) ? (object)DBNull.Value : Convert.ToInt32(txtLodderAccount.Text));
                cmd.Parameters.AddWithValue("@OtherAccount", string.IsNullOrEmpty(txtOtherAccount.Text) ? (object)DBNull.Value : Convert.ToInt32(txtOtherAccount.Text));

                cmd.Parameters.AddWithValue("@CreatedBy", Session["Emp_ID"] != null ? Convert.ToInt32(Session["Emp_ID"]) : (object)DBNull.Value);

                int newId = Convert.ToInt32(cmd.ExecuteScalar());

                if (newId > 0)
                {
                    hdnOutletID.Value = newId.ToString();
                    lblOutletID.Text = newId.ToString();
                    ShowMessage("Outlet saved successfully! ID: " + newId, "success");
                    LoadSearchGrid(""); // Refresh search grid
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error saving data: " + ex.Message, "error");
        }
    }

    protected void btnUpdate_Click(object sender, EventArgs e)
    {
        if (!ValidateInputs())
        {
            return;
        }

        try
        {
            if (string.IsNullOrEmpty(hdnOutletID.Value) || hdnOutletID.Value == "0")
            {
                ShowMessage("Please save the record first", "error");
                return;
            }

            using (SqlConnection con = new SqlConnection(conString))
            {
                con.Open();

                string query = @"UPDATE OutletSetup SET
                    Message1 = @Message1,
                    Message2 = @Message2,
                    Message3 = @Message3,
                    Address1 = @Address1,
                    Address2 = @Address2,
                    Address3 = @Address3,
                    Naration = @Naration,
                    CostBudgetID = @CostBudgetID,
                    ChargeCode = @ChargeCode,
                    CashID = @CashID,
                    CreditCardID = @CreditCardID,
                    Income = @Income,
                    Discount = @Discount,
                    TaxAC1 = @TaxAC1,
                    TaxPercentage1 = @TaxPercentage1,
                    TaxAC2 = @TaxAC2,
                    TaxPercentage2 = @TaxPercentage2,
                    ServiceChrAC = @ServiceChrAC,
                    ServiceChrPercentage = @ServiceChrPercentage,
                    MemberAccount = @MemberAccount,
                    SalesAccount = @SalesAccount,
                    TaxPayableAccount = @TaxPayableAccount,
                    TrBankCharges = @TrBankCharges,
                    LodderAccount = @LodderAccount,
                    OtherAccount = @OtherAccount,
                    UpdatedBy = @UpdatedBy,
                    UpdatedOn = GETDATE()
                WHERE OutletID = @OutletID";

                SqlCommand cmd = new SqlCommand(query, con);

                cmd.Parameters.AddWithValue("@OutletID", Convert.ToInt32(hdnOutletID.Value));
                cmd.Parameters.AddWithValue("@Message1", txtMessage1.Text ?? "");
                cmd.Parameters.AddWithValue("@Message2", txtMessage2.Text ?? "");
                cmd.Parameters.AddWithValue("@Message3", txtMessage3.Text ?? "");
                cmd.Parameters.AddWithValue("@Address1", txtAddress1.Text ?? "");
                cmd.Parameters.AddWithValue("@Address2", txtAddress2.Text ?? "");
                cmd.Parameters.AddWithValue("@Address3", txtAddress3.Text ?? "");
                cmd.Parameters.AddWithValue("@Naration", txtNaration.Text ?? "");

                cmd.Parameters.AddWithValue("@CostBudgetID", string.IsNullOrEmpty(txtCostBudgetID.Text) ? (object)DBNull.Value : Convert.ToInt32(txtCostBudgetID.Text));
                cmd.Parameters.AddWithValue("@ChargeCode", string.IsNullOrEmpty(txtChargeCode.Text) ? (object)DBNull.Value : Convert.ToInt32(txtChargeCode.Text));
                cmd.Parameters.AddWithValue("@CashID", string.IsNullOrEmpty(txtCashID.Text) ? (object)DBNull.Value : Convert.ToInt32(txtCashID.Text));
                cmd.Parameters.AddWithValue("@CreditCardID", string.IsNullOrEmpty(txtCreditCardID.Text) ? (object)DBNull.Value : Convert.ToInt32(txtCreditCardID.Text));
                cmd.Parameters.AddWithValue("@Income", string.IsNullOrEmpty(txtIncome.Text) ? (object)DBNull.Value : Convert.ToInt32(txtIncome.Text));
                cmd.Parameters.AddWithValue("@Discount", string.IsNullOrEmpty(txtDiscount.Text) ? (object)DBNull.Value : Convert.ToInt32(txtDiscount.Text));

                cmd.Parameters.AddWithValue("@TaxAC1", string.IsNullOrEmpty(txtTaxAC1.Text) ? (object)DBNull.Value : Convert.ToInt32(txtTaxAC1.Text));
                cmd.Parameters.AddWithValue("@TaxPercentage1", string.IsNullOrEmpty(txtTaxPercentage1.Text) ? (object)DBNull.Value : Convert.ToDecimal(txtTaxPercentage1.Text));
                cmd.Parameters.AddWithValue("@TaxAC2", string.IsNullOrEmpty(txtTaxAC2.Text) ? (object)DBNull.Value : Convert.ToInt32(txtTaxAC2.Text));
                cmd.Parameters.AddWithValue("@TaxPercentage2", string.IsNullOrEmpty(txtTaxPercentage2.Text) ? (object)DBNull.Value : Convert.ToDecimal(txtTaxPercentage2.Text));
                cmd.Parameters.AddWithValue("@ServiceChrAC", string.IsNullOrEmpty(txtServiceChrAC.Text) ? (object)DBNull.Value : Convert.ToInt32(txtServiceChrAC.Text));
                cmd.Parameters.AddWithValue("@ServiceChrPercentage", string.IsNullOrEmpty(txtServiceChrPercentage.Text) ? (object)DBNull.Value : Convert.ToDecimal(txtServiceChrPercentage.Text));

                cmd.Parameters.AddWithValue("@MemberAccount", string.IsNullOrEmpty(txtMemberAccount.Text) ? (object)DBNull.Value : Convert.ToInt32(txtMemberAccount.Text));
                cmd.Parameters.AddWithValue("@SalesAccount", string.IsNullOrEmpty(txtSalesAccount.Text) ? (object)DBNull.Value : Convert.ToInt32(txtSalesAccount.Text));
                cmd.Parameters.AddWithValue("@TaxPayableAccount", string.IsNullOrEmpty(txtTaxPayableAccount.Text) ? (object)DBNull.Value : Convert.ToInt32(txtTaxPayableAccount.Text));
                cmd.Parameters.AddWithValue("@TrBankCharges", string.IsNullOrEmpty(txtTrBankCharges.Text) ? (object)DBNull.Value : Convert.ToInt32(txtTrBankCharges.Text));
                cmd.Parameters.AddWithValue("@LodderAccount", string.IsNullOrEmpty(txtLodderAccount.Text) ? (object)DBNull.Value : Convert.ToInt32(txtLodderAccount.Text));
                cmd.Parameters.AddWithValue("@OtherAccount", string.IsNullOrEmpty(txtOtherAccount.Text) ? (object)DBNull.Value : Convert.ToInt32(txtOtherAccount.Text));

                cmd.Parameters.AddWithValue("@UpdatedBy", Session["Emp_ID"] != null ? Convert.ToInt32(Session["Emp_ID"]) : (object)DBNull.Value);

                int rowsAffected = cmd.ExecuteNonQuery();

                if (rowsAffected > 0)
                {
                    ShowMessage("Outlet updated successfully!", "success");
                    LoadSearchGrid(""); // Refresh search grid
                }
                else
                {
                    ShowMessage("No changes made", "info");
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error updating data: " + ex.Message, "error");
        }
    }

    protected void btnDelete_Click(object sender, EventArgs e)
    {
        // Handled by OnClientClick
    }

    protected void btnConfirmDelete_Click(object sender, EventArgs e)
    {
        try
        {
            if (string.IsNullOrEmpty(hdnOutletID.Value) || hdnOutletID.Value == "0")
            {
                ShowMessage("No record selected to delete", "error");
                return;
            }

            int outletId = Convert.ToInt32(hdnOutletID.Value);

            using (SqlConnection con = new SqlConnection(conString))
            {
                con.Open();

                string query = "DELETE FROM OutletSetup WHERE OutletID = @OutletID";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@OutletID", outletId);

                int rowsAffected = cmd.ExecuteNonQuery();

                if (rowsAffected > 0)
                {
                    ClearFields();
                    ShowMessage("Outlet deleted successfully!", "success");
                    LoadSearchGrid(""); // Refresh search grid
                }
                else
                {
                    ShowMessage("No record found to delete", "error");
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error deleting data: " + ex.Message, "error");
        }
    }

    protected void btnClose_Click(object sender, EventArgs e)
    {
        // Close button - handled by OnClientClick
    }

    // Search Panel Methods
    protected void txtSearch_TextChanged(object sender, EventArgs e)
    {
        LoadSearchGrid(txtSearch.Text);
    }

    protected void gvOutlets_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvOutlets.PageIndex = e.NewPageIndex;
        LoadSearchGrid(txtSearch.Text);
    }

    protected void gvOutlets_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "SelectOutlet")
        {
            int outletId = Convert.ToInt32(e.CommandArgument);
            LoadOutletData(outletId);

            // Hide search panel via JavaScript
            string script = "hideSearchPanel();";
            ScriptManager.RegisterStartupScript(this, GetType(), "HideSearch", script, true);
        }
    }
}


