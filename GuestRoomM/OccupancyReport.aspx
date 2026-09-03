<%@ Page Title="Occupancy Report" Language="C#" MasterPageFile="SiteGuestroom.master"
    AutoEventWireup="true" CodeFile="OccupancyReport.aspx.cs" Inherits="GuestRoomApp.GuestRoomM.OccupancyReport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    /* Premium Theme & Animations */
    .report-container { 
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

    .report-table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0;
    }
    
    .report-table th {
        background: #f8f9fa;
        color: #1A1A2E;
        font-weight: 700;
        text-transform: uppercase;
        font-size: 0.72rem;
        letter-spacing: 0.5px;
        padding: 14px 16px;
        border-bottom: 2px solid #e0d5c5;
    }
    
    .report-table td {
        padding: 12px 16px;
        border-bottom: 1px solid #f0f0f0;
        font-size: 0.85rem;
        color: #444;
        vertical-align: middle;
    }
    
    .report-table tr:hover td {
        background-color: #faf7f2;
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
<div class="report-container" style="padding: 20px;">

    <%-- PAGE HEADER --%>
    <div class="premium-header" style="background: linear-gradient(135deg, #1A1A2E 0%, #2d2d5e 100%); color: #fff; padding: 25px 30px; border-radius: 12px; margin-bottom: 25px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 10px 30px rgba(0,0,0,0.15);">
        <div>
            <h2 style="margin: 0; font-size: 1.6rem; font-weight: 800; letter-spacing: 0.5px;">
                <i class="fas fa-chart-pie" style="color: #E8D5A3; margin-right: 10px;"></i>Occupancy Report & Analysis
            </h2>
            <p style="margin: 5px 0 0; font-size: 0.85rem; color: #E8D5A3; opacity: 0.9;">Analyze room utilization, capacity trends, and revenue performance.</p>
            <div class="print-only" style="font-size: 0.75rem; color: #666; margin-top: 5px; display:flex; align-items:center; gap:12px;">
                <img src="images/lahore_gymkhana_logo1.png" alt="Lahore Gymkhana"
                     style="height:50px; width:auto;" />
                <div>
                    <div style="font-size:12pt; font-weight:800; color:#fff; margin-bottom:2px;">Lahore Gymkhana</div>
                    <div>Report Generated on: <%= DateTime.Now.ToString("dd-MMM-yyyy HH:mm") %></div>
                </div>
            </div>
        </div>
        <div class="no-print" style="display: flex; gap: 10px;">
             <asp:Button ID="btnExportExcel" runat="server" Text="Export Excel" 
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
            <i class="fas fa-filter" style="margin-right: 8px;"></i> Report Parameters
        </div>
        <div style="display: flex; gap: 20px; align-items: flex-end; flex-wrap: wrap;">
            <div style="display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 200px;">
                <label style="font-size: 0.8rem; font-weight: 700; color: #1A1A2E;">From Date</label>
                <asp:TextBox ID="txtFromDate" runat="server" style="padding: 10px 15px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 0.9rem; width: 100%; transition: border-color 0.2s;" TextMode="Date" />
            </div>
            <div style="display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 200px;">
                <label style="font-size: 0.8rem; font-weight: 700; color: #1A1A2E;">To Date</label>
                <asp:TextBox ID="txtToDate" runat="server" style="padding: 10px 15px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 0.9rem; width: 100%; transition: border-color 0.2s;" TextMode="Date" />
            </div>
            <div style="display: flex; gap: 10px;">
                <asp:LinkButton ID="btnGenerate" runat="server" OnClick="btnGenerate_Click"
                    style="background: #1A1A2E; color: #fff; text-decoration: none; padding: 10px 25px; border-radius: 8px; font-size: 0.9rem; font-weight: 600; transition: all 0.2s; display: inline-flex; align-items: center; gap: 8px;">
                    <i class="fas fa-sync-alt"></i> Generate Report
                </asp:LinkButton>
            </div>
        </div>
    </div>

    <%-- SUMMARY CARDS --%>
    <div class="summary-grid" style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 30px;">
        <div class="summary-card" style="background: #fff; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-top: 5px solid #1A1A2E;">
            <div style="color: #64748b; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; margin-bottom: 10px;">Total Inventory</div>
            <div style="font-size: 1.8rem; font-weight: 800; color: #1A1A2E;"><asp:Label ID="lblTotalRooms" runat="server" Text="0" /></div>
            <div style="font-size: 0.72rem; color: #94a3b8; font-weight: 600; margin-top: 5px;">Active Rooms</div>
        </div>
        <div class="summary-card" style="background: #fff; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-top: 5px solid #10b981;">
            <div style="color: #64748b; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; margin-bottom: 10px;">Avg. Occupied</div>
            <div style="font-size: 1.8rem; font-weight: 800; color: #10b981;"><asp:Label ID="lblOccupiedRooms" runat="server" Text="0" /></div>
            <div style="font-size: 0.72rem; color: #10b981; font-weight: 700; margin-top: 5px;"><asp:Label ID="lblOccupancyPercent" runat="server" Text="0%" /> Occupancy</div>
        </div>
        <div class="summary-card" style="background: #fff; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-top: 5px solid #ef4444;">
            <div style="color: #64748b; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; margin-bottom: 10px;">Avg. Available</div>
            <div style="font-size: 1.8rem; font-weight: 800; color: #ef4444;"><asp:Label ID="lblAvailableRooms" runat="server" Text="0" /></div>
            <div style="font-size: 0.72rem; color: #94a3b8; font-weight: 600; margin-top: 5px;">Vacant Rooms/Day</div>
        </div>
        <div class="summary-card" style="background: #fff; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-top: 5px solid #C9A84C;">
            <div style="color: #64748b; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; margin-bottom: 10px;">Total Revenue</div>
            <div style="font-size: 1.6rem; font-weight: 800; color: #C9A84C;">PKR <asp:Label ID="lblTotalRevenue" runat="server" Text="0" /></div>
            <div style="font-size: 0.72rem; color: #94a3b8; font-weight: 600; margin-top: 5px;">Room Rent Realized</div>
        </div>
    </div>

    <%-- TABS + GRIDS --%>
    <asp:UpdatePanel runat="server">
        <ContentTemplate>
            <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); overflow: hidden;">
                <div class="no-print" style="display: flex; background: #fafafa; border-bottom: 1px solid #eee;">
                    <button type="button" id="btnTabDaily" class="nav-link active" onclick="showView('daily',this)" style="flex: 1; padding: 18px; border: none; background: transparent; cursor: pointer; font-weight: 700; font-size: 0.9rem; color: #444; transition: all 0.2s;">
                        <i class="far fa-calendar-alt" style="margin-right: 8px;"></i> Daily Analytics
                    </button>
                    <button type="button" id="btnTabWeekly" class="nav-link" onclick="showView('weekly',this)" style="flex: 1; padding: 18px; border: none; background: transparent; cursor: pointer; font-weight: 700; font-size: 0.9rem; color: #444; transition: all 0.2s;">
                        <i class="far fa-calendar-check" style="margin-right: 8px;"></i> Weekly Summary
                    </button>
                    <button type="button" id="btnTabMonthly" class="nav-link" onclick="showView('monthly',this)" style="flex: 1; padding: 18px; border: none; background: transparent; cursor: pointer; font-weight: 700; font-size: 0.9rem; color: #444; transition: all 0.2s;">
                        <i class="far fa-calendar" style="margin-right: 8px;"></i> Monthly Analysis
                    </button>
                </div>

                <%-- CHART PANEL (Only for Daily) --%>
                <div id="chart-area" style="padding: 20px; border-bottom: 1px solid #f0f0f0;">
                    <asp:Panel ID="chartContainer" runat="server" Visible="false">
                        <div style="font-size: 0.7rem; font-weight: 800; text-transform: uppercase; letter-spacing: 1px; color: #8B5E3C; margin-bottom: 15px;">
                            <i class="fas fa-chart-bar" style="margin-right: 5px;"></i> Occupancy Trend (Last 20 Days)
                        </div>
                        <div id="barWrap" style="display: flex; align-items: flex-end; gap: 8px; height: 120px; overflow-x: auto; padding-bottom: 10px;">
                            <%-- Bars injected via JS --%>
                        </div>
                    </asp:Panel>
                </div>

                <%-- DAILY VIEW --%>
                <div id="view-daily" class="report-view" style="padding: 10px;">
                    <%-- ═══════════════ DAILY / OCCUPANCY GRID ═══════════════ --%>
