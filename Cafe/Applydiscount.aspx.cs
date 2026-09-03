using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Pos : System.Web.UI.Page
{
    private string conStr = ConfigurationManager
        .ConnectionStrings["RestaurantConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadOffersGrid();
            CountActiveOffers();
            ClearForm();
            hfActiveTab.Value = "new";
        }
    }

    // ─── GET DEPARTMENTS (returns DataTable, does NOT bind anything) ──────────
    private DataTable GetDepartments()
    {
        DataTable dt = new DataTable();
        try
        {
            using (SqlConnection con = new SqlConnection(conStr))
            {
                string q = @"SELECT SubDept_Id, SubDept_Name 
                             FROM SubDepartment 
                             WHERE Dept_Id = 9 
                             ORDER BY SubDept_Name";
                using (SqlCommand cmd = new SqlCommand(q, con))
                {
                    con.Open();
                    new SqlDataAdapter(cmd).Fill(dt);
                }
            }
        }
        catch (Exception ex)
        {
            ShowError("Error loading departments: " + ex.Message);
        }
        return dt;
    }

    // ─── GRID ────────────────────────────────────────────────────────────────
    private void LoadOffersGrid()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(conStr))
            {
                string q = @"SELECT offer_id, offer_name, ISNULL(offer_code,'') as offer_code, 
                                card_prefix, discount_percent, min_bill_amount, 
                                ISNULL(dept_name,'Unassigned') as dept_name, is_active
                             FROM card_prefix_offers 
                             ORDER BY offer_id DESC";
                using (SqlCommand cmd = new SqlCommand(q, con))
                {
                    con.Open();
                    DataTable dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);
                    gvOffers.DataSource = dt;
                    gvOffers.DataBind();
                }
            }
        }
        catch (Exception ex)
        {
            ShowError("Error loading offers: " + ex.Message);
            gvOffers.DataSource = new DataTable();
            gvOffers.DataBind();
        }
    }

    private void CountActiveOffers()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(conStr))
            {
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM card_prefix_offers WHERE is_active=1", con))
                {
                    con.Open();
                    lblActiveOffers.Text = (int)cmd.ExecuteScalar() + " Active";
                }
            }
        }
        catch { lblActiveOffers.Text = "0 Active"; }
    }

    // ─── CREATE OFFER ────────────────────────────────────────────────────────
    protected void btnSaveOffer_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        string offerName      = txtOfferName.Text.Trim();
        string offerCode      = txtOfferCode.Text.Trim();
        string prefixesInput  = txtCardPrefix.Text.Trim();
        int    prefixLength   = GetSelectedPrefixLength();

        string[] prefixes = prefixesInput
            .Split(new char[] { ',', ' ' }, StringSplitOptions.RemoveEmptyEntries)
            .Select(p => p.Trim()).ToArray();

        bool allValid = prefixes.All(p => p.Length == prefixLength && p.All(char.IsDigit));
        if (prefixes.Length == 0 || !allValid)
        {
            ShowError(string.Format(
                "Please enter valid {0}-digit prefixes (only numbers, exactly {0} digits each).",
                prefixLength));
            return;
        }

        decimal discPct;
        if (!decimal.TryParse(txtDiscountPercent.Text, out discPct))
        {
            ShowError("Please enter a valid discount percentage.");
            return;
        }

        decimal minBill    = string.IsNullOrWhiteSpace(txtMinBill.Text) ? 0m : Convert.ToDecimal(txtMinBill.Text);
        object maxDiscount = string.IsNullOrWhiteSpace(txtMaxDiscount.Text) ? (object)DBNull.Value : Convert.ToDecimal(txtMaxDiscount.Text);
        object validFrom   = string.IsNullOrWhiteSpace(txtValidFrom.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtValidFrom.Text);
        object validTo     = string.IsNullOrWhiteSpace(txtValidTo.Text)   ? (object)DBNull.Value : Convert.ToDateTime(txtValidTo.Text);
        bool   isActive    = chkActive.Checked;
        int    perDayLimit = string.IsNullOrWhiteSpace(txtPerDayLimit.Text) ? 0 : Convert.ToInt32(txtPerDayLimit.Text);

        int weekday = 0;
        if (!string.IsNullOrWhiteSpace(hfSelectedDays.Value))
        {
            string[] parts = hfSelectedDays.Value.Split(',');
            if (parts.Length == 1) weekday = int.Parse(parts[0]);
        }

        int    empId   = GetSessionEmpId();
        string empName = GetEmployeeName(empId);
        string ip      = GetClientIp();
        int    saved   = 0;

        try
        {
            using (SqlConnection con = new SqlConnection(conStr))
            {
                con.Open();
                foreach (string prefix in prefixes)
                {
                    string sql = @"
                        INSERT INTO card_prefix_offers 
                            (offer_name,offer_code,card_prefix,discount_percent,valid_weekday,
                             min_bill_amount,max_discount_amount,valid_from,valid_to,
                             is_active,created_at,per_day_transaction_limit,prefix_length)
                        OUTPUT INSERTED.offer_id
                        VALUES 
                            (@offer_name,@offer_code,@card_prefix,@discount_percent,@valid_weekday,
                             @min_bill_amount,@max_discount_amount,@valid_from,@valid_to,
                             @is_active,GETDATE(),@per_day_limit,@prefix_length)";

                    int newId = 0;
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@offer_name",       offerName);
                        cmd.Parameters.AddWithValue("@offer_code",       string.IsNullOrEmpty(offerCode) ? DBNull.Value : (object)offerCode);
                        cmd.Parameters.AddWithValue("@card_prefix",      prefix);
                        cmd.Parameters.AddWithValue("@discount_percent", discPct);
                        cmd.Parameters.AddWithValue("@valid_weekday",    weekday);
                        cmd.Parameters.AddWithValue("@min_bill_amount",  minBill);
                        cmd.Parameters.AddWithValue("@max_discount_amount", maxDiscount);
                        cmd.Parameters.AddWithValue("@valid_from",       validFrom);
                        cmd.Parameters.AddWithValue("@valid_to",         validTo);
                        cmd.Parameters.AddWithValue("@is_active",        isActive ? 1 : 0);
                        cmd.Parameters.AddWithValue("@per_day_limit",    perDayLimit);
                        cmd.Parameters.AddWithValue("@prefix_length",    prefixLength);
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                            newId = Convert.ToInt32(result);
                    }
                    if (newId > 0)
                    {
                        WriteLog(con, newId, "INSERT", offerName, prefix, discPct, weekday,
                                 minBill, maxDiscount, validFrom, validTo, isActive, "", 0,
                                 perDayLimit, empId, empName, ip,
                                 string.Format("Offer created with {0}-digit prefix", prefixLength));
                        saved++;
                    }
                }
            }
            ShowSuccess(string.Format("✓ {0} offer(s) published successfully!", saved));
            ClearForm();
            CountActiveOffers();
            LoadOffersGrid();
            hfActiveTab.Value = "new";
        }
        catch (Exception ex) { ShowError("Error: " + ex.Message); }
    }

    private int GetSelectedPrefixLength()
    {
        if (rbPrefix6.Checked) return 6;
        if (rbPrefix8.Checked) return 8;
        return 4;
    }

    // ─── SEARCH OFFER ────────────────────────────────────────────────────────
    protected void btnSearchOffer_Click(object sender, EventArgs e)
    {
        hfActiveTab.Value = "assign";
        // Reset selection area
        pnlSelectedOffer.Visible = false;
        pnlDeptAssign.Visible    = false;
        hfSearchedOfferId.Value  = "";

        string search = txtSearchOffer.Text.Trim();
        if (string.IsNullOrWhiteSpace(search))
        {
            pnlSearchResults.Visible = false;
            pnlNoResult.Visible      = true;
            return;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(conStr))
            {
                string q = @"SELECT offer_id, offer_name, ISNULL(offer_code,'') as offer_code, 
                                    card_prefix, discount_percent, is_active
                             FROM card_prefix_offers
                             WHERE offer_name LIKE '%'+@s+'%' 
                                OR offer_code  LIKE '%'+@s+'%'
                                OR card_prefix  LIKE '%'+@s+'%'
                             ORDER BY created_at DESC";
                using (SqlCommand cmd = new SqlCommand(q, con))
                {
                    cmd.Parameters.AddWithValue("@s", search);
                    con.Open();
                    DataTable dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptOfferResults.DataSource = dt;
                        rptOfferResults.DataBind();
                        pnlSearchResults.Visible = true;
                        pnlNoResult.Visible      = false;
                    }
                    else
                    {
                        pnlSearchResults.Visible = false;
                        pnlNoResult.Visible      = true;
                    }
                }
            }
        }
        catch (Exception ex) { ShowError("Search error: " + ex.Message); }
    }

    // ─── SELECT OFFER → POPULATE DEPT CHECKBOXES ────────────────────────────
    protected void rptOfferResults_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName != "Select") return;

        hfActiveTab.Value = "assign";
        int offerId = Convert.ToInt32(e.CommandArgument);
        hfSearchedOfferId.Value = offerId.ToString();

        try
        {
            using (SqlConnection con = new SqlConnection(conStr))
            {
                con.Open();

                // Offer details
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT offer_name, ISNULL(offer_code,'') as offer_code, card_prefix, discount_percent FROM card_prefix_offers WHERE offer_id=@id", con))
                {
                    cmd.Parameters.AddWithValue("@id", offerId);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            lblSelOfferName.Text = r["offer_name"].ToString();
                            lblSelOfferId.Text   = offerId.ToString();
                            lblSelOfferCode.Text  = r["offer_code"].ToString();
                            lblSelPrefix.Text    = r["card_prefix"].ToString();
                            lblSelDiscount.Text  = r["discount_percent"].ToString();
                        }
                    }
                }

                // Currently assigned dept_id (if any)
                string assignedDeptId = "";
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT ISNULL(CAST(dept_id AS VARCHAR),'') FROM card_prefix_offers WHERE offer_id=@id", con))
                {
                    cmd.Parameters.AddWithValue("@id", offerId);
                    object res = cmd.ExecuteScalar();
                    assignedDeptId = (res != null && res != DBNull.Value) ? res.ToString() : "";
                }

                // Populate department checkboxes
                DataTable depts = GetDepartments();
                cblDepartments.Items.Clear();
                foreach (DataRow row in depts.Rows)
                {
                    string dId   = row["SubDept_Id"].ToString();
                    string dName = row["SubDept_Name"].ToString();
                    ListItem li  = new ListItem(dName, dId);
                    li.Selected  = (dId == assignedDeptId);
                    cblDepartments.Items.Add(li);
                }

                pnlSelectedOffer.Visible = true;
                pnlDeptAssign.Visible    = true;
            }
        }
        catch (Exception ex) { ShowError("Error loading offer: " + ex.Message); }
    }

    // ─── ASSIGN (MULTIPLE DEPTS) ─────────────────────────────────────────────
    protected void btnAssignSave_Click(object sender, EventArgs e)
    {
        hfActiveTab.Value = "assign";

        if (string.IsNullOrWhiteSpace(hfSearchedOfferId.Value) || hfSearchedOfferId.Value == "0")
        {
            ShowError("Please search and select an offer first.");
            return;
        }

        // Collect checked departments
        var selected = new System.Collections.Generic.List<ListItem>();
        foreach (ListItem item in cblDepartments.Items)
            if (item.Selected) selected.Add(item);

        if (selected.Count == 0)
        {
            ShowError("Please select at least one department.");
            return;
        }

        int    offerId  = Convert.ToInt32(hfSearchedOfferId.Value);
        int    empId    = GetSessionEmpId();
        string empName  = GetEmployeeName(empId);
        string ip       = GetClientIp();

        try
        {
            using (SqlConnection con = new SqlConnection(conStr))
            {
                con.Open();

                // Fetch base offer data
                string offerName = "", cardPrefix = "";
                decimal discPct = 0;
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT offer_name, card_prefix, discount_percent FROM card_prefix_offers WHERE offer_id=@id", con))
                {
                    cmd.Parameters.AddWithValue("@id", offerId);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            offerName  = r["offer_name"].ToString();
                            cardPrefix = r["card_prefix"].ToString();
                            discPct    = Convert.ToDecimal(r["discount_percent"]);
                        }
                    }
                }

                string allDeptNames = string.Join(", ", selected.Select(d => d.Text));

                // Update original offer with first selected dept
                int    primaryId   = Convert.ToInt32(selected[0].Value);
                string primaryName = selected[0].Text;

                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE card_prefix_offers SET dept_id=@did, dept_name=@dn WHERE offer_id=@oid", con))
                {
                    cmd.Parameters.AddWithValue("@did", primaryId);
                    cmd.Parameters.AddWithValue("@dn",  allDeptNames);   // store all for display
                    cmd.Parameters.AddWithValue("@oid", offerId);
                    cmd.ExecuteNonQuery();
                }

                // Clone offer for each additional dept
                for (int i = 1; i < selected.Count; i++)
                {
                    int    extraId   = Convert.ToInt32(selected[i].Value);
                    string extraName = selected[i].Text;

                    string cloneSql = @"
                        INSERT INTO card_prefix_offers
                            (offer_name,offer_code,card_prefix,discount_percent,valid_weekday,
                             min_bill_amount,max_discount_amount,valid_from,valid_to,
                             is_active,created_at,per_day_transaction_limit,prefix_length,
                             dept_id,dept_name)
                        SELECT offer_name,offer_code,card_prefix,discount_percent,valid_weekday,
                               min_bill_amount,max_discount_amount,valid_from,valid_to,
                               is_active,GETDATE(),per_day_transaction_limit,prefix_length,
                               @dept_id,@dept_name
                        FROM card_prefix_offers WHERE offer_id=@offer_id";

                    using (SqlCommand cmd = new SqlCommand(cloneSql, con))
                    {
                        cmd.Parameters.AddWithValue("@dept_id",   extraId);
                        cmd.Parameters.AddWithValue("@dept_name", extraName);
                        cmd.Parameters.AddWithValue("@offer_id",  offerId);
                        cmd.ExecuteNonQuery();
                    }
                }

                WriteLog(con, offerId, "ASSIGN_DEPT", offerName, cardPrefix, discPct, 0,
                         0m, DBNull.Value, DBNull.Value, DBNull.Value, true,
                         allDeptNames, primaryId, 0, empId, empName, ip,
                         string.Format("Assigned to: {0}", allDeptNames));
            }

            ShowSuccess(string.Format("✓ Offer assigned to {0} department(s): {1}",
                selected.Count, string.Join(", ", selected.Select(d => d.Text))));

            LoadOffersGrid();
            CountActiveOffers();

            // Clear assign area after success
            pnlSelectedOffer.Visible = false;
            pnlDeptAssign.Visible    = false;
            hfSearchedOfferId.Value  = "";
            txtSearchOffer.Text      = "";
            pnlSearchResults.Visible = false;
            pnlNoResult.Visible      = false;
        }
        catch (Exception ex) { ShowError("Assignment error: " + ex.Message); }
    }

    // ─── GRID ROW ACTIONS ────────────────────────────────────────────────────
    protected void gvOffers_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int offerId = Convert.ToInt32(e.CommandArgument);
        if (e.CommandName == "ToggleStatus")
        {
            ToggleOfferStatus(offerId);
            ShowSuccess("Offer status updated.");
        }
        else if (e.CommandName == "DeleteOffer")
        {
            DeleteOffer(offerId);
            ShowSuccess("Offer deleted successfully.");
        }
        LoadOffersGrid();
        CountActiveOffers();
        hfActiveTab.Value = "view";
    }

    protected void gvOffers_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvOffers.PageIndex = e.NewPageIndex;
        LoadOffersGrid();
        hfActiveTab.Value = "view";
    }

    private void ToggleOfferStatus(int offerId)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(conStr))
            {
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE card_prefix_offers SET is_active=CASE WHEN is_active=1 THEN 0 ELSE 1 END WHERE offer_id=@id", con))
                {
                    cmd.Parameters.AddWithValue("@id", offerId);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch (Exception ex) { ShowError("Error updating status: " + ex.Message); }
    }

    private void DeleteOffer(int offerId)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(conStr))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand("DELETE FROM offer_daily_usage WHERE offer_id=@id", con))
                { cmd.Parameters.AddWithValue("@id", offerId); cmd.ExecuteNonQuery(); }
                using (SqlCommand cmd = new SqlCommand("DELETE FROM card_prefix_offers WHERE offer_id=@id", con))
                { cmd.Parameters.AddWithValue("@id", offerId); cmd.ExecuteNonQuery(); }
            }
        }
        catch (Exception ex) { throw new Exception("Error deleting offer: " + ex.Message); }
    }

    // ─── UTILITY ─────────────────────────────────────────────────────────────
    private int GetSessionEmpId()
    {
        int e2;
        return (Session["Emp_ID"] != null && int.TryParse(Session["Emp_ID"].ToString(), out e2)) ? e2 : 0;
    }

    private string GetEmployeeName(int empId)
    {
        if (empId <= 0) return "Unknown";
        try
        {
            using (SqlConnection con = new SqlConnection(conStr))
            using (SqlCommand cmd = new SqlCommand("SELECT EFName FROM Employee WHERE EmpID=@id", con))
            {
                cmd.Parameters.AddWithValue("@id", empId);
                con.Open();
                object r = cmd.ExecuteScalar();
                return r != null ? r.ToString() : "Unknown";
            }
        }
        catch { return "Unknown"; }
    }

    private string GetClientIp()
    {
        string ip = Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
        if (string.IsNullOrWhiteSpace(ip)) ip = Request.ServerVariables["REMOTE_ADDR"];
        return ip ?? "unknown";
    }

    private void WriteLog(SqlConnection con, int offerId, string actionType,
        string offerName, string cardPrefix, decimal discountPct, int weekday,
        object minBill, object maxDiscount, object validFrom, object validTo,
        bool isActive, string deptName, int deptId, int perDayLimit,
        int empId, string empName, string ip, string remarks = "")
    {
        string sql = @"
            INSERT INTO discount_offer_log
                (offer_id,action_type,offer_name,card_prefix,discount_percent,
                 valid_weekday,min_bill_amount,max_discount_amount,valid_from,valid_to,
                 is_active,dept_name,dept_id,per_day_limit,emp_id,emp_name,
                 log_time,ip_address,remarks)
            VALUES
                (@offer_id,@action_type,@offer_name,@card_prefix,@discount_percent,
                 @valid_weekday,@min_bill_amount,@max_discount_amount,@valid_from,@valid_to,
                 @is_active,@dept_name,@dept_id,@per_day_limit,@emp_id,@emp_name,
                 GETDATE(),@ip_address,@remarks)";
        try
        {
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@offer_id",          offerId);
                cmd.Parameters.AddWithValue("@action_type",       actionType);
                cmd.Parameters.AddWithValue("@offer_name",        offerName);
                cmd.Parameters.AddWithValue("@card_prefix",       cardPrefix);
                cmd.Parameters.AddWithValue("@discount_percent",  discountPct);
                cmd.Parameters.AddWithValue("@valid_weekday",     weekday);
                cmd.Parameters.AddWithValue("@min_bill_amount",   minBill);
                cmd.Parameters.AddWithValue("@max_discount_amount", maxDiscount);
                cmd.Parameters.AddWithValue("@valid_from",        validFrom);
                cmd.Parameters.AddWithValue("@valid_to",          validTo);
                cmd.Parameters.AddWithValue("@is_active",         isActive ? 1 : 0);
                cmd.Parameters.AddWithValue("@dept_name",         string.IsNullOrEmpty(deptName) ? DBNull.Value : (object)deptName);
                cmd.Parameters.AddWithValue("@dept_id",           deptId > 0 ? (object)deptId : DBNull.Value);
                cmd.Parameters.AddWithValue("@per_day_limit",     perDayLimit);
                cmd.Parameters.AddWithValue("@emp_id",            empId > 0 ? (object)empId : DBNull.Value);
                cmd.Parameters.AddWithValue("@emp_name",          empName);
                cmd.Parameters.AddWithValue("@ip_address",        ip);
                cmd.Parameters.AddWithValue("@remarks",           remarks);
                cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }

    protected void btnClear_Click(object sender, EventArgs e) { ClearForm(); }

    private void ClearForm()
    {
        txtOfferName.Text = txtOfferCode.Text = txtCardPrefix.Text =
        txtDiscountPercent.Text = txtMaxDiscount.Text = txtValidFrom.Text =
        txtValidTo.Text = string.Empty;
        txtMinBill.Text = txtPerDayLimit.Text = "0";
        hfSelectedDays.Value = "";
        chkActive.Checked = true;
        rbPrefix4.Checked = true;
        ClientScript.RegisterStartupScript(this.GetType(), "clearDays",
            "if(typeof clearAllDays==='function')clearAllDays();", true);
    }

    private void ShowSuccess(string msg)
    {
        ClientScript.RegisterStartupScript(this.GetType(), "alert",
            "showAlert('success','" + msg.Replace("'", "\\'") + "');", true);
    }
    private void ShowError(string msg)
    {
        ClientScript.RegisterStartupScript(this.GetType(), "alert",
            "showAlert('error','" + msg.Replace("'", "\\'") + "');", true);
    }
}

