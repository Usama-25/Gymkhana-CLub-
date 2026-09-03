using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;
// using Microsoft.Reporting;
using GymKhana.Library;

public partial class Store_BookingMenu : System.Web.UI.Page
{
    SqlConnection con = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString);
    String conString = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            BindEventPlace();
            BindEventTiming();
            BindDropDownList();
            LoadEventNames();
        }
    }

    protected void BindEventTiming()
    {
        SqlCommand cmd;
        try
        {
            con.Open();
            try
            {
                cmd = new SqlCommand("SELECT 0 as Timing_Id, '--- All ---' as Timing union select Timing_Id,Timing from EventTiming", con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                ddlTiming.DataSource = dt;
                ddlTiming.DataTextField = "Timing";
                ddlTiming.DataValueField = "Timing_Id";
                ddlTiming.DataBind();
                con.Close();
            }
            catch (Exception)
            {
                con.Close();
            }
        }
        catch (Exception) { }
    }

    protected void BindEventPlace()
    {
        SqlCommand cmd;
        try
        {
            con.Open();
            try
            {
                cmd = new SqlCommand("SELECT 0 as Event_Id, '--- All ---' as Event_Place union select Event_Id , Event_Place from EventBookingPlace", con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                DdlEvent.DataSource = dt;
                DdlEvent.DataTextField = "Event_Place";
                DdlEvent.DataValueField = "Event_Id";
                DdlEvent.DataBind();
                con.Close();
            }
            catch (Exception)
            {
                con.Close();
            }
        }
        catch (Exception) { }
    }

    private void LoadEventNames()
    {
        string conStr = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

        using (SqlConnection con = new SqlConnection(conStr))
        {
            using (SqlCommand cmd = new SqlCommand(
                "SELECT EventName_Id, EventName FROM EventName ORDER BY EventName", con))
            {
                con.Open();

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                dldName.DataSource = dt;
                dldName.DataTextField = "EventName";
                dldName.DataValueField = "EventName_Id";
                dldName.DataBind();

                dldName.Items.Insert(0,
                    new ListItem("-- Select Event Name --", ""));
            }
        }
    }

    private void UpdateFooterAmount(GridView gridView)
    {
        decimal totalAmount = 0;
        foreach (GridViewRow row in gridView.Rows)
        {
            CheckBox chkSelect = (CheckBox)row.FindControl("CheckBox1");
            TextBox txtQty = (TextBox)row.FindControl("txtQty");
            TextBox txtAmount = (TextBox)row.FindControl("txtAmount");
            TextBox txtFooterBills = (TextBox)gridView.FooterRow.FindControl("txtFooterBill");
            if (chkSelect.Checked)
            {
                decimal qty = 0;
                decimal amount = 0;
                if (decimal.TryParse(txtQty.Text, out qty) && decimal.TryParse(txtAmount.Text, out amount))
                {
                    totalAmount += qty * amount;
                    txtFooterBills.Text = totalAmount.ToString("F2");
                }
            }
        }
        TextBox txtOther = (TextBox)gridView.FooterRow.FindControl("txtFooterOther");
        TextBox txtFooterTotal = (TextBox)gridView.FooterRow.FindControl("txtFooterTotal");
        TextBox txtFooterAmount = (TextBox)gridView.FooterRow.FindControl("txtFooterAmount");
        TextBox txtdiscount = (TextBox)gridView.FooterRow.FindControl("txtDis");
        TextBox txtFooterBill = (TextBox)gridView.FooterRow.FindControl("txtFooterBill");

        txtFooterTotal.Text = totalAmount.ToString("F2");

        decimal otherAmount = 0;
        decimal footerTotalAmount = totalAmount;
        if (decimal.TryParse(txtOther.Text, out otherAmount))
        {
            footerTotalAmount += otherAmount;
        }
        txtFooterBill.Text = footerTotalAmount.ToString("F2");
        int totalPerson = 1;
        decimal totalAmountParsed = 0;
        decimal discounts = 0;

        if (int.TryParse(txtPerson.Text, out totalPerson) &&
            decimal.TryParse(txtFooterAmount.Text, out totalAmountParsed) &&
            decimal.TryParse(txtdiscount.Text, out discounts))
        {
            decimal billAmount = totalAmountParsed - discounts;
            decimal totalBill = billAmount * totalPerson;
            txtFooterBill.Text = totalBill.ToString("F2");
        }

        txtFooterAmount.Text = footerTotalAmount.ToString("F");
    }

    protected void loadReport(int bookingMainId)
    {
        try
        {
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

            DataTable VehicleData = ExecuteDataTable("uspGetBookingMainManuReport", connectionString,
                new SqlParameter("@BookingMain_Id", bookingMainId));

            DataTable AllExpensesData = ExecuteDataTable("uspGetBookingSubManuReport", connectionString,
                new SqlParameter("@BookingMain_Id", bookingMainId));

            DataTable Aditional = ExecuteDataTable("uspGetBookingSubManuReportOther", connectionString,
                new SqlParameter("@BookingMain_Id", bookingMainId));

            // ── FIX: verify data actually came back before rendering ──
            if (VehicleData == null || VehicleData.Rows.Count == 0)
            {
                lblMessage.Text = "Report data not found for Booking ID: " + bookingMainId;
                return;
            }

//             ReportViewer1.LocalReport.DataSources.Clear();

            string rdlcPath = "~/Store/BookingMenuReports.rdlc";
            string reportPath = Server.MapPath(rdlcPath);

//             ReportViewer1.LocalReport.ReportPath = reportPath;
//             ReportViewer1.LocalReport.DataSources.Add(new object("DataSet1", VehicleData));
//             ReportViewer1.LocalReport.DataSources.Add(new object("DataSet2", AllExpensesData));
//             ReportViewer1.LocalReport.DataSources.Add(new object("DataSet3", Aditional));
//             ReportViewer1.LocalReport.SubreportProcessing += new SubreportProcessingEventHandler(subReports);

            if (Request.Browser.Browser == "Chrome")
            {
//                 byte[] bytes = ReportViewer1.LocalReport.Render("PDF");
                Response.ClearHeaders();
                Response.ClearContent();
                Response.AddHeader("Content-Disposition", "inline; filename=BookingReport_" + bookingMainId + ".pdf");
                Response.ContentType = "application/pdf";
//                 Response.BinaryWrite(bytes);
                Response.Flush();
                Response.End();
            }
            else
            {
//                 ReportViewer1.Visible = true;
            }
        }
        catch (System.Threading.ThreadAbortException)
        {
            // Response.End() throws ThreadAbortException intentionally — do not log this
        }
        catch (Exception ex)
        {
            lblMessage.Text = "Report error: " + ex.Message;
        }
    }

    private DataTable ExecuteDataTable(string storedProcedure, string connectionString, params SqlParameter[] parameters)
    {
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            using (SqlCommand cmd = new SqlCommand(storedProcedure, conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddRange(parameters);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    return dt;
                }
            }
        }
    }

    public void subReports(object sender, object e)
    {
        try
        {
//             e.DataSources.Clear();
            DataTable dt = (DataTable)Session["DynamicHeader"];
//             e.DataSources.Add(new object("DataSet1", dt));
//             e.DataSources.Add(new object("DataSetFooter", dt));
        }
        catch (Exception) { }
    }

    protected void bindGride()
    {
        SqlConnection con = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString);
        SqlCommand cmd = new SqlCommand("select distinct SuperName Manu , ID SelectItem, Requird from BookingSetup order by SelectItem asc", con);
        SqlDataAdapter da = new SqlDataAdapter(cmd);
        DataTable dt = new DataTable();
        da.Fill(dt);
        DataList1.DataSource = dt;
        DataList1.DataBind();
    }

    protected void DataList1_ItemDataBound(object sender, DataListItemEventArgs e)
    {
        string ModuleID = ((HiddenField)e.Item.FindControl("hfModuleID")).Value;
        DataList dlist = (DataList)e.Item.FindControl("data");
        SqlConnection con = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString);
        SqlCommand cmd = new SqlCommand("uspGetmenuItems", con);
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Parameters.AddWithValue("@Manu", ModuleID);
        SqlDataAdapter da = new SqlDataAdapter(cmd);
        DataTable dt = new DataTable();
        da.Fill(dt);
        dlist.DataSource = dt;
        dlist.DataBind();
    }

    // ══════════════════════════════════════════════════════
    //  FIXED: btnSave_Click
    //  Changes:
    //  1. insertData no longer has a try/catch — errors bubble up here
    //  2. loadReport is only called AFTER both inserts succeed
    //  3. JavaScript alert fires only on non-Chrome path (Chrome uses Response.End PDF)
    //  4. Added explicit check: if bookingMainId == 0 after insert, abort
    // ══════════════════════════════════════════════════════
    protected void btnSave_Click(object sender, EventArgs e)
    {
        try
        {
            string xml = LoadXml();
            if (xml == "0")
            {
                lblMessage.Text = "Please select all required items!";
                return;
            }

            DateTime partyDate = DateTime.Parse(txtDate.Text.Trim());
            int totalPerson = int.Parse(txtPerson.Text.Trim());
            string partyName = dldName.Text.Trim();
            string contactPerson = txtConperson.Text.Trim();
            string contact = txtContact.Text.Trim();
            string MemberShipNo = txtmemberNo.Text.Trim();

            string connectionString = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

            decimal other;
            decimal.TryParse(txtother.Text.Trim(), out other);

            decimal DealsAmount;
            decimal.TryParse(txttotal.Text.Trim(), out DealsAmount);

            decimal DealWithtax;
            decimal.TryParse(txtDealWithtax.Text.Trim(), out DealWithtax);

            decimal tax;
            decimal.TryParse(txtTax.Text.Trim(), out tax);

            decimal bill;
            decimal.TryParse(txtBil.Text.Trim(), out bill);

            decimal Advance;
            decimal.TryParse(TxtAdvanc.Text.Trim(), out Advance);

            decimal Balance;
            decimal.TryParse(txtBalance.Text.Trim(), out Balance);

            decimal venue;
            decimal.TryParse(txtVenue.Text.Trim(), out venue);

            decimal WholeBillTax;
            decimal.TryParse(txtWtax.Text.Trim(), out WholeBillTax);

            decimal Additional;
            decimal.TryParse(lblAdditional.Text.Trim(), out Additional);

            decimal GrandTotal;
            decimal.TryParse(lblGrandTotal.Text.Trim(), out GrandTotal);

            int bookingMainId = 0;

            // ── STEP 1: Insert BookingMain ──
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("dbo.uspInsert_BookingItems", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@MemberShipNo", MemberShipNo);
                    cmd.Parameters.AddWithValue("@Member_Id", ddlMember.SelectedValue);
                    cmd.Parameters.AddWithValue("@Party_Date", partyDate);
                    cmd.Parameters.AddWithValue("@PartyHall", DdlEvent.SelectedValue);
                    cmd.Parameters.AddWithValue("@Total_Person", totalPerson);
                    cmd.Parameters.AddWithValue("@Party_Name", partyName);
                    cmd.Parameters.AddWithValue("@Contact_person", contactPerson);
                    cmd.Parameters.AddWithValue("@Contact_no", contact);
                    cmd.Parameters.AddWithValue("@Timing", ddlTiming.SelectedValue);
                    cmd.Parameters.AddWithValue("@DID", DdlMenu.SelectedValue);
                    cmd.Parameters.AddWithValue("@DealsTotal", DealsAmount);
                    cmd.Parameters.AddWithValue("@Tax", tax);
                    cmd.Parameters.AddWithValue("@DealsAmountother", DealWithtax);
                    cmd.Parameters.AddWithValue("@TotalBill", bill);
                    cmd.Parameters.AddWithValue("@Additional", Additional);
                    cmd.Parameters.AddWithValue("@OtherAmount", other);
                    cmd.Parameters.AddWithValue("@venue", venue);
                    cmd.Parameters.AddWithValue("@GrandTotal", GrandTotal);
                    cmd.Parameters.AddWithValue("@WholeBillTax", WholeBillTax);
                    cmd.Parameters.AddWithValue("@Advance", Advance);
                    cmd.Parameters.AddWithValue("@Balance", Balance);

                    SqlParameter outputBookingMainId = new SqlParameter("@BookingMain_Id", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    cmd.Parameters.Add(outputBookingMainId);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                    bookingMainId = Convert.ToInt32(outputBookingMainId.Value);
                }
            }
            // BookingMain row is fully committed — connection is disposed

            // ── Guard: stored proc must return a valid ID ──
            if (bookingMainId <= 0)
            {
                lblMessage.Text = "Booking insert failed — no ID returned. Please try again.";
                return;
            }

            // ── STEP 2: Insert sub-menu items ──
            // No try/catch here — any failure throws to the outer catch so we
            // don't call loadReport against incomplete data
            insertData(xml, bookingMainId);

            // ── STEP 3: Both inserts succeeded — now load report ──
            lblMessage.Text = "Saved successfully. Booking ID: " + bookingMainId;

            // Alert only makes sense on non-Chrome because Chrome path calls
            // Response.End() which terminates the response before page renders
            if (Request.Browser.Browser != "Chrome")
            {
                ScriptManager.RegisterStartupScript(
                    this,
                    this.GetType(),
                    "msg",
                    "alert('Booking saved! Report ID = " + bookingMainId + "');",
                    true);
            }

            loadReport(bookingMainId);
        }
        catch (System.Threading.ThreadAbortException)
        {
            // Expected when Response.End() is called in Chrome PDF path — ignore
        }
        catch (Exception ex)
        {
            lblMessage.Text = "Error: " + ex.Message;
        }
    }

    protected string LoadXml()
    {
        Int16 Total = 0;
        Decimal Count = 0;
        string xml = "<table>";

        foreach (DataListItem item in DataList1.Items)
        {
            HiddenField Hfreq = item.FindControl("Hfreq") as HiddenField;
            HiddenField hfCat = item.FindControl("hfCat") as HiddenField;

            if ((Hfreq != null && Hfreq.Value == "True") && (hfCat != null && hfCat.Value == "Deal"))
            {
                Total++;
            }

            DataList dataItems = (DataList)item.FindControl("data");
            foreach (DataListItem inItem in dataItems.Items)
            {
                CheckBox chk = (CheckBox)inItem.FindControl("chkboxOne");
                HiddenField hdfRole = inItem.FindControl("hfRoleID") as HiddenField;
                HiddenField ItemCode = inItem.FindControl("ItemCode") as HiddenField;
                HiddenField hdfcategory = inItem.FindControl("hdfcategory") as HiddenField;
                TextBox qty = inItem.FindControl("txtqtys") as TextBox;
                Label Amount = inItem.FindControl("lblAmount") as Label;
                HiddenField hdfWeightage = (HiddenField)inItem.FindControl("hdfWeightage");

                if (chk.Checked)
                {
                    if ((hfCat != null && hfCat.Value == "Deal"))
                    {
                        Count = Count + Convert.ToDecimal(hdfWeightage.Value);
                    }

                    xml = xml + "<row>" +
                            "<roleid>" + System.Security.SecurityElement.Escape(hdfRole.Value) + "</roleid>" +
                            "<itemcode>" + System.Security.SecurityElement.Escape(ItemCode.Value) + "</itemcode>" +
                            "<Amount>" + System.Security.SecurityElement.Escape(Amount.Text) + "</Amount>" +
                            "<Qty>" + System.Security.SecurityElement.Escape(qty.Text) + "</Qty>" +
                            "</row>";
                }
            }
        }

        xml += "</table>";

        if (Count == Total)
        {
            return xml;
        }
        else
        {
            return "0";
        }
    }

    // ══════════════════════════════════════════════════════
    //  FIXED: insertData
    //  Removed the try/catch block entirely.
    //  Any SQL exception now propagates up to btnSave_Click,
    //  which means loadReport is never called when this fails.
    // ══════════════════════════════════════════════════════
    protected void insertData(string xml, int bookingMainId)
    {
        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString))
        {
            SqlCommand cmd = new SqlCommand("sp_InsertSubMenuItems", con);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@bookingMainId", bookingMainId);
            cmd.Parameters.AddWithValue("@XMLString", xml);
            con.Open();
            cmd.ExecuteNonQuery();
            // No try/catch — let exceptions bubble up to btnSave_Click
        }
    }

    private void BindDropDownList()
    {
        string query = "SELECT DID, DealName FROM MainDeals";
        using (SqlConnection con = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString))
        {
            SqlDataAdapter da = new SqlDataAdapter(query, con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            DdlMenu.DataSource = dt;
            DdlMenu.DataTextField = "DealName";
            DdlMenu.DataValueField = "DID";
            DdlMenu.DataBind();
            DdlMenu.Items.Insert(0, new ListItem("Select a Deal", "0"));
        }
    }

    protected void DdlMenu_TextChanged(object sender, EventArgs e)
    {
        string didValue = DdlMenu.SelectedValue;
        int did;
        if (int.TryParse(didValue, out did))
        {
            SqlConnection con = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString);
            SqlCommand cmd = new SqlCommand("select distinct SuperName Manu , ID SelectItem,Requird,Category from BookingSetup where DealLevel=@DID order by SelectItem", con);
            cmd.Parameters.AddWithValue("@DID", did);
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            DataList1.DataSource = dt;
            DataList1.DataBind();
            BindDealAmountToLabel(did);
        }
        else
        {
            Label1.Text = "Invalid DID value.";
        }
    }

    protected void BindDealAmountToLabel(int did)
    {
        string query = "SELECT DealAmount FROM MainDeals WHERE DiD=@Did";
        using (SqlConnection con = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString))
        {
            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@Did", did);
            try
            {
                con.Open();
                object result = cmd.ExecuteScalar();
                Label1.Text = result != null ? result.ToString() : "";
            }
            catch (Exception ex)
            {
                Label1.Text = "Error: " + ex.Message;
            }
        }
    }

    protected void chkboxOne_CheckedChanged(object sender, EventArgs e)
    {
        CalculateSum();
    }

    private void CalculateSum()
    {
        decimal totalAmount = 0;
        decimal totalOther = 0;

        foreach (DataListItem item in DataList1.Items)
        {
            DataList dataItems = (DataList)item.FindControl("data");
            if (dataItems != null)
            {
                foreach (DataListItem inItem in dataItems.Items)
                {
                    HiddenField hdfcategory = (HiddenField)inItem.FindControl("hdfcategory");
                    CheckBox chk = (CheckBox)inItem.FindControl("chkboxOne");
                    Label lblAmount = (Label)inItem.FindControl("lblAmount");
                    if (hdfcategory.Value == "Other")
                    {
                        if (chk != null && lblAmount != null && chk.Checked)
                        {
                            decimal amount = 0;
                            if (decimal.TryParse(lblAmount.Text, out amount))
                            {
                                totalAmount += amount;
                                totalOther += amount;
                                hfOther.Value = totalOther.ToString();
                            }
                        }
                    }
                }
            }
        }

        decimal label1Amount = 0;
        decimal other = 0;
        int totalPerson = 1;
        decimal taxPercentage = 1m;
        decimal venue = 0;
        decimal venueAmount = 0;
        decimal totalBill = 0;
        decimal advance = 0;
        decimal totalAfterOther = 0;
        decimal overAlltax = 0;
        decimal CountAllTax = 0;
        decimal taxAmount = 0;
        decimal taxAmountsum = 0;

        if (decimal.TryParse(Label1.Text, out label1Amount))
        {
            lblAdditional.Text = totalAmount.ToString("F1");
            txttotal.Text = label1Amount.ToString("F1");

            if (int.TryParse(txtPerson.Text, out totalPerson))
            {
                totalBill = label1Amount * totalPerson;
            }
            if (decimal.TryParse(txtTax.Text, out taxPercentage))
            {
                taxAmount = totalBill * (taxPercentage / 100);
                taxAmountsum = totalBill + taxAmount;
                txtDealWithtax.Text = taxAmountsum.ToString("F1");
            }
            if (decimal.TryParse(txtVenue.Text, out venue))
            {
                venueAmount = taxAmountsum + venue + totalAmount;
                lblGrandTotal.Text = venueAmount.ToString("F1");
            }
            if (decimal.TryParse(txtother.Text, out other))
            {
                totalAfterOther = venueAmount + other;
                lblGrandTotal.Text = totalAfterOther.ToString("F1");
            }
            if (decimal.TryParse(txtWtax.Text, out overAlltax))
            {
                decimal taxAmountAll = totalAfterOther * (overAlltax / 100);
                CountAllTax = totalAfterOther + taxAmountAll;
                txtBalance.Text = CountAllTax.ToString("F1");
            }
            if (decimal.TryParse(TxtAdvanc.Text, out advance))
            {
                decimal finalamount = CountAllTax - advance;
                txtBalance.Text = finalamount.ToString("F2");
            }
        }
        else
        {
            Label3.Text = "";
        }
    }

    protected void txtother_TextChanged(object sender, EventArgs e) { CalculateSum(); }
    protected void txtTax_TextChanged(object sender, EventArgs e) { CalculateSum(); }
    protected void txtPerson_TextChanged(object sender, EventArgs e) { CalculateSum(); }
    protected void TxtAdvanc_TextChanged(object sender, EventArgs e) { CalculateSum(); }
    protected void txtVenue_TextChanged(object sender, EventArgs e) { CalculateSum(); }
    protected void txtWtax_TextChanged(object sender, EventArgs e) { CalculateSum(); }

    protected void txtmemberNo_TextChanged(object sender, EventArgs e)
    {
        try
        {
            string search = txtmemberNo.Text.Trim();
            string constr = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;
            ScanRFID scanner = new ScanRFID(constr);
            DataTable dt = scanner.CheckRFID(search);

            if (dt == null || dt.Rows.Count == 0)
            {
                ddlMember.Items.Clear();
                lblStatus.Text = "Member not found";
                return;
            }

            DataRow rd = dt.Rows[0];

            string activeValue = rd["IsActive"] != DBNull.Value ? rd["IsActive"].ToString().Trim().ToLower() : "";
            string cardValue = rd["IsCardActive"] != DBNull.Value ? rd["IsCardActive"].ToString().Trim().ToLower() : "";

            bool isActive = activeValue == "1" || activeValue == "true" || activeValue == "yes" || activeValue == "y";
            bool isCardActive = cardValue == "1" || cardValue == "true" || cardValue == "yes" || cardValue == "y";

            string status = rd["Status"] != DBNull.Value ? rd["Status"].ToString().Trim() : "";
            string statusLower = status.ToLower();

            if (!isActive || !isCardActive || (statusLower != "active" && statusLower != "absentee"))
            {
                ddlMember.Items.Clear();
                string reason = "Member account is ";
                if (!isActive) reason += "deactivated";
                else if (!isCardActive) reason += "card deactivated";
                else reason += status;
                lblStatus.Text = reason;
                return;
            }

            ddlMember.Items.Clear();
            ddlMember.Items.Add(new ListItem(rd["MemberName"].ToString(), rd["MemberID"].ToString()));
            ddlMember.SelectedIndex = 0;
            lblStatus.Text = status;
        }
        catch (Exception ex)
        {
            ddlMember.Items.Clear();
            lblStatus.Text = "Error: " + ex.Message;
        }
    }

    protected void txtqtys_TextChanged(object sender, EventArgs e)
    {
        TextBox txtQty = (TextBox)sender;
        DataListItem item = (DataListItem)txtQty.NamingContainer;
        Label lblAmount = (Label)item.FindControl("lblAmount");
        TextBox txtqtys = (TextBox)item.FindControl("txtqtys");

        decimal amount = 0;
        decimal qty = 0;
        if (decimal.TryParse(lblAmount.Text, out amount) && decimal.TryParse(txtqtys.Text, out qty))
        {
            decimal result = amount * qty;
            lblAmount.Text = result.ToString("F2");
        }
        CalculateSum();
    }

    protected void data_ItemDataBound(object sender, DataListItemEventArgs e)
    {
        Label lblAmount = ((Label)e.Item.FindControl("lblAmount"));
        TextBox txtqtys = ((TextBox)e.Item.FindControl("txtqtys"));
        string CategoryHDF = ((HiddenField)e.Item.FindControl("hdfcategory")).Value;
        if (CategoryHDF != "Other")
        {
            lblAmount.Visible = false;
            txtqtys.Visible = false;
            txtqtys.Text = txtPerson.Text;
        }
    }

    protected void DataList1_PreRender(object sender, EventArgs e)
    {
        foreach (DataListItem item in DataList1.Items)
        {
            DataList nestedDataList = (DataList)item.FindControl("data");
            if (nestedDataList != null)
            {
                decimal total = 0;
                foreach (DataListItem nestedItem in nestedDataList.Items)
                {
                    HiddenField hdfWeightage = (HiddenField)nestedItem.FindControl("hdfWeightage");
                    CheckBox chkboxOne = (CheckBox)nestedItem.FindControl("chkboxOne");
                    TextBox txtqtys = ((TextBox)nestedItem.FindControl("txtqtys"));
                    string CategoryHDF = ((HiddenField)nestedItem.FindControl("hdfcategory")).Value;
                    if (CategoryHDF != "Other")
                    {
                        txtqtys.Text = txtPerson.Text;
                    }
                    if (hdfWeightage != null)
                    {
                        if (chkboxOne.Checked)
                        {
                            if (total == 1)
                            {
                                chkboxOne.Checked = false;
                                chkboxOne.Enabled = false;
                            }
                            else
                            {
                                total = total + Convert.ToDecimal(hdfWeightage.Value);
                                chkboxOne.Enabled = true;
                            }
                        }
                        else
                        {
                            if (total == 1)
                            {
                                chkboxOne.Checked = false;
                                chkboxOne.Enabled = false;
                            }
                            else
                            {
                                chkboxOne.Enabled = true;
                            }
                        }
                    }
                }
            }
        }
    }

    protected void Button2_Click1(object sender, EventArgs e)
    {
        loadReport(11070);
    }

    [System.Web.Script.Services.ScriptMethod(), System.Web.Services.WebMethod()]
    public static List<string> SearchModules(string prefixText, int count)
    {
        List<string> items = new List<string>();
        SqlConnection conn = new SqlConnection();
        conn.ConnectionString = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "Select Distinct Member_Id,MemberShip_No From Member Where MemberShip_No LIKE '%' + @Search + '%'";
        cmd.CommandType = CommandType.Text;
        cmd.Parameters.AddWithValue("@Search", prefixText);
        cmd.Connection = conn;
        conn.Open();
        SqlDataReader sdr = cmd.ExecuteReader();
        while (sdr.Read())
        {
            items.Add(sdr["MemberShip_No"].ToString());
        }
        return items;
    }

    protected void DdlEvent_SelectedIndexChanged(object sender, EventArgs e) { }
}


