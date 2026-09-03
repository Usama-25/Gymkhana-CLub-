<%@ Page Title="Room Shift / Transfer" Language="C#" MasterPageFile="SiteGuestroom.master" AutoEventWireup="true" CodeFile="RoomShift.aspx.cs" Inherits="GuestRoomApp.GuestRoomM.RoomShift" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
    /* Rules that require pseudo-elements or media queries */
    .card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px; background: linear-gradient(90deg, #C9A84C, #8B5E3C); }
    .form-control:focus { border-color: #C9A84C; outline: none; box-shadow: 0 0 0 3px rgba(201,168,76,0.15); }
    .res-pager a:hover { background: #faf7f2; border-color: #C9A84C; color: #8B5E3C; }
</style>
</asp:Content>

<asp:Content ID="Content" ContentPlaceHolderID="PageTitle" runat="server">
    Room Shift & Guest Transfer
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div style="padding: 18px 22px;">
        
        <asp:UpdatePanel ID="upMain" runat="server">
            <ContentTemplate>
                
                <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; margin-bottom: 16px; position: relative; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.06);">
                    <div style="padding: 18px 25px; border-bottom: 1px solid #e0d5c5; background: #faf7f2; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                        <h3 style="margin:0;"><i class="fas fa-exchange-alt"></i> Execute Room Shift</h3>
                        <asp:Label ID="lblMessage" runat="server" />
                    </div>
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 30px; padding: 25px;">
                        <!-- FROM SOURCE -->
                        <div style="border-right: 1px dashed #e2e8f0; padding-right:30px;">
                            <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 15px;">
                                <label>From: Current Occupied Room</label>
                                <asp:DropDownList ID="ddlOccupiedRooms" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .85rem; color: #1A1A2E; background: #fff; font-family: 'Segoe UI', sans-serif;" AutoPostBack="true" OnSelectedIndexChanged="ddlOccupiedRooms_SelectedIndexChanged" />
                            </div>
                            <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 15px;">
                                <label>Guest Details</label>
                                <asp:TextBox ID="txtGuestDetails" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .85rem; font-family: 'Segoe UI', sans-serif; background:#f8fafc; color:#1e3a5f; font-weight:600; width:100%;" ReadOnly="true" TextMode="MultiLine" Rows="2" />
                            </div>
                        </div>

                        <!-- TO DESTINATION -->
                        <div>
                            <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 15px;">
                                <label>To: New Available Room</label>
                                <asp:DropDownList ID="ddlAvailableRooms" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .85rem; color: #1A1A2E; background: #fff; font-family: 'Segoe UI', sans-serif;" />
                            </div>
                            <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 15px;">
                                <label>Reason for Shift</label>
                                <asp:DropDownList ID="ddlShiftReason" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .85rem; color: #1A1A2E; background: #fff; font-family: 'Segoe UI', sans-serif;">
                                    <asp:ListItem Text="-- Select Reason --" Value="" />
                                    <asp:ListItem Text="AC / Technical Fault" Value="Maintenance Issue" />
                                    <asp:ListItem Text="Guest Request (Upgrade)" Value="Upgrade" />
                                    <asp:ListItem Text="Guest Request (Location)" Value="Location Change" />
                                    <asp:ListItem Text="Cleaning / Maintenance" Value="Cleaning" />
                                    <asp:ListItem Text="Management Decision" Value="Management" />
                                </asp:DropDownList>
                            </div>
                            <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 15px;">
                                <label>Internal Remarks</label>
                                <asp:TextBox ID="txtShiftRemarks" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .85rem; color: #1A1A2E; background: #fff; font-family: 'Segoe UI', sans-serif;" placeholder="Optional notes for history log..." />
                            </div>
                        </div>
                    </div>

                    <div style="padding: 25px; border-top: 1px solid #e2e8f0; background: #f8fafc; text-align: center;">
                        <asp:Button ID="btnShiftRoom" runat="server" Text="Confirm Room Shift Now" style="background: linear-gradient(135deg, #1A1A2E, #2d2d5e); color: #C9A84C; border: none; padding: 12px 60px; border-radius: 30px; font-size: .88rem; font-weight: 800; cursor: pointer; transition: all .2s;" 
                            OnClick="btnShiftRoom_Click" OnClientClick="return confirm('Are you sure you want to shift this guest to a new room? This will generate a new reservation segment.');" />
                    </div>
                </div>

                <!-- HISTORY SECTION -->
                <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; margin-bottom: 16px; position: relative; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.06);">
                    <div style="padding: 18px 25px; border-bottom: 1px solid #e0d5c5; background: #faf7f2; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                        <h4 style="margin:0;"><i class="fas fa-history"></i> Room Shift History</h4>
                        <div style="display:flex; gap:10px; align-items:center;">
                            <asp:TextBox ID="txtFromDate" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .85rem; color: #1A1A2E; background: #fff; font-family: 'Segoe UI', sans-serif; width:160px;" TextMode="Date" />
                            <asp:TextBox ID="txtToDate" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .85rem; color: #1A1A2E; background: #fff; font-family: 'Segoe UI', sans-serif; width:160px;" TextMode="Date" />
                            <asp:Button ID="btnFilter" runat="server" Text="Filter" style="background: transparent; border: 1.5px solid #1A1A2E; color: #1A1A2E; padding: 5px 14px; border-radius: 6px; font-size: .75rem; font-weight: 600; cursor: pointer;" OnClick="btnFilter_Click" />
                            <asp:Button ID="btnExportExcel" runat="server" Text="Export" style="background: #2e7d32; color: #fff; border: none; padding: 5px 14px; border-radius: 6px; font-size: .75rem; font-weight: 600; cursor: pointer;" OnClick="btnExportExcel_Click" />
                        </div>
                    </div>
                    
                    <div style="padding:20px;">
                        <div style="margin-bottom:15px; font-size:0.85rem; color:#64748b;">
                            Found <asp:Label ID="lblRecordCount" runat="server" Text="0" /> historical shift records
                        </div>
                        <asp:GridView ID="gvShiftHistory" runat="server"
    AutoGenerateColumns="false"
    GridLines="None"
    AllowPaging="true"
    PageSize="10"
    OnPageIndexChanging="gvShiftHistory_PageIndexChanging"
    style="width:100%; border-collapse:collapse; font-size:0.82rem; background:#fff;"
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

        <%-- S.No --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" Width="40px" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 10px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">S.No</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 10px; color:#1e293b; font-size:0.82rem;">
                    <%# Container.DataItemIndex + 1 + (gvShiftHistory.PageIndex * gvShiftHistory.PageSize) %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Date & Time --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Date & Time</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 15px; color:#1e293b; font-size:0.82rem;">
                    <%# Convert.ToDateTime(Eval("ShiftDate")).ToString("dd-MMM-yy hh:mm tt") %>
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
                <div style="padding:11px 15px; color:#1e293b; font-size:0.82rem;"><%# Eval("GuestName") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Transfer --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Transfer</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 15px;">
                    <div style="font-weight:700; display:flex; align-items:center; gap:6px;">
                        <span style="background:#fce4ec; color:#ef4444; padding:2px 8px; border-radius:5px; font-family:'Courier New',monospace; font-size:0.82rem;"
                            title='<%# Eval("OldRoomType") %>'>
                            <%# Eval("OldRoomNo") %>
                        </span>
                        <i class="fas fa-long-arrow-alt-right" style="color:#C9A84C; font-size:0.85rem;"></i>
                        <span style="background:#e8f5e9; color:#10b981; padding:2px 8px; border-radius:5px; font-family:'Courier New',monospace; font-size:0.82rem;">
                            <%# Eval("NewRoomNo") %>
                        </span>
                    </div>
                    <div style="font-size:0.72rem; color:#64748b; margin-top:4px;"><%# Eval("OldRoomType") %></div>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Last Check-in --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Last Check-in</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 15px; color:#1e293b; font-size:0.82rem;">
                    <%# Convert.ToDateTime(Eval("LastCheckIn")).ToString("dd-MMM-yy") %>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Reason --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Reason</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 15px; color:#64748b; font-size:0.82rem; font-style:italic;"><%# Eval("ShiftReason") %></div>
            </ItemTemplate>
        </asp:TemplateField>

        <%-- User --%>
        <asp:TemplateField>
            <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
            <HeaderTemplate>
                <span style="display:block; padding:12px 15px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">User</span>
            </HeaderTemplate>
            <ItemTemplate>
                <div style="padding:11px 15px; color:#1e293b; font-size:0.82rem; font-weight:600;"><%# Eval("ShiftedBy") %></div>
            </ItemTemplate>
        </asp:TemplateField>

    </Columns>

    <EmptyDataTemplate>
        <div style="padding:40px; text-align:center; color:#7a7a7a; background:#fff;">
            <i class="fas fa-exchange-alt" style="font-size:2.5rem; color:#e0d5c5; margin-bottom:12px; display:block;"></i>
            <p style="margin:0; font-size:0.85rem;">No room shift history found.</p>
        </div>
    </EmptyDataTemplate>

</asp:GridView>
                    </div>
                </div>

            </ContentTemplate>
        </asp:UpdatePanel>

    </div>
</asp:Content>
