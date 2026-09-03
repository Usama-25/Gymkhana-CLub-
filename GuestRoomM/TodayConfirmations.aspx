<%@ Page Title="Today's Pending Confirmations" Language="C#" MasterPageFile="SiteGuestroom.master" 
    AutoEventWireup="true" CodeFile="TodayConfirmations.aspx.cs" 
    Inherits="GuestRoomApp.GuestRoomM.TodayConfirmations" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .kpi-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px; }
    .form-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px; background: linear-gradient(90deg, #C9A84C, #8B5E3C); border-radius: 10px 10px 0 0; }
    .form-control:focus { border-color: #C9A84C !important; outline: none; box-shadow: 0 0 0 3px rgba(201,168,76,0.15); }
    
    .data-table { width: 100%; border-collapse: collapse; background: #fff; font-size: 0.88rem; }
    .data-table thead th { position: sticky; top: 0; z-index: 5; background: #1A1A2E; color: #fff; font-weight: 700; text-transform: uppercase; font-size: 0.72rem; letter-spacing: 0.5px; padding: 12px 15px; border-bottom: 2px solid #e2e8f0; text-align: left; }
    .data-table td { padding: 12px 15px; border-bottom: 1px solid #f1f5f9; color: #1e293b; }
    .data-table tr:hover { background: #f8fafc; }

    .btn-action { padding: 6px 14px; border-radius: 6px; font-size: 0.75rem; font-weight: 700; cursor: pointer; border: none; transition: all 0.2s; display: inline-flex; align-items: center; gap: 5px; }
    .btn-confirm { background: #e8f5e9; color: #2e7d32; border: 1px solid #a5d6a7; }
    .btn-confirm:hover { background: #2e7d32; color: #fff; }
    .btn-cancel { background: #fce4ec; color: #c62828; border: 1px solid #f8bbd0; }
    .btn-cancel:hover { background: #c62828; color: #fff; }

    .badge-pending { padding: 4px 10px; border-radius: 12px; font-size: .72rem; font-weight: 700; background: #fff3e0; color: #e65100; border: 1px solid #ffcc80; }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
<div style="width: 100%; padding: 18px 22px; background: #F7F3EE; font-family: 'Segoe UI', sans-serif; min-height: 100vh;">

    <%-- PAGE HEADER --%>
    <div style="background: linear-gradient(135deg, #1A1A2E 0%, #2d2d5e 100%); color: #fff; padding: 16px 26px; border-radius: 10px; margin-bottom: 18px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 4px 15px rgba(0,0,0,0.2);">
        <div>
            <h3 style="margin: 0; font-size: 1.35rem; letter-spacing: 1px;"><i class="fas fa-check-double" style="color:#C9A84C; margin-right:8px;"></i> Confirm Pending Bookings</h3>
            <div style="font-size: .77rem; color: #E8D5A3; margin-top: 3px; opacity: 0.9;">Process today's arrivals and pending reservations</div>
        </div>
        <div>
            <asp:LinkButton ID="btnPrintReport" runat="server" OnClick="btnPrintReport_Click" CssClass="btn-action" style="background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: #fff; margin-right: 8px; padding: 8px 16px;">
                <i class="fas fa-print"></i> Print Confirmation Report
            </asp:LinkButton>
            <asp:LinkButton ID="btnRefresh" runat="server" OnClick="btnRefresh_Click" CssClass="btn-action" style="background: rgba(255,255,255,0.1); color: #fff; border: 1px solid rgba(255,255,255,0.2); padding: 8px 16px;">
                <i class="fas fa-sync-alt"></i> Refresh List
            </asp:LinkButton>
        </div>
    </div>

    <asp:Label ID="lblMessage" runat="server" CssClass="alert" />

    <%-- KPI CARDS --%>
    <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin-bottom: 18px;">
        <div class="kpi-card" style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 16px 18px; display: flex; align-items: center; gap: 14px; position: relative; overflow: hidden;">
            <div style="width: 3px; position: absolute; top:0; left:0; bottom:0; background: #e65100;"></div>
            <div style="width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; background: #fff3e0; color: #e65100;"><i class="fas fa-clock"></i></div>
            <div>
                <div style="font-size: .72rem; font-weight: 700; text-transform: uppercase; color: #7a7a7a;">Pending Today</div>
                <div style="font-size: 1.7rem; font-weight: 800; color: #1A1A2E;"><asp:Label ID="lblPendingToday" runat="server" Text="0" /></div>
            </div>
        </div>
        <div class="kpi-card" style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 16px 18px; display: flex; align-items: center; gap: 14px; position: relative; overflow: hidden;">
            <div style="width: 3px; position: absolute; top:0; left:0; bottom:0; background: #2e7d32;"></div>
            <div style="width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; background: #e8f5e9; color: #2e7d32;"><i class="fas fa-check-circle"></i></div>
            <div>
                <div style="font-size: .72rem; font-weight: 700; text-transform: uppercase; color: #7a7a7a;">Confirmed Today</div>
                <div style="font-size: 1.7rem; font-weight: 800; color: #1A1A2E;"><asp:Label ID="lblConfirmedToday" runat="server" Text="0" /></div>
            </div>
        </div>
        <div class="kpi-card" style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 16px 18px; display: flex; align-items: center; gap: 14px; position: relative; overflow: hidden;">
            <div style="width: 3px; position: absolute; top:0; left:0; bottom:0; background: #1565C0;"></div>
            <div style="width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; background: #e3f2fd; color: #1565C0;"><i class="fas fa-plane-arrival"></i></div>
            <div>
                <div style="font-size: .72rem; font-weight: 700; text-transform: uppercase; color: #7a7a7a;">Total Arrivals</div>
                <div style="font-size: 1.7rem; font-weight: 800; color: #1A1A2E;"><asp:Label ID="lblTotalArrivals" runat="server" Text="0" /></div>
            </div>
        </div>
        <div class="kpi-card" style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 16px 18px; display: flex; align-items: center; gap: 14px; position: relative; overflow: hidden;">
            <div style="width: 3px; position: absolute; top:0; left:0; bottom:0; background: #c62828;"></div>
            <div style="width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; background: #fce4ec; color: #c62828;"><i class="fas fa-times-circle"></i></div>
            <div>
                <div style="font-size: .72rem; font-weight: 700; text-transform: uppercase; color: #7a7a7a;">Cancelled Today</div>
                <div style="font-size: 1.7rem; font-weight: 800; color: #1A1A2E;"><asp:Label ID="lblCancelledToday" runat="server" Text="0" /></div>
            </div>
        </div>
    </div>

    <%-- FILTER SECTION --%>
    <div class="form-card" style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 18px 22px; margin-bottom: 16px; position: relative;">
        <div style="display: flex; flex-wrap: wrap; align-items: flex-end; gap: 12px;">
            <div style="display: flex; flex-direction: column; gap: 4px;">
                <label style="font-size: .81rem; font-weight: 600; color: #1A1A2E;">Arrival Date</label>
                <asp:TextBox ID="txtArrivalDate" runat="server" TextMode="Date" AutoPostBack="true" OnTextChanged="btnRefresh_Click"
                    style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; min-width:160px;" />
            </div>
            <div style="display: flex; flex-direction: column; gap: 4px; flex: 1;">
                <label style="font-size: .81rem; font-weight: 600; color: #1A1A2E;">Search Guest / Member</label>
                <asp:TextBox ID="txtSearch" runat="server" placeholder="Enter name or member number..."
                    style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; width: 100%;" />
            </div>
            <asp:Button ID="btnSearch" runat="server" Text=" Search" OnClick="btnRefresh_Click"
                style="background: #1A1A2E; color: #fff; border: none; padding: 9px 22px; border-radius: 7px; font-size: .87rem; font-weight: 600; cursor: pointer;" />
        </div>
    </div>

    <%-- DATA GRID --%>
    <div class="form-card" style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 18px 22px; margin-bottom: 16px; position: relative;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
            <div style="font-size: .72rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #8B5E3C;"> Today's Pending Bookings</div>
            <div style="font-size: .75rem; color: #7a7a7a;">
                Showing <asp:Label ID="lblCount" runat="server" Text="0" Font-Bold="true" /> pending reservations
            </div>
        </div>

        <div style="overflow-x: auto; border-radius: 8px; border: 1px solid #e0d5c5;">
             <asp:GridView ID="gvPending" runat="server"
    AutoGenerateColumns="False"
    GridLines="None"
    OnRowCommand="gvPending_RowCommand"
    OnRowCancelingEdit="gvPending_RowCancelingEdit"
    style="width:100%; border-collapse:collapse; font-size:0.88rem; background:#fff;"
    HeaderStyle-BackColor="#1A1A2E"
    HeaderStyle-ForeColor="#C9A84C"
    HeaderStyle-Font-Bold="True"
    HeaderStyle-Font-Size="X-Small"
    RowStyle-BackColor="#FFFFFF"
    RowStyle-ForeColor="#1e293b"
    AlternatingRowStyle-BackColor="#F8F9FA"
    AlternatingRowStyle-ForeColor="#1e293b">

    <EmptyDataTemplate>
        <div style="padding:40px; text-align:center; color:#7a7a7a; background:#fff;">
            <i class="fas fa-calendar-check" style="font-size:3rem; color:#e0d5c5; margin-bottom:15px; display:block;"></i>
            No pending reservations found for the selected date.
        </div>
    </EmptyDataTemplate>

    <Columns>

        <%-- Res # --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Res #</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; font-weight:700; font-family:'Courier New',monospace; color:#1e293b; font-size:0.88rem;">
                    <%# Eval("ReservationNo") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Guest Details --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Guest Details</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px;">
                    <div style="font-weight:700; color:#1A1A2E; font-size:0.88rem;"><%# Eval("GuestName") %></div>
                    <div style="font-size:0.75rem; color:#666; margin-top:2px;"><%# Eval("GuestOf") %></div>
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

        <%-- Arrival --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Arrival</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; color:#1e293b; font-size:0.88rem;">
                    <%# Convert.ToDateTime(Eval("FromDate")).ToString("dd-MMM-yyyy") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Departure --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Departure</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; color:#1e293b; font-size:0.88rem;">
                    <%# Convert.ToDateTime(Eval("ToDate")).ToString("dd-MMM-yyyy") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Rooms --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Rooms</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; text-align:center; color:#1e293b; font-size:0.88rem;"><%# Eval("NoOfRooms") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Advance --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:right; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Advance</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; text-align:right; font-weight:700; color:#C9A84C; font-size:0.88rem;">
                    <%# Convert.ToDecimal(Eval("AdvancePayment")).ToString("N0") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Status Badge --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Status</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; text-align:center;">
                    <span style="background:#fff3e0; color:#e65100; border:1px solid #ffcc80; padding:4px 10px; border-radius:12px; font-size:.72rem; font-weight:700; white-space:nowrap;">
                        PENDING
                    </span>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Actions --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" Width="200px" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Actions</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:8px 15px; display:flex; gap:8px;">
                    <asp:LinkButton ID="btnConfirm" runat="server"
                        CommandName="Confirm"
                        CommandArgument='<%# Eval("ReservationNo") %>'
                        style="background:#e8f5e9; color:#2e7d32; border:1px solid #a5d6a7; padding:6px 14px; border-radius:6px; font-size:0.75rem; font-weight:700; text-decoration:none; display:inline-flex; align-items:center; gap:5px; cursor:pointer;">
                        <i class="fas fa-check"></i> Confirm
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnCancel" runat="server"
                        CommandName="CancelRes"
                        CommandArgument='<%# Eval("ReservationNo") %>'
                        OnClientClick="return confirm('Are you sure you want to cancel this booking?');"
                        style="background:#fce4ec; color:#c62828; border:1px solid #f8bbd0; padding:6px 14px; border-radius:6px; font-size:0.75rem; font-weight:700; text-decoration:none; display:inline-flex; align-items:center; gap:5px; cursor:pointer;">
                        <i class="fas fa-times"></i> Cancel
                    </asp:LinkButton>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

    </Columns>
</asp:GridView>

        </div>
    </div>

    <%-- ════════ PRINT REPORT PANEL (hidden on screen) ════════ --%>
    <div id="printReportPanel" style="display: none;">
        <style>
            @media print {
                body * { visibility: hidden !important; }
                #printReportPanel, #printReportPanel * { visibility: visible !important; }
                #printReportPanel { display: block !important; position: absolute; left: 0; top: 0; width: 100%; padding: 20px; background: #fff; }
                .rpt-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
                .rpt-table th { background: #1A1A2E !important; color: #fff !important; padding: 8px; text-align: left; -webkit-print-color-adjust: exact; }
                .rpt-table td { padding: 8px; border-bottom: 1px solid #ddd; }
            }
        </style>
        <table style="width:100%;">
            <tr>
                <td style="width:80px;"><img src="images/lahore_gymkhana_logo1.png" style="height:60px;"/></td>
                <td>
                    <div style="font-size:16pt; font-weight:800;">Lahore Gymkhana Club</div>
                    <div style="font-size:10pt; color:#666;">Guest Room Confirmation Report</div>
                </td>
                <td style="text-align:right;">
                    <div style="font-size:10pt;">Report Date: <strong><asp:Label ID="lblRptDate" runat="server" /></strong></div>
                    <div style="font-size:9pt; color:#888;">Printed: <asp:Label ID="lblRptTime" runat="server" /></div>
                </td>
            </tr>
        </table>
        <hr style="border:1px solid #1A1A2E; margin:15px 0;"/>
        
        <div style="display: flex; gap: 20px; margin-bottom: 20px;">
            <div style="flex:1; border:1px solid #ddd; padding:10px; border-radius:5px; text-align:center;">
                <div style="font-size:8pt; text-transform:uppercase; color:#777;">Confirmed Today</div>
                <div style="font-size:18pt; font-weight:800; color:#2e7d32;"><asp:Label ID="lblRptConfirmed" runat="server" Text="0" /></div>
            </div>
            <div style="flex:1; border:1px solid #ddd; padding:10px; border-radius:5px; text-align:center;">
                <div style="font-size:8pt; text-transform:uppercase; color:#777;">Cancelled Today</div>
                <div style="font-size:18pt; font-weight:800; color:#c62828;"><asp:Label ID="lblRptCancelled" runat="server" Text="0" /></div>
            </div>
            <div style="flex:1; border:1px solid #ddd; padding:10px; border-radius:5px; text-align:center;">
                <div style="font-size:8pt; text-transform:uppercase; color:#777;">Still Pending</div>
                <div style="font-size:18pt; font-weight:800; color:#e65100;"><asp:Label ID="lblRptPending" runat="server" Text="0" /></div>
            </div>
        </div>

        <div style="font-weight:700; text-transform:uppercase; color:#1A1A2E; border-bottom:2px solid #C9A84C; padding-bottom:5px; margin-top:20px;">Bookings Still Pending (Arriving Today)</div>
         <asp:GridView ID="gvPendingRpt" runat="server"
    AutoGenerateColumns="False"
    GridLines="None"
    style="width:100%; border-collapse:collapse; font-size:0.85rem; background:#fff; margin-top:10px;"
    HeaderStyle-BackColor="#1A1A2E"
    HeaderStyle-ForeColor="#C9A84C"
    HeaderStyle-Font-Bold="True"
    HeaderStyle-Font-Size="X-Small"
    RowStyle-BackColor="#FFFFFF"
    RowStyle-ForeColor="#1e293b"
    AlternatingRowStyle-BackColor="#F8F9FA"
    AlternatingRowStyle-ForeColor="#1e293b">

    <EmptyDataTemplate>
        <div style="padding:10px; color:#888; font-size:0.85rem;">No pending arrivals for this date.</div>
    </EmptyDataTemplate>

    <Columns>

        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:10px 12px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Res #</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:9px 12px; font-weight:700; font-family:'Courier New',monospace; color:#1e293b; font-size:0.85rem;"><%# Eval("ReservationNo") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:10px 12px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Guest Name</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:9px 12px; color:#1e293b; font-size:0.85rem;"><%# Eval("GuestName") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:10px 12px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Member No</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:9px 12px; font-family:'Courier New',monospace; color:#1e293b; font-size:0.85rem;"><%# Eval("MembershipNo") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:10px 12px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Arrival</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:9px 12px; color:#1e293b; font-size:0.85rem;"><%# Convert.ToDateTime(Eval("FromDate")).ToString("dd-MMM-yyyy") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:10px 12px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Departure</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:9px 12px; color:#1e293b; font-size:0.85rem;"><%# Convert.ToDateTime(Eval("ToDate")).ToString("dd-MMM-yyyy") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:10px 12px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Rooms</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:9px 12px; text-align:center; color:#1e293b; font-size:0.85rem;"><%# Eval("NoOfRooms") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:10px 12px; text-align:right; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Advance</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:9px 12px; text-align:right; font-weight:700; color:#C9A84C; font-size:0.85rem;"><%# Convert.ToDecimal(Eval("AdvancePayment")).ToString("N0") %></div>
            </ItemTemplate>
        </asp:TemplateField>

    </Columns>
</asp:GridView>



        <div style="font-weight:700; text-transform:uppercase; color:#1A1A2E; border-bottom:2px solid #C9A84C; padding-bottom:5px; margin-top:30px;">Bookings Confirmed Today (Actions)</div>
         <asp:GridView ID="gvConfirmedRpt" runat="server"
    AutoGenerateColumns="False"
    GridLines="None"
    style="width:100%; border-collapse:collapse; font-size:0.85rem; background:#fff; margin-top:10px;"
    HeaderStyle-BackColor="#1A1A2E"
    HeaderStyle-ForeColor="#C9A84C"
    HeaderStyle-Font-Bold="True"
    HeaderStyle-Font-Size="X-Small"
    RowStyle-BackColor="#FFFFFF"
    RowStyle-ForeColor="#1e293b"
    AlternatingRowStyle-BackColor="#F8F9FA"
    AlternatingRowStyle-ForeColor="#1e293b">

    <EmptyDataTemplate>
        <div style="padding:10px; color:#888; font-size:0.85rem;">No bookings confirmed today.</div>
    </EmptyDataTemplate>

    <Columns>

        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:10px 12px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Res #</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:9px 12px; font-weight:700; font-family:'Courier New',monospace; color:#1e293b; font-size:0.85rem;"><%# Eval("ReservationNo") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:10px 12px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Guest Name</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:9px 12px; color:#1e293b; font-size:0.85rem;"><%# Eval("GuestName") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:10px 12px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Member No</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:9px 12px; font-family:'Courier New',monospace; color:#1e293b; font-size:0.85rem;"><%# Eval("MembershipNo") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:10px 12px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Arrival</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:9px 12px; color:#1e293b; font-size:0.85rem;"><%# Convert.ToDateTime(Eval("FromDate")).ToString("dd-MMM-yyyy") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:10px 12px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Departure</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:9px 12px; color:#1e293b; font-size:0.85rem;"><%# Convert.ToDateTime(Eval("ToDate")).ToString("dd-MMM-yyyy") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:10px 12px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Rooms</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:9px 12px; text-align:center; color:#1e293b; font-size:0.85rem;"><%# Eval("NoOfRooms") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:10px 12px; text-align:right; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Advance</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:9px 12px; text-align:right; font-weight:700; color:#2e7d32; font-size:0.85rem;"><%# Convert.ToDecimal(Eval("AdvancePayment")).ToString("N0") %></div>
            </ItemTemplate>
        </asp:TemplateField>

    </Columns>
</asp:GridView>

        <div style="margin-top:30px; font-size:8pt; text-align:center; color:#999;">
            *** End of Confirmation Report ***
        </div>
    </div>

    <script type="text/javascript">
        function triggerPrint() {
            var hf = document.getElementById('<%= hfPrint.ClientID %>');
            if (hf && hf.value === '1') {
                hf.value = '0';
                window.print();
            }
        }
        window.onload = triggerPrint;
    </script>
    <asp:HiddenField ID="hfPrint" runat="server" Value="0" />

</div>
</asp:Content>
