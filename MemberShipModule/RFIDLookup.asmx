<%@ WebService Language="C#" Class="RFIDLookup" %>

using System;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[ScriptService]
public class RFIDLookup : System.Web.Services.WebService
{
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public MemberDTO GetMemberByTag(string tagNumber)
    {
        MemberDTO member = new MemberDTO();
        try
        {
            var connStringObj = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
            if (connStringObj == null) 
            {
                member.Message = "Error: Connection string 'MemberShipConnection' not found.";
                return member;
            }
            
            string cs = connStringObj.ConnectionString;

            using (SqlConnection con = new SqlConnection(cs))
            {
                string sql = @"
                    SELECT TOP 1 
                        MemberNo, 
                        MemberName AS ApplicantName, 
                        Status, 
                        AccountStatus,
                        MemberType,
                        CASE 
                            WHEN RFID = @TagNumber THEN MemberNo
                            WHEN RFIDLabel = @TagNumber OR SpouseRFID = @TagNumber THEN MemberNo + '-W'
                            ELSE MemberNo
                        END AS DisplayMemberNo
                    FROM MemberProfile
                    WHERE (RFID = @TagNumber OR RFIDLabel = @TagNumber OR SpouseRFID = @TagNumber)
                    
                    UNION
                    
                    SELECT TOP 1
                        mp.MemberNo,
                        mp.MemberName AS ApplicantName,
                        mp.Status,
                        mp.AccountStatus,
                        mp.MemberType,
                        CASE 
                            WHEN c.Relationship LIKE '%Son%' THEN mp.MemberNo + '-S'
                            WHEN c.Relationship LIKE '%Daughter%' THEN mp.MemberNo + '-D'
                            ELSE mp.MemberNo + '-C'
                        END AS DisplayMemberNo
                    FROM MemberChildren c
                    INNER JOIN MemberProfile mp ON c.MemberID = mp.MemberID
                    WHERE c.RFID = @TagNumber
                ";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@TagNumber", tagNumber ?? "");
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            member.Found = true;
                            member.MemberNo = dr["DisplayMemberNo"].ToString();
                            member.Name = dr["ApplicantName"].ToString();
                            member.Status = dr["Status"].ToString();
                            member.AccountStatus = dr["AccountStatus"].ToString();
                            member.MemberType = dr["MemberType"].ToString();
                        }
                        else
                        {
                            member.Found = false;
                            member.Message = "Member not found.";
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            member.Found = false;
            member.Message = "Server Exception: " + ex.Message;
        }
        return member;
    }

    [WebMethod]
    [ScriptMethod(UseHttpGet = true, ResponseFormat = ResponseFormat.Json)]
    public string Ping()
    {
        return "Service is alive at " + DateTime.Now.ToString();
    }
}

public class MemberDTO
{
    public bool Found { get; set; }
    public string MemberNo { get; set; }
    public string Name { get; set; }
    public string Status { get; set; }
    public string AccountStatus { get; set; }
    public string MemberType { get; set; }
    public string Message { get; set; }
}
