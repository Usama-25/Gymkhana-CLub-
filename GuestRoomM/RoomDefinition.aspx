<%@ Page Language="C#" MasterPageFile="SiteGuestroom.master" CodeFile="RoomDefinition.aspx.cs" Inherits="GuestRoomApp.GuestRoomM.RoomDefinition" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
<style>
    /* Only pseudo-elements and media queries here */
    .required-field::after { content: " *"; color: #c62828; font-weight: bold; }
    input[type=text]:focus, select:focus, textarea:focus { border-color: #C9A84C !important; outline: none !important; box-shadow: 0 0 0 3px rgba(201,168,76,0.15) !important; }
    @media (max-width: 768px) {
        .form-row td { display: block !important; width: 100% !important; }
        .page-wrap { padding: 10px !important; }
    }
</style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="Server">
<div class="page-wrap" style="padding:20px; font-family:'Segoe UI',sans-serif; background:#F7F3EE; min-height:100vh;">

    <%-- PAGE HEADER --%>
    <div style="background:linear-gradient(135deg,#1A1A2E,#2d2d5e); color:#fff; padding:16px 26px; border-radius:10px; margin-bottom:18px; display:flex; align-items:center; justify-content:space-between; box-shadow:0 4px 15px rgba(0,0,0,0.2);">
        <div>
            <h3 style="margin:0; font-size:1.35rem; letter-spacing:1px;">Room Definition</h3>
            <div style="font-size:.77rem; color:#E8D5A3; margin-top:3px;">Define and Manage Guest Rooms (001 to 102)</div>
        </div>
    </div>

    <%-- INFO BAR --%>
    <div style="background:#faf7f2; border-left:4px solid #C9A84C; padding:9px 14px; border-radius:7px; margin-bottom:16px; font-size:.8rem; color:#8B5E3C; font-weight:600;">
        <i class="fas fa-info-circle" style="margin-right:6px;"></i>
        Room numbers will be automatically generated (Format: 001, 002...)
    </div>

    <%-- TABS --%>
    <div style="display:flex; gap:6px; margin-bottom:-1px;">
        <asp:Button ID="btnTabDefine" runat="server" Text="Define Room" OnClick="SwitchTab" CommandArgument="0"
            style="background:#1A1A2E; color:#C9A84C; border:1px solid #1A1A2E; padding:9px 22px; font-size:.87rem; font-weight:700; cursor:pointer; font-family:'Segoe UI',sans-serif; border-radius:8px 8px 0 0;" />
        <asp:Button ID="btnTabView" runat="server" Text="View All" OnClick="SwitchTab" CommandArgument="1"
            style="background:#e0d5c5; color:#1A1A2E; border:1px solid #e0d5c5; padding:9px 22px; font-size:.87rem; font-weight:700; cursor:pointer; font-family:'Segoe UI',sans-serif; border-radius:8px 8px 0 0;" />
    </div>

    <asp:MultiView ID="mvRoom" runat="server" ActiveViewIndex="0">

        <%-- ═══ DEFINE FORM VIEW ═══ --%>
        <asp:View ID="viewForm" runat="server">
            <div style="background:#fff; border:1px solid #e0d5c5; border-radius:0 8px 8px 8px; box-shadow:0 2px 10px rgba(0,0,0,0.06); overflow:hidden; position:relative;">
                <div style="position:absolute; top:0; left:0; right:0; height:4px; background:linear-gradient(90deg,#C9A84C,#8B5E3C); border-radius:0;"></div>
                <div style="padding:8px 0; margin-top:4px;">

                    <asp:Label ID="lblMessage" runat="server" EnableViewState="false" />

                    <%-- Helper macro: label cell style --%>
                    <table style="width:100%; border-collapse:collapse;">

                        <%-- Room No --%>
                        <tr class="form-row">
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9; width:160px; font-weight:600; font-size:.85rem; color:#1A1A2E; background:#faf7f2;" class="required-field">Room No</td>
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9;" colspan="5">
                                <asp:TextBox ID="txtRoomNo" runat="server" MaxLength="8"
                                    style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; font-family:'Segoe UI',sans-serif; width:120px; color:#1A1A2E; background:#fff;" />
                                <span style="color:#7a7a7a; font-size:.75rem; font-style:italic; margin-left:8px;">Auto-generated (001, 002...)</span>
                                <asp:RequiredFieldValidator ID="rfvRoomNo" runat="server" ControlToValidate="txtRoomNo" ErrorMessage=" Room No is required" ForeColor="Red" ValidationGroup="save" style="font-size:.75rem;" />
                            </td>
                        </tr>

                        <%-- Location --%>
                        <tr class="form-row">
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9; font-weight:600; font-size:.85rem; color:#1A1A2E; background:#faf7f2;" class="required-field">Location</td>
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9;" colspan="5">
                                <asp:DropDownList ID="ddlLocation" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlLocation_SelectedIndexChanged"
                                    style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; font-family:'Segoe UI',sans-serif; width:220px; color:#1A1A2E; background:#fff;">
                                    <asp:ListItem Text="Select Side/Building" Value="" />
                                    <asp:ListItem Text="Lawn Side" />
                                    <asp:ListItem Text="Golf Side" />
                                    <asp:ListItem Text="Mall Side" />
                                    <asp:ListItem Text="Parking Side" />
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="rfvLocation" runat="server" ControlToValidate="ddlLocation" InitialValue="" ErrorMessage=" Location is required" ForeColor="Red" ValidationGroup="save" style="font-size:.75rem;" />
                            </td>
                        </tr>

                        <%-- Floor/Side --%>
                        <tr class="form-row">
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9; font-weight:600; font-size:.85rem; color:#1A1A2E; background:#faf7f2;" class="required-field">Floor/Side</td>
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9;" colspan="5">
                                <asp:DropDownList ID="ddlFloor" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFloor_SelectedIndexChanged"
                                    style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; font-family:'Segoe UI',sans-serif; width:220px; color:#1A1A2E; background:#fff;">
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="rfvFloor" runat="server" ControlToValidate="ddlFloor" InitialValue="" ErrorMessage=" Floor/Side is required" ForeColor="Red" ValidationGroup="save" style="font-size:.75rem;" />
                            </td>
                        </tr>

                        <%-- Room Type --%>
                        <tr class="form-row">
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9; font-weight:600; font-size:.85rem; color:#1A1A2E; background:#faf7f2;" class="required-field">Room Type</td>
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9;" colspan="5">
                                <asp:DropDownList ID="ddlRoomType" runat="server"
                                    style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; font-family:'Segoe UI',sans-serif; width:220px; color:#1A1A2E; background:#fff;">
                                    <asp:ListItem Text="Select Type" Value="" />
                                    <asp:ListItem Text="King Size one bed" />
                                    <asp:ListItem Text="Single Twin beds" />
                                    <asp:ListItem Text="Single" />
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="rfvRoomType" runat="server" ControlToValidate="ddlRoomType" InitialValue="" ErrorMessage=" Room Type is required" ForeColor="Red" ValidationGroup="save" style="font-size:.75rem;" />
                            </td>
                        </tr>

                        <%-- Rent Type --%>
                        <tr class="form-row">
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9; font-weight:600; font-size:.85rem; color:#1A1A2E; background:#faf7f2;" class="required-field">Rent Type</td>
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9;" colspan="5">
                                <asp:DropDownList ID="ddlRentType" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlRentType_SelectedIndexChanged"
                                    style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; font-family:'Segoe UI',sans-serif; width:220px; color:#1A1A2E; background:#fff;">
                                    <asp:ListItem Text="Select Rent Type" Value="" />
                                    <asp:ListItem Text="Single" />
                                    <asp:ListItem Text="Double" />
                                    <asp:ListItem Text="Single Foreigner" />
                                    <asp:ListItem Text="Double Foreigner" />
                                    <asp:ListItem Text="Single Affiliated" />
                                    <asp:ListItem Text="Double Affiliated" />
                                    <asp:ListItem Text="Single Delux" />
                                    <asp:ListItem Text="Double Delux" />
                                    <asp:ListItem Text="Single Foreigner Delux" />
                                    <asp:ListItem Text="Double Foreigner Delux" />
                                    <asp:ListItem Text="Single Affiliated Delux" />
                                    <asp:ListItem Text="Double Affiliated Delux" />
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="rfvRentType" runat="server" ControlToValidate="ddlRentType" InitialValue="" ErrorMessage=" Rent Type is required" ForeColor="Red" ValidationGroup="save" style="font-size:.75rem;" />
                            </td>
                        </tr>

                        <%-- Description --%>
                        <tr class="form-row">
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9; font-weight:600; font-size:.85rem; color:#1A1A2E; background:#faf7f2;">Description</td>
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9;" colspan="5">
                                <asp:TextBox ID="txtDescription" runat="server" MaxLength="100"
                                    style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; font-family:'Segoe UI',sans-serif; width:400px; color:#1A1A2E; background:#fff;" />
                            </td>
                        </tr>

                        <%-- Capacity --%>
                        <tr class="form-row">
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9; font-weight:600; font-size:.85rem; color:#1A1A2E; background:#faf7f2;" class="required-field">Capacity</td>
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9;" colspan="5">
                                <asp:TextBox ID="txtCapacity" runat="server"
                                    style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; font-family:'Segoe UI',sans-serif; width:100px; color:#1A1A2E; background:#fff;" />
                                <asp:RequiredFieldValidator ID="rfvCapacity" runat="server" ControlToValidate="txtCapacity" ErrorMessage=" Required" ForeColor="Red" ValidationGroup="save" style="font-size:.75rem;" />
                                <asp:RangeValidator ID="rvCapacity" runat="server" ControlToValidate="txtCapacity" MinimumValue="1" MaximumValue="10" Type="Integer" ErrorMessage=" 1-10 only" ForeColor="Red" ValidationGroup="save" style="font-size:.75rem;" />
                            </td>
                        </tr>

                        <%-- Rent --%>
                        <tr class="form-row">
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9; font-weight:600; font-size:.85rem; color:#1A1A2E; background:#faf7f2;" class="required-field">Rent (PKR)</td>
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9;" colspan="5">
                                <asp:TextBox ID="txtRent" runat="server" AutoPostBack="true" OnTextChanged="txtRent_TextChanged"
                                    style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; font-family:'Segoe UI',sans-serif; width:150px; color:#1A1A2E; background:#fff;" />
                                <asp:RequiredFieldValidator ID="rfvRent" runat="server" ControlToValidate="txtRent" ErrorMessage=" Required" ForeColor="Red" ValidationGroup="save" style="font-size:.75rem;" />
                                <asp:CompareValidator ID="cvRent" runat="server" ControlToValidate="txtRent" Operator="GreaterThan" Type="Currency" ValueToCompare="0" ErrorMessage=" Must be > 0" ForeColor="Red" ValidationGroup="save" style="font-size:.75rem;" />
                            </td>
                        </tr>

                        <%-- Tax / Total Row --%>
                        <tr class="form-row">
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9; font-weight:600; font-size:.85rem; color:#1A1A2E; background:#faf7f2;">Tax %</td>
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9;">
                                <asp:TextBox ID="txtTaxPer" runat="server" Text="16" ReadOnly="true"
                                    style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; font-family:'Segoe UI',sans-serif; width:60px; color:#7a7a7a; background:#f5f0e8;" />
                            </td>
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9; font-weight:600; font-size:.85rem; color:#1A1A2E; background:#faf7f2;">Tax Amount</td>
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9;">
                                <asp:TextBox ID="txtTaxAmt" runat="server" ReadOnly="true"
                                    style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; font-family:'Segoe UI',sans-serif; width:110px; color:#7a7a7a; background:#f5f0e8;" />
                            </td>
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9; font-weight:600; font-size:.85rem; color:#1A1A2E; background:#faf7f2;">Total Rent</td>
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9;">
                                <asp:TextBox ID="txtTotalRent" runat="server" ReadOnly="true"
                                    style="padding:8px 11px; border:1.5px solid #C9A84C; border-radius:7px; font-size:.87rem; font-family:'Segoe UI',sans-serif; width:110px; color:#8B5E3C; font-weight:700; background:#faf7f2;" />
                            </td>
                        </tr>

                        <%-- Status --%>
                        <tr class="form-row">
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9; font-weight:600; font-size:.85rem; color:#1A1A2E; background:#faf7f2;" class="required-field">Status</td>
                            <td style="padding:11px 18px; border-bottom:1px solid #f1f5f9;" colspan="5">
                                <asp:DropDownList ID="ddlStatus" runat="server"
                                    style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; font-family:'Segoe UI',sans-serif; width:160px; color:#1A1A2E; background:#fff;">
                                    <asp:ListItem Text="Available" />
                                    <asp:ListItem Text="Occupied" />
                                    <asp:ListItem Text="Maintenance" />
                                </asp:DropDownList>
                            </td>
                        </tr>

                        <%-- Features Row --%>
                        <tr class="form-row">
                            <td style="padding:11px 18px; font-weight:600; font-size:.85rem; color:#1A1A2E; background:#faf7f2;">AC</td>
                            <td style="padding:11px 18px;">
                                <asp:CheckBox ID="chkAC" runat="server" Checked="true"
                                    style="width:18px; height:18px; cursor:pointer; vertical-align:middle; accent-color:#C9A84C;" />
                            </td>
                            <td style="padding:11px 18px; font-weight:600; font-size:.85rem; color:#1A1A2E; background:#faf7f2;">Bathroom</td>
                            <td style="padding:11px 18px;">
                                <asp:CheckBox ID="chkBathroom" runat="server"
                                    style="width:18px; height:18px; cursor:pointer; vertical-align:middle; accent-color:#C9A84C;" />
                            </td>
                            <td style="padding:11px 18px; font-weight:600; font-size:.85rem; color:#1A1A2E; background:#faf7f2;">Bed Type</td>
                            <td style="padding:11px 18px;">
                                <asp:DropDownList ID="ddlBedType" runat="server"
                                    style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; font-family:'Segoe UI',sans-serif; width:130px; color:#1A1A2E; background:#fff;">
                                    <asp:ListItem Text="Single" />
                                    <asp:ListItem Text="King" />
                                </asp:DropDownList>
                            </td>
                        </tr>

                    </table>
                </div>
            </div>
        </asp:View>

        <%-- ═══ VIEW ALL GRID ═══ --%>
        <asp:View ID="viewGrid" runat="server">
            <div style="background:#fff; border:1px solid #e0d5c5; border-radius:0 8px 8px 8px; box-shadow:0 2px 10px rgba(0,0,0,0.06); padding:16px 18px;">

                <%-- Filter --%>
                <div style="display:flex; align-items:center; gap:10px; margin-bottom:14px;">
                    <label style="font-weight:600; font-size:.85rem; color:#1A1A2E;">Filter by Floor/Side:</label>
                    <asp:DropDownList ID="ddlFilterFloor" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterFloor_SelectedIndexChanged"
                        style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; font-family:'Segoe UI',sans-serif; min-width:200px; color:#1A1A2E; background:#fff;">
                    </asp:DropDownList>
                </div>

                <%-- Grid --%>
                <div style="border:1px solid #e0d5c5; border-radius:8px; max-height:400px; overflow-y:auto; overflow-x:auto;">
                    <asp:GridView ID="gvRooms" runat="server"
                        AutoGenerateColumns="False"
                        DataKeyNames="RoomNo"
                        OnSelectedIndexChanged="gvRooms_SelectedIndexChanged"
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

                            <%-- Edit --%>
                            <asp:TemplateField>
                                <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                                <HeaderTemplate>
                                    <span style="display:block; padding:12px 12px; font-size:0.72rem;"></span>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <div style="padding:10px 12px;">
                                        <asp:LinkButton ID="lnkEdit" runat="server" CommandName="Select"
                                            style="color:#C9A84C; font-size:.78rem; font-weight:700; text-decoration:none; background:transparent; border:1.5px solid #C9A84C; padding:3px 10px; border-radius:5px;">
                                            <i class="fas fa-edit"></i> Edit
                                        </asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Room No --%>
                            <asp:TemplateField>
                                <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                                <HeaderTemplate>
                                    <span style="display:block; padding:12px 12px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Room No</span>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <div style="padding:10px 12px; font-weight:700; font-family:'Courier New',monospace; color:#1e3a5f; font-size:0.85rem;">
                                        <%# Eval("RoomNo") %>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Description --%>
                            <asp:TemplateField>
                                <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                                <HeaderTemplate>
                                    <span style="display:block; padding:12px 12px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Description</span>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <div style="padding:10px 12px; color:#1e293b; font-size:0.85rem;"><%# Eval("Description") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Location --%>
                            <asp:TemplateField>
                                <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                                <HeaderTemplate>
                                    <span style="display:block; padding:12px 12px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Location</span>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <div style="padding:10px 12px; color:#1e293b; font-size:0.85rem;"><%# Eval("Location") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Type --%>
                            <asp:TemplateField>
                                <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                                <HeaderTemplate>
                                    <span style="display:block; padding:12px 12px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Type</span>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <div style="padding:10px 12px; color:#1e293b; font-size:0.85rem;"><%# Eval("RoomType") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Rent Type --%>
                            <asp:TemplateField>
                                <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                                <HeaderTemplate>
                                    <span style="display:block; padding:12px 12px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Rent Type</span>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <div style="padding:10px 12px; color:#1e293b; font-size:0.85rem;"><%# Eval("RentType") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Floor/Side --%>
                            <asp:TemplateField>
                                <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                                <HeaderTemplate>
                                    <span style="display:block; padding:12px 12px; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Floor/Side</span>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <div style="padding:10px 12px; color:#1e293b; font-size:0.85rem;"><%# Eval("FloorNo") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Capacity --%>
                            <asp:TemplateField>
                                <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                                <HeaderTemplate>
                                    <span style="display:block; padding:12px 12px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Capacity</span>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <div style="padding:10px 12px; text-align:center; color:#1e293b; font-size:0.85rem;"><%# Eval("Capacity") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Status --%>
                            <asp:TemplateField>
                                <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                                <HeaderTemplate>
                                    <span style="display:block; padding:12px 12px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Status</span>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <div style="padding:10px 12px; text-align:center;">
                                        <span style='<%# GetRoomStatusStyle(Eval("Status").ToString()) %>'>
                                            <%# Eval("Status") %>
                                        </span>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Rent --%>
                            <asp:TemplateField>
                                <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                                <HeaderTemplate>
                                    <span style="display:block; padding:12px 12px; text-align:right; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Rent</span>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <div style="padding:10px 12px; text-align:right; color:#1e293b; font-size:0.85rem;">
                                        <%# Convert.ToDecimal(Eval("Rent")).ToString("N0") %> PKR
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Tax % --%>
                            <asp:TemplateField>
                                <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                                <HeaderTemplate>
                                    <span style="display:block; padding:12px 12px; text-align:center; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Tax %</span>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <div style="padding:10px 12px; text-align:center; color:#7a7a7a; font-size:0.85rem;"><%# Eval("TaxPercentage") %>%</div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Total Rent --%>
                            <asp:TemplateField>
                                <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                                <HeaderTemplate>
                                    <span style="display:block; padding:12px 12px; text-align:right; text-transform:uppercase; letter-spacing:0.5px; font-size:0.72rem; white-space:nowrap;">Total Rent</span>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <div style="padding:10px 12px; text-align:right; font-weight:700; color:#C9A84C; font-size:0.85rem;">
                                        <%# Convert.ToDecimal(Eval("TotalRent")).ToString("N0") %> PKR
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                        </Columns>

                        <EmptyDataTemplate>
                            <div style="padding:40px; text-align:center; color:#7a7a7a; background:#fff;">
                                <i class="fas fa-door-open" style="font-size:2.5rem; color:#e0d5c5; margin-bottom:12px; display:block;"></i>
                                No rooms found. Click "Define Room" to add rooms 001, 002...
                            </div>
                        </EmptyDataTemplate>

                    </asp:GridView>
                </div>
            </div>
        </asp:View>

    </asp:MultiView>

    <%-- ACTION BUTTONS --%>
    <div style="background:#faf7f2; border:1px solid #e0d5c5; border-radius:8px; padding:14px 18px; margin-top:16px; display:flex; gap:8px; flex-wrap:wrap; align-items:center;">
        <asp:Button ID="btnAdd" runat="server" Text="Add New" OnClick="btnAdd_Click"
            style="background:linear-gradient(135deg,#1A1A2E,#2d2d5e); color:#fff; border:none; padding:9px 20px; border-radius:7px; font-size:.87rem; font-weight:600; cursor:pointer; font-family:'Segoe UI',sans-serif;" />
        <asp:Button ID="btnModify" runat="server" Text="Modify" OnClick="btnModify_Click"
            style="background:linear-gradient(135deg,#C9A84C,#8B5E3C); color:#fff; border:none; padding:9px 20px; border-radius:7px; font-size:.87rem; font-weight:600; cursor:pointer; font-family:'Segoe UI',sans-serif;" />
        <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click" ValidationGroup="save"
            style="background:linear-gradient(135deg,#2e7d32,#1b5e20); color:#fff; border:none; padding:9px 20px; border-radius:7px; font-size:.87rem; font-weight:600; cursor:pointer; font-family:'Segoe UI',sans-serif;" />
        <asp:Button ID="btnUpdateCategoryRates" runat="server" Text="Update Category Rates" OnClick="btnUpdateCategoryRates_Click"
            OnClientClick="return confirm('Are you sure you want to update rates for ALL rooms of this category?');"
            style="background:#5a6268; color:#fff; border:none; padding:9px 20px; border-radius:7px; font-size:.87rem; font-weight:600; cursor:pointer; font-family:'Segoe UI',sans-serif;" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClick="btnCancel_Click"
            style="background:#e0d5c5; color:#1A1A2E; border:none; padding:9px 20px; border-radius:7px; font-size:.87rem; font-weight:600; cursor:pointer; font-family:'Segoe UI',sans-serif;" />
        <asp:Button ID="btnClose" runat="server" Text="Close" OnClientClick="window.close(); return false;"
            style="background:#fce4ec; color:#c62828; border:1.5px solid #c62828; padding:9px 20px; border-radius:7px; font-size:.87rem; font-weight:600; cursor:pointer; font-family:'Segoe UI',sans-serif; margin-left:auto;" />
    </div>

</div>
</asp:Content>