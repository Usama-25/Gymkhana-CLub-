using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.UI;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Diagnostics;
using System.Web;
using System.Linq;

public partial class KitchenScreen : System.Web.UI.Page
{
    string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (!IsPostBack)
            {
                if (Session["Emp_ID"] == null)
                {
                    Response.Write("<script>alert('You are not logged in. Please login first.'); window.location.href='http://192.168.12.40/Gymkhana';</script>");
                    Response.End();
                    return;
                }

                string empID = Session["Emp_ID"].ToString();
                hdnEmpID.Value = empID;

                // POS jaisa: pehle departments load karo (auto-select bhi isi mein hoga)
                LoadDepartmentsForKitchen(empID);

                // Agar pehle se session mein saved department hai toh woh prefer karo
                if (Session["SelectedDepartmentID"] != null)
                {
                    string deptID = Session["SelectedDepartmentID"].ToString();
                    string deptName = Session["SelectedDepartmentName"] != null
                                        ? Session["SelectedDepartmentName"].ToString() : "";

                    // Validate karo ke yeh department employee ke list mein hai
                    ListItem found = ddlDepartment.Items.FindByValue(deptID);
                    if (found != null)
                    {
                        ddlDepartment.ClearSelection();
                        found.Selected = true;
                        hdnDepartmentID.Value = deptID;
                        hdnDepartmentName.Value = deptName;

                        ScriptManager.RegisterStartupScript(this, GetType(), "SetDepartment",
                            "setSelectedDepartment('" + deptID.Replace("'", "\\'") + "', '" + deptName.Replace("'", "\\'") + "');", true);
                    }
                }
                else if (!string.IsNullOrEmpty(hdnDepartmentID.Value))
                {
                    // Auto-select LoadDepartmentsForKitchen ne kiya — JS ko bhi notify karo
                    string deptID = hdnDepartmentID.Value;
                    string deptName = hdnDepartmentName.Value;

                    ScriptManager.RegisterStartupScript(this, GetType(), "SetDepartment",
                        "setSelectedDepartment('" + deptID.Replace("'", "\\'") + "', '" + deptName.Replace("'", "\\'") + "');", true);
                }

                UpdateEmployeeDisplay(empID);
            }
        }
        catch (Exception ex) { Debug.WriteLine("Page_Load Error: " + ex.Message); }
    }

    // ================================================================
    //  LOAD DEPARTMENTS — Employee ke assigned kitchen depts, fallback to all
    // ================================================================
    private void LoadDepartmentsForKitchen(string empID)
    {
        try
        {
            DataTable dt = new DataTable();

            // STEP 1: EmployeeRestaurantMap se employee ke departments try karo
            using (SqlConnection con = new SqlConnection(constr))
            {
                string query = @"
                    SELECT DISTINCT erm.SubDeptID, erm.RestaurantName AS SubDept_Name
                    FROM EmployeeRestaurantMap erm
                    WHERE erm.Emp_ID = @EmpID
                      AND erm.Role = 'Kitchen Chief'
                    ORDER BY erm.RestaurantName";

                SqlCommand cmd = new SqlCommand(query, con);
                int empIDInt;
                if (int.TryParse(empID, out empIDInt))
                    cmd.Parameters.Add("@EmpID", SqlDbType.Int).Value = empIDInt;
                else
                    cmd.Parameters.Add("@EmpID", SqlDbType.Int).Value = DBNull.Value;

                new SqlDataAdapter(cmd).Fill(dt);
            }

            // STEP 2: Agar EmployeeRestaurantMap mein kuch nahi mila
            //         toh BasicDataInfo se saare Dept_id=9 departments load karo (fallback)
            if (dt.Rows.Count == 0)
            {
                Debug.WriteLine("LoadDepartmentsForKitchen: No mapped depts for EmpID=" + empID + ", loading all Kitchen depts as fallback");
                using (SqlConnection con = new SqlConnection(
                    ConfigurationManager.ConnectionStrings["BasicDataInfoConnectionString"].ConnectionString))
                {
                    string query = @"
                        SELECT SubDept_Id AS SubDeptID, SubDept_Name
                        FROM SubDepartment
                        WHERE Dept_id = 9
                        ORDER BY SubDept_Name";

                    new SqlDataAdapter(new SqlCommand(query, con)).Fill(dt);
                }
            }

            // STEP 3: Dropdown populate karo
            ddlDepartment.Items.Clear();
            ddlDepartment.Items.Add(new ListItem("-- Select Kitchen Department --", ""));

            foreach (DataRow row in dt.Rows)
            {
                ddlDepartment.Items.Add(new ListItem(
                    row["SubDept_Name"].ToString(),
                    row["SubDeptID"].ToString()
                ));
            }

            // STEP 4: Agar sirf ek department hai toh auto-select
            if (dt.Rows.Count == 1)
            {
                ddlDepartment.SelectedIndex = 1;
                hdnDepartmentID.Value = dt.Rows[0]["SubDeptID"].ToString();
                hdnDepartmentName.Value = dt.Rows[0]["SubDept_Name"].ToString();
            }
        }
        catch (Exception ex) { Debug.WriteLine("LoadDepartmentsForKitchen error: " + ex.Message); }
    }

    private void UpdateEmployeeDisplay(string empID)
    {
        try
        {
            string name = GetEmployeeName(empID);
            string display = !string.IsNullOrEmpty(name) ? name + " (" + empID + ")" : empID;
            ScriptManager.RegisterStartupScript(this, GetType(), "UpdateEmployeeDisplay",
                "updateEmployeeDisplay('" + display.Replace("'", "\\'") + "');", true);
        }
        catch (Exception ex) { Debug.WriteLine("UpdateEmployeeDisplay error: " + ex.Message); }
    }

    private string GetEmployeeName(string empID)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(constr))
            {
                // POS jaisa: EmployeeRestaurantMap se name lo
                SqlCommand cmd = new SqlCommand(
                    "SELECT TOP 1 EmployeeName FROM EmployeeRestaurantMap WHERE Emp_ID = @EmpID", con);
                int empIDInt2;
                if (int.TryParse(empID, out empIDInt2))
                    cmd.Parameters.Add("@EmpID", SqlDbType.Int).Value = empIDInt2;
                else
                    cmd.Parameters.Add("@EmpID", SqlDbType.Int).Value = DBNull.Value;
                con.Open();
                object r = cmd.ExecuteScalar();
                return r != null ? r.ToString() : empID;
            }
        }
        catch { return empID; }
    }

    // ================================================================
    //  ddlDepartment_SelectedIndexChanged — POS jaisa handler
    // ================================================================
    protected void ddlDepartment_SelectedIndexChanged(object sender, EventArgs e)
    {
        try
        {
            if (!string.IsNullOrEmpty(ddlDepartment.SelectedValue))
            {
                hdnDepartmentID.Value = ddlDepartment.SelectedValue;
                hdnDepartmentName.Value = ddlDepartment.SelectedItem.Text;
            }
        }
        catch (Exception ex) { Debug.WriteLine("ddlDepartment_SelectedIndexChanged error: " + ex.Message); }
    }

    // ================================================================
    //  WEB METHODS
    // ================================================================

    [WebMethod]
    public static string GetKitchenEmployeeID()
    {
        try
        {
            HttpContext ctx = HttpContext.Current;
            foreach (string key in new[] { "Emp_ID", "EmpID", "EmployeeID", "UserID" })
                if (ctx.Session[key] != null && !string.IsNullOrEmpty(ctx.Session[key].ToString()))
                    return JsonConvert.SerializeObject(new { success = true, empID = ctx.Session[key].ToString() });

            return JsonConvert.SerializeObject(new { success = true, empID = "GUEST" });
        }
        catch { return JsonConvert.SerializeObject(new { success = true, empID = "GUEST" }); }
    }

    [WebMethod]
    public static string SaveSelectedDepartment(string departmentID, string departmentName)
    {
        try
        {
            HttpContext.Current.Session["SelectedDepartmentID"] = departmentID;
            HttpContext.Current.Session["SelectedDepartmentName"] = departmentName;
            return "success";
        }
        catch (Exception ex) { return "error: " + ex.Message; }
    }

    // ================================================================
    //  LOAD ORDERS — GROUPED BY BILL
    // ================================================================
    [WebMethod]
    public static string LoadOrders(string departmentID = "")
    {
        string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
        var orders = new List<KitchenOrder>();
        try
        {
            if (string.IsNullOrEmpty(departmentID))
                return JsonConvert.SerializeObject(orders);

            using (SqlConnection con = new SqlConnection(constr))
            {
                string query = @"
                    SELECT
                        bi.Id           AS ItemId,
                        bi.BillId,
                        bi.MenuItemId,
                        bi.Name,
                        bi.Quantity,
                        bi.IsPrep,
                        bi.PrepTime,
                        b.CreatedAt,
                        b.MemberNo,
                        b.DepartmentID,
                        b.DepartmentName,
                        ISNULL(b.KOT_Number,'') AS KOT_Number,
                        CONVERT(VARCHAR(5),  b.CreatedAt, 108) AS OrderTime,
                        CONVERT(VARCHAR(10), b.CreatedAt, 103) AS OrderDate,
                        DATEDIFF(MINUTE, b.CreatedAt, GETDATE()) AS MinutesAgo,
                        ISNULL(mp.MemberName,'') AS MemberName
                    FROM BillItems bi
                    INNER JOIN Bills b ON bi.BillId = b.Id
                    LEFT  JOIN Membership.dbo.MemberProfile mp ON b.MemberNo = mp.MemberNo
                    INNER JOIN dbo.Kitchen_Department_Map km
                           ON b.DepartmentID = km.Department_SubDept_Id
                    WHERE
                        b.Status IN ('Pending','In Progress')
                        AND bi.IsPrep IN ('Pending','Preparing','Completed')
                        AND km.Active = 1
                        AND km.Kitchen_SubDept_Id = @DepartmentID
                    ORDER BY
                        b.CreatedAt ASC,
                        b.Id        ASC,
                        bi.Id       ASC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@DepartmentID", departmentID);
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        var billGroups = new Dictionary<int, KitchenOrder>();

                        while (dr.Read())
                        {
                            int billId = Convert.ToInt32(dr["BillId"]);

                            if (!billGroups.ContainsKey(billId))
                            {
                                int min = dr["MinutesAgo"] == DBNull.Value ? 0 : Convert.ToInt32(dr["MinutesAgo"]);
                                string td = min < 1 ? "Just now"
                                          : min < 60 ? min + "m ago"
                                          : (min / 60) + "h " + (min % 60) + "m ago";

                                billGroups[billId] = new KitchenOrder
                                {
                                    BillId = billId,
                                    CreatedAt = Convert.ToDateTime(dr["CreatedAt"]),
                                    MemberNo = dr["MemberNo"] == DBNull.Value ? "" : dr["MemberNo"].ToString(),
                                    MemberName = dr["MemberName"].ToString(),
                                    DepartmentID = dr["DepartmentID"] == DBNull.Value ? "" : dr["DepartmentID"].ToString(),
                                    DepartmentName = dr["DepartmentName"] == DBNull.Value ? "" : dr["DepartmentName"].ToString(),
                                    KOT_Number = dr["KOT_Number"].ToString(),
                                    OrderTime = dr["OrderTime"].ToString(),
                                    OrderDate = dr["OrderDate"].ToString(),
                                    MinutesAgo = min,
                                    TimeDisplay = td,
                                    Items = new List<KitchenOrderItem>()
                                };
                            }

                            billGroups[billId].Items.Add(new KitchenOrderItem
                            {
                                ItemId = Convert.ToInt32(dr["ItemId"]),
                                MenuItemId = Convert.ToInt32(dr["MenuItemId"]),
                                Name = dr["Name"].ToString(),
                                Quantity = Convert.ToInt32(dr["Quantity"]),
                                IsPrep = dr["IsPrep"].ToString(),
                                PrepTime = dr["PrepTime"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(dr["PrepTime"])
                            });
                        }

                        orders = billGroups.Values.ToList();
                    }
                }
            }
            return JsonConvert.SerializeObject(orders);
        }
        catch (Exception ex)
        {
            Debug.WriteLine("LoadOrders error: " + ex.Message);
            return JsonConvert.SerializeObject(new List<KitchenOrder>());
        }
    }

    [WebMethod]
    public static string GetOrdersSignature(string departmentID)
    {
        string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
        try
        {
            if (string.IsNullOrEmpty(departmentID))
                return JsonConvert.SerializeObject(new { signature = "", count = 0 });

            using (SqlConnection con = new SqlConnection(constr))
            {
                string query = @"
                    SELECT
                        COUNT(DISTINCT b.Id) AS TotalBills,
                        ISNULL(CAST(MAX(bi.Id) AS VARCHAR(20)),'') AS MaxId,
                        ISNULL(SUM(CASE WHEN bi.IsPrep='Pending'   THEN 1 ELSE 0 END),0) AS PendingCnt,
                        ISNULL(SUM(CASE WHEN bi.IsPrep='Preparing' THEN 1 ELSE 0 END),0) AS PreparingCnt,
                        ISNULL(SUM(CASE WHEN bi.IsPrep='Completed' THEN 1 ELSE 0 END),0) AS CompletedCnt,
                        ISNULL(CONVERT(VARCHAR(20), MAX(b.CreatedAt), 120),'') AS LatestOrder
                    FROM BillItems bi
                    INNER JOIN Bills b ON bi.BillId = b.Id
                    INNER JOIN dbo.Kitchen_Department_Map km
                           ON b.DepartmentID = km.Department_SubDept_Id
                    WHERE
                        b.Status IN ('Pending','In Progress')
                        AND bi.IsPrep IN ('Pending','Preparing','Completed')
                        AND km.Active = 1
                        AND km.Kitchen_SubDept_Id = @DepartmentID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@DepartmentID", departmentID);
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            string sig = dr["TotalBills"] + "|" + dr["MaxId"] + "|"
                                       + dr["PendingCnt"] + "|" + dr["PreparingCnt"] + "|"
                                       + dr["CompletedCnt"] + "|" + dr["LatestOrder"];

                            return JsonConvert.SerializeObject(new
                            {
                                signature = sig,
                                count = Convert.ToInt32(dr["TotalBills"]),
                                pending = Convert.ToInt32(dr["PendingCnt"]),
                                preparing = Convert.ToInt32(dr["PreparingCnt"]),
                                completed = Convert.ToInt32(dr["CompletedCnt"])
                            });
                        }
                    }
                }
            }
        }
        catch (Exception ex) { Debug.WriteLine("GetOrdersSignature error: " + ex.Message); }
        return JsonConvert.SerializeObject(new { signature = "", count = 0 });
    }

    [WebMethod]
    public static string SearchOrders(string departmentID, string searchTerm)
    {
        try
        {
            string allJson = LoadOrders(departmentID);
            if (string.IsNullOrWhiteSpace(searchTerm)) return allJson;

            var orders = JsonConvert.DeserializeObject<List<KitchenOrder>>(allJson);
            string term = searchTerm.Trim().ToLower();

            var filtered = orders.FindAll(o =>
                (o.MemberNo != null && o.MemberNo.ToLower().Contains(term)) ||
                (o.MemberName != null && o.MemberName.ToLower().Contains(term)) ||
                (o.KOT_Number != null && o.KOT_Number.ToLower().Contains(term)) ||
                (o.Items != null && o.Items.Exists(i => i.Name != null && i.Name.ToLower().Contains(term))));

            return JsonConvert.SerializeObject(filtered);
        }
        catch (Exception ex)
        {
            Debug.WriteLine("SearchOrders error: " + ex.Message);
            return JsonConvert.SerializeObject(new List<KitchenOrder>());
        }
    }

    [WebMethod]
    public static string UpdateItemPrepStatus(int itemId, string status)
    {
        string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
        try
        {
            if (status != "Preparing" && status != "Completed")
                return "error: invalid status '" + status + "'";

            using (SqlConnection con = new SqlConnection(constr))
            {
                string sql = @"
                    UPDATE BillItems
                    SET IsPrep   = @Status,
                        PrepTime = CASE WHEN @Status='Completed' THEN GETDATE() ELSE PrepTime END
                    WHERE Id = @ItemId";

                SqlCommand cmd = new SqlCommand(sql, con);
                cmd.Parameters.Add("@Status", SqlDbType.NVarChar).Value = status;
                cmd.Parameters.Add("@ItemId", SqlDbType.Int).Value = itemId;
                con.Open();
                int rows = cmd.ExecuteNonQuery();
                if (rows <= 0) return "error: item not found or not updated";
            }
            return "success";
        }
        catch (Exception ex)
        {
            Debug.WriteLine("UpdateItemPrepStatus error: " + ex.Message);
            return "error: " + ex.Message;
        }
    }

    [WebMethod]
    public static string MarkBillReady(int billId)
    {
        string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
        try
        {
            // Check: saare items Completed hain?
            using (SqlConnection con = new SqlConnection(constr))
            {
                con.Open();
                SqlCommand chk = new SqlCommand(
                    "SELECT COUNT(*) FROM BillItems WHERE BillId=@BillId AND IsPrep <> 'Completed'", con);
                chk.Parameters.AddWithValue("@BillId", billId);
                int notDone = Convert.ToInt32(chk.ExecuteScalar());
                if (notDone > 0)
                    return "error: " + notDone + " item(s) not yet Completed";
            }

            string empID = "";
            if (HttpContext.Current != null &&
                HttpContext.Current.Session != null &&
                HttpContext.Current.Session["Emp_ID"] != null)
                empID = HttpContext.Current.Session["Emp_ID"].ToString();

            // Bill items fetch karo log ke liye
            DataTable items = new DataTable();
            using (SqlConnection con = new SqlConnection(constr))
            {
                string fetchSql = @"
                    SELECT
                        bi.Id AS ItemId, bi.MenuItemId, bi.Name, bi.Quantity, bi.IsPrep,
                        b.MemberNo, b.DepartmentID, b.DepartmentName,
                        ISNULL(b.KOT_Number,'') AS KOT_Number,
                        ISNULL(mp.MemberName,'') AS MemberName
                    FROM BillItems bi
                    INNER JOIN Bills b ON bi.BillId = b.Id
                    LEFT  JOIN Membership.dbo.MemberProfile mp ON b.MemberNo = mp.MemberNo
                    WHERE bi.BillId = @BillId";

                SqlCommand cmd = new SqlCommand(fetchSql, con);
                cmd.Parameters.AddWithValue("@BillId", billId);
                new SqlDataAdapter(cmd).Fill(items);
            }

            // KitchenReadyLog mein insert karo
            foreach (DataRow row in items.Rows)
            {
                using (SqlConnection con = new SqlConnection(constr))
                {
                    string ins = @"
                        INSERT INTO KitchenReadyLog
                            (ItemId, BillId, MenuItemId, ItemName, Quantity,
                             MemberNo, MemberName, DepartmentID, DepartmentName,
                             KOT_Number, StatusBefore, StatusAfter, MarkedByEmpID, MarkedAt, Notes)
                        VALUES
                            (@ItemId, @BillId, @MenuItemId, @ItemName, @Qty,
                             @MemberNo, @MemberName, @DeptID, @DeptName,
                             @KOT, @StatusBefore, 'Ready', @EmpID, GETDATE(), 'Bill marked Ready from Kitchen')";

                    SqlCommand cmd = new SqlCommand(ins, con);
                    cmd.Parameters.Add("@ItemId", SqlDbType.Int).Value = Convert.ToInt32(row["ItemId"]);
                    cmd.Parameters.Add("@BillId", SqlDbType.Int).Value = billId;
                    cmd.Parameters.Add("@MenuItemId", SqlDbType.Int).Value = Convert.ToInt32(row["MenuItemId"]);
                    cmd.Parameters.Add("@ItemName", SqlDbType.NVarChar).Value = row["Name"].ToString();
                    cmd.Parameters.Add("@Qty", SqlDbType.Int).Value = Convert.ToInt32(row["Quantity"]);
                    cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar).Value = NullIfEmpty(row["MemberNo"].ToString());
                    cmd.Parameters.Add("@MemberName", SqlDbType.NVarChar).Value = NullIfEmpty(row["MemberName"].ToString());
                    cmd.Parameters.Add("@DeptID", SqlDbType.NVarChar).Value = NullIfEmpty(row["DepartmentID"].ToString());
                    cmd.Parameters.Add("@DeptName", SqlDbType.NVarChar).Value = NullIfEmpty(row["DepartmentName"].ToString());
                    cmd.Parameters.Add("@KOT", SqlDbType.NVarChar).Value = NullIfEmpty(row["KOT_Number"].ToString());
                    cmd.Parameters.Add("@StatusBefore", SqlDbType.NVarChar).Value = row["IsPrep"].ToString();
                    cmd.Parameters.Add("@EmpID", SqlDbType.NVarChar).Value = NullIfEmpty(empID);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            // Bill status Completed karo
            using (SqlConnection con = new SqlConnection(constr))
            {
                con.Open();
                SqlCommand cmd = new SqlCommand("UPDATE Bills SET Status='Completed' WHERE Id=@BillId", con);
                cmd.Parameters.AddWithValue("@BillId", billId);
                cmd.ExecuteNonQuery();
            }

            return "success";
        }
        catch (Exception ex)
        {
            Debug.WriteLine("MarkBillReady error: " + ex.Message);
            return "error: " + ex.Message;
        }
    }

    private static object NullIfEmpty(string val)
    {
        return string.IsNullOrEmpty(val) ? (object)DBNull.Value : val;
    }

    [WebMethod]
    public static string GetKitchenStats()
    {
        string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
        try
        {
            using (SqlConnection con = new SqlConnection(constr))
            {
                string query = @"
                    SELECT
                        ISNULL(SUM(CASE WHEN bi.IsPrep='Pending'   THEN 1 ELSE 0 END),0) AS PendingCount,
                        ISNULL(SUM(CASE WHEN bi.IsPrep='Preparing' THEN 1 ELSE 0 END),0) AS PreparingCount,
                        ISNULL(SUM(CASE WHEN bi.IsPrep='Completed' THEN 1 ELSE 0 END),0) AS CompletedCount,
                        COUNT(DISTINCT b.Id) AS TotalBills
                    FROM BillItems bi
                    INNER JOIN Bills b ON bi.BillId = b.Id
                    WHERE b.Status IN ('Pending','In Progress')
                      AND CAST(b.CreatedAt AS DATE) = CAST(GETDATE() AS DATE)";

                SqlCommand cmd = new SqlCommand(query, con);
                con.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                        return JsonConvert.SerializeObject(new
                        {
                            PendingCount = Convert.ToInt32(dr["PendingCount"]),
                            PreparingCount = Convert.ToInt32(dr["PreparingCount"]),
                            ReadyCount = Convert.ToInt32(dr["CompletedCount"]),
                            TotalItems = Convert.ToInt32(dr["TotalBills"])
                        });
                }
            }
        }
        catch (Exception ex) { Debug.WriteLine("GetKitchenStats error: " + ex.Message); }
        return JsonConvert.SerializeObject(new { PendingCount = 0, PreparingCount = 0, ReadyCount = 0, TotalItems = 0 });
    }

    // ================================================================
    //  MODEL CLASSES
    // ================================================================

    public class KitchenOrderItem
    {
        public int ItemId { get; set; }
        public int MenuItemId { get; set; }
        public string Name { get; set; }
        public int Quantity { get; set; }
        public string IsPrep { get; set; }
        public DateTime? PrepTime { get; set; }
    }

    public class KitchenOrder
    {
        public int BillId { get; set; }
        public DateTime CreatedAt { get; set; }
        public string MemberNo { get; set; }
        public string MemberName { get; set; }
        public string DepartmentID { get; set; }
        public string DepartmentName { get; set; }
        public string KOT_Number { get; set; }
        public string OrderTime { get; set; }
        public string OrderDate { get; set; }
        public int MinutesAgo { get; set; }
        public string TimeDisplay { get; set; }
        public List<KitchenOrderItem> Items { get; set; }

        public string TableNo
        {
            get
            {
                if (!string.IsNullOrEmpty(MemberNo) && MemberNo.Length >= 2)
                    return MemberNo.Substring(MemberNo.Length - 2);
                return MemberNo;
            }
        }

        public string OverallStatus
        {
            get
            {
                if (Items == null || !Items.Any()) return "Pending";
                if (Items.Any(i => i.IsPrep == "Pending")) return "Pending";
                if (Items.Any(i => i.IsPrep == "Preparing")) return "Preparing";
                return "Completed";
            }
        }

        public int OverallProgress
        {
            get
            {
                if (Items == null || !Items.Any()) return 0;
                var statusOrder = new Dictionary<string, int>
                {
                    { "Pending",   0  },
                    { "Preparing", 50 },
                    { "Completed", 100}
                };
                int total = Items.Sum(i => statusOrder.ContainsKey(i.IsPrep) ? statusOrder[i.IsPrep] : 0);
                return total / Items.Count;
            }
        }
    }
}

