using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class SiteMemberShipMaster : MasterPage
{
    private string connStr = ConfigurationManager.ConnectionStrings["Users_ConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // 🔐 Session Check
            if (Session["UserName"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            // 👤 User Display
            string displayName = "";
            if (Session["UserName"] != null)
                displayName = Session["UserName"].ToString();

            string empIdText = "";
            if (Session["Emp_ID"] != null)
                empIdText = " (" + Session["Emp_ID"].ToString() + ")";

            lblUser.Text = displayName + empIdText;

            // 🚀 Load Sidebar
            BindDynamicNav();
        }
    }

    // ============================
    // 🔹 Bind Main Modules
    // ============================
    private void BindDynamicNav()
    {
        try
        {
            string role = "";
            if (Session["UserRole"] != null)
                role = Session["UserRole"].ToString();

            // ❌ Skip for Member
            if (role == "Member") return;

            if (Session["Emp_ID"] == null) return;

            int empId = 0;
            if (!int.TryParse(Session["Emp_ID"].ToString(), out empId))
                return;

            DataTable dtModules = new DataTable();

            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("usp_MainMenu", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // ✅ Correct parameter
                    cmd.Parameters.Add("@EmpId", SqlDbType.Int).Value = empId;

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dtModules);
                }
            }

            rptModules.DataSource = dtModules;
            rptModules.DataBind();
        }
        catch (Exception ex)
        {
            Response.Write("<br><b>Main Menu Error:</b> " + ex.Message);
        }
    }

    // ============================
    // 🔹 Bind Sub Menu (Dropdown)
    // ============================
    protected void rptModules_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item ||
            e.Item.ItemType == ListItemType.AlternatingItem)
        {
            try
            {
                DataRowView row = (DataRowView)e.Item.DataItem;

                int moduleId = Convert.ToInt32(row["Module_ID"]);

                if (Session["Emp_ID"] == null) return;

                int empId = 0;
                if (!int.TryParse(Session["Emp_ID"].ToString(), out empId))
                    return;

                Repeater rptPages = (Repeater)e.Item.FindControl("rptPages");
                if (rptPages == null) return;

                DataTable dtPages = new DataTable();

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    using (SqlCommand cmd = new SqlCommand("usp_SubMenu", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        // ✅ EXACT MATCH WITH SP
                        cmd.Parameters.Add("@ModuleId", SqlDbType.Int).Value = moduleId;
                        cmd.Parameters.Add("@EmpId", SqlDbType.Int).Value = empId;

                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        da.Fill(dtPages);
                    }
                }

                // 🧪 Debug (optional)
                // Response.Write("<br>Module " + moduleId + " Pages: " + dtPages.Rows.Count);

                rptPages.DataSource = dtPages;
                rptPages.DataBind();
            }
            catch (Exception ex)
            {
                Response.Write("<br><b>Sub Menu Error:</b> " + ex.Message);
            }
        }
    }

    // ============================
    // 🔹 Refresh Sidebar (AJAX)
    // ============================
    public void RefreshSidebar()
    {
        BindDynamicNav();

        if (upSidebar != null)
            upSidebar.Update();
    }
}