<%@ Page Title="Item Price Summary - By Outlet" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master"
    AutoEventWireup="true"
    CodeFile="Store_ItemPriceSummaryByOutlet.aspx.cs"
    Inherits="Store_ItemPriceSummaryByOutlet" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
<style>
    /* ===== SCREEN STYLES ===== */
    .report-wrapper {
        font-family: Arial, sans-serif;
        font-size: 11px;
        padding: 10px;
        background: #fff;
    }

    .report-header {
        margin-bottom: 10px;
    }

    .report-header h2 {
        font-size: 14px;
        font-weight: bold;
        margin: 0 0 2px 0;
        color: #000;
    }

    .report-header p {
        font-size: 11px;
        margin: 0;
        color: #333;
    }

    .report-subtitle {
        font-size: 11px;
        font-weight: bold;
        text-decoration: underline;
        margin: 10px 0 4px 0;
        color: #000;
    }

    /* Matrix table */
    .price-matrix {
        border-collapse: collapse;
        width: 100%;
        font-size: 9px;
        table-layout: fixed;
    }

    .price-matrix th,
    .price-matrix td {
        border: 1px solid #ccc;
        padding: 2px 3px;
        text-align: center;
        vertical-align: middle;
        white-space: nowrap;
        overflow: hidden;
    }

    /* Fixed item name column */
    .price-matrix td.item-col,
    .price-matrix th.item-col {
        text-align: left;
        width: 140px;
        min-width: 140px;
        max-width: 140px;
        white-space: normal;
        word-break: break-word;
        font-weight: bold;
        color: #0033cc;
    }

    /* Rotated department header */
    .price-matrix th.dept-header {
        height: 90px;
        width: 36px;
        min-width: 36px;
        max-width: 36px;
        padding: 0;
        vertical-align: bottom;
    }

    .price-matrix th.dept-header div {
        writing-mode: vertical-rl;
        transform: rotate(180deg);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        max-height: 88px;
        font-size: 9px;
        font-weight: normal;
        padding: 2px;
        display: block;
    }

    /* Price cell */
    .price-matrix td.price-cell {
        font-size: 9px;
        color: #000033;
    }

    /* Alternating rows */
    .price-matrix tr.odd-row td {
        background-color: #ffffff;
    }

    .price-matrix tr.even-row td {
        background-color: #f5f5f5;
    }

    /* Item code in blue */
    .item-code {
        color: #0033cc;
        font-weight: bold;
        font-size: 9px;
    }

    /* Footer info */
    .report-footer {
        margin-top: 10px;
        font-size: 9px;
        color: #555;
        border-top: 1px solid #ccc;
        padding-top: 5px;
    }

    /* Buttons */
    .btn-toolbar {
        margin-bottom: 10px;
    }

    .btn-print {
        background-color: #1a5276;
        color: #fff;
        border: none;
        padding: 6px 16px;
        font-size: 12px;
        border-radius: 3px;
        cursor: pointer;
    }

    .btn-print:hover {
        background-color: #154360;
    }

    /* Scrollable container on screen */
    .table-scroll {
        overflow-x: auto;
        overflow-y: visible;
    }

    /* ===== PRINT STYLES ===== */
    @media print {
        @page {
            size: A3 landscape;
            margin: 10mm 8mm 12mm 8mm;
        }

        body * {
            visibility: hidden;
        }

        .printable-area,
        .printable-area * {
            visibility: visible;
        }

        .printable-area {
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
        }

        .btn-toolbar,
        .no-print {
            display: none !important;
        }

        .table-scroll {
            overflow: visible !important;
        }

        .price-matrix {
            font-size: 7.5px;
            page-break-inside: auto;
        }

        .price-matrix tr {
            page-break-inside: avoid;
        }

        .price-matrix th.dept-header div {
            font-size: 7.5px;
        }

        .price-matrix td.item-col,
        .price-matrix th.item-col {
            width: 120px;
            min-width: 120px;
            max-width: 120px;
        }

        .price-matrix th.dept-header {
            width: 30px;
            min-width: 30px;
            max-width: 30px;
        }

        .report-footer {
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            font-size: 8px;
        }
    }
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<div class="report-wrapper printable-area">

    <!-- Header -->
    <div class="report-header">
        <h2>LAHORE GYMKHANA</h2>
        <p>Items Price By Outlet (Only Active)</p>
    </div>

    <!-- Toolbar -->
    <div class="btn-toolbar no-print">
        <button class="btn-print" onclick="window.print(); return false;">??? Print / Save as PDF</button>
    </div>

    <!-- Sub-title -->
    <div class="report-subtitle">Items Price Summary - By Outlet</div>

    <!-- Matrix Table -->
    <div class="table-scroll">
        <asp:Literal ID="litReportTable" runat="server"></asp:Literal>
    </div>

    <!-- Footer -->
    <div class="report-footer">
        <asp:Literal ID="litFooter" runat="server"></asp:Literal>
    </div>

</div>

</asp:Content>

