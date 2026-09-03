using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ManageAffiliatedClubs : System.Web.UI.Page
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
            EnsureTable();
            BindGrid();
            LoadStats();
        }
    }

    private void EnsureTable()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            
            // 1. Run direct table alterations to ensure the configuration columns exist in the active database
            string alterSql = @"
                IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='AffiliatedClubs' AND COLUMN_NAME='MaxDaysPerMonth')
                BEGIN
                    ALTER TABLE AffiliatedClubs ADD MaxDaysPerMonth INT NOT NULL DEFAULT 15;
                END

                IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='AffiliatedClubs' AND COLUMN_NAME='MaxTransactionsPerMonth')
                BEGIN
                    ALTER TABLE AffiliatedClubs ADD MaxTransactionsPerMonth INT NOT NULL DEFAULT 15;
                END

                IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='AffiliatedClubs' AND COLUMN_NAME='MaxVisitsPerYear')
                BEGIN
                    ALTER TABLE AffiliatedClubs ADD MaxVisitsPerYear INT NOT NULL DEFAULT 3;
                END";
                
            using (SqlCommand cmd = new SqlCommand(alterSql, con))
            {
                cmd.ExecuteNonQuery();
            }

            // 2. Re-create/update the usp_EnsureAffiliatedClubsTable stored procedure
            string spEnsureSql = @"
                IF OBJECT_ID('usp_EnsureAffiliatedClubsTable', 'P') IS NOT NULL
                    DROP PROCEDURE usp_EnsureAffiliatedClubsTable;";
            using (SqlCommand cmd = new SqlCommand(spEnsureSql, con)) { cmd.ExecuteNonQuery(); }

            string spEnsureCreateSql = @"
                CREATE PROCEDURE usp_EnsureAffiliatedClubsTable
                AS
                BEGIN
                    SET NOCOUNT ON;
                END";
            using (SqlCommand cmd = new SqlCommand(spEnsureCreateSql, con)) { cmd.ExecuteNonQuery(); }

            // 3. Re-create/update the usp_UpsertAffiliatedClub stored procedure
            string spUpsertSql = @"
                IF OBJECT_ID('usp_UpsertAffiliatedClub', 'P') IS NOT NULL
                    DROP PROCEDURE usp_UpsertAffiliatedClub;";
            using (SqlCommand cmd = new SqlCommand(spUpsertSql, con)) { cmd.ExecuteNonQuery(); }

            string spUpsertCreateSql = @"
                CREATE PROCEDURE usp_UpsertAffiliatedClub
                    @Id INT = 0,
                    @ClubID NVARCHAR(50),
                    @ClubName NVARCHAR(200),
                    @ClubAddress NVARCHAR(MAX),
                    @Phone NVARCHAR(50),
                    @Whatsapp NVARCHAR(50),
                    @ReceptionPhone NVARCHAR(50),
                    @Email NVARCHAR(100),
                    @MaxDaysPerMonth INT = 15,
                    @MaxTransactionsPerMonth INT = 15,
                    @MaxVisitsPerYear INT = 3
                AS
                BEGIN
                    SET NOCOUNT ON;
                    IF @Id > 0
                    BEGIN
                        UPDATE AffiliatedClubs SET 
                            ClubID = @ClubID, 
                            ClubName = @ClubName, 
                            ClubAddress = @ClubAddress, 
                            Phone = @Phone, 
                            Whatsapp = @Whatsapp, 
                            ReceptionPhone = @ReceptionPhone, 
                            Email = @Email,
                            MaxDaysPerMonth = @MaxDaysPerMonth,
                            MaxTransactionsPerMonth = @MaxTransactionsPerMonth,
                            MaxVisitsPerYear = @MaxVisitsPerYear
                        WHERE Id = @Id;
                    END
                    ELSE
                    BEGIN
                        INSERT INTO AffiliatedClubs (ClubID, ClubName, ClubAddress, Phone, Whatsapp, ReceptionPhone, Email, Status, MaxDaysPerMonth, MaxTransactionsPerMonth, MaxVisitsPerYear)
                        VALUES (@ClubID, @ClubName, @ClubAddress, @Phone, @Whatsapp, @ReceptionPhone, @Email, 1, @MaxDaysPerMonth, @MaxTransactionsPerMonth, @MaxVisitsPerYear);
                    END
                END";
            using (SqlCommand cmd = new SqlCommand(spUpsertCreateSql, con)) { cmd.ExecuteNonQuery(); }

            // 4. Refresh metadata for usp_GetAffiliatedClubs to ensure SELECT * returns the newly added columns
            string refreshSql = @"
                IF OBJECT_ID('usp_GetAffiliatedClubs', 'P') IS NOT NULL
                BEGIN
                    EXEC sp_refreshsqlmodule 'usp_GetAffiliatedClubs';
                END";
            try
            {
                using (SqlCommand cmdRefresh = new SqlCommand(refreshSql, con))
                {
                    cmdRefresh.ExecuteNonQuery();
                }
            }
            catch { /* Ignore if fails */ }
        }
    }

    private void BindGrid()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            SqlCommand cmd = new SqlCommand("usp_GetAffiliatedClubs", con);
            cmd.CommandType = CommandType.StoredProcedure;
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            gvClubs.DataSource = dt;
            gvClubs.DataBind();
        }
    }

    private void LoadStats()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            SqlCommand cmd = new SqlCommand("usp_GetAffiliatedClubsStats", con);
            cmd.CommandType = CommandType.StoredProcedure;
            con.Open();
            SqlDataReader dr = cmd.ExecuteReader();
            if (dr.Read())
            {
                lblTotalClubs.Text = dr["TotalClubs"].ToString();
                lblActiveClubs.Text = dr["ActiveClubs"].ToString();
                lblDeactiveClubs.Text = dr["DeactiveClubs"].ToString();
            }
        }
        upStats.Update();
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        string clubID = txtClubID.Text.Trim();
        string clubName = txtClubName.Text.Trim();
        
        if (string.IsNullOrEmpty(clubID) || string.IsNullOrEmpty(clubName))
        {
            ShowMessage("Club ID and Club Name are required.", false);
            return;
        }

        int id = 0;
        int.TryParse(hfClubId.Value, out id);

        using (SqlConnection con = new SqlConnection(connStr))
        {
            using (SqlCommand cmd = new SqlCommand("usp_UpsertAffiliatedClub", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@Id", SqlDbType.Int).Value = id;
                cmd.Parameters.Add("@ClubID", SqlDbType.NVarChar, 50).Value = clubID;
                cmd.Parameters.Add("@ClubName", SqlDbType.NVarChar, 200).Value = clubName;
                cmd.Parameters.Add("@ClubAddress", SqlDbType.NVarChar, 500).Value = txtClubAddress.Text.Trim();
                cmd.Parameters.Add("@Phone", SqlDbType.NVarChar, 50).Value = txtPhone.Text.Trim();
                cmd.Parameters.Add("@Whatsapp", SqlDbType.NVarChar, 50).Value = txtWhatsapp.Text.Trim();
                cmd.Parameters.Add("@ReceptionPhone", SqlDbType.NVarChar, 50).Value = txtReceptionPhone.Text.Trim();
                cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 200).Value = txtEmail.Text.Trim();

                int maxDays = 15;
                int maxTx = 15;
                int maxVisits = 3;
                int.TryParse(txtMaxDays.Text.Trim(), out maxDays);
                int.TryParse(txtMaxTx.Text.Trim(), out maxTx);
                int.TryParse(txtMaxVisits.Text.Trim(), out maxVisits);

                cmd.Parameters.Add("@MaxDaysPerMonth", SqlDbType.Int).Value = maxDays;
                cmd.Parameters.Add("@MaxTransactionsPerMonth", SqlDbType.Int).Value = maxTx;
                cmd.Parameters.Add("@MaxVisitsPerYear", SqlDbType.Int).Value = maxVisits;

                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        ClearForm();
        BindGrid();
        LoadStats();
        ShowMessage(id > 0 ? "Club updated successfully." : "New club added successfully.", true);
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        ClearForm();
    }

    protected void gvClubs_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int id = Convert.ToInt32(e.CommandArgument);
        if (e.CommandName == "EditItem")
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("usp_GetAffiliatedClubById", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@Id", SqlDbType.Int).Value = id;
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    hfClubId.Value = dr["Id"].ToString();
                    txtClubID.Text = dr["ClubID"].ToString();
                    txtClubName.Text = dr["ClubName"].ToString();
                    txtClubAddress.Text = dr["ClubAddress"].ToString();
                    txtPhone.Text = dr["Phone"].ToString();
                    txtWhatsapp.Text = dr["Whatsapp"].ToString();
                    txtReceptionPhone.Text = dr["ReceptionPhone"].ToString();
                    txtEmail.Text = dr["Email"].ToString();
                    txtMaxDays.Text = dr["MaxDaysPerMonth"].ToString();
                    txtMaxTx.Text = dr["MaxTransactionsPerMonth"].ToString();
                    txtMaxVisits.Text = dr["MaxVisitsPerYear"].ToString();
                    btnSave.Text = "Update Club";
                }
            }
        }
    }

    protected void btnConfirmToggle_Click(object sender, EventArgs e)
    {
        int id = 0;
        int.TryParse(hfToggleId.Value, out id);
        int currentStatus = 0;
        int.TryParse(hfToggleCurrentStatus.Value, out currentStatus);
        string reason = txtToggleReason.Text.Trim();

        if (string.IsNullOrEmpty(reason))
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Please enter a reason.');", true);
            return;
        }

        string userName = Session["Emp_Name"] != null ? Session["Emp_Name"].ToString() : "System";

        using (SqlConnection con = new SqlConnection(connStr))
        {
            using (SqlCommand cmd = new SqlCommand("usp_ToggleAffiliatedClubStatus", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@Id", SqlDbType.Int).Value = id;
                cmd.Parameters.Add("@CurrentStatus", SqlDbType.Int).Value = currentStatus;
                cmd.Parameters.Add("@Reason", SqlDbType.NVarChar, 500).Value = reason;
                cmd.Parameters.Add("@ChangedBy", SqlDbType.NVarChar, 100).Value = userName;

                try
                {
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
                catch (Exception ex)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Error updating status: " + ex.Message.Replace("'", "\\'") + "');", true);
                    return;
                }
            }
        }

        BindGrid();
        LoadStats();
        ShowMessage("Club status updated successfully.", true);
    }

    private void ClearForm()
    {
        hfClubId.Value = "0";
        txtClubID.Text = "";
        txtClubName.Text = "";
        txtClubAddress.Text = "";
        txtPhone.Text = "";
        txtWhatsapp.Text = "";
        txtReceptionPhone.Text = "";
        txtEmail.Text = "";
        txtMaxDays.Text = "15";
        txtMaxTx.Text = "15";
        txtMaxVisits.Text = "3";
        btnSave.Text = "Save Club";
    }

    private void ShowMessage(string msg, bool success)
    {
        lblMsg.Text = msg;
        lblMsg.CssClass = success ? "mmt-msg-success" : "mmt-msg-error";
        lblMsg.Visible = true;
    }
}
