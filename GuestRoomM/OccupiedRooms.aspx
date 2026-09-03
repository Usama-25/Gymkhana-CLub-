<%@ Page Title="Occupied Rooms Status" Language="C#" MasterPageFile="SiteGuestroom.master" AutoEventWireup="true" CodeFile="OccupiedRooms.aspx.cs" Inherits="GuestRoomApp.GuestRoomM.OccupiedRooms" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .status-card {
            background: #ffffff;
            border: 1px solid #e0e0e0;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.05);
            margin-bottom: 24px;
            overflow: hidden;
            transition: transform 0.2s;
        }

        .status-header {
            background: linear-gradient(135deg, #1e3a5f 0%, #2d4b73 100%);
            color: white;
            padding: 16px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .status-header h2 {
            margin: 0;
            font-size: 1.25rem;
            font-weight: 700;
            letter-spacing: 0.5px;
        }

        .search-box {
            padding: 20px 24px;
            background: #f8f9fa;
            border-bottom: 1px solid #eee;
            display: flex;
            gap: 12px;
            align-items: center;
        }

        .search-input {
            flex: 1;
            padding: 10px 16px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 14px;
            transition: all 0.3s;
        }

        .search-input:focus {
            border-color: #1e3a5f;
            box-shadow: 0 0 0 3px rgba(30, 58, 95, 0.1);
            outline: none;
        }

        .btn-refresh {
            background: #1e3a5f;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .btn-refresh:hover {
            background: #2d4b73;
            transform: translateY(-1px);
        }

        .room-grid {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
        }

        .room-grid th {
            background: #f1f5f9;
            color: #475569;
            font-weight: 600;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 14px 20px;
            text-align: left;
            border-bottom: 2px solid #e2e8f0;
        }

        .room-grid td {
            padding: 16px 20px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 14px;
            color: #1e293b;
        }

        .room-grid tr:hover {
            background-color: #f8fafc;
        }

        .badge {
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .badge-room {
            background: #e0f2fe;
            color: #0369a1;
        }

        .badge-occupied {
            background: #fef3c7;
            color: #92400e;
        }

        .action-link {
            color: #1e3a5f;
            text-decoration: none;
            font-weight: 600;
            font-size: 13px;
            margin-right: 12px;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .action-link:hover {
            color: #c5a572;
            text-decoration: underline;
        }

        .empty-state {
            padding: 60px;
            text-align: center;
            color: #64748b;
        }

        .empty-state i {
            font-size: 48px;
            margin-bottom: 16px;
            color: #cbd5e1;
        }
    </style>
</asp:Content>

<asp:Content ID="ContentTitle" ContentPlaceHolderID="PageTitle" runat="server">
    Occupied Rooms Status
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding: 24px;">
        <div class="status-card">
            <div class="status-header">
                <h2><i class="fas fa-bed"></i> Current Occupancy Status</h2>
                <asp:Label ID="lblTotalOccupied" runat="server" CssClass="badge badge-occupied" Text="0 Rooms Occupied"></asp:Label>
            </div>

            <div class="search-box no-print">
                <i class="fas fa-search" style="color: #94a3b8;"></i>
                <asp:TextBox ID="txtSearch" runat="server"
    placeholder="Search by Room No or Guest Name..."
    AutoPostBack="true"
    OnTextChanged="btnSearch_Click"
    style="padding:8px 14px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; outline:none; width:280px;">
</asp:TextBox>
                <asp:LinkButton ID="btnSearch" runat="server" OnClick="btnSearch_Click" CssClass="btn-refresh">
                    <i class="fas fa-filter"></i> Filter
                </asp:LinkButton>
                <asp:LinkButton ID="btnRefresh" runat="server" OnClick="btnRefresh_Click" CssClass="btn-refresh" style="background: #64748b;">
                    <i class="fas fa-sync-alt"></i> Refresh
                </asp:LinkButton>
            </div>

            <asp:GridView ID="gvOccupiedRooms" runat="server"
    AutoGenerateColumns="false"
    GridLines="None"
    OnRowDataBound="gvOccupiedRooms_RowDataBound"
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
        <div style="padding:48px; text-align:center; color:#7a7a7a; background:#fff;">
            <i class="fas fa-door-open" style="font-size:3rem; color:#e0d5c5; margin-bottom:15px; display:block;"></i>
            <p style="margin:0; font-size:0.88rem;">No rooms are currently occupied.</p>
        </div>
    </EmptyDataTemplate>

    <Columns>

        <%-- Room No --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Room No</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px;">
                    <span style="background:#1A1A2E; color:#C9A84C; padding:4px 12px; border-radius:6px; font-weight:800; font-size:0.88rem; font-family:'Courier New',monospace; letter-spacing:1px;">
                        <%# Eval("RoomNo") %>
                    </span>
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
                <div style="padding:12px 15px; font-weight:700; color:#1e293b; font-size:0.88rem;"><%# Eval("GuestName") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Member / Guest Of --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Member / Guest Of</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px;">
                    <span style="color:#1e3a5f; font-weight:600; font-size:0.88rem;"><%# Eval("GuestOf") %></span>
                    <span style="font-size:0.75rem; background:#f1f5f9; padding:2px 6px; border-radius:4px; color:#475569; margin-left:4px;">
                        <%# Eval("MembershipNo") %>
                    </span>
                    <br />
                    <small style="color:#64748b; font-size:0.75rem;"><%# Eval("ClubName") %></small>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Check-In Date --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Check-In Date</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; color:#1e293b; font-size:0.88rem;">
                    <%# Convert.ToDateTime(Eval("AllocatedDate")).ToString("dd-MMM-yyyy HH:mm") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Expected Checkout --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Expected Checkout</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; color:#1e293b; font-size:0.88rem;">
                    <%# Convert.ToDateTime(Eval("ExpectedCheckOut")).ToString("dd-MMM-yyyy") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Stay Duration --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Stay Duration</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; font-weight:600; color:#1e293b; font-size:0.88rem;">
                    <%# Eval("Nights") %> Night(s)
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Actions --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" Width="200px" CssClass="no-print" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Actions</span>
            </HeaderTemplate>
            <ItemStyle CssClass="no-print" />
            <ItemTemplate>
                <div style="padding:8px 15px; display:flex; gap:8px; flex-wrap:wrap;">
                    <a href='<%# "GuestLedger.aspx?ResNo=" + Eval("ReservationNo") %>'
                        target="_blank"
                        style="background:#e3f2fd; color:#1565C0; border:1px solid #90caf9; padding:5px 12px; border-radius:6px; font-size:0.75rem; font-weight:600; text-decoration:none; display:inline-flex; align-items:center; gap:5px;">
                        <i class="fas fa-list-alt"></i> Ledger
                    </a>
                    <a href='<%# "ManageBills.aspx?ResNo=" + Eval("ReservationNo") %>'
                        target="_blank"
                        style="background:linear-gradient(135deg,#C9A84C,#8B5E3C); color:#fff; padding:5px 12px; border-radius:6px; font-size:0.75rem; font-weight:600; text-decoration:none; display:inline-flex; align-items:center; gap:5px;">
                        <i class="fas fa-file-invoice-dollar"></i> Manage Bill
                    </a>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

    </Columns>
</asp:GridView>
        </div>
    </div>
</asp:Content>
