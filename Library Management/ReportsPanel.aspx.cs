using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Serialization;

namespace GymkhanaLibrary
{
    public partial class ReportsPanel : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Session Authentication Guard
            if (Session["Emp_ID"] == null || Session["UserName"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // Default date range filter values (Current Month)
                txtIssueFrom.Text = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).ToString("yyyy-MM-dd");
                txtIssueTo.Text = DateTime.Now.ToString("yyyy-MM-dd");
                txtReturnFrom.Text = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).ToString("yyyy-MM-dd");
                txtReturnTo.Text = DateTime.Now.ToString("yyyy-MM-dd");

                BindDropdowns();
            }

            // Check if postback script needs to fire printing popups
            if (IsPostBack && !string.IsNullOrEmpty(hfPrintData.Value))
            {
                litTriggerPrint.Text = "<script type='text/javascript'>triggerPrintWindow();</script>";
            }
            else
            {
                litTriggerPrint.Text = "";
            }
        }

        private void BindDropdowns()
        {
            try
            {
                // Bind Languages
                DataTable dtLang = DBHelper.GetLanguages();
                ddlCatLanguage.DataSource = dtLang;
                ddlCatLanguage.DataTextField = "LangName";
                ddlCatLanguage.DataValueField = "LangID";
                ddlCatLanguage.DataBind();
                ddlCatLanguage.Items.Insert(0, new ListItem("-- All Languages --", ""));

                // Bind Conditions
                DataTable dtCond = DBHelper.GetConditions();
                ddlCatCondition.DataSource = dtCond;
                ddlCatCondition.DataTextField = "CondName";
                ddlCatCondition.DataValueField = "CondID";
                ddlCatCondition.DataBind();
                ddlCatCondition.Items.Insert(0, new ListItem("-- All Conditions --", ""));

                // Bind Audit Language Dropdown (same data, separate control)
                ddlAuditLanguage.DataSource = dtLang;
                ddlAuditLanguage.DataTextField = "LangName";
                ddlAuditLanguage.DataValueField = "LangID";
                ddlAuditLanguage.DataBind();
                ddlAuditLanguage.Items.Insert(0, new ListItem("-- All Languages --", ""));

                // Bind Audit Condition Dropdown
                ddlAuditCondition.DataSource = dtCond;
                ddlAuditCondition.DataTextField = "CondName";
                ddlAuditCondition.DataValueField = "CondID";
                ddlAuditCondition.DataBind();
                ddlAuditCondition.Items.Insert(0, new ListItem("-- All Conditions --", ""));
            }
            catch (Exception ex)
            {
                ShowAlert("Error binding dropdown controls: " + ex.Message);
            }
        }

        private void ShowAlert(string msg)
        {
            pnlAlert.Visible = true;
            litAlertMsg.Text = msg;
        }

        // =========================================================================
        // TAB 0: CATALOGUE LISTING
        // =========================================================================
        protected void btnGenCatalogue_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            try
            {
                gvCatalogue.AllowPaging = true; // Restore paging
                DataTable dt = FetchCatalogueData();
                gvCatalogue.DataSource = dt;
                gvCatalogue.DataBind();
                litCatalogueCount.Text = "(" + dt.Rows.Count + " Record(s))";
                SetCataloguePrintFilters();
            }
            catch (Exception ex)
            {
                ShowAlert("Error generating catalogue listing: " + ex.Message);
            }
        }

        protected void btnExportCatalogue_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            try
            {
                DataTable dt = FetchCatalogueData();
                ExportToExcel(dt, "CatalogListingReport_" + DateTime.Now.ToString("yyyyMMdd_HHmmss"));
            }
            catch (Exception ex)
            {
                ShowAlert("Error exporting catalogue listing: " + ex.Message);
            }
        }

        private DataTable FetchCatalogueData()
        {
            int? from = string.IsNullOrEmpty(txtCatBookNoFrom.Text) ? (int?)null : int.Parse(txtCatBookNoFrom.Text);
            int? to = string.IsNullOrEmpty(txtCatBookNoTo.Text) ? (int?)null : int.Parse(txtCatBookNoTo.Text);
            byte? langId = string.IsNullOrEmpty(ddlCatLanguage.SelectedValue) ? (byte?)null : byte.Parse(ddlCatLanguage.SelectedValue);
            bool? isRef = string.IsNullOrEmpty(ddlCatBookType.SelectedValue) ? (bool?)null : (ddlCatBookType.SelectedValue == "1");
            byte? condId = string.IsNullOrEmpty(ddlCatCondition.SelectedValue) ? (byte?)null : byte.Parse(ddlCatCondition.SelectedValue);
            bool? isAvail = string.IsNullOrEmpty(ddlCatAvailability.SelectedValue) ? (bool?)null : (ddlCatAvailability.SelectedValue == "1");

            return DBHelper.GetCustomCatalog(from, to, langId, isRef, condId, isAvail);
        }

        // =========================================================================
        // TAB 1: CATALOGUE LABELS
        // =========================================================================
        protected void btnGenLabels_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            try
            {
                if (string.IsNullOrEmpty(txtLabelBookNoFrom.Text) || string.IsNullOrEmpty(txtLabelBookNoTo.Text))
                {
                    ShowAlert("Please specify both From and To Book Numbers.");
                    return;
                }
                int from = int.Parse(txtLabelBookNoFrom.Text);
                int to = int.Parse(txtLabelBookNoTo.Text);

                DataTable dt = DBHelper.GetCustomCatalogLabels(from, to);
                gvLabels.DataSource = dt;
                gvLabels.DataBind();
                litLabelsCount.Text = "(" + dt.Rows.Count + " Record(s))";
            }
            catch (Exception ex)
            {
                ShowAlert("Error generating label preview: " + ex.Message);
            }
        }

        protected void btnPrintLabels_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            try
            {
                if (string.IsNullOrEmpty(txtLabelBookNoFrom.Text) || string.IsNullOrEmpty(txtLabelBookNoTo.Text))
                {
                    ShowAlert("Please specify both From and To Book Numbers.");
                    return;
                }
                int from = int.Parse(txtLabelBookNoFrom.Text);
                int to = int.Parse(txtLabelBookNoTo.Text);

                DataTable dt = DBHelper.GetCustomCatalogLabels(from, to);
                if (dt.Rows.Count == 0)
                {
                    ShowAlert("No book copies found in the specified range to print.");
                    return;
                }

                gvLabels.DataSource = dt;
                gvLabels.DataBind();
                litLabelsCount.Text = "(" + dt.Rows.Count + " Record(s))";

                hfPrintData.Value = SerializeDataTable(dt);
                hfPrintType.Value = "labels";
            }
            catch (Exception ex)
            {
                ShowAlert("Error preparing labels for print: " + ex.Message);
            }
        }

        // =========================================================================
        // TAB 2: REGULATION PRINTING
        // =========================================================================
        protected void btnGenRegulations_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            try
            {
                if (string.IsNullOrEmpty(txtRegBookNoFrom.Text) || string.IsNullOrEmpty(txtRegBookNoTo.Text))
                {
                    ShowAlert("Please specify both From and To Book Numbers.");
                    return;
                }
                int from = int.Parse(txtRegBookNoFrom.Text);
                int to = int.Parse(txtRegBookNoTo.Text);

                DataTable dt = DBHelper.GetCustomCatalogRegulations(from, to);
                gvRegulations.DataSource = dt;
                gvRegulations.DataBind();
                litRegulationsCount.Text = "(" + dt.Rows.Count + " Record(s))";
            }
            catch (Exception ex)
            {
                ShowAlert("Error generating regulations preview: " + ex.Message);
            }
        }

        protected void btnPrintRegulations_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            try
            {
                if (string.IsNullOrEmpty(txtRegBookNoFrom.Text) || string.IsNullOrEmpty(txtRegBookNoTo.Text))
                {
                    ShowAlert("Please specify both From and To Book Numbers.");
                    return;
                }
                int from = int.Parse(txtRegBookNoFrom.Text);
                int to = int.Parse(txtRegBookNoTo.Text);

                DataTable dt = DBHelper.GetCustomCatalogRegulations(from, to);
                if (dt.Rows.Count == 0)
                {
                    ShowAlert("No book copies found in the specified range to print.");
                    return;
                }

                gvRegulations.DataSource = dt;
                gvRegulations.DataBind();
                litRegulationsCount.Text = "(" + dt.Rows.Count + " Record(s))";

                hfPrintData.Value = SerializeDataTable(dt);
                hfPrintType.Value = "regulations";
            }
            catch (Exception ex)
            {
                ShowAlert("Error preparing regulations for print: " + ex.Message);
            }
        }

        // =========================================================================
        // TAB 3: ISSUANCE LISTING
        // =========================================================================
        protected void btnGenIssuance_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            try
            {
                gvIssuances.AllowPaging = true; // Restore paging
                DataTable dt = FetchIssuanceData();
                gvIssuances.DataSource = dt;
                gvIssuances.DataBind();
                litIssuancesCount.Text = "(" + dt.Rows.Count + " Record(s))";
                SetIssuancePrintFilters();
            }
            catch (Exception ex)
            {
                ShowAlert("Error generating issuance report: " + ex.Message);
            }
        }

        protected void btnExportIssuance_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            try
            {
                DataTable dt = FetchIssuanceData();
                ExportToExcel(dt, "BookIssuanceReport_" + DateTime.Now.ToString("yyyyMMdd_HHmmss"));
            }
            catch (Exception ex)
            {
                ShowAlert("Error exporting issuance report: " + ex.Message);
            }
        }

        private DataTable FetchIssuanceData()
        {
            DateTime from = DateTime.Parse(txtIssueFrom.Text);
            DateTime to = DateTime.Parse(txtIssueTo.Text);
            string type = ddlIssueType.SelectedValue;
            string memberNo = string.IsNullOrEmpty(txtIssueMemberNo.Text) ? null : txtIssueMemberNo.Text.Trim();

            return DBHelper.GetCustomIssuance(from, to, type, memberNo);
        }

        // =========================================================================
        // TAB 4: RETURN LISTING
        // =========================================================================
        protected void btnGenReturns_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            try
            {
                gvReturns.AllowPaging = true; // Restore paging
                DataTable dt = FetchReturnData();
                gvReturns.DataSource = dt;
                gvReturns.DataBind();
                litReturnsCount.Text = "(" + dt.Rows.Count + " Record(s))";
                SetReturnsPrintFilters();
            }
            catch (Exception ex)
            {
                ShowAlert("Error generating return listing: " + ex.Message);
            }
        }

        protected void btnExportReturns_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            try
            {
                DataTable dt = FetchReturnData();
                ExportToExcel(dt, "BookReturnReport_" + DateTime.Now.ToString("yyyyMMdd_HHmmss"));
            }
            catch (Exception ex)
            {
                ShowAlert("Error exporting return listing: " + ex.Message);
            }
        }

        private DataTable FetchReturnData()
        {
            DateTime from = DateTime.Parse(txtReturnFrom.Text);
            DateTime to = DateTime.Parse(txtReturnTo.Text);

            return DBHelper.GetCustomReturns(from, to);
        }

        // =========================================================================
        // TAB 5: RESERVE LISTING
        // =========================================================================
        protected void btnGenReservations_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            try
            {
                gvReservations.AllowPaging = true; // Restore paging
                DataTable dt = FetchReservationData();
                gvReservations.DataSource = dt;
                gvReservations.DataBind();
                litReservationsCount.Text = "(" + dt.Rows.Count + " Record(s))";
                SetReservationsPrintFilters();
            }
            catch (Exception ex)
            {
                ShowAlert("Error generating reservation listing: " + ex.Message);
            }
        }

        protected void btnExportReservations_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            try
            {
                DataTable dt = FetchReservationData();
                ExportToExcel(dt, "BookReservationsReport_" + DateTime.Now.ToString("yyyyMMdd_HHmmss"));
            }
            catch (Exception ex)
            {
                ShowAlert("Error exporting reservation listing: " + ex.Message);
            }
        }

        private DataTable FetchReservationData()
        {
            int? bookNo = string.IsNullOrEmpty(txtReserveBookNo.Text) ? (int?)null : int.Parse(txtReserveBookNo.Text);
            string memberNo = string.IsNullOrEmpty(txtReserveMemberNo.Text) ? null : txtReserveMemberNo.Text.Trim();

            return DBHelper.GetCustomReservations(bookNo, memberNo);
        }

        // =========================================================================
        // TAB 6: BOOK COST AUDIT
        // =========================================================================
        protected void btnGenCostAudit_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            try
            {
                gvCostAudit.AllowPaging = true;
                DataTable dt = FetchCostAuditData();
                gvCostAudit.DataSource = dt;
                gvCostAudit.DataBind();
                litCostAuditCount.Text = "(" + dt.Rows.Count + " Record(s))";
                SetCostAuditPrintFilters();
            }
            catch (Exception ex)
            {
                ShowAlert("Error generating book cost audit: " + ex.Message);
            }
        }

        protected void btnExportCostAudit_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            try
            {
                DataTable dt = FetchCostAuditData();
                ExportToExcel(dt, "BookCostAuditReport_" + DateTime.Now.ToString("yyyyMMdd_HHmmss"));
            }
            catch (Exception ex)
            {
                ShowAlert("Error exporting book cost audit: " + ex.Message);
            }
        }

        private DataTable FetchCostAuditData()
        {
            int? from = string.IsNullOrEmpty(txtAuditBookNoFrom.Text) ? (int?)null : int.Parse(txtAuditBookNoFrom.Text);
            int? to = string.IsNullOrEmpty(txtAuditBookNoTo.Text) ? (int?)null : int.Parse(txtAuditBookNoTo.Text);
            byte? langId = string.IsNullOrEmpty(ddlAuditLanguage.SelectedValue) ? (byte?)null : byte.Parse(ddlAuditLanguage.SelectedValue);
            byte? condId = string.IsNullOrEmpty(ddlAuditCondition.SelectedValue) ? (byte?)null : byte.Parse(ddlAuditCondition.SelectedValue);
            DateTime? acqFrom = string.IsNullOrEmpty(txtAuditAcqFrom.Text) ? (DateTime?)null : DateTime.Parse(txtAuditAcqFrom.Text);
            DateTime? acqTo = string.IsNullOrEmpty(txtAuditAcqTo.Text) ? (DateTime?)null : DateTime.Parse(txtAuditAcqTo.Text);
            string source = string.IsNullOrEmpty(txtAuditSource.Text) ? null : txtAuditSource.Text.Trim();

            return DBHelper.GetBookCostAudit(from, to, langId, condId, acqFrom, acqTo, source);
        }

        // =========================================================================
        // COMMON HELPERS
        // =========================================================================
        private void ExportToExcel(DataTable dt, string filename)
        {
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=" + filename + ".xls");
            Response.Charset = "";
            Response.ContentType = "application/vnd.ms-excel";
            using (System.IO.StringWriter sw = new System.IO.StringWriter())
            {
                using (HtmlTextWriter hw = new HtmlTextWriter(sw))
                {
                    GridView gv = new GridView();
                    gv.DataSource = dt;
                    gv.DataBind();
                    gv.RenderControl(hw);
                    Response.Write(sw.ToString());
                    Response.End();
                }
            }
        }

        public override void VerifyRenderingInServerForm(Control control)
        {
            // Avoids server-side VerifyRendering exception when programmatically rendering GridView into Excel stream
        }

        private string SerializeDataTable(DataTable dt)
        {
            var rows = new List<Dictionary<string, object>>();
            foreach (DataRow dr in dt.Rows)
            {
                var row = new Dictionary<string, object>();
                foreach (DataColumn col in dt.Columns)
                {
                    row[col.ColumnName] = dr[col];
                }
                rows.Add(row);
            }
            var serializer = new JavaScriptSerializer();
            // Extend max JSON length for large datasets
            serializer.MaxJsonLength = 104857600; // ~100MB limit
            return serializer.Serialize(rows);
        }

        // =========================================================================
        // PDF EXPORT CLICK HANDLERS (FETCHED WITHOUT PAGINATION RESTRICTION)
        // =========================================================================
        private void SetCataloguePrintFilters()
        {
            var filters = new List<string>();
            if (!string.IsNullOrEmpty(txtCatBookNoFrom.Text)) filters.Add("Book No From: " + txtCatBookNoFrom.Text);
            if (!string.IsNullOrEmpty(txtCatBookNoTo.Text)) filters.Add("Book No To: " + txtCatBookNoTo.Text);
            if (ddlCatLanguage.SelectedIndex > 0) filters.Add("Language: " + ddlCatLanguage.SelectedItem.Text);
            if (ddlCatBookType.SelectedIndex > 0) filters.Add("Book Type: " + ddlCatBookType.SelectedItem.Text);
            if (ddlCatCondition.SelectedIndex > 0) filters.Add("Condition: " + ddlCatCondition.SelectedItem.Text);
            if (ddlCatAvailability.SelectedIndex > 0) filters.Add("Availability: " + ddlCatAvailability.SelectedItem.Text);

            litPrintFilters.Text = filters.Count > 0 ? string.Join(" | ", filters) : "All Catalogue Records";
        }

        private void SetIssuancePrintFilters()
        {
            var filters = new List<string>();
            if (!string.IsNullOrEmpty(txtIssueFrom.Text)) filters.Add("From Date: " + txtIssueFrom.Text);
            if (!string.IsNullOrEmpty(txtIssueTo.Text)) filters.Add("To Date: " + txtIssueTo.Text);
            if (ddlIssueType.SelectedIndex >= 0) filters.Add("Report Type: " + ddlIssueType.SelectedItem.Text);
            if (!string.IsNullOrEmpty(txtIssueMemberNo.Text)) filters.Add("Member No: " + txtIssueMemberNo.Text.Trim());

            litPrintFilters.Text = filters.Count > 0 ? string.Join(" | ", filters) : "All Issuance Records";
        }

        private void SetReturnsPrintFilters()
        {
            var filters = new List<string>();
            if (!string.IsNullOrEmpty(txtReturnFrom.Text)) filters.Add("From Date: " + txtReturnFrom.Text);
            if (!string.IsNullOrEmpty(txtReturnTo.Text)) filters.Add("To Date: " + txtReturnTo.Text);

            litPrintFilters.Text = filters.Count > 0 ? string.Join(" | ", filters) : "All Return Records";
        }

        private void SetReservationsPrintFilters()
        {
            var filters = new List<string>();
            if (!string.IsNullOrEmpty(txtReserveBookNo.Text)) filters.Add("Book No: " + txtReserveBookNo.Text);
            if (!string.IsNullOrEmpty(txtReserveMemberNo.Text)) filters.Add("Member No: " + txtReserveMemberNo.Text.Trim());

            litPrintFilters.Text = filters.Count > 0 ? string.Join(" | ", filters) : "All Reservation Records";
        }

        private void SetCostAuditPrintFilters()
        {
            var filters = new List<string>();
            if (!string.IsNullOrEmpty(txtAuditBookNoFrom.Text)) filters.Add("Book No From: " + txtAuditBookNoFrom.Text);
            if (!string.IsNullOrEmpty(txtAuditBookNoTo.Text)) filters.Add("Book No To: " + txtAuditBookNoTo.Text);
            if (ddlAuditLanguage.SelectedIndex > 0) filters.Add("Language: " + ddlAuditLanguage.SelectedItem.Text);
            if (ddlAuditCondition.SelectedIndex > 0) filters.Add("Condition: " + ddlAuditCondition.SelectedItem.Text);
            if (!string.IsNullOrEmpty(txtAuditAcqFrom.Text)) filters.Add("Acq From: " + txtAuditAcqFrom.Text);
            if (!string.IsNullOrEmpty(txtAuditAcqTo.Text)) filters.Add("Acq To: " + txtAuditAcqTo.Text);
            if (!string.IsNullOrEmpty(txtAuditSource.Text)) filters.Add("Source: " + txtAuditSource.Text.Trim());

            litPrintFilters.Text = filters.Count > 0 ? string.Join(" | ", filters) : "All Book Cost Records";
        }

        protected void btnPDFCatalogue_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            try
            {
                gvCatalogue.AllowPaging = false;
                DataTable dt = FetchCatalogueData();
                gvCatalogue.DataSource = dt;
                gvCatalogue.DataBind();
                litCatalogueCount.Text = "(" + dt.Rows.Count + " Record(s))";
                SetCataloguePrintFilters();
                ClientScript.RegisterStartupScript(this.GetType(), "PrintPDF", "setTimeout(printReport, 100);", true);
            }
            catch (Exception ex)
            {
                ShowAlert("Error preparing PDF catalogue: " + ex.Message);
            }
        }

        protected void btnPDFIssuance_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            try
            {
                gvIssuances.AllowPaging = false;
                DataTable dt = FetchIssuanceData();
                gvIssuances.DataSource = dt;
                gvIssuances.DataBind();
                litIssuancesCount.Text = "(" + dt.Rows.Count + " Record(s))";
                SetIssuancePrintFilters();
                ClientScript.RegisterStartupScript(this.GetType(), "PrintPDF", "setTimeout(printReport, 100);", true);
            }
            catch (Exception ex)
            {
                ShowAlert("Error preparing PDF issuance: " + ex.Message);
            }
        }

        protected void btnPDFReturns_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            try
            {
                gvReturns.AllowPaging = false;
                DataTable dt = FetchReturnData();
                gvReturns.DataSource = dt;
                gvReturns.DataBind();
                litReturnsCount.Text = "(" + dt.Rows.Count + " Record(s))";
                SetReturnsPrintFilters();
                ClientScript.RegisterStartupScript(this.GetType(), "PrintPDF", "setTimeout(printReport, 100);", true);
            }
            catch (Exception ex)
            {
                ShowAlert("Error preparing PDF returns: " + ex.Message);
            }
        }

        protected void btnPDFReservations_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            try
            {
                gvReservations.AllowPaging = false;
                DataTable dt = FetchReservationData();
                gvReservations.DataSource = dt;
                gvReservations.DataBind();
                litReservationsCount.Text = "(" + dt.Rows.Count + " Record(s))";
                SetReservationsPrintFilters();
                ClientScript.RegisterStartupScript(this.GetType(), "PrintPDF", "setTimeout(printReport, 100);", true);
            }
            catch (Exception ex)
            {
                ShowAlert("Error preparing PDF reservations: " + ex.Message);
            }
        }

        protected void btnPDFCostAudit_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            try
            {
                gvCostAudit.AllowPaging = false;
                DataTable dt = FetchCostAuditData();
                gvCostAudit.DataSource = dt;
                gvCostAudit.DataBind();
                litCostAuditCount.Text = "(" + dt.Rows.Count + " Record(s))";
                SetCostAuditPrintFilters();
                ClientScript.RegisterStartupScript(this.GetType(), "PrintPDF", "setTimeout(printReport, 100);", true);
            }
            catch (Exception ex)
            {
                ShowAlert("Error preparing PDF book cost audit: " + ex.Message);
            }
        }

        // =========================================================================
        // GRIDVIEW PAGE INDEX CHANGING HANDLERS
        // =========================================================================
        protected void gvCatalogue_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvCatalogue.PageIndex = e.NewPageIndex;
            try
            {
                DataTable dt = FetchCatalogueData();
                gvCatalogue.DataSource = dt;
                gvCatalogue.DataBind();
                litCatalogueCount.Text = "(" + dt.Rows.Count + " Record(s))";
            }
            catch (Exception ex)
            {
                ShowAlert("Error paging catalogue: " + ex.Message);
            }
        }

        protected void gvLabels_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvLabels.PageIndex = e.NewPageIndex;
            try
            {
                if (!string.IsNullOrEmpty(txtLabelBookNoFrom.Text) && !string.IsNullOrEmpty(txtLabelBookNoTo.Text))
                {
                    int from = int.Parse(txtLabelBookNoFrom.Text);
                    int to = int.Parse(txtLabelBookNoTo.Text);
                    DataTable dt = DBHelper.GetCustomCatalogLabels(from, to);
                    gvLabels.DataSource = dt;
                    gvLabels.DataBind();
                    litLabelsCount.Text = "(" + dt.Rows.Count + " Record(s))";
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Error paging labels: " + ex.Message);
            }
        }

        protected void gvRegulations_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvRegulations.PageIndex = e.NewPageIndex;
            try
            {
                if (!string.IsNullOrEmpty(txtRegBookNoFrom.Text) && !string.IsNullOrEmpty(txtRegBookNoTo.Text))
                {
                    int from = int.Parse(txtRegBookNoFrom.Text);
                    int to = int.Parse(txtRegBookNoTo.Text);
                    DataTable dt = DBHelper.GetCustomCatalogRegulations(from, to);
                    gvRegulations.DataSource = dt;
                    gvRegulations.DataBind();
                    litRegulationsCount.Text = "(" + dt.Rows.Count + " Record(s))";
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Error paging regulations: " + ex.Message);
            }
        }

        protected void gvIssuances_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvIssuances.PageIndex = e.NewPageIndex;
            try
            {
                DataTable dt = FetchIssuanceData();
                gvIssuances.DataSource = dt;
                gvIssuances.DataBind();
                litIssuancesCount.Text = "(" + dt.Rows.Count + " Record(s))";
            }
            catch (Exception ex)
            {
                ShowAlert("Error paging issuances: " + ex.Message);
            }
        }

        protected void gvReturns_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvReturns.PageIndex = e.NewPageIndex;
            try
            {
                DataTable dt = FetchReturnData();
                gvReturns.DataSource = dt;
                gvReturns.DataBind();
                litReturnsCount.Text = "(" + dt.Rows.Count + " Record(s))";
            }
            catch (Exception ex)
            {
                ShowAlert("Error paging returns: " + ex.Message);
            }
        }

        protected void gvReservations_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvReservations.PageIndex = e.NewPageIndex;
            try
            {
                DataTable dt = FetchReservationData();
                gvReservations.DataSource = dt;
                gvReservations.DataBind();
                litReservationsCount.Text = "(" + dt.Rows.Count + " Record(s))";
            }
            catch (Exception ex)
            {
                ShowAlert("Error paging reservations: " + ex.Message);
            }
        }

        protected void gvCostAudit_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvCostAudit.PageIndex = e.NewPageIndex;
            try
            {
                DataTable dt = FetchCostAuditData();
                gvCostAudit.DataSource = dt;
                gvCostAudit.DataBind();
                litCostAuditCount.Text = "(" + dt.Rows.Count + " Record(s))";
            }
            catch (Exception ex)
            {
                ShowAlert("Error paging book cost audit: " + ex.Message);
            }
        }

        // =========================================================================
        // DATA ACCESS HELPER
        // =========================================================================
        public static class DBHelper
        {
            private static string GetConnString()
            {
                return ConfigurationManager.ConnectionStrings["GymkhanaLibraryDB"].ConnectionString 
                    ?? "Data Source=.\\LOCALHOST;Initial Catalog=GymkhanaLibraryDB;Integrated Security=True;TrustServerCertificate=True;";
            }

            private static DataTable ExecuteReader(string spName, params SqlParameter[] prms)
            {
                using (var con = new SqlConnection(GetConnString()))
                using (var cmd = new SqlCommand(spName, con) { CommandType = CommandType.StoredProcedure })
                {
                    if (prms != null && prms.Length > 0) cmd.Parameters.AddRange(prms);
                    using (var da = new SqlDataAdapter(cmd))
                    {
                        var dt = new DataTable();
                        da.Fill(dt);
                        return dt;
                    }
                }
            }

            public static DataTable GetLanguages()
            {
                using (var con = new SqlConnection(GetConnString()))
                using (var cmd = new SqlCommand("SELECT LangID, LangName FROM Languages ORDER BY LangName", con))
                {
                    using (var da = new SqlDataAdapter(cmd))
                    {
                        var dt = new DataTable();
                        da.Fill(dt);
                        return dt;
                    }
                }
            }

            public static DataTable GetConditions()
            {
                using (var con = new SqlConnection(GetConnString()))
                using (var cmd = new SqlCommand("SELECT CondID, CondName FROM CopyConditions ORDER BY CondID", con))
                {
                    using (var da = new SqlDataAdapter(cmd))
                    {
                        var dt = new DataTable();
                        da.Fill(dt);
                        return dt;
                    }
                }
            }

            public static DataTable GetCustomCatalog(int? from, int? to, byte? langId, bool? isRef, byte? condId, bool? isAvail)
            {
                return ExecuteReader("sp_Report_CustomCatalog",
                    new SqlParameter("@BookNoFrom", (object)from ?? DBNull.Value),
                    new SqlParameter("@BookNoTo", (object)to ?? DBNull.Value),
                    new SqlParameter("@LangID", (object)langId ?? DBNull.Value),
                    new SqlParameter("@IsReference", (object)isRef ?? DBNull.Value),
                    new SqlParameter("@CondID", (object)condId ?? DBNull.Value),
                    new SqlParameter("@IsAvailable", (object)isAvail ?? DBNull.Value));
            }

            public static DataTable GetCustomCatalogLabels(int from, int to)
            {
                return ExecuteReader("sp_Report_CustomCatalogLabels",
                    new SqlParameter("@BookNoFrom", from),
                    new SqlParameter("@BookNoTo", to));
            }

            public static DataTable GetCustomCatalogRegulations(int from, int to)
            {
                return ExecuteReader("sp_Report_CustomCatalogRegulations",
                    new SqlParameter("@BookNoFrom", from),
                    new SqlParameter("@BookNoTo", to));
            }

            public static DataTable GetCustomIssuance(DateTime from, DateTime to, string type, string membershipNo = null)
            {
                return ExecuteReader("sp_Report_CustomIssuance",
                    new SqlParameter("@FromDate", from),
                    new SqlParameter("@ToDate", to),
                    new SqlParameter("@ReportType", type),
                    new SqlParameter("@MembershipNo", (object)membershipNo ?? DBNull.Value));
            }

            public static DataTable GetCustomReturns(DateTime from, DateTime to)
            {
                return ExecuteReader("sp_Report_CustomReturns",
                    new SqlParameter("@FromDate", from),
                    new SqlParameter("@ToDate", to));
            }

            public static DataTable GetCustomReservations(int? bookNo, string memberNo)
            {
                return ExecuteReader("sp_Report_CustomReservations",
                    new SqlParameter("@BookNo", (object)bookNo ?? DBNull.Value),
                    new SqlParameter("@MembershipNo", (object)memberNo ?? DBNull.Value));
            }

            public static DataTable GetBookCostAudit(int? from, int? to, byte? langId, byte? condId, DateTime? acqFrom, DateTime? acqTo, string source)
            {
                return ExecuteReader("sp_Report_BookCostAudit",
                    new SqlParameter("@BookNoFrom", (object)from ?? DBNull.Value),
                    new SqlParameter("@BookNoTo", (object)to ?? DBNull.Value),
                    new SqlParameter("@LangID", (object)langId ?? DBNull.Value),
                    new SqlParameter("@CondID", (object)condId ?? DBNull.Value),
                    new SqlParameter("@AcqDateFrom", (object)acqFrom ?? DBNull.Value),
                    new SqlParameter("@AcqDateTo", (object)acqTo ?? DBNull.Value),
                    new SqlParameter("@Source", (object)source ?? DBNull.Value));
            }
        }
    }
}
