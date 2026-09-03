using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace RefundFee
{
    public partial class PaymentPlan : System.Web.UI.Page
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
                BindAreas();
                BindGrid();
                BindSavedPlans();
            }
        }

        private void BindAreas()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "SELECT SubDept_Id, SubDept_Name FROM subdepartment ORDER BY SubDept_Name";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlArea.DataSource = dt;
                ddlArea.DataTextField = "SubDept_Name";
                ddlArea.DataValueField = "SubDept_Id";
                ddlArea.DataBind();
            }
        }

        protected void ddlArea_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindGrid();
        }

        private void BindGrid()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Area");

            for (int i = 0; i < ddlArea.Items.Count; i++)
            {
                if (ddlArea.Items[i].Selected)
                {
                    dt.Rows.Add(ddlArea.Items[i].Text);
                }
            }

            gvPaymentPlan.DataSource = dt;
            gvPaymentPlan.DataBind();
        }







        private void SaveSelectedPaymentPlans()
        {
            lblMessage.Text = ""; 

            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    string cardIdStr = Request.QueryString["CardID"];
                    int cardId;
                    if (string.IsNullOrEmpty(cardIdStr) || !int.TryParse(cardIdStr, out cardId))
                    {
                        lblMessage.Text = "CardID is missing or invalid.";
                        return;
                    }

                    bool anySaved = false;

                    foreach (GridViewRow row in gvPaymentPlan.Rows)
                    {
                        try
                        {
                            CheckBox chk = row.FindControl("chkSelect") as CheckBox;
                            if (chk == null || !chk.Checked)
                                continue; 

                            string area = row.Cells[0].Text;

                            RadioButtonList rblPlan = row.FindControl("rblPlan") as RadioButtonList;
                            if (rblPlan == null || string.IsNullOrEmpty(rblPlan.SelectedValue))
                            {
                                lblMessage.Text += "Payment plan not selected for row " + row.RowIndex + ".<br/>";
                                continue;
                            }
                            string paymentPlan = rblPlan.SelectedValue;

                            TextBox txtAmount = row.FindControl("amountBox") as TextBox;
                            if (txtAmount == null)
                            {
                                lblMessage.Text += "Amount textbox missing for row " + row.RowIndex + ".<br/>";
                                continue;
                            }

                            decimal amount = 0;
                            decimal.TryParse(txtAmount.Text.Trim(), out amount);

                            using (SqlCommand cmd = new SqlCommand("sp_InsertCardPaymentPlan", con))
                            {
                                cmd.CommandType = CommandType.StoredProcedure;
                                cmd.Parameters.AddWithValue("@CardID", cardId);
                                cmd.Parameters.AddWithValue("@Area", area);
                                cmd.Parameters.AddWithValue("@PaymentPlan", paymentPlan);
                                cmd.Parameters.AddWithValue("@Amount", amount);

                                cmd.ExecuteNonQuery();
                            }

                            row.BackColor = System.Drawing.Color.LightGreen;
                            anySaved = true;
                        }
                        catch (Exception rowEx)
                        {
                            lblMessage.Text += "Error in row " + row.RowIndex + ": " + rowEx.Message + "<br/>";
                        }
                    }

                    if (anySaved)
                    {
                        lblMessage.ForeColor = System.Drawing.Color.Green;
                        lblMessage.Text += "Payment plans saved successfully.";
                    }

                    con.Close();
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error: " + ex.Message;
            }
        }
        protected void btnSave_Click(object sender, EventArgs e)
        {
            SaveSelectedPaymentPlans();
        }
        private void BindSavedPlans()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string cardId = Request.QueryString["CardID"];
                if (string.IsNullOrEmpty(cardId))
                {
                    gvShowPlans.DataSource = null;
                    gvShowPlans.DataBind();
                    return;
                }

                string query = "SELECT Area, PaymentPlan, Amount FROM CardPaymentPlan WHERE CardID=@CardID";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@CardID", cardId);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvShowPlans.DataSource = dt;
                gvShowPlans.DataBind();
            }
        }


    }
}
