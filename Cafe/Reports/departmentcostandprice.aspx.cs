using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Text;

public partial class departmentcostandprice : System.Web.UI.Page
{
    string conStr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ToString();

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadReport();
        }
    }

    private void LoadReport()
    {
        string sql = @"
        SELECT
            DepartmentName,
            CONCAT(
                DepartmentName,
                ' (',
                COUNT(*) OVER(PARTITION BY DepartmentName),
                ')'
            ) AS DepartmentHeader,
            ItemCode,
            ItemName,
            Cost,
            Price AS SalePrice,
            GST,
            SubMenu_Name,
            Course_Name
        FROM MenuItems
        WHERE DepartmentName IS NOT NULL AND DepartmentName != ''
        ORDER BY DepartmentName, ItemName";

        DataTable dt = new DataTable();

        using (SqlConnection con = new SqlConnection(conStr))
        {
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }
        }

        StringBuilder sb = new StringBuilder();

        if (dt.Rows.Count == 0)
        {
            sb.Append("<div style='text-align:center;padding:50px;color:#999;font-size:16px;'>");
            sb.Append("?? No items found in the menu.");
            sb.Append("</div>");
            ltReport.Text = sb.ToString();
            return;
        }

        string currentDept = "";
        int totalItems = 0;
        decimal totalPrice = 0;
        decimal totalCost = 0;

        foreach (DataRow dr in dt.Rows)
        {
            if (currentDept != dr["DepartmentName"].ToString())
            {
                // Close previous department table
                if (currentDept != "")
                {
                    sb.Append("</table>");

                    // Add department summary
                    sb.Append("<div style='padding:5px 10px;background:#f5f7fa;border:1px solid #e0e6ed;border-top:none;border-radius:0 0 4px 4px;font-size:12px;color:#666;'>");
                    sb.Append("?? Items: <strong>" + currentDeptCount + "</strong>");
                    sb.Append("</div>");

                    sb.Append("<br/>");
                }

                currentDept = dr["DepartmentName"].ToString();
                currentDeptCount = 0;

                // Department header with item count
                sb.Append("<div class='deptHeader'>");
                sb.Append("??? " + dr["DepartmentHeader"].ToString());
                sb.Append("</div>");

                // Table start
                sb.Append(@"
                <table class='tblReport'>
                    <thead>
                        <tr>
                            <th style='width:10%;'>Item Code</th>
                            <th style='width:30%;'>Description</th>
                            <th style='width:20%;'>Sub Menu</th>
                            <th style='width:15%;'>Course</th>
                            <th style='width:10%;text-align:right;'>Price</th>
                            <th style='width:10%;text-align:right;'>Cost</th>
                            <th style='width:5%;text-align:right;'>GST%</th>
                        </tr>
                    </thead>
                    <tbody>");
            }

            // Format values
            string itemCode = dr["ItemCode"].ToString();
            string itemName = dr["ItemName"].ToString();
            string subMenu = dr["SubMenu_Name"].ToString();
            string course = dr["Course_Name"].ToString();

            decimal price = dr["SalePrice"] != DBNull.Value ? Convert.ToDecimal(dr["SalePrice"]) : 0;
            decimal cost = dr["Cost"] != DBNull.Value ? Convert.ToDecimal(dr["Cost"]) : 0;
            decimal gst = dr["GST"] != DBNull.Value ? Convert.ToDecimal(dr["GST"]) : 0;

            currentDeptCount++;
            totalItems++;
            totalPrice += price;
            totalCost += cost;

            sb.Append("<tr>");
            sb.Append("<td><span style='font-family:Courier New,monospace;font-size:12px;color:#555;'>" + itemCode + "</span></td>");
            sb.Append("<td><strong>" + itemName + "</strong></td>");
            sb.Append("<td>" + (string.IsNullOrEmpty(subMenu) ? "-" : subMenu) + "</td>");
            sb.Append("<td>" + (string.IsNullOrEmpty(course) ? "-" : course) + "</td>");
            sb.Append("<td class='price-col'>" + price.ToString("N0") + "</td>");
            sb.Append("<td class='cost-col'>" + cost.ToString("N0") + "</td>");
            sb.Append("<td class='gst-col'>" + gst.ToString("N0") + "%</td>");
            sb.Append("</tr>");
        }

        // Close last table
        if (dt.Rows.Count > 0)
        {
            sb.Append("</tbody></table>");

            // Last department summary
            sb.Append("<div style='padding:5px 10px;background:#f5f7fa;border:1px solid #e0e6ed;border-top:none;border-radius:0 0 4px 4px;font-size:12px;color:#666;'>");
            sb.Append("?? Items: <strong>" + currentDeptCount + "</strong>");
            sb.Append("</div>");

            // Grand total summary
            sb.Append(@"
            <div style='margin-top:20px;padding:12px 15px;background:#eef3f8;border-radius:4px;border:1px solid #d0d7e0;display:flex;justify-content:space-between;flex-wrap:wrap;'>
                <div><strong>?? Total Items:</strong> " + totalItems + @"</div>
                <div><strong>?? Total Sale Value:</strong> <span style='color:#1a7a3a;'>" + totalPrice.ToString("N0") + @"</span></div>
                <div><strong>?? Total Cost:</strong> <span style='color:#b22222;'>" + totalCost.ToString("N0") + @"</span></div>
                <div><strong>?? Margin:</strong> <span style='color:#1a3c5e;font-weight:bold;'>" + (totalPrice - totalCost).ToString("N0") + @"</span></div>
            </div>");
        }

        ltReport.Text = sb.ToString();
    }

    // Track current department item count
    private int currentDeptCount = 0;
}

