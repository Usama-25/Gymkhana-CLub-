<%@ Page Language="C#" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<!DOCTYPE html>
<html>
<head><title>Test BookSearch Filters Raw</title></head>
<body>
    <form id="form1" runat="server">
    <div>
        <h2>Testing sp_SearchBooksAdvanced Directly via SqlClient</h2>
        <%
        string connStr = ConfigurationManager.ConnectionStrings["GymkhanaLibraryDB"].ConnectionString;
        
        Func<short?, int> runSearch = (catID) => {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("sp_SearchBooksAdvanced", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@CatID", (object)catID ?? DBNull.Value);
                    
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    return dt.Rows.Count;
                }
            }
        };

        Func<string, int> runSearchAuthor = (author) => {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("sp_SearchBooksAdvanced", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Author", (object)author ?? DBNull.Value);
                    
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    return dt.Rows.Count;
                }
            }
        };

        try
        {
            // Test 1: CatID = 1
            int countCat1 = runSearch(1);
            Response.Write("<p><b>Filter CatID = 1:</b> Found " + countCat1 + " books.</p>");

            // Test 2: CatID = 2
            int countCat2 = runSearch(2);
            Response.Write("<p><b>Filter CatID = 2:</b> Found " + countCat2 + " books.</p>");
            
            // Test 3: Author = "Orwell"
            int countOrwell = runSearchAuthor("Orwell");
            Response.Write("<p><b>Filter Author = 'Orwell':</b> Found " + countOrwell + " books.</p>");
            
            // Test 4: All Null
            int countAll = runSearch(null);
            Response.Write("<p><b>No Filters:</b> Found " + countAll + " books.</p>");
        }
        catch (Exception ex)
        {
            Response.Write("<pre style='color:red;'>" + ex.ToString() + "</pre>");
        }
        %>
    </div>
    </form>
</body>
</html>
