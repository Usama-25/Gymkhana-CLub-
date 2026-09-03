<%@ page language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" autoeventwireup="true" CodeFile="Dashboard.aspx.cs" Inherits="Pages_Admin_Dashboard" title="Library Dashboard - Lahore Gymkhana Library" %>

<asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        /* KPI Cards Styling */
        .kpi-card {
            background-color: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 14px 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.02);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: transform 0.2s cubic-bezier(0.4, 0, 0.2, 1), box-shadow 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .kpi-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 16px -4px rgba(15, 30, 54, 0.08);
        }
        .kpi-title {
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            color: #64748b;
            letter-spacing: 0.6px;
        }
        .kpi-value {
            font-size: 24px;
            font-weight: 800;
            color: #0f1e36;
            margin: 4px 0 2px 0;
            line-height: 1.1;
        }
        .kpi-desc {
            font-size: 11px;
            color: #64748b;
        }

        /* Custom Scrollbar for scrollable panels */
        .scrollable-body::-webkit-scrollbar {
            width: 6px;
            height: 6px;
        }
        .scrollable-body::-webkit-scrollbar-track {
            background: transparent;
        }
        .scrollable-body::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 3px;
        }
        .scrollable-body::-webkit-scrollbar-thumb:hover {
            background: #94a3b8;
        }
    </style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">

<!-- Header -->
<div style="background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; padding: 12px 24px; border-radius: 8px; margin-bottom: 16px; border-bottom: 2px solid #c5a059; display: flex; justify-content: space-between; align-items: center; width: 100%; box-sizing: border-box;">
    <div style="display: block;">
        <h2 style="margin: 0; font-size: 18px; font-weight: 600;">Library Dashboard</h2>
    </div>
    <div style="font-size: 11px; opacity: .7; font-weight: 300;">Lahore Gymkhana Club Portal</div>
</div>

<!-- KPI Metric Cards Grid -->
<div style="display: grid; grid-template-columns: repeat(5, 1fr); gap: 16px; margin-bottom: 16px; width: 100%; box-sizing: border-box;">
    <div class="kpi-card" style="border-bottom: 3px solid #c5a059;">
        <span class="kpi-title">Total Book Titles</span>
        <div class="kpi-value"><asp:Literal ID="litTotalTitles" runat="server" Text="0" /></div>
        <span class="kpi-desc">Distinct catalog titles</span>
    </div>
    <div class="kpi-card" style="border-bottom: 3px solid #10b981;">
        <span class="kpi-title">Active Members</span>
        <div class="kpi-value"><asp:Literal ID="litActiveMembers" runat="server" Text="0" /></div>
        <span class="kpi-desc">Registered club readers</span>
    </div>
    <div class="kpi-card" style="border-bottom: 3px solid #3b82f6;">
        <span class="kpi-title">Books Out on Loan</span>
        <div class="kpi-value"><asp:Literal ID="litBooksOut" runat="server" Text="0" /></div>
        <span class="kpi-desc"><asp:Literal ID="litAvailableCopies" runat="server" Text="0" /> copies on shelves</span>
    </div>
    <asp:LinkButton ID="lnkOverduesCard" runat="server" OnClick="lnkOverduesCard_Click" Style="text-decoration: none; border-bottom: 3px solid #ef4444;" CssClass="kpi-card">
        <span class="kpi-title" style="color: #ef4444;">Overdue Borrowings</span>
        <div class="kpi-value" style="color: #ef4444;"><asp:Literal ID="litOverdue" runat="server" Text="0" /></div>
        <span class="kpi-desc">Fines: <strong>PKR <asp:Literal ID="litFines" runat="server" Text="0.00" /></strong></span>
    </asp:LinkButton>
    <asp:LinkButton ID="lnkTodayReturnsCard" runat="server" OnClick="lnkTodayReturnsCard_Click" Style="text-decoration: none; border-bottom: 3px solid #6366f1;" CssClass="kpi-card">
        <span class="kpi-title" style="color: #6366f1;">Today's Returns</span>
        <div class="kpi-value" style="color: #6366f1;"><asp:Literal ID="litTodayReturns" runat="server" Text="0" /></div>
        <span class="kpi-desc">Expected back today</span>
    </asp:LinkButton>
</div>

