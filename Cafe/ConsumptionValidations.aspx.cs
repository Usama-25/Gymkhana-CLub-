using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ConsumptionValidation : System.Web.UI.Page
{
    private string cons = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"] != null 
        ? ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString 
        : "";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            if (Request.QueryString["MasterId"] != null)
                hdnMasterId.Value = Request.QueryString["MasterId"];
            if (Request.QueryString["CCID"] != null)
                hdnCCID.Value = Request.QueryString["CCID"];
            if (Request.QueryString["DeptId"] != null)
                hdnDeptId.Value = Request.QueryString["DeptId"];

            BindData();
        }
    }

    private void BindData()
    {
        // Data binding logic for gvVerification
    }

    protected void btnConfirmReject_Click(object sender, EventArgs e)
    {
        pnlRejectArea.Visible = false;
    }

    protected void btnCancelReject_Click(object sender, EventArgs e)
    {
        pnlRejectArea.Visible = false;
    }

    protected void btnApproveAll_Click(object sender, EventArgs e)
    {
    }

    protected void btnRejectRecord_Click(object sender, EventArgs e)
    {
        pnlRejectArea.Visible = true;
    }

    protected void btnPostToStore_Click(object sender, EventArgs e)
    {
    }

    protected void gvVerification_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView drv = (DataRowView)e.Row.DataItem;
            Label lblDiff = (Label)e.Row.FindControl("lblDiff");
            Label lblStoreStock = (Label)e.Row.FindControl("lblStoreStock");
            Label lblShortage = (Label)e.Row.FindControl("lblShortage");
            Label lblSubstituteInfo = (Label)e.Row.FindControl("lblSubstituteInfo");

            if (lblDiff != null && drv["ExpectedQty"] != DBNull.Value && drv["ActualQty"] != DBNull.Value)
            {
                decimal expected = Convert.ToDecimal(drv["ExpectedQty"]);
                decimal actual = Convert.ToDecimal(drv["ActualQty"]);
                decimal diff = actual - expected;
                lblDiff.Text = diff.ToString("N3");
            }
        }
    }
}
