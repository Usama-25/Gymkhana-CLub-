<%@ Page Title="Reservation Forecast" Language="C#" MasterPageFile="SiteGuestroom.master" AutoEventWireup="true" CodeFile="ReservationForecast.aspx.cs" Inherits="GuestRoomApp.GuestRoomM.ReservationForecast" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    /* Premium Theme & Animations */
    .forecast-container { 
        animation: fadeIn 0.5s ease-out;
        max-width: 1400px;
        margin: 0 auto;
    }
    
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(10px); }
        to { opacity: 1; transform: translateY(0); }
    }

    .filter-card {
        transition: all 0.3s ease;
        border-left: 4px solid #C9A84C !important;
    }
    
    .filter-card:hover {
        box-shadow: 0 8px 25px rgba(0,0,0,0.1) !important;
    }

    .summary-card {
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        cursor: default;
    }
    
    .summary-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 12px 30px rgba(0,0,0,0.12) !important;
    }

    .forecast-table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0;
    }
    
    .forecast-table th {
        background: #f8f9fa;
        color: #1A1A2E;
        font-weight: 700;
        text-transform: uppercase;
        font-size: 0.72rem;
        letter-spacing: 0.5px;
        padding: 14px 16px;
        border-bottom: 2px solid #e0d5c5;
    }
    
    .forecast-table td {
        padding: 12px 16px;
        border-bottom: 1px solid #f0f0f0;
        font-size: 0.85rem;
        color: #444;
        vertical-align: middle;
    }
    
    .forecast-table tr:hover td {
        background-color: #faf7f2;
    }

    .btn-view {
        background: transparent;
        color: #C9A84C;
        border: 1.5px solid #C9A84C;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 0.75rem;
        font-weight: 700;
        cursor: pointer;
        transition: all 0.2s;
        text-decoration: none;
        display: inline-block;
    }
    
    .btn-view:hover {
        background: #C9A84C;
        color: #fff;
        box-shadow: 0 3px 8px rgba(201,168,76,0.3);
    }

    .nav-link {
        position: relative;
        overflow: hidden;
    }
    
    .nav-link.active::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 0;
        width: 100%;
        height: 3px;
        background: #C9A84C;
    }

    .gridview-pager td {
        padding: 0;
    }
    
    .gridview-pager span, .gridview-pager a {
        display: inline-block;
        padding: 6px 12px;
        margin: 0 3px;
        border-radius: 4px;
        border: 1px solid #e0d5c5;
        text-decoration: none;
        color: #1A1A2E;
        font-size: 0.8rem;
    }
    
    .gridview-pager span {
        background: #1A1A2E;
        color: #fff;
        border-color: #1A1A2E;
    }

    @media(max-width:768px) {
        .summary-grid { grid-template-columns: 1fr 1fr !important; }
        .filter-row { flex-direction: column; }
    }
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="forecast-container" style="padding: 20px;">

    <%-- PAGE HEADER --%>
    <%-- PAGE HEADER --%>
    <div class="premium-header" style="background: linear-gradient(135deg, #1A1A2E 0%, #2d2d5e 100%); color: #fff; padding: 25px 30px; border-radius: 12px; margin-bottom: 25px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 10px 30px rgba(0,0,0,0.15);">
        <div>
            <h2 style="margin: 0; font-size: 1.6rem; font-weight: 800; letter-spacing: 0.5px;">
                <i class="fas fa-chart-line" style="color: #E8D5A3; margin-right: 10px;"></i>Reservation Forecast & Analysis
            </h2>
            <p style="margin: 5px 0 0; font-size: 0.85rem; color: #E8D5A3; opacity: 0.9;">Analyze occupancy trends, revenue projections, and booking distributions.</p>
            <div class="print-only" style="font-size: 0.75rem; color: #666; margin-top: 5px;">
                Analysis Generated on: <%= DateTime.Now.ToString("dd-MMM-yyyy HH:mm") %>
            </div>
        </div>
        <div class="no-print" style="display: flex; gap: 10px;">
             <asp:Button ID="btnExportExcel" runat="server" Text="Export Report" 
                style="background: rgba(255,255,255,0.1); color: #fff; border: 1px solid rgba(255,255,255,0.2); padding: 8px 20px; border-radius: 30px; font-size: 0.85rem; font-weight: 600; cursor: pointer; transition: all 0.3s;" 
                onmouseover="this.style.background='rgba(255,255,255,0.2)'" onmouseout="this.style.background='rgba(255,255,255,0.1)'"
                OnClick="btnExportExcel_Click" />
             <button type="button" onclick="window.print();" style="background: rgba(255,255,255,0.1); color: #fff; border: 1px solid rgba(255,255,255,0.2); padding: 8px 20px; border-radius: 30px; font-size: 0.85rem; font-weight: 600; cursor: pointer;">
                <i class="fas fa-print"></i> Print
             </button>
        </div>
    </div>

    <asp:Label ID="lblMessage" runat="server" style="padding: 12px 20px; border-radius: 8px; margin-bottom: 20px; font-size: 0.9rem; display: block; border-left: 5px solid transparent;" Visible="false" />

    <%-- FILTER PANEL --%>
    <div class="filter-card no-print" style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; padding: 25px; margin-bottom: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.05);">
        <div style="font-size: 0.75rem; font-weight: 800; letter-spacing: 1.5px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 18px; display: flex; align-items: center;">
            <i class="fas fa-filter" style="margin-right: 8px;"></i> Analysis Parameters
        </div>
        <div style="display: flex; gap: 20px; align-items: flex-end; flex-wrap: wrap;">
            <div style="display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 200px;">
                <label style="font-size: 0.8rem; font-weight: 700; color: #1A1A2E;">Start Date</label>
                <asp:TextBox ID="txtStartDate" runat="server" style="padding: 10px 15px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 0.9rem; width: 100%; transition: border-color 0.2s;" TextMode="Date" />
            </div>
            <div style="display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 200px;">
                <label style="font-size: 0.8rem; font-weight: 700; color: #1A1A2E;">End Date</label>
                <asp:TextBox ID="txtEndDate" runat="server" style="padding: 10px 15px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 0.9rem; width: 100%; transition: border-color 0.2s;" TextMode="Date" />
            </div>
            <div style="display: flex; gap: 10px;">
                <asp:LinkButton ID="btnGenerate" runat="server" OnClick="btnGenerate_Click"
                    style="background: #1A1A2E; color: #fff; text-decoration: none; padding: 10px 25px; border-radius: 8px; font-size: 0.9rem; font-weight: 600; transition: all 0.2s; display: inline-flex; align-items: center; gap: 8px;">
                    <i class="fas fa-sync-alt"></i> Run Analysis
                </asp:LinkButton>
            </div>
        </div>
    </div>

    <%-- SUMMARY CARDS --%>
    <div class="summary-grid" style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 30px;">
        <div class="summary-card" style="background: #fff; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-top: 5px solid #1e3a5f;">
            <div style="color: #64748b; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; margin-bottom: 10px;">Total Reservations</div>
            <div style="font-size: 1.8rem; font-weight: 800; color: #1e3a5f;"><asp:Label ID="lblTotalReservations" runat="server" Text="0" /></div>
        </div>
        <div class="summary-card" style="background: #fff; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-top: 5px solid #10b981;">
            <div style="color: #64748b; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; margin-bottom: 10px;">Room Nights</div>
            <div style="font-size: 1.8rem; font-weight: 800; color: #10b981;"><asp:Label ID="lblTotalRoomsBooked" runat="server" Text="0" /></div>
        </div>
        <div class="summary-card" style="background: #fff; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-top: 5px solid #C9A84C;">
            <div style="color: #64748b; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; margin-bottom: 10px;">Proj. Revenue</div>
            <div style="font-size: 1.6rem; font-weight: 800; color: #C9A84C;">PKR <asp:Label ID="lblTotalRevenue" runat="server" Text="0" /></div>
        </div>
        <div class="summary-card" style="background: #fff; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-top: 5px solid #8B5E3C;">
            <div style="color: #64748b; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; margin-bottom: 10px;">Avg. Occupancy</div>
            <div style="display: flex; align-items: baseline; gap: 8px;">
                <span style="font-size: 1.8rem; font-weight: 800; color: #8B5E3C;"><asp:Label ID="lblAvgPercent" runat="server" Text="0%" /></span>
                <span style="font-size: 0.9rem; color: #94a3b8; font-weight: 600;">(<asp:Label ID="lblAvgDailyOccupancy" runat="server" Text="0" /> rms/day)</span>
            </div>
        </div>
    </div>

    <%-- TABS + GRIDS --%>
    <asp:UpdatePanel runat="server">
        <ContentTemplate>
            <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); overflow: hidden;">
                <div class="no-print" style="display: flex; background: #fafafa; border-bottom: 1px solid #eee;">
                    <button type="button" class="nav-link active" onclick="showView('daily',this)" style="flex: 1; padding: 18px; border: none; background: transparent; cursor: pointer; font-weight: 700; font-size: 0.9rem; color: #444; transition: all 0.2s;">
                        <i class="far fa-calendar-alt" style="margin-right: 8px;"></i> Daily Breakdown
                    </button>
                    <button type="button" class="nav-link" onclick="showView('weekly',this)" style="flex: 1; padding: 18px; border: none; background: transparent; cursor: pointer; font-weight: 700; font-size: 0.9rem; color: #444; transition: all 0.2s;">
                        <i class="far fa-calendar-check" style="margin-right: 8px;"></i> Weekly Summary
                    </button>
                    <button type="button" class="nav-link" onclick="showView('monthly',this)" style="flex: 1; padding: 18px; border: none; background: transparent; cursor: pointer; font-weight: 700; font-size: 0.9rem; color: #444; transition: all 0.2s;">
                        <i class="far fa-calendar" style="margin-right: 8px;"></i> Monthly Analysis
                    </button>
                </div>

                <%-- DAILY VIEW --%>
                <div id="view-daily" class="forecast-view" style="padding: 10px;">
                    <%-- ═══════════════ DAILY FORECAST GRID ═══════════════ --%>
