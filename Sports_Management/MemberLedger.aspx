<%@ Page Title="Member Ledger" Language="C#" MasterPageFile="~/Sports_Management/SiteSports.master" AutoEventWireup="true" CodeFile="MemberLedger.aspx.cs" Inherits="MemberLedger" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* ========== Ledger Table ========== */
        .ledger-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }
        .ledger-table thead th {
            background: #1a2332;
            color: #c9a84c;
            padding: 12px 15px;
            text-align: left;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 2px solid #c9a84c;
        }
        .ledger-table thead th:nth-child(4),
        .ledger-table thead th:nth-child(5),
        .ledger-table thead th:nth-child(6),
        .ledger-table thead th:nth-child(7) {
            text-align: right;
        }
        .ledger-table tbody td {
            padding: 10px 15px;
            border-bottom: 1px solid #eaedf1;
            color: #333;
            vertical-align: middle;
        }
        .ledger-table tbody tr:hover {
            background: #fefcf5;
        }
        .ledger-table tbody tr:nth-child(even) {
            background: #fafbfc;
        }
        .ledger-table tbody tr:nth-child(even):hover {
            background: #fefcf5;
        }
        .ledger-table tbody td:nth-child(5),
        .ledger-table tbody td:nth-child(6),
        .ledger-table tbody td:nth-child(7) {
            text-align: right;
            font-weight: 600;
        }
        .ledger-table tbody td:nth-child(1) {
            color: #555;
            white-space: nowrap;
            font-size: 12px;
        }
        .ledger-table tbody td:nth-child(2) {
            color: #1a2332;
            font-weight: 600;
            font-size: 12px;
        }
        .ledger-table tbody td:nth-child(3) {
            color: #0066cc;
            font-weight: 500;
        }
        
        .amt-debit { color: #d42a2a; }
        .amt-credit { color: #1a8a3f; }
        .amt-zero { color: #ccc; }
        .amt-bal { color: #1a2332; font-weight: 800 !important; }
        .amt-bal-negative { color: #d42a2a; font-weight: 800 !important; }

        /* ========== Summary Footer Row ========== */
        .ledger-summary-row {
            background: #f5f6f8;
            border-top: 2px solid #1a2332;
            padding: 18px 20px;
            display: flex;
            justify-content: space-around;
            align-items: center;
            gap: 15px;
        }
        .summary-item {
            text-align: center;
            flex: 1;
        }
        .summary-item .s-label {
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            color: #888;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }
        .summary-item .s-value {
            font-size: 20px;
            font-weight: 800;
        }
        .s-value.debit-color { color: #d42a2a; }
        .s-value.credit-color { color: #1a8a3f; }

        /* ========== Outstanding Balance Bar ========== */
        .outstanding-bar {
            background: linear-gradient(135deg, #1a2332 0%, #2c3e55 100%);
            padding: 18px 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-radius: 0 0 8px 8px;
        }
        .outstanding-bar .ob-label {
            color: #fff;
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .outstanding-bar .ob-value {
            color: #c9a84c;
            font-size: 26px;
            font-weight: 800;
        }

        /* ========== Member Info Card ========== */
        .member-details-card {
            background-color: #f0f7ff;
            border-left: 4px solid var(--info);
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        .member-info-row {
            display: flex;
            gap: 20px;
            margin-bottom: 10px;
        }
        .member-info-item {
            flex: 1;
        }
        .member-info-label {
            font-size: 11px;
            color: var(--gray-500);
            text-transform: uppercase;
            font-weight: 700;
        }
        .member-info-value {
            font-size: 14px;
            color: var(--primary-dark);
            font-weight: 600;
        }

        /* ========== Ledger Card Wrapper ========== */
        .ledger-card {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.08);
            overflow: hidden;
            border: 1px solid #e0e4ea;
        }
        .ledger-card-header {
            background: #1a2332;
            color: #fff;
            padding: 15px 20px;
            font-size: 14px;
            font-weight: 700;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .ledger-card-header .badge-gold {
            background: #c9a84c;
            color: #1a2332;
            padding: 3px 12px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 700;
        }

        /* ========== Print Only Header ========== */
        .print-report-header {
            display: none;
        }

        /* ========== Print ========== */
        @media print {
            /* Reset page */
            @page {
                size: A4 landscape;
                margin: 10mm 12mm;
            }

            /* Hide EVERYTHING from master page and non-report UI */
            .sidebar,
            .top-header,
            .page-header-card,
            .no-print,
            .member-details-card,
            .ledger-card-header {
                display: none !important;
            }

            /* Remove all layout constraints from master page */
            body {
                overflow: visible !important;
                background: white !important;
                font-size: 11px !important;
            }
            .app {
                display: block !important;
                height: auto !important;
                overflow: visible !important;
            }
            .main-content {
                display: block !important;
                overflow: visible !important;
            }
            .content-wrapper {
                overflow: visible !important;
                padding: 0 !important;
            }

            /* Remove flex layout from ledger area */
            #MainContent_pnlLedgerArea > div {
                display: block !important;
            }

            /* Show print-only report header */
            .print-report-header {
                display: block !important;
                text-align: center;
                margin-bottom: 15px;
                padding-bottom: 12px;
                border-bottom: 2px solid #1a2332;
            }
            .print-logo {
                width: 60px;
                height: auto;
                margin-bottom: 5px;
            }
            .print-report-header h2 {
                font-size: 18px;
                font-weight: 800;
                color: #1a2332;
                margin: 0 0 3px 0;
            }
            .print-report-header p {
                font-size: 11px;
                color: #555;
                margin: 0;
            }
            .print-member-info {
                display: flex !important;
                justify-content: space-between;
                margin-top: 10px;
                padding: 8px 0;
                border-top: 1px solid #ddd;
                font-size: 12px;
            }
            .print-member-info span {
                color: #333;
            }
            .print-member-info strong {
                color: #1a2332;
            }

            /* Ledger card - remove decorations */
            .ledger-card {
                box-shadow: none !important;
                border: none !important;
                border-radius: 0 !important;
            }

            /* Table styles for print */
            .ledger-table {
                font-size: 11px !important;
            }
            .ledger-table thead th {
                background: #1a2332 !important;
                color: #fff !important;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
                padding: 8px 10px !important;
                font-size: 10px !important;
            }
            .ledger-table tbody td {
                padding: 6px 10px !important;
                border-bottom: 1px solid #ddd !important;
            }

            /* Summary row */
            .ledger-summary-row {
                background: #f5f6f8 !important;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
                padding: 12px 15px !important;
                border-top: 2px solid #1a2332 !important;
            }
            .s-value {
                font-size: 16px !important;
            }

            /* Outstanding bar */
            .outstanding-bar {
                background: #1a2332 !important;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
                padding: 12px 20px !important;
                border-radius: 0 !important;
            }
            .ob-label {
                color: #fff !important;
            }
            .ob-value {
                color: #c9a84c !important;
                font-size: 20px !important;
            }

            /* Force color printing */
            .amt-debit { color: #d42a2a !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            .amt-credit { color: #1a8a3f !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            .amt-bal, .amt-bal-negative { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-header-card no-print">
        <h2><i class="fas fa-file-invoice-dollar" style="margin-right:10px;"></i> Member Ledger</h2>
        <span class="badge">Financial Statement</span>
    </div>

    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert no-print" style="display:block; margin-bottom: 20px; padding: 15px; border-radius: 8px; font-weight: bold;"></asp:Label>

    <!-- Search Section -->
    <div class="card no-print">
        <div class="card-header">Search Member</div>
        <div class="card-body">
            <div style="display:flex; gap:10px; align-items:flex-end;">
                <div class="form-group" style="margin-bottom:0; flex:1; max-width:400px;">
                    <label>Member ID / Name</label>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Enter MEM-001 or Name..."></asp:TextBox>
                </div>
                <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="btnSearch_Click" />
            </div>

            <asp:Panel ID="pnlSearchResults" runat="server" Visible="false" style="margin-top: 15px;">
                <div class="form-group" style="margin-bottom:0; max-width:500px;">
                    <label style="color:var(--primary); font-weight:700;">Select Member / Dependent <span style="color:red">*</span></label>
                    <asp:DropDownList ID="ddlMemberNames" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlMemberNames_SelectedIndexChanged">
                    </asp:DropDownList>
                </div>
            </asp:Panel>
        </div>
    </div>

    <asp:Panel ID="pnlLedgerArea" runat="server" Visible="false">
        
        <div style="display:flex; gap:20px; align-items:flex-start; flex-wrap:wrap;">
            
            <!-- Left Side: Member Details & Add Payment -->
            <div style="flex:1; min-width:300px;">
                <div class="member-details-card">
                    <h4 style="margin-bottom:15px; color:var(--primary); font-weight:700;"><i class="fas fa-user-circle"></i> Member Information</h4>
                    <div class="member-info-row">
                        <div class="member-info-item">
                            <div class="member-info-label">Member No</div>
                            <div class="member-info-value"><asp:Label ID="lblMemberNo" runat="server"></asp:Label></div>
                            <asp:HiddenField ID="hfMemberID" runat="server" />
                            <asp:HiddenField ID="hfDependentMemberNo" runat="server" />
                            <asp:HiddenField ID="hfDependentName" runat="server" />
                            <asp:HiddenField ID="hfDependentRelation" runat="server" />
                        </div>
                        <div class="member-info-item">
                            <div class="member-info-label">Full Name</div>
                            <div class="member-info-value"><asp:Label ID="lblFullName" runat="server"></asp:Label></div>
                        </div>
                        <div class="member-info-item">
                            <div class="member-info-label">Status</div>
                            <div class="member-info-value"><asp:Label ID="lblStatus" runat="server"></asp:Label></div>
                        </div>
                        <div class="member-info-item">
                            <div class="member-info-label">Relationship</div>
                            <div class="member-info-value">
                                <asp:Label ID="lblRelationship" runat="server" style="padding: 3px 10px; border-radius: 12px; font-size: 12px; font-weight: 700;"></asp:Label>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card no-print">
                    <div class="card-header">Receive Payment</div>
                    <div class="card-body">
                        <div class="form-group">
                            <label>Amount (PKR)</label>
                            <asp:TextBox ID="txtPayAmount" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label>Description / Remarks</label>
                            <asp:TextBox ID="txtPayDesc" runat="server" CssClass="form-control" placeholder="e.g. Cash Payment for Gym"></asp:TextBox>
                        </div>
                        <asp:Button ID="btnAddPayment" runat="server" Text="Post Payment to Ledger" CssClass="btn btn-primary" style="width:100%" OnClick="btnAddPayment_Click" />
                    </div>
                </div>

                <div class="card no-print" style="margin-top: 20px;">
                    <div class="card-header" style="background: var(--danger);">Ledger Reversal / Adjustment</div>
                    <div class="card-body">
                        <div class="form-group">
                            <label>Entry Type</label>
                            <asp:DropDownList ID="ddlReversalType" runat="server" CssClass="form-control">
                                <asp:ListItem Text="Credit (Pay Back / Refund)" Value="Credit"></asp:ListItem>
                                <asp:ListItem Text="Debit (Charge / Fine)" Value="Debit"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="form-group">
                            <label>Amount (PKR)</label>
                            <asp:TextBox ID="txtReversalAmount" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label>Reason / Description</label>
                            <asp:TextBox ID="txtReversalDesc" runat="server" CssClass="form-control" placeholder="e.g. Reversal for wrong Gym entry"></asp:TextBox>
                        </div>
                        <asp:Button ID="btnPostReversal" runat="server" Text="Post Adjustment" CssClass="btn" style="width:100%; background-color: var(--danger); color: white;" OnClick="btnPostReversal_Click" />
                    </div>
                </div>
            </div>

            <!-- Right Side: Ledger Statement -->
            <div style="flex:2; min-width:550px;">
                
                <div class="ledger-card">
                    <div class="ledger-card-header">
                        <span><i class="fas fa-scroll" style="margin-right:8px;"></i> Ledger Statement</span>
                        <span class="badge-gold">
                            <asp:Label ID="lblMemberNoHeader" runat="server"></asp:Label>
                        </span>
                    </div>

                    <!-- Print-Only Report Header (hidden on screen, visible only when printing) -->
                    <div class="print-report-header">
                        <img src="images/lg-logo.png" alt="Lahore Gymkhana" class="print-logo" />
                        <h2>Lahore Gymkhana Club</h2>
                        <p>Sports Management - Member Ledger Statement</p>
                        <div class="print-member-info">
                            <span>Member No: <strong><asp:Label ID="lblPrintMemberNo" runat="server"></asp:Label></strong></span>
                            <span>Member Name: <strong><asp:Label ID="lblPrintMemberName" runat="server"></asp:Label></strong></span>
                            <span>Print Date: <strong><%= DateTime.Now.ToString("dd-MMM-yyyy hh:mm tt") %></strong></span>
                        </div>
                    </div>

                    <!-- Table -->
                    <div style="overflow-x:auto;">
                        <asp:Repeater ID="rptLedger" runat="server">
                            <HeaderTemplate>
                                <table class="ledger-table">
                                    <thead>
                                        <tr>
                                            <th style="width:140px;">Date</th>
                                            <th style="width:130px;">Ref / Inv #</th>
                                            <th>Description</th>
                                            <th style="width:110px;">Used By</th>
                                            <th style="width:110px;">Debit (Charge)</th>
                                            <th style="width:110px;">Credit (Pay)</th>
                                            <th style="width:110px;">Running Bal</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td><%# Convert.ToDateTime(Eval("TransactionDate")).ToString("dd-MMM-yy HH:mm") %></td>
                                    <td><%# Eval("RefNo") %></td>
                                    <td><%# Eval("Description") %></td>
                                    <td>
                                        <span style="background: #eef2f6; padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: 700; color: #333;">
                                            <%# Eval("DependentRelation") == DBNull.Value || string.IsNullOrEmpty(Convert.ToString(Eval("DependentRelation"))) ? "Main Member" : Eval("DependentRelation") %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class='<%# Convert.ToDecimal(Eval("DebitAmount")) > 0 ? "amt-debit" : "amt-zero" %>'>
                                            <%# Convert.ToDecimal(Eval("DebitAmount")) > 0 ? Convert.ToDecimal(Eval("DebitAmount")).ToString("N0") : "0" %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class='<%# Convert.ToDecimal(Eval("CreditAmount")) > 0 ? "amt-credit" : "amt-zero" %>'>
                                            <%# Convert.ToDecimal(Eval("CreditAmount")) > 0 ? Convert.ToDecimal(Eval("CreditAmount")).ToString("N0") : "0" %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class='<%# Convert.ToDecimal(Eval("RunningBalance")) < 0 ? "amt-credit" : (Convert.ToDecimal(Eval("RunningBalance")) > 0 ? "amt-debit" : "amt-bal") %>'>
                                            <%# Math.Abs(Convert.ToDecimal(Eval("RunningBalance"))).ToString("N0") %> <%# Convert.ToDecimal(Eval("RunningBalance")) < 0 ? "(Cr)" : (Convert.ToDecimal(Eval("RunningBalance")) > 0 ? "(Dr)" : "") %>
                                        </span>
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                    </tbody>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>

                        <asp:Panel ID="pnlNoRecords" runat="server" Visible="false">
                            <div style="padding:30px; text-align:center; color:#999; font-style:italic;">
                                No ledger entries found for this member.
                            </div>
                        </asp:Panel>
                    </div>

                    <!-- Summary Row -->
                    <div class="ledger-summary-row">
                        <div class="summary-item">
                            <div class="s-label">Total Charges</div>
                            <div class="s-value debit-color">PKR <asp:Label ID="lblTotalDebit" runat="server">0</asp:Label></div>
                        </div>
                        <div class="summary-item">
                            <div class="s-label">Total Paid</div>
                            <div class="s-value credit-color">PKR <asp:Label ID="lblTotalCredit" runat="server">0</asp:Label></div>
                        </div>
                    </div>

                    <!-- Outstanding Balance Bar -->
                    <div class="outstanding-bar" id="divOutstanding" runat="server">
                        <span class="ob-label"><i class="fas fa-exclamation-triangle" style="margin-right:8px;"></i> Net Outstanding Balance</span>
                        <span class="ob-value" style="color: #c9a84c;">PKR <asp:Label ID="lblBalance" runat="server">0</asp:Label></span>
                    </div>

                    <!-- Member Credit Bar -->
                    <div class="outstanding-bar" id="divMemberCredit" runat="server" visible="false" style="background: linear-gradient(135deg, #064e3b 0%, #065f46 100%);">
                        <span class="ob-label"><i class="fas fa-wallet" style="margin-right:8px;"></i> Member Credit Amount</span>
                        <span class="ob-value" style="color: #34d399;">PKR <asp:Label ID="lblMemberCredit" runat="server">0</asp:Label></span>
                    </div>
                </div>

                <div class="no-print" style="text-align:right; margin-top:15px;">
                    <button type="button" class="btn btn-primary" onclick="window.print()" style="background:#1a2332; border-color:#1a2332;">
                        <i class="fas fa-print" style="margin-right:5px;"></i> Print Ledger
                    </button>
                </div>

            </div>
        </div>
    </asp:Panel>

</asp:Content>
