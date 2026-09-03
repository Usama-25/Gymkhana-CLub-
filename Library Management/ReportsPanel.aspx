<%@ page language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" autoeventwireup="true" CodeFile="ReportsPanel.aspx.cs" Inherits="GymkhanaLibrary.ReportsPanel" title="Listing Reports - Lahore Gymkhana Library" %>

<asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        /* Modern report styles matching Gymkhana UI design system */
        .tab-header-btn {
            padding: 16px 20px;
            text-align: center;
            background: none;
            border: none;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: #64748b;
            border-bottom: 3px solid transparent;
            cursor: pointer;
            transition: all 0.25s ease;
            outline: none;
            flex-shrink: 0;
        }
        .tab-header-btn:hover {
            color: #0f1e36;
            background-color: #f1f5f9;
        }
        .tab-header-btn.active {
            color: #c5a059;
            border-bottom-color: #c5a059;
            background-color: #ffffff;
        }
        .tab-pane {
            display: none;
            width: 100%;
        }
        .tab-pane.active {
            display: block;
        }
        .filter-container {
            background-color: #f8fafc;
            border: 1px solid #e2e8f0;
            padding: 24px;
            border-radius: 8px;
            margin-bottom: 24px;
            display: flex;
            flex-direction: column;
            gap: 20px;
            width: 100%;
            box-sizing: border-box;
        }
        .filter-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
            gap: 16px;
            align-items: end;
            width: 100%;
            box-sizing: border-box;
        }
        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
            width: 100%;
            box-sizing: border-box;
        }
        .filter-label {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            color: #64748b;
            letter-spacing: 0.5px;
        }
        .form-control {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 13.5px;
            outline: none;
            background-color: #ffffff;
            box-sizing: border-box;
            height: 42px;
            transition: border-color 0.2s ease;
        }
        .form-control:focus {
            border-color: #c5a059;
        }
        .btn-action-primary {
            padding: 12px 24px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%);
            color: #ffffff;
            transition: all 0.2s ease;
            box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1);
            display: inline-block;
        }
        .btn-action-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(15, 30, 54, 0.2);
        }
        .btn-action-gold {
            padding: 12px 24px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%);
            color: #ffffff;
            transition: all 0.2s ease;
            box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2);
            display: inline-block;
        }
        .btn-action-gold:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(197, 160, 89, 0.3);
        }
        .btn-action-gray {
            padding: 12px 24px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%);
            color: #0f1e36;
            transition: all 0.2s ease;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
            display: inline-block;
        }
        .btn-action-gray:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
        .report-grid-wrapper {
            width: 100%;
            overflow-x: auto;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            margin-top: 20px;
            background-color: #ffffff;
            -webkit-overflow-scrolling: touch;
        }
        .report-grid {
            width: 100%;
            border-collapse: collapse;
            background-color: #ffffff;
            font-size: 13.5px;
            color: #1e293b;
            margin: 0;
            border: none;
        }
        .report-grid th {
            background-color: #0f1e36 !important;
            color: #ffffff !important;
            font-weight: 600;
            text-align: left;
            padding: 12px 16px;
            border-bottom: 2px solid #cbd5e1;
            white-space: nowrap;
        }
        .report-grid td {
            padding: 12px 16px;
            border-bottom: 1px solid #e2e8f0;
            white-space: nowrap;
        }
        .report-grid tr:nth-child(even) {
            background-color: #f8fafc;
        }
        .report-grid tr:hover {
            background-color: #f1f5f9;
        }
        .report-grid-empty {
            padding: 40px;
            text-align: center;
            color: #64748b;
            font-style: italic;
            font-size: 14px;
            background-color: #ffffff;
        }
        .alert-message {
            padding: 16px 24px;
            border-radius: 8px;
            font-size: 14px;
            margin-bottom: 24px;
            border-left: 4px solid #ef4444;
            background-color: #fef2f2;
            color: #991b1b;
        }
        
        /* Premium Pager Styles */
        .pager-style table {
            margin: 12px 0;
            display: inline-block;
        }
        .pager-style td {
            padding: 0 4px;
        }
        .pager-style a, .pager-style span {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 6px;
            border: 1px solid #e2e8f0;
            text-decoration: none;
            font-weight: 600;
            font-size: 13px;
            transition: all 0.2s ease;
        }
        .pager-style a {
            color: #0f1e36;
            background-color: #ffffff;
        }
        .pager-style a:hover {
            background-color: #f1f5f9;
            border-color: #cbd5e1;
        }
        .pager-style span {
            color: #0f1e36;
            background-color: #c5a059;
            border-color: #c5a059;
        }

        /* Premium Print Styles */
        @media print {
            @page {
                margin: 0.2cm !important;
            }
            body {
                margin: 0 !important;
                padding: 5px !important;
                background-color: #fff !important;
                color: #000 !important;
                font-size: 10px !important;
            }
            aside, header, .filter-container, .btn-action-primary, .btn-action-gold, .btn-action-gray, .filter-group, #tabHeaders, .no-print {
                display: none !important;
            }
            .print-only {
                display: block !important;
                margin-bottom: 10px !important;
                padding-bottom: 5px !important;
            }
            .print-only h2 {
                font-size: 16px !important;
                margin-top: 5px !important;
            }
            main {
                margin-left: 0 !important;
                padding: 0 !important;
            }
            .tab-pane {
                display: none !important;
            }
            .tab-pane.active-print {
                display: block !important;
            }
            .report-grid-wrapper {
                overflow: visible !important;
                border: none !important;
                margin-top: 5px !important;
            }
            .report-grid {
                width: 100% !important;
                max-width: 100% !important;
                border: 1px solid #cbd5e1 !important;
                margin-top: 5px !important;
                table-layout: auto !important;
                word-break: break-word !important;
            }
            .report-grid th {
                background-color: #0f1e36 !important;
                color: #ffffff !important;
                border: 1px solid #cbd5e1 !important;
                padding: 4px 6px !important; /* Minimal padding */
                font-size: 9px !important; /* Smaller header font */
                text-transform: uppercase !important;
            }
            .report-grid td {
                border: 1px solid #cbd5e1 !important;
                padding: 4px 6px !important; /* Minimal padding */
                font-size: 9px !important; /* Smaller body font */
                white-space: normal !important;
            }
            .report-grid tr {
                page-break-inside: avoid !important;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">
    <style>
        /* Duplicate modern report styles directly inside the body to ensure enforcement on the live server */
        .tab-header-btn {
            padding: 16px 20px;
            text-align: center;
            background: none;
            border: none;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: #64748b;
            border-bottom: 3px solid transparent;
            cursor: pointer;
            transition: all 0.25s ease;
            outline: none;
            flex-shrink: 0;
        }
        .tab-header-btn:hover {
            color: #0f1e36;
            background-color: #f1f5f9;
        }
        .tab-header-btn.active {
            color: #c5a059;
            border-bottom-color: #c5a059;
            background-color: #ffffff;
        }
        .tab-pane {
            display: none;
            width: 100%;
        }
        .tab-pane.active {
            display: block;
        }
        .filter-container {
            background-color: #f8fafc;
            border: 1px solid #e2e8f0;
            padding: 24px;
            border-radius: 8px;
            margin-bottom: 24px;
            display: flex;
            flex-direction: column;
            gap: 20px;
            width: 100%;
            box-sizing: border-box;
        }
        .filter-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
            gap: 16px;
            align-items: end;
            width: 100%;
            box-sizing: border-box;
        }
        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
            width: 100%;
            box-sizing: border-box;
        }
        .filter-label {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            color: #64748b;
            letter-spacing: 0.5px;
        }
        .form-control {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 13.5px;
            outline: none;
            background-color: #ffffff;
            box-sizing: border-box;
            height: 42px;
            transition: border-color 0.2s ease;
        }
        .form-control:focus {
            border-color: #c5a059;
        }
        .btn-action-primary {
            padding: 12px 24px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%);
            color: #ffffff;
            transition: all 0.2s ease;
            box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1);
            display: inline-block;
        }
        .btn-action-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(15, 30, 54, 0.2);
        }
        .btn-action-gold {
            padding: 12px 24px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%);
            color: #ffffff;
            transition: all 0.2s ease;
            box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2);
            display: inline-block;
        }
        .btn-action-gold:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(197, 160, 89, 0.3);
        }
        .btn-action-gray {
            padding: 12px 24px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%);
            color: #0f1e36;
            transition: all 0.2s ease;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
            display: inline-block;
        }
        .btn-action-gray:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
        .report-grid-wrapper {
            width: 100%;
            overflow-x: auto;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            margin-top: 20px;
            background-color: #ffffff;
            -webkit-overflow-scrolling: touch;
        }
        .report-grid {
            width: 100%;
            border-collapse: collapse;
            background-color: #ffffff;
            font-size: 13.5px;
            color: #1e293b;
            margin: 0;
            border: none;
        }
        .report-grid th {
            background-color: #0f1e36 !important;
            color: #ffffff !important;
            font-weight: 600;
            text-align: left;
            padding: 12px 16px;
            border-bottom: 2px solid #cbd5e1;
            white-space: nowrap;
        }
        .report-grid td {
            padding: 12px 16px;
            border-bottom: 1px solid #e2e8f0;
            white-space: nowrap;
        }
        .report-grid tr:nth-child(even) {
            background-color: #f8fafc;
        }
        .report-grid tr:hover {
            background-color: #f1f5f9;
        }
        .report-grid-empty {
            padding: 40px;
            text-align: center;
            color: #64748b;
            font-style: italic;
            font-size: 14px;
            background-color: #ffffff;
        }
        .alert-message {
            padding: 16px 24px;
            border-radius: 8px;
            font-size: 14px;
            margin-bottom: 24px;
            border-left: 4px solid #ef4444;
            background-color: #fef2f2;
            color: #991b1b;
        }
        
        /* Premium Pager Styles */
        .pager-style table {
            margin: 12px 0;
            display: inline-block;
        }
        .pager-style td {
            padding: 0 4px;
        }
        .pager-style a, .pager-style span {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 6px;
            border: 1px solid #e2e8f0;
            text-decoration: none;
            font-weight: 600;
            font-size: 13px;
            transition: all 0.2s ease;
        }
        .pager-style a {
            color: #0f1e36;
            background-color: #ffffff;
        }
        .pager-style a:hover {
            background-color: #f1f5f9;
            border-color: #cbd5e1;
        }
        .pager-style span {
            color: #0f1e36;
            background-color: #c5a059;
            border-color: #c5a059;
        }

        /* Premium Print Styles */
        @media print {
            @page {
                margin: 0.2cm !important;
            }
            body {
                margin: 0 !important;
                padding: 5px !important;
                background-color: #fff !important;
                color: #000 !important;
                font-size: 10px !important;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }
            aside, header, .filter-container, .btn-action-primary, .btn-action-gold, .btn-action-gray, .filter-group, #tabHeaders, .no-print {
                display: none !important;
            }
            .print-only {
                display: block !important;
                margin-bottom: 10px !important;
                padding-bottom: 5px !important;
            }
            .print-only h2 {
                font-size: 16px !important;
                margin-top: 5px !important;
            }
            main {
                margin-left: 0 !important;
                padding: 0 !important;
            }
            .tab-pane {
                display: none !important;
            }
            .tab-pane.active-print {
                display: block !important;
            }
            .report-grid-wrapper {
                overflow: visible !important;
                border: none !important;
                margin-top: 5px !important;
            }
            .report-grid {
                width: 100% !important;
                max-width: 100% !important;
                border: 1px solid #cbd5e1 !important;
                margin-top: 5px !important;
                table-layout: auto !important;
                word-break: break-word !important;
            }
            .report-grid th {
                background-color: #0f1e36 !important;
                color: #ffffff !important;
                border: 1px solid #cbd5e1 !important;
                padding: 4px 6px !important;
                font-size: 9px !important;
                text-transform: uppercase !important;
            }
            .report-grid td {
                border: 1px solid #cbd5e1 !important;
                padding: 4px 6px !important;
                font-size: 9px !important;
                white-space: normal !important;
            }
            .report-grid tr {
                page-break-inside: avoid !important;
            }
        }
    </style>
    
    <!-- Print-Only Letterhead -->
    <div class="print-only" style="margin-bottom: 20px; border-bottom: 2px solid #cbd5e1; padding-bottom: 10px; text-align: left; width: 100%; display: none;">
        <div style="display: flex; justify-content: space-between; align-items: flex-end;">
            <div>
                <img src='<%= ResolveUrl("~/Library Management/Images/logo_new.png") %>' alt="Lahore Gymkhana Logo" style="height: 65px; display: inline-block; margin: 0; object-fit: contain;" />
                <h2 style="margin: 10px 0 2px 0; font-size: 20px; font-weight: 700; color: #0f1e36;">Lahore Gymkhana Club Library</h2>
                <p style="margin: 0; font-size: 11px; color: #64748b; font-weight: 500;">Custom listing report generated on <span id="printDate"></span></p>
            </div>
            <div style="text-align: right; font-size: 10px; color: #64748b; max-width: 60%; line-height: 1.4;">
                <div style="font-weight: bold; color: #0f1e36; margin-bottom: 3px;">Active Filters:</div>
                <asp:Literal ID="litPrintFilters" runat="server" Text="None" />
            </div>
        </div>
    </div>

    <!-- Title Banner -->
    <div class="no-print" style="background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; padding: 24px 28px; border-radius: 8px; margin-bottom: 24px; border-bottom: 3px solid #c5a059; display: flex; justify-content: space-between; align-items: center; width: 100%; box-sizing: border-box;">
        <div>
            <h2 style="margin: 0; font-size: 22px; font-weight: 600;">Custom Listing Reports</h2>
            <p style="margin: 4px 0 0; opacity: .8; font-size: 13px; font-weight: 300;">Lahore Gymkhana Club - Custom catalogue, label, and transaction reporting engine</p>
        </div>
    </div>

    <!-- Alert Panel -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <div class="alert-message" style="padding: 16px 24px; border-radius: 8px; font-size: 14px; margin-bottom: 24px; border-left: 4px solid #ef4444; background-color: #fef2f2; color: #991b1b;">
            <asp:Literal ID="litAlertMsg" runat="server" />
        </div>
    </asp:Panel>

    <!-- Master Card Wrapper -->
    <div style="display: flex; flex-direction: column; width: 100%; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); overflow: hidden; margin-bottom: 30px; box-sizing: border-box;">
        
        <!-- Tab Headers -->
        <div style="display: flex; background-color: #f8fafc; border-bottom: 1px solid #e2e8f0; width: 100%; box-sizing: border-box; overflow-x: auto; white-space: nowrap;" id="tabHeaders">
            <button type="button" class="tab-header-btn active" style="padding: 16px 20px; text-align: center; background-color: #ffffff; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #c5a059; border-bottom: 3px solid #c5a059; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;" onclick="switchTab(0)">1. Catalogue Listing</button>
            <button type="button" class="tab-header-btn" style="padding: 16px 20px; text-align: center; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;" onclick="switchTab(1)">2. Catalogue Labels</button>
            <button type="button" class="tab-header-btn" style="padding: 16px 20px; text-align: center; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;" onclick="switchTab(2)">3. Regulation Printing</button>
            <button type="button" class="tab-header-btn" style="padding: 16px 20px; text-align: center; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;" onclick="switchTab(3)">4. Issuance Listing</button>
            <button type="button" class="tab-header-btn" style="padding: 16px 20px; text-align: center; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;" onclick="switchTab(4)">5. Return Listing</button>
            <button type="button" class="tab-header-btn" style="padding: 16px 20px; text-align: center; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;" onclick="switchTab(5)">6. Reserve Listing</button>
            <button type="button" class="tab-header-btn" style="padding: 16px 20px; text-align: center; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;" onclick="switchTab(6)">7. Book Cost Audit</button>
        </div>

        <!-- Hidden field to preserve active tab state on postback -->
        <asp:HiddenField ID="hfActiveTab" runat="server" Value="0" />
        <asp:HiddenField ID="hfPrintData" runat="server" Value="" />
        <asp:HiddenField ID="hfPrintType" runat="server" Value="" />

        <!-- Card Body -->
        <div style="padding: 24px; width: 100%; box-sizing: border-box;">

            <!-- TAB 0: CATALOGUE LISTING -->
            <div id="paneCatalogue" class="tab-pane active" style="display: block; width: 100%;">
                <div class="filter-container" style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px; width: 100%; box-sizing: border-box;">
                    <div class="filter-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; align-items: end; width: 100%; box-sizing: border-box;">
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Book Number From</span>
                            <asp:TextBox ID="txtCatBookNoFrom" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" placeholder="Min Book No" Type="Number" />
                        </div>
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Book Number To</span>
                            <asp:TextBox ID="txtCatBookNoTo" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" placeholder="Max Book No" Type="Number" />
                        </div>
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Language</span>
                            <asp:DropDownList ID="ddlCatLanguage" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" />
                        </div>
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Book Type</span>
                            <asp:DropDownList ID="ddlCatBookType" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;">
                                <asp:ListItem Value="" Selected="True">-- All Types --</asp:ListItem>
                                <asp:ListItem Value="0">Circulating Only</asp:ListItem>
                                <asp:ListItem Value="1">Reference Only</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Condition</span>
                            <asp:DropDownList ID="ddlCatCondition" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" />
                        </div>
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Availability</span>
                            <asp:DropDownList ID="ddlCatAvailability" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;">
                                <asp:ListItem Value="" Selected="True">-- All Statuses --</asp:ListItem>
                                <asp:ListItem Value="1">Available</asp:ListItem>
                                <asp:ListItem Value="0">Issued / Unavailable</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div style="display: flex; gap: 12px; justify-content: flex-end; border-top: 1px solid #e2e8f0; padding-top: 16px;">
                        <asp:Button ID="btnGenCatalogue" runat="server" Text="Generate Listing" CssClass="btn-action-primary" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" OnClick="btnGenCatalogue_Click" />
                        <asp:Button ID="btnExportCatalogue" runat="server" Text="Export Excel" CssClass="btn-action-gold" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" OnClick="btnExportCatalogue_Click" />
                        <asp:Button ID="btnPDFCatalogue" runat="server" Text="Export PDF" CssClass="btn-action-gray no-print" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); display: inline-block;" OnClick="btnPDFCatalogue_Click" />
                    </div>
                </div>

                <h3 style="font-size: 14px; color: #0f1e36; font-weight: 700; text-transform: uppercase; margin: 20px 0 10px 0; border-bottom: 2px solid #c5a059; padding-bottom: 6px;">Catalogue Inventory Results <span style="color: #c5a059; font-weight: 600; text-transform: none; margin-left: 8px;"><asp:Literal ID="litCatalogueCount" runat="server" /></span></h3>
                <div class="report-grid-wrapper" style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 20px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                    <asp:GridView ID="gvCatalogue" runat="server" GridLines="None" AutoGenerateColumns="true" CssClass="report-grid" style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;" AllowPaging="True" PageSize="15" OnPageIndexChanging="gvCatalogue_PageIndexChanging" PagerStyle-CssClass="pager-style">
                        <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="true" HorizontalAlign="Left" Height="40px" />
                        <AlternatingRowStyle BackColor="#f8fafc" />
                        <EmptyDataTemplate>
                            <div class="report-grid-empty" style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff;">No book records match the specified filters.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>

            <!-- TAB 1: CATALOGUE LABELS -->
            <div id="paneLabels" class="tab-pane" style="display: none; width: 100%;">
                <div class="filter-container" style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px; width: 100%; box-sizing: border-box;">
                    <div class="filter-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 16px; align-items: end; width: 100%; box-sizing: border-box;">
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Book Number From</span>
                            <asp:TextBox ID="txtLabelBookNoFrom" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" placeholder="Start Book No" Type="Number" />
                        </div>
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Book Number To</span>
                            <asp:TextBox ID="txtLabelBookNoTo" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" placeholder="End Book No" Type="Number" />
                        </div>
                    </div>
                    <div style="display: flex; gap: 12px; justify-content: flex-end; border-top: 1px solid #e2e8f0; padding-top: 16px;">
                        <asp:Button ID="btnGenLabels" runat="server" Text="Preview Labels" CssClass="btn-action-primary" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" OnClick="btnGenLabels_Click" />
                        <asp:Button ID="btnPrintLabels" runat="server" Text="Print / Save PDF" CssClass="btn-action-gold" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" OnClick="btnPrintLabels_Click" />
                    </div>
                </div>

                <h3 style="font-size: 14px; color: #0f1e36; font-weight: 700; text-transform: uppercase; margin: 20px 0 10px 0; border-bottom: 2px solid #c5a059; padding-bottom: 6px;">Label Preview <span style="color: #c5a059; font-weight: 600; text-transform: none; margin-left: 8px;"><asp:Literal ID="litLabelsCount" runat="server" /></span></h3>
                <div class="report-grid-wrapper" style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 20px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                    <asp:GridView ID="gvLabels" runat="server" GridLines="None" AutoGenerateColumns="true" CssClass="report-grid" style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;" AllowPaging="True" PageSize="15" OnPageIndexChanging="gvLabels_PageIndexChanging" PagerStyle-CssClass="pager-style">
                        <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="true" HorizontalAlign="Left" Height="40px" />
                        <AlternatingRowStyle BackColor="#f8fafc" />
                        <EmptyDataTemplate>
                            <div class="report-grid-empty" style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff;">Enter a Book Number range and click Preview.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>

            <!-- TAB 2: REGULATION PRINTING -->
            <div id="paneRegulations" class="tab-pane" style="display: none; width: 100%;">
                <div class="filter-container" style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px; width: 100%; box-sizing: border-box;">
                    <div class="filter-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 16px; align-items: end; width: 100%; box-sizing: border-box;">
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Book Number From</span>
                            <asp:TextBox ID="txtRegBookNoFrom" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" placeholder="Start Book No" Type="Number" />
                        </div>
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Book Number To</span>
                            <asp:TextBox ID="txtRegBookNoTo" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" placeholder="End Book No" Type="Number" />
                        </div>
                    </div>
                    <div style="display: flex; gap: 12px; justify-content: flex-end; border-top: 1px solid #e2e8f0; padding-top: 16px;">
                        <asp:Button ID="btnGenRegulations" runat="server" Text="Preview Regulations" CssClass="btn-action-primary" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" OnClick="btnGenRegulations_Click" />
                        <asp:Button ID="btnPrintRegulations" runat="server" Text="Print / Save PDF" CssClass="btn-action-gold" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" OnClick="btnPrintRegulations_Click" />
                    </div>
                </div>

                <h3 style="font-size: 14px; color: #0f1e36; font-weight: 700; text-transform: uppercase; margin: 20px 0 10px 0; border-bottom: 2px solid #c5a059; padding-bottom: 6px;">Regulation Slips Preview <span style="color: #c5a059; font-weight: 600; text-transform: none; margin-left: 8px;"><asp:Literal ID="litRegulationsCount" runat="server" /></span></h3>
                <div class="report-grid-wrapper" style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 20px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                    <asp:GridView ID="gvRegulations" runat="server" GridLines="None" AutoGenerateColumns="true" CssClass="report-grid" style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;" AllowPaging="True" PageSize="15" OnPageIndexChanging="gvRegulations_PageIndexChanging" PagerStyle-CssClass="pager-style">
                        <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="true" HorizontalAlign="Left" Height="40px" />
                        <AlternatingRowStyle BackColor="#f8fafc" />
                        <EmptyDataTemplate>
                            <div class="report-grid-empty" style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff;">Enter a Book Number range and click Preview.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>

            <!-- TAB 3: ISSUANCE LISTING -->
            <div id="paneIssuances" class="tab-pane" style="display: none; width: 100%;">
                <div class="filter-container" style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px; width: 100%; box-sizing: border-box;">
                    <div class="filter-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; align-items: end; width: 100%; box-sizing: border-box;">
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">From Date</span>
                            <asp:TextBox ID="txtIssueFrom" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" Type="Date" />
                        </div>
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">To Date</span>
                            <asp:TextBox ID="txtIssueTo" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" Type="Date" />
                        </div>
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Report Type</span>
                            <asp:DropDownList ID="ddlIssueType" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;">
                                <asp:ListItem Value="Listing" Selected="True">Issue Listing (Detailed)</asp:ListItem>
                                <asp:ListItem Value="Member">Grouped By Member (Summary)</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Membership Number</span>
                            <asp:TextBox ID="txtIssueMemberNo" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" placeholder="Filter by Member No" />
                        </div>
                    </div>
                    <div style="display: flex; gap: 12px; justify-content: flex-end; border-top: 1px solid #e2e8f0; padding-top: 16px;">
                        <asp:Button ID="btnGenIssuance" runat="server" Text="Generate Listing" CssClass="btn-action-primary" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" OnClick="btnGenIssuance_Click" />
                        <asp:Button ID="btnExportIssuance" runat="server" Text="Export Excel" CssClass="btn-action-gold" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" OnClick="btnExportIssuance_Click" />
                        <asp:Button ID="btnPDFIssuance" runat="server" Text="Export PDF" CssClass="btn-action-gray no-print" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); display: inline-block;" OnClick="btnPDFIssuance_Click" />
                    </div>
                </div>

                <h3 style="font-size: 14px; color: #0f1e36; font-weight: 700; text-transform: uppercase; margin: 20px 0 10px 0; border-bottom: 2px solid #c5a059; padding-bottom: 6px;">Issuance Records <span style="color: #c5a059; font-weight: 600; text-transform: none; margin-left: 8px;"><asp:Literal ID="litIssuancesCount" runat="server" /></span></h3>
                <div class="report-grid-wrapper" style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 20px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                    <asp:GridView ID="gvIssuances" runat="server" GridLines="None" AutoGenerateColumns="true" CssClass="report-grid" style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;" AllowPaging="True" PageSize="15" OnPageIndexChanging="gvIssuances_PageIndexChanging" PagerStyle-CssClass="pager-style">
                        <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="true" HorizontalAlign="Left" Height="40px" />
                        <AlternatingRowStyle BackColor="#f8fafc" />
                        <EmptyDataTemplate>
                            <div class="report-grid-empty" style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff;">No issuance transactions found in this date range.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>

            <!-- TAB 4: RETURN LISTING -->
            <div id="paneReturns" class="tab-pane" style="display: none; width: 100%;">
                <div class="filter-container" style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px; width: 100%; box-sizing: border-box;">
                    <div class="filter-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 16px; align-items: end; width: 100%; box-sizing: border-box;">
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">From Date</span>
                            <asp:TextBox ID="txtReturnFrom" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" Type="Date" />
                        </div>
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">To Date</span>
                            <asp:TextBox ID="txtReturnTo" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" Type="Date" />
                        </div>
                    </div>
                    <div style="display: flex; gap: 12px; justify-content: flex-end; border-top: 1px solid #e2e8f0; padding-top: 16px;">
                        <asp:Button ID="btnGenReturns" runat="server" Text="Generate Listing" CssClass="btn-action-primary" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" OnClick="btnGenReturns_Click" />
                        <asp:Button ID="btnExportReturns" runat="server" Text="Export Excel" CssClass="btn-action-gold" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" OnClick="btnExportReturns_Click" />
                        <asp:Button ID="btnPDFReturns" runat="server" Text="Export PDF" CssClass="btn-action-gray no-print" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); display: inline-block;" OnClick="btnPDFReturns_Click" />
                    </div>
                </div>

                <h3 style="font-size: 14px; color: #0f1e36; font-weight: 700; text-transform: uppercase; margin: 20px 0 10px 0; border-bottom: 2px solid #c5a059; padding-bottom: 6px;">Returned Book Transaction Logs <span style="color: #c5a059; font-weight: 600; text-transform: none; margin-left: 8px;"><asp:Literal ID="litReturnsCount" runat="server" /></span></h3>
                <div class="report-grid-wrapper" style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 20px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                    <asp:GridView ID="gvReturns" runat="server" GridLines="None" AutoGenerateColumns="true" CssClass="report-grid" style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;" AllowPaging="True" PageSize="15" OnPageIndexChanging="gvReturns_PageIndexChanging" PagerStyle-CssClass="pager-style">
                        <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="true" HorizontalAlign="Left" Height="40px" />
                        <AlternatingRowStyle BackColor="#f8fafc" />
                        <EmptyDataTemplate>
                            <div class="report-grid-empty" style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff;">No book return records found in this date range.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>

            <!-- TAB 5: RESERVE LISTING -->
            <div id="paneReservations" class="tab-pane" style="display: none; width: 100%;">
                <div class="filter-container" style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px; width: 100%; box-sizing: border-box;">
                    <div class="filter-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 16px; align-items: end; width: 100%; box-sizing: border-box;">
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Book Number (Accession No)</span>
                            <asp:TextBox ID="txtReserveBookNo" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" placeholder="Filter by Book No" Type="Number" />
                        </div>
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Membership Number</span>
                            <asp:TextBox ID="txtReserveMemberNo" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" placeholder="Filter by Membership No" />
                        </div>
                    </div>
                    <div style="display: flex; gap: 12px; justify-content: flex-end; border-top: 1px solid #e2e8f0; padding-top: 16px;">
                        <asp:Button ID="btnGenReservations" runat="server" Text="Generate Listing" CssClass="btn-action-primary" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" OnClick="btnGenReservations_Click" />
                        <asp:Button ID="btnExportReservations" runat="server" Text="Export Excel" CssClass="btn-action-gold" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" OnClick="btnExportReservations_Click" />
                        <asp:Button ID="btnPDFReservations" runat="server" Text="Export PDF" CssClass="btn-action-gray no-print" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); display: inline-block;" OnClick="btnPDFReservations_Click" />
                    </div>
                </div>

                <h3 style="font-size: 14px; color: #0f1e36; font-weight: 700; text-transform: uppercase; margin: 20px 0 10px 0; border-bottom: 2px solid #c5a059; padding-bottom: 6px;">Book Reservation Requests <span style="color: #c5a059; font-weight: 600; text-transform: none; margin-left: 8px;"><asp:Literal ID="litReservationsCount" runat="server" /></span></h3>
                <div class="report-grid-wrapper" style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 20px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                    <asp:GridView ID="gvReservations" runat="server" GridLines="None" AutoGenerateColumns="true" CssClass="report-grid" style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;" AllowPaging="True" PageSize="15" OnPageIndexChanging="gvReservations_PageIndexChanging" PagerStyle-CssClass="pager-style">
                        <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="true" HorizontalAlign="Left" Height="40px" />
                        <AlternatingRowStyle BackColor="#f8fafc" />
                        <EmptyDataTemplate>
                            <div class="report-grid-empty" style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff;">No active or historic book reservations found.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>

            <!-- TAB 6: BOOK COST AUDIT -->
            <div id="paneCostAudit" class="tab-pane" style="display: none; width: 100%;">
                <div class="filter-container" style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 24px; border-radius: 8px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px; width: 100%; box-sizing: border-box;">
                    <div class="filter-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; align-items: end; width: 100%; box-sizing: border-box;">
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Book Number From</span>
                            <asp:TextBox ID="txtAuditBookNoFrom" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" placeholder="Min Book No" Type="Number" />
                        </div>
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Book Number To</span>
                            <asp:TextBox ID="txtAuditBookNoTo" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" placeholder="Max Book No" Type="Number" />
                        </div>
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Language</span>
                            <asp:DropDownList ID="ddlAuditLanguage" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" />
                        </div>
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Condition</span>
                            <asp:DropDownList ID="ddlAuditCondition" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" />
                        </div>
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Acquisition From</span>
                            <asp:TextBox ID="txtAuditAcqFrom" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" Type="Date" />
                        </div>
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Acquisition To</span>
                            <asp:TextBox ID="txtAuditAcqTo" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" Type="Date" />
                        </div>
                        <div class="filter-group" style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                            <span class="filter-label" style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Source</span>
                            <asp:TextBox ID="txtAuditSource" runat="server" CssClass="form-control" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" placeholder="e.g. Purchased, Donated" />
                        </div>
                    </div>
                    <div style="display: flex; gap: 12px; justify-content: flex-end; border-top: 1px solid #e2e8f0; padding-top: 16px;">
                        <asp:Button ID="btnGenCostAudit" runat="server" Text="Generate Listing" CssClass="btn-action-primary" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" OnClick="btnGenCostAudit_Click" />
                        <asp:Button ID="btnExportCostAudit" runat="server" Text="Export Excel" CssClass="btn-action-gold" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" OnClick="btnExportCostAudit_Click" />
                        <asp:Button ID="btnPDFCostAudit" runat="server" Text="Export PDF" CssClass="btn-action-gray no-print" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); display: inline-block;" OnClick="btnPDFCostAudit_Click" />
                    </div>
                </div>

                <h3 style="font-size: 14px; color: #0f1e36; font-weight: 700; text-transform: uppercase; margin: 20px 0 10px 0; border-bottom: 2px solid #c5a059; padding-bottom: 6px;">Book Cost Audit Results <span style="color: #c5a059; font-weight: 600; text-transform: none; margin-left: 8px;"><asp:Literal ID="litCostAuditCount" runat="server" /></span></h3>
                <div class="report-grid-wrapper" style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-top: 20px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
                    <asp:GridView ID="gvCostAudit" runat="server" GridLines="None" AutoGenerateColumns="true" CssClass="report-grid" style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;" AllowPaging="True" PageSize="15" OnPageIndexChanging="gvCostAudit_PageIndexChanging" PagerStyle-CssClass="pager-style">
                        <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="true" HorizontalAlign="Left" Height="40px" />
                        <AlternatingRowStyle BackColor="#f8fafc" />
                        <EmptyDataTemplate>
                            <div class="report-grid-empty" style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff;">No book cost records match the specified filters.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>

        </div>
    </div>

    <!-- Client-Side Tab Switching & Dynamic Printing Script -->
    <script type="text/javascript">
        function formatDate(dateStr) {
            if (!dateStr) return "";
            try {
                var date = new Date(dateStr);
                if (isNaN(date.getTime())) {
                    var match = /\/Date\((\d+)\)\//.exec(dateStr);
                    if (match) {
                        date = new Date(parseInt(match[1]));
                    } else {
                        return dateStr;
                    }
                }
                var dd = String(date.getDate()).padStart(2, "0");
                var mm = String(date.getMonth() + 1).padStart(2, "0");
                var yyyy = date.getFullYear();
                return dd + "/" + mm + "/" + yyyy;
            } catch (e) { return dateStr; }
        }

        function printReport() {
            var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
            var activeIdx = hf ? parseInt(hf.value) : 0;
            var panes = document.querySelectorAll('.tab-pane');
            
            for (var i = 0; i < panes.length; i++) {
                panes[i].classList.remove('active-print');
            }
            
            if (panes[activeIdx]) {
                panes[activeIdx].classList.add('active-print');
            }
            
            var printDateEl = document.getElementById('printDate');
            if (printDateEl) {
                var now = new Date();
                printDateEl.textContent = now.toLocaleDateString() + ' ' + now.toLocaleTimeString();
            }
            
            window.print();
        }

        function switchTab(index) {
            var btnStyleInactive = "padding: 16px 20px; text-align: center; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;";
            var btnStyleActive = "padding: 16px 20px; text-align: center; background-color: #ffffff; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #c5a059; border-bottom: 3px solid #c5a059; cursor: pointer; transition: all 0.25s ease; outline: none; flex-shrink: 0;";
            
            var btns = document.querySelectorAll('.tab-header-btn');
            for (var i = 0; i < btns.length; i++) {
                btns[i].classList.remove('active');
                btns[i].style.cssText = btnStyleInactive;
            }
            if (btns[index]) {
                btns[index].classList.add('active');
                btns[index].style.cssText = btnStyleActive;
            }

            var panes = document.querySelectorAll('.tab-pane');
            for (var i = 0; i < panes.length; i++) {
                panes[i].classList.remove('active');
                panes[i].style.display = 'none';
            }
            if (panes[index]) {
                panes[index].classList.add('active');
                panes[index].style.display = 'block';
            }

            var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
            if (hf) {
                hf.value = index;
            }
        }

        // Initialize tabs after full load/partial updates
        window.addEventListener('load', function () {
            // Bind hover events to non-active buttons to guarantee styles even without external CSS
            var btns = document.querySelectorAll('.tab-header-btn');
            for (var i = 0; i < btns.length; i++) {
                (function(idx) {
                    btns[idx].onmouseover = function() {
                        if (!this.classList.contains('active')) {
                            this.style.color = '#0f1e36';
                            this.style.backgroundColor = '#f1f5f9';
                        }
                    };
                    btns[idx].onmouseout = function() {
                        if (!this.classList.contains('active')) {
                            this.style.color = '#64748b';
                            this.style.backgroundColor = 'transparent';
                        }
                    };
                })(i);
            }

            var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
            var activeIdx = 0;
            if (hf && hf.value !== '') {
                var parsed = parseInt(hf.value);
                if (!isNaN(parsed)) {
                    activeIdx = parsed;
                }
            }
            switchTab(activeIdx);
        });

        // Trigger dynamic print preview popup for Labels or Regulations
        function triggerPrintWindow() {
            var hfData = document.getElementById('<%= hfPrintData.ClientID %>');
            var hfType = document.getElementById('<%= hfPrintType.ClientID %>');
            
            if (!hfData || !hfType || !hfData.value || !hfType.value) return;
            
            var data = JSON.parse(hfData.value);
            var printType = hfType.value;
            
            // Clean values to prevent repeated triggers
            hfData.value = "";
            hfType.value = "";
            
            if (printType === 'labels') {
                printLabelsPopup(data);
            } else if (printType === 'regulations') {
                printRegulationsPopup(data);
            }
        }

        function printLabelsPopup(data) {
            var w = window.open('', 'PrintLabels', 'width=850,height=900,scrollbars=yes');
            
            var html = '<!DOCTYPE html><html><head><title>Print Spine Labels</title><style>' +
                '@import url("https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&display=swap");' +
                'body { font-family: Arial, "Outfit", sans-serif; margin: 0; padding: 20px; background-color: #fff; color: #000; }' +
                '.label-grid { display: grid; grid-template-columns: repeat(2, 1fr); column-gap: 80px; row-gap: 50px; justify-items: center; }' +
                '.label-card { display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; box-sizing: border-box; page-break-inside: avoid; height: 130px; font-weight: bold; font-size: 24px; color: #000; }' +
                '.label-line { margin: 3px 0; line-height: 1.2; letter-spacing: 0.5px; }' +
                '@media print { body { padding: 0; } }' +
                '</style></head><body>';
                
            html += '<div class="label-grid">';
            for (var i = 0; i < data.length; i++) {
                var item = data[i];
                var barcodeVal = (item.Barcode || '').trim();
                var ddcVal = (item.DDC || item.ClassNo || '').trim();
                var authorVal = (item.Authors || '').trim();
                
                var ddcFirst = ddcVal;
                if (ddcVal.toLowerCase().indexOf(' to ') > -1) {
                    ddcFirst = ddcVal.substring(0, ddcVal.toLowerCase().indexOf(' to ')).trim();
                }
                
                var useBarcode = false;
                if (barcodeVal && barcodeVal.indexOf('-') > -1) {
                    if (/[a-zA-Z]/.test(barcodeVal)) {
                        useBarcode = true;
                    }
                }
                
                var source = useBarcode ? barcodeVal : ddcFirst;
                if (!source && ddcFirst) {
                    source = ddcFirst;
                }
                
                var line1 = '';
                var line2 = '';
                
                if (source) {
                    var parts = source.split('-');
                    if (parts.length >= 3) {
                        line1 = parts[0].trim();
                        line2 = parts[1].trim() + '-' + parts[2].trim();
                    } else if (parts.length === 2) {
                        line1 = parts[0].trim();
                        line2 = parts[1].trim();
                    } else {
                        line1 = source;
                        var cleanAuthor = authorVal.replace(/[^a-zA-Z]/g, '');
                        var authorCode = cleanAuthor.substring(0, 3).toUpperCase();
                        if (!authorCode) authorCode = 'UNK';
                        line2 = authorCode + '-1';
                    }
                } else {
                    line1 = 'N/A';
                    var cleanAuthor = authorVal.replace(/[^a-zA-Z]/g, '');
                    var authorCode = cleanAuthor.substring(0, 3).toUpperCase();
                    if (!authorCode) authorCode = 'UNK';
                    line2 = authorCode + '-1';
                }
                
                var bookNoPadded = String(item.BookNo).padStart(6, '0');
                var condChar = (item.Condition || 'Old').trim().charAt(0).toUpperCase();
                var line3 = bookNoPadded + '/' + condChar;
                
                html += '<div class="label-card">' +
                    '<div class="label-line">' + escapeHtml(line1) + '</div>' +
                    '<div class="label-line">' + escapeHtml(line2) + '</div>' +
                    '<div class="label-line">' + escapeHtml(line3) + '</div>' +
                    '</div>';
            }
            html += '</div>';
            
            html += '<script>window.onload = function() { setTimeout(function() { window.print(); }, 300); };<\/script></body></html>';
            w.document.write(html);
            w.document.close();
        }

        function printRegulationsPopup(data) {
            var w = window.open('', 'PrintRegulations', 'width=850,height=900,scrollbars=yes');
            
            var html = '<!DOCTYPE html><html><head><title>Print Regulations Slips</title><style>' +
                'body { font-family: "Segoe UI", Arial, sans-serif; margin: 0; padding: 0; background-color: #fff; color: #000; }' +
                '.slip-container { padding: 30px; margin: 20px auto; max-width: 650px; background-color: #fff; box-sizing: border-box; page-break-after: always; }' +
                '.slip-header { text-align: center; margin-bottom: 25px; }' +
                '.slip-header h2 { margin: 0; font-size: 19px; font-weight: bold; letter-spacing: 0.5px; text-transform: uppercase; }' +
                '.meta-row { display: flex; align-items: flex-end; margin-bottom: 12px; font-size: 13.5px; }' +
                '.meta-label { width: 140px; font-weight: normal; color: #000; flex-shrink: 0; }' +
                '.meta-value { flex-grow: 1; border-bottom: 1.5px solid #000; padding-bottom: 1px; padding-left: 5px; font-weight: normal; color: #000; }' +
                '.meta-row-split { display: flex; width: 100%; gap: 30px; }' +
                '.meta-col { display: flex; align-items: flex-end; flex: 1; }' +
                '.meta-col .meta-label { width: 100px; }' +
                '.regulations-title { font-weight: bold; font-size: 13px; text-transform: uppercase; text-decoration: underline; margin-top: 25px; margin-bottom: 10px; }' +
                '.regulations-list { font-size: 11.5px; line-height: 1.45; text-align: justify; }' +
                '.regulations-list ol { margin: 0; padding-left: 18px; }' +
                '.regulations-list li { margin-bottom: 6px; }' +
                '@media print { body { padding: 0; } .slip-container { margin: 0 auto; padding: 10px 0; } }' +
                '</style></head><body>';
                
            for (var i = 0; i < data.length; i++) {
                var item = data[i];
                var author = item.Authors || '';
                var ddc = item.Barcode || '';
                var receiptDate = formatDate(item.ReceiptDate);
                var copyCond = item.Condition || 'Old';
                
                var suitabilityArray = [];
                if (item.IsAdults) suitabilityArray.push("Adults only");
                if (item.IsChildren) suitabilityArray.push("Children");
                var suitability = suitabilityArray.length > 0 ? suitabilityArray.join(" / ") : "Adults only / Children";
                
                var bookNoPadded = String(item.BookNo).padStart(6, '0');
                
                html += '<div class="slip-container">' +
                    '<div class="slip-header">' +
                    '<h2>Lahore Gymkhana Library</h2>' +
                    '</div>' +
                    
                    '<div class="meta-row">' +
                    '<div class="meta-label">Title</div>' +
                    '<div class="meta-value">' + escapeHtml(item.Title) + '</div>' +
                    '</div>' +
                    
                    '<div class="meta-row">' +
                    '<div class="meta-label">Author</div>' +
                    '<div class="meta-value">' + escapeHtml(author) + '</div>' +
                    '</div>' +
                    
                    '<div class="meta-row-split">' +
                    '<div class="meta-col">' +
                    '<div class="meta-label">Book number</div>' +
                    '<div class="meta-value">' + bookNoPadded + '</div>' +
                    '</div>' +
                    '<div class="meta-col">' +
                    '<div class="meta-label">DDC Number</div>' +
                    '<div class="meta-value">' + escapeHtml(ddc) + '</div>' +
                    '</div>' +
                    '</div>' +
                    
                    '<div class="meta-row-split">' +
                    '<div class="meta-col">' +
                    '<div class="meta-label">Date of Receipt</div>' +
                    '<div class="meta-value">' + receiptDate + '</div>' +
                    '</div>' +
                    '<div class="meta-col">' +
                    '<div class="meta-label">Condition</div>' +
                    '<div class="meta-value">' + escapeHtml(copyCond) + '</div>' +
                    '</div>' +
                    '</div>' +
                    
                    '<div class="meta-row">' +
                    '<div class="meta-label">New Book Until</div>' +
                    '<div class="meta-value">&nbsp;</div>' +
                    '</div>' +
                    
                    '<div class="meta-row">' +
                    '<div class="meta-label">Book suitable for:</div>' +
                    '<div class="meta-value">' + suitability + '</div>' +
                    '</div>' +
                    
                    '<div class="regulations-title">LIBRARY REGULATION:</div>' +
                    '<div class="regulations-list">' +
                    '<ol>' +
                    '<li>Library cards must be made out by all members withdrawing books separate cards can be made for children.</li>' +
                    '<li>Single members will be allowed to take out 3 books at one time. of which one can be a new book.</li>' +
                    '<li>Family members are allowed to take out 3 books at one time in addition they can take out 2 children\'s books. Not more then one book of each category can be a new book.</li>' +
                    '<li>New books can be kept for a maximum of 14 days and this period can only be extended anew for 7 days. if there is no demand for the book from another member</li>' +
                    '<li>other books can be kept for 30 days</li>' +
                    '<li>all books taken out must be returned to the Librarian and under no circumstances should be placed on shelves</li>' +
                    '<li>FINES. as approved by the Club will be <u>automatically</u> charged if books are not returned on the due date. A book can be brought in to the Library within the due date and taken out again if there is no demand for it from another member</li>' +
                    '<li>A member who returns a book in a damaged condition will be liable for the cost of (a) rebinding the book or (b) replacing the book. The decision of the Convenor Library as to in which category the damage falls. shell be final.</li>' +
                    '<li>All books lost will be charged their original cost price plus 200% extra to cover enchance in price and the cost of replacement.</li>' +
                    '<li>Books kept in the Reference section may not be taken from the Library. but must be read on the premises.</li>' +
                    '<li>Books contained in the Rare Book section can only be read on the premises. However copies of pages can be make for members or scholars approaching through members. at a standard rate per page approved by the Library Committee from time to time.</li>' +
                    '</ol>' +
                    '</div>' +
                    '</div>';
            }
            
            html += '<script>window.onload = function() { setTimeout(function() { window.print(); }, 300); };<\/script></body></html>';
            w.document.write(html);
            w.document.close();
        }

        function escapeHtml(text) {
            if (!text) return '';
            var map = {
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#039;'
            };
            return text.replace(/[&<>"']/g, function(m) { return map[m]; });
        }
    </script>
    
    <!-- Auto-Trigger script registered after postbacks -->
    <asp:Literal ID="litTriggerPrint" runat="server" />
</asp:Content>
