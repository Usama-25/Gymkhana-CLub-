using GymKhana.Library;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class CombinedPOS : System.Web.UI.Page
{
    string restaurantDB = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
    string membershipDB = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (!IsPostBack)
            {
                if (Session["Emp_ID"] == null)
                {
                    ShowAccessDenied("You are not logged in. Please login first.");
                    return;
                }

                string empID = Session["Emp_ID"].ToString();
                hdnEmpID.Value = empID;

                string employeeName = GetEmployeeName(empID);
                hdnEmployeeName.Value = employeeName;
                empDisplay.InnerText = employeeName;

                CheckRoles(empID);
                LoadDepartments(empID);
                LoadTodaySalesData();
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine("CombinedPOS Page_Load Error: " + ex.Message);
            ShowAccessDenied("System initialization error. Please contact administrator.");
        }
    }

    private string GetEmployeeName(string empID)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(restaurantDB))
            {
                string query = "SELECT EmployeeName FROM EmployeeRestaurantMap WHERE Emp_ID = @empID";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@empID", empID);
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    return result != null ? result.ToString() : empID;
                }
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine("GetEmployeeName error: " + ex.Message);
            return empID;
        }
    }

    private void CheckRoles(string empID)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(restaurantDB))
            {
                string q = @"SELECT Role FROM EmployeeRestaurantMap WHERE Emp_ID=@EmpID";
                using (SqlCommand cmd = new SqlCommand(q, con))
                {
                    cmd.Parameters.AddWithValue("@EmpID", empID);
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        bool isWaiter = false, isCashier = false, isManager = false;
                        while (dr.Read())
                        {
                            string role = dr["Role"] != DBNull.Value ? dr["Role"].ToString() : "";
                            if (role == "Waiter") isWaiter = true;
                            if (role == "Cashier") isCashier = true;
                            if (role == "Manager") isManager = true;
                        }
                        hdnIsWaiter.Value = isWaiter ? "True" : "False";
                        hdnIsCashier.Value = isCashier ? "True" : "False";
                        hdnIsManager.Value = isManager ? "True" : "False";
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine("CheckRoles error: " + ex.Message);
            hdnIsWaiter.Value = "True";
            hdnIsCashier.Value = "False";
            hdnIsManager.Value = "False";
        }
    }

    private void ShowAccessDenied(string message)
    {
        Response.Write("<script>alert('" + message + "'); window.location.href='http://192.168.12.40/Gymkhana';</script>");
        Response.End();
    }

    private void LoadDepartments(string empID)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(restaurantDB))
            {
                string query = @"
                SELECT DISTINCT RestaurantName, SubDeptID, Role
                FROM EmployeeRestaurantMap
                WHERE Emp_ID = @empID
                ORDER BY RestaurantName";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@empID", empID);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlDepartment.Items.Clear();
                ddlDepartment.Items.Add(new ListItem("-- Select Department --", ""));

                foreach (DataRow row in dt.Rows)
                {
                    string name = row["RestaurantName"].ToString();
                    string id = row["SubDeptID"].ToString();
                    ListItem existing = ddlDepartment.Items.FindByValue(id);
                    if (existing == null)
                        ddlDepartment.Items.Add(new ListItem(name, id));
                }

                if (dt.Rows.Count == 1)
                {
                    ddlDepartment.SelectedIndex = 1;
                    hdnSelectedDeptID.Value = dt.Rows[0]["SubDeptID"].ToString();
                    hdnSelectedDeptName.Value = dt.Rows[0]["RestaurantName"].ToString();
                }
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine("LoadDepartments error: " + ex.Message);
        }
    }

    private void LoadTodaySalesData()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(restaurantDB))
            {
                con.Open();
                string query = @"
                    SELECT
                        ISNULL(SUM(Total),0) AS TotalSales,
                        ISNULL(SUM(CASE WHEN PaymentMethod IN ('Debit Card','Credit Card','Bank Card') THEN Total ELSE 0 END),0) AS CardTotal,
                        ISNULL(SUM(CASE WHEN PaymentMethod='Member Card' THEN Total ELSE 0 END),0) AS MemberCardTotal,
                        ISNULL(SUM(CASE WHEN PaymentMethod='Cash' THEN Total ELSE 0 END),0) AS CashTotal,
                        COUNT(*) AS BillCount
                    FROM Bills
                    WHERE CONVERT(DATE, ISNULL(PaymentDate, CreatedAt)) = @Today
                      AND Status IN ('Paid','GH')";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@Today", DateTime.Today);
                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    lblTodaySales.Text = "Rs " + string.Format("{0:0.00}", dr["TotalSales"]);
                    lblTodayBills.Text = dr["BillCount"].ToString();
                }
                dr.Close();
            }
        }
        catch
        {
            lblTodaySales.Text = "Rs 0.00";
            lblTodayBills.Text = "0";
        }
    }

    protected void ddlDepartment_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(ddlDepartment.SelectedValue))
        {
            hdnSelectedDeptID.Value = ddlDepartment.SelectedValue;
            hdnSelectedDeptName.Value = ddlDepartment.SelectedItem.Text;
        }
        else
        {
            hdnSelectedDeptID.Value = "";
            hdnSelectedDeptName.Value = "";
        }
        LoadTodaySalesData();
    }

    protected void timerRefresh_Tick(object sender, EventArgs e)
    {
        LoadTodaySalesData();
    }

    // ===================== KOT NUMBER GENERATOR =====================
    private static string GenerateKotNumber(SqlConnection con, SqlTransaction trans)
    {
        string dateStr = DateTime.Now.ToString("yyMMdd");
        string prefix = "KOT-" + dateStr + "-";
        string query = @"
            SELECT ISNULL(MAX(CAST(SUBSTRING(KOT_Number, LEN(@prefix)+1, 4) AS INT)), 0)
            FROM Bills WHERE KOT_Number LIKE @prefix + '%'";
        using (SqlCommand cmd = new SqlCommand(query, con, trans))
        {
            cmd.Parameters.AddWithValue("@prefix", prefix);
            int lastSeq = Convert.ToInt32(cmd.ExecuteScalar());
            return prefix + (lastSeq + 1).ToString("D4");
        }
    }

    public static string GenerateBillNo(SqlConnection con, SqlTransaction trans, int billId, string deptCode)
    {
        try
        {
            string dateCode = DateTime.Now.ToString("yyMMdd");
            string countQuery = @"
                SELECT COUNT(*) FROM Bills
                WHERE CONVERT(DATE, CreatedAt) = CONVERT(DATE, GETDATE())
                  AND BillNo IS NOT NULL";
            SqlCommand countCmd = new SqlCommand(countQuery, con, trans);
            int todayCount = Convert.ToInt32(countCmd.ExecuteScalar()) + 1;
            string sequence = todayCount.ToString("D4");
            return dateCode + "-" + sequence;
        }
        catch
        {
            string dateCode = DateTime.Now.ToString("yyMMdd");
            return dateCode + "-" + billId.ToString("D4");
        }
    }

    private string MaskCardNumber(string cardNumber)
    {
        if (string.IsNullOrEmpty(cardNumber)) return cardNumber;
        if (cardNumber == "CASH" || cardNumber == "GH") return cardNumber;
        string clean = cardNumber.Replace("-", "");
        if (clean.Length >= 8)
            return new string('*', clean.Length - 4) + clean.Substring(clean.Length - 4);
        return cardNumber;
    }

    private static string GetEmployeeNameStatic(string empID)
    {
        try
        {
            string rDB = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(rDB))
            {
                SqlCommand cmd = new SqlCommand("SELECT EmployeeName FROM EmployeeRestaurantMap WHERE Emp_ID=@empID", con);
                cmd.Parameters.AddWithValue("@empID", empID);
                con.Open();
                object result = cmd.ExecuteScalar();
                return result != null ? result.ToString() : empID;
            }
        }
        catch { return empID; }
    }

    // ===================== WEB METHODS =====================

    [WebMethod]
    public static object GetProducts(string search, string deptID, string category = "")
    {
        try
        {
            int departmentId;
            if (!int.TryParse(deptID, out departmentId) || departmentId <= 0)
                return new { success = false, message = "Invalid department ID" };

            string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(constr))
            {
                string query = @"
                SELECT TOP 50
                    rdm.id, rdm.ItemCode,
                    rdm.ItemName AS name,
                    rdm.Price,
                    ISNULL(rdm.Category, '') AS category,
                    ISNULL(rdm.GST, 0) AS gst
                FROM MenuItems rdm
                WHERE (
                    @search = ''
                    OR rdm.ItemName LIKE '%' + @search + '%'
                    OR CAST(rdm.ItemCode AS VARCHAR(50)) LIKE '%' + @search + '%'
                )
                AND rdm.DepartmentID = @DeptID
                AND (@category = '' OR rdm.Category = @category)
                AND Active = 1
                ORDER BY rdm.ItemName";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@search", (search ?? "").Trim());
                    cmd.Parameters.AddWithValue("@DeptID", departmentId);
                    cmd.Parameters.AddWithValue("@category", (category ?? "").Trim());
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) { da.Fill(dt); }
                }
            }

            var list = new List<object>();
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new
                {
                    id = r["id"].ToString(),
                    itemCode = r["ItemCode"].ToString(),
                    name = r["name"].ToString(),
                    price = Convert.ToDecimal(r["price"]),
                    gst = r["gst"] != DBNull.Value ? Convert.ToInt32(r["gst"]) : 0,
                    image = "/resources/images/food.png",
                    category = r["category"].ToString()
                });
            }

            return new { success = true, data = list };
        }
        catch (Exception ex)
        {
            return new { success = false, message = "Error: " + ex.Message };
        }
    }
    [WebMethod]
    public static object GetMember(string search)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(search))
                return new { success = false, message = "Search term is required" };

            string constr = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;
            ScanRFID scanner = new ScanRFID(constr);
            DataTable dt = scanner.CheckRFID(search);

            if (dt == null || dt.Rows.Count == 0)
                return new { success = false, message = "Member not found" };

            DataRow rd = dt.Rows[0];

            // Parse IsActive
            bool isActive = false;
            if (rd["IsActive"] != DBNull.Value)
            {
                string activeValue = rd["IsActive"].ToString().Trim().ToLower();
                isActive = (activeValue == "1" ||
                            activeValue == "true" ||
                            activeValue == "yes" ||
                            activeValue == "y" ||
                            activeValue == "active");
            }

            // Parse IsCardActive
            bool isCardActive = false;
            if (rd["IsCardActive"] != DBNull.Value)
            {
                string cardValue = rd["IsCardActive"].ToString().Trim().ToLower();
                isCardActive = (cardValue == "1" ||
                                cardValue == "true" ||
                                cardValue == "yes" ||
                                cardValue == "y" ||
                                cardValue == "active");
            }

            string status = "";
            if (rd["Status"] != DBNull.Value)
                status = rd["Status"].ToString().Trim();

            string statusLower = status.ToLower();

            // Only allow Active or Absentee members
            if (!isActive || !isCardActive || (statusLower != "active" && statusLower != "absentee"))
            {
                string reason = "Member account is ";

                if (!isActive)
                    reason += "deactivated";
                else if (!isCardActive)
                    reason += "card deactivated";
                else
                    reason += status;

                return new
                {
                    success = false,
                    message = reason
                };
            }

            return new
            {
                success = true,
                CardNo = rd["MemberNo"] != DBNull.Value ? rd["MemberNo"].ToString() : "",
                MemberID = rd["MemberID"] != DBNull.Value ? rd["MemberID"].ToString() : "",
                DisplayName = rd["MemberName"] != DBNull.Value ? rd["MemberName"].ToString() : "",
                Name = rd["MemberName"] != DBNull.Value ? rd["MemberName"].ToString() : "",
                isActive = isActive,
                isCardActive = isCardActive,
                status = status
            };
        }
        catch (Exception ex)
        {
            return new
            {
                success = false,
                message = "Error searching member: " + ex.Message
            };
        }
    }

    [WebMethod]
    public static object GetRoomInfo(string roomNo)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(roomNo))
                return new { success = false, message = "Room number is required" };

            string constr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                string query = @"
                    SELECT gr.RoomNo, rr.ClubName, rr.GuestName, rr.GuestOf, rr.IntroductoryCardNo, rr.ReservationNo
                    FROM GR_RoomServices gr
                    INNER JOIN RoomReservations rr ON gr.ReservationNo = rr.ReservationNo
                    WHERE gr.RoomNo = @RoomNo";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@RoomNo", roomNo.Trim());
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                            return new
                            {
                                success = true,
                                RoomNo = dr["RoomNo"] != DBNull.Value ? dr["RoomNo"].ToString() : "",
                                ReservationNo = dr["ReservationNo"] != DBNull.Value ? dr["ReservationNo"].ToString() : "",
                                GuestName = dr["GuestName"] != DBNull.Value ? dr["GuestName"].ToString() : "",
                                GuestOf = dr["GuestOf"] != DBNull.Value ? dr["GuestOf"].ToString() : "",
                                ClubName = dr["ClubName"] != DBNull.Value ? dr["ClubName"].ToString() : "",
                                IntroCardNo = dr["IntroductoryCardNo"] != DBNull.Value ? dr["IntroductoryCardNo"].ToString() : ""
                            };
                        return new { success = false, message = "No occupied room found for Room No: " + roomNo };
                    }
                }
            }
        }
        catch (Exception ex)
        {
            return new { success = false, message = "Error: " + ex.Message };
        }
    }

    [WebMethod]
    public static object SearchAffiliatedMember(string search)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(search))
                return new { success = false, message = "Search term is required", data = new List<object>() };

            string constr = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;
            var list = new List<object>();

            using (SqlConnection con = new SqlConnection(constr))
            {
                string query = @"
                SELECT TOP (10)
                    ISNULL(ic.IntroductoryNo,'') AS IntroductoryNo,
                    ISNULL(ic.MemberNo,'') AS MemberNo,
                    ISNULL(ic.MemberName,'') AS MemberName,
                    ISNULL(ic.IsActive,0) AS IsActive,
                    ISNULL(ac.ClubName,'') AS ClubName
                FROM IncomingClubMembers ic
                INNER JOIN AffiliatedClubs ac ON ac.Id = ic.ClubId
                WHERE ic.IsActive = 1
                AND (
                    ic.IntroductoryNo LIKE '%' + @search + '%'
                    OR ic.MemberNo LIKE '%' + @search + '%'
                    OR ic.MemberName LIKE '%' + @search + '%'
                    OR ac.ClubName LIKE '%' + @search + '%'
                )
                ORDER BY ic.MemberName ASC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.Add("@search", SqlDbType.NVarChar, 100).Value = search.Trim();
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                            list.Add(new
                            {
                                IntroductoryNo = dr["IntroductoryNo"].ToString(),
                                MemberNo = dr["MemberNo"].ToString(),
                                MemberName = dr["MemberName"].ToString(),
                                ClubName = dr["ClubName"].ToString(),
                                IsActive = Convert.ToBoolean(dr["IsActive"])
                            });
                    }
                }
            }

            if (list.Count == 0)
                return new { success = false, message = "No affiliated member found", data = list };

            return new { success = true, message = list.Count + " member(s) found", data = list };
        }
        catch (SqlException sqlEx)
        {
            return new { success = false, message = "Database error.", error = sqlEx.Message, data = new List<object>() };
        }
        catch (Exception ex)
        {
            return new { success = false, message = "System error.", error = ex.Message, data = new List<object>() };
        }
    }

    // ===================== SUBMIT ORDER â€” AUTO DELIVER =====================
    // autoDeliver = true means skip kitchen queue, mark Delivered immediately
    [WebMethod]
    public static object SubmitOrder(string memberNo, decimal totalAmount, string itemsJson,
                                     string tableNumber, string departmentId, string departmentName,
                                     string employeeID, string waiterName,
                                     string memberType, string roomNo, int covers = 1,
                                     string affiliatedIntroNo = "", string affiliatedClubName = "",
                                     string affiliatedMemberNo = "",
                                     string reservationNo = "", string guestName = "",
                                     bool autoDeliver = false)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(memberNo))
                return new { success = false, message = "Member/Guest identifier is required" };
            if (totalAmount <= 0)
                return new { success = false, message = "Invalid total amount" };
            if (string.IsNullOrEmpty(itemsJson))
                return new { success = false, message = "Cart is empty" };

            JavaScriptSerializer js = new JavaScriptSerializer();
            var items = js.Deserialize<List<Dictionary<string, object>>>(itemsJson);
            if (items == null || items.Count == 0)
                return new { success = false, message = "No items in cart" };

            if (covers < 1) covers = 1;

            string conStr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;

            using (SqlConnection con = new SqlConnection(conStr))
            {
                con.Open();
                using (SqlTransaction trans = con.BeginTransaction())
                {
                    try
                    {
                        int orderId;
                        decimal subtotal = 0, taxTotal = 0;

                        foreach (var item in items)
                        {
                            decimal price = Convert.ToDecimal(item["Price"]);
                            int quantity = Convert.ToInt32(item["Quantity"]);
                            int gstRate = Convert.ToInt32(item["GST"]);
                            decimal itemSub = price * quantity;
                            subtotal += itemSub;
                            taxTotal += (itemSub * gstRate) / 100;
                        }

                        decimal finalAmount = subtotal + taxTotal;
                        string kotNumber = GenerateKotNumber(con, trans);
                        string tableVal = string.IsNullOrWhiteSpace(tableNumber) ? null : tableNumber.Trim();

                        // When autoDeliver: insert as Delivered with PaymentDate set
                        string initialStatus = autoDeliver ? "Delivered" : "Pending";

                        string orderQuery = @"
                        INSERT INTO Bills
                        (CreatedAt, Total, Subtotal, MemberNo, Status, TableNumber,
                         WaiterName, DepartmentID, DepartmentName, EmployeeID, bill_to, roomno,
                         TaxApplied, FinalAmount, Cover, KOT_Number,
                         AffiliatedIntroNo, AffiliatedClubName, AffiliatedMemberNo,
                         ReservationNo, GuestName, PaymentDate)
                        OUTPUT INSERTED.Id
                        VALUES
                        (GETDATE(), @Total, @Subtotal, @MemberNo, @Status, @TableNumber,
                         @WaiterName, @DepartmentID, @DepartmentName, @EmployeeID, @bill_to, @roomno,
                         @TaxApplied, @FinalAmount, @Cover, @KOT_Number,
                         @AffiliatedIntroNo, @AffiliatedClubName, @AffiliatedMemberNo,
                         @ReservationNo, @GuestName, @PaymentDate)";

                        using (SqlCommand cmd = new SqlCommand(orderQuery, con, trans))
                        {
                            cmd.Parameters.AddWithValue("@Total", finalAmount);
                            cmd.Parameters.AddWithValue("@Subtotal", subtotal);
                            cmd.Parameters.AddWithValue("@TaxApplied", taxTotal);
                            cmd.Parameters.AddWithValue("@FinalAmount", finalAmount);
                            cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                            cmd.Parameters.AddWithValue("@Status", initialStatus);
                            cmd.Parameters.AddWithValue("@TableNumber", tableVal ?? (object)DBNull.Value);
                            cmd.Parameters.AddWithValue("@WaiterName", waiterName ?? "Waiter");
                            cmd.Parameters.AddWithValue("@DepartmentID", departmentId);
                            cmd.Parameters.AddWithValue("@DepartmentName", departmentName ?? (object)DBNull.Value);
                            cmd.Parameters.AddWithValue("@EmployeeID", employeeID ?? "Unknown");
                            cmd.Parameters.AddWithValue("@bill_to", memberType ?? (object)DBNull.Value);
                            cmd.Parameters.AddWithValue("@roomno", string.IsNullOrEmpty(roomNo) ? (object)DBNull.Value : roomNo);
                            cmd.Parameters.AddWithValue("@Cover", covers);
                            cmd.Parameters.AddWithValue("@KOT_Number", kotNumber);
                            cmd.Parameters.AddWithValue("@AffiliatedIntroNo", string.IsNullOrEmpty(affiliatedIntroNo) ? (object)DBNull.Value : affiliatedIntroNo);
                            cmd.Parameters.AddWithValue("@AffiliatedClubName", string.IsNullOrEmpty(affiliatedClubName) ? (object)DBNull.Value : affiliatedClubName);
                            cmd.Parameters.AddWithValue("@AffiliatedMemberNo", string.IsNullOrEmpty(affiliatedMemberNo) ? (object)DBNull.Value : affiliatedMemberNo);
                            cmd.Parameters.AddWithValue("@ReservationNo", string.IsNullOrEmpty(reservationNo) ? (object)DBNull.Value : reservationNo);
                            cmd.Parameters.AddWithValue("@GuestName", string.IsNullOrEmpty(guestName) ? (object)DBNull.Value : guestName);
                            cmd.Parameters.AddWithValue("@PaymentDate", autoDeliver ? (object)DateTime.Now : DBNull.Value);

                            orderId = Convert.ToInt32(cmd.ExecuteScalar());
                        }

                        foreach (var item in items)
                        {
                            int menuItemId = Convert.ToInt32(item["MenuItemId"]);
                            string name = item["Name"].ToString();
                            decimal price = Convert.ToDecimal(item["Price"]);
                            int quantity = Convert.ToInt32(item["Quantity"]);
                            decimal lineTotal = price * quantity;
                            string prepStatus = autoDeliver ? "Delivered" : "Pending";

                            string itemQuery = @"
                            INSERT INTO BillItems
                            (BillId, MenuItemId, Name, Price, Quantity, LineTotal, IsPrep, Notes)
                            VALUES
                            (@BillId, @MenuItemId, @Name, @Price, @Quantity, @LineTotal, @PrepStatus, @Notes)";

                            using (SqlCommand cmd = new SqlCommand(itemQuery, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@BillId", orderId);
                                cmd.Parameters.AddWithValue("@MenuItemId", menuItemId);
                                cmd.Parameters.AddWithValue("@Name", name);
                                cmd.Parameters.AddWithValue("@Price", price);
                                cmd.Parameters.AddWithValue("@Quantity", quantity);
                                cmd.Parameters.AddWithValue("@LineTotal", lineTotal);
                                cmd.Parameters.AddWithValue("@PrepStatus", prepStatus);
                                cmd.Parameters.AddWithValue("@Notes", item.ContainsKey("Notes") ? item["Notes"].ToString() : "");
                                cmd.ExecuteNonQuery();
                            }
                        }

                        trans.Commit();

                        return new
                        {
                            success = true,
                            orderId,
                            kotNumber,
                            totalAmount = finalAmount,
                            subtotal,
                            taxAmount = taxTotal,
                            covers,
                            departmentName,
                            autoDelivered = autoDeliver,
                            message = autoDeliver ? "Order placed and auto-delivered!" : "Order placed successfully"
                        };
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        return new { success = false, message = ex.Message };
                    }
                }
            }
        }
        catch (Exception ex)
        {
            return new { success = false, message = ex.Message };
        }
    }

    // ===================== CANCEL ORDER =====================
    [WebMethod]
    public static object CancelOrder(string orderId, string employeeID, string remarks)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(orderId)) return new { success = false, message = "Order ID is required" };
            if (string.IsNullOrWhiteSpace(remarks)) return new { success = false, message = "Remarks are required for cancellation" };

            int parsedOrderId;
            if (!int.TryParse(orderId, out parsedOrderId)) return new { success = false, message = "Invalid order ID" };

            string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;

            using (SqlConnection con = new SqlConnection(constr))
            {
                con.Open();

                string billQuery = @"
                    SELECT b.Id, b.KOT_Number, b.MemberNo, b.TableNumber, b.DepartmentName,
                           b.WaiterName, b.EmployeeID, b.roomno, b.bill_to, b.Cover, b.Status, b.Subtotal
                    FROM Bills b WHERE b.Id = @OrderId";

                string kotNumber = "", memberNo = "", tableNo = "", deptName = "",
                       waiterName = "", billTo = "", cover = "";
                decimal subtotal = 0;
                string roomNoVal = null, currentStatus = "";

                using (SqlCommand cmd = new SqlCommand(billQuery, con))
                {
                    cmd.Parameters.AddWithValue("@OrderId", parsedOrderId);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (!dr.Read()) return new { success = false, message = "Order not found" };
                        currentStatus = dr["Status"] != DBNull.Value ? dr["Status"].ToString() : "";
                        kotNumber = dr["KOT_Number"] != DBNull.Value ? dr["KOT_Number"].ToString() : "";
                        memberNo = dr["MemberNo"] != DBNull.Value ? dr["MemberNo"].ToString() : "";
                        tableNo = dr["TableNumber"] != DBNull.Value ? dr["TableNumber"].ToString() : "";
                        deptName = dr["DepartmentName"] != DBNull.Value ? dr["DepartmentName"].ToString() : "";
                        waiterName = dr["WaiterName"] != DBNull.Value ? dr["WaiterName"].ToString() : "";
                        billTo = dr["bill_to"] != DBNull.Value ? dr["bill_to"].ToString() : "";
                        cover = dr["Cover"] != DBNull.Value ? dr["Cover"].ToString() : "";
                        roomNoVal = dr["roomno"] != DBNull.Value ? dr["roomno"].ToString() : null;
                        subtotal = dr["Subtotal"] != DBNull.Value ? Convert.ToDecimal(dr["Subtotal"]) : 0;
                    }
                }

                if (currentStatus == "Cancelled")
                    return new { success = false, message = "Order is already cancelled" };

                string itemsQuery = "SELECT Name, Quantity FROM BillItems WHERE BillId = @OrderId";
                var itemSummaryParts = new List<string>();
                using (SqlCommand cmd = new SqlCommand(itemsQuery, con))
                {
                    cmd.Parameters.AddWithValue("@OrderId", parsedOrderId);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                        while (dr.Read())
                            itemSummaryParts.Add(dr["Name"].ToString() + " x" + dr["Quantity"].ToString());
                }
                string itemsSummary = string.Join(", ", itemSummaryParts);

                using (SqlTransaction trans = con.BeginTransaction())
                {
                    try
                    {
                        string updateQuery = "UPDATE Bills SET Status = 'Cancelled' WHERE Id = @OrderId";
                        using (SqlCommand cmd = new SqlCommand(updateQuery, con, trans))
                        {
                            cmd.Parameters.AddWithValue("@OrderId", parsedOrderId);
                            cmd.ExecuteNonQuery();
                        }

                        string insertCancel = @"
                        INSERT INTO cancel_kot
                            (BillId, KOT_Number, MemberNo, MemberName, TableNumber, DepartmentName,
                             WaiterName, Emp_ID, ItemsSummary, Remarks, CancelledAt, RoomNo, bill_to, Cover, Subtotal)
                        VALUES
                            (@BillId, @KOT_Number, @MemberNo, @MemberName, @TableNumber, @DepartmentName,
                             @WaiterName, @Emp_ID, @ItemsSummary, @Remarks, GETDATE(), @RoomNo, @bill_to, @Cover, @Subtotal)";

                        using (SqlCommand cmd = new SqlCommand(insertCancel, con, trans))
                        {
                            cmd.Parameters.AddWithValue("@BillId", parsedOrderId);
                            cmd.Parameters.AddWithValue("@KOT_Number", kotNumber);
                            cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                            cmd.Parameters.AddWithValue("@MemberName", memberNo);
                            cmd.Parameters.AddWithValue("@TableNumber", tableNo);
                            cmd.Parameters.AddWithValue("@DepartmentName", deptName);
                            cmd.Parameters.AddWithValue("@WaiterName", waiterName);
                            cmd.Parameters.AddWithValue("@Emp_ID", employeeID ?? "");
                            cmd.Parameters.AddWithValue("@ItemsSummary", itemsSummary);
                            cmd.Parameters.AddWithValue("@Remarks", remarks.Trim());
                            cmd.Parameters.AddWithValue("@RoomNo", string.IsNullOrEmpty(roomNoVal) ? (object)DBNull.Value : roomNoVal);
                            cmd.Parameters.AddWithValue("@bill_to", billTo);
                            cmd.Parameters.AddWithValue("@Cover", cover);
                            cmd.Parameters.AddWithValue("@Subtotal", subtotal);
                            cmd.ExecuteNonQuery();
                        }

                        trans.Commit();
                        return new { success = true, message = "Order #" + parsedOrderId + " cancelled successfully" };
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        return new { success = false, message = ex.Message };
                    }
                }
            }
        }
        catch (Exception ex)
        {
            return new { success = false, message = "Error: " + ex.Message };
        }
    }

    // ===================== GET ACTIVE / DELIVERED ORDERS =====================
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<object> GetLiveBills(string deptName)
    {
        var orders = new List<object>();
        try
        {
            string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                string query = @"
                    SELECT TOP 100
                        b.Id AS OrderId, b.CreatedAt, b.Total, b.Subtotal, b.MemberNo,
                        b.Status, b.TableNumber, b.DepartmentName, b.EmployeeID, b.WaiterName,
                        b.roomno, b.TaxApplied, b.FinalAmount,
                        ISNULL(b.Cover, 1) AS Cover,
                        ISNULL(b.KOT_Number, '') AS KOT_Number,
                        b.bill_to
                    FROM Bills b
                    WHERE b.Status IN ('Pending', 'Delivered')
                    AND (@DeptName = '' OR b.DepartmentName = @DeptName)
                    ORDER BY
                        CASE b.Status WHEN 'Delivered' THEN 1 WHEN 'Pending' THEN 2 ELSE 3 END,
                        b.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@DeptName", deptName ?? "");
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        DateTime createdAt = dr["CreatedAt"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(dr["CreatedAt"]);
                        orders.Add(new
                        {
                            id = dr["OrderId"].ToString(),
                            date = createdAt.ToString("dd MMM hh:mm tt"),
                            total = Convert.ToDecimal(dr["Total"]),
                            subtotal = dr["Subtotal"] == DBNull.Value ? 0m : Convert.ToDecimal(dr["Subtotal"]),
                            memberNo = dr["MemberNo"] == DBNull.Value ? "Guest" : dr["MemberNo"].ToString(),
                            status = dr["Status"].ToString(),
                            tableNumber = dr["TableNumber"] == DBNull.Value ? "" : dr["TableNumber"].ToString(),
                            departmentName = dr["DepartmentName"] == DBNull.Value ? "" : dr["DepartmentName"].ToString(),
                            waiterName = dr["WaiterName"] == DBNull.Value ? "" : dr["WaiterName"].ToString(),
                            roomNo = dr["roomno"] == DBNull.Value ? "" : dr["roomno"].ToString(),
                            cover = dr["Cover"] == DBNull.Value ? 1 : Convert.ToInt32(dr["Cover"]),
                            kotNumber = dr["KOT_Number"].ToString(),
                            billTo = dr["bill_to"] == DBNull.Value ? "" : dr["bill_to"].ToString(),
                            createdAt
                        });
                    }
                }
            }
        }
        catch (Exception ex) { Debug.WriteLine("GetLiveBills error: " + ex.Message); }
        return orders;
    }

    // ===================== GET ORDER DETAILS =====================
    [WebMethod]
    public static object GetOrderDetails(string orderId)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString))
            {
                string orderQuery = @"
                    SELECT b.Id AS OrderId, b.CreatedAt, b.Total, b.Subtotal, b.MemberNo,
                           b.Status, b.TableNumber, b.DepartmentName, b.EmployeeID, b.WaiterName,
                           b.TaxApplied, b.FinalAmount, b.roomno,
                           ISNULL(b.Cover, 1) AS Cover, ISNULL(b.KOT_Number, '') AS KOT_Number,
                           b.bill_to, b.AffiliatedIntroNo, b.AffiliatedClubName, b.AffiliatedMemberNo,
                           ISNULL(b.ReservationNo,'') AS ReservationNo, ISNULL(b.GuestName,'') AS GuestName
                    FROM Bills b WHERE b.Id = @OrderId";

                using (SqlCommand orderCmd = new SqlCommand(orderQuery, con))
                {
                    orderCmd.Parameters.AddWithValue("@OrderId", orderId);
                    con.Open();
                    SqlDataReader orderDr = orderCmd.ExecuteReader();
                    if (orderDr.Read())
                    {
                        string memberNo = orderDr["MemberNo"] == DBNull.Value ? "Guest" : orderDr["MemberNo"].ToString();
                        DateTime createdAt = orderDr["CreatedAt"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(orderDr["CreatedAt"]);
                        decimal total = orderDr["Total"] == DBNull.Value ? 0 : Convert.ToDecimal(orderDr["Total"]);
                        decimal subtotal = orderDr["Subtotal"] == DBNull.Value ? 0 : Convert.ToDecimal(orderDr["Subtotal"]);
                        decimal taxApplied = orderDr["TaxApplied"] == DBNull.Value ? 0 : Convert.ToDecimal(orderDr["TaxApplied"]);
                        decimal finalAmount = orderDr["FinalAmount"] == DBNull.Value ? 0 : Convert.ToDecimal(orderDr["FinalAmount"]);
                        int cover = orderDr["Cover"] == DBNull.Value ? 1 : Convert.ToInt32(orderDr["Cover"]);
                        string roomNoStr = orderDr["roomno"] == DBNull.Value ? "" : orderDr["roomno"].ToString();
                        string kotNumber = orderDr["KOT_Number"].ToString();
                        string tableNumber = orderDr["TableNumber"] == DBNull.Value ? "" : orderDr["TableNumber"].ToString();
                        string departmentName = orderDr["DepartmentName"] == DBNull.Value ? "" : orderDr["DepartmentName"].ToString();
                        string waiterName = orderDr["WaiterName"] == DBNull.Value ? "" : orderDr["WaiterName"].ToString();
                        string status = orderDr["Status"] == DBNull.Value ? "Pending" : orderDr["Status"].ToString();
                        string billTo = orderDr["bill_to"] == DBNull.Value ? "" : orderDr["bill_to"].ToString();
                        string reservationNo = orderDr["ReservationNo"].ToString();
                        string guestName = orderDr["GuestName"].ToString();
                        orderDr.Close();

                        string itemsQuery = @"
                            SELECT bi.Id AS BillItemId, bi.Name AS ItemName, bi.Price,
                                   bi.Quantity, bi.LineTotal, bi.IsPrep AS PrepStatus, bi.Notes
                            FROM BillItems bi WHERE bi.BillId = @OrderId ORDER BY bi.Id";

                        var itemsList = new List<object>();
                        using (SqlCommand itemsCmd = new SqlCommand(itemsQuery, con))
                        {
                            itemsCmd.Parameters.AddWithValue("@OrderId", orderId);
                            SqlDataReader itemsDr = itemsCmd.ExecuteReader();
                            while (itemsDr.Read())
                            {
                                itemsList.Add(new
                                {
                                    BillItemId = Convert.ToInt32(itemsDr["BillItemId"]),
                                    ItemName = itemsDr["ItemName"].ToString(),
                                    Price = Convert.ToDecimal(itemsDr["Price"]),
                                    Quantity = Convert.ToInt32(itemsDr["Quantity"]),
                                    LineTotal = Convert.ToDecimal(itemsDr["LineTotal"]),
                                    PrepStatus = itemsDr["PrepStatus"] == DBNull.Value ? "Pending" : itemsDr["PrepStatus"].ToString(),
                                    Notes = itemsDr["Notes"] == DBNull.Value ? "" : itemsDr["Notes"].ToString()
                                });
                            }
                            itemsDr.Close();

                            return new
                            {
                                success = true,
                                id = orderId,
                                date = createdAt.ToString("dd MMM yyyy hh:mm tt"),
                                total,
                                subtotal,
                                taxApplied,
                                finalAmount,
                                memberNo,
                                status,
                                tableNumber,
                                departmentName,
                                waiterName,
                                roomNo = roomNoStr,
                                cover,
                                kotNumber,
                                billTo,
                                reservationNo,
                                guestName,
                                items = itemsList
                            };
                        }
                    }
                    else { orderDr.Close(); return new { success = false, message = "Order not found" }; }
                }
            }
        }
        catch (Exception ex)
        {
            return new { success = false, message = "Error: " + ex.Message };
        }
    }

    // ===================== PROCESS PAYMENT (CASHIER) =====================
    [WebMethod]
    public static object ProcessConsolidatedPayment(
        string memberNo, string departmentId, int[] billIds,
        string paymentMethod, string paymentType,
        string cardNumber, string cardExpiry, string approvalCode, string cardHolderName,
        decimal totalAmount, decimal discountAmount,
        int offerId, string signatureData,
        int numberOfCovers, string deptCode,
        bool ghPayment, string effectiveStatus)
    {
        try
        {
            string mDB = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;
            string rDB = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            string gDB = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

            string empID = "0";
            if (HttpContext.Current.Session["Emp_ID"] != null)
                empID = HttpContext.Current.Session["Emp_ID"].ToString();
            string empName = GetEmployeeNameStatic(empID);

            string finalStatus = ghPayment ? "GH" : "Paid";
            string ledgerError = "";

            using (SqlConnection conR = new SqlConnection(rDB))
            using (SqlConnection conM = new SqlConnection(mDB))
            {
                conR.Open(); conM.Open();
                SqlTransaction trans = conR.BeginTransaction();

                try
                {
                    decimal billTotal = totalAmount;
                    decimal finalAmount = billTotal - discountAmount;
                    decimal taxAmt = 0, subtotal = 0;

                    if (billIds != null && billIds.Length > 0)
                    {
                        string idList = string.Join(",", billIds);
                        SqlCommand taxCmd = new SqlCommand(
                            "SELECT ISNULL(SUM(TaxApplied),0) AS TotalTax, ISNULL(SUM(Subtotal),0) AS TotalSubtotal FROM Bills WHERE Id IN (" + idList + ")", conR, trans);
                        using (SqlDataReader taxRdr = taxCmd.ExecuteReader())
                            if (taxRdr.Read()) { taxAmt = Convert.ToDecimal(taxRdr["TotalTax"]); subtotal = Convert.ToDecimal(taxRdr["TotalSubtotal"]); }
                    }

                    decimal? updatedBalance = null;
                    string roomNo = "", kotNos = "";
                    int subDeptId = 0;
                    string reservationNo = "";

                    if (billIds != null && billIds.Length > 0)
                    {
                        string idList2 = string.Join(",", billIds);
                        SqlCommand roomCmd = new SqlCommand(@"
                            SELECT TOP 1
                                RIGHT('000' + CAST(ISNULL(roomno, 0) AS NVARCHAR(10)), 3) AS RoomNo,
                                ISNULL(DepartmentID, 0) AS DeptID,
                                ISNULL(KOT_Number, '') AS KotNo,
                                ISNULL(ReservationNo, '') AS ReservationNo
                            FROM Bills WHERE Id IN (" + idList2 + ")", conR, trans);
                        using (SqlDataReader roomRdr = roomCmd.ExecuteReader())
                            if (roomRdr.Read())
                            {
                                roomNo = roomRdr["RoomNo"].ToString().Trim();
                                subDeptId = Convert.ToInt32(roomRdr["DeptID"]);
                                kotNos = roomRdr["KotNo"].ToString();
                                reservationNo = roomRdr["ReservationNo"].ToString().Trim();
                            }
                    }

                    if (paymentType == "MemberCard")
                    {
                        DataTable billDetailsMC = new DataTable();
                        using (SqlDataAdapter adMC = new SqlDataAdapter(
                            new SqlCommand("SELECT Id, BillNo, Total FROM Bills WHERE Id IN (" + string.Join(",", billIds) + ")", conR, trans)))
                            adMC.Fill(billDetailsMC);

                        string insertPaymentQuery = @"
                            DECLARE @MemberPaymentId INT;
                            INSERT INTO MemberPayment (MemberNo, Date, Description, Dept, Credit)
                            VALUES (@MemberNo, GETDATE(), @Description, @Amount, 0);
                            SET @MemberPaymentId = SCOPE_IDENTITY();";

                        foreach (DataRow bill in billDetailsMC.Rows)
                        {
                            int bid2 = Convert.ToInt32(bill["Id"]);
                            string billNo2 = bill["BillNo"].ToString().Replace("'", "''");
                            decimal billAmt = Convert.ToDecimal(bill["Total"]);
                            decimal billDisc = 0, discBill = billAmt;
                            if (discountAmount > 0 && totalAmount > 0) { billDisc = discountAmount * (billAmt / totalAmount); discBill = billAmt - billDisc; }

                            insertPaymentQuery += @"
                            INSERT INTO MemberPaymentDetails
                                (MemberPaymentId, MemberNo, BillId, BillNo, Amount, DiscountAmount, FinalAmount, PaymentDate, DepartmentId, PaymentMethod, CardNumber, ApprovalCode)
                            VALUES (@MemberPaymentId, @MemberNo, " + bid2 + ", '" + billNo2 + "', "
                                + billAmt.ToString(System.Globalization.CultureInfo.InvariantCulture) + ", "
                                + billDisc.ToString(System.Globalization.CultureInfo.InvariantCulture) + ", "
                                + discBill.ToString(System.Globalization.CultureInfo.InvariantCulture) + @",
                                 GETDATE(), @DepartmentId, @PaymentMethod, @CardNumber, @ApprovalCode);";
                        }

                        insertPaymentQuery += @"
                            SELECT (ISNULL(SUM(mp.Dept),0) - ISNULL(SUM(mp.Credit),0)) AS Balance
                            FROM MemberProfile mc LEFT JOIN MemberPayment mp ON mp.MemberNo = mc.MemberNo
                            WHERE mc.MemberNo = @MemberNo GROUP BY mc.MemberNo";

                        SqlCommand insertCmd = new SqlCommand(insertPaymentQuery, conM);
                        insertCmd.Parameters.AddWithValue("@MemberNo", memberNo);
                        insertCmd.Parameters.AddWithValue("@Amount", finalAmount);
                        insertCmd.Parameters.AddWithValue("@Description", "Restaurant payment for Bills #" + string.Join(", #", billIds));
                        insertCmd.Parameters.AddWithValue("@DepartmentId", departmentId);
                        insertCmd.Parameters.AddWithValue("@PaymentMethod", paymentMethod);
                        insertCmd.Parameters.AddWithValue("@CardNumber", cardNumber);
                        insertCmd.Parameters.AddWithValue("@ApprovalCode", (object)approvalCode ?? DBNull.Value);

                        using (SqlDataReader balRdr = insertCmd.ExecuteReader())
                            if (balRdr.Read()) updatedBalance = Convert.ToDecimal(balRdr["Balance"]);
                    }
                    else if (paymentType == "BankCard")
                    {
                        DataTable billDetailsBK = new DataTable();
                        using (SqlDataAdapter adBK = new SqlDataAdapter(
                            new SqlCommand("SELECT Id, BillNo, Total FROM Bills WHERE Id IN (" + string.Join(",", billIds) + ")", conR, trans)))
                            adBK.Fill(billDetailsBK);

                        string insertBKQuery = @"
                            DECLARE @MPDept INT; DECLARE @MPCredit INT;
                            INSERT INTO MemberPayment (MemberNo, Date, Description, Dept, Credit)
                            VALUES (@MemberNo, GETDATE(), @DescriptionDept, @Amount, 0);
                            SET @MPDept = SCOPE_IDENTITY();
                            INSERT INTO MemberPayment (MemberNo, Date, Description, Dept, Credit)
                            VALUES (@MemberNo, GETDATE(), @DescriptionCredit, 0, @Amount);
                            SET @MPCredit = SCOPE_IDENTITY();";

                        foreach (DataRow bill in billDetailsBK.Rows)
                        {
                            int bid2 = Convert.ToInt32(bill["Id"]);
                            string billNoBK = bill["BillNo"].ToString().Replace("'", "''");
                            decimal billAmt = Convert.ToDecimal(bill["Total"]);
                            decimal billDisc = 0, discBill = billAmt;
                            if (discountAmount > 0 && totalAmount > 0) { billDisc = discountAmount * (billAmt / totalAmount); discBill = billAmt - billDisc; }

                            insertBKQuery += @"
                            INSERT INTO MemberPaymentDetails
                                (MemberPaymentId, MemberNo, BillId, BillNo, Amount, DiscountAmount, FinalAmount, PaymentDate, DepartmentId, PaymentMethod, CardNumber, ApprovalCode)
                            VALUES (@MPDept, @MemberNo, " + bid2 + ", '" + billNoBK + "', "
                                + billAmt.ToString(System.Globalization.CultureInfo.InvariantCulture) + ", "
                                + billDisc.ToString(System.Globalization.CultureInfo.InvariantCulture) + ", "
                                + discBill.ToString(System.Globalization.CultureInfo.InvariantCulture) + @",
                                 GETDATE(), @DepartmentId, @PaymentMethod, @CardNumber, @ApprovalCode);";
                        }

                        SqlCommand insertBKCmd = new SqlCommand(insertBKQuery, conM);
                        insertBKCmd.Parameters.AddWithValue("@MemberNo", memberNo);
                        insertBKCmd.Parameters.AddWithValue("@Amount", finalAmount);
                        insertBKCmd.Parameters.AddWithValue("@DescriptionDept", "Bank Card charge for Bills #" + string.Join(", #", billIds));
                        insertBKCmd.Parameters.AddWithValue("@DescriptionCredit", "Bank Card settlement for Bills #" + string.Join(", #", billIds));
                        insertBKCmd.Parameters.AddWithValue("@DepartmentId", departmentId);
                        insertBKCmd.Parameters.AddWithValue("@PaymentMethod", paymentMethod);
                        insertBKCmd.Parameters.AddWithValue("@CardNumber", cardNumber);
                        insertBKCmd.Parameters.AddWithValue("@ApprovalCode", (object)approvalCode ?? DBNull.Value);
                        insertBKCmd.ExecuteNonQuery();

                        if (ghPayment)
                            ledgerError = InsertGuestLedgerSafe(gDB, roomNo, reservationNo,
                                "Bank Card payment (GH) for KOT: " + kotNos, 0m, 0m, subDeptId, string.Join(",", billIds), empName);
                    }
                    else if (paymentType == "GH")
                    {
                        ledgerError = InsertGuestLedgerSafe(gDB, roomNo, reservationNo,
                            "GH Restaurant charge for KOT: " + kotNos + " | Bills #" + string.Join(", #", billIds),
                            finalAmount, finalAmount, subDeptId, string.Join(",", billIds), empName);
                    }

                    string maskedCard = new CombinedPOS().MaskCardNumber(cardNumber);
                    string generatedBillNo = "";

                    foreach (int bid in billIds)
                    {
                        string billNo = GenerateBillNo(conR, trans, bid, deptCode);
                        if (string.IsNullOrEmpty(generatedBillNo)) generatedBillNo = billNo;

                        SqlCommand ub = new SqlCommand(@"
                            UPDATE Bills SET
                                Status=@ST, PaymentMethod=@PM, PaymentDate=GETDATE(),
                                AmountPaid=@AP, CardNumber=@CN, CardExpiry=@CE,
                                CardHolderName=@CHN, DiscountApplied=@DA, FinalAmount=@FA,
                                OfferId=@OI, ApprovalCode=@AC, BillNo=@BN, CashierName=@CSH
                            WHERE Id=@BillId AND Status IN ('Pending','Delivered')", conR, trans);
                        ub.Parameters.AddWithValue("@BillId", bid);
                        ub.Parameters.AddWithValue("@ST", finalStatus);
                        ub.Parameters.AddWithValue("@PM", paymentMethod);
                        ub.Parameters.AddWithValue("@AP", billTotal);
                        ub.Parameters.AddWithValue("@CN", maskedCard);
                        ub.Parameters.AddWithValue("@CE", (object)cardExpiry ?? DBNull.Value);
                        ub.Parameters.AddWithValue("@CHN", (object)cardHolderName ?? DBNull.Value);
                        ub.Parameters.AddWithValue("@DA", discountAmount);
                        ub.Parameters.AddWithValue("@FA", finalAmount);
                        ub.Parameters.AddWithValue("@OI", offerId > 0 ? (object)offerId : DBNull.Value);
                        ub.Parameters.AddWithValue("@AC", (object)approvalCode ?? DBNull.Value);
                        ub.Parameters.AddWithValue("@BN", billNo);
                        ub.Parameters.AddWithValue("@CSH", empName);
                        ub.ExecuteNonQuery();
                    }

                    if (offerId > 0 && discountAmount > 0)
                    {
                        string cleanNum = cardNumber.Replace("-", "");
                        string cardPrefix = cleanNum.Length >= 4 ? cleanNum.Substring(0, 4) : cleanNum;
                        SqlCommand ou = new SqlCommand(@"
                            MERGE offer_daily_usage WITH(HOLDLOCK) AS t
                            USING (VALUES(@OI,@CP,@CN,CAST(GETDATE() AS DATE))) AS s(offer_id,card_prefix,card_number,usage_date)
                            ON t.offer_id=s.offer_id AND t.card_number=s.card_number AND t.usage_date=s.usage_date
                            WHEN MATCHED THEN UPDATE SET usage_count=t.usage_count+1,last_updated=GETDATE()
                            WHEN NOT MATCHED THEN INSERT (offer_id,card_prefix,card_number,usage_date,usage_count,last_updated)
                                VALUES(s.offer_id,s.card_prefix,s.card_number,s.usage_date,1,GETDATE());", conR, trans);
                        ou.Parameters.AddWithValue("@OI", offerId);
                        ou.Parameters.AddWithValue("@CP", cardPrefix);
                        ou.Parameters.AddWithValue("@CN", cleanNum);
                        ou.ExecuteNonQuery();
                    }

                    foreach (int bid in billIds)
                    {
                        SqlCommand lc = new SqlCommand(@"
                            INSERT INTO CasierLog (BillId,Action_Type,Emp_ID,Emp_Name,KOT_Number,Payment_Method,Amount,Status,Remarks,CreatedAt)
                            SELECT @BillId,'ConsolidatedPayment',@EID,@EN,KOT_Number,@PM,Total,@ST,@REM,GETDATE()
                            FROM Bills WHERE Id=@BillId", conR, trans);
                        lc.Parameters.AddWithValue("@BillId", bid);
                        lc.Parameters.AddWithValue("@EID", empID);
                        lc.Parameters.AddWithValue("@EN", empName);
                        lc.Parameters.AddWithValue("@PM", paymentMethod);
                        lc.Parameters.AddWithValue("@ST", finalStatus);
                        lc.Parameters.AddWithValue("@REM", "CombinedPOS â€” Member:" + memberNo + (ghPayment ? " | GH" : "") + (discountAmount > 0 ? " | Disc:Rs " + discountAmount : ""));
                        lc.ExecuteNonQuery();
                    }

                    trans.Commit();

                    string successMsg = "Payment processed for " + billIds.Length + " bill(s)." + (ghPayment ? " (GH)" : "");
                    if (!string.IsNullOrEmpty(ledgerError)) successMsg += "\nâš ï¸ GR Ledger warning: " + ledgerError;

                    return new
                    {
                        success = true,
                        message = successMsg,
                        memberNo,
                        totalAmount = billTotal,
                        discountAmount,
                        finalAmount,
                        approvalCode,
                        maskedCardNumber = maskedCard,
                        updatedBalance,
                        billCount = billIds.Length,
                        generatedBillNo,
                        cashierName = empName,
                        numberOfCovers,
                        ghPayment,
                        ledgerError
                    };
                }
                catch (Exception ex)
                {
                    trans.Rollback();
                    return new { success = false, message = "Error: " + ex.Message };
                }
            }
        }
        catch (Exception ex)
        {
            return new { success = false, message = "Error: " + ex.Message };
        }
    }

    private static string InsertGuestLedgerSafe(string guestRoomConnStr, string roomNo, string reservationNo,
        string description, decimal debit, decimal credit, int subDeptId, string refNo, string createdBy)
    {
        try
        {
            using (SqlConnection conGR = new SqlConnection(guestRoomConnStr))
            {
                conGR.Open();
                SqlCommand grCmd = new SqlCommand(@"
                    INSERT INTO GR_GuestLedger
                        (TransDate, ReservationNo, RoomNo, RefNo, Description, Debit, Credit, EntryDate, CreatedBy, SubDeptID)
                    VALUES (GETDATE(), @ReservationNo, @RoomNo, @RefNo, @Description, @Debit, @Credit, GETDATE(), @CreatedBy, @SubDeptID)", conGR);
                grCmd.Parameters.AddWithValue("@ReservationNo", string.IsNullOrEmpty(reservationNo) ? (object)DBNull.Value : reservationNo);
                grCmd.Parameters.AddWithValue("@RoomNo", string.IsNullOrEmpty(roomNo) ? (object)DBNull.Value : roomNo);
                grCmd.Parameters.AddWithValue("@RefNo", string.IsNullOrEmpty(refNo) ? (object)DBNull.Value : refNo);
                grCmd.Parameters.AddWithValue("@Description", string.IsNullOrEmpty(description) ? (object)DBNull.Value : description);
                grCmd.Parameters.AddWithValue("@Debit", debit);
                grCmd.Parameters.AddWithValue("@Credit", credit);
                grCmd.Parameters.AddWithValue("@CreatedBy", string.IsNullOrEmpty(createdBy) ? (object)DBNull.Value : createdBy);
                grCmd.Parameters.AddWithValue("@SubDeptID", subDeptId > 0 ? (object)subDeptId : DBNull.Value);
                grCmd.ExecuteNonQuery();
                return "";
            }
        }
        catch (Exception ex) { return ex.Message; }
    }

    [WebMethod]
    public static object ValidateMemberCard(string cardNumber)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(cardNumber))
                return new { success = false, message = "Card number is required." };

            string mDB = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;
            ScanRFID scanner = new ScanRFID(mDB);
            DataTable dt = scanner.CheckRFID(cardNumber);

            if (dt == null || dt.Rows.Count == 0)
                return new { success = false, message = "Member not found." };

            DataRow rd = dt.Rows[0];

            // SAFE BOOLEAN HANDLING (prevents String was not recognized as a valid Boolean)
            string activeValue = "";
            string cardValue = "";
            string status = "";

            if (rd.Table.Columns.Contains("IsActive") && rd["IsActive"] != DBNull.Value)
                activeValue = Convert.ToString(rd["IsActive"]).Trim().ToLower();

            if (rd.Table.Columns.Contains("IsCardActive") && rd["IsCardActive"] != DBNull.Value)
                cardValue = Convert.ToString(rd["IsCardActive"]).Trim().ToLower();

            if (rd.Table.Columns.Contains("Status") && rd["Status"] != DBNull.Value)
                status = Convert.ToString(rd["Status"]).Trim();

            bool isActive = (activeValue == "1" || activeValue == "true" || activeValue == "yes" || activeValue == "y");
            bool isCardActive = (cardValue == "1" || cardValue == "true" || cardValue == "yes" || cardValue == "y");

            string statusLower = status.ToLower();

            // Member validation
            if (!isActive || !isCardActive || (statusLower != "active" && statusLower != "absentee"))
            {
                string reason = "";

                if (!isActive)
                    reason = "deactivated";
                else if (!isCardActive)
                    reason = "card deactivated";
                else
                    reason = "status: " + status;

                return new
                {
                    success = false,
                    message = "Member account is " + reason + "."
                };
            }

            string memberNo = "";
            if (rd.Table.Columns.Contains("MemberNo") && rd["MemberNo"] != DBNull.Value)
                memberNo = Convert.ToString(rd["MemberNo"]);

            decimal balance = 0m;
            decimal totalDept = 0m;
            decimal totalCredit = 0m;

            using (SqlConnection conM = new SqlConnection(mDB))
            {
                conM.Open();

                SqlCommand balCmd = new SqlCommand(@"
                SELECT 
                    (ISNULL(SUM(mp.Dept),0) - ISNULL(SUM(mp.Credit),0)) AS Balance,
                    ISNULL(SUM(mp.Dept),0) AS TotalDept,
                    ISNULL(SUM(mp.Credit),0) AS TotalCredit
                FROM MemberProfile mc
                LEFT JOIN MemberPayment mp ON mp.MemberNo = mc.MemberNo
                WHERE mc.MemberNo = @MemberNo
                GROUP BY mc.MemberNo", conM);

                balCmd.Parameters.AddWithValue("@MemberNo", memberNo);

                SqlDataReader balRdr = balCmd.ExecuteReader();

                if (balRdr.Read())
                {
                    if (balRdr["Balance"] != DBNull.Value)
                        balance = Convert.ToDecimal(balRdr["Balance"]);

                    if (balRdr["TotalDept"] != DBNull.Value)
                        totalDept = Convert.ToDecimal(balRdr["TotalDept"]);

                    if (balRdr["TotalCredit"] != DBNull.Value)
                        totalCredit = Convert.ToDecimal(balRdr["TotalCredit"]);
                }

                balRdr.Close();
            }

            return new
            {
                success = true,
                CardNo = rd.Table.Columns.Contains("RFID") && rd["RFID"] != DBNull.Value
                    ? Convert.ToString(rd["RFID"])
                    : cardNumber,

                Memberid = memberNo,
                MemberNo = memberNo,

                Name = rd.Table.Columns.Contains("MemberName") && rd["MemberName"] != DBNull.Value
                    ? Convert.ToString(rd["MemberName"])
                    : "Unknown",

                balance = balance,
                totalDept = totalDept,
                totalCredit = totalCredit,

                // Return as string for maximum VS2013 / JSON safety
                isActive = isActive ? "true" : "false",
                isCardActive = isCardActive ? "true" : "false",

                status = status
            };
        }
        catch (Exception ex)
        {
            return new
            {
                success = false,
                message = "Error: " + ex.Message
            };
        }
    }

    [WebMethod]
    public static object CheckCardDiscount(string cardNumber, decimal billAmount)
    {
        try
        {
            string rDB = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            string cleanNumber = cardNumber.Replace("-", "");
            string cardPrefix = cleanNumber.Length >= 4 ? cleanNumber.Substring(0, 4) : cleanNumber;
            int weekday = (int)DateTime.Now.DayOfWeek;
            if (weekday == 0) weekday = 7;

            using (SqlConnection con = new SqlConnection(rDB))
            {
                con.Open();
                string oq = @"
                    SELECT TOP 1 offer_id, offer_name, discount_percent, max_discount_amount, min_bill_amount, valid_weekday,
                           ISNULL(per_day_transaction_limit, 0) AS per_day_transaction_limit
                    FROM card_prefix_offers
                    WHERE card_prefix=@CP AND is_active=1
                      AND (valid_weekday=@WD OR valid_weekday=0)
                      AND (valid_from IS NULL OR valid_from <= GETDATE())
                      AND (valid_to IS NULL OR valid_to >= GETDATE())
                      AND (min_bill_amount IS NULL OR min_bill_amount <= @BA)
                    ORDER BY discount_percent DESC";
                SqlCommand oc = new SqlCommand(oq, con);
                oc.Parameters.AddWithValue("@CP", cardPrefix);
                oc.Parameters.AddWithValue("@WD", weekday);
                oc.Parameters.AddWithValue("@BA", billAmount);
                SqlDataReader rdr = oc.ExecuteReader();
                if (!rdr.Read()) { rdr.Close(); return new { success = false, discount_amount = 0, message = "No discount available." }; }

                int offerId = Convert.ToInt32(rdr["offer_id"]);
                string offerName = rdr["offer_name"].ToString();
                decimal discPct = Convert.ToDecimal(rdr["discount_percent"]);
                int perDayLimit = Convert.ToInt32(rdr["per_day_transaction_limit"]);
                object maxDiscObj = rdr["max_discount_amount"];
                rdr.Close();

                decimal discAmt = (billAmount * discPct) / 100m;
                if (maxDiscObj != DBNull.Value) { decimal mx = Convert.ToDecimal(maxDiscObj); if (discAmt > mx) discAmt = mx; }

                if (perDayLimit > 0)
                {
                    SqlCommand uc = new SqlCommand(@"SELECT ISNULL(usage_count,0) FROM offer_daily_usage WHERE offer_id=@OI AND card_number=@CN AND usage_date=CAST(GETDATE() AS DATE)", con);
                    uc.Parameters.AddWithValue("@OI", offerId);
                    uc.Parameters.AddWithValue("@CN", cleanNumber);
                    int usedToday = 0;
                    try { object ur = uc.ExecuteScalar(); if (ur != null && ur != DBNull.Value) usedToday = Convert.ToInt32(ur); } catch { }
                    if (usedToday >= perDayLimit)
                        return new { success = false, discount_amount = 0, limit_exceeded = true, used_today = usedToday, per_day_limit = perDayLimit, offer_id = offerId, offer_name = offerName, message = "Daily limit reached." };

                    return new { success = true, offer_id = offerId, offer_name = offerName, discount_percent = discPct, discount_amount = discAmt, per_day_limit = perDayLimit, used_today = usedToday, remaining_today = perDayLimit - usedToday, message = discPct + "% applied." };
                }

                return new { success = true, offer_id = offerId, offer_name = offerName, discount_percent = discPct, discount_amount = discAmt, per_day_limit = 0, used_today = 0, remaining_today = -1, message = discPct + "% applied." };
            }
        }
        catch (Exception ex)
        {
            return new { success = false, discount_amount = 0, message = "Error: " + ex.Message };
        }
    }

    [WebMethod]
    public static object GetMemberAllKOTs(string memberNo, string departmentId)
    {
        try
        {
            string rDB = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(rDB))
            {
                con.Open();
                string billsQuery = @"
                    SELECT b.Id AS BillId, b.Total, b.MemberNo, b.Status, b.KOT_Number,
                           b.TableNumber, b.DepartmentName, b.DepartmentID, b.bill_to, b.CreatedAt,
                           ISNULL(b.BillNo,'') AS BillNo, ISNULL(TRY_CAST(b.Cover AS INT),1) AS NumberOfCovers,
                           ISNULL(b.TaxApplied,0) AS TaxApplied, ISNULL(b.DiscountApplied,0) AS DiscountApplied,
                           ISNULL(b.Subtotal,0) AS Subtotal,
                           CASE WHEN b.bill_to='Guest House' THEN b.roomno ELSE NULL END AS RoomNo,
                           FORMAT(b.CreatedAt,'hh:mm tt') AS OrderTime
                    FROM Bills b
                    WHERE b.MemberNo=@MemberNo
                      AND (b.DepartmentID=@DepartmentId OR b.DepartmentName=@DepartmentId)
                      AND b.Status IN ('Pending','Delivered')
                    ORDER BY b.CreatedAt ASC, b.Id ASC";

                SqlCommand billsCmd = new SqlCommand(billsQuery, con);
                billsCmd.Parameters.AddWithValue("@MemberNo", memberNo);
                billsCmd.Parameters.AddWithValue("@DepartmentId", departmentId);
                SqlDataReader billsRdr = billsCmd.ExecuteReader();

                List<object> bills = new List<object>();
                List<int> billIds = new List<int>();
                decimal grandTotal = 0;

                while (billsRdr.Read())
                {
                    int billId = Convert.ToInt32(billsRdr["BillId"]);
                    decimal total = Convert.ToDecimal(billsRdr["Total"]);
                    decimal taxApplied = Convert.ToDecimal(billsRdr["TaxApplied"]);
                    decimal discountApplied = Convert.ToDecimal(billsRdr["DiscountApplied"]);
                    decimal sbtotal = Convert.ToDecimal(billsRdr["Subtotal"]);
                    string kotNo = billsRdr["KOT_Number"] != DBNull.Value ? billsRdr["KOT_Number"].ToString() : "";
                    string status2 = billsRdr["Status"].ToString();
                    string billTo = billsRdr["bill_to"] != DBNull.Value ? billsRdr["bill_to"].ToString() : "";
                    string tableNo = billsRdr["TableNumber"] != DBNull.Value ? billsRdr["TableNumber"].ToString() : "";
                    string rNo = billsRdr["RoomNo"] != DBNull.Value ? billsRdr["RoomNo"].ToString() : "";
                    string createdAt2 = billsRdr["CreatedAt"] != DBNull.Value ? Convert.ToDateTime(billsRdr["CreatedAt"]).ToString("dd/MM/yy hh:mm tt") : "";
                    string orderTime = billsRdr["OrderTime"] != DBNull.Value ? billsRdr["OrderTime"].ToString() : "";
                    string bNo = billsRdr["BillNo"].ToString();
                    int covers2 = Convert.ToInt32(billsRdr["NumberOfCovers"]);
                    bills.Add(new { billId, total, taxApplied, discountApplied, subtotal = sbtotal, kotNo, status = status2, billTo, tableNo, roomNo = rNo, createdAt = createdAt2, orderTime, billNo = bNo, covers = covers2 });
                    billIds.Add(billId);
                    grandTotal += total;
                }
                billsRdr.Close();

                if (bills.Count == 0)
                    return new { success = false, message = "No active bills for this member." };

                List<object> items = new List<object>();
                if (billIds.Count > 0)
                {
                    string idList = string.Join(",", billIds);
                    string itemsQuery = @"
                        SELECT bs.Id AS ItemId, bs.BillId, bs.Name, bs.Quantity, bs.Price,
                               (bs.Price * bs.Quantity) AS ItemTotal, b.KOT_Number, b.TableNumber,
                               b.Status AS BillStatus, ISNULL(b.BillNo,'') AS BillNo,
                               ISNULL(rc.ItemCode,'') AS ItemCode
                        FROM BillItems bs
                        INNER JOIN Bills b ON b.Id = bs.BillId
                        LEFT JOIN Restaurant_Catalog rc ON rc.ItemName = bs.Name
                        WHERE bs.BillId IN (" + idList + ") ORDER BY b.CreatedAt ASC, bs.Id ASC";
                    SqlCommand itemsCmd = new SqlCommand(itemsQuery, con);
                    SqlDataReader itemsRdr = itemsCmd.ExecuteReader();
                    while (itemsRdr.Read())
                        items.Add(new
                        {
                            ItemId = Convert.ToInt32(itemsRdr["ItemId"]),
                            BillId = Convert.ToInt32(itemsRdr["BillId"]),
                            Name = itemsRdr["Name"].ToString(),
                            ItemCode = itemsRdr["ItemCode"].ToString(),
                            Quantity = Convert.ToDecimal(itemsRdr["Quantity"]),
                            Price = Convert.ToDecimal(itemsRdr["Price"]),
                            ItemTotal = Convert.ToDecimal(itemsRdr["ItemTotal"]),
                            KOT_Number = itemsRdr["KOT_Number"] != DBNull.Value ? itemsRdr["KOT_Number"].ToString() : "",
                            TableNumber = itemsRdr["TableNumber"] != DBNull.Value ? itemsRdr["TableNumber"].ToString() : "",
                            BillStatus = itemsRdr["BillStatus"].ToString(),
                            BillNo = itemsRdr["BillNo"].ToString()
                        });
                    itemsRdr.Close();
                }

                return new { success = true, bills, items, grandTotal, memberNo, billCount = bills.Count, billIds = billIds.ToArray(), message = bills.Count + " KOT(s) found" };
            }
        }
        catch (Exception ex)
        {
            return new { success = false, message = "Error: " + ex.Message };
        }
    }

    protected void btnGoCounterClose_Click(object sender, EventArgs e)
    {
        string empId = hdnEmpID.Value;
        string empName = hdnEmployeeName.Value;
        string deptName = hdnSelectedDeptName.Value;

        if (!string.IsNullOrEmpty(deptName))
        {
            try
            {
                using (SqlConnection con = new SqlConnection(restaurantDB))
                {
                    SqlCommand checkCmd = new SqlCommand(@"
                        SELECT COUNT(*) FROM Bills
                        WHERE Status IN ('Pending','Delivered') AND DepartmentName = @DeptName", con);
                    checkCmd.Parameters.AddWithValue("@DeptName", deptName);
                    con.Open();
                    int activeCount = Convert.ToInt32(checkCmd.ExecuteScalar());
                    if (activeCount > 0)
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "BlockCC",
                            "alert('âš ï¸ Cannot close counter!\\n\\n" + activeCount + " active order(s) still pending in " + deptName.Replace("'", "\\'") + ".\\n\\nFinalize all bills first.');", true);
                        return;
                    }
                }
            }
            catch (Exception ex) { Debug.WriteLine(ex.Message); }
        }

        Session["CC_CashierName"] = empName;
        Session["CC_OpenTime"] = Session["CC_OpenTime"] ?? DateTime.Now;
        Session["CC_EmpID"] = empId;
        Session["CC_DeptName"] = deptName;
        Response.Redirect("Counterclose.aspx");
    }
}

