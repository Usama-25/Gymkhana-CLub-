<%@ Page Title="Member Subscriptions" Language="C#" MasterPageFile="~/Sports_Management/SiteSports.master" AutoEventWireup="true" CodeFile="MemberSubscriptions.aspx.cs" Inherits="MemberSubscriptions" %>
<%@ Register Src="~/Sports_Management/MemberSubscriptionInfo.ascx" TagPrefix="uc" TagName="MemberSubInfo" %>



<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
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
        .subscription-card {
            background: white;
            border: 1px solid var(--gray-200);
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            transition: all 0.3s ease;
            position: relative;
            border-left: 4px solid var(--secondary);
        }
        .subscription-card:hover {
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            transform: translateY(-2px);
        }
        .sub-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
            border-bottom: 1px solid var(--gray-100);
            padding-bottom: 10px;
        }
        .sub-title {
            font-size: 16px;
            font-weight: 700;
            color: var(--primary-dark);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .sub-sport {
            font-size: 11px;
            background: var(--primary-light);
            color: var(--primary);
            padding: 3px 8px;
            border-radius: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }
        .sub-price {
            font-size: 16px;
            font-weight: 700;
            color: var(--warning);
        }
        .sub-details {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-top: 10px;
        }
        .sub-detail-item {
            flex: 1;
            min-width: 120px;
        }
        .sub-label {
            font-size: 10px;
            color: var(--gray-500);
            text-transform: uppercase;
            font-weight: 600;
            margin-bottom: 2px;
        }
        .sub-value {
            font-size: 13px;
            color: var(--gray-800);
            font-weight: 500;
        }
        .sub-status-badge {
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
        }
        .status-active {
            background-color: #d1fae5;
            color: #065f46;
        }
        .status-expired {
            background-color: #fee2e2;
            color: #991b1b;
        }
        
        /* Premium custom grid styling */
        .custom-grid {
            width: 100%; 
            border-collapse: collapse; 
            margin-top: 10px; 
            background-color: #ffffff; 
            border-radius: 8px; 
            overflow: hidden; 
            box-shadow: 0 4px 6px rgba(0,0,0,0.05); 
            border: 1px solid #e5e7eb;
        }
        .custom-grid th {
            padding: 12px 16px;
            font-size: 13px; 
            text-transform: uppercase; 
            letter-spacing: 0.05em;
            text-align: left;
        }
        .custom-grid td {
            padding: 12px 16px;
            font-size: 14px; 
            color: #374151; 
            border-bottom: 1px solid #f3f4f6;
        }
        
        /* Modal Background */
        .modal-bg {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.5);
            z-index: 2000;
            align-items: center;
            justify-content: center;
        }

        .modal-content {
            background: white;
            padding: 24px;
            border-radius: 12px;
            width: 100%;
            max-width: 600px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            max-height: 90vh;
            overflow-y: auto;
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            border-bottom: 1px solid var(--gray-200);
            padding-bottom: 10px;
        }

        .modal-title { font-size: 18px; font-weight: 700; color: var(--primary-dark); }
        .close-modal { background: none; border: none; font-size: 20px; cursor: pointer; color: var(--gray-500); }

        /* Modal Tabs */
        .modal-tabs {
            display: flex;
            border-bottom: 2px solid var(--gray-200);
            margin-bottom: 20px;
        }

        .modal-tab-btn {
            padding: 10px 20px;
            font-size: 14px;
            font-weight: 600;
            color: var(--gray-500);
            background: none;
            border: none;
            border-bottom: 2px solid transparent;
            margin-bottom: -2px;
            cursor: pointer;
            transition: all 0.2s;
        }

        .modal-tab-btn:hover { color: var(--primary); }
        .modal-tab-btn.active {
            color: var(--primary);
            border-bottom-color: var(--primary);
        }

        .modal-tab-content { display: none; }
        .modal-tab-content.active { display: block; }

        /* Modal Info */
        .modal-member-info {
            background-color: #f0f7ff;
            border-left: 4px solid var(--info);
            padding: 12px;
            border-radius: 4px;
            margin-bottom: 15px;
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
        }

        .modal-info-label {
            font-size: 10px;
            color: var(--gray-500);
            text-transform: uppercase;
            font-weight: 700;
        }

        .modal-info-value {
            font-size: 13px;
            color: var(--primary-dark);
            font-weight: 600;
        }

        /* Form Grid */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
        }
        .full-width { grid-column: 1 / -1; }

        /* Rules & Summary */
        .rules-container {
            background: var(--gray-50);
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 15px;
        }
        .rule-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 6px 0;
            border-bottom: 1px dashed var(--gray-300);
        }
        .rule-item:last-child { border-bottom: none; }
        .rule-label { font-weight: 500; color: var(--gray-700); font-size: 12px; }
        .rule-status {
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
        }
        .rule-status.applied { background: #d1fae5; color: #065f46; }
        .rule-status.not-applied { background: #f3f4f6; color: #6b7280; }

        .charge-summary {
            background: #eff6ff;
            padding: 12px;
            border-radius: 8px;
            border: 1px solid #bfdbfe;
        }
        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 6px;
            font-size: 13px;
            color: #1e3a8a;
        }
        .summary-total {
            display: flex;
            justify-content: space-between;
            margin-top: 10px;
            padding-top: 10px;
            border-top: 1px solid #bfdbfe;
            font-size: 16px;
            font-weight: 700;
            color: #1e3a8a;
        }
        .balance-item-credit {
            background-color: #d1fae5;
            color: #065f46;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 12px;
            display: inline-block;
        }
        .balance-item-debit {
            background-color: #fee2e2;
            color: #991b1b;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 12px;
            display: inline-block;
        }
    </style>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    
    <script type="text/javascript">
        $(document).ready(function() {
            // Initialize Select2 on the Packages dropdown
            $('#<%= ddlPackages.ClientID %>').select2({
                placeholder: 'Search package...',
                allowClear: true,
                width: '100%'
            });

            onTopSelectionChange();
        });

        function onTopSelectionChange() {
            var ddlType = document.getElementById('<%= ddlTopSubscriptionType.ClientID %>');
            var subType = ddlType ? ddlType.value : '0';
            var isSaveMode = (subType === 'Monthly' || subType === 'Continuous');

            var buttons = document.querySelectorAll('.btn-select-row');
            buttons.forEach(function(btn) {
                if (isSaveMode) {
                    btn.value = 'Save';
                    btn.style.backgroundColor = '#10b981';
                    btn.style.boxShadow = '0 2px 4px rgba(16,185,129,0.3)';
                } else {
                    btn.value = 'Select';
                    btn.style.backgroundColor = '#2563eb';
                    btn.style.boxShadow = 'none';
                }
            });
        }

        function onRowSelectOrSaveClick(btn, e) {
            var ddlType = document.getElementById('<%= ddlTopSubscriptionType.ClientID %>');
            var subType = ddlType ? ddlType.value : '0';

            if (subType === 'Monthly' || subType === 'Continuous') {
                var ddlSports = document.getElementById('<%= ddlSports.ClientID %>');
                if (!ddlSports || ddlSports.selectedIndex <= 0) {
                    alert("Please select a Sport from the 'Select Sport' dropdown above first.");
                    if (ddlSports) ddlSports.focus();
                    return false;
                }
                return true;
            }
            return true;
        }

        function onAssignSubscriptionClick() {
            var ddlPkg = document.getElementById('<%= ddlPackages.ClientID %>');
            var txtStart = document.getElementById('<%= txtStartDate.ClientID %>');

            if (!ddlPkg || ddlPkg.value === '0' || !txtStart || !txtStart.value.trim()) {
                alert("Please select a package and start date.");
                return false;
            }

            var pkgName = ddlPkg.options[ddlPkg.selectedIndex].text;
            var memberNo = document.getElementById('<%= lblMemberNo.ClientID %>') ? document.getElementById('<%= lblMemberNo.ClientID %>').innerText : '';
            var memberName = document.getElementById('<%= lblFullName.ClientID %>') ? document.getElementById('<%= lblFullName.ClientID %>').innerText : '';

            var hfSource = document.getElementById('<%= hfModalMemberSubSource.ClientID %>');
            if (hfSource) hfSource.value = 'formAssign';

            var summaryElem = document.getElementById('lblMemberSubSummary');
            if (summaryElem) {
                summaryElem.innerText = memberNo + ' - ' + memberName + ' | ' + pkgName;
            }

            var modal = document.getElementById('pnlMemberSubManualModal');
            if (modal) {
                modal.style.display = 'flex';
                var txt = document.getElementById('<%= txtMemberSubManualCardNo.ClientID %>');
                if (txt) {
                    txt.value = '';
                    setTimeout(function () { txt.focus(); }, 100);
                }
            }
            return false;
        }

        function closeMemberSubManualModal() {
            var modal = document.getElementById('pnlMemberSubManualModal');
            if (modal) {
                modal.style.display = 'none';
            }
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Header -->
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
        <div>
            <h4 style="margin:0; color:var(--primary-dark); font-weight:700;">
                <i class="fas fa-users-cog" style="color:var(--primary); margin-right:8px;"></i>Member Subscriptions
                <span class="badge badge-info" style="font-size:11px; margin-left:8px;">Assign / View Subscriptions</span>
            </h4>
        </div>
        <span><asp:Button ID="btnRunMaintenance" runat="server" Text="Run Daily Maintenance" CssClass="btn btn-warning" OnClick="btnRunMaintenance_Click" OnClientClick="return confirm('This will process all auto-expiries and continuous billing. Proceed?');" /></span>
    </div>

    <!-- Alert Message -->
    <asp:Label ID="lblMessage" runat="server" Visible="false" style="display:none; margin-bottom:12px; padding:8px 14px; border-radius:6px; font-size:12px; font-weight:600;"></asp:Label>

    <!-- Search Section -->
    <asp:Panel ID="pnlSearchCard" runat="server" CssClass="card" DefaultButton="btnSearch">
        <div class="card-header">Search Member</div>
        <div class="card-body">
            <div style="display:flex; gap:10px; align-items:flex-end;">
                <div class="form-group" style="margin-bottom:0; flex:1; max-width:400px;">
                    <label>Member ID / Name</label>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Enter MEM-001 or Name..."></asp:TextBox>
                </div>
                <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="btnSearch_Click" />
            </div>
            <asp:Panel ID="pnlSearchResults" runat="server" Visible="false" style="margin-top: 15px;">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px; flex-wrap:wrap; gap:12px;">
                    <h5 style="color:var(--primary); font-weight:700; margin:0;">Select Member / Dependent <span style="color:red">*</span></h5>
                    <div style="display:flex; align-items:center; gap:12px; flex-wrap:wrap;">
                        <div style="display:flex; align-items:center; gap:8px;">
                            <label style="font-weight:700; margin:0; font-size:13px; color:var(--primary-dark);">Select Department / Sport:</label>
                            <asp:DropDownList ID="ddlSports" runat="server" CssClass="form-control" style="width:190px; padding:4px 8px; font-weight:600;" AutoPostBack="true" OnSelectedIndexChanged="ddlSports_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>
                        <div style="display:flex; align-items:center; gap:8px;">
                            <label style="font-weight:700; margin:0; font-size:13px; color:var(--primary-dark);">Sub Dept:</label>
                            <asp:DropDownList ID="ddlSubDept" runat="server" CssClass="form-control" style="width:170px; padding:4px 8px; font-weight:600;" AutoPostBack="true" OnSelectedIndexChanged="ddlSubDept_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>
                        <div style="display:flex; align-items:center; gap:8px;">
                            <label style="font-weight:700; margin:0; font-size:13px; color:var(--primary-dark);">Subscription Type:</label>
                            <asp:DropDownList ID="ddlTopSubscriptionType" runat="server" CssClass="form-control" style="width:160px; padding:4px 8px; font-weight:600;" onchange="onTopSelectionChange()">
                                <asp:ListItem Text="-- Select Type --" Value="0"></asp:ListItem>
                                <asp:ListItem Text="Monthly" Value="Monthly"></asp:ListItem>
                                <asp:ListItem Text="Continuous" Value="Continuous"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>
                <div class="table-responsive">
                    <asp:GridView ID="gvMemberResults" runat="server" AutoGenerateColumns="False" OnRowCommand="gvMemberResults_RowCommand" OnRowDataBound="gvMemberResults_RowDataBound"
                        GridLines="None" 
                        CssClass="custom-grid">
                        
                        <HeaderStyle BackColor="#1e3a8a" ForeColor="#ffffff" Font-Bold="True" Height="36px" Font-Size="12px" />
                        
                        <RowStyle Height="34px" Font-Size="12px" />
                        
                        <AlternatingRowStyle BackColor="#f9fafb" />
                        
                        <Columns>
                            <asp:TemplateField HeaderText="Member No">
                                <ItemTemplate>
                                    <span style="font-weight: 600; color: #1e3a8a;"><%# Eval("MembershipNo") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Name">
                                <ItemTemplate>
                                    <span style="font-weight: 500;"><%# Eval("FullName") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Relationship">
                                <ItemTemplate>
                                    <span style='<%# GetRelationshipBadgeStyle(Eval("Relationship").ToString()) %>'>
                                        <%# Eval("Relationship") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Age">
                                <ItemTemplate>
                                    <span style="font-weight: 600; color: #4b5563;"><%# Eval("Age") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Rate Policy">
                                <ItemTemplate>
                                    <span style="padding: 2px 8px; border-radius: 10px; font-size: 11px; font-weight: 700; background-color: #f59e0b; color: white;">
                                        <%# Eval("RatePolicy") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Account Status">
                                <ItemTemplate>
                                    <span style='<%# GetAccountStatusBadgeStyle(Eval("Status").ToString()) %>'>
                                        <%# Eval("Status") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Date Period">
                                <ItemTemplate>
                                    <%# GetDatePeriodHtml(Eval("MemberID"), Eval("Relationship"), Eval("MembershipNo")) %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Month Status" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="120px">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnOpen12MonthModal" runat="server" CommandName="Open12MonthModal" 
                                        CommandArgument='<%# Container.DataItemIndex %>'
                                        style='<%# IsCurrentMonthActive(Eval("MemberID"), Eval("Relationship"), Eval("MembershipNo")) ? "background-color: #10b981; color: #ffffff; padding: 5px 12px; border-radius: 6px; font-weight: 700; font-size: 12px; text-decoration: none; display: inline-block; box-shadow: 0 2px 4px rgba(16,185,129,0.3); cursor: pointer;" : "background-color: #ef4444; color: #ffffff; padding: 5px 12px; border-radius: 6px; font-weight: 700; font-size: 12px; text-decoration: none; display: inline-block; box-shadow: 0 2px 4px rgba(239,68,68,0.3); cursor: pointer;" %>'
                                        onmouseover='<%# IsCurrentMonthActive(Eval("MemberID"), Eval("Relationship"), Eval("MembershipNo")) ? "this.style.backgroundColor=\"#059669\"" : "this.style.backgroundColor=\"#dc2626\"" %>'
                                        onmouseout='<%# IsCurrentMonthActive(Eval("MemberID"), Eval("Relationship"), Eval("MembershipNo")) ? "this.style.backgroundColor=\"#10b981\"" : "this.style.backgroundColor=\"#ef4444\"" %>'
                                        title="Click to view 12-Month Status Breakdown">
                                        <i class="fas fa-calendar-alt" style="margin-right:4px;"></i> <%# GetCurrentMonthStatusText(Eval("MemberID"), Eval("Relationship"), Eval("MembershipNo")) %>
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Manual Register / Card No" ItemStyle-Width="160px">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtRowManualCardNo" runat="server" CssClass="form-control"
                                        Text='<%# Eval("ManualCardNo") != DBNull.Value ? Eval("ManualCardNo").ToString() : "" %>'
                                        placeholder="e.g. 1024 or RC-45"
                                        style="font-size: 12px; padding: 3px 8px; border: 1px solid #cbd5e1; border-radius: 4px; width: 140px; height: 28px; font-weight: 600; text-transform: uppercase;"
                                        onkeydown="if(event.keyCode===13){event.preventDefault();var btn=this.closest('tr').querySelector('.btn-select-row');if(btn)btn.click();}"></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <asp:Literal ID="litActions" runat="server" Text='<%# GetActionsHtml(Eval("MemberID"), Eval("Relationship"), Eval("MembershipNo")) %>'></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField ItemStyle-HorizontalAlign="Center" ItemStyle-Width="80px">
                                <ItemTemplate>
                                    <asp:Button ID="btnSelect" runat="server" CommandName="SelectMember" 
                                        CommandArgument='<%# Container.DataItemIndex + "|" + Eval("MemberID") + "|" + Eval("MembershipNo") + "|" + Eval("FullName") + "|" + Eval("Status") + "|" + Eval("ContactNo") + "|" + Eval("Relationship") %>' 
                                        data-arg='<%# Container.DataItemIndex + "|" + Eval("MemberID") + "|" + Eval("MembershipNo") + "|" + Eval("FullName") + "|" + Eval("Status") + "|" + Eval("ContactNo") + "|" + Eval("Relationship") %>'
                                        Text="Select" 
                                        CssClass="btn-select-row"
                                        OnClientClick="return onRowSelectOrSaveClick(this, event);"
                                        style="background-color: #2563eb; color: #ffffff; border: none; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; cursor: pointer; transition: background-color 0.2s;" />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField ItemStyle-HorizontalAlign="Center" ItemStyle-Width="120px" HeaderText="Assign RFID">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnOpenRFIDModal" runat="server" CommandName="OpenRFIDModal" 
                                        CommandArgument='<%# Container.DataItemIndex %>'
                                        style='<%# Eval("IsRFIDActive") != DBNull.Value && Convert.ToInt32(Eval("IsRFIDActive")) == 1 ? "background-color: #10b981; color: #ffffff; border: none; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; cursor: pointer; text-decoration:none; display:inline-block; box-shadow: 0 2px 4px rgba(16,185,129,0.2);" : "background-color: #3b82f6; color: #ffffff; border: none; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; cursor: pointer; text-decoration:none; display:inline-block; box-shadow: 0 2px 4px rgba(59,130,246,0.2);" %>'
                                        onmouseover='<%# Eval("IsRFIDActive") != DBNull.Value && Convert.ToInt32(Eval("IsRFIDActive")) == 1 ? "this.style.backgroundColor=\"#059669\"" : "this.style.backgroundColor=\"#2563eb\"" %>' 
                                        onmouseout='<%# Eval("IsRFIDActive") != DBNull.Value && Convert.ToInt32(Eval("IsRFIDActive")) == 1 ? "this.style.backgroundColor=\"#10b981\"" : "this.style.backgroundColor=\"#3b82f6\"" %>'>
                                        <i class="fas fa-id-card" style="margin-right:4px;"></i> <%# Eval("IsRFIDActive") != DBNull.Value && Convert.ToInt32(Eval("IsRFIDActive")) == 1 ? "Active (" + Eval("RFIDNumber") + ")" : "Assign RFID" %>
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </asp:Panel>
        </div>
    </asp:Panel>

    <%-- Active Subscriptions Summary (Commented Out) --%>
    <div style="display: none;">
        <uc:MemberSubInfo ID="ucMemberSubInfo" runat="server" />
    </div>

    <%-- Member Information Card (Commented Out) --%>
    <asp:Panel ID="pnlMemberArea" runat="server" Visible="false" style="display: none;">
        
        <!-- Member Details -->
        <div class="member-details-card">
            <h4 style="margin-bottom:15px; color:var(--primary); font-weight:700;"><i class="fas fa-user-circle"></i> Member Information</h4>
            <div class="member-info-row">
                <div class="member-info-item">
                    <div class="member-info-label">Member No</div>
                    <div class="member-info-value"><asp:Label ID="lblMemberNo" runat="server"></asp:Label></div>
                    <asp:HiddenField ID="hfMemberID" runat="server" />
                    <asp:HiddenField ID="hfDependentMemberNo" runat="server" />
                    <asp:HiddenField ID="hfDependentName" runat="server" />
                    <asp:HiddenField ID="hfDependentRelation" runat="server" />
                </div>
                <div class="member-info-item">
                    <div class="member-info-label">Full Name</div>
                    <div class="member-info-value"><asp:Label ID="lblFullName" runat="server"></asp:Label></div>
                </div>
                <div class="member-info-item">
                    <div class="member-info-label">Contact</div>
                    <div class="member-info-value"><asp:Label ID="lblContact" runat="server"></asp:Label></div>
                </div>
                <div class="member-info-item">
                    <div class="member-info-label">Age</div>
                    <div class="member-info-value"><asp:Label ID="lblAge" runat="server"></asp:Label></div>
                </div>
                <div class="member-info-item">
                    <div class="member-info-label">Status</div>
                    <div class="member-info-value"><asp:Label ID="lblStatus" runat="server"></asp:Label></div>
                </div>
                <div class="member-info-item">
                    <div class="member-info-label">Relationship</div>
                    <div class="member-info-value">
                        <asp:Label ID="lblRelationship" runat="server" style="padding: 3px 10px; border-radius: 12px; font-size: 12px; font-weight: 700;"></asp:Label>
                    </div>
                </div>
                <div class="member-info-item">
                    <div class="member-info-label">Rate Policy</div>
                    <div class="member-info-value">
                        <asp:Label ID="lblRatePolicy" runat="server" style="padding: 3px 10px; border-radius: 12px; font-size: 12px; font-weight: 700; background-color: #f59e0b; color: white;"></asp:Label>
                    </div>
                </div>
            </div>
        </div>

        <div style="display:flex; gap:20px; flex-wrap:wrap;">
            
            <!-- Assign New Subscription (Hidden) -->
            <div style="display: none;">
                <div class="card" style="flex:1; min-width:300px;">
                    <div class="card-header">Assign New Subscription</div>
                    <div class="card-body">
                        <div class="form-group">
                            <label>Select Subscription Package</label>
                            <asp:DropDownList ID="ddlPackages" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlPackages_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>
                        
                        <%-- Select Locker (Optional) & Locker Fee (Hidden) --%>
                        <div style="display: none;">
                            <div class="form-group" style="display:flex; gap:10px;">
                                <div style="flex:2;">
                                    <label>Select Locker (Optional)</label>
                                    <asp:DropDownList ID="ddlLocker" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlLocker_SelectedIndexChanged">
                                    </asp:DropDownList>
                                </div>
                                <div style="flex:1;">
                                    <label>Locker Fee</label>
                                    <asp:TextBox ID="txtLockerFee" runat="server" CssClass="form-control" ReadOnly="true" style="background:var(--gray-200);" Text="0"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label>Start Date</label>
                            <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control" TextMode="Date" AutoPostBack="true" OnTextChanged="txtStartDate_TextChanged"></asp:TextBox>
                        </div>
                        
                        <div class="form-group">
                            <label>End Date (Optional for Continuous)</label>
                            <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>

                        <div style="margin-top:20px;">
                            <asp:Button ID="btnAssign" runat="server" Text="Assign Subscription" CssClass="btn btn-primary" OnClientClick="return onAssignSubscriptionClick();" OnClick="btnAssign_Click" />
                        </div>
                    </div>
                </div>
            </div>
            <!-- Assign RFID Card -->
            <div class="card" style="flex:1; min-width:300px;">
                <div class="card-header">Manage RFID Card</div>
                <div class="card-body">
                    <div class="form-group">
                        <label>Current RFID Status</label>
                        <div>
                            <asp:Label ID="lblRFIDStatus" runat="server" Font-Bold="true"></asp:Label>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Scan/Enter RFID Card</label>
                        <asp:TextBox ID="txtAssignRFID" runat="server" CssClass="form-control" placeholder="Scan new card here..."></asp:TextBox>
                    </div>
                    <div style="margin-top:20px; display:flex; gap:10px;">
                        <asp:Button ID="btnAssignRFID" runat="server" Text="Assign & Activate" CssClass="btn btn-primary" OnClick="btnAssignRFID_Click" />
                        <asp:Button ID="btnDeactivateRFID" runat="server" Text="Deactivate" CssClass="btn" style="background-color: var(--danger); color: white;" OnClick="btnDeactivateRFID_Click" />
                    </div>
                </div>
            </div>

            <!-- Hidden elements for Action Triggering -->
            <asp:HiddenField ID="hfActionCommand" runat="server" />
            <asp:HiddenField ID="hfActionArgument" runat="server" />
            <asp:Button ID="btnTriggerAction" runat="server" Style="display: none;" OnClick="btnTriggerAction_Click" />

            <script type="text/javascript">
                function confirmStop(subId) {
                    if (confirm("Are you sure you want to stop this subscription?")) {
                        document.getElementById('<%= hfActionCommand.ClientID %>').value = "StopSub";
                        document.getElementById('<%= hfActionArgument.ClientID %>').value = subId;
                        document.getElementById('<%= btnTriggerAction.ClientID %>').click();
                    }
                }
                function confirmToggle(subId, currentStatus) {
                    var msg = currentStatus === "Active" ? "Stop this continuous subscription?" : "Resume this continuous subscription? It will auto-renew and post an entry to the ledger.";
                    if (confirm(msg)) {
                        document.getElementById('<%= hfActionCommand.ClientID %>').value = "ToggleSub";
                        document.getElementById('<%= hfActionArgument.ClientID %>').value = subId + "|" + (currentStatus === "Active" ? "True" : "False");
                        document.getElementById('<%= btnTriggerAction.ClientID %>').click();
                    }
                }
                function confirmToggleMonth(subId, currentStatus, subType) {
                    var monthName = "<%= DateTime.Now.ToString("MMMM") %>";
                    var msg = currentStatus === "Active" 
                        ? "Deactivate subscription for " + monthName + "?" 
                        : "Reactivate subscription for " + monthName + "?";
                    if (confirm(msg)) {
                        if (subType === "Continuous") {
                            confirmToggle(subId, currentStatus);
                        } else {
                            document.getElementById('<%= hfActionCommand.ClientID %>').value = "ToggleMonthlySub";
                            document.getElementById('<%= hfActionArgument.ClientID %>').value = subId + "|" + (currentStatus === "Active" ? "True" : "False");
                            document.getElementById('<%= btnTriggerAction.ClientID %>').click();
                        }
                    }
                }
                function switchModalTab(tabId) {
                    $('.modal-tab-btn').removeClass('active');
                    $('.modal-tab-content').removeClass('active');
                    
                    if (tabId === 'payment') {
                        $('#btnTabModalPayment').addClass('active');
                        $('#tab-modal-payment').addClass('active');
                        document.getElementById('<%= hfModalActiveTab.ClientID %>').value = 'payment';
                    } else {
                        $('#btnTabModalCharge').addClass('active');
                        $('#tab-modal-charge').addClass('active');
                        document.getElementById('<%= hfModalActiveTab.ClientID %>').value = 'charge';
                    }
                }
                
                $(document).ready(function () {
                    var tabEl = document.getElementById('<%= hfModalActiveTab.ClientID %>');
                    if (tabEl) {
                        var activeTab = tabEl.value || 'payment';
                        switchModalTab(activeTab);
                    }
                });
            </script>

        </div>

    </asp:Panel>

    <!-- QUICK PAYMENT & BILLING PROCESS MODAL -->
    <asp:Panel ID="pnlPaymentProcessModal" runat="server" CssClass="modal-bg" style="display: none;">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title"><i class="fas fa-money-bill-wave" style="margin-right:10px;"></i> Quick Payment & Billing</h3>
                <asp:Button ID="btnCloseModal" runat="server" Text="&times;" CssClass="close-modal" OnClick="btnCloseModal_Click" />
            </div>

            <!-- Alert Message inside Modal -->
            <asp:Label ID="lblModalMessage" runat="server" Visible="false" CssClass="alert" style="display:block; margin-bottom: 15px; padding: 10px; border-radius: 6px; font-weight: bold; font-size:13px;"></asp:Label>

            <!-- Member Info Header -->
            <div class="modal-member-info">
                <div>
                    <span class="modal-info-label">Member No:</span><br />
                    <span class="modal-info-value" style="font-size:14px;"><asp:Label ID="lblModalMemberNo" runat="server"></asp:Label></span>
                    <asp:HiddenField ID="hfModalMemberID" runat="server" />
                    <asp:HiddenField ID="hfModalMemberStatus" runat="server" />
                    <asp:HiddenField ID="hfModalActiveTab" runat="server" Value="payment" />
                </div>
                <div>
                    <span class="modal-info-label">Name:</span><br />
                    <span class="modal-info-value" style="font-size:14px;"><asp:Label ID="lblModalFullName" runat="server"></asp:Label></span>
                </div>
                <div>
                    <span class="modal-info-label">Ledger Balance:</span><br />
                    <div id="divModalBalance" runat="server">
                        <asp:Label ID="lblModalBalance" runat="server" Text="PKR 0.00"></asp:Label>
                    </div>
                </div>
            </div>

            <!-- Modal Tabs -->
            <div class="modal-tabs">
                <button type="button" id="btnTabModalPayment" class="modal-tab-btn active" onclick="switchModalTab('payment')">Receive Payment</button>
                <button type="button" id="btnTabModalCharge" class="modal-tab-btn" onclick="switchModalTab('charge')">Charge Subscriptions</button>
            </div>

            <!-- Tab 1: Receive Payment -->
            <div id="tab-modal-payment" class="modal-tab-content active">
                <div class="form-grid">
                    <div class="form-group">
                        <label>Amount Received (PKR) <span style="color:red">*</span></label>
                        <asp:TextBox ID="txtModalAmountPaid" runat="server" CssClass="form-control" type="number" step="0.01"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>Payment Mode</label>
                        <asp:DropDownList ID="ddlModalPaymentMode" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlModalPaymentMode_SelectedIndexChanged">
                            <asp:ListItem Text="Cash" Value="Cash"></asp:ListItem>
                            <asp:ListItem Text="Credit Card" Value="Credit Card"></asp:ListItem>
                            <asp:ListItem Text="Online Payment" Value="Online Payment"></asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <div class="form-group" id="divModalCardNoPayment" runat="server" visible="false">
                        <label>Credit Card # (First 4 digits auto-selects bank)</label>
                        <asp:TextBox ID="txtModalPaymentCardNo" runat="server" CssClass="form-control" placeholder="First 4 digits e.g. 4214" AutoPostBack="true" OnTextChanged="txtModalPaymentCardNo_TextChanged" onkeyup="if(this.value.replace(/\s+/g, '').length >= 4) { this.blur(); }"></asp:TextBox>
                    </div>

                    <div class="form-group" id="divModalBankCard" runat="server" visible="false">
                        <label>Bank</label>
                        <asp:DropDownList ID="ddlModalBankCard" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlModalBankCard_SelectedIndexChanged">
                        </asp:DropDownList>
                    </div>

                    <div class="form-group" id="divModalCardType" runat="server" visible="false">
                        <label>Card Type (Silver / Gold / Green / Platinum)</label>
                        <asp:TextBox ID="txtModalCardType" runat="server" CssClass="form-control" ReadOnly="true" placeholder="Card Type"></asp:TextBox>
                    </div>

                    <div class="form-group" id="divModalBankDiscountPercent" runat="server" visible="false">
                        <label>Bank Disc %</label>
                        <asp:TextBox ID="txtModalBankDiscountPercent" runat="server" CssClass="form-control" ReadOnly="true" placeholder="0%" style="font-weight:700; color:#15803d;"></asp:TextBox>
                    </div>

                    <div class="form-group" id="divModalRefID" runat="server" visible="false" style="grid-column: 1 / -1;">
                        <label>Reference ID</label>
                        <asp:TextBox ID="txtModalReferenceID" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>

                    <div class="form-group" id="divModalCardOfferInfo" runat="server" visible="false" style="grid-column: 1 / -1; background:#e0f2fe; border:1px solid #0284c7; border-radius:6px; padding:10px 12px; margin-top:4px;">
                        <div style="font-weight:700; color:#0369a1; font-size:12px; margin-bottom:4px;">
                            <i class="fas fa-credit-card"></i> Card Prefix Offer & Details
                        </div>
                        <div style="font-size:11.5px; color:#0c4a6e; line-height:1.5;">
                            <asp:Label ID="lblModalCardOfferDetails" runat="server"></asp:Label>
                        </div>
                    </div>
                </div>
                
                <div style="margin-top: 20px; display:flex; justify-content:flex-end;">
                    <asp:Button ID="btnModalReceivePayment" runat="server" Text="Process Payment" CssClass="btn btn-primary" OnClick="btnModalReceivePayment_Click" OnClientClick="return confirm('Confirm payment receipt?');" />
                </div>
            </div>

            <!-- Tab 2: Charge Subscriptions -->
            <div id="tab-modal-charge" class="modal-tab-content">
                <asp:GridView ID="gvModalActiveSubscriptions" runat="server" AutoGenerateColumns="False" 
                    CssClass="grid-view" EmptyDataText="No active subscriptions found for this member."
                    OnRowCommand="gvModalActiveSubscriptions_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="SportName" HeaderText="Sport" />
                        <asp:BoundField DataField="PackageName" HeaderText="Package" />
                        <asp:TemplateField HeaderText="Member / Dependent">
                            <ItemTemplate>
                                <%# string.IsNullOrEmpty(Eval("DependentName").ToString()) ? "Self" : Eval("DependentName") + " (" + Eval("DependentRelation") + ")" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="BaseFee" HeaderText="Base Fee" DataFormatString="{0:N0}" />
                        <asp:TemplateField HeaderText="Last Billed">
                            <ItemTemplate>
                                <%# Eval("LastBilledDate") != DBNull.Value ? Convert.ToDateTime(Eval("LastBilledDate")).ToString("dd MMM yyyy") : "Never" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Action">
                            <ItemTemplate>
                                <asp:Button ID="btnModalGenerateCharge" runat="server" 
                                    Text='<%# Eval("LastBilledDate") == DBNull.Value ? "Generate Charge" : "Charged" %>' 
                                    CssClass='<%# Eval("LastBilledDate") == DBNull.Value ? "btn btn-primary" : "btn" %>' 
                                    style='<%# Eval("LastBilledDate") == DBNull.Value ? "padding: 6px 12px; font-size: 11px;" : "padding: 6px 12px; font-size: 11px; background: var(--gray-300); color: var(--gray-600); cursor: not-allowed;" %>'
                                    CommandName="GenerateModalCharge" 
                                    CommandArgument='<%# Container.DataItemIndex %>' 
                                    Enabled='<%# Eval("LastBilledDate") == DBNull.Value %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>

                <!-- Sub-modal panel inside for Confirmation -->
                <asp:Panel ID="pnlModalConfirmCharge" runat="server" Visible="false" style="margin-top: 15px; border: 1px solid #bfdbfe; padding: 15px; border-radius: 8px; background-color: #f0f7ff;">
                    <h4 style="margin-bottom: 12px; color: var(--primary-dark); font-weight:700;"><i class="fas fa-check-circle"></i> Confirm Subscription Charge</h4>
                    
                    <div style="margin-bottom: 12px;">
                        <strong style="color: var(--primary-dark); font-size: 14px;"><asp:Literal ID="litModalChargePackageName" runat="server"></asp:Literal></strong><br />
                        <span style="color: var(--gray-600); font-size: 12px;"><asp:Literal ID="litModalChargeMemberName" runat="server"></asp:Literal></span>
                    </div>

                    <div class="form-group" style="margin-bottom:12px;">
                        <label style="color:var(--primary-dark); font-weight:700;">Select Package <span style="color:red">*</span></label>
                        <asp:DropDownList ID="ddlModalChargePackage" runat="server" CssClass="form-control" style="font-weight:600;" AutoPostBack="true" OnSelectedIndexChanged="ddlModalChargePackage_SelectedIndexChanged">
                        </asp:DropDownList>
                    </div>

                    <div class="form-group">
                        <label>Billing Period</label>
                        <asp:TextBox ID="txtModalBillingPeriod" runat="server" CssClass="form-control" placeholder="e.g. August 2026"></asp:TextBox>
                    </div>

                    <div class="rules-container">
                        <p style="font-size: 11px; font-weight: 700; color: var(--gray-500); margin-bottom: 8px; text-transform: uppercase;">Discount Rules Evaluated</p>
                        <asp:Repeater ID="rptModalRules" runat="server">
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
                            <span><asp:Literal ID="litModalBaseFee" runat="server"></asp:Literal></span>
                        </div>
                        <div class="summary-row">
                            <span>Discount Amount</span>
                            <span style="color: #ef4444;">- <asp:Literal ID="litModalDiscount" runat="server"></asp:Literal></span>
                        </div>
                        <div class="summary-row">
                            <span>GST (<asp:Literal ID="litModalGSTPercent" runat="server"></asp:Literal>%)</span>
                            <span><asp:Literal ID="litModalGSTAmount" runat="server"></asp:Literal></span>
                        </div>
                        <div class="summary-total">
                            <span>Net Charge to Ledger</span>
                            <span><asp:Literal ID="litModalNetFee" runat="server"></asp:Literal></span>
                        </div>
                    </div>

                    <asp:HiddenField ID="hfModalChargeMemberSubID" runat="server" />
                    <asp:HiddenField ID="hfModalCalculatedNetFee" runat="server" />

                    <div style="margin-top: 15px; display: flex; gap: 10px;">
                        <asp:Button ID="btnModalConfirmCharge" runat="server" Text="Confirm Charge" CssClass="btn btn-primary" style="flex: 1;" OnClick="btnModalConfirmCharge_Click" />
                        <asp:Button ID="btnModalCancelCharge" runat="server" Text="Cancel" CssClass="btn" style="background: var(--gray-200); color: var(--gray-700); flex: 1;" OnClick="btnModalCancelCharge_Click" />
                    </div>
                </asp:Panel>
            </div>
        </div>
    </asp:Panel>

    <!-- RFID Assignment Modal -->
    <asp:Panel ID="pnlRFIDAssignmentModal" runat="server" CssClass="modal-bg" style="display: none;">
        <div class="modal-content" style="max-width: 460px;">
            <div class="modal-header">
                <h3 class="modal-title"><i class="fas fa-id-card" style="color:var(--primary); margin-right:8px;"></i> Assign & Activate RFID Card</h3>
                <asp:Button ID="btnModalCloseRFID" runat="server" Text="&times;" CssClass="close-modal" OnClick="btnModalCloseRFID_Click" />
            </div>

            <!-- Alert inside RFID modal -->
            <asp:Label ID="lblRFIDModalMsg" runat="server" Visible="false" CssClass="alert" style="display:block; margin-bottom:15px; padding:10px; border-radius:6px; font-weight:bold; font-size:13px;"></asp:Label>

            <asp:HiddenField ID="hfRFIDMemberID" runat="server" />
            <asp:HiddenField ID="hfRFIDMemberNo" runat="server" />
            <asp:HiddenField ID="hfRFIDRelationship" runat="server" />

            <div style="background:#f0f7ff; border-left:4px solid var(--info); padding:12px 15px; border-radius:4px; margin-bottom:18px;">
                <div style="font-size:11px; color:var(--gray-500); text-transform:uppercase; font-weight:700;">Member Info</div>
                <div style="font-size:14px; color:var(--primary-dark); font-weight:700; margin-top:2px;">
                    <asp:Label ID="lblRFIDMemberDetails" runat="server"></asp:Label>
                </div>
                <div style="font-size:12px; color:#4b5563; margin-top:4px;">
                    <strong>Current Status:</strong> <asp:Label ID="lblRFIDCurrentStatus" runat="server" style="font-weight:700;"></asp:Label>
                </div>
            </div>

            <div class="form-group" style="margin-bottom:18px;">
                <label style="font-weight:700; color:var(--primary-dark);">Scan / Enter RFID Card Number <span style="color:red">*</span></label>
                <asp:TextBox ID="txtModalRFIDInput" runat="server" CssClass="form-control" placeholder="Scan card or type RFID..." style="font-size:15px; font-weight:700; padding:8px 12px; letter-spacing:1px;"></asp:TextBox>
            </div>

            <div style="display:flex; justify-content:space-between; align-items:center; gap:10px; margin-top:20px;">
                <asp:Button ID="btnModalDeactivateRFID" runat="server" Text="Deactivate Card" CssClass="btn" style="background-color:#ef4444; color:white; font-weight:600; font-size:12px;" OnClick="btnModalDeactivateRFID_Click" OnClientClick="return confirm('Are you sure you want to deactivate this RFID card?');" />
                <div style="display:flex; gap:8px;">
                    <asp:Button ID="btnModalCloseRFID2" runat="server" Text="Cancel" CssClass="btn btn-secondary" style="font-size:12px;" OnClick="btnModalCloseRFID_Click" />
                    <asp:Button ID="btnModalSaveRFID" runat="server" Text="Assign & Activate" CssClass="btn btn-success" style="font-weight:700; font-size:13px; box-shadow:0 2px 4px rgba(16,185,129,0.3);" OnClick="btnModalSaveRFID_Click" />
                </div>
            </div>
        </div>
    </asp:Panel>

    <!-- 12-Month Status Modal -->
    <asp:Panel ID="pnl12MonthModal" runat="server" CssClass="modal-bg" style="display: none;">
        <div class="modal-content" style="max-width: 680px; width: 92%; border-radius: 12px; overflow: hidden; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.2);">
            <div class="modal-header" style="background: linear-gradient(135deg, #1e293b, #0f172a); color: white; padding: 16px 20px;">
                <h3 class="modal-title" style="color: white; margin:0; font-size:16px; font-weight:700; display:flex; align-items:center;">
                    <i class="fas fa-calendar-alt" style="color: #38bdf8; margin-right: 10px; font-size:18px;"></i> 
                    12-Month Subscription Status (<asp:Literal ID="lit12MonthYear" runat="server"></asp:Literal>)
                </h3>
                <asp:Button ID="btn12MonthClose" runat="server" Text="&times;" CssClass="close-modal" OnClick="btn12MonthClose_Click" style="color:white; font-size:22px; cursor:pointer;" />
            </div>
            <div style="padding: 20px; background-color: #ffffff;">
                <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-left: 4px solid #0284c7; border-radius: 6px; padding: 12px 15px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <div style="font-size: 11px; color: #64748b; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Member Details</div>
                        <div style="font-size: 15px; font-weight: 700; color: #1e293b; margin-top: 2px;">
                            <asp:Label ID="lbl12MonthMemberName" runat="server"></asp:Label>
                        </div>
                    </div>
                    <div style="text-align: right;">
                        <span style="font-size: 13px; font-weight: 700; background: #e0f2fe; color: #0369a1; padding: 5px 12px; border-radius: 20px;">
                            <asp:Label ID="lbl12MonthMembershipNo" runat="server"></asp:Label>
                        </span>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px;">
                    <asp:Repeater ID="rpt12Months" runat="server">
                        <ItemTemplate>
                            <div style='<%# Convert.ToBoolean(Eval("IsActive")) ? "background: #f0fdf4; border: 1.5px solid #22c55e; border-radius: 8px; padding: 12px 10px; text-align: center; box-shadow: 0 1px 3px rgba(34,197,94,0.1);" : "background: #fef2f2; border: 1.5px solid #ef4444; border-radius: 8px; padding: 12px 10px; text-align: center; box-shadow: 0 1px 3px rgba(239,68,68,0.1);" %>'>
                                <div style='<%# Convert.ToBoolean(Eval("IsActive")) ? "font-weight: 800; font-size: 13px; color: #15803d; text-transform: uppercase;" : "font-weight: 800; font-size: 13px; color: #991b1b; text-transform: uppercase;" %>'>
                                    <%# Eval("MonthName") %>
                                </div>
                                <div style="margin-top: 6px;">
                                    <span style='<%# Convert.ToBoolean(Eval("IsActive")) ? "background-color: #22c55e; color: #ffffff; padding: 3px 8px; border-radius: 12px; font-weight: 700; font-size: 11px; display: inline-block;" : "background-color: #ef4444; color: #ffffff; padding: 3px 8px; border-radius: 12px; font-weight: 700; font-size: 11px; display: inline-block;" %>'>
                                        <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Deactive" %>
                                    </span>
                                </div>
                                <div style="font-size: 11px; margin-top: 6px; color: #475569; font-weight: 600; min-height: 24px; display: flex; align-items: center; justify-content: center; word-wrap: break-word;">
                                    <%# Eval("SportsList") %>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div style="margin-top: 22px; display: flex; justify-content: flex-end;">
                    <asp:Button ID="btn12MonthClose2" runat="server" Text="Close" CssClass="btn btn-secondary" OnClick="btn12MonthClose_Click" style="padding: 6px 24px; font-weight: 600;" />
                </div>
            </div>
        </div>
    </asp:Panel>

    <!-- Manual Register / Card No Modal -->
    <asp:HiddenField ID="hfModalMemberSubSource" runat="server" />
    <asp:HiddenField ID="hfModalMemberSubArgs" runat="server" />
    <asp:HiddenField ID="hfModalMemberSportId" runat="server" />
    <asp:HiddenField ID="hfModalMemberSubType" runat="server" />

    <div id="pnlMemberSubManualModal" class="modal-bg" style="display:none;">
        <div class="modal-content" style="max-width: 480px;">
            <div class="modal-header">
                <h3 class="modal-title"><i class="fas fa-id-card" style="color:var(--primary); margin-right:8px;"></i> Manual Register / Card No</h3>
                <button type="button" class="close-modal" onclick="closeMemberSubManualModal()">&times;</button>
            </div>
            <div style="background:#f0f7ff; border-left:4px solid var(--info); padding:10px 14px; border-radius:4px; margin-bottom:16px;">
                <div style="font-size:11px; color:var(--gray-500); text-transform:uppercase; font-weight:700;">Subscription Summary</div>
                <div id="lblMemberSubSummary" style="font-size:13px; color:var(--primary-dark); font-weight:700; margin-top:2px;"></div>
            </div>
            <div class="form-group" style="margin-bottom:18px;">
                <label style="font-weight:700; color:var(--primary-dark); font-size:13px; display:block; margin-bottom:6px;">
                    Enter manual Register/Card No <span style="font-size:11px; color:var(--gray-500); font-weight:normal;">(Digits or Alphabets)</span>
                </label>
                <asp:TextBox ID="txtMemberSubManualCardNo" runat="server" CssClass="form-control" placeholder="e.g. 1024 or RC-45 or CARD-A01" style="font-size:14px; font-weight:700; height:38px;" onkeydown="if(event.keyCode===13){event.preventDefault();document.getElementById('<%= btnConfirmMemberSubModal.ClientID %>').click();}"></asp:TextBox>
            </div>
            <div style="display:flex; justify-content:flex-end; gap:10px; margin-top:20px;">
                <button type="button" class="btn btn-secondary" onclick="closeMemberSubManualModal()" style="font-size:12px; height:36px; padding:0 16px; border:1px solid var(--gray-300); background:var(--gray-100); color:var(--gray-700); font-weight:600; border-radius:6px; cursor:pointer;">Cancel</button>
                <asp:Button ID="btnConfirmMemberSubModal" runat="server" Text="Confirm &amp; Save" CssClass="btn btn-success" OnClick="btnConfirmMemberSubModal_Click" style="font-weight:700; font-size:13px; height:36px; padding:0 20px; box-shadow:0 2px 6px rgba(16,185,129,0.3); border-radius:6px; cursor:pointer;" />
            </div>
        </div>
    </div>
</asp:Content>
