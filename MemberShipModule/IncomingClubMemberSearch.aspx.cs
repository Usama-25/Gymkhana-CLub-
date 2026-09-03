using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class IncomingClubMemberSearch : System.Web.UI.Page
{
    private string connStr
    {
        get { return ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        // Handle Report Request (must be before normal load to avoid HTML corruption)
        if (!string.IsNullOrEmpty(Request.QueryString["viewreport"]))
        {
            string type = Request.QueryString["viewreport"];
            DataTable dt = Session["SearchData"] as DataTable;
            if (dt != null)
            {
                if (type == "list") GenerateListReport(dt, "Incoming Club Members - Visit Report");
                else if (type == "summary") GenerateSummaryReport(dt);
            }
            else
            {
                Response.Write("No data found for report. Please search again.");
                Response.End();
            }
            return;
        }

        if (!IsPostBack)
        {
            BindDropdowns();
            PopulateYears();
        }
    }

    private void BindDropdowns()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            SqlDataAdapter da = new SqlDataAdapter("SELECT Id, ClubName FROM AffiliatedClubs WHERE Status = 1 ORDER BY ClubName", con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            ddlClub.DataSource = dt;
            ddlClub.DataTextField = "ClubName";
            ddlClub.DataValueField = "Id";
            ddlClub.DataBind();
            ddlClub.Items.Insert(0, new ListItem("-- All Clubs --", "0"));
        }
    }

    private void PopulateYears()
    {
        int currentYear = DateTime.Now.Year;
        for (int i = 0; i < 5; i++)
        {
            ddlYear.Items.Add(new ListItem((currentYear - i).ToString(), (currentYear - i).ToString()));
        }
        ddlYear.Items.Insert(0, new ListItem("-- All Years --", "0"));
    }

    private void BindGrid()
    {
        DataTable dt = GetData();
        gvResults.DataSource = dt;
        gvResults.DataBind();
    }

    private DataTable GetData()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            StringBuilder sb = new StringBuilder(@"
                SELECT icm.*, ac.ClubName 
                FROM IncomingClubMembers icm
                LEFT JOIN AffiliatedClubs ac ON icm.ClubId = ac.Id
                WHERE 1=1");

            SqlCommand cmd = new SqlCommand();

            if (!string.IsNullOrEmpty(txtIntroNo.Text))
            {
                sb.Append(" AND icm.IntroductoryNo LIKE @Intro");
                cmd.Parameters.AddWithValue("@Intro", "%" + txtIntroNo.Text.Trim() + "%");
            }
            if (!string.IsNullOrEmpty(txtGuestName.Text))
            {
                sb.Append(" AND icm.MemberName LIKE @Name");
                cmd.Parameters.AddWithValue("@Name", "%" + txtGuestName.Text.Trim() + "%");
            }
            if (!string.IsNullOrEmpty(txtMemberNo.Text))
            {
                sb.Append(" AND icm.MemberNo LIKE @MemNo");
                cmd.Parameters.AddWithValue("@MemNo", "%" + txtMemberNo.Text.Trim() + "%");
            }
            if (ddlClub.SelectedValue != "0")
            {
                sb.Append(" AND icm.ClubId = @ClubId");
                cmd.Parameters.AddWithValue("@ClubId", ddlClub.SelectedValue);
            }
            if (ddlMonth.SelectedValue != "0")
            {
                sb.Append(" AND MONTH(icm.DateFrom) = @Month");
                cmd.Parameters.AddWithValue("@Month", ddlMonth.SelectedValue);
            }
            if (ddlYear.SelectedValue != "0")
            {
                sb.Append(" AND YEAR(icm.DateFrom) = @Year");
                cmd.Parameters.AddWithValue("@Year", ddlYear.SelectedValue);
            }
            if (!string.IsNullOrEmpty(txtDateFrom.Text))
            {
                sb.Append(" AND icm.DateFrom >= @From");
                cmd.Parameters.AddWithValue("@From", DateTime.Parse(txtDateFrom.Text));
            }
            if (!string.IsNullOrEmpty(txtDateTo.Text))
            {
                sb.Append(" AND icm.DateFrom <= @To");
                cmd.Parameters.AddWithValue("@To", DateTime.Parse(txtDateTo.Text));
            }

            sb.Append(" ORDER BY icm.DateFrom DESC");
            cmd.CommandText = sb.ToString();
            cmd.Connection = con;

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            return dt;
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        DataTable dt = GetData();
        Session["SearchData"] = dt; // Store for reports
        gvResults.DataSource = dt;
        gvResults.DataBind();
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        txtIntroNo.Text = "";
        txtGuestName.Text = "";
        txtMemberNo.Text = "";
        ddlClub.SelectedIndex = 0;
        ddlMonth.SelectedIndex = 0;
        ddlYear.SelectedIndex = 0;
        txtDateFrom.Text = "";
        txtDateTo.Text = "";
        BindGrid();
    }

    protected void gvResults_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int id = Convert.ToInt32(e.CommandArgument);
        if (e.CommandName == "EditItem")
        {
            Response.Redirect("IncomingClubMembers.aspx?id=" + id);
        }
        else if (e.CommandName == "PrintItem")
        {
            // Trigger individual print in a way that opens in new tab
            string script = "setTimeout(function() { window.open('IncomingClubMembers.aspx?print=true&id=" + id + "', '_blank'); }, 100);";
            ScriptManager.RegisterStartupScript(this, GetType(), "PrintIndiv", script, true);
        }
    }

    protected void btnPrintList_Click(object sender, EventArgs e)
    {
        if (Session["SearchData"] == null)
        {
            DataTable dt = GetData();
            Session["SearchData"] = dt;
        }
        string script = "setTimeout(function() { window.open('IncomingClubMemberSearch.aspx?viewreport=list', '_blank'); }, 100);";
        ScriptManager.RegisterStartupScript(this, GetType(), "PrintReport", script, true);
    }

    protected void btnPrintSummary_Click(object sender, EventArgs e)
    {
        if (Session["SearchData"] == null)
        {
            DataTable dt = GetData();
            Session["SearchData"] = dt;
        }
        string script = "setTimeout(function() { window.open('IncomingClubMemberSearch.aspx?viewreport=summary', '_blank'); }, 100);";
        ScriptManager.RegisterStartupScript(this, GetType(), "PrintSummary", script, true);
    }

    private void GenerateListReport(DataTable dt, string title)
    {
        string logoPath = ResolveUrl("~/MemberShipModule/assets/images/logo for report.jpeg");
        string preparedBy = Session["Emp_Name"] != null ? Session["Emp_Name"].ToString() : "System";
        string printDateTime = DateTime.Now.ToString("dd/MM/yyyy hh:mm:ss tt");

        StringBuilder html = new StringBuilder();
        html.Append(@"<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>Visit Report</title>
    <style>
        @page { size: A4; margin: 0; }
        body { font-family: 'Arial', sans-serif; font-size: 13px; margin: 0; padding: 0; color: #000; background: #fff; line-height: 1.3; }
        .report-page { width: 210mm; min-height: 297mm; padding: 15mm; margin: auto; box-sizing: border-box; display: flex; flex-direction: column; position: relative; }
        
        .header { display: flex; align-items: flex-start; justify-content: space-between; border-bottom: 2px solid #000; padding-bottom: 6px; margin-bottom: 20px; }
        .header-left { display: flex; align-items: center; gap: 12px; }
        .logo { height: 60px; width: auto; }
        .club-info h1 { font-family: 'Times New Roman', Times, serif; font-size: 26px; font-weight: bold; margin: 0; color: #000; letter-spacing: 0.5px; }
        .club-info p { font-size: 10px; margin: 1px 0; color: #333; font-weight: bold; }
        
        .report-title { text-align: center; margin: 10px 0 20px; font-size: 18px; font-weight: bold; text-decoration: underline; text-transform: uppercase; font-style: italic; }

        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th { background: #f8fafc; padding: 8px; border: 1px solid #000; text-align: left; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        td { padding: 6px 8px; border: 1px solid #000; font-size: 11px; }

        .footer { position: fixed; bottom: 10mm; left: 15mm; right: 15mm; font-size: 9px; color: #333; border-top: 1px solid #ccc; padding-top: 4px; display: flex; justify-content: space-between; }
        
        @media print { body { background: none; } .report-page { border: none; box-shadow: none; margin: 0; } }
    </style>
</head>
<body onload='window.print()'>
    <div class='report-page'>
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

        <div class='report-title'>" + title + @"</div>

        <table>
            <tr>
                <th>Letter No</th>
                <th>Member #</th>
                <th>Guest Name</th>
                <th>Affiliated Club</th>
                <th>From Date</th>
                <th>To Date</th>
                <th>Days</th>
                <th>Status</th>
            </tr>");
        
        foreach (DataRow row in dt.Rows)
        {
            html.Append("<tr>");
            html.Append("<td>" + row["IntroductoryNo"] + "</td>");
            html.Append("<td>" + row["MemberNo"] + "</td>");
            html.Append("<td>" + row["MemberName"] + "</td>");
            html.Append("<td>" + row["ClubName"] + "</td>");
            html.Append("<td>" + Convert.ToDateTime(row["DateFrom"]).ToString("dd-MMM-yyyy") + "</td>");
            html.Append("<td>" + Convert.ToDateTime(row["DateTo"]).ToString("dd-MMM-yyyy") + "</td>");
            html.Append("<td>" + row["Days"] + "</td>");
            html.Append("<td>" + (Convert.ToBoolean(row["IsActive"]) ? "Active" : "Closed") + "</td>");
            html.Append("</tr>");
        }
        
        html.Append("</table>");
        
        html.Append(@"<div class='footer'>
            <div>" + preparedBy + " " + printDateTime + @"</div>
            <div style='text-align: right;'>Page 1 of 1</div>
        </div>
    </div>
</body>
</html>");

        Response.Clear();
        Response.Write(html.ToString());
        Response.End();
    }

    private void GenerateSummaryReport(DataTable dt)
    {
        string logoPath = ResolveUrl("~/MemberShipModule/assets/images/logo for report.jpeg");
        string preparedBy = Session["Emp_Name"] != null ? Session["Emp_Name"].ToString() : "System";
        string printDateTime = DateTime.Now.ToString("dd/MM/yyyy hh:mm:ss tt");

        // Group by Club
        var clubs = new System.Collections.Generic.Dictionary<string, int>();
        foreach (DataRow row in dt.Rows)
        {
            string club = row["ClubName"].ToString();
            if (clubs.ContainsKey(club)) clubs[club]++;
            else clubs[club] = 1;
        }

        StringBuilder html = new StringBuilder();
        html.Append(@"<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>Summary Report</title>
    <style>
        @page { size: A4; margin: 0; }
        body { font-family: 'Arial', sans-serif; font-size: 13px; margin: 0; padding: 0; color: #000; background: #fff; line-height: 1.3; }
        .report-page { width: 210mm; min-height: 297mm; padding: 15mm; margin: auto; box-sizing: border-box; display: flex; flex-direction: column; position: relative; }
        
        .header { display: flex; align-items: flex-start; justify-content: space-between; border-bottom: 2px solid #000; padding-bottom: 6px; margin-bottom: 20px; }
        .header-left { display: flex; align-items: center; gap: 12px; }
        .logo { height: 60px; width: auto; }
        .club-info h1 { font-family: 'Times New Roman', Times, serif; font-size: 26px; font-weight: bold; margin: 0; color: #000; letter-spacing: 0.5px; }
        .club-info p { font-size: 10px; margin: 1px 0; color: #333; font-weight: bold; }
        
        .report-title { text-align: center; margin: 10px 0 20px; font-size: 18px; font-weight: bold; text-decoration: underline; text-transform: uppercase; font-style: italic; }

        table { width: 60%; margin: 20px auto; border-collapse: collapse; }
        th { background: #f8fafc; padding: 10px; border: 1px solid #000; text-align: left; font-size: 12px; font-weight: bold; }
        td { padding: 10px; border: 1px solid #000; font-size: 12px; }
        .total { font-weight: bold; background: #f1f5f9; }

        .footer { position: fixed; bottom: 10mm; left: 15mm; right: 15mm; font-size: 9px; color: #333; border-top: 1px solid #ccc; padding-top: 4px; display: flex; justify-content: space-between; }
        
        @media print { body { background: none; } .report-page { border: none; box-shadow: none; margin: 0; } }
    </style>
</head>
<body onload='window.print()'>
    <div class='report-page'>
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

        <div class='report-title'>Clubwise Visit Summary</div>

        <table>
            <tr>
                <th>Affiliated Club Name</th>
                <th>Total Visits</th>
            </tr>");
        
        int totalSum = 0;
        foreach (var entry in clubs)
        {
            html.Append("<tr><td>" + entry.Key + "</td><td>" + entry.Value + "</td></tr>");
            totalSum += entry.Value;
        }
        
        html.Append("<tr class='total'><td>GRAND TOTAL</td><td>" + totalSum + "</td></tr>");
        html.Append(@"</table>
        
        <div class='footer'>
            <div>" + preparedBy + " " + printDateTime + @"</div>
            <div style='text-align: right;'>Page 1 of 1</div>
        </div>
    </div>
</body>
</html>");

        Response.Clear();
        Response.Write(html.ToString());
        Response.End();
    }
}
