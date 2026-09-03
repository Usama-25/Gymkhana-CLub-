using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;

public partial class CancelKot : System.Web.UI.Page
{
    // ── Connection strings ──────────────────────────────────────────────────
    private readonly string _conMember =
        ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;
    private readonly string _conRestaurant =
        ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;

    // ── Vague phrases rejected for audit quality ────────────────────────────
    private static readonly string[] VagueWords =
    {
        "ok","okay","cancel","done","cancelled","yes","no","na","n/a",
        "nothing","nil","none","fine","sure","agreed","approved","noted","..."
    };

    // ───────────────────────────────────────────────────────────────────────
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            string billIdParam = Request.QueryString["billId"];
            int billId;
            if (string.IsNullOrWhiteSpace(billIdParam) || !int.TryParse(billIdParam, out billId))
            {
                ShowError("Invalid or missing Bill ID. Please open this page from the POS.");
                return;
            }

            LoadKotData(billId);
        }
    }

    // ── Load KOT + items from database ─────────────────────────────────────
    private void LoadKotData(int billId)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(_conRestaurant))
            {
                con.Open();

                // --- Bill / KOT master row ---
                const string sqlBill = @"
                    SELECT b.Id, b.KOT_Number, b.BillNo, b.CreatedAt,
                           b.MemberNo, b.TableNumber, b.WaiterName,
                           b.DepartmentName, b.EmployeeID,
                           b.roomno, b.bill_to, b.Cover,
                           b.Status, b.Subtotal
                    FROM   Bills b
                    WHERE  b.Id = @BillId";

                DataRow dr;
                using (SqlCommand cmd = new SqlCommand(sqlBill, con))
                {
                    cmd.Parameters.AddWithValue("@BillId", billId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        ShowError("KOT record not found for the provided Bill ID.");
                        return;
                    }
                    dr = dt.Rows[0];
                }

                // --- Bill items ---
                const string sqlItems = @"
                    SELECT Name, Quantity, Price, LineTotal
                    FROM   BillItems
                    WHERE  BillId = @BillId
                    ORDER  BY Id";

                StringBuilder itemsJs = new StringBuilder("[");
                using (SqlCommand cmd2 = new SqlCommand(sqlItems, con))
                {
                    cmd2.Parameters.AddWithValue("@BillId", billId);
                    using (SqlDataReader rdr = cmd2.ExecuteReader())
                    {
                        bool first = true;
                        while (rdr.Read())
                        {
                            if (!first) itemsJs.Append(",");
                            first = false;
                            itemsJs.AppendFormat(
                                "{{\"Name\":{0},\"Quantity\":{1},\"Price\":{2},\"LineTotal\":{3}}}",
                                JsonStr(rdr["Name"].ToString()),
                                rdr["Quantity"],
                                ((decimal)rdr["Price"]).ToString("F2"),
                                ((decimal)rdr["LineTotal"]).ToString("F2"));
                        }
                    }
                }
                itemsJs.Append("]");

                // --- Resolve member name (from Membership DB if available) ---
                string memberName = ResolveGuestName(dr, billId);

                // --- Store hidden fields for postback ---
                hfBillId.Value = billId.ToString();
                hfKotNumber.Value = dr["KOT_Number"].ToString();

                // --- Build JS payload and push to page ---
                string loggedInUser = GetCurrentUser();
                string empId = Session["EmployeeID"] != null ? Session["EmployeeID"].ToString() : "";

                // FIX: use string.Format (no $ interpolation in .NET 4.0)
                string payload = string.Format(@"{{
                    ""kotNumber"" : {0},
                    ""billNo""    : {1},
                    ""createdAt"" : {2},
                    ""memberNo""  : {3},
                    ""memberName"": {4},
                    ""tableNumber"": {5},
                    ""deptName""  : {6},
                    ""waiterName"": {7},
                    ""empId""     : {8},
                    ""roomNo""    : {9},
                    ""billTo""    : {10},
                    ""cover""     : {11},
                    ""status""    : {12},
                    ""subtotal""  : {13},
                    ""cancelledBy"": {14},
                    ""items""     : {15}
                }}",
                    JsonStr(dr["KOT_Number"].ToString()),
                    JsonStr(dr["BillNo"].ToString()),
                    JsonStr(Convert.ToDateTime(dr["CreatedAt"]).ToString("dd-MMM-yyyy  hh:mm tt")),
                    JsonStr(dr["MemberNo"].ToString()),
                    JsonStr(memberName),
                    JsonStr(dr["TableNumber"].ToString()),
                    JsonStr(dr["DepartmentName"].ToString()),
                    JsonStr(dr["WaiterName"].ToString()),
                    JsonStr(empId),
                    JsonStr(dr["roomno"] == DBNull.Value ? "" : dr["roomno"].ToString()),
                    JsonStr(dr["bill_to"].ToString()),
                    JsonStr(dr["Cover"].ToString()),
                    JsonStr(dr["Status"] != null ? dr["Status"].ToString() : "Pending"),
                    dr["Subtotal"] == DBNull.Value ? "0" : ((decimal)dr["Subtotal"]).ToString("F2"),
                    JsonStr(loggedInUser),
                    itemsJs.ToString()
                );

                // FIX: string.Format instead of $ interpolation
                string script = string.Format("populateKotData({0});", payload);
                ScriptManager.RegisterStartupScript(this, GetType(), "kotdata", script, true);
            }
        }
        catch (Exception ex)
        {
            ShowError("Error loading KOT data: " + ex.Message);
        }
    }

    // ── Try to resolve a display name for the member ────────────────────────
    private string ResolveGuestName(DataRow dr, int billId)
    {
        if (dr.Table.Columns.Contains("GuestName") && dr["GuestName"] != DBNull.Value
            && !string.IsNullOrWhiteSpace(dr["GuestName"].ToString()))
            return dr["GuestName"].ToString();

        string memberNo = dr["MemberNo"] != null ? dr["MemberNo"].ToString() : "";
        if (string.IsNullOrWhiteSpace(memberNo)) return "—";

        try
        {
            using (SqlConnection con = new SqlConnection(_conMember))
            {
                con.Open();
                const string sql = @"
                    SELECT TOP 1 ISNULL(FirstName,'') + ' ' + ISNULL(LastName,'') AS FullName
                    FROM   Members
                    WHERE  MemberNo = @MemberNo";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        return result.ToString().Trim();
                }
            }
        }
        catch { /* Membership DB optional – fall through */ }

        return memberNo;
    }

    // ── Cancel KOT button click ─────────────────────────────────────────────
    protected void btnCancelKOT_Click(object sender, EventArgs e)
    {
        string memberReason = txtMemberReason.Text.Trim();
        string managerRemarks = txtManagerRemarks.Text.Trim();
        bool verified = chkVerify.Checked;

        string validationError = ServerSideValidate(memberReason, managerRemarks, verified);
        if (!string.IsNullOrEmpty(validationError))
        {
            ShowError(validationError);
            return;
        }

        int billId;
        if (!int.TryParse(hfBillId.Value, out billId))
        {
            ShowError("Session expired or invalid Bill ID. Please reload.");
            return;
        }

        try
        {
            SaveCancellationRecord(billId, memberReason, managerRemarks);
            UpdateBillStatus(billId);

            // FIX: string concatenation instead of $ interpolation
            ShowSuccess("KOT #" + hfKotNumber.Value +
                        " has been successfully cancelled. " +
                        "Audit record saved. Reference ID stored in cancel_kot log.");
            DisableForm();
        }
        catch (Exception ex)
        {
            ShowError("Cancellation failed: " + ex.Message);
        }
    }

    // ── Server-side validation ──────────────────────────────────────────────
    private string ServerSideValidate(string reason, string remarks, bool verified)
    {
        if (string.IsNullOrWhiteSpace(reason))
            return "Member complaint / cancellation reason is mandatory.";
        if (reason.Length < 30)
            return "Cancellation reason must be at least 30 characters.";
        if (IsVague(reason))
            return "Vague cancellation reason detected. Please provide complete details.";

        if (string.IsNullOrWhiteSpace(remarks))
            return "Management approval remarks are mandatory.";
        if (remarks.Length < 25)
            return "Management remarks must be at least 25 characters.";
        if (IsVague(remarks))
            return "Vague management remarks detected. Please provide a full approval justification.";

        if (!verified)
            return "Verification checkbox must be selected to proceed with cancellation.";

        return string.Empty;
    }

    private bool IsVague(string text)
    {
        string clean = text.Trim().ToLowerInvariant();
        clean = System.Text.RegularExpressions.Regex
                    .Replace(clean, @"[^a-z0-9 ]", "")
                    .Trim();
        foreach (string vw in VagueWords)
            if (clean == vw) return true;
        if (System.Text.RegularExpressions.Regex.IsMatch(text.Trim(), @"^[.\-_ ]+$"))
            return true;
        return false;
    }

    // ── Persist cancellation record ─────────────────────────────────────────
    private void SaveCancellationRecord(int billId, string memberReason, string managerRemarks)
    {
        string combinedRemarks =
            "[MEMBER COMPLAINT]\r\n" + memberReason +
            "\r\n\r\n[MANAGEMENT APPROVAL]\r\n" + managerRemarks;

        string itemsSummary = BuildItemsSummary(billId);

        DataRow bill = FetchBillRow(billId);
        if (bill == null) throw new Exception("Bill record not found.");

        string cancelledBy = GetCurrentUser();
        string empId = Session["EmployeeID"] != null ? Session["EmployeeID"].ToString() : "";

        using (SqlConnection con = new SqlConnection(_conRestaurant))
        {
            con.Open();
            const string sql = @"
                INSERT INTO cancel_kot
                    (BillId, KOT_Number, MemberNo, MemberName, TableNumber,
                     DepartmentName, WaiterName, Emp_ID, ItemsSummary,
                     Remarks, CancelledAt, RoomNo, bill_to, Cover, Subtotal)
                VALUES
                    (@BillId, @KOT_Number, @MemberNo, @MemberName, @TableNumber,
                     @DepartmentName, @WaiterName, @Emp_ID, @ItemsSummary,
                     @Remarks, @CancelledAt, @RoomNo, @bill_to, @Cover, @Subtotal)";

            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@BillId", billId);
                cmd.Parameters.AddWithValue("@KOT_Number", DbVal(bill["KOT_Number"]));
                cmd.Parameters.AddWithValue("@MemberNo", DbVal(bill["MemberNo"]));
                cmd.Parameters.AddWithValue("@MemberName", cancelledBy);
                cmd.Parameters.AddWithValue("@TableNumber", DbVal(bill["TableNumber"]));
                cmd.Parameters.AddWithValue("@DepartmentName", DbVal(bill["DepartmentName"]));
                cmd.Parameters.AddWithValue("@WaiterName", DbVal(bill["WaiterName"]));
                cmd.Parameters.AddWithValue("@Emp_ID", empId);
                cmd.Parameters.AddWithValue("@ItemsSummary", itemsSummary);
                cmd.Parameters.AddWithValue("@Remarks",
                    combinedRemarks.Length > 500
                        ? combinedRemarks.Substring(0, 500)
                        : combinedRemarks);
                cmd.Parameters.AddWithValue("@CancelledAt", DateTime.Now);
                cmd.Parameters.AddWithValue("@RoomNo",
                    bill["roomno"] == DBNull.Value
                        ? (object)DBNull.Value
                        : Convert.ToInt32(bill["roomno"]));
                cmd.Parameters.AddWithValue("@bill_to", DbVal(bill["bill_to"]));
                cmd.Parameters.AddWithValue("@Cover", DbVal(bill["Cover"]));
                cmd.Parameters.AddWithValue("@Subtotal",
                    bill["Subtotal"] == DBNull.Value
                        ? (object)DBNull.Value
                        : Convert.ToDecimal(bill["Subtotal"]));
                cmd.ExecuteNonQuery();
            }
        }
    }

    // ── Mark bill as Cancelled ──────────────────────────────────────────────
    private void UpdateBillStatus(int billId)
    {
        using (SqlConnection con = new SqlConnection(_conRestaurant))
        {
            con.Open();
            const string sql = "UPDATE Bills SET Status = 'Cancelled' WHERE Id = @BillId";
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@BillId", billId);
                cmd.ExecuteNonQuery();
            }
        }
    }

    // ── Build items summary string for audit ────────────────────────────────
    private string BuildItemsSummary(int billId)
    {
        StringBuilder sb = new StringBuilder();
        using (SqlConnection con = new SqlConnection(_conRestaurant))
        {
            con.Open();
            const string sql = "SELECT Name, Quantity, Price, LineTotal FROM BillItems WHERE BillId=@BillId ORDER BY Id";
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@BillId", billId);
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        // FIX: string.Format instead of $ interpolation
                        sb.AppendLine(string.Format("{0} x{1} @ {2:N2} = PKR {3:N2}",
                            rdr["Name"],
                            rdr["Quantity"],
                            rdr["Price"],
                            rdr["LineTotal"]));
                    }
                }
            }
        }
        return sb.ToString();
    }

    // ── Fetch a single bill row ─────────────────────────────────────────────
    private DataRow FetchBillRow(int billId)
    {
        using (SqlConnection con = new SqlConnection(_conRestaurant))
        {
            con.Open();
            const string sql = "SELECT * FROM Bills WHERE Id = @BillId";
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@BillId", billId);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt.Rows.Count > 0 ? dt.Rows[0] : null;
            }
        }
    }

    // ── Helpers ─────────────────────────────────────────────────────────────
    private string GetCurrentUser()
    {
        if (Session["UserName"] != null) return Session["UserName"].ToString();
        if (Session["CashierName"] != null) return Session["CashierName"].ToString();
        if (User.Identity != null && !string.IsNullOrEmpty(User.Identity.Name))
            return User.Identity.Name;
        return "Unknown";
    }

    private static object DbVal(object val)
    {
        if (val == DBNull.Value || val == null)
            return DBNull.Value;
        return val;
    }

    // FIX: proper string concatenation — no $ interpolation
    private static string JsonStr(string s)
    {
        if (s == null) return "null";
        s = s.Replace("\\", "\\\\")
             .Replace("\"", "\\\"")
             .Replace("\r", "\\r")
             .Replace("\n", "\\n")
             .Replace("\t", "\\t");
        return "\"" + s + "\"";
    }

    // ── UI feedback helpers ──────────────────────────────────────────────────
    private void ShowError(string msg)
    {
        // FIX: string.Format instead of $ interpolation
        string js = string.Format(@"
            document.getElementById('alertError').classList.add('visible');
            document.getElementById('alertErrorMsg').textContent = {0};
            document.getElementById('loadingOverlay').classList.remove('visible');
            window.scrollTo({{top:0,behavior:'smooth'}});",
            JsonStr(msg));
        ScriptManager.RegisterStartupScript(this, GetType(), "showErr", js, true);
    }

    private void ShowSuccess(string msg)
    {
        // FIX: string.Format instead of $ interpolation
        string js = string.Format(@"
            document.getElementById('alertSuccess').classList.add('visible');
            document.getElementById('alertSuccessMsg').textContent = {0};
            document.getElementById('alertError').classList.remove('visible');
            document.getElementById('loadingOverlay').classList.remove('visible');
            window.scrollTo({{top:0,behavior:'smooth'}});",
            JsonStr(msg));
        ScriptManager.RegisterStartupScript(this, GetType(), "showOk", js, true);
    }

    private void DisableForm()
    {
        string js = @"
            document.getElementById('txtMemberReason').disabled  = true;
            document.getElementById('txtManagerRemarks').disabled = true;
            var chk = document.getElementById('chkVerify_0') || document.getElementById('chkVerify');
            if (chk) chk.disabled = true;
            var btnKot = document.querySelector('.btn-cancel-kot');
            if (btnKot) btnKot.disabled = true;";
        ScriptManager.RegisterStartupScript(this, GetType(), "disableForm", js, true);
    }
}

