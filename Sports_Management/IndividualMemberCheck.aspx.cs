using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Collections.Generic;

public partial class IndividualMemberCheck : System.Web.UI.Page
{
    private readonly string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            lblMessage.Visible = false;
            pnlDetails.Visible = false;
            pnlNoData.Visible = true;
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        lblMessage.Visible = false;
        pnlDetails.Visible = false;
        pnlNoData.Visible = true;

        string searchNo = txtSearchMemberNo.Text.Trim();
        if (string.IsNullOrEmpty(searchNo))
        {
            ShowMessage("Please enter a Member or Dependent Number to search.", false);
            return;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetIndividualMemberCheckDetails", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SearchMemberNo", searchNo);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        // Check if we received the expected result sets
                        if (ds.Tables.Count >= 4)
                        {
                            DataTable dtMember = ds.Tables[0];
                            DataTable dtSubscriptions = ds.Tables[1];
                            DataTable dtDependents = ds.Tables[2];
                            DataTable dtSportsCards = ds.Tables[3];

                            if (dtMember.Rows.Count > 0 && Convert.ToInt32(dtMember.Rows[0]["MemberID"]) > 0)
                            {
                                pnlDetails.Visible = true;
                                pnlNoData.Visible = false;

                                DataRow memberRow = dtMember.Rows[0];
                                string fullName = memberRow["FullName"].ToString();
                                string actualMemberNo = memberRow["MemberNo"].ToString();
                                string relation = memberRow["Relation"].ToString();
                                string status = memberRow["Status"].ToString();
                                string contact = memberRow["ContactNo"].ToString();

                                // Populate Profile Card
                                lblMemberName.Text = fullName;
                                lblMemberNo.Text = actualMemberNo;
                                lblRelation.Text = relation;
                                lblStatus.Text = status;
                                lblContact.Text = contact;

                                // Style Profile Status Badge
                                badgeStatus.Attributes["class"] = "status-badge " + GetStatusBadgeClass(status);

                                // Style Relation Badge
                                if (relation.Equals("Self", StringComparison.OrdinalIgnoreCase))
                                {
                                    lblRelation.Text = "Main Member";
                                }

                                // Filter subscriptions by Allowed Sports if user is Operator
                                if (Session["UserRole"] != null && Session["UserRole"].ToString() == "Operator")
                                {
                                    List<int> allowedSports = Session["AllowedSports"] as List<int>;
                                    if (allowedSports != null && allowedSports.Count > 0)
                                    {
                                        for (int i = dtSubscriptions.Rows.Count - 1; i >= 0; i--)
                                        {
                                            if (dtSubscriptions.Rows[i]["SportID"] != DBNull.Value)
                                            {
                                                int sportId = Convert.ToInt32(dtSubscriptions.Rows[i]["SportID"]);
                                                if (!allowedSports.Contains(sportId))
                                                {
                                                    dtSubscriptions.Rows.RemoveAt(i);
                                                }
                                            }
                                        }
                                        
                                        for (int i = dtSportsCards.Rows.Count - 1; i >= 0; i--)
                                        {
                                            if (dtSportsCards.Rows[i]["SportID"] != DBNull.Value)
                                            {
                                                int sportId = Convert.ToInt32(dtSportsCards.Rows[i]["SportID"]);
                                                if (!allowedSports.Contains(sportId))
                                                {
                                                    dtSportsCards.Rows.RemoveAt(i);
                                                }
                                            }
                                        }
                                    }
                                    else
                                    {
                                        dtSubscriptions.Clear();
                                        dtSportsCards.Clear();
                                    }
                                }

                                // Bind Active Subscriptions
                                gvActiveSubscriptions.DataSource = dtSubscriptions;
                                gvActiveSubscriptions.DataBind();

                                // Bind Dependents (Only if searched member is Main Member)
                                if (relation.Equals("Self", StringComparison.OrdinalIgnoreCase))
                                {
                                    pnlDependents.Visible = true;
                                    gvDependents.DataSource = dtDependents;
                                    gvDependents.DataBind();
                                }
                                else
                                {
                                    pnlDependents.Visible = false;
                                }

                                // Process Sports Card Alerts
                                ProcessSportsCardAlerts(actualMemberNo, relation, dtSportsCards);
                            }
                            else
                            {
                                ShowMessage("No member found with member number: " + searchNo, false);
                            }
                        }
                        else
                        {
                            ShowMessage("Error retrieving member data from the server. Insufficient result sets returned.", false);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Database error: " + ex.Message, false);
        }
    }

    private void ProcessSportsCardAlerts(string searchedMemberNo, string relation, DataTable dtSportsCards)
    {
        pnlSportsCardAlert.Visible = false;
        lblSportsCardAlertText.Text = "";

        if (dtSportsCards == null || dtSportsCards.Rows.Count == 0)
        {
            return;
        }

        List<string> alerts = new List<string>();

        // If a dependent was searched, show alert only if they specifically have a card
        if (!relation.Equals("Self", StringComparison.OrdinalIgnoreCase))
        {
            foreach (DataRow row in dtSportsCards.Rows)
            {
                string rowMemberNo = row["MemberNo"].ToString();
                if (rowMemberNo.Equals(searchedMemberNo, StringComparison.OrdinalIgnoreCase))
                {
                    alerts.Add(string.Format("Searched member has an active <strong>{0}</strong> assigned on {1}.", 
                        row["PackageName"], 
                        Convert.ToDateTime(row["StartDate"]).ToString("dd-MMM-yyyy")));
                }
            }
        }
        else
        {
            // If main member was searched, show alerts for anyone in the entire family (main member or dependents)
            foreach (DataRow row in dtSportsCards.Rows)
            {
                string personName = row["PersonName"].ToString();
                string personRelation = row["Relation"].ToString();
                string personNo = row["MemberNo"].ToString();

                string displayName = personRelation.Equals("Self", StringComparison.OrdinalIgnoreCase) 
                    ? "Main Member" 
                    : string.Format("{0} ({1} - {2})", personName, personRelation, personNo);

                alerts.Add(string.Format("<strong>{0}</strong> has an active <strong>{1}</strong> assigned on {2}.", 
                    displayName, 
                    row["PackageName"], 
                    Convert.ToDateTime(row["StartDate"]).ToString("dd-MMM-yyyy")));
            }
        }

        if (alerts.Count > 0)
        {
            pnlSportsCardAlert.Visible = true;
            lblSportsCardAlertText.Text = string.Join("<br/>", alerts);
        }
    }

    protected string GetStatusBadgeClass(string status)
    {
        if (string.IsNullOrEmpty(status))
            return "status-inactive";

        status = status.Trim();
        if (status.Equals("Active", StringComparison.OrdinalIgnoreCase) || status.Equals("True", StringComparison.OrdinalIgnoreCase))
        {
            return "status-active";
        }
        else if (status.Equals("Block", StringComparison.OrdinalIgnoreCase) || status.Equals("Blocked", StringComparison.OrdinalIgnoreCase))
        {
            return "status-blocked";
        }
        else
        {
            return "status-inactive";
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
