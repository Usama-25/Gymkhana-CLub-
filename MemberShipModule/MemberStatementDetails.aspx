<%@ Page Title="Member Statement - Detailed" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true" CodeFile="MemberStatementDetails.aspx.cs" Inherits="MemberStatementDetails_Page" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
    <style type="text/css">
        .stmt-page {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 13px;
            padding: 14px 20px;
        }

        .view-switcher-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 14px;
            flex-wrap: wrap;
            gap: 10px;
        }

        .view-tabs {
            display: inline-flex;
            background: #e2e8f0;
            padding: 4px;
            border-radius: 8px;
            gap: 4px;
        }

        .view-tab {
            padding: 7px 18px;
            font-size: 12.5px;
            font-weight: 700;
            border-radius: 6px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s ease;
            color: #475569;
        }

        .view-tab.active {
            background: #342867;
            color: #ffffff !important;
            box-shadow: 0 2px 4px rgba(52, 40, 103, 0.25);
        }

        .view-tab:not(.active):hover {
            background: #cbd5e1;
            color: #1e293b;
        }

        /* Filter Card */
        .filter-card {
            background: #ffffff;
            border: 1px solid #c8c8c8;
            border-radius: 6px;
            padding: 14px 18px;
            margin-bottom: 18px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .filter-title {
            margin: 0 0 12px 0;
            font-size: 14px;
            color: #342867;
            font-weight: 700;
            border-bottom: 1px solid #eee;
            padding-bottom: 6px;
            text-transform: uppercase;
            letter-spacing: 0.03em;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .filter-grid {
            display: grid;
            grid-template-columns: 1.3fr 1fr 1fr auto auto;
            gap: 12px;
            align-items: end;
        }

        .filter-cell {
            display: flex;
            flex-direction: column;
        }

        .filter-cell label {
            font-weight: 600;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            color: #555;
            margin-bottom: 4px;
        }

        .filter-cell input[type="text"],
        .filter-cell input[type="date"],
        .filter-cell select {
            width: 100%;
            padding: 7px 10px;
            border: 1px solid #bbb;
            font-size: 13px;
            font-family: inherit;
            outline: none;
            background: #ffffff;
            border-radius: 4px;
            box-sizing: border-box;
        }

        .filter-cell input:focus {
            border-color: #342867;
            box-shadow: 0 0 0 2px rgba(52,40,103,0.12);
        }

        .btn-search {
            padding: 8px 24px;
            font-size: 12.5px;
            font-family: inherit;
            font-weight: 700;
            border: none;
            background: #342867;
            color: #ffffff !important;
            cursor: pointer;
            border-radius: 4px;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            box-shadow: 0 2px 4px rgba(52,40,103,0.2);
        }

        .btn-search:hover {
            background: #271e50;
        }

        .btn-reset {
            padding: 8px 20px;
            font-size: 12.5px;
            font-family: inherit;
            font-weight: 600;
            border: 1px solid #ccc;
            background: #e0e0e0;
            color: #333333 !important;
            cursor: pointer;
            border-radius: 4px;
            text-transform: uppercase;
        }

        .member-info-label {
            margin-top: 10px;
            padding: 8px 12px;
            font-size: 12px;
            font-weight: 600;
            border-radius: 4px;
            display: block;
        }

        /* Statement Doc */
        .stmt-container {
            background: #fff;
            border: 1px solid #aaa;
            padding: 0;
            width: 100%;
            margin-top: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }

        .stmt-doc-table {
            width: 100%;
            border-collapse: collapse;
            border: none;
        }
        .stmt-doc-table > thead {
            display: table-header-group;
        }
        .stmt-doc-table > thead > tr > td,
        .stmt-doc-table > tbody > tr > td {
            padding: 0;
            border: none;
        }

        .stmt-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 8px 16px 6px 16px;
            border-bottom: 3px solid #342867;
            background: linear-gradient(180deg, #f8f7fc 0%, #ffffff 100%);
        }

        .stmt-header-left {
            display: flex;
            align-items: center;
            gap: 12px;
            flex: 1;
        }

        .stmt-logo img {
            width: 50px;
            height: 50px;
            object-fit: contain;
        }

        .stmt-org-info {
            line-height: 1.35;
        }

        .stmt-org-name {
            font-size: 17px;
            font-weight: 800;
            color: #342867;
            letter-spacing: 0.8px;
            text-transform: uppercase;
            margin-bottom: 1px;
        }

        .stmt-org-addr {
            font-size: 10.5px;
            color: #555;
            font-style: italic;
        }

        .stmt-org-contact {
            font-size: 10.5px;
            color: #444;
        }

        .stmt-header-right {
            display: flex;
            flex-direction: row;
            gap: 6px;
            align-items: center;
            align-self: center;
            flex-wrap: nowrap;
        }

        .hdr-card {
            padding: 4px 8px;
            border-radius: 4px;
            border: 1px solid transparent;
            min-width: 80px;
            text-align: center;
            flex: 1;
        }

        .hdr-card .card-label {
            font-size: 7.5px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            margin-bottom: 2px;
            white-space: nowrap;
        }

        .hdr-card .card-value {
            font-size: 11.5px;
            font-weight: 800;
            white-space: nowrap;
        }

        .hdr-membership { background: #e3f2fd; border-color: #90caf9; }
        .hdr-membership .card-label { color: #1565c0; }
        .hdr-membership .card-value { color: #0d47a1; }

        .hdr-billing { background: #e8f5e9; border-color: #a5d6a7; }
        .hdr-billing .card-label { color: #2e7d32; }
        .hdr-billing .card-value { color: #1b5e20; }

        .hdr-statement { background: #fff8e1; border-color: #ffe082; }
        .hdr-statement .card-label { color: #f57f17; }
        .hdr-statement .card-value { color: #e65100; }

        .hdr-due { background: #ffebee; border-color: #ef9a9a; }
        .hdr-due .card-label { color: #c62828; }
        .hdr-due .card-value { color: #b71c1c; }

        /* Member Row */
        .stmt-summary-member-row {
            display: flex;
            gap: 0;
            align-items: stretch;
        }

        .acct-summary-inner {
            flex: 0 0 65%;
            width: 65%;
        }

        .stmt-member-card {
            flex: 0 0 35%;
            width: 35%;
            padding: 6px 14px;
            background: linear-gradient(135deg, #f0eef5 0%, #e8e5f0 100%);
            border-left: 3px solid #342867;
            display: flex;
            flex-direction: column;
            justify-content: center;
            box-sizing: border-box;
            text-align: right;
        }

        .stmt-member-card .member-no {
            font-weight: 800;
            font-size: 13px;
            color: #342867;
            margin-bottom: 2px;
        }

        .stmt-member-card .member-name {
            font-weight: 700;
            font-size: 12px;
            color: #1a1a2e;
            margin-bottom: 1px;
        }

        .stmt-member-card .member-detail {
            font-size: 10.5px;
            color: #555;
            line-height: 1.4;
        }

        /* Summary Cards */
        .cards-row {
            display: flex;
            gap: 4px;
            padding: 6px 8px;
            flex-wrap: nowrap;
        }

        .summary-card {
            flex: 1;
            min-width: 0;
            padding: 4px 6px;
            border-radius: 4px;
            margin: 2px;
            text-align: center;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            border: 1px solid transparent;
        }

        .summary-card .card-label {
            font-size: 7.5px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            margin-bottom: 2px;
            white-space: nowrap;
        }

        .summary-card .card-value {
            font-size: 12px;
            font-weight: 800;
            white-space: nowrap;
        }

        .card-prev-bal    { background: #e8f4fd; border-color: #b3d9f2; }
        .card-prev-bal .card-label { color: #1565c0; }
        .card-prev-bal .card-value { color: #0d47a1; }

        .card-pay-rec     { background: #e8f5e9; border-color: #a5d6a7; }
        .card-pay-rec .card-label { color: #2e7d32; }
        .card-pay-rec .card-value { color: #1b5e20; }

        .card-bill-amt    { background: #fff8e1; border-color: #ffe082; }
        .card-bill-amt .card-label { color: #f57f17; }
        .card-bill-amt .card-value { color: #e65100; }

        .card-adjustments { background: #f3e5f5; border-color: #ce93d8; }
        .card-adjustments .card-label { color: #7b1fa2; }
        .card-adjustments .card-value { color: #4a148c; }

        .card-due-amt     { background: #ffebee; border-color: #ef9a9a; }
        .card-due-amt .card-label { color: #c62828; }
        .card-due-amt .card-value { color: #b71c1c; }

        .stmt-section-header {
            background: #342867;
            color: #ffffff;
            font-weight: 700;
            font-size: 11.5px;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            padding: 7px 14px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        /* Detailed Ledger Table */
        .ledger-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 11.5px;
        }

        .ledger-table th {
            background: #342867;
            color: #ffffff;
            font-weight: 700;
            font-size: 10px;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            padding: 7px 10px;
            border: 1px solid #2a1f54;
            text-align: center;
        }

        .ledger-table td {
            padding: 6px 10px;
            border-left: 1px solid #d0cce0;
            border-right: 1px solid #d0cce0;
            border-bottom: 1px solid #e8e5f0;
            vertical-align: middle;
        }

        .ledger-table tr:nth-child(even) td {
            background: #faf9fc;
        }

        .ledger-table tr:hover td {
            background: #f0eef5;
        }

        .ledger-table tr:last-child td {
            border-bottom: 1px solid #c5bfdb;
        }

        /* Closing row */
        .closing-row {
            display: flex;
            justify-content: flex-end;
            padding: 8px 22px;
            background: linear-gradient(90deg, #fff 0%, #f0eef5 100%);
            border-top: 2px solid #342867;
            border-bottom: 1px solid #c5bfdb;
        }

        .closing-row table td {
            padding: 4px 12px;
            font-weight: 800;
            font-size: 13px;
            color: #342867;
        }

        .page-indicator {
            text-align: right;
            padding: 4px 22px;
            font-size: 10px;
            color: #888;
            border-bottom: 1px solid #ddd;
            background: #fafafa;
        }

        .stmt-note {
            padding: 12px 22px;
            font-size: 10.5px;
            line-height: 1.6;
            border-bottom: 1px solid #ddd;
            background: #fffdf5;
        }

        .stmt-note .note-title {
            color: #c00;
            font-weight: 800;
            font-size: 11px;
        }

        .stmt-note .note-text {
            color: #c00;
            font-weight: 600;
        }

        .stmt-note .note-link {
            color: #006600;
            font-weight: 600;
        }

        /* Subscription Card Colors */
        .sub-cards-row {
            display: flex;
            gap: 0;
            padding: 8px 10px;
            flex-wrap: wrap;
        }

        .sub-card {
            flex: 1;
            min-width: 0;
            padding: 8px 6px;
            border-radius: 5px;
            margin: 3px;
            text-align: center;
            box-shadow: 0 1px 2px rgba(0,0,0,0.06);
            border: 1px solid transparent;
        }

        .sub-card .card-label {
            font-size: 8px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            margin-bottom: 3px;
        }

        .sub-card .card-value {
            font-size: 13px;
            font-weight: 800;
        }

        .sc-general   { background: #e3f2fd; border-color: #90caf9; }
        .sc-general .card-label { color: #1565c0; } .sc-general .card-value { color: #0d47a1; }

        .sc-library   { background: #e8eaf6; border-color: #9fa8da; }
        .sc-library .card-label { color: #283593; } .sc-library .card-value { color: #1a237e; }

        .sc-film      { background: #ede7f6; border-color: #b39ddb; }
        .sc-film .card-label { color: #4527a0; } .sc-film .card-value { color: #311b92; }

        .sc-musical   { background: #fce4ec; border-color: #f48fb1; }
        .sc-musical .card-label { color: #ad1457; } .sc-musical .card-value { color: #880e4f; }

        .sc-utilities { background: #fff3e0; border-color: #ffcc80; }
        .sc-utilities .card-label { color: #e65100; } .sc-utilities .card-value { color: #bf360c; }

        .sc-welfare   { background: #e0f2f1; border-color: #80cbc4; }
        .sc-welfare .card-label { color: #00695c; } .sc-welfare .card-value { color: #004d40; }

        .sc-dev       { background: #f1f8e9; border-color: #aed581; }
        .sc-dev .card-label { color: #33691e; } .sc-dev .card-value { color: #1b5e20; }

        .sc-sport     { background: #e8f5e9; border-color: #a5d6a7; }
        .sc-sport .card-label { color: #2e7d32; } .sc-sport .card-value { color: #1b5e20; }

        .sc-amber     { background: #fff8e1; border-color: #ffe082; }
        .sc-amber .card-label { color: #b45309; } .sc-amber .card-value { color: #92400e; }

        .sc-cyan      { background: #ecfeff; border-color: #a5f3fc; }
        .sc-cyan .card-label { color: #0e7490; } .sc-cyan .card-value { color: #155e75; }

        .sc-total     { background: #342867; border-color: #2a1f54; }
        .sc-total .card-label { color: rgba(255,255,255,0.8); } .sc-total .card-value { color: #ffffff; }

        .card-benefit {
            font-size: 7.5px;
            font-weight: 700;
            color: #15803d;
            background: #dcfce7;
            border: 1px solid #86efac;
            border-radius: 3px;
            padding: 1px 3px;
            margin-top: 2px;
            display: inline-block;
        }

        /* Sports Layout */
        .sports-layout {
            display: flex;
            border-bottom: 1px solid #d0cce0;
        }

        .sports-left {
            flex: 1;
            border-right: 1px solid #d0cce0;
        }

        .sports-right {
            width: 35%;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #faf9fc;
            padding: 10px;
        }

        .sports-grid-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 11px;
        }

        .sports-grid-table th {
            background: #f0eef5;
            color: #342867;
            font-weight: 700;
            padding: 5px 8px;
            border-bottom: 1px solid #d0cce0;
            font-size: 9.5px;
            text-transform: uppercase;
        }

        .sports-grid-table td {
            padding: 4px 8px;
            border-bottom: 1px solid #eee;
        }

        .sports-grid-total-row td {
            background: #e8e5f0;
            font-weight: 800;
            color: #342867;
            border-top: 1px solid #342867;
            border-bottom: none;
        }

        .part-payment-box {
            border: 2px solid #b71c1c;
            color: #b71c1c;
            font-weight: 800;
            font-size: 12px;
            text-align: center;
            padding: 10px 16px;
            line-height: 1.4;
            letter-spacing: 0.04em;
            background: #fff;
            border-radius: 4px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06);
        }

        @media print {
            @page {
                size: portrait;
                margin: 3mm 4mm;
            }
            body, html {
                background: #fff !important;
                margin: 0 !important;
                padding: 0 !important;
                font-size: 10px !important;
            }
            .filter-card, .view-switcher-bar, header, footer, nav, .site-header, .site-footer { 
                display: none !important; 
            }
            .stmt-page { 
                padding: 0 !important; 
                margin: 0 !important; 
                width: 100% !important;
            }
            .stmt-container { 
                border: 1px solid #777 !important; 
                box-shadow: none !important; 
                margin: 0 !important;
                width: 100% !important;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">
    <div class="stmt-page">
        
        <%-- ══ Top Bar: Title & View Switcher ══ --%>
        <div class="view-switcher-bar">
            <div>
                <h2 style="margin: 0; color: #342867; font-weight: 700; font-size: 19px;">Member Statement - Detailed View</h2>
                <div style="font-size: 12px; color: #64748b; margin-top: 2px;">Shows all chronological transactions, payments, and charges for the filtered date range.</div>
            </div>
            <div class="view-tabs">
                <asp:HyperLink ID="lnkGoToSummary" runat="server" CssClass="view-tab">
                    <i class="fas fa-list-alt"></i> Summarized View
                </asp:HyperLink>
                <a href="javascript:void(0);" class="view-tab active">
                    <i class="fas fa-receipt"></i> Detailed View
                </a>
            </div>
        </div>

        <%-- ══ FILTER CARD ══ --%>
        <div class="filter-card">
            <h3 class="filter-title">
                <span>Filter By Membership Number & Date Range</span>
                <span style="font-size: 11px; color: #64748b; font-weight: 600;">Full Transaction History Mode</span>
            </h3>
            <div class="filter-grid">
                <div class="filter-cell">
                    <label>Membership Number</label>
                    <asp:TextBox ID="txtMemberNo" runat="server" placeholder="e.g. T-40004 or R-15553" AutoPostBack="false"></asp:TextBox>
                </div>
                <div class="filter-cell">
                    <label>Start Date</label>
                    <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date"></asp:TextBox>
                </div>
                <div class="filter-cell">
                    <label>End Date</label>
                    <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date"></asp:TextBox>
                </div>
                <div class="filter-cell">
                    <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click" CssClass="btn-search" CausesValidation="false" />
                </div>
                <div class="filter-cell">
                    <asp:Button ID="btnReset" runat="server" Text="Reset" OnClick="btnReset_Click" CssClass="btn-reset" CausesValidation="false" />
                </div>
            </div>

            <asp:Label ID="lblMemberInfo" runat="server" CssClass="member-info-label" Visible="false"></asp:Label>
        </div>

        <%-- ══════════════════════════════════════════════
             DETAILED STATEMENT REPORT
             ══════════════════════════════════════════════ --%>
        <asp:Panel ID="pnlStatement" runat="server" Visible="false">

            <div class="stmt-container">
                <table class="stmt-doc-table">
                    <thead>
                        <tr>
                            <td>
                                <%-- ═══ REPEATING HEADER ═══ --%>
                                <div class="stmt-header">
                                    <div class="stmt-header-left">
                                        <div class="stmt-logo">
                                            <img src="../resources/images/GymkhanaReportLogo.png" alt="Logo"
                                                 onerror="this.style.display='none'" />
                                        </div>
                                        <div class="stmt-org-info">
                                            <div class="stmt-org-name">LAHORE GYMKHANA</div>
                                            <div class="stmt-org-addr">Upper Shahrah-e-Quaid-e-Azam</div>
                                            <div class="stmt-org-addr">Lahore</div>
                                            <div class="stmt-org-contact">
                                                <strong>Phone:</strong> 111-115-231 / 3575 6896-95
                                            </div>
                                            <div class="stmt-org-contact"><strong>Fax:</strong> 3575 6896-97</div>
                                        </div>
                                    </div>
                                    <div class="stmt-header-right">
                                        <div class="hdr-card hdr-membership">
                                            <div class="card-label">Membership No.</div>
                                            <div class="card-value"><asp:Literal ID="litMembershipNo" runat="server"></asp:Literal></div>
                                        </div>
                                        <div class="hdr-card hdr-billing">
                                            <div class="card-label">Date Range</div>
                                            <div class="card-value"><asp:Literal ID="litBillingMonth" runat="server"></asp:Literal></div>
                                        </div>
                                        <div class="hdr-card hdr-statement">
                                            <div class="card-label">Statement Date</div>
                                            <div class="card-value"><asp:Literal ID="litStatementDate" runat="server"></asp:Literal></div>
                                        </div>
                                        <div class="hdr-card hdr-due">
                                            <div class="card-label">Due Date</div>
                                            <div class="card-value"><asp:Literal ID="litDueDate" runat="server"></asp:Literal></div>
                                        </div>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>
                                <%-- ═══ ACCOUNT SUMMARY (65% left) + MEMBER INFO (35% right) ═══ --%>
                                <div class="stmt-summary-member-row">
                                    <div class="acct-summary-inner">
                                        <div class="stmt-section-header">ACCOUNT SUMMARY (PERIOD TOTALS)</div>
                                        <div class="cards-row">
                                            <div class="summary-card card-prev-bal">
                                                <div class="card-label">Opening Bal.</div>
                                                <div class="card-value"><asp:Literal ID="litPrevBal" runat="server"></asp:Literal></div>
                                            </div>
                                            <div class="summary-card card-pay-rec">
                                                <div class="card-label">Payment Rec.</div>
                                                <div class="card-value"><asp:Literal ID="litPayRec" runat="server"></asp:Literal></div>
                                            </div>
                                            <div class="summary-card card-bill-amt">
                                                <div class="card-label">Total Debits</div>
                                                <div class="card-value"><asp:Literal ID="litBillAmt" runat="server"></asp:Literal></div>
                                            </div>
                                            <div class="summary-card card-adjustments">
                                                <div class="card-label">Adjustments</div>
                                                <div class="card-value"><asp:Literal ID="litAdjustments" runat="server"></asp:Literal></div>
                                            </div>
                                            <div class="summary-card card-due-amt">
                                                <div class="card-label">Closing Bal.</div>
                                                <div class="card-value"><asp:Literal ID="litDueAmt" runat="server"></asp:Literal></div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="stmt-member-card">
                                        <div class="member-no"><asp:Literal ID="litAddrMemberNo" runat="server"></asp:Literal></div>
                                        <div class="member-name"><asp:Literal ID="litAddrName" runat="server"></asp:Literal></div>
                                        <div class="member-detail">
                                            <asp:Literal ID="litAddrLine1" runat="server"></asp:Literal><br />
                                            <asp:Literal ID="litAddrLine2" runat="server"></asp:Literal>
                                            <asp:Literal ID="litAddrPhone" runat="server"></asp:Literal>
                                            <asp:Literal ID="litMemberTypeAndCat" runat="server"></asp:Literal>
                                        </div>
                                    </div>
                                </div>

                                <%-- ═══ SUBSCRIPTION DETAIL ═══ --%>
                                <div class="stmt-section-header">
                                    <span>SUBSCRIPTION DETAIL</span>
                                    <asp:Label ID="lblSubBadge" runat="server" Visible="false" 
                                        Style="font-size: 9.5px; text-transform: uppercase; background: rgba(255,255,255,0.2); padding: 2px 6px; border-radius: 3px;"></asp:Label>
                                </div>

                                <%-- Subscription Cards --%>
                                <div class="sub-cards-row">
                                    <asp:Repeater ID="rptSubscriptionCards" runat="server">
                                        <ItemTemplate>
                                            <div class='sub-card <%# Eval("CssClass") %>' style='<%# Eval("CustomStyle") %>'>
                                                <div class="card-label"><%# Eval("CardLabel") %></div>
                                                <div class="card-value"><%# Eval("FormattedValue") %></div>
                                                <%# !string.IsNullOrEmpty(Eval("BenefitNote") as string) ? "<div class='card-benefit'>" + Eval("BenefitNote") + "</div>" : "" %>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                    
                                    <%-- Sum / Sub. Total Card --%>
                                    <div class="sub-card sc-total">
                                        <div class="card-label">Sub. Total</div>
                                        <div class="card-value"><asp:Literal ID="litSubTotal" runat="server">0</asp:Literal></div>
                                    </div>
                                </div>

                                <%-- ═══ SPORTS CHARGES (GRID) + PART PAYMENT BOX ═══ --%>
                                <div class="sports-layout">
                                    <div class="sports-left">
                                        <table class="sports-grid-table">
                                            <thead>
                                                <tr>
                                                    <th style="width: 32%; text-align: left; padding-left: 8px;">Sports</th>
                                                    <th style="width: 17%; text-align: right; padding-right: 8px;">Subscription</th>
                                                    <th style="width: 17%; text-align: right; padding-right: 8px;">GST</th>
                                                    <th style="width: 17%; text-align: right; padding-right: 8px;">Locker</th>
                                                    <th style="width: 17%; text-align: right; padding-right: 8px;">Msc</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <asp:Repeater ID="rptSportsGrid" runat="server">
                                                    <ItemTemplate>
                                                        <tr>
                                                            <td style="text-align: left; padding-left: 8px; font-weight: 600;"><%# Eval("SportName") %></td>
                                                            <td style="text-align: right; padding-right: 8px;"><%# FormatAmount(Eval("Subscription")) %></td>
                                                            <td style="text-align: right; padding-right: 8px;"><%# FormatAmount(Eval("GST")) %></td>
                                                            <td style="text-align: right; padding-right: 8px;"><%# FormatAmount(Eval("Locker")) %></td>
                                                            <td style="text-align: right; padding-right: 8px;"><%# FormatAmount(Eval("Misc")) %></td>
                                                        </tr>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                            </tbody>
                                            <tfoot>
                                                <tr class="sports-grid-total-row">
                                                    <td style="text-align: left; padding-left: 8px; font-weight: 700;">TOTAL</td>
                                                    <td style="text-align: right; padding-right: 8px; font-weight: 700;"><asp:Literal ID="litSportsSubTotal" runat="server">0</asp:Literal></td>
                                                    <td style="text-align: right; padding-right: 8px; font-weight: 700;"><asp:Literal ID="litSportsGSTTotal" runat="server">0</asp:Literal></td>
                                                    <td style="text-align: right; padding-right: 8px; font-weight: 700;"><asp:Literal ID="litSportsLockerTotal" runat="server">0</asp:Literal></td>
                                                    <td style="text-align: right; padding-right: 8px; font-weight: 700;"><asp:Literal ID="litSportsMiscTotal" runat="server">0</asp:Literal></td>
                                                </tr>
                                            </tfoot>
                                        </table>
                                    </div>
                                    <div class="sports-right">
                                        <div class="part-payment-box">
                                            PART PAYMENT SHALL<br />NOT BE ACCEPTED
                                        </div>
                                    </div>
                                </div>

                                <%-- ═══ ALL TRANSACTIONS (DETAILED LEDGER) ═══ --%>
                                <div class="stmt-section-header">
                                    <span>ALL TRANSACTIONS IN DATE RANGE</span>
                                    <span style="font-size: 9.5px; font-weight: 400; text-transform: none; opacity: 0.9;">Chronological complete ledger</span>
                                </div>
                                <table class="ledger-table">
                                    <tr>
                                        <th style="width: 100px;">Date</th>
                                        <th>Particulars</th>
                                        <th style="width: 130px;">Reference</th>
                                        <th style="width: 105px;">Debit</th>
                                        <th style="width: 105px;">Credit</th>
                                        <th style="width: 110px;">Balance</th>
                                    </tr>
                                    <asp:Repeater ID="rptLedger" runat="server">
                                        <ItemTemplate>
                                            <tr>
                                                <td style="text-align: center; font-size: 11px;"><%# Eval("TransDateFormatted") %></td>
                                                <td style="text-align: left; padding-left: 12px; font-weight:<%# Convert.ToString(Eval("SortOrder")) == "0" ? "700" : "400" %>; color:<%# Convert.ToString(Eval("SortOrder")) == "0" ? "#342867" : "#1a1a2e" %>;">
                                                    <%# Eval("Particulars") %>
                                                </td>
                                                <td style="text-align: center; font-size: 11px;"><%# Eval("Reference") %></td>
                                                <td style="text-align: right; color: #c00;"><%# FormatAmount(Eval("Debit")) %></td>
                                                <td style="text-align: right; color: #006600;"><%# FormatAmount(Eval("Credit")) %></td>
                                                <td style="text-align: right; font-weight: 700;"><%# FormatAmount(Eval("Balance")) %></td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </table>

                                <%-- ═══ CLOSING BALANCE ═══ --%>
                                <div class="closing-row">
                                    <table>
                                        <tr>
                                            <td>Closing Balance (As of <asp:Literal ID="litClosingDateLabel" runat="server"></asp:Literal>):</td>
                                            <td style="text-align: right; min-width: 100px;">
                                                <asp:Literal ID="litClosingBalance" runat="server"></asp:Literal>
                                            </td>
                                        </tr>
                                    </table>
                                </div>

                                <%-- Note --%>
                                <div class="stmt-note">
                                    <span class="note-title">NOTE:-</span>
                                    <span class="note-text"> Members may kindly note that the account shall automatically be blocked in case of nonpayment of club dues within
                                        due date or exceeding fixed credit limit Rs.20,000/-, whichever comes first. After due date 2% surcharge shall
                                        be levied on unpaid bill amount.</span>
                                    <br />
                                    <span class="note-link">Dress Regulations can be viewed on Gymkhana website (www.lahoregymkhana.pk)</span>
                                </div>

                                <div class="page-indicator">Page 1 of 1</div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

        </asp:Panel>

    </div>
</asp:Content>
