<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master"
    AutoEventWireup="true" CodeFile="GymkhanaStatement.aspx.cs"
    Inherits="GymkhanaStatement" EnableEventValidation="false"
    ViewStateEncryptionMode="Never" MaintainScrollPositionOnPostBack="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;600;700&family=Source+Sans+3:wght@300;400;500;600&display=swap" rel="stylesheet"/>
<style>
  :root {
    --gold:#b8972a; --gold-light:#d4af37; --gold-pale:#f9f3e3;
    --navy:#1a2744; --navy-mid:#253460; --navy-light:#e8ecf4;
    --crimson:#8b1a1a; --gray-100:#f7f7f5; --gray-200:#eeede9;
    --gray-400:#9a9690; --gray-700:#3d3b36; --white:#ffffff;
  }
  *,*::before,*::after{box-sizing:border-box;}

  /* ── SEARCH BAR ── */
  .search-bar{
    background:linear-gradient(135deg,var(--navy),var(--navy-mid));
    padding:14px 24px;
    display:flex;
    align-items:center;
    gap:12px;
    flex-wrap:wrap;
    border-bottom:2px solid var(--gold);
  }
  .search-bar label{
    color:rgba(255,255,255,0.8);
    font-size:11px;
    font-weight:700;
    text-transform:uppercase;
    letter-spacing:1px;
    white-space:nowrap;
  }
  .bar-sep{ width:1px; height:28px; background:rgba(255,255,255,0.18); margin:0 4px; }

  /* ── Member No + Autocomplete ── */
  .ac-wrap{ position:relative; display:inline-block; }
  .search-input{
    padding:7px 14px;
    border:1.5px solid var(--gold);
    border-radius:4px;
    font-family:'Source Sans 3',sans-serif;
    font-size:13px;
    color:var(--navy);
    background:white;
    width:160px;
    outline:none;
    transition:border-color .2s,box-shadow .2s;
  }
  .search-input:focus{ border-color:var(--gold-light); box-shadow:0 0 0 3px rgba(184,151,42,0.22); }

  /* Autocomplete dropdown */
  .ac-list{
    display:none;
    position:absolute;
    top:calc(100% + 2px);
    left:0;
    z-index:9999;
    background:#fff;
    border:1.5px solid var(--gold);
    border-radius:0 0 6px 6px;
    min-width:260px;
    max-height:200px;
    overflow-y:auto;
    box-shadow:0 8px 24px rgba(26,39,68,0.22);
  }
  .ac-list.open{ display:block; }
  .ac-item{
    padding:7px 12px;
    cursor:pointer;
    border-bottom:1px solid #f0ede4;
    display:flex;
    align-items:baseline;
    gap:8px;
    transition:background .14s;
  }
  .ac-item:last-child{ border-bottom:none; }
  .ac-item:hover,.ac-item.ac-active{ background:var(--gold-pale); }
  .ac-no  { font-size:12px; font-weight:700; color:var(--navy); white-space:nowrap; }
  .ac-name{ font-size:11px; color:var(--gray-400); }

  /* ── Date inputs ── */
  .date-input{
    padding:7px 10px;
    border:1.5px solid var(--gold);
    border-radius:4px;
    font-family:'Source Sans 3',sans-serif;
    font-size:12px;
    color:var(--navy);
    background:white;
    outline:none;
    width:138px;
    transition:border-color .2s,box-shadow .2s;
  }
  .date-input:focus{ border-color:var(--gold-light); box-shadow:0 0 0 3px rgba(184,151,42,0.22); }

  /* ── Search button ── */
  .btn-search{
    background:linear-gradient(135deg,var(--gold-light),var(--gold));
    color:var(--navy);
    border:none;
    padding:8px 22px;
    border-radius:4px;
    font-weight:700;
    font-size:12px;
    cursor:pointer;
    letter-spacing:0.5px;
    transition:all 0.2s;
    white-space:nowrap;
  }
  .btn-search:hover{ opacity:0.9; transform:translateY(-1px); }
  .search-error{ color:#ffcccc; font-size:11px; font-weight:600; }

  /* ── STATEMENT WRAPPER ── */
  .page-wrap{ width:90%; margin:16px auto 30px; }
  .statement{
    background:var(--white); border-radius:4px;
    box-shadow:0 6px 28px rgba(26,39,68,0.17);
    overflow:hidden; position:relative;
    font-family:'Source Sans 3',sans-serif; color:var(--gray-700);
  }
  .statement::before{
    content:'';position:absolute;left:0;top:0;bottom:0;width:4px;
    background:linear-gradient(180deg,var(--gold-light),var(--gold),var(--gold-light));
  }

  /* ── HEADER ── */
  .stmt-header{
    background:linear-gradient(135deg,var(--navy) 0%,var(--navy-mid) 100%);
    padding:6px 18px 6px 20px;
    display:flex;align-items:center;justify-content:space-between;
    gap:14px;border-bottom:2px solid var(--gold);
  }
  .logo-emblem{ width:36px;height:36px;border:1.5px solid var(--gold);border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:18px;background:rgba(184,151,42,0.1);flex-shrink:0; }
  .org-info{ display:flex;flex-direction:column;gap:1px; }
  .org-info h1{ font-family:'Playfair Display',serif;font-size:13px;font-weight:700;color:var(--white);letter-spacing:1.2px;text-transform:uppercase;line-height:1.2; }
  .org-info .sub-addr{ font-size:8.5px;color:rgba(255,255,255,0.55);letter-spacing:0.5px; }
  .org-info .stmt-type{ font-size:9px;color:rgba(212,175,55,0.88);letter-spacing:1.6px;font-family:'Playfair Display',serif; }
  .org-info .org-contact{ font-size:8.5px;color:rgba(255,255,255,0.5);margin-top:1px; }
  .org-info .org-contact strong{ color:rgba(255,255,255,0.8); }

  /* Period badge */
  .period-badge{ background:rgba(184,151,42,0.14);border:1px solid rgba(184,151,42,0.4);border-radius:4px;padding:5px 12px;text-align:center;flex-shrink:0; }
  .period-badge .pb-label{ font-size:7.5px;text-transform:uppercase;letter-spacing:1px;color:rgba(255,255,255,0.5);margin-bottom:2px; }
  .period-badge .pb-val{ font-family:'Playfair Display',serif;font-size:10px;color:var(--gold-light);font-weight:600;white-space:nowrap; }

  /* ── META ROW ── */
  .meta-row{background:var(--gold-pale);border-bottom:1px solid #e0d5b8;display:grid;grid-template-columns:repeat(4,1fr);}
  .meta-cell{padding:6px 12px;border-right:1px solid #e0d5b8;text-align:center;}
  .meta-cell:last-child{border-right:none;}
  .meta-label{font-size:8px;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:var(--gold);margin-bottom:1px;}
  .meta-value{font-family:'Playfair Display',serif;font-size:12px;font-weight:600;color:var(--navy);}

  /* ── MEMBER STRIP ── */
  .member-strip{background:var(--navy-light);padding:7px 26px;display:flex;justify-content:space-between;align-items:center;border-bottom:1px solid #d5dae8;gap:14px;}
  .member-name-block h2{font-family:'Playfair Display',serif;font-size:13px;font-weight:700;color:var(--navy);}
  .member-name-block p{font-size:9.5px;color:var(--gray-400);margin-top:1px;line-height:1.5;}
  .member-id-pill{background:var(--navy);color:var(--gold-light);font-family:'Playfair Display',serif;font-size:10px;font-weight:600;padding:3px 12px;border-radius:20px;border:1px solid var(--gold);white-space:nowrap;}

  /* ── SECTION TITLE ── */
  .section-title{font-family:'Playfair Display',serif;font-size:8.5px;font-weight:700;text-transform:uppercase;letter-spacing:2px;color:var(--navy);background:var(--gray-200);padding:4px 26px;border-top:1px solid #ddd;border-bottom:1px solid #ddd;display:flex;align-items:center;gap:8px;}
  .section-title::after{content:'';flex:1;height:1px;background:linear-gradient(90deg,var(--gold),transparent);margin-left:6px;}

  /* ── ACCOUNT SUMMARY ── */
  .summary-grid{display:grid;grid-template-columns:repeat(5,1fr);padding:7px 26px;gap:7px;border-bottom:1px solid var(--gray-200);}
  .sum-card{background:var(--gray-100);border-radius:4px;padding:7px 8px;text-align:center;border:1px solid var(--gray-200);}
  .sum-card.highlight{background:linear-gradient(135deg,var(--navy),var(--navy-mid));border-color:var(--gold);box-shadow:0 2px 8px rgba(26,39,68,0.18);}
  .s-label{font-size:7.5px;font-weight:700;text-transform:uppercase;letter-spacing:0.8px;color:var(--gray-400);margin-bottom:2px;}
  .sum-card.highlight .s-label{color:rgba(255,255,255,0.6);}
  .s-value{font-family:'Playfair Display',serif;font-size:15px;font-weight:700;color:var(--navy);}
  .sum-card.highlight .s-value{color:var(--gold-light);font-size:16px;}

  /* ── SUBSCRIPTION GRIDS ── */
  .subs-grid{display:grid;grid-template-columns:repeat(9,1fr);padding:5px 26px 6px;gap:4px;border-bottom:1px solid var(--gray-200);}
  .sports-grid{display:grid;grid-template-columns:repeat(5,1fr) 1fr;padding:3px 26px 6px;gap:4px;border-bottom:1px solid var(--gray-200);}
  .sub-item{background:var(--gray-100);border:1px solid var(--gray-200);border-radius:3px;padding:4px 3px;text-align:center;}
  .si-label{font-size:7px;font-weight:700;text-transform:uppercase;letter-spacing:0.3px;color:var(--gray-400);margin-bottom:2px;line-height:1.2;}
  .si-value{font-family:'Playfair Display',serif;font-size:11px;font-weight:600;color:var(--navy-mid);}
  .sub-item.total-cell{background:var(--navy-light);border-color:var(--navy);}
  .sub-item.total-cell .si-value{color:var(--navy);font-size:12px;}

  /* ── WARNING ── */
  .warning-banner{margin:6px 26px;background:linear-gradient(135deg,var(--crimson),#6b1212);color:white;padding:6px 16px;border-radius:4px;text-align:center;font-family:'Playfair Display',serif;font-size:11px;font-weight:700;letter-spacing:1.5px;text-transform:uppercase;border:1px solid rgba(255,255,255,0.15);animation:pulse-warn 3s ease-in-out infinite;}
  @keyframes pulse-warn{0%,100%{box-shadow:0 2px 8px rgba(139,26,26,0.3);}50%{box-shadow:0 2px 16px rgba(139,26,26,0.55);}}

  /* ── TRANSACTION TABLE ── */
  .tx-wrap{padding:0 26px 8px;}
  .tx-table{width:100%;border-collapse:collapse;font-size:10.5px;}
  .tx-table thead tr{background:linear-gradient(135deg,var(--navy),var(--navy-mid));}
  .tx-table thead th{padding:6px 9px;text-align:left;font-size:8.5px;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:rgba(255,255,255,0.85);}
  .tx-table thead th.num{text-align:right;}
  .tx-table tbody tr{border-bottom:1px solid var(--gray-200);}
  .tx-table tbody tr.bbf-row td{background:var(--gold-pale);font-weight:600;font-style:italic;color:var(--navy);}
  .tx-table tbody tr:hover td{background:#f0f4fb;}
  .tx-table tbody tr.bbf-row:hover td{background:var(--gold-pale);}
  .tx-table td{padding:5px 9px;vertical-align:top;color:var(--gray-700);}
  .tx-date{font-size:10px;color:var(--navy);font-weight:500;white-space:nowrap;}
  .tx-ref{font-size:9.5px;color:var(--gray-400);font-family:'Courier New',monospace;display:block;}
  .num{text-align:right;font-variant-numeric:tabular-nums;}
  .debit-val{color:var(--crimson);font-weight:600;}
  .credit-val{color:#1a6b2a;font-weight:600;}
  .balance-val{color:var(--navy);font-weight:700;font-family:'Playfair Display',serif;}
  .closing-row td{background:linear-gradient(135deg,var(--navy),var(--navy-mid)) !important;color:white !important;font-weight:700 !important;border-top:2px solid var(--gold) !important;}
  .closing-row td .balance-val{color:var(--gold-light) !important;font-size:13px;}
  .no-data-row td{text-align:center;color:var(--gray-400);font-style:italic;padding:16px;}

  /* ── PAGE LABEL ── */
  .page-label{text-align:right;font-size:8.5px;color:var(--gray-400);padding:3px 26px 2px;}

  /* ── NOTE ── */
  .stmt-note{background:var(--gray-100);border-top:2px solid var(--gold);padding:6px 26px;font-size:9.5px;color:var(--gray-700);line-height:1.55;}
  .stmt-note strong{color:var(--navy);}

  /* ── PAYMENT SLIP ── */
  .payment-slip{margin:7px 26px 0;border:2px dashed var(--gold);border-radius:4px;overflow:hidden;}
  .slip-header{background:var(--navy);color:white;padding:5px 14px;font-size:9px;font-weight:700;text-transform:uppercase;letter-spacing:2px;display:flex;align-items:center;gap:8px;}
  .slip-header::before{content:'✂';font-size:11px;color:var(--gold-light);}
  .slip-body{padding:8px 14px;display:grid;grid-template-columns:1fr 1fr 1fr 1fr;gap:10px;align-items:end;}
  .slip-field label{display:block;font-size:7.5px;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:var(--gold);margin-bottom:2px;}
  .slip-value{font-family:'Playfair Display',serif;font-size:11px;font-weight:600;color:var(--navy);border-bottom:1.5px solid var(--gray-400);padding-bottom:2px;min-height:18px;}
  .slip-input{border:none;border-bottom:1.5px solid var(--gray-400);width:100%;outline:none;font-family:'Playfair Display',serif;font-size:11px;padding-bottom:2px;}
  .slip-amount{margin:0 14px 8px;background:var(--gold-pale);border:1px solid var(--gold);border-radius:3px;padding:6px 14px;display:flex;justify-content:space-between;align-items:center;}
  .slip-amount span:first-child{font-size:10px;font-weight:600;color:var(--navy);text-transform:uppercase;letter-spacing:1px;}
  .slip-amount span:last-child{font-family:'Playfair Display',serif;font-size:18px;font-weight:700;color:var(--crimson);}

  /* ── INSTRUCTIONS ── */
  .pay-instructions{padding:6px 26px 8px;}
  .pay-instructions h4{font-size:8.5px;font-weight:700;text-transform:uppercase;letter-spacing:1.5px;color:var(--navy);margin-bottom:3px;}
  .pay-instructions ol{margin-left:15px;font-size:9.5px;color:var(--gray-700);line-height:1.65;}

  /* ── ACTION BAR ── */
  .action-bar{display:flex;gap:10px;justify-content:center;padding:10px 26px 14px;border-top:1px solid var(--gray-200);background:var(--gray-100);}
  .btn{padding:8px 20px;border-radius:4px;border:none;font-family:'Source Sans 3',sans-serif;font-size:11.5px;font-weight:600;cursor:pointer;display:inline-flex;align-items:center;gap:6px;transition:all 0.2s;text-decoration:none;}
  .btn-print{background:linear-gradient(135deg,var(--navy),var(--navy-mid));color:white;box-shadow:0 3px 10px rgba(26,39,68,0.22);}
  .btn-print:hover{transform:translateY(-2px);box-shadow:0 5px 16px rgba(26,39,68,0.32);}
  .btn-gold{background:linear-gradient(135deg,var(--gold-light),var(--gold));color:var(--navy);box-shadow:0 3px 10px rgba(184,151,42,0.22);}
  .btn-gold:hover{transform:translateY(-2px);box-shadow:0 5px 16px rgba(184,151,42,0.38);}

  /* ── PLACEHOLDER ── */
  .no-statement{text-align:center;padding:48px 20px;color:var(--gray-400);font-family:'Playfair Display',serif;font-size:15px;}
  .no-statement span{font-size:36px;display:block;margin-bottom:12px;}

  /* ── PRINT ── */
  @media print{
    @page{size:A4 portrait;margin:8mm 10mm;}
    .search-bar,.action-bar{display:none !important;}
    body{background:white !important;padding:0 !important;}
    .page-wrap{width:100% !important;margin:0 !important;}
    .statement{box-shadow:none !important;border-radius:0 !important;}
    .statement::before{display:none;}
    .warning-banner{animation:none;box-shadow:none !important;}
    .tx-table tbody tr:hover td{background:transparent !important;}
  }
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<!-- ═══ SEARCH BAR ═══ -->
<div class="search-bar">

  <!-- ① Member No with live Autocomplete -->
  <label>Membership No.</label>
  <div class="ac-wrap">
    <asp:TextBox ID="txtMemberNo" runat="server" CssClass="search-input"
        placeholder="e.g. P-6158" autocomplete="off"
        onkeydown="if(event.key==='Enter'){document.getElementById('<%= btnSearch.ClientID %>').click();}" />
    <div id="acList" class="ac-list"></div>
  </div>

  <div class="bar-sep"></div>

  <!-- ② Date Range -->
  <label>From</label>
  <asp:TextBox ID="txtDateFrom" runat="server" CssClass="date-input" TextMode="Date" />
  <label>To</label>
  <asp:TextBox ID="txtDateTo"   runat="server" CssClass="date-input" TextMode="Date" />

  <div class="bar-sep"></div>

  <asp:Button ID="btnSearch" runat="server" Text="🔍 Load Statement"
      CssClass="btn-search" OnClick="btnSearch_Click" />
  <asp:Label ID="lblError" runat="server" CssClass="search-error" />
</div>

<!-- Autocomplete Script -->
<script>
    (function () {
        var inp = document.getElementById('<%= txtMemberNo.ClientID %>');
        var list = document.getElementById('acList');
        var timer;

        inp.addEventListener('input', function () {
            clearTimeout(timer);
            var q = this.value.trim();
            if (q.length < 1) { closeList(); return; }
            timer = setTimeout(function () {
                fetch('GymkhanaStatement.aspx?ac=1&q=' + encodeURIComponent(q), {
                    headers: { 'X-Requested-With': 'XMLHttpRequest' }
                })
                    .then(function (r) { return r.json(); })
                    .then(function (data) {
                        list.innerHTML = '';
                        if (!data || !data.length) { closeList(); return; }
                        data.forEach(function (m) {
                            var div = document.createElement('div');
                            div.className = 'ac-item';
                            div.innerHTML =
                                '<span class="ac-no">' + esc(m.MemberNo) + '</span>' +
                                '<span class="ac-name">' + esc(m.MemberName) + '</span>';
                            div.addEventListener('mousedown', function (e) {
                                e.preventDefault();
                                inp.value = m.MemberNo;
                                closeList();
                            });
                            list.appendChild(div);
                        });
                        list.classList.add('open');
                    });
            }, 200);
        });

        inp.addEventListener('keydown', function (e) {
            var items = list.querySelectorAll('.ac-item');
            var active = list.querySelector('.ac-active');
            var idx = Array.from(items).indexOf(active);
            if (e.key === 'ArrowDown') {
                e.preventDefault();
                if (active) active.classList.remove('ac-active');
                var next = items[idx + 1] || items[0];
                if (next) next.classList.add('ac-active');
            } else if (e.key === 'ArrowUp') {
                e.preventDefault();
                if (active) active.classList.remove('ac-active');
                var prev = items[idx - 1] || items[items.length - 1];
                if (prev) prev.classList.add('ac-active');
            } else if (e.key === 'Enter' && active) {
                inp.value = active.querySelector('.ac-no').textContent;
                closeList();
            } else if (e.key === 'Escape') {
                closeList();
            }
        });

        document.addEventListener('click', function (e) {
            if (!inp.contains(e.target) && !list.contains(e.target)) closeList();
        });

        function closeList() { list.classList.remove('open'); list.innerHTML = ''; }
        function esc(s) {
            return String(s)
                .replace(/&/g, '&amp;').replace(/</g, '&lt;')
                .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
        }
    })();
</script>

<!-- ═══ STATEMENT ═══ -->
<asp:Panel ID="pnlStatement" runat="server" Visible="false">
<div class="page-wrap">
<div class="statement">

  <!-- HEADER -->
  <div class="stmt-header">
    <div class="logo-emblem">🏛️</div>
    <div class="org-info">
      <h1>Lahore Gymkhana</h1>
      <span class="sub-addr">Upper Shahrah-e-Quaid-e-Azam &nbsp;·&nbsp; Lahore</span>
      <span class="stmt-type">Member Billing Statement</span>
      <span class="org-contact">
        <strong>Phone:</strong> 3575 6690-95 &nbsp;|&nbsp;
        <strong>Fax:</strong> 3575 6696-97 &nbsp;|&nbsp;
        www.lahoregymkhana.pk
      </span>
    </div>
    <div class="period-badge">
      <div class="pb-label">Statement Period</div>
      <div class="pb-val"><asp:Literal ID="litPeriodBadge" runat="server" /></div>
    </div>
  </div>

  <!-- META ROW -->
  <div class="meta-row">
    <div class="meta-cell">
      <div class="meta-label">Membership No.</div>
      <div class="meta-value"><asp:Literal ID="litMemberNo" runat="server" /></div>
    </div>
    <div class="meta-cell">
      <div class="meta-label">Billing Period</div>
      <div class="meta-value"><asp:Literal ID="litBillingMonth" runat="server" /></div>
    </div>
    <div class="meta-cell">
      <div class="meta-label">Statement Date</div>
      <div class="meta-value"><asp:Literal ID="litStatementDate" runat="server" /></div>
    </div>
    <div class="meta-cell" style="background:linear-gradient(135deg,#fff8e6,#fff3d0);border-left:2px solid var(--gold);">
      <div class="meta-label" style="color:var(--crimson);">Due Date</div>
      <div class="meta-value" style="color:var(--crimson);"><asp:Literal ID="litDueDate" runat="server" /></div>
    </div>
  </div>

  <!-- MEMBER INFO -->
  <div class="member-strip">
    <div class="member-name-block">
      <h2><asp:Literal ID="litMemberName" runat="server" /></h2>
      <p><asp:Literal ID="litAddress" runat="server" /><br/><asp:Literal ID="litPhone" runat="server" /></p>
    </div>
    <div class="member-id-pill"><asp:Literal ID="litMemberNoPill" runat="server" /></div>
  </div>

  <!-- ACCOUNT SUMMARY -->
  <div class="section-title">Account Summary</div>
  <div class="summary-grid">
    <div class="sum-card"><div class="s-label">Previous Balance</div><div class="s-value"><asp:Literal ID="litPrevBalance" runat="server" /></div></div>
    <div class="sum-card"><div class="s-label">Payment Received</div><div class="s-value" style="color:#1a6b2a;"><asp:Literal ID="litPaymentReceived" runat="server" /></div></div>
    <div class="sum-card"><div class="s-label">Bill Amount</div><div class="s-value"><asp:Literal ID="litBillAmount" runat="server" /></div></div>
    <div class="sum-card"><div class="s-label">Adjustments</div><div class="s-value"><asp:Literal ID="litAdjustments" runat="server" /></div></div>
    <div class="sum-card highlight"><div class="s-label">Due Amount</div><div class="s-value"><asp:Literal ID="litDueAmount" runat="server" /></div></div>
  </div>

  <!-- SUBSCRIPTION DETAIL -->
  <div class="section-title">Subscription Detail</div>
  <div class="subs-grid">
    <div class="sub-item"><div class="si-label">General Sub.</div><div class="si-value"><asp:Literal ID="litGenSub"     runat="server" /></div></div>
    <div class="sub-item"><div class="si-label">Library Sub.</div><div class="si-value"><asp:Literal ID="litLibSub"     runat="server" /></div></div>
    <div class="sub-item"><div class="si-label">Film Sub.</div>   <div class="si-value"><asp:Literal ID="litFilmSub"    runat="server" /></div></div>
    <div class="sub-item"><div class="si-label">Musical Eve.</div><div class="si-value"><asp:Literal ID="litMusical"    runat="server" /></div></div>
    <div class="sub-item"><div class="si-label">Utilities</div>   <div class="si-value"><asp:Literal ID="litUtilities"  runat="server" /></div></div>
    <div class="sub-item"><div class="si-label">Welfare Fund</div><div class="si-value"><asp:Literal ID="litWelfare"    runat="server" /></div></div>
    <div class="sub-item"><div class="si-label">Dev. Fund</div>   <div class="si-value"><asp:Literal ID="litDevFund"    runat="server" /></div></div>
    <div class="sub-item"><div class="si-label">Sport Total</div> <div class="si-value"><asp:Literal ID="litSportTotal" runat="server" /></div></div>
    <div class="sub-item total-cell"><div class="si-label">Sub. Total</div><div class="si-value"><asp:Literal ID="litSubTotal" runat="server" /></div></div>
  </div>

  <!-- SPORTS ROW -->
  <div class="sports-grid">
    <div class="sub-item"><div class="si-label">Sports</div> <div class="si-value"><asp:Literal ID="litSports"     runat="server" /></div></div>
    <div class="sub-item"><div class="si-label">Subs</div>   <div class="si-value"><asp:Literal ID="litSportsSubs" runat="server" /></div></div>
    <div class="sub-item"><div class="si-label">GST</div>    <div class="si-value"><asp:Literal ID="litGST"        runat="server" /></div></div>
    <div class="sub-item"><div class="si-label">Locker</div> <div class="si-value"><asp:Literal ID="litLocker"     runat="server" /></div></div>
    <div class="sub-item"><div class="si-label">Misc.</div>  <div class="si-value"><asp:Literal ID="litMisc"       runat="server" /></div></div>
    <div class="sub-item total-cell"><div class="si-label">Total</div><div class="si-value"><asp:Literal ID="litGrandTotal" runat="server" /></div></div>
  </div>

  <!-- WARNING -->
  <div class="warning-banner">⚠ &nbsp; Part Payment Shall Not Be Accepted &nbsp; ⚠</div>

  <!-- TRANSACTION LEDGER -->
  <div class="section-title">Transaction Ledger</div>
  <div class="tx-wrap" style="margin-top:5px;">
    <table class="tx-table">
      <thead>
        <tr>
          <th style="width:95px;">Date</th>
          <th>Particulars</th>
          <th style="width:130px;">Reference</th>
          <th class="num" style="width:80px;">Debit</th>
          <th class="num" style="width:80px;">Credit</th>
          <th class="num" style="width:90px;">Balance</th>
        </tr>
      </thead>
      <tbody>
        <tr class="bbf-row">
          <td></td>
          <td colspan="2">Balance Brought Forward</td>
          <td class="num">—</td>
          <td class="num">—</td>
          <td class="num"><span class="balance-val"><asp:Literal ID="litBBF" runat="server" /></span></td>
        </tr>

        <asp:Repeater ID="rptTransactions" runat="server">
          <ItemTemplate>
            <tr>
              <td><span class="tx-date"><%# Eval("TxDate", "{0:dd-MMM-yyyy}") %></span></td>
              <td><%# Eval("Particulars") %><span class="tx-ref"><%# Eval("SubRef") %></span></td>
              <td><span class="tx-ref"><%# Eval("Reference") %></span></td>
              <td class="num">
                <span class='<%# Convert.ToDecimal(Eval("Debit")) > 0 ? "debit-val" : "" %>'>
                  <%# Convert.ToDecimal(Eval("Debit")) > 0 ? string.Format("{0:N0}", Eval("Debit")) : "0" %>
                </span>
              </td>
              <td class="num">
                <span class='<%# Convert.ToDecimal(Eval("Credit")) > 0 ? "credit-val" : "" %>'>
                  <%# Convert.ToDecimal(Eval("Credit")) > 0 ? string.Format("{0:N0}", Eval("Credit")) : "0" %>
                </span>
              </td>
              <td class="num"><span class="balance-val"><%# string.Format("{0:N0}", Eval("RunningBalance")) %></span></td>
            </tr>
          </ItemTemplate>
        </asp:Repeater>

        <asp:Literal ID="litNoData" runat="server" />

        <tr class="closing-row">
          <td colspan="5" style="text-align:right;font-size:9px;letter-spacing:1px;padding-right:14px;">Closing Balance</td>
          <td class="num"><span class="balance-val"><asp:Literal ID="litClosingBalance" runat="server" /></span></td>
        </tr>
      </tbody>
    </table>
  </div>

  <div class="page-label">Page 1 of 1</div>

  <!-- FOOTER NOTE -->
  <div class="stmt-note">
    <strong>NOTE:</strong> The account shall automatically be blocked in case of non-payment within due date or exceeding fixed credit limit <strong>Rs.25,000/-</strong>, whichever comes first. After due date <strong>2% surcharge</strong> shall be levied on unpaid bill amount. Dress Regulations: <strong>www.lahoregymkhana.pk</strong>
  </div>

  <!-- PAYMENT SLIP -->
  <div class="payment-slip">
    <div class="slip-header">Payment Slip — Detach &amp; Attach with Payment Cheque</div>
    <div class="slip-body">
      <div class="slip-field"><label>Membership No.</label><div class="slip-value"><asp:Literal ID="litSlipMemberNo" runat="server" /></div></div>
      <div class="slip-field"><label>Member Name</label><div class="slip-value"><asp:Literal ID="litSlipName" runat="server" /></div></div>
      <div class="slip-field"><label>Statement Date</label><div class="slip-value"><asp:Literal ID="litSlipDate" runat="server" /></div></div>
      <div class="slip-field"><label>Cheque No.</label><input class="slip-input" type="text" placeholder="Enter cheque no." /></div>
    </div>
    <div class="slip-amount">
      <span>Amount Due</span>
      <span>Rs. <asp:Literal ID="litSlipDueAmount" runat="server" /></span>
    </div>
  </div>

  <!-- INSTRUCTIONS -->
  <div class="pay-instructions">
    <h4>Instructions to Pay</h4>
    <ol>
      <li>Enclose the PAYMENT SLIP to your payment cheque.</li>
      <li>Write your Membership No. and Name on the back of your payment cheque.</li>
      <li>Make your cheque payable to <strong>LAHORE GYMKHANA</strong>.</li>
      <li>Do not staple your cheque to your PAYMENT SLIP and do not forget to sign your cheque.</li>
    </ol>
  </div>

  <!-- ACTION BAR -->
  <div class="action-bar">
    <button class="btn btn-print" onclick="window.print()">🖨️ &nbsp; Print Statement</button>
    <button class="btn btn-gold"  onclick="window.print()">📥 &nbsp; Download PDF</button>
  </div>

</div>
</div>
</asp:Panel>

<!-- Placeholder -->
<asp:Panel ID="pnlEmpty" runat="server" Visible="true">
  <div class="page-wrap">
    <div class="no-statement">
      <span>🏛️</span>
      Enter a Membership No., select a date range and click <strong>Load Statement</strong>.
    </div>
  </div>
</asp:Panel>

</asp:Content>

