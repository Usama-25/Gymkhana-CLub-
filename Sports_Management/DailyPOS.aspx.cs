using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;

public partial class DailyPOS : System.Web.UI.Page
{
    string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;

    private DataTable CartDataTable
    {
        get
        {
            if (ViewState["Cart"] == null)
            {
                DataTable dt = new DataTable();
                dt.Columns.Add("SubscriptionID", typeof(int));
                dt.Columns.Add("ItemCode", typeof(string));
                dt.Columns.Add("PackageName", typeof(string));
                dt.Columns.Add("LockerID", typeof(int));
                dt.Columns.Add("LockerName", typeof(string));
                dt.Columns.Add("ValidFrom", typeof(DateTime));
                dt.Columns.Add("ValidTo", typeof(DateTime));
                dt.Columns.Add("NumberOfDays", typeof(int));
                dt.Columns.Add("BaseFee", typeof(decimal));
                dt.Columns.Add("GSTPercentage", typeof(decimal));
                dt.Columns.Add("GSTAmount", typeof(decimal));
                dt.Columns.Add("PolicyDiscount", typeof(decimal));
                dt.Columns.Add("LockerFee", typeof(decimal));
                dt.Columns.Add("NetTotal", typeof(decimal));
                dt.Columns.Add("IsEditable", typeof(bool));
                dt.Columns.Add("DepartmentName", typeof(string));
                ViewState["Cart"] = dt;
            }
            return (DataTable)ViewState["Cart"];
        }
        set
        {
            ViewState["Cart"] = value;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtValidFrom.Text = DateTime.Now.ToString("yyyy-MM-dd");
            txtValidTo.Text = DateTime.Now.ToString("yyyy-MM-dd");
            LoadDepartments();
            LoadSports();
            LoadDailyPackages();
            LoadLockers();
            ToggleCustomerFields();
            LoadActiveBankCards();

            // Set default visibility for Payment fields
            divBankCard.Visible = false;
            divCardNoPayment.Visible = false;
            if (divCardType != null) divCardType.Visible = false;
            if (divBankDiscountPercent != null) divBankDiscountPercent.Visible = false;
            divRefID.Visible = true;
        }
    }

    private void LoadDepartments()
    {
        // Facility dropdown removed from UI, handled by LoadSports
    }

    private static bool HasColumn(IDataRecord dr, string columnName)
    {
        for (int i = 0; i < dr.FieldCount; i++)
        {
            if (dr.GetName(i).Equals(columnName, StringComparison.OrdinalIgnoreCase))
                return true;
        }
        return false;
    }

    private void LoadActiveBankCards()
    {
        try
        {
            string restaurantConn = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"] != null
                ? ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString
                : (ConfigurationManager.ConnectionStrings["RestaurantConnString"] != null
                    ? ConfigurationManager.ConnectionStrings["RestaurantConnString"].ConnectionString
                    : connString.Replace("SportsModuleDB", "Restaurant"));

            using (SqlConnection con = new SqlConnection(restaurantConn))
            {
                string sql = @"
                    SELECT offer_id, offer_name, ISNULL(offer_code, '') AS offer_code, card_prefix, discount_percent, valid_weekday, 
                           min_bill_amount, max_discount_amount, valid_from, valid_to, is_active
                    FROM card_prefix_offers 
                    WHERE ISNULL(is_active, 1) = 1
                    ORDER BY ISNULL(offer_code, offer_name), offer_name";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    DataTable dt = new DataTable();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);

                    ddlBankCard.Items.Clear();
                    ddlBankCard.Items.Add(new ListItem("-- Select Card Offer / Bank --", "0"));

                    foreach (DataRow row in dt.Rows)
                    {
                        string bank = row.Table.Columns.Contains("offer_code") && row["offer_code"] != DBNull.Value && !string.IsNullOrWhiteSpace(row["offer_code"].ToString())
                            ? row["offer_code"].ToString().Trim()
                            : "";
                        string offer = row["offer_name"] != DBNull.Value ? row["offer_name"].ToString().Trim() : "";
                        string prefix = row["card_prefix"] != DBNull.Value ? row["card_prefix"].ToString().Trim() : "";
                        decimal disc = row["discount_percent"] != DBNull.Value ? Convert.ToDecimal(row["discount_percent"]) : 0;

                        string displayName = "";
                        if (!string.IsNullOrEmpty(bank))
                        {
                            displayName = string.Format("[{0}] {1} - {2} ({3}% Disc)", prefix, bank, offer, disc.ToString("0.##"));
                        }
                        else
                        {
                            displayName = string.Format("[{0}] {1} ({2}% Disc)", prefix, offer, disc.ToString("0.##"));
                        }

                        ddlBankCard.Items.Add(new ListItem(displayName, row["offer_id"].ToString()));
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading Card Offers from Restaurant DB: " + ex.Message, false);
        }
    }

    protected void txtPaymentCardNo_TextChanged(object sender, EventArgs e)
    {
        LookupCardPrefixOffer();
    }

    private void LookupCardPrefixOffer()
    {
        string rawCard = txtPaymentCardNo.Text.Trim();
        if (string.IsNullOrEmpty(rawCard) || rawCard.Length < 4)
        {
            divCardOfferInfo.Visible = false;
            return;
        }

        string prefix = rawCard.Substring(0, 4);

        try
        {
            string restaurantConn = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"] != null
                ? ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString
                : (ConfigurationManager.ConnectionStrings["RestaurantConnString"] != null
                    ? ConfigurationManager.ConnectionStrings["RestaurantConnString"].ConnectionString
                    : connString.Replace("SportsModuleDB", "Restaurant"));

            using (SqlConnection con = new SqlConnection(restaurantConn))
            {
                string sql = @"
                    SELECT TOP 1 offer_id, offer_name, ISNULL(offer_code, '') AS offer_code, card_prefix, prefix_length, discount_percent, valid_weekday, 
                           min_bill_amount, max_discount_amount, valid_from, valid_to, is_active, dept_name, dept_id
                    FROM card_prefix_offers 
                    WHERE ISNULL(is_active, 1) = 1 
                      AND (card_prefix = @Prefix OR @RawCard LIKE card_prefix + '%')
                    ORDER BY discount_percent DESC, offer_id DESC";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@Prefix", prefix);
                    cmd.Parameters.AddWithValue("@RawCard", rawCard);
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            string offerId = dr["offer_id"].ToString();
                            if (ddlBankCard.Items.FindByValue(offerId) != null)
                            {
                                ddlBankCard.SelectedValue = offerId;
                            }
                            PopulateCardOfferDetails(dr);
                        }
                        else
                        {
                            txtCardType.Text = "Standard Card";
                            txtBankDiscountPercent.Text = "0%";
                            lblOfferPrefixLength.Text = rawCard.Length + " Digits (" + rawCard + ")";
                            lblOfferCardType.Text = "Standard Card";
                            lblOfferDiscount.Text = "0%";
                            lblOfferValidity.Text = "No Expiry";
                            lblOfferMinBill.Text = "None";
                            lblOfferMaxDiscount.Text = "None";
                            lblOfferValidDays.Text = "All Days";
                            lblOfferValidDepts.Text = "All Departments";
                            divCardOfferInfo.Visible = true;
                            ViewState["CurrentOffer_MinBill"] = 0;
                            ViewState["CurrentOffer_MaxDiscount"] = 0;
                            UpdateCartTotal();
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            lblOfferCardType.Text = "Lookup Error";
            divCardOfferInfo.Visible = true;
            UpdateCartTotal();
        }
    }

    private void ApplyCardOfferById(int offerId)
    {
        try
        {
            string restaurantConn = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"] != null
                ? ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString
                : (ConfigurationManager.ConnectionStrings["RestaurantConnString"] != null
                    ? ConfigurationManager.ConnectionStrings["RestaurantConnString"].ConnectionString
                    : connString.Replace("SportsModuleDB", "Restaurant"));

            using (SqlConnection con = new SqlConnection(restaurantConn))
            {
                string sql = @"
                    SELECT offer_id, offer_name, ISNULL(offer_code, '') AS offer_code, card_prefix, prefix_length, discount_percent, valid_weekday, 
                           min_bill_amount, max_discount_amount, valid_from, valid_to, is_active, dept_name, dept_id
                    FROM card_prefix_offers 
                    WHERE offer_id = @OfferID";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@OfferID", offerId);
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            PopulateCardOfferDetails(dr);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error retrieving card offer: " + ex.Message, true);
        }
    }

    private void PopulateCardOfferDetails(SqlDataReader dr)
    {
        string offerName = dr["offer_name"] != DBNull.Value ? dr["offer_name"].ToString() : "";
        string offerCode = HasColumn(dr, "offer_code") && dr["offer_code"] != DBNull.Value ? dr["offer_code"].ToString() : "";
        string cardPrefix = dr["card_prefix"] != DBNull.Value ? dr["card_prefix"].ToString() : "";
        int prefixLength = HasColumn(dr, "prefix_length") && dr["prefix_length"] != DBNull.Value ? Convert.ToInt32(dr["prefix_length"]) : 4;
        string bankName = HasColumn(dr, "bank_name") && dr["bank_name"] != DBNull.Value ? dr["bank_name"].ToString() : (!string.IsNullOrEmpty(offerCode) ? offerCode : offerName);
        string cardTypeName = HasColumn(dr, "card_type_name") && dr["card_type_name"] != DBNull.Value ? dr["card_type_name"].ToString() : offerName;
        string networkName = HasColumn(dr, "network_name") && dr["network_name"] != DBNull.Value ? dr["network_name"].ToString() : "";
        decimal discountPercent = dr["discount_percent"] != DBNull.Value ? Convert.ToDecimal(dr["discount_percent"]) : 0;
        decimal surchargePercent = HasColumn(dr, "surcharge_percent") && dr["surcharge_percent"] != DBNull.Value ? Convert.ToDecimal(dr["surcharge_percent"]) : 0;
        decimal minBill = dr["min_bill_amount"] != DBNull.Value ? Convert.ToDecimal(dr["min_bill_amount"]) : 0;
        decimal maxDisc = dr["max_discount_amount"] != DBNull.Value ? Convert.ToDecimal(dr["max_discount_amount"]) : 0;
        int validWeekday = dr["valid_weekday"] != DBNull.Value ? Convert.ToInt32(dr["valid_weekday"]) : 0;
        string deptName = dr["dept_name"] != DBNull.Value && !string.IsNullOrWhiteSpace(dr["dept_name"].ToString()) ? dr["dept_name"].ToString().Trim() : "All Departments";

        if (string.IsNullOrEmpty(txtPaymentCardNo.Text) || txtPaymentCardNo.Text.Trim().Length < 4)
        {
            txtPaymentCardNo.Text = cardPrefix;
        }

        txtCardType.Text = !string.IsNullOrEmpty(cardTypeName) ? cardTypeName : (!string.IsNullOrEmpty(offerName) ? offerName : "Credit Card");

        if (string.IsNullOrEmpty(txtReferenceID.Text) || txtReferenceID.Text.StartsWith("REF-"))
        {
            txtReferenceID.Text = !string.IsNullOrEmpty(bankName) ? bankName : offerName;
        }

        if (divCardType != null) divCardType.Visible = true;
        if (divBankDiscountPercent != null) divBankDiscountPercent.Visible = true;

        DateTime? validFromDate = null;
        if (dr["valid_from"] != DBNull.Value)
        {
            DateTime dtF;
            if (DateTime.TryParse(dr["valid_from"].ToString(), out dtF)) validFromDate = dtF.Date;
        }

        DateTime? validToDate = null;
        if (dr["valid_to"] != DBNull.Value)
        {
            DateTime dtT;
            if (DateTime.TryParse(dr["valid_to"].ToString(), out dtT)) validToDate = dtT.Date;
        }

        string validFromStr = validFromDate.HasValue ? validFromDate.Value.ToString("dd-MMM-yyyy") : "";
        string validToStr = validToDate.HasValue ? validToDate.Value.ToString("dd-MMM-yyyy") : "";
        string validityPeriod = (!string.IsNullOrEmpty(validFromStr) ? validFromStr + " to " : "") + (!string.IsNullOrEmpty(validToStr) ? validToStr : "Ongoing");

        string weekdayText = GetWeekdayName(validWeekday);
        if (validWeekday == 0) weekdayText = "All Days (Mon-Sun)";
        else weekdayText = weekdayText + " Only";

        lblOfferPrefixLength.Text = prefixLength + " Digits (" + cardPrefix + ")";
        lblOfferCardType.Text = (!string.IsNullOrEmpty(cardTypeName) ? cardTypeName : "Credit") + (!string.IsNullOrEmpty(networkName) ? " - " + networkName : "");
        lblOfferValidity.Text = validityPeriod;
        lblOfferMinBill.Text = minBill > 0 ? "PKR " + minBill.ToString("N0") : "No Minimum";
        lblOfferMaxDiscount.Text = maxDisc > 0 ? "PKR " + maxDisc.ToString("N0") : "No Limit";
        lblOfferValidDays.Text = weekdayText;
        lblOfferValidDepts.Text = deptName;

        // ===== VALIDATION CHECKS =====
        bool isDeptValid = true;
        string deptWarningMsg = "";
        if (!deptName.Equals("All Departments", StringComparison.OrdinalIgnoreCase) && !deptName.Equals("All", StringComparison.OrdinalIgnoreCase) && !string.IsNullOrEmpty(deptName))
        {
            List<string> cartDeptsList = new List<string>();
            foreach (DataRow cr in CartDataTable.Rows)
            {
                string dName = cr.Table.Columns.Contains("DepartmentName") && cr["DepartmentName"] != DBNull.Value ? cr["DepartmentName"].ToString().Trim() : "";
                if (!string.IsNullOrEmpty(dName) && !cartDeptsList.Contains(dName))
                    cartDeptsList.Add(dName);
            }
            if (cartDeptsList.Count == 0 && ddlSports.SelectedValue != "0" && ddlSports.SelectedItem != null)
            {
                cartDeptsList.Add(ddlSports.SelectedItem.Text.Trim());
            }

            bool matched = false;
            string[] allowedList = deptName.Split(new char[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
            foreach (string cd in cartDeptsList)
            {
                foreach (string ad in allowedList)
                {
                    if (cd.IndexOf(ad.Trim(), StringComparison.OrdinalIgnoreCase) >= 0 || ad.Trim().IndexOf(cd, StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        matched = true;
                        break;
                    }
                }
                if (matched) break;
            }

            if (!matched)
            {
                isDeptValid = false;
                string currentDepts = cartDeptsList.Count > 0 ? string.Join(", ", cartDeptsList) : "Sports / Swimming";
                deptWarningMsg = "Card Offer '" + offerName + "' is ONLY valid for: [" + deptName + "]. It is NOT valid for " + currentDepts + "!";
            }
        }

        bool isDateValid = true;
        string dateWarningMsg = "";
        if (validToDate.HasValue && DateTime.Today > validToDate.Value)
        {
            isDateValid = false;
            dateWarningMsg = "Card Offer '" + offerName + "' expired on " + validToDate.Value.ToString("dd-MMM-yyyy") + "!";
        }
        else if (validFromDate.HasValue && DateTime.Today < validFromDate.Value)
        {
            isDateValid = false;
            dateWarningMsg = "Card Offer '" + offerName + "' is not active yet (Starts on " + validFromDate.Value.ToString("dd-MMM-yyyy") + ")!";
        }

        bool isWeekdayValid = true;
        string weekdayWarningMsg = "";
        if (validWeekday != 0)
        {
            int currentDay = (int)DateTime.Today.DayOfWeek == 0 ? 7 : (int)DateTime.Today.DayOfWeek;
            if (validWeekday != currentDay)
            {
                isWeekdayValid = false;
                string dayName = GetWeekdayName(validWeekday);
                weekdayWarningMsg = "Card Offer '" + offerName + "' is ONLY valid on " + dayName + " (Today is " + DateTime.Today.DayOfWeek + ")!";
            }
        }

        bool isOfferApplicable = isDeptValid && isDateValid && isWeekdayValid;

        if (!isOfferApplicable)
        {
            txtBankDiscountPercent.Text = "0%";
            if (!isDeptValid)
            {
                lblOfferDiscount.Text = "<span style='color:#dc2626; font-weight:bold;'>0% (Invalid Dept)</span>";
                lblOfferValidDepts.Text = "<span style='color:#dc2626; font-weight:bold;'>" + deptName + " <br/><small style='color:#b91c1c;'>(NOT valid for this department)</small></span>";
                ShowMessage(deptWarningMsg, true);
            }
            else if (!isDateValid)
            {
                lblOfferDiscount.Text = "<span style='color:#dc2626; font-weight:bold;'>0% (Expired/Inactive)</span>";
                ShowMessage(dateWarningMsg, true);
            }
            else if (!isWeekdayValid)
            {
                lblOfferDiscount.Text = "<span style='color:#dc2626; font-weight:bold;'>0% (Invalid Day)</span>";
                ShowMessage(weekdayWarningMsg, true);
            }
        }
        else
        {
            txtBankDiscountPercent.Text = discountPercent.ToString("0.##") + "%";
            lblOfferDiscount.Text = "<span style='color:#16a34a; font-weight:bold;'>" + discountPercent.ToString("0.##") + "%" + (surchargePercent > 0 ? " | Surch: " + surchargePercent.ToString("0.##") + "%" : "") + "</span>";
            lblOfferValidDepts.Text = "<span style='color:#16a34a; font-weight:bold;'>" + deptName + "</span>";
            ShowMessage("Card Offer '" + offerName + "' applied successfully (" + discountPercent.ToString("0.##") + "% Discount).", false);
        }

        divCardOfferInfo.Visible = true;

        ViewState["CurrentOffer_ValidTo"] = validToDate;
        ViewState["CurrentOffer_ValidFrom"] = validFromDate;
        ViewState["CurrentOffer_ValidWeekday"] = validWeekday;
        ViewState["CurrentOffer_DeptName"] = deptName;
        ViewState["CurrentOffer_MinBill"] = minBill;
        ViewState["CurrentOffer_MaxDiscount"] = maxDisc;
        ViewState["CurrentOffer_IsApplicable"] = isOfferApplicable;

        UpdateCartTotal();
    }

    private bool IsAdminOrMIS()
    {
        if (Session["UserRole"] != null)
        {
            string role = Session["UserRole"].ToString();
            if (role.Equals("Admin", StringComparison.OrdinalIgnoreCase) ||
                role.Equals("Administrator", StringComparison.OrdinalIgnoreCase))
                return true;
        }

        string deptName = Session["DeptName"] != null ? Session["DeptName"].ToString() : "";
        string subDeptName = Session["SubDeptName"] != null ? Session["SubDeptName"].ToString() : "";
        string empType = Session["Emp_Type"] != null ? Session["Emp_Type"].ToString() : "";
        string username = Session["Username"] != null ? Session["Username"].ToString() : (Session["UserName"] != null ? Session["UserName"].ToString() : "");

        if (username.Equals("admin", StringComparison.OrdinalIgnoreCase) ||
            empType.IndexOf("Admin", StringComparison.OrdinalIgnoreCase) >= 0 ||
            deptName.IndexOf("Admin", StringComparison.OrdinalIgnoreCase) >= 0 ||
            subDeptName.IndexOf("MIS", StringComparison.OrdinalIgnoreCase) >= 0 ||
            subDeptName.IndexOf("IT", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            return true;
        }

        return false;
    }

    private void LoadSports()
    {
        try
        {
            DataTable dt = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = @"
                    SELECT DISTINCT ISNULL(sp.Dept_ID, sp.SportID) AS Dept_ID, 
                           ISNULL(d.Dept_Name, sp.SportName) AS Dept_Name 
                    FROM Sports sp 
                    LEFT JOIN BasicDataInfo.dbo.Department d ON sp.Dept_ID = d.Dept_ID 
                    WHERE sp.Status = 1 
                    ORDER BY ISNULL(d.Dept_Name, sp.SportName)";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            // Direct fallback from Sports table if empty
            if (dt == null || dt.Rows.Count == 0)
            {
                using (SqlConnection con = new SqlConnection(connString))
                {
                    string query = "SELECT DISTINCT ISNULL(Dept_ID, SportID) AS Dept_ID, SportName AS Dept_Name FROM Sports WHERE Status = 1 ORDER BY SportName";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }
                    }
                }
            }

            bool adminOrMIS = IsAdminOrMIS();

            DataView dv = dt.DefaultView;
            int userDeptId = 0;
            if (Session["DeptID"] != null) int.TryParse(Session["DeptID"].ToString(), out userDeptId);
            else if (Session["Dept_ID"] != null) int.TryParse(Session["Dept_ID"].ToString(), out userDeptId);
            else if (Session["DepartmentID"] != null) int.TryParse(Session["DepartmentID"].ToString(), out userDeptId);

            if (!adminOrMIS)
            {
                List<int> allowedDepts = Session["AllowedDepartments"] as List<int>;
                if (allowedDepts != null && allowedDepts.Count > 0)
                {
                    dv.RowFilter = "Dept_ID IN (" + string.Join(",", allowedDepts) + ")";
                }
                else if (userDeptId > 0)
                {
                    dv.RowFilter = "Dept_ID = " + userDeptId;
                }
            }

            ddlSports.DataSource = dv;
            ddlSports.DataTextField = "Dept_Name";
            ddlSports.DataValueField = "Dept_ID";
            ddlSports.DataBind();

            if (adminOrMIS)
            {
                // Administration, MIS, and Admin get access to ALL sports in POS
                ddlSports.Items.Insert(0, new ListItem("-- All Departments --", "0"));
                ddlSports.Enabled = true;
                ddlSports.Attributes["style"] = "";

                if (userDeptId > 0 && ddlSports.Items.FindByValue(userDeptId.ToString()) != null)
                {
                    ddlSports.SelectedValue = userDeptId.ToString();
                }
                else
                {
                    ddlSports.SelectedIndex = 0;
                }
            }
            else
            {
                // Department-specific operator gets only their assigned department(s)
                if (userDeptId > 0 && ddlSports.Items.FindByValue(userDeptId.ToString()) != null)
                {
                    ddlSports.SelectedValue = userDeptId.ToString();
                }

                if (dv.Count == 1 || (userDeptId > 0 && ddlSports.Items.Count <= 1))
                {
                    ddlSports.Enabled = false;
                    ddlSports.Attributes["style"] = "background-color:#f1f5f9; cursor:not-allowed;";
                }
                else if (ddlSports.Items.Count > 1)
                {
                    ddlSports.Items.Insert(0, new ListItem("-- Select Department --", "0"));
                    ddlSports.Enabled = true;
                    ddlSports.Attributes["style"] = "";
                }
                else
                {
                    ddlSports.Items.Insert(0, new ListItem("-- All Departments --", "0"));
                }
            }

            int currentDeptId = 0;
            int.TryParse(ddlSports.SelectedValue, out currentDeptId);
            LoadSubDepartment(currentDeptId);
        }
        catch (Exception ex)
        {
            ddlSports.Items.Clear();
            ddlSports.Items.Insert(0, new ListItem("-- All Departments --", "0"));
            ShowMessage("Error loading departments: " + ex.Message, false);
        }
    }

    private void LoadSubDepartment(int deptId)
    {
        if (ddlSubDept == null) return;
        ddlSubDept.Items.Clear();

        int userSubDeptId = 0;
        if (Session["SubDeptID"] != null) int.TryParse(Session["SubDeptID"].ToString(), out userSubDeptId);
        else if (Session["subdept_id"] != null) int.TryParse(Session["subdept_id"].ToString(), out userSubDeptId);
        else if (Session["SubDeptId"] != null) int.TryParse(Session["SubDeptId"].ToString(), out userSubDeptId);

        string subDeptName = Session["SubDeptName"] != null ? Session["SubDeptName"].ToString() : (Session["subdept_name"] != null ? Session["subdept_name"].ToString() : "");

        try
        {
            DataTable dtSub = new DataTable();
            string basicDataConn = ConfigurationManager.ConnectionStrings["BasicDataInfoConnString"] != null
                ? ConfigurationManager.ConnectionStrings["BasicDataInfoConnString"].ConnectionString
                : connString.Replace("SportsModuleDB", "BasicDataInfo");

            using (SqlConnection con = new SqlConnection(basicDataConn))
            {
                string query = "SELECT SubDept_Id, SubDept_Name FROM SubDepartment WHERE (Dept_ID = @DeptID OR @DeptID = 0) ORDER BY SubDept_Name";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@DeptID", deptId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dtSub);
                    }
                }
            }

            if (dtSub.Rows.Count > 0)
            {
                ddlSubDept.DataSource = dtSub;
                ddlSubDept.DataTextField = "SubDept_Name";
                ddlSubDept.DataValueField = "SubDept_Id";
                ddlSubDept.DataBind();
            }
        }
        catch { }

        bool adminOrMIS = IsAdminOrMIS();

        if (adminOrMIS)
        {
            ddlSubDept.Items.Insert(0, new ListItem("-- All Sub Departments --", "0"));
            ddlSubDept.Enabled = true;
            ddlSubDept.Attributes["style"] = "";

            if (userSubDeptId > 0 && ddlSubDept.Items.FindByValue(userSubDeptId.ToString()) != null)
            {
                ddlSubDept.SelectedValue = userSubDeptId.ToString();
            }
            else
            {
                ddlSubDept.SelectedIndex = 0;
            }
        }
        else
        {
            if (userSubDeptId > 0 && ddlSubDept.Items.FindByValue(userSubDeptId.ToString()) != null)
            {
                ddlSubDept.SelectedValue = userSubDeptId.ToString();
            }
            else if (!string.IsNullOrEmpty(subDeptName))
            {
                ddlSubDept.Items.Clear();
                ddlSubDept.Items.Add(new ListItem(subDeptName, userSubDeptId.ToString()));
                ddlSubDept.SelectedIndex = 0;
            }
            else if (ddlSubDept.Items.Count == 0)
            {
                ddlSubDept.Items.Add(new ListItem("-- General --", "0"));
            }

            ddlSubDept.Enabled = false;
            ddlSubDept.Attributes["style"] = "background-color:#f1f5f9; cursor:not-allowed; pointer-events:none;";
        }
    }

    protected void ddlSports_SelectedIndexChanged(object sender, EventArgs e)
    {
        int selectedDeptId = 0;
        int.TryParse(ddlSports.SelectedValue, out selectedDeptId);
        LoadSubDepartment(selectedDeptId);
        LoadDailyPackages();
    }

    protected void ddlSubDept_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadDailyPackages();
    }



    private void LoadDailyPackages()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                DataTable dt = new DataTable();
                try
                {
                    string query = @"
                        SELECT 
                            s.SubscriptionID, 
                            s.SportID, 
                            sp.SportName, 
                            sp.Dept_ID,
                            ISNULL(sp.SubDeptID, 0) AS SubDeptID,
                            ISNULL(d.Dept_Name, sp.SportName) AS DepartmentName,
                            s.PackageName, 
                            s.Fee,
                            s.ItemCode,
                            s.GSTPercentage,
                            ISNULL(s.IsEditable, 1) AS IsEditable
                        FROM Subscriptions s
                        INNER JOIN Sports sp ON s.SportID = sp.SportID
                        LEFT JOIN [BasicDataInfo].[dbo].[Department] d ON sp.Dept_ID = d.Dept_ID
                        WHERE s.SubscriptionType = 'Daily' AND s.Status = 1
                        ORDER BY ISNULL(d.Dept_Name, sp.SportName), sp.SportName, s.PackageName";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }
                    }
                }
                catch
                {
                    // Fallback to stored procedure
                    using (SqlCommand cmd = new SqlCommand("sp_GetDailyPackages", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }
                    }
                }

