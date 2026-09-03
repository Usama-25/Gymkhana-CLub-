using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Collections.Generic;

public partial class FacilityAccess : System.Web.UI.Page
{
    string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadSports();
        }
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
            // Handle exception if needed
        }
    }

    protected void txtMemberNo_TextChanged(object sender, EventArgs e)
    {
        ValidateAccess(txtMemberNo.Text.Trim(), null);
    }

    protected void txtRFID_TextChanged(object sender, EventArgs e)
    {
        ValidateAccess(null, txtRFID.Text.Trim());
    }

    private void ValidateAccess(string memberNo, string rfid)
    {
        string sportIdStr = ddlSports.SelectedValue;

        if ((string.IsNullOrEmpty(memberNo) && string.IsNullOrEmpty(rfid)) || string.IsNullOrEmpty(sportIdStr))
        {
            pnlResult.CssClass = "result-panel"; // hide
            return;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();

                if (!string.IsNullOrEmpty(rfid))
                {
                    bool cardFound = false;
                    using (SqlCommand cmdRfid = new SqlCommand("select Cardid,MemberNo,CardNo from membership.dbo.RFIDCards where CardStatus = 'Active' and CardNo = @CardNo", con))
                    {
                        cmdRfid.Parameters.AddWithValue("@CardNo", rfid);
                        using (SqlDataReader reader = cmdRfid.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                memberNo = reader["MemberNo"].ToString();
                                cardFound = true;
                            }
                        }
                    }

                    if (!cardFound)
                    {
                        pnlResult.CssClass = "result-panel denied blink";
                        iconResult.Attributes["class"] = "fas fa-times-circle";
                        lblResultTitle.Text = "ACCESS DENIED";
                        lblReason.Text = "Invalid or Inactive RFID Card.";
                        
                        lblMemName.Text = "N/A";
                        lblMemNo.Text = "N/A";
                        lblMemStatus.Text = "N/A";

                        ClientScript.RegisterStartupScript(this.GetType(), "stopBlink", "setTimeout(function(){ document.getElementById('" + pnlResult.ClientID + "').classList.remove('blink'); }, 1500);", true);
                        
                        txtMemberNo.Text = "";
                        txtRFID.Text = "";
                        return;
                    }
                }

                using (SqlCommand cmd = new SqlCommand("sp_ValidateMemberAccess", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    
                    if (!string.IsNullOrEmpty(memberNo))
                        cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                    else
                        cmd.Parameters.AddWithValue("@MemberNo", DBNull.Value);

                    if (!string.IsNullOrEmpty(rfid))
                        cmd.Parameters.AddWithValue("@RFID", rfid);
                    else
                        cmd.Parameters.AddWithValue("@RFID", DBNull.Value);

                    cmd.Parameters.AddWithValue("@SportID", Convert.ToInt32(sportIdStr));

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            DataRow row = dt.Rows[0];
                            string result = row["AccessResult"].ToString();
                            string reason = row["DenialReason"].ToString();

                            lblMemName.Text = row["FullName"].ToString();
                            lblMemNo.Text = row["MemberNo"].ToString();
                            lblMemStatus.Text = row["MemberStatus"].ToString();

                            // Override: Allow access even if there are outstanding dues
                            if (result == "Denied" && reason.Contains("Outstanding Dues"))
                            {
                                result = "Granted";
                            }

                            if (result == "Granted")
                            {
                                pnlResult.CssClass = "result-panel granted blink";
                                iconResult.Attributes["class"] = "fas fa-check-circle";
                                lblResultTitle.Text = "ACCESS GRANTED";
                                
                                if (reason.Contains("Outstanding Dues"))
                                {
                                    lblReason.Text = "Access Allowed. Note: " + reason;
                                }
                                else
                                {
                                    lblReason.Text = "Member is clear and has an active subscription.";
                                }
                                
                                // Remove blink after 1.5 seconds to avoid annoyance
                                ClientScript.RegisterStartupScript(this.GetType(), "stopBlink", "setTimeout(function(){ document.getElementById('" + pnlResult.ClientID + "').classList.remove('blink'); }, 1500);", true);
                            }
                            else
                            {
                                pnlResult.CssClass = "result-panel denied blink";
                                iconResult.Attributes["class"] = "fas fa-times-circle";
                                lblResultTitle.Text = "ACCESS DENIED";
                                lblReason.Text = reason;

                                ClientScript.RegisterStartupScript(this.GetType(), "stopBlink", "setTimeout(function(){ document.getElementById('" + pnlResult.ClientID + "').classList.remove('blink'); }, 1500);", true);
                            }
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            pnlResult.CssClass = "result-panel denied";
            iconResult.Attributes["class"] = "fas fa-exclamation-triangle";
            lblResultTitle.Text = "SYSTEM ERROR";
            lblReason.Text = ex.Message;
        }

        // Clear input for next scan
        txtMemberNo.Text = "";
        txtRFID.Text = "";
    }
}
