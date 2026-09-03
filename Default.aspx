<%@ Page Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="GymkhanaNew.Default" %>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .dashboard-page {
            display: flex;
            flex-direction: column;
            gap: 2rem;
        }

        .dashboard-page .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background-color: var(--surface);
            padding: 1.5rem;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow);
        }

        .dashboard-page .page-header h1 {
            font-size: 1.5rem;
            color: var(--primary-dark);
            font-weight: 700;
        }

        .dashboard-page .page-header p {
            color: var(--text-muted);
            font-size: 0.875rem;
        }

        .dashboard-page .module-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
        }

        .dashboard-page .module-card {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .dashboard-page .module-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-lg);
            border-color: var(--primary-lt);
        }

        .dashboard-page .module-icon {
            font-size: 2.5rem;
            margin-bottom: 1rem;
        }

        .dashboard-page .module-card h2 {
            font-size: 1.25rem;
            color: var(--primary);
            margin-bottom: 0.5rem;
        }

        .dashboard-page .module-card p {
            font-size: 0.875rem;
            color: var(--text-muted);
            margin-bottom: 1.5rem;
            flex: 1;
        }

        .dashboard-page .btn-module {
            display: inline-block;
            text-align: center;
            background-color: var(--primary);
            color: var(--surface);
            padding: 0.6rem 1.2rem;
            border-radius: var(--radius);
            text-decoration: none;
            font-weight: 600;
            font-size: 0.875rem;
            transition: background-color 0.2s ease;
        }

        .dashboard-page .btn-module:hover {
            background-color: var(--primary-lt);
        }
    </style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-page">
        <div class="page-header">
            <div>
                <h1>Gymkhana Management System</h1>
                <p>Select a module to manage operations, bookings, and records.</p>
            </div>
        </div>

        <div class="module-grid">
            <div class="module-card">
                <div>
                    <div class="module-icon">🏛️</div>
                    <h2>Banquet Systems</h2>
                    <p>Manage hall reservations, event schedules, catering menus, and billing for private events.</p>
                </div>
                <a href="~/Baquetsystems/BanquetDashboard.aspx" runat="server" class="btn-module">Access Module</a>
            </div>

            <div class="module-card">
                <div>
                    <div class="module-icon">☕</div>
                    <h2>Cafe Management</h2>
                    <p>Track point-of-sale orders, inventory, beverage menus, and daily sales reports.</p>
                </div>
                <a href="~/Cafe/CafeDashboard.aspx" runat="server" class="btn-module">Access Module</a>
            </div>

            <div class="module-card">
                <div>
                    <div class="module-icon">🛌</div>
                    <h2>Guest Room Management</h2>
                    <p>Handle room check-ins, check-outs, reservations, housekeeping, and member stay billing.</p>
                </div>
                <a href="~/GuestRoomM/GuestRoomDashboard.aspx" runat="server" class="btn-module">Access Module</a>
            </div>

            <div class="module-card">
                <div>
                    <div class="module-icon">📚</div>
                    <h2>Library Management</h2>
                    <p>Catalog books, process member lendings/returns, track late fees, and manage inventory.</p>
                </div>
                <a href="~/Library Management/LibraryDashboard.aspx" runat="server" class="btn-module">Access Module</a>
            </div>

            <div class="module-card">
                <div>
                    <div class="module-icon">🪪</div>
                    <h2>Membership Module</h2>
                    <p>Register club members, manage subscription tiers, track dues, and process member profiles.</p>
                </div>
                <a href="~/MemberShipModule/MembershipDashboard.aspx" runat="server" class="btn-module">Access Module</a>
            </div>

            <div class="module-card">
                <div>
                    <div class="module-icon">💳</div>
                    <h2>Member Billing</h2>
                    <p>Define subscription rates, senior age concessions, billing cycles, and financial accounts.</p>
                </div>
                <a href="~/Member_Billing/DefineSubscription.aspx" runat="server" class="btn-module">Access Module</a>
            </div>

            <div class="module-card">
                <div>
                    <div class="module-icon">🍽️</div>
                    <h2>Restaurant System</h2>
                    <p>Manage table reservations, dining orders, kitchen tickets, and fine dining billing.</p>
                </div>
                <a href="~/Restaurant/RestaurantDashboard.aspx" runat="server" class="btn-module">Access Module</a>
            </div>
        </div>
    </div>
</asp:Content>
