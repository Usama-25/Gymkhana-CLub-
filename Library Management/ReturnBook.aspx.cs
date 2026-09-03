using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;

public partial class Pages_Circulation_ReturnBook : System.Web.UI.Page
{
    private short CurrentStaffID = 1; // Librarian session mock

    protected void Page_Load(object sender, EventArgs e)
    {
        pnlAlert.Visible = false;
        if (Session["StaffID"] != null)
        {
            CurrentStaffID = Convert.ToInt16(Session["StaffID"]);
        }

        if (!IsPostBack)
        {
            txtReturnDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtReturnTime.Text = DateTime.Now.ToString("HH:mm");
            BindReturnMemberLookupDropdown();
        }
    }

    private void BindReturnMemberLookupDropdown()
    {
        ddlReturnMemberLookup.DataSource = DBHelper.GetMembers();
        ddlReturnMemberLookup.DataTextField = "MemberDisplay";
        ddlReturnMemberLookup.DataValueField = "UniqueMemberValue";
        ddlReturnMemberLookup.DataBind();
        ddlReturnMemberLookup.Items.Insert(0, new ListItem("- Select Club Member -", "0"));
    }

    protected void txtReturnIssueNo_TextChanged(object sender, EventArgs e)
    {
        pnlAlert.Visible = false;
        string issueNo = txtReturnIssueNo.Text.Replace(" ", "").Trim();
        if (!string.IsNullOrEmpty(issueNo))
        {
            LoadActiveLoanByBarcodeOrIssueNo(issueNo);
            txtReturnBarcode.Text = "";
            txtReturnMemberSearch.Text = "";
            ddlReturnMemberLookup.SelectedValue = "0";
        }
        else
        {
            gvActiveLoans.DataSource = null;
            gvActiveLoans.DataBind();
            pnlActiveLoansGridContainer.Visible = false;
        }
    }

    protected void txtReturnBarcode_TextChanged(object sender, EventArgs e)
    {
        pnlAlert.Visible = false;
        string barcode = txtReturnBarcode.Text.Replace(" ", "").Trim();
        if (!string.IsNullOrEmpty(barcode))
        {
            LoadActiveLoanByBarcodeOrIssueNo(barcode);
            txtReturnIssueNo.Text = "";
            txtReturnMemberSearch.Text = "";
            ddlReturnMemberLookup.SelectedValue = "0";
        }
        else
        {
            gvActiveLoans.DataSource = null;
            gvActiveLoans.DataBind();
            pnlActiveLoansGridContainer.Visible = false;
        }
    }

