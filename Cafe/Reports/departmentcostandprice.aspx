<%@ Page Title="Department Cost & Price Report" Language="C#"
    MasterPageFile="~/MasterPages/GymkhanaMaster.master"
    AutoEventWireup="true"
    CodeFile="departmentcostandprice.aspx.cs"
    Inherits="departmentcostandprice" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">

<style>
    /* Print button styles */
    .print-btn {
        background: #2c3e50;
        color: white;
        border: none;
        padding: 10px 25px;
        font-size: 14px;
        border-radius: 4px;
        cursor: pointer;
        margin-bottom: 15px;
        transition: background 0.3s;
    }
    .print-btn:hover {
        background: #1a252f;
    }
    .print-btn i {
        margin-right: 8px;
    }

    /* Report container */
    .report-container {
        background: white;
        padding: 20px;
        border-radius: 6px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }

    /* Department header - Matching Lahore Gymkhana style */
    .deptHeader {
        background: #1a3c5e;
        color: white;
        font-weight: bold;
        font-size: 16px;
        padding: 10px 15px;
        margin-top: 15px;
        border-radius: 4px 4px 0 0;
        letter-spacing: 0.5px;
        text-transform: uppercase;
    }

    /* Report table - Clean modern style */
    .tblReport {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
        margin-bottom: 5px;
    }

    .tblReport th {
        background: #e8edf3;
        color: #2c3e50;
        border: 1px solid #d0d7e0;
        padding: 10px 8px;
        text-align: left;
        font-weight: 600;
        font-size: 12px;
        text-transform: uppercase;
        letter-spacing: 0.3px;
    }

    .tblReport td {
        border: 1px solid #e0e6ed;
        padding: 8px;
        color: #333;
    }

    .tblReport tr:nth-child(even) {
        background: #f8fafc;
    }

    .tblReport tr:hover {
        background: #eef3f8;
    }

    /* Price/Cost alignment and formatting */
    .tblReport td.price-col,
    .tblReport td.cost-col,
    .tblReport td.gst-col {
        text-align: right;
        font-weight: 500;
        font-family: 'Courier New', monospace;
    }

    .tblReport td.price-col {
        color: #1a7a3a;
    }
    
    .tblReport td.cost-col {
        color: #b22222;
    }

    .tblReport td.gst-col {
        color: #6c757d;
    }

    .item-count-badge {
        background: rgba(255,255,255,0.3);
        padding: 2px 12px;
        border-radius: 20px;
        font-size: 13px;
        margin-left: 10px;
    }

    /* ============================================
       PRINT STYLES - FIX URL AND HEADER ISSUES
       ============================================ */
    @media print {
        /* Hide everything except print area */
        body * {
            visibility: hidden !important;
        }
        
        .print-area, .print-area * {
            visibility: visible !important;
        }
        
        .print-area {
            position: absolute !important;
            left: 0 !important;
            top: 0 !important;
            width: 100% !important;
            padding: 20px !important;
            background: white !important;
        }
        
        /* Hide print button and other UI elements */
        .no-print {
            display: none !important;
        }
        
        /* Hide URL, page number, date from browser */
        @page {
            margin: 1.5cm 1cm !important;
            size: A4 !important;
        }
        
        @page {
            margin-top: 0.5cm !important;
            margin-bottom: 0.5cm !important;
        }
        
        @page :header {
            display: none !important;
        }
        
        @page :footer {
            display: none !important;
        }
        
        /* For Chrome/Edge */
        @page {
            @top-center {
                content: none !important;
            }
            @bottom-center {
                content: none !important;
            }
        }
        
        /* Show print header */
        #printHeader {
            display: block !important;
            text-align: center !important;
            padding-bottom: 15px !important;
            border-bottom: 3px solid #1a3c5e !important;
            margin-bottom: 20px !important;
        }
        
        #printHeader h1 {
            font-size: 24px !important;
            color: #1a3c5e !important;
            margin: 0 !important;
            letter-spacing: 2px !important;
        }
        
        #printHeader h2 {
            font-size: 18px !important;
            color: #333 !important;
            margin: 5px 0 !important;
            font-weight: normal !important;
        }
        
        #printHeader .print-meta {
            font-size: 12px !important;
            color: #666 !important;
            margin: 5px 0 0 !important;
        }
        
        /* Print table styles */
        .tblReport th {
            background: #dcdcdc !important;
            -webkit-print-color-adjust: exact !important;
            print-color-adjust: exact !important;
            border: 1px solid #999 !important;
        }
        
        .deptHeader {
            background: #1a3c5e !important;
            color: white !important;
            -webkit-print-color-adjust: exact !important;
            print-color-adjust: exact !important;
        }
        
        .tblReport tr:nth-child(even) {
            background: #f5f5f5 !important;
            -webkit-print-color-adjust: exact !important;
            print-color-adjust: exact !important;
        }
        
        .tblReport td {
            border: 1px solid #ccc !important;
        }
        
        /* Ensure tables don't break across pages */
        .tblReport {
            page-break-inside: auto !important;
        }
        
        .tblReport tr {
            page-break-inside: avoid !important;
            page-break-after: auto !important;
        }
        
        .deptHeader {
            page-break-after: avoid !important;
        }
    }

    /* Responsive */
    @media (max-width: 768px) {
        .tblReport {
            font-size: 11px;
        }
        .tblReport th,
        .tblReport td {
            padding: 5px;
        }
        .print-btn {
            width: 100%;
            text-align: center;
        }
    }
