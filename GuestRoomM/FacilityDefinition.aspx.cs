using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GuestRoomM
{
    public partial class FacilityDefinition : System.Web.UI.Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Initial Loads
                LoadRooms();
                LoadCategories();
                LoadLocations();
                LoadItems();
                LoadMiniBarItems();
                
                // Set initial view
                mvMain.ActiveViewIndex = 1; // Order Center by default
                
                // Auto-select room if passed via QueryString
                if (!string.IsNullOrEmpty(Request.QueryString["RoomNo"]))
                {
                    string roomNo = Request.QueryString["RoomNo"];
                    if (ddlRooms.Items.FindByValue(roomNo) != null)
                    {
                        ddlRooms.SelectedValue = roomNo;
                        HandleRoomSelection(roomNo);
                    }
                }
            }
        }

        #region [ TAB NAVIGATION ]
        protected void SwitchTab(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            int index = int.Parse(btn.CommandArgument);
            mvMain.ActiveViewIndex = index;

            // CSS classes for buttons
            btnTab1.CssClass = "tab-btn" + (index == 1 ? " active" : "");
            btnTab2.CssClass = "tab-btn" + (index == 0 ? " active" : "");
            btnTab3.CssClass = "tab-btn" + (index == 2 ? " active" : "");
            if (btnTab4 != null) btnTab4.CssClass = "tab-btn" + (index == 3 ? " active" : "");

            if (index == 1)
            {
                LoadMiniBarItems();
            }

            if (index == 2 && ddlRooms.SelectedValue != "0")
            {
                LoadOrderHistory(ddlRooms.SelectedValue);
            }

            if (index == 3)
            {
                LoadLaundryItems();
                if (ddlRooms.SelectedValue != "0")
                {
                    if (lblLaundryRoom != null) lblLaundryRoom.Text = ddlRooms.SelectedValue;
                    LoadLaundryPendingBalance(ddlRooms.SelectedValue);
                }
            }
        }
        #endregion

        #region [ TAB 1: ORDER CENTER ]
        private void LoadRooms()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = @"SELECT DISTINCT r.RoomNo, ('Room ' + r.RoomNo) as Display 
                                     FROM RoomDefinitionNew r
                                     INNER JOIN RoomAllocations ra ON r.RoomNo = ra.RoomNo
                                     INNER JOIN RoomReservations rr ON ra.ReservationNo = rr.ReservationNo
                                     WHERE rr.Status IN ('Occupied', 'Availed') AND ra.CheckOutDate IS NULL
                                     ORDER BY r.RoomNo";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        DataTable dt = new DataTable();
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        con.Open();
                        da.Fill(dt);
                        ddlRooms.DataSource = dt;
                        ddlRooms.DataTextField = "Display";
                        ddlRooms.DataValueField = "RoomNo";
                        ddlRooms.DataBind();
                        ddlRooms.Items.Insert(0, new ListItem("-- Select Guest Room --", "0"));
                    }
                }
            }
            catch (Exception ex) { ShowMessage("Error loading rooms: " + ex.Message, false); }
        }

        protected void ddlRooms_SelectedIndexChanged(object sender, EventArgs e)
        {
            HandleRoomSelection(ddlRooms.SelectedValue);
        }

        private void HandleRoomSelection(string roomNo)
        {
            if (roomNo != "0" && !string.IsNullOrEmpty(roomNo))
            {
                if (lblRoomNo != null) lblRoomNo.Text = roomNo;
                if (lblHistoryRoom != null) lblHistoryRoom.Text = roomNo;
                if (lblLaundryRoom != null) lblLaundryRoom.Text = roomNo;
                LoadGuestInfo(roomNo);
                LoadOrderHistory(roomNo);
                LoadLaundryPendingBalance(roomNo);
                if (upMain != null) upMain.Update();
            }
            else
            {
                if (lblRoomNo != null) lblRoomNo.Text = "--";
                if (lblHistoryRoom != null) lblHistoryRoom.Text = "--";
                if (lblLaundryRoom != null) lblLaundryRoom.Text = "--";
                if (lblGuestName != null) lblGuestName.Text = "No room selected";
                if (lblLaundryGuest != null) lblLaundryGuest.Text = "No room selected";
                if (lblPending != null) lblPending.Text = "0";
                if (lblLaundryPending != null) lblLaundryPending.Text = "0";
                Session["CurrentResNo"] = null;
                if (upMain != null) upMain.Update();
            }
            
            if (upMain != null)
            {
                ScriptManager.RegisterStartupScript(upMain, upMain.GetType(), "clearCartOnRoomChange", "if(typeof clearCart === 'function') clearCart();", true);
            }
        }

        private void LoadGuestInfo(string roomNo)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    // Corrected query: join with RoomAllocations to find guest by RoomNo
                    string query = @"SELECT TOP 1 rr.GuestName, rr.ReservationNo 
                                   FROM RoomReservations rr 
                                   INNER JOIN RoomAllocations ra ON rr.ReservationNo = ra.ReservationNo 
                                   WHERE ra.RoomNo = @RoomNo AND rr.Status IN ('Occupied', 'Availed') 
                                   AND ra.CheckOutDate IS NULL 
                                   ORDER BY ra.AllocatedDate DESC";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@RoomNo", roomNo ?? (object)DBNull.Value);
                        con.Open();
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                string gName = dr["GuestName"] != DBNull.Value ? dr["GuestName"].ToString() : "N/A";
                                string resNo = dr["ReservationNo"] != DBNull.Value ? dr["ReservationNo"].ToString() : "";
                                if (lblGuestName != null) lblGuestName.Text = "Guest: " + gName;
                                if (lblLaundryGuest != null) lblLaundryGuest.Text = "Guest: " + gName;
                                Session["CurrentResNo"] = resNo;
                            }
                            else
                            {
                                if (lblGuestName != null) lblGuestName.Text = "Guest information not found (Ensure check-in)";
                                if (lblLaundryGuest != null) lblLaundryGuest.Text = "Guest information not found (Ensure check-in)";
                                Session["CurrentResNo"] = null;
                            }
                        }
                    }
                }
                LoadPendingBalance(roomNo);
            }
            catch (Exception ex)
            {
                if (lblGuestName != null) lblGuestName.Text = "Error loading guest info: " + ex.Message;
            }
        }

        private void LoadPendingBalance(string roomNo)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string resNo = Session["CurrentResNo"] as string;
                    string query = @"SELECT ISNULL(SUM(TotalAmount), 0) 
                                     FROM GR_RoomServices 
                                     WHERE RoomNo = @RoomNo 
                                     AND ReservationNo = @ResNo 
                                     AND Status = 'Pending'
                                     AND ServiceName NOT LIKE 'Room Rent%'
                                     AND ServiceName NOT LIKE 'GST%'";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@RoomNo", roomNo ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@ResNo", string.IsNullOrEmpty(resNo) ? (object)DBNull.Value : resNo);
                        con.Open();
                        object result = cmd.ExecuteScalar();
                        if (lblPending != null) lblPending.Text = Convert.ToDecimal(result ?? 0).ToString("N0");
                    }
                }
            }
            catch { if (lblPending != null) lblPending.Text = "0"; }
        }

        public string GetServiceIcon(string itemName)
        {
            if (string.IsNullOrEmpty(itemName)) return "fas fa-concierge-bell";
            string itemLower = itemName.ToLower();
            if (itemLower.Contains("shirt") || itemLower.Contains("cloth")) return "fas fa-tshirt";
            if (itemLower.Contains("iron") || itemLower.Contains("press")) return "fas fa-plug";
            if (itemLower.Contains("wash") || itemLower.Contains("laundry")) return "fas fa-soap";
            if (itemLower.Contains("dry")) return "fas fa-wind";
            if (itemLower.Contains("food") || itemLower.Contains("meal") || itemLower.Contains("breakfast")) return "fas fa-utensils";
            if (itemLower.Contains("tea") || itemLower.Contains("coffee") || itemLower.Contains("beverage")) return "fas fa-coffee";
            if (itemLower.Contains("clean") || itemLower.Contains("housekeeping")) return "fas fa-broom";
            if (itemLower.Contains("spa")) return "fas fa-spa";
            return "fas fa-concierge-bell";
        }

        protected void btnCheckout_Click(object sender, EventArgs e)
        {
            if (ddlRooms.SelectedValue == "0")
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Please select a room first!');", true);
                return;
            }

            string cartJson = hfCart.Value;
            if (string.IsNullOrEmpty(cartJson)) return;

            JavaScriptSerializer serializer = new JavaScriptSerializer();
            List<CartItem> items = serializer.Deserialize<List<CartItem>>(cartJson);

            if (items == null || items.Count == 0) return;

            string invoiceNo = "INV-" + DateTime.Now.ToString("yyyyMMddHHmmss");
            string resNo = Session["CurrentResNo"] as string ?? "";

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                using (SqlTransaction trans = con.BeginTransaction())
                {
                    try
                    {
                        foreach (var item in items)
                        {
                            // Calculate Tax Amount
                            decimal taxPct = item.tax;
                            decimal taxAmt = (item.price * item.qty) * (taxPct / 100);

                            string query = @"INSERT INTO GR_RoomServices (ReservationNo, RoomNo, ServiceName, Qty, UnitPrice, TaxPercentage, TaxAmount, Status, OrderDate, InvoiceNo) 
                                           VALUES (@ResNo, @RoomNo, @ServiceName, @Qty, @UnitPrice, @TaxPct, @TaxAmt, 'Confirmed', GETDATE(), @Invoice); SELECT SCOPE_IDENTITY();";
                            using (SqlCommand cmd = new SqlCommand(query, con, trans))
                            {
                                cmd.Parameters.AddWithValue("@ResNo", string.IsNullOrEmpty(resNo) ? (object)DBNull.Value : resNo);
                                cmd.Parameters.AddWithValue("@RoomNo", ddlRooms.SelectedValue);
                                cmd.Parameters.AddWithValue("@ServiceName", item.name);
                                cmd.Parameters.AddWithValue("@Qty", item.qty);
                                cmd.Parameters.AddWithValue("@UnitPrice", item.price);
                                cmd.Parameters.AddWithValue("@TaxPct", taxPct);
                                cmd.Parameters.AddWithValue("@TaxAmt", taxAmt);
                                cmd.Parameters.AddWithValue("@Invoice", invoiceNo);
                                object sIdObj = cmd.ExecuteScalar();
                                int sId = sIdObj != DBNull.Value ? Convert.ToInt32(sIdObj) : 0;

                                // â”€â”€ LEDGER POSTING â”€â”€
                                decimal totalItemCharge = (item.price * item.qty) + taxAmt;
                                PostToLedger(resNo, ddlRooms.SelectedValue, invoiceNo, item.name + " (Qty: " + item.qty + ")", totalItemCharge, 0, con, trans, sId);
                            }
                        }
                        trans.Commit();
                        
                        hfCart.Value = "";
                        ScriptManager.RegisterStartupScript(this, GetType(), "success", 
                            "clearCart(); hideModal();", true);

                        ShowMessage("Service shift to Room No " + ddlRooms.SelectedValue, true);

                        LoadPendingBalance(ddlRooms.SelectedValue);
                        LoadLaundryPendingBalance(ddlRooms.SelectedValue);
                        LoadOrderHistory(ddlRooms.SelectedValue);
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        ScriptManager.RegisterStartupScript(this, GetType(), "error", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
                    }
                }
            }
        }
        #endregion

        #region [ TAB 2: ITEM DEFINITION ]
        private void LoadCategories()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_GR_GetCategories", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    ddlCategory.Items.Clear();
                    ddlCategory.Items.Add(new ListItem("-- Select Category --", "0"));
                    while (dr.Read()) ddlCategory.Items.Add(new ListItem(dr["CategoryName"].ToString(), dr["CategoryID"].ToString()));
                }
            }
            catch { }
        }

        private void LoadLocations()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand("sp_GR_GetLocations", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    ddlLocation.Items.Clear();
                    ddlLocation.Items.Add(new ListItem("-- Select Location --", "0"));
                    while (dr.Read()) ddlLocation.Items.Add(new ListItem(dr["LocationName"].ToString(), dr["LocationID"].ToString()));
                }
            }
            catch { }
        }

        private void LoadItems(string search = null)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    SqlCommand cmd;
                    if (!string.IsNullOrEmpty(search))
                    {
                        cmd = new SqlCommand("sp_GR_SearchItems", con);
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@SearchTerm", search);
                    }
                    else
                    {
                        cmd = new SqlCommand("sp_GR_GetItems", con);
                        cmd.CommandType = CommandType.StoredProcedure;
                    }
                    
                    DataTable dt = new DataTable();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    con.Open();
                    da.Fill(dt);
                    
                    gvItems.DataSource = dt;
                    gvItems.DataBind();
                }
            }
            catch { }
        }

        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlCategory.SelectedValue != "0" && hfItemID.Value == "0")
            {
                GenerateItemCode(int.Parse(ddlCategory.SelectedValue));
            }
        }

        private void GenerateItemCode(int categoryID)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GR_GenerateItemCode", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CategoryID", categoryID);
                SqlParameter outParam = new SqlParameter("@NewItemCode", SqlDbType.NVarChar, 20);
                outParam.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outParam);
                con.Open();
                cmd.ExecuteNonQuery();
                txtItemCode.Text = outParam.Value.ToString();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtItemName.Text) || ddlCategory.SelectedValue == "0") return;

            if (string.IsNullOrEmpty(txtItemCode.Text))
            {
                ShowMessage("Please enter an Item Code.", false);
                if (upMain != null) upMain.Update();
                return;
            }

            if (IsItemCodeDuplicate(txtItemCode.Text, "0"))
            {
                ShowMessage("Item Code already exists. Please use a unique Item Code.", false);
                if (upMain != null) upMain.Update();
                return;
            }

            using (SqlConnection con = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GR_InsertItem", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ItemCode", txtItemCode.Text);
                cmd.Parameters.AddWithValue("@ItemName", txtItemName.Text);
                cmd.Parameters.AddWithValue("@CategoryID", ddlCategory.SelectedValue);
                cmd.Parameters.AddWithValue("@LocationID", ddlLocation.SelectedValue);
                cmd.Parameters.AddWithValue("@UnitPrice", decimal.Parse(txtUnitPrice.Text));
                cmd.Parameters.AddWithValue("@TaxPercentage", decimal.Parse(txtTaxPercentage.Text));
                cmd.Parameters.AddWithValue("@StockQty", int.Parse(txtStockQty.Text));
                cmd.Parameters.AddWithValue("@Description", txtDescription.Text);
                cmd.Parameters.Add(new SqlParameter("@NewItemID", SqlDbType.Int) { Direction = ParameterDirection.Output });
                
                con.Open();
                cmd.ExecuteNonQuery();
            }
            ShowMessage("Item saved successfully!", true);
            ClearForm();
            LoadItems();
            if (upMain != null) upMain.Update();
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtItemCode.Text))
            {
                ShowMessage("Please enter an Item Code.", false);
                if (upMain != null) upMain.Update();
                return;
            }

            if (IsItemCodeDuplicate(txtItemCode.Text, hfItemID.Value))
            {
                ShowMessage("Item Code already exists. Please use a unique Item Code.", false);
                if (upMain != null) upMain.Update();
                return;
            }

            using (SqlConnection con = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GR_UpdateItem", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ItemID", hfItemID.Value);
                cmd.Parameters.AddWithValue("@ItemCode", txtItemCode.Text);
                cmd.Parameters.AddWithValue("@ItemName", txtItemName.Text);
                cmd.Parameters.AddWithValue("@CategoryID", ddlCategory.SelectedValue);
                cmd.Parameters.AddWithValue("@LocationID", ddlLocation.SelectedValue);
                cmd.Parameters.AddWithValue("@UnitPrice", decimal.Parse(txtUnitPrice.Text));
                cmd.Parameters.AddWithValue("@TaxPercentage", decimal.Parse(txtTaxPercentage.Text));
                cmd.Parameters.AddWithValue("@StockQty", int.Parse(txtStockQty.Text));
                cmd.Parameters.AddWithValue("@Description", txtDescription.Text);
                cmd.Parameters.AddWithValue("@IsActive", ddlStatus.SelectedValue == "1");
                cmd.Parameters.Add(new SqlParameter("@RowsAffected", SqlDbType.Int) { Direction = ParameterDirection.Output });
                
                con.Open();
                cmd.ExecuteNonQuery();
            }
            ShowMessage("Item updated successfully!", true);
            ClearForm();
            LoadItems();
            if (upMain != null) upMain.Update();
        }

        protected void gvItems_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int itemID = int.Parse(e.CommandArgument.ToString());
            if (e.CommandName == "EditItem")
            {
                LoadItemForEdit(itemID);
                if (upMain != null) upMain.Update();
            }
            else if (e.CommandName == "DeleteItem")
            {
                try
                {
                    using (SqlConnection con = new SqlConnection(connStr))
                    using (SqlCommand cmd = new SqlCommand("sp_GR_DeleteItem", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@ItemID", itemID);
                        con.Open();
                        cmd.ExecuteNonQuery();
                    }
                    ShowMessage("Item deleted successfully!", true);
                }
                catch (Exception ex)
                {
                    ShowMessage("Error deleting item: " + ex.Message, false);
                }
                LoadItems();
                if (upMain != null) upMain.Update();
            }
        }

        private void LoadItemForEdit(int itemID)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("sp_GR_GetItemByID", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ItemID", itemID);
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    hfItemID.Value = dr["ItemID"].ToString();
                    txtItemCode.Text = dr["ItemCode"].ToString();
                    txtItemName.Text = dr["ItemName"].ToString();
                    txtUnitPrice.Text = dr["UnitPrice"].ToString();
                    txtTaxPercentage.Text = dr["TaxPercentage"].ToString();
                    txtStockQty.Text = dr["StockQty"].ToString();
                    txtDescription.Text = dr["Description"].ToString();
                    ddlCategory.SelectedValue = dr["CategoryID"].ToString();
                    ddlLocation.SelectedValue = dr["LocationID"].ToString();
                    ddlStatus.SelectedValue = Convert.ToBoolean(dr["IsActive"]) ? "1" : "0";
                    
                    btnSave.Visible = false;
                    btnUpdate.Visible = true;
                    lblFormTitle.Text = "Edit Item: " + txtItemName.Text;
                }
            }
        }

        protected void btnClear_Click(object sender, EventArgs e) 
        { 
            ClearForm(); 
            if (upMain != null) upMain.Update();
        }

        private void ClearForm()
        {
            hfItemID.Value = "0";
            txtItemCode.Text = "";
            txtItemName.Text = "";
            txtUnitPrice.Text = "0";
            txtTaxPercentage.Text = "16";
            txtStockQty.Text = "0";
            txtDescription.Text = "";
            ddlCategory.SelectedIndex = 0;
            ddlLocation.SelectedIndex = 0;
            ddlStatus.SelectedValue = "1";
            btnSave.Visible = true;
            btnUpdate.Visible = false;
            lblFormTitle.Text = "Add New Item";
        }

        protected void btnSearch_Click(object sender, EventArgs e) 
        { 
            LoadItems(txtSearch.Text); 
            if (upMain != null) upMain.Update();
        }

        protected void btnShowAll_Click(object sender, EventArgs e) 
        { 
            txtSearch.Text = ""; 
            LoadItems(); 
            if (upMain != null) upMain.Update();
        }

        private bool IsItemCodeDuplicate(string itemCode, string currentItemId)
        {
            bool isDuplicate = false;
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = "SELECT COUNT(1) FROM GR_Items WHERE ItemCode = @ItemCode AND ItemID <> @ItemID";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@ItemCode", itemCode);
                        cmd.Parameters.AddWithValue("@ItemID", currentItemId);
                        con.Open();
                        int count = Convert.ToInt32(cmd.ExecuteScalar());
                        if (count > 0) isDuplicate = true;
                    }
                }
            }
            catch { }
            return isDuplicate;
        }
        #endregion

        #region [ TAB 3: ORDER HISTORY ]
        private void LoadOrderHistory(string roomNo)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string resNo = Session["CurrentResNo"] as string;
                    string query = @"SELECT ServiceID, InvoiceNo, ServiceName, Qty, TotalAmount, OrderDate, Status 
                                   FROM GR_RoomServices 
                                   WHERE RoomNo = @RoomNo 
                                   AND ReservationNo = @ResNo
                                   AND ServiceName NOT LIKE 'Room Rent%' 
                                   AND ServiceName NOT LIKE 'GST%'
                                   ORDER BY OrderDate DESC";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@RoomNo", roomNo ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@ResNo", string.IsNullOrEmpty(resNo) ? (object)DBNull.Value : resNo);
                        DataTable dt = new DataTable();
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        con.Open();
                        da.Fill(dt);
                        if (gvHistory != null)
                        {
                            gvHistory.DataSource = dt;
                            gvHistory.DataBind();
                        }
                    }
                }
            }
            catch { }
        }

        protected void gvHistory_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int serviceId = Convert.ToInt32(gvHistory.DataKeys[e.RowIndex].Value);
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "DELETE FROM GR_RoomServices WHERE ServiceID = @ServiceID";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@ServiceID", serviceId);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            if (ddlRooms.SelectedValue != "0")
            {
                LoadOrderHistory(ddlRooms.SelectedValue);
                LoadPendingBalance(ddlRooms.SelectedValue);
            }
            if (upMain != null) upMain.Update();
        }

        protected void btnRefreshHistory_Click(object sender, EventArgs e)
        {
            if (ddlRooms.SelectedValue != "0") LoadOrderHistory(ddlRooms.SelectedValue);
        }
        #endregion

        #region [ TAB 4: LAUNDRY SERVICES ]
        private void LoadLaundryItems()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = @"SELECT i.ItemID, i.ItemCode, i.ItemName, i.UnitPrice, i.TaxPercentage 
                                   FROM GR_Items i 
                                   INNER JOIN GR_Categories c ON i.CategoryID = c.CategoryID 
                                   WHERE c.CategoryName = 'Laundry' AND i.IsActive = 1
                                   ORDER BY i.ItemName";
                    
                    DataTable dt = new DataTable();
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    con.Open();
                    da.Fill(dt);
                    
                    rptLaundry.DataSource = dt;
                    rptLaundry.DataBind();
                }
            }
            catch { }
        }

        private void LoadMiniBarItems()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = @"SELECT i.ItemID, i.ItemCode, i.ItemName, i.UnitPrice, i.TaxPercentage 
                                   FROM GR_Items i 
                                   INNER JOIN GR_Categories c ON i.CategoryID = c.CategoryID 
                                   WHERE c.CategoryName = 'Minibar' AND i.IsActive = 1
                                   ORDER BY i.ItemName";
                    
                    DataTable dt = new DataTable();
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    con.Open();
                    da.Fill(dt);
                    
                    rptServices.DataSource = dt;
                    rptServices.DataBind();
                }
            }
            catch { }
        }

        private void LoadLaundryPendingBalance(string roomNo)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string resNo = Session["CurrentResNo"] as string;
                    string query = @"SELECT ISNULL(SUM(rs.TotalAmount), 0) 
                                   FROM GR_RoomServices rs
                                   INNER JOIN GR_Items i ON rs.ServiceName = i.ItemName
                                   INNER JOIN GR_Categories c ON i.CategoryID = c.CategoryID
                                   WHERE rs.RoomNo = @RoomNo AND rs.ReservationNo = @ResNo AND rs.Status = 'Pending' AND c.CategoryName = 'Laundry'";
                    
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@RoomNo", roomNo ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@ResNo", string.IsNullOrEmpty(resNo) ? (object)DBNull.Value : resNo);
                        con.Open();
                        object result = cmd.ExecuteScalar();
                        if (lblLaundryPending != null) lblLaundryPending.Text = Convert.ToDecimal(result ?? 0).ToString("N0");
                    }
                }
            }
            catch { if (lblLaundryPending != null) lblLaundryPending.Text = "0"; }
        }
        #endregion

        private void ShowMessage(string msg, bool success)
        {
            lblMessage.Text = msg;
            lblMessage.Style["display"] = "block";
            lblMessage.CssClass = "alert " + (success ? "bg-success" : "bg-danger");
        }

        public class CartItem
        {
            public string name { get; set; }
            public decimal price { get; set; }
            public decimal tax { get; set; }
            public int qty { get; set; }
        }

        private void PostToLedger(string resNo, string roomNo, string refNo, string desc, decimal debit, decimal credit, SqlConnection con, SqlTransaction trans, int? subDeptId)
        {
            string sql = "INSERT INTO GR_GuestLedger (ReservationNo, RoomNo, RefNo, Description, Debit, Credit, TransDate, SubDeptID) VALUES (@Res, @Room, @Ref, @Desc, @Dr, @Cr, GETDATE(), @SubID)";
            using (SqlCommand cmd = new SqlCommand(sql, con, trans))
            {
                cmd.Parameters.AddWithValue("@Res", resNo);
                cmd.Parameters.AddWithValue("@Room", roomNo);
                cmd.Parameters.AddWithValue("@Ref", refNo);
                cmd.Parameters.AddWithValue("@Desc", desc);
                cmd.Parameters.AddWithValue("@Dr", debit);
                cmd.Parameters.AddWithValue("@Cr", credit);
                cmd.Parameters.AddWithValue("@SubID", (object)subDeptId ?? DBNull.Value);
                cmd.ExecuteNonQuery();
            }
        }
    }
}



