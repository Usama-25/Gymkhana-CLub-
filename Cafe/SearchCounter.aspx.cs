using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Kitchen_assign : System.Web.UI.Page
{
    string cons = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadSubDepartments();
            pnlDepartmentInfo.Visible = false;
            pnlStats.Visible = false;
            gvCounterClose.Visible = false;
            pnlAlert.Visible = false;
        }
    }

    #region LOAD DROPDOWN
    protected void gvCounterClose_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        try
        {
            if (e.CommandName == "MarkConsumption")
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                int counterCloseId = Convert.ToInt32(args[0]);

                SyncSessionFromDropdown();
                Session["CounterCloseId"] = counterCloseId;

                Response.Redirect("Consumption1.aspx?CCID=" + counterCloseId);
            }
            else if (e.CommandName == "VerifyConsumption")
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                int counterCloseId = Convert.ToInt32(args[0]);

                Session["SubDeptId"] = ddlSubDept.SelectedValue;
                Session["SubDeptName"] = ddlSubDept.SelectedItem.Text;
                Session["CounterCloseID"] = counterCloseId;

                Response.Redirect("ConsumptionVerification.aspx");
            }
        }
        catch (Exception ex)
        {
            ShowAlert("Grid error: " + ex.Message, "error");
        }
    }
    private void LoadSubDepartments()
    {
        using (SqlConnection con = new SqlConnection(cons))
        {
            SqlDataAdapter da = new SqlDataAdapter(@"
                SELECT SubDept_Id, SubDept_Name 
                FROM BasicDataInfo.dbo.SubDepartment 
                WHERE Dept_Id = 9
                ORDER BY SubDept_Name", con);

            DataTable dt = new DataTable();
            da.Fill(dt);

            ddlSubDept.DataSource = dt;
            ddlSubDept.DataTextField = "SubDept_Name";
            ddlSubDept.DataValueField = "SubDept_Id";
            ddlSubDept.DataBind();

            ddlSubDept.Items.Insert(0, new ListItem("-- Select Department --", "0"));
        }
    }

    #endregion

    #region SESSION HELPERS

    private void SyncSessionFromDropdown()
    {
        Session["DepartmentID"] = ddlSubDept.SelectedValue;
        Session["DepartmentName"] = ddlSubDept.SelectedItem.Text;
        hdnDeptId.Value = ddlSubDept.SelectedValue;
        hdnDeptName.Value = ddlSubDept.SelectedItem.Text;
    }

    private void ClearSession()
    {
        Session["DepartmentID"] = null;
        Session["DepartmentName"] = null;
        hdnDeptId.Value = "";
        hdnDeptName.Value = "";
    }

    #endregion

    #region DROPDOWN CHANGE

    protected void ddlSubDept_SelectedIndexChanged(object sender, EventArgs e)
    {
        pnlAlert.Visible = false;

        if (ddlSubDept.SelectedValue != "0")
        {
            SyncSessionFromDropdown();
            pnlDepartmentInfo.Visible = true;
            lblDepartmentName.Text = ddlSubDept.SelectedItem.Text;

            CheckCounterCloseStatus();
            LoadGrid();
        }
        else
        {
            ClearSession();
            pnlDepartmentInfo.Visible = false;
            pnlStats.Visible = false;
            gvCounterClose.Visible = false;
        }
    }

    #endregion

    #region COUNTER STATUS

    private void CheckCounterCloseStatus()
    {
        bool isClosed = IsCounterClosedToday(ddlSubDept.SelectedValue);

        if (isClosed)
        {
            divCloseStatus.Attributes["class"] = "close-status status-closed";
            litStatusText.Text = "Counter Closed Today";
            btnCloseCounterNow.Visible = false;
        }
        else
        {
            divCloseStatus.Attributes["class"] = "close-status status-open";
            litStatusText.Text = "Counter Open – Needs Closing";
            btnCloseCounterNow.Visible = true;
        }
    }

    private bool IsCounterClosedToday(string departmentId)
    {
        using (SqlConnection con = new SqlConnection(cons))
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT COUNT(*) 
                FROM CounterClose
                WHERE DepartmentID = @DepartmentID
                  AND CAST(CloseDate AS DATE) = CAST(GETDATE() AS DATE)
                  AND CounterStatus = 'Closed'", con);

            cmd.Parameters.AddWithValue("@DepartmentID", departmentId);
            con.Open();

            return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
        }
    }

    #endregion

    #region SEARCH

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        pnlAlert.Visible = false;

        if (ddlSubDept.SelectedValue == "0")
        {
            ShowAlert("Please select a department first.", "error");
            return;
        }

        SyncSessionFromDropdown();
        pnlDepartmentInfo.Visible = true;

        CheckCounterCloseStatus();
        LoadGrid();
    }

    #endregion

    #region CLOSE COUNTER

    protected void btnCloseCounterNow_Click(object sender, EventArgs e)
    {
        string deptId = ddlSubDept.SelectedValue;

        if (IsCounterClosedToday(deptId))
        {
            ShowAlert("Counter already closed today.", "warning");
            return;
        }

        if (!HasSalesToday(deptId))
        {
            ShowAlert("No paid bills found for today.", "error");
            return;
        }

        try
        {
            string empId = Session["Emp_ID"] != null ? Session["Emp_ID"].ToString() : "1";

            ProcessCounterClose(deptId, empId);

            ShowAlert("Counter closed successfully.", "success");

            CheckCounterCloseStatus();
            LoadGrid();
        }
        catch (Exception ex)
        {
            ShowAlert("Error: " + ex.Message, "error");
        }
    }

    private bool HasSalesToday(string departmentId)
    {
        using (SqlConnection con = new SqlConnection(cons))
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT COUNT(*) 
                FROM Bills
                WHERE DepartmentID = @DepartmentID
                  AND Status IN ('Paid','GH')
                  AND CAST(PaymentDate AS DATE) = CAST(GETDATE() AS DATE)
                  AND CounterCloseId IS NULL", con);

            cmd.Parameters.AddWithValue("@DepartmentID", departmentId);
            con.Open();

            return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
        }
    }

    #endregion

    #region PROCESS CLOSE

    private void ProcessCounterClose(string departmentId, string empId)
    {
        using (SqlConnection con = new SqlConnection(cons))
        {
            con.Open();

            using (SqlTransaction tr = con.BeginTransaction())
            {
                try
                {
                    SqlCommand check = new SqlCommand(@"
                        SELECT COUNT(*) FROM CounterClose
                        WHERE DepartmentID = @DeptId
                          AND CAST(CloseDate AS DATE) = CAST(GETDATE() AS DATE)
                          AND CounterStatus = 'Closed'", con, tr);

                    check.Parameters.AddWithValue("@DeptId", departmentId);

                    if (Convert.ToInt32(check.ExecuteScalar()) > 0)
                        throw new Exception("Already closed.");

                    SqlCommand insert = new SqlCommand(@"
                        INSERT INTO CounterClose
                        (Emp_Id, DepartmentID, TotalSales, CardSales, MemberCardSales,
                         TotalDiscount, TotalTax, CloseDate, CounterStatus)
                        VALUES
                        (@EmpId, @DeptId,

                         (SELECT ISNULL(SUM(FinalAmount),0)
                          FROM Bills
                          WHERE DepartmentID=@DeptId AND Status IN ('Paid','GH')
                          AND CounterCloseId IS NULL
                          AND CAST(PaymentDate AS DATE)=CAST(GETDATE() AS DATE)),

                         (SELECT ISNULL(SUM(FinalAmount),0)
                          FROM Bills
                          WHERE DepartmentID=@DeptId
                          AND PaymentMethod IN ('Bank Card','Debit Card','Credit Card')
                          AND Status IN ('Paid','GH')
                          AND CounterCloseId IS NULL
                          AND CAST(PaymentDate AS DATE)=CAST(GETDATE() AS DATE)),

                         (SELECT ISNULL(SUM(FinalAmount),0)
                          FROM Bills
                          WHERE DepartmentID=@DeptId
                          AND PaymentMethod='Member Card'
                          AND Status IN ('Paid','GH')
                          AND CounterCloseId IS NULL
                          AND CAST(PaymentDate AS DATE)=CAST(GETDATE() AS DATE)),

                         (SELECT ISNULL(SUM(DiscountApplied),0)
                          FROM Bills
                          WHERE DepartmentID=@DeptId
                          AND Status IN ('Paid','GH')
                          AND CounterCloseId IS NULL
                          AND CAST(PaymentDate AS DATE)=CAST(GETDATE() AS DATE)),

                         (SELECT ISNULL(SUM(TaxApplied),0)
                          FROM Bills
                          WHERE DepartmentID=@DeptId
                          AND Status IN ('Paid','GH')
                          AND CounterCloseId IS NULL
                          AND CAST(PaymentDate AS DATE)=CAST(GETDATE() AS DATE)),

                         GETDATE(), 'Closed');

                        SELECT SCOPE_IDENTITY();
                    ", con, tr);

                    insert.Parameters.AddWithValue("@EmpId", empId);
                    insert.Parameters.AddWithValue("@DeptId", departmentId);

                    int ccId = Convert.ToInt32(insert.ExecuteScalar());

                    SqlCommand update = new SqlCommand(@"
                        UPDATE Bills
                        SET CounterCloseId = @CCID
                        WHERE DepartmentID = @DeptId
                          AND Status IN ('Paid','GH')
                          AND CounterCloseId IS NULL
                          AND CAST(PaymentDate AS DATE)=CAST(GETDATE() AS DATE)", con, tr);

                    update.Parameters.AddWithValue("@CCID", ccId);
                    update.Parameters.AddWithValue("@DeptId", departmentId);

                    update.ExecuteNonQuery();

                    tr.Commit();
                }
                catch
                {
                    tr.Rollback();
                    throw;
                }
            }
        }
    }

    #endregion

    #region GRID (FIXED - NO MISSING RECORDS)

    private void LoadGrid()
    {
        using (SqlConnection con = new SqlConnection(cons))
        {
            string query = @"
                SELECT 
                    cc.CounterCloseId,
                    cc.Emp_Id,
                    cc.DepartmentID,
                    cc.CloseDate,
                    ISNULL(cc.CounterStatus,'Open') AS CounterStatus,

                    ISNULL(SUM(b.FinalAmount),0) AS TotalSales,

                    ISNULL(SUM(CASE 
                        WHEN b.PaymentMethod IN ('Bank Card','Debit Card','Credit Card')
                        THEN b.FinalAmount ELSE 0 END),0) AS CardSales,

                    ISNULL(SUM(CASE 
                        WHEN b.PaymentMethod='Member Card'
                        THEN b.FinalAmount ELSE 0 END),0) AS MemberCardSales,

                    ISNULL(SUM(b.DiscountApplied),0) AS TotalDiscount,
                    ISNULL(SUM(b.TaxApplied),0) AS TotalTax,

                    CASE WHEN EXISTS (
                        SELECT 1 FROM Consumption_Master cm
                        WHERE cm.CounterCloseId = cc.CounterCloseId
                        AND ISNULL(cm.IsFullyConsumed,0)=1
                    ) THEN 'Consumed' ELSE 'Pending' END AS ConsumedStatus

                FROM CounterClose cc
                LEFT JOIN Bills b 
                    ON b.CounterCloseId = cc.CounterCloseId
                   AND b.Status IN ('Paid','GH')

                WHERE cc.DepartmentID = @DepartmentID";

            if (!string.IsNullOrEmpty(txtFromDate.Text))
                query += " AND CAST(cc.CloseDate AS DATE) >= @FromDate";

            if (!string.IsNullOrEmpty(txtToDate.Text))
                query += " AND CAST(cc.CloseDate AS DATE) <= @ToDate";

            query += @"
                GROUP BY cc.CounterCloseId, cc.Emp_Id, cc.DepartmentID, cc.CloseDate, cc.CounterStatus
                ORDER BY cc.CloseDate DESC";

            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@DepartmentID", ddlSubDept.SelectedValue);

            if (!string.IsNullOrEmpty(txtFromDate.Text))
                cmd.Parameters.AddWithValue("@FromDate", Convert.ToDateTime(txtFromDate.Text));

            if (!string.IsNullOrEmpty(txtToDate.Text))
                cmd.Parameters.AddWithValue("@ToDate", Convert.ToDateTime(txtToDate.Text));

            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            gvCounterClose.Visible = dt.Rows.Count > 0;
            gvCounterClose.DataSource = dt;
            gvCounterClose.DataBind();

            if (dt.Rows.Count > 0)
                CalculateStatistics(dt);
            else
                pnlStats.Visible = false;
        }
    }

    #endregion

    #region STATS

    private void CalculateStatistics(DataTable dt)
    {
        pnlStats.Visible = true;

        decimal sales = 0, card = 0, member = 0, disc = 0, tax = 0;

        foreach (DataRow r in dt.Rows)
        {
            sales += Convert.ToDecimal(r["TotalSales"]);
            card += Convert.ToDecimal(r["CardSales"]);
            member += Convert.ToDecimal(r["MemberCardSales"]);
            disc += Convert.ToDecimal(r["TotalDiscount"]);
            tax += Convert.ToDecimal(r["TotalTax"]);
        }

        lblTotalSales.Text = sales.ToString("N2");
        lblTotalCardSales.Text = card.ToString("N2");
        lblTotalMemberCardSales.Text = member.ToString("N2");
        lblTotalDiscount.Text = disc.ToString("N2");
        lblTotalTax.Text = tax.ToString("N2");
        lblNetAmount.Text = (sales - disc).ToString("N2");
        lblRecordCount.Text = dt.Rows.Count.ToString();
    }

    #endregion

    #region ALERT

    private void ShowAlert(string message, string type)
    {
        pnlAlert.Visible = true;
        lblAlertMessage.Text = message;

        string css = "alert-box";

        if (type == "success") css += " alert-success";
        else if (type == "error") css += " alert-error";
        else if (type == "warning") css += " alert-warning";

        divAlert.Attributes["class"] = css;
    }

    #endregion
}

