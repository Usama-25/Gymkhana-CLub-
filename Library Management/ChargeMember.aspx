<%@ page language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" autoeventwireup="true" CodeFile="ChargeMember.aspx.cs" Inherits="Pages_Members_ChargeMember" title="Billing & Voucher Desk - Lahore Gymkhana Library" %>

<asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        /* Keep print layout styling */
        .print-only {
            display: none !important;
        }

        @media print {
            body * {
                visibility: hidden;
            }
            .print-section, .print-section * {
                visibility: visible;
            }
            .print-section {
                position: absolute;
                left: 0;
                top: 0;
                width: 100%;
                box-shadow: none !important;
                border: none !important;
            }
            .no-print {
                display: none !important;
            }
        }
        /* Custom style for printed receipt items */
        .receipt-header {
            border-bottom: 1px dashed #000000 !important;
            padding: 8px 4px !important;
            font-size: 13px !important;
            text-align: left !important;
        }
        .receipt-row {
            border-bottom: 1px dashed #000000 !important;
            padding: 8px 4px !important;
            font-size: 13px !important;
        }
    </style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">

<asp:UpdatePanel ID="upChargeMember" runat="server" UpdateMode="Conditional">
<ContentTemplate>

<!-- Header Banner -->
<div class="no-print" style="background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; padding: 20px 28px; border-radius: 8px; margin-bottom: 24px; border-bottom: 3px solid #c5a059; display: flex; justify-content: space-between; align-items: center; width: 100%; box-sizing: border-box;">
    <div>
        <h2 style="margin: 0; font-size: 22px; font-weight: 600;">Billing & Voucher Desk</h2>
        <p style="margin: 4px 0 0; opacity: .8; font-size: 13px; font-weight: 300;">Log facility charges, book issuance fees, bundle unpaid items to invoices, and pay cashier vouchers</p>
    </div>
</div>

<!-- Alert Panel -->
<asp:Panel ID="pnlAlert" runat="server" Visible="false" style="width: 100%;">
    <div id="divAlert" runat="server" style="padding: 16px 24px; border-radius: 8px; font-size: 14.5px; margin-bottom: 24px; border-left: 4px solid transparent; width: 100%; box-sizing: border-box;">
        <asp:Literal ID="litAlertMsg" runat="server" />
    </div>
</asp:Panel>

<!-- Policy Warning Panel -->
<asp:Panel ID="pnlPolicyWarning" runat="server" Visible="false" style="width: 100%;">
    <div id="divPolicyWarning" runat="server" style="padding: 16px 24px; border-radius: 8px; font-size: 14px; margin-bottom: 24px; border-left: 4px solid #f59e0b; background-color: #fef3c7; color: #92400e; width: 100%; box-sizing: border-box;">
        <strong style="font-weight: 700;">Library Policy Alerts / Warnings:</strong>
        <ul style="margin: 8px 0 0 20px; padding: 0; line-height: 1.5;">
            <asp:Literal ID="litPolicyWarningMsg" runat="server" />
        </ul>
    </div>
</asp:Panel>

<!-- Tabs Header -->
<div class="no-print" style="display: flex; gap: 4px; border-bottom: 2px solid #e2e8f0; margin-bottom: 24px;">
    <asp:Button ID="btnTabCharge" runat="server" Text="1. Log Manual Charge" style="padding: 12px 24px; font-size: 14px; font-weight: 600; color: #64748b; background: transparent; border: none; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.2s ease; outline: none;" OnClick="btnTab_Click" CommandArgument="CHARGE" UseSubmitBehavior="false" />
    <asp:Button ID="btnTabVoucher" runat="server" Text="2. Generate Voucher / Slip" style="padding: 12px 24px; font-size: 14px; font-weight: 600; color: #64748b; background: transparent; border: none; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.2s ease; outline: none;" OnClick="btnTab_Click" CommandArgument="VOUCHER" UseSubmitBehavior="false" />
    <asp:Button ID="btnTabCashier" runat="server" Text="3. Cashier Payment Desk" style="padding: 12px 24px; font-size: 14px; font-weight: 600; color: #64748b; background: transparent; border: none; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.2s ease; outline: none;" OnClick="btnTab_Click" CommandArgument="CASHIER" UseSubmitBehavior="false" />
</div>

<asp:HiddenField ID="hfActiveTab" runat="server" Value="CHARGE" />

