using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using GymKhana.Library;

public partial class Casier : System.Web.UI.Page
{
    string restaurantDB = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
    string membershipDB = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;

    // ════════════════════════════════════════════════════════════════
    // SAFEBOOL
    // ════════════════════════════════════════════════════════════════
    private static bool SafeBool(object val)
    {
        if (val == null || val == DBNull.Value) return false;
        if (val is bool) return (bool)val;
        if (val is int) return (int)val != 0;
        if (val is short) return (short)val != 0;
        if (val is byte) return (byte)val != 0;
        if (val is long) return (long)val != 0;

        string s = val.ToString().Trim().ToLower();
        switch (s)
        {
            case "1":
            case "true":
            case "yes":
            case "y":
            case "active":
            case "enabled":
            case "on":
                return true;
            case "0":
            case "false":
            case "no":
            case "n":
            case "inactive":
            case "disabled":
            case "off":
            case "":
                return false;
        }
        try { return Convert.ToBoolean(val); }
        catch { return false; }
    }

    // ════════════════════════════════════════════════════════════════
    // PAGE LOAD
    // ════════════════════════════════════════════════════════════════
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
                hdnEmployeeName.Value = GetEmployeeName(empID);
                empDisplay.InnerText = hdnEmployeeName.Value;

                CheckIfCashier(empID);
                LoadDepartments();
                LoadDeliveredBills();
                LoadTodaySalesData();
                UpdateBillCount();

                ViewState["DepartmentSelected"] = false;
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine("Casier Page_Load Error: " + ex.Message);
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

