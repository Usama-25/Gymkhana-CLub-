using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Collections.Generic;

public partial class PaymentProcess : System.Web.UI.Page
{
    string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadActiveBankCards();
            txtBillingPeriod.Text = DateTime.Now.ToString("MMMM yyyy");

            string qMemberNo = Request.QueryString["memberNo"] ?? Request.QueryString["search"] ?? Request.QueryString["MemberNo"];
            if (!string.IsNullOrEmpty(qMemberNo))
            {
                txtSearch.Text = qMemberNo;
                btnSearch_Click(null, null);
            }
        }
    }

    private void LoadActiveBankCards()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string sql = "SELECT Bank_ID AS BankID, Bank_Name AS BankName FROM BankDefination WHERE IsActive = 1 ORDER BY Bank_Name";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    DataTable dt = new DataTable();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);

                    ddlBankCard.DataSource = dt;
                    ddlBankCard.DataTextField = "BankName";
                    ddlBankCard.DataValueField = "BankID";
                    ddlBankCard.DataBind();
                    ddlBankCard.Items.Insert(0, new ListItem("-- Select Bank --", "0"));
                }
            }
        }
        catch { }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        lblMessage.Visible = false;
        pnlSearchResults.Visible = false;
        pnlMemberArea.Visible = false;

        string searchTerm = txtSearch.Text.Trim();
        if (string.IsNullOrWhiteSpace(searchTerm))
        {
            ShowMessage("Please enter a Member ID or Name to search.", false);
            return;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_SearchMembers", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SearchTerm", searchTerm);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            DataRow selectedRow = null;
                            foreach (DataRow row in dt.Rows)
                            {
                                string mNo = row["MembershipNo"].ToString().Trim();
                                if (mNo.Equals(searchTerm, StringComparison.OrdinalIgnoreCase))
                                {
                                    selectedRow = row;
                                    break;
                                }
                            }

                            if (selectedRow == null && dt.Rows.Count == 1)
                            {
                                selectedRow = dt.Rows[0];
                            }

                            if (selectedRow != null)
                            {
                                hfMemberID.Value = selectedRow["MemberID"].ToString();
                                lblMemberNo.Text = selectedRow["MembershipNo"].ToString();
                                lblFullName.Text = selectedRow["FullName"].ToString();
                                lblStatus.Text = selectedRow["Status"].ToString();

                                pnlMemberArea.Visible = true;
                                pnlSearchResults.Visible = false;

                                LoadLedgerBalance();
                                LoadActiveSubscriptions();
                            }
                            else
                            {
                                pnlSearchResults.Visible = true;
                                ddlMemberNames.Items.Clear();
                                ddlMemberNames.Items.Add(new ListItem("-- Select Member / Dependent --", "0"));

                                foreach (DataRow row in dt.Rows)
                                {
                                    string val = row["MemberID"].ToString() + "|" + row["MembershipNo"].ToString() + "|" + row["FullName"].ToString() + "|" + row["Status"].ToString();
                                    string text = row["MemberDisplay"].ToString();
                                    ddlMemberNames.Items.Add(new ListItem(text, val));
                                }
                            }
                        }
                        else
                        {
                            ShowMessage("No member found with that criteria.", false);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error searching member: " + ex.Message, false);
        }
    }

    protected void ddlMemberNames_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlMemberNames.SelectedValue == "0")
        {
            pnlMemberArea.Visible = false;
            return;
        }

        string[] parts = ddlMemberNames.SelectedValue.Split('|');
        if (parts.Length >= 4)
        {
            hfMemberID.Value = parts[0];
            lblMemberNo.Text = parts[1];
            lblFullName.Text = parts[2];
            lblStatus.Text = parts[3];

            pnlMemberArea.Visible = true;

            LoadLedgerBalance();
            LoadActiveSubscriptions();
        }
    }

    private void LoadLedgerBalance()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = "SELECT ISNULL(SUM(DebitAmount), 0) - ISNULL(SUM(CreditAmount), 0) FROM LedgerEntries WHERE MemberID = @MemberID";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@MemberID", hfMemberID.Value);
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        decimal balance = Convert.ToDecimal(result);
                        lblBalance.Text = "PKR " + Math.Abs(balance).ToString("N2");

                        if (balance > 0)
                        {
                            divBalance.Attributes["class"] = "member-info-value balance-item-debit";
                            lblBalance.Text += " (Dr)"; // Owe money
                        }
                        else if (balance < 0)
                        {
                            divBalance.Attributes["class"] = "member-info-value balance-item-credit";
                            lblBalance.Text += " (Cr)"; // Advance payment
                        }
                        else
                        {
                            divBalance.Attributes["class"] = "member-info-value";
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading balance: " + ex.Message, false);
        }
    }

    private void LoadActiveSubscriptions()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetActiveSubscriptionsForCharge", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@MemberID", hfMemberID.Value);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (!dt.Columns.Contains("CalcBaseFee")) dt.Columns.Add("CalcBaseFee", typeof(decimal));
                        if (!dt.Columns.Contains("CalcGSTAmount")) dt.Columns.Add("CalcGSTAmount", typeof(decimal));
                        if (!dt.Columns.Contains("CalcNetFee")) dt.Columns.Add("CalcNetFee", typeof(decimal));
                        if (!dt.Columns.Contains("GSTPercentVal")) dt.Columns.Add("GSTPercentVal", typeof(decimal));

                        foreach (DataRow row in dt.Rows)
                        {
                            int subId = Convert.ToInt32(row["SubscriptionID"]);
                            int age = row["MemberAge"] != DBNull.Value ? Convert.ToInt32(row["MemberAge"]) : 0;
                            int tenure = row["MemberTenure"] != DBNull.Value ? Convert.ToInt32(row["MemberTenure"]) : 0;
                            string relation = row["DependentRelation"] != DBNull.Value ? row["DependentRelation"].ToString() : "";

                            decimal baseFee, discount, gstAmount;
                            string appliedPolicyName;
                            decimal netFee = CalculateNetFee(subId, age, tenure, relation, out baseFee, out discount, out gstAmount, out appliedPolicyName);

                            row["CalcBaseFee"] = baseFee;
                            row["CalcGSTAmount"] = gstAmount;
                            row["CalcNetFee"] = netFee;
                            row["GSTPercentVal"] = row["GSTPercentage"] != DBNull.Value ? Convert.ToDecimal(row["GSTPercentage"]) : 0m;
                        }

                        ViewState["ActiveSubs"] = dt;

                        gvActiveSubscriptions.DataSource = dt;
                        gvActiveSubscriptions.DataBind();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading active subscriptions: " + ex.Message, false);
        }
    }

    private DataTable GetPackagesForSport(int sportId)
    {
        DataTable dt = new DataTable();
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string q = "SELECT SubscriptionID, PackageName, Fee FROM Subscriptions WHERE SportID = @SportID AND Status = 1 ORDER BY PackageName";
                using (SqlCommand cmd = new SqlCommand(q, con))
                {
                    cmd.Parameters.AddWithValue("@SportID", sportId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }
        }
        catch { }
        return dt;
    }

    protected void gvActiveSubscriptions_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView drv = (DataRowView)e.Row.DataItem;
            int sportId = Convert.ToInt32(drv["SportID"]);

            DropDownList ddlPackage = (DropDownList)e.Row.FindControl("ddlPackage");
            if (ddlPackage != null)
            {
                ddlPackage.Items.Clear();
                ddlPackage.Items.Add(new ListItem("-- Select Package --", "0"));

                DataTable dtPackages = GetPackagesForSport(sportId);
                foreach (DataRow pRow in dtPackages.Rows)
                {
                    int subId = Convert.ToInt32(pRow["SubscriptionID"]);
                    string pName = pRow["PackageName"].ToString();
                    decimal fee = Convert.ToDecimal(pRow["Fee"]);
                    ddlPackage.Items.Add(new ListItem(pName + " (PKR " + fee.ToString("N0") + ")", subId.ToString()));
                }

                ddlPackage.SelectedValue = "0"; // Initially blank as requested
            }

            Label lblBaseFee = (Label)e.Row.FindControl("lblBaseFee");
            if (lblBaseFee != null)
            {
                lblBaseFee.Text = ""; // Initially blank as requested
            }
        }
    }

    protected void ddlPackage_SelectedIndexChanged(object sender, EventArgs e)
    {
        DropDownList ddlPackage = (DropDownList)sender;
        GridViewRow row = (GridViewRow)ddlPackage.NamingContainer;
        Label lblBaseFee = (Label)row.FindControl("lblBaseFee");
        HiddenField hfMemberSubID = (HiddenField)row.FindControl("hfMemberSubID");

        if (ddlPackage.SelectedValue == "0")
        {
            lblBaseFee.Text = "";
            return;
        }

        int selectedSubId = Convert.ToInt32(ddlPackage.SelectedValue);
        int memberSubId = Convert.ToInt32(hfMemberSubID.Value);

        DataTable dt = ViewState["ActiveSubs"] as DataTable;
        if (dt != null)
        {
            DataRow[] rows = dt.Select("MemberSubID = " + memberSubId);
            if (rows.Length > 0)
            {
                DataRow dataRow = rows[0];
                int age = Convert.ToInt32(dataRow["MemberAge"]);
                int tenure = Convert.ToInt32(dataRow["MemberTenure"]);
                string relation = dataRow["DependentRelation"].ToString();

                decimal baseFee, discount, gstAmount;
                string appliedPolicyName;
                decimal netFee = CalculateNetFee(selectedSubId, age, tenure, relation, out baseFee, out discount, out gstAmount, out appliedPolicyName);

                if (discount > 0)
                {
                    lblBaseFee.Text = "PKR " + netFee.ToString("N0") + " <br/><span style='font-size:11px; color:#059669; font-weight:bold;'><i class='fas fa-check-circle'></i> " + appliedPolicyName + "</span>";
                }
                else
                {
                    lblBaseFee.Text = "PKR " + netFee.ToString("N0");
                }
            }
        }
    }

    protected void ddlPaymentMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlPaymentMode.SelectedValue == "Credit Card" || ddlPaymentMode.SelectedValue == "Online Payment")
        {
            divCardNoPayment.Visible = true;
            divRefID.Visible = true;
            divBankCard.Visible = true;
            if (string.IsNullOrEmpty(txtReferenceID.Text))
            {
                txtReferenceID.Text = "PAY-" + DateTime.Now.ToString("yyyyMMdd") + "-" + new Random().Next(1000, 9999).ToString();
            }
        }
        else
        {
            divCardNoPayment.Visible = false;
            divRefID.Visible = false;
            divBankCard.Visible = false;
            txtPaymentCardNo.Text = "";
            txtReferenceID.Text = "";
            ddlBankCard.SelectedIndex = 0;
        }
    }

    protected void btnReceivePayment_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtAmountPaid.Text))
        {
            ShowMessage("Please enter amount.", false);
            return;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_ProcessLedgerPayment", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@MemberID", hfMemberID.Value);
                    cmd.Parameters.AddWithValue("@AmountPaid", Convert.ToDecimal(txtAmountPaid.Text));
                    cmd.Parameters.AddWithValue("@PaymentMode", ddlPaymentMode.SelectedValue);

                    int? bankId = null;
                    if (divBankCard.Visible && ddlBankCard.SelectedValue != "0")
                        bankId = Convert.ToInt32(ddlBankCard.SelectedValue);
                    cmd.Parameters.AddWithValue("@BankID", bankId.HasValue ? (object)bankId.Value : DBNull.Value);

                    string cardNo = null;
                    if (divCardNoPayment.Visible)
                    {
                        string rawCard = txtPaymentCardNo.Text.Trim();
                        if (rawCard.Length >= 4) cardNo = new string('*', rawCard.Length - 4) + rawCard.Substring(rawCard.Length - 4);
                        else if (!string.IsNullOrEmpty(rawCard)) cardNo = "****" + rawCard;
                    }
                    cmd.Parameters.AddWithValue("@CardNo", string.IsNullOrEmpty(cardNo) ? (object)DBNull.Value : cardNo);
                    cmd.Parameters.AddWithValue("@ReferenceID", string.IsNullOrEmpty(txtReferenceID.Text) ? (object)DBNull.Value : txtReferenceID.Text);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            LoadLedgerBalance();
            ShowMessage("Payment received successfully and credited to ledger.", true);

            txtAmountPaid.Text = "";
            ddlPaymentMode.SelectedIndex = 0;
            ddlPaymentMode_SelectedIndexChanged(null, null);
        }
        catch (Exception ex)
        {
            ShowMessage("Error processing payment: " + ex.Message, false);
        }
    }

    protected string GetFormattedBaseFee(object baseFeeObj, object subTypeObj, object monthlyRateObj, object continuousRateObj)
    {
        decimal fee = 0m;
        if (baseFeeObj != DBNull.Value && baseFeeObj != null)
        {
            fee = Convert.ToDecimal(baseFeeObj);
        }

        string subType = subTypeObj != null ? subTypeObj.ToString() : "";

        if (fee == 0m)
        {
            if (subType.Equals("Continuous", StringComparison.OrdinalIgnoreCase) && continuousRateObj != DBNull.Value && continuousRateObj != null)
            {
                fee = Convert.ToDecimal(continuousRateObj);
            }
            else if (monthlyRateObj != DBNull.Value && monthlyRateObj != null)
            {
                fee = Convert.ToDecimal(monthlyRateObj);
            }
        }

        if (string.IsNullOrEmpty(subType))
        {
            return string.Format("{0:N2} PKR", fee);
        }
        else
        {
            return string.Format("{0:N2} PKR ({1})", fee, subType);
        }
    }

    protected void gvActiveSubscriptions_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "GenerateCharge")
        {
            int memberSubId = Convert.ToInt32(e.CommandArgument);

            DataTable dt = ViewState["ActiveSubs"] as DataTable;
            if (dt != null)
            {
                DataRow[] rows = dt.Select("MemberSubID = " + memberSubId);
                if (rows.Length > 0)
                {
                    DataRow dataRow = rows[0];
                    int selectedSubId = Convert.ToInt32(dataRow["SubscriptionID"]);
                    int age = Convert.ToInt32(dataRow["MemberAge"]);
                    int tenure = Convert.ToInt32(dataRow["MemberTenure"]);
                    string relation = dataRow["DependentRelation"].ToString();

                    decimal baseFee, discount, gstAmount;
                    string appliedPolicyName;
                    decimal netFee = CalculateNetFee(selectedSubId, age, tenure, relation, out baseFee, out discount, out gstAmount, out appliedPolicyName);

                    try
                    {
                        using (SqlConnection con = new SqlConnection(connString))
                        {
                            con.Open();
                            using (SqlCommand cmd = new SqlCommand("sp_ChargeSubscriptionToLedger", con))
                            {
                                cmd.CommandType = CommandType.StoredProcedure;
                                cmd.Parameters.AddWithValue("@MemberID", hfMemberID.Value);
                                cmd.Parameters.AddWithValue("@MemberSubID", memberSubId);
                                cmd.Parameters.AddWithValue("@ChargeAmount", netFee);
                                cmd.Parameters.AddWithValue("@BillingPeriod", DateTime.Now.ToString("MMMM yyyy"));
                                cmd.ExecuteNonQuery();
                            }
                        }

                        LoadLedgerBalance();
                        LoadActiveSubscriptions();

                        string msg = "Subscription charge of PKR " + netFee.ToString("N2") + " generated successfully and posted to ledger.";
                        if (discount > 0)
                        {
                            msg += " [Applied Policy: " + appliedPolicyName + "]";
                        }

                        ShowMessage(msg, true);
                    }
                    catch (Exception ex)
                    {
                        ShowMessage("Error generating charge: " + ex.Message, false);
                    }
                }
            }
        }
    }

    protected void ddlChargePackage_SelectedIndexChanged(object sender, EventArgs e)
    {
        DataTable dt = ViewState["ActiveSubs"] as DataTable;
        if (dt != null && !string.IsNullOrEmpty(hfChargeMemberSubID.Value))
        {
            DataRow[] rows = dt.Select("MemberSubID = " + hfChargeMemberSubID.Value);
            if (rows.Length > 0)
            {
                RecalculateChargeDetails(rows[0]);
            }
        }
        pnlChargeModal.Style["display"] = "flex";
    }

    private decimal CalculateNetFee(int subId, int age, int tenure, string relation, out decimal baseFee, out decimal discount, out decimal gstAmount, out string appliedPolicyName)
    {
        baseFee = 0;
        discount = 0;
        gstAmount = 0;
        appliedPolicyName = "Standard Rate (No Discount)";
        decimal gstPercent = 0;
        string policyIDsStr = "";
        bool allow65 = false, allow30 = false, allow80 = false, allowChild = false;

        using (SqlConnection con = new SqlConnection(connString))
        {
            string q = @"SELECT s.Fee, s.GSTPercentage, 
                                ISNULL(sp.PolicyIDs, CAST(sp.PolicyID AS NVARCHAR)) AS PolicyIDs,
                                ISNULL(s.Allow65PlusDiscount, 0), ISNULL(s.Allow30YearsDiscount, 0), 
                                ISNULL(s.Allow80PlusFree, 0), ISNULL(s.AllowChildHalfCharge, 0),
                                ISNULL(sp.MonthlyFee, 0) AS MonthlyFee,
                                ISNULL(sp.ContinuousFee, 0) AS ContinuousFee,
                                s.SubscriptionType, sp.SportID
                         FROM Subscriptions s
                         LEFT JOIN Sports sp ON s.SportID = sp.SportID
                         WHERE s.SubscriptionID = @SubID";
            using (SqlCommand cmd = new SqlCommand(q, con))
            {
                cmd.Parameters.AddWithValue("@SubID", subId);
                con.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        decimal subFee = dr.GetDecimal(0);
                        gstPercent = dr.IsDBNull(1) ? 0 : dr.GetDecimal(1);
                        policyIDsStr = dr.IsDBNull(2) ? "" : dr.GetString(2);
                        allow65 = dr.GetBoolean(3);
                        allow30 = dr.GetBoolean(4);
                        allow80 = dr.GetBoolean(5);
                        allowChild = dr.GetBoolean(6);

                        decimal mFee = dr.IsDBNull(7) ? 0m : dr.GetDecimal(7);
                        decimal cFee = dr.IsDBNull(8) ? 0m : dr.GetDecimal(8);
                        string subType = dr.IsDBNull(9) ? "" : dr.GetString(9);
                        int sportId = dr.IsDBNull(10) ? 0 : dr.GetInt32(10);

                        if (sportId == 10) // Sports Cards
                        {
                            baseFee = subFee;
                        }
                        else
                        {
                            if (subType.Equals("Continuous", StringComparison.OrdinalIgnoreCase))
                                baseFee = cFee > 0 ? cFee : (subFee > 0 ? subFee : mFee);
                            else
                                baseFee = mFee > 0 ? mFee : subFee;
                        }
                    }
                }
            }

            // Check dynamic DiscountPolicies linked to the Sport
            if (!string.IsNullOrEmpty(policyIDsStr))
            {
                string polQuery = @"SELECT PolicyID, PolicyName, ISNULL(MinAge, 0) AS MinAge, MaxAge, 
                                           ISNULL(MinMembershipYears, 0) AS MinMembershipYears, 
                                           IsChild, ISNULL(ConditionOperator, 'OR') AS ConditionOperator, 
                                           DiscountPercentage 
                                    FROM DiscountPolicies 
                                    WHERE IsActive = 1 
                                      AND CHARINDEX(',' + CAST(PolicyID AS VARCHAR) + ',', ',' + @PolicyIDs + ',') > 0";
                using (SqlCommand pCmd = new SqlCommand(polQuery, con))
                {
                    pCmd.Parameters.AddWithValue("@PolicyIDs", policyIDsStr);
                    if (con.State != ConnectionState.Open) con.Open();
                    using (SqlDataReader pDr = pCmd.ExecuteReader())
                    {
                        List<string> matchedPolicies = new List<string>();
                        decimal maxDiscountAmt = 0;

                        while (pDr.Read())
                        {
                            string pName = pDr.GetString(1);
                            int minAge = pDr.GetInt32(2);
                            int? maxAge = pDr.IsDBNull(3) ? (int?)null : pDr.GetInt32(3);
                            int minTenure = pDr.GetInt32(4);
                            bool isChild = pDr.GetBoolean(5);
                            string condOp = pDr.GetString(6);
                            decimal discPct = pDr.GetDecimal(7);

                            bool isChildMatch = isChild && (relation.Equals("Son", StringComparison.OrdinalIgnoreCase) ||
                                                           relation.Equals("Daughter", StringComparison.OrdinalIgnoreCase) ||
                                                           relation.Equals("Child", StringComparison.OrdinalIgnoreCase) ||
                                                           relation.Equals("Dependent", StringComparison.OrdinalIgnoreCase));

                            bool isMatched = false;
                            if (condOp.Equals("AND", StringComparison.OrdinalIgnoreCase))
                            {
                                isMatched = true;
                                if (minAge > 0 && age < minAge) isMatched = false;
                                if (maxAge.HasValue && age > maxAge.Value) isMatched = false;
                                if (minTenure > 0 && tenure < minTenure) isMatched = false;
                                if (isChild && !isChildMatch) isMatched = false;
                            }
                            else // OR
                            {
                                if (minAge > 0 && age >= minAge) isMatched = true;
                                if (maxAge.HasValue && age <= maxAge.Value && minAge == 0) isMatched = true;
                                if (minTenure > 0 && tenure >= minTenure) isMatched = true;
                                if (isChild && isChildMatch) isMatched = true;
                            }

                            if (isMatched)
                            {
                                decimal calcDisc = baseFee * (discPct / 100m);
                                matchedPolicies.Add(pName + " (" + discPct.ToString("0.#") + "% Off)");
                                if (calcDisc > maxDiscountAmt)
                                {
                                    maxDiscountAmt = calcDisc;
                                }
                            }
                        }

                        if (matchedPolicies.Count > 0)
                        {
                            discount = maxDiscountAmt;
                            appliedPolicyName = string.Join(" + ", matchedPolicies);
                        }
                    }
                }
            }
        }

        // Fallback to legacy flags if no dynamic policy matched
        if (discount == 0)
        {
            if (allow80 && age >= 80)
            {
                discount = baseFee;
                appliedPolicyName = "80+ Years Free (100% Off)";
            }
            else if (allow30 && tenure >= 30)
            {
                discount = baseFee;
                appliedPolicyName = "30+ Years Membership Free (100% Off)";
            }
            else if (allow65 && age >= 65)
            {
                discount = baseFee * 0.5m;
                appliedPolicyName = "65+ Senior Discount (50% Off)";
            }
            else if (allowChild && (relation == "Son" || relation == "Daughter" || relation == "Child"))
            {
                discount = baseFee * 0.5m;
                appliedPolicyName = "Child Discount (50% Off)";
            }
        }

        decimal feeAfterDiscount = baseFee - discount;
        if (feeAfterDiscount < 0) feeAfterDiscount = 0;

        gstAmount = feeAfterDiscount * (gstPercent / 100m);
        decimal netFee = feeAfterDiscount + gstAmount;

        return netFee;
    }

    private void RecalculateChargeDetails(DataRow row)
    {
        if (ddlChargePackage.SelectedValue == "0")
        {
            litBaseFee.Text = "PKR 0.00";
            litDiscount.Text = "PKR 0.00";
            litGSTPercent.Text = "0.00";
            litGSTAmount.Text = "PKR 0.00";
            litNetFee.Text = "PKR 0.00";
            hfCalculatedNetFee.Value = "0";
            rptRules.DataSource = new List<object>();
            rptRules.DataBind();
            return;
        }

        int selectedSubId = Convert.ToInt32(ddlChargePackage.SelectedValue);
        int age = Convert.ToInt32(row["MemberAge"]);
        int tenure = Convert.ToInt32(row["MemberTenure"]);
        string relation = row["DependentRelation"].ToString();

        decimal baseFee, policyDiscount, gstAmount;
        string appliedPolicyName;
        decimal netFee = CalculateNetFee(selectedSubId, age, tenure, relation, out baseFee, out policyDiscount, out gstAmount, out appliedPolicyName);
        decimal gstPercent = (baseFee - policyDiscount > 0) ? (gstAmount / (baseFee - policyDiscount)) * 100m : 0m;

        List<object> rules = new List<object>();
        rules.Add(new { RuleName = appliedPolicyName, IsApplied = (policyDiscount > 0) });

        rptRules.DataSource = rules;
        rptRules.DataBind();

        litBaseFee.Text = "PKR " + baseFee.ToString("N2");
        litDiscount.Text = "PKR " + policyDiscount.ToString("N2");
        litGSTPercent.Text = gstPercent.ToString("0.00");
        litGSTAmount.Text = "PKR " + gstAmount.ToString("N2");
        litNetFee.Text = "PKR " + netFee.ToString("N2");

        hfCalculatedNetFee.Value = netFee.ToString();
    }

    protected void btnConfirmCharge_Click(object sender, EventArgs e)
    {
        if (ddlChargePackage.SelectedValue == "0" || string.IsNullOrEmpty(ddlChargePackage.SelectedValue))
        {
            ShowMessage("Please select a package first.", false);
            pnlChargeModal.Style["display"] = "flex";
            return;
        }

        try
        {
            int selectedSubId = Convert.ToInt32(ddlChargePackage.SelectedValue);
            int memberSubId = Convert.ToInt32(hfChargeMemberSubID.Value);

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                string updateSub = "UPDATE MemberSubscriptions SET SubscriptionID = @SubID WHERE MemberSubID = @MemberSubID";
                using (SqlCommand upCmd = new SqlCommand(updateSub, con))
                {
                    upCmd.Parameters.AddWithValue("@SubID", selectedSubId);
                    upCmd.Parameters.AddWithValue("@MemberSubID", memberSubId);
                    upCmd.ExecuteNonQuery();
                }

                using (SqlCommand cmd = new SqlCommand("sp_ChargeSubscriptionToLedger", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@MemberID", hfMemberID.Value);
                    cmd.Parameters.AddWithValue("@MemberSubID", hfChargeMemberSubID.Value);
                    cmd.Parameters.AddWithValue("@ChargeAmount", Convert.ToDecimal(hfCalculatedNetFee.Value));
                    cmd.Parameters.AddWithValue("@BillingPeriod", txtBillingPeriod.Text.Trim());
                    cmd.ExecuteNonQuery();
                }
            }

            LoadLedgerBalance();
            LoadActiveSubscriptions();
            pnlChargeModal.Style["display"] = "none";
            ShowMessage("Subscription charged successfully to ledger.", true);
        }
        catch (Exception ex)
        {
            ShowMessage("Error charging subscription: " + ex.Message, false);
            pnlChargeModal.Style["display"] = "none";
        }
    }

    protected void btnCloseModal_Click(object sender, EventArgs e)
    {
        pnlChargeModal.Style["display"] = "none";
    }

    private void ShowMessage(string msg, bool isSuccess)
    {
        lblMessage.Visible = true;
        lblMessage.Text = msg;
        if (isSuccess)
        {
            lblMessage.Style["background-color"] = "#d4edda";
            lblMessage.Style["color"] = "#155724";
            lblMessage.Style["border"] = "1px solid #c3e6cb";
        }
        else
        {
            lblMessage.Style["background-color"] = "#f8d7da";
            lblMessage.Style["color"] = "#721c24";
            lblMessage.Style["border"] = "1px solid #f5c6cb";
        }
    }
}
