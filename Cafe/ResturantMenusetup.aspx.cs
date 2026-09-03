using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Store_Add_Unit : System.Web.UI.Page
{
    string conString = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
    string conString1 = ConfigurationManager.ConnectionStrings["MemberShipConnection"].ConnectionString;
    string storeConnStr = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;
    string basicinfoConnStr = ConfigurationManager.ConnectionStrings["BasicDataInfoConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["Emp_Id"] == null)
            Response.Redirect("/Gymkhana.aspx");

        if (!IsPostBack)
        {
            InitializePage();
        }
        else
        {
            string itemCode = hdnItemCode.Value.Trim();
            if (!string.IsNullOrEmpty(itemCode))
                LoadSubDepartment();
        }
    }

    private void InitializePage()
    {
        LoadGrid();
        LoadCourses();
        LoadMealTypes();
        LoadSubDepartment();
        BindSubMenu();
        BindMealType();
        BindCourse();
        BindWeightUnit();
    }
    // =====================================================================
    //  LOAD ITEM — postback handler
    // =====================================================================
    protected void btnLoadItem_Click(object sender, EventArgs e)
    {
        ClearAllMessages();

        string itemCode = hdnItemCode.Value.Trim();
        if (string.IsNullOrEmpty(itemCode))
        {
            ShowMessage(lblGlobalMessage, "⚠ Please search and select an item from the list first.", false);
            return;
        }

        chkIsSpecial.Checked = GetItemStatusFromDB(itemCode) == 1;

        LoadSubDepartment();
        LoadSubDeptChecksAndPrices(itemCode);
        SetDropdownsFromDB(itemCode);
        LoadRecipeWeightAndPerPersonFromDB(itemCode);

        // Calculate live cost server-side and store in hidden field + badge label
        decimal serverLiveCost = GetLiveCostFromDB(itemCode);
        hdnLiveCost.Value = serverLiveCost.ToString("F2");
        lblServerLiveCost.Text = serverLiveCost.ToString("F2");

        pnlItemBadge.Visible = true;
        lblLoadedItem.Text = txtItem.Text.Trim();
        lblItemCode.Text = itemCode;

        ShowMessage(lblGlobalMessage, "✔ Item loaded: " + txtItem.Text.Trim(), true);
    }

    // =====================================================================
    //  Load Recipe Weight and Per Person from RecipeMain
    // =====================================================================
    private void LoadRecipeWeightAndPerPersonFromDB(string itemCode)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(storeConnStr))
            {
                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT TOP 1 
                        ISNULL(RecipeWeight, 0) AS RecipeWeight,
                        ISNULL(WeightUnit, '') AS WeightUnit,
                        ISNULL(PerPerson, 0) AS PerPerson
                      FROM RecipeMain
                      WHERE RecipeItemCode = @ItemCode", con))
                {
                    cmd.Parameters.AddWithValue("@ItemCode", itemCode);
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            decimal recipeWeight = dr["RecipeWeight"] != DBNull.Value ? Convert.ToDecimal(dr["RecipeWeight"]) : 0;
                            string weightUnit = dr["WeightUnit"] != DBNull.Value ? dr["WeightUnit"].ToString() : "";
                            decimal perPerson = dr["PerPerson"] != DBNull.Value ? Convert.ToDecimal(dr["PerPerson"]) : 0;

                            txtRecipeWeight.Text = recipeWeight > 0 ? recipeWeight.ToString("F2") : "";
                            txtPerPerson.Text = perPerson > 0 ? perPerson.ToString("F2") : "";

                            if (!string.IsNullOrEmpty(weightUnit) && ddlWeightUnit.Items.FindByValue(weightUnit) != null)
                                ddlWeightUnit.SelectedValue = weightUnit;
                            else
                                ddlWeightUnit.SelectedIndex = 0;
                        }
                    }
                }
            }
        }
        catch { }
    }

    // =====================================================================
    //  SERVER-SIDE live cost calculation
    // =====================================================================
    private decimal GetLiveCostFromDB(string itemCode)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(storeConnStr))
            {
                con.Open();

                // Read CostPerPortion directly — same value CreateRecipe saves
                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT TOP 1 ISNULL(CostPerPortion, 0) AS CostPerPortion
                  FROM RecipeMain
                  WHERE RecipeItemCode = @ItemCode", con))
                {
                    cmd.Parameters.AddWithValue("@ItemCode", itemCode);
                    object res = cmd.ExecuteScalar();
                    if (res != null && res != DBNull.Value)
                    {
                        decimal cpp = Convert.ToDecimal(res);
                        if (cpp > 0) return cpp;
                    }
                }

                // Fallback: calculate live if CostPerPortion not yet saved
                int recipeId = 0;
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT TOP 1 RecipeId FROM RecipeMain WHERE RecipeItemCode = @ItemCode", con))
                {
                    cmd.Parameters.AddWithValue("@ItemCode", itemCode);
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) recipeId = Convert.ToInt32(r);
                }
                if (recipeId == 0) return 0m;

                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT ISNULL(SUM(TotalCost), 0)
                  FROM RecipeSub
                  WHERE RecipeId = @RecipeId AND ISNULL(Active,1) = 1", con))
                {
                    cmd.Parameters.AddWithValue("@RecipeId", recipeId);
                    object res = cmd.ExecuteScalar();
                    return (res != null && res != DBNull.Value) ? Convert.ToDecimal(res) : 0m;
                }
            }
        }
        catch { return 0m; }
    }

    // =====================================================================
    //  Set dropdowns from saved MenuItems record
    // =====================================================================
    private void SetDropdownsFromDB(string itemCode)
    {
        BindSubMenu();
        BindMealType();
        BindCourse();

        int subMenuId = 0, mealTypeId = 0, courseId = 0;
        bool found = false;

        using (SqlConnection con = new SqlConnection(conString))
        {
            string query = @"
                SELECT TOP 1
                    ISNULL(SubMenuId,  0) AS SubMenuId,
                    ISNULL(MealTypeId, 0) AS MealTypeId,
                    ISNULL(CourseId,   0) AS CourseId
                FROM MenuItems
                WHERE ItemCode = @ItemCode AND Active = 1
                ORDER BY Id DESC";

            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@ItemCode", itemCode);
                con.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        found = true;
                        subMenuId = dr["SubMenuId"] != DBNull.Value ? Convert.ToInt32(dr["SubMenuId"]) : 0;
                        mealTypeId = dr["MealTypeId"] != DBNull.Value ? Convert.ToInt32(dr["MealTypeId"]) : 0;
                        courseId = dr["CourseId"] != DBNull.Value ? Convert.ToInt32(dr["CourseId"]) : 0;
                    }
                }
            }
        }

        if (found)
        {
            TrySelectDropdown(ddlSubMenu, subMenuId);
            TrySelectDropdown(ddlMealType, mealTypeId);
            TrySelectDropdown(ddlCourse, courseId);

            bool smLocked = (ddlSubMenu.SelectedValue != "0" && ddlSubMenu.SelectedValue != "");
            bool mtLocked = (ddlMealType.SelectedValue != "0" && ddlMealType.SelectedValue != "");
            bool crLocked = (ddlCourse.SelectedValue != "0" && ddlCourse.SelectedValue != "");

            hdnSubMenuLocked.Value = smLocked ? "1" : "0";
            hdnMealTypeLocked.Value = mtLocked ? "1" : "0";
            hdnCourseLocked.Value = crLocked ? "1" : "0";

            lblSubMenuStatus.Text = smLocked ? "✔ Loaded: " + ddlSubMenu.SelectedItem.Text : "⚠ Saved ID not found — please select";
            lblSubMenuStatus.CssClass = smLocked ? "ddl-status ok" : "ddl-status warn";

            lblMealTypeStatus.Text = mtLocked ? "✔ Loaded: " + ddlMealType.SelectedItem.Text : "⚠ Saved ID not found — please select";
            lblMealTypeStatus.CssClass = mtLocked ? "ddl-status ok" : "ddl-status warn";

            lblCourseStatus.Text = crLocked ? "✔ Loaded: " + ddlCourse.SelectedItem.Text : "⚠ Saved ID not found — please select";
            lblCourseStatus.CssClass = crLocked ? "ddl-status ok" : "ddl-status warn";
        }
        else
        {
            ddlSubMenu.SelectedIndex = 0;
            ddlMealType.SelectedIndex = 0;
            ddlCourse.SelectedIndex = 0;
            hdnSubMenuLocked.Value = "0";
            hdnMealTypeLocked.Value = "0";
            hdnCourseLocked.Value = "0";

            lblSubMenuStatus.Text = "ℹ New item — please select Sub Menu";
            lblSubMenuStatus.CssClass = "ddl-status warn";
            lblMealTypeStatus.Text = "ℹ New item — please select Meal Type";
            lblMealTypeStatus.CssClass = "ddl-status warn";
            lblCourseStatus.Text = "ℹ New item — please select Course";
            lblCourseStatus.CssClass = "ddl-status warn";
        }
    }

    private void TrySelectDropdown(DropDownList ddl, int id)
    {
        if (id <= 0) { ddl.SelectedIndex = 0; return; }
        ListItem item = ddl.Items.FindByValue(id.ToString());
        if (item != null) ddl.SelectedValue = id.ToString();
        else ddl.SelectedIndex = 0;
    }

    private int GetItemStatusFromDB(string itemCode)
    {
        using (SqlConnection con = new SqlConnection(conString))
        using (SqlCommand cmd = new SqlCommand(
            "SELECT Status FROM Restaurant_Catalog WHERE ItemCode = @ItemCode", con))
        {
            cmd.Parameters.AddWithValue("@ItemCode", itemCode);
            con.Open();
            object result = cmd.ExecuteScalar();
            return (result != null && result != DBNull.Value) ? Convert.ToInt32(result) : 1;
        }
    }

    // =====================================================================
    //  Load sub dept grid with saved Price/Cost/GST/Description
    // =====================================================================
    private void LoadSubDeptChecksAndPrices(string itemCode)
    {
        DataTable dtPrices = new DataTable();
        using (SqlConnection con = new SqlConnection(conString))
        {
            SqlDataAdapter da = new SqlDataAdapter(
                "SELECT DepartmentID, Price, Cost, GST, Description, OldPrice, OldGST FROM MenuItems WHERE ItemCode = @ItemCode AND Active = 1", con);
            da.SelectCommand.Parameters.AddWithValue("@ItemCode", itemCode);
            da.Fill(dtPrices);
        }
        ViewState["ItemPrices"] = dtPrices;
        LoadSubDepartmentWithPrices(itemCode, dtPrices);
    }

    private void LoadSubDepartmentWithPrices(string itemCode, DataTable dtPrices)
    {
        decimal liveCost = GetLiveCostFromDB(itemCode);

        DataTable dtDept = new DataTable();
        using (SqlConnection con = new SqlConnection(conString1))
        {
            SqlDataAdapter da = new SqlDataAdapter(
                "SELECT SubDept_Id, SubDept_Name FROM SubDepartment WHERE Dept_Id = 9 ORDER BY SubDept_Name", con);
            da.Fill(dtDept);
        }

        gvSubDept.DataSource = dtDept;
        gvSubDept.DataBind();

        foreach (GridViewRow row in gvSubDept.Rows)
        {
            if (row.RowType != DataControlRowType.DataRow) continue;

            int deptId = Convert.ToInt32(gvSubDept.DataKeys[row.RowIndex].Value);
            DataRow[] matches = dtPrices.Select("DepartmentID = " + deptId);

            CheckBox chk = (CheckBox)row.FindControl("chkSelect");
            TextBox txtP = (TextBox)row.FindControl("txtPrice");
            TextBox txto = (TextBox)row.FindControl("oldprice");
            TextBox txtC = (TextBox)row.FindControl("txtCost");
            TextBox txtG = (TextBox)row.FindControl("txtGST");
            TextBox txtD = (TextBox)row.FindControl("txtRowDescription");

            if (txtC != null) txtC.Text = liveCost.ToString("F2");

            if (matches.Length > 0)
            {
                DataRow dr = matches[0];
                if (chk != null) chk.Checked = true;
                if (txtP != null) txtP.Text = Convert.ToDecimal(dr["Price"]).ToString("F2");
                if (txto != null)
                    txto.Text = dr["OldPrice"] != DBNull.Value
                        ? Convert.ToDecimal(dr["OldPrice"]).ToString("F2")
                        : "";
                decimal gstVal = dr["GST"] != DBNull.Value ? Convert.ToDecimal(dr["GST"]) : 16m;
                if (txtG != null) txtG.Text = (gstVal > 0 ? gstVal : 16m).ToString("F0");
                if (txtD != null) txtD.Text = dr["Description"] != DBNull.Value ? dr["Description"].ToString() : "";
            }
            else
            {
                if (chk != null) chk.Checked = false;
                if (txtP != null) txtP.Text = "";
                if (txto != null) txto.Text = "";
                if (txtG != null) txtG.Text = "16";
                if (txtD != null) txtD.Text = "";
            }
        }
    }

    // =====================================================================
    //  SUB MENU Methods
    // =====================================================================
    #region Sub Menu Methods
    protected void btnSave_Click(object sender, EventArgs e)
    {
        ClearAllMessages();
        try
        {
            if (string.IsNullOrWhiteSpace(txtSubMenuName.Text))
            { ShowMessage(lblMessage, "⚠ Please enter Sub Menu Name", false); return; }

            string name = txtSubMenuName.Text.Trim();
            int empId = GetEmpId();

            using (SqlConnection con = new SqlConnection(conString))
            {
                con.Open();
                SqlCommand checkCmd = new SqlCommand("SELECT COUNT(*) FROM SubMenu WHERE SubMenu_Name = @Name", con);
                checkCmd.Parameters.AddWithValue("@Name", name);
                int count = (int)checkCmd.ExecuteScalar();

                if (count > 0)
                    ShowMessage(lblMessage, "❌ Sub Menu already exists: " + name, false);
                else
                {
                    SqlCommand insertCmd = new SqlCommand(
                        "INSERT INTO SubMenu (SubMenu_Name, Emp_Id) VALUES (@Name, @EmpId)", con);
                    insertCmd.Parameters.AddWithValue("@Name", name);
                    insertCmd.Parameters.AddWithValue("@EmpId", empId);
                    insertCmd.ExecuteNonQuery();
                    ShowMessage(lblMessage, "✅ Sub Menu added successfully!", true);
                    txtSubMenuName.Text = "";
                    LoadGrid();
                    BindSubMenu();
                }
            }
        }
        catch (Exception ex) { ShowMessage(lblMessage, "❌ Error: " + ex.Message, false); }
    }

    private void LoadGrid()
    {
        using (SqlConnection con = new SqlConnection(conString))
        {
            SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM SubMenu ORDER BY Id DESC", con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            gvSubMenu.DataSource = dt;
            gvSubMenu.DataBind();
        }
    }

    private void BindSubMenu()
    {
        using (SqlConnection con = new SqlConnection(conString))
        {
            string query = @"SELECT Id, SubMenu_Name,
                                CAST(Id AS VARCHAR) + ' - ' + SubMenu_Name AS DisplayText
                             FROM SubMenu ORDER BY SubMenu_Name";
            SqlDataAdapter da = new SqlDataAdapter(query, con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            ddlSubMenu.DataSource = dt;
            ddlSubMenu.DataTextField = "DisplayText";
            ddlSubMenu.DataValueField = "Id";
            ddlSubMenu.DataBind();
            ddlSubMenu.Items.Insert(0, new ListItem("-- Select Sub Menu --", "0"));
        }
    }
    #endregion

    // =====================================================================
    //  COURSE Methods
    // =====================================================================
    #region Course Methods
    protected void btnSaveCourse_Click(object sender, EventArgs e)
    {
        ClearAllMessages();
        try
        {
            if (string.IsNullOrWhiteSpace(txtCourseName.Text))
            { ShowMessage(lblCourseMessage, "⚠ Please enter Course Name", false); return; }

            string name = txtCourseName.Text.Trim();
            int empId = GetEmpId();

            using (SqlConnection con = new SqlConnection(conString))
            {
                con.Open();
                SqlCommand checkCmd = new SqlCommand("SELECT COUNT(*) FROM Courses WHERE Course_Name = @Name", con);
                checkCmd.Parameters.AddWithValue("@Name", name);
                int count = (int)checkCmd.ExecuteScalar();

                if (count > 0)
                    ShowMessage(lblCourseMessage, "❌ Course already exists: " + name, false);
                else
                {
                    SqlCommand insertCmd = new SqlCommand(
                        "INSERT INTO Courses (Course_Name, Emp_Id) VALUES (@Name, @EmpId)", con);
                    insertCmd.Parameters.AddWithValue("@Name", name);
                    insertCmd.Parameters.AddWithValue("@EmpId", empId);
                    insertCmd.ExecuteNonQuery();
                    ShowMessage(lblCourseMessage, "✅ Course added successfully!", true);
                    txtCourseName.Text = "";
                    LoadCourses();
                    BindCourse();
                }
            }
        }
        catch (Exception ex) { ShowMessage(lblCourseMessage, "❌ Error: " + ex.Message, false); }
    }

    private void LoadCourses()
    {
        using (SqlConnection con = new SqlConnection(conString))
        {
            SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM Courses ORDER BY Courseid ASC", con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            gvCourses.DataSource = dt;
            gvCourses.DataBind();
        }
    }

    private void BindCourse()
    {
        using (SqlConnection con = new SqlConnection(conString))
        {
            string query = @"SELECT Courseid AS Id, Course_Name,
                                CAST(Courseid AS VARCHAR) + ' - ' + Course_Name AS DisplayText
                             FROM Courses ORDER BY Course_Name";
            SqlDataAdapter da = new SqlDataAdapter(query, con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            ddlCourse.DataSource = dt;
            ddlCourse.DataTextField = "DisplayText";
            ddlCourse.DataValueField = "Id";
            ddlCourse.DataBind();
            ddlCourse.Items.Insert(0, new ListItem("-- Select Course --", "0"));
        }
    }
    #endregion

    // =====================================================================
    //  MEAL TYPE Methods
    // =====================================================================
    #region Meal Type Methods
    protected void btnSaveMealType_Click(object sender, EventArgs e)
    {
        ClearAllMessages();
        try
        {
            if (string.IsNullOrWhiteSpace(txtMealTypeName.Text))
            { ShowMessage(lblMealTypeMessage, "⚠ Please enter Meal Type Name", false); return; }

            string name = txtMealTypeName.Text.Trim();
            int empId = GetEmpId();

            using (SqlConnection con = new SqlConnection(conString))
            {
                con.Open();
                SqlCommand checkCmd = new SqlCommand("SELECT COUNT(*) FROM MealType WHERE MealType_Name = @Name", con);
                checkCmd.Parameters.AddWithValue("@Name", name);
                int count = (int)checkCmd.ExecuteScalar();

                if (count > 0)
                    ShowMessage(lblMealTypeMessage, "❌ Meal Type already exists: " + name, false);
                else
                {
                    SqlCommand insertCmd = new SqlCommand(
                        "INSERT INTO MealType (MealType_Name, Emp_Id) VALUES (@Name, @EmpId)", con);
                    insertCmd.Parameters.AddWithValue("@Name", name);
                    insertCmd.Parameters.AddWithValue("@EmpId", empId);
                    insertCmd.ExecuteNonQuery();
                    ShowMessage(lblMealTypeMessage, "✅ Meal Type added successfully!", true);
                    txtMealTypeName.Text = "";
                    LoadMealTypes();
                    BindMealType();
                }
            }
        }
        catch (Exception ex) { ShowMessage(lblMealTypeMessage, "❌ Error: " + ex.Message, false); }
    }

    private void LoadMealTypes()
    {
        using (SqlConnection con = new SqlConnection(conString))
        {
            SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM MealType ORDER BY Id DESC", con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            gvMealType.DataSource = dt;
            gvMealType.DataBind();
        }
    }

    private void BindMealType()
    {
        using (SqlConnection con = new SqlConnection(conString))
        {
            string query = @"SELECT Id, MealType_Name,
                                CAST(Id AS VARCHAR) + ' - ' + MealType_Name AS DisplayText
                             FROM MealType ORDER BY MealType_Name";
            SqlDataAdapter da = new SqlDataAdapter(query, con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            ddlMealType.DataSource = dt;
            ddlMealType.DataTextField = "DisplayText";
            ddlMealType.DataValueField = "Id";
            ddlMealType.DataBind();
            ddlMealType.Items.Insert(0, new ListItem("-- Select Meal Type --", "0"));
        }
    }
    #endregion

    // =====================================================================
    //  WEIGHT UNIT Bind
    // =====================================================================
    private void BindWeightUnit()
    {
        ddlWeightUnit.Items.Clear();
        ddlWeightUnit.Items.Add(new ListItem("-- Select Unit --", "0"));
        ddlWeightUnit.Items.Add(new ListItem("Grams (g)", "g"));
        ddlWeightUnit.Items.Add(new ListItem("Kilograms (kg)", "kg"));
        ddlWeightUnit.Items.Add(new ListItem("Milliliters (ml)", "ml"));
        ddlWeightUnit.Items.Add(new ListItem("Liters (L)", "L"));
        ddlWeightUnit.Items.Add(new ListItem("Ounces (oz)", "oz"));
        ddlWeightUnit.Items.Add(new ListItem("Pounds (lb)", "lb"));
        ddlWeightUnit.Items.Add(new ListItem("Piece(s)", "pcs"));
        ddlWeightUnit.Items.Add(new ListItem("Serving", "serving"));
    }

    // =====================================================================
    //  MENU ITEM Methods
    // =====================================================================
    #region Menu Item Methods

    private void LoadSubDepartment()
    {
        using (SqlConnection con = new SqlConnection(basicinfoConnStr))
        {
            SqlDataAdapter da = new SqlDataAdapter(
                "SELECT SubDept_Id, SubDept_Name FROM SubDepartment WHERE Dept_Id = 9 ORDER BY SubDept_Name", con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            gvSubDept.DataSource = dt;
            gvSubDept.DataBind();
        }
    }

    // =====================================================================
    //  WebMethod: GetItems — autocomplete
    // =====================================================================
    [System.Web.Services.WebMethod]
    [System.Web.Script.Services.ScriptMethod]
    public static List<string> GetItems(string prefixText)
    {
        List<string> items = new List<string>();
        string conStr = ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString;
        using (SqlConnection con = new SqlConnection(conStr))
        {
            string query = @"SELECT ItemCode, ItemName FROM Restaurant_Catalog
                             WHERE ItemName LIKE @Search + '%' OR ItemCode LIKE @Search + '%'
                             ORDER BY ItemName";
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@Search", prefixText);
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                while (dr.Read())
                    items.Add(dr["ItemName"].ToString() + " (" + dr["ItemCode"].ToString() + ")|" + dr["ItemCode"].ToString());
            }
        }
        return items;
    }

    // =====================================================================
    //  WebMethod: GetItemLiveCost with Recipe Weight and Per Person
    // =====================================================================
    [System.Web.Services.WebMethod]
    public static object GetItemLiveCost(string itemCode)
    {
        try
        {
            string storeConn = ConfigurationManager.ConnectionStrings["STOREConnectionString"].ConnectionString;

            using (SqlConnection con = new SqlConnection(storeConn))
            {
                con.Open();

                int recipeId = 0;
                decimal costPerPortion = 0, overheadPct = 0, inflationPct = 0;
                decimal recipeWeight = 0;
                string weightUnit = "";
                decimal perPerson = 0;
                decimal sellingPrice = 0;

                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT TOP 1 
                    RecipeId,
                    ISNULL(CostPerPortion, 0)  AS CostPerPortion,
                    ISNULL(OverheadPct,    0)  AS OverheadPct,
                    ISNULL(InflationPct,   0)  AS InflationPct,
                    ISNULL(OverheadValue,  0)  AS OverheadValue,
                    ISNULL(InflationValue, 0)  AS InflationValue,
                    ISNULL(TotalCost,      0)  AS TotalCost,
                    ISNULL(SellingPrice,   0)  AS SellingPrice,
                    ISNULL(RecipeWeight,   0)  AS RecipeWeight,
                    ISNULL(WeightUnit,    '')  AS WeightUnit,
                    ISNULL(PerPerson,      0)  AS PerPerson
                  FROM RecipeMain
                  WHERE RecipeItemCode = @ItemCode", con))
                {
                    cmd.Parameters.AddWithValue("@ItemCode", itemCode);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (!dr.Read())
                            return new
                            {
                                success = false,
                                message = "No recipe found for this item. Please add recipe first.",
                                hasRecipe = false
                            };

                        recipeId = Convert.ToInt32(dr["RecipeId"]);
                        costPerPortion = Convert.ToDecimal(dr["CostPerPortion"]);
                        overheadPct = Convert.ToDecimal(dr["OverheadPct"]);
                        inflationPct = Convert.ToDecimal(dr["InflationPct"]);
                        sellingPrice = Convert.ToDecimal(dr["SellingPrice"]);
                        recipeWeight = Convert.ToDecimal(dr["RecipeWeight"]);
                        weightUnit = dr["WeightUnit"].ToString();
                        perPerson = Convert.ToDecimal(dr["PerPerson"]);
                    }
                }

                if (recipeId == 0)
                    return new { success = false, message = "No recipe found for this item", hasRecipe = false };

                // ── breakdown from RecipeSub by Category_Type ──────────────────
                decimal ingTotal = 0, garnishTotal = 0,
                        toppingTotal = 0, wastageTotal = 0;
                var ingredientDetails = new List<object>();

                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT ItemCode, ItemName,
                         ISNULL(Quantity,  0) AS Quantity,
                         ISNULL(BaseCost,  0) AS BaseCost,
                         ISNULL(TotalCost, 0) AS TotalCost,
                         ISNULL(Unit,     '') AS Unit,
                         ISNULL(Category_Type, 1) AS Category_Type
                  FROM RecipeSub
                  WHERE RecipeId = @RecipeId
                    AND ISNULL(Active, 1) = 1
                  ORDER BY Category_Type, ItemName", con))
                {
                    cmd.Parameters.AddWithValue("@RecipeId", recipeId);
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            int catType = Convert.ToInt32(dr["Category_Type"]);
                            decimal qty = Convert.ToDecimal(dr["Quantity"]);
                            decimal baseCost = Convert.ToDecimal(dr["BaseCost"]);
                            decimal totCost = Convert.ToDecimal(dr["TotalCost"]);
                            string catLabel = catType == 2 ? "Garnish"
                                             : catType == 3 ? "Topping"
                                             : catType == 4 ? "Wastage"
                                             : "Ingredient";

                            switch (catType)
                            {
                                case 2: garnishTotal += totCost; break;
                                case 3: toppingTotal += totCost; break;
                                case 4: wastageTotal += totCost; break;
                                default: ingTotal += totCost; break;
                            }

                            ingredientDetails.Add(new
                            {
                                name = dr["ItemName"].ToString(),
                                category = catLabel,
                                quantity = Math.Round(qty, 4),
                                rate = Math.Round(baseCost, 4),
                                cost = Math.Round(totCost, 4)
                            });
                        }
                    }
                }

                decimal grandTotal = ingTotal + garnishTotal + toppingTotal + wastageTotal;
                decimal ohValue = Math.Round(grandTotal * overheadPct / 100, 4);
                decimal infValue = Math.Round(grandTotal * inflationPct / 100, 4);
                // Use saved CostPerPortion from RecipeMain (matches CreateRecipe page exactly)
                // Fall back to live-calculated value if not yet saved
                decimal displayCost = costPerPortion > 0
                                       ? costPerPortion
                                       : Math.Round(grandTotal + ohValue + infValue, 4);

                decimal recipeCostPct = sellingPrice > 0
                                        ? Math.Round(displayCost / sellingPrice * 100, 1)
                                        : 0;

                return new
                {
                    success = true,
                    hasRecipe = true,
                    liveCost = Math.Round(displayCost, 2),   // ← now = Cost Per Portion
                    grandTotal = Math.Round(grandTotal, 2),
                    overheadValue = Math.Round(ohValue, 2),
                    inflationValue = Math.Round(infValue, 2),
                    overheadPct = overheadPct,
                    inflationPct = inflationPct,
                    sellingPrice = Math.Round(sellingPrice, 2),
                    recipeCostPct = recipeCostPct,
                    gstAmount = Math.Round(displayCost * 0.16m, 2),
                    totalWithTax = Math.Round(displayCost * 1.16m, 2),
                    gstPercentage = 16,
                    recipeWeight = Math.Round(recipeWeight, 2),
                    weightUnit = weightUnit,
                    perPerson = Math.Round(perPerson, 2),
                    breakdown = new
                    {
                        ingredients = Math.Round(ingTotal, 2),
                        garnish = Math.Round(garnishTotal, 2),
                        topping = Math.Round(toppingTotal, 2),
                        wastage = Math.Round(wastageTotal, 2),
                        overheadValue = Math.Round(ohValue, 2),
                        inflationValue = Math.Round(infValue, 2),
                        ingredientCount = ingredientDetails.Count
                    },
                    ingredientsList = ingredientDetails
                };
            }
        }
        catch (Exception ex)
        {
            return new { success = false, message = "Error: " + ex.Message, hasRecipe = false };
        }
    }
    // =====================================================================
    //  SAVE MENU ITEMS
    // =====================================================================
    protected void btnSaveMenuItems_Click(object sender, EventArgs e)
    {
        ClearAllMessages();
        try
        {
            string itemCode = hdnItemCode.Value.Trim();
            string itemName = txtItem.Text.Trim();

            if (string.IsNullOrEmpty(itemCode))
            { ShowMessage(lblGlobalMessage, "⚠ Please search and select an item first", false); return; }

            int subMenuId = 0, mealTypeId = 0, courseId = 0;
            int.TryParse(ddlSubMenu.SelectedValue, out subMenuId);
            int.TryParse(ddlMealType.SelectedValue, out mealTypeId);
            int.TryParse(ddlCourse.SelectedValue, out courseId);

            string subMenuName = (subMenuId > 0 && ddlSubMenu.SelectedItem != null) ? ddlSubMenu.SelectedItem.Text : "";
            string mealTypeName = (mealTypeId > 0 && ddlMealType.SelectedItem != null) ? ddlMealType.SelectedItem.Text : "";
            string courseName = (courseId > 0 && ddlCourse.SelectedItem != null) ? ddlCourse.SelectedItem.Text : "";

            if (subMenuId <= 0) { ShowMessage(lblGlobalMessage, "⚠ Please select a valid Sub Menu", false); return; }
            if (mealTypeId <= 0) { ShowMessage(lblGlobalMessage, "⚠ Please select a valid Meal Type", false); return; }
            if (courseId <= 0) { ShowMessage(lblGlobalMessage, "⚠ Please select a valid Course", false); return; }

            // Get Recipe Weight and Per Person from UI
            decimal recipeWeight = 0;
            string weightUnit = "";
            decimal perPerson = 0;

            if (!string.IsNullOrEmpty(txtRecipeWeight.Text))
                decimal.TryParse(txtRecipeWeight.Text, out recipeWeight);

            if (ddlWeightUnit != null && ddlWeightUnit.SelectedValue != "0")
                weightUnit = ddlWeightUnit.SelectedValue;

            if (!string.IsNullOrEmpty(txtPerPerson.Text))
                decimal.TryParse(txtPerPerson.Text, out perPerson);

            int recipeId = GetRecipeIdFromItemCode(itemCode);
            int empId = GetEmpId();
            int insertCount = 0, updateCount = 0, deleteCount = 0;

            decimal liveCost = GetLiveCostFromDB(itemCode);

            using (SqlConnection con = new SqlConnection(conString))
            {
                con.Open();
                foreach (GridViewRow row in gvSubDept.Rows)
                {
                    if (row.RowType != DataControlRowType.DataRow) continue;

                    int departmentId = Convert.ToInt32(gvSubDept.DataKeys[row.RowIndex].Value);
                    CheckBox chk = (CheckBox)row.FindControl("chkSelect");
                    if (chk == null) continue;

                    bool isChecked = (Request.Form[chk.UniqueID] != null);

                    TextBox ctrlPrice = (TextBox)row.FindControl("txtPrice");
                    TextBox ctrlGST = (TextBox)row.FindControl("txtGST");
                    TextBox ctrlDesc = (TextBox)row.FindControl("txtRowDescription");

                    string priceStr = ctrlPrice != null ? (Request.Form[ctrlPrice.UniqueID] ?? "").Trim() : "0";
                    string gstStr = ctrlGST != null ? (Request.Form[ctrlGST.UniqueID] ?? "").Trim() : "";
                    string desc = ctrlDesc != null ? (Request.Form[ctrlDesc.UniqueID] ?? "").Trim() : "";

                    if (isChecked)
                    {
                        decimal price = 0m, gst = 16m;
                        decimal.TryParse(priceStr, out price);
                        decimal parsedGST = 0m;
                        if (!string.IsNullOrEmpty(gstStr) && decimal.TryParse(gstStr, out parsedGST) && parsedGST > 0)
                            gst = parsedGST;

                        int existingId = 0;
                        decimal oldPrice = 0m, oldGST = 0m;
                        bool recordExists = false;

                        using (SqlConnection conRead = new SqlConnection(conString))
                        {
                            conRead.Open();
                            using (SqlCommand checkCmd = new SqlCommand(
                                "SELECT Id, Price, GST FROM MenuItems WHERE ItemCode = @ItemCode AND DepartmentID = @DeptId AND Active = 1", conRead))
                            {
                                checkCmd.Parameters.AddWithValue("@ItemCode", itemCode);
                                checkCmd.Parameters.AddWithValue("@DeptId", departmentId);
                                using (SqlDataReader dr = checkCmd.ExecuteReader())
                                {
                                    if (dr.Read())
                                    {
                                        recordExists = true;
                                        existingId = Convert.ToInt32(dr["Id"]);
                                        oldPrice = Convert.ToDecimal(dr["Price"]);
                                        oldGST = dr["GST"] != DBNull.Value ? Convert.ToDecimal(dr["GST"]) : 0m;
                                    }
                                }
                            }
                        }

                        if (recordExists)
                        {
                            using (SqlCommand updateCmd = new SqlCommand(@"
                                UPDATE MenuItems SET
                                    Price         = @Price,
                                    Cost          = @Cost,
                                    GST           = @GST,
                                    Description   = @Description,
                                    Active        = 1,
                                    SubMenuId     = @SubMenuId,
                                    SubMenu_Name  = @SubMenuName,
                                    MealTypeId    = @MealTypeId,
                                    MealType_Name = @MealTypeName,
                                    CourseId      = @CourseId,
                                    Course_Name   = @CourseName,
                                    RecipeId      = @RecipeId,
                                    RecipeWeight  = @RecipeWeight,
                                    WeightUnit    = @WeightUnit,
                                    PerPerson     = @PerPerson,
                                    OldPrice      = @OldPrice,
                                    OldGST        = @OldGST,
                                    LastModifiedBy = @LastModifiedBy,
                                    LastModifiedDate = GETDATE()
                                WHERE Id = @Id", con))
                            {
                                updateCmd.Parameters.AddWithValue("@Price", price);
                                updateCmd.Parameters.AddWithValue("@Cost", liveCost);
                                updateCmd.Parameters.AddWithValue("@GST", gst);
                                updateCmd.Parameters.AddWithValue("@Description", desc);
                                updateCmd.Parameters.AddWithValue("@SubMenuId", subMenuId);
                                updateCmd.Parameters.AddWithValue("@SubMenuName", subMenuName);
                                updateCmd.Parameters.AddWithValue("@MealTypeId", mealTypeId);
                                updateCmd.Parameters.AddWithValue("@MealTypeName", mealTypeName);
                                updateCmd.Parameters.AddWithValue("@CourseId", courseId);
                                updateCmd.Parameters.AddWithValue("@CourseName", courseName);
                                updateCmd.Parameters.AddWithValue("@RecipeId", recipeId);
                                updateCmd.Parameters.AddWithValue("@RecipeWeight", recipeWeight > 0 ? recipeWeight : (object)DBNull.Value);
                                updateCmd.Parameters.AddWithValue("@WeightUnit", !string.IsNullOrEmpty(weightUnit) ? weightUnit : (object)DBNull.Value);
                                updateCmd.Parameters.AddWithValue("@PerPerson", perPerson > 0 ? perPerson : (object)DBNull.Value);
                                updateCmd.Parameters.AddWithValue("@OldPrice", oldPrice);
                                updateCmd.Parameters.AddWithValue("@OldGST", oldGST);
                                updateCmd.Parameters.AddWithValue("@LastModifiedBy", empId);
                                updateCmd.Parameters.AddWithValue("@Id", existingId);
                                updateCmd.ExecuteNonQuery();
                            }
                            InsertLog(con, itemCode, departmentId, oldPrice, price, oldGST, gst, "Update", empId);
                            updateCount++;
                        }
                        else
                        {
                            using (SqlCommand insertCmd = new SqlCommand(@"
                                INSERT INTO MenuItems
                                    (ItemCode, ItemName, Price, Category, Cost, GST, Description, Active,
                                     SavedBy, DepartmentID, SubMenuId, SubMenu_Name, MealTypeId,
                                     MealType_Name, CourseId, Course_Name, RecipeId, RecipeWeight, WeightUnit, PerPerson,
                                     OldPrice, OldGST, LastModifiedBy, LastModifiedDate)
                                VALUES
                                    (@ItemCode, @ItemName, @Price, 'Services', @Cost, @GST, @Description, 1,
                                     @SavedBy, @DeptId, @SubMenuId, @SubMenuName, @MealTypeId,
                                     @MealTypeName, @CourseId, @CourseName, @RecipeId, @RecipeWeight, @WeightUnit, @PerPerson,
                                     0, 0, @SavedBy, GETDATE())", con))
                            {
                                insertCmd.Parameters.AddWithValue("@ItemCode", itemCode);
                                insertCmd.Parameters.AddWithValue("@ItemName", itemName);
                                insertCmd.Parameters.AddWithValue("@Price", price);
                                insertCmd.Parameters.AddWithValue("@Cost", liveCost);
                                insertCmd.Parameters.AddWithValue("@GST", gst);
                                insertCmd.Parameters.AddWithValue("@Description", desc);
                                insertCmd.Parameters.AddWithValue("@SavedBy", empId);
                                insertCmd.Parameters.AddWithValue("@DeptId", departmentId);
                                insertCmd.Parameters.AddWithValue("@SubMenuId", subMenuId);
                                insertCmd.Parameters.AddWithValue("@SubMenuName", subMenuName);
                                insertCmd.Parameters.AddWithValue("@MealTypeId", mealTypeId);
                                insertCmd.Parameters.AddWithValue("@MealTypeName", mealTypeName);
                                insertCmd.Parameters.AddWithValue("@CourseId", courseId);
                                insertCmd.Parameters.AddWithValue("@CourseName", courseName);
                                insertCmd.Parameters.AddWithValue("@RecipeId", recipeId);
                                insertCmd.Parameters.AddWithValue("@RecipeWeight", recipeWeight > 0 ? recipeWeight : (object)DBNull.Value);
                                insertCmd.Parameters.AddWithValue("@WeightUnit", !string.IsNullOrEmpty(weightUnit) ? weightUnit : (object)DBNull.Value);
                                insertCmd.Parameters.AddWithValue("@PerPerson", perPerson > 0 ? perPerson : (object)DBNull.Value);
                                insertCmd.ExecuteNonQuery();
                            }
                            InsertLog(con, itemCode, departmentId, 0, price, 0, gst, "Insert", empId);
                            insertCount++;
                        }
                    }
                    else
                    {
                        int existingId = 0; decimal oldPrice = 0m, oldGST = 0m; bool found = false;
                        using (SqlConnection conRead = new SqlConnection(conString))
                        {
                            conRead.Open();
                            using (SqlCommand selCmd = new SqlCommand(
                                "SELECT Id, Price, GST FROM MenuItems WHERE ItemCode = @ItemCode AND DepartmentID = @DeptId AND Active = 1", conRead))
                            {
                                selCmd.Parameters.AddWithValue("@ItemCode", itemCode);
                                selCmd.Parameters.AddWithValue("@DeptId", departmentId);
                                using (SqlDataReader dr = selCmd.ExecuteReader())
                                {
                                    if (dr.Read())
                                    {
                                        found = true;
                                        existingId = Convert.ToInt32(dr["Id"]);
                                        oldPrice = Convert.ToDecimal(dr["Price"]);
                                        oldGST = dr["GST"] != DBNull.Value ? Convert.ToDecimal(dr["GST"]) : 0m;
                                    }
                                }
                            }
                        }
                        if (found)
                        {
                            using (SqlCommand deactivateCmd = new SqlCommand(
                                "UPDATE MenuItems SET Active = 0, OldPrice = @OldPrice, OldGST = @OldGST, LastModifiedBy = @LastModifiedBy, LastModifiedDate = GETDATE() WHERE Id = @Id", con))
                            {
                                deactivateCmd.Parameters.AddWithValue("@Id", existingId);
                                deactivateCmd.Parameters.AddWithValue("@OldPrice", oldPrice);
                                deactivateCmd.Parameters.AddWithValue("@OldGST", oldGST);
                                deactivateCmd.Parameters.AddWithValue("@LastModifiedBy", empId);
                                deactivateCmd.ExecuteNonQuery();
                            }
                            InsertLog(con, itemCode, departmentId, oldPrice, oldPrice, oldGST, oldGST, "Deactivate", empId);
                            deleteCount++;
                        }
                    }
                }
            }

            var parts = new List<string>();
            if (insertCount > 0) parts.Add(insertCount + " inserted");
            if (updateCount > 0) parts.Add(updateCount + " updated");
            if (deleteCount > 0) parts.Add(deleteCount + " deactivated");

            ShowMessage(lblGlobalMessage,
                parts.Count > 0
                    ? "✅ Saved: " + string.Join(", ", parts)
                    : "ℹ No changes were made",
                parts.Count > 0);

            string savedItemCode = hdnItemCode.Value.Trim();
            if (!string.IsNullOrEmpty(savedItemCode))
            {
                LoadSubDeptChecksAndPrices(savedItemCode);
                SetDropdownsFromDB(savedItemCode);
                LoadRecipeWeightAndPerPersonFromDB(savedItemCode);
                decimal lc = GetLiveCostFromDB(savedItemCode);
                hdnLiveCost.Value = lc.ToString("F2");
                lblServerLiveCost.Text = lc.ToString("F2");
            }
        }
        catch (Exception ex)
        {
            ShowMessage(lblGlobalMessage, "❌ Error saving: " + ex.Message, false);
        }
    }

    private int GetRecipeIdFromItemCode(string itemCode)
    {
        int recipeId = 0;
        try
        {
            using (SqlConnection con = new SqlConnection(storeConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT TOP 1 RecipeId FROM RecipeMain WHERE RecipeItemCode = @ItemCode", con))
            {
                cmd.Parameters.AddWithValue("@ItemCode", itemCode);
                con.Open();
                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                    recipeId = Convert.ToInt32(result);
            }
        }
        catch { }
        return recipeId;
    }

    protected void chkIsSpecial_CheckedChanged(object sender, EventArgs e)
    {
        ClearAllMessages();
        try
        {
            string itemCode = hdnItemCode.Value.Trim();
            if (string.IsNullOrEmpty(itemCode))
            { ShowMessage(lblGlobalMessage, "⚠ Please select an item first", false); chkIsSpecial.Checked = false; return; }

            UpdateCatalogStatus(itemCode, chkIsSpecial.Checked ? 1 : 0);

            string currentItem = hdnItemCode.Value.Trim();
            if (!string.IsNullOrEmpty(currentItem))
                LoadSubDeptChecksAndPrices(currentItem);

            ShowMessage(lblGlobalMessage,
                chkIsSpecial.Checked
                    ? "✅ Item activated — click Save to apply"
                    : "⚠ Item deactivated — click Save to deactivate",
                chkIsSpecial.Checked);
        }
        catch (Exception ex) { ShowMessage(lblGlobalMessage, "❌ Error: " + ex.Message, false); }
    }

    private void UpdateCatalogStatus(string itemCode, int status)
    {
        using (SqlConnection con = new SqlConnection(conString))
        using (SqlCommand cmd = new SqlCommand(
            "UPDATE Restaurant_Catalog SET Status = @Status WHERE ItemCode = @ItemCode", con))
        {
            cmd.Parameters.AddWithValue("@ItemCode", itemCode);
            cmd.Parameters.AddWithValue("@Status", status);
            con.Open();
            cmd.ExecuteNonQuery();
        }
    }
    #endregion

    // =====================================================================
    //  ITEM GROUP
    // =====================================================================
    #region Item Group
    protected void btnSaveGroup_Click(object sender, EventArgs e)
    {
        ClearAllMessages();
        try
        {
            using (SqlConnection con = new SqlConnection(conString))
            using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO ItemGroup (GroupCode, Description, Unit, IsActive, Emp_Id)
                VALUES (@GroupCode, @Description, @Unit, @IsActive, @Emp_Id)", con))
            {
                cmd.Parameters.AddWithValue("@GroupCode", txtGroupCode.Text.Trim());
                cmd.Parameters.AddWithValue("@Description", txtDescription.Text.Trim());
                cmd.Parameters.AddWithValue("@Unit", ddlUnit.SelectedValue);
                cmd.Parameters.AddWithValue("@IsActive", chkActive.Checked ? 1 : 0);
                cmd.Parameters.AddWithValue("@Emp_Id", GetEmpId());
                con.Open();
                cmd.ExecuteNonQuery();
            }
            ShowMessage(lblGlobalMessage, "✅ Item Group saved successfully!", true);
            ClearGroupForm();
        }
        catch (Exception ex) { ShowMessage(lblGlobalMessage, "❌ Error saving Item Group: " + ex.Message, false); }
    }

    private void ClearGroupForm()
    {
        txtGroupCode.Text = "";
        txtDescription.Text = "";
        ddlUnit.SelectedIndex = 0;
        chkActive.Checked = true;
    }
    #endregion

    // =====================================================================
    //  HELPERS
    // =====================================================================
    #region Helper Methods
    private int GetEmpId()
    {
        object raw = Session["Emp_ID"] ?? Session["Emp_Id"];
        int id = 0;
        if (raw != null && int.TryParse(raw.ToString(), out id)) return id;
        return 0;
    }

    private void ShowMessage(Label lbl, string message, bool isSuccess)
    {
        lbl.Text = message;
        lbl.CssClass = isSuccess ? "success-message" : "error-message";
    }

    private void ClearAllMessages()
    {
        foreach (var lbl in new[] { lblGlobalMessage, lblMessage, lblCourseMessage, lblMealTypeMessage })
        {
            lbl.Text = "";
            lbl.CssClass = "message";
        }
    }

    private static void InsertLog(SqlConnection con, string itemCode, int departmentId,
        decimal oldPrice, decimal newPrice, decimal oldGST, decimal newGST, string actionType, int empId)
    {
        try
        {
            SqlCommand logCmd = new SqlCommand(@"
                INSERT INTO MenuItemChangeLog
                    (ItemCode, DepartmentID, OldPrice, NewPrice, OldGST, NewGST, ActionType, ChangedBy, ChangeDate)
                VALUES
                    (@ItemCode, @DepartmentID, @OldPrice, @NewPrice, @OldGST, @NewGST, @ActionType, @ChangedBy, GETDATE())", con);
            logCmd.Parameters.AddWithValue("@ItemCode", itemCode);
            logCmd.Parameters.AddWithValue("@DepartmentID", departmentId);
            logCmd.Parameters.AddWithValue("@OldPrice", oldPrice);
            logCmd.Parameters.AddWithValue("@NewPrice", newPrice);
            logCmd.Parameters.AddWithValue("@OldGST", oldGST);
            logCmd.Parameters.AddWithValue("@NewGST", newGST);
            logCmd.Parameters.AddWithValue("@ActionType", actionType);
            logCmd.Parameters.AddWithValue("@ChangedBy", empId);
            logCmd.ExecuteNonQuery();
        }
        catch { }
    }
    #endregion

    protected void btnViewReport_Click(object sender, EventArgs e)
    {
        string itemCode = hdnItemCode.Value;

        if (string.IsNullOrEmpty(itemCode))
        {
            lblGlobalMessage.Text = "Please load an item first before generating report.";
            lblGlobalMessage.CssClass = "error-message";
            return;
        }

        // Store item code in session
        Session["ReportItemCode"] = itemCode;

        // Redirect to the report page
        Response.Redirect("Menuitemsreport.aspx");
    }
}

