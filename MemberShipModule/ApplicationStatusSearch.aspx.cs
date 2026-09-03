using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.Text;

namespace Membership
{
    public partial class ApplicationStatusSearch : Page
    {
        private string connectionString
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
                LoadDropdowns();
            }
        }

        private void LoadDropdowns()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Load Membership Types (Main) from FormTypeMain
                try
                {
                    using (SqlCommand cmd = new SqlCommand("SELECT id, FormTypeName FROM FormTypeMain WHERE Status = 1 ORDER BY FormTypeName", conn))
                    {
                        SqlDataReader dr = cmd.ExecuteReader();
                        while (dr.Read())
                        {
                            ddlType.Items.Add(new ListItem(dr["FormTypeName"].ToString(), dr["id"].ToString()));
                        }
                        dr.Close();
                    }
                }
                catch { }

                // Initial load of Class (Sub) - empty until type selected
                ddlClass.Items.Clear();
                ddlClass.Items.Add(new ListItem("All Classes", ""));

                // Load Statuses dynamically
                try
                {
                    using (SqlCommand cmd = new SqlCommand("SELECT DISTINCT Status FROM ApplicationFForm WHERE Status IS NOT NULL AND Status != '' ORDER BY Status", conn))
                    {
                        SqlDataReader dr = cmd.ExecuteReader();
                        while (dr.Read())
                        {
                            string status = dr[0].ToString();
                            if (ddlStatus.Items.FindByValue(status) == null)
                            {
                                ddlStatus.Items.Add(new ListItem(status, status));
                            }
                        }
                        dr.Close();
                    }
                }
                catch { }
            }
        }

        protected void ddlType_SelectedIndexChanged(object sender, EventArgs e)
        {
            ddlClass.Items.Clear();
            ddlClass.Items.Add(new ListItem("All Classes", ""));

            if (!string.IsNullOrEmpty(ddlType.SelectedValue))
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string sql = "SELECT id, SubTypeName FROM FormTypeSub WHERE MainId = @MainId AND Status = 1 ORDER BY SubTypeName";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@MainId", ddlType.SelectedValue);
                        conn.Open();
                        SqlDataReader dr = cmd.ExecuteReader();
                        while (dr.Read())
                        {
                            ddlClass.Items.Add(new ListItem(dr["SubTypeName"].ToString(), dr["id"].ToString()));
                        }
                        dr.Close();
                    }
                }
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindResults();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtUniversalSearch.Text = "";
            txtTrackID.Text = "";
            txtApplicantName.Text = "";
            txtNIC.Text = "";
            txtMobile.Text = "";
            txtApplyDate.Text = "";
            ddlStatus.SelectedIndex = 0;
            ddlType.SelectedIndex = 0;
            ddlClass.Items.Clear();
            ddlClass.Items.Add(new ListItem("All Classes", ""));
            ddlClass.SelectedIndex = 0;
            ddlSortOrder.SelectedIndex = 0;

            gvResults.DataSource = null;
            gvResults.DataBind();
            lblCount.Text = "Ready to search";
            lblCount.Style["background"] = "#f1f5f9";
            lblCount.Style["color"] = "#475569";
            lblCount.Style["border-color"] = "#e2e8f0";
        }

        protected void gvResults_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvResults.PageIndex = e.NewPageIndex;
            BindResults();
        }

        private void BindResults()
        {
            bool noFilter = string.IsNullOrWhiteSpace(txtUniversalSearch.Text) &&
                            string.IsNullOrWhiteSpace(txtTrackID.Text) &&
                            string.IsNullOrWhiteSpace(txtApplicantName.Text) &&
                            string.IsNullOrWhiteSpace(txtNIC.Text) &&
                            string.IsNullOrWhiteSpace(txtMobile.Text) &&
                            string.IsNullOrWhiteSpace(txtApplyDate.Text) &&
                            string.IsNullOrEmpty(ddlStatus.SelectedValue) &&
                            string.IsNullOrEmpty(ddlClass.SelectedValue) &&
                            string.IsNullOrEmpty(ddlType.SelectedValue);

            if (noFilter)
            {
                gvResults.DataSource = null;
                gvResults.DataBind();
                lblCount.Text = "Please apply a filter to search";
                lblCount.CssClass = "result-badge empty";
                return;
            }

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                StringBuilder sb = new StringBuilder(@"
                    SELECT TOP 500 
                        TrackID,
                        ApplicantName,
                        FatherName,
                        NIC,
                        Mobile,
                        Status,
                        MembershipType,
                        Membership_class,
                        City,
                        CONVERT(varchar, CreatedOn, 106) AS ApplyDate
                    FROM ApplicationFForm
                    WHERE 1=1 ");

                List<SqlParameter> parameters = new List<SqlParameter>();

                // Universal Search
                string universalText = txtUniversalSearch.Text.Trim();
                if (!string.IsNullOrEmpty(universalText))
                {
                    string[] terms = universalText.Split(new char[] { '+' }, StringSplitOptions.RemoveEmptyEntries);
                    for (int i = 0; i < terms.Length; i++)
                    {
                        string term = terms[i].Trim();
                        if (string.IsNullOrEmpty(term)) continue;

                        string likeTerm = term.Contains("%") ? term : "%" + term + "%";
                        string likeTermNoDash = likeTerm.Replace("-", "");

                        string pName = "@UTerm" + i;
                        string pNameND = "@UTermND" + i;

                        sb.AppendFormat(@" AND (
                            CAST(TrackID AS VARCHAR) LIKE {0}
                            OR ApplicantName LIKE {0}
                            OR FatherName LIKE {0}
                            OR REPLACE(NIC, '-', '') LIKE {1}
                            OR Mobile LIKE {0}
                            OR City LIKE {0}
                            OR Status LIKE {0}
                            OR MembershipType LIKE {0}
                        ) ", pName, pNameND);

                        parameters.Add(new SqlParameter(pName, likeTerm));
                        parameters.Add(new SqlParameter(pNameND, likeTermNoDash));
                    }
                }

                // Field Filters
                if (!string.IsNullOrWhiteSpace(txtTrackID.Text))
                {
                    sb.Append(" AND CAST(TrackID AS VARCHAR) LIKE @FTrackID ");
                    parameters.Add(new SqlParameter("@FTrackID", "%" + txtTrackID.Text.Trim() + "%"));
                }

                if (!string.IsNullOrWhiteSpace(txtApplicantName.Text))
                {
                    sb.Append(" AND ApplicantName LIKE @FName ");
                    parameters.Add(new SqlParameter("@FName", "%" + txtApplicantName.Text.Trim() + "%"));
                }

                if (!string.IsNullOrWhiteSpace(txtNIC.Text))
                {
                    sb.Append(" AND REPLACE(NIC, '-', '') LIKE @FNIC ");
                    parameters.Add(new SqlParameter("@FNIC", "%" + txtNIC.Text.Trim().Replace("-", "") + "%"));
                }

                if (!string.IsNullOrWhiteSpace(txtMobile.Text))
                {
                    sb.Append(" AND Mobile LIKE @FMobile ");
                    parameters.Add(new SqlParameter("@FMobile", "%" + txtMobile.Text.Trim() + "%"));
                }

                if (!string.IsNullOrWhiteSpace(txtApplyDate.Text))
                {
                    sb.Append(" AND CAST(CreatedOn AS DATE) = @FApplyDate ");
                    parameters.Add(new SqlParameter("@FApplyDate", txtApplyDate.Text.Trim()));
                }

                if (!string.IsNullOrEmpty(ddlStatus.SelectedValue))
                {
                    sb.Append(" AND Status = @FStatus ");
                    parameters.Add(new SqlParameter("@FStatus", ddlStatus.SelectedValue));
                }

                if (ddlType.SelectedIndex > 0)
                {
                    sb.Append(" AND Membership_class = @FType ");
                    parameters.Add(new SqlParameter("@FType", ddlType.SelectedItem.Text));
                }

                if (ddlClass.SelectedIndex > 0)
                {
                    sb.Append(" AND MembershipType = @FClass ");
                    parameters.Add(new SqlParameter("@FClass", ddlClass.SelectedItem.Text));
                }

                // Sorting based on selection
                if (ddlSortOrder.SelectedValue == "DESC")
                {
                    sb.Append(" ORDER BY TrackID DESC ");
                }
                else
                {
                    sb.Append(" ORDER BY TrackID ASC "); // Default General Seniority
                }

                using (SqlCommand cmd = new SqlCommand(sb.ToString(), conn))
                {
                    foreach (var p in parameters) cmd.Parameters.Add(p);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvResults.DataSource = dt;
                    gvResults.DataBind();

                    if (dt.Rows.Count > 0)
                    {
                        lblCount.Text = "Found " + dt.Rows.Count + " application" + (dt.Rows.Count > 1 ? "s" : "");
                        lblCount.Style["background"] = "#dcfce7";
                        lblCount.Style["color"] = "#166534";
                        lblCount.Style["border-color"] = "#bbf7d0";
                    }
                    else
                    {
                        lblCount.Text = "No applications found";
                        lblCount.Style["background"] = "#fef3c7";
                        lblCount.Style["color"] = "#92400e";
                        lblCount.Style["border-color"] = "#fde68a";
                    }
                }
            }
        }

        protected string GetStatusClass(object statusObj)
        {
            string status = statusObj != null ? statusObj.ToString().ToLower().Trim() : "";
            if (status.Contains("pending")) return "status-pending";
            if (status.Contains("approved")) return "status-approved";
            if (status.Contains("interview")) return "status-interview";
            return "status-other";
        }
    }
}
