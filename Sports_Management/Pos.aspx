<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Pos.aspx.cs" Inherits="Pos" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
<title>Sports POS System</title>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>

<style>
 /* --- SPORTS-THEME COLOR SCHEME --- */
:root {
    --primary: #1e90ff;       /* Dodger Blue - Sports primary */
    --primary-dark: #0066cc;
    --secondary: #00cc66;     /* Bright Green - Sports energy */
    --success: #2ecc71;       /* Success green */
    --danger: #e74c3c;        /* Red - Warning */
    --warning: #f39c12;       /* Yellow - Warning */
    --light: #f8f9fa;         /* Light background */
    --dark: #2c3e50;          /* Dark blue-gray */
    --gray: #7f8c8d;
    --light-gray: #ecf0f1;
    --card-bg: #ffffff;
    --border-radius: 16px;
    --shadow: 0 4px 12px rgba(30, 144, 255, 0.1);
    --shadow-hover: 0 10px 25px rgba(30, 144, 255, 0.2);
    --gradient-primary: linear-gradient(135deg, #1e90ff, #00cc66);
    --gradient-success: linear-gradient(135deg, #27ae60, #2ecc71);
    --nav-bg: linear-gradient(135deg, #1a237e 0%, #283593 100%);
    --nav-text: #ffffff;
    --physical-badge: #3498db;
    --services-badge: #2ecc71;
}

body { 
    font-family: 'Poppins', 'Segoe UI', system-ui, sans-serif; 
    margin:0; 
    background: linear-gradient(135deg, #f8f9fa 0%, #e3f2fd 100%);
    color:#2c3e50; 
    overflow-x: hidden;
    scroll-behavior: smooth;
}

/* ==================== UPDATED SPORTS NAVBAR ==================== */
.sports-navbar {
    background: var(--nav-bg);
    padding: 20px 24px;
    border-bottom: 4px solid var(--secondary);
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
    margin-bottom: 24px;
    position: sticky;
    top: 0;
    z-index: 999;
}

.sports-navbar .navbar-container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 24px;
}

.navbar-brand {
    display: flex;
    align-items: center;
    gap: 16px;
}

.navbar-brand h1 {
    color: var(--nav-text);
    margin: 0;
    font-size: 26px;
    font-weight: 800;
    letter-spacing: 0.5px;
    background: linear-gradient(90deg, #ffffff, #bbdefb);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
}

.navbar-brand .sports-icon {
    font-size: 32px;
    background: var(--gradient-primary);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
}

.sales-info {
    display: flex;
    gap: 24px;
    background: rgba(255, 255, 255, 0.1);
    padding: 12px 24px;
    border-radius: 12px;
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.2);
}

.info-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
}

.info-label {
    color: #bbdefb;
    font-size: 12px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.info-value {
    color: white;
    font-size: 18px;
    font-weight: 800;
    display: flex;
    align-items: center;
    gap: 6px;
}

.info-value i {
    color: var(--secondary);
}

.filter-container {
    width: 100%;
    display: flex;
    gap: 16px;
    align-items: center;
    padding-top: 16px;
    border-top: 1px solid rgba(255, 255, 255, 0.1);
    flex-wrap: wrap;
}

.filter-group {
    display: flex;
    flex-direction: column;
    gap: 8px;
    flex: 1;
    min-width: 200px;
}

.filter-group label {
    color: #bbdefb;
    font-weight: 600;
    font-size: 14px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.filter-select {
    padding: 14px 20px;
    border-radius: 12px;
    border: 2px solid rgba(255, 255, 255, 0.2);
    background: rgba(255, 255, 255, 0.1);
    color: white;
    font-weight: 600;
    font-size: 16px;
    outline: none;
    transition: all 0.3s ease;
    cursor: pointer;
    appearance: none;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='white' viewBox='0 0 16 16'%3E%3Cpath d='M7.247 11.14 2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z'/%3E%3C/svg%3E");
    background-repeat: no-repeat;
    background-position: right 16px center;
    padding-right: 50px;
}

.filter-select:hover {
    background: rgba(255, 255, 255, 0.15);
    border-color: var(--secondary);
}

.filter-select:focus {
    background: rgba(255, 255, 255, 0.2);
    border-color: var(--secondary);
    box-shadow: 0 0 0 4px rgba(0, 204, 102, 0.15);
}

.filter-select option {
    background: #1a237e;
    color: white;
    padding: 12px;
}

/* ==================== CUSTOM SCROLLBAR ==================== */
::-webkit-scrollbar { 
    width: 14px; 
    height: 14px;
}
::-webkit-scrollbar-track { 
    background: linear-gradient(180deg, #e3f2fd 0%, #f8f9fa 100%);
    border-radius: 10px;
    border: 3px solid transparent;
    background-clip: padding-box;
    margin: 4px;
}
::-webkit-scrollbar-thumb { 
    background: linear-gradient(180deg, #1e90ff, #00cc66);
    border-radius: 10px;
    border: 4px solid transparent;
    background-clip: padding-box;
    box-shadow: inset 0 0 6px rgba(0, 0, 0, 0.1);
    transition: all 0.3s ease;
}
::-webkit-scrollbar-thumb:hover { 
    background: linear-gradient(180deg, #0066cc, #00b359);
    box-shadow: inset 0 0 6px rgba(0, 0, 0, 0.2);
}
::-webkit-scrollbar-thumb:active { 
    background: linear-gradient(180deg, #0052a3, #00994d);
}
::-webkit-scrollbar-corner { 
    background: #f8f9fa;
    border-radius: 12px;
}

/* Firefox scrollbar */
* {
    scrollbar-width: thin;
    scrollbar-color: #1e90ff #e3f2fd;
}

/* Main Container */
.pos-container { 
    display:flex; 
    flex-direction:row; 
    min-height:100vh; 
    gap:24px; 
    padding:24px; 
    overflow:hidden; 
    box-sizing:border-box;
}

/* Left Panel - FIXED PADDING */
.left-panel { 
    flex:1 1 600px; 
    display:flex; 
    flex-direction:column; 
    background:#ffffff; 
    border-radius:20px; 
    box-shadow:var(--shadow); 
    padding:28px !important; 
    overflow:visible; 
    min-width:300px;
    border:1px solid rgba(30, 144, 255, 0.1);
    position: relative;
    box-sizing: border-box;
}

/* Header */
.pos-header { 
    font-size:32px; 
    font-weight:800; 
    color:var(--dark); 
    margin-bottom:28px; 
    display:flex; 
    align-items:center; 
    gap:16px;
    padding-bottom:20px;
    border-bottom:3px solid rgba(30, 144, 255, 0.2);
    background: linear-gradient(90deg, var(--primary), var(--primary-dark));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
}
.pos-header i { 
    background: var(--gradient-primary);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    font-size:36px;
}

.headermaincart {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12px;
    flex-wrap: wrap;
    gap: 20px;
}

/* Tabs - Sports Category Style */
.tabs { 
    display:flex; 
    gap:8px; 
    margin-bottom:28px; 
    flex-wrap:wrap;
    background:#e8f4fd;
    padding:8px;
    border-radius:14px;
    border:2px solid rgba(30, 144, 255, 0.1);
}
.tab { 
    padding:14px 28px; 
    border-radius:12px; 
    cursor:pointer; 
    font-weight:600; 
    text-align:center; 
    transition:all 0.3s ease; 
    user-select:none; 
    background:transparent; 
    color:var(--gray);
    flex:1 1 auto;
    min-width:100px;
    border:2px solid transparent;
    font-size:15px;
    -webkit-tap-highlight-color: transparent;
}
.tab.active { 
    background: var(--gradient-primary); 
    color:#fff;
    box-shadow:var(--shadow);
    transform:translateY(-2px);
}
.tab:hover:not(.active) {
    background:rgba(30, 144, 255, 0.1);
    color:var(--primary);
    border-color:var(--primary);
}

/* Search Row */
.search-row { 
    display: flex; 
    gap: 16px; 
    margin-bottom: 24px; 
    flex-wrap: wrap; 
    align-items: center;
}
#txtMember, #txtSearch { 
    flex: 1 1 200px; 
    padding: 16px 24px; 
    border-radius: 14px; 
    border: 2px solid var(--light-gray); 
    outline: none; 
    transition: all 0.3s; 
    font-size:16px;
    background:#fff;
    font-weight:500;
    box-shadow:0 2px 8px rgba(0,0,0,0.05);
}
#txtMember:focus, #txtSearch:focus { 
    border-color:var(--primary); 
    box-shadow:0 0 0 4px rgba(30, 144, 255, 0.15); 
    background:#fff;
    outline: none;
}
#txtMember::placeholder, #txtSearch::placeholder {
    color:#a0aec0;
}
#btnReload { 
    flex: 0 0 auto; 
    padding: 0 20px; 
    border:none; 
    background: var(--gradient-primary); 
    color:#fff; 
    border-radius:14px; 
    cursor:pointer; 
    transition:0.3s; 
    font-size:20px;
    width:60px;
    height:60px;
    display:flex;
    align-items:center;
    justify-content:center;
    box-shadow:0 4px 12px rgba(30, 144, 255, 0.3);
}
#btnReload:hover { 
    transform:translateY(-3px) rotate(180deg);
    box-shadow:0 6px 20px rgba(30, 144, 255, 0.4);
}

/* Member Box */
#memberBox { 
    display:none; 
    background: linear-gradient(135deg, #e8f4fd, #d4eaff);
    padding:24px; 
    border-radius:var(--border-radius); 
    margin-bottom:24px; 
    font-size:16px; 
    justify-content:space-between; 
    gap:24px; 
    flex-wrap:wrap; 
    box-shadow:var(--shadow);
    border:2px solid rgba(30, 144, 255, 0.2);
    animation: slideIn 0.5s ease;
}
@keyframes slideIn {
    from { opacity: 0; transform: translateY(-20px); }
    to { opacity: 1; transform: translateY(0); }
}
#memberBox div { 
    flex:1; 
    min-width:140px;
}
#memberBox div b { 
    color:var(--dark); 
    display:block; 
    margin-bottom:6px; 
    font-size:14px;
    text-transform:uppercase;
    letter-spacing:0.5px;
}
#memberBox div span { 
    color:var(--primary); 
    font-weight:800; 
    font-size:20px;
    display:block;
    padding:8px 0;
}

/* Grid Items with Beautiful Scrollbar */
.grid { 
    display:grid; 
    grid-template-columns:repeat(auto-fill, minmax(180px, 1fr)); 
    gap:24px; 
    flex:1; 
    overflow-y:auto; 
    overflow-x: hidden;
    padding: 12px 8px 12px 12px;
    /* FIXED: Better height calculation */
    height: calc(100vh - 420px);
    min-height: 400px;
    max-height: calc(100vh - 320px);
    margin-right: -4px;
    scrollbar-width: thin;
    scrollbar-color: #1e90ff #f8f9fa;
    box-sizing: border-box;
}

