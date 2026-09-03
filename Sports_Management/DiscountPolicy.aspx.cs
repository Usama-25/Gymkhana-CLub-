using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Collections.Generic;

public partial class DiscountPolicy : System.Web.UI.Page
{
    string connString = ConfigurationManager.ConnectionStrings["SportsConnString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadPolicies();
        }
    }

    private void LoadPolicies()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetDiscountPolicies", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IncludeInactive", 1);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvPolicies.DataSource = dt;
                        gvPolicies.DataBind();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading discount policies: " + ex.Message, false);
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtPolicyName.Text))
        {
            ShowMessage("Please enter Policy Name.", false);
            return;
        }

        decimal discountPercentage = 0;
        if (!decimal.TryParse(txtDiscountPercentage.Text.Trim(), out discountPercentage))
        {
            ShowMessage("Please enter a valid Discount Percentage.", false);
            return;
        }

        object minAge = DBNull.Value;
        if (!string.IsNullOrWhiteSpace(txtMinAge.Text))
        {
            int ageVal;
            if (int.TryParse(txtMinAge.Text.Trim(), out ageVal)) minAge = ageVal;
        }

        object minMembershipYears = DBNull.Value;
        if (!string.IsNullOrWhiteSpace(txtMinMembershipYears.Text))
        {
            int yearsVal;
            if (int.TryParse(txtMinMembershipYears.Text.Trim(), out yearsVal)) minMembershipYears = yearsVal;
        }

        try
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                SqlCommand cmd;
                bool isEdit = !string.IsNullOrEmpty(hfPolicyID.Value);

                if (isEdit)
                {
                    cmd = new SqlCommand("sp_UpdateDiscountPolicy", con);
                    cmd.Parameters.AddWithValue("@PolicyID", Convert.ToInt32(hfPolicyID.Value));
                }
                else
                {
                    cmd = new SqlCommand("sp_InsertDiscountPolicy", con);
                }

                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@PolicyName", txtPolicyName.Text.Trim());
                cmd.Parameters.AddWithValue("@MinAge", minAge);
                cmd.Parameters.AddWithValue("@MinMembershipYears", minMembershipYears);
                cmd.Parameters.AddWithValue("@IsChild", chkIsChild.Checked);
                cmd.Parameters.AddWithValue("@ConditionOperator", ddlConditionOperator.SelectedValue);
                cmd.Parameters.AddWithValue("@DiscountPercentage", discountPercentage);
                cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);

                con.Open();
                cmd.ExecuteNonQuery();

                ShowMessage(isEdit ? "Discount policy updated successfully!" : "Discount policy saved successfully!", true);
                ClearForm();
                LoadPolicies();
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error saving discount policy: " + ex.Message, false);
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ClearForm();
        lblMessage.Visible = false;
    }

    private void ClearForm()
    {
        hfPolicyID.Value = "";
        txtPolicyName.Text = "";
        txtDiscountPercentage.Text = "";
        txtMinAge.Text = "";
        txtMinMembershipYears.Text = "";
        chkIsChild.Checked = false;
        ddlConditionOperator.SelectedValue = "OR";
        chkIsActive.Checked = true;
        btnSave.Text = "Save Policy";
        btnCancel.Visible = false;
        litFormTitle.Text = "Add / Edit Discount Policy";
    }

    protected void gvPolicies_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "EditPolicy")
        {
            int index = Convert.ToInt32(e.CommandArgument);
            int policyId = Convert.ToInt32(gvPolicies.DataKeys[index].Value);

            try
            {
                using (SqlConnection con = new SqlConnection(connString))
                {
                    using (SqlCommand cmd = new SqlCommand("SELECT * FROM DiscountPolicies WHERE PolicyID = @PolicyID", con))
                    {
                        cmd.Parameters.AddWithValue("@PolicyID", policyId);
                        con.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                hfPolicyID.Value = reader["PolicyID"].ToString();
                                txtPolicyName.Text = reader["PolicyName"].ToString();
                                txtDiscountPercentage.Text = Convert.ToDecimal(reader["DiscountPercentage"]).ToString("0.##");
                                
                                txtMinAge.Text = reader["MinAge"] != DBNull.Value ? reader["MinAge"].ToString() : "";
                                txtMinMembershipYears.Text = reader["MinMembershipYears"] != DBNull.Value ? reader["MinMembershipYears"].ToString() : "";
                                chkIsChild.Checked = reader["IsChild"] != DBNull.Value && Convert.ToBoolean(reader["IsChild"]);
                                
                                string condOp = reader["ConditionOperator"] != DBNull.Value ? reader["ConditionOperator"].ToString().ToUpper() : "OR";
                                if (ddlConditionOperator.Items.FindByValue(condOp) != null)
                                {
                                    ddlConditionOperator.SelectedValue = condOp;
                                }

                                chkIsActive.Checked = reader["IsActive"] != DBNull.Value && Convert.ToBoolean(reader["IsActive"]);

                                btnSave.Text = "Update Policy";
                                btnCancel.Visible = true;
                                litFormTitle.Text = "Edit Discount Policy #" + hfPolicyID.Value;
                                lblMessage.Visible = false;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error fetching policy details: " + ex.Message, false);
            }
        }
    }

    protected string GetConditionSummary(object minAgeObj, object minMemberYearsObj, object isChildObj, object condOpObj)
    {
        List<string> conditions = new List<string>();

        if (minAgeObj != DBNull.Value && minAgeObj != null)
        {
            conditions.Add("Age >= " + minAgeObj.ToString());
        }

        if (minMemberYearsObj != DBNull.Value && minMemberYearsObj != null)
        {
            conditions.Add("Membership >= " + minMemberYearsObj.ToString() + " Yrs");
        }

        if (isChildObj != DBNull.Value && isChildObj != null && Convert.ToBoolean(isChildObj))
        {
            conditions.Add("Child Only");
        }

        if (conditions.Count == 0) return "All Members";

        string op = condOpObj != DBNull.Value && condOpObj != null ? condOpObj.ToString() : "OR";
        return string.Join(" " + op + " ", conditions);
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