    protected void btnSearchReturnMember_Click(object sender, EventArgs e)
    {
        pnlAlert.Visible = false;
        string term = txtReturnMemberSearch.Text.Trim();
        string searchKey = term;
        if (searchKey.Contains(" - "))
        {
            searchKey = searchKey.Split(new string[] { " - " }, StringSplitOptions.None)[0].Trim();
        }
        
        DataTable dt = DBHelper.GetMembers(searchKey);
        ddlReturnMemberLookup.DataSource = dt;
        ddlReturnMemberLookup.DataTextField = "MemberDisplay";
        ddlReturnMemberLookup.DataValueField = "UniqueMemberValue";
        ddlReturnMemberLookup.DataBind();
        ddlReturnMemberLookup.Items.Insert(0, new ListItem("- Select Club Member (" + (ddlReturnMemberLookup.Items.Count) + " matches) -", "0"));
        gvActiveLoans.DataSource = null;
        gvActiveLoans.DataBind();
        pnlActiveLoansGridContainer.Visible = false;

        if (dt != null && dt.Rows.Count > 0)
        {
            string autoSelectValue = null;
            foreach (DataRow row in dt.Rows)
            {
                string display = row["MemberDisplay"].ToString();
                if (display.IndexOf(term, StringComparison.OrdinalIgnoreCase) >= 0 || term.IndexOf(display, StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    autoSelectValue = row["UniqueMemberValue"].ToString();
                    break;
                }
            }

            if (autoSelectValue == null)
            {
                DataRow[] mainMembers = dt.Select("Priority = 1");
                if (mainMembers.Length > 0)
                {
                    autoSelectValue = mainMembers[0]["UniqueMemberValue"].ToString();
                }
                else if (dt.Rows.Count == 1)
                {
                    autoSelectValue = dt.Rows[0]["UniqueMemberValue"].ToString();
                }
            }

            if (autoSelectValue != null)
            {
                ddlReturnMemberLookup.SelectedValue = autoSelectValue;
                LoadActiveMemberLoans(GetMemberIDFromValue(autoSelectValue));
            }
        }
    }

    protected void ddlReturnMemberLookup_Changed(object sender, EventArgs e)
    {
        pnlAlert.Visible = false;
        if (ddlReturnMemberLookup.SelectedValue != "0")
        {
            LoadActiveMemberLoans(GetMemberIDFromValue(ddlReturnMemberLookup.SelectedValue));
        }
        else
        {
            gvActiveLoans.DataSource = null;
            gvActiveLoans.DataBind();
            pnlActiveLoansGridContainer.Visible = false;
        }
    }

    private void LoadActiveMemberLoans(int memberID)
    {
        gvActiveLoans.DataSource = null;
        gvActiveLoans.DataBind();
        pnlActiveLoansGridContainer.Visible = false;
        
        string actualBorrowerNo = null;
        if (ddlReturnMemberLookup.SelectedItem != null && ddlReturnMemberLookup.SelectedValue != "0")
        {
            string selectedText = ddlReturnMemberLookup.SelectedItem.Text;
            if (!selectedText.Contains("- Select Club Member"))
            {
                if (!string.IsNullOrEmpty(selectedText) && selectedText.Contains(" - "))
                {
                    int dashIndex = selectedText.IndexOf(" - ");
                    actualBorrowerNo = selectedText.Substring(0, dashIndex).Trim();
                }
            }
        }

        string mainMemberNo = "";
        if (ddlReturnMemberLookup.SelectedValue.Contains("|"))
        {
            mainMemberNo = ddlReturnMemberLookup.SelectedValue.Split('|')[1].Trim();
        }

        if (actualBorrowerNo == mainMemberNo)
        {
            actualBorrowerNo = null; // Get all loans (including NULL/empty actualBorrowerNo)
        }

        var prms = new[]
        {
            new SqlParameter("@MemberID", memberID),
            new SqlParameter("@ActiveOnly", true),
            new SqlParameter("@ActualBorrowerNo", (object)actualBorrowerNo ?? DBNull.Value)
        };
        
        DataTable dt = DBHelper.ExecuteReader("sp_GetMemberLoans", prms);
        gvActiveLoans.DataSource = dt;
        gvActiveLoans.DataBind();
        pnlActiveLoansGridContainer.Visible = true;
    }

    protected void gvActiveLoans_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        pnlAlert.Visible = false;
        if (e.CommandName == "ReturnBook" || e.CommandName == "ReissueBook")
        {
            int index = Convert.ToInt32(e.CommandArgument);
            
            int loanID = Convert.ToInt32(gvActiveLoans.DataKeys[index].Values["LoanID"]);
            int copyID = Convert.ToInt32(gvActiveLoans.DataKeys[index].Values["CopyID"]);
            DateTime dueDate = Convert.ToDateTime(gvActiveLoans.DataKeys[index].Values["DueDate"]);

            if (e.CommandName == "ReturnBook")
            {
                byte condID = Convert.ToByte(ddlReturnCondition.SelectedValue);
                DateTime? customReturnDateTime = null;
                if (!string.IsNullOrEmpty(txtReturnDate.Text))
                {
                    DateTime rDate;
                    if (DateTime.TryParse(txtReturnDate.Text, out rDate))
                    {
                        TimeSpan rTime = TimeSpan.Zero;
                        if (!string.IsNullOrEmpty(txtReturnTime.Text))
                        {
                            TimeSpan.TryParse(txtReturnTime.Text, out rTime);
                        }
                        customReturnDateTime = rDate.Date.Add(rTime);
                    }
                }

                string result = DBHelper.ReturnBook(copyID, CurrentStaffID, condID, customReturnDateTime);

                if (result.StartsWith("OK:"))
                {
                    string returnInfo = result.Substring(3);
                    string successMsg = "";
                    if (returnInfo.StartsWith("FINE:"))
                    {
                        string fineAmt = returnInfo.Substring(5);
                        successMsg = "Book returned successfully, but is <strong>OVERDUE</strong>. An outstanding fine of <strong>" + fineAmt + "</strong> has been logged to the member's account.";
                        ShowAlert(successMsg, "alert-error");
                    }
                    else if (returnInfo.StartsWith("EARLY:"))
                    {
                        string daysEarly = returnInfo.Substring(6);
                        successMsg = "Book returned successfully! Checked in <strong>" + daysEarly + " days early</strong>.";
                        ShowAlert(successMsg, "alert-success");
                    }
                    else
                    {
                        successMsg = "Book returned successfully! Copy has been checked back in.";
                        ShowAlert(successMsg, "alert-success");
                    }

                    // Check for reservations
                    DataTable dtCopy = DBHelper.GetTableData("SELECT BookID FROM BookCopies WHERE CopyID = " + copyID);
                    if (dtCopy != null && dtCopy.Rows.Count > 0)
                    {
                        int bookID = Convert.ToInt32(dtCopy.Rows[0]["BookID"]);
                        string resMemberName;
                        if (IsBookReserved(copyID, out resMemberName))
                        {
                            lblReservedMemberName.Text = resMemberName;
                            ViewState["ReservationSlipHtml"] = GenerateReservationSlipHtml(bookID, resMemberName);
                            pnlReservationAlertModal.Visible = true;
                        }
                    }
                }
                else
                {
                    ShowAlert("Check-in failed: " + result, "alert-error");
                }
            }
            else if (e.CommandName == "ReissueBook")
            {
                // Reissue/Renewal directly
                string result = DBHelper.RenewBook(loanID, CurrentStaffID);

                if (result.StartsWith("OK:"))
                {
                    string newDue = result.Substring(11);
                    ShowAlert("Loan Renewed/Reissued Successfully! <strong>New Due Date: " + newDue + " (Extended by 15 Days)</strong>", "alert-success");
                }
                else
                {
                    string err = result;
                    if (err.StartsWith("ERR:MAX_RENEWALS")) err = "Renewal failed: Member has reached the maximum allowed renewals (" + err.Split(':')[2] + " times).";
                    else if (err == "ERR:RESERVATION_EXISTS") err = "Renewal blocked: Another club member has placed an active reservation on this book.";
                    else if (err == "ERR:LOAN_NOT_FOUND") err = "Loan transaction not found.";
                    
                    ShowAlert("Renewal failed: " + err, "alert-error");
                }
            }

            // Refresh current grid view
            RefreshGridAfterAction();
        }
    }

