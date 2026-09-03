<%@ Page Title="Room Reservation Status" Language="C#" MasterPageFile="SiteGuestroom.master" AutoEventWireup="true"
    CodeFile="RoomReservationStatus.aspx.cs" Inherits="GuestRoomApp.GuestRoomM.RoomReservationStatus" %>

    <asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
        <style>
            /* Rules that require pseudo-elements or media queries */
            .kpi-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 3px;
            }

            .form-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 4px;
                background: linear-gradient(90deg, #C9A84C, #8B5E3C);
                border-radius: 10px 10px 0 0;
            }

            .form-control:focus {
                border-color: #C9A84C !important;
                outline: none;
                box-shadow: 0 0 0 3px rgba(201, 168, 76, 0.15);
            }

            .btn-gold:hover {
                transform: translateY(-1px);
                box-shadow: 0 4px 12px rgba(201, 168, 76, 0.4);
            }

            /* Data Table Styling */
            .data-table {
                width: 100%;
                border-collapse: collapse;
                background: #fff;
                font-size: 0.88rem;
            }

            .data-table thead th {
                position: sticky;
                top: 0;
                z-index: 5;
                background: #1A1A2E;
                color: #fff;
                font-weight: 700;
                text-transform: uppercase;
                font-size: 0.72rem;
                letter-spacing: 0.5px;
                padding: 12px 15px;
                border-bottom: 2px solid #e2e8f0;
                text-align: left;
                white-space: nowrap;
            }

            .data-table td {
                padding: 12px 15px;
                border-bottom: 1px solid #f1f5f9;
                color: #1e293b;
            }

            .data-table tr:hover {
                background: #f8fafc;
            }

            /* Pager Styling */
            .res-pager span {
                background: #1A1A2E !important;
                border-color: #1A1A2E !important;
                color: #C9A84C !important;
                padding: 5px 12px;
                border-radius: 4px;
            }

            .res-pager a {
                padding: 5px 12px;
                border: 1px solid #e0d5c5;
                border-radius: 4px;
                color: #1A1A2E;
                text-decoration: none;
                margin: 0 2px;
            }

            .res-pager a:hover {
                background: #faf7f2 !important;
                border-color: #C9A84C !important;
                color: #8B5E3C !important;
            }

            @media(max-width:1400px) {
                .kpi-grid {
                    grid-template-columns: repeat(4, 1fr) !important;
                }
            }

            @media(max-width:1100px) {
                .kpi-grid {
                    grid-template-columns: repeat(3, 1fr) !important;
                }
            }

            @media(max-width:768px) {
                .kpi-grid {
                    grid-template-columns: 1fr 1fr !important;
                }

                .filter-row {
                    flex-direction: column !important;
                }
            }

            /* ── PRINT REPORT STYLES ── */
            #printReportPanel {
                display: none;
            }

            @media print {
                body * {
                    visibility: hidden !important;
                }

                #printReportPanel,
                #printReportPanel * {
                    visibility: visible !important;
                }

                #printReportPanel {
                    display: block !important;
                    position: absolute;
                    left: 0;
                    top: 0;
                    width: 100%;
                }

                .rpt-table {
                    width: 100%;
                    border-collapse: collapse;
                    font-size: 10pt;
                }

                .rpt-table th {
                    background: #1A1A2E !important;
                    color: #fff !important;
                    -webkit-print-color-adjust: exact;
                    print-color-adjust: exact;
                    padding: 7px 10px;
                    font-size: 8.5pt;
                }

                .rpt-table td {
                    padding: 6px 10px;
                    border-bottom: 1px solid #ddd;
                    font-size: 9pt;
                }

                .rpt-kpi-box {
                    border: 2px solid;
                    border-radius: 8px;
                    padding: 12px 18px;
                    text-align: center;
                    display: inline-block;
                    min-width: 130px;
                    margin: 4px;
                    -webkit-print-color-adjust: exact;
                    print-color-adjust: exact;
                }
            }
        </style>
    </asp:Content>

    <asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
        <div
            style="width: 100%; padding: 18px 22px; background: #F7F3EE; font-family: 'Segoe UI', sans-serif; min-height: 100vh;">

            <%-- PAGE HEADER --%>
                <div
                    style="background: linear-gradient(135deg, #1A1A2E 0%, #2d2d5e 100%); color: #fff; padding: 16px 26px; border-radius: 10px; margin-bottom: 18px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 4px 15px rgba(0,0,0,0.2);">
                    <div>
                        <h3 style="margin: 0; font-size: 1.35rem; letter-spacing: 1px;"><i class="fas fa-chart-line"
                                style="color:#C9A84C; margin-right:8px;"></i> Reservation Status</h3>
                        <div style="font-size: .77rem; color: #E8D5A3; margin-top: 3px; opacity: 0.9;">Guest Room
                            Management · Live Booking Overview</div>
                    </div>
                    <div>
                        <asp:Button ID="btnPrintReport" runat="server" Text=" Print Today's Report"
                            OnClick="btnPrintReport_Click"
                            style="background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: #fff; border: none; padding: 10px 22px; border-radius: 8px; font-size: .88rem; font-weight: 700; cursor: pointer; letter-spacing: .4px; box-shadow: 0 2px 8px rgba(0,0,0,0.25);" />
                    </div>
                </div>

                <%-- KPI CARDS --%>
                    <div class="kpi-grid"
                        style="display: grid; grid-template-columns: repeat(7, 1fr); gap: 12px; margin-bottom: 18px;">

                        <div class="kpi-card"
                            style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 16px 18px; display: flex; align-items: center; gap: 14px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); position: relative; overflow: hidden;">
                            <div style="width: 3px; position: absolute; top:0; left:0; bottom:0; background: #2e7d32;">
                            </div>
                            <div
                                style="width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; flex-shrink: 0; background: #e8f5e9; color: #2e7d32;">
                                <i class="fas fa-check-circle"></i>
                            </div>
                            <div>
                                <div
                                    style="font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: #7a7a7a;">
                                    confirmed</div>
                                <div style="font-size: 1.7rem; font-weight: 800; color: #1A1A2E; line-height: 1.1;">
                                    <asp:Label ID="lblConfirmedCount" runat="server" Text="0" />
                                </div>
                                <div style="font-size: .7rem; color: #7a7a7a; margin-top: 1px;">rooms</div>
                            </div>
                        </div>

                        <div class="kpi-card"
                            style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 16px 18px; display: flex; align-items: center; gap: 14px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); position: relative; overflow: hidden;">
                            <div style="width: 3px; position: absolute; top:0; left:0; bottom:0; background: #e65100;">
                            </div>
                            <div
                                style="width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; flex-shrink: 0; background: #fff3e0; color: #e65100;">
                                <i class="fas fa-clock"></i>
                            </div>
                            <div>
                                <div
                                    style="font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: #7a7a7a;">
                                    pending</div>
                                <div style="font-size: 1.7rem; font-weight: 800; color: #1A1A2E; line-height: 1.1;">
                                    <asp:Label ID="lblPendingCount" runat="server" Text="0" />
                                </div>
                                <div style="font-size: .7rem; color: #7a7a7a; margin-top: 1px;">rooms</div>
                            </div>
                        </div>

                        <div class="kpi-card"
                            style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 16px 18px; display: flex; align-items: center; gap: 14px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); position: relative; overflow: hidden;">
                            <div style="width: 3px; position: absolute; top:0; left:0; bottom:0; background: #c62828;">
                            </div>
                            <div
                                style="width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; flex-shrink: 0; background: #fce4ec; color: #c62828;">
                                <i class="fas fa-times-circle"></i>
                            </div>
                            <div>
                                <div
                                    style="font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: #7a7a7a;">
                                    cancelled</div>
                                <div style="font-size: 1.7rem; font-weight: 800; color: #1A1A2E; line-height: 1.1;">
                                    <asp:Label ID="lblCancelledCount" runat="server" Text="0" />
                                </div>
                                <div style="font-size: .7rem; color: #7a7a7a; margin-top: 1px;">rooms</div>
                            </div>
                        </div>

                        <div class="kpi-card"
                            style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 16px 18px; display: flex; align-items: center; gap: 14px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); position: relative; overflow: hidden;">
                            <div style="width: 3px; position: absolute; top:0; left:0; bottom:0; background: #1565C0;">
                            </div>
                            <div
                                style="width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; flex-shrink: 0; background: #e3f2fd; color: #1565C0;">
                                <i class="fas fa-door-open"></i>
                            </div>
                            <div>
                                <div
                                    style="font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: #7a7a7a;">
                                    occupied</div>
                                <div style="font-size: 1.7rem; font-weight: 800; color: #1A1A2E; line-height: 1.1;">
                                    <asp:Label ID="lblOccupiedCount" runat="server" Text="0" />
                                </div>
                                <div style="font-size: .7rem; color: #7a7a7a; margin-top: 1px;">rooms</div>
                            </div>
                        </div>

                        <div class="kpi-card"
                            style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 16px 18px; display: flex; align-items: center; gap: 14px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); position: relative; overflow: hidden;">
                            <div style="width: 3px; position: absolute; top:0; left:0; bottom:0; background: #607d8b;">
                            </div>
                            <div
                                style="width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; flex-shrink: 0; background: #eceff1; color: #607d8b;">
                                <i class="fas fa-flag-checkered"></i>
                            </div>
                            <div>
                                <div
                                    style="font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: #7a7a7a;">
                                    completed</div>
                                <div style="font-size: 1.7rem; font-weight: 800; color: #1A1A2E; line-height: 1.1;">
                                    <asp:Label ID="lblCompletedCount" runat="server" Text="0" />
                                </div>
                                <div style="font-size: .7rem; color: #7a7a7a; margin-top: 1px;">rooms</div>
                            </div>
                        </div>

                        <div class="kpi-card"
                            style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 16px 18px; display: flex; align-items: center; gap: 14px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); position: relative; overflow: hidden;">
                            <div style="width: 3px; position: absolute; top:0; left:0; bottom:0; background: #8B5E3C;">
                            </div>
                            <div
                                style="width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; flex-shrink: 0; background: #fdf6e3; color: #8B5E3C;">
                                <i class="fas fa-bed"></i>
                            </div>
                            <div>
                                <div
                                    style="font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: #7a7a7a;">
                                    Total Rooms</div>
                                <div style="font-size: 1.7rem; font-weight: 800; color: #1A1A2E; line-height: 1.1;">
                                    <asp:Label ID="lblTotalRooms" runat="server" Text="0" />
                                </div>
                                <div style="font-size: .7rem; color: #7a7a7a; margin-top: 1px;">in filtered view</div>
                            </div>
                        </div>

                        <div class="kpi-card"
                            style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 16px 18px; display: flex; align-items: center; gap: 14px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); position: relative; overflow: hidden;">
                            <div style="width: 3px; position: absolute; top:0; left:0; bottom:0; background: #C9A84C;">
                            </div>
                            <div
                                style="width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; flex-shrink: 0; background: #fcf8e8; color: #C9A84C;">
                                <i class="fas fa-hand-holding-usd"></i>
                            </div>
                            <div>
                                <div
                                    style="font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: #7a7a7a;">
                                    Total Advance</div>
                                <div style="font-size: 1.7rem; font-weight: 800; color: #1A1A2E; line-height: 1.1;">
                                    <asp:Label ID="lblTotalAdvance" runat="server" Text="0" />
                                </div>
                                <div style="font-size: .7rem; color: #7a7a7a; margin-top: 1px;">collected (Rs.)</div>
                            </div>
                        </div>

                    </div>

                    <%-- FILTER CARD --%>
                        <div class="form-card"
                            style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 18px 22px; margin-bottom: 16px; box-shadow: 0 2px 10px rgba(0,0,0,0.06); position: relative;">
                            <div
                                style="font-size: .71rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 14px; padding-bottom: 8px; border-bottom: 1px solid #e0d5c5;">
                                Filter Reservations</div>
                            <div class="filter-row"
                                style="display: flex; flex-wrap: wrap; align-items: flex-end; gap: 12px;">

                                <div style="display: flex; flex-direction: column; gap: 4px;">
                                    <label style="font-size: .81rem; font-weight: 600; color: #1A1A2E;">From
                                        Date</label>
                                    <asp:TextBox ID="txtFromDate" runat="server" TextMode="Date"
                                        style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; min-width:150px;" />
                                </div>

                                <div style="display: flex; flex-direction: column; gap: 4px;">
                                    <label style="font-size: .81rem; font-weight: 600; color: #1A1A2E;">To Date</label>
                                    <asp:TextBox ID="txtToDate" runat="server" TextMode="Date"
                                        style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; min-width:150px;" />
                                </div>

                                <div style="display: flex; flex-direction: column; gap: 4px;">
                                    <label style="font-size: .81rem; font-weight: 600; color: #1A1A2E;">Status</label>
                                    <asp:DropDownList ID="ddlStatusFilter" runat="server"
                                        style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; min-width:170px;">
                                        <asp:ListItem Text=" All Statuses " Value="All" />
                                        <asp:ListItem Text="Confirmed" Value="CONFIRMED" />
                                        <asp:ListItem Text="Pending" Value="PENDING" />
                                        <asp:ListItem Text="Cancelled" Value="CANCELLED" />
                                        <asp:ListItem Text="Occupied" Value="OCCUPIED" />
                                        <asp:ListItem Text="Completed" Value="COMPLETED" />
                                    </asp:DropDownList>
                                </div>

                                <div style="display: flex; flex-direction: column; gap: 4px; justify-content:flex-end;">
                                    <label style="font-size: .81rem; font-weight: 600; color: #1A1A2E;">&nbsp;</label>
                                    <asp:Button ID="btnCheck" runat="server" Text=" Apply Filter"
                                        OnClick="btnCheck_Click"
                                        style="background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: #fff; border: none; padding: 9px 22px; border-radius: 7px; font-size: .87rem; font-weight: 600; cursor: pointer; transition: transform .15s, box-shadow .15s; letter-spacing: .3px;" />
                                </div>

                            </div>
                        </div>

                        <%-- DATA GRID --%>
                            <div class="form-card"
                                style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 18px 22px; margin-bottom: 16px; box-shadow: 0 2px 10px rgba(0,0,0,0.06); position: relative;">

                                <div
                                    style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
                                    <div
                                        style="font-size: .72rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #8B5E3C;">
                                        Reservation Records</div>
                                    <div style="display: flex; gap: 8px; align-items: center;">
                                        <span
                                            style="padding: 4px 14px; border-radius: 20px; font-size: .75rem; font-weight: 700; background: #e3f2fd; color: #1565C0; border: 1px solid #90caf9;">
                                            Rooms:
                                            <asp:Label ID="lblTotalRoomsToolbar" runat="server" Text="0" />
                                        </span>
                                        <span
                                            style="padding: 4px 14px; border-radius: 20px; font-size: .75rem; font-weight: 700; background: #faf7f2; color: #7a7a7a; border: 1px solid #e0d5c5;">
                                            Records:
                                            <asp:Label ID="lblRecordCount" runat="server" Text="0" />
                                        </span>
                                    </div>
                                </div>

                                <div
                                    style="overflow-x: auto; overflow-y: auto; max-height: 480px; border-radius: 8px; border: 1px solid #e0d5c5;">
                                    <asp:GridView ID="gvStatus" runat="server"
    AutoGenerateColumns="False"
    GridLines="None"
    OnRowDataBound="gvStatus_RowDataBound"
    AllowPaging="True"
    PageSize="15"
    OnPageIndexChanging="gvStatus_PageIndexChanging"
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
        <div style="padding:40px 20px; text-align:center; color:#7a7a7a; font-size:.88rem; background:#fff;">
            <i class="fas fa-search" style="font-size:2rem; display:block; margin-bottom:8px; color:#ccc;"></i>
            No reservations found for the selected filters.
        </div>
    </EmptyDataTemplate>

    <Columns>

        <%-- Reservation No --%>
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

        <%-- Club Name --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Club Name</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; color:#1e293b; font-size:0.88rem;"><%# Eval("Club") %></div>
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

        <%-- Member # --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Member #</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; font-family:'Courier New',monospace; color:#1e293b; font-size:0.88rem;">
                    <%# Eval("MembershipNo") %>
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

        <%-- Nights --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Nights</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; text-align:center; color:#1e293b; font-size:0.88rem;"><%# Eval("Days") %></div>
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
                <span style="display:block; padding:12px 15px; text-align:right; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Advance (Rs.)</span>
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
                    <%# GetStatusBadge(Eval("Status").ToString()) %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- RFID Cards --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">RFID Card(s)</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; font-weight:700; font-family:'Courier New',monospace; color:#1e293b; font-size:0.88rem;">
                    <%# GetRFIDStatusList(Eval("ReservationNo").ToString()) %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

    </Columns>
