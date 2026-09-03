<%@ Page Title="Payment & Billing Process" Language="C#" MasterPageFile="~/Sports_Management/SiteSports.master" AutoEventWireup="true" CodeFile="PaymentProcess.aspx.cs" Inherits="PaymentProcess" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/css/select2.min.css" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.min.js"></script>

    <style>
        .member-details-card {
            background-color: #f0f7ff;
            border-left: 4px solid var(--info);
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        .member-info-row {
            display: flex;
            gap: 20px;
            margin-bottom: 10px;
        }
        .member-info-item {
            flex: 1;
        }
        .member-info-label {
            font-size: 11px;
            color: var(--gray-500);
            text-transform: uppercase;
            font-weight: 700;
        }
        .member-info-value {
            font-size: 14px;
            color: var(--primary-dark);
            font-weight: 600;
        }
        
        .balance-item-credit {
            background-color: #d1fae5;
            color: #065f46;
            padding: 3px 10px;
            border-radius: 12px;
        }
        .balance-item-debit {
            background-color: #fee2e2;
            color: #991b1b;
            padding: 3px 10px;
            border-radius: 12px;
        }

        /* Tabs */
        .tabs {
            display: flex;
            border-bottom: 2px solid var(--gray-200);
            margin-bottom: 20px;
        }

        .tab-btn {
            padding: 12px 24px;
            font-size: 15px;
            font-weight: 600;
            color: var(--gray-500);
            background: none;
            border: none;
            border-bottom: 2px solid transparent;
            margin-bottom: -2px;
            cursor: pointer;
            transition: all 0.2s;
        }

        .tab-btn:hover { color: var(--primary); }
        .tab-btn.active {
            color: var(--primary);
            border-bottom-color: var(--primary);
        }

        .tab-content { display: none; }
        .tab-content.active { display: block; }

        /* Form Grid */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }

        .full-width { grid-column: 1 / -1; }

        /* Discount Rules UI */
        .rules-container {
            background: var(--gray-50);
            padding: 16px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        .rule-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 0;
            border-bottom: 1px dashed var(--gray-300);
        }
        .rule-item:last-child { border-bottom: none; }
        
        .rule-label { font-weight: 500; color: var(--gray-700); }
        .rule-status {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 600;
        }
        .rule-status.applied { background: #d1fae5; color: #065f46; }
        .rule-status.not-applied { background: #f3f4f6; color: #6b7280; }

        .charge-summary {
            background: #eff6ff;
            padding: 16px;
            border-radius: 8px;
            border: 1px solid #bfdbfe;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 14px;
            color: #1e3a8a;
        }

        .summary-total {
            display: flex;
            justify-content: space-between;
            margin-top: 12px;
            padding-top: 12px;
            border-top: 1px solid #bfdbfe;
            font-size: 18px;
            font-weight: 700;
            color: #1e3a8a;
        }

        /* Modal Background */
        .modal-bg {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }

        .modal-content {
            background: white;
            padding: 24px;
            border-radius: 12px;
            width: 100%;
            max-width: 500px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .modal-title { font-size: 18px; font-weight: 700; color: var(--primary-dark); }
        .close-modal { background: none; border: none; font-size: 20px; cursor: pointer; color: var(--gray-500); }
        
        .action-buttons {
            display: flex;
            gap: 12px;
            margin-top: 24px;
        }
        /* Search Member Section Sizing Override */
        .search-input-lg {
            font-size: 16px !important;
            height: 46px !important;
            padding: 10px 16px !important;
            font-weight: 700 !important;
            border-radius: 6px !important;
            border: 2px solid var(--primary) !important;
            width: 100% !important;
            box-sizing: border-box !important;
        }
        .search-btn-lg {
            height: 46px !important;
            padding: 0 30px !important;
            font-size: 15px !important;
            font-weight: 800 !important;
            border-radius: 6px !important;
            width: auto !important;
            display: inline-block !important;
        }
        .search-form-group {
            width: auto !important;
            max-width: 100% !important;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" Runat="Server">
    <asp:UpdatePanel ID="upPaymentProcess" runat="server">
        <ContentTemplate>
            <asp:HiddenField ID="hfActiveTab" runat="server" Value="payment" />

            <div class="page-header-card" style="display:flex; justify-content:space-between; align-items:center;">
                <div>
                    <h2><i class="fas fa-money-bill-wave" style="margin-right:10px;"></i> Payment & Billing Process <span class="badge">Receive Payments / Generate Charges</span></h2>
                </div>
            </div>

            <!-- Alert Message -->
            <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert" style="display:block; margin-bottom: 20px; padding: 15px; border-radius: 8px; font-weight: bold;"></asp:Label>

            <!-- Search Section -->
            <div class="card">
                <div class="card-header" style="font-size: 15px; font-weight: 700;">SEARCH MEMBER</div>
                <div class="card-body">
                    <div style="display:flex; gap:12px; align-items:flex-end; flex-wrap:wrap;">
                        <div class="search-form-group" style="flex: 1; min-width: 320px; max-width: 550px; margin-bottom:0 !important;">
                            <label style="font-size: 14px !important; font-weight: 800 !important; color: var(--primary-dark) !important; margin-bottom:6px !important; display:block !important; width:100% !important; white-space:nowrap !important;">Member ID / Name</label>
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-input-lg" placeholder="Enter Member ID or Name"></asp:TextBox>
                        </div>
                        <div class="search-form-group" style="flex: 0 0 auto; margin-bottom:0 !important;">
                            <asp:Button ID="btnSearch" runat="server" Text="Search Member" CssClass="btn btn-primary search-btn-lg" OnClick="btnSearch_Click" />
                        </div>
                    </div>

                    <asp:Panel ID="pnlSearchResults" runat="server" Visible="false" style="margin-top: 20px;">
                        <div class="form-group" style="max-width: 550px;">
                            <label style="color:var(--primary) !important; font-weight:700 !important; font-size: 14px !important;">Select Member / Dependent <span style="color:red">*</span></label>
                            <asp:DropDownList ID="ddlMemberNames" runat="server" CssClass="form-control select2" style="font-size: 15px !important; height: 42px !important;" AutoPostBack="true" OnSelectedIndexChanged="ddlMemberNames_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>
                    </asp:Panel>
                </div>
            </div>

            <!-- Member Info Section -->
            <asp:Panel ID="pnlMemberArea" runat="server" Visible="false">
                <asp:HiddenField ID="hfMemberID" runat="server" />
                
                <div class="member-details-card">
                    <h4 style="margin-bottom:15px; color:var(--primary); font-weight:700;"><i class="fas fa-user-circle"></i> Member Information</h4>
                    <div class="member-info-row">
                        <div class="member-info-item">
                            <div class="member-info-label">Membership No</div>
                            <div class="member-info-value"><asp:Label ID="lblMemberNo" runat="server" Text="---"></asp:Label></div>
                        </div>
                        <div class="member-info-item">
                            <div class="member-info-label">Full Name</div>
                            <div class="member-info-value"><asp:Label ID="lblFullName" runat="server" Text="---"></asp:Label></div>
                        </div>
                        <div class="member-info-item">
                            <div class="member-info-label">Status</div>
                            <div class="member-info-value"><asp:Label ID="lblStatus" runat="server" Text="---"></asp:Label></div>
                        </div>
                        <div class="member-info-item">
                            <div class="member-info-label">Ledger Balance</div>
                            <div class="member-info-value" id="divBalance" runat="server">
                                <asp:Label ID="lblBalance" runat="server" Text="PKR 0.00"></asp:Label>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Tabs -->
                <div class="tabs">
                    <button type="button" id="btn-tab-payment" class="tab-btn active" onclick="switchTab('payment')">Receive Payment</button>
                    <button type="button" id="btn-tab-charge" class="tab-btn" onclick="switchTab('charge')">Charge Subscriptions</button>
                </div>

                <div class="card">
                    <div class="card-body">
                        
                        <!-- PAYMENT TAB -->
                        <div id="tab-payment" class="tab-content active">
                            <h3 style="font-size: 16px; margin-bottom: 20px; color: var(--primary-dark);">Receive Payment</h3>
                            
                            <div class="form-grid">
                                <div class="form-group">
                                    <label>Amount Received (PKR)</label>
                                    <asp:TextBox ID="txtAmountPaid" runat="server" CssClass="form-control" type="number" step="0.01"></asp:TextBox>
                                </div>
                                <div class="form-group">
                                    <label>Payment Mode</label>
                                    <asp:DropDownList ID="ddlPaymentMode" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlPaymentMode_SelectedIndexChanged">
                                        <asp:ListItem Text="Cash" Value="Cash"></asp:ListItem>
                                        <asp:ListItem Text="Credit Card" Value="Credit Card"></asp:ListItem>
                                        <asp:ListItem Text="Online Payment" Value="Online Payment"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>

                                <div class="form-group" id="divBankCard" runat="server" visible="false">
                                    <label>Bank</label>
                                    <asp:DropDownList ID="ddlBankCard" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                                
                                <div class="form-group" id="divCardNoPayment" runat="server" visible="false">
                                    <label>Card Number (Last 4 Digits)</label>
                                    <asp:TextBox ID="txtPaymentCardNo" runat="server" CssClass="form-control" MaxLength="4"></asp:TextBox>
                                </div>

                                <div class="form-group" id="divRefID" runat="server" visible="false">
                                    <label>Reference ID</label>
                                    <asp:TextBox ID="txtReferenceID" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            
                            <div style="margin-top: 24px;">
                                <asp:Button ID="btnReceivePayment" runat="server" Text="Receive Payment" CssClass="btn btn-primary" OnClick="btnReceivePayment_Click" OnClientClick="return confirm('Confirm payment receipt?');" />
                            </div>
                        </div>

                        <!-- CHARGE TAB -->
                        <div id="tab-charge" class="tab-content">
                            <h3 style="font-size: 16px; margin-bottom: 20px; color: var(--primary-dark);">Active Subscriptions</h3>
                            
                            <asp:GridView ID="gvActiveSubscriptions" runat="server" AutoGenerateColumns="False" 
                                CssClass="grid-view" EmptyDataText="No active subscriptions found for this member."
                                OnRowCommand="gvActiveSubscriptions_RowCommand">
                                <Columns>
                                    <%-- 1. SPORT --%>
                                    <asp:BoundField DataField="SportName" HeaderText="Sport" />

                                    <%-- 2. MEMBER / DEPENDENT --%>
                                    <asp:TemplateField HeaderText="Member / Dependent">
                                        <ItemTemplate>
                                            <%# string.IsNullOrEmpty(Eval("DependentName").ToString()) ? "Self" : Eval("DependentName") + " (" + Eval("DependentRelation") + ")" %>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <%-- 3. BASE FEE --%>
                                    <asp:TemplateField HeaderText="Base Fee">
                                        <ItemTemplate>
                                            <span style="font-weight: 600; color: #374151;">
                                                <%# Eval("CalcBaseFee") != DBNull.Value ? Convert.ToDecimal(Eval("CalcBaseFee")).ToString("N2") + " PKR" : "0.00 PKR" %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <%-- 4. GST --%>
                                    <asp:TemplateField HeaderText="GST">
                                        <ItemTemplate>
                                            <span style="font-weight: 600; color: #d97706;">
                                                <%# Eval("CalcGSTAmount") != DBNull.Value ? Convert.ToDecimal(Eval("CalcGSTAmount")).ToString("N2") + " PKR" : "0.00 PKR" %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <%-- 5. TOTAL AMOUNT --%>
                                    <asp:TemplateField HeaderText="Total Amount">
                                        <ItemTemplate>
                                            <span style="font-weight: 700; color: var(--primary-dark);">
                                                <%# Eval("CalcNetFee") != DBNull.Value ? Convert.ToDecimal(Eval("CalcNetFee")).ToString("N2") + " PKR (" + Eval("SubscriptionType") + ")" : "0.00 PKR" %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <%-- 6. SUBSCRIPTION DATE --%>
                                    <asp:TemplateField HeaderText="Subscription Date">
                                        <ItemTemplate>
                                            <%# Eval("StartDate") != DBNull.Value ? Convert.ToDateTime(Eval("StartDate")).ToString("dd MMM yyyy") : "---" %>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <%-- 7. ACTION --%>
                                    <asp:TemplateField HeaderText="Action">
                                        <ItemTemplate>
                                            <asp:Button ID="btnGenerateCharge" runat="server" 
                                                Text='<%# Eval("LastBilledDate") == DBNull.Value ? "Generate Charge" : "Charged" %>' 
                                                CssClass='<%# Eval("LastBilledDate") == DBNull.Value ? "btn btn-primary" : "btn" %>' 
                                                style='<%# Eval("LastBilledDate") == DBNull.Value ? "padding: 6px 14px; font-size: 12px; font-weight:700;" : "padding: 6px 14px; font-size: 12px; background: var(--gray-300); color: var(--gray-600); cursor: not-allowed;" %>'
                                                CommandName="GenerateCharge" 
                                                CommandArgument='<%# Eval("MemberSubID") %>' 
                                                Enabled='<%# Eval("LastBilledDate") == DBNull.Value %>' 
                                                OnClientClick="return confirm('Generate charge for this subscription to ledger?');" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <!-- Modal for Charging -->
            <asp:Panel ID="pnlChargeModal" runat="server" CssClass="modal-bg" style="display: none;">
                <div class="modal-content">
                    <div class="modal-header">
                        <h3 class="modal-title">Confirm Subscription Charge</h3>
                        <asp:Button ID="btnCloseModal" runat="server" Text="&times;" CssClass="close-modal" OnClick="btnCloseModal_Click" />
                    </div>

                    <div style="margin-bottom: 16px;">
                        <strong style="color: var(--primary-dark); font-size: 15px;"><asp:Literal ID="litChargePackageName" runat="server"></asp:Literal></strong><br />
                        <span style="color: var(--gray-500); font-size: 13px;"><asp:Literal ID="litChargeMemberName" runat="server"></asp:Literal></span>
                    </div>

                    <div class="form-group" style="margin-bottom:12px;">
                        <label style="color:var(--primary-dark); font-weight:700;">Select Package <span style="color:red">*</span></label>
                        <asp:DropDownList ID="ddlChargePackage" runat="server" CssClass="form-control" style="font-weight:600;" AutoPostBack="true" OnSelectedIndexChanged="ddlChargePackage_SelectedIndexChanged">
                        </asp:DropDownList>
                    </div>

                    <div class="form-group">
                        <label>Billing Period</label>
                        <asp:TextBox ID="txtBillingPeriod" runat="server" CssClass="form-control" placeholder="e.g. August 2026"></asp:TextBox>
                    </div>

                    <div class="rules-container">
                        <p style="font-size: 12px; font-weight: 600; color: var(--gray-500); margin-bottom: 12px; text-transform: uppercase;">Discount Rules Evaluated</p>
                        <asp:Repeater ID="rptRules" runat="server">
                            <ItemTemplate>
                                <div class="rule-item">
                                    <span class="rule-label"><%# Eval("RuleName") %></span>
                                    <span class='rule-status <%# Convert.ToBoolean(Eval("IsApplied")) ? "applied" : "not-applied" %>'>
                                        <%# Convert.ToBoolean(Eval("IsApplied")) ? "APPLIED" : "NOT APPLIED" %>
                                    </span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <div class="charge-summary">
                        <div class="summary-row">
                            <span>Base Fee</span>
                            <span><asp:Literal ID="litBaseFee" runat="server"></asp:Literal></span>
                        </div>
                        <div class="summary-row">
                            <span>Discount Amount</span>
                            <span style="color: #ef4444;">- <asp:Literal ID="litDiscount" runat="server"></asp:Literal></span>
                        </div>
                        <div class="summary-row">
                            <span>GST (<asp:Literal ID="litGSTPercent" runat="server"></asp:Literal>%)</span>
                            <span><asp:Literal ID="litGSTAmount" runat="server"></asp:Literal></span>
                        </div>
                        <div class="summary-total">
                            <span>Net Charge to Ledger</span>
                            <span><asp:Literal ID="litNetFee" runat="server"></asp:Literal></span>
                        </div>
                    </div>

                    <asp:HiddenField ID="hfChargeMemberSubID" runat="server" />
                    <asp:HiddenField ID="hfCalculatedNetFee" runat="server" />

                    <div class="action-buttons">
                        <asp:Button ID="btnConfirmCharge" runat="server" Text="Confirm Charge" CssClass="btn btn-primary" style="flex: 1;" OnClick="btnConfirmCharge_Click" />
                        <asp:Button ID="btnCancelCharge" runat="server" Text="Cancel" CssClass="btn" style="background: var(--gray-200); color: var(--gray-700); flex: 1;" OnClick="btnCloseModal_Click" />
                    </div>
                </div>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

    <script>
        $(document).ready(function () {
            initSelect2();
            restoreActiveTab();
            
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            if (prm != null) {
                prm.add_endRequest(function (sender, e) {
                    initSelect2();
                    restoreActiveTab();
                });
            }
        });

        function initSelect2() {
            $('.select2').select2({
                width: '100%'
            });
        }

        function switchTab(tabId) {
            $('#<%= hfActiveTab.ClientID %>').val(tabId);
            restoreActiveTab();
        }

        function restoreActiveTab() {
            var activeTab = $('#<%= hfActiveTab.ClientID %>').val() || 'payment';
            $('.tab-btn').removeClass('active');
            $('.tab-content').removeClass('active');
            $('#btn-tab-' + activeTab).addClass('active');
            $('#tab-' + activeTab).addClass('active');
        }
    </script>
</asp:Content>
