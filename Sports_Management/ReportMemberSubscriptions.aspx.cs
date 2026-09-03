using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Collections.Generic;

public partial class ReportMemberSubscriptions : System.Web.UI.Page
{
    string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadSports();
            LoadReport();
        }
    }

    protected void gvReport_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvReport.PageIndex = e.NewPageIndex;
        LoadReport();
    }

    protected void btnPrint_Click(object sender, EventArgs e)
    {
        string url = string.Format("ReportPrint.aspx?rpt=subs&sport={0}&status={1}&memberNo={2}", 
            ddlSports.SelectedValue, 
            ddlStatus.SelectedValue, 
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
        gvReport.PageIndex = 0;
        LoadReport();
    }

    private void LoadReport()
    {
        lblMessage.Visible = false;
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_RptMemberSubscriptions", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SportID", Convert.ToInt32(ddlSports.SelectedValue));
                    cmd.Parameters.AddWithValue("@Status", Convert.ToInt32(ddlStatus.SelectedValue));

                    string memberNo = txtMemberNo.Text.Trim();
                    if (!string.IsNullOrEmpty(memberNo))
                    {
                        cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@MemberNo", DBNull.Value);
                    }

                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);

                        FilterDataTableByAllowedSports(dt);

                        gvReport.DataSource = dt;
                        gvReport.DataBind();
                        btnPrint.Visible = (dt.Rows.Count > 0);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            btnPrint.Visible = false;
            ShowMessage("Error generating report: " + ex.Message, false);
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
