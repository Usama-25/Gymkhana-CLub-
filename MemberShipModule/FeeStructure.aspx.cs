using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

public partial class MemberShip_FeeStructure : System.Web.UI.Page
{
    private string connectionString
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
            BindFeeStructure();
        }
    }

    private void BindFeeStructure()
    {
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            string sql = "SELECT * FROM FeeStructure ORDER BY CategoryName";
            SqlDataAdapter da = new SqlDataAdapter(sql, conn);
            DataTable dt = new DataTable();
            da.Fill(dt);
            gvFeeStructure.DataSource = dt;
            gvFeeStructure.DataBind();
        }
    }

    protected void btnAddFee_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtNewCategory.Text) || string.IsNullOrWhiteSpace(txtNewAmount.Text))
        {
            ShowMessage("Please enter both category name and amount.", true);
            return;
        }

        try
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string sql = "INSERT INTO FeeStructure (CategoryName, FeeAmount, LastUpdated) VALUES (@Category, @Amount, GETDATE())";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Category", txtNewCategory.Text.Trim());
                    cmd.Parameters.AddWithValue("@Amount", Convert.ToDecimal(txtNewAmount.Text));
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            txtNewCategory.Text = "";
            txtNewAmount.Text = "";
            BindFeeStructure();
            ShowMessage("Category added successfully.", false);
        }
        catch (Exception ex)
        {
            ShowMessage("Error adding category: " + ex.Message, true);
        }
    }

    protected void gvFeeStructure_RowEditing(object sender, GridViewEditEventArgs e)
    {
        gvFeeStructure.EditIndex = e.NewEditIndex;
        BindFeeStructure();
    }

    protected void gvFeeStructure_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
    {
        gvFeeStructure.EditIndex = -1;
        BindFeeStructure();
    }

    protected void gvFeeStructure_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        int feeId = Convert.ToInt32(gvFeeStructure.DataKeys[e.RowIndex].Value);
        string category = ((TextBox)gvFeeStructure.Rows[e.RowIndex].Cells[0].Controls[0]).Text;
        decimal amount = Convert.ToDecimal(((TextBox)gvFeeStructure.Rows[e.RowIndex].Cells[1].Controls[0]).Text);
        string description = ((TextBox)gvFeeStructure.Rows[e.RowIndex].Cells[2].Controls[0]).Text;

        try
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string sql = "UPDATE FeeStructure SET CategoryName=@Category, FeeAmount=@Amount, Description=@Desc, LastUpdated=GETDATE() WHERE FeeID=@ID";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Category", category);
                    cmd.Parameters.AddWithValue("@Amount", amount);
                    cmd.Parameters.AddWithValue("@Desc", description);
                    cmd.Parameters.AddWithValue("@ID", feeId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            gvFeeStructure.EditIndex = -1;
            BindFeeStructure();
            ShowMessage("Category updated successfully.", false);
        }
        catch (Exception ex)
        {
            ShowMessage("Error updating category: " + ex.Message, true);
        }
    }

    protected void gvFeeStructure_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        int feeId = Convert.ToInt32(gvFeeStructure.DataKeys[e.RowIndex].Value);

        try
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string sql = "DELETE FROM FeeStructure WHERE FeeID=@ID";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", feeId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            BindFeeStructure();
            ShowMessage("Category deleted successfully.", false);
        }
        catch (Exception ex)
        {
            ShowMessage("Error deleting category: " + ex.Message, true);
        }
    }

    private void ShowMessage(string msg, bool isError)
    {
        lblMessage.Text = msg;
        lblMessage.Visible = true;
        lblMessage.CssClass = isError ? "notification error" : "notification success";
    }
}
