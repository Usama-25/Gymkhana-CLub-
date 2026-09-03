using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Form_cell.Applicant_Form
{
    public partial class RFID : System.Web.UI.Page
    {
        private string strConn
        {
            get
            {
                var s = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
                return s != null ? s.ConnectionString : "";
            }
        }
        
        private int CurrentMemberID
        {
            get { return ViewState["CurrentMemberID"] != null ? (int)ViewState["CurrentMemberID"] : 0; }
            set { ViewState["CurrentMemberID"] = value; }
        }

        protected string CurrentMemberNo
        {
            get { return ViewState["CurrentMemberNo"] != null ? ViewState["CurrentMemberNo"].ToString() : ""; }
            set { ViewState["CurrentMemberNo"] = value; }
        }

        public int? CurrentSpouseID
        {
            get { return ViewState["CurrentSpouseID"] != null ? (int?)ViewState["CurrentSpouseID"] : null; }
            set { ViewState["CurrentSpouseID"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GridView1.SelectedIndex = -1;
                pnlMemberDetails.Visible = false;
                searchResultsSection.Visible = false;
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string memberNo = txtMemberNo.Text.Trim();
            string name = txtName.Text.Trim();
            string cnic = txtCNIC.Text.Trim();

            if (string.IsNullOrEmpty(memberNo) && string.IsNullOrEmpty(name) && string.IsNullOrEmpty(cnic))
            {
                return;
            }

            using (SqlConnection con = new SqlConnection(strConn))
            {
                using (SqlCommand cmd = new SqlCommand("usp_SearchRFIDMembers", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 60;
                    cmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = memberNo;
                    cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = name;
                    cmd.Parameters.Add("@CNIC", SqlDbType.NVarChar, 50).Value = cnic;

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                GridView1.DataSource = dt;
                GridView1.DataBind();

                searchResultsSection.Visible = dt.Rows.Count > 0;
                pnlMemberDetails.Visible = false;
                }
            }
        }

        protected void GridView1_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (GridView1.SelectedRow != null)
            {
                CurrentMemberID = Convert.ToInt32(GridView1.SelectedDataKey.Value);
                LoadMemberDetails(CurrentMemberID);
                pnlMemberDetails.Visible = true;
                ScriptManager.RegisterStartupScript(this, GetType(), "focus", "focusRFIDInput();", true);
            }
        }

        private void LoadMemberDetails(int memberId)
        {
            using (SqlConnection con = new SqlConnection(strConn))
            {
                SqlCommand cmd = new SqlCommand("usp_GetRFIDMemberDetails", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    CurrentMemberNo = dr["MemberNo"].ToString();
                    string accountStatus = dr["AccountStatus"].ToString();
                    string spouseName = dr["SpouseName"] != DBNull.Value ? dr["SpouseName"].ToString() : "";
                    
                    if (dr["SpouseID"] != DBNull.Value)
                        CurrentSpouseID = Convert.ToInt32(dr["SpouseID"]);
                    else
                        CurrentSpouseID = null;

                    divStatusWarning.Visible = true;
                    lblMemberStatus.InnerText = accountStatus;
                    
                    dr.Close();

                    // Fetch Spouse MembershipNo
                    string spouseMembershipNo = "";
                    if (CurrentSpouseID.HasValue)
                    {
                        using (SqlCommand spouseCmd = new SqlCommand("SELECT MembershipNo FROM MemberSpouses WHERE SpouseID = @SpouseID", con))
                        {
                            spouseCmd.Parameters.Add("@SpouseID", SqlDbType.Int).Value = CurrentSpouseID.Value;
                            object res = spouseCmd.ExecuteScalar();
                            spouseMembershipNo = res != null ? res.ToString() : "";
                        }
                    }
                    // Fetch Children MembershipNo
                    DataTable dtChildrenMemNo = new DataTable();
                    using (SqlCommand childrenCmd = new SqlCommand("SELECT ChildID, MembershipNo FROM MemberChildren WHERE MemberID = @MemberID", con))
                    {
                        childrenCmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                        SqlDataAdapter da = new SqlDataAdapter(childrenCmd);
                        da.Fill(dtChildrenMemNo);
                    }
                    // Build Family Grid
                    DataTable dtFamily = new DataTable();
                    dtFamily.Columns.Add("Name");
                    dtFamily.Columns.Add("Relationship");
                    dtFamily.Columns.Add("CardNo");
                    dtFamily.Columns.Add("Status");
                    dtFamily.Columns.Add("HolderType");
                    dtFamily.Columns.Add("HolderID", typeof(int));
                    dtFamily.Columns.Add("MembershipNo");

                    // Main Member
                    DataRow drMain = dtFamily.NewRow();
                    drMain["Name"] = GridView1.SelectedRow.Cells[2].Text;
                    drMain["Relationship"] = "Main Member";
                    drMain["HolderType"] = "Main";
                    drMain["HolderID"] = CurrentMemberID;
                    drMain["MembershipNo"] = CurrentMemberNo;
                    
                    string cardNo, cardStatus;
                    GetCardDetails("Main", null, out cardNo, out cardStatus);
                    drMain["CardNo"] = cardNo;
                    drMain["Status"] = cardStatus;
                    dtFamily.Rows.Add(drMain);

                    // Spouse
                    if (CurrentSpouseID.HasValue)
                    {
                        DataRow drSpouse = dtFamily.NewRow();
                        drSpouse["Name"] = spouseName;
                        drSpouse["Relationship"] = "Spouse";
                        drSpouse["HolderType"] = "Spouse";
                        drSpouse["HolderID"] = CurrentSpouseID.Value;
                        drSpouse["MembershipNo"] = spouseMembershipNo;
                        GetCardDetails("Spouse", CurrentSpouseID, out cardNo, out cardStatus);
                        drSpouse["CardNo"] = cardNo;
                        drSpouse["Status"] = cardStatus;
                        dtFamily.Rows.Add(drSpouse);
                    }

                    // Children
                    DataTable dtChildren = GetChildrenData(memberId);
                    foreach (DataRow r in dtChildren.Rows)
                    {
                        DataRow drChild = dtFamily.NewRow();
                        drChild["Name"] = r["ChildName"];
                        drChild["Relationship"] = "Child";
                        drChild["HolderType"] = "Child";
                        drChild["HolderID"] = r["ChildID"];
                        
                        GetCardDetails("Child", Convert.ToInt32(r["ChildID"]), out cardNo, out cardStatus);
                        drChild["CardNo"] = cardNo;
                        drChild["Status"] = !string.IsNullOrEmpty(cardStatus) ? cardStatus : "Active";
                        
                        DataRow[] childMemRows = dtChildrenMemNo.Select("ChildID = " + r["ChildID"]);
                        string childMembershipNo = childMemRows.Length > 0 ? childMemRows[0]["MembershipNo"].ToString() : "";
                        drChild["MembershipNo"] = childMembershipNo;
                        
                        dtFamily.Rows.Add(drChild);
                    }

                    gvFamilyMembers.DataSource = dtFamily;
                    gvFamilyMembers.DataBind();
                    
                    ViewState["FamilyData"] = dtFamily;
                }
            }
        }

        private DataTable GetChildrenData(int memberId)
        {
            using (SqlConnection con = new SqlConnection(strConn))
            {
                SqlCommand cmd = new SqlCommand("usp_GetRFIDChildren", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }

        private void GetCardDetails(string type, int? holderId, out string cardNo, out string cardStatus)
        {
            cardNo = "";
            cardStatus = "";
            using (SqlConnection con = new SqlConnection(strConn))
            {
                using (SqlCommand checkHolderCmd = new SqlCommand("usp_GetRFIDHolderCard", con))
                {
                    checkHolderCmd.CommandType = CommandType.StoredProcedure;
                    checkHolderCmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = CurrentMemberID;
                    checkHolderCmd.Parameters.Add("@Type", SqlDbType.NVarChar, 50).Value = type;
                    checkHolderCmd.Parameters.Add("@HID", SqlDbType.Int).Value = holderId.HasValue ? (object)holderId.Value : DBNull.Value;

                    con.Open();
                    using (SqlDataReader holderDr = checkHolderCmd.ExecuteReader())
                    {
                        if (holderDr.Read())
                        {
                            cardNo = holderDr["CardNo"].ToString();
                            cardStatus = holderDr["CardStatus"].ToString();
                        }
                    }
                }
            }
        }

        private bool AreAllDependentsActive(int memberId)
        {
            using (SqlConnection con = new SqlConnection(strConn))
            {
                SqlCommand cmd = new SqlCommand("usp_CheckAllDependentsActive", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = memberId;

                con.Open();
                object result = cmd.ExecuteScalar();
                return result != null && Convert.ToInt32(result) == 1;
            }
        }

        protected void gvFamilyMembers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "IssueCard")
            {
                int index = Convert.ToInt32(e.CommandArgument);
                DataTable dt = (DataTable)ViewState["FamilyData"];
                if (dt != null && index < dt.Rows.Count)
                {
                    DataRow row = dt.Rows[index];
                    string type = row["HolderType"].ToString();
                    int holderId = Convert.ToInt32(row["HolderID"]);
                    string name = row["Name"].ToString();
                    string currentCardNo = row["CardNo"].ToString();
                    string currentStatus = row["Status"].ToString();
                    string membershipNo = row["MembershipNo"] != DBNull.Value ? row["MembershipNo"].ToString() : "";

                    ViewState["EditHolderType"] = type;
                    ViewState["EditHolderID"] = holderId;
                    ViewState["EditPersonName"] = name;
                    ViewState["EditCurrentCardNo"] = currentCardNo;

                    lblPopupMemberNo.Text = CurrentMemberNo;
                    lblPopupMembershipNo.Text = !string.IsNullOrEmpty(membershipNo) ? membershipNo : CurrentMemberNo;
                    lblPopupPersonName.Text = name;
                    txtPopupRFID.Text = currentCardNo;
                    
                    txtPopupIssueDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                    txtPopupExpiryDate.Text = DateTime.Now.AddYears(5).ToString("yyyy-MM-dd");
                    
                    try { ddlPopupStatus.SelectedValue = !string.IsNullOrEmpty(currentStatus) ? currentStatus : "Active"; } catch { }

                    pnlCardPopup.Visible = true;
                }
            }
        }

        protected void btnSavePopup_Click(object sender, EventArgs e)
        {
            string type = ViewState["EditHolderType"] != null ? ViewState["EditHolderType"].ToString() : null;
            int? holderId = ViewState["EditHolderID"] != null ? (int?)Convert.ToInt32(ViewState["EditHolderID"]) : null;
            string rfid = txtPopupRFID.Text.Trim();
            string issueStr = txtPopupIssueDate.Text;
            string expiryStr = txtPopupExpiryDate.Text;
            string status = ddlPopupStatus.SelectedValue;

            // Force "Active" for new cards
            if (ViewState["EditCurrentCardNo"] == null || string.IsNullOrEmpty(ViewState["EditCurrentCardNo"].ToString()))
            {
                status = "Active";
            }

            if (SaveRFIDCard(type, holderId, rfid, issueStr, expiryStr, status))
            {
                ShowMessage("Card Saved Successfully.");
                pnlCardPopup.Visible = false;
                LoadMemberDetails(CurrentMemberID); // Reload grid
            }
        }

        protected void btnClosePopup_Click(object sender, EventArgs e)
        {
            pnlCardPopup.Visible = false;
        }

        protected void btnPrintPopup_Click(object sender, EventArgs e)
        {
            string type = ViewState["EditHolderType"] != null ? ViewState["EditHolderType"].ToString() : null;
            string name = lblPopupPersonName.Text;
            string rfid = txtPopupRFID.Text.Trim();

            if (!string.IsNullOrEmpty(rfid) && !System.Text.RegularExpressions.Regex.IsMatch(rfid, "^[a-zA-Z0-9]+$"))
            {
                ShowMessage("Error: Only alphanumeric characters are allowed in the RFID Tag.", true);
                return;
            }

            string script = string.Format("printCard('{0}', '{1}', '{2}', '');", 
                type, name.Replace("'", "\\'"), rfid.Replace("'", "\\'"));
            ScriptManager.RegisterStartupScript(this, GetType(), "PrintPopup", script, true);
        }

        private bool SaveRFIDCard(string type, int? holderId, string rfid, string issueStr, string expiryStr, string status)
        {
            if (!string.IsNullOrEmpty(rfid) && !System.Text.RegularExpressions.Regex.IsMatch(rfid, "^[a-zA-Z0-9]+$"))
            {
                ShowMessage("Error: Only alphanumeric characters are allowed in the RFID Tag.", true);
                return false;
            }

            if ((type == "Spouse" || type == "Child") && AreAllDependentsActive(CurrentMemberID))
            {
                ShowMessage("Cannot allocate new RFID because all spouse and children already have active cards.", true);
                return false;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(strConn))
                {
                    con.Open();

                    // Duplicate Check
                    if (!string.IsNullOrEmpty(rfid))
                    {
                        using (SqlCommand checkCmd = new SqlCommand("usp_CheckRFIDDuplicate", con))
                        {
                            checkCmd.CommandType = CommandType.StoredProcedure;
                            checkCmd.Parameters.Add("@CardNo", SqlDbType.NVarChar, 50).Value = rfid.Trim();
                            checkCmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = CurrentMemberID;
                            checkCmd.Parameters.Add("@Type", SqlDbType.NVarChar, 50).Value = type;
                            checkCmd.Parameters.Add("@HID", SqlDbType.Int).Value = holderId.HasValue ? (object)holderId.Value : DBNull.Value;

                            object assignedTo = checkCmd.ExecuteScalar();
                            if (assignedTo != null)
                            {
                                ShowMessage("Error: This RFID Tag is already assigned to Member No: " + assignedTo.ToString(), true);
                                return false;
                            }
                        }
                    }

                    // Holder Check
                    using (SqlCommand checkHolderCmd = new SqlCommand("usp_GetRFIDHolderCard", con))
                    {
                        checkHolderCmd.CommandType = CommandType.StoredProcedure;
                        checkHolderCmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = CurrentMemberID;
                        checkHolderCmd.Parameters.Add("@Type", SqlDbType.NVarChar, 50).Value = type;
                        checkHolderCmd.Parameters.Add("@HID", SqlDbType.Int).Value = holderId.HasValue ? (object)holderId.Value : DBNull.Value;

                        using (SqlDataReader holderDr = checkHolderCmd.ExecuteReader())
                        {
                            if (holderDr.Read())
                            {
                                string currentCardNo = holderDr["CardNo"].ToString();
                                string currentCardStatus = holderDr["CardStatus"].ToString();
                                holderDr.Close();

                                string newRfid = rfid != null ? rfid.Trim() : "";

                                if (currentCardNo != newRfid && !string.IsNullOrEmpty(newRfid))
                                {
                                    if (currentCardStatus != "Lost" && currentCardStatus != "Block" && currentCardStatus != "Replaced")
                                    {
                                        ShowMessage("This person already has an active card (" + currentCardNo + "). You must mark it as Lost, Blocked, or Replaced before assigning a new RFID.", true);
                                        return false;
                                    }
                                }
                            }
                        }
                    }

                    // Upsert Card
                    using (SqlCommand upsertCmd = new SqlCommand("usp_UpsertRFIDCard", con))
                    {
                        upsertCmd.CommandType = CommandType.StoredProcedure;
                        upsertCmd.Parameters.Add("@MemberID", SqlDbType.Int).Value = CurrentMemberID;
                        upsertCmd.Parameters.Add("@MemberNo", SqlDbType.NVarChar, 50).Value = CurrentMemberNo;
                        upsertCmd.Parameters.Add("@CardNo", SqlDbType.NVarChar, 50).Value = rfid != null ? rfid.Trim() : "";
                        upsertCmd.Parameters.Add("@CardHolderType", SqlDbType.NVarChar, 50).Value = type;
                        upsertCmd.Parameters.Add("@CardHolderID", SqlDbType.Int).Value = holderId.HasValue ? (object)holderId.Value : DBNull.Value;
                        upsertCmd.Parameters.Add("@IssueDate", SqlDbType.DateTime).Value = DateTime.Parse(issueStr);
                        upsertCmd.Parameters.Add("@ExpiryDate", SqlDbType.DateTime).Value = DateTime.Parse(expiryStr);
                        upsertCmd.Parameters.Add("@CardStatus", SqlDbType.NVarChar, 50).Value = status;

                        upsertCmd.ExecuteNonQuery();
                    }

                    return true;
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Database Error: " + ex.Message, true);
                return false;
            }
        }



        protected void btnCompleteIssuance_Click(object sender, EventArgs e)
        {
            pnlMemberDetails.Visible = false;
            searchResultsSection.Visible = false;
            txtMemberNo.Text = "";
            txtName.Text = "";
            txtCNIC.Text = "";
            ShowMessage("Member session closed.");
        }

        private void ShowMessage(string msg, bool isError = false)
        {
            string script = string.Format("alert('{0}');", msg.Replace("'", "\\'"));
            ScriptManager.RegisterStartupScript(this, GetType(), "msg", script, true);
        }
    }
}
