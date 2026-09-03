<%@ Page Language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" AutoEventWireup="true"
    CodeFile="ReturnBook.aspx.cs" Inherits="Pages_Circulation_ReturnBook"
    Title="Return & Reissue Desk - Lahore Gymkhana Library" %>

    <asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
        <style>
            .form-control-desk:focus {
                border-color: #c5a059 !important;
                box-shadow: 0 0 0 3px rgba(197, 160, 89, 0.15) !important;
            }
            .btn-outline-gold:hover {
                background-color: #0f1e36 !important;
                color: #ffffff !important;
                border-color: #0f1e36 !important;
            }
            .btn-return-action:hover {
                background-color: #059669 !important;
                transform: translateY(-1px);
                box-shadow: 0 4px 6px rgba(16, 185, 129, 0.2);
            }
            .btn-reissue-action:hover {
                background-color: #b08d4a !important;
                color: #ffffff !important;
                transform: translateY(-1px);
                box-shadow: 0 4px 6px rgba(197, 160, 89, 0.2);
            }
            .btn-primary-desk:hover {
                background-color: #b08d4a !important;
                border-color: #b08d4a !important;
                transform: translateY(-1px);
                box-shadow: 0 4px 12px rgba(197, 160, 89, 0.35) !important;
            }
            .active-loans-grid {
                width: 100%;
                border-collapse: collapse;
                text-align: left;
                font-size: 13.5px;
                border: none !important;
            }
            .active-loans-grid th {
                padding: 14px 16px !important;
                background-color: #0f1e36 !important;
                font-weight: 700 !important;
                font-size: 12px !important;
                text-transform: uppercase !important;
                color: #ffffff !important;
                border-bottom: 3px solid #c5a059 !important;
                letter-spacing: 0.5px !important;
                border-top: none !important;
                border-left: none !important;
                border-right: none !important;
            }
            .active-loans-grid td {
                padding: 14px 16px !important;
                border-bottom: 1px solid #e2e8f0 !important;
                color: #334155 !important;
                border-top: none !important;
                border-left: none !important;
                border-right: none !important;
            }
            .active-loans-grid tr {
                background-color: #ffffff !important;
                transition: background-color 0.15s ease;
            }
            .active-loans-grid tr:hover {
                background-color: #f8fafc !important;
            }
            .col-header-center {
                text-align: center !important;
            }
            .col-header-left {
                text-align: left !important;
            }
            .col-item-center {
                text-align: center !important;
            }
            .col-item-left {
                text-align: left !important;
            }
            .col-mono {
                font-family: 'Courier New', Courier, monospace;
                font-weight: 600;
            }
        </style>
    </asp:Content>

    <asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">

        <!-- Header -->
        <div style="background: linear-gradient(135deg, #0f1e36 0%, #1e293b 100%); border-left: 5px solid #c5a059; padding: 24px 32px; border-radius: 12px; margin-bottom: 30px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 20px; box-shadow: 0 4px 20px rgba(15, 30, 54, 0.08); box-sizing: border-box; width: 100%;">
            <div>
                <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #c5a059; letter-spacing: 2px;">Circulation Console</span>
                <h2 style="margin: 4px 0 0 0; font-family: 'Playfair Display', serif; font-size: 26px; font-weight: 700; color: #ffffff; letter-spacing: -0.3px;">Returns & Reissues Desk</h2>
                <p style="margin: 6px 0 0 0; opacity: .75; font-size: 13.5px; color: #f8fafc; font-weight: 400;">Lahore Gymkhana Club — Book returns, immediate reissuance, and renewal processing</p>
            </div>
            <div>
                <a href="<%= ResolveUrl("~/Library Management/IssueReturn.aspx") %>" class="btn-primary-desk" style="display: inline-flex; align-items: center; gap: 8px; padding: 12px 20px; border-radius: 30px; text-decoration: none; font-size: 13px; font-weight: 700; transition: all 0.25s ease; background-color: #c5a059; color: #0f1e36; border: 1px solid #c5a059; box-shadow: 0 4px 12px rgba(197, 160, 89, 0.25);">
                    <i class="fas fa-arrow-left-long" style="font-size: 14px;"></i>
                    <span>Go to Book Issuance Desk</span>
                </a>
            </div>
        </div>

        <asp:UpdatePanel ID="upReturnDesk" runat="server" UpdateMode="Conditional">
            <ContentTemplate>

                <!-- Alert Panel -->
                <asp:Panel ID="pnlAlert" runat="server" Visible="false" style="width: 100%;">
                    <div id="divAlert" runat="server"
                        style="padding: 16px 24px; border-radius: 10px; font-size: 14px; margin-bottom: 24px; border-left: 4px solid transparent; width: 100%; box-sizing: border-box; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02); font-weight: 500;">
                        <asp:Literal ID="litAlertMsg" runat="server" />
                    </div>
                </asp:Panel>

                <!-- Policy Warning Panel -->
                <asp:Panel ID="pnlPolicyWarning" runat="server" Visible="false" style="width: 100%;">
                    <div id="divPolicyWarning" runat="server"
                        style="padding: 16px 24px; border-radius: 10px; font-size: 13.5px; margin-bottom: 24px; border-left: 4px solid #f59e0b; background-color: #fef3c7; color: #92400e; width: 100%; box-sizing: border-box; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);">
                        <strong style="font-weight: 700; display: flex; align-items: center; gap: 8px; margin-bottom: 6px;">
                            <i class="fas fa-circle-exclamation" style="font-size: 16px;"></i> Library Policy Alerts / Warnings:
                        </strong>
                        <ul style="margin: 4px 0 0 20px; padding: 0; line-height: 1.6; font-weight: 500;">
                            <asp:Literal ID="litPolicyWarningMsg" runat="server" />
                        </ul>
                    </div>
                </asp:Panel>

                <!-- Return Form -->
                <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 16px; box-shadow: 0 10px 30px rgba(15, 30, 54, 0.03); margin-bottom: 30px; overflow: hidden; width: 100%;">
                    <div style="padding: 20px 28px; font-size: 16px; font-weight: 700; color: #ffffff; display: flex; align-items: center; justify-content: space-between; background: linear-gradient(90deg, #0f1e36 0%, #1e293b 100%); border-bottom: 3px solid #c5a059;">
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <i class="fas fa-desktop" style="color: #c5a059;"></i>
                            <span>Return, Reissue or Renew Books</span>
                        </div>
                        <span style="font-size: 11px; text-transform: uppercase; color: rgba(255,255,255,0.6); font-weight: 500; letter-spacing: 1px;">Circulation Management</span>
                    </div>
                    <div style="padding: 28px; width: 100%; box-sizing: border-box;">
                        
                        <!-- Search Console -->
                        <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px; margin-bottom: 28px;">
                            <div style="font-size: 12px; font-weight: 700; color: #475569; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 14px; display: flex; align-items: center; gap: 8px;">
                                <i class="fas fa-magnifying-glass" style="color: #c5a059;"></i>
                                <span>Search & Scan Filters</span>
                            </div>
                            
                            <div style="display: flex; gap: 20px; align-items: flex-end; flex-wrap: wrap; width: 100%; box-sizing: border-box;">
                                
                                <!-- Field 1: Barcode -->
                                <div style="flex: 1; min-width: 220px; display: flex; flex-direction: column; gap: 8px;">
                                    <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #475569; letter-spacing: 0.5px; display: flex; align-items: center; gap: 6px;">
                                        <i class="fas fa-barcode" style="color: #64748b;"></i> Scan Barcode / Book No
                                    </span>
                                    <asp:TextBox ID="txtReturnBarcode" runat="server" AutoPostBack="true" OnTextChanged="txtReturnBarcode_TextChanged"
                                        style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box; transition: all 0.2s;"
                                        placeholder="Scan Barcode or Book No..."
                                        class="form-control-desk"
                                        onchange="checkOverdueStatus()" />
                                </div>

                                <!-- Field 2: Issue Number -->
                                <div style="flex: 1; min-width: 180px; display: flex; flex-direction: column; gap: 8px;">
                                    <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #475569; letter-spacing: 0.5px; display: flex; align-items: center; gap: 6px;">
                                        <i class="fas fa-receipt" style="color: #64748b;"></i> Loan ID / Issue No
                                    </span>
                                    <asp:TextBox ID="txtReturnIssueNo" runat="server" AutoPostBack="true" OnTextChanged="txtReturnIssueNo_TextChanged"
                                        style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box; transition: all 0.2s;"
                                        placeholder="Enter Loan ID..."
                                        class="form-control-desk"
                                        onchange="checkOverdueStatus()" />
                                </div>

                                <!-- Field 3: Search Member -->
                                <div style="flex: 1.2; min-width: 250px; display: flex; flex-direction: column; gap: 8px;">
                                    <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #475569; letter-spacing: 0.5px; display: flex; align-items: center; gap: 6px;">
                                        <i class="fas fa-user-tag" style="color: #64748b;"></i> Search Member No / Name
                                    </span>
                                    <div style="display: flex; gap: 8px; width: 100%;">
                                        <asp:TextBox ID="txtReturnMemberSearch" runat="server"
                                            placeholder="Name or member no (e.g. A-1234)..."
                                            style="flex: 1; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box; transition: all 0.2s;"
                                            class="form-control-desk" />
                                        <asp:Button ID="btnSearchReturnMember" runat="server" Text="Filter"
                                            OnClick="btnSearchReturnMember_Click"
                                            style="padding: 12px 20px; border-radius: 8px; border: 1px solid #c5a059; background-color: #ffffff; color: #0f1e36; font-size: 12px; font-weight: 700; cursor: pointer; text-transform: uppercase; transition: all 0.2s;"
                                            class="btn-outline-gold" />
                                    </div>
                                </div>

                                <!-- Field 4: Select Member Dropdown -->
                                <div style="flex: 1.2; min-width: 250px; display: flex; flex-direction: column; gap: 8px;">
                                    <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #475569; letter-spacing: 0.5px; display: flex; align-items: center; gap: 6px;">
                                        <i class="fas fa-user-check" style="color: #64748b;"></i> Select Member
                                    </span>
                                    <asp:DropDownList ID="ddlReturnMemberLookup" runat="server"
                                        style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 48px; transition: all 0.2s;"
                                        class="form-control-desk"
                                        AutoPostBack="true" OnSelectedIndexChanged="ddlReturnMemberLookup_Changed" />
                                </div>

                            </div>
                        </div>

                        <div style="display: flex; gap: 30px; flex-wrap: wrap; width: 100%; box-sizing: border-box;">
                            
                            <!-- Left Sub-column: Inputs & Grid -->
                            <div style="flex: 1.6; min-width: 320px; box-sizing: border-box;">

                                <!-- Active Loans Grid -->
                                <asp:Panel ID="pnlActiveLoansGridContainer" runat="server" Visible="false" style="margin-bottom: 24px; width: 100%;">
                                    <div style="font-size: 13px; font-weight: 700; color: #475569; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 12px; display: flex; align-items: center; gap: 8px;">
                                        <i class="fas fa-list-check" style="color: #c5a059;"></i>
                                        <span>Active Borrowed Copies</span>
                                    </div>
                                    
                                    <div style="overflow-x: auto; width: 100%; border: 1px solid #e2e8f0; border-radius: 12px; background-color: #ffffff; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);">
                                        <asp:GridView ID="gvActiveLoans" runat="server" AutoGenerateColumns="False" 
                                            DataKeyNames="LoanID,CopyID,DueDate" OnRowCommand="gvActiveLoans_RowCommand"
                                            OnRowDataBound="gvActiveLoans_RowDataBound"
                                            style="width: 100%; border-collapse: collapse; text-align: left; font-size: 13.5px; border: none;"
                                            GridLines="None" UseAccessibleHeader="true">
                                            <Columns>
                                                <asp:BoundField DataField="LoanID" HeaderText="Issue No" />
                                                <asp:BoundField DataField="Title" HeaderText="Book Title" />
                                                <asp:BoundField DataField="BookNo" HeaderText="Book No" />
                                                <asp:BoundField DataField="Barcode" HeaderText="Barcode" />
                                                <asp:BoundField DataField="IssueDate" HeaderText="Issued On" DataFormatString="{0:dd-MMM-yyyy}" />
                                                <asp:BoundField DataField="DueDate" HeaderText="Due Date" DataFormatString="{0:dd-MMM-yyyy}" />
                                                <asp:TemplateField HeaderText="Est Fine">
                                                    <ItemTemplate>
                                                        <%# GetEstimatedFineBadge(Eval("DueDate")) %>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Actions">
                                                    <ItemTemplate>
                                                        <div style="display: flex; gap: 8px; justify-content: center; align-items: center;">
                                                            <asp:LinkButton ID="btnGridReturn" runat="server" CommandName="ReturnBook" CommandArgument='<%# Container.DataItemIndex %>'
                                                                OnClientClick="return confirm('Are you sure you want to return this book?');"
                                                                style="display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; border-radius: 20px; border: none; background-color: #10b981; color: #ffffff; font-size: 11px; font-weight: 700; cursor: pointer; text-decoration: none; text-transform: uppercase; transition: all 0.2s;"
                                                                class="btn-return-action">
                                                                <i class="fas fa-rotate-left"></i><span>Return</span>
                                                            </asp:LinkButton>
                                                            <asp:LinkButton ID="btnGridReissue" runat="server" CommandName="ReissueBook" CommandArgument='<%# Container.DataItemIndex %>'
                                                                OnClientClick="return confirm('Are you sure you want to reissue/renew this book? This will extend the due date by 15 days.');"
                                                                style="display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; border-radius: 20px; border: none; background-color: #c5a059; color: #0f1e36; font-size: 11px; font-weight: 700; cursor: pointer; text-decoration: none; text-transform: uppercase; transition: all 0.2s;"
                                                                class="btn-reissue-action">
                                                                <i class="fas fa-arrows-rotate"></i><span>Reissue</span>
                                                            </asp:LinkButton>
                                                        </div>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                            <EmptyDataTemplate>
                                                <div style="padding: 40px 20px; text-align: center; color: #64748b; display: flex; flex-direction: column; align-items: center; gap: 12px;">
                                                    <div style="font-size: 36px; color: #cbd5e1;"><i class="fas fa-book-open"></i></div>
                                                    <div style="font-size: 14px; font-weight: 600; color: #475569;">No Active Borrowed Books</div>
                                                    <div style="font-size: 12px; color: #94a3b8; max-width: 300px;">There are no active book transactions on this account.</div>
                                                </div>
                                            </EmptyDataTemplate>
                                        </asp:GridView>
                                    </div>
                                </asp:Panel>

                            </div>

                            <!-- Right Sub-column: Return Settings -->
                            <div style="flex: 1; min-width: 300px; box-sizing: border-box;">
                                
                                <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02); box-sizing: border-box;">
                                    <div style="font-size: 13px; font-weight: 700; color: #475569; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 18px; display: flex; align-items: center; gap: 8px;">
                                        <i class="fas fa-sliders" style="color: #c5a059;"></i>
                                        <span>Return Settings</span>
                                    </div>

                                    <!-- Return Condition -->
                                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 20px; width: 100%; box-sizing: border-box;">
                                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin: 0;">Return Condition</label>
                                        <asp:DropDownList ID="ddlReturnCondition" runat="server"
                                            style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 48px; transition: all 0.2s;"
                                            class="form-control-desk"
                                            AutoPostBack="true" OnSelectedIndexChanged="ddlReturnCondition_SelectedIndexChanged">
                                            <asp:ListItem Value="1">New</asp:ListItem>
                                            <asp:ListItem Value="2" Selected="True">Good</asp:ListItem>
                                            <asp:ListItem Value="3">Fair</asp:ListItem>
                                            <asp:ListItem Value="4">Worn</asp:ListItem>
                                            <asp:ListItem Value="5">Damaged</asp:ListItem>
                                            <asp:ListItem Value="6">Lost</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>

                                    <!-- Custom Return Date/Time -->
                                    <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 16px; margin-bottom: 20px; width: 100%; box-sizing: border-box;">
                                        <div style="font-size: 11px; font-weight: 700; color: #475569; text-transform: uppercase; margin-bottom: 12px; display: flex; align-items: center; gap: 6px;">
                                            <span style="width: 6px; height: 6px; background: #c5a059; border-radius: 50%;"></span>
                                            Custom Return Date/Time
                                        </div>
                                        <div style="display: flex; gap: 12px; flex-wrap: wrap; width: 100%; box-sizing: border-box;">
                                            <div style="flex: 1; min-width: 110px; display: flex; flex-direction: column; gap: 6px;">
                                                <label style="font-size: 10px; font-weight: 600; color: #64748b; text-transform: uppercase;">Return Date</label>
                                                <asp:TextBox ID="txtReturnDate" runat="server" TextMode="Date"
                                                    style="width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; outline: none; background-color: #ffffff; box-sizing: border-box; transition: all 0.2s;"
                                                    class="form-control-desk"
                                                    onchange="checkOverdueStatus()" />
                                            </div>
                                            <div style="flex: 1; min-width: 110px; display: flex; flex-direction: column; gap: 6px;">
                                                <label style="font-size: 10px; font-weight: 600; color: #64748b; text-transform: uppercase;">Return Time</label>
                                                <asp:TextBox ID="txtReturnTime" runat="server" TextMode="Time"
                                                    style="width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; outline: none; background-color: #ffffff; box-sizing: border-box; transition: all 0.2s;"
                                                    class="form-control-desk"
                                                    onchange="checkOverdueStatus()" />
                                            </div>
                                        </div>
                                        <div style="font-size: 10px; color: #94a3b8; margin-top: 8px; line-height: 1.4;">Leave blank to use current system time. Overdue fines calculate based on this date.</div>
                                    </div>

                                    <!-- Real-time Overdue Status (AJAX) -->
                                    <div id="overdueStatusContainer" style="display: none; padding: 16px; border-radius: 8px; font-size: 13px; margin-bottom: 20px; transition: all 0.25s ease;">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Modal Reservation Alert Pop-up -->
                <asp:Panel ID="pnlReservationAlertModal" runat="server" Visible="false"
                    style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(15,23,42,0.6); z-index: 1000; display: flex; align-items: center; justify-content: center; backdrop-filter: blur(4px);">
                    <div style="background-color: #ffffff; border-radius: 16px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04); max-width: 460px; width: 90%; padding: 32px 24px; text-align: center; border-top: 5px solid #c5a059;">
                        <div style="width: 56px; height: 56px; background-color: #fef3c7; color: #d97706; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 24px; margin: 0 auto 18px auto;">
                            <i class="fas fa-exclamation-triangle"></i>
                        </div>
                        <h3 style="font-size: 19px; font-weight: 700; color: #0f1e36; margin: 0 0 8px 0; text-transform: uppercase; letter-spacing: 0.5px;">Reservation Alert</h3>
                        <p style="font-size: 14.5px; color: #475569; margin: 0 0 12px 0; line-height: 1.5;">
                            This returned book is currently reserved for:<br />
                            <strong style="color: #0f1e36; font-size: 16px;"><asp:Label ID="lblReservedMemberName" runat="server" /></strong>
                        </p>
                        <p style="font-size: 13.5px; color: #64748b; margin: 0 0 24px 0;">
                            Would you like to print the Reservation Slip for this book?
                        </p>
                        <div style="display: flex; gap: 12px; justify-content: center;">
                            <asp:Button ID="btnPrintReservationSlip" runat="server" Text="Print Slip" OnClick="btnPrintReservationSlip_Click"
                                style="padding: 12px 24px; border-radius: 30px; border: none; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #0f1e36; font-weight: 700; font-size: 13px; cursor: pointer; text-transform: uppercase; transition: all 0.2s;" />
                            <asp:Button ID="btnCloseReservationModal" runat="server" Text="No, Close" OnClick="btnCloseReservationModal_Click"
                                style="padding: 12px 24px; border-radius: 30px; border: 1px solid #cbd5e1; background: #ffffff; color: #64748b; font-weight: 600; font-size: 13px; cursor: pointer; transition: all 0.2s;" />
                        </div>
                    </div>
                </asp:Panel>

            </ContentTemplate>
        </asp:UpdatePanel>

        <script type="text/javascript">
            function checkOverdueStatus() {
                var barcode = "";
                var txtBarcode = document.getElementById('<%= txtReturnBarcode.ClientID %>');
                var txtIssueNo = document.getElementById('<%= txtReturnIssueNo.ClientID %>');

                if (txtBarcode && txtBarcode.value.trim() !== "") {
                    barcode = txtBarcode.value;
                } else if (txtIssueNo && txtIssueNo.value.trim() !== "") {
                    barcode = txtIssueNo.value;
                }

                var statusContainer = document.getElementById('overdueStatusContainer');
                if (!statusContainer) return;

                if (!barcode || barcode.trim() === "") {
                    statusContainer.style.display = 'none';
                    return;
                }

                fetch('ReturnBook.aspx/CheckOverdueStatus', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ barcode: barcode.trim() })
                })
                    .then(response => response.json())
                    .then(data => {
                        var res = data.d;
                        if (res.error) {
                            statusContainer.style.display = 'block';
                            statusContainer.style.backgroundColor = '#f8fafc';
                            statusContainer.style.borderLeft = '4px solid #cbd5e1';
                            statusContainer.style.color = '#475569';
                            statusContainer.innerHTML = '<strong style="display:flex; align-items:center; gap:6px;"><i class="fas fa-info-circle"></i> Info</strong>' + res.error;
                        } else if (res.isOverdue) {
                            statusContainer.style.display = 'block';
                            statusContainer.style.backgroundColor = '#fef2f2';
                            statusContainer.style.borderLeft = '4px solid #f87171';
                            statusContainer.style.color = '#991b1b';
                            statusContainer.innerHTML = '<strong style="display:flex; align-items:center; gap:6px; margin-bottom:4px;"><i class="fas fa-triangle-exclamation"></i> OVERDUE!</strong>This book is <strong>' + res.days + ' days</strong> overdue.<br />Estimated Fine: <strong>PKR ' + res.fine.toFixed(2) + '</strong>';
                        } else {
                            statusContainer.style.display = 'block';
                            statusContainer.style.backgroundColor = '#f0fdf4';
                            statusContainer.style.borderLeft = '4px solid #4ade80';
                            statusContainer.style.color = '#14532d';
                            statusContainer.innerHTML = '<strong style="display:flex; align-items:center; gap:6px; margin-bottom:4px;"><i class="fas fa-circle-check"></i> ON TIME</strong>This book is within the return window. (Due: ' + res.dueDate + ')';
                        }
                    })
                    .catch(err => console.error('Error checking status:', err));
            }

            function printElement(htmlContent) {
                var win = window.open('', '_blank', 'width=800,height=600');
                win.document.write('<html><head><title>Print Slip</title>');
                win.document.write('<style>');
                win.document.write('body { font-family: Arial, sans-serif; padding: 10px; line-height: 1.4; color: #000; }');
                win.document.write('</style></head><body>');
                win.document.write(htmlContent);
                win.document.write('</body></html>');
                win.document.close();
                win.focus();
                setTimeout(function() {
                    win.print();
                    win.close();
                }, 250);
            }
        </script>

    </asp:Content>