<!-- Reminders Queue Stats Row -->
<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 20px; width: 100%; box-sizing: border-box;">
    <a href="OverdueManagement.aspx?tab=REMINDERS&amp;scenario=1" style="text-decoration: none; border-left: 4px solid #f59e0b; display: flex; flex-direction: column; justify-content: space-between;" class="kpi-card">
        <span class="kpi-title" style="color: #f59e0b; font-size: 9px;">Gentle Reminders Queue (7d+)</span>
        <div style="font-size: 16px; font-weight: 700; color: #0f1e36; margin-top: 4px;"><asp:Literal ID="litRemindersGentle" runat="server" Text="0" /> Pending</div>
    </a>
    <a href="OverdueManagement.aspx?tab=REMINDERS&amp;scenario=2" style="text-decoration: none; border-left: 4px solid #ea580c; display: flex; flex-direction: column; justify-content: space-between;" class="kpi-card">
        <span class="kpi-title" style="color: #ea580c; font-size: 9px;">Harsh Reminders Queue (15d+)</span>
        <div style="font-size: 16px; font-weight: 700; color: #0f1e36; margin-top: 4px;"><asp:Literal ID="litRemindersHarsh" runat="server" Text="0" /> Pending</div>
    </a>
    <a href="OverdueManagement.aspx?tab=REMINDERS&amp;scenario=3" style="text-decoration: none; border-left: 4px solid #dc2626; display: flex; flex-direction: column; justify-content: space-between;" class="kpi-card">
        <span class="kpi-title" style="color: #dc2626; font-size: 9px;">Final Warn / Charge Queue (30d+)</span>
        <div style="font-size: 16px; font-weight: 700; color: #0f1e36; margin-top: 4px;"><asp:Literal ID="litRemindersFinal" runat="server" Text="0" /> Pending</div>
    </a>
</div>