<!-- =========================================================================
     TAB 1: LOG MANUAL CHARGES
     ========================================================================= -->
<asp:Panel ID="pnlTabCharge" runat="server" CssClass="no-print">
    <div style="display: flex; gap: 28px; flex-wrap: wrap; width: 100%; box-sizing: border-box; align-items: flex-start;">
        <!-- LEFT: INPUT FORM CARD -->
        <div style="flex: 1; min-width: 320px; box-sizing: border-box;">
            <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); padding: 28px; box-sizing: border-box; width: 100%; margin-bottom: 24px;">
                <h3 style="font-size: 18px; font-weight: 700; color: #0f1e36; margin: 0 0 20px 0; border-bottom: 2px solid #cbd5e1; padding-bottom: 8px;">Log Charges for a Member</h3>
                <div style="display: flex; flex-direction: column; gap: 18px; width: 100%;">
                    <div style="display: flex; flex-direction: column; gap: 6px;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 6px;">Search Member</span>
                        <div style="display: flex; gap: 8px; width: 100%;">
                            <asp:TextBox ID="txtChargeMemberSearch" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" placeholder="Enter member name or number..." autocomplete="off" list="dlChargeMembers" oninput="fetchMembersCharge(this.value)" />
                            <datalist id="dlChargeMembers"></datalist>
                            <asp:Button ID="btnSelectChargeMember" runat="server" Text="Select" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1);" OnClick="btnSelectChargeMember_Click" />
                        </div>
                    </div>

                    <asp:Panel ID="pnlChargeForm" runat="server" Visible="false" style="display: flex; flex-direction: column; gap: 18px; width:100%;">
                        <div style="background-color: #f1f5f9; padding: 12px 18px; border-radius: 8px; font-size: 14px; color: #0f1e36;">
                            Selected Member: <strong><asp:Label ID="lblChargeMemberName" runat="server" /></strong> (<asp:Label ID="lblChargeMemberNo" runat="server" />)
                            <asp:HiddenField ID="hfChargeMemberID" runat="server" />
                        </div>

                        <div style="display: flex; flex-direction: column; gap: 6px;">
                            <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 6px;">Charge Category</span>
                            <asp:DropDownList ID="ddlChargeType" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" AutoPostBack="true" OnSelectedIndexChanged="ddlChargeType_SelectedIndexChanged">
                                <asp:ListItem Value="FACILITY" Selected="True">Facility Booking Charge</asp:ListItem>
                                <asp:ListItem Value="FINE">Library Fine / Book Issuance Fee</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <!-- Facility Booking Charge Block -->
                        <asp:Panel ID="pnlFacilityFields" runat="server">
                            <div style="display: flex; flex-direction: column; gap: 18px;">
                                <div style="display: flex; flex-direction: column; gap: 6px;">
                                    <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 6px;">Select Facility</span>
                                    <asp:DropDownList ID="ddlFacility" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" AutoPostBack="true" OnSelectedIndexChanged="ddlFacility_SelectedIndexChanged" />
                                </div>
                                <div style="display: flex; gap: 12px; flex-wrap: wrap;">
                                    <div style="display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 140px;">
                                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 6px;">Rate Per Hour (PKR)</span>
                                        <asp:TextBox ID="txtFacilityRate" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #f8fafc; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" ReadOnly="true" />
                                    </div>
                                    <div style="display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 140px;">
                                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 6px;">Hours Used</span>
                                        <asp:TextBox ID="txtHoursUsed" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" placeholder="e.g. 2.5" AutoPostBack="true" OnTextChanged="txtHoursUsed_TextChanged" />
                                    </div>
                                    <div style="display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 140px;">
                                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 6px;">Total Charge (PKR)</span>
                                        <asp:TextBox ID="txtFacilityTotal" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" placeholder="0.00" />
                                    </div>
                                </div>
                                <div style="display: flex; flex-direction: column; gap: 6px;">
                                    <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 6px;">Usage Date</span>
                                    <asp:TextBox ID="txtFacilityDate" runat="server" TextMode="Date" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" />
                                </div>
                            </div>
                        </asp:Panel>

                        <!-- Library Fine / Issuance Block -->
                        <asp:Panel ID="pnlFineFields" runat="server" Visible="false">
                            <div style="display: flex; flex-direction: column; gap: 18px;">
                                <div style="display: flex; flex-direction: column; gap: 6px;">
                                    <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 6px;">Charge Reason</span>
                                    <asp:DropDownList ID="ddlFineReason" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" AutoPostBack="true" OnSelectedIndexChanged="ddlFineReason_SelectedIndexChanged" />
                                </div>
                                <div style="display: flex; flex-direction: column; gap: 6px;">
                                    <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 6px;">Link to Active Loan (Optional)</span>
                                    <asp:DropDownList ID="ddlActiveLoans" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" AutoPostBack="true" OnSelectedIndexChanged="ddlActiveLoans_SelectedIndexChanged" />
                                </div>
                                <div style="display: flex; flex-direction: column; gap: 6px;">
                                    <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 6px;">Amount (PKR)</span>
                                    <asp:TextBox ID="txtFineAmount" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" placeholder="0.00" />
                                </div>
                            </div>
                        </asp:Panel>

                        <div style="display: flex; flex-direction: column; gap: 6px;">
                            <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 6px;">Remarks / Description</span>
                            <asp:TextBox ID="txtChargeRemarks" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: auto; transition: border-color 0.2s ease;" placeholder="Enter usage notes or checkout detail..." Rows="2" TextMode="MultiLine" />
                        </div>

                        <div style="margin-top: 10px;">
                            <asp:Button ID="btnAddToBasket" runat="server" Text="Add to Basket" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2);" OnClick="btnAddToBasket_Click" />
                        </div>
                    </asp:Panel>
                </div>
            </div>
        </div>

        <!-- RIGHT: BASKET CARD -->
        <div style="flex: 1; min-width: 320px; box-sizing: border-box;">
            <asp:Panel ID="pnlChargeBasketContainer" runat="server" Visible="false" style="width: 100%;">
                <div id="pnlChargeBasketSection" runat="server" style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); overflow: hidden; width: 100%; box-sizing: border-box;">
                    <div style="padding: 16px 24px; font-size: 15px; font-weight: 700; color: #ffffff; display: flex; justify-content: space-between; align-items: center; background-color: #0f1e36; border-bottom: 3px solid #c5a059;">
                        <span>Pending Charges Basket</span>
                    </div>
                    <div style="padding: 20px; width: 100%; box-sizing: border-box;">
                        <asp:GridView ID="gvChargeBasket" runat="server" AutoGenerateColumns="False" 
                            OnRowCommand="gvChargeBasket_RowCommand" GridLines="None"
                            style="width: 100%; border-collapse: collapse; font-size: 13.5px; color: #1e293b;">
                            <HeaderStyle CssClass="gv-header" />
                            <RowStyle CssClass="gv-row" />
                            <AlternatingRowStyle CssClass="gv-alt-row" />
                            <Columns>
                                <asp:TemplateField HeaderStyle-CssClass="gv-text-center" ItemStyle-CssClass="gv-text-center" ItemStyle-Width="40px">
                                    <ItemTemplate>
                                        <%# Container.DataItemIndex + 1 %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="TypeDisplay" HeaderText="Category" HeaderStyle-CssClass="gv-text-left" ItemStyle-CssClass="gv-text-left" />
                                <asp:BoundField DataField="ItemName" HeaderText="Charge Item" HeaderStyle-CssClass="gv-text-left" ItemStyle-CssClass="gv-text-left" />
                                <asp:BoundField DataField="LoanDisplay" HeaderText="Linked Info / Date" HeaderStyle-CssClass="gv-text-left" ItemStyle-CssClass="gv-text-left" />
                                <asp:BoundField DataField="Remarks" HeaderText="Remarks" HeaderStyle-CssClass="gv-text-left" ItemStyle-CssClass="gv-text-left" />
                                <asp:TemplateField HeaderText="Amount" HeaderStyle-CssClass="gv-text-right" ItemStyle-CssClass="gv-text-right" ItemStyle-Font-Bold="true">
                                    <ItemTemplate>
                                        Rs. <%# Eval("Amount", "{0:N2}") %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderStyle-CssClass="gv-text-center" ItemStyle-CssClass="gv-text-center" ItemStyle-Width="60px">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnRemove" runat="server" CommandName="RemoveItem" CommandArgument='<%# Container.DataItemIndex %>'
                                            style="color: #ef4444; font-weight: 600; text-decoration: none; font-size: 13px;">Remove</asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>

                        <asp:Panel ID="pnlChargeBasketEmpty" runat="server" style="text-align: center; padding: 20px; color: #94a3b8;">
                            <p style="margin: 0; font-size: 13px;">No charges added to the pending basket yet.</p>
                        </asp:Panel>

                        <div id="divConfirmCharges" runat="server" style="margin-top: 16px; display: none; justify-content: space-between; align-items: center;">
                            <div>
                                <span style="font-size:11px; font-weight:700; color:#64748b; text-transform:uppercase;">Total Basket Charges</span>
                                <div style="font-size:20px; font-weight:800; color:#ef4444;" id="divBasketTotal" runat="server">Rs. 0.00</div>
                            </div>
                            <asp:Button ID="btnRecordAllCharges" runat="server" Text="Record All Charges" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2);" OnClick="btnRecordAllCharges_Click" />
                        </div>
                    </div>
                </div>
            </asp:Panel>
        </div>
    </div>
