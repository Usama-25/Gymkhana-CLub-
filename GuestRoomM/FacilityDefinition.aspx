<%@ Page Title="Facility & Item Definition" Language="C#" MasterPageFile="SiteGuestroom.master" AutoEventWireup="true"
    CodeFile="FacilityDefinition.aspx.cs" Inherits="GuestRoomM.FacilityDefinition" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

        <style>
            /* Rules that require pseudo-elements or media queries */
            .card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 4px;
                background: linear-gradient(90deg, #C9A84C, #8B5E3C);
            }

            .form-control:focus {
                border-color: #C9A84C !important;
                outline: none;
                box-shadow: 0 0 0 3px rgba(201, 168, 76, 0.15);
            }

            .tab-btn.active {
                background: linear-gradient(135deg, #C9A84C, #8B5E3C) !important;
                color: #fff !important;
                border-color: #8B5E3C !important;
            }

            .tab-btn:hover:not(.active) {
                background: #faf7f2 !important;
                border-color: #C9A84C !important;
            }

            .btn-gold:hover {
                transform: translateY(-1px);
                box-shadow: 0 4px 12px rgba(201, 168, 76, 0.35);
            }

            .btn-info:hover {
                background: #1565C0 !important;
                color: #fff !important;
            }

            .btn-light:hover {
                background: #e0d5c5 !important;
            }

            .service-item:hover {
                border-color: #C9A84C !important;
                box-shadow: 0 4px 12px rgba(201, 168, 76, 0.15);
                transform: translateY(-2px);
            }

            .qty-btn:hover {
                background: #C9A84C !important;
                color: #fff !important;
                border-color: #C9A84C !important;
            }

            .badge::before {
                content: '';
                width: 5px;
                height: 5px;
                border-radius: 50%;
                flex-shrink: 0;
            }

            .bg-success::before {
                background: #2e7d32;
            }

            .bg-warning::before {
                background: #e65100;
            }

            .bg-danger::before {
                background: #c62828;
            }

            .res-pager span {
                background: #1A1A2E !important;
                border-color: hsl(240, 28%, 14%) !important;
                color: #C9A84C !important;
            }

            .res-pager a:hover {
                background: #faf7f2 !important;
                border-color: #C9A84C !important;
                color: #8B5E3C !important;
            }

            /* Light Brown Dropdown Styles */
            .brown-dropdown {
                background-color: #e0d5c5c8 !important;
                color: #1A1A2E !important;
                border: 1.5px solid #e0d5c5 !important;
            }

            .brown-dropdown option {
                background-color: #D2B48C !important;
                color: #1A1A2E !important;
            }

            @media(max-width: 900px) {
                .form-layout {
                    flex-direction: column !important;
                }

                .col-form,
                .col-list {
                    flex: 0 0 100% !important;
                }
            }

            /* Voucher Slip Styles */
            @media print {
                .no-print {
                    display: none !important;
                }

                body {
                    background: #fff !important;
                }

                #voucherSlip {
                    display: block !important;
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    border: none !important;
                    padding: 20px !important;
                    box-shadow: none !important;
                    font-family: 'Courier New', Courier, monospace !important;
                }
            }

            .voucher-item {
                display: flex;
                justify-content: space-between;
                padding: 5px 0;
                border-bottom: 1px dashed #eee;
                font-size: 0.9rem;
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">


        <div
            style="width: 100%; max-width: 100%; padding: 0; background: #F7F3EE; min-height: calc(100vh - 160px); font-family: 'Segoe UI', sans-serif;">

            <!-- PAGE HEADER -->
            <div
                style="background: linear-gradient(135deg, #1A1A2E, #2d2d5e); color: #fff; padding: 14px 22px; margin-bottom: 0; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 10px;">
                <div>
                    <h2 style="margin: 0; font-size: 1.2rem; letter-spacing: 1px;"><i class="fas fa-hotel"></i> Facility
                        & Item Definition</h2>
                    <div style="font-size: .72rem; color: #E8D5A3; margin-top: 3px;">Manage Guest Services and Item
                        Inventory</div>
                </div>
                <div style="display: flex; align-items: center; gap: 8px;">
                    <span style="font-weight: 600; color: #fff; opacity: 0.9; font-size: .78rem;">Select Room:</span>
                    <asp:UpdatePanel runat="server" UpdateMode="Always" style="display:inline-block;">
                        <ContentTemplate>
                            <asp:DropDownList ID="ddlRooms" runat="server" CssClass="brown-dropdown"
                                style="width: 260px; border-radius: 7px; padding: 8px 11px; font-size: .85rem; font-family: 'Segoe UI', sans-serif;"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlRooms_SelectedIndexChanged">
                            </asp:DropDownList>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </div>

            <!-- TABS -->
            <div
                style="display: flex; gap: 8px; margin-bottom: 0; border-bottom: 2px solid #e0d5c5; padding: 10px 18px; flex-wrap: wrap; background: #fff;">
                <asp:Button ID="btnTab1" runat="server" Text="Mini Bar"
                    style="padding: 8px 18px; border-radius: 7px; border: 1.5px solid #e0d5c5; background: #ffffff; color: #8B5E3C; font-weight: 600; cursor: pointer; font-size: .82rem; transition: all .15s;"
                    CssClass="tab-btn active" OnClick="SwitchTab" CommandArgument="1" />
                <asp:Button ID="btnTab4" runat="server" Text="Laundry Services"
                    style="padding: 8px 18px; border-radius: 7px; border: 1.5px solid #e0d5c5; background: #ffffff; color: #8B5E3C; font-weight: 600; cursor: pointer; font-size: .82rem; transition: all .15s;"
                    CssClass="tab-btn" OnClick="SwitchTab" CommandArgument="3" />
                <asp:Button ID="btnTab2" runat="server" Text="Item Definition"
                    style="padding: 8px 18px; border-radius: 7px; border: 1.5px solid #e0d5c5; background: #ffffff; color: #8B5E3C; font-weight: 600; cursor: pointer; font-size: .82rem; transition: all .15s;"
                    CssClass="tab-btn" OnClick="SwitchTab" CommandArgument="0" />
                <asp:Button ID="btnTab3" runat="server" Text="Order History"
                    style="padding: 8px 18px; border-radius: 7px; border: 1.5px solid #e0d5c5; background: #ffffff; color: #8B5E3C; font-weight: 600; cursor: pointer; font-size: .82rem; transition: all .15s;"
                    CssClass="tab-btn" OnClick="SwitchTab" CommandArgument="2" />
            </div>

            <asp:UpdatePanel ID="upMain" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:Label ID="lblMessage" runat="server" CssClass="alert"></asp:Label>

                    <asp:MultiView ID="mvMain" runat="server" ActiveViewIndex="0">

                        <!-- VIEW 0: ITEM DEFINITION (Merged from ItemDefinition.aspx) -->
                        <asp:View runat="server">
                            <div style="display: flex; gap: 14px; padding: 10px 18px;" class="form-layout">
                                <!-- Left: Add/Edit Form -->
                                <div style="flex: 0 0 64%;" class="col-form">
                                    <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; margin-bottom: 0; position: relative; overflow: hidden;"
                                        class="card">
                                        <div
                                            style="padding: 10px 18px; border-bottom: 1px solid #e0d5c5; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px; background: #fafafc;">
                                            <h4 style="margin: 0; font-size: .92rem; font-weight: 700; color: #1A1A2E;">
                                                <asp:Label ID="lblFormTitle" runat="server" Text="Add New Item">
                                                </asp:Label>
                                            </h4>
                                            <asp:HiddenField ID="hfItemID" runat="server" Value="0" />
                                        </div>
                                        <div style="padding: 10px 18px;">
                                            <div class="row">
                                                <div class="col-md-3" style="margin-bottom: 13px;">
                                                    <label
                                                        style="display: block; font-size: .68rem; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 4px;">Item
                                                        Code</label>
                                                    <asp:TextBox ID="txtItemCode" runat="server"
                                                        style="width: 100%; padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .85rem; color: #8B5E3C; background: #faf7f2; font-family: 'Segoe UI', sans-serif;"
                                                        placeholder="Enter or Generated" />
                                                </div>
                                                <div class="col-md-5" style="margin-bottom: 13px;">
                                                    <label
                                                        style="display: block; font-size: .68rem; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 4px;">Item
                                                        Name</label>
                                                    <asp:TextBox ID="txtItemName" runat="server"
                                                        style="width: 100%; padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .85rem; color: #1A1A2E; background: #fff; font-family: 'Segoe UI', sans-serif;"
                                                        placeholder="e.g. Laundry Shirt" />
                                                </div>
                                                <div class="col-md-4" style="margin-bottom: 13px;">
                                                    <label
                                                        style="display: block; font-size: .68rem; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 4px;">Category</label>
                                                    <asp:DropDownList ID="ddlCategory" runat="server"
                                                        CssClass="brown-dropdown"
                                                        style="width: 100%; padding: 8px 11px; border-radius: 7px; font-size: .85rem; font-family: 'Segoe UI', sans-serif;"
                                                        AutoPostBack="true"
                                                        OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-3" style="margin-bottom: 13px;">
                                                    <label
                                                        style="display: block; font-size: .68rem; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 4px;">Unit
                                                        Price (PKR)</label>
                                                    <asp:TextBox ID="txtUnitPrice" runat="server"
                                                        style="width: 100%; padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .85rem; color: #1A1A2E; background: #fff; font-family: 'Segoe UI', sans-serif;"
                                                        TextMode="Number" Text="0" oninput="calcItemGross()" />
                                                </div>
                                                <div class="col-md-3" style="margin-bottom: 13px;">
                                                    <label
                                                        style="display: block; font-size: .68rem; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 4px;">Tax
                                                        %</label>
                                                    <asp:TextBox ID="txtTaxPercentage" runat="server"
                                                        style="width: 100%; padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .85rem; color: #1A1A2E; background: #fff; font-family: 'Segoe UI', sans-serif;"
                                                        TextMode="Number" Text="16" oninput="calcItemGross()" />
                                                </div>
                                                <div class="col-md-3" style="margin-bottom: 13px;">
                                                    <label
                                                        style="display: block; font-size: .68rem; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 4px;">Result
                                                        (Incl. Tax)</label>
                                                    <div id="lblGrossPrice"
                                                        style="font-weight: 700; color: #2e7d32; font-size: 0.95rem; margin-top: 8px;">
                                                        PKR 0</div>
                                                </div>
                                                <div class="col-md-3" style="margin-bottom: 13px;">
                                                    <label
                                                        style="display: block; font-size: .68rem; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 4px;">Opening
                                                        Stock</label>
                                                    <asp:TextBox ID="txtStockQty" runat="server"
                                                        style="width: 100%; padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .85rem; color: #1A1A2E; background: #fff; font-family: 'Segoe UI', sans-serif;"
                                                        TextMode="Number" Text="0" />
                                                </div>
                                                <div class="col-md-4" style="margin-bottom: 13px;">
                                                    <label
                                                        style="display: block; font-size: .68rem; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 4px;">Location</label>
                                                    <asp:DropDownList ID="ddlLocation" runat="server"
                                                        CssClass="brown-dropdown"
                                                        style="width: 100%; padding: 8px 11px; border-radius: 7px; font-size: .85rem; font-family: 'Segoe UI', sans-serif;">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-8" style="margin-bottom: 13px;">
                                                    <label
                                                        style="display: block; font-size: .68rem; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 4px;">Description</label>
                                                    <asp:TextBox ID="txtDescription" runat="server"
                                                        style="width: 100%; padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .85rem; color: #1A1A2E; background: #fff; font-family: 'Segoe UI', sans-serif;"
                                                        TextMode="MultiLine" Rows="2" placeholder="Optional notes..." />
                                                </div>
                                                <div class="col-md-4" style="margin-bottom: 13px;">
                                                    <label
                                                        style="display: block; font-size: .68rem; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 4px;">Status</label>
                                                    <asp:DropDownList ID="ddlStatus" runat="server"
                                                        CssClass="brown-dropdown"
                                                        style="width: 100%; padding: 8px 11px; border-radius: 7px; font-size: .85rem; font-family: 'Segoe UI', sans-serif;">
                                                        <asp:ListItem Value="1" Text="Active" />
                                                        <asp:ListItem Value="0" Text="Inactive" />
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div style="margin-top: 12px;">
                                                <asp:Button ID="btnSave" runat="server" Text="Save Item"
                                                    style="background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: #fff; border: none; padding: 10px 25px; border-radius: 8px; font-size: .82rem; font-weight: 700; cursor: pointer; transition: transform .15s, box-shadow .15s;"
                                                    CssClass="tab-btn active" OnClick="btnSave_Click" />
                                                <asp:Button ID="btnUpdate" runat="server" Text="Update Item"
                                                    style="background: #1565C0; color: #fff; border: none; padding: 10px 25px; border-radius: 8px; font-size: .82rem; font-weight: 700; cursor: pointer; transition: transform .15s, box-shadow .15s;"
                                                    CssClass="tab-btn active" OnClick="btnUpdate_Click"
                                                    Visible="false" />
                                                <asp:Button ID="btnClear" runat="server" Text="Clear"
                                                    style="background: none; color: #7a7a7a; border: 1px solid #e0d5c5; padding: 10px 25px; border-radius: 8px; font-size: .82rem; font-weight: 600; cursor: pointer;"
                                                    CssClass="tab-btn" OnClick="btnClear_Click" />
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Right: Search & Actions -->
                                <div style="flex: 0 0 34%;" class="col-list">
                                    <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; margin-bottom: 0; position: relative; overflow: hidden;"
                                        class="card">
                                        <div
                                            style="padding: 13px 18px; border-bottom: 1px solid #e0d5c5; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px; background: #fafafc;">
                                            <span
                                                style="font-size: .68rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #8B5E3C; display: flex; align-items: center; gap: 8px; margin:0;">Search
                                                Items</span></div>
                                        <div style="padding: 12px 14px;">
                                            <asp:TextBox ID="txtSearch" runat="server"
                                                style="width: 100%; padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .85rem; color: #1A1A2E; background: #fff; font-family: 'Segoe UI', sans-serif; margin-bottom: 8px;"
                                                placeholder="Search by name or code..." />
                                            <div style="display: flex; gap: 8px;">
                                                <asp:Button ID="btnSearch" runat="server" Text="Search"
                                                    style="width: 100%; background: #faf7f2; color: #7a7a7a; border: 1.5px solid #e0d5c5; padding: 7px 14px; border-radius: 7px; font-size: .78rem; font-weight: 600; cursor: pointer;"
                                                    OnClick="btnSearch_Click" />
                                                <asp:Button ID="btnShowAll" runat="server" Text="Show All"
                                                    style="width: 100%; background: #faf7f2; color: #7a7a7a; border: 1.5px solid #e0d5c5; padding: 7px 14px; border-radius: 7px; font-size: .78rem; font-weight: 600; cursor: pointer;"
                                                    OnClick="btnShowAll_Click" />
                                            </div>
                                        </div>
                                    </div>

                                    <div
                                        style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; margin-bottom: 14px; position: relative; overflow: hidden; max-height: 400px; overflow-y: auto;">
                                        <asp:GridView ID="gvItems" runat="server" AutoGenerateColumns="false"
                                            CssClass="data-table" OnRowCommand="gvItems_RowCommand"
                                            DataKeyNames="ItemID">
                                            <Columns>
                                                <asp:BoundField DataField="ItemCode" HeaderText="Code"
                                                    ItemStyle-Width="80px" />
                                                <asp:BoundField DataField="ItemName" HeaderText="Name" />
                                                <asp:TemplateField ItemStyle-Width="60px">
                                                    <ItemTemplate>
                                                        <asp:LinkButton runat="server" CommandName="EditItem"
                                                            CommandArgument='<%# Eval("ItemID") %>' ForeColor="#1565C0">
                                                            <i class="fas fa-edit"></i></asp:LinkButton>
                                                        &nbsp;
                                                        <asp:LinkButton runat="server" CommandName="DeleteItem"
                                                            CommandArgument='<%# Eval("ItemID") %>' ForeColor="#c62828"
                                                            OnClientClick="if(!confirm('Delete this item?')) return false;">
                                                            <i class="fas fa-trash"></i></asp:LinkButton>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                            <EmptyDataTemplate>
                                                <div class="p-4 text-center text-muted">No items found.</div>
                                            </EmptyDataTemplate>
                                        </asp:GridView>
                                    </div>
                                </div>
                            </div>
                        </asp:View>

                        <!-- VIEW 1: ORDER CENTER (Service Menu) -->
                        <asp:View runat="server">
                            <div
                                style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; margin-bottom: 0; position: relative; overflow: hidden;">
                                <div
                                    style="padding: 10px 18px; border-bottom: 1px solid #e0d5c5; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px; background: #fafafc;">
                                    <div style="display:flex; align-items:center; gap:10px; flex-grow: 1;">
                                        <h4 style="margin: 0; font-size: .92rem; font-weight: 700; color: #1A1A2E;">
                                            Service Menu</h4>
                                        <div style="position: relative; margin-left: 15px;">
                                            <i class="fas fa-search"
                                                style="position: absolute; left: 10px; top: 50%; transform: translateY(-50%); color: #8B5E3C; font-size: 0.8rem;"></i>
                                            <input type="text" onkeyup="filterItems(this.value, 'orderItemsContainer')"
                                                placeholder="Search items..."
                                                style="padding: 6px 10px 6px 30px; border: 1.5px solid #e0d5c5; border-radius: 20px; font-size: 0.8rem; width: 220px; outline: none; transition: all 0.2s;" />
                                        </div>
                                        <span
                                            style="display: inline-flex; align-items: center; gap: 4px; padding: 3px 9px; border-radius: 99px; font-size: .68rem; font-weight: 700; background: #e8f5e9; color: #1b5e20;"
                                            class="badge bg-success">Select items below to order</span>
                                    </div>
                                    <div id="lblGuestDetails" style="font-size:0.9rem; color:#1A1A2E;">
                                        <asp:Label ID="lblGuestName" runat="server" Text="No room selected"
                                            Font-Bold="true" />
                                    </div>
                                </div>

                                <div id="orderItemsContainer"
                                    style="display: grid; grid-template-columns: repeat(auto-fill, minmax(170px, 1fr)); gap: 12px; padding: 10px 18px;">
                                    <asp:Repeater ID="rptServices" runat="server">
                                        <ItemTemplate>
                                            <div style="border: 1px solid #e0d5c5; border-radius: 10px; padding: 16px; cursor: pointer; background: #faf7f2; transition: all .15s; text-align: center;"
                                                data-name='<%# Eval("ItemName") %>'
                                                data-price='<%# Eval("UnitPrice") %>'
                                                data-tax='<%# Eval("TaxPercentage") %>' onclick='addToCart(this)'
                                                class="service-item">
                                                <div style="font-size: 1.6rem; color: #C9A84C; margin-bottom: 8px;"><i
                                                        class='<%# GetServiceIcon(Eval("ItemName").ToString()) %>'></i>
                                                </div>
                                                <div
                                                    style="font-size: .88rem; font-weight: 700; color: #1A1A2E; margin-bottom: 4px;">
                                                    <%# Eval("ItemName") %>
                                                </div>
                                                <div style="font-size: .95rem; font-weight: 800; color: #2e7d32;">PKR
                                                    <%# string.Format("{0:N0}", Convert.ToDecimal(Eval("UnitPrice")) *
                                                        (1 + Convert.ToDecimal(Eval("TaxPercentage"))/100)) %>
                                                </div>
                                                <div style="font-size:0.65rem; color:#7a7a7a; margin-top:2px;">Incl. <%#
                                                        Eval("TaxPercentage") %>% Tax</div>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>

                                <div
                                    style="background: linear-gradient(135deg, #1A1A2E, #2d2d5e); color: #fff; padding: 14px 20px; border-radius: 0 0 10px 10px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                                    <div style="display: flex; align-items: center; gap: 20px;">
                                        <div style="display: flex; flex-direction: column;">
                                            <span
                                                style="font-size:0.75rem; color:#E8D5A3; text-transform:uppercase;">Selected
                                                Room</span>
                                            <span style="font-weight:700; font-size:1.1rem;">
                                                <asp:Label ID="lblRoomNo" runat="server" Text="--" />
                                            </span>
                                        </div>
                                        <div style="height:35px; border-left:1px solid rgba(255,255,255,0.2);"></div>
                                        <div style="display: flex; flex-direction: column;">
                                            <span
                                                style="font-size:0.75rem; color:#E8D5A3; text-transform:uppercase;">Pending
                                                Balance</span>
                                            <span style="font-weight:700; font-size:1.1rem; color:#63b3ed;">PKR
                                                <asp:Label ID="lblPending" runat="server" Text="0" />
                                            </span>
                                        </div>
                                    </div>
                                    <div style="display:flex; gap:15px; align-items:center;">
                                        <div onclick="showModal()" style="cursor:pointer; position:relative;">
                                            <i class="fas fa-shopping-cart"
                                                style="font-size:1.8rem; color:#C9A84C;"></i>
                                            <span class="cart-badge"
                                                style="position:absolute; top:-10px; right:-10px; background:#c62828; color:#fff; font-size:0.75rem; padding:2px 7px; border-radius:50%; font-weight:700;">0</span>
                                        </div>
                                        <button type="button"
                                            style="background: #C9A84C; color: #1A1A2E; border: none; padding: 9px 22px; border-radius: 30px; font-weight: 700; cursor: pointer; display: flex; align-items: center; gap: 10px; font-size: .82rem;"
                                            onclick="showModal()">Review Order & Order Now</button>
                                    </div>
                                </div>
                            </div>
                        </asp:View>

                        <!-- VIEW 2: ORDER HISTORY -->
                        <asp:View runat="server">
                            <div
                                style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; margin-bottom: 0; position: relative; overflow: hidden;">
                                <div
                                    style="padding: 10px 18px; border-bottom: 1px solid #e0d5c5; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px; background: #fafafc;">
                                    <h4 style="margin:0; font-size: .92rem; font-weight: 700; color: #1A1A2E;">Order
                                        History for Room
                                        <asp:Label ID="lblHistoryRoom" runat="server" Text="--" />
                                    </h4>
                                    <asp:Button ID="btnRefreshHistory" runat="server" Text="Refresh List"
                                        style="padding: 5px 15px; border-radius: 7px; border: 1.5px solid #e0d5c5; background: #ffffff; color: #8B5E3C; font-weight: 600; cursor: pointer; font-size: .82rem; transition: all .15s;"
                                        OnClick="btnRefreshHistory_Click" />
                                </div>
                                <div class="p-3">
                                    <asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="False"
                                        CssClass="data-table" DataKeyNames="ServiceID"
                                        OnRowDeleting="gvHistory_RowDeleting">
                                        <Columns>
                                            <asp:BoundField DataField="InvoiceNo" HeaderText="Invoice #" />
                                            <asp:BoundField DataField="ServiceName" HeaderText="Service/Item Name" />
                                            <asp:BoundField DataField="Qty" HeaderText="Qty" ItemStyle-Width="50px" />
                                            <asp:BoundField DataField="TotalAmount" HeaderText="Total (PKR)"
                                                DataFormatString="{0:N0}" />
                                            <asp:BoundField DataField="OrderDate" HeaderText="Order Date"
                                                DataFormatString="{0:dd-MMM-yyyy HH:mm}" />
                                            <asp:TemplateField HeaderText="Status">
                                                <ItemTemplate>
                                                    <span
                                                        style='display: inline-flex; align-items: center; gap: 4px; padding: 3px 9px; border-radius: 99px; font-size: .68rem; font-weight: 700;'
                                                        class='badge <%# Eval("Status").ToString() == "Pending" ? "bg-warning" : "bg-success" %>'>
                                                        <%# Eval("Status") %>
                                                    </span>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Action" ItemStyle-Width="80px">
                                                <ItemTemplate>
                                                    <asp:LinkButton runat="server" CommandName="Delete" Text="Delete"
                                                        OnClientClick="if(!confirm('Cancel/Delete this order?')) return false;"
                                                        ForeColor="#c62828" />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                        <EmptyDataTemplate>
                                            <div class="p-5 text-center text-muted">No orders found for this room.</div>
                                        </EmptyDataTemplate>
                                    </asp:GridView>
                                </div>
                            </div>
                        </asp:View>

                        <!-- VIEW 3: LAUNDRY SERVICES -->
                        <asp:View runat="server">
                            <div
                                style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; margin-bottom: 0; position: relative; overflow: hidden;">
                                <div
                                    style="padding: 10px 18px; border-bottom: 1px solid #e0d5c5; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px; background: #fafafc;">
                                    <div style="display:flex; align-items:center; gap:10px; flex-grow: 1;">
                                        <h4 style="margin: 0; font-size: .92rem; font-weight: 700; color: #1A1A2E;">
                                            Laundry Services</h4>
                                        <div style="position: relative; margin-left: 15px;">
                                            <i class="fas fa-search"
                                                style="position: absolute; left: 10px; top: 50%; transform: translateY(-50%); color: #8B5E3C; font-size: 0.8rem;"></i>
                                            <input type="text"
                                                onkeyup="filterItems(this.value, 'laundryItemsContainer')"
                                                placeholder="Search laundry..."
                                                style="padding: 6px 10px 6px 30px; border: 1.5px solid #e0d5c5; border-radius: 20px; font-size: 0.8rem; width: 220px; outline: none; transition: all 0.2s;" />
                                        </div>
                                        <span
                                            style="display: inline-flex; align-items: center; gap: 4px; padding: 3px 9px; border-radius: 99px; font-size: .68rem; font-weight: 700; background: #e3f2fd; color: #0d47a1;"
                                            class="badge bg-info">Select items below</span>
                                    </div>
                                    <div style="font-size:0.9rem; color:#1A1A2E;">
                                        <asp:Label ID="lblLaundryGuest" runat="server" Text="No room selected"
                                            Font-Bold="true" />
                                    </div>
                                </div>

                                <div id="laundryItemsContainer"
                                    style="display: grid; grid-template-columns: repeat(auto-fill, minmax(170px, 1fr)); gap: 12px; padding: 10px 18px;">
                                    <asp:Repeater ID="rptLaundry" runat="server">
                                        <ItemTemplate>
                                            <div style="border: 1px solid #e0d5c5; border-radius: 10px; padding: 16px; cursor: pointer; background: #faf7f2; transition: all .15s; text-align: center;"
                                                data-name='<%# Eval("ItemName") %>'
                                                data-price='<%# Eval("UnitPrice") %>'
                                                data-tax='<%# Eval("TaxPercentage") %>' onclick='addToCart(this)'
                                                class="service-item">
                                                <div style="font-size: 1.6rem; color: #C9A84C; margin-bottom: 8px;"><i
                                                        class='<%# GetServiceIcon(Eval("ItemName").ToString()) %>'></i>
                                                </div>
                                                <div
                                                    style="font-size: .88rem; font-weight: 700; color: #1A1A2E; margin-bottom: 4px;">
                                                    <%# Eval("ItemName") %>
                                                </div>
                                                <div style="font-size: .95rem; font-weight: 800; color: #2e7d32;">PKR
                                                    <%# string.Format("{0:N0}", Convert.ToDecimal(Eval("UnitPrice")) *
                                                        (1 + Convert.ToDecimal(Eval("TaxPercentage"))/100)) %>
                                                </div>
                                                <div style="font-size:0.65rem; color:#7a7a7a; margin-top:2px;">Incl. <%#
                                                        Eval("TaxPercentage") %>% Tax</div>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>

                                <div
                                    style="background: linear-gradient(135deg, #1A1A2E, #2d2d5e); color: #fff; padding: 14px 20px; border-radius: 0 0 10px 10px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                                    <div style="display: flex; align-items: center; gap: 20px;">
                                        <div style="display: flex; flex-direction: column;">
                                            <span
                                                style="font-size:0.75rem; color:#E8D5A3; text-transform:uppercase;">Selected
                                                Room</span>
                                            <span style="font-weight:700; font-size:1.1rem;">
                                                <asp:Label ID="lblLaundryRoom" runat="server" Text="--" />
                                            </span>
                                        </div>
                                        <div style="height:35px; border-left:1px solid rgba(255,255,255,0.2);"></div>
                                        <div style="display: flex; flex-direction: column;">
                                            <span
                                                style="font-size:0.75rem; color:#E8D5A3; text-transform:uppercase;">Laundry
                                                Total (Pending)</span>
                                            <span style="font-weight:700; font-size:1.1rem; color:#63b3ed;">PKR
                                                <asp:Label ID="lblLaundryPending" runat="server" Text="0" />
                                            </span>
                                        </div>
                                    </div>
                                    <div style="display:flex; gap:15px; align-items:center;">
                                        <div onclick="showModal()" style="cursor:pointer; position:relative;">
                                            <i class="fas fa-shopping-cart"
                                                style="font-size:1.8rem; color:#C9A84C;"></i>
                                            <span class="cart-badge"
                                                style="position:absolute; top:-10px; right:-10px; background:#c62828; color:#fff; font-size:0.75rem; padding:2px 7px; border-radius:50%; font-weight:700;">0</span>
                                        </div>
                                        <button type="button"
                                            style="background: #C9A84C; color: #1A1A2E; border: none; padding: 9px 22px; border-radius: 30px; font-weight: 700; cursor: pointer; display: flex; align-items: center; gap: 10px; font-size: .82rem;"
                                            onclick="showModal()">Review Order & Place Order</button>
                                    </div>
                                </div>
                            </div>
                        </asp:View>

                    </asp:MultiView>
                </ContentTemplate>
            </asp:UpdatePanel>

            <!-- VOUCHER / RECEIPT SLIP (Hidden by default, shown for print) -->
            <div id="voucherSlip"
                style="display: none; background: #fff; border: 1px solid #ccc; width: 350px; padding: 25px; margin: 20px auto; color: #000; box-shadow: 0 0 20px rgba(0,0,0,0.1); border-top: 5px solid #1A1A2E;">
                <div style="text-align: center; margin-bottom: 20px;">
                    <img src="images/lahore_gymkhana_logo.png" alt="Lahore Gymkhana"
                        style="height:60px; width:auto; display:block; margin:0 auto 8px auto;" />
                    <h2 style="margin: 0; font-size: 1.4rem; color: #1A1A2E;">SERVICE VOUCHER</h2>
                    <div style="font-size: 0.75rem; color: #666; margin-top: 5px;">Guest Room Management System</div>
                </div>

                <div
                    style="border-bottom: 2px solid #1A1A2E; margin-bottom: 15px; padding-bottom: 10px; display: grid; grid-template-columns: 1fr 1fr; gap: 10px; font-size: 0.8rem;">
                    <div>
                        <strong>Invoice:</strong> <span id="vInvoice">--</span><br />
                        <strong>Date:</strong> <span id="vDate">--</span>
                    </div>
                    <div style="text-align: right;">
                        <strong>Room:</strong> <span id="vRoom">--</span><br />
                        <strong>Guest:</strong> <span id="vGuest">--</span>
                    </div>
                </div>

                <div id="vItemsList" style="margin-bottom: 20px;">
                    <!-- Items will be injected here -->
                </div>

                <div style="border-top: 2px solid #1A1A2E; padding-top: 10px;">
                    <div
                        style="display: flex; justify-content: space-between; font-weight: 700; font-size: 1.1rem; color: #1A1A2E;">
                        <span>GRAND TOTAL</span>
                        <span id="vTotal">PKR 0</span>
                    </div>
                </div>

                <div
                    style="margin-top: 30px; text-align: center; font-size: 0.75rem; border-top: 1px solid #eee; padding-top: 15px;">
                    <p style="margin: 0;">Thank you for availing our services!</p>
                    <p style="margin: 5px 0 0 0; color: #888;">This is a computer generated voucher.</p>
                </div>

                <div class="no-print" style="margin-top: 20px; text-align: center;">
                    <button type="button" onclick="window.print()"
                        style="background: #1A1A2E; color: #fff; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; font-weight: 600;">Print
                        Now</button>
                    <button type="button" onclick="closeVoucher()"
                        style="background: #f44336; color: #fff; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; font-weight: 600; margin-left: 10px;">Close</button>
                </div>
            </div>

        </div>

        <!-- CART SIDEBAR MODAL -->
        <div id="modalOverlay"
            style="display: none; position: fixed; inset: 0; background: rgba(26,26,46,0.5); z-index: 999;"
            onclick="hideModal()"></div>
        <div id="cartModal"
            style="display: none; position: fixed; right: 0; top: 0; bottom: 0; width: 390px; background: #fff; z-index: 1000; box-shadow: -8px 0 24px rgba(0,0,0,0.12); flex-direction: column; border-left: 3px solid #C9A84C;">
            <div
                style="padding: 16px 20px; border-bottom: 1px solid #e0d5c5; background: #1A1A2E; color: #fff; display: flex; justify-content: space-between; align-items: center;">
                <h4 style="margin: 0; color: #C9A84C; font-size: .95rem;"><i class="fas fa-shopping-basket"></i> Your
                    Cart</h4>
                <span style="cursor:pointer; font-size:1.5rem;" onclick="hideModal()">&times;</span>
            </div>
            <div id="cartItems" style="flex: 1; overflow-y: auto; padding: 20px;">
                <div style="text-align:center; color:#718096; margin-top:50px;">Your cart is empty</div>
            </div>
            <div style="padding: 16px 20px; border-top: 1px solid #e0d5c5; background: #faf7f2;">
                <div
                    style="display:flex; justify-content:space-between; margin-bottom:15px; font-weight:700; font-size:1.2rem; color:#1A1A2E;">
                    <span>Grand Total:</span>
                    <span id="cartTotal">PKR 0</span>
                </div>
                <asp:HiddenField ID="hfCart" runat="server" ClientIDMode="Static" />
                <asp:Button ID="btnCheckout" runat="server" Text="Confirm & Place Order"
                    style="background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: #fff; border: none; padding: 16px; border-radius: 7px; font-size: 1.1rem; font-weight: 700; cursor: pointer; width: 100%; transition: transform .15s, box-shadow .15s;"
                    OnClick="btnCheckout_Click" UseSubmitBehavior="false"
                    OnClientClick="if (!prepareCart(this)) return false;" />
            </div>
        </div>

        <script type="text/javascript">
            let cart = [];

            function calcItemGross() {
                var inputUp = document.getElementById('<%= txtUnitPrice.ClientID %>');
                var inputTx = document.getElementById('<%= txtTaxPercentage.ClientID %>');
                var label = document.getElementById('lblGrossPrice');

                if (!inputUp || !inputTx || !label) return;

                var up = parseFloat(inputUp.value) || 0;
                var tx = parseFloat(inputTx.value) || 0;
                var gross = up + (up * tx / 100);
                label.innerText = 'PKR ' + gross.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
            }

            // Initialize display on load
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(calcItemGross);
            window.onload = calcItemGross;

            function filterItems(term, containerId) {
                term = term.toLowerCase();
                const container = document.getElementById(containerId);
                if (!container) return;
                const items = container.getElementsByClassName('service-item');

                for (let i = 0; i < items.length; i++) {
                    const name = items[i].getAttribute('data-name').toLowerCase();
                    if (name.indexOf(term) > -1) {
                        items[i].style.display = '';
                    } else {
                        items[i].style.display = 'none';
                    }
                }
            }

            function addToCart(element) {
                var name = element.getAttribute('data-name');
                var price = parseFloat(element.getAttribute('data-price'));
                var tax = parseFloat(element.getAttribute('data-tax')) || 0;

                let item = cart.find(i => i.name === name);
                if (item) {
                    item.qty++;
                } else {
                    cart.push({ name: name, price: price, tax: tax, qty: 1 });
                }
                updateCartUI();

                // Animation effect
                element.style.transform = 'scale(0.95)';
                setTimeout(() => { element.style.transform = 'translateY(-3px)'; }, 100);
            }

            function updateQty(name, delta) {
                let item = cart.find(i => i.name === name);
                if (item) {
                    item.qty += delta;
                    if (item.qty <= 0) {
                        cart = cart.filter(i => i.name !== name);
                    }
                }
                updateCartUI();
            }

            function updateCartUI() {
                const container = document.getElementById('cartItems');
                const totalEl = document.getElementById('cartTotal');
                const badges = document.querySelectorAll('.cart-badge');
                const hf = document.getElementById('hfCart');

                if (!container) return;

                if (cart.length === 0) {
                    container.innerHTML = '<div style="text-align:center; color:#718096; margin-top:50px;">Your cart is empty</div>';
                    totalEl.innerText = 'PKR 0';
                    badges.forEach(b => b.innerText = '0');
                    if (hf) hf.value = '';
                    return;
                }

                container.innerHTML = '';
                let total = 0;
                let count = 0;

                cart.forEach(item => {
                    let itemTotal = (item.price * item.qty) * (1 + item.tax / 100);
                    total += itemTotal;
                    count += item.qty;
                    container.innerHTML += `
                    <div class="cart-item">
                        <div>
                            <div class="cart-item-name">${escapeHtml(item.name)}</div>
                            <div style="color:#718096; font-size:0.8rem;">PKR ${item.price.toLocaleString()} + ${item.tax}% Tax</div>
                        </div>
                        <div style="display:flex; align-items:center; gap:10px;">
                            <div class="qty-btn" onclick="updateQty('${escapeHtml(item.name)}', -1)">-</div>
                            <span style="min-width:20px; text-align:center; font-weight:700;">${item.qty}</span>
                            <div class="qty-btn" onclick="updateQty('${escapeHtml(item.name)}', 1)">+</div>
                        </div>
                    </div>
                `;
                });

                totalEl.innerText = 'PKR ' + total.toLocaleString();
                badges.forEach(b => b.innerText = count);
                if (hf) hf.value = JSON.stringify(cart);
            }

            function escapeHtml(str) {
                return str.replace(/[&<>]/g, function (m) {
                    return { '&': '&amp;', '<': '&lt;', '>': '&gt;' }[m];
                });
            }

            function showModal() {
                document.getElementById('cartModal').style.display = 'flex';
                document.getElementById('modalOverlay').style.display = 'block';
            }

            function hideModal() {
                document.getElementById('cartModal').style.display = 'none';
                document.getElementById('modalOverlay').style.display = 'none';
            }

            function prepareCart(btn) {
                if (cart.length === 0) {
                    alert("Please add some items to your cart first!");
                    return false;
                }

                // Prevent double submission
                if (btn) {
                    btn.disabled = true;
                    btn.value = 'Processing...';
                    // Force an update to the UI
                    var oldText = btn.innerHTML;
                    btn.innerHTML = 'Processing...';
                }
                return true;
            }

            function clearCart() {
                cart = [];
                updateCartUI();
            }

            function showVoucher(data) {
                document.getElementById('vInvoice').innerText = data.invoice;
                document.getElementById('vDate').innerText = data.date;
                document.getElementById('vRoom').innerText = data.room;
                document.getElementById('vGuest').innerText = data.guest;

                const list = document.getElementById('vItemsList');
                list.innerHTML = '';

                let total = 0;
                data.items.forEach(item => {
                    let itemTotal = (item.price * item.qty) * (1 + item.tax / 100);
                    total += itemTotal;
                    list.innerHTML += `
                    <div class="voucher-item">
                        <span>${item.name} (x${item.qty})</span>
                        <span>PKR ${itemTotal.toLocaleString()}</span>
                    </div>
                `;
                });

                document.getElementById('vTotal').innerText = 'PKR ' + total.toLocaleString();

                // Hide other content and show voucher
                document.getElementById('voucherSlip').style.display = 'block';
                document.getElementById('modalOverlay').style.display = 'block';
                window.scrollTo(0, 0);
            }

            function closeVoucher() {
                document.getElementById('voucherSlip').style.display = 'none';
                document.getElementById('modalOverlay').style.display = 'none';
            }

            // Re-initialize cart UI after UpdatePanel postback if needed
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            prm.add_endRequest(function () {
                updateCartUI();
            });
        </script>
    </asp:Content>