    private void CheckIfCashier(string empID)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(restaurantDB))
            {
                string query = @"SELECT COUNT(*) 
                                 FROM EmployeeRestaurantMap 
                                 WHERE Emp_ID = @EmpID AND Role = 'Cashier'";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@EmpID", empID);
                    con.Open();
                    int count = Convert.ToInt32(cmd.ExecuteScalar());
                    hdnIsManager.Value = count > 0 ? "True" : "False";
                }
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine("CheckIfCashier error: " + ex.Message);
            hdnIsManager.Value = "False";
        }
    }

    private void ShowAccessDenied(string message)
    {
        Response.Write("<script>alert('" + message + "'); window.location.href='http://192.168.12.40/Gymkhana';</script>");
        Response.End();
    }

    private void LoadDepartments()
    {
        if (Session["Emp_ID"] == null) return;
        int empID = Convert.ToInt32(Session["Emp_ID"]);
        try
        {
            using (SqlConnection con = new SqlConnection(restaurantDB))
            {
                string query = @"SELECT DISTINCT RestaurantName, SubDeptID
                                 FROM EmployeeRestaurantMap
                                 WHERE Emp_ID = @empID AND Role = 'Cashier'
                                 ORDER BY RestaurantName";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@empID", empID);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlDepartment.Items.Clear();
                ddlDepartment.DataSource = dt;
                ddlDepartment.DataTextField = "RestaurantName";
                ddlDepartment.DataValueField = "SubDeptID";
                ddlDepartment.DataBind();
                ddlDepartment.Items.Insert(0, new ListItem("All Departments", ""));
            }
        }
        catch (Exception ex)
        {
            Response.Write(ex.Message);
        }
    }

    // ════════════════════════════════════════════════════════════════
    // GENERATE BILL NO
    // Format: 260514-BBQT-0001  (yyMMdd-DeptAbbr-per-dept daily seq)
    // Duplicate-safe: loops until a unique candidate is found
    // ════════════════════════════════════════════════════════════════
    public static string GenerateBillNo(SqlConnection con, SqlTransaction trans,
                                        int billId, string deptCode)
    {
        string deptName = deptCode ?? "";
        try
        {
            using (SqlCommand nm = new SqlCommand(
                "SELECT TOP 1 DepartmentName FROM Bills WHERE Id = @id", con, trans))
            {
                nm.Parameters.AddWithValue("@id", billId);
                object dnObj = nm.ExecuteScalar();
                if (dnObj != null && dnObj != DBNull.Value)
                    deptName = dnObj.ToString();
            }
        }
        catch { }

        string deptAbbr = BuildDeptAbbr(deptName);
        string dateCode = DateTime.Now.ToString("yyMMdd");
        string prefix = dateCode + "-" + deptAbbr + "-";

        int maxAttempts = 200;
        for (int attempt = 1; attempt <= maxAttempts; attempt++)
        {
            string countSql = @"
                SELECT COUNT(*)
                FROM Bills
                WHERE CONVERT(DATE, ISNULL(PaymentDate, CreatedAt)) = CONVERT(DATE, GETDATE())
                  AND BillNo IS NOT NULL
                  AND BillNo LIKE @Prefix";

            int todayDeptCount;
            using (SqlCommand cnt = new SqlCommand(countSql, con, trans))
            {
                cnt.Parameters.AddWithValue("@Prefix", prefix + "%");
                todayDeptCount = Convert.ToInt32(cnt.ExecuteScalar());
            }

            int seq = todayDeptCount + attempt;
            string candidate = prefix + seq.ToString("D4");

            string existsSql = "SELECT COUNT(*) FROM Bills WHERE BillNo = @BN";
            using (SqlCommand ex = new SqlCommand(existsSql, con, trans))
            {
                ex.Parameters.AddWithValue("@BN", candidate);
                int exists = Convert.ToInt32(ex.ExecuteScalar());
                if (exists == 0)
                    return candidate;
            }
        }

        return dateCode + "-" + deptAbbr + "-" + billId.ToString("D4");
    }

    // ════════════════════════════════════════════════════════════════
    // BUILD DEPT ABBR
    // ════════════════════════════════════════════════════════════════
    private static string BuildDeptAbbr(string deptName)
    {
        if (string.IsNullOrWhiteSpace(deptName)) return "BR";

        string key = System.Text.RegularExpressions.Regex
            .Replace(deptName.Trim(), @"\s+", " ")
            .TrimEnd('.');

        try
        {
            string connStr = ConfigurationManager
                .ConnectionStrings["RestaurantConnectionString"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                string sql = @"SELECT TOP 1 Abbr 
                               FROM DepartmentAbbreviations 
                               WHERE DeptName = @DeptName";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@DeptName", key);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        return result.ToString();
                }
            }
        }
        catch { }

        var skip = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        { "and", "&", "the", "of", "at", "in", "section",
          "serving", "house", "keeping", "kitchen", "staff" };

        var words = key.Split(new[] { ' ', '-', '/', '.' },
            StringSplitOptions.RemoveEmptyEntries);

        string initials = string.Concat(
            words.Where(w => !skip.Contains(w))
                 .Take(4)
                 .Select(w => char.ToUpper(w[0])));

        string autoAbbr = string.IsNullOrEmpty(initials)
            ? key.Substring(0, Math.Min(4, key.Length)).ToUpper()
            : initials;

        try
        {
            string connStr = ConfigurationManager
                .ConnectionStrings["RestaurantConnectionString"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                string insertSql = @"
                IF NOT EXISTS (SELECT 1 FROM DepartmentAbbreviations WHERE DeptName = @DeptName)
                INSERT INTO DepartmentAbbreviations (DeptName, Abbr) 
                VALUES (@DeptName, @Abbr)";
                using (SqlCommand cmd = new SqlCommand(insertSql, con))
                {
                    cmd.Parameters.AddWithValue("@DeptName", key);
                    cmd.Parameters.AddWithValue("@Abbr", autoAbbr);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch { }

        return autoAbbr;
    }

    // ════════════════════════════════════════════════════════════════
    // LOAD DELIVERED BILLS
    // ════════════════════════════════════════════════════════════════
    private void LoadDeliveredBills()
    {
        try
        {
            string deptName = ddlDepartment.SelectedItem != null ? ddlDepartment.SelectedItem.Text : "All Departments";
            string searchFilter = txtSearchMember.Text.Trim();

            using (SqlConnection con = new SqlConnection(restaurantDB))
            {
                if (deptName == "All Departments" || string.IsNullOrEmpty(ddlDepartment.SelectedValue))
                {
                    rptBills.DataSource = null;
                    rptBills.DataBind();
                    lblBillCount.Text = "0";
                    lblPendingBills.Text = "0";
                    return;
                }

                string query = @"
                SELECT
                    MIN(b.Id)                                       AS Id,
                    b.MemberNo,
                    SUM(b.Total)                                    AS Total,
                    CASE WHEN MIN(CASE WHEN b.Status='Pending' THEN 0 ELSE 1 END) = 0
                         THEN 'Pending' ELSE 'Delivered' END        AS Status,
                    MIN(b.TableNumber)                              AS TableNumber,
                    b.DepartmentName,
                    MIN(b.DepartmentID)                             AS DepartmentID,
                    MIN(b.bill_to)                                  AS bill_to,
                    MIN(b.CreatedAt)                                AS CreatedAt,
                    STUFF((
                        SELECT ', ' + ISNULL(b2.KOT_Number, '#' + CAST(b2.Id AS VARCHAR))
                        FROM Bills b2
                        WHERE b2.MemberNo = b.MemberNo
                          AND b2.DepartmentName = b.DepartmentName
                          AND b2.Status IN ('Pending','Delivered')
                        FOR XML PATH(''), TYPE
                    ).value('.','NVARCHAR(MAX)'), 1, 2, '')         AS KOT_Number,
                    COUNT(*)                                        AS BillCount,
                    SUM(CASE WHEN b.Status='Delivered' THEN 1 ELSE 0 END) AS DeliveredCount,
                    NULL                                            AS BillNo,
                    ISNULL(MIN(TRY_CAST(b.Cover AS INT)), 1)        AS NumberOfCovers,
                    CASE WHEN MIN(b.bill_to) = 'Guest House'
                         THEN MIN(b.roomno) ELSE NULL END           AS RoomNumber
                FROM Bills b
                WHERE b.Status IN ('Pending', 'Delivered')
                  AND b.DepartmentName = @DeptName";

                if (!string.IsNullOrEmpty(searchFilter))
                    query += " AND b.MemberNo LIKE @SearchTerm";

                query += @"
                GROUP BY b.MemberNo, b.DepartmentName
                ORDER BY
                    CASE WHEN MIN(CASE WHEN b.Status='Pending' THEN 0 ELSE 1 END) = 1
                         THEN 0 ELSE 1 END ASC,
                    MIN(b.Id) DESC";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@DeptName", deptName);
                if (!string.IsNullOrEmpty(searchFilter))
                    cmd.Parameters.AddWithValue("@SearchTerm", "%" + searchFilter + "%");

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptBills.DataSource = dt;
                rptBills.DataBind();
                lblBillCount.Text = dt.Rows.Count.ToString();
                lblPendingBills.Text = dt.Rows.Count.ToString();
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine("LoadDeliveredBills error: " + ex.Message);
        }
    }

    private static void EnsurePaymentColumnsExist(SqlConnection con, SqlTransaction trans)
    {
        // All required columns already exist in the database.
    }

    // ════════════════════════════════════════════════════════════════
    // BADGE / DISPLAY HELPERS
    // ════════════════════════════════════════════════════════════════
    public string GetBillTypeBadge(string billTo)
    {
        switch (billTo)
        {
            case "Club Member": return "<span class='badge b-member'>Club Member</span>";
            case "Guest House": return "<span class='badge b-guest'>Guest House</span>";
            case "Affiliated Member": return "<span class='badge b-affiliated'>Affiliated Member</span>";
            default: return "<span class='badge b-default'>" + billTo + "</span>";
        }
    }

    public string GetStatusBadge(string status)
    {
        switch (status)
        {
            case "Delivered": return "<span class='sbadge sb-delivered'><i class='fas fa-check-circle'></i> Delivered</span>";
            case "Pending": return "<span class='sbadge sb-pending'><i class='fas fa-clock'></i> Pending</span>";
            default: return "<span class='sbadge'>" + status + "</span>";
        }
    }

    public string ShowRoomNumber(string billTo, object roomNumber)
    {
        if (billTo == "Guest House" && roomNumber != null && roomNumber != DBNull.Value)
            return "<div class='bf'><div class='lbl'>Room No</div><div class='val' style='color:#C55A11;font-weight:bold;'>Room #" + roomNumber + "</div></div>";
        return "";
    }

    public string ShowKOTNumber(object kotNumber)
    {
        if (kotNumber == null || kotNumber == DBNull.Value || string.IsNullOrEmpty(kotNumber.ToString()))
            return "";

        string kotStr = kotNumber.ToString();
        var kots = kotStr.Split(new[] { ", " }, StringSplitOptions.RemoveEmptyEntries);

        if (kots.Length > 1)
        {
            string pills = string.Join(" ", Array.ConvertAll(kots, k =>
                "<span style='background:#EEF3FF;color:#1845D4;padding:1px 6px;border-radius:10px;font-size:9.5px;font-weight:700;border:1px solid #C0CFFF;'>" + k.Trim() + "</span>"));
            return "<div class='bf'><div class='lbl'>KOTs <span style='background:#1845D4;color:white;padding:1px 5px;border-radius:8px;font-size:8px;'>" + kots.Length + "</span></div><div class='val kot' style='display:flex;flex-wrap:wrap;gap:3px;'>" + pills + "</div></div>";
        }
        return "<div class='bf'><div class='lbl'>KOT No</div><div class='val kot'>" + kotStr + "</div></div>";
    }

    public string ShowBillNo(object billNo)
    {
        if (billNo != null && billNo != DBNull.Value && !string.IsNullOrEmpty(billNo.ToString()))
            return "<div class='bf'><div class='lbl'>Bill No</div><div class='val billno'>" + billNo.ToString() + "</div></div>";
        return "";
    }

    public string ShowBillCount(object billCount, object deliveredCount)
    {
        int total = billCount != null && billCount != DBNull.Value ? Convert.ToInt32(billCount) : 1;
        int delivered = deliveredCount != null && deliveredCount != DBNull.Value ? Convert.ToInt32(deliveredCount) : 0;
        int pending = total - delivered;

        if (total <= 1) return "";

        string html = "<div class='bf'><div class='lbl'>Orders</div><div class='val' style='display:flex;gap:4px;align-items:center;'>";
        html += "<span style='background:#1845D4;color:white;padding:2px 8px;border-radius:100px;font-size:10px;font-weight:700;'>" + total + " KOTs</span>";
        if (delivered > 0)
            html += "<span style='background:#EDFAF4;color:#0D7A3E;padding:2px 6px;border-radius:100px;font-size:9px;font-weight:700;border:1px solid #A7F0C8;'>" + delivered + " ✓</span>";
        if (pending > 0)
            html += "<span style='background:#FFF8ED;color:#956008;padding:2px 6px;border-radius:100px;font-size:9px;font-weight:700;border:1px solid #FDE68A;'>" + pending + " ⏳</span>";
        html += "</div></div>";
        return html;
    }

    // ════════════════════════════════════════════════════════════════
    // UPDATE BILL COUNT
    // ════════════════════════════════════════════════════════════════
    private void UpdateBillCount()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(restaurantDB))
            {
                string deptName = ddlDepartment.SelectedItem != null ? ddlDepartment.SelectedItem.Text : "All Departments";
                string query;

                if (deptName == "All Departments" || string.IsNullOrEmpty(ddlDepartment.SelectedValue))
                    query = "SELECT COUNT(*) FROM Bills WHERE Status IN ('Pending', 'Delivered')";
                else
                    query = @"SELECT COUNT(DISTINCT MemberNo + '|' + DepartmentName)
                              FROM Bills 
                              WHERE Status IN ('Pending', 'Delivered')
                                AND DepartmentName = @DeptName";

                SqlCommand cmd = new SqlCommand(query, con);
                if (deptName != "All Departments" && !string.IsNullOrEmpty(ddlDepartment.SelectedValue))
                    cmd.Parameters.AddWithValue("@DeptName", deptName);

                con.Open();
                int count = (int)cmd.ExecuteScalar();
                lblBillCount.Text = count.ToString();
                lblPendingBills.Text = count.ToString();
            }
        }
        catch (Exception ex) { Debug.WriteLine("UpdateBillCount error: " + ex.Message); }
    }

    // ════════════════════════════════════════════════════════════════
    // LOAD TODAY SALES DATA
    // ════════════════════════════════════════════════════════════════
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
                        ISNULL(SUM(CASE WHEN PaymentMethod = 'Member Card' THEN Total ELSE 0 END),0) AS MemberCardTotal,
                        ISNULL(SUM(CASE WHEN PaymentMethod = 'Cash' THEN Total ELSE 0 END),0) AS CashTotal,
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
                    lblTodayCard.Text = "Rs " + string.Format("{0:0.00}", dr["CardTotal"]);
                    lblTodayMemberCard.Text = "Rs " + string.Format("{0:0.00}", dr["MemberCardTotal"]);
                    lblTodayCash.Text = "Rs " + string.Format("{0:0.00}", dr["CashTotal"]);
                    lblTodayBills.Text = dr["BillCount"].ToString();
                }
                dr.Close();
            }
        }
        catch
        {
            lblTodaySales.Text = "Rs 0.00";
            lblTodayCard.Text = "Rs 0.00";
            lblTodayMemberCard.Text = "Rs 0.00";
            lblTodayCash.Text = "Rs 0.00";
            lblTodayBills.Text = "0";
            lblPendingBills.Text = "0";
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

    // ════════════════════════════════════════════════════════════════
    // DROPDOWN / SEARCH / REPEATER EVENTS
    // ════════════════════════════════════════════════════════════════
    protected void ddlDepartment_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(ddlDepartment.SelectedValue))
        {
            hdnDepartmentId.Value = ddlDepartment.SelectedValue;
            hdnDepartmentName.Value = ddlDepartment.SelectedItem.Text;
            ViewState["DepartmentSelected"] = true;
        }
        else
        {
            hdnDepartmentId.Value = "";
            hdnDepartmentName.Value = "";
            ViewState["DepartmentSelected"] = false;
        }
        LoadDeliveredBills();
        LoadTodaySalesData();
        UpdateBillCount();
    }

    protected void txtSearchMember_TextChanged(object sender, EventArgs e)
    {
        LoadDeliveredBills();
        LoadTodaySalesData();
    }

    protected void rptBills_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        string deptId = ddlDepartment.SelectedValue;
        string deptName = ddlDepartment.SelectedItem != null ? ddlDepartment.SelectedItem.Text : hdnDepartmentName.Value;
        hdnDepartmentId.Value = deptId;
        hdnDepartmentName.Value = deptName;

        if (e.CommandName == "GHPay")
        {
            string[] args = e.CommandArgument.ToString().Split('|');
            if (args.Length >= 4)
            {
                string billId = args[0];
                string memberNo = args[1];
                string total = args[2];
                string billTo = args[3];
                string roomNo = args.Length > 4 ? args[4] : "";
                string kotNo = args.Length > 5 ? args[5] : "";
                string billNo = args.Length > 6 ? args[6] : "";
                string numberOfCovers = args.Length > 7 ? args[7] : "1";

                string itemsJson = GetBillItemsByBillId(billId);

                ScriptManager.RegisterStartupScript(this, GetType(), "ShowGHPayModal",
                    "showPaymentModalDirect('" + billId + "','" + memberNo + "','" + total + "'," +
                    itemsJson + ",'" + billTo + "','" + roomNo + "','" + kotNo + "','" + billNo +
                    "','" + numberOfCovers + "','" + deptId.Replace("'", "\\'") + "','" + deptName.Replace("'", "\\'") + "');", true);
            }
        }
        else if (e.CommandName == "Pay")
        {
            string[] args = e.CommandArgument.ToString().Split('|');
            if (args.Length >= 4)
            {
                string billId = args[0];
                string memberNo = args[1];
                string total = args[2];
                string billTo = args[3];
                string kotNo = args.Length > 4 ? args[4] : "";
                string billNo = args.Length > 5 ? args[5] : "";
                string numberOfCovers = args.Length > 6 ? args[6] : "1";

                string itemsJson = GetBillItemsByBillId(billId);

                ScriptManager.RegisterStartupScript(this, GetType(), "ShowPaymentModalDirect",
                    "showPaymentModalDirect('" + billId + "','" + memberNo + "','" + total + "'," +
                    itemsJson + ",'" + billTo + "','','" + kotNo + "','" + billNo +
                    "','" + numberOfCovers + "','" + deptId.Replace("'", "\\'") + "','" + deptName.Replace("'", "\\'") + "');", true);
            }
        }
    }

    private string GetBillItemsByBillId(string billId)
    {
        StringBuilder json = new StringBuilder();
        json.Append("[");
        try
        {
            using (SqlConnection con = new SqlConnection(restaurantDB))
            {
                string query = @"
                    SELECT 
                        bs.Name,
                        bs.Quantity,
                        bs.Price,
                        (bs.Price * bs.Quantity)  AS ItemTotal,
                        b.Total                   AS GrandTotal,
                        b.KOT_Number,
                        b.BillNo,
                        b.Cover                   AS NumberOfCovers,
                        ISNULL(rc.ItemCode, '')   AS ItemCode
                    FROM Bills b
                    INNER JOIN BillItems bs          ON bs.BillId = b.Id
                    LEFT  JOIN Restaurant_Catalog rc  ON rc.ItemName = bs.Name
                    WHERE b.Id = @BillId";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@BillId", billId);
                con.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                bool first = true;
                while (reader.Read())
                {
                    if (!first) json.Append(",");
                    string name = reader["Name"].ToString().Replace("\"", "\\\"").Replace("'", "\\'");
                    string itemCode = reader["ItemCode"].ToString();
                    string kotNum = reader["KOT_Number"] != DBNull.Value ? reader["KOT_Number"].ToString() : "";
                    string bNo = reader["BillNo"] != DBNull.Value ? reader["BillNo"].ToString() : "";

                    json.Append("{");
                    json.AppendFormat("\"Name\":\"{0}\",", name);
                    json.AppendFormat("\"ItemCode\":\"{0}\",", itemCode);
                    json.AppendFormat("\"Quantity\":{0},", Convert.ToDecimal(reader["Quantity"]));
                    json.AppendFormat("\"Price\":{0},", Convert.ToDecimal(reader["Price"]));
                    json.AppendFormat("\"ItemTotal\":{0},", Convert.ToDecimal(reader["ItemTotal"]));
                    json.AppendFormat("\"GrandTotal\":{0},", Convert.ToDecimal(reader["GrandTotal"]));
                    json.AppendFormat("\"KOT_Number\":\"{0}\",", kotNum);
                    json.AppendFormat("\"BillNo\":\"{0}\"", bNo);
                    json.Append("}");
                    first = false;
                }
                reader.Close();
            }
        }
        catch { return "[]"; }
        json.Append("]");
        return json.ToString();
    }

    // ════════════════════════════════════════════════════════════════
    // COUNTER CLOSE
    // ════════════════════════════════════════════════════════════════
    protected void btnGoCounterClose_Click(object sender, EventArgs e)
    {
        string empId = hdnEmpID.Value;
        string empName = hdnEmployeeName.Value;

        // ✅ FIX: hdnDepartmentName ki bajaye ddlDepartment se seedha lo
        string deptName = "";
        if (ddlDepartment.SelectedItem != null && !string.IsNullOrEmpty(ddlDepartment.SelectedValue))
        {
            deptName = ddlDepartment.SelectedItem.Text;
        }

        if (!string.IsNullOrEmpty(deptName))
        {
            try
            {
                using (SqlConnection con = new SqlConnection(restaurantDB))
                {
                    string checkQuery = @"
                    SELECT COUNT(*) 
                    FROM Bills 
                    WHERE Status IN ('Pending','Delivered')
                      AND DepartmentName = @DeptName";
                    SqlCommand checkCmd = new SqlCommand(checkQuery, con);
                    checkCmd.Parameters.AddWithValue("@DeptName", deptName);
                    con.Open();
                    int activeCount = Convert.ToInt32(checkCmd.ExecuteScalar());
                    if (activeCount > 0)
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "BlockCounterClose",
                            "alert('⚠️ Cannot close counter!\\n\\nThere are " + activeCount +
                            " active order(s) still pending/delivered but not yet paid in " +
                            deptName.Replace("'", "\\'") +
                            ".\\n\\nPlease finalize all outstanding bills before closing the counter.');", true);
                        return;
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("Counter close check error: " + ex.Message);
            }
        }
        else
        {
            // ✅ Agar koi department select nahi toh block kar do
            ScriptManager.RegisterStartupScript(this, GetType(), "NoDept",
                "alert('Please select a department before closing the counter.');", true);
            return;
        }

        Session["CC_CashierName"] = empName;
        Session["CC_OpenTime"] = Session["CC_OpenTime"] ?? DateTime.Now;
        Session["CC_EmpID"] = empId;
        Session["CC_DeptName"] = deptName;  // ✅ Ab sahi value aayegi

        Response.Redirect("Counterclose.aspx");
    }

    // ════════════════════════════════════════════════════════════════
    // WEB METHOD — GetMemberAllKOTs
    // ════════════════════════════════════════════════════════════════
    [WebMethod]
    public static object GetMemberAllKOTs(string memberNo, string departmentId)
    {
        try
        {
            string restaurantDB = ConfigurationManager
                .ConnectionStrings["RestaurantConnectionString"].ConnectionString;

            using (SqlConnection con = new SqlConnection(restaurantDB))
            {
                con.Open();

                string billsQuery = @"
                    SELECT 
                        b.Id          AS BillId,
                        b.Total,
                        b.MemberNo,
                        b.Status,
                        b.KOT_Number,
                        b.TableNumber,
                        b.DepartmentName,
                        b.DepartmentID,
                        b.bill_to,
                        b.CreatedAt,
                        ISNULL(b.BillNo, '')                       AS BillNo,
                        ISNULL(TRY_CAST(b.Cover AS INT), 1)        AS NumberOfCovers,
                        ISNULL(b.TaxApplied, 0)                    AS TaxApplied,
                        ISNULL(b.DiscountApplied, 0)               AS DiscountApplied,
                        ISNULL(b.Subtotal, 0)                      AS Subtotal,
                        CASE WHEN b.bill_to='Guest House' THEN b.roomno ELSE NULL END AS RoomNo,
                        FORMAT(b.CreatedAt, 'hh:mm tt')            AS OrderTime
                    FROM Bills b
                    WHERE b.MemberNo = @MemberNo
                      AND (b.DepartmentID = @DepartmentId OR b.DepartmentName = @DepartmentId)
                      AND b.Status IN ('Pending', 'Delivered')
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
                    decimal subtotal = Convert.ToDecimal(billsRdr["Subtotal"]);
                    string kotNo = billsRdr["KOT_Number"] != DBNull.Value ? billsRdr["KOT_Number"].ToString() : "";
                    string status = billsRdr["Status"].ToString();
                    string billTo = billsRdr["bill_to"] != DBNull.Value ? billsRdr["bill_to"].ToString() : "";
                    string tableNo = billsRdr["TableNumber"] != DBNull.Value ? billsRdr["TableNumber"].ToString() : "";
                    string roomNo = billsRdr["RoomNo"] != DBNull.Value ? billsRdr["RoomNo"].ToString() : "";
                    string createdAt = billsRdr["CreatedAt"] != DBNull.Value
                                            ? Convert.ToDateTime(billsRdr["CreatedAt"]).ToString("dd/MM/yy hh:mm tt") : "";
                    string orderTime = billsRdr["OrderTime"] != DBNull.Value ? billsRdr["OrderTime"].ToString() : "";
                    string billNo = billsRdr["BillNo"].ToString();
                    int covers = Convert.ToInt32(billsRdr["NumberOfCovers"]);

                    bills.Add(new
                    {
                        billId,
                        total,
                        taxApplied,
                        discountApplied,
                        subtotal,
                        kotNo,
                        status,
                        billTo,
                        tableNo,
                        roomNo,
                        createdAt,
                        orderTime,
                        billNo,
                        covers
                    });
                    billIds.Add(billId);
                    grandTotal += total;
                }
                billsRdr.Close();

                if (bills.Count == 0)
                    return new { success = false, message = "No active bills found for this member in the selected department." };

                List<object> items = new List<object>();

                if (billIds.Count > 0)
                {
                    string idList = string.Join(",", billIds);
                    string itemsQuery = @"
                        SELECT 
                            bs.Id                         AS ItemId,
                            bs.BillId,
                            bs.Name,
                            bs.Quantity,
                            bs.Price,
                            (bs.Price * bs.Quantity)      AS ItemTotal,
                            b.KOT_Number,
                            b.TableNumber,
                            b.Status                      AS BillStatus,
                            ISNULL(b.BillNo, '')          AS BillNo,
                            ISNULL(rc.ItemCode, '')       AS ItemCode
                        FROM BillItems bs
                        INNER JOIN Bills b               ON b.Id = bs.BillId
                        LEFT  JOIN Restaurant_Catalog rc  ON rc.ItemName = bs.Name
                        WHERE bs.BillId IN (" + idList + @")
                        ORDER BY b.CreatedAt ASC, bs.Id ASC";

                    SqlCommand itemsCmd = new SqlCommand(itemsQuery, con);
                    SqlDataReader itemsRdr = itemsCmd.ExecuteReader();

                    while (itemsRdr.Read())
                    {
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
                    }
                    itemsRdr.Close();
                }

                return new
                {
                    success = true,
                    bills,
                    items,
                    grandTotal,
                    memberNo,
                    billCount = bills.Count,
                    billIds = billIds.ToArray(),
                    message = string.Format("Found {0} KOT(s) for member {1}", bills.Count, memberNo)
                };
            }
        }
        catch (Exception ex)
        {
            return new { success = false, message = "Error: " + ex.Message };
        }
    }

    // ════════════════════════════════════════════════════════════════
    // WEB METHOD — ProcessConsolidatedPayment
    //
    // KEY FIX: GenerateBillNo is called ONCE before the loop using
    // billIds[0] for dept lookup. The SAME BillNo is then stamped on
    // ALL KOTs in this consolidated payment — no more duplicate BillNos.
    // ════════════════════════════════════════════════════════════════
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
            string membershipDB = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;
            string restaurantDB = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            string guestRoomDB = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

            string empID = "0";
            if (HttpContext.Current.Session["Emp_ID"] != null)
                empID = HttpContext.Current.Session["Emp_ID"].ToString();
            string empName = GetEmployeeNameStatic(empID);

            string finalStatus = ghPayment ? "GH" : "Paid";
            string ledgerError = "";
           
            using (SqlConnection conR = new SqlConnection(restaurantDB))
            using (SqlConnection conM = new SqlConnection(membershipDB))
            {
                conR.Open(); conM.Open();
                SqlTransaction trans = conR.BeginTransaction();

                try
                {
                    decimal billTotal = totalAmount;
                    decimal finalAmount = billTotal - discountAmount;

                    // ── Pull tax / subtotal totals for all bills ──────────────
                    decimal taxAmt = 0, subtotal = 0;
                    if (billIds != null && billIds.Length > 0)
                    {
                        string idList = string.Join(",", billIds);
                        string taxQuery = @"SELECT ISNULL(SUM(TaxApplied),0) AS TotalTax,
                                                   ISNULL(SUM(Subtotal),0)   AS TotalSubtotal
                                            FROM Bills WHERE Id IN (" + idList + ")";
                        SqlCommand taxCmd = new SqlCommand(taxQuery, conR, trans);
                        using (SqlDataReader taxRdr = taxCmd.ExecuteReader())
                        {
                            if (taxRdr.Read())
                            {
                                taxAmt = Convert.ToDecimal(taxRdr["TotalTax"]);
                                subtotal = Convert.ToDecimal(taxRdr["TotalSubtotal"]);
                            }
                        }
                    }

                    decimal? updatedBalance = null;
                    string roomNo = "";
                    string kotNos = "";
                    int subDeptId = 0;
                    string reservationNo = "";

                    if (billIds != null && billIds.Length > 0)
                    {
                        string idList2 = string.Join(",", billIds);
                        string roomQuery = @"SELECT TOP 1
                                                RIGHT('000' + CAST(ISNULL(roomno, 0) AS NVARCHAR(10)), 3) AS RoomNo,
                                                ISNULL(DepartmentID, 0)       AS DeptID,
                                                ISNULL(KOT_Number, '')        AS KotNo,
                                                ISNULL(ReservationNo, '')     AS ReservationNo
                                             FROM Bills
                                             WHERE Id IN (" + idList2 + ")";
                        SqlCommand roomCmd = new SqlCommand(roomQuery, conR, trans);
                        using (SqlDataReader roomRdr = roomCmd.ExecuteReader())
                        {
                            if (roomRdr.Read())
                            {
                                roomNo = roomRdr["RoomNo"].ToString().Trim();
                                subDeptId = Convert.ToInt32(roomRdr["DeptID"]);
                                kotNos = roomRdr["KotNo"].ToString();
                                reservationNo = roomRdr["ReservationNo"].ToString().Trim();
                            }
                        }
                    }

                    // ── MEMBER CARD ──────────────────────────────────────────
                    if (paymentType == "MemberCard")
                    {
                        string checkMemberQuery = @"
                            SELECT mc.MemberNo, mc.MemberName, mc.RFID,
                                   ISNULL(SUM(mp.Dept),0)   AS TotalDept,
                                   ISNULL(SUM(mp.Credit),0) AS TotalCredit,
                                   (ISNULL(SUM(mp.Dept),0) - ISNULL(SUM(mp.Credit),0)) AS Balance
                            FROM MemberProfile mc
                            LEFT JOIN MemberPayment mp ON mp.MemberNo = mc.MemberNo
                            WHERE mc.RFID = @CardNo OR mc.MemberNo = @MemberNo
                            GROUP BY mc.MemberNo, mc.MemberName, mc.RFID";

                        SqlCommand checkCmd = new SqlCommand(checkMemberQuery, conM);
                        checkCmd.Parameters.AddWithValue("@CardNo", cardNumber.Trim());
                        checkCmd.Parameters.AddWithValue("@MemberNo", memberNo.Trim());
                        using (SqlDataReader reader = checkCmd.ExecuteReader())
                        {
                            if (!reader.Read())
                            {
                                trans.Rollback();
                                return new { success = false, message = "Invalid Member Card. Member not found." };
                            }
                        }

                        DataTable billDetails = new DataTable();
                        using (SqlDataAdapter adapter = new SqlDataAdapter(
                            new SqlCommand("SELECT Id, BillNo, Total FROM Bills WHERE Id IN (" + string.Join(",", billIds) + ")", conR, trans)))
                            adapter.Fill(billDetails);

                        string insertPaymentQuery = @"
                            DECLARE @MemberPaymentId INT;
                            INSERT INTO MemberPayment (MemberNo, Date, Description, Dept, Credit)
                            VALUES (@MemberNo, GETDATE(), @Description, @Amount, 0);
                            SET @MemberPaymentId = SCOPE_IDENTITY();";

                        foreach (DataRow bill in billDetails.Rows)
                        {
                            int bid2 = Convert.ToInt32(bill["Id"]);
                            string billNo2 = bill["BillNo"].ToString().Replace("'", "''");
                            decimal billAmt = Convert.ToDecimal(bill["Total"]);
                            decimal billDisc = 0, discBill = billAmt;
                            if (discountAmount > 0 && totalAmount > 0)
                            { billDisc = discountAmount * (billAmt / totalAmount); discBill = billAmt - billDisc; }

                            insertPaymentQuery += @"
                            INSERT INTO MemberPaymentDetails
                                (MemberPaymentId, MemberNo, BillId, BillNo, Amount, DiscountAmount, FinalAmount,
                                 PaymentDate, DepartmentId, PaymentMethod, CardNumber, ApprovalCode)
                            VALUES (@MemberPaymentId, @MemberNo, " + bid2 + ", '" + billNo2 + "', "
                                + billAmt.ToString(System.Globalization.CultureInfo.InvariantCulture) + ", "
                                + billDisc.ToString(System.Globalization.CultureInfo.InvariantCulture) + ", "
                                + discBill.ToString(System.Globalization.CultureInfo.InvariantCulture) + @",
                                 GETDATE(), @DepartmentId, @PaymentMethod, @CardNumber, @ApprovalCode);";
                        }

                        insertPaymentQuery += @"
                            SELECT (ISNULL(SUM(mp.Dept),0) - ISNULL(SUM(mp.Credit),0)) AS Balance
                            FROM MemberProfile mc
                            LEFT JOIN MemberPayment mp ON mp.MemberNo = mc.MemberNo
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
                        { if (balRdr.Read()) updatedBalance = Convert.ToDecimal(balRdr["Balance"]); }
                    }

                    // ── BANK CARD ────────────────────────────────────────────
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
                            if (discountAmount > 0 && totalAmount > 0)
                            { billDisc = discountAmount * (billAmt / totalAmount); discBill = billAmt - billDisc; }

                            insertBKQuery += @"
                            INSERT INTO MemberPaymentDetails
                                (MemberPaymentId, MemberNo, BillId, BillNo, Amount, DiscountAmount, FinalAmount,
                                 PaymentDate, DepartmentId, PaymentMethod, CardNumber, ApprovalCode)
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
                        {
                            ledgerError = InsertGuestLedgerSafe(
                                guestRoomDB, roomNo, reservationNo,
                                "Bank Card payment (GH) for KOT: " + kotNos + " | Bills #" + string.Join(", #", billIds) + " | Cashier: " + empName,
                                debit: 0m, credit: 0m,
                                subDeptId: subDeptId,
                                refNo: string.Join(",", billIds),
                                createdBy: empName);
                        }

                        updatedBalance = null;
                    }

                    // ── GH PAYMENT ───────────────────────────────────────────
                    else if (paymentType == "GH")
                    {
                        ledgerError = InsertGuestLedgerSafe(
                            guestRoomDB, roomNo, reservationNo,
                            "GH Restaurant charge for KOT: " + kotNos + " | Bills #" + string.Join(", #", billIds) + " | Cashier: " + empName,
                            debit: finalAmount, credit: finalAmount,
                            subDeptId: subDeptId,
                            refNo: string.Join(",", billIds),
                            createdBy: empName);
                    }

                    // ════════════════════════════════════════════════════════
                    // DISTRIBUTE TAX + DISCOUNT INTO BillItems
                    // ════════════════════════════════════════════════════════
                    foreach (int bid in billIds)
                    {
                        decimal billAmt2 = 0, billTax = 0;

                        using (SqlCommand gt = new SqlCommand(
                            "SELECT ISNULL(Total,0), ISNULL(TaxApplied,0) FROM Bills WHERE Id = @id",
                            conR, trans))
                        {
                            gt.Parameters.AddWithValue("@id", bid);
                            using (SqlDataReader gr = gt.ExecuteReader())
                            {
                                if (gr.Read())
                                {
                                    billAmt2 = gr.GetDecimal(0);
                                    billTax = gr.GetDecimal(1);
                                }
                            }
                        }

                        if (billAmt2 <= 0) continue;

                        decimal billDiscount2 = 0;
                        if (discountAmount > 0 && totalAmount > 0)
                            billDiscount2 = Math.Round(discountAmount * (billAmt2 / totalAmount), 2);

                        DataTable itemRows = new DataTable();
                        using (SqlDataAdapter ia = new SqlDataAdapter(
                            new SqlCommand(
                                "SELECT Id, (Price * Quantity) AS LineTotal FROM BillItems WHERE BillId = @bid",
                                conR, trans)))
                        {
                            ia.SelectCommand.Parameters.AddWithValue("@bid", bid);
                            ia.Fill(itemRows);
                        }

                        if (itemRows.Rows.Count == 0) continue;

                        decimal lineSum = 0;
                        foreach (DataRow ir in itemRows.Rows)
                            lineSum += Convert.ToDecimal(ir["LineTotal"]);

                        if (lineSum <= 0) continue;

                        decimal taxDistributed = 0;
                        decimal discountDistributed = 0;

                        for (int i = 0; i < itemRows.Rows.Count; i++)
                        {
                            DataRow ir = itemRows.Rows[i];
                            int itemId = Convert.ToInt32(ir["Id"]);
                            decimal lineAmt = Convert.ToDecimal(ir["LineTotal"]);
                            bool isLast = (i == itemRows.Rows.Count - 1);

                            decimal itemTax;
                            if (isLast) itemTax = billTax - taxDistributed;
                            else itemTax = Math.Round(billTax * (lineAmt / lineSum), 2);
                            taxDistributed += itemTax;

                            decimal itemDiscount;
                            if (isLast) itemDiscount = billDiscount2 - discountDistributed;
                            else itemDiscount = Math.Round(billDiscount2 * (lineAmt / lineSum), 2);
                            discountDistributed += itemDiscount;

                            using (SqlCommand ut = new SqlCommand(@"
                                UPDATE BillItems SET
                                    TaxApplied     = @Tax,
                                    DiscountAmount = @Disc
                                WHERE Id = @ItemId", conR, trans))
                            {
                                ut.Parameters.AddWithValue("@Tax", itemTax);
                                ut.Parameters.AddWithValue("@Disc", itemDiscount);
                                ut.Parameters.AddWithValue("@ItemId", itemId);
                                ut.ExecuteNonQuery();
                            }
                        }
                    }

                    // ════════════════════════════════════════════════════════
                    // UPDATE BILLS
                    //
                    // *** THE FIX ***
                    // GenerateBillNo is called ONCE before the loop using
                    // billIds[0] for dept lookup.
                    // The SAME generatedBillNo is stamped on ALL KOTs —
                    // this prevents duplicate BillNos on consolidated payments.
                    // ════════════════════════════════════════════════════════
                    Casier c = new Casier();
                    string maskedCard = c.MaskCardNumber(cardNumber);

                    // ── Generate ONE BillNo for the entire consolidated payment ──
                    string generatedBillNo = GenerateBillNo(conR, trans, billIds[0], deptCode);

                    foreach (int bid in billIds)
                    {
                        SqlCommand ub = new SqlCommand(@"
                            UPDATE Bills SET
                                Status          = @ST,
                                PaymentMethod   = @PM,
                                PaymentDate     = GETDATE(),
                                AmountPaid      = @AP,
                                CardNumber      = @CN,
                                CardExpiry      = @CE,
                                CardHolderName  = @CHN,
                                DiscountApplied = @DA,
                                FinalAmount     = @FA,
                                OfferId         = @OI,
                                ApprovalCode    = @AC,
                                BillNo          = @BN,
                                CashierName     = @CSH
                            WHERE Id = @BillId AND Status IN ('Pending','Delivered')", conR, trans);

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
                        ub.Parameters.AddWithValue("@BN", generatedBillNo);   // ← SAME BillNo for all KOTs
                        ub.Parameters.AddWithValue("@CSH", empName);
                        ub.ExecuteNonQuery();
                    }

                    // ── OFFER USAGE TRACKING ──────────────────────────────────
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

                    // ── CASHIER LOG ───────────────────────────────────────────
                    foreach (int bid in billIds)
                    {
                        SqlCommand lc = new SqlCommand(@"
                            INSERT INTO CasierLog
                                (BillId,Action_Type,Emp_ID,Emp_Name,KOT_Number,Payment_Method,Amount,Status,Remarks,CreatedAt)
                            SELECT @BillId,'ConsolidatedPayment',@EID,@EN,KOT_Number,@PM,Total,@ST,@REM,GETDATE()
                            FROM Bills WHERE Id=@BillId", conR, trans);
                        lc.Parameters.AddWithValue("@BillId", bid);
                        lc.Parameters.AddWithValue("@EID", empID);
                        lc.Parameters.AddWithValue("@EN", empName);
                        lc.Parameters.AddWithValue("@PM", paymentMethod);
                        lc.Parameters.AddWithValue("@ST", finalStatus);
                        lc.Parameters.AddWithValue("@REM",
                            "Consolidated — Member:" + memberNo +
                            (ghPayment ? " | GH" : "") +
                            (discountAmount > 0 ? " | Disc:Rs " + discountAmount : "") +
                            " | BillNo:" + generatedBillNo);
                        lc.ExecuteNonQuery();
                    }
                    
                    trans.Commit();

                    string successMsg = "Payment processed for " + billIds.Length + " bill(s)." +
                                        (ghPayment ? " (GH)" : "");
                    if (!string.IsNullOrEmpty(ledgerError))
                        successMsg += "\n⚠️ GR Ledger warning: " + ledgerError;

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



    [WebMethod]
    public static string GetMobileNumber(string memberNo)
    {
        string mobileNo = "";

        string url = @"Dear Valued Member,

Thank you for choosing Cafe 9. We truly appreciate your visit and hope you enjoyed your dining experience with us.

Your support means a lot to us, and we look forward to welcoming you again soon.

Thank you for being a valued member of Gymkhana.

Best Regards,";

        string conString = ConfigurationManager
                            .ConnectionStrings["MemberShipConnection"]
                            .ConnectionString;

        try
        {
            using (SqlConnection con = new SqlConnection(conString))
            {
                string query = @"SELECT Mobile
                                 FROM MemberShip.dbo.MemberProfile
                                 WHERE MemberNo = @MemberNo";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@MemberNo", memberNo);

                    con.Open();
                    object result = cmd.ExecuteScalar();

                    if (result != null)
                        mobileNo = result.ToString();
                }
            }

            if (!string.IsNullOrEmpty(mobileNo) && mobileNo.Length >= 11)
            {
                MessageSystem(memberNo, mobileNo, "Message", url,
                    "Message Send", false, "", false);

                return "Message Sent Successfully";
            }
            else
            {
                MessageSystem(memberNo, mobileNo, "Invalid", url,
                    "Invalid Number", true, "", true);

                return "Invalid Mobile Number";
            }
        }
        catch (Exception ex)
        {
            return "Error: " + ex.Message;
        }
    }

    public static string MessageSystem(
    string Name,
    string Number,
    string Caption,
    string Message,
    string Remarks,
    bool Type,
    string FilePath,
    bool status)
    {
        string con_path = ConfigurationManager
                            .ConnectionStrings["MemberShipConnection"]
                            .ConnectionString;

        string result = "";

        try
        {
            using (SqlConnection connection = new SqlConnection(con_path))
            {
                using (SqlCommand command = new SqlCommand("sp_Insert_FileMessage", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@Name", Name);
                    command.Parameters.AddWithValue("@Number", Number);
                    command.Parameters.AddWithValue("@Caption", Caption);
                    command.Parameters.AddWithValue("@Message", Message);
                    command.Parameters.AddWithValue("@Remarks", Remarks);
                    command.Parameters.AddWithValue("@Type", Type);
                    command.Parameters.AddWithValue("@FilePath", FilePath);
                    command.Parameters.AddWithValue("@status", status);

                    connection.Open();
                    command.ExecuteNonQuery();
                }
            }

            result = "Record inserted successfully.";
        }
        catch (SqlException ex)
        {
            result = ex.Message;
        }
        catch (Exception ex)
        {
            result = ex.Message;
        }

        return result;
    }








    // ════════════════════════════════════════════════════════════════
    // GUEST LEDGER HELPERS
    // ════════════════════════════════════════════════════════════════
    private static string InsertGuestLedgerSafe(
        string guestRoomConnStr,
        string roomNo, string reservationNo, string description,
        decimal debit, decimal credit,
        int subDeptId, string refNo, string createdBy)
    {
        try
        {
            using (SqlConnection conGR = new SqlConnection(guestRoomConnStr))
            {
                conGR.Open();
                SqlCommand grCmd = new SqlCommand(@"
                    INSERT INTO GR_GuestLedger
                        (TransDate, ReservationNo, RoomNo, RefNo, Description,
                         Debit, Credit, EntryDate, CreatedBy, SubDeptID)
                    VALUES
                        (GETDATE(), @ReservationNo, @RoomNo, @RefNo, @Description,
                         @Debit, @Credit, GETDATE(), @CreatedBy, @SubDeptID)", conGR);

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
        catch (Exception ex)
        {
            Debug.WriteLine("InsertGuestLedgerSafe error: " + ex.Message);
            return ex.Message;
        }
    }

    private static void InsertGuestLedger(
        string guestRoomConnStr,
        string roomNo, string reservationNo,
        string description,
        decimal debit, decimal credit,
        int subDeptId, string refNo, string createdBy)
    {
        try
        {
            using (SqlConnection conGR = new SqlConnection(guestRoomConnStr))
            {
                conGR.Open();
                string insertGR = @"
                    INSERT INTO GR_GuestLedger
                        (TransDate, ReservationNo, RoomNo, RefNo, Description, Debit, Credit, EntryDate, CreatedBy, SubDeptID)
                    VALUES
                        (GETDATE(), @ReservationNo, @RoomNo, @RefNo, @Description, @Debit, @Credit, GETDATE(), @CreatedBy, @SubDeptID)";

                SqlCommand grCmd = new SqlCommand(insertGR, conGR);
                grCmd.Parameters.AddWithValue("@ReservationNo", (object)reservationNo ?? DBNull.Value);
                grCmd.Parameters.AddWithValue("@RoomNo", (object)roomNo ?? DBNull.Value);
                grCmd.Parameters.AddWithValue("@RefNo", (object)refNo ?? DBNull.Value);
                grCmd.Parameters.AddWithValue("@Description", (object)description ?? DBNull.Value);
                grCmd.Parameters.AddWithValue("@Debit", debit);
                grCmd.Parameters.AddWithValue("@Credit", credit);
                grCmd.Parameters.AddWithValue("@CreatedBy", (object)createdBy ?? DBNull.Value);
                grCmd.Parameters.AddWithValue("@SubDeptID", subDeptId > 0 ? (object)subDeptId : DBNull.Value);
                grCmd.ExecuteNonQuery();
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine("InsertGuestLedger error: " + ex.Message);
        }
    }

    // ════════════════════════════════════════════════════════════════
    // WEB METHOD — ValidateMemberCard
    // ════════════════════════════════════════════════════════════════
    [WebMethod]
    public static object ValidateMemberCard(string cardNumber)
    {
        try
        {
            string membershipConnStr = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;

            ScanRFID scanner = new ScanRFID(membershipConnStr);
            DataTable dt = scanner.CheckRFID(cardNumber);

            if (dt.Rows.Count == 0)
                return new { success = false, message = "Member not found. Please check the card number." };

            DataRow rd = dt.Rows[0];

            bool isActive = SafeBool(rd["IsActive"]);
            bool isCardActive = SafeBool(rd["IsCardActive"]);
            string status = rd["Status"] != DBNull.Value ? rd["Status"].ToString().Trim().ToLower() : "";

            if (!isActive || !isCardActive || (status != "active" && status != "absentee"))
            {
                string reason = !isActive ? "deactivated"
                              : !isCardActive ? "card deactivated"
                              : "status: " + status;

                return new
                {
                    success = false,
                    message = "Member account is " + reason + ". Please contact the membership office.",
                    status = new { isActive, isCardActive, status }
                };
            }

            string memberNo = "";
            if (rd.Table.Columns.Contains("MemberNo") && rd["MemberNo"] != DBNull.Value)
                memberNo = rd["MemberNo"].ToString();

            decimal balance = 0m, totalDept = 0m, totalCredit = 0m;

            using (SqlConnection conM = new SqlConnection(membershipConnStr))
            {
                conM.Open();
                string balQuery = @"
                SELECT 
                    ISNULL(SUM(mp.Dept), 0)   AS TotalDept,
                    ISNULL(SUM(mp.Credit), 0) AS TotalCredit,
                    (ISNULL(SUM(mp.Dept), 0) - ISNULL(SUM(mp.Credit), 0)) AS Balance
                FROM MemberProfile mc
                LEFT JOIN MemberPayment mp ON mp.MemberNo = mc.MemberNo
                WHERE mc.MemberNo = @MemberNo
                GROUP BY mc.MemberNo";

                using (SqlCommand balCmd = new SqlCommand(balQuery, conM))
                {
                    balCmd.Parameters.AddWithValue("@MemberNo", memberNo);
                    using (SqlDataReader balRdr = balCmd.ExecuteReader())
                    {
                        if (balRdr.Read())
                        {
                            totalDept = Convert.ToDecimal(balRdr["TotalDept"]);
                            totalCredit = Convert.ToDecimal(balRdr["TotalCredit"]);
                            balance = Convert.ToDecimal(balRdr["Balance"]);
                        }
                    }
                }
            }

            return new
            {
                success = true,
                CardNo = rd["RFID"] != DBNull.Value ? rd["RFID"].ToString() : cardNumber,
                Memberid = memberNo,
                MemberNo = memberNo,
                Name = rd["MemberName"] != DBNull.Value ? rd["MemberName"].ToString() : "Unknown",
                balance,
                totalDept,
                totalCredit,
                isActive,
                isCardActive,
                status
            };
        }
        catch (Exception ex)
        {
            return new { success = false, message = "Error validating card: " + ex.Message };
        }
    }

    // ════════════════════════════════════════════════════════════════
    // WEB METHOD — CheckCardDiscount
    // ════════════════════════════════════════════════════════════════
    [WebMethod]
    public static object CheckCardDiscount(string cardNumber, decimal billAmount)
    {
        try
        {
            string restaurantDB = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;

            string cleanNumber = cardNumber.Replace("-", "");
            string cardPrefix = cleanNumber.Length >= 4 ? cleanNumber.Substring(0, 4) : cleanNumber;
            string fullCardKey = cleanNumber;

            int weekday = (int)DateTime.Now.DayOfWeek;
            if (weekday == 0) weekday = 7;

            using (SqlConnection con = new SqlConnection(restaurantDB))
            {
                con.Open();

                string oq = @"
                    SELECT TOP 1 
                        offer_id, offer_name, discount_percent, max_discount_amount,
                        min_bill_amount, valid_weekday,
                        ISNULL(per_day_transaction_limit, 0) AS per_day_transaction_limit
                    FROM card_prefix_offers
                    WHERE card_prefix  = @CP
                      AND is_active    = 1
                      AND (valid_weekday = @WD OR valid_weekday = 0)
                      AND (valid_from IS NULL OR valid_from <= GETDATE())
                      AND (valid_to   IS NULL OR valid_to   >= GETDATE())
                      AND (min_bill_amount IS NULL OR min_bill_amount <= @BA)
                    ORDER BY discount_percent DESC";

                SqlCommand oc = new SqlCommand(oq, con);
                oc.Parameters.AddWithValue("@CP", cardPrefix);
                oc.Parameters.AddWithValue("@WD", weekday);
                oc.Parameters.AddWithValue("@BA", billAmount);
                SqlDataReader rdr = oc.ExecuteReader();

                if (!rdr.Read())
                {
                    rdr.Close();
                    return new { success = false, discount_amount = 0, message = "No discount available for this card." };
                }

                int offerId = Convert.ToInt32(rdr["offer_id"]);
                string offerName = rdr["offer_name"].ToString();
                decimal discPct = Convert.ToDecimal(rdr["discount_percent"]);
                int perDayLimit = Convert.ToInt32(rdr["per_day_transaction_limit"]);
                object maxDiscObj = rdr["max_discount_amount"];
                rdr.Close();

                if (perDayLimit > 0)
                {
                    string uq = @"
                        SELECT ISNULL(usage_count, 0) 
                        FROM offer_daily_usage 
                        WHERE offer_id    = @OI 
                          AND card_number = @CN 
                          AND usage_date  = CAST(GETDATE() AS DATE)";

                    SqlCommand uc = new SqlCommand(uq, con);
                    uc.Parameters.AddWithValue("@OI", offerId);
                    uc.Parameters.AddWithValue("@CN", fullCardKey);

                    int usedToday = 0;
                    try { object ur = uc.ExecuteScalar(); if (ur != null && ur != DBNull.Value) usedToday = Convert.ToInt32(ur); }
                    catch { }

                    if (usedToday >= perDayLimit)
                    {
                        return new
                        {
                            success = false,
                            discount_amount = 0,
                            limit_exceeded = true,
                            used_today = usedToday,
                            per_day_limit = perDayLimit,
                            offer_id = offerId,
                            offer_name = offerName,
                            message = string.Format(
                                "Daily offer limit reached. This card allows {0} transaction(s) per day. Used today: {1}.",
                                perDayLimit, usedToday)
                        };
                    }

                    decimal da = (billAmount * discPct) / 100m;
                    if (maxDiscObj != DBNull.Value) { decimal mx = Convert.ToDecimal(maxDiscObj); if (da > mx) da = mx; }

                    return new
                    {
                        success = true,
                        offer_id = offerId,
                        offer_name = offerName,
                        discount_percent = discPct,
                        discount_amount = da,
                        per_day_limit = perDayLimit,
                        used_today = usedToday,
                        remaining_today = perDayLimit - usedToday,
                        message = string.Format(
                            "{0}% discount applied (Rs {1:F2}). Usage: {2}/{3} today.", discPct, da, usedToday + 1, perDayLimit)
                    };
                }

                decimal discAmt = (billAmount * discPct) / 100m;
                if (maxDiscObj != DBNull.Value) { decimal mx = Convert.ToDecimal(maxDiscObj); if (discAmt > mx) discAmt = mx; }

                return new
                {
                    success = true,
                    offer_id = offerId,
                    offer_name = offerName,
                    discount_percent = discPct,
                    discount_amount = discAmt,
                    per_day_limit = 0,
                    used_today = 0,
                    remaining_today = -1,
                    message = string.Format(
                        "{0}% discount applied (Rs {1:F2}) — Unlimited usage.", discPct, discAmt)
                };
            }
        }
        catch (Exception ex)
        {
            return new { success = false, discount_amount = 0, message = "Error checking card discount: " + ex.Message };
        }
    }

    // ════════════════════════════════════════════════════════════════
    // WEB METHOD — GetPaymentSummary
    // ════════════════════════════════════════════════════════════════
    [WebMethod]
    public static object GetPaymentSummary()
    {
        try
        {
            string restaurantDB = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(restaurantDB))
            {
                con.Open();
                string cashierName = HttpContext.Current.Session["Emp_ID"] != null
                    ? GetEmployeeNameStatic(HttpContext.Current.Session["Emp_ID"].ToString()) : "Unknown";

                string query = @"
                    SELECT ISNULL(PaymentMethod,'Unknown') as PaymentMethod,
                           COUNT(*) AS TotalTransactions,
                           ISNULL(SUM(AmountPaid),0)       AS TotalAmountPaid,
                           ISNULL(SUM(DiscountApplied),0)  AS TotalDiscountApplied,
                           ISNULL(SUM(TaxApplied),0)       AS Tax
                    FROM Bills
                    WHERE Status IN ('Paid','GH')
                      AND CONVERT(DATE,ISNULL(PaymentDate,CreatedAt))=@Today
                    GROUP BY PaymentMethod
                    ORDER BY CASE WHEN PaymentMethod='Cash'        THEN 1
                                  WHEN PaymentMethod='Bank Card'   THEN 2
                                  WHEN PaymentMethod='Debit Card'  THEN 3
                                  WHEN PaymentMethod='Credit Card' THEN 4
                                  WHEN PaymentMethod='Member Card' THEN 5
                                  WHEN PaymentMethod='Guest House' THEN 6
                                  ELSE 7 END";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@Today", DateTime.Today);
                SqlDataReader reader = cmd.ExecuteReader();

                List<object> methods = new List<object>();
                decimal grandTotal = 0;
                int totalBills = 0;

                while (reader.Read())
                {
                    methods.Add(new
                    {
                        PaymentMethod = reader["PaymentMethod"].ToString(),
                        TotalTransactions = Convert.ToInt32(reader["TotalTransactions"]),
                        TotalAmountPaid = Convert.ToDecimal(reader["TotalAmountPaid"]),
                        TotalDiscountApplied = Convert.ToDecimal(reader["TotalDiscountApplied"]),
                        Tax = Convert.ToDecimal(reader["Tax"])
                    });
                    grandTotal += Convert.ToDecimal(reader["TotalAmountPaid"]);
                    totalBills += Convert.ToInt32(reader["TotalTransactions"]);
                }
                reader.Close();

                return new
                {
                    success = true,
                    cashierName,
                    departmentName = "All Departments",
                    date = DateTime.Today.ToString("dd-MM-yyyy"),
                    dateLong = DateTime.Today.ToString("dddd, MMMM d, yyyy"),
                    time = DateTime.Now.ToString("hh:mm tt"),
                    paymentMethods = methods,
                    grandTotal,
                    totalBills
                };
            }
        }
        catch (Exception ex) { return new { success = false, message = "Error: " + ex.Message }; }
    }

    // ════════════════════════════════════════════════════════════════
    // WEB METHOD — GetLiveBillsCount
    // ════════════════════════════════════════════════════════════════
    [WebMethod]
    public static object GetLiveBillsCount(string departmentName)
    {
        try
        {
            string restaurantDB = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(restaurantDB))
            {
                con.Open();
                string query = @"
                    SELECT COUNT(*) as PendingCount,
                           ISNULL(SUM(CASE WHEN Status='Delivered' THEN 1 ELSE 0 END),0) as DeliveredCount,
                           ISNULL(SUM(CASE WHEN Status='Pending'   THEN 1 ELSE 0 END),0) as PendingOnlyCount
                    FROM Bills WHERE Status IN ('Pending','Delivered')";

                if (!string.IsNullOrEmpty(departmentName) && departmentName != "All Departments")
                    query += " AND DepartmentName=@DN";

                SqlCommand cmd = new SqlCommand(query, con);
                if (!string.IsNullOrEmpty(departmentName) && departmentName != "All Departments")
                    cmd.Parameters.AddWithValue("@DN", departmentName);

                SqlDataReader dr = cmd.ExecuteReader();
                int p = 0, d = 0, po = 0;
                if (dr.Read())
                {
                    p = Convert.ToInt32(dr["PendingCount"]);
                    d = Convert.ToInt32(dr["DeliveredCount"]);
                    po = Convert.ToInt32(dr["PendingOnlyCount"]);
                }
                dr.Close();
                return new { success = true, total = p, delivered = d, pendingOnly = po };
            }
        }
        catch (Exception ex) { return new { success = false, message = ex.Message }; }
    }

    // ════════════════════════════════════════════════════════════════
    // STATIC HELPERS
    // ════════════════════════════════════════════════════════════════
    private static string GetEmployeeNameStatic(string empID)
    {
        try
        {
            string restaurantDB = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(restaurantDB))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT EmployeeName FROM EmployeeRestaurantMap WHERE Emp_ID=@empID", con);
                cmd.Parameters.AddWithValue("@empID", empID);
                con.Open();
                object result = cmd.ExecuteScalar();
                return result != null ? result.ToString() : empID;
            }
        }
        catch { return empID; }
    }

    // ════════════════════════════════════════════════════════════════
    // TIMER REFRESH
    // ════════════════════════════════════════════════════════════════
    protected void timerRefresh_Tick(object sender, EventArgs e)
    {
        LoadDeliveredBills();
        LoadTodaySalesData();
        UpdateBillCount();
    }
}

