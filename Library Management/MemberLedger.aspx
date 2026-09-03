<%@ page language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" autoeventwireup="true" CodeFile="MemberLedger.aspx.cs" Inherits="Pages_Members_MemberLedger" title="Member Ledger - Lahore Gymkhana Library" %>

<asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        /* Minimal stylesheet for print overrides */
        @media print {
            @page {
                size: landscape;
                margin: 0.4in;
            }
            aside, header, .filter-container, .btn-action-primary, .btn-action-gold, .btn-action-clear, .no-print {
                display: none !important;
            }
            .print-only {
                display: block !important;
            }
            main {
                margin-left: 0 !important;
                padding: 0 !important;
            }
            .ledger-grid-wrapper {
                overflow: visible !important;
                border: none !important;
                margin-top: 0 !important;
            }
            .ledger-grid {
                width: 100% !important;
                max-width: 100% !important;
                border: 1px solid #cbd5e1 !important;
                table-layout: auto !important;
                word-break: break-word !important;
            }
            .ledger-grid th {
                background-color: #0f1e36 !important;
                color: #ffffff !important;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
                padding: 6px 8px !important;
                font-size: 10px !important;
                white-space: normal !important;
                word-wrap: break-word !important;
            }
            .ledger-grid td {
                padding: 6px 8px !important;
                font-size: 10px !important;
                white-space: normal !important;
                word-wrap: break-word !important;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">

<!-- Header Banner -->
<div class="no-print" style="background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; padding: 20px 28px; border-radius: 8px; margin-bottom: 24px; border-bottom: 3px solid #c5a059; display: flex; justify-content: space-between; align-items: center; width: 100%; box-sizing: border-box;">
    <div style="display: block;">
        <h2 style="margin: 0; font-size: 22px; font-weight: 600;">Member Ledger</h2>
        <p style="margin: 4px 0 0; opacity: .8; font-size: 13px; font-weight: 300;">Lahore Gymkhana Club - Member profile details, book loans, facility usage, and outstanding ledger balance</p>
    </div>
</div>

<!-- Print-Only Letterhead -->
<div class="print-only" style="margin-bottom: 20px; border-bottom: 2px solid #cbd5e1; padding-bottom: 10px; text-align: left; width: 100%;">
    <img src='<%= ResolveUrl("~/Library Management/Images/logo_new.png") %>' alt="Lahore Gymkhana Logo" style="height: 65px; display: inline-block; margin: 0; object-fit: contain;" />
</div>

<asp:UpdatePanel ID="upMemberLedger" runat="server" UpdateMode="Conditional">
<Triggers>
    <asp:PostBackTrigger ControlID="btnExportExcel" />
</Triggers>
<ContentTemplate>

<!-- Alert Panel -->
<asp:Panel ID="pnlAlert" runat="server" Visible="false" style="width: 100%;">
    <div id="divAlert" runat="server" style="padding: 16px 24px; border-radius: 8px; font-size: 14px; margin-bottom: 24px; border-left: 4px solid transparent; width: 100%; box-sizing: border-box;">
        <asp:Literal ID="litAlertMsg" runat="server" />
    </div>
</asp:Panel>

<!-- Search and Filters Section -->
<div style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px; width: 100%; box-sizing: border-box;" class="no-print">
    <div style="display: flex; gap: 16px; flex-wrap: wrap; align-items: flex-end; width: 100%; box-sizing: border-box;">
        <div style="display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 180px; max-width: 100%; box-sizing: border-box;">
            <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Member Number</span>
            <asp:TextBox ID="txtMemberNo" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Search by number (e.g. LGC-2024)..." autocomplete="off" list="dlMemberNo" oninput="fetchMembersNo(this.value)" />
            <datalist id="dlMemberNo"></datalist>
        </div>
        <div style="display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 180px; max-width: 100%; box-sizing: border-box;">
            <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Member Name</span>
            <asp:TextBox ID="txtMemberName" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Search by name..." autocomplete="off" list="dlMemberName" oninput="fetchMembersName(this.value)" />
            <datalist id="dlMemberName"></datalist>
        </div>
        <div style="display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 180px; max-width: 100%; box-sizing: border-box;">
            <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Start Date</span>
            <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
        </div>
        <div style="display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 180px; max-width: 100%; box-sizing: border-box;">
            <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">End Date</span>
            <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
        </div>
        <div style="display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 130px; max-width: 150px; box-sizing: border-box;">
            <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Month</span>
            <asp:DropDownList ID="ddlMonth" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';">
                <asp:ListItem Value="0" Selected="True">- All Months -</asp:ListItem>
                <asp:ListItem Value="1">January</asp:ListItem>
                <asp:ListItem Value="2">February</asp:ListItem>
                <asp:ListItem Value="3">March</asp:ListItem>
                <asp:ListItem Value="4">April</asp:ListItem>
                <asp:ListItem Value="5">May</asp:ListItem>
                <asp:ListItem Value="6">June</asp:ListItem>
                <asp:ListItem Value="7">July</asp:ListItem>
                <asp:ListItem Value="8">August</asp:ListItem>
                <asp:ListItem Value="9">September</asp:ListItem>
                <asp:ListItem Value="10">October</asp:ListItem>
                <asp:ListItem Value="11">November</asp:ListItem>
                <asp:ListItem Value="12">December</asp:ListItem>
            </asp:DropDownList>
        </div>
        <div style="display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 100px; max-width: 120px; box-sizing: border-box;">
            <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Year</span>
            <asp:DropDownList ID="ddlYear" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';">
                <asp:ListItem Value="0" Selected="True">- All -</asp:ListItem>
            </asp:DropDownList>
        </div>
    </div>
    <div style="display: flex; gap: 12px; justify-content: flex-end; flex-wrap: wrap; border-top: 1px solid #e2e8f0; padding-top: 16px; box-sizing: border-box;">
        <asp:Button ID="btnSearch" runat="server" Text="Generate Ledger" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnSearch_Click" />
        <asp:Button ID="btnExportExcel" runat="server" Text="Export Excel" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(197, 160, 89, 0.3)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(197, 160, 89, 0.2)';" OnClick="btnExportExcel_Click" />
        <button type="button" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(0, 0, 0, 0.1)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(0, 0, 0, 0.05)';" onclick="printLedger()">Print / PDF</button>
        <asp:Button ID="btnClear" runat="server" Text="Clear Filters" style="padding: 12px 24px; border-radius: 8px; border: 1px solid #cbd5e1; cursor: pointer; font-size: 13px; font-weight: 600; background-color: #ffffff; color: #64748b; transition: all 0.2s ease; display: inline-block;" onmouseover="this.style.backgroundColor='#f1f5f9'; this.style.color='#1e293b';" onmouseout="this.style.backgroundColor='#ffffff'; this.style.color='#64748b';" OnClick="btnClear_Click" />
    </div>
</div>

<!-- Hidden selected member state -->
<asp:HiddenField ID="hfSelectedMemberID" runat="server" Value="" />

<!-- Member Details Statement (Visible only when a member is selected) -->
<asp:Panel ID="pnlLedgerContent" runat="server" Visible="false" style="width: 100%;">
    
    <!-- Member Profile Header Card -->
    <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px; display: flex; gap: 24px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); flex-wrap: wrap;">
        <div style="flex: 1; min-width: 250px;">
            <h3 style="font-size: 18px; font-weight: 700; color: #0f1e36; margin: 0 0 16px 0; border-bottom: 2px solid #cbd5e1; padding-bottom: 8px;">Member Profile</h3>
            <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
                <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 600; width: 140px;">Membership No:</td>
                    <td style="padding: 6px 0; font-weight: 700; color: #0f1e36;"><asp:Label ID="lblMembershipNo" runat="server" /></td>
                </tr>
                <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 600;">Full Name:</td>
                    <td style="padding: 6px 0; font-weight: 600; color: #0f1e36;"><asp:Label ID="lblFullName" runat="server" /></td>
                </tr>
                <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 600;">Member Type:</td>
                    <td style="padding: 6px 0; color: #0f1e36;"><asp:Label ID="lblMemberType" runat="server" /></td>
                </tr>
                <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 600;">CNIC:</td>
                    <td style="padding: 6px 0; color: #0f1e36;"><asp:Label ID="lblCNIC" runat="server" /></td>
                </tr>
            </table>
        </div>
        <div style="flex: 1; min-width: 250px;">
            <h3 style="font-size: 18px; font-weight: 700; color: #0f1e36; margin: 0 0 16px 0; border-bottom: 2px solid #cbd5e1; padding-bottom: 8px;">Contact & Status</h3>
            <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
                <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 600; width: 120px;">Phone:</td>
                    <td style="padding: 6px 0; color: #0f1e36;"><asp:Label ID="lblPhone" runat="server" /></td>
                </tr>
                <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 600;">Email:</td>
                    <td style="padding: 6px 0; color: #0f1e36;"><asp:Label ID="lblEmail" runat="server" /></td>
                </tr>
                <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 600;">Join Date:</td>
                    <td style="padding: 6px 0; color: #0f1e36;"><asp:Label ID="lblJoinDate" runat="server" /></td>
                </tr>
                <tr>
                    <td style="padding: 6px 0; color: #64748b; font-weight: 600;">Status:</td>
                    <td style="padding: 6px 0;"><asp:Label ID="lblStatusBadge" runat="server" /></td>
                </tr>
            </table>
        </div>
    </div>

    <!-- Summary Metrics Card -->
    <div style="display: flex; gap: 16px; flex-wrap: wrap; margin-bottom: 24px; width: 100%;">
        <div style="flex: 1; min-width: 160px; background: #ffffff; border: 1px solid #e2e8f0; border-left: 4px solid #c5a059; border-radius: 10px; padding: 18px; box-sizing: border-box; box-shadow: 0 1px 2px rgba(0,0,0,0.02); position: relative; overflow: hidden;">
            <div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Total Loans</div>
            <div style="font-size: 26px; font-weight: 700; color: #0f1e36; margin-top: 4px;"><asp:Label ID="lblTotalLoans" runat="server" Text="0" /></div>
        </div>
        <div style="flex: 1; min-width: 160px; background: #ffffff; border: 1px solid #e2e8f0; border-left: 4px solid #3b82f6; border-radius: 10px; padding: 18px; box-sizing: border-box; box-shadow: 0 1px 2px rgba(0,0,0,0.02); position: relative; overflow: hidden;">
            <div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Active Loans</div>
            <div style="font-size: 26px; font-weight: 700; color: #3b82f6; margin-top: 4px;"><asp:Label ID="lblActiveLoans" runat="server" Text="0" /></div>
        </div>
        <div style="flex: 1; min-width: 160px; background: #ffffff; border: 1px solid #e2e8f0; border-left: 4px solid #10b981; border-radius: 10px; padding: 18px; box-sizing: border-box; box-shadow: 0 1px 2px rgba(0,0,0,0.02); position: relative; overflow: hidden;">
            <div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Total Fines Charged</div>
            <div style="font-size: 22px; font-weight: 700; color: #10b981; margin-top: 4px;">Rs. <asp:Label ID="lblTotalFines" runat="server" Text="0.00" /></div>
        </div>
        <div style="flex: 1; min-width: 160px; background: #ffffff; border: 1px solid #e2e8f0; border-left: 4px solid #ef4444; border-radius: 10px; padding: 18px; box-sizing: border-box; box-shadow: 0 1px 2px rgba(0,0,0,0.02); position: relative; overflow: hidden;">
            <div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Outstanding Balance</div>
            <div style="font-size: 22px; font-weight: 700; color: #ef4444; margin-top: 4px;">Rs. <asp:Label ID="lblOutstandingBalance" runat="server" Text="0.00" /></div>
        </div>
    </div>

    <!-- Unified Ledger Entries Section -->
    <h3 style="font-size: 16px; font-weight: 700; color: #0f1e36; margin: 0 0 10px 0; text-transform: uppercase; letter-spacing: 0.5px;">Ledger Statement</h3>
    <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 20px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
        <asp:GridView ID="gvLedger" runat="server" AutoGenerateColumns="False" GridLines="None"
            DataKeyNames="Reference,TxnType"
            style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;">
            <HeaderStyle CssClass="gv-header" />
            <RowStyle CssClass="gv-row" />
            <AlternatingRowStyle CssClass="gv-alt-row" />
            <Columns>
                <asp:TemplateField HeaderText="Date">
                    <HeaderStyle CssClass="gv-header-left" />
                    <ItemStyle CssClass="gv-text-left" />
                    <ItemTemplate>
                        <%# Eval("TxnDate", "{0:dd MMM yyyy}") %>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Transaction Type">
                    <HeaderStyle CssClass="gv-header-left" />
                    <ItemStyle CssClass="gv-text-left" />
                    <ItemTemplate>
                        <span style='<%# GetTxnTypeBadgeStyle(Eval("TxnType").ToString()) %>'>
                            <%# Eval("TxnType") %>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Description / Facility / Book Details">
                    <HeaderStyle CssClass="gv-header-left" />
                    <ItemStyle CssClass="gv-text-left" />
                    <ItemTemplate>
                        <%# Eval("Description") %>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Ref Number">
                    <HeaderStyle CssClass="gv-header-left" />
                    <ItemStyle CssClass="gv-text-left" />
                    <ItemTemplate>
                        <%# Eval("Reference") %>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Amount">
                    <HeaderStyle CssClass="gv-header gv-text-right" />
                    <ItemStyle CssClass="gv-text-right" />
                    <ItemTemplate>
                        <%# Eval("TxnType").ToString() == "Book Loan" ? "-" : "Rs. " + Eval("Amount", "{0:N2}") %>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Status">
                    <HeaderStyle CssClass="gv-header gv-text-center" />
                    <ItemStyle CssClass="gv-text-center" />
                    <ItemTemplate>
                        <span style='<%# GetStatusBadgeStyle(Eval("Status").ToString()) %>'>
                            <%# Eval("Status") %>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
            <EmptyDataTemplate>
                <div style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff; border: none;">No transactions found matching the filter criteria.</div>
            </EmptyDataTemplate>
        </asp:GridView>
    </div>
</asp:Panel>

<!-- Empty State Panel -->
<asp:Panel ID="pnlEmptyState" runat="server" style="padding: 60px 40px; text-align: center; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); margin-top: 20px;">
    <div style="font-size: 40px; color: #cbd5e1; margin-bottom: 16px;">ðŸ”</div>
    <h3 style="font-size: 16px; font-weight: 600; color: #64748b; margin: 0 0 8px 0;">No Member Selected</h3>
    <p style="font-size: 14px; color: #94a3b8; margin: 0;">Use the search filters above to search for a library member and generate their unified ledger statement.</p>
</asp:Panel>

</ContentTemplate>
</asp:UpdatePanel>

<script>
    // Fetch suggestions by member number
    let memberNoTimeout;
    function fetchMembersNo(term) {
        if (term.length < 2) {
            document.getElementById('dlMemberNo').innerHTML = '';
            return;
        }
        clearTimeout(memberNoTimeout);
        memberNoTimeout = setTimeout(() => {
            fetch('Reports.aspx/GetMemberSuggestions', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ term: term })
            })
            .then(res => res.json())
            .then(data => {
                const dl = document.getElementById('dlMemberNo');
                dl.innerHTML = '';
                data.d.forEach(item => {
                    const opt = document.createElement('option');
                    opt.value = item.label;
                    dl.appendChild(opt);
                });
            })
            .catch(err => console.error('Error fetching members by number:', err));
        }, 300);
    }

    // Fetch suggestions by member name
    let memberNameTimeout;
    function fetchMembersName(term) {
        if (term.length < 2) {
            document.getElementById('dlMemberName').innerHTML = '';
            return;
        }
        clearTimeout(memberNameTimeout);
        memberNameTimeout = setTimeout(() => {
            fetch('Reports.aspx/GetMemberSuggestions', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ term: term })
            })
            .then(res => res.json())
            .then(data => {
                const dl = document.getElementById('dlMemberName');
                dl.innerHTML = '';
                data.d.forEach(item => {
                    const opt = document.createElement('option');
                    opt.value = item.label;
                    dl.appendChild(opt);
                });
            })
            .catch(err => console.error('Error fetching members by name:', err));
        }, 300);
    }

    // Native browser print helper
    function printLedger() {
        var printDateEl = document.getElementById('printDate');
        if (printDateEl) {
            var now = new Date();
            printDateEl.textContent = now.toLocaleDateString() + ' ' + now.toLocaleTimeString();
        }
        window.print();
    }
</script>

</asp:Content>
