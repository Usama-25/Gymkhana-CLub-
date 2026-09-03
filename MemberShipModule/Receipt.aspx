<%@ Page Title="Receipt" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true" CodeFile="Receipt.aspx.cs" Inherits="Receipt_Page" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
    <style type="text/css">
        * {
            box-sizing: border-box;
        }

        .receipt-wrapper {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 13px;
            padding: 14px 20px;
        }

        /* ── Two-panel layout ── */
        .receipt-layout {
            display: flex;
            gap: 16px;
            align-items: flex-start;
        }

        .panel-form {
            flex: 0 0 50%;
            width: 50%;
            display: flex;
            flex-direction: column;
        }

        .panel-grid {
            flex: 1 1 0;
            min-width: 0;
            display: flex;
            flex-direction: column;
        }

        /* ── Form Grid (2-col inside 50% panel) ── */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            border: 1px solid #c8c8c8;
            border-bottom: none;
        }

        .form-cell {
            display: flex;
            flex-direction: column;
            padding: 7px 10px;
            border-right: 1px solid #c8c8c8;
            border-bottom: 1px solid #c8c8c8;
        }

            .form-cell:nth-child(2n) {
                border-right: none;
            }

            .form-cell.span-2 {
                grid-column: span 2;
                border-right: none;
            }

            .form-cell label {
                font-weight: 600;
                font-size: 10.5px;
                text-transform: uppercase;
                letter-spacing: 0.04em;
                color: #555;
                margin-bottom: 4px;
                white-space: nowrap;
            }

        /* ── Controls ── */
        .receipt-wrapper input[type="text"],
        .receipt-wrapper input[type="number"],
        .receipt-wrapper input[type="date"],
        .receipt-wrapper select,
        .receipt-wrapper textarea {
            width: 100%;
            padding: 4px 7px;
            border: 1px solid #bbb;
            font-size: 12.5px;
            font-family: inherit;
            outline: none;
            background: #fff;
            transition: border-color 0.15s;
        }

            .receipt-wrapper input[type="text"]:focus,
            .receipt-wrapper input[type="number"]:focus,
            .receipt-wrapper input[type="date"]:focus,
            .receipt-wrapper select:focus,
            .receipt-wrapper textarea:focus {
                border-color: #555;
            }

        .receipt-wrapper textarea {
            resize: vertical;
            min-height: 48px;
        }

        /* RadioButtonList */
        .receipt-wrapper table[id$="rblReceiptType"] td {
            padding-right: 10px;
            white-space: nowrap;
            font-size: 12.5px;
            font-weight: 700;
            font: bold;
        }

        /* Bank charges inline */
        .bank-inline {
            display: flex;
            gap: 5px;
            align-items: center;
        }

            .bank-inline .pct-box {
                width: 56px;
                flex-shrink: 0;
            }

                .bank-inline .pct-box input {
                    width: 100%;
                }

            .bank-inline .pct-sign {
                font-weight: 700;
                color: #555;
                flex-shrink: 0;
                font-size: 12px;
            }

            .bank-inline .amt-box {
                flex: 1;
            }

                .bank-inline .amt-box input {
                    width: 100%;
                }

        /* Info label */
        .info-label {
            font-size: 10.5px;
            color: #888;
            margin-top: 2px;
        }

        /* ── Save button row — flush to form bottom ── */
        .action-row {
            border: 1px solid #c8c8c8;
            border-top: none;
            color: #342867;
            padding: 7px 10px;
            display: flex;
            justify-content: flex-end;
            background: #f5f5f5;
        }

        .receipt-wrapper input[type="submit"] {
            padding: 4px 24px;
            font-size: 12.5px;
            font-family: inherit;
            font-weight: 600;
            border: 1px solid #444;
            background: #342867;
            color: #ffffff;
            cursor: pointer;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            transition: background 0.15s, color 0.15s;
        }

            .receipt-wrapper input[type="submit"]:hover {
                background: #4a3b8c;
                color: #ffffff;
                border-color: #333;
            }

        /* ── GridView ── */
        .grid-wrapper {
            overflow-x: auto;
            border: 1px solid #c8c8c8;
        }

        .receipt-wrapper table.gv-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 11.5px;
        }

            .receipt-wrapper table.gv-table th {
                background: #f0f0f0;
                border: 1px solid #c8c8c8;
                padding: 6px 9px;
                text-align: left;
                font-weight: 700;
                font-size: 10.5px;
                text-transform: uppercase;
                letter-spacing: 0.04em;
                white-space: nowrap;
            }

            .receipt-wrapper table.gv-table td {
                border: 1px solid #e0e0e0;
                padding: 5px 9px;
                vertical-align: middle;
                white-space: nowrap;
            }

            .receipt-wrapper table.gv-table tr:nth-child(even) td {
                background: #f9f9f9;
            }

            .receipt-wrapper table.gv-table tr:hover td {
                background: #eef2f6;
            }

        /* Pager */
        .receipt-wrapper .grid-pager td {
            padding: 5px 9px;
            background: #f7f7f7;
            border-top: 1px solid #ddd;
        }

        .receipt-wrapper .grid-pager a,
        .receipt-wrapper .grid-pager span {
            padding: 2px 7px;
            border: 1px solid #ccc;
            font-size: 11px;
            text-decoration: none;
            color: #333;
            margin: 0 1px;
        }

        .receipt-wrapper .grid-pager span {
            background: #333;
            color: #fff;
            border-color: #333;
        }

        /* ── Modal Dialog Styles ── */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.5);
            z-index: 9999;
            align-items: center;
            justify-content: center;
        }
        .modal-content-box {
            background: #fff;
            border-radius: 8px;
            width: 680px;
            max-width: 95%;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 10px 25px rgba(0,0,0,0.25);
            padding: 20px 24px;
        }
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #e0e0e0;
            padding-bottom: 10px;
            margin-bottom: 15px;
        }
        .modal-header h3 {
            margin: 0;
            font-size: 16px;
            color: #342867;
            font-weight: 700;
        }
        .modal-form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-bottom: 15px;
        }
        .modal-form-cell {
            display: flex;
            flex-direction: column;
        }
        .modal-form-cell label {
            font-size: 11px;
            font-weight: 600;
            color: #555;
            margin-bottom: 4px;
            text-transform: uppercase;
        }
        .modal-grid-wrapper {
            max-height: 180px;
            overflow-y: auto;
            border: 1px solid #ccc;
            margin-bottom: 15px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">
    <div class="receipt-wrapper">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
            <h2 style="margin: 0; color: #342867; font-size: 18px; font-weight: 700;">Receipt Management</h2>
            <a href="ReceiptVoucherSearch.aspx" style="text-decoration: none; font-weight: 600; color: #ffffff; background: #342867; padding: 6px 16px; border-radius: 4px; font-size: 12px; letter-spacing: 0.03em;">View Posted Vouchers</a>
        </div>
        <div class="receipt-layout">

            <%-- ══════════ LEFT — FORM (50%) ══════════ --%>
            <div class="panel-form">
                <div class="form-grid">

                    <%-- Receipt Type — spans both columns --%>
                    <div class="form-cell span-2">
                        <label>Receipt Type</label>
                        <asp:RadioButtonList ID="rblReceiptType" runat="server"
                            RepeatDirection="Horizontal" AutoPostBack="True"
                            OnSelectedIndexChanged="rblReceiptType_SelectedIndexChanged">
                            <asp:ListItem Selected="True" Value="1">Billing / Membership</asp:ListItem>
                            <asp:ListItem Value="2">New Memberships</asp:ListItem>
                            <asp:ListItem Value="3">Activity / Event</asp:ListItem>
                            <asp:ListItem Value="4">Other</asp:ListItem>
                            <asp:ListItem Value="5">Guest Room</asp:ListItem>
                            <asp:ListItem Value="6">Banquet Hall</asp:ListItem>
                        </asp:RadioButtonList>
                    </div>

                    <%-- Receipt Mode | Receipt Date --%>
                    <div class="form-cell">
                        <label>Receipt Mode</label>
                        <div style="display: flex; gap: 5px; align-items: center;">
                            <asp:DropDownList ID="ddlReceiptMode" runat="server" AutoPostBack="True"
                                OnSelectedIndexChanged="ddlReceiptMode_SelectedIndexChanged"
                                DataSourceID="sdsMode" DataTextField="ReceiptMode" DataValueField="ReceiptModeID">
                            </asp:DropDownList>
                            <asp:Button ID="btnOpenReceiptModeModal" runat="server" Text="+" OnClick="btnOpenReceiptModeModal_Click" CausesValidation="false"
                                Style="padding: 2px 10px; font-size: 14px; font-weight: bold; background: #342867; color: white; border: none; cursor: pointer; height: 26px; border-radius: 3px; flex-shrink: 0;" Title="Add / Manage Receipt Mode" />
                        </div>
                        <asp:SqlDataSource ID="sdsMode" runat="server"
                            ConnectionString="<%$ ConnectionStrings:FinanceConnectionString %>"
                            SelectCommand="SELECT [ReceiptModeID], [ReceiptMode] FROM [ReceiptModes] WHERE ReceiptType = @ReceiptType AND ISNULL(IsActive, 1) = 1"
                            ProviderName="<%$ ConnectionStrings:FinanceConnectionString.ProviderName %>">
                            <SelectParameters>
                                <asp:ControlParameter ControlID="rblReceiptType" Name="ReceiptType" PropertyName="SelectedValue" />
                            </SelectParameters>
                        </asp:SqlDataSource>
                    </div>

                    <div class="form-cell">
                        <label>Receipt Date</label>
                        <asp:TextBox ID="txtReceiptDate" runat="server" TextMode="Date"></asp:TextBox>
                    </div>

                    <%-- Reference / Member # | Mode of Payment --%>
                    <div class="form-cell">
                        <label>Reference / Member #</label>
                        <asp:TextBox ID="txtReceiptRef" runat="server"
                            AutoPostBack="true"
                            OnTextChanged="txtReceiptRef_TextChanged"></asp:TextBox>
                        <asp:Label ID="lblInformation" runat="server" CssClass="info-label" Text="Info relevant to reference…"></asp:Label>
                    </div>

                    <div class="form-cell">
                        <label>Mode of Payment</label>
                        <asp:DropDownList ID="ddlReceiptModeOfPayment" runat="server" AutoPostBack="True"
                            OnSelectedIndexChanged="ddlReceiptModeOfPayment_SelectedIndexChanged">
                            <asp:ListItem Value="Cash">Cash</asp:ListItem>
                            <asp:ListItem Value="Bank">Cheque</asp:ListItem>
                            <asp:ListItem Value="Credit">Credit Card</asp:ListItem>
                            <asp:ListItem Value="Online">Online</asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <%-- Contact Person | CNIC --%>
                    <div class="form-cell">
                        <label>Contact Person</label>
                        <asp:TextBox ID="txtReceiptPerson" runat="server"></asp:TextBox>
                    </div>

                    <div class="form-cell">
                        <label>CNIC</label>
                        <asp:TextBox ID="txtReceiptP_CNIC" runat="server"></asp:TextBox>
                    </div>

                    <%-- Phone | For Department --%>
                    <div class="form-cell">
                        <label>Phone</label>
                        <asp:TextBox ID="txtReceiptP_Phone" runat="server"></asp:TextBox>
                    </div>

                    <div class="form-cell">
                        <label>For Department</label>
                        <asp:DropDownList ID="ddlCC" runat="server"
                            DataSourceID="sdsCC" DataTextField="CostCenterName" DataValueField="CostCenterID">
                        </asp:DropDownList>
                        <asp:SqlDataSource ID="sdsCC" runat="server"
                            ConnectionString="<%$ ConnectionStrings:FinanceConnectionString %>"
                            ProviderName="<%$ ConnectionStrings:FinanceConnectionString.ProviderName %>"
                            SelectCommand="SELECT CostCenterName, CostCenterID FROM CostCenter"></asp:SqlDataSource>
                    </div>

                    <%-- Receipt Amount | Payment Head --%>
                    <div class="form-cell">
                        <label>Receipt Amount</label>
                        <asp:TextBox ID="txtReceiptAmount" runat="server" TextMode="Number"
                            AutoPostBack="true" OnTextChanged="txtReceiptAmount_TextChanged"></asp:TextBox>
                    </div>

                    <div class="form-cell">
                        <label>Payment Head</label>
                        <asp:DropDownList ID="ddlP_Head" runat="server"
                            DataSourceID="sdsPHead" DataTextField="E_Name" DataValueField="E_Code">
                        </asp:DropDownList>
                        <asp:SqlDataSource ID="sdsPHead" runat="server"
                            CancelSelectOnNullParameter="False"
                            ConnectionString="<%$ ConnectionStrings:FinanceConnectionString %>"
                            SelectCommand="SELECT E.E_Code, E_Name FROM Head_Master_Table H INNER JOIN Expenditure E ON H.E_Code = E.E_Code WHERE H.Head_Type = @Head_Type">
                            <SelectParameters>
                                <asp:ControlParameter ControlID="ddlReceiptModeOfPayment" Name="Head_Type" PropertyName="SelectedValue" Type="String" />
                            </SelectParameters>
                        </asp:SqlDataSource>
                    </div>

                    <%-- Payment Reference | Bank Charges --%>
                    <div class="form-cell">
                        <label>Payment Reference / Cheque #</label>
                        <asp:TextBox ID="txtPaymentRefrence" runat="server"></asp:TextBox>
                    </div>
                    <asp:HiddenField ID="hfMemberData" runat="server" />
                    <div class="form-cell">
                        <label>Bank Charges</label>
                        <div class="bank-inline">
                            <div class="pct-box">
                                <asp:TextBox ID="txtBnkPer" runat="server" TextMode="Number"
                                    AutoPostBack="true" OnTextChanged="txtGSTPer_TextChanged"></asp:TextBox>
                            </div>
                            <span class="pct-sign">%</span>
                            <div class="amt-box">
                                <asp:TextBox ID="txtbnkAmount" runat="server" TextMode="Number"></asp:TextBox>
                            </div>
                        </div>
                    </div>

                    <%-- Receipt Notes — full width --%>
                    <div class="form-cell span-2">
                        <label>Receipt Notes</label>
                        <asp:TextBox ID="txtReceiptNotes" runat="server" TextMode="Multiline" Width="100%"></asp:TextBox>
                    </div>

                </div>
                <%-- /form-grid --%>

                <div class="action-row">
                    <asp:Button ID="btnAdd" runat="server" Text="Add" OnClick="BtnAdd" Style="color: #ffffff; background: #342867;" />
                </div>

            </div>
            <%-- /panel-form --%>

            <%-- ══════════ RIGHT — GRID (50%) ══════════ --%>
            <div class="panel-grid">
                <div class="grid-wrapper">
                   <asp:GridView ID="gvReceipts" runat="server"
                       AutoGenerateColumns="False"
                       DataKeyNames="MemberNo"
                       EmptyDataText="No records found."
                       CssClass="gv-table"
                       GridLines="None"
                       AllowPaging="True" PageSize="10"
                       HeaderStyle-BackColor="#342867" HeaderStyle-ForeColor="#ffffff" HeaderStyle-Font-Bold="true" HeaderStyle-Font-Size="11px" HeaderStyle-Height="38px"
                       RowStyle-Height="32px" RowStyle-Font-Size="12px" AlternatingRowStyle-BackColor="#f9f9f9">
                       <Columns>
                           <asp:BoundField DataField="MemberNo" HeaderText="Member No" ItemStyle-Width="15%" HeaderStyle-Width="15%" />
                           <asp:BoundField DataField="MemberName" HeaderText="Member Name" ItemStyle-Width="30%" HeaderStyle-Width="30%" />
                           <asp:BoundField DataField="LMonthPayable" HeaderText="Last Month Payable" ItemStyle-HorizontalAlign="Right" ItemStyle-Width="15%" HeaderStyle-Width="15%" />
                           <asp:BoundField DataField="overallPayable" HeaderText="Overall Payable" ItemStyle-HorizontalAlign="Right" ItemStyle-Width="15%" HeaderStyle-Width="15%" />

                           <%-- Non-editable Receipt Amount — pre-filled from txtReceiptAmount --%>
                           <asp:TemplateField HeaderText="Receipt Amount (incl. Bank Charges)" ItemStyle-HorizontalAlign="Right" ItemStyle-Width="25%" HeaderStyle-Width="25%" HeaderStyle-HorizontalAlign="Right">
                               <ItemTemplate>
                                   <asp:TextBox ID="txtRowAmount" runat="server" ReadOnly="true" Width="100%" Style="padding: 5px 8px; border: 1px solid #c5c5c5; background: #f0f4f8; font-size: 12px; font-weight: 700; color: #342867; text-align: right; box-sizing: border-box; border-radius: 3px;" Text='<%# GetReceiptAmount() %>'></asp:TextBox>
                               </ItemTemplate>
                           </asp:TemplateField>
                       </Columns>
                   </asp:GridView>
                    <%-- Add this above Save button in action-row --%>
<div class="action-row">
    <asp:Label ID="lblTotalStatus" runat="server" 
        Style="color:red; font-weight:600; margin-right:10px;"></asp:Label>
    <asp:Button ID="btnSave" runat="server" OnClick="btnSave_Click" Text="Save" />
</div>

                    <%--<asp:SqlDataSource ID="sdsReceipts" runat="server"
                ConnectionString="<%$ ConnectionStrings:MemberShipConnection %>"
                SelectCommand="select mp.MemberNo,mp.MemberName,m.Dept as LMonthPayable ,m.Credit as overallPayable from MemberProfile mp
inner join MemberPayment m on m.MemberNo=mp.MemberID where mp.MemberNo='i-012303'"
                ProviderName="<%$ ConnectionStrings:MemberShipConnection.ProviderName %>">
            </asp:SqlDataSource>--%>
                </div>
                
            </div>
            <%-- /panel-grid --%>
        </div>
        <%-- /receipt-layout --%>
        <%-- ══════════ RECEIPT MODE POPUP MODAL ══════════ --%>
        <asp:Panel ID="pnlReceiptModeModal" runat="server" Visible="false" Style="display: flex; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.55); z-index: 9999; align-items: center; justify-content: center; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;">
            <div style="background: #ffffff; border-radius: 8px; width: 680px; max-width: 95%; max-height: 90vh; overflow-y: auto; box-shadow: 0 10px 25px rgba(0,0,0,0.3); padding: 22px 24px; box-sizing: border-box;">
                
                <%-- Modal Header --%>
                <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #342867; padding-bottom: 8px; margin-bottom: 12px;">
                    <h3 style="margin: 0; color: #342867; font-size: 16px; font-weight: 700; font-family: inherit; text-transform: uppercase; letter-spacing: 0.03em;">Manage Receipt Modes</h3>
                </div>

                <%-- Selected Type Info --%>
                <div style="margin-bottom: 14px; font-size: 12.5px; color: #333333; background: #f8fafc; padding: 8px 12px; border-left: 3px solid #342867; border-radius: 3px; border: 1px solid #e2e8f0; border-left-width: 3px;">
                    Selected Receipt Type: <asp:Label ID="lblModalReceiptType" runat="server" Style="font-weight: 700; color: #342867;"></asp:Label>
                    <asp:HiddenField ID="hfModalReceiptTypeId" runat="server" />
                    <asp:HiddenField ID="hfSelectedReceiptModeID" runat="server" Value="0" />
                </div>

                <%-- Existing Modes Grid --%>
                <div style="font-weight: 700; font-size: 11.5px; text-transform: uppercase; color: #342867; margin-bottom: 6px; letter-spacing: 0.04em;">
                    Existing Receipt Modes
                </div>
                <div style="max-height: 180px; overflow-y: auto; border: 1px solid #dcdcdc; border-radius: 4px; margin-bottom: 16px;">
                    <asp:GridView ID="gvModalReceiptModes" runat="server" AutoGenerateColumns="False"
                        CssClass="gv-table" GridLines="None" Width="100%" OnRowCommand="gvModalReceiptModes_RowCommand"
                        DataKeyNames="ReceiptModeID"
                        HeaderStyle-BackColor="#342867" HeaderStyle-ForeColor="#ffffff" HeaderStyle-Font-Bold="true" HeaderStyle-Font-Size="11px"
                        RowStyle-Height="30px" RowStyle-Font-Size="12px" AlternatingRowStyle-BackColor="#f9f9f9">
                        <Columns>
                            <asp:BoundField DataField="ReceiptMode" HeaderText="Mode Name" />
                            <asp:BoundField DataField="Dept_Name" HeaderText="Cost Center" NullDisplayText="-" />
                            <asp:BoundField DataField="E_Name" HeaderText="Financial Head" NullDisplayText="-" />
                            <asp:TemplateField HeaderText="Validate Member" ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <%# (Eval("ValidateMember") != null && Convert.ToBoolean(Eval("ValidateMember"))) ? "Yes" : "No" %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Status" ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <span style='<%# (Eval("IsActive") != null && Convert.ToBoolean(Eval("IsActive"))) ? "color:#2e7d32;font-weight:700;" : "color:#c62828;font-weight:700;" %>'>
                                        <%# (Eval("IsActive") != null && Convert.ToBoolean(Eval("IsActive"))) ? "Active" : "Inactive" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnEditMode" runat="server" CommandName="EditMode"
                                        CommandArgument='<%# Eval("ReceiptModeID") %>' Text="Edit"
                                        Style="color: #342867; font-weight: 700; text-decoration: underline; font-size: 12px;" CausesValidation="false" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div style="padding: 10px; text-align: center; color: #777;">No receipt modes found for this type.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

                <%-- Form for Add / Edit --%>
                <div style="font-weight: 700; font-size: 12px; text-transform: uppercase; color: #342867; margin-bottom: 8px; border-bottom: 1px solid #eee; padding-bottom: 4px; letter-spacing: 0.03em;">
                    <asp:Label ID="lblFormTitle" runat="server" Text="Add New Receipt Mode"></asp:Label>
                </div>

                <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px 14px; margin-bottom: 12px;">
                    <div style="grid-column: span 2; display: flex; flex-direction: column;">
                        <label style="font-weight: 600; font-size: 11px; text-transform: uppercase; letter-spacing: 0.04em; color: #555555; margin-bottom: 4px; display: block;">Receipt Mode Name *</label>
                        <asp:TextBox ID="txtNewReceiptMode" runat="server" placeholder="Enter mode name..." Style="width: 100%; padding: 6px 8px; border: 1px solid #bbbbbb; font-size: 12.5px; font-family: inherit; outline: none; background: #ffffff; border-radius: 4px; box-sizing: border-box;"></asp:TextBox>
                    </div>

                    <div style="display: flex; flex-direction: column;">
                        <label style="font-weight: 600; font-size: 11px; text-transform: uppercase; letter-spacing: 0.04em; color: #555555; margin-bottom: 4px; display: block;">Cost Center</label>
                        <asp:DropDownList ID="ddlCostCenterModal" runat="server" Style="width: 100%; padding: 6px 8px; border: 1px solid #bbbbbb; font-size: 12.5px; font-family: inherit; outline: none; background: #ffffff; border-radius: 4px; box-sizing: border-box;"></asp:DropDownList>
                    </div>

                    <div style="display: flex; flex-direction: column;">
                        <label style="font-weight: 600; font-size: 11px; text-transform: uppercase; letter-spacing: 0.04em; color: #555555; margin-bottom: 4px; display: block;">Financial Head (Expenditure)</label>
                        <asp:DropDownList ID="ddlFinancialHeadModal" runat="server" Style="width: 100%; padding: 6px 8px; border: 1px solid #bbbbbb; font-size: 12.5px; font-family: inherit; outline: none; background: #ffffff; border-radius: 4px; box-sizing: border-box;"></asp:DropDownList>
                    </div>

                    <div style="display: flex; align-items: center; gap: 6px; margin-top: 4px; background: #f8fafc; padding: 6px 10px; border: 1px solid #e2e8f0; border-radius: 4px;">
                        <asp:CheckBox ID="chkValidateMember" runat="server" Style="cursor: pointer;" />
                        <label style="margin-bottom: 0; cursor: pointer; font-weight: 600; font-size: 11.5px; color: #333333;">Validate Member or Not</label>
                    </div>

                    <div style="display: flex; align-items: center; gap: 6px; margin-top: 4px; background: #f8fafc; padding: 6px 10px; border: 1px solid #e2e8f0; border-radius: 4px;">
                        <asp:CheckBox ID="chkIsActiveModal" runat="server" Checked="true" Style="cursor: pointer;" />
                        <label style="margin-bottom: 0; cursor: pointer; font-weight: 600; font-size: 11.5px; color: #333333;">Is Active</label>
                    </div>
                </div>

                <asp:Label ID="lblModalMsg" runat="server" Style="display: block; margin-bottom: 10px; font-weight: 600; font-size: 12px;"></asp:Label>

                <div style="display: flex; justify-content: flex-end; gap: 8px; border-top: 1px solid #e0e0e0; padding-top: 14px; margin-top: 8px;">
                    <asp:Button ID="btnResetModal" runat="server" Text="Reset Form" OnClick="btnResetModal_Click" CausesValidation="false" Style="padding: 6px 16px; font-size: 12.5px; font-family: inherit; font-weight: 600; border: 1px solid #6c757d; background: #6c757d; color: #ffffff !important; cursor: pointer; border-radius: 4px; text-transform: uppercase;" />
                    <asp:Button ID="btnSaveReceiptMode" runat="server" Text="Save" OnClick="btnSaveReceiptMode_Click" Style="padding: 6px 20px; font-size: 12.5px; font-family: inherit; font-weight: 600; border: none; background: #342867; color: #ffffff !important; cursor: pointer; border-radius: 4px; text-transform: uppercase; letter-spacing: 0.04em;" />
                    <asp:Button ID="btnCloseReceiptModeModal" runat="server" Text="Close" OnClick="btnCloseReceiptModeModal_Click" CausesValidation="false" Style="padding: 6px 16px; font-size: 12.5px; font-family: inherit; font-weight: 600; border: 1px solid #ccc; background: #e0e0e0; color: #333333 !important; cursor: pointer; border-radius: 4px; text-transform: uppercase;" />
                </div>
            </div>
        </asp:Panel>
    </div>
    <%-- /receipt-wrapper --%>
</asp:Content>
