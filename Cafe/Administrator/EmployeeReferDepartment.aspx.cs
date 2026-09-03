using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

public partial class Store_EmployeeReferDepartment : System.Web.UI.Page
{
    String connection = ConfigurationManager.ConnectionStrings["Reg_ConnectionString"].ToString();
    protected void Page_Load(object sender, EventArgs e)
    {
       
        if (!IsPostBack)
        {

            Bind_subDept();
            Bind_Employee();

            ShowData();

        }
    }

    public void Bind_subDept()
    {
        SqlConnection conn = new SqlConnection(connection);
        try
        {
            conn.Open();
            string P = string.Empty;
            string query = "select SubDept_Id, SubDept_Name from SubDepartment where  SubDept_Name like +@SubDept_Name";
            if (!string.IsNullOrEmpty(txtsubDept.Text.Trim()))
            { P = "%" + txtsubDept.Text.Trim() + "%"; } else
            { P =  "%"; }
            SqlCommand sc = new SqlCommand(query, conn);
            sc.CommandType = CommandType.Text;
            sc.Parameters.AddWithValue("@SubDept_Name", P);
           

            SqlDataReader dr = sc.ExecuteReader();

            if (dr.HasRows)
            {
                ddl_subDept.DataSource = dr;
                ddl_subDept.DataTextField = "SubDept_Name";
                ddl_subDept.DataValueField = "SubDept_Id";
                ddl_subDept.DataBind();
            }
            else
            {
                ddl_subDept.Items.Clear();
            //    ddl_subDept.Items.Add("--Lab Machines--");
            }

          
            dr.Close();
        }
        catch (Exception ex)
        {
            Response.Write(ex);
        }
        finally
        {
           
            conn.Close();
        }

    }

    public void Bind_Employee()
    {
        SqlConnection conn = new SqlConnection(connection);
        try
        {

            conn.Open();

            
            SqlCommand sc = new SqlCommand("Select_AllEmployeewithDesignation", conn);
            sc.CommandType = CommandType.StoredProcedure;
            sc.Parameters.AddWithValue("@EFName", txtemployee.Text);
            SqlDataReader dr = sc.ExecuteReader();

             if (dr.HasRows)
                {
                ddl_employee.DataSource = dr;
                ddl_employee.DataTextField = "EmployeeName";
                ddl_employee.DataValueField = "EmpID";
                ddl_employee.DataBind();
                }
                else
                {
                ddl_employee.Items.Clear();
                }


                dr.Close();

            

            }
        catch (Exception ex)
        {
            Response.Write(ex);
        }
        finally
        {

            conn.Close();
        }
    
            

    }
    protected void ShowData()
    {
        SqlConnection conn = new SqlConnection(connection);
        try
        {
           
            conn.Open();
            SqlCommand sc = new SqlCommand("Select_EmployeeDepartmentsRefers", conn);
            sc.CommandType = CommandType.StoredProcedure;
            sc.ExecuteNonQuery();
            SqlDataAdapter sda = new SqlDataAdapter(sc);
            DataTable dt = new DataTable();
            sda.Fill(dt);

            GridView1.DataSource = dt;
            GridView1.DataBind();
        }
        catch { }
        finally
        {
           
            conn.Close();
        }
    }
    protected void btnSave_Click(object sender, EventArgs e)
    {
        SqlConnection conn = new SqlConnection(connection);
        SqlCommand sc;
        try
        {
            conn.Open();
           
            sc = new SqlCommand(@"INSERT INTO employeeDepartmentsRefers (SubDept_ID, EmpID)
                                            VALUES( '" + (ddl_subDept.SelectedValue) + "', '" + (ddl_employee.SelectedValue) + "')", conn);
            sc.ExecuteNonQuery();
                       
             ScriptManager.RegisterStartupScript(this, this.GetType(), "script", "alert('Successfully inserted');", true);
            Bind_Employee();

        }
        catch (Exception)
        { }
        finally
        { 
            conn.Close();
            ShowData();
        }
    }
  

    



    protected void btnSearch_Click(object sender, EventArgs e)
    {
        SqlConnection conn = new SqlConnection(connection);
        try
        {

            conn.Open();
            SqlCommand sc = new SqlCommand("Select_EmployeeDepartmentsRefers", conn);
            sc.CommandType = CommandType.StoredProcedure;
            sc.Parameters.AddWithValue("@SubDept_ID", ddl_subDept.SelectedValue);
            sc.Parameters.AddWithValue("@EmpID", ddl_employee.SelectedValue);
            sc.ExecuteNonQuery();
            SqlDataAdapter sda = new SqlDataAdapter(sc);
            DataTable dt = new DataTable();
            sda.Fill(dt);

            GridView1.DataSource = dt;
            GridView1.DataBind();
        }
        catch { }
        finally
        {

            conn.Close();
        }
    }

   

    protected void btnDelete_Click(object sender, EventArgs e)
    {
        LinkButton lbtn = sender as LinkButton;
        int id = Convert.ToInt32(lbtn.CommandArgument);
        lbtn.CommandArgument = "";
       
        SqlConnection conn = new SqlConnection(connection);
        try
        {
            conn.Open();
            SqlCommand sc = new SqlCommand("Delete from employeeDepartmentsRefers where ID=@ID", conn);
            sc.CommandType = CommandType.Text;
            sc.Parameters.AddWithValue("@ID", id);
            sc.ExecuteNonQuery();
        }
        catch (Exception)
        { }
        finally
        {
            conn.Close();
            ShowData();
        }
    }


    protected void txtemployee_TextChanged(object sender, EventArgs e)
    {
        Bind_Employee();
    }

    protected void txtsubDept_TextChanged(object sender, EventArgs e)
    {
        Bind_subDept();
    }
}

