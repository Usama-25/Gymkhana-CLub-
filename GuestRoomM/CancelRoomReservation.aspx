<%@ Page Title="Manage Reservations" Language="C#" MasterPageFile="SiteGuestroom.master"
    AutoEventWireup="true" CodeFile="CancelRoomReservation.aspx.cs"
    Inherits="GuestRoomApp.GuestRoomM.CancelRoomReservation" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    /* Rules that require pseudo-elements or media queries */
    .kpi-card::before { content:''; position:absolute; top:0; left:0; right:0; height:3px; }
    .form-card::before { content:''; position:absolute; top:0; left:0; right:0; height:4px; background:linear-gradient(90deg,#C9A84C,#8B5E3C); border-radius:10px 10px 0 0; }
    .form-control:focus { border-color:#C9A84C !important; outline:none; box-shadow:0 0 0 3px rgba(201,168,76,0.15); }
    .btn-gold:hover { transform:translateY(-1px); box-shadow:0 4px 12px rgba(201,168,76,0.4); }
    .btn-confirm:hover { transform:translateY(-1px); box-shadow:0 3px 8px rgba(46,125,50,0.4); }
    .btn-checkin:hover { transform:translateY(-1px); box-shadow:0 3px 8px rgba(21,101,192,0.4); }
    .btn-cancel-row:hover { background:#c62828 !important; color:#fff !important; }
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

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
<div style="width:100%; background:#F7F3EE; min-height: 100vh; padding: 24px; margin: -24px;">

    <div class="page-header" style="background:linear-gradient(135deg,#1A1A2E,#2d2d5e); color:#fff; padding:16px 26px; border-radius:10px; margin-bottom:18px; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; box-shadow:0 4px 15px rgba(0,0,0,0.2); width: 100%;">
        <div>
            <h3 style="margin:0; font-size:1.35rem; letter-spacing:1px;"> Manage Reservations</h3>
            <div style="font-size:.77rem; color:#E8D5A3; margin-top:3px;">Confirm · Check-In · Cancel Bookings</div>
        </div>
    </div>

    <asp:Label ID="lblMessage" runat="server" CssClass="alert" EnableViewState="false"></asp:Label>

    <div class="kpi-grid">
        <div class="kpi-card" style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:16px 18px; display:flex; align-items:center; gap:14px; box-shadow:0 2px 8px rgba(0,0,0,0.05); position:relative; overflow:hidden;">
            <div style="width:3px; position:absolute; top:0; left:0; bottom:0; background:#e65100;"></div>
            <div style="width:44px; height:44px; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:1.2rem; flex-shrink:0; background:#fff3e0; color:#e65100;"><i class="fas fa-clock"></i></div>
            <div><div style="font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:1px; color:#7a7a7a;">Pending</div><div style="font-size:1.7rem; font-weight:800; color:#1A1A2E; line-height:1.1;"><asp:Label ID="lblPendingCount" runat="server" Text="0"/></div><div style="font-size:.7rem; color:#7a7a7a;">awaiting action</div></div>
        </div>
        <div class="kpi-card" style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:16px 18px; display:flex; align-items:center; gap:14px; box-shadow:0 2px 8px rgba(0,0,0,0.05); position:relative; overflow:hidden;">
            <div style="width:3px; position:absolute; top:0; left:0; bottom:0; background:#2e7d32;"></div>
            <div style="width:44px; height:44px; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:1.2rem; flex-shrink:0; background:#e8f5e9; color:#2e7d32;"><i class="fas fa-check-circle"></i></div>
            <div><div style="font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:1px; color:#7a7a7a;">Confirmed</div><div style="font-size:1.7rem; font-weight:800; color:#1A1A2E; line-height:1.1;"><asp:Label ID="lblConfirmedCount" runat="server" Text="0"/></div><div style="font-size:.7rem; color:#7a7a7a;">reservations</div></div>
        </div>
        <div class="kpi-card" style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:16px 18px; display:flex; align-items:center; gap:14px; box-shadow:0 2px 8px rgba(0,0,0,0.05); position:relative; overflow:hidden;">
            <div style="width:3px; position:absolute; top:0; left:0; bottom:0; background:#1565C0;"></div>
            <div style="width:44px; height:44px; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:1.2rem; flex-shrink:0; background:#e3f2fd; color:#1565C0;"><i class="fas fa-door-open"></i></div>
            <div><div style="font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:1px; color:#7a7a7a;">Occupied</div><div style="font-size:1.7rem; font-weight:800; color:#1A1A2E; line-height:1.1;"><asp:Label ID="lblAvailedCount" runat="server" Text="0"/></div><div style="font-size:.7rem; color:#7a7a7a;">rooms</div></div>
        </div>
        <div class="kpi-card" style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:16px 18px; display:flex; align-items:center; gap:14px; box-shadow:0 2px 8px rgba(0,0,0,0.05); position:relative; overflow:hidden;">
            <div style="width:3px; position:absolute; top:0; left:0; bottom:0; background:#c62828;"></div>
            <div style="width:44px; height:44px; border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:1.2rem; flex-shrink:0; background:#fce4ec; color:#c62828;"><i class="fas fa-times-circle"></i></div>
            <div><div style="font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:1px; color:#7a7a7a;">Cancelled</div><div style="font-size:1.7rem; font-weight:800; color:#1A1A2E; line-height:1.1;"><asp:Label ID="lblCancelledCount" runat="server" Text="0"/></div><div style="font-size:.7rem; color:#7a7a7a;">reservations</div></div>
        </div>
    </div>

    <div style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:18px 22px; margin-bottom:16px; position:relative; box-shadow:0 2px 10px rgba(0,0,0,0.06); width: 100%;">
        <div style="font-size:.71rem; font-weight:700; letter-spacing:2px; text-transform:uppercase; color:#8B5E3C; margin-bottom:14px; padding-bottom:8px; border-bottom:1px solid #e0d5c5;"> Filter Reservations</div>
        <div class="filter-container" style="display:flex; flex-wrap:wrap; align-items:flex-end; gap:12px;">
            <div class="filter-item" style="display:flex; flex-direction:column; gap:4px;">
                <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">From Date</label>
                <asp:TextBox ID="txtFromDate" runat="server" TextMode="Date" style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:160px;" />
            </div>
            <div class="filter-item" style="display:flex; flex-direction:column; gap:4px;">
                <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">To Date</label>
                <asp:TextBox ID="txtToDate" runat="server" TextMode="Date" style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:160px;" />
            </div>
            <div class="filter-item" style="display:flex; flex-direction:column; gap:4px;">
                <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Status</label>
                <asp:DropDownList ID="ddlStatusFilter" runat="server" style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:170px;">
                    <asp:ListItem Text="All Statuses" Value="All" />
                    <asp:ListItem Text="Pending"   Value="PENDING" />
                    <asp:ListItem Text="Confirmed" Value="CONFIRMED" />
                    <asp:ListItem Text="Occupied"   Value="OCCUPIED" />
                    <asp:ListItem Text="Cancelled" Value="CANCELLED" />
                </asp:DropDownList>
            </div>
            <div class="filter-item" style="display:flex; flex-direction:column; gap:4px;">
                <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">&nbsp;</label>
                <asp:Button ID="btnFilter" runat="server" Text=" Apply Filter" style="background:linear-gradient(135deg,#C9A84C,#8B5E3C); color:#fff; border:none; padding:9px 22px; border-radius:7px; font-size:.87rem; font-weight:600; cursor:pointer;" OnClick="btnFilter_Click" CssClass="btn-gold" />
            </div>
        </div>
    </div>
    <div style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:18px 22px; margin-bottom:16px; position:relative; box-shadow:0 2px 10px rgba(0,0,0,0.06); width: 100%;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px; flex-wrap:wrap; gap:8px;">
            <div style="font-size:.72rem; font-weight:700; letter-spacing:2px; text-transform:uppercase; color:#8B5E3C;"> Reservation Management</div>
            <span style="padding:4px 14px; border-radius:20px; font-size:.75rem; font-weight:700; background:#faf7f2; color:#7a7a7a; border:1px solid #e0d5c5;">Records: <asp:Label ID="lblRecordCount" runat="server" Text="0" /></span>
        </div>

        <div style="overflow-x:auto; overflow-y:auto; max-height:520px; border-radius:8px; border:1px solid #e0d5c5;">
            <asp:GridView ID="gvReservations" runat="server"
    AutoGenerateColumns="False"
    GridLines="None"
    DataKeyNames="ReservationID"
    AllowPaging="True"
    PageSize="15"
    OnPageIndexChanging="gvReservations_PageIndexChanging"
    OnRowCommand="gvReservations_RowCommand"
    OnRowDataBound="gvReservations_RowDataBound"
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
        <div style="padding:32px; text-align:center; color:#7a7a7a; background:#fff; font-size:0.88rem;">
            No reservations found.
        </div>
    </EmptyDataTemplate>

    <Columns>

        <%-- Booked On --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Booked On</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; color:#1e293b; font-size:0.88rem;">
                    <%# Convert.ToDateTime(Eval("ResDate")).ToString("dd-MMM-yyyy") %>
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
                <div style="padding:12px 15px; color:#1e293b; font-size:0.88rem;">
                    <%# Convert.ToDateTime(Eval("FromDate")).ToString("dd-MMM-yyyy") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Check-Out --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Check-Out</span>
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

        <%-- Status Badge --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Status</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; text-align:center;">
                    <span style='padding:3px 12px; border-radius:99px; font-size:.71rem; font-weight:700; white-space:nowrap; <%# GetStatusBadge(Eval("Status").ToString()) %>'>
                        <%# Eval("Status") %>
                    </span>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Allocated Rooms --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Allocated Rooms</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px;">
                    <asp:Label ID="lblRoomAllocation" runat="server"
                        Text="Not allocated"
                        style="font-size:.8rem; color:#7a7a7a;" />
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Actions --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" Width="210px" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Actions</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:8px 15px; display:flex; gap:5px; justify-content:center; flex-wrap:wrap;">

                    <asp:Button ID="btnConfirm" runat="server"
                        Text="✓ Confirm"
                        CommandName="Confirm"
                        CommandArgument='<%# Eval("ReservationNo") %>'
                        OnClientClick="return confirm('Confirm this reservation?');"
                        style="background:linear-gradient(135deg,#2e7d32,#1b5e20); color:#fff; padding:5px 13px; font-size:.76rem; font-weight:600; border:none; border-radius:6px; cursor:pointer;" />

                    <asp:Button ID="btnCheckIn" runat="server"
                        Text="↪ Check-In"
                        CommandName="CheckIn"
                        CommandArgument='<%# Eval("ReservationNo") %>'
                        OnClientClick="return confirm('Check-in this guest?');"
                        style="background:linear-gradient(135deg,#1565C0,#0d47a1); color:#fff; padding:5px 13px; font-size:.76rem; font-weight:600; border:none; border-radius:6px; cursor:pointer;" />

                    <asp:Button ID="btnCancel" runat="server"
                        Text="✕ Cancel"
                        CommandName="CancelRes"
                        CommandArgument='<%# Eval("ReservationNo") %>'
                        OnClientClick="return confirm('Cancel this reservation? Rooms will be freed.');"
                        style="background:#fce4ec; color:#c62828; border:1.5px solid #c62828; padding:5px 13px; font-size:.76rem; font-weight:600; border-radius:6px; cursor:pointer;" />

                </div>
            </ItemTemplate>
        </asp:TemplateField>

    </Columns>
</asp:GridView>
        </div>

        <div style="display:flex; justify-content:space-between; align-items:center; font-size:.76rem; color:#7a7a7a; padding:10px 4px 0; flex-wrap:wrap; gap:10px;">
            <span> Confirm → Check-In → Cancel frees the room.</span>
            <span>Total: <strong><asp:Label ID="lblFooterCount" runat="server" Text="0" /></strong></span>
        </div>
    </div>

</div>
    <script type="text/javascript">
    var availableRoomsList = [];
    var currentReservation = '';
    var requiredRooms = 0;
    
    function showRoomSelection(reservationNo, guestName, roomsRequired) {
        currentReservation = reservationNo;
        requiredRooms = roomsRequired;
        
        // Get available rooms from server
        PageMethods.GetAvailableRoomsList(roomsRequired, function(result) {
            availableRoomsList = result.split(',');
            showRoomDialog(guestName, roomsRequired);
        });
    }
    
    function showRoomDialog(guestName, roomsRequired) {
        var roomHtml = '<div id="roomSelectModal" style="position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);z-index:9999;display:flex;align-items:center;justify-content:center;">';
        roomHtml += '<div style="background:white;border-radius:10px;padding:20px;width:400px;max-width:90%;">';
        roomHtml += '<h3>Select Rooms for ' + guestName + '</h3>';
        roomHtml += '<p>Required: ' + roomsRequired + ' room(s)</p>';
        roomHtml += '<div style="max-height:300px;overflow-y:auto;">';
        
        for (var i = 0; i < availableRoomsList.length; i++) {
            roomHtml += '<label style="display:block;margin:5px 0;">';
            roomHtml += '<input type="checkbox" class="roomCheckbox" value="' + availableRoomsList[i] + '"> ';
            roomHtml += 'Room ' + availableRoomsList[i];
            roomHtml += '</label>';
        }
        
        roomHtml += '</div>';
        roomHtml += '<div style="margin-top:15px;">';
        roomHtml += '<button onclick="confirmRoomSelection()" style="background:#1565C0;color:white;border:none;padding:8px 20px;border-radius:5px;cursor:pointer;">Confirm Check-In</button>';
        roomHtml += '<button onclick="closeRoomDialog()" style="background:#6c757d;color:white;border:none;padding:8px 20px;border-radius:5px;margin-left:10px;cursor:pointer;">Cancel</button>';
        roomHtml += '</div>';
        roomHtml += '</div></div>';
        
        document.body.insertAdjacentHTML('beforeend', roomHtml);
    }
    
    function confirmRoomSelection() {
        var selected = [];
        var checkboxes = document.querySelectorAll('.roomCheckbox:checked');
        for (var i = 0; i < checkboxes.length; i++) {
            selected.push(checkboxes[i].value);
        }
        
        if (selected.length !== requiredRooms) {
            alert('Please select exactly ' + requiredRooms + ' room(s)');
            return;
        }
        
        // Call server to complete check-in
        PageMethods.CompleteCheckIn(currentReservation, selected.join(','), function() {
            location.reload();
        });
    }
    
    function closeRoomDialog() {
        var modal = document.getElementById('roomSelectModal');
        if (modal) modal.remove();
    }
    </script>
</asp:Content>





