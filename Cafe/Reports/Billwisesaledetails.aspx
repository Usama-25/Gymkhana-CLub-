<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master"
    AutoEventWireup="true"
    CodeFile="Billwisesaledetails.aspx.cs"
    Inherits="Store_Cash_Sale_Invoice_Wise" %>

<%-- Register Assembly AjaxControlToolkit disabled --%>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">

    <style type="text/css">

        body {
            font-family: Arial, Helvetica, sans-serif;
            background: #f4f4f4;
        }

        .report-main {
            width: 100%;
            padding: 15px;
        }

        /* -- FILTER BOX -- */
        .filter-box {
            width: 100%;
            background: #ffffff;
            border: 1px solid #dcdcdc;
            padding: 20px;
            margin-bottom: 20px;
        }

        .filter-table {
            width: 100%;
        }

        .filter-table td {
            padding: 8px;
        }

        .heading {
            font-size: 24px;
            font-weight: bold;
            color: #1d3557;
        }

        .sub-heading {
            font-size: 18px;
            color: #555;
            margin-top: 5px;
        }

        .btn-report {
            background: #1d3557;
            color: white;
            border: none;
            padding: 10px 25px;
            cursor: pointer;
            border-radius: 4px;
            font-weight: bold;
        }

        .btn-print {
            background: #198754;
            color: white;
            border: none;
            padding: 10px 25px;
            cursor: pointer;
            border-radius: 4px;
            font-weight: bold;
        }

        /* -- ONE-TIME PAGE HEADER -- */
        .page-header {
            width: 100%;
            background: white;
            border: 1px solid #d9d9d9;
            padding: 16px 20px 10px 20px;
            margin-bottom: 0;
            border-bottom: none;
        }

        .page-header .company-name {
            font-size: 22px;
            font-weight: bold;
            color: #222;
            letter-spacing: 0.5px;
        }

        .page-header .report-title {
            font-size: 15px;
            font-weight: bold;
            color: #444;
            margin-top: 2px;
        }

        .page-header .report-date-range {
            font-size: 12px;
            color: #666;
            margin-top: 4px;
        }

        /* -- BILL BOX (no top border — shares with header or previous bill) -- */
        .bill-box {
            width: 100%;
            background: white;
            border: 1px solid #d9d9d9;
            border-top: none;
            padding: 14px 20px 16px 20px;
            margin-bottom: 0;
            /* NO page-break-after — all bills flow on same page */
        }

        /* thin separator line between consecutive bills */
        .bill-box + .bill-box {
            border-top: 2px dashed #cccccc;
        }

        /* -- INFO TABLE (Check No / Member / Outlet row) -- */
        .info-table {
            width: 100%;
            margin-top: 10px;
            border-collapse: collapse;
        }

        .info-table td {
            padding: 4px 6px;
            vertical-align: top;
            font-size: 12.5px;
        }

        /* -- ITEM TABLE -- */
        .item-table {
            width: 100%;
            margin-top: 12px;
            border-collapse: collapse;
        }

        .item-table th {
            background: #e9ecef;
            border: 1px solid #cfcfcf;
            padding: 6px 8px;
            font-size: 12px;
            text-align: center;
        }

        .item-table td {
            border: 1px solid #dcdcdc;
            padding: 6px 8px;
            font-size: 12px;
        }

        .text-center { text-align: center; }
        .text-right  { text-align: right;  }

        /* -- SUMMARY (Net Payable / GST / Total) -- */
        .summary-wrap {
            width: 100%;
            margin-top: 8px;
            overflow: hidden;
        }

        .summary-table {
            width: 42%;
            float: right;
            border-collapse: collapse;
        }

        .summary-table td {
            border: 1px solid #dcdcdc;
            padding: 5px 8px;
            font-size: 12px;
        }

        .summary-table .lbl {
            background: #f5f5f5;
            font-weight: bold;
            width: 55%;
        }

        .clearfix { clear: both; }

        /* -- PRINT STYLES -- */
        @media print {
            .no-print { 
                display: none !important; 
            }
            
            body { 
                background: white; 
                margin: 0;
                padding: 0;
            }
            
            .report-main {
                padding: 0;
                margin: 0;
            }
            
            .page-header,
            .bill-box {
                border-color: #999;
                box-shadow: none;
                page-break-inside: avoid;
            }
            
            /* Ensure all text is visible */
            .item-table th,
            .item-table td,
            .summary-table td,
            .info-table td {
                color: black !important;
            }
            
            /* Prevent cutting of content */
            .bill-box {
                page-break-after: avoid;
                break-inside: avoid;
            }
            
            /* Ensure borders print */
            .item-table th,
            .item-table td,
            .summary-table td {
                border: 1px solid #000 !important;
            }
        }

    </style>

    <script type="text/javascript">

        function PrintReport() {
            // Check if report has content
            var reportContainer = document.getElementById('reportContainer');
            if (!reportContainer) {
                alert('Report container not found.');
                return;
            }

            var reportHTML = reportContainer.cloneNode(true);

            // Remove filter area from print copy
            var filterBox = reportHTML.querySelector('.filter-box');
            if (filterBox) {
                filterBox.remove();
            }

            // Get all styles
            var styles = document.querySelectorAll('style');
            var styleHTML = '';
            styles.forEach(function (style) {
                styleHTML += style.innerHTML;
            });

            // Open new window for printing
            var printWindow = window.open('', '_blank', 'width=900,height=700,toolbar=yes,scrollbars=yes');

            printWindow.document.write('<!DOCTYPE html>');
            printWindow.document.write('<html>');
            printWindow.document.write('<head>');
            printWindow.document.write('<title>Bill Wise Sale Report - Lahore Gymkhana</title>');
            printWindow.document.write('<style>' + styleHTML + '</style>');
            printWindow.document.write('<style>');
            printWindow.document.write('body { margin: 0; padding: 20px; }');
            printWindow.document.write('.no-print { display: none !important; }');
            printWindow.document.write('.filter-box { display: none !important; }');
            printWindow.document.write('</style>');
            printWindow.document.write('</head>');
            printWindow.document.write('<body>');
            printWindow.document.write(reportHTML.innerHTML);
            printWindow.document.write('</body>');
            printWindow.document.write('</html>');

            printWindow.document.close();

            // Wait for content to load then print
            printWindow.onload = function () {
                printWindow.focus();
                printWindow.print();
                printWindow.onafterprint = function () {
                    printWindow.close();
                };
            };
        }

        function ClientItemSelected2(sender, e) {
            $get("<%=hfItemCode.ClientID %>").value = e.get_value();
        }

    </script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

    <asp:ScriptManager ID="ToolkitScriptManager1" runat="server">
    </asp:ScriptManager>

    <div id="reportContainer" class="report-main">

        <!-- -- FILTER AREA -- -->
        <div class="filter-box no-print">

            <div class="heading">Bill Wise Sale Detail Report</div>
            <div class="sub-heading">Lahore Gymkhana</div>

            <br />

            <table class="filter-table">
                <tr>
                    <td width="15%"><b>Location</b></td>
                    <td width="35%">
                        <asp:DropDownList ID="ddlSubDept" runat="server" CssClass="form-control">
                        </asp:DropDownList>
                    </td>
                    <td width="15%"><b>Item Name</b></td>
                    <td width="35%">
                        <asp:TextBox ID="txtItemName" runat="server" CssClass="form-control"></asp:TextBox>

                        <%-- AutoCompleteExtender disabled --%>

                        <asp:HiddenField ID="hfItemCode" runat="server" />
                    </td>
                </tr>

                <tr>
                    <td><b>Start Date</b></td>
                    <td>
                        <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="form-control">
                        </asp:TextBox>
                    </td>
                    <td><b>End Date</b></td>
                    <td>
                        <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="form-control">
                        </asp:TextBox>
                    </td>
                </tr>

                <tr>
                    <td colspan="4" align="center">
                        <asp:Button ID="Button_report" runat="server"
                            Text="VIEW REPORT"
                            CssClass="btn-report"
                            OnClick="Button_Report_Click" />
                        &nbsp;
                        <input type="button" value="PRINT" class="btn-print" onclick="PrintReport();" />
                    </td>
                </tr>
            </table>

        </div>

        <!-- -- REPORT AREA -- -->
        <asp:Literal ID="ltReport" runat="server"></asp:Literal>

    </div>

</asp:Content>


