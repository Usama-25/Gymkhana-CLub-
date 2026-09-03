using System;
using System.Web.UI;

namespace GymkhanaNew.LibraryManagement
{
    public partial class LibraryDashboard : Page
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