                DataView dv = dt.DefaultView;
                string filter = "SportName <> 'Sports Cards'";
                if (ddlSports.SelectedValue != "0" && !string.IsNullOrEmpty(ddlSports.SelectedValue))
                {
                    if (dt.Columns.Contains("Dept_ID"))
                    {
                        filter += " AND Dept_ID = " + ddlSports.SelectedValue;
                    }
                    else if (dt.Columns.Contains("SubDeptID"))
                    {
                        filter += " AND SubDeptID = " + ddlSports.SelectedValue;
                    }
                    else if (dt.Columns.Contains("DepartmentID"))
                    {
                        filter += " AND DepartmentID = " + ddlSports.SelectedValue;
                    }
                    else
                    {
                        filter += " AND SportID = " + ddlSports.SelectedValue;
                    }
                }
                else if (!IsAdminOrMIS() && Session["UserRole"] != null && Session["UserRole"].ToString() == "Operator")
                {
                    List<int> allowedDepts = Session["AllowedDepartments"] as List<int>;
                    List<int> allowedSports = Session["AllowedSports"] as List<int>;

                    if (allowedDepts != null && allowedDepts.Count > 0 && dt.Columns.Contains("Dept_ID"))
                    {
                        filter += " AND Dept_ID IN (" + string.Join(",", allowedDepts) + ")";
                    }
                    else if (allowedSports != null && allowedSports.Count > 0)
                    {
                        filter += " AND SportID IN (" + string.Join(",", allowedSports) + ")";
                    }
                }

                if (ddlSubDept != null && ddlSubDept.SelectedValue != "0" && !string.IsNullOrEmpty(ddlSubDept.SelectedValue))
                {
                    if (dt.Columns.Contains("SubDeptID"))
                    {
                        filter += " AND SubDeptID = " + ddlSubDept.SelectedValue;
                    }
                }
                dv.RowFilter = filter;

                ddlDailyPackages.Items.Clear();

                foreach (DataRowView drv in dv)
                {
                    DataRow row = drv.Row;
                    string itemCode = row.Table.Columns.Contains("ItemCode") && row["ItemCode"] != DBNull.Value ? row["ItemCode"].ToString() : "N/A";
                    string deptOrSport = row.Table.Columns.Contains("DepartmentName") && row["DepartmentName"] != DBNull.Value && !string.IsNullOrEmpty(row["DepartmentName"].ToString()) && row["DepartmentName"].ToString() != "Unassigned"
                        ? row["DepartmentName"].ToString()
                        : row["SportName"].ToString();

                    string text = string.Format("[{0}] {1} - {2} (PKR {3:N0})",
                                                itemCode,
                                                deptOrSport,
                                                row["PackageName"],
                                                Convert.ToDecimal(row["Fee"]));

                    bool isEditable = row.Table.Columns.Contains("IsEditable") && row["IsEditable"] != DBNull.Value ? Convert.ToBoolean(row["IsEditable"]) : true;
                    string val = string.Format("{0}|{1}|{2}|{3}|{4}|{5}|{6}",
                                                row["SubscriptionID"],
                                                row["Fee"],
                                                deptOrSport,
                                                row["PackageName"],
                                                row["GSTPercentage"],
                                                row.Table.Columns.Contains("SportID") && row["SportID"] != DBNull.Value ? row["SportID"].ToString() : "0",
                                                isEditable ? "1" : "0");

                    ddlDailyPackages.Items.Add(new ListItem(text, val));
                }

