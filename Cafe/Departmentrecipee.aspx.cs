using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Pos : System.Web.UI.Page
{
    string constr = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;
    string cons = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadDepartments();
            LoadItems();
        }
    }

    void LoadDepartments()
    {
        using (SqlConnection con = new SqlConnection(constr))
        {
            SqlCommand cmd = new SqlCommand("SELECT SubDept_Id, SubDept_Name FROM SubDepartment WHERE Dept_Id = 9 ORDER BY SubDept_Name", con);
            con.Open();
            ddlDepartment.DataSource = cmd.ExecuteReader();
            ddlDepartment.DataTextField = "SubDept_Name";
            ddlDepartment.DataValueField = "SubDept_Id";
            ddlDepartment.DataBind();
        }
        ddlDepartment.Items.Insert(0, new ListItem("-- Select Department --", ""));
    }

    void LoadItems()
    {
        using (SqlConnection con = new SqlConnection(cons))
        {
            SqlDataAdapter da = new SqlDataAdapter("SELECT ItemCode, ItemName FROM Restaurant_Catalog", con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            gvItems.DataSource = dt;
            gvItems.DataBind();
        }
    }

    void LoadCategories(DropDownList ddl)
    {
        using (SqlConnection con = new SqlConnection(cons))
        {
            string query = "SELECT CategoryID, CategoryName FROM dbo.RecipeCategory WHERE IsActive = 1 ORDER BY CategoryName";
            SqlDataAdapter da = new SqlDataAdapter(query, con);
            DataTable dt = new DataTable();
            da.Fill(dt);

            ddl.DataSource = dt;
            ddl.DataTextField = "CategoryName";
            ddl.DataValueField = "CategoryID";
            ddl.DataBind();
        }
        ddl.Items.Insert(0, new ListItem("-- Select Category --", ""));
    }

    protected void gvItems_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DropDownList ddlCat = (DropDownList)e.Row.FindControl("ddlCategory");
            if (ddlCat != null)
                LoadCategories(ddlCat);
        }
    }

    private DataTable SelectedItems
    {
        get
        {
            if (ViewState["SelectedItems"] == null)
            {
                DataTable dt = new DataTable();
                dt.Columns.Add("ItemCode");
                dt.Columns.Add("ItemName");
                dt.Columns.Add("CategoryID");
                dt.Columns.Add("Category");
                dt.Columns.Add("HalfPrice", typeof(decimal));
                dt.Columns.Add("FullPrice", typeof(decimal));
                ViewState["SelectedItems"] = dt;
            }
            return (DataTable)ViewState["SelectedItems"];
        }
        set { ViewState["SelectedItems"] = value; }
    }

    protected void btnAddSelection_Click(object sender, EventArgs e)
    {
        DataTable dt = SelectedItems;

        foreach (GridViewRow row in gvItems.Rows)
        {
            CheckBox chk = (CheckBox)row.FindControl("chkSelect");
            if (chk != null && chk.Checked)
            {
                string itemCode = row.Cells[1].Text;
                string itemName = row.Cells[2].Text;
                DropDownList ddlCat = (DropDownList)row.FindControl("ddlCategory");
                TextBox txtHalf = (TextBox)row.FindControl("txtHalfPrice");
                TextBox txtFull = (TextBox)row.FindControl("txtFullPrice");

                decimal half = 0, full = 0;
                decimal.TryParse(txtHalf.Text, out half);
                decimal.TryParse(txtFull.Text, out full);

                // Avoid duplicates
                bool exists = dt.Select("ItemCode='" + itemCode + "'").Length > 0;
                if (!exists)
                    dt.Rows.Add(itemCode, itemName, ddlCat.SelectedValue, ddlCat.SelectedItem.Text, half, full);
            }
        }

        SelectedItems = dt;
        gvSelected.DataSource = dt;
        gvSelected.DataBind();
    }

    protected void btnFinalSave_Click(object sender, EventArgs e)
    {
        if (ddlDepartment.SelectedValue == "")
            return;

        if (Session["Emp_ID"] == null)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "sess", "alert('Session expired');", true);
            return;
        }

        string empID = Session["Emp_ID"].ToString();
        DataTable dt = SelectedItems;
        if (dt.Rows.Count == 0) return;

        using (SqlConnection con = new SqlConnection(cons))
        {
            con.Open();
            foreach (DataRow row in dt.Rows)
            {
                SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO RecipeDepartmentMap
                    (Emp_ID, DepartmentID, ItemCode, ItemName, Category, HalfPrice, FullPrice)
                    VALUES
                    (@Emp_ID, @DeptID, @ItemCode, @ItemName, @Category, @HalfPrice, @FullPrice)", con);

                cmd.Parameters.AddWithValue("@Emp_ID", empID);
                cmd.Parameters.AddWithValue("@DeptID", ddlDepartment.SelectedValue);
                cmd.Parameters.AddWithValue("@ItemCode", row["ItemCode"]);
                cmd.Parameters.AddWithValue("@ItemName", row["ItemName"]);
                cmd.Parameters.AddWithValue("@Category", row["Category"]);
                cmd.Parameters.AddWithValue("@HalfPrice", row["HalfPrice"]);
                cmd.Parameters.AddWithValue("@FullPrice", row["FullPrice"]);

                cmd.ExecuteNonQuery();
            }
        }

        ScriptManager.RegisterStartupScript(this, GetType(), "ok", "alert('Selected items saved successfully!');", true);

        SelectedItems.Clear();
        gvSelected.DataSource = null;
        gvSelected.DataBind();
    }
}