/* Grid specific scrollbar */
.grid::-webkit-scrollbar { 
    width: 12px; 
    margin-left: 4px;
}
.grid::-webkit-scrollbar-track { 
    background: #f8f9fa;
    border-radius: 10px;
    margin: 8px 0;
    border: 3px solid transparent;
    background-clip: padding-box;
}
.grid::-webkit-scrollbar-thumb { 
    background: linear-gradient(135deg, #1e90ff, #00cc66);
    border-radius: 10px;
    border: 3px solid #f8f9fa;
    background-clip: padding-box;
}
.grid::-webkit-scrollbar-thumb:hover { 
    background: linear-gradient(135deg, #0066cc, #00b359);
}
.grid::-webkit-scrollbar-corner { 
    background: #f8f9fa;
}

/* Cards - Sports Card Design */
.card {
    background:var(--card-bg);
    border-radius:18px;
    padding:20px;
    cursor:pointer;
    box-shadow:var(--shadow);
    transition:all 0.4s ease;
    text-align:center;
    display:flex;
    flex-direction:column;
    justify-content:space-between;
    border:2px solid #e8f4fd;
    overflow:hidden;
    position:relative;
}
.card:hover { 
    box-shadow:var(--shadow-hover); 
    transform:translateY(-8px) scale(1.02);
    border-color:var(--primary);
}
.card img { 
    width:100%; 
    height:160px; 
    object-fit:cover; 
    border-radius:14px; 
    margin-bottom:16px;
    border:3px solid #fff;
    box-shadow:0 4px 12px rgba(0,0,0,0.1);
}
.card .name { 
    font-weight:700; 
    font-size:17px; 
    white-space:normal; 
    word-wrap:break-word; 
    color:var(--dark); 
    margin-bottom:12px;
    line-height:1.4;
    min-height:48px;
    display:flex;
    align-items:center;
    justify-content:center;
}
.card .category-badge {
    display: inline-block;
    padding: 6px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 12px;
}
.card .category-badge.physical {
    background: var(--physical-badge);
    color: white;
}
.card .category-badge.services {
    background: var(--services-badge);
    color: white;
}
.card .price { 
    color:var(--primary); 
    font-weight:900; 
    margin-top:auto; 
    font-size:22px;
    background: linear-gradient(135deg, #e8f4fd, #d4eaff);
    padding:12px 16px;
    border-radius:12px;
    display:inline-block;
    border:2px solid rgba(30, 144, 255, 0.2);
}
.card:after {
    content:"+ Add to Cart";
    position:absolute;
    bottom:0;
    left:0;
    right:0;
    background: var(--gradient-primary);
    color:white;
    text-align:center;
    padding:14px;
    font-weight:700;
    transform:translateY(100%);
    transition:transform 0.4s;
    border-radius:0 0 16px 16px;
    font-size:16px;
    z-index:2;
}
.card:hover:after {
    transform:translateY(0);
}

/* Cart Panel - FIXED FOR ALL SCREENS - UPDATED */
.cart-panel {
    position: fixed;
    right: -450px;
    top: 0;
    width: 420px;
    height: 100%;
    background: #fff;
    transition: right 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    z-index: 1000;
    padding: 24px;
    box-shadow: -8px 0 30px rgba(0,0,0,0.15);
    border-left: 1px solid rgba(30, 144, 255, 0.1);
    border-radius: 24px 0 0 24px;
    display: flex;
    flex-direction: column;
    opacity: 1;
    visibility: visible;
}

.cart-panel.active { 
    right: 0; 
}

.panel-header { 
    display: flex; 
    justify-content: space-between; 
    align-items: center; 
    margin-bottom: 28px; 
    padding-bottom: 20px; 
    border-bottom: 3px solid rgba(30, 144, 255, 0.2); 
    flex-shrink: 0;
}
.panel-header h3 { 
    margin: 0; 
    font-size: 28px; 
    color: var(--dark); 
    display: flex; 
    align-items: center; 
    gap: 16px; 
    font-weight:800;
    background: linear-gradient(90deg, var(--primary), var(--primary-dark));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
}
.panel-header h3 i {
    background: var(--gradient-primary);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
}

/* Panel Tabs */
.panel-tabs { 
    display: flex; 
    gap: 6px; 
    margin-bottom: 28px; 
    background: #e8f4fd; 
    padding: 8px; 
    border-radius: 14px; 
    flex-shrink: 0;
}
.panel-tab { 
    flex: 1; 
    padding: 14px 12px; 
    border: none; 
    background: transparent; 
    border-radius: 12px; 
    cursor: pointer; 
    font-weight: 600; 
    font-size: 15px; 
    color: var(--gray); 
    display: flex; 
    align-items: center; 
    justify-content: center; 
    gap: 10px; 
    transition: all 0.3s ease; 
}
.panel-tab.active { 
    background: white; 
    color: var(--primary); 
    box-shadow: var(--shadow); 
}
.panel-tab:hover:not(.active) { 
    background: rgba(30, 144, 255, 0.1); 
    color:var(--primary);
}

/* Panel Content with Scrollbar */
.panel-content { 
    display: none; 
    flex-direction: column; 
    flex: 1; 
    overflow-y: auto; 
    overflow-x: hidden;
    padding-right: 8px; 
    margin-right: 4px;
    scrollbar-width: thin;
    scrollbar-color: #2ecc71 #f8fff9;
}
.panel-content.active { 
    display: flex; 
}

.panel-content::-webkit-scrollbar-track { 
    background: #f8fff9;
}
.panel-content::-webkit-scrollbar-thumb { 
    background: linear-gradient(180deg, #2ecc71, #27ae60);
}

/* Active content scrollbar */
#activeContent {
    max-height: calc(100vh - 300px);
    overflow-y: auto;
    scrollbar-color: #f39c12 #fff9e6;
}

#activeContent::-webkit-scrollbar-track { 
    background: #fff9e6;
}
#activeContent::-webkit-scrollbar-thumb { 
    background: linear-gradient(180deg, #f39c12, #e67e22);
}

/* No Content State */
.no-content { 
    text-align: center; 
    padding: 60px 20px; 
    color: #a0aec0; 
    flex: 1; 
    display: flex; 
    flex-direction: column; 
    justify-content: center; 
    align-items: center; 
}
.no-content i { 
    font-size: 72px; 
    margin-bottom: 20px; 
    opacity: 0.2; 
    background: linear-gradient(135deg, #1e90ff, #00cc66);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
}
.no-content p { 
    font-size: 20px; 
    margin: 0 0 12px 0; 
    font-weight:700;
    color:#64748b;
}
.no-content .subtext { 
    font-size: 15px; 
    color: #a0aec0; 
    margin-top: 8px; 
}

/* Cart Items */
.cart-item { 
    display: flex; 
    align-items: center; 
    gap: 20px; 
    padding: 20px; 
    background: #e8f4fd; 
    border-radius: 16px; 
    margin-bottom: 16px; 
    transition: 0.3s; 
    flex-wrap: wrap; 
    border:2px solid transparent;
    box-shadow:0 3px 10px rgba(0,0,0,0.05);
}
.cart-item:hover { 
    background: #d4eaff; 
    border-color:var(--primary);
    transform:translateX(6px);
}
.cart-item img { 
    width: 80px; 
    height: 80px; 
    border-radius: 12px; 
    object-fit: cover; 
    border:3px solid #fff;
    box-shadow:0 4px 12px rgba(0,0,0,0.1);
}
.cart-item .info { 
    flex: 1; 
    font-size: 17px; 
    font-weight: 600; 
    min-width: 140px; 
}
.cart-item .info .price {
    color:var(--primary);
    font-size:18px;
    font-weight:800;
    margin-top:6px;
}
.cart-item .qty { 
    display:flex; 
    align-items:center; 
    gap:12px;
}
.cart-item .qty button { 
    background: var(--gradient-primary); 
    color: #fff; 
    border: none; 
    padding: 10px 16px; 
    border-radius: 10px; 
    transition: 0.3s; 
    font-size: 18px; 
    cursor:pointer;
    width:44px;
    height:44px;
    display:flex;
    align-items:center;
    justify-content:center;
    box-shadow:0 4px 8px rgba(30, 144, 255, 0.3);
}
.cart-item .qty button:hover { 
    transform:scale(1.1);
}
.cart-item .qty span { 
    min-width: 40px; 
    display: inline-block; 
    text-align: center; 
    font-weight: 800; 
    font-size: 18px; 
    color:var(--dark);
    background:#fff;
    padding:8px;
    border-radius:8px;
    border:2px solid var(--light-gray);
}

/* Active Orders & History */
#activeContent .order-item,
#historyContent .history-item { 
    background: #f8fff9; 
    border-radius: 16px; 
    padding: 24px; 
    margin-bottom: 20px; 
    border-left: 6px solid var(--success); 
    transition: all 0.3s ease; 
    border:2px solid #e8f6ef;
    box-shadow:0 4px 12px rgba(39, 174, 96, 0.1);
}
#historyContent .history-item { 
    border-left-color: var(--warning); 
    background: #fff9e6; 
    border:2px solid #fef3cd;
}
.order-item:hover,
.history-item:hover { 
    transform: translateY(-5px); 
    box-shadow: 0 8px 25px rgba(0,0,0,0.15); 
}

.order-id,
.history-id { 
    font-weight: 800; 
    color: var(--dark); 
    font-size: 20px; 
    margin-bottom: 10px; 
    display:flex;
    justify-content:space-between;
    align-items:center;
    flex-wrap:wrap;
    gap:10px;
}
.order-date,
.history-date { 
    color: var(--gray); 
    font-size: 15px; 
    margin-bottom: 14px; 
}
.order-total,
.history-total { 
    font-weight: 900; 
    color: var(--success); 
    font-size: 24px; 
    margin-top: 16px; 
    text-align: right; 
}
.history-total { 
    color: var(--warning); 
}

/* Totals Section */
.totals { 
    border-top: 3px solid rgba(30, 144, 255, 0.2); 
    padding-top: 24px; 
    display: flex; 
    flex-direction: column; 
    gap: 16px; 
    margin-top: auto; 
    background:#e8f4fd;
    padding:24px;
    border-radius:16px;
    flex-shrink:0;
}
.totals div { 
    display:flex; 
    justify-content:space-between; 
    font-size:18px; 
    font-weight:600;
    color:var(--dark);
    align-items:center;
}
.totals div span:last-child {
    color:var(--primary);
    font-weight:900;
    font-size:24px;
    background: linear-gradient(90deg, var(--primary), var(--primary-dark));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
}

/* Buttons */
#btnSubmit, #btnClear, #btnSubmitMobile, #btnClearMobile { 
    width: 100%; 
    padding: 20px; 
    border: none; 
    border-radius: 14px; 
    font-weight: 700; 
    margin-top: 16px; 
    cursor: pointer; 
    transition: all 0.3s; 
    font-size: 18px; 
    display:flex;
    align-items:center;
    justify-content:center;
    gap:12px;
    letter-spacing:0.5px;
}
#btnSubmit, #btnSubmitMobile { 
    background: var(--gradient-success); 
    color: #fff; 
    box-shadow:0 6px 20px rgba(39, 174, 96, 0.3);
}
#btnSubmit:hover, #btnSubmitMobile:hover { 
    transform:translateY(-3px);
    box-shadow:0 10px 25px rgba(39, 174, 96, 0.4);
}
#btnClear, #btnClearMobile { 
    background: #fff; 
    color: var(--danger); 
    border:2px solid var(--light-gray);
}
#btnClear:hover, #btnClearMobile:hover { 
    background: #ffeaea; 
    color:var(--danger);
    border-color:var(--danger);
}

