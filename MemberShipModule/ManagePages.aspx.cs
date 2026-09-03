using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ManagePages : System.Web.UI.Page
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
            BindModuleDropdowns();
            BindGrid();
        }
    }

    private void BindModuleDropdowns()
    {
        string connStr = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;
        string query = "SELECT ModuleId, ModuleName FROM SysModules WHERE IsActive = 1 ORDER BY ModuleName";

        using (SqlConnection con = new SqlConnection(connStr))
        using (SqlCommand cmd = new SqlCommand(query, con))
        {
            con.Open();
            SqlDataReader dr = cmd.ExecuteReader();

            ddlModule.DataSource = dr;
            ddlModule.DataTextField = "ModuleName";
            ddlModule.DataValueField = "ModuleId";
            ddlModule.DataBind();
            dr.Close();

            // Re-run for filter dropdown
            dr = cmd.ExecuteReader();
            ddlFilterModule.DataSource = dr;
            ddlFilterModule.DataTextField = "ModuleName";
            ddlFilterModule.DataValueField = "ModuleId";
            ddlFilterModule.DataBind();
        }

        ddlModule.Items.Insert(0, new ListItem("-- Select Module --", "0"));
        ddlFilterModule.Items.Insert(0, new ListItem("All Modules", "0"));
    }

    private void BindGrid()
    {
        string connStr = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;
        string query = @"SELECT p.*, m.ModuleName 
                        FROM SysPages p 
                        INNER JOIN SysModules m ON p.ModuleId = m.ModuleId 
                        WHERE (@ModuleId = 0 OR p.ModuleId = @ModuleId)
                        ORDER BY m.ModuleName, p.SortOrder";

        using (SqlConnection con = new SqlConnection(connStr))
        using (SqlCommand cmd = new SqlCommand(query, con))
        {
            cmd.Parameters.AddWithValue("@ModuleId", ddlFilterModule.SelectedValue);
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            gvPages.DataSource = dt;
            gvPages.DataBind();
        }
    }

    protected void ddlFilterModule_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        string title = txtPageTitle.Text.Trim();
        string url = txtPageUrl.Text.Trim();
        string moduleId = ddlModule.SelectedValue;

        if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(url) || string.IsNullOrEmpty(moduleId))
        {
            ShowMessage("Module, Page Title, and URL are required.", false);
            return;
        }

        int pageId = 0;
        int.TryParse(hfPageId.Value, out pageId);
        int sortOrder = 0;
        int.TryParse(txtSortOrder.Text, out sortOrder);

        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            SqlCommand cmd;

            if (pageId > 0)
            {
                cmd = new SqlCommand(@"UPDATE SysPages SET ModuleId=@ModuleId, PageTitle=@Title, PageUrl=@Url, IconClass=@Icon, SortOrder=@Sort, IsActive=@Active WHERE PageId=@Id", con);
                cmd.Parameters.AddWithValue("@Id", pageId);
            }
            else
            {
                cmd = new SqlCommand(@"INSERT INTO SysPages (ModuleId, PageTitle, PageUrl, IconClass, SortOrder, IsActive) VALUES (@ModuleId, @Title, @Url, @Icon, @Sort, @Active)", con);
            }

            cmd.Parameters.AddWithValue("@ModuleId", moduleId);
            cmd.Parameters.AddWithValue("@Title", title);
            cmd.Parameters.AddWithValue("@Url", url);
            cmd.Parameters.AddWithValue("@Icon", txtIconClass.Text.Trim());
            cmd.Parameters.AddWithValue("@Sort", sortOrder);
            cmd.Parameters.AddWithValue("@Active", ddlIsActive.SelectedValue);

            cmd.ExecuteNonQuery();
        }

        ClearForm();
        BindGrid();
        ShowMessage(pageId > 0 ? "Page updated." : "Page created.", true);
        ((Masters_Site)this.Master).RefreshSidebar();
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ClearForm();
    }

    protected void gvPages_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int pageId = Convert.ToInt32(e.CommandArgument);

        if (e.CommandName == "EditPage")
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("SELECT * FROM SysPages WHERE PageId=@Id", con);
                cmd.Parameters.AddWithValue("@Id", pageId);
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    hfPageId.Value = pageId.ToString();
                    ddlModule.SelectedValue = dr["ModuleId"].ToString();
                    txtPageTitle.Text = dr["PageTitle"].ToString();
                    txtPageUrl.Text = dr["PageUrl"].ToString();
                    txtIconClass.Text = dr["IconClass"] != DBNull.Value ? dr["IconClass"].ToString() : "";
                    txtSortOrder.Text = dr["SortOrder"].ToString();
                    ddlIsActive.SelectedValue = Convert.ToBoolean(dr["IsActive"]) ? "1" : "0";
                }
            }
        }
        else if (e.CommandName == "DeletePage")
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                // Remove permissions
                SqlCommand cmd1 = new SqlCommand("DELETE FROM NavPermissions WHERE PageId=@Id", con);
                cmd1.Parameters.AddWithValue("@Id", pageId);
                cmd1.ExecuteNonQuery();

                // Remove page
                SqlCommand cmd2 = new SqlCommand("DELETE FROM SysPages WHERE PageId=@Id", con);
                cmd2.Parameters.AddWithValue("@Id", pageId);
                cmd2.ExecuteNonQuery();
            }
            BindGrid();
            ShowMessage("Page deleted.", true);
            ((Masters_Site)this.Master).RefreshSidebar();
        }
    }

    private void ClearForm()
    {
        hfPageId.Value = "0";
        ddlModule.SelectedIndex = 0;
        txtPageTitle.Text = "";
        txtPageUrl.Text = "";
        txtIconClass.Text = "";
        txtSortOrder.Text = "0";
        ddlIsActive.SelectedValue = "1";
    }

    private void ShowMessage(string msg, bool success)
    {
        lblMessage.Text = msg;
        lblMessage.CssClass = success ? "msg-success" : "msg-error";
        lblMessage.Visible = true;
    }
}
