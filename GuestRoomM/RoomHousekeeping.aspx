<%@ Page Title="Housekeeping Management" Language="C#" MasterPageFile="SiteGuestroom.master" AutoEventWireup="true" CodeFile="RoomHousekeeping.aspx.cs" Inherits="GuestRoomApp.GuestRoomM.RoomHousekeeping" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    /* Rules that require pseudo-elements or media queries */
    .kpi-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px; }
    .card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px; background: linear-gradient(90deg, #C9A84C, #8B5E3C); }
    .btn-clean:hover { transform: translateY(-1px); opacity: .88; }
    .btn-gold:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(201,168,76,0.35); }
    .btn-outline:hover { background: #C9A84C; color: #fff; }
    .form-control:focus { border-color: #C9A84C; outline: none; box-shadow: 0 0 0 3px rgba(201,168,76,0.15); }
    .res-pager a:hover { background: #faf7f2; border-color: #C9A84C; color: #8B5E3C; }
    
    .dirty-tag::before { content: ''; width: 5px; height: 5px; border-radius: 50%; background: #c62828; flex-shrink: 0; }
    .clean-tag::before { content: ''; width: 5px; height: 5px; border-radius: 50%; background: #2e7d32; flex-shrink: 0; }
    .inprogress-tag::before { content: ''; width: 5px; height: 5px; border-radius: 50%; background: #e65100; flex-shrink: 0; }

    /* Data Table Styling */
    .data-table { width: 100%; border-collapse: collapse; background: #fff; font-size: 0.88rem; }
    .data-table thead th { position: sticky; top: 0; z-index: 5; background: #1A1A2E; color: #fff; font-weight: 700; text-transform: uppercase; font-size: 0.72rem; letter-spacing: 0.5px; padding: 12px 15px; border-bottom: 2px solid #e2e8f0; text-align: left; white-space: nowrap; }
    .data-table td { padding: 12px 15px; border-bottom: 1px solid #f1f5f9; color: #1e293b; }
    .data-table tr:hover { background: #f8fafc; }

    /* Pager Styling */
    .res-pager span { background:#1A1A2E !important; border-color:#1A1A2E !important; color:#C9A84C !important; padding: 5px 12px; border-radius: 4px; }
    .res-pager a { padding: 5px 12px; border: 1px solid #e0d5c5; border-radius: 4px; color: #1A1A2E; text-decoration: none; margin: 0 2px; }
</style>
</asp:Content>



<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding: 16px 20px;" class="hk-container">
        
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 10px; margin-bottom: 14px;" class="kpi-strip">
            <div style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:14px 16px; display:flex; align-items:center; gap:12px; position:relative; overflow:hidden; border-left:4px solid #ef4444;" class="kpi-card dirty">
                <span style="font-size: .68rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: #7a7a7a;" class="kpi-lab">Dirty Rooms</span>
                <span style="font-size: 1.5rem; font-weight: 800; color: #1A1A2E; line-height: 1.1;" class="kpi-num"><asp:Label ID="lblDirtyCount" runat="server" Text="0" /></span>
            </div>
            <div style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:14px 16px; display:flex; align-items:center; gap:12px; position:relative; overflow:hidden; border-left:4px solid #e65100;" class="kpi-card maintenance">
                <span style="font-size: .68rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: #7a7a7a;" class="kpi-lab">Under Maintenance</span>
                <span style="font-size: 1.5rem; font-weight: 800; color: #1A1A2E; line-height: 1.1;" class="kpi-num"><asp:Label ID="lblMaintenanceCount" runat="server" Text="0" /></span>
            </div>
            <div style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:14px 16px; display:flex; align-items:center; gap:12px; position:relative; overflow:hidden; border-left:4px solid #f59e0b;" class="kpi-card progress">
                <span style="font-size: .68rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: #7a7a7a;" class="kpi-lab">Pending Cleanup</span>
                <span style="font-size: 1.5rem; font-weight: 800; color: #1A1A2E; line-height: 1.1;" class="kpi-num"><asp:Label ID="lblPendingCount" runat="server" Text="0" /></span>
            </div>
            <div style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:14px 16px; display:flex; align-items:center; gap:12px; position:relative; overflow:hidden; border-left:4px solid #10b981;" class="kpi-card clean">
                <span style="font-size: .68rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: #7a7a7a;" class="kpi-lab">Available / Clean</span>
                <span style="font-size: 1.5rem; font-weight: 800; color: #1A1A2E; line-height: 1.1;" class="kpi-num"><asp:Label ID="lblCleanCount" runat="server" Text="0" /></span>
            </div>
        </div>

        <asp:Label ID="lblMessage" runat="server" />

        <asp:UpdatePanel ID="upHousekeeping" runat="server">
            <ContentTemplate>
                <div style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; margin-bottom:14px; position:relative; overflow:hidden;" class="card">
                    <div style="padding:14px 20px; border-bottom:1px solid #e0d5c5; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px;" class="card-header">
                        <h4 style="margin:0; font-size:.95rem; font-weight:700; color:#1A1A2E;"><i class="fas fa-broom"></i> Pending Room Maintenance</h4>
                        <div style="font-size:0.8rem; color:#64748b;">List of rooms flagged for cleaning after checkout.</div>
                    </div>
                    
                    <div style="padding:0;">
                       

<asp:GridView ID="gvDirtyRooms" runat="server"
    AutoGenerateColumns="false"
    GridLines="None"
    OnRowCommand="gvDirtyRooms_RowCommand"
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

        <%-- Room Identity --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Room Identity</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px;">
                    <div style="font-weight:800; color:#1e3a5f; font-size:1.1rem;">Room <%# Eval("RoomNo") %></div>
                    <div style="font-size:0.75rem; color:#64748b; margin-top:2px;"><%# Eval("RoomType") %> | Floor <%# Eval("FloorNo") %></div>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Current State --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Current State</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px;">
                    <%# Eval("Status").ToString() == "Maintenance" ?
                        "<span style='background:#fff3e0; color:#e65100; padding:3px 10px; border-radius:99px; font-weight:700; font-size:.71rem; display:inline-flex; align-items:center; gap:4px;'><span style=\"width:5px;height:5px;border-radius:50%;background:#e65100;display:inline-block;flex-shrink:0;\"></span><i class=\"fas fa-tools\"></i> MAINTENANCE</span>" :
                        "<span style='background:#fce4ec; color:#b71c1c; padding:3px 10px; border-radius:99px; font-weight:700; font-size:.71rem; display:inline-flex; align-items:center; gap:4px;'><span style=\"width:5px;height:5px;border-radius:50%;background:#c62828;display:inline-block;flex-shrink:0;\"></span><i class=\"fas fa-exclamation-circle\"></i> DIRTY</span>"
                    %>
                    <div style="font-size:0.75rem; color:#64748b; margin-top:5px; max-width:250px; white-space:normal;">
                        <%# Eval("ShiftReason") != DBNull.Value && !string.IsNullOrEmpty(Eval("ShiftReason").ToString()) ? "<strong>Reason:</strong> " + Eval("ShiftReason").ToString() + "<br/>" : "" %>
                        <%# Eval("InternalRemark") != DBNull.Value && !string.IsNullOrEmpty(Eval("InternalRemark").ToString()) ? "<strong>Remark:</strong> " + Eval("InternalRemark").ToString() : "" %>
                    </div>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Last Checkout --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Last Checkout</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px;">
                    <div style="font-weight:600; color:#1e293b; font-size:0.88rem;">
                        <%# Convert.ToDateTime(Eval("LastReleased")).ToString("dd-MMM-yyyy") %>
                    </div>
                    <div style="font-size:0.75rem; color:#64748b; margin-top:2px;">
                        <%# Convert.ToDateTime(Eval("LastReleased")).ToString("hh:mm tt") %>
                    </div>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Action --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Action</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:8px 15px;">
                    <asp:Button ID="btnClean" runat="server"
                        Text="Mark Clean & Available"
                        CommandName="MakeAvailable"
                        CommandArgument='<%# Eval("RoomNo") %>'
                        OnClientClick="return confirm('Confirm room cleaning completion? Room will be added back to available inventory.');"
                        style="background:linear-gradient(135deg,#2e7d32,#1b5e20); color:#fff; border:none; padding:5px 14px; border-radius:6px; font-weight:700; font-size:.75rem; cursor:pointer;" />
                </div>
            </ItemTemplate>
        </asp:TemplateField>

    </Columns>

    <EmptyDataTemplate>
        <div style="padding:50px; text-align:center; color:#64748b; background:#fff;">
            <i class="fas fa-check-double" style="font-size:3rem; color:#10b981; margin-bottom:15px; display:block;"></i>
            <h4 style="margin:0; color:#1A1A2E;">All rooms are clean and ready!</h4>
        </div>
    </EmptyDataTemplate>

</asp:GridView>

                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>

    </div>
</asp:Content>





