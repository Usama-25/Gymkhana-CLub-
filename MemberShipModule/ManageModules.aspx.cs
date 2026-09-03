using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ManageModules : System.Web.UI.Page
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
            BindGrid();
    }

    private void BindGrid()
    {
        string cs = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;
        string query = "SELECT * FROM SysModules ORDER BY SortOrder";
        using (SqlConnection con = new SqlConnection(cs))
        using (SqlCommand cmd = new SqlCommand(query, con))
        {
            DataTable dt = new DataTable();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                da.Fill(dt);
            gvModules.DataSource = dt;
            gvModules.DataBind();
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        string name = txtModuleName.Text.Trim();
        if (string.IsNullOrEmpty(name))
        {
            ShowMessage("Module name is required.", false);
            return;
        }

        int moduleId = 0;
        int.TryParse(hfModuleId.Value, out moduleId);
        int sortOrder = 0;
        int.TryParse(txtSortOrder.Text, out sortOrder);

        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            SqlCommand cmd;

            if (moduleId > 0)
            {
                cmd = new SqlCommand(@"UPDATE SysModules SET ModuleName=@Name, IconClass=@Icon, SortOrder=@Sort, IsActive=@Active WHERE ModuleId=@Id", con);
                cmd.Parameters.AddWithValue("@Id", moduleId);
            }
            else
            {
                cmd = new SqlCommand(@"INSERT INTO SysModules (ModuleName, IconClass, SortOrder, IsActive) VALUES (@Name, @Icon, @Sort, @Active)", con);
            }

            cmd.Parameters.AddWithValue("@Name", name);
            cmd.Parameters.AddWithValue("@Icon", txtIconClass.Text.Trim());
            cmd.Parameters.AddWithValue("@Sort", sortOrder);
            cmd.Parameters.AddWithValue("@Active", ddlIsActive.SelectedValue);

            cmd.ExecuteNonQuery();
        }

        ClearForm();
        BindGrid();
        ShowMessage(moduleId > 0 ? "Module updated." : "Module created.", true);
        ((Masters_Site)this.Master).RefreshSidebar();
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ClearForm();
    }

    protected void gvModules_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int moduleId = Convert.ToInt32(e.CommandArgument);

        if (e.CommandName == "EditModule")
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("SELECT * FROM SysModules WHERE ModuleId=@Id", con);
                cmd.Parameters.AddWithValue("@Id", moduleId);
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    hfModuleId.Value = moduleId.ToString();
                    txtModuleName.Text = dr["ModuleName"].ToString();
                    txtIconClass.Text = dr["IconClass"].ToString();
                    txtSortOrder.Text = dr["SortOrder"].ToString();
                    ddlIsActive.SelectedValue = Convert.ToBoolean(dr["IsActive"]) ? "1" : "0";
                }
            }
        }
        else if (e.CommandName == "DeleteModule")
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                // Delete permissions for pages in this module
                SqlCommand cmd1 = new SqlCommand("DELETE FROM NavPermissions WHERE PageId IN (SELECT PageId FROM SysPages WHERE ModuleId=@Id)", con);
                cmd1.Parameters.AddWithValue("@Id", moduleId);
                cmd1.ExecuteNonQuery();

                // Delete pages
                SqlCommand cmd2 = new SqlCommand("DELETE FROM SysPages WHERE ModuleId=@Id", con);
                cmd2.Parameters.AddWithValue("@Id", moduleId);
                cmd2.ExecuteNonQuery();

                // Delete module
                SqlCommand cmd3 = new SqlCommand("DELETE FROM SysModules WHERE ModuleId=@Id", con);
                cmd3.Parameters.AddWithValue("@Id", moduleId);
                cmd3.ExecuteNonQuery();
            }
            BindGrid();
            ShowMessage("Module deleted.", true);
            ((Masters_Site)this.Master).RefreshSidebar();
        }
    }

    private void ClearForm()
    {
        hfModuleId.Value = "0";
        txtModuleName.Text = "";
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