<asp:GridView ID="gvDaily" runat="server"
    AutoGenerateColumns="false"
    GridLines="None"
    DataKeyNames="ForecastDate"
    OnSelectedIndexChanged="gvDaily_SelectedIndexChanged"
    AllowPaging="true"
    PageSize="15"
    OnPageIndexChanging="gvDaily_PageIndexChanging"
    style="width:100%; border-collapse:collapse; font-size:0.85rem; background:#fff;"
    HeaderStyle-BackColor="#1A1A2E"
    HeaderStyle-ForeColor="#C9A84C"
    HeaderStyle-Font-Bold="True"
    HeaderStyle-Font-Size="X-Small"
    RowStyle-BackColor="#FFFFFF"
    RowStyle-ForeColor="#444444"
    AlternatingRowStyle-BackColor="#FAF7F2"
    AlternatingRowStyle-ForeColor="#444444"
    PagerStyle-BackColor="#F7F3EE"
    PagerStyle-ForeColor="#1A1A2E"
    PagerStyle-HorizontalAlign="Center"
    PagerStyle-Font-Size="Small"
    PagerStyle-Font-Bold="True">

    <Columns>

        <%-- Date --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Date</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 16px; color:#444; font-size:0.85rem;">
                    <%# Convert.ToDateTime(Eval("ForecastDate")).ToString("dd-MMM-yyyy (ddd)") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Res. --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Res.</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 16px; text-align:center; color:#444; font-size:0.85rem;"><%# Eval("TotalReservations") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Total Rms --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Total Rms</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 16px; text-align:center; color:#444; font-size:0.85rem;"><%# Eval("RoomsBooked") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- In-House --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">In-House</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 16px; text-align:center; color:#1e3a5f; font-weight:600; font-size:0.85rem;"><%# Eval("OccupiedRooms") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Reserved --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Reserved</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 16px; text-align:center; color:#2e7d32; font-size:0.85rem;"><%# Eval("ConfirmedRooms") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Occupancy % with bar --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Occupancy %</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 16px; text-align:center;">
                    <div style="width:100px; background:#eee; height:8px; border-radius:4px; margin:0 auto 4px; position:relative; display:block;">
                        <div style='<%# GetOccupancyBarStyle(Eval("OccupancyPercentage")) %>'></div>
                    </div>
                    <div style='<%# GetOccupancyTextStyle(Eval("OccupancyPercentage")) %>'>
                        <%# Eval("OccupancyPercentage") %>%
                        <%# GetOverbookingIcon(Eval("OccupancyPercentage")) %>
                    </div>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Revenue --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-align:right; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Revenue (PKR)</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 16px; text-align:right; font-weight:700; color:#C9A84C; font-size:0.85rem;">
                    <%# Convert.ToDecimal(Eval("ExpectedRevenue")).ToString("N0") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- View Button --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Detail</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:8px 16px; text-align:center;">
                    <asp:LinkButton runat="server" CommandName="Select"
                        style="background:transparent; color:#C9A84C; border:1.5px solid #C9A84C; padding:4px 12px; border-radius:20px; font-size:0.75rem; font-weight:700; cursor:pointer; text-decoration:none; display:inline-block;">
                        <i class="fas fa-eye"></i> View
                    </asp:LinkButton>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

    </Columns>

    <EmptyDataTemplate>
        <div style="padding:40px; text-align:center; color:#94a3b8; background:#fff;">
            <i class="fas fa-calendar-times" style="font-size:3rem; margin-bottom:15px; opacity:0.3; display:block;"></i>
            <p style="margin:0; font-size:0.85rem;">No forecast data available for the selected period.</p>
        </div>
    </EmptyDataTemplate>

