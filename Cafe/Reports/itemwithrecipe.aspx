<%@ Page Title="Recipe Items Report" Language="C#"
    MasterPageFile="~/MasterPages/GymkhanaMaster.master"
    AutoEventWireup="true"
    CodeFile="itemwithrecipe.aspx.cs"
    Inherits="itemwithrecipe" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <style>
        .report-container {
            padding: 20px;
            background: #fff;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .filter-section {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .filter-section label {
            font-weight: bold;
            margin-right: 10px;
        }
        .filter-section .form-group {
            display: inline-block;
            margin-right: 20px;
            vertical-align: middle;
        }
        .filter-section .btn-search {
            padding: 6px 25px;
            background: #007bff;
            color: white;
            border: none;
            border-radius: 3px;
            cursor: pointer;
        }
        .filter-section .btn-search:hover {
            background: #0056b3;
        }
        .filter-section .btn-print {
            padding: 6px 25px;
            background: #17a2b8;
            color: white;
            border: none;
            border-radius: 3px;
            cursor: pointer;
        }
        .filter-section .btn-print:hover {
            background: #138496;
        }
        .report-title {
            font-size: 24px;
            font-weight: bold;
            color: #333;
            border-bottom: 2px solid #007bff;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .report-grid {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }
        .report-grid th {
            background: #007bff;
            color: white;
            padding: 10px 8px;
            text-align: left;
            border: 1px solid #0056b3;
        }
        .report-grid td {
            padding: 8px;
            border: 1px solid #ddd;
        }
        .report-grid tr:nth-child(even) {
            background: #f9f9f9;
        }
        .report-grid tr:hover {
            background: #f0f0f0;
        }
        .category-header {
            background: #e9ecef !important;
            font-weight: bold;
        }
        .item-row td {
            padding-left: 30px;
        }
        .total-row {
            background: #fffbcc !important;
            font-weight: bold;
        }
        .no-data {
            text-align: center;
            padding: 50px;
            color: #666;
            font-size: 16px;
        }
        .item-code-input {
            padding: 6px 12px;
            border: 1px solid #ccc;
            border-radius: 3px;
            width: 200px;
        }
        .department-dropdown {
            padding: 6px 12px;
            border: 1px solid #ccc;
            border-radius: 3px;
            min-width: 200px;
        }
        .button-group {
            display: inline-block;
            margin-left: 10px;
        }
        
        /* Print Styles */
        @media print {
            .filter-section {
                display: none !important;
            }
            .no-print {
                display: none !important;
            }
            .report-container {
                padding: 10px;
                box-shadow: none;
                border-radius: 0;
            }
            .report-grid th {
                background: #007bff !important;
                color: white !important;
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
            }
            .category-header {
                background: #e9ecef !important;
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
            }
            .total-row {
                background: #fffbcc !important;
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
            }
            .report-grid tr:nth-child(even) {
                background: #f9f9f9 !important;
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
            }
        }
        
        /* Print Header Styles */
        .print-header {
            display: none;
        }
        @media print {
            .print-header {
                display: block !important;
                text-align: center;
                margin-bottom: 20px;
            }
            .print-header h1 {
                font-size: 28px;
                margin-bottom: 5px;
            }
            .print-header h2 {
                font-size: 20px;
                margin-top: 0;
                color: #555;
                font-weight: normal;
            }
            .print-header .info {
                font-size: 14px;
                margin: 5px 0;
            }
            .print-header hr {
                border: 2px solid #007bff;
            }
            .print-header .hr-light {
                border: 1px solid #ccc;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div class="report-container" id="reportContainer">
        <!-- Print Header - Only visible when printing -->
        <div class="print-header">
            <h1>LAHORE GYMKHANA</h1>
            <h2>Items With Recipe Report</h2>
            <hr />
            <div class="info">
                Department: <strong><span id="spnDeptPrint"><%= ddlDepartment.SelectedItem.Text %></span></strong> | 
                Item Code: <strong><span id="spnItemPrint"><%= string.IsNullOrEmpty(txtItemCode.Text) ? "All" : txtItemCode.Text %></span></strong> | 
                Date: <strong><%= DateTime.Now.ToString("dd-MM-yyyy HH:mm") %></strong>
            </div>
            <hr class="hr-light" />
        </div>
        
        <!-- Web Header -->
        <div class="report-title">LAHORE GYMKHANA - Items With Recipe</div>
        
        <!-- Filter Section -->
        <div class="filter-section no-print">
            <div class="form-group">
                <label for="ddlDepartment">Department:</label>
                <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="department-dropdown" AutoPostBack="false">
                </asp:DropDownList>
            </div>
            
            <div class="form-group">
                <label for="txtItemCode">Item Code:</label>
                <asp:TextBox ID="txtItemCode" runat="server" CssClass="item-code-input" placeholder="Enter Item Code..."></asp:TextBox>
            </div>
            
            <div class="form-group button-group">
                <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn-search" OnClick="btnSearch_Click" />
                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn-search" OnClick="btnClear_Click" style="background: #6c757d;" />
            </div>
            
            <div class="form-group button-group">
                <asp:Button ID="btnPrint" runat="server" Text="Print Report" CssClass="btn-print" OnClientClick="return PrintReport();" UseSubmitBehavior="false" />
            </div>
        </div>

        <!-- Report Display -->
        <div id="divReport" runat="server">
            <asp:PlaceHolder ID="phReport" runat="server"></asp:PlaceHolder>
        </div>
        
        <!-- Hidden field to store report data -->
        <asp:HiddenField ID="hfReportData" runat="server" />
    </div>

    <script type="text/javascript">
        function PrintReport() {
            try {
                // Method 1: Try to get from placeholder
                var reportContainer = document.getElementById('<%= phReport.ClientID %>');
                var reportHTML = '';

                if (reportContainer) {
                    reportHTML = reportContainer.innerHTML;
                }

                // If no data in placeholder, try divReport
                if (!reportHTML || reportHTML.trim() == '' || reportHTML.indexOf('No records found') > -1) {
                    var divReport = document.getElementById('<%= divReport.ClientID %>');
                    if (divReport) {
                        reportHTML = divReport.innerHTML;
                    }
                }

                // If still no data, try to get from the grid directly
                if (!reportHTML || reportHTML.trim() == '' || reportHTML.indexOf('No records found') > -1) {
                    var grid = document.querySelector('.report-grid');
                    if (grid) {
                        reportHTML = grid.outerHTML;
                    }
                }

                // Check if we have data
                if (!reportHTML || reportHTML.trim() == '' || reportHTML.indexOf('No records found') > -1 || reportHTML.indexOf('no-data') > -1) {
                    alert('No data found to print. Please search for data first.');
                    return false;
                }

                // Get department name
                var deptDropdown = document.getElementById('<%= ddlDepartment.ClientID %>');
                var deptText = 'All Departments';
                if (deptDropdown && deptDropdown.options) {
                    deptText = deptDropdown.options[deptDropdown.selectedIndex].text;
                }

                // Get item code
                var itemCodeInput = document.getElementById('<%= txtItemCode.ClientID %>');
                var itemCode = 'All';
                if (itemCodeInput && itemCodeInput.value) {
                    itemCode = itemCodeInput.value;
                }

                // Get current date
                var now = new Date();
                var dateStr = now.toLocaleDateString() + ' ' + now.toLocaleTimeString();

                // Build the complete print HTML
                var printHTML = '';
                printHTML += '<!DOCTYPE html>';
                printHTML += '<html>';
                printHTML += '<head>';
                printHTML += '<title>Recipe Report - LAHORE GYMKHANA</title>';
                printHTML += '<style>';
                printHTML += 'body { font-family: Arial, sans-serif; margin: 20px; padding: 0; }';
                printHTML += '.print-header { text-align: center; margin-bottom: 20px; }';
                printHTML += '.print-header h1 { font-size: 28px; margin-bottom: 5px; color: #000; }';
                printHTML += '.print-header h2 { font-size: 20px; margin-top: 0; color: #555; font-weight: normal; }';
                printHTML += '.print-header .info { font-size: 14px; margin: 5px 0; color: #333; }';
                printHTML += '.print-header hr { border: 2px solid #007bff; }';
                printHTML += '.print-header .hr-light { border: 1px solid #ccc; }';
                printHTML += '.report-grid { width: 100%; border-collapse: collapse; font-size: 12px; }';
                printHTML += '.report-grid th { background: #007bff !important; color: white !important; padding: 8px 6px; border: 1px solid #0056b3; text-align: left; }';
                printHTML += '.report-grid td { padding: 6px; border: 1px solid #ddd; }';
                printHTML += '.report-grid tr:nth-child(even) { background: #f9f9f9 !important; }';
                printHTML += '.category-header { background: #e9ecef !important; font-weight: bold; }';
                printHTML += '.category-header td { font-weight: bold; }';
                printHTML += '.total-row { background: #fffbcc !important; font-weight: bold; }';
                printHTML += '.item-row td { padding-left: 30px; }';
                printHTML += '.header-row th { background: #007bff; color: white; }';
                printHTML += '.no-print { display: none !important; }';
                printHTML += '.filter-section { display: none !important; }';
                printHTML += '.report-title { display: none !important; }';
                printHTML += '@media print { body { margin: 0; padding: 10px; } }';
                printHTML += '</style>';
                printHTML += '</head>';
                printHTML += '<body>';

                // Print Header
                printHTML += '<div class="print-header">';
                printHTML += '<h1>LAHORE GYMKHANA</h1>';
                printHTML += '<h2>Items With Recipe Report</h2>';
                printHTML += '<hr />';
                printHTML += '<div class="info">';
                printHTML += 'Department: <strong>' + deptText + '</strong> | ';
                printHTML += 'Item Code: <strong>' + itemCode + '</strong> | ';
                printHTML += 'Date: <strong>' + dateStr + '</strong>';
                printHTML += '</div>';
                printHTML += '<hr class="hr-light" />';
                printHTML += '</div>';

                // Report Content
                printHTML += reportHTML;

                printHTML += '</body>';
                printHTML += '</html>';

                // Open new window and print
                var printWindow = window.open('', '_blank', 'width=1000,height=800,scrollbars=yes');
                if (!printWindow) {
                    alert('Please allow popups for this website to print.');
                    return false;
                }

                printWindow.document.write(printHTML);
                printWindow.document.close();

                // Wait for content to load then print
                setTimeout(function () {
                    printWindow.focus();
                    printWindow.print();
                }, 1500);

                return false;
            } catch (ex) {
                alert('Error printing: ' + ex.message);
                return false;
            }
        }
    </script>
</asp:Content>
