<%@ Page Language="C#" AutoEventWireup="true"
    CodeFile="Consumption1.aspx.cs"
    Inherits="Pos" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Consumption Entry &mdash; Lahore Gymkhana</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;0,9..40,600;1,9..40,400&display=swap" rel="stylesheet"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <style>
        /* ═══════════════════════════════════════════════
           DESIGN TOKENS
        ═══════════════════════════════════════════════ */
        :root {
            --ink:        #0A0E1A;
            --ink-2:      #2D3448;
            --ink-3:      #64748B;
            --ink-4:      #94A3B8;

            --canvas:     #F1F4FA;
            --surface:    #FFFFFF;
            --surface-2:  #F8FAFD;
            --surface-3:  #EEF2F8;

            --line:       #E2E8F4;
            --line-2:     #CBD5E8;

            --blue:       #1E40AF;
            --blue-mid:   #2563EB;
            --blue-soft:  #3B82F6;
            --blue-light: #EFF6FF;
            --blue-pale:  #F5F8FF;

            --emerald:    #047857;
            --emerald-bg: #ECFDF5;
            --emerald-b:  #6EE7B7;

            --amber:      #92400E;
            --amber-bg:   #FFFBEB;
            --amber-b:    #FCD34D;

            --rose:       #9F1239;
            --rose-bg:    #FFF1F2;
            --rose-b:     #FDA4AF;

            --orange:     #9A3412;
            --orange-bg:  #FFF7ED;
            --orange-b:   #FDBA74;

            --violet:     #5B21B6;
            --violet-bg:  #F5F3FF;
            --violet-b:   #C4B5FD;

            --slate:      #475569;
            --slate-bg:   #F8FAFC;
            --slate-b:    #CBD5E8;

            --sh-xs: 0 1px 3px rgba(10,14,26,.05);
            --sh-sm: 0 2px 8px rgba(10,14,26,.07), 0 1px 2px rgba(10,14,26,.04);
            --sh-md: 0 4px 16px rgba(10,14,26,.09), 0 2px 4px rgba(10,14,26,.04);
            --sh-lg: 0 12px 40px rgba(10,14,26,.12), 0 4px 8px rgba(10,14,26,.05);
            --sh-blue: 0 4px 16px rgba(37,99,235,.22);

            --r-xs:   4px;
            --r-sm:   8px;
            --r:      12px;
            --r-lg:   18px;
            --r-xl:   24px;
            --r-full: 9999px;

            --t-fast: .12s ease;
            --t:      .2s ease;
            --t-slow: .35s ease;
        }

        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }
        html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }

        body {
            font-family: 'DM Sans', system-ui, sans-serif;
            background: var(--canvas);
            color: var(--ink);
            font-size: 13.5px;
            line-height: 1.55;
            min-height: 100vh;
        }

        ::-webkit-scrollbar { width:5px; height:5px; }
        ::-webkit-scrollbar-track { background:transparent; }
        ::-webkit-scrollbar-thumb { background:var(--line-2); border-radius:5px; }
        ::-webkit-scrollbar-thumb:hover { background:var(--blue-mid); }

        /* ═══════════════════════════════════════════════
           LAYOUT
        ═══════════════════════════════════════════════ */
        .pg { max-width:1600px; margin:0 auto; padding:20px 24px 60px; }

        /* ═══════════════════════════════════════════════
           TOPBAR
        ═══════════════════════════════════════════════ */
        .topbar {
            display:flex; align-items:center; justify-content:space-between;
            background:var(--ink); padding:0 22px; height:56px;
            border-radius:var(--r-lg); margin-bottom:16px;
            box-shadow:var(--sh-lg); position:relative; overflow:hidden;
        }
        .topbar::before {
            content:''; position:absolute; inset:0;
            background:linear-gradient(110deg,rgba(37,99,235,.28) 0%,transparent 55%);
            pointer-events:none;
        }
        .topbar::after {
            content:''; position:absolute; top:0; left:0; right:0;
            height:1px; background:linear-gradient(90deg,rgba(255,255,255,.12),transparent);
        }
        .topbar-brand { display:flex; align-items:center; gap:11px; position:relative; }
        .tb-icon {
            width:34px; height:34px;
            background:linear-gradient(135deg,#2563EB,#60A5FA);
            border-radius:9px; display:flex; align-items:center; justify-content:center;
            font-size:14px; color:#fff; box-shadow:0 3px 10px rgba(37,99,235,.4);
            flex-shrink:0;
        }
        .tb-title {
            color:#fff; font-family:'Syne',sans-serif;
            font-size:.9rem; font-weight:700; letter-spacing:-.2px;
        }
        .topbar-right { display:flex; align-items:center; gap:8px; position:relative; }
        .dept-badge {
            display:inline-flex; align-items:center; gap:6px;
            background:rgba(255,255,255,.1); color:rgba(255,255,255,.85);
            padding:5px 13px; border-radius:var(--r-full);
            font-size:.72rem; font-weight:600;
            border:1px solid rgba(255,255,255,.15); backdrop-filter:blur(8px);
        }

        /* ═══════════════════════════════════════════════
           WORKFLOW STRIP
        ═══════════════════════════════════════════════ */
        .workflow-strip {
            display:flex; align-items:center; gap:0;
            background:var(--surface); border:1px solid var(--line);
            border-radius:var(--r-full); padding:5px; margin-bottom:16px;
            box-shadow:var(--sh-xs); overflow:hidden;
        }
        .wf-step {
            display:flex; align-items:center; gap:7px;
            padding:6px 16px; border-radius:var(--r-full);
            font-size:.72rem; font-weight:600; color:var(--ink-4);
            transition:all var(--t); white-space:nowrap; cursor:default;
        }
        .wf-step .wf-num {
            width:20px; height:20px; border-radius:50%;
            background:var(--surface-3); border:1.5px solid var(--line-2);
            display:flex; align-items:center; justify-content:center;
            font-size:9px; font-weight:800; flex-shrink:0;
            font-family:'Syne',sans-serif;
        }
        .wf-step.done { color:var(--emerald); }
        .wf-step.done .wf-num { background:var(--emerald-bg); border-color:var(--emerald-b); color:var(--emerald); }
        .wf-step.active { color:var(--ink); background:var(--blue-light); }
        .wf-step.active .wf-num { background:var(--blue-mid); border-color:var(--blue-mid); color:#fff; }
        .wf-sep { color:var(--line-2); font-size:10px; padding:0 2px; }

        /* ═══════════════════════════════════════════════
           ALERT
        ═══════════════════════════════════════════════ */
        .alert-box {
            border-radius:var(--r); padding:11px 16px; margin-bottom:14px;
            display:flex; align-items:center; gap:10px;
            font-size:.8rem; font-weight:500; border-left:3px solid transparent;
            animation:slideIn .2s ease;
        }
        @keyframes slideIn { from{opacity:0;transform:translateY(-6px)} to{opacity:1;transform:none} }
        .alert-box i { font-size:14px; flex-shrink:0; }
        .atxt { font-weight:600; }
        .alert-success { background:var(--emerald-bg); border-color:var(--emerald); color:#064E3B; }
        .alert-error   { background:var(--rose-bg);    border-color:var(--rose);    color:var(--rose); }
        .alert-warning { background:var(--amber-bg);   border-color:var(--amber);   color:var(--amber); }
        .alert-info    { background:var(--blue-light);  border-color:var(--blue);    color:var(--blue); }

        /* ═══════════════════════════════════════════════
           CARD
        ═══════════════════════════════════════════════ */
        .card {
            background:var(--surface); border-radius:var(--r-lg);
            box-shadow:var(--sh-sm); border:1px solid var(--line);
            margin-bottom:16px; overflow:hidden;
        }
        .card-head {
            padding:12px 18px; border-bottom:1px solid var(--line);
            display:flex; justify-content:space-between; align-items:center;
            background:linear-gradient(to right,var(--surface-2),var(--surface));
            min-height:48px;
        }
        .card-head h3 {
            font-size:.8rem; font-weight:700; color:var(--ink);
            display:flex; align-items:center; gap:8px; margin:0;
            font-family:'Syne',sans-serif;
        }
        .card-head h3 i { color:var(--blue-soft); font-size:12px; }
        .card-body { padding:16px 18px; }

        /* ═══════════════════════════════════════════════
           LOAD ROW
        ═══════════════════════════════════════════════ */
        .load-row { display:flex; align-items:center; gap:10px; flex-wrap:wrap; }

        /* ═══════════════════════════════════════════════
           MAIN LAYOUT — FIX: ops-right now has proper CSS
        ═══════════════════════════════════════════════ */
        .ops-layout {
            display:grid;
            grid-template-columns:340px 1fr;
            gap:16px;
            align-items:start;
        }
        .ops-left {
            display:flex;
            flex-direction:column;
            gap:16px;
            min-width:0; /* prevent overflow */
        }
        /* FIX: ops-right was missing CSS entirely */
        .ops-right {
            min-width:0;
            display:flex;
            flex-direction:column;
        }
        .ops-right .card {
            margin-bottom:0;
            display:flex;
            flex-direction:column;
        }

        /* ═══════════════════════════════════════════════
           COLLAPSIBLE REFERENCE PANEL
        ═══════════════════════════════════════════════ */
        .ref-panel { margin-bottom:0; }
        .ref-panel .card-head { cursor:pointer; user-select:none; }
        .ref-panel .card-head:hover { background:var(--blue-pale); }
        .ref-panel-body { overflow:hidden; transition:max-height .3s ease; }
        .ref-panel.collapsed .ref-panel-body { max-height:0 !important; overflow:hidden; }
        .collapse-icon { transition:transform .25s ease; color:var(--ink-3); font-size:11px; flex-shrink:0; }
        .ref-panel.collapsed .collapse-icon { transform:rotate(-90deg); }

        /* ═══════════════════════════════════════════════
           INPUTS
        ═══════════════════════════════════════════════ */
        .ccid-input {
            height:38px; border:1.5px solid var(--line-2); border-radius:var(--r-sm);
            padding:0 13px; font-size:13px; font-weight:500;
            font-family:'JetBrains Mono',monospace; color:var(--ink); background:var(--surface);
            width:220px; transition:border-color var(--t), box-shadow var(--t);
        }
        .ccid-input:focus { outline:none; border-color:var(--blue-mid); box-shadow:0 0 0 3px rgba(37,99,235,.1); }

        .qty-input {
            width:96px; height:30px;
            border:1.5px solid #BFDBFE;
            border-radius:var(--r-sm); padding:0 8px; text-align:right;
            font-family:'JetBrains Mono',monospace; font-size:11.5px; font-weight:600; color:var(--ink);
            background:var(--blue-pale); transition:border-color var(--t), box-shadow var(--t), background var(--t);
        }
        .qty-input:focus {
            outline:none; border-color:var(--blue-mid);
            box-shadow:0 0 0 3px rgba(37,99,235,.12);
            background:var(--surface);
        }
        .qty-input.modified { border-color:var(--amber); background:var(--amber-bg); }

        /* ═══════════════════════════════════════════════
           BUTTONS
        ═══════════════════════════════════════════════ */
        .wbtn {
            display:inline-flex; align-items:center; justify-content:center; gap:7px;
            height:38px; padding:0 18px; border:none; border-radius:var(--r-sm);
            font-size:12px; font-weight:700; font-family:'Syne',sans-serif;
            cursor:pointer; transition:all var(--t); white-space:nowrap; letter-spacing:-.1px;
        }
        .wbtn-primary { background:var(--blue-mid); color:#fff; box-shadow:var(--sh-blue); }
        .wbtn-primary:hover { background:#1D4ED8; transform:translateY(-1px); box-shadow:0 6px 20px rgba(37,99,235,.35); }
        .wbtn-ghost { background:var(--surface); color:var(--ink-2); border:1.5px solid var(--line-2); }
        .wbtn-ghost:hover { background:var(--blue-light); border-color:var(--blue-mid); color:var(--blue-mid); }
        .wbtn-success {
            background:linear-gradient(135deg,#047857,#059669); color:#fff;
            box-shadow:0 4px 14px rgba(5,150,105,.28);
        }
        .wbtn-success:hover { transform:translateY(-1px); box-shadow:0 8px 22px rgba(5,150,105,.38); }
        .wbtn-success:disabled { opacity:.5; cursor:not-allowed; transform:none; }
        .wbtn-sm { height:30px; padding:0 13px; font-size:11.5px; }
        .wbtn-xs { height:26px; padding:0 10px; font-size:11px; }

        /* ═══════════════════════════════════════════════
           BADGE / CHIP
        ═══════════════════════════════════════════════ */
        .chip {
            display:inline-flex; align-items:center; gap:5px;
            padding:3px 10px; border-radius:var(--r-full);
            font-size:10.5px; font-weight:700; letter-spacing:.1px;
        }
        .chip-blue   { background:var(--blue-light); color:var(--blue);   border:1px solid #BFDBFE; }
        .chip-violet { background:var(--violet-bg);  color:var(--violet); border:1px solid var(--violet-b); }
        .chip-slate  { background:var(--slate-bg);   color:var(--slate);  border:1px solid var(--slate-b); }

        .sel-chip {
            display:inline-flex; align-items:center; gap:6px;
            background:var(--blue-light); color:var(--blue);
            padding:4px 12px; border-radius:var(--r-full);
            font-size:.72rem; font-weight:700; border:1px solid #BFDBFE;
        }
        .sel-chip-label { color:var(--ink-3); font-weight:500; }

        /* ═══════════════════════════════════════════════
           TABLE SHELL — FIX: consistent overflow and border
        ═══════════════════════════════════════════════ */
        .tbl-outer {
            overflow:auto;
            border-top:1px solid var(--line);
        }
        .tbl-outer::-webkit-scrollbar { width:4px; height:4px; }
        .tbl-outer::-webkit-scrollbar-track { background:var(--surface-2); }
        .tbl-outer::-webkit-scrollbar-thumb { background:var(--line-2); border-radius:4px; }

        /* ═══════════════════════════════════════════════
           BASE TABLE — FIX: improved row density & alignment
        ═══════════════════════════════════════════════ */
        .cc-table { width:100%; border-collapse:collapse; font-size:12.5px; }
        .cc-table thead { position:sticky; top:0; z-index:3; }
        .cc-table th {
            padding:8px 14px; font-size:.59rem; font-weight:700; color:var(--ink-3);
            text-transform:uppercase; letter-spacing:.7px;
            background:var(--surface-2); border-bottom:2px solid var(--line);
            white-space:nowrap; font-family:'Syne',sans-serif;
        }
        .cc-table td {
            padding:8px 14px; border-bottom:1px solid var(--line);
            vertical-align:middle; color:var(--ink-2);
        }
        .cc-table tbody tr:last-child td { border-bottom:none; }
        .cc-table tbody tr:hover td { background:var(--blue-pale); }
        .cc-table .mono { font-family:'JetBrains Mono',monospace; font-size:11.5px; font-weight:500; }
        .cc-table .center { text-align:center; }
        .cc-table .right  { text-align:right; }
        .cc-table .name-cell { font-weight:600; color:var(--ink); white-space:nowrap; }
        .cc-table .code-cell { color:var(--ink-4); font-family:'JetBrains Mono',monospace; font-size:10.5px; white-space:nowrap; }

        /* Consumption entry table */
        .cons-table { table-layout:fixed; width:100%; }
        .cons-table col.c-name { width:22%; }
        .cons-table col.c-code { width:72px; }
        .cons-table col.c-unit { width:56px; }
        .cons-table col.c-exp  { width:110px; }
        .cons-table col.c-stk  { width:96px; }
        .cons-table col.c-act  { width:118px; }
        .cons-table col.c-var  { width:106px; }
        .cons-table col.c-sts  { width:140px; }

        /* ═══════════════════════════════════════════════
           STOCK BADGES
        ═══════════════════════════════════════════════ */
        .stock-ok   { font-family:'JetBrains Mono',monospace; font-size:11px; font-weight:500; color:var(--ink-3); }
        .stock-low  { font-family:'JetBrains Mono',monospace; font-size:11px; font-weight:600; color:var(--amber); }
        .stock-zero { font-family:'JetBrains Mono',monospace; font-size:11px; font-weight:600; color:var(--rose); }

        /* ═══════════════════════════════════════════════
           VARIANCE BADGES
        ═══════════════════════════════════════════════ */
        .var-save {
            display:inline-block; padding:2px 8px; border-radius:var(--r-full);
            font-family:'JetBrains Mono',monospace; font-size:10.5px; font-weight:700;
            background:var(--emerald-bg); color:var(--emerald); border:1px solid var(--emerald-b);
        }
        .var-over {
            display:inline-block; padding:2px 8px; border-radius:var(--r-full);
            font-family:'JetBrains Mono',monospace; font-size:10.5px; font-weight:700;
            background:var(--rose-bg); color:var(--rose); border:1px solid var(--rose-b);
        }
        .var-zero {
            display:inline-block; padding:2px 8px; border-radius:var(--r-full);
            font-family:'JetBrains Mono',monospace; font-size:10.5px; font-weight:500;
            background:var(--surface-3); color:var(--ink-4); border:1px solid var(--line);
        }

        /* ═══════════════════════════════════════════════
           REMARKS SELECT
        ═══════════════════════════════════════════════ */
        .remarks-sel {
            height:28px; border:1.5px solid var(--line-2); border-radius:var(--r-full);
            padding:0 24px 0 10px; font-size:11px; font-weight:600;
            font-family:'DM Sans',sans-serif; background:var(--surface); color:var(--ink);
            width:100%; max-width:136px; cursor:pointer; transition:all var(--t);
            appearance:none; -webkit-appearance:none;
            background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6' viewBox='0 0 10 6'%3E%3Cpath d='M1 1l4 4 4-4' stroke='%2364748B' stroke-width='1.5' fill='none' stroke-linecap='round'/%3E%3C/svg%3E");
            background-repeat:no-repeat; background-position:right 8px center;
        }
        .remarks-sel:focus { outline:none; border-color:var(--blue-mid); }
        .remarks-sel.sel-normal   { border-color:var(--emerald-b); color:var(--emerald);  background-color:var(--emerald-bg); }
        .remarks-sel.sel-over     { border-color:var(--orange-b);  color:var(--orange);   background-color:var(--orange-bg); }
        .remarks-sel.sel-shortage { border-color:var(--rose-b);    color:var(--rose);     background-color:var(--rose-bg); }
        .remarks-sel.sel-pending  { border-color:var(--amber-b);   color:var(--amber);    background-color:var(--amber-bg); }
        .remarks-sel.sel-other    { border-color:var(--slate-b);   color:var(--slate);    background-color:var(--slate-bg); }

        /* ═══════════════════════════════════════════════
           CHECKBOX
        ═══════════════════════════════════════════════ */
        input[type="checkbox"] { width:14px; height:14px; accent-color:var(--blue-mid); cursor:pointer; }

        /* ═══════════════════════════════════════════════
           EMPTY STATE
        ═══════════════════════════════════════════════ */
        .empty-state { text-align:center; padding:40px 24px; background:var(--surface-2); }
        .empty-state i { font-size:30px; color:var(--line-2); margin-bottom:12px; display:block; }
        .empty-state h4 { color:var(--ink-3); margin-bottom:4px; font-size:.82rem; font-weight:700; font-family:'Syne',sans-serif; }
        .empty-state p  { color:var(--ink-4); font-size:.75rem; }

        /* ═══════════════════════════════════════════════
           STATS ROW — FIX: proper padding + alignment
        ═══════════════════════════════════════════════ */
        .stats-row {
            display:flex; align-items:center; gap:8px; flex-wrap:wrap;
            padding:10px 18px; background:var(--surface-2); border-bottom:1px solid var(--line);
        }
        .stat-chip {
            display:inline-flex; align-items:center; gap:5px;
            padding:4px 11px; border-radius:var(--r-full);
            font-size:.7rem; font-weight:700;
        }
        .stat-total   { background:var(--blue-light); color:var(--blue);    border:1px solid #BFDBFE; }
        .stat-pending { background:var(--slate-bg);   color:var(--slate);   border:1px solid var(--slate-b); }
        .stat-normal  { background:var(--emerald-bg); color:var(--emerald); border:1px solid var(--emerald-b); }
        .stat-over    { background:var(--orange-bg);  color:var(--orange);  border:1px solid var(--orange-b); }
        .stat-under   { background:var(--amber-bg);   color:var(--amber);   border:1px solid var(--amber-b); }
        .stat-missing { background:var(--rose-bg);    color:var(--rose);    border:1px solid var(--rose-b); }

        /* ═══════════════════════════════════════════════
           ITEMS TOOLBAR — FIX: even padding
        ═══════════════════════════════════════════════ */
        .items-toolbar {
            display:flex; justify-content:space-between; align-items:center;
            padding:10px 14px; flex-wrap:wrap; gap:8px;
            border-top:1px solid var(--line); background:var(--surface-2);
        }

        /* ═══════════════════════════════════════════════
           SAVE FOOTER — FIX: no-wrap, consistent height
        ═══════════════════════════════════════════════ */
        .save-footer {
            display:flex; justify-content:space-between; align-items:center;
            padding:13px 18px; background:var(--surface);
            border-top:2px solid var(--line); flex-wrap:wrap; gap:10px;
            min-height:60px;
        }
        .save-note {
            font-size:.72rem; color:var(--ink-3);
            display:flex; align-items:center; gap:6px; white-space:nowrap;
        }
        .save-note i { color:var(--blue-soft); }
        .save-actions { display:flex; align-items:center; gap:10px; }

        /* Save state indicator */
        .save-state {
            display:inline-flex; align-items:center; gap:6px;
            font-size:.72rem; font-weight:600; padding:5px 12px;
            border-radius:var(--r-full);
        }
        .save-state.unsaved { color:var(--amber);   background:var(--amber-bg);   border:1px solid var(--amber-b); }
        .save-state.saved   { color:var(--emerald); background:var(--emerald-bg); border:1px solid var(--emerald-b); }
        .save-state.draft   { color:var(--slate);   background:var(--slate-bg);   border:1px solid var(--slate-b); }

        /* ═══════════════════════════════════════════════
           ROW MODIFIED INDICATOR
        ═══════════════════════════════════════════════ */
        tr.row-modified td:first-child { border-left:3px solid var(--amber); }
        tr.row-saved    td:first-child { border-left:3px solid var(--emerald); }

        /* ═══════════════════════════════════════════════
           COL HINT TOOLTIP — FIX: z-index above sticky thead
        ═══════════════════════════════════════════════ */
        .col-hint {
            display:inline-flex; align-items:center; gap:4px; cursor:help;
            position:relative;
        }
        .col-hint i { color:var(--blue-soft); font-size:9px; }
        .col-hint-tip {
            display:none; position:absolute; bottom:calc(100% + 8px); left:50%; transform:translateX(-50%);
            background:var(--ink); color:#fff; font-size:.68rem; white-space:nowrap;
            padding:6px 10px; border-radius:var(--r-sm); z-index:100; pointer-events:none;
            font-weight:500; letter-spacing:0; box-shadow:var(--sh-md);
        }
        .col-hint-tip::after {
            content:''; position:absolute; top:100%; left:50%; transform:translateX(-50%);
            border:5px solid transparent; border-top-color:var(--ink);
        }
        .col-hint:hover .col-hint-tip { display:block; }

        /* ═══════════════════════════════════════════════
           SECTION LABEL
        ═══════════════════════════════════════════════ */
        .sec-lbl {
            font-size:.62rem; font-weight:700; color:var(--ink-3);
            text-transform:uppercase; letter-spacing:.65px;
            display:flex; align-items:center; gap:5px;
            font-family:'Syne',sans-serif;
        }

        /* ═══════════════════════════════════════════════
           CARD HEAD FLEX — prevent stats overflow
        ═══════════════════════════════════════════════ */
        .card-head-right {
            display:flex; align-items:center; gap:8px; flex-wrap:wrap;
            justify-content:flex-end; flex:1; min-width:0; padding-left:12px;
        }

        /* ═══════════════════════════════════════════════
           RESPONSIVE
        ═══════════════════════════════════════════════ */
        @media(max-width:1100px) {
            .ops-layout { grid-template-columns:1fr; }
            .ops-left { flex-direction:row; flex-wrap:wrap; }
            .ops-left > * { flex:1; min-width:280px; }
        }
        @media(max-width:640px) {
            .workflow-strip { display:none; }
            .topbar { height:auto; padding:12px 16px; flex-direction:column; gap:8px; border-radius:var(--r); }
            .save-note { white-space:normal; }
            .pg { padding:12px 12px 40px; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="pg">

    <!-- ══ TOPBAR ══ -->
    <div class="topbar">
        <div class="topbar-brand">
            <div class="tb-icon"><i class="fas fa-bowl-food"></i></div>
            <div>
                <div class="tb-title">Ingredient Consumption Entry</div>
            </div>
        </div>
        <div class="topbar-right">
            <asp:Label ID="lblDeptInfo" runat="server" Visible="false"></asp:Label>
        </div>
    </div>

    <!-- ══ WORKFLOW STRIP ══ -->
    <div class="workflow-strip" id="workflowStrip">
        <div class="wf-step done" id="wfStep1">
            <div class="wf-num"><i class="fas fa-check" style="font-size:7px;"></i></div>
            <span>Counter Close Loaded</span>
        </div>
        <span class="wf-sep"><i class="fas fa-chevron-right"></i></span>
        <div class="wf-step" id="wfStep2">
            <div class="wf-num">2</div>
            <span>Select Items</span>
        </div>
        <span class="wf-sep"><i class="fas fa-chevron-right"></i></span>
        <div class="wf-step" id="wfStep3">
            <div class="wf-num">3</div>
            <span>Review &amp; Adjust Quantities</span>
        </div>
        <span class="wf-sep"><i class="fas fa-chevron-right"></i></span>
        <div class="wf-step" id="wfStep4">
            <div class="wf-num">4</div>
            <span>Save</span>
        </div>
    </div>

    <!-- ══ ALERT ══ -->
    <asp:Panel ID="pnlAlertMain" runat="server" Visible="false">
        <div id="divAlertMain" runat="server" class="alert-box">
            <asp:Label ID="lblAlertMain" runat="server" />
        </div>
    </asp:Panel>

    <!-- ══ LOAD CARD ══ -->
    <div class="card">
        <div class="card-head">
            <h3><i class="fas fa-hashtag"></i> Counter Close Reference</h3>
            <asp:Label ID="lblLoadedBadge" runat="server" Visible="false" CssClass="chip chip-slate"></asp:Label>
        </div>
        <div class="card-body">
            <div class="load-row">
                <asp:TextBox ID="txtCounterCloseId" runat="server"
                    CssClass="ccid-input"
                    placeholder="Counter Close ID" />
                <asp:Button ID="btnLoad" runat="server"
                    Text="Load"
                    CssClass="wbtn wbtn-primary"
                    OnClick="btnLoad_Click" />
            </div>
        </div>
    </div>

    <!-- ══ OPERATIONAL LAYOUT ══ -->
    <div class="ops-layout">

        <!-- LEFT: Reference panels -->
        <div class="ops-left">

            <!-- Bill Items panel -->
            <div class="card ref-panel" id="panelBillItems">
                <div class="card-head" onclick="togglePanel('panelBillItems')" title="Click to collapse">
                    <h3><i class="fas fa-receipt"></i> Bill Items</h3>
                    <div style="display:flex;align-items:center;gap:8px;">
                        <span class="sel-chip" id="selChip" style="display:none;">
                            <span class="sel-chip-label">Selected:</span>
                            <asp:Label ID="lblSelectedCount" runat="server" Text="0"></asp:Label>
                        </span>
                        <i class="fas fa-chevron-down collapse-icon"></i>
                    </div>
                </div>
                <div class="ref-panel-body" style="max-height:400px;">
                    <div class="tbl-outer" style="max-height:320px;border-top:none;">
                        <asp:GridView ID="gvItems" runat="server"
                            AutoGenerateColumns="False"
                            CssClass="cc-table"
                            GridLines="None">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="chkAll" runat="server"
                                            AutoPostBack="true"
                                            OnCheckedChanged="chkAll_CheckedChanged" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="chkSelect" runat="server" AutoPostBack="false" />
                                    </ItemTemplate>
                                    <HeaderStyle CssClass="center" Width="34px" />
                                    <ItemStyle CssClass="center" Width="34px" />
                                </asp:TemplateField>

                                <%-- FIX: TemplateField so we can add hfItemName HiddenField --%>
                                <asp:TemplateField HeaderText="Item">
                                    <ItemTemplate>
                                        <span class="name-cell"><%# Eval("Name") %></span>
                                        <%-- FIX: Hidden field carries item name reliably on postback --%>
                                        <asp:HiddenField ID="hfItemName" runat="server" Value='<%# Eval("Name") %>' />
                                    </ItemTemplate>
                                    <ItemStyle CssClass="name-cell" />
                                </asp:TemplateField>

                                <asp:BoundField DataField="Quantity" HeaderText="Qty Sold"
                                    DataFormatString="{0:N2}"
                                    ItemStyle-HorizontalAlign="Right"
                                    HeaderStyle-HorizontalAlign="Right"
                                    ItemStyle-CssClass="mono right" />
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="empty-state">
                                    <i class="fas fa-box-open"></i>
                                    <h4>No Items</h4>
                                    <p>Load a Counter Close ID above.</p>
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                    <div class="items-toolbar">
                        <span style="font-size:.7rem;color:var(--ink-3);">Select items to show ingredients</span>
                        <asp:Button ID="btnShowIngredients" runat="server"
                            Text="Show Ingredients"
                            CssClass="wbtn wbtn-ghost wbtn-sm"
                            OnClick="btnShowIngredients_Click" />
                    </div>
                </div>
            </div>

            <!-- All Ingredients reference panel -->
            <asp:Panel ID="pnlAllIngredients" runat="server" Visible="false">
                <div class="card ref-panel" id="panelIngredients">
                    <div class="card-head" onclick="togglePanel('panelIngredients')" title="Click to collapse">
                        <h3><i class="fas fa-cubes"></i>
                            Ingredients
                            <asp:Label ID="lblIngCount" runat="server" style="color:var(--ink-3);font-weight:500;"></asp:Label>
                        </h3>
                        <div style="display:flex;align-items:center;gap:6px;">
                            <span class="sec-lbl" style="color:var(--ink-4);font-size:.58rem;">Reference only</span>
                            <i class="fas fa-chevron-down collapse-icon"></i>
                        </div>
                    </div>
                    <div class="ref-panel-body" style="max-height:380px;">
                        <div class="tbl-outer" style="max-height:340px;border-top:none;">
                            <asp:GridView ID="gvAllIngredients" runat="server"
                                AutoGenerateColumns="false"
                                CssClass="cc-table"
                                GridLines="None">
                                <Columns>
                                    <asp:BoundField DataField="IngredientName" HeaderText="Ingredient" ItemStyle-CssClass="name-cell" />
                                    <asp:BoundField DataField="Unit" HeaderText="Unit"
                                        ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                    <asp:BoundField DataField="TotalIngredientQty" HeaderText="Expected"
                                        DataFormatString="{0:N3}"
                                        ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right"
                                        ItemStyle-CssClass="mono right" />
                                    <asp:TemplateField HeaderText="Stock" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right">
                                        <ItemTemplate>
                                            <%# GetStockBadge(Eval("CurrentStock"), Eval("TotalIngredientQty")) %>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <EmptyDataTemplate>
                                    <div class="empty-state">
                                        <i class="fas fa-carrot"></i>
                                        <h4>No ingredients</h4>
                                        <p>Check that MenuItems.RecipeId is linked.</p>
                                    </div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </asp:Panel>

        </div><!-- /ops-left -->

        <!-- RIGHT: Primary consumption entry -->
        <div class="ops-right">
            <div class="card">
                <div class="card-head">
                    <h3><i class="fas fa-pen-to-square"></i> Consumption Entry</h3>
                    <div class="card-head-right">
                        <!-- Save state indicator -->
                        <span class="save-state draft" id="saveStateIndicator">
                            <i class="fas fa-circle" style="font-size:6px;"></i> Draft
                        </span>
                        <!-- Stats chips -->
                        <asp:Panel ID="pnlSelectionStats" runat="server" Visible="false">
                            <div style="display:flex;gap:6px;flex-wrap:wrap;" id="statsRow">
                                <span class="stat-chip stat-total">
                                    <asp:Label ID="lblStatsTotalIng" runat="server" Text="0"></asp:Label>&nbsp;total
                                </span>
                                <span class="stat-chip stat-pending" id="statPendingChip">
                                    <asp:Label ID="lblStatsPending" runat="server" Text="0"></asp:Label>&nbsp;pending
                                </span>
                                <span class="stat-chip stat-normal" id="statNormalChip" style="display:none;">
                                    <asp:Label ID="lblStatsNormal" runat="server" Text="0"></asp:Label>&nbsp;normal
                                </span>
                                <span class="stat-chip stat-over" id="statOverChip" style="display:none;">
                                    <asp:Label ID="lblStatsOver" runat="server" Text="0"></asp:Label>&nbsp;over
                                </span>
                                <span class="stat-chip stat-under" id="statUnderChip" style="display:none;">
                                    <asp:Label ID="lblStatsUnder" runat="server" Text="0"></asp:Label>&nbsp;under
                                </span>
                                <span class="stat-chip stat-missing" id="statMissingChip" style="display:none;">
                                    <asp:Label ID="lblStatsMissing" runat="server" Text="0"></asp:Label>&nbsp;missing
                                </span>
                            </div>
                        </asp:Panel>
                    </div>
                </div>

                <div class="tbl-outer" style="border-top:none;max-height:520px;">
                    <asp:GridView ID="gvSelectedIngredients" runat="server"
                        AutoGenerateColumns="false"
                        CssClass="cc-table cons-table"
                        GridLines="None"
                        Width="100%"
                        OnRowDataBound="gvSelectedIngredients_RowDataBound">
                        <Columns>

                            <%-- Col 0: Ingredient Name + FIX hfIngredientName HiddenField --%>
                            <asp:TemplateField HeaderText="Ingredient">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                                <ItemTemplate>
                                    <span class="name-cell"><%# Eval("IngredientName") %></span>
                                    <%-- FIX: This hidden field is what btnSave_Click reads --%>
                                    <asp:HiddenField ID="hfIngredientName" runat="server" Value='<%# Eval("IngredientName") %>' />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Col 1: Item Code --%>
                            <asp:TemplateField HeaderText="Code">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                                <ItemTemplate>
                                    <span class="code-cell"><%# Eval("ItemCode") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Col 2: Unit --%>
                            <asp:TemplateField HeaderText="Unit">
                                <HeaderStyle HorizontalAlign="Center" />
                                <ItemStyle HorizontalAlign="Center" />
                                <ItemTemplate><%# Eval("Unit") %></ItemTemplate>
                            </asp:TemplateField>

                            <%-- Col 3: Expected Qty + FIX hfExpectedQty for server reads --%>
                            <asp:TemplateField HeaderText="Expected">
                                <HeaderStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" />
                                <ItemTemplate>
                                    <span class="mono"><%# FormatQty(Eval("TotalIngredientQty"), Eval("Unit")) %></span>
                                    <%-- FIX: Raw decimal value for server-side calculation --%>
                                    <asp:HiddenField ID="hfExpectedQty" runat="server" Value='<%# Eval("TotalIngredientQty") %>' />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Col 4: Stock (muted reference) --%>
                            <asp:TemplateField HeaderText="Stock">
                                <HeaderStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" />
                                <ItemTemplate>
                                    <%# GetStockBadge(Eval("CurrentStock"), Eval("TotalIngredientQty")) %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Col 5: Actual Used (highlighted editable) --%>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <span style="color:var(--blue-mid);">
                                        <i class="fas fa-pencil" style="font-size:9px;"></i>
                                        Actual Used
                                    </span>
                                </HeaderTemplate>
                                <HeaderStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" />
                                <ItemTemplate>
                                    <asp:TextBox ID="txtActualQty" runat="server"
                                        Text='<%# FormatQty(Eval("ActualQty"), Eval("Unit")) %>'
                                        CssClass="qty-input"
                                        AutoPostBack="true"
                                        OnTextChanged="txtActualQty_TextChanged" />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Col 6: Variance with tooltip --%>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <span class="col-hint">
                                        Variance
                                        <i class="fas fa-circle-info"></i>
                                        <span class="col-hint-tip">Actual &minus; Expected. +ve = Saving, &minus;ve = Over Usage</span>
                                    </span>
                                </HeaderTemplate>
                                <HeaderStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" />
                                <ItemTemplate>
                                    <asp:Label ID="lblVariance" runat="server" Text="0.000" CssClass="var-zero" />
                                    <asp:HiddenField ID="hfVariance" runat="server" Value="0" />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Col 7: Status / Remarks dropdown --%>
                            <asp:TemplateField HeaderText="Status / Remarks">
                                <HeaderStyle HorizontalAlign="Center" />
                                <ItemStyle HorizontalAlign="Center" />
                                <ItemTemplate>
                                    <asp:DropDownList ID="ddlRemarks" runat="server"
                                        CssClass="remarks-sel"
                                        onchange="onRemarksChange(this)">
                                        <asp:ListItem Text="Normal"        Value="Normal" />
                                        <asp:ListItem Text="Over Usage"    Value="Over Usage" />
                                        <asp:ListItem Text="Under Usage"   Value="Under Usage" />
                                        <asp:ListItem Text="Shortage"      Value="Shortage" />
                                        <asp:ListItem Text="Missing Entry" Value="Missing Entry" />
                                        <asp:ListItem Text="Saving"        Value="Saving" />
                                        <asp:ListItem Text="Over Cooking"  Value="Over Cooking" />
                                        <asp:ListItem Text="Wastage"       Value="Wastage" />
                                        <asp:ListItem Text="Damage"        Value="Damage" />
                                        <asp:ListItem Text="Theft"         Value="Theft" />
                                        <asp:ListItem Text="Quality Issue" Value="Quality Issue" />
                                    </asp:DropDownList>
                                    <%-- Keep ItemCode and Unit for save --%>
                                    <asp:HiddenField ID="hfItemCode" runat="server" Value='<%# Eval("ItemCode") %>' />
                                    <asp:HiddenField ID="hfUnit"     runat="server" Value='<%# Eval("Unit") %>' />
                                </ItemTemplate>
                            </asp:TemplateField>

                        </Columns>
                        <EmptyDataTemplate>
                            <div class="empty-state">
                                <i class="fas fa-chart-simple"></i>
                                <h4>No Ingredients to Display</h4>
                                <p>Select items from Bill Items and click <strong>Show Ingredients</strong>.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

                <!-- Save footer -->
                <div class="save-footer">
                    <span class="save-note">
                        <i class="fas fa-info-circle"></i>
                        Actual defaults to Expected. Stock shown for reference only.
                    </span>
                    <div class="save-actions">
                        <span class="save-state unsaved" id="dirtyIndicator" style="display:none;">
                            <i class="fas fa-circle" style="font-size:6px;"></i> Unsaved changes
                        </span>
                        <asp:Button ID="btnSave" runat="server"
                            Text="Save Consumption"
                            CssClass="wbtn wbtn-success"
                            OnClick="btnSave_Click"
                            OnClientClick="return confirmSave();" />
                    </div>
                </div>

            </div><!-- /card -->
        </div><!-- /ops-right -->

    </div><!-- /ops-layout -->

</div><!-- /pg -->
</form>

<script>
    /* ══ WORKFLOW STATE ══ */
    function setWorkflowStep(n) {
        for (var i = 1; i <= 4; i++) {
            var el = document.getElementById('wfStep' + i);
            if (!el) continue;
            el.classList.remove('active', 'done');
            if (i < n) el.classList.add('done');
            else if (i === n) el.classList.add('active');
        }
    }

    /* ══ PANEL COLLAPSE ══ */
    function togglePanel(id) {
        var panel = document.getElementById(id);
        if (!panel) return;
        panel.classList.toggle('collapsed');
    }

    /* ══ REMARKS STYLING ══ */
    function onRemarksChange(sel) {
        styleRemarks(sel);
        markDirty(sel);
        updateClientStats();
    }

    function styleRemarks(sel) {
        sel.className = 'remarks-sel';
        var v = sel.value;
        if (v === 'Normal' || v === 'Saving') sel.classList.add('sel-normal');
        else if (v === 'Over Usage' || v === 'Over Cooking') sel.classList.add('sel-over');
        else if (v === 'Shortage' || v === 'Missing Entry' || v === 'Theft') sel.classList.add('sel-shortage');
        else sel.classList.add('sel-other');
    }

    /* ══ DIRTY STATE ══ */
    var isDirty = false;

    function markDirty(el) {
        isDirty = true;
        var ind = document.getElementById('dirtyIndicator');
        var si = document.getElementById('saveStateIndicator');
        if (ind) ind.style.display = 'inline-flex';
        if (si) { si.className = 'save-state unsaved'; si.innerHTML = '<i class="fas fa-circle" style="font-size:6px;"></i> Unsaved changes'; }
        if (el) {
            var row = el.closest('tr');
            if (row) { row.classList.add('row-modified'); row.classList.remove('row-saved'); }
        }
    }

    function markSaved() {
        isDirty = false;
        var ind = document.getElementById('dirtyIndicator');
        var si = document.getElementById('saveStateIndicator');
        if (ind) ind.style.display = 'none';
        if (si) { si.className = 'save-state saved'; si.innerHTML = '<i class="fas fa-circle-check" style="font-size:8px;"></i> Saved'; }
        document.querySelectorAll('tr.row-modified').forEach(function (r) {
            r.classList.remove('row-modified'); r.classList.add('row-saved');
        });
    }

    /* ══ SELECTED COUNT ══ */
    function updateSelCount() {
        var cbs = document.querySelectorAll('[id*="chkSelect"]');
        var count = 0;
        cbs.forEach(function (cb) { if (cb.checked) count++; });
        var lbl = document.querySelector('[id*="lblSelectedCount"]');
        if (lbl) lbl.textContent = count;
        var chip = document.getElementById('selChip');
        if (chip) chip.style.display = count > 0 ? 'inline-flex' : 'none';
        if (count > 0) setWorkflowStep(2);
    }

    /* ══ CLIENT-SIDE STATS ══ */
    function updateClientStats() {
        var sels = document.querySelectorAll('[id*="ddlRemarks"]');
        var counts = { 'Normal': 0, 'Over Usage': 0, 'Under Usage': 0, 'Missing Entry': 0 };
        sels.forEach(function (sel) {
            var v = sel.value;
            if (counts.hasOwnProperty(v)) counts[v]++;
        });

        var total = sels.length;
        setStatChip('statPendingChip', 'lblStatsPending', 0, false);
        setStatChip('statNormalChip', 'lblStatsNormal', counts['Normal'], counts['Normal'] > 0);
        setStatChip('statOverChip', 'lblStatsOver', counts['Over Usage'], counts['Over Usage'] > 0);
        setStatChip('statUnderChip', 'lblStatsUnder', counts['Under Usage'], counts['Under Usage'] > 0);
        setStatChip('statMissingChip', 'lblStatsMissing', counts['Missing Entry'], counts['Missing Entry'] > 0);

        var totalLbl = document.querySelector('[id*="lblStatsTotalIng"]');
        if (totalLbl) totalLbl.textContent = total;
    }

    function setStatChip(chipId, lblId, val, show) {
        var chip = document.getElementById(chipId);
        var lbl = document.querySelector('[id*="' + lblId + '"]');
        if (lbl) lbl.textContent = val;
        if (chip) chip.style.display = show ? 'inline-flex' : 'none';
    }

    /* ══ VARIANCE UPDATE (client-side, instant) ══ */
    function onActualQtyInput(inp) {
        markDirty(inp);
        setWorkflowStep(3);

        var row = inp.closest('tr');
        if (!row) return;

        // FIX: Read expected from hfExpectedQty hidden field (reliable)
        var hfExp = row.querySelector('[id*="hfExpectedQty"]');
        var expected = hfExp ? (parseFloat(hfExp.value) || 0) : 0;
        var actual = parseFloat(inp.value.replace(/,/g, '')) || 0;
        var variance = actual - expected;

        var varLbl = row.querySelector('[id*="lblVariance"]');
        if (varLbl) {
            if (variance > 0) { varLbl.textContent = '+' + variance.toFixed(3); varLbl.className = 'var-save'; }
            else if (variance < 0) { varLbl.textContent = variance.toFixed(3); varLbl.className = 'var-over'; }
            else { varLbl.textContent = '0.000'; varLbl.className = 'var-zero'; }
        }

        // Auto-update remarks
        var ddl = row.querySelector('[id*="ddlRemarks"]');
        if (ddl) {
            var autoRemark = 'Normal';
            if (actual === 0 && expected > 0) autoRemark = 'Missing Entry';
            else if (actual > expected) autoRemark = 'Over Usage';
            else if (actual < expected) autoRemark = 'Under Usage';
            for (var i = 0; i < ddl.options.length; i++) {
                if (ddl.options[i].value === autoRemark) { ddl.selectedIndex = i; break; }
            }
            styleRemarks(ddl);
        }
        updateClientStats();
    }

    /* ══ SAVE CONFIRMATION ══ */
    function confirmSave() {
        var inputs = document.querySelectorAll('[id*="txtActualQty"]');
        if (inputs.length === 0) { alert('No consumption data to save.'); return false; }
        var blanks = 0;
        inputs.forEach(function (inp) { if (!inp.value.trim()) blanks++; });
        var msg = 'Save all ' + inputs.length + ' consumption record(s)?';
        if (blanks > 0) msg = blanks + ' ingredient(s) have no Actual Qty.\nThey will be saved as 0.\n\n' + msg;
        if (confirm(msg)) { markSaved(); return true; }
        return false;
    }

    /* ══ INIT ══ */
    document.addEventListener('DOMContentLoaded', function () {

        // Style all remarks dropdowns on load
        document.querySelectorAll('.remarks-sel').forEach(styleRemarks);

        // Attach input events to qty fields
        document.querySelectorAll('[id*="txtActualQty"]').forEach(function (inp) {
            inp.addEventListener('input', function () { onActualQtyInput(this); });
        });

        // Selection count
        var gvItemsEl = document.querySelector('[id*="gvItems"]');
        if (gvItemsEl) {
            gvItemsEl.addEventListener('change', function (ev) {
                if (ev.target && ev.target.type === 'checkbox') updateSelCount();
            });
        }

        // Workflow initial step
        var hasIngredients = document.querySelectorAll('[id*="gvSelectedIngredients"] tbody tr').length;
        var hasItems = document.querySelectorAll('[id*="gvItems"] tbody tr').length;

        if (hasIngredients > 0) setWorkflowStep(3);
        else if (hasItems > 0) setWorkflowStep(2);
        else setWorkflowStep(1);

        // Saved state if loaded from existing
        if (hasIngredients > 0) {
            var saveStateLbl = document.querySelector('[id*="lblLoadedBadge"]');
            if (saveStateLbl && saveStateLbl.textContent.indexOf('Previously Saved') > -1) {
                var si = document.getElementById('saveStateIndicator');
                if (si) { si.className = 'save-state saved'; si.innerHTML = '<i class="fas fa-circle-check" style="font-size:8px;"></i> Saved'; }
            }
        }

        updateSelCount();

        // Pending stats until user edits
        var statsPanel = document.querySelector('[id*="pnlSelectionStats"]');
        if (statsPanel) {
            var totalN = document.querySelectorAll('[id*="gvSelectedIngredients"] tbody tr').length;
            if (totalN > 0) {
                var pendingChip = document.getElementById('statPendingChip');
                if (pendingChip) {
                    var pLbl = pendingChip.querySelector('span');
                    if (pLbl) pLbl.textContent = totalN;
                    pendingChip.style.display = 'inline-flex';
                }
                ['statNormalChip', 'statOverChip', 'statUnderChip', 'statMissingChip'].forEach(function (id) {
                    var el = document.getElementById(id);
                    if (el) el.style.display = 'none';
                });
            }
        }

        // Warn on leave if unsaved
        window.addEventListener('beforeunload', function (e) {
            if (isDirty) { e.preventDefault(); e.returnValue = ''; }
        });
    });
</script>
</body>
</html>
