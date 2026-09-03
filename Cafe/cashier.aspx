<%@ Page Language="C#" AutoEventWireup="true" CodeFile="cashier.aspx.cs" Inherits="Casier" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=yes" />
    <title>Cashier Panel - Lahore Gymkhana</title>

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
            --gold:#C49A00;--gold-light:#FFFBEA;
            --sh1:0 1px 3px rgba(10,15,30,.07),0 1px 2px rgba(10,15,30,.05);
            --sh2:0 4px 12px rgba(10,15,30,.08),0 2px 4px rgba(10,15,30,.05);
            --sh3:0 12px 28px rgba(10,15,30,.1),0 4px 8px rgba(10,15,30,.06);
            --sh4:0 24px 48px rgba(10,15,30,.12);
            --r:10px;--r-sm:7px;--r-lg:14px;--r-xl:18px;
        }
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'Geist',system-ui,sans-serif;background:var(--surface);color:var(--ink);line-height:1.5;font-size:13.5px;}
        ::-webkit-scrollbar{width:5px;height:5px;}
        ::-webkit-scrollbar-track{background:transparent;}
        ::-webkit-scrollbar-thumb{background:var(--line-mid);border-radius:5px;}
        ::-webkit-scrollbar-thumb:hover{background:var(--blue-mid);}

        /* ── HEADER ── */
        .top-header{background:var(--ink);padding:0 24px;box-shadow:0 2px 16px rgba(10,15,30,.5);display:flex;justify-content:space-between;align-items:center;position:sticky;top:0;z-index:200;height:58px;border-bottom:1px solid rgba(255,255,255,.06);}
        .brand{display:flex;align-items:center;gap:10px;}
        .brand-icon{width:36px;height:36px;background:linear-gradient(135deg,var(--blue),var(--blue-mid));border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:16px;color:white;box-shadow:0 4px 12px rgba(24,69,212,.5);}
        .brand-name{color:white;font-size:.94rem;font-weight:800;letter-spacing:-.3px;}
        .brand-sub{color:rgba(255,255,255,.38);font-size:.63rem;letter-spacing:.8px;text-transform:uppercase;}
        .emp-pill{display:flex;align-items:center;gap:8px;background:rgba(255,255,255,.07);padding:5px 13px;border-radius:100px;border:1px solid rgba(255,255,255,.1);}
        .emp-pill i{color:rgba(255,255,255,.5);font-size:12px;}
        .emp-pill span{font-weight:700;color:white;font-size:.82rem;}
        .mgr-badge{background:linear-gradient(135deg,#F0B429,#D4820A);color:#1C1917;padding:2px 7px;border-radius:100px;font-size:8.5px;font-weight:800;margin-left:4px;letter-spacing:.5px;}
        .header-actions{display:flex;gap:5px;align-items:center;}
        .hdr-btn{padding:6px 13px;border-radius:7px;border:1px solid rgba(255,255,255,.1);font-weight:600;font-size:11px;cursor:pointer;transition:all .18s;display:flex;align-items:center;gap:5px;background:rgba(255,255,255,.08);color:rgba(255,255,255,.85);font-family:inherit;letter-spacing:.1px;}
        .hdr-btn:hover{background:rgba(255,255,255,.16);color:white;transform:translateY(-1px);}
        .hdr-btn.danger{background:rgba(212,43,43,.3);border-color:rgba(212,43,43,.4);}
        .hdr-btn.danger:hover{background:rgba(212,43,43,.55);}
        .hdr-btn.counter-close{background:rgba(212,130,10,.25);border-color:rgba(212,130,10,.4);}
        .hdr-btn.counter-close:hover{background:rgba(180,90,6,.5);}
        .live-dot{width:7px;height:7px;border-radius:50%;background:#22C55E;display:inline-block;animation:pulse 2s infinite;flex-shrink:0;}
        @keyframes pulse{0%{box-shadow:0 0 0 0 rgba(34,197,94,.6)}70%{box-shadow:0 0 0 5px rgba(34,197,94,0)}100%{box-shadow:0 0 0 0 rgba(34,197,94,0)}}
        #refreshCountdown{display:inline-flex;align-items:center;gap:5px;font-size:.67rem;color:rgba(255,255,255,.45);padding:4px 9px;border-radius:100px;background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.1);min-width:82px;}
        #refreshCountdown .cd-ring{width:9px;height:9px;border-radius:50%;border:1.5px solid rgba(34,197,94,.4);border-top-color:#22C55E;animation:spin .9s linear infinite;}

        .wrap{max-width:1640px;margin:0 auto;padding:18px 20px;}

        /* ── STATS ── */
        .stats-row{display:grid;grid-template-columns:repeat(6,1fr);gap:12px;margin-bottom:18px;}
        .stat-card{background:white;border-radius:var(--r-lg);padding:14px 16px;box-shadow:var(--sh1);border:1px solid var(--line);transition:transform .2s,box-shadow .2s;position:relative;overflow:hidden;}
        .stat-card::after{content:'';position:absolute;bottom:0;left:0;right:0;height:2.5px;}
        .stat-card.s-blue::after{background:linear-gradient(90deg,var(--blue),var(--blue-mid));}
        .stat-card.s-info::after{background:linear-gradient(90deg,#0284C7,#38BDF8);}
        .stat-card.s-purple::after{background:linear-gradient(90deg,var(--purple),#A855F7);}
        .stat-card.s-teal::after{background:linear-gradient(90deg,var(--teal),#14B8A6);}
        .stat-card.s-green::after{background:linear-gradient(90deg,var(--green),#4ADE80);}
        .stat-card.s-amber::after{background:linear-gradient(90deg,var(--amber),#FBBF24);}
        .stat-card:hover{transform:translateY(-2px);box-shadow:var(--sh2);}
        .stat-icon{width:34px;height:34px;border-radius:8px;display:flex;align-items:center;justify-content:center;margin-bottom:9px;}
        .stat-icon i{font-size:15px;}
        .si-blue{background:#EEF3FF;}.si-blue i{color:var(--blue);}
        .si-info{background:#F0F9FF;}.si-info i{color:#0284C7;}
        .si-purple{background:var(--purple-light);}.si-purple i{color:var(--purple);}
        .si-teal{background:var(--teal-light);}.si-teal i{color:var(--teal);}
        .si-green{background:var(--green-light);}.si-green i{color:var(--green);}
        .si-amber{background:var(--amber-light);}.si-amber i{color:var(--amber);}
        .stat-lbl{font-size:.62rem;color:var(--muted);text-transform:uppercase;letter-spacing:.8px;font-weight:700;}
        .stat-val{font-size:1.22rem;font-weight:800;color:var(--ink);line-height:1.2;margin-top:2px;letter-spacing:-.4px;}

        /* ── CARDS ── */
        .card{background:white;border-radius:var(--r-lg);box-shadow:var(--sh1);border:1px solid var(--line);margin-bottom:16px;overflow:hidden;}
        .card-head{background:linear-gradient(to right,#F7F9FF,white);padding:11px 18px;border-bottom:1px solid var(--line);display:flex;justify-content:space-between;align-items:center;}
        .card-head h3{font-size:.88rem;font-weight:800;color:var(--ink);display:flex;align-items:center;gap:7px;margin:0;}
        .card-head h3 i{color:var(--blue);font-size:13px;}
        .card-body{padding:16px 18px;}

        /* ── FILTER BAR ── */
        .filter-bar{display:grid;grid-template-columns:1fr 2fr auto;gap:14px;align-items:end;}
        .fg{display:flex;flex-direction:column;gap:5px;}
        .fg label{font-size:.67rem;font-weight:800;color:#475569;text-transform:uppercase;letter-spacing:.8px;display:flex;align-items:center;gap:5px;}
        .fg label i{color:var(--blue);font-size:10px;}
        .select-wrap{position:relative;}
        .select-wrap::after{content:'\f107';font-family:'Font Awesome 6 Free';font-weight:900;position:absolute;right:13px;top:50%;transform:translateY(-50%);color:var(--blue);pointer-events:none;font-size:12px;}
        .premium-select{width:100%;padding:10px 42px 10px 14px;border:1.5px solid var(--line);border-radius:var(--r);font-size:13.5px;font-weight:700;color:var(--ink);background:white;appearance:none;cursor:pointer;transition:all .2s;font-family:inherit;box-shadow:var(--sh1);height:42px;}
        .premium-select:focus{border-color:var(--blue);outline:none;box-shadow:0 0 0 3px rgba(24,69,212,.1);}
        .search-wrap{position:relative;}
        .search-wrap .search-icon{position:absolute;left:13px;top:50%;transform:translateY(-50%);color:var(--muted);font-size:13px;pointer-events:none;}
        .premium-search{width:100%;padding:10px 40px 10px 40px;border:1.5px solid var(--line);border-radius:var(--r);font-size:13.5px;font-weight:500;color:var(--ink);background:white;transition:all .2s;font-family:inherit;box-shadow:var(--sh1);height:42px;}
        .premium-search:focus{border-color:var(--blue);outline:none;box-shadow:0 0 0 3px rgba(24,69,212,.1);}
        .premium-search::placeholder{color:#94A3B8;font-weight:400;}
        .reset-btn{padding:0 18px;border-radius:var(--r);border:1.5px solid var(--line);font-weight:700;font-size:12px;cursor:pointer;background:white;color:var(--muted);display:inline-flex;align-items:center;gap:6px;white-space:nowrap;transition:all .2s;font-family:inherit;height:42px;}
        .reset-btn:hover{background:var(--blue);color:white;border-color:var(--blue);transform:translateY(-1px);}

        /* ── BILL CARDS ── */
        .bills-wrap{max-height:620px;overflow-y:auto;padding-right:3px;}
        .bill-card{background:white;border:1px solid var(--line);border-radius:var(--r);padding:13px 15px;margin-bottom:9px;transition:all .22s;display:flex;flex-wrap:wrap;align-items:center;gap:10px;position:relative;overflow:hidden;animation:fadeSlideIn .28s ease forwards;}
        @keyframes fadeSlideIn{from{opacity:0;transform:translateX(-6px);}to{opacity:1;transform:translateX(0);}}
        .bill-card::before{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;border-radius:0;}
        .bill-card.s-pending::before{background:var(--amber);}
        .bill-card.s-delivered::before{background:var(--green);}
        .bill-card:hover{border-color:var(--blue-mid);box-shadow:var(--sh2);transform:translateX(2px);}
        .bill-info{flex:1;display:flex;flex-wrap:wrap;gap:12px;align-items:center;}
        .bf{min-width:76px;}
        .bf .lbl{font-size:.59rem;color:var(--muted);text-transform:uppercase;letter-spacing:.5px;font-weight:700;margin-bottom:2px;}
        .bf .val{font-weight:700;color:var(--ink);font-size:.84rem;}
        .bf .val.id{color:var(--blue);font-weight:800;font-size:.9rem;}
        .bf .val.total{color:var(--green);font-size:.96rem;font-weight:800;}
        .bf .val.kot{color:#0284C7;font-weight:700;font-size:.8rem;}
        .bf .val.billno{color:#7B3F00;font-weight:700;font-family:'Geist Mono',monospace;font-size:.76rem;background:#FEF3E2;padding:2px 6px;border-radius:4px;border:1px solid #F5C9A0;}

        /* ── CONSOLIDATED BANNER on bill card ── */
        .consolidated-banner{background:linear-gradient(135deg,#EEF3FF,#F0F9FF);border:1px solid #C0CFFF;border-radius:6px;padding:5px 10px;display:flex;align-items:center;gap:7px;font-size:.72rem;font-weight:700;color:#1845D4;margin-bottom:4px;width:100%;}
        .consolidated-banner i{font-size:11px;}

        .badge{display:inline-block;padding:2px 8px;border-radius:100px;font-size:9.5px;font-weight:700;letter-spacing:.2px;}
        .b-member{background:#EEF3FF;color:#1845D4;border:1px solid #C0CFFF;}
        .b-guest{background:#FFF7ED;color:#B84A0A;border:1px solid #FDD8B0;}
        .b-affiliated{background:var(--green-light);color:#0D7A3E;border:1px solid #A7F0C8;}
        .b-default{background:#F3F5F9;color:#475569;border:1px solid var(--line);}
        .sbadge{display:inline-flex;align-items:center;gap:3px;padding:2px 8px;border-radius:100px;font-size:9.5px;font-weight:700;}
        .sb-delivered{background:var(--green-light);color:#0D7A3E;border:1px solid #A7F0C8;}
        .sb-pending{background:var(--amber-light);color:#956008;border:1px solid #FADED8;}
        .dept-pill{background:var(--blue);color:white;padding:2px 10px;border-radius:100px;font-size:.72rem;font-weight:700;display:inline-block;margin-left:7px;}

        .bill-actions{display:flex;gap:7px;align-items:center;flex-wrap:wrap;}
        .btn-finalize{height:38px;min-width:130px;background:linear-gradient(135deg,#075C30,var(--green));color:white;border:none;border-radius:var(--r);font-weight:700;font-size:11.5px;cursor:pointer;transition:all .22s;display:inline-flex;align-items:center;justify-content:center;gap:6px;box-shadow:0 3px 10px rgba(14,158,82,.3);white-space:nowrap;padding:0 14px;font-family:inherit;}
        .btn-finalize:hover:not(:disabled){transform:translateY(-2px);box-shadow:0 8px 20px rgba(14,158,82,.4);}
        .btn-finalize:disabled{background:linear-gradient(135deg,#CBD5E1,#94A3B8);box-shadow:none;cursor:not-allowed;opacity:.7;}
        .btn-gh{height:38px;min-width:100px;background:linear-gradient(135deg,#0A1A50,#1845D4);color:white;border:none;border-radius:var(--r);font-weight:700;font-size:11px;cursor:pointer;transition:all .22s;display:inline-flex;align-items:center;justify-content:center;gap:6px;white-space:nowrap;font-family:inherit;box-shadow:0 3px 10px rgba(24,69,212,.3);}
        .btn-gh:hover{transform:translateY(-2px);box-shadow:0 8px 18px rgba(24,69,212,.4);}
        .btn-pending-lock{height:38px;min-width:130px;background:#F3F5F9;color:var(--muted);border:1.5px dashed var(--line-mid);border-radius:var(--r);font-weight:600;font-size:11px;cursor:not-allowed;display:inline-flex;align-items:center;justify-content:center;gap:6px;white-space:nowrap;padding:0 14px;font-family:inherit;}

        .empty-state{text-align:center;padding:48px 20px;background:linear-gradient(135deg,#F7F9FF,#F1F5FF);border-radius:var(--r);border:2px dashed #C0CFFF;}
        .empty-state i{font-size:40px;color:#C0CFFF;margin-bottom:10px;display:block;}
        .empty-state h4{color:#1845D4;margin-bottom:5px;font-size:1rem;font-weight:800;}
        .empty-state p{color:var(--muted);font-size:.84rem;}

        /* ── MODAL ── */
        .modal-overlay{display:none;position:fixed;inset:0;background:rgba(10,15,30,.6);z-index:9999;align-items:center;justify-content:center;backdrop-filter:blur(6px);}
        .modal-overlay.active{display:flex;}
        .modal-box{background:white;border-radius:var(--r-xl);box-shadow:var(--sh4);width:90%;max-width:1080px;max-height:93vh;overflow-y:auto;animation:slideIn .28s cubic-bezier(.34,1.56,.64,1);border:1px solid rgba(255,255,255,.5);}
        .modal-head{background:linear-gradient(to right,#EEF3FF,white);padding:13px 20px;border-bottom:1px solid var(--line);display:flex;justify-content:space-between;align-items:center;position:sticky;top:0;z-index:10;border-radius:var(--r-xl) var(--r-xl) 0 0;}
        .modal-head h3{font-size:.95rem;font-weight:800;color:var(--ink);display:flex;align-items:center;gap:8px;margin:0;}
        .modal-head h3 i{color:var(--blue);}
        .modal-close{background:none;border:none;font-size:1rem;cursor:pointer;color:#94A3B8;width:30px;height:30px;display:flex;align-items:center;justify-content:center;border-radius:7px;transition:all .2s;}
        .modal-close:hover{background:var(--red-light);color:var(--red);}
        .modal-body{padding:18px 20px;}
        @keyframes slideIn{from{transform:scale(.92) translateY(-18px);opacity:0}to{transform:scale(1) translateY(0);opacity:1}}

        .kot-banner{background:linear-gradient(135deg,#EEF3FF,#F0F9FF);border:1.5px solid #C0CFFF;border-radius:var(--r);padding:11px 14px;margin-bottom:14px;display:flex;align-items:center;gap:11px;flex-wrap:wrap;}
        .kot-banner .ki{font-size:22px;color:var(--blue);flex-shrink:0;}
        .kot-banner .km{flex:1;min-width:200px;}
        .kot-banner .kt{font-size:.65rem;font-weight:800;color:var(--blue);text-transform:uppercase;letter-spacing:.6px;}
        .kot-banner .kl{font-size:.72rem;font-weight:500;color:#1845D4;margin-top:2px;word-break:break-all;}
        .kot-banner .kg{font-size:1.35rem;font-weight:800;color:var(--green);text-align:right;letter-spacing:-.5px;}
        .kot-group{margin-bottom:12px;border:1px solid var(--line);border-radius:var(--r);overflow:hidden;}
        .kot-gh{background:linear-gradient(135deg,#0A1A50,var(--blue));padding:10px 14px;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px;}
        .kot-gh .gl{color:white;font-weight:700;font-size:.82rem;}
        .kot-gh .gp{padding:3px 10px;border-radius:100px;font-size:.66rem;font-weight:700;}
        .gp.delivered{background:#A7F3D0;color:#065F46;}
        .gp.pending{background:#FDE68A;color:#78350F;}
        .wtable{width:100%;border-collapse:collapse;font-size:12px;}
        .wtable th{background:#F7F9FC;padding:8px 12px;font-weight:700;color:#475569;border-bottom:2px solid var(--line);text-align:left;font-size:10.5px;text-transform:uppercase;letter-spacing:.5px;}
        .wtable td{padding:8px 12px;border-bottom:1px solid #F0F4FA;}
        .wtable tbody tr:hover{background:#F7F9FC;}

        .cust-info{background:var(--blue-light);padding:10px;border-radius:var(--r);margin-bottom:14px;display:flex;align-items:center;justify-content:center;gap:8px;border:1px solid #C0CFFF;flex-wrap:wrap;}
        .cust-info i{color:var(--blue);font-size:1rem;}
        .cust-info span{font-weight:700;color:#1845D4;font-size:.92rem;}
        .total-disp{font-size:1.65rem;font-weight:800;color:var(--ink);text-align:center;padding:11px;background:linear-gradient(135deg,#EEF3FF,#F0F9FF);border-radius:var(--r);margin-bottom:14px;border:1.5px solid #C0CFFF;letter-spacing:-.8px;}
        .pmethods{display:grid;grid-template-columns:1fr 1fr 1fr;gap:10px;margin-bottom:14px;}
        .pmethod{background:white;border:1.5px solid var(--line);border-radius:var(--r);padding:14px 11px;text-align:center;cursor:pointer;transition:all .2s;position:relative;overflow:hidden;}
        .pmethod:hover{border-color:var(--blue-mid);transform:translateY(-2px);box-shadow:var(--sh2);}
        .pmethod.selected{border-color:var(--blue);background:var(--blue-light);box-shadow:0 4px 14px rgba(24,69,212,.12);}
        .pmethod i{font-size:24px;color:var(--blue);margin-bottom:6px;}
        .pmethod h6{font-weight:800;color:var(--ink);margin-bottom:2px;font-size:.86rem;}
        .pmethod small{color:var(--muted);font-size:.71rem;}

        .member-auto-notice{background:var(--green-light);border:1px solid #A7F0C8;border-radius:var(--r-sm);padding:8px 13px;display:flex;align-items:center;gap:7px;margin-bottom:9px;font-size:.8rem;color:#0D7A3E;font-weight:600;}
        .member-auto-notice i{color:var(--green);}
        .member-info{background:var(--blue-light);border:1.5px solid #C0CFFF;border-radius:var(--r);padding:12px;margin-top:8px;}
        .balance-row{display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px;margin-bottom:8px;}
        .balance-name{font-weight:700;font-size:.95rem;color:var(--ink);}
        .balance-chip{display:inline-flex;align-items:center;gap:5px;background:white;border:1px solid var(--line);border-radius:100px;padding:4px 12px;font-size:.8rem;}
        .balance-chip .bval{font-weight:800;font-family:'Geist Mono',monospace;}
        .balance-chip .bval.pos{color:var(--green);}
        .balance-chip .bval.neg{color:var(--red);}
        .balance-detail{background:rgba(0,0,0,.04);padding:8px 10px;border-radius:6px;font-size:.8rem;}
        .balance-detail .brow{display:flex;justify-content:space-between;padding:2px 0;}
        .balance-detail .brow .bk{color:var(--muted);}
        .balance-detail .brow .bv{font-weight:700;}

        .offer-box{background:linear-gradient(135deg,#EDFAF4,#D4F5E4);border:1.5px solid #86EFAC;border-radius:var(--r);padding:12px 14px;margin-top:10px;}
        .offer-box-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:6px;}
        .offer-title{font-weight:800;color:#0D7A3E;font-size:.88rem;display:flex;align-items:center;gap:6px;}
        .offer-title i{color:var(--green);}
        .offer-disc-amt{font-size:1.2rem;font-weight:800;color:var(--green);letter-spacing:-.4px;}
        .offer-detail-row{display:flex;flex-wrap:wrap;gap:8px;}
        .offer-chip{background:white;border:1px solid #A7F0C8;border-radius:100px;padding:3px 10px;font-size:.72rem;font-weight:700;color:#0D7A3E;display:inline-flex;align-items:center;gap:4px;}
        .offer-after{margin-top:7px;display:flex;justify-content:space-between;align-items:center;background:white;border-radius:7px;padding:7px 12px;border:1px solid #A7F0C8;}
        .offer-after .oa-lbl{font-size:.72rem;color:var(--muted);}
        .offer-after .oa-val{font-size:1.05rem;font-weight:800;color:var(--ink);}
        .offer-limit-warn{background:var(--amber-light);border:1.5px solid #FDE68A;border-radius:var(--r);padding:10px 14px;margin-top:10px;}
        .offer-limit-warn .ow-title{font-weight:800;color:#956008;font-size:.84rem;display:flex;align-items:center;gap:6px;margin-bottom:3px;}
        .offer-limit-warn .ow-msg{font-size:.77rem;color:#956008;}

        .card-type-row{display:flex;gap:9px;margin-bottom:11px;}
        .card-type-btn{flex:1;padding:8px 13px;border:1.5px solid var(--line);border-radius:var(--r-sm);background:white;font-weight:700;font-size:12px;cursor:pointer;transition:all .18s;display:flex;align-items:center;justify-content:center;gap:6px;color:#475569;font-family:inherit;}
        .card-type-btn:hover{border-color:var(--blue-mid);background:var(--blue-light);color:var(--blue);}
        .card-type-btn.active{border-color:var(--blue);background:var(--blue);color:white;}
        .card-validity{display:none;margin-top:5px;padding:6px 11px;border-radius:var(--r-sm);font-size:.76rem;font-weight:600;align-items:center;gap:5px;}
        .card-validity.valid{display:flex;background:var(--green-light);color:var(--green);border:1px solid #A7F0C8;}
        .card-validity.invalid{display:flex;background:var(--red-light);color:var(--red);border:1px solid #FECACA;}

        #cashSection{display:none;}
        .cash-display{background:linear-gradient(135deg,#EDFAF4,#D4F5E4);border:1.5px solid #86EFAC;border-radius:var(--r);padding:13px;text-align:center;margin-bottom:11px;}
        .cash-display .cash-amount{font-size:1.9rem;font-weight:800;color:var(--green);letter-spacing:-.8px;}
        .cash-display .cash-label{font-size:.76rem;color:#0D7A3E;font-weight:600;margin-top:2px;}

        .fg2{margin-bottom:12px;}
        .fg2 label{display:block;font-size:.74rem;font-weight:700;color:#475569;margin-bottom:5px;display:flex;align-items:center;gap:5px;}
        .fg2 label i{color:var(--blue);font-size:10px;}
        .finput{width:100%;padding:9px 12px;border:1.5px solid var(--line);border-radius:var(--r-sm);font-size:13px;transition:all .2s;font-family:inherit;color:var(--ink);background:white;}
        .finput:focus{border-color:var(--blue);outline:none;box-shadow:0 0 0 3px rgba(24,69,212,.08);}
        .finput[readonly]{background:#F7F9FC;cursor:not-allowed;color:#94A3B8;}
        .finput.err{border-color:var(--red);background:var(--red-light);}
        .finput.ok{border-color:var(--green);background:var(--green-light);}

        .debt-row{display:flex;gap:13px;margin-top:13px;}
        .debt-row .half{flex:1;}
        .debt-lbl{font-size:.74rem;font-weight:700;color:#475569;margin-bottom:5px;display:block;}
        .debt-disp{font-size:1.3rem;font-weight:800;color:var(--red);text-align:center;padding:9px;background:var(--red-light);border-radius:var(--r-sm);border:1px solid #FECACA;letter-spacing:-.4px;}
        .covers-info{display:inline-flex;align-items:center;gap:7px;background:var(--blue-light);border:1.5px solid #C0CFFF;border-radius:var(--r-sm);padding:7px 14px;font-weight:700;color:#1845D4;font-size:.95rem;}

        .pay-btn{width:100%;padding:13px;font-size:.96rem;font-weight:800;border:none;border-radius:var(--r);cursor:pointer;background:linear-gradient(135deg,#075C30,var(--green),#22C55E);color:white;display:flex;align-items:center;justify-content:center;gap:8px;transition:all .2s;margin-top:14px;font-family:inherit;box-shadow:0 4px 14px rgba(14,158,82,.28);}
        .pay-btn:hover:not(:disabled){transform:translateY(-1px);box-shadow:0 8px 20px rgba(14,158,82,.38);}
        .pay-btn:disabled{background:linear-gradient(135deg,#94A3B8,#CBD5E1);box-shadow:none;cursor:not-allowed;}
        .gh-pay-btn{width:100%;padding:13px;font-size:.96rem;font-weight:800;border:none;border-radius:var(--r);cursor:pointer;background:linear-gradient(135deg,#0A1A50,#1845D4,#4070F4);color:white;display:flex;align-items:center;justify-content:center;gap:8px;transition:all .2s;margin-top:9px;font-family:inherit;box-shadow:0 4px 14px rgba(24,69,212,.3);}
        .gh-pay-btn:hover:not(:disabled){transform:translateY(-1px);box-shadow:0 8px 20px rgba(24,69,212,.4);}
        #ghPaySection{display:none;margin-top:13px;}
        .gh-info-banner{background:linear-gradient(135deg,#EEF3FF,#F0F9FF);border:1.5px solid #C0CFFF;border-radius:var(--r);padding:13px 16px;margin-bottom:13px;text-align:center;}
        .gh-info-banner i{color:var(--blue);font-size:1.4rem;margin-bottom:5px;display:block;}
        .gh-info-banner p{color:#1845D4;font-weight:700;font-size:.9rem;margin:0;}
        .gh-info-banner small{color:var(--muted);font-size:.76rem;}

        .multi-kot-badge{display:inline-flex;align-items:center;gap:5px;background:linear-gradient(135deg,var(--amber),#F59E0B);color:white;padding:3px 10px;border-radius:100px;font-size:.72rem;font-weight:800;margin-left:8px;box-shadow:0 2px 6px rgba(212,130,10,.35);}
        .kot-summary-header{background:linear-gradient(135deg,var(--blue-light),#EEF3FF);border-radius:var(--r);padding:10px 14px;margin-bottom:12px;border:1px solid #C0CFFF;}

        .wbtn{padding:8px 15px;border-radius:7px;border:none;font-weight:700;font-size:12px;cursor:pointer;transition:all .2s;display:inline-flex;align-items:center;gap:6px;font-family:inherit;}
        .wbtn-primary{background:var(--blue);color:white;}
        .wbtn-primary:hover{background:var(--blue-dark);}

        .info-box{background:var(--amber-light);border:1.5px solid #FDE68A;border-radius:var(--r);padding:12px;margin-bottom:14px;text-align:center;}
        .loading-box{text-align:center;padding:26px;}
        .loading-box .fa-spinner{font-size:1.7rem;color:var(--blue);}
        .row2{display:flex;flex-wrap:wrap;gap:13px;}
        .col6{flex:1;min-width:130px;}
        .spinner{display:inline-block;width:15px;height:15px;border:2px solid rgba(255,255,255,.3);border-radius:50%;border-top-color:white;animation:spin .8s linear infinite;}
        @keyframes spin{to{transform:rotate(360deg)}}

        #updateProgress{display:none;position:fixed;bottom:22px;right:22px;background:rgba(10,15,30,.88);color:white;padding:9px 16px;border-radius:9px;font-size:12.5px;font-weight:600;z-index:9000;gap:7px;align-items:center;backdrop-filter:blur(8px);border:1px solid rgba(255,255,255,.1);box-shadow:var(--sh3);font-family:'Geist',sans-serif;}
        #updateProgress.visible{display:flex;}
        .up-spinner{width:13px;height:13px;border:2px solid rgba(255,255,255,.3);border-radius:50%;border-top-color:white;animation:spin .7s linear infinite;}

        @media(max-width:1200px){.stats-row{grid-template-columns:repeat(3,1fr);}}
        @media(max-width:768px){
            .top-header{flex-direction:column;gap:9px;height:auto;padding:10px;}
            .filter-bar{grid-template-columns:1fr;}
            .bill-card{flex-direction:column;align-items:flex-start;}
            .bill-info{width:100%;}
            .bill-actions{width:100%;justify-content:flex-end;}
            .stats-row{grid-template-columns:1fr 1fr;}
            .pmethods{grid-template-columns:1fr;}
            .modal-box{width:96%;max-height:96vh;}
            .modal-body{padding:13px;}
            .row2{flex-direction:column;}
            .card-type-row{flex-direction:column;}
            .kot-banner{flex-direction:column;text-align:center;}
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>

        <asp:UpdatePanel ID="upBills" runat="server" UpdateMode="Conditional">
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="timerRefresh" EventName="Tick" />
                <asp:AsyncPostBackTrigger ControlID="ddlDepartment" EventName="SelectedIndexChanged" />
                <asp:AsyncPostBackTrigger ControlID="txtSearchMember" EventName="TextChanged" />
            </Triggers>
            <ContentTemplate>
                <asp:Timer ID="timerRefresh" runat="server" Interval="8000" OnTick="timerRefresh_Tick" />
            </ContentTemplate>
        </asp:UpdatePanel>

        <asp:HiddenField ID="hdnEmpID" runat="server" />
        <asp:HiddenField ID="hdnEmployeeName" runat="server" />
        <asp:HiddenField ID="hdnIsManager" runat="server" />
        <asp:HiddenField ID="hdnDepartmentId" runat="server" />
        <asp:HiddenField ID="hdnDepartmentName" runat="server" />

        <!-- ════ HEADER ════ -->
        <div class="top-header">
            <div class="brand">
                <div class="brand-icon"><i class="fas fa-cash-register"></i></div>
                <div>
                    <div class="brand-name">Lahore Gymkhana</div>
                    <div class="brand-sub">Cashier Panel</div>
                </div>
            </div>
            <div class="emp-pill">
                <i class="fas fa-user-circle"></i>
                <span id="empDisplay" runat="server">Loading...</span>
                <span id="managerBadge" class="mgr-badge" style="display:none;">CASHIER</span>
                <span class="live-dot" title="Auto-refresh every 8 seconds"></span>
            </div>
            <div class="header-actions">
                <div id="refreshCountdown">
                    <span class="cd-ring"></span>
                    <span id="cdText">8s</span>
                </div>
                <button type="button" class="hdr-btn" onclick="printPaymentSummary()">
                    <i class="fas fa-print"></i> Summary
                </button>
                <asp:Button ID="btnGoCounterClose" runat="server"
                    CssClass="hdr-btn counter-close"
                    Text="🔒 Counter Close"
                    OnClick="btnGoCounterClose_Click"
                    UseSubmitBehavior="true" />
                <button type="button" class="hdr-btn danger" onclick="window.location='Login.aspx'">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </button>
            </div>
        </div>

        <div class="wrap">
            <!-- ════ STATS ════ -->
            <asp:UpdatePanel ID="upStats" runat="server" UpdateMode="Conditional">
                <Triggers>
                    <asp:AsyncPostBackTrigger ControlID="timerRefresh" EventName="Tick" />
                    <asp:AsyncPostBackTrigger ControlID="ddlDepartment" EventName="SelectedIndexChanged" />
                </Triggers>
                <ContentTemplate>
                    <div class="stats-row">
                        <div class="stat-card s-blue">
                            <div class="stat-icon si-blue"><i class="fas fa-rupee-sign"></i></div>
                            <div class="stat-lbl">Today's Sales</div>
                            <div class="stat-val"><asp:Label ID="lblTodaySales" runat="server" Text="Rs 0.00"></asp:Label></div>
                        </div>
                        <div class="stat-card s-info">
                            <div class="stat-icon si-info"><i class="fas fa-credit-card"></i></div>
                            <div class="stat-lbl">Card Payments</div>
                            <div class="stat-val"><asp:Label ID="lblTodayCard" runat="server" Text="Rs 0.00"></asp:Label></div>
                        </div>
                        <div class="stat-card s-purple">
                            <div class="stat-icon si-purple"><i class="fas fa-id-card"></i></div>
                            <div class="stat-lbl">Membership Card</div>
                            <div class="stat-val"><asp:Label ID="lblTodayMemberCard" runat="server" Text="Rs 0.00"></asp:Label></div>
                        </div>
                        <div class="stat-card s-teal">
                            <div class="stat-icon si-teal"><i class="fas fa-money-bill-wave"></i></div>
                            <div class="stat-lbl">Cash Payment</div>
                            <div class="stat-val"><asp:Label ID="lblTodayCash" runat="server" Text="Rs 0.00"></asp:Label></div>
                        </div>
                        <div class="stat-card s-green">
                            <div class="stat-icon si-green"><i class="fas fa-receipt"></i></div>
                            <div class="stat-lbl">Bills Paid Today</div>
                            <div class="stat-val"><asp:Label ID="lblTodayBills" runat="server" Text="0"></asp:Label></div>
                        </div>
                        <div class="stat-card s-amber">
                            <div class="stat-icon si-amber"><i class="fas fa-clock"></i></div>
                            <div class="stat-lbl">Active Members</div>
                            <div class="stat-val"><asp:Label ID="lblPendingBills" runat="server" Text="0"></asp:Label></div>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>

            <!-- ════ FILTER ════ -->
            <div class="card">
                <div class="card-head">
                    <h3><i class="fas fa-sliders-h"></i> Filter Bills</h3>
                    <span style="font-size:.72rem;color:var(--muted);display:flex;align-items:center;gap:5px;">
                        <span class="live-dot" style="width:6px;height:6px;"></span> Auto-refresh every 8s
                    </span>
                </div>
                <div class="card-body">
                    <div class="filter-bar">
                        <div class="fg">
                            <label><i class="fas fa-building"></i> Department</label>
                            <div class="select-wrap">
                                <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="premium-select"
                                    AutoPostBack="true" OnSelectedIndexChanged="ddlDepartment_SelectedIndexChanged">
                                    <asp:ListItem Text="-- Select Department --" Value="" />
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="fg">
                            <label><i class="fas fa-search"></i> Search by Member Number</label>
                            <div class="search-wrap">
                                <i class="fas fa-search search-icon"></i>
                                <asp:TextBox ID="txtSearchMember" runat="server" CssClass="premium-search"
                                    placeholder="Type member number to filter..." AutoPostBack="true"
                                    OnTextChanged="txtSearchMember_TextChanged">
                                </asp:TextBox>
                            </div>
                        </div>
                        <div class="fg">
                            <label style="visibility:hidden;">Reset</label>
                            <button type="button" class="reset-btn" onclick="location.reload()">
                                <i class="fas fa-redo-alt"></i> Reset
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ════ BILLS LIST (Consolidated per Member) ════ -->
            <asp:UpdatePanel ID="upBillsList" runat="server" UpdateMode="Conditional">
                <Triggers>
                    <asp:AsyncPostBackTrigger ControlID="timerRefresh" EventName="Tick" />
                    <asp:AsyncPostBackTrigger ControlID="ddlDepartment" EventName="SelectedIndexChanged" />
                    <asp:AsyncPostBackTrigger ControlID="txtSearchMember" EventName="TextChanged" />
                </Triggers>
                <ContentTemplate>
                    <div class="card">
                        <div class="card-head">
                            <h3><i class="fas fa-layer-group"></i> Active Orders — Consolidated per Member
                                <span class="dept-pill">
                                    <asp:Label ID="lblBillCount" runat="server" Text="0"></asp:Label> Members
                                </span>
                            </h3>
                            <div style="display:flex;gap:7px;align-items:center;">
                                <span class="sbadge sb-delivered"><i class="fas fa-check-circle"></i> All Delivered</span>
                                <span class="sbadge sb-pending"><i class="fas fa-clock"></i> Some Pending</span>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="bills-wrap">
                                <asp:Repeater ID="rptBills" runat="server" OnItemCommand="rptBills_ItemCommand">
                                    <ItemTemplate>
                                        <div class='bill-card s-<%# Eval("Status").ToString().ToLower() %>'>

                                            <%# Convert.ToInt32(Eval("BillCount")) > 1
                                                ? "<div class='consolidated-banner'><i class='fas fa-layer-group'></i> Consolidated: " + Eval("BillCount") + " KOTs for this member — will be paid as one bill</div>"
                                                : "" %>

                                            <div class="bill-info">
                                                <div class="bf"><div class="lbl">Member No</div><div class="val id"><%# Eval("MemberNo") %></div></div>
                                                <div class="bf"><div class="lbl">Bill Type</div><div class="val"><%# GetBillTypeBadge(Eval("bill_to").ToString()) %></div></div>
                                                <div class="bf"><div class="lbl">Status</div><div class="val"><%# GetStatusBadge(Eval("Status").ToString()) %></div></div>
                                                <%# ShowBillCount(Eval("BillCount"), Eval("DeliveredCount")) %>
                                                <%# ShowKOTNumber(Eval("KOT_Number")) %>
                                                <%# ShowRoomNumber(Eval("bill_to").ToString(), Eval("RoomNumber")) %>
                                                <div class="bf"><div class="lbl">Department</div><div class="val"><%# Eval("DepartmentName") %></div></div>
                                                <div class="bf"><div class="lbl">Table</div><div class="val"><%# Eval("TableNumber") %></div></div>
                                                <div class="bf"><div class="lbl">Covers</div><div class="val"><%# Eval("NumberOfCovers") %></div></div>
                                                <div class="bf"><div class="lbl">Total (All KOTs)</div><div class="val total"><%# "Rs " + string.Format("{0:0.00}", Eval("Total")) %></div></div>
                                            </div>

                                            <div class="bill-actions">
                                                <asp:Button ID="btnPayNow" runat="server"
                                                    CommandName='<%# Eval("bill_to").ToString() == "Guest House" ? "GHPay" : "Pay" %>'
                                                    CommandArgument='<%#
                                                        Eval("bill_to").ToString() == "Guest House"
                                                        ? Eval("Id")+"|"+Eval("MemberNo")+"|"+Eval("Total")+"|"+Eval("bill_to")+"|"+(Eval("RoomNumber")??"").ToString()+"|"+(Eval("KOT_Number")??"").ToString()+"|"+(Eval("BillNo")??"").ToString()+"|"+Eval("NumberOfCovers")
                                                        : Eval("Id")+"|"+Eval("MemberNo")+"|"+Eval("Total")+"|"+Eval("bill_to")+"|"+(Eval("KOT_Number")??"").ToString()+"|"+(Eval("BillNo")??"").ToString()+"|"+Eval("NumberOfCovers")
                                                    %>'
                                                    CssClass='<%#
                                                        Eval("Status").ToString() != "Delivered"
                                                        ? "btn-pending-lock"
                                                        : (Eval("bill_to").ToString() == "Guest House" ? "btn-gh" : "btn-finalize")
                                                    %>'
                                                    Enabled='<%# Eval("Status").ToString() == "Delivered" %>'
                                                    Text='<%#
                                                        Eval("Status").ToString() != "Delivered"
                                                        ? "⏳ Awaiting Delivery"
                                                        : (Eval("bill_to").ToString() == "Guest House"
                                                           ? "🏨 GH Bill"
                                                           : "✅ Finalize (" + Eval("BillCount") + " KOT" + (Convert.ToInt32(Eval("BillCount")) > 1 ? "s" : "") + ")")
                                                    %>'
                                                    ToolTip='<%#
                                                        Eval("Status").ToString() == "Pending"
                                                        ? "Cannot process — Not all orders delivered yet."
                                                        : "Process consolidated payment for all " + Eval("BillCount") + " KOT(s) — Total: Rs " + string.Format("{0:0.00}", Eval("Total"))
                                                    %>' />
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <%# (rptBills.Items.Count == 0 && ViewState["DepartmentSelected"] != null && (bool)ViewState["DepartmentSelected"] == true) ?
                                            "<div class='empty-state'><i class='fas fa-clipboard-check'></i><h4>No Active Bills</h4><p>No active bills found for the selected department.</p></div>" :
                                            (rptBills.Items.Count == 0 ?
                                            "<div class='empty-state'><i class='fas fa-building'></i><h4>Select a Department</h4><p>Please choose a department from the dropdown above to view active bills.</p></div>" : "") %>
                                    </FooterTemplate>
                                </asp:Repeater>
                            </div>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>

        <!-- ════════════════════════════════════════════════
             PAYMENT MODAL
        ════════════════════════════════════════════════ -->
        <div id="paymentModal" class="modal-overlay">
            <div class="modal-box">
                <div class="modal-head">
                    <h3 id="paymentModalTitle"><i class="fas fa-layer-group"></i> Consolidated Payment</h3>
                    <button class="modal-close" onclick="closeModal('paymentModal')"><i class="fas fa-times"></i></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="paymentBillId" />
                    <input type="hidden" id="selectedPaymentType" />
                    <input type="hidden" id="currentKotNumber" />
                    <input type="hidden" id="consolidatedBillIds" />
                    <input type="hidden" id="currentDepartmentName" />
                    <input type="hidden" id="currentDeptCode" />
                    <input type="hidden" id="selectedCardSubType" value="" />
                    <input type="hidden" id="isGHPayment" value="0" />

                    <!-- KOT summary banner -->
                    <div class="kot-banner">
                        <i class="fas fa-layer-group ki"></i>
                        <div class="km">
                            <div class="kt">Consolidated Bills for Member
                                <span class="multi-kot-badge" id="kotCountBadge" style="display:none;">
                                    <i class="fas fa-layer-group"></i> <span id="kotCountNum">0</span> KOTs
                                </span>
                            </div>
                            <div class="kl" id="kotBillsList">Loading...</div>
                        </div>
                        <div class="kg" id="kotGrandDisplay">Rs 0.00</div>
                    </div>

                    <div class="cust-info">
                        <i class="fas fa-user-circle"></i>
                        <span id="modalCustomerName">Guest</span>
                    </div>

                    <div id="billTypeInfo" style="display:none;"></div>

                    <div id="kotItemsContainer">
                        <div class="loading-box"><i class="fas fa-spinner fa-spin"></i><p style="margin-top:9px;color:var(--muted);">Loading KOTs...</p></div>
                    </div>

                    <div class="total-disp" id="modalTotal">Rs 0.00</div>

                    <div class="fg2" style="margin-bottom:14px;">
                        <label><i class="fas fa-users"></i> Number of Covers</label>
                        <div>
                            <span class="covers-info">
                                <i class="fas fa-user-friends"></i>
                                <span id="coversDisplay">1</span>
                                <span style="font-size:.74rem;color:var(--muted);font-weight:500;">person(s) dining</span>
                            </span>
                        </div>
                    </div>

                    <!-- Payment method buttons -->
                    <div id="paymentMethodsSection">
                        <div class="pmethods">
                            <div class="pmethod" id="pm_member" onclick="selectPaymentMethod(this,'MemberCard')">
                                <i class="fas fa-id-card"></i><h6>Membership Card</h6><small>Deduct from member account</small>
                            </div>
                            <div class="pmethod" id="pm_bank" onclick="selectPaymentMethod(this,'BankCard')">
                                <i class="fas fa-credit-card"></i><h6>Bank Card</h6><small>Debit / Credit Card</small>
                            </div>
                        </div>
                    </div>

                    <!-- Member Card Section -->
                    <div id="memberCardSection" style="display:none;">
                        <div class="member-auto-notice" id="memberAutoNotice">
                            <i class="fas fa-id-card"></i>
                            Member number auto-loaded. Validating...
                        </div>
                        <div class="fg2">
                            <label><i class="fas fa-id-card"></i> Membership Card Number / RFID</label>
                           <%-- <input type="text" id="memberCardNumber" class="finput"
                                   placeholder="Scan RFID or confirm member number"
                                   maxlength="50" autocomplete="off">--%>
                            <input type="text"
       id="memberCardNumber"
       runat="server"
       class="finput"
       placeholder="Scan RFID or confirm member number"
       maxlength="50"
       autocomplete="off">
                            <div style="font-size:.69rem;color:var(--muted);margin-top:3px;">
                                <i class="fas fa-info-circle"></i> Pre-filled from bill — re-scan RFID to override.
                            </div>
                        </div>
                        <div id="memberCardInfo" style="display:none;"></div>
                    </div>

                    <!-- Bank Card Section -->
                    <div id="bankCardSection" style="display:none;">
                        <div class="fg2">
                            <label><i class="fas fa-layer-group"></i> Card Type</label>
                            <div class="card-type-row">
                                <button type="button" class="card-type-btn" id="btnDebitCard" onclick="selectCardSubType('Debit')">
                                    <i class="fas fa-university"></i> Debit Card
                                </button>
                                <button type="button" class="card-type-btn" id="btnCreditCard" onclick="selectCardSubType('Credit')">
                                    <i class="fas fa-credit-card"></i> Credit Card
                                </button>
                            </div>
                        </div>
                        <div class="fg2">
                            <label><i class="fas fa-user"></i> Cardholder Name</label>
                            <input type="text" id="bankCardHolderName" class="finput"
                                   placeholder="Name printed on card" maxlength="100" autocomplete="off">
                        </div>
                        <div class="row2">
                            <div class="col6">
                                <div class="fg2">
                                    <label><i class="fas fa-credit-card"></i> Card Number</label>
                                    <input type="text" id="bankCardNumber" class="finput"
                                           placeholder="Enter card number" maxlength="23"
                                           oninput="onBankCardInput(this)" autocomplete="off">
                                    <div id="cardValidityMsg" class="card-validity"></div>
                                </div>
                            </div>
                            <div style="flex:0 0 130px;">
                                <div class="fg2">
                                    <label><i class="fas fa-calendar"></i> Expiry (MM/YY)</label>
                                    <input type="text" id="bankCardExpiry" class="finput"
                                           placeholder="MM/YY" maxlength="5"
                                           oninput="formatExpiry(this)" onblur="validateExpiry(this)">
                                    <span id="expiryError" style="color:var(--red);font-size:.73rem;display:none;margin-top:2px;">
                                        <i class="fas fa-exclamation-circle"></i> Invalid or expired date
                                    </span>
                                </div>
                            </div>
                        </div>
                        <div class="fg2">
                            <label><i class="fas fa-check-circle"></i> Authorization Code</label>
                            <input type="text" id="bankCardApprovalCode" class="finput"
                                   placeholder="6-digit authorization code" maxlength="6"
                                   oninput="this.value=this.value.replace(/[^0-9]/g,'')">
                        </div>
                        <div id="cardOfferSection" style="display:none;"></div>
                    </div>

                    <!-- Cash Section -->
                    <div id="cashSection">
                        <div class="cash-display">
                            <div class="cash-amount" id="cashAmountDisplay">Rs 0.00</div>
                            <div class="cash-label"><i class="fas fa-money-bill-wave"></i> &nbsp;Cash Amount to Collect</div>
                        </div>
                        <div class="fg2">
                            <label><i class="fas fa-hand-holding-usd"></i> Amount Tendered</label>
                            <input type="number" id="cashTendered" class="finput"
                                   placeholder="Enter amount received from customer"
                                   min="0" step="0.01" oninput="updateCashChange()">
                        </div>
                        <div id="cashChangeRow" style="display:none;margin-top:7px;">
                            <div style="display:flex;gap:11px;">
                                <div style="flex:1;background:var(--green-light);border:1.5px solid #A7F0C8;border-radius:var(--r-sm);padding:9px;text-align:center;">
                                    <div style="font-size:.68rem;color:#0D7A3E;font-weight:700;text-transform:uppercase;letter-spacing:.5px;margin-bottom:2px;">Change to Return</div>
                                    <div id="cashChangeAmount" style="font-size:1.35rem;font-weight:800;color:var(--green);">Rs 0.00</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="debt-row">
                        <div class="half">
                            <span class="debt-lbl">Amount to Pay</span>
                            <input type="number" id="modalSum" class="finput" value="0" min="0" step="0.01" readonly>
                        </div>
                        <div class="half">
                            <span class="debt-lbl">Remaining Balance</span>
                            <div class="debt-disp" id="modalDebtAmount">Rs 0.00</div>
                        </div>
                    </div>

                    <button type="button" class="pay-btn" id="acceptPayBtn" onclick="processPayment()">
                        <i class="fas fa-check-circle"></i> Accept Payment
                    </button>
                     <button type="button" class="pay-btn" id="sms" onclick="processsms()">
                        <i class="fas fa-check-circle"></i> SMS
                    </button>

                    <div id="ghPaySection">
                        <div class="gh-info-banner">
                            <i class="fas fa-hotel"></i>
                            <p>Guest House Bill</p>
                            <small>Click below to mark this bill as GH and generate a receipt.</small>
                        </div>
                        <button type="button" class="gh-pay-btn" id="ghMarkBtn" onclick="processGHPayment()">
                            <i class="fas fa-hotel"></i> Mark as Guest House (GH) &amp; Generate Receipt
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <div id="updateProgress">
            <span class="up-spinner"></span>
            <span>Refreshing...</span>
        </div>

        <script>
            // ── STATE ──
            var allKotItems = [], consolidatedBills = [], selectedPaymentType = '';
            var currentBillTotal = 0, currentMemberNo = '', currentBillTo = '', currentRoomNo = '';
            var currentKotNumber = '', currentBillNo = '', currentCardData = null, currentDiscountData = null;
            var isManager = false, currentCovers = 1, isGHPayment = false;

            // ── COUNTDOWN ──
            var cdMax = 8, cdVal = cdMax;
            function startCountdown() {
                clearInterval(window._cdTimer);
                cdVal = cdMax;
                document.getElementById('cdText').textContent = cdVal + 's';
                window._cdTimer = setInterval(function () {
                    cdVal--;
                    if (cdVal < 0) cdVal = cdMax;
                    document.getElementById('cdText').textContent = cdVal + 's';
                }, 1000);
            }

            var prm = Sys.WebForms.PageRequestManager.getInstance();
            prm.add_beginRequest(function () { document.getElementById('updateProgress').classList.add('visible'); });
            prm.add_endRequest(function () { document.getElementById('updateProgress').classList.remove('visible'); startCountdown(); });

            $(document).ready(function () {
                isManager = $("#<%= hdnIsManager.ClientID %>").val() === 'True';
                if (isManager) $("#managerBadge").show();
                var empName = $("#<%= hdnEmployeeName.ClientID %>").val();
                if (empName) $("#<%= empDisplay.ClientID %>").text(empName);
                initializeRFIDScanner();
                startCountdown();
            });

            function openModal(id) { var m = document.getElementById(id); if (m) { m.classList.add('active'); document.body.style.overflow = 'hidden'; } }
            function closeModal(id) { var m = document.getElementById(id); if (m) { m.classList.remove('active'); document.body.style.overflow = ''; } if (id === 'paymentModal') resetPaymentModal(); }
            document.addEventListener('click', function (e) { if (e.target.classList.contains('modal-overlay')) closeModal(e.target.id); });
            document.addEventListener('keydown', function (e) { if (e.key === 'Escape') { var a = document.querySelector('.modal-overlay.active'); if (a) closeModal(a.id); } });

            function deriveDeptCode(deptName) {
                if (!deptName || deptName === '-- Select Department --') return 'BR01';
                var prefix = deptName.replace(/[^a-zA-Z]/g, '').substring(0, 2).toUpperCase();
                return (prefix || 'BR') + '01';
            }

            // ════════════════════════════════════════════════
            // SHOW PAYMENT MODAL — triggered from server-side button
            // ════════════════════════════════════════════════
            function showPaymentModalDirect(billId, memberNo, total, items, billTo, roomNo, kotNo, billNo, numberOfCovers, passedDeptId, passedDeptName) {
                currentMemberNo   = memberNo || 'Guest';
                currentBillTo     = billTo   || 'Club Member';
                currentRoomNo     = roomNo   || '';
                currentKotNumber  = kotNo    || '';
                currentBillNo     = billNo   || '';
                currentCardData   = null;
                currentDiscountData = null;
                currentCovers     = parseInt(numberOfCovers) || 1;

                document.getElementById('paymentBillId').value    = billId;
                document.getElementById('currentKotNumber').value = kotNo || '';

                var deptId   = passedDeptId   || $("#<%= hdnDepartmentId.ClientID %>").val()   || '';
                var deptName = passedDeptName  || $("#<%= hdnDepartmentName.ClientID %>").val() || '';
                document.getElementById('currentDepartmentName').value = deptName;
                document.getElementById('coversDisplay').textContent   = currentCovers;
                document.getElementById('currentDeptCode').value       = deriveDeptCode(deptName);

                document.getElementById('kotItemsContainer').innerHTML =
                    '<div class="loading-box"><i class="fas fa-spinner fa-spin"></i><p style="margin-top:12px;color:var(--muted);">Loading all orders for member ' + memberNo + '...</p></div>';

                // Modal title
                var titleHtml = '<i class="fas fa-layer-group" style="margin-right:7px;"></i>Consolidated Payment';
                if (billTo === 'Guest House')        titleHtml = '<i class="fas fa-hotel" style="margin-right:7px;"></i>Guest House Bill — Room #' + roomNo;
                else if (billTo === 'Club Member')   titleHtml = '<i class="fas fa-id-card" style="margin-right:7px;"></i>Club Member | Consolidated';
                else if (billTo === 'Affiliated Member') titleHtml = '<i class="fas fa-handshake" style="margin-right:7px;"></i>Affiliated Member | Consolidated';
                document.getElementById('paymentModalTitle').innerHTML = titleHtml;

                // Customer info bar
                var custHtml = '<i class="fas fa-user-circle" style="color:var(--blue);font-size:1rem;"></i> &nbsp;Member: <strong>' + memberNo + '</strong>';
                if (billTo === 'Guest House' && roomNo) custHtml += ' <span style="background:#B84A0A;color:white;padding:2px 8px;border-radius:100px;margin-left:5px;">Room #' + roomNo + '</span>';
                document.getElementById('modalCustomerName').innerHTML = custHtml;

                // Payment method visibility by bill type
                if (billTo === 'Guest House') {
                    showOnlyBankCard('Guest House bills require Bank Card payment only.');
                    document.getElementById('acceptPayBtn').style.display = 'flex';
                    document.getElementById('ghPaySection').style.display = 'block';
                    isGHPayment = true;
                    document.getElementById('isGHPayment').value = '1';
                } else if (billTo === 'Club Member') {
                    showAllPaymentMethods();
                    isGHPayment = false;
                    document.getElementById('isGHPayment').value = '0';
                    document.getElementById('ghPaySection').style.display = 'none';
                    document.getElementById('acceptPayBtn').style.display = 'flex';
                    // Auto-select member card and validate
                    if (memberNo && memberNo !== 'Guest') {
                        setTimeout(function () {
                            var memberTab = document.getElementById('pm_member');
                            if (memberTab) {
                                selectPaymentMethod(memberTab, 'MemberCard');
                                var inp = document.getElementById('memberCardNumber');
                                if (inp) {
                                    inp.value = memberNo;
                                    var notice = document.getElementById('memberAutoNotice');
                                    if (notice) notice.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Validating membership card for ' + memberNo + '...';
                                    validateMemberCard(memberNo);
                                }
                            }
                        }, 350);
                    }
                } else if (billTo === 'Affiliated Member') {
                    showBankOnly('Affiliated Members can only pay with Bank Card.');
                    isGHPayment = false;
                    document.getElementById('isGHPayment').value = '0';
                    document.getElementById('ghPaySection').style.display = 'none';
                    document.getElementById('acceptPayBtn').style.display = 'flex';
                }

                openModal('paymentModal');
                // Load ALL KOTs for this member from this department
                loadMemberAllKOTs(memberNo, deptId, billId, total, items);
            }

            // ════════════════════════════════════════════════
            // LOAD ALL KOTs FOR MEMBER
            // ════════════════════════════════════════════════
            function loadMemberAllKOTs(memberNo, departmentId, singleBillId, singleTotal, singleItems) {
                $.ajax({
                    type: "POST", url: "Casier.aspx/GetMemberAllKOTs",
                    data: JSON.stringify({ memberNo: memberNo, departmentId: departmentId }),
                    contentType: "application/json; charset=utf-8", dataType: "json",
                    success: function (response) {
                        if (response && response.d && response.d.success) {
                            var data = response.d;
                            allKotItems       = data.items  || [];
                            consolidatedBills = data.bills  || [];
                            var grandTotal    = parseFloat(data.grandTotal) || 0;

                            var billIdArr = [];
                            consolidatedBills.forEach(function (b) { billIdArr.push(b.billId); });
                            document.getElementById('consolidatedBillIds').value = JSON.stringify(billIdArr);

                            // KOT count badge
                            var kotBadge = document.getElementById('kotCountBadge');
                            if (consolidatedBills.length > 1) {
                                kotBadge.style.display = 'inline-flex';
                                document.getElementById('kotCountNum').textContent = consolidatedBills.length + ' KOTs';
                            } else {
                                kotBadge.style.display = 'none';
                            }

                            // KOT list pills
                            var kotListHtml = '';
                            consolidatedBills.forEach(function (b, idx) {
                                if (idx > 0) kotListHtml += ' &bull; ';
                                kotListHtml += '<span style="background:var(--blue-mid);color:white;padding:2px 8px;border-radius:100px;font-size:10px;font-family:monospace;">'
                                    + (b.kotNo || 'KOT-' + b.billId) + '</span>';
                            });
                            document.getElementById('kotBillsList').innerHTML = '<i class="fas fa-list"></i> '
                                + consolidatedBills.length + ' Order(s): ' + kotListHtml;
                            document.getElementById('kotGrandDisplay').textContent = 'Rs ' + grandTotal.toFixed(2);

                            currentBillTotal = grandTotal;
                            document.getElementById('modalTotal').textContent   = 'Rs ' + grandTotal.toFixed(2);
                            document.getElementById('modalSum').value            = grandTotal.toFixed(2);
                            document.getElementById('cashAmountDisplay').textContent = 'Rs ' + grandTotal.toFixed(2);
                            updateDebtAmount();
                            renderKotGroupedItems(data.bills, data.items);
                        } else {
                            fallbackSingleBill(singleBillId, singleTotal, singleItems);
                        }
                    },
                    error: function () { fallbackSingleBill(singleBillId, singleTotal, singleItems); }
                });
            }

            function fallbackSingleBill(singleBillId, singleTotal, singleItems) {
                var formattedItems = [];
                if (singleItems && singleItems.length > 0) {
                    for (var i = 0; i < singleItems.length; i++) {
                        var item = singleItems[i];
                        formattedItems.push({
                            BillId: parseInt(singleBillId),
                            Name: item.Name || item.name,
                            Quantity: item.Quantity || item.quantity,
                            Price: item.Price || item.price,
                            ItemTotal: item.ItemTotal || item.itemTotal || ((item.Price || item.price || 0) * (item.Quantity || item.quantity || 0)),
                            ItemCode: item.ItemCode || item.itemCode || ''
                        });
                    }
                }
                allKotItems       = formattedItems;
                consolidatedBills = [{ billId: parseInt(singleBillId), kotNo: currentKotNumber, total: parseFloat(singleTotal), billNo: currentBillNo, status: 'Delivered', covers: currentCovers }];
                document.getElementById('consolidatedBillIds').value = JSON.stringify([parseInt(singleBillId)]);
                document.getElementById('kotCountBadge').style.display = 'none';
                currentBillTotal = parseFloat(singleTotal) || 0;
                document.getElementById('modalTotal').textContent   = 'Rs ' + currentBillTotal.toFixed(2);
                document.getElementById('modalSum').value            = currentBillTotal.toFixed(2);
                document.getElementById('cashAmountDisplay').textContent = 'Rs ' + currentBillTotal.toFixed(2);
                updateDebtAmount();
                document.getElementById('kotBillsList').innerHTML   = '<i class="fas fa-receipt"></i> #' + singleBillId;
                document.getElementById('kotGrandDisplay').textContent = 'Rs ' + currentBillTotal.toFixed(2);
                renderKotGroupedItems(consolidatedBills, formattedItems);
            }

            function renderKotGroupedItems(bills, items) {
                var container = document.getElementById('kotItemsContainer');
                var billItemMap = {};
                if (items && items.length > 0) {
                    items.forEach(function (item) {
                        var bid = item.BillId || item.billId;
                        if (!billItemMap[bid]) billItemMap[bid] = [];
                        billItemMap[bid].push(item);
                    });
                }
                var html = '', grandTotal = 0;
                var deliveredCount = 0, pendingCount = 0;

                if (bills && bills.length > 0) {
                    bills.forEach(function (bill) {
                        if (bill.status === 'Delivered') deliveredCount++;
                        else if (bill.status === 'Pending') pendingCount++;
                        grandTotal += parseFloat(bill.total) || 0;
                    });

                    html += '<div class="kot-summary-header"><div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px;">';
                    html += '<div><i class="fas fa-layer-group" style="color:var(--blue);margin-right:6px;"></i><strong>' + bills.length + ' Order(s)</strong>';
                    if (deliveredCount > 0) html += ' <span class="sbadge sb-delivered" style="margin-left:6px;"><i class="fas fa-check-circle"></i> ' + deliveredCount + ' Delivered</span>';
                    if (pendingCount > 0) html += ' <span class="sbadge sb-pending"><i class="fas fa-clock"></i> ' + pendingCount + ' Pending</span>';
                    html += '</div><div style="font-size:11px;color:var(--muted);"><i class="fas fa-info-circle"></i> All consolidated into one payment</div></div></div>';

                    bills.forEach(function (bill) {
                        var bid = bill.billId, kotNo = bill.kotNo || 'N/A', status = bill.status || 'Delivered';
                        var orderTime = bill.orderTime || '', tableNo = bill.tableNo || '', billNo = bill.billNo || '';
                        var items2 = billItemMap[bid] || [], subTotal = 0;
                        var statusClass = status.toLowerCase() === 'delivered' ? 'delivered' : 'pending';

                        html += '<div class="kot-group"><div class="kot-gh">';
                        html += '<span class="gl"><i class="fas fa-receipt" style="margin-right:6px;"></i>KOT: ' + kotNo;
                        if (billNo) html += ' <span style="background:rgba(255,255,255,.2);padding:2px 8px;border-radius:100px;font-family:monospace;font-size:10px;margin-left:6px;">#' + billNo + '</span>';
                        if (orderTime) html += ' <span style="background:rgba(255,255,255,.15);padding:2px 8px;border-radius:100px;font-size:10px;margin-left:6px;"><i class="far fa-clock"></i> ' + orderTime + '</span>';
                        html += '</span>';
                        html += '<span><span class="gp ' + statusClass + '">' + status + '</span>';
                        if (tableNo) html += ' <span style="background:rgba(255,255,255,.15);padding:3px 8px;border-radius:100px;font-size:10px;margin-left:6px;"><i class="fas fa-chair"></i> Table ' + tableNo + '</span>';
                        html += '</span></div>';

                        html += '<table class="wtable"><thead><tr><th>Item</th><th style="text-align:center;width:60px;">Qty</th><th style="text-align:right;width:80px;">Rate</th><th style="text-align:right;width:90px;">Amount</th></tr></thead><tbody>';
                        if (items2.length > 0) {
                            items2.forEach(function (item) {
                                var iTotal   = parseFloat(item.ItemTotal || item.itemTotal || 0);
                                subTotal    += iTotal;
                                var itemName = item.Name || item.name || '';
                                var itemCode = item.ItemCode || item.itemCode || '';
                                html += '<tr><td><strong>' + itemName + '</strong>';
                                if (itemCode) html += '<br><span style="font-size:9px;color:#7A85A0;">Code: ' + itemCode + '</span>';
                                html += '</td><td style="text-align:center;">' + (item.Quantity || item.quantity || 0) + '</td>';
                                html += '<td style="text-align:right;">Rs ' + parseFloat(item.Price || item.price || 0).toFixed(2) + '</td>';
                                html += '<td style="text-align:right;font-weight:600;">Rs ' + iTotal.toFixed(2) + '</td></tr>';
                            });
                        } else {
                            html += '<tr><td colspan="4" style="padding:20px;text-align:center;color:var(--muted);">No items found</td></tr>';
                        }
                        html += '<tr style="background:#EEF3FF;"><td colspan="3" style="padding:8px 12px;text-align:right;font-weight:700;">KOT Subtotal:</td>';
                        html += '<td style="padding:8px 12px;text-align:right;font-weight:700;color:var(--green);">Rs ' + subTotal.toFixed(2) + '</td></tr>';
                        html += '</tbody></table></div>';
                    });

                    html += '<div style="background:linear-gradient(135deg,var(--green-light),#F2FEF7);border:1.5px solid #A7F0C8;border-radius:var(--r);padding:14px 18px;margin-top:8px;display:flex;justify-content:space-between;align-items:center;">';
                    html += '<div><i class="fas fa-calculator" style="color:var(--green);font-size:18px;margin-right:8px;"></i><span style="font-weight:600;">Grand Total (' + bills.length + ' KOT' + (bills.length > 1 ? 's' : '') + ')</span></div>';
                    html += '<div><span style="font-size:20px;font-weight:800;color:var(--green);">Rs ' + grandTotal.toFixed(2) + '</span></div></div>';
                } else {
                    html = '<div class="empty-state" style="padding:30px;text-align:center;"><i class="fas fa-receipt" style="font-size:40px;color:var(--line-mid);margin-bottom:10px;"></i><h4>No Items Found</h4></div>';
                }
                container.innerHTML = html;
            }

            function showOnlyBankCard(msg) {
                document.querySelectorAll('.pmethod').forEach(function (m) { m.style.display = 'none'; });
                var bankBtn = document.getElementById('pm_bank');
                if (bankBtn) { bankBtn.style.display = 'block'; setTimeout(function () { selectPaymentMethod(bankBtn, 'BankCard'); }, 100); }
                var infoDiv = document.getElementById('billTypeInfo');
                infoDiv.style.display = 'block'; infoDiv.className = 'info-box';
                infoDiv.innerHTML = '<i class="fas fa-info-circle" style="color:var(--amber);"></i><br><strong style="color:var(--amber);">' + msg + '</strong>';
            }

            function showBankOnly(msg) {
                document.getElementById('pm_member').style.display = 'none';
                document.getElementById('pm_bank').style.display   = 'block';
                var infoDiv = document.getElementById('billTypeInfo');
                infoDiv.style.display = 'block'; infoDiv.className = 'info-box';
                infoDiv.innerHTML = '<i class="fas fa-info-circle" style="color:var(--amber);"></i><br><strong style="color:var(--amber);">' + msg + '</strong>';
            }

            function showAllPaymentMethods() {
                document.querySelectorAll('.pmethod').forEach(function (m) { m.style.display = 'block'; });
                var infoDiv = document.getElementById('billTypeInfo');
                if (infoDiv) infoDiv.style.display = 'none';
            }

            function resetPaymentModal() {
                document.querySelectorAll('.pmethod').forEach(function (m) { m.classList.remove('selected'); m.style.display = 'block'; });
                document.getElementById('selectedPaymentType').value = '';
                selectedPaymentType = '';
                ['memberCardSection','bankCardSection','cashSection','memberCardInfo','billTypeInfo','ghPaySection','cardOfferSection'].forEach(function (id) {
                    var el = document.getElementById(id); if (el) el.style.display = 'none';
                });
                document.getElementById('paymentMethodsSection').style.display = 'block';
                document.getElementById('acceptPayBtn').style.display = 'flex';
                ['memberCardNumber','bankCardNumber','bankCardHolderName','bankCardExpiry','bankCardApprovalCode','cashTendered'].forEach(function (id) {
                    var el = document.getElementById(id); if (el) el.value = '';
                });
                document.getElementById('expiryError').style.display = 'none';
                document.getElementById('selectedCardSubType').value = '';
                document.getElementById('isGHPayment').value = '0';
                document.getElementById('cashChangeRow').style.display = 'none';
                document.getElementById('kotCountBadge').style.display = 'none';
                isGHPayment = false;
                ['btnDebitCard','btnCreditCard'].forEach(function (id) { document.getElementById(id).classList.remove('active'); });
                var cv = document.getElementById('cardValidityMsg');
                if (cv) { cv.className = 'card-validity'; cv.textContent = ''; }
                currentCardData = null; currentDiscountData = null;
                updateDebtAmount();
                var notice = document.getElementById('memberAutoNotice');
                if (notice) {
                    notice.innerHTML = '<i class="fas fa-id-card"></i> Member number auto-loaded. Validating...';
                    notice.style.background = ''; notice.style.borderColor = ''; notice.style.color = '';
                }
            }

            function selectPaymentMethod(el, type) {
                document.querySelectorAll('.pmethod').forEach(function (m) { m.classList.remove('selected'); });
                el.classList.add('selected');
                document.getElementById('selectedPaymentType').value = type;
                selectedPaymentType = type;
                ['memberCardSection','bankCardSection','cashSection','cardOfferSection'].forEach(function (id) {
                    var e2 = document.getElementById(id); if (e2) e2.style.display = 'none';
                });
                ['bankCardNumber','bankCardHolderName','bankCardExpiry','bankCardApprovalCode'].forEach(function (id) {
                    var e2 = document.getElementById(id); if (e2) e2.value = '';
                });
                document.getElementById('expiryError').style.display = 'none';
                document.getElementById('selectedCardSubType').value = '';
                ['btnDebitCard','btnCreditCard'].forEach(function (id) { document.getElementById(id).classList.remove('active'); });
                var cv = document.getElementById('cardValidityMsg');
                if (cv) { cv.className = 'card-validity'; cv.textContent = ''; }
                currentDiscountData = null;
                updateDebtAmount();

                if (type === 'MemberCard') {
                    document.getElementById('memberCardSection').style.display = 'block';
                    var inp = document.getElementById('memberCardNumber');
                    if (inp && !inp.value.trim()) setTimeout(function () { inp.focus(); }, 300);
                } else if (type === 'BankCard') {
                    document.getElementById('bankCardSection').style.display = 'block';
                } else if (type === 'Cash') {
                    document.getElementById('cashSection').style.display = 'block';
                }
            }

            function updateCashChange() {
                var billTotal = currentBillTotal;
                var disc      = (currentDiscountData && currentDiscountData.success) ? parseFloat(currentDiscountData.discount_amount) : 0;
                var finalAmt  = billTotal - disc;
                var tendered  = parseFloat(document.getElementById('cashTendered').value) || 0;
                var change    = tendered - finalAmt;
                if (tendered > 0) {
                    document.getElementById('cashChangeRow').style.display = 'block';
                    document.getElementById('cashChangeAmount').textContent = 'Rs ' + (change > 0 ? change.toFixed(2) : '0.00');
                    document.getElementById('cashChangeAmount').style.color = change >= 0 ? 'var(--green)' : 'var(--red)';
                } else {
                    document.getElementById('cashChangeRow').style.display = 'none';
                }
            }

            function selectCardSubType(subType) {
                document.getElementById('selectedCardSubType').value = subType;
                document.getElementById('btnDebitCard').classList.toggle('active', subType === 'Debit');
                document.getElementById('btnCreditCard').classList.toggle('active', subType === 'Credit');
                var raw = document.getElementById('bankCardNumber').value.replace(/[\s\-]/g, '');
                if (raw.length >= 4) showCardValidity(raw);
            }

            function showCardValidity(raw) {
                var el  = document.getElementById('cardValidityMsg');
                var inp = document.getElementById('bankCardNumber');
                if (!el) return;
                if (raw.length === 0) { el.className = 'card-validity'; el.textContent = ''; inp.classList.remove('err','ok'); return; }
                if (!/^\d+$/.test(raw)) {
                    el.className = 'card-validity invalid';
                    el.innerHTML = '<i class="fas fa-times-circle"></i> Digits only';
                    inp.classList.remove('ok'); inp.classList.add('err');
                    document.getElementById('cardOfferSection').style.display = 'none';
                    currentDiscountData = null;
                    return;
                }
                el.className = 'card-validity valid';
                el.innerHTML = '<i class="fas fa-check-circle"></i> Card number accepted';
                inp.classList.remove('err'); inp.classList.add('ok');
                checkCardDiscount(raw);
            }

            function formatBankCardNumber(input) {
                var raw = input.value.replace(/\D/g, ''), f = '';
                for (var i = 0; i < raw.length; i++) { if (i > 0 && i % 4 === 0) f += '-'; f += raw[i]; }
                input.value = f;
            }

            function onBankCardInput(input) {
                formatBankCardNumber(input);
                var raw = input.value.replace(/[\s\-]/g, '');
                showCardValidity(raw);
            }

            function formatExpiry(input) {
                var v = input.value.replace(/\D/g, '');
                input.value = v.length >= 2 ? v.slice(0, 2) + '/' + v.slice(2, 4) : v;
                document.getElementById('expiryError').style.display = 'none';
                input.classList.remove('err');
            }

            function validateExpiry(input) {
                var val = input.value.trim(), errEl = document.getElementById('expiryError');
                if (!val || val.length < 5) return true;
                var parts = val.split('/');
                if (parts.length !== 2) { showExpiryError(input, errEl); return false; }
                var mm = parseInt(parts[0]), yy = parseInt(parts[1]);
                if (isNaN(mm) || isNaN(yy) || mm < 1 || mm > 12) { showExpiryError(input, errEl); return false; }
                var now = new Date(), nowY = now.getFullYear() % 100, nowM = now.getMonth() + 1;
                if (yy < nowY || (yy === nowY && mm < nowM)) { showExpiryError(input, errEl); return false; }
                errEl.style.display = 'none'; input.classList.remove('err');
                return true;
            }
            function showExpiryError(input, errEl) { input.classList.add('err'); errEl.style.display = 'block'; }

            // ════════════════════════════════════════════════
            // MEMBER CARD VALIDATION
            // ════════════════════════════════════════════════
            function validateMemberCard(cardNumber) {
                if (!cardNumber || cardNumber.trim() === '') return;
                var inp     = document.getElementById('memberCardNumber');
                var infoDiv = document.getElementById('memberCardInfo');
                var notice  = document.getElementById('memberAutoNotice');
                inp.style.background = '#FFF7ED'; inp.disabled = true;
                infoDiv.style.display = 'block';
                infoDiv.className     = 'member-info';
                infoDiv.innerHTML     = '<div style="text-align:center;padding:9px;"><i class="fas fa-spinner fa-spin"></i> Validating card...</div>';

                $.ajax({
                    type: "POST", url: "Cashier.aspx/ValidateMemberCard",
                    data: JSON.stringify({ cardNumber: cardNumber }),
                    contentType: "application/json; charset=utf-8", dataType: "json",
                    success: function (response) {
                        inp.style.background = ''; inp.disabled = false;
                        if (response && response.d && response.d.success) {
                            var r       = response.d;
                            var balance = parseFloat(r.balance) || 0;
                            currentCardData = {
                                balance: balance,
                                name: r.Name,
                                memberNo: r.MemberNo || r.Memberid,
                                cardNo: r.CardNo,
                                totalDept: parseFloat(r.totalDept)   || 0,
                                totalCredit: parseFloat(r.totalCredit) || 0
                            };
                            renderMemberCardInfo(r, balance);
                            if (notice) {
                                notice.innerHTML = '<i class="fas fa-check-circle"></i> Card validated — <strong>' + r.Name + '</strong>';
                                notice.style.background  = '';
                                notice.style.borderColor = '';
                                notice.style.color       = '';
                            }
                        } else {
                            currentCardData = null;
                            if (notice) {
                                notice.innerHTML = '<i class="fas fa-exclamation-circle"></i> ' + ((response.d && response.d.message) || 'Card not found.');
                                notice.style.background  = 'var(--red-light)';
                                notice.style.borderColor = '#FECACA';
                                notice.style.color       = 'var(--red)';
                            }
                            infoDiv.innerHTML = '<div style="color:var(--red);text-align:center;padding:8px;"><i class="fas fa-exclamation-triangle"></i> ' + ((response.d && response.d.message) || 'Card not found or invalid.') + '</div>';
                        }
                    },
                    error: function () {
                        inp.style.background = ''; inp.disabled = false; currentCardData = null;
                        infoDiv.innerHTML = '<div style="color:var(--red);text-align:center;"><i class="fas fa-exclamation-triangle"></i> Error validating. Please try again.</div>';
                    }
                });
            }

            function renderMemberCardInfo(r, balance) {
                var infoDiv     = document.getElementById('memberCardInfo');
                var billTotal   = currentBillTotal;
                var discAmt     = (currentDiscountData && currentDiscountData.success) ? parseFloat(currentDiscountData.discount_amount) : 0;
                var finalAmt    = billTotal - discAmt;
                var balAfter    = balance + finalAmt;
                var totalDept   = parseFloat(r.totalDept   || (currentCardData && currentCardData.totalDept)   || 0);
                var totalCredit = parseFloat(r.totalCredit || (currentCardData && currentCardData.totalCredit) || 0);

                var html = '<div class="balance-row">';
                html += '<div class="balance-name"><i class="fas fa-user-circle" style="color:var(--blue);margin-right:5px;"></i>' + r.Name + '</div>';
                html += '<div class="balance-chip"><i class="fas fa-wallet" style="color:var(--muted);font-size:11px;"></i>';
                html += '<span style="font-size:.72rem;color:var(--muted);">Balance:</span>';
                html += '<span class="bval ' + (balance <= 0 ? 'pos' : 'neg') + '">Rs ' + balance.toFixed(2) + '</span>';
                html += '</div></div>';

                html += '<div class="balance-detail">';
                html += '<div class="brow"><span class="bk">Member No</span><span class="bv">' + (r.MemberNo || r.Memberid) + '</span></div>';
                html += '<div class="brow"><span class="bk">Total Dept (Debit)</span><span class="bv" style="color:var(--red);">Rs ' + totalDept.toFixed(2) + '</span></div>';
                html += '<div class="brow"><span class="bk">Total Credit</span><span class="bv" style="color:var(--green);">Rs ' + totalCredit.toFixed(2) + '</span></div>';
                html += '<div class="brow" style="border-top:1px dashed var(--line);margin-top:4px;padding-top:4px;">';
                html += '<span class="bk">Balance (Dept - Credit)</span>';
                html += '<span class="bv" style="color:' + (balance <= 0 ? 'var(--green)' : 'var(--red)') + ';">Rs ' + balance.toFixed(2) + '</span></div>';
                html += '<div class="brow"><span class="bk">This Bill</span><span class="bv">Rs ' + finalAmt.toFixed(2) + '</span></div>';
                html += '<div class="brow"><span class="bk">Balance After Payment</span>';
                html += '<span class="bv" style="color:var(--amber);">Rs ' + balAfter.toFixed(2) + '</span></div>';
                html += '</div>';

                html += '<div style="background:var(--green);color:white;padding:7px 10px;border-radius:6px;margin-top:8px;text-align:center;font-weight:700;font-size:.82rem;">';
                html += '<i class="fas fa-check-circle"></i> Payment will be posted to member account</div>';

                infoDiv.className     = 'member-info';
                infoDiv.innerHTML     = html;
                infoDiv.style.display = 'block';
            }

            // ── CARD DISCOUNT ──
            function checkCardDiscount(cardNumber) {
                var prefix    = cardNumber.replace(/[^0-9]/g, '').substring(0, 4);
                if (!prefix || prefix.length < 4) return;
                var billTotal = currentBillTotal;

                $.ajax({
                    type: "POST", url: "Casier.aspx/CheckCardDiscount",
                    data: JSON.stringify({ cardNumber: prefix, billAmount: billTotal }),
                    contentType: "application/json; charset=utf-8", dataType: "json",
                    success: function (response) {
                        if (response && response.d) {
                            var r = response.d;
                            currentDiscountData = r;
                            if (r.success) { renderOfferBox(r); updateAmountAfterDiscount(); }
                            else if (r.limit_exceeded) { renderOfferLimitWarn(r); currentDiscountData = null; updateAmountAfterDiscount(); }
                            else { document.getElementById('cardOfferSection').style.display = 'none'; currentDiscountData = null; updateAmountAfterDiscount(); }
                        }
                    },
                    error: function () { document.getElementById('cardOfferSection').style.display = 'none'; currentDiscountData = null; updateAmountAfterDiscount(); }
                });
            }

            function renderOfferBox(r) {
                var sec      = document.getElementById('cardOfferSection');
                var discAmt  = parseFloat(r.discount_amount) || 0;
                var after    = currentBillTotal - discAmt;
                var usageHtml = r.per_day_limit > 0
                    ? '<span class="offer-chip"><i class="fas fa-sync-alt"></i> ' + ((r.used_today || 0) + 1) + '/' + r.per_day_limit + ' uses today</span>'
                    : '<span class="offer-chip"><i class="fas fa-infinity"></i> Unlimited usage</span>';
                sec.innerHTML =
                    '<div class="offer-box">' +
                    '<div class="offer-box-head">' +
                    '<div class="offer-title"><i class="fas fa-tag"></i>' + (r.offer_name || 'Card Discount') + '</div>' +
                    '<div class="offer-disc-amt">&minus;Rs ' + discAmt.toFixed(2) + '</div>' +
                    '</div>' +
                    '<div class="offer-detail-row">' +
                    '<span class="offer-chip"><i class="fas fa-percent"></i> ' + r.discount_percent + '% off</span>' +
                    usageHtml + '</div>' +
                    '<div class="offer-after">' +
                    '<span class="oa-lbl">After discount</span>' +
                    '<span class="oa-val">Rs ' + after.toFixed(2) + '</span>' +
                    '</div></div>';
                sec.style.display = 'block';
            }

            function renderOfferLimitWarn(r) {
                var sec = document.getElementById('cardOfferSection');
                sec.innerHTML =
                    '<div class="offer-limit-warn">' +
                    '<div class="ow-title"><i class="fas fa-ban"></i> Daily Offer Limit Reached</div>' +
                    '<div class="ow-msg">' + (r.message || 'This card has reached its daily discount limit.') + '</div>' +
                    '</div>';
                sec.style.display = 'block';
            }

            function updateAmountAfterDiscount() {
                var billTotal = currentBillTotal;
                var discAmt   = (currentDiscountData && currentDiscountData.success) ? parseFloat(currentDiscountData.discount_amount) : 0;
                var final     = billTotal - discAmt;
                document.getElementById('modalSum').value           = final.toFixed(2);
                document.getElementById('cashAmountDisplay').textContent = 'Rs ' + final.toFixed(2);
                document.getElementById('modalTotal').textContent   = 'Rs ' + billTotal.toFixed(2);
                updateDebtAmount();
                if (currentCardData && selectedPaymentType === 'MemberCard') {
                    renderMemberCardInfo({
                        Name: currentCardData.name, MemberNo: currentCardData.memberNo,
                        totalDept: currentCardData.totalDept, totalCredit: currentCardData.totalCredit
                    }, currentCardData.balance);
                }
            }

            function updateDebtAmount() {
                var billTotal = currentBillTotal;
                var discAmt   = (currentDiscountData && currentDiscountData.success) ? parseFloat(currentDiscountData.discount_amount) : 0;
                var finalAmt  = billTotal - discAmt;
                document.getElementById('modalDebtAmount').innerText = 'Rs ' + Math.max(0, finalAmt).toFixed(2);
            }

            // ════════════════════════════════════════════════
            // PROCESS PAYMENT
            // ════════════════════════════════════════════════



            function processsms() {

                var memberNo = $("#memberCardNumber").val();

                if (!memberNo) {
                    alert("Member number missing");
                    return;
                }

                $.ajax({
                    type: "POST",
                    url: "Cashier.aspx/GetMobileNumber",
                    data: JSON.stringify({ memberNo: memberNo }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        alert(res.d);
                    },
                    error: function (xhr) {
                        console.log(xhr.responseText);
                        alert("SMS failed");
                    }
                });
            }
            function processPayment() {
                debugger;
                var paymentType   = document.getElementById('selectedPaymentType').value;
                var billTotal     = currentBillTotal;
                var discountAmt   = (currentDiscountData && currentDiscountData.success) ? parseFloat(currentDiscountData.discount_amount) : 0;
                var finalAmount   = billTotal - discountAmt;
                var offerId       = (currentDiscountData && currentDiscountData.success) ? currentDiscountData.offer_id : 0;
                var covers        = currentCovers;
                var deptCode      = document.getElementById('currentDeptCode').value || 'BR01';
                var cardSubType   = document.getElementById('selectedCardSubType').value || '';
                var ghPayment     = document.getElementById('isGHPayment').value === '1';

                if (!paymentType) { alert('Please select a payment method to continue.'); return; }
                if (currentBillTo === 'Affiliated Member' && paymentType === 'MemberCard') { alert('Affiliated Members can only pay with Bank Card.'); return; }
                if (currentBillTo === 'Guest House' && paymentType !== 'BankCard') { alert('Guest House bills can only be paid with a Bank Card.'); return; }

                var cardNumber = '', cardExpiry = '', approvalCode = '', cardHolderName = '';

                if (paymentType === 'MemberCard') {
                    cardNumber = document.getElementById('memberCardNumber').value.trim();
                    if (!cardNumber) { alert('Please enter the membership card number.'); return; }
                    if (!currentCardData) { alert('Card validation pending. Please wait a moment and try again.'); return; }
                } else if (paymentType === 'BankCard') {
                    if (!cardSubType) { alert('Please select card type: Debit or Credit.'); return; }
                    cardNumber     = document.getElementById('bankCardNumber').value.trim();
                    var rawCard    = cardNumber.replace(/[\s\-]/g, '');
                    cardExpiry     = document.getElementById('bankCardExpiry').value.trim();
                    approvalCode   = document.getElementById('bankCardApprovalCode').value.trim();
                    cardHolderName = document.getElementById('bankCardHolderName').value.trim();
                    if (!rawCard) { alert('Please enter the bank card number.'); return; }
                    if (!/^\d+$/.test(rawCard)) { alert('Card number must contain digits only.'); return; }
                    if (!cardExpiry) { alert('Please enter card expiry date.'); return; }
                    if (!validateExpiry(document.getElementById('bankCardExpiry'))) { alert('Card expiry is invalid or expired.'); return; }
                    if (!ghPayment && currentBillTo !== 'Guest House' && !approvalCode) { alert('Please enter the authorization code from the terminal.'); return; }
                    if (approvalCode && approvalCode.length !== 6) { alert('Authorization code must be exactly 6 digits.'); return; }
                } else if (paymentType === 'Cash') {
                    var tendered = parseFloat(document.getElementById('cashTendered').value) || 0;
                    if (tendered < finalAmount) { alert('Amount tendered is less than bill amount. Please collect the correct amount.'); return; }
                    cardNumber = 'CASH';
                }

                var paymentMethod = '';
                if (paymentType === 'MemberCard')      paymentMethod = 'Member Card';
                else if (paymentType === 'Cash')       paymentMethod = 'Cash';
                else paymentMethod = (cardSubType ? cardSubType + ' Card' : 'Bank Card');

                var effectiveStatus = ghPayment ? 'GH' : 'Paid';
                var payBtn = document.getElementById('acceptPayBtn'), origTxt = payBtn.innerHTML;
                payBtn.innerHTML = '<span class="spinner"></span> Processing...'; payBtn.disabled = true;

                var billIdsJson = document.getElementById('consolidatedBillIds').value, billIds = [];
                try { billIds = JSON.parse(billIdsJson); } catch (e) { billIds = [parseInt(document.getElementById('paymentBillId').value)]; }
                var deptName = document.getElementById('currentDepartmentName').value || '';
                var memberNo = $("#memberCardNumber").val();

               

                $.ajax({
                    type: "POST",
                    url: "Cashier.aspx/GetMobileNumber",
                    data: JSON.stringify({ memberNo: memberNo }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {

                        console.log(res.d); 

                       
                    },
                    error: function (xhr) {
                        console.log("SMS failed", xhr.responseText);
                    }
                });
                $.ajax({
                    type: "POST", url: "Cashier.aspx/ProcessConsolidatedPayment",
                    data: JSON.stringify({
                        memberNo: currentMemberNo, departmentId: deptName, billIds: billIds,
                        paymentMethod: paymentMethod, paymentType: paymentType,
                        cardNumber: cardNumber, cardExpiry: cardExpiry,
                        approvalCode: approvalCode, cardHolderName: cardHolderName,
                        totalAmount: billTotal, discountAmount: discountAmt,
                        offerId: offerId, signatureData: '',
                        numberOfCovers: covers, deptCode: deptCode,
                        ghPayment: ghPayment, effectiveStatus: effectiveStatus
                    }),

                    contentType: "application/json; charset=utf-8", dataType: "json",
                    success: function (response) {
                        payBtn.innerHTML = origTxt; payBtn.disabled = false;
                        if (response && response.d && response.d.success) {
                            var rd = response.d;
                            generateConsolidatedReceipt({
                                memberNo: currentMemberNo, bills: consolidatedBills, items: allKotItems,
                                billTotal: billTotal, discountAmount: discountAmt,
                                finalAmount: rd.finalAmount || finalAmount,
                                approvalCode: rd.approvalCode || approvalCode,
                                maskedCardNumber: rd.maskedCardNumber || 'XXXX',
                                paymentMethod: paymentMethod, updatedBalance: rd.updatedBalance,
                                billTo: currentBillTo, roomNo: currentRoomNo,
                                generatedBillNo: rd.generatedBillNo || '',
                                cashierName: rd.cashierName || '',
                                numberOfCovers: covers, deptName: deptName, ghPayment: ghPayment
                            });
                            closeModal('paymentModal');
                            alert(rd.message || 'Payment processed successfully!');
                            __doPostBack('<%= timerRefresh.UniqueID %>', '');

                           
                        } else {
                            if (response.d && response.d.limit_exceeded) {
                                alert('Daily Offer Limit Reached\n\n' + (response.d.message || 'This card has reached its daily discount limit.'));
                                currentDiscountData = null; updateAmountAfterDiscount();
                                document.getElementById('cardOfferSection').style.display = 'none';
                            } else {
                                alert(response.d ? (response.d.message || 'Error processing payment.') : 'Unexpected error.');
                            }
                        }
                    },
                    error: function () { payBtn.innerHTML = origTxt; payBtn.disabled = false; alert('Network error. Please try again.'); }
                });
            }

            function processGHPayment() {
                var ghBtn   = document.getElementById('ghMarkBtn'), origTxt = ghBtn.innerHTML;
                ghBtn.innerHTML = '<span class="spinner"></span> Processing GH...'; ghBtn.disabled = true;
                var billIdsJson = document.getElementById('consolidatedBillIds').value, billIds = [];
                try { billIds = JSON.parse(billIdsJson); } catch (e) { billIds = [parseInt(document.getElementById('paymentBillId').value)]; }
                var deptName = document.getElementById('currentDepartmentName').value || '';
                var deptCode = document.getElementById('currentDeptCode').value || 'BR01';
                var billTotal = currentBillTotal;

                $.ajax({
                    type: "POST", url: "Casier.aspx/ProcessConsolidatedPayment",
                    data: JSON.stringify({
                        memberNo: currentMemberNo, departmentId: deptName, billIds: billIds,
                        paymentMethod: 'Guest House', paymentType: 'GH',
                        cardNumber: 'GH', cardExpiry: '', approvalCode: '', cardHolderName: '',
                        totalAmount: billTotal, discountAmount: 0, offerId: 0, signatureData: '',
                        numberOfCovers: currentCovers, deptCode: deptCode, ghPayment: true, effectiveStatus: 'GH'
                    }),
                    contentType: "application/json; charset=utf-8", dataType: "json",
                    success: function (response) {
                        ghBtn.innerHTML = origTxt; ghBtn.disabled = false;
                        if (response && response.d && response.d.success) {
                            var rd = response.d;
                            generateConsolidatedReceipt({
                                memberNo: currentMemberNo, bills: consolidatedBills, items: allKotItems,
                                billTotal: billTotal, discountAmount: 0, finalAmount: billTotal,
                                approvalCode: '', maskedCardNumber: 'GH', paymentMethod: 'Guest House',
                                updatedBalance: null, billTo: 'Guest House', roomNo: currentRoomNo,
                                generatedBillNo: rd.generatedBillNo || '', cashierName: rd.cashierName || '',
                                numberOfCovers: currentCovers, deptName: deptName, ghPayment: true
                            });
                            closeModal('paymentModal');
                            alert('Guest House bill marked successfully!');
                            __doPostBack('<%= timerRefresh.UniqueID %>', '');
                        } else {
                            alert(response.d ? (response.d.message || 'Error.') : 'Unexpected error.');
                        }
                    },
                    error: function () { ghBtn.innerHTML = origTxt; ghBtn.disabled = false; alert('Network error. Please try again.'); }
                });
            }

            // ── RFID SCANNER ──
            function initializeRFIDScanner() {
                var input = document.getElementById('memberCardNumber');
                if (!input) return;
                var scanTimer = null, lastKeyTime = 0;
                input.addEventListener('keydown', function (e) {
                    var now = new Date().getTime();
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        var v = this.value.trim();
                        if (v) validateMemberCard(v);
                        lastKeyTime = 0; return;
                    }
                    if (lastKeyTime > 0 && (now - lastKeyTime) < 50) {
                        if (scanTimer) clearTimeout(scanTimer);
                        scanTimer = setTimeout(function () {
                            var v = input.value.trim();
                            if (v && v.length >= 4) validateMemberCard(v);
                            scanTimer = null;
                        }, 100);
                    }
                    lastKeyTime = now;
                });
                input.addEventListener('input', function () {
                    var v = this.value.trim();
                    if (scanTimer) clearTimeout(scanTimer);
                    scanTimer = setTimeout(function () {
                        if (v && v.length >= 8) validateMemberCard(v);
                        scanTimer = null;
                    }, 800);
                });
                input.addEventListener('paste', function () {
                    setTimeout(function () { var v = input.value.trim(); if (v) validateMemberCard(v); }, 100);
                });
            }

            // ════════════════════════════════════════════════
            // RECEIPT GENERATOR
            // ════════════════════════════════════════════════
            function generateConsolidatedReceipt(data) {
                var deptName     = data.deptName    || $("#<%= hdnDepartmentName.ClientID %>").val() || 'F & B';
                var cashierName  = data.cashierName || '';
                var memberNo     = data.memberNo    || '';
                var covers       = data.numberOfCovers || 1;
                var billNo       = data.generatedBillNo || '';

                var now   = new Date();
                var dd    = String(now.getDate()).padStart(2, '0');
                var mm2   = String(now.getMonth() + 1).padStart(2, '0');
                var yyyy  = now.getFullYear();
                var hh12  = now.getHours() % 12 || 12;
                var min2  = String(now.getMinutes()).padStart(2, '0');
                var ampm  = now.getHours() >= 12 ? 'PM' : 'AM';
                var dateStr = dd + '/' + mm2 + '/' + yyyy + ' ' + String(hh12).padStart(2, '0') + ':' + min2 + ampm;

                var billTotal   = parseFloat(data.billTotal) || 0;
                var discAmt     = parseFloat(data.discountAmount) || 0;
                var netPayable  = billTotal - discAmt;

                var taxAmt = 0, subtotalFromDB = 0;
                if (data.bills && data.bills.length > 0) {
                    data.bills.forEach(function (b) { taxAmt += parseFloat(b.taxApplied || 0); subtotalFromDB += parseFloat(b.subtotal || 0); });
                }
                if (taxAmt === 0 && billTotal > 0) taxAmt = Math.round(billTotal * 16 / 116);
                var subtotal = subtotalFromDB > 0 ? subtotalFromDB : (billTotal - taxAmt);

                var billItemMap = {};
                if (data.items && data.items.length > 0) {
                    data.items.forEach(function (item) { var bid = item.BillId || item.billId; if (!billItemMap[bid]) billItemMap[bid] = []; billItemMap[bid].push(item); });
                }

                var rowsHtml = '';
                if (data.bills && data.bills.length > 0) {
                    data.bills.forEach(function (bill) {
                        var bid = bill.billId, kotNo = bill.kotNo || 'N/A';
                        var items2 = billItemMap[bid] || [], firstRow = true;
                        items2.forEach(function (item) {
                            var qty  = item.Quantity || item.quantity || 0;
                            var rate = parseFloat(item.Price || item.price || 0);
                            var iT   = parseFloat(item.ItemTotal || item.itemTotal || 0);
                            var code = item.ItemCode || item.itemCode || '';
                            var name = item.Name || item.name || '';
                            rowsHtml += '<tr>';
                            rowsHtml += '<td class="c-kot">' + (firstRow ? kotNo : '') + '</td>';
                            rowsHtml += '<td class="c-code">' + code + '</td>';
                            rowsHtml += '<td class="c-name">' + name + '</td>';
                            rowsHtml += '<td class="c-num">'  + rate.toFixed(0) + '</td>';
                            rowsHtml += '<td class="c-qty">'  + qty + '</td>';
                            rowsHtml += '<td class="c-num">'  + iT.toFixed(0) + '</td>';
                            rowsHtml += '</tr>';
                            firstRow  = false;
                        });
                    });
                }

                var pmNote  = data.ghPayment ? 'GH' : data.paymentMethod;
                var ghNote  = data.ghPayment ? '<div style="text-align:center;font-weight:700;margin-bottom:4px;">*** GUEST HOUSE BILL ***</div>' : '';
                var postedLabel = data.paymentMethod === 'Member Card' ? 'Posted to Member A/C:' : 'Amount Paid:';

                var html = '<!DOCTYPE html><html><head><meta charset="utf-8"><title>Receipt - ' + billNo + '</title>'
                    + '<style>'
                    + '@page{size:80mm auto;margin:4mm 4mm}'
                    + '*{margin:0;padding:0;box-sizing:border-box}'
                    + 'body{font-family:"Courier New",Courier,monospace;font-size:10px;color:#000;background:#fff;width:72mm;margin:0 auto}'
                    + '.hdr{text-align:center;border-bottom:1px dashed #000;padding-bottom:4px;margin-bottom:4px}'
                    + '.hdr .org{font-size:13px;font-weight:700;letter-spacing:1px;text-transform:uppercase}'
                    + '.hdr .sub{font-size:11px;font-weight:700}'
                    + '.meta{margin-bottom:4px;border-bottom:1px dashed #000;padding-bottom:4px;font-size:9.5px}'
                    + '.meta-row{display:flex;justify-content:space-between;margin-bottom:2px}'
                    + 'table{width:100%;border-collapse:collapse;font-size:9px;margin-bottom:4px}'
                    + 'thead tr{border-top:1px solid #000;border-bottom:1px solid #000}'
                    + 'th{padding:2px;font-weight:700;text-align:left}'
                    + 'td{padding:1px 2px;vertical-align:top}'
                    + '.c-kot{width:22%;font-size:8px;color:#333}'
                    + '.c-code{width:8%}'
                    + '.c-name{width:34%}'
                    + '.c-num{text-align:right;width:12%}'
                    + '.c-qty{text-align:center;width:6%}'
                    + '.totals{border-top:1px solid #000;padding-top:3px;margin-top:2px}'
                    + '.trow{display:flex;justify-content:space-between;font-size:9.5px;padding:1px 0}'
                    + '.trow.grand{font-weight:700;border-top:1px solid #000;margin-top:2px;padding-top:2px}'
                    + '.sig-area{margin-top:10px;display:flex;justify-content:space-between;align-items:flex-end}'
                    + '.sig-box{width:28mm;height:16mm;border:1px solid #000;border-radius:50%;display:flex;align-items:center;justify-content:center;overflow:hidden}'
                    + '.sig-lbl{font-size:8px;margin-top:3px;text-align:center}'
                    + '.preparer{text-align:right;font-size:8.5px;line-height:1.6}'
                    + '.ftr{border-top:1px dashed #000;margin-top:6px;padding-top:4px;text-align:center;font-size:8px;line-height:1.5}'
                    + '.noprint{text-align:center;margin-top:8px}'
                    + '@media print{.noprint{display:none}}'
                    + '</style></head><body>';

                html += ghNote;
                html += '<div class="hdr"><div class="org">LAHORE GYMKHANA</div><div class="sub">' + deptName + '</div></div>';
                html += '<div class="meta">';
                html += '<div class="meta-row"><span>Bill No: <strong>' + billNo + '</strong></span><span>Covers: <strong>' + covers + '</strong></span></div>';
                html += '<div class="meta-row"><span>Date: ' + dateStr + '</span></div>';
                html += '<div class="meta-row"><span>Member: <strong>' + memberNo + '</strong></span></div>';
                html += '<div class="meta-row"><span>' + deptName + '</span><span>Payment: ' + pmNote + '</span></div>';
                html += '</div>';

                html += '<table><thead><tr><th>KOT</th><th>Code</th><th>Item</th><th style="text-align:right">Rate</th><th style="text-align:center">Qty</th><th style="text-align:right">Amt</th></tr></thead><tbody>' + rowsHtml + '</tbody></table>';

                html += '<div class="totals">';
                html += '<div class="trow"><span>Total:</span><span>' + subtotal.toFixed(0) + '</span></div>';
                html += '<div class="trow"><span>Total GST:</span><span>' + taxAmt.toFixed(0) + '</span></div>';
                if (discAmt > 0) html += '<div class="trow"><span>Discount:</span><span>-' + discAmt.toFixed(0) + '</span></div>';
                html += '<div class="trow grand"><span>Net Payable:</span><span>' + netPayable.toFixed(0) + '</span></div>';
                html += '<div class="trow"><span>' + postedLabel + '</span><span>' + netPayable.toFixed(0) + '</span></div>';
                html += '<div class="trow grand"><span>Balance:</span><span>0</span></div>';
                html += '</div>';

                html += '<div class="sig-area">';
                html += '<div><div class="sig-box"><canvas id="sigCanvas" width="108" height="60"></canvas></div><div class="sig-lbl">Member Signature</div></div>';
                html += '<div class="preparer">Prepared By:<br>' + (cashierName || '&mdash;') + '</div>';
                html += '</div>';
                html += '<div class="ftr">WE HOPE YOU ENJOYED YOUR VISIT<br>WE WELCOME YOUR COMMENTS AND SUGGESTIONS</div>';
                html += '<div class="noprint"><button onclick="clearSig()" style="padding:5px 10px;background:#555;color:#fff;border:none;border-radius:4px;cursor:pointer;margin-right:4px;font-size:11px;">Clear Sig</button><button onclick="window.print()" style="padding:5px 10px;background:#1845D4;color:#fff;border:none;border-radius:4px;cursor:pointer;margin-right:4px;font-size:11px;">Print</button><button onclick="window.close()" style="padding:5px 10px;background:#D42B2B;color:#fff;border:none;border-radius:4px;cursor:pointer;font-size:11px;">Close</button></div>';
                html += '<script>(function(){var c=document.getElementById("sigCanvas");var ctx=c.getContext("2d");ctx.strokeStyle="#000";ctx.lineWidth=1.5;ctx.lineCap="round";var drawing=false,lx=0,ly=0;function getPos(e){var r=c.getBoundingClientRect(),t=e.touches?e.touches[0]:e;return{x:t.clientX-r.left,y:t.clientY-r.top};}c.onmousedown=function(e){drawing=true;var p=getPos(e);lx=p.x;ly=p.y;};c.onmousemove=function(e){if(!drawing)return;var p=getPos(e);ctx.beginPath();ctx.moveTo(lx,ly);ctx.lineTo(p.x,p.y);ctx.stroke();lx=p.x;ly=p.y;};c.onmouseup=c.onmouseleave=function(){drawing=false;};c.addEventListener("touchstart",function(e){e.preventDefault();drawing=true;var p=getPos(e);lx=p.x;ly=p.y;},{passive:false});c.addEventListener("touchmove",function(e){e.preventDefault();if(!drawing)return;var p=getPos(e);ctx.beginPath();ctx.moveTo(lx,ly);ctx.lineTo(p.x,p.y);ctx.stroke();lx=p.x;ly=p.y;},{passive:false});c.addEventListener("touchend",function(){drawing=false;});window.clearSig=function(){ctx.clearRect(0,0,c.width,c.height);};})();window.onload=function(){setTimeout(function(){window.print();},700);};<\/script></body></html>';

                var w = window.open('', '_blank', 'width=400,height=650');
                if (w) { w.document.write(html); w.document.close(); }
            }

            // ── PAYMENT SUMMARY PRINT ──
            function printPaymentSummary() {
                var btn = document.querySelector('[onclick="printPaymentSummary()"]'), orig = btn ? btn.innerHTML : '';
                if (btn) { btn.innerHTML = '<span class="spinner"></span> Loading...'; btn.disabled = true; }
                $.ajax({
                    type: "POST", url: "Casier.aspx/GetPaymentSummary",
                    contentType: "application/json; charset=utf-8", dataType: "json",
                    success: function (response) {
                        if (btn) { btn.innerHTML = orig; btn.disabled = false; }
                        if (response && response.d && response.d.success) generateThermalReceipt(response.d);
                        else alert('Error loading summary: ' + (response.d ? response.d.message : 'Unknown error.'));
                    },
                    error: function () { if (btn) { btn.innerHTML = orig; btn.disabled = false; } alert('Network error loading summary.'); }
                });
            }

            function generateThermalReceipt(data) {
                var cashierName = data.cashierName || $("#<%= hdnEmployeeName.ClientID %>").val() || 'Unknown';
                var deptName    = $("#<%= hdnDepartmentName.ClientID %>").val() || data.departmentName || 'All Departments';
                var rowsHtml = '';
                if (data.paymentMethods && data.paymentMethods.length > 0) {
                    data.paymentMethods.forEach(function (m) {
                        rowsHtml += '<div style="display:flex;justify-content:space-between;font-size:9.5px;margin:2px 0;"><span style="width:38%;">' + (m.PaymentMethod || 'Unknown') + '</span><span style="width:12%;text-align:center;">' + (m.TotalTransactions || 0) + '</span><span style="width:27%;text-align:right;">Rs ' + (m.TotalAmountPaid || 0).toFixed(2) + '</span><span style="width:23%;text-align:right;">Rs ' + (m.Tax || 0).toFixed(2) + '</span></div>';
                    });
                } else { rowsHtml = '<div style="text-align:center;padding:8px;font-size:10px;">No payments found for today.</div>'; }
                var totalTax = 0;
                if (data.paymentMethods) data.paymentMethods.forEach(function (m) { totalTax += parseFloat(m.Tax || 0); });
                var html = '<!DOCTYPE html><html><head><title>Payment Summary</title><style>@page{size:80mm auto;margin:4mm 4mm}*{margin:0;padding:0;box-sizing:border-box;font-family:"Courier New",monospace}body{background:white;color:#000;padding:0;width:72mm;margin:0 auto;font-size:10px}.hdr{text-align:center;border-bottom:1px dashed #000;padding-bottom:6px;margin-bottom:6px}.noprint{text-align:center;margin-top:8px}@media print{.noprint{display:none}}</style></head><body>';
                html += '<div class="hdr"><div style="font-size:13px;font-weight:700;text-transform:uppercase;">' + deptName + '</div><div style="font-size:9.5px;">Payment Summary — ' + data.date + '</div></div>';
                html += '<div style="margin-bottom:6px;border-bottom:1px dotted #000;padding-bottom:6px;font-size:9.5px;"><div style="display:flex;justify-content:space-between;margin:1px 0;"><span>Cashier:</span><span>' + cashierName + '</span></div><div style="display:flex;justify-content:space-between;margin:1px 0;"><span>Time:</span><span>' + data.time + '</span></div><div style="display:flex;justify-content:space-between;margin:1px 0;"><span>Total Bills:</span><span>' + (data.totalBills || 0) + '</span></div></div>';
                html += '<div style="display:flex;justify-content:space-between;font-weight:700;font-size:9px;border-bottom:1px solid #000;padding-bottom:2px;margin-bottom:3px;"><span style="width:38%;">Method</span><span style="width:12%;text-align:center;">Cnt</span><span style="width:27%;text-align:right;">Amount</span><span style="width:23%;text-align:right;">Tax</span></div>';
                html += rowsHtml;
                html += '<div style="border-top:1px solid #000;padding-top:4px;margin-top:6px;font-size:10px;"><div style="display:flex;justify-content:space-between;margin:2px 0;"><span>Total Tax:</span><span>Rs ' + totalTax.toFixed(2) + '</span></div><div style="display:flex;justify-content:space-between;font-weight:700;font-size:12px;border-top:1px dashed #000;padding-top:3px;margin-top:3px;"><span>GRAND TOTAL:</span><span>Rs ' + (data.grandTotal || 0).toFixed(2) + '</span></div></div>';
                html += '<div style="display:flex;justify-content:space-between;margin-top:12px;font-size:9px;"><span>Cashier: ________</span><span>Manager: ________</span></div>';
                html += '<div class="noprint"><button onclick="window.print()" style="padding:5px 12px;background:#1845D4;color:white;border:none;border-radius:4px;cursor:pointer;font-size:11px;">Print</button><button onclick="window.close()" style="padding:5px 12px;background:#D42B2B;color:white;border:none;border-radius:4px;cursor:pointer;margin-left:6px;font-size:11px;">Close</button></div>';
                html += '<script>window.onload=function(){setTimeout(function(){window.print();},500);};<\/script></body></html>';
                var w = window.open('', '_blank', 'width:380,height:600');
                if (w) { w.document.write(html); w.document.close(); }
            }
        </script>
    </form>
</body>
</html>
