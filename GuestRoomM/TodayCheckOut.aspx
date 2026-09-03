<%@ Page Title="Today Check-Out" Language="C#" MasterPageFile="SiteGuestroom.master"
    AutoEventWireup="true" CodeFile="TodayCheckOut.aspx.cs" Inherits="GuestRoomApp.GuestRoomM.TodayCheckOut" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    /* Rules that require pseudo-elements or media queries */
    .kpi-card::before { content:''; position:absolute; top:0; left:0; right:0; height:3px; }
    .form-card::before { content:''; position:absolute; top:0; left:0; right:0; height:4px; background:linear-gradient(90deg,#C9A84C,#8B5E3C); border-radius:10px 10px 0 0; }
    .form-control:focus { border-color:#C9A84C !important; outline:none; box-shadow:0 0 0 3px rgba(201,168,76,0.15); }
    .btn-gold:hover { transform:translateY(-1px); box-shadow:0 4px 12px rgba(201,168,76,0.4); }
    .btn-checkout-row:hover { transform:translateY(-1px); box-shadow:0 3px 8px rgba(30, 58, 95, 0.4); }
    .res-pager span { background:#1A1A2E !important; border-color:#1A1A2E !important; color:#C9A84C !important; padding: 5px 12px; border-radius: 4px; }
    .res-pager a { padding: 5px 12px; border: 1px solid #e0d5c5; border-radius: 4px; color: #1A1A2E; text-decoration: none; margin: 0 2px; }
    .res-pager a:hover { background:#faf7f2 !important; border-color:#C9A84C !important; color:#8B5E3C !important; }

    /* Responsive Grid for KPIs */
    .kpi-grid { 
        display: grid; 
        grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); 
        gap: 15px; 
        margin-bottom: 20px; 
    }

    /* Data Table Styling */
    .data-table { width: 100%; border-collapse: collapse; background: #fff; font-size: 0.88rem; }
    .data-table thead th { position: sticky; top: 0; z-index: 5; background: #1A1A2E; color: #fff; font-weight: 700; text-transform: uppercase; font-size: 0.72rem; letter-spacing: 0.5px; padding: 12px 15px; border-bottom: 2px solid #e2e8f0; text-align: left; }
    .data-table td { padding: 12px 15px; border-bottom: 1px solid #f1f5f9; color: #1e293b; }
    .data-table tr:hover { background: #f8fafc; }

    @media(max-width: 768px) {
        .filter-container { flex-direction: column !important; align-items: stretch !important; }
        .filter-item { width: 100% !important; }
        .filter-item input, .filter-item select, .filter-item button { width: 100% !important; }
        .page-header { flex-direction: column; align-items: flex-start !important; gap: 10px; }
    }
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div style="width:100%; background:#F7F3EE; min-height: 100vh; padding: 24px; margin: -24px;">

    <div class="page-header" style="background:linear-gradient(135deg,#1A1A2E,#2d2d5e); color:#fff; padding:16px 26px; border-radius:10px; margin-bottom:18px; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; box-shadow:0 4px 15px rgba(0,0,0,0.2); width: 100%;">
        <div>
            <h3 style="margin:0; font-size:1.35rem; letter-spacing:1px;"> Today Check-Outs</h3>
            <div style="font-size:.77rem; color:#E8D5A3; margin-top:3px;">Manage Departures · Finalize Bills · Release Rooms</div>
        </div>
        <div style="display: flex; gap: 10px; align-items: center;">
             <div style="display: flex; align-items: center; background: rgba(255,255,255,0.1); padding: 4px 12px; border-radius: 6px; border: 1px solid rgba(255,255,255,0.2);">
                <label style="font-size: .7rem; color: #E8D5A3; margin-right: 10px; font-weight: 600;">REPORT DATE:</label>
                <asp:TextBox ID="txtReportDate" runat="server" TextMode="Date" AutoPostBack="true" OnTextChanged="btnRefresh_Click"
                    style="background:transparent; border:none; color:#fff; font-size:.85rem; outline:none;" />
            </div>
             <asp:LinkButton ID="btnRefresh" runat="server" OnClick="btnRefresh_Click" style="text-decoration:none; background:rgba(255,255,255,0.1); color:#fff; padding:8px 15px; border-radius:6px; font-size:.8rem; border:1px solid rgba(255,255,255,0.2);">
                <i class="fas fa-sync-alt"></i> Refresh
            </asp:LinkButton>
            <button type="button" onclick="printCheckoutReport()" style="text-decoration:none; background:#C9A84C; color:#1A1A2E; padding:8px 18px; border-radius:6px; font-size:.8rem; border:none; font-weight:700; cursor:pointer;">
                <i class="fas fa-print"></i> Print Report
            </button>
        </div>
    </div>

    <asp:Label ID="lblMessage" runat="server" CssClass="alert" EnableViewState="false"></asp:Label>

    <div class="kpi-grid">
        <div class="kpi-card" style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:16px 18px; display:flex; align-items:center; gap:14px; box-shadow:0 2px 8px rgba(0,0,0,0.05); position:relative; overflow:hidden;">
            <div style="width:3px; position:absolute; top:0; left:0; bottom:0; background:#1e3a5f;"></div>
            <div style="width:44px; height:44px; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:1.2rem; flex-shrink:0; background:#e3f2fd; color:#1e3a5f;"><i class="fas fa-sign-out-alt"></i></div>
            <div><div style="font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:1px; color:#7a7a7a;">Due Today</div><div style="font-size:1.7rem; font-weight:800; color:#1A1A2E; line-height:1.1;"><asp:Label ID="lblTodayCount" runat="server" Text="0"/></div><div style="font-size:.7rem; color:#7a7a7a;">scheduled check-outs</div></div>
        </div>
        <div class="kpi-card" style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:16px 18px; display:flex; align-items:center; gap:14px; box-shadow:0 2px 8px rgba(0,0,0,0.05); position:relative; overflow:hidden;">
            <div style="width:3px; position:absolute; top:0; left:0; bottom:0; background:#2e7d32;"></div>
            <div style="width:44px; height:44px; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:1.2rem; flex-shrink:0; background:#e8f5e9; color:#2e7d32;"><i class="fas fa-door-open"></i></div>
            <div><div style="font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:1px; color:#7a7a7a;">Total Occupied</div><div style="font-size:1.7rem; font-weight:800; color:#1A1A2E; line-height:1.1;"><asp:Label ID="lblOccupiedCount" runat="server" Text="0"/></div><div style="font-size:.7rem; color:#7a7a7a;">currently in rooms</div></div>
        </div>
        <div class="kpi-card" style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:16px 18px; display:flex; align-items:center; gap:14px; box-shadow:0 2px 8px rgba(0,0,0,0.05); position:relative; overflow:hidden;">
            <div style="width:3px; position:absolute; top:0; left:0; bottom:0; background:#C9A84C;"></div>
            <div style="width:44px; height:44px; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:1.2rem; flex-shrink:0; background:#faf7f2; color:#C9A84C;"><i class="fas fa-clock"></i></div>
            <div><div style="font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:1px; color:#7a7a7a;">Checked Out</div><div style="font-size:1.7rem; font-weight:800; color:#1A1A2E; line-height:1.1;"><asp:Label ID="lblCheckedOutCount" runat="server" Text="0"/></div><div style="font-size:.7rem; color:#7a7a7a;">already processed today</div></div>
        </div>
    </div>

    <div style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:18px 22px; margin-bottom:16px; position:relative; box-shadow:0 2px 10px rgba(0,0,0,0.06); width: 100%;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px; flex-wrap:wrap; gap:8px;">
            <div style="font-size:.72rem; font-weight:700; letter-spacing:2px; text-transform:uppercase; color:#8B5E3C;"> Departure Management</div>
            <span style="padding:4px 14px; border-radius:20px; font-size:.75rem; font-weight:700; background:#faf7f2; color:#7a7a7a; border:1px solid #e0d5c5;">Due Today: <asp:Label ID="lblRecordCount" runat="server" Text="0" /></span>
        </div>

        <div style="overflow-x:auto; overflow-y:auto; max-height:520px; border-radius:8px; border:1px solid #e0d5c5;">
            <asp:GridView ID="gvTodayCheckOuts" runat="server"
    AutoGenerateColumns="False"
    GridLines="None"
    DataKeyNames="AllocationID"
    AllowPaging="True"
    PageSize="15"
    OnPageIndexChanging="gvTodayCheckOuts_PageIndexChanging"
    OnRowCommand="gvTodayCheckOuts_RowCommand"
    OnRowDataBound="gvTodayCheckOuts_RowDataBound"
    style="width:100%; border-collapse:collapse; font-size:0.88rem; background:#fff;"
    HeaderStyle-BackColor="#1A1A2E"
    HeaderStyle-ForeColor="#C9A84C"
    HeaderStyle-Font-Bold="True"
    HeaderStyle-Font-Size="X-Small"
    RowStyle-BackColor="#FFFFFF"
    RowStyle-ForeColor="#1e293b"
    AlternatingRowStyle-BackColor="#F8F9FA"
    AlternatingRowStyle-ForeColor="#1e293b"
    PagerStyle-BackColor="#F7F3EE"
    PagerStyle-ForeColor="#1A1A2E"
    PagerStyle-HorizontalAlign="Center"
    PagerStyle-Font-Size="Small"
    PagerStyle-Font-Bold="True">

    <EmptyDataTemplate>
        <div style="padding:48px; text-align:center; color:#7a7a7a; background:#fff;">
            <div style="font-size:3rem; color:#e0d5c5; margin-bottom:15px;"><i class="fas fa-calendar-check"></i></div>
            <h4 style="margin:0; color:#1A1A2E;">All Clear!</h4>
            <p style="margin:5px 0 0; font-size:.85rem;">No more check-outs scheduled for today.</p>
        </div>
    </EmptyDataTemplate>

    <Columns>

        <%-- Room No --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Room</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; font-weight:700; color:#1e3a5f; font-size:0.88rem;">
                    <i class="fas fa-door-closed" style="font-size:.7rem; opacity:.5; margin-right:4px;"></i>
                    <%# Eval("RoomNo") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Member No --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Member No</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; font-family:'Courier New',monospace; color:#1e293b; font-size:0.88rem;">
                    <%# Eval("MembershipNo") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Guest Name --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Guest Name</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; color:#1e293b; font-size:0.88rem;"><%# Eval("GuestName") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Guest Of --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Guest Of</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; color:#1e293b; font-size:0.88rem;"><%# Eval("GuestOf") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Check-In --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Check-In</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; font-size:.8rem; color:#1e293b;">
                    <%# Convert.ToDateTime(Eval("AllocatedDate")).ToString("dd-MMM-yyyy") %>
                    <div style="font-size:.7rem; color:#7a7a7a; margin-top:2px;">
                        <%# Convert.ToDateTime(Eval("AllocatedDate")).ToString("hh:mm tt") %>
                    </div>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Duration --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Duration</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; font-weight:600; color:#1e293b; font-size:0.88rem;">
                    <%# Eval("NightsStayed") %> Night(s)
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Advance Paid --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:right; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Advance Paid</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; text-align:right; color:#2e7d32; font-weight:600; font-size:0.88rem;">
                    PKR <%# Convert.ToDecimal(Eval("AdvancePayment")).ToString("N0") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Actions --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" Width="180px" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Actions</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:8px 15px; text-align:center;">
                    <asp:Button ID="btnCheckOut" runat="server"
                        Text="Process Check-Out"
                        CommandName="CheckOut"
                        CommandArgument='<%# Eval("AllocationID") + "|" + Eval("ReservationNo") + "|" + Eval("RoomNo") %>'
                        OnClientClick='<%# Eval("RoomNo", "return confirm(\"Process check-out for Room {0}?\");") %>'
                        style="background:linear-gradient(135deg,#1A1A2E,#2d2d5e); color:#fff; padding:6px 15px; font-size:.75rem; font-weight:600; border:none; border-radius:6px; cursor:pointer;" />
                </div>
            </ItemTemplate>
        </asp:TemplateField>

    </Columns>
</asp:GridView>
        </div>

        <div style="display:flex; justify-content:space-between; align-items:center; font-size:.76rem; color:#7a7a7a; padding:10px 4px 0; flex-wrap:wrap; gap:10px;">
            <span> Departure list is filtered for today's date automatically.</span>
            <span>Total Records: <strong><asp:Label ID="lblFooterCount" runat="server" Text="0" /></strong></span>
        </div>
    </div>

    <!-- Hidden Section for Report Data -->
    <div style="display:none;">
        <asp:Repeater ID="rptCompletedCheckouts" runat="server">
            <HeaderTemplate>
                <table id="tblCompletedCheckouts">
                    <thead>
                        <tr>
                            <th>Room</th>
                            <th>Member No</th>
                            <th>Guest Name</th>
                            <th>Check-In</th>
                            <th>Check-Out Time</th>
                        </tr>
                    </thead>
                    <tbody>
            </HeaderTemplate>
            <ItemTemplate>
                <tr>
                    <td><%# Eval("RoomNo") %></td>
                    <td><%# Eval("MembershipNo") %></td>
                    <td><%# Eval("GuestName") %></td>
                    <td><%# Convert.ToDateTime(Eval("AllocatedDate")).ToString("dd-MMM-yyyy") %></td>
                    <td><%# Convert.ToDateTime(Eval("CheckOutDate")).ToString("hh:mm tt") %></td>
                </tr>
            </ItemTemplate>
            <FooterTemplate>
                    </tbody>
                </table>
            </FooterTemplate>
        </asp:Repeater>
    </div>

    <script type="text/javascript">
        function printCheckoutReport() {
            var printWindow = window.open('', '_blank', 'height=900,width=1100');
            
            var html = '<html><head><title>Today Check-Out Report - Lahore Gymkhana</title>';
            html += '<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />';
            html += '<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">';
            html += '<style>';
            html += 'body { font-family: "Inter", sans-serif; padding: 40px; color: #1A1A2E; line-height: 1.4; }';
            html += 'img { max-height: 60px; width: auto; margin-right: 15px; }';
            html += '.header-flex { display: flex; align-items: center; border-bottom: 3px solid #1e3a5f; padding-bottom: 20px; margin-bottom: 30px; }';
            html += '.header-text { flex: 1; }';
            html += 'h1 { margin: 0; font-size: 1.8rem; color: #1e3a5f; }';
            html += 'h3 { margin: 5px 0 0; font-size: 1.1rem; color: #C9A84C; }';
            html += '.kpi-summary { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 30px; }';
            html += '.kpi-box { padding: 15px; border: 1px solid #e2e8f0; border-radius: 8px; text-align: center; background: #f8fafc; }';
            html += '.kpi-box label { display: block; font-size: 0.65rem; font-weight: 800; color: #64748b; text-transform: uppercase; margin-bottom: 5px; }';
            html += '.kpi-box span { font-size: 1.5rem; font-weight: 800; color: #1e3a5f; }';
            html += 'h4 { margin: 25px 0 15px; font-size: 1.1rem; color: #1e3a5f; border-left: 4px solid #C9A84C; padding-left: 10px; text-transform: uppercase; letter-spacing: 1px; }';
            html += 'table { width: 100%; border-collapse: collapse; margin-bottom: 30px; }';
            html += 'th { background: #f1f5f9; color: #475569; padding: 12px 10px; text-align: left; font-size: 0.75rem; text-transform: uppercase; border-bottom: 2px solid #e2e8f0; }';
            html += 'td { padding: 10px; border-bottom: 1px solid #e2e8f0; font-size: 0.85rem; }';
            html += '.text-center { text-align: center; }';
            html += '.no-data { padding: 20px; text-align: center; color: #94a3b8; font-style: italic; border: 1px dashed #cbd5e1; border-radius: 8px; }';
            html += '.print-footer { margin-top: 50px; text-align: center; font-size: 0.75rem; color: #94a3b8; border-top: 1px solid #e2e8f0; padding-top: 20px; }';
            html += '</style></head><body>';

            // Header
            html += '<div class="header-flex">';
            html += '  <img src="images/lahore_gymkhana_logo1.png" />';
            html += '  <div class="header-text">';
            html += '    <h1>Lahore Gymkhana Club</h1>';
            html += '    <h3>Daily Departure & Check-Out Report</h3>';
            html += '  </div>';
            var selectedDate = document.getElementById("<%= txtReportDate.ClientID %>").value;
            html += '  <div style="text-align:right;">Report Date: <strong>' + (selectedDate ? new Date(selectedDate).toLocaleDateString("en-GB", {day: "numeric", month: "short", year: "numeric"}) : new Date().toLocaleDateString("en-GB", {day: "numeric", month: "short", year: "numeric"})) + '</strong></div>';
            html += '</div>';

            // KPIs
            var dueToday = document.getElementById("<%= lblTodayCount.ClientID %>").innerText;
            var occupied = document.getElementById("<%= lblOccupiedCount.ClientID %>").innerText;
            var checkedOut = document.getElementById("<%= lblCheckedOutCount.ClientID %>").innerText;

            html += '<div class="kpi-summary">';
            html += '  <div class="kpi-box"><label>Due for Departure</label><span>' + dueToday + '</span></div>';
            html += '  <div class="kpi-box"><label>Completed Check-Outs</label><span>' + checkedOut + '</span></div>';
            html += '  <div class="kpi-box"><label>Currently Occupied</label><span>' + occupied + '</span></div>';
            html += '</div>';

            // Table 1: Pending Check-outs
            html += '<h4>1. Pending Departures (Scheduled for ' + (selectedDate ? new Date(selectedDate).toLocaleDateString("en-GB", {day: "numeric", month: "short", year: "numeric"}) : 'Selected Date') + ')</h4>';
            var gv = document.getElementById("<%= gvTodayCheckOuts.ClientID %>");
            if (gv && gv.rows.length > 1) {
                html += '<table><thead><tr>';
                html += '<th>Room</th><th>Member No</th><th>Guest Name</th><th>Guest Of</th><th>Check-In Date</th><th>Nights</th>';
                html += '</tr></thead><tbody>';
                
                for (var i = 1; i < gv.rows.length; i++) {
                    var cells = gv.rows[i].cells;
                    if (cells.length >= 6) {
                        html += '<tr>';
                        html += '<td>' + cells[0].innerText.trim() + '</td>';
                        html += '<td>' + cells[1].innerText.trim() + '</td>';
                        html += '<td>' + cells[2].innerText.trim() + '</td>';
                        html += '<td>' + cells[3].innerText.trim() + '</td>';
                        html += '<td>' + cells[4].innerText.trim() + '</td>';
                        html += '<td>' + cells[5].innerText.trim() + '</td>';
                        html += '</tr>';
                    }
                }
                html += '</tbody></table>';
            } else {
                html += '<div class="no-data">No pending departures scheduled for today.</div>';
            }

            // Table 2: Completed Check-outs
            html += '<h4>2. Completed Departures (Checked Out Today)</h4>';
            var tblComp = document.getElementById("tblCompletedCheckouts");
            if (tblComp && tblComp.rows.length > 1) {
                html += '<table><thead><tr>';
                html += '<th>Room</th><th>Member No</th><th>Guest Name</th><th>Check-In Date</th><th>Check-Out Time</th>';
                html += '</tr></thead><tbody>';
                
                for (var j = 1; j < tblComp.rows.length; j++) {
                    var cCells = tblComp.rows[j].cells;
                    html += '<tr>';
                    html += '<td>' + cCells[0].innerText + '</td>';
                    html += '<td>' + cCells[1].innerText + '</td>';
                    html += '<td>' + cCells[2].innerText + '</td>';
                    html += '<td>' + cCells[3].innerText + '</td>';
                    html += '<td>' + cCells[4].innerText + '</td>';
                    html += '</tr>';
                }
                html += '</tbody></table>';
            } else {
                html += '<div class="no-data">No check-outs processed yet today.</div>';
            }

            html += '<div class="print-footer">Generated on: ' + new Date().toLocaleString() + ' | Powered by MegaPlus Technologies</div>';
            html += '</body></html>';

            printWindow.document.write(html);
            printWindow.document.close();
            
            setTimeout(function() {
                printWindow.print();
                // printWindow.close();
            }, 800);
        }
    </script>

</div>
</asp:Content>

