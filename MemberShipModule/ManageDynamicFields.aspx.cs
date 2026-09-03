using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ManageDynamicFields : System.Web.UI.Page
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
            EnsureTrackingTableExists();
            LoadTables();
            BindGrid();
        }
    }

    /// <summary>
    /// Auto-creates the tracking table if it doesn't exist yet, to prevent manual SQL execution needs.
    /// </summary>
    private void EnsureTrackingTableExists()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            try
            {
                con.Open();
                string sql = @"
                    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DynamicFields]') AND type in (N'U'))
                    BEGIN
                        CREATE TABLE [dbo].[DynamicFields](
                            [FieldID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
                            [TableName] [nvarchar](100) NULL,
                            [FieldName] [nvarchar](100) NULL,
                            [FieldLabel] [nvarchar](100) NULL,
                            [FieldType] [nvarchar](50) NULL,
                            [FieldOptions] [nvarchar](max) NULL,
                            [IsActive] [bit] NULL DEFAULT ((1)),
                            [CreatedDate] [datetime] NULL DEFAULT (getdate())
                        )
                    END";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }
    }

    private void LoadTables()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            try
            {
                // Fetch all user tables avoiding system tables
                SqlDataAdapter da = new SqlDataAdapter("SELECT name FROM sys.tables WHERE is_ms_shipped = 0 ORDER BY name", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                ddlTableName.DataSource = dt;
                ddlTableName.DataTextField = "name";
                ddlTableName.DataValueField = "name";
                ddlTableName.DataBind();
                ddlTableName.Items.Insert(0, new ListItem("-- Select Target Database Table --", ""));
            }
            catch { }
        }
    }

    private void BindGrid()
    {
        using (SqlConnection con = new SqlConnection(connStr))
        {
            try
            {
                SqlDataAdapter da = new SqlDataAdapter(@"SELECT FieldID, TableName, FieldName, FieldLabel, FieldType, ISNULL(IsActive, 1) as IsActive 
                                                         FROM DynamicFields ORDER BY FieldID DESC", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvFields.DataSource = dt;
                gvFields.DataBind();
            }
            catch { }
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        string tableName = ddlTableName.SelectedValue;
        string fieldLabel = txtFieldLabel.Text.Trim();
        string fieldName = txtFieldName.Text.Trim().Replace(" ", ""); // For safety, strip spaces
        string fieldType = ddlFieldType.SelectedValue;
        string fieldOptions = txtFieldOptions.Text.Trim();

        if (string.IsNullOrEmpty(tableName) || string.IsNullOrEmpty(fieldLabel) || string.IsNullOrEmpty(fieldName))
        {
            ShowMessage("Please fill in all required fields marked with an asterisk (*).", false);
            return;
        }

        if (fieldType == "Dropdown" && string.IsNullOrEmpty(fieldOptions))
        {
            ShowMessage("Please provide comma-separated options for the Dropdown list.", false);
            return;
        }

        // Strict input validation to prevent SQL injection during DDL ALTER TABLE execution
        if (!Regex.IsMatch(tableName, @"^[a-zA-Z0-9_]+$") || !Regex.IsMatch(fieldName, @"^[a-zA-Z0-9_]+$"))
        {
            ShowMessage("Validation Error: Table name or column name contains invalid characters. Use letters, numbers, or underscores only.", false);
            return;
        }

        // Map UI type to SQL Data Type
        string dataType = "NVARCHAR(255)";
        if (fieldType == "Multiline") dataType = "NVARCHAR(MAX)";
        else if (fieldType == "Checkbox") dataType = "BIT";
        else if (fieldType == "Date") dataType = "DATE";
        else if (fieldType == "Number") dataType = "DECIMAL(18,2)";

        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            SqlTransaction tran = con.BeginTransaction();
            try
            {
                // 1. Physically Inject Column into the Target Table
                string alterSql = "ALTER TABLE [" + tableName + "] ADD [" + fieldName + "] " + dataType;
                using (SqlCommand cmdAlter = new SqlCommand(alterSql, con, tran))
                {
                    cmdAlter.ExecuteNonQuery();
                }

                // 2. Log metadata in the tracking table so your frontend builder knows about it
                string insertSql = @"INSERT INTO DynamicFields (TableName, FieldName, FieldLabel, FieldType, FieldOptions, IsActive)
                                     VALUES (@TableName, @FieldName, @FieldLabel, @FieldType, @FieldOptions, 1)";
                using (SqlCommand cmdInsert = new SqlCommand(insertSql, con, tran))
                {
                    cmdInsert.Parameters.AddWithValue("@TableName", tableName);
                    cmdInsert.Parameters.AddWithValue("@FieldName", fieldName);
                    cmdInsert.Parameters.AddWithValue("@FieldLabel", fieldLabel);
                    cmdInsert.Parameters.AddWithValue("@FieldType", fieldType);
                    cmdInsert.Parameters.AddWithValue("@FieldOptions", fieldOptions);
                    cmdInsert.ExecuteNonQuery();
                }

                tran.Commit();
                ShowMessage("<i class='fas fa-check-circle'></i> Column <b>'" + fieldName + "'</b> successfully injected into table <b>'" + tableName + "'</b>.", true);
                ClearForm();
                BindGrid();
            }
            catch (Exception ex)
            {
                tran.Rollback();
                // Common exception capture for pre-existing columns
                if (ex.Message.Contains("already has a column") || ex.Message.Contains("already exists"))
                {
                    ShowMessage("<i class='fas fa-exclamation-circle'></i> Error: The column <b>'" + fieldName + "'</b> already exists in table '" + tableName + "'. Try a different name.", false);
                }
                else
                {
                    ShowMessage("<i class='fas fa-exclamation-circle'></i> Database Error: " + ex.Message, false);
                }
            }
        }
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        ClearForm();
    }

    private void ClearForm()
    {
        ddlTableName.SelectedIndex = 0;
        txtFieldLabel.Text = "";
        txtFieldName.Text = "";
        ddlFieldType.SelectedIndex = 0;
        txtFieldOptions.Text = "";
        ScriptManager.RegisterStartupScript(this, GetType(), "toggleOptionsClear", "toggleOptions();", true);
    }

    private void ShowMessage(string msg, bool success)
    {
        lblMsg.Text = msg;
        lblMsg.CssClass = success ? "mmt-msg-success" : "mmt-msg-error";
        lblMsg.Visible = true;
    }
}