/* Active Button */
.primary-btn {
    background: var(--gradient-primary);
    color: #fff;
    padding: 16px 36px;
    border: none;
    border-radius: 14px;
    font-size: 17px;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    gap: 12px;
    box-shadow: 0 6px 20px rgba(30, 144, 255, 0.3);
    white-space: nowrap;
}
.primary-btn:hover {
    transform: translateY(-3px);
    box-shadow: 0 10px 25px rgba(30, 144, 255, 0.4);
}
.primary-btn:active {
    transform: scale(0.98);
}

/* Cart Header Icon */
.cart-header { 
    position: relative; 
    font-size: 18px; 
    cursor: pointer; 
    display: flex; 
    align-items: center; 
    gap: 12px; 
    color:var(--dark);
    background:#e8f4fd;
    padding:16px 24px;
    border-radius:14px;
    transition:all 0.3s;
    border:2px solid rgba(30, 144, 255, 0.1);
    font-weight:600;
    white-space: nowrap;
}
.cart-header:hover {
    background: linear-gradient(135deg, #d4eaff, #c2e0ff);
    color:var(--primary);
    transform:translateY(-3px);
    box-shadow:0 6px 20px rgba(30, 144, 255, 0.2);
    border-color:var(--primary);
}
.cart-badge { 
    position: absolute; 
    top: -8px; 
    right: -8px; 
    background: var(--danger); 
    color: #fff; 
    font-size: 14px; 
    padding: 6px 10px; 
    border-radius: 50%; 
    font-weight: 800; 
    min-width:28px;
    height:28px;
    display:flex;
    align-items:center;
    justify-content:center;
    box-shadow:0 4px 8px rgba(231, 76, 60, 0.3);
    border:2px solid #fff;
}

/* Close Button */
.close-cart { 
    position: absolute; 
    top: 20px; 
    right: 20px; 
    font-size: 36px; 
    cursor: pointer; 
    color: var(--gray); 
    z-index: 1001; 
    width:48px;
    height:48px;
    display:flex;
    align-items:center;
    justify-content:center;
    border-radius:50%;
    background:#e8f4fd;
    transition:all 0.3s;
    border:2px solid transparent;
}
.close-cart:hover {
    background:var(--primary);
    color:#fff;
    transform:rotate(90deg);
    border-color:var(--primary);
}

/* Mobile Cart Button */
#mobileCartBtn { 
    display: none; 
    position: fixed; 
    bottom: 40px; 
    right: 40px; 
    background: var(--gradient-primary); 
    color: #fff; 
    border: none; 
    border-radius: 50%; 
    width: 80px; 
    height: 80px; 
    font-size: 32px; 
    box-shadow: 0 8px 30px rgba(30, 144, 255, 0.4); 
    cursor: pointer; 
    z-index: 1000; 
    transition:all 0.3s;
    align-items:center;
    justify-content:center;
}
#mobileCartBtn:hover {
    transform:scale(1.15);
    box-shadow: 0 12px 40px rgba(30, 144, 255, 0.6);
}
#mobileCartBtn .badge { 
    position: absolute; 
    top: -5px; 
    right: -5px; 
    background: var(--danger); 
    color: #fff; 
    border-radius: 50%; 
    width: 32px; 
    height: 32px; 
    font-size: 16px; 
    display: flex; 
    align-items: center; 
    justify-content: center; 
    font-weight: 800; 
    border:3px solid #fff;
}

/* Overlay */
.cart-overlay { 
    position: fixed; 
    top: 0; 
    left: 0; 
    width: 100%; 
    height: 100%; 
    background: rgba(0,0,0,0.6); 
    display: none; 
    z-index: 999; 
    backdrop-filter:blur(5px);
}
.cart-overlay.active { 
    display: block; 
}

/* Order Details Button */
.btn-details {
    background: var(--gradient-primary);
    color: white;
    border: none;
    padding: 10px 20px;
    border-radius: 10px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s;
    font-size: 15px;
    display:flex;
    align-items:center;
    gap:8px;
    box-shadow:0 4px 12px rgba(30, 144, 255, 0.3);
}
.btn-details:hover {
    transform: translateY(-2px);
    box-shadow:0 6px 20px rgba(30, 144, 255, 0.4);
}

/* Modal for Order Details */
.modal {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.8);
    z-index: 2000;
    align-items: center;
    justify-content: center;
    backdrop-filter: blur(8px);
}

.modal-content {
    background: white;
    padding: 40px;
    border-radius: 20px;
    width: 90%;
    max-width: 600px;
    max-height: 80vh;
    overflow-y: auto;
    box-shadow: 0 25px 50px rgba(0,0,0,0.3);
    animation: modalSlide 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    border:2px solid rgba(30, 144, 255, 0.2);
}

@keyframes modalSlide {
    from { transform: translateY(-60px) scale(0.9); opacity: 0; }
    to { transform: translateY(0) scale(1); opacity: 1; }
}

.close-modal {
    float: right;
    font-size: 32px;
    cursor: pointer;
    color: var(--gray);
    transition: color 0.3s;
    width:40px;
    height:40px;
    display:flex;
    align-items:center;
    justify-content:center;
    border-radius:50%;
    background:#e8f4fd;
}
.close-modal:hover {
    color: var(--danger);
    background:#ffeaea;
}

/* Scroll to Top Button */
.scroll-top-btn {
    position: fixed;
    bottom: 100px;
    right: 40px;
    width: 50px;
    height: 50px;
    background: var(--gradient-primary);
    color: white;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    opacity: 0;
    transform: translateY(20px);
    transition: all 0.3s ease;
    box-shadow: 0 6px 20px rgba(30, 144, 255, 0.4);
    z-index: 999;
    border: none;
    font-size: 20px;
}

.scroll-top-btn.visible {
    opacity: 1;
    transform: translateY(0);
}

.scroll-top-btn:hover {
    transform: translateY(-5px) !important;
    box-shadow: 0 10px 25px rgba(30, 144, 255, 0.6);
}

/* ==================== SERVICE MODAL FIXES ==================== */
.service-modal {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.8);
    z-index: 2001;
    align-items: center;
    justify-content: center;
    backdrop-filter: blur(8px);
    overflow-y: auto;
    padding: 20px;
    box-sizing: border-box;
}

.service-modal-content {
    background: white;
    border-radius: 24px;
    width: 90%;
    max-width: 650px; /* Increased width */
    max-height: 90vh;
    overflow: hidden;
    box-shadow: 0 25px 50px rgba(0,0,0,0.3);
    animation: modalSlide 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    border: 3px solid rgba(30, 144, 255, 0.2);
    display: flex;
    flex-direction: column;
    position: relative;
}

.service-modal-header {
    background: linear-gradient(135deg, #1e90ff, #00cc66);
    padding: 24px 32px;
    color: white;
    border-radius: 24px 24px 0 0;
    position: relative;
    flex-shrink: 0;
}

.service-modal-header h3 {
    margin: 0;
    font-size: 24px;
    font-weight: 800;
    display: flex;
    align-items: center;
    gap: 12px;
}

.service-modal-header .close-service-modal {
    position: absolute;
    top: 20px;
    right: 20px;
    font-size: 28px;
    cursor: pointer;
    color: white;
    transition: all 0.3s;
    width: 40px;
    height: 40px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    background: rgba(255,255,255,0.2);
    border: none;
    z-index: 10;
}

.service-modal-header .close-service-modal:hover {
    background: rgba(255,255,255,0.3);
    transform: rotate(90deg);
}

.service-modal-tabs {
    display: flex;
    background: rgba(30, 144, 255, 0.1);
    border-bottom: 2px solid rgba(30, 144, 255, 0.2);
    position: relative;
    z-index: 1;
    flex-shrink: 0;
}

.service-modal-tab {
    flex: 1;
    padding: 16px;
    border: none;
    background: transparent;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    color: #7f8c8d;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    transition: all 0.3s;
    position: relative;
    min-height: 70px;
    z-index: 2;
}

.service-modal-tab.active {
    color: var(--primary);
    background: white;
    border-bottom: 3px solid var(--primary);
    box-shadow: 0 4px 12px rgba(30, 144, 255, 0.1);
}

.service-modal-body {
    padding: 24px;
    background: linear-gradient(135deg, #f8fff9, #e8f4fd);
    overflow-y: auto;
    flex: 1;
    max-height: 400px; /* Fixed height for scroll */
}

.service-tab-content {
    display: none;
    animation: fadeIn 0.3s ease;
    height: 100%;
    overflow-y: auto;
}

.service-tab-content.active {
    display: block;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
}

.date-time-container {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
    margin-top: 20px;
}

@media (max-width: 768px) {
    .date-time-container {
        grid-template-columns: 1fr;
    }
}

.date-time-group {
    background: white;
    padding: 20px;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    border: 2px solid rgba(30, 144, 255, 0.1);
}

.date-time-group h4 {
    margin: 0 0 16px 0;
    color: var(--dark);
    font-size: 16px;
    display: flex;
    align-items: center;
    gap: 10px;
}

.date-time-input {
    width: 100%;
    padding: 14px;
    border: 2px solid #e8f4fd;
    border-radius: 10px;
    font-size: 15px;
    font-weight: 600;
    color: var(--dark);
    background: #f8f9fa;
    outline: none;
    transition: all 0.3s;
    box-sizing: border-box;
}

.date-time-input:focus {
    border-color: var(--primary);
    background: white;
    box-shadow: 0 0 0 4px rgba(30, 144, 255, 0.15);
}

.time-selection {
    display: grid;
    grid-template-columns: 1fr auto 1fr;
    gap: 12px;
    align-items: center;
    margin-top: 12px;
}

.time-separator {
    font-size: 20px;
    font-weight: 800;
    color: var(--primary);
    text-align: center;
}

.duration-display {
    text-align: center;
    padding: 20px;
    background: white;
    border-radius: 12px;
    margin-top: 20px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    border: 2px solid rgba(46, 204, 113, 0.2);
}

.duration-display h5 {
    margin: 0 0 12px 0;
    color: var(--dark);
    font-size: 15px;
}

.duration-value {
    font-size: 24px;
    font-weight: 900;
    color: var(--success);
    display: block;
}

.service-modal-footer {
    padding: 20px 24px;
    background: white;
    border-top: 2px solid rgba(30, 144, 255, 0.1);
    display: flex;
    gap: 12px;
    border-radius: 0 0 24px 24px;
    flex-shrink: 0;
    position: sticky;
    bottom: 0;
}

.service-modal-btn {
    flex: 1;
    padding: 16px;
    border: none;
    border-radius: 12px;
    font-size: 16px;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.3s;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
}

.service-modal-btn.confirm {
    background: linear-gradient(135deg, #2ecc71, #27ae60);
    color: white;
    box-shadow: 0 6px 20px rgba(39, 174, 96, 0.3);
}

.service-modal-btn.confirm:hover {
    transform: translateY(-3px);
    box-shadow: 0 10px 25px rgba(39, 174, 96, 0.4);
}

.service-modal-btn.cancel {
    background: white;
    color: var(--danger);
    border: 2px solid var(--light-gray);
}

.service-modal-btn.cancel:hover {
    background: #ffeaea;
    border-color: var(--danger);
}

.price-breakdown {
    background: white;
    padding: 16px;
    border-radius: 12px;
    margin-top: 20px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    border: 2px solid rgba(255, 193, 7, 0.2);
}

.price-breakdown h5 {
    margin: 0 0 12px 0;
    color: var(--dark);
    font-size: 15px;
    display: flex;
    align-items: center;
    gap: 8px;
}

.price-breakdown-item {
    display: flex;
    justify-content: space-between;
    padding: 10px 0;
    border-bottom: 1px solid #e8f4fd;
    font-size: 15px;
}

.price-breakdown-item:last-child {
    border-bottom: none;
    font-weight: 800;
    color: var(--primary);
    font-size: 16px;
    margin-top: 6px;
    padding-top: 12px;
    border-top: 2px solid #e8f4fd;
}

/* Ensure modal body content doesn't overflow */
.service-modal-body * {
    box-sizing: border-box;
}

/* Scrollbar for modal body */
.service-modal-body::-webkit-scrollbar {
    width: 8px;
}

.service-modal-body::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 4px;
}

.service-modal-body::-webkit-scrollbar-thumb {
    background: var(--primary);
    border-radius: 4px;
}

.service-modal-body::-webkit-scrollbar-thumb:hover {
    background: var(--primary-dark);
}

/* ==================== RESPONSIVE DESIGN ==================== */

/* Desktop View (1025px and above) */
@media (min-width: 1025px) {
    .cart-panel {
        right: -450px;
        top: 0;
        width: 420px;
        height: 100%;
        transform: none;
        transition: right 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    }
    
    .cart-panel.active {
        right: 0;
        transform: none;
        opacity: 1;
    }
    
    #mobileCartBtn {
        display: none;
    }
    
    .cart-header {
        display: flex;
    }
    
    .grid {
        max-height: calc(100vh - 500px);
    }
    
    .date-time-container {
        grid-template-columns: 1fr 1fr;
    }
}
@media (max-width: 1024px) {
    .grid {
        height: auto;
        max-height: calc(100vh - 380px);
    }
}

@media (max-width: 768px) {
    .grid {
        height: auto;
        max-height: calc(100vh - 420px);
    }
}

/* iPad and Tablet Landscape (769px to 1024px) */
@media (min-width: 769px) and (max-width: 1024px) {
    .pos-container { 
        gap: 16px;
        padding: 16px;
        flex-direction: row;
    }
    
    .left-panel { 
        flex: 1;
        padding: 20px !important;
    }

    
    .grid {
        grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
        gap: 16px;
        max-height: calc(100vh - 450px);
    }
    
    .cart-panel {
        right: -400px;
        width: 380px;
        height: 100%;
        top: 0;
        transform: none;
        transition: right 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    }
    
    .cart-panel.active {
        right: 0;
        transform: none;
        opacity: 1;
    }
    
    #mobileCartBtn {
        display: none;
    }
    
    .cart-header {
        display: flex;
    }
    
    .sports-navbar .navbar-container {
        flex-direction: column;
        align-items: flex-start;
    }
    
    .sales-info {
        width: 100%;
        justify-content: space-around;
    }
    
    .date-time-container {
        grid-template-columns: 1fr;
    }
}

