<%@ Page Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" AutoEventWireup="true" CodeFile="BanquetDashboard.aspx.cs" Inherits="GymkhanaNew.Baquetsystems.BanquetDashboard" %>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .banquet-dashboard-page {
            display: flex;
            flex-direction: column;
            gap: 2rem;
        }

        .banquet-dashboard-page .dashboard-hero {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 2rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .banquet-dashboard-page .hero-text h1 {
            font-size: 1.75rem;
            color: var(--primary-dark);
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        .banquet-dashboard-page .hero-text p {
            color: var(--text-muted);
            font-size: 0.95rem;
        }

        .banquet-dashboard-page .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 1.25rem;
        }

        .banquet-dashboard-page .stat-card {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 1.25rem;
            box-shadow: var(--shadow);
            border-left: 4px solid var(--primary);
            display: flex;
            flex-direction: column;
        }

        .banquet-dashboard-page .stat-card.upcoming-events {
            border-left-color: var(--success);
        }

        .banquet-dashboard-page .stat-card.pending-confirmations {
            border-left-color: var(--warning);
        }

        .banquet-dashboard-page .stat-card.halls-booked {
            border-left-color: var(--primary-lt);
        }

        .banquet-dashboard-page .stat-label {
            font-size: 0.85rem;
            color: var(--text-muted);
            font-weight: 600;
            text-transform: uppercase;
            margin-bottom: 0.5rem;
        }

        .banquet-dashboard-page .stat-value {
            font-size: 1.75rem;
            font-weight: 700;
            color: var(--text);
        }

        .banquet-dashboard-page .section-title {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--primary-dark);
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid var(--accent);
        }

        .banquet-dashboard-page .action-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
        }

        .banquet-dashboard-page .action-card {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .banquet-dashboard-page .action-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-lg);
            border-color: var(--primary-lt);
        }

        .banquet-dashboard-page .action-icon {
            font-size: 2rem;
            margin-bottom: 0.75rem;
        }

        .banquet-dashboard-page .action-card h3 {
            font-size: 1.1rem;
            color: var(--primary);
            margin-bottom: 0.5rem;
        }

        .banquet-dashboard-page .action-card p {
            font-size: 0.875rem;
            color: var(--text-muted);
            margin-bottom: 1.25rem;
            flex: 1;
        }

        .banquet-dashboard-page .btn-action {
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

        .banquet-dashboard-page .btn-action:hover {
            background-color: var(--primary-lt);
        }
    </style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="banquet-dashboard-page">
        <div class="dashboard-hero">
            <div class="hero-text">
                <h1>Banquet Systems & Event Management</h1>
                <p>Manage hall bookings, custom event packages, catering menus, and private member functions.</p>
            </div>
        </div>

        <div class="stats-row">
            <div class="stat-card upcoming-events">
                <span class="stat-label">Upcoming Events This Month</span>
                <asp:Label ID="lblUpcomingEvents" runat="server" CssClass="stat-value" Text="12" />
            </div>
            <div class="stat-card halls-booked">
                <span class="stat-label">Halls Reserved Today</span>
                <asp:Label ID="lblHallsReserved" runat="server" CssClass="stat-value" Text="3" />
            </div>
            <div class="stat-card pending-confirmations">
                <span class="stat-label">Pending Inquiries</span>
                <asp:Label ID="lblPendingInquiries" runat="server" CssClass="stat-value" Text="5" />
            </div>
            <div class="stat-card">
                <span class="stat-label">Banquet Revenue</span>
                <asp:Label ID="lblBanquetRevenue" runat="server" CssClass="stat-value" Text="Rs. 2.4M" />
            </div>
        </div>

        <div>
            <h2 class="section-title">Bookings & Catering Operations</h2>
            <div class="action-grid">
                <div class="action-card">
                    <div class="action-icon">ðŸ›ï¸</div>
                    <h3>Event Setup & Hall Booking</h3>
                    <p>Schedule hall reservations, select dates, assign event managers, and configure setup arrangements.</p>
                    <a href="~/Baquetsystems/EventSetup.aspx" runat="server" class="btn-action">Setup Event</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">ðŸ½ï¸</div>
                    <h3>Booking Menu Selection</h3>
                    <p>Configure customized catering menus, per-head rates, dishes, and beverage packages.</p>
                    <a href="~/Baquetsystems/BookingMenu.aspx" runat="server" class="btn-action">Select Catering Menu</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">ðŸ”</div>
                    <h3>Search Banquet Bookings</h3>
                    <p>Search reservation records by date, hall name, member ID, or event type.</p>
                    <a href="~/Baquetsystems/BanquetBookingsearch.aspx" runat="server" class="btn-action">Search Bookings</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">ðŸ“œ</div>
                    <h3>Search Menu Packages</h3>
                    <p>View saved menu packages and historical catering orders for event audits.</p>
                    <a href="~/Baquetsystems/BookingMenuSearch.aspx" runat="server" class="btn-action">Search Packages</a>
                </div>
            </div>
        </div>

        <div>
            <h2 class="section-title">Packages & Special Deals</h2>
            <div class="action-grid">
                <div class="action-card">
                    <div class="action-icon">ðŸŽ</div>
                    <h3>Add Package Deals</h3>
                    <p>Create promotional banquet bundles, wedding packages, and seasonal event deals.</p>
                    <a href="~/Baquetsystems/AddPackageDeals.aspx" runat="server" class="btn-action">Manage Packages</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">ðŸ¤</div>
                    <h3>Assign Deals to Events</h3>
                    <p>Apply special discount deals and package privileges to confirmed member bookings.</p>
                    <a href="~/Baquetsystems/AssignDeals.aspx" runat="server" class="btn-action">Assign Deals</a>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