<asp:GridView ID="gvOccupancy" runat="server"
    AutoGenerateColumns="false"
    GridLines="None"
    AllowPaging="true"
    PageSize="15"
    OnPageIndexChanging="gvOccupancy_PageIndexChanging"
    style="width:100%; border-collapse:collapse; font-size:0.85rem; background:#fff;"
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

    <Columns>

        <%-- Date --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 14px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Date</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 14px; color:#1e293b; font-size:0.85rem;">
                    <%# Convert.ToDateTime(Eval("OccupancyDate")).ToString("dd-MMM-yyyy (ddd)") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Occupied --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 14px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Occupied</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 14px; text-align:center; font-weight:700; color:#1e3a5f; font-size:0.85rem;"><%# Eval("AvailedRooms") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Confirmed --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 14px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Confirmed</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 14px; text-align:center; color:#2e7d32; font-size:0.85rem;"><%# Eval("ConfirmedRooms") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Pending --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 14px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Pending</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 14px; text-align:center; color:#e65100; font-size:0.85rem;"><%# Eval("PendingRooms") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Dirty --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 14px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Dirty</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 14px; text-align:center; color:#8B5E3C; font-size:0.85rem;"><%# Eval("DirtyRooms") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Total Booked --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 14px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Total Booked</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 14px; text-align:center; color:#1e293b; font-size:0.85rem;"><%# Eval("TotalBookedRooms") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Occupancy % with bar --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 14px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Occupancy %</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 14px; text-align:center;">
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
                <span style="display:block; padding:12px 14px; text-align:right; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Revenue (PKR)</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 14px; text-align:right; font-weight:700; color:#C9A84C; font-size:0.85rem;">
                    <%# Convert.ToDecimal(Eval("TotalRevenue")).ToString("N0") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

    </Columns>

    <EmptyDataTemplate>
        <div style="padding:40px; text-align:center; color:#94a3b8; background:#fff;">
            <i class="fas fa-calendar-times" style="font-size:3rem; margin-bottom:15px; opacity:0.3; display:block;"></i>
            <p style="margin:0; font-size:0.85rem;">No occupancy data available for the selected period.</p>
        </div>
    </EmptyDataTemplate>

