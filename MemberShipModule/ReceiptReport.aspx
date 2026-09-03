<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ReceiptReport.aspx.cs" Inherits="Finance_ReceiptReport" %>

<%--<!DOCTYPE html>
<html>
<head>
    <title>Receipt</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 13px;
            margin: 0;
            padding: 20px;
            background: #f4f4f4;
        }

        .receipt-container {
            width: 720px;
            margin: 0 auto;
            background: #fff;
            border: 1px solid #ccc;
            padding: 30px 40px;
        }

        /* Header */
        .receipt-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 2px solid #342867;
            padding-bottom: 12px;
            margin-bottom: 18px;
        }

        .org-name {
            font-size: 20px;
            font-weight: 700;
            color: #342867;
        }

        .org-sub {
            font-size: 11px;
            color: #777;
            margin-top: 3px;
        }

        .receipt-title {
            text-align: right;
        }

        .receipt-title h2 {
            margin: 0;
            font-size: 22px;
            color: #342867;
            letter-spacing: 2px;
            text-transform: uppercase;
        }

        .receipt-no-badge {
            background: #342867;
            color: #fff;
            font-size: 12px;
            font-weight: 700;
            padding: 3px 10px;
            margin-top: 5px;
            display: inline-block;
        }

        /* Info rows */
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0;
            border: 1px solid #ddd;
            margin-bottom: 18px;
        }

        .info-cell {
            padding: 7px 12px;
            border-bottom: 1px solid #eee;
            border-right: 1px solid #eee;
        }

        .info-cell:nth-child(2n) {
            border-right: none;
        }

        .info-cell.span-2 {
            grid-column: span 2;
            border-right: none;
        }

        .info-cell label {
            display: block;
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            color: #888;
            letter-spacing: 0.05em;
            margin-bottom: 2px;
        }

        .info-cell span {
            font-size: 13px;
            color: #222;
            font-weight: 500;
        }

        /* Members table */
        .members-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 18px;
            font-size: 12px;
        }

        .members-table th {
            background: #342867;
            color: #fff;
            padding: 7px 10px;
            text-align: left;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }

        .members-table td {
            padding: 6px 10px;
            border-bottom: 1px solid #eee;
        }

        .members-table tr:nth-child(even) td {
            background: #f9f9f9;
        }

        /* Total row */
        .total-row {
            display: flex;
            justify-content: flex-end;
            margin-bottom: 18px;
        }

        .total-box {
            border: 2px solid #342867;
            padding: 10px 20px;
            min-width: 220px;
        }

        .total-box .total-label {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            color: #888;
        }

        .total-box .total-amount {
            font-size: 22px;
            font-weight: 700;
            color: #342867;
        }

        /* Notes */
        .notes-box {
            background: #f9f9f9;
            border: 1px solid #ddd;
            padding: 8px 12px;
            font-size: 12px;
            color: #555;
            margin-bottom: 20px;
        }

        .notes-label {
            font-weight: 700;
            text-transform: uppercase;
            font-size: 10px;
            color: #888;
            letter-spacing: 0.05em;
        }

        /* Footer */
        .receipt-footer {
            border-top: 1px solid #ddd;
            padding-top: 10px;
            display: flex;
            justify-content: space-between;
            font-size: 11px;
            color: #888;
        }

        /* Print button */
        .btn-print {
            display: block;
            width: 720px;
            margin: 14px auto 0;
            padding: 8px;
            background: #342867;
            color: #fff;
            border: none;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            letter-spacing: 0.05em;
            text-transform: uppercase;
        }

        @media print {
            body { background: #fff; padding: 0; }
            .btn-print { display: none; }
            .receipt-container { border: none; box-shadow: none; }
        }
    </style>
</head>
<body>
    
    
    <form id="form1" runat="server"> 
    <div class="receipt-container">

        <!-- Header -->
        <div class="receipt-header">
            <div>
                <div class="org-name">Your Organization Name</div>
                <div class="org-sub">Finance Department</div>
            </div>
            <div class="receipt-title">
                <h2>Receipt</h2>
                <span class="receipt-no-badge">
                    <asp:Literal ID="litReceiptNo" runat="server"></asp:Literal>
                </span>
            </div>
        </div>

        <!-- Info Grid -->
        <div class="info-grid">
            <div class="info-cell">
                <label>Receipt Date</label>
                <span><asp:Literal ID="litDate" runat="server"></asp:Literal></span>
            </div>
            <div class="info-cell">
                <label>Receipt Type</label>
                <span><asp:Literal ID="litType" runat="server"></asp:Literal></span>
            </div>
            <div class="info-cell">
                <label>Receipt Mode</label>
                <span><asp:Literal ID="litMode" runat="server"></asp:Literal></span>
            </div>
            <div class="info-cell">
                <label>Mode of Payment</label>
                <span><asp:Literal ID="litPaymentMode" runat="server"></asp:Literal></span>
            </div>
            <div class="info-cell">
                <label>Contact Person</label>
                <span><asp:Literal ID="litPerson" runat="server"></asp:Literal></span>
            </div>
            <div class="info-cell">
                <label>Phone</label>
                <span><asp:Literal ID="litPhone" runat="server"></asp:Literal></span>
            </div>
            <div class="info-cell">
                <label>CNIC</label>
                <span><asp:Literal ID="litCNIC" runat="server"></asp:Literal></span>
            </div>
            <div class="info-cell">
                <label>Payment Head</label>
                <span><asp:Literal ID="litPayHead" runat="server"></asp:Literal></span>
            </div>
            <div class="info-cell">
                <label>Payment Reference / Cheque #</label>
                <span><asp:Literal ID="litPayRef" runat="server"></asp:Literal></span>
            </div>
            <div class="info-cell">
                <label>Department</label>
                <span><asp:Literal ID="litDept" runat="server"></asp:Literal></span>
            </div>
        </div>

        <!-- Members Table -->
        <asp:GridView ID="gvMembers" runat="server"
            AutoGenerateColumns="False"
            CssClass="members-table"
            GridLines="None">
            <Columns>
                <asp:BoundField DataField="MemberNo"        HeaderText="Member No" />
                <asp:BoundField DataField="MemberName"      HeaderText="Member Name" />
                <asp:BoundField DataField="ReceiptAmount"   HeaderText="Receipt Amount"
                    DataFormatString="{0:N2}" HtmlEncode="false" />
            </Columns>
        </asp:GridView>

        <!-- Total -->
        <div class="total-row">
            <div class="total-box">
                <div class="total-label">Bank Charges</div>
                <div style="font-size:14px; font-weight:600; color:#555; margin-bottom:6px;">
                    <asp:Literal ID="litBankPct" runat="server"></asp:Literal>% &nbsp;=&nbsp;
                    <asp:Literal ID="litBankAmt" runat="server"></asp:Literal>
                </div>
                <div class="total-label">Total Amount Received</div>
                <div class="total-amount">
                    PKR <asp:Literal ID="litTotal" runat="server"></asp:Literal>
                </div>
            </div>
        </div>

        <!-- Notes -->
        <div class="notes-box">
            <div class="notes-label">Notes</div>
            <asp:Literal ID="litNotes" runat="server"></asp:Literal>
        </div>

        <!-- Footer -->
        <div class="receipt-footer">
            <span>Generated: <asp:Literal ID="litGenDate" runat="server"></asp:Literal></span>
            <span>Authorized Signature: ____________________</span>
        </div>

    </div>

    <button class="btn-print" onclick="window.print()">🖨 Print / Save as PDF</button>
        </form>
</body>
</html>--%>




  <!DOCTYPE html>
<html>
<head>
    <title>Receipt - Lahore Gymkhana</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Times New Roman', Times, serif;
            font-size: 13px;
            background: #e8e8e8;
            padding: 20px;
        }

        .page-wrap {
            width: 900px;
            margin: 0 auto;
        }

        .receipt-box {
            background: #fff;
            padding: 30px 40px 24px 40px;
            border: 1px solid #ccc;
        }

        /* ── HEADER ── */
        .receipt-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 10px;
        }

        .org-info .org-name {
            font-size: 26px;
            font-weight: 700;
            color: #000;
            letter-spacing: 1px;
            font-family: Arial, sans-serif;
        }

        .org-info .org-addr {
            font-style: italic;
            font-size: 12px;
            color: #333;
            margin-top: 4px;
            line-height: 1.6;
        }

        .org-logo img {
            width: 240px;
            height: 90px;
            object-fit:contain;
        }

        /* ── TITLE ── */
        .receipt-title {
            text-align: center;
            font-size: 15px;
            font-weight: 700;
            font-style: italic;
            text-decoration: underline;
            margin: 8px 0 18px 0;
            letter-spacing: 0.5px;
        }

        /* ── FIELD ROWS ── */
        .field-row {
            display: flex;
            align-items: baseline;
            margin-bottom: 14px;
            gap: 6px;
        }

        .field-label {
            font-style: italic;
            font-size: 13px;
            color: #000;
            white-space: nowrap;
            flex-shrink: 0;
            min-width: 185px;
        }

        .field-value {
            border-bottom: 1px solid #000;
            font-size: 13.5px;
            font-weight: 600;
            color: #000;
            padding: 0 6px 1px 6px;
            min-width: 130px;
            flex: 1;
        }

        /* Row with Receipt No + Date inline */
        .row-receipt-date {
            display: flex;
            align-items: baseline;
            margin-bottom: 14px;
            gap: 6px;
        }

        .row-receipt-date .field-label {
            min-width: 185px;
        }

        .row-receipt-date .val-rcptno {
            border-bottom: 1px solid #000;
            font-size: 13.5px;
            font-weight: 600;
            padding: 0 6px 1px 6px;
            min-width: 200px;
        }

        .row-receipt-date .val-date {
            border-bottom: 1px solid #000;
            font-size: 13.5px;
            font-weight: 600;
            padding: 0 6px 1px 6px;
            min-width: 110px;
            margin-left: 16px;
            flex: 1;
        }

        /* Row: Amount + Bank Charges + Net Amount */
        .row-amounts {
            display: flex;
            align-items: baseline;
            margin-bottom: 14px;
            gap: 6px;
        }

        .row-amounts .field-label {
            min-width: 185px;
        }

        .row-amounts .val-amount {
            border-bottom: 1px solid #000;
            font-size: 13.5px;
            font-weight: 600;
            padding: 0 6px 1px 6px;
            min-width: 110px;
        }

        .row-amounts .lbl-bank {
            font-style: italic;
            font-size: 13px;
            white-space: nowrap;
            margin-left: 10px;
            flex-shrink: 0;
        }

        .row-amounts .val-bank {
            border-bottom: 1px solid #000;
            font-size: 13.5px;
            font-weight: 600;
            padding: 0 6px 1px 6px;
            min-width: 80px;
        }

        .row-amounts .lbl-net {
            font-style: italic;
            font-size: 13px;
            white-space: nowrap;
            margin-left: 10px;
            flex-shrink: 0;
        }

        .row-amounts .val-net {
            border-bottom: 1px solid #000;
            font-size: 13.5px;
            font-weight: 600;
            padding: 0 6px 1px 6px;
            min-width: 100px;
            flex: 1;
        }

        /* Members Table Style */
        .members-table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            font-size: 13.5px;
            font-family: 'Times New Roman', Times, serif;
        }
        .members-table th {
            border-bottom: 1px solid #000;
            padding: 4px 6px;
            text-align: left;
            font-style: italic;
            font-weight: 700;
        }
        .members-table td {
            border-bottom: 1px solid #eee;
            padding: 8px 6px;
            vertical-align: bottom;
        }
        .members-table .align-right {
            text-align: right;
        }
        .members-table .align-left {
            text-align: left;
        }

        /* ── SIGNATURE SECTION ── */
        .sig-section {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
            margin-bottom: 8px;
        }

        .sig-block {
            width: 220px;
        }

        .sig-name {
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 4px;
        }

        .sig-line {
            border-top: 1px solid #000;
            margin-bottom: 4px;
        }

        .sig-caption {
            font-style: italic;
            font-size: 11.5px;
            text-align: center;
            color: #333;
        }

        /* ── FOOTER ── */
        .receipt-footer {
            display: flex;
            justify-content: space-between;
            margin-top: 14px;
            font-style: italic;
            font-size: 11px;
            color: #444;
        }

        /* ── Print / Action Buttons ── */
        .btn-row {
            width: 900px;
            margin: 14px auto 0;
            display: flex;
            gap: 10px;
        }

        .btn-print, .btn-close {
            flex: 1;
            padding: 8px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            border: none;
            letter-spacing: 0.05em;
            text-transform: uppercase;
        }

        .btn-print { background: #342867; color: #fff; }
        .btn-close { background: #888; color: #fff; }

        @media print {
            body { background: #fff; padding: 0; }
            .btn-row { display: none; }
            .receipt-box { border: none; }
            .page-wrap { width: 100%; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <div class="page-wrap">
        <div class="receipt-box">

            <!-- ══ HEADER ══ -->
            <div class="receipt-header">
                <div class="org-info">
                    <div class="org-name">LAHORE GYMKHANA</div>
                    <div class="org-addr">
                        The Mall, Upper Shahrah-e-Quaid-e-Azam, Lahore<br />
                        Lahore 54840, Pakistan
                    </div>
                </div>
                <div class="org-logo">
                    <img src="../resources/images/GymkhanaReportLogo.png" alt="Logo"
                         onerror="this.style.display='none'" />
                </div>
            </div>

            <!-- ══ TITLE ══ -->
            <div class="receipt-title">
                <asp:Literal ID="litReportTitle" runat="server" Text="Receipt"></asp:Literal>
            </div>

            <!-- ══ RECEIPT NO / DATE ══ -->
            <div class="row-receipt-date">
                <span class="field-label">Receipt # / Date</span>
                <span class="val-rcptno">
                    <asp:Literal ID="litReceiptNo" runat="server"></asp:Literal>
                </span>
                <span class="val-date">
                    <asp:Literal ID="litDate" runat="server"></asp:Literal>
                </span>
            </div>

            <!-- ══ AMOUNT / BANK CHARGES / NET ══ -->
            <div class="row-amounts">
                <span class="field-label">Received with thanks a sum of Rs.</span>
                <span class="val-amount">
                    <asp:Literal ID="litReceiptAmount" runat="server"></asp:Literal>
                </span>
                <span class="lbl-bank">Bank Charges:</span>
                <span class="val-bank">
                    <asp:Literal ID="litBankAmt" runat="server"></asp:Literal>
                </span>
                <span class="lbl-net">Net Amount:</span>
                <span class="val-net">
                    <asp:Literal ID="litNetAmount" runat="server"></asp:Literal>
                </span>
            </div>

            <!-- ══ RUPEES IN WORDS ══ -->
            <div class="field-row">
                <span class="field-label">Rupees in Words:</span>
                <span class="field-value" style="flex:1;">
                    <asp:Literal ID="litAmountWords" runat="server"></asp:Literal>
                </span>
            </div>

            <!-- ══ CASH / CHEQUE ══ -->
            <div class="field-row">
                <span class="field-label">Cash/Cheque No/PO/DD/Credit Card:</span>
                <span class="field-value" style="flex:1;">
                    <asp:Literal ID="litPaymentMode" runat="server"></asp:Literal>
                </span>
            </div>

            <!-- ══ RECEIPT AGAINST ══ -->
            <div class="field-row">
                <span class="field-label">Receipt against:</span>
                <span class="field-value" style="flex:1;">
                    <asp:Literal ID="litReceiptAgainst" runat="server"></asp:Literal>
                </span>
            </div>

            <!-- ══ RECEIVED FROM ══ -->
            <div class="field-row">
                <span class="field-label">Received From:</span>
                <span class="field-value" style="flex:1;">
                    <asp:Literal ID="litReceivedFrom" runat="server"></asp:Literal>
                </span>
            </div>

            <!-- ══ ON ACCOUNT OF ══ -->
            <div class="field-row">
                <span class="field-label">On Account of:</span>
                <span class="field-value" style="flex:1;">
                    <asp:Literal ID="litPayHead" runat="server"></asp:Literal>
                </span>
            </div>

            <!-- ══ MEMBERS GRID ══ -->
            <asp:GridView ID="gvMembers" runat="server"
                AutoGenerateColumns="False"
                CssClass="members-table"
                GridLines="None"
                Width="100%">
                <Columns>
                    <asp:BoundField DataField="MemberNo" HeaderText="Member No/Ref#" 
                        ItemStyle-Width="180px" HeaderStyle-Width="180px"
                        ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    
                    <asp:BoundField DataField="MemberName" HeaderText="Name" 
                        ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    
                    <asp:BoundField DataField="ReceiptAmount" HeaderText="Amount" 
                        DataFormatString="{0:N2}" ItemStyle-Width="110px" HeaderStyle-Width="110px"
                        ItemStyle-HorizontalAlign="Right" HeaderStyle-CssClass="align-right" HeaderStyle-HorizontalAlign="Right" />
                    
                    <asp:BoundField DataField="MemberBankAmount" HeaderText="Bank Charges" 
                        DataFormatString="{0:N2}" ItemStyle-Width="90px" HeaderStyle-Width="90px"
                        ItemStyle-HorizontalAlign="Right" HeaderStyle-CssClass="align-right" HeaderStyle-HorizontalAlign="Right" />
                    
                    <asp:BoundField DataField="TotalAmount" HeaderText="Total" 
                        DataFormatString="{0:N2}" ItemStyle-Width="110px" HeaderStyle-Width="110px"
                        ItemStyle-HorizontalAlign="Right" HeaderStyle-CssClass="align-right" HeaderStyle-HorizontalAlign="Right" />
                </Columns>
            </asp:GridView>

            <!-- ══ SIGNATURES ══ -->
            <div class="sig-section">
                <div class="sig-block">
                    <div class="sig-name">
                        <asp:Literal ID="litReceivedBy" runat="server"></asp:Literal>
                    </div>
                    <div class="sig-line"></div>
                    <div class="sig-caption">Received by</div>
                </div>
                <div class="sig-block" style="text-align:center;">
                    <div class="sig-line"></div>
                    <div class="sig-caption">Checked by</div>
                </div>
            </div>

            <!-- ══ FOOTER ══ -->
            <div class="receipt-footer">
                <span>
                    <asp:Literal ID="litFooterLeft" runat="server"></asp:Literal>
                </span>
                <span><em>(Cheques/PO/DD are subject to clearance)</em></span>
            </div>

        </div>
        <%-- /receipt-box --%>

        <!-- Print / Close Buttons -->
        <div class="btn-row">
            <button class="btn-print" type="button" onclick="window.print()">🖨 Print / Save as PDF</button>
            <button class="btn-close" type="button" onclick="window.close()">✕ Close</button>
        </div>
    </div>

</form>
</body>
</html>
