using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Receipt_Page : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            txtReceiptDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            btnSave.Visible = false; // hidden until valid
            AutoSelectDepartmentForReceiptMode();
        }
        else
        {
            if (IsPostBack)
            {
                ValidateAndToggleSave(); // ✔ NO REBIND
            }
        }
    }



    protected void rblReceiptType_SelectedIndexChanged(object sender, EventArgs e)
    {
        ddlReceiptMode.DataBind();
        AutoSelectDepartmentForReceiptMode();
    }

    protected void ddlReceiptMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        AutoSelectDepartmentForReceiptMode();
        PerformMemberValidationIfRequired();
    }

    private void AutoSelectDepartmentForReceiptMode()
    {
        if (string.IsNullOrEmpty(ddlReceiptMode.SelectedValue)) return;

        int modeId;
        if (!int.TryParse(ddlReceiptMode.SelectedValue, out modeId)) return;

        string financeConnStr = ConfigurationManager.ConnectionStrings["FinanceConnectionString"].ConnectionString;

        using (SqlConnection con = new SqlConnection(financeConnStr))
        {
            con.Open();

            SqlCommand cmd = new SqlCommand(@"
                SELECT rm.Dept_ID, d.Dept_Name
                FROM ReceiptModes rm
                LEFT JOIN Department d ON rm.Dept_ID = d.Dept_ID
                WHERE rm.ReceiptModeID = @ModeID", con);

            cmd.Parameters.AddWithValue("@ModeID", modeId);

            using (SqlDataReader rdr = cmd.ExecuteReader())
            {
                if (rdr.Read() && rdr["Dept_ID"] != DBNull.Value)
                {
                    string deptIdStr = rdr["Dept_ID"].ToString();
                    string deptName = rdr["Dept_Name"] != DBNull.Value ? rdr["Dept_Name"].ToString().Trim() : "";

                    if (ddlCC.Items.Count == 0) ddlCC.DataBind();

                    // 1. Direct value match
                    ListItem directMatch = ddlCC.Items.FindByValue(deptIdStr);
                    if (directMatch != null)
                    {
                        ddlCC.SelectedValue = deptIdStr;
                        return;
                    }

                    // 2. Direct text match
                    if (!string.IsNullOrEmpty(deptName))
                    {
                        ListItem textMatch = ddlCC.Items.FindByText(deptName);
                        if (textMatch != null)
                        {
                            ddlCC.SelectedValue = textMatch.Value;
                            return;
                        }

                        // 3. Clean text match
                        string cleanDeptName = deptName.ToLower().Replace("pool", "").Replace("course", "").Replace("room", "").Replace("department", "").Trim();
                        if (!string.IsNullOrEmpty(cleanDeptName))
                        {
                            foreach (ListItem item in ddlCC.Items)
                            {
                                string itemTextLower = item.Text.ToLower().Trim();
                                if (itemTextLower.Contains(cleanDeptName) || cleanDeptName.Contains(itemTextLower))
                                {
                                    ddlCC.SelectedValue = item.Value;
                                    return;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private bool IsValidateMemberForSelectedMode()
    {
        if (string.IsNullOrEmpty(ddlReceiptMode.SelectedValue)) return false;

        int modeId;
        if (!int.TryParse(ddlReceiptMode.SelectedValue, out modeId)) return false;

        string financeConnStr = ConfigurationManager.ConnectionStrings["FinanceConnectionString"].ConnectionString;

        using (SqlConnection con = new SqlConnection(financeConnStr))
        {
            con.Open();
            SqlCommand cmd = new SqlCommand("SELECT ISNULL(ValidateMember, 0) FROM ReceiptModes WHERE ReceiptModeID = @ModeID", con);
            cmd.Parameters.AddWithValue("@ModeID", modeId);
            object res = cmd.ExecuteScalar();
            if (res != null && res != DBNull.Value)
            {
                return Convert.ToBoolean(res);
            }
        }
        return false;
    }

    private string ExtractRawMemberNo(string input)
    {
        if (string.IsNullOrWhiteSpace(input)) return "";
        string trimmed = input.Trim();
        if (trimmed.Contains(" - "))
        {
            return trimmed.Split(new string[] { " - " }, StringSplitOptions.None)[0].Trim();
        }
        return trimmed;
    }

    private int GetPartyIdFromRef(string memberRefInput)
    {
        string rawNo = ExtractRawMemberNo(memberRefInput);
        int parsedId;
        if (int.TryParse(rawNo, out parsedId)) return parsedId;

        try
        {
            string connStr = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;
            using (SqlConnection mcon = new SqlConnection(connStr))
            {
                mcon.Open();
                SqlCommand mcmd = new SqlCommand("SELECT TOP 1 MemberID FROM MemberProfile WHERE MemberNo = @MNo", mcon);
                mcmd.Parameters.AddWithValue("@MNo", rawNo);
                object mRes = mcmd.ExecuteScalar();
                if (mRes != null && mRes != DBNull.Value) return Convert.ToInt32(mRes);
            }
        }
        catch { }

        return 1;
    }

    private string GetCreditHeadForSelectedMode()
    {
        if (string.IsNullOrEmpty(ddlReceiptMode.SelectedValue)) return ddlP_Head.SelectedValue;
        int modeId;
        if (!int.TryParse(ddlReceiptMode.SelectedValue, out modeId)) return ddlP_Head.SelectedValue;

        try
        {
            string fConnStr = ConfigurationManager.ConnectionStrings["FinanceConnectionString"].ConnectionString;
            using (SqlConnection fcon = new SqlConnection(fConnStr))
            {
                fcon.Open();
                SqlCommand fcmd = new SqlCommand("SELECT FinancialHead FROM ReceiptModes WHERE ReceiptModeID = @ModeID", fcon);
                fcmd.Parameters.AddWithValue("@ModeID", modeId);
                object fRes = fcmd.ExecuteScalar();
                if (fRes != null && fRes != DBNull.Value && !string.IsNullOrEmpty(fRes.ToString()))
                {
                    return fRes.ToString();
                }
            }
        }
        catch { }

        return ddlP_Head.SelectedValue;
    }

    private bool ValidateAndPopulateMember(string rawMemberInput, out string formattedRef, out string memberName, out string cnic, out string phone)
    {
        formattedRef = rawMemberInput;
        memberName = "";
        cnic = "";
        phone = "";

        if (string.IsNullOrWhiteSpace(rawMemberInput)) return false;

        string searchNo = ExtractRawMemberNo(rawMemberInput);
        string memberConnStr = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;

        using (SqlConnection con = new SqlConnection(memberConnStr))
        {
            con.Open();

            SqlCommand cmd = new SqlCommand(@"
                SELECT MemberNo AS MembershipNo, MemberName, ISNULL(NIC, '') AS CNIC, ISNULL(Mobile, ResidentialPhone1) AS Phone
                FROM MemberProfile
                WHERE MemberNo = @SearchNo

                UNION ALL

                SELECT MembershipNo, SpouseName AS MemberName, ISNULL(SpouseCNIC, '') AS CNIC, ISNULL(SpousePhone, '') AS Phone
                FROM MemberSpouses
                WHERE MembershipNo = @SearchNo

                UNION ALL

                SELECT MembershipNo, ChildName AS MemberName, ISNULL(CNIC, '') AS CNIC, ISNULL(ChildPhone, '') AS Phone
                FROM MemberChildren
                WHERE MembershipNo = @SearchNo", con);

            cmd.Parameters.AddWithValue("@SearchNo", searchNo);

            using (SqlDataReader rdr = cmd.ExecuteReader())
            {
                if (rdr.Read())
                {
                    string foundNo = rdr["MembershipNo"].ToString();
                    memberName = rdr["MemberName"].ToString();
                    cnic = rdr["CNIC"].ToString();
                    phone = rdr["Phone"].ToString();

                    formattedRef = foundNo + " - " + memberName;
                    return true;
                }
            }
        }

        return false;
    }

    private void PerformMemberValidationIfRequired()
    {
        if (IsValidateMemberForSelectedMode())
        {
            string rawInput = txtReceiptRef.Text.Trim();
            if (!string.IsNullOrWhiteSpace(rawInput))
            {
                string formattedRef, memberName, cnic, phone;
                if (ValidateAndPopulateMember(rawInput, out formattedRef, out memberName, out cnic, out phone))
                {
                    txtReceiptRef.Text = formattedRef;
                    txtReceiptPerson.Text = memberName;
                    if (!string.IsNullOrEmpty(cnic)) txtReceiptP_CNIC.Text = cnic;
                    if (!string.IsNullOrEmpty(phone)) txtReceiptP_Phone.Text = phone;

                    lblInformation.Text = "Member Validated: " + memberName;
                    lblInformation.Style["color"] = "green";
                }
                else
                {
                    lblInformation.Text = "Invalid Member # (Not found in MemberProfile, MemberSpouses, or MemberChildren)";
                    lblInformation.Style["color"] = "red";
                    ScriptManager.RegisterStartupScript(this, this.GetType(),
                        "invalidMemberRef",
                        "alert('Invalid Member #! Not found in MemberProfile, MemberSpouses, or MemberChildren.');", true);
                }
            }
        }
    }

    protected void txtReceiptRef_TextChanged(object sender, EventArgs e)
    {
        PerformMemberValidationIfRequired();

        // Only auto-populate for Activity / Event receipts
        if (rblReceiptType.SelectedValue != "3") return;

        string bookingIdText = ExtractRawMemberNo(txtReceiptRef.Text);
        int bookingMainId;

        if (string.IsNullOrWhiteSpace(bookingIdText)) return;

        if (!int.TryParse(bookingIdText, out bookingMainId))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                "invalidBookingRef",
                "alert('Please enter a valid Booking ID.');", true);
            return;
        }

        string bookingConnStr = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

        using (SqlConnection con = new SqlConnection(bookingConnStr))
        {
            con.Open();

            SqlCommand cmd = new SqlCommand(@"
                SELECT ISNULL(Balance,0) - ISNULL(Advance,0) AS RemainingBalance
                FROM Booking_Main_Menu
                WHERE BookingMain_Id = @BookingMainId", con);

            cmd.Parameters.AddWithValue("@BookingMainId", bookingMainId);

            object result = cmd.ExecuteScalar();

            if (result == null || result == DBNull.Value)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(),
                    "noBookingRef",
                    "alert('No booking found for this ID.');", true);
                return;
            }

            decimal remaining = Convert.ToDecimal(result);

            if (remaining <= 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(),
                    "paidRef",
                    "alert('This booking has already been fully paid.');", true);
                txtReceiptAmount.Text = "0.00";
                getBankCharges();
                return;
            }

            // Populate Receipt Amount — remains editable for the cashier
            txtReceiptAmount.Text = remaining.ToString("0.00");
            getBankCharges();
        }
    }

    protected void BtnAdd(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtReceiptRef.Text)) return;

        bool validateRequired = IsValidateMemberForSelectedMode();
        string selectedType = rblReceiptType.SelectedValue;
        string[] rawMembers = txtReceiptRef.Text.Split(',');

        if (validateRequired)
        {
            List<string> formattedList = new List<string>();
            foreach (string m in rawMembers)
            {
                if (string.IsNullOrWhiteSpace(m)) continue;
                string formattedRef, memberName, cnic, phone;
                if (ValidateAndPopulateMember(m, out formattedRef, out memberName, out cnic, out phone))
                {
                    formattedList.Add(formattedRef);
                    if (string.IsNullOrWhiteSpace(txtReceiptPerson.Text))
                        txtReceiptPerson.Text = memberName;
                    if (string.IsNullOrWhiteSpace(txtReceiptP_CNIC.Text) && !string.IsNullOrEmpty(cnic))
                        txtReceiptP_CNIC.Text = cnic;
                    if (string.IsNullOrWhiteSpace(txtReceiptP_Phone.Text) && !string.IsNullOrEmpty(phone))
                        txtReceiptP_Phone.Text = phone;
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "invalidMemberAdd",
                        "alert('Invalid Member # (" + m.Trim() + ")! Not found in MemberProfile, MemberSpouses, or MemberChildren.');", true);
                    return;
                }
            }
            if (formattedList.Count > 0)
            {
                txtReceiptRef.Text = string.Join(",", formattedList);
            }
        }

        string[] members = txtReceiptRef.Text.Split(',');

        // ── Case 1: Bypass check for New Memberships (2) or Other (4) ──
        if (selectedType == "2" || selectedType == "4")
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("MemberNo");
            dt.Columns.Add("MemberName");
            dt.Columns.Add("LMonthPayable");
            dt.Columns.Add("overallPayable");

            foreach (string m in members)
            {
                if (string.IsNullOrWhiteSpace(m)) continue;
                DataRow dr = dt.NewRow();
                dr["MemberNo"] = ExtractRawMemberNo(m);
                dr["MemberName"] = txtReceiptPerson.Text; // Fallback to contact person name
                dr["LMonthPayable"] = 0;
                dr["overallPayable"] = 0;
                dt.Rows.Add(dr);
            }

            hfMemberData.Value = DataTableToJson(dt);
            gvReceipts.DataSource = dt;
            gvReceipts.DataBind();
            btnSave.Visible = true;
            ValidateAndToggleSave();
            return;
        }

        // ── Case 2: Activity / Event — lookup by BookingMain_Id ──
        else if (selectedType == "3")
        {
            string bookingIdText = ExtractRawMemberNo(txtReceiptRef.Text);
            int bookingMainId;

            if (!int.TryParse(bookingIdText, out bookingMainId))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(),
                    "invalidBooking",
                    "alert('Please enter a valid Booking ID.');", true);
                return;
            }

            string bookingConnStr = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

            DataTable dt = new DataTable();
            dt.Columns.Add("MemberNo");
            dt.Columns.Add("MemberName");
            dt.Columns.Add("LMonthPayable");
            dt.Columns.Add("overallPayable");

            using (SqlConnection con = new SqlConnection(bookingConnStr))
            {
                con.Open();

                SqlCommand cmd = new SqlCommand(@"
            SELECT
                BookingMain_Id,
                MemberShipNo,
                ISNULL(Balance,0) AS Balance,
                ISNULL(Advance,0) AS Advance,
                ISNULL(Balance,0)-ISNULL(Advance,0) AS RemainingBalance
            FROM Booking_Main_Menu
            WHERE BookingMain_Id=@BookingMainId", con);

                cmd.Parameters.AddWithValue("@BookingMainId", bookingMainId);

                SqlDataReader rdr = cmd.ExecuteReader();

                if (!rdr.Read())
                {
                    rdr.Close();
                    ScriptManager.RegisterStartupScript(this, this.GetType(),
                        "noBooking",
                        "alert('No booking found for this ID.');", true);
                    return;
                }

                decimal remaining = Convert.ToDecimal(rdr["RemainingBalance"]);

                if (remaining <= 0)
                {
                    rdr.Close();
                    ScriptManager.RegisterStartupScript(this, this.GetType(),
                        "paid",
                        "alert('This booking has already been fully paid.');", true);
                    return;
                }

                // Grid
                DataRow dr = dt.NewRow();
                dr["MemberNo"] = rdr["BookingMain_Id"].ToString();
                dr["MemberName"] = rdr["MemberShipNo"].ToString();
                dr["LMonthPayable"] = "0.00";
                dr["overallPayable"] = remaining.ToString("0.00");
                dt.Rows.Add(dr);

                rdr.Close();
            }

            hfMemberData.Value = DataTableToJson(dt);
            gvReceipts.DataSource = dt;
            gvReceipts.DataBind();

            btnSave.Visible = true;
            ValidateAndToggleSave();
            return;
        }

        // ── Case 3: Standard MemberNo check for all other types ──
        string memberConnStr = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;

        using (SqlConnection con = new SqlConnection(memberConnStr))
        {
            con.Open();

            DataTable dt = new DataTable();
            dt.Columns.Add("MemberNo");
            dt.Columns.Add("MemberName");
            dt.Columns.Add("LMonthPayable");
            dt.Columns.Add("overallPayable");

            foreach (string m in members)
            {
                if (string.IsNullOrWhiteSpace(m)) continue;
                string cleanMemberNo = ExtractRawMemberNo(m);

                // 1. Query MemberProfile
                using (SqlCommand mpCmd = new SqlCommand("SELECT TOP 1 MemberID, MemberNo, MemberName FROM MemberProfile WHERE MemberNo = @MNo", con))
                {
                    mpCmd.Parameters.AddWithValue("@MNo", cleanMemberNo);
                    using (SqlDataReader rdr = mpCmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            int memberId = Convert.ToInt32(rdr["MemberID"]);
                            string memberNo = rdr["MemberNo"].ToString();
                            string memberName = rdr["MemberName"].ToString();
                            rdr.Close();

                            decimal lmonth = 0;
                            decimal overall = 0;

                            // 2. Query MemberPayment cleanly using string parameters
                            using (SqlCommand payCmd = new SqlCommand(@"
                                SELECT TOP 1 ISNULL(Dept, 0) AS LMonthPayable, ISNULL(Credit, 0) AS overallPayable 
                                FROM MemberPayment 
                                WHERE MemberNo = @MNoStr OR MemberNo = @MIdStr 
                                ORDER BY ID DESC", con))
                            {
                                payCmd.Parameters.AddWithValue("@MNoStr", memberNo);
                                payCmd.Parameters.AddWithValue("@MIdStr", memberId.ToString());

                                using (SqlDataReader payRdr = payCmd.ExecuteReader())
                                {
                                    if (payRdr.Read())
                                    {
                                        lmonth = Convert.ToDecimal(payRdr["LMonthPayable"]);
                                        overall = Convert.ToDecimal(payRdr["overallPayable"]);
                                    }
                                }
                            }

                            DataRow dr = dt.NewRow();
                            dr["MemberNo"] = memberNo;
                            dr["MemberName"] = memberName;
                            dr["LMonthPayable"] = lmonth;
                            dr["overallPayable"] = overall;
                            dt.Rows.Add(dr);
                        }
                        else
                        {
                            rdr.Close();
                            if (validateRequired)
                            {
                                DataRow dr = dt.NewRow();
                                dr["MemberNo"] = cleanMemberNo;
                                dr["MemberName"] = !string.IsNullOrWhiteSpace(txtReceiptPerson.Text) ? txtReceiptPerson.Text : "Validated Member";
                                dr["LMonthPayable"] = 0;
                                dr["overallPayable"] = 0;
                                dt.Rows.Add(dr);
                            }
                        }
                    }
                }
            }

            if (dt.Rows.Count == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "noRecord",
                    "alert('No member found.');", true);
                return;
            }

            hfMemberData.Value = DataTableToJson(dt);

            gvReceipts.DataSource = dt;
            gvReceipts.DataBind();
            btnSave.Visible = true;
        }

        // Validate after grid binds
        ValidateAndToggleSave();
    }

    private string DataTableToJson(DataTable dt)
    {
        JavaScriptSerializer js = new JavaScriptSerializer();
        var rows = new System.Collections.Generic.List<System.Collections.Generic.Dictionary<string, object>>();

        foreach (DataRow dr in dt.Rows)
        {
            var row = new System.Collections.Generic.Dictionary<string, object>();
            foreach (DataColumn col in dt.Columns)
            {
                row[col.ColumnName] = dr[col];
            }
            rows.Add(row);
        }
        return js.Serialize(rows);
    }

    // Convert JSON string back to DataTable
    private DataTable JsonToDataTable(string json)
    {
        JavaScriptSerializer js = new JavaScriptSerializer();
        var rows = js.Deserialize<System.Collections.Generic.List<System.Collections.Generic.Dictionary<string, object>>>(json);

        DataTable dt = new DataTable();

        if (rows.Count > 0)
        {
            // Create columns
            foreach (var key in rows[0].Keys)
            {
                dt.Columns.Add(key);
            }

            // Fill rows
            foreach (var row in rows)
            {
                DataRow dr = dt.NewRow();
                foreach (var key in row.Keys)
                {
                    dr[key] = row[key];
                }
                dt.Rows.Add(dr);
            }
        }
        return dt;
    }

    private bool IsGridTotalValid()
    {
        decimal receiptAmt = valstringAmount(txtReceiptAmount.Text);
        decimal bankCharges = valstringAmount(txtbnkAmount.Text);
        decimal headerTotal = receiptAmt + bankCharges;

        decimal gridTotal = 0;

        foreach (GridViewRow row in gvReceipts.Rows)
        {
            if (row.RowType == DataControlRowType.DataRow)
            {
                TextBox txtRowAmount = (TextBox)row.FindControl("txtRowAmount");

                if (txtRowAmount == null || string.IsNullOrWhiteSpace(txtRowAmount.Text))
                    return false;

                gridTotal += valstringAmount(txtRowAmount.Text);
            }
        }

        return Math.Round(gridTotal, 2) == Math.Round(headerTotal, 2);
    }
    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!IsGridTotalValid())
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "err",
                "alert('Total mismatch! Save not allowed.');", true);
            return;
        }

        if (string.IsNullOrWhiteSpace(txtReceiptRef.Text)) return;

        string financeConnStr = ConfigurationManager.ConnectionStrings["FinanceConnectionString"].ConnectionString;
        string[] members = txtReceiptRef.Text.Split(',');
        int memberCount = members.Length;

        decimal totalBankAmount = valstringAmount(txtbnkAmount.Text);
        decimal totalReceiptAmount = valstringAmount(txtReceiptAmount.Text);

        // Calculate bank charges per member (equally divided)
        decimal bankPerMember = totalBankAmount / memberCount;
        bankPerMember = Math.Round(bankPerMember, 2);

        // Calculate receipt amount per member (equally divided from header)
        decimal receiptPerMember = totalReceiptAmount / memberCount;
        receiptPerMember = Math.Round(receiptPerMember, 2);

        // Handle rounding differences for bank amount
        decimal calculatedBankTotal = bankPerMember * memberCount;
        decimal bankRoundingDiff = totalBankAmount - calculatedBankTotal;

        // Handle rounding differences for receipt amount
        decimal calculatedReceiptTotal = receiptPerMember * memberCount;
        decimal receiptRoundingDiff = totalReceiptAmount - calculatedReceiptTotal;

        string singleReceiptNo = GenerateReceiptNo();

        // Create DataTable for member details (TVP)
        DataTable memberDetailsTable = new DataTable();
        memberDetailsTable.Columns.Add("MemberNo", typeof(string));
        memberDetailsTable.Columns.Add("ContactPerson", typeof(string));
        memberDetailsTable.Columns.Add("CNIC", typeof(string));
        memberDetailsTable.Columns.Add("Phone", typeof(string));
        memberDetailsTable.Columns.Add("ReceiptAmount", typeof(decimal));
        memberDetailsTable.Columns.Add("BankAmount", typeof(decimal));

        int rowIndex = 0;
        foreach (string member in members)
        {
            // Get the row-specific amount from grid if available
            decimal rowAmount = 0;
            if (rowIndex < gvReceipts.Rows.Count)
            {
                TextBox txtRowAmt = (TextBox)gvReceipts.Rows[rowIndex].FindControl("txtRowAmount");
                if (txtRowAmt != null && !string.IsNullOrWhiteSpace(txtRowAmt.Text))
                    rowAmount = valstringAmount(txtRowAmt.Text);
            }

            // If row amount is 0, use the divided receipt amount
            decimal receiptForThisMember = rowAmount > 0 ? rowAmount : receiptPerMember;

            // Calculate bank for this member
            decimal bankForThisMember = bankPerMember;

            // Add rounding differences to last member
            if (rowIndex == memberCount - 1)
            {
                if (bankRoundingDiff != 0)
                    bankForThisMember += bankRoundingDiff;

                if (receiptRoundingDiff != 0 && rowAmount == 0)
                    receiptForThisMember += receiptRoundingDiff;
            }

            // Add row to DataTable
            memberDetailsTable.Rows.Add(
                member.Trim(),
                txtReceiptPerson.Text,
                txtReceiptP_CNIC.Text,
                txtReceiptP_Phone.Text,
                receiptForThisMember,
                bankForThisMember
            );

            rowIndex++;
        }

        using (SqlConnection con = new SqlConnection(financeConnStr))
        {
            con.Open();

            using (SqlCommand cmd = new SqlCommand("sp_InsertMemberReceipts", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                // Main table parameters
                cmd.Parameters.AddWithValue("@ReceiptNo", singleReceiptNo);
                cmd.Parameters.AddWithValue("@ReceiptType", rblReceiptType.SelectedValue);
                cmd.Parameters.AddWithValue("@ReceiptModeID", ddlReceiptMode.SelectedValue);
                cmd.Parameters.AddWithValue("@ReceiptDate", txtReceiptDate.Text);
                cmd.Parameters.AddWithValue("@CostCenterID", ddlCC.SelectedValue);
                cmd.Parameters.AddWithValue("@PaymentHead", ddlP_Head.SelectedValue);
                cmd.Parameters.AddWithValue("@PaymentReference", txtPaymentRefrence.Text);
                cmd.Parameters.AddWithValue("@BankPercent", valstringAmount(txtBnkPer.Text));
                cmd.Parameters.AddWithValue("@TotalBankAmount", totalBankAmount);
                cmd.Parameters.AddWithValue("@Notes", txtReceiptNotes.Text);
                cmd.Parameters.Add("@EmpId", SqlDbType.Int).Value = Convert.ToInt32(Session["Emp_Id"] ?? 1);

                // TVP parameter for member details
                SqlParameter tvpParam = cmd.Parameters.AddWithValue("@MemberDetails", memberDetailsTable);
                tvpParam.SqlDbType = SqlDbType.Structured;
                tvpParam.TypeName = "dbo.MemberReceiptDetailsType";

                cmd.ExecuteNonQuery();
            }

            // ── Call stored procedure dbo.JV_Receipt to post financial voucher ──
            try
            {
                using (SqlCommand jvCmd = new SqlCommand("dbo.JV_Receipt", con))
                {
                    jvCmd.CommandType = CommandType.StoredProcedure;

                    decimal branchId = 1m;
                    if (Session["Company_Branch_Id"] != null)
                        decimal.TryParse(Session["Company_Branch_Id"].ToString(), out branchId);

                    int empId = 1;
                    if (Session["Emp_Id"] != null) int.TryParse(Session["Emp_Id"].ToString(), out empId);
                    else if (Session["Emp_ID"] != null) int.TryParse(Session["Emp_ID"].ToString(), out empId);

                    int desgId = 1;
                    if (Session["Designation_Id"] != null) int.TryParse(Session["Designation_Id"].ToString(), out desgId);
                    else if (Session["Desg_Id"] != null) int.TryParse(Session["Desg_Id"].ToString(), out desgId);

                    int grossAmount = Convert.ToInt32(Math.Round(totalReceiptAmount + totalBankAmount));
                    int partyId = GetPartyIdFromRef(txtReceiptRef.Text);

                    int costCenterId = 1;
                    if (!string.IsNullOrEmpty(ddlCC.SelectedValue))
                        int.TryParse(ddlCC.SelectedValue, out costCenterId);

                    string crHead = GetCreditHeadForSelectedMode();
                    string drHead = ddlP_Head.SelectedValue;

                    string description = txtReceiptNotes.Text.Trim();
                    if (string.IsNullOrEmpty(description)) description = "Receipt " + singleReceiptNo;
                    if (description.Length > 50) description = description.Substring(0, 50);

                    string chargesHead = "E01010008"; // Bank Charges head

                    jvCmd.Parameters.AddWithValue("@Company_Branch_Id", branchId);
                    jvCmd.Parameters.AddWithValue("@By_Emp_Id", empId);
                    jvCmd.Parameters.AddWithValue("@Designation_Id", desgId);
                    jvCmd.Parameters.AddWithValue("@Amount", grossAmount);
                    jvCmd.Parameters.AddWithValue("@Party_Id", partyId);
                    jvCmd.Parameters.AddWithValue("@CostCenter", costCenterId);
                    jvCmd.Parameters.AddWithValue("@Cr_Head", crHead);
                    jvCmd.Parameters.AddWithValue("@Dr_Head", drHead);
                    jvCmd.Parameters.AddWithValue("@Description", description);
                    jvCmd.Parameters.AddWithValue("@bankCharges", totalBankAmount);
                    jvCmd.Parameters.AddWithValue("@ChargesHead", chargesHead);
                    jvCmd.Parameters.AddWithValue("@ReceiptNo", singleReceiptNo);

                    SqlParameter vtIdParam = new SqlParameter("@V_T_ID", SqlDbType.Decimal);
                    vtIdParam.Direction = ParameterDirection.Output;
                    vtIdParam.Precision = 18;
                    vtIdParam.Scale = 0;
                    jvCmd.Parameters.Add(vtIdParam);

                    jvCmd.ExecuteNonQuery();
                }
            }
            catch { }
        }

        // ── NEW: For Activity/Event receipts, push the received amount into
        // Booking_Main_Menu.Advance so the booking's remaining balance shrinks. ──
        if (rblReceiptType.SelectedValue == "3")
        {
            UpdateBookingAdvance(memberDetailsTable);
        }

        hfMemberData.Value = "";
        gvReceipts.DataSource = null;
        gvReceipts.DataBind();
        btnSave.Visible = false;
        lblTotalStatus.Text = "";
        ClearForm();

        // ── Open report in new tab after save ──
        string reportUrl = "ReceiptReport.aspx?ReceiptNo=" + Server.UrlEncode(singleReceiptNo);
        ScriptManager.RegisterStartupScript(this, this.GetType(), "openReport",
            "window.open('" + reportUrl + "', '_blank');", true);
    }

    // ── NEW: updates Booking_Main_Menu.Advance for each booking row that was saved ──
    private void UpdateBookingAdvance(DataTable memberDetailsTable)
    {
        string bookingConnStr = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

        using (SqlConnection bcon = new SqlConnection(bookingConnStr))
        {
            bcon.Open();

            foreach (DataRow row in memberDetailsTable.Rows)
            {
                int bookingMainId;
                if (!int.TryParse(row["MemberNo"].ToString(), out bookingMainId))
                    continue;

                decimal receiptAmt = Convert.ToDecimal(row["ReceiptAmount"]);
                decimal bankAmt = Convert.ToDecimal(row["BankAmount"]);
                decimal totalPaid = receiptAmt + bankAmt;

                if (totalPaid <= 0) continue;

                SqlCommand updCmd = new SqlCommand(@"
                    UPDATE Booking_Main_Menu
                    SET Advance = ISNULL(Advance,0) + @Amt
                    WHERE BookingMain_Id = @Id", bcon);

                updCmd.Parameters.AddWithValue("@Amt", totalPaid);
                updCmd.Parameters.AddWithValue("@Id", bookingMainId);
                updCmd.ExecuteNonQuery();
            }
        }
    }

    // ── Generate unique receipt number (Format: RCP-yy-MM-123456, reset yearly) ──
    private string GenerateReceiptNo()
    {
        string financeConnStr = ConfigurationManager.ConnectionStrings["Finance_ConnectionString"] != null
            ? ConfigurationManager.ConnectionStrings["Finance_ConnectionString"].ConnectionString
            : ConfigurationManager.ConnectionStrings["FinanceConnectionString"].ConnectionString;

        DateTime now = DateTime.Now;
        string yearPrefix = "RCP-" + now.ToString("yy-");           // e.g. "RCP-26-"
        string fullMonthPrefix = "RCP-" + now.ToString("yy-MM-");  // e.g. "RCP-26-08-"
        int nextNum = 1;

        using (SqlConnection con = new SqlConnection(financeConnStr))
        {
            con.Open();

            // Query the last generated receipt for the CURRENT YEAR
            SqlCommand cmd = new SqlCommand(
                "SELECT TOP 1 ReceiptNo FROM MemberReceipts_Main " +
                "WHERE ReceiptNo LIKE @YearPrefix + '%' " +
                "ORDER BY ReceiptMainID DESC", con);
            cmd.Parameters.AddWithValue("@YearPrefix", yearPrefix);

            object result = cmd.ExecuteScalar();

            if (result != null && result != DBNull.Value)
            {
                string last = result.ToString().Trim();
                if (!string.IsNullOrEmpty(last))
                {
                    string[] parts = last.Split('-');
                    if (parts.Length >= 4)
                    {
                        int seq;
                        if (int.TryParse(parts[3], out seq))
                        {
                            nextNum = seq + 1;
                        }
                    }
                }
            }
        }

        return fullMonthPrefix + nextNum.ToString("D6");
    }

    public string GetReceiptAmount()
    {
        decimal receiptAmt = valstringAmount(txtReceiptAmount.Text);
        decimal bankCharges = valstringAmount(txtbnkAmount.Text);
        decimal total = receiptAmt + bankCharges;

        // Count members
        int memberCount = txtReceiptRef.Text.Split(',').Length;

        if (total > 0 && memberCount > 0)
        {
            decimal perMember = total / memberCount;
            return perMember.ToString("0.00");
        }
        return "";
    }

    private void ValidateAndToggleSave()
    {
        decimal receiptAmt = valstringAmount(txtReceiptAmount.Text);
        decimal bankCharges = valstringAmount(txtbnkAmount.Text);
        decimal headerTotal = receiptAmt + bankCharges;

        if (gvReceipts.Rows.Count == 0 || headerTotal == 0)
        {
            btnSave.Visible = false;
            lblTotalStatus.Text = "";
            return;
        }

        decimal gridTotal = 0;
        int rowNum = 1;

        foreach (GridViewRow row in gvReceipts.Rows)
        {
            if (row.RowType == DataControlRowType.DataRow)
            {
                TextBox txtRowAmount = (TextBox)row.FindControl("txtRowAmount");

                // ❌ Empty check
                if (txtRowAmount == null || string.IsNullOrWhiteSpace(txtRowAmount.Text))
                {
                    btnSave.Visible = false;
                    lblTotalStatus.Text = "Row " + rowNum + " amount is empty.";
                    lblTotalStatus.Style["color"] = "red";
                    return;
                }

                decimal rowAmt = valstringAmount(txtRowAmount.Text);
                gridTotal += rowAmt;

                rowNum++;
            }
        }

        // ✅ ONLY CONDITION: TOTAL MUST MATCH
        if (Math.Round(gridTotal, 2) == Math.Round(headerTotal, 2))
        {
            btnSave.Visible = true;
            lblTotalStatus.Text = "Total matched: " + headerTotal.ToString("0.00");
            lblTotalStatus.Style["color"] = "green";
        }
        else
        {
            btnSave.Visible = false;
            lblTotalStatus.Text = "Grid Total (" + gridTotal.ToString("0.00")
                                + ") must equal Header Total (" + headerTotal.ToString("0.00") + ")";
            lblTotalStatus.Style["color"] = "red";
        }
    }


    private string GetMembers()
    {
        string[] members = txtReceiptRef.Text.Split(',');
        string formatted = "";

        foreach (string m in members)
        {
            if (formatted != "")
                formatted += ",";

            formatted += "'" + m.Trim() + "'";
        }

        return formatted;
    }
    protected void ddlReceiptModeOfPayment_SelectedIndexChanged(object sender, EventArgs e)
    {
        ddlP_Head.DataBind();
    }

    protected void txtGSTPer_TextChanged(object sender, EventArgs e)
    {
        getBankCharges();
    }

    private void getBankCharges()
    {
        decimal BankPer = valstringAmount(txtBnkPer.Text);
        decimal RecAmount = valstringAmount(txtReceiptAmount.Text);

        if (RecAmount > 0)
        {
            decimal BankCharges = RecAmount * BankPer / 100;
            txtbnkAmount.Text = Math.Round(BankCharges, 2).ToString("0.00");
        }
    }

    private decimal valstringAmount(string amountTxt)
    {
        decimal rtn = 0;
        if (!string.IsNullOrEmpty(amountTxt.Trim()))
        {
            rtn = Convert.ToDecimal(amountTxt.Trim());
        }
        return rtn;
    }

    protected void txtReceiptAmount_TextChanged(object sender, EventArgs e)
    {
        getBankCharges();
    }


    private void ClearForm()
    {
        txtReceiptRef.Text = "";
        txtReceiptPerson.Text = "";
        txtReceiptP_CNIC.Text = "";
        txtReceiptP_Phone.Text = "";
        txtReceiptAmount.Text = "";
        txtPaymentRefrence.Text = "";
        txtBnkPer.Text = "";
        txtbnkAmount.Text = "";
        txtReceiptNotes.Text = "";
    }


    public string GetReceiptTypeText(object receiptType)
    {
        if (receiptType == null || receiptType == DBNull.Value) return "";

        switch (receiptType.ToString())
        {
            case "1": return "Billing / Membership";
            case "2": return "New Memberships";
            case "3": return "Activity / Event";
            case "4": return "Other";
            case "5": return "Guest Room";
            default: return receiptType.ToString();
        }
    }

    // ═════════════════════════════════════════════════════════════════════════
    // RECEIPT MODE POPUP MODAL HANDLERS & METHODS
    // ═════════════════════════════════════════════════════════════════════════

    protected void btnOpenReceiptModeModal_Click(object sender, EventArgs e)
    {
        string typeText = rblReceiptType.SelectedItem != null ? rblReceiptType.SelectedItem.Text : "Selected";
        string typeVal = rblReceiptType.SelectedValue;
        lblModalReceiptType.Text = typeText;
        hfModalReceiptTypeId.Value = typeVal;

        LoadModalDropdowns();
        LoadModalGrid();
        ResetModalForm();

        pnlReceiptModeModal.Visible = true;
    }

    private void LoadModalDropdowns()
    {
        string financeConnStr = ConfigurationManager.ConnectionStrings["FinanceConnectionString"].ConnectionString;

        using (SqlConnection con = new SqlConnection(financeConnStr))
        {
            con.Open();

            // 1. Cost Centers using sp_GetCostCenters
            using (SqlCommand cmd = new SqlCommand("sp_GetCostCenters", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dtDept = new DataTable();
                da.Fill(dtDept);

                ddlCostCenterModal.DataSource = dtDept;
                ddlCostCenterModal.DataTextField = "CostCenterName";
                ddlCostCenterModal.DataValueField = "CostCenterID";
                ddlCostCenterModal.DataBind();
                ddlCostCenterModal.Items.Insert(0, new ListItem("-- Select Cost Center --", ""));
            }

            // 2. Expenditure Heads using sp_GetExpenditureHeads
            using (SqlCommand cmd = new SqlCommand("sp_GetExpenditureHeads", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dtExp = new DataTable();
                da.Fill(dtExp);

                ddlFinancialHeadModal.DataSource = dtExp;
                ddlFinancialHeadModal.DataTextField = "E_Name";
                ddlFinancialHeadModal.DataValueField = "E_Code";
                ddlFinancialHeadModal.DataBind();
                ddlFinancialHeadModal.Items.Insert(0, new ListItem("-- Select Financial Head --", ""));
            }
        }
    }

    private void LoadModalGrid()
    {
        int receiptType = 0;
        int.TryParse(hfModalReceiptTypeId.Value, out receiptType);

        string financeConnStr = ConfigurationManager.ConnectionStrings["FinanceConnectionString"].ConnectionString;

        using (SqlConnection con = new SqlConnection(financeConnStr))
        {
            con.Open();
            using (SqlCommand cmd = new SqlCommand("sp_GetReceiptModesByType", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ReceiptType", receiptType);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvModalReceiptModes.DataSource = dt;
                gvModalReceiptModes.DataBind();
            }
        }
    }

    private void ResetModalForm()
    {
        hfSelectedReceiptModeID.Value = "0";
        lblFormTitle.Text = "Add New Receipt Mode";
        txtNewReceiptMode.Text = "";
        chkValidateMember.Checked = false;
        chkIsActiveModal.Checked = true;
        if (ddlCostCenterModal.Items.Count > 0) ddlCostCenterModal.SelectedIndex = 0;
        if (ddlFinancialHeadModal.Items.Count > 0) ddlFinancialHeadModal.SelectedIndex = 0;
        btnSaveReceiptMode.Text = "Save";
        lblModalMsg.Text = "";
    }

    protected void gvModalReceiptModes_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "EditMode")
        {
            int modeId = Convert.ToInt32(e.CommandArgument);
            int receiptType = 0;
            int.TryParse(hfModalReceiptTypeId.Value, out receiptType);

            string financeConnStr = ConfigurationManager.ConnectionStrings["FinanceConnectionString"].ConnectionString;

            using (SqlConnection con = new SqlConnection(financeConnStr))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand("sp_GetReceiptModesByType", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@ReceiptType", receiptType);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    DataRow[] found = dt.Select("ReceiptModeID = " + modeId);
                    if (found.Length > 0)
                    {
                        DataRow dr = found[0];
                        hfSelectedReceiptModeID.Value = modeId.ToString();
                        txtNewReceiptMode.Text = dr["ReceiptMode"].ToString();
                        chkValidateMember.Checked = dr["ValidateMember"] != DBNull.Value && Convert.ToBoolean(dr["ValidateMember"]);
                        chkIsActiveModal.Checked = dr["IsActive"] != DBNull.Value && Convert.ToBoolean(dr["IsActive"]);

                        if (dr["Dept_ID"] != DBNull.Value && !string.IsNullOrEmpty(dr["Dept_ID"].ToString()))
                        {
                            ListItem item = ddlCostCenterModal.Items.FindByValue(dr["Dept_ID"].ToString());
                            if (item != null) ddlCostCenterModal.SelectedValue = dr["Dept_ID"].ToString();
                            else ddlCostCenterModal.SelectedIndex = 0;
                        }
                        else ddlCostCenterModal.SelectedIndex = 0;

                        if (dr["FinancialHead"] != DBNull.Value && !string.IsNullOrEmpty(dr["FinancialHead"].ToString()))
                        {
                            ListItem item = ddlFinancialHeadModal.Items.FindByValue(dr["FinancialHead"].ToString());
                            if (item != null) ddlFinancialHeadModal.SelectedValue = dr["FinancialHead"].ToString();
                            else ddlFinancialHeadModal.SelectedIndex = 0;
                        }
                        else ddlFinancialHeadModal.SelectedIndex = 0;

                        lblFormTitle.Text = "Edit Receipt Mode";
                        btnSaveReceiptMode.Text = "Update";
                        lblModalMsg.Text = "";
                    }
                }
            }
        }
    }

    protected void btnSaveReceiptMode_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtNewReceiptMode.Text))
        {
            lblModalMsg.Text = "Please enter Receipt Mode Name.";
            lblModalMsg.Style["color"] = "red";
            return;
        }

        int modeId = 0;
        int.TryParse(hfSelectedReceiptModeID.Value, out modeId);

        int receiptType = 0;
        int.TryParse(hfModalReceiptTypeId.Value, out receiptType);

        object deptId = DBNull.Value;
        if (!string.IsNullOrEmpty(ddlCostCenterModal.SelectedValue))
        {
            deptId = Convert.ToInt32(ddlCostCenterModal.SelectedValue);
        }

        object financialHead = DBNull.Value;
        if (!string.IsNullOrEmpty(ddlFinancialHeadModal.SelectedValue))
        {
            financialHead = ddlFinancialHeadModal.SelectedValue;
        }

        bool validateMember = chkValidateMember.Checked;
        bool isActive = chkIsActiveModal.Checked;
        string createdBy = Session["Emp_Id"] != null ? Session["Emp_Id"].ToString() : "System";

        string financeConnStr = ConfigurationManager.ConnectionStrings["FinanceConnectionString"].ConnectionString;

        using (SqlConnection con = new SqlConnection(financeConnStr))
        {
            con.Open();

            if (modeId == 0)
            {
                // INSERT via sp_InsertReceiptMode
                using (SqlCommand cmd = new SqlCommand("sp_InsertReceiptMode", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@ReceiptType", receiptType);
                    cmd.Parameters.AddWithValue("@ReceiptMode", txtNewReceiptMode.Text.Trim());
                    cmd.Parameters.AddWithValue("@ValidateMember", validateMember);
                    cmd.Parameters.AddWithValue("@FinancialHead", financialHead);
                    cmd.Parameters.AddWithValue("@Dept_ID", deptId);
                    cmd.Parameters.AddWithValue("@IsActive", isActive);
                    cmd.Parameters.AddWithValue("@CreatedBy", createdBy);

                    SqlParameter outParam = new SqlParameter("@NewReceiptModeID", SqlDbType.Int);
                    outParam.Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(outParam);

                    cmd.ExecuteNonQuery();
                }

                lblModalMsg.Text = "Receipt Mode added successfully!";
                lblModalMsg.Style["color"] = "green";
            }
            else
            {
                // UPDATE via sp_UpdateReceiptMode
                using (SqlCommand cmd = new SqlCommand("sp_UpdateReceiptMode", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@ReceiptModeID", modeId);
                    cmd.Parameters.AddWithValue("@ReceiptMode", txtNewReceiptMode.Text.Trim());
                    cmd.Parameters.AddWithValue("@ValidateMember", validateMember);
                    cmd.Parameters.AddWithValue("@FinancialHead", financialHead);
                    cmd.Parameters.AddWithValue("@Dept_ID", deptId);
                    cmd.Parameters.AddWithValue("@IsActive", isActive);

                    cmd.ExecuteNonQuery();
                }

                lblModalMsg.Text = "Receipt Mode updated successfully!";
                lblModalMsg.Style["color"] = "green";
            }
        }

        // Refresh grid & main page dropdown
        LoadModalGrid();
        ResetModalForm();
        ddlReceiptMode.DataBind();
    }

    protected void btnResetModal_Click(object sender, EventArgs e)
    {
        ResetModalForm();
    }

    protected void btnCloseReceiptModeModal_Click(object sender, EventArgs e)
    {
        pnlReceiptModeModal.Visible = false;
        ddlReceiptMode.DataBind();
    }
}