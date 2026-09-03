<%@ page language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" autoeventwireup="true" CodeFile="Reservations.aspx.cs" Inherits="Pages_Circulation_Reservations" title="Book Reservations - Lahore Gymkhana Library" %>

<asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
    <style type="text/css">
        .btn-action {
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            text-transform: uppercase;
            border: 1px solid transparent;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 4px;
        }
        .btn-cancel {
            background-color: #fee2e2;
            color: #ef4444;
            border-color: #fca5a5;
        }
        .btn-cancel:hover {
            background-color: #fecaca;
        }
        .btn-priority {
            background-color: #f1f5f9;
            color: #475569;
            border-color: #cbd5e1;
            padding: 4px 8px;
        }
        .btn-priority:hover {
            background-color: #e2e8f0;
        }
        .btn-issue {
            background-color: #eff6ff;
            color: #3b82f6;
            border-color: #bfdbfe;
        }
        .btn-issue:hover {
            background-color: #dbeafe;
        }

        /* GridView Custom Styling */
        .gv-reservations {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
            color: #334155;
            border: none;
        }
        .gv-header {
            background-color: #f1f5f9;
            color: #475569;
            font-weight: 700;
            text-align: left;
            padding: 12px 16px;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 2px solid #e2e8f0;
        }
        .gv-row {
            border-bottom: 1px solid #f1f5f9;
            font-size: 13px;
        }
        .gv-alt-row {
            background-color: #fafbfc;
            border-bottom: 1px solid #f1f5f9;
            font-size: 13px;
        }
        .gv-cell {
            padding: 14px 16px !important;
            vertical-align: middle;
        }
        .col-pos-header {
            text-align: center;
        }
        .col-pos-cell {
            font-weight: bold;
            color: #1d4ed8;
            width: 40px;
            text-align: center;
            padding: 14px 16px !important;
            vertical-align: middle;
        }
        .col-title-cell {
            font-weight: 500;
            color: #1e293b;
            padding: 14px 16px !important;
            vertical-align: middle;
        }
        .col-action-cell {
            padding: 14px 16px !important;
            white-space: nowrap;
            width: 280px;
            vertical-align: middle;
        }

        /* Print Override styles */
        @media print {
            .no-print {
                display: none !important;
            }
            
            /* Reset modal overlay container for printing */
            #cphBody_pnlReserveSlipModal {
                position: static !important;
                background-color: transparent !important;
                width: 100% !important;
                height: auto !important;
                display: block !important;
                z-index: auto !important;
                overflow: visible !important;
            }

            /* Reset the modal inner card wrapper */
            #cphBody_pnlReserveSlipModal > div {
                background-color: transparent !important;
                border: none !important;
                box-shadow: none !important;
                border-radius: 0 !important;
                width: 100% !important;
                max-width: 100% !important;
                max-height: 100% !important;
                padding: 0 !important;
                margin: 0 !important;
                display: block !important;
                overflow: visible !important;
            }

            /* Ensure printable area takes full width and natural flow */
            .printable-area {
                display: block !important;
                position: static !important;
                width: 100% !important;
                padding: 0 !important;
                margin: 0 !important;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">

<!-- Header -->
<div class="no-print" style="background: linear-gradient(135deg, #0f1e36, #1c3254); color: #ffffff; padding: 20px 28px; border-radius: 8px; margin-bottom: 24px; border-bottom: 3px solid #c5a059; width: 100%; box-sizing: border-box;">
    <h2 style="margin: 0; font-size: 22px; font-weight: 600;">Book Reservations Desk</h2>
    <p style="margin: 4px 0 0; opacity: .8; font-size: 13px; font-weight: 300;">Manage queue positions, view dynamic forecasting, notify members, and issue reserved books</p>
</div>

<asp:UpdatePanel ID="upReservations" runat="server" UpdateMode="Conditional">
    <ContentTemplate>

<!-- Alert Panel -->
<asp:Panel ID="pnlAlert" runat="server" CssClass="no-print" Visible="false" style="width: 100%;">
    <div id="divAlert" runat="server" style="padding: 16px 24px; border-radius: 8px; font-size: 14px; margin-bottom: 24px; border-left: 4px solid transparent; width: 100%; box-sizing: border-box;">
        <asp:Literal ID="litAlertMsg" runat="server" />
    </div>
</asp:Panel>

<!-- Form Split -->
<div class="no-print" style="display: flex; flex-direction: column; gap: 28px; width: 100%; box-sizing: border-box;">
    <!-- ==========================================================
         NEW RESERVATION CARD
    =========================================================== -->
    <div style="display: flex; gap: 28px; width: 100%; box-sizing: border-box; flex-wrap: wrap; align-items: flex-start;">
        <div style="flex: 0 0 calc(60% - 14px); min-width: 320px; box-sizing: border-box;">
        <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); overflow: hidden; width: 100%;">
            <div style="padding: 16px 24px; font-size: 15px; font-weight: 700; color: #ffffff; display: flex; align-items: center; gap: 10px; background-color: #1c3254; border-bottom: 3px solid #c5a059;">
                <span>Create Book Reservation</span>
            </div>
            
            <div style="padding: 24px; width: 100%; box-sizing: border-box;">
                <!-- Member Search -->
                <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px;">
                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Member No. / Name</label>
                    <div style="display: flex; gap: 8px; width: 100%;">
                        <asp:TextBox ID="txtMemberSearch" runat="server" placeholder="Enter name or member no (e.g. P-3219)" AutoPostBack="true" OnTextChanged="txtMemberSearch_TextChanged" style="flex: 1; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff;" />
                        <asp:Button ID="btnSearchMember" runat="server" Text="Filter" OnClick="btnSearchMember_Click" style="padding: 10px 18px; border-radius: 8px; border: 1px solid #c5a059; background-color: #ffffff; color: #0f1e36; font-size: 13px; font-weight: 700; cursor: pointer; text-transform: uppercase;" />
                    </div>
                </div>

                <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px;">
                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Select Member <span style="color:#ef4444">*</span></label>
                    <asp:DropDownList ID="ddlMember" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlMember_SelectedIndexChanged" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; height: 44px;" />
                </div>

                <!-- Display Member Name Automatically -->
                <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px;">
                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Member Name</label>
                    <asp:TextBox ID="txtMemberName" runat="server" ReadOnly="true" placeholder="Selected member name will appear here..." style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #f8fafc; color: #475569;" />
                </div>

                <!-- Book Search -->
                <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px;">
                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Search Book Title / ISBN / DDC / Book No. / Barcode</label>
                    <div style="display: flex; gap: 8px; width: 100%;">
                        <asp:TextBox ID="txtBookSearch" runat="server" placeholder="Enter title, ISBN, DDC, Book No, or Barcode..." style="flex: 1; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff;" />
                        <asp:Button ID="btnSearchBook" runat="server" Text="Filter" OnClick="btnSearchBook_Click" style="padding: 10px 18px; border-radius: 8px; border: 1px solid #c5a059; background-color: #ffffff; color: #0f1e36; font-size: 13px; font-weight: 700; cursor: pointer; text-transform: uppercase;" />
                    </div>
                </div>                <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px;">
                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Select Book <span style="color:#ef4444">*</span></label>
                    <asp:DropDownList ID="ddlBookCatalog" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlBookCatalog_Changed" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; height: 44px;" />
                </div>

                <!-- Reservation Range Dates -->
                <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 14px; margin-bottom: 18px; width: 100%; box-sizing: border-box;">
                    <div style="font-size: 11.5px; font-weight: 700; color: #475569; text-transform: uppercase; margin-bottom: 10px; display: flex; align-items: center; gap: 6px;">
                        <span style="width: 6px; height: 6px; background: #c5a059; border-radius: 50%;"></span>
                        Reservation Date Range
                    </div>
                    <div style="display: flex; gap: 12px; flex-wrap: wrap; width: 100%; box-sizing: border-box;">
                        <div style="flex: 1; min-width: 140px; display: flex; flex-direction: column; gap: 4px;">
                            <label style="font-size: 10px; font-weight: 600; color: #64748b; text-transform: uppercase;">Start Date <span style="color:#ef4444">*</span></label>
                            <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" AutoPostBack="true" OnTextChanged="txtReservationDate_TextChanged" style="width: 100%; padding: 8px 10px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; outline: none; background-color: #ffffff; box-sizing: border-box;" />
                        </div>
                        <div style="flex: 1; min-width: 140px; display: flex; flex-direction: column; gap: 4px;">
                            <label style="font-size: 10px; font-weight: 600; color: #64748b; text-transform: uppercase;">End Date <span style="color:#ef4444">*</span></label>
                            <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" AutoPostBack="true" OnTextChanged="txtReservationDate_TextChanged" style="width: 100%; padding: 8px 10px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; outline: none; background-color: #ffffff; box-sizing: border-box;" />
                        </div>
                    </div>
                </div>

                <!-- Real-Time Forecast Panel -->
                <asp:Panel ID="pnlForecastPreview" runat="server" Visible="false" style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 16px; margin-bottom: 20px; box-sizing: border-box; width: 100%;">
                    <div style="font-size: 12px; font-weight: 700; color: #475569; text-transform: uppercase; margin-bottom: 12px; display: flex; align-items: center; gap: 6px; border-bottom: 1px dashed #e2e8f0; padding-bottom: 8px;">
                        <span style="width: 6px; height: 6px; background: #c5a059; border-radius: 50%;"></span>
                        Reservation Forecast Preview
                    </div>
                    
                    <div style="display: flex; flex-direction: column; gap: 8px; font-size: 13px; color: #334155;">
                        <div style="display: flex; justify-content: space-between;">
                             <span>Total Usable Copies:</span>
                            <strong><asp:Label ID="lblTotalCopies" runat="server" /></strong>
                        </div>
                        <div style="display: flex; justify-content: space-between;">
                            <span>Available Copies:</span>
                            <strong><asp:Label ID="lblAvailableCopies" runat="server" /></strong>
                        </div>
                        <div style="display: flex; justify-content: space-between;">
                            <span>Current Active Queue:</span>
                            <strong><asp:Label ID="lblQueueSize" runat="server" /></strong>
                        </div>
                        
                        <div style="margin-top: 10px; padding: 10px 12px; border-radius: 6px; background-color: #eff6ff; border-left: 4px solid #3b82f6; display: flex; flex-direction: column; gap: 4px;">
                            <span style="font-size: 11px; font-weight: 600; text-transform: uppercase; color: #1e3a8a;">Estimated Availability:</span>
                            <strong style="font-size: 15px; color: #1d4ed8;"><asp:Label ID="lblForecastDate" runat="server" /></strong>
                            <span style="font-size: 10px; color: #64748b; margin-top: 2px;">(Calculated based on active loans and reservations ahead)</span>
                        </div>
                    </div>
                </asp:Panel>

                <div style="display: flex; gap: 12px; width: 100%; margin-top: 6px;">
                    <asp:Button ID="btnAddToBasket" runat="server" Text="Add to Basket" OnClick="btnAddToBasket_Click" style="flex: 1; padding: 11px 20px; border-radius: 8px; border: none; cursor: pointer; font-size: 14px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background-color: #0f1e36; color: #ffffff;" />
                    <asp:Button ID="btnRefresh" runat="server" Text="Refresh" OnClick="btnRefresh_Click" style="padding: 11px 20px; border-radius: 8px; border: 1px solid #cbd5e1; background-color: #ffffff; color: #0f1e36; font-size: 14px; font-weight: 700; cursor: pointer; text-transform: uppercase;" />
                </div>
            </div>
        </div>
        </div>

        <!-- ==========================================================
             RESERVATION BASKET CARD (Multi-Book Reservation)
        =========================================================== -->
        <div id="pnlBasketSection" runat="server" style="flex: 0 0 calc(40% - 14px); min-width: 320px; box-sizing: border-box; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); overflow: hidden;">
            <div style="padding: 16px 24px; font-size: 15px; font-weight: 700; color: #ffffff; display: flex; justify-content: space-between; align-items: center; background-color: #0f1e36; border-bottom: 3px solid #c5a059;">
                <span>Pending Reservation Basket</span>
            </div>
            <div style="padding: 20px; width: 100%; box-sizing: border-box;">
                <asp:GridView ID="gvBasket" runat="server" AutoGenerateColumns="False" 
                    OnRowCommand="gvBasket_RowCommand" GridLines="None"
                    CssClass="gv-reservations" style="width: 100%;">
                    <HeaderStyle CssClass="gv-header" />
                    <RowStyle CssClass="gv-row" />
                    <AlternatingRowStyle CssClass="gv-alt-row" />
                    <Columns>
                        <asp:TemplateField HeaderText="Sr#">
                            <ItemTemplate>
                                <%# Container.DataItemIndex + 1 %>
                            </ItemTemplate>
                            <ItemStyle Width="40px" CssClass="gv-cell" HorizontalAlign="Center" />
                            <HeaderStyle CssClass="col-pos-header" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Book Title">
                            <ItemTemplate>
                                <div style="font-weight: 600; color: #1e293b; font-size: 13px;"><%# Eval("Title") %></div>
                                <div style="font-size: 11px; color: #64748b; margin-top: 2px;">
                                    Range: <%# Eval("StartDate", "{0:dd-MMM-yyyy}") %> to <%# Eval("EndDate", "{0:dd-MMM-yyyy}") %>
                                </div>
                            </ItemTemplate>
                            <ItemStyle CssClass="gv-cell" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnRemove" runat="server" CommandName="RemoveItem" CommandArgument='<%# Container.DataItemIndex %>'
                                    style="color: #ef4444; font-weight: 600; text-decoration: none; font-size: 13px;">Remove</asp:LinkButton>
                            </ItemTemplate>
                            <ItemStyle Width="60px" CssClass="gv-cell" HorizontalAlign="Center" />
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>

                <asp:Panel ID="pnlBasketEmpty" runat="server" style="text-align: center; padding: 20px; color: #94a3b8;">
                    <p style="margin: 0; font-size: 13px;">No books in the reservation basket yet.</p>
                </asp:Panel>

                <div id="divConfirmReservations" runat="server" style="margin-top: 16px; display: none;">
                    <asp:Button ID="btnPlaceReservation" runat="server" Text="Confirm Reservation" OnClick="btnPlaceReservation_Click"
                        style="width: 100%; padding: 11px 20px; border-radius: 8px; border: none; cursor: pointer; font-size: 14px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background-color: #0f1e36; color: #ffffff;" />
                </div>
            </div>
        </div>
    </div>

    <!-- ==========================================================
         ACTIVE RESERVATIONS LIST CARD
    =========================================================== -->
    <div style="width: 100%; box-sizing: border-box;">
        <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); overflow: hidden; width: 100%;">
            <div style="padding: 16px 24px; font-size: 15px; font-weight: 700; color: #ffffff; display: flex; align-items: center; justify-content: space-between; background-color: #1c3254; border-bottom: 3px solid #c5a059;">
                <span>Active Reservations Queue</span>
                <span style="background-color: rgba(255,255,255,0.15); font-size: 12px; padding: 4px 10px; border-radius: 20px;">
                    <asp:Label ID="lblTotalActiveReservations" runat="server" Text="0" /> reservations
                </span>
            </div>

            <!-- Filters Bar -->
            <div style="padding: 14px 24px; background-color: #f8fafc; border-bottom: 1px solid #e2e8f0; display: flex; gap: 12px; align-items: center; flex-wrap: wrap;">
                <span style="font-size: 12px; font-weight: 700; text-transform: uppercase; color: #64748b;">Filters:</span>
                <asp:DropDownList ID="ddlFilterBook" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" style="padding: 6px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; outline: none; background-color: #ffffff; min-width: 150px; max-width: 250px;" />
                <asp:DropDownList ID="ddlFilterMember" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed" style="padding: 6px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; outline: none; background-color: #ffffff; min-width: 150px; max-width: 250px;" />
                <asp:Button ID="btnClearFilters" runat="server" Text="Clear" OnClick="btnClearFilters_Click" style="padding: 6px 14px; border-radius: 6px; border: 1px solid #cbd5e1; background-color: #ffffff; color: #475569; font-size: 12px; font-weight: 600; cursor: pointer;" />
            </div>

            <div style="padding: 24px; width: 100%; box-sizing: border-box; overflow-x: auto;">
                <!-- GridView of Reservations -->
                <asp:GridView ID="gvReservations" runat="server" AutoGenerateColumns="False" 
                              DataKeyNames="ResID,BookID,MemberID,MemberName,BookTitle,MembershipNo"
                              OnRowCommand="gvReservations_RowCommand"
                              OnRowDataBound="gvReservations_RowDataBound"
                              CssClass="gv-reservations">
                    <HeaderStyle CssClass="gv-header" />
                    <RowStyle CssClass="gv-row" />
                    <AlternatingRowStyle CssClass="gv-alt-row" />
                    
                    <Columns>
                        <asp:BoundField DataField="DynamicQueuePos" HeaderText="Pos" ItemStyle-Font-Bold="true" ItemStyle-ForeColor="#1d4ed8" ItemStyle-Width="40px" ItemStyle-CssClass="col-pos-cell" HeaderStyle-CssClass="col-pos-header" />
                        
                        <asp:BoundField DataField="ResID" HeaderText="Reserve No." ItemStyle-CssClass="gv-cell" HeaderStyle-CssClass="gv-header" />
                        <asp:BoundField DataField="BookNo" HeaderText="Book No." ItemStyle-CssClass="gv-cell" HeaderStyle-CssClass="gv-header" />
                        <asp:BoundField DataField="DDC" HeaderText="DDC No." ItemStyle-CssClass="gv-cell" HeaderStyle-CssClass="gv-header" />
                        
                        <asp:BoundField DataField="BookTitle" HeaderText="Book Title" ItemStyle-CssClass="col-title-cell" />
                        
                        <asp:TemplateField HeaderText="Member" ItemStyle-CssClass="gv-cell">
                            <ItemTemplate>
                                <div style="font-weight: 600; color: #0f1e36;"><%# Eval("MemberName") %></div>
                                <div style="font-size: 11px; color: #64748b; margin-top: 2px;"><%# Eval("MembershipNo") %></div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="ReservedAt" HeaderText="Reservation Date" DataFormatString="{0:dd-MMM-yyyy}" ItemStyle-CssClass="gv-cell" HeaderStyle-CssClass="gv-header" />
                        
                        <asp:TemplateField HeaderText="Reserved Range" ItemStyle-CssClass="gv-cell">
                            <ItemTemplate>
                                <div style="font-weight: 600; color: #0f1e36;">
                                    <%# Eval("StartDate", "{0:dd-MMM-yyyy}") %> to <%# Eval("EndDate", "{0:dd-MMM-yyyy}") %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Forecast Availability" ItemStyle-CssClass="gv-cell">
                            <ItemTemplate>
                                <asp:Label ID="lblForecast" runat="server" style="padding: 4px 8px; border-radius: 4px; font-size: 11.5px; font-weight: 600;" />
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Actions" ItemStyle-CssClass="col-action-cell">
                            <ItemTemplate>
                                <!-- Priority controls -->
                                <asp:LinkButton ID="btnMoveUp" runat="server" CommandName="MoveUp" CommandArgument='<%# Eval("ResID") %>' CssClass="btn-action btn-priority" ToolTip="Move Up in queue">▲</asp:LinkButton>
                                <asp:LinkButton ID="btnMoveDown" runat="server" CommandName="MoveDown" CommandArgument='<%# Eval("ResID") %>' CssClass="btn-action btn-priority" ToolTip="Move Down in queue">▼</asp:LinkButton>
                                
                                <!-- Issue direct -->
                                <asp:LinkButton ID="btnIssueDirect" runat="server" CommandName="IssueDirect" CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn-action btn-issue" style="margin-left: 6px;">Issue Direct</asp:LinkButton>
                                
                                <!-- Print Slip (Library Reserve Note) -->
                                <asp:LinkButton ID="btnPrintSlip" runat="server" CommandName="PrintSlip" CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn-action btn-priority" style="margin-left: 6px; background-color: #f0fdf4; color: #15803d; border-color: #bbf7d0;" ToolTip="Print Reserve Note">Print Slip</asp:LinkButton>
                                
                                <!-- Cancel -->
                                <asp:LinkButton ID="btnCancel" runat="server" CommandName="CancelRes" CommandArgument='<%# Eval("ResID") %>' CssClass="btn-action btn-cancel" OnClientClick="return confirm('Are you sure you want to cancel this reservation?');" style="margin-left: 6px;">Cancel</asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="padding: 32px; text-align: center; color: #64748b; font-size: 14px;">
                            No active reservations in the system matching the criteria.
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </div>
</div>

