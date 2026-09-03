<%@ Page Title="Partial Check-Out" Language="C#" MasterPageFile="SiteGuestroom.master" AutoEventWireup="true" CodeFile="PartialCheckOut.aspx.cs" Inherits="GuestRoomApp.GuestRoomM.PartialCheckOut" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    /* Rules that require pseudo-elements or media queries */
    .res-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px; background: linear-gradient(90deg, #C9A84C, #8B5E3C); }
    .room-unit:hover { border-color: #C9A84C !important; background: #faf7f2 !important; transform: translateY(-1px); }
    .room-unit.selected { border-color: #1A1A2E !important; background: #1A1A2E !important; color: #C9A84C !important; box-shadow: 0 3px 10px rgba(26,26,46,0.3); }
    .room-unit.selected .check-icon { display: inline-block !important; }
    
    .btn-partial:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(198,40,40,0.4); }
    .btn-full-co:hover { background: #c62828 !important; color: #fff !important; }
    .btn-cancel:hover { background: #4e555b !important; }
    
    .form-control:focus { border-color: #C9A84C !important; outline: none; box-shadow: 0 0 0 3px rgba(201,168,76,0.15); }
    
    @media(max-width:768px) {
        .res-card-foot { flex-direction: column !important; align-items: flex-start !important; }
        .room-unit { min-width: 100px !important; }
    }
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div style="width:100%; padding:18px 22px; background:#F7F3EE; min-height: 100vh; font-family: 'Segoe UI', sans-serif;">

    <%-- PAGE HEADER --%>
    <div style="background:linear-gradient(135deg,#1A1A2E,#2d2d5e); color:#fff; padding:16px 26px; border-radius:10px; margin-bottom:18px; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; box-shadow:0 4px 15px rgba(0,0,0,0.2);">
        <div>
            <h3 style="margin:0; font-size:1.35rem; letter-spacing:1px;"> Partial Check-Out</h3>
            <div style="font-size:.77rem; color:#E8D5A3; margin-top:3px;">Release individual rooms early while keeping the main reservation active</div>
        </div>
        <div style="background:rgba(255,255,255,0.12); border:1px solid rgba(201,168,76,0.5); padding:8px 18px; border-radius:30px; font-weight:700; font-size:.87rem; color:#E8D5A3;">
             Total Occupied Rooms: <strong style="color:#C9A84C; font-size:1.05rem;"><asp:Label ID="lblOccupiedCount" runat="server" Text="0" /></strong>
        </div>
    </div>

    <asp:UpdatePanel ID="upMain" runat="server">
        <ContentTemplate>
            <asp:Label ID="lblMessage" runat="server" CssClass="alert" EnableViewState="false" style="display:none; margin-bottom:15px;" />

            <%-- EMPTY STATE --%>
            <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
                <div style="background:#ffffff; border:2px dashed #e0d5c5; border-radius:10px; padding:60px 20px; text-align:center; box-shadow:0 2px 8px rgba(0,0,0,0.04);">
                    <span style="font-size:2.8rem; color:#E8D5A3; display:block; margin-bottom:12px;"></span>
                    <div style="font-size:1rem; font-weight:700; color:#1A1A2E; margin-bottom:6px;">No Multi-Room Reservations Found</div>
                    <div style="font-size:.84rem; color:#7a7a7a;">All active bookings are single-room, or there are no check-ins at the moment.</div>
                </div>
            </asp:Panel>

            <%-- RESERVATION CARDS --%>
            <asp:Repeater ID="rptReservations" runat="server" OnItemCommand="rptReservations_ItemCommand">
                <ItemTemplate>
                    <div class="res-card" style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; margin-bottom:16px; box-shadow:0 2px 10px rgba(0,0,0,0.06); overflow:hidden; position:relative;">
                        <%-- HEADER --%>
                        <div style="padding:14px 20px; background:#faf7f2; border-bottom:1px solid #e0d5c5; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:8px;">
                            <div>
                                <span style="font-weight:800; color:#1A1A2E; font-size:1rem; font-family:'Courier New',monospace; letter-spacing:.5px;"><%# Eval("ReservationNo") %></span>
                                <span style="font-weight:600; color:#8B5E3C; margin-left:10px; font-size:.9rem;"><%# Eval("GuestName") %></span>
                            </div>
                            <div style="display:flex; gap:8px; align-items:center;">
                                <span style="background:#1A1A2E; color:#C9A84C; padding:4px 14px; border-radius:20px; font-weight:700; font-size:.78rem; letter-spacing:.5px;"><%# Eval("TotalBookedRooms") %> Rooms Total</span>
                                <asp:LinkButton ID="btnFull" runat="server"
                                    CssClass="btn-full-co"
                                    style="background:transparent; border:1.5px solid #c62828; color:#c62828; padding:6px 14px; border-radius:7px; font-size:.82rem; font-weight:700; cursor:pointer; transition:all .15s; text-decoration:none;"
                                    Text="Full Check-Out"
                                    CommandName="FullCheckOut"
                                    CommandArgument='<%# Eval("ReservationNo") %>'
                                    OnClientClick="return confirm('WARNING: This will check out ALL remaining rooms for this reservation. Proceed?');" />
                            </div>
                        </div>

                        <%-- ROOM TILES --%>
                        <div style="padding:18px 20px; display:flex; gap:10px; flex-wrap:wrap;">
                            <asp:Repeater runat="server" DataSource='<%# Eval("Rooms") %>'>
                                <ItemTemplate>
                                    <div class="room-unit"
                                         style="border:2px solid #e0d5c5; border-radius:8px; padding:10px 16px; cursor:pointer; transition:all .2s; display:flex; align-items:center; gap:8px; background:#fff; font-weight:700; font-size:.87rem; color:#1A1A2E; min-width:120px;"
                                         onclick="toggleRoomSelection(this, '<%# Eval("RoomNo") %>', '<%# Eval("ReservationNo") %>', '<%# Eval("Rent") %>')">
                                        <span class="room-icon"></span>
                                        <span>Room <%# Eval("RoomNo") %></span>
                                        <i class="check-icon" style="display:none; color:#C9A84C;"></i>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>

                        <%-- FOOTER --%>
                        <div class="res-card-foot" style="padding:12px 20px; border-top:1px solid #e0d5c5; background:#faf7f2; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:8px;">
                            <span style="font-size:.8rem; color:#7a7a7a;">Click room tiles above to select, then release below.</span>
                            <button type="button" class="btn-partial"
                                style="background:linear-gradient(135deg,#c62828,#b71c1c); color:#fff; border:none; padding:8px 20px; border-radius:7px; font-size:.87rem; font-weight:700; cursor:pointer; transition:transform .15s,box-shadow .15s;"
                                onclick="openPartialModal('<%# Eval("ReservationNo") %>')">
                                 Check-Out Selected Rooms
                            </button>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <%-- PARTIAL CHECKOUT MODAL --%>
            <div id="partialModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.55); z-index:1000; align-items:center; justify-content:center; padding:20px;">
                <div style="background:#ffffff; width:100%; max-width:500px; border-radius:12px; overflow:hidden; box-shadow:0 20px 50px rgba(0,0,0,0.3);">
                    <div style="padding:16px 22px; background:linear-gradient(135deg,#1A1A2E,#2d2d5e); color:#fff; display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid #e0d5c5;">
                        <h4 style="margin:0; font-size:1rem;"> Room Release Details</h4>
                        <button type="button" style="background:none; border:none; color:#fff; font-size:1.4rem; cursor:pointer; line-height:1;" onclick="closeModal()">&times;</button>
                    </div>
                    <div style="padding:22px; background:#faf7f2;">
                        <asp:HiddenField ID="hfReservationNo" runat="server" />
                        <asp:HiddenField ID="hfSelectedRooms" runat="server" />

                        <%-- Context --%>
                        <div style="display:grid; grid-template-columns:1fr 1fr; gap:10px; margin-bottom:16px;">
                            <div style="background:#e3f2fd; border-radius:8px; padding:14px 16px; border-left:3px solid #1565C0; margin-bottom:16px;">
                                <div style="font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:.5px; color:#0d47a1; margin-bottom:4px;">Reservation No</div>
                                <div style="font-weight:800; color:#1A1A2E; font-size:.95rem;" id="modalResDisplay">—</div>
                            </div>
                            <div style="background:#e3f2fd; border-radius:8px; padding:14px 16px; border-left:3px solid #c62828; margin-bottom:16px;">
                                <div style="font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:.5px; color:#c62828; margin-bottom:4px;">Rooms to Release</div>
                                <div style="font-weight:800; color:#1A1A2E; font-size:.95rem;" id="modalRoomsDisplay">—</div>
                            </div>
                        </div>

                        <div style="margin-bottom:14px; display:grid; grid-template-columns:1fr 1fr; gap:10px;">
                            <div>
                                <label style="display:block; font-size:.78rem; font-weight:700; text-transform:uppercase; letter-spacing:.5px; color:#7a7a7a; margin-bottom:6px;">Stay Duration</label>
                                <asp:DropDownList ID="ddlStayType" runat="server" style="width:100%; padding:8px 12px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif;" onchange="calculateCharges()">
                                    <asp:ListItem Text="Full Day (100%)" Value="1.0" Selected="True" />
                                    <asp:ListItem Text="Half Day (50%)"  Value="0.5" />
                                </asp:DropDownList>
                            </div>
                            <div>
                                <label style="display:block; font-size:.78rem; font-weight:700; text-transform:uppercase; letter-spacing:.5px; color:#7a7a7a; margin-bottom:6px;">Estimated Charge</label>
                                <div id="divEstCharge" style="font-weight:800; color:#1565C0; padding:8px 0; font-size:1rem;">PKR 0</div>
                                <asp:HiddenField ID="hfDailyRate" runat="server" Value="0" />
                            </div>
                        </div>

                        <%-- Reason --%>
                        <div style="margin-bottom:14px;">
                            <label style="display:block; font-size:.78rem; font-weight:700; text-transform:uppercase; letter-spacing:.5px; color:#7a7a7a; margin-bottom:6px;">Reason for Early Release</label>
                            <asp:DropDownList ID="ddlReason" runat="server" style="width:100%; padding:8px 12px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif;">
                                <asp:ListItem Text="-- Select Reason --" Value="" />
                                <asp:ListItem Text="Guest Group Split"   Value="Group Departure" />
                                <asp:ListItem Text="Change of Plans"     Value="Plan Change" />
                                <asp:ListItem Text="Early Departure"     Value="Early Exit" />
                                <asp:ListItem Text="Management Shift"    Value="Room Shift Cleanup" />
                            </asp:DropDownList>
                        </div>

                        <%-- Remarks --%>
                        <div>
                            <label style="display:block; font-size:.78rem; font-weight:700; text-transform:uppercase; letter-spacing:.5px; color:#7a7a7a; margin-bottom:6px;">Housekeeping Remarks</label>
                            <asp:TextBox ID="txtRemarks" runat="server" style="width:100%; padding:8px 12px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; resize:vertical; min-height:72px;"
                                TextMode="MultiLine" Rows="3"
                                placeholder="Any specific notes for the housekeeping team..." />
                        </div>
                    </div>
                    <div style="padding:14px 22px; border-top:1px solid #e0d5c5; text-align:right; display:flex; justify-content:flex-end; gap:10px;">
                        <button type="button" style="background:#5a6268; color:#fff; border:none; padding:9px 20px; border-radius:7px; font-size:.87rem; font-weight:600; cursor:pointer; transition:background .15s;" onclick="closeModal()"> Cancel</button>
                        <asp:Button ID="btnConfirmPartial" runat="server"
                            Text=" Release Rooms Now"
                            CssClass="btn-partial"
                            style="background:linear-gradient(135deg,#c62828,#b71c1c); color:#fff; border:none; padding:8px 20px; border-radius:7px; font-size:.87rem; font-weight:700; cursor:pointer; transition:transform .15s,box-shadow .15s;"
                            OnClick="btnConfirmPartial_Click"
                            OnClientClick="return confirm('Release selected rooms? The main reservation will remain active with a reduced room count.');" />
                    </div>
                </div>
            </div>

        </ContentTemplate>
    </asp:UpdatePanel>

</div>

<script type="text/javascript">
    let selectedRooms = [];

    function toggleRoomSelection(el, roomNo, resNo, rate) {
        const hfResField = document.getElementById('<%= hfReservationNo.ClientID %>');
        const hfRateField = document.getElementById('<%= hfDailyRate.ClientID %>');

        // Different reservation selected — clear previous
        if (hfResField.value && hfResField.value !== resNo) {
            document.querySelectorAll('.room-unit.selected').forEach(u => {
                u.classList.remove('selected');
                const icon = u.querySelector('.check-icon');
                if (icon) icon.style.display = 'none';
            });
            selectedRooms = [];
        }

        hfResField.value = resNo;
        hfRateField.value = rate;

        if (el.classList.contains('selected')) {
            el.classList.remove('selected');
            const icon = el.querySelector('.check-icon');
            if (icon) icon.style.display = 'none';
            selectedRooms = selectedRooms.filter(r => r !== roomNo);
        } else {
            el.classList.add('selected');
            const icon = el.querySelector('.check-icon');
            if (icon) icon.style.display = 'inline-block';
            selectedRooms.push(roomNo);
        }

        const hfSelected = document.getElementById('<%= hfSelectedRooms.ClientID %>');
        if (hfSelected) hfSelected.value = selectedRooms.join(',');
        
        if (typeof calculateCharges === 'function') calculateCharges();
    }

    function openPartialModal(resNo) {
        const hfSelected = document.getElementById('<%= hfSelectedRooms.ClientID %>');
        if (!hfSelected || !hfSelected.value) {
            alert('Please select at least one room by clicking on the room tiles first.');
            return;
        }

        // Fetch daily rate for the reservation (this should be populated from the server)
        // For now, we'll let the server handle the logic, but we can show an estimate if we pass the rate
        
        document.getElementById('modalResDisplay').innerText = resNo;
        document.getElementById('modalRoomsDisplay').innerText = hfSelected.value.split(',').join(', ');
        document.getElementById('partialModal').style.display = 'flex';
        
        calculateCharges();
    }

    function calculateCharges() {
        const factor = parseFloat(document.getElementById('<%= ddlStayType.ClientID %>').value) || 1.0;
        const numRooms = (document.getElementById('<%= hfSelectedRooms.ClientID %>').value || "").split(',').filter(x => x).length;
        const rate = parseFloat(document.getElementById('<%= hfDailyRate.ClientID %>').value) || 0;
        
        const total = numRooms * rate * factor;
        document.getElementById('divEstCharge').innerText = 'PKR ' + total.toLocaleString();
    }

    function closeModal() {
        document.getElementById('partialModal').style.display = 'none';
    }

    window.onclick = function (e) {
        const modal = document.getElementById('partialModal');
        if (e.target === modal) closeModal();
    };
</script>
</asp:Content>

