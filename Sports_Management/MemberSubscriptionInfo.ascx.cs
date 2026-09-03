using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Collections.Generic;

public partial class MemberSubscriptionInfo : System.Web.UI.UserControl
{
    string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;

    public void LoadFamilySubscriptions(int memberId, string mainMemberName)
    {
        lblMainMemberName.Text = mainMemberName;
        divContainer.Visible = true;

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetFamilySubscriptions", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@MemberID", memberId);
                    
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (Session["UserRole"] != null && Session["UserRole"].ToString() == "Operator")
                        {
                            List<int> allowedSports = Session["AllowedSports"] as List<int>;
                            if (allowedSports != null && allowedSports.Count > 0)
                            {
                                for (int i = dt.Rows.Count - 1; i >= 0; i--)
                                {
                                    if (dt.Rows[i]["SportID"] != DBNull.Value)
                                    {
                                        int sportId = Convert.ToInt32(dt.Rows[i]["SportID"]);
                                        if (!allowedSports.Contains(sportId))
                                        {
                                            dt.Rows.RemoveAt(i);
                                        }
                                    }
                                }
                            }
                            else
                            {
                                dt.Clear();
                            }
                        }

                        gvFamilySubs.DataSource = dt;
                        gvFamilySubs.DataBind();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // Log error
        }
    }
    
    public void Clear()
    {
        divContainer.Visible = false;
        gvFamilySubs.DataSource = null;
        gvFamilySubs.DataBind();
    }
}
