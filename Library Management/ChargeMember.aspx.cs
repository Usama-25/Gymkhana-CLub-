using System.Configuration;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Pages_Members_ChargeMember : System.Web.UI.Page
{
    private short CurrentStaffID = 1; // Librarian session mock

    protected void Page_Load(object sender, EventArgs e)
    {
        pnlAlert.Visible = false;
        ClearPolicyWarnings();
        
        if (Session["StaffID"] != null)
        {
            CurrentStaffID = Convert.ToInt16(Session["StaffID"]);
        }

        if (!IsPostBack)
        {
            // Set default active tab
            SetActiveTab("CHARGE");
            BindFacilitiesDropdown();
            BindFineReasonsDropdown();
            txtFacilityDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            BindChargeBasket();
        }
    }

    // =========================================================================
    //  TAB MANAGEMENT
    // =========================================================================
    protected void btnTab_Click(object sender, EventArgs e)
    {
        string tab = ((Button)sender).CommandArgument;
        SetActiveTab(tab);
    }

    private void SetActiveTab(string tab)
    {
        ClearPolicyWarnings();
        hfActiveTab.Value = tab;
        pnlTabCharge.Visible = (tab == "CHARGE");
        pnlTabVoucher.Visible = (tab == "VOUCHER");
        pnlTabCashier.Visible = (tab == "CASHIER");
        pnlPrintSlip.Visible = false;

        string activeStyle = "padding: 12px 24px; font-size: 14px; font-weight: 700; color: #c5a059; background: transparent; border: none; border-bottom: 3px solid #c5a059; cursor: pointer; transition: all 0.2s ease; outline: none;";
        string inactiveStyle = "padding: 12px 24px; font-size: 14px; font-weight: 600; color: #64748b; background: transparent; border: none; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.2s ease; outline: none;";

        btnTabCharge.Attributes["style"] = (tab == "CHARGE" ? activeStyle : inactiveStyle);
        btnTabVoucher.Attributes["style"] = (tab == "VOUCHER" ? activeStyle : inactiveStyle);
        btnTabCashier.Attributes["style"] = (tab == "CASHIER" ? activeStyle : inactiveStyle);
    }

    // =========================================================================
    //  LOOKUPS BINDING
    // =========================================================================
    private void BindFacilitiesDropdown()
    {
        DataTable dt = DBHelper.GetFacilities();
        ddlFacility.DataSource = dt;
        ddlFacility.DataTextField = "FacilityName";
        ddlFacility.DataValueField = "FacilityID";
        ddlFacility.DataBind();
        ddlFacility.Items.Insert(0, new ListItem("- Select Facility -", "0"));
    }

    private void BindFineReasonsDropdown()
    {
        DataTable dt = DBHelper.GetFineReasons();
        ddlFineReason.DataSource = dt;
        ddlFineReason.DataTextField = "ReasonName";
        ddlFineReason.DataValueField = "ReasonID";
        ddlFineReason.DataBind();
        ddlFineReason.Items.Insert(0, new ListItem("- Select Fine Type -", "0"));
    }

    private void BindActiveLoansDropdown(int memberID)
    {
        ddlActiveLoans.Items.Clear();
        // Load active loans
        DataTable dt = DBHelper.GetMemberLoans(memberID, true);
        if (dt != null && dt.Rows.Count > 0)
        {
            foreach (DataRow row in dt.Rows)
            {
                string title = row["Title"].ToString();
                string barcode = row["Barcode"].ToString();
                string loanID = row["LoanID"].ToString();
                ddlActiveLoans.Items.Add(new ListItem(title + " (" + barcode + ")", loanID));
            }
        }
        ddlActiveLoans.Items.Insert(0, new ListItem("- No Specific Book (General Fee) -", "0"));
    }

    // =========================================================================
    //  TAB 1: LOG CHARGE LOGIC
    // =========================================================================
    protected void btnSelectChargeMember_Click(object sender, EventArgs e)
    {
        string searchText = txtChargeMemberSearch.Text.Trim();
        if (string.IsNullOrEmpty(searchText))
        {
            ShowAlert("Please enter a member to search.", false);
            return;
        }

        if (searchText.Contains(" - "))
        {
            searchText = searchText.Substring(0, searchText.IndexOf(" - ")).Trim();
        }

        DataTable dt = DBHelper.GetMembers(searchText);
        int? memberID = null;

        foreach (DataRow row in dt.Rows)
        {
            if (row["MembershipNo"].ToString().Equals(searchText, StringComparison.OrdinalIgnoreCase) ||
                row["FullName"].ToString().Equals(searchText, StringComparison.OrdinalIgnoreCase) ||
                row["MemberDisplay"].ToString().Equals(searchText, StringComparison.OrdinalIgnoreCase))
            {
                memberID = Convert.ToInt32(row["MemberID"]);
                lblChargeMemberNo.Text = row["MembershipNo"].ToString();
                lblChargeMemberName.Text = row["FullName"].ToString();
                break;
            }
        }

        if (memberID == null && dt.Rows.Count > 0)
        {
            memberID = Convert.ToInt32(dt.Rows[0]["MemberID"]);
            lblChargeMemberNo.Text = dt.Rows[0]["MembershipNo"].ToString();
            lblChargeMemberName.Text = dt.Rows[0]["FullName"].ToString();
        }

        if (memberID != null)
        {
            hfChargeMemberID.Value = memberID.ToString();
            pnlChargeForm.Visible = true;
            pnlChargeBasketContainer.Visible = true;
            BindActiveLoansDropdown(memberID.Value);
            ResetChargeInputs();
            ChargeBasketTable = null;
            BindChargeBasket();
        }
        else
        {
            pnlChargeForm.Visible = false;
            pnlChargeBasketContainer.Visible = false;
            ShowAlert("Member not found.", false);
        }
    }

    protected void ddlChargeType_SelectedIndexChanged(object sender, EventArgs e)
    {
        ClearPolicyWarnings();
        bool isFacility = (ddlChargeType.SelectedValue == "FACILITY");
        pnlFacilityFields.Visible = isFacility;
        pnlFineFields.Visible = !isFacility;
    }

    protected void ddlFacility_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlFacility.SelectedValue != "0")
        {
            int facID = Convert.ToInt32(ddlFacility.SelectedValue);
            DataTable dt = DBHelper.GetFacilities();
            DataRow[] rows = dt.Select("FacilityID = " + facID);
            if (rows.Length > 0)
            {
                decimal rate = Convert.ToDecimal(rows[0]["CostPerHour"]);
                txtFacilityRate.Text = rate.ToString("0.00");
                CalculateFacilityTotal();
            }
        }
        else
        {
            txtFacilityRate.Text = "";
            txtFacilityTotal.Text = "";
        }
    }

    protected void txtHoursUsed_TextChanged(object sender, EventArgs e)
    {
        CalculateFacilityTotal();
    }

    private void CalculateFacilityTotal()
    {
        decimal rate = 0;
        decimal hours = 0;
        if (decimal.TryParse(txtFacilityRate.Text, out rate) && decimal.TryParse(txtHoursUsed.Text, out hours))
        {
            txtFacilityTotal.Text = (rate * hours).ToString("0.00");
        }
        else
        {
            txtFacilityTotal.Text = "";
        }
    }

    protected void ddlFineReason_SelectedIndexChanged(object sender, EventArgs e)
    {
        ClearPolicyWarnings();
        if (ddlFineReason.SelectedValue != "0")
        {
            int reasonID = Convert.ToInt32(ddlFineReason.SelectedValue);
            
            if (ddlActiveLoans.SelectedValue != "0")
            {
                CalculateFineAmount();
            }
            else
            {
                DataTable dt = DBHelper.GetFineReasons();
                DataRow[] rows = dt.Select("ReasonID = " + reasonID);
                if (rows.Length > 0)
                {
                    decimal amt = Convert.ToDecimal(rows[0]["DefaultAmount"]);
                    txtFineAmount.Text = amt.ToString("0.00");
                }
            }

            List<string> warnings = new List<string>();
            if (reasonID == 2) // Lost Book
            {
                warnings.Add("Lost Book Policy: Lost books are charged original cost + 200% extra.");
            }
            else if (reasonID == 3) // Damage
            {
                warnings.Add("Damage Liability: Members returning a damaged book are liable for rebinding or replacement. The decision of the Convener Library is final.");
            }

            if (warnings.Count > 0)
            {
                ShowPolicyWarnings(warnings);
            }
        }
        else
        {
            txtFineAmount.Text = "";
        }
    }

    protected void ddlActiveLoans_SelectedIndexChanged(object sender, EventArgs e)
    {
        CalculateFineAmount();
    }

    private void CalculateFineAmount()
    {
        if (ddlActiveLoans.SelectedValue == "0")
        {
            if (ddlFineReason.SelectedValue != "0")
            {
                int reasonID = Convert.ToInt32(ddlFineReason.SelectedValue);
                DataTable dt = DBHelper.GetFineReasons();
                DataRow[] rows = dt.Select("ReasonID = " + reasonID);
                if (rows.Length > 0)
                {
                    decimal amt = Convert.ToDecimal(rows[0]["DefaultAmount"]);
                    txtFineAmount.Text = amt.ToString("0.00");
                }
            }
            else
            {
                txtFineAmount.Text = "";
            }
            return;
        }

        int loanID = Convert.ToInt32(ddlActiveLoans.SelectedValue);
        DataTable dtLoan = DBHelper.GetLoanDetailsForCalculation(loanID);
        if (dtLoan != null && dtLoan.Rows.Count > 0)
        {
            DataRow row = dtLoan.Rows[0];
            DateTime dueDate = Convert.ToDateTime(row["DueDate"]);
            decimal finePerDay = row["FinePerDay"] != DBNull.Value ? Convert.ToDecimal(row["FinePerDay"]) : 10.00m;
            decimal acqCost = row["AcqCost"] != DBNull.Value ? Convert.ToDecimal(row["AcqCost"]) : 0.00m;
            string pricePkrStr = row["PricePkr"] != DBNull.Value ? row["PricePkr"].ToString() : "";
            
            decimal bookCost = acqCost;
            if (bookCost == 0 && !string.IsNullOrEmpty(pricePkrStr))
            {
                string cleanPrice = System.Text.RegularExpressions.Regex.Replace(pricePkrStr, @"[^\d\.]", "");
                decimal.TryParse(cleanPrice, out bookCost);
            }
            if (bookCost == 0)
            {
                bookCost = 500.00m; // Fallback default
            }

            int reasonID = Convert.ToInt32(ddlFineReason.SelectedValue);
            if (reasonID == 1) // Overdue
            {
                int overdueDays = (DateTime.Today - dueDate.Date).Days;
                if (overdueDays > 0)
                {
                    decimal fineAmount = overdueDays * finePerDay;
                    txtFineAmount.Text = fineAmount.ToString("0.00");
                    txtChargeRemarks.Text = string.Format("Overdue fine: {0} days overdue (Due: {1:dd-MMM-yyyy}) @ Rs. {2:0.00}/day.", 
                        overdueDays, dueDate, finePerDay);
                }
                else
                {
                    txtFineAmount.Text = "0.00";
                    txtChargeRemarks.Text = string.Format("Book not overdue (Due: {0:dd-MMM-yyyy}). No overdue fine.", dueDate);
                }
            }
            else if (reasonID == 2) // Lost Book
            {
                decimal penalty = bookCost * 2.00m; // 200% extra
                decimal totalLostFine = bookCost + penalty;
                txtFineAmount.Text = totalLostFine.ToString("0.00");
                txtChargeRemarks.Text = string.Format("Lost book charge: Cost (Rs. {0:0.00}) + 200% Penalty (Rs. {1:0.00}). Total = Rs. {2:0.00}.", 
                    bookCost, penalty, totalLostFine);
            }
            else if (reasonID == 3) // Damage
            {
                DataTable dtReasons = DBHelper.GetFineReasons();
                DataRow[] rows = dtReasons.Select("ReasonID = " + reasonID);
                decimal defaultAmt = rows.Length > 0 ? Convert.ToDecimal(rows[0]["DefaultAmount"]) : 250.00m;
                txtFineAmount.Text = defaultAmt.ToString("0.00");
                txtChargeRemarks.Text = "Damaged book charge. Final rebinding/replacement cost subject to Convenor Library approval.";
            }
            else
            {
                if (reasonID != 0)
                {
                    DataTable dtReasons = DBHelper.GetFineReasons();
                    DataRow[] rows = dtReasons.Select("ReasonID = " + reasonID);
                    decimal defaultAmt = rows.Length > 0 ? Convert.ToDecimal(rows[0]["DefaultAmount"]) : 0.00m;
                    txtFineAmount.Text = defaultAmt.ToString("0.00");
                }
                else
                {
                    txtFineAmount.Text = "";
                }
            }
        }
    }

    private DataTable ChargeBasketTable
    {
        get
        {
            DataTable dt = ViewState["PendingChargesBasket"] as DataTable;
            if (dt == null)
            {
                dt = new DataTable();
                dt.Columns.Add("Type", typeof(string));
                dt.Columns.Add("TypeDisplay", typeof(string));
                dt.Columns.Add("ItemID", typeof(int));
                dt.Columns.Add("ItemName", typeof(string));
                dt.Columns.Add("UsageDate", typeof(DateTime));
                dt.Columns.Add("HoursUsed", typeof(decimal));
                dt.Columns.Add("LoanID", typeof(int));
                dt.Columns.Add("LoanDisplay", typeof(string));
                dt.Columns.Add("Remarks", typeof(string));
                dt.Columns.Add("Amount", typeof(decimal));
                ViewState["PendingChargesBasket"] = dt;
            }
            return dt;
        }
        set
        {
            ViewState["PendingChargesBasket"] = value;
        }
    }

    private void BindChargeBasket()
    {
        DataTable dt = ChargeBasketTable;
        gvChargeBasket.DataSource = dt;
        gvChargeBasket.DataBind();

        bool hasItems = dt != null && dt.Rows.Count > 0;
        pnlChargeBasketEmpty.Visible = !hasItems;
        divConfirmCharges.Style["display"] = hasItems ? "flex" : "none";

        // Calculate total
        decimal total = 0;
        if (hasItems)
        {
            foreach (DataRow row in dt.Rows)
            {
                total += Convert.ToDecimal(row["Amount"]);
            }
        }
        divBasketTotal.InnerText = "Rs. " + total.ToString("N2");
    }

    protected void btnAddToBasket_Click(object sender, EventArgs e)
    {
        try
        {
            int memberID = Convert.ToInt32(hfChargeMemberID.Value);
            string remarks = txtChargeRemarks.Text.Trim();

            DataTable basket = ChargeBasketTable;

            if (ddlChargeType.SelectedValue == "FACILITY")
            {
                if (ddlFacility.SelectedValue == "0")
                {
                    ShowAlert("Please select a facility.", false);
                    return;
                }
                decimal hours, totalCharges;
                if (!decimal.TryParse(txtHoursUsed.Text, out hours) || hours <= 0)
                {
                    ShowAlert("Please enter valid positive hours used.", false);
                    return;
                }
                if (!decimal.TryParse(txtFacilityTotal.Text, out totalCharges) || totalCharges < 0)
                {
                    ShowAlert("Please enter a valid total charges amount.", false);
                    return;
                }
                DateTime usageDate;
                if (!DateTime.TryParse(txtFacilityDate.Text, out usageDate))
                {
                    usageDate = DateTime.Today;
                }

                // Add to basket DataTable
                DataRow nr = basket.NewRow();
                nr["Type"] = "FACILITY";
                nr["TypeDisplay"] = "Facility Booking";
                nr["ItemID"] = Convert.ToInt32(ddlFacility.SelectedValue);
                nr["ItemName"] = ddlFacility.SelectedItem.Text;
                nr["UsageDate"] = usageDate;
                nr["HoursUsed"] = hours;
                nr["LoanID"] = DBNull.Value;
                nr["LoanDisplay"] = usageDate.ToString("dd-MMM-yyyy") + " (" + hours + " hrs)";
                nr["Remarks"] = remarks;
                nr["Amount"] = totalCharges;
                basket.Rows.Add(nr);
            }
            else // FINE
            {
                if (ddlFineReason.SelectedValue == "0")
                {
                    ShowAlert("Please select a charge reason.", false);
                    return;
                }
                decimal fineAmount;
                if (!decimal.TryParse(txtFineAmount.Text, out fineAmount) || fineAmount <= 0)
                {
                    ShowAlert("Please enter a valid fine/fee amount greater than zero.", false);
                    return;
                }

                int? loanID = null;
                string loanDisplay = "General Fee";
                if (ddlActiveLoans.SelectedValue != "0")
                {
                    loanID = Convert.ToInt32(ddlActiveLoans.SelectedValue);
                    loanDisplay = ddlActiveLoans.SelectedItem.Text;
                }

                // Add to basket DataTable
                DataRow nr = basket.NewRow();
                nr["Type"] = "FINE";
                nr["TypeDisplay"] = "Library Fine/Fee";
                nr["ItemID"] = Convert.ToInt32(ddlFineReason.SelectedValue);
                nr["ItemName"] = ddlFineReason.SelectedItem.Text;
                nr["UsageDate"] = DBNull.Value;
                nr["HoursUsed"] = DBNull.Value;
                if (loanID.HasValue) nr["LoanID"] = loanID.Value;
                else nr["LoanID"] = DBNull.Value;
                nr["LoanDisplay"] = loanDisplay;
                nr["Remarks"] = remarks;
                nr["Amount"] = fineAmount;
                basket.Rows.Add(nr);
            }

            ChargeBasketTable = basket;
            BindChargeBasket();
            ResetChargeInputs();
            ShowAlert("Charge added to the pending basket.", true);
        }
        catch (Exception ex)
        {
            ShowAlert("Error adding to basket: " + ex.Message, false);
        }
    }

    protected void gvChargeBasket_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "RemoveItem")
        {
            int idx = Convert.ToInt32(e.CommandArgument);
            DataTable basket = ChargeBasketTable;
            if (idx >= 0 && idx < basket.Rows.Count)
            {
                basket.Rows.RemoveAt(idx);
                ChargeBasketTable = basket;
                BindChargeBasket();
                ShowAlert("Item removed from basket.", true);
            }
        }
    }

    protected void btnRecordAllCharges_Click(object sender, EventArgs e)
    {
        try
        {
            int memberID = Convert.ToInt32(hfChargeMemberID.Value);
            DataTable basket = ChargeBasketTable;

            if (basket.Rows.Count == 0)
            {
                ShowAlert("The basket is empty.", false);
                return;
            }

            int successCount = 0;
            foreach (DataRow row in basket.Rows)
            {
                string type = row["Type"].ToString();
                int itemID = Convert.ToInt32(row["ItemID"]);
                decimal amount = Convert.ToDecimal(row["Amount"]);
                string remarks = row["Remarks"].ToString();

                if (type == "FACILITY")
                {
                    DateTime usageDate = Convert.ToDateTime(row["UsageDate"]);
                    decimal hours = Convert.ToDecimal(row["HoursUsed"]);
                    DBHelper.ChargeFacility(memberID, itemID, usageDate, hours, amount, remarks, CurrentStaffID);
                }
                else // FINE
                {
                    int? loanID = null;
                    if (row["LoanID"] != DBNull.Value)
                    {
                        loanID = Convert.ToInt32(row["LoanID"]);
                    }
                    DBHelper.ChargeFine(memberID, (byte)itemID, loanID, amount, remarks, CurrentStaffID);
                }
                successCount++;
            }

            ShowAlert("Successfully recorded " + successCount + " charge(s) for the member.", true);
            ChargeBasketTable = null;
            BindChargeBasket();
        }
        catch (Exception ex)
        {
            ShowAlert("Error recording charges: " + ex.Message, false);
        }
    }

    private void ResetChargeInputs()
    {
        ddlFacility.SelectedValue = "0";
        txtFacilityRate.Text = "";
        txtHoursUsed.Text = "";
        txtFacilityTotal.Text = "";
        txtFacilityDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
        ddlFineReason.SelectedValue = "0";
        txtFineAmount.Text = "";
        if (ddlActiveLoans.Items.Count > 0) ddlActiveLoans.SelectedValue = "0";
        txtChargeRemarks.Text = "";
        ClearPolicyWarnings();
    }

    // =========================================================================
    //  TAB 2: GENERATE VOUCHERS LOGIC
    // =========================================================================
    protected void btnSelectVoucherMember_Click(object sender, EventArgs e)
    {
        string searchText = txtVoucherMemberSearch.Text.Trim();
        if (string.IsNullOrEmpty(searchText))
        {
            ShowAlert("Please enter a member name or number.", false);
            return;
        }

        if (searchText.Contains(" - "))
        {
            searchText = searchText.Substring(0, searchText.IndexOf(" - ")).Trim();
        }

        DataTable dt = DBHelper.GetMembers(searchText);
        int? memberID = null;

        foreach (DataRow row in dt.Rows)
        {
            if (row["MembershipNo"].ToString().Equals(searchText, StringComparison.OrdinalIgnoreCase) ||
                row["FullName"].ToString().Equals(searchText, StringComparison.OrdinalIgnoreCase) ||
                row["MemberDisplay"].ToString().Equals(searchText, StringComparison.OrdinalIgnoreCase))
            {
                memberID = Convert.ToInt32(row["MemberID"]);
                lblVoucherMemberNo.Text = row["MembershipNo"].ToString();
                lblVoucherMemberName.Text = row["FullName"].ToString();
                break;
            }
        }

        if (memberID == null && dt.Rows.Count > 0)
        {
            memberID = Convert.ToInt32(dt.Rows[0]["MemberID"]);
            lblVoucherMemberNo.Text = dt.Rows[0]["MembershipNo"].ToString();
            lblVoucherMemberName.Text = dt.Rows[0]["FullName"].ToString();
        }

        if (memberID != null)
        {
            hfVoucherMemberID.Value = memberID.ToString();
            LoadUnpaidItems(memberID.Value);
        }
        else
        {
            pnlVoucherContent.Visible = false;
            ShowAlert("Member not found.", false);
        }
    }

    private void LoadUnpaidItems(int memberID)
    {
        DataRow profile = DBHelper.GetMemberDetails(memberID);
        if (profile != null)
        {
            lblVoucherMemberBalance.Text = Convert.ToDecimal(profile["OutstandingFines"]).ToString("N2");
        }

        DataSet ds = DBHelper.GetUnpaidItemsForVoucher(memberID);
        gvUnpaidFines.DataSource = ds.Tables[0];
        gvUnpaidFines.DataBind();

        gvUnpaidBookings.DataSource = ds.Tables[1];
        gvUnpaidBookings.DataBind();

        pnlVoucherContent.Visible = true;
    }

    protected void btnGenerateVoucher_Click(object sender, EventArgs e)
    {
        try
        {
            int memberID = Convert.ToInt32(hfVoucherMemberID.Value);
            StringBuilder fineIDs = new StringBuilder();
            StringBuilder bookingIDs = new StringBuilder();

            // Collect selected Fines
            foreach (GridViewRow row in gvUnpaidFines.Rows)
            {
                CheckBox chk = (CheckBox)row.FindControl("chkSelectFine");
                if (chk != null && chk.Checked)
                {
                    int fineID = Convert.ToInt32(gvUnpaidFines.DataKeys[row.RowIndex].Value);
                    if (fineIDs.Length > 0) fineIDs.Append(",");
                    fineIDs.Append(fineID);
                }
            }

            // Collect selected Bookings
            foreach (GridViewRow row in gvUnpaidBookings.Rows)
            {
                CheckBox chk = (CheckBox)row.FindControl("chkSelectBooking");
                if (chk != null && chk.Checked)
                {
                    int bookingID = Convert.ToInt32(gvUnpaidBookings.DataKeys[row.RowIndex].Value);
                    if (bookingIDs.Length > 0) bookingIDs.Append(",");
                    bookingIDs.Append(bookingID);
                }
            }

            if (fineIDs.Length == 0 && bookingIDs.Length == 0)
            {
                ShowAlert("Please select at least one fine or facility booking to bundle into a voucher.", false);
                return;
            }

            string payMode = ddlPaymentMode.SelectedValue;
            string remarks = txtVoucherRemarks.Text.Trim();

            string voucherNo = DBHelper.GenerateVoucher(memberID, fineIDs.ToString(), bookingIDs.ToString(), payMode, remarks, CurrentStaffID);

            if (!string.IsNullOrEmpty(voucherNo))
            {
                // Load and display printable view
                LoadPrintVoucher(voucherNo);
                
                // Show Alert
                if (payMode == "Account Debit")
                {
                    ShowAlert("Voucher " + voucherNo + " generated and immediately paid via member account debit.", true);
                }
                else
                {
                    ShowAlert("Voucher " + voucherNo + " created successfully. Presentation slip is loaded below.", true);
                }

                // Refresh lists
                LoadUnpaidItems(memberID);
                txtVoucherRemarks.Text = "";
            }
            else
            {
                ShowAlert("Failed to generate voucher.", false);
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Error generating voucher: " + ex.Message, false);
        }
    }

    private void LoadPrintVoucher(string voucherNo)
    {
        DataSet ds = DBHelper.GetVoucherDetails(voucherNo);
        if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
        {
            DataRow vRow = ds.Tables[0].Rows[0];
            lblPrintVoucherNo.Text = vRow["VoucherNo"].ToString();
            lblPrintDate.Text = Convert.ToDateTime(vRow["IssueDate"]).ToString("dd MMM yyyy HH:mm");
            lblPrintMemberName.Text = vRow["FullName"].ToString();
            lblPrintMemberNo.Text = vRow["MembershipNo"].ToString();
            lblPrintPaymentMode.Text = vRow["PaymentMode"].ToString();
            
            bool isPaid = Convert.ToBoolean(vRow["IsPaid"]);
            lblPrintStatus.Text = isPaid ? "PAID" : "PENDING CASHIER";
            lblPrintTotal.Text = Convert.ToDecimal(vRow["Amount"]).ToString("N2");

            // Combine both tables for grid print
            DataTable dtPrint = new DataTable();
            dtPrint.Columns.Add("ItemType");
            dtPrint.Columns.Add("Description");
            dtPrint.Columns.Add("Amount", typeof(decimal));

            if (ds.Tables.Count > 1)
            {
                foreach (DataRow r in ds.Tables[1].Rows)
                {
                    dtPrint.Rows.Add("Fine/Fee", r["Description"].ToString() + " (" + r["Remarks"].ToString() + ")", Convert.ToDecimal(r["Amount"]));
                }
            }

            if (ds.Tables.Count > 2)
            {
                foreach (DataRow r in ds.Tables[2].Rows)
                {
                    dtPrint.Rows.Add("Facility Reservation", r["Description"].ToString() + " (" + r["Remarks"].ToString() + ")", Convert.ToDecimal(r["Amount"]));
                }
            }

            gvPrintItems.DataSource = dtPrint;
            gvPrintItems.DataBind();

            pnlPrintSlip.Visible = true;
        }
    }

    protected void btnCloseVoucherPrint_Click(object sender, EventArgs e)
    {
        pnlPrintSlip.Visible = false;
    }

    // =========================================================================
    //  TAB 3: CASHIER DESK LOGIC
    // =========================================================================
    protected void btnSearchVoucher_Click(object sender, EventArgs e)
    {
        string vNo = txtVoucherNoSearch.Text.Trim();
        if (string.IsNullOrEmpty(vNo))
        {
            ShowAlert("Please enter a voucher number to retrieve.", false);
            return;
        }

        try
        {
            DataSet ds = DBHelper.GetVoucherDetails(vNo);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                DataRow vRow = ds.Tables[0].Rows[0];
                lblCashierVoucherNo.Text = vRow["VoucherNo"].ToString();
                lblCashierVoucherDate.Text = Convert.ToDateTime(vRow["IssueDate"]).ToString("dd MMM yyyy HH:mm");
                lblCashierMemberName.Text = vRow["FullName"].ToString();
                lblCashierMemberNo.Text = vRow["MembershipNo"].ToString();
                lblCashierPaymentMode.Text = vRow["PaymentMode"].ToString();
                lblCashierVoucherTotal.Text = Convert.ToDecimal(vRow["Amount"]).ToString("N2");

                bool isPaid = Convert.ToBoolean(vRow["IsPaid"]);
                if (isPaid)
                {
                    lblCashierVoucherStatus.Text = "<span style='background-color: #d1fae5; color: #065f46; padding: 4px 10px; border-radius: 30px; font-size: 11px; font-weight: 700;'>Paid</span>";
                    trPaidAt.Visible = true;
                    lblCashierPaidAt.Text = Convert.ToDateTime(vRow["PaidAt"]).ToString("dd MMM yyyy HH:mm");
                    divCashierPayButton.Visible = false;
                }
                else
                {
                    lblCashierVoucherStatus.Text = "<span style='background-color: #fee2e2; color: #991b1b; padding: 4px 10px; border-radius: 30px; font-size: 11px; font-weight: 700;'>Unpaid (Pending)</span>";
                    trPaidAt.Visible = false;
                    divCashierPayButton.Visible = true;
                }

                // Combine items
                DataTable dtItems = new DataTable();
                dtItems.Columns.Add("ItemType");
                dtItems.Columns.Add("Description");
                dtItems.Columns.Add("Remarks");
                dtItems.Columns.Add("Amount", typeof(decimal));

                if (ds.Tables.Count > 1)
                {
                    foreach (DataRow r in ds.Tables[1].Rows)
                    {
                        dtItems.Rows.Add(r["ItemType"].ToString(), r["Description"].ToString(), r["Remarks"].ToString(), Convert.ToDecimal(r["Amount"]));
                    }
                }
                if (ds.Tables.Count > 2)
                {
                    foreach (DataRow r in ds.Tables[2].Rows)
                    {
                        dtItems.Rows.Add(r["ItemType"].ToString(), r["Description"].ToString(), r["Remarks"].ToString(), Convert.ToDecimal(r["Amount"]));
                    }
                }

                gvVoucherLineItems.DataSource = dtItems;
                gvVoucherLineItems.DataBind();

                pnlVoucherSearchDetail.Visible = true;
            }
            else
            {
                pnlVoucherSearchDetail.Visible = false;
                ShowAlert("Voucher \"" + vNo + "\" was not found.", false);
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Error searching voucher: " + ex.Message, false);
        }
    }

    protected void btnPrintVoucherCashier_Click(object sender, EventArgs e)
    {
        string vNo = lblCashierVoucherNo.Text.Trim();
        if (!string.IsNullOrEmpty(vNo))
        {
            LoadPrintVoucher(vNo);
        }
    }

    protected void btnPayVoucher_Click(object sender, EventArgs e)
    {
        string vNo = lblCashierVoucherNo.Text;
        if (string.IsNullOrEmpty(vNo)) return;

        try
        {
            string result = DBHelper.PayVoucher(vNo, CurrentStaffID);
            if (result == "OK")
            {
                ShowAlert("Voucher payment of Rs. " + lblCashierVoucherTotal.Text + " successfully collected and logged.", true);
                
                // Refresh Cashier screen details
                btnSearchVoucher_Click(null, null);
            }
            else
            {
                ShowAlert("Payment error: " + result, false);
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Error collecting payment: " + ex.Message, false);
        }
    }

    private void ClearPolicyWarnings()
    {
        pnlPolicyWarning.Visible = false;
        litPolicyWarningMsg.Text = "";
    }

    private void ShowPolicyWarnings(List<string> warnings)
    {
        if (warnings != null && warnings.Count > 0)
        {
            pnlPolicyWarning.Visible = true;
            StringBuilder sb = new StringBuilder();
            foreach (string warning in warnings)
            {
                sb.AppendFormat("<li>{0}</li>", warning);
            }
            litPolicyWarningMsg.Text = sb.ToString();
        }
        else
        {
            pnlPolicyWarning.Visible = false;
        }
    }

    private void ShowAlert(string msg, bool isSuccess)
    {
        pnlAlert.Visible = true;
        litAlertMsg.Text = msg;
        if (isSuccess)
        {
            divAlert.Attributes["style"] = "padding: 16px 24px; border-radius: 8px; font-size: 14px; margin-bottom: 24px; border-left: 4px solid #10b981; background-color: #d1fae5; color: #065f46; width: 100%; box-sizing: border-box;";
        }
        else
        {
            divAlert.Attributes["style"] = "padding: 16px 24px; border-radius: 8px; font-size: 14px; margin-bottom: 24px; border-left: 4px solid #ef4444; background-color: #fee2e2; color: #991b1b; width: 100%; box-sizing: border-box;";
        }
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
        bool isAdults, bool isChildren)
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
        byte condID, decimal? cost, string notes)
    {
        var prms = new[]
        {
            new SqlParameter("@BookID",   bookID),
            new SqlParameter("@RackID",   (object)rackID  ?? DBNull.Value),
            new SqlParameter("@SlotNo",   (object)slotNo  ?? DBNull.Value),
            new SqlParameter("@CondID",   condID),
            new SqlParameter("@AcqCost",  (object)cost    ?? DBNull.Value),
            new SqlParameter("@Notes",    (object)notes   ?? DBNull.Value),
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

    public static DataTable GetLoanDetailsForCalculation(int loanID)
    {
        return ExecuteReader("sp_GetLoanDetailsForCalculation", 
            new SqlParameter("@LoanID", loanID));
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

