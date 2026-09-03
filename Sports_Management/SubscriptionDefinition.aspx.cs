using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Collections.Generic;

public partial class SubscriptionDefinition : System.Web.UI.Page
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
        if (!IsPostBack)
        {
            LoadSportsDropdown();
            LoadSubscriptions();
            LoadBankCards();
            LoadLockers();
        }
    }

    private void LoadSportsDropdown()
    {
        try
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection con = new SqlConnection(GetBasicDataConnString()))
                {
                    string query = "SELECT Dept_ID, Dept_Name FROM Department ORDER BY Dept_Name";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }
                    }
                }
            }
            catch
            {
                // Fallback cross-database query
                using (SqlConnection con = new SqlConnection(connString))
                {
                    string query = "SELECT Dept_ID, Dept_Name FROM BasicDataInfo.dbo.Department ORDER BY Dept_Name";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }
                    }
                }
            }

            DataView dv = dt.DefaultView;
            if (Session["UserRole"] != null && Session["UserRole"].ToString() == "Operator")
            {
                List<int> allowedDepts = Session["AllowedDepartments"] as List<int>;
                if (allowedDepts != null && allowedDepts.Count > 0)
                {
                    dv.RowFilter = "Dept_ID IN (" + string.Join(",", allowedDepts) + ")";
                }
                else
                {
                    dv.RowFilter = "Dept_ID = -1";
                }
            }

            ddlSports.DataSource = dv;
            ddlSports.DataTextField = "Dept_Name";
            ddlSports.DataValueField = "Dept_ID";
            ddlSports.DataBind();

            ddlSports.Items.Insert(0, new ListItem("-- Select Department --", "0"));
        }
        catch (Exception ex)
        {
            ddlSports.Items.Clear();
            ddlSports.Items.Insert(0, new ListItem("-- Select Department --", "0"));
            ShowMessage("Error loading departments: " + ex.Message, false);
        }
    }

    private void LoadSubscriptions()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                DataTable dt = new DataTable();
                try
                {
                    string query = @"
                        SELECT 
                            s.SubscriptionID, 
                            s.SportID, 
                            sp.SportName, 
                            sp.SubDeptID AS DepartmentID,
                            ISNULL(d.Dept_Name, sp.SportName) AS DepartmentName,
                            s.PackageName, 
                            s.SubscriptionType, 
                            s.Fee, 
                            ISNULL(s.GSTPercentage, 16.00) AS GSTPercentage,
                            s.Status,
                            s.ItemCode,
                            ISNULL(s.IsEditable, 1) AS IsEditable,
                            STUFF((
                                SELECT ',' + CAST(sdp.PolicyID AS VARCHAR(10))
                                FROM SubscriptionDiscountPolicies sdp
                                WHERE sdp.SubscriptionID = s.SubscriptionID
                                FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') AS PolicyIDs
                        FROM Subscriptions s
                        INNER JOIN Sports sp ON s.SportID = sp.SportID
                        LEFT JOIN [BasicDataInfo].[dbo].[Department] d ON sp.SubDeptID = d.Dept_ID
                        WHERE s.SubscriptionType = 'Daily'
                        ORDER BY ISNULL(d.Dept_Name, sp.SportName), s.PackageName";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }
                    }
                }
                catch
                {
                    // Fallback to stored procedure
                    using (SqlCommand cmd = new SqlCommand("sp_GetSubscriptions", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }
                    }
                }

                DataView dv = dt.DefaultView;
                string filter = "SubscriptionType = 'Daily'";

                if (ddlSports.SelectedIndex > 0)
                {
                    if (dt.Columns.Contains("DepartmentID"))
                    {
                        filter += " AND DepartmentID = " + ddlSports.SelectedValue;
                    }
                    else
                    {
                        filter += " AND SportID = " + ddlSports.SelectedValue;
                    }
                }
                else if (Session["UserRole"] != null && Session["UserRole"].ToString() == "Operator")
                {
                    List<int> allowedDepts = Session["AllowedDepartments"] as List<int>;
                    List<int> allowedSports = Session["AllowedSports"] as List<int>;

                    if (allowedDepts != null && allowedDepts.Count > 0 && dt.Columns.Contains("DepartmentID"))
                    {
                        filter += " AND DepartmentID IN (" + string.Join(",", allowedDepts) + ")";
                    }
                    else if (allowedSports != null && allowedSports.Count > 0)
                    {
                        filter += " AND SportID IN (" + string.Join(",", allowedSports) + ")";
                    }
                    else
                    {
                        filter += " AND SportID = -1";
                    }
                }

                dv.RowFilter = filter;
                gvSubscriptions.DataSource = dv;
                gvSubscriptions.DataBind();
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading subscriptions: " + ex.Message, false);
        }
    }

    protected void ddlSports_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadSubscriptions();
    }

    private int GetOrCreateSportIDForDepartment(SqlConnection con, int deptId, string deptName)
    {
        string queryFind = "SELECT TOP 1 SportID FROM Sports WHERE SubDeptID = @DeptID";
        using (SqlCommand cmd = new SqlCommand(queryFind, con))
        {
            cmd.Parameters.AddWithValue("@DeptID", deptId);
            object obj = cmd.ExecuteScalar();
            if (obj != null && obj != DBNull.Value)
            {
                return Convert.ToInt32(obj);
            }
        }

        // Try match by name if SubDeptID was not set
        string queryFindByName = "SELECT TOP 1 SportID FROM Sports WHERE SportName = @DeptName";
        using (SqlCommand cmd = new SqlCommand(queryFindByName, con))
        {
            cmd.Parameters.AddWithValue("@DeptName", deptName);
            object obj = cmd.ExecuteScalar();
            if (obj != null && obj != DBNull.Value)
            {
                int matchedId = Convert.ToInt32(obj);
                using (SqlCommand cmdUp = new SqlCommand("UPDATE Sports SET SubDeptID = @DeptID WHERE SportID = @SportID", con))
                {
                    cmdUp.Parameters.AddWithValue("@DeptID", deptId);
                    cmdUp.Parameters.AddWithValue("@SportID", matchedId);
                    cmdUp.ExecuteNonQuery();
                }
                return matchedId;
            }
        }

        // Otherwise create sport linked with this department
        string queryIns = "INSERT INTO Sports (SportName, Description, Status, SubDeptID) VALUES (@SportName, @Description, 1, @DeptID); SELECT SCOPE_IDENTITY();";
        using (SqlCommand cmd = new SqlCommand(queryIns, con))
        {
            cmd.Parameters.AddWithValue("@SportName", deptName);
            cmd.Parameters.AddWithValue("@Description", deptName + " Facility");
            cmd.Parameters.AddWithValue("@DeptID", deptId);
            return Convert.ToInt32(cmd.ExecuteScalar());
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (ddlSports.SelectedValue == "0" || string.IsNullOrWhiteSpace(txtPackageName.Text) || string.IsNullOrWhiteSpace(txtFee.Text))
        {
            ShowMessage("Please fill in all required fields and select a department.", false);
            return;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                int deptId = Convert.ToInt32(ddlSports.SelectedValue);
                string deptName = ddlSports.SelectedItem.Text;
                int resolvedSportId = GetOrCreateSportIDForDepartment(con, deptId, deptName);

                bool isEdit = !string.IsNullOrEmpty(hfSubscriptionID.Value);
                string spName = isEdit ? "sp_UpdateSubscription" : "sp_InsertSubscription";

                using (SqlCommand cmd = new SqlCommand(spName, con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    if (isEdit)
                    {
                        cmd.Parameters.AddWithValue("@SubscriptionID", hfSubscriptionID.Value);
                    }

                    cmd.Parameters.AddWithValue("@SportID", resolvedSportId);
                    cmd.Parameters.AddWithValue("@PackageName", txtPackageName.Text.Trim());
                    cmd.Parameters.AddWithValue("@SubscriptionType", "Daily");
                    cmd.Parameters.AddWithValue("@Fee", Convert.ToDecimal(txtFee.Text));
                    cmd.Parameters.AddWithValue("@Status", chkStatus.Checked);
                    cmd.Parameters.AddWithValue("@IsEditable", rdoRateMode.SelectedValue == "1");

                    cmd.Parameters.AddWithValue("@PolicyIDs", "");

                    cmd.ExecuteNonQuery();
                }
            }

            ShowMessage("Daily package saved successfully!", true);
            ClearForm();
            LoadSubscriptions();
        }
        catch (Exception ex)
        {
            ShowMessage("Error saving subscription: " + ex.Message, false);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ClearForm();
        lblMessage.Visible = false;
    }

    private void ClearForm()
    {
        hfSubscriptionID.Value = "";
        txtPackageName.Text = "";
        txtFee.Text = "";
        ddlSports.SelectedIndex = 0;
        if (ddlSubType.Items.FindByValue("Daily") != null)
        {
            ddlSubType.SelectedValue = "Daily";
        }
        rdoRateMode.SelectedValue = "1";
        chkStatus.Checked = true;
        btnSave.Text = "Save Package";
        btnCancel.Visible = false;
    }

    protected void gvSubscriptions_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "EditSub")
        {
            int index = Convert.ToInt32(e.CommandArgument);
            GridViewRow row = gvSubscriptions.Rows[index];

            hfSubscriptionID.Value = gvSubscriptions.DataKeys[index].Values["SubscriptionID"].ToString();

            object deptIdObj = gvSubscriptions.DataKeys[index].Values["DepartmentID"];
            string deptId = deptIdObj != null && deptIdObj != DBNull.Value ? deptIdObj.ToString() : "";

            if (!string.IsNullOrEmpty(deptId) && ddlSports.Items.FindByValue(deptId) != null)
            {
                ddlSports.SelectedValue = deptId;
            }
            else
            {
                string sportId = gvSubscriptions.DataKeys[index].Values["SportID"].ToString();
                if (ddlSports.Items.FindByValue(sportId) != null)
                {
                    ddlSports.SelectedValue = sportId;
                }
                else
                {
                    ddlSports.SelectedIndex = 0;
                }
            }

            txtPackageName.Text = row.Cells[3].Text;
            if (ddlSubType.Items.FindByValue("Daily") != null)
            {
                ddlSubType.SelectedValue = "Daily";
            }

            // Clean fee string (remove commas/formatting)
            string feeText = row.Cells[5].Text.Replace(",", "").Trim();
            txtFee.Text = feeText;

            string statusHtml = row.Cells[6].Text;
            chkStatus.Checked = statusHtml.Contains("Active") && !statusHtml.Contains("Inactive");

            object isEditableObj = gvSubscriptions.DataKeys[index].Values["IsEditable"];
            bool isEditable = isEditableObj != null && isEditableObj != DBNull.Value ? Convert.ToBoolean(isEditableObj) : true;
            rdoRateMode.SelectedValue = isEditable ? "1" : "0";

            btnSave.Text = "Update Package";
            btnCancel.Visible = true;
            lblMessage.Visible = false;
        }
        else if (e.CommandName == "DeleteSub")
        {
            int index = Convert.ToInt32(e.CommandArgument);
            int subId = Convert.ToInt32(gvSubscriptions.DataKeys[index].Values["SubscriptionID"]);
            DeleteSubscription(subId);
        }
    }

    private void DeleteSubscription(int subscriptionId)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand(@"
                    DELETE FROM SubscriptionDiscountPolicies WHERE SubscriptionID = @SubID;
                    DELETE FROM PackageDepartmentShares WHERE SubscriptionID = @SubID;
                    DELETE FROM POSTransactions WHERE SubscriptionID = @SubID;
                    DELETE FROM MemberSubscriptions WHERE SubscriptionID = @SubID;
                    DELETE FROM Subscriptions WHERE SubscriptionID = @SubID;
                ", con))
                {
                    cmd.Parameters.AddWithValue("@SubID", subscriptionId);
                    cmd.ExecuteNonQuery();
                }
            }
            ShowMessage("Subscription package deleted successfully!", true);
            ClearForm();
            LoadSubscriptions();
        }
        catch (Exception ex)
        {
            ShowMessage("Error deleting subscription: " + ex.Message, false);
        }
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

    #region Bank Cards Logic

    private void LoadBankCards()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetBankCards", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IncludeInactive", 1);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvBankCards.DataSource = dt;
                        gvBankCards.DataBind();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading bank cards: " + ex.Message, false);
        }
    }

    protected void btnSaveBank_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtBankName.Text) || string.IsNullOrWhiteSpace(txtBankDiscount.Text))
        {
            ShowMessage("Please enter Bank Name and Discount Percentage.", false);
            return;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                SqlCommand cmd;
                if (string.IsNullOrEmpty(hfBankID.Value))
                {
                    cmd = new SqlCommand("sp_InsertBankCard", con);
                }
                else
                {
                    cmd = new SqlCommand("sp_UpdateBankCard", con);
                    cmd.Parameters.AddWithValue("@BankID", hfBankID.Value);
                }

                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@BankName", txtBankName.Text.Trim());
                cmd.Parameters.AddWithValue("@DiscountPercentage", Convert.ToDecimal(txtBankDiscount.Text));
                cmd.Parameters.AddWithValue("@IsActive", chkBankActive.Checked);

                con.Open();
                cmd.ExecuteNonQuery();

                ShowMessage(string.IsNullOrEmpty(hfBankID.Value) ? "Bank Card saved successfully!" : "Bank Card updated successfully!", true);
                ClearBankForm();
                LoadBankCards();
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error saving Bank Card: " + ex.Message, false);
        }
    }

    protected void btnCancelBank_Click(object sender, EventArgs e)
    {
        ClearBankForm();
        lblMessage.Visible = false;
    }

    private void ClearBankForm()
    {
        hfBankID.Value = "";
        txtBankName.Text = "";
        txtBankDiscount.Text = "";
        chkBankActive.Checked = true;
        btnSaveBank.Text = "Save Bank";
        btnCancelBank.Visible = false;
    }

    protected void gvBankCards_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "EditBank")
        {
            int index = Convert.ToInt32(e.CommandArgument);
            GridViewRow row = gvBankCards.Rows[index];

            hfBankID.Value = gvBankCards.DataKeys[index].Values["BankID"].ToString();
            txtBankName.Text = row.Cells[1].Text;
            txtBankDiscount.Text = row.Cells[2].Text.Replace(",", "").Trim();

            string statusHtml = row.Cells[3].Text;
            chkBankActive.Checked = statusHtml.Contains("Active") && !statusHtml.Contains("Inactive");

            btnSaveBank.Text = "Update Bank";
            btnCancelBank.Visible = true;
            lblMessage.Visible = false;
        }
    }

    #endregion

    #region Lockers Logic

    private void LoadLockers()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetLockers", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IncludeInactive", 1);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvLockers.DataSource = dt;
                        gvLockers.DataBind();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading lockers: " + ex.Message, false);
        }
    }

    protected void btnSaveLocker_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtLockerName.Text) || string.IsNullOrWhiteSpace(txtLockerFee.Text))
        {
            ShowMessage("Please enter Locker Name and Fee.", false);
            return;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                SqlCommand cmd;
                if (string.IsNullOrEmpty(hfLockerID.Value))
                {
                    cmd = new SqlCommand("sp_InsertLocker", con);
                }
                else
                {
                    cmd = new SqlCommand("sp_UpdateLocker", con);
                    cmd.Parameters.AddWithValue("@LockerID", hfLockerID.Value);
                }

                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@LockerName", txtLockerName.Text.Trim());
                cmd.Parameters.AddWithValue("@Fee", Convert.ToDecimal(txtLockerFee.Text));
                cmd.Parameters.AddWithValue("@IsActive", chkLockerActive.Checked);

                con.Open();
                cmd.ExecuteNonQuery();

                ShowMessage(string.IsNullOrEmpty(hfLockerID.Value) ? "Locker saved successfully!" : "Locker updated successfully!", true);
                ClearLockerForm();
                LoadLockers();
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error saving Locker: " + ex.Message, false);
        }
    }

    protected void btnCancelLocker_Click(object sender, EventArgs e)
    {
        ClearLockerForm();
        lblMessage.Visible = false;
    }

    private void ClearLockerForm()
    {
        hfLockerID.Value = "";
        txtLockerName.Text = "";
        txtLockerFee.Text = "";
        chkLockerActive.Checked = true;
        btnSaveLocker.Text = "Save Locker";
        btnCancelLocker.Visible = false;
    }

    protected void gvLockers_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "EditLocker")
        {
            int index = Convert.ToInt32(e.CommandArgument);
            GridViewRow row = gvLockers.Rows[index];

            hfLockerID.Value = gvLockers.DataKeys[index].Values["LockerID"].ToString();
            txtLockerName.Text = row.Cells[1].Text;
            txtLockerFee.Text = row.Cells[2].Text.Replace(",", "").Trim();

            string statusHtml = row.Cells[3].Text;
            chkLockerActive.Checked = statusHtml.Contains("Active") && !statusHtml.Contains("Inactive");

            btnSaveLocker.Text = "Update Locker";
            btnCancelLocker.Visible = true;
            lblMessage.Visible = false;
        }
    }

    #endregion
}
