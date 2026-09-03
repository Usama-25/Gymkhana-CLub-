// using Infragistics.WebUI.WebHtmlEditor;
// using Microsoft.Reporting.WebForms;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace InterviewList
{
    public partial class WorkingIList : System.Web.UI.Page
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
                // BindPendingInterviews(); // Don't load on page load
                BindFormTypeMainDropdown();
                BindMembershipDropdown();
                PopulateDeferYearDropdown();
            }
        }

        private void BindPendingInterviews(string membership = "")
        {
            using (SqlConnection con = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetPendingInterviews", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                // Pass membership as parameter if provided
                cmd.Parameters.AddWithValue("@Membership",
    string.IsNullOrEmpty(membership) ? (object)DBNull.Value : (object)membership);


                con.Open();

                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());

                ViewState["Grid2"] = dt;

                gvPendingInterviews.DataSource = dt;
                gvPendingInterviews.DataBind();
            }
        }


        private void BindFormTypeMainDropdown()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "SELECT id, FormTypeName FROM FormTypeMain WHERE Status = 1 ORDER BY FormTypeName";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    con.Open();
                    ddlFormTypeMain.DataSource = cmd.ExecuteReader();
                    ddlFormTypeMain.DataTextField = "FormTypeName";
                    ddlFormTypeMain.DataValueField = "id";
                    ddlFormTypeMain.DataBind();
                }
            }
            ddlFormTypeMain.Items.Insert(0, new ListItem("Select Form Type Main", ""));
        }

        private void BindMembershipDropdown(string mainId = "")
        {
            ddlMembership.Items.Clear();

            if (!string.IsNullOrEmpty(mainId))
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    // Use FormTypeSub table as requested
                    string query = "SELECT id, SubTypeName FROM FormTypeSub WHERE Status = 1 AND MainId = @MainId ORDER BY SubTypeName";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@MainId", mainId);
                        con.Open();
                        SqlDataReader dr = cmd.ExecuteReader();

                        ddlMembership.DataSource = dr;
                        ddlMembership.DataTextField = "SubTypeName";
                        ddlMembership.DataValueField = "SubTypeName"; // Using text for SP filtering
                        ddlMembership.DataBind();
                    }
                }
            }

            ddlMembership.Items.Insert(0, new ListItem("Select Membership", ""));
        }

        protected void ddlFormTypeMain_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindMembershipDropdown(ddlFormTypeMain.SelectedValue);

            // Clear grid when main category changes to ensure data consistency
            gvPendingInterviews.DataSource = null;
            gvPendingInterviews.DataBind();
        }

        protected void ddlMembership_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Trigger filter when membership changes
            btnFilter_Click(null, null);
        }

        protected void FilterByDate_Click(object sender, EventArgs e)
        {
            DateTime startDate, endDate;

            // If empty, use NULL
            DateTime? sDate = DateTime.TryParse(txtStartDate.Text, out startDate) ? startDate : (DateTime?)null;
            DateTime? eDate = DateTime.TryParse(txtEndDate.Text, out endDate) ? endDate : (DateTime?)null;

            BindInterviewsByDate(sDate, eDate);
        }


        private void BindInterviewsByDate(DateTime? startDate, DateTime? endDate)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetDate", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@StartDate", (object)startDate ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@EndDate", (object)endDate ?? DBNull.Value);

                    con.Open();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvPendingInterviews.DataSource = dt;
                    gvPendingInterviews.DataBind();
                }
            }
        }


        protected void btnFilter_Click(object sender, EventArgs e)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GetPendingInterviews", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                // Handle Membership / Main Type filtering
                string selectedSub = ddlMembership.SelectedValue;
                string selectedMain = ddlFormTypeMain.SelectedIndex > 0 ? ddlFormTypeMain.SelectedItem.Text : "";

                string filterValue = selectedSub;
                if (string.IsNullOrEmpty(filterValue) && !string.IsNullOrEmpty(selectedMain))
                {
                    // "if not selected show all of the selected main type"
                    filterValue = selectedMain;
                }

                cmd.Parameters.AddWithValue("@Membership", string.IsNullOrEmpty(filterValue) ? (object)DBNull.Value : (object)filterValue);

                // Start Date
                if (string.IsNullOrEmpty(txtStartDate.Text))
                    cmd.Parameters.AddWithValue("@StartDate", DBNull.Value);
                else
                    cmd.Parameters.AddWithValue("@StartDate", Convert.ToDateTime(txtStartDate.Text));

                // End Date
                if (string.IsNullOrEmpty(txtEndDate.Text))
                    cmd.Parameters.AddWithValue("@EndDate", DBNull.Value);
                else
                    cmd.Parameters.AddWithValue("@EndDate", Convert.ToDateTime(txtEndDate.Text));

                con.Open();

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvPendingInterviews.DataSource = dt;
                gvPendingInterviews.DataBind();
            }
        }





        // --------------------------
        // GET SELECTED ROW INDEXES
        // --------------------------
        private List<int> GetSelectedRowsIndexes()
        {
            List<int> indexes = new List<int>();

            for (int i = 0; i < gvPendingInterviews.Rows.Count; i++)
            {
                CheckBox chk = gvPendingInterviews.Rows[i].FindControl("chkSelect") as CheckBox;
                if (chk != null && chk.Checked)
                {
                    indexes.Add(i);
                }
            }
            return indexes;
        }

        // --------------------------
        // ACTION BUTTONS
        // --------------------------
        protected void btnProcessAction_Click(object sender, EventArgs e)
        { }
        protected void btnReject_Click(object sender, EventArgs e)
        {
            hfActionType.Value = "Reject";
            ShowRemarksPanel("Reject Application");
        }

        protected void btnPostponed_Click(object sender, EventArgs e)
        {
            hfActionType.Value = "Postpone";
            ShowRemarksPanel("Postpone Application");
        }

        protected void btnFinalize_Click(object sender, EventArgs e)
        {
            hfActionType.Value = "Finalize";
            ShowRemarksPanel("Finalize Application");
        }

        private void ShowRemarksPanel(string title)
        {
            lblPanelTitle.Text = title;
            pnlRemarks.Visible = true;
            txtRemarks.Text = "";

            // Show date picker & year picker only for Defer (Postpone) action
            bool isDefer = hfActionType.Value == "Postpone";
            pnlDeferDateFields.Visible = isDefer;
            if (isDefer)
            {
                txtDeferDate.Text = "";
                ddlDeferYear.SelectedIndex = 0;
            }
        }

        private void PopulateDeferYearDropdown()
        {
            ddlDeferYear.Items.Clear();
            ddlDeferYear.Items.Add(new ListItem("-- Select Year --", ""));
            int currentYear = DateTime.Now.Year;
            for (int y = currentYear; y <= currentYear + 10; y++)
            {
                ddlDeferYear.Items.Add(new ListItem(y.ToString(), y.ToString()));
            }
        }

        protected void btnClosePanel_Click(object sender, EventArgs e)
        {
            pnlRemarks.Visible = false;
            txtRemarks.Text = "";
            hfActionType.Value = "";
        }

        protected void btnCancelAction_Click(object sender, EventArgs e)
        {
            pnlRemarks.Visible = false;
            pnlDeferDateFields.Visible = false;
            txtRemarks.Text = "";
            hfActionType.Value = "";
        }
        protected void gvPendingInterviews_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandArgument == null) return;

            if (e.CommandArgument == null) return;

            // Robust way: Get from GridViewRow directly
            LinkButton btn = e.CommandSource as LinkButton;
            if (btn != null)
            {
                GridViewRow row = (GridViewRow)btn.NamingContainer;
                // Col Index 3 is CNIC (0=Chk, 1=Name, 2=Father, 3=CNIC)
                string nic = row.Cells[3].Text;
                nic = Server.HtmlDecode(nic).Trim();

                // Set hidden fields
                hfSelectedNIC.Value = nic;
                hfActionType.Value = e.CommandName; // Reject, Postpone, Approve

                // Show popup
                ShowRemarksPanel(e.CommandName + " Application");
            }
        }






        protected void btnConfirmAction_Click(object sender, EventArgs e)
        {
            string remarks = txtRemarks.Text.Trim();
            string action = hfActionType.Value;
            string nic = hfSelectedNIC.Value; // <--- now this works

            if (string.IsNullOrEmpty(nic)) return;

            string status = "Pending";
            if (action == "Reject") status = "Rejected";
            else if (action == "Postpone") status = "Deferred";
            else if (action == "Approve") status = "Approved";

            // Capture defer date & year if Postpone action
            string deferDate = "";
            string deferYear = "";
            if (action == "Postpone")
            {
                deferDate = txtDeferDate.Text.Trim();
                deferYear = ddlDeferYear.SelectedValue;
            }

            UpdateApplicationFFormStatus(nic, status, remarks, deferDate, deferYear);
            UpdateInterviewListStatus(nic, status, remarks, deferDate, deferYear);

            pnlRemarks.Visible = false;
            pnlDeferDateFields.Visible = false;
            BindPendingInterviews();
            lblActionIndicator.Text = "Status updated successfully.";
        }







        // --------------------------
        // REJECT
        // --------------------------
        private void ProcessRejectAction(string remarks)
        {
            DataTable dt = ViewState["Grid2"] as DataTable;
            List<int> selected = GetSelectedRowsIndexes();

            if (selected.Count == 0)
            {
                lblActionIndicator.Text = "Please select at least one record.";
                return;
            }

            foreach (int idx in selected)
            {
                string nic = dt.Rows[idx]["NIC"].ToString();

                UpdateApplicationFFormStatus(nic, "Rejected", remarks);
                UpdateInterviewListStatus(nic, "Rejected", remarks);

                dt.Rows[idx]["Status"] = "Rejected";
            }

            ViewState["Grid2"] = dt;

            gvPendingInterviews.DataSource = dt;
            gvPendingInterviews.DataBind();

            lblActionIndicator.Text = "Rejected successfully.";
        }

        // --------------------------
        // POSTPONE
        // --------------------------
        private void ProcessPostponeAction(string remarks)
        {
            DataTable dt = ViewState["Grid2"] as DataTable;
            List<int> selected = GetSelectedRowsIndexes();

            if (selected.Count == 0)
            {
                lblActionIndicator.Text = "Please select at least one record.";
                return;
            }

            foreach (int idx in selected)
            {
                string nic = dt.Rows[idx]["NIC"].ToString();

                UpdateApplicationFFormStatus(nic, "Deferred", remarks);
                UpdateInterviewListStatus(nic, "Deferred", remarks);

                dt.Rows[idx]["Status"] = "Deferred";
            }

            ViewState["Grid2"] = dt;
            gvPendingInterviews.DataSource = dt;
            gvPendingInterviews.DataBind();

            lblActionIndicator.Text = "Postponed successfully.";
        }

        // --------------------------
        // FINALIZE
        // --------------------------
        private void ProcessFinalizeAction(string remarks)
        {
            ShowRemarksPanel("Finalize Application");
            DataTable dt = ViewState["Grid2"] as DataTable;

            if (dt == null || dt.Rows.Count == 0)
            {
                lblActionIndicator.Text = "Grid is empty!";
                return;
            }

            try
            {
                foreach (DataRow row in dt.Rows)
                {
                    string nic = row["NIC"].ToString();
                    UpdateApplicationFFormStatus(nic, "Approved", remarks);
                    UpdateInterviewListStatus(nic, "Approved", remarks);

                    row["Status"] = "Approved";
                }

                ViewState["Grid2"] = dt;

                gvPendingInterviews.DataSource = dt;
                gvPendingInterviews.DataBind();

                lblActionIndicator.Text = "Finalized successfully!";
                GenerateGrid2PDF();
            }
            catch (Exception ex)
            {
                lblActionIndicator.Text = "Error: " + ex.Message;
            }
        }

        // --------------------------
        // DB STATUS UPDATE METHODS
        // --------------------------
        private void UpdateApplicationFFormStatus(string nic, string status, string remarks, string deferDate = "", string deferYear = "")
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE MainInterview SET Status=@Status, Remarks=@Remarks, DeferDate=@DeferDate, DeferYear=@DeferYear WHERE NIC=@NIC", conn))
            {
                cmd.Parameters.AddWithValue("@Status", status);
                cmd.Parameters.AddWithValue("@Remarks", remarks);
                cmd.Parameters.AddWithValue("@DeferDate", string.IsNullOrEmpty(deferDate) ? (object)DBNull.Value : (object)Convert.ToDateTime(deferDate));
                cmd.Parameters.AddWithValue("@DeferYear", string.IsNullOrEmpty(deferYear) ? (object)DBNull.Value : (object)deferYear);
                cmd.Parameters.AddWithValue("@NIC", nic);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private void UpdateInterviewListStatus(string nic, string status, string remarks, string deferDate = "", string deferYear = "")
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE ApplicationFForm SET Status=@Status, Remarks=@Remarks, DeferDate=@DeferDate, DeferYear=@DeferYear WHERE NIC=@NIC", conn))
            {
                cmd.Parameters.AddWithValue("@Status", status);
                cmd.Parameters.AddWithValue("@Remarks", remarks);
                cmd.Parameters.AddWithValue("@DeferDate", string.IsNullOrEmpty(deferDate) ? (object)DBNull.Value : (object)Convert.ToDateTime(deferDate));
                cmd.Parameters.AddWithValue("@DeferYear", string.IsNullOrEmpty(deferYear) ? (object)DBNull.Value : (object)deferYear);
                cmd.Parameters.AddWithValue("@NIC", nic);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // --------------------------
        // PDF GENERATION
        // --------------------------
        private void GenerateGrid2PDF()
        {
            /*
            DataTable dt = ViewState["Grid2"] as DataTable;

            if (dt == null || dt.Rows.Count == 0)
                return;

            LocalReport lr = new LocalReport();
            lr.ReportPath = Server.MapPath("InterViewListReport.rdlc");
            lr.DataSources.Clear();
            lr.DataSources.Add(new ReportDataSource("DataSet1", dt));

            string mimeType, encoding, extension;
            Warning[] warnings;
            string[] streams;

            byte[] bytes = lr.Render("PDF", null, out mimeType, out encoding, out extension, out streams, out warnings);

            Response.Clear();
            Response.ContentType = mimeType;
            Response.AddHeader("content-disposition", "inline; filename=InterviewList.pdf");
            Response.BinaryWrite(bytes);
            Response.End();
            */
        }
    }
}
