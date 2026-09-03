using System;
using System.Web.UI;

namespace GymkhanaNew.Baquetsystems
{
    public partial class BanquetDashboard : Page
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
