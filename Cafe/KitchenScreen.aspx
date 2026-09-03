<%@ Page Language="C#" AutoEventWireup="true" CodeFile="KitchenScreen.aspx.cs" Inherits="KitchenScreen" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=yes">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Kitchen Display System</title>

    <link href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root {
            --word-blue:       #2B579A;
            --word-dark:       #1E3F73;
            --word-bright:     #106EBE;
            --word-light-bg:   #EFF6FC;
            --word-ultra-light:#F8FBFF;
            --word-white:      #FFFFFF;
            --word-text:       #212121;
            --word-text-mid:   #595959;
            --word-text-light: #8D9091;
            --word-border:     #D1D1D1;
            --word-border-dark:#A9A9A9;
            --word-surface:    #FAFAFA;
            --word-hover:      #F0F4FA;
            --status-pending:  #D83B01;
            --status-preparing:#0078D4;
            --status-ready:    #107C10;
            --status-delayed:  #A80000;
            --shadow-xs:  0 1px 3px rgba(43,87,154,.10);
            --shadow-sm:  0 2px 8px rgba(43,87,154,.13);
            --shadow-md:  0 4px 18px rgba(43,87,154,.16);
            --shadow-lg:  0 8px 32px rgba(43,87,154,.20);
            --radius-sm:  6px;
            --radius-md:  10px;
            --radius-lg:  16px;
        }

        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }
        html { scroll-behavior:smooth; }

        body {
            font-family: 'Source Sans 3', 'Segoe UI', Calibri, sans-serif;
            background: var(--word-ultra-light);
            color: var(--word-text);
            min-height: 100vh;
            padding: 20px;
            -webkit-font-smoothing: antialiased;
        }

        ::-webkit-scrollbar { width:7px; height:7px; }
        ::-webkit-scrollbar-track { background:#f0f0f0; }
        ::-webkit-scrollbar-thumb { background:var(--word-blue); border-radius:4px; }
        ::-webkit-scrollbar-thumb:hover { background:var(--word-dark); }

        /* ── NAV ── */
        .nav-container {
            background: var(--word-blue);
            padding: 0 24px;
            border-radius: var(--radius-md);
            margin-bottom: 20px;
            box-shadow: var(--shadow-md);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
            min-height: 60px;
            position: sticky;
            top: 10px;
            z-index: 100;
        }

        .nav-container.scrolled {
            background: rgba(43,87,154,.97);
            backdrop-filter: blur(16px);
        }

        .nav-title-section {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 10px 0;
        }

        .kitchen-logo {
            width: 38px; height: 38px;
            background: rgba(255,255,255,.18);
            border: 1.5px solid rgba(255,255,255,.35);
            border-radius: var(--radius-sm);
            display: flex; align-items: center; justify-content: center;
            color: #fff;
            font-size: 1.15rem;
            flex-shrink: 0;
        }

        .nav-title {
            color: #fff;
            font-size: 1.15rem;
            font-weight: 700;
            letter-spacing: .3px;
            white-space: nowrap;
        }

        .nav-title span { color: rgba(255,255,255,.7); font-weight: 400; }

        .nav-controls {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            justify-content: flex-end;
            padding: 10px 0;
        }

        .employee-badge {
            background: rgba(255,255,255,.15);
            color: #fff;
            padding: 6px 13px;
            border-radius: 20px;
            font-size: 0.82rem;
            font-weight: 600;
            border: 1px solid rgba(255,255,255,.25);
            display: flex; align-items: center; gap: 7px;
            white-space: nowrap;
        }

        .live-indicator {
            display: inline-flex; align-items: center; gap: 6px;
            background: rgba(255,255,255,.12);
            color: #fff;
            border: 1px solid rgba(255,255,255,.25);
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.76rem;
            font-weight: 700;
            letter-spacing: .5px;
            white-space: nowrap;
        }

        .live-dot {
            width: 7px; height: 7px;
            border-radius: 50%;
            background: #6FCF97;
            animation: pulse 1.5s infinite;
        }

        .search-wrapper { position:relative; min-width:220px; flex:1; max-width:320px; }

        .search-input {
            width: 100%;
            background: rgba(255,255,255,.12);
            color: #fff;
            border: 1px solid rgba(255,255,255,.25);
            border-radius: var(--radius-sm);
            padding: 8px 36px 8px 14px;
            font-size: 0.88rem;
            font-family: inherit;
            height: 38px;
            transition: all .25s ease;
            outline: none;
        }

        .search-input::placeholder { color: rgba(255,255,255,.55); }
        .search-input:focus {
            background: rgba(255,255,255,.2);
            border-color: rgba(255,255,255,.6);
            box-shadow: 0 0 0 3px rgba(255,255,255,.12);
        }

        .search-icon { position:absolute; right:12px; top:50%; transform:translateY(-50%); color:rgba(255,255,255,.6); font-size:.85rem; pointer-events:none; }
        .search-clear-btn {
            position:absolute; right:8px; top:50%; transform:translateY(-50%);
            background:none; border:none; color:rgba(255,255,255,.7); cursor:pointer;
            padding:4px; font-size:.8rem; display:none; transition:color .2s;
        }
        .search-clear-btn:hover { color:#fff; }

        .search-active-badge {
            background: rgba(255,255,255,.18);
            color: #fff;
            border: 1px solid rgba(255,255,255,.3);
            padding: 5px 11px;
            border-radius: 20px;
            font-size: 0.78rem;
            font-weight: 600;
            display: none;
            align-items: center;
            gap: 5px;
            white-space: nowrap;
        }

        .department-dropdown { position:relative; min-width:240px; }

        .department-select {
            background: rgba(255,255,255,.12) !important;
            color: #fff !important;
            border: 1px solid rgba(255,255,255,.25) !important;
            border-radius: var(--radius-sm) !important;
            padding: 8px 36px 8px 14px !important;
            font-weight: 500 !important;
            cursor: pointer !important;
            width: 100% !important;
            font-size: 0.88rem !important;
            height: 38px !important;
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='rgba(255,255,255,.8)' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E") !important;
            background-repeat: no-repeat !important;
            background-position: right 12px center !important;
            outline: none !important;
            font-family: inherit !important;
            transition: all .25s !important;
        }

        .department-select:focus,
        .department-select:hover {
            background: rgba(255,255,255,.2) !important;
            border-color: rgba(255,255,255,.5) !important;
        }

        .department-select option {
            background: var(--word-dark) !important;
            color: #fff !important;
        }

        .selected-dept-badge {
            background: rgba(255,255,255,.22);
            color: #fff;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.82rem;
            display: flex; align-items: center; gap: 7px;
            font-weight: 600;
            border: 1px solid rgba(255,255,255,.3);
            white-space: nowrap;
        }

        .clear-filter-btn {
            background: rgba(255,255,255,.2);
            border: none; color: #fff;
            width: 20px; height: 20px;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; font-size: .7rem;
            transition: all .2s ease;
        }
        .clear-filter-btn:hover { background: rgba(255,255,255,.4); transform: rotate(90deg); }

        /* ── HEADER ── */
        .header-section {
            background: var(--word-white);
            padding: 22px 28px;
            border-radius: var(--radius-md);
            margin-bottom: 20px;
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--word-border);
            border-left: 5px solid var(--word-blue);
            position: relative;
            overflow: hidden;
        }

        .header-section::after {
            content: '';
            position: absolute; right:0; top:0; bottom:0;
            width: 200px;
            background: linear-gradient(to left, var(--word-light-bg), transparent);
            pointer-events: none;
        }

        .kitchen-title {
            font-size: 1.9rem; font-weight: 800;
            letter-spacing: -.5px;
            color: var(--word-dark);
            margin-bottom: 4px;
        }

        .kitchen-subtitle {
            color: var(--word-blue);
            font-size: 0.92rem; font-weight: 600;
            display: flex; align-items: center; gap: 8px;
            text-transform: uppercase; letter-spacing: .4px;
        }

        /* ── STATS ── */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(170px, 1fr));
            gap: 14px;
            margin-bottom: 20px;
        }

        .stat-card {
            background: var(--word-white);
            border-radius: var(--radius-md);
            padding: 16px 18px;
            box-shadow: var(--shadow-xs);
            border: 1px solid var(--word-border);
            transition: transform .25s, box-shadow .25s;
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute; top:0; left:0; right:0;
            height: 3px;
        }

        .stat-card:nth-child(1)::before { background: var(--status-pending); }
        .stat-card:nth-child(2)::before { background: var(--status-preparing); }
        .stat-card:nth-child(3)::before { background: var(--status-ready); }
        .stat-card:nth-child(4)::before { background: var(--word-blue); }

        .stat-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-sm); }

        .stat-icon {
            width: 38px; height: 38px;
            border-radius: var(--radius-sm);
            background: var(--word-light-bg);
            display: flex; align-items: center; justify-content: center;
            margin-bottom: 10px;
            color: var(--word-blue);
            font-size: 1rem;
        }

        .stat-card:nth-child(1) .stat-icon { color: var(--status-pending);  background: #FFF4F0; }
        .stat-card:nth-child(2) .stat-icon { color: var(--status-preparing); background: #EFF6FF; }
        .stat-card:nth-child(3) .stat-icon { color: var(--status-ready);     background: #F0FFF0; }

        .stat-label { color: var(--word-text-light); font-size: .76rem; font-weight: 600; text-transform:uppercase; letter-spacing:.4px; margin-bottom:4px; }
        .stat-value { font-size: 1.9rem; font-weight: 700; color: var(--word-text); line-height:1; }

        /* ── ORDERS GRID ── */
        #ordersContainer {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(370px, 1fr));
            gap: 16px;
            padding-bottom: 80px;
        }

        /* ── KITCHEN CARD ── */
        .kitchen-card {
            background: var(--word-white);
            border-radius: var(--radius-md);
            border: 1px solid var(--word-border);
            box-shadow: var(--shadow-xs);
            transition: all .35s cubic-bezier(.4,0,.2,1);
            overflow: hidden;
            opacity: 0;
            transform: translateY(16px) scale(.985);
            animation: cardAppear .45s cubic-bezier(.4,0,.2,1) forwards;
        }

        @keyframes cardAppear { to { opacity:1; transform:translateY(0) scale(1); } }

        .kitchen-card.status-pending   { border-top: 4px solid var(--status-pending); }
        .kitchen-card.status-preparing { border-top: 4px solid var(--status-preparing); }
        .kitchen-card.status-ready     { border-top: 4px solid var(--status-ready); }
        .kitchen-card.status-delayed   { border-top: 4px solid var(--status-delayed); }

        .kitchen-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-md);
            border-color: var(--word-blue);
        }

        /* Card Header */
        .card-header {
            padding: 12px 16px 10px;
            border-bottom: 1px solid var(--word-border);
            background: var(--word-surface);
        }

        .card-header-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 6px;
            flex-wrap: wrap;
            gap: 6px;
        }

        .bill-badge {
            display: inline-flex; align-items: center; gap: 5px;
            background: var(--word-light-bg);
            color: var(--word-blue);
            padding: 3px 9px;
            border-radius: 20px;
            font-size: .74rem; font-weight: 700;
            border: 1px solid #C7DCF7;
        }

        .kot-badge {
            display: inline-flex; align-items: center; gap: 5px;
            background: #FFF3CD;
            color: #856404;
            border: 1px solid #FFD700;
            padding: 3px 9px;
            border-radius: 20px;
            font-size: 0.74rem;
            font-weight: 700;
            white-space: nowrap;
        }

        .department-info {
            background: #F0F4FA;
            color: var(--word-text-mid);
            padding: 2px 8px;
            border-radius: 12px;
            font-size: .7rem; font-weight: 600;
            border: 1px solid var(--word-border);
            max-width: 130px;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }

        .bill-number {
            font-size: 1.35rem; font-weight: 700;
            color: var(--word-dark);
            margin-bottom: 4px;
            letter-spacing: -.3px;
        }

        .member-info-row {
            display: flex; align-items: center; gap: 6px;
            margin-bottom: 6px; flex-wrap: wrap;
        }

        .member-no-badge {
            display: inline-flex; align-items: center; gap: 4px;
            background: #F4F4F4;
            color: var(--word-text);
            border: 1px solid var(--word-border);
            padding: 2px 8px;
            border-radius: 12px;
            font-size: .72rem; font-weight: 600;
            font-family: 'Consolas', monospace;
        }

        .member-no-badge i { color: var(--word-blue); font-size: .68rem; }

        .member-name-badge {
            display: inline-flex; align-items: center; gap: 4px;
            background: #F0FFF3;
            color: var(--status-ready);
            border: 1px solid #B7DFC0;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: .72rem; font-weight: 600;
        }

        .order-time {
            font-size: .78rem;
            color: var(--word-text-light);
            display: flex; align-items: center; gap: 5px;
        }

        .time-indicator {
            display: inline-flex; align-items: center; gap: 4px;
            background: var(--word-light-bg);
            color: var(--word-text-mid);
            padding: 2px 7px; border-radius: 10px;
            font-size: .74rem; font-weight: 500;
        }

        .time-indicator.warning {
            background: #FFF4F0;
            color: var(--status-pending);
        }

        /* Card Body */
        .card-body { padding: 10px 16px; }

        /* ── COMPACT ITEM ROW ── */
        .order-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
            padding: 7px 0;
            border-bottom: 1px solid var(--word-border);
        }

        .order-item:last-child { border-bottom: none; }

        .item-left {
            display: flex;
            align-items: center;
            gap: 8px;
            flex: 1;
            min-width: 0;
        }

        .quantity-badge {
            background: var(--word-blue);
            color: #fff;
            font-size: .82rem;
            font-weight: 700;
            min-width: 32px;
            height: 32px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            box-shadow: 0 1px 4px rgba(43,87,154,.25);
        }

        .item-name {
            font-size: .9rem;
            font-weight: 600;
            color: var(--word-text);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        /* Status tag */
        .status-tag {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 3px 8px; border-radius: 20px;
            font-weight: 700; font-size: .7rem;
            letter-spacing: .2px;
            white-space: nowrap;
            flex-shrink: 0;
        }

        .status-tag.pending   { background:#FFF4F0; color:var(--status-pending);   border:1px solid #FBC4AE; }
        .status-tag.preparing { background:#EFF6FF; color:var(--status-preparing); border:1px solid #B3D4F5; }
        .status-tag.ready     { background:#F0FFF3; color:var(--status-ready);     border:1px solid #B7DFC0; }
        .status-tag.delayed   { background:#FFF0F0; color:var(--status-delayed);   border:1px solid #F5ACAC; }
        .status-tag.completed { background:#F0FFF3; color:var(--status-ready);     border:1px solid #B7DFC0; }

        .status-dot { width:6px; height:6px; border-radius:50%; animation:pulse 2s infinite; flex-shrink:0; }
        .status-tag.pending   .status-dot { background:var(--status-pending); }
        .status-tag.preparing .status-dot { background:var(--status-preparing); }
        .status-tag.ready     .status-dot { background:var(--status-ready); }
        .status-tag.delayed   .status-dot { background:var(--status-delayed); }
        .status-tag.completed .status-dot { background:var(--status-ready); animation:none; }

        @keyframes pulse { 0%,100%{opacity:1;transform:scale(1)} 50%{opacity:.6;transform:scale(1.3)} }

        /* Progress */
        .progress-section {
            background: var(--word-surface);
            border-radius: var(--radius-sm);
            padding: 10px 12px;
            border: 1px solid var(--word-border);
            margin-top: 10px;
        }

        .progress-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 6px; font-size: .78rem;
        }

        .progress-label { color: var(--word-text-mid); font-weight: 500; }
        .progress-percent { color: var(--word-blue); font-weight: 700; }

        .progress-bar-container { height: 6px; background: #E5E5E5; border-radius: 4px; overflow:hidden; }

        .progress-bar-fill {
            height: 100%; border-radius: 4px;
            transition: width .5s cubic-bezier(.4,0,.2,1);
            position:relative; overflow:hidden;
        }

        .progress-bar-fill::after {
            content:''; position:absolute; top:0; left:0; right:0; bottom:0;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,.45), transparent);
            animation: shimmer 1.6s infinite;
        }

        @keyframes shimmer { 0%{transform:translateX(-100%)} 100%{transform:translateX(100%)} }

        .progress-bar-fill.pending   { background: var(--status-pending); }
        .progress-bar-fill.preparing { background: var(--status-preparing); }
        .progress-bar-fill.ready     { background: var(--status-ready); }
        .progress-bar-fill.delayed   { background: var(--status-delayed); }

        /* Card Footer */
        .card-footer {
            padding: 12px 16px;
            border-top: 1px solid var(--word-border);
            background: var(--word-surface);
        }

        /* ── ACTION BUTTONS ── */
        .action-buttons { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }

        .action-btn {
            border: none;
            padding: 10px;
            border-radius: var(--radius-sm);
            font-weight: 700;
            cursor: pointer;
            transition: all .25s cubic-bezier(.4,0,.2,1);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 7px;
            font-size: .82rem;
            font-family: inherit;
            letter-spacing: .2px;
        }

        .btn-prepare {
            background: var(--status-preparing);
            color: #fff;
            box-shadow: 0 2px 6px rgba(0,120,212,.3);
        }

        .btn-prepare:hover:not(:disabled) {
            background: #005A9E;
            transform: translateY(-1px);
            box-shadow: 0 5px 14px rgba(0,120,212,.4);
        }

        .btn-ready {
            background: var(--status-ready);
            color: #fff;
            box-shadow: 0 2px 6px rgba(16,124,16,.3);
        }

        .btn-ready:hover:not(:disabled) {
            background: #0B5E0B;
            transform: translateY(-1px);
            box-shadow: 0 5px 14px rgba(16,124,16,.4);
        }

        .action-btn:disabled {
            opacity: .4;
            cursor: not-allowed;
            transform: none !important;
            background: #C8C8C8 !important;
            box-shadow: none !important;
            color: #666 !important;
        }

        /* Bill ready — full width */
        .btn-bill-ready {
            grid-column: span 2;
            background: var(--status-ready);
            color: #fff;
            box-shadow: 0 2px 8px rgba(16,124,16,.3);
            font-size: .88rem;
        }

        .btn-bill-ready:hover:not(:disabled) {
            background: #0B5E0B;
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(16,124,16,.45);
        }

        /* ── EMPTY / LOADING ── */
        .select-dept-container,
        .no-dept-orders-container {
            grid-column: 1/-1;
            display: flex; flex-direction: column;
            align-items: center; justify-content: center;
            min-height: 420px;
            background: var(--word-white);
            border-radius: var(--radius-lg);
            padding: 60px 40px;
            max-width: 640px;
            margin: 20px auto;
            border: 1px solid var(--word-border);
            text-align: center;
            box-shadow: var(--shadow-sm);
        }

        .empty-icon { font-size: 4rem; color: var(--word-blue); margin-bottom: 18px; opacity: .75; }
        .empty-title { color: var(--word-dark); font-weight: 700; margin-bottom: 10px; font-size: 1.6rem; }
        .empty-message { color: var(--word-text-mid); font-size: .95rem; line-height:1.6; margin-bottom:20px; }

        .empty-hint {
            background: var(--word-blue);
            color: #fff;
            padding: 10px 26px; border-radius: 30px;
            font-size: .9rem; font-weight: 700;
            display: inline-flex; align-items: center; gap: 10px;
            cursor: pointer; border: none;
            transition: all .25s ease; font-family: inherit;
            box-shadow: var(--shadow-sm);
        }

        .empty-hint:hover { background: var(--word-dark); transform: translateY(-1px); box-shadow: var(--shadow-md); }

        .loading {
            grid-column: 1/-1;
            text-align: center; padding: 60px;
            color: var(--word-blue);
        }

        .spinner {
            width: 44px; height: 44px;
            border: 3px solid var(--word-border);
            border-top-color: var(--word-blue);
            border-radius: 50%;
            animation: spin .75s linear infinite;
            margin: 0 auto 16px;
        }

        @keyframes spin { to { transform:rotate(360deg); } }

        /* ── FLOATING ACTIONS ── */
        .floating-actions {
            position: fixed; bottom: 26px; right: 26px;
            display: flex; flex-direction: column; gap: 11px;
            z-index: 1000;
        }

        .float-btn {
            width: 50px; height: 50px; border-radius: 25px;
            border: none;
            background: var(--word-blue);
            color: #fff;
            cursor: pointer; box-shadow: var(--shadow-lg);
            transition: all .3s cubic-bezier(.4,0,.2,1);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.1rem;
        }

        .float-btn:hover { transform: translateY(-2px) scale(1.08); background: var(--word-dark); box-shadow: 0 10px 28px rgba(43,87,154,.4); }

        .float-btn.scroll-top-btn {
            background: var(--word-white);
            color: var(--word-blue);
            border: 1px solid var(--word-border);
            opacity: 0; transform: scale(.8); pointer-events: none;
        }

        .float-btn.scroll-top-btn.visible { opacity: 1; transform: scale(1); pointer-events: all; }

        /* ── NOTIFICATION TOAST ── */
        #autoRefreshNotify {
            position: fixed; top: 76px; right: 18px;
            background: var(--word-white);
            color: var(--word-text);
            padding: 11px 20px; border-radius: var(--radius-md);
            box-shadow: var(--shadow-lg);
            border-left: 4px solid var(--word-blue);
            z-index: 1050; display: none;
            animation: slideInRight .3s ease;
            font-size: .88rem; font-weight: 500;
            border: 1px solid var(--word-border);
        }

        #autoRefreshNotify.notify-new { border-left-color: var(--status-ready); }

        @keyframes slideInRight {
            from { transform:translateX(100%); opacity:0; }
            to   { transform:translateX(0);    opacity:1; }
        }

        /* ── RESPONSIVE ── */
        @media (max-width:768px) {
            body { padding: 10px; }
            .nav-container { flex-direction: column; align-items: stretch; padding: 12px; }
            .nav-controls { justify-content: stretch; }
            .department-dropdown, .search-wrapper { min-width:100%; max-width:100%; }
            .kitchen-title { font-size: 1.5rem; }
            #ordersContainer { grid-template-columns: 1fr; gap: 12px; }
            .stats-grid { grid-template-columns: 1fr 1fr; }
            .floating-actions { bottom:14px; right:14px; }
            .float-btn { width:44px; height:44px; font-size:1rem; }
        }

        @media print {
            .nav-container, .floating-actions, #autoRefreshNotify { display:none; }
            body { background:white; padding:0; }
            .kitchen-card { break-inside:avoid; border:1px solid #ddd; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>

        <asp:HiddenField ID="hdnEmpID"         runat="server" />
        <asp:HiddenField ID="hdnDepartmentID"   runat="server" />
        <asp:HiddenField ID="hdnDepartmentName" runat="server" />

        <div id="mainContainer">

            <!-- Navigation Bar -->
            <div class="nav-container" id="mainNav">
                <div class="nav-title-section">
                    <div class="kitchen-logo"><i class="fas fa-utensils"></i></div>
                    <h2 class="nav-title">KITCHEN <span>DISPLAY SYSTEM</span></h2>
                </div>

                <div class="nav-controls">
                    <div class="live-indicator" id="liveIndicator" style="display:none;">
                        <span class="live-dot"></span> LIVE
                    </div>

                    <div class="employee-badge" id="employeeBadge" style="display:none;">
                        <i class="fas fa-user"></i>
                        <span id="employeeBadgeText">—</span>
                    </div>

                    <div class="search-wrapper">
                        <input type="text" id="searchInput" class="search-input"
                               placeholder="Search member / item…"
                               oninput="onSearchInput(this.value)"
                               autocomplete="off" />
                        <i class="fas fa-search search-icon" id="searchIcon"></i>
                        <button type="button" class="search-clear-btn" id="searchClearBtn" onclick="clearSearch()">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>

                    <div class="search-active-badge" id="searchActiveBadge">
                        <i class="fas fa-filter"></i>
                        <span id="searchResultCount">0 results</span>
                    </div>

                    <div class="department-dropdown">
                        <asp:DropDownList ID="ddlDepartment" runat="server"
                            CssClass="department-select"
                            onchange="onDepartmentChange(this)"
                            AutoPostBack="false">
                        </asp:DropDownList>
                    </div>

                    <div id="selectedDeptBadge" class="selected-dept-badge" style="display:none;">
                        <i class="fas fa-store-alt"></i>
                        <span id="selectedDeptText"></span>
                        <button type="button" class="clear-filter-btn" onclick="clearDepartmentFilter()">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                </div>
            </div>

            <!-- Header -->
            <div class="header-section">
                <h1 class="kitchen-title">KITCHEN ORDER BOARD</h1>
                <p class="kitchen-subtitle">
                    <i class="fas fa-fire-alt"></i>
                    REAL-TIME ORDER MANAGEMENT SYSTEM
                </p>
            </div>

            <!-- Stats -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon"><i class="fas fa-clock"></i></div>
                    <div class="stat-label">Pending Orders</div>
                    <div class="stat-value" id="pendingCount">0</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon"><i class="fas fa-spinner"></i></div>
                    <div class="stat-label">Preparing Orders</div>
                    <div class="stat-value" id="preparingCount">0</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon"><i class="fas fa-check-circle"></i></div>
                    <div class="stat-label">Ready Orders</div>
                    <div class="stat-value" id="readyCount">0</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon"><i class="fas fa-chart-bar"></i></div>
                    <div class="stat-label">Total Active Bills</div>
                    <div class="stat-value" id="totalItems">0</div>
                </div>
            </div>

            <!-- Orders -->
            <div id="ordersContainer"></div>

            <!-- Loading -->
            <div id="loadingState" class="loading" style="display:none;">
                <div class="spinner"></div>
                <p style="color:var(--word-text-mid); font-size:.95rem;">Loading kitchen orders…</p>
            </div>
        </div>

        <!-- Floating Actions -->
        <div class="floating-actions">
            <button class="float-btn refresh-btn" onclick="refreshOrders()" title="Refresh (F5)">
                <i class="fas fa-sync-alt"></i>
            </button>
            <button class="float-btn scroll-top-btn" onclick="scrollToTop()" title="Back to Top">
                <i class="fas fa-arrow-up"></i>
            </button>
        </div>

        <!-- Notification Toast -->
        <div id="autoRefreshNotify">
            <i class="fas fa-info-circle" style="color:var(--word-blue); margin-right:8px;"></i>
            <span id="notifyMsg">Orders updated</span>
        </div>
    </form>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <script>
        // ── GLOBALS ──
        let isRefreshing = false;
        let allOrders = [];
        let currentDepartmentID = '';
        let currentDepartmentName = '';
        let kitchenEmployeeID = '';
        let currentSearchTerm = '';
        let scrollTimeout;
        let pollInterval = null;
        let lastSignature = '';
        const POLL_FAST_MS = 8000;

        // ── INIT ──
        $(document).ready(function () {
            const hdnEmpID = document.getElementById('<%= hdnEmpID.ClientID %>');
            if (hdnEmpID && hdnEmpID.value) {
                kitchenEmployeeID = hdnEmpID.value.trim();
            }
            showMainInterface();
            initScrollEvents();
        });

        function showMainInterface() {
            if (kitchenEmployeeID && kitchenEmployeeID !== 'GUEST') {
                $('#employeeBadge').show();
                $('#employeeBadgeText').text(kitchenEmployeeID);
            }

            const savedDeptID = $('#<%= hdnDepartmentID.ClientID %>').val();
            const savedDeptName = $('#<%= hdnDepartmentName.ClientID %>').val();

            if (savedDeptID) {
                setSelectedDepartment(savedDeptID, savedDeptName);
            } else {
                showSelectDepartmentMessage();
            }

            setupSmartPolling();
        }

        // ── DEPARTMENT ──
        function onDepartmentChange(select) {
            const value = select.value;
            const text = select.options[select.selectedIndex] ? select.options[select.selectedIndex].text : '';
            if (value) {
                saveDepartmentToSession(value, text);
                setSelectedDepartment(value, text);
            } else {
                clearDepartmentFilter();
            }
        }

        function saveDepartmentToSession(deptID, deptName) {
            $.ajax({
                type: 'POST',
                url: 'KitchenScreen.aspx/SaveSelectedDepartment',
                data: JSON.stringify({ departmentID: deptID, departmentName: deptName }),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json'
            });
        }

        function setSelectedDepartment(deptID, deptName) {
            if (!deptID) return;
            currentDepartmentID = deptID;
            currentDepartmentName = deptName;

            $('#<%= hdnDepartmentID.ClientID %>').val(deptID);
            $('#<%= hdnDepartmentName.ClientID %>').val(deptName);
            $('#<%= ddlDepartment.ClientID %>').val(deptID);

            $('#selectedDeptText').text(deptName);
            $('#selectedDeptBadge').fadeIn(200);
            $('#liveIndicator').show();

            clearSearch();
            lastSignature = '';
            showNotification('Loading orders for ' + deptName);
            loadOrders();
        }

        function clearDepartmentFilter() {
            currentDepartmentID   = '';
            currentDepartmentName = '';
            $('#<%= hdnDepartmentID.ClientID %>').val('');
            $('#<%= hdnDepartmentName.ClientID %>').val('');
            $('#<%= ddlDepartment.ClientID %>').val('');
            $('#selectedDeptBadge').fadeOut(200);
            $('#liveIndicator').hide();
            clearSearch();
            saveDepartmentToSession('', '');
            showSelectDepartmentMessage();
            resetStats();
            lastSignature = '';
        }

        // ── SEARCH ──
        let searchDebounceTimer = null;

        function onSearchInput(value) {
            currentSearchTerm = value.trim();
            if (currentSearchTerm) { $('#searchClearBtn').show(); $('#searchIcon').hide(); }
            else { $('#searchClearBtn').hide(); $('#searchIcon').show(); }
            clearTimeout(searchDebounceTimer);
            searchDebounceTimer = setTimeout(applySearchFilter, 300);
        }

        function clearSearch() {
            currentSearchTerm = '';
            $('#searchInput').val('');
            $('#searchClearBtn').hide();
            $('#searchIcon').show();
            $('#searchActiveBadge').hide();
            applySearchFilter();
        }

        function applySearchFilter() {
            if (!allOrders || !allOrders.length) return;
            let filtered = allOrders;

            if (currentSearchTerm) {
                const term = currentSearchTerm.toLowerCase();
                filtered = allOrders.filter(o =>
                    (o.MemberNo && o.MemberNo.toLowerCase().includes(term)) ||
                    (o.MemberName && o.MemberName.toLowerCase().includes(term)) ||
                    (o.Items && o.Items.some(i => i.Name && i.Name.toLowerCase().includes(term)))
                );
                $('#searchActiveBadge').css('display', 'inline-flex');
                $('#searchResultCount').text(filtered.length + ' result' + (filtered.length !== 1 ? 's' : ''));
            } else {
                $('#searchActiveBadge').hide();
            }

            if (filtered.length === 0 && currentSearchTerm) {
                $('#ordersContainer').html(`
                <div class="no-dept-orders-container">
                    <div class="empty-icon"><i class="fas fa-search"></i></div>
                    <h3 class="empty-title">No Results</h3>
                    <p class="empty-message">No orders match "<strong>${escapeHtml(currentSearchTerm)}</strong>"</p>
                    <button class="empty-hint" onclick="clearSearch()">
                        <i class="fas fa-times"></i> Clear Search
                    </button>
                </div>`);
            } else {
                renderOrders(filtered);
            }
            updateStats(filtered);
        }

        // ── LOAD ORDERS ──
        function loadOrders(silent) {
            if (!currentDepartmentID || isRefreshing) return;
            isRefreshing = true;

            if (!silent) {
                $('#loadingState').fadeIn(150);
                $('#ordersContainer').empty();
            }

            $.ajax({
                type: 'POST',
                url: 'KitchenScreen.aspx/LoadOrders',
                data: JSON.stringify({ departmentID: currentDepartmentID }),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                timeout: 15000,
                success: function (res) {
                    $('#loadingState').hide();
                    try {
                        const orders = res.d ? JSON.parse(res.d) : [];
                        allOrders = orders;
                        if (!orders.length) showNoOrdersMessage();
                        else applySearchFilter();
                    } catch (e) {
                        console.error('Parse error:', e);
                        if (!silent) showError('Error processing orders');
                    }
                },
                error: function (xhr, status, error) {
                    console.error('AJAX error:', error);
                    $('#loadingState').hide();
                    if (!silent) showError('Connection error. Retrying…');
                },
                complete: function () { isRefreshing = false; }
            });
        }

        // ── SMART POLLING ──
        function setupSmartPolling() {
            if (pollInterval) clearInterval(pollInterval);
            pollInterval = setInterval(function () {
                if (!currentDepartmentID) return;
                checkForNewOrders();
            }, POLL_FAST_MS);
        }

        function checkForNewOrders() {
            if (isRefreshing) return;
            $.ajax({
                type: 'POST',
                url: 'KitchenScreen.aspx/GetOrdersSignature',
                data: JSON.stringify({ departmentID: currentDepartmentID }),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                timeout: 8000,
                success: function (res) {
                    try {
                        const result = res.d ? JSON.parse(res.d) : res;
                        const newSig = result.signature || '';
                        if (newSig !== lastSignature) {
                            const isFirst = lastSignature === '';
                            lastSignature = newSig;
                            if (!isFirst) showNewOrderNotification('Orders updated — refreshing…');
                            loadOrders(true);
                        }
                    } catch (e) { }
                }
            });
        }

        // ── RENDER ORDERS ──
        function renderOrders(orders) {
            if (!orders || !orders.length) return;

            const delayThreshold = 15;
            let html = '';

            orders.forEach((order, i) => {
                const isDelayed = order.MinutesAgo > delayThreshold && order.OverallStatus !== 'Completed';
                const statusClass = isDelayed
                    ? 'delayed'
                    : (order.OverallStatus === 'Completed'
                        ? 'ready'
                        : (order.OverallStatus || 'pending').toLowerCase());

                const timeClass = isDelayed ? 'warning' : '';

                const memberNoHtml = order.MemberNo
                    ? `<span class="member-no-badge"><i class="fas fa-id-card"></i>${escapeHtml(order.MemberNo)}</span>`
                    : '';

                const memberNameHtml = order.MemberName
                    ? `<span class="member-name-badge"><i class="fas fa-user"></i>${escapeHtml(order.MemberName)}</span>`
                    : '';

                const kotHtml = order.KOT_Number
                    ? `<span class="kot-badge"><i class="fas fa-ticket-alt"></i>KOT: ${escapeHtml(order.KOT_Number)}</span>`
                    : '';

                // Compact item rows — qty + name + status tag only, no inline buttons
                let itemsHtml = '';
                order.Items.forEach(item => {
                    const itemStatusClass = (item.IsPrep || 'pending').toLowerCase();
                    itemsHtml += `
                    <div class="order-item">
                        <div class="item-left">
                            <div class="quantity-badge">×${item.Quantity}</div>
                            <span class="item-name" title="${escapeHtml(item.Name)}">${escapeHtml(item.Name)}</span>
                        </div>
                        <div class="status-tag ${itemStatusClass}">
                            <span class="status-dot"></span>
                            ${escapeHtml(item.IsPrep || 'Pending')}
                        </div>
                    </div>`;
                });

                html += `
                <div class="kitchen-card status-${statusClass}"
                     id="bill-${order.BillId}"
                     data-billid="${order.BillId}"
                     style="animation-delay:${i * .04}s;">

                    <div class="card-header">
                        <div class="card-header-top">
                            <div class="bill-badge"><i class="fas fa-receipt"></i> Bill #${order.BillId}</div>
                            ${kotHtml}
                            ${order.DepartmentName ? `<div class="department-info">${escapeHtml(order.DepartmentName)}</div>` : ''}
                        </div>
                        <div class="bill-number">${escapeHtml(order.TableNo || order.MemberNo || 'T/A')}</div>
                        ${(memberNoHtml || memberNameHtml) ? `<div class="member-info-row">${memberNoHtml}${memberNameHtml}</div>` : ''}
                        <div class="order-time">
                            <i class="far fa-clock"></i>
                            <span class="time-indicator ${timeClass}">
                                <i class="fas ${isDelayed ? 'fa-exclamation-circle' : 'fa-hourglass-half'}"></i>
                                ${escapeHtml(order.TimeDisplay || order.OrderTime)}
                            </span>
                        </div>
                    </div>

                    <div class="card-body">
                        <div class="items-container">
                            ${itemsHtml}
                        </div>
                        <div class="progress-section">
                            <div class="progress-header">
                                <span class="progress-label">Overall Progress</span>
                                <span class="progress-percent">${order.OverallProgress || 0}%</span>
                            </div>
                            <div class="progress-bar-container">
                                <div class="progress-bar-fill ${statusClass}" style="width:${order.OverallProgress || 0}%"></div>
                            </div>
                        </div>
                    </div>

                    <div class="card-footer">
                        <div class="action-buttons">
                            ${renderBillActionButtons(order)}
                        </div>
                    </div>
                </div>`;
            });

            $('#ordersContainer').html(html);
            initCardAnimations();
        }

        // ── CARD-LEVEL ACTION BUTTONS ──
        function renderBillActionButtons(order) {
            const hasAnyPending = order.Items.some(i => i.IsPrep === 'Pending');
            const hasAnyPreparing = order.Items.some(i => i.IsPrep === 'Preparing');
            const allDone = order.OverallStatus === 'Completed';

            // All items completed — full-width Mark Bill Ready
            if (allDone) {
                return `<button class="action-btn btn-ready btn-bill-ready"
                            onclick="markBillReady(${order.BillId})">
                            <i class="fas fa-bell"></i> Mark Bill Ready for Service
                        </button>`;
            }

            // Start All Prep — active only when pending items exist
            const prepareBtn = hasAnyPending
                ? `<button class="action-btn btn-prepare"
                       onclick="startAllPending(${order.BillId})">
                       <i class="fas fa-play-circle"></i> Start All Prep
                   </button>`
                : `<button class="action-btn" disabled>
                       <i class="fas fa-play-circle"></i> Start All Prep
                   </button>`;

            // Mark All Ready — active only when preparing items exist
            const readyBtn = hasAnyPreparing
                ? `<button class="action-btn btn-ready"
                       onclick="markAllPreparing(${order.BillId})">
                       <i class="fas fa-check-circle"></i> Mark All Ready
                   </button>`
                : `<button class="action-btn" disabled>
                       <i class="fas fa-check-circle"></i> Mark All Ready
                   </button>`;

            return prepareBtn + readyBtn;
        }

        // ── BULK: START ALL PENDING ITEMS ──
        function startAllPending(billId) {
            const order = allOrders.find(o => o.BillId === billId);
            if (!order) return;
            const pendingItems = order.Items.filter(i => i.IsPrep === 'Pending');
            if (!pendingItems.length) return;

            const $btn = $(`#bill-${billId} .btn-prepare`);
            $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Starting…');

            let done = 0;
            pendingItems.forEach(item => {
                $.ajax({
                    type: 'POST',
                    url: 'KitchenScreen.aspx/UpdateItemPrepStatus',
                    data: JSON.stringify({ itemId: item.ItemId, status: 'Preparing' }),
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    complete: function () {
                        done++;
                        if (done === pendingItems.length) {
                            showNotification('All items started — Preparing');
                            lastSignature = '';
                            setTimeout(function () { loadOrders(true); }, 400);
                        }
                    }
                });
            });
        }

        // ── BULK: MARK ALL PREPARING → COMPLETED ──
        function markAllPreparing(billId) {
            const order = allOrders.find(o => o.BillId === billId);
            if (!order) return;
            const preparingItems = order.Items.filter(i => i.IsPrep === 'Preparing');
            if (!preparingItems.length) return;

            const $btn = $(`#bill-${billId} .btn-ready`);
            $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Marking…');

            let done = 0;
            preparingItems.forEach(item => {
                $.ajax({
                    type: 'POST',
                    url: 'KitchenScreen.aspx/UpdateItemPrepStatus',
                    data: JSON.stringify({ itemId: item.ItemId, status: 'Completed' }),
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    complete: function () {
                        done++;
                        if (done === preparingItems.length) {
                            showNotification('All items marked Ready');
                            lastSignature = '';
                            setTimeout(function () { loadOrders(true); }, 400);
                        }
                    }
                });
            });
        }

        // ── MARK BILL READY (all items done) ──
        function markBillReady(billId) {
            if (!confirm('Mark Bill #' + billId + ' as Ready?\nThis order will be completed and removed from the kitchen screen.')) return;

            const $btn = $(`#bill-${billId} .btn-bill-ready`);
            $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Processing…');

            $.ajax({
                type: 'POST',
                url: 'KitchenScreen.aspx/MarkBillReady',
                data: JSON.stringify({ billId: billId }),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (res) {
                    const result = res.d || '';
                    if (result === 'success') {
                        showNotification('✓ Bill #' + billId + ' marked Ready');
                        lastSignature = '';
                        setTimeout(function () { loadOrders(true); }, 400);
                    } else {
                        alert('Error: ' + result);
                        $btn.prop('disabled', false).html('<i class="fas fa-bell"></i> Mark Bill Ready for Service');
                    }
                },
                error: function () {
                    alert('Network error. Please try again.');
                    $btn.prop('disabled', false).html('<i class="fas fa-bell"></i> Mark Bill Ready for Service');
                }
            });
        }

        // ── STATS ──
        function updateStats(orders) {
            if (!orders || !orders.length) { resetStats(); return; }
            let pending = 0, preparing = 0, completed = 0;
            orders.forEach(order => {
                if (order.OverallStatus === 'Pending') pending++;
                else if (order.OverallStatus === 'Preparing') preparing++;
                else if (order.OverallStatus === 'Completed') completed++;
            });
            animateNumber('pendingCount', pending);
            animateNumber('preparingCount', preparing);
            animateNumber('readyCount', completed);
            animateNumber('totalItems', orders.length);
        }

        function animateNumber(id, target) {
            const $el = $('#' + id);
            const start = parseInt($el.text()) || 0;
            const dur = 450, t0 = performance.now();
            (function tick(now) {
                const p = Math.min((now - t0) / dur, 1);
                const e = 1 - Math.pow(1 - p, 4);
                $el.text(Math.floor(start + (target - start) * e));
                if (p < 1) requestAnimationFrame(tick);
            })(t0);
        }

        function resetStats() {
            $('#pendingCount, #preparingCount, #readyCount, #totalItems').text('0');
        }

        // ── MESSAGES ──
        function showSelectDepartmentMessage() {
            $('#ordersContainer').html(`
            <div class="select-dept-container">
                <div class="empty-icon"><i class="fas fa-store-alt"></i></div>
                <h2 class="empty-title">Select a Department</h2>
                <p class="empty-message">Choose a kitchen department from the dropdown above to view live orders.</p>
                <div class="empty-hint"><i class="fas fa-arrow-up"></i> Select from the dropdown above</div>
            </div>`);
        }

        function showNoOrdersMessage() {
            $('#ordersContainer').html(`
            <div class="no-dept-orders-container">
                <div class="empty-icon"><i class="fas fa-utensils"></i></div>
                <h3 class="empty-title">No Active Orders</h3>
                <p class="empty-message">No pending orders for <strong>${escapeHtml(currentDepartmentName)}</strong>.<br>Watching for new orders…</p>
                <button class="empty-hint" onclick="clearDepartmentFilter()">
                    <i class="fas fa-exchange-alt"></i> Switch Department
                </button>
            </div>`);
        }

        function showError(msg) {
            $('#ordersContainer').html(`
            <div class="no-dept-orders-container">
                <div class="empty-icon" style="color:var(--status-pending)"><i class="fas fa-exclamation-triangle"></i></div>
                <h3 class="empty-title">Connection Error</h3>
                <p class="empty-message">${escapeHtml(msg)}</p>
                <button class="empty-hint" onclick="loadOrders()">
                    <i class="fas fa-sync-alt"></i> Retry
                </button>
            </div>`);
        }

        // ── NOTIFICATIONS ──
        function showNotification(msg, isNew) {
            $('#notifyMsg').text(msg);
            const $n = $('#autoRefreshNotify');
            isNew ? $n.addClass('notify-new') : $n.removeClass('notify-new');
            $n.stop(true).fadeIn(200).delay(2800).fadeOut(300);
        }

        function showNewOrderNotification(msg) {
            showNotification(msg, true);
            let f = 0, orig = document.title;
            const fi = setInterval(function () {
                document.title = f % 2 === 0 ? '🔔 NEW ORDER!' : orig;
                if (++f >= 6) { clearInterval(fi); document.title = orig; }
            }, 600);
        }

        // ── UTILITIES ──
        function escapeHtml(text) {
            if (!text) return '';
            return String(text)
                .replace(/&/g, '&amp;').replace(/</g, '&lt;')
                .replace(/>/g, '&gt;').replace(/"/g, '&quot;')
                .replace(/'/g, '&#039;');
        }

        // ── SCROLL ──
        function initScrollEvents() {
            const $nav = $('#mainNav'), $scrollBtn = $('.scroll-top-btn');
            $(window).on('scroll', function () {
                if (scrollTimeout) cancelAnimationFrame(scrollTimeout);
                scrollTimeout = requestAnimationFrame(function () {
                    const top = $(window).scrollTop();
                    $nav.toggleClass('scrolled', top > 10);
                    $scrollBtn.toggleClass('visible', top > 300);
                });
            });
        }

        function scrollToTop() { $('html,body').animate({ scrollTop: 0 }, 400); }

        // ── ANIMATIONS ──
        function initCardAnimations() {
            if (!window.IntersectionObserver) return;
            const obs = new IntersectionObserver(function (entries) {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.style.opacity = '1';
                        entry.target.style.transform = 'translateY(0) scale(1)';
                        obs.unobserve(entry.target);
                    }
                });
            }, { threshold: .08, rootMargin: '50px' });
            document.querySelectorAll('.kitchen-card').forEach(c => obs.observe(c));
        }

        // ── MANUAL REFRESH ──
        function refreshOrders() {
            if (!currentDepartmentID) { showNotification('Select a department first'); return; }
            const $icon = $('.refresh-btn i');
            $icon.addClass('fa-spin');
            lastSignature = '';
            loadOrders();
            setTimeout(() => $icon.removeClass('fa-spin'), 800);
        }

        // ── KEYBOARD SHORTCUTS ──
        $(document).on('keydown', function (e) {
            if (e.key === 'F5' || (e.ctrlKey && e.key === 'r')) { e.preventDefault(); refreshOrders(); }
            if (e.key === 'Escape' && currentSearchTerm) clearSearch();
            if (e.ctrlKey && e.key === 'f') { e.preventDefault(); $('#searchInput').focus(); }
        });

        $(document).on('visibilitychange', function () {
            if (!document.hidden && currentDepartmentID) {
                lastSignature = '';
                loadOrders(true);
            }
        });
    </script>
</body>
</html>
