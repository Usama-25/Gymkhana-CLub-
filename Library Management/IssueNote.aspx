<%@ page language="C#" autoeventwireup="true" CodeFile="IssueNote.aspx.cs" Inherits="Pages_Circulation_IssueNote" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Library Issue Note - Lahore Gymkhana Club</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <style type="text/css">
        body {
            font-family: 'Outfit', sans-serif;
            color: #1e293b;
            margin: 0;
            padding: 30px;
            background-color: #ffffff;
            font-size: 13.5px;
            line-height: 1.5;
        }
        .container {
            max-width: 780px;
            margin: 0 auto;
            border: 1px solid #e2e8f0;
            padding: 40px;
            border-radius: 8px;
            background-color: #ffffff;
        }
        .header {
            margin-bottom: 30px;
        }
        .club-name {
            font-size: 18px;
            font-weight: 700;
            color: #0f1e36;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin: 0;
        }
        .note-title {
            font-size: 14px;
            font-weight: 500;
            color: #64748b;
            margin: 2px 0 0 0;
        }
        .meta-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px 40px;
            margin-bottom: 30px;
            font-size: 13px;
        }
        .meta-item {
            display: flex;
            align-items: baseline;
            border-bottom: 1px solid #cbd5e1;
            padding-bottom: 4px;
        }
        .meta-label {
            font-weight: 500;
            color: #64748b;
            width: 140px;
            flex-shrink: 0;
        }
        .meta-val {
            font-weight: 600;
            color: #0f1e36;
        }
        .books-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 40px;
        }
        .books-table th {
            border-bottom: 2px solid #0f1e36;
            padding: 10px 8px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            color: #475569;
            text-align: left;
        }
        .books-table td {
            border-bottom: 1px solid #e2e8f0;
            padding: 12px 8px;
            color: #1e293b;
        }
        .footer-signatures {
            display: flex;
            justify-content: space-between;
            margin-top: 60px;
            padding-top: 10px;
        }
        .sig-block {
            width: 260px;
            text-align: left;
        }
        .sig-line {
            border-bottom: 1px solid #475569;
            margin-bottom: 6px;
            height: 30px;
            font-weight: 600;
            color: #1e293b;
        }
        .sig-label {
            font-size: 11.5px;
            font-weight: 600;
            color: #64748b;
            text-transform: uppercase;
        }
        .print-audit {
            font-size: 9.5px;
            color: #94a3b8;
            margin-top: 4px;
        }
        .no-print-btn {
            background-color: #0f1e36;
            color: #ffffff;
            border: none;
            padding: 10px 20px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 20px;
        }
        .no-print-btn:hover {
            background-color: #1c3254;
        }

        /* Print Media Styles */
        @media print {
            body {
                padding: 0;
                margin: 0;
                font-size: 12px;
            }
            .container {
                border: none;
                padding: 0;
                max-width: 100%;
            }
            .no-print {
                display: none !important;
            }
            .books-table th {
                border-bottom: 1.5px solid #000000;
            }
            .books-table td {
                border-bottom: 0.75px solid #cccccc;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="no-print" style="display: flex; justify-content: space-between; align-items: center;">
                <button type="button" class="no-print-btn" onclick="window.print();">Print Slip</button>
                <button type="button" class="no-print-btn" style="background-color: #64748b;" onclick="window.close();">Close Window</button>
            </div>

            <!-- Receipt Header -->
            <div class="header">
                <h1 class="club-name">Lahore Gymkhana</h1>
                <p class="note-title">Library Issue Note</p>
            </div>

            <!-- Meta Details Grid -->
            <div class="meta-grid">
                <div class="meta-item">
                    <span class="meta-label">Library Issue No:</span>
                    <span class="meta-val"><asp:Label ID="lblIssueNo" runat="server" /></span>
                </div>
                <div class="meta-item">
                    <span class="meta-label">Transaction Date/Time:</span>
                    <span class="meta-val"><asp:Label ID="lblTransactionDateTime" runat="server" /></span>
                </div>
                <div class="meta-item" style="grid-column: span 2;">
                    <span class="meta-label">Issue To:</span>
                    <span class="meta-val"><asp:Label ID="lblIssueTo" runat="server" /></span>
                </div>
            </div>

            <!-- Description indicator -->
            <div style="font-size: 12.5px; color: #475569; font-weight: 500; margin-bottom: 12px;">Received the following book(s):</div>

            <!-- Issued Books Table -->
            <asp:Repeater ID="rptBooks" runat="server">
                <HeaderTemplate>
                    <table class="books-table">
                        <thead>
                            <tr>
                                <th style="width: 40px;">Sr#</th>
                                <th style="width: 120px;">Book Number</th>
                                <th style="width: 140px;">DDC No</th>
                                <th>Title</th>
                                <th style="width: 100px;">Issue Date</th>
                                <th style="width: 100px;">Due Date</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Container.ItemIndex + 1 %></td>
                        <td style="font-family: monospace; font-weight: 500;"><%# Eval("Barcode") %></td>
                        <td><%# Eval("DDC") %></td>
                        <td style="font-weight: 500;"><%# Eval("Title") %></td>
                        <td><%# Eval("IssueDate", "{0:dd/MM/yyyy}") %></td>
                        <td><%# Eval("DueDate", "{0:dd/MM/yyyy}") %></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>

            <!-- Signature Lines -->
            <div class="footer-signatures">
                <div class="sig-block">
                    <div class="sig-line"><asp:Label ID="lblIssuedBySig" runat="server" /></div>
                    <div class="sig-label">Issued By</div>
                    <div class="print-audit"><asp:Label ID="lblPrintAudit" runat="server" /></div>
                </div>
                <div class="sig-block" style="text-align: right;">
                    <div class="sig-line"></div>
                    <div class="sig-label" style="display: inline-block; width: 100%; text-align: right;">Member Signature</div>
                </div>
            </div>
        </div>
    </form>
    <script type="text/javascript">
        // Auto print on load
        window.onload = function () {
            // Check if we are not loaded inside an iframe/editor
            if (window.self === window.top) {
                setTimeout(function () {
                    window.print();
                }, 500);
            }
        };
    </script>
</body>
</html>
