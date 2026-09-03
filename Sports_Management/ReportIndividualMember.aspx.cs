using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Collections.Generic;

public partial class ReportIndividualMember : System.Web.UI.Page
{
    string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            pnlReport.Visible = false;
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        gvSubscriptions.PageIndex = 0;
        gvPOS.PageIndex = 0;
        LoadMemberData();
    }

    protected void gvSubscriptions_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvSubscriptions.PageIndex = e.NewPageIndex;
        LoadMemberData();
    }

    protected void gvPOS_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvPOS.PageIndex = e.NewPageIndex;
        LoadMemberData();
    }

    protected void btnPrint_Click(object sender, EventArgs e)
    {
        string url = string.Format("ReportPrint.aspx?rpt=ind&memberNo={0}", txtMemberNo.Text.Trim());
        ClientScript.RegisterStartupScript(this.GetType(), "print", "window.open('" + url + "', '_blank');", true);
    }

    private void LoadMemberData()
    {
        string memberNo = txtMemberNo.Text.Trim();
        if (string.IsNullOrEmpty(memberNo))
        {
            ShowMessage("Please enter a Member No.", false);
            return;
        }

        try
        {
            int memberId = 0;
            // 1. Get Member Details
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_SearchMembers", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SearchTerm", memberNo);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            memberId = Convert.ToInt32(reader["MemberID"]);
                            lblName.Text = reader["FullName"].ToString();
                            lblMemberNo.Text = reader["MembershipNo"].ToString();
                            lblContact.Text = reader["ContactNo"].ToString();
                            
                            string status = reader["Status"].ToString();
                            lblStatus.Text = status;
                            if (status.Equals("Active", StringComparison.OrdinalIgnoreCase))
                                lblStatus.CssClass = "badge badge-active";
                            else
                                lblStatus.CssClass = "badge badge-inactive";
                            
                            pnlReport.Visible = true;
                            btnPrint.Visible = true;
                            lblMessage.Visible = false;
                        }
                        else
                        {
                            ShowMessage("Member not found.", false);
                            pnlReport.Visible = false;
                            btnPrint.Visible = false;
                            return;
                        }
                    }
                }
            }

            // 2. Get Subscriptions
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetMemberSubscriptions", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@MemberID", memberId);
                    cmd.Parameters.AddWithValue("@MemberNo", lblMemberNo.Text);
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        FilterDataTableByAllowedSports(dt);
                        gvSubscriptions.DataSource = dt;
                        gvSubscriptions.DataBind();
                    }
                }
            }

            // 3. Get POS Transactions
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_RptIndividualMemberPOS", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@MemberID", memberId);
                    cmd.Parameters.AddWithValue("@MemberNo", lblMemberNo.Text);
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        FilterDataTableByAllowedSports(dt);
                        gvPOS.DataSource = dt;
                        gvPOS.DataBind();
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
