using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;
using System.IO;
using System.Web.UI.HtmlControls;

public partial class Pos : System.Web.UI.Page
{
    private string conStr = ConfigurationManager
        .ConnectionStrings["RestaurantConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Set default dates
            txtStartDate.Text = DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd");
            txtEndDate.Text = DateTime.Now.ToString("yyyy-MM-dd");

            // Load initial data
            LoadDashboardData();
        }
    }

    protected void btnLoadReport_Click(object sender, EventArgs e)
    {
        LoadDashboardData();
    }

    protected void txtSearch_TextChanged(object sender, EventArgs e)
    {
        LoadDashboardData();
    }

    protected void gvReports_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvReports.PageIndex = e.NewPageIndex;
        LoadDashboardData();
    }

    private void LoadDashboardData()
    {
        try
        {
            string startDate = txtStartDate.Text;
            string endDate = txtEndDate.Text;
            string reportType = ddlReportType.SelectedValue;
            string searchText = txtSearch.Text.Trim();

            // Load KPIs
            LoadKPIs(startDate, endDate);

            // Load Report Data
            DataTable dt = GetReportData(startDate, endDate, reportType, searchText);
            gvReports.DataSource = dt;
            gvReports.DataBind();

            lblRecordCount.Text = dt.Rows.Count + " records";

            // Load Charts Data
            LoadChartsData(startDate, endDate, reportType);
        }
        catch (Exception ex)
        {
            ShowError("Error loading data: " + ex.Message);
        }
    }

    private void LoadKPIs(string startDate, string endDate)
    {
        string query = @"
            SELECT 
                ISNULL(COUNT(*), 0) as TotalBills,
                ISNULL(SUM(FinalAmount), 0) as NetSales,
                ISNULL(SUM(CASE WHEN ISNUMERIC(Cover) = 1 THEN CAST(Cover AS INT) ELSE 0 END), 0) as TotalCovers,
                CASE 
                    WHEN ISNULL(SUM(CASE WHEN ISNUMERIC(Cover) = 1 THEN CAST(Cover AS INT) ELSE 0 END), 0) > 0 
                    THEN ISNULL(SUM(FinalAmount), 0) / NULLIF(SUM(CASE WHEN ISNUMERIC(Cover) = 1 THEN CAST(Cover AS INT) ELSE 0 END), 0)
                    ELSE 0
                END as PPA
            FROM Bills
            WHERE CAST(CreatedAt AS DATE) BETWEEN @StartDate AND @EndDate";

        using (SqlConnection conn = new SqlConnection(conStr))
        {
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@StartDate", startDate);
                cmd.Parameters.AddWithValue("@EndDate", endDate);

                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    lblTotalBills.Text = reader["TotalBills"].ToString();
                    lblNetSales.Text = "₹" + Convert.ToDecimal(reader["NetSales"]).ToString("N2");
                    lblTotalCovers.Text = reader["TotalCovers"].ToString();
                    lblPPA.Text = "₹" + Convert.ToDecimal(reader["PPA"]).ToString("N2");
                }
                conn.Close();
            }
        }
    }

    private DataTable GetReportData(string startDate, string endDate, string reportType, string searchText)
    {
        string query = GetQueryByReportType(reportType, startDate, endDate);

        DataTable dt = new DataTable();

        using (SqlConnection conn = new SqlConnection(conStr))
        {
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@StartDate", startDate);
                cmd.Parameters.AddWithValue("@EndDate", endDate);

                conn.Open();
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
                conn.Close();
            }
        }

        // Apply search filter if needed
        if (!string.IsNullOrEmpty(searchText) && dt.Rows.Count > 0)
        {
            DataView dv = dt.DefaultView;
            string filterExpression = "";

            foreach (DataColumn col in dt.Columns)
            {
                if (col.DataType == typeof(string))
                {
                    if (filterExpression.Length > 0)
                        filterExpression += " OR ";
                    filterExpression += string.Format("[{0}] LIKE '%{1}%'", col.ColumnName, searchText.Replace("'", "''"));
                }
            }

            if (!string.IsNullOrEmpty(filterExpression))
            {
                dv.RowFilter = filterExpression;
                dt = dv.ToTable();
            }
        }

        return dt;
    }

    private string GetQueryByReportType(string reportType, string startDate, string endDate)
    {
        switch (reportType)
        {
            case "daily":
                return @"
                    SELECT 
                        FORMAT(CAST(CreatedAt AS DATE), 'dd-MMM-yyyy') as BillDate,
                        COUNT(*) as TotalBills,
                        SUM(Total) as GrossSales,
                        SUM(DiscountAmount) as TotalDiscount,
                        SUM(TaxApplied) as TotalTax,
                        SUM(FinalAmount) as NetSales,
                        AVG(FinalAmount) as AvgBillValue
                    FROM Bills
                    WHERE CAST(CreatedAt AS DATE) BETWEEN @StartDate AND @EndDate
                    GROUP BY CAST(CreatedAt AS DATE)
                    ORDER BY CAST(CreatedAt AS DATE) DESC";

            case "payment":
                return @"
                    SELECT 
                        ISNULL(PaymentMethod, 'Not Specified') as PaymentMethod,
                        COUNT(*) as TransactionCount,
                        SUM(AmountPaid) as TotalAmount,
                        COUNT(CASE WHEN Status = 'Paid' THEN 1 END) as SettledBills,
                        SUM(CASE WHEN Status = 'Pending' THEN FinalAmount ELSE 0 END) as PendingAmount
                    FROM Bills
                    WHERE CAST(CreatedAt AS DATE) BETWEEN @StartDate AND @EndDate
                    GROUP BY PaymentMethod
                    ORDER BY TotalAmount DESC";

            case "waiter":
                return @"
                    SELECT 
                        ISNULL(WaiterName, 'Not Assigned') as WaiterName,
                        COUNT(*) as OrdersHandled,
                        SUM(FinalAmount) as RevenueGenerated,
                        AVG(FinalAmount) as AvgOrderValue,
                        SUM(DiscountAmount) as DiscountsGiven,
                        COUNT(CASE WHEN Status = 'Pending' THEN 1 END) as PendingOrders
                    FROM Bills
                    WHERE CAST(CreatedAt AS DATE) BETWEEN @StartDate AND @EndDate
                    GROUP BY WaiterName
                    ORDER BY RevenueGenerated DESC";

            case "cover":
                return @"
                    SELECT 
                        Cover as PartySize,
                        COUNT(*) as BillsCount,
                        SUM(FinalAmount) as TotalRevenue,
                        AVG(FinalAmount) as AvgBillValue,
                        SUM(FinalAmount) / NULLIF(SUM(CAST(Cover AS INT)), 0) as PerPersonAverage
                    FROM Bills
                    WHERE CAST(CreatedAt AS DATE) BETWEEN @StartDate AND @EndDate
                        AND Cover IS NOT NULL 
                        AND ISNUMERIC(Cover) = 1
                    GROUP BY Cover
                    ORDER BY CAST(Cover AS INT)";

            case "hourly":
                return @"
                    SELECT 
                        DATEPART(HOUR, CreatedAt) as HourOfDay,
                        CASE 
                            WHEN DATEPART(HOUR, CreatedAt) BETWEEN 6 AND 11 THEN 'Breakfast'
                            WHEN DATEPART(HOUR, CreatedAt) BETWEEN 12 AND 15 THEN 'Lunch'
                            WHEN DATEPART(HOUR, CreatedAt) BETWEEN 16 AND 18 THEN 'Evening'
                            ELSE 'Dinner'
                        END as MealPeriod,
                        COUNT(*) as OrdersCount,
                        SUM(FinalAmount) as Revenue,
                        AVG(FinalAmount) as AvgBillValue
                    FROM Bills
                    WHERE CAST(CreatedAt AS DATE) BETWEEN @StartDate AND @EndDate
                    GROUP BY DATEPART(HOUR, CreatedAt)
                    ORDER BY HourOfDay";

            case "department":
                return @"
                    SELECT 
                        ISNULL(DepartmentName, 'Other') as DepartmentName,
                        COUNT(*) as OrdersCount,
                        SUM(Total) as GrossRevenue,
                        SUM(DiscountAmount) as Discounts,
                        SUM(TaxApplied) as TaxCollected,
                        SUM(FinalAmount) as NetRevenue,
                        AVG(DiscountApplied) as AvgDiscountPercent
                    FROM Bills
                    WHERE CAST(CreatedAt AS DATE) BETWEEN @StartDate AND @EndDate
                    GROUP BY DepartmentName
                    ORDER BY NetRevenue DESC";

            default:
                return GetQueryByReportType("daily", startDate, endDate);
        }
    }

    private void LoadChartsData(string startDate, string endDate, string reportType)
    {
        string salesQuery = @"
            SELECT TOP 7 
                FORMAT(CAST(CreatedAt AS DATE), 'dd-MMM') as DateLabel,
                SUM(FinalAmount) as DailySales
            FROM Bills
            WHERE CAST(CreatedAt AS DATE) BETWEEN @StartDate AND @EndDate
            GROUP BY CAST(CreatedAt AS DATE)
            ORDER BY CAST(CreatedAt AS DATE) DESC";

        string paymentQuery = @"
            SELECT 
                ISNULL(PaymentMethod, 'Other') as PaymentMethod,
                SUM(AmountPaid) as TotalAmount
            FROM Bills
            WHERE CAST(CreatedAt AS DATE) BETWEEN @StartDate AND @EndDate
                AND PaymentMethod IS NOT NULL
            GROUP BY PaymentMethod";

        DataTable salesDt = new DataTable();
        DataTable paymentDt = new DataTable();

        using (SqlConnection conn = new SqlConnection(conStr))
        {
            // Get Sales Data
            using (SqlCommand cmd = new SqlCommand(salesQuery, conn))
            {
                cmd.Parameters.AddWithValue("@StartDate", startDate);
                cmd.Parameters.AddWithValue("@EndDate", endDate);

                conn.Open();
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(salesDt);
                conn.Close();
            }

            // Get Payment Data
            using (SqlCommand cmd = new SqlCommand(paymentQuery, conn))
            {
                cmd.Parameters.AddWithValue("@StartDate", startDate);
                cmd.Parameters.AddWithValue("@EndDate", endDate);

                conn.Open();
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(paymentDt);
                conn.Close();
            }
        }

        // Prepare JavaScript arrays
        StringBuilder salesLabels = new StringBuilder();
        StringBuilder salesData = new StringBuilder();

        foreach (DataRow row in salesDt.Rows)
        {
            salesLabels.Append("'" + row["DateLabel"].ToString() + "',");
            salesData.Append(row["DailySales"].ToString() + ",");
        }

        StringBuilder paymentLabels = new StringBuilder();
        StringBuilder paymentData = new StringBuilder();

        foreach (DataRow row in paymentDt.Rows)
        {
            paymentLabels.Append("'" + row["PaymentMethod"].ToString() + "',");
            paymentData.Append(row["TotalAmount"].ToString() + ",");
        }

        // Register script to initialize charts
        string script = @"
            setTimeout(function() {
                initializeCharts(
                    [" + salesLabels.ToString().TrimEnd(',') + @"],
                    [" + salesData.ToString().TrimEnd(',') + @"],
                    [" + paymentLabels.ToString().TrimEnd(',') + @"],
                    [" + paymentData.ToString().TrimEnd(',') + @"]
                );
            }, 100);
        ";

        ClientScript.RegisterStartupScript(this.GetType(), "InitCharts", script, true);
    }

    protected void btnExportPDF_Click(object sender, EventArgs e)
    {
        try
        {
            // Create HTML content for PDF
            StringBuilder html = new StringBuilder();
            html.Append("<html><head>");
            html.Append("<style>");
            html.Append("body { font-family: Arial, sans-serif; margin: 20px; }");
            html.Append("h1 { color: #667eea; }");
            html.Append("table { width: 100%; border-collapse: collapse; margin-top: 20px; }");
            html.Append("th { background: #667eea; color: white; padding: 10px; }");
            html.Append("td { padding: 8px; border-bottom: 1px solid #ddd; }");
            html.Append(".header { text-align: center; margin-bottom: 30px; }");
            html.Append(".kpi { display: inline-block; margin: 10px; padding: 15px; border: 1px solid #ddd; border-radius: 10px; }");
            html.Append("</style>");
            html.Append("</head><body>");

            // Header
            html.Append("<div class='header'>");
            html.Append("<h1>Restaurant POS Report</h1>");
            html.Append("<p>Period: " + txtStartDate.Text + " to " + txtEndDate.Text + "</p>");
            html.Append("<p>Report Type: " + ddlReportType.SelectedItem.Text + "</p>");
            html.Append("<p>Generated: " + DateTime.Now.ToString("dd-MMM-yyyy HH:mm:ss") + "</p>");
            html.Append("</div>");

            // KPIs
            html.Append("<div>");
            html.Append("<div class='kpi'><strong>Total Bills:</strong> " + lblTotalBills.Text + "</div>");
            html.Append("<div class='kpi'><strong>Net Sales:</strong> " + lblNetSales.Text + "</div>");
            html.Append("<div class='kpi'><strong>Total Covers:</strong> " + lblTotalCovers.Text + "</div>");
            html.Append("<div class='kpi'><strong>PPA:</strong> " + lblPPA.Text + "</div>");
            html.Append("</div>");

            // Data Table
            html.Append("<h3>Report Details</h3>");
            html.Append(GridViewToHtml(gvReports));

            html.Append("</body></html>");

            // Export to PDF (using simple HTML to PDF approach)
            Response.Clear();
            Response.ContentType = "application/pdf";
            Response.AddHeader("content-disposition", "attachment;filename=RestaurantReport.pdf");
            Response.Write(html.ToString());
            Response.End();
        }
        catch (Exception ex)
        {
            ShowError("Error generating PDF: " + ex.Message);
        }
    }

    protected void btnExportExcel_Click(object sender, EventArgs e)
    {
        try
        {
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=RestaurantReport.xls");
            Response.Charset = "";
            Response.ContentType = "application/vnd.ms-excel";

            using (StringWriter sw = new StringWriter())
            {
                using (HtmlTextWriter hw = new HtmlTextWriter(sw))
                {
                    // Header
                    hw.RenderBeginTag(HtmlTextWriterTag.H1);
                    hw.Write("Restaurant POS Report");
                    hw.RenderEndTag();

                    hw.RenderBeginTag(HtmlTextWriterTag.P);
                    hw.Write("Period: " + txtStartDate.Text + " to " + txtEndDate.Text);
                    hw.RenderEndTag();

                    hw.RenderBeginTag(HtmlTextWriterTag.P);
                    hw.Write("Report Type: " + ddlReportType.SelectedItem.Text);
                    hw.RenderEndTag();

                    hw.RenderBeginTag(HtmlTextWriterTag.P);
                    hw.Write("Generated: " + DateTime.Now.ToString("dd-MMM-yyyy HH:mm:ss"));
                    hw.RenderEndTag();

                    // KPIs
                    hw.RenderBeginTag(HtmlTextWriterTag.Table);
                    hw.RenderBeginTag(HtmlTextWriterTag.Tr);
                    hw.RenderBeginTag(HtmlTextWriterTag.Td);
                    hw.Write("Total Bills: " + lblTotalBills.Text);
                    hw.RenderEndTag();
                    hw.RenderBeginTag(HtmlTextWriterTag.Td);
                    hw.Write("Net Sales: " + lblNetSales.Text);
                    hw.RenderEndTag();
                    hw.RenderBeginTag(HtmlTextWriterTag.Td);
                    hw.Write("Total Covers: " + lblTotalCovers.Text);
                    hw.RenderEndTag();
                    hw.RenderBeginTag(HtmlTextWriterTag.Td);
                    hw.Write("PPA: " + lblPPA.Text);
                    hw.RenderEndTag();
                    hw.RenderEndTag();
                    hw.RenderEndTag();

                    // Data Grid
                    gvReports.RenderControl(hw);

                    Response.Write(sw.ToString());
                }
            }
            Response.End();
        }
        catch (Exception ex)
        {
            ShowError("Error exporting to Excel: " + ex.Message);
        }
    }

    private string GridViewToHtml(GridView gv)
    {
        StringBuilder sb = new StringBuilder();
        StringWriter sw = new StringWriter(sb);
        HtmlTextWriter htw = new HtmlTextWriter(sw);

        gv.RenderControl(htw);

        return sb.ToString();
    }

    private void ShowError(string message)
    {
        string script = "alert('" + message.Replace("'", "\\'") + "');";
        ClientScript.RegisterStartupScript(this.GetType(), "Error", script, true);
    }

    // Override VerifyRenderingInServerForm for Excel export
    public override void VerifyRenderingInServerForm(Control control)
    {
        // Required for GridView export
    }
}

