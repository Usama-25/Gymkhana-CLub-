using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

public partial class DepartmentWiseShare : System.Web.UI.Page
{
    string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;

    private string GetBasicDataConnString()
    {
        return ConfigurationManager.ConnectionStrings["BasicDataInfoConnString"] != null 
            ? ConfigurationManager.ConnectionStrings["BasicDataInfoConnString"].ConnectionString 
            : connString.Replace("SportsModuleDB", "BasicDataInfo");
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        EnsureTablesExist();

        if (!IsPostBack)
        {
            LoadDepartments();
            LoadPackages();
            LoadSharesGrid();
        }
    }

    private void EnsureTablesExist()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                string sql = @"
                    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PackageDepartmentShares')
                    BEGIN
                        CREATE TABLE [PackageDepartmentShares] (
                            [ShareID] INT IDENTITY(1,1) PRIMARY KEY,
                            [SubscriptionID] INT NOT NULL FOREIGN KEY REFERENCES [Subscriptions](SubscriptionID),
                            [DepartmentID] INT NOT NULL,
                            [ShareMode] NVARCHAR(10) NOT NULL,
                            [ShareValue] DECIMAL(18,2) NOT NULL,
                            [CreatedOn] DATETIME DEFAULT GETDATE(),
                            [IsActive] BIT DEFAULT 1
                        );
                    END;

