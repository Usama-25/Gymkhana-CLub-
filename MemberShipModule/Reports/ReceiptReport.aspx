<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ReceiptReport.aspx.cs" Inherits="MemberShipModule_ReceiptReport"
    %>

    <!DOCTYPE html>
    <html>

    <head runat="server">
        <meta charset="utf-8" />
        <title>Transaction Receipt</title>
        <style>
            body {
                font-family: 'Segoe UI', Arial, sans-serif;
                font-size: 14px;
                padding: 40px;
                color: #1A1A2E;
                background-color: #faf7f2;
            }

            .receipt-box {
                max-width: 600px;
                margin: auto;
                border: 1px solid #e0d5c5;
                padding: 30px;
                background-color: #ffffff;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
                border-radius: 8px;
            }

            .header {
                text-align: center;
                border-bottom: 2px solid #C9A84C;
                margin-bottom: 20px;
                padding-bottom: 15px;
            }

            .title {
                font-size: 24px;
                font-weight: bold;
                color: #1A1A2E;
                margin-bottom: 5px;
            }

            .subtitle {
                font-size: 14px;
                color: #8B5E3C;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.05em;
            }

            .receipt-no {
                font-family: monospace;
                font-size: 12px;
                color: #8B5E3C;
                margin-top: 8px;
                padding: 4px 8px;
                background: #F7F3EE;
                border-radius: 4px;
                display: inline-block;
            }

            .content {
                line-height: 1.8;
            }

            .row {
                display: flex;
                justify-content: space-between;
                border-bottom: 1px solid #F7F3EE;
                padding: 10px 0;
            }

            .label {
                font-weight: 600;
                color: #8B5E3C;
                width: 40%;
            }

            .value {
                color: #1A1A2E;
                width: 60%;
                text-align: right;
            }

            .total-row {
                border-top: 2px solid #e0d5c5;
                border-bottom: 2px solid #e0d5c5;
                margin-top: 10px;
                padding: 12px 0;
                background-color: #faf7f2;
            }

            .total-label {
                font-size: 18px;
                font-weight: bold;
                color: #C9A84C;
            }

            .total-value {
                font-size: 18px;
                font-weight: bold;
                color: #C9A84C;
            }

            .footer {
                margin-top: 40px;
                text-align: center;
                font-size: 12px;
                color: #8B5E3C;
                border-top: 1px solid #F7F3EE;
                padding-top: 20px;
            }

            @media print {
                body {
                    background-color: white;
                    padding: 0;
                }

                .receipt-box {
                    box-shadow: none;
                    border: none;
                    width: 100%;
                    max-width: none;
                }

                .no-print {
                    display: none;
                }
            }

            .btn-print {
                display: block;
                width: fit-content;
                margin: 20px auto 0;
                padding: 10px 20px;
                background: linear-gradient(135deg, #C9A84C, #8B5E3C);
                color: white;
                border: none;
                border-radius: 6px;
                cursor: pointer;
                font-weight: 600;
                transition: all 0.2s ease;
                box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);
            }

            .btn-print:hover {
                box-shadow: 0 8px 12px rgba(201, 168, 76, 0.3);
                transform: translateY(-1px);
            }
        </style>
    </head>

    <body>
        <form id="form1" runat="server">
            <asp:ScriptManager ID="ScriptManager1" runat="server" />
            <div class="receipt-box">
                <div class="header">
                    <div class="title">Lahore Gymkhana Club</div>
                    <div class="subtitle">Transaction Receipt</div>
                    <div class="receipt-no">
                        <asp:Literal ID="litReceiptNoHeader" runat="server"></asp:Literal>
                    </div>
                </div>

                <div class="content">
                    <div class="row">
                        <span class="label">Date:</span>
                        <span class="value">
                            <asp:Literal ID="litDate" runat="server"></asp:Literal>
                        </span>
                    </div>
                    <div class="row">
                        <span class="label">Category (Head):</span>
                        <span class="value">
                            <asp:Literal ID="litHead" runat="server"></asp:Literal>
                        </span>
                    </div>
                    <div class="row">
                        <span class="label">Name:</span>
                        <span class="value">
                            <asp:Literal ID="litName" runat="server"></asp:Literal>
                        </span>
                    </div>
                    <div class="row">
                        <span class="label">CNIC:</span>
                        <span class="value">
                            <asp:Literal ID="litCNIC" runat="server"></asp:Literal>
                        </span>
                    </div>
                    <div class="row">
                        <span class="label">Form/Membership Type:</span>
                        <span class="value">
                            <asp:Literal ID="litType" runat="server"></asp:Literal>
                        </span>
                    </div>
                    <div class="row">
                        <span class="label">Payment Mode:</span>
                        <span class="value">
                            <asp:Literal ID="litMode" runat="server"></asp:Literal>
                        </span>
                    </div>

                    <asp:PlaceHolder ID="phCheque" runat="server" Visible="false">
                        <div class="row">
                            <span class="label">Cheque No:</span>
                            <span class="value">
                                <asp:Literal ID="litChequeNo" runat="server"></asp:Literal>
                            </span>
                        </div>
                        <div class="row">
                            <span class="label">Cheque Holder:</span>
                            <span class="value">
                                <asp:Literal ID="litChequeHolder" runat="server"></asp:Literal>
                            </span>
                        </div>
                    </asp:PlaceHolder>

                    <div class="row total-row">
                        <span class="label total-label">Amount Paid:</span>
                        <span class="value total-value">Rs. <asp:Literal ID="litAmount" runat="server"></asp:Literal>
                            </span>
                    </div>
                </div>

                <div class="footer">
                    <p>This is a computer generated receipt.</p>
                    <p>&copy; Lahore Gymkhana Club - <asp:Literal ID="litSystemDate" runat="server"></asp:Literal>
                    </p>
                </div>

                <button type="button" class="btn-print no-print" onclick="window.print()">Print Receipt</button>
            </div>
        </form>
    </body>

    </html>





