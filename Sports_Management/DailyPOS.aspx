<%@ Page Title="Daily POS" Language="C#" MasterPageFile="~/Sports_Management/SiteSports.Master" AutoEventWireup="true" CodeFile="DailyPOS.aspx.cs" Inherits="DailyPOS" %>
<%@ Register Src="~/Sports_Management/MemberSubscriptionInfo.ascx" TagPrefix="uc" TagName="MemberSubInfo" %>


<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.css" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.js"></script>
    <style>
        #toast-container > .toast-error {
            background-color: #bd2130 !important;
            color: #ffffff !important;
            font-size: 14px !important;
            font-weight: 600 !important;
            box-shadow: 0 4px 12px rgba(0,0,0,0.25) !important;
            border-left: 6px solid #721c24 !important;
        }
        #toast-container > .toast-success {
            background-color: #28a745 !important;
            color: #ffffff !important;
            font-size: 14px !important;
            font-weight: 600 !important;
            box-shadow: 0 4px 12px rgba(0,0,0,0.25) !important;
        }
        .custom-pos-toast {
            position: fixed;
            top: 25px;
            right: 25px;
            z-index: 999999;
            min-width: 320px;
            max-width: 520px;
            background: #dc3545;
            color: #fff;
            padding: 16px 20px;
            border-radius: 8px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.35);
            font-size: 14px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideInToast 0.4s ease-out forwards;
        }
        @keyframes slideInToast {
            from { transform: translateX(120%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
    </style>
    <script type="text/javascript">
        function showToastrMessage(msg, isError) {
            if (typeof toastr !== 'undefined') {
                toastr.options = {
                    "closeButton": true,
                    "progressBar": true,
                    "positionClass": "toast-top-right",
                    "timeOut": "9000",
                    "extendedTimeOut": "3000"
                };
                if (isError) {
                    toastr.error(msg, "Subscription Alert");
                } else {
                    toastr.success(msg, "Notification");
                }
            } else {
                showCustomToast(msg, isError ? 'error' : 'success');
            }
        }

        function showCustomToast(msg, type) {
            var existing = document.getElementById('customPosToast');
            if (existing) existing.remove();

            var toast = document.createElement('div');
            toast.id = 'customPosToast';
            toast.className = 'custom-pos-toast';
            if (type === 'success') toast.style.background = '#28a745';
            
            toast.innerHTML = '<i class="fas fa-exclamation-circle" style="font-size:22px;"></i> <span>' + msg + '</span>';
            document.body.appendChild(toast);

            setTimeout(function () {
                if (toast && toast.parentNode) {
                    toast.style.opacity = '0';
                    toast.style.transition = 'opacity 0.5s ease';
                    setTimeout(function () { toast.remove(); }, 500);
                }
            }, 9000);
        }
    </script>
    <style>
        /* =========================================================
           DAILY POS - FULL-WIDTH SINGLE UNIFIED CARD SYSTEM
           ========================================================= */
        :root {
            --pos-navy: #1e3a5f;
            --pos-navy-dark: #0f172a;
            --pos-navy-light: #2c4f7c;
            --pos-accent: #0284c7;
            --pos-accent-hover: #0369a1;
            --pos-bg-card: #ffffff;
            --pos-border: #e2e8f0;
            --pos-border-input: #cbd5e1;
            --pos-text: #1e293b;
            --pos-text-muted: #64748b;
            --pos-success: #16a34a;
            --pos-success-bg: #dcfce7;
            --pos-danger: #dc2626;
            --pos-gold: #d97706;
            --pos-gold-bg: #fffbeb;
            --field-h: 28px;
        }

        /* Full Page Width & Master Layout Overrides */
        .content-wrapper {
            padding: 3px 8px 6px 8px !important;
            width: 100% !important;
            max-width: 100% !important;
            overflow-y: auto !important;
            overflow-x: hidden !important;
            box-sizing: border-box !important;
        }
        .breadcrumb, .footer {
            display: none !important;
        }
        .main-content {
            overflow: auto !important;
        }

        /* Page Header - Ultra Compact Full Width */
        .page-header-card {
            background: linear-gradient(135deg, #1e3a5f 0%, #0f172a 100%) !important;
            border-radius: 4px !important;
            padding: 3px 10px !important;
            color: #ffffff !important;
            display: flex !important;
            justify-content: space-between !important;
            align-items: center !important;
            margin-bottom: 3px !important;
            box-shadow: 0 1px 4px rgba(15, 23, 42, 0.08) !important;
            border: none !important;
            width: 100% !important;
            height: 26px !important;
            box-sizing: border-box !important;
        }
        .page-header-card h2 {
            margin: 0 !important;
            font-size: 13px !important;
            font-weight: 800 !important;
            letter-spacing: 0.2px !important;
            display: flex !important;
            align-items: center !important;
            color: #ffffff !important;
            line-height: 1 !important;
        }
        .page-header-card .badge {
            background: rgba(255, 255, 255, 0.18) !important;
            backdrop-filter: blur(4px) !important;
            border: 1px solid rgba(255, 255, 255, 0.3) !important;
            padding: 2px 8px !important;
            border-radius: 10px !important;
            font-size: 10.5px !important;
            font-weight: 700 !important;
            color: #ffffff !important;
            line-height: 1 !important;
        }

        /* Top Navigation Tabs & Quick Verifier */
        .pos-tabs-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: nowrap;
            gap: 6px;
            margin-bottom: 3px;
            width: 100%;
            height: 25px;
        }
        .pos-tabs-group {
            display: flex;
            gap: 4px;
        }
        .pos-tab-btn {
            padding: 3px 12px;
            border-radius: 4px;
            font-weight: 700;
            font-size: 11.5px;
            border: 1px solid transparent;
            cursor: pointer;
            transition: all 0.15s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            height: 25px;
            box-sizing: border-box;
        }
        .pos-tab-active {
            background: #1e3a5f !important;
            color: #ffffff !important;
            box-shadow: 0 1px 3px rgba(30, 58, 95, 0.25);
        }
        .pos-tab-inactive {
            background: #ffffff !important;
            color: #475569 !important;
            border: 1px solid #cbd5e1 !important;
        }
        .pos-tab-inactive:hover {
            background: #f8fafc !important;
            color: #1e3a5f !important;
            border-color: #94a3b8 !important;
        }
        .quick-verifier-box {
            display: flex;
            align-items: center;
            gap: 5px;
            background: #ffffff;
            border: 1px solid #cbd5e1;
            padding: 1px 5px;
            border-radius: 4px;
            box-shadow: 0 1px 2px rgba(30, 58, 95, 0.04);
            height: 25px;
            box-sizing: border-box;
        }
        .quick-verifier-label {
            font-weight: 700;
            font-size: 10px;
            color: #1e3a5f;
            text-transform: uppercase;
            letter-spacing: 0.2px;
            white-space: nowrap;
        }

        /* =========================================================
           SINGLE UNIFIED POS MAIN CARD
           ========================================================= */
        .pos-main-card {
            width: 100% !important;
            max-width: 100% !important;
            background: #ffffff;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            box-shadow: 0 1px 4px rgba(15, 23, 42, 0.05);
            padding: 5px 8px 6px 8px;
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        /* Card Section Divider */
        .pos-card-section {
            width: 100%;
            padding-bottom: 4px;
            border-bottom: 1px solid #f1f5f9;
        }
        .pos-card-section:last-child {
            border-bottom: none;
            padding-bottom: 0;
        }

        /* Universal Field Sizing & Typography */
        .field-group {
            display: flex;
            flex-direction: column;
            min-width: 0;
            width: 100%;
        }
        .pos-field-label {
            font-size: 10px !important;
            font-weight: 700 !important;
            color: #475569 !important;
            text-transform: uppercase !important;
            letter-spacing: 0.2px !important;
            margin-bottom: 2px !important;
            display: block !important;
            line-height: 1.1 !important;
            white-space: nowrap !important;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        /* Standard Unified Form Input (Exact 28px Height Everywhere) */
        .form-control, .pos-input {
            height: var(--field-h) !important;
            min-height: var(--field-h) !important;
            max-height: var(--field-h) !important;
            padding: 2px 7px !important;
            font-size: 11.5px !important;
            font-weight: 600 !important;
            border-radius: 4px !important;
            border: 1px solid #cbd5e1 !important;
            background-color: #ffffff !important;
            color: #1e293b !important;
            transition: border-color 0.15s ease, box-shadow 0.15s ease;
            width: 100% !important;
            box-sizing: border-box !important;
        }
        .form-control:focus, .pos-input:focus {
            border-color: #0284c7 !important;
            outline: none;
            box-shadow: 0 0 0 2px rgba(2, 132, 199, 0.15) !important;
        }

        /* Search Input Group with Button */
        .input-with-btn {
            display: flex;
            align-items: stretch;
            width: 100%;
            height: var(--field-h);
        }
        .input-with-btn .pos-input {
            border-top-right-radius: 0 !important;
            border-bottom-right-radius: 0 !important;
            flex: 1;
        }
        .btn-search-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0 9px;
            height: var(--field-h);
            background: linear-gradient(135deg, #1e3a5f 0%, #0f172a 100%);
            color: #ffffff !important;
            border: 1px solid #1e3a5f;
            border-left: none;
            border-top-right-radius: 4px;
            border-bottom-right-radius: 4px;
            font-size: 11px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.15s ease;
            flex-shrink: 0;
        }
        .btn-search-icon:hover {
            background: linear-gradient(135deg, #2c4f7c 0%, #1e3a5f 100%);
            color: #ffffff !important;
        }

        /* Pill Radio Buttons (Customer Type & Payment) */
        .pos-pill-radios {
            display: flex;
            font-weight: 700;
            font-size: 11px;
        }
        .pos-pill-radios table {
            border-collapse: separate;
            border-spacing: 4px 0;
            margin: 0;
        }
        .pos-pill-radios td {
            padding: 2px 8px;
            border-radius: 4px;
            border: 1px solid #cbd5e1;
            background: #f8fafc;
            transition: all 0.15s ease-in-out;
            cursor: pointer;
            white-space: nowrap;
            height: 24px;
            line-height: 20px;
        }
        .pos-pill-radios td:hover {
            border-color: #94a3b8;
            background: #f1f5f9;
        }
        .pos-pill-radios td label {
            cursor: pointer;
            font-weight: 700;
            color: #475569;
            font-size: 11px;
            margin: 0;
            user-select: none;
            display: inline-flex;
            align-items: center;
            gap: 3px;
        }
        .pos-pill-radios input[type="radio"] {
            margin-right: 3px;
            cursor: pointer;
            accent-color: #0284c7;
            transform: scale(0.95);
        }
        .pos-pill-radios td:has(input:checked) {
            background: linear-gradient(135deg, #e0f2fe 0%, #bae6fd 100%);
            border-color: #0284c7;
            box-shadow: 0 1px 3px rgba(2, 132, 199, 0.15);
        }
        .pos-pill-radios td:has(input:checked) label {
            color: #0369a1 !important;
            font-weight: 800 !important;
        }

        /* Section 1: Customer Info Header Row */
        .customer-type-header-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 6px;
            flex-wrap: nowrap;
            margin-bottom: 4px;
            padding-bottom: 3px;
            border-bottom: 1px solid #f1f5f9;
        }
        .tr-info-badge-wrap {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-left: auto;
            background: #f8fafc;
            padding: 1px 6px;
            border-radius: 4px;
            border: 1px solid #e2e8f0;
            height: 26px;
        }
        .tr-field-item {
            display: flex;
            align-items: center;
            gap: 4px;
        }
        .tr-field-item label {
            font-weight: 800;
            font-size: 10px;
            color: #475569;
            white-space: nowrap;
            margin: 0;
            text-transform: uppercase;
            letter-spacing: 0.2px;
        }
        .tr-no-box {
            width: 120px !important;
            background: #f1f5f9 !important;
            text-align: center;
            font-weight: 800 !important;
            color: #1e3a5f !important;
            height: 22px !important;
            padding: 1px 4px !important;
            font-size: 11px !important;
        }

        /* Customer Fields Grid */
        .customer-fields-grid {
            display: grid;
            grid-template-columns: 210px 1.4fr 1.4fr 115px;
            gap: 8px;
            align-items: flex-end;
            width: 100%;
        }

        /* Direct Print Pill */
        .direct-print-toggle {
            height: var(--field-h);
            display: flex;
            align-items: center;
            justify-content: center;
            background: #f8fafc;
            border: 1px solid #cbd5e1;
            padding: 0 8px;
            border-radius: 4px;
            white-space: nowrap;
            transition: all 0.15s;
            box-sizing: border-box;
        }
        .direct-print-toggle:hover {
            background: #f1f5f9;
            border-color: #94a3b8;
        }
        .direct-print-toggle label {
            margin: 0;
            font-weight: 700;
            font-size: 11px;
            color: #1e3a5f;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .direct-print-toggle input[type="checkbox"] {
            transform: scale(1);
            cursor: pointer;
            accent-color: #0284c7;
        }

        /* Member Info Badge */
        .member-info-badge-card {
            background-color: #f8fafc;
            padding: 2px 8px;
            border-radius: 4px;
            border: 1px solid #e2e8f0;
            margin-top: 3px;
            display: flex;
            gap: 14px;
            font-size: 11px;
        }
        .member-info-badge-card .info-badge-item strong {
            color: #475569;
        }
        .member-info-badge-card .info-badge-item span {
            color: #1e3a5f;
            font-weight: 700;
            margin-left: 3px;
        }

        /* Section 2: Section Header Badges */
        .pos-section-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 1px 6px;
            font-size: 10px;
            font-weight: 800;
            color: #1e3a5f;
            background: #f8fafc;
            border: 1px solid #cbd5e1;
            border-radius: 3px;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            margin-bottom: 3px;
            line-height: 1.2;
        }

        /* Add Item Grid - Perfectly Aligned Columns */
        .add-items-grid {
            display: grid;
            grid-template-columns: 140px 130px 105px 1.8fr 85px 105px 85px 110px 95px;
            gap: 6px;
            align-items: flex-end;
            width: 100%;
        }
        .btn-add-grid {
            height: var(--field-h) !important;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 4px;
            padding: 0 10px;
            white-space: nowrap;
            border-radius: 4px;
            font-weight: 800;
            font-size: 11.5px;
            background: linear-gradient(135deg, #1e3a5f 0%, #0f172a 100%) !important;
            color: #ffffff !important;
            border: none !important;
            box-shadow: 0 1px 3px rgba(30, 58, 95, 0.25);
            transition: all 0.15s ease;
            cursor: pointer;
            text-decoration: none;
            width: 100%;
            box-sizing: border-box;
        }
        .btn-add-grid:hover {
            background: linear-gradient(135deg, #2c4f7c 0%, #1e3a5f 100%) !important;
            transform: translateY(-1px);
            box-shadow: 0 2px 5px rgba(30, 58, 95, 0.35);
            color: #ffffff !important;
        }

        /* Section 3: Cart Grid Table */
        .grid-table-container {
            border-radius: 4px;
            border: 1px solid #cbd5e1;
            margin-top: 2px;
            margin-bottom: 2px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.03);
            background: #ffffff;
            width: 100% !important;
            min-height: 130px;
            max-height: 260px;
            overflow-y: auto;
        }
        .pos-grid-table {
            border: none !important;
            margin-bottom: 0 !important;
            width: 100% !important;
        }
        .pos-grid-table th {
            background: #1e3a5f !important;
            color: #ffffff !important;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.2px;
            padding: 5px 8px !important;
            border: none !important;
            border-right: 1px solid rgba(255,255,255,0.12) !important;
            position: sticky;
            top: 0;
            z-index: 2;
        }
        .pos-grid-table th:last-child {
            border-right: none !important;
        }
        .pos-grid-table td {
            padding: 5px 8px !important;
            border: none !important;
            border-bottom: 1px solid #e2e8f0 !important;
            border-right: 1px solid #f1f5f9 !important;
            font-size: 11.5px;
            font-weight: 600;
            vertical-align: middle;
        }
        .pos-grid-table tr:nth-child(even) td {
            background-color: #fafcff;
        }
        .pos-grid-table tr:hover td {
            background-color: #f0f9ff;
        }
        .pos-grid-table .form-control-sm {
            height: 24px !important;
            padding: 1px 5px !important;
            font-size: 11.5px !important;
            border-radius: 3px;
            font-weight: 700;
            border: 1px solid #cbd5e1;
        }
        .pos-grid-table .form-control-sm:focus {
            border-color: #0284c7;
            outline: none;
        }

        /* Live Totals Summary Bar */
        .grid-totals-bar {
            background: #f8fafc;
            border-top: 1px solid #cbd5e1;
            padding: 2px 10px;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 16px;
            font-size: 11.5px;
            position: sticky;
            bottom: 0;
            z-index: 2;
        }
        .grid-totals-bar .total-item {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .grid-totals-bar .total-item .lbl {
            font-weight: 700;
            color: #64748b;
            text-transform: uppercase;
            font-size: 10px;
            letter-spacing: 0.2px;
        }
        .grid-totals-bar .total-item .val {
            color: #1e3a5f;
            font-weight: 800;
            font-size: 12px;
        }
        .grid-totals-bar .total-item.net-item {
            background: #dcfce7;
            padding: 1px 6px;
            border-radius: 3px;
            border: 1px solid #86efac;
        }
        .grid-totals-bar .total-item.net-item .lbl {
            color: #15803d;
            font-weight: 800;
        }
        .grid-totals-bar .total-item.net-item .val {
            color: #15803d;
            font-size: 13px;
            font-weight: 900;
        }

        /* Section 4: Settlement & Actions */
        .settlement-bottom-grid {
            display: grid;
            grid-template-columns: 1fr 125px;
            gap: 6px;
            align-items: stretch;
            width: 100% !important;
        }
        .settlement-fields-area {
            display: flex;
            flex-direction: column;
            gap: 4px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 5px;
            padding: 4px 8px;
        }
        .settlement-mode-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: nowrap;
            gap: 4px;
            padding-bottom: 3px;
            border-bottom: 1px solid #e2e8f0;
        }
        .payment-mode-label {
            font-size: 10px;
            font-weight: 800;
            color: #1e3a5f;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            white-space: nowrap;
            display: inline-flex;
            align-items: center;
            gap: 3px;
        }

        /* Settlement Inputs Grid - Uniform Grid */
        .settlement-inputs-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
            gap: 4px 8px;
            align-items: flex-end;
            width: 100%;
        }

        /* Net Payable Highlight Input */
        .payable-badge-input {
            display: flex;
            align-items: stretch;
            background: #f0fdf4;
            border: 1.5px solid #86efac;
            border-radius: 4px;
            overflow: hidden;
            height: var(--field-h);
            box-sizing: border-box;
        }
        .payable-badge-input .currency-prefix {
            display: flex;
            align-items: center;
            padding: 0 5px;
            background: #dcfce7;
            color: #15803d;
            font-weight: 800;
            font-size: 10px;
            letter-spacing: 0.3px;
            border-right: 1px solid #86efac;
        }
        .payable-badge-input .net-payable-val {
            border: none !important;
            background: transparent !important;
            font-size: 13px !important;
            font-weight: 800 !important;
            color: #15803d !important;
            text-align: right;
            box-shadow: none !important;
            height: 100% !important;
            padding-right: 6px !important;
        }

        .text-danger-bold {
            color: #dc2626 !important;
            font-weight: 800 !important;
            text-align: right;
        }
        .text-success-bold {
            color: #15803d !important;
            font-weight: 800 !important;
            text-align: right;
        }
        .text-right {
            text-align: right !important;
        }
        .font-bold {
            font-weight: 700 !important;
        }

        /* Card Offer Info Banner */
        .settlement-offer-full {
            width: 100%;
        }
        .card-offer-banner {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
            gap: 3px 6px;
            font-size: 10px;
            color: #0369a1;
            background: #f0f9ff;
            border: 1px solid #bae6fd;
            border-radius: 4px;
            padding: 3px 6px;
            margin-top: 2px;
        }

        /* Actions Sidebar */
        .pos-actions-sidebar {
            display: flex;
            flex-direction: column;
            gap: 4px;
            justify-content: stretch;
        }
        .btn-action-side {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 2px;
            padding: 4px 4px;
            border-radius: 4px;
            font-weight: 800;
            font-size: 10.5px;
            text-decoration: none;
            text-align: center;
            border: none;
            cursor: pointer;
            transition: all 0.15s ease;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
        }
        .btn-action-side i {
            font-size: 12px;
        }
        .btn-action-secondary {
            background: #ffffff;
            color: #475569;
            border: 1px solid #cbd5e1;
            flex: 1;
        }
        .btn-action-secondary:hover {
            background: #f8fafc;
            color: #1e3a5f;
            border-color: #94a3b8;
            transform: translateY(-1px);
        }
        .btn-action-navy {
            background: linear-gradient(135deg, #1e3a5f 0%, #0f172a 100%);
            color: #ffffff;
            flex: 1;
        }
        .btn-action-navy:hover {
            background: linear-gradient(135deg, #2c4f7c 0%, #1e3a5f 100%);
            color: #ffffff;
            transform: translateY(-1px);
        }
        .btn-action-primary {
            background: linear-gradient(135deg, #16a34a 0%, #15803d 100%);
            color: #ffffff;
            flex: 1.2;
            font-size: 11px;
            box-shadow: 0 2px 6px rgba(22, 163, 74, 0.25);
        }
        .btn-action-primary:hover {
            background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
            color: #ffffff;
            transform: translateY(-1px);
        }

        /* Buttons & Utility */
        .btn-navy {
            background: linear-gradient(135deg, #1e3a5f 0%, #162d4a 100%) !important;
            color: #ffffff !important;
            border: none !important;
            font-weight: 700 !important;
            border-radius: 4px;
            box-shadow: 0 1px 3px rgba(30, 58, 95, 0.2);
            transition: all 0.15s;
        }
        .btn-navy:hover {
            background: linear-gradient(135deg, #162d4a 0%, #0f172a 100%) !important;
            color: #ffffff !important;
            transform: translateY(-1px);
        }

        .form-control-sm {
            height: 22px !important;
            padding: 1px 5px !important;
            font-size: 11px !important;
            border-radius: 3px;
            border: 1px solid #cbd5e1;
            box-sizing: border-box;
        }

        /* Modal Overlay */
        .pos-modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(15, 23, 42, 0.7);
            backdrop-filter: blur(4px);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 99999;
        }
        .pos-modal-box {
            background: #ffffff;
            border-radius: 8px;
            box-shadow: 0 20px 40px -12px rgba(0, 0, 0, 0.4);
            width: 92%;
            max-width: 440px;
            overflow: hidden;
            border: 1px solid #cbd5e1;
            animation: modalPopIn 0.2s ease-out;
        }
        @keyframes modalPopIn {
            from { opacity: 0; transform: scale(0.96) translateY(-6px); }
            to { opacity: 1; transform: scale(1) translateY(0); }
        }

        /* Print Receipt Styling */
        @media print {
            body * { visibility: hidden; }
            .receipt-area, .receipt-area * { visibility: visible; }
            .receipt-area { position: absolute; left: 0; top: 0; width: 100%; margin: 0; padding: 0; }
            .no-print { display: none !important; }
        }
        .receipt-card {
            background: white;
            border: 1px dashed var(--gray-400);
            border-radius: 8px;
            padding: 20px;
            max-width: 380px;
            margin: 0 auto;
            box-shadow: 0 2px 4px rgba(0,0,0,0.08);
        }
        .receipt-header {
            display: flex;
            align-items: center;
            gap: 10px;
            border-bottom: 2px solid #ddd;
            padding-bottom: 6px;
            margin-top: 4px;
        }
        .receipt-header img { width: 45px; height: auto; margin: 0; }
        .receipt-text h3 { margin: 0; font-size: 15px; font-weight: 800; }
        .receipt-text p { margin: 2px 0 0 0; font-size: 10.5px; }
        .receipt-row { display: flex; justify-content: space-between; margin-bottom: 5px; font-size: 11.5px; }
        .receipt-row .label { color: var(--gray-600); font-weight: 600; }
        .receipt-row .value { color: var(--gray-900); font-weight: 700; text-align: right; }
        .receipt-divider { border-top: 1px dashed var(--gray-300); margin: 8px 0; }
        .receipt-total { font-size: 15px; font-weight: 800; color: var(--primary-dark); }
        .receipt-footer { text-align: center; margin-top: 12px; font-size: 10px; color: var(--gray-500); font-style: italic; }
        
        .history-grid {
            width: 100%;
            border-collapse: collapse;
            font-size: 11.5px;
            background: white;
        }
        .history-grid th {
            background: #1e3a5f;
            color: #ffffff;
            padding: 5px 8px;
            font-size: 10.5px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        .history-grid td {
            padding: 4px 6px;
            border-bottom: 1px solid #e2e8f0;
            color: #334155;
        }

        /* Select2 Dropdown Matching Uniform 28px Height */
        .select2-container {
            width: 100% !important;
        }
        .select2-container--default .select2-selection--single {
            height: var(--field-h) !important;
            border: 1px solid #cbd5e1 !important;
            border-radius: 4px !important;
            display: flex !important;
            align-items: center !important;
            background-color: #ffffff !important;
            box-sizing: border-box !important;
        }
        .select2-container--default .select2-selection--single .select2-selection__rendered {
            line-height: 26px !important;
            color: #1e293b !important;
            font-size: 11.5px !important;
            font-weight: 600 !important;
            padding-left: 6px !important;
            padding-right: 18px !important;
        }
        .select2-container--default .select2-selection--single .select2-selection__arrow {
            height: 26px !important;
            right: 4px !important;
        }
        .select2-container--default.select2-container--focus .select2-selection--single {
            border-color: #0284c7 !important;
            box-shadow: 0 0 0 2px rgba(2, 132, 199, 0.15) !important;
        }
    </style>

    <!-- jQuery and Select2 for searchable dropdown (Item Code & Package Name Search) -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    
    <script type="text/javascript">
        $(document).ready(function() {
            initSelect2();
            scrollCartToBottom();
        });
        function initSelect2() {
            if ($('#<%= ddlDailyPackages.ClientID %>').length) {
                $('#<%= ddlDailyPackages.ClientID %>').select2({
                    placeholder: 'Search by Item Code or Package Name...',
                    allowClear: true,
                    width: '100%'
                });
            }
        }
        function scrollCartToBottom() {
            var container = document.querySelector('.grid-table-container');
            if (container && container.scrollHeight > container.clientHeight) {
                container.scrollTop = container.scrollHeight;
            }
        }
        if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            if (prm) {
                prm.add_endRequest(function () {
                    initSelect2();
                    scrollCartToBottom();
                });
            }
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="page-header-card no-print">
        <h2><i class="fas fa-cash-register" style="margin-right:8px;"></i> POS</h2>
        <span class="badge" style="background:#1e3a5f; color:#fff;">Lahore Gymkhana</span>
    </div>

    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert no-print" style="display:block; margin-bottom: 4px; padding: 4px 12px; border-radius: 4px; font-weight: 700; font-size: 11.5px;"></asp:Label>

    <!-- ===== EXPIRED SUBSCRIPTION ALERT MODAL ===== -->
    <div id="expiredSubOverlay" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.72); z-index:999999; justify-content:center; align-items:center;">
        <div style="background:#fff; border-radius:14px; max-width:580px; width:96%; box-shadow:0 24px 64px rgba(0,0,0,0.45); overflow:hidden; animation:expiredModalIn 0.35s cubic-bezier(.175,.885,.32,1.275) forwards;">
            <!-- Header -->
            <div style="background:linear-gradient(135deg,#b91c1c,#dc2626); padding:20px 24px; display:flex; align-items:center; gap:14px;">
                <div style="background:rgba(255,255,255,0.18); border-radius:50%; width:48px; height:48px; display:flex; align-items:center; justify-content:center; flex-shrink:0;">
                    <span style="color:#fff; font-size:24px; font-weight:900;">&#9888;</span>
                </div>
                <div>
                    <div id="modalAlertTitle" style="color:#fff; font-size:16px; font-weight:800; letter-spacing:0.3px;">ALERT</div>
                    <div id="expiredSubType" style="color:#fecaca; font-size:12px; font-weight:600; margin-top:2px;"></div>
                </div>
            </div>
            <!-- Body -->
            <div style="padding:22px 24px; max-height:70vh; overflow-y:auto;">
                <!-- Member Name Banner -->
                <div style="background:#fef2f2; border:1.5px solid #fca5a5; border-radius:8px; padding:14px 16px; margin-bottom:14px;">
                    <div id="expiredSubMemberName" style="color:#991b1b; font-size:15px; font-weight:800; margin-bottom:6px;"></div>
                    <div id="modalSubtitleMsg" style="color:#b91c1c; font-size:13px; font-weight:600;">
                        &#9201;&nbsp; Please review the details below.
                    </div>
                </div>

                <!-- Expired Subscriptions List -->
                <div id="expiredSubListContainer" style="display:none; margin-bottom:16px;">
                    <div style="font-weight:700; font-size:13px; color:#374151; margin-bottom:8px;">
                        &#9635;&nbsp; Expired Subscriptions:
                    </div>
                    <div id="expiredSubList" style="border:1.5px solid #fca5a5; border-radius:6px; overflow:hidden;">
                        <!-- rows injected by JS -->
                    </div>
                </div>

                <!-- Info note: new slip ALLOWED (shown for member expired subs) -->
                <div id="slipAllowedBanner" style="background:#fffbeb; border:1.5px solid #fcd34d; border-radius:8px; padding:10px 14px; margin-bottom:16px; display:flex; align-items:center; gap:10px;">
                    <span style="color:#d97706; font-size:20px; flex-shrink:0;">&#9432;</span>
                    <span style="font-size:13px; font-weight:600; color:#92400e;">
                        You can still generate a new slip. Please Acknowledge and proceed.
                    </span>
                </div>
                <!-- BLOCKED banner: shown for checked-out guest / expired affiliated card -->
                <div id="slipBlockedBanner" style="display:none; background:#fef2f2; border:2px solid #dc2626; border-radius:8px; padding:12px 14px; margin-bottom:16px; align-items:center; gap:10px;">
                    <span style="color:#dc2626; font-size:22px; flex-shrink:0;">&#128683;</span>
                    <div>
                        <div style="font-size:14px; font-weight:800; color:#991b1b;">Slip Generation BLOCKED</div>
                        <div style="font-size:12px; font-weight:600; color:#b91c1c; margin-top:2px;">This transaction cannot be processed. Please remove Face ID and do not allow entry.</div>
                    </div>
                </div>

                <label style="display:block; font-weight:700; font-size:13px; color:#374151; margin-bottom:6px;">
                    &#9998;&nbsp; Remarks <span style="color:#dc2626;">*</span> <span style="font-weight:400; color:#6b7280;">(required to close this alert)</span>
                </label>
                <textarea id="expiredSubRemarks" rows="3"
                    placeholder="Enter your remarks before closing this alert..."
                    style="width:100%; padding:10px 12px; border:2px solid #fca5a5; border-radius:6px; font-size:13px; font-family:inherit; resize:vertical; outline:none; transition:border-color 0.2s;"
                    onfocus="this.style.borderColor='#dc2626';" onblur="this.style.borderColor='#fca5a5';"></textarea>
                <div id="expiredSubRemarksError" style="display:none; color:#dc2626; font-size:12px; font-weight:600; margin-top:4px;">
                    &#9432; Remarks are required to close this alert.
                </div>
            </div>
            <!-- Footer -->
            <div style="padding:14px 24px 22px 24px; display:flex; justify-content:flex-end; border-top:1px solid #fee2e2;">
                <button type="button" id="btnAcknowledgeExpired"
                    onclick="acknowledgeExpiredAlert();"
                    style="background:linear-gradient(135deg,#b91c1c,#dc2626); color:#fff; border:none; border-radius:8px; padding:12px 28px; font-size:14px; font-weight:700; cursor:pointer; display:flex; align-items:center; gap:8px; transition:opacity 0.2s;"
                    onmouseover="this.style.opacity='0.88';" onmouseout="this.style.opacity='1';">
                    <span style="font-size:18px;">&#10003;</span> Acknowledge &amp; Generate New Slip
                </button>
            </div>
        </div>
    </div>

    <style>
        @keyframes expiredModalIn {
            from { transform: scale(0.80) translateY(-30px); opacity: 0; }
            to   { transform: scale(1)    translateY(0);     opacity: 1; }
        }
    </style>

    <script type="text/javascript">
        // expiredSubs: array of {name, endDate} objects
        // blockSlip: true = slip is BLOCKED (checked-out guest / expired affiliated card)
        function showExpiredSubscriptionAlert(memberName, memberType, expiredSubs, blockSlip) {
            document.getElementById('expiredSubMemberName').textContent = memberName || 'Unknown Member';
            document.getElementById('expiredSubType').textContent = 'Category: ' + (memberType || '');
            document.getElementById('expiredSubRemarks').value = '';
            document.getElementById('expiredSubRemarksError').style.display = 'none';

            // --- Dynamic title and subtitle based on type ---
            var titleEl    = document.getElementById('modalAlertTitle');
            var subtitleEl = document.getElementById('modalSubtitleMsg');

            var col1Label = 'Status / Details';
            var col2Label = 'Info';

            if (memberType === 'Guest Room') {
                titleEl.textContent    = 'ROOM STATUS ALERT';
                subtitleEl.innerHTML   = '&#9201;&nbsp; This room is <strong>Checked Out or Vacant</strong>. Please contact the relevant department.';
                col1Label = 'Room Status'; col2Label = 'Action Required';
            } else if (memberType === 'Affiliated Member') {
                titleEl.textContent    = 'INTRO CARD ALERT';
                subtitleEl.innerHTML   = '&#9201;&nbsp; Affiliated member\'s <strong>Introductory Card has EXPIRED</strong>. Slip generation is not allowed.';
                col1Label = 'Card Details'; col2Label = 'Status';
            } else {
                titleEl.textContent    = 'EXPIRED SUBSCRIPTION ALERT';
                subtitleEl.innerHTML   = '&#9201;&nbsp; The following subscriptions have <strong>EXPIRED</strong>. Please remove Face ID from the machine.';
                col1Label = 'Subscription / Package'; col2Label = 'Expired On';
            }

            // Store block flag in a data attribute on the button
            var btn = document.getElementById('btnAcknowledgeExpired');
            btn.setAttribute('data-block-slip', blockSlip ? '1' : '0');

            if (blockSlip) {
                btn.innerHTML = '<span style="font-size:16px;">&#128683;</span>&nbsp; Slip Blocked &mdash; Acknowledge &amp; Close';
                btn.style.background = 'linear-gradient(135deg,#7f1d1d,#991b1b)';
                document.getElementById('slipBlockedBanner').style.display = 'flex';
                document.getElementById('slipAllowedBanner').style.display = 'none';
            } else {
                btn.innerHTML = '<span style="font-size:18px;">&#10003;</span> Acknowledge &amp; Generate New Slip';
                btn.style.background = 'linear-gradient(135deg,#b91c1c,#dc2626)';
                document.getElementById('slipBlockedBanner').style.display = 'none';
                document.getElementById('slipAllowedBanner').style.display = 'flex';
            }

            // Populate list
            var listContainer = document.getElementById('expiredSubListContainer');
            var listDiv = document.getElementById('expiredSubList');
            listDiv.innerHTML = '';

            if (expiredSubs && expiredSubs.length > 0) {
                var hdr = '<div style="display:flex; background:#991b1b; color:#fff; font-size:12px; font-weight:700; padding:8px 12px;">' +
                    '<div style="flex:1;">' + col1Label + '</div>' +
                    '<div style="width:160px; text-align:right;">' + col2Label + '</div>' +
                    '</div>';
                listDiv.innerHTML = hdr;

                for (var i = 0; i < expiredSubs.length; i++) {
                    var s = expiredSubs[i];
                    var bg = (i % 2 === 0) ? '#fff5f5' : '#fff';
                    var row = '<div style="display:flex; align-items:center; background:' + bg + '; padding:9px 12px; border-top:1px solid #fca5a5;">' +
                        '<div style="flex:1; font-size:13px; font-weight:600; color:#374151;">' +
                        '<span style="color:#dc2626; margin-right:6px; font-size:13px;">&#10005;</span>' +
                        escHtml(s.name) + '</div>' +
                        '<div style="width:110px; text-align:right; font-size:12px; font-weight:700; color:#b91c1c;">' + escHtml(s.endDate) + '</div>' +
                        '</div>';
                    listDiv.innerHTML += row;
                }
                listContainer.style.display = 'block';
            } else {
                listContainer.style.display = 'none';
            }

            var overlay = document.getElementById('expiredSubOverlay');
            overlay.style.display = 'flex';
            document.body.style.overflow = 'hidden';
            setTimeout(function () {
                var ta = document.getElementById('expiredSubRemarks');
                if (ta) ta.focus();
            }, 350);
        }

        function escHtml(str) {
            if (!str) return '';
            return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
        }

        function acknowledgeExpiredAlert() {
            var remarks = document.getElementById('expiredSubRemarks').value.trim();
            if (!remarks) {
                document.getElementById('expiredSubRemarksError').style.display = 'block';
                document.getElementById('expiredSubRemarks').focus();
                return;
            }
            var btn = document.getElementById('btnAcknowledgeExpired');
            var isBlocked = btn.getAttribute('data-block-slip') === '1';

            if (!isBlocked) {
                // Copy remarks into the main POS Remarks field only when allowed
                var remarksField = document.getElementById('<%= txtPayDesc.ClientID %>');
                if (remarksField) remarksField.value = remarks;
            }
            // Hide modal
            document.getElementById('expiredSubOverlay').style.display = 'none';
            document.body.style.overflow = '';

            if (isBlocked) {
                // Disable the Save & Print button so user cannot proceed
                var generateBtn = document.getElementById('<%= btnGenerateReceipt.ClientID %>');
                if (generateBtn) {
                    generateBtn.disabled = true;
                    generateBtn.style.opacity = '0.4';
                    generateBtn.style.cursor = 'not-allowed';
                    generateBtn.title = 'Slip blocked: Guest checked out / Affiliated card expired';
                }
            }
        }

        // Prevent closing by pressing Escape
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') {
                var overlay = document.getElementById('expiredSubOverlay');
                if (overlay && overlay.style.display === 'flex') {
                    e.preventDefault();
                    e.stopPropagation();
                    document.getElementById('expiredSubRemarks').focus();
                }
            }
        });
    </script>

    <div class="pos-tabs-row no-print">
        <div class="pos-tabs-group">
            <asp:Button ID="btnTabNew" runat="server" Text="New Receipt" CssClass="pos-tab-btn pos-tab-active" OnClick="btnTabNew_Click" CausesValidation="false" />
            <asp:Button ID="btnTabHistory" runat="server" Text="Receipt History" CssClass="pos-tab-btn pos-tab-inactive" OnClick="btnTabHistory_Click" CausesValidation="false" />
        </div>

        <!-- Quick Manual Slip Verifier Tool -->
        <div class="quick-verifier-box">
            <i class="fas fa-barcode" style="color:#0284c7; font-size:14px;"></i>
            <span class="quick-verifier-label">Verify Manual Slip:</span>
            <asp:TextBox ID="txtQuickVerifySlip" runat="server" CssClass="form-control pos-input" placeholder="Enter Slip / Reg #" style="height:22px !important; width:150px; font-size:11.5px; font-weight:700; padding:1px 6px; border-color:#0284c7;"></asp:TextBox>
            <asp:LinkButton ID="btnQuickVerifySlip" runat="server" CssClass="btn btn-navy" OnClick="btnQuickVerifySlip_Click" CausesValidation="false" style="height:22px; padding:0 8px; font-size:11px; font-weight:700; display:inline-flex; align-items:center; gap:4px;"><i class="fas fa-search"></i> Verify</asp:LinkButton>
        </div>
    </div>

    <!-- Manual Slip Verification Result Banner -->
    <asp:Panel ID="pnlSlipVerificationResult" runat="server" Visible="false" CssClass="no-print" style="margin-bottom:4px;">
        <div id="divSlipResultCard" runat="server" style="border-radius:5px; padding:5px 10px; display:flex; justify-content:space-between; align-items:center; box-shadow:0 1px 3px rgba(0,0,0,0.05); font-size:11.5px;">
            <div style="display:flex; align-items:center; gap:8px;">
                <i id="iconSlipResult" runat="server" class="fas fa-info-circle" style="font-size:16px;"></i>
                <div>
                    <div id="divSlipResultTitle" runat="server" style="font-weight:800; font-size:12px;"></div>
                    <div id="divSlipResultDetails" runat="server" style="font-size:11px; margin-top:1px;"></div>
                </div>
            </div>
            <asp:LinkButton ID="btnCloseSlipResult" runat="server" OnClick="btnCloseSlipResult_Click" CausesValidation="false" style="background:transparent; border:none; font-size:16px; font-weight:bold; cursor:pointer; color:inherit; opacity:0.75; text-decoration:none; padding:0 4px;">&times;</asp:LinkButton>
        </div>
    </asp:Panel>

    <asp:MultiView ID="mvDailyPOS" runat="server" ActiveViewIndex="0">
        <asp:View ID="vwNewReceipt" runat="server">

            <asp:Panel ID="pnlPOSForm" runat="server" CssClass="no-print">
                <asp:Label ID="lblCustomerHeader" runat="server" Visible="false"></asp:Label>

                <!-- =========================================================
                     SINGLE UNIFIED POS MAIN CARD
                     ========================================================= -->
                <div class="pos-main-card">
                    
                    <!-- Section 1: Customer & Transaction Configuration -->
                    <div class="pos-card-section">
                        <!-- Top Row: Radio list on left, Tr info on right -->
                        <div class="customer-type-header-row">
                            <div class="customer-type-pills-wrap">
                                <asp:RadioButtonList ID="rdoCustomerType" runat="server" RepeatDirection="Horizontal" AutoPostBack="true" OnSelectedIndexChanged="rdoCustomerType_SelectedIndexChanged" CssClass="pos-pill-radios">
                                    <asp:ListItem Text="By Member" Value="Member" Selected="True"></asp:ListItem>
                                    <asp:ListItem Text="By Guest Rooms" Value="Guest Room"></asp:ListItem>
                                    <asp:ListItem Text="By Affiliated Club" Value="Affiliated Member"></asp:ListItem>
                                </asp:RadioButtonList>
                            </div>

                            <div class="tr-info-badge-wrap">
                                <div class="tr-field-item">
                                    <label>Tr Date:</label>
                                    <asp:TextBox ID="txtValidFrom" runat="server" CssClass="form-control pos-input" TextMode="Date" AutoPostBack="true" OnTextChanged="txtValidFrom_TextChanged" style="width:130px !important; height:22px !important; padding:1px 4px !important; font-size:11px !important;"></asp:TextBox>
                                </div>
                                <div class="tr-field-item">
                                    <label>Tr #:</label>
                                    <asp:TextBox ID="txtTransactionNo" runat="server" CssClass="form-control pos-input tr-no-box" ReadOnly="true" Text="2670004132"></asp:TextBox>
                                </div>
                            </div>
                        </div>

                        <!-- Hidden Dropdown for State Handling -->
                        <asp:DropDownList ID="ddlCustomerType" runat="server" Visible="false" AutoPostBack="true" OnSelectedIndexChanged="ddlCustomerType_SelectedIndexChanged">
                            <asp:ListItem Text="Member" Value="Member"></asp:ListItem>
                            <asp:ListItem Text="Guest Room" Value="Guest Room"></asp:ListItem>
                            <asp:ListItem Text="Affiliated Member" Value="Affiliated Member"></asp:ListItem>
                        </asp:DropDownList>

                        <!-- Bottom Row: Search, Customer Name, Remarks & Direct Print with Balanced Spacing -->
                        <div class="customer-fields-grid">
                            <div class="field-group">
                                <asp:Panel ID="pnlMemberSearch" runat="server" DefaultButton="btnSearchMember">
                                    <label class="pos-field-label">Member No:</label>
                                    <div class="input-with-btn">
                                        <asp:TextBox ID="txtMemberSearch" runat="server" CssClass="form-control pos-input" placeholder="Scan / Member No..."></asp:TextBox>
                                        <asp:LinkButton ID="btnSearchMember" runat="server" CssClass="btn-search-icon" OnClick="btnSearchMember_Click" CausesValidation="false"><i class="fas fa-search"></i></asp:LinkButton>
                                    </div>
                                </asp:Panel>

                                <asp:Panel ID="pnlGuestSearch" runat="server" DefaultButton="btnValidateGuest" Visible="false">
                                    <label class="pos-field-label">Check IN # / Room No:</label>
                                    <div class="input-with-btn">
                                        <asp:TextBox ID="txtReservationNo" runat="server" CssClass="form-control pos-input" placeholder="Room No / Res No..."></asp:TextBox>
                                        <asp:LinkButton ID="btnValidateGuest" runat="server" CssClass="btn-search-icon" OnClick="btnValidateGuest_Click" CausesValidation="false"><i class="fas fa-search"></i></asp:LinkButton>
                                    </div>
                                </asp:Panel>

                                <asp:Panel ID="pnlAffiliatedSearch" runat="server" DefaultButton="btnSearchAffiliated" Visible="false">
                                    <label class="pos-field-label">Card No / Intro #:</label>
                                    <div class="input-with-btn">
                                        <asp:TextBox ID="txtCardNo" runat="server" CssClass="form-control pos-input" placeholder="Enter Card No..."></asp:TextBox>
                                        <asp:LinkButton ID="btnSearchAffiliated" runat="server" CssClass="btn-search-icon" OnClick="btnSearchAffiliated_Click" CausesValidation="false"><i class="fas fa-search"></i></asp:LinkButton>
                                    </div>
                                </asp:Panel>
                            </div>

                            <div class="field-group">
                                <label class="pos-field-label">Customer / Member Name:</label>
                                <asp:DropDownList ID="ddlMemberNames" runat="server" CssClass="form-control pos-input" Visible="false" AutoPostBack="true" OnSelectedIndexChanged="ddlMemberNames_SelectedIndexChanged">
                                </asp:DropDownList>
                                <asp:TextBox ID="txtCustomerName" runat="server" CssClass="form-control pos-input" placeholder="Select or view name"></asp:TextBox>
                                <asp:TextBox ID="txtGuestNameDisplay" runat="server" CssClass="form-control pos-input" placeholder="Guest Name will appear here..." Visible="false" style="font-weight:700; color:#1e3a5f; background:#f8fafc;"></asp:TextBox>
                                <asp:TextBox ID="txtAffiliatedNameDisplay" runat="server" CssClass="form-control pos-input" placeholder="Affiliated Member Name..." Visible="false" style="font-weight:700; color:#1e3a5f;"></asp:TextBox>
                            </div>

                            <div class="field-group">
                                <label class="pos-field-label">Remarks / Notes:</label>
                                <asp:TextBox ID="txtPayDesc" runat="server" CssClass="form-control pos-input" placeholder="Enter remarks or note..."></asp:TextBox>
                            </div>

                            <div class="field-group">
                                <label class="pos-field-label">&nbsp;</label>
                                <div class="direct-print-toggle">
                                    <label>
                                        <asp:CheckBox ID="chkDirectPrint" runat="server" Checked="true" />
                                        <span>Direct Print</span>
                                    </label>
                                </div>
                            </div>
                        </div>

                        <asp:Panel ID="pnlMemberInfoCard" runat="server" Visible="false" CssClass="member-info-badge-card">
                            <div class="info-badge-item"><strong>Member No:</strong> <asp:Label ID="lblInfoMemberNo" runat="server"></asp:Label></div>
                            <div class="info-badge-item"><strong>Age:</strong> <asp:Label ID="lblInfoAge" runat="server"></asp:Label></div>
                        </asp:Panel>

                        <asp:HiddenField ID="hfMemberID" runat="server" />
                        <asp:HiddenField ID="hfMemberNo" runat="server" />
                        <asp:HiddenField ID="hfBlockSlip" runat="server" Value="0" />
                    </div>

                    <!-- Section 2: Search & Add Package / Item Section -->
                    <div class="pos-card-section">
                        <div class="pos-section-badge"><i class="fas fa-barcode"></i> Add Package / Item</div>
                        
                        <div class="add-items-grid">
                            <div class="field-group">
                                <label class="pos-field-label">Filter Department:</label>
                                <asp:DropDownList ID="ddlSports" runat="server" CssClass="form-control pos-input" AutoPostBack="true" OnSelectedIndexChanged="ddlSports_SelectedIndexChanged">
                                </asp:DropDownList>
                            </div>

                            <div class="field-group">
                                <label class="pos-field-label">Sub Department:</label>
                                <asp:DropDownList ID="ddlSubDept" runat="server" CssClass="form-control pos-input" AutoPostBack="true" OnSelectedIndexChanged="ddlSubDept_SelectedIndexChanged">
                                </asp:DropDownList>
                            </div>

                            <div class="field-group">
                                <label class="pos-field-label">Item Code:</label>
                                <div class="input-with-btn">
                                    <asp:TextBox ID="txtItemCode" runat="server" CssClass="form-control pos-input" placeholder="Code" AutoPostBack="true" OnTextChanged="txtItemCode_TextChanged"></asp:TextBox>
                                    <asp:LinkButton ID="btnSearchItemCode" runat="server" CssClass="btn-search-icon" OnClick="txtItemCode_TextChanged" CausesValidation="false" ToolTip="Search Item Code"><i class="fas fa-search"></i></asp:LinkButton>
                                </div>
                            </div>

                            <div class="field-group">
                                <label class="pos-field-label">Package (Code or Name):</label>
                                <asp:DropDownList ID="ddlDailyPackages" runat="server" CssClass="form-control pos-input" AutoPostBack="true" OnSelectedIndexChanged="ddlDailyPackages_SelectedIndexChanged">
                                </asp:DropDownList>
                            </div>

                            <div class="field-group">
                                <label class="pos-field-label">Rate (PKR):</label>
                                <asp:TextBox ID="txtCustomRate" runat="server" CssClass="form-control pos-input text-right font-bold" TextMode="Number" step="1" Text="0" AutoPostBack="true" OnTextChanged="CalculateNetTotal"></asp:TextBox>
                            </div>

                            <div class="field-group">
                                <label class="pos-field-label">Valid To Date:</label>
                                <asp:TextBox ID="txtValidTo" runat="server" CssClass="form-control pos-input" TextMode="Date" AutoPostBack="true" OnTextChanged="txtValidTo_TextChanged"></asp:TextBox>
                            </div>

                            <div class="field-group">
                                <label class="pos-field-label">No. of Days:</label>
                                <asp:DropDownList ID="ddlNumberOfDays" runat="server" CssClass="form-control pos-input" AutoPostBack="true" OnSelectedIndexChanged="ddlNumberOfDays_SelectedIndexChanged">
                                    <asp:ListItem Text="1 Day" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="2 Days" Value="2"></asp:ListItem>
                                    <asp:ListItem Text="3 Days" Value="3"></asp:ListItem>
                                    <asp:ListItem Text="4 Days" Value="4"></asp:ListItem>
                                    <asp:ListItem Text="5 Days" Value="5"></asp:ListItem>
                                    <asp:ListItem Text="6 Days" Value="6"></asp:ListItem>
                                    <asp:ListItem Text="7 Days" Value="7"></asp:ListItem>
                                    <asp:ListItem Text="10 Days" Value="10"></asp:ListItem>
                                    <asp:ListItem Text="15 Days" Value="15"></asp:ListItem>
                                    <asp:ListItem Text="30 Days" Value="30"></asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="field-group">
                                <label class="pos-field-label">Locker (Optional):</label>
                                <asp:DropDownList ID="ddlLocker" runat="server" CssClass="form-control pos-input" AutoPostBack="true" OnSelectedIndexChanged="CalculateNetTotal">
                                </asp:DropDownList>
                                <asp:HiddenField ID="txtLockerFee" runat="server" Value="0" />
                            </div>

                            <div class="field-group">
                                <label class="pos-field-label">&nbsp;</label>
                                <asp:LinkButton ID="btnAddToList" runat="server" CssClass="btn-add-grid" OnClick="btnAddToList_Click" CausesValidation="false"><i class="fas fa-plus"></i> Add</asp:LinkButton>
                            </div>
                        </div>
                    </div>

                    <!-- Hidden inputs for calculations -->
                    <div style="display:none;">
                        <asp:DropDownList ID="ddlRateType" runat="server">
                            <asp:ListItem Text="Base Rate" Value="Base"></asp:ListItem>
                            <asp:ListItem Text="Half" Value="Half"></asp:ListItem>
                            <asp:ListItem Text="Senior" Value="Senior"></asp:ListItem>
                        </asp:DropDownList>
                        <asp:TextBox ID="txtBaseFee" runat="server" Text="0"></asp:TextBox>
                        <asp:TextBox ID="txtGSTAmount" runat="server" Text="0"></asp:TextBox>
                        <asp:Label ID="lblGSTPercent" runat="server" Text="16"></asp:Label>
                        <asp:HiddenField ID="hfGSTPercentage" runat="server" Value="16" />
                        <asp:TextBox ID="txtPolicyDiscount" runat="server" Text="0"></asp:TextBox>
                        <asp:TextBox ID="txtNetTotal" runat="server" Text="0"></asp:TextBox>
                        <asp:TextBox ID="txtBankDiscount" runat="server" Text="0"></asp:TextBox>
                        <asp:TextBox ID="txtFinalPayable" runat="server" Text="0"></asp:TextBox>
                        <asp:Label ID="lblCartSummary" runat="server" Text="0 Items"></asp:Label>
                        <uc:MemberSubInfo ID="ucMemberSubInfo" runat="server" Visible="false" />
                        <asp:HiddenField ID="hfFeeAmount" runat="server" />
                    </div>

                    <!-- Section 3: Middle Item Grid Table -->
                    <div class="pos-card-section" style="padding-bottom: 2px;">
                        <div class="grid-table-container">
                            <asp:GridView ID="gvCart" runat="server" AutoGenerateColumns="False" CssClass="pos-grid-table" GridLines="Both" OnRowCommand="gvCart_RowCommand" OnRowDataBound="gvCart_RowDataBound" ShowFooter="false">
                                <Columns>
                                    <asp:BoundField DataField="ItemCode" HeaderText="Code" ItemStyle-Width="100px" ItemStyle-Font-Bold="true" />
                                    <asp:BoundField DataField="PackageName" HeaderText="Description" />
                                    
                                    <asp:TemplateField HeaderText="Rate (PKR)" ItemStyle-Width="110px">
                                        <ItemTemplate>
                                            <asp:TextBox ID="txtGridRate" runat="server" Text='<%# Eval("BaseFee", "{0:N0}") %>' CssClass="form-control-sm" style="width:95px; text-align:right; font-weight:700;" AutoPostBack="true" OnTextChanged="txtGridRow_TextChanged" ReadOnly='<%# Eval("IsEditable") != DBNull.Value && !Convert.ToBoolean(Eval("IsEditable")) %>'></asp:TextBox>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Unit / Days" ItemStyle-Width="90px" ItemStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:TextBox ID="txtGridDays" runat="server" Text='<%# Eval("NumberOfDays") %>' CssClass="form-control-sm" style="width:65px; text-align:center; font-weight:700;" TextMode="Number" AutoPostBack="true" OnTextChanged="txtGridRow_TextChanged"></asp:TextBox>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:BoundField DataField="BaseFee" HeaderText="Amount" DataFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" />
                                    <asp:BoundField DataField="GSTAmount" HeaderText="Gst(%)" DataFormatString="{0:N2}" ItemStyle-HorizontalAlign="Right" />
                                    <asp:BoundField DataField="NetTotal" HeaderText="Net" DataFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" ItemStyle-Font-Bold="true" />
                                    <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="70px">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnRemove" runat="server" CommandName="RemoveItem" CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn btn-sm btn-danger" style="padding:2px 8px; font-size:11px; border-radius:3px;"><i class="fas fa-trash"></i></asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <EmptyDataTemplate>
                                    <div style="text-align:center; padding:8px 12px; color:#64748b; font-weight:600; font-size:11.5px; background:#fff;">No item added to charging grid. Search package by Code/Name above and click 'Add to Grid'.</div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                            
                            <!-- Live Totals Summary Bar -->
                            <div class="grid-totals-bar">
                                <div class="total-item">
                                    <span class="lbl">Amount:</span>
                                    <span class="val"><asp:Label ID="lblGridAmount" runat="server" Text="0"></asp:Label></span>
                                </div>
                                <div class="total-item">
                                    <span class="lbl">GST:</span>
                                    <span class="val"><asp:Label ID="lblGridGST" runat="server" Text="0.00"></asp:Label></span>
                                </div>
                                <div class="total-item net-item">
                                    <span class="lbl">Net Payable:</span>
                                    <span class="val"><asp:Label ID="lblGridNet" runat="server" Text="0"></asp:Label></span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Section 4: Unified Payment & Settlement + Actions Sidebar -->
                    <div class="pos-card-section" style="border-bottom: none; padding-bottom: 0;">
                        <div class="settlement-bottom-grid">
                            
                            <!-- Unified Payment Settlement Area -->
                            <div class="settlement-fields-area">
                                <div class="settlement-mode-bar">
                                    <span class="payment-mode-label"><i class="fas fa-money-check-alt"></i> Payment Mode:</span>
                                    
                                    <asp:RadioButtonList ID="rdoPaymentMode" runat="server" RepeatDirection="Horizontal" AutoPostBack="true" OnSelectedIndexChanged="rdoPaymentMode_SelectedIndexChanged" CssClass="pos-pill-radios">
                                        <asp:ListItem Text="On Cash" Value="Cash" Selected="True"></asp:ListItem>
                                        <asp:ListItem Text="Credit Card" Value="Credit Card"></asp:ListItem>
                                        <asp:ListItem Text="On Account" Value="Online Payment"></asp:ListItem>
                                    </asp:RadioButtonList>
                                </div>

                                <!-- Hidden Dropdown for state handling -->
                                <asp:DropDownList ID="ddlPaymentMode" runat="server" Visible="false" AutoPostBack="true" OnSelectedIndexChanged="ddlPaymentMode_SelectedIndexChanged">
                                    <asp:ListItem Text="Cash" Value="Cash"></asp:ListItem>
                                    <asp:ListItem Text="Credit Card" Value="Credit Card"></asp:ListItem>
                                    <asp:ListItem Text="Online Payment" Value="Online Payment"></asp:ListItem>
                                </asp:DropDownList>

                                <!-- Settlement Form Fields Layout -->
                                <div class="settlement-inputs-grid">
                                    <!-- Net Payable Badge Input -->
                                    <div class="field-group">
                                        <label class="pos-field-label">Net Payable:</label>
                                        <div class="payable-badge-input">
                                            <span class="currency-prefix">PKR</span>
                                            <asp:TextBox ID="txtNetTotalDisplay" runat="server" CssClass="form-control pos-input net-payable-val" ReadOnly="true" Text="0"></asp:TextBox>
                                        </div>
                                    </div>

                                    <div class="field-group">
                                        <label class="pos-field-label">Amount Paid:</label>
                                        <asp:TextBox ID="txtAmountPaid" runat="server" CssClass="form-control pos-input text-right font-bold" TextMode="Number" step="0.01" placeholder="0.00"></asp:TextBox>
                                    </div>

                                    <div class="field-group">
                                        <label class="pos-field-label">Discount:</label>
                                        <asp:TextBox ID="txtManualDiscount" runat="server" CssClass="form-control pos-input text-right" Text="0" placeholder="0"></asp:TextBox>
                                    </div>

                                    <div class="field-group" id="divBankDiscountAmount" runat="server" visible="false">
                                        <label class="pos-field-label" style="color:#dc2626;">Bank Disc:</label>
                                        <asp:TextBox ID="txtBankDiscountDisplay" runat="server" CssClass="form-control pos-input text-danger-bold" ReadOnly="true" Text="0.00"></asp:TextBox>
                                    </div>

                                    <div class="field-group" id="divRefID" runat="server">
                                        <label class="pos-field-label">Ref / Slip Name:</label>
                                        <asp:TextBox ID="txtReferenceID" runat="server" CssClass="form-control pos-input" placeholder="Ref No / Slip #"></asp:TextBox>
                                    </div>

                                    <!-- Right Group: Credit Card / Bank Offers (when Active) -->
                                    <div class="field-group" id="divCardNoPayment" runat="server">
                                        <label class="pos-field-label">Credit Card #:</label>
                                        <asp:TextBox ID="txtPaymentCardNo" runat="server" CssClass="form-control pos-input" placeholder="Card No / 4 digits" AutoPostBack="true" OnTextChanged="txtPaymentCardNo_TextChanged" onkeyup="if(this.value.replace(/\s+/g, '').length >= 4) { this.blur(); }"></asp:TextBox>
                                    </div>

                                    <div class="field-group" id="divBankCard" runat="server">
                                        <label class="pos-field-label">Select Offer:</label>
                                        <asp:DropDownList ID="ddlBankCard" runat="server" CssClass="form-control pos-input" AutoPostBack="true" OnSelectedIndexChanged="ddlBankCard_SelectedIndexChanged">
                                        </asp:DropDownList>
                                    </div>

                                    <div class="field-group" id="divCardType" runat="server">
                                        <label class="pos-field-label">Card Type:</label>
                                        <asp:TextBox ID="txtCardType" runat="server" CssClass="form-control pos-input" ReadOnly="true" placeholder="Card Type"></asp:TextBox>
                                    </div>

                                    <div class="field-group" id="divBankDiscountPercent" runat="server">
                                        <label class="pos-field-label">Bank Disc %:</label>
                                        <asp:TextBox ID="txtBankDiscountPercent" runat="server" CssClass="form-control pos-input text-success-bold" ReadOnly="true" placeholder="0%"></asp:TextBox>
                                    </div>
                                </div>

                                <!-- Detailed Card Offer Criteria Breakdown -->
                                <div class="settlement-offer-full" id="divCardOfferInfo" runat="server" visible="false">
                                    <div class="card-offer-banner">
                                        <div><i class="fas fa-barcode" style="color:#0284c7;"></i> <b>Prefix / Length:</b> <asp:Label ID="lblOfferPrefixLength" runat="server" style="font-weight:700; color:#0369a1;"></asp:Label></div>
                                        <div><i class="fas fa-credit-card" style="color:#0284c7;"></i> <b>Card Type:</b> <asp:Label ID="lblOfferCardType" runat="server" style="font-weight:700; color:#0369a1;"></asp:Label></div>
                                        <div><i class="fas fa-percentage" style="color:#16a34a;"></i> <b>Discount Rate:</b> <asp:Label ID="lblOfferDiscount" runat="server" style="font-weight:800; color:#15803d;"></asp:Label></div>
                                        <div><i class="fas fa-calendar-check" style="color:#0284c7;"></i> <b>Valid Till:</b> <asp:Label ID="lblOfferValidity" runat="server" style="font-weight:700; color:#0369a1;"></asp:Label></div>
                                        <div><i class="fas fa-coins" style="color:#d97706;"></i> <b>Min Bill:</b> <asp:Label ID="lblOfferMinBill" runat="server" style="font-weight:700; color:#b45309;"></asp:Label></div>
                                        <div><i class="fas fa-tag" style="color:#dc2626;"></i> <b>Max Discount:</b> <asp:Label ID="lblOfferMaxDiscount" runat="server" style="font-weight:700; color:#b91c1c;"></asp:Label></div>
                                        <div><i class="fas fa-clock" style="color:#0284c7;"></i> <b>Valid Days:</b> <asp:Label ID="lblOfferValidDays" runat="server" style="font-weight:700; color:#0369a1;"></asp:Label></div>
                                        <div><i class="fas fa-building" style="color:#4f46e5;"></i> <b>Departments:</b> <asp:Label ID="lblOfferValidDepts" runat="server" style="font-weight:700; color:#4338ca;"></asp:Label></div>
                                    </div>
                                </div>
                            </div>

                            <!-- Actions Sidebar -->
                            <div class="pos-actions-sidebar">
                                <asp:LinkButton ID="btnRefreshProducts" runat="server" CssClass="btn-action-side btn-action-secondary" OnClick="btnRefreshProducts_Click" CausesValidation="false">
                                    <i class="fas fa-sync-alt"></i>
                                    <span>Refresh</span>
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnNewTransaction" runat="server" CssClass="btn-action-side btn-action-navy" OnClick="btnNewTransaction_Click" CausesValidation="false">
                                    <i class="fas fa-file-alt"></i>
                                    <span>New</span>
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnGenerateReceipt" runat="server" CssClass="btn-action-side btn-action-primary" OnClick="btnGenerateReceipt_Click">
                                    <i class="fas fa-save"></i>
                                    <span>Save &amp; Print</span>
                                </asp:LinkButton>
                            </div>

                        </div>
                    </div>

                </div>

            </asp:Panel>

            <!-- Printable Receipt Section -->
            <asp:Panel ID="pnlReceipt" runat="server" Visible="false" style="flex:1; min-width:400px;" CssClass="receipt-area">
                <div class="receipt-card">
                    <div class="receipt-header">
                        <img src="images/lahore_gymkhana_logo.png.png" alt="Lahore Gymkhana Logo" />
                        <div class="receipt-text">
                            <h3>Lahore Gymkhana</h3>
                            <p>Sports Facility Access Pass</p>
                        </div>
                    </div>

                    <div class="receipt-row">
                        <span class="label">Receipt No:</span>
                        <span class="value"><asp:Label ID="lblRecNo" runat="server"></asp:Label></span>
                    </div>
                    <div class="receipt-row" id="divRecManualRegister" runat="server" visible="false">
                        <span class="label">Slip / Reg #:</span>
                        <span class="value"><asp:Label ID="lblRecManualRegister" runat="server" style="font-weight:700; color:#0369a1;"></asp:Label></span>
                    </div>
                    <div class="receipt-row">
                        <span class="label">Date:</span>
                        <span class="value"><asp:Label ID="lblRecDate" runat="server"></asp:Label></span>
                    </div>
                    
                    <div class="receipt-divider"></div>
                    
                    <div class="receipt-row">
                        <span class="label">Customer Type:</span>
                        <span class="value"><asp:Label ID="lblRecType" runat="server"></asp:Label></span>
                    </div>
                    <asp:Panel ID="pnlRecMemberNo" runat="server" CssClass="receipt-row">
                        <span class="label">Member / Room No:</span>
                        <span class="value"><asp:Label ID="lblRecMemberNo" runat="server"></asp:Label></span>
                    </asp:Panel>
                    <div class="receipt-row">
                        <span class="label">Name:</span>
                        <span class="value"><asp:Label ID="lblRecName" runat="server"></asp:Label></span>
                    </div>
                    <div class="receipt-row" id="divRecDept" runat="server">
                        <span class="label">Department:</span>
                        <span class="value"><asp:Label ID="lblRecDepartment" runat="server" style="color:#1e3a5f; font-weight:700;"></asp:Label></span>
                    </div>

                    <div class="receipt-divider"></div>
                    
                    <div style="margin-bottom: 10px; font-weight: bold; text-decoration: underline;">Items:</div>
                    <asp:Repeater ID="rptReceiptItems" runat="server">
                        <ItemTemplate>
                            <div class="receipt-row" style="margin-bottom: 2px;">
                                <span class="label"><%# Eval("PackageName") %> (<%# Eval("NumberOfDays") %> Days)</span>
                                <span class="value"><%# Convert.ToDecimal(Eval("NetTotal")).ToString("N0") %></span>
                            </div>
                            <div class="receipt-row" style="font-size: 11px; color: var(--gray-600); margin-bottom: 5px;">
                                <span><%# Eval("DepartmentName") != null && !string.IsNullOrEmpty(Eval("DepartmentName").ToString()) ? "<b>Dept:</b> " + Eval("DepartmentName") + " &nbsp;|&nbsp; " : "" %>Valid: <%# Convert.ToDateTime(Eval("ValidFrom")).ToString("dd-MMM") %> to <%# Convert.ToDateTime(Eval("ValidTo")).ToString("dd-MMM") %></span>
                                <span runat="server" visible='<%# Eval("LockerName") != null && Eval("LockerName").ToString() != "" %>'> &nbsp;|&nbsp; Lckr: <%# Eval("LockerName") %></span>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    <div class="receipt-divider"></div>

                    <div class="receipt-row">
                        <span class="label">Payment Mode:</span>
                        <span class="value"><asp:Label ID="lblRecPaymentMode" runat="server"></asp:Label></span>
                    </div>

                    <div class="receipt-divider"></div>

                    <div class="receipt-row" id="divRecSubTotal" runat="server" visible="false">
                        <span class="label">Gross Total:</span>
                        <span class="value"><asp:Label ID="lblRecSubTotal" runat="server"></asp:Label></span>
                    </div>

                    <div class="receipt-row" id="divRecDiscount" runat="server" visible="false" style="color:#dc2626; font-weight:700;">
                        <span class="label" style="color:#dc2626;">Discount:</span>
                        <span class="value" style="color:#dc2626;"><asp:Label ID="lblRecDiscount" runat="server"></asp:Label></span>
                    </div>

                    <div class="receipt-divider" id="divRecDiscountDivider" runat="server" visible="false"></div>

                    <div class="receipt-row">
                        <span class="label" style="font-size:16px;">Total Paid:</span>
                        <span class="value receipt-total"><asp:Label ID="lblRecTotal" runat="server"></asp:Label></span>
                    </div>

                    <div class="receipt-footer">
                        * Valid for the specified dates only.<br />
                        * Non-transferable & Non-refundable.<br />
                        Generated By: Staff
                    </div>
                </div>

                <div class="no-print" style="text-align:center; margin-top:20px;">
                    <button type="button" class="btn btn-navy" onclick="window.print()">
                        <i class="fas fa-print"></i> Print Receipt
                    </button>
                    <asp:Button ID="btnDoneReceipt" runat="server" Text="Done / New" CssClass="btn" style="background:#64748b; color:#fff; margin-left:10px;" OnClick="btnNewTransaction_Click" />
                </div>
            </asp:Panel>

        <!-- MANUAL CARD SLIP & REGISTER ENTRY MODAL -->
        <asp:Panel ID="pnlManualCardModal" runat="server" Visible="false" CssClass="pos-modal-overlay">
            <div class="pos-modal-box">
                <div style="background: linear-gradient(135deg, #1e3a5f 0%, #0f172a 100%); color: #ffffff; padding: 14px 20px; display:flex; justify-content:space-between; align-items:center;">
                    <h4 style="margin:0; font-size:16px; font-weight:800; display:flex; align-items:center; gap:8px;">
                        <i class="fas fa-receipt" style="color:#38bdf8;"></i> <asp:Label ID="lblModalTitle" runat="server" Text="Manual Card Slip & Register Entry"></asp:Label>
                    </h4>
                    <asp:LinkButton ID="btnCloseManualCardModal" runat="server" OnClick="btnCloseManualCardModal_Click" CausesValidation="false" style="color:#ffffff; font-size:22px; line-height:1; text-decoration:none;">&times;</asp:LinkButton>
                </div>

                <div style="padding: 20px;">
                    <!-- Summary Card -->
                    <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px 16px; margin-bottom: 16px; display: grid; grid-template-columns: 1fr 1fr; gap: 8px; font-size: 13px;">
                        <div>
                            <span style="color:#64748b; font-size:11.5px; text-transform:uppercase; font-weight:700;">Net Amount:</span><br />
                            <b style="color:#15803d; font-size:16px;"><asp:Label ID="lblModalChargeAmount" runat="server" Text="PKR 0"></asp:Label></b>
                        </div>
                        <div>
                            <span id="lblModalModeHeading" runat="server" style="color:#64748b; font-size:11.5px; text-transform:uppercase; font-weight:700;">Payment Mode / Offer:</span><br />
                            <b style="color:#1e3a5f; font-size:13px;"><asp:Label ID="lblModalCardOfferName" runat="server" Text="Credit Card"></asp:Label></b>
                        </div>
                    </div>

                    <div class="form-group" style="margin-bottom: 14px;">
                        <label style="font-weight:700; font-size:12.5px; color:#1e293b; margin-bottom:5px; display:block;">
                            Manual Slip / Register No <span style="color:#dc2626;">*</span>
                        </label>
                        <div style="display:flex; gap:6px;">
                            <asp:TextBox ID="txtManualRegisterNo" runat="server" CssClass="form-control" placeholder="Enter Physical Slip / Register # (e.g. SLIP-8921)" style="font-size:14px; font-weight:700; height:40px; border-color:#0284c7;" AutoCompleteType="Disabled"></asp:TextBox>
                            <asp:LinkButton ID="btnModalVerifySlip" runat="server" CssClass="btn btn-navy" OnClick="btnModalVerifySlip_Click" CausesValidation="false" style="height:40px; padding:0 14px; font-size:13px; font-weight:700; display:inline-flex; align-items:center; gap:5px; white-space:nowrap;"><i class="fas fa-check-circle"></i> Check</asp:LinkButton>
                        </div>
                        <asp:Label ID="lblModalSlipCheckResult" runat="server" Visible="false" style="display:block; margin-top:6px; font-size:12px; font-weight:700;"></asp:Label>
                        <small style="color:#64748b; font-size:11px; display:block; margin-top:3px;"><i class="fas fa-info-circle"></i> Unique physical receipt/register book number.</small>
                    </div>

                    <div class="form-group" id="divModalCardNo" runat="server" style="margin-bottom: 14px;">
                        <label style="font-weight:700; font-size:12px; color:#475569; margin-bottom:4px; display:block;">Card Number / Digits:</label>
                        <asp:TextBox ID="txtModalCardNoDigits" runat="server" CssClass="form-control" ReadOnly="true" style="background:#f1f5f9; font-weight:700; color:#334155; height:36px;"></asp:TextBox>
                    </div>

                    <div class="form-group" id="divModalTerminalRef" runat="server" style="margin-bottom: 14px;">
                        <label id="lblModalTerminalRef" runat="server" style="font-weight:700; font-size:12px; color:#475569; margin-bottom:4px; display:block;">POS Terminal / Bank Machine Ref (Optional):</label>
                        <asp:TextBox ID="txtModalTerminalRef" runat="server" CssClass="form-control" placeholder="TID / Bank Machine Ref" style="height:36px;"></asp:TextBox>
                    </div>

                    <div style="display:flex; justify-content:flex-end; gap:10px; margin-top:20px; padding-top:14px; border-top:1px solid #e2e8f0;">
                        <asp:Button ID="btnCancelManualCard" runat="server" Text="Cancel" CssClass="btn" OnClick="btnCloseManualCardModal_Click" CausesValidation="false" style="background:#f1f5f9; color:#475569; border:1px solid #cbd5e1; padding:8px 18px; font-weight:600; border-radius:6px;" />
                        <asp:Button ID="btnConfirmSaveReceipt" runat="server" Text="Save & Print Slip" CssClass="btn btn-primary" OnClick="btnConfirmSaveReceipt_Click" style="background:linear-gradient(135deg, #166534 0%, #14532d 100%) !important; padding:8px 22px; font-weight:700; border-radius:6px;" />
                    </div>
                </div>
            </div>
        </asp:Panel>
        </asp:View>

        <asp:View ID="vwHistory" runat="server">
            <div class="card no-print" style="margin-bottom:0; border-radius:6px;">
                <div class="card-header" style="background:#1e3a5f; color:white; font-weight:700; font-size:12.5px; text-transform:uppercase; padding:6px 12px;">Receipt History</div>
                <div class="card-body" style="padding:10px 12px !important;">
                    <!-- Collection Summary Cards -->
                    <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap:8px; margin-bottom:10px;">
                        <div style="background:#e0f2fe; border-left:3px solid #0284c7; padding:6px 10px; border-radius:5px;">
                            <div style="font-size:10px; color:#0369a1; font-weight:700; text-transform:uppercase; letter-spacing:0.4px;"><i class="fas fa-money-bill-wave"></i> Cash Paid</div>
                            <div style="font-size:15px; font-weight:800; color:#0c4a6e; margin-top:2px;">
                                <asp:Label ID="lblTotalCash" runat="server" Text="PKR 0"></asp:Label>
                            </div>
                        </div>
                        <div style="background:#f0fdf4; border-left:3px solid #16a34a; padding:6px 10px; border-radius:5px;">
                            <div style="font-size:10px; color:#15803d; font-weight:700; text-transform:uppercase; letter-spacing:0.4px;"><i class="fas fa-credit-card"></i> Credit Card</div>
                            <div style="font-size:15px; font-weight:800; color:#14532d; margin-top:2px;">
                                <asp:Label ID="lblTotalCard" runat="server" Text="PKR 0"></asp:Label>
                            </div>
                        </div>
                        <div style="background:#fef3c7; border-left:3px solid #d97706; padding:6px 10px; border-radius:5px;">
                            <div style="font-size:10px; color:#b45309; font-weight:700; text-transform:uppercase; letter-spacing:0.4px;"><i class="fas fa-user-check"></i> Member Account</div>
                            <div style="font-size:15px; font-weight:800; color:#78350f; margin-top:2px;">
                                <asp:Label ID="lblTotalAccount" runat="server" Text="PKR 0"></asp:Label>
                            </div>
                        </div>
                        <div style="background:#1e3a5f; border-left:3px solid #3b82f6; padding:6px 10px; border-radius:5px; color:white;">
                            <div style="font-size:10px; color:#93c5fd; font-weight:700; text-transform:uppercase; letter-spacing:0.4px;"><i class="fas fa-calculator"></i> Total Amount</div>
                            <div style="font-size:15px; font-weight:800; color:#ffffff; margin-top:2px;">
                                <asp:Label ID="lblTotalOverall" runat="server" Text="PKR 0"></asp:Label>
                            </div>
                        </div>
                    </div>

                    <div style="display:flex; gap:8px; align-items:flex-end; margin-bottom:10px; flex-wrap:wrap;">
                        <div class="form-group" style="margin-bottom:0; width:auto; flex:1; min-width:120px;">
                            <label style="font-size:10.5px; font-weight:700; margin-bottom:2px;">From Date</label>
                            <asp:TextBox ID="txtFromDate" runat="server" CssClass="form-control pos-input" TextMode="Date" style="height:28px !important; font-size:11.5px;"></asp:TextBox>
                        </div>
                        <div class="form-group" style="margin-bottom:0; width:auto; flex:1; min-width:120px;">
                            <label style="font-size:10.5px; font-weight:700; margin-bottom:2px;">To Date</label>
                            <asp:TextBox ID="txtToDate" runat="server" CssClass="form-control pos-input" TextMode="Date" style="height:28px !important; font-size:11.5px;"></asp:TextBox>
                        </div>
                        <div class="form-group" style="margin-bottom:0; width:auto; flex:1.2; min-width:140px;">
                            <label style="font-size:10.5px; font-weight:700; margin-bottom:2px;">Manual Slip / Reg #</label>
                            <asp:TextBox ID="txtFilterManualSlip" runat="server" CssClass="form-control pos-input" placeholder="Search Slip #" style="height:28px !important; font-size:11.5px;"></asp:TextBox>
                        </div>
                        <div class="form-group" style="margin-bottom:0; width:auto; flex:1; min-width:110px;">
                            <label style="font-size:10.5px; font-weight:700; margin-bottom:2px;">Status</label>
                            <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="form-control pos-input" style="height:28px !important; font-size:11.5px;">
                                <asp:ListItem Text="All" Value="All"></asp:ListItem>
                                <asp:ListItem Text="Paid" Value="Paid"></asp:ListItem>
                                <asp:ListItem Text="Unpaid" Value="Unpaid"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <asp:LinkButton ID="btnFilterHistory" runat="server" CssClass="btn btn-navy" OnClick="btnFilterHistory_Click" style="height:28px; padding:0 12px; font-size:11.5px; font-weight:700; display:inline-flex; align-items:center; gap:4px;"><i class="fas fa-filter"></i> Filter</asp:LinkButton>
                    </div>

                    <div style="border-radius:5px; overflow:hidden; border:1px solid #cbd5e1; max-height:350px; overflow-y:auto;">
                        <asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="false" CssClass="history-grid" Width="100%" OnRowCommand="gvHistory_RowCommand" GridLines="None">
                            <Columns>
                                <asp:BoundField DataField="ReceiptNo" HeaderText="Receipt #" />
                                <asp:BoundField DataField="ManualRegisterNo" HeaderText="Slip / Reg #" NullDisplayText="-" />
                                <asp:BoundField DataField="TransactionDate" HeaderText="Date" DataFormatString="{0:dd-MMM-yyyy hh:mm tt}" />
                                <asp:BoundField DataField="CustomerType" HeaderText="Type" />
                                <asp:BoundField DataField="CustomerName" HeaderText="Name" />
                                <asp:BoundField DataField="PackageName" HeaderText="Package" />
                                <asp:BoundField DataField="ValidFrom" HeaderText="Valid From" DataFormatString="{0:dd-MMM-yyyy}" />
                                <asp:BoundField DataField="ValidTo" HeaderText="Valid To" DataFormatString="{0:dd-MMM-yyyy}" />
                                <asp:BoundField DataField="PaymentMode" HeaderText="Payment Mode" />
                                <asp:BoundField DataField="Fee" HeaderText="Amount" DataFormatString="{0:N0}" />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <span style='<%# Convert.ToString(Eval("Status")) == "Paid" ? "color:#155724; background-color:#d4edda; padding:2px 6px; border-radius:4px; font-weight:bold; font-size:10.5px;" : "color:#721c24; background-color:#f8d7da; padding:2px 6px; border-radius:4px; font-weight:bold; font-size:10.5px;" %>' >
                                            <%# Eval("Status") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Action">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnReprint" runat="server" CommandName="Reprint" CommandArgument='<%# Eval("TransactionID") %>' CssClass="btn btn-navy btn-sm" style="padding:2px 8px; font-size:11px;"><i class="fas fa-print"></i> Reprint</asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div style="text-align:center; padding:15px; color:var(--gray-500); font-size:11.5px;">No receipts found for the selected date range.</div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </asp:View>
    </asp:MultiView>
</asp:Content>
