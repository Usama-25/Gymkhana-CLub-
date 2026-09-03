<%@ Page Title="Room Extension Report" Language="C#" MasterPageFile="SiteGuestroom.master" 
    AutoEventWireup="true" CodeFile="RoomExtensionReport.aspx.cs" 
    Inherits="GuestRoomApp.GuestRoomM.RoomExtensionReport" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .kpi-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px; }
    .form-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px; background: linear-gradient(90deg, #C9A84C, #8B5E3C); border-radius: 10px 10px 0 0; }
    .form-control:focus { border-color: #C9A84C !important; outline: none; box-shadow: 0 0 0 3px rgba(201,168,76,0.15); }
    
    .data-table { width: 100%; border-collapse: collapse; background: #fff; font-size: 0.88rem; }
    .data-table thead th { position: sticky; top: 0; z-index: 5; background: #1A1A2E; color: #fff; font-weight: 700; text-transform: uppercase; font-size: 0.72rem; letter-spacing: 0.5px; padding: 12px 15px; border-bottom: 2px solid #e2e8f0; text-align: left; }
    .data-table td { padding: 12px 15px; border-bottom: 1px solid #f1f5f9; color: #1e293b; }
    .data-table tr:hover { background: #f8fafc; }

    .btn-action { padding: 6px 14px; border-radius: 6px; font-size: 0.75rem; font-weight: 700; cursor: pointer; border: none; transition: all 0.2s; display: inline-flex; align-items: center; gap: 5px; }
    
    .badge-approved { padding: 4px 10px; border-radius: 12px; font-size: .72rem; font-weight: 700; background: #e8f5e9; color: #2e7d32; border: 1px solid #a5d6a7; }
    .badge-pending { padding: 4px 10px; border-radius: 12px; font-size: .72rem; font-weight: 700; background: #fff3e0; color: #e65100; border: 1px solid #ffcc80; }
    .badge-rejected { padding: 4px 10px; border-radius: 12px; font-size: .72rem; font-weight: 700; background: #fce4ec; color: #c62828; border: 1px solid #f8bbd0; }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
<div style="width: 100%; padding: 18px 22px; background: #F7F3EE; font-family: 'Segoe UI', sans-serif; min-height: 100vh;">

    <%-- PAGE HEADER --%>
    <div style="background: linear-gradient(135deg, #1A1A2E 0%, #2d2d5e 100%); color: #fff; padding: 16px 26px; border-radius: 10px; margin-bottom: 18px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 4px 15px rgba(0,0,0,0.2);">
        <div>
            <h3 style="margin: 0; font-size: 1.35rem; letter-spacing: 1px;"><i class="fas fa-history" style="color:#C9A84C; margin-right:8px;"></i> Room Extension Report</h3>
            <div style="font-size: .77rem; color: #E8D5A3; margin-top: 3px; opacity: 0.9;">View and audit all stay extension requests</div>
        </div>
        <div>
            <asp:LinkButton ID="btnPrintReport" runat="server" OnClick="btnPrintReport_Click" CssClass="btn-action" style="background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: #fff; margin-right: 8px; padding: 8px 16px;">
                <i class="fas fa-print"></i> Print Report
            </asp:LinkButton>
            <asp:LinkButton ID="btnRefresh" runat="server" OnClick="btnSearch_Click" CssClass="btn-action" style="background: rgba(255,255,255,0.1); color: #fff; border: 1px solid rgba(255,255,255,0.2); padding: 8px 16px;">
                <i class="fas fa-sync-alt"></i> Refresh
            </asp:LinkButton>
        </div>
    </div>

    <asp:Label ID="lblMessage" runat="server" CssClass="alert" />

    <%-- FILTER SECTION --%>
    <div class="form-card" style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 18px 22px; margin-bottom: 16px; position: relative;">
        <div style="display: flex; flex-wrap: wrap; align-items: flex-end; gap: 12px;">
            <div style="display: flex; flex-direction: column; gap: 4px;">
                <label style="font-size: .81rem; font-weight: 600; color: #1A1A2E;">From Date</label>
                <asp:TextBox ID="txtFromDate" runat="server" TextMode="Date" 
                    style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; min-width:160px;" />
            </div>
            <div style="display: flex; flex-direction: column; gap: 4px;">
                <label style="font-size: .81rem; font-weight: 600; color: #1A1A2E;">To Date</label>
                <asp:TextBox ID="txtToDate" runat="server" TextMode="Date"
                    style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; min-width:160px;" />
            </div>
            <div style="display: flex; flex-direction: column; gap: 4px; flex: 1;">
                <label style="font-size: .81rem; font-weight: 600; color: #1A1A2E;">Search (Res #, Guest Name)</label>
                <asp:TextBox ID="txtSearch" runat="server" placeholder="Enter keyword..."
                    style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; width: 100%;" />
            </div>
            <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click"
                style="background: #1A1A2E; color: #fff; border: none; padding: 9px 22px; border-radius: 7px; font-size: .87rem; font-weight: 600; cursor: pointer;" />
        </div>
    </div>

    <%-- DATA GRID --%>
    <div class="form-card" style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 18px 22px; margin-bottom: 16px; position: relative;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
            <div style="font-size: .72rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #8B5E3C;"> Extension History</div>
            <div style="font-size: .75rem; color: #7a7a7a;">
                Total <asp:Label ID="lblCount" runat="server" Text="0" Font-Bold="true" /> records found
            </div>
        </div>

        <div style="overflow-x: auto; border-radius: 8px; border: 1px solid #e0d5c5;">
            <asp:GridView ID="gvExtensions" runat="server"
    AutoGenerateColumns="False"
    GridLines="None"
    style="width:100%; border-collapse:collapse; font-size:0.88rem; background:#fff;"
    HeaderStyle-BackColor="#1A1A2E"
    HeaderStyle-ForeColor="#C9A84C"
    HeaderStyle-Font-Bold="True"
    HeaderStyle-Font-Size="X-Small"
    RowStyle-BackColor="#FFFFFF"
    RowStyle-ForeColor="#1e293b"
    AlternatingRowStyle-BackColor="#F8F9FA"
    AlternatingRowStyle-ForeColor="#1e293b">

    <EmptyDataTemplate>
        <div style="padding:40px; text-align:center; color:#7a7a7a; background:#fff;">
            <i class="fas fa-search" style="font-size:3rem; color:#e0d5c5; margin-bottom:15px; display:block;"></i>
            No extension records found for the selected criteria.
        </div>
    </EmptyDataTemplate>

    <Columns>

        <%-- Req Date --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Req Date</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; color:#1e293b; font-size:0.88rem;">
                    <%# Convert.ToDateTime(Eval("RequestDate")).ToString("dd-MMM-yyyy HH:mm") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Res # --%>
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

        <%-- Room --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Room</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; text-align:center;">
                    <span style="background:#1A1A2E; color:#C9A84C; padding:3px 10px; border-radius:6px; font-weight:700; font-size:0.8rem; font-family:'Courier New',monospace;">
                        <%# Eval("RoomNo") %>
                    </span>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Old Date --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Old Date</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; color:#7a7a7a; font-size:0.88rem; text-decoration:line-through;">
                    <%# Convert.ToDateTime(Eval("CurrentToDate")).ToString("dd-MMM-yyyy") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- New Date --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">New Date</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; font-weight:700; color:#2e7d32; font-size:0.88rem;">
                    <%# Convert.ToDateTime(Eval("NewToDate")).ToString("dd-MMM-yyyy") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Status --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Status</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; text-align:center;">
                    <span style='<%# GetExtensionStatusStyle(Eval("Status").ToString()) %>'>
                        <%# Eval("Status") %>
                    </span>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- By --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">By</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; color:#1e293b; font-size:0.88rem;"><%# Eval("ApprovedBy") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Remarks --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Remarks</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; color:#64748b; font-size:0.85rem; font-style:italic;"><%# Eval("Remarks") %></div>
            </ItemTemplate>
        </asp:TemplateField>

    </Columns>
</asp:GridView>
        </div>
    </div>

    <%-- ════════ PRINT REPORT PANEL (hidden on screen) ════════ --%>
    <div id="printReportPanel" style="display: none;">
        <style>
            @media print {
                body * { visibility: hidden !important; }
                #printReportPanel, #printReportPanel * { visibility: visible !important; }
                #printReportPanel { display: block !important; position: absolute; left: 0; top: 0; width: 100%; padding: 20px; background: #fff; }
                .rpt-table { width: 100%; border-collapse: collapse; margin-top: 20px; font-size: 9pt; }
                .rpt-table th { background: #1A1A2E !important; color: #fff !important; padding: 8px; text-align: left; -webkit-print-color-adjust: exact; }
                .rpt-table td { padding: 8px; border-bottom: 1px solid #ddd; }
            }
        </style>
        <table style="width:100%;">
            <tr>
                <td style="width:80px;"><img src="images/lahore_gymkhana_logo1.png" style="height:60px;"/></td>
                <td>
                    <div style="font-size:16pt; font-weight:800;">Lahore Gymkhana Club</div>
                    <div style="font-size:10pt; color:#666;">Stay Extension Audit Report</div>
                </td>
                <td style="text-align:right;">
                    <div style="font-size:10pt;">Period: <strong><asp:Label ID="lblPrintPeriod" runat="server" /></strong></div>
                    <div style="font-size:9pt; color:#888;">Printed: <asp:Label ID="lblPrintTime" runat="server" /></div>
                </td>
            </tr>
        </table>
        <hr style="border:1px solid #1A1A2E; margin:15px 0;"/>
        
        <asp:GridView ID="gvExtensionsPrint" runat="server"
    AutoGenerateColumns="False"
    GridLines="None"
    style="width:100%; border-collapse:collapse; font-size:0.88rem; background:#fff;"
    HeaderStyle-BackColor="#1A1A2E"
    HeaderStyle-ForeColor="#C9A84C"
    HeaderStyle-Font-Bold="True"
    HeaderStyle-Font-Size="X-Small"
    RowStyle-BackColor="#FFFFFF"
    RowStyle-ForeColor="#1e293b"
    AlternatingRowStyle-BackColor="#F8F9FA"
    AlternatingRowStyle-ForeColor="#1e293b">

    <EmptyDataTemplate>
        <div style="padding:20px; text-align:center; color:#7a7a7a; background:#fff; font-size:0.85rem;">
            No records found.
        </div>
    </EmptyDataTemplate>

    <Columns>

        <%-- Date --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Date</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; color:#1e293b; font-size:0.88rem;">
                    <%# Convert.ToDateTime(Eval("RequestDate")).ToString("dd-MMM-yy HH:mm") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Res # --%>
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

        <%-- Room --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Room</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; text-align:center;">
                    <span style="background:#1A1A2E; color:#C9A84C; padding:3px 10px; border-radius:6px; font-weight:700; font-size:0.8rem; font-family:'Courier New',monospace;">
                        <%# Eval("RoomNo") %>
                    </span>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Old Date --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Old Date</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; color:#7a7a7a; font-size:0.88rem; text-decoration:line-through;">
                    <%# Convert.ToDateTime(Eval("CurrentToDate")).ToString("dd-MMM") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- New Date --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">New Date</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; font-weight:700; color:#2e7d32; font-size:0.88rem;">
                    <%# Convert.ToDateTime(Eval("NewToDate")).ToString("dd-MMM") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Status --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Status</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; text-align:center;">
                    <span style='<%# GetExtensionStatusStyle(Eval("Status").ToString()) %>'>
                        <%# Eval("Status") %>
                    </span>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- By --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">By</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; color:#1e293b; font-size:0.88rem;"><%# Eval("ApprovedBy") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Remarks --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Remarks</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; color:#64748b; font-size:0.85rem; font-style:italic;"><%# Eval("Remarks") %></div>
            </ItemTemplate>
        </asp:TemplateField>

    </Columns>
</asp:GridView>

        <div style="margin-top:30px; font-size:8pt; text-align:center; color:#999;">
            *** End of Stay Extension Report ***
        </div>
    </div>

    <script type="text/javascript">
        function triggerPrint() {
            var hf = document.getElementById('<%= hfPrint.ClientID %>');
            if (hf && hf.value === '1') {
                hf.value = '0';
                window.print();
            }
        }
        window.onload = triggerPrint;
    </script>
    <asp:HiddenField ID="hfPrint" runat="server" Value="0" />

</div>
</asp:Content>
