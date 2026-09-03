using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class EventSetup : System.Web.UI.Page
{
    private readonly string conString = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            ShowTab("EventName");
        }
    }

    // ══════════════════════════════════════════
    //  TAB SWITCHING
    // ══════════════════════════════════════════
    protected void lnkTabEventName_Click(object sender, EventArgs e) { ShowTab("EventName"); }
    protected void lnkTabEventTiming_Click(object sender, EventArgs e) { ShowTab("EventTiming"); }
    protected void lnkTabEventPlace_Click(object sender, EventArgs e) { ShowTab("EventPlace"); }
    protected void lnkTabMenu_Click(object sender, EventArgs e) { ShowTab("Menu"); }

    private void ShowTab(string tab)
    {
        pnlEventName.Visible = (tab == "EventName");
        pnlEventTiming.Visible = (tab == "EventTiming");
        pnlEventPlace.Visible = (tab == "EventPlace");
        pnlMenu.Visible = (tab == "Menu");

        lnkTabEventName.CssClass = (tab == "EventName") ? "tab-link active" : "tab-link";
        lnkTabEventTiming.CssClass = (tab == "EventTiming") ? "tab-link active" : "tab-link";
        lnkTabEventPlace.CssClass = (tab == "EventPlace") ? "tab-link active" : "tab-link";
        lnkTabMenu.CssClass = (tab == "Menu") ? "tab-link active" : "tab-link";

        switch (tab)
        {
            case "EventName": BindEventNameGrid(); break;
            case "EventTiming": BindEventTimingGrid(); break;
            case "EventPlace": BindEventPlaceGrid(); break;
            case "Menu": BindMenuGrid(); break;
        }
    }

    private void SetMessage(string text, bool success)
    {
        lblSetupMessage.Text = text;
        lblSetupMessage.CssClass = success ? "status-label success" : "status-label";
    }

    // ══════════════════════════════════════════
    //  TAB 1 : EVENT NAME
    // ══════════════════════════════════════════
    private void BindEventNameGrid()
    {
        using (SqlConnection con = new SqlConnection(conString))
        {
            SqlCommand cmd = new SqlCommand("SELECT EventName_Id, EventName FROM EventName ORDER BY EventName_Id", con);
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            gvEventName.DataSource = dt;
            gvEventName.DataBind();
        }
    }

    protected void btnSaveEventName_Click(object sender, EventArgs e)
    {
        try
        {
            int id = Convert.ToInt32(hfEventNameId.Value);
            string name = txtEventName.Text.Trim();

            using (SqlConnection con = new SqlConnection(conString))
            {
                con.Open();
                SqlCommand cmd;
                if (id == 0)
                {
                    cmd = new SqlCommand("INSERT INTO EventName (EventName) VALUES (@Name)", con);
                }
                else
                {
                    cmd = new SqlCommand("UPDATE EventName SET EventName = @Name WHERE EventName_Id = @Id", con);
                    cmd.Parameters.AddWithValue("@Id", id);
                }
                cmd.Parameters.AddWithValue("@Name", name);
                cmd.ExecuteNonQuery();
            }

            SetMessage((id == 0 ? "Event Name added successfully." : "Event Name updated successfully."), true);
            ClearEventNameForm();
            ShowTab("EventName");
        }
        catch (Exception ex)
        {
            SetMessage("Error: " + ex.Message, false);
        }
    }

    protected void btnClearEventName_Click(object sender, EventArgs e)
    {
        ClearEventNameForm();
        ShowTab("EventName");
    }

    private void ClearEventNameForm()
    {
        hfEventNameId.Value = "0";
        txtEventName.Text = "";
    }

    protected void gvEventName_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int id = Convert.ToInt32(e.CommandArgument);

        if (e.CommandName == "EditRow")
        {
            using (SqlConnection con = new SqlConnection(conString))
            {
                SqlCommand cmd = new SqlCommand("SELECT EventName_Id, EventName FROM EventName WHERE EventName_Id = @Id", con);
                cmd.Parameters.AddWithValue("@Id", id);
                con.Open();
                using (SqlDataReader rd = cmd.ExecuteReader())
                {
                    if (rd.Read())
                    {
                        hfEventNameId.Value = rd["EventName_Id"].ToString();
                        txtEventName.Text = rd["EventName"].ToString();
                    }
                }
            }
            ShowTab("EventName");
        }
        else if (e.CommandName == "DeleteRow")
        {
            try
            {
                using (SqlConnection con = new SqlConnection(conString))
                {
                    SqlCommand cmd = new SqlCommand("DELETE FROM EventName WHERE EventName_Id = @Id", con);
                    cmd.Parameters.AddWithValue("@Id", id);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
                SetMessage("Event Name deleted.", true);
            }
            catch (SqlException)
            {
                SetMessage("Cannot delete — this Event Name is in use by existing bookings.", false);
            }
            ShowTab("EventName");
        }
    }

    // ══════════════════════════════════════════
    //  TAB 2 : EVENT TIMING
    // ══════════════════════════════════════════
    private void BindEventTimingGrid()
    {
        using (SqlConnection con = new SqlConnection(conString))
        {
            SqlCommand cmd = new SqlCommand("SELECT Timing_Id, Timing FROM EventTiming ORDER BY Timing_Id", con);
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            gvEventTiming.DataSource = dt;
            gvEventTiming.DataBind();
        }
    }

    protected void btnSaveTiming_Click(object sender, EventArgs e)
    {
        try
        {
            int id = Convert.ToInt32(hfTimingId.Value);
            string timing = txtTiming.Text.Trim();

            using (SqlConnection con = new SqlConnection(conString))
            {
                con.Open();
                SqlCommand cmd;
                if (id == 0)
                {
                    cmd = new SqlCommand("INSERT INTO EventTiming (Timing) VALUES (@Timing)", con);
                }
                else
                {
                    cmd = new SqlCommand("UPDATE EventTiming SET Timing = @Timing WHERE Timing_Id = @Id", con);
                    cmd.Parameters.AddWithValue("@Id", id);
                }
                cmd.Parameters.AddWithValue("@Timing", timing);
                cmd.ExecuteNonQuery();
            }

            SetMessage((id == 0 ? "Event Timing added successfully." : "Event Timing updated successfully."), true);
            ClearTimingForm();
            ShowTab("EventTiming");
        }
        catch (Exception ex)
        {
            SetMessage("Error: " + ex.Message, false);
        }
    }

    protected void btnClearTiming_Click(object sender, EventArgs e)
    {
        ClearTimingForm();
        ShowTab("EventTiming");
    }

    private void ClearTimingForm()
    {
        hfTimingId.Value = "0";
        txtTiming.Text = "";
    }

    protected void gvEventTiming_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int id = Convert.ToInt32(e.CommandArgument);

        if (e.CommandName == "EditRow")
        {
            using (SqlConnection con = new SqlConnection(conString))
            {
                SqlCommand cmd = new SqlCommand("SELECT Timing_Id, Timing FROM EventTiming WHERE Timing_Id = @Id", con);
                cmd.Parameters.AddWithValue("@Id", id);
                con.Open();
                using (SqlDataReader rd = cmd.ExecuteReader())
                {
                    if (rd.Read())
                    {
                        hfTimingId.Value = rd["Timing_Id"].ToString();
                        txtTiming.Text = rd["Timing"].ToString();
                    }
                }
            }
            ShowTab("EventTiming");
        }
        else if (e.CommandName == "DeleteRow")
        {
            try
            {
                using (SqlConnection con = new SqlConnection(conString))
                {
                    SqlCommand cmd = new SqlCommand("DELETE FROM EventTiming WHERE Timing_Id = @Id", con);
                    cmd.Parameters.AddWithValue("@Id", id);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
                SetMessage("Event Timing deleted.", true);
            }
            catch (SqlException)
            {
                SetMessage("Cannot delete — this Timing is in use by existing bookings.", false);
            }
            ShowTab("EventTiming");
        }
    }

    // ══════════════════════════════════════════
    //  TAB 3 : EVENT PLACE
    // ══════════════════════════════════════════
    private void BindEventPlaceGrid()
    {
        using (SqlConnection con = new SqlConnection(conString))
        {
            SqlCommand cmd = new SqlCommand("SELECT Event_Id, Event_Place FROM EventBookingPlace ORDER BY Event_Id", con);
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            gvEventPlace.DataSource = dt;
            gvEventPlace.DataBind();
        }
    }

    protected void btnSavePlace_Click(object sender, EventArgs e)
    {
        try
        {
            int id = Convert.ToInt32(hfPlaceId.Value);
            string place = txtPlace.Text.Trim();

            using (SqlConnection con = new SqlConnection(conString))
            {
                con.Open();
                SqlCommand cmd;
                if (id == 0)
                {
                    cmd = new SqlCommand("INSERT INTO EventBookingPlace (Event_Place) VALUES (@Place)", con);
                }
                else
                {
                    cmd = new SqlCommand("UPDATE EventBookingPlace SET Event_Place = @Place WHERE Event_Id = @Id", con);
                    cmd.Parameters.AddWithValue("@Id", id);
                }
                cmd.Parameters.AddWithValue("@Place", place);
                cmd.ExecuteNonQuery();
            }

            SetMessage((id == 0 ? "Event Place added successfully." : "Event Place updated successfully."), true);
            ClearPlaceForm();
            ShowTab("EventPlace");
        }
        catch (Exception ex)
        {
            SetMessage("Error: " + ex.Message, false);
        }
    }

    protected void btnClearPlace_Click(object sender, EventArgs e)
    {
        ClearPlaceForm();
        ShowTab("EventPlace");
    }

    private void ClearPlaceForm()
    {
        hfPlaceId.Value = "0";
        txtPlace.Text = "";
    }

    protected void gvEventPlace_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int id = Convert.ToInt32(e.CommandArgument);

        if (e.CommandName == "EditRow")
        {
            using (SqlConnection con = new SqlConnection(conString))
            {
                SqlCommand cmd = new SqlCommand("SELECT Event_Id, Event_Place FROM EventBookingPlace WHERE Event_Id = @Id", con);
                cmd.Parameters.AddWithValue("@Id", id);
                con.Open();
                using (SqlDataReader rd = cmd.ExecuteReader())
                {
                    if (rd.Read())
                    {
                        hfPlaceId.Value = rd["Event_Id"].ToString();
                        txtPlace.Text = rd["Event_Place"].ToString();
                    }
                }
            }
            ShowTab("EventPlace");
        }
        else if (e.CommandName == "DeleteRow")
        {
            try
            {
                using (SqlConnection con = new SqlConnection(conString))
                {
                    SqlCommand cmd = new SqlCommand("DELETE FROM EventBookingPlace WHERE Event_Id = @Id", con);
                    cmd.Parameters.AddWithValue("@Id", id);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
                SetMessage("Event Place deleted.", true);
            }
            catch (SqlException)
            {
                SetMessage("Cannot delete — this Place is in use by existing bookings.", false);
            }
            ShowTab("EventPlace");
        }
    }

    // ══════════════════════════════════════════
    //  TAB 4 : MENU (MainDeals)
    // ══════════════════════════════════════════
    private void BindMenuGrid()
    {
        using (SqlConnection con = new SqlConnection(conString))
        {
            SqlCommand cmd = new SqlCommand(
                "SELECT DID, DealName, DealAmount, Tax, Timing, ISActive, Remarks FROM MainDeals ORDER BY DID", con);
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            gvMenu.DataSource = dt;
            gvMenu.DataBind();
        }
    }

    protected void btnSaveMenu_Click(object sender, EventArgs e)
    {
        try
        {
            int did = Convert.ToInt32(hfMenuDID.Value);
            string dealName = txtDealName.Text.Trim();

            decimal dealAmount;
            decimal.TryParse(txtDealAmount.Text.Trim(), out dealAmount);

            string tax = txtMenuTax.Text.Trim();
            string timing = txtMenuTiming.Text.Trim();
            string remarks = txtMenuRemarks.Text.Trim();
            bool isActive = chkMenuActive.Checked;

            using (SqlConnection con = new SqlConnection(conString))
            {
                con.Open();

                if (did == 0)
                {
                    // MainDeals.DID has no IDENTITY — generate the next ID manually
                    SqlCommand cmdMax = new SqlCommand("SELECT ISNULL(MAX(DID), 0) + 1 FROM MainDeals", con);
                    did = Convert.ToInt32(cmdMax.ExecuteScalar());

                    SqlCommand cmd = new SqlCommand(@"
                        INSERT INTO MainDeals (DID, DealName, DealAmount, Tax, ISActive, EntryDate, Remarks, Timing)
                        VALUES (@DID, @DealName, @DealAmount, @Tax, @ISActive, @EntryDate, @Remarks, @Timing)", con);
                    cmd.Parameters.AddWithValue("@DID", did);
                    cmd.Parameters.AddWithValue("@DealName", dealName);
                    cmd.Parameters.AddWithValue("@DealAmount", dealAmount);
                    cmd.Parameters.AddWithValue("@Tax", string.IsNullOrEmpty(tax) ? (object)DBNull.Value : tax);
                    cmd.Parameters.AddWithValue("@ISActive", isActive);
                    cmd.Parameters.AddWithValue("@EntryDate", DateTime.Now);
                    cmd.Parameters.AddWithValue("@Remarks", string.IsNullOrEmpty(remarks) ? (object)DBNull.Value : remarks);
                    cmd.Parameters.AddWithValue("@Timing", string.IsNullOrEmpty(timing) ? (object)DBNull.Value : timing);
                    cmd.ExecuteNonQuery();
                }
                else
                {
                    SqlCommand cmd = new SqlCommand(@"
                        UPDATE MainDeals SET
                            DealName = @DealName,
                            DealAmount = @DealAmount,
                            Tax = @Tax,
                            ISActive = @ISActive,
                            Remarks = @Remarks,
                            Timing = @Timing
                        WHERE DID = @DID", con);
                    cmd.Parameters.AddWithValue("@DID", did);
                    cmd.Parameters.AddWithValue("@DealName", dealName);
                    cmd.Parameters.AddWithValue("@DealAmount", dealAmount);
                    cmd.Parameters.AddWithValue("@Tax", string.IsNullOrEmpty(tax) ? (object)DBNull.Value : tax);
                    cmd.Parameters.AddWithValue("@ISActive", isActive);
                    cmd.Parameters.AddWithValue("@Remarks", string.IsNullOrEmpty(remarks) ? (object)DBNull.Value : remarks);
                    cmd.Parameters.AddWithValue("@Timing", string.IsNullOrEmpty(timing) ? (object)DBNull.Value : timing);
                    cmd.ExecuteNonQuery();
                }
            }

            SetMessage((Convert.ToInt32(hfMenuDID.Value) == 0 ? "Menu Deal added successfully." : "Menu Deal updated successfully."), true);
            ClearMenuForm();
            ShowTab("Menu");
        }
        catch (Exception ex)
        {
            SetMessage("Error: " + ex.Message, false);
        }
    }

    protected void btnClearMenu_Click(object sender, EventArgs e)
    {
        ClearMenuForm();
        ShowTab("Menu");
    }

    private void ClearMenuForm()
    {
        hfMenuDID.Value = "0";
        txtDealName.Text = "";
        txtDealAmount.Text = "";
        txtMenuTax.Text = "";
        txtMenuTiming.Text = "";
        txtMenuRemarks.Text = "";
        chkMenuActive.Checked = true;
    }

    protected void gvMenu_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int did = Convert.ToInt32(e.CommandArgument);

        if (e.CommandName == "EditRow")
        {
            using (SqlConnection con = new SqlConnection(conString))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT DID, DealName, DealAmount, Tax, Timing, ISActive, Remarks FROM MainDeals WHERE DID = @DID", con);
                cmd.Parameters.AddWithValue("@DID", did);
                con.Open();
                using (SqlDataReader rd = cmd.ExecuteReader())
                {
                    if (rd.Read())
                    {
                        hfMenuDID.Value = rd["DID"].ToString();
                        txtDealName.Text = rd["DealName"] == DBNull.Value ? "" : rd["DealName"].ToString();
                        txtDealAmount.Text = rd["DealAmount"] == DBNull.Value ? "" : Convert.ToDecimal(rd["DealAmount"]).ToString("F2");
                        txtMenuTax.Text = rd["Tax"] == DBNull.Value ? "" : rd["Tax"].ToString();
                        txtMenuTiming.Text = rd["Timing"] == DBNull.Value ? "" : rd["Timing"].ToString();
                        txtMenuRemarks.Text = rd["Remarks"] == DBNull.Value ? "" : rd["Remarks"].ToString();
                        chkMenuActive.Checked = rd["ISActive"] != DBNull.Value && Convert.ToBoolean(rd["ISActive"]);
                    }
                }
            }
            ShowTab("Menu");
        }
        else if (e.CommandName == "DeleteRow")
        {
            try
            {
                using (SqlConnection con = new SqlConnection(conString))
                {
                    SqlCommand cmd = new SqlCommand("DELETE FROM MainDeals WHERE DID = @DID", con);
                    cmd.Parameters.AddWithValue("@DID", did);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
                SetMessage("Menu Deal deleted.", true);
            }
            catch (SqlException)
            {
                SetMessage("Cannot delete — this Deal is in use by existing bookings.", false);
            }
            ShowTab("Menu");
        }
    }
}

