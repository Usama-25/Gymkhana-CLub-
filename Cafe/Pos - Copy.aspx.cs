using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Collections.Generic;
using System.Web;

public partial class Pos : System.Web.UI.Page
{
    string constr = System.Configuration.ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        // All dynamic loading done using AJAX
    }

    // ---------------- GET PRODUCTS ----------------
    [System.Web.Services.WebMethod]
    public static object GetProducts(string search)
    {
        string constr = System.Configuration.ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
        DataTable dt = new DataTable();

        using (SqlConnection con = new SqlConnection(constr))
        {
            string query = @"SELECT TOP 30 Id, Name, Price,
                         'resources/images/NoProduct.png' AS ImagePath
                         FROM MenuItems
                         WHERE (@search = '' OR Name LIKE '%' + @search + '%')";

            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@search", search ?? "");
                using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                {
                    sda.Fill(dt);
                }
            }
        }

        var list = new List<object>();
        foreach (DataRow row in dt.Rows)
        {
            list.Add(new
            {
                id = row["Id"].ToString(),
                name = row["Name"].ToString(),
                price = Convert.ToDecimal(row["Price"]),
                image = VirtualPathUtility.ToAbsolute("~/" + row["ImagePath"])
            });
        }

        return list;
    }

    // ---------------- GET MEMBER ----------------
    [System.Web.Services.WebMethod]
    public static object GetMember(string search)
    {
        string constr = System.Configuration.ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

        using (SqlConnection con = new SqlConnection(constr))
        {
            SqlCommand cmd = new SqlCommand(@"
                SELECT TOP 1 
                    mc.CardNo,
                    pt.PLName AS DisplayName,
                    pt.PLName AS Name,
                    pt.MobilePhone AS Mobile,
                    mb.Credit AS Balance
                FROM MemberCard mc
                INNER JOIN Patient pt ON pt.RegNo = mc.MemberID
                INNER JOIN MemberBalance mb ON mb.MemberNo = pt.RegNo
                WHERE mc.CardNo = @val OR mc.CardNo LIKE @val + '%'
            ", con);

            cmd.Parameters.AddWithValue("@val", search);

            con.Open();
            var rd = cmd.ExecuteReader();

            if (!rd.Read()) return null;

            return new
            {
                empID = rd["CardNo"].ToString(),
                name = rd["DisplayName"].ToString(),
                rfName = rd["Name"].ToString(),
                mobile = rd["Mobile"].ToString(),
                balance = Convert.ToDecimal(rd["Balance"])
            };
        }
    }

    // ---------------- SUBMIT BILL ----------------
    [System.Web.Services.WebMethod]
    public static object SubmitBill(string empID, decimal totalAmount)
    {
        string constr = System.Configuration.ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

        using (SqlConnection con = new SqlConnection(constr))
        {
            con.Open();
            SqlTransaction tran = con.BeginTransaction();

            try
            {
                // Get current balance
                SqlCommand getBal = new SqlCommand("SELECT Credit FROM MemberBalance WHERE MemberNo=@id", con, tran);
                getBal.Parameters.AddWithValue("@id", empID);

                var b = getBal.ExecuteScalar();
                if (b == null) return new { success = false, message = "Member not found!" };

                decimal balance = Convert.ToDecimal(b);

                if (balance < totalAmount)
                    return new { success = false, message = "Insufficient balance!" };

                // Deduct balance
                SqlCommand upd = new SqlCommand("UPDATE MemberBalance SET Credit = Credit - @amt WHERE MemberNo=@id", con, tran);
                upd.Parameters.AddWithValue("@amt", totalAmount);
                upd.Parameters.AddWithValue("@id", empID);
                upd.ExecuteNonQuery();

                tran.Commit();

                return new
                {
                    success = true,
                    remaining = balance - totalAmount
                };
            }
            catch (Exception ex)
            {
                tran.Rollback();
                return new { success = false, message = ex.Message };
            }
        }
    }
}