</asp:GridView>

                </div>

                <%-- WEEKLY VIEW --%>
                <div id="view-weekly" class="forecast-view" style="display:none; padding: 10px;">
                    <%-- ═══════════════ WEEKLY FORECAST GRID ═══════════════ --%>
<asp:GridView ID="gvWeekly" runat="server"
    AutoGenerateColumns="false"
    GridLines="None"
    DataKeyNames="WeekStart"
    OnSelectedIndexChanged="gvWeekly_SelectedIndexChanged"
    AllowPaging="true"
    PageSize="10"
    OnPageIndexChanging="gvWeekly_PageIndexChanging"
    style="width:100%; border-collapse:collapse; font-size:0.85rem; background:#fff;"
    HeaderStyle-BackColor="#1A1A2E"
    HeaderStyle-ForeColor="#C9A84C"
    HeaderStyle-Font-Bold="True"
    HeaderStyle-Font-Size="X-Small"
    RowStyle-BackColor="#FFFFFF"
    RowStyle-ForeColor="#444444"
    AlternatingRowStyle-BackColor="#FAF7F2"
    AlternatingRowStyle-ForeColor="#444444"
    PagerStyle-BackColor="#F7F3EE"
    PagerStyle-ForeColor="#1A1A2E"
    PagerStyle-HorizontalAlign="Center"
    PagerStyle-Font-Size="Small"
    PagerStyle-Font-Bold="True">

    <Columns>

        <%-- Week Period --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Week Period</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 16px;">
                    <div style="font-weight:700; color:#1e3a5f; font-size:0.85rem;">Week <%# Eval("WeekNo") %></div>
                    <div style="font-size:0.75rem; color:#7a7a7a; margin-top:2px;">
                        <%# Convert.ToDateTime(Eval("WeekStart")).ToString("dd MMM") %> – <%# Convert.ToDateTime(Eval("WeekEnd")).ToString("dd MMM yyyy") %>
                    </div>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Bookings --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Bookings</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 16px; text-align:center; color:#444; font-size:0.85rem;"><%# Eval("TotalReservations") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Room-Nights --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Room-Nights</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 16px; text-align:center; color:#444; font-size:0.85rem;"><%# Eval("TotalRoomsBooked") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Avg Occupancy --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Avg Occupancy</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 16px; text-align:center;">
                    <span style='<%# GetWeeklyOccupancyStyle(Eval("AvgOccupancyPercentage")) %>'>
                        <%# Eval("AvgOccupancyPercentage") %>%
                    </span>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Est. Revenue --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-align:right; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Est. Revenue (PKR)</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 16px; text-align:right; font-weight:700; color:#C9A84C; font-size:0.85rem;">
                    <%# Convert.ToDecimal(Eval("ExpectedRevenue")).ToString("N0") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Details Button --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Detail</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:8px 16px; text-align:center;">
                    <asp:LinkButton runat="server" CommandName="Select"
                        style="background:transparent; color:#C9A84C; border:1.5px solid #C9A84C; padding:4px 12px; border-radius:20px; font-size:0.75rem; font-weight:700; cursor:pointer; text-decoration:none; display:inline-block;">
                        <i class="fas fa-eye"></i> Details
                    </asp:LinkButton>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

    </Columns>

    <EmptyDataTemplate>
        <div style="padding:40px; text-align:center; color:#94a3b8; background:#fff;">
            <i class="fas fa-calendar-times" style="font-size:3rem; margin-bottom:15px; opacity:0.3; display:block;"></i>
            <p style="margin:0; font-size:0.85rem;">No weekly data available.</p>
        </div>
    </EmptyDataTemplate>

