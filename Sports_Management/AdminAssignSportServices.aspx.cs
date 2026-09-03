using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Web;


public partial class AdminAssignSportServices : System.Web.UI.Page
{
    string basicConnStr = ConfigurationManager.ConnectionStrings["BasicDataInfoConnectionString"].ConnectionString;
    string storeConnStr = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;
    private string connectionString = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            BindDepartments();
            BindGrid();
        }
    }

    private void BindDepartments()
    {
        using (SqlConnection con = new SqlConnection(basicConnStr)) 
        {
            SqlCommand cmd = new SqlCommand("select Dept_ID,Dept_Name from Department order by Dept_Name asc", con);
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            ddlDepartment.DataSource = dt;
            ddlDepartment.DataTextField = "Dept_Name";
            ddlDepartment.DataValueField = "Dept_ID";
            ddlDepartment.DataBind();

            ddlDepartment.Items.Insert(0, new ListItem("--Select Department--", "0"));
        }
    }










    protected void btnSavePrices_Click(object sender, EventArgs e)
    {
        if (ddlDepartment.SelectedIndex == 0 ||
            string.IsNullOrWhiteSpace(txtServices.Text) ||
            string.IsNullOrWhiteSpace(txtamonut.Text))
        {
            return;
        }

        using (SqlConnection con = new SqlConnection(connectionString))
        {
            SqlCommand cmd = new SqlCommand(
            @"INSERT INTO SportsServices 
          (Dept_Id, ServiceName, Amount)
          VALUES (@DepartmentId, @ServiceName, @Amount)", con);

            cmd.Parameters.AddWithValue("@DepartmentId", ddlDepartment.SelectedValue);
            cmd.Parameters.AddWithValue("@ServiceName", txtServices.Text.Trim());
            cmd.Parameters.AddWithValue("@Amount", Convert.ToDecimal(txtamonut.Text));

            con.Open();
            cmd.ExecuteNonQuery();
        }

        ClearFields();
        BindGrid();
    }




    private void BindGrid(int deptId = 0)
    {
        using (SqlConnection con = new SqlConnection(connectionString))
        {
            string query = @"
        SELECT 
            s.ServiceName,
            s.Amount,
            d.Dept_Name
        FROM SportsServices s
        INNER JOIN BasicDataInfo.dbo.Department d 
            ON d.Dept_ID = s.Dept_Id";

            if (deptId > 0)
            {
                query += " WHERE s.Dept_Id = @DeptId";
            }

            query += " ORDER BY s.ServiceId DESC";

            SqlDataAdapter da = new SqlDataAdapter(query, con);

            if (deptId > 0)
            {
                da.SelectCommand.Parameters.AddWithValue("@DeptId", deptId);
            }

            DataTable dt = new DataTable();
            da.Fill(dt);

            gvRecipeMain.DataSource = dt;
            gvRecipeMain.DataBind();
        }
    }



    protected void ddlDepartment_SelectedIndexChanged(object sender, EventArgs e)
    {
        int deptId = 0;

        if (ddlDepartment.SelectedIndex > 0)
        {
            deptId = Convert.ToInt32(ddlDepartment.SelectedValue);
        }

        BindGrid(deptId);
    }


    private void ClearFields()
    {
        txtServices.Text = "";
        txtamonut.Text = "";
        ddlDepartment.SelectedIndex = 0;
    }




}

