using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Data.SqlClient;

public partial class Store_Godown : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        gridGoDown.DataBind();
    }
    protected void btnSave_Click(object sender, EventArgs e)
    {
        try
        {
            string constring = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;
            SqlConnection con = new SqlConnection(constring);
            con.Open();
            SqlCommand cmd = new SqlCommand("INSERT INTO Godown(Godown_Name,Subdept_ID) Values(@Godown_Name,@Subdept_ID)", con);
            cmd.Parameters.AddWithValue("@Godown_Name", txtboxgodown.Text);
            cmd.Parameters.AddWithValue("@Subdept_ID", ddlDepartment.SelectedValue);     
            cmd.ExecuteNonQuery();
            con.Close();

            lblText.Text = "Your Given Information has been saved successfully!";
            lblText.ForeColor = System.Drawing.Color.Green;

            gridGoDown.DataBind();
        }
        catch (Exception)
        {
            lblText.Text = "There Is an Erorr FOr Sumitting Record!";
            lblText.ForeColor = System.Drawing.Color.Red;
        }

    }
}