    private void RefreshGridAfterAction()
    {
        if (ddlReturnMemberLookup.SelectedValue != "0")
        {
            LoadActiveMemberLoans(GetMemberIDFromValue(ddlReturnMemberLookup.SelectedValue));
        }
        else if (!string.IsNullOrEmpty(txtReturnBarcode.Text))
        {
            LoadActiveLoanByBarcodeOrIssueNo(txtReturnBarcode.Text.Trim());
        }
        else if (!string.IsNullOrEmpty(txtReturnIssueNo.Text))
        {
            LoadActiveLoanByBarcodeOrIssueNo(txtReturnIssueNo.Text.Trim());
        }
        else
        {
            gvActiveLoans.DataSource = null;
            gvActiveLoans.DataBind();
            pnlActiveLoansGridContainer.Visible = false;
        }
    }

    private void LoadActiveLoanByBarcodeOrIssueNo(string input)
    {
        gvActiveLoans.DataSource = null;
        gvActiveLoans.DataBind();
        pnlActiveLoansGridContainer.Visible = false;

        if (string.IsNullOrEmpty(input)) return;

        string cleanInput = input.Replace("'", "''").Replace(" ", "").Trim();
        string query = @"
            SELECT
                l.LoanID, b.ISBN13, dbo.fn_ISBN13Fmt(b.ISBN13) AS ISBN13Fmt,
                b.Title, cp.Barcode, cp.CopyID, cp.BookNo,
                l.IssueDate, l.DueDate, l.ReturnDate, l.RenewalCount,
                ts.StatusName
            FROM Loans l
            JOIN BookCopies cp ON l.CopyID = cp.CopyID
            JOIN Books b ON cp.BookID = b.BookID
            JOIN TxnStatuses ts ON l.StatusID = ts.StatusID
            WHERE l.StatusID IN (1,3,4) AND (
                cp.Barcode = '" + cleanInput + @"'
                OR CAST(cp.BookNo AS VARCHAR(50)) = '" + cleanInput + @"'
                OR CAST(l.LoanID AS VARCHAR(50)) = '" + cleanInput + @"'
            )
            ORDER BY l.IssueDate DESC";

        DataTable dt = DBHelper.GetTableData(query);
        gvActiveLoans.DataSource = dt;
        gvActiveLoans.DataBind();
        pnlActiveLoansGridContainer.Visible = true;
    }

    public string GetEstimatedFineDisplay(object dueDateVal)
    {
        if (dueDateVal == null || dueDateVal == DBNull.Value) return "None";
        DateTime dueDate = Convert.ToDateTime(dueDateVal).Date;
        DateTime today = DateTime.Today;
        if (today > dueDate)
        {
            int days = (today - dueDate).Days;
            decimal dailyFine = 10;
            DataTable dtFine = DBHelper.GetTableData("SELECT SVal FROM Settings WHERE SKey = 'OverdueDailyFine'");
            if (dtFine != null && dtFine.Rows.Count > 0)
            {
                decimal.TryParse(dtFine.Rows[0]["SVal"].ToString(), out dailyFine);
            }
            decimal estFine = days * dailyFine;
            return "PKR " + estFine.ToString("F2");
        }
        return "None";
     }

    public string GetEstimatedFineBadge(object dueDateVal)
    {
        string display = GetEstimatedFineDisplay(dueDateVal);
        if (display == "None")
        {
            return "<span style='display: inline-block; background-color: #f1f5f9; color: #475569; font-weight: 600; padding: 4px 10px; border-radius: 12px; font-size: 11px;'>None</span>";
        }
        else
        {
            return "<span style='display: inline-block; background-color: #fee2e2; color: #ef4444; font-weight: 700; padding: 4px 10px; border-radius: 12px; font-size: 11px; border: 1px solid #fca5a5;'>" + display + "</span>";
        }
    }



    protected void ddlReturnCondition_SelectedIndexChanged(object sender, EventArgs e)
    {
        pnlAlert.Visible = false;
        byte condID = Convert.ToByte(ddlReturnCondition.SelectedValue);
        var returnWarnings = new System.Collections.Generic.List<string>();
        returnWarnings.Add("Return Shelf Policy: All books taken out must be returned to the Librarian and under no circumstances should be placed on shelves.");

        if (condID == 5) // Damaged
        {
            returnWarnings.Add("Damage Liability: A member who returns a book in a damaged condition will be liable for the cost of: (a) Rebinding the book, or (b) Replacing the book. The decision of the Convener Library as to in which category the damage falls shall be final.");
        }
        else if (condID == 6) // Lost
        {
            returnWarnings.Add("Lost Book Policy: All books lost will be charged their original cost price plus 200% extra to cover enhancement in price and the cost of replacement.");
        }

        ShowPolicyWarnings(returnWarnings);
    }