<!-- ==========================================================
     MANUAL ISSUE DIRECT DRAWER (POPUP PANEL)
=========================================================== -->
<asp:Panel ID="pnlIssueDirect" runat="server" CssClass="no-print" Visible="false" style="position: fixed; bottom: 0; right: 0; left: 280px; background-color: #ffffff; border-top: 3px solid #c5a059; box-shadow: 0 -10px 25px -5px rgba(0,0,0,0.1); padding: 24px 32px; z-index: 1000; box-sizing: border-box; display: flex; flex-direction: column; gap: 16px; transition: all 0.3s ease;">
    <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px;">
        <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #0f1e36; display: flex; align-items: center; gap: 8px;">
            <span style="width: 8px; height: 8px; border-radius: 50%; background-color: #3b82f6;"></span>
            Manual Issue Override (Bypassing Queue Order)
        </h3>
        <asp:LinkButton ID="btnCancelIssueDirectTop" runat="server" OnClick="btnCancelIssueDirect_Click" style="text-decoration: none; font-size: 20px; color: #94a3b8; font-weight: 500; cursor: pointer;">&times;</asp:LinkButton>
    </div>

    <asp:HiddenField ID="hdnIssueResID" runat="server" />
    <asp:HiddenField ID="hdnIssueMemberID" runat="server" />
    <asp:HiddenField ID="hdnIssueBookID" runat="server" />
    <asp:HiddenField ID="hdnIssueBorrowerNo" runat="server" />
    <asp:HiddenField ID="hdnIssueBorrowerName" runat="server" />

    <div style="display: flex; gap: 24px; flex-wrap: wrap; align-items: flex-end;">
        <div style="flex: 1; min-width: 200px;">
            <div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; margin-bottom: 6px;">Club Member</div>
            <div style="font-size: 14px; font-weight: 600; color: #1e293b; padding: 10px 14px; background-color: #f1f5f9; border-radius: 8px; border: 1px solid #cbd5e1;">
                <asp:Label ID="lblIssueMemberName" runat="server" />
            </div>
        </div>

        <div style="flex: 1.5; min-width: 250px;">
            <div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; margin-bottom: 6px;">Reserved Book Title</div>
            <div style="font-size: 14px; font-weight: 600; color: #1e293b; padding: 10px 14px; background-color: #f1f5f9; border-radius: 8px; border: 1px solid #cbd5e1;">
                <asp:Label ID="lblIssueBookTitle" runat="server" />
            </div>
        </div>

        <div style="flex: 1.5; min-width: 250px;">
            <div style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; margin-bottom: 6px;">Select Available Copy <span style="color:#ef4444">*</span></div>
            <asp:DropDownList ID="ddlIssueCopies" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; height: 44px;" />
        </div>

        <div style="display: flex; gap: 12px; min-width: 240px; margin-top: 10px;">
            <asp:Button ID="btnConfirmIssueDirect" runat="server" Text="Confirm Direct Issue" OnClick="btnConfirmIssueDirect_Click" style="padding: 11px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background-color: #3b82f6; color: #ffffff;" />
            <asp:Button ID="btnCancelIssueDirect" runat="server" Text="Cancel" OnClick="btnCancelIssueDirect_Click" style="padding: 11px 20px; border-radius: 8px; border: 1px solid #cbd5e1; background-color: #ffffff; color: #475569; font-size: 13px; font-weight: 700; cursor: pointer; text-transform: uppercase;" />
        </div>
    </div>
