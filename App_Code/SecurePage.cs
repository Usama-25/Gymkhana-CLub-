using System;
using System.Web;

namespace GuestRoomApp.GuestRoomM
{
    public class SecurePage : System.Web.UI.Page
    {
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            if (Session["UserName"] == null || Session["emp_id"] == null)
            {
                string loginPath = ResolveUrl("~/MemberShipModule/Login.aspx");
                Response.Redirect(loginPath + "?Msg=Session Expired. Please Login Again.");
            }
        }
    }
}