    private void ShowPolicyWarnings(System.Collections.Generic.List<string> warnings)
    {
        if (warnings != null && warnings.Count > 0)
        {
            pnlPolicyWarning.Visible = true;
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            foreach (string warning in warnings)
            {
                sb.AppendFormat("<li>{0}</li>", warning);
            }
            litPolicyWarningMsg.Text = sb.ToString();
        }
        else
        {
            pnlPolicyWarning.Visible = false;
        }
    }

    private bool IsBookReserved(int copyID, out string reservedByMember)
    {
        reservedByMember = "";
        DataTable dtBook = DBHelper.GetTableData("SELECT BookID FROM BookCopies WHERE CopyID = " + copyID);
        if (dtBook != null && dtBook.Rows.Count > 0 && dtBook.Rows[0]["BookID"] != DBNull.Value)
        {
            int bookID = Convert.ToInt32(dtBook.Rows[0]["BookID"]);
            DataTable dtRes = DBHelper.GetTableData("SELECT TOP 1 m.FullName, m.MembershipNo FROM Reservations r JOIN Members m ON r.MemberID = m.MemberID WHERE r.BookID = " + bookID + " AND r.StatusID = 1 ORDER BY r.QueuePos, r.ReservedAt");
            if (dtRes != null && dtRes.Rows.Count > 0)
            {
                reservedByMember = dtRes.Rows[0]["FullName"].ToString() + " (" + dtRes.Rows[0]["MembershipNo"].ToString() + ")";
                return true;
            }
        }
        return false;
    }

