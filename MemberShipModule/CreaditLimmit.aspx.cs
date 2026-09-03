using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

public partial class MembershipProfile : System.Web.UI.Page
{
    private string connStr
    {
        get
        {
            var s = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
            return s != null ? s.ConnectionString : "";
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            BindMembershipType();
            BindGrid();
        }
    }

    // ?? Bind Membership Dropdown
    void BindMembershipType()
    {
        SqlDataAdapter da = new SqlDataAdapter(
            "SELECT id, FormType FROM FormTable WHERE status = 1", new SqlConnection(connStr));

        DataTable dt = new DataTable();
        da.Fill(dt);

        ddlMembershipType.DataSource = dt;
        ddlMembershipType.DataTextField = "FormType";
        ddlMembershipType.DataValueField = "FormType";
        ddlMembershipType.DataBind();
        ddlMembershipType.Items.Insert(0, new System.Web.UI.WebControls.ListItem("-- Select Category --", ""));
    }

    // ?? Bind Grid
    void BindGrid()
    {
        SqlDataAdapter da = new SqlDataAdapter(@"
            SELECT MembershipCategory, CreditLimit,
                   CASE WHEN IsActive = 1 THEN 'Active' ELSE 'Inactive' END AS IsActive
            FROM CreditLimits
            ORDER BY MembershipCategory", new SqlConnection(connStr));

        DataTable dt = new DataTable();
        da.Fill(dt);

        gvCreditLimits.DataSource = dt;
        gvCreditLimits.DataBind();
    }

    // ?? Save / Update Credit Limit with LOG
    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (ddlMembershipType.SelectedValue == "")
            return;

        decimal newLimit;
        if (!decimal.TryParse(txtCreditLimit.Text, out newLimit))
            return;

        if (Session["Emp_ID"] == null) return;
        
        int empId = 0;
        if (!int.TryParse(Session["Emp_ID"].ToString(), out empId))
        {
            return; // Silent fail - could add error message if needed
        }
        string category = ddlMembershipType.SelectedValue;

        SqlConnection con = new SqlConnection(connStr);

        con.Open();
        SqlTransaction tran = con.BeginTransaction();

        try
        {
            SqlCommand checkCmd = new SqlCommand(@"
                SELECT CreditLimitID, CreditLimit 
                FROM CreditLimits 
                WHERE MembershipCategory = @Category", con, tran);

            checkCmd.Parameters.AddWithValue("@Category", category);

            SqlDataReader dr = checkCmd.ExecuteReader();

            if (dr.Read())
            {
                int creditLimitId = Convert.ToInt32(dr["CreditLimitID"]);
                decimal oldLimit = Convert.ToDecimal(dr["CreditLimit"]);
                dr.Close();

                // LOG
                SqlCommand logCmd = new SqlCommand(@"
                    INSERT INTO CreditLimitLogs
                    (CreditLimitID, MembershipCategory, OldCreditLimit, NewCreditLimit, ChangedByEmpId)
                    VALUES
                    (@ID, @Category, @Old, @New, @Emp)", con, tran);

                logCmd.Parameters.AddWithValue("@ID", creditLimitId);
                logCmd.Parameters.AddWithValue("@Category", category);
                logCmd.Parameters.AddWithValue("@Old", oldLimit);
                logCmd.Parameters.AddWithValue("@New", newLimit);
                logCmd.Parameters.AddWithValue("@Emp", empId);
                logCmd.ExecuteNonQuery();

                // UPDATE
                SqlCommand updateCmd = new SqlCommand(@"
                    UPDATE CreditLimits
                    SET CreditLimit = @New
                    WHERE CreditLimitID = @ID", con, tran);

                updateCmd.Parameters.AddWithValue("@New", newLimit);
                updateCmd.Parameters.AddWithValue("@ID", creditLimitId);
                updateCmd.ExecuteNonQuery();
            }
            else
            {
                dr.Close();

                // INSERT
                SqlCommand insertCmd = new SqlCommand(@"
                    INSERT INTO CreditLimits
                    (EmpId, MembershipCategory, CreditLimit, IsActive)
                    VALUES
                    (@Emp, @Category, @Limit, 1)", con, tran);

                insertCmd.Parameters.AddWithValue("@Emp", empId);
                insertCmd.Parameters.AddWithValue("@Category", category);
                insertCmd.Parameters.AddWithValue("@Limit", newLimit);
                insertCmd.ExecuteNonQuery();
            }

            tran.Commit();
        }
        catch
        {
            tran.Rollback();
            throw;
        }
        finally
        {
            con.Close();
        }

        txtCreditLimit.Text = "";
        ddlMembershipType.SelectedIndex = 0;
        BindGrid();
    }
}
