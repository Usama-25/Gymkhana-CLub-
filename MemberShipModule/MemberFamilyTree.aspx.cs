using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ApplicationProcessing : System.Web.UI.Page
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
            
        }
    }

    protected void BtnSearch_Click(object sender, EventArgs e)
    {
        BindGrid();
    }

    private void BindGrid()
    {
        string cleanNIC = txtCNIC.Text.Trim().Replace("-", "");

        using (SqlConnection con = new SqlConnection(Con))
        {
            
            using (SqlCommand cmd = new SqlCommand("usp_SearchMemberFamilyTree", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@mNo", SqlDbType.NVarChar, 50).Value = txtMemberNo.Text.Trim();
                cmd.Parameters.Add("@mName", SqlDbType.NVarChar, 200).Value = txtMemberName.Text.Trim();
                cmd.Parameters.Add("@sName", SqlDbType.NVarChar, 200).Value = txtSpouseName.Text.Trim();
                cmd.Parameters.Add("@cnic", SqlDbType.NVarChar, 50).Value = cleanNIC;
                cmd.Parameters.Add("@cName", SqlDbType.NVarChar, 200).Value = txtChildName.Text.Trim();

                try
                {
                    con.Open();
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        rptMembers.DataSource = dt;
                        rptMembers.DataBind();
                    }
                }
                catch (Exception ex)
                {
                    
                    string cleanMessage = ex.Message.Replace("'", "\\'");

                    
                    string script = "alert('Search Error: " + cleanMessage + "');";

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "error", script, true);
                }
            }
        }
    }

    protected void rptMembers_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            DataRowView row = (DataRowView)e.Item.DataItem;
            string memberId = row["MemberID"].ToString();
            string memberName = row["membername"].ToString();
            string spouseName = row["spousename"].ToString();
            
            Repeater rptFamilyList = (Repeater)e.Item.FindControl("rptFamilyList");
            Label lblNoChildren = (Label)e.Item.FindControl("lblNoChildren");
            Literal litMermaidFamily = (Literal)e.Item.FindControl("litMermaidFamily");

            if (string.IsNullOrEmpty(memberId)) return;

            // Start Building Mermaid Definition
            System.Text.StringBuilder mermaid = new System.Text.StringBuilder();
            mermaid.AppendLine("graph TD");
            
            // Define Styles
            mermaid.AppendLine("classDef head fill:#dbeafe,stroke:#2563eb,stroke-width:2px;");
            mermaid.AppendLine("classDef spouse fill:#fce7f3,stroke:#db2777,stroke-width:2px;");
            mermaid.AppendLine("classDef child fill:#f0fdf4,stroke:#16a34a,stroke-width:2px;");

            // Sanitize IDs and names for Mermaid.js syntax
            string cleanMemberId = System.Text.RegularExpressions.Regex.Replace(memberId, @"[^a-zA-Z0-9_]", "_");
            string safeMemberName = memberName.Replace("\"", "'");
            string safeSpouseName = spouseName.Replace("\"", "'");

            // Add Head
            string headId = "H" + cleanMemberId;
            mermaid.AppendLine(headId + "[\"" + safeMemberName + "<br/>(Head)\"]");
            mermaid.AppendLine("class " + headId + " head");

            // Add Spouse if exists
            if (!string.IsNullOrEmpty(spouseName))
            {
                string spouseId = "S" + cleanMemberId;
                mermaid.AppendLine(spouseId + "[\"" + safeSpouseName + "<br/>(Spouse)\"]");
                mermaid.AppendLine(headId + " --> " + spouseId);
                mermaid.AppendLine("class " + spouseId + " spouse");
            }

            using (SqlConnection con = new SqlConnection(Con))
            {
                using (SqlCommand cmd = new SqlCommand("usp_GetMemberChildren", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@mid", SqlDbType.Int).Value = memberId;
                    try
                    {
                        con.Open();
                        using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                        {
                            DataTable dtChildren = new DataTable();
                            sda.Fill(dtChildren);

                            if (dtChildren.Rows.Count > 0)
                            {
                                rptFamilyList.DataSource = dtChildren;
                                rptFamilyList.DataBind();
                                lblNoChildren.Visible = false;

                                // Add Children to Graph
                                int childIndex = 0;
                                string parentIdForChildren = !string.IsNullOrEmpty(spouseName) ? "S" + cleanMemberId : headId;
                                foreach (DataRow childRow in dtChildren.Rows)
                                {
                                    string cName = childRow["childname"].ToString();
                                    string rel = childRow["Relationship"].ToString();
                                    string cId = "C" + cleanMemberId + "_" + (childIndex++);
                                    string safeChildName = cName.Replace("\"", "'");
                                    
                                    mermaid.AppendLine(cId + "[\"" + safeChildName + "<br/>(" + rel + ")\"]");
                                    mermaid.AppendLine(parentIdForChildren + " --> " + cId);
                                    mermaid.AppendLine("class " + cId + " child");
                                }
                            }
                            else
                            {
                                rptFamilyList.Visible = false;
                                lblNoChildren.Visible = true;
                            }
                        }
                    }
                    catch (Exception)
                    {
                        lblNoChildren.Text = "Error loading children details.";
                        lblNoChildren.Visible = true;
                    }
                }
            }
            
            litMermaidFamily.Text = mermaid.ToString();
        }
    }
}