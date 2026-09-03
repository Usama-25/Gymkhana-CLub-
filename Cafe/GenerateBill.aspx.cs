// using Microsoft.Reporting;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Pos : System.Web.UI.Page
{
    private string conStr = ConfigurationManager
        .ConnectionStrings["RestaurantConnectionString"].ConnectionString;
    private int SelectedBillId
    {
        get { return ViewState["SelectedBillId"] == null ? 0 : (int)ViewState["SelectedBillId"]; }
        set { ViewState["SelectedBillId"] = value; }
    }


    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            BindBillsGrid();
            pnlBillItems.Visible = false;
        }
        else
        {
            if (SelectedBillId > 0)
            {
                BindBillItemsGrid(SelectedBillId);
                pnlBillItems.Visible = true;
            }
        }
    }


    protected void btnSearch_Click(object sender, EventArgs e)
    {
        BindBillsGrid(txtBillId.Text.Trim(), txtMemberNo.Text.Trim());
        pnlBillItems.Visible = false;
    }

    private void BindBillsGrid(string Id = "", string memberNo = "")
    {
        using (SqlConnection con = new SqlConnection(conStr))
        {
           
            string query = "SELECT Id, MemberNo, Total FROM Bills WHERE Status='Dine'";

            if (!string.IsNullOrEmpty(Id))
                query += " AND Id LIKE @BillId";
            if (!string.IsNullOrEmpty(memberNo))
                query += " AND MemberNo LIKE @MemberNo";

            SqlCommand cmd = new SqlCommand(query, con);

            if (!string.IsNullOrEmpty(Id))
                cmd.Parameters.AddWithValue("@BillId", "%" + Id + "%");
            if (!string.IsNullOrEmpty(memberNo))
                cmd.Parameters.AddWithValue("@MemberNo", "%" + memberNo + "%");

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            gvBills.DataSource = dt;
            gvBills.DataBind();
        }
    }


    protected void gvBills_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "SelectBill")
        {
            int billId = Convert.ToInt32(e.CommandArgument);
            SelectedBillId = billId;
            BindBillItemsGrid(billId);
            pnlBillItems.Visible = true;
        }
    }

    private decimal grandTotal = 0;

    private void BindBillItemsGrid(int billId)
    {
        grandTotal = 0; 
        using (SqlConnection con = new SqlConnection(conStr))
        {
           
            string query = @"
        SELECT i.Name, 
               i.Quantity, 
               i.Price,
               (i.Quantity * i.Price) as ItemTotal
        FROM BillItems i
        INNER JOIN Bills b ON b.Id = i.BillId
        WHERE i.BillId = @BillId";

            SqlDataAdapter da = new SqlDataAdapter(query, con);
            da.SelectCommand.Parameters.AddWithValue("@BillId", billId);

            DataTable dt = new DataTable();
            da.Fill(dt);

            // Calculate grand total
            foreach (DataRow row in dt.Rows)
            {
                decimal quantity = Convert.ToDecimal(row["Quantity"]);
                decimal price = Convert.ToDecimal(row["Price"]);
                decimal itemTotal = quantity * price;
                grandTotal += itemTotal;
            }

            // Store grand total in ViewState
            ViewState["GrandTotal"] = grandTotal;

            gvBillItems.DataSource = dt;
            gvBillItems.DataBind();
        }
    }


    protected void gvBillItems_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            // Calculate and display item total in the last cell
            decimal quantity = Convert.ToDecimal(DataBinder.Eval(e.Row.DataItem, "Quantity"));
            decimal price = Convert.ToDecimal(DataBinder.Eval(e.Row.DataItem, "Price"));
            decimal itemTotal = quantity * price;

            // Display item total in the last cell (Total column)
            e.Row.Cells[3].Text = itemTotal.ToString("0.00");
        }

        if (e.Row.RowType == DataControlRowType.Footer)
        {
            // Add total row at the bottom
            e.Row.Cells[0].ColumnSpan = 3;
            e.Row.Cells[0].Text = "Grand Total:";
            e.Row.Cells[0].HorizontalAlign = HorizontalAlign.Right;
            e.Row.Cells[0].Style.Add("font-weight", "bold");

            // Remove the extra cells
            for (int i = e.Row.Cells.Count - 1; i > 0; i--)
            {
                e.Row.Cells.RemoveAt(i);
            }

            // Add the grand total amount cell
            TableCell totalCell = new TableCell();
            totalCell.Text = ViewState["GrandTotal"] != null ?
                Convert.ToDecimal(ViewState["GrandTotal"]).ToString("0.00") : "0.00";
            totalCell.Style.Add("font-weight", "bold");
            e.Row.Cells.Add(totalCell);
        }
    }

    protected void btnGenerateBill_Click(object sender, EventArgs e)
    {
        if (SelectedBillId == 0)
        {
           
            ScriptManager.RegisterStartupScript(this, GetType(), "noBillSelected", 
                "alert('Please select a bill first!');", true);
            return;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(conStr))
            {
               
                string updateQuery = "UPDATE Bills SET Status='Paid' WHERE Id=@Id";
                SqlCommand cmd = new SqlCommand(updateQuery, con);
                cmd.Parameters.AddWithValue("@Id", SelectedBillId);
                
                con.Open();
                int rowsAffected = cmd.ExecuteNonQuery();
                con.Close();
                
                if (rowsAffected > 0)
                {
                    
                    ScriptManager.RegisterStartupScript(this, GetType(), "billGenerated", 
                        "alert('Bill generated successfully!');", true);
                    
                    
                    BindBillsGrid();
                    pnlBillItems.Visible = false;
                    SelectedBillId = 0;
                }
            }
        }
        catch (Exception ex)
        {
           
            ScriptManager.RegisterStartupScript(this, GetType(), "error", 
                "alert('Error generating bill: {ex.Message}');", true);
        }
    }
}


