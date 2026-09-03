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
    public partial class MemberSearch : Page
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

        /// <summary>
        /// Load MemberCategory and MemberType dropdowns from DB tables.
        /// Falls back to loading distinct values from MemberProfile if lookup tables fail.
        /// </summary>
        private void LoadDropdowns()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // ── Load Category dropdown ──
                // Try MembershipClass table first, fallback to distinct MemberProfile values
                bool categoryLoaded = false;
                try
                {
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT DISTINCT Members_classes FROM MembershipClass ORDER BY Members_classes", conn))
                    {
                        SqlDataReader dr = cmd.ExecuteReader();
                        while (dr.Read())
                        {
                            string val = dr[0].ToString().Trim();
                            if (!string.IsNullOrEmpty(val))
                            {
                                ddlCategory.Items.Add(new ListItem(val, val));
                                categoryLoaded = true;
                            }
                        }
                        dr.Close();
                    }
                }
                catch { /* Table may not exist */ }

                // Fallback: load distinct categories from MemberProfile
                if (!categoryLoaded)
                {
                    try
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT DISTINCT MemberCategory FROM MemberProfile WHERE MemberCategory IS NOT NULL AND MemberCategory != '' ORDER BY MemberCategory", conn))
                        {
                            SqlDataReader dr = cmd.ExecuteReader();
                            while (dr.Read())
                            {
                                string val = dr[0].ToString().Trim();
                                if (!string.IsNullOrEmpty(val))
                                    ddlCategory.Items.Add(new ListItem(val, val));
                            }
                            dr.Close();
                        }
                    }
                    catch { }
                }

                // ── Load MemberType dropdown ──
                // Try MembershipType table first, fallback to distinct MemberProfile values
                bool typeLoaded = false;
                try
                {
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT DISTINCT MembershipType FROM MembershipType ORDER BY MembershipType", conn))
                    {
                        SqlDataReader dr = cmd.ExecuteReader();
                        while (dr.Read())
                        {
                            string val = dr[0].ToString().Trim();
                            if (!string.IsNullOrEmpty(val))
                            {
                                ddlMemberType.Items.Add(new ListItem(val, val));
                                typeLoaded = true;
                            }
                        }
                        dr.Close();
                    }
                }
                catch { /* Table may not exist */ }

                // Fallback: load distinct types from MemberProfile
                if (!typeLoaded)
                {
                    try
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT DISTINCT MemberType FROM MemberProfile WHERE MemberType IS NOT NULL AND MemberType != '' ORDER BY MemberType", conn))
                        {
                            SqlDataReader dr = cmd.ExecuteReader();
                            while (dr.Read())
                            {
                                string val = dr[0].ToString().Trim();
                                if (!string.IsNullOrEmpty(val))
                                    ddlMemberType.Items.Add(new ListItem(val, val));
                            }
                            dr.Close();
                        }
                    }
                    catch { }
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
            txtMemberNo.Text = "";
            txtName.Text = "";
            txtFatherName.Text = "";
            txtCNIC.Text = "";
            txtMobile.Text = "";
            txtEmail.Text = "";
            txtCity.Text = "";
            txtOccupation.Text = "";
            txtCompany.Text = "";
            txtSpouseName.Text = "";
            txtNationality.Text = "";
            txtPassport.Text = "";
            txtCoMemberNo.Text = "";
            ddlCategory.SelectedIndex = 0;
            ddlMemberType.SelectedIndex = 0;
            ddlStatus.SelectedIndex = 0;

            gvResults.DataSource = null;
            gvResults.DataBind();
            lblCount.Text = "Ready to search";
            lblCount.CssClass = "result-badge ready";
        }

        protected void gvResults_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvResults.PageIndex = e.NewPageIndex;
            BindResults();
        }

        private void BindResults()
        {
            bool NoFilter = string.IsNullOrWhiteSpace(txtUniversalSearch.Text) &&
                            string.IsNullOrWhiteSpace(txtMemberNo.Text) &&
                            string.IsNullOrWhiteSpace(txtName.Text) &&
                            string.IsNullOrWhiteSpace(txtFatherName.Text) &&
                            string.IsNullOrWhiteSpace(txtCNIC.Text) &&
                            string.IsNullOrWhiteSpace(txtMobile.Text) &&
                            string.IsNullOrWhiteSpace(txtEmail.Text) &&
                            string.IsNullOrWhiteSpace(txtCity.Text) &&
                            string.IsNullOrWhiteSpace(txtOccupation.Text) &&
                            string.IsNullOrWhiteSpace(txtCompany.Text) &&
                            string.IsNullOrWhiteSpace(txtSpouseName.Text) &&
                            string.IsNullOrWhiteSpace(txtNationality.Text) &&
                            string.IsNullOrWhiteSpace(txtPassport.Text) &&
                            string.IsNullOrWhiteSpace(txtCoMemberNo.Text) &&
                            string.IsNullOrEmpty(ddlCategory.SelectedValue) &&
                            string.IsNullOrEmpty(ddlMemberType.SelectedValue) &&
                            string.IsNullOrEmpty(ddlStatus.SelectedValue);

            if (NoFilter)
            {
                gvResults.DataSource = null;
                gvResults.DataBind();
                lblCount.Text = "Please apply a filter to search";
                lblCount.CssClass = "result-badge empty";
                return;
            }

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                // Query from MemberProfile (the comprehensive table) 
                // with LEFT JOIN to Member for any legacy fields
                StringBuilder sb = new StringBuilder(@"
                    SELECT TOP 500 
                        mp.MemberID,
                        ISNULL(mp.MemberNo, '') AS MemberNo,
                        ISNULL(mp.MemberName, '') AS MemberName,
                        ISNULL(mp.FatherName, '') AS FatherName,
                        ISNULL(mp.NIC, '') AS NIC,
                        ISNULL(mp.Mobile, '') AS ResidentialMobile,
                        ISNULL(mp.ResidentialCity, '') AS ResidentialCity,
                        ISNULL(mp.Occupation, '') AS Occupation,
                        ISNULL(mp.MemberCategory, '') AS MemberCategory,
                        ISNULL(mp.MemberType, '') AS MemberType,
                        ISNULL(mp.AccountStatus, '') AS AccountStatus,
                        ISNULL(mp.CompanyName, '') AS CompanyName,
                        ISNULL(mp.SpouseName, '') AS SpouseName,
                        ISNULL(mp.ResidentialEmail, '') AS ResidentialEmail,
                        ISNULL(mp.Nationality, '') AS Nationality,
                        ISNULL(mp.PassportNo, '') AS PassportNo,
                        ISNULL(mp.CoMemberNo, '') AS CoMemberNo,
                        mp.DOB
                    FROM MemberProfile mp
                    WHERE 1=1 ");

                List<SqlParameter> parameters = new List<SqlParameter>();

                // ══════════════════════════════════════════════
                //  UNIVERSAL SEARCH (search-engine style)
                //  Supports:
                //   - "+" as AND operator: "ali+doctor" → must match both
                //   - "%" as wildcard (like SQL LIKE)
                //   - Default: CONTAINS (any part of any field)
                // ══════════════════════════════════════════════
                string universalText = txtUniversalSearch.Text.Trim();
                if (!string.IsNullOrEmpty(universalText))
                {
                    // Split by + to get AND terms
                    string[] terms = universalText.Split(new char[] { '+' }, StringSplitOptions.RemoveEmptyEntries);

                    for (int i = 0; i < terms.Length; i++)
                    {
                        string term = terms[i].Trim();
                        if (string.IsNullOrEmpty(term)) continue;

                        // If user typed % characters, keep them as-is for wildcard
                        // Otherwise wrap with % for CONTAINS behavior
                        string likeTerm;
                        if (term.Contains("%"))
                        {
                            likeTerm = term; // User is controlling the wildcards themselves
                        }
                        else
                        {
                            likeTerm = "%" + term + "%"; // CONTAINS behavior
                        }

                        // Strip dashes for CNIC matching
                        string likeTermNoDash = likeTerm.Replace("-", "");

                        string paramName = "@UTerm" + i;
                        string paramNameNoDash = "@UTermND" + i;

                        sb.AppendFormat(@" AND (
                            mp.MemberNo LIKE {0}
                            OR mp.MemberName LIKE {0}
                            OR mp.FatherName LIKE {0}
                            OR REPLACE(mp.NIC, '-', '') LIKE {1}
                            OR mp.ResidentialMobile LIKE {0}
                            OR mp.ResidentialPhone1 LIKE {0}
                            OR mp.CompanyMobile LIKE {0}
                            OR mp.ResidentialEmail LIKE {0}
                            OR mp.CompanyEmail LIKE {0}
                            OR mp.ResidentialCity LIKE {0}
                            OR mp.CompanyCity LIKE {0}
                            OR mp.Occupation LIKE {0}
                            OR mp.CompanyName LIKE {0}
                            OR mp.CompanyInfoName LIKE {0}
                            OR mp.SpouseName LIKE {0}
                            OR mp.MemberCategory LIKE {0}
                            OR mp.MemberType LIKE {0}
                            OR mp.AccountStatus LIKE {0}
                            OR mp.Nationality LIKE {0}
                            OR mp.PassportNo LIKE {0}
                            OR mp.CoMemberNo LIKE {0}
                            OR mp.Designation LIKE {0}
                            OR mp.Remarks LIKE {0}
                            OR mp.Sector LIKE {0}
                            OR mp.PrintName LIKE {0}
                        ) ", paramName, paramNameNoDash);

                        parameters.Add(new SqlParameter(paramName, likeTerm));
                        parameters.Add(new SqlParameter(paramNameNoDash, likeTermNoDash));
                    }
                }

                // ══════════════════════════════════════════════
                //  INDIVIDUAL FIELD FILTERS (all use CONTAINS / LIKE)
                // ══════════════════════════════════════════════

                AddContainsFilter(sb, parameters, txtMemberNo.Text, "mp.MemberNo", "@FMemberNo");
                AddContainsFilter(sb, parameters, txtName.Text, "mp.MemberName", "@FName");
                AddContainsFilter(sb, parameters, txtFatherName.Text, "mp.FatherName", "@FFather");

                // CNIC: strip dashes for flexible matching
                string cnicFilter = txtCNIC.Text.Trim();
                if (!string.IsNullOrEmpty(cnicFilter))
                {
                    string cnicLike = cnicFilter.Contains("%") ? cnicFilter.Replace("-", "") : "%" + cnicFilter.Replace("-", "") + "%";
                    sb.Append(" AND REPLACE(mp.NIC, '-', '') LIKE @FCNIC ");
                    parameters.Add(new SqlParameter("@FCNIC", cnicLike));
                }

                // Mobile: search across multiple phone fields
                string mobileFilter = txtMobile.Text.Trim();
                if (!string.IsNullOrEmpty(mobileFilter))
                {
                    string mobileLike = mobileFilter.Contains("%") ? mobileFilter : "%" + mobileFilter + "%";
                    sb.Append(@" AND (
                        mp.ResidentialMobile LIKE @FMobile 
                        OR mp.ResidentialPhone1 LIKE @FMobile 
                        OR mp.CompanyMobile LIKE @FMobile 
                        OR mp.CompanyPhone1 LIKE @FMobile
                        OR mp.MailingPhone LIKE @FMobile
                    ) ");
                    parameters.Add(new SqlParameter("@FMobile", mobileLike));
                }

                // Email: search across email fields
                string emailFilter = txtEmail.Text.Trim();
                if (!string.IsNullOrEmpty(emailFilter))
                {
                    string emailLike = emailFilter.Contains("%") ? emailFilter : "%" + emailFilter + "%";
                    sb.Append(@" AND (
                        mp.ResidentialEmail LIKE @FEmail 
                        OR mp.CompanyEmail LIKE @FEmail
                        OR mp.MailingEmail LIKE @FEmail
                    ) ");
                    parameters.Add(new SqlParameter("@FEmail", emailLike));
                }

                // City: search across city fields
                string cityFilter = txtCity.Text.Trim();
                if (!string.IsNullOrEmpty(cityFilter))
                {
                    string cityLike = cityFilter.Contains("%") ? cityFilter : "%" + cityFilter + "%";
                    sb.Append(@" AND (
                        mp.ResidentialCity LIKE @FCity 
                        OR mp.CompanyCity LIKE @FCity
                        OR mp.MailingCity LIKE @FCity
                    ) ");
                    parameters.Add(new SqlParameter("@FCity", cityLike));
                }

                AddContainsFilter(sb, parameters, txtOccupation.Text, "mp.Occupation", "@FOccupation");
                AddContainsFilter(sb, parameters, txtCompany.Text, "mp.CompanyName", "@FCompany", "mp.CompanyInfoName");
                AddContainsFilter(sb, parameters, txtSpouseName.Text, "mp.SpouseName", "@FSpouse");
                AddContainsFilter(sb, parameters, txtNationality.Text, "mp.Nationality", "@FNationality");
                AddContainsFilter(sb, parameters, txtPassport.Text, "mp.PassportNo", "@FPassport");
                AddContainsFilter(sb, parameters, txtCoMemberNo.Text, "mp.CoMemberNo", "@FCoMember");

                // Dropdown exact matches
                if (!string.IsNullOrEmpty(ddlCategory.SelectedValue))
                {
                    sb.Append(" AND mp.MemberCategory = @FCategory ");
                    parameters.Add(new SqlParameter("@FCategory", ddlCategory.SelectedValue));
                }

                if (!string.IsNullOrEmpty(ddlMemberType.SelectedValue))
                {
                    sb.Append(" AND mp.MemberType = @FMemberType ");
                    parameters.Add(new SqlParameter("@FMemberType", ddlMemberType.SelectedValue));
                }

                if (!string.IsNullOrEmpty(ddlStatus.SelectedValue))
                {
                    sb.Append(" AND mp.AccountStatus = @FStatus ");
                    parameters.Add(new SqlParameter("@FStatus", ddlStatus.SelectedValue));
                }

                // Order by MemberNo
                sb.Append(" ORDER BY mp.MemberNo ");

                using (SqlCommand cmd = new SqlCommand(sb.ToString(), conn))
                {
                    foreach (SqlParameter p in parameters)
                    {
                        cmd.Parameters.Add(p);
                    }

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvResults.DataSource = dt;
                    gvResults.DataBind();

                    if (dt.Rows.Count > 0)
                    {
                        lblCount.Text = "Found " + dt.Rows.Count + " member" + (dt.Rows.Count > 1 ? "s" : "");
                        if (dt.Rows.Count >= 500)
                            lblCount.Text += " (showing first 500)";
                        lblCount.CssClass = "result-badge found";
                    }
                    else
                    {
                        lblCount.Text = "No results found";
                        lblCount.CssClass = "result-badge empty";
                    }
                }
            }
        }

        /// <summary>
        /// Helper: Adds a CONTAINS (LIKE '%term%') filter for a text field.
        /// Supports % wildcard if user typed it explicitly.
        /// Optionally searches an alternative column too (OR).
        /// </summary>
        private void AddContainsFilter(StringBuilder sb, List<SqlParameter> parameters, 
            string fieldValue, string columnName, string paramName, string altColumn = null)
        {
            string val = fieldValue.Trim();
            if (string.IsNullOrEmpty(val)) return;

            string likeTerm = val.Contains("%") ? val : "%" + val + "%";

            if (!string.IsNullOrEmpty(altColumn))
            {
                sb.AppendFormat(" AND ({0} LIKE {1} OR {2} LIKE {1}) ", columnName, paramName, altColumn);
            }
            else
            {
                sb.AppendFormat(" AND {0} LIKE {1} ", columnName, paramName);
            }

            parameters.Add(new SqlParameter(paramName, likeTerm));
        }

        /// <summary>
        /// Returns inline CSS for status badges based on the account status value.
        /// </summary>
        protected string GetStatusStyle(object statusObj)
        {
            string status = statusObj != null ? statusObj.ToString().ToLower().Trim() : "";
            string bg, color;

            switch (status)
            {
                case "active":
                    bg = "#dcfce7"; color = "#166534"; break;
                case "suspended":
                    bg = "#fef3c7"; color = "#92400e"; break;
                case "absentee":
                    bg = "#e0e7ff"; color = "#3730a3"; break;
                case "cancelled":
                case "resigned":
                    bg = "#fee2e2"; color = "#991b1b"; break;
                case "deceased":
                    bg = "#f1f5f9"; color = "#475569"; break;
                default:
                    bg = "#f1f5f9"; color = "#64748b"; break;
            }

            return string.Format(
                "background-color:{0};color:{1};padding:2px 8px;border-radius:12px;font-size:0.78rem;font-weight:600;white-space:nowrap;",
                bg, color);
        }

        protected string CalculateAge(object dobObj)
        {
            if (dobObj == null || dobObj == DBNull.Value || string.IsNullOrEmpty(dobObj.ToString()))
                return "-";

            DateTime dob;
            if (DateTime.TryParse(dobObj.ToString(), out dob))
            {
                int age = DateTime.Today.Year - dob.Year;
                if (dob.Date > DateTime.Today.AddYears(-age)) age--;
                return age.ToString() + " yrs";
            }
            return "-";
        }
    }
}
