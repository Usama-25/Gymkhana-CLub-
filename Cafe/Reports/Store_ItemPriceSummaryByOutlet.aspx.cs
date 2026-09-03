using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Text;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;

public partial class Store_ItemPriceSummaryByOutlet : System.Web.UI.Page
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
        // -------------------------------------------------------
        // 1.  Fetch all active departments (SubDepartments) that
        //     have at least one priced menu item (Dept_Id = 9)
        // -------------------------------------------------------
        string deptSql = @"
            SELECT DISTINCT
                sd.SubDept_Id,
                sd.SubDept_Name
            FROM BasicDataInfo.dbo.SubDepartment sd
            INNER JOIN MenuItems ms ON ms.DepartmentID = sd.SubDept_Id
            WHERE ms.Price IS NOT NULL
              AND ms.Price > 0
              AND sd.Dept_Id = 9
            ORDER BY sd.SubDept_Id";

        // -------------------------------------------------------
        // 2.  Fetch all priced items for Dept_Id = 9
        // -------------------------------------------------------
        string itemSql = @"
            SELECT
                ms.ItemCode,
                ms.ItemName,
                ms.Price,
                ms.DepartmentID AS SubDept_Id
            FROM MenuItems ms
            INNER JOIN BasicDataInfo.dbo.SubDepartment sd
                ON ms.DepartmentID = sd.SubDept_Id
            WHERE ms.Price IS NOT NULL
              AND ms.Price > 0
              AND sd.Dept_Id = 9
            ORDER BY ms.ItemCode";

        DataTable dtDepts = new DataTable();
        DataTable dtItems = new DataTable();

        using (SqlConnection con = new SqlConnection(conStr))
        {
            con.Open();
            using (SqlDataAdapter da = new SqlDataAdapter(deptSql, con))
                da.Fill(dtDepts);

            using (SqlDataAdapter da = new SqlDataAdapter(itemSql, con))
                da.Fill(dtItems);
        }

        if (dtDepts.Rows.Count == 0 || dtItems.Rows.Count == 0)
        {
            litReportTable.Text = "<p style='color:red'>No data found.</p>";
            litFooter.Text = string.Empty;
            return;
        }

        // -------------------------------------------------------
        // 3.  Build lookup:  ItemCode ? (SubDept_Id ? Price)
        // -------------------------------------------------------
        // Also collect unique items in order
        var itemOrder = new List<string>();          // ordered ItemCodes
        var itemNames = new Dictionary<string, string>();  // ItemCode ? ItemName
        var priceMap = new Dictionary<string, Dictionary<int, decimal>>();
        // priceMap[ItemCode][SubDept_Id] = Price

        foreach (DataRow row in dtItems.Rows)
        {
            string code = row["ItemCode"].ToString().Trim();
            string name = row["ItemName"].ToString().Trim();
            int deptId = Convert.ToInt32(row["SubDept_Id"]);
            decimal price = Convert.ToDecimal(row["Price"]);

            if (!itemNames.ContainsKey(code))
            {
                itemOrder.Add(code);
                itemNames[code] = name;
                priceMap[code] = new Dictionary<int, decimal>();
            }

            // If item appears in multiple rows for same dept, keep first / max
            if (!priceMap[code].ContainsKey(deptId))
                priceMap[code][deptId] = price;
        }

        // -------------------------------------------------------
        // 4.  Build department list
        // -------------------------------------------------------
        var deptIds = new List<int>();
        var deptNames = new Dictionary<int, string>();

        foreach (DataRow row in dtDepts.Rows)
        {
            int id = Convert.ToInt32(row["SubDept_Id"]);
            string name = row["SubDept_Name"].ToString().Trim();
            deptIds.Add(id);
            deptNames[id] = name;
        }

        // -------------------------------------------------------
        // 5.  Render HTML table
        // -------------------------------------------------------
        StringBuilder sb = new StringBuilder();
        sb.Append("<table class='price-matrix'>");

        // --- Header Row ---
        sb.Append("<thead><tr>");
        sb.Append("<th class='item-col'>Item</th>");

        for (int d = 0; d < deptIds.Count; d++)
        {
            int dId = deptIds[d];
            string dName = deptNames[dId];

            // Format like image: "01 - THACHIN" style numbers
            string dLabel = (d + 1).ToString("D2") + " - " + dName.ToUpper();

            sb.AppendFormat(
                "<th class='dept-header'><div title='{0}'>{0}</div></th>",
                HttpUtility.HtmlEncode(dLabel)
            );
        }

        sb.Append("</tr></thead>");

        // --- Data Rows ---
        sb.Append("<tbody>");

        for (int i = 0; i < itemOrder.Count; i++)
        {
            string code = itemOrder[i];
            string name = itemNames[code];
            string rowClass = (i % 2 == 0) ? "odd-row" : "even-row";

            sb.AppendFormat("<tr class='{0}'>", rowClass);

            // Item name cell  (code + name, blue code like in image)
            sb.AppendFormat(
                "<td class='item-col'><span class='item-code'>{0}</span> - {1}</td>",
                HttpUtility.HtmlEncode(code),
                HttpUtility.HtmlEncode(name)
            );

            // Price cells per department
            foreach (int dId in deptIds)
            {
                if (priceMap[code].ContainsKey(dId))
                {
                    decimal price = priceMap[code][dId];
                    sb.AppendFormat(
                        "<td class='price-cell'>{0}</td>",
                        price.ToString("0")          // no decimals, like image
                    );
                }
                else
                {
                    sb.Append("<td></td>");
                }
            }

            sb.Append("</tr>");
        }

        sb.Append("</tbody></table>");

        litReportTable.Text = sb.ToString();

        // -------------------------------------------------------
        // 6.  Footer
        // -------------------------------------------------------
        string userName = (Session["UserName"] != null)
            ? Session["UserName"].ToString()
            : HttpContext.Current.User.Identity.Name;

        litFooter.Text = string.Format(
            "Page 1 of 1 &nbsp;&nbsp;&nbsp; {0}, {1} &nbsp;&nbsp;&nbsp; OP:{2}",
            HttpUtility.HtmlEncode(userName),
            DateTime.Now.ToString("dd-MMM-yyyy, hh:mm:ss tt"),
            HttpUtility.HtmlEncode(userName)
        );
    }
}