</asp:GridView>

                </div>

                <%-- MONTHLY VIEW --%>
                <div id="view-monthly" class="forecast-view" style="display:none; padding: 10px;">
                    <%-- ═══════════════ MONTHLY FORECAST GRID ═══════════════ --%>
<asp:GridView ID="gvMonthly" runat="server"
    AutoGenerateColumns="false"
    GridLines="None"
    DataKeyNames="Year,MonthNo"
    OnSelectedIndexChanged="gvMonthly_SelectedIndexChanged"
    AllowPaging="true"
    PageSize="12"
    OnPageIndexChanging="gvMonthly_PageIndexChanging"
    style="width:100%; border-collapse:collapse; font-size:0.85rem; background:#fff;"
    HeaderStyle-BackColor="#1A1A2E"
    HeaderStyle-ForeColor="#C9A84C"
    HeaderStyle-Font-Bold="True"
    HeaderStyle-Font-Size="X-Small"
    RowStyle-BackColor="#FFFFFF"
    RowStyle-ForeColor="#444444"
    AlternatingRowStyle-BackColor="#FAF7F2"
    AlternatingRowStyle-ForeColor="#444444"
    PagerStyle-BackColor="#F7F3EE"
    PagerStyle-ForeColor="#1A1A2E"
    PagerStyle-HorizontalAlign="Center"
    PagerStyle-Font-Size="Small"
    PagerStyle-Font-Bold="True">

    <Columns>

        <%-- Month --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Month</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 16px; display:flex; align-items:center; gap:10px;">
                    <div style="background:#1A1A2E; color:#C9A84C; width:40px; height:40px; border-radius:8px; display:flex; align-items:center; justify-content:center; font-weight:800; font-size:0.68rem; flex-shrink:0; text-align:center; line-height:1.2;">
                        <%# Eval("Year") %>
                    </div>
                    <span style="font-weight:700; color:#1e293b; font-size:0.85rem;"><%# Eval("MonthName") %></span>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Total Bookings --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Total Bookings</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 16px; text-align:center; color:#444; font-size:0.85rem;"><%# Eval("TotalReservations") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Room-Nights --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Room-Nights</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 16px; text-align:center; color:#444; font-size:0.85rem;"><%# Eval("TotalRoomsBooked") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Avg % --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Avg %</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 16px; text-align:center; font-weight:700; color:#444; font-size:0.85rem;"><%# Eval("AvgOccupancyPercentage") %>%</div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Advance Recv. --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-align:right; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Advance Recv.</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 16px; text-align:right; color:#444; font-size:0.85rem;">
                    <%# Convert.ToDecimal(Eval("TotalAdvanceReceived")).ToString("N0") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Proj. Revenue --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-align:right; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Proj. Revenue</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 16px; text-align:right; font-weight:700; color:#15803d; font-size:0.85rem;">
                    <%# Convert.ToDecimal(Eval("ExpectedRevenue")).ToString("N0") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Analysis Button --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:14px 16px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Detail</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:8px 16px; text-align:center;">
                    <asp:LinkButton runat="server" CommandName="Select"
                        style="background:transparent; color:#C9A84C; border:1.5px solid #C9A84C; padding:4px 12px; border-radius:20px; font-size:0.75rem; font-weight:700; cursor:pointer; text-decoration:none; display:inline-block;">
                        <i class="fas fa-search"></i> Analysis
                    </asp:LinkButton>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

    </Columns>

    <EmptyDataTemplate>
        <div style="padding:40px; text-align:center; color:#94a3b8; background:#fff;">
            <i class="fas fa-calendar-times" style="font-size:3rem; margin-bottom:15px; opacity:0.3; display:block;"></i>
            <p style="margin:0; font-size:0.85rem;">No monthly data available.</p>
        </div>
    </EmptyDataTemplate>

