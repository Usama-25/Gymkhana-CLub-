using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ManageMemberCard : Page
{
    private string connectionString
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
            // Initial load logic if needed
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        string searchText = txtSearch.Text.Trim();
        if (string.IsNullOrEmpty(searchText))
        {
            ShowMessage("error", "Please enter a Member ID or Member Number to search.");
            return;
        }

        LoadMemberCardData(searchText);
    }

    private void LoadMemberCardData(string searchText)
    {
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            using (SqlCommand cmd = new SqlCommand("usp_GetMemberCardData", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@SearchText", SqlDbType.NVarChar, 100).Value = searchText;
                conn.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        hdnMemberID.Value = reader["MemberID"].ToString();
                        lblMemberName.Text = reader["MemberName"].ToString();
                        lblMemberNo.Text = reader["MemberNo"].ToString();

                        txtPrintName.Text = reader["PrintName"].ToString();
                        txtCardIssueDate.Text = FormatDate(reader["CardIssueDate"]);
                        txtCardExpiryDate.Text = FormatDate(reader["CardExpiryDate"]);
                        txtRFIDLabel.Text = reader["RFID"].ToString();

                        string status = reader["IsCardActive"].ToString();
                        if (ddlCardStatus.Items.FindByValue(status) != null)
                        {
                            ddlCardStatus.SelectedValue = status;
                        }

                        pnlCardDetails.Visible = true;
                        pnlMessage.Visible = false;
                    }
                    else
                    {
                        pnlCardDetails.Visible = false;
                        ShowMessage("error", "No member found with the provided ID or Number.");
                    }
                }
            }
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        int memberId = 0;
        if (!int.TryParse(hdnMemberID.Value, out memberId) || memberId <= 0)
        {
            ShowMessage("error", "Invalid Member ID. Please search and select a member again.");
            return;
        }

        SaveCardDetails(memberId);
    }

    private void SaveCardDetails(int memberId)
    {
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            conn.Open();

            string currentRFID = "";
            int currentIsCardActive = 0;

            using (SqlCommand checkCmd = new SqlCommand("usp_CheckMemberCardStatus", conn))
            {
                checkCmd.CommandType = CommandType.StoredProcedure;
                checkCmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                using (SqlDataReader reader = checkCmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        currentRFID = reader["RFID"] != DBNull.Value ? reader["RFID"].ToString() : "";
                        currentIsCardActive = reader["IsCardActive"] != DBNull.Value ? Convert.ToInt32(reader["IsCardActive"]) : 0;
                    }
                }
            }

            string newRFID = txtRFIDLabel.Text.Trim();

            if (!string.IsNullOrEmpty(currentRFID) && currentRFID != newRFID)
            {
                if (currentIsCardActive != 2) // 2 = Blocked
                {
                    ShowMessage("error", "Please block the previous card first before issuing a new RFID.");
                    return;
                }
            }

            using (SqlCommand cmd = new SqlCommand("usp_UpdateMemberCardDetails", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                cmd.Parameters.Add("@PrintName", SqlDbType.NVarChar, 200).Value = GetValue(txtPrintName.Text);
                cmd.Parameters.Add("@CardIssueDate", SqlDbType.DateTime).Value = GetDateValue(txtCardIssueDate.Text);
                cmd.Parameters.Add("@CardExpiryDate", SqlDbType.DateTime).Value = GetDateValue(txtCardExpiryDate.Text);
                cmd.Parameters.Add("@IsCardActive", SqlDbType.Int).Value = GetIntValue(ddlCardStatus.SelectedValue);
                cmd.Parameters.Add("@RFID", SqlDbType.NVarChar, 50).Value = GetValue(txtRFIDLabel.Text);

                int rowsAffected = cmd.ExecuteNonQuery();

                if (rowsAffected > 0)
                {
                    ShowMessage("success", "Card details updated successfully for " + lblMemberName.Text);
                }
                else
                {
                    ShowMessage("error", "Failed to update card details. Member might not exist.");
                }
            }
        }
    }

    private void ShowMessage(string type, string message)
    {
        pnlMessage.Visible = true;
        lblMessage.Text = message;
        divMessage.Attributes["class"] = "alert alert-" + type;
    }

    private string FormatDate(object date)
    {
        if (date == null || date == DBNull.Value) return "";
        return Convert.ToDateTime(date).ToString("yyyy-MM-dd");
    }

    private object GetValue(string value)
    {
        return string.IsNullOrEmpty(value) ? DBNull.Value : (object)value;
    }

    private object GetDateValue(string dateString)
    {
        if (string.IsNullOrEmpty(dateString)) return DBNull.Value;
        DateTime date;
        return DateTime.TryParse(dateString, out date) ? (object)date : DBNull.Value;
    }

    private object GetIntValue(string intString)
    {
        if (string.IsNullOrEmpty(intString)) return DBNull.Value;
        int value;
        return int.TryParse(intString, out value) ? (object)value : DBNull.Value;
    }
}
