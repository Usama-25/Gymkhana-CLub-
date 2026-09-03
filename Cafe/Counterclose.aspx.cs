using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Kitchen_assign : System.Web.UI.Page
{
    // ══════════════════════════════════════════════════════════════════
    // PAGE LOAD
    // ══════════════════════════════════════════════════════════════════
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadCounterInfo();
            LoadSalesData();
            LoadSummaryTotals();
        }
    }

    // ══════════════════════════════════════════════════════════════════
    // GET CURRENT DEPARTMENT NAME FROM SESSION
    // ══════════════════════════════════════════════════════════════════
    private string GetCurrentDeptName()
    {
        return Session["CC_DeptName"] != null ? Session["CC_DeptName"].ToString() : "";
    }

    // ══════════════════════════════════════════════════════════════════
    // LOAD COUNTER HEADER INFO FROM SESSION
    // ══════════════════════════════════════════════════════════════════
    private void LoadCounterInfo()
    {
        string cashierName = Session["CC_CashierName"] != null
            ? Session["CC_CashierName"].ToString() : GetCashierNameFromSession();
        lblCashierName.Text = cashierName;

        DateTime openTime = Session["CC_OpenTime"] != null
            ? Convert.ToDateTime(Session["CC_OpenTime"]) : DateTime.Today;
        lblOpenTime.Text = openTime.ToString("dd MMM yyyy  hh:mm tt");

        lblCloseTime.Text = DateTime.Now.ToString("dd MMM yyyy  hh:mm tt");

        string deptName = GetCurrentDeptName();
        lblDeptName.Text = string.IsNullOrEmpty(deptName) ? "All Departments" : deptName;

        bool alreadyClosed = IsCounterAlreadyClosed();
        if (alreadyClosed)
        {
            lblCounterStatus.Text = "<span class='status-dot'></span> Already Closed";
            lblCounterStatus.CssClass = "status-badge status-closed";
            btnCounterClose.Enabled = false;

            lblAlertHtml.Visible = true;
            lblAlertHtml.Text = "<div class='alert-box alert-warn'>" +
                "<i class='fas fa-exclamation-triangle'></i>" +
                "<div class='atxt'>Counter has already been closed for today. You cannot close it again.</div></div>";
        }
    }

    private string GetCashierNameFromSession()
    {
        if (Session["Emp_ID"] == null) return "Unknown";
        string empId = Session["Emp_ID"].ToString();
        try
        {
            string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                string sql = "SELECT EmployeeName FROM EmployeeRestaurantMap WHERE Emp_ID = @EID";
                SqlCommand cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@EID", empId);
                con.Open();
                object result = cmd.ExecuteScalar();
                return result != null ? result.ToString() : empId;
            }
        }
        catch { return empId; }
    }

    // ══════════════════════════════════════════════════════════════════
    // CHECK IF COUNTER IS ALREADY CLOSED (department-scoped)
    // ══════════════════════════════════════════════════════════════════
    private bool IsCounterAlreadyClosed()
    {
        string empId = Session["Emp_ID"] != null ? Session["Emp_ID"].ToString() : "0";
        string deptName = GetCurrentDeptName();
        try
        {
            string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                EnsureCounterCloseTable(con);
                string sql = @"SELECT COUNT(*) FROM CounterClose 
                               WHERE Emp_Id = @EID 
                                 AND CAST(CloseDate AS DATE) = CAST(GETDATE() AS DATE)";
                // If dept is known, scope to that dept
                if (!string.IsNullOrEmpty(deptName))
                    sql += " AND DepartmentName = @DeptName";

                SqlCommand cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@EID", empId);
                if (!string.IsNullOrEmpty(deptName))
                    cmd.Parameters.AddWithValue("@DeptName", deptName);
                con.Open();
                int count = Convert.ToInt32(cmd.ExecuteScalar());
                return count > 0;
            }
        }
        catch { return false; }
    }

    // ══════════════════════════════════════════════════════════════════
    // LOAD SALES GRIDVIEW — filtered to current department
    // ══════════════════════════════════════════════════════════════════
    private void LoadSalesData()
    {
        string deptName = GetCurrentDeptName();
        try
        {
            string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                string deptFilter = string.IsNullOrEmpty(deptName)
                    ? ""
                    : "AND b.DepartmentName = @DeptName";

                string query = @"
                    SELECT
                        ISNULL(b.PaymentMethod,'Unknown')            AS PaymentMethod,
                        b.DepartmentID,
                        ISNULL(SUM(b.DiscountApplied), 0)           AS TotalDiscount,
                        ISNULL(SUM(b.TaxApplied), 0)                AS TotalTax,
                        ISNULL(SUM(b.FinalAmount), 0)               AS TodayTotalSales,
                        b.DepartmentName                            AS SubDept_Name,
                        b.DepartmentName                            AS Dept_Name
                    FROM Bills b
                    WHERE 
                        b.Status IN ('Paid','GH')
                        AND CAST(b.PaymentDate AS DATE) = CAST(GETDATE() AS DATE)
                        AND b.CounterCloseId IS NULL
                        " + deptFilter + @"
                    GROUP BY
                        b.PaymentMethod,
                        b.DepartmentID,
                        b.DepartmentName
                    ORDER BY b.DepartmentName, b.PaymentMethod";

                SqlCommand cmd = new SqlCommand(query, con);
                if (!string.IsNullOrEmpty(deptName))
                    cmd.Parameters.AddWithValue("@DeptName", deptName);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count == 0)
                {
                    btnCounterClose.Enabled = false;
                    lblAlertHtml.Visible = true;
                    lblAlertHtml.Text = "<div class='alert-box alert-danger'>" +
                        "<i class='fas fa-ban'></i>" +
                        "<div class='atxt'>No sales found for today" +
                        (string.IsNullOrEmpty(deptName) ? "" : " in <strong>" + deptName + "</strong>") +
                        ". Counter close is only allowed when at least one paid bill exists.</div></div>";
                }

                gvSales.DataSource = dt;
                gvSales.DataBind();
            }
        }
        catch (Exception)
        {
            LoadSalesDataFallback(deptName);
        }
    }

    private void LoadSalesDataFallback(string deptName)
    {
        try
        {
            string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                string deptFilter = string.IsNullOrEmpty(deptName) ? "" : "AND DepartmentName = @DeptName";
                string query = @"
                    SELECT
                        ISNULL(PaymentMethod,'Unknown')     AS PaymentMethod,
                        DepartmentID,
                        ISNULL(SUM(DiscountApplied), 0)    AS TotalDiscount,
                        ISNULL(SUM(TaxApplied), 0)         AS TotalTax,
                        ISNULL(SUM(FinalAmount), 0)        AS TodayTotalSales,
                        DepartmentName                     AS SubDept_Name,
                        DepartmentName                     AS Dept_Name
                    FROM Bills
                    WHERE Status IN ('Paid','GH')
                      AND CAST(PaymentDate AS DATE) = CAST(GETDATE() AS DATE)
                      AND (CounterCloseId IS NULL OR CounterCloseId = 0)
                      " + deptFilter + @"
                    GROUP BY PaymentMethod, DepartmentID, DepartmentName
                    ORDER BY DepartmentName, PaymentMethod";

                SqlCommand cmd = new SqlCommand(query, con);
                if (!string.IsNullOrEmpty(deptName))
                    cmd.Parameters.AddWithValue("@DeptName", deptName);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvSales.DataSource = dt;
                gvSales.DataBind();
            }
        }
        catch { }
    }

    // ══════════════════════════════════════════════════════════════════
    // LOAD SUMMARY TOTALS — filtered to current department
    // ══════════════════════════════════════════════════════════════════
    private void LoadSummaryTotals()
    {
        string deptName = GetCurrentDeptName();
        try
        {
            string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                string deptFilter = string.IsNullOrEmpty(deptName) ? "" : "AND DepartmentName = @DeptName";
                string query = @"
                    SELECT
                        ISNULL(SUM(FinalAmount),0)                                           AS TotalSales,
                        ISNULL(SUM(CASE WHEN PaymentMethod IN
                            ('Bank Card','Debit Card','Credit Card')
                            THEN FinalAmount ELSE 0 END),0)                                  AS BankTotal,
                        ISNULL(SUM(CASE WHEN PaymentMethod='Member Card'
                            THEN FinalAmount ELSE 0 END),0)                                  AS MemberTotal,
                        ISNULL(SUM(CASE WHEN PaymentMethod='Cash'
                            THEN FinalAmount ELSE 0 END),0)                                  AS CashTotal,
                        ISNULL(SUM(DiscountApplied),0)                                       AS DiscountTotal,
                        ISNULL(SUM(TaxApplied),0)                                            AS TaxTotal,
                        ISNULL(SUM(Total),0)                                                 AS GrandTotal
                    FROM Bills
                    WHERE Status IN ('Paid','GH')
                      AND CAST(PaymentDate AS DATE) = CAST(GETDATE() AS DATE)
                      AND (CounterCloseId IS NULL OR CounterCloseId = 0)
                      " + deptFilter;

                SqlCommand cmd = new SqlCommand(query, con);
                if (!string.IsNullOrEmpty(deptName))
                    cmd.Parameters.AddWithValue("@DeptName", deptName);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    decimal totalSales = Convert.ToDecimal(dr["TotalSales"]);
                    decimal bankTotal = Convert.ToDecimal(dr["BankTotal"]);
                    decimal memberTotal = Convert.ToDecimal(dr["MemberTotal"]);
                    decimal cashTotal = Convert.ToDecimal(dr["CashTotal"]);
                    decimal discTotal = Convert.ToDecimal(dr["DiscountTotal"]);
                    decimal taxTotal = Convert.ToDecimal(dr["TaxTotal"]);
                    decimal grandTotal = Convert.ToDecimal(dr["GrandTotal"]);

                    lblTotalSales.Text = "Rs " + totalSales.ToString("N2");
                    lblBankTotal.Text = "Rs " + bankTotal.ToString("N2");
                    lblMemberTotal.Text = "Rs " + memberTotal.ToString("N2");
                    lblCashTotal.Text = "Rs " + cashTotal.ToString("N2");
                    lblDiscountTotal.Text = "Rs " + discTotal.ToString("N2");

                    lblCardAmount.Text = "Rs " + bankTotal.ToString("N2");
                    lblMemberAmount.Text = "Rs " + memberTotal.ToString("N2");
                    lblCashAmount.Text = "Rs " + cashTotal.ToString("N2");

                    lblTaxTotal.Text = "Rs " + taxTotal.ToString("N2");
                    lblDiscountGiven.Text = "Rs " + discTotal.ToString("N2");
                    lblNetSales.Text = "Rs " + totalSales.ToString("N2");
                    lblGrandTotal.Text = "Rs " + grandTotal.ToString("N2");
                }
                dr.Close();
            }
        }
        catch { }
    }

    // ══════════════════════════════════════════════════════════════════
    // PAYMENT METHOD BADGE HELPER
    // ══════════════════════════════════════════════════════════════════
    public string GetPaymentBadge(string method)
    {
        switch (method.ToLower().Trim())
        {
            case "bank card": return "<span class='pm-badge pm-bank'><i class='fas fa-credit-card'></i> Bank Card</span>";
            case "debit card": return "<span class='pm-badge pm-debit'><i class='fas fa-university'></i> Debit Card</span>";
            case "credit card": return "<span class='pm-badge pm-credit'><i class='fas fa-credit-card'></i> Credit Card</span>";
            case "member card": return "<span class='pm-badge pm-member'><i class='fas fa-id-card'></i> Member Card</span>";
            case "cash": return "<span class='pm-badge pm-cash'><i class='fas fa-money-bill-wave'></i> Cash</span>";
            default: return "<span class='pm-badge' style='background:#F8FAFC;color:#475569;border:1px solid #E2E8F0;'>" + method + "</span>";
        }
    }

    // ══════════════════════════════════════════════════════════════════
    // BUTTON: BACK TO CASHIER
    // ══════════════════════════════════════════════════════════════════
    protected void btnBack_Click(object sender, EventArgs e)
    {
        Response.Redirect("Casier.aspx");
    }

    // ══════════════════════════════════════════════════════════════════
    // BUTTON: CONFIRM COUNTER CLOSE
    // ══════════════════════════════════════════════════════════════════
    protected void btnCounterClose_Click(object sender, EventArgs e)
    {
        string empId = Session["Emp_ID"] != null ? Session["Emp_ID"].ToString() : "0";

        if (string.IsNullOrEmpty(empId) || empId == "0")
        {
            ShowAlert("danger", "Employee ID not found in session. Please log in again.");
            return;
        }

        if (IsCounterAlreadyClosed())
        {
            ShowAlert("warn", "Counter has already been closed for today.");
            btnCounterClose.Enabled = false;
            return;
        }

        bool hasSales = HasSalesToday(empId);
        if (!hasSales)
        {
            ShowAlert("danger", "No paid bills found for today. Counter close is not allowed when there are no sales.");
            return;
        }

        try
        {
            ProcessCounterClose(empId);
            lblCounterStatus.Text = "<span class='status-dot'></span> Closed";
            lblCounterStatus.CssClass = "status-badge status-closed";
            lblCloseTime.Text = DateTime.Now.ToString("dd MMM yyyy  hh:mm tt");
            btnCounterClose.Enabled = false;

            ShowAlert("success", "Counter closed successfully! All sales have been recorded.");
            ScriptManager.RegisterStartupScript(this, GetType(), "ShowSuccess", "showSuccessOverlay();", true);
        }
        catch (Exception ex)
        {
            ShowAlert("danger", "Error closing counter: " + ex.Message);
        }
    }

    private void ShowAlert(string type, string message)
    {
        string iconClass = type == "success" ? "fa-check-circle" : type == "warn" ? "fa-exclamation-triangle" : "fa-ban";
        string cssClass = "alert-box alert-" + (type == "warn" ? "warn" : type == "success" ? "success" : "danger");
        lblAlertHtml.Visible = true;
        lblAlertHtml.Text = string.Format(
            "<div class='{0}'><i class='fas {1}'></i><div class='atxt'>{2}</div></div>",
            cssClass, iconClass, message);
    }

    private bool HasSalesToday(string empId)
    {
        string deptName = GetCurrentDeptName();
        try
        {
            string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                string deptFilter = string.IsNullOrEmpty(deptName) ? "" : "AND DepartmentName = @DeptName";
                string sql = @"SELECT COUNT(*) FROM Bills
                               WHERE Status IN ('Paid','GH')
                                 AND CAST(PaymentDate AS DATE) = CAST(GETDATE() AS DATE)
                                 AND (CounterCloseId IS NULL OR CounterCloseId = 0)
                                 " + deptFilter;
                SqlCommand cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@EmpId", empId);
                if (!string.IsNullOrEmpty(deptName))
                    cmd.Parameters.AddWithValue("@DeptName", deptName);
                con.Open();
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }
        catch { return false; }
    }

    // ══════════════════════════════════════════════════════════════════
    // PROCESS COUNTER CLOSE — scoped to current department
    // ══════════════════════════════════════════════════════════════════
    private void ProcessCounterClose(string empId)
    {
        string deptName = GetCurrentDeptName();
        string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
        using (SqlConnection con = new SqlConnection(constr))
        {
            con.Open();
            EnsureCounterCloseTable(con);

            string deptFilter = string.IsNullOrEmpty(deptName) ? "" : "AND b.DepartmentName = @DeptName";

            string deptQuery = @"
                SELECT DISTINCT b.DepartmentID, b.DepartmentName AS SubDept_Name, b.DepartmentName AS Dept_Name
                FROM Bills b
                WHERE b.Status IN ('Paid','GH')
                  AND CAST(b.PaymentDate AS DATE) = CAST(GETDATE() AS DATE)
                  AND (b.CounterCloseId IS NULL OR b.CounterCloseId = 0)
                  " + deptFilter;

            List<DepartmentInfo> departments = new List<DepartmentInfo>();
            using (SqlCommand cmdDept = new SqlCommand(deptQuery, con))
            {
                if (!string.IsNullOrEmpty(deptName))
                    cmdDept.Parameters.AddWithValue("@DeptName", deptName);

                using (SqlDataReader dr = cmdDept.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        departments.Add(new DepartmentInfo
                        {
                            DepartmentID = dr["DepartmentID"].ToString(),
                            DepartmentName = dr["Dept_Name"].ToString(),
                            SubDepartmentName = dr["SubDept_Name"].ToString()
                        });
                    }
                }
            }

            foreach (DepartmentInfo dept in departments)
            {
                string insertCC = @"
                    INSERT INTO CounterClose
                    (Emp_Id, DepartmentID, DepartmentName, TotalSales, CardSales, MemberCardSales,
                     TotalDiscount, TotalTax, CloseDate)
                    VALUES
                    (@EmpId, @DeptId, @DeptName,
                     (SELECT ISNULL(SUM(FinalAmount),0) FROM Bills
                      WHERE Status IN ('Paid','GH') AND CAST(PaymentDate AS DATE)=CAST(GETDATE() AS DATE)
                        AND DepartmentID=@DeptId AND (CounterCloseId IS NULL OR CounterCloseId=0)),
                     (SELECT ISNULL(SUM(FinalAmount),0) FROM Bills
                      WHERE Status IN ('Paid','GH') AND PaymentMethod IN ('Bank Card','Debit Card','Credit Card')
                        AND CAST(PaymentDate AS DATE)=CAST(GETDATE() AS DATE)
                        AND DepartmentID=@DeptId AND (CounterCloseId IS NULL OR CounterCloseId=0)),
                     (SELECT ISNULL(SUM(FinalAmount),0) FROM Bills
                      WHERE Status IN ('Paid','GH') AND PaymentMethod='Member Card'
                        AND CAST(PaymentDate AS DATE)=CAST(GETDATE() AS DATE)
                        AND DepartmentID=@DeptId AND (CounterCloseId IS NULL OR CounterCloseId=0)),
                     (SELECT ISNULL(SUM(DiscountApplied),0) FROM Bills
                      WHERE Status IN ('Paid','GH') AND CAST(PaymentDate AS DATE)=CAST(GETDATE() AS DATE)
                        AND DepartmentID=@DeptId AND (CounterCloseId IS NULL OR CounterCloseId=0)),
                     (SELECT ISNULL(SUM(TaxApplied),0) FROM Bills
                      WHERE Status IN ('Paid','GH') AND CAST(PaymentDate AS DATE)=CAST(GETDATE() AS DATE)
                        AND DepartmentID=@DeptId AND (CounterCloseId IS NULL OR CounterCloseId=0)),
                     GETDATE()
                    );
                    SELECT SCOPE_IDENTITY();";

                int counterCloseId;
                using (SqlCommand cmdInsert = new SqlCommand(insertCC, con))
                {
                    cmdInsert.Parameters.AddWithValue("@EmpId", empId);
                    cmdInsert.Parameters.AddWithValue("@DeptId", dept.DepartmentID);
                    cmdInsert.Parameters.AddWithValue("@DeptName", dept.DepartmentName);
                    counterCloseId = Convert.ToInt32(cmdInsert.ExecuteScalar());
                }

                string updateBills = @"
                    UPDATE Bills SET CounterCloseId = @CCID
                    WHERE Status IN ('Paid','GH')
                      AND CAST(PaymentDate AS DATE) = CAST(GETDATE() AS DATE)
                      AND DepartmentID = @DeptId
                      AND (CounterCloseId IS NULL OR CounterCloseId = 0)";

                using (SqlCommand cmdUpdate = new SqlCommand(updateBills, con))
                {
                    cmdUpdate.Parameters.AddWithValue("@CCID", counterCloseId);
                    cmdUpdate.Parameters.AddWithValue("@DeptId", dept.DepartmentID);
                    cmdUpdate.ExecuteNonQuery();
                }
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════
    // ENSURE TABLE COLUMNS EXIST
    // ══════════════════════════════════════════════════════════════════
    private void EnsureCounterCloseTable(SqlConnection con)
    {
        if (con.State != System.Data.ConnectionState.Open) con.Open();

        new SqlCommand(@"
            IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='CounterClose')
            BEGIN
                CREATE TABLE CounterClose (
                    Id              INT IDENTITY(1,1) PRIMARY KEY,
                    Emp_Id          NVARCHAR(50)    NOT NULL,
                    DepartmentID    NVARCHAR(50)    NULL,
                    DepartmentName  NVARCHAR(100)   NULL,
                    TotalSales      DECIMAL(18,2)   DEFAULT 0,
                    CardSales       DECIMAL(18,2)   DEFAULT 0,
                    MemberCardSales DECIMAL(18,2)   DEFAULT 0,
                    TotalDiscount   DECIMAL(18,2)   DEFAULT 0,
                    TotalTax        DECIMAL(18,2)   DEFAULT 0,
                    CloseDate       DATETIME        DEFAULT GETDATE()
                )
            END", con).ExecuteNonQuery();

        // Ensure columns exist on legacy tables
        foreach (var col in new[]
  {
    "CloseDate DATETIME DEFAULT GETDATE()",
    "DepartmentName NVARCHAR(100) NULL"
})
        {
            string colName = col.Split(' ')[0];

            string sql = string.Format(@"
    IF NOT EXISTS
    (
        SELECT *
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME='CounterClose'
          AND COLUMN_NAME='{0}'
    )
    BEGIN
        ALTER TABLE CounterClose ADD {1}
    END", colName, col);

            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.ExecuteNonQuery();
            }
        }

        new SqlCommand(@"
            IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS
                           WHERE TABLE_NAME='Bills' AND COLUMN_NAME='CounterCloseId')
                ALTER TABLE Bills ADD CounterCloseId INT NULL", con).ExecuteNonQuery();
    }

    // ══════════════════════════════════════════════════════════════════
    // WEB METHOD — GetPaymentMethodDetail
    // Returns bill-level detail for a given department + payment method
    // ══════════════════════════════════════════════════════════════════
    [WebMethod]
    public static object GetPaymentMethodDetail(string deptName, string paymentMethod)
    {
        try
        {
            string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                con.Open();

                string deptFilter = string.IsNullOrEmpty(deptName) ? "" : "AND b.DepartmentName = @DeptName";

                string query = @"
                    SELECT
                        b.BillNo,
                        b.KOT_Number,
                        b.MemberNo,
                        ISNULL(b.Subtotal, 0)          AS Subtotal,
                        ISNULL(b.DiscountApplied, 0)   AS DiscountAmt,
                        ISNULL(b.TaxApplied, 0)        AS TaxAmt,
                        ISNULL(b.FinalAmount, 0)       AS FinalAmount,
                        b.PaymentMethod,
                        b.DepartmentName,
                        FORMAT(b.PaymentDate, 'hh:mm tt') AS PayTime
                    FROM Bills b
                    WHERE b.Status IN ('Paid','GH')
                      AND CAST(b.PaymentDate AS DATE) = CAST(GETDATE() AS DATE)
                      AND b.PaymentMethod = @PayMethod
                      AND (b.CounterCloseId IS NULL OR b.CounterCloseId = 0)
                      " + deptFilter + @"
                    ORDER BY b.PaymentDate DESC";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@PayMethod", paymentMethod);
                if (!string.IsNullOrEmpty(deptName))
                    cmd.Parameters.AddWithValue("@DeptName", deptName);

                SqlDataReader dr = cmd.ExecuteReader();
                var rows = new List<object>();
                decimal grandTotal = 0, grandDiscount = 0, grandTax = 0;

                while (dr.Read())
                {
                    decimal finalAmt = Convert.ToDecimal(dr["FinalAmount"]);
                    decimal discAmt = Convert.ToDecimal(dr["DiscountAmt"]);
                    decimal taxAmt = Convert.ToDecimal(dr["TaxAmt"]);
                    grandTotal += finalAmt;
                    grandDiscount += discAmt;
                    grandTax += taxAmt;

                    rows.Add(new
                    {
                        BillNo = dr["BillNo"].ToString(),
                        KotNumber = dr["KOT_Number"].ToString(),
                        MemberNo = dr["MemberNo"].ToString(),
                        Subtotal = Convert.ToDecimal(dr["Subtotal"]),
                        DiscountAmt = discAmt,
                        TaxAmt = taxAmt,
                        FinalAmount = finalAmt,
                        PayTime = dr["PayTime"].ToString(),
                        DepartmentName = dr["DepartmentName"].ToString()
                    });
                }
                dr.Close();

                return new
                {
                    success = true,
                    rows,
                    grandTotal,
                    grandDiscount,
                    grandTax,
                    count = rows.Count,
                    paymentMethod,
                    deptName
                };
            }
        }
        catch (Exception ex)
        {
            return new { success = false, message = ex.Message };
        }
    }

    // ══════════════════════════════════════════════════════════════════
    // HELPER CLASS
    // ══════════════════════════════════════════════════════════════════
    public class DepartmentInfo
    {
        public string DepartmentID { get; set; }
        public string DepartmentName { get; set; }
        public string SubDepartmentName { get; set; }
    }

    // ══════════════════════════════════════════════════════════════════
    // LEGACY WEB METHOD
    // ══════════════════════════════════════════════════════════════════
    [System.Web.Services.WebMethod]
    public static List<SalesModel> GetTodaySales()
    {
        var list = new List<SalesModel>();
        string constr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
        using (SqlConnection con = new SqlConnection(constr))
        {
            con.Open();
            string query = @"
                SELECT
                    ISNULL(PaymentMethod,'Unknown')     AS PaymentMethod,
                    DepartmentID,
                    ISNULL(SUM(DiscountApplied), 0)    AS TotalDiscount,
                    ISNULL(SUM(TaxApplied), 0)         AS TotalTax,
                    ISNULL(SUM(FinalAmount), 0)        AS TodayTotalSales,
                    DepartmentName                     AS SubDept_Name,
                    DepartmentName                     AS Dept_Name
                FROM Bills
                WHERE Status IN ('Paid','GH')
                  AND CAST(PaymentDate AS DATE) = CAST(GETDATE() AS DATE)
                GROUP BY PaymentMethod, DepartmentID, DepartmentName";

            using (SqlCommand cmd = new SqlCommand(query, con))
            using (SqlDataReader dr = cmd.ExecuteReader())
            {
                while (dr.Read())
                {
                    list.Add(new SalesModel
                    {
                        PaymentMethod = dr["PaymentMethod"].ToString(),
                        DepartmentID = dr["DepartmentID"].ToString(),
                        DepartmentName = dr["Dept_Name"].ToString(),
                        SubDepartmentName = dr["SubDept_Name"].ToString(),
                        TotalDiscount = Convert.ToDecimal(dr["TotalDiscount"]),
                        TotalTax = Convert.ToDecimal(dr["TotalTax"]),
                        TodayTotalSales = Convert.ToDecimal(dr["TodayTotalSales"])
                    });
                }
            }
        }
        return list;
    }

    public class SalesModel
    {
        public string PaymentMethod { get; set; }
        public string DepartmentID { get; set; }
        public string DepartmentName { get; set; }
        public string SubDepartmentName { get; set; }
        public decimal TotalDiscount { get; set; }
        public decimal TotalTax { get; set; }
        public decimal TodayTotalSales { get; set; }
    }
}

