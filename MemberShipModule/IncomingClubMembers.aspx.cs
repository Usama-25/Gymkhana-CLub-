using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class IncomingClubMembers : System.Web.UI.Page
{
    private string connStr
    {
        get
        {
            var s = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
            return s != null ? s.ConnectionString : "";
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        // Handle Print Request before normal load
        if (Request.QueryString["print"] == "true" && !string.IsNullOrEmpty(Request.QueryString["id"]))
        {
            int printId = 0;
            if (int.TryParse(Request.QueryString["id"], out printId))
            {
                GeneratePrintReport(printId);
                return;
            }
        }

        if (!IsPostBack)
        {
            EnsureTable();
            BindDropdowns();
            BindGrid();
            
            if (!string.IsNullOrEmpty(Request.QueryString["id"]))
            {
                int id = 0;
                if (int.TryParse(Request.QueryString["id"], out id))
                {
                    LoadRecord(id);
                }
            }
            else
            {
                GenerateIntroductoryNo();
                txtDateFrom.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }
    }

    private void EnsureTable()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            SqlCommand cmd = new SqlCommand("usp_EnsureIncomingClubMembersTable", con);
            cmd.CommandType = CommandType.StoredProcedure;
            con.Open();
            cmd.ExecuteNonQuery();
        }
    }

    private void BindDropdowns()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            
            // Clubs
            SqlCommand cmdClubs = new SqlCommand("usp_GetActiveAffiliatedClubs", con);
            cmdClubs.CommandType = CommandType.StoredProcedure;
            SqlDataAdapter daClubs = new SqlDataAdapter(cmdClubs);
            DataTable dtClubs = new DataTable();
            daClubs.Fill(dtClubs);
            ddlClub.DataSource = dtClubs;
            ddlClub.DataTextField = "ClubName";
            ddlClub.DataValueField = "Id";
            ddlClub.DataBind();
            ddlClub.Items.Insert(0, new ListItem("-- Select Affiliated Club --", "0"));

            // Countries
            SqlCommand cmdCountries = new SqlCommand("usp_GetAllCountries", con);
            cmdCountries.CommandType = CommandType.StoredProcedure;
            SqlDataAdapter daCountries = new SqlDataAdapter(cmdCountries);
            DataTable dtCountries = new DataTable();
            daCountries.Fill(dtCountries);
            if (dtCountries.Rows.Count > 0)
            {
                ddlCountry.DataSource = dtCountries;
                ddlCountry.DataTextField = "CountryName";
                ddlCountry.DataValueField = "CountryName";
                ddlCountry.DataBind();
            }
            else
            {
                ddlCountry.Items.Add(new ListItem("Pakistan", "Pakistan"));
            }
            ddlCountry.Items.Insert(0, new ListItem("-- Select Country --", ""));

            // Cities
            SqlCommand cmdCities = new SqlCommand("usp_GetAllCities", con);
            cmdCities.CommandType = CommandType.StoredProcedure;
            SqlDataAdapter daCities = new SqlDataAdapter(cmdCities);
            DataTable dtCities = new DataTable();
            daCities.Fill(dtCities);
            if (dtCities.Rows.Count > 0)
            {
                ddlCity.DataSource = dtCities;
                ddlCity.DataTextField = "CityName";
                ddlCity.DataValueField = "CityName";
                ddlCity.DataBind();
            }
            else
            {
                ddlCity.Items.Add(new ListItem("Lahore", "Lahore"));
            }
            ddlCity.Items.Insert(0, new ListItem("-- Select City --", ""));
        }
    }

    private void BindGrid()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            SqlCommand cmd = new SqlCommand("usp_GetIncomingClubMembers", con);
            cmd.CommandType = CommandType.StoredProcedure;
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            gvIncoming.DataSource = dt;
            gvIncoming.DataBind();
        }
    }

    private void GenerateIntroductoryNo()
    {
        if (hfId.Value != "0") return;

        using (SqlConnection con = new SqlConnection(connStr))
        {
            string datePart = DateTime.Now.ToString("yyyyMMdd");
            string prefix = "INTRO-" + datePart + "-";
            
            SqlCommand cmd = new SqlCommand("usp_GetLastIntroductoryNo", con);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("@Prefix", SqlDbType.NVarChar, 20).Value = prefix;
            
            con.Open();
            object result = cmd.ExecuteScalar();
            int nextNo = 1;
            
            if (result != null)
            {
                string lastNo = result.ToString();
                int.TryParse(lastNo.Replace(prefix, ""), out nextNo);
                nextNo++;
            }
            
            txtIntroNo.Text = prefix + nextNo.ToString("D4");
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(txtMemberNo.Text) || string.IsNullOrEmpty(txtMemberName.Text) || ddlClub.SelectedValue == "0")
        {
            ShowMessage("Member No, Name, and Club are required.", false);
            return;
        }

        int id = 0;
        int.TryParse(hfId.Value, out id);
        
        DateTime dateFrom = DateTime.Parse(txtDateFrom.Text);
        int days = int.Parse(txtDays.Text);
        DateTime dateTo = dateFrom.AddDays(days - 1);

        string validationError;
        if (!ValidateVisitRestrictions(id, txtMemberNo.Text.Trim(), Convert.ToInt32(ddlClub.SelectedValue), dateFrom, days, out validationError))
        {
            ShowMessage(validationError, false);
            return;
        }

        int newId = 0;
        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            SqlCommand cmd;
            
            if (id > 0)
            {
                cmd = new SqlCommand("usp_UpdateIncomingClubMember", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@Id", SqlDbType.Int).Value = id;
                newId = id;
            }
            else
            {
                GenerateIntroductoryNo(); 
                cmd = new SqlCommand("usp_InsertIncomingClubMember", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@IntroNo", SqlDbType.NVarChar, 50).Value = txtIntroNo.Text;
                cmd.Parameters.Add("@CreatedBy", SqlDbType.NVarChar, 100).Value = Session["Emp_Name"] ?? "System";
            }

            cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = txtMemberNo.Text.Trim();
            cmd.Parameters.Add("@MemberName", SqlDbType.NVarChar, 200).Value = txtMemberName.Text.Trim();
            cmd.Parameters.Add("@ClubId", SqlDbType.Int).Value = Convert.ToInt32(ddlClub.SelectedValue);
            cmd.Parameters.Add("@ForType", SqlDbType.NVarChar, 50).Value = rblFor.SelectedValue;
            cmd.Parameters.Add("@RefNo", SqlDbType.NVarChar, 50).Value = txtRefNo.Text.Trim();
            cmd.Parameters.Add("@DateFrom", SqlDbType.DateTime).Value = dateFrom;
            cmd.Parameters.Add("@Days", SqlDbType.Int).Value = days;
            cmd.Parameters.Add("@DateTo", SqlDbType.DateTime).Value = dateTo;
            cmd.Parameters.Add("@Remarks", SqlDbType.NVarChar, 500).Value = txtRemarks.Text.Trim();
            cmd.Parameters.Add("@Address1", SqlDbType.NVarChar, 500).Value = txtAddr1.Text.Trim();
            cmd.Parameters.Add("@Address2", SqlDbType.NVarChar, 500).Value = txtAddr2.Text.Trim();
            cmd.Parameters.Add("@City", SqlDbType.NVarChar, 100).Value = ddlCity.SelectedValue;
            cmd.Parameters.Add("@Country", SqlDbType.NVarChar, 100).Value = ddlCountry.SelectedValue;
            cmd.Parameters.Add("@Tel", SqlDbType.NVarChar, 50).Value = txtTel.Text.Trim();
            cmd.Parameters.Add("@Mobile", SqlDbType.NVarChar, 50).Value = txtMobile.Text.Trim();
            cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 200).Value = txtEmail.Text.Trim();
            cmd.Parameters.Add("@Fax", SqlDbType.NVarChar, 50).Value = txtFax.Text.Trim();
            cmd.Parameters.Add("@Cnic", SqlDbType.NVarChar, 50).Value = txtCnic.Text.Trim();
            cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = chkIsActive.Checked;

            object result = cmd.ExecuteScalar();
            if (id == 0 && result != null) newId = Convert.ToInt32(result);
        }

        ShowMessage("Record saved successfully.", true);
        
        // Auto-open print in new tab
        string printUrl = "IncomingClubMembers.aspx?print=true&id=" + newId;
        string script = "setTimeout(function() { window.open('" + printUrl + "', '_blank'); }, 100);";
        ScriptManager.RegisterStartupScript(this, GetType(), "PrintReport", script, true);

        ClearForm();
        BindGrid();
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        ClearForm();
    }

    protected void btnPrint_Click(object sender, EventArgs e)
    {
        int id = 0;
        int.TryParse(hfId.Value, out id);
        if (id > 0)
        {
            string printUrl = "IncomingClubMembers.aspx?print=true&id=" + id;
            string script = "setTimeout(function() { window.open('" + printUrl + "', '_blank'); }, 100);";
            ScriptManager.RegisterStartupScript(this, GetType(), "PrintReport", script, true);
        }
        else
        {
            ShowMessage("Please select or save a record first to print.", false);
        }
    }

    protected void gvIncoming_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int id = Convert.ToInt32(e.CommandArgument);
        
        if (e.CommandName == "EditItem")
        {
            LoadRecord(id);
        }
        else if (e.CommandName == "PrintItem")
        {
            string printUrl = "IncomingClubMembers.aspx?print=true&id=" + id;
            string script = "setTimeout(function() { window.open('" + printUrl + "', '_blank'); }, 100);";
            ScriptManager.RegisterStartupScript(this, GetType(), "PrintReport", script, true);
        }
    }

    private void LoadRecord(int id)
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            SqlCommand cmd = new SqlCommand("usp_GetIncomingClubMemberByID", con);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("@Id", SqlDbType.Int).Value = id;
            con.Open();
            SqlDataReader dr = cmd.ExecuteReader();
            if (dr.Read())
            {
                hfId.Value = id.ToString();
                txtIntroNo.Text = dr["IntroductoryNo"].ToString();
                txtMemberNo.Text = dr["MemberNo"].ToString();
                txtMemberName.Text = dr["MemberName"].ToString();
                ddlClub.SelectedValue = dr["ClubId"].ToString();
                rblFor.SelectedValue = dr["ForType"].ToString();
                txtRefNo.Text = dr["RefNo"].ToString();
                txtDateFrom.Text = Convert.ToDateTime(dr["DateFrom"]).ToString("yyyy-MM-dd");
                txtDays.Text = dr["Days"].ToString();
                txtDateTo.Text = Convert.ToDateTime(dr["DateTo"]).ToString("dd-MM-yyyy");
                txtRemarks.Text = dr["Remarks"].ToString();
                txtAddr1.Text = dr["Address1"].ToString();
                txtAddr2.Text = dr["Address2"].ToString();
                ddlCity.SelectedValue = dr["City"].ToString();
                ddlCountry.SelectedValue = dr["Country"].ToString();
                txtTel.Text = dr["Tel"].ToString();
                txtMobile.Text = dr["Mobile"].ToString();
                txtEmail.Text = dr["Email"].ToString();
                txtFax.Text = dr["Fax"].ToString();
                txtCnic.Text = dr["NTN_CNIC"].ToString();
                chkIsActive.Checked = Convert.ToBoolean(dr["IsActive"]);
                btnSave.Text = "Update Details";
            }
        }
    }

    private void GeneratePrintReport(int id)
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            SqlCommand cmd = new SqlCommand("usp_GetIncomingClubMemberDetailForPrint", con);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("@Id", SqlDbType.Int).Value = id;
            
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            
            if (dt.Rows.Count == 0) return;
            DataRow row = dt.Rows[0];
            
            string logoPath = ResolveUrl("~/MemberShipModule/assets/images/logo for report.jpeg");
            string preparedBy = row["CreatedBy"] != DBNull.Value ? row["CreatedBy"].ToString() : "System";
            string printDateTime = DateTime.Now.ToString("dd/MM/yyyy hh:mm:ss tt");

            System.Text.StringBuilder html = new System.Text.StringBuilder();
            html.Append(@"<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>Introductory Letter - " + row["IntroductoryNo"].ToString() + @"</title>
    <style>
        @page { size: A4; margin: 0; }
        body { font-family: 'Arial', sans-serif; font-size: 13px; margin: 0; padding: 0; color: #000; background: #fff; line-height: 1.3; }
        .report-page { width: 210mm; height: 297mm; padding: 12mm 15mm; margin: auto; box-sizing: border-box; display: flex; flex-direction: column; position: relative; overflow: hidden; }
        
        .header { display: flex; align-items: flex-start; justify-content: space-between; border-bottom: 2px solid #000; padding-bottom: 6px; margin-bottom: 20px; }
        .header-left { display: flex; align-items: center; gap: 12px; }
        .logo { height: 60px; width: auto; }
        .club-info h1 { font-family: 'Times New Roman', Times, serif; font-size: 26px; font-weight: bold; margin: 0; color: #000; letter-spacing: 0.5px; }
        .club-info p { font-size: 10px; margin: 1px 0; color: #333; font-weight: bold; }
        
        .meta-info { text-align: right; font-size: 12px; line-height: 1.5; padding-top: 5px; }
        .meta-info strong { width: 85px; display: inline-block; text-align: left; }

        .recipient-info { margin-bottom: 12px; font-size: 13px; line-height: 1.4; }
        .recipient-info div { font-weight: bold; }

        .subject { text-align: center; margin: 12px 0; font-size: 15px; font-weight: bold; text-decoration: underline; text-transform: uppercase; font-style: italic; }

        .welcome-text { margin-bottom: 20px; text-align: justify; font-size: 13px; line-height: 1.5; }

        .signature-area { display: flex; justify-content: flex-end; margin: 15px 0 25px; }
        .sig-box { width: 140px; text-align: center; font-weight: bold; font-size: 13px; }

        .info-card { border: 1px solid #000; padding: 10px 15px; width: 88%; margin: 10px auto; }
        .info-card-title { text-align: center; font-weight: bold; text-decoration: underline; margin-bottom: 8px; font-size: 14px; font-style: italic; }
        
        .card-table { width: 100%; border-collapse: collapse; }
        .card-table td { padding: 2px 8px; vertical-align: top; font-size: 12px; }
        .card-table .label { font-weight: bold; width: 130px; }
        .card-table .separator { width: 10px; text-align: center; }

        .footer { position: absolute; bottom: 10mm; left: 15mm; right: 15mm; font-size: 9px; color: #333; border-top: 1px solid #ccc; padding-top: 4px; display: flex; justify-content: space-between; }

        @media print { 
            .no-print { display: none; } 
            body { background: none; }
            .report-page { border: none; box-shadow: none; margin: 0; padding: 20mm; }
        }
    </style>
</head>
<body onload='window.print()'>
    <div class='report-page'>
        <!-- Top Header -->
        <div class='header'>
            <div class='header-left'>
                <img src='" + logoPath + @"' class='logo' alt='Logo' />
                <div class='club-info'>
                    <h1>LAHORE GYMKHANA</h1>
                    <p><strong>Upper Shahrah-e-Quaid-e-Azam, Lahore, Pakistan</strong></p>
                    <p><strong>Phone: 111-111-231 Email: secretary@lahoregymkhana.org.pk</strong></p>
                </div>
            </div>
        </div>

        <!-- Recipient and Meta-Info side-by-side -->
        <div style='display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px;'>
            <div class='recipient-info'>
                <div>" + row["MemberName"].ToString() + @",</div>
                <div>" + row["ClubName"].ToString() + @",</div>
                <div style='text-decoration: underline;'>" + row["City"].ToString() + @".</div>
            </div>
            <div class='meta-info' style='text-align: right; font-size: 13px;'>
                <table style='margin-left: auto; border-collapse: collapse; text-align: left;'>
                    <tr>
                        <td style='font-weight: bold; padding-right: 5px; width: 85px;'>Letter No</td>
                        <td>: " + row["IntroductoryNo"].ToString() + @"</td>
                    </tr>
                    <tr>
                        <td style='font-weight: bold; padding-right: 5px;'>Issuing Date</td>
                        <td>: " + Convert.ToDateTime(row["DateFrom"]).ToString("dd/MM/yyyy") + @"</td>
                    </tr>
                    <tr>
                        <td style='font-weight: bold; padding-right: 5px;'>Valid Upto</td>
                        <td>: " + Convert.ToDateTime(row["DateTo"]).ToString("dd/MM/yyyy") + @"</td>
                    </tr>
                </table>
            </div>
        </div>

        <div class='subject'>AFFILIATED CLUB MEMBER CARD</div>

        <div class='welcome-text'>
            We welcome the affiliated member having Membership No. <strong>" + row["MemberNo"].ToString() + @"</strong> to avail himself / herself <strong>" + row["ForType"].ToString() + @"</strong> the facilities at Lahore Gymkhana, You are requested to make payment through ""DEBIT / CREDIT Card"", Please.
        </div>

        <div class='signature-area'>
            <div class='sig-box'>
                <br/><br/>
                Secretary
            </div>
        </div>

        <!-- Detailed Card Info -->
        <div class='info-card'>
            <div class='info-card-title'>AFFILIATED CLUB MEMBER CARD</div>
            <table class='card-table'>
                <tr>
                    <td class='label'>Letter No</td>
                    <td class='separator'>:</td>
                    <td>" + row["IntroductoryNo"].ToString() + @"</td>
                </tr>
                <tr>
                    <td class='label'>Club Name</td>
                    <td class='separator'>:</td>
                    <td>" + row["ClubName"].ToString() + @"</td>
                </tr>
                <tr>
                    <td class='label'>Club's Mem No</td>
                    <td class='separator'>:</td>
                    <td>" + row["MemberNo"].ToString() + @"</td>
                </tr>
                <tr>
                    <td class='label'>Guest Name</td>
                    <td class='separator'>:</td>
                    <td>" + row["MemberName"].ToString().ToUpper() + @"</td>
                </tr>
                <tr>
                    <td class='label'>Reference No</td>
                    <td class='separator'>:</td>
                    <td>" + row["RefNo"].ToString() + @"</td>
                </tr>
                <tr>
                    <td class='label'>Issued For</td>
                    <td class='separator'>:</td>
                    <td>" + row["ForType"].ToString() + @"</td>
                </tr>
                <tr>
                    <td class='label'>Issuance On</td>
                    <td class='separator'>:</td>
                    <td>" + Convert.ToDateTime(row["DateFrom"]).ToString("dd/MM/yyyy") + @"</td>
                </tr>
                <tr>
                    <td class='label'>Valid Upto</td>
                    <td class='separator'>:</td>
                    <td>" + Convert.ToDateTime(row["DateTo"]).ToString("dd/MM/yyyy") + @"</td>
                </tr>
                <tr>
                    <td class='label'>Days</td>
                    <td class='separator'>:</td>
                    <td>" + row["Days"].ToString() + @"</td>
                </tr>
                <tr>
                    <td class='label'>Contact</td>
                    <td class='separator'>:</td>
                    <td>" + row["Mobile"].ToString() + @"</td>
                </tr>
                <tr>
                    <td class='label'>Remarks</td>
                    <td class='separator'>:</td>
                    <td>" + row["Remarks"].ToString() + @"</td>
                </tr>
                <tr>
                    <td class='label'>Prepaired By</td>
                    <td class='separator'>:</td>
                    <td>" + preparedBy + @"</td>
                </tr>
                <tr>
                    <td class='label'>Date/Time</td>
                    <td class='separator'>:</td>
                    <td>" + printDateTime + @"</td>
                </tr>
            </table>
        </div>

        <!-- Final Signature Area at the bottom -->
        <div class='signature-area' style='margin-top: auto;'>
            <div class='sig-box'>
                <br/><br/>
                Secretary
            </div>
        </div>

        <div class='footer'>
            <div>" + preparedBy + " " + printDateTime + @"</div>
            <div style='text-align: right;'>Page 1 of 1</div>
        </div>
    </div>
</body>
</html>");

            Response.Clear();
            Response.ContentType = "text/html";
            Response.Write(html.ToString());
            Response.End();
        }
    }

    private void ClearForm()
    {
        hfId.Value = "0";
        txtMemberNo.Text = "";
        txtMemberName.Text = "";
        ddlClub.SelectedIndex = 0;
        rblFor.SelectedValue = "Self";
        txtRefNo.Text = "";
        txtDateFrom.Text = DateTime.Now.ToString("yyyy-MM-dd");
        txtDays.Text = "1";
        txtDateTo.Text = "";
        txtRemarks.Text = "";
        txtAddr1.Text = "";
        txtAddr2.Text = "";
        ddlCity.SelectedIndex = 0;
        ddlCountry.SelectedIndex = 0;
        txtTel.Text = "";
        txtMobile.Text = "";
        txtEmail.Text = "";
        txtFax.Text = "";
        txtCnic.Text = "";
        chkIsActive.Checked = true;
        btnSave.Text = "Save Details";
        GenerateIntroductoryNo();
    }

    private void ShowMessage(string msg, bool success)
    {
        lblMsg.Text = msg;
        lblMsg.CssClass = success ? "msg-success" : "msg-error";
        lblMsg.Visible = true;
    }

    private bool ValidateVisitRestrictions(int id, string memberNo, int clubId, DateTime dateFrom, int days, out string errorMessage)
    {
        errorMessage = string.Empty;
        int proposedYear = dateFrom.Year;
        int proposedMonth = dateFrom.Month;

        int maxDaysPerMonth = 15;
        int maxTransactionsPerMonth = 15;
        int maxVisitsPerYear = 3;

        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();

            // 1. Fetch the club's configured limits
            string queryLimits = "SELECT MaxDaysPerMonth, MaxTransactionsPerMonth, MaxVisitsPerYear FROM AffiliatedClubs WHERE Id = @ClubId";
            using (SqlCommand cmd = new SqlCommand(queryLimits, con))
            {
                cmd.Parameters.AddWithValue("@ClubId", clubId);
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        maxDaysPerMonth = dr["MaxDaysPerMonth"] != DBNull.Value ? Convert.ToInt32(dr["MaxDaysPerMonth"]) : 15;
                        maxTransactionsPerMonth = dr["MaxTransactionsPerMonth"] != DBNull.Value ? Convert.ToInt32(dr["MaxTransactionsPerMonth"]) : 15;
                        maxVisitsPerYear = dr["MaxVisitsPerYear"] != DBNull.Value ? Convert.ToInt32(dr["MaxVisitsPerYear"]) : 3;
                    }
                }
            }

            // 2. Validate maximum days in a calendar month
            string queryDays = @"
                SELECT COALESCE(SUM(Days), 0) 
                FROM IncomingClubMembers 
                WHERE MemberNo = @MemberNo 
                  AND ClubId = @ClubId 
                  AND YEAR(DateFrom) = @Year 
                  AND MONTH(DateFrom) = @Month
                  AND (@Id = 0 OR Id <> @Id)";
            
            int existingDays = 0;
            using (SqlCommand cmd = new SqlCommand(queryDays, con))
            {
                cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                cmd.Parameters.AddWithValue("@ClubId", clubId);
                cmd.Parameters.AddWithValue("@Year", proposedYear);
                cmd.Parameters.AddWithValue("@Month", proposedMonth);
                cmd.Parameters.AddWithValue("@Id", id);
                existingDays = (int)cmd.ExecuteScalar();
            }

            if (existingDays + days > maxDaysPerMonth)
            {
                errorMessage = string.Format("Stay limit exceeded: This member has already stayed {0} days in {1:MMMM yyyy}. Proposed stay of {2} days would exceed the maximum limit of {3} days per month for this club.", existingDays, dateFrom, days, maxDaysPerMonth);
                return false;
            }

            // 3. Validate maximum transactions/visits in a calendar month
            string queryMonthTx = @"
                SELECT COUNT(*) 
                FROM IncomingClubMembers 
                WHERE MemberNo = @MemberNo 
                  AND ClubId = @ClubId 
                  AND YEAR(DateFrom) = @Year 
                  AND MONTH(DateFrom) = @Month
                  AND (@Id = 0 OR Id <> @Id)";

            int existingMonthTx = 0;
            using (SqlCommand cmd = new SqlCommand(queryMonthTx, con))
            {
                cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                cmd.Parameters.AddWithValue("@ClubId", clubId);
                cmd.Parameters.AddWithValue("@Year", proposedYear);
                cmd.Parameters.AddWithValue("@Month", proposedMonth);
                cmd.Parameters.AddWithValue("@Id", id);
                existingMonthTx = (int)cmd.ExecuteScalar();
            }

            if (existingMonthTx + 1 > maxTransactionsPerMonth)
            {
                errorMessage = string.Format("Monthly visit limit exceeded: This member has already registered {0} visits in {1:MMMM yyyy}, exceeding the maximum limit of {2} visits per month for this club.", existingMonthTx, dateFrom, maxTransactionsPerMonth);
                return false;
            }

            // 4. Validate maximum visits in a calendar year (Jan to Dec)
            string queryYearVisits = @"
                SELECT COUNT(*) 
                FROM IncomingClubMembers 
                WHERE MemberNo = @MemberNo 
                  AND ClubId = @ClubId 
                  AND YEAR(DateFrom) = @Year
                  AND (@Id = 0 OR Id <> @Id)";

            int existingYearVisits = 0;
            using (SqlCommand cmd = new SqlCommand(queryYearVisits, con))
            {
                cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                cmd.Parameters.AddWithValue("@ClubId", clubId);
                cmd.Parameters.AddWithValue("@Year", proposedYear);
                cmd.Parameters.AddWithValue("@Id", id);
                existingYearVisits = (int)cmd.ExecuteScalar();
            }

            if (existingYearVisits + 1 > maxVisitsPerYear)
            {
                errorMessage = string.Format("Annual visit limit exceeded: This member has already registered {0} visits in the calendar year {1}, exceeding the maximum limit of {2} visits per year for this club.", existingYearVisits, proposedYear, maxVisitsPerYear);
                return false;
            }
        }

        return true;
    }
}
