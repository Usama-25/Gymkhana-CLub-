using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

public partial class BanquetBookingsearch : System.Web.UI.Page
{
    private string constr = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            BindBookingGrid();
        }
    }

    private void BindBookingGrid()
    {
        using (SqlConnection con = new SqlConnection(constr))
        {
            SqlCommand cmd = new SqlCommand("SELECT ID AS BookingMain_Id, SuperName AS MemberName, SuperName AS Contact_person, SuperName AS Event_Place, SuperName AS EventName, DealLevel AS MemberShipNo, Category AS PartyDate, 100 AS Total_Person FROM BookingSetup", con);
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            gvBooking.DataSource = dt;
            gvBooking.DataBind();
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        BindBookingGrid();
    }

    protected void btnIngredients_Click(object sender, EventArgs e)
    {
        Button btn = (Button)sender;
        int bookingID = Convert.ToInt32(btn.CommandArgument);
        GeneratePDFReport(bookingID);
    }

    private void GeneratePDFReport(int bookingID)
    {
        Response.Clear();
        Response.ContentType = "application/pdf";
        Response.AddHeader("Content-Disposition", "inline; filename=IngredientsReport.pdf");
        Response.End();
    }
}
