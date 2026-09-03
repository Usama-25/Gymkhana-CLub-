<%@ page language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" autoeventwireup="true" CodeFile="OverdueManagement.aspx.cs" Inherits="Pages_OverdueManagement" title="Overdue Book Reminders & Reversals - Lahore Gymkhana Library" %>

<asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        /* Minimal stylesheet for print layout and pager buttons that cannot be styled inline */
        .pager-style td {
            padding: 12px 8px !important;
            background-color: #f8fafc;
            border-top: 1px solid #e2e8f0;
        }
        .pager-style a {
            padding: 6px 12px;
            background-color: #ffffff;
            border: 1px solid #cbd5e1;
            border-radius: 4px;
            color: #0f1e36;
            font-weight: 600;
            text-decoration: none;
            margin: 0 4px;
            display: inline-block;
            transition: all 0.2s ease;
        }
        .pager-style a:hover {
            background-color: #f1f5f9;
            border-color: #94a3b8;
        }
        .pager-style span {
            padding: 6px 12px;
            background-color: #0f1e36;
            color: #ffffff;
            font-weight: 600;
            border-radius: 4px;
            margin: 0 4px;
            display: inline-block;
            border: 1px solid #0f1e36;
        }

        /* Print Override styles (Optimized to force single-page output) */
        @media print {
            @page {
                size: A4;
                margin: 8mm 12mm 8mm 12mm; /* Narrow margins for print */
            }
            body * {
                visibility: hidden;
            }
            .printable-area, .printable-area * {
                visibility: visible;
            }
            .printable-area {
                position: absolute;
                left: 0;
                top: 0;
                width: 100%;
                padding: 0 !important;
                margin: 0 !important;
                font-size: 11px !important;
                line-height: 1.35 !important;
            }
            .no-print {
                display: none !important;
            }
            .letterhead {
                margin-bottom: 12px !important;
                padding-bottom: 6px !important;
                border-bottom: 2px double #000;
                display: flex;
                justify-content: space-between;
                align-items: flex-end;
            }
            .letter-content {
                font-size: 11px !important;
                margin-bottom: 10px !important;
                line-height: 1.6;
            }
            .letter-details {
                margin: 10px 0 !important;
                padding: 10px !important;
                background-color: #f8fafc;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                width: 100%;
            }
            .letter-details td {
                padding: 3px 6px !important;
            }
            .voucher-slip {
                padding: 15px !important;
                border-width: 1px !important;
                max-width: 100% !important;
                border: 2px dashed #cbd5e1;
                background-color: #fff;
                border-radius: 8px;
                margin: 0 auto;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">

    <!-- Title Header -->
    <div style="background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; padding: 20px 28px; border-radius: 8px; margin-bottom: 24px; border-bottom: 3px solid #c5a059; display: flex; justify-content: space-between; align-items: center; width: 100%; box-sizing: border-box;">
        <div>
            <h2 style="margin: 0; font-size: 22px; font-weight: 600;">Overdue Book Management</h2>
            <p style="margin: 4px 0 0; opacity: .8; font-size: 13px; font-weight: 300;">Manage active overdue loans, issue reminders, automate charges, and process reversals.</p>
        </div>
    </div>

    <!-- Alert Panel -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false" style="width: 100%;">
        <div id="divAlert" runat="server" style="padding: 16px 24px; border-radius: 8px; font-size: 14px; margin-bottom: 24px; border-left: 4px solid transparent; width: 100%; box-sizing: border-box;">
            <asp:Literal ID="litAlertMsg" runat="server" />
        </div>
    </asp:Panel>

    <!-- Main Card and Tabs -->
    <div style="width: 100%; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 1px 2px rgba(0,0,0,0.05); overflow: hidden; margin-bottom: 30px; box-sizing: border-box;">
        
        <!-- Tab Headers -->
        <div style="display: flex; background-color: #f8fafc; border-bottom: 1px solid #e2e8f0; width: 100%; overflow-x: auto; white-space: nowrap;">
            <asp:Button ID="btnTabReminders" runat="server" Text="Reminders Queue" style="padding: 18px 24px; text-align: center; background: none; border: none; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #c5a059; border-bottom: 3px solid #c5a059; cursor: pointer; transition: all 0.25s ease; outline: none;" OnClick="btnTab_Click" CommandArgument="REMINDERS" />
            <asp:Button ID="btnTabReversals" runat="server" Text="Reversal Desk" style="padding: 18px 24px; text-align: center; background: none; border: none; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.25s ease; outline: none;" OnClick="btnTab_Click" CommandArgument="REVERSALS" />
        </div>
        
        <asp:HiddenField ID="hfActiveTab" runat="server" Value="REMINDERS" />

        <div style="padding: 24px; width: 100%; box-sizing: border-box;">
            
            <!-- PANEL 1: REMINDERS QUEUE -->
            <asp:Panel ID="pnlTabReminders" runat="server" Visible="true">
                
                <!-- Filter bar -->
                <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 20px 24px; border-radius: 8px; margin-bottom: 24px; display: flex; gap: 16px; flex-wrap: wrap; align-items: flex-end; width: 100%; box-sizing: border-box;">
                    <div style="display: flex; flex-direction: column; gap: 6px; flex: 1; min-width: 180px;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Scenario / Stage</span>
                        <asp:DropDownList ID="ddlScenarioFilter" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlScenarioFilter_SelectedIndexChanged" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';">
                            <asp:ListItem Value="0">All Due Reminders</asp:ListItem>
                            <asp:ListItem Value="1">Scenario 1: Gentle Reminder (7+ Days Overdue)</asp:ListItem>
                            <asp:ListItem Value="2">Scenario 2: Harsh Reminder (15+ Days Overdue)</asp:ListItem>
                            <asp:ListItem Value="3">Scenario 3: Final Warning & Auto Charge (30+ Days Overdue)</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    
                    <div style="display: flex; flex-direction: column; gap: 6px; flex: 2; min-width: 180px;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Search Member / Book</span>
                        <asp:TextBox ID="txtSearchReminders" runat="server" AutoPostBack="true" OnTextChanged="txtSearchReminders_TextChanged" placeholder="Enter membership number, name, or book title..." style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>

                    <div style="height: 42px; display: flex; align-items: center;">
                        <asp:Button ID="btnRefreshReminders" runat="server" Text="Refresh List" style="padding: 10px 20px; border-radius: 6px; border: none; cursor: pointer; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnRefreshReminders_Click" />
                    </div>
                </div>

                <!-- GridView for Reminders -->
                <h3 style="font-size: 15px; margin: 0 0 12px 0; color: #0f1e36; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Overdue Book Loans Pending Action</h3>
                
                <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; background-color: #ffffff;">
                    <asp:GridView ID="gvReminders" runat="server" AutoGenerateColumns="False" 
                        GridLines="None" DataKeyNames="LoanID"
                        OnRowCommand="gvReminders_RowCommand" AllowPaging="True" PageSize="10"
                        OnPageIndexChanging="gvReminders_PageIndexChanging"
                        style="width: 100%; border-collapse: collapse; font-size: 13.5px; color: #1e293b;">
                        <HeaderStyle CssClass="gv-header-left" />
                        <RowStyle CssClass="gv-row" />
                        <AlternatingRowStyle CssClass="gv-alt-row" />
                        <PagerStyle CssClass="pager-style" HorizontalAlign="Center" />
                        <Columns>
                            <asp:TemplateField HeaderText="Member Details">
                                <HeaderStyle CssClass="gv-header" />
                                <ItemStyle CssClass="gv-text-left" />
                                <ItemTemplate>
                                    <div style="font-weight: 600; color: #0f1e36;"><%# Eval("MemberName") %></div>
                                    <div style="font-size: 11.5px; color: #64748b;"><%# Eval("MembershipNo") %> â€¢ Phone: <%# Eval("Phone") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Book Details">
                                <HeaderStyle CssClass="gv-header" />
                                <ItemStyle CssClass="gv-text-left" />
                                <ItemTemplate>
                                    <div style="font-weight: 500;"><%# Eval("BookTitle") %></div>
                                    <div style="font-size: 11.5px; color: #64748b;">Barcode: <span style="font-family: monospace; font-weight: bold;"><%# Eval("Barcode") %></span></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Dates">
                                <HeaderStyle CssClass="gv-header" />
                                <ItemStyle CssClass="gv-text-left" />
                                <ItemTemplate>
                                    <div style="font-size: 12px;">Issued: <strong><%# Convert.ToDateTime(Eval("IssueDate")).ToString("dd-MMM-yyyy") %></strong></div>
                                    <div style="font-size: 12px; color: #ef4444;">Due: <strong><%# Convert.ToDateTime(Eval("DueDate")).ToString("dd-MMM-yyyy") %></strong></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Overdue Info">
                                <HeaderStyle CssClass="gv-header" />
                                <ItemStyle CssClass="gv-text-left" />
                                <ItemTemplate>
                                    <div style="font-size: 13px; font-weight: 700; color: #b91c1c;"><%# Eval("DaysOverdue") %> Days</div>
                                    <div style="font-size: 11px; color: #4b5563;">Est. Fine: Rs. <%# Convert.ToDecimal(Eval("EstFine")).ToString("N2") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Stage">
                                <HeaderStyle CssClass="gv-header" />
                                <ItemStyle CssClass="gv-text-left" />
                                <ItemTemplate>
                                    <span style='display: inline-block; padding: 4px 8px; border-radius: 12px; font-size: 11px; font-weight: 600; text-transform: uppercase; <%# Convert.ToInt32(Eval("ApplicableScenario")) == 1 ? "background-color: #d1fae5; color: #065f46;" : (Convert.ToInt32(Eval("ApplicableScenario")) == 2 ? "background-color: #fef3c7; color: #92400e;" : "background-color: #fee2e2; color: #991b1b;") %>'>
                                        Scenario <%# Eval("ApplicableScenario") %>
                                    </span>
                                    <div style="font-size: 10px; color: #64748b; margin-top: 4px;">
                                        <%# Eval("Reminder1SentDate") != DBNull.Value ? "âœ” R1 sent" : "" %>
                                        <%# Eval("Reminder2SentDate") != DBNull.Value ? "<br/>âœ” R2 sent" : "" %>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Actions" ItemStyle-Width="250px">
                                <HeaderStyle CssClass="gv-header" />
                                <ItemStyle CssClass="gv-text-left" />
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnGenerate" runat="server" CommandName="GenerateLetter" CommandArgument='<%# Container.DataItemIndex %>' 
                                        style="padding: 6px 12px; font-size: 11px; margin-right: 6px; text-decoration: none; border-radius: 6px; border: none; cursor: pointer; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" Text="Generate Letter" />
                                    <asp:LinkButton ID="btnMarkSent" runat="server" CommandName="MarkSent" CommandArgument='<%# Eval("LoanID") %>'
                                        style="padding: 6px 12px; font-size: 11px; text-decoration: none; border-radius: 6px; border: none; cursor: pointer; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" Text='<%# Convert.ToInt32(Eval("ApplicableScenario")) == 3 ? "Process & Charge" : "Mark Sent" %>' 
                                        OnClientClick='<%# Convert.ToInt32(Eval("ApplicableScenario")) == 3 ? "return confirm(\"This will automatically charge Book Cost + Penalty + Overdue Fine to the member account. Proceed?\");" : "" %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div style="padding: 40px; text-align: center; color: #64748b; font-style: italic;">No active book loans match the selected overdue stage filter.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </asp:Panel>

            <!-- PANEL 2: REVERSAL DESK -->
            <asp:Panel ID="pnlTabReversals" runat="server" Visible="false">
                
                <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; padding: 20px 24px; border-radius: 8px; margin-bottom: 24px; display: flex; gap: 16px; flex-wrap: wrap; align-items: flex-end; width: 100%; box-sizing: border-box;">
                    <div style="display: flex; flex-direction: column; gap: 6px; flex: 2; min-width: 180px;">
                        <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Search Charged Member / Loan</span>
                        <asp:TextBox ID="txtSearchReversals" runat="server" AutoPostBack="true" OnTextChanged="txtSearchReversals_TextChanged" placeholder="Enter membership number or name..." style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
                    </div>
                    
                    <div style="height: 42px; display: flex; align-items: center;">
                        <asp:Button ID="btnRefreshReversals" runat="server" Text="Refresh List" style="padding: 10px 20px; border-radius: 6px; border: none; cursor: pointer; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnRefreshReversals_Click" />
                    </div>
                </div>

                <h3 style="font-size: 15px; margin: 0 0 12px 0; color: #0f1e36; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Final Charged Loans Available for Reversal</h3>
                
                <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; background-color: #ffffff;">
                    <asp:GridView ID="gvReversals" runat="server" AutoGenerateColumns="False" 
                        GridLines="None" DataKeyNames="LoanID"
                        OnRowCommand="gvReversals_RowCommand" AllowPaging="True" PageSize="10"
                        OnPageIndexChanging="gvReversals_PageIndexChanging"
                        style="width: 100%; border-collapse: collapse; font-size: 13.5px; color: #1e293b;">
                        <HeaderStyle CssClass="gv-header-left" />
                        <RowStyle CssClass="gv-row" />
                        <AlternatingRowStyle CssClass="gv-alt-row" />
                        <PagerStyle CssClass="pager-style" HorizontalAlign="Center" />
                        <Columns>
                            <asp:TemplateField HeaderText="Member">
                                <HeaderStyle CssClass="gv-header" />
                                <ItemStyle CssClass="gv-text-left" />
                                <ItemTemplate>
                                    <div style="font-weight: 600; color: #0f1e36;"><%# Eval("MemberName") %></div>
                                    <div style="font-size: 11.5px; color: #64748b;"><%# Eval("MembershipNo") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Book Details">
                                <HeaderStyle CssClass="gv-header" />
                                <ItemStyle CssClass="gv-text-left" />
                                <ItemTemplate>
                                    <div style="font-weight: 500;"><%# Eval("BookTitle") %></div>
                                    <div style="font-size: 11.5px; color: #64748b;">Barcode: <%# Eval("Barcode") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Charged Date">
                                <HeaderStyle CssClass="gv-header" />
                                <ItemStyle CssClass="gv-text-left" />
                                <ItemTemplate>
                                    <div style="font-size: 12.5px;"><%# Convert.ToDateTime(Eval("ChargedDate")).ToString("dd-MMM-yyyy hh:mm tt") %></div>
                                    <div style="font-size: 11px; color: #64748b;">Due Date: <%# Convert.ToDateTime(Eval("DueDate")).ToString("dd-MMM-yyyy") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Fine Breakdown">
                                <HeaderStyle CssClass="gv-header" />
                                <ItemStyle CssClass="gv-text-left" />
                                <ItemTemplate>
                                    <div style="font-size: 11.5px;">Overdue Fine: Rs. <strong><%# Convert.ToDecimal(Eval("OverdueFine")).ToString("N2") %></strong> (Non-Rev)</div>
                                    <div style="font-size: 11.5px; color: #475569;">Book Cost: Rs. <%# Convert.ToDecimal(Eval("BookCostCharge")).ToString("N2") %></div>
                                    <div style="font-size: 11.5px; color: #475569;">Penalty: Rs. <%# Convert.ToDecimal(Eval("PenaltyCharge")).ToString("N2") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Total Charged">
                                <HeaderStyle CssClass="gv-header" />
                                <ItemStyle CssClass="gv-text-left" />
                                <ItemTemplate>
                                    <div style="font-size: 14px; font-weight: 700; color: #b91c1c;">Rs. <%# Convert.ToDecimal(Eval("TotalCharged")).ToString("N2") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Action" ItemStyle-Width="180px">
                                <HeaderStyle CssClass="gv-header" />
                                <ItemStyle CssClass="gv-text-left" />
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnReverse" runat="server" CommandName="ProcessReversal" CommandArgument='<%# Eval("LoanID") %>'
                                        style="padding: 6px 12px; font-size: 11px; text-decoration: none; border-radius: 6px; border: none; cursor: pointer; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" Text="Process Reversal" 
                                        OnClientClick="return confirm('This will reverse Book Cost & Penalty charges, retain the Overdue Days fine, and generate a payment voucher. Proceed?');" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div style="padding: 40px; text-align: center; color: #64748b; font-style: italic;">No loans currently hold final charges (Scenario 3) pending reversal.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

            </asp:Panel>

        </div>
    </div>

    <!-- MODAL 1: LETTER GENERATOR MODAL -->
    <asp:Panel ID="pnlLetterModal" runat="server" Visible="false" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.6); display: flex; justify-content: center; align-items: center; z-index: 1000;">
        <div style="background-color: #ffffff; border-radius: 12px; width: 80%; max-width: 800px; max-height: 90%; overflow-y: auto; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.15); display: flex; flex-direction: column; border-top: 5px solid #c5a059;">
            <div style="padding: 16px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
                <h3 style="margin:0; font-size:16px; color:#0f1e36; font-weight:700;">Overdue Letter Preview</h3>
                <asp:Button ID="btnCloseLetter" runat="server" Text="&times;" style="border:none; background:none; font-size:24px; cursor:pointer;" OnClick="btnCloseLetter_Click" />
            </div>
            <div class="printable-area" style="padding: 30px; flex-grow: 1; font-family: Arial, sans-serif; color: #000000; background-color: #ffffff;">
                <asp:Literal ID="litPrintableLetter" runat="server" />
                
                <!-- Old controls kept for compilation fallback, made invisible -->
                <asp:PlaceHolder ID="phOldControls" runat="server" Visible="false">
                    <div class="letterhead">
                        <asp:Literal ID="litLetterRef" runat="server" />
                    </div>
                    <asp:Literal ID="litLetterMemberName" runat="server" />
                    <asp:Literal ID="litLetterMemberNo" runat="server" />
                    <asp:Literal ID="litLetterMemberAddress" runat="server" />
                    <asp:Literal ID="litLetterSubject" runat="server" />
                    <asp:Literal ID="litLetterMainBody" runat="server" />
                    <asp:Literal ID="litLetterBookTitle" runat="server" />
                    <asp:Literal ID="litLetterBarcode" runat="server" />
                    <asp:Literal ID="litLetterIssueDate" runat="server" />
                    <asp:Literal ID="litLetterDueDate" runat="server" />
                    <asp:Literal ID="litLetterOverdueDays" runat="server" />
                    <asp:PlaceHolder ID="phFinancialDetails" runat="server">
                        <asp:Literal ID="litDaysFineCount" runat="server" />
                        <asp:Literal ID="litDaysFineAmt" runat="server" />
                        <asp:Literal ID="litBookCostAmt" runat="server" />
                        <asp:Literal ID="litPenaltyAmt" runat="server" />
                        <asp:Literal ID="litTotalLiabAmt" runat="server" />
                    </asp:PlaceHolder>
                </asp:PlaceHolder>
            </div>
            <div style="padding: 16px 24px; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 12px;" class="no-print">
                <button type="button" style="padding: 10px 20px; border-radius: 6px; border: none; cursor: pointer; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" onclick="window.print();">Print & Post Notice</button>
                <asp:Button ID="btnCloseLetterFooter" runat="server" Text="Close Preview" style="padding: 10px 20px; border-radius: 6px; border: none; cursor: pointer; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" OnClick="btnCloseLetter_Click" />
            </div>
        </div>
    </asp:Panel>

    <!-- MODAL 2: VOUCHER SLIP PREVIEW -->
    <asp:Panel ID="pnlVoucherModal" runat="server" Visible="false" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.6); display: flex; justify-content: center; align-items: center; z-index: 1000;">
        <div style="background-color: #ffffff; border-radius: 12px; width: 80%; max-width: 600px; max-height: 90%; overflow-y: auto; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.15); display: flex; flex-direction: column; border-top: 5px solid #c5a059;">
            <div style="padding: 16px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
                <h3 style="margin:0; font-size:16px; color:#0f1e36; font-weight:700;">Overdue Fine Voucher Generated</h3>
                <asp:Button ID="btnCloseVoucher" runat="server" Text="&times;" style="border:none; background:none; font-size:24px; cursor:pointer;" OnClick="btnCloseVoucher_Click" />
            </div>
            <div class="printable-area" style="padding: 30px; flex-grow: 1; font-family: 'Inter', 'Segoe UI', Arial, sans-serif; color: #2d3748;">
                <div style="border: 2px dashed #cbd5e1; padding: 24px; background-color: #fff; border-radius: 8px; max-width: 600px; margin: 0 auto;">
                    <!-- Gymkhana Logo Header -->
                    <div style="text-align: center; border-bottom: 2px dashed #000; padding-bottom: 12px; margin-bottom: 16px;">
                        <img src='<%= ResolveUrl("~/Library Management/Images/logo_new.png") %>' alt="Lahore Gymkhana" style="height: 50px;" /><br />
                        <strong style="font-size: 16px; text-transform: uppercase; letter-spacing: 1px;">Lahore Gymkhana Club</strong><br />
                        <span style="font-size: 11px; color:#4b5563;">Library Accounts Section â€” Pay Slip</span>
                    </div>

                    <table style="width: 100%; border-collapse: collapse; font-size: 13px; line-height: 1.8;">
                        <tr>
                            <td width="120"><strong>Voucher No:</strong></td>
                            <td style="font-family: monospace; font-size: 15px; font-weight: bold; color: #b91c1c;">
                                <asp:Literal ID="litVoucherNo" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td><strong>Issue Date:</strong></td>
                            <td><% = DateTime.Now.ToString("dd-MMM-yyyy hh:mm tt") %></td>
                        </tr>
                        <tr>
                            <td><strong>Member Name:</strong></td>
                            <td><asp:Literal ID="litVoucherMemberName" runat="server" /></td>
                        </tr>
                        <tr>
                            <td><strong>Membership No:</strong></td>
                            <td><strong><asp:Literal ID="litVoucherMemberNo" runat="server" /></strong></td>
                        </tr>
                        <tr>
                            <td><strong>Status:</strong></td>
                            <td><span style="display: inline-block; padding: 4px 8px; border-radius: 12px; font-size: 11px; font-weight: 600; text-transform: uppercase; background-color: #fee2e2; color: #991b1b;">Pending Cashier Payment</span></td>
                        </tr>
                    </table>

                    <div style="border-top: 1px solid #cbd5e1; border-bottom: 1px solid #cbd5e1; margin: 16px 0; padding: 12px 0;">
                        <strong style="font-size:12px; text-transform:uppercase; color:#0f1e36;">Charge Descriptions</strong>
                        <table style="width: 100%; font-size: 12.5px; margin-top: 6px;">
                            <tr>
                                <td>Overdue Fine (Retained from Scenario 3 Reversal):</td>
                                <td style="text-align: right; font-weight: bold;">Rs. <asp:Literal ID="litVoucherOverdueFineAmt" runat="server" /></td>
                            </tr>
                            <tr style="font-size: 11px; color: #475569;">
                                <td colspan="2">
                                    <em>Note: Book Cost & Penalty charges have been fully reversed.</em>
                                </td>
                            </tr>
                        </table>
                    </div>

                    <table style="width: 100%; font-size: 16px; font-weight: bold; color: #b91c1c;">
                        <tr>
                            <td>NET PAYABLE AMOUNT:</td>
                            <td style="text-align: right;">Rs. <asp:Literal ID="litVoucherNetPayable" runat="server" /></td>
                        </tr>
                    </table>

                    <div style="margin-top: 25px; border-top: 1px dotted #94a3b8; padding-top: 20px; text-align: center; font-size: 11px; color: #64748b;">
                        Please present this slip at the Cashier Counter to clear your dues.<br />
                        <br />
                        <div style="display: flex; justify-content: space-between; margin-top: 30px;">
                            <div style="border-top: 1px solid #94a3b8; width: 40%; padding-top: 4px;"><strong>Librarian Sign</strong></div>
                            <div style="border-top: 1px solid #94a3b8; width: 40%; padding-top: 4px;"><strong>Member Sign</strong></div>
                        </div>
                    </div>
                </div>
            </div>
            <div style="padding: 16px 24px; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 12px;" class="no-print">
                <button type="button" style="padding: 10px 20px; border-radius: 6px; border: none; cursor: pointer; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block;" onclick="window.print();">Print Voucher Slip</button>
                <asp:Button ID="btnCloseVoucherFooter" runat="server" Text="Close Desk" style="padding: 10px 20px; border-radius: 6px; border: none; cursor: pointer; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block;" OnClick="btnCloseVoucher_Click" />
            </div>
        </div>
    </asp:Panel>

</asp:Content>
