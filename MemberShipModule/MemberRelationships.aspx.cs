using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MemberShip
{
    public partial class MemberRelationships : System.Web.UI.Page
    {
        private string strConn
        {
            get
            {
                var s = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
                return s != null ? s.ConnectionString : "";
            }
        }
        private int CurrentMemberID
        {
            get { return ViewState["CurrentMemberID"] != null ? (int)ViewState["CurrentMemberID"] : 0; }
            set { ViewState["CurrentMemberID"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                pnlSelectedMember.Visible = false;
                pnlAddRelationship.Visible = false;
                pnlRelationships.Visible = false;
            }
        }

        protected void btnSearchMember_Click(object sender, EventArgs e)
        {
            using (SqlConnection con = new SqlConnection(strConn))
            {
                string sql = @"SELECT TOP 1 MemberID, MemberNo, MemberName, Gender 
                              FROM MemberProfile 
                              WHERE (@MemberNo = '' OR MemberNo = @MemberNo)
                                AND (@Name = '' OR MemberName LIKE '%' + @Name + '%')";

                SqlCommand cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@MemberNo", txtMemberNo.Text.Trim());
                cmd.Parameters.AddWithValue("@Name", txtMemberName.Text.Trim());

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    CurrentMemberID = Convert.ToInt32(dr["MemberID"]);
                    lblMemberNo.Text = dr["MemberNo"].ToString();
                    lblMemberName.Text = dr["MemberName"].ToString();

                    pnlSelectedMember.Visible = true;
                    pnlAddRelationship.Visible = true;
                    pnlRelationships.Visible = true;

                    dr.Close();
                    LoadRelationships();
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", 
                        "alert('Member not found. Please check Member No or Name.');", true);
                    pnlSelectedMember.Visible = false;
                    pnlAddRelationship.Visible = false;
                    pnlRelationships.Visible = false;
                }
            }
        }

        protected void btnSearchRelated_Click(object sender, EventArgs e)
        {
            using (SqlConnection con = new SqlConnection(strConn))
            {
                string sql = @"SELECT TOP 1 MemberNo, MemberName 
                              FROM MemberProfile 
                              WHERE (@MemberNo = '' OR MemberNo = @MemberNo)
                                AND (@Name = '' OR MemberName LIKE '%' + @Name + '%')";

                SqlCommand cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@MemberNo", txtRelatedMemberNo.Text.Trim());
                cmd.Parameters.AddWithValue("@Name", txtRelatedMemberName.Text.Trim());

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    txtRelatedMemberNo.Text = dr["MemberNo"].ToString();
                    txtRelatedMemberName.Text = dr["MemberName"].ToString();
                    ScriptManager.RegisterStartupScript(this, GetType(), "success", 
                        "alert('Member found! Now select relationship type and click Add Relationship.');", true);
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", 
                        "alert('Related member not found.');", true);
                }
            }
        }

        protected void btnAddRelationship_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtRelatedMemberNo.Text.Trim()))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", 
                    "alert('Please search and select a related member first.');", true);
                return;
            }

            if (string.IsNullOrEmpty(ddlRelationshipType.SelectedValue))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", 
                    "alert('Please select a relationship type.');", true);
                return;
            }

            using (SqlConnection con = new SqlConnection(strConn))
            {
                con.Open();

                // Get related member ID and gender
                SqlCommand cmdGetRelated = new SqlCommand(
                    "SELECT MemberID, Gender FROM MemberProfile WHERE MemberNo = @MemberNo", con);
                cmdGetRelated.Parameters.AddWithValue("@MemberNo", txtRelatedMemberNo.Text.Trim());
                SqlDataReader dr = cmdGetRelated.ExecuteReader();

                if (!dr.Read())
                {
                    dr.Close();
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", 
                        "alert('Related member not found.');", true);
                    return;
                }

                int relatedMemberID = Convert.ToInt32(dr["MemberID"]);
                string relatedGender = dr["Gender"].ToString();
                dr.Close();

                // Check if same member
                if (CurrentMemberID == relatedMemberID)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", 
                        "alert('Cannot add relationship to the same member.');", true);
                    return;
                }

                // Get current member gender for reciprocal relationship
                SqlCommand cmdGetCurrent = new SqlCommand(
                    "SELECT Gender FROM MemberProfile WHERE MemberID = @MemberID", con);
                cmdGetCurrent.Parameters.AddWithValue("@MemberID", CurrentMemberID);
                string currentGender = cmdGetCurrent.ExecuteScalar().ToString() ?? "Male";

                string relationshipType = ddlRelationshipType.SelectedValue;
                string reciprocalType = GetReciprocalRelationType(relationshipType, currentGender, relatedGender);

                using (SqlTransaction transaction = con.BeginTransaction())
                {
                    try
                    {
                        // Insert primary relationship
                        SqlCommand cmd1 = new SqlCommand(@"
                            IF NOT EXISTS (SELECT 1 FROM MemberRelationships 
                                          WHERE MemberID = @MemberID AND RelatedMemberID = @RelatedMemberID 
                                          AND RelationshipType = @RelationshipType)
                            BEGIN
                                INSERT INTO MemberRelationships (MemberID, RelatedMemberID, RelationshipType, CreatedBy)
                                VALUES (@MemberID, @RelatedMemberID, @RelationshipType, @CreatedBy)
                            END", con, transaction);

                        cmd1.Parameters.AddWithValue("@MemberID", CurrentMemberID);
                        cmd1.Parameters.AddWithValue("@RelatedMemberID", relatedMemberID);
                        cmd1.Parameters.AddWithValue("@RelationshipType", relationshipType);
                        cmd1.Parameters.AddWithValue("@CreatedBy", User.Identity.Name ?? "System");
                        cmd1.ExecuteNonQuery();

                        // Insert reciprocal relationship
                        SqlCommand cmd2 = new SqlCommand(@"
                            IF NOT EXISTS (SELECT 1 FROM MemberRelationships 
                                          WHERE MemberID = @MemberID AND RelatedMemberID = @RelatedMemberID 
                                          AND RelationshipType = @RelationshipType)
                            BEGIN
                                INSERT INTO MemberRelationships (MemberID, RelatedMemberID, RelationshipType, CreatedBy)
                                VALUES (@MemberID, @RelatedMemberID, @RelationshipType, @CreatedBy)
                            END", con, transaction);

                        cmd2.Parameters.AddWithValue("@MemberID", relatedMemberID);
                        cmd2.Parameters.AddWithValue("@RelatedMemberID", CurrentMemberID);
                        cmd2.Parameters.AddWithValue("@RelationshipType", reciprocalType);
                        cmd2.Parameters.AddWithValue("@CreatedBy", User.Identity.Name ?? "System");
                        cmd2.ExecuteNonQuery();

                        transaction.Commit();

                        ScriptManager.RegisterStartupScript(this, GetType(), "success", 
                            "alert('Relationship added successfully! {lblMemberName.Text} is {relationshipType} of {txtRelatedMemberName.Text}. Reciprocal: {txtRelatedMemberName.Text} is {reciprocalType} of {lblMemberName.Text}');", true);

                        // Clear fields and reload
                        txtRelatedMemberNo.Text = "";
                        txtRelatedMemberName.Text = "";
                        ddlRelationshipType.SelectedIndex = 0;
                        LoadRelationships();
                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        ScriptManager.RegisterStartupScript(this, GetType(), "error", 
                            "alert('Error adding relationship: {ex.Message}');", true);
                    }
                }
            }
        }

        private string GetReciprocalRelationType(string relationType, string currentGender, string relatedGender)
        {
            // Determine reciprocal relationship based on type and genders
            switch (relationType)
            {
                case "Father":
                    return relatedGender == "Male" ? "Son" : "Daughter";
                case "Mother":
                    return relatedGender == "Male" ? "Son" : "Daughter";
                case "Son":
                    return currentGender == "Male" ? "Father" : "Mother";
                case "Daughter":
                    return currentGender == "Male" ? "Father" : "Mother";
                case "Brother":
                    return relatedGender == "Male" ? "Brother" : "Sister";
                case "Sister":
                    return relatedGender == "Male" ? "Brother" : "Sister";
                case "Spouse":
                    return "Spouse";
                default:
                    return relationType;
            }
        }

        private void LoadRelationships()
        {
            using (SqlConnection con = new SqlConnection(strConn))
            {
                string sql = @"SELECT r.RelationshipID, r.RelationshipType, 
                              mp.MemberNo AS RelatedMemberNo, mp.MemberName AS RelatedMemberName
                              FROM MemberRelationships r
                              INNER JOIN MemberProfile mp ON r.RelatedMemberID = mp.MemberID
                              WHERE r.MemberID = @MemberID
                              ORDER BY r.RelationshipType, mp.MemberName";

                SqlCommand cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@MemberID", CurrentMemberID);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvRelationships.DataSource = dt;
                gvRelationships.DataBind();
            }
        }

        protected void gvRelationships_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteRelation")
            {
                int rowIndex = Convert.ToInt32(e.CommandArgument);
                int relationshipID = Convert.ToInt32(gvRelationships.DataKeys[rowIndex].Value);

                using (SqlConnection con = new SqlConnection(strConn))
                {
                    con.Open();
                    using (SqlTransaction transaction = con.BeginTransaction())
                    {
                        try
                        {
                            // Get the related member ID first
                            SqlCommand cmdGet = new SqlCommand(
                                "SELECT MemberID, RelatedMemberID FROM MemberRelationships WHERE RelationshipID = @RelationshipID",
                                con, transaction);
                            cmdGet.Parameters.AddWithValue("@RelationshipID", relationshipID);
                            SqlDataReader dr = cmdGet.ExecuteReader();

                            if (dr.Read())
                            {
                                int memberID = Convert.ToInt32(dr["MemberID"]);
                                int relatedMemberID = Convert.ToInt32(dr["RelatedMemberID"]);
                                dr.Close();

                                // Delete primary relationship
                                SqlCommand cmd1 = new SqlCommand(
                                    "DELETE FROM MemberRelationships WHERE RelationshipID = @RelationshipID",
                                    con, transaction);
                                cmd1.Parameters.AddWithValue("@RelationshipID", relationshipID);
                                cmd1.ExecuteNonQuery();

                                // Delete reciprocal relationship
                                SqlCommand cmd2 = new SqlCommand(
                                    "DELETE FROM MemberRelationships WHERE MemberID = @MemberID AND RelatedMemberID = @RelatedMemberID",
                                    con, transaction);
                                cmd2.Parameters.AddWithValue("@MemberID", relatedMemberID);
                                cmd2.Parameters.AddWithValue("@RelatedMemberID", memberID);
                                cmd2.ExecuteNonQuery();

                                transaction.Commit();

                                ScriptManager.RegisterStartupScript(this, GetType(), "success",
                                    "alert('Relationship deleted successfully (both sides removed).');", true);

                                LoadRelationships();
                            }
                        }
                        catch (Exception ex)
                        {
                            transaction.Rollback();
                            ScriptManager.RegisterStartupScript(this, GetType(), "error",
                                "alert('Error deleting relationship: {ex.Message}');", true);
                        }
                    }
                }
            }
        }
    }
}
