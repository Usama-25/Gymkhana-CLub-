using System;
using System.Web.UI;

namespace GymkhanaNew.MasterPages
{
    public partial class GymkhanaMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserID"] == null)
                {
                    Response.Redirect("~/Login.aspx");
                }
                else
                {
                    lblUserName.Text = Session["UserName"] != null ? Session["UserName"].ToString() : Session["UserID"].ToString();
                }
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Login.aspx");
        }
    }
}
