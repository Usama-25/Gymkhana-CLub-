using System;
using System.Configuration;
using System.Data;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
namespace GuestRoomApp.GuestRoomM
{
    public partial class RoomDefinition : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["GuestRoomDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindGrid();
                ToggleFields(false);
                BindFloorFilter();
            }
        }

        protected void SwitchTab(object sender, EventArgs e)
        {
            var btn = (System.Web.UI.WebControls.Button)sender;
            mvRoom.ActiveViewIndex = int.Parse(btn.CommandArgument);
            if (mvRoom.ActiveViewIndex == 1)
            {
                BindGrid();
            }
        }

        protected void txtRent_TextChanged(object sender, EventArgs e)
        {
            CalculateTaxAndTotal();
        }

        protected void ddlRentType_SelectedIndexChanged(object sender, EventArgs e)
        {
            decimal rate = 0;
            switch (ddlRentType.SelectedValue)
            {
                case "Single": rate = 11500; break;
                case "Double": rate = 13100; break;
                case "Single Foreigner": rate = 15000; break;
                case "Double Foreigner": rate = 16000; break;
                case "Single Affiliated": rate = 11500; break;
                case "Double Affiliated": rate = 13100; break;
                case "Single Delux": rate = 12500; break;
                case "Double Delux": rate = 14100; break;
                case "Single Foreigner Delux": rate = 16000; break;
                case "Double Foreigner Delux": rate = 17000; break;
                case "Single Affiliated Delux": rate = 12500; break;
                case "Double Affiliated Delux": rate = 14100; break;
            }

            if (rate > 0)
            {
                txtRent.Text = rate.ToString("0.00");
                CalculateTaxAndTotal();
            }
        }

        private void CalculateTaxAndTotal()
        {
            decimal rent = 0;

            if (decimal.TryParse(txtRent.Text, out rent))
            {
                decimal taxPer = 16; // FIXED 16%
                decimal taxAmt = (rent * taxPer) / 100;

                txtTaxPer.Text = "16";
                txtTaxAmt.Text = taxAmt.ToString("0.00");
                txtTotalRent.Text = (rent + taxAmt).ToString("0.00");
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                // Validation
                if (string.IsNullOrWhiteSpace(txtRoomNo.Text))
                {
                    ShowAlert("Please enter Room Number");
                    return;
                }

                // Check for duplicate room number (only for new rooms, not for modify)
                string editMode = ViewState["EditMode"] as string;
                if (editMode != "Modify")
                {
                    if (IsRoomNoExists(txtRoomNo.Text.Trim()))
                    {
                        ShowAlert("Room Number already exists! Please use a different room number.");
                        return;
                    }
                }

                decimal rent = 0;
                int cap = 0;

                decimal.TryParse(txtRent.Text, out rent);
                int.TryParse(txtCapacity.Text, out cap);

                if (rent <= 0)
                {
                    ShowAlert("Please enter valid rent amount");
                    return;
                }

                if (cap <= 0)
                {
                    ShowAlert("Please enter valid capacity");
                    return;
                }

                decimal taxPer = Convert.ToDecimal(txtTaxPer.Text);
                decimal taxAmt = (rent * taxPer) / 100;
                decimal total = rent + taxAmt;

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string sql = @"IF EXISTS (SELECT 1 FROM RoomDefinitionNew WHERE RoomNo = @RoomNo)
                           UPDATE RoomDefinitionNew SET 
                           Description=@Desc,
                           Location=@Loc,
                           RoomType=@Type,
                           RentType=@RentType,
                           FloorNo=@Floor,
                           Capacity=@Cap,
                           Rent=@Rent,
                           TaxPercentage=@TaxP,
                           TaxAmount=@TaxA,
                           TotalRent=@Total,
                           Status=@Status,
                           IsAC=@AC,
                           IsBathroom=@Bath,
                           BedType=@Bed
                           WHERE RoomNo=@RoomNo
                           ELSE
                           INSERT INTO RoomDefinitionNew 
                           (RoomNo, Description, Location, RoomType, RentType, FloorNo, Capacity, Rent, TaxPercentage, TaxAmount, TotalRent, Status, IsAC, IsBathroom, BedType)
                           VALUES 
                           (@RoomNo, @Desc, @Loc, @Type, @RentType, @Floor, @Cap, @Rent, @TaxP, @TaxA, @Total, @Status, @AC, @Bath, @Bed)";

                    SqlCommand cmd = new SqlCommand(sql, conn);

                    cmd.Parameters.AddWithValue("@RoomNo", txtRoomNo.Text.Trim());
                    cmd.Parameters.AddWithValue("@Desc", txtDescription.Text.Trim());
                    cmd.Parameters.AddWithValue("@Loc", ddlLocation.SelectedValue);
                    cmd.Parameters.AddWithValue("@Type", ddlRoomType.SelectedValue);
                    cmd.Parameters.AddWithValue("@RentType", ddlRentType.SelectedValue);
                    cmd.Parameters.AddWithValue("@Floor", ddlFloor.SelectedValue);
                    cmd.Parameters.AddWithValue("@Cap", cap);
                    cmd.Parameters.AddWithValue("@Rent", rent);
                    cmd.Parameters.AddWithValue("@TaxP", taxPer);
                    cmd.Parameters.AddWithValue("@TaxA", taxAmt);
                    cmd.Parameters.AddWithValue("@Total", total);
                    cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);
                    cmd.Parameters.AddWithValue("@AC", chkAC.Checked);
                    cmd.Parameters.AddWithValue("@Bath", chkBathroom.Checked);
                    cmd.Parameters.AddWithValue("@Bed", ddlBedType.SelectedValue);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                BindGrid();
                ToggleFields(false);
                ClearFields();
                mvRoom.ActiveViewIndex = 1;
                ShowAlert("Room saved successfully!");
            }
            catch (Exception ex)
            {
                ShowAlert("Error: " + ex.Message);
            }
        }

        private bool IsRoomNoExists(string roomNo)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "SELECT COUNT(*) FROM RoomDefinitionNew WHERE RoomNo = @RoomNo";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@RoomNo", roomNo);
                conn.Open();
                int count = Convert.ToInt32(cmd.ExecuteScalar());
                return count > 0;
            }
        }

        protected void ddlFilterFloor_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindGridWithFilter();
        }

        protected void ddlLocation_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateFloorDropdown();

            // Only auto-generate room number in ADD mode, not in MODIFY mode
            string editMode = ViewState["EditMode"] as string;
            if (editMode != "Modify" && !string.IsNullOrEmpty(ddlLocation.SelectedValue) && ddlFloor.Items.Count > 1)
            {
                txtRoomNo.Text = GenerateRoomNo();
            }
        }

        protected void ddlFloor_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Only auto-generate room number in ADD mode, not in MODIFY mode
            string editMode = ViewState["EditMode"] as string;
            if (editMode != "Modify" && !string.IsNullOrEmpty(ddlLocation.SelectedValue) && ddlFloor.SelectedIndex > 0)
            {
                txtRoomNo.Text = GenerateRoomNo();
            }
        }

        private void PopulateFloorDropdown()
        {
            ddlFloor.Items.Clear();
            ddlFloor.Items.Add(new ListItem("Select Floor", ""));
            ddlFloor.Items.Add(new ListItem("Ground", "Ground"));
            ddlFloor.Items.Add(new ListItem("1st Floor", "1st Floor"));
        }

        private void PopulateFloorDropdownWithSelectedValue(string selectedFloor)
        {
            PopulateFloorDropdown();

            // Set the selected value
            if (!string.IsNullOrEmpty(selectedFloor))
            {
                ListItem item = ddlFloor.Items.FindByText(selectedFloor);
                if (item != null)
                {
                    item.Selected = true;
                }
            }
        }

        private string GenerateRoomNo()
        {
            // Get next available numeric room number (001, 002...)
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "SELECT RoomNo FROM RoomDefinitionNew ORDER BY RoomNo";
                SqlDataAdapter da = new SqlDataAdapter(query, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);

                var existingNumbers = new HashSet<int>();

                foreach (DataRow row in dt.Rows)
                {
                    string roomNo = row.Field<string>("RoomNo");
                    int roomNumber;
                    if (int.TryParse(roomNo, out roomNumber))
                    {
                        existingNumbers.Add(roomNumber);
                    }
                }

                for (int i = 1; i <= 500; i++)
                {
                    if (!existingNumbers.Contains(i))
                    {
                        return i.ToString("D3");
                    }
                }

                return (existingNumbers.Count + 1).ToString("D3");
            }
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            ClearFields();
            ToggleFields(true);
            mvRoom.ActiveViewIndex = 0;
            txtRoomNo.Focus();
            txtRoomNo.Text = GenerateRoomNo();
            ViewState["EditMode"] = "Add";
            txtRoomNo.ReadOnly = false;
            txtRoomNo.Enabled = true;
            txtRoomNo.BackColor = System.Drawing.Color.White;

            // Reset dropdowns
            ddlLocation.SelectedIndex = 0;
            ddlRentType.SelectedIndex = 0;
            ddlFloor.Items.Clear();
            ddlFloor.Items.Add(new ListItem("Select Location First", ""));
        }

        protected void btnModify_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtRoomNo.Text))
            {
                ShowAlert("Please select a room to modify from the list");
                return;
            }
            ToggleFields(true);
            txtRoomNo.ReadOnly = true;
            txtRoomNo.Enabled = true;
            txtRoomNo.BackColor = System.Drawing.Color.LightGray;
            ViewState["EditMode"] = "Modify";
            mvRoom.ActiveViewIndex = 0;

            // Make sure floor dropdown is populated based on selected location
            if (!string.IsNullOrEmpty(ddlLocation.SelectedValue))
            {
                // Get the current floor value
                string currentFloor = ddlFloor.SelectedValue;
                // Repopulate floor dropdown
                PopulateFloorDropdownWithSelectedValue(currentFloor);
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ClearFields();
            ToggleFields(false);
            mvRoom.ActiveViewIndex = 1;
            ViewState["EditMode"] = null;
        }

        protected void gvRooms_SelectedIndexChanged(object sender, EventArgs e)
        {
            GridViewRow row = gvRooms.SelectedRow;
            string roomNo = gvRooms.DataKeys[row.RowIndex].Value.ToString();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "SELECT * FROM RoomDefinitionNew WHERE RoomNo = @RoomNo";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@RoomNo", roomNo);
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    txtRoomNo.Text = reader["RoomNo"].ToString();
                    txtDescription.Text = reader["Description"].ToString();

                    string location = reader["Location"].ToString();
                    ddlLocation.ClearSelection();
                    if (ddlLocation.Items.FindByText(location) != null)
                        ddlLocation.Items.FindByText(location).Selected = true;

                    PopulateFloorDropdownWithSelectedValue(reader["FloorNo"].ToString());

                    string roomType = reader["RoomType"].ToString();
                    ddlRoomType.ClearSelection();
                    if (ddlRoomType.Items.FindByText(roomType) != null)
                        ddlRoomType.Items.FindByText(roomType).Selected = true;

                    string rentType = reader["RentType"].ToString();
                    ddlRentType.ClearSelection();
                    if (ddlRentType.Items.FindByText(rentType) != null)
                        ddlRentType.Items.FindByText(rentType).Selected = true;

                    txtCapacity.Text = reader["Capacity"].ToString();

                    string status = reader["Status"].ToString();
                    ddlStatus.ClearSelection();
                    if (ddlStatus.Items.FindByText(status) != null)
                        ddlStatus.Items.FindByText(status).Selected = true;

                    txtRent.Text = reader["Rent"].ToString();
                    txtTaxPer.Text = reader["TaxPercentage"].ToString();
                    txtTaxAmt.Text = reader["TaxAmount"].ToString();
                    txtTotalRent.Text = reader["TotalRent"].ToString();

                    chkAC.Checked = reader["IsAC"] != DBNull.Value ? Convert.ToBoolean(reader["IsAC"]) : false;
                    chkBathroom.Checked = reader["IsBathroom"] != DBNull.Value ? Convert.ToBoolean(reader["IsBathroom"]) : false;

                    string bedType = reader["BedType"].ToString();
                    ddlBedType.ClearSelection();
                    if (ddlBedType.Items.FindByText(bedType) != null)
                        ddlBedType.Items.FindByText(bedType).Selected = true;
                }
                reader.Close();
            }

            ViewState["EditMode"] = "Modify";
            mvRoom.ActiveViewIndex = 0;
            ToggleFields(true);
            txtRoomNo.ReadOnly = true;
            txtRoomNo.BackColor = System.Drawing.Color.LightGray;
        }

        private void BindGrid()
        {
            BindGridWithFilter();
        }

        private void BindGridWithFilter()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string baseQuery = @"SELECT RoomNo, Description, Location, RoomType, RentType, FloorNo, 
                               Capacity, Status, Rent, TaxPercentage, TotalRent 
                               FROM RoomDefinitionNew";

                string orderBy = @" ORDER BY 
                               CASE 
                                   WHEN ISNUMERIC(RoomNo) = 1 THEN CAST(RoomNo AS INT)
                                   ELSE 9999
                               END, RoomNo";

                SqlCommand cmd = new SqlCommand();
                string finalQuery = baseQuery;

                if (!string.IsNullOrEmpty(ddlFilterFloor.SelectedValue) && ddlFilterFloor.SelectedValue != "All Floors")
                {
                    finalQuery += " WHERE FloorNo = @Floor";
                    cmd.Parameters.AddWithValue("@Floor", ddlFilterFloor.SelectedValue);
                }

                finalQuery += orderBy;
                cmd.CommandText = finalQuery;
                cmd.Connection = conn;

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvRooms.DataSource = dt;
                gvRooms.DataBind();
            }
        }

        private void BindFloorFilter()
        {
            ddlFilterFloor.Items.Clear();
            ddlFilterFloor.Items.Add(new ListItem("All Floors", ""));
            ddlFilterFloor.Items.Add(new ListItem("Ground", "Ground"));
            ddlFilterFloor.Items.Add(new ListItem("1st Floor", "1st Floor"));
        }

        private void ToggleFields(bool enabled)
        {
            txtRoomNo.Enabled = enabled;
            txtDescription.Enabled = enabled;
            txtRent.Enabled = enabled;
            ddlRoomType.Enabled = enabled;
            ddlRentType.Enabled = enabled;
            ddlLocation.Enabled = enabled;
            ddlFloor.Enabled = enabled;
            txtCapacity.Enabled = enabled;
            ddlStatus.Enabled = enabled;
            chkAC.Enabled = enabled;
            chkBathroom.Enabled = enabled;
            ddlBedType.Enabled = enabled;
            btnSave.Enabled = enabled;
        }

        private void ClearFields()
        {
            txtRoomNo.Text = "";
            txtDescription.Text = "";
            txtRent.Text = "";
            txtTaxAmt.Text = "";
            txtTotalRent.Text = "";
            txtCapacity.Text = "";
            txtTaxPer.Text = "16";

            ddlLocation.SelectedIndex = 0;
            ddlRoomType.SelectedIndex = 0;
            ddlRentType.SelectedIndex = 0;
            ddlStatus.SelectedIndex = 0;
            ddlBedType.SelectedIndex = 0;
            ddlFloor.Items.Clear();
            ddlFloor.Items.Add(new ListItem("Select Location First", ""));

            chkAC.Checked = true;
            chkBathroom.Checked = false;
            txtRoomNo.ReadOnly = false;
            txtRoomNo.BackColor = System.Drawing.Color.White;
            ViewState["EditMode"] = null;
        }
        protected string GetRoomStatusStyle(string status)
        {
            switch (status.ToUpper())
            {
                case "AVAILABLE":
                    return "background:#e8f5e9; color:#2e7d32; border:1px solid #c8e6c9; padding:3px 10px; border-radius:99px; font-size:.71rem; font-weight:700; white-space:nowrap;";
                case "OCCUPIED":
                    return "background:#e3f2fd; color:#1565C0; border:1px solid #90caf9; padding:3px 10px; border-radius:99px; font-size:.71rem; font-weight:700; white-space:nowrap;";
                case "MAINTENANCE":
                    return "background:#fff3e0; color:#e65100; border:1px solid #ffcc80; padding:3px 10px; border-radius:99px; font-size:.71rem; font-weight:700; white-space:nowrap;";
                default:
                    return "background:#f1f5f9; color:#64748b; border:1px solid #cbd5e1; padding:3px 10px; border-radius:99px; font-size:.71rem; font-weight:700; white-space:nowrap;";
            }
        }
        protected void btnUpdateCategoryRates_Click(object sender, EventArgs e)
        {
            try
            {
                string roomType = ddlRoomType.SelectedValue;
                string rentType = ddlRentType.SelectedValue;

                if (string.IsNullOrEmpty(roomType) && string.IsNullOrEmpty(rentType))
                {
                    ShowAlert("Please select a Room Type or Rent Type to update category rates.");
                    return;
                }

                decimal rent = 0;
                if (!decimal.TryParse(txtRent.Text, out rent) || rent <= 0)
                {
                    ShowAlert("Please enter a valid Rent amount.");
                    return;
                }

                decimal taxPer = 16;
                decimal taxAmt = (rent * taxPer) / 100;
                decimal total = rent + taxAmt;

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string sql = @"UPDATE RoomDefinitionNew SET 
                               Rent = @Rent, 
                               TaxAmount = @TaxA, 
                               TotalRent = @Total 
                               WHERE 1=1 ";

                    if (!string.IsNullOrEmpty(roomType)) sql += " AND RoomType = @Type ";
                    if (!string.IsNullOrEmpty(rentType)) sql += " AND RentType = @RentType ";

                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@Rent", rent);
                    cmd.Parameters.AddWithValue("@TaxA", taxAmt);
                    cmd.Parameters.AddWithValue("@Total", total);

                    if (!string.IsNullOrEmpty(roomType)) cmd.Parameters.AddWithValue("@Type", roomType);
                    if (!string.IsNullOrEmpty(rentType)) cmd.Parameters.AddWithValue("@RentType", rentType);

                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        BindGrid();
                        string filterMsg = "";
                        if (!string.IsNullOrEmpty(roomType) && !string.IsNullOrEmpty(rentType)) filterMsg = roomType + " + " + rentType;
                        else if (!string.IsNullOrEmpty(roomType)) filterMsg = roomType;
                        else filterMsg = rentType;

                        ShowAlert("Successfully updated rates for " + rowsAffected + " " + filterMsg + " rooms.");
                    }
                    else
                    {
                        ShowAlert("No rooms found matching the selected criteria.");
                    }
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Error: " + ex.Message);
            }
        }

        private void ShowAlert(string message)
        {
            string script = "<script>alert('" + message.Replace("'", "\\'") + "');</script>";
            ClientScript.RegisterStartupScript(this.GetType(), "Alert", script);
        }
    }
}



