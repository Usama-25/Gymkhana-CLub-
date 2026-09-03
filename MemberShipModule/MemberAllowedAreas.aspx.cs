using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RefundFee
{
    public partial class MemberSearch : Page
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
                ddlMember.Items.Clear();
                ddlMember.Items.Add(new ListItem("-- Select Member / Spouse / Child --", "0"));
                lblStatus.Text = "";
                pnlDepartment.Visible = false;
            }
        }

        // ================= Search Button =================
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string memberNo = txtMemberNo.Text.Trim();
            if (string.IsNullOrEmpty(memberNo))
            {
                lblStatus.Text = "Please enter a Member No!";
                lblStatus.ForeColor = System.Drawing.Color.Red;
                return;
            }

            lblStatus.Text = "";
            BindMemberDropdown(memberNo);

            // Load allowed areas from AllowedAreasMember table
            LoadAllowedAreasFromMemberTable(memberNo);

            // Load family members
            LoadFamilyMembersGrid(memberNo);
        }

        // ================= Bind dropdown for applicant/spouse/children =================
        private void BindMemberDropdown(string memberNo)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Text");
            dt.Columns.Add("Value");

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();

                // Applicant
                SqlCommand cmdMember = new SqlCommand(
                    "SELECT MemberID, ApplicantName FROM Member WHERE MemberNo=@MemberNo AND ApplicantName IS NOT NULL", con);
                cmdMember.Parameters.AddWithValue("@MemberNo", memberNo);
                SqlDataReader dr = cmdMember.ExecuteReader();
                while (dr.Read())
                    dt.Rows.Add(dr["ApplicantName"] + " (Member)", dr["MemberID"]);
                dr.Close();

                // Spouse
                SqlCommand cmdSpouse = new SqlCommand(@"
                    SELECT m.MemberID, p.SpouseName
                    FROM Member m
                    INNER JOIN MemberProfile p ON p.MemberID = m.MemberID
                    WHERE m.MemberNo=@MemberNo AND p.SpouseName IS NOT NULL", con);
                cmdSpouse.Parameters.AddWithValue("@MemberNo", memberNo);
                dr = cmdSpouse.ExecuteReader();
                while (dr.Read())
                    dt.Rows.Add(dr["SpouseName"] + " (Spouse)", dr["MemberID"]);
                dr.Close();

                // Children
                SqlCommand cmdChild = new SqlCommand(@"
                    SELECT m.MemberID, c.ChildName, c.Relationship
                    FROM Member m
                    INNER JOIN MemberChildren c ON c.MemberID = m.MemberID
                    WHERE m.MemberNo=@MemberNo", con);
                cmdChild.Parameters.AddWithValue("@MemberNo", memberNo);
                dr = cmdChild.ExecuteReader();
                while (dr.Read())
                    dt.Rows.Add(dr["ChildName"] + " (" + dr["Relationship"] + ")", dr["MemberID"]);
                dr.Close();
            }

            ddlMember.DataSource = dt;
            ddlMember.DataTextField = "Text";
            ddlMember.DataValueField = "Value";
            ddlMember.DataBind();

            ddlMember.Items.Insert(0, new ListItem("-- Select Member / Spouse / Child --", "0"));
        }

        // ================= Load allowed areas from AllowedAreasMember table =================
        private void LoadAllowedAreasFromMemberTable(string memberNo)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    SqlCommand cmd = new SqlCommand(@"
                        SELECT Id, AreaId, Areaname, MemberId, Relation, MemberName, dept_name, MemberNo
                        FROM AllowedAreasMember
                        WHERE MemberNo = @MemberNo
                        ORDER BY Id", con);
                    cmd.Parameters.AddWithValue("@MemberNo", memberNo);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        gvAllowedAreas.DataSource = dt;
                        gvAllowedAreas.DataBind();
                    }
                    else
                    {
                        gvAllowedAreas.DataSource = null;
                        gvAllowedAreas.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                lblStatus.Text = "Error loading allowed areas: " + ex.Message;
                lblStatus.ForeColor = System.Drawing.Color.Red;
            }
        }

        // ================= Family Members Grid =================
        private void LoadFamilyMembersGrid(string memberNo)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    SqlCommand cmdFamily = new SqlCommand(@"
                        SELECT m.MemberID, p.SpouseName, t.ChildName, t.Relationship
                        FROM Member m
                        LEFT JOIN MemberProfile p ON p.MemberID = m.MemberID
                        LEFT JOIN MemberChildren t ON t.MemberID = m.MemberID
                        WHERE m.MemberNo=@MemberNo", con);
                    cmdFamily.Parameters.AddWithValue("@MemberNo", memberNo);

                    SqlDataAdapter da = new SqlDataAdapter(cmdFamily);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        gvFamily.DataSource = dt;
                        gvFamily.DataBind();
                    }
                    else
                    {
                        gvFamily.DataSource = null;
                        gvFamily.DataBind();
                    }
                }
            }
            catch (Exception)
            {
                // Silent fail for family grid
                gvFamily.DataSource = null;
                gvFamily.DataBind();
            }
        }

        // ================= Add Button Click =================
        protected void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {
                string memberNo = txtMemberNo.Text.Trim();

                // Validation
                if (string.IsNullOrEmpty(memberNo))
                {
                    lblStatus.Text = "Please search for a member first!";
                    lblStatus.ForeColor = System.Drawing.Color.Red;
                    return;
                }

                if (ddlMember.SelectedValue == "0")
                {
                    lblStatus.Text = "Please select a member/spouse/child!";
                    lblStatus.ForeColor = System.Drawing.Color.Red;
                    return;
                }

                if (ddlDepartment.SelectedValue == "0")
                {
                    lblStatus.Text = "Please select a department!";
                    lblStatus.ForeColor = System.Drawing.Color.Red;
                    return;
                }

                // Get values
                int memberId = Convert.ToInt32(ddlMember.SelectedValue);
                string memberText = ddlMember.SelectedItem.Text;

                // Extract member name and relation
                string memberName = "";
                string relation = "";

                if (memberText.Contains("("))
                {
                    string[] parts = memberText.Split('(');
                    memberName = parts[0].Trim();
                    if (parts.Length > 1)
                    {
                        relation = parts[1].Replace(")", "").Trim();
                    }
                }
                else
                {
                    memberName = memberText;
                    relation = "Member";
                }

                int areaId = Convert.ToInt32(ddlDepartment.SelectedValue);
                string areaName = ddlDepartment.SelectedItem.Text;
                string deptName = areaName; // Same as area name

                // Check if record already exists
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    // Check for duplicate
                    SqlCommand chkCmd = new SqlCommand(@"
                        SELECT COUNT(*) FROM AllowedAreasMember 
                        WHERE MemberNo = @MemberNo 
                        AND MemberId = @MemberId 
                        AND AreaId = @AreaId", con);

                    chkCmd.Parameters.AddWithValue("@MemberNo", memberNo);
                    chkCmd.Parameters.AddWithValue("@MemberId", memberId);
                    chkCmd.Parameters.AddWithValue("@AreaId", areaId);

                    int count = (int)chkCmd.ExecuteScalar();

                    if (count > 0)
                    {
                        lblStatus.Text = "This area is already assigned to this member!";
                        lblStatus.ForeColor = System.Drawing.Color.Orange;
                        return;
                    }

                    // Insert new record
                    SqlCommand cmd = new SqlCommand(@"
                        INSERT INTO AllowedAreasMember 
                        (AreaId, Areaname, MemberId, Relation, MemberName, dept_name, MemberNo) 
                        VALUES 
                        (@AreaId, @Areaname, @MemberId, @Relation, @MemberName, @dept_name, @MemberNo)", con);

                    cmd.Parameters.AddWithValue("@AreaId", areaId);
                    cmd.Parameters.AddWithValue("@Areaname", areaName);
                    cmd.Parameters.AddWithValue("@MemberId", memberId);
                    cmd.Parameters.AddWithValue("@Relation", relation);
                    cmd.Parameters.AddWithValue("@MemberName", memberName);
                    cmd.Parameters.AddWithValue("@dept_name", deptName);
                    cmd.Parameters.AddWithValue("@MemberNo", memberNo);

                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        lblStatus.Text = "Area successfully added for " + memberName + "!";
                        lblStatus.ForeColor = System.Drawing.Color.Green;

                        // Refresh the allowed areas grid
                        LoadAllowedAreasFromMemberTable(memberNo);

                        // Clear selection
                        ddlDepartment.SelectedIndex = 0;
                    }
                    else
                    {
                        lblStatus.Text = "Failed to add area!";
                        lblStatus.ForeColor = System.Drawing.Color.Red;
                    }
                }
            }
            catch (Exception ex)
            {
                lblStatus.Text = "Error: " + ex.Message;
                lblStatus.ForeColor = System.Drawing.Color.Red;
            }
        }

        // ================= Revoke Button Click =================
        protected void btnRevoke_Click(object sender, EventArgs e)
        {
            try
            {
                string memberNo = txtMemberNo.Text.Trim();

                if (string.IsNullOrEmpty(memberNo))
                {
                    lblStatus.Text = "Please search for a member first!";
                    lblStatus.ForeColor = System.Drawing.Color.Red;
                    return;
                }

                if (ddlDepartment.SelectedValue == "0")
                {
                    lblStatus.Text = "Please select a department to revoke!";
                    lblStatus.ForeColor = System.Drawing.Color.Red;
                    return;
                }

                int areaId = Convert.ToInt32(ddlDepartment.SelectedValue);
                string areaName = ddlDepartment.SelectedItem.Text;

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand(@"
                        DELETE FROM AllowedAreasMember 
                        WHERE MemberNo = @MemberNo 
                        AND AreaId = @AreaId", con);

                    cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                    cmd.Parameters.AddWithValue("@AreaId", areaId);

                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        lblStatus.Text = "Area access revoked successfully!";
                        lblStatus.ForeColor = System.Drawing.Color.Green;

                        // Refresh the allowed areas grid
                        LoadAllowedAreasFromMemberTable(memberNo);

                        // Clear selection
                        ddlDepartment.SelectedIndex = 0;
                    }
                    else
                    {
                        lblStatus.Text = "No record found to revoke!";
                        lblStatus.ForeColor = System.Drawing.Color.Orange;
                    }
                }
            }
            catch (Exception ex)
            {
                lblStatus.Text = "Error: " + ex.Message;
                lblStatus.ForeColor = System.Drawing.Color.Red;
            }
        }

        // ================= Dropdown SelectedIndexChanged =================
        protected void ddlMember_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                if (ddlMember.SelectedValue != "0")
                {
                    // Show department panel
                    pnlDepartment.Visible = true;

                    // Load departments if not already loaded
                    if (ddlDepartment.Items.Count <= 1)
                    {
                        LoadDepartments();
                    }

                    lblStatus.Text = "";
                }
                else
                {
                    pnlDepartment.Visible = false;
                }
            }
            catch (Exception ex)
            {
                lblStatus.Text = "Error: " + ex.Message;
                lblStatus.ForeColor = System.Drawing.Color.Red;
            }
        }

        // ================= Load Departments =================
        private void LoadDepartments()
        {
            try
            {
                ddlDepartment.Items.Clear();
                ddlDepartment.Items.Add(new ListItem("-- Select Department --", "0"));

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("SELECT Dept_ID, Dept_Name FROM basicdatainfo.dbo.Department ORDER BY Dept_Name", con);
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        ddlDepartment.Items.Add(new ListItem(dr["Dept_Name"].ToString(), dr["Dept_ID"].ToString()));
                    }
                    dr.Close();
                }
            }
            catch (Exception ex)
            {
                lblStatus.Text = "Error loading departments: " + ex.Message;
                lblStatus.ForeColor = System.Drawing.Color.Red;
            }
        }
    }
}