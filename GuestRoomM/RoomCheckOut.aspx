<%@ Page Title="Check-Out" Language="C#" MasterPageFile="SiteGuestroom.master"
    AutoEventWireup="true" CodeFile="RoomCheckOut.aspx.cs" Inherits="GuestRoomApp.GuestRoomM.RoomCheckOut" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    /* Rules that require pseudo-elements or media queries */
    .occupied-card::before { content:''; position:absolute; top:0; left:0; right:0; height:3px; background:linear-gradient(90deg,#C9A84C,#8B5E3C); }
    .form-card::before { content:''; position:absolute; top:0; left:0; right:0; height:4px; background:linear-gradient(90deg,#C9A84C,#8B5E3C); border-radius:10px 10px 0 0; }
    .btn-checkout:hover { transform:translateY(-1px); box-shadow:0 4px 12px rgba(198,40,40,0.4); }
    
    @media(max-width:768px) {
        .detail-grid { grid-template-columns:1fr !important; }
        .occupied-grid { grid-template-columns:1fr !important; }
    }
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div style="width:100%; padding:18px 22px; background:#F7F3EE; min-height:100vh; font-family:'Segoe UI',sans-serif;">

    <%-- PAGE HEADER --%>
    <div style="background:linear-gradient(135deg,#1A1A2E,#2d2d5e); color:#fff; padding:16px 26px; border-radius:10px; margin-bottom:18px; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; box-shadow:0 4px 15px rgba(0,0,0,0.2);">
        <div>
            <h3 style="margin:0; font-size:1.35rem; letter-spacing:1px;">🔓 Check-Out</h3>
            <div style="font-size:.77rem; color:#E8D5A3; margin-top:3px;">Release rooms and complete guest stay</div>
        </div>
    </div>

    <%-- ALERT --%>
    <asp:Label ID="lblMessage" runat="server" CssClass="alert" EnableViewState="false"></asp:Label>

    <%-- SUMMARY BANNER --%>
    <div style="background:linear-gradient(135deg,#1A1A2E,#2d2d5e); color:#fff; border-radius:10px; padding:20px 26px; margin-bottom:18px; display:flex; align-items:center; gap:20px; box-shadow:0 4px 15px rgba(0,0,0,0.2);">
        <div style="font-size:2.2rem; color:#C9A84C; flex-shrink:0;"><i class="fas fa-bed"></i></div>
        <div>
            <div style="font-size:2.4rem; font-weight:800; color:#C9A84C; line-height:1;"><asp:Label ID="lblOccupiedCount" runat="server" Text="0" /></div>
            <div style="font-size:.85rem; color:#E8D5A3; margin-top:2px;">Currently Occupied Rooms — Click Check-Out to release</div>
        </div>
    </div>

    <%-- OCCUPIED ROOMS --%>
    <div style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:20px 22px; margin-bottom:16px; box-shadow:0 2px 10px rgba(0,0,0,0.06); position:relative;">
        <div style="font-size:.71rem; font-weight:700; letter-spacing:2px; text-transform:uppercase; color:#8B5E3C; margin-bottom:14px; padding-bottom:8px; border-bottom:1px solid #e0d5c5;">🛏️ Currently Occupied Rooms</div>

        <div style="display:grid; grid-template-columns:repeat(auto-fill,minmax(340px,1fr)); gap:16px;">
            <asp:Repeater ID="rptOccupiedRooms" runat="server" OnItemCommand="rptOccupiedRooms_ItemCommand">
                <ItemTemplate>
                    <div style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:18px 20px; box-shadow:0 2px 10px rgba(0,0,0,0.06); position:relative; overflow:hidden; border-left:4px solid #c62828; transition:box-shadow .2s;">
                        <div style="display:inline-flex; align-items:center; gap:8px; background:#1A1A2E; color:#C9A84C; font-family:'Courier New',monospace; font-size:1.1rem; font-weight:800; padding:6px 16px; border-radius:8px; margin-bottom:14px; letter-spacing:1px;">
                            <i class="fas fa-door-open"></i>
                            Room <%# Eval("RoomNo") %>
                        </div>

                        <div>
                            <span style="display:inline-flex; align-items:center; gap:5px; background:#fff3e0; color:#bf360c; border:1px solid #ffcc80; padding:3px 12px; border-radius:20px; font-size:.78rem; font-weight:700; margin-bottom:12px;">
                                <i class="fas fa-moon"></i>
                                <%# Eval("NightsStayed") %> Night(s) Stayed
                            </span>
                            <span style="display:inline-flex; align-items:center; gap:5px; background:#e8f5e9; color:#1b5e20; border:1px solid #a5d6a7; padding:3px 12px; border-radius:20px; font-size:.78rem; font-weight:700; margin-left:8px; margin-bottom:12px;">
                                <i class="fas fa-rupee-sign"></i>
                                Advance: PKR <%# Convert.ToDecimal(Eval("AdvancePayment")).ToString("N0") %>
                            </span>
                        </div>

                        <div style="display:grid; grid-template-columns:1fr 1fr; gap:8px; margin-bottom:14px;">
                            <div style="padding:6px 0; border-bottom:1px solid #e0d5c5;">
                                <span style="font-size:.74rem; font-weight:700; text-transform:uppercase; letter-spacing:.5px; color:#7a7a7a; display:block;">Guest Name</span>
                                <span style="font-size:.87rem; font-weight:600; color:#1A1A2E; margin-top:2px; display:block;"><%# Eval("GuestName") %></span>
                            </div>
                            <div style="padding:6px 0; border-bottom:1px solid #e0d5c5;">
                                <span style="font-size:.74rem; font-weight:700; text-transform:uppercase; letter-spacing:.5px; color:#7a7a7a; display:block;">Reservation No</span>
                                <span style="font-size:.87rem; font-weight:600; color:#1A1A2E; margin-top:2px; display:block; font-family:'Courier New',monospace;"><%# Eval("ReservationNo") %></span>
                            </div>
                            <div style="padding:6px 0; border-bottom:1px solid #e0d5c5;">
                                <span style="font-size:.74rem; font-weight:700; text-transform:uppercase; letter-spacing:.5px; color:#7a7a7a; display:block;">Check-In</span>
                                <span style="font-size:.87rem; font-weight:600; color:#1A1A2E; margin-top:2px; display:block;"><%# Convert.ToDateTime(Eval("AllocatedDate")).ToString("dd-MMM-yyyy hh:mm tt") %></span>
                            </div>
                            <div style="padding:6px 0; border-bottom:1px solid #e0d5c5;">
                                <span style="font-size:.74rem; font-weight:700; text-transform:uppercase; letter-spacing:.5px; color:#7a7a7a; display:block;">Expected Check-Out</span>
                                <span style="font-size:.87rem; font-weight:600; color:#1A1A2E; margin-top:2px; display:block;"><%# Convert.ToDateTime(Eval("ToDate")).ToString("dd-MMM-yyyy") %></span>
                            </div>
                        </div>

                        <asp:Button ID="btnCheckOut" runat="server"
    Text=" Check-Out & Release Room"
    style="background:linear-gradient(135deg,#c62828,#b71c1c); color:#fff; border:none; padding:10px 22px; border-radius:8px; cursor:pointer; font-weight:700; font-size:.87rem; width:100%; margin-top:6px; transition:transform .15s,box-shadow .15s;"
    CommandName="CheckOut"
    CommandArgument='<%# Eval("AllocationID") + "|" + Eval("ReservationNo") + "|" + Eval("RoomNo") %>'
    OnClientClick='<%# Eval("RoomNo", "return confirm(\"Check-out Room {0}? The room will be released for new bookings.\");") %>' />
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <%-- EMPTY STATE --%>
        <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
            <div style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:50px 20px; text-align:center; box-shadow:0 2px 8px rgba(0,0,0,0.06);">
                <i class="fas fa-check-circle" style="font-size:3rem; color:#a5d6a7; display:block; margin-bottom:14px;"></i>
                <div style="font-size:1.1rem; font-weight:700; color:#1A1A2E; margin-bottom:6px;">All Rooms are Vacant! 🎉</div>
                <div style="font-size:.86rem; color:#7a7a7a;">No occupied rooms at the moment. All rooms are available for new check-ins.</div>
            </div>
        </asp:Panel>

    </div>

</div>
</asp:Content>









