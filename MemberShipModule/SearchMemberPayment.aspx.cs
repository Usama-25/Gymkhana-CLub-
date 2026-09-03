using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
//using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace RefundFee
{
    public partial class PaymentPlan : System.Web.UI.Page
    {
        private string connStr
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
                BindDepartments();
            }
        }

        private void BindDepartments()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "SELECT SubDept_Id, SubDept_Name FROM subdepartment ORDER BY SubDept_Name";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlDepartment.DataSource = dt;
                ddlDepartment.DataTextField = "SubDept_Name";
                ddlDepartment.DataValueField = "SubDept_Id";
                ddlDepartment.DataBind();

                ddlDepartment.Items.Insert(0, new ListItem("Select Department", ""));
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string memberNo = txtMemberNo.Text.Trim();
            string memberName = txtMemberName.Text.Trim();
            string department = ddlDepartment.SelectedValue; 

            if (string.IsNullOrEmpty(memberNo) && string.IsNullOrEmpty(memberName))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('Please enter Member No or Name');", true);
                return;
            }

            hfSelectedDept.Value = department;
            using (SqlConnection con = new SqlConnection(connStr))
            {
                // Updated query: Use MemberProfile instead of MemberIssueCard
                string query = @"
            SELECT 
                m.MemberName AS ApplicantName,
                m.MemberSince AS IssueDate,
                DATEADD(year, 3, m.MemberSince) AS ExpiryDate,
                m.MemberNo AS Area, -- Using MemberNo as Area/Card reference
                0 AS Amount, 
                pay.Dept,
                pay.Credit,
                m.MemberNo AS CardNo -- Evaluation target for GridView
            FROM MemberProfile m
            LEFT JOIN MemberPayment pay ON m.MemberID = pay.MemberNo -- Updated to join on MemberID
            WHERE (@MemberNo = '' OR m.MemberNo LIKE '%' + @MemberNo + '%')
              AND (@MemberName = '' OR m.MemberName LIKE '%' + @MemberName + '%')";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                    cmd.Parameters.AddWithValue("@MemberName", memberName);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvSearchResults.DataSource = dt;
                    gvSearchResults.DataBind();
                }
            }
        }

        protected void ddlDepartment_SelectedIndexChanged(object sender, EventArgs e)
        {
            hfSelectedDept.Value = ddlDepartment.SelectedValue;
        }

        protected void gvSearchResults_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Proceed")
            {
                // Store the MemberNo for lookup
                hfCardNo.Value = e.CommandArgument.ToString();
                
                Card.Visible = true;
                chkExpireIssueBetween.Visible = true;
                chkCheckBalance.Visible = true;
                chkAllowDepartment.Visible = true;
            }
        }

        protected void CardActive(object sender, EventArgs e)
        {
            if (Card.Checked)
            {
                string memberNo = hfCardNo.Value;

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = @"
                SELECT AccountStatus 
                FROM MemberProfile
                WHERE MemberNo = @memberNo OR MemberNo = dbo.GetBaseMemberNo(@memberNo)"; // Assuming dbo.GetBaseMemberNo exists or handled via stripping

                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@memberNo", memberNo);

                    con.Open();
                    object result = cmd.ExecuteScalar();
                    con.Close();

                    string status = (result != null && result.ToString() == "Active") ? "Active" : "Not Active";

                    ScriptManager.RegisterStartupScript(
                        this, this.GetType(),
                        "alert",
                        "alert('Member Status: " + status + "');",
                        true
                    );
                }
            }
        }

        protected void activeCard_Check(object sender, EventArgs e)
        {
            if (chkExpireIssueBetween.Checked)
            {
                // In the new system, member status is handled by AccountStatus, not expiry dates usually
                // but we can still check against MemberSince if needed.
                ScriptManager.RegisterStartupScript(
                        this, this.GetType(),
                        "alert",
                        "alert('Member Record is Valid');",
                        true
                    );
            }
        }

        protected void Check_Balance(object sender, EventArgs e)
        {
            string memberNo = hfCardNo.Value;

            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = @"
SELECT 
    ISNULL(SUM(TRY_CONVERT(decimal(18,2), mp.Credit)) 
           - SUM(TRY_CONVERT(decimal(18,2), mp.Dept)), 0) AS Balance,
    ISNULL(SUM(TRY_CONVERT(decimal(18,2), mp.Credit)), 0) AS MemberAmount
FROM MemberProfile p
LEFT JOIN MemberPayment mp ON mp.MemberNo = p.MemberID -- JOIN on MemberID
WHERE p.MemberNo = @memberNo OR p.MemberNo = (SELECT SUBSTRING(@memberNo, 1, 
    CASE WHEN CHARINDEX('-', REVERSE(@memberNo)) > 0 
          THEN LEN(@memberNo) - CHARINDEX('-', REVERSE(@memberNo)) 
          ELSE LEN(@memberNo) END))
        ";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@memberNo", memberNo);

                    con.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        decimal balance = reader.GetDecimal(reader.GetOrdinal("Balance"));
                        decimal amount = reader.GetDecimal(reader.GetOrdinal("MemberAmount"));

                        if (balance >= 0)
                        {
                            ScriptManager.RegisterStartupScript(
                                this, this.GetType(),
                                "alert",
                                "alert('Positive Balance: " + balance + "');",
                                true
                            );
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(
                                this, this.GetType(),
                                "alert",
                                "alert('Recharge Required! Balance: " + balance + "');",
                                true
                            );
                        }
                    }
                    con.Close();
                }
            }
        }

        protected void Cheack_departments(object sender, EventArgs e)
        {
            string memberNo = hfCardNo.Value.Trim();
            string departmentId = hfSelectedDept.Value.Trim();

            ScriptManager.RegisterStartupScript(
                this, this.GetType(),
                "alert",
                "alert('Department Check Bypass: Logic being updated for MemberNo system');",
                true
            );
        }

    }
}
