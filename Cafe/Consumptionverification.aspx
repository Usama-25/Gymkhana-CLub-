<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Consumptionverification.aspx.cs" Inherits="ConsumptionVerification" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Consumption Verification – Lahore Gymkhana</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <%-- Fonts: Inter for UI, JetBrains Mono for data --%>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>

    <style>
        /* ═══════════════════════════════════════════════════════
           DESIGN TOKENS
        ═══════════════════════════════════════════════════════ */
        :root {
            /* Neutrals */
            --ink:       #0C1120;
            --ink-2:     #2D3654;
            --ink-3:     #5C6584;
            --ink-4:     #8F97B2;
            --canvas:    #F0F2F8;
            --surface:   #FFFFFF;
            --surface-2: #F7F8FC;
            --surface-3: #EEF0F7;
            --line:      #E2E6F0;
            --line-2:    #CDD3E6;

            /* Brand — deep navy + electric indigo */
            --navy:      #0B1437;
            --navy-2:    #162050;
            --indigo:    #4361EE;
            --indigo-2:  #3A0CA3;
            --indigo-bg: #EEF1FD;
            --indigo-bgx:#F5F7FF;
            --indigo-b:  #C7D0FA;

            /* Semantic */
            --green:     #059669;
            --green-2:   #047857;
            --green-bg:  #ECFDF5;
            --green-b:   #6EE7B7;

            --amber:     #D97706;
            --amber-bg:  #FFFBEB;
            --amber-b:   #FCD34D;

            --rose:      #E11D48;
            --rose-2:    #BE123C;
            --rose-bg:   #FFF1F2;
            --rose-b:    #FDA4AF;

            --violet:    #7C3AED;
            --violet-bg: #F5F3FF;
            --violet-b:  #C4B5FD;

            /* Shadows */
            --sh-xs: 0 1px 2px rgba(11,20,55,.04);
            --sh-sm: 0 2px 6px rgba(11,20,55,.06), 0 1px 2px rgba(11,20,55,.04);
            --sh-md: 0 6px 20px rgba(11,20,55,.09), 0 2px 6px rgba(11,20,55,.05);
            --sh-lg: 0 16px 48px rgba(11,20,55,.13), 0 4px 12px rgba(11,20,55,.07);
            --sh-ind: 0 4px 18px rgba(67,97,238,.32);

            /* Radii */
            --r-xs: 4px; --r-sm: 8px; --r: 12px;
            --r-md: 16px; --r-lg: 20px; --r-xl: 28px;
            --pill: 9999px;
        }

        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
        html { scroll-behavior: smooth; }

        body {
            font-family: 'Inter', system-ui, sans-serif;
            background: var(--canvas);
            color: var(--ink);
            font-size: 13px;
            line-height: 1.6;
            min-height: 100vh;
            -webkit-font-smoothing: antialiased;
        }

        ::-webkit-scrollbar { width: 5px; height: 5px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: var(--line-2); border-radius: 5px; }
        ::-webkit-scrollbar-thumb:hover { background: var(--indigo); }

        .pg { max-width: 1640px; margin: 0 auto; padding: 22px 26px 52px; }

        /* ═══════════════════════════════════════════════════════
           TOPBAR — dark navy with subtle shimmer stripe
        ═══════════════════════════════════════════════════════ */
        .topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: linear-gradient(110deg, var(--navy) 0%, var(--navy-2) 100%);
            padding: 0 28px;
            height: 64px;
            border-radius: var(--r-xl);
            margin-bottom: 22px;
            box-shadow: var(--sh-lg);
            position: relative;
            overflow: hidden;
        }
        /* Shimmer accent line */
        .topbar::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 2px;
            background: linear-gradient(90deg, transparent 0%, var(--indigo) 35%, #818CF8 65%, transparent 100%);
        }
        /* Soft glow blob */
        .topbar::after {
            content: '';
            position: absolute;
            top: -40px; left: -40px;
            width: 220px; height: 160px;
            background: radial-gradient(ellipse at center, rgba(67,97,238,.22) 0%, transparent 70%);
            pointer-events: none;
        }

        .tb-left { display: flex; align-items: center; gap: 16px; position: relative; z-index: 1; }

        .tb-ico {
            width: 42px; height: 42px;
            background: linear-gradient(135deg, var(--indigo), #818CF8);
            border-radius: var(--r-sm);
            display: flex; align-items: center; justify-content: center;
            font-size: 17px; color: #fff;
            box-shadow: var(--sh-ind);
            flex-shrink: 0;
        }

        .tb-title { color: #fff; font-size: 1rem; font-weight: 700; letter-spacing: -.3px; line-height: 1.2; }
        .tb-sub   { color: rgba(255,255,255,.38); font-size: .6rem; font-weight: 500; letter-spacing: .9px; text-transform: uppercase; margin-top: 1px; }

        .tb-right { display: flex; align-items: center; gap: 12px; position: relative; z-index: 1; }

        .tb-badge {
            display: inline-flex; align-items: center; gap: 6px;
            background: rgba(255,255,255,.08);
            border: 1px solid rgba(255,255,255,.13);
            color: rgba(255,255,255,.7);
            padding: 5px 13px;
            border-radius: var(--pill);
            font-size: .67rem; font-weight: 600; letter-spacing: .5px;
            backdrop-filter: blur(8px);
        }
        .tb-badge i { color: var(--indigo); font-size: 10px; }

        /* ═══════════════════════════════════════════════════════
           SESSION INFO BAR
        ═══════════════════════════════════════════════════════ */
        .session-bar {
            background: linear-gradient(135deg, #EEF1FD 0%, #F5F7FF 100%);
            border: 1px solid var(--indigo-b);
            border-left: 4px solid var(--indigo);
            padding: 11px 18px;
            border-radius: var(--r);
            margin-bottom: 18px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 10px;
            font-size: .8rem;
            box-shadow: var(--sh-xs);
        }
        .session-bar i { color: var(--indigo); margin-right: 6px; }
        .session-tag {
            background: var(--indigo);
            color: #fff;
            padding: 4px 12px;
            border-radius: var(--pill);
            font-size: .65rem;
            font-weight: 700;
            letter-spacing: .4px;
        }

        /* ═══════════════════════════════════════════════════════
           ALERT
        ═══════════════════════════════════════════════════════ */
        .alert-box {
            display: flex; align-items: center; gap: 10px;
            padding: 11px 16px;
            border-radius: var(--r);
            font-size: .8rem; font-weight: 600;
            border-left: 3px solid transparent;
            margin-bottom: 18px;
        }
        .alert-box i { font-size: 14px; flex-shrink: 0; }
        .alert-success { background: var(--green-bg);  border-color: var(--green);  color: var(--green-2); }
        .alert-error   { background: var(--rose-bg);   border-color: var(--rose);   color: var(--rose-2); }
        .alert-warning { background: var(--amber-bg);  border-color: var(--amber);  color: var(--amber); }
        .alert-info    { background: var(--indigo-bg); border-color: var(--indigo); color: var(--indigo-2); }

        /* ═══════════════════════════════════════════════════════
           CARD
        ═══════════════════════════════════════════════════════ */
        .card {
            background: var(--surface);
            border-radius: var(--r-lg);
            box-shadow: var(--sh-sm);
            border: 1px solid var(--line);
            margin-bottom: 20px;
            overflow: hidden;
        }
        .card-head {
            padding: 14px 22px;
            border-bottom: 1px solid var(--line);
            background: linear-gradient(to right, var(--surface-2), var(--surface));
            display: flex; justify-content: space-between; align-items: center;
            gap: 12px; flex-wrap: wrap;
        }
        .card-head h3 {
            font-size: .84rem; font-weight: 700; color: var(--ink);
            display: flex; align-items: center; gap: 8px; margin: 0;
        }
        .card-head h3 i { color: var(--indigo); font-size: 13px; }
        .card-body { padding: 20px 22px; }

        /* ═══════════════════════════════════════════════════════
           FILTER ROW
        ═══════════════════════════════════════════════════════ */
        .filter-row { display: flex; align-items: flex-end; gap: 14px; flex-wrap: wrap; }

        .fg { display: flex; flex-direction: column; gap: 5px; }
        .fg label {
            font-size: .63rem; font-weight: 700; color: var(--ink-3);
            text-transform: uppercase; letter-spacing: .8px;
            display: flex; align-items: center; gap: 5px;
        }
        .fg label i { color: var(--indigo); font-size: 10px; }

        .select-wrap { position: relative; width: 300px; }
        .select-wrap .s-ico {
            position: absolute; left: 12px; top: 50%; transform: translateY(-50%);
            color: var(--ink-3); font-size: 12px; pointer-events: none; z-index: 1;
        }
        .select-wrap select {
            width: 100%; height: 40px;
            padding: 0 38px 0 34px;
            border: 1.5px solid var(--line-2);
            border-radius: var(--r-sm);
            font-family: 'Inter', sans-serif;
            font-size: 13px; font-weight: 500; color: var(--ink);
            background: var(--surface);
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath d='M1 1l5 5 5-5' fill='none' stroke='%235C6584' stroke-width='1.6' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 12px center;
            cursor: pointer;
            transition: border-color .15s, box-shadow .15s;
        }
        .select-wrap select:focus {
            outline: none;
            border-color: var(--indigo);
            box-shadow: 0 0 0 3px rgba(67,97,238,.12);
        }

        /* ═══════════════════════════════════════════════════════
           BUTTONS
        ═══════════════════════════════════════════════════════ */
        .wbtn {
            display: inline-flex; align-items: center; justify-content: center;
            gap: 7px; height: 40px; padding: 0 20px;
            border: none; border-radius: var(--r-sm);
            font-size: 12.5px; font-weight: 700;
            font-family: 'Inter', sans-serif;
            cursor: pointer; transition: all .18s;
            white-space: nowrap; letter-spacing: -.1px;
        }
        .wbtn-primary {
            background: var(--indigo); color: #fff;
            box-shadow: var(--sh-ind);
        }
        .wbtn-primary:hover { background: var(--indigo-2); transform: translateY(-1px); box-shadow: 0 6px 22px rgba(67,97,238,.42); }

        .wbtn-ghost {
            background: var(--surface); color: var(--ink-2);
            border: 1.5px solid var(--line-2);
        }
        .wbtn-ghost:hover { background: var(--indigo-bg); border-color: var(--indigo); color: var(--indigo-2); transform: translateY(-1px); }

        .wbtn-success {
            background: linear-gradient(135deg, var(--green-2), var(--green));
            color: #fff;
            box-shadow: 0 3px 14px rgba(5,150,105,.28);
        }
        .wbtn-success:hover { transform: translateY(-1px); box-shadow: 0 7px 22px rgba(5,150,105,.44); }

        .wbtn-sm { height: 36px; padding: 0 16px; font-size: 12px; }

        .row-btn {
            display: inline-flex; align-items: center; gap: 5px;
            height: 28px; padding: 0 11px;
            background: var(--indigo-bg);
            color: var(--indigo);
            border: 1.5px solid var(--indigo-b);
            border-radius: var(--r-sm);
            font-family: 'Inter', sans-serif;
            font-size: 11px; font-weight: 700;
            cursor: pointer; transition: all .16s; white-space: nowrap;
        }
        .row-btn:hover { background: var(--indigo); color: #fff; border-color: var(--indigo); transform: translateY(-1px); }

        /* ═══════════════════════════════════════════════════════
           STAT TILES
        ═══════════════════════════════════════════════════════ */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 20px;
        }

        .stat-tile {
            background: var(--surface);
            border-radius: var(--r-lg);
            padding: 18px 20px;
            border: 1px solid var(--line);
            box-shadow: var(--sh-xs);
            display: flex; align-items: center; gap: 16px;
            transition: all .2s;
            position: relative;
            overflow: hidden;
        }
        .stat-tile::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 3px;
        }
        .stat-tile:hover { transform: translateY(-3px); box-shadow: var(--sh-md); }

        .tile-ind::before  { background: linear-gradient(90deg, var(--indigo), #818CF8); }
        .tile-rose::before { background: linear-gradient(90deg, var(--rose), #F43F5E); }
        .tile-amb::before  { background: linear-gradient(90deg, var(--amber), #F59E0B); }
        .tile-grn::before  { background: linear-gradient(90deg, var(--green-2), var(--green)); }

        .stat-ico {
            width: 44px; height: 44px;
            border-radius: var(--r);
            display: flex; align-items: center; justify-content: center;
            font-size: 18px; flex-shrink: 0;
        }
        .ico-ind  { background: var(--indigo-bg); color: var(--indigo); }
        .ico-rose { background: var(--rose-bg);   color: var(--rose); }
        .ico-amb  { background: var(--amber-bg);  color: var(--amber); }
        .ico-grn  { background: var(--green-bg);  color: var(--green); }

        .stat-lbl { font-size: .6rem; font-weight: 700; color: var(--ink-4); text-transform: uppercase; letter-spacing: .8px; margin-bottom: 3px; }
        .stat-val { font-family: 'JetBrains Mono', monospace; font-size: 1.55rem; font-weight: 700; line-height: 1; }
        .val-ind  { color: var(--indigo); }
        .val-rose { color: var(--rose); }
        .val-amb  { color: var(--amber); }
        .val-grn  { color: var(--green); }

        /* ═══════════════════════════════════════════════════════
           GRID TABLE — redesigned with fixed layout
        ═══════════════════════════════════════════════════════ */
        .tbl-wrap {
            overflow: auto;
            max-height: 660px;
        }

        .cc-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            font-size: 12.5px;
            table-layout: fixed;
        }

        /* Column widths */
        .col-sel    { width:  44px; }
        .col-ccid   { width:  70px; }
        .col-dept   { width: 120px; }
        .col-ingr   { width: 190px; }
        .col-code   { width:  88px; }
        .col-unit   { width:  52px; }
        .col-cf     { width:  68px; }
        .col-exp    { width:  98px; }
        .col-actual { width: 122px; }
        .col-diff   { width:  90px; }
        .col-stock  { width: 100px; }
        .col-rem    { width: 155px; }
        .col-date   { width:  82px; }
        .col-act    { width:  82px; }

        /* HEADER */
        .cc-table thead th {
            padding: 11px 10px;
            font-size: .58rem;
            font-weight: 700;
            color: var(--ink-4);
            text-transform: uppercase;
            letter-spacing: .75px;
            background: var(--surface-2);
            border-bottom: 2px solid var(--line);
            border-top: none;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            position: sticky;
            top: 0;
            z-index: 3;
            text-align: left;
        }
        .cc-table thead th.th-right  { text-align: right; }
        .cc-table thead th.th-center { text-align: center; }

        /* Subtle column group separators */
        .cc-table thead th.sep-left { border-left: 1px solid var(--line-2); }

        /* DATA ROWS */
        .cc-table tbody tr { transition: background .12s; }
        .cc-table tbody td {
            padding: 9px 10px;
            border-bottom: 1px solid var(--line);
            vertical-align: middle;
            color: var(--ink-2);
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            line-height: 1.4;
        }
        .cc-table tbody td.td-name   { white-space: normal; word-break: break-word; }
        .cc-table tbody tr:last-child td { border-bottom: none; }

        /* Row hover */
        .cc-table tbody tr:hover td { background: var(--indigo-bgx); }

        /* Even row subtle tint */
        .cc-table tbody tr:nth-child(even) td { background: var(--surface-2); }
        .cc-table tbody tr:nth-child(even):hover td { background: var(--indigo-bgx); }

        /* Text helpers */
        .cc-table .center { text-align: center; }
        .cc-table .right  { text-align: right; }
        .cc-table .mono   { font-family: 'JetBrains Mono', monospace; font-size: 11.5px; font-weight: 500; }

        /* ── Cell styles ──────────────────────────────────── */
        .name-cell { font-weight: 600; color: var(--ink); font-size: 12.5px; }
        .code-cell { color: var(--ink-3); font-family: 'JetBrains Mono', monospace; font-size: 11px; }

        /* CC ID chip */
        .ccid-chip {
            display: inline-block; padding: 2px 9px;
            border-radius: var(--pill);
            font-family: 'JetBrains Mono', monospace;
            font-size: 11px; font-weight: 600;
            background: var(--indigo-bg); color: var(--indigo);
            border: 1px solid var(--indigo-b);
        }

        /* Dept pill */
        .dept-pill {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 3px 9px; border-radius: var(--pill);
            font-size: 10.5px; font-weight: 600;
            background: var(--violet-bg); color: var(--violet);
            border: 1px solid var(--violet-b);
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 100%;
        }
        .dept-pill i { font-size: 8px; }

        /* CF badge */
        .cf-badge {
            display: inline-block; padding: 2px 8px;
            border-radius: var(--pill);
            font-family: 'JetBrains Mono', monospace;
            font-size: 10.5px; font-weight: 600;
            background: var(--violet-bg); color: var(--violet);
            border: 1px solid var(--violet-b);
        }

        /* ── Stock row highlights ───────────────────────── */
        .cc-table tbody tr.row-zero-stock td,
        .cc-table tbody tr:nth-child(even).row-zero-stock td {
            background: #FFF1F2 !important;
        }
        .cc-table tbody tr.row-zero-stock:hover td { background: #FFE4E8 !important; }
        tr.row-zero-stock .qty-inp { border-color: var(--rose); background: var(--rose-bg); }

        .cc-table tbody tr.row-low-stock td,
        .cc-table tbody tr:nth-child(even).row-low-stock td {
            background: #FFFBEB !important;
        }
        .cc-table tbody tr.row-low-stock:hover td { background: #FEF3C7 !important; }
        tr.row-low-stock .qty-inp { border-color: var(--amber); background: var(--amber-bg); }

        /* Stock hint */
        .stk-hint {
            display: block;
            font-size: 10px; color: var(--rose);
            font-weight: 600; margin-top: 3px;
            line-height: 1.3; white-space: normal;
        }
        .stk-hint i { font-size: 9px; margin-right: 2px; }

        /* ── Inputs ─────────────────────────────────────── */
        .qty-inp {
            width: 100%; height: 30px;
            padding: 0 8px;
            border: 1.5px solid var(--line-2);
            border-radius: var(--r-sm);
            font-family: 'JetBrains Mono', monospace;
            font-size: 12px; font-weight: 600;
            color: var(--ink); background: var(--surface);
            text-align: right;
            transition: border-color .15s, box-shadow .15s;
            display: block;
        }
        .qty-inp:focus  { outline: none; border-color: var(--indigo); box-shadow: 0 0 0 3px rgba(67,97,238,.1); }
        .qty-inp.edited { border-color: var(--amber); background: var(--amber-bg); }

        .rem-inp {
            width: 100%; height: 30px; padding: 0 8px;
            border: 1.5px solid var(--line-2);
            border-radius: var(--r-sm);
            font-family: 'Inter', sans-serif;
            font-size: 11.5px; font-weight: 500;
            color: var(--ink); background: var(--surface);
            transition: border-color .15s, box-shadow .15s; display: block;
        }
        .rem-inp:focus  { outline: none; border-color: var(--indigo); box-shadow: 0 0 0 3px rgba(67,97,238,.1); }
        .rem-inp.edited { border-color: var(--amber); background: var(--amber-bg); }

        /* ── Diff badge ─────────────────────────────────── */
        .diff-badge {
            display: inline-block; padding: 2px 8px;
            border-radius: var(--pill);
            font-family: 'JetBrains Mono', monospace;
            font-size: 11px; font-weight: 600;
            min-width: 56px; text-align: right;
        }
        .diff-pos  { background: var(--green-bg);  color: var(--green-2);  border: 1px solid var(--green-b); }
        .diff-neg  { background: var(--rose-bg);   color: var(--rose-2);   border: 1px solid var(--rose-b); }
        .diff-zero { background: var(--surface-3); color: var(--ink-3);    border: 1px solid var(--line-2); }

        /* ── Stock badges ───────────────────────────────── */
        .stk-ok   { display: inline-block; padding: 2px 9px; border-radius: var(--pill); font-family: 'JetBrains Mono', monospace; font-size: 11px; font-weight: 600; background: var(--green-bg);  color: var(--green-2);  border: 1px solid var(--green-b); }
        .stk-low  { display: inline-block; padding: 2px 9px; border-radius: var(--pill); font-family: 'JetBrains Mono', monospace; font-size: 11px; font-weight: 600; background: var(--amber-bg);  color: var(--amber);    border: 1px solid var(--amber-b); }
        .stk-zero { display: inline-block; padding: 2px 9px; border-radius: var(--pill); font-family: 'JetBrains Mono', monospace; font-size: 11px; font-weight: 600; background: var(--rose-bg);   color: var(--rose-2);   border: 1px solid var(--rose-b); }

        /* ── Remarks badges ─────────────────────────────── */
        .rem-normal   { display: inline-flex; align-items: center; gap: 4px; padding: 2px 9px; border-radius: var(--pill); font-size: 10.5px; font-weight: 700; background: var(--green-bg);  color: var(--green-2); border: 1px solid var(--green-b); }
        .rem-shortage { display: inline-flex; align-items: center; gap: 4px; padding: 2px 9px; border-radius: var(--pill); font-size: 10.5px; font-weight: 700; background: var(--rose-bg);   color: var(--rose-2);  border: 1px solid var(--rose-b); }
        .rem-over     { display: inline-flex; align-items: center; gap: 4px; padding: 2px 9px; border-radius: var(--pill); font-size: 10.5px; font-weight: 700; background: var(--amber-bg);  color: var(--amber);   border: 1px solid var(--amber-b); }

        /* ── Checkbox ───────────────────────────────────── */
        .cc-table td input[type="checkbox"],
        .cc-table th input[type="checkbox"] {
            width: 15px; height: 15px;
            cursor: pointer;
            accent-color: var(--indigo);
            vertical-align: middle;
        }

        /* ── Unsaved indicator ──────────────────────────── */
        .unsaved-dot {
            display: none; width: 7px; height: 7px;
            border-radius: 50%; background: var(--amber);
            margin-left: 6px; vertical-align: middle;
            box-shadow: 0 0 0 3px rgba(217,119,6,.2);
            animation: pulse-amber 1.4s ease-in-out infinite;
        }
        .unsaved-dot.on { display: inline-block; }
        @keyframes pulse-amber {
            0%, 100% { box-shadow: 0 0 0 3px rgba(217,119,6,.2); }
            50%       { box-shadow: 0 0 0 6px rgba(217,119,6,.05); }
        }

        /* ═══════════════════════════════════════════════════════
           EMPTY STATE
        ═══════════════════════════════════════════════════════ */
        .empty-state { text-align: center; padding: 60px 24px; background: var(--surface-2); }
        .empty-ico {
            width: 64px; height: 64px;
            background: var(--indigo-bg);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 26px; color: var(--indigo);
            margin: 0 auto 18px;
        }
        .empty-state h4 { color: var(--ink-2); font-size: .95rem; font-weight: 700; margin-bottom: 6px; }
        .empty-state p  { color: var(--ink-4); font-size: .8rem; }

        /* ═══════════════════════════════════════════════════════
           PAGER
        ═══════════════════════════════════════════════════════ */
        .pager-row {
            display: flex; align-items: center; justify-content: center;
            gap: 4px; padding: 12px 22px;
            background: var(--surface-2);
            border-top: 1px solid var(--line);
        }
        .pager-row a, .pager-row span {
            display: inline-block; padding: 5px 13px;
            background: var(--surface);
            border: 1.5px solid var(--line-2);
            color: var(--ink-3);
            border-radius: var(--r-sm);
            font-size: .7rem; font-family: 'JetBrains Mono', monospace; font-weight: 600;
            text-decoration: none; transition: all .15s;
        }
        .pager-row a:hover       { background: var(--indigo); color: #fff; border-color: var(--indigo); }
        .pager-row span.current  { background: var(--indigo); color: #fff; border-color: var(--indigo); }

        /* ═══════════════════════════════════════════════════════
           GRID FOOTER
        ═══════════════════════════════════════════════════════ */
        .grid-footer {
            display: flex; align-items: center; justify-content: space-between;
            padding: 12px 22px;
            background: var(--surface-2);
            border-top: 1px solid var(--line);
            flex-wrap: wrap; gap: 10px;
        }
        .gf-note { font-size: .72rem; color: var(--ink-3); display: flex; align-items: center; gap: 6px; }
        .gf-note i { color: var(--indigo); }

        /* Legend dots */
        .legend { display: flex; align-items: center; gap: 14px; flex-wrap: wrap; }
        .leg-item { display: flex; align-items: center; gap: 5px; font-size: .68rem; color: var(--ink-3); font-weight: 500; }
        .leg-dot  { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
        .leg-rose { background: var(--rose); }
        .leg-amb  { background: var(--amber); }

        /* ═══════════════════════════════════════════════════════
           RESPONSIVE
        ═══════════════════════════════════════════════════════ */
        @media(max-width: 1200px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } }
        @media(max-width: 768px)  {
            .pg { padding: 14px 14px 36px; }
            .stats-grid { grid-template-columns: 1fr 1fr; gap: 10px; }
            .filter-row { flex-direction: column; align-items: stretch; }
            .select-wrap { width: 100%; }
            .topbar { height: auto; padding: 14px 18px; }
            .tb-right { display: none; }
        }
        @media(max-width: 480px) { .stats-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="pg">

    <%-- ══════════════════════════════════════════
         TOPBAR
    ══════════════════════════════════════════ --%>
    <div class="topbar">
        <div class="tb-left">
            <div class="tb-ico"><i class="fas fa-clipboard-check"></i></div>
            <div>
                <div class="tb-title">Consumption Verification</div>
                <div class="tb-sub">Stock vs Expected · Department Analysis</div>
            </div>
        </div>
        <div class="tb-right">
            <span class="tb-badge"><i class="fas fa-circle-dot"></i> Live Stock Check</span>
            <span class="tb-badge"><i class="fas fa-pen-to-square"></i> Edit Actual Qty per row → Update → Save</span>
        </div>
    </div>

    <%-- ── Session info bar ─────────────────────────────── --%>
    <asp:Panel ID="pnlSessionInfo" runat="server" Visible="false">
        <div class="session-bar">
            <div>
                <i class="fas fa-bolt"></i>
                <strong>Auto-loaded from verification request</strong> &nbsp;·&nbsp;
                Department: <span id="spanDeptName" runat="server" style="font-weight:700"></span>
                &nbsp;·&nbsp; Counter Close ID:
                <span id="spanCCID" runat="server" style="font-weight:700;font-family:'JetBrains Mono',monospace"></span>
            </div>
            <span class="session-tag"><i class="fas fa-check-circle"></i> &nbsp;Verification Mode</span>
        </div>
    </asp:Panel>

    <%-- ── Alert ─────────────────────────────────────────── --%>
    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <div id="divAlert" runat="server" class="alert-box alert-info">
            <asp:Label ID="lblAlertMsg" runat="server" />
        </div>
    </asp:Panel>

    <%-- ══════════════════════════════════════════
         FILTER CARD
    ══════════════════════════════════════════ --%>
    <div class="card">
        <div class="card-head">
            <h3><i class="fas fa-sliders"></i> Filter by Department</h3>
        </div>
        <div class="card-body">
            <div class="filter-row">
                <asp:HiddenField ID="hfSubDeptId"       runat="server" />
                <asp:HiddenField ID="hfAutoLoadMode"    runat="server" Value="false" />
                <%-- [FIX-5] Tracks checked DetailIds across pages --%>
                <asp:HiddenField ID="hfCheckedDetailIds" runat="server" />

                <div class="fg">
                    <label><i class="fas fa-building"></i> Department</label>
                    <div class="select-wrap">
                        <i class="fas fa-sitemap s-ico"></i>
                        <asp:DropDownList ID="ddlDepartment" runat="server" />
                    </div>
                </div>

                <asp:Button ID="btnSearch" runat="server" Text="Search"
                    CssClass="wbtn wbtn-primary" OnClick="btnSearch_Click" />
                <asp:Button ID="btnClear"  runat="server" Text="Clear"
                    CssClass="wbtn wbtn-ghost"  OnClick="btnClear_Click" />
            </div>
        </div>
    </div>

    <%-- ══════════════════════════════════════════
         STAT TILES
    ══════════════════════════════════════════ --%>
    <asp:Panel ID="pnlStats" runat="server" Visible="false">
        <div class="stats-grid">
            <div class="stat-tile tile-ind">
                <div class="stat-ico ico-ind"><i class="fas fa-list-check"></i></div>
                <div>
                    <div class="stat-lbl">Total Rows</div>
                    <div class="stat-val val-ind"><asp:Label ID="lblTotalRows" runat="server" Text="0" /></div>
                </div>
            </div>
            <div class="stat-tile tile-rose">
                <div class="stat-ico ico-rose"><i class="fas fa-arrow-trend-down"></i></div>
                <div>
                    <div class="stat-lbl">Shortage</div>
                    <div class="stat-val val-rose"><asp:Label ID="lblShortage" runat="server" Text="0" /></div>
                </div>
            </div>
            <div class="stat-tile tile-amb">
                <div class="stat-ico ico-amb"><i class="fas fa-arrow-trend-up"></i></div>
                <div>
                    <div class="stat-lbl">Over</div>
                    <div class="stat-val val-amb"><asp:Label ID="lblOver" runat="server" Text="0" /></div>
                </div>
            </div>
            <div class="stat-tile tile-grn">
                <div class="stat-ico ico-grn"><i class="fas fa-circle-check"></i></div>
                <div>
                    <div class="stat-lbl">Normal</div>
                    <div class="stat-val val-grn"><asp:Label ID="lblOk" runat="server" Text="0" /></div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <%-- ══════════════════════════════════════════
         GRID CARD
    ══════════════════════════════════════════ --%>
    <div class="card">
        <div class="card-head">
            <h3>
                <i class="fas fa-table-list"></i>
                Consumption Details
                <span id="unsavedDot" class="unsaved-dot" title="You have unsaved row edits"></span>
            </h3>
            <asp:Button ID="btnSaveConsumption" runat="server"
                Text="Save to Store"
                CssClass="wbtn wbtn-success wbtn-sm"
                OnClick="btnSaveConsumption_Click"
                OnClientClick="return confirmSave();" />
        </div>

        <div class="tbl-wrap">
            <%-- [FIX-2] DataKeyNames changed from "ItemCode" to "DetailId" --%>
            <asp:GridView ID="gvConsumption" runat="server"
                AutoGenerateColumns="False"
                CssClass="cc-table"
                GridLines="None"
                AllowPaging="True"
                PageSize="25"
                OnPageIndexChanging="gvConsumption_PageIndexChanging"
                OnRowCommand="gvConsumption_RowCommand"
                OnRowDataBound="gvConsumption_RowDataBound"
                DataKeyNames="DetailId"
                PagerStyle-CssClass="pager-row">

                <Columns>

                    <%-- ── Select ──────────────────────────────────────────────── --%>
                    <asp:TemplateField>
                        <HeaderStyle CssClass="th-center col-sel" />
                        <ItemStyle   CssClass="center col-sel" />
                        <HeaderTemplate>
                            <asp:CheckBox ID="chkAll" runat="server" onclick="SelectAll(this)" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <%-- [FIX-5] onchange tracks DetailId in hidden field for cross-page save --%>
                            <asp:CheckBox ID="chkSelect" runat="server"
                                onclick='<%# "trackCheck(this, \"" + Eval("DetailId") + "\")" %>' />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- ── CC ID ─────────────────────────────────────────────────── --%>
                    <asp:TemplateField HeaderText="CC ID">
                        <HeaderStyle CssClass="th-center col-ccid" />
                        <ItemStyle   CssClass="center col-ccid" />
                        <ItemTemplate>
                            <span class="ccid-chip"><%# Eval("CounterCloseId") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- ── Department ──────────────────────────────────────────────── --%>
                    <asp:TemplateField HeaderText="Department">
                        <HeaderStyle CssClass="col-dept" />
                        <ItemStyle   CssClass="col-dept" />
                        <ItemTemplate>
                            <span class="dept-pill">
                                <i class="fas fa-building"></i><%# Eval("DepartmentName") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- ── Ingredient ───────────────────────────────────────────────── --%>
                    <asp:BoundField DataField="IngredientName" HeaderText="Ingredient"
                        HeaderStyle-CssClass="col-ingr"
                        ItemStyle-CssClass="td-name name-cell col-ingr" />

                    <%-- ── Item Code ─────────────────────────────────────────────────── --%>
                    <asp:TemplateField HeaderText="Code">
                        <HeaderStyle CssClass="col-code" />
                        <ItemStyle   CssClass="code-cell col-code" />
                        <ItemTemplate>
                            <%# Eval("ItemCode") %>
                            <%-- Hidden label so UpdateRow + Save can read ItemCode per row [LOGIC-4] --%>
                            <asp:Label ID="lblItemCodeHidden" runat="server"
                                Text='<%# Eval("ItemCode") %>'
                                style="display:none;" />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- ── Unit ────────────────────────────────────────────────────────── --%>
                    <asp:BoundField DataField="Unit" HeaderText="Unit"
                        HeaderStyle-CssClass="th-center col-unit"
                        ItemStyle-CssClass="center mono col-unit" />

                    <%-- ── Conversion Factor ──────────────────────────────────────────── --%>
                    <asp:TemplateField HeaderText="CF">
                        <HeaderStyle CssClass="th-center col-cf" />
                        <ItemStyle   CssClass="center col-cf" />
                        <ItemTemplate>
                            <span class="cf-badge"><%# string.Format("{0:N2}", Eval("ConversionFactor")) %></span>
                            <asp:Label ID="lblConversionFactorHidden" runat="server"
                                Text='<%# Eval("ConversionFactor") %>'
                                style="display:none;" />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- ── Expected ÷ CF ──────────────────────────────────────────────── --%>
                    <asp:TemplateField HeaderText="Expected÷CF">
                        <HeaderStyle CssClass="th-right col-exp sep-left" />
                        <ItemStyle   CssClass="right mono col-exp" />
                        <ItemTemplate>
                            <%# string.Format("{0:N3}", Eval("ExpectedQty")) %>
                            <asp:Label ID="lblExpectedQtyHidden" runat="server"
                                Text='<%# Eval("ExpectedQty") %>'
                                style="display:none;" />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- ── Actual ÷ CF (editable) ─────────────────────────────────────── --%>
                    <asp:TemplateField HeaderText="Actual÷CF ✏">
                        <HeaderStyle CssClass="th-right col-actual" />
                        <ItemStyle   CssClass="right col-actual" />
                        <ItemTemplate>
                            <%-- [FIX-8] both onchange AND oninput to catch paste events --%>
                            <asp:TextBox ID="txtActualQty" runat="server"
                                Text='<%# string.Format("{0:N3}", Eval("ActualQty")) %>'
                                CssClass="qty-inp"
                                onchange="markEdited(this); recalcDiff(this);"
                                oninput="markEdited(this); recalcDiff(this);" />
                            <%-- [FIX-7] Empty in ASPX; code-behind sets Text --%>
                            <asp:Label ID="lblZeroStockHint" runat="server"
                                CssClass="stk-hint" Visible="false" />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- ── Difference ÷ CF ─────────────────────────────────────────────── --%>
                    <asp:TemplateField HeaderText="Diff÷CF">
                        <HeaderStyle CssClass="th-right col-diff" />
                        <ItemStyle   CssClass="right col-diff" />
                        <ItemTemplate>
                            <%# string.Format("<span class='diff-badge {0}'>{1:N3}</span>",
                                    GetDiffClass(Eval("DifferenceQty")),
                                    Eval("DifferenceQty")) %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- ── Current Stock ────────────────────────────────────────────────── --%>
                    <asp:TemplateField HeaderText="Curr. Stock">
                        <HeaderStyle CssClass="th-right col-stock sep-left" />
                        <ItemStyle   CssClass="right col-stock" />
                        <ItemTemplate>
                            <%# GetStockBadge(Eval("CurrentStock"), Eval("ExpectedQty")) %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- ── Remarks (editable) ─────────────────────────────────────────── --%>
                    <asp:TemplateField HeaderText="Remarks ✏">
                        <HeaderStyle CssClass="col-rem" />
                        <ItemStyle   CssClass="col-rem" />
                        <ItemTemplate>
                            <asp:TextBox ID="txtUserRemarks" runat="server"
                                Text='<%# Eval("Remarks") %>'
                                CssClass="rem-inp"
                                placeholder="Shortage / Over / Normal…"
                                onchange="markEdited(this)"
                                oninput="markEdited(this)" />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- ── Date ──────────────────────────────────────────────────────────── --%>
                    <asp:BoundField DataField="CreatedDate" HeaderText="Date"
                        DataFormatString="{0:dd MMM yy}"
                        HeaderStyle-CssClass="col-date"
                        ItemStyle-CssClass="mono col-date" />

                    <%-- ── Action ─────────────────────────────────────────────────────────── --%>
                    <asp:TemplateField HeaderText="Action">
                        <HeaderStyle CssClass="th-center col-act" />
                        <ItemStyle   CssClass="center col-act" />
                        <ItemTemplate>
                            <asp:Button ID="btnUpdateRow" runat="server"
                                Text="Update"
                                CssClass="row-btn"
                                CommandName="UpdateRow"
                                CommandArgument='<%# Eval("DetailId") %>'
                                OnClientClick="return confirmUpdate(this);" />
                        </ItemTemplate>
                    </asp:TemplateField>

                </Columns>

                <EmptyDataTemplate>
                    <div class="empty-state">
                        <div class="empty-ico"><i class="fas fa-inbox"></i></div>
                        <h4>No Records Found</h4>
                        <p>Select a department above and click <strong>Search</strong> to load consumption records.</p>
                    </div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>

        <div class="grid-footer">
            <span class="gf-note">
                <i class="fas fa-circle-info"></i>
                Qty shown ÷ CF &nbsp;·&nbsp; Edit Actual Qty then <strong>Update</strong> per row
                &nbsp;·&nbsp; Check rows then <strong>Save to Store</strong>
            </span>
            <div class="legend">
                <span class="leg-item"><span class="leg-dot leg-rose"></span> Zero stock</span>
                <span class="leg-item"><span class="leg-dot leg-amb"></span> Insufficient stock</span>
            </div>
        </div>
    </div>

</div>
</form>

<script type="text/javascript">
    // ── Sync hidden field when dept dropdown changes ──────────────────────
    document.addEventListener('DOMContentLoaded', function () {
        var ddl = document.getElementById('<%= ddlDepartment.ClientID %>');
        var hf  = document.getElementById('<%= hfSubDeptId.ClientID %>');
        if (ddl && hf) {
            ddl.addEventListener('change', function () { hf.value = ddl.value; });
            if (ddl.value) hf.value = ddl.value;
        }

        // [FIX-9] Reset header checkbox on page load (after paging postback)
        var chkAll = document.querySelector('input[id*="chkAll"]');
        if (chkAll) chkAll.checked = false;
    });

    // ── [FIX-5] Track checked state across pages using hidden field ──────
    function trackCheck(chk, detailId) {
        var hf  = document.getElementById('<%= hfCheckedDetailIds.ClientID %>');
        var ids = hf.value ? hf.value.split(',').filter(Boolean) : [];
        var id  = String(detailId);

        if (chk.checked) {
            if (ids.indexOf(id) === -1) ids.push(id);
        } else {
            ids = ids.filter(function(x){ return x !== id; });
        }
        hf.value = ids.join(',');
        updateUnsavedDot();
    }

    // ── [LOGIC-6] SelectAll — skips header checkbox itself ───────────────
    function SelectAll(source) {
        var grid = source.closest('table');
        var checkboxes = grid.querySelectorAll("input[type='checkbox'][id*='chkSelect']");
        for (var i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = source.checked;
            // Sync tracking hidden field
            var row = checkboxes[i].closest('tr');
            if (row) {
                var btns = row.querySelectorAll('input[type="submit"][id*="btnUpdateRow"], button[id*="btnUpdateRow"]');
                // Get DetailId from the onclick attribute of the update button via CommandArgument
                var updateBtn = row.querySelector('[id*="btnUpdateRow"]');
                if (updateBtn) {
                    // extract value from onclick or use data
                    var match = (updateBtn.value || '').match(/\d+/);
                    // fallback: get from the checkbox onclick attr
                }
            }
        }
        // Rebuild entire tracked set from visible checkboxes
        syncAllVisible();
    }

    function syncAllVisible() {
        var hf  = document.getElementById('<%= hfCheckedDetailIds.ClientID %>');
        var existing = hf.value ? hf.value.split(',').filter(Boolean) : [];
        var checkboxes = document.querySelectorAll("input[type='checkbox'][id*='chkSelect']");
        checkboxes.forEach(function(chk) {
            var onclick = chk.getAttribute('onclick') || '';
            var match   = onclick.match(/'(\d+)'/);
            if (!match) return;
            var id = match[1];
            if (chk.checked) {
                if (existing.indexOf(id) === -1) existing.push(id);
            } else {
                existing = existing.filter(function(x){ return x !== id; });
            }
        });
        hf.value = existing.join(',');
        updateUnsavedDot();
    }

    // ── Mark input as edited ─────────────────────────────────────────────
    function markEdited(el) {
        el.classList.add('edited');
        updateUnsavedDot();
    }

    function updateUnsavedDot() {
        var dot    = document.getElementById('unsavedDot');
        var edited = document.querySelectorAll('.edited');
        var hf     = document.getElementById('<%= hfCheckedDetailIds.ClientID %>');
        var hasChecked = hf && hf.value.length > 0;
        if (dot) dot.className = 'unsaved-dot' + (edited.length > 0 || hasChecked ? ' on' : '');
    }

    // ── Confirm per-row update ───────────────────────────────────────────
    function confirmUpdate(btn) {
        var row = btn.closest('tr');
        var inp = row ? row.querySelector('input[id*="txtActualQty"]') : null;
        var qty = inp ? inp.value : '?';
        return confirm('Update this row?\n\nActual Qty = ' + qty + '\n\nThis will save to the database immediately.');
    }

    // ── Confirm save — warn on zero-stock rows with non-zero qty ────────
    function confirmSave() {
        var zeroRows = [];

        // Check zero-stock rows
        document.querySelectorAll('tr.row-zero-stock').forEach(function(row) {
            var chk = row.querySelector("input[type='checkbox'][id*='chkSelect']");
            if (!chk || !chk.checked) return;
            var inp = row.querySelector("input[id*='txtActualQty']");
            var qty = inp ? parseFloat(inp.value) : 0;
            if (qty > 0) {
                var nameCell = row.querySelector('td.name-cell');
                zeroRows.push(nameCell ? nameCell.textContent.trim() : 'Unknown item');
            }
        });

        // [FIX-9] Also warn on low-stock rows
        var lowRows = [];
        document.querySelectorAll('tr.row-low-stock').forEach(function(row) {
            var chk = row.querySelector("input[type='checkbox'][id*='chkSelect']");
            if (!chk || !chk.checked) return;
            var nameCell = row.querySelector('td.name-cell');
            lowRows.push(nameCell ? nameCell.textContent.trim() : 'Unknown item');
        });

        if (zeroRows.length > 0) {
            return confirm(
                '\u26a0\ufe0f  WARNING: ' + zeroRows.length + ' selected item(s) have zero stock but non-zero Actual Qty:\n\n' +
                zeroRows.join('\n') +
                '\n\nThe store procedure will BLOCK these rows.\n' +
                'Click Cancel to set their Actual Qty to 0 first.\n' +
                'Click OK to proceed anyway (they will be skipped).'
            );
        }

        if (lowRows.length > 0) {
            return confirm(
                '\u26a0\ufe0f  NOTICE: ' + lowRows.length + ' selected item(s) have insufficient stock (amber rows):\n\n' +
                lowRows.join('\n') +
                '\n\nIf Actual Used exceeds available stock these rows will be blocked.\n' +
                'Click OK to proceed, or Cancel to review.'
            );
        }

        return confirm('Save selected consumption records to the store system?');
    }

    // ── [LOGIC-7] Live difference recalculation ──────────────────────────
    function recalcDiff(inp) {
        var row = inp.closest('tr');
        if (!row) return;

        // [LOGIC-7] Attribute selector on any element tag
        var expLabel = row.querySelector('[id*="lblExpectedQtyHidden"]');
        var expQty   = expLabel ? parseFloat(expLabel.textContent || expLabel.innerText) : NaN;
        var actQty   = parseFloat(inp.value);

        var diffSpan = row.querySelector('.diff-badge');
        if (!diffSpan || isNaN(expQty) || isNaN(actQty)) return;

        var diff = actQty - expQty;
        diffSpan.textContent = diff.toFixed(3);
        diffSpan.className   = 'diff-badge ' + (diff < 0 ? 'diff-neg' : diff > 0 ? 'diff-pos' : 'diff-zero');

        // Auto-fill system remark if user hasn't customised it
        // [FIX-8] Works for both input and paste events
        var remInput = row.querySelector('input[id*="txtUserRemarks"]');
        if (remInput) {
            var cur = remInput.value.trim();
            if (cur === '' || cur === 'Shortage' || cur === 'Over' || cur === 'Normal') {
                remInput.value = diff < 0 ? 'Shortage' : diff > 0 ? 'Over' : 'Normal';
            }
        }
    }
</script>
</body>
</html>