</asp:Panel>

<!-- =========================================================================
     TAB 2: GENERATE VOUCHERS
     ========================================================================= -->
<asp:Panel ID="pnlTabVoucher" runat="server" Visible="false" class="no-print" style="width: 100%;">
    <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); padding: 28px; box-sizing: border-box; width: 100%; margin-bottom: 24px;">
        <h3 style="font-size: 18px; font-weight: 700; color: #0f1e36; margin: 0 0 20px 0; border-bottom: 2px solid #cbd5e1; padding-bottom: 8px;">Create Voucher Slip / Billing Statement</h3>
        
        <div style="display: flex; flex-direction: column; gap: 18px; width: 100%; margin-bottom: 24px;">
            <div style="display: flex; flex-direction: column; gap: 6px; max-width: 600px; width: 100%;">
                <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 6px;">Search Member</span>
                <div style="display: flex; gap: 8px; width: 100%;">
                    <asp:TextBox ID="txtVoucherMemberSearch" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" placeholder="Enter member name or number..." autocomplete="off" list="dlVoucherMembers" oninput="fetchMembersVoucher(this.value)" />
                    <datalist id="dlVoucherMembers"></datalist>
                    <asp:Button ID="btnSelectVoucherMember" runat="server" Text="Load Unpaid Items" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1);" OnClick="btnSelectVoucherMember_Click" />
                </div>
            </div>
        </div>

        <asp:Panel ID="pnlVoucherContent" runat="server" Visible="false" style="width: 100%;">
            <div style="background-color: #f1f5f9; padding: 14px 20px; border-radius: 8px; font-size: 14.5px; color: #0f1e36; margin-bottom: 20px;">
                Member: <strong><asp:Label ID="lblVoucherMemberName" runat="server" /></strong> (<asp:Label ID="lblVoucherMemberNo" runat="server" />) |
                Outstanding balance: <strong style="color: #ef4444;">Rs. <asp:Label ID="lblVoucherMemberBalance" runat="server" /></strong>
                <asp:HiddenField ID="hfVoucherMemberID" runat="server" />
            </div>

            <!-- Fines Grid -->
            <h4 style="font-size: 13px; font-weight: 700; color: #0f1e36; text-transform: uppercase; margin: 20px 0 10px 0; letter-spacing: 0.5px;">Outstanding Fines & Fees</h4>
            <div style="overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-bottom: 20px; background-color:#ffffff;">
                <asp:GridView ID="gvUnpaidFines" runat="server" AutoGenerateColumns="False" style="width: 100%; border-collapse: collapse; font-size: 13.5px; color: #1e293b;" GridLines="None"
                    DataKeyNames="FineID">
                    <HeaderStyle CssClass="gv-header" />
                    <RowStyle CssClass="gv-row" />
                    <AlternatingRowStyle CssClass="gv-alt-row" />
                    <Columns>
                        <asp:TemplateField HeaderStyle-CssClass="gv-text-center" ItemStyle-CssClass="gv-text-center" ItemStyle-Width="40px">
                            <ItemTemplate>
                                <asp:CheckBox ID="chkSelectFine" runat="server" onclick="calculateVoucherTotal()" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="TxnDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}" HeaderStyle-CssClass="gv-text-left" ItemStyle-CssClass="gv-text-left" />
                        <asp:BoundField DataField="Description" HeaderText="Fine Reason" HeaderStyle-CssClass="gv-text-left" ItemStyle-CssClass="gv-text-left" />
                        <asp:BoundField DataField="Remarks" HeaderText="Remarks" HeaderStyle-CssClass="gv-text-left" ItemStyle-CssClass="gv-text-left" />
                        <asp:TemplateField HeaderText="Amount" HeaderStyle-CssClass="gv-text-right" ItemStyle-CssClass="gv-text-right" ItemStyle-Font-Bold="true">
                            <ItemTemplate>
                                <span class="row-amount">Rs. <%# Eval("Amount", "{0:N2}") %></span>
                                <asp:HiddenField ID="hfFineAmount" runat="server" Value='<%# Eval("Amount") %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="padding: 20px; text-align: center; color: #64748b; font-style: italic;">No unpaid library fines found.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>

            <!-- Facilities Grid -->
            <h4 style="font-size: 13px; font-weight: 700; color: #0f1e36; text-transform: uppercase; margin: 20px 0 10px 0; letter-spacing: 0.5px;">Outstanding Facility Bookings</h4>
            <div style="overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin-bottom: 24px; background-color:#ffffff;">
                <asp:GridView ID="gvUnpaidBookings" runat="server" AutoGenerateColumns="False" style="width: 100%; border-collapse: collapse; font-size: 13.5px; color: #1e293b;" GridLines="None"
                    DataKeyNames="BookingID">
                    <HeaderStyle CssClass="gv-header" />
                    <RowStyle CssClass="gv-row" />
                    <AlternatingRowStyle CssClass="gv-alt-row" />
                    <Columns>
                        <asp:TemplateField HeaderStyle-CssClass="gv-text-center" ItemStyle-CssClass="gv-text-center" ItemStyle-Width="40px">
                            <ItemTemplate>
                                <asp:CheckBox ID="chkSelectBooking" runat="server" onclick="calculateVoucherTotal()" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="TxnDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}" HeaderStyle-CssClass="gv-text-left" ItemStyle-CssClass="gv-text-left" />
                        <asp:BoundField DataField="Description" HeaderText="Facility Used" HeaderStyle-CssClass="gv-text-left" ItemStyle-CssClass="gv-text-left" />
                        <asp:BoundField DataField="Remarks" HeaderText="Remarks" HeaderStyle-CssClass="gv-text-left" ItemStyle-CssClass="gv-text-left" />
                        <asp:TemplateField HeaderText="Amount" HeaderStyle-CssClass="gv-text-right" ItemStyle-CssClass="gv-text-right" ItemStyle-Font-Bold="true">
                            <ItemTemplate>
                                <span class="row-amount">Rs. <%# Eval("Amount", "{0:N2}") %></span>
                                <asp:HiddenField ID="hfBookingAmount" runat="server" Value='<%# Eval("Amount") %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="padding: 20px; text-align: center; color: #64748b; font-style: italic;">No unpaid facility bookings found.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>

            <!-- Billing Execution Form -->
            <div style="display:flex; gap: 28px; flex-wrap: wrap; background-color:#f8fafc; border:1px solid #e2e8f0; border-radius: 8px; padding: 24px; width:100%; box-sizing:border-box;">
                <div style="flex:1; min-width: 250px; display:flex; flex-direction:column; gap:12px;">
                    <div style="display: flex; flex-direction: column; gap: 6px;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 6px;">Billing/Payment Mode</span>
                        <asp:DropDownList ID="ddlPaymentMode" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;">
                            <asp:ListItem Value="Cash">Cash (Generate Voucher for Cashier)</asp:ListItem>
                            <asp:ListItem Value="Account Debit">Debit Member Account (Immediate Account Settlement)</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 6px;">Voucher Notes</span>
                        <asp:TextBox ID="txtVoucherRemarks" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" placeholder="Add invoice remarks..." />
                    </div>
                </div>
                <div style="flex:1; min-width: 250px; display:flex; flex-direction:column; justify-content:space-between; align-items:flex-end; text-align:right;">
                    <div>
                        <div style="font-size:12px; font-weight:700; color:#64748b; text-transform:uppercase;">Selected Items Sum</div>
                        <div style="font-size:32px; font-weight:800; color:#ef4444; margin-top:4px;" id="lblSelectedTotal">Rs. 0.00</div>
                    </div>
                    <div style="margin-top:16px;">
                        <asp:Button ID="btnGenerateVoucher" runat="server" Text="Create Billing Receipt" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2);" OnClick="btnGenerateVoucher_Click" />
                    </div>
                </div>
            </div>

        </asp:Panel>
    </div>
