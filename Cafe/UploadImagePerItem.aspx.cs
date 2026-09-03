using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.IO;
using System.Web.UI.WebControls;


public partial class Pos : System.Web.UI.Page
{
     string conStr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;

     protected void Page_Load(object sender, EventArgs e)
     {
         if (!IsPostBack)
         {
             LoadMenuItems();
             BindMenuGrid(); 
         }
     }


    private void LoadMenuItems()
    {
        using (SqlConnection con = new SqlConnection(conStr))
        {
            string query = "SELECT Id, Name FROM MenuItems ORDER BY Name";
            SqlCommand cmd = new SqlCommand(query, con);
            con.Open();

            ddlMenuItems.DataSource = cmd.ExecuteReader();
            ddlMenuItems.DataTextField = "Name";
            ddlMenuItems.DataValueField = "Id";
            ddlMenuItems.DataBind();
        }

        ddlMenuItems.Items.Insert(0, new System.Web.UI.WebControls.ListItem("-- Select Item --", "0"));
    }

    protected void ddlMenuItems_SelectedIndexChanged(object sender, EventArgs e)
    {
        imgPreview.Visible = false;
        lblSavedPath.Text = "";
        txtImagePath.Text = "";
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (ddlMenuItems.SelectedValue == "0")
        {
            return;
        }

        string imagePath = txtImagePath.Text.Trim(); // path from textbox

        // ===== OPTION 1: FILE UPLOAD (OPTIONAL) =====
        if (fuImage.HasFile)
        {
            string folder = "~/resources/MenuImages/";
            string extension = Path.GetExtension(fuImage.FileName);
            string fileName = Guid.NewGuid().ToString() + extension;

           
            imagePath = folder + fileName;
        }

        if (string.IsNullOrEmpty(imagePath))
        {
            return;
        }

       
        using (SqlConnection con = new SqlConnection(conStr))
        {
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE MenuItems SET ImagePath = @ImagePath WHERE Id = @Id", con))
            {
                cmd.Parameters.Add("@ImagePath", SqlDbType.NVarChar, 500).Value = imagePath;
                cmd.Parameters.Add("@Id", SqlDbType.Int).Value = Convert.ToInt32(ddlMenuItems.SelectedValue);

                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

       
        lblSavedPath.Text = "Saved Image Path: " + imagePath;
        imgPreview.ImageUrl = imagePath;
        imgPreview.Visible = true;
    }

    
    private void BindMenuGrid()
    {
        using (SqlConnection con = new SqlConnection(conStr))
        {
            SqlDataAdapter da = new SqlDataAdapter("SELECT Id, Name, ImagePath FROM MenuItems", con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            gvMenuImages.DataSource = dt;
            gvMenuImages.DataBind();
        }
    }

    
    protected void gvMenuImages_RowEditing(object sender, GridViewEditEventArgs e)
    {
        gvMenuImages.EditIndex = e.NewEditIndex;
        BindMenuGrid();
    }

    
    protected void gvMenuImages_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
    {
        gvMenuImages.EditIndex = -1;
        BindMenuGrid();
    }

    
    protected void gvMenuImages_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        int id = Convert.ToInt32(gvMenuImages.DataKeys[e.RowIndex].Value);
        TextBox txtEditPath = (TextBox)gvMenuImages.Rows[e.RowIndex].FindControl("txtEditImagePath");
        string newPath = txtEditPath.Text.Trim();

        using (SqlConnection con = new SqlConnection(conStr))
        {
            SqlCommand cmd = new SqlCommand("UPDATE MenuItems SET ImagePath=@ImagePath WHERE Id=@Id", con);
            cmd.Parameters.AddWithValue("@ImagePath", newPath);
            cmd.Parameters.AddWithValue("@Id", id);
            con.Open();
            cmd.ExecuteNonQuery();
        }

        gvMenuImages.EditIndex = -1;
        BindMenuGrid();
    }

    
    protected void gvMenuImages_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "DeletePath")
        {
            int id = Convert.ToInt32(e.CommandArgument);
            using (SqlConnection con = new SqlConnection(conStr))
            {
                SqlCommand cmd = new SqlCommand("UPDATE MenuItems SET ImagePath=NULL WHERE Id=@Id", con);
                cmd.Parameters.AddWithValue("@Id", id);
                con.Open();
                cmd.ExecuteNonQuery();
            }
            BindMenuGrid();
        }
    }





}