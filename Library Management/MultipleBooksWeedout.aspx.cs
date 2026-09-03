using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;

namespace GymkhanaLibrary
{
    public partial class MultipleBooksWeedout : System.Web.UI.Page
    {
        public string AlertCssClass { get; set; }

        private short CurrentStaffID
        {
            get
            {
                if (Session["StaffID"] != null)
                    return Convert.ToInt16(Session["StaffID"]);
                return 1;
            }
        }

        // Stores selected books in ViewState as a DataTable
        private DataTable SelectedBooks
        {
            get
            {
                if (ViewState["SelectedBooks"] == null)
                {
                    var dt = new DataTable();
                    dt.Columns.Add("BookID", typeof(int));
                    dt.Columns.Add("CopyID", typeof(int));
                    dt.Columns.Add("CopyBookNo", typeof(int));
                    dt.Columns.Add("Barcode", typeof(string));
                    dt.Columns.Add("ISBN13", typeof(string));
                    dt.Columns.Add("Title", typeof(string));
                    dt.Columns.Add("TotalCopies", typeof(int));
                    dt.Columns.Add("AvailableCopies", typeof(int));
                    dt.Columns.Add("LoanStatus", typeof(string));
                    dt.Columns.Add("CanWeed", typeof(bool));
                    ViewState["SelectedBooks"] = dt;
                }
                return (DataTable)ViewState["SelectedBooks"];
            }
            set { ViewState["SelectedBooks"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            if (!IsPostBack)
            {
                // In case a BookID is passed via QueryString, add it directly
                if (Request.QueryString["BookID"] != null)
                {
                    int bookID;
                    if (int.TryParse(Request.QueryString["BookID"], out bookID))
                        AddBookToList(bookID);
                }
            }
        }

        protected void btnAddCopy_Click(object sender, EventArgs e)
        {
            string term = txtCopyBookNo.Text.Trim();
            if (string.IsNullOrEmpty(term))
            {
                ShowAlert("Please enter a copy book number.", "alert-error");
                return;
            }

            int bookNo;
            if (!int.TryParse(term, out bookNo))
            {
                ShowAlert("Invalid book number. Please enter a valid number.", "alert-error");
                return;
            }

            AddCopyToList(bookNo);
        }

        protected void rdoSearchMode_CheckedChanged(object sender, EventArgs e)
        {
            pnlSearchTitleBlock.Visible = rdoSearchTitle.Checked;
            pnlAddCopyBlock.Visible = rdoAddCopy.Checked;
            
            if (rdoSearchTitle.Checked)
            {
                txtCopyBookNo.Text = "";
            }
            else
            {
                txtSearchBook.Text = "";
                pnlSearchResults.Visible = false;
            }
        }

        private void AddCopyToList(int bookNo)
        {
            try
            {
                DataTable dt = DBHelper.GetTableData(
                    @"SELECT bc.CopyID, bc.BookNo, bc.Barcode, bc.CondID, bc.IsAvailable, b.BookID, b.ISBN13, b.Title
                      FROM BookCopies bc
                      INNER JOIN Books b ON bc.BookID = b.BookID
                      WHERE bc.BookNo = @BookNo AND b.IsActive = 1",
                    new SqlParameter("@BookNo", bookNo));

                if (dt == null || dt.Rows.Count == 0)
                {
                    ShowAlert("Copy with Book No " + bookNo + " not found or its book is inactive.", "alert-error");
                    return;
                }

                DataRow r = dt.Rows[0];
                int bookID = Convert.ToInt32(r["BookID"]);
                int copyID = Convert.ToInt32(r["CopyID"]);

                if (Convert.ToInt32(r["CondID"]) == 7)
                {
                    ShowAlert("This copy is already weeded out.", "alert-error");
                    return;
                }

                DataTable sel = SelectedBooks;
                // Check if this copy is already in list
                if (sel.Rows.Cast<DataRow>().Any(row => row["CopyID"] != DBNull.Value && Convert.ToInt32(row["CopyID"]) == copyID))
                {
                    ShowAlert("This copy is already in the weeding list.", "alert-error");
                    return;
                }

                // Check if the entire book is already in list
                if (sel.Select("BookID = " + bookID + " AND CopyID IS NULL").Length > 0)
                {
                    ShowAlert("The entire book is already in the weeding list.", "alert-error");
                    return;
                }

                // Check active loans
                DataTable loans = DBHelper.GetTableData(
                    "SELECT TOP 1 1 FROM Loans WHERE CopyID = @CopyID AND StatusID = 1",
                    new SqlParameter("@CopyID", copyID));
                bool hasActiveLoan = loans.Rows.Count > 0;

                string loanStatus;
                bool canWeed;
                if (hasActiveLoan)
                {
                    loanStatus = "On Loan (cannot weed)";
                    canWeed = false;
                }
                else
                {
                    loanStatus = "Available â€“ can weed";
                    canWeed = true;
                }

                DataRow newRow = sel.NewRow();
                newRow["BookID"] = bookID;
                newRow["CopyID"] = copyID;
                newRow["CopyBookNo"] = Convert.ToInt32(r["BookNo"]);
                newRow["Barcode"] = r["Barcode"].ToString();
                newRow["ISBN13"] = r["ISBN13"].ToString();
                newRow["Title"] = r["Title"].ToString();
                newRow["TotalCopies"] = 1;
                newRow["AvailableCopies"] = hasActiveLoan ? 0 : 1;
                newRow["LoanStatus"] = loanStatus;
                newRow["CanWeed"] = canWeed;
                sel.Rows.Add(newRow);
                SelectedBooks = sel;

                BindSelectedBooksGrid();
                pnlSelectedBooks.Visible = true;
                txtCopyBookNo.Text = "";
                ShowAlert("Copy added to weeding list.", "alert-success");
            }
            catch (Exception ex)
            {
                ShowAlert("Error adding copy: " + ex.Message, "alert-error");
            }
        }

        protected void btnSearchBook_Click(object sender, EventArgs e)
        {
            string term = txtSearchBook.Text.Trim();
            if (term.Contains(" ["))
                term = term.Split(new string[] { " [" }, StringSplitOptions.None)[0].Trim();
            if (string.IsNullOrEmpty(term))
            {
                ShowAlert("Please enter a book title or ISBN to search.", "alert-error");
                return;
            }
            BindBooksGrid(term);
        }

        private void BindBooksGrid(string term)
        {
            try
            {
                int? bookNo = null;
                int parsedNo;
                if (int.TryParse(term, out parsedNo))
                {
                    bookNo = parsedNo;
                }
                DataTable dt = GymkhanaLibrary.MultipleBooksWeedout.DBHelper.SearchBooks(term, null, null, null, null, null, false, null, null, null, null, bookNo);
                gvBooks.DataSource = dt;
                gvBooks.DataBind();
                pnlSearchResults.Visible = true;
            }
            catch (Exception ex)
            {
                ShowAlert("Error searching books: " + ex.Message, "alert-error");
            }
        }

        protected void gvBooks_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvBooks.PageIndex = e.NewPageIndex;
            BindBooksGrid(txtSearchBook.Text.Trim());
        }

        protected void gvBooks_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "AddBook")
            {
                int bookID = Convert.ToInt32(e.CommandArgument);
                AddBookToList(bookID);
            }
        }

