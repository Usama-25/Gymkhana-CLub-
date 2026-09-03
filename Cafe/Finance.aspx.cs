using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Kitchen_assign : System.Web.UI.Page
{
    string cons = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Text = DateTime.Now.AddDays(-7).ToString("yyyy-MM-dd");
            txtEndDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            LoadCounterCloseData();
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        LoadCounterCloseData();
    }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        txtStartDate.Text = DateTime.Now.AddDays(-7).ToString("yyyy-MM-dd");
        txtEndDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        LoadCounterCloseData();
    }

    private void LoadCounterCloseData()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(cons))
            {
                string query = @"
                    SELECT CounterCloseId,
                           TotalSales,
                           CardSales        AS BankcardSales,
                           MemberCardSales,
                           TotalDiscount,
                           TotalTax,
                           DepartmentID,
                           Emp_Id,
                           CloseDate,
                           VoucherId,
                           CounterStatus
                    FROM   CounterClose
                    WHERE  1=1";

                if (!string.IsNullOrEmpty(txtStartDate.Text))
                    query += " AND CAST(CloseDate AS DATE) >= @StartDate";

                if (!string.IsNullOrEmpty(txtEndDate.Text))
                    query += " AND CAST(CloseDate AS DATE) <= @EndDate";

                query += " ORDER BY CloseDate DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    if (!string.IsNullOrEmpty(txtStartDate.Text))
                        cmd.Parameters.AddWithValue("@StartDate", Convert.ToDateTime(txtStartDate.Text));

                    if (!string.IsNullOrEmpty(txtEndDate.Text))
                        cmd.Parameters.AddWithValue("@EndDate", Convert.ToDateTime(txtEndDate.Text));

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        gvCounterClose.DataSource = dt;
                        gvCounterClose.DataBind();
                        lblMessage.Text = "";
                    }
                    else
                    {
                        gvCounterClose.DataSource = null;
                        gvCounterClose.DataBind();
                        lblMessage.Text = "No records found for the selected date range.";
                    }
                }
            }
        }
        catch (Exception ex)
        {
            lblMessage.Text = "Error loading data: " + ex.Message;
        }
    }

    // ─── POST SELECTED ──────────────────────────────────────────────────────────

    protected void btnPostSelected_Click(object sender, EventArgs e)
    {
        string selectedIds = hdnSelectedIds.Value;

        if (string.IsNullOrEmpty(selectedIds))
        {
            ShowAlert("⚠️ Koi row select nahi ki gayi.\\nPehle checkboxes select karein.");
            return;
        }

        // FIX: If this postback came from the JS confirm dialog, process directly.
        bool isConfirmed = (Request.Params["__EVENTARGUMENT"] == "Confirmed");

        if (isConfirmed)
        {
            DataTable selectedRecords = GetSelectedRecordsDetails(selectedIds);

            if (selectedRecords.Rows.Count == 0)
            {
                ShowAlert("No records found!");
                return;
            }

            decimal totalSales = 0, totalBank = 0, totalMember = 0, totalDisc = 0, totalTax = 0;

            foreach (DataRow row in selectedRecords.Rows)
            {
                totalSales += Convert.ToDecimal(row["TotalSales"]);
                totalBank += Convert.ToDecimal(row["BankcardSales"]);
                totalMember += Convert.ToDecimal(row["MemberCardSales"]);
                totalDisc += Convert.ToDecimal(row["TotalDiscount"]);
                totalTax += Convert.ToDecimal(row["TotalTax"]);
            }

            ProcessPosting(selectedIds, totalSales, totalBank, totalMember, totalDisc, totalTax,
                           selectedRecords.Rows.Count);
        }
        else
        {
            // First click: gather data, show confirm dialog, re-post with "Confirmed" argument.
            DataTable selectedRecords = GetSelectedRecordsDetails(selectedIds);

            if (selectedRecords.Rows.Count == 0)
            {
                ShowAlert("No records found!");
                return;
            }

            decimal totalSales = 0, totalBank = 0, totalMember = 0, totalDisc = 0, totalTax = 0;
            StringBuilder idsBuilder = new StringBuilder();

            foreach (DataRow row in selectedRecords.Rows)
            {
                totalSales += Convert.ToDecimal(row["TotalSales"]);
                totalBank += Convert.ToDecimal(row["BankcardSales"]);
                totalMember += Convert.ToDecimal(row["MemberCardSales"]);
                totalDisc += Convert.ToDecimal(row["TotalDiscount"]);
                totalTax += Convert.ToDecimal(row["TotalTax"]);

                // FIX: proper string concatenation — no broken interpolation
                if (idsBuilder.Length > 0) idsBuilder.Append(", ");
                idsBuilder.Append(row["CounterCloseId"].ToString());
            }

            string idsList = idsBuilder.ToString();

            // FIX: BuildConfirmationMessage now uses string.Format properly
            string confirmMsg = BuildConfirmationMessage(
                idsList, totalSales, totalBank, totalMember, totalDisc, totalTax);

            ShowConfirm(confirmMsg);
        }
    }

    // ─── HELPERS ────────────────────────────────────────────────────────────────

    // FIX: parameterised query — no SQL injection
    private DataTable GetSelectedRecordsDetails(string selectedIds)
    {
        DataTable dt = new DataTable();

        if (string.IsNullOrWhiteSpace(selectedIds))
            return dt;

        // Convert comma-separated string to a table-valued list safely
        // by parsing to integers first (rejects any injection attempt).
        string[] parts = selectedIds.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
        var safeIds = new System.Collections.Generic.List<int>();

        foreach (string p in parts)
        {
            int id;
            if (int.TryParse(p.Trim(), out id))
                safeIds.Add(id);
        }

        if (safeIds.Count == 0)
            return dt;

        // Build parameterised IN clause  (@p0, @p1, …)
        var paramNames = new System.Collections.Generic.List<string>();
        for (int i = 0; i < safeIds.Count; i++)
            paramNames.Add("@p" + i);

        string inClause = string.Join(",", paramNames);

        using (SqlConnection con = new SqlConnection(cons))
        {
            string query = string.Format(
                @"SELECT CounterCloseId, TotalSales,
                         CardSales AS BankcardSales,
                         MemberCardSales, TotalDiscount, TotalTax
                  FROM   CounterClose
                  WHERE  CounterCloseId IN ({0})", inClause);

            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                for (int i = 0; i < safeIds.Count; i++)
                    cmd.Parameters.AddWithValue("@p" + i, safeIds[i]);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }
        }

        return dt;
    }

    // FIX: All string.Format placeholders are now correct (were {variable} before)
    private string BuildConfirmationMessage(string idsList,
        decimal totalSales, decimal totalBank,
        decimal totalMember, decimal totalDisc, decimal totalTax)
    {
        StringBuilder msg = new StringBuilder();
        msg.AppendLine("═══════════════════════════════════════");
        msg.AppendLine("📋 POST SELECTED RECORDS");
        msg.AppendLine("═══════════════════════════════════════");
        msg.AppendLine();
        msg.AppendLine("Counter Close IDs: " + idsList);          // FIX: was {idsList}
        msg.AppendLine();
        msg.AppendLine("📊 SELECTED TOTALS:");
        msg.AppendLine("───────────────────────────────────────");
        msg.AppendLine(string.Format("💰 Total Sales:   Rs {0:N0}", totalSales));
        msg.AppendLine(string.Format("💳 Bank Card:     Rs {0:N0}", totalBank));
        msg.AppendLine(string.Format("🆔 Member Card:   Rs {0:N0}", totalMember));
        msg.AppendLine(string.Format("🏷️  Discount:     Rs {0:N0}", totalDisc));
        msg.AppendLine(string.Format("📋 Tax:           Rs {0:N0}", totalTax));
        msg.AppendLine("───────────────────────────────────────");
        msg.AppendLine(string.Format("💵 NET RECEIVABLE: Rs {0:N0}", totalSales - totalDisc));
        msg.AppendLine();
        msg.AppendLine("⚠️  This action cannot be undone.");
        msg.AppendLine("═══════════════════════════════════════");
        return msg.ToString();
    }

    private void ShowAlert(string message)
    {
        // FIX: was using broken template literal  alert('{safeMessage}');
        string safeMessage = message
            .Replace("\\", "\\\\")
            .Replace("'", "\\'")
            .Replace("\r", "")
            .Replace("\n", "\\n");

        string script = string.Format("alert('{0}');", safeMessage);
        ClientScript.RegisterStartupScript(this.GetType(), "Alert", script, true);
    }

    // FIX: Confirm dialog that actually triggers a second postback with "Confirmed" argument.
    private void ShowConfirm(string message)
    {
        string safeMessage = message
            .Replace("\\", "\\\\")
            .Replace("'", "\\'")
            .Replace("\r", "")
            .Replace("\n", "\\n");

        // __doPostBack with "Confirmed" event argument — picked up in btnPostSelected_Click
        string script = string.Format(
            "if(confirm('{0}')){{ __doPostBack('{1}','Confirmed'); }}",
            safeMessage,
            btnPostSelected.UniqueID);   // FIX: was broken string literal

        ClientScript.RegisterStartupScript(this.GetType(), "Confirm", script, true);
    }

    // ─── PROCESS POSTING ────────────────────────────────────────────────────────

    private void ProcessPosting(string selectedIds,
        decimal totalSales, decimal totalBank,
        decimal totalMember, decimal totalDisc, decimal totalTax,
        int recordCount)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(cons))
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand("PostCounterToFinance", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    int empId = 1;
                    if (Session["EmpId"] != null)
                        empId = Convert.ToInt32(Session["EmpId"]);

                    cmd.Parameters.AddWithValue("@Emp_Id", empId);
                    cmd.Parameters.AddWithValue("@CounterIds", selectedIds);

                    // FIX: @vti output parameter kept as requested
                    SqlParameter vtiParam = new SqlParameter("@vti", SqlDbType.Decimal);
                    vtiParam.Precision = 18;
                    vtiParam.Scale = 0;
                    vtiParam.Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(vtiParam);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int success = Convert.ToInt32(reader["Success"]);

                            if (success == 1)
                            {
                                int voucherId = Convert.ToInt32(reader["VoucherId"]);

                                // FIX: all placeholders now use string.Format {0},{1}…
                                string successMessage = string.Format(
                                    "✅ Successfully posted {0} record(s)!\\n" +
                                    "📄 Voucher ID: V-{1}\\n" +
                                    "💰 Total Sales:  Rs {2:N0}\\n" +
                                    "💳 Bank Card:    Rs {3:N0}\\n" +
                                    "🆔 Member Card:  Rs {4:N0}\\n" +
                                    "🏷️ Discount:     Rs {5:N0}\\n" +
                                    "📋 Tax:          Rs {6:N0}\\n" +
                                    "💵 Net Amount:   Rs {7:N0}",
                                    recordCount, voucherId,
                                    totalSales, totalBank, totalMember,
                                    totalDisc, totalTax,
                                    totalSales - totalDisc);

                                ShowAlert(successMessage);
                                lblMessage.Text =
                                    "<span style='color:var(--green);font-weight:700;'>✅ Successfully posted!</span>";
                            }
                            else
                            {
                                // FIX: was using broken template literal  "❌ Error: {errMsg}"
                                string errMsg = (reader.FieldCount > 1)
                                    ? reader["ErrorMessage"].ToString()
                                    : "Unknown error.";

                                ShowAlert("❌ Error: " + errMsg);
                                lblMessage.Text =
                                    "<span style='color:var(--red);'>❌ " + errMsg + "</span>";
                            }
                        }
                    }
                }
            }

            hdnSelectedIds.Value = "";
            LoadCounterCloseData();
        }
        catch (Exception ex)
        {
            // FIX: was broken "Error: {ex.Message}"
            ShowAlert("Error: " + ex.Message);
            lblMessage.Text =
                "<span style='color:var(--red);'>Error: " + ex.Message + "</span>";
        }
    }

    // ─── VIEW / MODAL ────────────────────────────────────────────────────────────

    protected void btnView_Click(object sender, EventArgs e)
    {
        Button btn = (Button)sender;
        string counterCloseId = btn.CommandArgument;

        try
        {
            DataTable dtBills = LoadBillsByCounterCloseId(counterCloseId);
            Session["CurrentBillsDT"] = dtBills;
            Session["CurrentCounterCloseId"] = counterCloseId;

            gvBillItems.DataSource = null;
            gvBillItems.DataBind();
            BindBillsGrid(dtBills);

            string modalScript =
                "document.getElementById('detailsModal').classList.add('active');";
            ClientScript.RegisterStartupScript(
                this.GetType(), "OpenModal", modalScript, true);
        }
        catch (Exception ex)
        {
            lblMessage.Text = "Error loading details: " + ex.Message;
        }
    }

    private void BindBillsGrid(DataTable dt)
    {
        gvBills.DataSource =
            (dt != null && dt.Rows.Count > 0) ? (object)dt : null;
        gvBills.DataBind();
    }

    private DataTable LoadBillsByCounterCloseId(string counterCloseId)
    {
        DataTable dt = new DataTable();
        using (SqlConnection con = new SqlConnection(cons))
        {
            string query = @"
                SELECT Id, MemberNo, Subtotal, DiscountApplied, TaxApplied,
                       AmountPaid, bill_to, PaymentMethod, CardNumber,
                       CashierName, PaymentDate
                FROM   Bills
                WHERE  CounterCloseId = @CounterCloseId
                ORDER  BY Id DESC";

            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@CounterCloseId", counterCloseId);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }
        }
        return dt;
    }

    protected void gvBills_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName != "ShowItems") return;

        string billId = e.CommandArgument.ToString();

        try
        {
            DataTable dtBills = Session["CurrentBillsDT"] as DataTable;
            if (dtBills != null)
                BindBillsGrid(dtBills);

            DataTable dtItems = LoadBillItemsByBillId(billId);

            if (dtItems.Rows.Count > 0)
            {
                gvBillItems.DataSource = dtItems;
                gvBillItems.DataBind();

                string showItemsScript = @"
                    document.getElementById('detailsModal').classList.add('active');
                    document.getElementById('loadingPanel').style.display='none';
                    document.getElementById('billItemsPanel').style.display='block';";
                ClientScript.RegisterStartupScript(
                    this.GetType(), "ShowItems", showItemsScript, true);
            }
            else
            {
                // FIX: was broken "No items found for Bill ID {billId}."
                ShowAlert("No items found for Bill ID " + billId + ".");
            }
        }
        catch (Exception ex)
        {
            // FIX: was broken "Error: {ex.Message}"
            ShowAlert("Error: " + ex.Message);
        }
    }

    private DataTable LoadBillItemsByBillId(string billId)
    {
        DataTable dt = new DataTable();
        using (SqlConnection con = new SqlConnection(cons))
        {
            string query = @"
                SELECT bi.MenuItemId, bi.Name, bi.Price, bi.Quantity, bi.LineTotal,
                       b.KOT_Number, b.Cover
                FROM   BillItems bi
                INNER  JOIN Bills b ON b.Id = bi.BillId
                WHERE  bi.BillId = @BillId";

            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@BillId", Convert.ToInt32(billId));
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }
        }
        return dt;
    }

    // ─── GRID EVENTS ────────────────────────────────────────────────────────────

    protected void gvCounterClose_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvCounterClose.PageIndex = e.NewPageIndex;
        LoadCounterCloseData();
    }

    protected void gvCounterClose_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView drv = (DataRowView)e.Row.DataItem;
            if (drv["VoucherId"] != DBNull.Value &&
                Convert.ToInt32(drv["VoucherId"]) > 0)
            {
                e.Row.Attributes.Add("class", "row-posted");
            }
        }
    }
}

