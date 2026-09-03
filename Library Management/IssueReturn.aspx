<%@ Page Language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" AutoEventWireup="true" CodeFile="IssueReturn.aspx.cs" Inherits="Pages_Circulation_IssueReturn" Title="Books Circulation Menu - Lahore Gymkhana Library" %>

<asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
    <style type="text/css">
        /* Reset button appearance across all browsers */
        input[type="submit"], input[type="button"], button {
            -webkit-appearance: none !important;
            -moz-appearance: none !important;
            appearance: none !important;
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif !important;
        }

        .circ-container {
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif !important;
            color: #1e293b !important;
            background-color: #f1f5f9 !important;
            padding: 24px !important;
            border-radius: 14px !important;
            box-shadow: 0 10px 30px -5px rgba(0,0,0,0.08), 0 8px 10px -6px rgba(0,0,0,0.04) !important;
            margin: 0 !important;
            width: 100% !important;
            box-sizing: border-box !important;
        }
        
        .circ-header-bar {
            background: linear-gradient(135deg, #0f1e36 0%, #1e3a8a 100%) !important;
            color: #ffffff !important;
            padding: 18px 26px !important;
            border-radius: 12px !important;
            display: flex !important;
            justify-content: space-between !important;
            align-items: center !important;
            border-bottom: 4px solid #c5a059 !important;
            margin-bottom: 20px !important;
            box-shadow: 0 4px 14px rgba(15, 30, 54, 0.2) !important;
        }
        
        .circ-title {
            font-size: 20px !important;
            font-weight: 800 !important;
            margin: 0 !important;
            text-transform: uppercase !important;
            letter-spacing: 0.75px !important;
            color: #ffffff !important;
            display: flex !important;
            align-items: center !important;
            gap: 10px !important;
        }
        
        .circ-panel {
            background: #ffffff !important;
            border: 1px solid #cbd5e1 !important;
            border-radius: 12px !important;
            padding: 22px !important;
            margin-bottom: 20px !important;
            width: 100% !important;
            box-sizing: border-box !important;
            box-shadow: 0 2px 10px rgba(0,0,0,0.04) !important;
            transition: all 0.2s ease-in-out !important;
        }

        .circ-sec-header {
            display: flex !important;
            align-items: center !important;
            gap: 10px !important;
            font-size: 13.5px !important;
            font-weight: 700 !important;
            color: #0f1e36 !important;
            text-transform: uppercase !important;
            letter-spacing: 0.6px !important;
            padding-bottom: 12px !important;
            border-bottom: 2px solid #e2e8f0 !important;
            margin-bottom: 16px !important;
        }

        .circ-sec-badge {
            display: none !important;
        }
        
        .circ-label {
            font-size: 11px !important;
            font-weight: 700 !important;
            color: #475569 !important;
            text-transform: uppercase !important;
            display: block !important;
            margin-bottom: 5px !important;
            letter-spacing: 0.5px !important;
        }
        
        .circ-input-text {
            border: 1.5px solid #cbd5e1 !important;
            border-radius: 7px !important;
            padding: 8px 12px !important;
            font-size: 13.5px !important;
            font-weight: 600 !important;
            color: #0f1e36 !important;
            background-color: #ffffff !important;
            outline: none !important;
            box-sizing: border-box !important;
            transition: all 0.2s ease-in-out !important;
            height: 38px !important;
        }
        .circ-input-text:focus {
            border-color: #0f1e36 !important;
            box-shadow: 0 0 0 3px rgba(15, 30, 54, 0.12) !important;
            background-color: #ffffff !important;
        }
        
        .circ-input-readonly {
            border: 1px solid #cbd5e1 !important;
            border-radius: 7px !important;
            padding: 8px 12px !important;
            font-size: 13.5px !important;
            font-weight: 600 !important;
            color: #0f1e36 !important;
            background-color: #f8fafc !important;
            box-sizing: border-box !important;
            height: 38px !important;
        }

        /* ===== BUTTON SYSTEM ===== */
        .circ-btn-action {
            background: linear-gradient(135deg, #0f1e36 0%, #1e3a8a 100%) !important;
            color: #ffffff !important;
            border: none !important;
            border-radius: 7px !important;
            padding: 0 20px !important;
            height: 38px !important;
            font-size: 12px !important;
            font-weight: 700 !important;
            cursor: pointer !important;
            text-transform: uppercase !important;
            letter-spacing: 0.5px !important;
            transition: all 0.2s ease-in-out !important;
            box-shadow: 0 3px 8px rgba(15, 30, 54, 0.2) !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            outline: none !important;
        }
        .circ-btn-action:hover {
            background: linear-gradient(135deg, #c5a059 0%, #d4af37 100%) !important;
            color: #0f1e36 !important;
            transform: translateY(-1px) !important;
            box-shadow: 0 5px 12px rgba(197, 160, 89, 0.35) !important;
        }
        .circ-btn-action:active {
            transform: translateY(0) !important;
            box-shadow: 0 2px 6px rgba(15, 30, 54, 0.25) !important;
        }
        .circ-btn-action:disabled {
            opacity: 0.55 !important;
            cursor: not-allowed !important;
            transform: none !important;
        }

        .circ-btn-gold {
            background: linear-gradient(135deg, #c5a059 0%, #d4af37 100%) !important;
            color: #0f1e36 !important;
            border: none !important;
            border-radius: 7px !important;
            padding: 10px 18px !important;
            font-size: 13px !important;
            font-weight: 800 !important;
            cursor: pointer !important;
            text-transform: uppercase !important;
            letter-spacing: 0.5px !important;
            box-shadow: 0 4px 12px rgba(197, 160, 89, 0.35) !important;
            transition: all 0.2s ease-in-out !important;
            outline: none !important;
        }
        .circ-btn-gold:hover {
            background: linear-gradient(135deg, #0f1e36 0%, #1e3a8a 100%) !important;
            color: #ffffff !important;
            transform: translateY(-1px) !important;
            box-shadow: 0 6px 14px rgba(15, 30, 54, 0.3) !important;
        }
        .circ-btn-gold:active {
            transform: translateY(0) !important;
        }
        .circ-btn-gold:disabled {
            opacity: 0.55 !important;
            cursor: not-allowed !important;
            transform: none !important;
        }

        .circ-btn-green {
            background: linear-gradient(135deg, #16a34a 0%, #15803d 100%) !important;
            color: #ffffff !important;
            border: none !important;
            border-radius: 7px !important;
            padding: 10px 18px !important;
            font-size: 13px !important;
            font-weight: 800 !important;
            cursor: pointer !important;
            text-transform: uppercase !important;
            letter-spacing: 0.5px !important;
            box-shadow: 0 4px 12px rgba(22, 163, 74, 0.35) !important;
            transition: all 0.2s ease-in-out !important;
            outline: none !important;
        }
        .circ-btn-green:hover {
            background: linear-gradient(135deg, #15803d 0%, #166534 100%) !important;
            transform: translateY(-1px) !important;
            box-shadow: 0 6px 16px rgba(21, 128, 61, 0.45) !important;
        }
        .circ-btn-green:active {
            transform: translateY(0) !important;
        }
        .circ-btn-green:disabled {
            opacity: 0.55 !important;
            cursor: not-allowed !important;
            transform: none !important;
        }

        .circ-side-btns {
            display: flex !important;
            flex-direction: column !important;
            gap: 10px !important;
            min-width: 135px !important;
        }
        .circ-side-btns input[type="submit"], 
        .circ-side-btns input[type="button"],
        .circ-side-btns button {
            width: 100% !important;
            padding: 10px 16px !important;
            font-size: 12.5px !important;
            font-weight: 700 !important;
            border-radius: 7px !important;
            cursor: pointer !important;
            text-transform: uppercase !important;
            letter-spacing: 0.5px !important;
            transition: all 0.2s ease-in-out !important;
            box-sizing: border-box !important;
        }

        /* ===== TAB NAVIGATION ===== */
        .circ-tab-btn {
            padding: 12px 26px !important;
            font-size: 13px !important;
            font-weight: 700 !important;
            border: 1px solid #cbd5e1 !important;
            border-bottom: none !important;
            border-radius: 10px 10px 0 0 !important;
            background: #e2e8f0 !important;
            color: #475569 !important;
            cursor: pointer !important;
            outline: none !important;
            margin-right: 6px !important;
            transition: all 0.2s ease-in-out !important;
        }
        .circ-tab-btn:hover {
            background: #f1f5f9 !important;
            color: #0f1e36 !important;
        }
        .circ-tab-btn.active {
            background: #ffffff !important;
            color: #0f1e36 !important;
            border-color: #cbd5e1 !important;
            border-bottom: 3px solid #c5a059 !important;
            margin-bottom: -2px !important;
            box-shadow: 0 -4px 10px rgba(0,0,0,0.05) !important;
        }

        /* ===== GRIDVIEW TABLE ===== */
        .circ-grid {
            width: 100% !important;
            border-collapse: collapse !important;
            font-size: 12.5px !important;
            background: #ffffff !important;
            border: 1px solid #cbd5e1 !important;
            border-radius: 8px !important;
            overflow: hidden !important;
            box-shadow: 0 1px 4px rgba(0,0,0,0.03) !important;
        }
        .circ-grid th {
            background: #0f1e36 !important;
            color: #ffffff !important;
            padding: 11px 14px !important;
            font-weight: 700 !important;
            text-align: left !important;
            text-transform: uppercase !important;
            font-size: 11px !important;
            letter-spacing: 0.6px !important;
            border: 1px solid #1c3254 !important;
        }
        .circ-grid td {
            padding: 10px 14px !important;
            border: 1px solid #e2e8f0 !important;
            color: #1e293b !important;
            vertical-align: middle !important;
        }
        .circ-grid tr:nth-child(even) {
            background-color: #f8fafc !important;
        }
        .circ-grid tr:hover {
            background-color: #f1f5f9 !important;
        }

        /* ===== COLOR PALETTE STRIPS ===== */
        .circ-color-strip-member { border-left: 5px solid #7c3aed !important; }
        .circ-color-strip-issue { border-left: 5px solid #16a34a !important; }
        .circ-color-strip-return { border-left: 5px solid #2563eb !important; }
        .circ-color-strip-reserve { border-left: 5px solid #c5a059 !important; }
        .circ-color-strip-report { border-left: 5px solid #0891b2 !important; }

        /* Report Quick Action Card Hover Animation */
        .circ-report-card {
            transition: all 0.22s ease-in-out !important;
        }
        .circ-report-card:hover {
            transform: translateY(-3px) !important;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08) !important;
        }

        /* Alert focus animation */
        @keyframes alertPulse {
            0% { transform: scale(1); }
            30% { transform: scale(1.01); }
            60% { transform: scale(1); }
        }
        .circ-alert-animate {
            animation: alertPulse 0.4s ease-out !important;
        }

        /* ===== CONFIRMATION MODAL OVERLAY & BOX ===== */
        .circ-confirm-overlay {
            position: fixed !important; 
            top: 0 !important; 
            left: 0 !important; 
            width: 100% !important; 
            height: 100% !important;
            background-color: rgba(15, 23, 42, 0.7) !important; 
            z-index: 10001 !important;
            display: flex !important; 
            align-items: center !important; 
            justify-content: center !important;
            backdrop-filter: blur(5px) !important;
        }
        .circ-confirm-box {
            background-color: #ffffff !important; 
            border-radius: 20px !important;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25), 0 10px 15px -3px rgba(0, 0, 0, 0.1) !important;
            max-width: 450px !important; 
            width: 92% !important; 
            padding: 32px 28px !important; 
            text-align: center !important;
            position: relative !important;
        }
        .circ-confirm-box.confirm-return { border-top: 6px solid #16a34a !important; }
        .circ-confirm-box.confirm-renew { border-top: 6px solid #d97706 !important; }
        
        .circ-confirm-icon {
            display: none !important;
        }
        
        .circ-confirm-title {
            font-size: 18px !important; 
            font-weight: 800 !important; 
            color: #0f1e36 !important;
            margin: 0 0 8px 0 !important; 
            text-transform: uppercase !important; 
            letter-spacing: 0.6px !important;
        }
        .circ-confirm-msg {
            font-size: 14px !important; 
            color: #475569 !important; 
            margin: 0 0 12px 0 !important; 
            line-height: 1.5 !important;
        }
        .circ-confirm-detail {
            font-size: 13px !important; 
            color: #334155 !important; 
            margin: 0 0 24px 0 !important;
            background: #f8fafc !important; 
            border: 1px solid #e2e8f0 !important; 
            border-radius: 10px !important;
            padding: 12px 16px !important; 
            text-align: left !important;
            line-height: 1.6 !important;
        }
        .circ-confirm-actions {
            display: flex !important; 
            gap: 14px !important; 
            justify-content: center !important;
        }

        /* Modal Action Buttons Styling */
        input[type="submit"].circ-confirm-yes,
        input[type="button"].circ-confirm-yes,
        button.circ-confirm-yes,
        .circ-confirm-yes {
            -webkit-appearance: none !important;
            appearance: none !important;
            padding: 12px 28px !important; 
            border-radius: 30px !important; 
            border: none !important;
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif !important;
            font-weight: 800 !important; 
            font-size: 13px !important; 
            cursor: pointer !important;
            text-transform: uppercase !important; 
            letter-spacing: 0.6px !important;
            transition: all 0.2s ease-in-out !important;
            outline: none !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
        }
        input[type="submit"].circ-confirm-yes.btn-return,
        .circ-confirm-yes.btn-return {
            background: linear-gradient(135deg, #16a34a 0%, #15803d 100%) !important;
            color: #ffffff !important; 
            box-shadow: 0 4px 14px rgba(22, 163, 74, 0.35) !important;
        }
        input[type="submit"].circ-confirm-yes.btn-return:hover,
        .circ-confirm-yes.btn-return:hover {
            background: linear-gradient(135deg, #15803d 0%, #166534 100%) !important;
            transform: translateY(-2px) !important;
            box-shadow: 0 6px 18px rgba(22, 163, 74, 0.45) !important;
        }
        input[type="submit"].circ-confirm-yes.btn-renew,
        .circ-confirm-yes.btn-renew {
            background: linear-gradient(135deg, #d97706 0%, #b45309 100%) !important;
            color: #ffffff !important; 
            box-shadow: 0 4px 14px rgba(217, 119, 6, 0.35) !important;
        }
        input[type="submit"].circ-confirm-yes.btn-renew:hover,
        .circ-confirm-yes.btn-renew:hover {
            background: linear-gradient(135deg, #b45309 0%, #92400e 100%) !important;
            transform: translateY(-2px) !important;
            box-shadow: 0 6px 18px rgba(217, 119, 6, 0.45) !important;
        }

        input[type="submit"].circ-confirm-no,
        input[type="button"].circ-confirm-no,
        button.circ-confirm-no,
        .circ-confirm-no {
            -webkit-appearance: none !important;
            appearance: none !important;
            padding: 12px 28px !important; 
            border-radius: 30px !important;
            border: 1.5px solid #cbd5e1 !important; 
            background: #ffffff !important;
            color: #475569 !important; 
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif !important;
            font-weight: 700 !important; 
            font-size: 13px !important;
            cursor: pointer !important; 
            text-transform: uppercase !important;
            letter-spacing: 0.5px !important;
            transition: all 0.2s ease-in-out !important;
            outline: none !important;
            box-shadow: 0 2px 6px rgba(0,0,0,0.04) !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
        }
        input[type="submit"].circ-confirm-no:hover,
        input[type="button"].circ-confirm-no:hover,
        button.circ-confirm-no:hover,
        .circ-confirm-no:hover {
            background: #f1f5f9 !important;
            color: #0f1e36 !important;
            border-color: #94a3b8 !important;
            transform: translateY(-1px) !important;
            box-shadow: 0 4px 10px rgba(0,0,0,0.08) !important;
        }

        /* ===== RESPONSIVE ADJUSTMENTS (Desktop / Laptop / Tablet) ===== */
        @media (max-width: 1024px) {
            .circ-container { padding: 18px !important; }
            .circ-header-bar { padding: 16px 20px !important; flex-wrap: wrap !important; gap: 10px !important; }
        }
        @media (max-width: 900px) {
            .circ-panel, .circ-container > div { flex-wrap: wrap !important; }
            .circ-side-btns { flex-direction: row !important; min-width: 100% !important; }
            .circ-side-btns input[type="submit"],
            .circ-side-btns input[type="button"],
            .circ-side-btns button { width: auto !important; flex: 1 1 auto !important; }
        }
        @media (max-width: 768px) {
            .circ-title { font-size: 17px !important; }
            .circ-tab-btn { padding: 10px 16px !important; font-size: 12px !important; }
            .circ-grid { font-size: 11.5px !important; }
        }
    </style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">
    <asp:UpdatePanel ID="upCirculation" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <div class="circ-container" style="font-family: 'Segoe UI', system-ui, -apple-system, sans-serif !important; color: #1e293b !important; background-color: #f1f5f9 !important; padding: 22px !important; border-radius: 14px !important; box-shadow: 0 10px 30px -5px rgba(0,0,0,0.08), 0 8px 10px -6px rgba(0,0,0,0.04) !important; margin: 0 !important; width: 100% !important; box-sizing: border-box !important;">
                
                <!-- Top Main Header Bar -->
                <div class="circ-header-bar" style="background: linear-gradient(135deg, #0f1e36 0%, #1e3a8a 100%) !important; color: #ffffff !important; padding: 18px 26px !important; border-radius: 12px !important; display: flex !important; justify-content: space-between !important; align-items: center !important; border-bottom: 4px solid #c5a059 !important; margin-bottom: 20px !important; box-shadow: 0 4px 14px rgba(15, 30, 54, 0.2) !important;">
                    <div>
                        <h2 class="circ-title" style="font-size: 20px !important; font-weight: 800 !important; margin: 0 !important; text-transform: uppercase !important; letter-spacing: 0.75px !important; color: #ffffff !important; display: flex !important; align-items: center !important; gap: 10px !important;">
                            Books Circulation Menu
                        </h2>
                    </div>
                    <div style="font-size: 12.5px !important; font-weight: 600 !important; background: rgba(255,255,255,0.1) !important; color: #ffffff !important; padding: 6px 14px !important; border-radius: 20px !important; border: 1px solid rgba(255,255,255,0.2) !important;">
                        Lahore Gymkhana Library Management System
                    </div>
                </div>

                <!-- Global Alert Panel -->
                <asp:Panel ID="pnlAlert" runat="server" Visible="false" style="margin-bottom: 20px !important; width: 100% !important;">
                    <div id="divAlert" runat="server" class="circ-alert-animate" style="padding: 14px 20px !important; border-radius: 10px !important; font-size: 13.5px !important; font-weight: 600 !important; box-shadow: 0 2px 6px rgba(0,0,0,0.06) !important;">
                        <asp:Literal ID="litAlertMsg" runat="server" />
                    </div>
                </asp:Panel>

                <!-- =========================================================
                     SHARED TOP MEMBER INFORMATION PANEL (Step 1 Verification)
                     ========================================================= -->
                <div class="circ-panel circ-color-strip-member" style="background: #ffffff !important; border: 1.5px solid #cbd5e1 !important; border-left: 5px solid #7c3aed !important; border-radius: 12px !important; padding: 22px !important; margin-bottom: 20px !important; width: 100% !important; box-sizing: border-box !important; box-shadow: 0 2px 10px rgba(0,0,0,0.04) !important;">
                    <!-- Section Header -->
                    <div class="circ-sec-header" style="display: flex !important; align-items: center !important; gap: 10px !important; font-size: 13.5px !important; font-weight: 800 !important; color: #0f1e36 !important; text-transform: uppercase !important; letter-spacing: 0.65px !important; padding: 13px 18px !important; margin-bottom: 18px !important; background: #f5f3ff !important; border: 1px solid #ddd6fe !important; border-left: 4px solid #7c3aed !important; border-radius: 8px !important; box-shadow: 0 1px 3px rgba(0,0,0,0.04) !important;">
                        <span style="display: inline-block !important; width: 8px !important; height: 8px !important; border-radius: 50% !important; background: #7c3aed !important; flex-shrink: 0 !important;"></span>
                        <span>Member Information & Verification</span>
                    </div>

                    <!-- Member Search & Header Fields -->
                    <div style="display: flex !important; gap: 16px !important; align-items: center !important; flex-wrap: wrap !important; margin-bottom: 18px !important; border-bottom: 1px dashed #e2e8f0 !important; padding-bottom: 18px !important; width: 100% !important;">
                        <div style="display: flex !important; align-items: center !important; gap: 10px !important; flex-wrap: wrap !important;">
                            <span class="circ-label" style="margin: 0 !important; font-size: 12px !important; font-weight: 700 !important; color: #334155 !important; width: 140px !important; text-transform: uppercase !important; letter-spacing: 0.5px !important; display: block !important;">Member No/Name:</span>
                            <asp:TextBox ID="txtMemberNo" runat="server" CssClass="circ-input-text" style="-webkit-appearance: none !important; appearance: none !important; border: 1.5px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 600 !important; color: #0f1e36 !important; background-color: #ffffff !important; outline: none !important; box-sizing: border-box !important; height: 38px !important; width: 140px !important;" AutoPostBack="true" OnTextChanged="txtMemberNo_TextChanged" placeholder="Enter Member No" />
                            <asp:Button ID="btnVerifyMember" runat="server" Text="Search" OnClick="btnVerifyMember_Click" CssClass="circ-btn-action" style="-webkit-appearance: none !important; appearance: none !important; background: linear-gradient(135deg, #0f1e36 0%, #1e3a8a 100%) !important; color: #ffffff !important; border: none !important; border-radius: 7px !important; padding: 0 20px !important; height: 38px !important; font-size: 12px !important; font-weight: 700 !important; cursor: pointer !important; text-transform: uppercase !important; letter-spacing: 0.5px !important; box-shadow: 0 3px 8px rgba(15, 30, 54, 0.2) !important; display: inline-flex !important; align-items: center !important; justify-content: center !important; outline: none !important;" />
                            <asp:TextBox ID="txtMemberName" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 800 !important; color: #0f1e36 !important; background-color: #f8fafc !important; box-sizing: border-box !important; height: 38px !important; width: 280px !important;" />
                        </div>

                        <!-- Radio Category Indicator -->
                        <div style="margin-left: auto !important; display: flex !important; gap: 16px !important; font-size: 13px !important; font-weight: 700 !important; color: #334155 !important; background: #f8fafc !important; padding: 8px 18px !important; border-radius: 8px !important; border: 1px solid #e2e8f0 !important;">
                            <label style="cursor: pointer !important; display: flex !important; align-items: center !important; gap: 6px !important;"><input type="radio" name="memberTypeRad" checked="checked" style="accent-color: #0f1e36 !important; width: 15px !important; height: 15px !important; cursor: pointer !important;" /> Member</label>
                            <label style="cursor: pointer !important; display: flex !important; align-items: center !important; gap: 6px !important;"><input type="radio" name="memberTypeRad" style="accent-color: #0f1e36 !important; width: 15px !important; height: 15px !important; cursor: pointer !important;" /> Staff</label>
                            <label style="cursor: pointer !important; display: flex !important; align-items: center !important; gap: 6px !important;"><input type="radio" name="memberTypeRad" style="accent-color: #0f1e36 !important; width: 15px !important; height: 15px !important; cursor: pointer !important;" /> Others</label>
                        </div>
                    </div>

                    <!-- Member Metadata Detailed Grid -->
                    <div style="display: grid !important; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)) !important; gap: 14px 16px !important; align-items: center !important; width: 100% !important;">
                        <div>
                            <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Membership Type:</span>
                            <asp:TextBox ID="txtMembershipType" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 600 !important; color: #0f1e36 !important; background-color: #f8fafc !important; box-sizing: border-box !important; height: 38px !important; width: 100% !important;" />
                        </div>
                        <div>
                            <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Status:</span>
                            <asp:TextBox ID="txtMemberStatus" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #a7f3d0 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; color: #15803d !important; font-weight: 800 !important; background-color: #d1fae5 !important; box-sizing: border-box !important; height: 38px !important; width: 100% !important;" />
                        </div>
                        <div>
                            <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Membership Status:</span>
                            <asp:TextBox ID="txtMembershipStatus" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 600 !important; color: #0f1e36 !important; background-color: #f8fafc !important; box-sizing: border-box !important; height: 38px !important; width: 100% !important;" />
                        </div>
                        <div>
                            <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Max. Loan Period:</span>
                            <asp:TextBox ID="txtMaxLoanPeriod" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 600 !important; color: #0f1e36 !important; background-color: #f8fafc !important; box-sizing: border-box !important; height: 38px !important; width: 100% !important; text-align: center !important;" />
                        </div>
                        <div>
                            <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Renewal(s):</span>
                            <asp:TextBox ID="txtRenewalsAllowed" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 600 !important; color: #0f1e36 !important; background-color: #f8fafc !important; box-sizing: border-box !important; height: 38px !important; width: 100% !important; text-align: center !important;" />
                        </div>
                        <div>
                            <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Late Fine Per Day:</span>
                            <asp:TextBox ID="txtLateFinePerDay" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #fca5a5 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; color: #b91c1c !important; font-weight: 800 !important; background-color: #fee2e2 !important; box-sizing: border-box !important; height: 38px !important; width: 100% !important; text-align: center !important;" />
                        </div>
                        <div>
                            <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Max. Book Issue:</span>
                            <asp:TextBox ID="txtMaxBookIssue" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 600 !important; color: #0f1e36 !important; background-color: #f8fafc !important; box-sizing: border-box !important; height: 38px !important; width: 100% !important; text-align: center !important;" />
                        </div>
                        <div>
                            <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Already Issue (M/MS/Total):</span>
                            <div style="display: flex !important; gap: 6px !important;">
                                <asp:TextBox ID="txtAlreadyIssuedM" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 4px !important; font-size: 13.5px !important; width: 33% !important; text-align:center !important; font-weight: 700 !important; height: 38px !important; background: #f8fafc !important;" />
                                <asp:TextBox ID="txtAlreadyIssuedMS" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 4px !important; font-size: 13.5px !important; width: 33% !important; text-align:center !important; font-weight: 700 !important; height: 38px !important; background: #f8fafc !important;" />
                                <asp:TextBox ID="txtAlreadyIssuedTotal" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1.5px solid #d97706 !important; border-radius: 7px !important; padding: 8px 4px !important; font-size: 13.5px !important; width: 33% !important; text-align:center !important; font-weight: 800 !important; color: #92400e !important; background: #fef3c7 !important; height: 38px !important;" />
                            </div>
                        </div>
                    </div>

                    <!-- Already Issued Books Collapsible / View -->
                    <asp:Panel ID="pnlAlreadyIssuedSection" runat="server" Visible="false" style="margin-top: 18px !important; border-top: 1px dashed #cbd5e1 !important; padding-top: 16px !important; width: 100% !important;">
                        <div style="font-size: 12.5px !important; font-weight: 700 !important; color: #0f1e36 !important; text-transform: uppercase !important; margin-bottom: 10px !important; letter-spacing: 0.5px !important; display: flex !important; align-items: center !important; gap: 8px !important;">
                            <span>Books Currently Issued To Member</span>
                        </div>
                        <asp:GridView ID="gvMemberActiveLoans" runat="server" AutoGenerateColumns="false" CssClass="circ-grid" style="width: 100% !important; border-collapse: collapse !important; font-size: 12.5px !important; background: #ffffff !important; border: 1px solid #cbd5e1 !important; border-radius: 8px !important; overflow: hidden !important;" EmptyDataText="No books currently issued to this member.">
                            <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="true" Height="38px" />
                            <RowStyle Height="36px" BackColor="#ffffff" ForeColor="#1e293b" />
                            <AlternatingRowStyle BackColor="#f8fafc" />
                            <EmptyDataRowStyle ForeColor="#64748b" Font-Italic="true" />
                            <Columns>
                                <asp:BoundField DataField="BookNo" HeaderText="Book No" HeaderStyle-Width="110px" ItemStyle-Font-Bold="true" />
                                <asp:BoundField DataField="Title" HeaderText="Book Title" />
                                <asp:BoundField DataField="IssueDate" HeaderText="Issue Date" DataFormatString="{0:dd/MM/yyyy}" HeaderStyle-Width="110px" ItemStyle-HorizontalAlign="Center" />
                                <asp:BoundField DataField="DueDate" HeaderText="Due Date" DataFormatString="{0:dd/MM/yyyy}" HeaderStyle-Width="110px" ItemStyle-HorizontalAlign="Center" />
                                <asp:BoundField DataField="FineAmount" HeaderText="Fine (Rs)" DataFormatString="{0:N0}" HeaderStyle-Width="90px" ItemStyle-HorizontalAlign="Right" ItemStyle-Font-Bold="true" ItemStyle-ForeColor="#b91c1c" />
                            </Columns>
                        </asp:GridView>
                    </asp:Panel>
                </div>

                <!-- =========================================================
                     CIRCULATION TABS SYSTEM
                     ========================================================= -->
                <div style="display: flex !important; border-bottom: 2px solid #cbd5e1 !important; margin-bottom: 0 !important; width: 100% !important; gap: 6px !important;">
                    <asp:Button ID="btnTabIssue" runat="server" Text="New Issues" OnClick="btnTabIssue_Click" CssClass="circ-tab-btn active" style="-webkit-appearance: none !important; appearance: none !important; padding: 12px 26px !important; font-size: 13px !important; font-weight: 700 !important; border: 1px solid #cbd5e1 !important; border-bottom: 3px solid #c5a059 !important; border-radius: 10px 10px 0 0 !important; background: #ffffff !important; color: #0f1e36 !important; cursor: pointer !important; outline: none !important; margin-right: 6px !important; margin-bottom: -2px !important; box-shadow: 0 -4px 10px rgba(0,0,0,0.05) !important;" />
                    <asp:Button ID="btnTabReturn" runat="server" Text="Returns & Renewals" OnClick="btnTabReturn_Click" CssClass="circ-tab-btn" style="-webkit-appearance: none !important; appearance: none !important; padding: 12px 26px !important; font-size: 13px !important; font-weight: 700 !important; border: 1px solid #cbd5e1 !important; border-bottom: none !important; border-radius: 10px 10px 0 0 !important; background: #e2e8f0 !important; color: #475569 !important; cursor: pointer !important; outline: none !important; margin-right: 6px !important;" />
                    <asp:Button ID="btnTabReservation" runat="server" Text="Reservations" OnClick="btnTabReservation_Click" CssClass="circ-tab-btn" style="-webkit-appearance: none !important; appearance: none !important; padding: 12px 26px !important; font-size: 13px !important; font-weight: 700 !important; border: 1px solid #cbd5e1 !important; border-bottom: none !important; border-radius: 10px 10px 0 0 !important; background: #e2e8f0 !important; color: #475569 !important; cursor: pointer !important; outline: none !important; margin-right: 6px !important;" />
                </div>

                <div style="background: #ffffff !important; border: 1.5px solid #cbd5e1 !important; border-top: none !important; border-radius: 0 0 12px 12px !important; padding: 22px !important; margin-bottom: 20px !important; width: 100% !important; box-sizing: border-box !important; box-shadow: 0 4px 14px rgba(0,0,0,0.05) !important;">

                    <!-- =========================================================
                         MODE 1: NEW ISSUE PROCEDURE
                         ========================================================= -->
                    <asp:Panel ID="pnlModeIssue" runat="server" Visible="true" style="width: 100% !important;" CssClass="circ-color-strip-issue">
                        <!-- Sub Section Header -->
                        <div class="circ-sec-header" style="display: flex !important; align-items: center !important; gap: 10px !important; font-size: 13.5px !important; font-weight: 800 !important; color: #0f1e36 !important; text-transform: uppercase !important; letter-spacing: 0.65px !important; padding: 13px 18px !important; margin-bottom: 18px !important; background: #f0fdf4 !important; border: 1px solid #bbf7d0 !important; border-left: 4px solid #16a34a !important; border-radius: 8px !important; box-shadow: 0 1px 3px rgba(0,0,0,0.04) !important;">
                            <span style="display: inline-block !important; width: 8px !important; height: 8px !important; border-radius: 50% !important; background: #16a34a !important; flex-shrink: 0 !important;"></span>
                            <span>New Book Issuance Procedure</span>
                        </div>

                        <!-- Step 2 & 3 Bar: Inputs & Basket Grid -->
                        <div style="display: flex !important; gap: 18px !important; margin-bottom: 18px !important; align-items: center !important; flex-wrap: wrap !important;">
                            <div>
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Issue No:</span>
                                <asp:TextBox ID="txtIssueNo" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 800 !important; color: #0f1e36 !important; background-color: #f8fafc !important; width: 130px !important; text-align: center !important; height: 38px !important; box-sizing: border-box !important;" />
                            </div>
                            <div>
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Issue Date:</span>
                                <asp:TextBox ID="txtIssueDate" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 700 !important; color: #0f1e36 !important; background-color: #f8fafc !important; width: 130px !important; text-align: center !important; height: 38px !important; box-sizing: border-box !important;" />
                            </div>
                            <div style="display: flex !important; align-items: center !important; gap: 8px !important; padding-top: 16px !important;">
                                <asp:CheckBox ID="chkDirectPrint" runat="server" Text=" Direct Print Receipt" Checked="true" Font-Bold="true" Font-Size="13px" ForeColor="#0f1e36" style="cursor: pointer !important; display: flex !important; align-items: center !important; gap: 6px !important; font-size: 13px !important; font-weight: 700 !important; color: #0f1e36 !important; accent-color: #0f1e36 !important;" />
                            </div>
                        </div>

                        <!-- Step 2: Book Entry Inputs -->
                        <div style="background: #f8fafc !important; border: 1px solid #e2e8f0 !important; border-radius: 10px !important; padding: 18px !important; margin-bottom: 18px !important; display: grid !important; grid-template-columns: repeat(auto-fit, minmax(170px, 1fr)) !important; gap: 14px !important; width: 100% !important; box-sizing: border-box !important;">
                            <div>
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Book No / Barcode:</span>
                                <div style="display: flex !important; gap: 6px !important;">
                                    <asp:TextBox ID="txtIssueBookNo" runat="server" CssClass="circ-input-text" style="-webkit-appearance: none !important; appearance: none !important; border: 1.5px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 600 !important; color: #0f1e36 !important; background-color: #ffffff !important; width: 100% !important; height: 38px !important; box-sizing: border-box !important; outline: none !important;" AutoPostBack="true" OnTextChanged="txtIssueBookNo_TextChanged" placeholder="Enter Book No" />
                                    <asp:Button ID="btnFetchIssueBook" runat="server" Text="Fetch" OnClick="btnFetchIssueBook_Click" CssClass="circ-btn-action" style="-webkit-appearance: none !important; appearance: none !important; background: linear-gradient(135deg, #0f1e36 0%, #1e3a8a 100%) !important; color: #ffffff !important; border: none !important; border-radius: 7px !important; padding: 0 20px !important; height: 38px !important; font-size: 12px !important; font-weight: 700 !important; cursor: pointer !important; text-transform: uppercase !important; letter-spacing: 0.5px !important; box-shadow: 0 3px 8px rgba(15, 30, 54, 0.2) !important; display: inline-flex !important; align-items: center !important; justify-content: center !important; outline: none !important;" />
                                </div>
                            </div>
                            <div style="grid-column: span 2 !important;">
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Book Title:</span>
                                <asp:TextBox ID="txtIssueBookTitle" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 700 !important; color: #0f1e36 !important; background-color: #f8fafc !important; width: 100% !important; height: 38px !important; box-sizing: border-box !important;" />
                            </div>
                            <div>
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">DDC No:</span>
                                <asp:TextBox ID="txtIssueDDC" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 600 !important; color: #0f1e36 !important; background-color: #f8fafc !important; width: 100% !important; height: 38px !important; box-sizing: border-box !important;" />
                            </div>
                            <div>
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Return Date (30 Days Auto):</span>
                                <asp:TextBox ID="txtIssueReturnDate" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1.5px solid #d97706 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 800 !important; color: #92400e !important; background-color: #fef3c7 !important; width: 100% !important; text-align: center !important; height: 38px !important; box-sizing: border-box !important;" />
                            </div>
                        </div>

                        <!-- Grid & Action Buttons Container -->
                        <div style="display: flex !important; gap: 18px !important; width: 100% !important;">
                            <div style="flex: 1 !important; overflow-x: auto !important;">
                                <asp:GridView ID="gvIssueBasket" runat="server" AutoGenerateColumns="false" CssClass="circ-grid" style="width: 100% !important; border-collapse: collapse !important; font-size: 12.5px !important; background: #ffffff !important; border: 1px solid #cbd5e1 !important; border-radius: 8px !important; overflow: hidden !important;" EmptyDataText="No books added for issuance yet. Enter Book No above." OnRowCommand="gvIssueBasket_RowCommand">
                                    <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="true" Height="38px" />
                                    <RowStyle Height="36px" BackColor="#ffffff" ForeColor="#1e293b" />
                                    <AlternatingRowStyle BackColor="#f8fafc" />
                                    <EmptyDataRowStyle ForeColor="#64748b" Font-Italic="true" />
                                    <Columns>
                                        <asp:BoundField DataField="BookNo" HeaderText="BookNo" HeaderStyle-Width="110px" ItemStyle-Font-Bold="true" />
                                        <asp:BoundField DataField="Ref" HeaderText="R" HeaderStyle-Width="40px" ItemStyle-HorizontalAlign="Center" />
                                        <asp:BoundField DataField="Title" HeaderText="Book Title" />
                                        <asp:BoundField DataField="DDC" HeaderText="DDC No" HeaderStyle-Width="130px" />
                                        <asp:BoundField DataField="ReturnDate" HeaderText="Return Date" DataFormatString="{0:dd/MM/yyyy}" HeaderStyle-Width="120px" ItemStyle-HorizontalAlign="Center" />
                                        <asp:TemplateField HeaderText="Action" HeaderStyle-Width="90px" ItemStyle-HorizontalAlign="Center">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="lnkRemoveIssue" runat="server" CommandName="RemoveBook" CommandArgument='<%# Container.DataItemIndex %>' Text="Remove" style="color: #b91c1c !important; font-weight: 700 !important; text-decoration: none !important; padding: 5px 10px !important; border-radius: 20px !important; background: #fee2e2 !important; border: 1px solid #fca5a5 !important; font-size: 11px !important; text-transform: uppercase !important; display: inline-block !important;" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>

                            <!-- Right Action Buttons -->
                            <div class="circ-side-btns" style="display: flex !important; flex-direction: column !important; gap: 10px !important; min-width: 135px !important;">
                                <asp:Button ID="btnIssueRefresh" runat="server" Text="Refresh" OnClick="btnIssueRefresh_Click" style="-webkit-appearance: none !important; appearance: none !important; background: #ffffff !important; color: #334155 !important; border: 1.5px solid #cbd5e1 !important; border-radius: 7px !important; padding: 10px 16px !important; font-size: 12px !important; font-weight: 700 !important; cursor: pointer !important; text-transform: uppercase !important; width: 100% !important; box-shadow: 0 1px 3px rgba(0,0,0,0.05) !important;" />
                                <asp:Button ID="btnIssueNew" runat="server" Text="New" OnClick="btnIssueNew_Click" style="-webkit-appearance: none !important; appearance: none !important; background: #f8fafc !important; color: #0f1e36 !important; border: 1.5px solid #0f1e36 !important; border-radius: 7px !important; padding: 10px 16px !important; font-size: 12px !important; font-weight: 700 !important; cursor: pointer !important; text-transform: uppercase !important; width: 100% !important; box-shadow: 0 1px 3px rgba(0,0,0,0.05) !important;" />
                                <asp:Button ID="btnSaveIssue" runat="server" Text="Save Issue" OnClick="btnSaveIssue_Click" CssClass="circ-btn-gold" style="-webkit-appearance: none !important; appearance: none !important; background: linear-gradient(135deg, #d97706 0%, #b45309 100%) !important; color: #ffffff !important; border: none !important; border-radius: 7px !important; padding: 11px 16px !important; font-size: 12.5px !important; font-weight: 800 !important; cursor: pointer !important; text-transform: uppercase !important; letter-spacing: 0.5px !important; width: 100% !important; box-shadow: 0 4px 12px rgba(217, 119, 6, 0.35) !important;" />
                                <asp:Button ID="btnIssueClose" runat="server" Text="Close" OnClick="btnIssueClose_Click" style="-webkit-appearance: none !important; appearance: none !important; background: #fee2e2 !important; color: #b91c1c !important; border: 1.5px solid #fca5a5 !important; border-radius: 7px !important; padding: 10px 16px !important; font-size: 12px !important; font-weight: 700 !important; cursor: pointer !important; text-transform: uppercase !important; width: 100% !important;" />
                            </div>
                        </div>
                    </asp:Panel>

                    <!-- =========================================================
                         MODE 2: RETURN & RENEWAL PROCEDURE
                         ========================================================= -->
                    <asp:Panel ID="pnlModeReturn" runat="server" Visible="false" style="width: 100% !important;" CssClass="circ-color-strip-return">
                        <!-- Sub Section Header -->
                        <div class="circ-sec-header" style="display: flex !important; align-items: center !important; gap: 10px !important; font-size: 13.5px !important; font-weight: 800 !important; color: #0f1e36 !important; text-transform: uppercase !important; letter-spacing: 0.65px !important; padding: 13px 18px !important; margin-bottom: 18px !important; background: #eff6ff !important; border: 1px solid #bfdbfe !important; border-left: 4px solid #2563eb !important; border-radius: 8px !important; box-shadow: 0 1px 3px rgba(0,0,0,0.04) !important;">
                            <span style="display: inline-block !important; width: 8px !important; height: 8px !important; border-radius: 50% !important; background: #2563eb !important; flex-shrink: 0 !important;"></span>
                            <span>Book Return & Renewal Counter</span>
                        </div>

                        <!-- Step 1: Member No & Book Entry Inputs -->
                        <div style="background: #f8fafc !important; border: 1px solid #e2e8f0 !important; border-radius: 10px !important; padding: 18px !important; margin-bottom: 18px !important; display: grid !important; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)) !important; gap: 14px !important; width: 100% !important; box-sizing: border-box !important;">
                            <div>
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Member No / Card:</span>
                                <div style="display: flex !important; gap: 6px !important;">
                                    <asp:TextBox ID="txtReturnMemberNo" runat="server" CssClass="circ-input-text" style="-webkit-appearance: none !important; appearance: none !important; border: 1.5px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 600 !important; color: #0f1e36 !important; background-color: #ffffff !important; width: 100% !important; height: 38px !important; box-sizing: border-box !important; outline: none !important;" AutoPostBack="true" OnTextChanged="txtReturnMemberNo_TextChanged" placeholder="Enter Member No" />
                                    <asp:Button ID="btnFetchReturnMember" runat="server" Text="Fetch" OnClick="btnFetchReturnMember_Click" CssClass="circ-btn-action" style="-webkit-appearance: none !important; appearance: none !important; background: linear-gradient(135deg, #0f1e36 0%, #1e3a8a 100%) !important; color: #ffffff !important; border: none !important; border-radius: 7px !important; padding: 0 20px !important; height: 38px !important; font-size: 12px !important; font-weight: 700 !important; cursor: pointer !important; text-transform: uppercase !important; letter-spacing: 0.5px !important; box-shadow: 0 3px 8px rgba(15, 30, 54, 0.2) !important; display: inline-flex !important; align-items: center !important; justify-content: center !important; outline: none !important;" />
                                </div>
                            </div>
                            <div>
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Book No / Barcode:</span>
                                <div style="display: flex !important; gap: 6px !important;">
                                    <asp:TextBox ID="txtReturnBookNo" runat="server" CssClass="circ-input-text" style="-webkit-appearance: none !important; appearance: none !important; border: 1.5px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 600 !important; color: #0f1e36 !important; background-color: #ffffff !important; width: 100% !important; height: 38px !important; box-sizing: border-box !important; outline: none !important;" AutoPostBack="true" OnTextChanged="txtReturnBookNo_TextChanged" placeholder="Enter Book No" />
                                    <asp:Button ID="btnFetchReturnBook" runat="server" Text="Fetch" OnClick="btnFetchReturnBook_Click" CssClass="circ-btn-action" style="-webkit-appearance: none !important; appearance: none !important; background: linear-gradient(135deg, #0f1e36 0%, #1e3a8a 100%) !important; color: #ffffff !important; border: none !important; border-radius: 7px !important; padding: 0 20px !important; height: 38px !important; font-size: 12px !important; font-weight: 700 !important; cursor: pointer !important; text-transform: uppercase !important; letter-spacing: 0.5px !important; box-shadow: 0 3px 8px rgba(15, 30, 54, 0.2) !important; display: inline-flex !important; align-items: center !important; justify-content: center !important; outline: none !important;" />
                                </div>
                            </div>
                            <div>
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Issue No:</span>
                                <asp:TextBox ID="txtReturnIssueNoVal" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 600 !important; color: #0f1e36 !important; background-color: #f8fafc !important; width: 100% !important; text-align: center !important; height: 38px !important; box-sizing: border-box !important;" />
                            </div>
                            <div>
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Issue Date:</span>
                                <asp:TextBox ID="txtReturnIssueDateVal" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 600 !important; color: #0f1e36 !important; background-color: #f8fafc !important; width: 100% !important; text-align: center !important; height: 38px !important; box-sizing: border-box !important;" />
                            </div>
                            <div>
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Due Date:</span>
                                <asp:TextBox ID="txtReturnDueDateVal" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 600 !important; color: #0f1e36 !important; background-color: #f8fafc !important; width: 100% !important; text-align: center !important; height: 38px !important; box-sizing: border-box !important;" />
                            </div>
                            <div style="grid-column: span 2 !important;">
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Book Title:</span>
                                <asp:TextBox ID="txtReturnBookTitleVal" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 700 !important; color: #0f1e36 !important; background-color: #f8fafc !important; width: 100% !important; height: 38px !important; box-sizing: border-box !important;" />
                            </div>
                            <div>
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Fine (Rs):</span>
                                <asp:TextBox ID="txtReturnFineVal" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #fca5a5 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; color: #b91c1c !important; font-weight: 800 !important; background-color: #fee2e2 !important; width: 100% !important; text-align: center !important; height: 38px !important; box-sizing: border-box !important;" Text="0" />
                            </div>
                            <div>
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Return Date:</span>
                                <asp:TextBox ID="txtReturnDateVal" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 600 !important; color: #0f1e36 !important; background-color: #f8fafc !important; width: 100% !important; text-align: center !important; height: 38px !important; box-sizing: border-box !important;" />
                            </div>
                            <div>
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Renewal:</span>
                                <asp:TextBox ID="txtReturnRenewalVal" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 600 !important; color: #0f1e36 !important; background-color: #f8fafc !important; width: 100% !important; text-align: center !important; height: 38px !important; box-sizing: border-box !important;" Text="0" />
                            </div>
                            <div>
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Days Late:</span>
                                <asp:TextBox ID="txtReturnDaysLateVal" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #fca5a5 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; color: #b91c1c !important; font-weight: 800 !important; background-color: #fee2e2 !important; width: 100% !important; text-align: center !important; height: 38px !important; box-sizing: border-box !important;" Text="0" />
                            </div>
                        </div>

                        <!-- Grid & Action Buttons Container -->
                        <div style="display: flex !important; gap: 18px !important; width: 100% !important;">
                            <div style="flex: 1 !important; overflow-x: auto !important;">
                                <asp:GridView ID="gvReturnLoansList" runat="server" AutoGenerateColumns="false" CssClass="circ-grid" style="width: 100% !important; border-collapse: collapse !important; font-size: 12.5px !important; background: #ffffff !important; border: 1px solid #cbd5e1 !important; border-radius: 8px !important; overflow: hidden !important;" EmptyDataText="Enter Member No or Book Number above to fetch loan details." OnRowCommand="gvReturnLoansList_RowCommand">
                                    <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="true" Height="38px" />
                                    <RowStyle Height="36px" BackColor="#ffffff" ForeColor="#1e293b" />
                                    <AlternatingRowStyle BackColor="#f8fafc" />
                                    <EmptyDataRowStyle ForeColor="#64748b" Font-Italic="true" />
                                    <Columns>
                                        <asp:BoundField DataField="BookNo" HeaderText="BookNo" HeaderStyle-Width="95px" ItemStyle-Font-Bold="true" />
                                        <asp:BoundField DataField="Title" HeaderText="Book Title" />
                                        <asp:BoundField DataField="IssueDate" HeaderText="Issue Date" DataFormatString="{0:dd/MM/yyyy}" HeaderStyle-Width="105px" ItemStyle-HorizontalAlign="Center" />
                                        <asp:BoundField DataField="DueDate" HeaderText="Due Date" DataFormatString="{0:dd/MM/yyyy}" HeaderStyle-Width="105px" ItemStyle-HorizontalAlign="Center" />
                                        <asp:BoundField DataField="FineAmount" HeaderText="Fine (Rs)" DataFormatString="{0:N0}" HeaderStyle-Width="85px" ItemStyle-HorizontalAlign="Right" ItemStyle-Font-Bold="true" ItemStyle-ForeColor="#b91c1c" />
                                        <asp:TemplateField HeaderText="Actions" HeaderStyle-Width="150px" ItemStyle-HorizontalAlign="Center">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="lnkRowReturn" runat="server" CommandName="ReturnRowLoan" CommandArgument='<%# Eval("CopyID") %>' Text="Return" style="color: #047857 !important; font-weight: 700 !important; text-decoration: none !important; margin-right: 6px !important; background: #d1fae5 !important; border: 1px solid #a7f3d0 !important; padding: 5px 11px !important; border-radius: 20px !important; font-size: 11px !important; text-transform: uppercase !important; display: inline-block !important;" />
                                                <asp:LinkButton ID="lnkRowRenew" runat="server" CommandName="RenewRowLoan" CommandArgument='<%# Eval("LoanID") %>' Text="Renew" style="color: #b45309 !important; font-weight: 700 !important; text-decoration: none !important; background: #fef3c7 !important; border: 1px solid #fde68a !important; padding: 5px 11px !important; border-radius: 20px !important; font-size: 11px !important; text-transform: uppercase !important; display: inline-block !important;" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>

                            <!-- Right Action Buttons -->
                            <div class="circ-side-btns" style="display: flex !important; flex-direction: column !important; gap: 10px !important; min-width: 135px !important;">
                                <asp:Button ID="btnReturnRefresh" runat="server" Text="Refresh" OnClick="btnReturnRefresh_Click" style="-webkit-appearance: none !important; appearance: none !important; background: #ffffff !important; color: #334155 !important; border: 1.5px solid #cbd5e1 !important; border-radius: 7px !important; padding: 10px 16px !important; font-size: 12px !important; font-weight: 700 !important; cursor: pointer !important; text-transform: uppercase !important; width: 100% !important; box-shadow: 0 1px 3px rgba(0,0,0,0.05) !important;" />
                                <asp:Button ID="btnReturnRecheck" runat="server" Text="Re Check" OnClick="btnReturnRecheck_Click" style="-webkit-appearance: none !important; appearance: none !important; background: #f8fafc !important; color: #0f1e36 !important; border: 1.5px solid #0f1e36 !important; border-radius: 7px !important; padding: 10px 16px !important; font-size: 12px !important; font-weight: 700 !important; cursor: pointer !important; text-transform: uppercase !important; width: 100% !important; box-shadow: 0 1px 3px rgba(0,0,0,0.05) !important;" />
                                <asp:Button ID="btnProcessReturn" runat="server" Text="Return" OnClick="btnProcessReturn_Click" CssClass="circ-btn-green" style="-webkit-appearance: none !important; appearance: none !important; background: linear-gradient(135deg, #16a34a 0%, #15803d 100%) !important; color: #ffffff !important; border: none !important; border-radius: 7px !important; padding: 11px 16px !important; font-size: 12.5px !important; font-weight: 800 !important; cursor: pointer !important; text-transform: uppercase !important; width: 100% !important; box-shadow: 0 4px 12px rgba(22, 163, 74, 0.35) !important;" />
                                <asp:Button ID="btnProcessRenew" runat="server" Text="Renewal" OnClick="btnProcessRenew_Click" CssClass="circ-btn-gold" style="-webkit-appearance: none !important; appearance: none !important; background: linear-gradient(135deg, #d97706 0%, #b45309 100%) !important; color: #ffffff !important; border: none !important; border-radius: 7px !important; padding: 11px 16px !important; font-size: 12.5px !important; font-weight: 800 !important; cursor: pointer !important; text-transform: uppercase !important; width: 100% !important; box-shadow: 0 4px 12px rgba(217, 119, 6, 0.35) !important;" UseSubmitBehavior="true" />
                            </div>
                        </div>
                    </asp:Panel>

                    <!-- =========================================================
                         MODE 3: RESERVATION PROCEDURE
                         ========================================================= -->
                    <asp:Panel ID="pnlModeReservation" runat="server" Visible="false" style="width: 100% !important;" CssClass="circ-color-strip-reserve">
                        <!-- Sub Section Header -->
                        <div class="circ-sec-header" style="display: flex !important; align-items: center !important; gap: 10px !important; font-size: 13.5px !important; font-weight: 800 !important; color: #0f1e36 !important; text-transform: uppercase !important; letter-spacing: 0.65px !important; padding: 13px 18px !important; margin-bottom: 18px !important; background: #fdf8f0 !important; border: 1px solid #eaddc7 !important; border-left: 4px solid #c5a059 !important; border-radius: 8px !important; box-shadow: 0 1px 3px rgba(0,0,0,0.04) !important;">
                            <span style="display: inline-block !important; width: 8px !important; height: 8px !important; border-radius: 50% !important; background: #c5a059 !important; flex-shrink: 0 !important;"></span>
                            <span>Book Reservation Management</span>
                        </div>

                        <!-- Step 2: Book Reservation Fields -->
                        <div style="background: #f8fafc !important; border: 1px solid #e2e8f0 !important; border-radius: 10px !important; padding: 18px !important; margin-bottom: 18px !important; display: grid !important; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)) !important; gap: 14px !important; width: 100% !important; box-sizing: border-box !important;">
                            <div>
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Reserve No:</span>
                                <asp:TextBox ID="txtResNoVal" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 800 !important; color: #0f1e36 !important; background-color: #f8fafc !important; width: 100% !important; text-align: center !important; height: 38px !important; box-sizing: border-box !important;" />
                            </div>
                            <div>
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Book No / Barcode:</span>
                                <div style="display: flex !important; gap: 6px !important;">
                                    <asp:TextBox ID="txtResBookNo" runat="server" CssClass="circ-input-text" style="-webkit-appearance: none !important; appearance: none !important; border: 1.5px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 600 !important; color: #0f1e36 !important; background-color: #ffffff !important; width: 100% !important; height: 38px !important; box-sizing: border-box !important; outline: none !important;" AutoPostBack="true" OnTextChanged="txtResBookNo_TextChanged" placeholder="Enter Book No" />
                                    <asp:Button ID="btnFetchResBook" runat="server" Text="Fetch" OnClick="btnFetchResBook_Click" CssClass="circ-btn-action" style="-webkit-appearance: none !important; appearance: none !important; background: linear-gradient(135deg, #0f1e36 0%, #1e3a8a 100%) !important; color: #ffffff !important; border: none !important; border-radius: 7px !important; padding: 0 20px !important; height: 38px !important; font-size: 12px !important; font-weight: 700 !important; cursor: pointer !important; text-transform: uppercase !important; letter-spacing: 0.5px !important; box-shadow: 0 3px 8px rgba(15, 30, 54, 0.2) !important; display: inline-flex !important; align-items: center !important; justify-content: center !important; outline: none !important;" />
                                </div>
                            </div>
                            <div>
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">DDC No:</span>
                                <asp:TextBox ID="txtResDDCVal" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 600 !important; color: #0f1e36 !important; background-color: #f8fafc !important; width: 100% !important; height: 38px !important; box-sizing: border-box !important;" />
                            </div>
                            <div style="grid-column: span 2 !important;">
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Book Title:</span>
                                <asp:TextBox ID="txtResBookTitleVal" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 700 !important; color: #0f1e36 !important; background-color: #f8fafc !important; width: 100% !important; height: 38px !important; box-sizing: border-box !important;" />
                            </div>
                            <div>
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Reserve Date:</span>
                                <asp:TextBox ID="txtResDateVal" runat="server" CssClass="circ-input-readonly" ReadOnly="true" style="border: 1.5px solid #d97706 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 800 !important; color: #92400e !important; background-color: #fef3c7 !important; width: 100% !important; text-align: center !important; height: 38px !important; box-sizing: border-box !important;" />
                            </div>
                            <div style="grid-column: span 2 !important;">
                                <span class="circ-label" style="font-size: 11px !important; font-weight: 700 !important; color: #475569 !important; text-transform: uppercase !important; display: block !important; margin-bottom: 5px !important; letter-spacing: 0.5px !important;">Remarks:</span>
                                <asp:TextBox ID="txtResRemarks" runat="server" CssClass="circ-input-text" style="-webkit-appearance: none !important; appearance: none !important; border: 1.5px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13.5px !important; font-weight: 600 !important; color: #0f1e36 !important; background-color: #ffffff !important; width: 100% !important; height: 38px !important; box-sizing: border-box !important; outline: none !important;" placeholder="Add reservation remarks..." />
                            </div>
                        </div>

                        <!-- Grid & Action Buttons Container -->
                        <div style="display: flex !important; gap: 18px !important; width: 100% !important;">
                            <div style="flex: 1 !important; overflow-x: auto !important;">
                                <asp:GridView ID="gvReservationsList" runat="server" AutoGenerateColumns="false" CssClass="circ-grid" style="width: 100% !important; border-collapse: collapse !important; font-size: 12.5px !important; background: #ffffff !important; border: 1px solid #cbd5e1 !important; border-radius: 8px !important; overflow: hidden !important;" EmptyDataText="No active reservations found for this member or book.">
                                    <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="true" Height="38px" />
                                    <RowStyle Height="36px" BackColor="#ffffff" ForeColor="#1e293b" />
                                    <AlternatingRowStyle BackColor="#f8fafc" />
                                    <EmptyDataRowStyle ForeColor="#64748b" Font-Italic="true" />
                                    <Columns>
                                        <asp:BoundField DataField="ReserveNo" HeaderText="Reserve No" HeaderStyle-Width="110px" ItemStyle-Font-Bold="true" />
                                        <asp:BoundField DataField="ReserveDate" HeaderText="Reserve Date" DataFormatString="{0:dd/MM/yyyy}" HeaderStyle-Width="120px" ItemStyle-HorizontalAlign="Center" />
                                        <asp:BoundField DataField="BookNo" HeaderText="Book No" HeaderStyle-Width="110px" ItemStyle-Font-Bold="true" />
                                        <asp:BoundField DataField="BookTitle" HeaderText="Book Title" />
                                        <asp:BoundField DataField="DDC" HeaderText="DDC" HeaderStyle-Width="130px" />
                                    </Columns>
                                </asp:GridView>
                            </div>

                            <!-- Right Action Buttons -->
                            <div class="circ-side-btns" style="display: flex !important; flex-direction: column !important; gap: 10px !important; min-width: 135px !important;">
                                <asp:Button ID="btnResRefresh" runat="server" Text="Refresh" OnClick="btnResRefresh_Click" style="-webkit-appearance: none !important; appearance: none !important; background: #ffffff !important; color: #334155 !important; border: 1.5px solid #cbd5e1 !important; border-radius: 7px !important; padding: 10px 16px !important; font-size: 12px !important; font-weight: 700 !important; cursor: pointer !important; text-transform: uppercase !important; width: 100% !important; box-shadow: 0 1px 3px rgba(0,0,0,0.05) !important;" />
                                <asp:Button ID="btnResNew" runat="server" Text="New" OnClick="btnResNew_Click" style="-webkit-appearance: none !important; appearance: none !important; background: #f8fafc !important; color: #0f1e36 !important; border: 1.5px solid #0f1e36 !important; border-radius: 7px !important; padding: 10px 16px !important; font-size: 12px !important; font-weight: 700 !important; cursor: pointer !important; text-transform: uppercase !important; width: 100% !important; box-shadow: 0 1px 3px rgba(0,0,0,0.05) !important;" />
                                <asp:Button ID="btnSaveReservation" runat="server" Text="Reserve" OnClick="btnSaveReservation_Click" CssClass="circ-btn-gold" style="-webkit-appearance: none !important; appearance: none !important; background: linear-gradient(135deg, #d97706 0%, #b45309 100%) !important; color: #ffffff !important; border: none !important; border-radius: 7px !important; padding: 11px 16px !important; font-size: 12.5px !important; font-weight: 800 !important; cursor: pointer !important; text-transform: uppercase !important; width: 100% !important; box-shadow: 0 4px 12px rgba(217, 119, 6, 0.35) !important;" />
                                <asp:Button ID="btnReleaseReservation" runat="server" Text="Release" OnClick="btnReleaseReservation_Click" style="-webkit-appearance: none !important; appearance: none !important; background: #fee2e2 !important; color: #b91c1c !important; border: 1.5px solid #fca5a5 !important; border-radius: 7px !important; padding: 10px 16px !important; font-size: 12px !important; font-weight: 700 !important; cursor: pointer !important; text-transform: uppercase !important; width: 100% !important;" />
                            </div>
                        </div>
                    </asp:Panel>
                </div>

                <!-- =========================================================
                     BOTTOM MEMBER REPORTING & QUICK PRINT MENU
                     ========================================================= -->
                <div class="circ-panel circ-color-strip-report" style="margin-bottom: 0 !important; background: #ffffff !important; border: 1.5px solid #cbd5e1 !important; border-left: 5px solid #0891b2 !important; border-radius: 12px !important; padding: 22px !important; width: 100% !important; box-sizing: border-box !important; box-shadow: 0 4px 14px rgba(0,0,0,0.04) !important;">
                    <!-- Section Header -->
                    <div class="circ-sec-header" style="display: flex !important; align-items: center !important; justify-content: space-between !important; font-size: 13.5px !important; font-weight: 800 !important; color: #0f1e36 !important; text-transform: uppercase !important; letter-spacing: 0.65px !important; padding: 13px 18px !important; margin-bottom: 20px !important; background: #ecfeff !important; border: 1px solid #a5f3fc !important; border-left: 4px solid #0891b2 !important; border-radius: 8px !important; box-shadow: 0 1px 3px rgba(0,0,0,0.04) !important;">
                        <div style="display: flex !important; align-items: center !important; gap: 10px !important;">
                            <span style="display: inline-block !important; width: 8px !important; height: 8px !important; border-radius: 50% !important; background: #0891b2 !important; flex-shrink: 0 !important;"></span>
                            <span>Member Circulation Reports & Quick Print</span>
                        </div>
                        <span style="font-size: 11px !important; color: #0e7490 !important; text-transform: none !important; font-weight: 700 !important; background: #ffffff !important; padding: 4px 10px !important; border-radius: 20px !important; border: 1px solid #a5f3fc !important;">Generate & Print Official Reports</span>
                    </div>

                    <!-- Filter / Action Toolbar -->
                    <div style="background: #f8fafc !important; border: 1px solid #e2e8f0 !important; border-radius: 10px !important; padding: 16px 20px !important; margin-bottom: 22px !important; display: flex !important; align-items: center !important; justify-content: space-between !important; flex-wrap: wrap !important; gap: 16px !important;">
                        <div style="display: flex !important; align-items: center !important; gap: 18px !important; flex-wrap: wrap !important;">
                            <div style="display: flex !important; align-items: center !important; gap: 8px !important;">
                                <span class="circ-label" style="margin: 0 !important; font-size: 11.5px !important; font-weight: 700 !important; color: #334155 !important; text-transform: uppercase !important; letter-spacing: 0.5px !important;">Select Report:</span>
                                <asp:DropDownList ID="ddlReportType" runat="server" CssClass="circ-input-text" style="-webkit-appearance: none !important; appearance: none !important; border: 1.5px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13px !important; font-weight: 600 !important; color: #0f1e36 !important; background-color: #ffffff !important; outline: none !important; height: 38px !important; min-width: 260px !important; box-sizing: border-box !important;">
                                    <asp:ListItem Value="LEDGER" Text="1. Member Transaction Ledger" Selected="True" />
                                    <asp:ListItem Value="ISSUANCE_SUMMARY" Text="2. Issuance Summary (Print)" />
                                    <asp:ListItem Value="OVERDUE_NOTICE" Text="3. Overdue Notice (Print)" />
                                    <asp:ListItem Value="RESERVATION_SLIP" Text="4. Reservation Slip (Print)" />
                                </asp:DropDownList>
                            </div>
                            <div style="display: flex !important; align-items: center !important; gap: 8px !important;">
                                <span class="circ-label" style="margin: 0 !important; font-size: 11.5px !important; font-weight: 700 !important; color: #334155 !important; text-transform: uppercase !important; letter-spacing: 0.5px !important;">As On Date:</span>
                                <asp:TextBox ID="txtReportAsOnDate" runat="server" CssClass="circ-input-text" style="-webkit-appearance: none !important; appearance: none !important; border: 1.5px solid #cbd5e1 !important; border-radius: 7px !important; padding: 8px 12px !important; font-size: 13px !important; font-weight: 700 !important; color: #0f1e36 !important; background-color: #ffffff !important; outline: none !important; height: 38px !important; width: 130px !important; text-align: center !important; box-sizing: border-box !important;" />
                            </div>
                        </div>
                        <div>
                            <asp:Button ID="btnPrintReporting" runat="server" Text="View / Print Report" OnClick="btnPrintReporting_Click" CssClass="circ-btn-action" style="-webkit-appearance: none !important; appearance: none !important; background: linear-gradient(135deg, #0891b2 0%, #0e7490 100%) !important; color: #ffffff !important; border: none !important; border-radius: 7px !important; padding: 0 24px !important; height: 38px !important; font-size: 12px !important; font-weight: 700 !important; cursor: pointer !important; text-transform: uppercase !important; letter-spacing: 0.5px !important; box-shadow: 0 3px 10px rgba(8, 145, 178, 0.3) !important; transition: all 0.2s ease-in-out !important; display: inline-flex !important; align-items: center !important; justify-content: center !important; outline: none !important;" />
                        </div>
                    </div>

                    <!-- Quick 1-Click Action Cards Grid -->
                    <div style="display: grid !important; grid-template-columns: repeat(auto-fit, minmax(210px, 1fr)) !important; gap: 16px !important; width: 100% !important; box-sizing: border-box !important;">
                        <!-- Card 1: Transaction Ledger -->
                        <div class="circ-report-card" style="background: #ffffff !important; border: 1.5px solid #cbd5e1 !important; border-top: 4px solid #0f1e36 !important; border-radius: 10px !important; padding: 16px 18px !important; display: flex !important; flex-direction: column !important; justify-content: space-between !important; gap: 14px !important; box-shadow: 0 2px 8px rgba(0,0,0,0.04) !important; transition: all 0.2s ease-in-out !important;">
                            <div>
                                <div style="font-size: 13.5px !important; font-weight: 800 !important; color: #0f1e36 !important; text-transform: uppercase !important; letter-spacing: 0.4px !important;">Transaction Ledger</div>
                                <div style="font-size: 11.5px !important; color: #64748b !important; margin-top: 4px !important; line-height: 1.4 !important;">Complete loan & fine history record for member</div>
                            </div>
                            <asp:Button ID="btnPrintLedgerQuick" runat="server" Text="Ledger" OnClick="btnPrintLedgerQuick_Click" style="-webkit-appearance: none !important; appearance: none !important; background: #0f1e36 !important; color: #ffffff !important; border: none !important; border-radius: 6px !important; padding: 9px 16px !important; font-size: 11.5px !important; font-weight: 800 !important; cursor: pointer !important; text-transform: uppercase !important; letter-spacing: 0.5px !important; box-shadow: 0 2px 6px rgba(15,30,54,0.2) !important; width: 100% !important; outline: none !important;" />
                        </div>

                        <!-- Card 2: Issuance Summary -->
                        <div class="circ-report-card" style="background: #ffffff !important; border: 1.5px solid #cbd5e1 !important; border-top: 4px solid #2563eb !important; border-radius: 10px !important; padding: 16px 18px !important; display: flex !important; flex-direction: column !important; justify-content: space-between !important; gap: 14px !important; box-shadow: 0 2px 8px rgba(0,0,0,0.04) !important; transition: all 0.2s ease-in-out !important;">
                            <div>
                                <div style="font-size: 13.5px !important; font-weight: 800 !important; color: #0f1e36 !important; text-transform: uppercase !important; letter-spacing: 0.4px !important;">Issuance Summary</div>
                                <div style="font-size: 11.5px !important; color: #64748b !important; margin-top: 4px !important; line-height: 1.4 !important;">Printable slip of currently issued books</div>
                            </div>
                            <asp:Button ID="btnPrintIssuanceQuick" runat="server" Text="Print" OnClick="btnPrintIssuanceQuick_Click" style="-webkit-appearance: none !important; appearance: none !important; background: #2563eb !important; color: #ffffff !important; border: none !important; border-radius: 6px !important; padding: 9px 16px !important; font-size: 11.5px !important; font-weight: 800 !important; cursor: pointer !important; text-transform: uppercase !important; letter-spacing: 0.5px !important; box-shadow: 0 2px 6px rgba(37,99,235,0.25) !important; width: 100% !important; outline: none !important;" />
                        </div>

                        <!-- Card 3: Overdue Notice -->
                        <div class="circ-report-card" style="background: #ffffff !important; border: 1.5px solid #cbd5e1 !important; border-top: 4px solid #dc2626 !important; border-radius: 10px !important; padding: 16px 18px !important; display: flex !important; flex-direction: column !important; justify-content: space-between !important; gap: 14px !important; box-shadow: 0 2px 8px rgba(0,0,0,0.04) !important; transition: all 0.2s ease-in-out !important;">
                            <div>
                                <div style="font-size: 13.5px !important; font-weight: 800 !important; color: #0f1e36 !important; text-transform: uppercase !important; letter-spacing: 0.4px !important;">Overdue Notice</div>
                                <div style="font-size: 11.5px !important; color: #dc2626 !important; font-weight: 600 !important; margin-top: 4px !important; line-height: 1.4 !important;">Official overdue notice & fine breakdown</div>
                            </div>
                            <asp:Button ID="btnPrintOverdueQuick" runat="server" Text="Notice" OnClick="btnPrintOverdueQuick_Click" style="-webkit-appearance: none !important; appearance: none !important; background: #dc2626 !important; color: #ffffff !important; border: none !important; border-radius: 6px !important; padding: 9px 16px !important; font-size: 11.5px !important; font-weight: 800 !important; cursor: pointer !important; text-transform: uppercase !important; letter-spacing: 0.5px !important; box-shadow: 0 2px 6px rgba(220,38,38,0.25) !important; width: 100% !important; outline: none !important;" />
                        </div>

                        <!-- Card 4: Reservation Slip -->
                        <div class="circ-report-card" style="background: #ffffff !important; border: 1.5px solid #cbd5e1 !important; border-top: 4px solid #d97706 !important; border-radius: 10px !important; padding: 16px 18px !important; display: flex !important; flex-direction: column !important; justify-content: space-between !important; gap: 14px !important; box-shadow: 0 2px 8px rgba(0,0,0,0.04) !important; transition: all 0.2s ease-in-out !important;">
                            <div>
                                <div style="font-size: 13.5px !important; font-weight: 800 !important; color: #0f1e36 !important; text-transform: uppercase !important; letter-spacing: 0.4px !important;">Reservation Slip</div>
                                <div style="font-size: 11.5px !important; color: #d97706 !important; font-weight: 600 !important; margin-top: 4px !important; line-height: 1.4 !important;">Active reservation note for hold counter</div>
                            </div>
                            <asp:Button ID="btnPrintReservationQuick" runat="server" Text="Slip" OnClick="btnPrintReservationQuick_Click" style="-webkit-appearance: none !important; appearance: none !important; background: linear-gradient(135deg, #d97706 0%, #b45309 100%) !important; color: #ffffff !important; border: none !important; border-radius: 6px !important; padding: 9px 16px !important; font-size: 11.5px !important; font-weight: 800 !important; cursor: pointer !important; text-transform: uppercase !important; letter-spacing: 0.5px !important; box-shadow: 0 2px 6px rgba(217,119,6,0.3) !important; width: 100% !important; outline: none !important;" />
                        </div>
                    </div>
                </div>

                <!-- Modal Reservation Alert Pop-up -->
                <asp:Panel ID="pnlReservationAlertModal" runat="server" Visible="false"
                    style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(15,23,42,0.7); z-index: 10000; display: flex; align-items: center; justify-content: center; backdrop-filter: blur(5px);">
                    <div style="background-color: #ffffff; border-radius: 20px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); max-width: 460px; width: 92%; padding: 32px 28px; text-align: center; border-top: 6px solid #d97706;">
                        <h3 style="font-size: 19px; font-weight: 800; color: #0f1e36; margin: 0 0 8px 0; text-transform: uppercase; letter-spacing: 0.6px;">Reservation Alert</h3>
                        <p style="font-size: 14.5px; color: #475569; margin: 0 0 12px 0; line-height: 1.5;">
                            This returned book is currently reserved for:<br />
                            <strong style="color: #0f1e36; font-size: 16px;"><asp:Label ID="lblReservedMemberName" runat="server" /></strong>
                        </p>
                        <p style="font-size: 13.5px; color: #64748b; margin: 0 0 24px 0;">
                            Would you like to print the Reservation Slip for this book?
                        </p>
                        <div style="display: flex; gap: 14px; justify-content: center;">
                            <asp:Button ID="btnPrintReservationSlipModal" runat="server" Text="Print Slip" OnClick="btnPrintReservationSlipModal_Click"
                                style="padding: 12px 28px; border-radius: 30px; border: none; background: linear-gradient(135deg, #d97706 0%, #b45309 100%); color: #ffffff; font-weight: 800; font-size: 13px; cursor: pointer; text-transform: uppercase; transition: all 0.2s; box-shadow: 0 4px 14px rgba(217, 119, 6, 0.35); outline: none;" />
                            <asp:Button ID="btnCloseReservationModal" runat="server" Text="Cancel" OnClick="btnCloseReservationModal_Click"
                                CssClass="circ-confirm-no" style="padding: 12px 28px; border-radius: 30px; border: 1.5px solid #cbd5e1; background: #ffffff; color: #475569; font-weight: 700; font-size: 13px; cursor: pointer; text-transform: uppercase; outline: none;" />
                        </div>
                    </div>
                </asp:Panel>

                <!-- ===== CONFIRMATION MODAL FOR RETURN/RENEW ===== -->
                <asp:Panel ID="pnlConfirmAction" runat="server" Visible="false" CssClass="circ-confirm-overlay" style="position: fixed !important; top: 0 !important; left: 0 !important; width: 100% !important; height: 100% !important; background-color: rgba(15, 23, 42, 0.7) !important; z-index: 10001 !important; display: flex !important; align-items: center !important; justify-content: center !important; backdrop-filter: blur(5px) !important;">
                    <div id="divConfirmBox" runat="server" class="circ-confirm-box confirm-return" style="background-color: #ffffff !important; border-radius: 20px !important; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25) !important; max-width: 450px !important; width: 92% !important; padding: 32px 28px !important; text-align: center !important; position: relative !important; border-top: 6px solid #16a34a !important;">
                        <div id="divConfirmIcon" runat="server" class="circ-confirm-icon icon-return" style="display: none !important;"></div>
                        <h3 class="circ-confirm-title" style="font-size: 18px !important; font-weight: 800 !important; color: #0f1e36 !important; margin: 0 0 8px 0 !important; text-transform: uppercase !important; letter-spacing: 0.6px !important;"><asp:Literal ID="litConfirmTitle" runat="server" Text="Confirm Return" /></h3>
                        <p class="circ-confirm-msg" style="font-size: 14px !important; color: #475569 !important; margin: 0 0 12px 0 !important; line-height: 1.5 !important;"><asp:Literal ID="litConfirmMsg" runat="server" /></p>
                        <div class="circ-confirm-detail" style="font-size: 13px !important; color: #334155 !important; margin: 0 0 24px 0 !important; background: #f8fafc !important; border: 1px solid #e2e8f0 !important; border-radius: 10px !important; padding: 12px 16px !important; text-align: left !important; line-height: 1.6 !important;">
                            <asp:Literal ID="litConfirmDetail" runat="server" />
                        </div>
                        <div class="circ-confirm-actions" style="display: flex !important; gap: 14px !important; justify-content: center !important;">
                            <asp:Button ID="btnConfirmYes" runat="server" Text="Yes, Return" OnClick="btnConfirmYes_Click" CssClass="circ-confirm-yes btn-return" style="-webkit-appearance: none !important; appearance: none !important; padding: 12px 28px !important; border-radius: 30px !important; border: none !important; font-family: 'Segoe UI', system-ui, -apple-system, sans-serif !important; font-weight: 800 !important; font-size: 13px !important; cursor: pointer !important; text-transform: uppercase !important; letter-spacing: 0.6px !important; outline: none !important; display: inline-flex !important; align-items: center !important; justify-content: center !important; background: linear-gradient(135deg, #16a34a 0%, #15803d 100%) !important; color: #ffffff !important; box-shadow: 0 4px 14px rgba(22, 163, 74, 0.35) !important;" />
                            <asp:Button ID="btnConfirmNo" runat="server" Text="Cancel" OnClick="btnConfirmNo_Click" CssClass="circ-confirm-no" style="-webkit-appearance: none !important; appearance: none !important; padding: 12px 28px !important; border-radius: 30px !important; border: 1.5px solid #cbd5e1 !important; background: #ffffff !important; color: #475569 !important; font-family: 'Segoe UI', system-ui, -apple-system, sans-serif !important; font-weight: 700 !important; font-size: 13px !important; cursor: pointer !important; text-transform: uppercase !important; letter-spacing: 0.5px !important; outline: none !important; box-shadow: 0 2px 6px rgba(0,0,0,0.04) !important; display: inline-flex !important; align-items: center !important; justify-content: center !important;" />
                        </div>
                    </div>
                </asp:Panel>

                <!-- Modal Report Preview & Auto-Print Overlay -->
                <asp:Panel ID="pnlReportModal" runat="server" Visible="false"
                    style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(15,23,42,0.75); z-index: 10000; display: flex; align-items: center; justify-content: center; backdrop-filter: blur(4px);">
                    <div style="background-color: #ffffff; border-radius: 12px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); max-width: 900px; width: 95%; max-height: 90vh; display: flex; flex-direction: column; overflow: hidden; border-top: 6px solid #c5a059;">
                        <!-- Modal Header Bar -->
                        <div style="padding: 14px 20px; background: #0f1e36; color: #ffffff; display: flex; justify-content: space-between; align-items: center;">
                            <h3 style="margin: 0; font-size: 15px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Member Report Preview</h3>
                            <div style="display: flex; gap: 10px;">
                                <button type="button" onclick="printReportModalContent();" style="padding: 8px 18px; border-radius: 6px; border: none; background: linear-gradient(135deg, #c5a059 0%, #d4af37 100%); color: #0f1e36; font-weight: 700; font-size: 12px; cursor: pointer; text-transform: uppercase; box-shadow: 0 2px 4px rgba(0,0,0,0.15);">
                                    Print Now
                                </button>
                                <asp:Button ID="btnCloseReportModal" runat="server" Text="Close" OnClick="btnCloseReportModal_Click" style="padding: 8px 16px; border-radius: 6px; border: 1px solid #cbd5e1; background: #ffffff; color: #0f1e36; font-weight: 700; font-size: 12px; cursor: pointer; text-transform: uppercase;" />
                            </div>
                        </div>
                        <!-- Modal Body Content -->
                        <div id="divReportModalPrintArea" style="padding: 24px; overflow-y: auto; flex: 1; background: #ffffff;">
                            <asp:Literal ID="litReportModalHtml" runat="server" />
                        </div>
                    </div>
                </asp:Panel>

                <script type="text/javascript">
                    function printReportModalContent() {
                        var elem = document.getElementById('divReportModalPrintArea');
                        if (!elem) return;
                        var content = elem.innerHTML;
                        var w = window.open('', '_blank', 'width=900,height=750,resizable=yes,scrollbars=yes');
                        if (w) {
                            w.document.open();
                            w.document.write('<html><head><title>Print Member Report</title><style>@page{size:auto;margin:15mm;}body{font-family:Arial,sans-serif;margin:0;padding:10px;color:#000;}</style></head><body>' + content + '</body></html>');
                            w.document.close();
                            w.focus();
                            setTimeout(function () { w.print(); }, 500);
                        }
                    }
                    // Auto-scroll to alert panel on postback
                    var prm = Sys.WebForms.PageRequestManager.getInstance();
                    prm.add_endRequest(function () {
                        var alertDiv = document.getElementById('<%= divAlert.ClientID %>');
                        if (alertDiv && alertDiv.offsetParent !== null) {
                            alertDiv.scrollIntoView({ behavior: 'smooth', block: 'center' });
                        }
                    });
                </script>

            </div>

            <asp:HiddenField ID="hfCircMode" runat="server" Value="ISSUE" />
            <asp:HiddenField ID="hfConfirmAction" runat="server" Value="" />
            <asp:HiddenField ID="hfConfirmCopyID" runat="server" Value="0" />
            <asp:HiddenField ID="hfConfirmLoanID" runat="server" Value="0" />
            <asp:Literal ID="litPrintSlipHtml" runat="server" />
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
