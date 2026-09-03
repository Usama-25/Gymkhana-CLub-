using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Store_Add_Unit : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object GetKOTByMember(string memberNo, string date)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(memberNo))
                return new { success = false, message = "Member number is required" };

            if (string.IsNullOrWhiteSpace(date))
                return new { success = false, message = "Date is required" };

            DateTime searchDate;
            if (!DateTime.TryParse(date, out searchDate))
                return new { success = false, message = "Invalid date format" };

            // Set date range for the selected day
            DateTime startDate = searchDate.Date;
            DateTime endDate = startDate.AddDays(1).AddSeconds(-1);

            string constr = ConfigurationManager
                .ConnectionStrings["RestaurantConnectionString"]
                .ConnectionString;

            // First, get member information
            object memberInfo = GetMemberInfo(memberNo, constr);

            // Get orders for this member on the selected date
            var orders = new List<object>();

            using (SqlConnection con = new SqlConnection(constr))
            {
                string query = @"
                    SELECT 
                        b.Id AS OrderId,
                        b.CreatedAt,
                        b.Total,
                        b.Subtotal,
                        b.MemberNo,
                        b.Status,
                        b.TableNumber,
                        b.DepartmentName,
                        b.WaiterName,
                        ISNULL(b.Cover, 1) AS Cover,
                        ISNULL(b.KOT_Number, '') AS KOT_Number,
                        b.roomno,
                        b.TaxApplied,
                        b.FinalAmount
                    FROM Bills b
                    WHERE b.MemberNo = @MemberNo
                        AND b.CreatedAt BETWEEN @StartDate AND @EndDate
                        AND b.Status IN ('Pending', 'In Progress', 'Completed', 'Delivered')
                    ORDER BY b.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                    cmd.Parameters.AddWithValue("@StartDate", startDate);
                    cmd.Parameters.AddWithValue("@EndDate", endDate);

                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        var order = new
                        {
                            id = Convert.ToInt32(dr["OrderId"]),
                            date = Convert.ToDateTime(dr["CreatedAt"]).ToString("dd MMM yyyy hh:mm tt"),
                            total = Convert.ToDecimal(dr["Total"]),
                            subtotal = dr["Subtotal"] == DBNull.Value ? 0 : Convert.ToDecimal(dr["Subtotal"]),
                            taxApplied = dr["TaxApplied"] == DBNull.Value ? 0 : Convert.ToDecimal(dr["TaxApplied"]),
                            memberNo = dr["MemberNo"].ToString(),
                            status = dr["Status"].ToString(),
                            tableNumber = dr["TableNumber"] == DBNull.Value ? "" : dr["TableNumber"].ToString(),
                            departmentName = dr["DepartmentName"] == DBNull.Value ? "" : dr["DepartmentName"].ToString(),
                            waiterName = dr["WaiterName"] == DBNull.Value ? "" : dr["WaiterName"].ToString(),
                            cover = Convert.ToInt32(dr["Cover"]),
                            kotNumber = dr["KOT_Number"].ToString(),
                            roomNo = dr["roomno"] == DBNull.Value ? "" : dr["roomno"].ToString(),
                            items = GetOrderItems(Convert.ToInt32(dr["OrderId"]), constr)
                        };
                        orders.Add(order);
                    }
                    dr.Close();
                }
            }

            if (orders.Count == 0)
            {
                return new { success = false, message = "No KOT found for this member on the selected date" };
            }

            return new
            {
                success = true,
                memberInfo = memberInfo,
                orders = orders,
                count = orders.Count
            };
        }
        catch (Exception ex)
        {
            Debug.WriteLine("GetKOTByMember Error: " + ex.Message);
            return new { success = false, message = "Error: " + ex.Message };
        }
    }

    private static object GetMemberInfo(string memberNo, string connectionString)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = @"
                    SELECT TOP 1
                        m.MemberNo,
                        m.MemberName,
                        m.Email,
                        m.MobileNo,
                        m.CardNo
                    FROM MemberMst m
                    WHERE m.MemberNo = @MemberNo OR m.CardNo = @MemberNo";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    if (dr.Read())
                    {
                        return new
                        {
                            memberNo = dr["MemberNo"].ToString(),
                            name = dr["MemberName"].ToString(),
                            email = dr["Email"] == DBNull.Value ? "" : dr["Email"].ToString(),
                            phone = dr["MobileNo"] == DBNull.Value ? "" : dr["MobileNo"].ToString(),
                            cardNo = dr["CardNo"] == DBNull.Value ? "" : dr["CardNo"].ToString()
                        };
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine("GetMemberInfo Error: " + ex.Message);
        }

        return new
        {
            memberNo = memberNo,
            name = "Member Information Not Found",
            email = "",
            phone = "",
            cardNo = ""
        };
    }

    private static List<object> GetOrderItems(int orderId, string connectionString)
    {
        var items = new List<object>();

        try
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = @"
                    SELECT 
                        bi.Name,
                        bi.Quantity,
                        bi.Price,
                        bi.LineTotal
                    FROM BillItems bi
                    WHERE bi.BillId = @OrderId
                    ORDER BY bi.Id";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@OrderId", orderId);
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        items.Add(new
                        {
                            name = dr["Name"].ToString(),
                            quantity = Convert.ToInt32(dr["Quantity"]),
                            price = Convert.ToDecimal(dr["Price"]),
                            lineTotal = Convert.ToDecimal(dr["LineTotal"])
                        });
                    }
                    dr.Close();
                }
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine("GetOrderItems Error: " + ex.Message);
        }

        return items;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object GetOrderDetails(int orderId)
    {
        try
        {
            string constr = ConfigurationManager
                .ConnectionStrings["RestaurantConnectionString"]
                .ConnectionString;

            using (SqlConnection con = new SqlConnection(constr))
            {
                string orderQuery = @"
                    SELECT 
                        b.Id AS OrderId,
                        b.CreatedAt,
                        b.Total,
                        b.Subtotal,
                        b.MemberNo,
                        b.Status,
                        b.TableNumber,
                        b.DepartmentName,
                        b.WaiterName,
                        ISNULL(b.Cover, 1) AS Cover,
                        ISNULL(b.KOT_Number, '') AS KOT_Number,
                        b.roomno,
                        b.TaxApplied,
                        b.FinalAmount,
                        m.MemberName
                    FROM Bills b
                    LEFT JOIN MemberMst m ON m.MemberNo = b.MemberNo
                    WHERE b.Id = @OrderId";

                using (SqlCommand cmd = new SqlCommand(orderQuery, con))
                {
                    cmd.Parameters.AddWithValue("@OrderId", orderId);
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    if (dr.Read())
                    {
                        DateTime createdAt = Convert.ToDateTime(dr["CreatedAt"]);
                        var order = new
                        {
                            id = Convert.ToInt32(dr["OrderId"]),
                            date = createdAt.ToString("dd MMM yyyy"),
                            time = createdAt.ToString("hh:mm tt"),
                            total = Convert.ToDecimal(dr["Total"]),
                            subtotal = dr["Subtotal"] == DBNull.Value ? 0 : Convert.ToDecimal(dr["Subtotal"]),
                            taxApplied = dr["TaxApplied"] == DBNull.Value ? 0 : Convert.ToDecimal(dr["TaxApplied"]),
                            memberNo = dr["MemberNo"].ToString(),
                            memberName = dr["MemberName"] == DBNull.Value ? "" : dr["MemberName"].ToString(),
                            status = dr["Status"].ToString(),
                            tableNumber = dr["TableNumber"] == DBNull.Value ? "" : dr["TableNumber"].ToString(),
                            departmentName = dr["DepartmentName"] == DBNull.Value ? "" : dr["DepartmentName"].ToString(),
                            waiterName = dr["WaiterName"] == DBNull.Value ? "" : dr["WaiterName"].ToString(),
                            cover = Convert.ToInt32(dr["Cover"]),
                            kotNumber = dr["KOT_Number"].ToString(),
                            roomNo = dr["roomno"] == DBNull.Value ? "" : dr["roomno"].ToString(),
                            items = GetOrderItems(orderId, constr)
                        };

                        dr.Close();
                        return new { success = true, order = order };
                    }
                    dr.Close();
                }
            }

            return new { success = false, message = "Order not found" };
        }
        catch (Exception ex)
        {
            Debug.WriteLine("GetOrderDetails Error: " + ex.Message);
            return new { success = false, message = "Error: " + ex.Message };
        }
    }

}