</asp:Panel>

<!-- =========================================================================
     TAB 3: CASHIER DESK
     ========================================================================= -->
<asp:Panel ID="pnlTabCashier" runat="server" Visible="false">
    <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); padding: 28px; box-sizing: border-box; width: 100%; margin-bottom: 24px;">
        <h3 style="font-size: 18px; font-weight: 700; color: #0f1e36; margin: 0 0 20px 0; border-bottom: 2px solid #cbd5e1; padding-bottom: 8px;" class="no-print">Cashier Voucher Payment</h3>
        <div style="display: flex; flex-direction: column; gap: 18px; max-width: 600px; width: 100%;" class="no-print">
            <div style="display: flex; flex-direction: column; gap: 6px;">
                <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 6px;">Voucher Number</span>
                <div style="display: flex; gap: 8px; width: 100%;">
                    <asp:TextBox ID="txtVoucherNoSearch" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" placeholder="Enter Voucher No (e.g. VCH-20260606-0001)..." />
                    <asp:Button ID="btnSearchVoucher" runat="server" Text="Retrieve Slip" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1);" OnClick="btnSearchVoucher_Click" />
                </div>
            </div>
        </div>

        <asp:Panel ID="pnlVoucherSearchDetail" runat="server" Visible="false" style="margin-top: 24px;">
            <div style="background-color: #ffffff; border: 1px solid #cbd5e1; padding: 30px; max-width: 100%; margin: 20px auto; color: #000000; font-family: 'Outfit', sans-serif; border-radius: 8px;">
                <div style="display:flex; justify-content:space-between; border-bottom:2px solid #cbd5e1; padding-bottom:12px; margin-bottom:16px;">
                    <div>
                        <h4 style="margin:0; font-size:18px; color:#0f1e36;"><asp:Label ID="lblCashierVoucherNo" runat="server" /></h4>
                        <span style="font-size:12px; color:#64748b;">Issued on: <asp:Label ID="lblCashierVoucherDate" runat="server" /></span>
                    </div>
                    <div>
                        <asp:Label ID="lblCashierVoucherStatus" runat="server" />
                    </div>
                </div>

                <table style="width: 100%; border-collapse: collapse; font-size: 14px; margin-bottom: 20px;">
                    <tr>
                        <td style="padding: 6px 0; color: #64748b; font-weight:600; width:120px;">Member:</td>
                        <td style="padding: 6px 0; font-weight:700; color:#0f1e36;"><asp:Label ID="lblCashierMemberName" runat="server" /></td>
                    </tr>
                    <tr>
                        <td style="padding: 6px 0; color: #64748b; font-weight:600;">Membership No:</td>
                        <td style="padding: 6px 0; color:#0f1e36;"><asp:Label ID="lblCashierMemberNo" runat="server" /></td>
                    </tr>
                    <tr>
                        <td style="padding: 6px 0; color: #64748b; font-weight:600;">Payment Mode:</td>
                        <td style="padding: 6px 0; color:#0f1e36; font-weight:600;"><asp:Label ID="lblCashierPaymentMode" runat="server" /></td>
                    </tr>
                    <tr id="trPaidAt" runat="server" visible="false">
                        <td style="padding: 6px 0; color: #64748b; font-weight:600;">Paid At:</td>
                        <td style="padding: 6px 0; color:#10b981; font-weight:600;"><asp:Label ID="lblCashierPaidAt" runat="server" /></td>
                    </tr>
                </table>

                <h4 style="font-size: 12px; font-weight: 700; color: #64748b; text-transform: uppercase; margin-bottom: 8px;">Voucher Line Items</h4>
                <asp:GridView ID="gvVoucherLineItems" runat="server" AutoGenerateColumns="False" style="width: 100%; border-collapse: collapse; font-size: 13.5px; color: #1e293b;" GridLines="None"
                    HeaderStyle-CssClass="gv-text-left" RowStyle-CssClass="gv-row" AlternatingRowStyle-CssClass="gv-row">
                    <Columns>
                        <asp:BoundField DataField="ItemType" HeaderText="Category" HeaderStyle-CssClass="gv-text-left" ItemStyle-CssClass="gv-text-left" />
                        <asp:BoundField DataField="Description" HeaderText="Description" HeaderStyle-CssClass="gv-text-left" ItemStyle-CssClass="gv-text-left" />
                        <asp:BoundField DataField="Remarks" HeaderText="Notes" HeaderStyle-CssClass="gv-text-left" ItemStyle-CssClass="gv-text-left" />
                        <asp:TemplateField HeaderText="Amount" HeaderStyle-CssClass="gv-text-right" ItemStyle-CssClass="gv-text-right" ItemStyle-Font-Bold="true">
                            <ItemTemplate>
                                Rs. <%# Eval("Amount", "{0:N2}") %>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>

                <div style="display:flex; justify-content:space-between; align-items:center; border-top:2px solid #cbd5e1; padding-top:16px; margin-top:20px;">
                    <asp:Button ID="btnPrintVoucherCashier" runat="server" Text="Print Statement" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background:#64748b; color:white; transition: all 0.2s ease;" class="no-print" OnClick="btnPrintVoucherCashier_Click" />
                    
                    <div style="text-align:right;">
                        <span style="font-size:12px; color:#64748b; font-weight:600;">Total Amount</span>
                        <div style="font-size:24px; font-weight:800; color:#ef4444;">Rs. <asp:Label ID="lblCashierVoucherTotal" runat="server" /></div>
                    </div>
                </div>

                <div style="margin-top:24px; text-align:right;" id="divCashierPayButton" runat="server" class="no-print">
                    <asp:Button ID="btnPayVoucher" runat="server" Text="Collect Cash & Mark Paid" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2);" OnClick="btnPayVoucher_Click" />
                </div>
            </div>
        </asp:Panel>
    </div>
