using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Data;
using System.Configuration;

public partial class Store_Cash_Sale_Invoice_Wise : System.Web.UI.Page
{
    String conStr = ConfigurationManager
        .ConnectionStrings["RestaurantConnectionString"]
        .ToString();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            txtStartDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            txtEndDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            getSubDepts();
        }
    }

    private void getSubDepts()
    {
        SqlConnection conn = new SqlConnection(
            ConfigurationManager
            .ConnectionStrings["STOREConnectionString"]
            .ConnectionString);

        SqlCommand cmd = new SqlCommand("select * from SubDepartment", conn);

        SqlDataAdapter sda = new SqlDataAdapter(cmd);
        DataTable dt = new DataTable();
        sda.Fill(dt);

        ddlSubDept.DataSource = dt;
        ddlSubDept.DataTextField = "SubDept_Name";
        ddlSubDept.DataValueField = "SubDept_Id";
        ddlSubDept.DataBind();

        // Add default item
        ddlSubDept.Items.Insert(0, new ListItem("-- All Locations --", "0"));
    }

    protected void Button_Report_Click(object sender, EventArgs e)
    {
        ShowReport();
    }

    private void ShowReport()
    {
        try
        {
            DbManager dbMgr = new DbManager();

            SqlParameter[] sqlParam =
          {
    new SqlParameter("@Start_Date", txtStartDate.Text),
    new SqlParameter("@End_Date", txtEndDate.Text),
    new SqlParameter("@SubDeptId", ddlSubDept.SelectedValue)
};
            DataTable dt = dbMgr.ExecuteDataTable(
                "sp_GetBillwiseDetail",
                "RestaurantConnectionString",
                sqlParam);

            if (dt.Rows.Count == 0)
            {
                ltReport.Text = "<div style='padding: 20px; text-align: center; background: white; border: 1px solid #ddd;'><h2 style='color: #ff0000;'>No Record Found</h2><p>Please try with different date range.</p></div>";
                return;
            }

            // -- Format dates for display ----------------------------------
            string startDisplay = Convert.ToDateTime(txtStartDate.Text)
                                         .ToString("dd/MM/yyyy");
            string endDisplay = Convert.ToDateTime(txtEndDate.Text)
                                         .ToString("dd/MM/yyyy");

            // -- ONE-TIME PAGE HEADER --------------------------------------
            string html = @"
            <div class='page-header'>
                <div class='company-name'>LAHORE GYMKHANA</div>
                <div class='report-title'>Outlet Sales Listings - Bill Wise Detail</div>
                <div class='report-date-range'>
                    from " + startDisplay + " to " + endDisplay + @"
                </div>
            </div>";

            // -- BILLS (multiple, no page-break between them) --------------
            var bills = dt.AsEnumerable()
                          .GroupBy(x => x["check_No"].ToString());

            foreach (var bill in bills)
            {
                DataRow first = bill.First();

                decimal totalAmount = bill.Sum(x =>
                    Convert.ToDecimal(x["LineTotal"]));

                // GST column — use if present, else calculate at ~15.24 % (adjust if needed)
                decimal totalGst;
                if (dt.Columns.Contains("GST"))
                    totalGst = bill.Sum(x => Convert.ToDecimal(x["GST"]));
                else
                    totalGst = Math.Round(totalAmount * 0.1524m, 0);

                // Net Payable = TotalAmount + GST
                decimal netPayable = totalAmount + totalGst;

                // Cash Received — use column if present, else leave blank
                string cashReceived = dt.Columns.Contains("CashReceived")
                    ? Convert.ToDecimal(first["CashReceived"]).ToString("N0")
                    : "0";

                // Format dates safely
                string paymentDate = "";
                try
                {
                    paymentDate = Convert.ToDateTime(first["PaymentDate"]).ToString("dd/MM/yyyy");
                }
                catch
                {
                    paymentDate = first["PaymentDate"].ToString();
                }

                // -- Bill header info --------------------------------------
                html += @"
                <div class='bill-box'>

                    <table class='info-table'>
                        <tr>
                            <td width='33%'><b>Check No&nbsp;:</b> " + first["check_No"] + @"</td>
                            <td width='33%'><b>Check Date&nbsp;:</b> " + paymentDate + @"</td>
                            <td width='34%'><b>Sales Type&nbsp;:</b> " + first["PaymentMethod"] + @"</td>
                        </tr>
                        <tr>
                            <td colspan='2'>
                                <b>Member No</b>&nbsp;" + first["MemberNo"] + " " + first["MemberName"] + @"
                            </td>
                            <td><b>Cover&nbsp;:</b> " + first["Cover"] + @"</td>
                        </tr>
                        <tr>
                            <td><b>Outlet&nbsp;:</b> " + first["DepartmentName"] + @"</td>
                            <td colspan='2'><b>Waiter&nbsp;:</b> " + first["WaiterName"] + @"</td>
                        </tr>
                    </table>

                    <table class='item-table'>
                        <tr>
                            <th width='5%'>Sr #</th>
                            <th width='15%'>Outlet</th>
                            <th width='10%'>KOT</th>
                            <th width='10%'>Item Code</th>
                            <th width='30%'>Item Name</th>
                            <th width='8%'>Qty</th>
                            <th width='10%'>Rate</th>
                            <th width='12%'>Amount</th>
                        </tr>";

                int sr = 1;
                foreach (var item in bill)
                {
                    string itemName = item["itemname"].ToString();
                    string quantity = item["Quantity"].ToString();
                    string rate = Convert.ToDecimal(item["Rate"]).ToString("N0");
                    string lineTotal = Convert.ToDecimal(item["LineTotal"]).ToString("N0");

                    html += @"
                        <tr>
                            <td class='text-center'>" + sr + @"</td>
                            <td class='text-center'>" + item["DepartmentName"] + @"</td>
                            <td class='text-center'>" + item["KOT_Number"] + @"</td>
                            <td class='text-center'>" + item["ItemCode"] + @"</td>
                            <td>" + itemName + @"</td>
                            <td class='text-center'>" + quantity + @"</td>
                            <td class='text-right'>" + rate + @"</td>
                            <td class='text-right'>" + lineTotal + @"</td>
                        </tr>";
                    sr++;
                }

                html += @"
                    </table>

                    <div class='summary-wrap'>
                        <table class='summary-table'>
                            <tr>
                                <td class='lbl'>Total Amount :</td>
                                <td class='text-right'>" + totalAmount.ToString("N0") + @"</td>
                            </tr>
                            <tr>
                                <td class='lbl'>Total GST :</td>
                                <td class='text-right'>" + totalGst.ToString("N0") + @"</td>
                            </tr>
                            <tr>
                                <td class='lbl'>Net Payable :</td>
                                <td class='text-right'><b>" + netPayable.ToString("N0") + @"</b></td>
                            </tr>
                            <tr>
                                <td class='lbl'>Cash Received :</td>
                                <td class='text-right'>" + cashReceived + @"</td>
                            </tr>
                        </table>
                        <div class='clearfix'></div>
                    </div>

                </div>";   // end .bill-box
            }

            ltReport.Text = html;
        }
        catch (Exception ex)
        {
            ltReport.Text = "<div style='padding: 20px; text-align: center; background: white; border: 1px solid #ddd;'><h2 style='color:red;'>Error Generating Report</h2><p style='color:red;'>" + ex.Message + "</p></div>";
        }
    }

    [System.Web.Script.Services.ScriptMethod()]
    [System.Web.Services.WebMethod()]
    public static List<string> SearchItems(string prefixText, int count)
    {
        List<string> items = new List<string>();

        string connectionString = ConfigurationManager
            .ConnectionStrings["RestaurantConnectionString"]
            .ConnectionString;

        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            SqlCommand cmd = new SqlCommand();
            cmd.CommandText = "SELECT TOP 10 ItemCode, ItemName FROM MenuItems WHERE ItemName LIKE '%' + @Search + '%' ORDER BY ItemName";
            cmd.CommandType = CommandType.Text;
            cmd.Parameters.AddWithValue("@Search", prefixText);
            cmd.Connection = conn;

            conn.Open();
            SqlDataReader sdr = cmd.ExecuteReader();

            while (sdr.Read())
            {
                items.Add(sdr["ItemCode"].ToString());
            }
        }

        return items;
    }
}




