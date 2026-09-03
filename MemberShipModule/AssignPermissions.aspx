<%@ Page Title="Assign Permissions" Language="C#" MasterPageFile="~/MemberShipModule/Site.master"
    AutoEventWireup="true" CodeFile="AssignPermissions.aspx.cs" Inherits="AssignPermissions" %>
    <asp:Content ID="HeadStyles" ContentPlaceHolderID="HeadContent" runat="server">
        <style>
            /* Essential Styles (Self-contained for server deployments) */
            .table-container { background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
            .table { width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left; }
            .table th { background: #f8fafc; color: #334155; font-weight: 600; padding: 0.75rem 1rem; border-bottom: 2px solid #e2e8f0; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.05em; }
            .table td { padding: 0.75rem 1rem; border-bottom: 1px solid #e2e8f0; color: #0f172a; vertical-align: middle; }
            .table tr:last-child td { border-bottom: none; }
            .empty-state { padding: 2rem; text-align: center; color: #94a3b8; background-color: #f8fafc; border: 1px dashed #e2e8f0; border-radius: 12px; display: flex; flex-direction: column; align-items: center; gap: 0.75rem; margin-top: 1rem; }
            .empty-state svg { color: #94a3b8; opacity: 0.6; margin-bottom: 0.5rem; }
            .table-input { width: 100%; padding: 0.5rem 0.75rem; border: 1px solid transparent; border-radius: 6px; background: transparent; font-size: 0.95rem; color: #0f172a; transition: all 0.2s ease; }
            .table-input:hover { background: #f1f5f9; border-color: #e2e8f0; }
            .table-input:focus { background: #ffffff; border-color: #3b82f6; box-shadow: 0 0 0 2px #dbeafe; outline: none; }
            .form-control { display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #0f172a; background-color: white; border: 1px solid #cbd5e1; border-radius: 6px; }
            .form-control:focus { border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15); outline: none; }
            
            /* Button Styles */
            .btn { display: inline-block; text-align: center; vertical-align: middle; padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: all 0.15s ease; border: 1px solid transparent; line-height: 1; }
            .btn-primary { background: linear-gradient(135deg, #2563eb, #3b82f6); color: white; box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2); }
            .btn-primary:hover { box-shadow: 0 8px 12px rgba(37, 99, 235, 0.3); transform: translateY(-1px); }
            .btn-secondary { background-color: white; color: #334155; border-color: #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
            .btn-secondary:hover { background-color: #f1f5f9; border-color: #cbd5e1; color: #0f172a; }
            .btn-success { background-color: #10b981; color: white; border-color: #10b981; border: 1px solid #10b981; }
            .btn-danger { background-color: #ef4444; color: white; border-color: #ef4444; border: 1px solid #ef4444; }
            .btn-warning { background-color: #f59e0b; color: white; border-color: #f59e0b; border: 1px solid #f59e0b; }
            .btn-info { background-color: #3b82f6; color: white; border-color: #3b82f6; border: 1px solid #3b82f6; }
            .btn-sm { padding: 0.4rem 0.8rem; font-size: 0.875rem; }
            .btn-sm.flex { display: inline-flex; align-items: center; justify-content: center; }
        </style>
    <style>
        h1, h2, h3, h4, h5, h6 { color: #0f172a; line-height: 1.25; }
        h1 { font-size: 2rem; font-weight: 800; letter-spacing: -0.03em; margin-bottom: 1.5rem; }
        h2 { font-size: 1.5rem; font-weight: 700; letter-spacing: -0.025em; margin: 0; }
        h3 { font-size: 1.25rem; font-weight: 600; margin-bottom: 1rem; }
        p { color: #475569; margin-bottom: 1rem; max-width: 100%; }
        .form-section { margin-bottom: 1rem; background: #ffffff; border-radius: 12px; padding: 1rem; border: 1px solid #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
        .section-header { display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem; padding-bottom: 0.5rem; border-bottom: 1px solid #e2e8f0; }
        .section-icon { width: 40px; height: 40px; background: transparent; color: #2563eb; display: flex; align-items: center; justify-content: center; }
        .section-icon svg { color: #2563eb; fill: none !important; stroke: currentColor; stroke-width: 2; }
        .section-title { font-size: 1.15rem; font-weight: 700; margin: 0; color: #0f172a; }
        .section-subtitle { font-size: 0.875rem; color: #475569; margin: 0; }
        .full-width { grid-column: 1 / -1; }
        .form-grid { width: 100%; }
        .card { background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); transition: none; position: relative; overflow: hidden; height: 100%; }
        .card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; padding-bottom: 0.75rem; border-bottom: 1px solid #e2e8f0; }
        .card-title { font-size: 1.15rem; font-weight: 700; color: #0f172a; }
        .card-actions { display: flex; gap: 0.5rem; }
        .btn { display: inline-block; text-align: center; vertical-align: middle; padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: all 0.15s ease; border: 1px solid transparent; line-height: 1; }
        .btn-primary { background: linear-gradient(135deg, #2563eb, #3b82f6); color: white; box-shadow: 0 4px 6px rgba(37,99,235,0.2); }
        .btn-primary:hover { box-shadow: 0 8px 12px rgba(37,99,235,0.3); transform: translateY(-1px); }
        .btn-secondary { background-color: white; color: #334155; border-color: #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
        .btn-secondary:hover { background-color: #f1f5f9; border-color: #cbd5e1; color: #0f172a; }
        .btn-success { background-color: #10b981; color: white; border: 1px solid #10b981; }
        .btn-danger { background-color: #ef4444; color: white; border: 1px solid #ef4444; }
        .btn-warning { background-color: #f59e0b; color: white; border: 1px solid #f59e0b; }
        .btn-info { background-color: #3b82f6; color: white; border: 1px solid #3b82f6; }
        .btn-group { display: flex; gap: 1rem; margin-top: 1.5rem; padding-top: 0.5rem; }
        .grid-responsive { display: grid; grid-template-columns: repeat(1, 1fr); gap: 1.5rem; }
        @media (min-width: 640px) { .grid-responsive { grid-template-columns: repeat(2, 1fr); } }
        @media (min-width: 1024px) { .grid-responsive { grid-template-columns: repeat(4, 1fr); } }
        @media (min-width: 1400px) { .grid-responsive { grid-template-columns: repeat(5, 1fr); } }
        .form-control { display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out; }
        .form-control:focus { color: #0f172a; background-color: white; border-color: #2563eb; outline: 0; box-shadow: 0 0 0 3px rgba(37,99,235,0.15); }
        .empty-state { padding: 2rem; text-align: center; color: #94a3b8; background-color: #f8fafc; border: 1px dashed #e2e8f0; border-radius: 12px; font-size: 0.95rem; margin-top: 1rem; display: flex; flex-direction: column; align-items: center; gap: 0.75rem; }
        .table-container { background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
        .table { width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left; }
        .table th { background: #f8fafc; color: #334155; font-weight: 600; padding: 0.75rem 1rem; border-bottom: 2px solid #e2e8f0; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.05em; }
        .table td { padding: 0.75rem 1rem; border-bottom: 1px solid #e2e8f0; color: #0f172a; vertical-align: middle; }
        .badge { display: inline-flex; align-items: center; padding: 0.35rem 0.75rem; border-radius: 99px; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; }
        .badge-success { background-color: #d1fae5; color: #10b981; }
        .badge-warning { background-color: #fef3c7; color: #f59e0b; }
        .badge-danger { background-color: #fee2e2; color: #ef4444; }
        .badge-info { background-color: #dbeafe; color: #3b82f6; }
        .grid-2, .grid-3, .grid-4 { display: grid; gap: 1.5rem; }
        .grid-2 { grid-template-columns: repeat(2, 1fr); }
        .grid-3 { grid-template-columns: repeat(3, 1fr); }
        .grid-4 { grid-template-columns: repeat(4, 1fr); }
        @media (max-width: 1024px) { .grid-3, .grid-4 { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 768px) { .grid-2, .grid-3, .grid-4 { grid-template-columns: 1fr; } }
        .p-2 { padding: 0.5rem; } .p-4 { padding: 1rem; } .p-6 { padding: 1.5rem; } .p-8 { padding: 2rem; }
        .m-0 { margin: 0; } .mb-1 { margin-bottom: 0.25rem !important; } .mb-2 { margin-bottom: 0.5rem; } .mb-4 { margin-bottom: 1rem; }
        .mb-6 { margin-bottom: 1.5rem !important; } .mb-8 { margin-bottom: 2rem !important; }
        .mt-1 { margin-top: 0.25rem !important; } .mt-2 { margin-top: 0.5rem !important; }
        .mt-4 { margin-top: 0.5rem; } .mt-6 { margin-top: 0.75rem; } .mt-8 { margin-top: 1rem; }
        .gap-2 { gap: 0.5rem; } .gap-4 { gap: 1rem; } .gap-6 { gap: 2rem; }
        .pb-4 { padding-bottom: 1rem !important; } .pb-6 { padding-bottom: 1.5rem !important; } .pt-6 { padding-top: 1.5rem !important; }
        .flex { display: flex; } .flex-col { flex-direction: column; } .items-center { align-items: center; }
        .justify-between { justify-content: space-between; } .justify-end { justify-content: flex-end !important; }
        .justify-center { justify-content: center !important; } .flex-wrap { flex-wrap: wrap !important; } .flex-1 { flex: 1; }
        .w-full { width: 100%; } .h-full { height: 100%; }
        .hidden { display: none !important; } .border { border: 1px solid #e2e8f0; } .border-b { border-bottom: 1px solid #e2e8f0; }
        .border-subtle { border-color: #e2e8f0 !important; } .shadow-none { box-shadow: none !important; }
        .text-lg { font-size: 1.125rem; line-height: 1.75rem; } .text-sm { font-size: 0.875rem; line-height: 1.25rem; }
        .text-2xl { font-size: 1.5rem !important; } .text-3xl { font-size: 1.875rem !important; line-height: 2.25rem !important; }
        .font-bold { font-weight: 700; } .text-primary-900 { color: #0f172a !important; } .text-secondary { color: #475569 !important; }
        .text-gray-800 { color: #1e293b !important; } .text-gray-500 { color: #64748b !important; } .text-yellow-500 { color: #eab308 !important; }
        .block { display: block !important; } .text-center { text-align: center !important; }
        .bg-blue-50 { background-color: #eff6ff !important; } .min-w-200 { min-width: 200px !important; }
        .status-message { font-size: 0.875rem; color: #64748b; margin-top: 0.5rem; display: block; }
        .whitespace-nowrap { white-space: nowrap !important; }
    </style>
    </asp:Content>


    <asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
        <style>
            .mgmt-page {
                width: 98%;
                margin: 0 auto;
                padding: 10px 0;
            }

            .mgmt-page h2 {
                font-size: 1.4rem;
                font-weight: 700;
                color: #1e293b;
                margin: 0 0 12px 0;
                display: flex;
                align-items: center;
            }
            .mgmt-page h2 i {
                margin-right: 8px;
            }

            .mgmt-page h2 i {
                color: #6366f1;
            }

            .form-card {
                background: #fff;
                border-radius: 8px;
                padding: 14px 16px;
                box-shadow: 0 1px 6px rgba(0, 0, 0, .05);
                margin-bottom: 12px;
            }

            .form-row {
                display: flex;
                gap: 12px;
                align-items: flex-end;
            }

            .form-group {
                display: flex;
                flex-direction: column;
                flex: 1;
                min-width: 200px;
            }

            .form-group label {
                font-size: .75rem;
                font-weight: 600;
                color: #64748b;
                text-transform: uppercase;
                letter-spacing: .3px;
            }

            .form-group select {
                padding: 7px 10px;
                border: 1px solid #d1d5db;
                border-radius: 6px;
                font-size: .88rem;
                display: block;
                width: 100%;
            }

            .form-group select:focus {
                border-color: #6366f1;
                outline: none;
                box-shadow: 0 0 0 2px rgba(99, 102, 241, .12);
            }

            .btn-primary {
                background: linear-gradient(135deg, #6366f1, #4f46e5);
                color: #fff;
                border: none;
                padding: 7px 18px;
                border-radius: 6px;
                font-weight: 600;
                cursor: pointer;
                font-size: .85rem;
                display: flex;
                align-items: center;
                gap: 6px;
                white-space: nowrap;
            }

            .btn-primary:hover {
                box-shadow: 0 3px 10px rgba(99, 102, 241, .3);
            }

            .btn-select {
                background: #10b981;
                color: #fff;
                border: none;
                padding: 5px 12px;
                border-radius: 5px;
                font-weight: 600;
                cursor: pointer;
                font-size: .78rem;
            }

            .btn-deselect {
                background: #6b7280;
                color: #fff;
                border: none;
                padding: 5px 12px;
                border-radius: 5px;
                font-weight: 600;
                cursor: pointer;
                font-size: .78rem;
            }

            .msg-success {
                background: #ecfdf5;
                color: #065f46;
                padding: 8px 14px;
                border-radius: 6px;
                border-left: 3px solid #10b981;
                margin-bottom: 10px;
                font-weight: 500;
                font-size: .85rem;
            }

            .msg-error {
                background: #fef2f2;
                color: #991b1b;
                padding: 8px 14px;
                border-radius: 6px;
                border-left: 3px solid #ef4444;
                margin-bottom: 10px;
                font-weight: 500;
                font-size: .85rem;
            }

            .module-section {
                margin-bottom: 8px;
            }

            .module-header {
                background: linear-gradient(135deg, #eef2ff, #e0e7ff);
                padding: 8px 14px;
                border-radius: 6px 6px 0 0;
                font-weight: 700;
                color: #3730a3;
                font-size: .88rem;
                display: flex;
                align-items: center;
                border-bottom: 2px solid #c7d2fe;
            }
            .module-header i { margin-right: 8px; }

            .module-header i {
                font-size: .95rem;
            }

            .page-list {
                background: #fff;
                border: 1px solid #e2e8f0;
                border-top: none;
                border-radius: 0 0 6px 6px;
            }

            .page-item {
                display: block;
                padding: 6px 14px;
                -webkit-transition: background .12s;
                -moz-transition: background .12s;
                transition: background .12s;
            }
            .page-item:after { content: ""; display: table; clear: both; }
            .page-item input[type=checkbox] { float: left; margin-top: 2px; margin-right: 8px; }
            .page-item label { float: left; cursor: pointer; }
            .page-item .page-url { float: right; }

            .page-item:hover {
                background: #fafbfc;
            }

            .page-item input[type=checkbox] {
                width: 16px;
                height: 16px;
                accent-color: #6366f1;
                cursor: pointer;
            }

            .page-item label {
                font-size: .85rem;
                color: #334155;
                cursor: pointer;
                flex: 1;
            }

            .page-item .page-url {
                font-size: .72rem;
                color: #94a3b8;
            }

            .emp-info {
                background: #f0fdf4;
                border: 1px solid #bbf7d0;
                -webkit-border-radius: 6px;
                -moz-border-radius: 6px;
                border-radius: 6px;
                padding: 10px 14px;
                margin-bottom: 10px;
                display: block;
            }
            .emp-info:after { content: ""; display: table; clear: both; }
            .emp-info-item { float: left; margin-right: 20px; }

            .emp-info-item {
                font-size: .82rem;
                color: #334155;
            }

            .emp-info-item strong {
                color: #166534;
            }
        </style>


        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <div class="mgmt-page">
                    <h2><i class="fas fa-user-shield"></i> Assign Page Permissions</h2>

                    <asp:Label ID="lblMessage" runat="server" Visible="false" />

                    <div class="form-card">
                        <div class="form-row">
                            <div class="form-group">
                                <label>Select Employee</label>
                                <asp:DropDownList ID="ddlEmployee" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlEmployee_SelectedIndexChanged" />
                            </div>
                        </div>
                    </div>

                    <asp:Panel ID="pnlPermissions" runat="server" Visible="false">
                        <div class="emp-info">
                            <div class="emp-info-item"><strong>Employee:</strong>
                                <asp:Label ID="lblEmpName" runat="server" />
                            </div>
                            <div class="emp-info-item"><strong>Department:</strong>
                                <asp:Label ID="lblDept" runat="server" />
                            </div>
                            <div class="emp-info-item"><strong>Role:</strong>
                                <asp:Label ID="lblRole" runat="server" />
                            </div>
                        </div>


                        <div>
                            <asp:Button ID="btnSelectAll" runat="server" Text="Select All" CssClass="btn-select"
                                OnClick="btnSelectAll_Click" />
                            <asp:Button ID="btnDeselectAll" runat="server" Text="Deselect All" CssClass="btn-deselect"
                                OnClick="btnDeselectAll_Click" />
                        </div>

                        <asp:Repeater ID="rptModules" runat="server" OnItemDataBound="rptModules_ItemDataBound">
                            <ItemTemplate>
                                <div class="module-section">
                                    <div class="module-header">
                                        <i class="fas fa-folder"></i>
                                       <h3 class="module-title"><%# Eval("ModuleName") %></h3>
                                    </div>
                                    <div class="page-list">
                                        <asp:Repeater ID="rptPages" runat="server">
                                            <ItemTemplate>
                                                <div class="page-item">
                                                    <asp:CheckBox ID="chkPage" runat="server"
                                                        Checked='<%# Convert.ToBoolean(Eval("IsGranted")) %>' />
                                                    <asp:HiddenField ID="hfPageId" runat="server"
                                                        Value='<%# Eval("Page_ID") %>' />
                                                    <label>
                                                        <span><%# Eval("PageTitle") %></span>
                                                    </label>
                                                    <span class="page-url">
                                                        <%# Eval("Page_URL") %>
                                                    </span>
                                                </div>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>

                        <div>
                            <asp:Button ID="btnSavePermissions" runat="server" Text="Save Permissions"
                                CssClass="btn-primary" OnClick="btnSavePermissions_Click"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #2563eb, #3b82f6); color: white; box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2);" />
                        </div>
                    </asp:Panel>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </asp:Content>









