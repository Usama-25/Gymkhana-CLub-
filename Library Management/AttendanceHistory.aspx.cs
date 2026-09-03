using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GymkhanaLibrary
{
    public partial class AttendanceHistory : System.Web.UI.Page
    {
        #region Page Lifecycle & Init

        protected void Page_Load(object sender, EventArgs e)
        {
            // Auto-login logic for testing / consistency if Session is empty
            if (Session["StaffID"] == null)
            {
                Session["StaffID"] = 1; 
                Session["StaffName"] = "System Admin";
            }

            if (!IsPostBack)
            {

                // Default date filter to current month's start to today
                txtFilterFromDate.Text = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).ToString("yyyy-MM-dd");
                txtFilterToDate.Text = DateTime.Now.ToString("yyyy-MM-dd");

                LoadAttendanceHistory();
            }
        }

        #endregion

        #region Database Utilities

        private string GetConnectionString()
        {
            if (ConfigurationManager.ConnectionStrings["GymkhanaLibraryDB"] != null)
            {
                return ConfigurationManager.ConnectionStrings["GymkhanaLibraryDB"].ConnectionString;
            }
            return "Server=.\\LOCALHOST;Database=GymkhanaLibraryDB;Trusted_Connection=True;";
        }

        private DataTable ExecuteStoredProcedure(string spName, SqlParameter[] parameters = null)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                using (SqlCommand cmd = new SqlCommand(spName, conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        conn.Open();
                        da.Fill(dt);
                    }
                }
            }
            return dt;
        }

        private DataTable GetTableData(string query, SqlParameter[] parameters = null)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        conn.Open();
                        da.Fill(dt);
                    }
                }
            }
            return dt;
        }

        #endregion

        #region History & GridView Load

        private void LoadAttendanceHistory()
        {
            string fromDateStr = txtFilterFromDate.Text.Trim();
            string toDateStr = txtFilterToDate.Text.Trim();
            string mType = ddlFilterMemberType.SelectedValue;
            string status = ddlFilterStatus.SelectedValue;
            string name = txtFilterName.Text.Trim();
            string mNo = txtFilterMemberNo.Text.Trim();

            object fromDate = string.IsNullOrEmpty(fromDateStr) ? DBNull.Value : (object)DateTime.Parse(fromDateStr);
            object toDate = string.IsNullOrEmpty(toDateStr) ? DBNull.Value : (object)DateTime.Parse(toDateStr);

            SqlParameter[] prms = {
                new SqlParameter("@FromDate", fromDate),
                new SqlParameter("@ToDate", toDate),
                new SqlParameter("@Department", DBNull.Value),
                new SqlParameter("@MembershipType", string.IsNullOrEmpty(mType) ? DBNull.Value : (object)mType),
                new SqlParameter("@Status", string.IsNullOrEmpty(status) ? DBNull.Value : (object)status),
                new SqlParameter("@MemberName", string.IsNullOrEmpty(name) ? DBNull.Value : (object)name),
                new SqlParameter("@MembershipNo", string.IsNullOrEmpty(mNo) ? DBNull.Value : (object)mNo)
            };

            try
            {
                DataTable dt = ExecuteStoredProcedure("sp_GetAttendanceHistory", prms);
                gvAttendanceHistory.DataSource = dt;
                gvAttendanceHistory.DataBind();
            }
            catch (Exception ex)
            {
                ShowAlert("Error loading history: " + ex.Message, false);
            }
        }

        protected void gvAttendanceHistory_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.Header)
            {
                for (int i = 0; i < e.Row.Cells.Count; i++)
                {
                    e.Row.Cells[i].Attributes.Add("style", "background-color: #f1f5f9; color: #475569; font-weight: 600; padding: 12px; border-bottom: 2px solid #e2e8f0; text-align: left; vertical-align: middle;");
                }
            }
            else if (e.Row.RowType == DataControlRowType.DataRow)
            {
                for (int i = 0; i < e.Row.Cells.Count; i++)
                {
                    string style = "padding: 12px; border-bottom: 1px solid #e2e8f0; vertical-align: middle;";
                    if (i == 2) style += " font-weight: 600; color: #1e3a8a;";
                    e.Row.Cells[i].Attributes.Add("style", style);
                }
            }
        }

        #endregion

        #region Navigation & Filters Actions

        protected void btnBackToEntry_Click(object sender, EventArgs e)
        {
            Response.Redirect("MemberAttendance.aspx");
        }

        protected void btnFilterSearch_Click(object sender, EventArgs e)
        {
            pnlAlertMessage.Visible = false;
            LoadAttendanceHistory();
        }

        protected void btnFilterReset_Click(object sender, EventArgs e)
        {
            pnlAlertMessage.Visible = false;
            txtFilterFromDate.Text = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).ToString("yyyy-MM-dd");
            txtFilterToDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            ddlFilterMemberType.SelectedIndex = 0;
            ddlFilterStatus.SelectedIndex = 0;
            txtFilterName.Text = "";
            txtFilterMemberNo.Text = "";

            LoadAttendanceHistory();
        }

        #endregion

        #region Reports & Exports

        protected void btnTodayReport_Click(object sender, EventArgs e)
        {
            pnlAlertMessage.Visible = false;
            txtFilterFromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            txtFilterToDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            ddlFilterMemberType.SelectedIndex = 0;
            ddlFilterStatus.SelectedIndex = 0;
            txtFilterName.Text = "";
            txtFilterMemberNo.Text = "";

            LoadAttendanceHistory();
            ShowAlert("Filters set to Today's Attendance.", true);
        }

        protected void btnMonthlyReport_Click(object sender, EventArgs e)
        {
            pnlAlertMessage.Visible = false;
            txtFilterFromDate.Text = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).ToString("yyyy-MM-dd");
            txtFilterToDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            ddlFilterMemberType.SelectedIndex = 0;
            ddlFilterStatus.SelectedIndex = 0;
            txtFilterName.Text = "";
            txtFilterMemberNo.Text = "";

            LoadAttendanceHistory();
            ShowAlert("Filters set to Current Month's Attendance.", true);
        }

        protected void btnSummaryReport_Click(object sender, EventArgs e)
        {
            pnlAlertMessage.Visible = false;
            // Generate print view of the dashboard metrics
            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = "text/html";
            Response.Charset = "utf-8";

            using (StringWriter sw = new StringWriter())
            {
                using (HtmlTextWriter hw = new HtmlTextWriter(sw))
                {
                    // Fetch dashboard stats from DB
                    DataTable dtStats = ExecuteStoredProcedure("sp_GetAttendanceDashboard");
                    DataRow r = dtStats.Rows.Count > 0 ? dtStats.Rows[0] : null;

                    string totalToday = r != null ? r["TodayVisitors"].ToString() : "0";
                    string insideNow = r != null ? r["CurrentInside"].ToString() : "0";
                    string avgStay = r != null ? r["AvgStayTime"].ToString() : "0";
                    string monthly = r != null ? r["MonthlyVisitors"].ToString() : "0";

                    // Fetch total history count directly from MemberAttendance table
                    string totalHistory = "0";
                    try
                    {
                        using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                        {
                            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.MemberAttendance", conn))
                            {
                                conn.Open();
                                totalHistory = cmd.ExecuteScalar().ToString();
                            }
                        }
                    }
                    catch { }

                    hw.Write("<html><head><title>Attendance Summary Report</title>");
                    hw.Write("<style>");
                    hw.Write("body { font-family: Arial, sans-serif; padding: 30px; color: #334155; }");
                    hw.Write(".header { border-bottom: 2px solid #1e3a8a; padding-bottom: 10px; margin-bottom: 30px; }");
                    hw.Write("h1 { color: #1e3a8a; margin: 0; }");
                    hw.Write(".meta { font-size: 13px; color: #64748b; margin-top: 5px; }");
                    hw.Write(".stats-container { display: flex; flex-wrap: wrap; margin-bottom: 30px; }");
                    hw.Write(".card { border: 1px solid #cbd5e1; border-radius: 8px; padding: 20px; width: 200px; margin-right: 15px; margin-bottom: 15px; text-align: center; }");
                    hw.Write(".card-val { font-size: 24px; font-weight: bold; color: #1e3a8a; margin-top: 10px; }");
                    hw.Write(".card-lbl { font-size: 12px; color: #64748b; text-transform: uppercase; }");
                    hw.Write("</style></head><body onload='window.print();'>");
                    hw.Write("<div class='header'><h1>Library Attendance Summary</h1>");
                    hw.Write("<div class='meta'>Generated on: " + DateTime.Now.ToString("dd-MMM-yyyy hh:mm tt") + " | Generated by: " + Session["StaffName"] + "</div></div>");
                    
                    hw.Write("<div class='stats-container'>");
                    hw.Write("<div class='card'><div class='card-lbl'>Today Visitors</div><div class='card-val'>" + totalToday + "</div></div>");
                    hw.Write("<div class='card'><div class='card-lbl'>Inside Library Now</div><div class='card-val'>" + insideNow + "</div></div>");
                    hw.Write("<div class='card'><div class='card-lbl'>Avg Stay (Mins)</div><div class='card-val'>" + avgStay + "</div></div>");
                    hw.Write("<div class='card'><div class='card-lbl'>Monthly Logins</div><div class='card-val'>" + monthly + "</div></div>");
                    hw.Write("<div class='card'><div class='card-lbl'>Total Logins</div><div class='card-val'>" + totalHistory + "</div></div>");
                    hw.Write("</div></body></html>");

                    Response.Write(sw.ToString());
                    Response.Flush();
                    Response.End();
                }
            }
        }

        protected void btnPrint_Click(object sender, EventArgs e)
        {
            pnlAlertMessage.Visible = false;
            DataTable dt = GetFilteredHistoryData();
            if (dt != null && dt.Rows.Count > 0)
            {
                RenderPrintView(dt, "Library Attendance History Report (Print)");
            }
            else
            {
                ShowAlert("No data found matching current filters to print.", false);
            }
        }

        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            pnlAlertMessage.Visible = false;
            DataTable dt = GetFilteredHistoryData();
            if (dt == null || dt.Rows.Count == 0)
            {
                ShowAlert("No data found matching current filters to export to Excel.", false);
                return;
            }

            string filename = "Attendance_History_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".xls";
            
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=" + filename);
            Response.Charset = "utf-8";
            Response.ContentType = "application/vnd.ms-excel";

            using (StringWriter sw = new StringWriter())
            {
                using (HtmlTextWriter hw = new HtmlTextWriter(sw))
                {
                    GridView gv = new GridView();
                    gv.DataSource = dt;
                    gv.DataBind();

                    // Apply basic Excel table formatting styling
                    gv.HeaderStyle.BackColor = System.Drawing.Color.FromArgb(30, 58, 138);
                    gv.HeaderStyle.ForeColor = System.Drawing.Color.White;
                    gv.HeaderStyle.Font.Bold = true;
                    gv.AlternatingRowStyle.BackColor = System.Drawing.Color.FromArgb(248, 250, 252);
                    gv.GridLines = GridLines.Both;

                    gv.RenderControl(hw);
                    Response.Output.Write(sw.ToString());
                    Response.Flush();
                    Response.End();
                }
            }
        }

        protected void btnExportPDF_Click(object sender, EventArgs e)
        {
            pnlAlertMessage.Visible = false;
            DataTable dt = GetFilteredHistoryData();
            if (dt != null && dt.Rows.Count > 0)
            {
                RenderPrintView(dt, "Library Attendance History Report (PDF Export)");
            }
            else
            {
                ShowAlert("No data found matching current filters to export to PDF.", false);
            }
        }

        private DataTable GetFilteredHistoryData()
        {
            string fromDateStr = txtFilterFromDate.Text.Trim();
            string toDateStr = txtFilterToDate.Text.Trim();
            string mType = ddlFilterMemberType.SelectedValue;
            string status = ddlFilterStatus.SelectedValue;
            string name = txtFilterName.Text.Trim();
            string mNo = txtFilterMemberNo.Text.Trim();

            object fromDate = string.IsNullOrEmpty(fromDateStr) ? DBNull.Value : (object)DateTime.Parse(fromDateStr);
            object toDate = string.IsNullOrEmpty(toDateStr) ? DBNull.Value : (object)DateTime.Parse(toDateStr);

            SqlParameter[] prms = {
                new SqlParameter("@FromDate", fromDate),
                new SqlParameter("@ToDate", toDate),
                new SqlParameter("@Department", DBNull.Value),
                new SqlParameter("@MembershipType", string.IsNullOrEmpty(mType) ? DBNull.Value : (object)mType),
                new SqlParameter("@Status", string.IsNullOrEmpty(status) ? DBNull.Value : (object)status),
                new SqlParameter("@MemberName", string.IsNullOrEmpty(name) ? DBNull.Value : (object)name),
                new SqlParameter("@MembershipNo", string.IsNullOrEmpty(mNo) ? DBNull.Value : (object)mNo)
            };

            try
            {
                return ExecuteStoredProcedure("sp_GetAttendanceHistory", prms);
            }
            catch
            {
                return null;
            }
        }

        private void RenderPrintView(DataTable dt, string title)
        {
            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = "text/html";
            Response.Charset = "utf-8";

            using (StringWriter sw = new StringWriter())
            {
                using (HtmlTextWriter hw = new HtmlTextWriter(sw))
                {
                    hw.Write("<html><head><title>" + title + "</title>");
                    hw.Write("<style>");
                    hw.Write("body { font-family: 'Segoe UI', Arial, sans-serif; padding: 20px; color: #1e293b; }");
                    hw.Write(".header { border-bottom: 2px solid #0f1e36; padding-bottom: 10px; margin-bottom: 20px; }");
                    hw.Write(".header h1 { color: #0f1e36; margin: 0; font-size: 24px; }");
                    hw.Write(".meta { font-size: 12px; color: #64748b; margin-top: 5px; }");
                    hw.Write("table { width: 100%; border-collapse: collapse; margin-top: 20px; font-size: 13px; }");
                    hw.Write("th { background-color: #f1f5f9; color: #475569; font-weight: 600; text-align: left; padding: 10px; border: 1px solid #cbd5e1; }");
                    hw.Write("td { padding: 10px; border: 1px solid #cbd5e1; }");
                    hw.Write("tr:nth-child(even) { background-color: #f8fafc; }");
                    hw.Write("</style></head><body onload='window.print();'>");
                    hw.Write("<div class='header'><h1>" + title + "</h1>");
                    hw.Write("<div class='meta'>Generated on: " + DateTime.Now.ToString("dd-MMM-yyyy hh:mm tt") + " | Operator: " + Session["StaffName"] + "</div></div>");
                    
                    hw.Write("<table><thead><tr>");
                    hw.Write("<th>Sr#</th><th>Date</th><th>Member</th><th>Check In</th><th>Check Out</th><th>Duration</th><th>Remarks</th>");
                    hw.Write("</tr></thead><tbody>");

                    foreach (DataRow r in dt.Rows)
                    {
                        string checkInStr = r["CheckIn"] != DBNull.Value ? Convert.ToDateTime(r["CheckIn"]).ToString("dd-MMM-yyyy hh:mm tt") : "-";
                        string checkOutStr = r["CheckOut"] != DBNull.Value ? Convert.ToDateTime(r["CheckOut"]).ToString("dd-MMM-yyyy hh:mm tt") : "-";
                        string durationStr = r["Duration"] != DBNull.Value ? r["Duration"].ToString() + " Mins" : "-";
                        string dateStr = r["AttendanceDate"] != DBNull.Value ? Convert.ToDateTime(r["AttendanceDate"]).ToString("dd-MMM-yyyy") : "-";

                        hw.Write("<tr>");
                        hw.Write("<td>" + r["SrNo"] + "</td>");
                        hw.Write("<td>" + dateStr + "</td>");
                        hw.Write("<td>" + r["Member"] + "</td>");
                        hw.Write("<td>" + checkInStr + "</td>");
                        hw.Write("<td>" + checkOutStr + "</td>");
                        hw.Write("<td>" + durationStr + "</td>");
                        hw.Write("<td>" + r["Remarks"] + "</td>");
                        hw.Write("</tr>");
                    }

                    hw.Write("</tbody></table></body></html>");

                    Response.Write(sw.ToString());
                    Response.Flush();
                    Response.End();
                }
            }
        }

        #endregion

        #region Helper Utilities

        private void ShowAlert(string msg, bool isSuccess)
        {
            pnlAlertMessage.Visible = true;
            lblAlertText.Text = msg;

            if (isSuccess)
            {
                pnlAlertMessage.Style["background-color"] = "#d1fae5"; // emerald green
                pnlAlertMessage.Style["border"] = "1px solid #10b981";
                pnlAlertMessage.Style["color"] = "#065f46";
            }
            else
            {
                pnlAlertMessage.Style["background-color"] = "#fef2f2"; // red
                pnlAlertMessage.Style["border"] = "1px solid #ef4444";
                pnlAlertMessage.Style["color"] = "#991b1b";
            }
        }

        private bool SafeParseBool(object obj)
        {
            if (obj == null || obj == DBNull.Value)
                return false;

            string val = obj.ToString().Trim().ToLower();
            if (val == "true" || val == "1" || val == "active" || val == "yes" || val == "y")
                return true;

            return false;
        }

        #endregion
    }
}
