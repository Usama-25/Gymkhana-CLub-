using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

public class DbManager
{
    private string GetConnectionString(string connectionStringName)
    {
        if (ConfigurationManager.ConnectionStrings[connectionStringName] != null)
        {
            return ConfigurationManager.ConnectionStrings[connectionStringName].ConnectionString;
        }
        return connectionStringName;
    }

    public DataTable ExecuteDataTable(string spName, string connectionStringName, SqlParameter[] parameters)
    {
        DataTable dt = new DataTable();
        using (SqlConnection conn = new SqlConnection(GetConnectionString(connectionStringName)))
        {
            using (SqlCommand cmd = new SqlCommand(spName, conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                if (parameters != null)
                {
                    cmd.Parameters.AddRange(parameters);
                }
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
        }
        return dt;
    }

    public DataTable ExecuteDataTableWithQuery(string query, string connectionStringName, SqlParameter[] parameters)
    {
        DataTable dt = new DataTable();
        using (SqlConnection conn = new SqlConnection(GetConnectionString(connectionStringName)))
        {
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.CommandType = CommandType.Text;
                if (parameters != null)
                {
                    cmd.Parameters.AddRange(parameters);
                }
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
        }
        return dt;
    }

    public int ExecuteNonQuery(string commandText, string connectionStringName, SqlParameter[] parameters, CommandType commandType = CommandType.Text)
    {
        using (SqlConnection conn = new SqlConnection(GetConnectionString(connectionStringName)))
        {
            using (SqlCommand cmd = new SqlCommand(commandText, conn))
            {
                cmd.CommandType = commandType;
                if (parameters != null)
                {
                    cmd.Parameters.AddRange(parameters);
                }
                conn.Open();
                return cmd.ExecuteNonQuery();
            }
        }
    }
}
