using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace GymKhana.Library
{
    public class ScanRFID
    {
        private readonly string _connectionString;

        public ScanRFID()
        {
            _connectionString = string.Empty;
        }

        public ScanRFID(string connectionString)
        {
            _connectionString = connectionString;
        }

        public DataTable CheckRFID(string inputValue)
        {
            DataTable dt = new DataTable();

            try
            {
                string connStr = !string.IsNullOrEmpty(_connectionString)
                    ? _connectionString
                    : (ConfigurationManager.ConnectionStrings["MemberShipConnection"] != null
                        ? ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString
                        : (ConfigurationManager.ConnectionStrings["GymkhanaDB"] != null
                            ? ConfigurationManager.ConnectionStrings["GymkhanaDB"].ConnectionString
                            : ""));

                using (SqlConnection con = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("usp_CheckMemberByMemberNo", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Input", inputValue);

                    con.Open();

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                }
            }
            catch (SqlException ex)
            {
                // SQL RAISERROR messages from stored procedure
                throw new Exception(ex.Message);
            }
            catch (Exception ex)
            {
                throw new Exception("Error while checking RFID/Member: " + ex.Message);
            }

            return dt;
        }
    }
}

