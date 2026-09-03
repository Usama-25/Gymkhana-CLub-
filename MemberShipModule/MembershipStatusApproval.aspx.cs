using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MemberShipModule
{
    public partial class MembershipStatusApproval : System.Web.UI.Page
    {
        private string Con
        {
            get
            {
                var s = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
                return s != null ? s.ConnectionString : "";
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Data is not loaded on page load as per user request
                // BindPendingRequests(); 
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindPendingRequests();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtFilterMemberNo.Text = "";
            txtFilterName.Text = "";
            ddlFilterStatus.SelectedIndex = 0;
            txtFilterStartDate.Text = "";
            txtFilterEndDate.Text = "";
            gvPendingRequests.DataSource = null;
            gvPendingRequests.DataBind();
        }

        private void BindPendingRequests()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(Con))
                {
                    using (SqlCommand cmd = new SqlCommand("usp_GetPendingStatusRequests", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        
                        cmd.Parameters.AddWithValue("@MemberNo", txtFilterMemberNo.Text.Trim());
                        cmd.Parameters.AddWithValue("@MemberName", txtFilterName.Text.Trim());
                        cmd.Parameters.AddWithValue("@NewStatus", ddlFilterStatus.SelectedValue);
                        
                        if (!string.IsNullOrEmpty(txtFilterStartDate.Text))
                            cmd.Parameters.AddWithValue("@FromDate", DateTime.Parse(txtFilterStartDate.Text));
                        else
                            cmd.Parameters.AddWithValue("@FromDate", DBNull.Value);

                        if (!string.IsNullOrEmpty(txtFilterEndDate.Text))
                            cmd.Parameters.AddWithValue("@ToDate", DateTime.Parse(txtFilterEndDate.Text).AddDays(1).AddSeconds(-1)); // End of day
                        else
                            cmd.Parameters.AddWithValue("@ToDate", DBNull.Value);

                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvPendingRequests.DataSource = dt;
                        gvPendingRequests.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("error", "Failed to load pending requests: " + ex.Message);
            }
        }

        protected void gvPendingRequests_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Approve" || e.CommandName == "Reject")
            {
                int rowIndex = Convert.ToInt32(e.CommandArgument);
                int requestId = Convert.ToInt32(gvPendingRequests.DataKeys[rowIndex].Value);
                
                TextBox txtRemarks = (TextBox)gvPendingRequests.Rows[rowIndex].FindControl("txtApprovalRemarks");
                string remarks = txtRemarks != null ? txtRemarks.Text.Trim() : "";
                
                string userName = Session["UserName"] != null ? Session["UserName"].ToString() : "Admin";
                
                try
                {
                    using (SqlConnection con = new SqlConnection(Con))
                    {
                        string spName = (e.CommandName == "Approve") ? "usp_ApproveStatusRequest" : "usp_RejectStatusRequest";
                        using (SqlCommand cmd = new SqlCommand(spName, con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.AddWithValue("@RequestID", requestId);
                            cmd.Parameters.AddWithValue("@ApprovedBy", userName);
                            cmd.Parameters.AddWithValue("@Remarks", remarks);
                            
                            con.Open();
                            cmd.ExecuteNonQuery();
                            
                            ShowMessage("success", "Request successfully " + (e.CommandName == "Approve" ? "Approved" : "Rejected") + "!");
                            BindPendingRequests();
                        }
                    }
                }
                catch (Exception ex)
                {
                    ShowMessage("error", "Operation failed: " + ex.Message);
                }
            }
        }

        private void ShowMessage(string type, string message)
        {
            message = message.Replace("'", "\\'").Replace("\n", "\\n").Replace("\r", "\\r");
            string script = string.Format("alert('{0}');", message);
            ScriptManager.RegisterStartupScript(this, GetType(), "show_msg", script, true);
        }
    }
}
