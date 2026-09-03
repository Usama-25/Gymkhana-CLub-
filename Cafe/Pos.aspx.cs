using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI.WebControls;
using GymKhana.Library;

public partial class Pos : System.Web.UI.Page
{
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
                empDisplay.InnerText = employeeName;

                CheckIfManager(empID);
                LoadDepartments(empID);
                LoadSelectedDepartment();
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine("Page_Load Error: " + ex.Message);
            ShowAccessDenied("System initialization error. Please contact administrator.");
        }
    }

    private string GetEmployeeName(string empID)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString))
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

    private void CheckIfManager(string empID)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString))
            {
                try
                {
                    string query = "SELECT IsManager FROM Employees WHERE Emp_ID = @EmpID";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@EmpID", empID);
                        con.Open();
                        object result = cmd.ExecuteScalar();
                        hdnIsManager.Value = result != null && Convert.ToBoolean(result) ? "True" : "False";
                    }
                }
                catch { hdnIsManager.Value = "False"; }
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine("CheckIfManager error: " + ex.Message);
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
            using (SqlConnection con = new SqlConnection(
                ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString))
            {
                string query = @"
                SELECT DISTINCT RestaurantName, SubDeptID
                FROM EmployeeRestaurantMap
                WHERE Emp_ID = @empID AND Role='Waiter'
                ORDER BY RestaurantName;";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@empID", empID);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlDepartment.Items.Clear();
                ddlDepartment.Items.Add(new ListItem("-- Select Department --", ""));

                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        ddlDepartment.Items.Add(new ListItem(
                            row["RestaurantName"].ToString(),
                            row["SubDeptID"].ToString()
                        ));
                    }
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

    private void LoadSelectedDepartment()
    {
        try
        {
            string deptID = Request.QueryString["deptId"] ?? hdnSelectedDeptID.Value;
            string deptName = Request.QueryString["deptName"] ?? hdnSelectedDeptName.Value;

            if (!string.IsNullOrEmpty(deptID))
            {
                ListItem item = ddlDepartment.Items.FindByValue(deptID);
                if (item != null)
                {
                    ddlDepartment.ClearSelection();
                    item.Selected = true;
                    hdnSelectedDeptID.Value = deptID;
                    hdnSelectedDeptName.Value = !string.IsNullOrEmpty(deptName) ? deptName : item.Text;
                }
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine("LoadSelectedDepartment error: " + ex.Message);
        }
    }

    protected void ddlDepartment_SelectedIndexChanged(object sender, EventArgs e)
    {
        try
        {
            if (!string.IsNullOrEmpty(ddlDepartment.SelectedValue))
            {
                hdnSelectedDeptID.Value = ddlDepartment.SelectedValue;
                hdnSelectedDeptName.Value = ddlDepartment.SelectedItem.Text;
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine("ddlDepartment_SelectedIndexChanged error: " + ex.Message);
        }
    }

    // ==================== GET SUBDEPT ABBREVIATION ====================
    [WebMethod]
    public static object GetSubDeptAbb(string subDeptId)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(subDeptId))
                return new { success = false, message = "SubDept ID required", abb = "" };

            string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                // Dynamic query - Dept_id is derived from EmployeeRestaurantMap, SubDept_Id is the login dept
                string query = @"
                    SELECT ISNULL(subdept_abb, '') AS subdept_abb
                    FROM SubDepartment
                    WHERE SubDept_Id = @SubDeptId";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@SubDeptId", subDeptId.Trim());
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    string abb = result != null && result != DBNull.Value ? result.ToString().Trim() : "";
                    return new { success = true, abb = abb };
                }
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine("GetSubDeptAbb error: " + ex.Message);
            return new { success = false, message = ex.Message, abb = "" };
        }
    }

    // ==================== KOT NUMBER GENERATOR (NEW FORMAT) ====================
    // New format: {ABB}-{DDMMYY}-{NNNN}  e.g. C9-260622-0001
    private static string GenerateKotNumber(SqlConnection con, SqlTransaction trans, string subDeptAbb)
    {
        string dateStr = DateTime.Now.ToString("ddMMyy");
        string abb = !string.IsNullOrWhiteSpace(subDeptAbb) ? subDeptAbb.Trim() : "KOT";
        string prefix = abb + "-" + dateStr + "-";

        string query = @"
            SELECT ISNULL(MAX(CAST(SUBSTRING(KOT_Number, LEN(@prefix)+1, 4) AS INT)), 0)
            FROM Bills
            WHERE KOT_Number LIKE @prefix + '%'";

        using (SqlCommand cmd = new SqlCommand(query, con, trans))
        {
            cmd.Parameters.AddWithValue("@prefix", prefix);
            int lastSeq = Convert.ToInt32(cmd.ExecuteScalar());
            return prefix + (lastSeq + 1).ToString("D4");
        }
    }

    // ==================== WEB METHODS ====================

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
                SELECT TOP 10 
                    rdm.id, rdm.ItemCode,
                    rdm.ItemName AS name,
                    rdm.Price,
                    ISNULL(rdm.Category, '') AS category,
                    ISNULL(rdm.GST, 0) AS gst
                FROM MenuItems rdm
                WHERE 
                (
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
                    image = "",
                    category = r["category"].ToString()
                });
            }

            return new { success = true, data = list };
        }
        catch (Exception ex)
        {
            Debug.WriteLine("GetProducts error: " + ex.Message);
            return new { success = false, message = "Error: " + ex.Message };
        }
    }

    [WebMethod]
    public static object GetMember(string search)
    {
        try
        {
            string constr = ConfigurationManager
                .ConnectionStrings["MemberShipConnection"]
                .ConnectionString;

            ScanRFID scanner = new ScanRFID(constr);
            DataTable dt = scanner.CheckRFID(search);

            if (dt == null || dt.Rows.Count == 0)
                return new { success = false, message = "Member not found" };

            DataRow rd = dt.Rows[0];

            bool isActive = false;
            bool isCardActive = false;

            string activeValue = rd["IsActive"] != DBNull.Value
                ? rd["IsActive"].ToString().Trim().ToLower() : "";
            string cardValue = rd["IsCardActive"] != DBNull.Value
                ? rd["IsCardActive"].ToString().Trim().ToLower() : "";

            isActive = activeValue == "1" || activeValue == "true" || activeValue == "yes" || activeValue == "y";
            isCardActive = cardValue == "1" || cardValue == "true" || cardValue == "yes" || cardValue == "y";

            string status = rd["Status"] != DBNull.Value ? rd["Status"].ToString().Trim() : "";
            string statusLower = status.ToLower();

            if (!isActive || !isCardActive ||
                (statusLower != "active" && statusLower != "absentee"))
            {
                string reason = "Member account is ";
                if (!isActive) reason += "deactivated";
                else if (!isCardActive) reason += "card deactivated";
                else reason += status;
                return new { success = false, message = reason };
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
            return new { success = false, message = "Error searching member: " + ex.Message };
        }
    }

    [WebMethod]
    public static object GetRoomInfo(string roomNo)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(roomNo))
                return new { success = false, message = "Room number is required" };

            string constr = ConfigurationManager
                .ConnectionStrings["GuestRoomDBConnectionString"]
                .ConnectionString;

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
                        {
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
                        }
                        else
                        {
                            return new { success = false, message = "No occupied room found for Room No: " + roomNo };
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine("GetRoomInfo error: " + ex.Message);
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
                        {
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
            }

            if (list.Count == 0)
                return new { success = false, message = "No affiliated member found", data = list };

            return new { success = true, message = list.Count + " member(s) found", data = list };
        }
        catch (SqlException sqlEx)
        {
            Debug.WriteLine("SQL Error in SearchAffiliatedMember: " + sqlEx.Message);
            return new { success = false, message = "Database error occurred.", error = sqlEx.Message, data = new List<object>() };
        }
        catch (Exception ex)
        {
            Debug.WriteLine("SearchAffiliatedMember error: " + ex.Message);
            return new { success = false, message = "System error occurred.", error = ex.Message, data = new List<object>() };
        }
    }

    // ==================== SUBMIT ORDER (with dynamic SubDept Abb for KOT) ====================
    [WebMethod]
    public static object SubmitOrder(string memberNo, decimal totalAmount, string itemsJson,
                                     string tableNumber, string departmentId, string departmentName,
                                     string employeeID, string waiterName,
                                     string memberType, string roomNo, int covers = 1,
                                     string affiliatedIntroNo = "", string affiliatedClubName = "",
                                     string affiliatedMemberNo = "",
                                     string reservationNo = "", string guestName = "",
                                     string subDeptAbb = "")
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

            // If abb not passed, try to look it up from DB
            string kotAbb = subDeptAbb;
            if (string.IsNullOrWhiteSpace(kotAbb) && !string.IsNullOrWhiteSpace(departmentId))
            {
                try
                {
                    string constrLookup = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
                    using (SqlConnection conLookup = new SqlConnection(constrLookup))
                    {
                        string qAbb = "SELECT ISNULL(subdept_abb,'') FROM SubDepartment WHERE SubDept_Id = @id";
                        using (SqlCommand cmdAbb = new SqlCommand(qAbb, conLookup))
                        {
                            cmdAbb.Parameters.AddWithValue("@id", departmentId);
                            conLookup.Open();
                            object abbResult = cmdAbb.ExecuteScalar();
                            if (abbResult != null && abbResult != DBNull.Value)
                                kotAbb = abbResult.ToString().Trim();
                        }
                    }
                }
                catch { kotAbb = "KOT"; }
            }
            if (string.IsNullOrWhiteSpace(kotAbb)) kotAbb = "KOT";

            string conStr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;

            using (SqlConnection con = new SqlConnection(conStr))
            {
                con.Open();
                using (SqlTransaction trans = con.BeginTransaction())
                {
                    try
                    {
                        int orderId;
                        decimal subtotal = 0;
                        decimal taxTotal = 0;

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
                        string kotNumber = GenerateKotNumber(con, trans, kotAbb);
                        string tableVal = string.IsNullOrWhiteSpace(tableNumber) ? null : tableNumber.Trim();

                        string orderQuery = @"
                        INSERT INTO Bills 
                        (CreatedAt, Total, Subtotal, MemberNo, Status, TableNumber,
                         WaiterName, DepartmentID, DepartmentName, EmployeeID, bill_to, roomno,
                         TaxApplied, FinalAmount, Cover, KOT_Number,
                         AffiliatedIntroNo, AffiliatedClubName, AffiliatedMemberNo,
                         ReservationNo, GuestName)
                        OUTPUT INSERTED.Id
                        VALUES 
                        (GETDATE(), @Total, @Subtotal, @MemberNo, 'Pending', @TableNumber,
                         @WaiterName, @DepartmentID, @DepartmentName, @EmployeeID, @bill_to, @roomno,
                         @TaxApplied, @FinalAmount, @Cover, @KOT_Number,
                         @AffiliatedIntroNo, @AffiliatedClubName, @AffiliatedMemberNo,
                         @ReservationNo, @GuestName)";

                        using (SqlCommand cmd = new SqlCommand(orderQuery, con, trans))
                        {
                            cmd.Parameters.AddWithValue("@Total", finalAmount);
                            cmd.Parameters.AddWithValue("@Subtotal", subtotal);
                            cmd.Parameters.AddWithValue("@TaxApplied", taxTotal);
                            cmd.Parameters.AddWithValue("@FinalAmount", finalAmount);
                            cmd.Parameters.AddWithValue("@MemberNo", memberNo);
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
                            orderId = Convert.ToInt32(cmd.ExecuteScalar());
                        }

                        foreach (var item in items)
                        {
                            int menuItemId = Convert.ToInt32(item["MenuItemId"]);
                            string name = item["Name"].ToString();
                            decimal price = Convert.ToDecimal(item["Price"]);
                            int quantity = Convert.ToInt32(item["Quantity"]);
                            int gstRate = Convert.ToInt32(item["GST"]);

                            decimal itemSubtotal = price * quantity;
                            decimal gstAmount = (itemSubtotal * gstRate) / 100m;
                            decimal lineTotal = itemSubtotal + gstAmount;

                            string itemCode = "";
                            using (SqlCommand cmdCode = new SqlCommand(
                                "SELECT TOP 1 ItemCode FROM Restaurant_Catalog WHERE ItemName = @ItemName", con, trans))
                            {
                                cmdCode.Parameters.AddWithValue("@ItemName", name);
                                object result = cmdCode.ExecuteScalar();
                                if (result != null && result != DBNull.Value)
                                    itemCode = result.ToString();
                            }

                            string itemQuery = @"
    INSERT INTO BillItems
    (BillId, MenuItemId, ItemCode, Name, Price, Quantity, ItemSubtotal, GSTPercent, GSTAmount, LineTotal, IsPrep, Notes)
    VALUES
    (@BillId, @MenuItemId, @ItemCode, @Name, @Price, @Quantity, @ItemSubtotal, @GSTPercent, @GSTAmount, @LineTotal, 'Pending', @Notes)";

                            using (SqlCommand cmd = new SqlCommand(itemQuery, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@BillId", orderId);
                                cmd.Parameters.AddWithValue("@MenuItemId", menuItemId);
                                cmd.Parameters.AddWithValue("@ItemCode", itemCode);
                                cmd.Parameters.AddWithValue("@Name", name);
                                cmd.Parameters.AddWithValue("@Price", price);
                                cmd.Parameters.AddWithValue("@Quantity", quantity);
                                cmd.Parameters.AddWithValue("@ItemSubtotal", itemSubtotal);
                                cmd.Parameters.AddWithValue("@GSTPercent", gstRate);
                                cmd.Parameters.AddWithValue("@GSTAmount", gstAmount);
                                cmd.Parameters.AddWithValue("@LineTotal", lineTotal);
                                cmd.Parameters.AddWithValue("@Notes", item.ContainsKey("Notes") ? item["Notes"].ToString() : "");
                                cmd.ExecuteNonQuery();
                            }
                        }

                        trans.Commit();
                        return new
                        {
                            success = true,
                            orderId = orderId,
                            kotNumber = kotNumber,
                            totalAmount = finalAmount,
                            subtotal = subtotal,
                            taxAmount = taxTotal,
                            covers = covers,
                            departmentName = departmentName,
                            message = "Order placed successfully"
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

    [WebMethod]
    public static object MarkOrderAsDelivered(string orderId, string employeeID)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(orderId))
                return new { success = false, message = "Order ID required" };

            int parsedOrderId;
            if (!int.TryParse(orderId, out parsedOrderId))
                return new { success = false, message = "Invalid Order ID" };

            string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                con.Open();
                string checkQuery = "SELECT Status FROM Bills WHERE Id = @OrderId";
                using (SqlCommand cmd = new SqlCommand(checkQuery, con))
                {
                    cmd.Parameters.AddWithValue("@OrderId", parsedOrderId);
                    object status = cmd.ExecuteScalar();
                    if (status == null) return new { success = false, message = "Order not found" };
                    if (status.ToString() == "Delivered") return new { success = true, message = "Order already Delivered" };
                }

                string updateQuery = "UPDATE Bills SET Status = 'Delivered', PaymentDate = GETDATE() WHERE Id = @OrderId";
                using (SqlCommand cmd = new SqlCommand(updateQuery, con))
                {
                    cmd.Parameters.AddWithValue("@OrderId", parsedOrderId);
                    int rows = cmd.ExecuteNonQuery();
                    return rows > 0
                        ? new { success = true, message = "Order #" + parsedOrderId + " marked as Delivered" }
                        : new { success = false, message = "Update failed" };
                }
            }
        }
        catch (Exception ex)
        {
            return new { success = false, message = "Error: " + ex.Message };
        }
    }

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
                string roomNoVal = null;
                string currentStatus = "";

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

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<object> GetActiveOrders(string departmentId = "")
    {
        var orders = new List<object>();
        try
        {
            string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                string query = @"
                SELECT TOP 20
                    b.Id AS OrderId, b.CreatedAt, b.Total, b.Subtotal, b.MemberNo,
                    b.Status, b.TableNumber, b.DepartmentID, b.DepartmentName, b.EmployeeID, b.WaiterName,
                    b.PaymentMethod, b.PaymentDate, b.roomno, b.TaxApplied, b.FinalAmount,
                    ISNULL(b.Cover, 1) AS Cover, ISNULL(b.KOT_Number, '') AS KOT_Number,
                    b.bill_to
                FROM Bills b
                WHERE b.Status IN ('Pending', 'In Progress', 'Completed')
                AND (@DeptID = '' OR CAST(b.DepartmentID AS VARCHAR(20)) = @DeptID)
                ORDER BY
                    CASE b.Status WHEN 'Pending' THEN 1 WHEN 'In Progress' THEN 2 WHEN 'Completed' THEN 3 ELSE 4 END,
                    b.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@DeptID", (departmentId ?? "").Trim());
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        DateTime createdAt = dr["CreatedAt"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(dr["CreatedAt"]);
                        orders.Add(new
                        {
                            id = dr["OrderId"].ToString(),
                            date = createdAt.ToString("dd MMM yyyy hh:mm tt"),
                            total = "Rs. " + Convert.ToDecimal(dr["Total"]).ToString("N2"),
                            subtotal = "Rs. " + (dr["Subtotal"] == DBNull.Value ? 0 : Convert.ToDecimal(dr["Subtotal"])).ToString("N2"),
                            memberNo = dr["MemberNo"] == DBNull.Value ? "Guest" : dr["MemberNo"].ToString(),
                            status = dr["Status"].ToString(),
                            tableNumber = dr["TableNumber"] == DBNull.Value ? "" : dr["TableNumber"].ToString(),
                            departmentName = dr["DepartmentName"] == DBNull.Value ? "" : dr["DepartmentName"].ToString(),
                            employeeID = dr["EmployeeID"] == DBNull.Value ? "" : dr["EmployeeID"].ToString(),
                            waiterName = dr["WaiterName"] == DBNull.Value ? "" : dr["WaiterName"].ToString(),
                            roomNo = dr["roomno"] == DBNull.Value ? "" : dr["roomno"].ToString(),
                            cover = dr["Cover"] == DBNull.Value ? 1 : Convert.ToInt32(dr["Cover"]),
                            kotNumber = dr["KOT_Number"].ToString(),
                            billTo = dr["bill_to"] == DBNull.Value ? "" : dr["bill_to"].ToString(),
                            createdAt = createdAt
                        });
                    }
                }
            }
        }
        catch (Exception ex) { Debug.WriteLine("Error in GetActiveOrders: " + ex.Message); }
        return orders;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<object> GetDeliveredOrders(string departmentId = "")
    {
        var orders = new List<object>();
        try
        {
            string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                string query = @"
                SELECT TOP 50
                    b.Id AS OrderId, b.CreatedAt, b.Total, b.Subtotal, b.MemberNo,
                    b.Status, b.TableNumber, b.DepartmentName, b.EmployeeID, b.WaiterName,
                    b.PaymentDate, b.roomno, b.TaxApplied, b.FinalAmount,
                    ISNULL(b.Cover, 1) AS Cover, ISNULL(b.KOT_Number, '') AS KOT_Number
                FROM Bills b
                WHERE b.Status = 'Delivered'
                AND (@DeptID = '' OR CAST(b.DepartmentID AS VARCHAR(20)) = @DeptID)
                ORDER BY b.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@DeptID", (departmentId ?? "").Trim());
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        DateTime createdAt = dr["CreatedAt"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(dr["CreatedAt"]);
                        orders.Add(new
                        {
                            id = dr["OrderId"].ToString(),
                            date = createdAt.ToString("dd MMM yyyy hh:mm tt"),
                            total = "Rs. " + Convert.ToDecimal(dr["Total"]).ToString("N2"),
                            memberNo = dr["MemberNo"] == DBNull.Value ? "Guest" : dr["MemberNo"].ToString(),
                            status = "Delivered",
                            tableNumber = dr["TableNumber"] == DBNull.Value ? "" : dr["TableNumber"].ToString(),
                            departmentName = dr["DepartmentName"] == DBNull.Value ? "" : dr["DepartmentName"].ToString(),
                            employeeID = dr["EmployeeID"] == DBNull.Value ? "" : dr["EmployeeID"].ToString(),
                            waiterName = dr["WaiterName"] == DBNull.Value ? "" : dr["WaiterName"].ToString(),
                            roomNo = dr["roomno"] == DBNull.Value ? "" : dr["roomno"].ToString(),
                            cover = dr["Cover"] == DBNull.Value ? 1 : Convert.ToInt32(dr["Cover"]),
                            kotNumber = dr["KOT_Number"].ToString(),
                            createdAt = createdAt
                        });
                    }
                }
            }
        }
        catch (Exception ex) { Debug.WriteLine("Error in GetDeliveredOrders: " + ex.Message); }
        return orders;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static List<object> GetOrderHistory()
    {
        var orders = new List<object>();
        try
        {
            string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                string query = @"
                    SELECT TOP 50
                        b.Id AS OrderId, b.CreatedAt, b.Total, b.Subtotal, b.MemberNo,
                        b.Status, b.TableNumber, b.DepartmentName, b.EmployeeID, b.WaiterName,
                        b.PaymentDate, b.roomno, b.TaxApplied, b.FinalAmount,
                        ISNULL(b.Cover, 1) AS Cover, ISNULL(b.KOT_Number, '') AS KOT_Number
                    FROM Bills b
                    WHERE b.Status IN ('Paid')
                    ORDER BY b.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        DateTime createdAt = dr["CreatedAt"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(dr["CreatedAt"]);
                        orders.Add(new
                        {
                            id = dr["OrderId"].ToString(),
                            date = createdAt.ToString("dd MMM yyyy hh:mm tt"),
                            total = "Rs. " + Convert.ToDecimal(dr["Total"]).ToString("N2"),
                            memberNo = dr["MemberNo"] == DBNull.Value ? "Guest" : dr["MemberNo"].ToString(),
                            status = dr["Status"].ToString(),
                            tableNumber = dr["TableNumber"] == DBNull.Value ? "" : dr["TableNumber"].ToString(),
                            departmentName = dr["DepartmentName"] == DBNull.Value ? "" : dr["DepartmentName"].ToString(),
                            employeeID = dr["EmployeeID"] == DBNull.Value ? "" : dr["EmployeeID"].ToString(),
                            roomNo = dr["roomno"] == DBNull.Value ? "" : dr["roomno"].ToString(),
                            cover = dr["Cover"] == DBNull.Value ? 1 : Convert.ToInt32(dr["Cover"]),
                            kotNumber = dr["KOT_Number"].ToString()
                        });
                    }
                }
            }
        }
        catch (Exception ex) { Debug.WriteLine("Error in GetOrderHistory: " + ex.Message); }
        return orders;
    }

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
                           ISNULL(b.ReservationNo,'') AS ReservationNo,
                           ISNULL(b.GuestName,'') AS GuestName
                    FROM Bills b
                    WHERE b.Id = @OrderId";

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
                        string employeeID = orderDr["EmployeeID"] == DBNull.Value ? "" : orderDr["EmployeeID"].ToString();
                        string waiterName = orderDr["WaiterName"] == DBNull.Value ? "" : orderDr["WaiterName"].ToString();
                        string status = orderDr["Status"] == DBNull.Value ? "Pending" : orderDr["Status"].ToString();
                        string billTo = orderDr["bill_to"] == DBNull.Value ? "" : orderDr["bill_to"].ToString();
                        string afIntroNo = orderDr["AffiliatedIntroNo"] == DBNull.Value ? "" : orderDr["AffiliatedIntroNo"].ToString();
                        string afClubName = orderDr["AffiliatedClubName"] == DBNull.Value ? "" : orderDr["AffiliatedClubName"].ToString();
                        string afMemberNo = orderDr["AffiliatedMemberNo"] == DBNull.Value ? "" : orderDr["AffiliatedMemberNo"].ToString();
                        string reservationNo = orderDr["ReservationNo"].ToString();
                        string guestName = orderDr["GuestName"].ToString();

                        orderDr.Close();

                        string itemsQuery = @"
                            SELECT bi.Id AS BillItemId, bi.Name AS ItemName, bi.Price,
                                   bi.Quantity, bi.LineTotal, bi.IsPrep AS PrepStatus, bi.Notes
                            FROM BillItems bi
                            WHERE bi.BillId = @OrderId ORDER BY bi.Id";

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
                                total = "Rs. " + total.ToString("N2"),
                                subtotal = "Rs. " + subtotal.ToString("N2"),
                                taxApplied = "Rs. " + taxApplied.ToString("N2"),
                                finalAmount = "Rs. " + finalAmount.ToString("N2"),
                                memberNo,
                                status,
                                tableNumber,
                                departmentName,
                                employeeID,
                                waiterName,
                                roomNo = roomNoStr,
                                cover,
                                kotNumber,
                                billTo,
                                afIntroNo,
                                afClubName,
                                afMemberNo,
                                reservationNo,
                                guestName,
                                items = itemsList
                            };
                        }
                    }
                    else
                    {
                        orderDr.Close();
                        return new { success = false, message = "Order not found" };
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine("Error in GetOrderDetails: " + ex.Message);
            return new { success = false, message = "Error: " + ex.Message };
        }
    }
}

