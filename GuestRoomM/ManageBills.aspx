<%@ Page Title="Manage Bills" Language="C#" MasterPageFile="SiteGuestroom.master" AutoEventWireup="true"
    CodeFile="ManageBills.aspx.cs" Inherits="GuestRoomApp.GuestRoomM.ManageBills" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <style>
        /* ── Pseudo-elements, hover states, media queries only ── */
        .form-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: linear-gradient(90deg, #1A1A2E, #2d2d5e);
            border-radius: 10px 10px 0 0;
        }

        .fc:focus {
            border-color: #1A1A2E !important;
            outline: none;
            box-shadow: 0 0 0 3px rgba(26, 26, 46, 0.15);
        }

        .btn-gold:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 16px rgba(201, 168, 76, 0.45);
        }

        .btn-blue:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(26, 26, 46, 0.5);
        }

        .btn-post:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(46, 125, 50, 0.4);
        }

        .btn-dark:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(26, 26, 46, 0.4);
        }

        .btn-print:hover {
            background: #1A1A2E !important;
            color: #fff !important;
        }

        .btn-view:hover {
            opacity: .82;
        }

        .data-table tbody tr:hover {
            background: #f0e8d8 !important;
            cursor: pointer;
        }

        .balance-due td {
            background: #fce4ec;
            color: #c62828;
        }

        .balance-refund td {
            background: #fff3e0;
            color: #e65100;
        }

        .balance-settled td {
            background: #e8f5e9;
            color: #2e7d32;
        }

        .data-table {
            width: 100%;
            border-collapse: collapse;
            font-size: .78rem;
        }

        .data-table thead th {
            position: sticky;
            top: 0;
            z-index: 5;
            background: #1A1A2E;
            color: #fff;
            padding: 10px 12px;
            text-align: left;
            font-weight: 600;
            letter-spacing: .5px;
            text-transform: uppercase;
            font-size: .68rem;
            white-space: nowrap;
            border-bottom: 2px solid #e0d5c5;
        }

        .data-table tbody td {
            padding: 8px 12px;
            border-bottom: 1px solid #f1f5f9;
            color: #1e293b;
            vertical-align: middle;
        }

        .data-table tbody tr:nth-child(even) {
            background: #faf7f2;
        }

        .chip {
            padding: 3px 10px;
            border-radius: 20px;
            font-size: .65rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .5px;
            display: inline-block;
        }

        .chip-settled {
            background: #e8f5e9;
            color: #2e7d32;
            border: 1px solid #c8e6c9;
        }

        .chip-refund {
            background: #fff3e0;
            color: #e65100;
            border: 1px solid #ffe0b2;
        }

        .chip-draft {
            background: #eeeeee;
            color: #616161;
            border: 1px solid #e0e0e0;
        }

        .ledger-table tr {
            border-bottom: 1px solid #e0d5c5;
        }

        .ledger-table td {
            padding: 10px 15px;
            color: #444;
            font-size: .85rem;
        }

        /* Print Styles */
        @media print {
            .no-print {
                display: none !important;
            }

            body {
                background: #fff !important;
            }

            #receiptSlip {
                display: block !important;
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                border: none !important;
                padding: 20px !important;
                box-shadow: none !important;
            }
            
            .print-header {
                margin-bottom: 20px;
            }
        }

        @media(max-width:1100px) {
            .two-col {
                flex-direction: column !important;
            }

            .col-right {
                min-width: 100% !important;
                position: static !important;
            }
        }
        
        .bill-type-selector {
            background: #faf7f2;
            border: 1px solid #e0d5c5;
            border-radius: 8px;
            padding: 12px 14px;
            margin-bottom: 16px;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div style="width:100%; min-height:100vh; background:#F7F3EE; font-family:'Segoe UI',sans-serif; padding:16px 20px; box-sizing:border-box;">
        
        <asp:HiddenField ID="hfReservationNo" runat="server" />
        <asp:HiddenField ID="hfReceiptNo" runat="server" />
        <asp:HiddenField ID="hfAdvancePaid" runat="server" Value="0" />
        <asp:HiddenField ID="hfRoomDescription" runat="server" />
        <asp:HiddenField ID="hfBillStatus" runat="server" />
        <asp:HiddenField ID="hfAutoPrint" runat="server" Value="false" />
        <asp:HiddenField ID="hfBillType" runat="server" Value="SUMMARY" />

        <!-- PAGE HEADER -->
        <div class="no-print" style="background:linear-gradient(135deg,#1A1A2E,#2d2d5e); border-radius:10px; padding:14px 22px; margin-bottom:14px; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px; box-shadow:0 4px 15px rgba(0,0,0,0.2);">
            <div>
                <div style="font-size:1.3rem;font-weight:700;color:#fff;letter-spacing:1px;">
                    <i class="fas fa-file-invoice-dollar"></i> Manage Bills
                </div>
                <div style="font-size:.75rem;color:#E8D5A3;margin-top:3px;">
                    Guest Room Management &nbsp;&middot;&nbsp; Billing &amp; Settlement
                </div>
            </div>
            <div style="display:flex;align-items:center;gap:12px;">
                <asp:HyperLink ID="lnkLedger" runat="server" Target="_blank" Visible="false" style="background:rgba(255,255,255,0.12); color:#fff; border:1px solid rgba(255,255,255,0.3); text-decoration:none; padding:8px 18px; border-radius:7px; font-size:.84rem; font-weight:600; white-space:nowrap;">
                    <i class="fas fa-list-alt"></i> View Detailed Ledger
                </asp:HyperLink>
                <asp:Label ID="lblBillNo" runat="server" Text="NEW BILL" style="background:#C9A84C; color:#1A1A2E; font-family:'Courier New',monospace; font-weight:700; font-size:.82rem; padding:5px 16px; border-radius:20px; letter-spacing:1px;" />
            </div>
        </div>

        <asp:Label ID="lblMessage" runat="server" EnableViewState="false" style="display:none; padding:10px 16px; border-radius:8px; margin-bottom:14px; font-size:.86rem; border-left:4px solid #2e7d32; background:#e8f5e9; color:#2e7d32;" />

        <!-- TWO-COLUMN LAYOUT -->
        <div class="two-col" style="display:flex;gap:14px;align-items:flex-start;width:100%;">

            <!-- LEFT COLUMN -->
            <div class="no-print" style="flex:1;min-width:0;">

                <!-- FIND RESERVATION -->
                <div class="form-card" style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:18px 20px; margin-bottom:14px; position:relative; box-shadow:0 2px 10px rgba(0,0,0,0.06);">
                    <div style="position:absolute;top:0;left:0;right:0;height:4px; background:linear-gradient(90deg,#C9A84C,#8B5E3C); border-radius:10px 10px 0 0;"></div>
                    <div style="font-size:.67rem;font-weight:700;letter-spacing:2px; text-transform:uppercase;color:#8B5E3C; margin-bottom:14px;padding-bottom:8px; border-bottom:1px solid #e0d5c5;">
                        <i class="fas fa-search"></i> Find Reservation
                    </div>
                    <div style="display:flex;gap:10px;align-items:flex-end;flex-wrap:wrap;">
                        <div style="display:flex;flex-direction:column;gap:4px;flex:0 0 280px;">
                            <label style="font-size:.78rem;font-weight:600;color:#1A1A2E;">Reservation No / Receipt No</label>
                            <asp:TextBox ID="txtSearchRes" runat="server" placeholder="e.g. RES000001 or REC000001" CssClass="fc" style="padding:9px 12px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.86rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:100%; transition:border-color .2s;" />
                        </div>
                        <div style="display:flex;flex-direction:column;gap:4px;">
                            <label style="font-size:.78rem;color:transparent;">.</label>
                            <asp:LinkButton ID="btnSearchRes" runat="server" CssClass="btn-blue" CausesValidation="false" OnClick="btnSearchRes_Click" style="background:linear-gradient(135deg,#1A1A2E,#2d2d5e); color:#fff; text-decoration:none; padding:9px 22px; border-radius:7px; font-size:.86rem; font-weight:600; cursor:pointer; display:inline-block; white-space:nowrap; transition:all .2s;">
                                <i class="fas fa-play"></i> Load
                            </asp:LinkButton>
                        </div>
                    </div>
                </div>

                <!-- BILL FORM -->
                <asp:Panel ID="pnlBillForm" runat="server" Visible="false">

                    <!-- GUEST INFO & ROOM SELECTION -->
                    <div class="form-card" style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:18px 20px; margin-bottom:14px; position:relative; box-shadow:0 2px 12px rgba(0,0,0,0.4);">
                        <div style="position:absolute;top:0;left:0;right:0;height:4px; background:linear-gradient(90deg,#C9A84C,#8B5E3C); border-radius:10px 10px 0 0;"></div>
                        <div style="font-size:.67rem;font-weight:700;letter-spacing:2px; text-transform:uppercase;color:#8B5E3C; margin-bottom:14px;padding-bottom:8px; border-bottom:1px solid #e0d5c5;">
                            <i class="fas fa-info-circle"></i> Guest Information &amp; Room Selection
                        </div>

                        <!-- Bill Type Dropdown -->
                        <div class="bill-type-selector">
                            <div style="display:flex;gap:10px;align-items:flex-end;flex-wrap:wrap;">
                                <div style="display:flex;flex-direction:column;gap:4px;flex:0 0 280px;">
                                    <label style="font-size:.78rem;font-weight:600;color:#1A1A2E;">Bill Type</label>
                                    <asp:DropDownList ID="ddlBillType" runat="server" AutoPostBack="false" CssClass="fc" style="padding:9px 12px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.86rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:100%;">
                                        <asp:ListItem Text="Summary Bill (Compact View)" Value="SUMMARY"></asp:ListItem>
                                        <asp:ListItem Text="Detailed Bill (Full Breakdown)" Value="DETAILED"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                        </div>

                        <!-- Billing Basis Dropdown -->
                        <div style="background:#faf7f2;border:1px solid #e0d5c5;border-radius:8px; padding:12px 14px;margin-bottom:16px;">
                            <div style="display:flex;gap:10px;align-items:flex-end;flex-wrap:wrap;">
                                <div style="display:flex;flex-direction:column;gap:4px;flex:0 0 280px;">
                                    <label style="font-size:.78rem;font-weight:600;color:#1A1A2E;">Billing Basis (Select Room for Separate Charges)</label>
                                    <asp:DropDownList ID="ddlBillRooms" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlBillRooms_SelectedIndexChanged" CssClass="fc" style="padding:9px 12px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.86rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; width:100%;" />
                                </div>
                            </div>
                        </div>

                        <!-- Guest Info Grid -->
                        <div style="background:linear-gradient(90deg,#e3f2fd,#f0f7ff); border:1.5px solid #90caf9; border-radius:8px; padding:12px 16px; margin-bottom:14px; display:grid; grid-template-columns:repeat(3,1fr); gap:10px;">
                            <div style="display:flex;flex-direction:column;gap:3px;">
                                <span style="font-size:.64rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#C9A84C;">Guest Name</span>
                                <asp:Label ID="lblGuestName" runat="server" style="font-size:.88rem;font-weight:600;color:#1A1A2E;" />
                            </div>
                            <div style="display:flex;flex-direction:column;gap:3px;">
                                <span style="font-size:.64rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#C9A84C;">Guest Of</span>
                                <asp:Label ID="lblGuestOf" runat="server" style="font-size:.88rem;font-weight:600;color:#1A1A2E;" />
                            </div>
                            <div style="display:flex;flex-direction:column;gap:3px;">
                                <span style="font-size:.64rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#C9A84C;">Club</span>
                                <asp:Label ID="lblClubName" runat="server" style="font-size:.88rem;font-weight:600;color:#1A1A2E;" />
                            </div>
                            <div style="display:flex;flex-direction:column;gap:3px;">
                                <span style="font-size:.64rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#C9A84C;">Reservation No</span>
                                <asp:Label ID="lblResNo" runat="server" style="font-size:.72rem;font-weight:700;font-family:'Courier New',monospace;color:#1A1A2E;" />
                            </div>
                            <div style="display:flex;flex-direction:column;gap:3px;">
                                <span style="font-size:.64rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#C9A84C;">Receipt No</span>
                                <asp:Label ID="lblRecNo" runat="server" style="font-size:.72rem;font-weight:700;font-family:'Courier New',monospace;color:#1A1A2E;" />
                            </div>
                            <div style="display:flex;flex-direction:column;gap:3px;">
                                <span style="font-size:.64rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#C9A84C;">Status</span>
                                <asp:Label ID="lblResStatus" runat="server" style="font-size:.88rem;font-weight:600;color:#1A1A2E;" />
                            </div>
                            <div style="display:flex;flex-direction:column;gap:3px;">
                                <span style="font-size:.64rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#C9A84C;">Allocated Rooms</span>
                                <asp:Label ID="lblAllocRooms" runat="server" style="font-size:.88rem;font-weight:600;color:#1A1A2E;" />
                            </div>
                            <div style="display:flex;flex-direction:column;gap:3px;">
                                <span style="font-size:.64rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#C9A84C;">Check-In</span>
                                <asp:Label ID="lblFromDate" runat="server" style="font-size:.88rem;font-weight:600;color:#1A1A2E;" />
                            </div>
                            <div style="display:flex;flex-direction:column;gap:3px;">
                                <span style="font-size:.64rem;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#C9A84C;">Check-Out</span>
                                <asp:Label ID="lblToDate" runat="server" style="font-size:.88rem;font-weight:600;color:#1A1A2E;" />
                            </div>
                        </div>

                        <!-- Billing Inputs Row 1 -->
                        <div style="display:flex;gap:10px;align-items:flex-end;flex-wrap:wrap;margin-bottom:12px;">
                            <div style="display:flex;flex-direction:column;gap:4px;flex:0 0 105px;min-width:90px;">
                                <label style="font-size:.78rem;font-weight:600;color:#1A1A2E;">No of Rooms</label>
                                <asp:TextBox ID="txtNoOfRooms" runat="server" TextMode="Number" ReadOnly="true" CssClass="fc" onchange="calcBill()" style="padding:9px 11px;border:1.5px solid #e0d5c5;border-radius:7px; font-size:.86rem;color:#7a7a7a;background:#f5f0e8; font-family:'Segoe UI',sans-serif;width:100%;" />
                            </div>
                            <div style="display:flex;flex-direction:column;gap:4px;flex:0 0 105px;min-width:90px;">
                                <label style="font-size:.78rem;font-weight:600;color:#1A1A2E;">No of Nights</label>
                                <asp:TextBox ID="txtNoOfNights" runat="server" TextMode="Number" ReadOnly="true" CssClass="fc" onchange="calcBill()" step="any" style="padding:9px 11px;border:1.5px solid #e0d5c5;border-radius:7px; font-size:.86rem;color:#7a7a7a;background:#f5f0e8; font-family:'Segoe UI',sans-serif;width:100%;" />
                            </div>
                            <div style="display:flex;flex-direction:column;gap:4px;flex:1;min-width:130px;">
                                <label style="font-size:.78rem;font-weight:600;color:#1A1A2E;">Rent / Room / Night (PKR)</label>
                                <asp:TextBox ID="txtRentPerNight" runat="server" TextMode="Number" ReadOnly="true" CssClass="fc" onchange="calcBill()" style="padding:9px 11px;border:1.5px solid #e0d5c5;border-radius:7px; font-size:.86rem;color:#7a7a7a;background:#f5f0e8; font-family:'Segoe UI',sans-serif;width:100%;" />
                            </div>
                            <div style="display:flex;flex-direction:column;gap:4px;flex:0 0 90px;min-width:80px;">
                                <label style="font-size:.78rem;font-weight:600;color:#1A1A2E;">Tax %</label>
                                <asp:TextBox ID="txtTaxPercent" runat="server" TextMode="Number" ReadOnly="true" Text="16" CssClass="fc" onchange="calcBill()" style="padding:9px 11px;border:1.5px solid #e0d5c5;border-radius:7px; font-size:.86rem;color:#7a7a7a;background:#f5f0e8; font-family:'Segoe UI',sans-serif;width:100%;" />
                            </div>
                        </div>

                        <!-- Billing Inputs Row 2 -->
                        <div style="display:flex;gap:10px;align-items:flex-end;flex-wrap:wrap;margin-bottom:12px;">
                            <div style="display:flex;flex-direction:column;gap:4px;flex:1;min-width:130px;">
                                <label style="font-size:.78rem;font-weight:600;color:#1A1A2E;">Services Charges (PKR)</label>
                                <asp:TextBox ID="txtOtherCharges" runat="server" ReadOnly="true" TextMode="Number" Text="0" CssClass="fc" onchange="calcBill()" style="padding:9px 11px;border:1.5px solid #e0d5c5;border-radius:7px; font-size:.86rem;color:#7a7a7a;background:#f5f0e8; font-family:'Segoe UI',sans-serif;width:100%;" />
                            </div>
                            <div style="display:flex;flex-direction:column;gap:4px;flex:1;min-width:130px;">
                                <label style="font-size:.78rem;font-weight:600;color:#1A1A2E;">Advance Paid (PKR)</label>
                                <asp:TextBox ID="txtAdvancePaid" runat="server" TextMode="Number" ReadOnly="true" style="padding:9px 11px;border:1.5px solid #e0d5c5;border-radius:7px; font-size:.86rem;color:#7a7a7a;background:#f5f0e8; font-family:'Segoe UI',sans-serif;width:100%;" />
                            </div>
                            <div style="display:flex;flex-direction:column;gap:4px;flex:1;min-width:130px;">
                                <label style="font-size:.78rem;font-weight:600;color:#1A1A2E;">Payment Mode</label>
                                <asp:DropDownList ID="ddlPaymentMode" runat="server" CssClass="fc" onchange="togglePaymentFields()" style="padding:9px 11px;border:1.5px solid #e0d5c5;border-radius:7px;font-size:.86rem;color:#1A1A2E;background:#fff;font-family:'Segoe UI',sans-serif;width:100%;">
                                    <asp:ListItem Text="Cash" Value="Cash"></asp:ListItem>
                                    <asp:ListItem Text="Online Bank Payment" Value="Online Bank Payment"></asp:ListItem>
                                    <asp:ListItem Text="Credit Card" Value="Credit Card"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div style="display:flex;flex-direction:column;gap:4px;flex:1;min-width:130px;">
                                <label style="font-size:.78rem;font-weight:600;color:#1A1A2E;">Manual Payment (PKR)</label>
                                <asp:TextBox ID="txtManualPay" runat="server" TextMode="Number" Text="0" CssClass="fc" onchange="calcBill()" style="padding:9px 11px;border:1.5px solid #e0d5c5;border-radius:7px; font-size:.86rem;color:#1A1A2E;background:#fff; font-family:'Segoe UI',sans-serif;width:100%;" />
                            </div>
                        </div>

                        <!-- Bank Details Fields (shown for online payment) -->
                        <div id="divBankDetails" style="display:none; gap:10px; align-items:flex-end; flex-wrap:wrap; margin-bottom:12px;">
                            <div style="display:flex;flex-direction:column;gap:4px;flex:1;min-width:150px;">
                                <label style="font-size:.78rem;font-weight:600;color:#1A1A2E;">Bank Name / Till ID</label>
                                <asp:TextBox ID="txtBankTillID" runat="server" CssClass="fc" placeholder="e.g., HBL, UBL, Till-001" style="padding:9px 11px;border:1.5px solid #e0d5c5;border-radius:7px;font-size:.86rem;color:#1A1A2E;background:#fff;width:100%;" />
                            </div>
                            <div style="display:flex;flex-direction:column;gap:4px;flex:1;min-width:150px;">
                                <label style="font-size:.78rem;font-weight:600;color:#1A1A2E;">Transaction Reference ID</label>
                                <asp:TextBox ID="txtRefID" runat="server" CssClass="fc" placeholder="e.g., TRX-123456, IBFT Ref" style="padding:9px 11px;border:1.5px solid #e0d5c5;border-radius:7px;font-size:.86rem;color:#1A1A2E;background:#fff;width:100%;" />
                            </div>
                        </div>

                        <!-- Billing Inputs Row 3 -->
                        <div style="display:flex;gap:10px;align-items:flex-end;flex-wrap:wrap;margin-bottom:4px;">
                            <div style="display:flex;flex-direction:column;gap:4px;flex:1;min-width:130px;">
                                <label style="font-size:.78rem;font-weight:600;color:#1A1A2E;">Cash Pay Back (PKR)</label>
                                <asp:TextBox ID="txtCashPayBack" runat="server" TextMode="Number" Text="0" CssClass="fc" onchange="calcBill()" style="padding:9px 11px;border:1.5px solid #e0d5c5;border-radius:7px; font-size:.86rem;color:#1A1A2E;background:#fff; font-family:'Segoe UI',sans-serif;width:100%;" />
                            </div>
                            <div style="display:flex;flex-direction:column;gap:4px;flex:2;min-width:200px;">
                                <label style="font-size:.78rem;font-weight:600;color:#1A1A2E;">Remarks</label>
                                <asp:TextBox ID="txtRemarks" runat="server" CssClass="fc" placeholder="Any additional notes..." style="padding:9px 11px;border:1.5px solid #e0d5c5;border-radius:7px; font-size:.86rem;color:#1A1A2E;background:#fff; font-family:'Segoe UI',sans-serif;width:100%;" />
                            </div>
                        </div>
                    </div>

                    <!-- INTERIM ADVANCE / CREDIT -->
                    <div class="form-card" style="background:#f0faf2; border:1px solid #b7e4c7; border-radius:10px; padding:18px 20px; margin-bottom:14px; position:relative; box-shadow:0 2px 10px rgba(0,0,0,0.06);">
                        <div style="position:absolute;top:0;left:0;right:0;height:4px; background:linear-gradient(90deg,#2e7d32,#1b5e20); border-radius:10px 10px 0 0;"></div>
                        <div style="font-size:.67rem;font-weight:700;letter-spacing:2px; text-transform:uppercase;color:#2e7d32; margin-bottom:14px;padding-bottom:8px; border-bottom:1px solid #b7e4c7;">
                            <i class="fas fa-plus-circle"></i> Record Advance / Payment / Reversal
                        </div>
                        <div class="no-print" style="display:flex;gap:10px;align-items:flex-end;flex-wrap:wrap;">
                            <div style="display:flex;flex-direction:column;gap:4px;flex:0 0 160px;">
                                <label style="font-size:.78rem;font-weight:600;color:#81c784;">Transaction Type</label>
                                <asp:DropDownList ID="ddlTransType" runat="server" CssClass="fc" style="padding:9px 11px;border:1.5px solid #b7e4c7;border-radius:7px;font-size:.86rem;color:#1A1A2E;background:#fff;width:100%;">
                                    <asp:ListItem Text="Payment (Credit)" Value="PAYMENT" Selected="True"></asp:ListItem>
                                    <asp:ListItem Text="Refund/Reversal (Debit)" Value="VOID"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div style="display:flex;flex-direction:column;gap:4px;flex:0 0 120px;">
                                <label style="font-size:.78rem;font-weight:600;color:#81c784;">Amount (PKR)</label>
                                <asp:TextBox ID="txtInterimAmount" runat="server" TextMode="Number" placeholder="0.00" CssClass="fc" style="padding:9px 11px;border:1.5px solid #b7e4c7;border-radius:7px; font-size:.86rem;color:#1A1A2E;background:#fff; width:100%;" />
                            </div>
                            <div style="display:flex;flex-direction:column;gap:4px;flex:1;min-width:130px;">
                                <label style="font-size:.78rem;font-weight:600;color:#81c784;">Remarks / Reference No</label>
                                <asp:TextBox ID="txtInterimRemarks" runat="server" placeholder="e.g., Visa Ending 4421, Advance, etc." CssClass="fc" style="padding:9px 11px;border:1.5px solid #b7e4c7;border-radius:7px; font-size:.86rem;color:#1A1A2E;background:#fff; width:100%;" />
                            </div>
                            <asp:Button ID="btnPost" runat="server" Text="Post Transaction" CssClass="btn-post" OnClick="btnPostPayment_Click" style="background:linear-gradient(135deg,#2e7d32,#1b5e20); color:#fff; border:none; padding:9px 22px; border-radius:7px; font-size:.86rem; font-weight:600; cursor:pointer; white-space:nowrap; transition:all .2s;" />
                        </div>
                    </div>
                </asp:Panel>
            </div>

            <!-- RIGHT COLUMN -->
            <div class="col-right no-print" style="flex:0 0 380px;min-width:350px;position:sticky;top:10px;">

                <!-- CALCULATION SUMMARY -->
                <asp:Panel ID="pnlSummarySide" runat="server" Visible="false">
                    <div style="border:1.5px solid #C9A84C; border-radius:12px; background:#ffffff; overflow:hidden; box-shadow:0 4px 15px rgba(0,0,0,0.08); margin-bottom:14px;">
                        <div style="background:linear-gradient(135deg,#C9A84C,#8B5E3C); color:#1A1A2E; padding:10px 16px; font-size:.72rem; font-weight:800; text-transform:uppercase; letter-spacing:1.5px; display:flex; justify-content:space-between; align-items:center;">
                            <span><i class="fas fa-calculator"></i> Calculation Summary</span>
                            <span style="background:rgba(0,0,0,0.2);padding:2px 8px;border-radius:4px;font-size:.62rem;font-weight:700;">LIVE UPDATE</span>
                        </div>
                        <table class="ledger-table" style="width:100%;border-collapse:collapse;">
                            <tr>
                                <td style="padding:10px 15px;color:#555;">Room Rent Breakdown</td>
                                <td style="padding:10px 15px;text-align:right;color:#777;font-size:.78rem;">
                                    <span id="spanRooms">0</span> R &times; <span id="spanNights">0</span> N
                                    <div style="font-size:.64rem;color:#888;" id="spanRoomDesc">No details</div>
                                </td>
                                <td style="padding:10px 15px;text-align:right;font-weight:600;color:#1A1A2E;width:95px;" id="tdRoomRent">0</td>
                            </tr>
                            <tr>
                                <td style="padding:10px 15px;color:#555;">GST / Tax (<span id="spanTaxPct">16</span>%)</td>
                                <td style="padding:10px 15px;"></td>
                                <td style="padding:10px 15px;text-align:right;font-weight:600;color:#1A1A2E;" id="tdTax">0</td>
                            </tr>
                            <tr>
                                <td style="padding:10px 15px;color:#555;">Other Services</td>
                                <td style="padding:10px 15px;"></td>
                                <td style="padding:10px 15px;text-align:right;font-weight:600;color:#1A1A2E;" id="tdOther">0</td>
                            </tr>
                            <tr style="background:#f8f9fa;border-top:2px solid #C9A84C;border-bottom:2px solid #C9A84C;">
                                <td style="padding:12px 15px;font-weight:700;color:#1A1A2E;font-size:.9rem;">GROSS TOTAL</td>
                                <td style="padding:12px 15px;"></td>
                                <td style="padding:12px 15px;text-align:right;font-size:1.05rem;font-weight:700;color:#1A1A2E;" id="tdGross">0</td>
                            </tr>
                            <tr>
                                <td style="padding:10px 15px;color:#c62828;">Advance Paid</td>
                                <td style="padding:10px 15px;"></td>
                                <td style="padding:10px 15px;text-align:right;font-weight:600;color:#c62828;" id="tdAdvance">0</td>
                            </tr>
                            <tr>
                                <td style="padding:10px 15px;color:#2e7d32;">Checkout Paid</td>
                                <td style="padding:10px 15px;"></td>
                                <td style="padding:10px 15px;text-align:right;font-weight:600;color:#2e7d32;" id="tdManual">0</td>
                            </tr>
                            <tr id="balanceRow">
                                <td style="padding:12px 15px;font-weight:700;text-transform:uppercase;font-size:.85rem;color:#1A1A2E;" id="balanceLabel">Net Balance</td>
                                <td colspan="2" style="padding:12px 15px;text-align:right;font-weight:800;font-family:'Courier New',monospace;font-size:1.05rem;">
                                    <span id="balanceDebit"></span><span id="balanceCredit">0</span>
                                </td>
                            </tr>
                        </table>
                    </div>

                    <div id="balanceMeter" style="margin-bottom:14px; padding:14px 18px; border-radius:10px; border:2px solid #e0d5c5; text-align:center; font-size:.88rem; font-weight:700; color:#7a7a7a; background:#f5f5f5; transition:all .3s;">
                        Enter details to see balance
                    </div>

                    <div class="no-print" style="display:flex;gap:10px;margin-bottom:16px;">
                        <asp:Button ID="btnSaveBill" runat="server" Text="Save &amp; Finalize Bill" CssClass="btn-dark" OnClick="btnSaveBill_Click" style="flex:1; background:linear-gradient(135deg,#C9A84C,#8B5E3C); color:#fff; border:none; padding:14px 10px; border-radius:8px; font-size:.9rem; font-weight:800; cursor:pointer; letter-spacing:.5px; box-shadow:0 4px 14px rgba(201,168,76,0.35); transition:all .2s;" />
                        <%--<button type="button" onclick="printBill()" class="btn-print" style="width:56px; background:#fff; border:1.5px solid #C9A84C; border-radius:8px; cursor:pointer; display:flex; align-items:center; justify-content:center; transition:all .2s;">--%>
                            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#C9A84C" stroke-width="2">
                                <path d="M6 9V2h12v7M6 18H4a2 2 0 01-2-2v-5a2 2 0 012-2h16a2 2 0 012 2v5a2 2 0 01-2 2h-2" />
                                <path d="M6 14h12v8H6z" />
                            </svg>
                        </button>
                    </div>
                </asp:Panel>

                <!-- BILLS HISTORY -->
                <div style="background:#ffffff; border:1px solid #e0d5c5; border-radius:10px; padding:16px 18px; position:relative; box-shadow:0 2px 10px rgba(0,0,0,0.06);">
                    <div style="position:absolute;top:0;left:0;right:0;height:4px; background:linear-gradient(90deg,#C9A84C,#8B5E3C); border-radius:10px 10px 0 0;"></div>
                    <div style="font-size:.67rem;font-weight:700;letter-spacing:2px; text-transform:uppercase;color:#8B5E3C; margin-bottom:12px;padding-bottom:8px; border-bottom:1px solid #e0d5c5; display:flex;justify-content:space-between;align-items:center;">
                        <span>&#9670; Bills History</span>
                        <asp:Label ID="lblBillCount" runat="server" Text="0" style="font-size:.68rem;background:#C9A84C; color:#1A1A2E;padding:2px 10px;border-radius:10px;font-weight:700;" />
                    </div>
                    <div style="overflow-x:auto;overflow-y:auto;max-height:380px; border-radius:7px;border:1px solid #e0d5c5;">
                        <asp:GridView ID="gvBills" runat="server" AutoGenerateColumns="false" CssClass="data-table" GridLines="None" OnRowCommand="gvBills_RowCommand" EmptyDataText="No bills yet." DataKeyNames="BillID">
                            <Columns>
                                <asp:TemplateField HeaderText="Bill No">
                                    <ItemTemplate>
                                        <span style="font-family:'Courier New',monospace;font-size:.68rem;color:#C9A84C;"><%# Eval("BillNo") %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Room">
                                    <ItemTemplate><%# Eval("RoomNo").ToString()=="0" ? "All" : Eval("RoomNo") %></ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Total" ItemStyle-HorizontalAlign="Right">
                                    <ItemTemplate><%# Math.Abs(Convert.ToDecimal(Eval("GrossTotal"))).ToString("N0") %></ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Status" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <span class='<%# GetBillStatusChip(Eval("BillStatus").ToString()) %>' style="font-size:.6rem;padding:2px 7px;"><%# Eval("BillStatus").ToString().ToLower() %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Button runat="server" Text="VIEW" CommandName="LoadBill" CommandArgument='<%# Eval("ReservationNo") %>' CssClass="btn-view" CausesValidation="false" style="background:linear-gradient(135deg,#1565C0,#0d47a1); color:#fff; border:none; padding:3px 9px; border-radius:4px; font-size:.65rem; font-weight:600; cursor:pointer;" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Print" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <button type="button" onclick="printExistingBill('<%# Eval("BillNo") %>', '<%# Eval("ReservationNo") %>')" style="background:#C9A84C; border:none; border-radius:4px; padding:3px 9px; cursor:pointer; font-size:.65rem; font-weight:600; color:#1A1A2E;">
                                            <i class="fas fa-print"></i> Print
                                        </button>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Void" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton runat="server" CommandName="VoidPayment" CommandArgument='<%# Eval("BillNo") %>' Visible='<%# Eval("BillNo").ToString().StartsWith("ADV-MID-") && Eval("BillStatus").ToString().ToUpper() != "VOID" %>' OnClientClick="return confirm('Are you sure you want to VOID this payment?');" CausesValidation="false" style="color:#c62828; font-size:.9rem; cursor:pointer; text-decoration:none;" ToolTip="Void Payment">
                                            <i class="fas fa-trash-alt"></i> Void
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>

        <!-- DETAILED LEDGER PANEL -->
        <asp:Panel ID="pnlDetailedLedger" runat="server" Visible="false" style="margin-top:24px;" class="no-print">
            <div style="background:#ffffff;border:1px solid #e0d5c5;border-radius:10px;padding:20px;position:relative;box-shadow:0 2px 10px rgba(0,0,0,0.06);">
                <div style="position:absolute;top:0;left:0;right:0;height:4px;background:linear-gradient(90deg,#C9A84C,#8B5E3C);border-radius:10px 10px 0 0;"></div>
                <div style="font-size:1.1rem;font-weight:700;color:#1A1A2E;margin-bottom:15px;display:flex;justify-content:space-between;align-items:center;">
                    <span><i class="fas fa-book"></i> Detailed Financial Ledger</span>
                </div>
                <div style="overflow-x:auto;">
                    <asp:GridView ID="gvLedger" runat="server" AutoGenerateColumns="False" GridLines="None" style="width:100%; border-collapse:collapse; font-size:0.88rem; background:#fff;" HeaderStyle-BackColor="#1A1A2E" HeaderStyle-ForeColor="#C9A84C" HeaderStyle-Font-Bold="True" HeaderStyle-Font-Size="X-Small" RowStyle-BackColor="#FFFFFF" RowStyle-ForeColor="#1e293b" AlternatingRowStyle-BackColor="#F8F9FA">
                        <EmptyDataTemplate>
                            <div style="padding:32px; text-align:center; color:#7a7a7a;"><i class="fas fa-file-alt" style="font-size:2.5rem; margin-bottom:12px; display:block;"></i>No financial records found.</div>
                        </EmptyDataTemplate>
                        <Columns>
                            <asp:TemplateField HeaderText="Date">
                                <HeaderStyle BackColor="#1A1A2E" ForeColor="#C9A84C" Font-Bold="True" Font-Size="X-Small" />
                                <HeaderTemplate><span style="display:block; padding:12px 15px; text-transform:uppercase;">Date</span></HeaderTemplate>
                                <ItemTemplate><div style="padding:12px 15px;"><%# Convert.ToDateTime(Eval("Date")).ToString("dd-MMM-yyyy HH:mm") %></div></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Ref / Invoice">
                                <HeaderTemplate><span style="display:block; padding:12px 15px; text-transform:uppercase;">Ref / Invoice</span></HeaderTemplate>
                                <ItemTemplate><div style="padding:12px 15px; font-family:'Courier New',monospace; font-weight:600;"><%# Eval("RefNo") %></div></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Description">
                                <HeaderTemplate><span style="display:block; padding:12px 15px; text-transform:uppercase;">Description</span></HeaderTemplate>
                                <ItemTemplate><div style="padding:12px 15px;"><%# Eval("Description") %></div></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Debit (PKR)">
                                <HeaderTemplate><span style="display:block; padding:12px 15px; text-align:right; text-transform:uppercase;">Debit (PKR)</span></HeaderTemplate>
                                <ItemTemplate><div style="padding:12px 15px; text-align:right; color:#c62828;"><%# Convert.ToDecimal(Eval("Debit")).ToString("N0") %></div></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Credit (PKR)">
                                <HeaderTemplate><span style="display:block; padding:12px 15px; text-align:right; text-transform:uppercase;">Credit (PKR)</span></HeaderTemplate>
                                <ItemTemplate><div style="padding:12px 15px; text-align:right; color:#2e7d32;"><%# Convert.ToDecimal(Eval("Credit")).ToString("N0") %></div></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Balance">
                                <HeaderTemplate><span style="display:block; padding:12px 15px; text-align:right; text-transform:uppercase;">Balance</span></HeaderTemplate>
                                <ItemTemplate><div style="padding:12px 15px; text-align:right; font-weight:700; color:#C9A84C;"><%# Convert.ToDecimal(Eval("Balance")).ToString("N0") %></div></ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </asp:Panel>

        <!-- PRINTABLE BILL SLIP - SUMMARY VERSION -->
        <div id="receiptSlip" style="display:none; background:#fff; width:100%; max-width:800px; margin:24px auto 0; padding:40px; border:1px solid #ddd; font-family:'Segoe UI',sans-serif; color:#333; border-radius:8px;">
            <div style="text-align:center;border-bottom:2px solid #333;padding-bottom:15px;margin-bottom:20px;">
                <img src="images/lahore_gymkhana_logo1.png" alt="Lahore Gymkhana Logo" style="height:70px; width:auto; display:block; margin:0 auto 10px auto;" />
                <h2 style="margin:0;letter-spacing:2px;color:#1A1A2E;">LAHORE GYMKHANA</h2>
                <div style="font-size:.84rem;margin-top:5px;color:#555;">Upper Mall, Lahore, Pakistan &nbsp;|&nbsp; Tel: +92-42-111-111-231</div>
                <h4 style="margin:15px 0 0;text-transform:uppercase;border:1px solid #333;display:inline-block;padding:4px 20px;letter-spacing:2px;" id="receiptTitle">GUEST ROOM BILL</h4>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:20px;">
                <div>
                    <div style="font-size:.72rem;font-weight:700;text-transform:uppercase;color:#777;" id="rBillNo">Bill #: —</div>
                    <div style="font-size:.72rem;font-weight:700;text-transform:uppercase;color:#777;" id="rBillDate">Date: —</div>
                    <div style="margin-top:14px;"><div style="font-size:.72rem;font-weight:700;text-transform:uppercase;color:#777;">Guest Name</div><div style="font-size:.94rem;font-weight:600;color:#111;" id="rGuestName">—</div></div>
                    <div style="margin-top:10px;"><div style="font-size:.72rem;font-weight:700;text-transform:uppercase;color:#777;">Guest Of / Club</div><div style="font-size:.94rem;font-weight:600;color:#111;"><span id="rGuestOf"></span> / <span id="rClub"></span></div></div>
                </div>
                <div style="text-align:right;">
                    <div style="font-size:.72rem;font-weight:700;text-transform:uppercase;color:#777;">Reservation Ref</div>
                    <div style="font-size:.94rem;font-weight:600;color:#111;" id="rResNo">—</div>
                    <div style="margin-top:14px;"><div style="font-size:.72rem;font-weight:700;text-transform:uppercase;color:#777;">Stay Duration</div><div style="font-size:.94rem;font-weight:600;color:#111;"><span id="rCheckIn"></span> to <span id="rCheckOut"></span></div></div>
                    <div style="margin-top:10px;"><div style="font-size:.72rem;font-weight:700;text-transform:uppercase;color:#777;">Room(s)</div><div style="font-size:.94rem;font-weight:600;color:#111;" id="rRoomNo">—</div></div>
                </div>
            </div>
            
            <!-- DYNAMIC BODY - will be populated by JavaScript based on bill type -->
            <div id="receiptBody"></div>
            
            <div style="margin-top:60px;display:flex;justify-content:space-between;">
                <div style="text-align:center;width:200px;border-top:1px solid #333;padding-top:6px;font-size:.78rem;color:#555;">Guest Signature</div>
                <div style="text-align:center;width:200px;border-top:1px solid #333;padding-top:6px;font-size:.78rem;color:#555;">Receptionist / Manager</div>
            </div>
            <div style="margin-top:36px;text-align:center;font-size:.72rem;color:#aaa;border-top:1px dashed #ccc;padding-top:14px;">This is a computer generated receipt. E&amp;OE.</div>
        </div>

        <!-- PRINTABLE DETAILED BILL TEMPLATE (hidden, used for detailed printing) -->
        <div id="detailedBillTemplate" style="display:none;">
            <div style="padding:20px;">
                <h3 style="margin-bottom:15px;color:#1A1A2E;">Detailed Transaction Breakup</h3>
                <table id="detailedTransactionsTable" style="width:100%; border-collapse:collapse; margin-top:15px;">
                    <thead>
                        <tr style="background:#f4f4f4;">
                            <th style="padding:8px; text-align:left; border-bottom:1px solid #ddd;">Date</th>
                            <th style="padding:8px; text-align:left; border-bottom:1px solid #ddd;">Description</th>
                            <th style="padding:8px; text-align:right; border-bottom:1px solid #ddd;">Debit (PKR)</th>
                            <th style="padding:8px; text-align:right; border-bottom:1px solid #ddd;">Credit (PKR)</th>
                        </tr>
                    </thead>
                    <tbody id="detailedTransactionsBody"></tbody>
                </table>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        let currentBillData = null;
        let currentBillType = 'SUMMARY';
        
        function num(id) {
            var el = document.getElementById(id);
            return el ? (parseFloat(el.value) || 0) : 0;
        }
        
        function fmtN(n) {
            return n.toLocaleString('en-PK', { minimumFractionDigits: 0, maximumFractionDigits: 0 });
        }
        
        function setText(id, val) {
            var el = document.getElementById(id);
            if (el) el.innerHTML = val;
        }

        function calcBill() {
            var rooms = num('<%= txtNoOfRooms.ClientID %>');
            var nights = num('<%= txtNoOfNights.ClientID %>');
            var rate = num('<%= txtRentPerNight.ClientID %>');
            var taxPct = num('<%= txtTaxPercent.ClientID %>');
            var other = num('<%= txtOtherCharges.ClientID %>');
            var advance = num('<%= txtAdvancePaid.ClientID %>');
            var manual = num('<%= txtManualPay.ClientID %>');
            var cashPayBack = num('<%= txtCashPayBack.ClientID %>');
            var roomDesc = document.getElementById('<%= hfRoomDescription.ClientID %>').value;

            var roomRent = rooms * nights * rate;
            var tax = Math.round(roomRent * taxPct / 100);
            var gross = roomRent + tax + other;
            var totalPaid = advance + manual - cashPayBack;
            var balance = gross - totalPaid;
            var payback = totalPaid > gross ? totalPaid - gross : 0;
            var netBal = balance < 0 ? 0 : balance;

            setText('spanRooms', rooms);
            setText('spanNights', nights);
            setText('spanTaxPct', taxPct);
            setText('spanRoomDesc', roomDesc || 'No room details');
            setText('tdRoomRent', fmtN(roomRent));
            setText('tdTax', fmtN(tax));
            setText('tdOther', fmtN(other));
            setText('tdGross', '<strong>' + fmtN(gross) + '</strong>');
            setText('tdAdvance', fmtN(advance));
            setText('tdManual', fmtN(manual));

            var meter = document.getElementById('balanceMeter');
            var balRow = document.getElementById('balanceRow');
            var balD = document.getElementById('balanceDebit');
            var balC = document.getElementById('balanceCredit');
            var balLbl = document.getElementById('balanceLabel');

            if (payback > 0) {
                balLbl.innerHTML = '<strong>Pay Back to Guest</strong>';
                balD.innerHTML = '—';
                balC.innerHTML = '<strong>' + fmtN(payback) + '</strong>';
                balRow.className = 'balance-refund';
                meter.innerHTML = '&#9651; Pay Back PKR ' + fmtN(payback) + ' to Guest (Advance Excess)';
                meter.style.cssText = 'margin-bottom:14px;padding:14px 18px;border-radius:10px;text-align:center;font-size:.88rem;font-weight:700;transition:all .3s;background:#fff3e0;border:2px solid #e65100;color:#e65100;';
            } else if (netBal === 0) {
                balLbl.innerHTML = '<strong>&#10003; Settled</strong>';
                balD.innerHTML = '';
                balC.innerHTML = '<strong>PKR 0 (Settled)</strong>';
                balRow.className = 'balance-settled';
                meter.innerHTML = '&#10003; Bill Settled - Debit &amp; Credit Match';
                meter.style.cssText = 'margin-bottom:14px;padding:14px 18px;border-radius:10px;text-align:center;font-size:.88rem;font-weight:700;transition:all .3s;background:#e8f5e9;border:2px solid #2e7d32;color:#2e7d32;';
            } else {
                balLbl.innerHTML = '<strong>Amount Due</strong>';
                balD.innerHTML = '<strong>' + fmtN(netBal) + '</strong>';
                balC.innerHTML = '';
                balRow.className = 'balance-due';
                meter.innerHTML = '&#9651; PKR ' + fmtN(netBal) + ' still due from guest';
                meter.style.cssText = 'margin-bottom:14px;padding:14px 18px;border-radius:10px;text-align:center;font-size:.88rem;font-weight:700;transition:all .3s;background:#fce4ec;border:2px solid #c62828;color:#c62828;';
            }
            
            // Store current data for printing
            currentBillData = {
                rooms: rooms, nights: nights, rate: rate, taxPct: taxPct, other: other,
                advance: advance, manual: manual, cashPayBack: cashPayBack,
                roomRent: roomRent, tax: tax, gross: gross, totalPaid: totalPaid, 
                balance: netBal, payback: payback, roomDesc: roomDesc
            };
        }

        function getBillType() {
            var ddl = document.getElementById('<%= ddlBillType.ClientID %>');
            return ddl ? ddl.value : 'SUMMARY';
        }

        function printBill() {
            var billType = getBillType();
            var slip = document.getElementById('receiptSlip');
            var receiptBody = document.getElementById('receiptBody');
            var titleEl = document.getElementById('receiptTitle');
            
            if (billType === 'DETAILED') {
                titleEl.innerHTML = 'GUEST ROOM BILL - DETAILED BREAKDOWN';
                receiptBody.innerHTML = generateDetailedBillHTML();
            } else {
                titleEl.innerHTML = 'GUEST ROOM BILL';
                receiptBody.innerHTML = generateSummaryBillHTML();
            }
            
            slip.style.display = 'block';
            window.print();
            
            // Hide after print (print dialog handles visibility)
            setTimeout(function() {
                slip.style.display = 'none';
            }, 100);
        }

        function generateSummaryBillHTML() {
            if (!currentBillData) return '<p>No bill data available</p>';
            
            var d = currentBillData;
            var paymentMode = getPaymentMode();
            var bankDetails = getBankDetailsHTML();
            
            return `
                <table style="width:100%; border-collapse:collapse; margin-top:10px;">
                    <thead>
                        <tr>
                            <th style="background:#f4f4f4; text-align:left; padding:10px; border-bottom:1px solid #333;">DESCRIPTION</th>
                            <th style="background:#f4f4f4; text-align:right; padding:10px; border-bottom:1px solid #333;">AMOUNT (PKR)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td style="padding:10px; border-bottom:1px solid #eee;">Room Rent: ${d.rooms} R × ${d.nights} N @ PKR ${fmtN(d.rate)}<br/><span style="font-size:.7rem; color:#666;">${d.roomDesc || ''}</span></td>
                            <td style="padding:10px; border-bottom:1px solid #eee; text-align:right;">${fmtN(d.roomRent)}</td>
                        </tr>
                        <tr>
                            <td style="padding:10px; border-bottom:1px solid #eee;">GST / Sales Tax (${d.taxPct}%)</td>
                            <td style="padding:10px; border-bottom:1px solid #eee; text-align:right;">${fmtN(d.tax)}</td>
                        </tr>
                        <tr>
                            <td style="padding:10px; border-bottom:1px solid #eee;">Other Services &amp; Charges</td>
                            <td style="padding:10px; border-bottom:1px solid #eee; text-align:right;">${fmtN(d.other)}</td>
                        </tr>
                    </tbody>
                </table>
                <div style="display:flex; justify-content:flex-end; gap:30px; padding:10px; background:#f9f9f9; border-top:2px solid #333; margin-top:10px;">
                    <div style="font-weight:700;">GROSS TOTAL</div>
                    <div style="font-weight:700; width:120px; text-align:right;">${fmtN(d.gross)}</div>
                </div>
                <div style="display:flex; justify-content:flex-end; gap:30px; padding:8px 10px; border-bottom:1px solid #eee;">
                    <div style="color:#c62828;">Advance Payments / Credits</div>
                    <div style="font-weight:600; width:120px; text-align:right;">${fmtN(d.advance)}</div>
                </div>
                <div style="display:flex; justify-content:flex-end; gap:30px; padding:8px 10px; border-bottom:1px solid #eee;">
                    <div style="color:#2e7d32;">Payment at Checkout</div>
                    <div style="font-weight:600; width:120px; text-align:right;">${fmtN(d.manual)}</div>
                </div>
                ${d.cashPayBack > 0 ? `
                <div style="display:flex; justify-content:flex-end; gap:30px; padding:8px 10px; border-bottom:1px solid #eee;">
                    <div style="color:#e65100;">Cash Pay Back to Guest</div>
                    <div style="font-weight:600; width:120px; text-align:right;">${fmtN(d.cashPayBack)}</div>
                </div>` : ''}
                ${paymentMode ? `<div style="display:flex; justify-content:flex-end; gap:30px; padding:8px 10px; border-bottom:1px solid #eee;">
                    <div style="color:#555;">Payment Mode</div>
                    <div style="font-weight:500; width:120px; text-align:right;">${paymentMode}</div>
                </div>` : ''}
                ${bankDetails}
                <div style="display:flex; justify-content:flex-end; gap:30px; padding:10px; background:#1A1A2E; color:#fff; margin-top:5px;">
                    <div style="font-weight:700; text-transform:uppercase;">${d.payback > 0 ? 'PAY BACK TO GUEST' : (d.balance === 0 ? 'SETTLED' : 'AMOUNT DUE')}</div>
                    <div style="font-weight:700; width:120px; text-align:right; font-size:1.05rem;">${d.payback > 0 ? fmtN(d.payback) : (d.balance === 0 ? 'PKR 0' : fmtN(d.balance))}</div>
                </div>
            `;
        }

        function generateDetailedBillHTML() {
            if (!currentBillData) return '<p>No bill data available</p>';
            
            var d = currentBillData;
            var paymentMode = getPaymentMode();
            var bankDetails = getBankDetailsHTML();
            
            return `
                <h4 style="margin:15px 0 10px; color:#C9A84C;">Room Charges Breakdown</h4>
                <table style="width:100%; border-collapse:collapse; margin-bottom:15px;">
                    <thead>
                        <tr><th style="background:#f4f4f4; padding:8px; text-align:left;">Description</th><th style="background:#f4f4f4; padding:8px; text-align:right;">Amount</th></tr>
                    </thead>
                    <tbody>
                        <tr><td style="padding:6px; border-bottom:1px solid #eee;">Room Rent (${d.rooms} Rooms × ${d.nights} Nights)</td><td style="padding:6px; text-align:right;">${fmtN(d.roomRent)}</td></tr>
                        <tr><td style="padding:6px; border-bottom:1px solid #eee;">GST / Tax @ ${d.taxPct}%</td><td style="padding:6px; text-align:right;">${fmtN(d.tax)}</td></tr>
                        <tr><td style="padding:6px; border-bottom:1px solid #eee;">Other Services</td><td style="padding:6px; text-align:right;">${fmtN(d.other)}</td></tr>
                        <tr style="background:#f9f9f9; font-weight:bold;"><td style="padding:8px;">Subtotal</td><td style="padding:8px; text-align:right;">${fmtN(d.gross)}</td></tr>
                    </tbody>
                </table>
                
                <h4 style="margin:15px 0 10px; color:#C9A84C;">Payments & Adjustments</h4>
                <table style="width:100%; border-collapse:collapse; margin-bottom:15px;">
                    <thead><tr><th style="background:#f4f4f4; padding:8px; text-align:left;">Description</th><th style="background:#f4f4f4; padding:8px; text-align:right;">Amount</th></tr></thead>
                    <tbody>
                        <tr><td style="padding:6px; border-bottom:1px solid #eee;">Advance Payment</td><td style="padding:6px; text-align:right; color:#c62828;">(${fmtN(d.advance)})</td></tr>
                        <tr><td style="padding:6px; border-bottom:1px solid #eee;">Checkout Payment</td><td style="padding:6px; text-align:right; color:#c62828;">(${fmtN(d.manual)})</td></tr>
                        ${d.cashPayBack > 0 ? `<tr><td style="padding:6px; border-bottom:1px solid #eee;">Cash Pay Back</td><td style="padding:6px; text-align:right; color:#e65100;">+${fmtN(d.cashPayBack)}</td></tr>` : ''}
                        ${paymentMode ? `<tr><td style="padding:6px; border-bottom:1px solid #eee;">Payment Mode</td><td style="padding:6px; text-align:right;">${paymentMode}</td></tr>` : ''}
                    </tbody>
                </table>
                ${bankDetails}
                
                <div style="display:flex; justify-content:flex-end; gap:30px; padding:10px; background:#1A1A2E; color:#fff; margin-top:10px;">
                    <div style="font-weight:700; text-transform:uppercase;">NET ${d.payback > 0 ? 'REFUND' : (d.balance === 0 ? 'SETTLED' : 'DUE')}</div>
                    <div style="font-weight:700; width:120px; text-align:right;">${d.payback > 0 ? fmtN(d.payback) : (d.balance === 0 ? '0' : fmtN(d.balance))}</div>
                </div>
                
                <div style="margin-top:15px; padding:10px; background:#f9f9f9; font-size:.8rem;">
                    <strong>Room Details:</strong> ${d.roomDesc || 'No additional details'}
                </div>
            `;
        }

        function getPaymentMode() {
            var ddl = document.getElementById('<%= ddlPaymentMode.ClientID %>');
            return ddl ? ddl.options[ddl.selectedIndex].text : 'Cash';
        }

        function getBankDetailsHTML() {
            var ddl = document.getElementById('<%= ddlPaymentMode.ClientID %>');
            if (!ddl) return '';
            
            var mode = ddl.value;
            if (mode === 'Online Bank Payment' || mode === 'Credit Card') {
                var bankId = document.getElementById('<%= txtBankTillID.ClientID %>');
                var refId = document.getElementById('<%= txtRefID.ClientID %>');
                var bankText = bankId ? bankId.value : '';
                var refText = refId ? refId.value : '';
                
                if (bankText || refText) {
                    return `
                        <div style="margin-top:10px; padding:8px; background:#e8f5e9; border-radius:5px;">
                            <strong>Payment Details:</strong><br/>
                            ${bankText ? `Bank/Till: ${bankText}<br/>` : ''}
                            ${refText ? `Reference ID: ${refText}` : ''}
                        </div>
                    `;
                }
            }
            return '';
        }

        function togglePaymentFields() {
            var ddl = document.getElementById('<%= ddlPaymentMode.ClientID %>');
            var divBank = document.getElementById('divBankDetails');
            if (ddl && divBank) {
                if (ddl.value === 'Online Bank Payment' || ddl.value === 'Credit Card') {
                    divBank.style.display = 'flex';
                } else {
                    divBank.style.display = 'none';
                }
            }
        }

        function showReceipt(d) {
            // Store data and update display based on bill type
            currentBillData = {
                rooms: parseFloat(d.rooms), nights: parseFloat(d.nights), rate: parseFloat(d.roomRent.replace(/[^0-9.-]/g, '')),
                taxPct: parseFloat(d.tax.replace(/[^0-9.-]/g, '')) / (parseFloat(d.roomRent.replace(/[^0-9.-]/g, '')) || 1) * 100,
                other: parseFloat(d.other.replace(/[^0-9.-]/g, '')),
                advance: parseFloat(d.advance.replace(/[^0-9.-]/g, '')),
                manual: parseFloat(d.manual.replace(/[^0-9.-]/g, '')),
                cashPayBack: parseFloat(d.payback || '0'),
                roomRent: parseFloat(d.roomRent.replace(/[^0-9.-]/g, '')),
                tax: parseFloat(d.tax.replace(/[^0-9.-]/g, '')),
                gross: parseFloat(d.gross.replace(/[^0-9.-]/g, '')),
                totalPaid: parseFloat(d.advance.replace(/[^0-9.-]/g, '')) + parseFloat(d.manual.replace(/[^0-9.-]/g, '')),
                balance: parseFloat(d.balance.replace(/[^0-9.-]/g, '')),
                payback: parseFloat(d.payback || '0'),
                roomDesc: d.roomDesc || ''
            };
            
            document.getElementById('rBillNo').innerText = 'Bill #: ' + d.billNo;
            document.getElementById('rBillDate').innerText = 'Date: ' + d.date;
            document.getElementById('rGuestName').innerText = d.guest;
            document.getElementById('rGuestOf').innerText = d.guestOf;
            document.getElementById('rClub').innerText = d.club;
            document.getElementById('rResNo').innerText = d.resNo;
            document.getElementById('rCheckIn').innerText = d.checkIn;
            document.getElementById('rCheckOut').innerText = d.checkOut;
            document.getElementById('rRoomNo').innerText = d.roomNo;
            
            var billType = getBillType();
            var receiptBody = document.getElementById('receiptBody');
            var titleEl = document.getElementById('receiptTitle');
            
            if (billType === 'DETAILED') {
                titleEl.innerHTML = 'GUEST ROOM BILL - DETAILED BREAKDOWN';
                receiptBody.innerHTML = generateDetailedBillHTML();
            } else {
                titleEl.innerHTML = 'GUEST ROOM BILL';
                receiptBody.innerHTML = generateSummaryBillHTML();
            }
            
            document.getElementById('receiptSlip').style.display = 'block';
        }
        
        function printExistingBill(billNo, resNo) {
            window.location.href = 'PrintBill.aspx?BillNo=' + billNo + '&ResNo=' + resNo;
        }
        
        document.addEventListener('DOMContentLoaded', function() {
            togglePaymentFields();
            
            var ddlBillType = document.getElementById('<%= ddlBillType.ClientID %>');
            if (ddlBillType) {
                ddlBillType.addEventListener('change', function() {
                    calcBill();
                });
            }
        });
    </script>
</asp:Content>