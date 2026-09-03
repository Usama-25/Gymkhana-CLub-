<%@ Page Language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" AutoEventWireup="true" CodeFile="AdminLiveDashboard.aspx.cs" Inherits="GymkhanaLibrary.AdminLiveDashboard" Title="Live Library Admin Dashboard - Lahore Gymkhana Library" %>

<asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
    <!-- Font Awesome, Chart.js, and Google Fonts -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet" />

    <style>
        /* ─── BASE & TYPOGRAPHY ─── */
        * { box-sizing: border-box; }

        .dashboard-root,
        .dashboard-root *:not(i):not(.fa):not(.fas):not(.far):not(.fab) {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }

        /* ─── ANIMATIONS ─── */
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(18px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes shimmer {
            0%   { background-position: -200% 0; }
            100% { background-position: 200% 0; }
        }
        @keyframes pulseGlow {
            0%, 100% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.45); }
            50%      { box-shadow: 0 0 0 6px rgba(16, 185, 129, 0); }
        }
        @keyframes breathe {
            0%, 100% { opacity: 1; }
            50%      { opacity: 0.55; }
        }
        @keyframes countUp {
            from { opacity: 0; transform: translateY(8px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes gradientShift {
            0%   { background-position: 0% 50%; }
            50%  { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        .anim-fade { animation: fadeInUp 0.5s ease both; }
        .anim-d1 { animation-delay: 0.04s; }
        .anim-d2 { animation-delay: 0.08s; }
        .anim-d3 { animation-delay: 0.12s; }
        .anim-d4 { animation-delay: 0.16s; }
        .anim-d5 { animation-delay: 0.20s; }
        .anim-d6 { animation-delay: 0.24s; }
        .anim-d7 { animation-delay: 0.28s; }
        .anim-d8 { animation-delay: 0.32s; }
        .anim-d9 { animation-delay: 0.36s; }
        .anim-d10 { animation-delay: 0.40s; }
        .anim-d11 { animation-delay: 0.44s; }

        /* ─── SUMMARY CARDS ─── */
        .stat-card {
            background: #ffffff;
            border: 1px solid rgba(226, 232, 240, 0.8);
            border-radius: 14px;
            padding: 20px 22px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: relative;
            overflow: hidden;
            transition: all 0.28s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 4px 12px rgba(0,0,0,0.03);
        }

        .stat-card::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 4px;
            border-radius: 14px 0 0 14px;
            transition: width 0.28s ease;
        }

        .stat-card:hover {
            transform: translateY(-4px) scale(1.01);
            box-shadow: 0 8px 25px rgba(15, 30, 54, 0.08), 0 4px 12px rgba(197, 160, 89, 0.08);
            border-color: rgba(197, 160, 89, 0.2);
        }

        .stat-card:hover::before { width: 5px; }

        .stat-card .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            color: #ffffff;
            flex-shrink: 0;
            transition: transform 0.28s ease;
        }

        .stat-card:hover .stat-icon { transform: scale(1.08) rotate(-3deg); }

        .stat-card .stat-label {
            font-size: 10.5px;
            text-transform: uppercase;
            font-weight: 700;
            color: #64748b;
            letter-spacing: 0.6px;
            margin-bottom: 6px;
        }

        .stat-card .stat-value {
            font-size: 24px;
            font-weight: 800;
            color: #0f1e36;
            line-height: 1;
            animation: countUp 0.6s ease both;
        }

        .stat-card .stat-sub {
            font-size: 10px;
            color: #64748b;
            margin-top: 4px;
            font-weight: 500;
        }

        /* Card accent colors */
        .accent-blue::before    { background: linear-gradient(180deg, #3b82f6, #60a5fa); }
        .accent-cyan::before    { background: linear-gradient(180deg, #0ea5e9, #38bdf8); }
        .accent-green::before   { background: linear-gradient(180deg, #10b981, #34d399); }
        .accent-orange::before  { background: linear-gradient(180deg, #ea580c, #fb923c); }
        .accent-teal::before    { background: linear-gradient(180deg, #0d9488, #5eead4); }
        .accent-amber::before   { background: linear-gradient(180deg, #f59e0b, #fbbf24); }
        .accent-red::before     { background: linear-gradient(180deg, #ef4444, #f87171); }
        .accent-purple::before  { background: linear-gradient(180deg, #6366f1, #818cf8); }
        .accent-info::before    { background: linear-gradient(180deg, #0ea5e9, #67e8f9); }
        .accent-gold::before    { background: linear-gradient(180deg, #c5a059, #dfba75); }
        .accent-slate::before   { background: linear-gradient(180deg, #0f1e36, #1c3254); }
        .accent-emerald::before { background: linear-gradient(180deg, #10b981, #6ee7b7); }

        /* Icon gradient backgrounds */
        .icon-blue    { background: linear-gradient(135deg, #3b82f6, #60a5fa); }
        .icon-cyan    { background: linear-gradient(135deg, #0ea5e9, #38bdf8); }
        .icon-green   { background: linear-gradient(135deg, #10b981, #34d399); }
        .icon-orange  { background: linear-gradient(135deg, #ea580c, #fb923c); }
        .icon-teal    { background: linear-gradient(135deg, #0d9488, #5eead4); }
        .icon-amber   { background: linear-gradient(135deg, #f59e0b, #fbbf24); }
        .icon-red     { background: linear-gradient(135deg, #ef4444, #f87171); }
        .icon-purple  { background: linear-gradient(135deg, #6366f1, #818cf8); }
        .icon-info    { background: linear-gradient(135deg, #0ea5e9, #67e8f9); }
        .icon-gold    { background: linear-gradient(135deg, #c5a059, #dfba75); }
        .icon-slate   { background: linear-gradient(135deg, #0f1e36, #1c3254); }
        .icon-emerald { background: linear-gradient(135deg, #10b981, #6ee7b7); }

        /* Red card special bg */
        .stat-card.card-danger {
            background: linear-gradient(135deg, #fef2f2, #fff1f2);
            border-color: rgba(239, 68, 68, 0.15);
        }

        /* ─── SECTION PANELS ─── */
        .panel {
            background: #ffffff;
            border: 1px solid rgba(226, 232, 240, 0.7);
            border-radius: 16px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 6px 16px rgba(0,0,0,0.025);
            overflow: hidden;
            transition: box-shadow 0.3s ease;
        }
        .panel:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.06), 0 8px 24px rgba(0,0,0,0.04);
        }

        .panel-header {
            background: linear-gradient(135deg, #f8fafc, #f1f5f9);
            border-bottom: 1px solid #e2e8f0;
            padding: 16px 22px;
            font-weight: 700;
            font-size: 14px;
            color: #0f1e36;
            display: flex;
            align-items: center;
            gap: 12px;
            position: relative;
        }

        .panel-header::after {
            content: '';
            position: absolute;
            bottom: -1px;
            left: 22px;
            right: 22px;
            height: 2px;
            background: linear-gradient(90deg, #0f1e36, #c5a059, transparent);
            border-radius: 2px;
        }

        .panel-header .header-icon {
            width: 32px;
            height: 32px;
            border-radius: 8px;
            background: linear-gradient(135deg, #0f1e36, #1c3254);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            flex-shrink: 0;
        }



        /* ─── ALERT ROW ─── */
        .alert-row {
            border-radius: 10px;
            padding: 12px 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: all 0.2s ease;
        }
        .alert-row:hover {
            transform: translateX(3px);
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        }

        .alert-view-btn {
            background: rgba(255,255,255,0.85);
            backdrop-filter: blur(4px);
            border: 1px solid rgba(0,0,0,0.08);
            border-radius: 8px;
            font-weight: 700;
            font-size: 10px;
            padding: 5px 12px;
            text-decoration: none;
            color: #333;
            transition: all 0.2s ease;
        }
        .alert-view-btn:hover {
            background: #0f1e36;
            color: #ffffff;
            border-color: #0f1e36;
        }



        /* ─── CALENDAR ─── */
        .calendar-ctrl {
            border: none !important;
            width: 100%;
            border-collapse: separate;
            border-spacing: 3px;
        }
        .calendar-ctrl td {
            padding: 6px !important;
            vertical-align: top;
            height: 54px;
            width: 14.28%;
            font-size: 11px;
            border: 1px solid #f1f5f9 !important;
            border-radius: 6px;
            transition: background-color 0.15s ease;
        }
        .calendar-ctrl td:hover {
            background-color: #f8fafc !important;
        }
        .calendar-hdr {
            background-color: #eef5fc !important;
            color: #0f1e36 !important;
            font-weight: 700;
            text-align: center;
            padding: 6px 0 !important;
            border-radius: 6px;
        }
        .calendar-ttl {
            background: linear-gradient(135deg, #0f1e36, #1c3254) !important;
            color: #ffffff !important;
            font-weight: 700;
            font-size: 14px;
            border-radius: 6px;
        }
        .calendar-badge, .calendar-event-badge {
            font-size: 8px;
            padding: 2px 4px;
            border-radius: 4px;
            display: block;
            margin-top: 3px;
            text-align: left;
            font-weight: 600;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        /* ─── SCROLLBARS ─── */
        .scroll-panel::-webkit-scrollbar { width: 5px; }
        .scroll-panel::-webkit-scrollbar-thumb {
            background: linear-gradient(180deg, #cbd5e1, #94a3b8);
            border-radius: 10px;
        }
        .scroll-panel::-webkit-scrollbar-track { background-color: transparent; }

        /* ─── TABLE ENHANCEMENTS ─── */
        .table thead th {
            font-size: 10.5px !important;
            font-weight: 700 !important;
            letter-spacing: 0.5px;
            color: #64748b !important;
            border-bottom: 2px solid #e2e8f0 !important;
        }
        .table tbody tr {
            transition: background-color 0.15s ease;
        }
        .table tbody tr:hover {
            background-color: #f8fafc !important;
        }



        /* ─── INVENTORY PROGRESS ─── */
        .inv-bar-track {
            height: 7px;
            border-radius: 4px;
            background: linear-gradient(90deg, #f1f5f9, #e2e8f0);
            overflow: hidden;
            display: flex;
        }
        .inv-bar-track > div {
            border: none;
            border-radius: 4px;
            transition: width 0.8s cubic-bezier(0.4, 0, 0.2, 1);
        }

        /* ─── RECENTLY ADDED BOOK CARDS ─── */
        .book-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 14px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.02);
            display: flex;
            gap: 14px;
            align-items: center;
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .book-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(0,0,0,0.06);
            border-color: rgba(15, 108, 189, 0.15);
        }

        /* ─── LIVE PULSE INDICATOR ─── */
        .live-dot {
            width: 8px;
            height: 8px;
            background: #10b981;
            border-radius: 50%;
            display: inline-block;
            animation: pulseGlow 2s infinite;
        }

        /* ─── ALERT DETAILS MODAL ─── */
        .modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(15, 30, 54, 0.45);
            backdrop-filter: blur(8px);
            z-index: 10000;
            display: none;
            align-items: center;
            justify-content: center;
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .modal-overlay.active {
            display: flex;
            opacity: 1;
        }

        .modal-box {
            background: #ffffff;
            border-radius: 16px;
            width: 90%;
            max-width: 960px;
            max-height: 85vh;
            display: flex;
            flex-direction: column;
            box-shadow: 0 24px 48px -12px rgba(15, 30, 54, 0.25);
            border: 1px solid rgba(197, 160, 89, 0.2);
            overflow: hidden;
            transform: scale(0.95);
            transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
        }

        .modal-overlay.active .modal-box {
            transform: scale(1);
        }

        .modal-hdr-custom {
            background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%);
            color: #ffffff;
            padding: 18px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 3px solid #c5a059;
        }

        .modal-hdr-custom h3 {
            margin: 0;
            font-size: 16px;
            font-weight: 700;
            letter-spacing: -0.3px;
        }

        .modal-close-btn {
            background: rgba(255, 255, 255, 0.1);
            color: #ffffff;
            border: 1px solid rgba(255, 255, 255, 0.15);
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s;
        }
        .modal-close-btn:hover {
            background: #c5a059;
            color: #0f1e36;
            border-color: #c5a059;
            transform: rotate(90deg);
        }

        .modal-body-custom {
            padding: 24px;
            overflow-y: auto;
            flex: 1;
            box-sizing: border-box;
        }

        .modal-toolbar {
            display: flex;
            gap: 10px;
            margin-bottom: 18px;
            justify-content: flex-end;
        }

        .toolbar-btn {
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
            border: 1px solid #e2e8f0;
        }

        .btn-excel {
            background-color: #ecfdf5;
            color: #059669;
            border-color: rgba(16, 185, 129, 0.2);
        }
        .btn-excel:hover {
            background-color: #059669;
            color: #ffffff;
            border-color: #059669;
        }

        .btn-print {
            background-color: #f8fafc;
            color: #475569;
        }
        .btn-print:hover {
            background-color: #475569;
            color: #ffffff;
            border-color: #475569;
        }

        .modal-table-container {
            width: 100%;
            overflow-x: auto;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
        }

        .modal-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 12.5px;
            text-align: left;
        }

        .modal-table th {
            background-color: #f8fafc;
            padding: 12px 16px;
            font-weight: 700;
            color: #64748b;
            border-bottom: 2px solid #e2e8f0;
            font-size: 10.5px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .modal-table td {
            padding: 12px 16px;
            border-bottom: 1px solid #f1f5f9;
            color: #1e293b;
        }

        .modal-table tr:hover td {
            background-color: #f8fafc;
        }

        /* Spinner */
        .spinner-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 40px 0;
            gap: 12px;
            color: #64748b;
        }
        .spinner-icon {
            font-size: 32px;
            animation: spin 1s linear infinite;
            color: #c5a059;
        }
        @keyframes spin {
            100% { transform: rotate(360deg); }
        }
    </style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">
    <div class="dashboard-root" style="background: #f8fafc; padding: 28px; width: 100%; box-sizing: border-box; min-height: 100vh;">

        <!-- ══════════ HEADER PANEL ══════════ -->
        <div class="anim-fade" style="background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); background-size: 200% 200%; animation: fadeInUp 0.5s ease both, gradientShift 8s ease infinite; color: #ffffff; padding: 18px 24px; border-radius: 12px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px; box-shadow: 0 8px 32px rgba(15, 30, 54, 0.15), 0 2px 8px rgba(0,0,0,0.05); position: relative; overflow: hidden; border-bottom: 3px solid #c5a059;">
            <!-- Shimmer overlay -->
            <div style="position: absolute; inset: 0; background: linear-gradient(90deg, transparent, rgba(255,255,255,0.06), transparent); background-size: 200% 100%; animation: shimmer 3s infinite; pointer-events: none;"></div>
            <div style="position: relative; z-index: 1;">
                <h1 style="margin: 0; font-size: 26px; font-weight: 900; letter-spacing: -0.6px; line-height: 1.2;">
                    <i class="fas fa-tachometer-alt" style="margin-right: 10px; opacity: 0.85;"></i>Live Administration Dashboard
                </h1>
                <p style="margin: 6px 0 0 0; opacity: 0.75; font-size: 13px; font-weight: 500;">Library Resource Management &amp; Real-Time Circulation Metrics</p>
            </div>
            <div style="position: relative; z-index: 1; display: flex; align-items: center; gap: 12px;">
                <span style="display: flex; align-items: center; gap: 6px; font-size: 11px; font-weight: 600; opacity: 0.85;"><span class="live-dot"></span> LIVE</span>
                <span style="font-weight: 600; font-size: 12.5px; background: rgba(255,255,255,0.12); backdrop-filter: blur(8px); padding: 9px 18px; border-radius: 50px; display: inline-flex; align-items: center; gap: 8px; border: 1px solid rgba(255,255,255,0.15);">
                    <i class="far fa-clock"></i>
                    <asp:Literal ID="litServerTime" runat="server" />
                </span>
            </div>
        </div>

        <!-- ══════════ SECTION 1: Summary Cards Grid ══════════ -->
        <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 16px; margin-bottom: 24px;">

            <!-- Card 1: Total Books -->
            <div class="stat-card accent-blue anim-fade anim-d1">
                <div>
                    <div class="stat-label">Total Books</div>
                    <div class="stat-value" style="color: #3b82f6;"><asp:Literal ID="litTotalBooks" runat="server" Text="0" /></div>
                    <div class="stat-sub">Copies</div>
                </div>
                <div class="stat-icon icon-blue"><i class="fas fa-book"></i></div>
            </div>

            <!-- Card 2: Total Titles -->
            <div class="stat-card accent-gold anim-fade anim-d2">
                <div>
                    <div class="stat-label">Total Titles</div>
                    <div class="stat-value" style="color: #c5a059;"><asp:Literal ID="litTotalTitles" runat="server" Text="0" /></div>
                    <div class="stat-sub">Unique Titles</div>
                </div>
                <div class="stat-icon icon-gold"><i class="fas fa-bookmark"></i></div>
            </div>

            <!-- Card 3: Available Books -->
            <div class="stat-card accent-green anim-fade anim-d3">
                <div>
                    <div class="stat-label">Available Books</div>
                    <div class="stat-value" style="color: #10b981;"><asp:Literal ID="litAvailableBooks" runat="server" Text="0" /></div>
                    <div class="stat-sub">On shelves</div>
                </div>
                <div class="stat-icon icon-green"><i class="fas fa-check-circle"></i></div>
            </div>

            <!-- Card 4: Issued Books -->
            <div class="stat-card accent-blue anim-fade anim-d4">
                <div>
                    <div class="stat-label">Issued Books</div>
                    <div class="stat-value" style="color: #3b82f6;"><asp:Literal ID="litIssuedBooks" runat="server" Text="0" /></div>
                    <div class="stat-sub">On loan</div>
                </div>
                <div class="stat-icon icon-blue"><i class="fas fa-book-reader"></i></div>
            </div>

            <!-- Card 5: Returned Today -->
            <div class="stat-card accent-purple anim-fade anim-d5">
                <div>
                    <div class="stat-label">Returned Today</div>
                    <div class="stat-value" style="color: #6366f1;"><asp:Literal ID="litReturnedToday" runat="server" Text="0" /></div>
                    <div class="stat-sub">Returns</div>
                </div>
                <div class="stat-icon icon-purple"><i class="fas fa-undo"></i></div>
            </div>

            <!-- Card 6: Books Due Today -->
            <div class="stat-card accent-amber anim-fade anim-d6">
                <div>
                    <div class="stat-label">Due Today</div>
                    <div class="stat-value" style="color: #f59e0b;"><asp:Literal ID="litDueToday" runat="server" Text="0" /></div>
                    <div class="stat-sub">Expected</div>
                </div>
                <div class="stat-icon icon-amber"><i class="fas fa-clock"></i></div>
            </div>

            <!-- Card 7: Overdue Books -->
            <div class="stat-card accent-red card-danger anim-fade anim-d7">
                <div>
                    <div class="stat-label" style="color: #ef4444;">Overdue Books</div>
                    <div class="stat-value" style="color: #ef4444;"><asp:Literal ID="litOverdueBooks" runat="server" Text="0" /></div>
                    <div class="stat-sub">Late returns</div>
                </div>
                <div class="stat-icon icon-red"><i class="fas fa-exclamation-triangle"></i></div>
            </div>

            <!-- Card 8: Reserved Books -->
            <div class="stat-card accent-cyan anim-fade anim-d8">
                <div>
                    <div class="stat-label">Reserved Books</div>
                    <div class="stat-value" style="color: #0ea5e9;"><asp:Literal ID="litReservedBooks" runat="server" Text="0" /></div>
                    <div class="stat-sub">Active holds</div>
                </div>
                <div class="stat-icon icon-cyan"><i class="fas fa-calendar-check"></i></div>
            </div>

            <!-- Card 9: Active Members -->
            <div class="stat-card accent-green anim-fade anim-d9">
                <div>
                    <div class="stat-label">Active Members</div>
                    <div class="stat-value" style="color: #10b981;"><asp:Literal ID="litActiveMembers" runat="server" Text="0" /></div>
                    <div class="stat-sub">Patrons</div>
                </div>
                <div class="stat-icon icon-green"><i class="fas fa-users"></i></div>
            </div>

            <!-- Card 10: Lost Books -->
            <div class="stat-card accent-slate anim-fade anim-d10">
                <div>
                    <div class="stat-label">Lost Books</div>
                    <div class="stat-value" style="color: #0f1e36;"><asp:Literal ID="litLostBooks" runat="server" Text="0" /></div>
                    <div class="stat-sub">Missing copies</div>
                </div>
                <div class="stat-icon icon-slate"><i class="fas fa-circle-xmark"></i></div>
            </div>

            <!-- Card 11: Fine Collection -->
            <div class="stat-card accent-green anim-fade anim-d11" style="grid-column: span 2;">
                <div>
                    <div class="stat-label">Outstanding Fines</div>
                    <div class="stat-value" style="color: #10b981;">PKR <asp:Literal ID="litFineCollection" runat="server" Text="0.00" /></div>
                    <div class="stat-sub">Ledger outstanding balance</div>
                </div>
                <div class="stat-icon icon-green"><i class="fas fa-coins"></i></div>
            </div>
        </div>

        <!-- ══════════ TWO-COLUMN WORKSPACE ══════════ -->
        <div style="display: flex; flex-wrap: wrap; gap: 22px; width: 100%;">

            <!-- LEFT PANEL -->
            <div style="flex: 1 1 66%; min-width: 340px; display: flex; flex-direction: column; gap: 22px;">



                <!-- SECTION 3: Today's Activity Log -->
                <div class="panel anim-fade" style="animation-delay: 0.6s;">
                    <div class="panel-header">
                        <div class="header-icon"><i class="fas fa-receipt"></i></div>
                        Today's Library Activity Log
                    </div>
                    <div style="width: 100%; overflow-x: auto;">
                        <asp:GridView ID="gvRecentActivity" runat="server" AutoGenerateColumns="False"
                            CssClass="table table-hover table-striped align-middle mb-0"
                            GridLines="None" BorderWidth="0px" CellPadding="8"
                            HeaderStyle-CssClass="table-light text-uppercase"
                            HeaderStyle-Font-Bold="true"
                            HeaderStyle-Font-Size="11px"
                            HeaderStyle-Height="40px"
                            RowStyle-Height="42px"
                            EmptyDataText="No transaction log recorded for today yet.">
                            <columns>
                                <asp:BoundField DataField="Time" HeaderText="Time" ItemStyle-Width="12%" ItemStyle-CssClass="ps-4" HeaderStyle-CssClass="ps-4" ItemStyle-Font-Size="12px" />
                                <asp:BoundField DataField="Member" HeaderText="Member" ItemStyle-Width="30%" ItemStyle-Font-Size="12px" />
                                <asp:BoundField DataField="Book" HeaderText="Book Title" ItemStyle-Width="38%" ItemStyle-Font-Size="12px" />
                                <asp:TemplateField HeaderText="Action" ItemStyle-Width="10%">
                                    <itemtemplate>
                                        <span class='badge <%# GetActionBadgeClass(Eval("Action").ToString()) %>' style="font-size: 10px; padding: 5px 10px; border-radius: 20px; font-weight: 600;">
                                            <%# Eval("Action") %>
                                        </span>
                                    </itemtemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Status" ItemStyle-Width="10%">
                                    <itemtemplate>
                                        <span class='badge <%# GetStatusBadgeClass(Eval("Status").ToString()) %>' style="font-size: 10px; padding: 5px 10px; border-radius: 20px; font-weight: 600;">
                                            <%# Eval("Status") %>
                                        </span>
                                    </itemtemplate>
                                </asp:TemplateField>
                            </columns>
                        </asp:GridView>
                    </div>
                </div>

                <!-- SECTION 7: Most Borrowed Titles -->
                <div class="panel anim-fade" style="animation-delay: 0.7s;">
                    <div class="panel-header">
                        <div class="header-icon" style="background: linear-gradient(135deg, #d97706, #f59e0b);"><i class="fas fa-crown"></i></div>
                        Most Borrowed Titles
                    </div>
                    <div style="width: 100%; overflow-x: auto;">
                        <asp:GridView ID="gvMostBorrowed" runat="server" AutoGenerateColumns="False"
                            CssClass="table table-hover table-striped align-middle mb-0"
                            GridLines="None" BorderWidth="0px" CellPadding="8"
                            HeaderStyle-CssClass="table-light text-uppercase"
                            HeaderStyle-Font-Bold="true"
                            HeaderStyle-Font-Size="11px"
                            HeaderStyle-Height="40px"
                            RowStyle-Height="58px"
                            EmptyDataText="No borrowing records found.">
                            <columns>
                                <asp:TemplateField HeaderText="Cover" ItemStyle-Width="10%" ItemStyle-CssClass="ps-4" HeaderStyle-CssClass="ps-4">
                                    <itemtemplate>
                                        <asp:Panel ID="pnlCover" runat="server" style="width: 38px; height: 50px; border-radius: 6px; box-shadow: 0 2px 8px rgba(0,0,0,0.12); background-color: #e2e8f0; display: flex; align-items: center; justify-content: center; overflow: hidden;">
                                             <img src='<%# ResolveUrl("~/Library Management/Images/BookCovers/" + Eval("CoverFile")) %>' alt="Cover" style="width: 100%; height: 100%; object-fit: cover;" />
                                        </asp:Panel>
                                    </itemtemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Title" HeaderText="Book Title" ItemStyle-Width="35%" ItemStyle-Font-Bold="true" ItemStyle-Font-Size="12px" />
                                <asp:BoundField DataField="Author" HeaderText="Author" ItemStyle-Width="25%" ItemStyle-Font-Size="12px" />
                                <asp:BoundField DataField="Category" HeaderText="Category" ItemStyle-Width="15%" ItemStyle-Font-Size="12px" />
                                <asp:BoundField DataField="TimesIssued" HeaderText="Times" ItemStyle-Width="8%" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" ItemStyle-Font-Size="12px" />
                                <asp:BoundField DataField="AvailableCopies" HeaderText="Avail" ItemStyle-Width="7%" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" ItemStyle-Font-Size="12px" />
                            </columns>
                        </asp:GridView>
                    </div>
                </div>

                <!-- SECTION 8: Recently Added Books Grid -->
                <div class="panel anim-fade" style="animation-delay: 0.8s;">
                    <div class="panel-header">
                        <div class="header-icon" style="background: linear-gradient(135deg, #059669, #34d399);"><i class="fas fa-plus"></i></div>
                        Recently Added Book Catalogue
                    </div>
                    <div style="padding: 22px;">
                        <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 14px;">
                            <asp:Repeater ID="rptRecentBooks" runat="server">
                                <itemtemplate>
                                    <div class="book-card">
                                        <div style="width: 46px; height: 62px; border-radius: 7px; box-shadow: 0 2px 8px rgba(0,0,0,0.12); background-color: #e2e8f0; display: flex; align-items: center; justify-content: center; overflow: hidden; flex-shrink: 0;">
                                            <img src='<%# ResolveUrl("~/Library Management/Images/BookCovers/" + Eval("CoverFile")) %>' alt="Cover" style="width: 100%; height: 100%; object-fit: cover;" />
                                        </div>
                                        <div style="min-width: 0; flex-grow: 1; line-height: 1.35;">
                                            <h6 style="margin: 0; font-weight: 700; font-size: 12.5px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; color: #1a1f36;" title='<%# Eval("Title") %>'>
                                                <%# Eval("Title") %>
                                            </h6>
                                            <small style="color: #64748b; font-size: 10.5px; display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">By <%# Eval("Author") %></small>
                                            <small style="color: #94a3b8; font-size: 10.5px; display: block;">Pub: <%# Eval("Publisher") %></small>
                                            <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 6px;">
                                                <span style="background: linear-gradient(135deg, #eef5fc, #e0f2fe); color: #0369a1; font-size: 9.5px; padding: 3px 8px; border-radius: 20px; font-weight: 600;"><%# Eval("Category") %></span>
                                                <span style="font-size: 9.5px; color: #94a3b8;"><%# Eval("AddedDate", "{0:dd-MMM}") %></span>
                                            </div>
                                        </div>
                                    </div>
                                </itemtemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </div>

                <!-- SECTION 9: Most Active Members -->
                <div class="panel anim-fade" style="animation-delay: 0.9s;">
                    <div class="panel-header">
                        <div class="header-icon" style="background: linear-gradient(135deg, #7c3aed, #a78bfa);"><i class="fas fa-star"></i></div>
                        Most Active Members
                    </div>
                    <div style="width: 100%; overflow-x: auto;">
                        <asp:GridView ID="gvActiveMembers" runat="server" AutoGenerateColumns="False"
                            CssClass="table table-hover align-middle mb-0"
                            GridLines="None" BorderWidth="0px" CellPadding="8"
                            HeaderStyle-CssClass="table-light text-uppercase"
                            HeaderStyle-Font-Bold="true"
                            HeaderStyle-Font-Size="11px"
                            HeaderStyle-Height="40px"
                            RowStyle-Height="42px"
                            EmptyDataText="No active borrowers registered.">
                            <columns>
                                <asp:BoundField DataField="MemberName" HeaderText="Patron Name" ItemStyle-Width="50%" ItemStyle-Font-Bold="true" ItemStyle-CssClass="ps-4" HeaderStyle-CssClass="ps-4" ItemStyle-Font-Size="12px" />
                                <asp:BoundField DataField="BooksBorrowed" HeaderText="Borrowed" ItemStyle-Width="18%" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" ItemStyle-Font-Size="12px" />
                                <asp:BoundField DataField="CurrentBorrowed" HeaderText="Current" ItemStyle-Width="18%" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" ItemStyle-Font-Size="12px" />
                                <asp:TemplateField HeaderText="Fine Due" ItemStyle-Width="14%" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" ItemStyle-CssClass="pe-4" HeaderStyle-CssClass="pe-4">
                                    <itemtemplate>
                                        <span style='color: <%# Convert.ToDecimal(Eval("FineDue")) > 0 ? "#dc2626" : "#059669" %>; font-weight: 700; font-size: 12px;'>PKR <%# Eval("FineDue", "{0:N2}") %>
                                        </span>
                                    </itemtemplate>
                                </asp:TemplateField>
                            </columns>
                        </asp:GridView>
                    </div>
                </div>

            </div>

            <!-- RIGHT PANEL: SIDEBAR -->
            <div style="flex: 1 1 31%; min-width: 300px; display: flex; flex-direction: column; gap: 22px;">


                <!-- SECTION 4: Critical Alerts -->
                <div class="panel anim-fade" style="animation-delay: 0.6s;">
                    <div class="panel-header">
                        <div class="header-icon" style="background: linear-gradient(135deg, #dc2626, #f87171);"><i class="fas fa-bell"></i></div>
                        Critical Action Alerts
                    </div>
                    <div class="scroll-panel" style="padding: 18px; max-height: 320px; overflow-y: auto; display: flex; flex-direction: column; gap: 10px;">
                        <asp:Repeater ID="rptAlerts" runat="server">
                            <itemtemplate>
                                <div class="alert-row" style='background-color: <%# Eval("BGColor") %>; border: 1px solid <%# Eval("BorderColor") %>;'>
                                    <div style="display: flex; align-items: center; gap: 12px;">
                                        <div style='font-size: 16px; color: <%# Eval("TextColor") %>;'><i class='<%# Eval("Icon") %>'></i></div>
                                        <div style='font-weight: 700; color: <%# Eval("TextColor") %>; font-size: 12.5px; line-height: 1.2;'>
                                            <%# Eval("Count") %> <%# Eval("Title") %>
                                        </div>
                                    </div>
                                    <a href="javascript:void(0);" onclick='showAlertDetails("<%# Eval("Title") %>", "<%# Eval("Count") %>")' class="alert-view-btn">View</a>
                                </div>
                            </itemtemplate>
                        </asp:Repeater>
                    </div>
                </div>

                <!-- SECTION 6: Copy Inventory Status -->
                <div class="panel anim-fade" style="animation-delay: 0.7s;">
                    <div class="panel-header">
                        <div class="header-icon" style="background: linear-gradient(135deg, #0891b2, #22d3ee);"><i class="fas fa-boxes"></i></div>
                        Copy Inventory Status
                    </div>
                    <div style="padding: 20px; display: flex; flex-direction: column; gap: 16px;">
                        <asp:Repeater ID="rptInventoryStatus" runat="server">
                            <itemtemplate>
                                <div style="line-height: 1.3;">
                                    <div style="display: flex; justify-content: space-between; margin-bottom: 6px; font-size: 11.5px;">
                                        <span style="font-weight: 700; color: #1e293b;"><%# Eval("StatusName") %></span>
                                        <span style="color: #64748b; font-weight: 500;"><%# Eval("Count") %> copies (<%# Eval("Percentage", "{0:0.##}") %>%)</span>
                                    </div>
                                    <div class="inv-bar-track">
                                        <div class='<%# Eval("BarClass") %>' style='width: <%# Eval("Percentage", "{0:0.##}") %>%;'></div>
                                    </div>
                                </div>
                            </itemtemplate>
                        </asp:Repeater>
                    </div>
                </div>

                <!-- SECTION 10 & 11: Financial & Purchase Overview -->
                <div class="panel anim-fade" style="animation-delay: 0.8s;">
                    <div class="panel-header">
                        <div class="header-icon" style="background: linear-gradient(135deg, #059669, #34d399);"><i class="fas fa-cash-register"></i></div>
                        Financial &amp; Purchase Overview
                    </div>
                    <div style="padding: 20px;">
                        <!-- Procurement -->
                        <div style="margin-bottom: 18px;">
                            <small style="color: #64748b; font-weight: 700; text-transform: uppercase; display: block; font-size: 9.5px; letter-spacing: 0.6px; margin-bottom: 10px;">Book Procurement (Month)</small>
                            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px;">
                                <div style="padding: 12px 8px; text-align: center; background: linear-gradient(135deg, #f8fafc, #f1f5f9); border: 1px solid #e2e8f0; border-radius: 10px;">
                                    <span style="color: #64748b; display: block; font-size: 9.5px; font-weight: 500;">Active POs</span>
                                    <span style="font-weight: 800; font-size: 16px; color: #0F6CBD;">
                                        <asp:Literal ID="litActivePOs" runat="server" Text="0" /></span>
                                </div>
                                <div style="padding: 12px 8px; text-align: center; background: linear-gradient(135deg, #f8fafc, #f1f5f9); border: 1px solid #e2e8f0; border-radius: 10px;">
                                    <span style="color: #64748b; display: block; font-size: 9.5px; font-weight: 500;">Received</span>
                                    <span style="font-weight: 800; font-size: 16px; color: #059669;">
                                        <asp:Literal ID="litReceivedBooks" runat="server" Text="0" /></span>
                                </div>
                                <div style="padding: 12px 8px; text-align: center; background: linear-gradient(135deg, #f8fafc, #f1f5f9); border: 1px solid #e2e8f0; border-radius: 10px;">
                                    <span style="color: #64748b; display: block; font-size: 9.5px; font-weight: 500;">Approval</span>
                                    <span style="font-weight: 800; font-size: 16px; color: #ea580c;">
                                        <asp:Literal ID="litPendingApproval" runat="server" Text="0" /></span>
                                </div>
                            </div>
                        </div>

                        <hr style="border: 0; border-top: 1px solid #e2e8f0; margin: 0 0 18px 0;" />

                        <!-- Fines Overview -->
                        <div>
                            <small style="color: #64748b; font-weight: 700; text-transform: uppercase; display: block; font-size: 9.5px; letter-spacing: 0.6px; margin-bottom: 10px;">Fines Summary</small>
                            <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 8px;">
                                <div style="padding: 12px; background: linear-gradient(135deg, #f8fafc, #f1f5f9); border: 1px solid #e2e8f0; border-radius: 10px; display: flex; justify-content: space-between; align-items: center;">
                                    <div style="line-height: 1.25;">
                                        <span style="color: #64748b; font-size: 9.5px; display: block; font-weight: 500;">Today</span>
                                        <span style="font-weight: 800; font-size: 12px; color: #0f1e36;">PKR
                                            <asp:Literal ID="litTodayFine" runat="server" Text="0.00" /></span>
                                    </div>
                                    <div style="width: 30px; height: 30px; border-radius: 8px; background: linear-gradient(135deg, #eef5fc, #dbeafe); display: flex; align-items: center; justify-content: center;">
                                        <i class="fas fa-calendar-day" style="font-size: 12px; color: #3b82f6;"></i>
                                    </div>
                                </div>
                                <div style="padding: 12px; background: linear-gradient(135deg, #f8fafc, #f1f5f9); border: 1px solid #e2e8f0; border-radius: 10px; display: flex; justify-content: space-between; align-items: center;">
                                    <div style="line-height: 1.25;">
                                        <span style="color: #64748b; font-size: 9.5px; display: block; font-weight: 500;">Month</span>
                                        <span style="font-weight: 800; font-size: 12px; color: #0f1e36;">PKR
                                            <asp:Literal ID="litMonthlyFine" runat="server" Text="0.00" /></span>
                                    </div>
                                    <div style="width: 30px; height: 30px; border-radius: 8px; background: linear-gradient(135deg, #ecfdf5, #d1fae5); display: flex; align-items: center; justify-content: center;">
                                        <i class="fas fa-calendar-alt" style="font-size: 12px; color: #10b981;"></i>
                                    </div>
                                </div>
                                <div style="padding: 12px; background: linear-gradient(135deg, #fef2f2, #fff1f2); border: 1px solid rgba(239,68,68,0.1); border-radius: 10px; display: flex; justify-content: space-between; align-items: center;">
                                    <div style="line-height: 1.25;">
                                        <span style="color: #64748b; font-size: 9.5px; display: block; font-weight: 500;">Outstanding</span>
                                        <span style="font-weight: 800; font-size: 12px; color: #ef4444;">PKR
                                            <asp:Literal ID="litOutstandingFine" runat="server" Text="0.00" /></span>
                                    </div>
                                    <div style="width: 30px; height: 30px; border-radius: 8px; background: linear-gradient(135deg, #fee2e2, #fecaca); display: flex; align-items: center; justify-content: center;">
                                        <i class="fas fa-exclamation-triangle" style="font-size: 12px; color: #ef4444;"></i>
                                    </div>
                                </div>
                                <div style="padding: 12px; background: linear-gradient(135deg, #f8fafc, #f1f5f9); border: 1px solid #e2e8f0; border-radius: 10px; display: flex; justify-content: space-between; align-items: center;">
                                    <div style="line-height: 1.25;">
                                        <span style="color: #64748b; font-size: 9.5px; display: block; font-weight: 500;">Collected YTD</span>
                                        <span style="font-weight: 800; font-size: 12px; color: #10b981;">PKR
                                            <asp:Literal ID="litCollectedYear" runat="server" Text="0.00" /></span>
                                    </div>
                                    <div style="width: 30px; height: 30px; border-radius: 8px; background: linear-gradient(135deg, #ecfdf5, #d1fae5); display: flex; align-items: center; justify-content: center;">
                                        <i class="fas fa-coins" style="font-size: 12px; color: #10b981;"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- SECTION 12: Operations Calendar -->
                <div class="panel anim-fade" style="animation-delay: 0.9s;">
                    <div class="panel-header">
                        <div class="header-icon" style="background: linear-gradient(135deg, #7c3aed, #a78bfa);"><i class="fas fa-calendar-alt"></i></div>
                        Operations Calendar
                    </div>
                    <div style="padding: 16px; background-color: #ffffff;">
                        <asp:Calendar ID="calLibraryEvents" runat="server"
                            CssClass="calendar-ctrl"
                            NextPrevFormat="ShortMonth"
                            OnDayRender="calLibraryEvents_DayRender"
                            DayNameFormat="Shortest"
                            ShowGridLines="True"
                            BorderColor="#e9ecef"
                            BackColor="#FFFFFF"
                            ForeColor="#495057">
                            <titlestyle cssclass="calendar-ttl" />
                            <dayheaderstyle cssclass="calendar-hdr" />
                            <todaydaystyle backcolor="#E2E8F0" font-bold="True" />
                            <selecteddaystyle backcolor="#0F6CBD" forecolor="#FFFFFF" />
                            <othermonthdaystyle forecolor="#ADB5BD" />
                        </asp:Calendar>

                        <div style="font-size: 9.5px; margin-top: 14px; display: flex; gap: 16px; justify-content: center;">
                            <span style="display: flex; align-items: center; gap: 5px;"><span style="width: 8px; height: 8px; background: linear-gradient(135deg, #dc2626, #f87171); border-radius: 50%; display: inline-block;"></span>Due Date</span>
                            <span style="display: flex; align-items: center; gap: 5px;"><span style="width: 8px; height: 8px; background: linear-gradient(135deg, #7c3aed, #a78bfa); border-radius: 50%; display: inline-block;"></span>Hold</span>
                            <span style="display: flex; align-items: center; gap: 5px;"><span style="width: 8px; height: 8px; background: linear-gradient(135deg, #0ea5e9, #67e8f9); border-radius: 50%; display: inline-block;"></span>Expiry</span>
                        </div>
                    </div>
                </div>


            </div>

        </div>

    </div>


    </div>

    <!-- ══════════ POPUP MODAL FOR CRITICAL DETAILS ══════════ -->
    <div id="alertModal" class="modal-overlay">
        <div class="modal-box">
            <div class="modal-hdr-custom">
                <h3 id="modalTitle">Alert Details</h3>
                <button type="button" class="modal-close-btn" onclick="closeModal()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="modal-body-custom">
                <div class="modal-toolbar">
                    <button type="button" class="toolbar-btn btn-print" onclick="triggerPrint()">
                        <i class="fas fa-print"></i> Print Report
                    </button>
                    <button type="button" class="toolbar-btn btn-excel" onclick="triggerExport()">
                        <i class="fas fa-file-excel"></i> Export to Excel
                    </button>
                </div>
                <div class="modal-table-container" id="detailsTableContainer">
                    <!-- Dynamic Table or Loading Spinner injected here -->
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        var activeAlertTitle = "";
        var activeAlertData = [];

        function showCalendarDetails(dateStr, eventType) {
            var fullTitle = eventType + " on " + dateStr;
            activeAlertTitle = fullTitle;
            document.getElementById('modalTitle').innerText = fullTitle;
            document.getElementById('detailsTableContainer').innerHTML = `
                <div class="spinner-container">
                    <i class="fas fa-spinner spinner-icon"></i>
                    <span>Loading calendar events from database...</span>
                </div>
            `;
            document.getElementById('alertModal').classList.add('active');

            // Invoke PageMethod
            PageMethods.GetCalendarDetails(dateStr, eventType, function (data) {
                activeAlertData = data;
                renderDetailsTable(data);
            }, function (err) {
                document.getElementById('detailsTableContainer').innerHTML = `
                    <div style="padding: 30px; text-align: center; color: #dc2626; font-weight: 600;">
                        <i class="fas fa-exclamation-circle" style="font-size: 24px; margin-bottom: 10px; display: block;"></i>
                        Failed to load calendar events: ${err.get_message()}
                    </div>
                `;
            });
        }

        function showAlertDetails(title, count) {
            activeAlertTitle = title;
            document.getElementById('modalTitle').innerText = title + " (" + count + ")";
            document.getElementById('detailsTableContainer').innerHTML = `
                <div class="spinner-container">
                    <i class="fas fa-spinner spinner-icon"></i>
                    <span>Loading details from database...</span>
                </div>
            `;
            document.getElementById('alertModal').classList.add('active');

            // Invoke PageMethod
            PageMethods.GetAlertDetails(title, function (data) {
                activeAlertData = data;
                renderDetailsTable(data);
            }, function (err) {
                document.getElementById('detailsTableContainer').innerHTML = `
                    <div style="padding: 30px; text-align: center; color: #dc2626; font-weight: 600;">
                        <i class="fas fa-exclamation-circle" style="font-size: 24px; margin-bottom: 10px; display: block;"></i>
                        Failed to load details: ${err.get_message()}
                    </div>
                `;
            });
        }

        function renderDetailsTable(data) {
            if (!data || data.length === 0) {
                document.getElementById('detailsTableContainer').innerHTML = `
                    <div style="padding: 40px; text-align: center; color: #64748b;">
                        <i class="fas fa-info-circle" style="font-size: 24px; margin-bottom: 10px; display: block; color: #c5a059;"></i>
                        No active records found for this alert.
                    </div>
                `;
                return;
            }

            // Dynamically get columns from first item
            var cols = Object.keys(data[0]);
            var html = `<table class="modal-table" id="modalDataTable"><thead><tr>`;
            for (var i = 0; i < cols.length; i++) {
                html += `<th>${cols[i]}</th>`;
            }
            html += `</tr></thead><tbody>`;

            for (var r = 0; r < data.length; r++) {
                html += `<tr>`;
                for (var c = 0; c < cols.length; c++) {
                    var val = data[r][cols[c]];
                    if (val === null || val === undefined) val = "";
                    html += `<td>${val}</td>`;
                }
                html += `</tr>`;
            }
            html += `</tbody></table>`;
            document.getElementById('detailsTableContainer').innerHTML = html;
        }

        function closeModal() {
            document.getElementById('alertModal').classList.remove('active');
        }

        // Close modal on escape key
        document.addEventListener('keydown', function(event) {
            if (event.key === "Escape") {
                closeModal();
            }
        });

        function printModalTable(title) {
            var tableHtml = document.getElementById('detailsTableContainer').innerHTML;
            var printWindow = window.open('', '', 'height=600,width=900');
            printWindow.document.write('<html><head><title>' + title + '</title>');
            printWindow.document.write('<style>');
            printWindow.document.write('body { font-family: sans-serif; padding: 20px; color: #1e293b; }');
            printWindow.document.write('table { width: 100%; border-collapse: collapse; margin-top: 20px; }');
            printWindow.document.write('th { background-color: #0f1e36; color: #ffffff; font-weight: bold; border: 1px solid #e2e8f0; padding: 10px; text-align: left; font-size: 11px; text-transform: uppercase; }');
            printWindow.document.write('td { border: 1px solid #e2e8f0; padding: 10px; font-size: 12px; }');
            printWindow.document.write('h2 { color: #0f1e36; border-bottom: 2px solid #c5a059; padding-bottom: 8px; font-size: 18px; margin: 0; }');
            printWindow.document.write('</style></head><body>');
            printWindow.document.write('<h2>Lahore Gymkhana Library - ' + title + '</h2>');
            printWindow.document.write('<div style="font-size: 10px; color: #64748b; margin-top: 5px;">Report Generated: ' + new Date().toLocaleString() + '</div>');
            printWindow.document.write(tableHtml);
            printWindow.document.write('</body></html>');
            printWindow.document.close();
            printWindow.print();
        }

        function triggerPrint() {
            printModalTable(activeAlertTitle);
        }

        function triggerExport() {
            var filename = activeAlertTitle.replace(/\s+/g, '_') + "_Report";
            exportTableToExcel('modalDataTable', filename);
        }

        function exportTableToExcel(tableId, filename) {
            var table = document.getElementById(tableId);
            if (!table) return;

            var html = table.outerHTML;
            // Add style tags to format cells nicely in Excel
            var style = `<style>
                table { border-collapse: collapse; font-family: 'Segoe UI', Arial, sans-serif; }
                th { background-color: #0f1e36; color: #ffffff; font-weight: bold; border: 1px solid #cbd5e1; padding: 8px; text-align: left; }
                td { border: 1px solid #cbd5e1; padding: 8px; color: #1e293b; }
            </style>`;
            
            var template = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40">';
            template += '<head><!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>Sheet1</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]-->';
            template += style + '</head><body>' + html + '</body></html>';

            var blob = new Blob([template], { type: "application/vnd.ms-excel" });
            var url = URL.createObjectURL(blob);
            var a = document.createElement("a");
            a.href = url;
            a.download = filename + ".xls";
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
        }
    </script>
</asp:Content>
