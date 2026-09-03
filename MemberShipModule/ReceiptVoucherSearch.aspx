<%@ Page Title="Receipt Posted Vouchers" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true" CodeFile="ReceiptVoucherSearch.aspx.cs" Inherits="ReceiptVoucherSearch_Page" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
    <style type="text/css">
        .voucher-search-wrapper {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 13px;
            padding: 16px 20px;
        }

        /* Enforced Table Hover & Row Styling */
        table.gv-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 12px;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        table.gv-table th {
            background-color: #342867 !important;
            color: #ffffff !important;
            border: 1px solid #2a1f54 !important;
            padding: 9px 12px !important;
            text-align: left;
            font-weight: 700 !important;
            font-size: 11px !important;
            text-transform: uppercase !important;
            letter-spacing: 0.04em !important;
            white-space: nowrap;
        }

        table.gv-table td {
            border: 1px solid #e0e0e0 !important;
            padding: 8px 12px !important;
            vertical-align: middle;
            white-space: nowrap;
            font-size: 12px !important;
        }

        table.gv-table tr:nth-child(even) td {
            background-color: #f9f9f9 !important;
        }

        table.gv-table tr:hover td {
            background-color: #eef2f6 !important;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">
    <div class="voucher-search-wrapper" style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; font-size: 13px; padding: 16px 20px;">
        
        <%-- Top Header Row --%>
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
            <h2 style="margin: 0; color: #342867; font-weight: 700; font-size: 18px; font-family: inherit;">Posted Receipt Vouchers</h2>
            <a href="Receipt.aspx" style="text-decoration: none; font-weight: 600; color: #342867; background: #eef2f6; padding: 6px 14px; border-radius: 4px; border: 1px solid #ccc; font-size: 12.5px; display: inline-block;">← Back to Receipt Entry</a>
        </div>

        <%-- Search Filter Card --%>
        <div style="background: #ffffff; border: 1px solid #c8c8c8; border-radius: 6px; padding: 14px 18px; margin-bottom: 18px; box-shadow: 0 2px 5px rgba(0,0,0,0.05);">
            <h3 style="margin: 0 0 12px 0; font-size: 14px; color: #342867; font-weight: 700; border-bottom: 1px solid #eee; padding-bottom: 6px; text-transform: uppercase; letter-spacing: 0.03em;">Search Filters</h3>
            
            <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; align-items: end;">
                <div style="display: flex; flex-direction: column;">
                    <label style="font-weight: 600; font-size: 11px; text-transform: uppercase; letter-spacing: 0.04em; color: #555; margin-bottom: 4px; display: block;">Receipt No / Keyword</label>
                    <asp:TextBox ID="txtSearchReceiptNo" runat="server" placeholder="e.g. RCP-26-08-000001" Style="width: 100%; padding: 6px 8px; border: 1px solid #bbb; font-size: 12.5px; font-family: inherit; outline: none; background: #ffffff; border-radius: 4px; box-sizing: border-box;"></asp:TextBox>
                </div>
                
                <div style="display: flex; flex-direction: column;">
                    <label style="font-weight: 600; font-size: 11px; text-transform: uppercase; letter-spacing: 0.04em; color: #555; margin-bottom: 4px; display: block;">Voucher No</label>
                    <asp:TextBox ID="txtSearchVoucherNo" runat="server" placeholder="e.g. CRV/2026/..." Style="width: 100%; padding: 6px 8px; border: 1px solid #bbb; font-size: 12.5px; font-family: inherit; outline: none; background: #ffffff; border-radius: 4px; box-sizing: border-box;"></asp:TextBox>
                </div>
                
                <div style="display: flex; flex-direction: column;">
                    <label style="font-weight: 600; font-size: 11px; text-transform: uppercase; letter-spacing: 0.04em; color: #555; margin-bottom: 4px; display: block;">From Date</label>
                    <asp:TextBox ID="txtFromDate" runat="server" TextMode="Date" Style="width: 100%; padding: 6px 8px; border: 1px solid #bbb; font-size: 12.5px; font-family: inherit; outline: none; background: #ffffff; border-radius: 4px; box-sizing: border-box;"></asp:TextBox>
                </div>
                
                <div style="display: flex; flex-direction: column;">
                    <label style="font-weight: 600; font-size: 11px; text-transform: uppercase; letter-spacing: 0.04em; color: #555; margin-bottom: 4px; display: block;">To Date</label>
                    <asp:TextBox ID="txtToDate" runat="server" TextMode="Date" Style="width: 100%; padding: 6px 8px; border: 1px solid #bbb; font-size: 12.5px; font-family: inherit; outline: none; background: #ffffff; border-radius: 4px; box-sizing: border-box;"></asp:TextBox>
                </div>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 8px; margin-top: 14px;">
                <asp:Button ID="btnReset" runat="server" Text="Reset" OnClick="btnReset_Click" CausesValidation="false" Style="padding: 6px 18px; font-size: 12.5px; font-family: inherit; font-weight: 600; border: 1px solid #ccc; background: #e0e0e0; color: #333333 !important; cursor: pointer; border-radius: 4px; text-transform: uppercase;" />
                <asp:Button ID="btnSearch" runat="server" Text="Search Vouchers" OnClick="btnSearch_Click" Style="padding: 6px 20px; font-size: 12.5px; font-family: inherit; font-weight: 600; border: none; background: #342867; color: #ffffff !important; cursor: pointer; border-radius: 4px; text-transform: uppercase; letter-spacing: 0.04em;" />
            </div>
        </div>

        <%-- Grid Results --%>
        <div style="background: #ffffff; border: 1px solid #c8c8c8; border-radius: 6px; overflow: hidden;">
            <asp:GridView ID="gvVouchers" runat="server" AutoGenerateColumns="False"
                CssClass="gv-table" GridLines="None" Width="100%" OnRowCommand="gvVouchers_RowCommand"
                AllowPaging="True" PageSize="15" OnPageIndexChanging="gvVouchers_PageIndexChanging"
                EmptyDataText="No posted vouchers found matching the search criteria."
                HeaderStyle-BackColor="#342867" HeaderStyle-ForeColor="#ffffff" HeaderStyle-Font-Bold="true" HeaderStyle-Font-Size="11px" HeaderStyle-Height="36px"
                RowStyle-Height="32px" RowStyle-Font-Size="12px" AlternatingRowStyle-BackColor="#f9f9f9">
                <Columns>
                    <asp:BoundField DataField="Voucher_No" HeaderText="Voucher No" />
                    <asp:BoundField DataField="VoucherDate" HeaderText="Voucher Date" DataFormatString="{0:yyyy-MM-dd}" />
                    <asp:BoundField DataField="Voucher_Type" HeaderText="Voucher Type" />
                    <asp:BoundField DataField="ReceiptNo" HeaderText="Receipt No" NullDisplayText="-" />
                    <asp:BoundField DataField="CostCenterName" HeaderText="Cost Center" NullDisplayText="-" />
                    <asp:BoundField DataField="VoucherDescription" HeaderText="Description / Notes" />
                    <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnViewDetail" runat="server" CommandName="ViewDetail"
                                CommandArgument='<%# Eval("Voucher_Trans_Id") %>' Text="View Entry"
                                Style="color: #342867; font-weight: 700; text-decoration: underline; font-size: 12px;" CausesValidation="false" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>

        <%-- VOUCHER DETAIL POPUP MODAL --%>
        <asp:Panel ID="pnlVoucherDetailModal" runat="server" Visible="false" Style="display: flex; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.55); z-index: 9999; align-items: center; justify-content: center; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;">
            <div style="background: #ffffff; border-radius: 8px; width: 750px; max-width: 95%; max-height: 90vh; overflow-y: auto; box-shadow: 0 10px 25px rgba(0,0,0,0.3); padding: 24px; box-sizing: border-box;">
                
                <div style="text-align: center; border-bottom: 2px solid #342867; padding-bottom: 10px; margin-bottom: 16px;">
                    <h2 style="margin: 0; color: #342867; font-size: 18px; font-weight: 700;">FINANCIAL RECEIPT VOUCHER</h2>
                    <div style="font-size: 11px; color: #666666; margin-top: 2px; text-transform: uppercase; letter-spacing: 0.04em; font-weight: 600;">Lahore Gymkhana Club — Finance Department</div>
                </div>

                <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 8px 16px; font-size: 12.5px; margin-bottom: 16px; background: #f8fafc; padding: 12px; border: 1px solid #e2e8f0; border-radius: 4px;">
                    <div><strong style="color: #342867;">Voucher No:</strong> <asp:Label ID="lblModalVoucherNo" runat="server" Style="font-weight: 600;"></asp:Label></div>
                    <div><strong style="color: #342867;">Receipt No:</strong> <asp:Label ID="lblModalReceiptNo" runat="server" Style="font-weight: 600;"></asp:Label></div>
                    <div><strong style="color: #342867;">Voucher Date:</strong> <asp:Label ID="lblModalVoucherDate" runat="server" Style="font-weight: 600;"></asp:Label></div>
                    <div><strong style="color: #342867;">Voucher Type:</strong> <asp:Label ID="lblModalVoucherType" runat="server" Style="font-weight: 600;"></asp:Label></div>
                    <div><strong style="color: #342867;">Cost Center:</strong> <asp:Label ID="lblModalCostCenter" runat="server" Style="font-weight: 600;"></asp:Label></div>
                    <div style="grid-column: span 2;"><strong style="color: #342867;">Description:</strong> <asp:Label ID="lblModalDescription" runat="server" Style="font-weight: 600;"></asp:Label></div>
                </div>

                <h4 style="margin: 0 0 8px 0; color: #342867; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.03em;">Accounting Entries (Double-Entry Ledger)</h4>
                
                <asp:GridView ID="gvVoucherDetails" runat="server" AutoGenerateColumns="False"
                    CssClass="gv-table" GridLines="None" Width="100%"
                    HeaderStyle-BackColor="#342867" HeaderStyle-ForeColor="#ffffff" HeaderStyle-Font-Bold="true" HeaderStyle-Font-Size="11px" HeaderStyle-Height="34px"
                    RowStyle-Height="30px" RowStyle-Font-Size="12px" AlternatingRowStyle-BackColor="#f9f9f9">
                    <Columns>
                        <asp:BoundField DataField="Account_Head_id" HeaderText="Account Code" />
                        <asp:BoundField DataField="AccountTitle" HeaderText="Account Title / Financial Head" />
                        <asp:BoundField DataField="DetailCostCenter" HeaderText="Cost Center" />
                        <asp:BoundField DataField="ActionType" HeaderText="Entry Type" />
                        <asp:BoundField DataField="DebitAmount" HeaderText="Debit (Dr)" DataFormatString="{0:N2}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" />
                        <asp:BoundField DataField="CreditAmount" HeaderText="Credit (Cr)" DataFormatString="{0:N2}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" />
                    </Columns>
                </asp:GridView>

                <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 18px; border-top: 1px solid #ddd; padding-top: 12px;">
                    <button type="button" onclick="window.print();" Style="padding: 6px 18px; font-size: 12.5px; font-family: inherit; font-weight: 600; border: none; background: #342867; color: #ffffff !important; cursor: pointer; border-radius: 4px;">🖨 Print Voucher</button>
                    <asp:Button ID="btnCloseVoucherModal" runat="server" Text="Close" OnClick="btnCloseVoucherModal_Click" CausesValidation="false" Style="padding: 6px 18px; font-size: 12.5px; font-family: inherit; font-weight: 600; border: 1px solid #ccc; background: #e0e0e0; color: #333333 !important; cursor: pointer; border-radius: 4px; text-transform: uppercase;" />
                </div>
            </div>
        </asp:Panel>

    </div>
</asp:Content>
