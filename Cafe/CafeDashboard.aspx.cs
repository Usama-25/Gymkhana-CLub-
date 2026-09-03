using System;
using System.Web.UI;

namespace GymkhanaNew.Cafe
{
    public partial class CafeDashboard : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserID"] == null)
                {
                    Response.Redirect("~/Login.aspx");
                }
            }
        }
    }
}
