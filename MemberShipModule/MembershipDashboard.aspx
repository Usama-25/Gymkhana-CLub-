<%@ Page Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true" CodeFile="MembershipDashboard.aspx.cs" Inherits="GymkhanaNew.MemberShipModule.MembershipDashboard" %>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .membership-dashboard-page {
            display: flex;
            flex-direction: column;
            gap: 2rem;
        }

        .membership-dashboard-page .dashboard-hero {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 2rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .membership-dashboard-page .hero-text h1 {
            font-size: 1.75rem;
            color: var(--primary-dark);
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        .membership-dashboard-page .hero-text p {
            color: var(--text-muted);
            font-size: 0.95rem;
        }

        .membership-dashboard-page .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 1.25rem;
        }

        .membership-dashboard-page .stat-card {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 1.25rem;
            box-shadow: var(--shadow);
            border-left: 4px solid var(--primary);
            display: flex;
            flex-direction: column;
        }

        .membership-dashboard-page .stat-card.active-members {
            border-left-color: var(--success);
        }

        .membership-dashboard-page .stat-card.pending-apps {
            border-left-color: var(--warning);
        }

        .membership-dashboard-page .stat-card.cards-issued {
            border-left-color: var(--primary-lt);
        }

        .membership-dashboard-page .stat-label {
            font-size: 0.85rem;
            color: var(--text-muted);
            font-weight: 600;
            text-transform: uppercase;
            margin-bottom: 0.5rem;
        }

        .membership-dashboard-page .stat-value {
            font-size: 1.75rem;
            font-weight: 700;
            color: var(--text);
        }

        .membership-dashboard-page .section-title {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--primary-dark);
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid var(--accent);
        }

        .membership-dashboard-page .action-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
        }

        .membership-dashboard-page .action-card {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .membership-dashboard-page .action-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-lg);
            border-color: var(--primary-lt);
        }

        .membership-dashboard-page .action-icon {
            font-size: 2rem;
            margin-bottom: 0.75rem;
        }

        .membership-dashboard-page .action-card h3 {
            font-size: 1.1rem;
            color: var(--primary);
            margin-bottom: 0.5rem;
        }

        .membership-dashboard-page .action-card p {
            font-size: 0.875rem;
            color: var(--text-muted);
            margin-bottom: 1.25rem;
            flex: 1;
        }

        .membership-dashboard-page .btn-action {
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

        .membership-dashboard-page .btn-action:hover {
            background-color: var(--primary-lt);
        }
    </style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="membership-dashboard-page">
        <div class="dashboard-hero">
            <div class="hero-text">
                <h1>Membership Management Module</h1>
                <p>Register members, track application processing, issue RFID cards, and manage fee subscriptions.</p>
            </div>
        </div>

        <div class="stats-row">
            <div class="stat-card active-members">
                <span class="stat-label">Active Members</span>
                <asp:Label ID="lblActiveMembers" runat="server" CssClass="stat-value" Text="1,248" />
            </div>
            <div class="stat-card pending-apps">
                <span class="stat-label">Pending Applications</span>
                <asp:Label ID="lblPendingApps" runat="server" CssClass="stat-value" Text="34" />
            </div>
            <div class="stat-card cards-issued">
                <span class="stat-label">RFID Cards Issued</span>
                <asp:Label ID="lblCardsIssued" runat="server" CssClass="stat-value" Text="1,190" />
            </div>
            <div class="stat-card">
                <span class="stat-label">Total Fee Collections</span>
                <asp:Label ID="lblTotalFee" runat="server" CssClass="stat-value" Text="Rs. 4.8M" />
            </div>
        </div>

        <div>
            <h2 class="section-title">Member & Application Operations</h2>
            <div class="action-grid">
                <div class="action-card">
                    <div class="action-icon">ðŸ‘¤</div>
                    <h3>Member Profiles</h3>
                    <p>Create and manage comprehensive member profiles, contact info, and club privileges.</p>
                    <a href="~/MemberShipModule/MemberProfile.aspx" runat="server" class="btn-action">Manage Profiles</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">ðŸ”</div>
                    <h3>Member Directory Search</h3>
                    <p>Search active and archived club members by ID, name, category, or status.</p>
                    <a href="~/MemberShipModule/MemberSearch.aspx" runat="server" class="btn-action">Search Members</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">ðŸ“‹</div>
                    <h3>Application Processing</h3>
                    <p>Process new membership applications, interview scores, and committee approvals.</p>
                    <a href="~/MemberShipModule/ApplicationProcessing.aspx" runat="server" class="btn-action">Process Applications</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">ðŸ·ï¸</div>
                    <h3>Membership Types</h3>
                    <p>Configure membership categories, fee structures, and area access rights.</p>
                    <a href="~/MemberShipModule/ManageMembershipTypes.aspx" runat="server" class="btn-action">Configure Types</a>
                </div>
            </div>
        </div>

        <div>
            <h2 class="section-title">Cards & Financial Operations</h2>
            <div class="action-grid">
                <div class="action-card">
                    <div class="action-icon">ðŸªª</div>
                    <h3>RFID & Member Cards</h3>
                    <p>Issue smart RFID cards, track card statuses, replacement stickers, and access permissions.</p>
                    <a href="~/MemberShipModule/RFIDCard_Issuance.aspx" runat="server" class="btn-action">Card Issuance</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">ðŸ’³</div>
                    <h3>Member Fee & Receipts</h3>
                    <p>Collect monthly subscription fees, generate official receipts, and track dues.</p>
                    <a href="~/MemberShipModule/MemberFee.aspx" runat="server" class="btn-action">Collect Fees</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">ðŸ‘¨â€ðŸ‘©â€ðŸ‘§</div>
                    <h3>Dependents & Vehicles</h3>
                    <p>Register member family dependents, secondary cards, and authorized vehicle details.</p>
                    <a href="~/MemberShipModule/DependentsDetails.aspx" runat="server" class="btn-action">Manage Dependents</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">ðŸ¤</div>
                    <h3>Affiliated Clubs</h3>
                    <p>Manage reciprocal privileges with partner clubs and track visiting member logs.</p>
                    <a href="~/MemberShipModule/ManageAffiliatedClubs.aspx" runat="server" class="btn-action">Affiliated Clubs</a>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
