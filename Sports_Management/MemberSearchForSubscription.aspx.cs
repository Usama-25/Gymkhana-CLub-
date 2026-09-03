using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RefundFee
{
    public partial class MemberSearchFroSupport : Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                pnlPopup.Visible = false;
                pnlDisplay.Visible = false;
                BindDepartments();
                gvSelectedServices.Visible = false;
                btnSave.Visible = false;
            }
        }
        private void BindDepartments()
        {
            string connStr = ConfigurationManager.ConnectionStrings["BasicDataInfoConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "SELECT Dept_Id, Dept_Name FROM Department";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlDepartment.DataSource = dt;
                ddlDepartment.DataTextField = "Dept_Name";
                ddlDepartment.DataValueField = "Dept_Id";
                ddlDepartment.DataBind();
            }


            ddlDepartment.Items.Insert(0, new System.Web.UI.WebControls.ListItem("--Select Department--", "0"));
        }

        protected void rblSubscriptionType_SelectedIndexChanged(object sender, EventArgs e)
        {
            pnlPopup.Visible = true;
            pnlDisplay.Visible = false;
            
            DateTime startDate;
            if (!DateTime.TryParse(txtStartDate.Text, out startDate))
            {
                txtEndDate.Text = ""; 
                return;
            }

            string type = rblSubscriptionType.SelectedValue;

            if (type == "Daily")
            {

                txtEndDate.Text = startDate.AddDays(1).ToString("yyyy-MM-dd");
                txtEndDate.ReadOnly = true;
            }
            else if (type == "Monthly")
            {
               
                txtEndDate.Text = startDate.AddMonths(1).ToString("yyyy-MM-dd");
                txtEndDate.ReadOnly = true;
            }
            else if (type == "Continue")
            {
                
                txtEndDate.Text = "9999-12-31";
                txtEndDate.ReadOnly = true;

            }


        }

        protected void txtStartDate_TextChanged(object sender, EventArgs e)
        {
            rblSubscriptionType_SelectedIndexChanged(sender, e); // reuse logic
        }


        protected void btnSave_Click(object sender, EventArgs e)
        {
           
            int memberId = Convert.ToInt32(Request.QueryString["MemberID"]);
            string memberNo = Request.QueryString["MemberNo"];
            string memberName = Request.QueryString["Name"];
            string NIC = Request.QueryString["NIC"];
            string cardNo = Request.QueryString["CardNo"];

            
            DateTime startDate = DateTime.Parse(txtStartDate.Text);
            DateTime endDate = DateTime.Parse(txtEndDate.Text);
            DateTime bookingDate = DateTime.Now;
            string bookingFor = ddlBookingFor.SelectedValue;

            int deptId = 0;
            if (ddlDepartment.SelectedValue != "")
                deptId = Convert.ToInt32(ddlDepartment.SelectedValue);

            
            string connStr = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;
            int subscriptionId;

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                SqlCommand cmd = new SqlCommand(@"INSERT INTO MemberSubscription
            (MemberID, MemberNo, Name, NIC, CardNo, StartDate, EndDate, BookingDate, BookingFor, DepartmentID)
            VALUES (@MemberID,@MemberNo,@Name,@NIC,@CardNo,@StartDate,@EndDate,@BookingDate,@BookingFor,@DeptID);
            SELECT SCOPE_IDENTITY();", con);

                cmd.Parameters.AddWithValue("@MemberID", memberId);
                cmd.Parameters.AddWithValue("@MemberNo", memberNo);
                cmd.Parameters.AddWithValue("@Name", memberName);
                cmd.Parameters.AddWithValue("@NIC", NIC);
                cmd.Parameters.AddWithValue("@CardNo", cardNo);
                cmd.Parameters.AddWithValue("@StartDate", startDate);
                cmd.Parameters.AddWithValue("@EndDate", endDate);
                cmd.Parameters.AddWithValue("@BookingDate", bookingDate);
                cmd.Parameters.AddWithValue("@BookingFor", bookingFor);
                cmd.Parameters.AddWithValue("@DeptID", deptId);

                subscriptionId = Convert.ToInt32(cmd.ExecuteScalar());
            }

            
            if (ViewState["SelectedServices"] != null)
            {
                DataTable dt = (DataTable)ViewState["SelectedServices"];
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();
                    foreach (DataRow dr in dt.Rows)
                    {
                        SqlCommand cmd = new SqlCommand(@"INSERT INTO MemberSubscriptionServices
                    (SubscriptionID, ServiceID, ServiceName, Amount, Dept_Name)
                    VALUES (@SubscriptionID,@ServiceID,@ServiceName,@Amount,@DeptName)", con);

                        cmd.Parameters.AddWithValue("@SubscriptionID", subscriptionId);
                        cmd.Parameters.AddWithValue("@ServiceID", dr["ServiceId"]);
                        cmd.Parameters.AddWithValue("@ServiceName", dr["ServiceName"]);
                        cmd.Parameters.AddWithValue("@Amount", dr["Amount"]);
                        cmd.Parameters.AddWithValue("@DeptName", dr["Dept_Name"]);

                        cmd.ExecuteNonQuery();
                    }
                }
            }

           
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Subscription saved successfully!');", true);

           
            gvSelectedServices.Visible = false;
            btnSave.Visible = false;
            ViewState["SelectedServices"] = null;
        }

        protected void ddlDepartment_SelectedIndexChanged(object sender, EventArgs e)
        {
            int deptId;
            if (int.TryParse(ddlDepartment.SelectedValue, out deptId) && deptId != 0)
            {
                BindServicesGrid(deptId);
            }
            else
            {
                gvServices.DataSource = null;
                gvServices.DataBind();
            }
        }
        private void BindServicesGrid(int deptId)
        {
            string connStr = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = @"SELECT ss.ServiceId, ss.ServiceName, ss.Amount, d.Dept_Name
                         FROM SportsServices ss
                         INNER JOIN basicdatainfo.dbo.Department d
                         ON d.Dept_ID = ss.Dept_Id
                         WHERE ss.Dept_Id = @DeptId";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@DeptId", deptId);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvServices.DataSource = dt;
                gvServices.DataBind();
            }
        }
        protected void gvServices_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "AddService")
            {
                int serviceId = Convert.ToInt32(e.CommandArgument);

                
                GridViewRow row = (GridViewRow)((LinkButton)e.CommandSource).NamingContainer;
                string serviceName = row.Cells[1].Text;
                string amount = row.Cells[2].Text;
                string deptName = row.Cells[3].Text;

               
                DataTable dt;
                if (ViewState["SelectedServices"] != null)
                    dt = (DataTable)ViewState["SelectedServices"];
                else
                {
                    dt = new DataTable();
                    dt.Columns.Add("ServiceId", typeof(int));
                    dt.Columns.Add("ServiceName", typeof(string));
                    dt.Columns.Add("Amount", typeof(decimal));
                    dt.Columns.Add("Dept_Name", typeof(string));
                }

                
                if (dt.Select("ServiceId=" + serviceId).Length == 0)
                {
                    DataRow dr = dt.NewRow();
                    dr["ServiceId"] = serviceId;
                    dr["ServiceName"] = serviceName;
                    dr["Amount"] = Convert.ToDecimal(amount.Replace("$", "").Trim()); 
                    dr["Dept_Name"] = deptName;
                    dt.Rows.Add(dr);
                }

                
                ViewState["SelectedServices"] = dt;
                gvSelectedServices.DataSource = dt;
                gvSelectedServices.DataBind();
                gvSelectedServices.Visible = true;
                btnSave.Visible = true;
            }
        }
        protected void gvSelectedServices_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "RemoveService")
            {
                int serviceId = Convert.ToInt32(e.CommandArgument);

                if (ViewState["SelectedServices"] != null)
                {
                    DataTable dt = (DataTable)ViewState["SelectedServices"];
                    DataRow[] rows = dt.Select("ServiceId=" + serviceId);
                    if (rows.Length > 0)
                        dt.Rows.Remove(rows[0]);

                    ViewState["SelectedServices"] = dt;

                    gvSelectedServices.DataSource = dt;
                    gvSelectedServices.DataBind();


                    if (dt.Rows.Count == 0)
                    {
                        gvSelectedServices.Visible = false;
                        btnSave.Visible = false;
                    }
                }
            }
        }

    }
}