        private void AddBookToList(int bookID)
        {
            DataTable sel = SelectedBooks;
            if (sel.Select("BookID = " + bookID).Length > 0)
            {
                ShowAlert("This book is already in the weeding list.", "alert-error");
                return;
            }

            try
            {
                DataSet ds = DBHelper.GetBookDetail(bookID);
                if (ds == null || ds.Tables[0].Rows.Count == 0)
                {
                    ShowAlert("Book details could not be loaded.", "alert-error");
                    return;
                }
                DataRow r = ds.Tables[0].Rows[0];
                // Get copy stats
                DataTable copies = DBHelper.GetBookCopiesForWeeding(bookID);
                int totalCopies = copies.Rows.Count;
                int availableCopies = copies.AsEnumerable().Count(c => Convert.ToInt32(c["CondID"]) != 7 && Convert.ToBoolean(c["IsAvailable"]));
                bool hasActiveLoan = CheckBookHasActiveLoan(bookID);

                string loanStatus;
                bool canWeed;
                if (hasActiveLoan)
                {
                    loanStatus = "On Loan (cannot weed)";
                    canWeed = false;
                }
                else
                {
                    loanStatus = "All available – can weed";
                    canWeed = true;
                }

                DataRow newRow = sel.NewRow();
                newRow["BookID"] = bookID;
                newRow["ISBN13"] = r["ISBN13"].ToString();
                newRow["Title"] = r["Title"].ToString();
                newRow["TotalCopies"] = totalCopies;
                newRow["AvailableCopies"] = availableCopies;
                newRow["LoanStatus"] = loanStatus;
                newRow["CanWeed"] = canWeed;
                sel.Rows.Add(newRow);
                SelectedBooks = sel;

                BindSelectedBooksGrid();
                pnlSelectedBooks.Visible = true;
                ShowAlert("Book added to weeding list.", "alert-success");
            }
            catch (Exception ex)
            {
                ShowAlert("Error adding book: " + ex.Message, "alert-error");
            }
        }

