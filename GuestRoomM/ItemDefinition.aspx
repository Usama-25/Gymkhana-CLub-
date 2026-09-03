<%@ Page Language="C#" MasterPageFile="SiteGuestroom.master" 
         AutoEventWireup="true" CodeFile="ItemDefinition.aspx.cs" 
         Inherits="GuestRoomApp.GuestRoomM.ItemDefinition" Title="Item Definition" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    /* Rules that require pseudo-elements or media queries */
    .form-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px; background: linear-gradient(90deg, #C9A84C, #8B5E3C); border-radius: 10px 10px 0 0; }
    .ctrl:focus { outline: none; border-color: #C9A84C; box-shadow: 0 0 0 3px rgba(201,168,76,0.15); }
    .btn-gold:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(201,168,76,0.4); }
    .btn-outline:hover { background: #8B5E3C; color: #fff; }
    table.item-grid thead th { position: sticky; top: 0; z-index: 5; }
    table.item-grid tbody tr:hover { background: #f0e8d8; transition: background .15s; }
    
    @media(max-width: 1050px){
        .col-form { flex: 0 0 62% !important; max-width: 62% !important; }
        .col-panel { flex: 0 0 calc(38% - 16px) !important; max-width: calc(38% - 16px) !important; }
    }
    @media(max-width: 860px){
        .page-layout { flex-direction: column !important; }
        .col-form, .col-panel { flex: 0 0 100% !important; max-width: 100% !important; position: static !important; }
        .grid-wrap { max-height: 300px !important; }
        .filter-col { flex-direction: row !important; flex-wrap: wrap !important; }
        .filter-col .ctrl { min-width: 150px !important; }
    }
    @media(max-width: 600px){ .form-card { padding: 13px !important; } }
</style>
</asp:Content>

<%-- ════════════════════════════════════════
     MAIN CONTENT
════════════════════════════════════════ --%>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

<div class="container-fluid px-3 py-2">

    <%-- PAGE HEADER --%>
    <div style="background: linear-gradient(135deg, #1A1A2E 0%, #2d2d5e 100%); color: #fff; padding: 16px 24px; border-radius: 10px; margin-bottom: 18px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 4px 15px rgba(0,0,0,0.2);">
        <div>
            <h3 style="margin: 0; font-size: 1.35rem; letter-spacing: 1px;">🏨 Item Definition</h3>
            <span style="font-size: .78rem; color: #E8D5A3;">Guest Room Management · Inventory Items</span>
        </div>
    </div>

    <%-- ALERT --%>
    <asp:Label ID="lblMessage" runat="server" CssClass="alert" EnableViewState="false"></asp:Label>

    <%-- ══════════════════════════════════════
         70%  FORM  |  30%  SEARCH + LIST
    ══════════════════════════════════════ --%>
    <div style="display: flex; gap: 16px; align-items: flex-start; width: 100%;" class="page-layout">

        <%-- ══ LEFT 70% — ADD / EDIT FORM ══ --%>
        <div style="flex: 0 0 70%; max-width: 70%;" class="col-form">
            <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 20px; margin-bottom: 16px; box-shadow: 0 2px 10px rgba(0,0,0,0.06); position: relative;" class="form-card">
                <div style="font-size: .71rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 15px; padding-bottom: 8px; border-bottom: 1px solid #e0d5c5; display: flex; align-items: center; gap: 8px;" class="section-title">
                    <asp:Label ID="lblFormTitle" runat="server" Text="➕ Add New Item"></asp:Label>
                </div>

                <asp:HiddenField ID="hfItemID" runat="server" Value="0" />

                <div class="row g-3">

                    <%-- Item ID + Code + Category + Location --%>
                    <div class="col-md-3">
                        <label style="font-size: .81rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px; display: block;">
                            Item ID <span style="font-size: .67rem; background: #e8f5e9; color: #2e7d32; border: 1px solid #a5d6a7; padding: 1px 7px; border-radius: 10px; margin-left: 5px; font-weight: 600;">AUTO</span>
                        </label>
                        <asp:TextBox ID="txtItemID" runat="server" style="width: 100%; padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; transition: border-color .2s, box-shadow .2s; background: #f5f5f5; color: #7a7a7a;"
                            ReadOnly="true" placeholder="Auto Generated"></asp:TextBox>
                    </div>

                    <div class="col-md-3">
                        <label style="font-size: .81rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px; display: block;">
                            Item Code <span style="font-size: .67rem; background: #e8f5e9; color: #2e7d32; border: 1px solid #a5d6a7; padding: 1px 7px; border-radius: 10px; margin-left: 5px; font-weight: 600;">AUTO</span>
                        </label>
                        <asp:TextBox ID="txtItemCode" runat="server" style="width: 100%; padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; transition: border-color .2s, box-shadow .2s; background: #f5f5f5; color: #7a7a7a;"
                            ReadOnly="true" placeholder="Select Category First"></asp:TextBox>
                    </div>

                    <div class="col-md-3">
                        <label style="font-size: .81rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px; display: block;">Category <span style="color: #c62828;">*</span></label>
                        <asp:DropDownList ID="ddlCategory" runat="server" style="width: 100%; padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; transition: border-color .2s, box-shadow .2s; background: #fff; color: #1A1A2E;"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged">
                        </asp:DropDownList>
                    </div>

                    <div class="col-md-3">
                        <label style="font-size: .81rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px; display: block;">Location <span style="color: #c62828;">*</span></label>
                        <asp:DropDownList ID="ddlLocation" runat="server" style="width: 100%; padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; transition: border-color .2s, box-shadow .2s; background: #fff; color: #1A1A2E;">
                        </asp:DropDownList>
                    </div>

                    <%-- Item Name + Price + Stock --%>
                    <div class="col-md-6">
                        <label style="font-size: .81rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px; display: block;">Item Name <span style="color: #c62828;">*</span></label>
                        <asp:TextBox ID="txtItemName" runat="server" style="width: 100%; padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; transition: border-color .2s, box-shadow .2s; background: #fff; color: #1A1A2E;"
                            MaxLength="150" placeholder="e.g. Lays Classic Chips"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvItemName" runat="server"
                            ControlToValidate="txtItemName"
                            ErrorMessage="Item name is required"
                            Display="Dynamic" ForeColor="Red" Font-Size="Small"
                            ValidationGroup="ItemForm" />
                    </div>

                    <div class="col-md-3">
                        <label style="font-size: .81rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px; display: block;">Unit Price (PKR)</label>
                        <asp:TextBox ID="txtUnitPrice" runat="server" style="width: 100%; padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; transition: border-color .2s, box-shadow .2s; background: #fff; color: #1A1A2E;"
                            TextMode="Number" placeholder="0.00" Text="0"></asp:TextBox>
                    </div>

                    <div class="col-md-3">
                        <label style="font-size: .81rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px; display: block;">Opening Stock</label>
                        <asp:TextBox ID="txtStockQty" runat="server" style="width: 100%; padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; transition: border-color .2s, box-shadow .2s; background: #fff; color: #1A1A2E;"
                            TextMode="Number" placeholder="0" Text="0"></asp:TextBox>
                    </div>

                    <%-- Description + Status --%>
                    <div class="col-md-9">
                        <label style="font-size: .81rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px; display: block;">Description / Notes</label>
                        <asp:TextBox ID="txtDescription" runat="server" style="width: 100%; padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; transition: border-color .2s, box-shadow .2s; background: #fff; color: #1A1A2E;"
                            TextMode="MultiLine" Rows="2"
                            placeholder="Optional description..."></asp:TextBox>
                    </div>

                    <div class="col-md-3">
                        <label style="font-size: .81rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px; display: block;">Status</label>
                        <asp:DropDownList ID="ddlStatus" runat="server" style="width: 100%; padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; transition: border-color .2s, box-shadow .2s; background: #fff; color: #1A1A2E;">
                            <asp:ListItem Value="1" Text="✅ Active" />
                            <asp:ListItem Value="0" Text="❌ Inactive" />
                        </asp:DropDownList>
                    </div>

                </div><%-- /row --%>

                <%-- ACTION BUTTONS --%>
                <div style="margin-top: 1.5rem !important; display: flex !important; gap: 0.5rem !important; flex-wrap: wrap !important;">
                    <asp:Button ID="btnSave" runat="server" Text="💾 Save Item"
                        style="background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: #fff; border: none; padding: 9px 22px; border-radius: 7px; font-weight: 600; font-size: .87rem; cursor: pointer; transition: transform .15s, box-shadow .15s; letter-spacing: .4px;" OnClick="btnSave_Click"
                        ValidationGroup="ItemForm" />
                    <asp:Button ID="btnUpdate" runat="server" Text="✏️ Update Item"
                        style="background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: #fff; border: none; padding: 9px 22px; border-radius: 7px; font-weight: 600; font-size: .87rem; cursor: pointer; transition: transform .15s, box-shadow .15s; letter-spacing: .4px;" OnClick="btnUpdate_Click"
                        Visible="false" ValidationGroup="ItemForm" />
                    <asp:Button ID="btnClear" runat="server" Text="🔄 Clear Form"
                        style="background: transparent; color: #8B5E3C; border: 1.5px solid #8B5E3C; padding: 9px 18px; border-radius: 7px; font-weight: 600; font-size: .87rem; cursor: pointer; transition: all .15s;" OnClick="btnClear_Click"
                        CausesValidation="false" />
                </div>
            </div>
        </div><%-- /col-form --%>

        <%-- ══ RIGHT 30% — SEARCH + SCROLLABLE LIST ══ --%>
        <div style="flex: 0 0 calc(30% - 16px); max-width: calc(30% - 16px); position: sticky; top: 8px;" class="col-panel">

            <%-- SEARCH & FILTER --%>
            <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 20px; margin-bottom: 16px; box-shadow: 0 2px 10px rgba(0,0,0,0.06); position: relative;" class="form-card">
                <div style="font-size: .71rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 15px; padding-bottom: 8px; border-bottom: 1px solid #e0d5c5; display: flex; align-items: center; gap: 8px;" class="section-title">🔍 Search & Filter</div>
                <div style="display: flex; flex-direction: column; gap: 9px;" class="filter-col">
                    <asp:TextBox ID="txtSearch" runat="server" style="width: 100%; padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; transition: border-color .2s, box-shadow .2s; background: #fff; color: #1A1A2E;"
                        placeholder="🔍 Item Code or Name..."></asp:TextBox>
                    <asp:DropDownList ID="ddlFilterCategory" runat="server" style="width: 100%; padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; transition: border-color .2s, box-shadow .2s; background: #fff; color: #1A1A2E;">
                        <asp:ListItem Value="" Text="── All Categories ──" />
                    </asp:DropDownList>
                    <div style="display: flex; gap: 7px;" class="search-btn-row">
                        <asp:Button ID="btnSearch" runat="server" Text="Search"
                            style="flex: 1; padding: 8px 0; font-size: .82rem; text-align:center; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: #fff; border: none; border-radius: 7px; font-weight: 600; cursor: pointer; transition: transform .15s, box-shadow .15s; letter-spacing: .4px;" OnClick="btnSearch_Click"
                            CausesValidation="false" />
                        <asp:Button ID="btnShowAll" runat="server" Text="All"
                            style="flex: 0 0 55px; padding: 8px 0; font-size: .82rem; text-align:center; background: transparent; color: #8B5E3C; border: 1.5px solid #8B5E3C; border-radius: 7px; font-weight: 600; cursor: pointer; transition: all .15s;" OnClick="btnShowAll_Click"
                            CausesValidation="false" />
                    </div>
                </div>
            </div>

            <%-- SCROLLABLE ITEM LIST --%>
            <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 20px; margin-bottom: 16px; box-shadow: 0 2px 10px rgba(0,0,0,0.06); position: relative;" class="form-card">
                <div style="font-size: .71rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 15px; padding-bottom: 8px; border-bottom: 1px solid #e0d5c5; display: flex; align-items: center; gap: 8px;" class="section-title">
                    📋 Items &nbsp;
                    <asp:Label ID="lblItemCount" runat="server" style="background: #C9A84C; color: #1A1A2E; padding: 2px 11px; border-radius: 20px; font-weight: 700; font-size: .78rem;">0</asp:Label>
                </div>
                <div style="overflow-x: auto; overflow-y: auto; max-height: calc(100vh - 300px); min-height: 250px; border-radius: 7px; border: 1px solid #e0d5c5;" class="grid-wrap">
                    <asp:GridView ID="gvItems" runat="server"
                        AutoGenerateColumns="false"
                        CssClass="item-grid"
                        OnRowCommand="gvItems_RowCommand"
                        EmptyDataText="No items found."
                        GridLines="None">
                        <Columns>
                            <asp:TemplateField HeaderText="Code">
                                <ItemTemplate>
                                    <span style="background: #1A1A2E; color: #C9A84C; font-family: 'Courier New', monospace; font-size: .71rem; padding: 2px 6px; border-radius: 4px; font-weight: 700; letter-spacing: 1px; white-space: nowrap;"><%# Eval("ItemCode") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="ItemName"     HeaderText="Name" />
                            <asp:BoundField DataField="CategoryName" HeaderText="Cat" />
                            <asp:TemplateField HeaderText="St" ItemStyle-CssClass="text-center" ItemStyle-Width="30px">
                                <ItemTemplate>
                                    <span style='padding: 2px 7px; border-radius: 10px; font-size:.7rem; font-weight:600; <%# Convert.ToBoolean(Eval("IsActive")) ? "background: #e8f5e9; color: #2e7d32;" : "background: #fce4ec; color: #c62828;" %>'>
                                        <%# Convert.ToBoolean(Eval("IsActive")) ? "✓" : "✗" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Act" ItemStyle-CssClass="text-center" ItemStyle-Width="65px">
                                <ItemTemplate>
                                    <asp:Button runat="server" Text="✏" style="background: #1565C0; color: #fff; border: none; padding: 4px 9px; border-radius: 5px; font-size: .73rem; cursor: pointer; margin-right: 3px;"
                                        CommandName="EditItem" CommandArgument='<%# Eval("ItemID") %>'
                                        CausesValidation="false" />
                                    <asp:Button runat="server" Text="✕" style="background: #c62828; color: #fff; border: none; padding: 4px 9px; border-radius: 5px; font-size: .73rem; cursor: pointer;"
                                        CommandName="DeleteItem" CommandArgument='<%# Eval("ItemID") %>'
                                        CausesValidation="false"
                                        OnClientClick="return confirm('Delete this item?');" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

        </div><%-- /col-panel --%>

    </div><%-- /page-layout --%>

</div><%-- /container --%>

</asp:Content>

