<%@ Page Title="Guest Room Dashboard" Language="C#" MasterPageFile="SiteGuestroom.master" AutoEventWireup="true" CodeFile="Dashboard.aspx.cs" Inherits="GuestRoomApp.GuestRoomM.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    /* Only hover/transition effects that require pseudo-elements */
    .dash-card:hover { transform:translateY(-4px); box-shadow:0 12px 28px rgba(0,0,0,0.12) !important; }
    .dash-card:hover .card-arrow { opacity:1; }
    input[type="date"]:focus { border-color:#C9A84C !important; outline:none; box-shadow:0 0 0 3px rgba(201,168,76,0.15) !important; }
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="PageTitle" runat="server">Dashboard</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
<div style="padding:20px; background:#F7F3EE; min-height:100vh; font-family:'Segoe UI',sans-serif;">

    <asp:UpdatePanel ID="upDashboard" runat="server">
        <Triggers>
        <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
    </Triggers>

        <ContentTemplate>
            
            <%-- PAGE HEADER --%>
            <div style="background:linear-gradient(135deg,#1A1A2E,#2d2d5e); color:#fff; padding:16px 26px; border-radius:10px; margin-bottom:20px; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:12px; box-shadow:0 4px 15px rgba(0,0,0,0.2);">
                <div>
                    <h3 style="margin:0; font-size:1.35rem; letter-spacing:1px;">
                        <i class="fas fa-calendar-alt" style="color:#C9A84C; margin-right:8px;"></i> Dashboard Overview
                    </h3>
                    <div style="font-size:.77rem; color:#E8D5A3; margin-top:3px;">Guest Room Management  Live Status</div>
                </div>
                <%-- Actions & Filters --%>
                <div style="display:flex; align-items:center; gap:15px; flex-wrap:wrap;">
                    <%-- New Reservation Button --%>
                    <a href="RoomReservation.aspx" style="text-decoration:none; background:#2e7d32; color:#fff; padding:9px 16px; border-radius:7px; font-size:.87rem; font-weight:600; display:flex; align-items:center; gap:6px; box-shadow:0 2px 5px rgba(0,0,0,0.15); transition:all 0.2s;">
                        <i class="fas fa-plus"></i> New Reservation
                    </a>
                     <a href="TodayConfirmations.aspx" style="text-decoration:none; background:#2e7d32; color:#fff; padding:9px 16px; border-radius:7px; font-size:.87rem; font-weight:600; display:flex; align-items:center; gap:6px; box-shadow:0 2px 5px rgba(0,0,0,0.15); transition:all 0.2s;">
                         Cancel/Confirm 
                    </a>
                     <a href="RoomavailabilityCalendar.aspx" style="text-decoration:none; background:#2e7d32; color:#fff; padding:9px 16px; border-radius:7px; font-size:.87rem; font-weight:600; display:flex; align-items:center; gap:6px; box-shadow:0 2px 5px rgba(0,0,0,0.15); transition:all 0.2s;">
     Room InHand
</a>

                    <%-- Date Filter --%>
                    <div style="display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.08); padding:10px 16px; border-radius:8px; border:1px solid rgba(255,255,255,0.15); flex-wrap:wrap;">
                    <asp:TextBox ID="txtFromDate" runat="server" TextMode="Date"
    style="padding:7px 11px;
           border:1px solid rgba(255,255,255,0.25);
           border-radius:7px;
           background:rgba(255,255,255,0.1);
           color:#fff !important;
           font-size:.87rem;
           font-family:'Segoe UI',sans-serif;" />

<asp:TextBox ID="txtToDate" runat="server" TextMode="Date"
    style="padding:7px 11px;
           border:1px solid rgba(255,255,255,0.25);
           border-radius:7px;
           background:rgba(255,255,255,0.1);
           color:#fff !important;
           font-size:.87rem;
           font-family:'Segoe UI',sans-serif;" />
                    <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click" CausesValidation="false"
                        style="background:linear-gradient(135deg,#C9A84C,#8B5E3C); color:#fff; border:none; padding:8px 20px; border-radius:7px; font-size:.87rem; font-weight:600; cursor:pointer; letter-spacing:.3px;" />
                    </div>
                </div>
            </div>

            <%-- KPI CARDS --%>
            <div style="display:grid; grid-template-columns:repeat(auto-fit,minmax(200px,1fr)); gap:16px; margin-bottom:24px;">

                <%-- Pending --%>
                <asp:LinkButton ID="lnkPending" runat="server" OnClick="Card_Click" CommandArgument="Pending"
                    style="text-decoration:none; display:flex; align-items:center; gap:14px; background:#fff; border:1px solid #e0d5c5; border-left:5px solid #e65100; border-radius:10px; padding:18px 20px; box-shadow:0 2px 8px rgba(0,0,0,0.05); transition:all .25s; cursor:pointer;" CssClass="dash-card">
                    <div style="width:48px; height:48px; border-radius:10px; background:#fff3e0; color:#e65100; display:flex; align-items:center; justify-content:center; font-size:1.3rem; flex-shrink:0;">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div>
                        <div style="font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:1px; color:#7a7a7a;">Pending</div>
                        <div style="font-size:1.7rem; font-weight:800; color:#1A1A2E; line-height:1.1;">
                            <asp:Label ID="lblPendingCount" runat="server" Text="0" />
                        </div>
                        <div style="font-size:.7rem; color:#7a7a7a;">reservations</div>
                    </div>
                </asp:LinkButton>

                <%-- Confirmed --%>
                <asp:LinkButton ID="lnkConfirmed" runat="server" OnClick="Card_Click" CommandArgument="Confirmed"
                    style="text-decoration:none; display:flex; align-items:center; gap:14px; background:#fff; border:1px solid #e0d5c5; border-left:5px solid #1565C0; border-radius:10px; padding:18px 20px; box-shadow:0 2px 8px rgba(0,0,0,0.05); transition:all .25s; cursor:pointer;" CssClass="dash-card">
                    <div style="width:48px; height:48px; border-radius:10px; background:#e3f2fd; color:#1565C0; display:flex; align-items:center; justify-content:center; font-size:1.3rem; flex-shrink:0;">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <div>
                        <div style="font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:1px; color:#7a7a7a;">Confirmed</div>
                        <div style="font-size:1.7rem; font-weight:800; color:#1A1A2E; line-height:1.1;">
                            <asp:Label ID="lblConfirmedCount" runat="server" Text="0" />
                        </div>
                        <div style="font-size:.7rem; color:#7a7a7a;">reservations</div>
                    </div>
                </asp:LinkButton>

                <%-- Cancelled --%>
                <asp:LinkButton ID="lnkCancelled" runat="server" OnClick="Card_Click" CommandArgument="Cancelled"
                    style="text-decoration:none; display:flex; align-items:center; gap:14px; background:#fff; border:1px solid #e0d5c5; border-left:5px solid #c62828; border-radius:10px; padding:18px 20px; box-shadow:0 2px 8px rgba(0,0,0,0.05); transition:all .25s; cursor:pointer;" CssClass="dash-card">
                    <div style="width:48px; height:48px; border-radius:10px; background:#fce4ec; color:#c62828; display:flex; align-items:center; justify-content:center; font-size:1.3rem; flex-shrink:0;">
                        <i class="fas fa-times-circle"></i>
                    </div>
                    <div>
                        <div style="font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:1px; color:#7a7a7a;">Cancelled</div>
                        <div style="font-size:1.7rem; font-weight:800; color:#1A1A2E; line-height:1.1;">
                            <asp:Label ID="lblCancelledCount" runat="server" Text="0" />
                        </div>
                        <div style="font-size:.7rem; color:#7a7a7a;">reservations</div>
                    </div>
                </asp:LinkButton>

                <%-- Occupied --%>
                <asp:LinkButton ID="lnkOccupied" runat="server" OnClick="Card_Click" CommandArgument="Occupied"
                    style="text-decoration:none; display:flex; align-items:center; gap:14px; background:#fff; border:1px solid #e0d5c5; border-left:5px solid #1A1A2E; border-radius:10px; padding:18px 20px; box-shadow:0 2px 8px rgba(0,0,0,0.05); transition:all .25s; cursor:pointer;" CssClass="dash-card">
                    <div style="width:48px; height:48px; border-radius:10px; background:#e8eaf6; color:#1A1A2E; display:flex; align-items:center; justify-content:center; font-size:1.3rem; flex-shrink:0;">
                        <i class="fas fa-bed"></i>
                    </div>
                    <div>
                        <div style="font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:1px; color:#7a7a7a;">Occupied History</div>
                        <div style="font-size:1.7rem; font-weight:800; color:#1A1A2E; line-height:1.1;">
                            <asp:Label ID="lblOccupiedCount" runat="server" Text="0" />
                        </div>
                        <div style="font-size:.7rem; color:#7a7a7a;">rooms</div>
                    </div>
                </asp:LinkButton>

                <%-- Completed --%>
                <asp:LinkButton ID="lnkCompleted" runat="server" OnClick="Card_Click" CommandArgument="Completed"
                    style="text-decoration:none; display:flex; align-items:center; gap:14px; background:#fff; border:1px solid #e0d5c5; border-left:5px solid #2e7d32; border-radius:10px; padding:18px 20px; box-shadow:0 2px 8px rgba(0,0,0,0.05); transition:all .25s; cursor:pointer;" CssClass="dash-card">
                    <div style="width:48px; height:48px; border-radius:10px; background:#e8f5e9; color:#2e7d32; display:flex; align-items:center; justify-content:center; font-size:1.3rem; flex-shrink:0;">
                        <i class="fas fa-sign-out-alt"></i>
                    </div>
                    <div>
                        <div style="font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:1px; color:#7a7a7a;">Completed/Not Paid</div>
                        <div style="font-size:1.7rem; font-weight:800; color:#1A1A2E; line-height:1.1;">
                            <asp:Label ID="lblCompletedCount" runat="server" Text="0" />
                        </div>
                        <div style="font-size:.7rem; color:#7a7a7a;">check-outs</div>
                    </div>
                </asp:LinkButton>

                <%-- Billing Done --%>
                <asp:LinkButton ID="lnkBillingDone" runat="server" OnClick="Card_Click" CommandArgument="BillingDone"
                    style="text-decoration:none; display:flex; align-items:center; gap:14px; background:#fff; border:1px solid #e0d5c5; border-left:5px solid #C9A84C; border-radius:10px; padding:18px 20px; box-shadow:0 2px 8px rgba(0,0,0,0.05); transition:all .25s; cursor:pointer;" CssClass="dash-card">
                    <div style="width:48px; height:48px; border-radius:10px; background:#fffde7; color:#C9A84C; display:flex; align-items:center; justify-content:center; font-size:1.3rem; flex-shrink:0;">
                        <i class="fas fa-file-invoice-dollar"></i>
                    </div>
                    <div>
                        <div style="font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:1px; color:#7a7a7a;">Billing Done</div>
                        <div style="font-size:1.7rem; font-weight:800; color:#1A1A2E; line-height:1.1;">
                            <asp:Label ID="lblBillingDoneCount" runat="server" Text="0" />
                        </div>
                        <div style="font-size:.7rem; color:#7a7a7a;">settled bills</div>
                    </div>
                </asp:LinkButton>

                <%-- Today's Occupied --%>
                <asp:LinkButton ID="lnkTodayOccupied" runat="server" OnClick="Card_Click" CommandArgument="TodayOccupied"
                    style="text-decoration:none; display:flex; align-items:center; gap:14px; background:#fff; border:1px solid #e0d5c5; border-left:5px solid #3b82f6; border-radius:10px; padding:18px 20px; box-shadow:0 2px 8px rgba(0,0,0,0.05); transition:all .25s; cursor:pointer;" CssClass="dash-card">
                    <div style="width:48px; height:48px; border-radius:10px; background:#eff6ff; color:#3b82f6; display:flex; align-items:center; justify-content:center; font-size:1.3rem; flex-shrink:0;">
                        <i class="fas fa-door-open"></i>
                    </div>
                    <div>
                        <div style="font-size:.72rem; font-weight:700; text-transform:uppercase; letter-spacing:1px; color:#7a7a7a;">Today Occupied</div>
                        <div style="font-size:1.7rem; font-weight:800; color:#1A1A2E; line-height:1.1;">
                            <asp:Label ID="lblTodayOccupiedCount" runat="server" Text="0" />
                        </div>
                        <div style="font-size:.7rem; color:#7a7a7a;">rooms in-house now</div>
                    </div>
                </asp:LinkButton>

            </div>
            <%-- DETAILS GRID PANEL --%>
<asp:Panel ID="pnlDetails" runat="server" Visible="false">
    <div style="background:#fff; border:1px solid #e0d5c5; border-radius:10px; box-shadow:0 2px 10px rgba(0,0,0,0.06); overflow:hidden;">

        <%-- Panel Header --%>
        <div style="background:linear-gradient(135deg,#1A1A2E,#2d2d5e); padding:14px 22px; display:flex; align-items:center; justify-content:space-between;">
            <h3 style="margin:0; font-size:1rem; font-weight:700; color:#fff; display:flex; align-items:center; gap:8px;">
                <i class="fas fa-list-ul" style="color:#C9A84C;"></i>
                <asp:Literal ID="litGridTitle" runat="server">Details</asp:Literal>
            </h3>
        </div>

        <%-- Grid --%>
        <div style="padding:12px; overflow-x:auto;">
            <asp:GridView ID="gvDetails" runat="server"
                AutoGenerateColumns="False"
                GridLines="None"
                OnRowDataBound="gvDetails_RowDataBound"
                style="width:100%; border-collapse:collapse; font-size:0.88rem; background:#fff;"
                HeaderStyle-BackColor="#1A1A2E"
                HeaderStyle-ForeColor="#C9A84C"
                HeaderStyle-Font-Bold="True"
                HeaderStyle-Font-Size="X-Small"
                RowStyle-BackColor="#FFFFFF"
                RowStyle-ForeColor="#1e293b"
                AlternatingRowStyle-BackColor="#F8F9FA"
                AlternatingRowStyle-ForeColor="#1e293b">

                <Columns>

                    <%-- Res. No --%>
                    <asp:TemplateField>
                        <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                        <HeaderTemplate>
                            <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Res. No</span>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding:12px 15px; font-weight:700; font-family:'Courier New',monospace; color:#1e293b; font-size:0.88rem;">
                                <%# Eval("ReservationNo") %>
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

                    <%-- Mobile No --%>
                    <asp:TemplateField>
                        <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                        <HeaderTemplate>
                            <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Mobile No</span>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding:12px 15px; color:#1e293b; font-size:0.88rem;">
                                <%# Eval("MobileNo") %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- Room No --%>
                    <asp:TemplateField>
                        <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                        <HeaderTemplate>
                            <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Room No</span>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div style="padding:12px 15px; font-weight:600; color:#1e293b; font-size:0.88rem;">
                                <%# Eval("RoomNo") %>
                            </div>
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
                                <%# Convert.ToDateTime(Eval("CheckInDate")).ToString("dd-MMM-yyyy") %>
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
                                <%# Convert.ToDateTime(Eval("CheckOutDate")).ToString("dd-MMM-yyyy") %>
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
                                <asp:Label ID="lblStatus" runat="server" Text='<%# Eval("Status") %>' />
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                </Columns>

                <EmptyDataTemplate>
                    <div style="padding:40px; text-align:center; color:#7a7a7a; background:#fff;">
                        <i class="fas fa-search" style="font-size:2.5rem; color:#e0d5c5; margin-bottom:12px; display:block;"></i>
                        <p style="margin:0; font-size:0.88rem;">No records found.</p>
                    </div>
                </EmptyDataTemplate>

            </asp:GridView>
        </div>
    </div>
</asp:Panel>

            <%-- ROOM STATUS GRID PANEL --%>
            <div style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:20px 22px; margin-bottom:24px; box-shadow:0 2px 10px rgba(0,0,0,0.06); position:relative;">
                <div style="font-size:1rem; font-weight:700; color:#1A1A2E; margin-bottom:14px; padding-bottom:8px; border-bottom:1px solid #e0d5c5; display:flex; align-items:center; gap:8px;">
                    <i class="fas fa-th-large" style="color:#C9A84C;"></i> Live Room Status
                </div>

                <div class="room-grid" style="display:grid; grid-template-columns:repeat(auto-fill,minmax(95px,1fr)); gap:10px; margin:16px 0; max-height:400px; overflow-y:auto; padding:14px; border:1px solid #e0d5c5; border-radius:8px; background:#F7F3EE;">
                    <asp:Repeater ID="rptRooms" runat="server">
                        <ItemTemplate>
                            <div class="room-card"
                                 style='padding:12px 8px; border-radius:8px; text-align:center; transition:all .2s; border:2px solid transparent; 
                                 <%# Convert.ToString(Eval("Status")) == "Available" ? "background:#e8f5e9; border-color:#a5d6a7; color:#1b5e20;" : 
                                    (Convert.ToString(Eval("Status")) == "Occupied" ? "background:#fce4ec; border-color:#ef9a9a; color:#b71c1c;" : 
                                    (Convert.ToString(Eval("Status")) == "Dirty" ? "background:#fff3e0; border-color:#ffcc80; color:#e65100;" : "background:#eeeeee; border-color:#bdbdbd; color:#616161;")) %>'>
                                <span style="font-size:1.05rem; font-weight:800; display:block;"><%# Eval("RoomNo") %></span>
                                <span style="font-size:.68rem; margin-top:3px; display:block; opacity:.85;"><%# Eval("RoomType") %></span>
                                <span style='font-size:.6rem; margin-top:5px; display:inline-block; padding:2px 6px; border-radius:4px; font-weight:bold; text-transform:uppercase; 
                                 <%# Convert.ToString(Eval("Status")) == "Available" ? "background:#c8e6c9; color:#1b5e20;" : 
                                    (Convert.ToString(Eval("Status")) == "Occupied" ? "background:#ffcdd2; color:#b71c1c;" : 
                                    (Convert.ToString(Eval("Status")) == "Dirty" ? "background:#ffe0b2; color:#e65100;" : "background:#e0e0e0; color:#616161;")) %>'>
                                    <%# Convert.ToString(Eval("Status")) == "Available" ? "Vacant" : Eval("Status") %>
                                </span>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                
                <div style="display:flex; gap:16px; margin-top:12px; font-size:0.8rem; font-weight:600; color:#1A1A2E; flex-wrap:wrap;">
                    <div style="display:flex; align-items:center; gap:6px;"><span style="width:12px; height:12px; background:#a5d6a7; border-radius:3px; display:inline-block;"></span> Vacant (Available)</div>
                    <div style="display:flex; align-items:center; gap:6px;"><span style="width:12px; height:12px; background:#ef9a9a; border-radius:3px; display:inline-block;"></span> Occupied</div>
                    <div style="display:flex; align-items:center; gap:6px;"><span style="width:12px; height:12px; background:#ffcc80; border-radius:3px; display:inline-block;"></span> Dirty</div>
                    <div style="display:flex; align-items:center; gap:6px;"><span style="width:12px; height:12px; background:#bdbdbd; border-radius:3px; display:inline-block;"></span> Other</div>
                </div>
            </div>

            

        </ContentTemplate>
    </asp:UpdatePanel>
</div>
</asp:Content>


