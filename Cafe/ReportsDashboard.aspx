<%@ Page Title="Restaurant POS Dashboard" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master"
    AutoEventWireup="true" CodeFile="ReportsDashboard.aspx.cs" Inherits="Pos" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'DM Sans', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }

        .dashboard-wrapper {
            padding: 20px;
            animation: fadeIn 0.5s ease-in;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Header Styles */
        .dashboard-header {
            background: white;
            border-radius: 20px;
            padding: 25px 30px;
            margin-bottom: 25px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            border: 1px solid rgba(255,255,255,0.2);
        }

        .header-title {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .header-title i {
            font-size: 40px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .header-title h1 {
            font-size: 28px;
            font-weight: 800;
            font-family: 'Syne', sans-serif;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .header-subtitle {
            color: #6c757d;
            margin-top: 8px;
            font-size: 14px;
        }

        /* Filter Card */
        .filter-card {
            background: white;
            border-radius: 20px;
            padding: 20px;
            margin-bottom: 25px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
            transition: transform 0.3s;
        }

        .filter-card:hover {
            transform: translateY(-2px);
        }

        .filter-label {
            font-weight: 600;
            color: #495057;
            margin-bottom: 8px;
            display: block;
        }

        .filter-input {
            border: 2px solid #e9ecef;
            border-radius: 12px;
            padding: 10px 15px;
            width: 100%;
            transition: all 0.3s;
        }

        .filter-input:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }

        .btn-apply {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 12px;
            padding: 10px 25px;
            font-weight: 600;
            width: 100%;
            transition: all 0.3s;
        }

        .btn-apply:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }

        .btn-pdf {
            background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
            color: white;
        }

        .btn-excel {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
        }

        /* KPI Cards */
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 25px;
        }

        .kpi-card {
            background: white;
            border-radius: 20px;
            padding: 20px;
            display: flex;
            align-items: center;
            gap: 20px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
            transition: all 0.3s;
            cursor: pointer;
        }

        .kpi-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px rgba(0,0,0,0.15);
        }

        .kpi-icon {
            width: 70px;
            height: 70px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 32px;
        }

        .kpi-info h3 {
            font-size: 13px;
            color: #6c757d;
            margin-bottom: 5px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .kpi-info .kpi-value {
            font-size: 32px;
            font-weight: 800;
            color: #2c3e50;
            margin: 0;
        }

        .kpi-trend {
            font-size: 12px;
            margin-top: 5px;
        }

        .trend-up {
            color: #28a745;
        }

        .trend-down {
            color: #dc3545;
        }

        /* Charts Grid */
        .charts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
            gap: 20px;
            margin-bottom: 25px;
        }

        .chart-card {
            background: white;
            border-radius: 20px;
            padding: 20px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
        }

        .chart-title {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 20px;
            color: #2c3e50;
            display: flex;
            align-items: center;
            gap: 10px;
            padding-bottom: 10px;
            border-bottom: 2px solid #e9ecef;
        }

        .chart-container {
            position: relative;
            height: 300px;
        }

        canvas {
            max-height: 280px;
        }

        /* Data Table */
        .table-card {
            background: white;
            border-radius: 20px;
            padding: 20px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
            margin-bottom: 20px;
        }

        .table-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 15px;
        }

        .table-title {
            font-size: 18px;
            font-weight: 700;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .search-box {
            border: 2px solid #e9ecef;
            border-radius: 12px;
            padding: 8px 15px;
            width: 250px;
        }

        .gridview-custom {
            width: 100%;
            border-collapse: collapse;
        }

        .gridview-custom th {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 12px;
            text-align: left;
            font-weight: 600;
        }

        .gridview-custom td {
            padding: 12px;
            border-bottom: 1px solid #e9ecef;
        }

        .gridview-custom tr:hover {
            background: #f8f9fa;
            cursor: pointer;
        }

        /* Loading Spinner */
        .loading-spinner {
            display: none;
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 9999;
        }

        .spinner-border {
            width: 3rem;
            height: 3rem;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .charts-grid {
                grid-template-columns: 1fr;
            }
            
            .kpi-grid {
                grid-template-columns: 1fr;
            }
            
            .table-header {
                flex-direction: column;
                align-items: stretch;
            }
            
            .search-box {
                width: 100%;
            }
        }

        /* Print Styles */
        @media print {
            .btn-apply, .btn-pdf, .btn-excel, .filter-card {
                display: none;
            }
            
            .kpi-card, .chart-card, .table-card {
                break-inside: avoid;
                box-shadow: none;
                border: 1px solid #ddd;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div class="dashboard-wrapper">
        <!-- Loading Spinner -->
        <div id="loadingSpinner" class="loading-spinner">
            <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Loading...</span>
            </div>
        </div>

        <!-- Header -->
        <div class="dashboard-header">
            <div class="header-title">
                <i class="fas fa-chart-line"></i>
                <h1>Restaurant POS Analytics Dashboard</h1>
            </div>
            <div class="header-subtitle">
                <i class="fas fa-calendar-alt"></i> Real-time insights & performance metrics
            </div>
        </div>

        <!-- Filter Section -->
        <div class="filter-card">
            <div class="row g-3 align-items-end">
                <div class="col-md-3">
                    <label class="filter-label">
                        <i class="fas fa-calendar-start"></i> From Date
                    </label>
                    <asp:TextBox ID="txtStartDate" runat="server" CssClass="filter-input" TextMode="Date"></asp:TextBox>
                </div>
                <div class="col-md-3">
                    <label class="filter-label">
                        <i class="fas fa-calendar-end"></i> To Date
                    </label>
                    <asp:TextBox ID="txtEndDate" runat="server" CssClass="filter-input" TextMode="Date"></asp:TextBox>
                </div>
                <div class="col-md-3">
                    <label class="filter-label">
                        <i class="fas fa-chart-simple"></i> Report Type
                    </label>
                    <asp:DropDownList ID="ddlReportType" runat="server" CssClass="filter-input">
                        <asp:ListItem Value="daily">Daily Sales Report</asp:ListItem>
                        <asp:ListItem Value="payment">Payment Method Report</asp:ListItem>
                        <asp:ListItem Value="waiter">Waiter Performance</asp:ListItem>
                        <asp:ListItem Value="cover">Cover Analysis</asp:ListItem>
                        <asp:ListItem Value="hourly">Hourly Sales Trend</asp:ListItem>
                        <asp:ListItem Value="department">Department Report</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-md-3">
                    <asp:Button ID="btnLoadReport" runat="server" Text="Load Report" CssClass="btn-apply" OnClick="btnLoadReport_Click" />
                    <div class="mt-2">
                        <asp:Button ID="btnExportPDF" runat="server" Text="PDF" CssClass="btn-apply btn-pdf me-2" OnClick="btnExportPDF_Click" style="width: 48%;" />
                        <asp:Button ID="btnExportExcel" runat="server" Text="Excel" CssClass="btn-apply btn-excel" OnClick="btnExportExcel_Click" style="width: 48%;" />
                    </div>
                </div>
            </div>
        </div>

        <!-- KPI Cards -->
        <div class="kpi-grid">
            <div class="kpi-card">
                <div class="kpi-icon">
                    <i class="fas fa-receipt"></i>
                </div>
                <div class="kpi-info">
                    <h3>Total Bills</h3>
                    <p class="kpi-value">
                        <asp:Label ID="lblTotalBills" runat="server" Text="0"></asp:Label>
                    </p>
                    <div class="kpi-trend trend-up">
                        <i class="fas fa-arrow-up"></i> vs last period
                    </div>
                </div>
            </div>
            <div class="kpi-card">
                <div class="kpi-icon">
                    <i class="fas fa-rupee-sign"></i>
                </div>
                <div class="kpi-info">
                    <h3>Net Sales</h3>
                    <p class="kpi-value">
                        <asp:Label ID="lblNetSales" runat="server" Text="₹0"></asp:Label>
                    </p>
                    <div class="kpi-trend trend-up">
                        <i class="fas fa-chart-line"></i> Revenue
                    </div>
                </div>
            </div>
            <div class="kpi-card">
                <div class="kpi-icon">
                    <i class="fas fa-users"></i>
                </div>
                <div class="kpi-info">
                    <h3>Total Covers</h3>
                    <p class="kpi-value">
                        <asp:Label ID="lblTotalCovers" runat="server" Text="0"></asp:Label>
                    </p>
                    <div class="kpi-trend">
                        <i class="fas fa-user-friends"></i> Persons served
                    </div>
                </div>
            </div>
            <div class="kpi-card">
                <div class="kpi-icon">
                    <i class="fas fa-chart-line"></i>
                </div>
                <div class="kpi-info">
                    <h3>Per Person Avg</h3>
                    <p class="kpi-value">
                        <asp:Label ID="lblPPA" runat="server" Text="₹0"></asp:Label>
                    </p>
                    <div class="kpi-trend trend-up">
                        <i class="fas fa-chart-line"></i> Customer value
                    </div>
                </div>
            </div>
        </div>

        <!-- Charts Section -->
        <div class="charts-grid">
            <div class="chart-card">
                <div class="chart-title">
                    <i class="fas fa-chart-bar"></i>
                    Sales Trend Analysis
                </div>
                <div class="chart-container">
                    <canvas id="salesChart"></canvas>
                </div>
            </div>
            <div class="chart-card">
                <div class="chart-title">
                    <i class="fas fa-chart-pie"></i>
                    Payment Method Distribution
                </div>
                <div class="chart-container">
                    <canvas id="paymentChart"></canvas>
                </div>
            </div>
        </div>

        <!-- Data Table -->
        <div class="table-card">
            <div class="table-header">
                <div class="table-title">
                    <i class="fas fa-table-list"></i>
                    Report Details
                    <asp:Label ID="lblRecordCount" runat="server" CssClass="badge bg-primary ms-2"></asp:Label>
                </div>
                <div>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="search-box" placeholder="Search records..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                </div>
            </div>
            <div class="table-responsive">
                <asp:GridView ID="gvReports" runat="server" CssClass="gridview-custom table" 
                    AutoGenerateColumns="true" AllowPaging="true" PageSize="10" 
                    OnPageIndexChanging="gvReports_PageIndexChanging"
                    AlternatingRowStyle-BackColor="#F8F9FA" 
                    HeaderStyle-CssClass="bg-gradient">
                    <PagerStyle CssClass="pagination justify-content-center" />
                </asp:GridView>
            </div>
        </div>
    </div>

    <script>
        // Chart.js implementation
        let salesChart = null;
        let paymentChart = null;

        function initializeCharts(salesLabels, salesData, paymentLabels, paymentData) {
            // Sales Chart
            const salesCtx = document.getElementById('salesChart').getContext('2d');
            if (salesChart) salesChart.destroy();

            salesChart = new Chart(salesCtx, {
                type: 'bar',
                data: {
                    labels: salesLabels,
                    datasets: [{
                        label: 'Sales Amount (₹)',
                        data: salesData,
                        backgroundColor: 'rgba(102, 126, 234, 0.6)',
                        borderColor: 'rgba(102, 126, 234, 1)',
                        borderWidth: 2,
                        borderRadius: 8
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: true,
                    plugins: {
                        legend: {
                            position: 'top',
                        },
                        tooltip: {
                            callbacks: {
                                label: function (context) {
                                    return '₹' + context.parsed.y.toLocaleString('en-IN');
                                }
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                callback: function (value) {
                                    return '₹' + value.toLocaleString('en-IN');
                                }
                            }
                        }
                    }
                }
            });

            // Payment Chart
            const paymentCtx = document.getElementById('paymentChart').getContext('2d');
            if (paymentChart) paymentChart.destroy();

            paymentChart = new Chart(paymentCtx, {
                type: 'pie',
                data: {
                    labels: paymentLabels,
                    datasets: [{
                        data: paymentData,
                        backgroundColor: [
                            'rgba(102, 126, 234, 0.8)',
                            'rgba(118, 75, 162, 0.8)',
                            'rgba(39, 174, 96, 0.8)',
                            'rgba(241, 196, 15, 0.8)',
                            'rgba(231, 76, 60, 0.8)'
                        ],
                        borderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: true,
                    plugins: {
                        legend: {
                            position: 'bottom',
                        },
                        tooltip: {
                            callbacks: {
                                label: function (context) {
                                    return context.label + ': ₹' + context.parsed.toLocaleString('en-IN');
                                }
                            }
                        }
                    }
                }
            });
        }

        // Show/Hide Loading
        function showLoading() {
            document.getElementById('loadingSpinner').style.display = 'block';
        }

        function hideLoading() {
            document.getElementById('loadingSpinner').style.display = 'none';
        }

        // Client-side validation
        function validateDates() {
            const startDate = document.getElementById('<%= txtStartDate.ClientID %>').value;
            const endDate = document.getElementById('<%= txtEndDate.ClientID %>').value;

            if (startDate && endDate && startDate > endDate) {
                alert('Start date cannot be greater than end date!');
                return false;
            }
            return true;
        }
    </script>
</asp:Content>
