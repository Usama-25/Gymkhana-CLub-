using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ReceiptVoucherSearch_Page : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            txtFromDate.Text = DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd");
            txtToDate.Text = DateTime.Now.ToString("yyyy-MM-dd");

            // Check if ReceiptNo passed in QueryString
            if (!string.IsNullOrEmpty(Request.QueryString["ReceiptNo"]))
            {
                txtSearchReceiptNo.Text = Request.QueryString["ReceiptNo"];
            }

            BindVouchersGrid();
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        gvVouchers.PageIndex = 0;
        BindVouchersGrid();
    }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        txtSearchReceiptNo.Text = "";
        txtSearchVoucherNo.Text = "";
        txtFromDate.Text = DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd");
        txtToDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        gvVouchers.PageIndex = 0;
        BindVouchersGrid();
    }

    protected void gvVouchers_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvVouchers.PageIndex = e.NewPageIndex;
        BindVouchersGrid();
    }

    private void BindVouchersGrid()
    {
        string financeConnStr = ConfigurationManager.ConnectionStrings["FinanceConnectionString"].ConnectionString;

        using (SqlConnection con = new SqlConnection(financeConnStr))
        {
            con.Open();
            using (SqlCommand cmd = new SqlCommand("sp_GetReceiptVouchers", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@ReceiptNo", txtSearchReceiptNo.Text.Trim());
                cmd.Parameters.AddWithValue("@VoucherNo", txtSearchVoucherNo.Text.Trim());

                if (!string.IsNullOrEmpty(txtFromDate.Text))
                    cmd.Parameters.AddWithValue("@FromDate", txtFromDate.Text.Trim());

                if (!string.IsNullOrEmpty(txtToDate.Text))
                    cmd.Parameters.AddWithValue("@ToDate", txtToDate.Text.Trim());

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvVouchers.DataSource = dt;
                gvVouchers.DataBind();
            }
        }
    }

    protected void gvVouchers_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "ViewDetail")
        {
            decimal voucherTransId = Convert.ToDecimal(e.CommandArgument);
            LoadVoucherDetailsModal(voucherTransId);
        }
    }

    private void LoadVoucherDetailsModal(decimal voucherTransId)
    {
        string financeConnStr = ConfigurationManager.ConnectionStrings["FinanceConnectionString"].ConnectionString;

        using (SqlConnection con = new SqlConnection(financeConnStr))
        {
            con.Open();
            using (SqlCommand cmd = new SqlCommand("sp_GetVoucherDetails", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Voucher_Trans_Id", voucherTransId);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataSet ds = new DataSet();
                da.Fill(ds);

                if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    DataRow master = ds.Tables[0].Rows[0];
                    lblModalVoucherNo.Text = master["Voucher_No"].ToString();
                    lblModalReceiptNo.Text = master["ReceiptNo"].ToString();
                    lblModalVoucherDate.Text = Convert.ToDateTime(master["VoucherDate"]).ToString("yyyy-MM-dd HH:mm");
                    lblModalVoucherType.Text = master["Voucher_Type"].ToString();
                    lblModalCostCenter.Text = master["CostCenterName"].ToString();
                    lblModalDescription.Text = master["Description"].ToString();
                }

                if (ds.Tables.Count > 1)
                {
                    gvVoucherDetails.DataSource = ds.Tables[1];
                    gvVoucherDetails.DataBind();
                }

                pnlVoucherDetailModal.Visible = true;
            }
        }
    }

    protected void btnCloseVoucherModal_Click(object sender, EventArgs e)
    {
        pnlVoucherDetailModal.Visible = false;
    }
}
