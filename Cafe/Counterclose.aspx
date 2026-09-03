<%@ Page Title="Counter Close" Language="C#" AutoEventWireup="true"
    CodeFile="Counterclose.aspx.cs" Inherits="Kitchen_assign" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />
    <title>Counter Close — Lahore Gymkhana</title>
    <link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700;800;900&family=Geist+Mono:wght@400;500;600&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>

    <style>
        :root {
            --ink:#0A0F1E;
            --blue:#1845D4;--blue-light:#EEF3FF;--blue-dark:#0F2D8A;--blue-mid:#4070F4;
            --surface:#F4F6FB;--line:#DDE3EF;--line-mid:#C8D0E0;--muted:#7A85A0;
            --green:#0E9E52;--green-light:#EDFAF4;--green-dark:#075C30;
            --amber:#D4820A;--amber-light:#FFF8ED;
            --red:#D42B2B;--red-light:#FFF0F0;
            --purple:#6B35D4;--purple-light:#F3EEFF;
            --teal:#0A9E8E;--teal-light:#EDFAF8;
            --sh1:0 1px 3px rgba(10,15,30,.07),0 1px 2px rgba(10,15,30,.05);
            --sh2:0 4px 12px rgba(10,15,30,.08),0 2px 4px rgba(10,15,30,.05);
            --sh4:0 24px 48px rgba(10,15,30,.12);
            --r:10px;--r-sm:7px;--r-lg:14px;--r-xl:18px;
        }
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'Geist',system-ui,sans-serif;background:var(--surface);color:var(--ink);font-size:13.5px;line-height:1.5;}
        ::-webkit-scrollbar{width:5px;height:5px;}
        ::-webkit-scrollbar-track{background:transparent;}
        ::-webkit-scrollbar-thumb{background:var(--line-mid);border-radius:5px;}
        ::-webkit-scrollbar-thumb:hover{background:var(--blue-mid);}

        .cc-wrap{max-width:1640px;margin:0 auto;padding:18px 20px;}

        .page-hdr{display:flex;align-items:center;justify-content:space-between;background:var(--ink);padding:0 22px;height:56px;border-radius:var(--r-lg);margin-bottom:18px;box-shadow:0 4px 18px rgba(10,15,30,.2);}
        .page-hdr-brand{display:flex;align-items:center;gap:10px;}
        .phdr-icon{width:34px;height:34px;background:linear-gradient(135deg,var(--blue),var(--blue-mid));border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:15px;color:white;box-shadow:0 4px 10px rgba(24,69,212,.4);}
        .phdr-name{color:white;font-size:.9rem;font-weight:800;letter-spacing:-.3px;}
        .phdr-sub{color:rgba(255,255,255,.38);font-size:.62rem;letter-spacing:.8px;text-transform:uppercase;}
        .hdr-btn{padding:7px 14px;border-radius:8px;border:1px solid rgba(255,255,255,0.15);font-weight:600;font-size:11.5px;cursor:pointer;transition:all .18s;display:flex;align-items:center;gap:6px;background:rgba(255,255,255,0.1);color:white;font-family:inherit;}
        .hdr-btn:hover{background:rgba(255,255,255,0.2);transform:translateY(-1px);}

        .card{background:white;border-radius:var(--r-lg);box-shadow:var(--sh1);border:1px solid var(--line);margin-bottom:16px;overflow:hidden;}
        .card-head{background:linear-gradient(to right,#F7F9FF,white);padding:11px 18px;border-bottom:1px solid var(--line);display:flex;justify-content:space-between;align-items:center;}
        .card-head h3{font-size:.88rem;font-weight:800;color:var(--ink);display:flex;align-items:center;gap:7px;margin:0;}
        .card-head h3 i{color:var(--blue);font-size:13px;}
        .card-body{padding:16px 18px;}

        .counter-banner{background:white;border-radius:var(--r-lg);border:1px solid var(--line);padding:20px 28px;margin-bottom:18px;box-shadow:var(--sh1);display:flex;flex-wrap:wrap;justify-content:space-between;align-items:center;gap:16px;}
        .cb-section{display:flex;flex-direction:column;gap:4px;}
        .cb-label{font-size:.66rem;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.8px;}
        .cb-value{font-size:1rem;font-weight:800;color:var(--ink);}
        .cb-divider{width:1px;height:44px;background:var(--line);}
        .status-badge{padding:6px 16px;border-radius:100px;font-size:.78rem;font-weight:700;display:inline-flex;align-items:center;gap:7px;}
        .status-open{background:var(--green-light);color:var(--green-dark);border:1.5px solid #A7F3D0;}
        .status-closed{background:var(--red-light);color:var(--red);border:1.5px solid #FECACA;}
        .status-dot{width:7px;height:7px;border-radius:50%;animation:blink 1.5s infinite;}
        .status-open .status-dot{background:var(--green);}
        .status-closed .status-dot{background:var(--red);animation:none;}
        @keyframes blink{0%,100%{opacity:1}50%{opacity:0.3}}

        .dept-scope-badge{display:inline-flex;align-items:center;gap:6px;background:var(--blue-light);border:1.5px solid #C0CFFF;border-radius:100px;padding:5px 14px;font-size:.75rem;font-weight:700;color:var(--blue);}

        .stats-grid{display:grid;grid-template-columns:repeat(5,1fr);gap:12px;margin-bottom:18px;}
        .stat-tile{border-radius:var(--r);padding:14px 16px;display:flex;flex-direction:column;gap:6px;transition:transform .15s,box-shadow .15s;background:white;border:1px solid var(--line);}
        .stat-tile:hover{transform:translateY(-2px);box-shadow:var(--sh2);}
        .stat-tile-label{font-size:.63rem;font-weight:800;text-transform:uppercase;letter-spacing:.7px;display:flex;align-items:center;gap:5px;color:var(--muted);}
        .stat-tile-label i{font-size:10px;}
        .stat-tile-value{font-family:'Geist Mono',monospace;font-size:1.1rem;font-weight:800;letter-spacing:-.5px;color:var(--ink);}
        .stat-tile.st-sales .stat-tile-value{color:var(--green-dark);}
        .stat-tile.st-bank .stat-tile-value{color:var(--blue-dark);}
        .stat-tile.st-member .stat-tile-value{color:var(--purple);}
        .stat-tile.st-cash .stat-tile-value{color:var(--amber);}
        .stat-tile.st-disc .stat-tile-value{color:var(--red);}

        .pay-cards{display:grid;grid-template-columns:repeat(3,1fr);gap:14px;margin-bottom:18px;}
        .pay-card{background:white;border-radius:var(--r-lg);padding:16px 20px;border:1px solid var(--line);box-shadow:var(--sh1);display:flex;justify-content:space-between;align-items:center;transition:transform .15s;}
        .pay-card:hover{transform:translateY(-2px);box-shadow:var(--sh2);}
        .pay-card.bank{border-left:4px solid var(--blue);}
        .pay-card.member{border-left:4px solid var(--purple);}
        .pay-card.cash{border-left:4px solid var(--amber);}
        .pay-card-title{font-size:.7rem;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.6px;margin-bottom:5px;}
        .pay-card-amount{font-family:'Geist Mono',monospace;font-size:1.2rem;font-weight:800;color:var(--ink);}
        .pay-card-icon{font-size:24px;color:var(--line-mid);}

        /* ── FIXED TABLE STYLES ── */
        .table-outer{overflow-x:auto;}
        .cc-table{width:100%;border-collapse:collapse;font-size:12.5px;table-layout:fixed;}
        .cc-table thead tr{background:linear-gradient(to right,#F0F4FF,#F7F9FF);}
        .cc-table th{padding:11px 14px;font-size:.68rem;font-weight:800;color:#1E293B;text-transform:uppercase;letter-spacing:.7px;border-bottom:2px solid var(--line);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
        .cc-table td{padding:10px 14px;border-bottom:1px solid #F0F4FA;vertical-align:middle;overflow:hidden;text-overflow:ellipsis;}
        .cc-table tbody tr:hover td{background:#F7F9FF;}
        .cc-table tbody tr:nth-child(even) td{background:#FAFBFF;}
        .cc-table tbody tr:nth-child(even):hover td{background:#F0F4FF;}

        /* Fixed column widths */
        .col-dept    { width:22%; text-align:left !important; }
        .col-subdept { width:20%; text-align:left !important; }
        .col-pm      { width:18%; text-align:left !important; }
        .col-disc    { width:13%; text-align:right !important; }
        .col-tax     { width:12%; text-align:right !important; }
        .col-total   { width:10%; text-align:right !important; }
        .col-action  { width:5%;  text-align:center !important; }

        .pm-badge{display:inline-flex;align-items:center;gap:5px;padding:3px 10px;border-radius:100px;font-size:11px;font-weight:700;white-space:nowrap;}
        .pm-bank{background:var(--blue-light);color:var(--blue);border:1px solid #BFDBFE;}
        .pm-member{background:var(--purple-light);color:var(--purple);border:1px solid #DDD6FE;}
        .pm-debit{background:var(--blue-light);color:var(--blue);border:1px solid #BFDBFE;}
        .pm-credit{background:var(--amber-light);color:var(--amber);border:1px solid #FDE68A;}
        .pm-cash{background:var(--green-light);color:var(--green-dark);border:1px solid #BBF7D0;}

        .money{font-family:'Geist Mono',monospace;font-weight:600;color:var(--ink);}
        .money.pos{color:var(--green-dark);font-weight:700;}

        .btn-view{padding:4px 10px;border-radius:6px;border:1px solid var(--blue);background:var(--blue-light);color:var(--blue);font-size:11px;font-weight:700;cursor:pointer;transition:all .18s;display:inline-flex;align-items:center;gap:4px;font-family:inherit;white-space:nowrap;}
        .btn-view:hover{background:var(--blue);color:white;}

        .empty-state{text-align:center;padding:40px 20px;background:linear-gradient(135deg,#F7F9FF,#F1F5FF);border-radius:var(--r);border:2px dashed #C0CFFF;margin:16px;}
        .empty-state i{font-size:38px;color:#C0CFFF;margin-bottom:10px;display:block;}
        .empty-state h4{color:var(--blue);margin-bottom:5px;font-size:.98rem;font-weight:800;}
        .empty-state p{color:var(--muted);font-size:.84rem;}

        .alert-box{border-radius:var(--r);padding:12px 16px;margin-bottom:16px;display:flex;align-items:center;gap:12px;}
        .alert-warn{background:var(--amber-light);border:2px solid #FDE68A;}
        .alert-danger{background:var(--red-light);border:2px solid #FECACA;}
        .alert-success{background:var(--green-light);border:2px solid #BBF7D0;}
        .alert-box i{font-size:16px;flex-shrink:0;}
        .alert-warn i{color:var(--amber);}
        .alert-danger i{color:var(--red);}
        .alert-success i{color:var(--green);}
        .alert-box .atxt{font-weight:600;font-size:.85rem;}

        .action-footer{background:white;border-radius:var(--r-lg);border:1px solid var(--line);padding:18px 24px;display:flex;justify-content:space-between;align-items:center;gap:16px;box-shadow:var(--sh1);margin-top:8px;}
        .action-footer .note{font-size:.8rem;color:var(--muted);max-width:500px;}
        .action-footer .note strong{color:var(--ink);}
        .action-btns{display:flex;gap:10px;}

        .btn-print{padding:10px 20px;border-radius:var(--r-sm);border:1.5px solid var(--line);font-weight:700;font-size:12px;cursor:pointer;background:white;color:var(--muted);display:inline-flex;align-items:center;gap:7px;font-family:inherit;transition:all .2s;}
        .btn-print:hover{background:var(--blue-light);border-color:var(--blue);color:var(--blue);transform:translateY(-1px);}

        .btn-confirm{padding:10px 24px;border-radius:var(--r-sm);border:none;font-weight:700;font-size:12px;cursor:pointer;background:linear-gradient(135deg,var(--green-dark),var(--green));color:white;display:inline-flex;align-items:center;gap:7px;font-family:inherit;transition:all .2s;box-shadow:0 3px 10px rgba(14,158,82,.3);}
        .btn-confirm:hover:not(:disabled){transform:translateY(-1px);box-shadow:0 6px 16px rgba(14,158,82,.4);}
        .btn-confirm:disabled{background:linear-gradient(135deg,#CBD5E1,#94A3B8);box-shadow:none;cursor:not-allowed;}

        .sub-totals{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;}
        .sub-tile{padding:14px 16px;background:var(--surface);border-radius:var(--r);border:1px solid var(--line);}
        .sub-tile-label{font-size:.62rem;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.7px;margin-bottom:4px;}
        .sub-tile-value{font-family:'Geist Mono',monospace;font-size:1rem;font-weight:800;color:var(--ink);}

        /* ── DETAIL MODAL ── */
        .modal-overlay{display:none;position:fixed;inset:0;background:rgba(10,15,30,.6);z-index:9999;align-items:center;justify-content:center;backdrop-filter:blur(6px);}
        .modal-overlay.active{display:flex;}
        .modal-box{background:white;border-radius:var(--r-xl);box-shadow:var(--sh4);width:94%;max-width:1100px;max-height:90vh;overflow-y:auto;animation:slideIn .28s cubic-bezier(.34,1.56,.64,1);}
        .modal-head{background:linear-gradient(to right,#EEF3FF,white);padding:13px 20px;border-bottom:1px solid var(--line);display:flex;justify-content:space-between;align-items:center;position:sticky;top:0;z-index:10;border-radius:var(--r-xl) var(--r-xl) 0 0;}
        .modal-head h3{font-size:.9rem;font-weight:800;color:var(--ink);display:flex;align-items:center;gap:8px;margin:0;}
        .modal-head h3 i{color:var(--blue);}
        .modal-close{background:none;border:none;font-size:1rem;cursor:pointer;color:#94A3B8;width:30px;height:30px;display:flex;align-items:center;justify-content:center;border-radius:7px;transition:all .2s;}
        .modal-close:hover{background:var(--red-light);color:var(--red);}
        .modal-body{padding:18px 20px;}
        @keyframes slideIn{from{transform:scale(.92) translateY(-18px);opacity:0}to{transform:scale(1) translateY(0);opacity:1}}

        /* Detail table inside modal */
        .detail-table{width:100%;border-collapse:collapse;font-size:12px;table-layout:fixed;}
        .detail-table th{background:#F7F9FC;padding:9px 12px;font-weight:700;color:#475569;border-bottom:2px solid var(--line);font-size:10.5px;text-transform:uppercase;letter-spacing:.5px;}
        .detail-table td{padding:9px 12px;border-bottom:1px solid #F0F4FA;vertical-align:middle;}
        .detail-table tbody tr:hover td{background:#F7F9FF;}
        .detail-table .th-billno  { width:16%; text-align:left; }
        .detail-table .th-kot     { width:14%; text-align:left; }
        .detail-table .th-member  { width:14%; text-align:left; }
        .detail-table .th-time    { width:10%; text-align:center; }
        .detail-table .th-sub     { width:12%; text-align:right; }
        .detail-table .th-disc    { width:12%; text-align:right; }
        .detail-table .th-tax     { width:10%; text-align:right; }
        .detail-table .th-final   { width:12%; text-align:right; }

        .mono{font-family:'Geist Mono',monospace;font-weight:600;}
        .tag-billno{background:#FEF3E2;color:#7B3F00;padding:2px 7px;border-radius:4px;border:1px solid #F5C9A0;font-family:'Geist Mono',monospace;font-size:10.5px;font-weight:700;}
        .tag-kot{background:var(--blue-light);color:var(--blue);padding:2px 7px;border-radius:100px;font-size:10.5px;font-weight:700;}

        .detail-totals{background:linear-gradient(135deg,var(--green-light),#F2FEF7);border:1.5px solid #A7F0C8;border-radius:var(--r);padding:12px 16px;margin-top:12px;display:flex;justify-content:space-between;flex-wrap:wrap;gap:12px;}
        .dt-item{text-align:center;}
        .dt-lbl{font-size:.62rem;color:#0D7A3E;font-weight:700;text-transform:uppercase;letter-spacing:.6px;margin-bottom:3px;}
        .dt-val{font-family:'Geist Mono',monospace;font-size:1rem;font-weight:800;color:var(--ink);}
        .dt-val.grand{color:var(--green-dark);font-size:1.1rem;}

        /* Success overlay */
        #successOverlay{display:none;position:fixed;inset:0;background:rgba(10,15,30,.6);z-index:9999;align-items:center;justify-content:center;backdrop-filter:blur(4px);}
        #successOverlay.show{display:flex;}
        .success-box{background:white;border-radius:var(--r-xl);padding:40px 50px;text-align:center;box-shadow:var(--sh4);animation:popIn .4s cubic-bezier(.34,1.2,.64,1);max-width:420px;width:90%;}
        .success-ring{width:72px;height:72px;background:var(--green-light);border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 16px;}
        .success-ring i{font-size:32px;color:var(--green);}
        .success-box h2{font-size:1.3rem;font-weight:800;color:var(--ink);margin-bottom:6px;}
        .success-box p{color:var(--muted);font-size:.88rem;margin-bottom:20px;}
        .btn-go-home{padding:10px 24px;background:var(--blue);color:white;border:none;border-radius:var(--r-sm);font-weight:700;font-size:12px;cursor:pointer;font-family:inherit;transition:all .2s;}
        .btn-go-home:hover{background:var(--blue-dark);transform:translateY(-1px);}
        @keyframes popIn{from{transform:scale(.85);opacity:0}to{transform:scale(1);opacity:1}}

        /* Loading spinner */
        .loading-box{text-align:center;padding:30px;}
        .loading-box i{font-size:1.6rem;color:var(--blue);}
        .spin{animation:spin .8s linear infinite;}
        @keyframes spin{to{transform:rotate(360deg)}}

        /* Print */
        @media print{
            .page-hdr,.action-footer,.btn-print,.btn-confirm,.hdr-btn,.btn-view{display:none !important;}
            .cc-wrap{padding:0;margin:0;}
            .card{box-shadow:none;border:1px solid #ccc;}
        }

        @media(max-width:1100px){.stats-grid{grid-template-columns:repeat(3,1fr);}}
        @media(max-width:900px){
            .stats-grid{grid-template-columns:repeat(2,1fr);}
            .pay-cards{grid-template-columns:1fr;}
            .sub-totals{grid-template-columns:repeat(2,1fr);}
        }
        @media(max-width:768px){
            .counter-banner{flex-direction:column;align-items:flex-start;}
            .action-footer{flex-direction:column;align-items:stretch;}
            .action-btns{flex-direction:column;}
            .cb-divider{display:none;}
            .stats-grid{grid-template-columns:1fr;}
            .sub-totals{grid-template-columns:1fr;}
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" />

    <div class="cc-wrap">

        <!-- PAGE HEADER -->
        <div class="page-hdr">
            <div class="page-hdr-brand">
                <div class="phdr-icon"><i class="fas fa-lock"></i></div>
                <div>
                    <div class="phdr-name">Lahore Gymkhana</div>
                    <div class="phdr-sub">Counter Close</div>
                </div>
            </div>
            <div>
                <asp:Button ID="btnBack" runat="server" CssClass="hdr-btn"
                    Text="← Back to Cashier" OnClick="btnBack_Click" UseSubmitBehavior="true" />
            </div>
        </div>

        <!-- COUNTER INFO BANNER -->
        <div class="counter-banner">
            <div class="cb-section">
                <div class="cb-label"><i class="fas fa-user"></i> Cashier</div>
                <div class="cb-value"><asp:Label ID="lblCashierName" runat="server" Text="—"></asp:Label></div>
            </div>
            <div class="cb-divider"></div>
            <div class="cb-section">
                <div class="cb-label"><i class="fas fa-door-open"></i> Counter Opened</div>
                <div class="cb-value"><asp:Label ID="lblOpenTime" runat="server" Text="—"></asp:Label></div>
            </div>
            <div class="cb-divider"></div>
            <div class="cb-section">
                <div class="cb-label"><i class="fas fa-clock"></i> Close Time</div>
                <div class="cb-value"><asp:Label ID="lblCloseTime" runat="server" Text="—"></asp:Label></div>
            </div>
            <div class="cb-divider"></div>
            <div class="cb-section">
                <div class="cb-label"><i class="fas fa-building"></i> Department</div>
                <div class="cb-value">
                    <asp:Label ID="lblDeptName" runat="server" Text="All"></asp:Label>
                </div>
            </div>
            <div style="display:flex;flex-direction:column;gap:8px;align-items:flex-end;">
                <asp:Label ID="lblCounterStatus" runat="server" CssClass="status-badge status-open"
                    Text='<span class="status-dot"></span> Counter Open' />
                <div class="dept-scope-badge" id="deptScopeBadge" style="display:none;">
                    <i class="fas fa-filter"></i>
                    <span id="deptScopeText">Filtered to department</span>
                </div>
            </div>
        </div>

        <!-- VALIDATION ALERTS -->
        <asp:Label ID="lblAlertHtml" runat="server" Visible="false" />

        <!-- SUMMARY STATS CARDS -->
        <div class="stats-grid">
            <div class="stat-tile st-sales">
                <div class="stat-tile-label"><i class="fas fa-coins"></i> Total Sales</div>
                <div class="stat-tile-value"><asp:Label ID="lblTotalSales" runat="server" Text="Rs 0"></asp:Label></div>
            </div>
            <div class="stat-tile st-bank">
                <div class="stat-tile-label"><i class="fas fa-credit-card"></i> Bank Card</div>
                <div class="stat-tile-value"><asp:Label ID="lblBankTotal" runat="server" Text="Rs 0"></asp:Label></div>
            </div>
            <div class="stat-tile st-member">
                <div class="stat-tile-label"><i class="fas fa-id-card"></i> Member Card</div>
                <div class="stat-tile-value"><asp:Label ID="lblMemberTotal" runat="server" Text="Rs 0"></asp:Label></div>
            </div>
            <div class="stat-tile st-cash">
                <div class="stat-tile-label"><i class="fas fa-money-bill-wave"></i> Cash</div>
                <div class="stat-tile-value"><asp:Label ID="lblCashTotal" runat="server" Text="Rs 0"></asp:Label></div>
            </div>
            <div class="stat-tile st-disc">
                <div class="stat-tile-label"><i class="fas fa-percentage"></i> Total Discount</div>
                <div class="stat-tile-value"><asp:Label ID="lblDiscountTotal" runat="server" Text="Rs 0"></asp:Label></div>
            </div>
        </div>

        <!-- PAYMENT METHOD CARDS -->
        <div class="pay-cards">
            <div class="pay-card bank">
                <div>
                    <div class="pay-card-title">Bank / Debit / Credit Card</div>
                    <div class="pay-card-amount"><asp:Label ID="lblCardAmount" runat="server" Text="Rs 0"></asp:Label></div>
                </div>
                <i class="fas fa-credit-card pay-card-icon"></i>
            </div>
            <div class="pay-card member">
                <div>
                    <div class="pay-card-title">Member Card</div>
                    <div class="pay-card-amount"><asp:Label ID="lblMemberAmount" runat="server" Text="Rs 0"></asp:Label></div>
                </div>
                <i class="fas fa-id-card pay-card-icon"></i>
            </div>
            <div class="pay-card cash">
                <div>
                    <div class="pay-card-title">Cash in Hand</div>
                    <div class="pay-card-amount"><asp:Label ID="lblCashAmount" runat="server" Text="Rs 0"></asp:Label></div>
                </div>
                <i class="fas fa-money-bill-wave pay-card-icon"></i>
            </div>
        </div>

        <!-- DETAILED BREAKDOWN TABLE -->
        <div class="card">
            <div class="card-head">
                <h3><i class="fas fa-table"></i> Sales Breakdown by Department &amp; Payment Method</h3>
                <span style="font-size:.7rem;color:var(--muted);"><i class="far fa-clock"></i> Today's paid transactions</span>
            </div>
            <div class="table-outer">
                <asp:GridView ID="gvSales" runat="server" AutoGenerateColumns="False"
                    CssClass="cc-table" GridLines="None"
                    Width="100%">
                    <Columns>
                        <asp:BoundField DataField="Dept_Name"    HeaderText="Department"
                            HeaderStyle-CssClass="col-dept"    ItemStyle-CssClass="col-dept" />
                        <asp:BoundField DataField="SubDept_Name" HeaderText="Sub Department"
                            HeaderStyle-CssClass="col-subdept" ItemStyle-CssClass="col-subdept" />
                        <asp:TemplateField HeaderText="Payment Method"
                            HeaderStyle-CssClass="col-pm"      ItemStyle-CssClass="col-pm">
                            <ItemTemplate>
                                <%# GetPaymentBadge(Eval("PaymentMethod").ToString()) %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="TotalDiscount" HeaderText="Discount (Rs)" DataFormatString="{0:N2}"
                            HeaderStyle-CssClass="col-disc" ItemStyle-CssClass="col-disc money" />
                        <asp:BoundField DataField="TotalTax"      HeaderText="Tax (Rs)"      DataFormatString="{0:N2}"
                            HeaderStyle-CssClass="col-tax"  ItemStyle-CssClass="col-tax money" />
                        <asp:BoundField DataField="TodayTotalSales" HeaderText="Total (Rs)"  DataFormatString="{0:N2}"
                            HeaderStyle-CssClass="col-total" ItemStyle-CssClass="col-total money pos" />
                        <asp:TemplateField HeaderText="Detail"
                            HeaderStyle-CssClass="col-action" ItemStyle-CssClass="col-action">
                            <ItemTemplate>
                                <button type="button" class="btn-view"
                                    onclick="openDetailModal('<%# Eval("Dept_Name").ToString().Replace("'","\\'") %>','<%# Eval("PaymentMethod").ToString().Replace("'","\\'") %>')">
                                    <i class="fas fa-eye"></i>
                                </button>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="empty-state">
                            <i class="fas fa-receipt"></i>
                            <h4>No Sales Data</h4>
                            <p>No paid transactions found for today in the selected department.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

        <!-- TAX & DISCOUNT SUMMARY -->
        <div class="card">
            <div class="card-head">
                <h3><i class="fas fa-receipt"></i> Tax &amp; Discount Summary</h3>
            </div>
            <div class="card-body">
                <div class="sub-totals">
                    <div class="sub-tile">
                        <div class="sub-tile-label">Total Tax Collected</div>
                        <div class="sub-tile-value"><asp:Label ID="lblTaxTotal" runat="server" Text="Rs 0"></asp:Label></div>
                    </div>
                    <div class="sub-tile">
                        <div class="sub-tile-label">Total Discounts Given</div>
                        <div class="sub-tile-value"><asp:Label ID="lblDiscountGiven" runat="server" Text="Rs 0"></asp:Label></div>
                    </div>
                    <div class="sub-tile">
                        <div class="sub-tile-label">Net Sales (After Discount)</div>
                        <div class="sub-tile-value"><asp:Label ID="lblNetSales" runat="server" Text="Rs 0"></asp:Label></div>
                    </div>
                    <div class="sub-tile">
                        <div class="sub-tile-label">Grand Total (incl. Tax)</div>
                        <div class="sub-tile-value"><asp:Label ID="lblGrandTotal" runat="server" Text="Rs 0"></asp:Label></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ACTION FOOTER -->
        <div class="action-footer">
            <div class="note">
                <strong>Ready to close?</strong><br />
                Closing the counter will lock today's sales records for
                <strong id="footerDeptName">this department</strong>
                and generate the closing report.
                This action <strong>cannot be undone</strong>.
            </div>
            <div class="action-btns">
                <button type="button" class="btn-print" onclick="printReport()">
                    <i class="fas fa-print"></i> Print Report
                </button>
                <asp:Button ID="btnCounterClose" runat="server"
                    CssClass="btn-confirm"
                    Text="🔒 Confirm Counter Close"
                    OnClick="btnCounterClose_Click"
                    OnClientClick="return confirmClose();" />
            </div>
        </div>

    </div><!-- /cc-wrap -->

    <!-- ══ DETAIL MODAL ══ -->
    <div id="detailModal" class="modal-overlay">
        <div class="modal-box">
            <div class="modal-head">
                <h3 id="detailModalTitle"><i class="fas fa-list-alt"></i> Bill Details</h3>
                <button class="modal-close" onclick="closeDetailModal()"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                <div id="detailContent">
                    <div class="loading-box">
                        <i class="fas fa-spinner spin"></i>
                        <p style="margin-top:10px;color:var(--muted);">Loading...</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- SUCCESS OVERLAY -->
    <div id="successOverlay">
        <div class="success-box">
            <div class="success-ring"><i class="fas fa-check"></i></div>
            <h2>Counter Closed!</h2>
            <p>Today's counter has been successfully closed. All sales have been recorded and locked.</p>
            <button class="btn-go-home" onclick="window.location.href='Casier.aspx'">
                <i class="fas fa-home"></i> Back to Cashier
            </button>
        </div>
    </div>

    <script>
        // Show dept scope badge if a dept is set
        (function () {
            var deptVal = '<%= Session["CC_DeptName"] != null ? Session["CC_DeptName"].ToString() : "" %>';
            if (deptVal && deptVal !== '') {
                var badge = document.getElementById('deptScopeBadge');
                var txt = document.getElementById('deptScopeText');
                var footer = document.getElementById('footerDeptName');
                if (badge) { badge.style.display = 'inline-flex'; }
                if (txt) txt.textContent = 'Showing: ' + deptVal;
                if (footer) footer.textContent = deptVal;
            }
        })();

        // ── MODAL ──
        function openDetailModal(deptName, paymentMethod) {
            var modal = document.getElementById('detailModal');
            var title = document.getElementById('detailModalTitle');
            title.innerHTML = '<i class="fas fa-list-alt"></i> ' + paymentMethod + ' — ' + deptName;

            document.getElementById('detailContent').innerHTML =
                '<div class="loading-box"><i class="fas fa-spinner spin"></i>' +
                '<p style="margin-top:10px;color:var(--muted);">Loading bill details...</p></div>';

            modal.classList.add('active');
            document.body.style.overflow = 'hidden';

            $.ajax({
                type: 'POST',
                url: 'Counterclose.aspx/GetPaymentMethodDetail',
                data: JSON.stringify({ deptName: deptName, paymentMethod: paymentMethod }),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (res) {
                    if (res && res.d && res.d.success) {
                        renderDetailTable(res.d);
                    } else {
                        document.getElementById('detailContent').innerHTML =
                            '<div class="empty-state"><i class="fas fa-info-circle"></i>' +
                            '<h4>No Records Found</h4><p>' + (res.d ? (res.d.message || '') : '') + '</p></div>';
                    }
                },
                error: function () {
                    document.getElementById('detailContent').innerHTML =
                        '<div class="empty-state"><i class="fas fa-exclamation-triangle"></i>' +
                        '<h4>Error</h4><p>Could not load bill details. Please try again.</p></div>';
                }
            });
        }

        function renderDetailTable(data) {
            var rows = data.rows || [];
            var html = '';

            if (rows.length === 0) {
                html = '<div class="empty-state"><i class="fas fa-receipt"></i>' +
                    '<h4>No Bills Found</h4><p>No bills match this filter.</p></div>';
                document.getElementById('detailContent').innerHTML = html;
                return;
            }

            html += '<div style="overflow-x:auto;">';
            html += '<table class="detail-table">';
            html += '<thead><tr>';
            html += '<th class="th-billno">Bill No</th>';
            html += '<th class="th-kot">KOT Number</th>';
            html += '<th class="th-member">Member No</th>';
            html += '<th class="th-time" style="text-align:center;">Time</th>';
            html += '<th class="th-sub" style="text-align:right;">Subtotal</th>';
            html += '<th class="th-disc" style="text-align:right;">Discount</th>';
            html += '<th class="th-tax" style="text-align:right;">Tax</th>';
            html += '<th class="th-final" style="text-align:right;">Final Amount</th>';
            html += '</tr></thead><tbody>';

            rows.forEach(function (r) {
                html += '<tr>';
                html += '<td><span class="tag-billno">' + (r.BillNo || '—') + '</span></td>';
                html += '<td><span class="tag-kot">' + (r.KotNumber || '—') + '</span></td>';
                html += '<td><span class="mono" style="color:var(--blue);">' + (r.MemberNo || '—') + '</span></td>';
                html += '<td style="text-align:center;color:var(--muted);font-size:11px;">' + (r.PayTime || '—') + '</td>';
                html += '<td style="text-align:right;" class="mono">Rs ' + parseFloat(r.Subtotal || 0).toFixed(2) + '</td>';
                html += '<td style="text-align:right;color:var(--red);" class="mono">' +
                    (parseFloat(r.DiscountAmt || 0) > 0 ? '−Rs ' + parseFloat(r.DiscountAmt).toFixed(2) : '—') + '</td>';
                html += '<td style="text-align:right;color:var(--muted);" class="mono">Rs ' + parseFloat(r.TaxAmt || 0).toFixed(2) + '</td>';
                html += '<td style="text-align:right;font-weight:700;color:var(--green-dark);" class="mono">Rs ' + parseFloat(r.FinalAmount || 0).toFixed(2) + '</td>';
                html += '</tr>';
            });

            html += '</tbody></table></div>';

            // Totals bar
            html += '<div class="detail-totals">';
            html += '<div class="dt-item"><div class="dt-lbl">Bills Count</div><div class="dt-val">' + rows.length + '</div></div>';
            html += '<div class="dt-item"><div class="dt-lbl">Total Discount</div><div class="dt-val" style="color:var(--red);">Rs ' + parseFloat(data.grandDiscount || 0).toFixed(2) + '</div></div>';
            html += '<div class="dt-item"><div class="dt-lbl">Total Tax</div><div class="dt-val" style="color:var(--muted);">Rs ' + parseFloat(data.grandTax || 0).toFixed(2) + '</div></div>';
            html += '<div class="dt-item"><div class="dt-lbl">Grand Total</div><div class="dt-val grand">Rs ' + parseFloat(data.grandTotal || 0).toFixed(2) + '</div></div>';
            html += '</div>';

            document.getElementById('detailContent').innerHTML = html;
        }

        function closeDetailModal() {
            document.getElementById('detailModal').classList.remove('active');
            document.body.style.overflow = '';
        }

        // Close modal on overlay click or ESC
        document.addEventListener('click', function (e) {
            if (e.target.id === 'detailModal') closeDetailModal();
        });
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') closeDetailModal();
        });

        // ── CONFIRM CLOSE ──
        function confirmClose() {
            var deptVal = '<%= Session["CC_DeptName"] != null ? Session["CC_DeptName"].ToString().Replace("'", "\\'") : "All Departments" %>';
            return confirm('Are you sure you want to CLOSE the counter for ' + deptVal + '?\n\nThis will lock all today\'s sales records and cannot be undone.');
        }

        // ── SUCCESS ──
        function showSuccessOverlay() {
            var overlay = document.getElementById('successOverlay');
            if (overlay) overlay.classList.add('show');
        }

        // ── PRINT ──
        function printReport() {
            var html = buildReportHtml();
            var w = window.open('', '_blank', 'width=900,height=700,scrollbars=yes');
            w.document.write(html);
            w.document.close();
        }

        function buildReportHtml() {
            var cashierName = document.getElementById('<%= lblCashierName.ClientID %>').textContent;
            var openTime = document.getElementById('<%= lblOpenTime.ClientID %>').textContent;
            var closeTime = document.getElementById('<%= lblCloseTime.ClientID %>').textContent;
            var deptName = document.getElementById('<%= lblDeptName.ClientID %>').textContent;
            var totalSales = document.getElementById('<%= lblTotalSales.ClientID %>').textContent;
            var bankCard = document.getElementById('<%= lblCardAmount.ClientID %>').textContent;
            var memberCard = document.getElementById('<%= lblMemberAmount.ClientID %>').textContent;
            var cash = document.getElementById('<%= lblCashAmount.ClientID %>').textContent;
            var discount = document.getElementById('<%= lblDiscountTotal.ClientID %>').textContent;
            var tax = document.getElementById('<%= lblTaxTotal.ClientID %>').textContent;
            var netSales = document.getElementById('<%= lblNetSales.ClientID %>').textContent;
            var grandTotal = document.getElementById('<%= lblGrandTotal.ClientID %>').textContent;

            var gv = document.getElementById('<%= gvSales.ClientID %>');
            var tableHtml = '';
            if (gv) {
                var rows = gv.querySelectorAll('tr');
                rows.forEach(function (row) {
                    var cells = row.querySelectorAll('th, td');
                    if (!cells.length) return;
                    tableHtml += '<tr>';
                    cells.forEach(function (cell, idx) {
                        var tag = cell.tagName.toLowerCase();
                        var align = (idx >= 3 && idx <= 5) ? 'right' : (idx === 6 ? 'center' : 'left');
                        tableHtml += '<' + tag + ' style="padding:8px 10px;border-bottom:1px solid #e2e8f0;text-align:' + align + ';">' + cell.innerText.trim() + '</' + tag + '>';
                    });
                    tableHtml += '</tr>';
                });
            }

            return '<!DOCTYPE html><html><head><title>Counter Close Report</title><style>'
                + '@page{size:A4;margin:15mm}*{margin:0;padding:0;box-sizing:border-box}'
                + 'body{font-family:"Courier New",monospace;font-size:11px;color:#111}'
                + '.org{text-align:center;font-size:17px;font-weight:700;text-transform:uppercase;border-bottom:2px solid #000;padding-bottom:6px;margin-bottom:8px}'
                + '.row{display:flex;justify-content:space-between;margin-bottom:3px;font-size:10.5px;}'
                + 'table{width:100%;border-collapse:collapse;margin-top:12px;}'
                + 'th{background:#f0f0f0;padding:7px 9px;border-bottom:2px solid #333;font-size:9.5px;text-transform:uppercase;}'
                + 'td{padding:7px 9px;border-bottom:1px solid #eee;}'
                + '.totals-box{margin-top:14px;border-top:2px solid #000;padding-top:10px;}'
                + '.total-row{display:flex;justify-content:space-between;margin-bottom:4px;font-size:11px;}'
                + '.grand{font-size:13px;font-weight:700;border-top:1px solid #000;padding-top:5px;margin-top:5px;}'
                + '.sigs{display:flex;justify-content:space-between;margin-top:28px;font-size:10px;}'
                + '.sig-line{border-top:1px solid #000;padding-top:3px;min-width:140px;text-align:center;}'
                + '.noprint{text-align:center;margin-top:14px;} @media print{.noprint{display:none}}'
                + '</style></head><body>'
                + '<div class="org">LAHORE GYMKHANA</div>'
                + '<div style="text-align:center;font-size:12px;font-weight:700;margin-bottom:10px;">' + deptName + ' — COUNTER CLOSE REPORT</div>'
                + '<div style="margin-bottom:10px;">'
                + '<div class="row"><span>Cashier: <b>' + cashierName + '</b></span><span>Date: <b>' + closeTime.split(' ')[0] + '</b></span></div>'
                + '<div class="row"><span>Counter Opened: ' + openTime + '</span><span>Closed: ' + closeTime + '</span></div>'
                + '</div>'
                + '<table>' + tableHtml + '</table>'
                + '<div class="totals-box">'
                + '<div class="total-row"><span>Bank / Card Total:</span><span>' + bankCard + '</span></div>'
                + '<div class="total-row"><span>Member Card Total:</span><span>' + memberCard + '</span></div>'
                + '<div class="total-row"><span>Cash Total:</span><span>' + cash + '</span></div>'
                + '<div class="total-row"><span>Total Discount:</span><span>' + discount + '</span></div>'
                + '<div class="total-row"><span>Total Tax:</span><span>' + tax + '</span></div>'
                + '<div class="total-row"><span>Net Sales:</span><span>' + netSales + '</span></div>'
                + '<div class="total-row grand"><span>GRAND TOTAL:</span><span>' + grandTotal + '</span></div>'
                + '</div>'
                + '<div class="sigs">'
                + '<div><div class="sig-line">Cashier: ' + cashierName + '</div></div>'
                + '<div><div class="sig-line">Manager: _______________</div></div>'
                + '<div><div class="sig-line">Accounts: _______________</div></div>'
                + '</div>'
                + '<div class="noprint">'
                + '<button onclick="window.print()" style="padding:7px 18px;background:#1845D4;color:white;border:none;border-radius:5px;cursor:pointer;margin-right:7px;">Print</button>'
                + '<button onclick="window.close()" style="padding:7px 18px;background:#D42B2B;color:white;border:none;border-radius:5px;cursor:pointer;">Close</button>'
                + '</div>'
                + '<script>window.onload=function(){setTimeout(function(){window.print();},600);};<\/script>'
                + '</body></html>';
        }
    </script>

</form>
</body>
</html>
