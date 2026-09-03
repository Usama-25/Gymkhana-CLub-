<%@ Page Title="Check-In" Language="C#" MasterPageFile="SiteGuestroom.master"
    AutoEventWireup="true" CodeFile="RoomCheckIn.aspx.cs" Inherits="GuestRoomApp.GuestRoomM.RoomCheckIn" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    /* Rules that require pseudo-elements or media queries */
    .form-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px; background: linear-gradient(90deg, #C9A84C, #8B5E3C); border-radius: 10px 10px 0 0; }
    .checkin-card-panel::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px; background: linear-gradient(90deg, #C9A84C, #8B5E3C); border-radius: 10px 10px 0 0; }
    .form-control:focus { border-color: #C9A84C !important; outline: none; box-shadow: 0 0 0 3px rgba(201,168,76,0.15); }
    .btn-search:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(21,101,192,0.4); }
    .btn-checkin:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(46,125,50,0.4); }
    .btn-secondary:hover { background: #4e555b !important; }
    .room-card.available:hover { background: #c8e6c9 !important; transform: scale(1.03); box-shadow: 0 3px 8px rgba(0,0,0,0.1); }
    .room-card.selected { background: #1A1A2E !important; color: #C9A84C !important; border-color: #C9A84C !important; }
    
    @media(max-width:992px) { .card-grid { grid-template-columns: repeat(2, 1fr) !important; } }
    @media(max-width:768px) {
        .info-grid, .card-grid, .card-grid-2 { grid-template-columns: 1fr !important; }
        .form-row { flex-direction: column !important; }
    }
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div style="width:100%; padding:18px 22px; background:#F7F3EE; min-height:100vh; font-family:'Segoe UI',sans-serif;">

    <div style="background:linear-gradient(135deg,#1A1A2E,#2d2d5e); color:#fff; padding:16px 26px; border-radius:10px; margin-bottom:18px; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; box-shadow:0 4px 15px rgba(0,0,0,0.2);">
        <div>
            <h3 style="margin:0; font-size:1.35rem; letter-spacing:1px;">Check-In / Room Allocation</h3>
            <div style="font-size:.77rem; color:#E8D5A3; margin-top:3px;">Assign rooms to confirmed reservations (Group Booking Support)</div>
        </div>
    </div>

    <asp:Label ID="lblMessage" runat="server" CssClass="alert" EnableViewState="false"></asp:Label>

    <%-- SEARCH --%>
    <div class="form-card" style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:20px 22px; margin-bottom:16px; box-shadow:0 2px 10px rgba(0,0,0,0.06); position:relative;">
        <div style="font-size:.71rem; font-weight:700; letter-spacing:2px; text-transform:uppercase; color:#8B5E3C; margin-bottom:14px; padding-bottom:8px; border-bottom:1px solid #e0d5c5;"> Find Reservation</div>
        <div style="display:flex; gap:12px; align-items:flex-end; flex-wrap:wrap;">
            <div style="display:flex; flex-direction:column; gap:4px; flex:2; min-width:180px;">
                <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Reservation No / Booking No</label>
                <asp:TextBox ID="txtSearch" runat="server" style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:100%;"
                    placeholder="e.g. RES000001" />
            </div>
            <div style="display:flex; flex-direction:column; gap:4px; flex:0; min-width:auto;">
                <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">&nbsp;</label>
                <asp:Button ID="btnSearch" runat="server" Text=" Search Booking"
                    style="background:linear-gradient(135deg,#1565C0,#0d47a1); color:#fff; border:none; padding:9px 22px; border-radius:7px; font-size:.87rem; font-weight:600; cursor:pointer; white-space:nowrap; transition:transform .15s,box-shadow .15s;" OnClick="btnSearch_Click" />
            </div>
        </div>
    </div>

    <%-- RESERVATION DETAILS + ROOM SELECTION --%>
    <asp:Panel ID="pnlReservation" runat="server" Visible="false">

        <%-- MAIN RESERVATION DETAILS --%>
        <div style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:20px; margin-bottom:16px; border-left:4px solid #1565C0; box-shadow:0 2px 8px rgba(0,0,0,0.06);">
            <div style="font-size:.95rem; font-weight:700; color:#1A1A2E; margin-bottom:14px;"> Booking Details (Group Reservation)</div>
            <div style="display:grid; grid-template-columns:repeat(2,1fr); gap:10px;">
                <div style="display:flex; padding:7px 0; border-bottom:1px solid #e0d5c5; align-items:center;">
                    <span style="width:140px; font-weight:700; color:#7a7a7a; font-size:.82rem; flex-shrink:0;">Booking No:</span>
                    <span style="flex:1; color:#1A1A2E; font-weight:600; font-size:.87rem;"><asp:Label ID="lblReservationNo" runat="server" Font-Bold="true" /></span>
                </div>
                <div style="display:flex; padding:7px 0; border-bottom:1px solid #e0d5c5; align-items:center;">
                    <span style="width:140px; font-weight:700; color:#7a7a7a; font-size:.82rem; flex-shrink:0;">Receipt No:</span>
                    <span style="flex:1; color:#1A1A2E; font-weight:600; font-size:.87rem;"><asp:Label ID="lblReceiptNo" runat="server" /></span>
                </div>
                <div style="display:flex; padding:7px 0; border-bottom:1px solid #e0d5c5; align-items:center;">
                    <span style="width:140px; font-weight:700; color:#7a7a7a; font-size:.82rem; flex-shrink:0;">Category:</span>
                    <span style="flex:1; color:#1A1A2E; font-weight:600; font-size:.87rem;"><asp:Label ID="lblCategory" runat="server" Font-Bold="true" /></span>
                </div>
                <div style="display:flex; padding:7px 0; border-bottom:1px solid #e0d5c5; align-items:center;">
                    <span style="width:140px; font-weight:700; color:#7a7a7a; font-size:.82rem; flex-shrink:0;">Guest Name:</span>
                    <span style="flex:1; color:#1A1A2E; font-weight:600; font-size:.87rem;"><asp:Label ID="lblGuestName" runat="server" Font-Bold="true" /></span>
                </div>
                <div style="display:flex; padding:7px 0; border-bottom:1px solid #e0d5c5; align-items:center;">
                    <span style="width:140px; font-weight:700; color:#7a7a7a; font-size:.82rem; flex-shrink:0;">Check-In Date:</span>
                    <span style="flex:1; color:#1A1A2E; font-weight:600; font-size:.87rem;"><asp:Label ID="lblFromDate" runat="server" Font-Bold="true" /></span>
                </div>
                <div style="display:flex; padding:7px 0; border-bottom:1px solid #e0d5c5; align-items:center;">
                    <span style="width:140px; font-weight:700; color:#7a7a7a; font-size:.82rem; flex-shrink:0;">Check-Out Date:</span>
                    <span style="flex:1; color:#1A1A2E; font-weight:600; font-size:.87rem;"><asp:Label ID="lblToDate" runat="server" /></span>
                </div>
                <div style="display:flex; padding:7px 0; border-bottom:1px solid #e0d5c5; align-items:center;">
                    <span style="width:140px; font-weight:700; color:#7a7a7a; font-size:.82rem; flex-shrink:0;">Rooms Booked:</span>
                    <span style="flex:1; color:#1A1A2E; font-weight:600; font-size:.87rem;"><asp:Label ID="lblNoOfRooms" runat="server" Font-Bold="true" /></span>
                </div>
                <div style="display:flex; padding:7px 0; border-bottom:1px solid #e0d5c5; align-items:center;">
                    <span style="width:140px; font-weight:700; color:#7a7a7a; font-size:.82rem; flex-shrink:0;">Current Status:</span>
                    <span style="flex:1; color:#1A1A2E; font-weight:600; font-size:.87rem;"><asp:Label ID="lblStatus" runat="server" style="display:inline-block; padding:4px 12px; border-radius:20px; font-size:.8rem; font-weight:700; background:#e3f2fd; color:#1565C0;" /></span>
                </div>
                <div style="display:flex; padding:7px 0; border-bottom:1px solid #e0d5c5; align-items:center;">
                    <span style="width:140px; font-weight:700; color:#7a7a7a; font-size:.82rem; flex-shrink:0;">Advance Paid:</span>
                    <span style="flex:1; color:#1A1A2E; font-weight:600; font-size:.87rem;"><asp:Label ID="lblAdvancePaid" runat="server" Font-Bold="true" ForeColor="#2e7d32" Text="0" /></span>
                </div>
            </div>
        </div>

        <%-- ALLOCATED ROOMS (if already checked in) --%>
        <asp:Panel ID="pnlAllocatedRooms" runat="server" Visible="false" style="background:#e8f5e9; padding:10px; border-radius:8px; margin-top:10px;">
            <div style="font-weight:700; margin-bottom:8px;"> Reservation Allocations:</div>
            <asp:Repeater ID="rptAllocatedRooms" runat="server">
                <ItemTemplate>
                    <div style="display:inline-block; margin-right:15px; margin-bottom:10px; vertical-align:top;">
                        <span style='display:inline-block; background:#2e7d32; color:white; padding:3px 10px; border-radius:15px; margin:3px; font-size:.75rem;'>
                            Room <%# Eval("RoomNo") %>
                            <small>(<%# Eval("CheckOutDate") == DBNull.Value ? "Active" : "Checked-Out" %>)</small>
                        </span>
                        <div style="font-size: 0.7rem; color: #666; margin-top: 2px;">
                            RFID: <b style='color:<%# Eval("RFIDDeactive") != DBNull.Value && Eval("RFIDDeactive").ToString() == "Yes" ? "#c62828" : "#2e7d32" %>'>
                                <%# Eval("RFIDDeactive") != DBNull.Value && Eval("RFIDDeactive").ToString() == "Yes" ? "DEACTIVE" : "LIVE" %>
                            </b>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>

        <%-- MEMBER CATEGORY DETAILS --%>
        <asp:Panel ID="pnlMemberDetails" runat="server" Visible="false" style="background:#faf7f2; border-radius:8px; padding:12px; margin-top:10px; border-left:3px solid #C9A84C;">
            <div style="font-size:.75rem; font-weight:700; color:#8B5E3C; margin-bottom:10px; letter-spacing:1px;"> Member / Guest Of Information</div>
            <div style="display:grid; grid-template-columns:repeat(2,1fr); gap:10px;">
                <div style="display:flex; padding:7px 0; border-bottom:1px solid #e0d5c5; align-items:center;">
                    <span style="width:140px; font-weight:700; color:#7a7a7a; font-size:.82rem; flex-shrink:0;">Guest Of:</span>
                    <span style="flex:1; color:#1A1A2E; font-weight:600; font-size:.87rem;"><asp:Label ID="lblGuestOf" runat="server" Font-Bold="true" /></span>
                </div>
                <div style="display:flex; padding:7px 0; border-bottom:1px solid #e0d5c5; align-items:center;">
                    <span style="width:140px; font-weight:700; color:#7a7a7a; font-size:.82rem; flex-shrink:0;">Member No:</span>
                    <span style="flex:1; color:#1A1A2E; font-weight:600; font-size:.87rem;"><asp:Label ID="lblMemberNo" runat="server" /></span>
                </div>
                <div style="display:flex; padding:7px 0; border-bottom:1px solid #e0d5c5; align-items:center;">
                    <span style="width:140px; font-weight:700; color:#7a7a7a; font-size:.82rem; flex-shrink:0;">Member Name:</span>
                    <span style="flex:1; color:#1A1A2E; font-weight:600; font-size:.87rem;"><asp:Label ID="lblMemberName" runat="server" /></span>
                </div>
            </div>
        </asp:Panel>

        <%-- AFFILIATED CATEGORY DETAILS --%>
        <asp:Panel ID="pnlAffiliatedDetails" runat="server" Visible="false" style="background:#faf7f2; border-radius:8px; padding:12px; margin-top:10px; border-left:3px solid #C9A84C;">
            <div style="font-size:.75rem; font-weight:700; color:#8B5E3C; margin-bottom:10px; letter-spacing:1px;"> Affiliated Club Details</div>
            <div style="display:grid; grid-template-columns:repeat(2,1fr); gap:10px;">
                <div style="display:flex; padding:7px 0; border-bottom:1px solid #e0d5c5; align-items:center;">
                    <span style="width:140px; font-weight:700; color:#7a7a7a; font-size:.82rem; flex-shrink:0;">Club Name:</span>
                    <span style="flex:1; color:#1A1A2E; font-weight:600; font-size:.87rem;"><asp:Label ID="lblClubName" runat="server" Font-Bold="true" /></span>
                </div>
                <div style="display:flex; padding:7px 0; border-bottom:1px solid #e0d5c5; align-items:center;">
                    <span style="width:140px; font-weight:700; color:#7a7a7a; font-size:.82rem; flex-shrink:0;">Intro Card #:</span>
                    <span style="flex:1; color:#1A1A2E; font-weight:600; font-size:.87rem;"><asp:Label ID="lblIntroCard" runat="server" /></span>
                </div>
                <div style="display:flex; padding:7px 0; border-bottom:1px solid #e0d5c5; align-items:center;">
                    <span style="width:140px; font-weight:700; color:#7a7a7a; font-size:.82rem; flex-shrink:0;">Card Expiry:</span>
                    <span style="flex:1; color:#1A1A2E; font-weight:600; font-size:.87rem;"><asp:Label ID="lblExpiryDate" runat="server" /></span>
                </div>
            </div>
        </asp:Panel>

        <%-- =====================================================
             CHECK-IN CARD PANEL  (from physical card image)
             ===================================================== --%>
        <asp:Panel ID="pnlCheckInCard" runat="server" Visible="true">
            <div style="background:#ffffff; border:2px solid #C9A84C; border-radius:10px; padding:20px 22px; margin-bottom:16px; box-shadow:0 2px 10px rgba(201,168,76,0.15); position:relative;">
                <div style="font-size:.71rem; font-weight:700; letter-spacing:2px; text-transform:uppercase; color:#8B5E3C; margin-bottom:14px; padding-bottom:8px; border-bottom:1px solid #e0d5c5;"> Check-In Card Details &nbsp;<small style="font-size:.68rem;color:#7a7a7a;font-weight:400;letter-spacing:0;">(Lahore Gymkhana Guest Rooms)</small></div>

                <%-- Row 1: Name Of Guest (Editable) --%>
                <div style="display:flex; flex-direction:column; gap:4px; margin-bottom:12px;">
                    <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Name of Guest <small style="color:#7a7a7a; font-weight:normal;">(Auto-filled from reservation, editable)</small></label>
                    <asp:TextBox ID="txtGuestName" runat="server" style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:100%;" placeholder="Enter guest name" />
                </div>

                <%-- Row 2: No. of Guests (Total + Breakup) --%>
                <div class="card-grid" style="display:grid; grid-template-columns:repeat(3,1fr); gap:12px; margin-bottom:12px;">
                    <div style="display:flex; flex-direction:column; gap:4px;">
                        <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Total No. of Guests</label>
                        <asp:TextBox ID="txtNoOfGuests" runat="server" style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:100%;"
                            placeholder="Total" TextMode="Number" />
                    </div>
                    <div style="display:flex; flex-direction:column; gap:4px;">
                        <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Adults (Men)</label>
                        <asp:TextBox ID="txtMen" runat="server" style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:100%;" 
                            placeholder="Men" TextMode="Number" />
                    </div>
                    <div style="display:flex; flex-direction:column; gap:4px;">
                        <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Adults (Women)</label>
                        <asp:TextBox ID="txtWomen" runat="server" style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:100%;" 
                            placeholder="Women" TextMode="Number" />
                    </div>
                    <div style="display:flex; flex-direction:column; gap:4px;">
                        <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Children</label>
                        <asp:TextBox ID="txtChild" runat="server" style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:100%;" 
                            placeholder="Children" TextMode="Number" />
                    </div>
                </div>

                <%-- Row 2: Address (full width) --%>
                <div style="display:flex; flex-direction:column; gap:4px; margin-bottom:12px;">
                    <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Address</label>
                    <asp:TextBox ID="txtGuestAddress" runat="server" style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:100%;"
                        placeholder="Guest's full address" />
                </div>

                <%-- Row 3: Guest Of / M.Ship # / Affiliated Club — read-only from booking --%>
                <div class="card-grid" style="display:grid; grid-template-columns:repeat(3,1fr); gap:12px; margin-bottom:12px;">
                    <div id="divGuestOfCard" runat="server" style="display:flex; flex-direction:column; gap:4px;">
                        <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Guest Of</label>
                        <div style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#7a7a7a; background:#f5f0e8; font-family:'Segoe UI',sans-serif; width:100%;">
                            <asp:Label ID="lblGuestOfCard" runat="server" Text="" />
                        </div>
                    </div>
                    <div id="divMemberNoCard" runat="server" style="display:flex; flex-direction:column; gap:4px;">
                        <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">M/Ship #</label>
                        <div style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#7a7a7a; background:#f5f0e8; font-family:'Segoe UI',sans-serif; width:100%;">
                            <asp:Label ID="lblMemberNoCard" runat="server" Text="" />
                        </div>
                    </div>
                    <div id="divAffiliatedClubCard" runat="server" style="display:flex; flex-direction:column; gap:4px;">
                        <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Affiliated Club</label>
                        <div style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#7a7a7a; background:#f5f0e8; font-family:'Segoe UI',sans-serif; width:100%;">
                            <asp:Label ID="lblAffiliatedClubCard" runat="server" Text="" />
                        </div>
                    </div>
                </div>

                               <div class="card-grid" style="display:grid; grid-template-columns:repeat(3,1fr); gap:12px; margin-bottom:12px;">
                    <div style="display:flex; flex-direction:column; gap:4px;">
                        <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Arrival Date</label>
                        <div style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#7a7a7a; background:#f5f0e8; font-family:'Segoe UI',sans-serif; width:100%;">
                            <asp:Label ID="lblArrivalDateCard" runat="server" Text="" />
                        </div>
                    </div>
                    <div style="display:flex; flex-direction:column; gap:4px;">
                        <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Arrival Time</label>
                        <asp:TextBox ID="txtArrivalTime" runat="server" style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:100%;"
                            placeholder="e.g. 14:00" TextMode="Time" />
                    </div>
                    <div style="display:flex; flex-direction:column; gap:4px;">
    <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">
        Departure Date
    </label>

    <asp:TextBox 
        ID="txtDepartureDateCard" 
        runat="server"
        TextMode="Date"
        style="padding:8px 11px; 
               border:1.5px solid #e0d5c5; 
               border-radius:7px; 
               font-size:.87rem; 
               color:#1A1A2E; 
               background:#fff; 
               font-family:'Segoe UI',sans-serif; 
               width:100%;" />
</div>
                </div>


                <%-- Row 5: Check In By / Bill # --%>
                <div style="display:grid; grid-template-columns:repeat(2,1fr); gap:12px; margin-bottom:12px;">
                    <div style="display:flex; flex-direction:column; gap:4px;">
                        <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Check In By <span style="color:#c62828; margin-left:2px;">*</span></label>
                        <asp:TextBox ID="txtCheckInBy" runat="server" style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:100%;"
                            placeholder="Staff name / ID" />
                    </div>
                    <div style="display:flex; flex-direction:column; gap:4px;">
                        <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Bill #</label>
                        <div style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#7a7a7a; background:#f5f0e8; font-family:'Segoe UI',sans-serif; width:100%;">
                            <asp:Label ID="lblBillNoCard" runat="server" Text="" />
                        </div>
                    </div>
                </div>

                <%-- Row 6: CNIC / Passport # + Country --%>
                <div style="display:grid; grid-template-columns:repeat(2,1fr); gap:12px; margin-bottom:12px;">
                    <div style="display:flex; flex-direction:column; gap:4px;">
                        <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">C.N.I.C # / Passport #</label>
                        <asp:TextBox ID="txtCNIC" runat="server" style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:100%;"
                            placeholder="e.g. 35201-1234567-1" MaxLength="30" />
                    </div>
                    <div style="display:flex; flex-direction:column; gap:4px;">
                        <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Country</label>
                        <asp:TextBox ID="txtCountry" runat="server" style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:100%;"
                            placeholder="e.g. Pakistan" MaxLength="100" />
                    </div>
                </div>

                <%-- Row 7: Driver's Name / Driver Stay Yes-No / Vehicle # --%>
                <div class="card-grid" style="display:grid; grid-template-columns:repeat(3,1fr); gap:12px; margin-bottom:12px;">
                    <div style="display:flex; flex-direction:column; gap:4px;">
                        <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Driver's Name</label>
                        <asp:TextBox ID="txtDriverName" runat="server" style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:100%;"
                            placeholder="Driver's full name" MaxLength="200" />
                    </div>
                    <div style="display:flex; flex-direction:column; gap:4px;">
                        <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Driver Stay</label>
                        <div style="display:flex; gap:16px; align-items:center; padding:8px 0;">
                            <label style="display:flex; align-items:center; gap:5px; font-size:.87rem; font-weight:600; cursor:pointer; color:#1A1A2E;">
                                <asp:RadioButton ID="rbDriverStayYes" runat="server"
                                    GroupName="DriverStay" Text="Yes" />
                            </label>
                            <label style="display:flex; align-items:center; gap:5px; font-size:.87rem; font-weight:600; cursor:pointer; color:#1A1A2E;">
                                <asp:RadioButton ID="rbDriverStayNo" runat="server"
                                    GroupName="DriverStay" Text="No" Checked="true" />
                            </label>
                        </div>
                    </div>
                    <div style="display:flex; flex-direction:column; gap:4px;">
                        <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Vehicle # (Veh #)</label>
                        <asp:TextBox ID="txtVehicleNo" runat="server" style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:100%;"
                            placeholder="e.g. LHR-1234" MaxLength="50" />
                    </div>
                </div>

                <%-- Row 8: Remarks (full width) --%>
                <div style="display:flex; flex-direction:column; gap:4px;">
                    <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Remarks (If Any)</label>
                    <asp:TextBox ID="txtRemarks" runat="server" style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:100%; resize:vertical; min-height:60px;"
                        TextMode="MultiLine" Rows="2"
                        placeholder="Any special instructions or notes..." />
                </div>

            </div>
        </asp:Panel>

        <%-- ROOM SELECTION (only if not already checked in) --%>
        <asp:Panel ID="pnlRoomSelection" runat="server" Visible="true">
            <div style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:20px 22px; margin-bottom:16px; box-shadow:0 2px 10px rgba(0,0,0,0.06); position:relative;">
                <div style="font-size:.71rem; font-weight:700; letter-spacing:2px; text-transform:uppercase; color:#8B5E3C; margin-bottom:14px; padding-bottom:8px; border-bottom:1px solid #e0d5c5;"> Select Rooms to Allocate (Select <asp:Label ID="lblRequiredCount" runat="server" Text="0" /> rooms)</div>

                <div style="display:inline-flex; align-items:center; gap:6px; background:#faf7f2; border:1px solid #e0d5c5; padding:5px 14px; border-radius:20px; font-size:.82rem; font-weight:600; color:#1A1A2E; margin-bottom:6px;">
                    Selected: <span style="color:#C9A84C; font-size:1rem; font-weight:800;"><asp:Label ID="lblSelectedCount" runat="server" Text="0" /></span>
                    &nbsp;/&nbsp;
                    Required: <span style="color:#C9A84C; font-size:1rem; font-weight:800;"><asp:Label ID="lblRequiredCount2" runat="server" Text="0" /></span>
                </div>

                <asp:HiddenField ID="hfSelectedRooms" runat="server" />
                <asp:HiddenField ID="hfRFIDData" runat="server" />

                <div class="room-grid" style="display:grid; grid-template-columns:repeat(auto-fill,minmax(95px,1fr)); gap:10px; margin:16px 0; max-height:320px; overflow-y:auto; padding:14px; border:1px solid #e0d5c5; border-radius:8px; background:#F7F3EE;">
                    <asp:Repeater ID="rptRooms" runat="server">
                        <ItemTemplate>
                            <div class="room-card <%# GetRoomStatusClass(Eval("Status").ToString()) %>"
                                 style='padding:12px 8px; border-radius:8px; text-align:center; cursor:pointer; transition:all .2s; border:2px solid transparent; <%# Eval("Status").ToString() == "Available" ? "background:#e8f5e9; border-color:#a5d6a7; color:#1b5e20;" : (Eval("Status").ToString() == "Occupied" ? "background:#fce4ec; border-color:#ef9a9a; color:#b71c1c; cursor:not-allowed; opacity:.65;" : "") %>'
                                 data-roomno='<%# Eval("RoomNo") %>'
                                 data-status='<%# Eval("Status") %>'
                                 onclick='selectRoom(this)'>
                                <span style="font-size:1.05rem; font-weight:800; display:block;"><%# Eval("RoomNo") %></span>
                                <span style="font-size:.68rem; margin-top:3px; display:block; opacity:.85;"><%# Eval("RoomType") %></span>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div id="rfidContainer" style="margin-top:20px; display:none;">
                    <div style="font-size:.71rem; font-weight:700; letter-spacing:2px; text-transform:uppercase; color:#8B5E3C; margin-bottom:14px; padding-bottom:8px; border-bottom:1px solid #e0d5c5; font-size: .65rem; border-color: #e0d5c5;">Assign RFID Card per Room</div>
                    <div id="rfidList" style="display:grid; grid-template-columns:repeat(auto-fill, minmax(280px, 1fr)); gap:12px;"></div>
                </div>

                <div style="display:flex; gap:12px; margin-top:14px; flex-wrap:wrap;">
                    <asp:Button ID="btnConfirmCheckIn" runat="server"
                        Text=" Confirm Check-In & Allocate Rooms"
                        style="background:linear-gradient(135deg,#2e7d32,#1b5e20); color:#fff; border:none; padding:11px 28px; border-radius:8px; font-size:.9rem; font-weight:700; cursor:pointer; transition:transform .15s,box-shadow .15s;"
                        OnClick="btnConfirmCheckIn_Click"
                        OnClientClick="return prepareSelectedRooms();" />
                    <asp:Button ID="btnCancel" runat="server"
                        Text=" Clear"
                        style="background:#5a6268; color:#fff; border:none; padding:11px 24px; border-radius:8px; font-size:.9rem; font-weight:600; cursor:pointer; transition:background .15s;"
                        OnClick="btnCancel_Click"
                        CausesValidation="false" />
                </div>
            </div>
        </asp:Panel>

    </asp:Panel>

</div>

<script>
    // Sync Guest Name from booking label into Check-In Card display
    window.addEventListener('load', function () {
        var src = document.getElementById('<%= lblGuestName.ClientID %>');
        var dst = document.getElementById('<%= txtGuestName.ClientID %>');
        if (src && dst) {
            dst.value = src.innerText;
        }

        // Also sync read-only card labels from booking data
        syncCardLabel('<%= lblFromDate.ClientID %>', '<%= lblArrivalDateCard.ClientID %>');
        syncCardLabel('<%= lblToDate.ClientID %>',   '<%= txtDepartureDateCard.ClientID %>');
        syncCardLabel('<%= lblReceiptNo.ClientID %>', '<%= lblBillNoCard.ClientID %>');
    });

    function syncCardLabel(srcId, dstId) {
        var s = document.getElementById(srcId);
        var d = document.getElementById(dstId);
        if (s && d && s.innerText.trim()) d.innerText = s.innerText;
    }

    function selectRoom(element) {
        var status = element.getAttribute('data-status');
        if (status !== 'Available') return;
        element.classList.toggle('selected');
        updateSelectedRooms();
    }

    function updateSelectedRooms() {
        var selected = [];
        var rfidList = document.getElementById('rfidList');
        var rfidContainer = document.getElementById('rfidContainer');
        
        document.querySelectorAll('.room-card.selected').forEach(function (card) {
            selected.push(card.getAttribute('data-roomno'));
        });
        
        var hf = document.getElementById('<%= hfSelectedRooms.ClientID %>');
        if (hf) hf.value = selected.join(',');
        var lbl = document.getElementById('<%= lblSelectedCount.ClientID %>');
        if (lbl) lbl.innerText = selected.length;

        // Update RFID Inputs
        if (selected.length > 0) {
            rfidContainer.style.display = 'block';
            
            // Keep track of existing values to not lose them on re-click
            var currentData = {};
            document.querySelectorAll('.rfid-input').forEach(function(input) {
                currentData[input.getAttribute('data-room')] = input.value;
            });

            rfidList.innerHTML = '';
                selected.forEach(function(room) {
                    var val = currentData[room] || '';
                    var html = `
    <div style="display:flex; flex-direction:column; gap:4px; background:#faf7f2; padding:10px; border-radius:8px; border:1px solid #e0d5c5;">
        <label style="font-size:.81rem; font-weight:600; color:#1A1A2E; display:flex; justify-content:space-between;">
            <span>RFID / Key Card for <b>Room ${room}</b></span>
        </label>
        <input
            type="text"
            style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:100%;"
            class="rfid-input"
            data-room="${room}"
            value="${val}"
            placeholder="Swipe or Type RFID #"
            onkeydown="return event.key !== 'Enter';"
            autocomplete="off"
        />
    </div>
`;
                    rfidList.innerHTML += html;
                });
        } else {
            rfidContainer.style.display = 'none';
            rfidList.innerHTML = '';
        }
    }

    function prepareSelectedRooms() {
        var hf = document.getElementById('<%= hfSelectedRooms.ClientID %>');
        var hfRfid = document.getElementById('<%= hfRFIDData.ClientID %>');
        var req = parseInt(document.getElementById('<%= lblRequiredCount.ClientID %>').innerText || '0');
        var selected = hf ? hf.value.split(',').filter(function (r) { return r.trim(); }) : [];
        
        if (selected.length === 0) {
            alert('Please select at least one room to allocate.');
            return false;
        }
        if (selected.length > req) {
            alert('You can select AT MOST ' + req + ' room(s). Currently selected: ' + selected.length);
            return false;
        }

        // Collect RFID data
        var rfidData = {};
        document.querySelectorAll('.rfid-input').forEach(function(input) {
            rfidData[input.getAttribute('data-room')] = input.value.trim();
        });
        hfRfid.value = JSON.stringify(rfidData);

        // Basic validation: Check-In By is required
        var checkInBy = document.getElementById('<%= txtCheckInBy.ClientID %>');
        if (checkInBy && !checkInBy.value.trim()) {
            alert('Please enter the name of the staff doing the check-in (Check In By field).');
            checkInBy.focus();
            return false;
        }

        return confirm('Confirm check-in for ' + selected.length + ' room(s)?');
    }
</script>
</asp:Content>

