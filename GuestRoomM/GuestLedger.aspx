<%@ Page Title="Guest Statement Ledger" Language="C#" MasterPageFile="SiteGuestroom.master" AutoEventWireup="true"
    CodeFile="GuestLedger.aspx.cs" Inherits="GuestRoomApp.GuestRoomM.GuestLedger" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
        <style>
            /* Rules that require pseudo-elements, media queries or print logic */
            .btn-lookup:hover {
                background: #059669 !important;
                transform: translateY(-2px) !important;
            }

            @media print {
                .no-print { display: none !important; }
                body { background: white !important; }
                .card { box-shadow: none !important; border: 1px solid #eee !important; }
            }
        </style>

        <script type="text/javascript">
            function printLedgerReport() {
                var panel = document.getElementById('<%= pnlLedger.ClientID %>');
                if (!panel) return;

                var printWindow = window.open('', '_blank', 'height=900,width=1100');
                
                // Construct the HTML for the print window
                var html = '<html><head><title>Guest Ledger - Lahore Gymkhana</title>';
                
                // Add styles
                html += '<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />';
                html += '<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">';
                html += '<style>';
                html += 'body { font-family: "Inter", sans-serif; padding: 40px; color: #1A1A2E; line-height: 1.4; }';
                html += '.no-print { display: none !important; }';
                html += 'img { max-height: 60px; width: auto; margin-right: 15px; }';
                html += '.header-flex { display: flex; align-items: center; border-bottom: 3px solid #1e3a5f; padding-bottom: 20px; margin-bottom: 30px; }';
                html += '.header-text { flex: 1; }';
                html += 'h1 { margin: 0; font-size: 1.8rem; color: #1e3a5f; }';
                html += 'h3 { margin: 5px 0 0; font-size: 1.1rem; color: #C9A84C; }';
                html += '.info-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 30px; background: #fcfaf7; padding: 20px; border-radius: 8px; border: 1px solid #e0d5c5; }';
                html += '.info-item label { display: block; font-size: 0.65rem; font-weight: 800; color: #8B5E3C; text-transform: uppercase; margin-bottom: 4px; }';
                html += '.info-item span { display: block; font-size: 0.95rem; font-weight: 600; color: #1A1A2E; }';
                html += 'table { width: 100%; border-collapse: collapse; margin-bottom: 30px; }';
                html += 'th { background: #1e3a5f; color: white; padding: 12px 10px; text-align: left; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 1px; }';
                html += 'td { padding: 10px; border-bottom: 1px solid #e2e8f0; font-size: 0.85rem; }';
                html += '.text-right { text-align: right; }';
                html += '.amt-debit { color: #c62828; font-weight: 700; }';
                html += '.amt-credit { color: #2e7d32; font-weight: 700; }';
                html += '.amt-bal { font-weight: 800; background: #f8f9fa; }';
                html += '.summary-boxes { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 30px; }';
                html += '.summary-box { padding: 15px; border: 1px solid #e2e8f0; border-radius: 8px; text-align: center; }';
                html += '.summary-box label { display: block; font-size: 0.6rem; font-weight: 700; color: #64748b; text-transform: uppercase; margin-bottom: 5px; }';
                html += '.summary-box span { font-size: 1.1rem; font-weight: 700; }';
                html += '.footer-balance { background: #1e3a5f; color: white; padding: 25px; border-radius: 12px; display: flex; justify-content: space-between; align-items: center; }';
                html += '.footer-balance h2 { margin: 0; font-size: 1.5rem; }';
                html += '.footer-balance p { margin: 0; opacity: 0.8; font-size: 0.8rem; font-weight: 600; text-transform: uppercase; }';
                html += '.print-footer { margin-top: 50px; text-align: center; font-size: 0.75rem; color: #94a3b8; border-top: 1px solid #e2e8f0; padding-top: 20px; }';
                html += '</style></head><body>';

                // Reconstruct the report content for a clean look
                var guestName = document.getElementById('<%= lblGuestName.ClientID %>').innerText;
                var resNo = document.getElementById('<%= lblResNo.ClientID %>').innerText;
                var guestOf = document.getElementById('<%= lblGuestOf.ClientID %>').innerText;
                var rooms = document.getElementById('<%= lblRooms.ClientID %>').innerText;
                var checkIn = document.getElementById('<%= lblCheckIn.ClientID %>').innerText;
                var checkOut = document.getElementById('<%= lblCheckOut.ClientID %>').innerText;
                
                html += '<div class="header-flex">';
                html += '  <img src="images/lahore_gymkhana_logo1.png" />';
                html += '  <div class="header-text">';
                html += '    <h1>Lahore Gymkhana Club</h1>';
                html += '    <h3>Guest Ledger & Statement of Account</h3>';
                html += '  </div>';
                html += '</div>';

                html += '<div class="info-grid">';
                html += '  <div class="info-item"><label>Guest Name</label><span>' + guestName + '</span></div>';
                html += '  <div class="info-item"><label>Reservation #</label><span>' + resNo + '</span></div>';
                html += '  <div class="info-item"><label>Guest Of (Ref)</label><span>' + guestOf + '</span></div>';
                html += '  <div class="info-item"><label>Room(s)</label><span>' + rooms + '</span></div>';
                html += '  <div class="info-item"><label>Arrival Date</label><span>' + checkIn + '</span></div>';
                html += '  <div class="info-item"><label>Departure Date</label><span>' + checkOut + '</span></div>';
                html += '</div>';

                // Table Header
                html += '<table><thead><tr>';
                html += '<th>Date/Time</th><th>Ref #</th><th>Description</th><th class="text-right">Debit</th><th class="text-right">Credit</th><th class="text-right">Balance</th>';
                html += '</tr></thead><tbody>';

                // Extract rows from repeater
                var rows = panel.querySelectorAll("table tbody tr");
                rows.forEach(function(row) {
                    var cells = row.querySelectorAll("td");
                    if (cells.length >= 6) {
                        html += "<tr>";
                        html += "<td>" + cells[0].innerText + "</td>";
                        html += "<td>" + cells[1].innerText + "</td>";
                        html += "<td>" + cells[2].innerText + "</td>";
                        html += '<td class="text-right amt-debit">' + cells[3].innerText + "</td>";
                        html += '<td class="text-right amt-credit">' + cells[4].innerText + "</td>";
                        html += '<td class="text-right amt-bal">' + cells[5].innerText + "</td>";
                        html += "</tr>";
                    }
                });
                html += "</tbody></table>";

                // Summaries
                var totalCharges = document.getElementById("<%= lblSumGross.ClientID %>").innerText;
                var roomCharges = document.getElementById("<%= lblSumRoomCharges.ClientID %>").innerText;
                var svcCharges = document.getElementById("<%= lblSumServices.ClientID %>").innerText;
                var advancePaid = document.getElementById("<%= lblSumAdvance.ClientID %>").innerText;
                var netBalance = document.getElementById("<%= lblNetBalance.ClientID %>").innerText;

                html += '<div class="summary-boxes">';
                html += '  <div class="summary-box"><label>Total Charges</label><span>' + totalCharges + '</span></div>';
                html += '  <div class="summary-box"><label>Room Rent</label><span>' + roomCharges + '</span></div>';
                html += '  <div class="summary-box"><label>Services</label><span>' + svcCharges + '</span></div>';
                html += '  <div class="summary-box"><label>Advance Paid</label><span>' + advancePaid + '</span></div>';
                html += '</div>';

                html += '<div class="footer-balance">';
                html += '  <div><p>Net Outstanding Balance</p><h2>' + netBalance + '</h2></div>';
                html += '  <div class="text-right"><p>Statement Date</p><strong>' + new Date().toLocaleDateString("en-GB", {day: "numeric", month: "short", year: "numeric", hour: "2-digit", minute: "2-digit"}) + '</strong></div>';
                html += '</div>';

                html += '<div class="print-footer">Powered by MegaPlus Technologies | Lahore Gymkhana Club &copy; 2026</div>';

                html += "</body></html>";

                printWindow.document.write(html);
                printWindow.document.close();
                
                setTimeout(function() {
                    printWindow.print();
                    // printWindow.close(); // Keep open for user to see
                }, 800);
            }
        </script>
    </asp:Content>

    <asp:Content ID="ContentTitle" ContentPlaceHolderID="PageTitle" runat="server">
        Guest Ledger & Financial Statement
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div style="padding: 25px; background: #F7F3EE; min-height: 90vh; font-family: 'Segoe UI', sans-serif;">

            <div style="background: linear-gradient(135deg, #1A1A2E, #2d2d5e); padding: 20px 30px; border-radius: 12px; margin-bottom: 30px; display: flex; gap: 20px; align-items: center; box-shadow: 0 10px 20px rgba(26,26,46,0.2);"
                class="premium-header no-print">
                <div style="flex:1; display:none;">
                    <asp:DropDownList ID="ddlActiveRooms" runat="server" Visible="false" />
                </div>
                <div style="flex:2;">
                    <asp:TextBox ID="txtSearch" runat="server"
                        style="background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.2); color: #fff; padding: 12px 20px; border-radius: 8px; width:100%; font-size: .87rem;"
                        placeholder="Search by Res No, Receipt No, or Member No..." />
                </div>
                <asp:Button ID="btnSearch" runat="server" Text="Generate Ledger"
                    style="background: #C9A84C; color: #1A1A2E; border: none; padding: 12px 30px; border-radius: 8px; font-weight: 700; cursor: pointer; transition: 0.2s;"
                    OnClick="btnSearch_Click" />
            </div>

            <asp:UpdatePanel runat="server">
                <ContentTemplate>
                    <asp:Panel ID="pnlEmpty" runat="server"
                        style="background: #fff; border-radius: 12px; border: 2px dashed #e0d5c5; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05); margin-bottom: 25px; overflow: hidden; padding:100px 20px; text-align:center;">
                        <i class="fas fa-file-invoice-dollar"
                            style="font-size:4rem; color:#e0d5c5; margin-bottom:20px;"></i>
                        <h3 style="color:#7a7a7a;">No Active Statement Loaded</h3>
                        <p style="color:#94a3b8;">Select a room or enter a reservation number above to see the ledger.
                        </p>
                    </asp:Panel>

                    <asp:Panel ID="pnlLedger" runat="server" Visible="false">
                        <div style="background: #fff; border-radius: 12px; border: 1px solid #e0d5c5; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05); margin-bottom: 25px; overflow: hidden;"
                            class="card">
                            <div class="premium-header"
                                style="padding: 20px 25px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; background: #faf7f2;">
                                <div style="display:flex; align-items:center; gap:14px;">
                                    <img src="images/lahore_gymkhana_logo1.png" alt="Lahore Gymkhana"
                                        style="height:48px; width:auto;" />
                                    <h3 style="margin:0; color:#1A1A2E; font-size:1.25rem;"><i
                                            class="fas fa-user-circle" style="color:#C9A84C;"></i>
                                        <asp:Label ID="lblGuestName" runat="server" />
                                    </h3>
                                </div>
                                <div style="display:flex; gap:10px; align-items:center;">
                                    <asp:DropDownList ID="ddlResRooms" runat="server" AutoPostBack="true"
                                        OnSelectedIndexChanged="ddlResRooms_SelectedIndexChanged"
                                        style="padding: 6px 12px; border-radius: 6px; border: 1.5px solid #C9A84C; font-size: .8rem; font-weight: 600; background: #fff; color: #1A1A2E;">
                                    </asp:DropDownList>
                                    <button type="button"
                                        style="background: #1e3a5f; color: #fff; border: none; padding: 7px 18px; border-radius: 7px; font-size: .8rem; font-weight: 700; cursor: pointer; box-shadow: 0 2px 4px rgba(0,0,0,0.1);"
                                        class="btn btn-sm btn-primary no-print" onclick="printLedgerReport()"><i
                                            class="fas fa-print"></i> Print Report</button>
                                    <span
                                        style="display: inline-flex; align-items: center; gap: 4px; padding: 8px 15px; border-radius: 99px; font-size: .75rem; font-weight: 700; background: #1565C0; color: #fff;"
                                        class="badge bg-primary">
                                        <asp:Label ID="lblStatus" runat="server" />
                                    </span>
                                </div>
                            </div>

                            <div
                                style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; padding: 25px; background: #fff; border-bottom: 1px solid #f1f5f9;">
                                <div style="flex:1;"><label
                                        style="display: block; font-size: 0.7rem; color: #8B5E3C; font-weight: 700; text-transform: uppercase; margin-bottom: 5px; letter-spacing: 0.5px;">Reference
                                        / Res #</label><span
                                        style="display: block; font-size: 1rem; color: #1A1A2E; font-weight: 600;">
                                        <asp:Label ID="lblResNo" runat="server" />
                                    </span></div>
                                <div style="flex:1;"><label
                                        style="display: block; font-size: 0.7rem; color: #8B5E3C; font-weight: 700; text-transform: uppercase; margin-bottom: 5px; letter-spacing: 0.5px;">Guest
                                        Of (Ref)</label><span
                                        style="display: block; font-size: 1rem; color: #1A1A2E; font-weight: 600;">
                                        <asp:Label ID="lblGuestOf" runat="server" />
                                    </span></div>
                                <div style="flex:1;"><label
                                        style="display: block; font-size: 0.7rem; color: #8B5E3C; font-weight: 700; text-transform: uppercase; margin-bottom: 5px; letter-spacing: 0.5px;">Allocated
                                        Space</label><span
                                        style="display: block; font-size: 1rem; color: #1A1A2E; font-weight: 600;">
                                        <asp:Label ID="lblRooms" runat="server" />
                                    </span></div>
                                <div style="flex:1;"><label
                                        style="display: block; font-size: 0.7rem; color: #8B5E3C; font-weight: 700; text-transform: uppercase; margin-bottom: 5px; letter-spacing: 0.5px;">Stay
                                        Duration</label><span
                                        style="display: block; font-size: 1rem; color: #1A1A2E; font-weight: 600;">
                                        <asp:Label ID="lblCheckIn" runat="server" /> -
                                        <asp:Label ID="lblCheckOut" runat="server" />
                                    </span></div>
                            </div>

                            <table style="width: 100%; border-collapse: collapse;">
                                <thead>
                                    <tr>
                                        <th
                                            style="background: #faf7f2; padding: 15px; text-align: left; font-size: 0.8rem; text-transform: uppercase; color: #8B5E3C; border-bottom: 2px solid #e0d5c5; font-weight: 700;">
                                            Date</th>
                                        <th
                                            style="background: #faf7f2; padding: 15px; text-align: left; font-size: 0.8rem; text-transform: uppercase; color: #8B5E3C; border-bottom: 2px solid #e0d5c5; font-weight: 700;">
                                            Ref / Inv #</th>
                                        <th
                                            style="background: #faf7f2; padding: 15px; text-align: left; font-size: 0.8rem; text-transform: uppercase; color: #8B5E3C; border-bottom: 2px solid #e0d5c5; font-weight: 700; width:40%;">
                                            Description</th>
                                        <th
                                            style="background: #faf7f2; padding: 15px; text-align: right; font-size: 0.8rem; text-transform: uppercase; color: #8B5E3C; border-bottom: 2px solid #e0d5c5; font-weight: 700;">
                                            Debit (Charge)</th>
                                        <th
                                            style="background: #faf7f2; padding: 15px; text-align: right; font-size: 0.8rem; text-transform: uppercase; color: #8B5E3C; border-bottom: 2px solid #e0d5c5; font-weight: 700;">
                                            Credit (Pay)</th>
                                        <th
                                            style="background: #faf7f2; padding: 15px; text-align: right; font-size: 0.8rem; text-transform: uppercase; color: #8B5E3C; border-bottom: 2px solid #e0d5c5; font-weight: 700;">
                                            Running Bal</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptLedger" runat="server">
                                        <ItemTemplate>
                                            <tr style="border-bottom: 1px solid #f1f5f9;">
                                                <td style="padding: 12px 15px; font-size: 0.87rem; color: #1A1A2E;">
                                                    <%# Eval("LDate", "{0:dd-MMM-yy HH:mm}" ) %>
                                                </td>
                                                <td style="padding: 12px 15px; font-size: 0.87rem; color: #1A1A2E;">
                                                    <%# Eval("RefNo") %>
                                                </td>
                                                <td style="padding: 12px 15px; font-size: 0.87rem; color: #1A1A2E;">
                                                    <%# Eval("Description") %>
                                                </td>
                                                <td
                                                    style="padding: 12px 15px; font-size: 0.87rem; color: #c62828; font-weight: 700; text-align: right;">
                                                    <%# Eval("Debit", "{0:N0}" ) %>
                                                </td>
                                                <td
                                                    style="padding: 12px 15px; font-size: 0.87rem; color: #2e7d32; font-weight: 700; text-align: right;">
                                                    <%# Eval("Credit", "{0:N0}" ) %>
                                                </td>
                                                <td
                                                    style="padding: 12px 15px; font-size: 0.87rem; font-weight: 800; color: #1A1A2E; text-align: right; background: #faf7f2;">
                                                    <%# Eval("Balance", "{0:N0}" ) %>
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>

                            <div
                                style="display: grid; grid-template-columns: repeat(5, 1fr); gap: 10px; padding: 20px; background: #faf7f2; border-top: 1px solid #e2e8f0; text-align: center;">
                                <div>
                                    <label
                                        style="display: block; font-size: 0.65rem; color: #8B5E3C; font-weight: 700; text-transform: uppercase;">Total
                                        Charges</label>
                                    <span style="font-size: 1.1rem; font-weight: 700; color: #1A1A2E;">PKR
                                        <asp:Label ID="lblSumGross" runat="server" Text="0" />
                                    </span>
                                </div>
                                <div>
                                    <label
                                        style="display: block; font-size: 0.65rem; color: #8B5E3C; font-weight: 700; text-transform: uppercase;">Room
                                        Charges</label>
                                    <span style="font-size: 1.1rem; font-weight: 700; color: #c62828;">
                                        <asp:Label ID="lblSumRoomCharges" runat="server" Text="0" />
                                    </span>
                                </div>
                                <div>
                                    <label
                                        style="display: block; font-size: 0.65rem; color: #8B5E3C; font-weight: 700; text-transform: uppercase;">Service
                                        Charges</label>
                                    <span style="font-size: 1.1rem; font-weight: 700; color: #c62828;">
                                        <asp:Label ID="lblSumServices" runat="server" Text="0" />
                                    </span>
                                </div>
                                <div>
                                    <label
                                        style="display: block; font-size: 0.65rem; color: #8B5E3C; font-weight: 700; text-transform: uppercase;">Advance
                                        Paid</label>
                                    <span style="font-size: 1.1rem; font-weight: 700; color: #2e7d32;">
                                        <asp:Label ID="lblSumAdvance" runat="server" Text="0" />
                                    </span>
                                </div>
                                <div runat="server" visible="false">
                                    <label
                                        style="display: block; font-size: 0.65rem; color: #8B5E3C; font-weight: 700; text-transform: uppercase;">Misc
                                        Payments</label>
                                    <span style="font-size: 1.1rem; font-weight: 700; color: #2e7d32;">
                                        <asp:Label ID="lblSumPayments" runat="server" Text="0" />
                                    </span>
                                </div>
                            </div>

                            <div
                                style="background: #1e3a5f; color: #fff; padding: 30px; border-radius: 12px; display: flex; justify-content: space-between; align-items: center; margin: 25px;">
                                <div>
                                    <span
                                        style="display:block; font-size:0.9rem; opacity:0.8; font-weight:600; text-transform:uppercase; letter-spacing:1px;">Net
                                        Outstanding Balance</span>
                                    <span style="font-size:2rem; font-weight:900;">
                                        <asp:Label ID="lblNetBalance" runat="server" />
                                    </span>
                                </div>
                                <div style="text-align:right; font-size:0.8rem; font-weight:700;">
                                    <i class="fas fa-calculator"></i> Verified Account Balance:
                                    <asp:Label ID="lblLedgerBalance" runat="server" />
                                </div>
                            </div>
                    </asp:Panel>
                </ContentTemplate>
            </asp:UpdatePanel>

        </div>
    </asp:Content>