/* Tablet Portrait (601px to 768px) */
@media (min-width: 601px) and (max-width: 768px) {
    .pos-container { 
        flex-direction: column; 
        height: auto;
        min-height: 100vh;
        padding: 16px;
        gap: 16px;
    }
    
    .left-panel { 
        flex: none;
        width: 100%;
        padding: 20px !important;
        margin-bottom: 90px;
    }
    
    .cart-panel {
        width: 100%;
        height: 85vh;
        top: auto;
        bottom: 0;
        right: 0;
        left: 0;
        border-radius: 24px 24px 0 0;
        transform: translateY(100%);
        transition: transform 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    }
    
    .cart-panel.active { 
        transform: translateY(0);
    }
    
    #mobileCartBtn { 
        display: flex; 
        bottom: 30px;
        right: 30px;
        width: 70px;
        height: 70px;
        font-size: 28px;
    }
    
    .cart-header {
        display: none;
    }
    
    .grid {
        grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
        gap: 16px;
    }
    
    .sports-navbar {
        padding: 16px;
    }
    
    .sports-navbar .navbar-container {
        flex-direction: column;
        gap: 16px;
    }
    
    .sales-info {
        width: 100%;
        justify-content: space-around;
    }
    
    .navbar-brand h1 {
        font-size: 22px;
    }
    
    .filter-container {
        flex-direction: column;
    }
    
    .filter-group {
        min-width: 100%;
    }
    
    .date-time-container {
        grid-template-columns: 1fr;
    }
    
    .service-modal-content {
        max-width: 90%;
        max-height: 85vh;
    }
}

/* Mobile View (600px and below) */
@media (max-width: 600px) {
    .pos-container { 
        flex-direction: column; 
        height: auto;
        min-height: 100vh;
        padding: 12px;
        gap: 12px;
    }
    
    .left-panel { 
        flex: none;
        width: 100%;
        padding: 16px !important;
        margin-bottom: 100px;
    }
    
    .cart-panel { 
        width: 100%;
        height: 90vh;
        top: auto;
        bottom: 0;
        right: 0;
        left: 0;
        border-radius: 20px 20px 0 0;
        transform: translateY(100%);
        transition: transform 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        padding: 16px;
    }
    
    .cart-panel.active { 
        transform: translateY(0);
    }
    
    #mobileCartBtn { 
        display: flex; 
        bottom: 24px;
        right: 24px;
        width: 64px;
        height: 64px;
        font-size: 24px;
    }
    
    .cart-header {
        display: none;
    }
    
    .grid {
        grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
        gap: 12px;
    }
    
    .sports-navbar {
        padding: 12px;
    }
    
    .sports-navbar .navbar-container {
        flex-direction: column;
        gap: 12px;
    }
    
    .navbar-brand {
        width: 100%;
        justify-content: center;
    }
    
    .navbar-brand h1 {
        font-size: 20px;
    }
    
    .sales-info {
        width: 100%;
        justify-content: space-around;
        padding: 8px 12px;
    }
    
    .info-value {
        font-size: 16px;
    }
    
    .filter-container {
        flex-direction: column;
        gap: 12px;
    }
    
    .filter-group {
        min-width: 100%;
    }
    
    .date-time-container {
        grid-template-columns: 1fr;
    }
    
    .service-modal-content {
        max-width: 95%;
        max-height: 90vh;
        padding: 0;
    }
    
    .service-modal-tab {
        padding: 12px 8px;
        font-size: 14px;
        min-height: 70px;
    }
    
    .service-modal-body {
        padding: 16px;
    }
}

/* Very Small Screens (480px and below) */
@media (max-width: 480px) {
    .pos-container {
        padding: 8px;
    }
    
    .left-panel {
        padding: 12px !important;
    }
    
    .cart-panel {
        padding: 12px;
        height: 92vh;
    }
    
    #mobileCartBtn {
        width: 56px;
        height: 56px;
        font-size: 22px;
        bottom: 20px;
        right: 20px;
    }
    
    .grid {
        grid-template-columns: repeat(auto-fill, minmax(110px, 1fr));
        gap: 10px;
    }
    
    .navbar-brand h1 {
        font-size: 18px;
    }
    
    .sports-icon {
        font-size: 24px !important;
    }
    
    .info-label {
        font-size: 10px;
    }
    
    .info-value {
        font-size: 14px;
    }
    
    .tab {
        padding: 12px 16px;
        min-width: 80px;
        font-size: 14px;
    }
    
    .service-modal-tab {
        flex-direction: row;
        min-height: auto;
        padding: 10px;
        gap: 6px;
    }
    
    .service-modal-tab .tab-icon {
        font-size: 16px;
    }
    
    .service-modal-tab .tab-price {
        font-size: 14px;
    }
}
</style>
</head>
<body>
<form id="form1" runat="server">
<div class="sports-navbar">
    <div class="navbar-container">
        <div class="navbar-brand">
            <i class="fas fa-running sports-icon"></i>
            <h1>Sports Pro POS</h1>
        </div>
        
        <div class="sales-info">
            <div class="info-item">
                <span class="info-label">Today's Sales</span>
                <span class="info-value"><i class="fas fa-rupee-sign"></i> 45,280</span>
            </div>
            <div class="info-item">
                <span class="info-label">Active Orders</span>
                <span class="info-value"><i class="fas fa-bolt"></i> 12</span>
            </div>
            <div class="info-item">
                <span class="info-label">Cart Items</span>
                <span class="info-value"><i class="fas fa-shopping-cart"></i> <span id="navbarCartCount">0</span></span>
            </div>
        </div>
    </div>
    
    <div class="filter-container">
        <div class="filter-group">
            <label><i class="fas fa-filter"></i> Filter by Department</label>
            <select class="filter-select" id="deptFilter">
                <option value="">All Departments</option>
                <!-- Department options will be loaded dynamically -->
            </select>
        </div>
        <div class="filter-group">
           <%-- <label><i class="fas fa-filter"></i> filter by category</label>
            <select class="filter-select" id="categoryfilter">
                <option value="">all categories</option>
                <option value="physical">physical products</option>
                <option value="services">services</option>
            </select>--%>
        </div>
        <div class="filter-group">
            <label><i class="fas fa-sort-amount-down"></i> Sort by</label>
            <select class="filter-select" id="sortFilter">
                <option value="name_asc">Name (A-Z)</option>
                <option value="name_desc">Name (Z-A)</option>
                <option value="price_asc">Price (Low to High)</option>
                <option value="price_desc">Price (High to Low)</option>
            </select>
        </div>
    </div>
</div>

<div class="pos-container">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

 <div class="left-panel">
  <div class="headermaincart">
   <div class="pos-header"><i class="fa fa-dumbbell"></i> Sports Pro Shop</div>
   
   <div style="display: flex; align-items: center; gap: 20px; flex-wrap: wrap;">
    <button type="button" class="primary-btn" id="activeOrdersBtn">
        <i class="fa fa-bolt"></i> Active Orders
    </button>
    
    <div class="cart-header" id="desktopCartBtn">
     <i class="fa fa-shopping-cart"></i>
     <span>View Cart</span>
     <span class="cart-badge">0</span>
    </div>
   </div>
  </div>

  <div class="tabs">
   <div class="tab active" data-category="">All Sports Items</div>
   <div class="tab" data-category="Physical">Physical</div>
   <div class="tab" data-category="Services">Services</div>
  </div>
  
  <div class="search-row">
   <input type="text" id="txtMember" placeholder="Enter Member ID or Mobile..." autocomplete="off" />
   <input type="text" id="txtSearch" placeholder="Search sports products..." autocomplete="off" />
   <button type="button" id="btnReload" title="Reload Products">
    <i class="fa fa-sync-alt"></i>
   </button>
  </div>
  
  <div id="memberBox">
   <div><b>Card No:</b> <span id="memCardNo"></span></div>
   <div><b>Name:</b> <span id="memName"></span></div>
   <div><b>Mobile:</b> <span id="memPhone"></span></div>
   <div><b>Balance:</b> <span id="memBalance"></span></div>
  </div>
  
  <div class="grid" id="gridItems"></div>
 </div>
 
 <!-- Main Cart Panel -->
 <div class="cart-panel" id="mainPanel">
  <div class="panel-header">
   <h3 id="panelTitle"><i class="fa fa-shopping-cart"></i> Shopping Cart</h3>
   <span class="close-cart" id="closePanel">&times;</span>
  </div>
  <div class="panel-tabs" id="panelTabs">
   <button class="panel-tab active" data-content="cart">
    <i class="fa fa-shopping-cart"></i> Cart
   </button>
   <button class="panel-tab" data-content="active">
    <i class="fa fa-bolt"></i> Active Orders
   </button>
   <button class="panel-tab" data-content="history">
    <i class="fa fa-history"></i> Order History
   </button>
  </div>
  <div class="panel-content active" id="cartContent">
   <div id="cartItems">
    <div class="no-content">
     <i class="fa fa-shopping-cart"></i>
     <p>Your cart is empty</p>
     <p class="subtext">Add items from the menu to get started</p>
    </div>
   </div>
   <div class="totals">
    <div><span>Cart Total</span> <span id="totalPrice">Rs. 0</span></div>
    <div><span>Member Balance</span> <span id="memberBalance">Rs. 0</span></div>
    <div><span>Available Balance</span> <span id="availableBalance">Rs. 0</span></div>
    <button type="button" id="btnSubmit">
        <i class="fa fa-check-circle"></i> Process Payment
    </button>
    <button type="button" id="btnClear">
        <i class="fa fa-trash"></i> Clear Cart
    </button>
   </div>
  </div>
  
  <div class="panel-content" id="activeContent">
   <div id="activeOrdersList">
    <div class="no-content">
      <i class="fa fa-bolt"></i>
      <p>No active orders</p>
      <p class="subtext">Active orders will appear here</p>
    </div>
   </div>
  </div>

  <div class="panel-content" id="historyContent">
   <div id="historyList">
    <div class="no-content">
     <i class="fa fa-history"></i>
     <p>No order history</p>
     <p class="subtext">Your order history will appear here</p>
    </div>
   </div>
  </div>
 </div>

 <div class="cart-overlay" id="panelOverlay"></div>
