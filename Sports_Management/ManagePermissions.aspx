<%@ Page Title="Manage Permissions" Language="C#" MasterPageFile="~/Sports_Management/SiteSports.master" AutoEventWireup="true" CodeFile="ManagePermissions.aspx.cs" Inherits="ManagePermissions" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .role-section {
            transition: all 0.3s ease;
        }
        .btn-action {
            padding: 6px 12px;
            font-size: 12px;
            border-radius: 4px;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
        }
        .btn-edit {
            background-color: var(--primary-light);
            color: var(--primary);
            margin-right: 5px;
        }
        .btn-delete {
            background-color: #fee2e2;
            color: var(--danger);
        }
        .sports-list-container {
            border: 1px solid var(--gray-300);
            border-radius: 6px;
            padding: 12px;
            max-height: 200px;
            overflow-y: auto;
            background-color: var(--gray-50);
        }
        .sports-list-container label {
            font-weight: normal !important;
            display: inline !important;
            margin-left: 8px;
            font-size: 13px !important;
            color: var(--gray-800) !important;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-header-card">
        <h2><i class="fas fa-user-shield" style="margin-right:10px;"></i> Manage Permissions</h2>
        <span class="badge">Roles & Access Rights</span>
    </div>

    <!-- Message Label -->
    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert" style="display:block; margin-bottom: 20px; padding: 15px; border-radius: 8px; font-weight: bold;"></asp:Label>

    <div style="display:flex; gap:20px; flex-wrap:wrap; align-items:flex-start;">
        
        <!-- Left Side: Add/Edit User -->
        <div class="card" style="flex:1; min-width:320px;">
            <div class="card-header">
                <asp:Literal ID="litFormTitle" runat="server" Text="Add New User"></asp:Literal>
            </div>
            <div class="card-body">
                <asp:HiddenField ID="hfEmpID" runat="server" />

                <!-- Username -->
                <div class="form-group">
                    <label>Username *</label>
                    <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="e.g. jameel_op"></asp:TextBox>
                </div>

                <!-- Password -->
                <div class="form-group">
                    <label>Password *</label>
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Enter password"></asp:TextBox>
                    <small style="color:var(--gray-500); display:block; margin-top:4px;">
                        <asp:Literal ID="litPassHint" runat="server" Text="Password is required for new users."></asp:Literal>
                    </small>
                </div>

                <!-- Role -->
                <div class="form-group">
                    <label>Role *</label>
                    <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlRole_SelectedIndexChanged">
                        <asp:ListItem Text="Operator (Assigned Sports Access)" Value="Operator" Selected="True"></asp:ListItem>
                        <asp:ListItem Text="Admin (Full Access)" Value="Admin"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <!-- Sports Permissions Checklist -->
                <asp:Panel ID="pnlSportsAccess" runat="server" class="form-group role-section">
                    <label>Assigned Sports (Check all that apply)</label>
                    <div class="sports-list-container">
                        <asp:CheckBoxList ID="cblSports" runat="server" RepeatLayout="UnorderedList" CssClass="checkbox-list"></asp:CheckBoxList>
                    </div>
                </asp:Panel>

                <!-- Pages Permissions Checklist -->
                <asp:Panel ID="pnlPagesAccess" runat="server" class="form-group role-section">
                    <label>Assigned Pages (Check all that apply)</label>
                    <div class="sports-list-container" style="max-height: 250px;">
                        <asp:CheckBoxList ID="cblPages" runat="server" RepeatLayout="UnorderedList" CssClass="checkbox-list">
                            <asp:ListItem Text="Member Subscriptions" Value="MemberSubscriptions.aspx"></asp:ListItem>
                            <asp:ListItem Text="Subscription Packages" Value="SubscriptionDefinition.aspx"></asp:ListItem>
                            <asp:ListItem Text="Discount Policy" Value="DiscountPolicy.aspx"></asp:ListItem>
                            <asp:ListItem Text="Sports Definition" Value="SportsDefinition.aspx"></asp:ListItem>
                            <asp:ListItem Text="Manage Sports Cards" Value="ManageSportsCard.aspx"></asp:ListItem>
                            <asp:ListItem Text="Individual Member Check" Value="IndividualMemberCheck.aspx"></asp:ListItem>
                            <asp:ListItem Text="Daily POS (1-Day)" Value="DailyPOS.aspx"></asp:ListItem>
                            <asp:ListItem Text="Member Ledger" Value="MemberLedger.aspx"></asp:ListItem>
                            <asp:ListItem Text="Payment & Billing" Value="PaymentProcess.aspx"></asp:ListItem>
                            <asp:ListItem Text="Facility Access" Value="FacilityAccess.aspx"></asp:ListItem>
                            <asp:ListItem Text="Manage Permissions" Value="ManagePermissions.aspx"></asp:ListItem>
                            <asp:ListItem Text="Report - Member Subscriptions" Value="ReportMemberSubscriptions.aspx"></asp:ListItem>
                            <asp:ListItem Text="Report - Individual Member" Value="ReportIndividualMember.aspx"></asp:ListItem>
                            <asp:ListItem Text="Report - Access Logs" Value="ReportAccessLogs.aspx"></asp:ListItem>
                        </asp:CheckBoxList>
                    </div>
                </asp:Panel>

                <div style="margin-top:20px; display:flex; gap:10px;">
                    <asp:Button ID="btnSave" runat="server" Text="Save User" CssClass="btn btn-primary" OnClick="btnSave_Click" />
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn" style="background-color:var(--gray-300); color:var(--gray-800);" OnClick="btnCancel_Click" Visible="false" />
                </div>
            </div>
        </div>

        <!-- Right Side: Existing Users & Rights -->
        <div class="card" style="flex:2; min-width:450px;">
            <div class="card-header">System Users</div>
            <div class="card-body" style="padding:0;">
                <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="False" CssClass="grid-view" GridLines="None" OnRowCommand="gvUsers_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="Emp_ID" HeaderText="Emp ID" />
                        <asp:BoundField DataField="Username" HeaderText="Username" />
                        <asp:TemplateField HeaderText="Role">
                            <ItemTemplate>
                                <span style='<%# Eval("Role").ToString() == "Admin" ? "color:var(--secondary); font-weight:bold;" : "color:var(--gray-700);" %>'>
                                    <%# Eval("Role") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Sports Access">
                            <ItemTemplate>
                                <i><%# Eval("Role").ToString() == "Admin" ? "ALL SPORTS" : (string.IsNullOrEmpty(Eval("AllowedSports").ToString()) ? "No Access Granted" : Eval("AllowedSports")) %></i>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Page Access">
                            <ItemTemplate>
                                <i><%# Eval("Role").ToString() == "Admin" ? "ALL PAGES" : (string.IsNullOrEmpty(Eval("AllowedPages").ToString()) ? "No Access" : Eval("AllowedPages")) %></i>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditUser" CommandArgument='<%# Eval("Emp_ID") %>' CssClass="btn-action btn-edit">
                                    <i class="fas fa-edit"></i> Edit
                                </asp:LinkButton>
                                <asp:LinkButton ID="lnkDelete" runat="server" CommandName="DeleteUser" CommandArgument='<%# Eval("Emp_ID") %>' CssClass="btn-action btn-delete" OnClientClick="return confirm('Are you sure you want to delete this user?');">
                                    <i class="fas fa-trash-alt"></i> Delete
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

    </div>
</asp:Content>
