using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

public partial class Dashbord : System.Web.UI.Page
{
    private string cs
    {
        get
        {
            var s = ConfigurationManager.ConnectionStrings["MemberShipConnection"];
            return s != null ? s.ConnectionString : "";
        }
    }


    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["MemberId"] == null)
            Response.Redirect("~/MemberShipModule/Login.aspx");

        // Strict Role Check: Only Members allowed
        // Strict Role Check REMOVED

        if (!IsPostBack)
            LoadMember();
    }

    void LoadMember()
    {
        using (SqlConnection con = new SqlConnection(cs))
        using (SqlCommand cmd = new SqlCommand("SELECT * FROM Member WHERE MemberID=@id", con))
        {
            cmd.Parameters.AddWithValue("@id", Session["MemberId"]);
            con.Open();
            SqlDataReader dr = cmd.ExecuteReader();
            if (dr.Read())
            {
                lblName.Text = dr["ApplicantName"].ToString();
                lblMemberNo.Text = dr["MemberNo"].ToString();
                lblNIC.Text = dr["NIC"].ToString();
                lblDesignation.Text = dr["Designation"].ToString();
                lblMobile.Text = dr["Mobile"].ToString();
                lblEmail.Text = dr["Email"].ToString();
                lblMemberType.Text = dr["MemberType"].ToString();
                lblProfession.Text = dr["Profession"].ToString();

                if (dr["ApplicantPhotoPath"] != DBNull.Value)
                    imgPhoto.ImageUrl = ResolveUrl(dr["ApplicantPhotoPath"].ToString());
                else
                    imgPhoto.ImageUrl = "~/MemberShipModule/assets/images/user-placeholder.png";

                txtDesignation.Text = dr["Designation"].ToString();
                txtMobile.Text = dr["Mobile"].ToString();
                txtEmail.Text = dr["Email"].ToString();
                txtProfession.Text = dr["Profession"].ToString();

                // Save MemberNo in session if not already
                if (Session["MemberNo"] == null)
                    Session["MemberNo"] = dr["MemberNo"].ToString();
            }
        }
    }

    protected void btnProfile_Click(object sender, EventArgs e)
    {
        pnlProfile.Visible = true;
        pnlAdBilling.Visible = false;
    }

    protected void btnAdBilling_Click(object sender, EventArgs e)
    {
        pnlProfile.Visible = false;
        pnlAdBilling.Visible = true;
        LoadAdBilling();
    }

    void LoadAdBilling()
    {
        if (Session["MemberNo"] == null || Session["MemberId"] == null) return;

        string memberNo = Session["MemberNo"].ToString();
        string memberId = Session["MemberId"].ToString();
        lblMemberNo.Text = memberNo;

        string query = @"
        SELECT mp.MemberNo, m.ApplicantName, mp.Description, mp.Dept, mp.Credit
        FROM MemberPayment mp
        INNER JOIN Member m ON m.MemberID = mp.MemberNo
        WHERE m.MemberID = @MemberId";

        using (SqlConnection con = new SqlConnection(cs))
        using (SqlCommand cmd = new SqlCommand(query, con))
        {
            cmd.Parameters.AddWithValue("@MemberNo", memberNo);
            cmd.Parameters.AddWithValue("@MemberId", memberId);
            con.Open();

            DataTable dt = new DataTable();
            dt.Load(cmd.ExecuteReader());

            gvAdBilling.DataSource = dt;
            gvAdBilling.DataBind();
        }
    }

    protected void btn_records_Click(object sender, EventArgs e)
    {
        // 1?? Check session
        if (Session["MemberId"] == null) return;

        string memberNo = Session["MemberId"].ToString();
        if (string.IsNullOrEmpty(memberNo)) return;

        // 2?? Query
        string query = @"
       SELECT 
            b.MemberNo,
            b.Total,
            b.DepartmentName,
            bi.Name AS ItemName,
            bi.Price,
            bi.Quantity,
            CONVERT(date, bi.PrepTime) AS PrepDate, 
            b.Id AS BillId
       FROM Bills b
       INNER JOIN BillItems bi
           ON bi.BillId = b.Id
       WHERE b.MemberNo = @memberNo; 
    ";

        using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["RestaurantConnectionString"].ConnectionString))
        using (SqlCommand cmd = new SqlCommand(query, con))
        {
            cmd.Parameters.AddWithValue("@memberNo", memberNo); // match SQL param

            DataTable dt = new DataTable();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                da.Fill(dt);

            gvRecords.DataSource = dt;
            gvRecords.DataBind();
        }

        // 3?? Show modal
        string script = @"
        document.getElementById('recordsModal').style.display='flex';";
        ScriptManager.RegisterStartupScript(this, GetType(), "ShowModal", script, true);
    }


    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Response.Redirect("~/MemberShipModule/Login.aspx");
    }

    // Edit / Save
    protected void btnEdit_Click(object sender, EventArgs e) { pnlEdit.Visible = true; }
    protected void btnCancel_Click(object sender, EventArgs e) { pnlEdit.Visible = false; }
    protected void btnSave_Click(object sender, EventArgs e)
    {
        using (SqlConnection con = new SqlConnection(cs))
        {
            con.Open();
            SaveField(con, "Designation", txtDesignation.Text);
            SaveField(con, "Mobile", txtMobile.Text);
            SaveField(con, "Email", txtEmail.Text);
            SaveField(con, "Profession", txtProfession.Text);

            if (fuEditPhoto.HasFile)
            {
                string memberId = Session["MemberId"].ToString();
                string uploadDir = Server.MapPath("~/Uploads/Members/" + memberId + "/");
                if (!System.IO.Directory.Exists(uploadDir))
                    System.IO.Directory.CreateDirectory(uploadDir);

                string fileName = "Profile_" + DateTime.Now.ToString("yyyyMMddHHmmss") + System.IO.Path.GetExtension(fuEditPhoto.FileName);
                string filePath = System.IO.Path.Combine(uploadDir, fileName);
                fuEditPhoto.SaveAs(filePath);

                string relativePath = "~/Uploads/Members/" + memberId + "/" + fileName;

                SqlCommand imgCmd = new SqlCommand("UPDATE Member SET ApplicantPhotoPath=@path WHERE MemberID=@id", con);
                imgCmd.Parameters.AddWithValue("@path", relativePath);
                imgCmd.Parameters.AddWithValue("@id", memberId);
                imgCmd.ExecuteNonQuery();
            }
        }
        pnlEdit.Visible = false;
        LoadMember();
    }

    void SaveField(SqlConnection con, string field, string value)
    {
        string[] allowedFields = {
            "Designation","Nationality","Mobile","Email","MemberType","MaritalStatus","Profession","CompanyName",
            "MonthlyIncome","Currency","AddressType","City","Province","Country","ZipCode","Phone","AreaOfInterest"
        };
        if (Array.IndexOf(allowedFields, field) < 0) throw new Exception("Invalid field: " + field);

        string oldValue = "";
        using (SqlCommand cmdGet = new SqlCommand("SELECT [" + field + "] FROM Member WHERE MemberID=@id", con))
        {
            cmdGet.Parameters.AddWithValue("@id", Session["MemberId"]);
            object result = cmdGet.ExecuteScalar();
            oldValue = result == DBNull.Value ? "" : result.ToString();
        }

        string sql = "UPDATE Member SET [" + field + "] = @v WHERE MemberID = @id";
        using (SqlCommand cmd = new SqlCommand(sql, con))
        {
            cmd.Parameters.AddWithValue("@v", value ?? (object)DBNull.Value);
            cmd.Parameters.AddWithValue("@id", Session["MemberId"]);
            cmd.ExecuteNonQuery();
        }

        using (SqlCommand log = new SqlCommand(
            "INSERT INTO MemberUpdateLog(MemberID,MemberNo,FieldName,OldValue,NewValue,UpdatedBy,UpdatedAt) " +
            "VALUES(@id,@mno,@field,@old,@new,@by,GETDATE())", con))
        {
            log.Parameters.AddWithValue("@id", Session["MemberId"]);
            log.Parameters.AddWithValue("@mno", Session["MemberNo"]);
            log.Parameters.AddWithValue("@field", field);
            log.Parameters.AddWithValue("@old", oldValue);
            log.Parameters.AddWithValue("@new", value ?? (object)DBNull.Value);
            log.Parameters.AddWithValue("@by", Session["UserName"]);
            log.ExecuteNonQuery();
        }
    }
}