</asp:GridView>

                    <div style="padding: 10px 15px; font-size: 0.75rem; color: #64748b; font-weight: 600;">
                        Showing <asp:Label ID="lblRecordCount" runat="server" Text="0" /> daily records
                    </div>
                </div>

                <%-- WEEKLY VIEW --%>
                <div id="view-weekly" class="report-view" style="display:none; padding: 10px;">
                    <%-- ═══════════════ WEEKLY GRID ═══════════════ --%>
<asp:GridView ID="gvWeekly" runat="server"
    AutoGenerateColumns="false"
    GridLines="None"
    style="width:100%; border-collapse:collapse; font-size:0.85rem; background:#fff;"
    HeaderStyle-BackColor="#1A1A2E"
    HeaderStyle-ForeColor="#C9A84C"
    HeaderStyle-Font-Bold="True"
    HeaderStyle-Font-Size="X-Small"
    RowStyle-BackColor="#FFFFFF"
    RowStyle-ForeColor="#1e293b"
    AlternatingRowStyle-BackColor="#F8F9FA"
    AlternatingRowStyle-ForeColor="#1e293b">

    <Columns>

        <%-- Week Period --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 14px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Week Period</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 14px;">
                    <div style="font-weight:700; color:#1e3a5f; font-size:0.85rem;">Week <%# Eval("WeekNo") %></div>
                    <div style="font-size:0.75rem; color:#7a7a7a; margin-top:2px;">
                        <%# Convert.ToDateTime(Eval("WeekStart")).ToString("dd MMM") %> – <%# Convert.ToDateTime(Eval("WeekEnd")).ToString("dd MMM yyyy") %>
                    </div>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Total Room-Nights --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 14px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Total Room-Nights</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 14px; text-align:center; font-weight:700; color:#1e293b; font-size:0.85rem;"><%# Eval("TotalRooms") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Avg Occupancy --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 14px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Avg Occupancy</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 14px; text-align:center;">
                    <span style='<%# GetWeeklyOccupancyStyle(Eval("AvgOccupancy")) %>'>
                        <%# Eval("AvgOccupancy") %>%
                    </span>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Est. Revenue --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 14px; text-align:right; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Est. Revenue (PKR)</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 14px; text-align:right; font-weight:700; color:#C9A84C; font-size:0.85rem;">
                    <%# Convert.ToDecimal(Eval("Revenue")).ToString("N0") %>
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
                <div id="view-monthly" class="report-view" style="display:none; padding: 10px;">
                    <%-- ═══════════════ MONTHLY GRID ═══════════════ --%>