</asp:GridView>
                                </div>

                                <div
                                    style="display: flex; justify-content: space-between; align-items: center; font-size: .76rem; color: #7a7a7a; padding: 10px 4px 0;">
                                    <span> Counts reflect the current date-range filter.</span>
                                    <span>
                                        Total rooms booked: <strong>
                                            <asp:Label ID="lblTotalRoomsFooter" runat="server" Text="0" />
                                        </strong>
                                    </span>
                                </div>

                            </div>

                            <%-- ════════ PRINT REPORT PANEL (hidden on screen, visible on print) ════════ --%>
                                <div id="printReportPanel">
                                    <table style="width:100%; margin-bottom:18px;">
                                        <tr>
                                            <td style="vertical-align:middle; width:120px;">
                                                <img src="images/lahore_gymkhana_logo1.png" alt="Lahore Gymkhana"
                                                    style="height:65px; width:auto;" />
                                            </td>
                                            <td style="vertical-align:top;">
                                                <div
                                                    style="font-size:15pt; font-weight:800; color:#1A1A2E; margin-bottom:2px;">
                                                    Lahore Gymkhana</div>
                                                <div style="font-size:11pt; font-weight:700; color:#8B5E3C;">Guest Room
                                                    Management System</div>
                                                <div style="font-size:10pt; color:#555;">Daily Reservation Status Report
                                                </div>
                                            </td>
                                            <td style="text-align:right; vertical-align:top;">
                                                <div style="font-size:10pt; color:#333;">Date: <strong>
                                                        <asp:Label ID="lblReportDate" runat="server" />
                                                    </strong></div>
                                                <div style="font-size:9pt; color:#777;">Printed on:
                                                    <asp:Label ID="lblPrintTime" runat="server" />
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                    <hr style="border:1.5px solid #1A1A2E; margin-bottom:16px;" />

                                    <%-- KPI SUMMARY BOXES --%>
                                        <div style="text-align:center; margin-bottom:20px;">
                                            <div class="rpt-kpi-box" style="border-color:#e65100; background:#fff3e0;">
                                                <div
                                                    style="font-size:8pt; font-weight:700; color:#e65100; text-transform:uppercase; letter-spacing:1px;">
                                                    Pending</div>
                                                <div style="font-size:24pt; font-weight:900; color:#e65100;">
                                                    <asp:Label ID="lblRptPending" runat="server" Text="0" />
                                                </div>
                                                <div style="font-size:8pt; color:#888;">reservations</div>
                                            </div>
                                            <div class="rpt-kpi-box" style="border-color:#1565C0; background:#e3f2fd;">
                                                <div
                                                    style="font-size:8pt; font-weight:700; color:#1565C0; text-transform:uppercase; letter-spacing:1px;">
                                                    Occupied</div>
                                                <div style="font-size:24pt; font-weight:900; color:#1565C0;">
                                                    <asp:Label ID="lblRptOccupied" runat="server" Text="0" />
                                                </div>
                                                <div style="font-size:8pt; color:#888;">rooms</div>
                                            </div>
                                            <div class="rpt-kpi-box" style="border-color:#c62828; background:#fce4ec;">
                                                <div
                                                    style="font-size:8pt; font-weight:700; color:#c62828; text-transform:uppercase; letter-spacing:1px;">
                                                    Cancelled</div>
                                                <div style="font-size:24pt; font-weight:900; color:#c62828;">
                                                    <asp:Label ID="lblRptCancelled" runat="server" Text="0" />
                                                </div>
                                                <div style="font-size:8pt; color:#888;">reservations</div>
                                            </div>
                                            <div class="rpt-kpi-box" style="border-color:#607d8b; background:#eceff1;">
                                                <div
                                                    style="font-size:8pt; font-weight:700; color:#607d8b; text-transform:uppercase; letter-spacing:1px;">
                                                    Completed</div>
                                                <div style="font-size:24pt; font-weight:900; color:#607d8b;">
                                                    <asp:Label ID="lblRptCompleted" runat="server" Text="0" />
                                                </div>
                                                <div style="font-size:8pt; color:#888;">check-outs</div>
                                            </div>
                                            <div class="rpt-kpi-box" style="border-color:#2e7d32; background:#e8f5e9;">
                                                <div
                                                    style="font-size:8pt; font-weight:700; color:#2e7d32; text-transform:uppercase; letter-spacing:1px;">
                                                    Confirmed</div>
                                                <div style="font-size:24pt; font-weight:900; color:#2e7d32;">
                                                    <asp:Label ID="lblRptConfirmed" runat="server" Text="0" />
                                                </div>
                                                <div style="font-size:8pt; color:#888;">reservations</div>
                                            </div>
                                        </div>

                                        <%-- DETAIL TABLE --%>
                                            <div
                                                style="font-size:9pt; font-weight:700; text-transform:uppercase; letter-spacing:1.5px; color:#8B5E3C; margin-bottom:8px; border-bottom:1px solid #ccc; padding-bottom:5px;">
                                                Today's Reservation Detail</div>
                                            <asp:GridView ID="gvPrintReport" runat="server" AutoGenerateColumns="False"
                                                CssClass="rpt-table" GridLines="Both" BorderColor="#cccccc"
                                                BorderWidth="1px">
                                                <HeaderStyle BackColor="#1A1A2E" ForeColor="White" Font-Bold="True" />
                                                <AlternatingRowStyle BackColor="#f9f9f9" />
                                                <Columns>
                                                    <asp:BoundField DataField="ReservationNo" HeaderText="Res #"
                                                        ItemStyle-Font-Bold="true" />
                                                    <asp:BoundField DataField="GuestName" HeaderText="Guest Name" />
                                                    <asp:BoundField DataField="Club" HeaderText="Club" />
                                                    <asp:BoundField DataField="FromDate" HeaderText="Check-In"
                                                        DataFormatString="{0:dd-MMM-yyyy}" />
                                                    <asp:BoundField DataField="ToDate" HeaderText="Check-Out"
                                                        DataFormatString="{0:dd-MMM-yyyy}" />
                                                    <asp:BoundField DataField="NoOfRooms" HeaderText="Rooms"
                                                        ItemStyle-HorizontalAlign="Center"
                                                        HeaderStyle-HorizontalAlign="Center" />
                                                    <asp:BoundField DataField="AdvancePayment" HeaderText="Advance"
                                                        DataFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right"
                                                        HeaderStyle-HorizontalAlign="Right" />
                                                    <asp:BoundField DataField="Status" HeaderText="Status"
                                                        ItemStyle-HorizontalAlign="Center"
                                                        HeaderStyle-HorizontalAlign="Center" />
                                                </Columns>
                                            </asp:GridView>

                                            <div
                                                style="margin-top:24px; font-size:8.5pt; color:#555; text-align:right;">
                                                — End of Report —</div>
                                </div>

                                <script type="text/javascript">
                                    function triggerPrint() {
                                        var hf = document.getElementById('<%= hfTriggerPrint.ClientID %>');
                                        if (hf && hf.value === '1') {
                                            hf.value = '0';
                                            window.print();
                                        }
                                    }
                                    window.onload = triggerPrint;
                                </script>
                                <asp:HiddenField ID="hfTriggerPrint" runat="server" Value="0" />

        </div>
    </asp:Content>