<%@ Page Title="Individual Member Check" Language="C#" MasterPageFile="~/Sports_Management/SiteSports.master" AutoEventWireup="true" CodeFile="IndividualMemberCheck.aspx.cs" Inherits="IndividualMemberCheck" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .search-section {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            border: 1px solid var(--gray-200);
            padding: 24px;
            margin-bottom: 24px;
        }

        .search-wrapper {
            display: flex;
            gap: 12px;
            align-items: center;
            max-width: 600px;
        }

        .search-input-container {
            position: relative;
            flex: 1;
        }

        .search-input-container i {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--gray-400);
            font-size: 16px;
        }

        .search-input-field {
            width: 100%;
            padding: 12px 14px 12px 42px;
            font-size: 15px;
            font-weight: 500;
            border: 2px solid var(--gray-200);
            border-radius: 8px;
            outline: none;
            transition: all 0.2s ease-in-out;
            color: var(--gray-800);
        }

        .search-input-field:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(30, 58, 95, 0.15);
        }

        .search-btn {
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 8px;
            padding: 12px 24px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease-in-out;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .search-btn:hover {
            background: var(--primary-dark);
            box-shadow: 0 4px 12px rgba(15, 43, 72, 0.2);
        }

        /* Profile Card Glassmorphism */
        .profile-container {
            display: grid;
            grid-template-columns: 320px 1fr;
            gap: 24px;
            margin-bottom: 24px;
        }

        .profile-card {
            background: white;
            border-radius: 16px;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            border: 1px solid var(--gray-200);
            padding: 24px;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .profile-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 8px;
            background: linear-gradient(90deg, var(--primary), var(--secondary));
        }

        .avatar-circle {
            width: 90px;
            height: 90px;
            background: var(--primary-light);
            color: var(--primary);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 36px;
            margin-bottom: 16px;
            border: 4px solid var(--gray-50);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
        }

        .profile-name {
            font-size: 20px;
            font-weight: 700;
            color: var(--gray-900);
            margin-bottom: 4px;
        }

        .profile-no {
            font-size: 13px;
            font-weight: 600;
            color: var(--gray-500);
            background: var(--gray-100);
            padding: 4px 12px;
            border-radius: 20px;
            margin-bottom: 16px;
        }

        .profile-details {
            width: 100%;
            border-top: 1px solid var(--gray-100);
            padding-top: 16px;
            display: grid;
            gap: 12px;
            text-align: left;
        }

        .detail-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 13px;
        }

        .detail-label {
            color: var(--gray-400);
            font-weight: 500;
        }

        .detail-value {
            color: var(--gray-800);
            font-weight: 600;
        }

        /* Custom Status Badge */
        .status-badge {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            padding: 4px 10px;
            border-radius: 12px;
            display: inline-block;
            letter-spacing: 0.5px;
        }

        .status-active {
            background-color: #d1fae5;
            color: #065f46;
            border: 1px solid #a7f3d0;
        }

        .status-inactive {
            background-color: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }

        .status-blocked {
            background-color: #fef3c7;
            color: #92400e;
            border: 1px solid #fde68a;
        }

        .relation-badge {
            background-color: #e0f2fe;
            color: #0369a1;
            border: 1px solid #bae6fd;
        }

        /* Alert Box */
        .alert-sports-card {
            background: linear-gradient(135deg, #fffbeb 0%, #fef3c7 100%);
            border: 1px solid #fde68a;
            border-radius: 12px;
            padding: 16px 20px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 16px;
            box-shadow: 0 4px 6px -1px rgba(251, 191, 36, 0.05);
            animation: pulse-border 2s infinite alternate;
        }

        @keyframes pulse-border {
            0% { border-color: #fde68a; }
            100% { border-color: #f59e0b; }
        }

        .alert-sports-card i {
            font-size: 24px;
            color: #d97706;
        }

        .alert-content h4 {
            font-size: 15px;
            font-weight: 700;
            color: #78350f;
            margin-bottom: 2px;
        }

        .alert-content p {
            font-size: 13px;
            color: #92400e;
        }

        /* Premium Table Grid */
        .grid-container {
            background: white;
            border-radius: 16px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
            border: 1px solid var(--gray-200);
            padding: 24px;
            margin-bottom: 24px;
        }

        .grid-title {
            font-size: 16px;
            font-weight: 700;
            color: var(--primary-dark);
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
            border-bottom: 2px solid var(--primary-light);
            padding-bottom: 10px;
        }

        .premium-grid {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }

        .premium-grid th {
            background-color: var(--gray-50);
            color: var(--gray-500);
            font-weight: 700;
            text-transform: uppercase;
            font-size: 11px;
            padding: 12px 16px;
            border-bottom: 2px solid var(--gray-200);
            text-align: left;
            letter-spacing: 0.5px;
        }

        .premium-grid td {
            padding: 14px 16px;
            border-bottom: 1px solid var(--gray-100);
            color: var(--gray-800);
            vertical-align: middle;
        }

        .premium-grid tr:last-child td {
            border-bottom: none;
        }

        .premium-grid tr:hover {
            background-color: #f8fafc;
        }

        .subscription-type-badge {
            font-size: 11px;
            font-weight: 600;
            padding: 3px 8px;
            border-radius: 6px;
            background-color: #f1f5f9;
            color: #475569;
            border: 1px solid #cbd5e1;
        }

        .subscription-type-badge.continuous {
            background-color: #eff6ff;
            color: #1d4ed8;
            border: 1px solid #bfdbfe;
        }

        .subscription-type-badge.monthly {
            background-color: #faf5ff;
            color: #7e22ce;
            border: 1px solid #e9d5ff;
        }

        .badge-grid-status {
            padding: 3px 8px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
        }

        .info-msg {
            text-align: center;
            padding: 40px;
            color: var(--gray-400);
            font-size: 15px;
            background: white;
            border-radius: 12px;
            border: 1px dashed var(--gray-300);
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="page-header-card">
        <h2><i class="fas fa-user-check" style="margin-right:10px;"></i> Individual Member Check</h2>
        <span class="badge">Verification & Status Check</span>
    </div>

    <!-- Search Section -->
    <div class="search-section">
        <div class="search-wrapper">
            <div class="search-input-container">
                <i class="fas fa-search"></i>
                <asp:TextBox ID="txtSearchMemberNo" runat="server" CssClass="search-input-field" placeholder="Enter Member No. (e.g. 1001, 1001-W1)..." AutoPostBack="false"></asp:TextBox>
            </div>
            <asp:LinkButton ID="btnSearch" runat="server" CssClass="search-btn" OnClick="btnSearch_Click">
                <i class="fas fa-check-double"></i> Check Member
            </asp:LinkButton>
        </div>
    </div>

    <!-- Message Label -->
    <asp:Label ID="lblMessage" runat="server" Style="display: block; margin-bottom: 20px; padding: 12px; border-radius: 8px; font-weight: 500; font-size: 14px;" Visible="false"></asp:Label>

    <!-- Initial State Placeholder -->
    <asp:Panel ID="pnlNoData" runat="server" CssClass="info-msg">
        <i class="fas fa-search-user" style="font-size: 40px; margin-bottom: 12px; display: block; color: var(--gray-300);"></i>
        Enter a member or dependent number above to verify status, subscriptions, and sports card details.
    </asp:Panel>

    <!-- Member Details & Information Panel -->
    <asp:Panel ID="pnlDetails" runat="server" Visible="false">
        
        <!-- Sports Card Alert Banner -->
        <asp:Panel ID="pnlSportsCardAlert" runat="server" CssClass="alert-sports-card" Visible="false">
            <i class="fas fa-exclamation-triangle"></i>
            <div class="alert-content">
                <h4>Active Sports Card Warning!</h4>
                <p><asp:Label ID="lblSportsCardAlertText" runat="server"></asp:Label></p>
            </div>
        </asp:Panel>

        <div class="profile-container">
            <!-- Left Side: Profile Card -->
            <div class="profile-card">
                <div class="avatar-circle">
                    <i class="fas fa-user-circle"></i>
                </div>
                <div class="profile-name">
                    <asp:Label ID="lblMemberName" runat="server"></asp:Label>
                </div>
                <div class="profile-no">
                    <asp:Label ID="lblMemberNo" runat="server"></asp:Label>
                </div>

                <div class="profile-details">
                    <div class="detail-item">
                        <span class="detail-label">Relationship</span>
                        <span id="badgeRelation" runat="server" class="status-badge relation-badge">
                            <asp:Label ID="lblRelation" runat="server"></asp:Label>
                        </span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Membership Status</span>
                        <span id="badgeStatus" runat="server" class="status-badge">
                            <asp:Label ID="lblStatus" runat="server"></asp:Label>
                        </span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Contact No.</span>
                        <span class="detail-value">
                            <asp:Label ID="lblContact" runat="server"></asp:Label>
                        </span>
                    </div>
                </div>
            </div>

            <!-- Right Side: Active Subscriptions Grid -->
            <div class="grid-container">
                <div class="grid-title">
                    <i class="fas fa-running" style="color: var(--primary);"></i> Active Subscriptions
                </div>

                <asp:GridView ID="gvActiveSubscriptions" runat="server" AutoGenerateColumns="False" CssClass="premium-grid" GridLines="None" ShowHeaderWhenEmpty="true">
                    <Columns>
                        <asp:BoundField DataField="SportName" HeaderText="Sport" HeaderStyle-CssClass="th" />
                        <asp:BoundField DataField="PackageName" HeaderText="Package" HeaderStyle-CssClass="th" />
                        <asp:TemplateField HeaderText="Subscription Type" HeaderStyle-CssClass="th">
                            <ItemTemplate>
                                <span class='subscription-type-badge <%# Convert.ToString(Eval("SubscriptionType")).Equals("Continuous", StringComparison.OrdinalIgnoreCase) ? "continuous" : "monthly" %>'>
                                    <%# Eval("SubscriptionType") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Base Fee" HeaderStyle-CssClass="th">
                            <ItemTemplate>
                                <%# Convert.ToDecimal(Eval("BaseFee")).ToString("N0") %> PKR
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="GST" HeaderStyle-CssClass="th">
                            <ItemTemplate>
                                <%# Convert.ToDecimal(Eval("GSTPercentage")).ToString("0") %>%
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="GST Amount" HeaderStyle-CssClass="th">
                            <ItemTemplate>
                                <%# Convert.ToDecimal(Eval("GSTAmount")).ToString("N0") %> PKR
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Total Fee" HeaderStyle-CssClass="th">
                            <ItemTemplate>
                                <strong style="color: var(--primary);"><%# Convert.ToDecimal(Eval("TotalAmount")).ToString("N0") %> PKR</strong>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Start Date" HeaderStyle-CssClass="th">
                            <ItemTemplate>
                                <%# Convert.ToDateTime(Eval("StartDate")).ToString("dd-MMM-yyyy") %>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="text-align:center; padding: 24px; color: var(--gray-400); font-style: italic;">
                            No active subscriptions found for this specific member number.
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

        <!-- Dependents Grid (Only visible if searched member is Self/Main Member) -->
        <asp:Panel ID="pnlDependents" runat="server" CssClass="grid-container" Visible="false">
            <div class="grid-title">
                <i class="fas fa-users" style="color: var(--primary);"></i> Registered Dependents & Spouses
            </div>

            <asp:GridView ID="gvDependents" runat="server" AutoGenerateColumns="False" CssClass="premium-grid" GridLines="None" ShowHeaderWhenEmpty="true">
                <Columns>
                    <asp:BoundField DataField="FullName" HeaderText="Dependent Name" HeaderStyle-CssClass="th" />
                    <asp:TemplateField HeaderText="Member No." HeaderStyle-CssClass="th">
                        <ItemTemplate>
                            <span style="font-family: monospace; font-weight: 600; color: var(--primary);"><%# Eval("MemberNo") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="Relation" HeaderText="Relationship" HeaderStyle-CssClass="th" />
                    <asp:TemplateField HeaderText="Membership Status" HeaderStyle-CssClass="th">
                        <ItemTemplate>
                            <span class='status-badge <%# GetStatusBadgeClass(Convert.ToString(Eval("Status"))) %>'>
                                <%# Eval("Status") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div style="text-align:center; padding: 24px; color: var(--gray-400); font-style: italic;">
                        No dependents registered under this main member.
                    </div>
                </EmptyDataTemplate>
            </asp:GridView>
        </asp:Panel>

    </asp:Panel>

</asp:Content>
