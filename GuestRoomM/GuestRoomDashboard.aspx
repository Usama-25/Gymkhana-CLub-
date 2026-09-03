<%@ Page Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" AutoEventWireup="true" CodeFile="GuestRoomDashboard.aspx.cs" Inherits="GymkhanaNew.GuestRoomM.GuestRoomDashboard" %>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .guestroom-dashboard-page {
            display: flex;
            flex-direction: column;
            gap: 2rem;
        }

        .guestroom-dashboard-page .dashboard-hero {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 2rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .guestroom-dashboard-page .hero-text h1 {
            font-size: 1.75rem;
            color: var(--primary-dark);
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        .guestroom-dashboard-page .hero-text p {
            color: var(--text-muted);
            font-size: 0.95rem;
        }

        .guestroom-dashboard-page .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 1.25rem;
        }

        .guestroom-dashboard-page .stat-card {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 1.25rem;
            box-shadow: var(--shadow);
            border-left: 4px solid var(--primary);
            display: flex;
            flex-direction: column;
        }

        .guestroom-dashboard-page .stat-card.occupied {
            border-left-color: var(--success);
        }

        .guestroom-dashboard-page .stat-card.checkouts {
            border-left-color: var(--warning);
        }

        .guestroom-dashboard-page .stat-card.available {
            border-left-color: var(--primary-lt);
        }

        .guestroom-dashboard-page .stat-label {
            font-size: 0.85rem;
            color: var(--text-muted);
            font-weight: 600;
            text-transform: uppercase;
            margin-bottom: 0.5rem;
        }

        .guestroom-dashboard-page .stat-value {
            font-size: 1.75rem;
            font-weight: 700;
            color: var(--text);
        }

        .guestroom-dashboard-page .section-title {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--primary-dark);
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid var(--accent);
        }

        .guestroom-dashboard-page .action-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
        }

        .guestroom-dashboard-page .action-card {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .guestroom-dashboard-page .action-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-lg);
            border-color: var(--primary-lt);
        }

        .guestroom-dashboard-page .action-icon {
            font-size: 2rem;
            margin-bottom: 0.75rem;
        }

        .guestroom-dashboard-page .action-card h3 {
            font-size: 1.1rem;
            color: var(--primary);
            margin-bottom: 0.5rem;
        }

        .guestroom-dashboard-page .action-card p {
            font-size: 0.875rem;
            color: var(--text-muted);
            margin-bottom: 1.25rem;
            flex: 1;
        }

        .guestroom-dashboard-page .btn-action {
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

        .guestroom-dashboard-page .btn-action:hover {
            background-color: var(--primary-lt);
        }
    </style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="guestroom-dashboard-page">
        <div class="dashboard-hero">
            <div class="hero-text">
                <h1>Guest Room Management Module</h1>
                <p>Process room check-ins, reservations, housekeeping status, and guest billing statements.</p>
            </div>
        </div>

        <div class="stats-row">
            <div class="stat-card occupied">
                <span class="stat-label">Occupied Rooms</span>
                <asp:Label ID="lblOccupied" runat="server" CssClass="stat-value" Text="24" />
            </div>
            <div class="stat-card available">
                <span class="stat-label">Available Rooms</span>
                <asp:Label ID="lblAvailable" runat="server" CssClass="stat-value" Text="12" />
            </div>
            <div class="stat-card checkouts">
                <span class="stat-label">Today's Check-outs</span>
                <asp:Label ID="lblTodayCheckouts" runat="server" CssClass="stat-value" Text="6" />
            </div>
            <div class="stat-card">
                <span class="stat-label">Occupancy Rate</span>
                <asp:Label ID="lblOccupancyRate" runat="server" CssClass="stat-value" Text="66.7%" />
            </div>
        </div>

        <div>
            <h2 class="section-title">Front Desk & Reservations</h2>
            <div class="action-grid">
                <div class="action-card">
                    <div class="action-icon">🔑</div>
                    <h3>Room Check-In</h3>
                    <p>Process member and guest check-ins, assign rooms, and collect advance deposits.</p>
                    <a href="~/GuestRoomM/RoomCheckIn.aspx" runat="server" class="btn-action">New Check-In</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">📅</div>
                    <h3>Room Reservations</h3>
                    <p>Manage room booking requests, check future availability calendars, and confirm stays.</p>
                    <a href="~/GuestRoomM/RoomReservation.aspx" runat="server" class="btn-action">Manage Reservations</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">🛋️</div>
                    <h3>Occupied Rooms & Status</h3>
                    <p>View real-time list of currently occupied rooms and member stay details.</p>
                    <a href="~/GuestRoomM/OccupiedRooms.aspx" runat="server" class="btn-action">View Occupied Rooms</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">🚪</div>
                    <h3>Room Check-Out</h3>
                    <p>Finalize guest room billing, record additional room charges, and process check-outs.</p>
                    <a href="~/GuestRoomM/RoomCheckOut.aspx" runat="server" class="btn-action">Process Check-Out</a>
                </div>
            </div>
        </div>

        <div>
            <h2 class="section-title">Billing & Room Maintenance</h2>
            <div class="action-grid">
                <div class="action-card">
                    <div class="action-icon">🧾</div>
                    <h3>Guest Billing & Ledger</h3>
                    <p>Manage room folios, process room service charges, and view guest payment history.</p>
                    <a href="~/GuestRoomM/ManageBills.aspx" runat="server" class="btn-action">Manage Guest Bills</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">🧹</div>
                    <h3>Housekeeping Management</h3>
                    <p>Track clean, dirty, and under-maintenance room statuses for room attendants.</p>
                    <a href="~/GuestRoomM/RoomHousekeeping.aspx" runat="server" class="btn-action">Housekeeping Panel</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">🏨</div>
                    <h3>Room Definitions</h3>
                    <p>Define room types, suites, tariffs, amenities, and facility charges.</p>
                    <a href="~/GuestRoomM/RoomDefinition.aspx" runat="server" class="btn-action">Configure Rooms</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">📈</div>
                    <h3>Occupancy Reports</h3>
                    <p>Generate detailed room occupancy statistics, revenue summaries, and forecasts.</p>
                    <a href="~/GuestRoomM/OccupancyReport.aspx" runat="server" class="btn-action">View Reports</a>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
