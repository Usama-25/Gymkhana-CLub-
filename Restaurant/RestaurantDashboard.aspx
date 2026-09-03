<%@ Page Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" AutoEventWireup="true" CodeFile="RestaurantDashboard.aspx.cs" Inherits="GymkhanaNew.Restaurant.RestaurantDashboard" %>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .restaurant-dashboard-page {
            display: flex;
            flex-direction: column;
            gap: 2rem;
        }

        .restaurant-dashboard-page .dashboard-hero {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 2rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .restaurant-dashboard-page .hero-text h1 {
            font-size: 1.75rem;
            color: var(--primary-dark);
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        .restaurant-dashboard-page .hero-text p {
            color: var(--text-muted);
            font-size: 0.95rem;
        }

        .restaurant-dashboard-page .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 1.25rem;
        }

        .restaurant-dashboard-page .stat-card {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 1.25rem;
            box-shadow: var(--shadow);
            border-left: 4px solid var(--primary);
            display: flex;
            flex-direction: column;
        }

        .restaurant-dashboard-page .stat-card.dining-sales {
            border-left-color: var(--success);
        }

        .restaurant-dashboard-page .stat-card.occupied-tables {
            border-left-color: var(--warning);
        }

        .restaurant-dashboard-page .stat-card.open-orders {
            border-left-color: var(--primary-lt);
        }

        .restaurant-dashboard-page .stat-label {
            font-size: 0.85rem;
            color: var(--text-muted);
            font-weight: 600;
            text-transform: uppercase;
            margin-bottom: 0.5rem;
        }

        .restaurant-dashboard-page .stat-value {
            font-size: 1.75rem;
            font-weight: 700;
            color: var(--text);
        }

        .restaurant-dashboard-page .section-title {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--primary-dark);
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid var(--accent);
        }

        .restaurant-dashboard-page .action-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
        }

        .restaurant-dashboard-page .action-card {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .restaurant-dashboard-page .action-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-lg);
            border-color: var(--primary-lt);
        }

        .restaurant-dashboard-page .action-icon {
            font-size: 2rem;
            margin-bottom: 0.75rem;
        }

        .restaurant-dashboard-page .action-card h3 {
            font-size: 1.1rem;
            color: var(--primary);
            margin-bottom: 0.5rem;
        }

        .restaurant-dashboard-page .action-card p {
            font-size: 0.875rem;
            color: var(--text-muted);
            margin-bottom: 1.25rem;
            flex: 1;
        }

        .restaurant-dashboard-page .btn-action {
            display: inline-block;
            text-align: center;
            background-color: var(--primary);
            color: var(--surface);
            padding: 0.5rem 1rem;
            border-radius: var(--radius);
            text-decoration: none;
            font-weight: 600;
            font-size: 0.875rem;
            transition: background-color 0.2s ease;
        }

        .restaurant-dashboard-page .btn-action:hover {
            background-color: var(--primary-lt);
        }
    </style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="restaurant-dashboard-page">
        <div class="dashboard-hero">
            <div class="hero-text">
                <h1>Restaurant Management System</h1>
                <p>Manage dining table reservations, fine dining orders, kitchen tickets, and menu configurations.</p>
            </div>
        </div>

        <div class="stats-row">
            <div class="stat-card dining-sales">
                <span class="stat-label">Today's Dining Revenue</span>
                <asp:Label ID="lblDiningRevenue" runat="server" CssClass="stat-value" Text="Rs. 285,400" />
            </div>
            <div class="stat-card occupied-tables">
                <span class="stat-label">Tables Seated</span>
                <asp:Label ID="lblSeatedTables" runat="server" CssClass="stat-value" Text="16 / 25" />
            </div>
            <div class="stat-card open-orders">
                <span class="stat-label">Kitchen Tickets Open</span>
                <asp:Label ID="lblOpenTickets" runat="server" CssClass="stat-value" Text="9" />
            </div>
            <div class="stat-card">
                <span class="stat-label">Average Table Turnover</span>
                <asp:Label ID="lblTurnover" runat="server" CssClass="stat-value" Text="42 mins" />
            </div>
        </div>

        <div>
            <h2 class="section-title">Dining Room Operations</h2>
            <div class="action-grid">
                <div class="action-card">
                    <div class="action-icon">🍷</div>
                    <h3>Restaurant Dining Menu</h3>
                    <p>Configure a la carte dining items, chef specials, courses, and pricing schedules.</p>
                    <a href="~/Restaurant/Menu.aspx" runat="server" class="btn-action">Configure Menu</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">🍽️</div>
                    <h3>Table & Order Management</h3>
                    <p>Assign tables to servers, take member food orders, and route orders to kitchen stations.</p>
                    <a href="~/Restaurant/Default.aspx" runat="server" class="btn-action">Order Terminal</a>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
