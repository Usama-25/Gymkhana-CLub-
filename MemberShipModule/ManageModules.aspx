<%@ Page Title="Manage Modules" Language="C#" MasterPageFile="~/MemberShipModule/Site.master"
    AutoEventWireup="true" CodeFile="ManageModules.aspx.cs" Inherits="ManageModules" %>
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
            .mgmt-page h2 i { margin-right: 8px; }

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
                min-width: 130px;
            }

            .form-group label {
                font-size: .75rem;
                font-weight: 600;
                color: #64748b;
                text-transform: uppercase;
                letter-spacing: .3px;
            }

            .form-group input,
            .form-group select {
                padding: 7px 10px;
                border: 1px solid #d1d5db;
                border-radius: 6px;
                font-size: .88rem;
            }

            .form-group input:focus,
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

            .btn-danger {
                background: #ef4444;
                color: #fff;
                border: none;
                padding: 5px 12px;
                border-radius: 5px;
                font-weight: 600;
                cursor: pointer;
                font-size: .78rem;
            }

            .btn-edit {
                background: #f59e0b;
                color: #fff;
                border: none;
                padding: 5px 12px;
                border-radius: 5px;
                font-weight: 600;
                cursor: pointer;
                font-size: .78rem;
            }

            .grid-table {
                width: 100%;
                border-collapse: collapse;
            }

            .grid-table th {
                background: #f1f5f9;
                color: #475569;
                font-size: .75rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: .4px;
                padding: 8px 10px;
                border-bottom: 2px solid #e2e8f0;
                text-align: left;
            }

            .grid-table td {
                padding: 7px 10px;
                border-bottom: 1px solid #f1f5f9;
                font-size: .85rem;
                color: #334155;
            }

            .grid-table tr:hover td {
                background: #fafbfc;
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

            .status-active {
                background: #dcfce7;
                color: #166534;
                padding: 3px 10px;
                border-radius: 12px;
                font-size: .72rem;
                font-weight: 600;
            }

            .status-inactive {
                background: #fee2e2;
                color: #991b1b;
                padding: 3px 10px;
                border-radius: 12px;
                font-size: .72rem;
                font-weight: 600;
            }
        </style>

        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <div class="mgmt-page">
                    <h2><i class="fas fa-cubes"></i> Manage Modules</h2>

                    <asp:Label ID="lblMessage" runat="server" Visible="false" />

                    <div class="form-card">
                        <asp:HiddenField ID="hfModuleId" runat="server" Value="0" />
                        <div class="form-row">
                            <div class="form-group">
                                <label>Module Name</label>
                                <asp:TextBox ID="txtModuleName" runat="server" placeholder="e.g. Finance" />
                            </div>
                            <div class="form-group">
                                <label>Icon Class</label>
                                <asp:TextBox ID="txtIconClass" runat="server" placeholder="fas fa-cog" />
                            </div>
                            <div class="form-group">
                                <label>Order</label>
                                <asp:TextBox ID="txtSortOrder" runat="server" TextMode="Number" Text="0" />
                            </div>
                            <div class="form-group">
                                <label>Active</label>
                                <asp:DropDownList ID="ddlIsActive" runat="server">
                                    <asp:ListItem Text="Yes" Value="1" />
                                    <asp:ListItem Text="No" Value="0" />
                                </asp:DropDownList>
                            </div>
                            <div>
                                <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn-primary"
                                    OnClick="btnSave_Click"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #2563eb, #3b82f6); color: white; box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2);" />
                                <asp:Button ID="btnCancel" runat="server" Text="Clear" CssClass="btn-edit"
                                    OnClick="btnCancel_Click" />
                            </div>
                        </div>
                    </div>

                    <div class="form-card">
                        <asp:GridView ID="gvModules" runat="server" AutoGenerateColumns="false" CssClass="grid-table"
                            DataKeyNames="ModuleId" OnRowCommand="gvModules_RowCommand"
                            EmptyDataText="No modules found.">
                            <Columns>
                                <asp:BoundField DataField="ModuleId" HeaderText="ID" />
                                <asp:BoundField DataField="ModuleName" HeaderText="Module Name" />
                                <asp:BoundField DataField="IconClass" HeaderText="Icon" />
                                <asp:BoundField DataField="SortOrder" HeaderText="Order" />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <span
                                            class='<%# Convert.ToBoolean(Eval("IsActive")) ? "status-active" : "status-inactive" %>'>
                                            <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Pages">
                                    <ItemTemplate>
                                        <%# Eval("PageCount") %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Actions">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditModule"
                                            CommandArgument='<%# Eval("ModuleId") %>' CssClass="btn-edit" Text="Edit" />
                                        <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteModule"
                                            CommandArgument='<%# Eval("ModuleId") %>' CssClass="btn-danger"
                                            Text="Delete"
                                            OnClientClick="return confirm('Delete this module and all its pages?');" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </asp:Content>










