using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Collections.Generic;

public partial class ReportPrint : System.Web.UI.Page
{
    string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            string reportType = Request.QueryString["rpt"];
            if (string.IsNullOrEmpty(reportType))
            {
                lblMessage.Text = "Invalid report type specified.";
                lblMessage.Visible = true;
                return;
            }

            LoadReport(reportType);
        }
    }

    private void LoadReport(string type)
    {
        try
        {
            if (type == "subs")
            {
                phSubs.Visible = true;
                lblTitle.Text = "Member Subscriptions Report";
                
                int sportId = 0;
                int.TryParse(Request.QueryString["sport"], out sportId);
                
                int status = -1;
                int.TryParse(Request.QueryString["status"], out status);

                string memberNo = Request.QueryString["memberNo"];

                string filterText = string.Format("Filters - Sport: {0}, Status: {1}", 
                    sportId == 0 ? "All" : sportId.ToString(), 
                    status == -1 ? "All" : (status == 1 ? "Active" : "Inactive"));

                if (!string.IsNullOrEmpty(memberNo))
                {
                    filterText += string.Format(", Member No: {0}", memberNo);
                }

                lblSubtitle.Text = string.Format("Generated on {0:dd-MMM-yyyy hh:mm tt} ({1})", 
                    DateTime.Now, 
                    filterText);

                using (SqlConnection con = new SqlConnection(connString))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_RptMemberSubscriptions", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@SportID", sportId);
                        cmd.Parameters.AddWithValue("@Status", status);
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
                            gvSubs.DataSource = dt;
                            gvSubs.DataBind();
                        }
                    }
                }
            }
            else if (type == "ind")
            {
                phInd.Visible = true;
                lblTitle.Text = "Individual Member Wise Report";
                string memberNo = Request.QueryString["memberNo"];
                lblSubtitle.Text = string.Format("Generated on {0:dd-MMM-yyyy hh:mm tt} for Member: {1}", DateTime.Now, memberNo);

                if (string.IsNullOrEmpty(memberNo))
                {
                    lblMessage.Text = "Member Number is required.";
                    lblMessage.Visible = true;
                    return;
                }

                int memberId = 0;
                // Get Member Details
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
                                lblIndName.Text = reader["FullName"].ToString();
                                lblIndMemberNo.Text = reader["MembershipNo"].ToString();
                                lblIndContact.Text = reader["ContactNo"].ToString();
                                lblIndStatus.Text = reader["Status"].ToString();
                            }
                            else
                            {
                                lblMessage.Text = "Member not found.";
                                lblMessage.Visible = true;
                                phInd.Visible = false;
                                return;
                            }
                        }
                    }
                }

                // Get Subscriptions
                using (SqlConnection con = new SqlConnection(connString))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_GetMemberSubscriptions", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@MemberID", memberId);
                        cmd.Parameters.AddWithValue("@MemberNo", lblIndMemberNo.Text);
                        using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);
                            FilterDataTableByAllowedSports(dt);
                            gvIndSubs.DataSource = dt;
                            gvIndSubs.DataBind();
                        }
                    }
                }

                // Get POS Transactions
                using (SqlConnection con = new SqlConnection(connString))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_RptIndividualMemberPOS", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@MemberID", memberId);
                        cmd.Parameters.AddWithValue("@MemberNo", lblIndMemberNo.Text);
                        using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);
                            FilterDataTableByAllowedSports(dt);
                            gvIndPOS.DataSource = dt;
                            gvIndPOS.DataBind();
                        }
                    }
                }
            }
            else if (type == "acc_summary")
            {
                phAccessSummary.Visible = true;
                lblTitle.Text = "Access Logs Summary Report";
                
                string fromDate = Request.QueryString["from"];
                string toDate = Request.QueryString["to"];
                int sportId = 0;
                int.TryParse(Request.QueryString["sport"], out sportId);

                lblSubtitle.Text = string.Format("Generated on {0:dd-MMM-yyyy hh:mm tt} (Date: {1} to {2})", 
                    DateTime.Now, 
                    string.IsNullOrEmpty(fromDate) ? "All" : fromDate, 
                    string.IsNullOrEmpty(toDate) ? "All" : toDate);

                using (SqlConnection con = new SqlConnection(connString))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_RptAccessLogSummary", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        if (!string.IsNullOrEmpty(fromDate)) cmd.Parameters.AddWithValue("@FromDate", fromDate);
                        if (!string.IsNullOrEmpty(toDate)) cmd.Parameters.AddWithValue("@ToDate", toDate);
                        cmd.Parameters.AddWithValue("@SportID", sportId);

                        using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);
                            FilterDataTableByAllowedSports(dt);
                            gvAccessSummary.DataSource = dt;
                            gvAccessSummary.DataBind();
                        }
                    }
                }
            }
            else if (type == "acc_details")
            {
                phAccessDetails.Visible = true;
                lblTitle.Text = "Access Logs Detailed Report";
                
                string fromDate = Request.QueryString["from"];
                string toDate = Request.QueryString["to"];
                string memberNo = Request.QueryString["memberNo"];
                int sportId = 0;
                int.TryParse(Request.QueryString["sport"], out sportId);

                lblSubtitle.Text = string.Format("Generated on {0:dd-MMM-yyyy hh:mm tt} (Filters - Date: {1} to {2}, Member: {3})", 
                    DateTime.Now, 
                    string.IsNullOrEmpty(fromDate) ? "All" : fromDate, 
                    string.IsNullOrEmpty(toDate) ? "All" : toDate,
                    string.IsNullOrEmpty(memberNo) ? "All" : memberNo);

                using (SqlConnection con = new SqlConnection(connString))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_RptAccessLogDetails", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                        if (!string.IsNullOrEmpty(fromDate)) cmd.Parameters.AddWithValue("@FromDate", fromDate);
                        if (!string.IsNullOrEmpty(toDate)) cmd.Parameters.AddWithValue("@ToDate", toDate);
                        cmd.Parameters.AddWithValue("@SportID", sportId);

                        using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);
                            FilterDataTableByAllowedSports(dt);
                            gvAccessDetails.DataSource = dt;
                            gvAccessDetails.DataBind();
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            lblMessage.Text = "Error generating print view: " + ex.Message;
            lblMessage.Visible = true;
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
}
