<%@ Page Title="Room Availability Calendar" Language="C#" MasterPageFile="SiteGuestroom.master" AutoEventWireup="true" CodeFile="RoomAvailabilityCalendar.aspx.cs" Inherits="GuestRoomApp.GuestRoomM.RoomAvailabilityCalendar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<<style>
    /* Rules that require pseudo-elements or media queries */
    .filter-card::before { content:''; position:absolute; top:0; left:0; right:0; height:4px; background:linear-gradient(90deg,#C9A84C,#8B5E3C); border-radius:10px 10px 0 0; }
    .form-control:focus { border-color:#C9A84C !important; outline:none; box-shadow:0 0 0 3px rgba(201,168,76,0.15); }
    .btn-search:hover { transform:translateY(-1px); }
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div style="width:100%; padding:18px 22px; background:#F7F3EE; min-height:100vh; font-family:'Segoe UI',sans-serif;" class="calendar-container">
    <div style="background:linear-gradient(135deg,#1A1A2E,#2d2d5e); color:#fff; padding:16px 26px; border-radius:10px; margin-bottom:18px; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; box-shadow:0 4px 15px rgba(0,0,0,0.2);" class="page-header">
        <div>
            <h3 style="margin:0; font-size:1.35rem;"> Room Availability Calendar</h3>
            <div style="font-size:.71rem; font-weight:700; letter-spacing:2px; text-transform:uppercase; color:#E8D5A3; margin-bottom:14px; padding-bottom:8px; border-bottom:1px solid #e0d5c5; margin:0;" class="section-title">Real-time room availability checker</div>
        </div>
        <a href="RoomReservation.aspx" style="text-decoration:none; background:#C9A84C; color:#1A1A2E; padding:9px 24px; border-radius:7px; font-size:.87rem; font-weight:600; cursor:pointer;" class="btn-search">
            <i class="fas fa-arrow-left"></i> New Reservation
        </a>
    </div>

    <asp:Label ID="lblMessage" runat="server" CssClass="alert alert-error" Visible="false" />

    <div style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:20px 22px; margin-bottom:16px; box-shadow:0 2px 10px rgba(0,0,0,0.06); position:relative;" class="filter-card">
        <div style="font-size:.71rem; font-weight:700; letter-spacing:2px; text-transform:uppercase; color:#8B5E3C; margin-bottom:14px; padding-bottom:8px; border-bottom:1px solid #e0d5c5;" class="section-title"> Select Date Range</div>
        <div style="display:flex; gap:12px; align-items:flex-end; flex-wrap:wrap;" class="filter-row">
            <div style="display:flex; flex-direction:column; gap:4px; flex:1; min-width:160px;" class="form-group">
                <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;" class="form-label">From Date</label>
                <asp:TextBox ID="txtStartDate" runat="server" style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; width:100%;" TextMode="Date" />
            </div>
            <div style="display:flex; flex-direction:column; gap:4px; flex:1; min-width:160px;" class="form-group">
                <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;" class="form-label">To Date</label>
                <asp:TextBox ID="txtEndDate" runat="server" style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; width:100%;" TextMode="Date" />
            </div>
            <div style="display:flex; flex-direction:column; gap:4px; flex:0;" class="form-group">
                <asp:Button ID="btnSearch" runat="server" Text=" Check Availability" style="background:linear-gradient(135deg,#1A1A2E,#2d2d5e); color:#fff; border:none; padding:9px 24px; border-radius:7px; font-size:.87rem; font-weight:600; cursor:pointer;" class="btn-search" OnClick="btnSearch_Click" />
            </div>
        </div>
    </div>

    <div style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; margin-bottom:16px; overflow:hidden;" class="table-card">
        <div style="padding:14px 22px; border-bottom:1px solid #e0d5c5; background:#faf7f2; display:flex; justify-content:space-between;" class="table-card-header">
            <h3 style="margin:0;"> Room Inventory Status</h3>
            <span>Last updated: <%= DateTime.Now.ToString("dd-MMM-yyyy HH:mm:ss") %></span>
        </div>
        <div style="overflow-x:auto;">
            <asp:GridView ID="gvAvailability" runat="server" style="width:100%; border-collapse:collapse;"
                AutoGenerateColumns="false" GridLines="None"
                OnRowDataBound="gvAvailability_RowDataBound">
                <Columns>
                    <asp:BoundField DataField="DateFormatted" HeaderText="Date" />
                    <asp:BoundField DataField="DayName" HeaderText="Day" />
                    <asp:BoundField DataField="TotalRooms" HeaderText="Total Rooms" ItemStyle-HorizontalAlign="Center" />
                    <asp:BoundField DataField="OccupiedRooms" HeaderText="Occupied" ItemStyle-HorizontalAlign="Center" />
                    <asp:BoundField DataField="AvailableRooms" HeaderText="Available" ItemStyle-HorizontalAlign="Center" />
                    <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                             <a href='RoomReservation.aspx?dt=<%# Eval("DateFormatted") %>' 
                               style="background:#1A1A2E; color:#C9A84C; padding:4px 12px; border-radius:6px; text-decoration:none; font-size:.7rem;">
                                Book Now
                             </a>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
        <div style="display:flex; gap:20px; padding:14px 18px; background:#faf7f2; border-radius:8px; border:1px solid #e0d5c5;" class="legend">
            <div class="legend-item"><div style="width:14px; height:14px; border-radius:4px; background:#e8f5e9; border:1px solid #2e7d32; display:inline-block; vertical-align:middle; margin-right:5px;" class="legend-dot"></div> Available (6 rooms)</div>
            <div class="legend-item"><div style="width:14px; height:14px; border-radius:4px; background:#fff3e0; border:1px solid #e65100; display:inline-block; vertical-align:middle; margin-right:5px;" class="legend-dot"></div> Limited (1-5 rooms)</div>
            <div class="legend-item"><div style="width:14px; height:14px; border-radius:4px; background:#fce4ec; border:1px solid #c62828; display:inline-block; vertical-align:middle; margin-right:5px;" class="legend-dot"></div> Full (0 rooms)</div>
        </div>
    </div>
</div>
</asp:Content>