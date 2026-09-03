<%@ Page Language="C#" MasterPageFile="~/Complaint/Complaint.Master" AutoEventWireup="true" CodeFile="ComplaintPanel.aspx.cs" Inherits="GymkhanaLibrary.Pages_ComplaintPanel" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        @keyframes modalFadeIn {
            from {
                opacity: 0;
                transform: scale(0.96) translateY(-12px);
            }
            to {
                opacity: 1;
                transform: scale(1) translateY(0);
            }
        }
    </style>
    <script type="text/javascript">
        function printModalSummary() {
            var subjectEl = document.getElementById('spnCompSubject');
            var detailEl = document.getElementById('spnCompDetail');
            var statusEl = document.getElementById('<%= ddlUpdateStatus.ClientID %>');
            var remarksEl = document.getElementById('<%= txtRemarks.ClientID %>');
            
            var idEl = document.getElementById('<%= hfComplaintID.ClientID %>');
            var typeEl = document.getElementById('<%= hfRecordType.ClientID %>');
            var memberNoEl = document.getElementById('<%= hfMemberNo.ClientID %>');
            var memberNameEl = document.getElementById('<%= hfMemberName.ClientID %>');
            var emailEl = document.getElementById('<%= hfMemberEmail.ClientID %>');
            var phoneEl = document.getElementById('<%= hfMemberPhone.ClientID %>');
            var deptEl = document.getElementById('<%= hfDepartmentName.ClientID %>');
            var subDeptEl = document.getElementById('<%= hfSubDepartmentName.ClientID %>');
            var locEl = document.getElementById('<%= hfLocationName.ClientID %>');
            var dateEl = document.getElementById('<%= hfCreatedDate.ClientID %>');

            var complaintId = idEl && idEl.value ? idEl.value : '';
            var recordType = typeEl && typeEl.value ? typeEl.value : 'Complaint';
            var memberNo = memberNoEl && memberNoEl.value ? memberNoEl.value.trim() : '';
            var memberName = memberNameEl && memberNameEl.value ? memberNameEl.value.trim() : 'Guest / Anonymous Member';
            var email = emailEl && emailEl.value ? emailEl.value.trim() : '';
            var phone = phoneEl && phoneEl.value ? phoneEl.value.trim() : '';
            var deptName = deptEl && deptEl.value ? deptEl.value.trim() : 'Lahore Gymkhana Administration';
            var subDeptName = subDeptEl && subDeptEl.value ? subDeptEl.value.trim() : '';
            var locationName = locEl && locEl.value ? locEl.value.trim() : '';
            var createdDate = dateEl && dateEl.value ? dateEl.value.trim() : new Date().toLocaleDateString();

            var subject = subjectEl ? (subjectEl.innerText || subjectEl.textContent || '').trim() : 'Service Grievance / Complaint';
            var detail = detailEl ? (detailEl.innerText || detailEl.textContent || '').trim() : '';
            var status = statusEl ? statusEl.options[statusEl.selectedIndex].text : 'Pending';
            var remarks = remarksEl ? remarksEl.value.trim() : '';

            var targetDeptFull = deptName;
            if (subDeptName && subDeptName !== '') {
                targetDeptFull += ' (' + subDeptName + ')';
            }
            if (locationName && locationName !== '' && locationName !== 'N/A') {
                targetDeptFull += ' - ' + locationName;
            }

            var logoUrl = window.location.protocol + '//' + window.location.host + '<%= ResolveUrl("~/Complaint/Images/logo_new.png") %>';

            var printWin = window.open('', '_blank', 'width=860,height=920');
            printWin.document.write('<!DOCTYPE html><html><head><title>Member Complaint Letter - Ref #' + complaintId + '</title>');
            printWin.document.write('<link rel="preconnect" href="https://fonts.googleapis.com">');
            printWin.document.write('<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=Outfit:wght@400;600;700&display=swap" rel="stylesheet">');
            printWin.document.write('<style>');
            printWin.document.write('@page { size: A4 portrait; margin: 8mm 12mm 8mm 12mm; }');
            printWin.document.write('* { box-sizing: border-box; margin: 0; padding: 0; }');
            printWin.document.write('body { font-family: "Times New Roman", Times, Georgia, serif; color: #111827; line-height: 1.35; background: #f8fafc; font-size: 10.5pt; padding: 16px; }');
            printWin.document.write('.page-sheet { max-width: 780px; margin: 0 auto; background: #ffffff; border: 1px solid #d1d5db; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.06); padding: 24px 30px 18px 30px; position: relative; }');
            printWin.document.write('@media print { html, body { background: #ffffff !important; padding: 0 !important; margin: 0 !important; font-size: 10pt !important; } .page-sheet { border: none !important; box-shadow: none !important; padding: 0 !important; margin: 0 !important; max-width: 100% !important; width: 100% !important; } .no-print { display: none !important; } }');
            printWin.document.write('.letterhead { text-align: center; border-bottom: 1.5px solid #0f1e36; padding-bottom: 8px; margin-bottom: 8px; }');
            printWin.document.write('.header-logo-row { display: flex; align-items: center; justify-content: center; gap: 14px; }');
            printWin.document.write('.club-logo { height: 48px; width: auto; max-width: 120px; object-fit: contain; }');
            printWin.document.write('.header-text { text-align: center; }');
            printWin.document.write('.club-name { font-family: "Playfair Display", Georgia, serif; font-size: 17pt; font-weight: 700; color: #0f1e36; text-transform: uppercase; letter-spacing: 1.5px; margin: 0; line-height: 1.1; }');
            printWin.document.write('.club-address { font-family: "Outfit", "Segoe UI", Arial, sans-serif; font-size: 8pt; color: #4b5563; text-transform: uppercase; letter-spacing: 1px; margin: 2px 0 0 0; }');
            printWin.document.write('.doc-badge { display: inline-block; margin-top: 4px; padding: 2px 10px; background: #0f1e36; color: #c5a059; font-family: "Outfit", "Segoe UI", Arial, sans-serif; font-size: 7.5pt; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; border-radius: 3px; }');
            printWin.document.write('.meta-container { display: flex; justify-content: space-between; font-family: "Outfit", "Segoe UI", Arial, sans-serif; font-size: 8.5pt; border-bottom: 1px solid #e5e7eb; padding-bottom: 5px; margin-bottom: 8px; }');
            printWin.document.write('.status-tag { display: inline-block; font-weight: 700; color: #92400e; background: #fef3c7; padding: 1px 6px; border-radius: 3px; font-size: 8pt; text-transform: uppercase; border: 1px solid #fde68a; }');
            printWin.document.write('.address-table { width: 100%; border-collapse: collapse; margin-bottom: 6px; }');
            printWin.document.write('.address-col { vertical-align: top; font-size: 9.5pt; line-height: 1.35; }');
            printWin.document.write('.address-label { font-family: "Outfit", "Segoe UI", Arial, sans-serif; font-size: 7.5pt; font-weight: 700; text-transform: uppercase; color: #6b7280; letter-spacing: 0.5px; margin-bottom: 1px; }');
            printWin.document.write('.address-val { color: #1e293b; }');
            printWin.document.write('.formal-subject { margin: 6px 0; padding: 5px 8px; background-color: #f8fafc; border-left: 3px solid #c5a059; font-family: "Outfit", "Segoe UI", Arial, sans-serif; font-weight: 700; font-size: 9.5pt; color: #0f1e36; }');
            printWin.document.write('.letter-content { font-size: 10pt; line-height: 1.4; text-align: justify; }');
            printWin.document.write('.salutation { margin-bottom: 3px; font-weight: 600; }');
            printWin.document.write('.intro-text { margin-bottom: 4px; }');
            printWin.document.write('.complaint-box { margin: 4px 0 6px 0; padding: 8px 12px; background-color: #fafafa; border: 1px solid #d1d5db; border-radius: 4px; font-family: "Times New Roman", Times, serif; font-size: 10pt; line-height: 1.4; white-space: pre-wrap; word-break: break-word; color: #111827; min-height: 45px; max-height: 140px; overflow: hidden; }');
            printWin.document.write('.closing-row { display: flex; justify-content: space-between; align-items: flex-end; margin-top: 6px; margin-bottom: 8px; }');
            printWin.document.write('.closing-req { font-size: 9.5pt; max-width: 60%; line-height: 1.35; color: #374151; }');
            printWin.document.write('.signature-block { text-align: right; font-size: 9pt; }');
            printWin.document.write('.signoff-lbl { font-family: "Outfit", "Segoe UI", Arial, sans-serif; font-size: 8pt; color: #6b7280; margin-bottom: 1px; }');
            printWin.document.write('.member-sign-line { border-top: 1px solid #4b5563; padding-top: 2px; display: inline-block; min-width: 140px; font-family: "Outfit", "Segoe UI", Arial, sans-serif; }');
            printWin.document.write('.official-record-box { margin-top: 8px; border: 1.5px solid #0f1e36; border-radius: 6px; background: #fafafa; padding: 8px 12px; page-break-inside: avoid; }');
            printWin.document.write('.official-title { font-family: "Outfit", "Segoe UI", Arial, sans-serif; font-size: 8.5pt; font-weight: 800; text-transform: uppercase; letter-spacing: 0.8px; color: #0f1e36; border-bottom: 1px solid #cbd5e1; padding-bottom: 3px; margin-bottom: 5px; display: flex; justify-content: space-between; }');
            printWin.document.write('.official-table { width: 100%; font-family: "Outfit", "Segoe UI", Arial, sans-serif; font-size: 8.5pt; border-collapse: collapse; }');
            printWin.document.write('.official-table td { padding: 2px 4px; vertical-align: top; }');
            printWin.document.write('.official-lbl { font-weight: 700; color: #4b5563; }');
            printWin.document.write('.official-val { color: #1e293b; }');
            printWin.document.write('.stamp-row { margin-top: 14px; display: flex; justify-content: space-between; font-family: "Outfit", "Segoe UI", Arial, sans-serif; font-size: 8pt; color: #4b5563; }');
            printWin.document.write('.stamp-block { width: 45%; text-align: center; }');
            printWin.document.write('.stamp-line { border-top: 1px dashed #94a3b8; padding-top: 3px; }');
            printWin.document.write('.footer-note { margin-top: 6px; text-align: center; font-family: "Outfit", "Segoe UI", Arial, sans-serif; font-size: 7.5pt; color: #9ca3af; }');
            printWin.document.write('</style></head><body>');
            
            printWin.document.write('<div class="page-sheet">');
            printWin.document.write('<div class="letterhead">');
            printWin.document.write('<div class="header-logo-row">');
            printWin.document.write('<img src="' + logoUrl + '" alt="Lahore Gymkhana Logo" class="club-logo" onerror="this.style.display=\'none\';" />');
            printWin.document.write('<div class="header-text">');
            printWin.document.write('<h1 class="club-name">Lahore Gymkhana</h1>');
            printWin.document.write('<p class="club-address">Club House, Upper Mall, Lahore &middot; Est. 1878</p>');
            printWin.document.write('<span class="doc-badge">Official Member Complaint &amp; Grievance Docket</span>');
            printWin.document.write('</div>');
            printWin.document.write('</div>');
            printWin.document.write('</div>');

            printWin.document.write('<div class="meta-container">');
            printWin.document.write('<div><strong>Ref No:</strong> LGC/CMP/' + complaintId + ' &nbsp;&middot;&nbsp; <strong>Target:</strong> ' + targetDeptFull + '</div>');
            printWin.document.write('<div><strong>Date Filed:</strong> ' + createdDate + ' &nbsp;&middot;&nbsp; <strong>Status:</strong> <span class="status-tag">' + status + '</span></div>');
            printWin.document.write('</div>');

            printWin.document.write('<table class="address-table"><tr>');
            printWin.document.write('<td class="address-col" style="width: 50%;">');
            printWin.document.write('<div class="address-label">To:</div>');
            printWin.document.write('<div class="address-val"><strong>The Convener / Officer In-Charge of ' + deptName + '</strong><br/>' + (subDeptName ? subDeptName + ' Section<br/>' : '') + 'Lahore Gymkhana Club, Upper Mall, Lahore</div>');
            printWin.document.write('</td>');
            printWin.document.write('<td class="address-col" style="width: 50%;">');
            printWin.document.write('<div class="address-label">From (Complainant Member):</div>');
            printWin.document.write('<div class="address-val"><strong>' + memberName + '</strong> ' + (memberNo ? '(M.No: <strong>' + memberNo + '</strong>)' : '(Guest / Visitor)') + '<br/>' + (phone ? 'Phone: ' + phone : '') + (phone && email ? ' &middot; ' : '') + (email ? 'Email: ' + email : '') + '</div>');
            printWin.document.write('</td>');
            printWin.document.write('</tr></table>');

            printWin.document.write('<div class="formal-subject">SUBJECT: FORMAL COMPLAINT REGARDING ' + subject.toUpperCase() + '</div>');

            printWin.document.write('<div class="letter-content">');
            printWin.document.write('<p class="salutation">Respected Sir / Madam,</p>');
            printWin.document.write('<p class="intro-text">I am writing to formally lodge a grievance and bring to your urgent attention the following service issue at <strong>' + targetDeptFull + '</strong>:</p>');
            printWin.document.write('<div class="complaint-box">' + (detail ? detail : 'No detailed description provided.') + '</div>');
            printWin.document.write('<div class="closing-row">');
            printWin.document.write('<div class="closing-req">I kindly request the Club Management to investigate this matter and initiate appropriate remedial actions.</div>');
            printWin.document.write('<div class="signature-block"><div class="signoff-lbl">Yours sincerely,</div><div class="member-sign-line"><strong>' + memberName + '</strong><br/><span>' + (memberNo ? 'M.No: ' + memberNo : 'Complainant') + '</span></div></div>');
            printWin.document.write('</div>');
            printWin.document.write('</div>');

            printWin.document.write('<div class="official-record-box">');
            printWin.document.write('<div class="official-title"><span>FOR OFFICE / MANAGEMENT RECORD &amp; RESOLUTION</span><span>ID: #' + complaintId + '</span></div>');
            printWin.document.write('<table class="official-table">');
            printWin.document.write('<tr><td class="official-lbl" style="width: 85px;">Department:</td><td class="official-val" style="width: 250px;">' + deptName + (subDeptName ? ' &middot; ' + subDeptName : '') + (locationName && locationName !== 'N/A' ? ' (' + locationName + ')' : '') + '</td><td class="official-lbl" style="width: 90px;">Current Status:</td><td class="official-val"><strong>' + status + '</strong></td></tr>');
            printWin.document.write('<tr><td class="official-lbl">Action Remarks:</td><td class="official-val" colspan="3">' + (remarks ? remarks : 'Under active departmental review &amp; investigation.') + '</td></tr>');
            printWin.document.write('</table>');
            printWin.document.write('<div class="stamp-row"><div class="stamp-block"><div class="stamp-line">Reviewed By (Officer)</div></div><div class="stamp-block"><div class="stamp-line">Convener / Secretary Sign &amp; Stamp</div></div></div>');
            printWin.document.write('</div>');

            printWin.document.write('<div class="footer-note">Lahore Gymkhana Club &middot; Official Grievance Documentation System &middot; Generated on ' + new Date().toLocaleDateString() + ' ' + new Date().toLocaleTimeString() + '</div>');
            printWin.document.write('</div>');

            printWin.document.write('</body></html>');
            printWin.document.close();
            printWin.focus();
            setTimeout(function() { printWin.print(); printWin.close(); }, 400);
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphBody" runat="server">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; width: 100%;">
        <div>
            <h2 style="font-family: 'Playfair Display', serif; font-size: 28px; font-weight: 700; color: #0f1e36; margin: 0;">Departmental Feedback & Complaint Panel</h2>
            <p style="color: #64748b; font-size: 14px; margin-top: 6px; margin-bottom: 0;">View, filter, track and review member feedback and complaints for departments and subdepartments.</p>
        </div>
    </div>

    <!-- Alert Message Panel -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false" style="width: 100%; margin-bottom: 20px;">
        <div style='padding: 16px 24px; border-radius: 8px; font-size: 14px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; border-left: 4px solid; width: 100%; box-sizing: border-box; <%= AlertCssClass == "alert-success" ? "background-color: #d1fae5; color: #065f46; border-left-color: #10b981;" : "background-color: #fee2e2; color: #991b1b; border-left-color: #ef4444;" %>'>
            <span><%= AlertMessage %></span>
        </div>
    </asp:Panel>

    <!-- Filters Section -->
    <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); width: 100%; box-sizing: border-box;">
        <h3 style="font-family: 'Playfair Display', serif; font-size: 16px; color: #0f1e36; margin-top: 0; margin-bottom: 16px;">Search & Filter Submissions</h3>
        
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 16px; align-items: end;">
            <div>
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Department</label>
                <asp:DropDownList ID="ddlDeptFilter" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" AutoPostBack="true" OnSelectedIndexChanged="ddlDeptFilter_SelectedIndexChanged" />
            </div>

            <div>
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Subdepartment</label>
                <asp:DropDownList ID="ddlSubDeptFilter" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" Enabled="false" />
            </div>

            <div>
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Record Type</label>
                <asp:DropDownList ID="ddlTypeFilter" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';">
                    <asp:ListItem Text="- All Types -" Value="" />
                    <asp:ListItem Text="Complaints" Value="Complaint" />
                    <asp:ListItem Text="Feedbacks" Value="Feedback" />
                </asp:DropDownList>
            </div>

            <div>
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Status</label>
                <asp:DropDownList ID="ddlStatusFilter" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';">
                    <asp:ListItem Text="- All Statuses -" Value="" />
                    <asp:ListItem Text="Pending" Value="Pending" />
                    <asp:ListItem Text="In Progress" Value="In Progress" />
                    <asp:ListItem Text="Resolved" Value="Resolved" />
                    <asp:ListItem Text="Closed" Value="Closed" />
                    <asp:ListItem Text="Submitted (Feedback)" Value="Submitted" />
                </asp:DropDownList>
            </div>

            <div>
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">From Date</label>
                <asp:TextBox ID="txtFromDate" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" TextMode="Date" />
            </div>

            <div>
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">To Date</label>
                <asp:TextBox ID="txtToDate" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" TextMode="Date" />
            </div>

            <div style="display: flex; gap: 8px; height: 42px;">
                <asp:Button ID="btnSearch" runat="server" Text="Filter" style="flex: 1; padding: 10px 20px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); height: 42px;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnSearch_Click" />
                <asp:Button ID="btnReset" runat="server" Text="Reset" style="padding: 10px 20px; border-radius: 8px; border: 1px solid #cbd5e1; cursor: pointer; font-size: 13px; font-weight: 600; background-color: #ffffff; color: #64748b; transition: all 0.2s ease; height: 42px;" onmouseover="this.style.backgroundColor='#f1f5f9'; this.style.color='#1e293b';" onmouseout="this.style.backgroundColor='#ffffff'; this.style.color='#64748b';" OnClick="btnReset_Click" />
            </div>
        </div>
    </div>

    <!-- Complaints Grid Section -->
    <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); width: 100%; box-sizing: border-box;">
        <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
            <asp:GridView ID="gvComplaints" runat="server" AutoGenerateColumns="false" GridLines="None"
                OnRowCommand="gvComplaints_RowCommand"
                style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;">
                <HeaderStyle CssClass="gv-header" />
                <RowStyle CssClass="gv-row" />
                <AlternatingRowStyle CssClass="gv-alt-row" />
                <Columns>
                    <asp:TemplateField HeaderText="Date Submitted">
                        <HeaderStyle CssClass="gv-header-left" Width="140px" />
                        <ItemStyle CssClass="gv-text-left" Width="140px" />
                        <ItemTemplate>
                            <%# Convert.ToDateTime(Eval("CreatedDate")).ToString("dd-MMM-yyyy hh:mm tt") %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Department / Subdept">
                        <HeaderStyle CssClass="gv-header-left" />
                        <ItemStyle CssClass="gv-text-left" />
                        <ItemTemplate>
                            <div style="font-weight: 600; color: #0f1e36;"><%# Eval("DepartmentName") %></div>
                            <div style="font-size: 12px; color: #64748b; margin-top: 2px;">
                                <%# Eval("SubDepartmentName") != DBNull.Value && !string.IsNullOrEmpty(Eval("SubDepartmentName").ToString()) ? "&nbsp;&nbsp;&rdsh; " + Eval("SubDepartmentName") : "Entire Dept" %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Location">
                        <HeaderStyle CssClass="gv-header-left" Width="130px" />
                        <ItemStyle CssClass="gv-text-left" Width="130px" />
                        <ItemTemplate>
                            <div style="font-weight: 500; color: #334155;">
                                <%# GetLocationDisplay(Eval("LocationName")) %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Member Details">
                        <HeaderStyle CssClass="gv-header-left" />
                        <ItemStyle CssClass="gv-text-left" />
                        <ItemTemplate>
                            <%# FormatMemberDetails(Eval("MemberName"), Eval("MemberNo"), Eval("Email"), Eval("PhoneNumber")) %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Subject & Detail">
                        <HeaderStyle CssClass="gv-header-left" />
                        <ItemStyle CssClass="gv-text-left" />
                        <ItemTemplate>
                            <div style="font-weight: 600; color: #0f1e36;"><%# Eval("Subject") %></div>
                            <div style="font-size: 13px; color: #475569; margin-top: 4px; max-width: 350px; white-space: normal; word-break: break-all;">
                                <%# Eval("Detail") %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Status">
                        <HeaderStyle CssClass="gv-header-left" />
                        <ItemStyle CssClass="gv-text-left" />
                        <ItemTemplate>
                            <span style='display: inline-block; padding: 4px 8px; border-radius: 9999px; font-size: 11px; font-weight: 600; text-transform: uppercase; <%# Eval("Status").ToString() == "Pending" ? "background-color: #fee2e2; color: #991b1b;" : (Eval("Status").ToString() == "In Progress" ? "background-color: #fef3c7; color: #92400e;" : (Eval("Status").ToString() == "Resolved" ? "background-color: #d1fae5; color: #065f46;" : (Eval("Status").ToString() == "Closed" ? "background-color: #f1f5f9; color: #475569;" : "background-color: #e0f2fe; color: #0369a1;"))) %>'>
                                <%# Eval("Status") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Actions">
                        <HeaderStyle CssClass="gv-header-left" />
                        <ItemStyle CssClass="gv-text-left" />
                        <ItemTemplate>
                            <asp:LinkButton ID="lnkAction" runat="server" CommandName="ManageComplaint" CommandArgument='<%# Eval("RecordType") + "|" + Eval("ID") %>' style="text-decoration: none; font-size: 13px; font-weight: 600; color: #c5a059;">Manage & Resolve</asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div style="padding: 30px; text-align: center; color: #64748b;">No complaints found matching the specified filters.</div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>

    <!-- Modal Popup Overlay for Managing & Resolving Complaint -->
    <asp:Panel ID="pnlAction" runat="server" Visible="false" style="position: fixed; top: 0; left: 0; right: 0; bottom: 0; width: 100vw; height: 100vh; background-color: rgba(15, 23, 42, 0.65); backdrop-filter: blur(4px); z-index: 99999; display: flex; align-items: center; justify-content: center; padding: 20px; box-sizing: border-box;">
        <div style="background-color: #ffffff; border-radius: 16px; width: 100%; max-width: 650px; max-height: 90vh; overflow: hidden; display: flex; flex-direction: column; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); border: 1px solid #e2e8f0; animation: modalFadeIn 0.25s cubic-bezier(0.16, 1, 0.3, 1);">
            
            <!-- Modal Header -->
            <div style="padding: 18px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; background-color: #ffffff;">
                <h3 style="font-family: 'Playfair Display', serif; font-size: 20px; font-weight: 700; color: #0f1e36; margin: 0;">Manage & Resolve Submission</h3>
                <asp:LinkButton ID="btnCloseModal" runat="server" OnClick="btnCancelAction_Click" style="text-decoration: none; color: #64748b; font-size: 24px; font-weight: bold; cursor: pointer; line-height: 1; padding: 4px 8px; border-radius: 6px; transition: all 0.2s;" onmouseover="this.style.color='#0f1e36'; this.style.backgroundColor='#f1f5f9';" onmouseout="this.style.color='#64748b'; this.style.backgroundColor='transparent';" ToolTip="Close Modal">&times;</asp:LinkButton>
            </div>
            
            <!-- Modal Body (Scrollable if tall) -->
            <div style="padding: 24px; overflow-y: auto; flex: 1;">
                <asp:HiddenField ID="hfComplaintID" runat="server" />
                <asp:HiddenField ID="hfRecordType" runat="server" />
                <asp:HiddenField ID="hfMemberNo" runat="server" />
                <asp:HiddenField ID="hfMemberName" runat="server" />
                <asp:HiddenField ID="hfMemberEmail" runat="server" />
                <asp:HiddenField ID="hfMemberPhone" runat="server" />
                <asp:HiddenField ID="hfDepartmentName" runat="server" />
                <asp:HiddenField ID="hfSubDepartmentName" runat="server" />
                <asp:HiddenField ID="hfLocationName" runat="server" />
                <asp:HiddenField ID="hfCreatedDate" runat="server" />

                <!-- Details Header Box -->
                <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 16px; margin-bottom: 20px; background: #f8fafc; padding: 16px; border-radius: 10px; border: 1px solid #e2e8f0;">
                    <div>
                        <p style="margin: 0 0 6px 0; font-size: 11px; color: #64748b; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Subject</p>
                        <p style="margin: 0; font-size: 14px; font-weight: 700; color: #0f1e36; word-break: break-word;"><span id="spnCompSubject"><asp:Literal ID="litCompSubject" runat="server" /></span></p>
                    </div>
                    <div>
                        <p style="margin: 0 0 6px 0; font-size: 11px; color: #64748b; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Member Details</p>
                        <p style="margin: 0; font-size: 13.5px; font-weight: 600; color: #334155; word-break: break-word;"><span id="spnCompMember"><asp:Literal ID="litCompMember" runat="server" /></span></p>
                    </div>
                    <div>
                        <p style="margin: 0 0 6px 0; font-size: 11px; color: #64748b; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Location</p>
                        <p style="margin: 0; font-size: 13.5px; font-weight: 600; color: #334155; word-break: break-word;"><span id="spnCompLocation"><asp:Literal ID="litCompLocation" runat="server" /></span></p>
                    </div>
                </div>

                <!-- Detail / Description Box -->
                <div style="margin-bottom: 20px;">
                    <p style="margin: 0 0 6px 0; font-size: 11px; color: #64748b; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Complaint / Feedback Details</p>
                    <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 14px; font-size: 13.5px; color: #334155; line-height: 1.5; white-space: pre-wrap; word-break: break-word; max-height: 160px; overflow-y: auto;">
                        <span id="spnCompDetail"><asp:Literal ID="litCompDetail" runat="server" /></span>
                    </div>
                </div>

                <!-- Update Status & Remarks Form -->
                <div style="display: grid; grid-template-columns: 180px 1fr; gap: 16px; margin-bottom: 10px;">
                    <div>
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Update Status *</label>
                        <asp:DropDownList ID="ddlUpdateStatus" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';">
                            <asp:ListItem Text="Pending" Value="Pending" />
                            <asp:ListItem Text="In Progress" Value="In Progress" />
                            <asp:ListItem Text="Resolved" Value="Resolved" />
                            <asp:ListItem Text="Closed" Value="Closed" />
                        </asp:DropDownList>
                    </div>
                    <div>
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Resolution / Action Remarks *</label>
                        <asp:TextBox ID="txtRemarks" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" TextMode="MultiLine" Rows="3" placeholder="Describe actions taken, investigations, or contact details..." />
                    </div>
                </div>
            </div>

            <!-- Modal Footer -->
            <div style="padding: 16px 24px; background-color: #f8fafc; border-top: 1px solid #e2e8f0; display: flex; gap: 12px; justify-content: flex-end; align-items: center;">
                <button type="button" onclick="printModalSummary();" style="margin-right: auto; padding: 10px 18px; border-radius: 8px; border: 1px solid #cbd5e1; cursor: pointer; font-size: 13px; font-weight: 600; background-color: #ffffff; color: #0f1e36; transition: all 0.2s ease; height: 40px; display: inline-flex; align-items: center; gap: 8px;" onmouseover="this.style.backgroundColor='#f1f5f9';" onmouseout="this.style.backgroundColor='#ffffff';">
                    <i class="fas fa-print" style="color: #c5a059;"></i> Print Summary
                </button>
                <asp:Button ID="btnCancelAction" runat="server" Text="Cancel" style="padding: 10px 20px; border-radius: 8px; border: 1px solid #cbd5e1; cursor: pointer; font-size: 13px; font-weight: 600; background-color: #ffffff; color: #64748b; transition: all 0.2s ease; height: 40px;" onmouseover="this.style.backgroundColor='#f1f5f9'; this.style.color='#1e293b';" onmouseout="this.style.backgroundColor='#ffffff'; this.style.color='#64748b';" OnClick="btnCancelAction_Click" />
                <asp:Button ID="btnSaveStatus" runat="server" Text="Update Submission" style="padding: 10px 20px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); height: 40px;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(197, 160, 89, 0.3)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(197, 160, 89, 0.2)';" OnClick="btnSaveStatus_Click" />
            </div>
        </div>
    </asp:Panel>
</asp:Content>