</asp:Panel>

<!-- =========================================================================
     PRINTABLE SLIP MODAL CONTAINER (Active for printing/PDF generation)
     ========================================================================= -->
<asp:Panel ID="pnlPrintSlip" runat="server" Visible="false" style="width: 100%;">
    <div class="print-section" style="background-color: #ffffff; border: 2px dashed #000000; padding: 30px; max-width: 600px; margin: 20px auto; color: #000000; font-family: 'Courier New', Courier, monospace;">
        <div style="text-align: center; border-bottom: 1px dashed #000000; padding-bottom: 15px; margin-bottom: 20px;">
            <div style="font-size: 16px; font-weight: bold;">LAHORE GYMKHANA CLUB</div>
            <div style="font-size: 11px;">Library Billing Receipt</div>
            <div style="font-size: 14px; font-weight: bold; margin-top: 10px;">VOUCHER SLIP</div>
        </div>

        <table style="width: 100%; font-size: 12px; line-height: 1.6; margin-bottom: 15px;">
            <tr>
                <td style="font-weight: bold; width: 110px;">Voucher No:</td>
                <td><asp:Label ID="lblPrintVoucherNo" runat="server" /></td>
            </tr>
            <tr>
                <td style="font-weight: bold;">Date Issued:</td>
                <td><asp:Label ID="lblPrintDate" runat="server" /></td>
            </tr>
            <tr>
                <td style="font-weight: bold;">Member Name:</td>
                <td><asp:Label ID="lblPrintMemberName" runat="server" /></td>
            </tr>
            <tr>
                <td style="font-weight: bold;">Member No:</td>
                <td><asp:Label ID="lblPrintMemberNo" runat="server" /></td>
            </tr>
            <tr>
                <td style="font-weight: bold;">Payment Mode:</td>
                <td><asp:Label ID="lblPrintPaymentMode" runat="server" /></td>
            </tr>
            <tr>
                <td style="font-weight: bold;">Status:</td>
                <td><strong><asp:Label ID="lblPrintStatus" runat="server" /></strong></td>
            </tr>
        </table>

        <asp:GridView ID="gvPrintItems" runat="server" AutoGenerateColumns="False" GridLines="None" style="width: 100%; border-collapse: collapse; margin: 20px 0;">
            <HeaderStyle CssClass="receipt-header" />
            <RowStyle CssClass="receipt-row" />
            <Columns>
                <asp:BoundField DataField="ItemType" HeaderText="TYPE" HeaderStyle-CssClass="gv-text-left" ItemStyle-CssClass="gv-text-left" ItemStyle-Width="120px" />
                <asp:BoundField DataField="Description" HeaderText="DETAILS" HeaderStyle-CssClass="gv-text-left" ItemStyle-CssClass="gv-text-left" />
                <asp:TemplateField HeaderText="AMOUNT" HeaderStyle-CssClass="gv-text-right" ItemStyle-CssClass="gv-text-right" ItemStyle-Width="100px">
                    <ItemTemplate>
                        Rs. <%# Eval("Amount", "{0:N2}") %>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>

        <div style="text-align: right; font-size: 16px; font-weight: bold; margin-top: 15px; border-top: 1px dashed #000000; padding-top: 10px;">
            TOTAL AMOUNT: Rs. <asp:Label ID="lblPrintTotal" runat="server" />
        </div>

        <div style="margin-top: 30px; text-align: center; font-size: 10px; border-top: 1px dashed #000; padding-top: 15px;">
            Please present this voucher to the library cashier desk.<br />
            Thank you for your cooperation.<br />
            * System generated slip *
        </div>

        <div class="no-print" style="margin-top:20px; text-align:center;">
            <button type="button" style="padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2);" onclick="window.print()">Print Receipt</button>
            <asp:Button ID="btnCloseVoucherPrint" runat="server" Text="Close Print View" style="padding: 12px 24px; border-radius: 8px; border: 1px solid #cbd5e1; background-color: #ffffff; color: #475569; font-size: 13px; font-weight: 700; text-transform: uppercase; cursor: pointer; transition: all 0.2s ease; margin-left: 10px;" OnClick="btnCloseVoucherPrint_Click" />
        </div>
    </div>
