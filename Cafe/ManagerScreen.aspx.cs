using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.UI;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Text;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Diagnostics;
using System.Web;

public partial class ManagerScreen : System.Web.UI.Page
{
    string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Check if user is manager (you should implement proper authentication)
            //if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Manager")
            //{
            //    Response.Redirect("Login.aspx");
            //}
        }
    }

    [WebMethod]
    public static string GetDashboardData()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString))
            {
                con.Open();

                // Today's sales
                string salesQuery = @"
                    SELECT 
                        ISNULL(SUM(Total), 0) AS TodaySales,
                        COUNT(*) AS TodayOrders
                    FROM Bills 
                    WHERE CAST(CreatedAt AS DATE) = CAST(GETDATE() AS DATE)
                    AND Status != 'Cancelled'";

                using (SqlCommand cmd = new SqlCommand(salesQuery, con))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        decimal todaySales = 0;
                        int todayOrders = 0;

                        if (reader.Read())
                        {
                            todaySales = Convert.ToDecimal(reader["TodaySales"]);
                            todayOrders = Convert.ToInt32(reader["TodayOrders"]);
                        }
                        reader.Close();

                        // Yesterday's sales for comparison
                        string yesterdayQuery = @"
                            SELECT ISNULL(SUM(Total), 0) AS YesterdaySales
                            FROM Bills 
                            WHERE CAST(CreatedAt AS DATE) = CAST(DATEADD(day, -1, GETDATE()) AS DATE)
                            AND Status != 'Cancelled'";

                        cmd.CommandText = yesterdayQuery;
                        decimal yesterdaySales = Convert.ToDecimal(cmd.ExecuteScalar());

                        // Active orders
                        string activeQuery = @"
                            SELECT COUNT(*) AS ActiveOrders 
                            FROM Bills 
                            WHERE Status IN ('Pending', 'Preparing','In Progress', 'Ready','Completed')";

                        cmd.CommandText = activeQuery;
                        int activeOrders = Convert.ToInt32(cmd.ExecuteScalar());

                        // Pending delivery
                        string deliveryQuery = @"
                            SELECT COUNT(*) AS PendingDelivery
                            FROM Bills 
                            WHERE Status = 'Pending'";

                        cmd.CommandText = deliveryQuery;
                        int pendingDelivery = Convert.ToInt32(cmd.ExecuteScalar());

                        // Total orders
                        string totalOrdersQuery = "SELECT COUNT(*) FROM Bills";
                        cmd.CommandText = totalOrdersQuery;
                        int totalOrders = Convert.ToInt32(cmd.ExecuteScalar());

                        // Calculate sales change percentage
                        decimal salesChange = 0;
                        if (yesterdaySales > 0)
                        {
                            salesChange = ((todaySales - yesterdaySales) / yesterdaySales) * 100;
                        }
                        else if (todaySales > 0)
                        {
                            salesChange = 100; // First day with sales
                        }

                        var result = new
                        {
                            TodaySales = todaySales,
                            TodayOrders = todayOrders,
                            TotalOrders = totalOrders,
                            ActiveOrders = activeOrders,
                            PendingDelivery = pendingDelivery,
                            SalesChange = Math.Round(salesChange, 2)
                        };

                        return JsonConvert.SerializeObject(result);
                    }
                }
            }
        }
        catch (Exception)
        {
            return JsonConvert.SerializeObject(new
            {
                TodaySales = 0.00m,
                TodayOrders = 0,
                TotalOrders = 0,
                ActiveOrders = 0,
                PendingDelivery = 0,
                SalesChange = 0.00m
            });
        }
    }

    [WebMethod]
    public static string GetOrders(string status, string waiter, string date)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString))
            {
                con.Open();

                StringBuilder query = new StringBuilder(@"
                    SELECT 
                        Id, 
                        CreatedAt,
                        Total,
                        MemberNo,
                        Status,
                        TableNumber,
                        WaiterName,
                        DepartmentName,
                        EmployeeID
                    FROM Bills 
                    WHERE 1=1");

                if (!string.IsNullOrEmpty(status))
                {
                    query.Append(" AND Status = @Status");
                }

                if (!string.IsNullOrEmpty(waiter))
                {
                    query.Append(" AND WaiterName = @WaiterName");
                }

                if (!string.IsNullOrEmpty(date))
                {
                    query.Append(" AND CAST(CreatedAt AS DATE) = @Date");
                }

                query.Append(" ORDER BY CreatedAt DESC");

                using (SqlCommand cmd = new SqlCommand(query.ToString(), con))
                {
                    if (!string.IsNullOrEmpty(status))
                        cmd.Parameters.AddWithValue("@Status", status);

                    if (!string.IsNullOrEmpty(waiter))
                        cmd.Parameters.AddWithValue("@WaiterName", waiter);

                    if (!string.IsNullOrEmpty(date))
                        cmd.Parameters.AddWithValue("@Date", date);

                    DataTable dt = new DataTable();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }

                    return JsonConvert.SerializeObject(dt);
                }
            }
        }
        catch (Exception)
        {
            return "[]";
        }
    }

    [WebMethod]
    public static string GetOrderDetails(int orderId)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString))
            {
                con.Open();

                // Get order info
                string orderQuery = @"
                    SELECT * FROM Bills WHERE Id = @OrderId";

                DataTable orderDt = new DataTable();
                using (SqlCommand cmd = new SqlCommand(orderQuery, con))
                {
                    cmd.Parameters.AddWithValue("@OrderId", orderId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(orderDt);
                    }
                }

                // Get order items
                string itemsQuery = @"
                    SELECT 
                        Id,
                        BillId,
                        MenuItemId,
                        Name,
                        Price,
                        Quantity,
                        Notes,
                        LineTotal,
                        IsPrep,
                        PrepTime
                    FROM BillItems 
                    WHERE BillId = @OrderId";

                DataTable itemsDt = new DataTable();
                using (SqlCommand cmd = new SqlCommand(itemsQuery, con))
                {
                    cmd.Parameters.AddWithValue("@OrderId", orderId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(itemsDt);
                    }
                }

                var result = new
                {
                    order = orderDt.Rows.Count > 0 ? orderDt.Rows[0] : null,
                    items = itemsDt
                };

                return JsonConvert.SerializeObject(result);
            }
        }
        catch (Exception)
        {
            return "{}";
        }
    }

    [WebMethod]
    public static string UpdateOrderStatus(int orderId, string status)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString))
            {
                con.Open();

                string query = @"
                    UPDATE Bills 
                    SET Status = @Status 
                    WHERE Id = @OrderId";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@OrderId", orderId);
                    cmd.Parameters.AddWithValue("@Status", status);
                    cmd.ExecuteNonQuery();
                }

                return "success";
            }
        }
        catch (Exception ex)
        {
            return "error: " + ex.Message;
        }
    }

    [WebMethod]
    public static string GetKitchenData()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString))
            {
                con.Open();

                string query = @"
                    SELECT 
                        bi.Id,
                        bi.BillId,
                        bi.Name,
                        bi.Price,
                        bi.Quantity,
                        bi.Notes,
                        bi.LineTotal,
                        bi.IsPrep,
                        bi.PrepTime,
                        b.TableNumber,
                        b.WaiterName
                    FROM BillItems bi
                    INNER JOIN Bills b ON bi.BillId = b.Id
                    WHERE b.Status IN ('Pending', 'Preparing', 'Ready')
                    AND bi.IsPrep != 'Completed'
                    ORDER BY b.CreatedAt DESC, bi.Id";

                DataTable dt = new DataTable();
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }

                return JsonConvert.SerializeObject(dt);
            }
        }
        catch (Exception)
        {
            return "[]";
        }
    }

    [WebMethod]
    public static string UpdatePrepStatus(int itemId, string status)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString))
            {
                con.Open();

                string query = @"
                    UPDATE BillItems 
                    SET IsPrep = @Status,
                        PrepTime = CASE WHEN @Status = 'Ready' THEN GETDATE() ELSE NULL END
                    WHERE Id = @ItemId";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@ItemId", itemId);
                    cmd.Parameters.AddWithValue("@Status", status);
                    cmd.ExecuteNonQuery();
                }

                return "success";
            }
        }
        catch (Exception ex)
        {
            return "error: " + ex.Message;
        }
    }

    [WebMethod]
    public static string GetStaffPerformance(string period)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString))
            {
                con.Open();

                string dateFilter = "";
                switch (period)
                {
                    case "Today":
                        dateFilter = "CAST(CreatedAt AS DATE) = CAST(GETDATE() AS DATE)";
                        break;
                    case "This Week":
                        dateFilter = "CreatedAt >= DATEADD(day, -7, GETDATE())";
                        break;
                    case "This Month":
                        dateFilter = "CreatedAt >= DATEADD(month, -1, GETDATE())";
                        break;
                    default:
                        dateFilter = "CAST(CreatedAt AS DATE) = CAST(GETDATE() AS DATE)";
                        break;
                }

                string query = @"
                    SELECT 
                        WaiterName,
                        COUNT(Id) AS OrderCount,
                        ISNULL(SUM(Total), 0) AS TotalSales,
                        ISNULL(AVG(Total), 0) AS AverageOrder,
                        SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledOrders
                    FROM Bills
                    WHERE " + dateFilter + @"
                    AND WaiterName IS NOT NULL
                    GROUP BY WaiterName
                    ORDER BY TotalSales DESC";

                DataTable dt = new DataTable();
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }

                // Calculate performance percentage
                List<dynamic> results = new List<dynamic>();
                foreach (DataRow row in dt.Rows)
                {
                    int orderCount = Convert.ToInt32(row["OrderCount"]);
                    decimal totalSales = Convert.ToDecimal(row["TotalSales"]);
                    int cancelledOrders = Convert.ToInt32(row["CancelledOrders"]);

                    // Simple performance calculation
                    decimal performance = 0;
                    if (orderCount > 0)
                    {
                        decimal successRate = ((orderCount - cancelledOrders) / (decimal)orderCount) * 100;
                        decimal salesPerOrder = totalSales / orderCount;

                        // Weighted performance (70% success rate, 30% sales performance)
                        performance = (successRate * 0.7m) + (Math.Min(salesPerOrder / 100m, 1) * 30m);
                    }

                    results.Add(new
                    {
                        WaiterName = row["WaiterName"].ToString(),
                        OrderCount = orderCount,
                        TotalSales = totalSales,
                        AverageOrder = Convert.ToDecimal(row["AverageOrder"]),
                        CancelledOrders = cancelledOrders,
                        Performance = Math.Round(performance, 1)
                    });
                }

                return JsonConvert.SerializeObject(results);
            }
        }
        catch (Exception)
        {
            return "[]";
        }
    }

    [WebMethod]
    public static string GetDeliveryData()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString))
            {
                con.Open();

                string query = @"
                    SELECT 
                        dl.Id,
                        dl.BillId,
                        dl.MemberNo,
                        dl.Status,
                        dl.DeliveredAt,
                        dl.DeliveredBy,
                        b.Total,
                        b.TableNumber
                    FROM DeliveryLog dl
                    INNER JOIN Bills b ON dl.BillId = b.Id
                    WHERE dl.DeliveredAt >= DATEADD(day, -1, GETDATE())
                    ORDER BY dl.DeliveredAt DESC";

                DataTable dt = new DataTable();
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }

                return JsonConvert.SerializeObject(dt);
            }
        }
        catch (Exception)
        {
            return "[]";
        }
    }

    [WebMethod]
    public static string CancelOrder(int orderId)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString))
            {
                con.Open();

                using (SqlTransaction trans = con.BeginTransaction())
                {
                    try
                    {
                        // Update bill status
                        string billQuery = @"
                            UPDATE Bills 
                            SET Status = 'Cancelled' 
                            WHERE Id = @OrderId";

                        using (SqlCommand cmd = new SqlCommand(billQuery, con, trans))
                        {
                            cmd.Parameters.AddWithValue("@OrderId", orderId);
                            cmd.ExecuteNonQuery();
                        }

                        // Update bill items prep status
                        string itemsQuery = @"
                            UPDATE BillItems 
                            SET IsPrep = 'Cancelled' 
                            WHERE BillId = @OrderId";

                        using (SqlCommand cmd = new SqlCommand(itemsQuery, con, trans))
                        {
                            cmd.Parameters.AddWithValue("@OrderId", orderId);
                            cmd.ExecuteNonQuery();
                        }

                        trans.Commit();
                        return "success";
                    }
                    catch
                    {
                        trans.Rollback();
                        throw;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            return "error: " + ex.Message;
        }
    }

    [WebMethod]
    public static string GenerateReport(string reportType, string fromDate, string toDate)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString))
            {
                con.Open();

                if (reportType == "sales")
                {
                    string query = @"
                        SELECT 
                            COUNT(*) AS TotalOrders,
                            ISNULL(SUM(Total), 0) AS TotalSales,
                            ISNULL(AVG(Total), 0) AS AverageOrder
                        FROM Bills
                        WHERE CreatedAt >= @FromDate 
                        AND CreatedAt <= DATEADD(day, 1, @ToDate)
                        AND Status != 'Cancelled'";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@FromDate", fromDate);
                        cmd.Parameters.AddWithValue("@ToDate", toDate);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                var result = new
                                {
                                    TotalOrders = Convert.ToInt32(reader["TotalOrders"]),
                                    TotalSales = Convert.ToDecimal(reader["TotalSales"]),
                                    AverageOrder = Convert.ToDecimal(reader["AverageOrder"])
                                };

                                return JsonConvert.SerializeObject(result);
                            }
                        }
                    }
                }

                return "{}";
            }
        }
        catch (Exception)
        {
            return "{}";
        }
    }
}