</div>

<!-- Mobile Cart Button -->
<button type="button" id="mobileCartBtn" title="View Cart">
 <i class="fa fa-shopping-cart"></i>
 <span class="badge" id="cartCount">0</span>
</button>

<!-- Scroll to Top Button -->
<button type="button" class="scroll-top-btn" title="Scroll to Top">
 <i class="fa fa-arrow-up"></i>
</button>

<!-- Modal for Order Details -->
<div class="modal" id="orderModal">
    <div class="modal-content">
        <span class="close-modal">&times;</span>
        <h3 style="margin-top: 0; background: linear-gradient(90deg, var(--primary), var(--primary-dark)); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">Order Details</h3>
        <div id="orderModalBody">
            <p>Loading order details...</p>
        </div>
    </div>
</div>

<!-- Service Selection Modal -->
<div class="service-modal" id="serviceModal">
    <div class="service-modal-content">
        <div class="service-modal-header">
            <h3><i class="fas fa-calendar-alt"></i> <span id="serviceModalTitle">Service Booking</span></h3>
            <span class="close-service-modal">&times;</span>
        </div>
        
        <div class="service-modal-tabs" id="serviceTabs">
            <!-- Tabs will be dynamically populated -->
        </div>
        
        <div class="service-modal-body">
            <div id="dailyContent" class="service-tab-content active">
                <div class="date-time-container">
                    <div class="date-time-group">
                        <h4><i class="fas fa-calendar-day"></i> Select Date</h4>
                        <input type="date" id="dailyDate" class="date-time-input">
                    </div>
                    <div class="date-time-group">
                        <h4><i class="fas fa-clock"></i> Select Time</h4>
                        <div class="time-selection">
                            <input type="time" id="dailyStartTime" class="date-time-input" value="09:00">
                            <span class="time-separator">→</span>
                            <input type="time" id="dailyEndTime" class="date-time-input" value="17:00">
                        </div>
                    </div>
                </div>
                
                <div class="duration-display">
                    <h5>Service Duration</h5>
                    <span class="duration-value" id="dailyDuration">8 hours</span>
                </div>
            </div>
            
            <div id="monthlyContent" class="service-tab-content">
                <div class="date-time-container">
                    <div class="date-time-group">
                        <h4><i class="fas fa-calendar-check"></i> Start Date</h4>
                        <input type="date" id="monthlyStartDate" class="date-time-input">
                    </div>
                    <div class="date-time-group">
                        <h4><i class="fas fa-calendar-times"></i> End Date</h4>
                        <input type="date" id="monthlyEndDate" class="date-time-input">
                    </div>
                </div>
                
                <div class="duration-display">
                    <h5>Service Period</h5>
                    <span class="duration-value" id="monthlyDuration">30 days</span>
                </div>
                
                <div class="price-breakdown">
                    <h5><i class="fas fa-calculator"></i> Price Breakdown</h5>
                    <div class="price-breakdown-item">
                        <span>Monthly Rate</span>
                        <span id="monthlyRate">Rs. 0</span>
                    </div>
                    <div class="price-breakdown-item">
                        <span>Total Days</span>
                        <span id="totalDays">0 days</span>
                    </div>
                    <div class="price-breakdown-item">
                        <span>Total Amount</span>
                        <span id="monthlyTotal">Rs. 0</span>
                    </div>
                </div>
            </div>
            
            <div id="continueContent" class="service-tab-content">
                <div class="date-time-container">
                    <div class="date-time-group">
                        <h4><i class="fas fa-play-circle"></i> Start Date</h4>
                        <input type="date" id="continueStartDate" class="date-time-input">
                    </div>
                    <div class="date-time-group">
                        <h4><i class="fas fa-infinity"></i> Continuous Service</h4>
                        <div style="text-align: center; padding: 20px;">
                            <i class="fas fa-infinity fa-3x" style="color: var(--primary); margin-bottom: 16px;"></i>
                            <p style="color: var(--gray); font-weight: 600;">Ongoing service with automatic renewal</p>
                        </div>
                    </div>
                </div>
                
                <div class="duration-display">
                    <h5>Service Type</h5>
                    <span class="duration-value">Continuous</span>
                </div>
                
                <div class="price-breakdown">
                    <h5><i class="fas fa-crown"></i> Premium Features</h5>
                    <div style="margin-top: 16px;">
                        <p style="color: var(--dark); margin: 8px 0; display: flex; align-items: center; gap: 10px;">
                            <i class="fas fa-check-circle" style="color: var(--success);"></i>
                            <span>Automatic monthly renewal</span>
                        </p>
                        <p style="color: var(--dark); margin: 8px 0; display: flex; align-items: center; gap: 10px;">
                            <i class="fas fa-check-circle" style="color: var(--success);"></i>
                            <span>Priority booking access</span>
                        </p>
                        <p style="color: var(--dark); margin: 8px 0; display: flex; align-items: center; gap: 10px;">
                            <i class="fas fa-check-circle" style="color: var(--success);"></i>
                            <span>Free cancellations</span>
                        </p>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="service-modal-footer">
            <button type="button" class="service-modal-btn cancel" id="cancelService">
                <i class="fas fa-times"></i> Cancel
            </button>
            <button type="button" class="service-modal-btn confirm" id="confirmService">
                <i class="fas fa-check-circle"></i> Add to Cart
            </button>
        </div>
    </div>
</div>

