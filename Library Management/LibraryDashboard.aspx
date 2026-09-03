<%@ Page Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" AutoEventWireup="true" CodeFile="LibraryDashboard.aspx.cs" Inherits="GymkhanaNew.LibraryManagement.LibraryDashboard" %>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .library-dashboard-page {
            display: flex;
            flex-direction: column;
            gap: 2rem;
        }

        .library-dashboard-page .dashboard-hero {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 2rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .library-dashboard-page .hero-text h1 {
            font-size: 1.75rem;
            color: var(--primary-dark);
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        .library-dashboard-page .hero-text p {
            color: var(--text-muted);
            font-size: 0.95rem;
        }

        .library-dashboard-page .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 1.25rem;
        }

        .library-dashboard-page .stat-card {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 1.25rem;
            box-shadow: var(--shadow);
            border-left: 4px solid var(--primary);
            display: flex;
            flex-direction: column;
        }

        .library-dashboard-page .stat-card.total-books {
            border-left-color: var(--primary-lt);
        }

        .library-dashboard-page .stat-card.issued-books {
            border-left-color: var(--warning);
        }

        .library-dashboard-page .stat-card.overdue-books {
            border-left-color: var(--danger);
        }

        .library-dashboard-page .stat-label {
            font-size: 0.85rem;
            color: var(--text-muted);
            font-weight: 600;
            text-transform: uppercase;
            margin-bottom: 0.5rem;
        }

        .library-dashboard-page .stat-value {
            font-size: 1.75rem;
            font-weight: 700;
            color: var(--text);
        }

        .library-dashboard-page .section-title {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--primary-dark);
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid var(--accent);
        }

        .library-dashboard-page .action-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
        }

        .library-dashboard-page .action-card {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .library-dashboard-page .action-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-lg);
            border-color: var(--primary-lt);
        }

        .library-dashboard-page .action-icon {
            font-size: 2rem;
            margin-bottom: 0.75rem;
        }

        .library-dashboard-page .action-card h3 {
            font-size: 1.1rem;
            color: var(--primary);
            margin-bottom: 0.5rem;
        }

        .library-dashboard-page .action-card p {
            font-size: 0.875rem;
            color: var(--text-muted);
            margin-bottom: 1.25rem;
            flex: 1;
        }

        .library-dashboard-page .btn-action {
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

        .library-dashboard-page .btn-action:hover {
            background-color: var(--primary-lt);
        }
    </style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="library-dashboard-page">
        <div class="dashboard-hero">
            <div class="hero-text">
                <h1>Library Management Module</h1>
                <p>Catalog library inventory, process book borrowing/returns, track member ledgers, and manage fines.</p>
            </div>
        </div>

        <div class="stats-row">
            <div class="stat-card total-books">
                <span class="stat-label">Total Titles</span>
                <asp:Label ID="lblTotalTitles" runat="server" CssClass="stat-value" Text="8,450" />
            </div>
            <div class="stat-card issued-books">
                <span class="stat-label">Currently Borrowed</span>
                <asp:Label ID="lblIssued" runat="server" CssClass="stat-value" Text="342" />
            </div>
            <div class="stat-card overdue-books">
                <span class="stat-label">Overdue Returns</span>
                <asp:Label ID="lblOverdue" runat="server" CssClass="stat-value" Text="14" />
            </div>
            <div class="stat-card">
                <span class="stat-label">Active Readers</span>
                <asp:Label ID="lblActiveReaders" runat="server" CssClass="stat-value" Text="520" />
            </div>
        </div>

        <div>
            <h2 class="section-title">Circulation & Member Services</h2>
            <div class="action-grid">
                <div class="action-card">
                    <div class="action-icon">📖</div>
                    <h3>Issue & Return Books</h3>
                    <p>Process book lending to members, handle book returns, and calculate late fees.</p>
                    <a href="~/Library Management/IssueReturn.aspx" runat="server" class="btn-action">Circulation Desk</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">🔍</div>
                    <h3>Book Catalog Search</h3>
                    <p>Search books by title, author, ISBN, category, or rack location.</p>
                    <a href="~/Library Management/BookSearch.aspx" runat="server" class="btn-action">Search Catalog</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">📑</div>
                    <h3>Book Reservations</h3>
                    <p>Manage member reserve requests for currently borrowed or upcoming titles.</p>
                    <a href="~/Library Management/Reservations.aspx" runat="server" class="btn-action">Manage Reservations</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">💸</div>
                    <h3>Member Library Ledger</h3>
                    <p>View member borrowing history, outstanding late charges, and process payments.</p>
                    <a href="~/Library Management/MemberLedger.aspx" runat="server" class="btn-action">Member Ledger</a>
                </div>
            </div>
        </div>

        <div>
            <h2 class="section-title">Inventory & Catalog Setup</h2>
            <div class="action-grid">
                <div class="action-card">
                    <div class="action-icon">➕</div>
                    <h3>Add / Edit Books</h3>
                    <p>Add new book entries, update editions, upload covers, and set copy counts.</p>
                    <a href="~/Library Management/AddEditBook.aspx" runat="server" class="btn-action">Manage Books</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">⚙️</div>
                    <h3>Library Master Setup</h3>
                    <p>Define categories, authors, publishers, rack positions, and library rules.</p>
                    <a href="~/Library Management/Define.aspx" runat="server" class="btn-action">System Setup</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">⚖️</div>
                    <h3>Fine Rules & Charges</h3>
                    <p>Configure daily overdue fine rates, damaged book fees, and grace periods.</p>
                    <a href="~/Library Management/DefineFacilityFine.aspx" runat="server" class="btn-action">Fine Rules</a>
                </div>

                <div class="action-card">
                    <div class="action-icon">📊</div>
                    <h3>Library Reports</h3>
                    <p>Generate inventory reports, most borrowed books list, and monthly revenue summaries.</p>
                    <a href="~/Library Management/Reports.aspx" runat="server" class="btn-action">View Reports</a>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