    private string GenerateReservationSlipHtml(int bookID, string memberName)
    {
        string bookTitle = "";
        string ddc = "";
        string bookNo = "";
        DataTable dtBook = DBHelper.GetTableData("SELECT Title, DDC, AcqNo, BookID FROM Books WHERE BookID = " + bookID);
        if (dtBook != null && dtBook.Rows.Count > 0)
        {
            bookTitle = dtBook.Rows[0]["Title"].ToString().ToUpper();
            ddc = dtBook.Rows[0]["DDC"] != DBNull.Value ? dtBook.Rows[0]["DDC"].ToString().Trim() : "N/A";
            bookNo = dtBook.Rows[0]["AcqNo"] != DBNull.Value && !string.IsNullOrEmpty(dtBook.Rows[0]["AcqNo"].ToString()) 
                ? dtBook.Rows[0]["AcqNo"].ToString().Trim() 
                : Convert.ToInt32(dtBook.Rows[0]["BookID"]).ToString("D6");
        }

        string resID = "00000";
        string membershipNo = "";
        string memberCleanName = "";
        string reserveDate = DateTime.Today.ToString("dd/MM/yyyy");
        DataTable dtRes = DBHelper.GetTableData("SELECT TOP 1 r.ResID, r.ReservedAt, m.FullName, m.MembershipNo FROM Reservations r JOIN Members m ON r.MemberID = m.MemberID WHERE r.BookID = " + bookID + " AND r.StatusID = 1 ORDER BY r.QueuePos, r.ReservedAt");
        if (dtRes != null && dtRes.Rows.Count > 0)
        {
            resID = Convert.ToInt32(dtRes.Rows[0]["ResID"]).ToString("D5");
            membershipNo = dtRes.Rows[0]["MembershipNo"].ToString();
            memberCleanName = dtRes.Rows[0]["FullName"].ToString().ToUpper();
            reserveDate = Convert.ToDateTime(dtRes.Rows[0]["ReservedAt"]).ToString("dd/MM/yyyy");
        }
        else
        {
            if (memberName.Contains(" (") && memberName.EndsWith(")"))
            {
                int startParen = memberName.LastIndexOf(" (");
                memberCleanName = memberName.Substring(0, startParen).Trim().ToUpper();
                membershipNo = memberName.Substring(startParen + 2, memberName.Length - startParen - 3).Trim();
            }
            else
            {
                memberCleanName = memberName.ToUpper();
            }
        }

        string transactionDateTime = DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss");
        int resDays = 7;
        try
        {
            DataTable dtResDays = DBHelper.GetTableData("SELECT SVal FROM Settings WHERE SKey = 'ResDays'");
            if (dtResDays != null && dtResDays.Rows.Count > 0)
            {
                int.TryParse(dtResDays.Rows[0]["SVal"].ToString(), out resDays);
            }
        }
        catch { }
        string disposalUntil = DateTime.Now.AddDays(resDays).ToString("dd/MM/yyyy HH:mm");
        
        string staffName = "Librarian";
        try
        {
            DataTable dtStaff = DBHelper.GetTableData("SELECT ISNULL(EFName, '') + ' ' + ISNULL(ELName, '') FROM User_management.dbo.Employee WHERE EmpID = " + CurrentStaffID);
            if (dtStaff != null && dtStaff.Rows.Count > 0)
            {
                string name = Convert.ToString(dtStaff.Rows[0][0]).Trim();
                if (!string.IsNullOrEmpty(name)) staffName = name;
            }
        }
        catch { }

        string auditStamp = staffName + ", " + DateTime.Now.ToString("dd/MM/yyyy, h:mm:sstt").ToUpper() + ", LM 10.04";

        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        sb.Append("<div style='font-family: Arial, sans-serif; color: #000000; line-height: 1.6; padding: 20px; max-width: 750px; margin: 0 auto; text-align: left;'>");
        sb.Append("  <table style='width: 100%; border-collapse: collapse; margin-bottom: 25px;'>");
        sb.Append("    <tr>");
        sb.Append("      <td style='vertical-align: top; text-align: left;'>");
        sb.Append("        <div style='font-size: 20px; font-weight: bold; letter-spacing: 0.5px;'>Lahore Gymkhana</div>");
        sb.Append("        <div style='font-size: 13px; font-weight: bold; margin-top: 3px;'>Library Reserve Note</div>");
        sb.Append("      </td>");
        sb.Append("      <td style='vertical-align: bottom; text-align: right; font-size: 13px;'>");
        sb.Append("        Transaction Date/Time: <span style='border-bottom: 1px solid #000; padding-bottom: 2px;'>" + transactionDateTime + "</span>");
        sb.Append("      </td>");
        sb.Append("    </tr>");
        sb.Append("  </table>");
        sb.Append("  <table style='width: 100%; border-collapse: collapse; margin-bottom: 20px; font-size: 13.5px;'>");
        sb.Append("    <tr>");
        sb.Append("      <td style='padding: 6px 0; width: 140px;'>Library Reserve No:</td>");
        sb.Append("      <td style='padding: 6px 0; font-weight: bold;'><span style='border-bottom: 1px solid #000; padding-bottom: 2px;'>" + resID + "</span></td>");
        sb.Append("    </tr>");
        sb.Append("    <tr>");
        sb.Append("      <td style='padding: 6px 0;'>Reserved for:</td>");
        sb.Append("      <td style='padding: 6px 0; font-weight: bold;'><span style='border-bottom: 1px solid #000; padding-bottom: 2px;'>" + membershipNo + " &nbsp; " + memberCleanName + "</span></td>");
        sb.Append("    </tr>");
        sb.Append("  </table>");
        sb.Append("  <div style='font-size: 13.5px; margin-bottom: 15px;'>The following book/magazine was reserved by you</div>");
        sb.Append("  <table style='width: 100%; border-collapse: collapse; margin-bottom: 20px; font-size: 13px;'>");
        sb.Append("    <thead>");
        sb.Append("      <tr style='border-bottom: 1.5px solid #000;'>");
        sb.Append("        <th style='text-align: left; padding: 6px 0; font-weight: bold; width: 110px;'>AccNo</th>");
        sb.Append("        <th style='text-align: left; padding: 6px 0; font-weight: bold; width: 130px;'>DDC No</th>");
        sb.Append("        <th style='text-align: left; padding: 6px 0; font-weight: bold;'>Title</th>");
        sb.Append("        <th style='text-align: right; padding: 6px 0; font-weight: bold; width: 120px;'>Reserve Date</th>");
        sb.Append("      </tr>");
        sb.Append("    </thead>");
        sb.Append("    <tbody>");
        sb.Append("      <tr style='border-bottom: 1.5px solid #000;'>");
        sb.Append("        <td style='padding: 10px 0; font-family: monospace;'>" + bookNo + "</td>");
        sb.Append("        <td style='padding: 10px 0;'>" + ddc + "</td>");
        sb.Append("        <td style='padding: 10px 0; font-weight: bold;'>" + bookTitle + "</td>");
        sb.Append("        <td style='padding: 10px 0; text-align: right;'>" + reserveDate + "</td>");
        sb.Append("      </tr>");
        sb.Append("    </tbody>");
        sb.Append("  </table>");
        sb.Append("  <div style='font-size: 13.5px; margin-bottom: 12px; text-align: justify;'>");
        sb.Append("    This is now available and will be held at your disposal up to <strong>(" + disposalUntil + ")</strong>");
        sb.Append("  </div>");
        sb.Append("  <div style='font-size: 13.5px; margin-bottom: 20px; text-align: justify;'>");
        sb.Append("    if not claimed, then this will be issued to the next applicant or returned to the shelves.");
        sb.Append("  </div>");
        sb.Append("  <div style='font-size: 13.5px; margin-bottom: 60px;'>");
        sb.Append("    Please bring this reservation slip with you or sign it below for the bearer.");
        sb.Append("  </div>");
        sb.Append("  <table style='width: 100%; border-collapse: collapse;'>");
        sb.Append("    <tr>");
        sb.Append("      <td style='width: 50%; vertical-align: top; text-align: left;'>");
        sb.Append("        <div style='display: inline-block; text-align: center;'>");
        sb.Append("          <div style='font-size: 13.5px; border-bottom: 1px solid #000; width: 220px; padding-bottom: 3px; font-weight: bold; height: 25px;'>" + staffName + "</div>");
        sb.Append("          <div style='font-size: 12px; font-weight: bold; margin-top: 5px;'>Reserved By</div>");
        sb.Append("        </div>");
        sb.Append("      </td>");
        sb.Append("      <td style='width: 50%; vertical-align: top; text-align: right; font-size: 13.5px;'>");
        sb.Append("        <div style='margin-bottom: 40px;'>Yours Faithfully,</div>");
        sb.Append("        <div style='font-weight: bold;'>Manager Library</div>");
        sb.Append("      </td>");
        sb.Append("    </tr>");
        sb.Append("    <tr>");
        sb.Append("      <td style='padding-top: 40px; font-size: 10px; color: #555; font-style: italic; vertical-align: bottom;'>" + auditStamp + "</td>");
        sb.Append("      <td style='padding-top: 40px; text-align: right; vertical-align: top;'>");
        sb.Append("        <table style='float: right; font-size: 13px;'>");
        sb.Append("          <tr><td style='padding: 3px 0; text-align: left; width: 80px;'>Signature</td><td style='border-bottom: 1px solid #000; width: 150px;'></td></tr>");
        sb.Append("          <tr><td style='padding: 3px 0; text-align: left;'>M/s No.</td><td style='border-bottom: 1px solid #000;'></td></tr>");
        sb.Append("        </table>");
        sb.Append("      </td>");
        sb.Append("    </tr>");
        sb.Append("  </table>");
        sb.Append("</div>");

        return sb.ToString();
    }

