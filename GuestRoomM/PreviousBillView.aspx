<%@ Page Title="Previous Bill View" Language="C#" MasterPageFile="SiteGuestroom.master" AutoEventWireup="true" CodeFile="PreviousBillView.aspx.cs" Inherits="GuestRoomApp.GuestRoomM.PreviousBillView" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <style>
        .form-card {
            background: #ffffff;
            border: 1px solid #e0d5c5;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            position: relative;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        }
        .form-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 4px;
            background: linear-gradient(90deg, #C9A84C, #8B5E3C);
            border-radius: 10px 10px 0 0;
        }
        .section-title {
            font-size: .75rem;
            font-weight: 700;
            letter-spacing: 2px;
            text-transform: uppercase;
            color: #8B5E3C;
            margin-bottom: 15px;
            padding-bottom: 8px;
            border-bottom: 1px solid #e0d5c5;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .data-table { width: 100%; border-collapse: collapse; font-size: .85rem; }
        .data-table thead th {
            background: #1A1A2E;
            color: #fff;
            padding: 10px 12px;
            text-align: left;
            font-weight: 600;
            text-transform: uppercase;
            font-size: .7rem;
        }
        .data-table tbody td {
            padding: 9px 12px;
            border-bottom: 1px solid #f1f5f9;
            color: #334155;
        }
        .data-table tbody tr:hover { background: #fdfaf3; }
        .btn-gold {
            background: linear-gradient(135deg, #C9A84C, #8B5E3C);
            color: #fff; border: none;
            padding: 8px 18px; border-radius: 6px;
            font-weight: 600; cursor: pointer;
            font-size: .8rem; transition: all 0.2s;
        }
        .btn-gold:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(201,168,76,0.4); }
        .fc {
            padding: 10px 12px;
            border: 1.5px solid #e0d5c5;
            border-radius: 8px; font-size: .9rem;
            transition: border-color .2s;
        }
        .fc:focus { border-color: #C9A84C; outline: none; box-shadow: 0 0 0 3px rgba(201,168,76,0.1); }

        /* ── STATUS BADGES ── */
        .badge {
            padding: 3px 10px; border-radius: 20px;
            font-size: .68rem; font-weight: 700;
            text-transform: uppercase; white-space: nowrap;
        }
        .badge-settled  { background:#e8f5e9; color:#2e7d32; border:1px solid #c8e6c9; }
        .badge-unsettled{ background:#fff3e0; color:#e65100; border:1px solid #ffe0b2; }
        .badge-draft    { background:#e3f2fd; color:#1565C0; border:1px solid #90caf9; }
        .badge-refunded { background:#fce4ec; color:#c62828; border:1px solid #f8bbd0; }

        /* ── DETAIL PANEL ── */
        #pnlDetail {
            background:#fff;
            border:1px solid #e0d5c5;
            border-radius:10px;
            padding:20px;
            margin-bottom:20px;
            position:relative;
            box-shadow:0 4px 12px rgba(0,0,0,.06);
            display:none;
        }
        #pnlDetail::before {
            content:'';position:absolute;top:0;left:0;right:0;height:4px;
            background:linear-gradient(90deg,#2d2d5e,#1A1A2E);
            border-radius:10px 10px 0 0;
        }
        .detail-grid { display:grid; grid-template-columns:1fr 1fr 1fr; gap:12px; margin-bottom:18px; }
        .dg-card {
            background:#f8f9fa; border-radius:8px; padding:10px 14px;
            border-left:3px solid #C9A84C;
        }
        .dg-label { font-size:.68rem; color:#8B5E3C; font-weight:700; text-transform:uppercase; }
        .dg-val   { font-size:.95rem; font-weight:700; color:#1A1A2E; margin-top:3px; }
        .amount-debit  { color:#c62828; }
        .amount-credit { color:#2e7d32; }

        /* ── SEARCH BAR ── */
        .search-bar {
            display:flex; gap:10px; align-items:center; flex-wrap:wrap;
        }
        .search-bar input[type=text] { flex:1; min-width:200px; }
        
        /* ── UNSETTLED HIGHLIGHT ── */
        tr.unsettled-row td { background:#fff8f0 !important; }
        tr.unsettled-row:hover td { background:#fff3e0 !important; }

        /* Print handled via popup window — no @media print rules needed here */
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
<div style="width:100%; min-height:100vh; background:#F7F3EE; padding:20px; box-sizing:border-box; font-family:'Inter',sans-serif;">

    <%-- ══ HEADER ══ --%>
    <div class="no-print" style="background:linear-gradient(135deg,#1A1A2E,#2d2d5e); border-radius:12px; padding:18px 25px; margin-bottom:20px; display:flex; align-items:center; justify-content:space-between; box-shadow:0 4px 15px rgba(0,0,0,0.2);">
        <div>
            <h1 style="font-size:1.4rem; font-weight:700; color:#fff; margin:0; letter-spacing:1px;">&#9670; Previous Bill View</h1>
            <p style="font-size:.8rem; color:#E8D5A3; margin:5px 0 0 0;">Enter Reservation No. To Find Settled And Unsettled Bills </p>
        </div>
        <div style="display:flex; gap:10px; align-items:center; flex-wrap:wrap;">
    <asp:TextBox ID="txtSearch" runat="server"
        placeholder="Res No / Bill No / Member No / Guest..."
        style="width:300px; padding:8px 14px; background:rgba(255,255,255,0.1); border:1px solid rgba(255,255,255,0.25); border-radius:7px; color:#fff; font-size:.87rem; font-family:'Segoe UI',sans-serif; outline:none;" />
    <asp:Button ID="btnSearch" runat="server"
        Text="Search"
        OnClick="btnSearch_Click"
        style="background:linear-gradient(135deg,#C9A84C,#8B5E3C); color:#fff; border:none; padding:8px 22px; border-radius:7px; font-size:.87rem; font-weight:600; cursor:pointer; letter-spacing:.3px;" />
    <asp:Button ID="btnClear" runat="server"
        Text="Clear"
        OnClick="btnClear_Click"
        style="background:rgba(255,255,255,0.15); color:#fff; border:1px solid rgba(255,255,255,0.3); padding:8px 16px; border-radius:7px; font-size:.87rem; font-weight:600; cursor:pointer;" />
</div>
    </div>

    <%-- ══ STATUS SUMMARY STRIP ══ --%>
    <asp:Panel ID="pnlSummary" runat="server" Visible="false" CssClass="no-print">
        <div style="display:flex; gap:14px; margin-bottom:18px; flex-wrap:wrap;">
            <div style="background:#fff; border-radius:10px; padding:12px 20px; display:flex; align-items:center; gap:12px; box-shadow:0 2px 8px rgba(0,0,0,.06); border-left:4px solid #C9A84C; flex:1; min-width:150px;">
                <i class="fas fa-file-invoice" style="font-size:1.4rem; color:#C9A84C;"></i>
                <div><div style="font-size:.68rem; color:#8B5E3C; font-weight:700; text-transform:uppercase;">Total Bills</div>
                    <div style="font-size:1.4rem; font-weight:800; color:#1A1A2E;"><asp:Label ID="lblTotalBills" runat="server">0</asp:Label></div></div>
            </div>
            <div style="background:#fff; border-radius:10px; padding:12px 20px; display:flex; align-items:center; gap:12px; box-shadow:0 2px 8px rgba(0,0,0,.06); border-left:4px solid #2e7d32; flex:1; min-width:150px;">
                <i class="fas fa-check-circle" style="font-size:1.4rem; color:#2e7d32;"></i>
                <div><div style="font-size:.68rem; color:#2e7d32; font-weight:700; text-transform:uppercase;">Settled</div>
                    <div style="font-size:1.4rem; font-weight:800; color:#1A1A2E;"><asp:Label ID="lblSettledCount" runat="server">0</asp:Label></div></div>
            </div>
            <div style="background:#fff; border-radius:10px; padding:12px 20px; display:flex; align-items:center; gap:12px; box-shadow:0 2px 8px rgba(0,0,0,.06); border-left:4px solid #e65100; flex:1; min-width:150px;">
                <i class="fas fa-exclamation-circle" style="font-size:1.4rem; color:#e65100;"></i>
                <div><div style="font-size:.68rem; color:#e65100; font-weight:700; text-transform:uppercase;">Unsettled / Draft</div>
                    <div style="font-size:1.4rem; font-weight:800; color:#1A1A2E;"><asp:Label ID="lblUnsettledCount" runat="server">0</asp:Label></div></div>
            </div>
            <div style="background:#fff; border-radius:10px; padding:12px 20px; display:flex; align-items:center; gap:12px; box-shadow:0 2px 8px rgba(0,0,0,.06); border-left:4px solid #1565C0; flex:1; min-width:150px;">
                <i class="fas fa-money-bill-wave" style="font-size:1.4rem; color:#1565C0;"></i>
                <div><div style="font-size:.68rem; color:#1565C0; font-weight:700; text-transform:uppercase;">Total Gross</div>
                    <div style="font-size:1.1rem; font-weight:800; color:#1A1A2E;">PKR <asp:Label ID="lblTotalGross" runat="server">0</asp:Label></div></div>
            </div>
        </div>
    </asp:Panel>

    <%-- ══ BILL DETAIL PANEL (shown on row click) ══ --%>
    <div id="pnlDetail">
        <div class="section-title"><i class="fas fa-receipt"></i> <span id="detailBillNo">Bill Details</span>
            <span id="detailStatusBadge" style="margin-left:auto;"></span>
        </div>
        <div class="detail-grid" id="detailGrid"></div>
        <div style="display:flex; gap:10px; margin-top:10px;">
            <button type="button" onclick="printBill()" class="btn-gold"><i class="fas fa-print"></i> Print Bill Only</button>
            <button type="button" onclick="closePnl()" style="background:#f1f5f9;border:none;padding:8px 18px;border-radius:6px;cursor:pointer;">Close</button>
        </div>
    </div>

    <%-- ══ BILLS GRID ══ --%>
    <div class="form-card no-print">
        <div class="section-title">
            <i class="fas fa-file-invoice-dollar"></i> Bills History
            <asp:Label ID="lblMsg" runat="server" style="font-size:.75rem; font-weight:400; text-transform:none; margin-left:auto; color:#64748b;"></asp:Label>
        </div>
        <div style="max-height:520px; overflow-y:auto;">
        <asp:GridView ID="gvBills" runat="server"
    AutoGenerateColumns="false"
    GridLines="None"
    OnRowCommand="gvBills_RowCommand"
    DataKeyNames="BillNo"
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
        <div style="padding:32px; text-align:center; color:#7a7a7a; background:#fff; font-size:0.88rem;">
            <i class="fas fa-file-invoice" style="font-size:2.5rem; color:#e0d5c5; margin-bottom:12px; display:block;"></i>
            No Bill Found . Search with Reservation No. 
        </div>
    </EmptyDataTemplate>

    <Columns>

        <%-- Bill No --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Bill No</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; font-weight:700; font-family:'Courier New',monospace; color:#1e293b; font-size:0.88rem;">
                    <%# Eval("BillNo") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Res No --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Res No</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; font-family:'Courier New',monospace; color:#1e293b; font-size:0.88rem;">
                    <%# Eval("ReservationNo") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Date --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Date</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; color:#1e293b; font-size:0.88rem;">
                    <%# Convert.ToDateTime(Eval("BillDate")).ToString("dd-MMM-yyyy") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Guest --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Guest</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; color:#1e293b; font-size:0.88rem;"><%# Eval("GuestName") %></div>
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

        <%-- Room --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Room</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px;">
                    <span style="background:#1A1A2E; color:#C9A84C; padding:3px 10px; border-radius:6px; font-weight:700; font-size:0.8rem; font-family:'Courier New',monospace;">
                        <%# Eval("RoomNo") %>
                    </span>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Gross Total --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:right; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Gross Total</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; text-align:right; font-weight:700; color:#1A1A2E; font-size:0.88rem;">
                    PKR <%# Eval("GrossTotal","{0:N0}") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Balance Due --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:right; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Balance Due</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; text-align:right; font-size:0.88rem;">
                    <span style='font-weight:700; color:<%# (Convert.ToDecimal(Eval("BalanceDue")) > 0) ? "#c62828" : "#2e7d32" %>'>
                        PKR <%# Eval("BalanceDue","{0:N0}") %>
                    </span>
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
                    <span style='<%# GetStatusBadgeClass(Eval("BillStatus").ToString()) %>'>
                        <%# GetStatusLabel(Eval("BillStatus").ToString()) %>
                    </span>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Action --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Action</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:8px 15px; text-align:center;">
                    <asp:LinkButton ID="btnView" runat="server"
                        CommandName="ViewBill"
                        CommandArgument='<%# Eval("BillNo") %>'
                        style="background:linear-gradient(135deg,#C9A84C,#8B5E3C); color:#fff; border:none; padding:5px 12px; border-radius:6px; font-size:.75rem; font-weight:600; text-decoration:none; cursor:pointer; display:inline-flex; align-items:center; gap:5px;">
                        <i class="fas fa-eye"></i> View
                    </asp:LinkButton>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

    </Columns>
</asp:GridView>
        </div>
    </div>

    <%-- ══ SERVICE INVOICES (shown below on bill select) ══ --%>
    <asp:Panel ID="pnlServices" runat="server" Visible="false" CssClass="no-print">
        <div class="form-card" style="border-left:4px solid #1A1A2E;">
            <div class="section-title"><i class="fas fa-concierge-bell"></i> Service Invoices &amp; Charges</div>
            <div style="max-height:350px; overflow-y:auto;">
                <asp:GridView ID="gvServices" runat="server"
    AutoGenerateColumns="false"
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
        <div style="padding:32px; text-align:center; color:#7a7a7a; background:#fff; font-size:0.88rem;">
            <i class="fas fa-concierge-bell" style="font-size:2.5rem; color:#e0d5c5; margin-bottom:12px; display:block;"></i>
            Is reservation ke liye koi service record nahi.
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
                    <%# Convert.ToDateTime(Eval("OrderDate")).ToString("dd-MMM HH:mm") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Service / Item --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Service / Item</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; color:#1e293b; font-size:0.88rem;"><%# Eval("ServiceName") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Qty --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Qty</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; text-align:center; color:#1e293b; font-size:0.88rem;"><%# Eval("Qty") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Unit Price --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:right; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Unit Price</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; text-align:right; color:#1e293b; font-size:0.88rem;">
                    PKR <%# Eval("UnitPrice","{0:N0}") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Total --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-align:right; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Total</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:12px 15px; text-align:right; font-weight:600; color:#C9A84C; font-size:0.88rem;">
                    PKR <%# (Convert.ToDecimal(Eval("UnitPrice")) * Convert.ToInt32(Eval("Qty"))).ToString("N0") %>
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
                <div style="padding:12px 15px; text-align:center; font-size:0.88rem; color:#1e293b;">
                    <%# Eval("Status") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

    </Columns>
</asp:GridView>
            </div>
        </div>
    </asp:Panel>

    <%-- ══ PRINTABLE RECEIPT ══ --%>
    <div id="receiptSlip" style="display:none; font-family:'Courier New',monospace; font-size:12px; width:100%; max-width:320px; margin:0 auto; color:#000;"></div>

</div>

<script>
    // ── Highlight unsettled rows ──
    window.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('.data-table tbody tr').forEach(function (tr) {
            var badge = tr.querySelector('.badge-unsettled, .badge-draft');
            if (badge) tr.classList.add('unsettled-row');
        });
    });

    // ── Show Bill Detail Panel ──
    function showBillDetail(data) {
        var p = document.getElementById('pnlDetail');
        document.getElementById('detailBillNo').textContent = 'Bill No: ' + data.billNo;
        document.getElementById('detailStatusBadge').innerHTML =
            '<span class="badge ' + data.badgeClass + '">' + data.statusLabel + '</span>';

        var g = document.getElementById('detailGrid');
        g.innerHTML =
            card('Reservation No',  data.resNo)   +
            card('Guest Name',      data.guest)    +
            card('Room No',         data.roomNo)   +
            card('Check In',        data.fromDate) +
            card('Check Out',       data.toDate)   +
            card('No. of Rooms',    data.rooms)    +
            card('No. of Nights',   data.nights)   +
            card('Rate / Night',    'PKR ' + fmt(data.rate)) +
            card('Room Rent',       'PKR ' + fmt(data.roomRent)) +
            card('GST / Tax',       'PKR ' + fmt(data.tax)) +
            card('Other Charges',   'PKR ' + fmt(data.other)) +
            card('Gross Total',     'PKR ' + fmt(data.gross), '#1A1A2E') +
            card('Advance Paid',    'PKR ' + fmt(data.advance), '#2e7d32') +
            card('Amount Paid',     'PKR ' + fmt(data.paid), '#2e7d32') +
            card('Balance Due',     'PKR ' + fmt(data.balance), data.balance > 0 ? '#c62828' : '#2e7d32') +
            card('Remarks',         data.remarks);

        // Printable slip
        document.getElementById('receiptSlip').innerHTML = buildSlip(data);

        p.style.display = 'block';
        p.scrollIntoView({ behavior: 'smooth' });
    }

    function card(label, val, color) {
        return '<div class="dg-card"><div class="dg-label">' + label + '</div><div class="dg-val"' +
            (color ? ' style="color:' + color + '"' : '') + '>' + (val || '—') + '</div></div>';
    }
    function fmt(v) { return Number(v || 0).toLocaleString('en-PK', { minimumFractionDigits: 0, maximumFractionDigits: 0 }); }
    function closePnl() { document.getElementById('pnlDetail').style.display = 'none'; }

    function buildSlip(d) {
        return '<div style="text-align:center;border-bottom:1px dashed #000;padding-bottom:8px;margin-bottom:8px;">' +
               '<h2 style="margin:0;font-size:14px;">LAHORE GYMKHANA CLUB</h2>' +
               '<p style="margin:2px 0;font-size:11px;">Guest Room Bill Receipt</p></div>' +
               row('Bill No:', d.billNo) + row('Status:', d.statusLabel) + row('Date:', d.date) +
               row('Res No:', d.resNo) + row('Guest:', d.guest) + row('Room:', d.roomNo) +
               '<div style="border-top:1px solid #000;margin:6px 0;"></div>' +
               row('Room Rent:', 'PKR ' + fmt(d.roomRent)) + row('GST/Tax:', 'PKR ' + fmt(d.tax)) +
               row('Other Charges:', 'PKR ' + fmt(d.other)) +
               '<div style="border-top:1px dashed #000;margin:4px 0;"></div>' +
               '<div style="display:flex;justify-content:space-between;font-weight:bold;font-size:13px;">' +
               '<span>GROSS TOTAL</span><span>PKR ' + fmt(d.gross) + '</span></div>' +
               '<div style="border-top:1px solid #000;margin:6px 0;"></div>' +
               row('Advance Paid:', 'PKR ' + fmt(d.advance)) + row('Amount Paid:', 'PKR ' + fmt(d.paid)) +
               '<div style="display:flex;justify-content:space-between;font-weight:bold;font-size:13px;">' +
               '<span>BALANCE DUE</span><span>PKR ' + fmt(d.balance) + '</span></div>' +
               '<div style="text-align:center;margin-top:12px;font-size:11px;color:#555;">' +
               '<p>Printed: ' + new Date().toLocaleString('en-PK') + '</p></div>';
    }
    function row(label, val) {
        return '<div style="display:flex;justify-content:space-between;font-size:11px;margin:2px 0;">' +
               '<span>' + label + '</span><span>' + val + '</span></div>';
    }

    // ── Print only the bill slip in a new popup window ──
    function printBill() {
        var slipHtml = document.getElementById('receiptSlip').innerHTML;
        if (!slipHtml || slipHtml.trim() === '') {
            alert('First bill "View" Then Print.');
            return;
        }
        var win = window.open('', '_blank', 'width=420,height=650,scrollbars=yes');
        win.document.write(
            '<!DOCTYPE html><html><head>' +
            '<meta charset="utf-8"><title>Bill Receipt</title>' +
            '<style>' +
            '  body { font-family: "Courier New", monospace; font-size: 12px; color:#000; margin:20px; }' +
            '  @media print { @page { margin: 8mm; size: 80mm auto; } }' +
            '</style>' +
            '</head><body>' +
            slipHtml +
            '<script>window.onload=function(){window.print();window.onafterprint=function(){window.close();}};<\/script>' +
            '</body></html>'
        );
        win.document.close();
    }
</script>

</asp:Content>
