using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

// USAMA ------ //
public partial class AddPackageDeals : System.Web.UI.Page
{
    private readonly string constr = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            BindEventName();
            BindRestorentCataloage();
        }

    }


    //[System.Web.Services.WebMethod]
    //public static List<object> GetMainDeals()
    //{
    //    var list = new List<object>();
    //    string constr = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

    //    using (SqlConnection con = new SqlConnection(constr))
    //    using (SqlCommand cmd = new SqlCommand("SELECT DID, DealName FROM MainDeals", con))
    //    {
    //        con.Open();
    //        SqlDataReader rdr = cmd.ExecuteReader();
    //        while (rdr.Read())
    //        {
    //            list.Add(new
    //            {
    //                DID = rdr["DID"].ToString(),
    //                DealName = rdr["DealName"].ToString()
    //            });
    //        }
    //    }
    //    return list;
    //}


    //[System.Web.Services.WebMethod]
    //public static List<object> GetMenuListByDeal(int dealId)
    //{
    //    var list = new List<object>();
    //    string constr = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

    //    using (SqlConnection con = new SqlConnection(constr))
    //    using (SqlCommand cmd = new SqlCommand("SELECT Manu_Name, Category FROM MenuList WHERE DID = @DID", con))
    //    {
    //        cmd.Parameters.AddWithValue("@DID", dealId);
    //        con.Open();
    //        SqlDataReader rdr = cmd.ExecuteReader();
    //        while (rdr.Read())
    //        {
    //            list.Add(new
    //            {
    //                Manu_Name = rdr["Manu_Name"].ToString(),
    //                Category = rdr["Category"].ToString()
    //            });
    //        }
    //    }
    //    return list;
    //}


    //private void BindGrid()
    //{
    //    if (DdlMenu.SelectedValue == "0") return;

    //    using (SqlConnection con = new SqlConnection(constr))
    //    using (SqlCommand cmd = new SqlCommand("SELECT Manu_Name, Category FROM MenuList WHERE DID = @DID", con))
    //    {
    //        cmd.Parameters.AddWithValue("@DID", DdlMenu.SelectedValue);
    //        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
    //        {
    //            DataTable dt = new DataTable();
    //            da.Fill(dt);
    //            gvCart.DataSource = dt;
    //            gvCart.DataBind();
    //        }
    //    }
    //}

    //protected void gvCart_PageIndexChanging(object sender, GridViewPageEventArgs e)
    //{
    //    gvCart.PageIndex = e.NewPageIndex;
    //    BindGrid();
    //}


    //[System.Web.Services.WebMethod]
    //public static List<object> GetDealsByMenu(int menuId)
    //{
    //    var deals = new List<object>();
    //    string constr = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

    //    using (SqlConnection con = new SqlConnection(constr))
    //    using (SqlCommand cmd = new SqlCommand("SELECT ID, SuperName FROM BookingSetup WHERE DealLevel = @DID", con))
    //    {
    //        cmd.Parameters.AddWithValue("@DID", menuId);
    //        con.Open();

    //        using (SqlDataReader reader = cmd.ExecuteReader())
    //        {
    //            while (reader.Read())
    //            {
    //                deals.Add(new
    //                {
    //                    ID = reader["ID"].ToString(),
    //                    SuperName = reader["SuperName"].ToString()
    //                });
    //            }
    //        }
    //    }

    //    return deals;
    //}


    //[System.Web.Services.WebMethod]
    //public static string InsertMenuRecord(MenuData menu)
    //{
    //    try
    //    {
    //        string constr = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

    //        using (SqlConnection con = new SqlConnection(constr))
    //        using (SqlCommand cmd = new SqlCommand("usp_InsertDealWithMenuList", con))
    //        {
    //            cmd.CommandType = CommandType.StoredProcedure;

    //            cmd.Parameters.AddWithValue("@ID", menu.DealNameID);
    //            cmd.Parameters.AddWithValue("@DID", menu.DID);
    //            cmd.Parameters.AddWithValue("@Manu", menu.MenuName);
    //            cmd.Parameters.AddWithValue("@MenuName", menu.MenuName);
    //            cmd.Parameters.AddWithValue("@Category", menu.Category);


    //            int weightage = (menu.Category != null &&
    //                             menu.Category.Trim().Equals("Deal", StringComparison.OrdinalIgnoreCase))
    //                             ? 1 : -1;

    //            cmd.Parameters.AddWithValue("@Weightage", weightage);

    //            con.Open();
    //            cmd.ExecuteNonQuery();
    //        }

    //        return "success";
    //    }
    //    catch (Exception ex)
    //    {
    //        return ex.Message;
    //    }
    //}


    //public class MenuData
    //{
    //    public int DID { get; set; }
    //    public int DealNameID { get; set; }
    //    public string MenuName { get; set; }
    //    public string Category { get; set; }
    //}






    private void BindEventName()
    {
        using (SqlConnection con = new SqlConnection(constr))
        {
            SqlCommand cmd = new SqlCommand("SELECT DID, DealName FROM MainDeals", con);

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            DdlMenu.DataSource = dt;
            DdlMenu.DataTextField = "DealName";
            DdlMenu.DataValueField = "DID";
            DdlMenu.DataBind();

            DdlMenu.Items.Insert(0, new ListItem("--Select--", "0"));
        }
    }



    private void BindDeals()
    {
        using (SqlConnection con = new SqlConnection(constr))
        {
            SqlCommand cmd = new SqlCommand("SELECT ID, SuperName FROM BookingSetup WHERE DealLevel=@DealLevel", con);
            cmd.Parameters.AddWithValue("@DealLevel", DdlMenu.SelectedValue); 

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            ddlDealName.DataSource = dt;
            ddlDealName.DataTextField = "SuperName";
            ddlDealName.DataValueField = "ID";
            ddlDealName.DataBind();

            ddlDealName.Items.Insert(0, new ListItem("--Select--", "0"));

           
           
        }
    }



    protected void DdlMenu_TextChanged(object sender, EventArgs e)
    {
        BindDeals();
       
    }



    private void BindRestorentCataloage()
    {
        string query = "SELECT 0 as ItemCode ,'-All-' ItemName union all SELECT ItemCode, ItemName FROM Restaurant_Catalog";

        using (SqlConnection con = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString))
        {
            SqlDataAdapter da = new SqlDataAdapter(query, con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            ddlRestorentCataloage.DataSource = dt;
            ddlRestorentCataloage.DataTextField = "ItemName";
            ddlRestorentCataloage.DataValueField = "ItemCode";
            ddlRestorentCataloage.DataBind();

        }
    }

    private void UpdateCategoryByDealId()
    {
        using (SqlConnection con = new SqlConnection(constr))
        {
            string query = "SELECT Requird FROM BookingSetup WHERE ID = @ID";
            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@ID", ddlDealName.SelectedValue);

            con.Open();
            object result = cmd.ExecuteScalar();
            con.Close();

            if (result != null)
            {
                int requiredValue = Convert.ToInt32(result);

                string category = requiredValue == 1 ? "Deal" : "Other";

                if (ddlCategory.Items.FindByValue(category) != null)
                {
                    ddlCategory.SelectedValue = category;
                }


                Amount.Visible = (category == "Other");
            }
            else
            {
                ddlCategory.SelectedIndex = 0;
                Amount.Visible = false; 
            }
        }
    }

    protected void ddlDealName_TextChanged(object sender, EventArgs e)
    {
        UpdateCategoryByDealId();
    }


  protected void btnSave_Click(object sender, EventArgs e)
{
    int DID = int.Parse(DdlMenu.SelectedValue);
    int setupID = int.Parse(ddlDealName.SelectedValue);
    string ManuName = ddlDealName.SelectedItem.Text;
    string CatelogeItemCode = ddlRestorentCataloage.SelectedValue;
    string catelogeName = ddlRestorentCataloage.SelectedItem.Text;
    string category = ddlCategory.SelectedValue;

    decimal amountValue = 0;
    if(!decimal.TryParse(Amount.Text.Trim(), out amountValue))
    {
        ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Please enter a valid number for Amount');", true);
        return;
    }

    try
    {
        string constr = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

        using (SqlConnection con = new SqlConnection(constr))
        using (SqlCommand cmd = new SqlCommand("usp_InsertDealWithMenuList", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.AddWithValue("@ID", setupID);
            cmd.Parameters.AddWithValue("@DID", DID);
            cmd.Parameters.AddWithValue("@Manu", ManuName);
            cmd.Parameters.AddWithValue("@ItemCode", CatelogeItemCode);
            cmd.Parameters.AddWithValue("@MenuName", catelogeName);
            cmd.Parameters.AddWithValue("@Category", category);
            cmd.Parameters.AddWithValue("@Amount", amountValue);

            int weightage = (category != null &&
                             category.Trim().Equals("Deal", StringComparison.OrdinalIgnoreCase))
                             ? 1 : -1;

            cmd.Parameters.AddWithValue("@Weightage", weightage);

            con.Open();
            cmd.ExecuteNonQuery();
        }

        ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Menu added successfully!');", true);
    }
    catch (Exception ex)
    {
        ScriptManager.RegisterStartupScript(
            this,
            GetType(),
            "alert",
            "alert('Error: " + ex.Message.Replace("'", "") + "');",
            true);
    }
}


 
}