                ddlDailyPackages.Items.Insert(0, new ListItem("-- Select Daily Package --", "0"));
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading packages: " + ex.Message, false);
        }
    }

    private void LoadLockers()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetLockers", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IncludeInactive", 0);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        ddlLocker.Items.Clear();
                        ddlLocker.Items.Add(new ListItem("-- No Locker --", "0"));

                        foreach (DataRow row in dt.Rows)
                        {
                            string text = string.Format("{0} (PKR {1:N0})", row["LockerName"], row["Fee"]);
                            string val = string.Format("{0}|{1}", row["LockerID"], row["Fee"]);
                            ddlLocker.Items.Add(new ListItem(text, val));
                        }
                    }
                }
            }
        }
        catch { }
    }

    protected void ddlCustomerType_SelectedIndexChanged(object sender, EventArgs e)
    {
        ToggleCustomerFields();
    }

    protected void rdoCustomerType_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (rdoCustomerType != null && ddlCustomerType != null && !string.IsNullOrEmpty(rdoCustomerType.SelectedValue))
        {
            ddlCustomerType.SelectedValue = rdoCustomerType.SelectedValue;
        }
        if (ucMemberSubInfo != null) ucMemberSubInfo.Clear();
        ToggleCustomerFields();
    }

    protected void rdoPaymentMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (rdoPaymentMode != null && ddlPaymentMode != null && !string.IsNullOrEmpty(rdoPaymentMode.SelectedValue))
        {
            ddlPaymentMode.SelectedValue = rdoPaymentMode.SelectedValue;
        }

        if (rdoPaymentMode != null)
        {
            foreach (ListItem item in rdoPaymentMode.Items)
            {
                item.Enabled = true;
            }
        }

        ddlPaymentMode_SelectedIndexChanged(sender, e);
    }

    private void UpdatePillActiveState(string type)
    {
        if (rdoCustomerType != null && rdoCustomerType.Items.FindByValue(type) != null)
        {
            rdoCustomerType.SelectedValue = type;
        }
    }

    protected void ddlDepartment_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadDailyPackages();
    }

    protected void btnRefreshProducts_Click(object sender, EventArgs e)
    {
        if (rdoPaymentMode != null)
        {
            foreach (ListItem item in rdoPaymentMode.Items)
            {
                item.Enabled = true;
            }
        }

        LoadDepartments();
        LoadSports();
        LoadDailyPackages();
    }

    protected void txtValidFrom_TextChanged(object sender, EventArgs e)
    {
        SyncDatesAndCalculate();
    }

    protected void txtValidTo_TextChanged(object sender, EventArgs e)
    {
        SyncDatesAndCalculate();
    }

    protected void ddlNumberOfDays_SelectedIndexChanged(object sender, EventArgs e)
    {
        int days = 1;
        int.TryParse(ddlNumberOfDays.SelectedValue, out days);
        if (days < 1) days = 1;

        DateTime validFrom = DateTime.Now.Date;
        if (!string.IsNullOrEmpty(txtValidFrom.Text))
            DateTime.TryParse(txtValidFrom.Text, out validFrom);

        DateTime validTo = validFrom.AddDays(days - 1);
        txtValidTo.Text = validTo.ToString("yyyy-MM-dd");

        CalculateNetTotal(null, null);
    }

    private void SyncDatesAndCalculate()
    {
        DateTime validFrom = DateTime.Now.Date;
        if (!string.IsNullOrEmpty(txtValidFrom.Text))
            DateTime.TryParse(txtValidFrom.Text, out validFrom);

        DateTime validTo = validFrom;
        if (!string.IsNullOrEmpty(txtValidTo.Text))
            DateTime.TryParse(txtValidTo.Text, out validTo);

        if (validTo < validFrom)
        {
            validTo = validFrom;
            txtValidTo.Text = validTo.ToString("yyyy-MM-dd");
        }

        int numberOfDays = (validTo - validFrom).Days + 1;
        if (numberOfDays < 1) numberOfDays = 1;

        if (ddlNumberOfDays.Items.FindByValue(numberOfDays.ToString()) != null)
        {
            ddlNumberOfDays.SelectedValue = numberOfDays.ToString();
        }

        CalculateNetTotal(null, null);
    }

    protected void ddlPaymentMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlPaymentMode.SelectedValue == "Credit Card" || ddlPaymentMode.SelectedValue == "Online Payment")
        {
            divCardNoPayment.Visible = (ddlPaymentMode.SelectedValue == "Credit Card");
            divRefID.Visible = true;
            divBankCard.Visible = (ddlPaymentMode.SelectedValue == "Credit Card");
            if (divCardType != null) divCardType.Visible = (ddlPaymentMode.SelectedValue == "Credit Card");
            if (divBankDiscountPercent != null) divBankDiscountPercent.Visible = (ddlPaymentMode.SelectedValue == "Credit Card");

            if (ddlPaymentMode.SelectedValue == "Credit Card")
            {
                LoadActiveBankCards();
            }

            if (string.IsNullOrEmpty(txtReferenceID.Text))
            {
                txtReferenceID.Text = "REF-" + DateTime.Now.ToString("yyyyMMddHHmmss");
            }
            if (!string.IsNullOrEmpty(txtPaymentCardNo.Text) && txtPaymentCardNo.Text.Trim().Length >= 4)
            {
                LookupCardPrefixOffer();
            }
        }
        else
        {
            divCardNoPayment.Visible = false;
            divRefID.Visible = true;
            divBankCard.Visible = false;
            if (divCardType != null) divCardType.Visible = false;
            if (divBankDiscountPercent != null) divBankDiscountPercent.Visible = false;
            if (divCardOfferInfo != null) divCardOfferInfo.Visible = false;
            txtReferenceID.Text = "";
            txtPaymentCardNo.Text = "";
            if (ddlBankCard.Items.Count > 0) ddlBankCard.SelectedIndex = 0;
            txtCardType.Text = "";
            txtBankDiscountPercent.Text = "0%";
        }
        CalculateNetTotal(null, null);
    }

    private void ToggleCustomerFields()
    {
        pnlMemberInfoCard.Visible = false;
        string type = ddlCustomerType.SelectedValue;
        UpdatePillActiveState(type);

        if (type == "Member")
        {
            lblCustomerHeader.Text = "Club Member Search";
            pnlMemberSearch.Visible = true;
            ddlMemberNames.Visible = true;
            txtCustomerName.Visible = false;
            txtGuestNameDisplay.Visible = false;
            txtAffiliatedNameDisplay.Visible = false;
            pnlAffiliatedSearch.Visible = false;
            pnlGuestSearch.Visible = false;

            ddlMemberNames.Items.Clear();
            hfMemberID.Value = "";
            hfMemberNo.Value = "";
            txtCustomerName.Text = "";
            txtCardNo.Text = "";
            txtReservationNo.Text = "";
        }
        else if (type == "Affiliated Member")
        {
            lblCustomerHeader.Text = "Affiliated Member Search";
            pnlMemberSearch.Visible = false;
            ddlMemberNames.Visible = false;
            txtCustomerName.Visible = false;
            txtGuestNameDisplay.Visible = false;
            txtAffiliatedNameDisplay.Visible = true;
            pnlAffiliatedSearch.Visible = true;
            pnlGuestSearch.Visible = false;

            txtAffiliatedNameDisplay.ReadOnly = false;
            txtAffiliatedNameDisplay.Text = "";
            txtCustomerName.Text = "";
            txtCardNo.Text = "";
            txtReservationNo.Text = "";
            hfMemberID.Value = "";
            hfMemberNo.Value = "";
        }
        else if (type == "Guest Room")
        {
            lblCustomerHeader.Text = "Guest House Room Search";
            pnlMemberSearch.Visible = false;
            ddlMemberNames.Visible = false;
            txtCustomerName.Visible = false;
            txtGuestNameDisplay.Visible = true;
            txtAffiliatedNameDisplay.Visible = false;
            pnlAffiliatedSearch.Visible = false;
            pnlGuestSearch.Visible = true;

            txtGuestNameDisplay.ReadOnly = true;
            txtGuestNameDisplay.Text = "";
            txtCustomerName.Text = "";
            txtCardNo.Text = "";
            txtReservationNo.Text = "";
            hfMemberID.Value = "";
            hfMemberNo.Value = "";
        }
        else
        {
            lblCustomerHeader.Text = "Non Member / Guest Info";
            pnlMemberSearch.Visible = false;
            ddlMemberNames.Visible = false;
            txtCustomerName.Visible = true;
            txtGuestNameDisplay.Visible = false;
            txtAffiliatedNameDisplay.Visible = false;
            pnlAffiliatedSearch.Visible = false;
            pnlGuestSearch.Visible = false;

            txtCustomerName.ReadOnly = false;
            txtCustomerName.Text = "";
            txtCardNo.Text = "";
            txtReservationNo.Text = "";
            hfMemberID.Value = "";
            hfMemberNo.Value = "";
        }
    }

    protected void btnSearchMember_Click(object sender, EventArgs e)
    {
        if (ucMemberSubInfo != null) ucMemberSubInfo.Clear();
        if (string.IsNullOrWhiteSpace(txtMemberSearch.Text))
        {
            ShowMessage("Please enter Member ID or Name.", false);
            return;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_SearchMembers", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SearchTerm", txtMemberSearch.Text.Trim());

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        ddlMemberNames.Items.Clear();

                        if (dt.Rows.Count > 0)
                        {
                            foreach (DataRow row in dt.Rows)
                            {
                                string memberNo = row["MembershipNo"].ToString();
                                string rel = dt.Columns.Contains("Relationship") ? row["Relationship"].ToString() : "";
                                if (string.IsNullOrEmpty(rel) || rel == "Self" || rel == "Dependent")
                                {
                                    rel = GetRelationFromMemberNo(memberNo);
                                }

                                string text = row["MemberDisplay"].ToString();
                                string val = string.Format("{0}|{1}|{2}|{3}", row["MemberID"], memberNo, row["FullName"], rel);
                                ddlMemberNames.Items.Add(new ListItem(text, val));
                            }
                            ddlMemberNames.Items.Insert(0, new ListItem("-- Select Member / Dependent --", "0"));

                            // Clear hf fields until a selection is made
                            hfMemberID.Value = "";
                            hfMemberNo.Value = "";
                            txtCustomerName.Text = "";
                            pnlMemberInfoCard.Visible = false;
                            lblMessage.Visible = false;

                            // Load global family subscription card using the first row's MemberID
                            int mainMemberId = Convert.ToInt32(dt.Rows[0]["MemberID"]);
                            string mainMemberName = dt.Rows[0]["FullName"].ToString(); // fallback
                            // Try to find the actual Main Member row to get the correct name
                            foreach (DataRow row in dt.Rows)
                            {
                                string memberNo = row["MembershipNo"].ToString();
                                string rel = dt.Columns.Contains("Relationship") ? row["Relationship"].ToString() : "";
                                if (string.IsNullOrEmpty(rel) || rel == "Self" || rel == "Dependent")
                                {
                                    rel = GetRelationFromMemberNo(memberNo);
                                }
                                if (rel == "Self")
                                {
                                    mainMemberName = row["FullName"].ToString();
                                    break;
                                }
                            }
                            ucMemberSubInfo.LoadFamilySubscriptions(mainMemberId, mainMemberName);

                            int exactMatchIndex = -1;
                            string searchStr = txtMemberSearch.Text.Trim();
                            for (int i = 1; i < ddlMemberNames.Items.Count; i++)
                            {
                                if (ddlMemberNames.Items[i].Text.StartsWith(searchStr + " -", StringComparison.OrdinalIgnoreCase))
                                {
                                    exactMatchIndex = i;
                                    break;
                                }
                            }

                            if (dt.Rows.Count == 1 || exactMatchIndex != -1)
                            {
                                ddlMemberNames.SelectedIndex = exactMatchIndex != -1 ? exactMatchIndex : 1;
                                ddlMemberNames_SelectedIndexChanged(null, null);
                            }
                        }
                        else
                        {
                            hfMemberID.Value = "";
                            hfMemberNo.Value = "";
                            txtCustomerName.Text = "";
                            pnlMemberInfoCard.Visible = false;
                            ShowMessage("Member not found.", true);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error searching member: " + ex.Message, true);
        }
    }

    protected void btnValidateGuest_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtReservationNo.Text))
        {
            ShowMessage("Please enter Room No or Reservation No.", false);
            return;
        }
        try
        {
            string guestRoomConn = ConfigurationManager.ConnectionStrings["GuestRoomConnString"] != null
                ? ConfigurationManager.ConnectionStrings["GuestRoomConnString"].ConnectionString
                : connString.Replace("SportsModuleDB", "GuestRoom");
            using (SqlConnection con = new SqlConnection(guestRoomConn))
            {
                // Fetch the most recent allocation for this room
                string query = @"SELECT TOP 1 a.AllocatedDate, a.CheckOutDate, a.ActualCheckOutDate, a.RoomNo,
       ISNULL(r.GuestName,'') AS GuestName, ISNULL(r.MembershipNo,'') AS MembershipNo
FROM RoomAllocations a INNER JOIN RoomReservations r ON a.ReservationNo=r.ReservationNo
WHERE (LTRIM(RTRIM(a.RoomNo))=@ResNo OR LTRIM(RTRIM(a.ReservationNo))=@ResNo
       OR a.RoomNo LIKE '%'+@ResNo+'%')
ORDER BY a.AllocationID DESC";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@ResNo", txtReservationNo.Text.Trim());
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            DateTime? checkOutDate = null;
                            if (reader["CheckOutDate"] != DBNull.Value)
                            {
                                DateTime dtOut;
                                if (DateTime.TryParse(reader["CheckOutDate"].ToString(), out dtOut))
                                    checkOutDate = dtOut.Date;
                            }

                            // OCCUPIED: ActualCheckOutDate IS NULL AND (CheckOutDate IS NULL OR CheckOutDate >= Today)
                            bool isOccupied = (reader["ActualCheckOutDate"] == DBNull.Value)
                                           && (!checkOutDate.HasValue || checkOutDate.Value >= DateTime.Today);

                            string roomNo = reader["RoomNo"] != DBNull.Value ? reader["RoomNo"].ToString() : "";
                            string guestName = reader["GuestName"] != DBNull.Value ? reader["GuestName"].ToString() : "";
                            string membershipNo = reader["MembershipNo"] != DBNull.Value ? reader["MembershipNo"].ToString() : "";

                            if (isOccupied)
                            {
                                // Room OCCUPIED today — allow slip, no alert
                                hfBlockSlip.Value = "0";
                                lblMessage.Visible = false;
                                ShowMessage("Room " + roomNo + " is Occupied (" + guestName + "). You may proceed.", false);
                                if (!string.IsNullOrEmpty(guestName))
                                {
                                    string fn = guestName + " (Room " + roomNo + ")";
                                    txtCustomerName.Text = fn; txtGuestNameDisplay.Text = fn;
                                }
                                if (!string.IsNullOrEmpty(membershipNo)) { hfMemberNo.Value = membershipNo; LookupMemberID(membershipNo); }
                                else { hfMemberID.Value = ""; }
                            }
                            else
                            {
                                // Room CHECKED OUT or VACANT — block slip
                                string guestDisplay = !string.IsNullOrEmpty(guestName)
                                    ? guestName + (!string.IsNullOrEmpty(roomNo) ? " (Room " + roomNo + ")" : "")
                                    : "Room " + roomNo;

                                hfBlockSlip.Value = "1";
                                txtCustomerName.Text = "";
                                txtGuestNameDisplay.Text = "";
                                hfMemberID.Value = "";
                                hfMemberNo.Value = "";

                                string safeName = HttpUtility.JavaScriptStringEncode(guestDisplay);
                                // Pass a single info row describing the status
                                string statusJson = "[{\"name\":\"Room status: Checked Out / Vacant\",\"endDate\":\"Please contact relevant department\"}]";
                                string script = string.Format(
                                    "showExpiredSubscriptionAlert('{0}', 'Guest Room', {1}, true);",
                                    safeName, statusJson);
                                ScriptManager.RegisterStartupScript(this, GetType(),
                                    "GuestNotOccupied_" + Guid.NewGuid().ToString("N"), script, true);
                            }
                        }
                        else
                        {
                            // No record found — room is VACANT
                            string roomNo = txtReservationNo.Text.Trim();
                            hfBlockSlip.Value = "1";
                            txtCustomerName.Text = "";
                            txtGuestNameDisplay.Text = "";
                            hfMemberID.Value = "";
                            hfMemberNo.Value = "";

                            string safeName = HttpUtility.JavaScriptStringEncode("Room " + roomNo);
                            string statusJson = "[{\"name\":\"Room status: Vacant / Not Found\",\"endDate\":\"Please contact relevant department\"}]";
                            string script = string.Format(
                                "showExpiredSubscriptionAlert('{0}', 'Guest Room', {1}, true);",
                                safeName, statusJson);
                            ScriptManager.RegisterStartupScript(this, GetType(),
                                "GuestVacant_" + Guid.NewGuid().ToString("N"), script, true);
                        }
                    }
                }
            }
        }
        catch (Exception ex) { ShowMessage("Error validating Guest Room: " + ex.Message, true); }
    }

    private void LookupMemberID(string membershipNo)
    {
        try
        {
            string memberShipConn = ConfigurationManager.ConnectionStrings["MemberShipConnString"] != null ? ConfigurationManager.ConnectionStrings["MemberShipConnString"].ConnectionString : connString.Replace("SportsModuleDB", "MemberShip");
            using (SqlConnection con = new SqlConnection(memberShipConn))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT MemberID FROM MemberProfile WHERE MemberNo = @MemberNo OR MemberNo_New = @MemberNo", con))
                {
                    cmd.Parameters.AddWithValue("@MemberNo", membershipNo);
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        hfMemberID.Value = result.ToString();
                    }
                    else
                    {
                        hfMemberID.Value = "";
                    }
                }
            }
        }
        catch { }
    }

    protected void btnSearchAffiliated_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtCardNo.Text))
        {
            ShowMessage("Please enter Introductory No / Card No.", false);
            return;
        }

        try
        {
            string memberShipConn = ConfigurationManager.ConnectionStrings["MemberShipConnString"] != null ? ConfigurationManager.ConnectionStrings["MemberShipConnString"].ConnectionString : connString.Replace("SportsModuleDB", "MemberShip");
            using (SqlConnection con = new SqlConnection(memberShipConn))
            {
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT MemberName, DateTo FROM IncomingClubMembers WHERE IntroductoryNo = @IntroNo", con))
                {
                    cmd.Parameters.AddWithValue("@IntroNo", txtCardNo.Text.Trim());
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string affName = reader["MemberName"] != DBNull.Value ? reader["MemberName"].ToString() : "";

                            DateTime? dateTo = null;
                            if (reader["DateTo"] != DBNull.Value)
                            {
                                DateTime dtVal;
                                if (DateTime.TryParse(reader["DateTo"].ToString(), out dtVal))
                                    dateTo = dtVal.Date;
                            }

                            bool isExpired = dateTo.HasValue && dateTo.Value < DateTime.Today;

                            if (isExpired)
                            {
                                // --- EXPIRED: block slip, show modal ---
                                hfBlockSlip.Value = "1";
                                txtCustomerName.Text = "";
                                txtAffiliatedNameDisplay.Text = "";

                                string displayName = !string.IsNullOrEmpty(affName) ? affName : "Affiliated Member";
                                string expDateStr = dateTo.HasValue ? dateTo.Value.ToString("dd/MM/yyyy") : "";

                                string safeName = HttpUtility.JavaScriptStringEncode(displayName);
                                string expJson = string.Format("[{{\"name\":\"Intro Card (Valid To: {0})\",\"endDate\":\"EXPIRED\"}}]", expDateStr);
                                string script = string.Format(
                                    "showExpiredSubscriptionAlert('{0}', 'Affiliated Member', {1}, true);",
                                    safeName, expJson);
                                ScriptManager.RegisterStartupScript(this, GetType(),
                                    "AffExpired_" + Guid.NewGuid().ToString("N"), script, true);
                            }
                            else
                            {
                                // --- VALID: proceed normally ---
                                hfBlockSlip.Value = "0";
                                txtCustomerName.Text = affName;
                                txtAffiliatedNameDisplay.Text = affName;
                                lblMessage.Visible = false;
                            }
                        }
                        else
                        {
                            txtCustomerName.Text = "";
                            txtAffiliatedNameDisplay.Text = "";
                            hfBlockSlip.Value = "0";
                            ShowMessage("Affiliated Member not found with this Introductory No.", true);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error searching Affiliated Member: " + ex.Message, true);
        }
    }

    protected void ddlMemberNames_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlMemberNames.SelectedValue != "0")
        {
            string[] parts = ddlMemberNames.SelectedValue.Split('|');
            if (parts.Length >= 4)
            {
                hfMemberID.Value = parts[0];
                hfMemberNo.Value = parts[1];

                txtCustomerName.Text = parts[2];
                lblInfoMemberNo.Text = parts[1];
                lblInfoAge.Text = "N/A";
                pnlMemberInfoCard.Visible = true;

                // Fetch DOB and set ddlRateType
                try
                {
                    string memberShipConn = ConfigurationManager.ConnectionStrings["MemberShipConnString"] != null ? ConfigurationManager.ConnectionStrings["MemberShipConnString"].ConnectionString : connString.Replace("SportsModuleDB", "MemberShip");
                    using (SqlConnection con = new SqlConnection(memberShipConn))
                    {
                        using (SqlCommand cmd = new SqlCommand("SELECT DOB, CreatedDate FROM MemberProfile WHERE MemberID = @MemberID OR MemberID_New = @MemberID", con))
                        {
                            cmd.Parameters.AddWithValue("@MemberID", hfMemberID.Value);
                            con.Open();
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    DateTime dob;
                                    if (DateTime.TryParse(reader["DOB"].ToString(), out dob))
                                    {
                                        int age = DateTime.Now.Year - dob.Year;
                                        if (dob.Date > DateTime.Now.AddYears(-age)) age--;
                                        lblInfoAge.Text = age.ToString() + " Yrs";

                                        DateTime createdDate;
                                        int memYears = 0;
                                        if (DateTime.TryParse(reader["CreatedDate"].ToString(), out createdDate))
                                        {
                                            memYears = DateTime.Now.Year - createdDate.Year;
                                            if (createdDate.Date > DateTime.Now.AddYears(-memYears)) memYears--;
                                        }

                                        // POS policy discount is disabled for all members regardless of age / tenure
                                        ddlRateType.SelectedValue = "Base";
                                    }
                                }
                            }
                        }
                    }
                }
                catch { }

                try
                {
                    using (SqlConnection con = new SqlConnection(connString))
                    {
                        // Fetch expired subscriptions for this member filtered by user's sport access permissions
                        string querySub = @"
                            SELECT ISNULL(s.PackageName, 'Subscription') AS PackageName,
                                   CONVERT(VARCHAR(10), ms.EndDate, 103) AS EndDateStr
                            FROM MemberSubscriptions ms
                            LEFT JOIN Subscriptions s ON ms.SubscriptionID = s.SubscriptionID
                            WHERE (ms.MemberID = @MemberID OR ms.DependentMemberNo = @MemberNo)
                              AND ms.EndDate IS NOT NULL
                              AND ms.EndDate <= CAST(GETDATE() AS DATE)";

                        if (Session["UserRole"] != null && Session["UserRole"].ToString() == "Operator")
                        {
                            List<int> allowedSports = Session["AllowedSports"] as List<int>;
                            if (allowedSports != null && allowedSports.Count > 0)
                            {
                                querySub += " AND s.SportID IN (" + string.Join(",", allowedSports) + ")";
                            }
                            else
                            {
                                querySub += " AND s.SportID = -1";
                            }
                        }

                        querySub += " ORDER BY ms.EndDate DESC";

                        using (SqlCommand cmdSub = new SqlCommand(querySub, con))
                        {
                            cmdSub.Parameters.AddWithValue("@MemberID", hfMemberID.Value);
                            cmdSub.Parameters.AddWithValue("@MemberNo", hfMemberNo.Value);
                            con.Open();

                            using (SqlDataAdapter daSub = new SqlDataAdapter(cmdSub))
                            {
                                DataTable dtExpired = new DataTable();
                                daSub.Fill(dtExpired);

                                if (dtExpired.Rows.Count > 0)
                                {
                                    string memberName = parts.Length >= 3 ? parts[2] : txtCustomerName.Text;
                                    string memberType = parts.Length >= 4 ? parts[3] : "Member";

                                    // Build JSON array: [{name:"...", endDate:"..."}, ...]
                                    System.Text.StringBuilder sbJson = new System.Text.StringBuilder();
                                    sbJson.Append("[");
                                    for (int ri = 0; ri < dtExpired.Rows.Count; ri++)
                                    {
                                        if (ri > 0) sbJson.Append(",");
                                        string pkgName = dtExpired.Rows[ri]["PackageName"].ToString().Replace("'", "\\'").Replace("\"", "\\\"");
                                        string expDate = dtExpired.Rows[ri]["EndDateStr"].ToString();
                                        sbJson.AppendFormat("{{\"name\":\"{0}\",\"endDate\":\"{1}\"}}", pkgName, expDate);
                                    }
                                    sbJson.Append("]");

                                    string safeName = HttpUtility.JavaScriptStringEncode(memberName);
                                    string safeType = HttpUtility.JavaScriptStringEncode(memberType);
                                    string script = string.Format(
                                        "showExpiredSubscriptionAlert('{0}', '{1}', {2});",
                                        safeName, safeType, sbJson.ToString());

                                    ScriptManager.RegisterStartupScript(this, GetType(),
                                        "MemberExpiredAlert_" + Guid.NewGuid().ToString("N"), script, true);
                                }
                            }
                        }
                    }
                }
                catch { }

                CalculateNetTotal(null, null);
            }
        }
        else
        {
            hfMemberID.Value = "";
            hfMemberNo.Value = "";
            txtCustomerName.Text = "";
            pnlMemberInfoCard.Visible = false;
            CalculateNetTotal(null, null);
        }
    }

    protected void txtItemCode_TextChanged(object sender, EventArgs e)
    {
        string code = txtItemCode.Text.Trim();
        if (string.IsNullOrEmpty(code))
        {
            ddlDailyPackages.SelectedValue = "0";
            ddlDailyPackages_SelectedIndexChanged(null, null);
            return;
        }

        // Try searching package by item code across all daily packages
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetDailyPackages", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        DataRow matchedRow = null;
                        foreach (DataRow row in dt.Rows)
                        {
                            if (row.Table.Columns.Contains("ItemCode") && row["ItemCode"] != DBNull.Value)
                            {
                                string ic = row["ItemCode"].ToString().Trim();
                                if (ic.Equals(code, StringComparison.OrdinalIgnoreCase))
                                {
                                    matchedRow = row;
                                    break;
                                }
                            }
                        }

                        if (matchedRow != null)
                        {
                            string deptId = (matchedRow.Table.Columns.Contains("SubDeptID") && matchedRow["SubDeptID"] != DBNull.Value)
                                ? matchedRow["SubDeptID"].ToString()
                                : (matchedRow.Table.Columns.Contains("DepartmentID") && matchedRow["DepartmentID"] != DBNull.Value ? matchedRow["DepartmentID"].ToString() : "");

                            // Automatically select the Department in ddlSports filter if available
                            if (!string.IsNullOrEmpty(deptId) && ddlSports.Items.FindByValue(deptId) != null)
                            {
                                ddlSports.SelectedValue = deptId;
                                LoadDailyPackages();
                            }
                            else
                            {
                                ddlSports.SelectedValue = "0";
                                LoadDailyPackages();
                            }

                            bool found = MatchAndSelectPackageByCode(code);
                            if (found)
                            {
                                lblMessage.Visible = false;
                                return;
                            }
                        }
                    }
                }
            }
        }
        catch { }

        // Fallback: search in existing dropdown list
        bool matchedInDropdown = MatchAndSelectPackageByCode(code);
        if (!matchedInDropdown && ddlSports.SelectedValue != "0")
        {
            ddlSports.SelectedValue = "0";
            LoadDailyPackages();
            matchedInDropdown = MatchAndSelectPackageByCode(code);
        }

        if (matchedInDropdown)
        {
            lblMessage.Visible = false;
        }
        else
        {
            ShowMessage("Package with Item Code '" + code + "' not found.", true);
            ddlDailyPackages.SelectedValue = "0";
            ddlDailyPackages_SelectedIndexChanged(null, null);
        }
    }

    private bool MatchAndSelectPackageByCode(string code)
    {
        string exactBracket = "[" + code + "]";
        foreach (ListItem item in ddlDailyPackages.Items)
        {
            if (item.Value != "0")
            {
                if (item.Text.StartsWith(exactBracket, StringComparison.OrdinalIgnoreCase))
                {
                    ddlDailyPackages.SelectedValue = item.Value;
                    ddlDailyPackages_SelectedIndexChanged(null, null);
                    return true;
                }
            }
        }

        foreach (ListItem item in ddlDailyPackages.Items)
        {
            if (item.Value != "0")
            {
                if (item.Text.IndexOf(exactBracket, StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    ddlDailyPackages.SelectedValue = item.Value;
                    ddlDailyPackages_SelectedIndexChanged(null, null);
                    return true;
                }
            }
        }

        return false;
    }

    protected void ddlDailyPackages_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlDailyPackages.SelectedValue != "0")
        {
            string[] parts = ddlDailyPackages.SelectedValue.Split('|');
            if (parts.Length >= 2)
            {
                decimal fee = 0;
                decimal.TryParse(parts[1], out fee);
                txtCustomRate.Text = fee.ToString("0");
            }

            if (parts.Length >= 6)
            {
                string sportId = parts[5];
                if (!string.IsNullOrEmpty(sportId) && ddlSports.Items.FindByValue(sportId) != null)
                {
                    ddlSports.SelectedValue = sportId;
                }
            }

            if (parts.Length >= 7)
            {
                bool isEditable = parts[6] == "1";
                txtCustomRate.ReadOnly = !isEditable;
                txtCustomRate.Style["background-color"] = isEditable ? "#ffffff" : "#f1f5f9";
            }
            else
            {
                txtCustomRate.ReadOnly = false;
                txtCustomRate.Style["background-color"] = "#ffffff";
            }

            ListItem selectedItem = ddlDailyPackages.SelectedItem;
            if (selectedItem != null && selectedItem.Text.StartsWith("["))
            {
                int closeIndex = selectedItem.Text.IndexOf("]");
                if (closeIndex > 1)
                {
                    txtItemCode.Text = selectedItem.Text.Substring(1, closeIndex - 1);
                }
            }
        }
        else
        {
            txtCustomRate.Text = "0";
            txtCustomRate.ReadOnly = false;
            txtCustomRate.Style["background-color"] = "#ffffff";
            txtItemCode.Text = "";
        }
        CalculateNetTotal(null, null);
    }

    protected void CalculateNetTotal(object sender, EventArgs e)
    {
        if (ddlDailyPackages.SelectedValue == "0")
        {
            txtBaseFee.Text = "0";
            txtGSTAmount.Text = "0";
            txtPolicyDiscount.Text = "0";
            txtNetTotal.Text = "0";
            hfFeeAmount.Value = "0";
            return;
        }

        string[] parts = ddlDailyPackages.SelectedValue.Split('|');
        if (parts.Length < 5) return;

        int numberOfDays = 1;
        int.TryParse(ddlNumberOfDays.SelectedValue, out numberOfDays);
        if (numberOfDays < 1) numberOfDays = 1;

        decimal baseFeePerDay = Convert.ToDecimal(parts[1]);
        if (txtCustomRate != null && !string.IsNullOrEmpty(txtCustomRate.Text))
        {
            decimal.TryParse(txtCustomRate.Text.Replace(",", "").Trim(), out baseFeePerDay);
        }

        decimal baseFee = baseFeePerDay * numberOfDays;
        decimal gstPercent = Convert.ToDecimal(parts[4]);

        lblGSTPercent.Text = gstPercent.ToString("0.##");
        hfGSTPercentage.Value = gstPercent.ToString();

        txtBaseFee.Text = baseFee.ToString("0.00");
        hfFeeAmount.Value = baseFee.ToString();

        decimal policyDiscount = 0;
        if (ddlRateType.SelectedValue == "Half")
        {
            policyDiscount = baseFee * 0.5m;
        }
        else if (ddlRateType.SelectedValue == "Senior")
        {
            policyDiscount = baseFee; // 100% off
        }

        txtPolicyDiscount.Text = policyDiscount.ToString("0.00");

        decimal feeAfterPolicy = baseFee - policyDiscount;
        if (feeAfterPolicy < 0) feeAfterPolicy = 0;

        decimal gstAmount = feeAfterPolicy * (gstPercent / 100m);
        txtGSTAmount.Text = gstAmount.ToString("0.00");

        decimal manualDiscount = 0;
        decimal.TryParse(txtManualDiscount.Text, out manualDiscount);

        decimal lockerFee = 0;
        if (ddlLocker.SelectedValue != "0" && !string.IsNullOrEmpty(ddlLocker.SelectedValue))
        {
            string[] lockerParts = ddlLocker.SelectedValue.Split('|');
            if (lockerParts.Length >= 2)
            {
                decimal.TryParse(lockerParts[1], out lockerFee);
            }
        }
        txtLockerFee.Value = lockerFee.ToString("0.00");

        decimal netTotal = feeAfterPolicy + gstAmount + lockerFee;
        if (netTotal < 0) netTotal = 0;

        txtNetTotal.Text = Math.Round(netTotal).ToString("0");
    }

    protected void txtGridRow_TextChanged(object sender, EventArgs e)
    {
        TextBox txt = sender as TextBox;
        if (txt != null)
        {
            GridViewRow row = txt.NamingContainer as GridViewRow;
            if (row != null)
            {
                int rowIndex = row.RowIndex;
                TextBox txtGridRate = row.FindControl("txtGridRate") as TextBox;
                TextBox txtGridDays = row.FindControl("txtGridDays") as TextBox;

                if (txtGridRate != null && txtGridDays != null)
                {
                    decimal rate = 0;
                    int days = 1;
                    decimal.TryParse(txtGridRate.Text.Replace(",", "").Trim(), out rate);
                    int.TryParse(txtGridDays.Text.Trim(), out days);
                    if (days < 1) days = 1;

                    DataTable dt = CartDataTable;
                    if (rowIndex >= 0 && rowIndex < dt.Rows.Count)
                    {
                        DataRow dr = dt.Rows[rowIndex];

                        if (dr.Table.Columns.Contains("IsEditable") && dr["IsEditable"] != DBNull.Value)
                        {
                            if (!Convert.ToBoolean(dr["IsEditable"]))
                            {
                                BindCart();
                                return;
                            }
                        }

                        decimal gstPercent = 0;
                        if (dr.Table.Columns.Contains("GSTPercentage") && dr["GSTPercentage"] != DBNull.Value)
                        {
                            decimal.TryParse(dr["GSTPercentage"].ToString(), out gstPercent);
                        }

                        decimal lockerFee = 0;
                        if (dr.Table.Columns.Contains("LockerFee") && dr["LockerFee"] != DBNull.Value)
                        {
                            decimal.TryParse(dr["LockerFee"].ToString(), out lockerFee);
                        }

                        decimal policyDiscount = 0;
                        if (dr.Table.Columns.Contains("PolicyDiscount") && dr["PolicyDiscount"] != DBNull.Value)
                        {
                            decimal.TryParse(dr["PolicyDiscount"].ToString(), out policyDiscount);
                        }

                        decimal baseFeeTotal = rate * days;
                        decimal feeAfterPolicy = baseFeeTotal - policyDiscount;
                        if (feeAfterPolicy < 0) feeAfterPolicy = 0;

                        decimal gstAmount = feeAfterPolicy * (gstPercent / 100m);
                        decimal netTotal = feeAfterPolicy + gstAmount + lockerFee;

                        dr["BaseFee"] = baseFeeTotal;
                        dr["NumberOfDays"] = days;
                        dr["GSTAmount"] = gstAmount;
                        dr["NetTotal"] = netTotal;

                        if (dr.Table.Columns.Contains("ValidFrom") && dr["ValidFrom"] != DBNull.Value)
                        {
                            DateTime validFrom = Convert.ToDateTime(dr["ValidFrom"]);
                            dr["ValidTo"] = validFrom.AddDays(days - 1);
                        }

                        CartDataTable = dt;
                        BindCart();
                    }
                }
            }
        }
    }

    protected void btnAddToList_Click(object sender, EventArgs e)
    {
        if (ddlDailyPackages.SelectedValue == "0")
        {
            ShowMessage("Please select a package first.", true);
            return;
        }

        CalculateNetTotal(null, null);

        string[] parts = ddlDailyPackages.SelectedValue.Split('|');
        if (parts.Length < 5) return;

        int subId = Convert.ToInt32(parts[0]);
        string pkgName = parts[3];
        // Parse item code if available from dropdown text, or set N/A
        string ddlText = ddlDailyPackages.SelectedItem.Text;
        string itemCode = "N/A";
        if (ddlText.StartsWith("["))
        {
            int endIndex = ddlText.IndexOf("]");
            if (endIndex > 1)
            {
                itemCode = ddlText.Substring(1, endIndex - 1);
            }
        }

        int numberOfDays = 1;
        int.TryParse(ddlNumberOfDays.SelectedValue, out numberOfDays);

        DateTime validFrom = DateTime.Now.Date;
        if (!string.IsNullOrEmpty(txtValidFrom.Text))
            DateTime.TryParse(txtValidFrom.Text, out validFrom);

        DateTime validTo = validFrom.AddDays(numberOfDays > 0 ? numberOfDays - 1 : 0);

        int lockerId = 0;
        string lockerName = "";
        decimal lockerFee = 0;
        if (ddlLocker.SelectedValue != "0")
        {
            string[] lockerParts = ddlLocker.SelectedValue.Split('|');
            int.TryParse(lockerParts[0], out lockerId);
            lockerName = ddlLocker.SelectedItem.Text.Split('(')[0].Trim();
            decimal.TryParse(lockerParts[1], out lockerFee);
        }

        decimal baseFee = 0, gstAmount = 0, policyDiscount = 0, netTotal = 0, gstPercent = 0;
        decimal.TryParse(txtBaseFee.Text, out baseFee);
        decimal.TryParse(txtGSTAmount.Text, out gstAmount);
        decimal.TryParse(txtPolicyDiscount.Text, out policyDiscount);
        decimal.TryParse(txtNetTotal.Text, out netTotal);
        decimal.TryParse(hfGSTPercentage.Value, out gstPercent);

        bool isEditable = parts.Length >= 7 ? parts[6] == "1" : true;
        string deptName = parts.Length > 2 ? parts[2] : "";
        DataTable dt = CartDataTable;
        dt.Rows.Add(subId, itemCode, pkgName, lockerId, lockerName, validFrom, validTo, numberOfDays, baseFee, gstPercent, gstAmount, policyDiscount, lockerFee, netTotal, isEditable, deptName);

        CartDataTable = dt;
        BindCart();

        // Reset inputs
        txtItemCode.Text = "";
        ddlDailyPackages.SelectedIndex = 0;
        txtCustomRate.Text = "0";
        txtCustomRate.ReadOnly = false;
        txtCustomRate.Style["background-color"] = "#ffffff";
        ddlLocker.SelectedIndex = 0;
        txtBaseFee.Text = "0";
        txtGSTAmount.Text = "0";
        txtPolicyDiscount.Text = "0";
        txtNetTotal.Text = "0";
        hfFeeAmount.Value = "0";

        // Auto Focus back to Item Code
        txtItemCode.Focus();
    }

    private void BindCart()
    {
        gvCart.DataSource = CartDataTable;
        gvCart.DataBind();
        UpdateCartTotal();
    }

    protected void gvCart_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "RemoveItem")
        {
            int index = Convert.ToInt32(e.CommandArgument);
            DataTable dt = CartDataTable;
            dt.Rows.RemoveAt(index);
            CartDataTable = dt;
            BindCart();
        }
    }

    protected void gvCart_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView drv = e.Row.DataItem as DataRowView;
            if (drv != null)
            {
                bool isEditable = drv.Row.Table.Columns.Contains("IsEditable") && drv["IsEditable"] != DBNull.Value
                    ? Convert.ToBoolean(drv["IsEditable"])
                    : true;

                if (!isEditable)
                {
                    TextBox txtGridRate = e.Row.FindControl("txtGridRate") as TextBox;
                    TextBox txtGridDays = e.Row.FindControl("txtGridDays") as TextBox;

                    if (txtGridRate != null)
                    {
                        txtGridRate.ReadOnly = true;
                        txtGridRate.Style["background-color"] = "#f1f5f9";
                        txtGridRate.Style["color"] = "#64748b";
                        txtGridRate.Style["cursor"] = "not-allowed";
                    }
                    if (txtGridDays != null)
                    {
                        txtGridDays.ReadOnly = true;
                        txtGridDays.Style["background-color"] = "#f1f5f9";
                        txtGridDays.Style["color"] = "#64748b";
                        txtGridDays.Style["cursor"] = "not-allowed";
                    }
                }
            }
        }
    }

    private void UpdateCartTotal()
    {
        decimal cartTotal = 0;
        decimal cartBaseFeeTotal = 0;
        decimal cartGstTotal = 0;
        DataTable dt = CartDataTable;
        foreach (DataRow row in dt.Rows)
        {
            cartTotal += Convert.ToDecimal(row["NetTotal"]);
            cartBaseFeeTotal += Convert.ToDecimal(row["BaseFee"]);
            if (row.Table.Columns.Contains("GSTAmount") && row["GSTAmount"] != DBNull.Value)
            {
                cartGstTotal += Convert.ToDecimal(row["GSTAmount"]);
            }
        }

        if (lblGridAmount != null) lblGridAmount.Text = cartBaseFeeTotal.ToString("N0");
        if (lblGridGST != null) lblGridGST.Text = cartGstTotal.ToString("N2");
        if (lblGridNet != null) lblGridNet.Text = cartTotal.ToString("N0");

        if (lblCartSummary != null) lblCartSummary.Text = dt.Rows.Count + " Items | Total: PKR " + cartTotal.ToString("N0");

        decimal manualDiscount = 0;
        decimal.TryParse(txtManualDiscount.Text, out manualDiscount);

        decimal bankDiscountPercent = 0;
        if (txtBankDiscountPercent != null && !string.IsNullOrEmpty(txtBankDiscountPercent.Text))
        {
            string cleanPercent = txtBankDiscountPercent.Text.Replace("%", "").Trim();
            decimal.TryParse(cleanPercent, out bankDiscountPercent);
        }

        decimal bankDiscount = 0;
        if (ddlPaymentMode.SelectedValue != "Cash" && bankDiscountPercent > 0)
        {
            // Dynamically verify department matching against cart items
            bool deptMatches = true;
            if (ViewState["CurrentOffer_DeptName"] != null)
            {
                string offerDepts = ViewState["CurrentOffer_DeptName"].ToString().Trim();
                if (!offerDepts.Equals("All Departments", StringComparison.OrdinalIgnoreCase) && !offerDepts.Equals("All", StringComparison.OrdinalIgnoreCase) && !string.IsNullOrEmpty(offerDepts))
                {
                    bool anyMatch = false;
                    string[] allowedList = offerDepts.Split(new char[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
                    foreach (DataRow cr in dt.Rows)
                    {
                        string itemDept = cr.Table.Columns.Contains("DepartmentName") && cr["DepartmentName"] != DBNull.Value ? cr["DepartmentName"].ToString().Trim() : "";
                        foreach (string ad in allowedList)
                        {
                            if (!string.IsNullOrEmpty(itemDept) && (itemDept.IndexOf(ad.Trim(), StringComparison.OrdinalIgnoreCase) >= 0 || ad.Trim().IndexOf(itemDept, StringComparison.OrdinalIgnoreCase) >= 0))
                            {
                                anyMatch = true;
                                break;
                            }
                        }
                        if (anyMatch) break;
                    }
                    if (!anyMatch && dt.Rows.Count > 0)
                    {
                        deptMatches = false;
                    }
                }
            }

            if (deptMatches && (ViewState["CurrentOffer_IsApplicable"] == null || (bool)ViewState["CurrentOffer_IsApplicable"]))
            {
                decimal minBill = ViewState["CurrentOffer_MinBill"] != null ? Convert.ToDecimal(ViewState["CurrentOffer_MinBill"]) : 0;
                decimal maxDisc = ViewState["CurrentOffer_MaxDiscount"] != null ? Convert.ToDecimal(ViewState["CurrentOffer_MaxDiscount"]) : 0;

                if (minBill > 0 && cartTotal < minBill)
                {
                    bankDiscount = 0;
                }
                else
                {
                    bankDiscount = cartTotal * (bankDiscountPercent / 100m);
                    if (maxDisc > 0 && bankDiscount > maxDisc)
                    {
                        bankDiscount = maxDisc;
                    }
                }
            }
            else
            {
                bankDiscount = 0;
            }
        }

        if (txtBankDiscountDisplay != null)
        {
            txtBankDiscountDisplay.Text = bankDiscount.ToString("0.00");
        }
        if (divBankDiscountAmount != null)
        {
            divBankDiscountAmount.Visible = (bankDiscount > 0);
        }

        decimal finalNetPayable = cartTotal - manualDiscount - bankDiscount;
        if (finalNetPayable < 0) finalNetPayable = 0;

        txtNetTotalDisplay.Text = Math.Round(finalNetPayable).ToString("0");
        txtAmountPaid.Text = Math.Round(finalNetPayable).ToString("0");
    }

    protected void txtManualDiscount_TextChanged(object sender, EventArgs e)
    {
        UpdateCartTotal();
    }

    protected void ddlBankCard_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlBankCard.SelectedValue != "0" && !string.IsNullOrEmpty(ddlBankCard.SelectedValue))
        {
            int offerId = 0;
            if (int.TryParse(ddlBankCard.SelectedValue, out offerId))
            {
                ApplyCardOfferById(offerId);
            }
        }
        else
        {
            txtPaymentCardNo.Text = "";
            txtCardType.Text = "";
            txtBankDiscountPercent.Text = "0%";
            if (divCardType != null) divCardType.Visible = false;
            if (divBankDiscountPercent != null) divBankDiscountPercent.Visible = false;
            if (divCardOfferInfo != null) divCardOfferInfo.Visible = false;
            UpdateCartTotal();
        }
    }

    protected void btnGenerateReceipt_Click(object sender, EventArgs e)
    {
        if (ddlCustomerType.SelectedValue == "Member" && (ddlMemberNames.SelectedValue == "0" || string.IsNullOrEmpty(ddlMemberNames.SelectedValue)))
        {
            ShowMessage("Please select a Member from the dropdown.", true);
            return;
        }

        if (ddlCustomerType.SelectedValue == "Guest" || ddlCustomerType.SelectedValue == "Guest Room")
        {
            if (string.IsNullOrWhiteSpace(txtReservationNo.Text))
            {
                ShowMessage("Please enter Reservation No.", true);
                return;
            }

            try
            {
                string guestRoomConn = ConfigurationManager.ConnectionStrings["GuestRoomConnString"] != null ? ConfigurationManager.ConnectionStrings["GuestRoomConnString"].ConnectionString : connString.Replace("SportsModuleDB", "GuestRoom");
                using (SqlConnection con = new SqlConnection(guestRoomConn))
                {
                    string query = @"SELECT TOP 1 a.AllocatedDate, a.CheckOutDate, a.ActualCheckOutDate, a.RoomNo,
       ISNULL(r.GuestName,'') AS GuestName, ISNULL(r.MembershipNo,'') AS MembershipNo
FROM RoomAllocations a INNER JOIN RoomReservations r ON a.ReservationNo=r.ReservationNo
WHERE (LTRIM(RTRIM(a.RoomNo))=@ResNo OR LTRIM(RTRIM(a.ReservationNo))=@ResNo
       OR a.RoomNo LIKE '%'+@ResNo+'%')
ORDER BY a.AllocationID DESC";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@ResNo", txtReservationNo.Text.Trim());
                        con.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                DateTime? checkOutDate = reader["CheckOutDate"] != DBNull.Value ? Convert.ToDateTime(reader["CheckOutDate"]).Date : (DateTime?)null;

                                // OCCUPIED: ActualCheckOutDate IS NULL AND (CheckOutDate IS NULL OR CheckOutDate >= Today)
                                bool isOccupied = (reader["ActualCheckOutDate"] == DBNull.Value)
                                               && (!checkOutDate.HasValue || checkOutDate.Value >= DateTime.Today);

                                if (!isOccupied)
                                {
                                    string gName = reader["GuestName"] != DBNull.Value ? reader["GuestName"].ToString() : txtCustomerName.Text;
                                    string rNo = reader["RoomNo"] != DBNull.Value ? reader["RoomNo"].ToString() : "";
                                    string display = !string.IsNullOrEmpty(gName)
                                        ? gName + (!string.IsNullOrEmpty(rNo) ? " (Room " + rNo + ")" : "")
                                        : "Guest";
                                    ShowMessage(display + " - Room is Checked Out or Vacant. Slip generation is not allowed. Please contact relevant department.", true);
                                    return;
                                }

                                // Occupied: look up memberID if needed
                                string membershipNo = reader["MembershipNo"].ToString();
                                if (!string.IsNullOrEmpty(membershipNo) && string.IsNullOrEmpty(hfMemberID.Value))
                                    LookupMemberID(membershipNo);
                            }
                            else
                            {
                                ShowMessage("Room No or Reservation No not found. Room may be Vacant. Please contact relevant department.", true);
                                return;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error validating Guest: " + ex.Message, true);
                return;
            }
        }
        else if (ddlCustomerType.SelectedValue == "Affiliated Member")
        {
            if (string.IsNullOrWhiteSpace(txtCardNo.Text))
            {
                ShowMessage("Please enter Card No / Introductory No.", true);
                return;
            }

            try
            {
                string memberShipConn = ConfigurationManager.ConnectionStrings["MemberShipConnString"] != null ? ConfigurationManager.ConnectionStrings["MemberShipConnString"].ConnectionString : connString.Replace("SportsModuleDB", "MemberShip");
                using (SqlConnection con = new SqlConnection(memberShipConn))
                {
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT MemberName, DateTo FROM IncomingClubMembers WHERE IntroductoryNo = @IntroNo", con))
                    {
                        cmd.Parameters.AddWithValue("@IntroNo", txtCardNo.Text.Trim());
                        con.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string affName = reader["MemberName"] != DBNull.Value ? reader["MemberName"].ToString() : "";

                                DateTime? dateTo = null;
                                if (reader["DateTo"] != DBNull.Value)
                                {
                                    DateTime dtVal;
                                    if (DateTime.TryParse(reader["DateTo"].ToString(), out dtVal))
                                        dateTo = dtVal.Date;
                                }

                                if (dateTo.HasValue && dateTo.Value < DateTime.Today)
                                {
                                    string display = !string.IsNullOrEmpty(affName) ? affName : "Affiliated Member";
                                    string expStr = dateTo.Value.ToString("dd/MM/yyyy");
                                    ShowMessage(display + " - Introductory Card expired on " + expStr + ". Slip generation is not allowed.", true);
                                    return;
                                }
                            }
                            else
                            {
                                ShowMessage("Affiliated Member not found with this Introductory No.", true);
                                return;
                            }
                        }
                    }
                }
            }
            catch { }
        }

        if (string.IsNullOrWhiteSpace(txtCustomerName.Text))
        {
            if (txtGuestNameDisplay != null && !string.IsNullOrWhiteSpace(txtGuestNameDisplay.Text))
            {
                txtCustomerName.Text = txtGuestNameDisplay.Text;
            }
            else if (txtAffiliatedNameDisplay != null && !string.IsNullOrWhiteSpace(txtAffiliatedNameDisplay.Text))
            {
                txtCustomerName.Text = txtAffiliatedNameDisplay.Text;
            }
        }

        if (string.IsNullOrWhiteSpace(txtCustomerName.Text))
        {
            ShowMessage("Customer Name is required.", true);
            return;
        }

        if (CartDataTable.Rows.Count == 0)
        {
            ShowMessage("Cart is empty. Please add items to the cart.", true);
            return;
        }

        // 1. Credit Card Offer Validations (Valid To, Valid From, Valid Weekday, Allowed Departments)
        if (ddlPaymentMode.SelectedValue == "Credit Card" || (!string.IsNullOrEmpty(txtBankDiscountPercent.Text) && txtBankDiscountPercent.Text != "0%"))
        {
            if (ViewState["CurrentOffer_ValidTo"] != null && ViewState["CurrentOffer_ValidTo"] != DBNull.Value)
            {
                DateTime validTo = Convert.ToDateTime(ViewState["CurrentOffer_ValidTo"]).Date;
                if (DateTime.Today > validTo)
                {
                    ShowMessage("The selected credit card offer expired on " + validTo.ToString("dd-MMM-yyyy") + ". Transaction cannot be processed.", true);
                    return;
                }
            }

            if (ViewState["CurrentOffer_ValidFrom"] != null && ViewState["CurrentOffer_ValidFrom"] != DBNull.Value)
            {
                DateTime validFrom = Convert.ToDateTime(ViewState["CurrentOffer_ValidFrom"]).Date;
                if (DateTime.Today < validFrom)
                {
                    ShowMessage("The selected credit card offer is not active yet (Starts on " + validFrom.ToString("dd-MMM-yyyy") + "). Transaction cannot be processed.", true);
                    return;
                }
            }

            if (ViewState["CurrentOffer_ValidWeekday"] != null)
            {
                int validWeekday = Convert.ToInt32(ViewState["CurrentOffer_ValidWeekday"]);
                if (validWeekday != 0)
                {
                    int currentDay = (int)DateTime.Today.DayOfWeek == 0 ? 7 : (int)DateTime.Today.DayOfWeek;
                    if (validWeekday != currentDay)
                    {
                        string dayName = GetWeekdayName(validWeekday);
                        string todayName = DateTime.Today.DayOfWeek.ToString();
                        ShowMessage("The selected credit card offer is ONLY valid on " + dayName + " (Today is " + todayName + "). Transaction cannot be processed.", true);
                        return;
                    }
                }
            }

            if (ViewState["CurrentOffer_DeptName"] != null && !string.IsNullOrWhiteSpace(ViewState["CurrentOffer_DeptName"].ToString()))
            {
                string allowedDepts = ViewState["CurrentOffer_DeptName"].ToString().Trim();
                if (!allowedDepts.Equals("All Departments", StringComparison.OrdinalIgnoreCase) && !allowedDepts.Equals("All", StringComparison.OrdinalIgnoreCase))
                {
                    string[] allowedList = allowedDepts.Split(new char[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
                    bool deptMatch = false;
                    foreach (DataRow cr in CartDataTable.Rows)
                    {
                        string itemDept = cr.Table.Columns.Contains("DepartmentName") && cr["DepartmentName"] != DBNull.Value ? cr["DepartmentName"].ToString().Trim() : "";
                        foreach (string ad in allowedList)
                        {
                            if (!string.IsNullOrEmpty(itemDept) && itemDept.IndexOf(ad.Trim(), StringComparison.OrdinalIgnoreCase) >= 0)
                            {
                                deptMatch = true;
                                break;
                            }
                        }
                        if (deptMatch) break;
                    }
                    if (!deptMatch)
                    {
                        ShowMessage("The selected credit card offer is only valid for: " + allowedDepts + ". Cart items do not match this offer.", true);
                        return;
                    }
                }
            }

        }

        // Setup and Open Manual Card Slip & Register Entry Modal for all modes (Credit Card, Cash, Online Payment)
        lblModalChargeAmount.Text = "PKR " + txtNetTotalDisplay.Text;
        lblModalSlipCheckResult.Visible = false;

        // Prefill slip if user entered it on the main page
        if (!string.IsNullOrWhiteSpace(txtReferenceID.Text) && string.IsNullOrWhiteSpace(txtManualRegisterNo.Text))
        {
            txtManualRegisterNo.Text = txtReferenceID.Text.Trim();
        }
        else if (string.IsNullOrWhiteSpace(txtManualRegisterNo.Text))
        {
            txtManualRegisterNo.Text = "";
        }

        if (ddlPaymentMode.SelectedValue == "Credit Card")
        {
            if (lblModalTitle != null) lblModalTitle.Text = "Manual Card Slip & Register Entry";
            if (lblModalModeHeading != null) lblModalModeHeading.InnerText = "Card / Offer:";
            lblModalCardOfferName.Text = (!string.IsNullOrEmpty(txtCardType.Text) ? txtCardType.Text : "Credit Card")
                + (!string.IsNullOrEmpty(txtBankDiscountPercent.Text) && txtBankDiscountPercent.Text != "0%" ? " (" + txtBankDiscountPercent.Text + ")" : "");
            txtModalCardNoDigits.Text = txtPaymentCardNo.Text;
            if (divModalCardNo != null) divModalCardNo.Visible = true;
            if (lblModalTerminalRef != null) lblModalTerminalRef.InnerText = "POS Terminal / Bank Machine Ref (Optional):";
            txtModalTerminalRef.Text = txtReferenceID.Text;
            if (divModalTerminalRef != null) divModalTerminalRef.Visible = true;
        }
        else if (ddlPaymentMode.SelectedValue == "Cash")
        {
            if (lblModalTitle != null) lblModalTitle.Text = "Manual Card Slip & Register Entry";
            if (lblModalModeHeading != null) lblModalModeHeading.InnerText = "Payment Mode:";
            lblModalCardOfferName.Text = "On Cash (Cash Payment)";
            txtModalCardNoDigits.Text = "";
            if (divModalCardNo != null) divModalCardNo.Visible = false;
            if (lblModalTerminalRef != null) lblModalTerminalRef.InnerText = "Ref / Manual Slip Notes (Optional):";
            txtModalTerminalRef.Text = txtReferenceID.Text;
            if (divModalTerminalRef != null) divModalTerminalRef.Visible = true;
        }
        else // Online Payment / On Account
        {
            if (lblModalTitle != null) lblModalTitle.Text = "Manual Card Slip & Register Entry (On Account)";
            if (lblModalModeHeading != null) lblModalModeHeading.InnerText = "Payment Mode:";
            lblModalCardOfferName.Text = "On Account / Online";
            txtModalCardNoDigits.Text = "";
            if (divModalCardNo != null) divModalCardNo.Visible = false;
            if (lblModalTerminalRef != null) lblModalTerminalRef.InnerText = "Reference ID / Notes (Optional):";
            txtModalTerminalRef.Text = txtReferenceID.Text;
            if (divModalTerminalRef != null) divModalTerminalRef.Visible = true;
        }

        pnlManualCardModal.Visible = true;
        return;
    }

    protected void btnQuickVerifySlip_Click(object sender, EventArgs e)
    {
        string slip = txtQuickVerifySlip.Text.Trim();
        if (string.IsNullOrEmpty(slip))
        {
            ShowMessage("Please enter a Slip / Register Number to verify.", true);
            return;
        }

        int curYear = DateTime.Today.Year;
        int curMonth = DateTime.Today.Month;
        string curMonthName = DateTime.Today.ToString("MMMM yyyy");

        DataTable dt = GetManualReceiptDetails(slip, curYear, curMonth);
        pnlSlipVerificationResult.Visible = true;

        if (dt.Rows.Count > 0)
        {
            DataRow dr = dt.Rows[0];
            string rNo = dr["ReceiptNo"].ToString();
            string cName = dr["CustomerName"].ToString();
            DateTime tDate = Convert.ToDateTime(dr["TransactionDate"]);
            string pMode = dr["PaymentMode"].ToString();
            decimal amt = dr["Amount"] != DBNull.Value ? Convert.ToDecimal(dr["Amount"]) : 0;
            string status = dr["Status"].ToString();

            divSlipResultCard.Style["background"] = "#fef2f2";
            divSlipResultCard.Style["border"] = "1.5px solid #ef4444";
            divSlipResultCard.Style["color"] = "#991b1b";
            iconSlipResult.Attributes["class"] = "fas fa-times-circle";
            iconSlipResult.Style["color"] = "#dc2626";

            divSlipResultTitle.InnerHtml = "<span style='color:#dc2626;'>ALREADY USED IN " + curMonthName.ToUpper() + ":</span> Manual Slip # <u>" + HttpUtility.HtmlEncode(slip) + "</u> has ALREADY been entered!";
            divSlipResultDetails.InnerHtml = "<b>Receipt #:</b> " + rNo + " &nbsp;|&nbsp; <b>Date:</b> " + tDate.ToString("dd-MMM-yyyy hh:mm tt") + " &nbsp;|&nbsp; <b>Customer:</b> " + HttpUtility.HtmlEncode(cName) + " &nbsp;|&nbsp; <b>Amount:</b> PKR " + amt.ToString("N0") + " (" + pMode + " - " + status + ")";

            ShowMessage("Manual Slip / Register No '" + slip + "' has ALREADY been used for receipt " + rNo + " in " + curMonthName + "!", true);
        }
        else
        {
            divSlipResultCard.Style["background"] = "#f0fdf4";
            divSlipResultCard.Style["border"] = "1.5px solid #22c55e";
            divSlipResultCard.Style["color"] = "#166534";
            iconSlipResult.Attributes["class"] = "fas fa-check-circle";
            iconSlipResult.Style["color"] = "#16a34a";

            divSlipResultTitle.InnerHtml = "<span style='color:#16a34a;'>AVAILABLE / VALID FOR " + curMonthName.ToUpper() + ":</span> Manual Slip # <u>" + HttpUtility.HtmlEncode(slip) + "</u> is Available!";
            divSlipResultDetails.InnerHtml = "This physical register / slip number has not been used in " + curMonthName + ". You can safely record this slip.";

            ShowMessage("Manual Slip / Register No '" + slip + "' is AVAILABLE and valid for " + curMonthName + ".", false);
        }
    }

    protected void btnCloseSlipResult_Click(object sender, EventArgs e)
    {
        pnlSlipVerificationResult.Visible = false;
    }

    protected void btnModalVerifySlip_Click(object sender, EventArgs e)
    {
        string slip = txtManualRegisterNo.Text.Trim();
        if (string.IsNullOrEmpty(slip))
        {
            lblModalSlipCheckResult.Visible = true;
            lblModalSlipCheckResult.Text = "<span style='color:#dc2626;'><i class='fas fa-exclamation-triangle'></i> Please enter a slip number first.</span>";
            pnlManualCardModal.Visible = true;
            return;
        }

        int curYear = DateTime.Today.Year;
        int curMonth = DateTime.Today.Month;
        string curMonthName = DateTime.Today.ToString("MMMM yyyy");

        DataTable dt = GetManualReceiptDetails(slip, curYear, curMonth);
        lblModalSlipCheckResult.Visible = true;

        if (dt.Rows.Count > 0)
        {
            DataRow dr = dt.Rows[0];
            string rNo = dr["ReceiptNo"].ToString();
            string cName = dr["CustomerName"].ToString();
            lblModalSlipCheckResult.Text = "<span style='color:#dc2626;'><i class='fas fa-times-circle'></i> ALREADY USED in " + curMonthName + " for " + rNo + " (" + HttpUtility.HtmlEncode(cName) + ")! Please enter a different Slip No.</span>";
        }
        else
        {
            lblModalSlipCheckResult.Text = "<span style='color:#16a34a;'><i class='fas fa-check-circle'></i> Slip #" + HttpUtility.HtmlEncode(slip) + " is AVAILABLE & VALID for " + curMonthName + ".</span>";
        }
        pnlManualCardModal.Visible = true;
    }

    private DataTable GetManualReceiptDetails(string slipNo, int year = 0, int month = 0)
    {
        DataTable dt = new DataTable();
        if (string.IsNullOrWhiteSpace(slipNo)) return dt;
        if (year <= 0) year = DateTime.Today.Year;
        if (month <= 0) month = DateTime.Today.Month;

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string sql = @"SELECT TOP 1 t.TransactionID, 'POS-' + RIGHT('00000' + CAST(t.TransactionID AS VARCHAR(10)), 5) AS ReceiptNo,
                                      t.TransactionDate, t.CustomerType, t.CustomerName, t.PaymentMode, t.ManualRegisterNo, ISNULL(t.NetFee, t.Amount) AS Amount,
                                      CASE WHEN ISNULL((SELECT SUM(CreditAmount) FROM LedgerEntries WHERE RefType = 'POS_Pay' AND RefID = t.TransactionID), 0) > 0 THEN 'Paid' ELSE 'Unpaid' END AS Status
                               FROM POSTransactions t
                               WHERE UPPER(LTRIM(RTRIM(t.ManualRegisterNo))) = @RegNo
                                 AND YEAR(t.TransactionDate) = @Year
                                 AND MONTH(t.TransactionDate) = @Month
                               ORDER BY t.TransactionID DESC";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@RegNo", slipNo.Trim().ToUpper());
                    cmd.Parameters.AddWithValue("@Year", year);
                    cmd.Parameters.AddWithValue("@Month", month);
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

    protected void btnConfirmSaveReceipt_Click(object sender, EventArgs e)
    {
        string manualRegNo = txtManualRegisterNo.Text.Trim();
        if (string.IsNullOrEmpty(manualRegNo))
        {
            ShowMessage("Please enter the Manual Slip / Register Number.", true);
            pnlManualCardModal.Visible = true;
            return;
        }

        int curYear = DateTime.Today.Year;
        int curMonth = DateTime.Today.Month;
        string curMonthName = DateTime.Today.ToString("MMMM yyyy");

        // Duplicate Check in POSTransactions scoped month-wise
        bool isDuplicate = false;
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string sqlCheck = @"SELECT COUNT(1) FROM POSTransactions 
                                   WHERE UPPER(LTRIM(RTRIM(ManualRegisterNo))) = @RegNo
                                     AND YEAR(TransactionDate) = @Year
                                     AND MONTH(TransactionDate) = @Month";
                using (SqlCommand cmd = new SqlCommand(sqlCheck, con))
                {
                    cmd.Parameters.AddWithValue("@RegNo", manualRegNo.ToUpper());
                    cmd.Parameters.AddWithValue("@Year", curYear);
                    cmd.Parameters.AddWithValue("@Month", curMonth);
                    con.Open();
                    int count = Convert.ToInt32(cmd.ExecuteScalar());
                    if (count > 0)
                    {
                        isDuplicate = true;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error checking duplicate register number: " + ex.Message, true);
            pnlManualCardModal.Visible = true;
            return;
        }

        if (isDuplicate)
        {
            ShowMessage("Receipt / Register No '" + manualRegNo + "' has ALREADY been entered in " + curMonthName + "! Please enter a unique Register / Slip No.", true);
            lblModalSlipCheckResult.Visible = true;
            lblModalSlipCheckResult.Text = "<span style='color:#dc2626;'><i class='fas fa-times-circle'></i> Receipt / Register No '" + HttpUtility.HtmlEncode(manualRegNo) + "' has ALREADY been entered in " + curMonthName + "!</span>";
            pnlManualCardModal.Visible = true;
            return;
        }

        pnlManualCardModal.Visible = false;
        ExecuteSaveTransaction(manualRegNo);
    }

    protected void btnCloseManualCardModal_Click(object sender, EventArgs e)
    {
        pnlManualCardModal.Visible = false;
    }

    private void ExecuteSaveTransaction(string manualRegisterNo)
    {
        try
        {
            int newTransactionId = 0;
            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();

                decimal cartTotalNet = 0;
                foreach (DataRow cr in CartDataTable.Rows)
                {
                    cartTotalNet += Convert.ToDecimal(cr["NetTotal"]);
                }

                decimal totalBankDisc = 0;
                if (txtBankDiscountDisplay != null && !string.IsNullOrEmpty(txtBankDiscountDisplay.Text))
                {
                    decimal.TryParse(txtBankDiscountDisplay.Text, out totalBankDisc);
                }

                decimal totalManualDisc = 0;
                decimal.TryParse(txtManualDiscount.Text, out totalManualDisc);

                decimal totalAmountPaid = 0;
                if (!string.IsNullOrWhiteSpace(txtAmountPaid.Text))
                {
                    decimal.TryParse(txtAmountPaid.Text, out totalAmountPaid);
                }

                decimal allocatedBankDisc = 0;
                decimal allocatedManualDisc = 0;
                decimal allocatedAmountPaid = 0;
                int rowCount = CartDataTable.Rows.Count;
                int rowIndex = 0;

                foreach (DataRow cartRow in CartDataTable.Rows)
                {
                    rowIndex++;
                    int subId = Convert.ToInt32(cartRow["SubscriptionID"]);
                    decimal fee = Convert.ToDecimal(cartRow["BaseFee"]);
                    int numberOfDays = Convert.ToInt32(cartRow["NumberOfDays"]);
                    DateTime validFrom = Convert.ToDateTime(cartRow["ValidFrom"]);
                    DateTime validTo = Convert.ToDateTime(cartRow["ValidTo"]);
                    decimal rowNetTotal = Convert.ToDecimal(cartRow["NetTotal"]);

                    int? lockerId = null;
                    if (cartRow["LockerID"] != DBNull.Value && Convert.ToInt32(cartRow["LockerID"]) > 0)
                    {
                        lockerId = Convert.ToInt32(cartRow["LockerID"]);
                    }
                    decimal lockerFee = Convert.ToDecimal(cartRow["LockerFee"]);

                    // Proportional distribution for multi-item cart
                    decimal rowBankDiscount = 0;
                    decimal rowManualDiscount = 0;
                    decimal rowAmountPaid = 0;

                    if (rowIndex == rowCount)
                    {
                        rowBankDiscount = totalBankDisc - allocatedBankDisc;
                        rowManualDiscount = totalManualDisc - allocatedManualDisc;
                        rowAmountPaid = totalAmountPaid - allocatedAmountPaid;
                    }
                    else
                    {
                        decimal ratio = cartTotalNet > 0 ? (rowNetTotal / cartTotalNet) : (1.0m / rowCount);
                        rowBankDiscount = Math.Round(totalBankDisc * ratio, 2);
                        rowManualDiscount = Math.Round(totalManualDisc * ratio, 2);
                        rowAmountPaid = Math.Round(totalAmountPaid * ratio, 2);

                        allocatedBankDisc += rowBankDiscount;
                        allocatedManualDisc += rowManualDiscount;
                        allocatedAmountPaid += rowAmountPaid;
                    }

                    using (SqlCommand cmd = new SqlCommand("sp_InsertPOSTransaction", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@CustomerType", ddlCustomerType.SelectedValue);

                        if (ddlCustomerType.SelectedValue == "Member" && ddlMemberNames.SelectedValue != "0")
                        {
                            string[] memberParts = ddlMemberNames.SelectedValue.Split('|');
                            cmd.Parameters.AddWithValue("@MemberID", memberParts[0]);

                            string rel = memberParts[3];
                            if (rel != "Self")
                            {
                                cmd.Parameters.AddWithValue("@DependentMemberNo", memberParts[1]);
                                cmd.Parameters.AddWithValue("@DependentName", memberParts[2]);
                                cmd.Parameters.AddWithValue("@DependentRelation", rel);
                            }
                            else
                            {
                                cmd.Parameters.AddWithValue("@DependentMemberNo", DBNull.Value);
                                cmd.Parameters.AddWithValue("@DependentName", DBNull.Value);
                                cmd.Parameters.AddWithValue("@DependentRelation", "Main Member");
                            }
                        }
                        else if (ddlCustomerType.SelectedValue == "Affiliated Member")
                        {
                            cmd.Parameters.AddWithValue("@MemberID", DBNull.Value);
                            cmd.Parameters.AddWithValue("@DependentMemberNo", string.IsNullOrWhiteSpace(txtCardNo.Text) ? DBNull.Value : (object)txtCardNo.Text.Trim());
                            cmd.Parameters.AddWithValue("@DependentName", DBNull.Value);
                            cmd.Parameters.AddWithValue("@DependentRelation", "Affiliated Card");
                        }
                        else if (ddlCustomerType.SelectedValue == "Guest" || ddlCustomerType.SelectedValue == "Guest Room")
                        {
                            cmd.Parameters.AddWithValue("@MemberID", string.IsNullOrEmpty(hfMemberID.Value) ? DBNull.Value : (object)hfMemberID.Value);
                            cmd.Parameters.AddWithValue("@DependentMemberNo", string.IsNullOrEmpty(txtReservationNo.Text) ? DBNull.Value : (object)txtReservationNo.Text.Trim());
                            cmd.Parameters.AddWithValue("@DependentName", DBNull.Value);
                            cmd.Parameters.AddWithValue("@DependentRelation", "Guest");
                        }
                        else
                        {
                            cmd.Parameters.AddWithValue("@MemberID", DBNull.Value);
                            cmd.Parameters.AddWithValue("@DependentMemberNo", DBNull.Value);
                            cmd.Parameters.AddWithValue("@DependentName", DBNull.Value);
                            cmd.Parameters.AddWithValue("@DependentRelation", DBNull.Value);
                        }

                        cmd.Parameters.AddWithValue("@CustomerName", txtCustomerName.Text.Trim());
                        cmd.Parameters.AddWithValue("@SubscriptionID", subId);
                        cmd.Parameters.AddWithValue("@Amount", fee);

                        cmd.Parameters.AddWithValue("@ValidFrom", validFrom);
                        cmd.Parameters.AddWithValue("@ValidTo", validTo);
                        cmd.Parameters.AddWithValue("@NumberOfDays", numberOfDays);

                        cmd.Parameters.AddWithValue("@PolicyDiscount", cartRow["PolicyDiscount"]);
                        cmd.Parameters.AddWithValue("@GSTAmount", cartRow["GSTAmount"]);
                        cmd.Parameters.AddWithValue("@ManualDiscount", rowManualDiscount);
                        cmd.Parameters.AddWithValue("@NetFee", cartRow["NetTotal"]);

                        cmd.Parameters.AddWithValue("@LockerID", lockerId.HasValue ? (object)lockerId.Value : DBNull.Value);
                        cmd.Parameters.AddWithValue("@LockerFee", lockerFee);

                        cmd.Parameters.AddWithValue("@AmountPaid", rowAmountPaid);

                        string remarks = string.IsNullOrWhiteSpace(txtPayDesc.Text) ? "POS Payment Received" : txtPayDesc.Text.Trim();
                        cmd.Parameters.AddWithValue("@Remarks", remarks);

                        cmd.Parameters.AddWithValue("@PaymentMode", ddlPaymentMode.SelectedValue);

                        int? bankId = null;
                        if (ddlBankCard.Visible && ddlBankCard.SelectedValue != "0" && !string.IsNullOrEmpty(ddlBankCard.SelectedValue))
                        {
                            bankId = Convert.ToInt32(ddlBankCard.SelectedValue);
                        }
                        cmd.Parameters.AddWithValue("@BankID", bankId.HasValue ? (object)bankId.Value : DBNull.Value);
                        cmd.Parameters.AddWithValue("@BankDiscount", rowBankDiscount);

                        string cardNo = null;
                        string refId = null;
                        if (ddlPaymentMode.SelectedValue == "Credit Card")
                        {
                            refId = !string.IsNullOrEmpty(txtModalTerminalRef.Text) ? txtModalTerminalRef.Text.Trim() : txtReferenceID.Text.Trim();
                            string rawCard = txtPaymentCardNo.Text.Trim();
                            if (rawCard.Length >= 4)
                            {
                                cardNo = new string('*', rawCard.Length - 4) + rawCard.Substring(rawCard.Length - 4);
                            }
                            else if (!string.IsNullOrEmpty(rawCard))
                            {
                                cardNo = "****" + rawCard;
                            }
                        }
                        else
                        {
                            refId = !string.IsNullOrEmpty(txtModalTerminalRef.Text) ? txtModalTerminalRef.Text.Trim() : (!string.IsNullOrEmpty(txtReferenceID.Text) ? txtReferenceID.Text.Trim() : null);
                        }

                        cmd.Parameters.AddWithValue("@CardNo", string.IsNullOrEmpty(cardNo) ? (object)DBNull.Value : cardNo);
                        cmd.Parameters.AddWithValue("@ReferenceID", string.IsNullOrEmpty(refId) ? (object)DBNull.Value : refId);
                        cmd.Parameters.AddWithValue("@ManualRegisterNo", string.IsNullOrEmpty(manualRegisterNo) ? (object)DBNull.Value : manualRegisterNo);

                        object result = cmd.ExecuteScalar();
                        if (result != null)
                        {
                            newTransactionId = Convert.ToInt32(result);
                        }
                    } // End using cmd
                } // End foreach
            } // End using con

            // Show Receipt
            lblRecNo.Text = "POS-" + newTransactionId.ToString("D5");
            if (!string.IsNullOrEmpty(manualRegisterNo))
            {
                divRecManualRegister.Visible = true;
                lblRecManualRegister.Text = manualRegisterNo;
            }
            else
            {
                divRecManualRegister.Visible = false;
            }

            lblRecDate.Text = DateTime.Now.ToString("dd-MMM-yyyy hh:mm tt");
            lblRecType.Text = ddlCustomerType.SelectedValue;

            if (ddlCustomerType.SelectedValue == "Member" && ddlMemberNames.SelectedValue != "0")
            {
                string[] memberParts = ddlMemberNames.SelectedValue.Split('|');
                pnlRecMemberNo.Visible = true;
                lblRecMemberNo.Text = memberParts[1];
            }
            else if (ddlCustomerType.SelectedValue == "Affiliated Member" && !string.IsNullOrWhiteSpace(txtCardNo.Text))
            {
                pnlRecMemberNo.Visible = true;
                lblRecMemberNo.Text = txtCardNo.Text;
            }
            else
            {
                pnlRecMemberNo.Visible = false;
            }

            lblRecName.Text = txtCustomerName.Text;

            // Display Department on Receipt
            List<string> depts = new List<string>();
            foreach (DataRow r in CartDataTable.Rows)
            {
                if (r.Table.Columns.Contains("DepartmentName") && r["DepartmentName"] != DBNull.Value)
                {
                    string d = r["DepartmentName"].ToString().Trim();
                    if (!string.IsNullOrEmpty(d) && !depts.Contains(d))
                        depts.Add(d);
                }
            }
            string allDepts = string.Join(", ", depts);
            if (!string.IsNullOrEmpty(allDepts))
            {
                divRecDept.Visible = true;
                lblRecDepartment.Text = allDepts;
            }
            else
            {
                divRecDept.Visible = false;
            }

            rptReceiptItems.DataSource = CartDataTable;
            rptReceiptItems.DataBind();
            lblRecPaymentMode.Text = ddlPaymentMode.SelectedValue;

            decimal subTotal = 0;
            foreach (DataRow r in CartDataTable.Rows)
            {
                if (r.Table.Columns.Contains("NetTotal") && r["NetTotal"] != DBNull.Value)
                    subTotal += Convert.ToDecimal(r["NetTotal"]);
            }

            decimal bankDisc = 0;
            if (txtBankDiscountDisplay != null && !string.IsNullOrEmpty(txtBankDiscountDisplay.Text))
            {
                decimal.TryParse(txtBankDiscountDisplay.Text, out bankDisc);
            }

            decimal manualDisc = 0;
            decimal.TryParse(txtManualDiscount.Text, out manualDisc);

            decimal totalDiscount = bankDisc + manualDisc;

            decimal parsedAmountPaid = 0;
            decimal.TryParse(txtAmountPaid.Text, out parsedAmountPaid);

            if (totalDiscount > 0)
            {
                divRecSubTotal.Visible = true;
                lblRecSubTotal.Text = "PKR " + subTotal.ToString("N0");
                divRecDiscount.Visible = true;
                string discLabel = "- PKR " + totalDiscount.ToString("N0");
                if (bankDisc > 0 && !string.IsNullOrEmpty(txtBankDiscountPercent.Text) && txtBankDiscountPercent.Text != "0%")
                {
                    discLabel += " (" + txtBankDiscountPercent.Text.Trim() + ")";
                }
                lblRecDiscount.Text = discLabel;
                divRecDiscountDivider.Visible = true;
            }
            else
            {
                divRecSubTotal.Visible = false;
                divRecDiscount.Visible = false;
                divRecDiscountDivider.Visible = false;
            }

            if (parsedAmountPaid > 0)
            {
                lblRecTotal.Text = "PKR " + parsedAmountPaid.ToString("N0");
            }
            else
            {
                lblRecTotal.Text = "<span style='color:var(--danger);'>UNPAID</span>";
            }

            pnlPOSForm.Visible = false;
            pnlReceipt.Visible = true;
            lblMessage.Visible = false;
        }
        catch (Exception ex)
        {
            ShowMessage("Error generating receipt: " + ex.Message, false);
        }
    }

    private string GetWeekdayName(int day)
    {
        switch (day)
        {
            case 1: return "Monday";
            case 2: return "Tuesday";
            case 3: return "Wednesday";
            case 4: return "Thursday";
            case 5: return "Friday";
            case 6: return "Saturday";
            case 7: return "Sunday";
            default: return "All Days";
        }
    }

    protected void btnNewTransaction_Click(object sender, EventArgs e)
    {
        // Clear cart
        CartDataTable.Rows.Clear();
        BindCart();

        // Reset Form
        ddlCustomerType.SelectedIndex = 0;
        ToggleCustomerFields();
        txtMemberSearch.Text = "";
        txtCardNo.Text = "";
        txtItemCode.Text = "";
        ddlDailyPackages.SelectedIndex = 0;
        ddlLocker.SelectedIndex = 0;
        txtLockerFee.Value = "0";
        txtValidFrom.Text = DateTime.Now.ToString("yyyy-MM-dd");
        ddlNumberOfDays.SelectedIndex = 0;
        txtBaseFee.Text = "";
        txtGSTAmount.Text = "";
        txtPolicyDiscount.Text = "";
        txtManualDiscount.Text = "0";
        txtNetTotal.Text = "";
        txtAmountPaid.Text = "";
        if (rdoPaymentMode != null)
        {
            foreach (ListItem item in rdoPaymentMode.Items)
            {
                item.Enabled = true;
            }
            if (rdoPaymentMode.Items.Count > 0) rdoPaymentMode.SelectedIndex = 0;
        }
        ddlPaymentMode.SelectedIndex = 0;
        ddlPaymentMode_SelectedIndexChanged(sender, e);
        divCardNoPayment.Visible = false;
        divRefID.Visible = true;
        txtPaymentCardNo.Text = "";
        txtReferenceID.Text = "";
        txtManualRegisterNo.Text = "";
        txtModalTerminalRef.Text = "";
        lblModalSlipCheckResult.Visible = false;
        pnlManualCardModal.Visible = false;
        txtReservationNo.Text = "";

        ddlSports.SelectedIndex = 0;
        LoadDailyPackages();

        pnlPOSForm.Visible = true;
        pnlReceipt.Visible = false;
    }

    private void ShowMessage(string msg, bool isError)
    {
        lblMessage.Visible = true;
        lblMessage.Text = msg;
        if (isError)
        {
            lblMessage.Style["background-color"] = "#f8d7da";
            lblMessage.Style["color"] = "#721c24";
            lblMessage.Style["border"] = "1px solid #f5c6cb";
        }
        else
        {
            lblMessage.Style["background-color"] = "#d4edda";
            lblMessage.Style["color"] = "#155724";
            lblMessage.Style["border"] = "1px solid #c3e6cb";
        }

        string cleanMsg = HttpUtility.JavaScriptStringEncode(msg);
        string script = string.Format("showToastrMessage('{0}', {1});", cleanMsg, isError ? "true" : "false");
        ScriptManager.RegisterStartupScript(this, GetType(), "ToastrAlert_" + Guid.NewGuid().ToString("N"), script, true);
    }

    /// <summary>
    /// Shows a persistent blocking modal for expired subscriptions (Guest Room / Affiliated Member).
    /// Staff must enter Remarks and click Acknowledge before the modal dismisses.
    /// </summary>
    private void ShowExpiredSubscriptionAlert(string memberName, string memberType)
    {
        // Also show the page-level label banner as a fallback indicator
        string labelMsg = memberName + " - Subscription expired. Please remove Face ID from the machine.";
        lblMessage.Visible = true;
        lblMessage.Text = labelMsg;
        lblMessage.Style["background-color"] = "#f8d7da";
        lblMessage.Style["color"] = "#721c24";
        lblMessage.Style["border"] = "1px solid #f5c6cb";

        // Fire the persistent client-side modal
        string safeName = HttpUtility.JavaScriptStringEncode(memberName);
        string safeType = HttpUtility.JavaScriptStringEncode(memberType);
        string script = string.Format("showExpiredSubscriptionAlert('{0}', '{1}');", safeName, safeType);
        ScriptManager.RegisterStartupScript(this, GetType(), "ExpiredAlert_" + Guid.NewGuid().ToString("N"), script, true);
    }

    private string GetRelationFromMemberNo(string memberNo)
    {
        if (string.IsNullOrEmpty(memberNo)) return "Self";
        string upper = memberNo.ToUpper();
        int dashIndex = upper.LastIndexOf('-');
        if (dashIndex >= 0 && dashIndex < upper.Length - 1)
        {
            string suffix = upper.Substring(dashIndex + 1);
            if (suffix.StartsWith("W")) return "Spouse";
            if (suffix.StartsWith("H")) return "Husband";
            if (suffix.StartsWith("S")) return "Son";
            if (suffix.StartsWith("D")) return "Daughter";
        }
        return "Self";
    }

    protected void btnTabNew_Click(object sender, EventArgs e)
    {
        mvDailyPOS.ActiveViewIndex = 0;
        btnTabNew.CssClass = "pos-tab-btn pos-tab-active";
        btnTabHistory.CssClass = "pos-tab-btn pos-tab-inactive";
        btnTabHistory.Style.Clear();
        btnTabNew.Style.Clear();
        lblMessage.Visible = false;
    }

    protected void btnTabHistory_Click(object sender, EventArgs e)
    {
        mvDailyPOS.ActiveViewIndex = 1;
        btnTabHistory.CssClass = "pos-tab-btn pos-tab-active";
        btnTabNew.CssClass = "pos-tab-btn pos-tab-inactive";
        btnTabHistory.Style.Clear();
        btnTabNew.Style.Clear();
        txtFromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        txtToDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        lblMessage.Visible = false;
        LoadHistory();
    }

    protected void btnFilterHistory_Click(object sender, EventArgs e)
    {
        LoadHistory();
    }

    private void LoadHistory()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = @"SELECT t.TransactionID, 'POS-' + RIGHT('00000' + CAST(t.TransactionID AS VARCHAR(10)), 5) AS ReceiptNo, 
                                 t.TransactionDate, t.CustomerType, t.CustomerName, sp.SportName + ' - ' + s.PackageName AS PackageName, 
                                 ISNULL(t.NetFee, t.Amount) AS Fee, 
                                 t.ValidFrom, t.ValidTo,
                                 CASE WHEN ISNULL((SELECT SUM(CreditAmount) FROM LedgerEntries WHERE RefType = 'POS_Pay' AND RefID = t.TransactionID), 0) > 0 THEN 'Paid' ELSE 'Unpaid' END AS Status,
                                 ISNULL(t.PaymentMode, 'Cash') AS PaymentMode,
                                 t.ManualRegisterNo
                                 FROM POSTransactions t
                                 INNER JOIN Subscriptions s ON t.SubscriptionID = s.SubscriptionID
                                 INNER JOIN Sports sp ON s.SportID = sp.SportID
                                 WHERE CAST(t.TransactionDate AS DATE) >= @FromDate AND CAST(t.TransactionDate AS DATE) <= @ToDate";

                if (Session["UserRole"] != null && Session["UserRole"].ToString() == "Operator")
                {
                    List<int> allowedSports = Session["AllowedSports"] as List<int>;
                    if (allowedSports != null && allowedSports.Count > 0)
                    {
                        query += " AND s.SportID IN (" + string.Join(",", allowedSports) + ")";
                    }
                    else
                    {
                        query += " AND s.SportID = -1";
                    }
                }

                if (ddlFilterStatus.SelectedValue != "All")
                {
                    query += " AND (CASE WHEN ISNULL((SELECT SUM(CreditAmount) FROM LedgerEntries WHERE RefType = 'POS_Pay' AND RefID = t.TransactionID), 0) > 0 THEN 'Paid' ELSE 'Unpaid' END) = @Status";
                }

                if (!string.IsNullOrWhiteSpace(txtFilterManualSlip.Text))
                {
                    query += " AND t.ManualRegisterNo LIKE @ManualSlip";
                }

                query += " ORDER BY t.TransactionDate DESC, t.TransactionID DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@FromDate", txtFromDate.Text);
                    cmd.Parameters.AddWithValue("@ToDate", txtToDate.Text);

                    if (ddlFilterStatus.SelectedValue != "All")
                    {
                        cmd.Parameters.AddWithValue("@Status", ddlFilterStatus.SelectedValue);
                    }

                    if (!string.IsNullOrWhiteSpace(txtFilterManualSlip.Text))
                    {
                        cmd.Parameters.AddWithValue("@ManualSlip", "%" + txtFilterManualSlip.Text.Trim() + "%");
                    }

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dtRaw = new DataTable();
                        da.Fill(dtRaw);

                        DataTable dtGrouped = new DataTable();
                        dtGrouped.Columns.Add("TransactionID", typeof(int));
                        dtGrouped.Columns.Add("ReceiptNo", typeof(string));
                        dtGrouped.Columns.Add("ManualRegisterNo", typeof(string));
                        dtGrouped.Columns.Add("TransactionDate", typeof(DateTime));
                        dtGrouped.Columns.Add("CustomerType", typeof(string));
                        dtGrouped.Columns.Add("CustomerName", typeof(string));
                        dtGrouped.Columns.Add("PackageName", typeof(string));
                        dtGrouped.Columns.Add("Fee", typeof(decimal));
                        dtGrouped.Columns.Add("ValidFrom", typeof(DateTime));
                        dtGrouped.Columns.Add("ValidTo", typeof(DateTime));
                        dtGrouped.Columns.Add("Status", typeof(string));
                        dtGrouped.Columns.Add("PaymentMode", typeof(string));

                        foreach (DataRow row in dtRaw.Rows)
                        {
                            int txnId = Convert.ToInt32(row["TransactionID"]);
                            DateTime txnDate = Convert.ToDateTime(row["TransactionDate"]);
                            string custType = row["CustomerType"].ToString();
                            string custName = row["CustomerName"].ToString();
                            string pkgName = row["PackageName"].ToString();
                            decimal fee = row["Fee"] != DBNull.Value ? Convert.ToDecimal(row["Fee"]) : 0;
                            string status = row["Status"].ToString();
                            string payMode = row["PaymentMode"].ToString();
                            string manReg = row["ManualRegisterNo"] != DBNull.Value ? row["ManualRegisterNo"].ToString() : "-";
                            DateTime validFrom = row["ValidFrom"] != DBNull.Value ? Convert.ToDateTime(row["ValidFrom"]) : txnDate;
                            DateTime validTo = row["ValidTo"] != DBNull.Value ? Convert.ToDateTime(row["ValidTo"]) : txnDate;

                            bool merged = false;
                            if (dtGrouped.Rows.Count > 0)
                            {
                                DataRow lastRow = dtGrouped.Rows[dtGrouped.Rows.Count - 1];
                                DateTime lastDate = Convert.ToDateTime(lastRow["TransactionDate"]);
                                string lastCustName = lastRow["CustomerName"].ToString();
                                string lastCustType = lastRow["CustomerType"].ToString();

                                if (lastCustName == custName && lastCustType == custType && Math.Abs((txnDate - lastDate).TotalSeconds) <= 5)
                                {
                                    lastRow["PackageName"] = lastRow["PackageName"].ToString() + ", " + pkgName;
                                    lastRow["Fee"] = Convert.ToDecimal(lastRow["Fee"]) + fee;
                                    if (lastRow["ManualRegisterNo"].ToString() == "-" && manReg != "-")
                                    {
                                        lastRow["ManualRegisterNo"] = manReg;
                                    }
                                    merged = true;
                                }
                            }

                            if (!merged)
                            {
                                DataRow newRow = dtGrouped.NewRow();
                                newRow["TransactionID"] = txnId;
                                newRow["ReceiptNo"] = row["ReceiptNo"].ToString();
                                newRow["ManualRegisterNo"] = manReg;
                                newRow["TransactionDate"] = txnDate;
                                newRow["CustomerType"] = custType;
                                newRow["CustomerName"] = custName;
                                newRow["PackageName"] = pkgName;
                                newRow["Fee"] = fee;
                                newRow["ValidFrom"] = validFrom;
                                newRow["ValidTo"] = validTo;
                                newRow["Status"] = status;
                                newRow["PaymentMode"] = payMode;
                                dtGrouped.Rows.Add(newRow);
                            }
                        }

                        decimal totalCash = 0;
                        decimal totalCard = 0;
                        decimal totalAccount = 0;
                        decimal totalOverall = 0;

                        foreach (DataRow gRow in dtGrouped.Rows)
                        {
                            string status = gRow["Status"].ToString();
                            decimal fee = gRow["Fee"] != DBNull.Value ? Convert.ToDecimal(gRow["Fee"]) : 0;

                            totalOverall += fee;

                            if (status == "Paid")
                            {
                                string payMode = gRow["PaymentMode"] != DBNull.Value ? gRow["PaymentMode"].ToString() : "Cash";

                                if (payMode.Equals("Credit Card", StringComparison.OrdinalIgnoreCase) || payMode.IndexOf("Card", StringComparison.OrdinalIgnoreCase) >= 0)
                                {
                                    totalCard += fee;
                                }
                                else if (payMode.Equals("Cash", StringComparison.OrdinalIgnoreCase))
                                {
                                    totalCash += fee;
                                }
                                else
                                {
                                    totalAccount += fee;
                                }
                            }
                        }

                        lblTotalCash.Text = "PKR " + totalCash.ToString("N0");
                        lblTotalCard.Text = "PKR " + totalCard.ToString("N0");
                        lblTotalAccount.Text = "PKR " + totalAccount.ToString("N0");
                        lblTotalOverall.Text = "PKR " + totalOverall.ToString("N0");

                        gvHistory.DataSource = dtGrouped;
                        gvHistory.DataBind();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading history: " + ex.Message, true);
        }
    }

    protected void gvHistory_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Reprint")
        {
            int transactionId = Convert.ToInt32(e.CommandArgument);
            ReprintReceipt(transactionId);
        }
    }

    private void ReprintReceipt(int transactionId)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = @"SELECT main.TransactionID AS MainTxnID, main.TransactionDate AS MainTxnDate, main.CustomerType, main.CustomerName, main.MemberID, main.DependentMemberNo, mp.MemberNo, main.PaymentMode, main.ManualRegisterNo,
                                         t.TransactionID, t.NetFee, ISNULL(t.BankDiscount, 0) AS BankDiscount, ISNULL(t.ManualDiscount, 0) AS ManualDiscount, t.ValidFrom, t.ValidTo, t.NumberOfDays, t.LockerID, t.LockerFee,
                                         s.PackageName, ISNULL(d.Dept_Name, sp.SportName) AS DepartmentName, sp.SportName, sp.SportID,
                                         ISNULL((SELECT SUM(CreditAmount) FROM LedgerEntries WHERE RefType = 'POS_Pay' AND RefID = t.TransactionID), 0) AS ItemAmountPaid
                                  FROM POSTransactions main
                                  INNER JOIN POSTransactions t ON (
                                      (main.MemberID IS NOT NULL AND t.MemberID = main.MemberID) 
                                      OR (main.MemberID IS NULL AND ISNULL(t.CustomerName, '') = ISNULL(main.CustomerName, ''))
                                  )
                                  AND ABS(DATEDIFF(second, t.TransactionDate, main.TransactionDate)) <= 5
                                  INNER JOIN Subscriptions s ON t.SubscriptionID = s.SubscriptionID
                                  INNER JOIN Sports sp ON s.SportID = sp.SportID
                                  LEFT JOIN BasicDataInfo.dbo.Department d ON sp.Dept_ID = d.Dept_ID
                                  LEFT JOIN [MemberShip].[dbo].[MemberProfile] mp ON main.MemberID = mp.MemberID
                                  WHERE main.TransactionID = @TransactionID
                                  ORDER BY t.TransactionID ASC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@TransactionID", transactionId);
                    con.Open();

                    DataTable dtReceipt = new DataTable();
                    dtReceipt.Columns.Add("PackageName", typeof(string));
                    dtReceipt.Columns.Add("NumberOfDays", typeof(int));
                    dtReceipt.Columns.Add("NetTotal", typeof(decimal));
                    dtReceipt.Columns.Add("ValidFrom", typeof(DateTime));
                    dtReceipt.Columns.Add("ValidTo", typeof(DateTime));
                    dtReceipt.Columns.Add("LockerName", typeof(string));
                    dtReceipt.Columns.Add("DepartmentName", typeof(string));

                    decimal totalGross = 0;
                    decimal totalBankDiscount = 0;
                    decimal totalManualDiscount = 0;
                    decimal totalAmountPaid = 0;
                    bool headerSet = false;
                    List<string> depts = new List<string>();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            if (!headerSet)
                            {
                                if (Session["UserRole"] != null && Session["UserRole"].ToString() == "Operator")
                                {
                                    List<int> allowedSports = Session["AllowedSports"] as List<int>;
                                    int sportId = Convert.ToInt32(reader["SportID"]);
                                    if (allowedSports == null || !allowedSports.Contains(sportId))
                                    {
                                        ShowMessage("You do not have permission to view or print transactions for this sport.", true);
                                        return;
                                    }
                                }

                                int mainTxnID = Convert.ToInt32(reader["MainTxnID"]);
                                lblRecNo.Text = "POS-" + mainTxnID.ToString("D5");
                                if (reader["ManualRegisterNo"] != DBNull.Value && !string.IsNullOrEmpty(reader["ManualRegisterNo"].ToString()))
                                {
                                    divRecManualRegister.Visible = true;
                                    lblRecManualRegister.Text = reader["ManualRegisterNo"].ToString();
                                }
                                else
                                {
                                    divRecManualRegister.Visible = false;
                                }

                                lblRecDate.Text = Convert.ToDateTime(reader["MainTxnDate"]).ToString("dd-MMM-yyyy hh:mm tt");
                                lblRecType.Text = reader["CustomerType"].ToString();

                                if (reader["MemberID"] != DBNull.Value)
                                {
                                    pnlRecMemberNo.Visible = true;
                                    string dependentNo = reader["DependentMemberNo"] != DBNull.Value ? reader["DependentMemberNo"].ToString() : "";
                                    string mainNo = reader["MemberNo"] != DBNull.Value ? reader["MemberNo"].ToString() : reader["MemberID"].ToString();
                                    lblRecMemberNo.Text = !string.IsNullOrEmpty(dependentNo) ? dependentNo : mainNo;
                                }
                                else
                                {
                                    pnlRecMemberNo.Visible = false;
                                }

                                lblRecName.Text = reader["CustomerName"].ToString();
                                lblRecPaymentMode.Text = reader["PaymentMode"] != DBNull.Value ? reader["PaymentMode"].ToString() : "Cash";
                                headerSet = true;
                            }

                            string deptName = reader["DepartmentName"] != DBNull.Value ? reader["DepartmentName"].ToString().Trim() : reader["SportName"].ToString().Trim();
                            if (!string.IsNullOrEmpty(deptName) && !depts.Contains(deptName))
                                depts.Add(deptName);

                            decimal itemGross = reader["NetFee"] != DBNull.Value ? Convert.ToDecimal(reader["NetFee"]) : 0;
                            totalGross += itemGross;

                            totalBankDiscount += reader["BankDiscount"] != DBNull.Value ? Convert.ToDecimal(reader["BankDiscount"]) : 0;
                            totalManualDiscount += reader["ManualDiscount"] != DBNull.Value ? Convert.ToDecimal(reader["ManualDiscount"]) : 0;

                            DataRow drItem = dtReceipt.NewRow();
                            drItem["PackageName"] = reader["PackageName"].ToString();
                            drItem["DepartmentName"] = deptName;
                            drItem["NumberOfDays"] = reader["NumberOfDays"] != DBNull.Value ? Convert.ToInt32(reader["NumberOfDays"]) : 1;
                            drItem["NetTotal"] = itemGross;
                            drItem["ValidFrom"] = reader["ValidFrom"] != DBNull.Value ? Convert.ToDateTime(reader["ValidFrom"]) : Convert.ToDateTime(reader["MainTxnDate"]);
                            drItem["ValidTo"] = reader["ValidTo"] != DBNull.Value ? Convert.ToDateTime(reader["ValidTo"]) : Convert.ToDateTime(reader["MainTxnDate"]);
                            drItem["LockerName"] = "";
                            dtReceipt.Rows.Add(drItem);

                            totalAmountPaid += reader["ItemAmountPaid"] != DBNull.Value ? Convert.ToDecimal(reader["ItemAmountPaid"]) : 0;
                        }

                        if (headerSet)
                        {
                            string allDepts = string.Join(", ", depts);
                            if (!string.IsNullOrEmpty(allDepts))
                            {
                                divRecDept.Visible = true;
                                lblRecDepartment.Text = allDepts;
                            }
                            else
                            {
                                divRecDept.Visible = false;
                            }

                            rptReceiptItems.DataSource = dtReceipt;
                            rptReceiptItems.DataBind();

                            decimal repDiscount = totalBankDiscount + totalManualDiscount;
                            if (repDiscount <= 0 && totalAmountPaid > 0 && totalAmountPaid < totalGross)
                            {
                                repDiscount = totalGross - totalAmountPaid;
                            }

                            if (repDiscount > 0)
                            {
                                divRecSubTotal.Visible = true;
                                lblRecSubTotal.Text = "PKR " + totalGross.ToString("N0");
                                divRecDiscount.Visible = true;
                                lblRecDiscount.Text = "- PKR " + repDiscount.ToString("N0");
                                divRecDiscountDivider.Visible = true;
                            }
                            else
                            {
                                divRecSubTotal.Visible = false;
                                divRecDiscount.Visible = false;
                                divRecDiscountDivider.Visible = false;
                            }

                            decimal finalReprintPaid = totalGross - repDiscount;
                            if (finalReprintPaid < 0) finalReprintPaid = 0;

                            if (totalAmountPaid > 0)
                            {
                                lblRecTotal.Text = "PKR " + Math.Round(finalReprintPaid).ToString("N0");
                            }
                            else
                            {
                                lblRecTotal.Text = "<span style='color:var(--danger);'>UNPAID</span>";
                            }

                            mvDailyPOS.ActiveViewIndex = 0;
                            btnTabNew.CssClass = "pos-tab-btn pos-tab-active";
                            btnTabHistory.CssClass = "pos-tab-btn pos-tab-inactive";
                            btnTabHistory.Style.Clear();
                            btnTabNew.Style.Clear();

                            pnlPOSForm.Visible = false;
                            pnlReceipt.Visible = true;
                        }
                        else
                        {
                            ShowMessage("Transaction not found.", true);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error reprinting receipt: " + ex.Message, true);
        }
    }
}