<!-- Dashboard Split View -->
<div style="display: flex; gap: 20px; width: 100%; box-sizing: border-box; flex-wrap: wrap;">
    <!-- Left Column: Dynamic Grid View -->
    <div style="flex: 1.6; min-width: 320px; box-sizing: border-box;">
        <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 1px 2px 0 rgba(0,0,0,0.05); overflow: hidden; width: 100%; height: 420px; display: flex; flex-direction: column;">
            <!-- Header -->
            <div style="padding: 12px 20px; background-color: #f8fafc; border-bottom: 1px solid #e2e8f0; font-weight: 700; font-size: 13.5px; color: #0f1e36; display: flex; justify-content: space-between; align-items: center; flex: 0 0 auto;">
                <span><asp:Literal ID="litGridTitle" runat="server" Text="Overdue Loans and Warnings" /></span>
                <span id="spnBadge" runat="server" style="background-color: #fee2e2; color: #ef4444; font-weight: 700; padding: 2px 6px; border-radius: 4px; font-size: 10px; text-transform: uppercase;"><asp:Literal ID="litOverdueCountBadge" runat="server" Text="0" /> Overdue</span>
            </div>
            <!-- Scrollable Body -->
            <div class="scrollable-body" style="padding: 16px 20px; overflow-y: auto; flex: 1 1 auto; box-sizing: border-box; width: 100%;">
                <div style="width: 100%; overflow-x: auto;">
                    <table style="width: 100%; border-collapse: collapse; font-size: 12.5px;">
                        <thead>
                            <tr style="border-bottom: 2px solid #e2e8f0;">
                                <th style="background-color: #f1f5f9; padding: 8px 12px; font-weight: 700; text-align: left; color: #64748b; font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.5px;">Member</th>
                                <th style="background-color: #f1f5f9; padding: 8px 12px; font-weight: 700; text-align: left; color: #64748b; font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.5px;">Book / Barcode</th>
                                <th style="background-color: #f1f5f9; padding: 8px 12px; font-weight: 700; text-align: left; color: #64748b; font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.5px;">Due Date</th>
                                <th style="background-color: #f1f5f9; padding: 8px 12px; font-weight: 700; text-align: left; color: #64748b; font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.5px;">Days Past</th>
                                <th style="background-color: #f1f5f9; padding: 8px 12px; font-weight: 700; text-align: left; color: #64748b; font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.5px;">Fine</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptOverdues" runat="server">
                                <ItemTemplate>
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="padding: 10px 12px; line-height: 1.35;">
                                            <strong><%# Eval("MemberName") %></strong><br/>
                                            <span style="font-size:11px;color:#64748b;"><%# Eval("MembershipNo") %> - <%# Eval("Phone") %></span>
                                        </td>
                                        <td style="padding: 10px 12px; line-height: 1.35;">
                                            <strong><%# Eval("Title") %></strong><br/>
                                            <code style="font-family: monospace; font-weight: 600; color: #1c3254; background-color: #f1f5f9; padding: 1px 4px; border-radius: 4px; font-size: 10.5px;"><%# Eval("Barcode") %></code>
                                        </td>
                                        <td style="padding: 10px 12px;"><%# Eval("DueDate", "{0:dd-MMM-yyyy}") %></td>
                                        <td style="padding: 10px 12px;">
                                            <span style="color:#ef4444;font-weight:700;"><%# Eval("DaysOverdue") %> days</span>
                                        </td>
                                        <td style="padding: 10px 12px;">
                                            <strong style="color:#ef4444;">PKR <%# Convert.ToDecimal(Eval("EstFine")).ToString("N0") %></strong>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                            <asp:Panel ID="pnlNoOverdues" runat="server" Visible="false">
                                <tr>
                                    <td colspan="5" style="text-align:center;padding:24px;color:#64748b;">
                                        <asp:Literal ID="litNoRecordsMsg" runat="server" Text="Excellent! No overdue loans checked out in the system currently." />
                                    </td>
                                </tr>
                            </asp:Panel>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Right Column: Physical Rack Utilization -->
    <div style="flex: 1; min-width: 320px; box-sizing: border-box;">
        <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 1px 2px 0 rgba(0,0,0,0.05); overflow: hidden; width: 100%; height: 420px; display: flex; flex-direction: column;">
            <!-- Header -->
            <div style="padding: 12px 20px; background-color: #f8fafc; border-bottom: 1px solid #e2e8f0; font-weight: 700; font-size: 13.5px; color: #0f1e36; flex: 0 0 auto;">
                <span>Physical Shelf Units Utilization</span>
            </div>
            <!-- Scrollable Body -->
            <div class="scrollable-body" style="padding: 16px 20px; overflow-y: auto; flex: 1 1 auto; box-sizing: border-box; width: 100%;">
                <div style="display: flex; flex-direction: column; gap: 12px; width: 100%;">
                    <asp:Repeater ID="rptRackOccupancy" runat="server">
                        <ItemTemplate>
                            <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px 14px; width: 100%; box-sizing: border-box;">
                                <div style="display: flex; justify-content: space-between; font-size: 12.5px; font-weight: 600; color: #0f1e36; margin-bottom: 6px;">
                                    <div>
                                        <%# Eval("UnitCode") %> - Rack <%# Eval("RackNo") %>
                                        <div style="font-size: 10.5px; color: #64748b; font-weight: 400; margin-top: 2px;">Address: <%# Eval("FullAddress") %></div>
                                    </div>
                                    <div style='font-size: 11.5px; font-weight: 700; color: <%# GetOccupancyColor(Convert.ToDouble(Eval("OccupancyPct"))) %>'>
                                        <%# Eval("OccupancyPct") %>% Full
                                    </div>
                                </div>
                                <div style="height: 8px; background-color: #e2e8f0; border-radius: 4px; overflow: hidden; position: relative; width: 100%;">
                                    <div style='height: 100%; border-radius: 4px; transition: width 0.8s ease-out; width: <%# Eval("OccupancyPct") %>%; background-color: <%# GetOccupancyColor(Convert.ToDouble(Eval("OccupancyPct"))) %>'>
                                    </div>
                                </div>
                                <div style="font-size:10.5px;color:#64748b;margin-top:6px;display:flex;justify-content:space-between">
                                    <span>Subject: <strong><%# (Eval("SubjectTag") == DBNull.Value || Eval("SubjectTag") == null) ? "General" : Eval("SubjectTag") %></strong></span>
                                    <span>Copies: <strong><%# Eval("UsedSlots") %> / <%# Eval("TotalSlots") %></strong></span>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>
    </div>
</div>

</asp:Content>