                    DECLARE @sql NVARCHAR(MAX) = '';
                    SELECT @sql += 'ALTER TABLE [PackageDepartmentShares] DROP CONSTRAINT [' + name + '];'
                    FROM sys.foreign_keys 
                    WHERE parent_object_id = OBJECT_ID('PackageDepartmentShares') 
                      AND (referenced_object_id = OBJECT_ID('Departments') OR name LIKE '%Depar%');
                    IF @sql <> '' EXEC sp_executesql @sql;";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Table check/creation error: " + ex.Message);
        }
    }

    // ============================================
    // DEPARTMENT MANAGEMENT (BasicDataInfo DB)
    // ============================================

    private void LoadDepartments()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(GetBasicDataConnString()))
            {
                string query = "SELECT Dept_ID AS DepartmentID, Dept_Name AS DepartmentName FROM Department ORDER BY Dept_Name";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvDepartments.DataSource = dt;
                        gvDepartments.DataBind();
                    }
                }
            }
        }
        catch
        {
            gvDepartments.DataSource = null;
            gvDepartments.DataBind();
        }
    }

    // ============================================
    // PACKAGE DROPDOWN
    // ============================================

    private void LoadPackages()
    {
        try
        {
            string query = @"SELECT s.SubscriptionID, s.SportID, sp.SportName, s.PackageName, s.SubscriptionType, s.Fee,
                sp.SportName + ' - ' + s.PackageName + ' (' + s.SubscriptionType + ') - PKR ' + CAST(CAST(s.Fee AS INT) AS NVARCHAR) AS DisplayText
                FROM Subscriptions s INNER JOIN Sports sp ON s.SportID = sp.SportID
                WHERE s.Status = 1 ORDER BY sp.SportName, s.PackageName";

            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        ddlPackages.DataSource = dt;
                        ddlPackages.DataTextField = "DisplayText";
                        ddlPackages.DataValueField = "SubscriptionID";
                        ddlPackages.DataBind();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading packages: " + ex.Message, false);
        }
    }

    protected void ddlPackages_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlPackages.SelectedValue == "0")
        {
            pnlPackageInfo.Visible = false;
            return;
        }

        LoadPackageInfo();
        LoadDepartmentRepeater();
        LoadExistingShares();
    }

    private void LoadPackageInfo()
    {
        try
        {
            int subId = Convert.ToInt32(ddlPackages.SelectedValue);
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = @"SELECT s.PackageName, s.SubscriptionType, s.Fee, sp.SportName 
                                 FROM Subscriptions s INNER JOIN Sports sp ON s.SportID = sp.SportID 
                                 WHERE s.SubscriptionID = @SubscriptionID";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@SubscriptionID", subId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblPackageName.Text = reader["SportName"].ToString() + " - " + reader["PackageName"].ToString();
                            lblPackageType.Text = reader["SubscriptionType"].ToString();
                            decimal fee = Convert.ToDecimal(reader["Fee"]);
                            lblPackageFee.Text = fee.ToString("N0");
                            hfPackageFee.Value = fee.ToString();
                            hfShareMode.Value = rdoShareMode.SelectedValue;
                            pnlPackageInfo.Visible = true;
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading package info: " + ex.Message, false);
        }
    }

    // ============================================
    // SHARE MODE TOGGLE
    // ============================================

    protected void rdoShareMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        hfShareMode.Value = rdoShareMode.SelectedValue;
    }

    // ============================================
    // DEPARTMENT REPEATER (From BasicDataInfo)
    // ============================================

    private void LoadDepartmentRepeater()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(GetBasicDataConnString()))
            {
                string query = "SELECT Dept_ID AS DepartmentID, Dept_Name AS DepartmentName FROM Department ORDER BY Dept_Name";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptDepartments.DataSource = dt;
                        rptDepartments.DataBind();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading department list: " + ex.Message, false);
        }
    }

    protected void rptDepartments_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        // Placeholder for future logic if needed
    }

    // ============================================
    // LOAD EXISTING SHARES (for editing)
    // ============================================

    private void LoadExistingShares()
    {
        if (ddlPackages.SelectedValue == "0") return;

        try
        {
            int subId = Convert.ToInt32(ddlPackages.SelectedValue);
            DataTable dtShares = new DataTable();

            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = @"SELECT pds.ShareID, pds.SubscriptionID, pds.DepartmentID, 
                    ISNULL(d.Dept_Name, 'Dept #' + CAST(pds.DepartmentID AS NVARCHAR)) AS DepartmentName, 
                    pds.ShareMode, pds.ShareValue, pds.CreatedOn, pds.IsActive
                    FROM PackageDepartmentShares pds 
                    LEFT JOIN [BasicDataInfo].[dbo].[Department] d ON pds.DepartmentID = d.Dept_ID
                    WHERE pds.SubscriptionID = @SubscriptionID AND pds.IsActive = 1 ORDER BY d.Dept_Name";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@SubscriptionID", subId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dtShares);
                    }
                }
            }

            if (dtShares.Rows.Count > 0)
            {
                string mode = dtShares.Rows[0]["ShareMode"].ToString();
                rdoShareMode.SelectedValue = mode;
                hfShareMode.Value = mode;

                foreach (RepeaterItem item in rptDepartments.Items)
                {
                    CheckBox chk = (CheckBox)item.FindControl("chkDept");
                    HiddenField hf = (HiddenField)item.FindControl("hfDeptID");
                    TextBox txt = (TextBox)item.FindControl("txtShareValue");

                    if (chk == null || hf == null || txt == null) continue;

                    int deptId = Convert.ToInt32(hf.Value);

                    DataRow[] rows = dtShares.Select("DepartmentID = " + deptId);
                    if (rows.Length > 0)
                    {
                        chk.Checked = true;
                        txt.Text = Convert.ToDecimal(rows[0]["ShareValue"]).ToString("0.##");
                    }
                    else
                    {
                        chk.Checked = false;
                        txt.Text = "";
                    }
                }
            }
        }
        catch
        {
            // Fail silently if table empty
        }
    }

    // ============================================
    // SAVE SHARE ALLOCATION
    // ============================================

    protected void btnSaveShare_Click(object sender, EventArgs e)
    {
        if (ddlPackages.SelectedValue == "0")
        {
            ShowMessage("Please select a package first.", false);
            return;
        }

        int subId = Convert.ToInt32(ddlPackages.SelectedValue);
        string shareMode = rdoShareMode.SelectedValue;
        decimal packageFee = Convert.ToDecimal(hfPackageFee.Value);

        decimal totalValue = 0;
        int selectedCount = 0;

        foreach (RepeaterItem item in rptDepartments.Items)
        {
            CheckBox chk = (CheckBox)item.FindControl("chkDept");
            TextBox txt = (TextBox)item.FindControl("txtShareValue");

            if (chk == null || !chk.Checked) continue;

            selectedCount++;

            decimal val = 0;
            if (!decimal.TryParse(txt.Text.Trim(), out val) || val <= 0)
            {
                ShowMessage("Please enter a valid share value for all selected departments.", false);
                return;
            }

            totalValue += val;
        }

        if (selectedCount == 0)
        {
            ShowMessage("Please select at least one department and enter share values.", false);
            return;
        }

        if (shareMode == "Percentage")
        {
            if (Math.Abs(totalValue - 100) > 0.01m)
            {
                ShowMessage("Total percentage must equal 100%. Currently: " + totalValue.ToString("N2") + "%", false);
                return;
            }
        }
        else
        {
            if (Math.Abs(totalValue - packageFee) > 0.01m)
            {
                ShowMessage("Total amount must equal package fee (PKR " + packageFee.ToString("N2") + "). Currently: PKR " + totalValue.ToString("N2"), false);
                return;
            }
        }

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();

                using (SqlCommand cmdDel = new SqlCommand("DELETE FROM PackageDepartmentShares WHERE SubscriptionID = @SubscriptionID", con))
                {
                    cmdDel.Parameters.AddWithValue("@SubscriptionID", subId);
                    cmdDel.ExecuteNonQuery();
                }

                foreach (RepeaterItem item in rptDepartments.Items)
                {
                    CheckBox chk = (CheckBox)item.FindControl("chkDept");
                    HiddenField hf = (HiddenField)item.FindControl("hfDeptID");
                    TextBox txt = (TextBox)item.FindControl("txtShareValue");

                    if (chk == null || !chk.Checked || hf == null || txt == null) continue;

                    int deptId = Convert.ToInt32(hf.Value);
                    decimal val = Convert.ToDecimal(txt.Text.Trim());

                    string insertQuery = "INSERT INTO PackageDepartmentShares (SubscriptionID, DepartmentID, ShareMode, ShareValue, IsActive) VALUES (@SubscriptionID, @DepartmentID, @ShareMode, @ShareValue, 1)";
                    using (SqlCommand cmdIns = new SqlCommand(insertQuery, con))
                    {
                        cmdIns.Parameters.AddWithValue("@SubscriptionID", subId);
                        cmdIns.Parameters.AddWithValue("@DepartmentID", deptId);
                        cmdIns.Parameters.AddWithValue("@ShareMode", shareMode);
                        cmdIns.Parameters.AddWithValue("@ShareValue", val);
                        cmdIns.ExecuteNonQuery();
                    }
                }
            }

            ShowMessage("Share allocation saved successfully!", true);
            LoadSharesGrid();
        }
        catch (Exception ex)
        {
            ShowMessage("Error saving share allocation: " + ex.Message, false);
        }
    }

    protected void btnClearShare_Click(object sender, EventArgs e)
    {
        ddlPackages.SelectedValue = "0";
        pnlPackageInfo.Visible = false;
        lblMessage.Visible = false;
    }

    // ============================================
    // SHARES GRID
    // ============================================

    private void LoadSharesGrid()
    {
        try
        {
            string query = @"SELECT pds.ShareID, sp.SportName, s.PackageName, s.SubscriptionType, 
                    s.Fee AS PackageFee, 
                    ISNULL(d.Dept_Name, 'Dept #' + CAST(pds.DepartmentID AS NVARCHAR)) AS DepartmentName, 
                    pds.ShareMode, pds.ShareValue,
                    CASE WHEN pds.ShareMode = 'Percentage' 
                         THEN CAST(ROUND(s.Fee * pds.ShareValue / 100, 2) AS DECIMAL(18,2)) 
                         ELSE pds.ShareValue END AS ShareAmount,
                    pds.CreatedOn
                FROM PackageDepartmentShares pds
                INNER JOIN Subscriptions s ON pds.SubscriptionID = s.SubscriptionID
                INNER JOIN Sports sp ON s.SportID = sp.SportID
                LEFT JOIN [BasicDataInfo].[dbo].[Department] d ON pds.DepartmentID = d.Dept_ID
                WHERE pds.IsActive = 1 
                ORDER BY sp.SportName, s.PackageName, d.Dept_Name";

            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvShares.DataSource = dt;
                        gvShares.DataBind();
                    }
                }
            }
        }
        catch
        {
            gvShares.DataSource = null;
            gvShares.DataBind();
        }
    }

    // ============================================
    // NAVIGATION
    // ============================================

    protected void btnViewReport_Click(object sender, EventArgs e)
    {
        Response.Redirect("ReportDepartmentShares.aspx");
    }

    // ============================================
    // UTILITY
    // ============================================

    private void ShowMessage(string msg, bool isSuccess)
    {
        lblMessage.Visible = true;
        lblMessage.Text = msg;
        if (isSuccess)
        {
            lblMessage.Style["background-color"] = "#d4edda";
            lblMessage.Style["color"] = "#155724";
            lblMessage.Style["border"] = "1px solid #c3e6cb";
        }
        else
        {
            lblMessage.Style["background-color"] = "#f8d7da";
            lblMessage.Style["color"] = "#721c24";
            lblMessage.Style["border"] = "1px solid #f5c6cb";
        }
    }
}