</style>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<!-- Action Buttons - Hidden in Print -->
<div class="no-print" style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; flex-wrap:wrap; gap:10px;">
    <h3 style="margin:0; color:#2c3e50; border-left:4px solid #1a3c5e; padding-left:12px;">
        ?? Department Cost & Price Report
    </h3>
    <div>
        <button class="print-btn" onclick="printReport()">
            ??? Print / PDF
        </button>
        <button class="print-btn" style="background:#27ae60;" onclick="exportToCSV()">
            ?? Export CSV
        </button>
    </div>
</div>

<!-- Report Content - Visible in Print -->
<div class="report-container print-area" id="reportArea">
    
    <!-- Print Header - Only visible in print -->
    <div id="printHeader" style="display:none;">
        <h1>??? LAHORE GYMKHANA</h1>
        <h2>Department Cost & Price Report</h2>
        <p class="print-meta">
            Generated: <%= DateTime.Now.ToString("dd MMMM yyyy") %> &nbsp;|&nbsp; 
            Time: <%= DateTime.Now.ToString("hh:mm tt") %> &nbsp;|&nbsp; 
            Page <span class="page-number"></span>
        </p>
        <hr style="border:1px solid #eee; margin:10px 0 0;" />
    </div>
    
    <!-- Report Data -->
    <asp:Literal ID="ltReport" runat="server"></asp:Literal>
    
    <!-- Footer for print -->
    <div style="display:none;" id="printFooter">
        <hr style="border:1px solid #eee; margin-top:30px;" />
        <p style="text-align:center; color:#999; font-size:11px;">
            Confidential - For internal use only<br />
            Lahore Gymkhana - Department Cost & Price Report
        </p>
    </div>
</div>

<script>
    function printReport() {
        // Show print header
        document.getElementById('printHeader').style.display = 'block';
        document.getElementById('printFooter').style.display = 'block';

        // Remove URL from print header using JavaScript hack
        var originalTitle = document.title;
        document.title = 'Department Cost & Price Report - Lahore Gymkhana';

        // Trigger print
        window.print();

        // Restore after print
        setTimeout(function () {
            document.getElementById('printHeader').style.display = 'none';
            document.getElementById('printFooter').style.display = 'none';
            document.title = originalTitle;
        }, 1000);
    }

    function exportToCSV() {
        var table = document.querySelector('.tblReport');
        if (!table) {
            alert('No data to export');
            return;
        }

        var csv = [];
        // Get headers
        var headers = [];
        var ths = table.querySelectorAll('th');
        ths.forEach(function (th) {
            headers.push(th.innerText.trim());
        });
        csv.push(headers.join(','));

        // Get rows
        var rows = table.querySelectorAll('tbody tr');
        rows.forEach(function (row) {
            var rowData = [];
            var tds = row.querySelectorAll('td');
            tds.forEach(function (td) {
                rowData.push('"' + td.innerText.trim() + '"');
            });
            if (rowData.length > 0) {
                csv.push(rowData.join(','));
            }
        });

        // Download
        var blob = new Blob([csv.join('\n')], { type: 'text/csv;charset=utf-8;' });
        var link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = 'DepartmentReport_' + new Date().toISOString().slice(0, 10) + '.csv';
        link.click();
    }
</script>

</asp:Content>
