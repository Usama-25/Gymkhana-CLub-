using System.Configuration;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;

public partial class Pages_Reports_Reports : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        pnlAlert.Visible = false;
        if (!IsPostBack)
        {
            // Initialize default date range filters (last 60 days to today to ensure historical transaction data shows)
            DateTime today = DateTime.Today;
            DateTime fromDate = today.AddDays(-60);
            
            string fromDateStr = fromDate.ToString("yyyy-MM-dd");
            string toDateStr = today.ToString("yyyy-MM-dd");

            txtIssuanceFrom.Text = fromDateStr;
            txtIssuanceTo.Text = toDateStr;
            txtFinesFrom.Text = fromDateStr;
            txtFinesTo.Text = toDateStr;
            txtReservationsFrom.Text = fromDateStr;
            txtReservationsTo.Text = toDateStr;

            // Load lookups
            LoadLanguages();
            LoadLanguagesText(ddlAuthorLanguage);
            LoadLanguagesText(ddlPublisherLanguage);
            LoadLanguagesText(ddlEditionLanguage);
            LoadLanguagesText(ddlBooksLanguage);

            LoadCategories(ddlAuthorCategory);
            LoadCategories(ddlPublisherCategory);
            LoadCategories(ddlEditionCategory);
            LoadCategories(ddlLanguageCategory);
            LoadCategories(ddlBooksCategory);

            LoadStaff(ddlIssuanceStaff);
            LoadStaff(ddlIssuedNotReturnedStaff);

            LoadHalls(ddlShelfHall);
        }
    }

    [WebMethod]
    public static object GetMemberSuggestions(string term)
    {
        DataTable dt = DBHelper.GetMembers(term);
        var list = new System.Collections.Generic.List<object>();
        foreach (DataRow row in dt.Rows)
        {
            list.Add(new {
                id = row["MemberID"],
                label = row["MemberDisplay"].ToString()
            });
        }
        return list;
    }

    [WebMethod]
    public static object GetAuthorSuggestions(string term)
    {
        DataTable dt = DBHelper.GetTableData("SELECT TOP 100 AuthorID, FullName FROM Authors WHERE IsActive = 1 AND FullName LIKE '%" + term.Replace("'", "''") + "%' ORDER BY FullName");
        var list = new System.Collections.Generic.List<object>();
        foreach (DataRow row in dt.Rows)
        {
            list.Add(new {
                id = row["AuthorID"],
                label = row["FullName"].ToString()
            });
        }
        return list;
    }

    [WebMethod]
    public static object GetPublisherSuggestions(string term)
    {
        DataTable dt = DBHelper.GetTableData("SELECT TOP 100 PubID, PubName FROM Publishers WHERE IsActive = 1 AND PubName LIKE '%" + term.Replace("'", "''") + "%' ORDER BY PubName");
        var list = new System.Collections.Generic.List<object>();
        foreach (DataRow row in dt.Rows)
        {
            list.Add(new {
                id = row["PubID"],
                label = row["PubName"].ToString()
            });
        }
        return list;
    }

    [WebMethod]
    public static object GetBookSuggestions(string term)
    {
        string safeTerm = (term ?? "").Replace("'", "''");
        DataTable dt = DBHelper.GetTableData("SELECT TOP 30 BookID, Title, DDC FROM Books WHERE IsActive = 1 AND (Title LIKE '%" + safeTerm + "%' OR ISBN13 LIKE '%" + safeTerm + "%' OR DDC LIKE '%" + safeTerm + "%') ORDER BY Title");
        var list = new System.Collections.Generic.List<object>();
        foreach (DataRow row in dt.Rows)
        {
            list.Add(new {
                id = row["BookID"],
                label = row["Title"].ToString() + (row["DDC"] != DBNull.Value && !string.IsNullOrEmpty(row["DDC"].ToString()) ? " [" + row["DDC"].ToString() + "]" : "")
            });
        }
        return list;
    }


    private void LoadLanguages()
    {
        try
        {
            ddlLanguageFilter.Items.Clear();
            DataTable dt = DBHelper.GetLanguages();
            ddlLanguageFilter.DataSource = dt;
            ddlLanguageFilter.DataTextField = "LangName";
            ddlLanguageFilter.DataValueField = "LangID";
            ddlLanguageFilter.DataBind();
            ddlLanguageFilter.Items.Insert(0, new ListItem("-- All Languages --", ""));
        }
        catch (Exception ex)
        {
            ShowAlert("Error loading languages list: " + ex.Message, false);
        }
    }

    private void LoadLanguagesText(DropDownList ddl)
    {
        try
        {
            ddl.Items.Clear();
            DataTable dt = DBHelper.GetLanguages();
            ddl.DataSource = dt;
            ddl.DataTextField = "LangName";
            ddl.DataValueField = "LangName";
            ddl.DataBind();
            ddl.Items.Insert(0, new ListItem("-- All Languages --", ""));
        }
        catch (Exception ex)
        {
            ShowAlert("Error loading languages list: " + ex.Message, false);
        }
    }

    private void LoadCategories(DropDownList ddl)
    {
        try
        {
            ddl.Items.Clear();
            DataTable dt = DBHelper.GetCategories();
            ddl.DataSource = dt;
            ddl.DataTextField = "CatName";
            ddl.DataValueField = "CatName";
            ddl.DataBind();
            ddl.Items.Insert(0, new ListItem("-- All Categories --", ""));
        }
        catch (Exception ex)
        {
            ShowAlert("Error loading categories list: " + ex.Message, false);
        }
    }

    private void LoadStaff(DropDownList ddl)
    {
        try
        {
            ddl.Items.Clear();
            DataTable dt = DBHelper.GetStaffList();
            ddl.DataSource = dt;
            ddl.DataTextField = "FullName";
            ddl.DataValueField = "FullName";
            ddl.DataBind();
            ddl.Items.Insert(0, new ListItem("-- All Staff --", ""));
        }
        catch (Exception ex)
        {
            ShowAlert("Error loading staff list: " + ex.Message, false);
        }
    }

    private void LoadHalls(DropDownList ddl)
    {
        try
        {
            ddl.Items.Clear();
            DataTable dt = DBHelper.GetHalls();
            ddl.DataSource = dt;
            ddl.DataTextField = "HallDisplay";
            ddl.DataValueField = "HallDisplay";
            ddl.DataBind();
            ddl.Items.Insert(0, new ListItem("-- All Halls --", ""));
        }
        catch (Exception ex)
        {
            ShowAlert("Error loading halls list: " + ex.Message, false);
        }
    }

    private DataTable FormatReportDataTable(DataTable dt)
    {
        if (dt == null) return null;

        var colsToRemove = new System.Collections.Generic.List<string>();
        foreach (DataColumn col in dt.Columns)
        {
            string name = col.ColumnName.ToLower();
            if (name.EndsWith("id") && !name.EndsWith("paid"))
            {
                colsToRemove.Add(col.ColumnName);
            }
        }
        foreach (string colName in colsToRemove)
        {
            dt.Columns.Remove(colName);
        }

        // Add SR# at the beginning
        if (!dt.Columns.Contains("SR#"))
        {
            DataColumn srCol = new DataColumn("SR#", typeof(int));
            dt.Columns.Add(srCol);
            srCol.SetOrdinal(0);
        }

        for (int i = 0; i < dt.Rows.Count; i++)
        {
            dt.Rows[i]["SR#"] = i + 1;
        }

        return dt;
    }

    private void BindReport(GridView gv, DataTable dt, string filterExpression)
    {
        if (dt == null)
        {
            gv.DataSource = null;
            gv.DataBind();
            return;
        }

        if (!string.IsNullOrEmpty(filterExpression))
        {
            DataView dv = new DataView(dt);
            dv.RowFilter = filterExpression;
            dt = dv.ToTable();
        }

        DataTable formatted = FormatReportDataTable(dt);
        gv.DataSource = formatted;
        gv.DataBind();
    }

    private DateTime? ParseDate(string dateText)
    {
        DateTime parsedDate;
        if (DateTime.TryParse(dateText, out parsedDate))
        {
            return parsedDate;
        }
        return null;
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

    // Needed to allow RenderControl to execute without form checking exception
    public override void VerifyRenderingInServerForm(Control control)
    {
        // Confirms that an HtmlForm control is rendered for the specified ASP.NET server control.
    }

    private void ExportGridViewToExcel(GridView gv, string baseName)
    {
        if (gv.Rows.Count == 0)
        {
            ShowAlert("There is no data to export. Generate the report first.", false);
            return;
        }

        try
        {
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=LGC_Library_" + baseName + "_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".xls");
            Response.Charset = "";
            Response.ContentType = "application/vnd.ms-excel";

            using (System.IO.StringWriter sw = new System.IO.StringWriter())
            {
                using (HtmlTextWriter hw = new HtmlTextWriter(sw))
                {
                    // Style it as a decent HTML table for Excel parsing
                    string style = @"<style> 
                        TABLE { border: 1px solid #ccc; font-family: Arial; } 
                        TH { background-color: #0f1e36; color: #ffffff; font-weight: bold; } 
                        TD { mso-number-format:\@; border: 1px solid #eee; } 
                    </style>";
                    Response.Write(style);
                    gv.RenderControl(hw);
                    Response.Write(sw.ToString());
                    Response.End();
                }
            }
        }
        catch (System.Threading.ThreadAbortException)
        {
            // ThreadAbortException is expected when calling Response.End()
        }
        catch (Exception ex)
        {
            ShowAlert("Error exporting to Excel: " + ex.Message, false);
        }
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Report Tab 0: Author-Wise
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    protected void btnGenerateAuthorWise_Click(object sender, EventArgs e)
    {
        try
        {
            int? authorID = null;
            string selectedText = txtAuthorFilter.Text.Trim();
            if (!string.IsNullOrEmpty(selectedText))
            {
                DataTable dtAuthor = DBHelper.GetTableData("SELECT AuthorID FROM Authors WHERE FullName = '" + selectedText.Replace("'", "''") + "' AND IsActive = 1");
                if (dtAuthor.Rows.Count > 0)
                {
                    authorID = Convert.ToInt32(dtAuthor.Rows[0]["AuthorID"]);
                }
            }

            DataTable dt = DBHelper.GetReportAuthorWise(authorID);
            
            System.Text.StringBuilder filter = new System.Text.StringBuilder();
            if (ddlAuthorCategory.SelectedIndex > 0)
            {
                filter.AppendFormat("Category = '{0}'", ddlAuthorCategory.SelectedValue.Replace("'", "''"));
            }
            if (ddlAuthorLanguage.SelectedIndex > 0)
            {
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("Language = '{0}'", ddlAuthorLanguage.SelectedValue.Replace("'", "''"));
            }
            if (!string.IsNullOrEmpty(txtAuthorYear.Text.Trim()))
            {
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("PublishYear = {0}", txtAuthorYear.Text.Trim());
            }
            if (!string.IsNullOrEmpty(txtAuthorTitleKeyword.Text.Trim()))
            {
                string kw = txtAuthorTitleKeyword.Text.Trim().Replace("'", "''");
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("(Title LIKE '%{0}%' OR ISBN13 LIKE '%{0}%')", kw);
            }

            BindReport(gvAuthorWise, dt, filter.ToString());
        }
        catch (Exception ex)
        {
            ShowAlert("Error generating Author report: " + ex.Message, false);
        }
    }

    protected void btnExportAuthorWise_Click(object sender, EventArgs e)
    {
        // Ensure grid has data before exporting
        if (gvAuthorWise.DataSource == null)
        {
            btnGenerateAuthorWise_Click(sender, e);
        }
        ExportGridViewToExcel(gvAuthorWise, "AuthorWise");
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Report Tab 1: Publisher-Wise
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    protected void btnGeneratePublisherWise_Click(object sender, EventArgs e)
    {
        try
        {
            int? pubID = null;
            string selectedText = txtPublisherFilter.Text.Trim();
            if (!string.IsNullOrEmpty(selectedText))
            {
                DataTable dtPub = DBHelper.GetTableData("SELECT PubID FROM Publishers WHERE PubName = '" + selectedText.Replace("'", "''") + "' AND IsActive = 1");
                if (dtPub.Rows.Count > 0)
                {
                    pubID = Convert.ToInt32(dtPub.Rows[0]["PubID"]);
                }
            }

            DataTable dt = DBHelper.GetReportPublisherWise(pubID);

            System.Text.StringBuilder filter = new System.Text.StringBuilder();
            if (ddlPublisherCategory.SelectedIndex > 0)
            {
                filter.AppendFormat("Category = '{0}'", ddlPublisherCategory.SelectedValue.Replace("'", "''"));
            }
            if (ddlPublisherLanguage.SelectedIndex > 0)
            {
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("Language = '{0}'", ddlPublisherLanguage.SelectedValue.Replace("'", "''"));
            }
            if (!string.IsNullOrEmpty(txtPublisherYear.Text.Trim()))
            {
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("PublishYear = {0}", txtPublisherYear.Text.Trim());
            }
            if (!string.IsNullOrEmpty(txtPublisherTitleKeyword.Text.Trim()))
            {
                string kw = txtPublisherTitleKeyword.Text.Trim().Replace("'", "''");
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("(Title LIKE '%{0}%' OR ISBN13 LIKE '%{0}%' OR Authors LIKE '%{0}%')", kw);
            }

            BindReport(gvPublisherWise, dt, filter.ToString());
        }
        catch (Exception ex)
        {
            ShowAlert("Error generating Publisher report: " + ex.Message, false);
        }
    }

    protected void btnExportPublisherWise_Click(object sender, EventArgs e)
    {
        if (gvPublisherWise.DataSource == null)
        {
            btnGeneratePublisherWise_Click(sender, e);
        }
        ExportGridViewToExcel(gvPublisherWise, "PublisherWise");
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Report Tab 2: Edition-Wise
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    protected void btnGenerateEditionWise_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable dt = DBHelper.GetReportEditionWise();

            System.Text.StringBuilder filter = new System.Text.StringBuilder();
            if (!string.IsNullOrEmpty(txtEditionFilter.Text.Trim()))
            {
                filter.AppendFormat("Edition LIKE '%{0}%'", txtEditionFilter.Text.Trim().Replace("'", "''"));
            }
            if (ddlEditionCategory.SelectedIndex > 0)
            {
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("Category = '{0}'", ddlEditionCategory.SelectedValue.Replace("'", "''"));
            }
            if (ddlEditionLanguage.SelectedIndex > 0)
            {
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("Language = '{0}'", ddlEditionLanguage.SelectedValue.Replace("'", "''"));
            }
            if (!string.IsNullOrEmpty(txtEditionKeyword.Text.Trim()))
            {
                string kw = txtEditionKeyword.Text.Trim().Replace("'", "''");
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("(Title LIKE '%{0}%' OR ISBN13 LIKE '%{0}%' OR Authors LIKE '%{0}%' OR Publisher LIKE '%{0}%')", kw);
            }

            BindReport(gvEditionWise, dt, filter.ToString());
        }
        catch (Exception ex)
        {
            ShowAlert("Error generating Edition report: " + ex.Message, false);
        }
    }

    protected void btnExportEditionWise_Click(object sender, EventArgs e)
    {
        if (gvEditionWise.DataSource == null)
        {
            btnGenerateEditionWise_Click(sender, e);
        }
        ExportGridViewToExcel(gvEditionWise, "EditionWise");
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Report Tab 3: Language-Wise
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    protected void btnGenerateLanguageWise_Click(object sender, EventArgs e)
    {
        try
        {
            byte? langID = null;
            if (!string.IsNullOrEmpty(ddlLanguageFilter.SelectedValue))
            {
                langID = Convert.ToByte(ddlLanguageFilter.SelectedValue);
            }

            DataTable dt = DBHelper.GetReportLanguageWise(langID);

            System.Text.StringBuilder filter = new System.Text.StringBuilder();
            if (ddlLanguageCategory.SelectedIndex > 0)
            {
                filter.AppendFormat("Category = '{0}'", ddlLanguageCategory.SelectedValue.Replace("'", "''"));
            }
            if (!string.IsNullOrEmpty(txtLanguagePublisherFilter.Text.Trim()))
            {
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("Publisher LIKE '%{0}%'", txtLanguagePublisherFilter.Text.Trim().Replace("'", "''"));
            }
            if (!string.IsNullOrEmpty(txtLanguageKeyword.Text.Trim()))
            {
                string kw = txtLanguageKeyword.Text.Trim().Replace("'", "''");
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("(Title LIKE '%{0}%' OR ISBN13 LIKE '%{0}%' OR Authors LIKE '%{0}%')", kw);
            }

            BindReport(gvLanguageWise, dt, filter.ToString());
        }
        catch (Exception ex)
        {
            ShowAlert("Error generating Language report: " + ex.Message, false);
        }
    }

    protected void btnExportLanguageWise_Click(object sender, EventArgs e)
    {
        if (gvLanguageWise.DataSource == null)
        {
            btnGenerateLanguageWise_Click(sender, e);
        }
        ExportGridViewToExcel(gvLanguageWise, "LanguageWise");
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Report Tab 4: Book Issuance
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    protected void btnGenerateBookIssuance_Click(object sender, EventArgs e)
    {
        try
        {
            DateTime? from = ParseDate(txtIssuanceFrom.Text);
            DateTime? to = ParseDate(txtIssuanceTo.Text);
            DataTable dt = DBHelper.GetReportBookIssuance(from, to);

            System.Text.StringBuilder filter = new System.Text.StringBuilder();
            if (!string.IsNullOrEmpty(txtIssuanceNoFilter.Text.Trim()))
            {
                filter.AppendFormat("LoanID = {0}", txtIssuanceNoFilter.Text.Trim());
            }
            if (!string.IsNullOrEmpty(txtIssuanceMemberFilter.Text.Trim()))
            {
                string mKey = txtIssuanceMemberFilter.Text.Trim();
                if (mKey.Contains(" - "))
                {
                    mKey = mKey.Substring(0, mKey.IndexOf(" - ")).Trim();
                }
                mKey = mKey.Replace("'", "''");
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("(MemberName LIKE '%{0}%' OR MembershipNo LIKE '%{0}%')", mKey);
            }
            if (!string.IsNullOrEmpty(txtIssuanceBookKeyword.Text.Trim()))
            {
                string kw = txtIssuanceBookKeyword.Text.Trim().Replace("'", "''");
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("(Title LIKE '%{0}%' OR Barcode LIKE '%{0}%' OR ISBN13 LIKE '%{0}%')", kw);
            }
            if (ddlIssuanceStatus.SelectedIndex > 0)
            {
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("Status = '{0}'", ddlIssuanceStatus.SelectedValue.Replace("'", "''"));
            }
            if (ddlIssuanceStaff.SelectedIndex > 0)
            {
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("IssuedBy = '{0}'", ddlIssuanceStaff.SelectedValue.Replace("'", "''"));
            }

            BindReport(gvBookIssuance, dt, filter.ToString());
        }
        catch (Exception ex)
        {
            ShowAlert("Error generating Book Issuance report: " + ex.Message, false);
        }
    }

    protected void btnExportBookIssuance_Click(object sender, EventArgs e)
    {
        if (gvBookIssuance.DataSource == null)
        {
            btnGenerateBookIssuance_Click(sender, e);
        }
        ExportGridViewToExcel(gvBookIssuance, "BookIssuance");
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Report Tab 5: Issued Not Returned
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    protected void btnGenerateIssuedNotReturned_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable dt = DBHelper.GetReportIssuedNotReturned();

            System.Text.StringBuilder filter = new System.Text.StringBuilder();
            if (!string.IsNullOrEmpty(txtIssuedNotReturnedMemberFilter.Text.Trim()))
            {
                string mKey = txtIssuedNotReturnedMemberFilter.Text.Trim();
                if (mKey.Contains(" - "))
                {
                    mKey = mKey.Substring(0, mKey.IndexOf(" - ")).Trim();
                }
                mKey = mKey.Replace("'", "''");
                filter.AppendFormat("(MemberName LIKE '%{0}%' OR MembershipNo LIKE '%{0}%')", mKey);
            }
            if (!string.IsNullOrEmpty(txtIssuedNotReturnedBookKeyword.Text.Trim()))
            {
                string kw = txtIssuedNotReturnedBookKeyword.Text.Trim().Replace("'", "''");
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("(Title LIKE '%{0}%' OR Barcode LIKE '%{0}%' OR ISBN13 LIKE '%{0}%')", kw);
            }
            if (ddlIssuedNotReturnedOverdueStatus.SelectedIndex > 0)
            {
                if (filter.Length > 0) filter.Append(" AND ");
                if (ddlIssuedNotReturnedOverdueStatus.SelectedValue == "Overdue")
                {
                    filter.Append("DaysOverdue > 0");
                }
                else
                {
                    filter.Append("DaysOverdue = 0");
                }
            }
            if (ddlIssuedNotReturnedStaff.SelectedIndex > 0)
            {
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("IssuedBy = '{0}'", ddlIssuedNotReturnedStaff.SelectedValue.Replace("'", "''"));
            }

            BindReport(gvIssuedNotReturned, dt, filter.ToString());
        }
        catch (Exception ex)
        {
            ShowAlert("Error generating Issued Not Returned report: " + ex.Message, false);
        }
    }

    protected void btnExportIssuedNotReturned_Click(object sender, EventArgs e)
    {
        if (gvIssuedNotReturned.DataSource == null)
        {
            btnGenerateIssuedNotReturned_Click(sender, e);
        }
        ExportGridViewToExcel(gvIssuedNotReturned, "IssuedNotReturned");
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Report Tab 6: Fine Report
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    protected void btnGenerateFines_Click(object sender, EventArgs e)
    {
        try
        {
            DateTime? from = ParseDate(txtFinesFrom.Text);
            DateTime? to = ParseDate(txtFinesTo.Text);
            bool? paid = null;
            if (ddlFinesStatus.SelectedValue == "1") paid = true;
            else if (ddlFinesStatus.SelectedValue == "0") paid = false;

            DataTable dt = DBHelper.GetReportFines(from, to, paid);

            System.Text.StringBuilder filter = new System.Text.StringBuilder();
            if (!string.IsNullOrEmpty(txtFinesMemberFilter.Text.Trim()))
            {
                string mKey = txtFinesMemberFilter.Text.Trim();
                if (mKey.Contains(" - "))
                {
                    mKey = mKey.Substring(0, mKey.IndexOf(" - ")).Trim();
                }
                mKey = mKey.Replace("'", "''");
                filter.AppendFormat("(MemberName LIKE '%{0}%' OR MembershipNo LIKE '%{0}%')", mKey);
            }
            if (!string.IsNullOrEmpty(txtFinesBookKeyword.Text.Trim()))
            {
                string kw = txtFinesBookKeyword.Text.Trim().Replace("'", "''");
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("(Title LIKE '%{0}%' OR Barcode LIKE '%{0}%')", kw);
            }
            if (ddlFinesReason.SelectedIndex > 0)
            {
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("FineReason = '{0}'", ddlFinesReason.SelectedValue.Replace("'", "''"));
            }
            if (!string.IsNullOrEmpty(txtFinesMinAmount.Text.Trim()))
            {
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("FineAmount >= {0}", txtFinesMinAmount.Text.Trim());
            }

            BindReport(gvFines, dt, filter.ToString());
        }
        catch (Exception ex)
        {
            ShowAlert("Error generating Fine report: " + ex.Message, false);
        }
    }

    protected void btnExportFines_Click(object sender, EventArgs e)
    {
        if (gvFines.DataSource == null)
        {
            btnGenerateFines_Click(sender, e);
        }
        ExportGridViewToExcel(gvFines, "FineReport");
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Report Tab 7: Member-Wise Borrowing
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    protected void btnGenerateMemberWise_Click(object sender, EventArgs e)
    {
        try
        {
            int? memberID = null;
            string selectedText = txtMemberFilter.Text.Trim();
            
            if (!string.IsNullOrEmpty(selectedText))
            {
                string searchKey = selectedText;
                if (searchKey.Contains(" - "))
                {
                    searchKey = searchKey.Substring(0, searchKey.IndexOf(" - ")).Trim();
                }

                DataTable dt = DBHelper.GetMembers(searchKey);
                foreach (DataRow row in dt.Rows)
                {
                    if (row["MemberDisplay"].ToString().Equals(selectedText, StringComparison.OrdinalIgnoreCase))
                    {
                        memberID = Convert.ToInt32(row["MemberID"]);
                        break;
                    }
                }
                
                if (memberID == null)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        if (row["MembershipNo"].ToString().Equals(searchKey, StringComparison.OrdinalIgnoreCase))
                        {
                            memberID = Convert.ToInt32(row["MemberID"]);
                            break;
                        }
                    }
                }
                
                if (memberID == null && dt.Rows.Count > 0)
                {
                    memberID = Convert.ToInt32(dt.Rows[0]["MemberID"]);
                }
            }

            DataTable dtReport = DBHelper.GetReportMemberWise(memberID);

            System.Text.StringBuilder filter = new System.Text.StringBuilder();
            if (memberID != null)
            {
                // Detailed report filters
                if (!string.IsNullOrEmpty(txtMemberBookKeyword.Text.Trim()))
                {
                    string kw = txtMemberBookKeyword.Text.Trim().Replace("'", "''");
                    filter.AppendFormat("(Title LIKE '%{0}%' OR Barcode LIKE '%{0}%')", kw);
                }
                if (!string.IsNullOrEmpty(txtMemberFromDate.Text))
                {
                    DateTime? fDate = ParseDate(txtMemberFromDate.Text);
                    if (fDate != null)
                    {
                        if (filter.Length > 0) filter.Append(" AND ");
                        filter.AppendFormat("IssueDate >= #{0}#", fDate.Value.ToString("yyyy-MM-dd HH:mm:ss"));
                    }
                }
                if (!string.IsNullOrEmpty(txtMemberToDate.Text))
                {
                    DateTime? tDate = ParseDate(txtMemberToDate.Text);
                    if (tDate != null)
                    {
                        if (filter.Length > 0) filter.Append(" AND ");
                        filter.AppendFormat("IssueDate <= #{0}#", tDate.Value.ToString("yyyy-MM-dd 23:59:59"));
                    }
                }
                if (ddlMemberLoanStatus.SelectedIndex > 0)
                {
                    if (filter.Length > 0) filter.Append(" AND ");
                    filter.AppendFormat("Status = '{0}'", ddlMemberLoanStatus.SelectedValue.Replace("'", "''"));
                }
            }
            else
            {
                // Summary report filters
                if (!string.IsNullOrEmpty(selectedText))
                {
                    string clean = selectedText.Replace("'", "''");
                    filter.AppendFormat("(MemberName LIKE '%{0}%' OR MembershipNo LIKE '%{0}%')", clean);
                }
            }

            BindReport(gvMemberWise, dtReport, filter.ToString());
        }
        catch (Exception ex)
        {
            ShowAlert("Error generating Member-Wise report: " + ex.Message, false);
        }
    }

    protected void btnExportMemberWise_Click(object sender, EventArgs e)
    {
        if (gvMemberWise.DataSource == null)
        {
            btnGenerateMemberWise_Click(sender, e);
        }
        ExportGridViewToExcel(gvMemberWise, "MemberWise");
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Report Tab 8: Books catalogue
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    protected void btnGenerateBooks_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable dt = DBHelper.GetReportBooks();

            System.Text.StringBuilder filter = new System.Text.StringBuilder();
            if (ddlBooksCategory.SelectedIndex > 0)
            {
                filter.AppendFormat("Category = '{0}'", ddlBooksCategory.SelectedValue.Replace("'", "''"));
            }
            if (ddlBooksLanguage.SelectedIndex > 0)
            {
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("Language = '{0}'", ddlBooksLanguage.SelectedValue.Replace("'", "''"));
            }
            if (!string.IsNullOrEmpty(txtBooksPublisherFilter.Text.Trim()))
            {
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("Publisher LIKE '%{0}%'", txtBooksPublisherFilter.Text.Trim().Replace("'", "''"));
            }
            if (!string.IsNullOrEmpty(txtBooksKeyword.Text.Trim()))
            {
                string kw = txtBooksKeyword.Text.Trim().Replace("'", "''");
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("(Title LIKE '%{0}%' OR ISBN13 LIKE '%{0}%' OR Authors LIKE '%{0}%')", kw);
            }
            if (ddlBooksAvailability.SelectedIndex > 0)
            {
                if (filter.Length > 0) filter.Append(" AND ");
                if (ddlBooksAvailability.SelectedValue == "Available")
                {
                    filter.Append("AvailableCopies > 0");
                }
                else
                {
                    filter.Append("AvailableCopies = 0");
                }
            }

            BindReport(gvBooks, dt, filter.ToString());
        }
        catch (Exception ex)
        {
            ShowAlert("Error generating Books Catalog report: " + ex.Message, false);
        }
    }

    protected void btnExportBooks_Click(object sender, EventArgs e)
    {
        if (gvBooks.DataSource == null)
        {
            btnGenerateBooks_Click(sender, e);
        }
        ExportGridViewToExcel(gvBooks, "BooksCatalogue");
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Report Tab 9: Reservations
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    protected void btnGenerateReservations_Click(object sender, EventArgs e)
    {
        try
        {
            DateTime? from = ParseDate(txtReservationsFrom.Text);
            DateTime? to = ParseDate(txtReservationsTo.Text);
            byte? status = null;
            if (!string.IsNullOrEmpty(ddlReservationsStatus.SelectedValue))
            {
                status = Convert.ToByte(ddlReservationsStatus.SelectedValue);
            }

            DataTable dt = DBHelper.GetReportReservations(from, to, status);

            System.Text.StringBuilder filter = new System.Text.StringBuilder();
            if (!string.IsNullOrEmpty(txtReservationsMemberFilter.Text.Trim()))
            {
                string mKey = txtReservationsMemberFilter.Text.Trim();
                if (mKey.Contains(" - "))
                {
                    mKey = mKey.Substring(0, mKey.IndexOf(" - ")).Trim();
                }
                mKey = mKey.Replace("'", "''");
                filter.AppendFormat("(MemberName LIKE '%{0}%' OR MembershipNo LIKE '%{0}%')", mKey);
            }
            if (!string.IsNullOrEmpty(txtReservationsBookKeyword.Text.Trim()))
            {
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("BookTitle LIKE '%{0}%'", txtReservationsBookKeyword.Text.Trim().Replace("'", "''"));
            }

            BindReport(gvReservations, dt, filter.ToString());
        }
        catch (Exception ex)
        {
            ShowAlert("Error generating Reservations report: " + ex.Message, false);
        }
    }

    protected void btnExportReservations_Click(object sender, EventArgs e)
    {
        if (gvReservations.DataSource == null)
        {
            btnGenerateReservations_Click(sender, e);
        }
        ExportGridViewToExcel(gvReservations, "ReservationsReport");
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Report Tab 10: Shelf Books (NEW)
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    protected void btnGenerateShelfBooks_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable dt = DBHelper.GetReportShelfBooks();

            System.Text.StringBuilder filter = new System.Text.StringBuilder();
            if (ddlShelfHall.SelectedIndex > 0)
            {
                filter.AppendFormat("Hall = '{0}'", ddlShelfHall.SelectedValue.Replace("'", "''"));
            }
            if (!string.IsNullOrEmpty(txtShelfAisle.Text.Trim()))
            {
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("[Aisle/Unit] LIKE '%{0}%'", txtShelfAisle.Text.Trim().Replace("'", "''"));
            }
            if (!string.IsNullOrEmpty(txtShelfRack.Text.Trim()))
            {
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("[Rack#] = '{0}'", txtShelfRack.Text.Trim());
            }
            if (!string.IsNullOrEmpty(txtShelfKeyword.Text.Trim()))
            {
                string kw = txtShelfKeyword.Text.Trim().Replace("'", "''");
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("(Title LIKE '%{0}%' OR Barcode LIKE '%{0}%')", kw);
            }
            if (ddlShelfAvailability.SelectedIndex > 0)
            {
                if (filter.Length > 0) filter.Append(" AND ");
                filter.AppendFormat("Status = '{0}'", ddlShelfAvailability.SelectedValue.Replace("'", "''"));
            }

            BindReport(gvShelfBooks, dt, filter.ToString());
        }
        catch (Exception ex)
        {
            ShowAlert("Error generating Shelf Books report: " + ex.Message, false);
        }
    }

    protected void btnExportShelfBooks_Click(object sender, EventArgs e)
    {
        if (gvShelfBooks.DataSource == null)
        {
            btnGenerateShelfBooks_Click(sender, e);
        }
        ExportGridViewToExcel(gvShelfBooks, "ShelfBooks");
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