</asp:Panel>
</ContentTemplate>
</asp:UpdatePanel>

<script type="text/javascript">
    // Autocomplete for TAB 1
    let termTimeout1;
    function fetchMembersCharge(term) {
        if (term.length < 2) {
            document.getElementById('dlChargeMembers').innerHTML = '';
            return;
        }
        clearTimeout(termTimeout1);
        termTimeout1 = setTimeout(() => {
            fetch('Reports.aspx/GetMemberSuggestions', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ term: term })
            })
            .then(res => res.json())
            .then(data => {
                const dl = document.getElementById('dlChargeMembers');
                dl.innerHTML = '';
                data.d.forEach(item => {
                    const opt = document.createElement('option');
                    opt.value = item.label;
                    dl.appendChild(opt);
                });
            })
            .catch(err => console.error(err));
        }, 300);
    }

    // Autocomplete for TAB 2
    let termTimeout2;
    function fetchMembersVoucher(term) {
        if (term.length < 2) {
            document.getElementById('dlVoucherMembers').innerHTML = '';
            return;
        }
        clearTimeout(termTimeout2);
        termTimeout2 = setTimeout(() => {
            fetch('Reports.aspx/GetMemberSuggestions', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ term: term })
            })
            .then(res => res.json())
            .then(data => {
                const dl = document.getElementById('dlVoucherMembers');
                dl.innerHTML = '';
                data.d.forEach(item => {
                    const opt = document.createElement('option');
                    opt.value = item.label;
                    dl.appendChild(opt);
                });
            })
            .catch(err => console.error(err));
        }, 300);
    }

    // Dynamic calculations for checkboxes in TAB 2
    function calculateVoucherTotal() {
        let total = 0.0;
        
        // Find checked GridView checkboxes
        const grids = [
            document.getElementById('<%= gvUnpaidFines.ClientID %>'),
            document.getElementById('<%= gvUnpaidBookings.ClientID %>')
        ];

        grids.forEach(grid => {
            if (grid) {
                const checkboxes = grid.querySelectorAll('input[type="checkbox"]');
                checkboxes.forEach(chk => {
                    if (chk.checked) {
                        const tr = chk.closest('tr');
                        // Find hidden field with amount
                        const hf = tr.querySelector('input[type="hidden"]');
                        if (hf) {
                            total += parseFloat(hf.value);
                        }
                    }
                });
            }
        });

        document.getElementById('lblSelectedTotal').textContent = 'Rs. ' + total.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }

    // Print handlers
    function printVoucherSlip() {
        window.print();
    }
    
    function printVoucherSlipDirect() {
        window.print();
    }

    // Run initial calculate on page load
    window.onload = function() {
        calculateVoucherTotal();
    };
</script>

</asp:Content>