    protected void btnPrintReservationSlip_Click(object sender, EventArgs e)
    {
        pnlReservationAlertModal.Visible = false;
        if (ViewState["ReservationSlipHtml"] != null)
        {
            string html = ViewState["ReservationSlipHtml"].ToString();
            ScriptManager.RegisterStartupScript(this, GetType(), "PrintSlip", "printElement(" + System.Web.HttpUtility.JavaScriptStringEncode(html, true) + ");", true);
        }
    }

    protected void btnCloseReservationModal_Click(object sender, EventArgs e)
    {
        pnlReservationAlertModal.Visible = false;
    }

    protected void gvActiveLoans_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header)
        {
            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                TableCell cell = e.Row.Cells[i];
                cell.Attributes["style"] = "padding: 14px 16px; background-color: #0f1e36; font-weight: 700; font-size: 12px; text-transform: uppercase; color: #ffffff; border-bottom: 3px solid #c5a059; letter-spacing: 0.5px; border-top: none; border-left: none; border-right: none; text-align: " + (i == 1 ? "left" : "center") + ";";
            }
        }
        else if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string bg = (e.Row.RowIndex % 2 == 0) ? "#ffffff" : "#f8fafc";
            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                TableCell cell = e.Row.Cells[i];
                string style = "padding: 14px 16px; border-bottom: 1px solid #e2e8f0; color: #334155; border-top: none; border-left: none; border-right: none; text-align: " + (i == 1 ? "left" : "center") + "; background-color: " + bg + ";";
                if (i == 2 || i == 3) // Book No or Barcode column
                {
                    style += " font-family: 'Courier New', Courier, monospace; font-weight: 600;";
                }
                cell.Attributes["style"] = style;
            }
        }
    }

    private void ShowAlert(string msg, string type)
    {
        pnlAlert.Visible = true;
        litAlertMsg.Text = msg;
        if (type == "alert-success")
        {
            divAlert.Style["background-color"] = "#d1fae5";
            divAlert.Style["border-left-color"] = "#10b981";
            divAlert.Style["color"] = "#065f46";
        }
        else if (type == "alert-info")
        {
            divAlert.Style["background-color"] = "#e0f2fe";
            divAlert.Style["border-left-color"] = "#0ea5e9";
            divAlert.Style["color"] = "#0369a1";
        }
        else // alert-error
        {
            divAlert.Style["background-color"] = "#fee2e2";
            divAlert.Style["border-left-color"] = "#ef4444";
            divAlert.Style["color"] = "#991b1b";
        }
        upReturnDesk.Update();
    }

    private int GetMemberIDFromValue(string val)
    {
        if (string.IsNullOrEmpty(val) || val == "0") return 0;
        if (val.Contains("|"))
        {
            int id;
            if (int.TryParse(val.Split('|')[0], out id)) return id;
        }
        else
        {
            int id;
            if (int.TryParse(val, out id)) return id;
        }
        return 0;
    }

    [System.Web.Services.WebMethod]
    public static object CheckOverdueStatus(string barcode)
    {
        if (string.IsNullOrEmpty(barcode)) return new { error = "Empty search input" };

        barcode = barcode.Replace(" ", "").Trim();
        string cleanInput = barcode.Replace("'", "''");
        
        string query = @"
            SELECT TOP 1 l.DueDate
            FROM Loans l
            JOIN BookCopies cp ON l.CopyID = cp.CopyID
            JOIN Books b ON cp.BookID = b.BookID
            WHERE (
                   cp.Barcode = '" + cleanInput + @"'
                OR CAST(cp.BookNo AS VARCHAR(50)) = '" + cleanInput + @"'
                OR CAST(l.LoanID AS VARCHAR(50)) = '" + cleanInput + @"'
            ) AND l.StatusID IN (1,3,4)
            ORDER BY l.IssueDate DESC";

        DataTable dt = DBHelper.GetTableData(query);

        if (dt.Rows.Count == 0)
        {
            return new { error = "No active borrowing loan found for copy input '" + barcode + "'" };
        }

        DateTime dueDate = Convert.ToDateTime(dt.Rows[0]["DueDate"]).Date;
        DateTime today = DateTime.Today;

        if (today > dueDate)
        {
            int days = (today - dueDate).Days;
            
            decimal dailyFine = 10;
            DataTable dtFine = DBHelper.GetTableData("SELECT SVal FROM Settings WHERE SKey = 'OverdueDailyFine'");
            if (dtFine != null && dtFine.Rows.Count > 0)
            {
                decimal.TryParse(dtFine.Rows[0]["SVal"].ToString(), out dailyFine);
            }
            decimal estFine = days * dailyFine;
            
            return new { isOverdue = true, days = days, fine = estFine, dueDate = dueDate.ToString("dd-MMM-yyyy") };
        }
        else
        {
            return new { isOverdue = false, days = 0, fine = 0.0, dueDate = dueDate.ToString("dd-MMM-yyyy") };
        }
    }

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
            using (var da  = new SqlDataAdapter(cmd))
            {
                if (prms != null) cmd.Parameters.AddRange(prms);
                con.Open();
                da.Fill(dt);
            }
            return dt;
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

        public static T GetOutputValue<T>(SqlParameter[] prms, string paramName)
        {
            foreach (var p in prms)
                if (p.ParameterName.Equals(paramName, StringComparison.OrdinalIgnoreCase))
                    return (p.Value == null || p.Value == DBNull.Value) ? default(T) : (T)Convert.ChangeType(p.Value, typeof(T));
            return default(T);
        }

        public static string ReturnBook(int copyID, short staffID, byte condID = 2, DateTime? returnDateTime = null)
        {
            var prms = new[]
            {
                new SqlParameter("@CopyID",  copyID),
                new SqlParameter("@StaffID", staffID),
                new SqlParameter("@CondID",  condID),
                new SqlParameter("@ReturnDateTime", (object)returnDateTime ?? DBNull.Value),
                new SqlParameter("@Msg",     SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
            };
            using (var con = GetConnection())
            using (var cmd = new SqlCommand("sp_ReturnBook", con) { CommandType = CommandType.StoredProcedure })
            {
                cmd.Parameters.AddRange(prms);
                con.Open();
                cmd.ExecuteNonQuery();
            }
            return GetOutputValue<string>(prms, "@Msg");
        }

        public static string ReturnCollectReissue(int copyID, short staffID, byte condID, int? reissueToMemberID, DateTime? issueDate, DateTime? dueDate, bool collectFines, string actualBorrowerNo = null, string actualBorrowerName = null)
        {
            var prms = new[]
            {
                new SqlParameter("@CopyID",             copyID),
                new SqlParameter("@StaffID",            staffID),
                new SqlParameter("@CondID",             condID),
                new SqlParameter("@ReissueToMemberID",  (object)reissueToMemberID ?? DBNull.Value),
                new SqlParameter("@IssueDate",          (object)issueDate         ?? DBNull.Value),
                new SqlParameter("@DueDate",            (object)dueDate           ?? DBNull.Value),
                new SqlParameter("@CollectFines",       collectFines),
                new SqlParameter("@Msg",                SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output },
                new SqlParameter("@ActualBorrowerNo",   (object)actualBorrowerNo ?? DBNull.Value),
                new SqlParameter("@ActualBorrowerName", (object)actualBorrowerName ?? DBNull.Value)
            };
            using (var con = GetConnection())
            using (var cmd = new SqlCommand("sp_ReturnCollectReissue", con) { CommandType = CommandType.StoredProcedure })
            {
                cmd.Parameters.AddRange(prms);
                con.Open();
                cmd.ExecuteNonQuery();
            }
            return GetOutputValue<string>(prms, "@Msg");
        }

        public static string RenewBook(int loanID, short staffID)
        {
            var prms = new[]
            {
                new SqlParameter("@LoanID",  loanID),
                new SqlParameter("@StaffID", staffID),
                new SqlParameter("@Msg",     SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output }
            };
            using (var con = GetConnection())
            using (var cmd = new SqlCommand("sp_RenewLoan", con) { CommandType = CommandType.StoredProcedure })
            {
                cmd.Parameters.AddRange(prms);
                con.Open();
                cmd.ExecuteNonQuery();
            }
            return GetOutputValue<string>(prms, "@Msg");
        }

        public static DataTable GetMembers(string search = null)
        {
            if (string.IsNullOrEmpty(search))
            {
                return GetTableData(@"
                    SELECT TOP 100 
                        mp.MemberID, 
                        mp.MemberNo AS MembershipNo, 
                        mp.MemberName AS FullName, 
                        mp.MemberNo + ' - ' + mp.MemberName + ' (' + COALESCE(mp.Status, mp.AccountStatus, 'Active') + 
  ', ' + CAST((SELECT COUNT(*) FROM GymkhanaLibraryDB.dbo.Loans L WHERE L.MemberID = mp.MemberID AND L.StatusID IN 
  (1,3,4) AND (L.ActualBorrowerNo IS NULL OR L.ActualBorrowerNo COLLATE DATABASE_DEFAULT = mp.MemberNo COLLATE 
  DATABASE_DEFAULT)) AS VARCHAR(10)) + ' Books)' AS MemberDisplay, 
                        1 AS Priority, 
                        CAST(mp.MemberID AS VARCHAR(20)) + '|' + mp.MemberNo AS UniqueMemberValue 
                    FROM MemberShip.dbo.MemberProfile mp 
                    WHERE mp.IsActive = '1' 
                    ORDER BY mp.MemberName");
            }
            else
            {
                string cleanSearch = search.Replace("'", "''");
                string query = @"
                    SELECT TOP 200 MemberID, MembershipNo, FullName, MemberDisplay, Priority, CAST(MemberID AS 
  VARCHAR(20)) + '|' + MembershipNo AS UniqueMemberValue
                    FROM (
                        SELECT 
                            mp.MemberID, 
                            mp.MemberNo AS MembershipNo, 
                            mp.MemberName AS FullName, 
                            mp.MemberNo + ' - ' + mp.MemberName + ' (' + COALESCE(mp.Status, mp.AccountStatus, 'Active') 
  + ', ' + CAST((SELECT COUNT(*) FROM GymkhanaLibraryDB.dbo.Loans L WHERE L.MemberID = mp.MemberID AND L.StatusID IN 
  (1,3,4) AND (L.ActualBorrowerNo IS NULL OR L.ActualBorrowerNo COLLATE DATABASE_DEFAULT = mp.MemberNo COLLATE 
  DATABASE_DEFAULT)) AS VARCHAR(10)) + ' Books)' AS MemberDisplay,
                            mp.MemberName AS OrderName,
                            1 AS Priority
                        FROM MemberShip.dbo.MemberProfile mp
                        WHERE mp.IsActive = '1' 
                          AND (mp.MemberNo LIKE '%" + cleanSearch + @"%' OR mp.MemberName LIKE '%" + cleanSearch + @"%')
                          
                        UNION ALL
                        
                        SELECT 
                            mp.MemberID,
                            ms.MembershipNo,
                            ms.SpouseName AS FullName,
                            ms.MembershipNo + ' - ' + ms.SpouseName + ' (Spouse of ' + mp.MemberName + ')' + ' (' + 
  COALESCE(ms.RecordStatus, 'Active') + ', ' + CAST((SELECT COUNT(*) FROM GymkhanaLibraryDB.dbo.Loans L WHERE L.MemberID 
  = mp.MemberID AND L.StatusID IN (1,3,4) AND L.ActualBorrowerNo COLLATE DATABASE_DEFAULT = ms.MembershipNo COLLATE 
  DATABASE_DEFAULT) AS VARCHAR(10)) + ' Books)' AS MemberDisplay,
                            mp.MemberName AS OrderName,
                            2 AS Priority
                        FROM MemberShip.dbo.MemberSpouses ms
                        JOIN MemberShip.dbo.MemberProfile mp ON ms.MemberID = mp.MemberID
                        WHERE mp.IsActive = '1' 
                          AND ms.RecordStatus = 'Active'
                          AND (ms.MembershipNo LIKE '%" + cleanSearch + @"%' OR ms.SpouseName LIKE '%" + cleanSearch + 
  @"%')
                          
                        UNION ALL
                        
                        SELECT 
                            mp.MemberID,
                            mc.MembershipNo,
                            mc.ChildName AS FullName,
                            mc.MembershipNo + ' - ' + mc.ChildName + ' (' + mc.Relationship + ' of ' + mp.MemberName + 
  ')' + ' (' + COALESCE(mc.RecordStatus, 'Active') + ', ' + CAST((SELECT COUNT(*) FROM GymkhanaLibraryDB.dbo.Loans L 
  WHERE L.MemberID = mp.MemberID AND L.StatusID IN (1,3,4) AND L.ActualBorrowerNo COLLATE DATABASE_DEFAULT = 
  mc.MembershipNo COLLATE DATABASE_DEFAULT) AS VARCHAR(10)) + ' Books)' AS MemberDisplay,
                            mp.MemberName AS OrderName,
                            3 AS Priority
                        FROM MemberShip.dbo.MemberChildren mc
                        JOIN MemberShip.dbo.MemberProfile mp ON mc.MemberID = mp.MemberID
                        WHERE mp.IsActive = '1' 
                          AND mc.RecordStatus = 'Active'
                          AND (mc.MembershipNo LIKE '%" + cleanSearch + @"%' OR mc.ChildName LIKE '%" + cleanSearch + 
  @"%')
                    ) AS Combined
                    ORDER BY Priority, OrderName";
                return GetTableData(query);
            }
        }
    }
}
