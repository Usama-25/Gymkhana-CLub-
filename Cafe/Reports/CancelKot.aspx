<%@ Page Title="KOT Cancelled/Delivered Report" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" AutoEventWireup="true" CodeFile="CancelKot.aspx.cs" Inherits="CancelKot" %>

<%-- Register Assembly AjaxControlToolkit disabled --%>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <style type="text/css">

        /* -- Filter Form ---------------------------------------- */
        .style1      { width: 100%; text-align: center; }
        .auto-style1 { width: 50%; text-align: right; font-weight: bold; }
        .style3      { width: 50%; text-align: left; }

        /* -- Report Container ----------------------------------- */
        .report-container {
            width: 92%;
            max-width: 960px;
            margin: 24px auto;
            background: #ffffff;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            padding: 32px 40px;
            font-family: 'Segoe UI', Calibri, 'Helvetica Neue', sans-serif;
            font-size: 13px;
            color: #1a1a2e;
            box-shadow: 0 2px 12px rgba(0,0,0,0.07);
        }

        /* -- No-data message ------------------------------------ */
        .no-data {
            text-align: center;
            padding: 60px 20px;
            color: #666;
            font-style: italic;
            font-family: 'Segoe UI', sans-serif;
        }

        /* -- Report Header -------------------------------------- */
        .rpt-header {
            text-align: center;
            padding-bottom: 20px;
            border-bottom: 2px solid #1a1a2e;
            margin-bottom: 28px;
        }
        .rpt-org {
            font-size: 20px;
            font-weight: 700;
            letter-spacing: 2px;
            text-transform: uppercase;
            color: #1a1a2e;
        }
        .rpt-title {
            font-size: 14px;
            font-weight: 600;
            color: #4a4a6a;
            margin-top: 4px;
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }
        .rpt-meta {
            display: flex;
            justify-content: center;
            gap: 40px;
            margin-top: 12px;
            font-size: 12.5px;
            color: #444;
        }
        .rpt-meta strong { color: #1a1a2e; }

        /* -- KOT Block ------------------------------------------ */
        .kot-block {
            margin-bottom: 28px;
            border: 1px solid #d8dde6;
            border-radius: 5px;
            overflow: hidden;
            page-break-inside: avoid;
        }

        /* KOT Meta Bar */
        .kot-meta-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #f4f6fb;
            padding: 10px 16px;
            border-bottom: 1px solid #d8dde6;
        }
        .kot-meta-left {
            display: flex;
            gap: 28px;
            flex-wrap: wrap;
        }
        .kot-label {
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            color: #777;
            letter-spacing: 0.4px;
            margin-right: 4px;
        }
        .kot-value {
            font-size: 13px;
            font-weight: 600;
            color: #1a1a2e;
        }

        /* Status Badge */
        .badge {
            display: inline-block;
            padding: 3px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .badge-cancelled {
            background: #fde8e8;
            color: #c0392b;
            border: 1px solid #f5c6c6;
        }
        .badge-delivered {
            background: #e6f4ea;
            color: #1e7e34;
            border: 1px solid #b8dfc2;
        }

        /* Items Table */
        .items-table {
            width: 100%;
            border-collapse: collapse;
        }
        .items-table thead tr {
            background: #1a1a2e;
            color: #ffffff;
        }
        .items-table thead th {
            padding: 9px 14px;
            font-size: 11.5px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            text-align: left;
        }
        .items-table tbody tr {
            border-bottom: 1px solid #edf0f5;
        }
        .items-table tbody tr:last-child {
            border-bottom: none;
        }
        .items-table tbody tr:nth-child(even) {
            background: #f9fafc;
        }
        .items-table tbody td {
            padding: 8px 14px;
            color: #2c2c3e;
        }
        .items-table tfoot tr {
            background: #eef0f8;
            border-top: 1.5px solid #c0c8dc;
        }
        .items-table tfoot td {
            padding: 8px 14px;
            font-weight: 600;
            color: #1a1a2e;
        }
        .foot-label { text-align: right; font-style: italic; color: #555; }
        .foot-val   { font-weight: 700; color: #1a1a2e; }

        /* Column widths */
        .col-code { width: 18%; }
        .col-name { width: 62%; }
        .col-qty  { width: 20%; text-align: center; }

        /* -- Grand Total Bar ------------------------------------ */
        .grand-total-bar {
            margin-top: 8px;
            padding: 14px 20px;
            background: #1a1a2e;
            color: #ffffff;
            border-radius: 5px;
            display: flex;
            justify-content: center;
            gap: 60px;
            font-size: 13.5px;
            letter-spacing: 0.3px;
        }
        .grand-total-bar strong {
            font-size: 15px;
            color: #a8d8ea;
        }

        /* -- Print Button --------------------------------------- */
        .print-button {
            text-align: center;
            margin: 16px 0;
        }

        /* -- Print Styles --------------------------------------- */
        @media print {
            /* Hide everything except the report */
            .no-print,
            .bxmain,
            .inner_content,
            h2,
            .style1,
            .btn_1,
            .print-button {
                display: none !important;
            }

            body { margin: 0; padding: 0; }

            .report-container {
                width: 100% !important;
                max-width: 100% !important;
                margin: 0 !important;
                padding: 16px 20px !important;
                border: none !important;
                box-shadow: none !important;
                border-radius: 0 !important;
                font-size: 11px !important;
            }

            /* Keep header colours in print */
            .rpt-org     { font-size: 16px !important; }
            .rpt-title   { font-size: 12px !important; }

            /* Keep dark table header in print */
            .items-table thead tr {
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
                background: #1a1a2e !important;
                color: #ffffff !important;
            }
            .grand-total-bar {
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
                background: #1a1a2e !important;
                color: #ffffff !important;
            }
            .badge-cancelled {
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }
            .badge-delivered {
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }
            .kot-meta-bar {
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }

            .kot-block {
                page-break-inside: avoid;
                page-break-after: auto;
                margin-bottom: 18px !important;
            }

            .rpt-meta {
                flex-direction: row;
                flex-wrap: wrap;
            }
        }

        /* -- Screen shadow -------------------------------------- */
        @media screen {
            .report-container {
                box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            }
        }
    </style>

    <script type="text/javascript">
        function ClientItemSelected2(sender, e) {
            $get("<%=hfItemCode.ClientID %>").value = e.get_value();
        }

        function PrintReport() {
            var reportContent = document.getElementById('reportContainer').innerHTML;

            var printWindow = window.open('', '_blank', 'width=900,height=700,toolbar=yes,scrollbars=yes');

            printWindow.document.write('<!DOCTYPE html><html><head>');
            printWindow.document.write('<title>KOT Cancelled/Delivered Report - Lahore Gymkhana</title>');
            printWindow.document.write('<style>');
            printWindow.document.write('*{box-sizing:border-box;}');
            printWindow.document.write('body{font-family:"Segoe UI",Calibri,"Helvetica Neue",sans-serif;font-size:12px;color:#1a1a2e;margin:20px;background:#fff;}');

            /* Header */
            printWindow.document.write('.rpt-header{text-align:center;padding-bottom:16px;border-bottom:2px solid #1a1a2e;margin-bottom:24px;}');
            printWindow.document.write('.rpt-org{font-size:18px;font-weight:700;letter-spacing:2px;text-transform:uppercase;}');
            printWindow.document.write('.rpt-title{font-size:13px;font-weight:600;color:#4a4a6a;margin-top:4px;text-transform:uppercase;letter-spacing:0.5px;}');
            printWindow.document.write('.rpt-meta{display:flex;justify-content:center;gap:40px;margin-top:10px;font-size:12px;color:#444;}');
            printWindow.document.write('.rpt-meta strong{color:#1a1a2e;}');

            /* KOT block */
            printWindow.document.write('.kot-block{margin-bottom:22px;border:1px solid #d8dde6;border-radius:4px;overflow:hidden;page-break-inside:avoid;}');
            printWindow.document.write('.kot-meta-bar{display:flex;justify-content:space-between;align-items:center;background:#f4f6fb;padding:8px 14px;border-bottom:1px solid #d8dde6;}');
            printWindow.document.write('.kot-meta-left{display:flex;gap:24px;flex-wrap:wrap;}');
            printWindow.document.write('.kot-label{font-size:10px;font-weight:600;text-transform:uppercase;color:#777;margin-right:4px;}');
            printWindow.document.write('.kot-value{font-size:12px;font-weight:600;color:#1a1a2e;}');

            /* Badge */
            printWindow.document.write('.badge{display:inline-block;padding:2px 10px;border-radius:20px;font-size:10px;font-weight:700;text-transform:uppercase;}');
            printWindow.document.write('.badge-cancelled{background:#fde8e8;color:#c0392b;border:1px solid #f5c6c6;-webkit-print-color-adjust:exact;print-color-adjust:exact;}');
            printWindow.document.write('.badge-delivered{background:#e6f4ea;color:#1e7e34;border:1px solid #b8dfc2;-webkit-print-color-adjust:exact;print-color-adjust:exact;}');

            /* Table */
            printWindow.document.write('.items-table{width:100%;border-collapse:collapse;}');
            printWindow.document.write('.items-table thead tr{background:#1a1a2e;color:#fff;-webkit-print-color-adjust:exact;print-color-adjust:exact;}');
            printWindow.document.write('.items-table thead th{padding:8px 12px;font-size:10.5px;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;text-align:left;}');
            printWindow.document.write('.items-table tbody tr{border-bottom:1px solid #edf0f5;}');
            printWindow.document.write('.items-table tbody tr:nth-child(even){background:#f9fafc;-webkit-print-color-adjust:exact;print-color-adjust:exact;}');
            printWindow.document.write('.items-table tbody td{padding:7px 12px;color:#2c2c3e;}');
            printWindow.document.write('.items-table tfoot tr{background:#eef0f8;border-top:1.5px solid #c0c8dc;-webkit-print-color-adjust:exact;print-color-adjust:exact;}');
            printWindow.document.write('.items-table tfoot td{padding:7px 12px;font-weight:600;}');
            printWindow.document.write('.foot-label{text-align:right;font-style:italic;color:#555;}');
            printWindow.document.write('.col-code{width:18%}.col-name{width:62%}.col-qty{width:20%;text-align:center;}');

            /* Grand total */
            printWindow.document.write('.grand-total-bar{margin-top:8px;padding:12px 18px;background:#1a1a2e;color:#fff;border-radius:4px;display:flex;justify-content:center;gap:50px;font-size:13px;-webkit-print-color-adjust:exact;print-color-adjust:exact;}');
            printWindow.document.write('.grand-total-bar strong{font-size:14px;color:#a8d8ea;}');

            printWindow.document.write('</style></head><body>');
            printWindow.document.write(reportContent);
            printWindow.document.write('</body></html>');
            printWindow.document.close();

            printWindow.onload = function () {
                printWindow.print();
                printWindow.onafterprint = function () { printWindow.close(); };
            };
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <asp:ScriptManager ID="ToolkitScriptManager1" runat="server">
    </asp:ScriptManager>

    <div class="bxmain inner_content" style="width: 100%;">
        <h2><span>Cancelled/Delivered KOT Report</span></h2>
        <table class="style1">
            <tr>
                <td class="auto-style1">Department :</td>
                <td class="style3">
                    <asp:DropDownList ID="ddlSubDept" runat="server" CssClass="dropdown"></asp:DropDownList>
                </td>
            </tr>
            <tr>
                <td class="auto-style1">Start Date :</td>
                <td class="style3">
                    <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td class="auto-style1">End Date :</td>
                <td class="style3">
                    <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td class="auto-style1">Item Name :</td>
                <td class="style3">
                    <asp:TextBox ID="txtItemName" runat="server" OnTextChanged="txtItemName_TextChanged"></asp:TextBox>
                    <%-- AutoCompleteExtender disabled --%>
                    <asp:HiddenField ID="hfItemCode" runat="server" />
                </td>
            </tr>
            <tr>
                <td colspan="2" align="center">
                    <asp:Button ID="Button_report" runat="server" Text="View Report"
                        OnClick="Button_Report_Click" CssClass="btn_1" />
                </td>
            </tr>
        </table>
    </div>

    <div class="print-button no-print">
        <asp:Button ID="btnPrint" runat="server" Text="&#128438; Print Report" CssClass="btn_1"
            OnClientClick="PrintReport(); return false;" Visible="false"
            style="background-color:#1a1a2e; color:#fff; padding:10px 24px; cursor:pointer; border-radius:4px; font-size:13px;" />
    </div>

    <div id="reportContainer" runat="server" class="report-container">
        <!-- Report will be dynamically generated here -->
    </div>
</asp:Content>



