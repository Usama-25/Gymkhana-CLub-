using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RefundFee
{
    public partial class SearchMemberForServices : Page
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
                BindGrid();
            }
        }

        private void BindGrid(string memberID = "", string nic = "", string name = "", string mobile = "")
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("SearchMembers", con);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@MemberID", memberID);
                cmd.Parameters.AddWithValue("@NIC", nic);
                cmd.Parameters.AddWithValue("@Name", name);
                cmd.Parameters.AddWithValue("@Mobile", mobile);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvMembers.DataSource = dt;
                gvMembers.DataBind();
            }
        }


        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindGrid(txtMemberID.Text.Trim(), txtNIC.Text.Trim(), txtName.Text.Trim(), txtMobile.Text.Trim());
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtMemberID.Text = "";
            txtNIC.Text = "";
            txtName.Text = "";
            txtMobile.Text = "";
            BindGrid();
        }

        protected void gvMembers_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvMembers.PageIndex = e.NewPageIndex;
            BindGrid(txtMemberID.Text.Trim(), txtNIC.Text.Trim(), txtName.Text.Trim(), txtMobile.Text.Trim());
        }
        protected void lnkservice_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            string memberID = btn.CommandArgument;
            string cardNo = btn.ToolTip;
            string url = "~/Member_Services.aspx?MemberID=" + memberID + "&CardNo=" + cardNo;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "openWindow", "window.open('" + ResolveUrl(url) + "', '_blank');", true);
        }


    }
}
