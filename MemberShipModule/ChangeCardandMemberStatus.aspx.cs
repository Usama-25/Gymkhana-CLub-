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
            // Do not bind grid on initial load
        }
    }

    protected void BtnSearch_Click(object sender, EventArgs e)
    {
        BindGrid();
    }

    private void BindGrid()
    {
        string memberNo = txtMemberNo.Text.Trim();
        string memberName = txtMemberName.Text.Trim();
        string spouseName = txtSpouseName.Text.Trim();
        string cnic = txtCNIC.Text.Trim().Replace("-", "");
        string childName = txtChildName.Text.Trim();

        // Only search if at least one field is provided
        if (string.IsNullOrEmpty(memberNo) && 
            string.IsNullOrEmpty(memberName) && 
            string.IsNullOrEmpty(spouseName) && 
            string.IsNullOrEmpty(cnic) && 
            string.IsNullOrEmpty(childName))
        {
            rptMembers.DataSource = null;
            rptMembers.DataBind();
            return;
        }

        using (SqlConnection con = new SqlConnection(Con))
        {
            string query = @"
               SELECT DISTINCT 
                mp.M_ID,
                mp.MemberNo,
                mp.MemberName, 
                mp.SpouseName, 
                mp.NIC, 
                mp.AccountStatus, 
                mp.IsActive,
                mp.IsCardActive
            FROM MemberProfile mp
            LEFT JOIN MemberChildren mc ON mp.MemberId = mc.MemberId
            WHERE (@mNo = '' OR mp.MemberNo LIKE '%' + @mNo + '%')
              AND (@mName = '' OR mp.MemberName LIKE '%' + @mName + '%')
              AND (@sName = '' OR mp.SpouseName LIKE '%' + @sName + '%')
              AND (@cnic = '' OR REPLACE(mp.NIC, '-', '') LIKE '%' + @cnic + '%')
              AND (@cName = '' OR mc.ChildName LIKE '%' + @cName + '%')
            ORDER BY mp.MemberNo";

            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@mNo", memberNo);
                cmd.Parameters.AddWithValue("@mName", memberName);
                cmd.Parameters.AddWithValue("@sName", spouseName);
                cmd.Parameters.AddWithValue("@cnic", cnic);
                cmd.Parameters.AddWithValue("@cName", childName);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptMembers.DataSource = dt;
                rptMembers.DataBind();
            }
        } 
    }

    protected void rptMembers_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            // Find the ID and the nested GridView
            string memberId = DataBinder.Eval(e.Item.DataItem, "M_ID").ToString();
            GridView gvChildren = (GridView)e.Item.FindControl("gvChildren");

            if (gvChildren != null)
            {
                using (SqlConnection con = new SqlConnection(Con))
                {
                    string childQuery = "SELECT childname FROM MemberChildren WHERE M_ID = @MID";
                    SqlCommand cmd = new SqlCommand(childQuery, con);
                    cmd.Parameters.AddWithValue("@MID", memberId);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dtChildren = new DataTable();
                    da.Fill(dtChildren);

                    gvChildren.DataSource = dtChildren;
                    gvChildren.DataBind();
                }
            }
        }
    }
}