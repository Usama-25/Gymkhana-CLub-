using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Collections.Generic;

public partial class ReportDepartmentShares : System.Web.UI.Page
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
            LoadSports();
            LoadDepartments();
            LoadPackages();
            LoadReport();
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
            System.Diagnostics.Debug.WriteLine("Table check error: " + ex.Message);
        }
    }

    // ============================================
    // LOAD FILTER DROPDOWNS
    // ============================================

    private void LoadSports()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = "SELECT SportID, SportName, Description, Status FROM Sports ORDER BY SportName";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        DataView dv = dt.DefaultView;
                        if (Session["UserRole"] != null && Session["UserRole"].ToString() == "Operator")
                        {
                            List<int> allowedSports = Session["AllowedSports"] as List<int>;
                            if (allowedSports != null && allowedSports.Count > 0)
                            {
                                dv.RowFilter = "Status = True AND SportID IN (" + string.Join(",", allowedSports) + ")";
                            }
                            else
                            {
                                dv.RowFilter = "SportID = -1";
                            }
                        }
                        else
                        {
                            dv.RowFilter = "Status = True";
                        }

                        ddlSports.DataSource = dv;
                        ddlSports.DataTextField = "SportName";
                        ddlSports.DataValueField = "SportID";
                        ddlSports.DataBind();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading sports: " + ex.Message, false);
        }
    }

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
                        ddlDepartments.DataSource = dt;
                        ddlDepartments.DataTextField = "DepartmentName";
                        ddlDepartments.DataValueField = "DepartmentID";
                        ddlDepartments.DataBind();
                    }
                }
            }
        }
        catch
        {
            // Ignore if connection fails
        }
    }

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

    // ============================================
    // GENERATE REPORT
    // ============================================

    protected void btnGenerate_Click(object sender, EventArgs e)
    {
        gvReport.PageIndex = 0;
        LoadReport();
    }

    protected void gvReport_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvReport.PageIndex = e.NewPageIndex;
        LoadReport();
    }

    private void LoadReport()
    {
        lblMessage.Visible = false;
        try
        {
            int sportId = Convert.ToInt32(ddlSports.SelectedValue);
            int deptId = Convert.ToInt32(ddlDepartments.SelectedValue);
            int subId = Convert.ToInt32(ddlPackages.SelectedValue);

            string query = @"SELECT pds.ShareID, s.SubscriptionID, sp.SportID, sp.SportName, s.PackageName, 
                    s.SubscriptionType, s.Fee AS PackageFee, d.Dept_ID AS DepartmentID, 
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
                    AND (@SportID = 0 OR sp.SportID = @SportID)
                    AND (@DepartmentID = 0 OR d.Dept_ID = @DepartmentID OR pds.DepartmentID = @DepartmentID)
                    AND (@SubscriptionID = 0 OR s.SubscriptionID = @SubscriptionID)
                ORDER BY sp.SportName, s.PackageName, d.Dept_Name";

            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@SportID", sportId);
                    cmd.Parameters.AddWithValue("@DepartmentID", deptId);
                    cmd.Parameters.AddWithValue("@SubscriptionID", subId);

                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);

                        FilterDataTableByAllowedSports(dt);

                        gvReport.DataSource = dt;
                        gvReport.DataBind();

                        btnPrint.Visible = (dt.Rows.Count > 0);

                        if (dt.Rows.Count > 0)
                        {
                            pnlSummary.Visible = true;

                            DataView dvPkg = new DataView(dt);
                            DataTable dtDistinctPkg = dvPkg.ToTable(true, "SubscriptionID");
                            lblTotalPackages.Text = dtDistinctPkg.Rows.Count.ToString();

                            DataView dvDept = new DataView(dt);
                            DataTable dtDistinctDept = dvDept.ToTable(true, "DepartmentID");
                            lblTotalDepartments.Text = dtDistinctDept.Rows.Count.ToString();

                            decimal totalAmt = 0;
                            foreach (DataRow row in dt.Rows)
                            {
                                if (row["ShareAmount"] != DBNull.Value)
                                    totalAmt += Convert.ToDecimal(row["ShareAmount"]);
                            }
                            lblTotalAmount.Text = totalAmt.ToString("N0");

                            lblTotalShares.Text = dt.Rows.Count.ToString();
                        }
                        else
                        {
                            pnlSummary.Visible = false;
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            btnPrint.Visible = false;
            pnlSummary.Visible = false;
            ShowMessage("Error generating report: " + ex.Message, false);
        }
    }

    private void FilterDataTableByAllowedSports(DataTable dt)
    {
        if (dt == null || dt.Rows.Count == 0) return;

        if (Session["UserRole"] != null && Session["UserRole"].ToString() == "Operator")
        {
            List<int> allowedSports = Session["AllowedSports"] as List<int>;
            if (allowedSports != null && allowedSports.Count > 0)
            {
                for (int i = dt.Rows.Count - 1; i >= 0; i--)
                {
                    if (dt.Columns.Contains("SportID") && dt.Rows[i]["SportID"] != DBNull.Value)
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
    }

    protected void btnBackToSetup_Click(object sender, EventArgs e)
    {
        Response.Redirect("DepartmentWiseShare.aspx");
    }

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
