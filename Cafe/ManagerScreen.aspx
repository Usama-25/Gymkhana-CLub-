<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ManagerScreen.aspx.cs" Inherits="ManagerScreen" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Restaurant Manager Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #2c3e50;
            --secondary: #3498db;
            --success: #27ae60;
            --warning: #f39c12;
            --danger: #e74c3c;
            --light: #ecf0f1;
            --dark: #2c3e50;
            --gray: #95a5a6;
            --border-radius: 8px;
            --box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            --transition: all 0.3s ease;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: #f5f7fa;
            color: #333;
            min-height: 100vh;
        }

        .container {
            display: grid;
            grid-template-columns: 250px 1fr;
            min-height: 100vh;
        }

        /* Sidebar */
        .sidebar {
            background: var(--primary);
            color: white;
            padding: 20px 0;
            position: sticky;
            top: 0;
            height: 100vh;
        }

        .logo {
            text-align: center;
            padding: 20px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            margin-bottom: 30px;
        }

        .logo h2 {
            font-size: 22px;
            font-weight: 600;
        }

        .logo span {
            color: var(--secondary);
        }

        .nav-menu {
            list-style: none;
        }

        .nav-menu li {
            margin-bottom: 5px;
        }

        .nav-menu a {
            display: flex;
            align-items: center;
            padding: 15px 25px;
            color: rgba(255,255,255,0.8);
            text-decoration: none;
            transition: var(--transition);
        }

        .nav-menu a:hover,
        .nav-menu a.active {
            background: rgba(52, 152, 219, 0.2);
            color: white;
            border-left: 4px solid var(--secondary);
        }

        .nav-menu i {
            margin-right: 12px;
            font-size: 18px;
            width: 24px;
            text-align: center;
        }

        /* Main Content */
        .main-content {
            padding: 20px;
            overflow-y: auto;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #e0e6ef;
        }

        .header h1 {
            color: var(--primary);
            font-size: 28px;
            font-weight: 600;
        }

        .header-controls {
            display: flex;
            gap: 15px;
            align-items: center;
        }

        .date-time {
            background: white;
            padding: 10px 20px;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            font-weight: 500;
        }

        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            padding: 25px;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            display: flex;
            align-items: center;
            transition: var(--transition);
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }

        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 20px;
            font-size: 24px;
        }

        .stat-sales .stat-icon { background: #e3f2fd; color: var(--secondary); }
        .stat-orders .stat-icon { background: #e8f5e9; color: var(--success); }
        .stat-active .stat-icon { background: #fff3e0; color: var(--warning); }
        .stat-delivery .stat-icon { background: #fce4ec; color: #e91e63; }

        .stat-info h3 {
            font-size: 12px;
            text-transform: uppercase;
            color: var(--gray);
            margin-bottom: 5px;
            letter-spacing: 1px;
        }

        .stat-value {
            font-size: 28px;
            font-weight: 600;
            color: var(--primary);
        }

        .stat-change {
            font-size: 12px;
            margin-top: 5px;
        }

        .positive { color: var(--success); }
        .negative { color: var(--danger); }

        /* Sections */
        .section {
            background: white;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            margin-bottom: 30px;
            overflow: hidden;
        }

        .section-header {
            padding: 20px 25px;
            border-bottom: 1px solid #e0e6ef;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .section-header h2 {
            color: var(--primary);
            font-size: 20px;
            font-weight: 600;
        }

        .section-controls {
            display: flex;
            gap: 10px;
        }

        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            font-family: 'Poppins', sans-serif;
            font-weight: 500;
            cursor: pointer;
            transition: var(--transition);
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-primary {
            background: var(--secondary);
            color: white;
        }

        .btn-primary:hover {
            background: #2980b9;
        }

        .btn-outline {
            background: transparent;
            border: 1px solid var(--secondary);
            color: var(--secondary);
        }

        .btn-outline:hover {
            background: var(--secondary);
            color: white;
        }

        /* Tables */
        .table-container {
            overflow-x: auto;
        }

        .data-table {
            width: 100%;
            border-collapse: collapse;
        }

        .data-table th {
            background: #f8f9fa;
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: var(--primary);
            border-bottom: 1px solid #e0e6ef;
        }

        .data-table td {
            padding: 15px;
            border-bottom: 1px solid #e0e6ef;
        }

        .data-table tr:hover {
            background: #f8f9fa;
        }

        /* Status Badges */
        .status-badge {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            display: inline-block;
        }

        .status-pending { background: #fff3e0; color: #f57c00; }
        .status-preparing { background: #e3f2fd; color: #1976d2; }
        .status-ready { background: #e8f5e9; color: #388e3c; }
        .status-completed { background: #f3e5f5; color: #7b1fa2; }
        .status-cancelled { background: #ffebee; color: #d32f2f; }

        /* Action Buttons */
        .action-btn {
            background: transparent;
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 6px 12px;
            cursor: pointer;
            transition: var(--transition);
            margin: 0 2px;
        }

        .action-btn:hover {
            background: #f5f5f5;
        }

        .action-btn.view { color: var(--secondary); }
        .action-btn.edit { color: var(--warning); }
        .action-btn.delete { color: var(--danger); }

        /* Charts */
        .charts-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 30px;
        }

        .chart-container {
            background: white;
            padding: 25px;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
        }

        .chart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .chart-header h3 {
            color: var(--primary);
            font-size: 18px;
            font-weight: 600;
        }

        .chart-placeholder {
            height: 250px;
            background: #f8f9fa;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--gray);
            font-size: 14px;
        }

        /* Modal */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0,0,0,0.5);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 1000;
        }

        .modal {
            background: white;
            border-radius: var(--border-radius);
            width: 90%;
            max-width: 800px;
            max-height: 90vh;
            overflow-y: auto;
        }

        .modal-header {
            padding: 20px 25px;
            border-bottom: 1px solid #e0e6ef;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-header h3 {
            color: var(--primary);
            font-size: 20px;
        }

        .modal-close {
            background: transparent;
            border: none;
            font-size: 24px;
            cursor: pointer;
            color: var(--gray);
        }

        .modal-body {
            padding: 25px;
        }

        /* Responsive */
        @media (max-width: 1200px) {
            .charts-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .container {
                grid-template-columns: 1fr;
            }
            
            .sidebar {
                display: none;
            }
            
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 576px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .header {
                flex-direction: column;
                gap: 15px;
                align-items: flex-start;
            }
        }

        /* Refresh Animation */
        .refresh-btn {
            background: transparent;
            border: none;
            color: var(--secondary);
            font-size: 18px;
            cursor: pointer;
            transition: transform 0.3s ease;
        }

        .refresh-btn:hover {
            transform: rotate(180deg);
        }

        /* Filter Controls */
        .filter-controls {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }

        .filter-select {
            padding: 8px 15px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-family: 'Poppins', sans-serif;
        }

        /* Loading */
        .loading {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid #f3f3f3;
            border-top: 3px solid var(--secondary);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
        
        <div class="container">
            <!-- Sidebar -->
            <aside class="sidebar">
                <div class="logo">
                    <h2>Restaurant<span>Pro</span></h2>
                    <p style="font-size: 12px; opacity: 0.7; margin-top: 5px;">Manager Dashboard</p>
                </div>
                
                <ul class="nav-menu">
                    <li>
                        <a href="#" class="active" onclick="showSection('dashboard')">
                            <i class="fas fa-chart-line"></i>
                            <span>Dashboard</span>
                        </a>
                    </li>
                    <li>
                        <a href="#" onclick="showSection('orders')">
                            <i class="fas fa-shopping-cart"></i>
                            <span>Orders</span>
                            <span class="badge" id="orderBadge" style="margin-left: auto; background: var(--warning); color: white; padding: 2px 8px; border-radius: 10px; font-size: 12px;">0</span>
                        </a>
                    </li>
                    <li>
                        <a href="#" onclick="showSection('kitchen')">
                            <i class="fas fa-utensils"></i>
                            <span>Kitchen Monitor</span>
                        </a>
                    </li>
                    <li>
                        <a href="#" onclick="showSection('staff')">
                            <i class="fas fa-users"></i>
                            <span>Staff Performance</span>
                        </a>
                    </li>
                    <li>
                        <a href="#" onclick="showSection('delivery')">
                            <i class="fas fa-shipping-fast"></i>
                            <span>Delivery Tracking</span>
                        </a>
                    </li>
                    <li>
                        <a href="#" onclick="showSection('reports')">
                            <i class="fas fa-chart-bar"></i>
                            <span>Reports</span>
                        </a>
                    </li>
                    <li style="margin-top: 30px;">
                        <a href="#" onclick="logout()">
                            <i class="fas fa-sign-out-alt"></i>
                            <span>Logout</span>
                        </a>
                    </li>
                </ul>
                
                <div style="position: absolute; bottom: 20px; left: 0; right: 0; text-align: center; color: rgba(255,255,255,0.5); font-size: 12px;">
                    <p>Restaurant POS v2.0</p>
                </div>
            </aside>
            
            <!-- Main Content -->
            <main class="main-content">
                <!-- Header -->
                <header class="header">
                    <div>
                        <h1>Manager Dashboard</h1>
                        <p style="color: var(--gray); margin-top: 5px;">Real-time restaurant management overview</p>
                    </div>
                    
                    <div class="header-controls">
                        <div class="date-time">
                            <i class="far fa-calendar"></i>
                            <span id="currentDateTime"></span>
                        </div>
                        <button class="refresh-btn" onclick="loadDashboardData()" title="Refresh Data">
                            <i class="fas fa-sync-alt"></i>
                        </button>
                    </div>
                </header>
                
                <!-- Stats Cards -->
                <div class="stats-grid">
                    <div class="stat-card stat-sales">
                        <div class="stat-icon">
                            <i class="fas fa-rupee-sign"></i>
                        </div>
                        <div class="stat-info">
                            <h3>Today's Sales</h3>
                            <div class="stat-value" id="todaySales">RS0.00</div>
                            <div class="stat-change positive" id="salesChange">Loading...</div>
                        </div>
                    </div>
                    
                    <div class="stat-card stat-orders">
                        <div class="stat-icon">
                            <i class="fas fa-receipt"></i>
                        </div>
                        <div class="stat-info">
                            <h3>Total Orders</h3>
                            <div class="stat-value" id="totalOrders">0</div>
                            <div class="stat-change" id="ordersChange">Today: 0</div>
                        </div>
                    </div>
                    
                    <div class="stat-card stat-active">
                        <div class="stat-icon">
                            <i class="fas fa-clock"></i>
                        </div>
                        <div class="stat-info">
                            <h3>Active Orders</h3>
                            <div class="stat-value" id="activeOrders">0</div>
                            <div class="stat-change warning" id="activeStatus">Monitoring...</div>
                        </div>
                    </div>
                    
                    <div class="stat-card stat-delivery">
                        <div class="stat-icon">
                            <i class="fas fa-truck"></i>
                        </div>
                        <div class="stat-info">
                            <h3>Pending Delivery</h3>
                            <div class="stat-value" id="pendingDelivery">0</div>
                            <div class="stat-change" id="deliveryStatus">On-time</div>
                        </div>
                    </div>
                </div>
                
                <!-- Charts Section -->
                <div class="charts-grid">
                    <div class="chart-container">
                        <div class="chart-header">
                            <h3>Sales Overview (Today)</h3>
                            <select class="filter-select" onchange="updateChart()">
                                <option>Today</option>
                                <option>This Week</option>
                                <option>This Month</option>
                            </select>
                        </div>
                        <div class="chart-placeholder">
                            <i class="fas fa-chart-area" style="font-size: 48px; opacity: 0.3; margin-right: 15px;"></i>
                            <span>Sales chart will appear here</span>
                        </div>
                    </div>
                    
                    <div class="chart-container">
                        <div class="chart-header">
                            <h3>Order Status Distribution</h3>
                        </div>
                        <div class="chart-placeholder">
                            <i class="fas fa-chart-pie" style="font-size: 48px; opacity: 0.3; margin-right: 15px;"></i>
                            <span>Order status chart will appear here</span>
                        </div>
                    </div>
                </div>
                
                <!-- Orders Section -->
                <section class="section" id="ordersSection" style="display: none;">
                    <div class="section-header">
                        <h2>Recent Orders</h2>
                        <div class="section-controls">
                            <div class="filter-controls">
                                <select class="filter-select" id="statusFilter">
                                    <option value="">All Status</option>
                                    <option value="Pending">Pending</option>
                                    <option value="Preparing">Preparing</option>
                                    <option value="Ready">Ready</option>
                                    <option value="Completed">Completed</option>
                                    <option value="Cancelled">Cancelled</option>
                                </select>
                                <select class="filter-select" id="waiterFilter">
                                    <option value="">All Waiters</option>
                                </select>
                                <input type="date" class="filter-select" id="dateFilter">
                            </div>
                            <button class="btn btn-primary" onclick="exportOrders()">
                                <i class="fas fa-download"></i> Export
                            </button>
                        </div>
                    </div>
                    
                    <div class="table-container">
                        <table class="data-table" id="ordersTable">
                            <thead>
                                <tr>
                                    <th>Order ID</th>
                                    <th>Table</th>
                                    <th>Waiter</th>
                                    <th>Total</th>
                                    <th>Status</th>
                                    <th>Time</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="ordersTableBody">
                                <!-- Orders will be loaded here -->
                                <tr>
                                    <td colspan="7" style="text-align: center; padding: 50px;">
                                        <div class="loading"></div>
                                        <p style="margin-top: 10px;">Loading orders...</p>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </section>
                
                <!-- Kitchen Monitor Section -->
                <section class="section" id="kitchenSection" style="display: none;">
                    <div class="section-header">
                        <h2>Kitchen Monitor</h2>
                        <div class="section-controls">
                            <button class="btn btn-outline" onclick="refreshKitchen()">
                                <i class="fas fa-sync-alt"></i> Refresh
                            </button>
                        </div>
                    </div>
                    
                    <div class="table-container">
                        <table class="data-table" id="kitchenTable">
                            <thead>
                                <tr>
                                    <th>Order ID</th>
                                    <th>Item</th>
                                    <th>Quantity</th>
                                    <th>Prep Status</th>
                                    <th>Prep Time</th>
                                    <th>Notes</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="kitchenTableBody">
                                <!-- Kitchen items will be loaded here -->
                            </tbody>
                        </table>
                    </div>
                </section>
                
                <!-- Staff Performance Section -->
                <section class="section" id="staffSection" style="display: none;">
                    <div class="section-header">
                        <h2>Staff Performance</h2>
                        <div class="section-controls">
                            <select class="filter-select" id="staffPeriod">
                                <option>Today</option>
                                <option>This Week</option>
                                <option>This Month</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="table-container">
                        <table class="data-table" id="staffTable">
                            <thead>
                                <tr>
                                    <th>Waiter</th>
                                    <th>Orders</th>
                                    <th>Total Sales</th>
                                    <th>Avg. Order</th>
                                    <th>Cancelled</th>
                                    <th>Performance</th>
                                </tr>
                            </thead>
                            <tbody id="staffTableBody">
                                <!-- Staff data will be loaded here -->
                            </tbody>
                        </table>
                    </div>
                </section>
                
                <!-- Delivery Tracking Section -->
                <section class="section" id="deliverySection" style="display: none;">
                    <div class="section-header">
                        <h2>Delivery Tracking</h2>
                        <div class="section-controls">
                            <button class="btn btn-outline" onclick="loadDeliveryData()">
                                <i class="fas fa-sync-alt"></i> Refresh
                            </button>
                        </div>
                    </div>
                    
                    <div class="table-container">
                        <table class="data-table" id="deliveryTable">
                            <thead>
                                <tr>
                                    <th>Bill ID</th>
                                    <th>Member No</th>
                                    <th>Status</th>
                                    <th>Delivered By</th>
                                    <th>Time</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="deliveryTableBody">
                                <!-- Delivery data will be loaded here -->
                            </tbody>
                        </table>
                    </div>
                </section>
                
                <!-- Reports Section -->
                <section class="section" id="reportsSection" style="display: none;">
                    <div class="section-header">
                        <h2>Reports</h2>
                        <div class="section-controls">
                            <button class="btn btn-primary" onclick="generateDailyReport()">
                                <i class="fas fa-file-pdf"></i> Daily Report
                            </button>
                            <button class="btn btn-outline" onclick="generateSalesReport()">
                                <i class="fas fa-file-excel"></i> Sales Report
                            </button>
                        </div>
                    </div>
                    
                    <div style="padding: 25px;">
                        <div class="filter-controls">
                            <input type="date" class="filter-select" id="reportFrom">
                            <span style="margin: 0 10px;">to</span>
                            <input type="date" class="filter-select" id="reportTo">
                            <select class="filter-select" id="reportType">
                                <option value="sales">Sales Report</option>
                                <option value="items">Top Items</option>
                                <option value="staff">Staff Performance</option>
                                <option value="delivery">Delivery Report</option>
                            </select>
                            <button class="btn btn-primary" onclick="generateReport()">
                                <i class="fas fa-play"></i> Generate
                            </button>
                        </div>
                        
                        <div id="reportResults" style="margin-top: 30px;">
                            <!-- Report results will appear here -->
                        </div>
                    </div>
                </section>
            </main>
        </div>
        
        <!-- Order Details Modal -->
        <div class="modal-overlay" id="orderModal">
            <div class="modal">
                <div class="modal-header">
                    <h3>Order Details - #<span id="modalOrderId"></span></h3>
                    <button class="modal-close" onclick="closeModal()">&times;</button>
                </div>
                <div class="modal-body">
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
                        <div>
                            <h4>Order Information</h4>
                            <table style="width: 100%;">
                                <tr><td><strong>Table:</strong></td><td id="modalTable"></td></tr>
                                <tr><td><strong>Waiter:</strong></td><td id="modalWaiter"></td></tr>
                                <tr><td><strong>Member No:</strong></td><td id="modalMember"></td></tr>
                                <tr><td><strong>Created:</strong></td><td id="modalCreated"></td></tr>
                            </table>
                        </div>
                        <div>
                            <h4>Status Control</h4>
                            <select class="filter-select" id="modalStatus" style="width: 100%; margin-bottom: 15px;">
                                <option value="Pending">Pending</option>
                                <option value="Preparing">Preparing</option>
                                <option value="Ready">Ready</option>
                                <option value="Completed">Completed</option>
                                <option value="Cancelled">Cancelled</option>
                            </select>
                            <button class="btn btn-primary" onclick="updateOrderStatus()" style="width: 100%;">
                                Update Status
                            </button>
                        </div>
                    </div>
                    
                    <h4>Order Items</h4>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Item</th>
                                <th>Qty</th>
                                <th>Price</th>
                                <th>Total</th>
                                <th>Prep Status</th>
                            </tr>
                        </thead>
                        <tbody id="modalItems">
                            <!-- Items will be loaded here -->
                        </tbody>
                    </table>
                    
                    <div style="text-align: right; margin-top: 20px; font-size: 18px;">
                        <strong>Total: RS<span id="modalTotal">0.00</span></strong>
                    </div>
                </div>
            </div>
        </div>
        
        <script>
            // Global variables
            let currentSection = 'dashboard';
            let ordersData = [];

            // Initialize page
            document.addEventListener('DOMContentLoaded', function () {
                updateDateTime();
                setInterval(updateDateTime, 1000);
                loadDashboardData();
                loadOrders();

                // Auto-refresh every 30 seconds
                setInterval(loadDashboardData, 30000);
                setInterval(loadOrders, 30000);
            });

            // Update current date and time
            function updateDateTime() {
                const now = new Date();
                const options = {
                    weekday: 'long',
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit'
                };
                document.getElementById('currentDateTime').textContent =
                    now.toLocaleDateString('en-US', options);
            }

            // Show section
            function showSection(sectionId) {
                // Hide all sections
                document.getElementById('ordersSection').style.display = 'none';
                document.getElementById('kitchenSection').style.display = 'none';
                document.getElementById('staffSection').style.display = 'none';
                document.getElementById('deliverySection').style.display = 'none';
                document.getElementById('reportsSection').style.display = 'none';

                // Update active nav
                document.querySelectorAll('.nav-menu a').forEach(a => a.classList.remove('active'));
                event.target.closest('a').classList.add('active');

                // Show selected section
                if (sectionId === 'dashboard') {
                    // Dashboard is already visible
                    return;
                } else {
                    document.getElementById(sectionId + 'Section').style.display = 'block';
                    currentSection = sectionId;

                    // Load section data
                    switch (sectionId) {
                        case 'orders':
                            loadOrders();
                            break;
                        case 'kitchen':
                            loadKitchenData();
                            break;
                        case 'staff':
                            loadStaffData();
                            break;
                        case 'delivery':
                            loadDeliveryData();
                            break;
                        case 'reports':
                            // Reports section doesn't need auto-load
                            break;
                    }
                }
            }

            // Load dashboard data
            function loadDashboardData() {
                // Show loading state
                document.getElementById('todaySales').innerHTML = '<div class="loading"></div>';

                // Call server method
                PageMethods.GetDashboardData(onDashboardSuccess, onDashboardError);
            }

            function onDashboardSuccess(result) {
                const data = JSON.parse(result);

                // Update stats
                document.getElementById('todaySales').textContent = '' + data.TodaySales.toFixed(2);
                document.getElementById('totalOrders').textContent = data.TotalOrders;
                document.getElementById('activeOrders').textContent = data.ActiveOrders;
                document.getElementById('pendingDelivery').textContent = data.PendingDelivery;

                // Update badge
                document.getElementById('orderBadge').textContent = data.ActiveOrders;

                // Update changes
                document.getElementById('salesChange').textContent = 'vs yesterday: ' +
                    (data.SalesChange >= 0 ? '+' : '') + data.SalesChange.toFixed(2) + '%';
                document.getElementById('salesChange').className = data.SalesChange >= 0 ? 'stat-change positive' : 'stat-change negative';

                document.getElementById('ordersChange').textContent = 'Today: ' + data.TodayOrders;
            }

            function onDashboardError(error) {
                console.error('Error loading dashboard:', error);
                // Set default values
                document.getElementById('todaySales').textContent = 'Rs 0.00';
                document.getElementById('totalOrders').textContent = '0';
                document.getElementById('activeOrders').textContent = '0';
                document.getElementById('pendingDelivery').textContent = '0';
            }

            // Load orders
            function loadOrders() {
                const status = document.getElementById('statusFilter').value;
                const waiter = document.getElementById('waiterFilter').value;
                const date = document.getElementById('dateFilter').value;

                PageMethods.GetOrders(status, waiter, date, onOrdersSuccess, onOrdersError);
            }

            function onOrdersSuccess(result) {
                const orders = JSON.parse(result);
                ordersData = orders;

                const tbody = document.getElementById('ordersTableBody');
                tbody.innerHTML = '';

                if (orders.length === 0) {
                    tbody.innerHTML = `
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 50px;">
                                <i class="fas fa-clipboard-list" style="font-size: 48px; color: var(--gray); margin-bottom: 15px;"></i>
                                <p>No orders found</p>
                            </td>
                        </tr>
                    `;
                    return;
                }

                orders.forEach(order => {
                    const row = document.createElement('tr');
                    const created = new Date(order.CreatedAt);
                    const timeStr = created.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

                    row.innerHTML = `
                        <td>#${order.Id}</td>
                        <td>${order.TableNumber || 'Takeaway'}</td>
                        <td>${order.WaiterName || 'N/A'}</td>
                        <td>$${order.Total.toFixed(2)}</td>
                        <td><span class="status-badge status-${order.Status.toLowerCase()}">${order.Status}</span></td>
                        <td>${timeStr}</td>
                        <td>
                            <button class="action-btn view" onclick="viewOrder(${order.Id})" title="View Details">
                                <i class="fas fa-eye"></i>
                            </button>
                            ${order.Status === 'Pending' ? `
                            <button class="action-btn edit" onclick="editOrder(${order.Id})" title="Edit">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="action-btn delete" onclick="cancelOrder(${order.Id})" title="Cancel">
                                <i class="fas fa-times"></i>
                            </button>
                            ` : ''}
                        </td>
                    `;
                    tbody.appendChild(row);
                });
            }

            function onOrdersError(error) {
                console.error('Error loading orders:', error);
                document.getElementById('ordersTableBody').innerHTML = `
                    <tr>
                        <td colspan="7" style="text-align: center; color: var(--danger); padding: 30px;">
                            <i class="fas fa-exclamation-triangle" style="font-size: 24px; margin-bottom: 10px;"></i>
                            <p>Error loading orders</p>
                        </td>
                    </tr>
                `;
            }

            // View order details
            function viewOrder(orderId) {
                PageMethods.GetOrderDetails(orderId, function (result) {
                    const data = JSON.parse(result);

                    document.getElementById('modalOrderId').textContent = data.order.Id;
                    document.getElementById('modalTable').textContent = data.order.TableNumber || 'Takeaway';
                    document.getElementById('modalWaiter').textContent = data.order.WaiterName || 'N/A';
                    document.getElementById('modalMember').textContent = data.order.MemberNo || 'N/A';
                    document.getElementById('modalCreated').textContent = new Date(data.order.CreatedAt).toLocaleString();
                    document.getElementById('modalTotal').textContent = data.order.Total.toFixed(2);
                    document.getElementById('modalStatus').value = data.order.Status;

                    // Load items
                    const itemsTbody = document.getElementById('modalItems');
                    itemsTbody.innerHTML = '';

                    data.items.forEach(item => {
                        const row = document.createElement('tr');
                        row.innerHTML = `
                            <td>${item.Name}</td>
                            <td>${item.Quantity}</td>
                            <td>RS ${item.Price.toFixed(2)}</td>
                            <td>RS ${item.LineTotal.toFixed(2)}</td>
                            <td><span class="status-badge status-${item.IsPrep.toLowerCase()}">${item.IsPrep}</span></td>
                        `;
                        itemsTbody.appendChild(row);
                    });

                    // Show modal
                    document.getElementById('orderModal').style.display = 'flex';
                }, function (error) {
                    alert('Error loading order details: ' + error);
                });
            }

            // Update order status
            function updateOrderStatus() {
                const orderId = document.getElementById('modalOrderId').textContent;
                const status = document.getElementById('modalStatus').value;

                PageMethods.UpdateOrderStatus(orderId, status, function (result) {
                    if (result === 'success') {
                        alert('Status updated successfully');
                        closeModal();
                        loadOrders();
                        loadDashboardData();
                    } else {
                        alert('Error updating status');
                    }
                }, function (error) {
                    alert('Error: ' + error);
                });
            }

            // Close modal
            function closeModal() {
                document.getElementById('orderModal').style.display = 'none';
            }

            // Load kitchen data
            function loadKitchenData() {
                PageMethods.GetKitchenData(function (result) {
                    const items = JSON.parse(result);
                    const tbody = document.getElementById('kitchenTableBody');
                    tbody.innerHTML = '';

                    items.forEach(item => {
                        const row = document.createElement('tr');
                        const prepTime = item.PrepTime ? new Date(item.PrepTime).toLocaleTimeString() : 'N/A';

                        row.innerHTML = `
                            <td>#${item.BillId}</td>
                            <td>${item.Name}</td>
                            <td>${item.Quantity}</td>
                            <td><span class="status-badge status-${item.IsPrep.toLowerCase()}">${item.IsPrep}</span></td>
                            <td>${prepTime}</td>
                            <td>${item.Notes || ''}</td>
                            <td>
                                <button class="action-btn edit" onclick="updatePrepStatus(${item.Id}, 'Preparing')" title="Start Prep">
                                    <i class="fas fa-play"></i>
                                </button>
                                <button class="action-btn view" onclick="updatePrepStatus(${item.Id}, 'Ready')" title="Mark Ready">
                                    <i class="fas fa-check"></i>
                                </button>
                            </td>
                        `;
                        tbody.appendChild(row);
                    });
                }, function (error) {
                    console.error('Error loading kitchen data:', error);
                });
            }

            // Load staff data
            function loadStaffData() {
                const period = document.getElementById('staffPeriod').value;
                PageMethods.GetStaffPerformance(period, function (result) {
                    const staff = JSON.parse(result);
                    const tbody = document.getElementById('staffTableBody');
                    tbody.innerHTML = '';

                    staff.forEach(employee => {
                        const row = document.createElement('tr');
                        row.innerHTML = `
                            <td>${employee.WaiterName}</td>
                            <td>${employee.OrderCount}</td>
                            <td>$${employee.TotalSales.toFixed(2)}</td>
                            <td>$${employee.AverageOrder.toFixed(2)}</td>
                            <td>${employee.CancelledOrders}</td>
                            <td>
                                <div style="background: #e0e0e0; border-radius: 10px; height: 10px; width: 100%;">
                                    <div style="background: ${getPerformanceColor(employee.Performance)}; 
                                                width: ${employee.Performance}%; 
                                                height: 100%; 
                                                border-radius: 10px;"></div>
                                </div>
                                <small>${employee.Performance}%</small>
                            </td>
                        `;
                        tbody.appendChild(row);
                    });
                }, function (error) {
                    console.error('Error loading staff data:', error);
                });
            }

            function getPerformanceColor(percentage) {
                if (percentage >= 80) return '#27ae60';
                if (percentage >= 60) return '#f39c12';
                return '#e74c3c';
            }

            // Load delivery data
            function loadDeliveryData() {
                PageMethods.GetDeliveryData(function (result) {
                    const deliveries = JSON.parse(result);
                    const tbody = document.getElementById('deliveryTableBody');
                    tbody.innerHTML = '';

                    deliveries.forEach(delivery => {
                        const row = document.createElement('tr');
                        const time = delivery.DeliveredAt ?
                            new Date(delivery.DeliveredAt).toLocaleTimeString() : 'Pending';

                        row.innerHTML = `
                            <td>#${delivery.BillId}</td>
                            <td>${delivery.MemberNo || 'N/A'}</td>
                            <td><span class="status-badge status-${delivery.Status.toLowerCase()}">${delivery.Status}</span></td>
                            <td>${delivery.DeliveredBy || 'N/A'}</td>
                            <td>${time}</td>
                            <td>
                                <button class="action-btn view" onclick="viewDelivery(${delivery.Id})" title="View">
                                    <i class="fas fa-eye"></i>
                                </button>
                            </td>
                        `;
                        tbody.appendChild(row);
                    });
                }, function (error) {
                    console.error('Error loading delivery data:', error);
                });
            }

            // Generate report
            function generateReport() {
                const from = document.getElementById('reportFrom').value;
                const to = document.getElementById('reportTo').value;
                const type = document.getElementById('reportType').value;

                PageMethods.GenerateReport(type, from, to, function (result) {
                    const data = JSON.parse(result);
                    const resultsDiv = document.getElementById('reportResults');

                    let html = '<h3>Report Results</h3>';

                    if (type === 'sales') {
                        html += `
                            <div class="stats-grid" style="margin-top: 20px;">
                                <div class="stat-card">
                                    <div class="stat-info">
                                        <h3>Total Sales</h3>
                                        <div class="stat-value">$${data.TotalSales.toFixed(2)}</div>
                                    </div>
                                </div>
                                <div class="stat-card">
                                    <div class="stat-info">
                                        <h3>Total Orders</h3>
                                        <div class="stat-value">${data.TotalOrders}</div>
                                    </div>
                                </div>
                                <div class="stat-card">
                                    <div class="stat-info">
                                        <h3>Average Order</h3>
                                        <div class="stat-value">$${data.AverageOrder.toFixed(2)}</div>
                                    </div>
                                </div>
                            </div>
                        `;
                    }

                    resultsDiv.innerHTML = html;
                }, function (error) {
                    alert('Error generating report: ' + error);
                });
            }

            // Utility functions
            function refreshKitchen() {
                loadKitchenData();
            }

            function updatePrepStatus(itemId, status) {
                PageMethods.UpdatePrepStatus(itemId, status, function (result) {
                    if (result === 'success') {
                        loadKitchenData();
                    }
                });
            }

            function cancelOrder(orderId) {
                if (confirm('Are you sure you want to cancel this order?')) {
                    PageMethods.CancelOrder(orderId, function (result) {
                        if (result === 'success') {
                            loadOrders();
                            loadDashboardData();
                        }
                    });
                }
            }

            function exportOrders() {
                // Implement export functionality
                alert('Export functionality would be implemented here');
            }

            function generateDailyReport() {
                // Implement PDF generation
                alert('PDF report generation would be implemented here');
            }

            function generateSalesReport() {
                // Implement Excel export
                alert('Excel export would be implemented here');
            }

            function logout() {
                if (confirm('Are you sure you want to logout?')) {
                    window.location.href = 'Login.aspx';
                }
            }

            // Close modal when clicking outside
            window.onclick = function (event) {
                const modal = document.getElementById('orderModal');
                if (event.target === modal) {
                    closeModal();
                }
            }
        </script>
    </form>
</body>
</html>