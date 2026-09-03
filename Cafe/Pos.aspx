<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Pos.aspx.cs" Inherits="Pos" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
<title>POS - Waiter Panel</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<style>
/* ===== TOKENS ===== */
:root{
  --pr:#D32F2F;--pr-d:#B71C1C;--pr-l:#FFCDD2;
  --sc:#FF9800;--ok:#4CAF50;--ok-d:#388E3C;
  --err:#F44336;--warn:#FF9800;--inf:#2196F3;
  --dk:#4E342E;--gy:#795548;--lg:#D7CCC8;
  --sh:0 2px 8px rgba(211,47,47,.10);
  --sh-lg:0 6px 20px rgba(211,47,47,.14);
  --sh-xl:0 14px 36px rgba(211,47,47,.18);
  --g1:linear-gradient(135deg,#D32F2F,#FF9800);
  --g-lt:linear-gradient(135deg,#FFF8F5,#fff);
  --tr:.18s cubic-bezier(.4,0,.2,1);
  --hdr-h:96px;
  --cart-w:360px;
  --card-min:160px;
}
*{box-sizing:border-box;margin:0;padding:0;-webkit-tap-highlight-color:transparent;}
html,body{height:100%;overflow:hidden;}
body{font-family:'Poppins','Segoe UI',sans-serif;background:var(--g-lt);color:var(--dk);-webkit-font-smoothing:antialiased;}
::-webkit-scrollbar{width:5px;height:5px;}
::-webkit-scrollbar-thumb{background:var(--g1);border-radius:8px;}

/* ===== HEADER ===== */
.hdr{position:fixed;top:0;left:0;right:0;background:#fff;z-index:200;box-shadow:0 2px 10px rgba(211,47,47,.09);border-bottom:3px solid var(--pr-l);}
.h1{display:flex;justify-content:space-between;align-items:center;padding:6px 14px;border-bottom:1px solid var(--pr-l);background:#fff9f9;min-height:42px;}
.edp{display:flex;align-items:center;gap:8px;font-weight:700;color:var(--dk);font-size:12.5px;}
.eic{width:28px;height:28px;border-radius:50%;background:var(--g1);display:flex;align-items:center;justify-content:center;color:#fff;font-size:12px;flex-shrink:0;}
.hacts{display:flex;gap:6px;align-items:center;}
.hbtn{padding:6px 11px;border-radius:9px;background:var(--g1);color:#fff;border:none;font-weight:700;font-size:11.5px;cursor:pointer;display:flex;align-items:center;gap:5px;white-space:nowrap;font-family:'Poppins',sans-serif;transition:box-shadow var(--tr),transform var(--tr);}
.hbtn:hover{transform:translateY(-1px);box-shadow:var(--sh);}

/* ===== HEADER ROW 2 ===== */
.h2{display:flex;align-items:center;padding:6px 14px;gap:10px;background:#fff;flex-wrap:nowrap;min-height:48px;overflow:hidden;}
.dg{display:flex;align-items:center;gap:0;flex-shrink:0;background:#fff;border:2px solid var(--pr-l);border-radius:10px;overflow:hidden;box-shadow:0 2px 8px rgba(211,47,47,.08);transition:box-shadow .18s,border-color .18s;}
.dg:focus-within{border-color:var(--pr);box-shadow:0 4px 14px rgba(211,47,47,.16);}
.dl{display:flex;align-items:center;gap:4px;padding:0 9px;background:var(--g1);color:#fff;font-size:10.5px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;white-space:nowrap;height:34px;border-right:2px solid rgba(255,255,255,.2);flex-shrink:0;}
.dw{position:relative;display:flex;align-items:center;}
.dw::after{content:'\f107';font-family:'Font Awesome 6 Free';font-weight:900;position:absolute;right:9px;top:50%;transform:translateY(-50%);color:var(--pr);pointer-events:none;font-size:10px;}
.dsel{padding:0 26px 0 9px;height:34px;border:none;background:transparent;font-size:12px;font-weight:600;color:var(--dk);cursor:pointer;outline:none;appearance:none;-webkit-appearance:none;font-family:'Poppins',sans-serif;min-width:130px;max-width:180px;}
.dsel.ok{color:var(--ok-d);}
.btg{display:flex;align-items:center;gap:5px;flex:1;overflow:hidden;}
.btl{font-size:10px;font-weight:700;color:var(--gy);text-transform:uppercase;white-space:nowrap;display:none;}
.radio-label{display:inline-flex;align-items:center;gap:3px;padding:5px 9px;border-radius:8px;border:2px solid var(--lg);background:#fff;font-family:'Poppins',sans-serif;font-size:10.5px;font-weight:700;color:var(--gy);cursor:pointer;transition:all var(--tr);margin:0;white-space:nowrap;}
.radio-label:hover{border-color:var(--pr);color:var(--pr);background:#fff5f5;}
.radio-label.active{color:#fff;border-color:transparent;box-shadow:var(--sh);}
.radio-label[data-t="Club Member"].active{background:linear-gradient(135deg,#1565C0,#42A5F5);}
.radio-label[data-t="Guest House"].active{background:linear-gradient(135deg,#2E7D32,#66BB6A);}
.radio-label[data-t="Affiliated Member"].active{background:linear-gradient(135deg,#6A1B9A,#AB47BC);}
.radio-label[data-t="Non Member"].active{background:linear-gradient(135deg,#E65100,#FFA726);}
.radio-label input[type="radio"]{display:none;}

/* ===== MAIN SPLIT LAYOUT ===== */
.pw{
  display:flex;
  position:fixed;
  top:var(--hdr-h);
  left:0;right:0;bottom:0;
  overflow:hidden;
}

/* ===== LEFT PANEL ===== */
.lp{
  flex:1;
  display:flex;
  flex-direction:column;
  padding:10px;
  overflow:hidden;
  min-width:0;
  min-height:0;
}

/* ===== RIGHT PANEL ===== */
.rp{
  width:var(--cart-w);
  min-width:var(--cart-w);
  max-width:var(--cart-w);
  background:#fff;
  border-left:2px solid var(--pr-l);
  display:flex;
  flex-direction:column;
  overflow:hidden;
  min-height:0;
  box-shadow:-4px 0 18px rgba(211,47,47,.08);
}

/* ===== MEMBER BOXES ===== */
.ma{margin-bottom:8px;flex-shrink:0;}
.mr{display:flex;flex-wrap:nowrap;gap:7px;align-items:flex-start;}
.mb{background:#fff;border-radius:10px;padding:9px 10px;box-shadow:var(--sh);flex:1;min-width:0;}
.mb-cl{border:2px solid #90CAF9;background:linear-gradient(135deg,#E3F2FD,#fff);display:block;}
.mb-gh{border:2px solid #A5D6A7;background:linear-gradient(135deg,#E8F5E9,#F1F8E9);display:none;}
.mb-af{border:2px solid #CE93D8;background:linear-gradient(135deg,#F3E5F5,#fff);display:none;}
.mb-ng{border:2px solid var(--pr-l);background:linear-gradient(135deg,#FFF3E0,#fff);display:none;}
.mb-ps{border:2px solid var(--pr-l);background:linear-gradient(135deg,#FFF3E0,#fff);}
.mbt{font-weight:700;font-size:11px;margin-bottom:5px;display:flex;align-items:center;gap:4px;}
.mb-cl .mbt{color:#1565C0;}.mb-gh .mbt{color:#2E7D32;}.mb-af .mbt{color:#6A1B9A;}.mb-ps .mbt{color:var(--pr);}.mb-ng .mbt{color:#E65100;}
.sw{position:relative;display:flex;align-items:center;gap:4px;}
.swi{position:absolute;left:8px;font-size:11px;pointer-events:none;z-index:2;}
.mb-cl .swi{color:#1565C0;}.mb-gh .swi{color:#2E7D32;}.mb-af .swi{color:#6A1B9A;}.mb-ps .swi{color:var(--pr);}.mb-ng .swi{color:#E65100;}
.sw input{flex:1;padding:6px 8px 6px 26px;border-radius:7px;border:2px solid #ddd;font-size:12px;font-weight:500;outline:none;font-family:'Poppins',sans-serif;transition:border-color .14s;background:#fff;min-width:0;width:100%;}
.mb-cl .sw input:focus{border-color:#1565C0;}.mb-gh .sw input:focus{border-color:#2E7D32;}
.mb-af .sw input:focus{border-color:#6A1B9A;}.mb-ps .sw input:focus{border-color:var(--pr);}.mb-ng .sw input:focus{border-color:#E65100;}
.sw button{width:30px;height:30px;min-width:30px;border-radius:6px;border:none;cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:11px;flex-shrink:0;color:#fff;transition:transform .13s;}
.mb-cl .sw button{background:linear-gradient(135deg,#1565C0,#42A5F5);}
.mb-gh .sw button{background:linear-gradient(135deg,#2E7D32,#66BB6A);}
.mb-af .sw button{background:linear-gradient(135deg,#6A1B9A,#AB47BC);}
.mb-ps .sw button{background:var(--g1);}
.mb-ng .sw button{background:linear-gradient(135deg,#E65100,#FFA726);}
.sw button:hover{transform:scale(1.08);}
.tdot{position:absolute;right:38px;width:7px;height:7px;border-radius:50%;background:var(--warn);display:none;animation:pdot 1s infinite;}
.typing .tdot{display:block;}.found .tdot{background:var(--ok);display:block;}.nf .tdot{background:var(--err);display:block;}
.ghc{margin-top:6px;padding:7px 9px;border-radius:7px;background:linear-gradient(135deg,#E8F5E9,#fff);border:2px solid #66BB6A;border-left:4px solid #2E7D32;display:none;}
.ghc.ok{display:block;animation:fi .22s ease;}
.ghc.err{background:linear-gradient(135deg,#FFEBEE,#fff);border-color:#EF9A9A;border-left-color:var(--err);}
.ghr{display:flex;align-items:center;gap:5px;padding:2px 0;font-size:10.5px;}
.ghr i{color:#2E7D32;width:12px;}.ghr span{font-weight:600;color:var(--dk);}
.rc{margin-top:6px;display:none;border-radius:7px;padding:7px 9px;}
.rc.ok{display:block;background:linear-gradient(135deg,#E8F5E9,#fff);border:2px solid var(--ok);border-left:4px solid var(--ok);animation:fi .2s ease;}
.rc.err{display:block;background:linear-gradient(135deg,#FFEBEE,#fff);border:2px solid var(--err);border-left:4px solid var(--err);animation:fi .2s ease;}
.mdg{display:grid;grid-template-columns:repeat(auto-fit,minmax(120px,1fr));gap:3px;margin-top:4px;}
.md{display:flex;align-items:center;gap:4px;padding:3px 6px;background:#fff;border-radius:5px;border:1px solid var(--pr-l);font-size:10px;}
.md i{color:var(--pr);font-size:10px;}.md span{font-weight:600;color:var(--dk);}
.ng-nm{font-size:10px;color:#bf360c;margin-bottom:4px;opacity:.75;}

/* ===== CATEGORY TABS ===== */
.tabs{display:flex;gap:3px;margin-bottom:8px;padding:4px;background:var(--g-lt);border-radius:10px;border:2px solid var(--pr-l);overflow-x:auto;scrollbar-width:none;flex-shrink:0;}
.tabs::-webkit-scrollbar{display:none;}
.tab{flex:0 0 auto;min-width:64px;padding:5px 10px;border-radius:7px;background:transparent;border:none;color:var(--gy);font-weight:600;font-size:11px;cursor:pointer;transition:background var(--tr),color var(--tr);white-space:nowrap;font-family:'Poppins',sans-serif;}
.tab.act{color:#fff;background:var(--g1);box-shadow:var(--sh);}

/* ===== PRODUCT GRID ===== */
.grid{
  display:grid;
  grid-template-columns:repeat(auto-fill,minmax(var(--card-min),1fr));
  gap:10px;
  flex:1;
  min-height:0;
  overflow-y:auto;
  padding:2px 2px 12px;
  align-content:start;
  -webkit-overflow-scrolling:touch;
}

/* ===== PRODUCT CARD ===== */
.card{
  background:#fff;
  border-radius:12px;
  padding:0;
  cursor:pointer;
  box-shadow:var(--sh);
  display:flex;
  flex-direction:column;
  border:2px solid #fff;
  overflow:hidden;
  transition:transform .15s,box-shadow .15s,border-color .15s;
  min-height:140px;
}
.card:hover{transform:translateY(-3px);box-shadow:var(--sh-xl);border-color:var(--pr-l);}
.card:active{transform:scale(.97);}

/* Card icon area */
.card .cico{
  width:100%;
  height:76px;
  background:linear-gradient(135deg,#FFF3E0,#FFE0B2);
  display:flex;
  align-items:center;
  justify-content:center;
  flex-shrink:0;
}
.card .cico i{font-size:28px;color:var(--pr);opacity:.5;}
.card .cico img{width:100%;height:100%;object-fit:cover;display:block;}

/* Card body */
.card .cbody{
  flex:1;
  display:flex;
  flex-direction:column;
  padding:7px 8px 8px;
  gap:4px;
}
.card .nm{
  font-weight:700;
  font-size:11.5px;
  color:var(--dk);
  line-height:1.3;
  display:-webkit-box;
  -webkit-line-clamp:2;
  -webkit-box-orient:vertical;
  overflow:hidden;
  min-height:28px;
}
.card .gl{
  font-size:9.5px;
  color:var(--gy);
  background:#f5f5f5;
  border-radius:4px;
  padding:1px 5px;
  align-self:flex-start;
}
.card .px{
  font-size:13px;
  font-weight:800;
  color:var(--pr);
  text-align:center;
  padding:5px;
  background:var(--g-lt);
  border-radius:6px;
  border:2px solid var(--pr-l);
  margin-top:auto;
}

/* ===== RIGHT PANEL INNER ===== */
.rph{padding:9px 11px;border-bottom:2px solid var(--pr-l);background:var(--g-lt);flex-shrink:0;}
.rph h3{font-size:13.5px;font-weight:800;background:var(--g1);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;margin:0 0 5px;display:flex;align-items:center;gap:6px;}
.ptabs{display:flex;gap:3px;padding:3px;background:rgba(0,0,0,.04);border-radius:9px;}
.ptab{flex:1;padding:5px 3px;border-radius:7px;background:transparent;border:none;color:var(--gy);font-weight:600;font-size:10px;cursor:pointer;transition:background var(--tr),color var(--tr);display:flex;align-items:center;justify-content:center;gap:3px;white-space:nowrap;font-family:'Poppins',sans-serif;}
.ptab.act{background:#fff;color:var(--pr);box-shadow:var(--sh);}
.pc{display:none;flex-direction:column;flex:1;min-height:0;overflow-y:auto;padding:9px 11px 11px;overscroll-behavior:contain;-webkit-overflow-scrolling:touch;}
.pc.act{display:flex;}

/* ===== CART ITEMS ===== */
.ci{display:flex;align-items:center;gap:7px;padding:7px;background:#fff;border-radius:9px;margin-bottom:5px;box-shadow:var(--sh);border:2px solid var(--pr-l);}
.ci .cthumb{width:40px;height:40px;border-radius:6px;flex-shrink:0;overflow:hidden;background:linear-gradient(135deg,#FFF3E0,#FFE0B2);display:flex;align-items:center;justify-content:center;}
.ci .cthumb img{width:100%;height:100%;object-fit:cover;display:block;}
.ci .cthumb i{font-size:15px;color:var(--pr);opacity:.5;}
.ci .inf{flex:1;min-width:0;}
.ci .qty{display:flex;align-items:center;gap:3px;background:var(--g-lt);padding:3px;border-radius:6px;border:2px solid var(--pr-l);flex-shrink:0;}
.ci .qty button{width:22px;height:22px;min-width:22px;border-radius:5px;background:var(--g1);color:#fff;border:none;cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:700;transition:transform .12s;}
.ci .qty button:hover{transform:scale(1.1);}
.ci .qty button:disabled{opacity:.4;cursor:default;transform:none;}

/* ===== TOTALS ===== */
.tots{padding:9px 11px;background:#fff;border-top:2px solid var(--pr-l);display:flex;flex-direction:column;gap:5px;flex-shrink:0;}
.ngbox{background:linear-gradient(135deg,#FFF3E0,#fff);border:2px solid #FFCC80;border-radius:8px;padding:7px 9px;display:none;}
.ngbox.show{display:block;animation:fi .2s ease;}
.ngttl{font-size:10px;font-weight:700;color:#E65100;margin-bottom:3px;display:flex;align-items:center;gap:4px;}
.tcr{display:grid;grid-template-columns:1fr 1fr;gap:5px;}
.igl{display:flex;flex-direction:column;gap:2px;}
.igl label{font-size:9.5px;font-weight:700;color:var(--gy);display:flex;align-items:center;gap:3px;text-transform:uppercase;}
.igl label i{color:var(--pr);font-size:9.5px;}
.tinp{padding:6px 9px;border-radius:7px;border:2px solid var(--lg);font-size:12px;font-weight:600;color:var(--dk);width:100%;background:#fff;font-family:'Poppins',sans-serif;outline:none;transition:border-color .13s;}
.tinp:focus{border-color:var(--pr);}
.covinp{width:100%;padding:6px 9px;border:2px solid var(--lg);border-radius:7px;text-align:center;font-size:13px;font-weight:800;color:var(--dk);outline:none;font-family:'Poppins',sans-serif;transition:border-color .13s;}
.covinp:focus{border-color:var(--pr);}
#btnSubmit,#btnClear{width:100%;padding:9px;border-radius:8px;border:none;font-weight:700;font-size:12px;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px;font-family:'Poppins',sans-serif;transition:transform .13s,box-shadow .13s;}
#btnSubmit{background:var(--g1);color:#fff;box-shadow:var(--sh);}
#btnSubmit:hover{transform:translateY(-2px);box-shadow:var(--sh-lg);}
#btnClear{background:var(--g-lt);color:var(--err);border:2px solid rgba(244,67,54,.2);}
#btnClear:hover{background:var(--err);color:#fff;}
button:disabled{opacity:.55;cursor:not-allowed!important;transform:none!important;}

/* ===== ORDER ITEMS ===== */
.oi{background:#fff;border-radius:11px;padding:10px;margin-bottom:7px;box-shadow:var(--sh);border:2px solid var(--pr-l);}
.sbadge{padding:2px 7px;border-radius:11px;font-size:10px;font-weight:700;text-transform:uppercase;white-space:nowrap;}
.sbadge.pending{background:var(--warn);color:#fff;}
.sbadge.in-progress{background:var(--inf);color:#fff;}
.sbadge.completed{background:var(--ok);color:#fff;}
.sbadge.paid{background:var(--gy);color:#fff;}
.sbadge.delivered{background:#1565C0;color:#fff;}
.sbadge.cancelled{background:#B71C1C;color:#fff;}
.kotb{display:inline-flex;align-items:center;gap:3px;background:linear-gradient(135deg,#1565C0,#42A5F5);color:#fff;padding:2px 7px;border-radius:10px;font-size:10px;font-weight:700;white-space:nowrap;}

/* ===== ACTION BUTTONS ===== */
.abtns{display:flex;gap:5px;margin-top:8px;flex-wrap:wrap;}
.obtn{border:none;padding:5px 9px;border-radius:7px;cursor:pointer;display:inline-flex;align-items:center;justify-content:center;gap:4px;font-weight:600;font-size:10.5px;font-family:'Poppins',sans-serif;color:#fff;transition:transform .12s,box-shadow .12s;white-space:nowrap;flex-shrink:0;min-height:30px;}
.obtn:hover{transform:translateY(-1px);box-shadow:0 3px 10px rgba(0,0,0,.15);}
.ob-d{background:var(--inf);}
.ob-ok{background:var(--ok);}
.ob-cx{background:linear-gradient(135deg,#7B1FA2,#E040FB);}
.ob-x{background:linear-gradient(135deg,#B71C1C,#EF5350);}

/* ===== MODALS ===== */
.mbg{display:none;position:fixed;inset:0;background:rgba(0,0,0,.75);backdrop-filter:blur(6px);z-index:4000;align-items:center;justify-content:center;padding:12px;overflow-y:auto;}
.mbg.open{display:flex!important;}
.mbox{background:#fff;padding:18px;border-radius:14px;width:100%;max-width:420px;margin:auto;box-shadow:var(--sh-xl);animation:siu .22s ease;}
.recmod{display:none;position:fixed;inset:0;background:rgba(0,0,0,.78);backdrop-filter:blur(7px);z-index:5000;align-items:flex-start;justify-content:center;overflow-y:auto;-webkit-overflow-scrolling:touch;padding:10px;}
.recmod.open{display:flex!important;}
.recbox{background:#fff;padding:18px;border-radius:14px;width:100%;max-width:500px;margin:auto;box-shadow:var(--sh-xl);position:relative;animation:siu .22s ease;}
.mcx{position:absolute;top:10px;right:10px;width:28px;height:28px;border-radius:6px;background:var(--g-lt);color:var(--gy);display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:16px;border:none;transition:background var(--tr);}
.mcx:hover{background:var(--err);color:#fff;}

/* ===== EMPTY / LOADING / ERROR ===== */
.noc{display:flex;flex-direction:column;align-items:center;justify-content:center;padding:24px 12px;text-align:center;background:#fff;border-radius:11px;border:2px dashed var(--lg);color:var(--gy);}
.noc i{font-size:26px;margin-bottom:7px;color:var(--pr-l);}
.noc p{font-size:12.5px;font-weight:600;}
.noc .sub{font-size:10px;opacity:.7;}
.ld{display:flex;flex-direction:column;align-items:center;justify-content:center;padding:24px;color:var(--pr);gap:7px;font-size:12px;}
.er{display:flex;flex-direction:column;align-items:center;justify-content:center;padding:24px;color:var(--err);gap:7px;font-size:12px;}

/* ===== RECEIPT ===== */
.rw{font-family:'Courier New',Courier,monospace;max-width:320px;margin:0 auto;background:#fff;border:1px solid #e0e0e0;border-radius:4px;padding:14px 12px;}
.rh{text-align:center;padding-bottom:10px;margin-bottom:8px;border-bottom:2px dashed #333;}
.rh .r-logo{font-size:17px;font-weight:900;letter-spacing:1px;color:#000;line-height:1.2;}
.rh .r-sub{font-size:11px;color:#444;margin:2px 0;}
.rh .r-dept{font-size:12px;font-weight:700;color:#222;margin:3px 0;}
.kb{display:inline-block;background:#111;color:#fff;padding:3px 12px;border-radius:3px;font-size:12px;font-weight:800;letter-spacing:2px;margin:5px 0 0;}
.is{padding:8px 0;margin-bottom:6px;border-bottom:1px dashed #999;}
.ir{display:flex;justify-content:space-between;align-items:flex-start;padding:2px 0;font-size:11px;color:#333;}
.ir .il{font-weight:700;color:#111;white-space:nowrap;min-width:70px;}
.ir .iv{text-align:right;word-break:break-word;}
.rt{width:100%;border-collapse:collapse;margin:6px 0;}
.rt thead tr{border-top:2px dashed #333;border-bottom:2px dashed #333;}
.rt th{padding:5px 3px;font-size:11px;font-weight:800;text-align:left;color:#000;}
.rt th:last-child{text-align:right;}
.rt td{padding:4px 3px;font-size:11px;color:#333;border-bottom:1px dashed #ccc;vertical-align:top;}
.rt td:nth-child(2){text-align:center;font-weight:700;}
.rt td:last-child{text-align:right;font-weight:700;white-space:nowrap;}
.rt tfoot tr{border-top:2px dashed #333;}
.r-totals{border-top:2px dashed #333;padding-top:8px;margin-top:2px;}
.r-tot-row{display:flex;justify-content:space-between;font-size:11px;padding:2px 0;color:#333;}
.r-tot-row.grand{font-size:13px;font-weight:900;color:#000;border-top:1px solid #333;margin-top:4px;padding-top:5px;}
.ft{text-align:center;padding-top:10px;margin-top:6px;border-top:2px dashed #333;}
.ft p{font-size:10px;color:#555;line-height:1.5;}
.ft .thank{font-size:12px;font-weight:800;color:#000;letter-spacing:1px;}

/* ===== SHORTCUT BAR ===== */
.scut{position:fixed;bottom:8px;left:8px;background:rgba(0,0,0,.46);color:#fff;padding:4px 9px;border-radius:10px;font-size:10px;backdrop-filter:blur(4px);z-index:9999;font-family:'Poppins',sans-serif;pointer-events:none;}

/* ===== PRINT ===== */
@media print{
  body *{visibility:hidden;}
  .prt-area,.prt-area *{visibility:visible;}
  .prt-area{position:absolute;left:0;top:0;width:80mm;margin:0;padding:0;font-family:'Courier New',Courier,monospace;background:#fff;}
}

/* ===========================================================
   RESPONSIVE BREAKPOINTS
=========================================================== */

/* Large desktop - more columns */
@media(min-width:1400px){
  :root{--cart-w:400px;--card-min:170px;}
}

/* Standard desktop */
@media(max-width:1399px) and (min-width:1101px){
  :root{--cart-w:360px;--card-min:155px;}
}

/* Small desktop / large tablet landscape */
@media(max-width:1100px) and (min-width:901px){
  :root{--cart-w:320px;--card-min:140px;}
  .card .cico{height:68px;}
  .radio-label{padding:5px 7px;font-size:10px;}
}

/* Tablet landscape / iPad Pro */
@media(max-width:900px) and (min-width:681px){
  :root{--cart-w:280px;--card-min:120px;}
  .h2{flex-wrap:wrap;min-height:auto;padding:5px 10px;gap:6px;}
  .btg{flex-wrap:wrap;gap:4px;}
  .radio-label{padding:4px 7px;font-size:10px;gap:2px;}
  .radio-label i{display:none;}
  .dsel{min-width:110px;max-width:160px;}
  .card .cico{height:60px;}
  .card .nm{font-size:11px;}
  .card .px{font-size:12px;padding:4px;}
  .mr{flex-wrap:wrap;gap:6px;}
  .mb{min-width:calc(50% - 3px);flex:1 1 calc(50% - 3px);}
  .mb-ps{min-width:100%;flex:1 1 100%;}
}

/* Tablet portrait / iPad */
@media(max-width:680px){
  html,body{overflow:auto;}
  .pw{flex-direction:column;position:static;padding:8px;gap:8px;overflow:visible;}
  .lp{overflow:visible;padding:0;}
  .rp{width:100%;min-width:unset;max-width:none;border-left:none;border-top:2px solid var(--pr-l);box-shadow:none;}
  .grid{max-height:55vh;}
  .pc.act{max-height:60vh;}
  :root{--card-min:130px;}
  .card .cico{height:64px;}
}

/* Mobile */
@media(max-width:599px){
  :root{--card-min:calc(50% - 6px);}
  .h2{flex-wrap:wrap;align-items:flex-start;padding:5px 10px;gap:4px;}
  .dg{width:100%;}
  .dsel{min-width:0;width:100%;max-width:none;}
  .btg{width:100%;gap:3px;}
  .radio-label{flex:1;font-size:10px;padding:5px 3px;gap:2px;justify-content:center;}
  .radio-label i{display:none;}
  .grid{grid-template-columns:repeat(2,1fr);gap:7px;max-height:44vh;}
  .card .cico{height:58px;}
  .card .nm{font-size:10.5px;}
  .card .px{font-size:12px;}
  .mr{flex-direction:column;gap:6px;}
  .mb{width:100%;min-width:unset;}
  .scut{display:none;}
}

/* Very small mobile */
@media(max-width:380px){
  .radio-label{padding:4px 2px;font-size:9.5px;}
  .card .cico{height:50px;}
  .card .nm{font-size:10px;}
}
</style>
</head>
<body>
<form id="form1" runat="server">
<asp:ScriptManager ID="SM1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
<asp:HiddenField ID="hdnSelectedDeptID" runat="server" />
<asp:HiddenField ID="hdnSelectedDeptName" runat="server" />
<asp:HiddenField ID="hdnEmpID" runat="server" />
<asp:HiddenField ID="hdnIsManager" runat="server" />
<asp:HiddenField ID="hdnBillType" runat="server" Value="Club Member" />
<!-- Stores the current dept SubDept_abb fetched from DB -->
<asp:HiddenField ID="hdnDeptAbb" runat="server" Value="" />

<!-- ===== HEADER ===== -->
<div class="hdr" id="hdrEl">
  <div class="h1">
    <div class="edp">
      <div class="eic"><i class="fa fa-user"></i></div>
      <span>Waiter: <strong id="empDisplay" runat="server">...</strong></span>
    </div>
    <div class="hacts">
      <button type="button" class="hbtn" id="btnActive"><i class="fa fa-bolt"></i> Active</button>
    </div>
  </div>
  <div class="h2">
    <div class="dg" id="deptGroup">
      <span class="dl"><i class="fa fa-utensils"></i> Dept</span>
      <div class="dw">
        <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="dsel" AutoPostBack="false"></asp:DropDownList>
      </div>
    </div>
    <div class="btg">
      <label class="radio-label active" data-t="Club Member">
        <input type="radio" name="billType" value="Club Member" checked="checked" />
        <i class="fa fa-id-card"></i> Club Member
      </label>
      <label class="radio-label" data-t="Guest House">
        <input type="radio" name="billType" value="Guest House" />
        <i class="fa fa-bed"></i> Guest House
      </label>
      <label class="radio-label" data-t="Affiliated Member">
        <input type="radio" name="billType" value="Affiliated Member" />
        <i class="fa fa-handshake"></i> Affiliated
      </label>
      <label class="radio-label" data-t="Non Member">
        <input type="radio" name="billType" value="Non Member" />
        <i class="fa fa-user-slash"></i> Non Member
      </label>
    </div>
  </div>
</div>

<!-- ===== MAIN LAYOUT ===== -->
<div class="pw" id="pw">

 <!-- LEFT: MENU -->
 <div class="lp">

  <!-- Member Search Boxes -->
  <div class="ma">
    <div class="mr">

      <!-- Club Member -->
      <div class="mb mb-cl" id="bxCl">
        <div class="mbt"><i class="fa fa-id-card"></i> Club Member</div>
        <div class="sw" id="swM">
          <i class="fa fa-search swi"></i>
          <input type="text" id="txM" placeholder="Scan card or member no..." autocomplete="off" />
          <span class="tdot"></span>
          <button type="button" id="btnSM"><i class="fa fa-search"></i></button>
        </div>
        <div class="rc" id="rcM"></div>
      </div>

      <!-- Guest House -->
      <div class="mb mb-gh" id="bxGH">
        <div class="mbt"><i class="fa fa-bed"></i> Guest House</div>
        <div class="sw">
          <i class="fa fa-door-open swi"></i>
          <input type="text" id="txGH" placeholder="Enter Room No (e.g. 017)..." autocomplete="off" />
          <button type="button" id="btnSGH"><i class="fa fa-search"></i></button>
        </div>
        <div class="ghc" id="ghc"></div>
      </div>

      <!-- Affiliated -->
      <div class="mb mb-af" id="bxAF">
        <div class="mbt"><i class="fa fa-handshake"></i> Affiliated Member</div>
        <div class="sw">
          <i class="fa fa-search swi"></i>
          <input type="text" id="txAF" placeholder="Intro/Member No/Name..." autocomplete="off" />
          <button type="button" id="btnSAF"><i class="fa fa-search"></i></button>
        </div>
        <div class="rc" id="rcAF"></div>
      </div>

      <!-- Non Member -->
      <div class="mb mb-ng" id="bxNG">
        <div class="mbt"><i class="fa fa-users"></i> Non Member — Guest Entry</div>
        <div class="ng-nm">Enter number of guests</div>
        <div class="sw">
          <i class="fa fa-users swi"></i>
          <input type="number" id="txNG" placeholder="No. of Guests" min="1" max="999" value="1" autocomplete="off" />
        </div>
      </div>

      <!-- Product Search -->
      <div class="mb mb-ps">
        <div class="mbt"><i class="fa fa-search"></i> Search Product</div>
        <div class="sw">
          <i class="fa fa-search swi"></i>
          <input type="text" id="txSrch" placeholder="Search products..." autocomplete="off" />
          <button type="button" id="btnRld"><i class="fa fa-sync-alt"></i></button>
        </div>
      </div>

    </div>
  </div>

  <!-- Category Tabs -->
  <div class="tabs">
    <button class="tab act" data-c="">All Items</button>
    <button class="tab" data-c="Beverages">Beverages</button>
    <button class="tab" data-c="Snacks">Snacks</button>
    <button class="tab" data-c="Main Course">Main Course</button>
    <button class="tab" data-c="Desserts">Desserts</button>
  </div>

  <!-- Product Grid -->
  <div class="grid" id="grid">
    <div class="noc" style="grid-column:1/-1">
      <i class="fa fa-building"></i>
      <p>Select a department to view products</p>
    </div>
  </div>

 </div>

 <!-- RIGHT: CART PANEL -->
 <div class="rp">
  <div class="rph">
    <h3><i class="fa fa-shopping-cart"></i> Cart &amp; Orders</h3>
    <div class="ptabs">
      <button class="ptab act" data-c="cart"><i class="fa fa-shopping-cart"></i> Cart</button>
      <button class="ptab" data-c="active"><i class="fa fa-bolt"></i> Active</button>
      <button class="ptab" data-c="delivered"><i class="fa fa-check-double"></i> Done</button>
      <button class="ptab" data-c="history"><i class="fa fa-history"></i> History</button>
    </div>
  </div>

  <!-- Cart Tab -->
  <div class="pc act" id="pcCart">
    <div id="citems">
      <div class="noc">
        <i class="fa fa-shopping-cart"></i>
        <p>Cart is empty</p>
        <p class="sub">Add items from menu</p>
      </div>
    </div>
    <div class="tots">
      <div class="ngbox" id="ngbox">
        <div class="ngttl"><i class="fa fa-users"></i> Non Member Order</div>
        <div style="font-size:10px;color:#bf360c;">Guest count: <strong id="ngcnt">1</strong></div>
      </div>
      <div class="tcr">
        <div class="igl">
          <label><i class="fa fa-table"></i> Table No</label>
          <input type="text" id="txTbl" class="tinp" placeholder="T-01 (opt)" />
        </div>
        <div class="igl">
          <label><i class="fa fa-users"></i> Covers</label>
          <input type="number" id="txCov" class="covinp" value="1" min="1" max="99" />
        </div>
      </div>
      <div id="totbox">
        <div style="display:flex;justify-content:space-between;font-size:12px;"><span>Subtotal</span><span style="font-weight:700;">Rs. 0.00</span></div>
        <div style="display:flex;justify-content:space-between;font-size:12px;"><span>GST</span><span style="font-weight:700;">Rs. 0.00</span></div>
        <div style="display:flex;justify-content:space-between;margin-top:4px;font-size:13px;border-top:2px dashed var(--pr-l);padding-top:4px;">
          <span style="font-weight:800;color:var(--pr);">Total</span>
          <span style="font-weight:800;color:var(--pr);" id="gtot">Rs. 0.00</span>
        </div>
      </div>
      <button type="button" id="btnSubmit"><i class="fa fa-check-circle"></i> Place Order</button>
      <button type="button" id="btnClear"><i class="fa fa-trash"></i> Clear Cart</button>
    </div>
  </div>

  <!-- Active Orders Tab -->
  <div class="pc" id="pcActive">
    <div id="alst"><div class="noc"><i class="fa fa-bolt"></i><p>No active orders</p></div></div>
  </div>

  <!-- Delivered Tab -->
  <div class="pc" id="pcDelivered">
    <div id="dlst"><div class="noc"><i class="fa fa-check-double"></i><p>No delivered orders</p></div></div>
  </div>

  <!-- History Tab -->
  <div class="pc" id="pcHistory">
    <div id="hlst"><div class="noc"><i class="fa fa-history"></i><p>No order history</p></div></div>
  </div>
 </div>
</div>

<!-- ===== RECEIPT MODAL ===== -->
<div class="recmod" id="recmod">
  <div class="recbox">
    <button class="mcx" id="btnXrec">&times;</button>
    <h3 style="margin:0 0 11px;color:var(--pr);font-size:14px;padding-right:36px;"><i class="fa fa-receipt"></i> Receipt / KOT</h3>
    <div id="recbody"></div>
    <button class="hbtn" onclick="prt()" style="margin-top:11px;width:100%;justify-content:center;font-size:13px;padding:9px;">
      <i class="fa fa-print"></i> Print KOT
    </button>
  </div>
</div>

<!-- ===== CANCEL KOT MODAL ===== -->
<div class="mbg" id="cxmod">
  <div class="mbox" style="border:2px solid #E1BEE7;max-width:460px;">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;padding-bottom:8px;border-bottom:2px solid #E1BEE7;">
      <div style="font-size:13.5px;font-weight:800;color:#7B1FA2;display:flex;align-items:center;gap:5px;">
        <i class="fa fa-ban"></i> Cancel KOT Request
      </div>
      <button id="btnCxX" style="width:27px;height:27px;border-radius:6px;background:#F3E5F5;color:#7B1FA2;border:none;cursor:pointer;font-size:15px;display:flex;align-items:center;justify-content:center;flex-shrink:0;">&times;</button>
    </div>
    <div id="cxdetails" style="background:linear-gradient(135deg,#F3E5F5,#fff);border:2px solid #CE93D8;border-radius:9px;padding:9px 11px;margin-bottom:9px;font-size:11.5px;"></div>
    <div style="font-weight:700;font-size:11px;margin-bottom:5px;display:flex;align-items:center;gap:4px;">
      <i class="fa fa-comment-alt" style="color:#7B1FA2;"></i> Cancellation Reason <span style="color:var(--err);">*</span>
    </div>
    <textarea id="cxrmk" style="width:100%;padding:8px;border-radius:7px;border:2px solid var(--lg);font-size:12px;font-family:'Poppins',sans-serif;resize:vertical;min-height:68px;outline:none;" placeholder="Enter reason for cancellation..."></textarea>
    <div style="display:flex;gap:6px;margin-top:10px;">
      <button id="btnCxBk" style="padding:9px 11px;border-radius:7px;background:var(--g-lt);color:var(--gy);border:2px solid var(--lg);font-size:12px;font-weight:600;cursor:pointer;font-family:'Poppins',sans-serif;white-space:nowrap;">
        <i class="fa fa-arrow-left"></i> Back
      </button>
      <button id="btnCxOk" style="flex:1;padding:9px;border-radius:7px;background:linear-gradient(135deg,#7B1FA2,#E040FB);color:#fff;border:none;font-size:12px;font-weight:700;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:5px;font-family:'Poppins',sans-serif;">
        <i class="fa fa-ban"></i> Submit Cancel Request
      </button>
    </div>
  </div>
</div>

<div class="scut"><i class="fa fa-keyboard" style="color:#FFCDD2;margin-right:3px;"></i>F1:Member &nbsp;F2:Search &nbsp;ESC:Close</div>

<script>
    // ===== STATE =====
    var cart = [], mem = null, afm = null, ghi = null;
    var mode = 'cart', eid = '', enm = '', bt = 'Club Member';
    var srch = false, afs = false, ghs = false;
    var cxoid = null, cxkot = '';
    var sb = '', sl = 0, slk = false, ls = { v: '', t: 0 };
    var kbt = null, aft = null, ght = null, prt2 = null;
    var isSubmitting = false;
    var deptAbb = ''; // Stores current dept abbreviation from SubDepartment table

    $(function () {
        eid = $('#<%= hdnEmpID.ClientID %>').val() || '';
    enm = $('#empDisplay').text().trim();
    deptAbb = $('#<%= hdnDeptAbb.ClientID %>').val() || '';
    setHdrHeight();
    initDept(); initBT(); initMS(); initGH(); initAF(); initPS();
    initUI(); initCx(); initKeys();
    ldCart(); updCnt();
    showBUI('Club Member');
    $(window).on('resize', debounce(setHdrHeight, 80));
    setTimeout(function () { $('#txM').focus(); }, 220);
});

function debounce(fn, ms) {
    var t; return function () { clearTimeout(t); t = setTimeout(fn, ms); };
}

function setHdrHeight() {
    var h = $('#hdrEl').outerHeight(true) || 96;
    document.documentElement.style.setProperty('--hdr-h', h + 'px');
    if ($(window).width() > 680) $('#pw').css('top', h + 'px');
    else $('#pw').css('top', '');
}

// ===== DEPARTMENT =====
function initDept() {
    var el = $('#<%= ddlDepartment.ClientID %>')[0];
    el.onchange = function () {
        var id = this.value, nm = this.options[this.selectedIndex] ? this.options[this.selectedIndex].text : '';
        if (id && id.trim()) {
            $(this).addClass('ok');
            $('#<%= hdnSelectedDeptID.ClientID %>').val(id);
            $('#<%= hdnSelectedDeptName.ClientID %>').val(nm);
            ntf('Dept: ' + nm, 'ok');
            // Fetch abbreviation dynamically for this dept
            fetchDeptAbb(id);
            ldProds();
        } else {
            $(this).removeClass('ok');
            $('#<%= hdnSelectedDeptID.ClientID %>').val('');
            $('#<%= hdnSelectedDeptName.ClientID %>').val('');
            deptAbb = '';
            $('#<%= hdnDeptAbb.ClientID %>').val('');
            $('#grid').html('<div class="noc" style="grid-column:1/-1"><i class="fa fa-building"></i><p>Select a department first</p></div>');
        }
    };
    $('#<%= ddlDepartment.ClientID %>').on('keydown', function (e) { if (e.key === 'Enter') { e.preventDefault(); e.stopPropagation(); } });
    var iv = $('#<%= ddlDepartment.ClientID %>').val();
    if (iv && iv.trim()) {
        $('#<%= ddlDepartment.ClientID %>').addClass('ok');
        fetchDeptAbb(iv);
        ldProds();
    }
}

function fetchDeptAbb(subDeptId) {
    if (!subDeptId) return;
    $.ajax({
        type: 'POST', url: 'Pos.aspx/GetSubDeptAbb',
        data: JSON.stringify({ subDeptId: subDeptId }),
        contentType: 'application/json;charset=utf-8', dataType: 'json',
        success: function (r) {
            if (r && r.d && r.d.success) {
                deptAbb = r.d.abb || '';
                $('#<%= hdnDeptAbb.ClientID %>').val(deptAbb);
            }
        },
        error: function () { deptAbb = ''; }
    });
}

function gDid() { return $('#<%= hdnSelectedDeptID.ClientID %>').val() || ''; }
    function gDnm() { return $('#<%= hdnSelectedDeptName.ClientID %>').val() || ''; }

    // ===== BILL TYPE =====
    function initBT() {
        $('input[name="billType"]').on('change', function () {
            var t = $(this).val();
            bt = t;
            $('#<%= hdnBillType.ClientID %>').val(t);
        $('.radio-label').removeClass('active');
        $(this).closest('.radio-label').addClass('active');
        resetM(); showBUI(t);
        ntf('Bill to: ' + t, 'info');
    });
}

function resetM() {
    mem = null; afm = null; ghi = null;
    $('#rcM').attr('class', 'rc').html('');
    $('#rcAF').attr('class', 'rc').html('');
    $('#ghc').attr('class', 'ghc').html('');
    $('#txM').val(''); setMS('idle');
    $('#txAF').val(''); $('#txGH').val('');
}

function showBUI(t) {
    $('.mb:not(.mb-ps)').hide();
    $('#ngbox').removeClass('show');
    if (t === 'Club Member') { $('#bxCl').show(); setTimeout(function () { $('#txM').focus(); }, 80); }
    else if (t === 'Guest House') { $('#bxGH').show(); setTimeout(function () { $('#txGH').focus(); }, 80); }
    else if (t === 'Affiliated Member') { $('#bxAF').show(); setTimeout(function () { $('#txAF').focus(); }, 80); }
    else if (t === 'Non Member') { $('#bxNG').show(); $('#ngbox').addClass('show'); setTimeout(function () { $('#txNG').focus(); }, 80); }
}

$('#txNG').on('input change', function () {
    var v = parseInt($(this).val()) || 1;
    $('#ngcnt').text(v);
});

// ===== MEMBER SEARCH =====
function initMS() {
    var $i = $('#txM');
    $i.on('input', function () {
        var v = $(this).val().trim();
        if (kbt) { clearTimeout(kbt); kbt = null; }
        if (!v) { mem = null; $('#rcM').attr('class', 'rc').html(''); setMS('idle'); return; }
        if (v.length >= 2) { setMS('typing'); kbt = setTimeout(function () { kbt = null; if (!slk && !srch) doMS($i.val().trim(), false); }, 400); }
    });
    $i.on('keydown', function (e) {
        var now = Date.now();
        if (e.key === 'Enter') { e.preventDefault(); e.stopPropagation(); if (kbt) { clearTimeout(kbt); kbt = null; } var v = $(this).val().trim(); if (v && !srch) doMS(v, false); return; }
        if (e.key.length === 1 && (now - sl) < 38) sb += e.key; else sb = e.key; sl = now;
    });
    $i.on('keyup', function (e) {
        if (e.key === 'Enter' && sb.length >= 4) {
            var sv = sb; sb = ''; var now = Date.now();
            if (sv === ls.v && (now - ls.t) < 2000) return;
            ls = { v: sv, t: now };
            if (!slk && !srch) { slk = true; doMS(sv, true); setTimeout(function () { slk = false; }, 800); }
        } else if (e.key !== 'Enter') sb = '';
    });
    $i.on('paste', function (e) {
        e.preventDefault();
        var p = e.originalEvent.clipboardData.getData('text').trim();
        if (p && !slk && !srch) { $(this).val(p); if (kbt) { clearTimeout(kbt); kbt = null; } doMS(p, false); }
    });
    $('#btnSM').on('click', function () {
        if (kbt) { clearTimeout(kbt); kbt = null; }
        var v = $('#txM').val().trim();
        if (!v) { ntf('Enter member no or scan!', 'warn'); $('#txM').focus(); return; }
        if (!srch) doMS(v, false);
    });
}

function doMS(val, sc) {
    if (!val || srch) return; srch = true; setMS('typing');
    var $c = $('#rcM');
    $c.attr('class', 'rc ok').html('<div style="text-align:center;padding:6px;"><i class="fa fa-spinner fa-spin" style="color:#1565C0;font-size:17px;"></i></div>');
    $.ajax({
        type: 'POST', url: 'Pos.aspx/GetMember', data: JSON.stringify({ search: val }),
        contentType: 'application/json;charset=utf-8', dataType: 'json', timeout: 9000,
        success: function (r) {
            r = r.d;
            if (r && r.success) {
                mem = r; setMS('found');
                $c.attr('class', 'rc ok').html(
                    '<div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:3px;margin-bottom:4px;">' +
                    '<div style="font-weight:800;font-size:12.5px;"><i class="fa fa-id-card" style="color:var(--ok);"></i> ' + (r.CardNo || 'N/A') + '</div>' +
                    '<span class="sbadge" style="background:var(--ok);color:#fff;"><i class="fa fa-check-circle"></i> Active</span></div>' +
                    '<div class="mdg"><div class="md"><i class="fa fa-user"></i><span><b>Name:</b> ' + (r.DisplayName || r.Name || 'N/A') + '</span></div></div>'
                );
                ntf('Member: ' + (r.DisplayName || r.Name), 'ok');
                if (sc) $('#txM').val('');
            } else {
                mem = null; setMS('nf');
                $c.attr('class', 'rc err').html('<div style="display:flex;align-items:center;gap:6px;"><i class="fa fa-exclamation-triangle" style="color:var(--err);font-size:14px;"></i><span style="font-weight:700;color:var(--err);font-size:12px;">Not Found</span></div><p style="font-size:10px;color:var(--gy);margin-top:3px;">' + (r && r.message ? r.message : 'No member found') + '</p>');
                ntf(r && r.message ? r.message : 'Member not found', 'err');
                setTimeout(function () { $c.attr('class', 'rc').html(''); }, 2800);
            }
        },
        error: function () { mem = null; setMS('nf'); $c.attr('class', 'rc err').html('<div style="color:var(--err);font-weight:700;font-size:12px;"><i class="fa fa-exclamation-triangle"></i> Server error</div>'); ntf('Server error', 'err'); },
        complete: function () { setTimeout(function () { srch = false; }, 300); }
    });
}
function setMS(s) { var $w = $('#swM').removeClass('typing found nf'); if (s === 'typing') $w.addClass('typing'); else if (s === 'found') $w.addClass('found'); else if (s === 'nf') $w.addClass('nf'); }

// ===== GUEST HOUSE =====
function initGH() {
    $('#txGH').on('input', function () {
        var v = $(this).val().trim(); if (ght) { clearTimeout(ght); ght = null; }
        if (!v) { ghi = null; $('#ghc').attr('class', 'ghc').html(''); return; }
        if (v.length >= 2) { ght = setTimeout(function () { ght = null; doGH($('#txGH').val().trim()); }, 480); }
    });
    $('#txGH').on('keydown', function (e) { if (e.key === 'Enter') { e.preventDefault(); var v = $(this).val().trim(); if (v) { if (ght) { clearTimeout(ght); ght = null; } doGH(v); } } });
    $('#btnSGH').on('click', function () { var v = $('#txGH').val().trim(); if (!v) { ntf('Enter Room Number!', 'warn'); $('#txGH').focus(); return; } if (ght) { clearTimeout(ght); ght = null; } doGH(v); });
}

function doGH(rn) {
    if (ghs) return; ghs = true;
    var $c = $('#ghc');
    $c.attr('class', 'ghc ok').html('<div style="text-align:center;padding:5px;"><i class="fa fa-spinner fa-spin" style="color:#2E7D32;font-size:15px;"></i></div>');
    $.ajax({
        type: 'POST', url: 'Pos.aspx/GetRoomInfo', data: JSON.stringify({ roomNo: rn }),
        contentType: 'application/json;charset=utf-8', dataType: 'json', timeout: 9000,
        success: function (r) {
            r = r.d;
            if (r && r.success) {
                ghi = r;
                var extra = '';
                if (r.GuestOf) extra += '<div class="ghr"><i class="fa fa-user-friends"></i><span><b>Guest Of:</b> ' + r.GuestOf + '</span></div>';
                if (r.ClubName) extra += '<div class="ghr"><i class="fa fa-building"></i><span><b>Club:</b> ' + r.ClubName + '</span></div>';
                $c.attr('class', 'ghc ok').html(
                    '<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:5px;">' +
                    '<span style="font-weight:800;font-size:11px;color:#1B5E20;"><i class="fa fa-check-circle" style="color:#2E7D32;"></i> Room Found</span>' +
                    '<span style="font-size:9px;background:#2E7D32;color:#fff;padding:2px 6px;border-radius:5px;font-weight:700;">OCCUPIED</span></div>' +
                    '<div class="ghr"><i class="fa fa-door-open"></i><span><b>Room:</b> ' + r.RoomNo + '</span></div>' +
                    '<div class="ghr"><i class="fa fa-user"></i><span><b>Guest:</b> ' + r.GuestName + '</span></div>' +
                    '<div class="ghr"><i class="fa fa-hashtag"></i><span><b>Res#:</b> ' + r.ReservationNo + '</span></div>' + extra
                );
                ntf('Room ' + r.RoomNo + ' — ' + r.GuestName, 'ok');
            } else {
                ghi = null;
                $c.attr('class', 'ghc err').html('<div class="ghr"><i class="fa fa-exclamation-triangle" style="color:var(--err);"></i><span style="color:var(--err);font-weight:700;font-size:11px;">' + (r && r.message ? r.message : 'Room not found') + '</span></div>');
                ntf(r && r.message ? r.message : 'Room not found', 'err');
            }
        },
        error: function () { ghi = null; $c.attr('class', 'ghc err').html('<div class="ghr"><i class="fa fa-exclamation-triangle" style="color:var(--err);"></i><span style="color:var(--err);font-weight:700;">Server error</span></div>'); ntf('Server error', 'err'); },
        complete: function () { setTimeout(function () { ghs = false; }, 300); }
    });
}

// ===== AFFILIATED MEMBER =====
function initAF() {
    $('#txAF').on('input', function () {
        var v = $(this).val().trim(); if (aft) { clearTimeout(aft); aft = null; }
        if (!v) { afm = null; $('#rcAF').attr('class', 'rc').html(''); return; }
        if (v.length >= 2) { aft = setTimeout(function () { aft = null; doAF($('#txAF').val().trim()); }, 400); }
    });
    $('#txAF').on('keydown', function (e) { if (e.key === 'Enter') { e.preventDefault(); var v = $(this).val().trim(); if (v) { if (aft) { clearTimeout(aft); aft = null; } doAF(v); } } });
    $('#btnSAF').on('click', function () { var v = $('#txAF').val().trim(); if (!v) { ntf('Enter search!', 'warn'); $('#txAF').focus(); return; } if (aft) { clearTimeout(aft); aft = null; } doAF(v); });
}

function doAF(val) {
    if (!val || afs) return; afs = true;
    var $c = $('#rcAF');
    $c.attr('class', 'rc ok').html('<div style="text-align:center;padding:5px;"><i class="fa fa-spinner fa-spin" style="color:#6A1B9A;font-size:15px;"></i></div>');
    $.ajax({
        type: 'POST', url: 'Pos.aspx/SearchAffiliatedMember', data: JSON.stringify({ search: val }),
        contentType: 'application/json;charset=utf-8', dataType: 'json', timeout: 9000,
        success: function (r) {
            r = r.d;
            if (r && r.success && r.data && r.data.length) {
                if (r.data.length === 1) {
                    afm = r.data[0];
                    $c.attr('class', 'rc ok').html(bldAF(afm));
                    ntf('Found: ' + afm.MemberName, 'ok');
                } else {
                    var h = '<div style="font-size:11px;font-weight:700;color:#6A1B9A;margin-bottom:5px;">' + r.data.length + ' results — tap to select</div>';
                    r.data.forEach(function (m, i) {
                        h += '<div class="afl" data-i="' + i + '" style="cursor:pointer;padding:5px 7px;border-radius:6px;border:1.5px solid #CE93D8;margin-bottom:4px;background:#fff;">' +
                            '<div style="font-weight:700;font-size:11px;color:#4A148C;">' + m.MemberName + '</div>' +
                            '<div style="font-size:10px;color:var(--gy);">' + m.IntroductoryNo + ' | ' + m.ClubName + '</div></div>';
                    });
                    $c.attr('class', 'rc ok').html(h);
                    $c.find('.afl').on('click', function () {
                        var i = parseInt($(this).data('i'));
                        afm = r.data[i];
                        $c.html(bldAF(afm));
                        ntf('Selected: ' + afm.MemberName, 'ok');
                    });
                }
            } else {
                afm = null;
                $c.attr('class', 'rc err').html('<div style="font-weight:700;color:var(--err);font-size:11.5px;"><i class="fa fa-exclamation-triangle"></i> ' + (r && r.message ? r.message : 'Not found') + '</div>');
                ntf('No affiliated member found', 'err');
                setTimeout(function () { $c.attr('class', 'rc').html(''); }, 2600);
            }
        },
        error: function () { afm = null; $c.attr('class', 'rc err').html('<div style="color:var(--err);font-weight:700;"><i class="fa fa-exclamation-triangle"></i> Server error</div>'); ntf('Server error', 'err'); },
        complete: function () { setTimeout(function () { afs = false; }, 300); }
    });
}
function bldAF(m) {
    return '<div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:3px;margin-bottom:4px;">' +
        '<span style="font-weight:800;font-size:12px;color:#4A148C;"><i class="fa fa-handshake"></i> ' + m.MemberName + '</span>' +
        '<span class="sbadge" style="background:#6A1B9A;color:#fff;"><i class="fa fa-check-circle"></i> Active</span></div>' +
        '<div class="mdg">' +
        '<div class="md" style="border-color:#CE93D8;"><i class="fa fa-hashtag" style="color:#6A1B9A;"></i><span><b>Intro:</b> ' + m.IntroductoryNo + '</span></div>' +
        '<div class="md" style="border-color:#CE93D8;"><i class="fa fa-building" style="color:#6A1B9A;"></i><span><b>Club:</b> ' + m.ClubName + '</span></div></div>';
}

// ===== PRODUCT SEARCH & LOAD =====
function initPS() {
    $('#txSrch').on('input', function () {
        if (prt2) clearTimeout(prt2);
        prt2 = setTimeout(function () { prt2 = null; ldProds(); }, 350);
    });
    $('#btnRld').on('click', function () {
        if (prt2) { clearTimeout(prt2); prt2 = null; }
        $(this).find('i').addClass('fa-spin');
        setTimeout(function () { $('#btnRld i').removeClass('fa-spin'); }, 420);
        ldProds();
    });
    $('.tabs').on('click', '.tab', function () {
        $('.tab').removeClass('act'); $(this).addClass('act'); ldProds();
    });
}

function ldProds() {
    var did = gDid();
    if (!did) {
        $('#grid').html('<div class="noc" style="grid-column:1/-1"><i class="fa fa-building"></i><p>Select a department first</p></div>');
        return;
    }
    var cat = $('.tab.act').data('c') || '', srchv = $('#txSrch').val().trim();
    $('#grid').html('<div class="ld" style="grid-column:1/-1"><i class="fa fa-spinner fa-spin fa-2x"></i><span>Loading...</span></div>');
    $.ajax({
        type: 'POST', url: 'Pos.aspx/GetProducts',
        data: JSON.stringify({ search: srchv, deptID: did, category: cat }),
        contentType: 'application/json;charset=utf-8', dataType: 'json', timeout: 10000,
        success: function (r) {
            if (!r.d || !r.d.success) {
                $('#grid').html('<div class="er" style="grid-column:1/-1"><i class="fa fa-exclamation-triangle fa-2x"></i><span>' + (r.d ? r.d.message : 'Failed') + '</span></div>');
                return;
            }
            rndrProds(r.d.data || []);
        },
        error: function () { $('#grid').html('<div class="er" style="grid-column:1/-1"><i class="fa fa-exclamation-triangle fa-2x"></i><span>Failed to load</span></div>'); }
    });
}

function rndrProds(prods) {
    var $g = $('#grid');
    if (!prods.length) {
        $g.html('<div class="noc" style="grid-column:1/-1"><i class="fa fa-box-open"></i><p>No products found</p></div>');
        return;
    }
    // Adaptive column: if few products, use fixed 3-col max to avoid ugly stretch
    var cnt = prods.length;
    var minW = cnt <= 3 ? '200px' : cnt <= 6 ? '160px' : 'var(--card-min)';
    $g.css('grid-template-columns', 'repeat(auto-fill,minmax(' + minW + ',1fr))');

    var h = '';
    prods.forEach(function (p) {
        var img = p.image || '';
        h += '<div class="card fi" data-id="' + p.id +
            '" data-nm="' + String(p.name).replace(/"/g, '&quot;') +
            '" data-pr="' + p.price +
            '" data-gst="' + (p.gst || 0) +
            '" data-img="' + img + '">' +
            '<div class="cico">' +
            (img ? '<img src="' + img + '" alt="" loading="lazy" onerror="this.style.display=\'none\'">' : '<i class="fa fa-utensils"></i>') +
            '</div>' +
            '<div class="cbody">' +
            '<div class="nm">' + p.name + '</div>' +
            '<div class="gl">GST: ' + (p.gst || 0) + '%</div>' +
            '<div class="px">' + fmt(p.price) + '</div>' +
            '</div></div>';
    });
    $g.html(h);
    $g.off('click.card').on('click.card', '.card', function () {
        var $c = $(this);
        addC({ id: $c.data('id'), name: $c.data('nm'), price: parseFloat($c.data('pr')), gst: parseInt($c.data('gst')) || 0, image: $c.data('img') });
    });
}

// ===== CART =====
function addC(item) {
    var ex = null;
    for (var i = 0; i < cart.length; i++) { if (cart[i].id == item.id) { ex = cart[i]; break; } }
    if (ex) ex.qty++;
    else cart.push({ id: item.id, name: item.name, price: parseFloat(item.price), gst: item.gst || 0, image: item.image, qty: 1 });
    rndrCart(); updCnt(); svCart();
    ntf(item.name + ' added!', 'ok');
}

function rndrCart() {
    var $c = $('#citems'); $c.empty();
    if (!cart.length) {
        $c.html('<div class="noc"><i class="fa fa-shopping-cart"></i><p>Cart is empty</p><p class="sub">Add items from menu</p></div>');
        updTot(); return;
    }
    var h = '';
    cart.forEach(function (item, i) {
        var ls = item.price * item.qty, lg = ls * (item.gst || 0) / 100, lt = ls + lg;
        h += '<div class="ci fi">' +
            '<div class="cthumb">' +
            (item.image ? '<img src="' + item.image + '" alt="" loading="lazy" onerror="this.style.display=\'none\'">' : '<i class="fa fa-utensils"></i>') +
            '</div>' +
            '<div class="inf">' +
            '<div style="font-weight:700;font-size:11px;line-height:1.3;">' + item.name + '</div>' +
            '<div style="font-size:10px;color:var(--gy);">' + fmt(item.price) + ' | GST ' + (item.gst || 0) + '%</div>' +
            '<div style="font-size:11px;"><strong>' + fmt(lt) + '</strong></div></div>' +
            '<div class="qty">' +
            '<button ' + (item.qty <= 1 ? 'disabled' : '') + ' data-i="' + i + '" data-d="-1">−</button>' +
            '<span style="font-weight:800;min-width:16px;text-align:center;font-size:12px;">' + item.qty + '</span>' +
            '<button data-i="' + i + '" data-d="1">+</button>' +
            '</div></div>';
    });
    $c.html(h);
    $c.off('click.qty').on('click.qty', '.qty button', function () {
        cqty(parseInt($(this).data('i')), parseInt($(this).data('d')));
    });
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
    var title = n > 0 ? 'Cart (' + n + ')' : 'Cart';
    $('.ptab[data-c="cart"]').html('<i class="fa fa-shopping-cart"></i> ' + title);
}

function updTot() {
    var sub = 0, gst = 0;
    cart.forEach(function (item) { var ls = item.price * item.qty; sub += ls; gst += ls * (item.gst || 0) / 100; });
    var tot = sub + gst;
    $('#totbox').html(
        '<div style="display:flex;justify-content:space-between;font-size:12px;"><span>Subtotal</span><span style="font-weight:700;">' + fmt(sub) + '</span></div>' +
        '<div style="display:flex;justify-content:space-between;font-size:12px;"><span>GST</span><span style="font-weight:700;">' + fmt(gst) + '</span></div>' +
        '<div style="display:flex;justify-content:space-between;margin-top:4px;font-size:13px;border-top:2px dashed var(--pr-l);padding-top:4px;">' +
        '<span style="font-weight:800;color:var(--pr);">Total</span>' +
        '<span style="font-weight:800;color:var(--pr);">' + fmt(tot) + '</span></div>'
    );
}

function clrCart() {
    if (!cart.length) return;
    if (confirm('Clear all items?')) { cart = []; rndrCart(); updCnt(); svCart(); ntf('Cart cleared', 'info'); }
}
function svCart() { try { localStorage.setItem('pos4', JSON.stringify(cart)); } catch (e) { } }
function ldCart() { try { var s = localStorage.getItem('pos4'); if (s) { cart = JSON.parse(s); rndrCart(); } } catch (e) { } }

// ===== UI =====
function initUI() {
    $('.ptab').on('click', function () {
        var c = $(this).data('c');
        mode = c;
        $('.ptab').removeClass('act'); $(this).addClass('act');
        $('.pc').removeClass('act'); $('#pc' + c.charAt(0).toUpperCase() + c.slice(1)).addClass('act');
        if (c === 'active') ldActive();
        else if (c === 'delivered') ldDelivered();
        else if (c === 'history') ldHistory();
    });
    $('#btnActive').on('click', function () { $('.ptab[data-c="active"]').trigger('click'); });
    $('#btnSubmit').on('click', subOrder);
    $('#btnClear').on('click', clrCart);
    $('#btnXrec').on('click', function () { $('#recmod').removeClass('open'); });
    $(document).on('click', function (e) { if ($(e.target).is('#recmod')) $('#recmod').removeClass('open'); });
    $('#txCov').on('input', function () { var v = parseInt($(this).val()); if (isNaN(v) || v < 1) $(this).val(1); if (v > 99) $(this).val(99); });
    $('#txCov').on('keydown', function (e) { e.stopPropagation(); });
}

// ===== PLACE ORDER =====
function subOrder() {
    if (isSubmitting) { ntf('Please wait...', 'warn'); return; }
    var did = gDid(), dnm = gDnm();
    if (!did) { ntf('Select a Department first!', 'err'); return; }
    if (!cart.length) { ntf('Cart is empty!', 'err'); return; }
    var cov = parseInt($('#txCov').val()) || 1;
    var tbl = $('#txTbl').val().trim();
    var ngcount = parseInt($('#txNG').val()) || 1;

    if (bt === 'Club Member' && !mem) { ntf('Search and select a Member first!', 'err'); $('#txM').focus(); return; }
    if (bt === 'Guest House' && !ghi) { ntf('Search and confirm a Room first!', 'err'); $('#txGH').focus(); return; }
    if (bt === 'Affiliated Member' && !afm) { ntf('Select an Affiliated Member!', 'err'); $('#txAF').focus(); return; }

    var sub = 0, gstT = 0;
    cart.forEach(function (item) { var ls = item.price * item.qty; sub += ls; gstT += ls * (item.gst || 0) / 100; });
    var grand = sub + gstT;

    var lbl = 'Non Member';
    if (bt === 'Club Member') lbl = mem ? (mem.DisplayName || mem.Name) : 'Member';
    else if (bt === 'Guest House') lbl = ghi ? ('Room ' + ghi.RoomNo + ' — ' + ghi.GuestName) : 'Guest';
    else if (bt === 'Affiliated Member') lbl = afm ? afm.MemberName : 'Affiliated';
    else if (bt === 'Non Member') lbl = 'Non Member (' + ngcount + ' guests)';

    if (!confirm('Place order?\nTable: ' + (tbl || 'None') + '\nCovers: ' + cov + '\nTotal: ' + fmt(grand) + '\nFor: ' + lbl)) return;

    var ip = cart.map(function (item) { return { MenuItemId: parseInt(item.id, 10), Name: item.name, Price: parseFloat(item.price), GST: item.gst || 0, Quantity: parseInt(item.qty, 10), Notes: '' }; });
    var mno = '0', ain = '', acn = '', amn = '', resn = '', gn = '', rmn = '';
    if (bt === 'Club Member') mno = mem ? (mem.CardNo || '') : '';
    else if (bt === 'Guest House') { mno = ghi ? ('ROOM-' + ghi.RoomNo) : 'GUEST'; rmn = ghi ? ghi.RoomNo : ''; resn = ghi ? ghi.ReservationNo : ''; gn = ghi ? ghi.GuestName : ''; }
    else if (bt === 'Affiliated Member') { mno = afm ? afm.MemberNo : ''; ain = afm ? afm.IntroductoryNo : ''; acn = afm ? afm.ClubName : ''; amn = afm ? afm.MemberNo : ''; }
    else if (bt === 'Non Member') mno = 'NM-' + ngcount;

    // Pass deptAbb so server uses correct abbreviation for KOT
    var pl = {
        memberNo: mno, totalAmount: grand, itemsJson: JSON.stringify(ip),
        tableNumber: tbl, departmentId: did, departmentName: dnm,
        employeeID: eid, waiterName: enm || eid, memberType: bt,
        roomNo: rmn, covers: cov,
        affiliatedIntroNo: ain, affiliatedClubName: acn, affiliatedMemberNo: amn,
        reservationNo: resn, guestName: gn,
        subDeptAbb: deptAbb   // <-- new field for dynamic KOT prefix
    };

    var $b = $('#btnSubmit');
    $b.prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Placing...');
    isSubmitting = true;

    $.ajax({
        type: 'POST', url: 'Pos.aspx/SubmitOrder',
        data: JSON.stringify(pl),
        contentType: 'application/json;charset=utf-8', dataType: 'json', timeout: 26000,
        success: function (r) {
            r = r.d;
            if (r && r.success) {
                ntf('Order #' + r.orderId + ' — KOT: ' + r.kotNumber, 'ok');
                gnRec(r.orderId, tbl, r.subtotal, r.taxAmount, r.totalAmount, dnm, rmn, null, bt, cov, r.kotNumber, lbl, resn, gn, mno);
                cart = []; rndrCart(); updCnt(); svCart();
                $('#txTbl').val(''); $('#txCov').val(1);
                resetM();
            } else {
                ntf('Error: ' + (r ? r.message : 'Unknown'), 'err');
            }
        },
        error: function (xhr, status, error) { ntf('Server error: ' + error, 'err'); },
        complete: function () { $b.prop('disabled', false).html('<i class="fa fa-check-circle"></i> Place Order'); setTimeout(function () { isSubmitting = false; }, 1000); }
    });
}

// ===== ACTIVE ORDERS =====
    function ldActive() {
        $('#alst').html('<div class="ld"><i class="fa fa-spinner fa-spin fa-2x"></i></div>');
        var did = gDid();
        if (!did) {
            $('#alst').html('<div class="noc"><i class="fa fa-building"></i><p>Select a department first</p></div>');
            return;
        }
        $.ajax({
            type: 'POST', url: 'Pos.aspx/GetActiveOrders',
            data: JSON.stringify({ departmentId: did }),
            contentType: 'application/json;charset=utf-8', dataType: 'json',
            success: function (r) {
                var o = r.d || [];
                if (!o.length) { $('#alst').html('<div class="noc"><i class="fa fa-bolt"></i><p>No active orders</p></div>'); return; }
                o.sort(function (a, b) { return new Date(b.createdAt) - new Date(a.createdAt); });
                var h = '';
                o.forEach(function (x) {
                    var sc = (x.status || '').toLowerCase().replace(/ /g, '-');
                    var kb = x.kotNumber ? '<span class="kotb"><i class="fa fa-ticket-alt"></i> ' + x.kotNumber + '</span>' : '';
                    h += '<div class="oi fi">' +
                        '<div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:4px;">' +
                        '<div style="display:flex;align-items:center;gap:5px;font-weight:700;font-size:12px;flex-wrap:wrap;">' +
                        '<span>Order #' + x.id + '</span><span class="sbadge ' + sc + '">' + x.status + '</span>' + kb + '</div>' +
                        '<div style="font-size:10px;color:var(--gy);">' + x.date + '</div></div>' +
                        '<div style="margin:4px 0;display:flex;flex-wrap:wrap;gap:6px;font-size:10px;">' +
                        '<span><i class="fa fa-table"></i> ' + (x.tableNumber || '—') + '</span>' +
                        '<span><i class="fa fa-users"></i> ' + (x.cover || 1) + '</span>' +
                        (x.roomNo ? '<span><i class="fa fa-bed"></i> ' + x.roomNo + '</span>' : '') +
                        '<span><i class="fa fa-user"></i> ' + (x.memberNo || 'Guest') + '</span></div>' +
                        '<div class="abtns">' +
                        '<button class="obtn ob-d" onclick="vwDet(\'' + x.id + '\')"><i class="fa fa-info-circle"></i> Details</button>' +
                        '<button class="obtn ob-ok" onclick="mkDel(\'' + x.id + '\')"><i class="fa fa-check-circle"></i> Delivered</button>' +
                        '<button class="obtn ob-cx" onclick="openCx(\'' + x.id + '\',\'' + (x.kotNumber || '') + '\',\'' + escJs(x.memberNo || '') + '\',\'' + escJs(x.tableNumber || '') + '\',\'' + escJs(x.status || '') + '\',\'' + escJs(x.date || '') + '\',\'' + escJs(x.total || '') + '\')"><i class="fa fa-ban"></i> Cancel KOT</button>' +
                        '</div></div>';
                });
                $('#alst').html(h);
            },
            error: function () { $('#alst').html('<div class="er"><i class="fa fa-exclamation-triangle fa-2x"></i><span>Failed</span></div>'); }
        });
    }

// ===== DELIVERED ORDERS =====
    function ldDelivered() {
        $('#dlst').html('<div class="ld"><i class="fa fa-spinner fa-spin fa-2x"></i></div>');
        var did = gDid();
        if (!did) {
            $('#dlst').html('<div class="noc"><i class="fa fa-building"></i><p>Select a department first</p></div>');
            return;
        }
        $.ajax({
            type: 'POST', url: 'Pos.aspx/GetDeliveredOrders',
            data: JSON.stringify({ departmentId: did }),
            contentType: 'application/json;charset=utf-8', dataType: 'json',
            success: function (r) {
                var o = r.d || [];
                if (!o.length) { $('#dlst').html('<div class="noc"><i class="fa fa-check-double"></i><p>No delivered</p></div>'); return; }
                var h = '';
                o.forEach(function (x) {
                    var kb = x.kotNumber ? '<span class="kotb"><i class="fa fa-ticket-alt"></i> ' + x.kotNumber + '</span>' : '';
                    h += '<div class="oi fi">' +
                        '<div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:4px;">' +
                        '<div style="display:flex;align-items:center;gap:5px;font-weight:700;font-size:12px;flex-wrap:wrap;">' +
                        '<span>Order #' + x.id + '</span><span class="sbadge delivered">Delivered</span>' + kb + '</div>' +
                        '<div style="font-size:10px;color:var(--gy);">' + x.date + '</div></div>' +
                        '<div style="margin:4px 0;display:flex;flex-wrap:wrap;gap:6px;font-size:10px;">' +
                        '<span><i class="fa fa-table"></i> ' + (x.tableNumber || '—') + '</span>' +
                        '<span><i class="fa fa-user"></i> ' + (x.memberNo || 'Guest') + '</span>' +
                        (x.roomNo ? '<span><i class="fa fa-bed"></i> ' + x.roomNo + '</span>' : '') +
                        '</div>' +
                        '<div class="abtns">' +
                        '<button class="obtn ob-d" onclick="vwDet(\'' + x.id + '\')"><i class="fa fa-info-circle"></i> Details</button>' +
                        '</div></div>';
                });
                $('#dlst').html(h);
            },
            error: function () { $('#dlst').html('<div class="er"><i class="fa fa-exclamation-triangle fa-2x"></i><span>Failed</span></div>'); }
        });
    }

// ===== ORDER HISTORY =====
function ldHistory() {
    $('#hlst').html('<div class="ld"><i class="fa fa-spinner fa-spin fa-2x"></i></div>');
    $.ajax({
        type: 'POST', url: 'Pos.aspx/GetOrderHistory',
        contentType: 'application/json;charset=utf-8', dataType: 'json',
        success: function (r) {
            var o = r.d || [];
            if (!o.length) { $('#hlst').html('<div class="noc"><i class="fa fa-history"></i><p>No history</p></div>'); return; }
            var h = '';
            o.forEach(function (x) {
                var kb = x.kotNumber ? '<span class="kotb"><i class="fa fa-ticket-alt"></i> ' + x.kotNumber + '</span>' : '';
                h += '<div class="oi fi">' +
                    '<div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:4px;">' +
                    '<div style="display:flex;align-items:center;gap:5px;font-weight:700;font-size:12px;flex-wrap:wrap;">' +
                    '<span>Order #' + x.id + '</span><span class="sbadge paid">Paid</span>' + kb + '</div>' +
                    '<div style="font-size:10px;color:var(--gy);">' + x.date + '</div></div>' +
                    '<div style="margin:4px 0;font-size:10px;"><i class="fa fa-user"></i> ' + (x.memberNo || 'Guest') + '</div>' +
                    '<div class="abtns"><button class="obtn ob-d" onclick="vwDet(\'' + x.id + '\')"><i class="fa fa-info-circle"></i> Details</button></div>' +
                    '</div>';
            });
            $('#hlst').html(h);
        },
        error: function () { $('#hlst').html('<div class="er"><i class="fa fa-exclamation-triangle fa-2x"></i><span>Failed</span></div>'); }
    });
}

// ===== MARK DELIVERED =====
function mkDel(oid) {
    if (!confirm('Mark Order #' + oid + ' as Delivered?')) return;
    $.ajax({
        type: 'POST', url: 'Pos.aspx/MarkOrderAsDelivered',
        data: JSON.stringify({ orderId: oid, employeeID: eid }),
        contentType: 'application/json;charset=utf-8', dataType: 'json',
        success: function (r) { r = r.d; if (r && r.success) { ntf('Order #' + oid + ' Delivered!', 'ok'); ldActive(); } else ntf(r ? r.message : 'Failed', 'err'); },
        error: function () { ntf('Server error', 'err'); }
    });
}

// ===== VIEW DETAILS =====
function vwDet(oid) {
    $.ajax({
        type: 'POST', url: 'Pos.aspx/GetOrderDetails',
        data: JSON.stringify({ orderId: oid }),
        contentType: 'application/json;charset=utf-8', dataType: 'json',
        success: function (r) { r = r.d; if (r && r.success) shwRec2(r); else ntf(r ? r.message : 'Failed', 'err'); },
        error: function () { ntf('Error loading details', 'err'); }
    });
}

function shwRec2(o) {
    var ih = '';
    o.items.forEach(function (i) {
        ih += '<tr><td>' + i.ItemName + (i.Notes ? '<br><span style="font-size:9px;color:#666;">' + i.Notes + '</span>' : '') + '</td>' +
            '<td style="text-align:center;">' + i.Quantity + '</td>' +
            '<td>' + fmtR(i.Price) + '</td><td>' + fmtR(i.LineTotal) + '</td></tr>';
    });
    var gx = '';
    if (o.billTo === 'Guest House' && o.reservationNo) {
        gx = '<div class="ir"><span class="il">Res #</span><span class="iv">' + o.reservationNo + '</span></div>' +
            '<div class="ir"><span class="il">Guest</span><span class="iv">' + o.guestName + '</span></div>' +
            '<div class="ir"><span class="il">Room</span><span class="iv">' + o.roomNo + '</span></div>';
    } else if (o.roomNo) {
        gx = '<div class="ir"><span class="il">Room</span><span class="iv">' + o.roomNo + '</span></div>';
    }
    var sub = parseFloat((o.subtotal || '').replace('Rs. ', '').replace(/,/g, '')) || 0;
    var tax = parseFloat((o.taxApplied || '').replace('Rs. ', '').replace(/,/g, '')) || 0;
    var grand = parseFloat((o.finalAmount || o.total || '').replace('Rs. ', '').replace(/,/g, '')) || 0;
    $('#recbody').html(buildRecHTML({ kot: o.kotNumber, dept: o.departmentName, orderId: o.id, date: o.date, memberNo: o.memberNo, memberName: null, billTo: o.billTo, waiter: o.waiterName, table: o.tableNumber, cover: o.cover, guestExtra: gx, itemsHtml: ih, sub: sub, tax: tax, grand: grand }));
    $('#recmod').addClass('open');
}

function gnRec(oid, tbl, sub, tax, grand, dnm, rmn, its, btp, cov, kot, lbl, resn, gn, mno) {
    var now = new Date(), items = its || cart, ih = '';
    items.forEach(function (i) {
        var pr = parseFloat(i.price || i.Price) || 0, qty = parseInt(i.qty || i.Quantity) || 1;
        var gstR = parseInt(i.gst || i.GST) || 0;
        var lineSub = pr * qty, lineGst = lineSub * gstR / 100, lineTotal = lineSub + lineGst;
        ih += '<tr><td>' + (i.name || i.Name) + '</td><td style="text-align:center;">' + qty + '</td><td>' + fmtR(pr) + '</td><td>' + fmtR(lineTotal) + '</td></tr>';
    });
    var gx = '';
    if (btp === 'Guest House') {
        if (resn) gx += '<div class="ir"><span class="il">Res #</span><span class="iv">' + resn + '</span></div>';
        if (rmn) gx += '<div class="ir"><span class="il">Room</span><span class="iv">' + rmn + '</span></div>';
        if (gn) gx += '<div class="ir"><span class="il">Guest</span><span class="iv">' + gn + '</span></div>';
    }
    var dateStr = now.toLocaleDateString('en-PK', { day: '2-digit', month: 'short', year: 'numeric' });
    var timeStr = now.toLocaleTimeString('en-PK', { hour: '2-digit', minute: '2-digit' });
    var memNoDisplay = (btp === 'Club Member' || btp === 'Affiliated Member') && mno ? mno : '';
    $('#recbody').html(buildRecHTML({ kot: kot, dept: dnm, orderId: oid, date: dateStr + ' ' + timeStr, memberNo: memNoDisplay, memberName: lbl, billTo: btp, waiter: enm || eid, table: tbl, cover: cov, guestExtra: gx, itemsHtml: ih, sub: sub, tax: tax, grand: grand }));
    $('#recmod').addClass('open');
}

function buildRecHTML(d) {
    return '<div class="rw prt-area">' +
        '<div class="rh"><div class="r-logo">LAHORE GYMKHANA</div><div class="r-sub">Food &amp; Beverage</div>' +
        '<div class="r-dept">' + (d.dept || 'Restaurant') + '</div>' +
        (d.kot ? '<div class="kb">KOT: ' + d.kot + '</div>' : '') + '</div>' +
        '<div class="is">' +
        '<div class="ir"><span class="il">Order #</span><span class="iv">' + d.orderId + '</span></div>' +
        '<div class="ir"><span class="il">Date</span><span class="iv">' + d.date + '</span></div>' +
        '<div class="ir"><span class="il">Waiter</span><span class="iv">' + (d.waiter || '—') + '</span></div>' +
        '<div class="ir"><span class="il">Bill Type</span><span class="iv">' + (d.billTo || '—') + '</span></div>' +
        (d.memberNo ? '<div class="ir"><span class="il">Member No</span><span class="iv">' + d.memberNo + '</span></div>' : '') +
        '<div class="ir"><span class="il">' + (d.billTo === 'Guest House' ? 'Guest' : (d.billTo === 'Non Member' ? 'Guest' : 'Member')) + '</span><span class="iv">' + (d.memberName || d.memberNo || 'Guest') + '</span></div>' +
        (d.guestExtra || '') +
        '<div class="ir"><span class="il">Table</span><span class="iv">' + (d.table || '—') + '</span></div>' +
        '<div class="ir"><span class="il">Covers</span><span class="iv" style="font-weight:900;">' + (d.cover || 1) + '</span></div>' +
        '</div>' +
        '<table class="rt"><thead><tr><th>Item</th><th style="text-align:center;">Qty</th><th>Rate</th><th>Amt</th></tr></thead><tbody>' + d.itemsHtml + '</tbody></table>' +
        '<div class="r-totals">' +
        '<div class="r-tot-row"><span>Subtotal</span><span>' + fmtR(d.sub) + '</span></div>' +
        '<div class="r-tot-row"><span>GST</span><span>' + fmtR(d.tax) + '</span></div>' +
        '<div class="r-tot-row grand"><span>TOTAL</span><span>' + fmtR(d.grand) + '</span></div></div>' +
        '<div class="ft"><p class="thank">THANK YOU!</p><p>We hope you enjoyed your visit.</p><p>Lahore Gymkhana — F&amp;B Services</p></div></div>';
}

function fmtR(v) { return parseFloat(v || 0).toLocaleString('en-PK', { minimumFractionDigits: 2, maximumFractionDigits: 2 }); }

// ===== PRINT =====
function prt() {
    var content = document.getElementById('recbody').innerHTML;
    var pw = window.open('', '_blank', 'width=400,height=600');
    pw.document.write('<!DOCTYPE html><html><head><title>KOT Print</title><style>body{margin:0;padding:8px;font-family:"Courier New",Courier,monospace;background:#fff;color:#000;}.rw{max-width:320px;margin:0 auto;}.rh{text-align:center;padding-bottom:10px;margin-bottom:8px;border-bottom:2px dashed #333;}.r-logo{font-size:17px;font-weight:900;letter-spacing:1px;}.r-sub{font-size:11px;color:#444;margin:2px 0;}.r-dept{font-size:12px;font-weight:700;margin:3px 0;}.kb{display:inline-block;background:#111;color:#fff;padding:3px 12px;border-radius:3px;font-size:12px;font-weight:800;letter-spacing:2px;margin:5px 0 0;}.is{padding:8px 0;margin-bottom:6px;border-bottom:1px dashed #999;}.ir{display:flex;justify-content:space-between;padding:2px 0;font-size:11px;}.il{font-weight:700;min-width:70px;}.iv{text-align:right;}.rt{width:100%;border-collapse:collapse;margin:6px 0;}.rt thead tr{border-top:2px dashed #333;border-bottom:2px dashed #333;}.rt th{padding:5px 3px;font-size:11px;font-weight:800;text-align:left;}.rt th:last-child{text-align:right;}.rt td{padding:4px 3px;font-size:11px;border-bottom:1px dashed #ccc;vertical-align:top;}.rt td:nth-child(2){text-align:center;font-weight:700;}.rt td:last-child{text-align:right;font-weight:700;}.r-totals{border-top:2px dashed #333;padding-top:8px;margin-top:2px;}.r-tot-row{display:flex;justify-content:space-between;font-size:11px;padding:2px 0;}.r-tot-row.grand{font-size:13px;font-weight:900;border-top:1px solid #333;margin-top:4px;padding-top:5px;}.ft{text-align:center;padding-top:10px;margin-top:6px;border-top:2px dashed #333;font-size:10px;}.thank{font-size:12px;font-weight:800;letter-spacing:1px;}@media print{body{margin:0;padding:0;}}</style></head><body>' + content + '</body></html>');
    pw.document.close(); pw.focus();
    setTimeout(function () { pw.print(); pw.close(); }, 300);
}

// ===== CANCEL KOT =====
var cxData = {};

function escJs(s) { return String(s || '').replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/"/g, '\\"'); }

function openCx(oid, kot, memberNo, tableNo, status, date, total) {
    cxoid = oid; cxkot = kot || '';
    cxData = { oid: oid, kot: kot, memberNo: memberNo, tableNo: tableNo, status: status, date: date, total: total };
    var details = '<div style="display:grid;grid-template-columns:1fr 1fr;gap:5px;">' +
        mkCxBox('Order #', oid, true) + mkCxBox('KOT No', kot || '—', true) +
        mkCxBox('Member/Guest', memberNo || 'Guest', false) + mkCxBox('Table', tableNo || '—', false) +
        '<div style="background:#fff;border-radius:7px;padding:7px 9px;border:1.5px solid #CE93D8;">' +
        '<div style="font-size:9px;color:#7B1FA2;font-weight:700;text-transform:uppercase;margin-bottom:2px;">Status</div>' +
        '<span class="sbadge ' + (status || '').toLowerCase().replace(/ /g, '-') + '">' + (status || '—') + '</span></div>' +
        mkCxBox('Amount', total || '—', false) +
        '</div>' +
        (date ? '<div style="font-size:10px;color:#9C27B0;margin-top:5px;"><i class="fa fa-clock"></i> ' + date + '</div>' : '');
    $('#cxdetails').html(details);
    $('#cxrmk').val('');
    $('#cxmod').addClass('open');
    setTimeout(function () { $('#cxrmk').focus(); }, 70);
}

function mkCxBox(lbl, val, big) {
    return '<div style="background:#fff;border-radius:7px;padding:7px 9px;border:1.5px solid #CE93D8;">' +
        '<div style="font-size:9px;color:#7B1FA2;font-weight:700;text-transform:uppercase;margin-bottom:2px;">' + lbl + '</div>' +
        '<div style="font-size:' + (big ? '13' : '11') + 'px;font-weight:' + (big ? '800' : '700') + ';color:#4A148C;">' + val + '</div></div>';
}

function initCx() {
    $('#btnCxX,#btnCxBk').on('click', function () { $('#cxmod').removeClass('open'); cxoid = null; cxkot = ''; $('#cxrmk').val(''); });
    $(document).on('click', function (e) { if ($(e.target).is('#cxmod')) { $('#cxmod').removeClass('open'); cxoid = null; } });
    $('#btnCxOk').on('click', function () {
        var rm = $('#cxrmk').val().trim();
        if (!rm) { ntf('Enter cancellation reason!', 'err'); return; }
        if (!cxoid) return;
        var $b = $(this);
        $b.prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Submitting...');
        $.ajax({
            type: 'POST', url: 'Pos.aspx/CancelOrder',
            data: JSON.stringify({ orderId: cxoid, employeeID: eid, remarks: rm }),
            contentType: 'application/json;charset=utf-8', dataType: 'json',
            success: function (r) {
                r = r.d;
                if (r && r.success) {
                    ntf('Cancel KOT request submitted for Order #' + cxoid, 'ok');
                    $('#cxmod').removeClass('open');
                    cxoid = null; cxkot = ''; $('#cxrmk').val('');
                    if (mode === 'active') ldActive();
                    else if (mode === 'delivered') ldDelivered();
                } else ntf('Error: ' + (r ? r.message : 'Unknown'), 'err');
            },
            error: function () { ntf('Server error', 'err'); },
            complete: function () { $b.prop('disabled', false).html('<i class="fa fa-ban"></i> Submit Cancel Request'); }
        });
    });
}

// ===== KEYBOARD =====
function initKeys() {
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            if ($('#cxmod').hasClass('open')) { $('#cxmod').removeClass('open'); return; }
            if ($('#recmod').hasClass('open')) { $('#recmod').removeClass('open'); return; }
        }
        if (e.key === 'F1') { e.preventDefault(); if (bt === 'Club Member') $('#txM').focus(); }
        if (e.key === 'F2') { e.preventDefault(); $('#txSrch').focus(); }
    }, false);
    $('#form1').on('submit', function (e) { e.preventDefault(); return false; });
}

// ===== TOAST =====
function ntf(msg, t) {
    t = t || 'ok';
    var bg = t === 'err' ? 'var(--err)' : t === 'warn' ? 'var(--warn)' : t === 'info' ? 'var(--inf)' : 'var(--ok)';
    var ic = t === 'err' ? 'fa-exclamation-circle' : t === 'warn' ? 'fa-exclamation-triangle' : t === 'info' ? 'fa-info-circle' : 'fa-check-circle';
    var ex = $('.pntf').length, top = 62 + ex * 46;
    var $n = $('<div class="pntf" style="position:fixed;top:' + top + 'px;right:12px;background:' + bg + ';color:#fff;padding:7px 12px;border-radius:8px;box-shadow:0 4px 14px rgba(0,0,0,.18);z-index:9999;display:flex;align-items:center;gap:6px;animation:sir .16s ease;max-width:85vw;font-size:11px;font-family:\'Poppins\',sans-serif;"><i class="fa ' + ic + '"></i><span style="font-weight:600;">' + msg + '</span></div>');
    $('body').append($n);
    setTimeout(function () { $n.fadeOut(200, function () { $(this).remove(); }); }, 2400);
}

function fmt(v) { return 'Rs. ' + parseFloat(v || 0).toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 }); }

var styleEl = document.createElement('style');
styleEl.innerHTML = '@keyframes siu{from{transform:translateY(10px);opacity:0}to{transform:translateY(0);opacity:1}}@keyframes fi{from{opacity:0}to{opacity:1}}@keyframes pdot{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.5;transform:scale(.7)}}@keyframes sir{from{transform:translateX(100%);opacity:0}to{transform:translateX(0);opacity:1}}.fi{animation:fi .2s ease;}';
document.head.appendChild(styleEl);
</script>
</form>
</body>
</html>