<script>
    let cart = [];
    let member = null;
    let currentPanelMode = 'cart';
    let products = [];
    let lastFocusTime = 0;
    const FOCUS_DELAY = 300;
    let currentCategory = "";
    let currentSort = "name_asc";
    let currentDept = "";
    let selectedServiceItem = null;
    let servicePrices = null;
    let currentServiceType = 'daily';

    // Price formatting function
    function priceFormat(value) {
        return "Rs. " + parseFloat(value).toLocaleString('en-IN', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    }

    // Format date for input field
    function formatDateForInput(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    // Fetch departments from server
    function fetchDepartments() {
        $.ajax({
            type: "POST",
            url: "Pos.aspx/GetDepartments",
            data: "{}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (res) {
                const depts = res.d || [];
                const $deptFilter = $("#deptFilter");
                $deptFilter.empty();
                $deptFilter.append('<option value="">All Departments</option>');
                
                depts.forEach(dept => {
                    $deptFilter.append(`<option value="${dept.Dept_ID}">${dept.Dept_Name}</option>`);
                });
            },
            error: function () {
                console.error("Failed to load departments");
            }
        });
    }

    // Fetch products from server with category and sort
    function fetchProducts(search = "", category = "", dept = "", sort = "") {
        $("#gridItems").html('<div style="text-align:center;padding:40px;color:#94a3b8;"><i class="fa fa-spinner fa-spin fa-2x"></i><p style="margin-top:16px;">Loading sports products...</p></div>');

        $.ajax({
            type: "POST",
            url: "Pos.aspx/GetProducts",
            data: JSON.stringify({ 
                search: search, 
                category: category,
                dept: dept,
                sort: sort
            }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (res) {
                products = res.d || [];
                renderItems(products);
            },
            error: function (xhr) {
                console.error("Error fetching products:", xhr.responseText);
                $("#gridItems").html('<div style="text-align:center;padding:40px;color:#e74c3c;"><i class="fa fa-exclamation-triangle fa-2x"></i><p style="margin-top:16px;">Failed to load products</p></div>');
            }
        });
    }

    // Department filter change
    $("#deptFilter").change(function() {
        currentDept = $(this).val();
        fetchProducts($("#txtSearch").val().trim(), currentCategory, currentDept, currentSort);
    });

    // Tab click handler for category filtering
    $(".tab").click(function () {
        $(".tab").removeClass("active");
        $(this).addClass("active");
        
        currentCategory = $(this).data("category") || "";
        
        fetchProducts($("#txtSearch").val().trim(), currentCategory, currentDept, currentSort);
    });

    // Sort filter change
    $("#sortFilter").change(function() {
        currentSort = $(this).val();
        fetchProducts($("#txtSearch").val().trim(), currentCategory, currentDept, currentSort);
    });

    // Show service selection modal - FIXED VERSION
   // Show service selection modal - FIXED
// Show service selection modal - FIXED VERSION
function showServiceModal(item) {
    selectedServiceItem = item;
    servicePrices = null;
    
    // Show modal with loading state
    $("#serviceModal").css("display", "flex");
    $("#serviceModalTitle").text(item.name);
    
    // Set initial loading content
    $(".service-modal-body").html(`
        <div style="padding: 60px; text-align: center; background: linear-gradient(135deg, #f8fff9, #e8f4fd); border-radius: 16px; min-height: 300px; display: flex; flex-direction: column; justify-content: center; align-items: center;">
            <i class="fas fa-spinner fa-spin fa-3x" style="color: var(--primary); margin-bottom: 20px;"></i>
            <p style="font-size: 18px; font-weight: 600; color: var(--dark);">Loading service details...</p>
            <p style="font-size: 14px; color: var(--gray); margin-top: 8px;">Please wait</p>
        </div>
    `);
    
    // Fetch service prices from database
    $.ajax({
        type: "POST",
        url: "Pos.aspx/GetServicePrices",
        data: JSON.stringify({ productName: item.name }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (res) {
            const result = res.d;
            if (result && result.success) {
                servicePrices = result;
                populateServiceModalWithPrices(item, result);
            } else {
                // Show error in modal
                $(".service-modal-body").html(`
                    <div style="padding: 60px; text-align: center;">
                        <i class="fas fa-exclamation-triangle fa-3x" style="color: var(--warning); margin-bottom: 20px;"></i>
                        <p style="font-size: 18px; font-weight: 600; color: var(--dark);">Failed to load service prices</p>
                        <p style="font-size: 14px; color: var(--gray); margin-top: 8px;">Please try again or contact support</p>
                    </div>
                `);
            }
        },
        error: function (xhr, status, error) {
            console.error("Error loading service prices:", error);
            $(".service-modal-body").html(`
                <div style="padding: 60px; text-align: center;">
                    <i class="fas fa-exclamation-circle fa-3x" style="color: var(--danger); margin-bottom: 20px;"></i>
                    <p style="font-size: 18px; font-weight: 600; color: var(--dark);">Network Error</p>
                    <p style="font-size: 14px; color: var(--gray); margin-top: 8px;">Could not load service details. Please check your connection.</p>
                </div>
            `);
        }
    });
}

// Populate service modal with database prices - FIXED
function populateServiceModalWithPrices(item, priceData) {
    // Clear previous tabs
    $("#serviceTabs").empty();
    
    // Store service prices globally
    servicePrices = priceData;
    
    // Create tabs with database prices
    const tabsHtml = `
        <button type="button" class="service-modal-tab active" data-type="daily">
            <i class="fas fa-sun tab-icon"></i>
            <span>Daily</span>
            <span class="tab-price">${priceFormat(priceData.daily)}</span>
        </button>
        <button type="button" class="service-modal-tab" data-type="monthly">
            <i class="fas fa-calendar-alt tab-icon"></i>
            <span>Monthly</span>
            <span class="tab-price">${priceFormat(priceData.monthly)}</span>
        </button>
        <button type="button" class="service-modal-tab" data-type="continue">
            <i class="fas fa-infinity tab-icon"></i>
            <span>Continue</span>
            <span class="tab-price">${priceFormat(priceData.continuePrice)}</span>
        </button>
    `;
    
    $("#serviceTabs").html(tabsHtml);    
    
    // Set modal body content
    const modalBodyHtml = `
        <div id="dailyContent" class="service-tab-content active">
            <div class="date-time-container">
                <div class="date-time-group">
                    <h4><i class="fas fa-calendar-day"></i> Select Date</h4>
                    <input type="date" id="dailyDate" class="date-time-input">
                </div>
                <div class="date-time-group">
                    <h4><i class="fas fa-clock"></i> Select Time</h4>
                    <div class="time-selection">
                        <input type="time" id="dailyStartTime" class="date-time-input" value="09:00">
                        <span class="time-separator">→</span>
                        <input type="time" id="dailyEndTime" class="date-time-input" value="17:00">
                    </div>
                </div>
            </div>
            
            <div class="duration-display">
                <h5>Service Duration</h5>
                <span class="duration-value" id="dailyDuration">8 hours</span>
            </div>
            
            <div class="price-breakdown" style="margin-top: 20px;">
                <h5><i class="fas fa-tag"></i> Daily Rate</h5>
                <div class="price-breakdown-item" style="font-size: 20px; font-weight: 800; color: var(--primary);">
                    <span>Total Amount:</span>
                    <span id="dailyTotal">${priceFormat(priceData.daily)}</span>
                </div>
            </div>
        </div>
        
        <div id="monthlyContent" class="service-tab-content">
            <div class="date-time-container">
                <div class="date-time-group">
                    <h4><i class="fas fa-calendar-check"></i> Start Date</h4>
                    <input type="date" id="monthlyStartDate" class="date-time-input">
                </div>
                <div class="date-time-group">
                    <h4><i class="fas fa-calendar-times"></i> End Date</h4>
                    <input type="date" id="monthlyEndDate" class="date-time-input">
                </div>
            </div>
            
            <div class="duration-display">
                <h5>Service Period</h5>
                <span class="duration-value" id="monthlyDuration">30 days</span>
            </div>
            
            <div class="price-breakdown">
                <h5><i class="fas fa-calculator"></i> Price Breakdown</h5>
                <div class="price-breakdown-item">
                    <span>Monthly Rate</span>
                    <span id="monthlyRate">${priceFormat(priceData.monthly)}</span>
                </div>
                <div class="price-breakdown-item">
                    <span>Total Days</span>
                    <span id="totalDays">30 days</span>
                </div>
                <div class="price-breakdown-item" style="font-weight: 800; color: var(--primary); font-size: 18px;">
                    <span>Total Amount</span>
                    <span id="monthlyTotal">${priceFormat(priceData.monthly)}</span>
                </div>
            </div>
        </div>
        
        <div id="continueContent" class="service-tab-content">
            <div class="date-time-container">
                <div class="date-time-group">
                    <h4><i class="fas fa-play-circle"></i> Start Date</h4>
                    <input type="date" id="continueStartDate" class="date-time-input">
                </div>
                <div class="date-time-group">
                    <h4><i class="fas fa-infinity"></i> Continuous Service</h4>
                    <div style="text-align: center; padding: 20px;">
                        <i class="fas fa-infinity fa-3x" style="color: var(--primary); margin-bottom: 16px;"></i>
                        <p style="color: var(--gray); font-weight: 600;">Ongoing service with automatic renewal</p>
                    </div>
                </div>
            </div>
            
            <div class="duration-display">
                <h5>Service Type</h5>
                <span class="duration-value">Continuous</span>
            </div>
            
            <div class="price-breakdown">
                <h5><i class="fas fa-crown"></i> Premium Features</h5>
                <div style="margin-top: 16px;">
                    <p style="color: var(--dark); margin: 8px 0; display: flex; align-items: center; gap: 10px;">
                        <i class="fas fa-check-circle" style="color: var(--success);"></i>
                        <span>Automatic monthly renewal</span>
                    </p>
                    <p style="color: var(--dark); margin: 8px 0; display: flex; align-items: center; gap: 10px;">
                        <i class="fas fa-check-circle" style="color: var(--success);"></i>
                        <span>Priority booking access</span>
                    </p>
                    <p style="color: var(--dark); margin: 8px 0; display: flex; align-items: center; gap: 10px;">
                        <i class="fas fa-check-circle" style="color: var(--success);"></i>
                        <span>Free cancellations</span>
                    </p>
                </div>
                <div class="price-breakdown-item" style="font-weight: 800; color: var(--primary); font-size: 20px; margin-top: 20px;">
                    <span>Monthly Fee:</span>
                    <span id="continueTotal">${priceFormat(priceData.continuePrice)}</span>
                </div>
            </div>
        </div>
    `;

    $(".service-modal-body").html(modalBodyHtml);

    // Set default dates
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    const nextMonth = new Date(today);
    nextMonth.setMonth(nextMonth.getMonth() + 1);
    
    const todayStr = formatDateForInput(today);
    const tomorrowStr = formatDateForInput(tomorrow);
    const nextMonthStr = formatDateForInput(nextMonth);
    
    // Set date values
    $("#dailyDate").val(todayStr).attr("min", todayStr);
    $("#monthlyStartDate").val(todayStr).attr("min", todayStr);
    $("#monthlyEndDate").val(nextMonthStr);
    $("#continueStartDate").val(todayStr).attr("min", todayStr);
    
    // Initialize calculations
    updateDailyDuration();
    updateMonthlyCalculation();
    
    // Setup event handlers
    setupServiceModalHandlers();
}

// Set up service modal event handlers - FIXED
function setupServiceModalHandlers() {
    // Remove existing handlers first to avoid duplicates
    $(".service-modal-tab").off('click');
    $("#dailyStartTime, #dailyEndTime, #dailyDate, #monthlyStartDate, #monthlyEndDate").off('change');
    
    // Tab click handlers - FIXED
    $(".service-modal-tab").on('click', function(e) {
        e.preventDefault();
        const type = $(this).data('type');
        currentServiceType = type;
        
        $(".service-modal-tab").removeClass("active");
        $(this).addClass("active");
        
        $(".service-tab-content").removeClass("active");
        $(`#${type}Content`).addClass("active");
    });
    
    // Date/time change handlers
    $("#dailyStartTime, #dailyEndTime, #dailyDate").on('change', updateDailyDuration);
    $("#monthlyStartDate, #monthlyEndDate").on('change', updateMonthlyCalculation);
}

// Update daily duration calculation
function updateDailyDuration() {
    const startTime = $("#dailyStartTime").val();
    const endTime = $("#dailyEndTime").val();
    
    if (startTime && endTime) {
        const start = new Date(`2000-01-01T${startTime}`);
        const end = new Date(`2000-01-01T${endTime}`);
        const diffMs = end - start;
        const diffHours = diffMs / (1000 * 60 * 60);
        
        if (diffHours > 0) {
            $("#dailyDuration").text(`${diffHours.toFixed(1)} hours`);
        } else {
            $("#dailyDuration").text("Invalid time range");
        }
    }
}

// Update monthly calculation
function updateMonthlyCalculation() {
    const startDate = $("#monthlyStartDate").val();
    const endDate = $("#monthlyEndDate").val();
    
    if (startDate && endDate && servicePrices) {
        const start = new Date(startDate);
        const end = new Date(endDate);
        const diffMs = end - start;
        const diffDays = Math.max(0, diffMs / (1000 * 60 * 60 * 24));
        
        if (diffDays > 0) {
            const monthlyRate = servicePrices.monthly;
            // Calculate price based on months (minimum 1 month)
            const months = Math.max(1, Math.ceil(diffDays / 30));
            const totalAmount = monthlyRate * months;
            
            $("#monthlyDuration").text(`${diffDays.toFixed(0)} days (${months} month${months > 1 ? 's' : ''})`);
            $("#monthlyRate").text(priceFormat(monthlyRate));
            $("#totalDays").text(`${diffDays.toFixed(0)} days`);
            $("#monthlyTotal").text(priceFormat(totalAmount));
        } else {
            $("#monthlyDuration").text("Invalid date range");
            $("#monthlyTotal").text(priceFormat(0));
        }
    }
}

// Handle service confirmation - FIXED
function confirmService() {
    if (!selectedServiceItem || !servicePrices) {
        alert("Service details not loaded. Please try again.");
        return;
    }
    
    let price = 0;
    let startDate = null;
    let endDate = null;
    let serviceType = currentServiceType;
    
    // Calculate based on selected service type using database prices
    switch(currentServiceType) {
        case 'daily':
            price = servicePrices.daily;
            startDate = $("#dailyDate").val();
            endDate = $("#dailyDate").val(); // Same day for daily
            break;
        case 'monthly':
            const start = $("#monthlyStartDate").val();
            const end = $("#monthlyEndDate").val();
            if (!start || !end) {
                alert("Please select both start and end dates for monthly service");
                return;
            }
            const diffMs = new Date(end) - new Date(start);
            const diffDays = diffMs / (1000 * 60 * 60 * 24);
            if (diffDays <= 0) {
                alert("End date must be after start date");
                return;
            }
            // Calculate price based on number of months (minimum 1 month)
            const months = Math.max(1, Math.ceil(diffDays / 30));
            price = servicePrices.monthly * months;
            startDate = start;
            endDate = end;
            break;
        case 'continue':
            price = servicePrices.continuePrice;
            startDate = $("#continueStartDate").val();
            endDate = null; // Continuous has no end date
            break;
        default:
            alert("Please select a service type");
            return;
    }
    
    // Validate required fields
    if (!startDate) {
        alert("Please select a start date");
        return;
    }
    
    // Add to cart with service details
    const serviceItem = {
        id: selectedServiceItem.id,
        name: selectedServiceItem.name,
        price: price,
        image: selectedServiceItem.image,
        qty: 1,
        serviceType: serviceType,
        startDate: startDate,
        endDate: endDate,
        category: 'Services'
    };
    
    cart.push(serviceItem);
    renderCart();
    showNotification(`${selectedServiceItem.name} (${serviceType}) added to cart!`);
    
    // Close modal
    $("#serviceModal").hide();
    resetServiceModal();
}

// Reset service modal
function resetServiceModal() {
    selectedServiceItem = null;
    servicePrices = null;
    currentServiceType = 'daily';
    $(".service-modal-tab").removeClass("active").first().addClass("active");
    $(".service-tab-content").removeClass("active").first().addClass("active");
}

// Add this to your document ready function to fix close button
$(document).ready(function() {
    // Service modal close handlers - FIXED
    $(document).on("click", ".close-service-modal", function(e) {
        e.preventDefault();
        $("#serviceModal").hide();
        resetServiceModal();
    });
    
    // Close modal when clicking outside
    $(document).on("click", "#serviceModal", function(e) {
        if ($(e.target).is("#serviceModal")) {
            $("#serviceModal").hide();
            resetServiceModal();
        }
    });
    
    // Prevent modal close when clicking inside content
    $(document).on("click", ".service-modal-content", function(e) {
        e.stopPropagation();
    });
    
    // Cancel button handler
    $("#cancelService").click(function(e) {
        e.preventDefault();
        $("#serviceModal").hide();
        resetServiceModal();
    });
    
    // Confirm button handler
    $("#confirmService").click(function(e) {
        e.preventDefault();
        confirmService();
    });
    
    // Prevent form submission on Enter key in service modal
    $(".service-modal").on("keydown", function(e) {
        if (e.keyCode === 13) { // Enter key
            e.preventDefault();
            return false;
        }
    });
});    // Render product items with category badges
   // FIXED renderItems function
function renderItems(list) {
    var container = $("#gridItems");
    container.empty();

    if (!list || list.length === 0) {
        container.html('<div class="no-content"><i class="fa fa-box-open"></i><p>No sports products found</p><p class="subtext">Try a different search term or category</p></div>');
        return;
    }

    // Apply sorting
    list.sort((a, b) => {
        switch(currentSort) {
            case "name_asc":
                return a.name.localeCompare(b.name);
            case "name_desc":
                return b.name.localeCompare(a.name);
            case "price_asc":
                return a.price - b.price;
            case "price_desc":
                return b.price - a.price;
            default:
                return a.name.localeCompare(b.name);
        }
    });

    for (var i = 0; i < list.length; i++) {
        var product = list[i];
        var categoryClass = product.category === 'Services' ? 'services' : 'physical';
        var html = `
            <div class="card" data-id="${product.id}">
                <img src="${product.image || 'https://images.unsplash.com/photo-1536922246289-88c42f957773?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80'}" 
                     alt="${product.name}" 
                     onerror="this.src='https://images.unsplash.com/photo-1536922246289-88c42f957773?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80'" />
                <div class="name">${product.name}</div>
                <div class="category-badge ${categoryClass}">${product.category || 'Physical'}</div>
                <div class="price">${priceFormat(product.price)}</div>
            </div>`;

        var $el = $(html);
        $el.on("click", function () {
            const productId = $(this).data('id');
            const product = list.find(p => p.id == productId);
            if (product) {
                if (product.category === 'Services') {
                    showServiceModal(product);
                } else {
                    addToCart(product);
                    $(this).css({
                        'transform': 'scale(0.95)',
                        'border-color': 'var(--success)'
                    });
                    setTimeout(() => {
                        $(this).css({
                            'transform': '',
                            'border-color': ''
                        });
                    }, 300);
                }
            }
        });

        container.append($el);
    }
}

// Also update the priceFormat function to ensure it works
function priceFormat(value) {
    if (!value && value !== 0) return "Rs. 0.00";
    return "Rs. " + parseFloat(value).toLocaleString('en-IN', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    });
}

    // Add item to cart (for physical products only)
    function addToCart(item) {
        var index = cart.findIndex(cartItem => cartItem.id === item.id);

        if (index === -1) {
            cart.push({
                id: item.id,
                name: item.name,
                price: item.price,
                image: item.image,
                category: item.category,
                qty: 1
            });
        } else {
            cart[index].qty++;
        }

        renderCart();
        showNotification(`${item.name} added to cart!`);
    }

    // Show notification
    function showNotification(message) {
        const notification = $(`
            <div style="position:fixed; top:20px; right:20px; background:var(--success); color:white; padding:16px 24px; border-radius:12px; box-shadow:0 8px 25px rgba(39,174,96,0.4); z-index:2000; display:flex; align-items:center; gap:12px; animation:slideInRight 0.3s ease;">
                <i class="fa fa-check-circle"></i>
                <span>${message}</span>
            </div>
        `);

        $("body").append(notification);

        setTimeout(() => {
            notification.animate({ right: '-100%' }, 300, function () {
                $(this).remove();
            });
        }, 3000);
    }

    // Render cart items
    function renderCart() {
        var container = $("#cartItems");
        container.empty();

        if (cart.length === 0) {
            var emptyHtml = '<div class="no-content"><i class="fa fa-shopping-cart"></i><p>Your cart is empty</p><p class="subtext">Add items from the menu</p></div>';
            container.html(emptyHtml);
            updateTotals();
            updateCartCount();
            return;
        }

        for (var i = 0; i < cart.length; i++) {
            var item = cart[i];
            var serviceInfo = '';
            
            // Add service details if applicable
            if (item.category === 'Services' && item.serviceType) {
                serviceInfo = `
                    <div style="font-size:12px; color:#7f8c8d; margin:4px 0;">
                        <span class="category-badge services" style="padding:2px 8px; font-size:10px; margin-right:8px;">
                            ${item.serviceType}
                        </span>
                        ${item.startDate ? `From: ${item.startDate}` : ''}
                        ${item.endDate ? `To: ${item.endDate}` : ''}
                    </div>
                `;
            }
            
            var html = `
                <div class="cart-item" data-id="${item.id}">
                    <img src="${item.image}" alt="${item.name}" />
                    <div class="info">
                        <div>${item.name}</div>
                        <div style="font-size:12px; color:#7f8c8d; margin:4px 0;">
                            <span class="category-badge ${item.category === 'Services' ? 'services' : 'physical'}" style="padding:2px 8px; font-size:10px;">
                                ${item.category || 'Physical'}
                            </span>
                        </div>
                        ${serviceInfo}
                        <div class="price">${priceFormat(item.price)} each</div>
                        <div style="font-size:14px;color:#7f8c8d;margin-top:4px;">Total: ${priceFormat(item.price * item.qty)}</div>
                    </div>
                    <div class="qty">
                        <button onclick="changeQty('${item.id}', -1)"><i class="fa fa-minus"></i></button>
                        <span>${item.qty}</span>
                        <button onclick="changeQty('${item.id}', 1)"><i class="fa fa-plus"></i></button>
                    </div>
                </div>`;
            container.append(html);
        }

        updateTotals();
        updateCartCount();
    }

    // Update cart badge count
    function updateCartCount() {
        var count = cart.reduce(function (sum, item) {
            return sum + item.qty;
        }, 0);
        
        $("#cartCount").text(count);
        $(".cart-badge").text(count);
        $("#navbarCartCount").text(count);

        if (count === 0) {
            $(".cart-badge, #cartCount").hide();
        } else {
            $(".cart-badge, #cartCount").show();
        }
    }

    // Change quantity of an item in cart
    function changeQty(id, delta) {
        var index = cart.findIndex(item => item.id === id);
        if (index === -1) return;

        cart[index].qty += delta;

        if (cart[index].qty <= 0) {
            cart.splice(index, 1);
        }

        renderCart();
    }

    // Calculate total cart price
    function getTotal() {
        var total = cart.reduce(function (sum, item) {
            return sum + (item.price * item.qty);
        }, 0);
        return Math.round(total * 100) / 100;
    }

    // Update totals and member balance display
    function updateTotals() {
        const total = getTotal();
        const balance = member ? (member.balance || 0) : 0;
        const available = balance - total;

        $("#totalPrice").text(priceFormat(total));
        $("#memberBalance").text(priceFormat(balance));
        $("#availableBalance").text(priceFormat(available));

        const availableBalanceEl = $("#availableBalance");
        if (available < 0) {
            availableBalanceEl.css('color', 'var(--danger)');
        } else if (available < 100) {
            availableBalanceEl.css('color', 'var(--warning)');
        } else {
            availableBalanceEl.css('color', 'var(--success)');
        }
    }

    // Submit bill to server
    function submitBill() {
        if (cart.length === 0) {
            alert("Cart is empty!");
            return;
        }
        if (!member) {
            alert("Please select a member first!");
            return;
        }

        const total = getTotal();
        const memberBalance = member.balance || 0;

        if (total > memberBalance) {
            alert("Insufficient member balance!\nTotal: " + priceFormat(total) + "\nAvailable: " + priceFormat(memberBalance));
            return;
        }

        if (!confirm(`Process payment of ${priceFormat(total)}?\nMember: ${member.DisplayName}\n\nClick OK to confirm.`)) {
            return;
        }

        var itemsPayload = [];
        for (var i = 0; i < cart.length; i++) {
            var item = cart[i];
            var payloadItem = {
                MenuItemId: parseInt(item.id, 10),
                Name: item.name,
                Price: parseFloat(item.price),
                Quantity: parseInt(item.qty, 10),
                Category: item.category || "Physical"
            };
            
            // Add service details if applicable
            if (item.category === 'Services') {
                payloadItem.ServiceType = item.serviceType;
                payloadItem.StartDate = item.startDate;
                payloadItem.EndDate = item.endDate;
            }
            
            itemsPayload.push(payloadItem);
        }

        var payload = {
            empID: member.CardNo || "",
            totalAmount: total,
            itemsJson: JSON.stringify(itemsPayload)
        };

        $("#btnSubmit, #btnSubmitMobile").prop("disabled", true).html('<i class="fa fa-spinner fa-spin"></i> Processing...');

        $.ajax({
            type: "POST",
            url: "Pos.aspx/SubmitBill",
            data: JSON.stringify(payload),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (res) {
                var result = res.d;
                if (result && result.success) {
                    showNotification(`Bill #${result.billId} processed successfully!`);

                    if (member) {
                        member.balance = result.remaining;
                        $("#memBalance").text(priceFormat(member.balance));
                    }

                    // Add to history
                    addToHistory(result.billId, total, member.DisplayName);

                    // Clear cart
                    cart = [];
                    renderCart();
                    updateTotals();

                    // Reset member search
                    $("#txtMember").val("");
                    $("#memberBox").hide();
                    member = null;

                    // Refresh active orders
                    if (currentPanelMode === 'active') {
                        loadActiveOrders();
                    }

                } else {
                    alert("Error: " + (result ? result.message : "Unknown error occurred"));
                }
            },
            error: function (xhr) {
                console.error("AJAX error:", xhr.responseText);
                alert("Server error occurred. Please check console for details.");
            },
            complete: function () {
                $("#btnSubmit, #btnSubmitMobile").prop("disabled", false).html('<i class="fa fa-check-circle"></i> Process Payment');
            }
        });
    }

    // Clear cart
    function clearCart() {
        if (cart.length === 0) return;
        if (confirm("Clear all items from cart?")) {
            cart = [];
            renderCart();
        }
    }

    // ==========================================
    // PANEL MANAGEMENT
    // ==========================================

    // Show panel with specific mode
    function showPanel(mode) {
        currentPanelMode = mode;

        // Update panel title
        const titles = {
            'cart': '<i class="fa fa-shopping-cart"></i> Shopping Cart',
            'active': '<i class="fa fa-bolt"></i> Active Orders',
            'history': '<i class="fa fa-history"></i> Order History'
        };
        $("#panelTitle").html(titles[mode]);

        // Update tabs
        $(".panel-tab").removeClass("active");
        $(`.panel-tab[data-content="${mode}"]`).addClass("active");

        // Update content
        $(".panel-content").removeClass("active");
        $(`#${mode}Content`).addClass("active");

        // Load data if needed
        if (mode === 'active') {
            loadActiveOrders();
        } else if (mode === 'history') {
            loadOrderHistory();
        }

        // Show panel
        const $panel = $("#mainPanel");
        const $overlay = $("#panelOverlay");

        $panel.removeAttr("style");
        $panel.addClass("active");
        $overlay.addClass("active");
        $("body").css("overflow", "hidden");
    }

    // Hide panel
    function hidePanel() {
        const $panel = $("#mainPanel");
        const $overlay = $("#panelOverlay");

        $panel.removeClass("active");
        $overlay.removeClass("active");
        $("body").css("overflow", "");
    }

    // Load Active Orders
    function loadActiveOrders() {
        $("#activeOrdersList").html('<div style="text-align:center;padding:40px;color:#94a3b8;"><i class="fa fa-spinner fa-spin fa-2x"></i><p style="margin-top:16px;">Loading active orders...</p></div>');

        $.ajax({
            type: "POST",
            url: "Pos.aspx/GetActiveOrders",
            contentType: "application/json; charset=utf-8",
            data: '{}',
            dataType: "json",
            success: function (response) {
                var orders = response.d || [];
                var html = "";

                if (orders.length === 0) {
                    html = `<div class="no-content"><i class="fa fa-bolt"></i><p>No active orders</p><p class="subtext">All orders are processed</p></div>`;
                } else {
                    $.each(orders, function (i, o) {
                        html += `
                        <div class="order-item">
                            <div class="order-id">
                                <span>Bill #${o.id}</span>
                                <button class="btn-details" data-billid="${o.id}" onclick="showOrderDetails('${o.id}')">
                                    <i class="fa fa-info-circle"></i> Details
                                </button>
                            </div>
                            <div class="order-date">${o.date}</div>
                            <div style="font-weight:600;color:#2c3e50;margin:8px 0;">Member: ${o.memberNo}</div>
                            <div class="order-total">${o.total}</div>
                        </div>`;
                    });
                }

                $("#activeOrdersList").html(html);
            },
            error: function () {
                $("#activeOrdersList").html('<div class="no-content"><i class="fa fa-exclamation-triangle"></i><p>Failed to load orders</p></div>');
            }
        });
    }

    // Show order details
    function showOrderDetails(billId) {
        $("#orderModalBody").html('<div style="text-align:center;padding:20px;"><i class="fa fa-spinner fa-spin fa-2x"></i><p>Loading details...</p></div>');
        $("#orderModal").css("display", "flex");

        $.ajax({
            type: "POST",
            url: "Pos.aspx/GetOrderDetails",
            data: JSON.stringify({ billId: billId }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                const details = response.d || [];
                let html = '';

                if (details.length > 0) {
                    const order = details[0];
                    html = `
                        <div style="background:#f8fff9;padding:20px;border-radius:12px;margin-bottom:20px;">
                            <p><strong>Bill Number:</strong> ${order.id}</p>
                            <p><strong>Date:</strong> ${order.date}</p>
                            <p><strong>Member:</strong> ${order.memberNo}</p>
                            <p><strong>Total Amount:</strong> ${order.total}</p>
                        </div>
                        <h4>Order Items:</h4>
                        <div style="max-height:300px;overflow-y:auto;">`;

                    const itemsMap = {};
                    details.forEach(item => {
                        if (!itemsMap[item.item]) {
                            itemsMap[item.item] = {
                                name: item.item,
                                price: item.price,
                                quantity: 1
                            };
                        } else {
                            itemsMap[item.item].quantity++;
                        }
                    });

                    Object.values(itemsMap).forEach(item => {
                        html += `
                            <div style="display:flex;justify-content:space-between;padding:12px;border-bottom:1px solid #eee;">
                                <span>${item.name}</span>
                                <span>${item.price} × ${item.quantity}</span>
                            </div>`;
                    });

                    html += '</div>';
                } else {
                    html = '<p style="text-align:center;color:#7f8c8d;">No details found for this order.</p>';
                }

                $("#orderModalBody").html(html);
            },
            error: function () {
                $("#orderModalBody").html('<p style="color:var(--danger);text-align:center;">Error loading order details.</p>');
            }
        });
    }

    // Load Order History
    function loadOrderHistory() {
        $("#historyList").html('<div style="text-align:center;padding:40px;color:#94a3b8;"><i class="fa fa-spinner fa-spin fa-2x"></i><p style="margin-top:16px;">Loading history...</p></div>');

        let history = JSON.parse(localStorage.getItem('orderHistory') || '[]');

        if (history.length === 0) {
            history = [
                {
                    id: "999",
                    date: new Date(Date.now() - 86400000).toLocaleString('en-US', {
                        weekday: 'short',
                        month: 'short',
                        day: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit'
                    }),
                    member: "John Doe",
                    total: "Rs. 2500.00"
                },
                {
                    id: "998",
                    date: new Date(Date.now() - 172800000).toLocaleString('en-US', {
                        weekday: 'short',
                        month: 'short',
                        day: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit'
                    }),
                    member: "Jane Smith",
                    total: "Rs. 4180.50"
                },
                {
                    id: "997",
                    date: new Date(Date.now() - 259200000).toLocaleString('en-US', {
                        weekday: 'short',
                        month: 'short',
                        day: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit'
                    }),
                    member: "Guest",
                    total: "Rs. 6320.75"
                }
            ];
        }

        displayOrderHistory(history);
    }

    function displayOrderHistory(history) {
        var container = $("#historyList");
        container.empty();

        if (!history || history.length === 0) {
            container.html('<div class="no-content"><i class="fa fa-history"></i><p>No order history</p><p class="subtext">Your order history will appear here</p></div>');
            return;
        }

        history.sort((a, b) => new Date(b.date) - new Date(a.date));

        for (var i = 0; i < Math.min(history.length, 10); i++) {
            var item = history[i];
            var html = `
                <div class="history-item">
                    <div class="history-id">Bill #${item.id}</div>
                    <div class="history-date">${item.date}</div>
                    <div style="color:#92400e;font-weight:600;font-size:15px;margin:8px 0;">${item.member}</div>
                    <div class="history-total">${item.total}</div>
                </div>`;
            container.append(html);
        }
    }

    // Add to history when bill is submitted
    function addToHistory(billId, amount, memberName) {
        var history = JSON.parse(localStorage.getItem('orderHistory') || '[]');
        var newEntry = {
            id: billId,
            date: new Date().toLocaleString('en-US', {
                weekday: 'short',
                year: 'numeric',
                month: 'short',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            }),
            member: memberName,
            total: priceFormat(amount)
        };

        history.unshift(newEntry);
        if (history.length > 20) {
            history = history.slice(0, 20);
        }

        localStorage.setItem('orderHistory', JSON.stringify(history));

        if (currentPanelMode === 'history' && $("#mainPanel").hasClass("active")) {
            loadOrderHistory();
        }
    }

    // Initialize
    $(document).ready(function () {
        updateCartCount();
        
        // Load departments first
        fetchDepartments();

        // Event handlers
        $("#btnSubmit, #btnSubmitMobile").click(submitBill);
        $("#btnClear, #btnClearMobile").click(clearCart);

        $("#btnReload").click(function () {
            $(this).css('transform', 'rotate(360deg)');
            setTimeout(() => {
                $(this).css('transform', '');
            }, 300);
            fetchProducts("", currentCategory, currentDept, currentSort);
            $("#txtSearch").val("");
        });

        // Panel controls
        $("#desktopCartBtn").click(function (e) {
            e.preventDefault();
            showPanel('cart');
        });

        $("#activeOrdersBtn").click(function (e) {
            e.preventDefault();
            showPanel('active');
        });

        $("#mobileCartBtn").click(function (e) {
            e.preventDefault();
            showPanel('cart');
        });

        $("#closePanel").click(function (e) {
            e.preventDefault();
            hidePanel();
        });

        $("#panelOverlay").click(function (e) {
            e.preventDefault();
            hidePanel();
        });

        // Panel tab switching
        $(".panel-tab").click(function (e) {
            e.preventDefault();
            var content = $(this).data("content");
            showPanel(content);
        });

        // Close modal
        $(document).on("click", ".close-modal, #orderModal", function (e) {
            if ($(e.target).is("#orderModal") || $(e.target).hasClass("close-modal")) {
                $("#orderModal").hide();
            }
        });

        // Service modal handlers
        $(document).on("click", ".close-service-modal, #serviceModal", function(e) {
            if ($(e.target).is("#serviceModal") || $(e.target).hasClass("close-service-modal")) {
                $("#serviceModal").hide();
                resetServiceModal();
                e.stopPropagation();
            }
        });

        $("#cancelService").click(function() {
            $("#serviceModal").hide();
            resetServiceModal();
        });

        $("#confirmService").click(confirmService);

        // Prevent modal close when clicking inside
        $("#mainPanel, .service-modal-content, .modal-content").click(function (e) {
            e.stopPropagation();
        });

        // Keyboard shortcuts
        $(document).keydown(function (e) {
            if (e.keyCode === 27) { // ESC key
                if ($("#mainPanel").hasClass("active")) {
                    hidePanel();
                }
                if ($("#orderModal").is(":visible")) {
                    $("#orderModal").hide();
                }
                if ($("#serviceModal").is(":visible")) {
                    $("#serviceModal").hide();
                    resetServiceModal();
                }
            }

            if (e.ctrlKey && e.keyCode === 70) { // Ctrl+F
                e.preventDefault();
                $("#txtSearch").focus();
            }
        });

        // Focus on member field on page load
        setTimeout(() => {
            $("#txtMember").focus();
        }, 500);

        // Initialize data
        fetchProducts("", currentCategory, currentDept, currentSort);
        renderCart();

        // Handle window resize
        let resizeTimer;
        $(window).resize(function () {
            clearTimeout(resizeTimer);
            resizeTimer = setTimeout(function () {
                const width = $(window).width();

                if (width > 1024) {
                    $("body").css("overflow", "");
                } else if (width <= 768) {
                    $("body").css("overflow", "auto");
                } else {
                    $("body").css("overflow", "auto");
                }

                $(".grid").trigger("scroll");
            }, 250);
        });
        
        // Scroll to top button
        $(window).scroll(function() {
            if ($(this).scrollTop() > 300) {
                $('.scroll-top-btn').addClass('visible');
            } else {
                $('.scroll-top-btn').removeClass('visible');
            }
        });
        
        $('.scroll-top-btn').click(function() {
            $('html, body').animate({scrollTop: 0}, 300);
        });
    });


</script>
</form>
</body>
</html>