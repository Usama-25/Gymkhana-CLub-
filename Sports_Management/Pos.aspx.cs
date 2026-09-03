using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;

public partial class Pos : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
    }

    // =======================
    // GET DEPARTMENTS
    // =======================
    [WebMethod]
    public static List<Department> GetDepartments()
    {
        var departments = new List<Department>();
        try
        {
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["BasicDataInfoConnectionString"].ConnectionString))
            {
                string query = "SELECT Dept_ID, Dept_Name FROM Department ORDER BY Dept_Name";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        departments.Add(new Department
                        {
                            Dept_ID = Convert.ToInt32(dr["Dept_ID"]),
                            Dept_Name = dr["Dept_Name"].ToString()
                        });
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // Return sample departments for testing
            departments.Add(new Department { Dept_ID = 1, Dept_Name = "Sports" });
            departments.Add(new Department { Dept_ID = 2, Dept_Name = "Fitness" });
            departments.Add(new Department { Dept_ID = 3, Dept_Name = "Wellness" });
        }
        return departments;
    }

    // =======================
    // GET PRODUCTS WITH DEPARTMENT FILTER
    // =======================
    [WebMethod]
    public static object GetProducts(string search, string category = "", string dept = "", string sort = "")
    {
        try
        {
            string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(constr))
            {
                string query = @"
                    SELECT TOP 50 
                        Id, 
                        Name, 
                        Price, 
                        'resources/images/food.png' AS ImagePath,
                        ISNULL(Category, 'Physical') AS Category,
                        ISNULL(Dept_ID, 0) AS DeptId
                    FROM SportsMenuItems 
                    WHERE (@search='' OR Name LIKE '%'+@search+'%') 
                    AND (ISNULL(Category, 'Physical') IN ('Physical', 'Services'))
                    AND (@category='' OR ISNULL(Category, 'Physical')=@category)
                    AND (@dept='' OR ISNULL(Dept_ID, 0)=@dept OR @dept='0')";

                // Add sorting
                switch (sort)
                {
                    case "name_asc":
                        query += " ORDER BY Name ASC";
                        break;
                    case "name_desc":
                        query += " ORDER BY Name DESC";
                        break;
                    case "price_asc":
                        query += " ORDER BY Price ASC";
                        break;
                    case "price_desc":
                        query += " ORDER BY Price DESC";
                        break;
                    default:
                        query += " ORDER BY Name ASC";
                        break;
                }

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@search", search ?? "");
                    cmd.Parameters.AddWithValue("@category", category ?? "");
                    cmd.Parameters.AddWithValue("@dept", string.IsNullOrEmpty(dept) ? "0" : dept);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            var list = new List<object>();
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new
                {
                    id = r["Id"].ToString(),
                    name = r["Name"].ToString(),
                    price = Convert.ToDecimal(r["Price"]),
                    image = VirtualPathUtility.ToAbsolute("~/" + r["ImagePath"]),
                    category = r["Category"].ToString(),
                    deptId = Convert.ToInt32(r["DeptId"])
                });
            }

            return list;
        }
        catch (Exception ex)
        {
            // Return sample data for testing
            return GetSampleProducts();
        }
    }

    // Sample products for testing
    private static List<object> GetSampleProducts()
    {
        return new List<object>
        {
            new { id = 1, name = "Running Shoes", price = 2999.99m, image = "https://images.unsplash.com/photo-1542291026-7eec264c27ff?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80", category = "Physical", deptId = 1 },
            new { id = 2, name = "Yoga Mat", price = 1299.50m, image = "https://images.unsplash.com/photo-1599901860904-17e6ed7083a0?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80", category = "Physical", deptId = 2 },
            new { id = 3, name = "Dumbbell Set", price = 4599.00m, image = "https://images.unsplash.com/photo-1534367507877-0edd93bd013b?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80", category = "Physical", deptId = 1 },
            new { id = 4, name = "Sports Jersey", price = 1999.00m, image = "https://images.unsplash.com/photo-1523374228107-6e44bd2b524e?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80", category = "Physical", deptId = 1 },
            new { id = 5, name = "Fitness Tracker", price = 3499.99m, image = "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80", category = "Physical", deptId = 2 },
            new { id = 6, name = "Tennis Racket", price = 5899.00m, image = "https://images.unsplash.com/photo-1554068865-24cecd4e34b8?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80", category = "Physical", deptId = 1 },
            new { id = 7, name = "Gym Bag", price = 1799.50m, image = "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80", category = "Physical", deptId = 2 },
            new { id = 8, name = "Protein Shaker", price = 699.00m, image = "https://images.unsplash.com/photo-1594736797933-df1d6a7953c9?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80", category = "Physical", deptId = 2 },
            new { id = 9, name = "Personal Training", price = 1500.00m, image = "https://images.unsplash.com/photo-1549060279-7e168fce7090?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80", category = "Services", deptId = 2 },
            new { id = 10, name = "Gym Membership", price = 2000.00m, image = "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80", category = "Services", deptId = 2 },
            new { id = 11, name = "Yoga Classes", price = 1200.00m, image = "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80", category = "Services", deptId = 3 },
            new { id = 12, name = "Sports Massage", price = 1800.00m, image = "https://images.unsplash.com/photo-1544161515-4ab6ce6db874?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80", category = "Services", deptId = 3 },
            new { id = 13, name = "Badminton Court", price = 500.00m, image = "https://images.unsplash.com/photo-1622279456716-4c5e00e23f58?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80", category = "Services", deptId = 1 },
            new { id = 14, name = "Swimming Pool Access", price = 800.00m, image = "https://images.unsplash.com/photo-1598974357801-cbca100e5d10?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80", category = "Services", deptId = 1 }
        };
    }

    // =======================
    // GET SERVICE PRICES
    // =======================
    [WebMethod]
    public static object GetServicePrices(string productName)
    {
        try
        {
            string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(constr))
            {
                string query = @"
                SELECT Daily, Monthly, [Continue] as ContinuePrice, Name
                FROM SportsPrice 
                WHERE Category = 'Services' 
                AND (
                    @Name LIKE '%' + Name + '%' 
                    OR Name LIKE '%' + @Name + '%'
                    OR @Name = Name
                )";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Name", productName);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            if (dt.Rows.Count > 0)
            {
                return new
                {
                    success = true,
                    daily = Convert.ToDecimal(dt.Rows[0]["Daily"]),
                    monthly = Convert.ToDecimal(dt.Rows[0]["Monthly"]),
                    continuePrice = Convert.ToDecimal(dt.Rows[0]["ContinuePrice"]),
                    productName = dt.Rows[0]["Name"].ToString()
                };
            }
            else
            {
                string lowerName = productName.ToLower();

                if (lowerName.Contains("badminton") || lowerName.Contains("court"))
                {
                    return new
                    {
                        success = true,
                        daily = 800m,
                        monthly = 3000m,
                        continuePrice = 5000m,
                        productName = productName
                    };
                }
                else if (lowerName.Contains("gym") || lowerName.Contains("membership"))
                {
                    return new
                    {
                        success = true,
                        daily = 1200m,
                        monthly = 4000m,
                        continuePrice = 9000m,
                        productName = productName
                    };
                }
                else if (lowerName.Contains("yoga") || lowerName.Contains("class"))
                {
                    return new
                    {
                        success = true,
                        daily = 500m,
                        monthly = 1500m,
                        continuePrice = 3500m,
                        productName = productName
                    };
                }
                else if (lowerName.Contains("training") || lowerName.Contains("personal"))
                {
                    return new
                    {
                        success = true,
                        daily = 1500m,
                        monthly = 5000m,
                        continuePrice = 12000m,
                        productName = productName
                    };
                }
                else
                {
                    return new
                    {
                        success = true,
                        daily = 500m,
                        monthly = 2000m,
                        continuePrice = 5000m,
                        productName = productName
                    };
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("GetServicePrices error: " + ex.Message);

            return new
            {
                success = false,
                message = ex.Message
            };
        }
    }

    // =======================
    // GET MEMBER
    // =======================
    [WebMethod]
    public static object GetMember(string search)
    {
        try
        {
            string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;

            using (SqlConnection con = new SqlConnection(constr))
            {
                SqlCommand cmd = new SqlCommand(@"
                    SELECT TOP 1
                        mc.MemberID AS CardNo,
                        pt.RFName AS DisplayName,
                        pt.RFName AS Name,
                        pt.Mobile AS Mobile,
                        mb.Credit AS Balance
                    FROM MemberCard mc
                    LEFT JOIN Patient pt ON pt.RegNo = mc.MemberID
                    INNER JOIN MemberBalance mb ON mb.MemberNo = mc.MemberID
                    WHERE mc.CardNo LIKE @val + '%' 
                        OR pt.PLName LIKE @val + '%'", con);

                cmd.Parameters.AddWithValue("@val", search);
                con.Open();
                var rd = cmd.ExecuteReader();

                if (!rd.Read())
                    return null;

                return new
                {
                    CardNo = rd["CardNo"].ToString(),
                    DisplayName = rd["DisplayName"].ToString(),
                    rfName = rd["Name"].ToString(),
                    mobile = rd["Mobile"].ToString(),
                    balance = Convert.ToDecimal(rd["Balance"])
                };
            }
        }
        catch
        {
            return null;
        }
    }

    // =======================
    // SUBMIT BILL WITH REPORT GENERATION
    // =======================
    [WebMethod]
    public static object SubmitBill(string empID, decimal totalAmount, string itemsJson)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(empID))
                return new { success = false, message = "Member ID is required" };

            if (totalAmount <= 0)
                return new { success = false, message = "Invalid total amount" };

            if (string.IsNullOrEmpty(itemsJson))
                return new { success = false, message = "Cart is empty" };

            JavaScriptSerializer js = new JavaScriptSerializer();
            var items = js.Deserialize<List<Dictionary<string, object>>>(itemsJson);

            if (items == null || items.Count == 0)
                return new { success = false, message = "No items in cart" };

            string restaurantConStr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            string membershipConStr = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;

            decimal currentBalance = 0;
            string memberName = "";

            using (SqlConnection con1 = new SqlConnection(restaurantConStr))
            {
                con1.Open();
                SqlCommand cmd1 = new SqlCommand("SELECT Credit FROM MemberBalance WHERE MemberNo = @MemberNo", con1);
                cmd1.Parameters.AddWithValue("@MemberNo", empID);
                object bal = cmd1.ExecuteScalar();

                if (bal == null || bal == DBNull.Value)
                    return new { success = false, message = "Member not found" };

                currentBalance = Convert.ToDecimal(bal);

                if (currentBalance < totalAmount)
                    return new { success = false, message = "Insufficient balance" };
            }

            // Get member name for report
            using (SqlConnection con = new SqlConnection(restaurantConStr))
            {
                con.Open();
                SqlCommand cmd = new SqlCommand("SELECT RFName FROM Patient WHERE RegNo = @MemberNo", con);
                cmd.Parameters.AddWithValue("@MemberNo", empID);
                object name = cmd.ExecuteScalar();
                memberName = name != null ? name.ToString() : empID;
            }

            int billId = 0;
            using (SqlConnection con2 = new SqlConnection(restaurantConStr))
            {
                con2.Open();
                SqlCommand cmd2 = new SqlCommand(
                    "INSERT INTO SportsBills (CreatedAt, Total, MemberNo, Status) OUTPUT INSERTED.Id VALUES (GETDATE(), @Total, @MemberNo, 'Completed')",
                    con2);
                cmd2.Parameters.AddWithValue("@Total", totalAmount);
                cmd2.Parameters.AddWithValue("@MemberNo", empID);
                billId = Convert.ToInt32(cmd2.ExecuteScalar());
            }

            using (SqlConnection con3 = new SqlConnection(restaurantConStr))
            {
                con3.Open();
                foreach (var item in items)
                {
                    if (item == null) continue;

                    object idObj = item.ContainsKey("MenuItemId") ? item["MenuItemId"] :
                                  item.ContainsKey("menuItemId") ? item["menuItemId"] :
                                  item.ContainsKey("Id") ? item["Id"] :
                                  item.ContainsKey("id") ? item["id"] : null;

                    object nameObj = item.ContainsKey("Name") ? item["Name"] :
                                    item.ContainsKey("name") ? item["name"] : null;

                    object priceObj = item.ContainsKey("Price") ? item["Price"] :
                                     item.ContainsKey("price") ? item["price"] : null;

                    object qtyObj = item.ContainsKey("Quantity") ? item["Quantity"] :
                                   item.ContainsKey("quantity") ? item["quantity"] :
                                   item.ContainsKey("qty") ? item["qty"] : null;

                    object categoryObj = item.ContainsKey("Category") ? item["Category"] :
                                       item.ContainsKey("category") ? null : "Physical";

                    object startDateObj = item.ContainsKey("StartDate") ? item["StartDate"] : null;
                    object endDateObj = item.ContainsKey("EndDate") ? item["EndDate"] : null;
                    object serviceTypeObj = item.ContainsKey("ServiceType") ? item["ServiceType"] : null;

                    if (idObj == null || nameObj == null || priceObj == null || qtyObj == null)
                        continue;

                    int menuItemId = Convert.ToInt32(idObj);
                    string name = nameObj.ToString();
                    decimal price = Convert.ToDecimal(priceObj);
                    int quantity = Convert.ToInt32(qtyObj);
                    decimal lineTotal = price * quantity;
                    string category = categoryObj.ToString() ?? "Physical";
                    DateTime? startDate = null;
                    DateTime? endDate = null;

                    if (startDateObj != null && !string.IsNullOrEmpty(startDateObj.ToString()))
                        startDate = Convert.ToDateTime(startDateObj);

                    if (endDateObj != null && !string.IsNullOrEmpty(endDateObj.ToString()))
                        endDate = Convert.ToDateTime(endDateObj);

                    SqlCommand cmd3 = new SqlCommand(
                        @"INSERT INTO SportsBillItems 
                          (BillId, MenuItemId, Name, Price, Quantity, LineTotal, Category, Time, EmpId, StartDate, EndDate) 
                          VALUES 
                          (@BillId, @MenuItemId, @Name, @Price, @Quantity, @LineTotal, @Category, GETDATE(), @EmpId, @StartDate, @EndDate)",
                        con3);

                    cmd3.Parameters.AddWithValue("@BillId", billId);
                    cmd3.Parameters.AddWithValue("@MenuItemId", menuItemId);
                    cmd3.Parameters.AddWithValue("@Name", name);
                    cmd3.Parameters.AddWithValue("@Price", price);
                    cmd3.Parameters.AddWithValue("@Quantity", quantity);
                    cmd3.Parameters.AddWithValue("@LineTotal", lineTotal);
                    cmd3.Parameters.AddWithValue("@Category", category);
                    cmd3.Parameters.AddWithValue("@EmpId", empID);

                    if (startDate.HasValue)
                        cmd3.Parameters.AddWithValue("@StartDate", startDate.Value);
                    else
                        cmd3.Parameters.AddWithValue("@StartDate", DBNull.Value);

                    if (endDate.HasValue)
                        cmd3.Parameters.AddWithValue("@EndDate", endDate.Value);
                    else
                        cmd3.Parameters.AddWithValue("@EndDate", DBNull.Value);

                    cmd3.ExecuteNonQuery();
                }
            }

            using (SqlConnection con4 = new SqlConnection(membershipConStr))
            {
                con4.Open();
                SqlCommand cmd4 = new SqlCommand(
                    "UPDATE MemberPayment SET Credit = Credit - @Amount WHERE MemberNo = @MemberNo",
                    con4);
                cmd4.Parameters.AddWithValue("@MemberNo", empID);
                cmd4.Parameters.AddWithValue("@Amount", totalAmount);
                cmd4.ExecuteNonQuery();
            }

            decimal newBalance = currentBalance - totalAmount;

            // Generate report data for RDL
            GenerateReportData(billId, empID, memberName, totalAmount, items);

            return new
            {
                success = true,
                billId = billId,
                totalAmount = totalAmount,
                remaining = newBalance,
                memberName = memberName,
                message = "Bill #" + billId + " created successfully!"
            };
        }
        catch (SqlException sqlEx)
        {
            return new { success = false, message = "Database error: " + sqlEx.Message };
        }
        catch (Exception ex)
        {
            return new { success = false, message = "Error: " + ex.Message };
        }
    }

    // =======================
    // GENERATE REPORT DATA FOR RDL
    // =======================
    private static void GenerateReportData(int billId, string memberNo, string memberName, decimal totalAmount, List<Dictionary<string, object>> items)
    {
        try
        {
            string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;

            using (SqlConnection con = new SqlConnection(constr))
            {
                con.Open();

                // Create a temporary table for report data if it doesn't exist
                string createTableQuery = @"
                    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='SportsBillReport' AND xtype='U')
                    CREATE TABLE SportsBillReport (
                        ReportId INT IDENTITY(1,1) PRIMARY KEY,
                        BillId INT,
                        MemberNo NVARCHAR(50),
                        MemberName NVARCHAR(100),
                        TotalAmount DECIMAL(18,2),
                        CreatedDate DATETIME DEFAULT GETDATE(),
                        Status NVARCHAR(20) DEFAULT 'Generated'
                    )";

                SqlCommand createCmd = new SqlCommand(createTableQuery, con);
                createCmd.ExecuteNonQuery();

                // Insert report data
                string insertQuery = @"
                    INSERT INTO SportsBillReport (BillId, MemberNo, MemberName, TotalAmount)
                    VALUES (@BillId, @MemberNo, @MemberName, @TotalAmount)";

                SqlCommand insertCmd = new SqlCommand(insertQuery, con);
                insertCmd.Parameters.AddWithValue("@BillId", billId);
                insertCmd.Parameters.AddWithValue("@MemberNo", memberNo);
                insertCmd.Parameters.AddWithValue("@MemberName", memberName);
                insertCmd.Parameters.AddWithValue("@TotalAmount", totalAmount);
                insertCmd.ExecuteNonQuery();

                // Create report items table if it doesn't exist
                string createItemsTableQuery = @"
                    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='SportsBillReportItems' AND xtype='U')
                    CREATE TABLE SportsBillReportItems (
                        ItemId INT IDENTITY(1,1) PRIMARY KEY,
                        ReportId INT,
                        BillId INT,
                        ItemName NVARCHAR(100),
                        Price DECIMAL(18,2),
                        Quantity INT,
                        LineTotal DECIMAL(18,2),
                        Category NVARCHAR(50)
                    )";

                SqlCommand createItemsCmd = new SqlCommand(createItemsTableQuery, con);
                createItemsCmd.ExecuteNonQuery();

                // Insert report items
                foreach (var item in items)
                {
                    if (item == null) continue;

                    object nameObj = item.ContainsKey("Name") ? item["Name"] :
                                    item.ContainsKey("name") ? item["name"] : null;

                    object priceObj = item.ContainsKey("Price") ? item["Price"] :
                                     item.ContainsKey("price") ? item["price"] : null;

                    object qtyObj = item.ContainsKey("Quantity") ? item["Quantity"] :
                                   item.ContainsKey("quantity") ? item["quantity"] :
                                   item.ContainsKey("qty") ? item["qty"] : null;

                    object categoryObj = item.ContainsKey("Category") ? item["Category"] :
                                       item.ContainsKey("category") ? null : "Physical";

                    if (nameObj == null || priceObj == null || qtyObj == null)
                        continue;

                    string name = nameObj.ToString();
                    decimal price = Convert.ToDecimal(priceObj);
                    int quantity = Convert.ToInt32(qtyObj);
                    decimal lineTotal = price * quantity;
                    string category = categoryObj.ToString() ?? "Physical";

                    string insertItemQuery = @"
                        INSERT INTO SportsBillReportItems (ReportId, BillId, ItemName, Price, Quantity, LineTotal, Category)
                        VALUES ((SELECT TOP 1 ReportId FROM SportsBillReport WHERE BillId = @BillId), 
                                @BillId, @ItemName, @Price, @Quantity, @LineTotal, @Category)";

                    SqlCommand insertItemCmd = new SqlCommand(insertItemQuery, con);
                    insertItemCmd.Parameters.AddWithValue("@BillId", billId);
                    insertItemCmd.Parameters.AddWithValue("@ItemName", name);
                    insertItemCmd.Parameters.AddWithValue("@Price", price);
                    insertItemCmd.Parameters.AddWithValue("@Quantity", quantity);
                    insertItemCmd.Parameters.AddWithValue("@LineTotal", lineTotal);
                    insertItemCmd.Parameters.AddWithValue("@Category", category);
                    insertItemCmd.ExecuteNonQuery();
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error generating report data: " + ex.Message);
        }
    }

    // =======================
    // GET ACTIVE ORDERS
    // =======================
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<object> GetActiveOrders()
    {
        var orders = new List<object>();
        try
        {
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString))
            {
                string query = "SELECT Id AS BillId, CreatedAt, Total, MemberNo FROM SportsBills WHERE Status = 'Pending' ORDER BY CreatedAt DESC";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        orders.Add(new
                        {
                            id = dr["BillId"].ToString(),
                            date = dr["CreatedAt"] == DBNull.Value ? "" : Convert.ToDateTime(dr["CreatedAt"]).ToString("dd MMM yyyy hh:mm tt"),
                            total = "Rs. " + dr["Total"].ToString(),
                            memberNo = dr["MemberNo"] == DBNull.Value ? "Guest" : dr["MemberNo"].ToString()
                        });
                    }
                }
            }
        }
        catch
        {
            // Return empty list on error
        }
        return orders;
    }

    // =======================
    // GET ORDER DETAILS
    // =======================
    [WebMethod]
    public static List<object> GetOrderDetails(string billId)
    {
        var details = new List<object>();
        try
        {
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString))
            {
                string query = @"
                    SELECT 
                        b.BillId,
                        a.CreatedAt,
                        b.Name AS ItemName,
                        b.Price,
                        b.Quantity,
                        b.LineTotal,
                        b.Category,
                        b.StartDate,
                        b.EndDate,
                        a.Total,
                        a.MemberNo
                    FROM SportsBillItems b
                    INNER JOIN SportsBills a ON a.Id = b.BillId
                    WHERE b.BillId = @BillId
                    ORDER BY a.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@BillId", billId);
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        details.Add(new
                        {
                            id = dr["BillId"].ToString(),
                            date = dr["CreatedAt"] == DBNull.Value ? "" : Convert.ToDateTime(dr["CreatedAt"]).ToString("dd MMM yyyy hh:mm tt"),
                            item = dr["ItemName"].ToString(),
                            price = "Rs. " + dr["Price"].ToString(),
                            quantity = dr["Quantity"].ToString(),
                            lineTotal = "Rs. " + dr["LineTotal"].ToString(),
                            category = dr["Category"].ToString(),
                            startDate = dr["StartDate"] == DBNull.Value ? "" : Convert.ToDateTime(dr["StartDate"]).ToString("dd MMM yyyy"),
                            endDate = dr["EndDate"] == DBNull.Value ? "" : Convert.ToDateTime(dr["EndDate"]).ToString("dd MMM yyyy"),
                            total = "Rs. " + dr["Total"].ToString(),
                            memberNo = dr["MemberNo"] == DBNull.Value ? "Guest" : dr["MemberNo"].ToString()
                        });
                    }
                }
            }
        }
        catch
        {
            // Return empty list on error
        }
        return details;
    }
}

// Department class
public class Department
{
    public int Dept_ID { get; set; }
    public string Dept_Name { get; set; }
}