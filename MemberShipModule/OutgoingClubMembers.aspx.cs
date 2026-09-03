using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class OutgoingClubMembers : System.Web.UI.Page
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
            con.Open();
            string sql = @"
                IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='OutgoingClubMembers')
                BEGIN
                    CREATE TABLE OutgoingClubMembers (
                        Id INT IDENTITY(1,1) PRIMARY KEY,
                        IntroductoryNo NVARCHAR(50) UNIQUE,
                        MemberNo NVARCHAR(50),
                        MemberName NVARCHAR(200),
                        ClubId INT,
                        ForType NVARCHAR(50),
                        RefNo NVARCHAR(50),
                        DateFrom DATETIME,
                        Days INT,
                        DateTo DATETIME,
                        Remarks NVARCHAR(MAX),
                        Address1 NVARCHAR(200),
                        Address2 NVARCHAR(200),
                        City NVARCHAR(100),
                        Country NVARCHAR(100),
                        Tel NVARCHAR(50),
                        Mobile NVARCHAR(50),
                        Email NVARCHAR(100),
                        Fax NVARCHAR(50),
                        NTN_CNIC NVARCHAR(50),
                        IsActive BIT DEFAULT 1,
                        CreatedBy NVARCHAR(100),
                        CreatedAt DATETIME DEFAULT GETDATE()
                    );
                END";
            using (SqlCommand cmd = new SqlCommand(sql, con))
                cmd.ExecuteNonQuery();
        }
    }

    private void BindDropdowns()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            SqlDataAdapter daClubs = new SqlDataAdapter("SELECT Id, ClubName FROM AffiliatedClubs WHERE Status = 1 ORDER BY ClubName", con);
            DataTable dtClubs = new DataTable();
            daClubs.Fill(dtClubs);
            ddlClub.DataSource = dtClubs;
            ddlClub.DataTextField = "ClubName";
            ddlClub.DataValueField = "Id";
            ddlClub.DataBind();
            ddlClub.Items.Insert(0, new ListItem("-- Select Destination Club --", "0"));
        }
    }

    private void BindGrid()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            string sql = @"
                SELECT ocm.*, ac.ClubName 
                FROM OutgoingClubMembers ocm
                LEFT JOIN AffiliatedClubs ac ON ocm.ClubId = ac.Id
                ORDER BY ocm.CreatedAt DESC";
            SqlDataAdapter da = new SqlDataAdapter(sql, con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            gvOutgoing.DataSource = dt;
            gvOutgoing.DataBind();
        }
    }

    private void GenerateIntroductoryNo()
    {
        if (hfId.Value != "0") return;

        using (SqlConnection con = new SqlConnection(connStr))
        {
            string datePart = DateTime.Now.ToString("yyyyMMdd");
            string prefix = "OUT-LC-" + datePart + "-";
            
            SqlCommand cmd = new SqlCommand("SELECT TOP 1 IntroductoryNo FROM OutgoingClubMembers WHERE IntroductoryNo LIKE @Prefix + '%' ORDER BY Id DESC", con);
            cmd.Parameters.AddWithValue("@Prefix", prefix);
            
            con.Open();
            object result = cmd.ExecuteScalar();
            int nextNo = 1;
            
            if (result != null)
            {
                string lastNo = result.ToString();
                int dashIdx = lastNo.LastIndexOf('-');
                if (dashIdx > 0)
                {
                    int.TryParse(lastNo.Substring(dashIdx + 1), out nextNo);
                    nextNo++;
                }
            }
            
            txtIntroNo.Text = prefix + nextNo.ToString("D4");
        }
    }

    protected void txtMemberNo_TextChanged(object sender, EventArgs e)
    {
        string mNo = txtMemberNo.Text.Trim();
        if (string.IsNullOrEmpty(mNo)) return;

        using (SqlConnection con = new SqlConnection(connStr))
        {
            string sql = "SELECT TOP 1 MemberName, Status FROM MemberProfile WHERE MemberNo = @MemberNo";
            SqlCommand cmd = new SqlCommand(sql, con);
            cmd.Parameters.AddWithValue("@MemberNo", mNo);
            con.Open();
            SqlDataReader dr = cmd.ExecuteReader();
            if (dr.Read())
            {
                string status = dr["Status"] != DBNull.Value ? dr["Status"].ToString().Trim() : "";
                
                // VALIDATION: Active and Absentee allowed
                if (status.Equals("Active", StringComparison.OrdinalIgnoreCase) || 
                    status.Equals("Absentee", StringComparison.OrdinalIgnoreCase))
                {
                    txtMemberName.Text = dr["MemberName"].ToString();
                    lblMsg.Visible = false;
                }
                else
                {
                    txtMemberName.Text = "";
                    txtMemberNo.Text = "";
                    ShowMessage("Validation Error: Member status is '" + (string.IsNullOrEmpty(status) ? "NULL" : status) + "'. Only Active or Absentee members are allowed.", false);
                }
            }
            else
            {
                txtMemberName.Text = "";
                ShowMessage("Error: Member No '" + mNo + "' not found in profiles.", false);
            }
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(txtMemberNo.Text) || string.IsNullOrEmpty(txtMemberName.Text) || ddlClub.SelectedValue == "0")
        {
            ShowMessage("Member No, Name, and Destination Club are required.", false);
            return;
        }

        int id = 0;
        int.TryParse(hfId.Value, out id);
        
        DateTime dateFrom = DateTime.Parse(txtDateFrom.Text);
        int days = int.Parse(txtDays.Text);
        DateTime dateTo = dateFrom.AddDays(days - 1);

        int newId = 0;
        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            SqlCommand cmd;
            
            if (id > 0)
            {
                cmd = new SqlCommand(@"
                    UPDATE OutgoingClubMembers SET 
                        MemberNo = @MemberNo, MemberName = @MemberName, ClubId = @ClubId, 
                        ForType = @ForType, DateFrom = @DateFrom, Days = @Days, DateTo = @DateTo, 
                        Remarks = @Remarks, IsActive = @IsActive
                    WHERE Id = @Id; SELECT @Id;", con);
                cmd.Parameters.AddWithValue("@Id", id);
                newId = id;
            }
            else
            {
                GenerateIntroductoryNo(); 
                cmd = new SqlCommand(@"
                    INSERT INTO OutgoingClubMembers (
                        IntroductoryNo, MemberNo, MemberName, ClubId, ForType, DateFrom, Days, DateTo, 
                        Remarks, IsActive, CreatedBy
                    ) VALUES (
                        @IntroNo, @MemberNo, @MemberName, @ClubId, @ForType, @DateFrom, @Days, @DateTo, 
                        @Remarks, @IsActive, @CreatedBy
                    ); SELECT SCOPE_IDENTITY();", con);
                cmd.Parameters.AddWithValue("@IntroNo", txtIntroNo.Text);
                cmd.Parameters.AddWithValue("@CreatedBy", Session["Emp_Name"] ?? "System");
            }

            cmd.Parameters.AddWithValue("@MemberNo", txtMemberNo.Text.Trim());
            cmd.Parameters.AddWithValue("@MemberName", txtMemberName.Text.Trim());
            cmd.Parameters.AddWithValue("@ClubId", ddlClub.SelectedValue);
            cmd.Parameters.AddWithValue("@ForType", rblFor.SelectedValue);
            cmd.Parameters.AddWithValue("@DateFrom", dateFrom);
            cmd.Parameters.AddWithValue("@Days", days);
            cmd.Parameters.AddWithValue("@DateTo", dateTo);
            cmd.Parameters.AddWithValue("@Remarks", txtRemarks.Text.Trim());
            cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);

            object result = cmd.ExecuteScalar();
            if (id == 0 && result != null) newId = Convert.ToInt32(result);
        }

        ShowMessage("Record saved successfully.", true);
        
        // Auto-open print
        string printUrl = "OutgoingClubMembers.aspx?print=true&id=" + newId;
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
            string printUrl = "OutgoingClubMembers.aspx?print=true&id=" + id;
            string script = "setTimeout(function() { window.open('" + printUrl + "', '_blank'); }, 100);";
            ScriptManager.RegisterStartupScript(this, GetType(), "PrintReport", script, true);
        }
        else
        {
            ShowMessage("Please select or save a record first to print.", false);
        }
    }

    protected void gvOutgoing_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int id = Convert.ToInt32(e.CommandArgument);
        
        if (e.CommandName == "EditItem")
        {
            LoadRecord(id);
        }
        else if (e.CommandName == "PrintItem")
        {
            string printUrl = "OutgoingClubMembers.aspx?print=true&id=" + id;
            string script = "setTimeout(function() { window.open('" + printUrl + "', '_blank'); }, 100);";
            ScriptManager.RegisterStartupScript(this, GetType(), "PrintReport", script, true);
        }
    }

    private void LoadRecord(int id)
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            SqlCommand cmd = new SqlCommand("SELECT * FROM OutgoingClubMembers WHERE Id = @Id", con);
            cmd.Parameters.AddWithValue("@Id", id);
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
                txtDateFrom.Text = Convert.ToDateTime(dr["DateFrom"]).ToString("yyyy-MM-dd");
                txtDays.Text = dr["Days"].ToString();
                txtDateTo.Text = Convert.ToDateTime(dr["DateTo"]).ToString("dd-MM-yyyy");
                txtRemarks.Text = dr["Remarks"].ToString();
                chkIsActive.Checked = Convert.ToBoolean(dr["IsActive"]);
                btnSave.Text = "Update Details";
            }
        }
    }

    private void GeneratePrintReport(int id)
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            string sql = @"
                SELECT ocm.*, ac.ClubName, IsNull(ac.ClubAddress, '') as ClubAddress,
                       (SELECT TOP 1 IsNull(Status, 'Active') FROM MemberProfile WHERE MemberNo = ocm.MemberNo) as MemberStatus
                FROM OutgoingClubMembers ocm
                LEFT JOIN AffiliatedClubs ac ON ocm.ClubId = ac.Id
                WHERE ocm.Id = @Id";
            
            SqlCommand cmd = new SqlCommand(sql, con);
            cmd.Parameters.AddWithValue("@Id", id);
            
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            
            if (dt.Rows.Count == 0) return;
            DataRow row = dt.Rows[0];
            
            string logoPath = ResolveUrl("~/MemberShipModule/assets/images/logo for report.jpeg");
            string preparedBy = row["CreatedBy"] != DBNull.Value ? row["CreatedBy"].ToString() : "System";
            string printDateTime = DateTime.Now.ToString("dd/MM/yyyy h:mm:ss tt");
            string displayDate = DateTime.Now.ToString("dd MMMM, yyyy");
            string visitStatus = Convert.ToBoolean(row["IsActive"]) ? "Active" : "InActive";

            System.Text.StringBuilder html = new System.Text.StringBuilder();
            html.Append(@"<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>Introductory Letter - " + row["IntroductoryNo"].ToString() + @"</title>
    <style>
        @page { size: A4; margin: 0; }
        body { font-family: 'Arial', sans-serif; font-size: 13px; margin: 0; padding: 0; color: #000; background: #fff; line-height: 1.2; }
        .report-page { width: 210mm; height: 297mm; padding: 10mm 15mm; margin: auto; box-sizing: border-box; display: flex; flex-direction: column; position: relative; }
        
        /* Header Section */
        .header { display: flex; align-items: center; justify-content: flex-start; gap: 15px; margin-bottom: 5px; }
        .logo { height: 65px; }
        .club-info { flex-grow: 1; }
        .club-info h1 { font-family: 'Times New Roman', serif; font-size: 32px; font-weight: bold; margin: 0; letter-spacing: 1px; }
        .club-info p { font-size: 11px; margin: 1px 0; font-weight: bold; line-height: 1.1; }
        
        .header-divider { border-top: 1px solid #000; border-bottom: 1px solid #000; height: 2px; margin: 5px 0 15px; }

        /* Top Right Meta */
        .top-meta { align-self: flex-end; text-align: right; margin-bottom: 20px; font-size: 13px; }
        .card-no-box { display: inline-block; border: 1px solid #000; padding: 2px 8px; margin-bottom: 4px; font-weight: bold; }

        /* Recipient */
        .recipient { margin-bottom: 20px; font-size: 14px; line-height: 1.4; }
        .recipient div { font-weight: bold; }

        /* Subject */
        .subject { text-align: center; margin: 15px 0; font-size: 15px; font-weight: bold; text-decoration: underline; text-transform: uppercase; }

        /* Letter Content */
        .content { margin-bottom: 60px; text-align: justify; font-size: 14px; line-height: 1.6; }

        /* Signature */
        .signature-row { display: flex; justify-content: flex-end; margin-bottom: 40px; }
        .sig-block { width: 150px; text-align: center; font-weight: bold; font-size: 14px; }

        /* Office Copy Section */
        .office-copy-divider { border-top: 1px dashed #000; margin: 20px 0; }
        .office-header { display: flex; justify-content: center; position: relative; margin-bottom: 15px; }
        .office-header .title { font-size: 15px; font-weight: bold; text-decoration: underline; text-transform: uppercase; }
        .office-header .tag { position: absolute; right: 0; font-size: 15px; font-weight: bold; text-decoration: underline; text-transform: uppercase; }

        /* Data Table */
        .data-table { width: 100%; border-collapse: collapse; margin-bottom: 30px; }
        .data-table td { padding: 3px 0; vertical-align: top; font-size: 13px; font-weight: bold; }
        .data-table .label { width: 140px; }
        .data-table .sep { width: 15px; text-align: center; }

        /* Final Footer */
        .bottom-row { position: absolute; bottom: 8mm; left: 15mm; right: 15mm; display: flex; justify-content: space-between; align-items: flex-end; font-size: 10px; color: #333; }
        .bottom-metadata { font-size: 10px; font-family: 'Courier New', Courier, monospace; }

        @media print { 
            .report-page { border: none; }
            body { background: none; }
        }
    </style>
</head>
<body onload='window.print()'>
    <div class='report-page'>
        <!-- Header -->
        <div class='header'>
            <img src='" + logoPath + @"' class='logo' />
            <div class='club-info'>
                <h1>LAHORE GYMKHANA</h1>
                <p>Upper Shahrah-e-Quaid-e-Azam, Lahore, Pakistan</p>
                <p>Phone: 111-111-231 Email: secretary@lahoregymkhana.org.pk</p>
            </div>
        </div>
        
        <div class='header-divider'></div>

        <!-- Top Right Meta -->
        <div class='top-meta'>
            <div class='card-no-box'>Letter No: " + row["IntroductoryNo"].ToString() + @"</div><br/>
            " + displayDate + @"
        </div>

        <!-- Recipient -->
        <div class='recipient' style='font-weight: bold;'>
            The Secretary,<br/>
            " + row["ClubName"].ToString() + @",<br/>
            " + row["ClubAddress"].ToString() + @"
        </div>

        <!-- Subject -->
        <div class='subject'>INTRODUCTORY LETTER</div>

        <!-- Content -->
        <div class='content'>
            We feel pleasure to introduce <strong>" + row["MemberName"].ToString() + " " + row["ForType"].ToString() + @"</strong>, having Membership No. <strong>" + row["MemberNo"].ToString() + @"</strong>, an honorable Member of Lahore Gymkhana, to avail himself / herself of the facilities of your esteemed Club.
        </div>

        <!-- Signature 1 -->
        <div class='signature-row'>
            <div class='sig-block'>
                <br/><br/>
                Secretary
            </div>
        </div>

        <!-- Office Copy Part -->
        <div class='office-copy-divider'></div>
        
        <div class='office-header'>
            <div class='title'>INTRODUCTORY LETTER</div>
            <div class='tag'>OFFICE COPY</div>
        </div>

        <table class='data-table'>
            <tr><td class='label'>Letter No</td><td class='sep'>:</td><td>" + row["IntroductoryNo"].ToString() + @"</td></tr>
            <tr><td class='label'>Club Name</td><td class='sep'>:</td><td>" + row["ClubName"].ToString() + @"</td></tr>
            <tr><td class='label'>Membership No</td><td class='sep'>:</td><td>" + row["MemberNo"].ToString() + @"</td></tr>
            <tr><td class='label'>Member Name</td><td class='sep'>:</td><td>" + row["MemberName"].ToString() + @"</td></tr>
            <tr><td class='label'>Issuance Date</td><td class='sep'>:</td><td>" + Convert.ToDateTime(row["DateFrom"]).ToString("dd/MM/yyyy") + @"</td></tr>
            <tr><td class='label'>Status</td><td class='sep'>:</td><td>" + visitStatus + @"</td></tr>
            <tr><td class='label'>Balance</td><td class='sep'>:</td><td>0</td></tr>
            <tr><td class='label'>Remarks</td><td class='sep'>:</td><td>" + row["Remarks"].ToString() + @"</td></tr>
            <tr><td class='label'>Issued For</td><td class='sep'>:</td><td>" + row["ForType"].ToString() + @"</td></tr>
            <tr><td class='label'>Prepaired By</td><td class='sep'>:</td><td>" + preparedBy + @"</td></tr>
            <tr><td class='label'>Date/Time</td><td class='sep'>:</td><td>" + printDateTime + @"</td></tr>
        </table>

        <!-- Signature 2 -->
        <div class='signature-row' style='margin-bottom: 20px;'>
            <div class='sig-block'>
                <br/><br/>
                Secretary
            </div>
        </div>

        <!-- Footer Footer -->
        <div class='bottom-row'>
            <div class='bottom-metadata'>
                " + preparedBy + " " + printDateTime + " OP7.2" + @"
            </div>
            <div>Page 1 of 1</div>
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
        txtDateFrom.Text = DateTime.Now.ToString("yyyy-MM-dd");
        txtDays.Text = "1";
        txtDateTo.Text = "";
        txtRemarks.Text = "";
        chkIsActive.Checked = true;
        btnSave.Text = "Save & Print";
        GenerateIntroductoryNo();
    }

    private void ShowMessage(string msg, bool success)
    {
        lblMsg.Text = msg;
        lblMsg.CssClass = success ? "msg-success" : "msg-error";
        lblMsg.Visible = true;
    }
}
