<%@ Page Title="Manage Dynamic Fields" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true" CodeFile="ManageDynamicFields.aspx.cs" Inherits="ManageDynamicFields" %>

<asp:Content ID="HeadStyles" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .mmt-page { width: 98%; margin: 0 auto; padding: 10px 0; }
        .mmt-page-header { display: flex; align-items: center; gap: 14px; margin-bottom: 8px; padding-bottom: 20px; border-bottom: 1px solid #f1f5f9; }
        .mmt-page-header .icon-wrap { width: 52px; height: 52px; background: linear-gradient(135deg, #10b981, #059669); border-radius: 14px; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 1.4rem; flex-shrink: 0; box-shadow: 0 4px 12px rgba(16, 185, 129, 0.2); }
        .mmt-page-header h1 { font-size: 1.6rem; font-weight: 800; color: #0f172a; margin: 0; letter-spacing: -0.5px; }
        .mmt-page-header p { color: #64748b; margin: 4px 0 0; font-size: 0.8rem; }
        
        .mmt-card { background: #fff; border-radius: 12px; padding: 14px 18px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); border: 1px solid #e2e8f0; margin-bottom: 8px; transition: border-color 0.2s; }
        .mmt-card:hover { border-color: #cbd5e1; }
        .mmt-card-title { font-size: 0.95rem; font-weight: 700; color: #0f172a; margin: 0 0 14px; display: flex; align-items: center; gap: 8px; border-bottom: 1px solid #f1f5f9; padding-bottom: 8px; }
        .mmt-card-title i { color: #10b981; }

        .mmt-form-row { display: flex; gap: 12px; align-items: flex-start; flex-wrap: wrap; margin-bottom: 10px; }
        .mmt-form-group { display: flex; flex-direction: column; flex: 1; min-width: 150px; }
        .mmt-form-group label { font-size: 0.68rem; font-weight: 700; color: #475569; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px; }
        .mmt-form-group input, .mmt-form-group select, .mmt-form-group textarea { padding: 6px 10px; border: 1px solid #e2e8f0; border-radius: 6px; font-size: 0.85rem; color: #0f172a; background: #fff; transition: all 0.2s; height: 32px; font-family: inherit; }
        .mmt-form-group textarea { height: auto; resize: vertical; }
        .mmt-form-group input:focus, .mmt-form-group select:focus, .mmt-form-group textarea:focus { border-color: #10b981; outline: none; box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1); }
        .mmt-form-group input[readonly] { background-color: #f8fafc; cursor: not-allowed; color: #64748b; }
        
        .mmt-flex-container { display: flex; flex-direction: row; gap: 16px; align-items: stretch; flex-wrap: wrap; }
        .mmt-flex-35 { width: calc(35% - 8px); }
        .mmt-flex-65 { width: calc(65% - 8px); }

        .mmt-btn-add { background: linear-gradient(135deg, #10b981, #059669); color: #fff; border: none; padding: 8px 18px; border-radius: 6px; font-weight: 600; font-size: 0.85rem; cursor: pointer; display: inline-flex; align-items: center; gap: 10px; transition: all 0.2s; box-shadow: 0 4px 12px rgba(16, 185, 129, 0.25); }
        .mmt-btn-add:hover { box-shadow: 0 6px 16px rgba(16, 185, 129, 0.35); transform: translateY(-1.5px); }
        .mmt-btn-cancel { background: #fff; color: #64748b; border: 1px solid #e2e8f0; padding: 8px 18px; border-radius: 6px; font-weight: 600; font-size: 0.85rem; cursor: pointer; transition: all 0.2s; }
        .mmt-btn-cancel:hover { background: #f8fafc; color: #0f172a; border-color: #cbd5e1; }

        .mmt-msg-success { display: block; padding: 12px 16px; background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; border-radius: 8px; margin-bottom: 12px; font-size: 0.85rem; font-weight: 600; display: flex; align-items: center; gap: 8px; }
        .mmt-msg-error { display: block; padding: 12px 16px; background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; border-radius: 8px; margin-bottom: 12px; font-size: 0.85rem; font-weight: 600; display: flex; align-items: center; gap: 8px; }

        .mmt-grid { width: 100%; border-collapse: separate; border-spacing: 0; border-radius: 12px; overflow: hidden; border: 1px solid #f1f5f9; }
        .mmt-grid th { background: #f8fafc; color: #475569; font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; padding: 8px 10px; border-bottom: 2px solid #f1f5f9; text-align: left; }
        .mmt-grid td { padding: 8px 10px; border-bottom: 1px solid #f1f5f9; font-size: 0.8rem; color: #334155; }
        .mmt-grid tr:last-child td { border-bottom: none; }
        .mmt-grid tr:hover td { background: #fcfdfe; }

        @media (max-width: 768px) {
            .mmt-flex-35, .mmt-flex-65 { width: 100%; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="mmt-page">
        <!-- Header -->
        <div class="mmt-page-header">
            <div class="icon-wrap">
                <i class="fas fa-layer-group"></i>
            </div>
            <div>
                <h1>Manage Dynamic Fields</h1>
                <p>Create new custom fields (Textbox, Dropdown, Checkbox, etc.) and seamlessly inject them as columns into your database tables.</p>
            </div>
        </div>

        <asp:UpdatePanel ID="upDynamic" runat="server">
            <ContentTemplate>
                <asp:Label ID="lblMsg" runat="server" Visible="false" />
                
                <div class="mmt-flex-container">
                    <!-- Left Side: Add Field (35%) -->
                    <div class="mmt-flex-35">
                        <div class="mmt-card">
                            <div class="mmt-card-title"><i class="fas fa-plus-circle"></i> Create New Field</div>
                            
                            <div class="mmt-form-row">
                                <div class="mmt-form-group" style="flex: 100%;">
                                    <label>Target Database Table <span style="color:#ef4444;">*</span></label>
                                    <asp:DropDownList ID="ddlTableName" runat="server"></asp:DropDownList>
                                    <small style="color:#64748b; font-size:0.65rem; margin-top:4px;">Select the table where you want to add the column.</small>
                                </div>
                            </div>
                            
                            <div class="mmt-form-row">
                                <div class="mmt-form-group">
                                    <label>Field Display Label <span style="color:#ef4444;">*</span></label>
                                    <asp:TextBox ID="txtFieldLabel" runat="server" placeholder="e.g. Identity Number" onkeyup="autoFillFieldName()" />
                                </div>
                            </div>

                            <div class="mmt-form-row">
                                <div class="mmt-form-group">
                                    <label>Database Column Name <span style="color:#ef4444;">*</span></label>
                                    <asp:TextBox ID="txtFieldName" runat="server" placeholder="e.g. IdentityNumber" />
                                    <small style="color:#64748b; font-size:0.65rem; margin-top:4px;">No spaces allowed. This is the physical SQL column name.</small>
                                </div>
                            </div>

                            <div class="mmt-form-row">
                                <div class="mmt-form-group" style="flex: 100%;">
                                    <label>Field Data Type <span style="color:#ef4444;">*</span></label>
                                    <asp:DropDownList ID="ddlFieldType" runat="server" onchange="toggleOptions()">
                                        <asp:ListItem Text="Textbox (Single Line)" Value="Text" />
                                        <asp:ListItem Text="Textbox (Multi-line)" Value="Multiline" />
                                        <asp:ListItem Text="Dropdown List" Value="Dropdown" />
                                        <asp:ListItem Text="Checkbox (Yes/No)" Value="Checkbox" />
                                        <asp:ListItem Text="Date Picker" Value="Date" />
                                        <asp:ListItem Text="Number (Decimal)" Value="Number" />
                                    </asp:DropDownList>
                                </div>
                            </div>

                            <div class="mmt-form-row" id="rowOptions" style="display:none;">
                                <div class="mmt-form-group" style="flex: 100%;">
                                    <label>Dropdown Options <span style="color:#ef4444;">*</span></label>
                                    <asp:TextBox ID="txtFieldOptions" runat="server" TextMode="MultiLine" Rows="3" placeholder="Enter comma-separated options (e.g. Option A, Option B, Option C)" />
                                </div>
                            </div>

                            <div style="display:flex; gap:10px; justify-content: flex-end; margin-top: 20px;">
                                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="mmt-btn-cancel" OnClick="btnClear_Click" />
                                <asp:Button ID="btnSave" runat="server" Text="Inject Column" CssClass="mmt-btn-add" OnClientClick="return confirm('Are you sure you want to ALTER the database schema and inject this column? This action cannot be easily undone.');" OnClick="btnSave_Click" />
                            </div>
                        </div>
                    </div>

                    <!-- Right Side: Existing Fields List (65%) -->
                    <div class="mmt-flex-65">
                        <div class="mmt-card" style="height: 100%;">
                            <div class="mmt-card-title"><i class="fas fa-list"></i> Dynamically Created Fields Directory</div>
                            <div style="overflow-x: auto;">
                                <asp:GridView ID="gvFields" runat="server" AutoGenerateColumns="false" CssClass="mmt-grid" EmptyDataText="No dynamic fields found. Once you create a column, it will be logged here.">
                                    <Columns>
                                        <asp:TemplateField ItemStyle-Width="40px">
                                            <HeaderTemplate>Sr.</HeaderTemplate>
                                            <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Table Name">
                                            <ItemTemplate><span style="font-weight: 600; color: #0f172a;"><%# Eval("TableName") %></span></ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Label">
                                            <ItemTemplate><%# Eval("FieldLabel") %></ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="DB Column">
                                            <ItemTemplate><span style="color: #059669; font-family: monospace; font-size: 0.75rem; background: #ecfdf5; padding: 2px 6px; border-radius: 4px; border: 1px solid #d1fae5;"><%# Eval("FieldName") %></span></ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Type">
                                            <ItemTemplate>
                                                <span style="background: #f1f5f9; padding: 2px 8px; border-radius: 4px; border: 1px solid #e2e8f0; font-size: 0.75rem;">
                                                    <%# Eval("FieldType") %>
                                                </span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Status" ItemStyle-Width="60px">
                                            <ItemTemplate>
                                                <span style='<%# "background:" + (Convert.ToInt32(Eval("IsActive")) == 1 ? "#dcfce7; color: #15803d; border: 1px solid #bbf7d0;" : "#fee2e2; color: #b91c1c; border: 1px solid #fecaca;") + " padding: 4px 12px; border-radius: 20px; font-size: 0.7rem; font-weight: 700; display: inline-block; white-space: nowrap;" %>'>
                                                    <%# Convert.ToInt32(Eval("IsActive")) == 1 ? "Active" : "Inactive" %>
                                                </span>
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

    <script type="text/javascript">
        function toggleOptions() {
            var ddl = document.getElementById('<%= ddlFieldType.ClientID %>');
            var rowOptions = document.getElementById('rowOptions');
            if (ddl && rowOptions) {
                if (ddl.value === 'Dropdown') {
                    rowOptions.style.display = 'flex';
                } else {
                    rowOptions.style.display = 'none';
                }
            }
        }

        function autoFillFieldName() {
            var label = document.getElementById('<%= txtFieldLabel.ClientID %>').value;
            var nameField = document.getElementById('<%= txtFieldName.ClientID %>');
            // Dynamically strip spaces and special chars to create a safe SQL column name
            nameField.value = label.replace(/[^a-zA-Z0-9]/g, '');
        }

        // Initialize on normal page load
        window.addEventListener('load', toggleOptions);

        // Re-initialize after UpdatePanel partial postbacks
        if (typeof Sys !== 'undefined') {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                toggleOptions();
            });
        }
    </script>
</asp:Content>
