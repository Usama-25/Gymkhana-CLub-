<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CombinedPOS.aspx.cs" Inherits="CombinedPOS" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1.0"/>
<title>Combined POS - Lahore Gymkhana</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700;800&family=Poppins:wght@400;600;700;800&display=swap" rel="stylesheet"/>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<style>
:root{
  --pr:#C62828;--pr-d:#8E0000;--pr-l:#FFCDD2;--pr-ll:#FFF5F5;
  --sc:#EF6C00;--ok:#2E7D32;--ok-l:#E8F5E9;
  --err:#C62828;--warn:#E65100;--inf:#1565C0;
  --dk:#1A0A00;--gy:#6D4C41;--lg:#D7CCC8;--llg:#EFEBE9;
  --sh:0 2px 8px rgba(0,0,0,.10);--sh-lg:0 6px 20px rgba(0,0,0,.14);
  --g1:linear-gradient(135deg,#C62828,#EF6C00);
  --g-lt:linear-gradient(135deg,#FFF3E0,#fff);
  --tr:.14s cubic-bezier(.4,0,.2,1);
  --hh:50px;
  --sb:34px;
  --mono:'JetBrains Mono',monospace;
}
*{box-sizing:border-box;margin:0;padding:0;}
body{font-family:'Poppins',sans-serif;background:#F3EDE8;color:var(--dk);overflow:hidden;}
::-webkit-scrollbar{width:4px;height:4px;}
::-webkit-scrollbar-thumb{background:var(--pr-l);border-radius:4px;}

/* FOCUS RING — keyboard nav */
:focus-visible{outline:2px solid var(--pr);outline-offset:2px;}

/* HEADER */
.hdr{position:fixed;top:0;left:0;right:0;height:var(--hh);background:#fff;z-index:300;
  box-shadow:0 2px 8px rgba(0,0,0,.09);border-bottom:3px solid var(--pr-l);
  display:flex;align-items:center;padding:0 10px;gap:8px;}
.logo{font-family:var(--mono);font-weight:800;font-size:13px;color:var(--dk);
  display:flex;align-items:center;gap:5px;white-space:nowrap;flex-shrink:0;}
.logo i{color:var(--pr);}

/* dept selector */
.dg{display:flex;align-items:center;border:2px solid var(--pr-l);border-radius:8px;overflow:hidden;
  box-shadow:var(--sh);flex-shrink:0;}
.dg:focus-within{border-color:var(--pr);}
.dl{display:flex;align-items:center;gap:4px;padding:0 8px;background:var(--g1);color:#fff;
  font-size:10px;font-weight:700;height:30px;flex-shrink:0;}
.dsel{padding:0 8px;height:30px;border:none;background:#fff;font-size:11px;font-weight:600;
  color:var(--dk);outline:none;appearance:none;font-family:'Poppins',sans-serif;min-width:130px;}

/* bill-type pills */
.btg{display:flex;gap:4px;align-items:center;flex-shrink:0;}
.rl{display:inline-flex;align-items:center;gap:3px;padding:4px 9px;border-radius:7px;
  border:2px solid var(--lg);background:#fff;font-size:10.5px;font-weight:700;color:var(--gy);
  cursor:pointer;transition:all var(--tr);white-space:nowrap;user-select:none;}
.rl input{display:none;}
.rl kbd{font-family:var(--mono);font-size:8.5px;background:#eee;border:1px solid #ccc;
  border-radius:3px;padding:0 3px;margin-left:2px;color:#555;}
.rl:hover{border-color:var(--pr);color:var(--pr);}
.rl.act{color:#fff;border-color:transparent;background:var(--g1);box-shadow:var(--sh);}
.rl.act kbd{background:rgba(255,255,255,.25);border-color:rgba(255,255,255,.4);color:#fff;}
.rl[data-t="Club Member"].act{background:linear-gradient(135deg,#C62828,#EF6C00);}
.rl[data-t="Guest House"].act{background:linear-gradient(135deg,#2E7D32,#66BB6A);}
.rl[data-t="Affiliated Member"].act{background:linear-gradient(135deg,#6A1B9A,#AB47BC);}

/* auto-deliver */
.adt{display:flex;align-items:center;gap:5px;background:#fff;border:2px solid var(--lg);
  border-radius:7px;padding:4px 9px;cursor:pointer;font-size:10px;font-weight:700;
  color:var(--gy);transition:all var(--tr);white-space:nowrap;user-select:none;}
.adt.on{background:linear-gradient(135deg,#1B5E20,var(--ok));color:#fff;border-color:var(--ok);}
.adt .tog{width:26px;height:14px;border-radius:7px;background:var(--lg);position:relative;transition:background .2s;flex-shrink:0;}
.adt.on .tog{background:rgba(255,255,255,.4);}
.adt .tog::after{content:'';position:absolute;left:2px;top:2px;width:10px;height:10px;
  border-radius:50%;background:#fff;transition:transform .2s;box-shadow:0 1px 3px rgba(0,0,0,.3);}
.adt.on .tog::after{transform:translateX(12px);}

.hdr-acts{display:flex;gap:4px;align-items:center;margin-left:auto;flex-shrink:0;}
.hbtn{padding:5px 10px;border-radius:7px;background:var(--g1);color:#fff;border:none;
  font-weight:700;font-size:10.5px;cursor:pointer;display:flex;align-items:center;gap:3px;
  white-space:nowrap;font-family:'Poppins',sans-serif;transition:box-shadow var(--tr),transform var(--tr);}
.hbtn:hover{transform:translateY(-1px);box-shadow:var(--sh);}
.hbtn.cc{background:linear-gradient(135deg,#E65100,#FF9800);}
.hbtn.logout{background:linear-gradient(135deg,#B71C1C,#EF5350);}
.emp-pill{display:flex;align-items:center;gap:4px;background:#FFF3E0;border:2px solid var(--pr-l);
  border-radius:7px;padding:3px 9px;font-size:10.5px;font-weight:700;color:var(--dk);white-space:nowrap;}

/* STATS BAR */
.sbar{position:fixed;top:var(--hh);left:0;right:0;height:var(--sb);background:#fff;
  border-bottom:2px solid var(--pr-l);display:flex;align-items:center;z-index:200;overflow:hidden;}
.sc{flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;
  padding:0 8px;border-right:1px solid var(--pr-l);white-space:nowrap;}
.sc .sv{font-size:11px;font-weight:800;color:var(--dk);font-family:var(--mono);}
.sc .sl{font-size:8.5px;color:var(--gy);text-transform:uppercase;letter-spacing:.4px;}
.lv-dot{width:6px;height:6px;border-radius:50%;background:#22C55E;animation:pulse 2s infinite;display:inline-block;vertical-align:middle;margin-right:2px;}
@keyframes pulse{0%{box-shadow:0 0 0 0 rgba(34,197,94,.6)}70%{box-shadow:0 0 0 4px rgba(34,197,94,0)}100%{box-shadow:0 0 0 0 rgba(34,197,94,0)}}

/* LAYOUT */
.layout{display:flex;height:100vh;padding-top:calc(var(--hh) + var(--sb));}

/* ===== LEFT PANEL ===== */
.left{width:56%;display:flex;flex-direction:column;background:#F3EDE8;border-right:2px solid var(--pr-l);}

/* KEYBOARD SHORTCUT BAR — top of left panel */
.kb-bar{background:var(--dk);color:#FFCDD2;padding:4px 10px;font-size:9.5px;font-family:var(--mono);
  display:flex;gap:10px;flex-wrap:wrap;align-items:center;flex-shrink:0;}
.kb-bar .kk{display:inline-flex;align-items:center;gap:3px;}
.kb-bar .kk kbd{background:rgba(255,255,255,.15);border:1px solid rgba(255,255,255,.25);
  border-radius:3px;padding:1px 4px;font-size:8.5px;color:#fff;font-family:var(--mono);}

/* MEMBER BAR */
.mbar{padding:6px 10px 5px;background:#fff;border-bottom:2px solid var(--pr-l);flex-shrink:0;}
.mb-r{display:flex;gap:6px;flex-wrap:nowrap;}
.mbx{flex:1;min-width:0;border-radius:8px;border:2px solid #ddd;overflow:hidden;display:none;}
.mbx.vis{display:flex;flex-direction:column;}
.mbx-cl{border-color:#FFAB91;}
.mbx-gh{border-color:#A5D6A7;}
.mbx-af{border-color:#CE93D8;}
.mbx-ps{border-color:var(--pr-l);}
.mbx-hd{padding:3px 7px;font-size:9.5px;font-weight:800;display:flex;align-items:center;gap:3px;}
.mbx-cl .mbx-hd{background:#FBE9E7;color:#BF360C;}
.mbx-gh .mbx-hd{background:#E8F5E9;color:#2E7D32;}
.mbx-af .mbx-hd{background:#F3E5F5;color:#6A1B9A;}
.mbx-ps .mbx-hd{background:#FFF3E0;color:var(--pr);}
.mbx-hd kbd{font-family:var(--mono);font-size:8px;background:rgba(0,0,0,.1);border-radius:2px;padding:0 3px;}
.msr{display:flex;align-items:center;gap:3px;padding:4px 5px;}
.msr input{flex:1;padding:5px 8px;border-radius:6px;border:1.5px solid #ddd;font-size:12px;
  font-weight:600;outline:none;font-family:'Poppins',sans-serif;min-width:0;
  transition:border-color .13s,box-shadow .13s;}
.msr input:focus{border-color:var(--pr);box-shadow:0 0 0 3px rgba(198,40,40,.12);}
.msr button{width:26px;height:26px;min-width:26px;border-radius:5px;border:none;cursor:pointer;
  display:flex;align-items:center;justify-content:center;font-size:11px;color:#fff;transition:transform .12s;}
.msr button:hover{transform:scale(1.08);}
.mbx-cl .msr button{background:linear-gradient(135deg,#BF360C,#FF7043);}
.mbx-gh .msr button{background:linear-gradient(135deg,#2E7D32,#66BB6A);}
.mbx-af .msr button{background:linear-gradient(135deg,#6A1B9A,#AB47BC);}
.mbx-ps .msr button{background:var(--g1);}
.mres{padding:1px 7px 4px;font-size:10px;}

/* QUICK SEARCH — always visible compact bar */
.qsbar{display:flex;align-items:center;gap:6px;padding:6px 10px;background:#fff;
  border-bottom:2px solid var(--pr-l);flex-shrink:0;}
.qsbar label{font-size:10px;font-weight:700;color:var(--gy);white-space:nowrap;
  display:flex;align-items:center;gap:3px;}
.qsbar label kbd{font-family:var(--mono);font-size:8.5px;background:#eee;border:1px solid #ccc;
  border-radius:3px;padding:0 3px;}
.qsinp{flex:1;padding:5px 9px;border-radius:7px;border:2px solid var(--lg);font-size:12px;
  font-weight:600;outline:none;font-family:'Poppins',sans-serif;transition:border-color .13s,box-shadow .13s;}
.qsinp:focus{border-color:var(--pr);box-shadow:0 0 0 3px rgba(198,40,40,.12);}

/* CATEGORIES */
.cats{display:flex;gap:4px;padding:5px 10px 4px;overflow-x:auto;flex-shrink:0;scrollbar-width:none;}
.cats::-webkit-scrollbar{display:none;}
.cat{flex:0 0 auto;padding:4px 10px;border-radius:6px;background:#fff;border:2px solid var(--lg);
  color:var(--gy);font-weight:700;font-size:10.5px;cursor:pointer;transition:all var(--tr);
  font-family:'Poppins',sans-serif;display:flex;align-items:center;gap:4px;}
.cat kbd{font-family:var(--mono);font-size:8px;background:rgba(0,0,0,.08);border-radius:2px;padding:0 3px;}
.cat.act{background:var(--g1);color:#fff;border-color:transparent;box-shadow:var(--sh);}
.cat.act kbd{background:rgba(255,255,255,.25);}

/* PRODUCT GRID */
.pg{flex:1;overflow-y:auto;display:grid;grid-template-columns:repeat(auto-fill,minmax(120px,1fr));
  gap:6px;padding:6px 10px 8px;align-content:start;-webkit-overflow-scrolling:touch;}
.pc2{background:#fff;border-radius:9px;padding:7px;cursor:pointer;border:2px solid transparent;
  box-shadow:var(--sh);display:flex;flex-direction:column;gap:3px;transition:transform .13s,border-color .13s;
  will-change:transform;position:relative;}
.pc2:hover{transform:translateY(-2px);border-color:var(--pr-l);box-shadow:var(--sh-lg);}
.pc2:active{transform:scale(.96);}
.pc2.kbd-focus{border-color:var(--pr);box-shadow:0 0 0 3px rgba(198,40,40,.2);}
.pc2 .nmb{font-family:var(--mono);font-size:9px;font-weight:800;color:#fff;background:var(--pr);
  border-radius:3px;padding:0 4px;position:absolute;top:5px;left:5px;opacity:.85;}
.pc2 img{width:100%;height:80px;object-fit:cover;border-radius:5px;}
.pc2 .nm{font-weight:700;font-size:10.5px;color:var(--dk);text-align:center;line-height:1.3;
  display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;min-height:26px;}
.pc2 .gst-lbl{font-size:9px;color:var(--gy);text-align:center;background:#f5f5f5;border-radius:3px;padding:1px 3px;}
.pc2 .pr{font-size:12px;font-weight:800;color:var(--pr);text-align:center;padding:3px;
  background:var(--g-lt);border-radius:5px;border:2px solid var(--pr-l);margin-top:2px;
  font-family:var(--mono);}

/* ===== RIGHT PANEL ===== */
.right{width:44%;display:flex;flex-direction:column;background:#fff;}

/* TABS */
.rtabs{display:flex;border-bottom:2px solid var(--pr-l);flex-shrink:0;}
.rtab{flex:1;padding:7px 5px;border:none;background:#FFF9F6;font-weight:700;font-size:10.5px;
  cursor:pointer;font-family:'Poppins',sans-serif;color:var(--gy);transition:all var(--tr);
  border-bottom:3px solid transparent;display:flex;align-items:center;justify-content:center;gap:3px;}
.rtab.act{background:#fff;color:var(--pr);border-bottom-color:var(--pr);}
.rtab .cnt{background:var(--err);color:#fff;font-size:9px;font-weight:900;width:16px;height:16px;
  border-radius:50%;display:inline-flex;align-items:center;justify-content:center;margin-left:2px;}
.rtab kbd{font-family:var(--mono);font-size:8.5px;background:rgba(0,0,0,.08);border-radius:3px;padding:0 3px;}
.rtab.act kbd{background:rgba(198,40,40,.12);color:var(--pr);}

/* PANELS */
.rpanel{display:none;flex-direction:column;flex:1;overflow:hidden;}
.rpanel.act{display:flex;}

/* CART ITEMS */
.citems{flex:1;overflow-y:auto;padding:6px 8px;-webkit-overflow-scrolling:touch;}
.ci{display:flex;align-items:center;gap:5px;padding:6px 7px;background:#fff;border-radius:7px;
  margin-bottom:4px;box-shadow:var(--sh);border:2px solid var(--pr-l);transition:border-color .1s;}
.ci:focus-within{border-color:var(--pr);}
.ci .inf{flex:1;min-width:0;}
.ci .inf .inm{font-weight:700;font-size:10.5px;line-height:1.3;}
.ci .inf .ipr{font-size:9.5px;color:var(--gy);font-family:var(--mono);}
.ci .qty{display:flex;align-items:center;gap:2px;background:var(--g-lt);padding:2px;
  border-radius:5px;border:2px solid var(--pr-l);flex-shrink:0;}
.ci .qty button{width:22px;height:22px;min-width:22px;border-radius:3px;background:var(--g1);
  color:#fff;border:none;cursor:pointer;display:flex;align-items:center;justify-content:center;
  font-size:12px;font-weight:700;transition:transform .1s;}
.ci .qty button:hover{transform:scale(1.1);}
.ci .qty button:disabled{opacity:.35;cursor:default;transform:none;}
.ci .qty span{font-weight:800;min-width:18px;text-align:center;font-size:12px;font-family:var(--mono);}
.ci .del-btn{width:22px;height:22px;min-width:22px;border-radius:4px;background:#FFEBEE;
  border:none;cursor:pointer;color:var(--err);font-size:10px;display:flex;align-items:center;justify-content:center;
  flex-shrink:0;transition:all .12s;}
.ci .del-btn:hover{background:var(--err);color:#fff;}

/* CART FOOTER */
.cftr{padding:7px 8px;background:#FFF9F6;border-top:2px solid var(--pr-l);flex-shrink:0;}
.row2c{display:flex;gap:6px;margin-bottom:6px;}
.igl{display:flex;flex-direction:column;gap:2px;flex:1;}
.igl label{font-size:9.5px;font-weight:700;color:var(--gy);text-transform:uppercase;letter-spacing:.3px;
  display:flex;align-items:center;gap:3px;}
.igl label kbd{font-family:var(--mono);font-size:8px;background:#eee;border:1px solid #ccc;border-radius:2px;padding:0 3px;}
.tinp{padding:6px 8px;border-radius:6px;border:2px solid var(--lg);font-size:12px;font-weight:600;
  color:var(--dk);width:100%;background:#fff;font-family:'Poppins',sans-serif;outline:none;transition:border-color .12s,box-shadow .12s;}
.tinp:focus{border-color:var(--pr);box-shadow:0 0 0 3px rgba(198,40,40,.12);}

/* non-member row */
.nm-row{display:flex;align-items:center;gap:5px;margin-bottom:6px;}
.nmtog{padding:5px 10px;border-radius:6px;border:2px solid var(--lg);background:#fff;color:var(--gy);
  font-size:10.5px;font-weight:700;cursor:pointer;font-family:'Poppins',sans-serif;
  display:flex;align-items:center;gap:3px;transition:all var(--tr);}
.nmtog.on{background:linear-gradient(135deg,#E65100,#FFA726);color:#fff;border-color:#E65100;}
.nmtog kbd{font-family:var(--mono);font-size:8.5px;background:rgba(0,0,0,.1);border-radius:2px;padding:0 3px;}
.nmtog.on kbd{background:rgba(255,255,255,.25);}
.nminp{flex:1;padding:5px 8px;border-radius:6px;border:2px solid var(--pr-l);font-size:12px;font-weight:600;
  outline:none;font-family:'Poppins',sans-serif;display:none;transition:border-color .12s;}
.nminp.show{display:block;}
.nminp:focus{border-color:var(--pr);}

/* TOTALS */
.tots-box{background:#fff;border-radius:7px;border:2px solid var(--pr-l);padding:6px 9px;
  margin-bottom:6px;font-size:11px;}
.tot-row{display:flex;justify-content:space-between;font-family:var(--mono);}
.tot-row.grand{font-weight:800;font-size:12.5px;color:var(--pr);border-top:2px dashed var(--pr-l);
  padding-top:4px;margin-top:3px;}

/* SUBMIT ROW */
.obtn-row{display:grid;grid-template-columns:1fr auto auto;gap:5px;}
#btnSubmit{padding:9px;border-radius:7px;border:none;background:var(--g1);color:#fff;
  font-weight:800;font-size:12.5px;cursor:pointer;font-family:'Poppins',sans-serif;
  display:flex;align-items:center;justify-content:center;gap:4px;
  transition:transform .12s,box-shadow .12s;box-shadow:var(--sh);}
#btnSubmit:hover{transform:translateY(-1px);box-shadow:var(--sh-lg);}
#btnSubmit:disabled{opacity:.5;cursor:not-allowed;transform:none;}
#btnClear{padding:9px 11px;border-radius:7px;border:2px solid var(--pr-l);background:#fff;
  color:var(--err);font-weight:700;font-size:11.5px;cursor:pointer;font-family:'Poppins',sans-serif;
  transition:all var(--tr);display:flex;align-items:center;gap:3px;}
#btnClear:hover{background:var(--err);color:#fff;}
#btnClear kbd{font-family:var(--mono);font-size:8.5px;background:rgba(0,0,0,.1);border-radius:2px;padding:0 3px;}

/* LIVE BILLS */
.live-list{flex:1;overflow-y:auto;padding:6px 8px;}
.oi2{background:#fff;border-radius:9px;padding:8px 9px;margin-bottom:5px;box-shadow:var(--sh);
  border:2px solid var(--pr-l);animation:fi .18s ease;}
@keyframes fi{from{opacity:0;transform:translateY(-4px)}to{opacity:1;transform:none}}
.oi2-hd{display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:3px;margin-bottom:4px;}
.sbadge{padding:2px 6px;border-radius:10px;font-size:9px;font-weight:700;text-transform:uppercase;font-family:var(--mono);}
.sb-del{background:#1565C0;color:#fff;}
.sb-pend{background:var(--warn);color:#fff;}
.kotb{display:inline-flex;align-items:center;gap:2px;background:linear-gradient(135deg,#1565C0,#42A5F5);
  color:#fff;padding:2px 6px;border-radius:10px;font-size:9px;font-weight:700;font-family:var(--mono);}
.abt{display:flex;gap:4px;flex-wrap:wrap;margin-top:5px;}
.ob{border:none;padding:5px 10px;border-radius:6px;cursor:pointer;display:inline-flex;align-items:center;
  gap:3px;font-weight:700;font-size:10px;color:#fff;transition:transform .11s;
  font-family:'Poppins',sans-serif;white-space:nowrap;}
.ob:hover{transform:translateY(-1px);}
.ob-pay{background:linear-gradient(135deg,#1B5E20,var(--ok));}
.ob-gh{background:linear-gradient(135deg,#0A1A50,#1845D4);}
.ob-cx{background:linear-gradient(135deg,#B71C1C,#EF5350);}
.ob-lock{background:#E8E8E8;color:#999;cursor:not-allowed;}

/* CASHIER FILTER */
.cfilter{padding:6px 8px;border-bottom:1px solid var(--pr-l);flex-shrink:0;display:flex;gap:5px;align-items:center;}
.cfilter input{flex:1;padding:5px 9px;border-radius:6px;border:2px solid var(--lg);font-size:12px;font-weight:600;
  outline:none;font-family:'Poppins',sans-serif;transition:border-color .12s;}
.cfilter input:focus{border-color:var(--pr);}
.cfilter .ref-btn{padding:5px 9px;border-radius:6px;border:2px solid var(--pr-l);background:#fff;
  color:var(--pr);font-weight:700;font-size:10.5px;cursor:pointer;font-family:'Poppins',sans-serif;}

/* ===== MODALS ===== */
.mbg{display:none;position:fixed;inset:0;background:rgba(0,0,0,.7);backdrop-filter:blur(5px);
  z-index:2000;align-items:center;justify-content:center;padding:10px;overflow-y:auto;}
.mbg.open{display:flex;}
.mbox{background:#fff;border-radius:12px;width:100%;max-width:480px;box-shadow:0 14px 40px rgba(0,0,0,.2);
  animation:siu .2s ease;margin:auto;}
@keyframes siu{from{transform:translateY(8px);opacity:0}to{transform:translateY(0);opacity:1}}
.mhd{padding:11px 14px;border-bottom:2px solid var(--pr-l);display:flex;justify-content:space-between;
  align-items:center;background:var(--g-lt);}
.mhd h3{font-size:13px;font-weight:800;color:var(--dk);margin:0;display:flex;align-items:center;gap:5px;}
.mhd h3 i{color:var(--pr);}
.mcx2{width:26px;height:26px;border-radius:5px;background:var(--llg);color:var(--gy);
  display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:15px;border:none;}
.mcx2:hover{background:var(--err);color:#fff;}
.mbody{padding:12px 14px;}

/* PAYMENT MODAL */
.pay-mbox{max-width:720px;}
.pmethods{display:grid;grid-template-columns:1fr 1fr;gap:7px;margin-bottom:11px;}
.pmethod{background:#fff;border:2px solid var(--lg);border-radius:8px;padding:11px 9px;
  text-align:center;cursor:pointer;transition:all .16s;}
.pmethod:hover{border-color:var(--inf);}
.pmethod.sel{border-color:var(--inf);background:#EEF3FF;}
.pmethod i{font-size:20px;color:var(--inf);display:block;margin-bottom:3px;}
.pmethod h6{font-weight:800;font-size:11.5px;color:var(--dk);margin:0;}
.pmethod small{color:var(--gy);font-size:9.5px;}

.fg2{margin-bottom:9px;}
.fg2 label{display:block;font-size:10px;font-weight:700;color:var(--gy);margin-bottom:3px;
  text-transform:uppercase;letter-spacing:.4px;}
.finput{width:100%;padding:7px 10px;border:2px solid var(--lg);border-radius:6px;
  font-size:12.5px;font-family:'Poppins',sans-serif;outline:none;transition:border-color .13s,box-shadow .13s;}
.finput:focus{border-color:var(--pr);box-shadow:0 0 0 3px rgba(198,40,40,.1);}
.finput.ok{border-color:var(--ok);}
.finput.err{border-color:var(--err);}
.row2{display:flex;gap:8px;flex-wrap:wrap;}
.half{flex:1;min-width:110px;}
.cty-row{display:flex;gap:6px;margin-bottom:9px;}
.cty-btn{flex:1;padding:6px;border:2px solid var(--lg);border-radius:6px;background:#fff;
  font-weight:700;font-size:10.5px;cursor:pointer;font-family:'Poppins',sans-serif;transition:all .14s;}
.cty-btn:hover{border-color:var(--inf);}
.cty-btn.act{border-color:var(--inf);background:linear-gradient(135deg,#1565C0,#42A5F5);color:#fff;}
.pay-btn{width:100%;padding:11px;border-radius:7px;border:none;
  background:linear-gradient(135deg,#1B5E20,var(--ok));color:#fff;font-weight:800;font-size:12.5px;
  cursor:pointer;font-family:'Poppins',sans-serif;display:flex;align-items:center;justify-content:center;
  gap:6px;margin-top:11px;transition:transform .12s,box-shadow .12s;}
.pay-btn:hover:not(:disabled){transform:translateY(-1px);box-shadow:0 6px 18px rgba(46,125,50,.3);}
.pay-btn:disabled{background:linear-gradient(135deg,#94A3B8,#CBD5E1);cursor:not-allowed;}
.gh-pay-btn{width:100%;padding:11px;border-radius:7px;border:none;
  background:linear-gradient(135deg,#0A1A50,#1845D4);color:#fff;font-weight:800;font-size:12.5px;
  cursor:pointer;font-family:'Poppins',sans-serif;display:flex;align-items:center;justify-content:center;
  gap:6px;margin-top:7px;transition:transform .12s;}
.gh-pay-btn:hover{transform:translateY(-1px);}
.mem-info{background:#EEF3FF;border:2px solid #C0CFFF;border-radius:7px;padding:8px 10px;margin-top:7px;font-size:10.5px;}
.offer-box{background:linear-gradient(135deg,#EDFAF4,#fff);border:2px solid #86EFAC;border-radius:7px;padding:9px 11px;margin-top:7px;}
.offer-box-hd{display:flex;justify-content:space-between;align-items:center;margin-bottom:3px;}
.offer-title{font-weight:800;color:#0D7A3E;font-size:11px;display:flex;align-items:center;gap:4px;}
.offer-disc{font-size:1.1rem;font-weight:800;color:var(--ok);font-family:var(--mono);}
.tot-disp{text-align:center;padding:9px;background:var(--g-lt);border-radius:7px;border:2px solid var(--pr-l);
  font-size:1.35rem;font-weight:800;color:var(--dk);margin-bottom:11px;font-family:var(--mono);}
.cust-info-bar{background:#EEF3FF;border:2px solid #C0CFFF;border-radius:7px;padding:7px 11px;
  text-align:center;margin-bottom:11px;font-weight:700;font-size:12px;color:#1565C0;font-family:var(--mono);}
.gh-info{background:#EEF3FF;border:2px solid #C0CFFF;border-radius:7px;padding:9px;text-align:center;margin-bottom:10px;}
.gh-info i{color:#1565C0;font-size:1.1rem;margin-bottom:3px;display:block;}
.gh-info p{color:#1845D4;font-weight:700;font-size:11px;}

/* RECEIPT */
.recmod{display:none;position:fixed;inset:0;background:rgba(0,0,0,.75);backdrop-filter:blur(5px);
  z-index:3000;align-items:flex-start;justify-content:center;overflow-y:auto;padding:10px;}
.recmod.open{display:flex;}
.recbox{background:#fff;padding:16px;border-radius:11px;width:100%;max-width:460px;margin:auto;
  position:relative;animation:siu .2s ease;}

/* CANCEL MODAL */
#cxmod .mbox{border:2px solid var(--pr-l);}

/* EMPTY / LOADING */
.noc{display:flex;flex-direction:column;align-items:center;justify-content:center;padding:20px;
  text-align:center;color:var(--gy);}
.noc i{font-size:24px;margin-bottom:6px;color:var(--pr-l);}
.noc p{font-size:12px;font-weight:600;}
.noc .hint{font-size:10px;opacity:.65;margin-top:3px;}
.ld{display:flex;flex-direction:column;align-items:center;justify-content:center;padding:20px;
  color:var(--pr);gap:5px;font-size:11.5px;}
.spinner{display:inline-block;width:13px;height:13px;border:2px solid rgba(255,255,255,.3);
  border-radius:50%;border-top-color:#fff;animation:spin .7s linear infinite;}
@keyframes spin{to{transform:rotate(360deg)}}

/* TOAST */
.pntf{position:fixed;right:10px;z-index:9999;display:flex;align-items:center;gap:5px;
  padding:7px 12px;border-radius:7px;color:#fff;font-size:11px;font-weight:600;
  font-family:'Poppins',sans-serif;box-shadow:0 4px 14px rgba(0,0,0,.18);
  animation:sir .15s ease;max-width:80vw;}
@keyframes sir{from{transform:translateX(100%);opacity:0}to{transform:translateX(0);opacity:1}}

/* STATUS BAR BOTTOM */
.sbar-bottom{position:fixed;bottom:0;left:0;right:0;height:22px;background:var(--dk);
  color:#FFCDD2;font-size:9.5px;font-family:var(--mono);display:flex;align-items:center;
  padding:0 10px;gap:12px;z-index:9998;}
.sbar-bottom .sk{display:inline-flex;align-items:center;gap:3px;}
.sbar-bottom kbd{background:rgba(255,255,255,.15);border:1px solid rgba(255,255,255,.25);
  border-radius:2px;padding:0 3px;font-size:8.5px;font-family:var(--mono);}

/* receipt thermal */
.rw{font-family:'Courier New',monospace;max-width:300px;margin:0 auto;font-size:10px;}
.rh{text-align:center;margin-bottom:6px;border-bottom:2px dashed #000;padding-bottom:4px;}
.rh h1{font-size:14px;font-weight:800;}.rh h2,.rh h3{font-size:11px;font-weight:700;}
.is{margin-bottom:6px;padding-bottom:4px;border-bottom:2px dashed #000;}
.ir{display:flex;justify-content:space-between;font-size:9.5px;margin-bottom:1px;}
.il{font-weight:700;}
.rt{width:100%;border-collapse:collapse;font-size:9.5px;margin-bottom:6px;}
.rt th{border-bottom:2px solid #000;padding:2px 0;text-align:left;}
.rt td{border-bottom:1px dashed #ccc;padding:2px 0;}
.ft{text-align:center;padding-top:4px;border-top:2px dashed #000;font-size:9px;}
.kb{background:#000;color:#fff;padding:2px 7px;border-radius:3px;text-align:center;
  margin:2px 0;font-size:10.5px;font-weight:800;letter-spacing:1px;}
</style>
</head>
<body>
<form id="form1" runat="server">
<asp:ScriptManager ID="SM1" runat="server" EnablePageMethods="true"></asp:ScriptManager>

<asp:UpdatePanel ID="upTimer" runat="server" UpdateMode="Conditional">
 <Triggers>
  <asp:AsyncPostBackTrigger ControlID="timerRefresh" EventName="Tick"/>
  <asp:AsyncPostBackTrigger ControlID="ddlDepartment" EventName="SelectedIndexChanged"/>
 </Triggers>
 <ContentTemplate>
  <asp:Timer ID="timerRefresh" runat="server" Interval="10000" OnTick="timerRefresh_Tick"/>
  <asp:Label ID="lblTodaySales" runat="server" Text="Rs 0.00" style="display:none"></asp:Label>
  <asp:Label ID="lblTodayBills" runat="server" Text="0" style="display:none"></asp:Label>
 </ContentTemplate>
</asp:UpdatePanel>

<asp:HiddenField ID="hdnSelectedDeptID" runat="server"/>
<asp:HiddenField ID="hdnSelectedDeptName" runat="server"/>
<asp:HiddenField ID="hdnEmpID" runat="server"/>
<asp:HiddenField ID="hdnEmployeeName" runat="server"/>
<asp:HiddenField ID="hdnIsWaiter" runat="server"/>
<asp:HiddenField ID="hdnIsCashier" runat="server"/>
<asp:HiddenField ID="hdnIsManager" runat="server"/>

<!-- HEADER -->
<div class="hdr">
  <div class="logo"><i class="fa fa-cash-register"></i> LGK POS</div>

  <div class="dg">
    <span class="dl"><i class="fa fa-store"></i> Dept</span>
    <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="dsel" AutoPostBack="false"></asp:DropDownList>
  </div>

  <div class="btg">
    <label class="rl act" data-t="Club Member"><input type="radio" name="bt" value="Club Member" checked/><i class="fa fa-id-card"></i> Member <kbd>F5</kbd></label>
    <label class="rl" data-t="Guest House"><input type="radio" name="bt" value="Guest House"/><i class="fa fa-bed"></i> GH <kbd>F6</kbd></label>
    <label class="rl" data-t="Affiliated Member"><input type="radio" name="bt" value="Affiliated Member"/><i class="fa fa-handshake"></i> Affl <kbd>F7</kbd></label>
  </div>

  <div class="adt" id="adtBtn" onclick="toggleADT()" tabindex="0" title="Auto-Deliver (F8)">
    <div class="tog"></div>
    <span>Auto-Del <kbd style="font-family:monospace;font-size:8.5px;background:rgba(0,0,0,.15);border-radius:2px;padding:0 3px;">F8</kbd></span>
  </div>

  <div class="hdr-acts">
    <div class="emp-pill"><i class="fa fa-user"></i><span id="empDisplay" runat="server">...</span></div>
    <asp:Button ID="btnGoCounterClose" runat="server" CssClass="hbtn cc" Text="Close" OnClick="btnGoCounterClose_Click" UseSubmitBehavior="true"/>
    <button type="button" class="hbtn logout" onclick="window.location='Login.aspx'" title="Logout"><i class="fa fa-sign-out-alt"></i></button>
  </div>
</div>

<!-- STATS BAR -->
<div class="sbar">
  <div class="sc"><div class="sv" id="sTodaySales">Rs 0</div><div class="sl">Today Sales</div></div>
  <div class="sc"><div class="sv" id="sTodayBills">0</div><div class="sl">Bills Paid</div></div>
  <div class="sc"><div class="sv" id="sActiveCnt">0</div><div class="sl"><span class="lv-dot"></span>Active</div></div>
  <div class="sc"><div class="sv" id="sDelivCnt">0</div><div class="sl">Delivered</div></div>
  <div class="sc"><div class="sv" id="sCartTotal">Rs 0</div><div class="sl">Cart Total</div></div>
  <div class="sc" style="max-width:80px;"><div class="sv" style="font-size:10px;" id="sTime">--:--</div><div class="sl">Time</div></div>
</div>

<!-- LAYOUT -->
<div class="layout" style="padding-bottom:22px;">

 <!-- LEFT -->
 <div class="left">

  <!-- KEYBOARD SHORTCUT BAR -->
  <div class="kb-bar">
    <span class="kk"><kbd>F1</kbd> Member Search</span>
    <span class="kk"><kbd>F2</kbd> Item Search</span>
    <span class="kk"><kbd>F3</kbd> Cart</span>
    <span class="kk"><kbd>F4</kbd> Live Bills</span>
    <span class="kk"><kbd>F5-F7</kbd> Bill Type</span>
    <span class="kk"><kbd>F8</kbd> Auto-Deliver</span>
    <span class="kk"><kbd>Enter</kbd> Place Order</span>
    <span class="kk"><kbd>1-9</kbd> Quick Add Item</span>
    <span class="kk"><kbd>ESC</kbd> Close</span>
  </div>

  <!-- MEMBER SEARCH -->
  <div class="mbar">
   <div class="mb-r">
    <!-- Club Member -->
    <div class="mbx mbx-cl vis" id="bxCl">
     <div class="mbx-hd"><i class="fa fa-id-card"></i> Club Member <kbd>F1</kbd></div>
     <div class="msr">
      <input type="text" id="txM" placeholder="Scan RFID / member no..." autocomplete="off"/>
      <button type="button" id="btnSM" title="Search (Enter)"><i class="fa fa-search"></i></button>
     </div>
     <div class="mres" id="rcM"></div>
    </div>
    <!-- Guest House -->
    <div class="mbx mbx-gh" id="bxGH">
     <div class="mbx-hd"><i class="fa fa-bed"></i> Guest House <kbd>F1</kbd></div>
     <div class="msr">
      <input type="text" id="txGH" placeholder="Room No e.g. 017..." autocomplete="off"/>
      <button type="button" id="btnSGH"><i class="fa fa-search"></i></button>
     </div>
     <div class="mres" id="ghc"></div>
    </div>
    <!-- Affiliated -->
    <div class="mbx mbx-af" id="bxAF">
     <div class="mbx-hd"><i class="fa fa-handshake"></i> Affiliated <kbd>F1</kbd></div>
     <div class="msr">
      <input type="text" id="txAF" placeholder="Intro / Member / Name..." autocomplete="off"/>
      <button type="button" id="btnSAF"><i class="fa fa-search"></i></button>
     </div>
     <div class="mres" id="rcAF"></div>
    </div>
   </div>
  </div>

  <!-- PRODUCT SEARCH BAR -->
  <div class="qsbar">
    <label><i class="fa fa-search"></i> Item Search <kbd>F2</kbd></label>
    <input type="text" id="txSrch" class="qsinp" placeholder="Type name or code..." autocomplete="off"/>
    <button type="button" id="btnRld" class="hbtn" style="padding:5px 9px;" title="Refresh"><i class="fa fa-sync-alt"></i></button>
  </div>

  <!-- CATEGORIES -->
  <div class="cats">
   <button class="cat act" data-c=""><i class="fa fa-th"></i> All <kbd>Alt+1</kbd></button>
   <button class="cat" data-c="Beverages"><i class="fa fa-coffee"></i> Beverages <kbd>Alt+2</kbd></button>
   <button class="cat" data-c="Snacks"><i class="fa fa-cookie-bite"></i> Snacks <kbd>Alt+3</kbd></button>
   <button class="cat" data-c="Main Course"><i class="fa fa-utensils"></i> Main <kbd>Alt+4</kbd></button>
   <button class="cat" data-c="Desserts"><i class="fa fa-ice-cream"></i> Desserts <kbd>Alt+5</kbd></button>
  </div>

  <!-- PRODUCT GRID -->
  <div class="pg" id="pgrid">
   <div class="noc" style="grid-column:1/-1">
    <i class="fa fa-store"></i>
    <p>Select a Department</p>
    <p class="hint">Use dropdown at top or press F2 to search</p>
   </div>
  </div>

 </div><!-- /left -->

 <!-- RIGHT -->
 <div class="right">

  <div class="rtabs">
   <button class="rtab act" data-p="cart"><i class="fa fa-shopping-cart"></i> Cart <kbd>F3</kbd> <span class="cnt" id="cartCnt" style="display:none">0</span></button>
   <button class="rtab" data-p="live"><i class="fa fa-bolt"></i> Live Bills <kbd>F4</kbd> <span class="cnt" id="liveCnt" style="display:none">0</span></button>
  </div>

  <!-- CART PANEL -->
  <div class="rpanel act" id="pCart">
   <div class="citems" id="citems">
    <div class="noc">
     <i class="fa fa-shopping-cart"></i>
     <p>Cart is empty</p>
     <p class="hint">Press 1-9 to add top items, or click products</p>
    </div>
   </div>
   <div class="cftr">
    <!-- Non-Member toggle -->
    <div class="nm-row">
     <button type="button" class="nmtog" id="btnNMT" onclick="toggleNM()"><i class="fa fa-user-slash"></i> Non-Member <kbd>F9</kbd></button>
     <input type="text" class="nminp" id="txNM" value="0" placeholder="Name / ID (default: 0)"/>
    </div>
    <!-- Table & Covers -->
    <div class="row2c">
     <div class="igl">
      <label><i class="fa fa-table"></i> Table <kbd>Tab</kbd></label>
      <input type="text" id="txTbl" class="tinp" placeholder="T-01"/>
     </div>
     <div class="igl" style="max-width:75px;">
      <label><i class="fa fa-users"></i> Covers</label>
      <input type="number" id="txCov" class="tinp" value="1" min="1" max="99"/>
     </div>
    </div>
    <!-- Totals -->
    <div class="tots-box" id="totbox">
     <div class="tot-row"><span>Subtotal</span><span>Rs 0.00</span></div>
     <div class="tot-row"><span>GST</span><span>Rs 0.00</span></div>
     <div class="tot-row grand"><span>TOTAL</span><span id="gtot">Rs 0.00</span></div>
    </div>
    <!-- Buttons -->
    <div class="obtn-row">
     <button type="button" id="btnSubmit"><i class="fa fa-check-circle"></i> Place Order <span id="adtTag"></span></button>
     <button type="button" id="btnClear" onclick="clrCart()"><i class="fa fa-trash"></i> <kbd>Del</kbd></button>
    </div>
   </div>
  </div>

  <!-- LIVE BILLS PANEL -->
  <div class="rpanel" id="pLive">
   <div class="cfilter">
    <input type="text" id="txBFilter" placeholder="Filter by member no..."/>
    <button class="ref-btn" onclick="ldLive()" title="Refresh (F4)"><i class="fa fa-sync-alt"></i></button>
   </div>
   <div class="live-list" id="livelist">
    <div class="noc"><i class="fa fa-bolt"></i><p>No active bills</p></div>
   </div>
  </div>

 </div><!-- /right -->

</div><!-- /layout -->

<!-- RECEIPT MODAL -->
<div class="recmod" id="recmod">
 <div class="recbox">
  <button style="position:absolute;top:9px;right:9px;width:26px;height:26px;border-radius:4px;background:#f5f5f5;border:none;cursor:pointer;font-size:15px;" onclick="$('#recmod').removeClass('open')">&times;</button>
  <h3 style="margin:0 0 9px;color:var(--pr);font-size:13px;padding-right:30px;"><i class="fa fa-receipt"></i> KOT / Receipt</h3>
  <div id="recbody"></div>
  <button class="hbtn" onclick="prt()" style="margin-top:10px;width:100%;justify-content:center;padding:9px;"><i class="fa fa-print"></i> Print <kbd style="font-family:monospace;background:rgba(255,255,255,.25);border-radius:2px;padding:0 4px;font-size:9px;">Ctrl+P</kbd></button>
 </div>
</div>

<!-- CANCEL MODAL -->
<div class="mbg" id="cxmod">
 <div class="mbox" style="border:2px solid var(--pr-l);">
  <div class="mhd" style="background:#FFF5F5;">
   <h3 style="color:#B71C1C;"><i class="fa fa-ban" style="color:#B71C1C;"></i> Cancel Order</h3>
   <button class="mcx2" id="btnCxX" title="Close (ESC)">&times;</button>
  </div>
  <div class="mbody">
   <div style="background:#FFF3E0;border-radius:5px;padding:6px 9px;margin-bottom:9px;border-left:4px solid var(--warn);font-size:11px;">
    Order <b id="cxoid">#</b> &mdash; KOT: <b id="cxkot">-</b>
   </div>
   <div class="fg2">
    <label><i class="fa fa-comment-alt"></i> Cancellation Reason *</label>
    <textarea id="cxrmk" class="finput" style="min-height:60px;resize:vertical;" placeholder="Enter reason..."></textarea>
   </div>
   <div style="display:flex;gap:5px;">
    <button class="ob ob-cx" style="flex:0;padding:8px 12px;" id="btnCxBk" title="Back (ESC)"><i class="fa fa-arrow-left"></i></button>
    <button class="pay-btn" style="margin:0;flex:1;" id="btnCxOk" title="Confirm (Enter)"><i class="fa fa-ban"></i> Confirm Cancel</button>
   </div>
  </div>
 </div>
</div>

<!-- PAYMENT MODAL -->
<div class="mbg" id="paymod">
 <div class="mbox pay-mbox">
  <div class="mhd">
   <h3 id="paymod-title"><i class="fa fa-layer-group"></i> Consolidated Payment</h3>
   <button class="mcx2" onclick="closePayMod()" title="Close (ESC)">&times;</button>
  </div>
  <div class="mbody">
   <input type="hidden" id="pmBillIds"/>
   <input type="hidden" id="pmPayType"/>
   <input type="hidden" id="pmCardSub" value=""/>
   <input type="hidden" id="pmIsGH" value="0"/>
   <input type="hidden" id="pmDeptName"/>
   <input type="hidden" id="pmDeptCode"/>
   <input type="hidden" id="pmMemberNo"/>
   <input type="hidden" id="pmBillTo"/>
   <input type="hidden" id="pmRoomNo"/>
   <input type="hidden" id="pmCovers"/>
   <input type="hidden" id="pmKotNo"/>

   <div class="cust-info-bar" id="pmCustBar">Member: -</div>
   <div id="pmKotItems" style="max-height:190px;overflow-y:auto;margin-bottom:9px;border:2px solid var(--pr-l);border-radius:7px;padding:6px;font-size:11px;"></div>
   <div class="tot-disp" id="pmTotDisp">Rs 0.00</div>

   <div id="pmMethodsSec">
    <div class="pmethods">
     <div class="pmethod" id="pm_member" onclick="selPM(this,'MemberCard')" tabindex="0" title="Member Card (Alt+M)"><i class="fa fa-id-card"></i><h6>Membership Card</h6><small>Deduct from account</small></div>
     <div class="pmethod" id="pm_bank" onclick="selPM(this,'BankCard')" tabindex="0" title="Bank Card (Alt+B)"><i class="fa fa-credit-card"></i><h6>Bank Card</h6><small>Debit / Credit</small></div>
    </div>
   </div>

   <!-- Member card -->
   <div id="pmMemSec" style="display:none;">
    <div id="pmMemNotice" style="background:#E8F5E9;border:2px solid #A5D6A7;border-radius:6px;padding:6px 10px;margin-bottom:7px;font-size:11px;font-weight:700;color:#2E7D32;display:flex;align-items:center;gap:4px;"><i class="fa fa-spinner fa-spin"></i> Validating...</div>
    <div class="fg2">
     <label><i class="fa fa-id-card"></i> Membership Card / RFID (Scan or type, press Enter)</label>
     <input type="text" id="pmMemCard" class="finput" placeholder="Scan RFID or enter member no" autocomplete="off"/>
    </div>
    <div id="pmMemInfo" style="display:none;"></div>
   </div>

   <!-- Bank card -->
   <div id="pmBankSec" style="display:none;">
    <div class="cty-row">
     <button type="button" class="cty-btn" id="ctyDebit" onclick="setCTY('Debit')" title="Debit (Alt+D)"><i class="fa fa-university"></i> Debit</button>
     <button type="button" class="cty-btn" id="ctyCredit" onclick="setCTY('Credit')" title="Credit (Alt+C)"><i class="fa fa-credit-card"></i> Credit</button>
    </div>
    <div class="fg2">
     <label><i class="fa fa-user"></i> Cardholder Name</label>
     <input type="text" id="pmCHN" class="finput" placeholder="Name on card" maxlength="100"/>
    </div>
    <div class="row2">
     <div class="half fg2">
      <label><i class="fa fa-credit-card"></i> Card Number</label>
      <input type="text" id="pmCardNo" class="finput" placeholder="Card number" maxlength="23" oninput="onBankCard(this)" autocomplete="off"/>
      <div id="pmCardMsg" style="font-size:9.5px;margin-top:2px;"></div>
     </div>
     <div style="flex:0 0 105px;" class="fg2">
      <label><i class="fa fa-calendar"></i> Expiry MM/YY</label>
      <input type="text" id="pmExpiry" class="finput" placeholder="MM/YY" maxlength="5" oninput="fmtExp(this)" onblur="valExp(this)"/>
     </div>
    </div>
    <div class="fg2">
     <label><i class="fa fa-check-circle"></i> Auth Code (6 digits)</label>
     <input type="text" id="pmAuth" class="finput" placeholder="6-digit auth code" maxlength="6" oninput="this.value=this.value.replace(/[^0-9]/g,'')"/>
    </div>
    <div id="pmOfferSec" style="display:none;"></div>
   </div>

   <!-- GH -->
   <div id="pmGHSec" style="display:none;margin-top:9px;">
    <div class="gh-info"><i class="fa fa-hotel"></i><p>Guest House Bill - click below to finalize</p></div>
    <button type="button" class="gh-pay-btn" id="pmGHBtn" onclick="doGHPay()"><i class="fa fa-hotel"></i> Mark as Guest House &amp; Generate Receipt</button>
   </div>

   <div style="display:flex;gap:9px;margin-top:11px;border-top:2px dashed var(--pr-l);padding-top:9px;">
    <div style="flex:1;">
     <div style="font-size:9.5px;font-weight:700;color:var(--gy);text-transform:uppercase;margin-bottom:2px;">Net Payable</div>
     <input type="number" id="pmSum" class="finput" value="0" readonly style="font-size:1.1rem;font-weight:800;text-align:center;font-family:var(--mono);"/>
    </div>
   </div>

   <button type="button" class="pay-btn" id="pmPayBtn" onclick="doPayment()"><i class="fa fa-check-circle"></i> Accept Payment <kbd style="font-family:monospace;background:rgba(255,255,255,.2);border-radius:2px;padding:0 5px;font-size:9.5px;">Enter</kbd></button>
  </div>
 </div>
</div>

<!-- STATUS BAR BOTTOM -->
<div class="sbar-bottom">
  <span class="sk"><kbd>F1</kbd> Search</span>
  <span class="sk"><kbd>F2</kbd> Items</span>
  <span class="sk"><kbd>F3</kbd> Cart</span>
  <span class="sk"><kbd>F4</kbd> Live</span>
  <span class="sk"><kbd>F5</kbd> Member</span>
  <span class="sk"><kbd>F6</kbd> GH</span>
  <span class="sk"><kbd>F7</kbd> Affl</span>
  <span class="sk"><kbd>F8</kbd> AutoDel</span>
  <span class="sk"><kbd>F9</kbd> Non-Mbr</span>
  <span class="sk"><kbd>1-9</kbd> Quick Add</span>
  <span class="sk"><kbd>Enter</kbd> Order</span>
  <span class="sk"><kbd>ESC</kbd> Close</span>
  <span class="sk"><kbd>Del</kbd> Clear Cart</span>
</div>

<script>
    // =================== STATE ===================
    var cart = [], mem = null, afm = null, ghi = null;
    var bt = 'Club Member', nmOn = false, autoDeliver = false;
    var isSubmitting = false, srch = false, afs = false, ghs = false;
    var cxOId = null, cxKot = '';
    var kbt = null, aft = null, ght = null, sb = '', sl = 0;
    var allProds = [];
    var pmCurTotal = 0, pmCurMemberNo = '', pmCurBillTo = '', pmCurRoomNo = '';
    var pmCardData = null, pmDiscData = null, pmBillsList = [], pmItemsList = [];
    var selPayType = '', cardSubType = '', isGHPayment = false;
    var eid = '', enm = '';
    var focusedProdIdx = -1;

    $(function () {
        eid = $('#<%= hdnEmpID.ClientID %>').val() || '';
    enm = $('#empDisplay').text().trim();
    initDept(); initBT(); initMS(); initGH(); initAF(); initPS();
    initUI(); initCx(); initKeys();
    ldCart(); updCnt();
    showBUI('Club Member');
    tickTime();
    setInterval(tickTime, 30000);
    setInterval(function () {
        $('#sTodaySales').text($('#<%= lblTodaySales.ClientID %>').text());
        $('#sTodayBills').text($('#<%= lblTodayBills.ClientID %>').text());
    }, 2000);
    setTimeout(function () { $('#txM').focus(); }, 250);
    initPMKeys();
});

    function tickTime() {
        var now = new Date();
        var hh = now.getHours() % 12 || 12, mm = String(now.getMinutes()).padStart(2, '0'), ap = now.getHours() >= 12 ? 'PM' : 'AM';
        $('#sTime').text(hh + ':' + mm + ' ' + ap);
    }

    // =================== DEPT ===================
    function initDept() {
        var el = $('#<%= ddlDepartment.ClientID %>')[0];
    el.onchange = function () {
        var id = this.value, nm = this.options[this.selectedIndex] ? this.options[this.selectedIndex].text : '';
        if (id && id.trim()) {
            $('#<%= hdnSelectedDeptID.ClientID %>').val(id);
            $('#<%= hdnSelectedDeptName.ClientID %>').val(nm);
            ntf('Dept: ' + nm, 'ok'); ldProds(); ldLive();
        } else {
            $('#<%= hdnSelectedDeptID.ClientID %>').val('');
            $('#<%= hdnSelectedDeptName.ClientID %>').val('');
            $('#pgrid').html('<div class="noc" style="grid-column:1/-1"><i class="fa fa-store"></i><p>Select a department first</p></div>');
        }
    };
    var iv = $('#<%= ddlDepartment.ClientID %>').val();
    if (iv && iv.trim()) { ldProds(); ldLive(); }
}
function gDid() { return $('#<%= hdnSelectedDeptID.ClientID %>').val() || ''; }
function gDnm() { return $('#<%= hdnSelectedDeptName.ClientID %>').val() || ''; }

// =================== BILL TYPE ===================
function initBT() {
    $('input[name="bt"]').on('change', function () {
        var t = $(this).val(); bt = t;
        $('.rl').removeClass('act'); $(this).closest('.rl').addClass('act');
        if (nmOn) toggleNM();
        resetM(); showBUI(t);
        ntf('Bill to: ' + t, 'info');
    });
}
function resetM() {
    mem = null; afm = null; ghi = null;
    $('#rcM,#rcAF,#ghc').html('');
    $('#txM,#txAF,#txGH').val('');
}
function showBUI(t) {
    $('#bxCl,#bxGH,#bxAF').removeClass('vis');
    if (t === 'Club Member') { $('#bxCl').addClass('vis'); setTimeout(function () { $('#txM').focus(); }, 60); }
    else if (t === 'Guest House') { $('#bxGH').addClass('vis'); setTimeout(function () { $('#txGH').focus(); }, 60); }
    else if (t === 'Affiliated Member') { $('#bxAF').addClass('vis'); setTimeout(function () { $('#txAF').focus(); }, 60); }
}

// =================== AUTO DELIVER ===================
function toggleADT() {
    autoDeliver = !autoDeliver;
    var $b = $('#adtBtn');
    $b.toggleClass('on', autoDeliver);
    $('#adtTag').html(autoDeliver ? '<span style="font-size:8.5px;background:rgba(255,255,255,.25);padding:1px 5px;border-radius:3px;margin-left:3px;">AUTO-DEL</span>' : '');
    ntf(autoDeliver ? 'Auto-Deliver ON' : 'Auto-Deliver OFF', autoDeliver ? 'ok' : 'info');
}

// =================== NON MEMBER ===================
function toggleNM() {
    nmOn = !nmOn;
    var $b = $('#btnNMT'), $i = $('#txNM');
    $b.toggleClass('on', nmOn);
    $b.html(nmOn ? '<i class="fa fa-times"></i> Cancel <kbd>F9</kbd>' : '<i class="fa fa-user-slash"></i> Non-Member <kbd>F9</kbd>');
    $i.toggleClass('show', nmOn);
    if (nmOn) {
        $('input[name="bt"]').prop('checked', false);
        $('.rl').removeClass('act'); bt = 'Non Member';
        resetM(); showBUI('Non Member');
        setTimeout(function () { $i.focus(); }, 60);
        ntf('Non-Member mode ON', 'info');
    } else {
        $('input[name="bt"][value="Club Member"]').prop('checked', true).trigger('change');
    }
}

// =================== MEMBER SEARCH ===================
function initMS() {
    var $i = $('#txM');
    $i.on('input', function () {
        var v = $(this).val().trim();
        if (kbt) { clearTimeout(kbt); kbt = null; }
        if (!v) { mem = null; $('#rcM').html(''); return; }
        if (v.length >= 2) { setMS('t'); kbt = setTimeout(function () { kbt = null; doMS($i.val().trim()); }, 380); }
    });
    $i.on('keydown', function (e) {
        var now = Date.now();
        if (e.key === 'Enter') { e.preventDefault(); if (kbt) { clearTimeout(kbt); kbt = null; } var v = $(this).val().trim(); if (v && !srch) doMS(v); return; }
        if (e.key.length === 1 && (now - sl) < 40) sb += e.key; else sb = e.key; sl = now;
    });
    $i.on('keyup', function (e) {
        if (e.key === 'Enter' && sb.length >= 4) { var sv = sb; sb = ''; if (!srch) { doMS(sv); } } else if (e.key !== 'Enter') sb = '';
    });
    $i.on('paste', function (e) {
        e.preventDefault();
        var p = e.originalEvent.clipboardData.getData('text').trim();
        if (p && !srch) { $(this).val(p); if (kbt) { clearTimeout(kbt); kbt = null; } doMS(p); }
    });
    $('#btnSM').on('click', function () {
        if (kbt) { clearTimeout(kbt); kbt = null; }
        var v = $('#txM').val().trim();
        if (!v) { ntf('Enter member no or scan!', 'warn'); $('#txM').focus(); return; }
        if (!srch) doMS(v);
    });
}
function doMS(val) {
    if (!val || srch) return; srch = true;
    var $c = $('#rcM');
    $c.html('<span style="color:#BF360C;"><i class="fa fa-spinner fa-spin"></i> Searching...</span>');
    $.ajax({
        type: 'POST', url: 'CombinedPOS.aspx/GetMember', data: JSON.stringify({ search: val }),
        contentType: 'application/json;charset=utf-8', dataType: 'json', timeout: 9000,
        success: function (r) {
            r = r.d;
            if (r && r.success) {
                mem = r;
                $c.html('<span style="color:var(--ok);font-weight:700;"><i class="fa fa-check-circle"></i> ' + (r.DisplayName || r.Name) + ' [' + r.CardNo + ']</span>');
                ntf('Member: ' + (r.DisplayName || r.Name), 'ok');
                // Auto-focus search after member found
                setTimeout(function () { $('#txSrch').focus(); }, 300);
            } else {
                mem = null;
                $c.html('<span style="color:var(--err);font-weight:700;"><i class="fa fa-times-circle"></i> ' + (r && r.message ? r.message : 'Not found') + '</span>');
                ntf(r && r.message ? r.message : 'Member not found', 'err');
                setTimeout(function () { $c.html(''); }, 2500);
            }
        },
        error: function () { mem = null; $c.html('<span style="color:var(--err);">Server error</span>'); ntf('Server error', 'err'); },
        complete: function () { setTimeout(function () { srch = false; }, 300); }
    });
}

// =================== GUEST HOUSE ===================
function initGH() {
    $('#txGH').on('input', function () {
        var v = $(this).val().trim(); if (ght) { clearTimeout(ght); ght = null; }
        if (!v) { ghi = null; $('#ghc').html(''); return; }
        if (v.length >= 2) ght = setTimeout(function () { ght = null; doGH($('#txGH').val().trim()); }, 450);
    });
    $('#txGH').on('keydown', function (e) { if (e.key === 'Enter') { e.preventDefault(); var v = $(this).val().trim(); if (v) { if (ght) clearTimeout(ght); doGH(v); } } });
    $('#btnSGH').on('click', function () { var v = $('#txGH').val().trim(); if (v) { if (ght) clearTimeout(ght); doGH(v); } });
}
function doGH(rn) {
    if (ghs) return; ghs = true;
    $('#ghc').html('<span style="color:#2E7D32;"><i class="fa fa-spinner fa-spin"></i></span>');
    $.ajax({
        type: 'POST', url: 'CombinedPOS.aspx/GetRoomInfo', data: JSON.stringify({ roomNo: rn }),
        contentType: 'application/json;charset=utf-8', dataType: 'json', timeout: 9000,
        success: function (r) {
            r = r.d;
            if (r && r.success) {
                ghi = r; $('#ghc').html('<span style="color:var(--ok);font-weight:700;"><i class="fa fa-check-circle"></i> Room ' + r.RoomNo + ' - ' + r.GuestName + '</span>');
                ntf('Room ' + r.RoomNo, 'ok');
                setTimeout(function () { $('#txSrch').focus(); }, 300);
            } else { ghi = null; $('#ghc').html('<span style="color:var(--err);font-weight:700;"><i class="fa fa-times-circle"></i> ' + (r && r.message ? r.message : 'Not found') + '</span>'); ntf('Room not found', 'err'); }
        },
        error: function () { ghi = null; $('#ghc').html('<span style="color:var(--err);">Server error</span>'); },
        complete: function () { setTimeout(function () { ghs = false; }, 300); }
    });
}

// =================== AFFILIATED ===================
function initAF() {
    $('#txAF').on('input', function () {
        var v = $(this).val().trim(); if (aft) { clearTimeout(aft); aft = null; }
        if (!v) { afm = null; $('#rcAF').html(''); return; }
        if (v.length >= 2) aft = setTimeout(function () { aft = null; doAF($('#txAF').val().trim()); }, 380);
    });
    $('#txAF').on('keydown', function (e) { if (e.key === 'Enter') { e.preventDefault(); var v = $(this).val().trim(); if (v) { if (aft) clearTimeout(aft); doAF(v); } } });
    $('#btnSAF').on('click', function () { var v = $('#txAF').val().trim(); if (v) { if (aft) clearTimeout(aft); doAF(v); } });
}
function doAF(val) {
    if (!val || afs) return; afs = true;
    $('#rcAF').html('<span style="color:#6A1B9A;"><i class="fa fa-spinner fa-spin"></i></span>');
    $.ajax({
        type: 'POST', url: 'CombinedPOS.aspx/SearchAffiliatedMember', data: JSON.stringify({ search: val }),
        contentType: 'application/json;charset=utf-8', dataType: 'json', timeout: 9000,
        success: function (r) {
            r = r.d;
            if (r && r.success && r.data && r.data.length) {
                if (r.data.length === 1) {
                    afm = r.data[0];
                    $('#rcAF').html('<span style="color:var(--ok);font-weight:700;"><i class="fa fa-check-circle"></i> ' + afm.MemberName + ' [' + afm.ClubName + ']</span>');
                    ntf('Found: ' + afm.MemberName, 'ok');
                    setTimeout(function () { $('#txSrch').focus(); }, 300);
                } else {
                    var h = '<div style="font-size:10px;font-weight:700;color:#6A1B9A;margin-bottom:3px;">' + r.data.length + ' results - tap to select</div>';
                    r.data.forEach(function (m, i) {
                        h += '<div class="afl" data-i="' + i + '" tabindex="0" style="cursor:pointer;padding:3px 6px;border-radius:4px;border:1.5px solid #CE93D8;margin-bottom:3px;background:#fff;font-size:10px;font-weight:700;">' + m.MemberName + ' - ' + m.ClubName + '</div>';
                    });
                    $('#rcAF').html(h);
                    $('#rcAF .afl').on('click keydown', function (e) {
                        if (e.type === 'click' || e.key === 'Enter') {
                            afm = r.data[parseInt($(this).data('i'))];
                            $('#rcAF').html('<span style="color:var(--ok);font-weight:700;"><i class="fa fa-check-circle"></i> ' + afm.MemberName + '</span>');
                            ntf('Selected: ' + afm.MemberName, 'ok');
                        }
                    });
                }
            } else {
                afm = null; $('#rcAF').html('<span style="color:var(--err);font-weight:700;"><i class="fa fa-times-circle"></i> ' + (r && r.message ? r.message : 'Not found') + '</span>');
                ntf('No affiliated member found', 'err');
                setTimeout(function () { $('#rcAF').html(''); }, 2500);
            }
        },
        error: function () { afm = null; $('#rcAF').html('<span style="color:var(--err);">Server error</span>'); },
        complete: function () { setTimeout(function () { afs = false; }, 300); }
    });
}

// =================== PRODUCT SEARCH ===================
function initPS() {
    var t2 = null;
    $('#txSrch').on('input', function () {
        if (t2) clearTimeout(t2);
        t2 = setTimeout(function () { t2 = null; ldProds(); }, 280);
    });
    $('#txSrch').on('keydown', function (e) {
        if (e.key === 'ArrowDown') { e.preventDefault(); focusedProdIdx = 0; focusProd(); }
        if (e.key === 'Enter') { e.preventDefault(); if (allProds.length > 0) addC(allProds[0]); }
        e.stopPropagation();
    });
    $('#btnRld').on('click', function () {
        $(this).find('i').addClass('fa-spin');
        setTimeout(function () { $('#btnRld i').removeClass('fa-spin'); }, 400);
        ldProds();
    });
    $('.cats').on('click', '.cat', function () {
        $('.cat').removeClass('act'); $(this).addClass('act'); ldProds();
    });
}

function ldProds() {
    var did = gDid();
    if (!did) { $('#pgrid').html('<div class="noc" style="grid-column:1/-1"><i class="fa fa-store"></i><p>Select a department first</p></div>'); return; }
    var cat = $('.cat.act').data('c') || '', sv = $('#txSrch').val().trim();
    $('#pgrid').html('<div class="ld" style="grid-column:1/-1"><i class="fa fa-spinner fa-spin fa-2x"></i><span>Loading...</span></div>');
    $.ajax({
        type: 'POST', url: 'CombinedPOS.aspx/GetProducts',
        data: JSON.stringify({ search: sv, deptID: did, category: cat }),
        contentType: 'application/json;charset=utf-8', dataType: 'json', timeout: 10000,
        success: function (r) {
            if (!r.d || !r.d.success) { $('#pgrid').html('<div class="noc" style="grid-column:1/-1"><i class="fa fa-exclamation-triangle"></i><p>' + (r.d ? r.d.message : 'Failed') + '</p></div>'); return; }
            allProds = r.d.data || []; rndrProds(allProds);
        },
        error: function () { $('#pgrid').html('<div class="noc" style="grid-column:1/-1"><i class="fa fa-exclamation-triangle"></i><p>Failed to load</p></div>'); }
    });
}

function rndrProds(prods) {
    var $g = $('#pgrid');
    if (!prods.length) { $g.html('<div class="noc" style="grid-column:1/-1"><i class="fa fa-box-open"></i><p>No products found</p></div>'); return; }
    var h = '';
    prods.forEach(function (p, i) {
        var img = p.image || 'https://placehold.co/120x80/FFF3E0/C62828?text=Food';
        var num = i < 9 ? '<span class="nmb">' + (i + 1) + '</span>' : '';
        h += '<div class="pc2" data-id="' + p.id + '" data-nm="' + String(p.name).replace(/"/g, '&quot;') + '" data-pr="' + p.price + '" data-gst="' + (p.gst || 0) + '" data-img="' + img + '" data-idx="' + i + '" tabindex="0" role="button" aria-label="' + p.name + ' Rs ' + p.price + '">'
            + num
            + '<img src="' + img + '" alt="" loading="lazy" onerror="this.src=\'https://placehold.co/120x80/FFF3E0/C62828?text=Food\'">'
            + '<div class="nm">' + p.name + '</div>'
            + '<div class="gst-lbl">GST: ' + (p.gst || 0) + '%</div>'
            + '<div class="pr">Rs ' + parseFloat(p.price).toFixed(0) + '</div></div>';
    });
    $g.html(h);
    $g.off('click.pc').on('click.pc', '.pc2', function () {
        var $c = $(this);
        addC({ id: $c.data('id'), name: $c.data('nm'), price: parseFloat($c.data('pr')), gst: parseInt($c.data('gst')) || 0, image: $c.data('img') });
        $c.css('transform', 'scale(.93)');
        setTimeout(function () { $c.css('transform', ''); }, 130);
    });
    // Keyboard nav on grid
    $g.off('keydown.pc').on('keydown.pc', '.pc2', function (e) {
        if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            var $c = $(this);
            addC({ id: $c.data('id'), name: $c.data('nm'), price: parseFloat($c.data('pr')), gst: parseInt($c.data('gst')) || 0, image: $c.data('img') });
        }
        if (e.key === 'ArrowRight') { e.preventDefault(); var n = $(this).next('.pc2'); if (n.length) n.focus(); }
        if (e.key === 'ArrowLeft') { e.preventDefault(); var p = $(this).prev('.pc2'); if (p.length) p.focus(); }
        if (e.key === 'ArrowDown') {
            e.preventDefault();
            var cols = Math.round($g.width() / 126);
            var idx = parseInt($(this).data('idx')) + cols;
            var nx = $g.find('.pc2[data-idx="' + idx + '"]');
            if (nx.length) nx.focus();
        }
        if (e.key === 'ArrowUp') {
            e.preventDefault();
            var cols2 = Math.round($g.width() / 126);
            var idx2 = parseInt($(this).data('idx')) - cols2;
            if (idx2 >= 0) { var px = $g.find('.pc2[data-idx="' + idx2 + '"]'); if (px.length) px.focus(); }
            else { $('#txSrch').focus(); }
        }
    });
}

function focusProd() {
    var $p = $('#pgrid .pc2[data-idx="' + focusedProdIdx + '"]');
    if ($p.length) $p.focus();
}

// =================== CART ===================
function addC(item) {
    var ex = null;
    for (var i = 0; i < cart.length; i++) { if (cart[i].id == item.id) { ex = cart[i]; break; } }
    if (ex) ex.qty++;
    else cart.push({ id: item.id, name: item.name, price: parseFloat(item.price), gst: item.gst || 0, image: item.image, qty: 1 });
    rndrCart(); updCnt(); svCart();
    ntf(item.name + ' added', 'ok');
}

function rndrCart() {
    var $c = $('#citems'); $c.empty();
    if (!cart.length) {
        $c.html('<div class="noc"><i class="fa fa-shopping-cart"></i><p>Cart is empty</p><p class="hint">Press 1-9 to add top items, or click products</p></div>');
        updTot(); return;
    }
    var h = '';
    cart.forEach(function (item, i) {
        var ls = item.price * item.qty, lg = ls * (item.gst || 0) / 100, lt = ls + lg;
        h += '<div class="ci">'
            + '<div class="inf"><div class="inm">' + item.name + '</div><div class="ipr">Rs ' + item.price.toFixed(0) + ' x' + item.qty + ' = Rs ' + lt.toFixed(0) + (item.gst ? ' (GST ' + item.gst + '%)' : '') + '</div></div>'
            + '<div class="qty">'
            + '<button ' + (item.qty <= 1 ? 'disabled' : '') + ' data-i="' + i + '" data-d="-1" title="Decrease">-</button>'
            + '<span>' + item.qty + '</span>'
            + '<button data-i="' + i + '" data-d="1" title="Increase">+</button>'
            + '</div>'
            + '<button class="del-btn" data-di="' + i + '" title="Remove (Del)"><i class="fa fa-times"></i></button>'
            + '</div>';
    });
    $c.html(h);
    $c.off('click.q').on('click.q', '.qty button', function () { cqty(parseInt($(this).data('i')), parseInt($(this).data('d'))); });
    $c.off('click.d').on('click.d', '.del-btn', function () { cart.splice(parseInt($(this).data('di')), 1); rndrCart(); updCnt(); svCart(); });
    updTot();
}

function cqty(i, d) {
    if (!cart[i]) return;
    cart[i].qty += d;
    if (cart[i].qty <= 0) cart.splice(i, 1);
    rndrCart(); updCnt(); svCart();
}

function updCnt() {
    var n = 0; cart.forEach(function (x) { n += x.qty; });
    var $c = $('#cartCnt');
    $c.text(n);
    n === 0 ? $c.hide() : $c.show();
    var sub = 0, gst = 0;
    cart.forEach(function (i) { var ls = i.price * i.qty; sub += ls; gst += ls * (i.gst || 0) / 100; });
    $('#sCartTotal').text('Rs ' + (sub + gst).toFixed(0));
}

function updTot() {
    var sub = 0, gst = 0;
    cart.forEach(function (item) { var ls = item.price * item.qty; sub += ls; gst += ls * (item.gst || 0) / 100; });
    var tot = sub + gst;
    $('#totbox').html(
        '<div class="tot-row"><span>Subtotal</span><span>Rs ' + sub.toFixed(2) + '</span></div>'
        + '<div class="tot-row"><span>GST</span><span>Rs ' + gst.toFixed(2) + '</span></div>'
        + '<div class="tot-row grand"><span>TOTAL</span><span id="gtot">Rs ' + tot.toFixed(2) + '</span></div>'
    );
}

function clrCart() {
    if (!cart.length) return;
    if (confirm('Clear all items from cart?')) { cart = []; rndrCart(); updCnt(); svCart(); ntf('Cart cleared', 'info'); }
}
function svCart() { try { localStorage.setItem('cpos1', JSON.stringify(cart)); } catch (e) { } }
function ldCart() { try { var s = localStorage.getItem('cpos1'); if (s) { cart = JSON.parse(s); rndrCart(); } } catch (e) { } }

// =================== UI ===================
function initUI() {
    $('.rtabs').on('click', '.rtab', function () {
        var p = $(this).data('p');
        $('.rtab').removeClass('act'); $(this).addClass('act');
        $('.rpanel').removeClass('act');
        var pid = 'p' + p.charAt(0).toUpperCase() + p.slice(1);
        $('#' + pid).addClass('act');
        if (p === 'live') ldLive();
    });
    $('#btnSubmit').on('click', subOrder);
    $('#txCov').on('input', function () { var v = parseInt($(this).val()); if (isNaN(v) || v < 1) $(this).val(1); if (v > 99) $(this).val(99); });
    $('#txCov,#txTbl,#txNM').on('keydown', function (e) { e.stopPropagation(); });
    // Enter on table/covers moves to submit
    $('#txTbl').on('keydown', function (e) {
        if (e.key === 'Enter') { e.preventDefault(); $('#txCov').focus(); }
    });
    $('#txCov').on('keydown', function (e) {
        if (e.key === 'Enter') { e.preventDefault(); subOrder(); }
    });
}

// =================== PLACE ORDER ===================
function subOrder() {
    if (isSubmitting) { ntf('Please wait...', 'warn'); return; }
    var did = gDid(), dnm = gDnm();
    if (!did) { ntf('Select a Department first!', 'err'); return; }
    if (!cart.length) { ntf('Cart is empty!', 'err'); return; }
    var cov = parseInt($('#txCov').val()) || 1, tbl = $('#txTbl').val().trim();
    var nmv = $('#txNM').val().trim() || '0';

    if (bt === 'Club Member' && !mem) { ntf('Search and select a Member first!', 'err'); $('#txM').focus(); return; }
    if (bt === 'Guest House' && !ghi) { ntf('Search and confirm a Room first!', 'err'); $('#txGH').focus(); return; }
    if (bt === 'Affiliated Member' && !afm) { ntf('Select an Affiliated Member!', 'err'); $('#txAF').focus(); return; }

    var sub = 0, gstT = 0;
    cart.forEach(function (item) { var ls = item.price * item.qty; sub += ls; gstT += ls * (item.gst || 0) / 100; });
    var grand = sub + gstT;

    var lbl = 'Non Member';
    if (bt === 'Club Member') lbl = mem ? (mem.DisplayName || mem.Name) : 'Member';
    else if (bt === 'Guest House') lbl = ghi ? ('Room ' + ghi.RoomNo + ' - ' + ghi.GuestName) : 'Guest';
    else if (bt === 'Affiliated Member') lbl = afm ? afm.MemberName : 'Affiliated';
    else if (bt === 'Non Member') lbl = nmv || 'Non Member';

    var adLbl = autoDeliver ? ' [AUTO-DELIVER]' : '';
    if (!confirm('Place order?\nTable: ' + (tbl || 'None') + '\nCovers: ' + cov + '\nTotal: Rs ' + grand.toFixed(2) + '\nFor: ' + lbl + adLbl)) return;

    var ip = cart.map(function (item) { return { MenuItemId: parseInt(item.id, 10), Name: item.name, Price: parseFloat(item.price), GST: item.gst || 0, Quantity: parseInt(item.qty, 10), Notes: '' }; });
    var mno = '0', ain = '', acn = '', amn = '', resn = '', gn = '', rmn = '';
    if (bt === 'Club Member') mno = mem ? (mem.CardNo || '') : '';
    else if (bt === 'Guest House') { mno = ghi ? ('ROOM-' + ghi.RoomNo) : 'GUEST'; rmn = ghi ? ghi.RoomNo : ''; resn = ghi ? ghi.ReservationNo : ''; gn = ghi ? ghi.GuestName : ''; }
    else if (bt === 'Affiliated Member') { mno = afm ? afm.MemberNo : ''; ain = afm ? afm.IntroductoryNo : ''; acn = afm ? afm.ClubName : ''; amn = afm ? afm.MemberNo : ''; }
    else if (bt === 'Non Member') mno = nmv || '0';

    var pl = {
        memberNo: mno, totalAmount: grand, itemsJson: JSON.stringify(ip), tableNumber: tbl,
        departmentId: did, departmentName: dnm, employeeID: eid, waiterName: enm || eid,
        memberType: bt, roomNo: rmn, covers: cov,
        affiliatedIntroNo: ain, affiliatedClubName: acn, affiliatedMemberNo: amn,
        reservationNo: resn, guestName: gn, autoDeliver: autoDeliver
    };

    var $b = $('#btnSubmit');
    $b.prop('disabled', true).html('<span class="spinner"></span> Placing...');
    isSubmitting = true;

    $.ajax({
        type: 'POST', url: 'CombinedPOS.aspx/SubmitOrder',
        data: JSON.stringify(pl),
        contentType: 'application/json;charset=utf-8', dataType: 'json', timeout: 26000,
        success: function (r) {
            r = r.d;
            if (r && r.success) {
                ntf('Order #' + r.orderId + ' - KOT: ' + r.kotNumber + (r.autoDelivered ? ' AUTO-DELIVERED' : ''), 'ok');
                gnRec(r.orderId, tbl, r.subtotal, r.taxAmount, r.totalAmount, dnm, rmn, null, bt, cov, r.kotNumber, lbl, resn, gn);
                cart = []; rndrCart(); updCnt(); svCart();
                $('#txTbl').val(''); $('#txCov').val(1);
                resetM(); if (nmOn) toggleNM();
                ldLive();
                // Re-focus member search after order
                setTimeout(function () {
                    if (bt === 'Club Member') $('#txM').focus();
                }, 500);
            } else { ntf('Error: ' + (r ? r.message : 'Unknown'), 'err'); }
        },
        error: function (xhr, status, error) { ntf('Server error: ' + error, 'err'); },
        complete: function () {
            $b.prop('disabled', false).html('<i class="fa fa-check-circle"></i> Place Order' + (autoDeliver ? ' <span style="font-size:8.5px;background:rgba(255,255,255,.25);padding:1px 4px;border-radius:3px;margin-left:3px;">AUTO-DEL</span>' : ''));
            setTimeout(function () { isSubmitting = false; }, 800);
        }
    });
}

// =================== LIVE BILLS ===================
function ldLive() {
    var dnm = gDnm();
    $('#livelist').html('<div class="ld"><i class="fa fa-spinner fa-spin fa-2x"></i></div>');
    $.ajax({
        type: 'POST', url: 'CombinedPOS.aspx/GetLiveBills',
        data: JSON.stringify({ deptName: dnm }),
        contentType: 'application/json;charset=utf-8', dataType: 'json',
        success: function (r) {
            var o = r.d || [];
            var mf = $('#txBFilter').val().trim().toLowerCase();
            if (mf) o = o.filter(function (x) { return (x.memberNo || '').toLowerCase().indexOf(mf) >= 0; });
            var actCnt = 0, delCnt = 0;
            o.forEach(function (x) { if (x.status === 'Delivered') delCnt++; else actCnt++; });
            $('#sActiveCnt').text(actCnt); $('#sDelivCnt').text(delCnt);
            var total = o.length;
            var $lc = $('#liveCnt');
            $lc.text(total); total === 0 ? $lc.hide() : $lc.show();
            if (!o.length) { $('#livelist').html('<div class="noc"><i class="fa fa-bolt"></i><p>No active bills</p></div>'); return; }
            var h = '';
            o.forEach(function (x) {
                var isDel = x.status === 'Delivered', isGH2 = x.billTo === 'Guest House';
                var kb = x.kotNumber ? '<span class="kotb"><i class="fa fa-receipt"></i> ' + x.kotNumber + '</span>' : '';
                var stbadge = isDel ? '<span class="sbadge sb-del">Delivered</span>' : '<span class="sbadge sb-pend">Pending</span>';
                var payBtnHtml = '';
                if (isDel) {
                    if (isGH2) {
                        payBtnHtml = '<button class="ob ob-gh" onclick="openPayModal(\'' + x.id + '\',\'' + x.memberNo + '\',\'' + x.total + '\',\'' + x.billTo + '\',\'' + x.roomNo + '\',\'' + x.kotNumber + '\',\'' + x.cover + '\',\'' + gDid() + '\')"><i class="fa fa-hotel"></i> GH Bill</button>';
                    } else {
                        payBtnHtml = '<button class="ob ob-pay" onclick="openPayModal(\'' + x.id + '\',\'' + x.memberNo + '\',\'' + x.total + '\',\'' + x.billTo + '\',\'\',\'' + x.kotNumber + '\',\'' + x.cover + '\',\'' + gDid() + '\')"><i class="fa fa-check-circle"></i> Pay</button>';
                    }
                } else {
                    payBtnHtml = '<button class="ob ob-lock" disabled><i class="fa fa-hourglass-half"></i> Awaiting Delivery</button>';
                }
                h += '<div class="oi2">'
                    + '<div class="oi2-hd"><div style="display:flex;align-items:center;gap:4px;flex-wrap:wrap;font-weight:700;font-size:11.5px;"><span>Order #' + x.id + '</span>' + stbadge + kb + '</div>'
                    + '<div style="font-size:9px;color:var(--gy);">' + x.date + '</div></div>'
                    + '<div style="display:flex;flex-wrap:wrap;gap:7px;font-size:10px;margin:2px 0;font-family:var(--mono);">'
                    + '<span><i class="fa fa-user"></i> ' + x.memberNo + '</span>'
                    + (x.tableNumber ? '<span><i class="fa fa-table"></i> ' + x.tableNumber + '</span>' : '')
                    + '<span><i class="fa fa-users"></i> ' + x.cover + '</span>'
                    + (x.roomNo ? '<span><i class="fa fa-bed"></i> ' + x.roomNo + '</span>' : '')
                    + '<span style="font-weight:800;color:var(--ok);">Rs ' + parseFloat(x.total).toFixed(0) + '</span></div>'
                    + '<div class="abt">' + payBtnHtml
                    + '<button class="ob ob-cx" onclick="openCx(\'' + x.id + '\',\'' + x.kotNumber + '\')"><i class="fa fa-ban"></i> Cancel</button>'
                    + '</div></div>';
            });
            $('#livelist').html(h);
        },
        error: function () { $('#livelist').html('<div class="noc"><i class="fa fa-exclamation-triangle"></i><p>Failed to load</p></div>'); }
    });
}
$('#txBFilter').on('input', function () { ldLive(); });

// =================== PAYMENT MODAL ===================
function openPayModal(billId, memberNo, total, billTo, roomNo, kotNo, covers, deptId) {
    pmCurTotal = parseFloat(total) || 0;
    pmCurMemberNo = memberNo || 'Guest';
    pmCurBillTo = billTo || 'Club Member';
    pmCurRoomNo = roomNo || '';
    pmCardData = null; pmDiscData = null;
    isGHPayment = false;

    document.getElementById('pmBillIds').value = '';
    document.getElementById('pmPayType').value = '';
    document.getElementById('pmCardSub').value = '';
    document.getElementById('pmIsGH').value = '0';
    document.getElementById('pmDeptName').value = gDnm();
    document.getElementById('pmDeptCode').value = deriveDeptCode(gDnm());
    document.getElementById('pmMemberNo').value = memberNo;
    document.getElementById('pmBillTo').value = billTo;
    document.getElementById('pmRoomNo').value = roomNo;
    document.getElementById('pmCovers').value = covers;
    document.getElementById('pmKotNo').value = kotNo;

    $('#paymod-title').html('<i class="fa fa-layer-group"></i> Payment - ' + memberNo);
    $('#pmCustBar').html('<i class="fa fa-user-circle" style="color:#1565C0;"></i> ' + memberNo + (roomNo ? ' <span style="background:#B84A0A;color:#fff;padding:1px 7px;border-radius:100px;margin-left:4px;font-size:9.5px;">Room #' + roomNo + '</span>' : ''));
    $('#pmTotDisp').text('Rs ' + pmCurTotal.toFixed(2));
    document.getElementById('pmSum').value = pmCurTotal.toFixed(2);

    $('#pmKotItems').html('<div style="text-align:center;padding:7px;"><i class="fa fa-spinner fa-spin" style="color:var(--pr);"></i> Loading KOTs for ' + memberNo + '...</div>');

    $('#pmMemSec,#pmBankSec,#pmGHSec,#pmOfferSec,#pmMemInfo').hide();
    $('#pmPayBtn').show();
    $('.pmethod').removeClass('sel');
    ['pmCardNo', 'pmCHN', 'pmExpiry', 'pmAuth'].forEach(function (id) { var e = document.getElementById(id); if (e) e.value = ''; });
    ['ctyDebit', 'ctyCredit'].forEach(function (id) { document.getElementById(id).classList.remove('act'); });
    document.getElementById('pmCardMsg').textContent = '';
    selPayType = ''; cardSubType = '';
    pmDiscData = null;

    if (billTo === 'Guest House') {
        isGHPayment = true;
        document.getElementById('pmIsGH').value = '1';
        $('#pmMethodsSec').html('<div style="background:#EEF3FF;border:2px solid #C0CFFF;border-radius:7px;padding:8px 11px;font-size:11px;font-weight:700;color:#1845D4;margin-bottom:9px;"><i class="fa fa-info-circle"></i> Guest House bills use Bank Card or GH posting.</div><div class="pmethods"><div class="pmethod" id="pm_bank" onclick="selPM(this,\'BankCard\')" tabindex="0"><i class="fa fa-credit-card"></i><h6>Bank Card</h6><small>Debit / Credit</small></div></div>');
        $('#pmGHSec').show();
        $('#pmPayBtn').show();
    } else if (billTo === 'Affiliated Member') {
        $('#pmMethodsSec').html('<div style="background:#FFF3E0;border:2px solid #FFCC80;border-radius:7px;padding:8px 11px;font-size:11px;font-weight:700;color:#E65100;margin-bottom:9px;"><i class="fa fa-info-circle"></i> Affiliated Members - Bank Card only.</div><div class="pmethods"><div class="pmethod" id="pm_bank" onclick="selPM(this,\'BankCard\')" tabindex="0"><i class="fa fa-credit-card"></i><h6>Bank Card</h6><small>Debit / Credit</small></div></div>');
        isGHPayment = false;
    } else {
        $('#pmMethodsSec').html('<div class="pmethods"><div class="pmethod" id="pm_member" onclick="selPM(this,\'MemberCard\')" tabindex="0" title="Alt+M"><i class="fa fa-id-card"></i><h6>Membership Card</h6><small>Deduct from account</small></div><div class="pmethod" id="pm_bank" onclick="selPM(this,\'BankCard\')" tabindex="0" title="Alt+B"><i class="fa fa-credit-card"></i><h6>Bank Card</h6><small>Debit / Credit</small></div></div>');
        isGHPayment = false;
        if (memberNo && memberNo !== 'Guest') {
            setTimeout(function () {
                var mb = document.getElementById('pm_member');
                if (mb) {
                    selPM(mb, 'MemberCard');
                    var inp = document.getElementById('pmMemCard');
                    if (inp) { inp.value = memberNo; validateMemCard(memberNo); }
                }
            }, 300);
        }
    }

    $('#paymod').addClass('open');
    loadAllKOTs(memberNo, deptId || gDid(), billId);
}

function closePayMod() {
    $('#paymod').removeClass('open');
    pmCardData = null; pmDiscData = null; pmBillsList = []; pmItemsList = [];
}

function loadAllKOTs(memberNo, deptId, singleBillId) {
    $.ajax({
        type: 'POST', url: 'CombinedPOS.aspx/GetMemberAllKOTs',
        data: JSON.stringify({ memberNo: memberNo, departmentId: deptId }),
        contentType: 'application/json;charset=utf-8', dataType: 'json',
        success: function (r) {
            r = r.d;
            if (r && r.success) {
                pmBillsList = r.bills || [];
                pmItemsList = r.items || [];
                var grandTotal = parseFloat(r.grandTotal) || 0;
                pmCurTotal = grandTotal;
                document.getElementById('pmSum').value = grandTotal.toFixed(2);
                $('#pmTotDisp').text('Rs ' + grandTotal.toFixed(2));
                document.getElementById('pmBillIds').value = JSON.stringify(r.billIds || [parseInt(singleBillId)]);
                renderKotItems(pmBillsList, pmItemsList);
            } else {
                document.getElementById('pmBillIds').value = JSON.stringify([parseInt(singleBillId)]);
                $('#pmKotItems').html('<div style="padding:5px;font-size:11px;color:var(--gy);">Single KOT - ' + document.getElementById('pmKotNo').value + '</div>');
            }
        },
        error: function () { document.getElementById('pmBillIds').value = JSON.stringify([parseInt(singleBillId)]); }
    });
}

function renderKotItems(bills, items) {
    var bmap = {};
    items.forEach(function (i) { var bid = i.BillId; if (!bmap[bid]) bmap[bid] = []; bmap[bid].push(i); });
    var h = '', grand = 0;
    bills.forEach(function (b) {
        var bid = b.billId, its = bmap[bid] || [];
        var sub = 0;
        its.forEach(function (i) { sub += parseFloat(i.ItemTotal || 0); });
        grand += parseFloat(b.total || 0);
        h += '<div style="margin-bottom:4px;">';
        h += '<div style="background:linear-gradient(135deg,#0A1A50,#1845D4);color:#fff;padding:2px 7px;border-radius:4px 4px 0 0;font-size:9px;font-weight:700;font-family:var(--mono);display:flex;justify-content:space-between;">';
        h += '<span>' + (b.kotNo || 'KOT') + '</span><span class="sbadge ' + (b.status === 'Delivered' ? 'sb-del' : 'sb-pend') + '" style="padding:1px 5px;font-size:8px;">' + b.status + '</span></div>';
        h += '<table style="width:100%;border-collapse:collapse;font-size:9.5px;font-family:var(--mono);"><thead><tr style="background:#f5f5f5;"><th style="padding:2px 3px;text-align:left;">Item</th><th style="padding:2px 3px;text-align:center;">Qty</th><th style="padding:2px 3px;text-align:right;">Amt</th></tr></thead><tbody>';
        its.forEach(function (i) { h += '<tr><td style="padding:2px 3px;">' + (i.Name || '') + '</td><td style="text-align:center;padding:2px 3px;">' + (i.Quantity || 0) + '</td><td style="text-align:right;padding:2px 3px;">Rs ' + (parseFloat(i.ItemTotal || 0)).toFixed(0) + '</td></tr>'; });
        h += '<tr style="background:#F0FFF4;font-weight:700;"><td colspan="2" style="padding:2px 3px;text-align:right;">Sub:</td><td style="padding:2px 3px;text-align:right;color:var(--ok);">Rs ' + sub.toFixed(0) + '</td></tr>';
        h += '</tbody></table></div>';
    });
    h += '<div style="background:linear-gradient(135deg,#EDFAF4,#fff);border:2px solid #A7F0C8;border-radius:5px;padding:6px 9px;display:flex;justify-content:space-between;font-weight:800;margin-top:3px;font-family:var(--mono);"><span>Grand (' + bills.length + ' KOT' + (bills.length > 1 ? 's' : '') + ')</span><span style="color:var(--ok);">Rs ' + grand.toFixed(2) + '</span></div>';
    $('#pmKotItems').html(h);
}

function selPM(el, type) {
    document.querySelectorAll('.pmethod').forEach(function (m) { m.classList.remove('sel'); });
    el.classList.add('sel');
    document.getElementById('pmPayType').value = type;
    selPayType = type;
    ['pmMemSec', 'pmBankSec', 'pmOfferSec', 'pmMemInfo'].forEach(function (id) { var e = document.getElementById(id); if (e) e.style.display = 'none'; });
    pmDiscData = null; updatePMSum();
    if (type === 'MemberCard') {
        document.getElementById('pmMemSec').style.display = 'block';
        var inp = document.getElementById('pmMemCard');
        if (inp && !inp.value.trim()) setTimeout(function () { inp.focus(); }, 200);
    } else if (type === 'BankCard') {
        document.getElementById('pmBankSec').style.display = 'block';
        setTimeout(function () { document.getElementById('pmCHN').focus(); }, 200);
    }
}

function validateMemCard(cn) {
    if (!cn || cn.trim() === '') return;
    var inp = document.getElementById('pmMemCard');
    var ntc = document.getElementById('pmMemNotice');
    if (ntc) ntc.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Validating ' + cn + '...';
    if (inp) inp.disabled = true;
    $.ajax({
        type: 'POST', url: 'CombinedPOS.aspx/ValidateMemberCard', data: JSON.stringify({ cardNumber: cn }),
        contentType: 'application/json;charset=utf-8', dataType: 'json',
        success: function (r) {
            r = r.d;
            if (inp) inp.disabled = false;
            if (r && r.success) {
                pmCardData = { balance: parseFloat(r.balance) || 0, name: r.Name, memberNo: r.MemberNo || r.Memberid, cardNo: r.CardNo, totalDept: parseFloat(r.totalDept) || 0, totalCredit: parseFloat(r.totalCredit) || 0 };
                if (ntc) ntc.innerHTML = '<i class="fa fa-check-circle"></i> Valid - ' + r.Name;
                var info = document.getElementById('pmMemInfo');
                if (info) {
                    var bal = parseFloat(r.balance) || 0;
                    info.innerHTML = '<div style="display:flex;justify-content:space-between;flex-wrap:wrap;gap:3px;"><span style="font-weight:800;">' + r.Name + '</span><span style="background:#fff;border:1px solid var(--lg);border-radius:100px;padding:2px 8px;font-size:10.5px;font-weight:700;color:' + (bal <= 0 ? 'var(--ok)' : 'var(--err)') + ';font-family:var(--mono);">Rs ' + bal.toFixed(2) + '</span></div>';
                    info.style.display = 'block';
                }
                ntf('Card valid: ' + r.Name, 'ok');
                // Auto-focus pay button
                setTimeout(function () { document.getElementById('pmPayBtn').focus(); }, 300);
            } else {
                pmCardData = null;
                if (ntc) { ntc.innerHTML = '<i class="fa fa-times-circle"></i> ' + (r && r.message ? r.message : 'Card not found'); ntc.style.background = '#FFEBEE'; ntc.style.color = 'var(--err)'; }
                ntf(r && r.message ? r.message : 'Card not found', 'err');
            }
        },
        error: function () { if (inp) inp.disabled = false; pmCardData = null; ntf('Error validating card', 'err'); }
    });
}

function initPMKeys() {
    var inp = document.getElementById('pmMemCard');
    if (!inp) return;
    var st = null, lkt = 0;
    inp.addEventListener('keydown', function (e) {
        var now = Date.now();
        if (e.key === 'Enter') { e.preventDefault(); var v = this.value.trim(); if (v) validateMemCard(v); return; }
        if (lkt > 0 && (now - lkt) < 55) { if (st) clearTimeout(st); st = setTimeout(function () { var v = inp.value.trim(); if (v && v.length >= 4) validateMemCard(v); st = null; }, 120); }
        lkt = now;
    });
    inp.addEventListener('input', function () {
        var v = this.value.trim();
        if (st) clearTimeout(st);
        st = setTimeout(function () { if (v && v.length >= 8) validateMemCard(v); st = null; }, 700);
    });
    inp.addEventListener('paste', function () { setTimeout(function () { var v = inp.value.trim(); if (v) validateMemCard(v); }, 100); });
}

function onBankCard(input) {
    var raw = input.value.replace(/\D/g, ''), f = '';
    for (var i = 0; i < raw.length; i++) { if (i > 0 && i % 4 === 0) f += '-'; f += raw[i]; }
    input.value = f;
    var clean = raw;
    var msg = document.getElementById('pmCardMsg');
    if (clean.length === 0) { if (msg) msg.textContent = ''; input.classList.remove('ok', 'err'); return; }
    if (!/^\d+$/.test(clean)) { input.classList.add('err'); input.classList.remove('ok'); if (msg) msg.innerHTML = '<span style="color:var(--err);">Digits only</span>'; return; }
    input.classList.add('ok'); input.classList.remove('err');
    if (msg) msg.innerHTML = '<span style="color:var(--ok);">Card accepted</span>';
    if (clean.length >= 4) checkDiscount(clean);
}

function checkDiscount(clean) {
    $.ajax({
        type: 'POST', url: 'CombinedPOS.aspx/CheckCardDiscount',
        data: JSON.stringify({ cardNumber: clean.substring(0, 4), billAmount: pmCurTotal }),
        contentType: 'application/json;charset=utf-8', dataType: 'json',
        success: function (r) {
            r = r.d;
            pmDiscData = r.success ? r : null;
            var sec = document.getElementById('pmOfferSec');
            if (r && r.success) {
                var da = parseFloat(r.discount_amount) || 0;
                if (sec) { sec.innerHTML = '<div class="offer-box"><div class="offer-box-hd"><div class="offer-title"><i class="fa fa-tag"></i> ' + (r.offer_name || 'Discount') + '</div><div class="offer-disc">-Rs ' + da.toFixed(2) + '</div></div><div style="font-size:9.5px;color:var(--ok);">' + r.discount_percent + '% off - Net: Rs ' + (pmCurTotal - da).toFixed(2) + '</div></div>'; sec.style.display = 'block'; }
                document.getElementById('pmSum').value = (pmCurTotal - da).toFixed(2);
            } else {
                if (sec) sec.style.display = 'none';
                document.getElementById('pmSum').value = pmCurTotal.toFixed(2);
            }
        },
        error: function () { pmDiscData = null; document.getElementById('pmSum').value = pmCurTotal.toFixed(2); }
    });
}

function setCTY(sub) {
    cardSubType = sub;
    document.getElementById('pmCardSub').value = sub;
    document.getElementById('ctyDebit').classList.toggle('act', sub === 'Debit');
    document.getElementById('ctyCredit').classList.toggle('act', sub === 'Credit');
    // Focus card number after type selection
    setTimeout(function () { document.getElementById('pmCHN').focus(); }, 100);
}

function fmtExp(input) {
    var v = input.value.replace(/\D/g, '');
    input.value = v.length >= 2 ? v.slice(0, 2) + '/' + v.slice(2, 4) : v;
}
function valExp(input) {
    var v = input.value.trim(); if (!v || v.length < 5) { input.classList.remove('err'); return true; }
    var parts = v.split('/'); if (parts.length !== 2) { input.classList.add('err'); return false; }
    var mm = parseInt(parts[0]), yy = parseInt(parts[1]);
    if (isNaN(mm) || isNaN(yy) || mm < 1 || mm > 12) { input.classList.add('err'); return false; }
    var now = new Date(), ny = now.getFullYear() % 100, nm = now.getMonth() + 1;
    if (yy < ny || (yy === ny && mm < nm)) { input.classList.add('err'); return false; }
    input.classList.remove('err'); return true;
}

function updatePMSum() {
    var da = (pmDiscData && pmDiscData.success) ? parseFloat(pmDiscData.discount_amount) : 0;
    document.getElementById('pmSum').value = (pmCurTotal - da).toFixed(2);
}

function deriveDeptCode(deptName) {
    if (!deptName) return 'BR01';
    var p = deptName.replace(/[^a-zA-Z]/g, '').substring(0, 2).toUpperCase();
    return (p || 'BR') + '01';
}

// =================== DO PAYMENT ===================
function doPayment() {
    var payType = document.getElementById('pmPayType').value;
    var billTotal = pmCurTotal;
    var discountAmt = (pmDiscData && pmDiscData.success) ? parseFloat(pmDiscData.discount_amount) : 0;
    var finalAmount = billTotal - discountAmt;
    var offerId = (pmDiscData && pmDiscData.success) ? pmDiscData.offer_id : 0;
    var covers = parseInt(document.getElementById('pmCovers').value) || 1;
    var deptCode = document.getElementById('pmDeptCode').value || 'BR01';
    var ghPay = document.getElementById('pmIsGH').value === '1';
    var memberNo = document.getElementById('pmMemberNo').value;
    var billTo = document.getElementById('pmBillTo').value;

    if (!payType) { ntf('Select a payment method!', 'warn'); return; }
    if (billTo === 'Affiliated Member' && payType === 'MemberCard') { ntf('Affiliated - Bank Card only', 'err'); return; }
    if (billTo === 'Guest House' && payType !== 'BankCard') { ntf('Guest House - Bank Card only', 'err'); return; }

    var cardNumber = '', cardExpiry = '', approvalCode = '', cardHolderName = '';
    if (payType === 'MemberCard') {
        cardNumber = document.getElementById('pmMemCard').value.trim();
        if (!cardNumber) { ntf('Enter membership card number', 'err'); return; }
        if (!pmCardData) { ntf('Validate the card first (press Enter in card field)', 'warn'); return; }
    } else if (payType === 'BankCard') {
        if (!cardSubType) { ntf('Select Debit or Credit card type', 'warn'); return; }
        cardNumber = document.getElementById('pmCardNo').value.trim();
        var rawCard = cardNumber.replace(/[\s\-]/g, '');
        cardExpiry = document.getElementById('pmExpiry').value.trim();
        approvalCode = document.getElementById('pmAuth').value.trim();
        cardHolderName = document.getElementById('pmCHN').value.trim();
        if (!rawCard) { ntf('Enter bank card number', 'err'); return; }
        if (!cardExpiry) { ntf('Enter card expiry', 'err'); return; }
        if (!valExp(document.getElementById('pmExpiry'))) { ntf('Card expired or invalid expiry', 'err'); return; }
        if (!ghPay && billTo !== 'Guest House' && !approvalCode) { ntf('Enter authorization code', 'err'); return; }
        if (approvalCode && approvalCode.length !== 6) { ntf('Auth code must be 6 digits', 'err'); return; }
    }

    var payMethod = '';
    if (payType === 'MemberCard') payMethod = 'Member Card';
    else payMethod = (cardSubType ? cardSubType + ' Card' : 'Bank Card');

    var billIdsJson = document.getElementById('pmBillIds').value, billIds = [];
    try { billIds = JSON.parse(billIdsJson); } catch (e) { billIds = [parseInt(document.getElementById('pmBillIds').value) || 0]; }
    var deptName = document.getElementById('pmDeptName').value || '';

    var $b = $('#pmPayBtn'), orig = $b.html();
    $b.html('<span class="spinner"></span> Processing...').prop('disabled', true);

    $.ajax({
        type: 'POST', url: 'CombinedPOS.aspx/ProcessConsolidatedPayment',
        data: JSON.stringify({
            memberNo: memberNo, departmentId: deptName, billIds: billIds,
            paymentMethod: payMethod, paymentType: payType,
            cardNumber: cardNumber, cardExpiry: cardExpiry, approvalCode: approvalCode, cardHolderName: cardHolderName,
            totalAmount: billTotal, discountAmount: discountAmt, offerId: offerId, signatureData: '',
            numberOfCovers: covers, deptCode: deptCode, ghPayment: ghPay, effectiveStatus: ghPay ? 'GH' : 'Paid'
        }),
        contentType: 'application/json;charset=utf-8', dataType: 'json',
        success: function (r) {
            $b.html(orig).prop('disabled', false);
            r = r.d;
            if (r && r.success) {
                ntf('Payment OK - Bill: ' + r.generatedBillNo, 'ok');
                genFinalReceipt(r, deptName, memberNo, billTotal, discountAmt, r.finalAmount, payMethod, covers, ghPay);
                closePayMod(); ldLive();
            } else { ntf('Error: ' + (r ? r.message : 'Unknown'), 'err'); }
        },
        error: function () { $b.html(orig).prop('disabled', false); ntf('Network error', 'err'); }
    });
}

function doGHPay() {
    var billTotal = pmCurTotal;
    var memberNo = document.getElementById('pmMemberNo').value;
    var covers = parseInt(document.getElementById('pmCovers').value) || 1;
    var deptCode = document.getElementById('pmDeptCode').value || 'BR01';
    var deptName = document.getElementById('pmDeptName').value || '';
    var billIdsJson = document.getElementById('pmBillIds').value, billIds = [];
    try { billIds = JSON.parse(billIdsJson); } catch (e) { billIds = [0]; }

    var $b = $('#pmGHBtn'), orig = $b.html();
    $b.html('<span class="spinner"></span> Processing GH...').prop('disabled', true);

    $.ajax({
        type: 'POST', url: 'CombinedPOS.aspx/ProcessConsolidatedPayment',
        data: JSON.stringify({
            memberNo: memberNo, departmentId: deptName, billIds: billIds,
            paymentMethod: 'Guest House', paymentType: 'GH',
            cardNumber: 'GH', cardExpiry: '', approvalCode: '', cardHolderName: '',
            totalAmount: billTotal, discountAmount: 0, offerId: 0, signatureData: '',
            numberOfCovers: covers, deptCode: deptCode, ghPayment: true, effectiveStatus: 'GH'
        }),
        contentType: 'application/json;charset=utf-8', dataType: 'json',
        success: function (r) {
            $b.html(orig).prop('disabled', false);
            r = r.d;
            if (r && r.success) {
                ntf('GH Bill OK - ' + r.generatedBillNo, 'ok');
                genFinalReceipt(r, deptName, memberNo, billTotal, 0, billTotal, 'Guest House', covers, true);
                closePayMod(); ldLive();
            } else { ntf('Error: ' + (r ? r.message : 'Unknown'), 'err'); }
        },
        error: function () { $b.html(orig).prop('disabled', false); ntf('Network error', 'err'); }
    });
}

// =================== CANCEL ===================
function initCx() {
    $('#btnCxX,#btnCxBk').on('click', function () { $('#cxmod').removeClass('open'); cxOId = null; cxKot = ''; $('#cxrmk').val(''); });
    $('#btnCxOk').on('click', function () {
        var rm = $('#cxrmk').val().trim();
        if (!rm) { ntf('Enter cancellation reason!', 'err'); $('#cxrmk').focus(); return; }
        if (!cxOId) return;
        var $b = $(this), orig = $b.html();
        $b.html('<span class="spinner"></span> Cancelling...').prop('disabled', true);
        $.ajax({
            type: 'POST', url: 'CombinedPOS.aspx/CancelOrder',
            data: JSON.stringify({ orderId: cxOId, employeeID: eid, remarks: rm }),
            contentType: 'application/json;charset=utf-8', dataType: 'json',
            success: function (r) {
                r = r.d;
                if (r && r.success) { ntf('Order #' + cxOId + ' cancelled', 'ok'); $('#cxmod').removeClass('open'); cxOId = null; cxKot = ''; $('#cxrmk').val(''); ldLive(); }
                else ntf('Error: ' + (r ? r.message : 'Unknown'), 'err');
            },
            error: function () { ntf('Server error', 'err'); },
            complete: function () { $b.html(orig).prop('disabled', false); }
        });
    });
}
function openCx(oid, kot) {
    cxOId = oid; cxKot = kot || '';
    $('#cxoid').text('#' + oid); $('#cxkot').text(kot || '-'); $('#cxrmk').val('');
    $('#cxmod').addClass('open');
    setTimeout(function () { $('#cxrmk').focus(); }, 60);
}

// =================== RECEIPT (KOT) ===================
function gnRec(oid, tbl, sub, tax, grand, dnm, rmn, its, btp, cov, kot, lbl, resn, gn) {
    var items = its || cart, ih = '';
    items.forEach(function (i) {
        ih += '<tr><td style="padding:2px 0;">' + (i.name || i.Name || '') + '</td><td style="text-align:center;padding:2px 0;">' + (i.qty || i.Quantity || 0) + '</td></tr>';
    });
    var gh = (btp === 'Guest House' && resn) ? '<div class="ir"><span class="il">Res#:</span><span>' + resn + '</span></div><div class="ir"><span class="il">Room:</span><span>' + rmn + '</span></div><div class="ir"><span class="il">Guest:</span><span>' + gn + '</span></div>' : (rmn ? '<div class="ir"><span class="il">Room:</span><span>' + rmn + '</span></div>' : '');
    $('#recbody').html(
        '<div class="rw">'
        + '<div class="rh"><h1>LAHORE GYMKHANA</h1><h2>F & B</h2><h3>' + (dnm || '') + '</h3>' + (kot ? '<div class="kb">KOT: ' + kot + '</div>' : '') + '</div>'
        + '<div class="is"><div class="ir"><span class="il">For:</span><span>' + lbl + '</span></div>'
        + '<div class="ir"><span class="il">Bill Type:</span><span>' + btp + '</span></div>' + gh
        + '<div class="ir"><span class="il">Covers:</span><span style="font-weight:800;">' + cov + '</span></div>'
        + '<div class="ir"><span class="il">Table:</span><span>' + (tbl || '-') + '</span></div>'
        + '<div class="ir"><span class="il">Order #:</span><span>' + oid + '</span></div>'
        + '<div class="ir"><span class="il">Waiter:</span><span>' + (enm || eid) + '</span></div>'
        + '<div class="ir"><span class="il">Date:</span><span>' + new Date().toLocaleDateString('en-IN') + '</span></div></div>'
        + '<table class="rt"><thead><tr><th>Item</th><th style="text-align:center;">QTY</th></tr></thead><tbody>' + ih + '</tbody></table>'
        + '<div class="ft"><p>THANK YOU - LAHORE GYMKHANA</p></div></div>'
    );
    $('#recmod').addClass('open');
}

// =================== FINAL RECEIPT ===================
function genFinalReceipt(rd, deptName, memberNo, billTotal, discAmt, finalAmt, payMethod, covers, ghPay) {
    var now = new Date();
    var dd = String(now.getDate()).padStart(2, '0'), mm2 = String(now.getMonth() + 1).padStart(2, '0'), yyyy = now.getFullYear();
    var hh12 = now.getHours() % 12 || 12, min2 = String(now.getMinutes()).padStart(2, '0'), ampm = now.getHours() >= 12 ? 'PM' : 'AM';
    var dateStr = dd + '/' + mm2 + '/' + yyyy + ' ' + String(hh12).padStart(2, '0') + ':' + min2 + ampm;

    var taxAmt = 0, subtotal = 0;
    pmBillsList.forEach(function (b) { taxAmt += parseFloat(b.taxApplied || 0); subtotal += parseFloat(b.subtotal || 0); });
    if (taxAmt === 0 && billTotal > 0) taxAmt = Math.round(billTotal * 16 / 116);
    if (subtotal === 0) subtotal = billTotal - taxAmt;

    var bmap = {};
    pmItemsList.forEach(function (i) { var bid = i.BillId; if (!bmap[bid]) bmap[bid] = []; bmap[bid].push(i); });

    var rowsHtml = '';
    pmBillsList.forEach(function (bill) {
        var bid = bill.billId, kotNo = bill.kotNo || 'N/A', its = bmap[bid] || [], first = true;
        its.forEach(function (item) {
            var qty = item.Quantity || 0, rate = parseFloat(item.Price || 0), iT = parseFloat(item.ItemTotal || 0), code = item.ItemCode || '', name = item.Name || '';
            rowsHtml += '<tr><td style="font-size:8px;color:#555;width:22%;">' + (first ? kotNo : '') + '</td><td style="width:8%;">' + code + '</td><td style="width:34%;">' + name + '</td><td style="text-align:right;width:12%;">' + rate.toFixed(0) + '</td><td style="text-align:center;width:6%;">' + qty + '</td><td style="text-align:right;width:18%;">' + iT.toFixed(0) + '</td></tr>';
            first = false;
        });
    });

    var pmNote = ghPay ? 'GH' : payMethod;
    var ghNote = ghPay ? '<div style="text-align:center;font-weight:700;margin-bottom:3px;">*** GUEST HOUSE BILL ***</div>' : '';
    var postedLabel = payMethod === 'Member Card' ? 'Posted to Member A/C:' : 'Amount Paid:';
    var billNo = rd.generatedBillNo || '';
    var cashierName = rd.cashierName || enm || eid;

    var html = '<!DOCTYPE html><html><head><meta charset="utf-8"><title>Bill - ' + billNo + '</title>'
        + '<style>@page{size:80mm auto;margin:4mm}*{margin:0;padding:0;box-sizing:border-box}body{font-family:"Courier New",monospace;font-size:10px;color:#000;background:#fff;width:72mm;margin:0 auto}'
        + '.hdr{text-align:center;border-bottom:1px dashed #000;padding-bottom:4px;margin-bottom:4px}.hdr .org{font-size:13px;font-weight:700;letter-spacing:1px}.hdr .sub{font-size:11px;font-weight:700}'
        + '.meta{margin-bottom:4px;border-bottom:1px dashed #000;padding-bottom:4px;font-size:9.5px}.mr{display:flex;justify-content:space-between;margin-bottom:1px}'
        + 'table{width:100%;border-collapse:collapse;font-size:9px;margin-bottom:4px}thead tr{border-top:1px solid #000;border-bottom:1px solid #000}th{padding:2px;font-weight:700;text-align:left}td{padding:1px 2px;vertical-align:top}'
        + '.totals{border-top:1px solid #000;padding-top:3px;font-size:9.5px}.trow{display:flex;justify-content:space-between;padding:1px 0}.trow.grand{font-weight:700;border-top:1px solid #000;margin-top:2px;padding-top:2px}'
        + '.sig-area{margin-top:10px;display:flex;justify-content:space-between;align-items:flex-end}'
        + '.sig-box{width:28mm;height:16mm;border:1px solid #000;border-radius:50%;display:flex;align-items:center;justify-content:center;overflow:hidden}'
        + '.ftr{border-top:1px dashed #000;margin-top:6px;padding-top:4px;text-align:center;font-size:8px;line-height:1.5}'
        + '.noprint{text-align:center;margin-top:8px}@media print{.noprint{display:none}}</style></head><body>';

    html += ghNote;
    html += '<div class="hdr"><div class="org">LAHORE GYMKHANA</div><div class="sub">' + deptName + '</div></div>';
    html += '<div class="meta"><div class="mr"><span>Bill No: <strong>' + billNo + '</strong></span><span>Covers: <strong>' + covers + '</strong></span></div><div class="mr"><span>Date: ' + dateStr + '</span></div><div class="mr"><span>Member: <strong>' + memberNo + '</strong></span></div><div class="mr"><span>Dept: ' + deptName + '</span><span>Payment: ' + pmNote + '</span></div></div>';
    html += '<table><thead><tr><th>KOT</th><th>Code</th><th>Item</th><th style="text-align:right">Rate</th><th style="text-align:center">Qty</th><th style="text-align:right">Amt</th></tr></thead><tbody>' + rowsHtml + '</tbody></table>';
    html += '<div class="totals"><div class="trow"><span>Subtotal:</span><span>' + subtotal.toFixed(0) + '</span></div><div class="trow"><span>GST:</span><span>' + taxAmt.toFixed(0) + '</span></div>';
    if (discAmt > 0) html += '<div class="trow"><span>Discount:</span><span>-' + discAmt.toFixed(0) + '</span></div>';
    html += '<div class="trow grand"><span>Net Payable:</span><span>' + finalAmt.toFixed(0) + '</span></div><div class="trow"><span>' + postedLabel + '</span><span>' + finalAmt.toFixed(0) + '</span></div><div class="trow grand"><span>Balance:</span><span>0</span></div></div>';
    html += '<div class="sig-area"><div><div class="sig-box"><canvas id="sigCanvas" width="108" height="60"></canvas></div><div style="font-size:8px;margin-top:2px;text-align:center;">Member Signature</div></div><div style="text-align:right;font-size:8.5px;line-height:1.6">Prepared By:<br>' + cashierName + '</div></div>';
    html += '<div class="ftr">WE HOPE YOU ENJOYED YOUR VISIT<br>WE WELCOME YOUR COMMENTS AND SUGGESTIONS</div>';
    html += '<div class="noprint"><button onclick="clearSig()" style="padding:5px 10px;background:#555;color:#fff;border:none;border-radius:4px;cursor:pointer;margin-right:4px;font-size:11px;">Clear Sig</button><button onclick="window.print()" style="padding:5px 10px;background:#1845D4;color:#fff;border:none;border-radius:4px;cursor:pointer;margin-right:4px;font-size:11px;">Print</button><button onclick="window.close()" style="padding:5px 10px;background:#C62828;color:#fff;border:none;border-radius:4px;cursor:pointer;font-size:11px;">Close</button></div>';
    html += '<script>(function(){var c=document.getElementById("sigCanvas");var ctx=c.getContext("2d");ctx.strokeStyle="#000";ctx.lineWidth=1.5;ctx.lineCap="round";var drawing=false,lx=0,ly=0;function gp(e){var r=c.getBoundingClientRect(),t=e.touches?e.touches[0]:e;return{x:t.clientX-r.left,y:t.clientY-r.top};}c.onmousedown=function(e){drawing=true;var p=gp(e);lx=p.x;ly=p.y;};c.onmousemove=function(e){if(!drawing)return;var p=gp(e);ctx.beginPath();ctx.moveTo(lx,ly);ctx.lineTo(p.x,p.y);ctx.stroke();lx=p.x;ly=p.y;};c.onmouseup=c.onmouseleave=function(){drawing=false;};c.addEventListener("touchstart",function(e){e.preventDefault();drawing=true;var p=gp(e);lx=p.x;ly=p.y;},{passive:false});c.addEventListener("touchmove",function(e){e.preventDefault();if(!drawing)return;var p=gp(e);ctx.beginPath();ctx.moveTo(lx,ly);ctx.lineTo(p.x,p.y);ctx.stroke();lx=p.x;ly=p.y;},{passive:false});c.addEventListener("touchend",function(){drawing=false;});window.clearSig=function(){ctx.clearRect(0,0,c.width,c.height);};})();window.onload=function(){setTimeout(function(){window.print();},700);};<\/script></body></html>';

    var w = window.open('', '_blank', 'width=400,height=650');
    if (w) { w.document.write(html); w.document.close(); }
}

function prt() {
    var pw = window.open('', '_blank');
    pw.document.write('<!DOCTYPE html><html><head><title>KOT</title></head><body>' + document.getElementById('recbody').innerHTML + '</body></html>');
    pw.document.close(); pw.focus();
    setTimeout(function () { pw.print(); pw.close(); }, 200);
}

// =================== KEYBOARD SHORTCUTS ===================
function initKeys() {
    document.addEventListener('keydown', function (e) {
        var tag = document.activeElement ? document.activeElement.tagName.toLowerCase() : '';
        var isInput = tag === 'input' || tag === 'textarea' || tag === 'select';
        var modOpen = $('#cxmod').hasClass('open') || $('#paymod').hasClass('open') || $('#recmod').hasClass('open');

        // ESC closes modals
        if (e.key === 'Escape') {
            if ($('#cxmod').hasClass('open')) { $('#cxmod').removeClass('open'); return; }
            if ($('#paymod').hasClass('open')) { closePayMod(); return; }
            if ($('#recmod').hasClass('open')) { $('#recmod').removeClass('open'); return; }
        }

        // In modal: Enter submits
        if (modOpen && e.key === 'Enter' && $('#cxmod').hasClass('open') && !isInput) { $('#btnCxOk').trigger('click'); return; }
        if (modOpen && e.key === 'Enter' && $('#paymod').hasClass('open') && !isInput) { doPayment(); return; }

        if (modOpen) return; // Don't process other keys if modal is open

        // F-keys
        if (e.key === 'F1') { e.preventDefault(); if (bt === 'Club Member') $('#txM').focus(); else if (bt === 'Guest House') $('#txGH').focus(); else $('#txAF').focus(); return; }
        if (e.key === 'F2') { e.preventDefault(); $('#txSrch').val('').focus(); ldProds(); return; }
        if (e.key === 'F3') { e.preventDefault(); $('.rtab[data-p="cart"]').trigger('click'); return; }
        if (e.key === 'F4') { e.preventDefault(); $('.rtab[data-p="live"]').trigger('click'); return; }
        if (e.key === 'F5') { e.preventDefault(); $('input[name="bt"][value="Club Member"]').prop('checked', true).trigger('change'); return; }
        if (e.key === 'F6') { e.preventDefault(); $('input[name="bt"][value="Guest House"]').prop('checked', true).trigger('change'); return; }
        if (e.key === 'F7') { e.preventDefault(); $('input[name="bt"][value="Affiliated Member"]').prop('checked', true).trigger('change'); return; }
        if (e.key === 'F8') { e.preventDefault(); toggleADT(); return; }
        if (e.key === 'F9') { e.preventDefault(); toggleNM(); return; }

        // Alt + category keys
        if (e.altKey && !e.ctrlKey) {
            if (e.key === '1') { e.preventDefault(); $('.cat[data-c=""]').trigger('click'); return; }
            if (e.key === '2') { e.preventDefault(); $('.cat[data-c="Beverages"]').trigger('click'); return; }
            if (e.key === '3') { e.preventDefault(); $('.cat[data-c="Snacks"]').trigger('click'); return; }
            if (e.key === '4') { e.preventDefault(); $('.cat[data-c="Main Course"]').trigger('click'); return; }
            if (e.key === '5') { e.preventDefault(); $('.cat[data-c="Desserts"]').trigger('click'); return; }
            // Payment modal
            if (e.key === 'm' || e.key === 'M') { var mb = document.getElementById('pm_member'); if (mb) { selPM(mb, 'MemberCard'); } return; }
            if (e.key === 'b' || e.key === 'B') { var bb = document.getElementById('pm_bank'); if (bb) { selPM(bb, 'BankCard'); } return; }
            if (e.key === 'd' || e.key === 'D') { setCTY('Debit'); return; }
            if (e.key === 'c' || e.key === 'C') { setCTY('Credit'); return; }
        }

        // Delete clears cart (when not in input)
        if (e.key === 'Delete' && !isInput) { e.preventDefault(); clrCart(); return; }

        // Enter places order (from cart panel, not in input)
        if (e.key === 'Enter' && !isInput && $('#pCart').hasClass('act')) { e.preventDefault(); subOrder(); return; }

        // Number keys 1-9 quick add top items
        if (!isInput && !e.ctrlKey && !e.altKey && !e.shiftKey && /^[1-9]$/.test(e.key)) {
            var idx = parseInt(e.key) - 1;
            if (allProds[idx]) {
                addC(allProds[idx]);
                // Highlight the product card
                var $card = $('#pgrid .pc2[data-idx="' + idx + '"]');
                $card.css('border-color', 'var(--ok)');
                setTimeout(function () { $card.css('border-color', ''); }, 400);
            }
            return;
        }

        // Letters: quick search (when on product grid)
        if (!isInput && !e.ctrlKey && !e.altKey && e.key.length === 1 && /[a-zA-Z]/.test(e.key)) {
            $('#txSrch').val(e.key).focus();
            ldProds(); return;
        }
    }, false);

    $('#form1').on('submit', function (e) { e.preventDefault(); return false; });

    // Tab flow in cart: table -> covers -> submit
    $('#txTbl').on('keydown', function (e) {
        if (e.key === 'Tab' && !e.shiftKey) { e.preventDefault(); $('#txCov').focus(); }
    });
}

// =================== TOAST ===================
function ntf(msg, t) {
    t = t || 'ok';
    var bg = t === 'err' ? '#C62828' : t === 'warn' ? '#E65100' : t === 'info' ? '#1565C0' : '#1B5E20';
    var ic = t === 'err' ? 'fa-times-circle' : t === 'warn' ? 'fa-exclamation-triangle' : t === 'info' ? 'fa-info-circle' : 'fa-check-circle';
    var ex = $('.pntf').length, top = 58 + ex * 40;
    var $n = $('<div class="pntf" style="top:' + top + 'px;background:' + bg + ';"><i class="fa ' + ic + '"></i><span>' + msg + '</span></div>');
    $('body').append($n);
    setTimeout(function () { $n.fadeOut(180, function () { $(this).remove(); }); }, 2100);
}

// UpdatePanel sync
var prm = Sys.WebForms.PageRequestManager.getInstance();
prm.add_endRequest(function () {
    $('#sTodaySales').text($('#<%= lblTodaySales.ClientID %>').text());
    $('#sTodayBills').text($('#<%= lblTodayBills.ClientID %>').text());
    ldLive();
});
</script>
</form>
</body>
</html>