        private bool CheckBookHasActiveLoan(int bookID)
        {
            DataTable loans = DBHelper.GetTableData(
                @"SELECT TOP 1 1 FROM BookCopies bc 
                  INNER JOIN Loans l ON bc.CopyID = l.CopyID 
                  WHERE bc.BookID = @BookID AND l.StatusID = 1",
                new SqlParameter("@BookID", bookID));
            return loans.Rows.Count > 0;
        }

        private void BindSelectedBooksGrid()
        {
            gvSelectedBooks.DataSource = SelectedBooks;
            gvSelectedBooks.DataBind();
        }

        protected void gvSelectedBooks_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "RemoveBook")
            {
                int bookID = Convert.ToInt32(e.CommandArgument);
                DataTable sel = SelectedBooks;
                DataRow[] rows = sel.Select("BookID = " + bookID);
                if (rows.Length > 0)
                {
                    sel.Rows.Remove(rows[0]);
                    SelectedBooks = sel;
                    BindSelectedBooksGrid();
                    if (sel.Rows.Count == 0)
                        pnlSelectedBooks.Visible = false;
                    ShowAlert("Book removed from list.", "alert-success");
                }
            }
        }

        protected void btnWeedAllSelected_Click(object sender, EventArgs e)
        {
            DataTable sel = SelectedBooks;
            if (sel.Rows.Count == 0)
            {
                ShowAlert("No books selected for weeding.", "alert-error");
                return;
            }

            List<int> successBooks = new List<int>();
            List<string> failedBooks = new List<string>();
            string remarks = "Bulk weeding from multiple books page"; // could add remarks input, but not required per spec

            foreach (DataRow row in sel.Rows)
            {
                int bookID = (int)row["BookID"];
                bool canWeed = (bool)row["CanWeed"];
                if (!canWeed)
                {
                    failedBooks.Add(row["Title"].ToString() + " (has active loans)");
                    continue;
                }

                try
                {
                    if (row["CopyID"] != DBNull.Value)
                    {
                        // Weed only this specific copy
                        int copyID = (int)row["CopyID"];
                        string res = DBHelper.WeedSingleCopy(copyID, remarks, CurrentStaffID);
                        if (res.StartsWith("SUCCESS"))
                        {
                            successBooks.Add(bookID);
                        }
                        else
                        {
                            failedBooks.Add(row["Title"].ToString() + " (Copy " + row["CopyBookNo"] + ") - " + res);
                        }
                    }
                    else
                    {
                        // Weed all copies of this book
                        string res = DBHelper.WeedFullBook(bookID, remarks, CurrentStaffID);
                        if (res.StartsWith("SUCCESS"))
                        {
                            // Deactivate the book
                            DBHelper.ExecuteSql("UPDATE Books SET IsActive = 0 WHERE BookID = " + bookID);
                            successBooks.Add(bookID);
                        }
                        else
                        {
                            failedBooks.Add(row["Title"].ToString() + " - " + res);
                        }
                    }
                }
                catch (Exception ex)
                {
                    failedBooks.Add(row["Title"].ToString() + " - " + ex.Message);
                }
            }

            // Refresh selected list: keep only failed books (those that still exist and could not be weeded)
            DataTable remaining = SelectedBooks.Clone();
            foreach (DataRow row in sel.Rows)
            {
                int bookID = (int)row["BookID"];
                if (!successBooks.Contains(bookID) && failedBooks.Any(f => f.Contains(row["Title"].ToString())))
                {
                    // still in list, keep it
                    remaining.ImportRow(row);
                }
            }
            SelectedBooks = remaining;
            BindSelectedBooksGrid();
            pnlSelectedBooks.Visible = remaining.Rows.Count > 0;

            string message = "";
            if (successBooks.Count > 0)
                message += string.Format("{0} book(s) successfully weeded out. ", successBooks.Count);
            if (failedBooks.Count > 0)
                message += string.Format("{0} book(s) failed: ", failedBooks.Count) + string.Join("; ", failedBooks);
            if (message == "")
                message = "No books processed.";

            ShowAlert(message, successBooks.Count > 0 && failedBooks.Count == 0 ? "alert-success" : "alert-error");
        }

        private void ShowAlert(string msg, string cssClass)
        {
            lblAlert.Text = msg;
            AlertCssClass = cssClass;
            pnlAlert.Visible = true;
            pnlAlert.DataBind();
        }

        // ----------------------------------------------------------------
        // Nested DBHelper class (identical to the one in the existing Weedout page)
        // ----------------------------------------------------------------
        #region Nested Helper Classes (DBHelper)

        public static class DBHelper
        {
            private static string ConnStr
            {
                get
                {
                    return ConfigurationManager.ConnectionStrings["GymkhanaLibraryDB"] != null
                        ? ConfigurationManager.ConnectionStrings["GymkhanaLibraryDB"].ConnectionString
                        : "Data Source=.\\LOCALHOST;Initial Catalog=GymkhanaLibraryDB;Integrated Security=True;TrustServerCertificate=True;";
                }
            }

            public static SqlConnection GetConnection()
            {
                return new SqlConnection(ConnStr);
            }

            public static DataTable ExecuteReader(string spName, params SqlParameter[] prms)
            {
                var dt = new DataTable();
                using (var con = GetConnection())
                using (var cmd = new SqlCommand(spName, con) { CommandType = CommandType.StoredProcedure, CommandTimeout = 120 })
                using (var da = new SqlDataAdapter(cmd))
                {
                    if (prms != null) cmd.Parameters.AddRange(prms);
                    con.Open();
                    da.Fill(dt);
                }
                return dt;
            }

            public static void ExecuteNonQuery(string spName, params SqlParameter[] prms)
            {
                using (var con = GetConnection())
                using (var cmd = new SqlCommand(spName, con) { CommandType = CommandType.StoredProcedure, CommandTimeout = 120 })
                {
                    if (prms != null) cmd.Parameters.AddRange(prms);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            public static void ExecuteSql(string sql)
            {
                using (var con = GetConnection())
                using (var cmd = new SqlCommand(sql, con) { CommandTimeout = 120 })
                {
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            public static DataTable GetTableData(string query)
            {
                var dt = new DataTable();
                using (var con = GetConnection())
                using (var cmd = new SqlCommand(query, con) { CommandTimeout = 120 })
                using (var da = new SqlDataAdapter(cmd))
                {
                    con.Open();
                    da.Fill(dt);
                }
                return dt;
            }

            public static DataTable GetTableData(string query, params SqlParameter[] prms)
            {
                var dt = new DataTable();
                using (var con = GetConnection())
                using (var cmd = new SqlCommand(query, con) { CommandTimeout = 120 })
                using (var da = new SqlDataAdapter(cmd))
                {
                    if (prms != null) cmd.Parameters.AddRange(prms);
                    con.Open();
                    da.Fill(dt);
                }
                return dt;
            }

            public static DataSet GetBookDetail(int bookID)
            {
                return ExecuteDataSet("sp_GetBookDetail", new SqlParameter("@BookID", bookID));
            }

            public static DataSet ExecuteDataSet(string spName, params SqlParameter[] prms)
            {
                var ds = new DataSet();
                using (var con = GetConnection())
                using (var cmd = new SqlCommand(spName, con) { CommandType = CommandType.StoredProcedure, CommandTimeout = 120 })
                using (var da = new SqlDataAdapter(cmd))
                {
                    if (prms != null) cmd.Parameters.AddRange(prms);
                    con.Open();
                    da.Fill(ds);
                }
                return ds;
            }

            public static DataTable SearchBooks(string term, short? catID, byte? langID, short? pubID, short? yearFrom, short? yearTo, bool availOnly, short? rackID, int? pageNumber = null, int? pageSize = null, string ddc = null, int? bookNo = null)
            {
                var prms = new[]
                {
                    new SqlParameter("@Term", (object)term ?? DBNull.Value),
                    new SqlParameter("@CatID", (object)catID ?? DBNull.Value),
                    new SqlParameter("@LangID", (object)langID ?? DBNull.Value),
                    new SqlParameter("@PubID", (object)pubID ?? DBNull.Value),
                    new SqlParameter("@YearFrom", (object)yearFrom ?? DBNull.Value),
                    new SqlParameter("@YearTo", (object)yearTo ?? DBNull.Value),
                    new SqlParameter("@AvailOnly", availOnly),
                    new SqlParameter("@RackID", (object)rackID ?? DBNull.Value),
                    new SqlParameter("@PageNumber", (object)pageNumber ?? DBNull.Value),
                    new SqlParameter("@PageSize", (object)pageSize ?? DBNull.Value),
                    new SqlParameter("@DDC", (object)ddc ?? DBNull.Value),
                    new SqlParameter("@BookNo", (object)bookNo ?? DBNull.Value)
                };
                return ExecuteReader("sp_SearchBooks", prms);
            }

            public static DataTable GetBookCopiesForWeeding(int bookID)
            {
                return ExecuteReader("dbo.sp_GetBookCopiesForWeeding", new SqlParameter("@BookID", bookID));
            }

            public static string WeedFullBook(int bookID, string remarks, short staffID)
            {
                var prms = new[]
                {
                    new SqlParameter("@BookID", bookID),
                    new SqlParameter("@Remarks", (object)remarks ?? DBNull.Value),
                    new SqlParameter("@StaffID", staffID),
                    new SqlParameter("@Msg", SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
                };
                ExecuteNonQuery("dbo.sp_WeedFullBook", prms);
                return GetOutputValue<string>(prms, "@Msg");
            }

            public static string WeedSingleCopy(int copyID, string remarks, short staffID)
            {
                var prms = new[]
                {
                    new SqlParameter("@CopyID", copyID),
                    new SqlParameter("@Remarks", (object)remarks ?? DBNull.Value),
                    new SqlParameter("@StaffID", staffID),
                    new SqlParameter("@Msg", SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
                };
                ExecuteNonQuery("dbo.sp_WeedSingleCopy", prms);
                return GetOutputValue<string>(prms, "@Msg");
            }



            private static T GetOutputValue<T>(SqlParameter[] prms, string paramName)
            {
                foreach (var p in prms)
                    if (p.ParameterName.Equals(paramName, StringComparison.OrdinalIgnoreCase))
                        return (p.Value == null || p.Value == DBNull.Value) ? default(T) : (T)Convert.ChangeType(p.Value, typeof(T));
                return default(T);
            }
        }

        #endregion
    }
}