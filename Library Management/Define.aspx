<%@ Page Language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" AutoEventWireup="true"
         CodeFile="Define.aspx.cs" Inherits="Pages_System_Define"
         Title="Define Lookups - Lahore Gymkhana Library" %>

<asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        .grid-header {
            background-color: #0f1e36;
            color: #ffffff;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 11px;
            letter-spacing: 0.5px;
        }
        .grid-row {
            background-color: #ffffff;
            border-bottom: 1px solid #e2e8f0;
            transition: background-color 0.2s ease;
        }
        .grid-row:hover {
            background-color: #f8fafc;
        }
        .grid-alt-row {
            background-color: #f8fafc;
            border-bottom: 1px solid #e2e8f0;
            transition: background-color 0.2s ease;
        }
        .grid-alt-row:hover {
            background-color: #f1f5f9;
        }
        .badge-active {
            background-color: #d1fae5;
            color: #065f46;
            padding: 4px 8px;
            border-radius: 9999px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }
        .badge-inactive {
            background-color: #fee2e2;
            color: #991b1b;
            padding: 4px 8px;
            border-radius: 9999px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }
        .cell-left {
            padding: 10px 12px !important;
            text-align: left;
        }
        .cell-center {
            padding: 10px 12px !important;
            text-align: center;
        }
        .cell-right {
            padding: 10px 12px !important;
            text-align: right;
        }
        .col-id {
            padding: 10px 12px !important;
            font-size: 13px;
            font-weight: 600;
            width: 50px;
            text-align: left;
        }
        .col-name {
            padding: 10px 12px !important;
            font-size: 13px;
            font-weight: 500;
            color: #0f1e36;
            text-align: left;
        }
        .col-status {
            padding: 10px 12px !important;
            text-align: center;
            width: 80px;
        }
        .col-actions {
            padding: 10px 12px !important;
            text-align: center;
            width: 80px;
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
    </style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">

<!-- Header -->
<div style="background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; padding: 20px 28px; border-radius: 8px; margin-bottom: 24px; border-bottom: 3px solid #c5a059; display: flex; justify-content: space-between; align-items: center; width: 100%; box-sizing: border-box;">
    <div style="display: block;">
        <h2 style="margin: 0; font-size: 22px; font-weight: 600;">Define Library Settings</h2>
        <p style="margin: 4px 0 0; opacity: .8; font-size: 13px; font-weight: 300;">Lahore Gymkhana Club - Core lookup configurations, catalog attributes, and location metrics</p>
    </div>
</div>

<asp:UpdatePanel ID="upDefine" runat="server" UpdateMode="Conditional">
<ContentTemplate>

<!-- Alert Panel -->
<asp:Panel ID="pnlAlert" runat="server" Visible="false" style="width: 100%;">
    <div id="divAlert" runat="server" style="padding: 16px 24px; border-radius: 8px; font-size: 14px; margin-bottom: 24px; border-left: 4px solid transparent; width: 100%; box-sizing: border-box;">
        <asp:Literal ID="litAlertMsg" runat="server" />
    </div>
</asp:Panel>

<!-- Tab container spanning 100% width with clean text-only headers -->
<div style="display: flex; flex-direction: column; width: 100%; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 1px 2px 0 rgba(0,0,0,0.05); overflow: hidden; margin-bottom: 30px; box-sizing: border-box;">
    <div style="display: flex; background-color: #f8fafc; border-bottom: 1px solid #e2e8f0; width: 100%;" id="tabHeaders">
        <button type="button" class="tab-header-btn" style="flex: 1; padding: 18px 12px; text-align: center; background: none; border: none; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #c5a059; border-bottom: 3px solid #c5a059; background-color: #ffffff; cursor: pointer; transition: all 0.25s ease; outline: none;" onclick="switchTab(0)">Author</button>
        <button type="button" class="tab-header-btn" style="flex: 1; padding: 18px 12px; text-align: center; background: none; border: none; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; background-color: transparent; cursor: pointer; transition: all 0.25s ease; outline: none;" onclick="switchTab(1)">Staff Role</button>
        <button type="button" class="tab-header-btn" style="flex: 1; padding: 18px 12px; text-align: center; background: none; border: none; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; background-color: transparent; cursor: pointer; transition: all 0.25s ease; outline: none;" onclick="switchTab(2)">Location Selector</button>
        <button type="button" class="tab-header-btn" style="flex: 1; padding: 18px 12px; text-align: center; background: none; border: none; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; background-color: transparent; cursor: pointer; transition: all 0.25s ease; outline: none;" onclick="switchTab(3)">Subject</button>
        <button type="button" class="tab-header-btn" style="flex: 1; padding: 18px 12px; text-align: center; background: none; border: none; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; background-color: transparent; cursor: pointer; transition: all 0.25s ease; outline: none;" onclick="switchTab(4)">Publisher</button>
        <button type="button" class="tab-header-btn" style="flex: 1; padding: 18px 12px; text-align: center; background: none; border: none; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; background-color: transparent; cursor: pointer; transition: all 0.25s ease; outline: none;" onclick="switchTab(5)">Language</button>
        <button type="button" class="tab-header-btn" style="flex: 1; padding: 18px 12px; text-align: center; background: none; border: none; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; background-color: transparent; cursor: pointer; transition: all 0.25s ease; outline: none;" onclick="switchTab(6)">Floor</button>
    </div>

    <div style="padding: 36px; width: 100%; box-sizing: border-box;">
        <!-- Hidden field to persist active tab state across postbacks -->
        <asp:HiddenField ID="hfActiveTab" runat="server" Value="0" />

        <!-- Tab 0: Author Definition -->
        <div id="paneAuthor" class="tab-pane" style="display: block; width: 100%;">
            <div style="display: flex; gap: 30px; flex-wrap: wrap; align-items: flex-start; width: 100%;">
                
                <!-- Left Form: Add/Edit Author -->
                <div style="flex: 1; min-width: 320px; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 28px; box-sizing: border-box;">
                    <h3 style="font-size: 16px; font-weight: 700; color: #0f1e36; margin-bottom: 20px; border-bottom: 1px dashed #e2e8f0; padding-bottom: 10px; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0;">
                        <asp:Literal ID="litAuthorFormTitle" runat="server" Text="Add New Author" />
                    </h3>
                    
                    <asp:HiddenField ID="hfAuthorID" runat="server" Value="" />
                    
                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">First Name<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                        <asp:TextBox ID="txtAuthFirstName" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. Leo" />
                    </div>
                    
                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Last Name<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                        <asp:TextBox ID="txtAuthLastName" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. Tolstoy" />
                    </div>
                    
                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Nationality</label>
                        <asp:TextBox ID="txtAuthNationality" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. Russian" />
                    </div>

                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 24px; width: 100%; box-sizing: border-box;">
                        <asp:CheckBox ID="chkAuthorActive" runat="server" Checked="true" style="cursor: pointer;" />
                        <label for="<%= chkAuthorActive.ClientID %>" style="font-size: 13px; font-weight: 600; color: #1e293b; cursor: pointer; margin: 0; user-select: none;">Mark this Author as Active</label>
                    </div>

                    <div style="display: flex; gap: 12px; width: 100%;">
                        <asp:Button ID="btnSaveAuthor" runat="server" Text="Save Author" style="flex: 2; padding: 13px 20px; border: none; border-radius: 8px; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; cursor: pointer; text-align: center; outline: none; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #0f1e36; transition: transform 0.2s;" OnClick="btnSaveAuthor_Click" />
                        <asp:Button ID="btnClearAuthor" runat="server" Text="Cancel" style="flex: 1; padding: 13px 20px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; text-align: center; outline: none; background-color: #ffffff; color: #64748b; transition: all 0.2s;" OnClick="btnClearAuthor_Click" Visible="false" />
                    </div>
                </div>

                <!-- Right Table: Existing Authors List -->
                <div style="flex: 2; min-width: 450px; box-sizing: border-box;">
                    <h3 style="font-size: 16px; font-weight: 700; color: #0f1e36; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px dashed #e2e8f0; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0;">Defined Authors</h3>
                    
                    <asp:GridView ID="gvAuthors" runat="server" AutoGenerateColumns="False" style="width: 100%; border-collapse: collapse; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;"
                                  HeaderStyle-CssClass="grid-header" RowStyle-CssClass="grid-row" AlternatingRowStyle-CssClass="grid-alt-row" GridLines="None"
                                  AllowPaging="True" PageSize="10" OnPageIndexChanging="gvAuthors_PageIndexChanging" PagerStyle-CssClass="pager-style"
                                  OnRowCommand="gvAuthors_RowCommand" DataKeyNames="AuthorID">
                        <Columns>
                            <asp:TemplateField HeaderText="#" HeaderStyle-CssClass="cell-left" ItemStyle-CssClass="col-id" ItemStyle-Width="40px">
                                <ItemTemplate>
                                    <%# Container.DataItemIndex + 1 %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="AuthorID" HeaderText="ID" ItemStyle-CssClass="col-id" HeaderStyle-CssClass="cell-left" />
                            <asp:TemplateField HeaderText="Full Name" HeaderStyle-CssClass="cell-left" ItemStyle-CssClass="col-name">
                                <ItemTemplate>
                                    <%# Eval("FirstName") %> <%# Eval("LastName") %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="Nationality" HeaderText="Nationality" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                            <asp:TemplateField HeaderText="Status" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-status">
                                <ItemTemplate>
                                    <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                                        <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-actions">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditAuthor" CommandArgument='<%# Eval("AuthorID") %>' style="font-size: 13px; font-weight: 700; color: #c5a059; text-decoration: none; border: 1px solid #c5a059; padding: 6px 12px; border-radius: 6px; background-color: transparent; transition: all 0.2s;" onmouseover="this.style.backgroundColor='#c5a059'; this.style.color='#0f1e36';" onmouseout="this.style.backgroundColor='transparent'; this.style.color='#c5a059';">Edit</asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div style="padding: 40px; text-align: center; color: #64748b; font-size: 14px;">No authors defined yet.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>

        <!-- Tab 1: Staff Role Definition -->
        <div id="paneRole" class="tab-pane" style="display: none; width: 100%;">
            <div style="display: flex; gap: 30px; flex-wrap: wrap; align-items: flex-start; width: 100%;">
                
                <!-- Left Form: Add/Edit Staff Role -->
                <div style="flex: 1; min-width: 320px; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 28px; box-sizing: border-box;">
                    <h3 style="font-size: 16px; font-weight: 700; color: #0f1e36; margin-bottom: 20px; border-bottom: 1px dashed #e2e8f0; padding-bottom: 10px; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0;">
                        <asp:Literal ID="litRoleFormTitle" runat="server" Text="Add New Staff Role" />
                    </h3>
                    
                    <asp:HiddenField ID="hfRoleID" runat="server" Value="" />
                    
                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Role Name<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                        <asp:TextBox ID="txtRoleName" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. Senior Librarian" />
                    </div>

                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 24px; width: 100%; box-sizing: border-box;">
                        <asp:CheckBox ID="chkRoleActive" runat="server" Checked="true" style="cursor: pointer;" />
                        <label for="<%= chkRoleActive.ClientID %>" style="font-size: 13px; font-weight: 600; color: #1e293b; cursor: pointer; margin: 0; user-select: none;">Mark this Staff Role as Active</label>
                    </div>

                    <div style="display: flex; gap: 12px; width: 100%;">
                        <asp:Button ID="btnSaveRole" runat="server" Text="Save Staff Role" style="flex: 2; padding: 13px 20px; border: none; border-radius: 8px; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; cursor: pointer; text-align: center; outline: none; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #0f1e36; transition: transform 0.2s;" OnClick="btnSaveRole_Click" />
                        <asp:Button ID="btnClearRole" runat="server" Text="Cancel" style="flex: 1; padding: 13px 20px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; text-align: center; outline: none; background-color: #ffffff; color: #64748b; transition: all 0.2s;" OnClick="btnClearRole_Click" Visible="false" />
                    </div>
                </div>

                <!-- Right Table: Existing Staff Roles List -->
                <div style="flex: 2; min-width: 450px; box-sizing: border-box;">
                    <h3 style="font-size: 16px; font-weight: 700; color: #0f1e36; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px dashed #e2e8f0; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0;">Defined Staff Roles</h3>
                    
                    <asp:GridView ID="gvStaffRoles" runat="server" AutoGenerateColumns="False" style="width: 100%; border-collapse: collapse; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;"
                                  HeaderStyle-CssClass="grid-header" RowStyle-CssClass="grid-row" AlternatingRowStyle-CssClass="grid-alt-row" GridLines="None"
                                  AllowPaging="True" PageSize="10" OnPageIndexChanging="gvStaffRoles_PageIndexChanging" PagerStyle-CssClass="pager-style"
                                  OnRowCommand="gvStaffRoles_RowCommand" DataKeyNames="RoleID">
                        <Columns>
                            <asp:TemplateField HeaderText="#" HeaderStyle-CssClass="cell-left" ItemStyle-CssClass="col-id" ItemStyle-Width="40px">
                                <ItemTemplate>
                                    <%# Container.DataItemIndex + 1 %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="RoleID" HeaderText="ID" ItemStyle-CssClass="col-id" HeaderStyle-CssClass="cell-left" />
                            <asp:BoundField DataField="RoleName" HeaderText="Role Name" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                            <asp:TemplateField HeaderText="Status" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-status">
                                <ItemTemplate>
                                    <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                                        <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-actions">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditRole" CommandArgument='<%# Eval("RoleID") %>' style="font-size: 13px; font-weight: 700; color: #c5a059; text-decoration: none; border: 1px solid #c5a059; padding: 6px 12px; border-radius: 6px; background-color: transparent; transition: all 0.2s;" onmouseover="this.style.backgroundColor='#c5a059'; this.style.color='#0f1e36';" onmouseout="this.style.backgroundColor='transparent'; this.style.color='#c5a059';">Edit</asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div style="padding: 40px; text-align: center; color: #64748b; font-size: 14px;">No staff roles defined yet.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>

        <!-- Tab 2: Location Definition hierarchy -->
        <div id="paneLocation" class="tab-pane" style="display: none; width: 100%;">
            <!-- Part A: Define Hall -->
            <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 28px; margin-bottom: 28px; width: 100%; box-sizing: border-box;">
                <h3 style="font-size: 15px; font-weight: 700; color: #0f1e36; margin-bottom: 20px; border-bottom: 1px dashed #e2e8f0; padding-bottom: 8px; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0;">Step 1: Define Hall Location</h3>
                
                <div style="display: flex; gap: 30px; flex-wrap: wrap; align-items: flex-start; width: 100%;">
                    <!-- Left Form -->
                    <div style="flex: 1; min-width: 320px; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 24px; box-sizing: border-box;">
                        <h4 style="font-size: 14px; font-weight: 700; color: #0f1e36; margin-bottom: 16px; margin-top: 0; text-transform: uppercase; letter-spacing: 0.5px;">
                            <asp:Literal ID="litHallFormTitle" runat="server" Text="Add New Hall Wing" />
                        </h4>
                        
                        <asp:HiddenField ID="hfHallID" runat="server" Value="" />
                        
                        <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Hall Code<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                            <asp:TextBox ID="txtHallCode" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. GH-01, LH-A" />
                        </div>
                        
                        <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Hall Name<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                            <asp:TextBox ID="txtHallName" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. Iqbal Hall" />
                        </div>
                        
                        <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Floor Number</label>
                            <asp:DropDownList ID="ddlHallFloor" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 46px;" />
                        </div>

                        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 24px; width: 100%; box-sizing: border-box;">
                            <asp:CheckBox ID="chkHallActive" runat="server" Checked="true" style="cursor: pointer;" />
                            <label for="<%= chkHallActive.ClientID %>" style="font-size: 13px; font-weight: 600; color: #1e293b; cursor: pointer; margin: 0; user-select: none;">Mark this Hall as Active</label>
                        </div>

                        <div style="display: flex; gap: 12px; width: 100%;">
                            <asp:Button ID="btnSaveHall" runat="server" Text="Save Hall Wing" style="flex: 2; padding: 13px 20px; border: none; border-radius: 8px; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; cursor: pointer; text-align: center; outline: none; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff;" OnClick="btnSaveHall_Click" />
                            <asp:Button ID="btnClearHall" runat="server" Text="Cancel" style="flex: 1; padding: 13px 20px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; text-align: center; outline: none; background-color: #ffffff; color: #64748b; transition: all 0.2s;" OnClick="btnClearHall_Click" Visible="false" />
                        </div>
                    </div>

                    <!-- Right Table -->
                    <div style="flex: 2; min-width: 450px; box-sizing: border-box;">
                        <h4 style="font-size: 14px; font-weight: 700; color: #0f1e36; margin-bottom: 16px; margin-top: 0; text-transform: uppercase; letter-spacing: 0.5px;">Defined Hall Locations</h4>
                        <asp:GridView ID="gvHalls" runat="server" AutoGenerateColumns="False" style="width: 100%; border-collapse: collapse; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;"
                                      HeaderStyle-CssClass="grid-header" RowStyle-CssClass="grid-row" AlternatingRowStyle-CssClass="grid-alt-row" GridLines="None"
                                      AllowPaging="True" PageSize="10" OnPageIndexChanging="gvHalls_PageIndexChanging" PagerStyle-CssClass="pager-style"
                                      OnRowCommand="gvHalls_RowCommand" DataKeyNames="HallID">
                            <Columns>
                                <asp:TemplateField HeaderText="#" HeaderStyle-CssClass="cell-left" ItemStyle-CssClass="col-id" ItemStyle-Width="40px">
                                    <ItemTemplate>
                                        <%# Container.DataItemIndex + 1 %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="HallID" HeaderText="ID" ItemStyle-CssClass="col-id" HeaderStyle-CssClass="cell-left" />
                                <asp:BoundField DataField="HallCode" HeaderText="Code" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                                <asp:BoundField DataField="HallName" HeaderText="Hall Name" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                                <asp:BoundField DataField="FloorName" HeaderText="Floor" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                                <asp:TemplateField HeaderText="Status" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-status">
                                    <ItemTemplate>
                                        <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                                            <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-actions">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditHall" CommandArgument='<%# Eval("HallID") %>' style="font-size: 13px; font-weight: 700; color: #c5a059; text-decoration: none; border: 1px solid #c5a059; padding: 6px 12px; border-radius: 6px; background-color: transparent; transition: all 0.2s;" onmouseover="this.style.backgroundColor='#c5a059'; this.style.color='#0f1e36';" onmouseout="this.style.backgroundColor='transparent'; this.style.color='#c5a059';">Edit</asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div style="padding: 40px; text-align: center; color: #64748b; font-size: 14px;">No halls defined yet.</div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>

            <!-- Part B: Define Shelf Unit -->
            <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 28px; margin-bottom: 28px; width: 100%; box-sizing: border-box;">
                <h3 style="font-size: 15px; font-weight: 700; color: #0f1e36; margin-bottom: 20px; border-bottom: 1px dashed #e2e8f0; padding-bottom: 8px; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0;">Step 2: Define Shelf Unit</h3>
                
                <div style="display: flex; gap: 30px; flex-wrap: wrap; align-items: flex-start; width: 100%;">
                    <!-- Left Form -->
                    <div style="flex: 1; min-width: 320px; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 24px; box-sizing: border-box;">
                        <h4 style="font-size: 14px; font-weight: 700; color: #0f1e36; margin-bottom: 16px; margin-top: 0; text-transform: uppercase; letter-spacing: 0.5px;">
                            <asp:Literal ID="litUnitFormTitle" runat="server" Text="Add New Shelf Unit" />
                        </h4>
                        
                        <asp:HiddenField ID="hfUnitID" runat="server" Value="" />
                        
                        <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Belongs to Hall Wing<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                            <asp:DropDownList ID="ddlUnitHall" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 46px;" />
                        </div>
                        
                        <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Shelf Unit Code<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                            <asp:TextBox ID="txtUnitCode" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. SU-101, Aisle-04" />
                        </div>
                        
                        <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Shelf Unit Name / Label</label>
                            <asp:TextBox ID="txtUnitName" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. English Classics" />
                        </div>

                        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 24px; width: 100%; box-sizing: border-box;">
                            <asp:CheckBox ID="chkUnitActive" runat="server" Checked="true" style="cursor: pointer;" />
                            <label for="<%= chkUnitActive.ClientID %>" style="font-size: 13px; font-weight: 600; color: #1e293b; cursor: pointer; margin: 0; user-select: none;">Mark this Shelf Unit as Active</label>
                        </div>

                        <div style="display: flex; gap: 12px; width: 100%;">
                            <asp:Button ID="btnSaveShelfUnit" runat="server" Text="Save Shelf Unit" style="flex: 2; padding: 13px 20px; border: none; border-radius: 8px; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; cursor: pointer; text-align: center; outline: none; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff;" OnClick="btnSaveShelfUnit_Click" />
                            <asp:Button ID="btnClearShelfUnit" runat="server" Text="Cancel" style="flex: 1; padding: 13px 20px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; text-align: center; outline: none; background-color: #ffffff; color: #64748b; transition: all 0.2s;" OnClick="btnClearShelfUnit_Click" Visible="false" />
                        </div>
                    </div>

                    <!-- Right Table -->
                    <div style="flex: 2; min-width: 450px; box-sizing: border-box;">
                        <h4 style="font-size: 14px; font-weight: 700; color: #0f1e36; margin-bottom: 16px; margin-top: 0; text-transform: uppercase; letter-spacing: 0.5px;">Defined Shelf Units</h4>
                        <asp:GridView ID="gvShelfUnits" runat="server" AutoGenerateColumns="False" style="width: 100%; border-collapse: collapse; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;"
                                      HeaderStyle-CssClass="grid-header" RowStyle-CssClass="grid-row" AlternatingRowStyle-CssClass="grid-alt-row" GridLines="None"
                                      AllowPaging="True" PageSize="10" OnPageIndexChanging="gvShelfUnits_PageIndexChanging" PagerStyle-CssClass="pager-style"
                                      OnRowCommand="gvShelfUnits_RowCommand" DataKeyNames="UnitID">
                            <Columns>
                                <asp:TemplateField HeaderText="#" HeaderStyle-CssClass="cell-left" ItemStyle-CssClass="col-id" ItemStyle-Width="40px">
                                    <ItemTemplate>
                                        <%# Container.DataItemIndex + 1 %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="UnitID" HeaderText="ID" ItemStyle-CssClass="col-id" HeaderStyle-CssClass="cell-left" />
                                <asp:BoundField DataField="HallName" HeaderText="Hall Wing" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                                <asp:BoundField DataField="UnitCode" HeaderText="Unit Code" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                                <asp:BoundField DataField="UnitName" HeaderText="Unit Name" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                                <asp:TemplateField HeaderText="Status" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-status">
                                    <ItemTemplate>
                                        <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                                            <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-actions">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditShelfUnit" CommandArgument='<%# Eval("UnitID") %>' style="font-size: 13px; font-weight: 700; color: #c5a059; text-decoration: none; border: 1px solid #c5a059; padding: 6px 12px; border-radius: 6px; background-color: transparent; transition: all 0.2s;" onmouseover="this.style.backgroundColor='#c5a059'; this.style.color='#0f1e36';" onmouseout="this.style.backgroundColor='transparent'; this.style.color='#c5a059';">Edit</asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div style="padding: 40px; text-align: center; color: #64748b; font-size: 14px;">No shelf units defined yet.</div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>

            <!-- Part C: Define Rack Row -->
            <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 28px; margin-bottom: 28px; width: 100%; box-sizing: border-box;">
                <h3 style="font-size: 15px; font-weight: 700; color: #0f1e36; margin-bottom: 20px; border-bottom: 1px dashed #e2e8f0; padding-bottom: 8px; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0;">Step 3: Define Rack Row</h3>
                
                <div style="display: flex; gap: 30px; flex-wrap: wrap; align-items: flex-start; width: 100%;">
                    <!-- Left Form -->
                    <div style="flex: 1; min-width: 320px; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 24px; box-sizing: border-box;">
                        <h4 style="font-size: 14px; font-weight: 700; color: #0f1e36; margin-bottom: 16px; margin-top: 0; text-transform: uppercase; letter-spacing: 0.5px;">
                            <asp:Literal ID="litRackFormTitle" runat="server" Text="Add New Rack Row" />
                        </h4>
                        
                        <asp:HiddenField ID="hfRackID" runat="server" Value="" />
                        
                        <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 14px; width: 100%; box-sizing: border-box;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Select Hall Wing<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                            <asp:DropDownList ID="ddlRackHall" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 46px;" AutoPostBack="true" OnSelectedIndexChanged="ddlRackHall_Changed" />
                        </div>
                        
                        <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 14px; width: 100%; box-sizing: border-box;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Select Shelf Unit<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                            <asp:DropDownList ID="ddlRackUnit" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 46px;" />
                        </div>
                        
                        <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 14px; width: 100%; box-sizing: border-box;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Rack Row Number<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                            <asp:TextBox ID="txtRackNo" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. 1" TextMode="Number" />
                        </div>
                        
                        <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 14px; width: 100%; box-sizing: border-box;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Total Capacity Slots<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                            <asp:TextBox ID="txtRackSlots" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="Default 30 slots" TextMode="Number" Text="30" />
                        </div>
                        
                        <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Subject / Subject Tag</label>
                            <asp:TextBox ID="txtRackSubject" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. History" />
                        </div>

                        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 24px; width: 100%; box-sizing: border-box;">
                            <asp:CheckBox ID="chkRackActive" runat="server" Checked="true" style="cursor: pointer;" />
                            <label for="<%= chkRackActive.ClientID %>" style="font-size: 13px; font-weight: 600; color: #1e293b; cursor: pointer; margin: 0; user-select: none;">Mark this Rack as Active</label>
                        </div>

                        <div style="display: flex; gap: 12px; width: 100%;">
                            <asp:Button ID="btnSaveRack" runat="server" Text="Save Rack Row" style="flex: 2; padding: 13px 20px; border: none; border-radius: 8px; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; cursor: pointer; text-align: center; outline: none; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #0f1e36;" OnClick="btnSaveRack_Click" />
                            <asp:Button ID="btnClearRack" runat="server" Text="Cancel" style="flex: 1; padding: 13px 20px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; text-align: center; outline: none; background-color: #ffffff; color: #64748b; transition: all 0.2s;" OnClick="btnClearRack_Click" Visible="false" />
                        </div>
                    </div>

                    <!-- Right Table -->
                    <div style="flex: 2; min-width: 450px; box-sizing: border-box;">
                        <h4 style="font-size: 14px; font-weight: 700; color: #0f1e36; margin-bottom: 16px; margin-top: 0; text-transform: uppercase; letter-spacing: 0.5px;">Defined Rack Rows</h4>
                        <asp:GridView ID="gvRacks" runat="server" AutoGenerateColumns="False" style="width: 100%; border-collapse: collapse; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;"
                                      HeaderStyle-CssClass="grid-header" RowStyle-CssClass="grid-row" AlternatingRowStyle-CssClass="grid-alt-row" GridLines="None"
                                      AllowPaging="True" PageSize="10" OnPageIndexChanging="gvRacks_PageIndexChanging" PagerStyle-CssClass="pager-style"
                                      OnRowCommand="gvRacks_RowCommand" DataKeyNames="RackID">
                            <Columns>
                                <asp:TemplateField HeaderText="#" HeaderStyle-CssClass="cell-left" ItemStyle-CssClass="col-id" ItemStyle-Width="40px">
                                    <ItemTemplate>
                                        <%# Container.DataItemIndex + 1 %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="RackID" HeaderText="ID" ItemStyle-CssClass="col-id" HeaderStyle-CssClass="cell-left" />
                                <asp:BoundField DataField="UnitCode" HeaderText="Shelf Unit" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                                <asp:BoundField DataField="RackNo" HeaderText="Rack No" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                                <asp:BoundField DataField="TotalSlots" HeaderText="Slots" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                                <asp:BoundField DataField="SubjectTag" HeaderText="Subject Tag" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                                <asp:TemplateField HeaderText="Status" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-status">
                                    <ItemTemplate>
                                        <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                                            <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-actions">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditRack" CommandArgument='<%# Eval("RackID") %>' style="font-size: 13px; font-weight: 700; color: #c5a059; text-decoration: none; border: 1px solid #c5a059; padding: 6px 12px; border-radius: 6px; background-color: transparent; transition: all 0.2s;" onmouseover="this.style.backgroundColor='#c5a059'; this.style.color='#0f1e36';" onmouseout="this.style.backgroundColor='transparent'; this.style.color='#c5a059';">Edit</asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div style="padding: 40px; text-align: center; color: #64748b; font-size: 14px;">No rack rows defined yet.</div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tab 3: Subject Definition -->
        <div id="paneCategory" class="tab-pane" style="display: none; width: 100%;">
            <div style="display: flex; gap: 30px; flex-wrap: wrap; align-items: flex-start; width: 100%;">
                
                <!-- Left Form: Add/Edit Subject -->
                <div style="flex: 1; min-width: 320px; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 28px; box-sizing: border-box;">
                    <h3 style="font-size: 16px; font-weight: 700; color: #0f1e36; margin-bottom: 20px; border-bottom: 1px dashed #e2e8f0; padding-bottom: 10px; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0;">
                        <asp:Literal ID="litCategoryFormTitle" runat="server" Text="Add New Subject" />
                    </h3>
                    
                    <asp:HiddenField ID="hfCatID" runat="server" Value="" />
                    
                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Subject Code (UPPERCASE)<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                        <asp:TextBox ID="txtCatCode" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. FIC, SCI" />
                    </div>
                    
                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Subject Name<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                        <asp:TextBox ID="txtCatName" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. Biography" />
                    </div>

                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">DDC Class/Subclass Code</label>
                        <asp:TextBox ID="txtDdcPrefix" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. 909 or 827" />
                    </div>
                    
                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Parent Subject (Hierarchy)</label>
                        <asp:DropDownList ID="ddlParentCategory" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 46px;" />
                    </div>
 
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 24px; width: 100%; box-sizing: border-box;">
                        <asp:CheckBox ID="chkCatActive" runat="server" Checked="true" style="cursor: pointer;" />
                        <label for="<%= chkCatActive.ClientID %>" style="font-size: 13px; font-weight: 600; color: #1e293b; cursor: pointer; margin: 0; user-select: none;">Mark this Subject as Active</label>
                    </div>
 
                    <div style="display: flex; gap: 12px; width: 100%;">
                        <asp:Button ID="btnSaveCategory" runat="server" Text="Save Subject" style="flex: 2; padding: 13px 20px; border: none; border-radius: 8px; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; cursor: pointer; text-align: center; outline: none; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #0f1e36;" OnClick="btnSaveCategory_Click" />
                        <asp:Button ID="btnClearCategory" runat="server" Text="Cancel" style="flex: 1; padding: 13px 20px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; text-align: center; outline: none; background-color: #ffffff; color: #64748b; transition: all 0.2s;" OnClick="btnClearCategory_Click" Visible="false" />
                    </div>
                </div>
 
                <!-- Right Table: Existing Subjects List -->
                <div style="flex: 2; min-width: 450px; box-sizing: border-box;">
                    <h3 style="font-size: 16px; font-weight: 700; color: #0f1e36; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px dashed #e2e8f0; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0;">Defined Subjects</h3>
                    
                    <asp:GridView ID="gvCategories" runat="server" AutoGenerateColumns="False" style="width: 100%; border-collapse: collapse; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;"
                                  HeaderStyle-CssClass="grid-header" RowStyle-CssClass="grid-row" AlternatingRowStyle-CssClass="grid-alt-row" GridLines="None"
                                  AllowPaging="True" PageSize="10" OnPageIndexChanging="gvCategories_PageIndexChanging" PagerStyle-CssClass="pager-style"
                                  OnRowCommand="gvCategories_RowCommand" DataKeyNames="CatID">
                        <Columns>
                            <asp:TemplateField HeaderText="#" HeaderStyle-CssClass="cell-left" ItemStyle-CssClass="col-id" ItemStyle-Width="40px">
                                <ItemTemplate>
                                    <%# Container.DataItemIndex + 1 %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="CatID" HeaderText="ID" ItemStyle-CssClass="col-id" HeaderStyle-CssClass="cell-left" />
                            <asp:BoundField DataField="CatCode" HeaderText="Code" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                            <asp:BoundField DataField="CatName" HeaderText="Subject Name" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                            <asp:BoundField DataField="DdcPrefix" HeaderText="DDC Code" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" NullDisplayText="-" />
                            <asp:BoundField DataField="ParentCatName" HeaderText="Parent Subject" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" NullDisplayText="- None -" />
                            <asp:TemplateField HeaderText="Status" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-status">
                                <ItemTemplate>
                                    <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                                        <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-actions">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditCategory" CommandArgument='<%# Eval("CatID") %>' style="font-size: 13px; font-weight: 700; color: #c5a059; text-decoration: none; border: 1px solid #c5a059; padding: 6px 12px; border-radius: 6px; background-color: transparent; transition: all 0.2s;" onmouseover="this.style.backgroundColor='#c5a059'; this.style.color='#0f1e36';" onmouseout="this.style.backgroundColor='transparent'; this.style.color='#c5a059';">Edit</asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div style="padding: 40px; text-align: center; color: #64748b; font-size: 14px;">No categories defined yet.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>

        <!-- Tab 4: Publisher Definition -->
        <div id="panePublisher" class="tab-pane" style="display: none; width: 100%;">
            <div style="display: flex; gap: 30px; flex-wrap: wrap; align-items: flex-start; width: 100%;">
                
                <!-- Left Form: Add/Edit Publisher -->
                <div style="flex: 1; min-width: 320px; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 28px; box-sizing: border-box;">
                    <h3 style="font-size: 16px; font-weight: 700; color: #0f1e36; margin-bottom: 20px; border-bottom: 1px dashed #e2e8f0; padding-bottom: 10px; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0;">
                        <asp:Literal ID="litPublisherFormTitle" runat="server" Text="Add New Publisher" />
                    </h3>
                    
                    <asp:HiddenField ID="hfPubID" runat="server" Value="" />
                    
                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Publisher Name<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                        <asp:TextBox ID="txtPubName" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. Penguin Books" />
                    </div>
                    
                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Country of Origin</label>
                        <asp:TextBox ID="txtPubCountry" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. United Kingdom" />
                    </div>

                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 24px; width: 100%; box-sizing: border-box;">
                        <asp:CheckBox ID="chkPubActive" runat="server" Checked="true" style="cursor: pointer;" />
                        <label for="<%= chkPubActive.ClientID %>" style="font-size: 13px; font-weight: 600; color: #1e293b; cursor: pointer; margin: 0; user-select: none;">Mark this Publisher as Active</label>
                    </div>

                    <div style="display: flex; gap: 12px; width: 100%;">
                        <asp:Button ID="btnSavePublisher" runat="server" Text="Save Publisher" style="flex: 2; padding: 13px 20px; border: none; border-radius: 8px; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; cursor: pointer; text-align: center; outline: none; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #0f1e36;" OnClick="btnSavePublisher_Click" />
                        <asp:Button ID="btnClearPublisher" runat="server" Text="Cancel" style="flex: 1; padding: 13px 20px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; text-align: center; outline: none; background-color: #ffffff; color: #64748b; transition: all 0.2s;" OnClick="btnClearPublisher_Click" Visible="false" />
                    </div>
                </div>

                <!-- Right Table: Existing Publishers List -->
                <div style="flex: 2; min-width: 450px; box-sizing: border-box;">
                    <h3 style="font-size: 16px; font-weight: 700; color: #0f1e36; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px dashed #e2e8f0; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0;">Defined Publishers</h3>
                    
                    <asp:GridView ID="gvPublishers" runat="server" AutoGenerateColumns="False" style="width: 100%; border-collapse: collapse; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;"
                                  HeaderStyle-CssClass="grid-header" RowStyle-CssClass="grid-row" AlternatingRowStyle-CssClass="grid-alt-row" GridLines="None"
                                  AllowPaging="True" PageSize="10" OnPageIndexChanging="gvPublishers_PageIndexChanging" PagerStyle-CssClass="pager-style"
                                  OnRowCommand="gvPublishers_RowCommand" DataKeyNames="PubID">
                        <Columns>
                            <asp:TemplateField HeaderText="#" HeaderStyle-CssClass="cell-left" ItemStyle-CssClass="col-id" ItemStyle-Width="40px">
                                <ItemTemplate>
                                    <%# Container.DataItemIndex + 1 %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="PubID" HeaderText="ID" ItemStyle-CssClass="col-id" HeaderStyle-CssClass="cell-left" />
                            <asp:BoundField DataField="PubName" HeaderText="Publisher Name" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                            <asp:BoundField DataField="Country" HeaderText="Country" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" NullDisplayText="- Unknown -" />
                            <asp:TemplateField HeaderText="Status" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-status">
                                <ItemTemplate>
                                    <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                                        <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-actions">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditPublisher" CommandArgument='<%# Eval("PubID") %>' style="font-size: 13px; font-weight: 700; color: #c5a059; text-decoration: none; border: 1px solid #c5a059; padding: 6px 12px; border-radius: 6px; background-color: transparent; transition: all 0.2s;" onmouseover="this.style.backgroundColor='#c5a059'; this.style.color='#0f1e36';" onmouseout="this.style.backgroundColor='transparent'; this.style.color='#c5a059';">Edit</asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div style="padding: 40px; text-align: center; color: #64748b; font-size: 14px;">No publishers defined yet.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>

        <!-- Tab 5: Language Definition -->
        <div id="paneLanguage" class="tab-pane" style="display: none; width: 100%;">
            <div style="display: flex; gap: 30px; flex-wrap: wrap; align-items: flex-start; width: 100%;">
                
                <!-- Left Form: Add/Edit Language -->
                <div style="flex: 1; min-width: 320px; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 28px; box-sizing: border-box;">
                    <h3 style="font-size: 16px; font-weight: 700; color: #0f1e36; margin-bottom: 20px; border-bottom: 1px dashed #e2e8f0; padding-bottom: 10px; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0;">
                        <asp:Literal ID="litLanguageFormTitle" runat="server" Text="Add New Language" />
                    </h3>
                    
                    <asp:HiddenField ID="hfLangID" runat="server" Value="" />
                    
                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Language Code (2-Letters)<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                        <asp:TextBox ID="txtLangCode" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. es" MaxLength="2" />
                    </div>
                    
                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Language Name<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                        <asp:TextBox ID="txtLangName" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. Spanish" MaxLength="40" />
                    </div>

                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 24px; width: 100%; box-sizing: border-box;">
                        <asp:CheckBox ID="chkLangActive" runat="server" Checked="true" style="cursor: pointer;" />
                        <label for="<%= chkLangActive.ClientID %>" style="font-size: 13px; font-weight: 600; color: #1e293b; cursor: pointer; margin: 0; user-select: none;">Mark this Language as Active</label>
                    </div>

                    <div style="display: flex; gap: 12px; width: 100%;">
                        <asp:Button ID="btnSaveLanguage" runat="server" Text="Save Language" style="flex: 2; padding: 13px 20px; border: none; border-radius: 8px; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; cursor: pointer; text-align: center; outline: none; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #0f1e36;" OnClick="btnSaveLanguage_Click" />
                        <asp:Button ID="btnClearLanguage" runat="server" Text="Cancel" style="flex: 1; padding: 13px 20px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; text-align: center; outline: none; background-color: #ffffff; color: #64748b; transition: all 0.2s;" OnClick="btnClearLanguage_Click" Visible="false" />
                    </div>
                </div>

                <!-- Right Table: Existing Languages List -->
                <div style="flex: 2; min-width: 450px; box-sizing: border-box;">
                    <h3 style="font-size: 16px; font-weight: 700; color: #0f1e36; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px dashed #e2e8f0; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0;">Defined Languages</h3>
                    
                    <asp:GridView ID="gvLanguages" runat="server" AutoGenerateColumns="False" style="width: 100%; border-collapse: collapse; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;"
                                  HeaderStyle-CssClass="grid-header" RowStyle-CssClass="grid-row" AlternatingRowStyle-CssClass="grid-alt-row" GridLines="None"
                                  AllowPaging="True" PageSize="10" OnPageIndexChanging="gvLanguages_PageIndexChanging" PagerStyle-CssClass="pager-style"
                                  OnRowCommand="gvLanguages_RowCommand" DataKeyNames="LangID">
                        <Columns>
                            <asp:TemplateField HeaderText="#" HeaderStyle-CssClass="cell-left" ItemStyle-CssClass="col-id" ItemStyle-Width="40px">
                                <ItemTemplate>
                                    <%# Container.DataItemIndex + 1 %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="LangID" HeaderText="ID" ItemStyle-CssClass="col-id" HeaderStyle-CssClass="cell-left" />
                            <asp:BoundField DataField="LangCode" HeaderText="Code" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                            <asp:BoundField DataField="LangName" HeaderText="Language Name" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                            <asp:TemplateField HeaderText="Status" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-status">
                                <ItemTemplate>
                                    <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                                        <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-actions">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditLanguage" CommandArgument='<%# Eval("LangID") %>' style="font-size: 13px; font-weight: 700; color: #c5a059; text-decoration: none; border: 1px solid #c5a059; padding: 6px 12px; border-radius: 6px; background-color: transparent; transition: all 0.2s;" onmouseover="this.style.backgroundColor='#c5a059'; this.style.color='#0f1e36';" onmouseout="this.style.backgroundColor='transparent'; this.style.color='#c5a059';">Edit</asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div style="padding: 40px; text-align: center; color: #64748b; font-size: 14px;">No languages defined yet.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>

        <!-- Tab 6: Floor Definition -->
        <div id="paneFloor" class="tab-pane" style="display: none; width: 100%;">
            <div style="display: flex; gap: 30px; flex-wrap: wrap; align-items: flex-start; width: 100%;">
                
                <!-- Left Form: Add/Edit Floor -->
                <div style="flex: 1; min-width: 320px; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 28px; box-sizing: border-box;">
                    <h3 style="font-size: 16px; font-weight: 700; color: #0f1e36; margin-bottom: 20px; border-bottom: 1px dashed #e2e8f0; padding-bottom: 10px; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0;">
                        <asp:Literal ID="litFloorFormTitle" runat="server" Text="Add New Floor" />
                    </h3>
                    
                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Floor Number<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                        <asp:TextBox ID="txtFloorNo" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. 4" TextMode="Number" />
                    </div>
                    
                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Floor Name<span style="color: #ef4444; margin-left: 2px;">*</span></label>
                        <asp:TextBox ID="txtFloorName" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box;" placeholder="e.g. Fourth Floor" MaxLength="40" />
                    </div>

                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 24px; width: 100%; box-sizing: border-box;">
                        <asp:CheckBox ID="chkFloorActive" runat="server" Checked="true" style="cursor: pointer;" />
                        <label for="<%= chkFloorActive.ClientID %>" style="font-size: 13px; font-weight: 600; color: #1e293b; cursor: pointer; margin: 0; user-select: none;">Mark this Floor as Active</label>
                    </div>

                    <div style="display: flex; gap: 12px; width: 100%;">
                        <asp:Button ID="btnSaveFloor" runat="server" Text="Save Floor" style="flex: 2; padding: 13px 20px; border: none; border-radius: 8px; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; cursor: pointer; text-align: center; outline: none; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #0f1e36;" OnClick="btnSaveFloor_Click" />
                        <asp:Button ID="btnClearFloor" runat="server" Text="Cancel" style="flex: 1; padding: 13px 20px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; text-align: center; outline: none; background-color: #ffffff; color: #64748b; transition: all 0.2s;" OnClick="btnClearFloor_Click" Visible="false" />
                    </div>
                </div>

                <!-- Right Table: Existing Floors List -->
                <div style="flex: 2; min-width: 450px; box-sizing: border-box;">
                    <h3 style="font-size: 16px; font-weight: 700; color: #0f1e36; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px dashed #e2e8f0; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0;">Defined Floors</h3>
                    
                    <asp:GridView ID="gvFloors" runat="server" AutoGenerateColumns="False" style="width: 100%; border-collapse: collapse; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;"
                                  HeaderStyle-CssClass="grid-header" RowStyle-CssClass="grid-row" AlternatingRowStyle-CssClass="grid-alt-row" GridLines="None"
                                  AllowPaging="True" PageSize="10" OnPageIndexChanging="gvFloors_PageIndexChanging" PagerStyle-CssClass="pager-style"
                                  OnRowCommand="gvFloors_RowCommand" DataKeyNames="FloorNo">
                        <Columns>
                            <asp:TemplateField HeaderText="#" HeaderStyle-CssClass="cell-left" ItemStyle-CssClass="col-id" ItemStyle-Width="40px">
                                <ItemTemplate>
                                    <%# Container.DataItemIndex + 1 %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="FloorNo" HeaderText="Floor No" ItemStyle-CssClass="col-id" HeaderStyle-CssClass="cell-left" />
                            <asp:BoundField DataField="FloorName" HeaderText="Floor Name" ItemStyle-CssClass="col-name" HeaderStyle-CssClass="cell-left" />
                            <asp:TemplateField HeaderText="Status" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-status">
                                <ItemTemplate>
                                    <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                                        <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="cell-center" ItemStyle-CssClass="col-actions">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditFloor" CommandArgument='<%# Eval("FloorNo") %>' style="font-size: 13px; font-weight: 700; color: #c5a059; text-decoration: none; border: 1px solid #c5a059; padding: 6px 12px; border-radius: 6px; background-color: transparent; transition: all 0.2s;" onmouseover="this.style.backgroundColor='#c5a059'; this.style.color='#0f1e36';" onmouseout="this.style.backgroundColor='transparent'; this.style.color='#c5a059';">Edit</asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div style="padding: 40px; text-align: center; color: #64748b; font-size: 14px;">No floors defined yet.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</div>

</ContentTemplate>
</asp:UpdatePanel>

<script>
    // Tab switching mechanism (pure text buttons, zero icons, strict inline CSS updates)
    function switchTab(index) {
        // Toggle Active Headers
        var btns = document.querySelectorAll('.tab-header-btn');
        for (var i = 0; i < btns.length; i++) {
            btns[i].style.color = '#64748b';
            btns[i].style.borderBottomColor = 'transparent';
            btns[i].style.backgroundColor = 'transparent';
        }
        btns[index].style.color = '#c5a059';
        btns[index].style.borderBottomColor = '#c5a059';
        btns[index].style.backgroundColor = '#ffffff';

        // Toggle Active Panes
        var panes = document.querySelectorAll('.tab-pane');
        for (var i = 0; i < panes.length; i++) {
            panes[i].style.display = 'none';
        }
        panes[index].style.display = 'block';

        // Persist tab index to ASP.NET HiddenField across postbacks
        var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
        if (hf) {
            var oldVal = hf.value;
            hf.value = index;
            if (oldVal !== index.toString()) {
                __doPostBack('<%= upDefine.UniqueID %>', 'tabChange:' + index);
            }
        }
    }

    // Restore active tab after ASP.NET postback triggers page reload
    window.onload = function() {
        var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
        if (hf && hf.value) {
            var activeIdx = parseInt(hf.value);
            switchTab(activeIdx);
        }
    };

    // Also restore active tab after AJAX async postbacks (UpdatePanel)
    if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function() {
            var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
            if (hf && hf.value) {
                var activeIdx = parseInt(hf.value);
                switchTab(activeIdx);
            }
        });
    }
</script>
</asp:Content>
