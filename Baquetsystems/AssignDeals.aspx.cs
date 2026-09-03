using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;


/// <summary>
/// --------------USAMA------////////
/// </summary>
public partial class AssignDeals : System.Web.UI.Page
{
    static string constr = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            BindDropDownList();
        }
    }


    private void BindDropDownList()
    {
        string query = "SELECT 0 as DID ,'-All-' DealName union all SELECT DID, DealName FROM MainDeals";

        using (SqlConnection con = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString))
        {
            SqlDataAdapter da = new SqlDataAdapter(query, con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            ddlDeal.DataSource = dt;
            ddlDeal.DataTextField = "DealName";
            ddlDeal.DataValueField = "DID";
            ddlDeal.DataBind();
            
        }
    }


    //[WebMethod]
    //public static List<object> GetMainDeals()
    //{
    //    var list = new List<object>();

    //    using (SqlConnection con = new SqlConnection(constr))
    //    using (SqlCommand cmd = new SqlCommand("SELECT 0 as DID ,'-All-' DealName union all SELECT DID, DealName FROM MainDeals", con))
    //    {
    //        con.Open();
    //        SqlDataReader dr = cmd.ExecuteReader();
    //        while (dr.Read())
    //        {
    //            list.Add(new
    //            {
    //                DID = dr["DID"].ToString(),
    //                DealName = dr["DealName"].ToString()
    //            });
    //        }
    //    }

    //    return list;
    //}

    [WebMethod]
    public static string SaveDeal(string superName, string dealId, string type, bool allowOne, bool allowMany)
    {
        if (string.IsNullOrWhiteSpace(superName) || dealId == "0")
            return "Invalid data";

        using (SqlConnection con = new SqlConnection(constr))
        {
            con.Open();

            decimal weightage = 0;
            if (type.Equals("Additional", StringComparison.OrdinalIgnoreCase))
                weightage = -1.00M;
            else
                weightage = allowOne ? 1.00M : 0.50M;

            string checkQuery = @"SELECT COUNT(*) FROM BookingSetup 
                                  WHERE SuperName = @SuperName 
                                  AND Category = @Category 
                                  AND DealLevel = @DealLevel";

            using (SqlCommand checkCmd = new SqlCommand(checkQuery, con))
            {
                checkCmd.Parameters.AddWithValue("@SuperName", superName);
                checkCmd.Parameters.AddWithValue("@Category", type);
                checkCmd.Parameters.AddWithValue("@DealLevel", dealId);

                int exists = Convert.ToInt32(checkCmd.ExecuteScalar());

                if (exists == 0)
                {
                    string insertQuery = @"INSERT INTO BookingSetup 
                                           (DealLevel, SuperName, Category, Requird, LevelWetage)
                                           VALUES (@DealLevel, @SuperName, @Category, @Requird, @Weightage)";

                    using (SqlCommand insertCmd = new SqlCommand(insertQuery, con))
                    {
                        insertCmd.Parameters.AddWithValue("@DealLevel", dealId);
                        insertCmd.Parameters.AddWithValue("@SuperName", superName);
                        insertCmd.Parameters.AddWithValue("@Category", type);
                        insertCmd.Parameters.AddWithValue("@Requird", type.Equals("Deal", StringComparison.OrdinalIgnoreCase));
                        insertCmd.Parameters.AddWithValue("@Weightage", weightage);
                        insertCmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    return "Already exists";
                }
            }
        }

        return "Success";
    }

    [WebMethod]
    public static List<object> GetAssignedDeals(string dealId)
    {
        var list = new List<object>();

        using (SqlConnection con = new SqlConnection(constr))
        {
            string query = @"SELECT m.DealName, b.SuperName, b.Category
                             FROM BookingSetup b 
                             INNER JOIN MainDeals m ON m.DID = b.DealLevel
                             WHERE DealLevel = @DID";

            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@DID", dealId);
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                while (dr.Read())
                {
                    list.Add(new
                    {
                        DealName = dr["DealName"].ToString(),
                        SuperName = dr["SuperName"].ToString(),
                        Category = dr["Category"].ToString()
                    });
                }
            }
        }

        return list;
    }
    [System.Web.Services.WebMethod]
    public static List<DealData> GetDeals()
    {
        List<DealData> deals = new List<DealData>();
        string constr = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

        using (SqlConnection con = new SqlConnection(constr))
        using (SqlCommand cmd = new SqlCommand("SELECT DealName, SuperName, Category FROM vw_BookingSetup", con))
        {
            con.Open();
            SqlDataReader dr = cmd.ExecuteReader();
            while (dr.Read())
            {
                deals.Add(new DealData
                {
                    DealName = dr["DealName"].ToString(),
                    SuperName = dr["SuperName"].ToString(),
                    Category = dr["Category"].ToString()
                });
            }
        }

        return deals;
    }


    public class DealData
    {
        public string DealName { get; set; }
        public string SuperName { get; set; }
        public string Category { get; set; }
    }

}
