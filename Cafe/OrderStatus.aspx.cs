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
            string query = "SELECT Id, MemberNo FROM Bills WHERE Status='Pending'";

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
        int billId = Convert.ToInt32(e.CommandArgument);
        SelectedBillId = billId; 

        using (SqlConnection con = new SqlConnection(conStr))
        {
            SqlCommand cmd = null;

            if (e.CommandName == "OrderReady")
                cmd = new SqlCommand("UPDATE Bills SET Status='Ready' WHERE Id=@Id", con);
            else if (e.CommandName == "MoveDine")
                cmd = new SqlCommand("UPDATE Bills SET Status='Dine' WHERE Id=@Id", con);

            if (cmd != null)
            {
                cmd.Parameters.AddWithValue("@Id", billId);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        BindBillsGrid();
        BindBillItemsGrid(billId); 
        pnlBillItems.Visible = true;
    }



    private decimal grandTotal = 0;

    private void BindBillItemsGrid(int billId)
    {
        grandTotal = 0;
        using (SqlConnection con = new SqlConnection(conStr))
        {
            string query = @"
            SELECT i.Name, i.Quantity, i.Price, b.Total
            FROM BillItems i
            INNER JOIN Bills b ON b.Id = i.BillId
            WHERE i.BillId = @BillId
              AND b.Status IN ('Pending','Ready')";

            SqlDataAdapter da = new SqlDataAdapter(query, con);
            da.SelectCommand.Parameters.AddWithValue("@BillId", billId);

            DataTable dt = new DataTable();
            da.Fill(dt);

            gvBillItems.DataSource = dt;
            gvBillItems.DataBind();
            pnlBillItems.Visible = true;

        }
    }


    protected void gvBillItems_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            decimal rowPrice = Convert.ToDecimal(DataBinder.Eval(e.Row.DataItem, "Price"));
            grandTotal += rowPrice; 
        }

        if (e.Row.RowType == DataControlRowType.Footer)
        {
            Label lbl = (Label)e.Row.FindControl("lblFooterTotal");
            if (lbl != null)
            {
                lbl.Text = grandTotal.ToString("0.00"); 
            }
        }
    }



    protected void btnOrderReady_Click(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(hfSelectedBillId.Value))
            SelectedBillId = Convert.ToInt32(hfSelectedBillId.Value);

        UpdateBillStatus("Ready");
    }

    protected void btnMoveDine_Click(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(hfSelectedBillId.Value))
            SelectedBillId = Convert.ToInt32(hfSelectedBillId.Value);

        UpdateBillStatus("Dine");
    }



    private void UpdateBillStatus(string status)
    {
        if (SelectedBillId == 0) return;

        using (SqlConnection con = new SqlConnection(conStr))
        {
            SqlCommand cmd = new SqlCommand(
                "UPDATE Bills SET Status=@Status WHERE Id=@Id", con);

            cmd.Parameters.AddWithValue("@Status", status);
            cmd.Parameters.AddWithValue("@Id", SelectedBillId);

            con.Open();
            cmd.ExecuteNonQuery();
        }

        
        BindBillsGrid();

        
        if (SelectedBillId > 0)
        {
            BindBillItemsGrid(SelectedBillId);
            pnlBillItems.Visible = true;  
        }
    }

}

