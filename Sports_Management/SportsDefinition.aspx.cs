using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Collections.Generic;
using System.Web.UI.WebControls;

public partial class SportsDefinition : System.Web.UI.Page
{
    string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadDiscountPolicies();
            LoadSports();
        }
    }

    private void LoadDiscountPolicies()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = "SELECT PolicyID, PolicyName FROM DiscountPolicies WHERE IsActive = 1 ORDER BY PolicyName";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        cblDiscountPolicies.DataSource = dt;
                        cblDiscountPolicies.DataTextField = "PolicyName";
                        cblDiscountPolicies.DataValueField = "PolicyID";
                        cblDiscountPolicies.DataBind();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // Log error
        }
    }

    private void LoadSports()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetSports", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvSports.DataSource = dt;
                        gvSports.DataBind();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading sports: " + ex.Message, false);
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtSportName.Text))
        {
            ShowMessage("Sport Name is required.", false);
            return;
        }

        try
        {
            int? subDeptId = null;
            if (!string.IsNullOrWhiteSpace(txtSubDeptID.Text))
            {
                int temp;
                if (int.TryParse(txtSubDeptID.Text.Trim(), out temp))
                {
                    subDeptId = temp;
                }
            }

            decimal monthlyFee = 0;
            decimal.TryParse(txtMonthlyRate.Text.Trim(), out monthlyFee);

            decimal continuousFee = 0;
            decimal.TryParse(txtContinuousRate.Text.Trim(), out continuousFee);

            List<string> selectedPolicyIds = new List<string>();
            foreach (ListItem item in cblDiscountPolicies.Items)
            {
                if (item.Selected)
                {
                    selectedPolicyIds.Add(item.Value);
                }
            }
            string policyIDsStr = selectedPolicyIds.Count > 0 ? string.Join(",", selectedPolicyIds) : null;

            using (SqlConnection con = new SqlConnection(connString))
            {
                bool isEdit = !string.IsNullOrEmpty(hfSportID.Value);
                string spName = isEdit ? "sp_UpdateSport" : "sp_InsertSport";

                using (SqlCommand cmd = new SqlCommand(spName, con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    if (isEdit)
                    {
                        cmd.Parameters.AddWithValue("@SportID", Convert.ToInt32(hfSportID.Value));
                    }
                    cmd.Parameters.AddWithValue("@SportName", txtSportName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Description", txtDescription.Text.Trim());
                    cmd.Parameters.AddWithValue("@Status", chkStatus.Checked);
                    cmd.Parameters.AddWithValue("@SubDeptID", (object)subDeptId ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@MonthlyFee", monthlyFee);
                    cmd.Parameters.AddWithValue("@ContinuousFee", continuousFee);
                    cmd.Parameters.AddWithValue("@PolicyIDs", (object)policyIDsStr ?? DBNull.Value);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            bool editMode = !string.IsNullOrEmpty(hfSportID.Value);
            ShowMessage(editMode ? "Sport updated successfully!" : "Sport saved successfully!", true);
            ClearForm();
            LoadSports();
        }
        catch (Exception ex)
        {
            ShowMessage("Error saving sport: " + ex.Message, false);
        }
    }

    protected void gvSports_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "EditSport")
        {
            int sportId = Convert.ToInt32(e.CommandArgument);
            LoadSportForEdit(sportId);
        }
    }

    private void LoadSportForEdit(int sportId)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = "SELECT SportName, Description, Status, SubDeptID, ISNULL(MonthlyFee, 0) AS MonthlyFee, ISNULL(ContinuousFee, 0) AS ContinuousFee, ISNULL(PolicyIDs, CAST(PolicyID AS NVARCHAR)) AS PolicyIDs FROM Sports WHERE SportID = @SportID";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@SportID", sportId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            hfSportID.Value = sportId.ToString();
                            txtSportName.Text = reader["SportName"].ToString();
                            txtSubDeptID.Text = reader["SubDeptID"] != DBNull.Value ? reader["SubDeptID"].ToString() : "";
                            txtMonthlyRate.Text = Convert.ToDecimal(reader["MonthlyFee"]).ToString("0.00");
                            txtContinuousRate.Text = Convert.ToDecimal(reader["ContinuousFee"]).ToString("0.00");

                            string polIDs = reader["PolicyIDs"] != DBNull.Value ? reader["PolicyIDs"].ToString() : "";
                            List<string> pList = new List<string>(polIDs.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries));
                            foreach (ListItem item in cblDiscountPolicies.Items)
                            {
                                item.Selected = pList.Contains(item.Value);
                            }

                            txtDescription.Text = reader["Description"].ToString();
                            chkStatus.Checked = Convert.ToBoolean(reader["Status"]);

                            litFormTitle.Text = "Edit Sport: " + txtSportName.Text;
                            btnSave.Text = "Update Sport";
                            btnCancel.Visible = true;
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading sport for edit: " + ex.Message, false);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ClearForm();
        lblMessage.Visible = false;
    }

    private void ClearForm()
    {
        hfSportID.Value = "";
        txtSportName.Text = "";
        txtSubDeptID.Text = "";
        txtMonthlyRate.Text = "";
        txtContinuousRate.Text = "";
        foreach (ListItem item in cblDiscountPolicies.Items)
        {
            item.Selected = false;
        }
        txtDescription.Text = "";
        chkStatus.Checked = true;

        litFormTitle.Text = "Add New Sport";
        btnSave.Text = "Save Sport";
        btnCancel.Visible = false;
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