</asp:Panel>

<!-- MODAL 3: RESERVE SLIP PREVIEW -->
<asp:Panel ID="pnlReserveSlipModal" runat="server" Visible="false" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.6); display: flex; justify-content: center; align-items: center; z-index: 1000;">
    <div style="background-color: #ffffff; border-radius: 12px; width: 80%; max-width: 800px; max-height: 90%; overflow-y: auto; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.15); display: flex; flex-direction: column; border-top: 5px solid #c5a059;">
        <div style="padding: 16px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;" class="no-print">
            <h3 style="margin:0; font-size:16px; color:#0f1e36; font-weight:700;">Library Reserve Note Preview</h3>
            <asp:Button ID="btnCloseReserveSlip" runat="server" Text="&times;" style="border:none; background:none; font-size:24px; cursor:pointer;" OnClick="btnCloseReserveSlip_Click" />
        </div>
        <div class="printable-area" style="padding: 40px; flex-grow: 1; font-family: Arial, sans-serif; color: #000000; background-color: #ffffff;">
            <asp:Literal ID="litPrintableReserveSlip" runat="server" />
        </div>
        <div style="padding: 16px 24px; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 12px;" class="no-print">
            <button type="button" style="padding: 10px 20px; border-radius: 6px; border: none; cursor: pointer; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" onclick="window.print();">Print Slip</button>
            <asp:Button ID="btnCloseReserveSlipFooter" runat="server" Text="Close Preview" style="padding: 10px 20px; border-radius: 6px; border: none; cursor: pointer; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" OnClick="btnCloseReserveSlip_Click" />
        </div>
    </div>
</asp:Panel>
    </ContentTemplate>
</asp:UpdatePanel>

</asp:Content>
