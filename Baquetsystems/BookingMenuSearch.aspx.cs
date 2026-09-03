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


public partial class Store_BookingMenuSearch : System.Web.UI.Page
{
    SqlConnection con = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString);
    String conString = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            // Pehle wala (galat)
            txtFromDate.Text = DateTime.Now.AddMonths(-1).ToString("yyyy-MM-dd");
            txtToDate.Text = DateTime.Now.AddDays(0).ToString("yyyy-MM-dd");

            // ✅ Naya (sahi) - agle 3 mahine ki bookings bhi dikhao
            txtFromDate.Text = DateTime.Now.AddMonths(-1).ToString("yyyy-MM-dd");
            txtToDate.Text = DateTime.Now.AddMonths(3).ToString("yyyy-MM-dd");
            BindMember();
            BindEventPlace();
        }
    }
    private void FillGridView()
    {
        Response.Write("FromDate: " + txtFromDate.Text + " | ToDate: " + txtToDate.Text);

        using (SqlConnection connection = new SqlConnection(conString))
        {
            SqlCommand command = new SqlCommand("uspGet_BookingDealMembers", connection);
            command.CommandType = CommandType.StoredProcedure;
            SqlDataAdapter sda = new SqlDataAdapter(command);
            command.Parameters.AddWithValue("@Member", ddlMember.SelectedValue);
            command.Parameters.AddWithValue("@Event", DdlEvent.SelectedValue);
            command.Parameters.AddWithValue("@ItemName", txtName.Text.Trim());
            command.Parameters.AddWithValue("@MemberShipNo", txtmemberNo.Text.Trim());
            command.Parameters.AddWithValue("@FromDate", txtFromDate.Text);
            command.Parameters.AddWithValue("@ToDate", txtToDate.Text);
            DataTable dt = new DataTable();
            sda.Fill(dt);
            GridView1.DataSource = dt;
            GridView1.DataBind();
        }
    }
    protected void BindMember()
    {
        SqlCommand cmd;
        try
        {
            con.Open();
            try
            {
                cmd = new SqlCommand("SELECT  0 as Member_Id, '--- All ---' as Member_Name union select Member_Id , Member_Name from member", con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                ddlMember.DataSource = dt;
                ddlMember.DataTextField = "Member_Name";
                ddlMember.DataValueField = "Member_Id";
                ddlMember.DataSource = dt;
                ddlMember.DataBind();
                con.Close();
            }
            catch (Exception)
            {

                con.Close();
            }

        }
        catch (Exception)
        {
        }
    }
    protected void BindEventPlace()
    {
        SqlCommand cmd;
        try
        {
            con.Open();
            try
            {
                cmd = new SqlCommand("SELECT  0 as Event_Id, '--- All ---' as Event_Place union select Event_Id , Event_Place from EventBookingPlace", con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                DdlEvent.DataSource = dt;
                DdlEvent.DataTextField = "Event_Place";
                DdlEvent.DataValueField = "Event_Id";
                DdlEvent.DataSource = dt;
                DdlEvent.DataBind();
                con.Close();
            }
            catch (Exception)
            {

                con.Close();
            }
        }
        catch (Exception)
        {
        }
    }
    protected void Button1_Click(object sender, EventArgs e)
    {
        FillGridView();
    }
    protected void btnGenerateReport_Click(object sender, EventArgs e)
    {
        Button btn = (Button)sender;
        int bookingMainId = Convert.ToInt32(btn.CommandArgument);
        loadReport(bookingMainId);
    }
    protected void loadReport(int bookingMainId)
    {
        string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;
        DataTable VehicleData = ExecuteDataTable("uspGetBookingMainManuReport", connectionString,
           new SqlParameter("@BookingMain_Id", bookingMainId));
        DataTable AllExpensesData = ExecuteDataTable("uspGetBookingSubManuReport", connectionString,
            new SqlParameter("@BookingMain_Id", bookingMainId));
        DataTable Aditional = ExecuteDataTable("uspGetBookingSubManuReportOther", connectionString,
          new SqlParameter("@BookingMain_Id", bookingMainId));
//         ReportViewer1.LocalReport.DataSources.Clear();
        string rdlcPath;
        rdlcPath = "~/Store/BookingMenuReports.rdlc";
        string reportPath = Server.MapPath(rdlcPath);
//         ReportViewer1.LocalReport.ReportPath = reportPath;
//         ReportViewer1.LocalReport.DataSources.Add(new object("DataSet1", VehicleData));
//         ReportViewer1.LocalReport.DataSources.Add(new object("DataSet2", AllExpensesData));
//         ReportViewer1.LocalReport.DataSources.Add(new object("DataSet3", Aditional));
//         ReportViewer1.LocalReport.SubreportProcessing += new SubreportProcessingEventHandler(subReports);
        if (Request.Browser.Browser == "Chrome")
        {
//             byte[] bytes = ReportViewer1.LocalReport.Render("PDF");
            Response.AddHeader("Content-Disposition", "inline; filename=MyReport.pdf");
            Response.ContentType = "application/pdf";
//             Response.BinaryWrite(bytes);
            Response.End();
        }
        else
        {
//             ReportViewer1.Visible = true;
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
        catch (Exception)
        {
        }
    }


    protected void btnReport_Click(object sender, EventArgs e)
    {
        try
        {
            DateTime fromDate = DateTime.Parse(txtFromDate.Text);
            DateTime toDate = DateTime.Parse(txtToDate.Text);
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("GetMemberDetailsReport", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@FromDate", fromDate);
                    cmd.Parameters.AddWithValue("@ToDate", toDate);
                    conn.Open();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataSet ds = new DataSet();
                    da.Fill(ds, "DataSet1"); 
                    string rdlcPath = "~/Store/BookingMemberReport.rdlc";
                    string reportPath = Server.MapPath(rdlcPath);
//                     ReportViewer2.LocalReport.ReportPath = reportPath;
//                     ReportViewer2.LocalReport.DataSources.Clear(); 
//                     ReportViewer2.LocalReport.DataSources.Add(new object("DataSet1", ds.Tables["DataSet1"]));
//                     ReportViewer2.LocalReport.SubreportProcessing += new SubreportProcessingEventHandler(subReports);
                    if (Request.Browser.Browser == "Chrome")
                    {
//                         byte[] bytes = ReportViewer2.LocalReport.Render("PDF");
                        Response.AddHeader("Content-Disposition", "inline; filename=MyReport.pdf");
                        Response.ContentType = "application/pdf";
//                         Response.BinaryWrite(bytes);
                        Response.End();
                    }
                    else
                    {
//                         ReportViewer2.Visible = true; 
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Response.Write("Error: " + ex.Message);
        }
    }



    protected void EventWiseConsumptionReport(int bookingMainId)
    {
        string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;
        DataTable AllExpensesData = ExecuteDataTables("uspGetBookingSubManuReport", connectionString,
        new SqlParameter("@BookingMain_Id", bookingMainId));
//         ReportViewer1.LocalReport.DataSources.Clear();
        string rdlcPath;
        rdlcPath = "~/Store/EventWiseConsumptionReport.rdlc";
        string reportPath = Server.MapPath(rdlcPath);
//         ReportViewer1.LocalReport.ReportPath = reportPath;
//         ReportViewer1.LocalReport.DataSources.Add(new object("DataSet2", AllExpensesData));
//         ReportViewer1.LocalReport.SubreportProcessing += new SubreportProcessingEventHandler(subReports);
        if (Request.Browser.Browser == "Chrome")
        {
//             byte[] bytes = ReportViewer1.LocalReport.Render("PDF");
            Response.AddHeader("Content-Disposition", "inline; filename=MyReport.pdf");
            Response.ContentType = "application/pdf";
//             Response.BinaryWrite(bytes);
            Response.End();
        }
        else
        {
//             ReportViewer1.Visible = true;
        }
    }
    private DataTable ExecuteDataTables(string storedProcedure, string connectionString, params SqlParameter[] parameters)
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
    protected void txtmemberNo_TextChanged(object sender, EventArgs e)
    {
        try
        {
            string search = txtmemberNo.Text.Trim();

            string constr = ConfigurationManager
                .ConnectionStrings["MemberShipConnection"]
                .ConnectionString;

            ScanRFID scanner = new ScanRFID(constr);

            DataTable dt = scanner.CheckRFID(search);

            if (dt == null || dt.Rows.Count == 0)
            {
                ddlMember.Items.Clear();
                lblStatus.Text = "Member not found";
                return;
            }

            DataRow rd = dt.Rows[0];

            // Same validation as GetMember()
            bool isActive =
                rd["IsActive"].ToString().Trim().ToLower() == "true" ||
                rd["IsActive"].ToString().Trim() == "1";

            bool isCardActive =
                rd["IsCardActive"].ToString().Trim().ToLower() == "true" ||
                rd["IsCardActive"].ToString().Trim() == "1";

            string status = rd["Status"].ToString().Trim().ToLower();

            if (!isActive || !isCardActive ||
                (status != "active" && status != "absentee"))
            {
                ddlMember.Items.Clear();
                lblStatus.Text = "Member account is " + status;
                return;
            }

            ddlMember.Items.Clear();
            ddlMember.Items.Add(
                new ListItem(
                    rd["MemberName"].ToString(),
                    rd["MemberID"].ToString()
                ));

            lblStatus.Text = rd["Status"].ToString();
        }
        catch (Exception ex)
        {
            lblStatus.Text = ex.Message;
        }
    }

}



