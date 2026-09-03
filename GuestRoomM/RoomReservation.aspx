<%@ Page Language="C#" MasterPageFile="SiteGuestroom.master" AutoEventWireup="true" CodeFile="RoomReservation.aspx.cs" Inherits="GuestRoomApp.GuestRoomM.RoomReservation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
<style>
    /* Styles that cannot be inlined (pseudo-elements & media queries) */
    .form-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px; background: linear-gradient(90deg, #C9A84C, #8B5E3C); border-radius: 10px 10px 0 0; }
    .form-control:focus { border-color: #C9A84C !important; outline: none; box-shadow: 0 0 0 3px rgba(201,168,76,0.15); }
    .btn-action:hover { transform: translateY(-1px); box-shadow: 0 4px 10px rgba(0,0,0,0.15); }
    
    @media(max-width: 1050px) { 
        .panel-left { flex: 0 0 62% !important; max-width: 62% !important; } 
        .panel-right { flex: 0 0 calc(38% - 16px) !important; max-width: calc(38% - 16px) !important; } 
    }
    @media(max-width: 860px) { 
        .page-layout { flex-direction: column !important; } 
        .panel-left, .panel-right { flex: 0 0 100% !important; max-width: 100% !important; } 
    }
    
    /* Data Table Styling */
    .data-table { width: 100%; border-collapse: collapse; background: #fff; font-size: 0.78rem; }
    .data-table thead th { position: sticky; top: 0; z-index: 5; background: #1A1A2E; color: #fff; font-weight: 700; text-transform: uppercase; font-size: 0.72rem; letter-spacing: 0.5px; padding: 12px 10px; border-bottom: 2px solid #e2e8f0; text-align: left; }
    .data-table td { padding: 10px; border-bottom: 1px solid #f1f5f9; color: #1e293b; }
    .data-table tr:hover { background: #f8fafc; }
</style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="Server">

<div style="width: 100%; padding: 18px 22px; background: #F7F3EE; min-height: 100vh; font-family: 'Segoe UI', sans-serif;">

    <%-- PAGE HEADER --%>
    <div style="background: linear-gradient(135deg, #1A1A2E, #2d2d5e); color: #fff; padding: 16px 26px; border-radius: 10px; margin-bottom: 18px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 4px 15px rgba(0,0,0,0.2);">
        <div>
            <h3 style="margin: 0; font-size: 1.35rem;">Room Reservation</h3>
            <div style="font-size: .77rem; color: #E8D5A3; margin-top: 3px;">Guest Room Management · Booking & Allocation</div>
        </div>
        <asp:Label ID="lblResNo" runat="server" style="background: #C9A84C; color: #1A1A2E; font-family: monospace; font-weight: 700; font-size: .85rem; padding: 5px 16px; border-radius: 20px; min-width: 130px; text-align: center;" Text="RES-XXXXXX"></asp:Label>
    </div>

    <%-- SUMMARY BAR --%>
    <div style="background: linear-gradient(135deg, #e8f4f8, #dbeafe); border-left: 4px solid #1565C0; padding: 10px 16px; border-radius: 8px; margin-bottom: 16px; font-size: .85rem; font-weight: 600; color: #1A1A2E; display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">
        <i class="fas fa-chart-line"></i>
        <asp:Label ID="lblRoomSummary" runat="server" Text="Loading room status..." Font-Bold="true" />
    </div>

    <asp:Label ID="lblMessage" runat="server" CssClass="alert" EnableViewState="false"></asp:Label>

    <asp:HiddenField ID="hfSelectedRooms" runat="server" />
    <asp:TextBox ID="txtReservationNo" runat="server" ReadOnly="true" style="display:none;"></asp:TextBox>
    <asp:TextBox ID="txtReceiptNo" runat="server" ReadOnly="true" style="display:none;"></asp:TextBox>
    <asp:TextBox ID="txtReceiptDisplay" runat="server" ReadOnly="true" style="display:none;"></asp:TextBox>

    <div class="page-layout" style="display: flex; gap: 16px; align-items: flex-start; width: 100%;">

        <%-- LEFT PANEL --%>
        <div class="panel-left" style="flex: 0 0 68%; max-width: 68%;">

            <%-- CARD 1: STAY DATES --%>
            <div class="form-card" style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 20px 22px; margin-bottom: 16px; box-shadow: 0 2px 10px rgba(0,0,0,0.06); position: relative;">
                <div style="font-size: .71rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 15px; padding-bottom: 8px; border-bottom: 1px solid #e0d5c5;"> Stay Period</div>
                <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin-bottom: 12px;">
                    <div style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">From Date <span style="color: #c62828;">*</span></label>
                        <asp:TextBox ID="txtFromDate" runat="server" TextMode="Date" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; transition: border-color .2s; width: 100%;"></asp:TextBox>
                    </div>
                    <div style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">To Date <span style="color: #c62828;">*</span></label>
                        <asp:TextBox ID="txtToDate" runat="server" TextMode="Date" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; transition: border-color .2s; width: 100%;"></asp:TextBox>
                    </div>
                    <div style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Arrival Time</label>
                        <asp:TextBox ID="txtArrivalTime" runat="server" TextMode="Time" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; transition: border-color .2s; width: 100%;"></asp:TextBox>
                    </div>
                    <div style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">&nbsp;</label>
                        <asp:Button ID="btnCheckAvail" runat="server" Text=" Check Rooms" OnClick="btnCheckAvail_Click" 
                            style="background: linear-gradient(135deg, #1565C0, #0d47a1); color: #fff; border:none; padding: 8px 16px; border-radius: 7px; font-size: .82rem; font-weight: 600; cursor: pointer; white-space: nowrap;" />
                        <asp:LinkButton ID="btnViewCalendar" runat="server" 
                            style="color: #1565C0; font-size: .75rem; font-weight: 600; text-decoration: none; display: flex; align-items: center; gap: 5px; margin-top: 8px; transition: color .2s;" 
                            OnClientClick="window.open('RoomAvailabilityCalendar.aspx', '_blank'); return false;">
                            <i class="fas fa-calendar-alt"></i> View Availability Calendar
                        </asp:LinkButton>
                    </div>
                </div>
            </div>

            <%-- CARD 2: RESERVATION CATEGORY --%>
            <div class="form-card" style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 20px 22px; margin-bottom: 16px; box-shadow: 0 2px 10px rgba(0,0,0,0.06); position: relative;">
                <div style="font-size: .71rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 15px; padding-bottom: 8px; border-bottom: 1px solid #e0d5c5;"> Reservation Type & Status</div>
                <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 12px;">
                    <div style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">No. of Rooms</label>
                        <asp:TextBox ID="txtNoOfRooms" runat="server" TextMode="Number" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; width: 100%;" Text="1"></asp:TextBox>
                    </div>
                    <div style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Status</label>
                        <asp:DropDownList ID="ddlStatus" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; width: 100%;">
                            <asp:ListItem Value="Pending">pending</asp:ListItem>
                            <asp:ListItem Value="Confirmed">confirmed</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Category</label>
                        <div style="display: flex; gap: 14px; align-items: center; border: 1.5px solid #e0d5c5; border-radius: 7px; padding: 8px 12px; background: #fff;">
                            <label style="display: inline-flex; align-items: center; gap: 5px; font-size: .84rem; font-weight: 600; cursor: pointer;">
                                <asp:RadioButton ID="rbGuest" runat="server" GroupName="ReservationType" Checked="true" 
                                    OnCheckedChanged="rbGuest_CheckedChanged" AutoPostBack="true" />
                                Guest
                            </label>
                            <label style="display: inline-flex; align-items: center; gap: 5px; font-size: .84rem; font-weight: 600; cursor: pointer;">
                                <asp:RadioButton ID="rbMember" runat="server" GroupName="ReservationType" 
                                    OnCheckedChanged="rbMember_CheckedChanged" AutoPostBack="true" />
                                Member
                            </label>
                            <label style="display: inline-flex; align-items: center; gap: 5px; font-size: .84rem; font-weight: 600; cursor: pointer;">
                                <asp:RadioButton ID="rbAffiliated" runat="server" GroupName="ReservationType" 
                                    OnCheckedChanged="rbAffiliated_CheckedChanged" AutoPostBack="true" />
                                Affiliated
                            </label>
                        </div>
                    </div>
                </div>
            </div>

            <%-- CARD 3: GUEST INFORMATION --%>
            <div class="form-card" style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 20px 22px; margin-bottom: 16px; box-shadow: 0 2px 10px rgba(0,0,0,0.06); position: relative;">
                <div style="font-size: .71rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 15px; padding-bottom: 8px; border-bottom: 1px solid #e0d5c5;"> Guest Information</div>


                <%-- Affiliated Fields --%>
                <div id="divAffiliatedFields" runat="server">
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 12px;">
                        <div style="display: flex; flex-direction: column;">
                            <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Intro Card #</label>
                            <div style="position: relative; display: flex; align-items: center;">
                                <i class="fas fa-id-card" style="position: absolute; left: 10px; color: #7a7a7a; font-size: .85rem; z-index: 1;"></i>
                                <asp:TextBox ID="txtIntroCard" runat="server" style="padding: 8px 11px 8px 30px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; width: 100%;" placeholder="Enter Card No."></asp:TextBox>
                            </div>
                        </div>
                        <div style="display: flex; flex-direction: column;">
                            <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Card Expiry Date</label>
                            <asp:TextBox ID="txtExpiryDate" runat="server" TextMode="Date" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; width: 100%;"></asp:TextBox>
                        </div>
                    </div>
                </div>

                <%-- Member Fields --%>
                <div id="divMemberFields" runat="server">
                    <asp:UpdatePanel ID="upMemberSearch" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 12px;">
                                <div style="display: flex; flex-direction: column;">
                                    <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Member No (Guest Of)</label>
                                    <asp:Panel ID="pnlMemberSearch" runat="server" DefaultButton="btnSearchMember" style="display: flex; gap: 5px;">
                                        <asp:TextBox ID="txtMemberNo" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; flex:1;" placeholder="Enter Member Number" />
                                        <asp:Button ID="btnSearchMember" runat="server" Text=" Search" OnClick="btnSearchMember_Click" 
                                            style="background: #1565C0; color: #fff; border:none; padding: 8px 15px; border-radius: 7px; font-weight: 600; cursor: pointer;" />
                                    </asp:Panel>
                                </div>
                                <div style="display: flex; flex-direction: column;">
                                    <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Member Name</label>
                                    <asp:TextBox ID="MemberNameLHR" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #7a7a7a; background: #f5f0e8; width: 100%;" placeholder="Member Name" ReadOnly="true" />
                                    <asp:HiddenField ID="hfMemberNo" runat="server" />
                                </div>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>

                <%-- Guest Fields --%>
                <div id="divGuestFields" runat="server">
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 12px;">
                        <div style="display: flex; flex-direction: column;">
                            <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Guest Name <span style="color: #c62828;">*</span></label>
                            <asp:TextBox ID="txtGuestName" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; width: 100%;" placeholder="Full name of guest"></asp:TextBox>
                        </div>
                        <div style="display: flex; flex-direction: column;">
                            <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Address</label>
                            <asp:TextBox ID="txtAddress" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; width: 100%;" placeholder="Full address"></asp:TextBox>
                        </div>
                    </div>
                </div>

                <%-- Club Fields (Under Guest Name) --%>
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 12px;">
                    <div style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Club Name</label>
                        <asp:DropDownList ID="ddlClubName" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; width: 100%;"></asp:DropDownList>
                    </div>
                    <div id="divClubMemberName" runat="server" style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Club Member Name</label>
                        <asp:TextBox ID="txtClubMemberName" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; width: 100%;" placeholder="Club Member Name"></asp:TextBox>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 12px;">
                    <div style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Mobile #</label>
                        <div style="position: relative; display: flex; align-items: center;">
                            <i class="fas fa-mobile-alt" style="position: absolute; left: 10px; color: #7a7a7a; font-size: .85rem; z-index: 1;"></i>
                            <asp:TextBox ID="txtMobile" runat="server" style="padding: 8px 11px 8px 30px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; width: 100%;" placeholder="03xx-xxxxxxx"></asp:TextBox>
                        </div>
                    </div>
                    <div style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">NIC #</label>
                        <asp:TextBox ID="txtNIC" runat="server" MaxLength="13" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; width: 100%;" placeholder="xxxxx-xxxxxxx-x"></asp:TextBox>
                    </div>
                </div>

                <%-- PASSPORT DETAILS --%>
                <div style="font-size: .71rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #8B5E3C; margin-top:15px; margin-bottom:12px;"> Passport Details (For Foreigners)</div>
                <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 12px;">
                    <div style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Passport #</label>
                        <asp:TextBox ID="txtPassport" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; width: 100%;" placeholder="Passport Number"></asp:TextBox>
                    </div>
                    <div style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Issue Date</label>
                        <asp:TextBox ID="txtPassportIssue" runat="server" TextMode="Date" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; width: 100%;"></asp:TextBox>
                    </div>
                    <div style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Expiry Date</label>
                        <asp:TextBox ID="txtPassportExpiry" runat="server" TextMode="Date" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; width: 100%;"></asp:TextBox>
                    </div>
                </div>

                <%-- HIDDEN FIELDS --%>
                <asp:TextBox ID="txtPhone" runat="server" style="display:none;"></asp:TextBox>

                <%-- NEW: GUEST COUNTS --%>
                <div style="font-size: .71rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #8B5E3C; margin-top:15px; margin-bottom:12px;"> Guest Counts</div>
                <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 12px;">
                    <div style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Men</label>
                        <asp:TextBox ID="txtMen" runat="server" TextMode="Number" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; width: 100%;" Text="1"></asp:TextBox>
                    </div>
                    <div style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Women</label>
                        <asp:TextBox ID="txtWomen" runat="server" TextMode="Number" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; width: 100%;" Text="0"></asp:TextBox>
                    </div>
                    <div style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Child</label>
                        <asp:TextBox ID="txtChild" runat="server" TextMode="Number" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; width: 100%;" Text="0"></asp:TextBox>
                    </div>
                </div>

            </div>

            <%-- CARD 4: PAYMENT --%>
            <div class="form-card" style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 20px 22px; margin-bottom: 16px; box-shadow: 0 2px 10px rgba(0,0,0,0.06); position: relative;">
                <div style="font-size: .71rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 15px; padding-bottom: 8px; border-bottom: 1px solid #e0d5c5;"> Payment & Remarks</div>
                <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 12px;">
                    <div style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Advance (Rs)</label>
                        <div style="position: relative; display: flex; align-items: center;">
                            <i class="fas fa-rupee-sign" style="position: absolute; left: 10px; color: #7a7a7a; font-size: .85rem; z-index: 1;"></i>
                            <asp:TextBox ID="txtPayment" runat="server" style="padding: 8px 11px 8px 30px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; width: 100%;" placeholder="0.00"></asp:TextBox>
                        </div>
                    </div>
                    <div style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Receipt #</label>
                        <asp:TextBox ID="TextBox1" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #7a7a7a; background: #f5f0e8; width: 100%;" ReadOnly="true" placeholder="After Save"></asp:TextBox>
                    </div>
                    <div style="display: flex; flex-direction: column;">
                        <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;">Remarks</label>
                        <asp:TextBox ID="txtRemarks" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; width: 100%;" placeholder="Optional notes..."></asp:TextBox>
                    </div>
                </div>
            </div>

            <%-- ACTION BUTTONS --%>
            <div style="background: #faf7f2; border: 1px solid #e0d5c5; border-radius: 8px; padding: 13px 18px; display: flex; gap: 10px; flex-wrap: wrap;">
                <asp:Button ID="btnSave" runat="server" Text=" Save Reservation" OnClick="btnSave_Click" 
                    style="background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: #fff; border:none; padding: 9px 22px; border-radius: 7px; font-size: .87rem; font-weight: 600; cursor: pointer; transition: transform .15s;" CssClass="btn-action" />
                <asp:Button ID="btnAddNew" runat="server" Text=" Reset Form" OnClick="btnAddNew_Click" 
                    style="background: #5a6268; color: #fff; border:none; padding: 9px 22px; border-radius: 7px; font-size: .87rem; font-weight: 600; cursor: pointer; transition: transform .15s;" CssClass="btn-action" />
                <button type="button" style="background: #5a6268; color: #fff; border:none; padding: 9px 22px; border-radius: 7px; font-size: .87rem; font-weight: 600; cursor: pointer; margin-left: auto;" onclick="toggleGrid()" class="btn-action"> Toggle History</button>
            </div>

        </div>

        <%-- RIGHT PANEL --%>
        <div class="panel-right" style="flex:0 0 32%; max-width:32%; position:sticky; top:8px;">
    <div style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:20px 22px; margin-bottom:16px; box-shadow:0 2px 10px rgba(0,0,0,0.06); position:relative;">
        
        <%-- Gold top bar --%>
        <div style="position:absolute; top:0; left:0; right:0; height:4px; background:linear-gradient(90deg,#C9A84C,#8B5E3C); border-radius:10px 10px 0 0;"></div>
        
        <div style="font-size:.71rem; font-weight:700; letter-spacing:2px; text-transform:uppercase; color:#8B5E3C; margin-bottom:15px; padding-bottom:8px; border-bottom:1px solid #e0d5c5;">
            📋 Reservation History
        </div>

        <%-- Search Box --%>
        <div style="display:flex; gap:8px; margin-bottom:12px;">
            <asp:TextBox ID="txtSearchMember" runat="server"
                placeholder="Search by Member, Mobile or Name..."
                style="flex:1; padding:6px 10px; border:1.5px solid #e0d5c5; border-radius:6px; font-size:.8rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif;" />
            <asp:Button ID="btnSearchHistory" runat="server" Text="Search" OnClick="btnSearchHistory_Click"
                style="background:linear-gradient(135deg,#1565C0,#0d47a1); color:#fff; border:none; padding:6px 12px; border-radius:6px; font-size:.8rem; font-weight:600; cursor:pointer;" />
            <asp:Button ID="btnClearHistory" runat="server" Text="Clear" OnClick="btnClearHistory_Click"
                style="background:#f1f5f9; color:#334155; border:1px solid #e0d5c5; padding:6px 12px; border-radius:6px; font-size:.8rem; cursor:pointer;" />
        </div>

        <%-- Grid Container --%>
        <div style="overflow-x:auto; max-height:calc(100vh - 280px); min-height:260px; border-radius:7px; border:1px solid #e0d5c5;">
            <asp:GridView ID="gvStatus" runat="server"
                AutoGenerateColumns="False"
                GridLines="None"
                OnRowCommand="gvStatus_RowCommand"
                style="width:100%; border-collapse:collapse; font-size:0.78rem; background:#fff;"
                HeaderStyle-BackColor="#1A1A2E"
                HeaderStyle-ForeColor="#C9A84C"
                HeaderStyle-Font-Bold="True"
                HeaderStyle-Font-Size="X-Small"
                RowStyle-BackColor="#FFFFFF"
                RowStyle-ForeColor="#1e293b"
                AlternatingRowStyle-BackColor="#F8F9FA"
                AlternatingRowStyle-ForeColor="#1e293b">

                <Columns>

                    <%-- Edit --%>
                    <asp:TemplateField>
                        <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                        <HeaderTemplate>
                            <span style="display:block; padding:10px 8px;"></span>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding:10px 8px;">
                                <asp:LinkButton ID="btnEdit" runat="server"
                                    CommandName="EditRes"
                                    CommandArgument='<%# Eval("GroupResNo") %>'
                                    style="color:#1565C0; font-size:.75rem; font-weight:600; text-decoration:none; white-space:nowrap;">
                                    <i class="fas fa-edit"></i> Edit
                                </asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- Receipt No --%>
                    <asp:TemplateField>
                        <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                        <HeaderTemplate>
                            <span style="display:block; padding:10px 8px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Rec #</span>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding:10px 8px; font-family:'Courier New',monospace; font-weight:600; color:#1e293b; font-size:0.78rem;">
                                <%# Eval("ReceiptNo") %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- Guest --%>
                    <asp:TemplateField>
                        <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                        <HeaderTemplate>
                            <span style="display:block; padding:10px 8px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Guest</span>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding:10px 8px; color:#1e293b; font-size:0.78rem;"><%# Eval("GuestName") %></div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- Club Member Name --%>
                    <asp:TemplateField>
                        <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                        <HeaderTemplate>
                            <span style="display:block; padding:10px 8px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Club Member</span>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding:10px 8px; color:#1e293b; font-size:0.78rem;"><%# Eval("ClubMemberName") %></div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- Intro Card No --%>
                    <asp:TemplateField>
                        <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                        <HeaderTemplate>
                            <span style="display:block; padding:10px 8px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Intro #</span>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding:10px 8px; font-family:'Courier New',monospace; color:#1e293b; font-size:0.78rem;">
                                <%# Eval("IntroCardNo") %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- Club --%>
                    <asp:TemplateField>
                        <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                        <HeaderTemplate>
                            <span style="display:block; padding:10px 8px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Club</span>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding:10px 8px; color:#1e293b; font-size:0.78rem;"><%# Eval("Club") %></div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- Guest Of --%>
                    <asp:TemplateField>
                        <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                        <HeaderTemplate>
                            <span style="display:block; padding:10px 8px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Guest Of</span>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding:10px 8px; color:#1e293b; font-size:0.78rem;"><%# Eval("GuestOf") %></div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- Check-In --%>
                    <asp:TemplateField>
                        <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                        <HeaderTemplate>
                            <span style="display:block; padding:10px 8px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">In</span>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding:10px 8px; color:#1e293b; font-size:0.78rem;">
                                <%# (Eval("FromDate") != DBNull.Value && Eval("FromDate") != null) ? Convert.ToDateTime(Eval("FromDate")).ToString("dd/MM/yy") : "-" %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- Check-Out --%>
                    <asp:TemplateField>
                        <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                        <HeaderTemplate>
                            <span style="display:block; padding:10px 8px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Out</span>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding:10px 8px; color:#1e293b; font-size:0.78rem;">
                                <%# (Eval("ToDate") != DBNull.Value && Eval("ToDate") != null) ? Convert.ToDateTime(Eval("ToDate")).ToString("dd/MM/yy") : "-" %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- Rooms --%>
                    <asp:TemplateField>
                        <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                        <HeaderTemplate>
                            <span style="display:block; padding:10px 8px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Rms</span>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding:10px 8px; text-align:center; color:#1e293b; font-size:0.78rem;"><%# Eval("NoOfRooms") %></div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- Advance --%>
                    <asp:TemplateField>
                        <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                        <HeaderTemplate>
                            <span style="display:block; padding:10px 8px; text-align:right; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Advance</span>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding:10px 8px; text-align:right; font-weight:700; color:#C9A84C; font-size:0.78rem;">
                                <%# (Eval("AdvancePayment") != DBNull.Value && Eval("AdvancePayment") != null) ? Convert.ToDecimal(Eval("AdvancePayment")).ToString("N0") : "0" %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- Status --%>
                    <asp:TemplateField>
                        <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                        <HeaderTemplate>
                            <span style="display:block; padding:10px 8px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.7rem; white-space:nowrap;">Status</span>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding:10px 8px; text-align:center;">
                                <span style='<%# "padding:2px 8px; border-radius:10px; font-size:.7rem; font-weight:700; white-space:nowrap; " + GetStatusStyle(Eval("Status") != null ? Eval("Status").ToString() : "") %>'>
                                    <%# Eval("Status") != null ? Eval("Status").ToString().ToLower() : "-" %>
                                </span>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                </Columns>

                <EmptyDataTemplate>
                    <div style="padding:30px; text-align:center; color:#7a7a7a; background:#fff; font-size:0.85rem;">
                        <i class="fas fa-history" style="font-size:2rem; color:#e0d5c5; margin-bottom:10px; display:block;"></i>
                        No reservations found.
                    </div>
                </EmptyDataTemplate>

            </asp:GridView>
        </div>
    </div>
</div>

    </div>
</div>

<script type="text/javascript">
    function toggleGrid() {
        var panel = document.querySelector('.panel-right');
        var left = document.querySelector('.panel-left');
        if (panel.style.display === 'none') {
            panel.style.display = '';
            left.style.flex = '0 0 68%';
            left.style.maxWidth = '68%';
        } else {
            panel.style.display = 'none';
            left.style.flex = '0 0 100%';
            left.style.maxWidth = '100%';
        }
    }

    document.addEventListener('DOMContentLoaded', function () {
        var txtPayment = document.getElementById('<%= txtPayment.ClientID %>');
        var ddlStatus = document.getElementById('<%= ddlStatus.ClientID %>');

        if (txtPayment && ddlStatus) {
            txtPayment.addEventListener('input', function () {
                var payment = parseFloat(txtPayment.value) || 0;
                if (payment > 0) {
                    if (ddlStatus.value !== 'Confirmed') {
                        ddlStatus.value = 'Confirmed';
                    }
                }
            });
        }
    });
</script>

</asp:Content>
