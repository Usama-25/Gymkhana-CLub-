using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Collections.Generic;

public partial class ReportAccessLogs : System.Web.UI.Page
{
    string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadSports();
            
            // Set default date range to current month
            txtFromDate.Text = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1).ToString("yyyy-MM-dd");
            txtToDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            
            LoadReport();
        }
    }

    protected void gvSummary_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvSummary.PageIndex = e.NewPageIndex;
        LoadReport();
    }

    protected void gvDetails_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvDetails.PageIndex = e.NewPageIndex;
        LoadReport();
    }

    protected void btnPrint_Click(object sender, EventArgs e)
    {
        string rpt = mvReports.ActiveViewIndex == 0 ? "acc_summary" : "acc_details";
        string url = string.Format("ReportPrint.aspx?rpt={0}&from={1}&to={2}&sport={3}&memberNo={4}",
            rpt,
            txtFromDate.Text,
            txtToDate.Text,
            ddlSports.SelectedValue,
            Server.UrlEncode(txtMemberNo.Text.Trim()));
            
        ClientScript.RegisterStartupScript(this.GetType(), "print", "window.open('" + url + "', '_blank');", true);
    }

    private void LoadSports()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetSports", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        DataView dv = dt.DefaultView;
                        if (Session["UserRole"] != null && Session["UserRole"].ToString() == "Operator")
                        {
                            List<int> allowedSports = Session["AllowedSports"] as List<int>;
                            if (allowedSports != null && allowedSports.Count > 0)
                            {
                                dv.RowFilter = "Status = True AND SportID IN (" + string.Join(",", allowedSports) + ")";
                            }
                            else
                            {
                                dv.RowFilter = "SportID = -1";
                            }
                        }
                        else
                        {
                            dv.RowFilter = "Status = True";
                        }

                        ddlSports.DataSource = dv;
                        ddlSports.DataTextField = "SportName";
                        ddlSports.DataValueField = "SportID";
                        ddlSports.DataBind();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading sports: " + ex.Message, false);
        }
    }

    protected void btnGenerate_Click(object sender, EventArgs e)
    {
        gvSummary.PageIndex = 0;
        gvDetails.PageIndex = 0;
        LoadReport();
    }

    protected void lnkSummary_Click(object sender, EventArgs e)
    {
        mvReports.ActiveViewIndex = 0;
        lnkSummary.CssClass = "nav-link-tab active";
        lnkDetails.CssClass = "nav-link-tab";
        LoadReport();
    }

    protected void lnkDetails_Click(object sender, EventArgs e)
    {
        mvReports.ActiveViewIndex = 1;
        lnkSummary.CssClass = "nav-link-tab";
        lnkDetails.CssClass = "nav-link-tab active";
        LoadReport();
    }

    private void LoadReport()
    {
        lblMessage.Visible = false;
        try
        {
            string spName = mvReports.ActiveViewIndex == 0 ? "sp_RptAccessLogSummary" : "sp_RptAccessLogDetails";

            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand(spName, con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    
                    if (!string.IsNullOrEmpty(txtFromDate.Text))
                        cmd.Parameters.AddWithValue("@FromDate", txtFromDate.Text);
                    
                    if (!string.IsNullOrEmpty(txtToDate.Text))
                        cmd.Parameters.AddWithValue("@ToDate", txtToDate.Text);
                        
                    cmd.Parameters.AddWithValue("@SportID", Convert.ToInt32(ddlSports.SelectedValue));
                    
                    if (mvReports.ActiveViewIndex == 1) // Details has MemberNo parameter
                    {
                        cmd.Parameters.AddWithValue("@MemberNo", txtMemberNo.Text.Trim());
                    }

                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);

                        FilterDataTableByAllowedSports(dt);
                        
                        if (mvReports.ActiveViewIndex == 0)
                        {
                            gvSummary.DataSource = dt;
                            gvSummary.DataBind();
                        }
                        else
                        {
                            gvDetails.DataSource = dt;
                            gvDetails.DataBind();
                        }
                        btnPrint.Visible = (dt.Rows.Count > 0);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            btnPrint.Visible = false;
            ShowMessage("Database error: " + ex.Message, false);
        }
    }

    private void FilterDataTableByAllowedSports(DataTable dt)
    {
        if (dt == null || dt.Rows.Count == 0) return;

        if (Session["UserRole"] != null && Session["UserRole"].ToString() == "Operator")
        {
            List<int> allowedSports = Session["AllowedSports"] as List<int>;
            if (allowedSports != null && allowedSports.Count > 0)
            {
                for (int i = dt.Rows.Count - 1; i >= 0; i--)
                {
                    if (dt.Columns.Contains("SportID") && dt.Rows[i]["SportID"] != DBNull.Value)
                    {
                        int sportId = Convert.ToInt32(dt.Rows[i]["SportID"]);
                        if (!allowedSports.Contains(sportId))
                        {
                            dt.Rows.RemoveAt(i);
                        }
                    }
                }
            }
            else
            {
                dt.Clear();
            }
        }
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
