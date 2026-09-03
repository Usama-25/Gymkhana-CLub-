<%@ Page Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" AutoEventWireup="true" CodeFile="CafeDashboard.aspx.cs" Inherits="GymkhanaNew.Cafe.CafeDashboard" %>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .cafe-dashboard-page {
            display: flex;
            flex-direction: column;
            gap: 2rem;
        }

        .cafe-dashboard-page .dashboard-hero {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 2rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .cafe-dashboard-page .hero-text h1 {
            font-size: 1.75rem;
            color: var(--primary-dark);
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        .cafe-dashboard-page .hero-text p {
            color: var(--text-muted);
            font-size: 0.95rem;
        }

        .cafe-dashboard-page .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 1.25rem;
        }

        .cafe-dashboard-page .stat-card {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 1.25rem;
            box-shadow: var(--shadow);
            border-left: 4px solid var(--primary);
            display: flex;
            flex-direction: column;
        }

        .cafe-dashboard-page .stat-card.today-sales {
            border-left-color: var(--success);
        }

        .cafe-dashboard-page .stat-card.active-orders {
            border-left-color: var(--warning);
        }

        .cafe-dashboard-page .stat-card.open-counters {
            border-left-color: var(--primary-lt);
        }

        .cafe-dashboard-page .stat-label {
            font-size: 0.85rem;
            color: var(--text-muted);
            font-weight: 600;
            text-transform: uppercase;
            margin-bottom: 0.5rem;
        }

        .cafe-dashboard-page .stat-value {
            font-size: 1.75rem;
            font-weight: 700;
            color: var(--text);
        }

        .cafe-dashboard-page .section-title {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--primary-dark);
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid var(--accent);
        }

        .cafe-dashboard-page .action-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
        }

        .cafe-dashboard-page .action-card {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .cafe-dashboard-page .action-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-lg);
            border-color: var(--primary-lt);
        }

        .cafe-dashboard-page .action-icon {
            font-size: 2rem;
            margin-bottom: 0.75rem;
        }

        .cafe-dashboard-page .action-card h3 {
            font-size: 1.1rem;
            color: var(--primary);
            margin-bottom: 0.5rem;
        }

        .cafe-dashboard-page .action-card p {
            font-size: 0.875rem;
            color: var(--text-muted);
            margin-bottom: 1.25rem;
            flex: 1;
        }

        .cafe-dashboard-page .btn-action {
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

        .cafe-dashboard-page .btn-action:hover {
            background-color: var(--primary-lt);
        }
    </style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="cafe-dashboard-page">
        <div class="dashboard-hero">
            <div class="hero-text">
                <h1>Cafe & POS Management Module</h1>
                <p>Manage point-of-sale ordering, kitchen display screens, menu items, and daily cashier operations.</p>
            </div>
        </div>

        <div class="stats-row">
            <div class="stat-card today-sales">
                <span class="stat-label">Today's Sales</span>
                <asp:Label ID="lblTodaySales" runat="server" CssClass="stat-value" Text="Rs. 142,500" />
            </div>
            <div class="stat-card active-orders">
                <span class="stat-label">Active KOT Orders</span>
                <asp:Label ID="lblActiveOrders" runat="server" CssClass="stat-value" Text="18" />
            </div>
            <div class="stat-card open-counters">
                <span class="stat-label">Open Counters</span>
                <asp:Label ID="lblOpenCounters" runat="server" CssClass="stat-value" Text="4" />
            </div>
            <div class="stat-card">
                <span class="stat-label">Total Items Sold</span>
                <asp:Label ID="lblItemsSold" runat="server" CssClass="stat-value" Text="385" />
            </div>
        </div>

        <div>
            <h2 class="section-title">Point of Sale & Kitchen Operations</h2>
            <div class="action-grid">
                <div class="action-card">
                    <div class="action-icon">🖥️</div>
                    <h3>POS Terminal</h3>
                    <p>Process quick member beverage orders, takeaway billing, and table dining invoices.</p>
                    <a href="~/Cafe/Pos.aspx" runat="server" class="btn-action">Open POS Terminal</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">🍳</div>
                    <h3>Kitchen Order Screen (KDS)</h3>
                    <p>Live display of incoming Kitchen Order Tickets (KOT) for chefs and preparation staff.</p>
                    <a href="~/Cafe/KitchenScreen.aspx" runat="server" class="btn-action">View Kitchen Screen</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">💵</div>
                    <h3>Cashier Operations</h3>
                    <p>Manage cash drawers, process payments, apply member discounts, and close counters.</p>
                    <a href="~/Cafe/cashier.aspx" runat="server" class="btn-action">Cashier Panel</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">🔍</div>
                    <h3>Search KOT Orders</h3>
                    <p>Track pending, completed, or cancelled kitchen orders and verify order statuses.</p>
                    <a href="~/Cafe/SearchKOT.aspx" runat="server" class="btn-action">Search Orders</a>
                </div>
            </div>
        </div>

        <div>
            <h2 class="section-title">Menu Setup & Financial Reports</h2>
            <div class="action-grid">
                <div class="action-card">
                    <div class="action-icon">☕</div>
                    <h3>Cafe Menu Setup</h3>
                    <p>Configure cafe food and beverage categories, prices, recipes, and item availability.</p>
                    <a href="~/Cafe/ResturantMenusetup.aspx" runat="server" class="btn-action">Configure Menu</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">🏢</div>
                    <h3>Outlet Setup</h3>
                    <p>Define cafe counter locations, printer assignments, and department permissions.</p>
                    <a href="~/Cafe/OutletSetup.aspx" runat="server" class="btn-action">Manage Outlets</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">📊</div>
                    <h3>Reports Dashboard</h3>
                    <p>View daily sales summaries, item-wise consumption reports, and revenue analytics.</p>
                    <a href="~/Cafe/ReportsDashboard.aspx" runat="server" class="btn-action">View Reports</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">🔒</div>
                    <h3>Counter Shift Closing</h3>
                    <p>Perform shift reconciliation, verify cash collections, and generate shift summary slips.</p>
                    <a href="~/Cafe/Counterclose.aspx" runat="server" class="btn-action">Shift Closing</a>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
