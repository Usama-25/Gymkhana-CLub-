<%@ Page Title="Manage Membership Types" Language="C#" MasterPageFile="~/MemberShipModule/Site.master"
    AutoEventWireup="true" CodeFile="ManageMembershipTypes.aspx.cs" Inherits="ManageMembershipTypes" %>

<asp:Content ID="HeadStyles" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Outfit', sans-serif !important; background-color: #faf7f2; }
        .table-container { background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
        .table { width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left; }
        .table th { background: #1A1A2E; color: #C9A84C; font-weight: 600; padding: 0.75rem 1rem; border-bottom: 2px solid #e0d5c5; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.05em; }
        .table td { padding: 0.75rem 1rem; border-bottom: 1px solid #e0d5c5; color: #1A1A2E; vertical-align: middle; }
        .table tr:last-child td { border-bottom: none; }
        .empty-state { padding: 2rem; text-align: center; color: #a09080; background-color: #faf7f2; border: 1px dashed #e0d5c5; border-radius: 12px; display: flex; flex-direction: column; align-items: center; gap: 0.75rem; margin-top: 1rem; }
        .empty-state svg { color: #a09080; opacity: 0.6; margin-bottom: 0.5rem; }
        .table-input { width: 100%; padding: 0.5rem 0.75rem; border: 1px solid transparent; border-radius: 6px; background: transparent; font-size: 0.95rem; color: #1A1A2E; transition: all 0.2s ease; }
        .table-input:hover { background: #F7F3EE; border-color: #e0d5c5; }
        .table-input:focus { background: #ffffff; border-color: #8B5E3C; box-shadow: 0 0 0 2px #f5ecd5; outline: none; }
        .form-control { display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.8rem; font-weight: 400; line-height: 1.2; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; }
        .form-control:focus { border-color: #C9A84C; box-shadow: 0 0 0 3px rgba(201, 168, 76, 0.15); outline: none; }
        
        .btn { display: inline-block; text-align: center; vertical-align: middle; padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: all 0.15s ease; border: 1px solid transparent; line-height: 1; }
        .btn-primary { background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2); }
        .btn-primary:hover { box-shadow: 0 8px 12px rgba(201, 168, 76, 0.3); transform: translateY(-1px); }
        .btn-secondary { background-color: white; color: #1A1A2E; border-color: #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
        .btn-secondary:hover { background-color: #F7F3EE; border-color: #e0d5c5; color: #1A1A2E; }
        .btn-success { background-color: #10b981; color: white; border-color: #10b981; border: 1px solid #10b981; }
        .btn-danger { background-color: #ef4444; color: white; border-color: #ef4444; border: 1px solid #ef4444; }
        .btn-warning { background-color: #f59e0b; color: white; border-color: #f59e0b; border: 1px solid #f59e0b; }
        .btn-info { background-color: #8B5E3C; color: white; border-color: #8B5E3C; border: 1px solid #8B5E3C; }
        .btn-sm { padding: 0.4rem 0.8rem; font-size: 0.875rem; }
        .btn-sm.flex { display: inline-flex; align-items: center; justify-content: center; }
        
        /* Refund Configuration Styles */
        .refund-config { 
            background: #faf7f2; 
            border-radius: 8px; 
            padding: 12px; 
            margin-top: 10px; 
            border: 1px solid #e0d5c5;
        }
        .refund-config-title { 
            font-size: 0.75rem; 
            font-weight: 700; 
            color: #8B5E3C; 
            margin-bottom: 10px; 
            text-transform: uppercase;
        }
        .refund-row { 
            display: flex; 
            gap: 15px; 
            margin-bottom: 10px; 
            align-items: center;
        }
        .refund-field { 
            flex: 1; 
            display: flex; 
            flex-direction: column;
        }
        .refund-field label { 
            font-size: 0.7rem; 
            font-weight: 600; 
            color: #7a7a7a; 
            margin-bottom: 3px;
        }
        .refund-field input { 
            padding: 5px 8px; 
            border: 1px solid #e0d5c5; 
            border-radius: 5px; 
            font-size: 0.8rem;
            width: 100%;
        }
        .refund-field input:focus { 
            border-color: #C9A84C; 
            outline: none;
        }
        /* Refund Type Toggle (Radio Pill) */
        .refund-type-toggle {
            display: flex;
            gap: 8px;
            width: 100%;
        }
        .refund-radio-label {
            cursor: pointer;
            flex: 1;
        }
        .refund-radio-label input[type="radio"] {
            display: none;
        }
        .refund-radio-pill {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            padding: 8px 14px;
            border: 2px solid #e0d5c5;
            border-radius: 8px;
            font-size: 0.78rem;
            font-weight: 600;
            color: #7a7a7a;
            background: #ffffff;
            transition: all 0.25s ease;
            text-align: center;
        }
        .refund-radio-pill:hover {
            border-color: #e0d5c5;
            color: #1A1A2E;
        }
        .refund-radio-pill.active {
            border-color: #C9A84C;
            background: linear-gradient(135deg, #faf7f2, #f5ecd5);
            color: #8B5E3C;
            box-shadow: 0 2px 8px rgba(201, 168, 76, 0.15);
        }
        .refund-calc-input {
            padding: 5px 8px;
            border: 1px solid #a7f3d0;
            border-radius: 5px;
            font-size: 0.85rem;
            font-weight: 700;
            width: 100%;
            background: #ecfdf5 !important;
            color: #059669;
            cursor: not-allowed;
        }

        /* Modal Styles */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(15, 23, 42, 0.5);
            backdrop-filter: blur(4px);
            z-index: 10000;
            display: none;
            align-items: center;
            justify-content: center;
        }
        .modal-container {
            background: #fff;
            border-radius: 14px;
            width: 500px;
            max-width: 92vw;
            box-shadow: 0 20px 60px rgba(0,0,0,0.15);
            overflow: hidden;
        }
        .modal-header {
            padding: 20px 24px 12px;
            border-bottom: 1px solid #e0d5c5;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .modal-header h3 {
            margin: 0;
            font-size: 1.1rem;
            font-weight: 700;
            color: #1A1A2E;
        }
        .modal-close {
            cursor: pointer;
            font-size: 1.2rem;
            color: #a09080;
            transition: color 0.2s;
        }
        .modal-close:hover {
            color: #ef4444;
        }
        .modal-body {
            padding: 20px 24px;
        }
        .modal-footer {
            padding: 14px 24px;
            background: #faf7f2;
            border-top: 1px solid #e0d5c5;
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        .subtype-input-group {
            display: flex;
            gap: 10px;
            margin-bottom: 8px;
            align-items: center;
        }
        .subtype-input-group input {
            flex: 1;
            padding: 6px 10px;
            border: 1px solid #e0d5c5;
            border-radius: 6px;
            font-size: 0.85rem;
        }
        .btn-remove-subtype {
            background: #fee2e2;
            color: #991b1b;
            border: none;
            width: 28px;
            height: 28px;
            border-radius: 6px;
            cursor: pointer;
        }
        .btn-remove-subtype:hover {
            background: #fecaca;
        }
        .btn-add-subtype {
            background: #faf7f2;
            color: #8B5E3C;
            border: 1px solid #e0d5c5;
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 0.75rem;
            font-weight: 600;
            cursor: pointer;
            margin-top: 12px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
        }
        .btn-add-subtype:hover {
            background: #F7F3EE;
            border-color: #e0d5c5;
            color: #1e293b;
        }
        .subtypes-container {
            margin-top: 15px;
            border-top: 1px solid #e0d5c5;
            padding-top: 12px;
        }
        .subtypes-container label {
            font-size: 0.7rem;
            font-weight: 600;
            color: #8B5E3C;
            display: block;
            margin-bottom: 8px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .mmt-page { width: 98%; margin: 0 auto; padding: 10px 0; font-family: 'Outfit', sans-serif; }
        .mmt-page-header { display: flex; align-items: center; gap: 16px; margin-bottom: 1.5rem; padding: 16px 26px; border-bottom: 1px solid #e0d5c5; background: linear-gradient(135deg, #1A1A2E, #2d2d5e); border-radius: 12px; }
        .mmt-page-header .icon-wrap { width: 52px; height: 52px; background: rgba(255, 255, 255, 0.1); border-radius: 14px; display: flex; align-items: center; justify-content: center; color: #E8D5A3; font-size: 1.4rem; flex-shrink: 0; }
        .mmt-page-header h1 { font-size: 1.5rem; font-weight: 700; color: #ffffff; margin: 0; }
        .mmt-page-header p { color: #E8D5A3; margin: 0.25rem 0 0 0; font-size: 0.95rem; }

        .mmt-tabs { display: flex; gap: 6px; background: #faf7f2; border-radius: 12px; padding: 6px; margin-bottom: 8px; border: 1px solid #e0d5c5; }
        .mmt-tab { flex: 1; text-align: center; padding: 12px 16px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; color: #7a7a7a; cursor: pointer; border: none; background: transparent; transition: all 0.2s ease; display: flex; align-items: center; justify-content: center; gap: 10px; }
        .mmt-tab:hover { color: #C9A84C; background: #fff; }
        .mmt-tab.active { background: #fff; color: #8B5E3C; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.04); border: 1px solid #e0d5c5; }

        .mmt-panel { display: none; }
        .mmt-panel.active { display: block; animation: fadeInSlideUp 0.3s ease-out; }
        @keyframes fadeInSlideUp { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

        .mmt-card { background: #fff; border-radius: 12px; padding: 14px 18px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); border: 1px solid #e0d5c5; margin-bottom: 8px; transition: border-color 0.2s; }
        .mmt-card:hover { border-color: #e0d5c5; }
        .mmt-card-title { font-size: 0.95rem; font-weight: 700; color: #1A1A2E; margin: 0 0 14px; display: flex; align-items: center; gap: 8px; border-bottom: 1px solid #F7F3EE; padding-bottom: 8px; }
        .mmt-card-title i { color: #C9A84C; }

        .mmt-form-row { display: flex; gap: 12px; align-items: flex-end; flex-wrap: wrap; margin-bottom: 0px; }
        .mmt-form-group { display: flex; flex-direction: column; flex: 1; min-width: 110px; margin-bottom: 10px; }
        .mmt-form-group.wide { flex: 2; min-width: 220px; }
        .mmt-form-group label { font-size: 0.68rem; font-weight: 700; color: #8B5E3C; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px; }
        .mmt-form-group input, .mmt-form-group select, .mmt-form-group textarea { padding: 6px 10px; border: 1px solid #e0d5c5; border-radius: 6px; font-size: 0.85rem; color: #1A1A2E; background: #fff; transition: all 0.2s; height: 32px; }
        .mmt-form-group textarea { height: auto; }
        .mmt-form-group input:focus, .mmt-form-group select:focus, .mmt-form-group textarea:focus { border-color: #C9A84C; outline: none; box-shadow: 0 0 0 3px rgba(201, 168, 76, 0.15); }
        .mmt-form-group input[readonly] { background-color: #faf7f2; cursor: not-allowed; font-weight: 600; color: #1A1A2E; border-color: #F7F3EE; }

        .mmt-flex-container { display: flex; flex-direction: column; gap: 16px; align-items: stretch; width: 100%; }
        .mmt-flex-item { width: 100%; }
        .mmt-flex-30, .mmt-flex-35 { width: 100% !important; }
        .mmt-flex-70, .mmt-flex-65 { width: 98% !important; margin-left: auto !important; margin-right: auto !important; }

        .mmt-btn-add { background: #8B5E3C; color: #fff !important; border: none; padding: 8px 18px; border-radius: 8px; font-weight: 600; font-size: 0.8rem; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; gap: 10px; transition: all 0.2s; border: 1px solid #1A1A2E; }
        .mmt-btn-add:hover { background: #1A1A2E; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
        .mmt-btn-cancel { background: #fff; color: #7a7a7a; border: 1px solid #e0d5c5; padding: 8px 18px; border-radius: 8px; font-weight: 600; font-size: 0.8rem; cursor: pointer; transition: all 0.2s; }
        .mmt-btn-cancel:hover { background: #faf7f2; color: #1A1A2E; border-color: #e0d5c5; }
        
        .mmt-btn-edit { background: #fef3c7; color: #92400e; border: 1px solid #fde68a; padding: 6px 14px; border-radius: 6px; font-weight: 600; font-size: 0.8rem; cursor: pointer; }
        .mmt-btn-edit:hover { background: #fde68a; }
        .mmt-btn-deactivate { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; padding: 6px 14px; border-radius: 6px; font-weight: 600; font-size: 0.8rem; cursor: pointer; }
        .mmt-btn-deactivate:hover { background: #fecaca; }
        .mmt-btn-activate { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; padding: 6px 14px; border-radius: 6px; font-weight: 600; font-size: 0.8rem; cursor: pointer; }
        .mmt-btn-activate:hover { background: #bbf7d0; }

        .mmt-grid { width: 100%; border-collapse: separate; border-spacing: 0; border-radius: 12px; overflow: hidden; border: 1px solid #F7F3EE; }
        .mmt-grid-header { background: #faf7f2; color: #8B5E3C; font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; padding: 6px 8px; border-bottom: 2px solid #F7F3EE; text-align: left; }
        .mmt-grid-row { padding: 6px 8px; border-bottom: 1px solid #F7F3EE; font-size: 0.8rem; color: #1A1A2E; }
        .mmt-grid tr:hover td { background: #fcfdfe; }

        .badge-active { background: #dcfce7; color: #15803d; padding: 4px 12px; border-radius: 20px; font-size: 0.7rem; font-weight: 700; border: 1px solid #bbf7d0; display: inline-block; white-space: nowrap; }
        .badge-inactive { background: #fee2e2; color: #b91c1c; padding: 4px 12px; border-radius: 20px; font-size: 0.7rem; font-weight: 700; border: 1px solid #fecaca; display: inline-block; white-space: nowrap; }

        .mmt-stats { display: flex; gap: 16px; margin-bottom: 8px; }
        .mmt-stat-card { flex: 1; background: #fff; border-radius: 14px; padding: 18px 24px; border: 1px solid #e0d5c5; display: flex; align-items: center; gap: 16px; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .mmt-stat-card:hover { transform: translateY(-3px); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); border-color: #e0d5c5; }
        .mmt-stat-icon { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.25rem; flex-shrink: 0; }
        .mmt-stat-icon.purple { background: #faf7f2; color: #8B5E3C; }
        .mmt-stat-icon.blue { background: #faf7f2; color: #C9A84C; }
        .mmt-stat-icon.green { background: #ecfdf5; color: #15803d; }
        .mmt-stat-value { font-size: 1.5rem; font-weight: 800; color: #1A1A2E; line-height: 1.1; }
        .mmt-stat-label { font-size: 0.8rem; color: #7a7a7a; font-weight: 600; margin-top: 3px; text-transform: uppercase; letter-spacing: 0.5px; }

        /* Premium Form Grid Styles (Shared classes for template items) */
        .prefix-badge { display: inline-block; background: #F7F3EE; color: #8B5E3C; padding: 3px 10px; border-radius: 4px; font-size: 0.72rem; font-weight: 700; font-family: 'Consolas', 'SF Mono', monospace; letter-spacing: 0.5px; border: 1px solid #e0d5c5; }
        .amount-cell { color: #1A1A2E; }
        .amount-cell .currency-sign { color: #a09080; font-size: 0.7rem; margin-right: 2px; }
        .total-cell { background: linear-gradient(135deg, #f0fdf4, #ecfdf5); padding: 4px 10px; border-radius: 6px; display: inline-block; border: 1px solid #bbf7d0; }
        .total-cell .currency-sign { color: #16a34a; font-size: 0.7rem; margin-right: 2px; }
        .total-cell .total-value { color: #15803d; font-weight: 800; }
        .refund-pill { display: inline-block; padding: 2px 8px; border-radius: 12px; font-size: 0.68rem; font-weight: 700; margin-right: 3px; margin-bottom: 2px; white-space: nowrap; }
        .refund-pill-pct { background: #faf7f2; color: #8B5E3C; border: 1px solid #e0d5c5; }
        .refund-pill-fixed { background: #faf7f2; color: #1A1A2E; border: 1px solid #e0d5c5; }
        .refund-pill-yes { background: #ecfdf5; color: #059669; border: 1px solid #a7f3d0; }
        .refund-pill-none { color: #e0d5c5; font-size: 0.7rem; }

        .mmt-btn-secondary { background: #7a7a7a; color: #fff; border: none; padding: 6px 16px; border-radius: 6px; font-weight: 600; font-size: 0.8rem; cursor: pointer; transition: all 0.2s; display: inline-flex; align-items: center; gap: 8px; }
        .mmt-btn-secondary:hover { background: #8B5E3C; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
        
        .mmt-msg-success { background: #dcfce7; color: #15803d; padding: 8px 12px; border-radius: 6px; margin-bottom: 10px; font-size: 0.8rem; }
        .mmt-msg-error { background: #fee2e2; color: #b91c1c; padding: 8px 12px; border-radius: 6px; margin-bottom: 10px; font-size: 0.8rem; }
    </style>

    <div class="mmt-page">
        <!-- Header -->
        <div class="mmt-page-header">
            <div class="icon-wrap">
                <i class="fas fa-layer-group"></i>
            </div>
            <div>
                <h1>Manage Membership Types</h1>
                <p>Manage Membership Types and Form Types</p>
            </div>
        </div>

        <!-- Stats -->
        <asp:UpdatePanel ID="upStats" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <div class="mmt-stats">
                    <div class="mmt-stat-card">
                        <div class="mmt-stat-icon blue"><i class="fas fa-id-badge"></i></div>
                        <div>
                            <div class="mmt-stat-value"><asp:Label ID="lblTypeCount" runat="server" Text="0" /></div>
                            <div class="mmt-stat-label">Membership Types</div>
                        </div>
                    </div>
                    <div class="mmt-stat-card">
                        <div class="mmt-stat-icon green"><i class="fas fa-file-alt"></i></div>
                        <div>
                            <div class="mmt-stat-value"><asp:Label ID="lblFormCount" runat="server" Text="0" /></div>
                            <div class="mmt-stat-label">Form Types</div>
                        </div>
                    </div>
                    <div class="mmt-stat-card">
                        <div class="mmt-stat-icon purple" style="background:#fff7ed;color:#ea580c;"><i class="fas fa-layer-group"></i></div>
                        <div>
                            <div class="mmt-stat-value"><asp:Label ID="lblCategoryCount" runat="server" Text="0" /></div>
                            <div class="mmt-stat-label">Categories</div>
                        </div>
                    </div>
                    <div class="mmt-stat-card">
                        <div class="mmt-stat-icon purple" style="background:#faf7f2;color:#C9A84C;"><i class="fas fa-tags"></i></div>
                        <div>
                            <div class="mmt-stat-value"><asp:Label ID="lblFormTypeMainCount" runat="server" Text="0" /></div>
                            <div class="mmt-stat-label">Form Type Categories</div>
                        </div>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>

        <!-- Tabs -->
        <div class="mmt-tabs" id="tabBar">
            <button type="button" class="mmt-tab active" onclick="switchTab('tabType', this)">
                <i class="fas fa-id-badge"></i> Define MembershipTypes
            </button>
            <button type="button" class="mmt-tab" onclick="switchTab('tabForm', this)">
                <i class="fas fa-file-alt"></i> Define Form Types
            </button>
            <button type="button" class="mmt-tab" onclick="switchTab('tabCategory', this)">
                <i class="fas fa-layer-group"></i>Define Categories
            </button>
        </div>

        <!-- TAB 2: Membership Types (unchanged) -->
        <div id="tabType" class="mmt-panel active">
            <asp:UpdatePanel ID="upType" runat="server">
                <ContentTemplate>
                    <asp:Label ID="lblTypeMsg" runat="server" Visible="false" />
                    <div class="mmt-flex-container">
                        <div class="mmt-flex-item mmt-flex-30">
                            <div class="mmt-card">
                                <div class="mmt-card-title"><i class="fas fa-plus-circle"></i> Add Membership Type</div>
                                <asp:HiddenField ID="hfTypeId" runat="server" Value="0" />
                                <div class="mmt-form-row">
                                    <div class="mmt-form-group">
                                        <label>Type Name</label>
                                        <asp:TextBox ID="txtTypeName" runat="server" placeholder="e.g. Ordinary, Life" />
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Prefix</label>
                                        <asp:TextBox ID="txtPrefix" runat="server" placeholder="e.g. ORD" />
                                    </div>
                                </div>
                                <div style="display:flex; gap:10px;">
                                    <asp:Button ID="btnSaveType" runat="server" Text="Save" OnClick="btnSaveType_Click" 
                                        style="background: #8B5E3C; color: #ffffff; border: none; padding: 6px 16px; border-radius: 6px; font-weight: 600; font-size: 0.8rem; cursor: pointer;" />
                                    <asp:Button ID="btnClearType" runat="server" Text="Clear" OnClick="btnClearType_Click" 
                                        style="background: #a09080; color: #ffffff; border: none; padding: 6px 16px; border-radius: 6px; font-weight: 600; font-size: 0.8rem; cursor: pointer;" />
                                </div>
                            </div>
                        </div>
                        <div class="mmt-flex-item mmt-flex-70">
                            <div class="mmt-card">
                                <div class="mmt-card-title"><i class="fas fa-list"></i> All Membership Types</div>
                                <asp:GridView ID="gvType" runat="server" AutoGenerateColumns="false" DataKeyNames="id" OnRowCommand="gvType_RowCommand" EmptyDataText="No membership types found." 
                                    GridLines="None" 
                                    style="width: 100%; border-collapse: separate; border-spacing: 0; border-radius: 12px; overflow: hidden; border: 1px solid #F7F3EE; font-family: inherit;">
                                    <HeaderStyle BackColor="#faf7f2" ForeColor="#8B5E3C" Font-Bold="true" Height="32px" CssClass="mmt-grid-header" />
                                    <RowStyle BackColor="White" ForeColor="#1A1A2E" Height="36px" CssClass="mmt-grid-row" />
                                    <AlternatingRowStyle BackColor="#FAFBFC" />
                                    <Columns>
                                        <asp:TemplateField HeaderText="Sr.">
                                            <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Type Name">
                                            <ItemTemplate><%# Eval("MembershipType") %></ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Prefix">
                                            <ItemTemplate><%# Eval("Prefix") %></ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Status">
                                            <ItemTemplate>
                                                <span class='<%# Convert.ToInt32(Eval("Status")) == 1 ? "badge-active" : "badge-inactive" %>'>
                                                    <%# Convert.ToInt32(Eval("Status")) == 1 ? "Active" : "Inactive" %>
                                                </span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Actions">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="btnEditType" runat="server" CommandName="EditItem" CommandArgument='<%# Eval("id") %>' Text="Edit" CssClass="mmt-btn-edit" />
                                                <button type="button" class='<%# Convert.ToInt32(Eval("Status")) == 1 ? "mmt-btn-deactivate" : "mmt-btn-activate" %>'
                                                    onclick='<%# "openToggleModal(\"MembershipType\", " + Eval("id") + ", \"" + HttpUtility.JavaScriptStringEncode(Eval("MembershipType").ToString()) + "\", " + Eval("Status") + ")" %>'>
                                                    <%# Convert.ToInt32(Eval("Status")) == 1 ? "Deactivate" : "Activate" %>
                                                </button>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>

        <!-- TAB 3: Form Types with FormType Dropdown -->
        <div id="tabForm" class="mmt-panel">
            <asp:UpdatePanel ID="upForm" runat="server">
                <ContentTemplate>
                    <asp:Label ID="lblFormMsg" runat="server" Visible="false" />
                    <div class="mmt-flex-container">
                        <!-- Left Side: Add Form -->
                        <div class="mmt-flex-item mmt-flex-35">
                            <div class="mmt-card">
                                <div class="mmt-card-title"><i class="fas fa-plus-circle"></i> Add Form Type</div>
                                <asp:HiddenField ID="hfFormId" runat="server" Value="0" />
                                <asp:HiddenField ID="hfModalSubTypes" runat="server" Value="" />
                                
                                <div class="mmt-form-row">
                                    <div class="mmt-form-group wide">
                                        <label>Form Type Name <span style="color:#ef4444;">*</span></label>
                                        <div style="display: flex; gap: 8px;">
                                            <asp:DropDownList ID="ddlFormTypeName" runat="server" style="flex:2;" AutoPostBack="true" OnSelectedIndexChanged="ddlFormTypeName_SelectedIndexChanged">
                                                <asp:ListItem Text="-- Select Form Type --" Value="0" />
                                            </asp:DropDownList>
                                            <asp:Button ID="btnOpenFormTypeModal" runat="server" Text="+ New" OnClientClick="openFormTypeModal(); return false;" 
                                                style="background: #8B5E3C; color: #ffffff !important; border: 1px solid #1A1A2E; padding: 8px 18px; border-radius: 8px; font-weight: 600; font-size: 0.8rem; cursor: pointer; white-space: nowrap;" />
                                        </div>
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Sub Type</label>
                                        <asp:DropDownList ID="ddlSubType" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSubType_SelectedIndexChanged">
                                            <asp:ListItem Text="-- Select Sub Type --" Value="0" />
                                        </asp:DropDownList>
                                    </div>
                                </div>

                                <div class="mmt-form-row">
                                    <div class="mmt-form-group">
                                        <label>Prefix</label>
                                        <asp:TextBox ID="txtFormPrefix" runat="server" placeholder="e.g. PM" AutoPostBack="true" OnTextChanged="AutoSaveForm" />
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Form Fee</label>
                                        <div style="display:flex; align-items:center; gap:8px;">
                                            <asp:TextBox ID="txtFormFee" runat="server" placeholder="0" TextMode="Number" oninput="calculateTotal()" style="flex:1;" AutoPostBack="true" OnTextChanged="AutoSaveForm" />
                                            <div style="display:flex; align-items:center; gap:4px;">
                                                <asp:CheckBox ID="chkRefFormFee" runat="server" onclick="toggleRefundConfig('formFeeConfig')" AutoPostBack="true" OnCheckedChanged="AutoSaveForm" /> Refundable
                                            </div>
                                        </div>
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Entrance Fee</label>
                                        <div style="display:flex; align-items:center; gap:8px;">
                                            <asp:TextBox ID="txtEntranceFee" runat="server" placeholder="0" TextMode="Number" oninput="calculateTotal()" style="flex:1;" AutoPostBack="true" OnTextChanged="AutoSaveForm" />
                                            <div style="display:flex; align-items:center; gap:4px;">
                                                <asp:CheckBox ID="chkRefEntranceFee" runat="server" onclick="toggleRefundConfig('entranceFeeConfig')" AutoPostBack="true" OnCheckedChanged="AutoSaveForm" /> Refundable
                                            </div>
                                        </div>
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Extras / Misc.</label>
                                        <div style="display:flex; align-items:center; gap:8px;">
                                            <asp:TextBox ID="txtExtraCharges" runat="server" placeholder="0" TextMode="Number" oninput="calculateTotal()" style="flex:1;" AutoPostBack="true" OnTextChanged="AutoSaveForm" />
                                            <div style="display:flex; align-items:center; gap:4px;">
                                                <asp:CheckBox ID="chkRefExtraCharges" runat="server" onclick="toggleRefundConfig('extraChargesConfig')" AutoPostBack="true" OnCheckedChanged="AutoSaveForm" /> Refundable
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Refund Configuration Sections (same as before) -->
                                <asp:HiddenField ID="hfFormFeeRefundType" runat="server" Value="Fixed" />
                                <asp:HiddenField ID="hfEntranceFeeRefundType" runat="server" Value="Fixed" />
                                <asp:HiddenField ID="hfExtraChargesRefundType" runat="server" Value="Fixed" />

                                <div id="formFeeConfig" class="refund-config" style="display:none;">
                                    <div class="refund-config-title">Form Fee Refund Configuration</div>
                                    <div class="refund-row">
                                        <div class="refund-type-toggle">
                                            <label class="refund-radio-label">
                                                <input type="radio" name="formFeeRefType" value="Fixed" checked="checked" onclick="switchRefundType('formFee', 'Fixed')" />
                                                <span class="refund-radio-pill active" id="pillFormFeeFixed"><i class="fas fa-money-bill-wave"></i> Fixed Amount</span>
                                            </label>
                                            <label class="refund-radio-label">
                                                <input type="radio" name="formFeeRefType" value="Percentage" onclick="switchRefundType('formFee', 'Percentage')" />
                                                <span class="refund-radio-pill" id="pillFormFeePercent"><i class="fas fa-percentage"></i> Percentage</span>
                                            </label>
                                        </div>
                                    </div>
                                    <div class="refund-row">
                                        <div class="refund-field" id="formFeeFixedDiv">
                                            <label>Fixed Refund Amount</label>
                                            <asp:TextBox ID="txtFormFeeRefundFixed" runat="server" placeholder="0" TextMode="Number" AutoPostBack="true" OnTextChanged="AutoSaveForm" />
                                        </div>
                                        <div class="refund-field" id="formFeePercentDiv" style="display:none;">
                                            <label>Refund Percentage (%)</label>
                                            <asp:TextBox ID="txtFormFeeRefundPercent" runat="server" placeholder="0" TextMode="Number" oninput="calcRefundFromPercent('formFee')" AutoPostBack="true" OnTextChanged="AutoSaveForm" />
                                        </div>
                                        <div class="refund-field refund-calc-field" id="formFeeCalcDiv" style="display:none;">
                                            <label>Calculated Amount</label>
                                            <input type="text" id="formFeeCalcAmount" readonly="readonly" class="refund-calc-input" value="0" />
                                        </div>
                                    </div>
                                </div>

                                <div id="entranceFeeConfig" class="refund-config" style="display:none;">
                                    <div class="refund-config-title">Entrance Fee Refund Configuration</div>
                                    <div class="refund-row">
                                        <div class="refund-type-toggle">
                                            <label class="refund-radio-label">
                                                <input type="radio" name="entranceFeeRefType" value="Fixed" checked="checked" onclick="switchRefundType('entranceFee', 'Fixed')" />
                                                <span class="refund-radio-pill active" id="pillEntranceFeeFixed"><i class="fas fa-money-bill-wave"></i> Fixed Amount</span>
                                            </label>
                                            <label class="refund-radio-label">
                                                <input type="radio" name="entranceFeeRefType" value="Percentage" onclick="switchRefundType('entranceFee', 'Percentage')" />
                                                <span class="refund-radio-pill" id="pillEntranceFeePercent"><i class="fas fa-percentage"></i> Percentage</span>
                                            </label>
                                        </div>
                                    </div>
                                    <div class="refund-row">
                                        <div class="refund-field" id="entranceFeeFixedDiv">
                                            <label>Fixed Refund Amount</label>
                                            <asp:TextBox ID="txtEntranceFeeRefundFixed" runat="server" placeholder="0" TextMode="Number" AutoPostBack="true" OnTextChanged="AutoSaveForm" />
                                        </div>
                                        <div class="refund-field" id="entranceFeePercentDiv" style="display:none;">
                                            <label>Refund Percentage (%)</label>
                                            <asp:TextBox ID="txtEntranceFeeRefundPercent" runat="server" placeholder="0" TextMode="Number" oninput="calcRefundFromPercent('entranceFee')" AutoPostBack="true" OnTextChanged="AutoSaveForm" />
                                        </div>
                                        <div class="refund-field refund-calc-field" id="entranceFeeCalcDiv" style="display:none;">
                                            <label>Calculated Amount</label>
                                            <input type="text" id="entranceFeeCalcAmount" readonly="readonly" class="refund-calc-input" value="0" />
                                        </div>
                                    </div>
                                </div>

                                <div id="extraChargesConfig" class="refund-config" style="display:none;">
                                    <div class="refund-config-title">Extra Charges Refund Configuration</div>
                                    <div class="refund-row">
                                        <div class="refund-type-toggle">
                                            <label class="refund-radio-label">
                                                <input type="radio" name="extraChargesRefType" value="Fixed" checked="checked" onclick="switchRefundType('extraCharges', 'Fixed')" />
                                                <span class="refund-radio-pill active" id="pillExtraChargesFixed"><i class="fas fa-money-bill-wave"></i> Fixed Amount</span>
                                            </label>
                                            <label class="refund-radio-label">
                                                <input type="radio" name="extraChargesRefType" value="Percentage" onclick="switchRefundType('extraCharges', 'Percentage')" />
                                                <span class="refund-radio-pill" id="pillExtraChargesPercent"><i class="fas fa-percentage"></i> Percentage</span>
                                            </label>
                                        </div>
                                    </div>
                                    <div class="refund-row">
                                        <div class="refund-field" id="extraChargesFixedDiv">
                                            <label>Fixed Refund Amount</label>
                                            <asp:TextBox ID="txtExtraChargesRefundFixed" runat="server" placeholder="0" TextMode="Number" AutoPostBack="true" OnTextChanged="AutoSaveForm" />
                                        </div>
                                        <div class="refund-field" id="extraChargesPercentDiv" style="display:none;">
                                            <label>Refund Percentage (%)</label>
                                            <asp:TextBox ID="txtExtraChargesRefundPercent" runat="server" placeholder="0" TextMode="Number" oninput="calcRefundFromPercent('extraCharges')" AutoPostBack="true" OnTextChanged="AutoSaveForm" />
                                        </div>
                                        <div class="refund-field refund-calc-field" id="extraChargesCalcDiv" style="display:none;">
                                            <label>Calculated Amount</label>
                                            <input type="text" id="extraChargesCalcAmount" readonly="readonly" class="refund-calc-input" value="0" />
                                        </div>
                                    </div>
                                </div>

                                <div class="mmt-form-row">
                                    <div class="mmt-form-group">
                                        <label>Total Amount</label>
                                        <asp:TextBox ID="txtTotal" runat="server" placeholder="0" ReadOnly="true" Font-Bold="true" style="background: #F7F3EE;" />
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Currency</label>
                                        <asp:DropDownList ID="ddlCurrency" runat="server" AutoPostBack="true" OnSelectedIndexChanged="AutoSaveForm"></asp:DropDownList>
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Status</label>
                                        <asp:DropDownList ID="ddlFormStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="AutoSaveForm">
                                            <asp:ListItem Text="Active" Value="1" />
                                            <asp:ListItem Text="Inactive" Value="0" />
                                        </asp:DropDownList>
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Remarks</label>
                                        <asp:TextBox ID="txtRemarks" runat="server" placeholder="Enter any relevant notes..." AutoPostBack="true" OnTextChanged="AutoSaveForm" />
                                    </div>
                                </div>

                                <div style="display:flex; gap:10px; justify-content: flex-end; margin-top: 10px;">
                                    <asp:Button ID="btnSaveForm" runat="server" Text="Save" OnClick="btnSaveForm_Click" 
                                        style="background: #8B5E3C; color: #ffffff; border: none; padding: 6px 16px; border-radius: 6px; font-weight: 600; font-size: 0.8rem; cursor: pointer;" />
                                    <asp:Button ID="btnClearForm" runat="server" Text="Clear" OnClick="btnClearForm_Click" 
                                        style="background: #a09080; color: #ffffff; border: none; padding: 6px 16px; border-radius: 6px; font-weight: 600; font-size: 0.8rem; cursor: pointer;" />
                                </div>
                            </div>
                        </div>

                        <!-- Right Side: List -->
                        <div class="mmt-flex-item mmt-flex-65">
                            <div class="mmt-card">
                                <div class="mmt-card-title"><i class="fas fa-list"></i> All Form Types</div>
                                <div style="overflow-x: auto; border-radius: 10px; border: 1px solid #e0d5c5; width: 100%;">
                                    <asp:GridView ID="gvForm" runat="server" AutoGenerateColumns="false" DataKeyNames="id" OnRowCommand="gvForm_RowCommand" EmptyDataText="No form types found." 
                                        GridLines="None"
                                        style="width: 100%; border-collapse: collapse; font-size: 0.82rem; font-family: inherit;">
                                        <HeaderStyle BackColor="#faf7f2" ForeColor="#8B5E3C" Font-Bold="true" Height="40px" CssClass="mmt-grid-header" />
                                        <RowStyle BackColor="White" ForeColor="#1A1A2E" Height="40px" CssClass="mmt-grid-row" />
                                        <AlternatingRowStyle BackColor="#FAFBFC" />
                                        <Columns>
                                            <asp:TemplateField HeaderText="#">
                                                <HeaderStyle CssClass="col-sr" />
                                                <ItemStyle CssClass="col-sr" />
                                                <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Form Type">
                                                <ItemStyle CssClass="col-type" />
                                                <ItemTemplate>
                                                    <div><%# Eval("FormTypeName") %></div>
                                                    <small style="color:#7a7a7a;"><%# Eval("SubType") %></small>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Prefix">
                                                <HeaderStyle CssClass="col-center" />
                                                <ItemStyle CssClass="col-prefix" />
                                                <ItemTemplate>
                                                    <span class="prefix-badge"><%# Eval("Prefix") %></span>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Form Fee">
                                                <HeaderStyle CssClass="col-amount" />
                                                <ItemStyle CssClass="col-amount" />
                                                <ItemTemplate>
                                                    <span class="amount-cell"><span class="currency-sign"></span><%# string.Format("{0:N0}", Eval("Price")) %></span>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Entrance">
                                                <HeaderStyle CssClass="col-amount" />
                                                <ItemStyle CssClass="col-amount" />
                                                <ItemTemplate>
                                                    <span class="amount-cell"><span class="currency-sign"></span><%# string.Format("{0:N0}", Eval("EntranceFee")) %></span>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Extras">
                                                <HeaderStyle CssClass="col-amount" />
                                                <ItemStyle CssClass="col-amount" />
                                                <ItemTemplate>
                                                    <span class="amount-cell"><span class="currency-sign"></span><%# string.Format("{0:N0}", Eval("ExtraCharges")) %></span>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Total">
                                                <HeaderStyle CssClass="col-amount" />
                                                <ItemStyle CssClass="col-total" />
                                                <ItemTemplate>
                                                    <span class="total-cell"><span class="currency-sign"></span><span class="total-value"><%# string.Format("{0:N0}", Eval("TotalAmount")) %></span></span>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Refund Info">
                                                <ItemStyle CssClass="col-refund" />
                                                <ItemTemplate>
                                                    <div>
                                                        <%# GetRefundPill(Eval("IsFormFeeRefundable"), Eval("FormFeeRefundFixed"), Eval("FormFeeRefundPercent"), "Form") %>
                                                        <%# GetRefundPill(Eval("IsEntranceFeeRefundable"), Eval("EntranceFeeRefundFixed"), Eval("EntranceFeeRefundPercent"), "Entr.") %>
                                                        <%# GetRefundPill(Eval("IsExtraChargesRefundable"), Eval("ExtraChargesRefundFixed"), Eval("ExtraChargesRefundPercent"), "Extra") %>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Currency">
                                                <HeaderStyle CssClass="col-center" />
                                                <ItemStyle CssClass="col-prefix" />
                                                <ItemTemplate>
                                                    <span class="prefix-badge"><%# Eval("Currency") %></span>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Remarks">
                                                <ItemTemplate>
                                                    <span style="font-size: 0.75rem; color: #7a7a7a;"><%# Eval("Remarks") %></span>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Status">
                                                <HeaderStyle CssClass="col-center" />
                                                <ItemStyle CssClass="col-status" />
                                                <ItemTemplate>
                                                    <span class='<%# Convert.ToInt32(Eval("status")) == 1 ? "badge-active" : "badge-inactive" %>'>
                                                        <%# Convert.ToInt32(Eval("status")) == 1 ? "Active" : "Inactive" %>
                                                    </span>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Actions">
                                                <HeaderStyle CssClass="col-center" />
                                                <ItemStyle CssClass="col-actions" />
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="btnEditForm" runat="server" CommandName="EditItem" CommandArgument='<%# Eval("id") %>' Text="Edit" CssClass="mmt-btn-edit" />
                                                    <button type="button" class='<%# Convert.ToInt32(Eval("status")) == 1 ? "mmt-btn-deactivate" : "mmt-btn-activate" %>'
                                                        onclick='<%# "openToggleModal(\"FormTable\", " + Eval("id") + ", \"" + HttpUtility.JavaScriptStringEncode(Eval("FormTypeName").ToString()) + "\", " + Eval("status") + ")" %>'>
                                                        <%# Convert.ToInt32(Eval("status")) == 1 ? "Deactivate" : "Activate" %>
                                                    </button>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </div>
                            </div>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>

        <!-- TAB 4: Membership Categories (unchanged) -->
        <div id="tabCategory" class="mmt-panel" style="display:none">
            <asp:UpdatePanel ID="upCategory" runat="server">
                <ContentTemplate>
                    <asp:Label ID="lblCategoryMsg" runat="server" Visible="false" />
                    <div class="mmt-flex-container">
                        <div class="mmt-flex-item mmt-flex-35">
                            <div class="mmt-card">
                                <div class="mmt-card-title"><i class="fas fa-plus-circle"></i> Add Membership Category</div>
                                <asp:HiddenField ID="hfCategoryId" runat="server" Value="0" />
                                
                                <div class="mmt-form-row">
                                    <div class="mmt-form-group">
                                        <label>Category Code</label>
                                        <asp:TextBox ID="txtCategoryCode" runat="server" placeholder="e.g. CMI" />
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Category Description</label>
                                        <asp:TextBox ID="txtCategoryDesc" runat="server" placeholder="e.g. Invitation Member" />
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Monthly Fee</label>
                                        <asp:TextBox ID="txtCategoryMonthlyFee" runat="server" placeholder="0" TextMode="Number" />
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Type (From Form Table)</label>
                                        <asp:DropDownList ID="ddlCategoryFormType" runat="server"></asp:DropDownList>
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Member Type</label>
                                        <asp:DropDownList ID="ddlCategoryMemberType" runat="server" onchange="toggleCustomMemberType(this)">
                                            <asp:ListItem Text="Member-Corporate" Value="Member-Corporate" />
                                            <asp:ListItem Text="Member-Individual" Value="Member-Individual" />
                                            <asp:ListItem Text="Nominee" Value="Nominee" />
                                            <asp:ListItem Text="Other" Value="Other" />
                                        </asp:DropDownList>
                                        <asp:TextBox ID="txtCategoryMemberTypeCustom" runat="server" placeholder="Enter custom type..." style="display:none; margin-top: 5px;" />
                                    </div>
                                </div>

                                <div class="mmt-form-row">
                                    <div class="mmt-form-group">
                                        <label>Status</label>
                                        <asp:DropDownList ID="ddlCategoryStatus" runat="server">
                                            <asp:ListItem Text="Active" Value="1" />
                                            <asp:ListItem Text="Inactive" Value="0" />
                                        </asp:DropDownList>
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Advance Sub</label>
                                        <asp:TextBox ID="txtCatAdvanceSub" runat="server" placeholder="0" TextMode="Number" />
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Library Sub</label>
                                        <asp:TextBox ID="txtCatLibrarySub" runat="server" placeholder="0" TextMode="Number" />
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Film Sub</label>
                                        <asp:TextBox ID="txtCatFilmSub" runat="server" placeholder="0" TextMode="Number" />
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Musical Eve</label>
                                        <asp:TextBox ID="txtCatMusicalEve" runat="server" placeholder="0" TextMode="Number" />
                                    </div>
                                </div>

                                <div class="mmt-form-row">
                                    <div class="mmt-form-group">
                                        <label>AC Charges</label>
                                        <asp:TextBox ID="txtCatACCharges" runat="server" placeholder="0" TextMode="Number" />
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Welfare Fund</label>
                                        <asp:TextBox ID="txtCatWelfareFund" runat="server" placeholder="0" TextMode="Number" />
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Dev. Fund</label>
                                        <asp:TextBox ID="txtCatDevFund" runat="server" placeholder="0" TextMode="Number" />
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Credit Limit</label>
                                        <asp:TextBox ID="txtCatCreditLimit" runat="server" placeholder="0" TextMode="Number" />
                                    </div>
                                    <div class="mmt-form-group">
                                        <label>Misc. Charges</label>
                                        <asp:TextBox ID="txtCatMiscCharges" runat="server" placeholder="0" TextMode="Number" />
                                    </div>
                                </div>

                                <div class="mmt-form-row">
                                    <div class="mmt-form-group">
                                        <label>Add. Charges</label>
                                        <asp:TextBox ID="txtCatAddCharges" runat="server" placeholder="0" TextMode="Number" />
                                    </div>
                                </div>

                                <div style="display:flex; gap:10px; justify-content: flex-end; margin-top: 10px;">
                                    <asp:Button ID="btnSaveCategory" runat="server" Text="Save" OnClick="btnSaveCategory_Click" 
                                        style="background: #8B5E3C; color: #ffffff; border: none; padding: 6px 16px; border-radius: 6px; font-weight: 600; font-size: 0.8rem; cursor: pointer;" />
                                    <asp:Button ID="btnClearCategory" runat="server" Text="Clear" OnClick="btnClearCategory_Click" 
                                        style="background: #a09080; color: #ffffff; border: none; padding: 6px 16px; border-radius: 6px; font-weight: 600; font-size: 0.8rem; cursor: pointer;" />
                                </div>
                            </div>
                        </div>

                        <div class="mmt-flex-item mmt-flex-65">
                            <div class="mmt-card">
                                <div class="mmt-card-title"><i class="fas fa-list"></i> All Categories</div>
                                <div style="overflow-x: auto; border-radius: 10px; border: 1px solid #e0d5c5; width: 100%;">
                                    <asp:GridView ID="gvCategory" runat="server" AutoGenerateColumns="false" DataKeyNames="id" OnRowCommand="gvCategory_RowCommand" EmptyDataText="No categories found." 
                                        GridLines="None"
                                        style="width: 100%; border-collapse: collapse; font-size: 0.82rem; font-family: inherit;">
                                        <HeaderStyle BackColor="#faf7f2" ForeColor="#8B5E3C" Font-Bold="true" Height="40px" CssClass="mmt-grid-header" />
                                        <RowStyle BackColor="White" ForeColor="#1A1A2E" Height="40px" CssClass="mmt-grid-row" />
                                        <AlternatingRowStyle BackColor="#FAFBFC" />
                                        <Columns>
                                            <asp:TemplateField HeaderText="#">
                                                <HeaderStyle CssClass="col-sr" />
                                                <ItemStyle CssClass="col-sr" />
                                                <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Code">
                                                <ItemStyle CssClass="col-type" />
                                                <ItemTemplate><%# Eval("Category") %></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Description">
                                                <ItemTemplate><%# Eval("CategoryDescription") %></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Type ID">
                                                <HeaderStyle CssClass="col-center" />
                                                <ItemStyle CssClass="col-prefix" />
                                                <ItemTemplate>
                                                    <span class="prefix-badge"><%# Eval("FormTypeID") %></span>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="M/Fee">
                                                <HeaderStyle CssClass="col-amount" />
                                                <ItemStyle CssClass="col-amount" />
                                                <ItemTemplate><span class="amount-cell"><%# string.Format("{0:N0}", Eval("MonthlyFee")) %></span></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Adv.Sub">
                                                <HeaderStyle CssClass="col-amount" />
                                                <ItemStyle CssClass="col-amount" />
                                                <ItemTemplate><span class="amount-cell"><%# string.Format("{0:N0}", Eval("AdvanceSub")) %></span></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Lib.Sub">
                                                <HeaderStyle CssClass="col-amount" />
                                                <ItemStyle CssClass="col-amount" />
                                                <ItemTemplate><span class="amount-cell"><%# string.Format("{0:N0}", Eval("LibrarySub")) %></span></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Film">
                                                <HeaderStyle CssClass="col-amount" />
                                                <ItemStyle CssClass="col-amount" />
                                                <ItemTemplate><span class="amount-cell"><%# string.Format("{0:N0}", Eval("FilmSub")) %></span></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Music">
                                                <HeaderStyle CssClass="col-amount" />
                                                <ItemStyle CssClass="col-amount" />
                                                <ItemTemplate><span class="amount-cell"><%# string.Format("{0:N0}", Eval("MusicalEve")) %></span></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="AC">
                                                <HeaderStyle CssClass="col-amount" />
                                                <ItemStyle CssClass="col-amount" />
                                                <ItemTemplate><span class="amount-cell"><%# string.Format("{0:N0}", Eval("ACCharges")) %></span></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Welfare">
                                                <HeaderStyle CssClass="col-amount" />
                                                <ItemStyle CssClass="col-amount" />
                                                <ItemTemplate><span class="amount-cell"><%# string.Format("{0:N0}", Eval("WelfareFund")) %></span></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Dev.Fund">
                                                <HeaderStyle CssClass="col-amount" />
                                                <ItemStyle CssClass="col-amount" />
                                                <ItemTemplate><span class="amount-cell"><%# string.Format("{0:N0}", Eval("DevFund")) %></span></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Credit">
                                                <HeaderStyle CssClass="col-amount" />
                                                <ItemStyle CssClass="col-amount" />
                                                <ItemTemplate><span class="amount-cell"><%# string.Format("{0:N0}", Eval("CreditLimit")) %></span></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Misc">
                                                <HeaderStyle CssClass="col-amount" />
                                                <ItemStyle CssClass="col-amount" />
                                                <ItemTemplate><span class="amount-cell"><%# string.Format("{0:N0}", Eval("MiscCharges")) %></span></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Add.Chg">
                                                <HeaderStyle CssClass="col-amount" />
                                                <ItemStyle CssClass="col-amount" />
                                                <ItemTemplate><span class="amount-cell"><%# string.Format("{0:N0}", Eval("AdditionalCharges")) %></span></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="M.Type">
                                                <ItemTemplate><%# Eval("MemberType") %></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Status">
                                                <HeaderStyle CssClass="col-center" />
                                                <ItemStyle CssClass="col-status" />
                                                <ItemTemplate>
                                                    <span class='<%# Convert.ToInt32(Eval("Status")) == 1 ? "badge-active" : "badge-inactive" %>'>
                                                        <%# Convert.ToInt32(Eval("Status")) == 1 ? "Active" : "Inactive" %>
                                                    </span>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Actions">
                                                <HeaderStyle CssClass="col-center" />
                                                <ItemStyle CssClass="col-actions" />
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="btnEditCategory" runat="server" CommandName="EditItem" CommandArgument='<%# Eval("id") %>' Text="Edit" CssClass="mmt-btn-edit" />
                                                    <button type="button" class='<%# Convert.ToInt32(Eval("Status")) == 1 ? "mmt-btn-deactivate" : "mmt-btn-activate" %>'
                                                        onclick='<%# "openToggleModal(\"MembershipCategories\", " + Eval("id") + ", \"" + HttpUtility.JavaScriptStringEncode(Eval("Category").ToString()) + "\", " + Eval("Status") + ")" %>'>
                                                        <%# Convert.ToInt32(Eval("Status")) == 1 ? "Deactivate" : "Activate" %>
                                                    </button>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </div>
                            </div>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>

    <!-- FormType Modal -->
    <div id="formTypeModal" class="modal-overlay">
        <div class="modal-container">
            <div class="modal-header">
                <h3><i class="fas fa-folder-plus"></i> Add New Form Type Category</h3>
                <span class="modal-close" onclick="closeFormTypeModal()">&times;</span>
            </div>
            <div class="modal-body">
                <div class="mmt-form-group" style="margin-bottom: 15px;">
                    <label>Main Category Name *</label>
                    <asp:TextBox ID="txtModalMainType" runat="server" placeholder="e.g., Membership, Event, Conference" style="width:100%;" />
                </div>
                <div class="subtypes-container">
                    <label>Sub Types</label>
                    <div id="subtypesContainer">
                        <div class="subtype-input-group">
                            <asp:TextBox ID="txtSubType1" runat="server" placeholder="Enter sub type" />
                            <button type="button" class="btn-remove-subtype" onclick="removeSubtype(this)" style="display:none;"></button>
                        </div>
                    </div>
                    <button type="button" onclick="addSubtypeInput()" 
                        style="background: #faf7f2; color: #8B5E3C; border: 1px solid #e0d5c5; padding: 8px 16px; border-radius: 8px; font-size: 0.75rem; font-weight: 600; cursor: pointer; margin-top: 12px; display: inline-flex; align-items: center; gap: 8px;">
                        <i class="fas fa-plus"></i> Add Sub Type
                    </button>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" onclick="closeFormTypeModal()" 
                    style="background: #fff; color: #7a7a7a; border: 1px solid #e0d5c5; padding: 8px 18px; border-radius: 8px; font-weight: 600; font-size: 0.8rem; cursor: pointer;">Cancel</button>
                <asp:Button ID="btnSaveFormType" runat="server" Text="Save" OnClick="btnSaveFormType_Click" 
                    style="background: #8B5E3C; color: #ffffff !important; border: 1px solid #1A1A2E; padding: 8px 18px; border-radius: 8px; font-weight: 600; font-size: 0.8rem; cursor: pointer;" />
            </div>
        </div>
    </div>

    <!-- TOGGLE STATUS MODAL -->
    <div id="toggleModal" class="mmt-modal-overlay" style="display:none;">
        <div class="mmt-modal">
            <div class="mmt-modal-header">
                <div class="mmt-modal-icon" id="modalIcon"><i class="fas fa-toggle-on"></i></div>
                <h3 id="modalTitle">Confirm Status Change</h3>
                <p id="modalSubtitle" class="mmt-modal-subtitle"></p>
            </div>
            <div class="mmt-modal-body">
                <div class="mmt-form-group">
                    <label>Reason <span style="color:#ef4444;">*</span></label>
                    <asp:TextBox ID="txtToggleReason" runat="server" TextMode="MultiLine" Rows="3" placeholder="Enter reason for this status change..." style="width:100%; border:1px solid #d1d5db; border-radius:7px; font-size:0.88rem; resize:vertical;" />
                </div>
            </div>
            <div class="mmt-modal-footer">
                <button type="button" onclick="closeToggleModal()" 
                    style="background: #fff; color: #7a7a7a; border: 1px solid #e0d5c5; padding: 8px 18px; border-radius: 8px; font-weight: 600; font-size: 0.8rem; cursor: pointer;">Cancel</button>
                <asp:Button ID="btnConfirmToggle" runat="server" Text="Confirm" OnClick="btnConfirmToggle_Click" 
                    style="background: #8B5E3C; color: #ffffff !important; border: 1px solid #1A1A2E; padding: 8px 18px; border-radius: 8px; font-weight: 600; font-size: 0.8rem; cursor: pointer;" />
            </div>
        </div>
    </div>

    <asp:HiddenField ID="hfToggleTable" runat="server" />
    <asp:HiddenField ID="hfToggleId" runat="server" />
    <asp:HiddenField ID="hfToggleCurrentStatus" runat="server" />
    <asp:HiddenField ID="hfActiveTab" runat="server" Value="tabType" />

    <style>
        .mmt-modal-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(15, 23, 42, 0.5); backdrop-filter: blur(4px); z-index: 9999; display: flex; align-items: center; justify-content: center; animation: fadeInOverlay 0.2s ease; }
        .mmt-modal { background: #fff; border-radius: 14px; width: 440px; max-width: 92vw; box-shadow: 0 20px 60px rgba(0,0,0,0.15); animation: slideUpModal 0.25s ease; overflow: hidden; }
        .mmt-modal-header { padding: 24px 24px 12px; text-align: center; }
        .mmt-modal-icon { width: 52px; height: 52px; border-radius: 14px; display: inline-flex; align-items: center; justify-content: center; font-size: 1.4rem; margin-bottom: 10px; }
        .mmt-modal-icon.deactivate { background: #fff7ed; color: #ea580c; }
        .mmt-modal-icon.activate { background: #ecfdf5; color: #16a34a; }
        .mmt-modal-header h3 { font-size: 1.1rem; font-weight: 700; color: #1A1A2E; margin: 0 0 4px; }
        .mmt-modal-subtitle { font-size: 0.85rem; color: #7a7a7a; margin: 0; }
        .mmt-modal-body { padding: 12px 24px 20px; }
        .mmt-modal-footer { padding: 14px 24px; background: #faf7f2; border-top: 1px solid #e0d5c5; display: flex; justify-content: flex-end; gap: 10px; }
    </style>

    <script type="text/javascript">
        // Tab navigation only
        function switchTab(panelId, btn) {
            var panels = document.querySelectorAll('.mmt-panel');
            for (var i = 0; i < panels.length; i++) panels[i].classList.remove('active');
            var tabs = document.querySelectorAll('.mmt-tab');
            for (var j = 0; j < tabs.length; j++) tabs[j].classList.remove('active');
            document.getElementById(panelId).classList.add('active');
            btn.classList.add('active');
            document.getElementById('<%= hfActiveTab.ClientID %>').value = panelId;
        }

        // Modal open/close with pre-fill logic
        function openFormTypeModal() {
            var modal = document.getElementById('formTypeModal');
            modal.style.display = 'flex';

            var ddl = document.getElementById('<%= ddlFormTypeName.ClientID %>');
            var txtMain = document.getElementById('<%= txtModalMainType.ClientID %>');
            var hfSubs = document.getElementById('<%= hfModalSubTypes.ClientID %>');
            var container = document.getElementById('subtypesContainer');

            if (ddl && ddl.value !== "0") {
                // Pre-fill selected Form Type
                txtMain.value = ddl.options[ddl.selectedIndex].text;

                // Load existing sub-types from hidden field
                var subs = hfSubs.value ? hfSubs.value.split('|') : [];
                if (subs.length > 0) {
                    container.innerHTML = '';
                    for (var i = 0; i < subs.length; i++) {
                        var val = subs[i];
                        var count = i + 1;
                        var newId = 'txtSubType' + count;
                        var newDiv = document.createElement('div');
                        newDiv.className = 'subtype-input-group';
                        var showRemove = (subs.length > 1) ? 'inline-block' : 'none';
                        newDiv.innerHTML = '<input type="text" id="' + newId + '" name="' + newId + '" value="' + val + '" placeholder="Enter sub type" /><button type="button" class="btn-remove-subtype" onclick="removeSubtype(this)" style="display:' + showRemove + ';">✕</button>';
                        container.appendChild(newDiv);
                    }
                    subtypeCounter = subs.length + 1;
                } else {
                    resetModalInputs(txtMain, container);
                }
            } else {
                txtMain.value = '';
                resetModalInputs(txtMain, container);
            }
        }

        function resetModalInputs(txtMain, container) {
            subtypeCounter = 2;
            container.innerHTML = '<div class="subtype-input-group"><input type="text" id="<%= txtSubType1.ClientID %>" name="txtSubType1" placeholder="Enter sub type" /><button type="button" class="btn-remove-subtype" onclick="removeSubtype(this)" style="display:none;">✕</button></div>';
        }

        function closeFormTypeModal() {
            document.getElementById('formTypeModal').style.display = 'none';
        }

        function openToggleModal(tableName, id, itemName, currentStatus) {
            document.getElementById('<%= hfToggleTable.ClientID %>').value = tableName;
            document.getElementById('<%= hfToggleId.ClientID %>').value = id;
            document.getElementById('<%= hfToggleCurrentStatus.ClientID %>').value = currentStatus;
            document.getElementById('<%= txtToggleReason.ClientID %>').value = '';

            var action = (currentStatus == 1) ? 'Deactivate' : 'Activate';
            var icon = document.getElementById('modalIcon');
            icon.className = 'mmt-modal-icon ' + (currentStatus == 1 ? 'deactivate' : 'activate');
            icon.innerHTML = currentStatus == 1 ? '<i class="fas fa-toggle-off"></i>' : '<i class="fas fa-toggle-on"></i>';

            document.getElementById('modalTitle').innerText = action + ' Confirmation';
            document.getElementById('modalSubtitle').innerText = 'You are about to ' + action.toLowerCase() + ' "' + itemName + '" in ' + tableName;

            document.getElementById('toggleModal').style.display = 'flex';
        }

        function closeToggleModal() {
            document.getElementById('toggleModal').style.display = 'none';
        }

        // Subtype management
        var subtypeCounter = 2;

        function addSubtypeInput() {
            var container = document.getElementById('subtypesContainer');
            var newId = 'txtSubType' + subtypeCounter;
            var newDiv = document.createElement('div');
            newDiv.className = 'subtype-input-group';
            newDiv.innerHTML = '<input type="text" id="' + newId + '" name="' + newId + '" placeholder="Enter sub type" /><button type="button" class="btn-remove-subtype" onclick="removeSubtype(this)">✕</button>';
            container.appendChild(newDiv);
            subtypeCounter++;

            // Show remove button on first item if there are multiple
            var firstRemoveBtn = container.querySelector('.subtype-input-group:first-child .btn-remove-subtype');
            if (firstRemoveBtn && container.children.length > 1) {
                firstRemoveBtn.style.display = 'inline-block';
            }
        }

        function removeSubtype(btn) {
            var container = document.getElementById('subtypesContainer');
            if (container.children.length > 1) {
                btn.parentElement.remove();
                // Hide remove button on first item if only one left
                if (container.children.length === 1) {
                    var firstRemoveBtn = container.querySelector('.subtype-input-group:first-child .btn-remove-subtype');
                    if (firstRemoveBtn) firstRemoveBtn.style.display = 'none';
                }
            } else {
                alert('At least one sub type is required.');
            }
        }

        // Refund config functions (keep as is)
        function toggleRefundConfig(configId) {
            var configDiv = document.getElementById(configId);
            if (configDiv) {
                configDiv.style.display = configDiv.style.display === 'none' ? 'block' : 'none';
            }
        }

        var feeSourceMap = {
            'formFee': '<%= txtFormFee.ClientID %>',
            'entranceFee': '<%= txtEntranceFee.ClientID %>',
            'extraCharges': '<%= txtExtraCharges.ClientID %>'
        };
        var hiddenFieldMap = {
            'formFee': '<%= hfFormFeeRefundType.ClientID %>',
            'entranceFee': '<%= hfEntranceFeeRefundType.ClientID %>',
            'extraCharges': '<%= hfExtraChargesRefundType.ClientID %>'
        };
        var percentFieldMap = {
            'formFee': '<%= txtFormFeeRefundPercent.ClientID %>',
            'entranceFee': '<%= txtEntranceFeeRefundPercent.ClientID %>',
            'extraCharges': '<%= txtExtraChargesRefundPercent.ClientID %>'
        };
        var fixedFieldMap = {
            'formFee': '<%= txtFormFeeRefundFixed.ClientID %>',
            'entranceFee': '<%= txtEntranceFeeRefundFixed.ClientID %>',
            'extraCharges': '<%= txtExtraChargesRefundFixed.ClientID %>'
        };

        function switchRefundType(prefix, type) {
            var fixedDiv = document.getElementById(prefix + 'FixedDiv');
            var percentDiv = document.getElementById(prefix + 'PercentDiv');
            var calcDiv = document.getElementById(prefix + 'CalcDiv');
            var pillFixed = document.getElementById('pill' + capitalize(prefix) + 'Fixed');
            var pillPercent = document.getElementById('pill' + capitalize(prefix) + 'Percent');
            var hf = document.getElementById(hiddenFieldMap[prefix]);

            if (type === 'Fixed') {
                if (fixedDiv) fixedDiv.style.display = 'block';
                if (percentDiv) percentDiv.style.display = 'none';
                if (calcDiv) calcDiv.style.display = 'none';
                if (pillFixed) pillFixed.classList.add('active');
                if (pillPercent) pillPercent.classList.remove('active');
                var percentField = document.getElementById(percentFieldMap[prefix]);
                if (percentField) percentField.value = '';
            } else {
                if (fixedDiv) fixedDiv.style.display = 'none';
                if (percentDiv) percentDiv.style.display = 'block';
                if (calcDiv) calcDiv.style.display = 'block';
                if (pillFixed) pillFixed.classList.remove('active');
                if (pillPercent) pillPercent.classList.add('active');
                var fixedField = document.getElementById(fixedFieldMap[prefix]);
                if (fixedField) fixedField.value = '';
                calcRefundFromPercent(prefix);
            }
            if (hf) hf.value = type;
        }

        function calcRefundFromPercent(prefix) {
            var feeEl = document.getElementById(feeSourceMap[prefix]);
            var percentEl = document.getElementById(percentFieldMap[prefix]);
            var calcEl = document.getElementById(prefix + 'CalcAmount');
            var fixedEl = document.getElementById(fixedFieldMap[prefix]);
            if (!feeEl || !percentEl || !calcEl) return;

            var feeValue = parseFloat(feeEl.value) || 0;
            var pct = parseFloat(percentEl.value) || 0;
            var calculated = Math.round((feeValue * pct) / 100);
            calcEl.value = calculated.toLocaleString();
            if (fixedEl) fixedEl.value = calculated;
        }

        function capitalize(str) {
            return str.charAt(0).toUpperCase() + str.slice(1);
        }

        function toggleCustomMemberType(ddl) {
            if (!ddl) return;
            var customBox = ddl.nextElementSibling;
            if (customBox && customBox.tagName === 'INPUT') {
                if (ddl.value === 'Other') {
                    customBox.style.display = 'block';
                } else {
                    customBox.style.display = 'none';
                }
            }
        }

        function calculateTotal() {
            var fee = parseFloat(document.getElementById('<%= txtFormFee.ClientID %>').value) || 0;
            var entrance = parseFloat(document.getElementById('<%= txtEntranceFee.ClientID %>').value) || 0;
            var extra = parseFloat(document.getElementById('<%= txtExtraCharges.ClientID %>').value) || 0;
            var total = fee + entrance + extra;
            document.getElementById('<%= txtTotal.ClientID %>').value = total;
        }

        function applyTabState() {
            var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
            if (hf && hf.value) {
                var panels = document.querySelectorAll('.mmt-panel');
                for (var i = 0; i < panels.length; i++) panels[i].classList.remove('active');
                var tabs = document.querySelectorAll('.mmt-tab');
                for (var j = 0; j < tabs.length; j++) tabs[j].classList.remove('active');
                var targetPanel = document.getElementById(hf.value);
                if (targetPanel) targetPanel.classList.add('active');

                var mapping = { 'tabType': 0, 'tabForm': 1, 'tabCategory': 2 };
                if (mapping[hf.value] !== undefined && tabs[mapping[hf.value]])
                    tabs[mapping[hf.value]].classList.add('active');
            }
        }

        function restoreRefundTypeState() {
            var types = ['formFee', 'entranceFee', 'extraCharges'];
            for (var i = 0; i < types.length; i++) {
                var prefix = types[i];
                var hf = document.getElementById(hiddenFieldMap[prefix]);
                if (hf && hf.value === 'Percentage') {
                    switchRefundType(prefix, 'Percentage');
                    var radios = document.getElementsByName(prefix + 'RefType');
                    for (var r = 0; r < radios.length; r++) {
                        if (radios[r].value === 'Percentage') radios[r].checked = true;
                        else radios[r].checked = false;
                    }
                }
            }
            var chkFormFee = document.getElementById('<%= chkRefFormFee.ClientID %>');
            var chkEntFee = document.getElementById('<%= chkRefEntranceFee.ClientID %>');
            var chkExtChg = document.getElementById('<%= chkRefExtraCharges.ClientID %>');
            if (chkFormFee && chkFormFee.checked) document.getElementById('formFeeConfig').style.display = 'block';
            if (chkEntFee && chkEntFee.checked) document.getElementById('entranceFeeConfig').style.display = 'block';
            if (chkExtChg && chkExtChg.checked) document.getElementById('extraChargesConfig').style.display = 'block';
        }

        window.addEventListener('load', function () {
            applyTabState();
            restoreRefundTypeState();
        });

        if (typeof Sys !== 'undefined') {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                applyTabState();
                restoreRefundTypeState();
                closeToggleModal();
            });
        }
    </script>
</asp:Content>