<asp:GridView ID="gvMonthly" runat="server"
    AutoGenerateColumns="false"
    GridLines="None"
    style="width:100%; border-collapse:collapse; font-size:0.85rem; background:#fff;"
    HeaderStyle-BackColor="#1A1A2E"
    HeaderStyle-ForeColor="#C9A84C"
    HeaderStyle-Font-Bold="True"
    HeaderStyle-Font-Size="X-Small"
    RowStyle-BackColor="#FFFFFF"
    RowStyle-ForeColor="#1e293b"
    AlternatingRowStyle-BackColor="#F8F9FA"
    AlternatingRowStyle-ForeColor="#1e293b">

    <Columns>

        <%-- Month --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 14px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Month</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 14px; display:flex; align-items:center; gap:10px;">
                    <div style="background:#1A1A2E; color:#C9A84C; width:40px; height:40px; border-radius:8px; display:flex; align-items:center; justify-content:center; font-weight:800; font-size:0.68rem; flex-shrink:0; text-align:center; line-height:1.2;">
                        <%# Eval("Year") %>
                    </div>
                    <span style="font-weight:700; color:#1e293b; font-size:0.85rem;"><%# Eval("Month") %></span>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Monthly Room-Nights --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 14px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Monthly Room-Nights</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 14px; text-align:center; font-weight:700; color:#1e293b; font-size:0.85rem;"><%# Eval("Rooms") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Avg Occupancy % --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 14px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Avg Occupancy %</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 14px; text-align:center; font-weight:700; color:#1e293b; font-size:0.85rem;"><%# Eval("AvgPct") %>%</div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Realized Revenue --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 14px; text-align:right; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Realized Revenue</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 14px; text-align:right; font-weight:700; color:#15803d; font-size:0.85rem;">
                    <%# Convert.ToDecimal(Eval("Revenue")).ToString("N0") %>
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

<script>
    function showView(viewId, btn) {
        document.querySelectorAll('.report-view').forEach(v => v.style.display = 'none');
        document.getElementById('view-' + viewId).style.display = 'block';
        document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
        btn.classList.add('active');
        
        // Hide chart if not daily
        var chartArea = document.getElementById('chart-area');
        if (chartArea) {
            chartArea.style.display = (viewId === 'daily') ? 'block' : 'none';
        }
    }
    
    function drawBars(data) {
        var wrap = document.getElementById('barWrap');
        if (!wrap || !data || !data.length) return;
        var max = Math.max.apply(null, data.map(function (d) { return d.p; })) || 1;
        wrap.innerHTML = '';
        data.forEach(function (d) {
            var h = Math.max(4, Math.round((d.p / max) * 100));
            var col = d.p >= 90 ? '#ef4444' : d.p >= 70 ? '#f59e0b' : '#10b981';
            var el = document.createElement('div');
            el.style.display = 'flex'; el.style.flexDirection = 'column'; el.style.alignItems = 'center'; el.style.minWidth = '45px';
            el.innerHTML =
                '<div style="width:20px; height:' + h + 'px; background:' + col + '; border-radius:4px 4px 0 0; transition:height 0.6s cubic-bezier(0.4, 0, 0.2, 1);"></div>' +
                '<div style="font-size:0.7rem; font-weight:800; color:#1A1A2E; margin-top:6px;">' + d.p + '%</div>' +
                '<div style="font-size:0.6rem; color:#64748b; font-weight:600;">' + d.dt + '</div>';
            wrap.appendChild(el);
        });
    }
    
    // Auto-initialize view on UpdatePanel partial postback
    var prm = Sys.WebForms.PageRequestManager.getInstance();
    prm.add_endRequest(function() {
        // Find active tab and ensure its view is shown
        var activeTab = document.querySelector('.nav-link.active');
        if (activeTab) {
            var tabId = activeTab.id.replace('btnTab', '').toLowerCase();
            showView(tabId, activeTab);
        }
    });
</script>
</asp:Content>