</asp:GridView>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

</div>

<%-- DETAIL MODAL --%>
<div id="detailModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.7); z-index:2000; align-items:center; justify-content:center; padding:20px; backdrop-filter: blur(4px);">
    <div style="background:#ffffff; width:100%; max-width:750px; max-height:85vh; border-radius:16px; display:flex; flex-direction:column; overflow:hidden; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.5);">
        <div style="padding: 20px 25px; border-bottom: 1px solid #eee; background: #1A1A2E; color: #fff; display: flex; justify-content: space-between; align-items: center;">
            <h4 style="margin: 0; font-size: 1.1rem; font-weight: 700;"><i class="fas fa-list-ul" style="margin-right: 10px; color: #E8D5A3;"></i> Reservation Details</h4>
            <button type="button" style="background:none; border:none; color:#fff; font-size:1.5rem; cursor:pointer; line-height:1; opacity: 0.7;" onclick="document.getElementById('detailModal').style.display='none'">&times;</button>
        </div>
        <div id="modalBody" style="padding: 25px; overflow-y: auto; flex: 1; background: #fafafa;">
            <%-- Data injected here --%>
        </div>
        <div style="padding: 15px 25px; border-top: 1px solid #eee; text-align: right; background: #fff;">
            <button type="button" style="background: #1A1A2E; color: #fff; border: none; padding: 10px 25px; border-radius: 8px; font-size: 0.9rem; font-weight: 600; cursor: pointer;" onclick="document.getElementById('detailModal').style.display='none'">Close Window</button>
        </div>
    </div>
</div>

<script>
    function showView(viewId, btn) {
        document.querySelectorAll('.forecast-view').forEach(v => v.style.display = 'none');
        document.getElementById('view-' + viewId).style.display = 'block';
        document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
        btn.classList.add('active');
    }
    
    function showDetail(html) {
        document.getElementById('modalBody').innerHTML = html;
        document.getElementById('detailModal').style.display = 'flex';
    }
    
    // Auto-initialize view on UpdatePanel partial postback
    var prm = Sys.WebForms.PageRequestManager.getInstance();
    prm.add_endRequest(function() {
        // Re-apply current active view logic if needed
    });
</script>
</asp:Content>