<%@ Page Title="KOT By Member" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" AutoEventWireup="true" 
    Inherits="Store_Add_Unit" CodeFile="SearchKOT.aspx.cs" EnableEventValidation="false" 
     ViewStateEncryptionMode="Never" MaintainScrollPositionOnPostBack="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<!DOCTYPE html>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <style>
        /* Your existing styles - keep them all */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        .kot-container {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #FFF3E0, #fff);
            min-height: 100vh;
            padding: 20px;
        }

        /* Header */
        .kot-header {
            background: #fff;
            border-radius: 16px;
            padding: 20px 25px;
            margin-bottom: 25px;
            box-shadow: 0 4px 20px rgba(211, 47, 47, 0.1);
            border: 2px solid #FFCDD2;
        }

        .kot-header h1 {
            font-size: 24px;
            font-weight: 800;
            background: linear-gradient(135deg, #D32F2F, #FF9800);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 5px;
        }

        .kot-header p {
            color: #795548;
            font-size: 13px;
        }

        /* Search Card */
        .search-card {
            background: #fff;
            border-radius: 16px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 4px 14px rgba(211, 47, 47, 0.12);
            border: 2px solid #FFCDD2;
        }

        .form-group {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            align-items: flex-end;
        }

        .input-group {
            flex: 1;
            min-width: 200px;
        }

        .input-group label {
            display: block;
            font-size: 12px;
            font-weight: 700;
            color: #D32F2F;
            margin-bottom: 6px;
            text-transform: uppercase;
        }

        .input-group input {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #D7CCC8;
            border-radius: 10px;
            font-size: 14px;
            font-family: 'Poppins', sans-serif;
            transition: all 0.2s;
            outline: none;
        }

        .input-group input:focus {
            border-color: #D32F2F;
        }

        .btn-search {
            background: linear-gradient(135deg, #D32F2F, #FF9800);
            color: #fff;
            border: none;
            padding: 12px 30px;
            border-radius: 10px;
            font-weight: 700;
            font-size: 14px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: transform 0.2s, box-shadow 0.2s;
            font-family: 'Poppins', sans-serif;
        }

        .btn-search:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(211, 47, 47, 0.3);
        }

        .btn-search:active {
            transform: translateY(0);
        }

        /* Results Section */
        .results-section {
            display: none;
        }

        .results-section.active {
            display: block;
            animation: fadeIn 0.3s ease;
        }

        .member-info {
            background: linear-gradient(135deg, #E3F2FD, #fff);
            border: 2px solid #90CAF9;
            border-radius: 16px;
            padding: 20px;
            margin-bottom: 25px;
        }

        .member-info h3 {
            font-size: 18px;
            font-weight: 800;
            color: #1565C0;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .member-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 12px;
        }

        .detail-item {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 8px 12px;
            background: #fff;
            border-radius: 8px;
            border: 1px solid #90CAF9;
        }

        .detail-item i {
            width: 25px;
            color: #1565C0;
            font-size: 14px;
        }

        .detail-item .label {
            font-weight: 600;
            color: #795548;
            font-size: 12px;
        }

        .detail-item .value {
            font-weight: 700;
            color: #5D4037;
            font-size: 13px;
        }

        /* Orders List */
        .orders-list {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .order-card {
            background: #fff;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            border: 2px solid #FFCDD2;
            transition: transform 0.2s;
        }

        .order-card:hover {
            transform: translateX(5px);
            border-color: #D32F2F;
        }

        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px dashed #FFCDD2;
        }

        .order-id {
            font-weight: 800;
            font-size: 16px;
            color: #D32F2F;
        }

        .kot-badge {
            background: linear-gradient(135deg, #1565C0, #42A5F5);
            color: #fff;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
        }

        .order-date {
            font-size: 12px;
            color: #795548;
        }

        .order-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 10px;
            margin-bottom: 15px;
        }

        .order-detail {
            font-size: 12px;
        }

        .order-detail i {
            width: 20px;
            color: #D32F2F;
            margin-right: 5px;
        }

        .items-table {
            width: 100%;
            margin: 15px 0;
            border-collapse: collapse;
            font-size: 12px;
        }

        .items-table th {
            text-align: left;
            padding: 8px;
            background: #FFF3E0;
            border-bottom: 2px solid #FFCDD2;
            color: #D32F2F;
        }

        .items-table td {
            padding: 8px;
            border-bottom: 1px solid #FFCDD2;
        }

        .order-total {
            text-align: right;
            padding-top: 10px;
            font-weight: 800;
            font-size: 16px;
            color: #D32F2F;
            border-top: 2px dashed #FFCDD2;
        }

        .btn-kot {
            background: linear-gradient(135deg, #1565C0, #42A5F5);
            color: #fff;
            border: none;
            padding: 8px 20px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 12px;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s;
            font-family: 'Poppins', sans-serif;
            margin-top: 10px;
        }

        .btn-kot:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(21, 101, 192, 0.3);
        }

        .no-orders {
            text-align: center;
            padding: 50px;
            background: #fff;
            border-radius: 16px;
            border: 2px dashed #FFCDD2;
        }

        .no-orders i {
            font-size: 50px;
            color: #FFCDD2;
            margin-bottom: 15px;
        }

        /* Loading */
        .loading {
            text-align: center;
            padding: 40px;
        }

        .loading i {
            font-size: 40px;
            color: #D32F2F;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Receipt Modal */
        .kot-modal {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.8);
            backdrop-filter: blur(7px);
            z-index: 10000;
            align-items: center;
            justify-content: center;
        }

        .kot-modal.active {
            display: flex;
        }

        .modal-content {
            background: #fff;
            border-radius: 20px;
            width: 90%;
            max-width: 500px;
            max-height: 90vh;
            overflow-y: auto;
            position: relative;
            animation: fadeIn 0.2s ease;
        }

        .modal-header {
            padding: 15px 20px;
            border-bottom: 2px solid #FFCDD2;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #FFF3E0;
            border-radius: 20px 20px 0 0;
            position: sticky;
            top: 0;
            z-index: 10;
        }

        .modal-header h3 {
            font-size: 18px;
            font-weight: 800;
            color: #D32F2F;
        }

        .close-modal {
            background: none;
            border: none;
            font-size: 24px;
            cursor: pointer;
            color: #795548;
            transition: color 0.2s;
        }

        .close-modal:hover {
            color: #D32F2F;
        }

        .modal-body {
            padding: 20px;
        }

        .print-btn {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #D32F2F, #FF9800);
            color: #fff;
            border: none;
            border-radius: 10px;
            font-weight: 700;
            cursor: pointer;
            margin-top: 15px;
            font-family: 'Poppins', sans-serif;
        }

        /* Receipt Styles */
        .receipt {
            font-family: 'Courier New', monospace;
            max-width: 340px;
            margin: 0 auto;
            padding: 15px;
        }

        .receipt-header {
            text-align: center;
            margin-bottom: 15px;
            border-bottom: 2px dashed #000;
            padding-bottom: 10px;
        }

        .receipt-header h1 {
            font-size: 16px;
            font-weight: 800;
            margin: 0;
        }

        .receipt-header h3 {
            font-size: 12px;
            margin: 5px 0;
        }

        .receipt-info {
            margin-bottom: 15px;
            border-bottom: 2px dashed #000;
            padding-bottom: 10px;
        }

        .receipt-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 5px;
            font-size: 11px;
        }

        .receipt-items {
            width: 100%;
            margin-bottom: 15px;
            border-collapse: collapse;
            font-size: 11px;
        }

        .receipt-items th {
            text-align: left;
            border-bottom: 2px solid #000;
            padding: 5px 0;
        }

        .receipt-items td {
            padding: 3px 0;
            border-bottom: 1px dashed #ccc;
        }

        .receipt-footer {
            text-align: center;
            padding-top: 10px;
            border-top: 2px dashed #000;
            font-size: 10px;
        }

        @media (max-width: 768px) {
            .kot-container {
                padding: 10px;
            }
            
            .form-group {
                flex-direction: column;
            }
            
            .btn-search {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <div class="kot-container">
        <div class="kot-header">
            <h1><i class="fa fa-ticket-alt"></i> KOT By Member Number</h1>
            <p>View and print KOT receipts for any member by entering their member number and date</p>
        </div>

        <div class="search-card">
            <div class="form-group">
                <div class="input-group">
                    <label><i class="fa fa-id-card"></i> Member Number</label>
                    <input type="text" id="txtMemberNo" placeholder="Enter member number..." autocomplete="off" />
                </div>
                <div class="input-group">
                    <label><i class="fa fa-calendar"></i> Select Date</label>
                    <input type="date" id="dtpDate" />
                </div>
                <button type="button" class="btn-search" id="btnSearch">
                    <i class="fa fa-search"></i> Search KOT
                </button>
            </div>
        </div>

        <div class="results-section" id="resultsSection">
            <div class="member-info" id="memberInfo"></div>
            <div class="orders-list" id="ordersList"></div>
        </div>
    </div>

    <!-- Receipt Modal -->
    <div class="kot-modal" id="receiptModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3><i class="fa fa-receipt"></i> KOT Receipt</h3>
                <button class="close-modal" onclick="closeModal()">&times;</button>
            </div>
            <div class="modal-body" id="receiptBody"></div>
        </div>
    </div>

    <asp:ScriptManager ID="SM1" runat="server" EnablePageMethods="true"></asp:ScriptManager>

    <script>
        $(function () {
            // Set default date to today
            $('#dtpDate').val(new Date().toISOString().split('T')[0]);

            // Search button click
            $('#btnSearch').on('click', function () {
                var memberNo = $('#txtMemberNo').val().trim();
                var date = $('#dtpDate').val();

                if (!memberNo) {
                    showNotification('Please enter member number!', 'error');
                    $('#txtMemberNo').focus();
                    return;
                }

                if (!date) {
                    showNotification('Please select a date!', 'error');
                    return;
                }

                searchOrders(memberNo, date);
            });

            // Enter key press
            $('#txtMemberNo').on('keypress', function (e) {
                if (e.which === 13) {
                    $('#btnSearch').click();
                }
            });
        });

        function searchOrders(memberNo, date) {
            $('#resultsSection').removeClass('active');
            $('#ordersList').html('<div class="loading"><i class="fa fa-spinner fa-spin"></i><p>Loading orders...</p></div>');
            $('#resultsSection').addClass('active');

            $.ajax({
                type: 'POST',
                url: 'SearchKOT.aspx/GetKOTByMember',
                data: JSON.stringify({ memberNo: memberNo, date: date }),
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                timeout: 15000,
                success: function (response) {
                    var result = response.d;
                    if (result.success) {
                        displayMemberInfo(result.memberInfo);
                        displayOrders(result.orders);
                    } else {
                        showNotification(result.message, 'error');
                        $('#ordersList').html('<div class="no-orders"><i class="fa fa-exclamation-triangle"></i><p>' + result.message + '</p></div>');
                    }
                },
                error: function (xhr, status, error) {
                    console.error('Error:', error);
                    showNotification('Server error. Please try again.', 'error');
                    $('#ordersList').html('<div class="no-orders"><i class="fa fa-exclamation-triangle"></i><p>Failed to load orders. Please try again.</p></div>');
                }
            });
        }

        function displayMemberInfo(info) {
            if (!info || !info.name) {
                $('#memberInfo').hide();
                return;
            }

            $('#memberInfo').show().html(`
                <h3><i class="fa fa-id-card"></i> Member Information</h3>
                <div class="member-details">
                    <div class="detail-item">
                        <i class="fa fa-hashtag"></i>
                        <span class="label">Member No:</span>
                        <span class="value">${escapeHtml(info.memberNo || 'N/A')}</span>
                    </div>
                    <div class="detail-item">
                        <i class="fa fa-user"></i>
                        <span class="label">Name:</span>
                        <span class="value">${escapeHtml(info.name || 'N/A')}</span>
                    </div>
                    <div class="detail-item">
                        <i class="fa fa-id-card"></i>
                        <span class="label">Card No:</span>
                        <span class="value">${escapeHtml(info.cardNo || 'N/A')}</span>
                    </div>
                    <div class="detail-item">
                        <i class="fa fa-envelope"></i>
                        <span class="label">Email:</span>
                        <span class="value">${escapeHtml(info.email || 'N/A')}</span>
                    </div>
                    <div class="detail-item">
                        <i class="fa fa-phone"></i>
                        <span class="label">Phone:</span>
                        <span class="value">${escapeHtml(info.phone || 'N/A')}</span>
                    </div>
                </div>
            `);
        }

        function displayOrders(orders) {
            if (!orders || orders.length === 0) {
                $('#ordersList').html('<div class="no-orders"><i class="fa fa-receipt"></i><p>No KOT found for this member on the selected date.</p></div>');
                return;
            }

            var html = '';
            for (var i = 0; i < orders.length; i++) {
                var order = orders[i];
                var itemsHtml = '';
                if (order.items && order.items.length > 0) {
                    itemsHtml = '<table class="items-table">' +
                        '<thead><tr><th>Item</th><th>Qty</th><th>Price</th><th>Total</th></tr></thead><tbody>';
                    for (var j = 0; j < order.items.length; j++) {
                        var item = order.items[j];
                        itemsHtml += '<tr>' +
                            '<td>' + escapeHtml(item.name) + '</td>' +
                            '<td>' + item.quantity + '</td>' +
                            '<td>' + formatPrice(item.price) + '</td>' +
                            '<td>' + formatPrice(item.price * item.quantity) + '</td>' +
                            '</tr>';
                    }
                    itemsHtml += '</tbody></table>';
                }

                html += `
                    <div class="order-card">
                        <div class="order-header">
                            <div>
                                <span class="order-id"><i class="fa fa-hashtag"></i> Order #${order.id}</span>
                                ${order.kotNumber ? `<span class="kot-badge"><i class="fa fa-ticket-alt"></i> ${escapeHtml(order.kotNumber)}</span>` : ''}
                            </div>
                            <div class="order-date">
                                <i class="fa fa-calendar-alt"></i> ${escapeHtml(order.date)}
                            </div>
                        </div>
                        <div class="order-details">
                            <div class="order-detail"><i class="fa fa-table"></i> Table: ${escapeHtml(order.tableNumber || '—')}</div>
                            <div class="order-detail"><i class="fa fa-users"></i> Covers: ${order.cover || 1}</div>
                            <div class="order-detail"><i class="fa fa-building"></i> Dept: ${escapeHtml(order.departmentName || '—')}</div>
                            <div class="order-detail"><i class="fa fa-user"></i> Waiter: ${escapeHtml(order.waiterName || '—')}</div>
                            ${order.roomNo ? `<div class="order-detail"><i class="fa fa-bed"></i> Room: ${escapeHtml(order.roomNo)}</div>` : ''}
                        </div>
                        ${itemsHtml}
                        <div class="order-total">
                            Total: ${formatPrice(order.total)}
                        </div>
                        <button class="btn-kot" onclick="printKOT(${order.id})">
                            <i class="fa fa-print"></i> Print KOT
                        </button>
                    </div>
                `;
            }

            $('#ordersList').html(html);
        }

        function printKOT(orderId) {
            $.ajax({
                type: 'POST',
                url: 'SearchKOT.aspx/GetOrderDetails',
                data: JSON.stringify({ orderId: orderId }),
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var result = response.d;
                    if (result.success) {
                        displayReceipt(result.order);
                        $('#receiptModal').addClass('active');
                    } else {
                        showNotification(result.message, 'error');
                    }
                },
                error: function () {
                    showNotification('Failed to load order details', 'error');
                }
            });
        }

        function displayReceipt(order) {
            var itemsHtml = '';
            if (order.items && order.items.length > 0) {
                for (var i = 0; i < order.items.length; i++) {
                    var item = order.items[i];
                    itemsHtml += '<tr>' +
                        '<td>' + escapeHtml(item.name) + '</td>' +
                        '<td style="text-align:center">' + item.quantity + '</td>' +
                        '<td style="text-align:right">' + formatPrice(item.price * item.quantity) + '</td>' +
                        '</tr>';
                }
            }

            var roomHtml = '';
            if (order.roomNo) {
                roomHtml = `<div class="receipt-row"><span>Room No:</span><span>${escapeHtml(order.roomNo)}</span></div>`;
            }

            var html = `
                <div class="receipt">
                    <div class="receipt-header">
                        <h1>LAHORE GYMKHANA</h1>
                        <h3>Food & Beverage</h3>
                        <h3>${escapeHtml(order.departmentName || '')}</h3>
                        <div style="background:#000;color:#fff;padding:4px;margin:8px 0;font-weight:800">
                            KOT: ${escapeHtml(order.kotNumber || 'N/A')}
                        </div>
                    </div>
                    <div class="receipt-info">
                        <div class="receipt-row"><span>Member No:</span><span>${escapeHtml(order.memberNo)}</span></div>
                        <div class="receipt-row"><span>Member Name:</span><span>${escapeHtml(order.memberName || order.memberNo)}</span></div>
                        ${roomHtml}
                        <div class="receipt-row"><span>Table:</span><span>${escapeHtml(order.tableNumber || '—')}</span></div>
                        <div class="receipt-row"><span>Covers:</span><span>${order.cover || 1}</span></div>
                        <div class="receipt-row"><span>Waiter:</span><span>${escapeHtml(order.waiterName || '—')}</span></div>
                        <div class="receipt-row"><span>Date:</span><span>${escapeHtml(order.date)}</span></div>
                        <div class="receipt-row"><span>Time:</span><span>${escapeHtml(order.time || '')}</span></div>
                    </div>
                    <table class="receipt-items">
                        <thead>
                            <tr><th>Item</th><th style="width:40px;text-align:center">Qty</th><th style="width:70px;text-align:right">Amount</th></tr>
                        </thead>
                        <tbody>
                            ${itemsHtml}
                        </tbody>
                    </table>
                    <div class="receipt-info">
                        <div class="receipt-row"><span>Subtotal:</span><span>${formatPrice(order.subtotal)}</span></div>
                        <div class="receipt-row"><span>GST:</span><span>${formatPrice(order.taxApplied)}</span></div>
                        <div class="receipt-row" style="font-weight:800;font-size:13px;margin-top:5px;padding-top:5px;border-top:2px solid #000;">
                            <span>TOTAL:</span><span>${formatPrice(order.total)}</span>
                        </div>
                    </div>
                    <div class="receipt-footer">
                        <p>WE HOPE YOU HAVE ENJOYED YOUR VISIT.</p>
                        <p>Thank You!</p>
                    </div>
                </div>
                <button class="print-btn" onclick="printReceipt()">
                    <i class="fa fa-print"></i> Print Receipt
                </button>
            `;

            $('#receiptBody').html(html);
        }

        function printReceipt() {
            var printContent = $('#receiptBody').clone();
            printContent.find('.print-btn').remove();

            var printWindow = window.open('', '_blank');
            printWindow.document.write('<!DOCTYPE html><html><head><title>KOT Receipt</title>');
            printWindow.document.write('<style>');
            printWindow.document.write('.receipt{font-family:"Courier New",monospace;max-width:340px;margin:0 auto;padding:15px;}');
            printWindow.document.write('.receipt-header{text-align:center;margin-bottom:15px;border-bottom:2px dashed #000;padding-bottom:10px;}');
            printWindow.document.write('.receipt-header h1{font-size:16px;font-weight:800;margin:0;}');
            printWindow.document.write('.receipt-header h3{font-size:12px;margin:5px 0;}');
            printWindow.document.write('.receipt-info{margin-bottom:15px;border-bottom:2px dashed #000;padding-bottom:10px;}');
            printWindow.document.write('.receipt-row{display:flex;justify-content:space-between;margin-bottom:5px;font-size:11px;}');
            printWindow.document.write('.receipt-items{width:100%;margin-bottom:15px;border-collapse:collapse;font-size:11px;}');
            printWindow.document.write('.receipt-items th{text-align:left;border-bottom:2px solid #000;padding:5px 0;}');
            printWindow.document.write('.receipt-items td{padding:3px 0;border-bottom:1px dashed #ccc;}');
            printWindow.document.write('.receipt-footer{text-align:center;padding-top:10px;border-top:2px dashed #000;font-size:10px;}');
            printWindow.document.write('</style></head><body>');
            printWindow.document.write(printContent.html());
            printWindow.document.write('</body></html>');
            printWindow.document.close();
            printWindow.focus();
            setTimeout(function () {
                printWindow.print();
                printWindow.close();
            }, 200);
        }

        function closeModal() {
            $('#receiptModal').removeClass('active');
        }

        function formatPrice(price) {
            return 'Rs. ' + (parseFloat(price) || 0).toLocaleString('en-IN', {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            });
        }

        function escapeHtml(str) {
            if (!str) return '';
            return str.replace(/[&<>]/g, function (m) {
                if (m === '&') return '&amp;';
                if (m === '<') return '&lt;';
                if (m === '>') return '&gt;';
                return m;
            });
        }

        function showNotification(msg, type) {
            var bg = type === 'error' ? '#F44336' : '#4CAF50';
            var icon = type === 'error' ? 'fa-exclamation-circle' : 'fa-check-circle';
            var $n = $('<div class="kot-notification" style="position:fixed;top:20px;right:20px;background:' + bg + ';color:#fff;padding:12px 20px;border-radius:8px;box-shadow:0 4px 12px rgba(0,0,0,0.2);z-index:99999;display:flex;align-items:center;gap:10px;animation:fadeIn 0.3s ease;font-size:13px;"><i class="fa ' + icon + '"></i><span>' + msg + '</span></div>');
            $('body').append($n);
            setTimeout(function () {
                $n.fadeOut(300, function () { $(this).remove(); });
            }, 3000);
        }

        // Close modal on outside click
        $(document).on('click', function (e) {
            if ($(e.target).is('#receiptModal')) {
                closeModal();
            }
        });
    </script>
</body>
</html>
</asp:Content>
