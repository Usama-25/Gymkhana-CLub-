<%@ Page Title="Manage Sports Cards" Language="C#" MasterPageFile="~/Sports_Management/SiteSports.master" AutoEventWireup="true" CodeFile="ManageSportsCard.aspx.cs" Inherits="ManageSportsCard" %>
<%@ Register Src="~/Sports_Management/MemberSubscriptionInfo.ascx" TagPrefix="uc" TagName="MemberSubInfo" %>



<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* Compact Page Layout */
        .page-header-card { margin-bottom: 8px !important; }
        .page-header-card h2 { font-size: 18px !important; margin: 0 !important; }
        .card { margin-bottom: 8px !important; box-shadow: 0 2px 4px rgba(0,0,0,0.04) !important; border-radius: 8px !important; }
        .card-header { padding: 6px 12px !important; font-size: 13px !important; font-weight: 700 !important; background: #1e3a8a !important; color: #fff !important; }
        .card-body { padding: 10px 14px !important; }

        /* Recipient Header Bar */
        .recipient-header-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
            background: #f0f4ff;
            border: 1px solid #cbd5e1;
            padding: 6px 12px;
            border-radius: 6px;
            margin-bottom: 8px;
        }

        /* Scroll-less Grid Container */
        .custom-grid-container {
            max-height: 270px;
            overflow-y: auto;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
        }
        .custom-grid { width:100%; border-collapse:collapse; background:#fff; border-radius:6px; }
        .custom-grid th {
            padding:7px 10px;
            font-size:11px;
            text-transform:uppercase;
            letter-spacing:.05em;
            text-align:left;
            white-space:nowrap;
            position: sticky;
            top: 0;
            z-index: 5;
            background: #1e3a8a;
            color: #ffffff;
        }
        .custom-grid td { padding:5px 10px; font-size:12px; color:#374151; border-bottom:1px solid #f3f4f6; vertical-align:middle; }
        
        /* Checkbox */
        .act-cb { width:16px; height:16px; accent-color:#2563eb; cursor:pointer; }
        .act-cb:disabled { cursor:not-allowed; accent-color:#9ca3af; }
        
        /* Inputs */
        .grid-date { font-size:12px; padding:3px 6px; border:1px solid #d1d5db; border-radius:4px; width:125px; height:28px; }
        .grid-date:focus { outline:none; border-color:#2563eb; box-shadow:0 0 0 2px rgba(37,99,235,.15); }
        .grid-date:disabled { background:#e5e7eb; color:#9ca3af; cursor:not-allowed; }
        .grid-select { font-size:12px; padding:3px 6px; border:1px solid #cbd5e1; border-radius:5px; background:#fff; height:30px; }
        .grid-select:focus { outline:none; border-color:#2563eb; }

        /* Bottom Bar */
        .assign-bar { display:flex; flex-wrap:wrap; gap:12px; align-items:flex-end; margin-top:8px; padding-top:8px; border-top:1.5px solid #e2e8f0; }
        .assign-bar .form-group { margin-bottom:0; min-width:150px; flex:1; }
        .assign-bar .form-control { height:32px; font-size:12px; padding:4px 8px; }

        /* Modal Background & Content */
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
            padding: 22px;
            border-radius: 10px;
            width: 100%;
            max-width: 480px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            max-height: 90vh;
            overflow-y: auto;
        }
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 16px;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 10px;
        }
        .modal-title { font-size: 16px; font-weight: 700; color: #1e3a8a; margin: 0; }
        .close-modal { background: none; border: none; font-size: 22px; cursor: pointer; color: #64748b; line-height: 1; }
        .close-modal:hover { color: #0f172a; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-header-card" style="display:flex; justify-content:space-between; align-items:center;">
        <div>
            <h2><i class="fas fa-id-card" style="margin-right:8px;"></i> Manage Sports Cards <span class="badge">Assign / View</span></h2>
        </div>
    </div>

    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert"
        style="display:block; margin-bottom:8px; padding:8px 12px; border-radius:6px; font-weight:bold; font-size:12px;"></asp:Label>

    <asp:Panel ID="pnlSearchCard" runat="server" CssClass="card" DefaultButton="btnSearch">
        <div class="card-header">Search Member &amp; Assign Sports Card</div>
        <div class="card-body">

            <%-- Hidden fields for code-behind compatibility --%>
            <asp:HiddenField ID="hfMemberID"            runat="server" />
            <asp:HiddenField ID="hfSelectedMembershipNo" runat="server" />
            <asp:HiddenField ID="hfSelectedRelationship" runat="server" />
            <asp:HiddenField ID="hfSelectedName"        runat="server" />
            <asp:HiddenField ID="hfHasActiveMonthly"    runat="server" Value="none" />
            <asp:HiddenField ID="hfCardTypeVal"         runat="server" Value="0" />
            <asp:HiddenField ID="hfCardTypeText"        runat="server" Value="" />

            <asp:Panel ID="pnlTargetDependent" runat="server" Visible="false" style="display:none;">
                <asp:DropDownList ID="ddlDependents" runat="server"></asp:DropDownList>
            </asp:Panel>

            <%-- Search Row --%>
            <div style="display:flex; gap:10px; align-items:flex-end; flex-wrap:wrap;">
                <div class="form-group" style="margin-bottom:0; flex:1; max-width:420px;">
                    <label style="font-weight:700; color:#1e3a8a; font-size:12px; margin-bottom:4px; display:block;">Member ID / Name</label>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Enter MEM-001 or Name..." style="height:32px; font-size:12px;"></asp:TextBox>
                </div>
                <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="btnSearch_Click" style="height:32px; padding:0 18px; font-size:12px; font-weight:700;" />
            </div>

            <%-- Active Sports Warning --%>
            <asp:Panel ID="pnlActiveSportsWarning" runat="server" Visible="false"
                style="margin-top:8px; padding:8px 12px; background:#fff3cd; border:1.5px solid #f59e0b; border-radius:6px; display:flex; align-items:center; gap:10px;">
                <i class="fas fa-exclamation-triangle" style="color:#d97706; font-size:18px;"></i>
                <div>
                    <div style="font-weight:800; color:#92400e; font-size:12px;">⚠ Active Sports Detected</div>
                    <div style="color:#78350f; font-size:11px; margin-top:1px;">
                        Active sports: <strong><asp:Label ID="lblActiveSportsList" runat="server"></asp:Label></strong>
                    </div>
                </div>
            </asp:Panel>

            <%-- Search Results Grid --%>
            <asp:Panel ID="pnlSearchResults" runat="server" Visible="false" style="margin-top:10px;">
                
                <%-- Recipient Header Bar with Department, SubDept, Card Type & Sub Type on Right --%>
                <div class="recipient-header-bar">
                    <div style="font-weight:700; font-size:13px; color:#1e3a8a; display:flex; align-items:center; gap:6px;">
                        <i class="fas fa-users"></i> Select Recipients &amp; Set Card Details
                    </div>
                    <div style="display:flex; align-items:center; gap:12px; flex-wrap:wrap;">
                        <div style="display:flex; align-items:center; gap:6px;">
                            <label style="font-size:12px; font-weight:700; color:#1e3a8a; margin:0; white-space:nowrap;">Department:</label>
                            <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="grid-select" AutoPostBack="true" OnSelectedIndexChanged="ddlDepartment_SelectedIndexChanged" style="font-size:12px; padding:2px 8px; height:30px; font-weight:600; border-color:#93c5fd;">
                            </asp:DropDownList>
                        </div>
                        <div style="display:flex; align-items:center; gap:6px;">
                            <label style="font-size:12px; font-weight:700; color:#1e3a8a; margin:0; white-space:nowrap;">Sub Dept:</label>
                            <asp:DropDownList ID="ddlSubDept" runat="server" CssClass="grid-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSubDept_SelectedIndexChanged" style="font-size:12px; padding:2px 8px; height:30px; font-weight:600; border-color:#93c5fd;">
                            </asp:DropDownList>
                        </div>
                        <div style="display:flex; align-items:center; gap:6px;">
                            <label style="font-size:12px; font-weight:700; color:#1e3a8a; margin:0; white-space:nowrap;">Card Type:</label>
                            <asp:DropDownList ID="ddlCardType" runat="server" CssClass="grid-select" onchange="onGlobalCardTypeChange(this)" style="font-size:12px; padding:2px 8px; height:30px; font-weight:600; border-color:#93c5fd;">
                                <asp:ListItem Value="0" Text="-- Select Card Type --"></asp:ListItem>
                                <asp:ListItem Value="17" Text="Family Sports Card"></asp:ListItem>
                                <asp:ListItem Value="18" Text="Couple Sports Card"></asp:ListItem>
                                <asp:ListItem Value="19" Text="Individual / Child Sports Card"></asp:ListItem>
                                <asp:ListItem Value="20" Text="Non Earning Sports Card"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div style="display:flex; align-items:center; gap:6px;">
                            <label style="font-size:12px; font-weight:700; color:#1e3a8a; margin:0; white-space:nowrap;">Sub Type:</label>
                            <asp:DropDownList ID="ddlSubType" runat="server" CssClass="grid-select" onchange="onGlobalSubTypeChange(this)" style="font-size:12px; padding:2px 8px; height:30px; font-weight:600; border-color:#93c5fd;">
                                <asp:ListItem Value="Monthly" Text="Monthly"></asp:ListItem>
                                <asp:ListItem Value="Continuous" Text="Continuous"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>

                <div class="custom-grid-container">
                    <asp:GridView ID="gvMemberResults" runat="server" AutoGenerateColumns="False"
                        GridLines="None" CssClass="custom-grid" OnRowCommand="gvMemberResults_RowCommand">
                        <HeaderStyle BackColor="#1e3a8a" ForeColor="#ffffff" Font-Bold="True" Height="34px" />
                        <RowStyle Height="34px" />
                        <AlternatingRowStyle BackColor="#f9fafb" />
                        <Columns>
                            <%-- ACTION: Checkbox --%>
                            <asp:TemplateField ItemStyle-Width="40px" ItemStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    <input type="checkbox" id="chkAll" title="Select All"
                                        onchange="toggleAll(this)"
                                        style="width:15px;height:15px;accent-color:#fff;cursor:pointer;" />
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <input type="checkbox" class="act-cb"
                                        name="cbMember"
                                        value='<%# Container.DataItemIndex + "|" + Eval("MemberID") + "|" + Eval("MembershipNo") + "|" + Eval("Relationship") + "|" + Eval("Status") %>'
                                        data-idx='<%# Container.DataItemIndex %>'
                                        onchange="onCheckboxChange(this)"
                                        <%# IsAccountActive(Eval("Status").ToString()) ? "" : "disabled='disabled'" %>
                                        style="width:16px;height:16px;accent-color:#2563eb;cursor:pointer;" />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Member No --%>
                            <asp:TemplateField HeaderText="Member No">
                                <ItemTemplate>
                                    <span style="font-weight:600; color:#1e3a8a;"><%# Eval("MembershipNo") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Name --%>
                            <asp:TemplateField HeaderText="Name">
                                <ItemTemplate>
                                    <span style="font-weight:500;"><%# Eval("FullName") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Relationship --%>
                            <asp:TemplateField HeaderText="Relationship">
                                <ItemTemplate>
                                    <span style='<%# GetRelationshipBadgeStyle(Eval("Relationship").ToString()) %>'>
                                        <%# Eval("Relationship") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Account Status --%>
                            <asp:TemplateField HeaderText="Account Status">
                                <ItemTemplate>
                                    <span style='<%# GetAccountStatusBadgeStyle(Eval("Status").ToString()) %>'>
                                        <%# Eval("Status") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Active Sports --%>
                            <asp:TemplateField HeaderText="Active Sports">
                                <ItemTemplate>
                                    <span style='<%# GetSubStatusStyle(Eval("SubscriptionStatus").ToString()) %>'>
                                        <%# Eval("SubscriptionStatus") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Manual Register / Card No (editable per row) --%>
                            <asp:TemplateField HeaderText="Manual Register / Card No" ItemStyle-Width="160px">
                                <ItemTemplate>
                                    <input type="text" class="grid-input"
                                        name='<%# "mc_" + Container.DataItemIndex %>'
                                        value='<%# Eval("ManualCardNo") != DBNull.Value ? Eval("ManualCardNo").ToString() : "" %>'
                                        placeholder="e.g. 1024 or RC-45"
                                        <%# IsAccountActive(Eval("Status").ToString()) ? "" : "disabled='disabled'" %>
                                        style="font-size:12px; padding:3px 8px; border:1px solid #cbd5e1; border-radius:4px; width:140px; height:28px; font-weight:600; text-transform:uppercase;" />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Start Date (editable per row) --%>
                            <asp:TemplateField HeaderText="Start Date" ItemStyle-Width="130px">
                                <ItemTemplate>
                                    <input type="date" class="grid-date"
                                        name='<%# "sd_" + Container.DataItemIndex %>'
                                        value='<%# GetDefaultStartDate() %>'
                                        <%# IsAccountActive(Eval("Status").ToString()) ? "" : "disabled='disabled'" %> />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- End Date (editable per row) --%>
                            <asp:TemplateField HeaderText="End Date" ItemStyle-Width="130px">
                                <ItemTemplate>
                                    <input type="date" class="grid-date"
                                        name='<%# "ed_" + Container.DataItemIndex %>'
                                        value='<%# GetDefaultEndDate() %>'
                                        <%# IsAccountActive(Eval("Status").ToString()) ? "" : "disabled='disabled'" %> />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%-- Action (Deactivate) --%>
                            <asp:TemplateField HeaderText="Action" ItemStyle-Width="105px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnRowDeact" runat="server"
                                        Text="🛑 Deactivate"
                                        CommandName="DeactivateCard"
                                        CommandArgument='<%# Eval("ActiveSportsCardSubID") + "|" + Eval("MembershipNo") + "|" + Eval("MemberID") + "|" + Eval("Relationship") %>'
                                        Visible='<%# Eval("HasActiveSportsCard") != DBNull.Value && Convert.ToBoolean(Eval("HasActiveSportsCard")) %>'
                                        OnClientClick='<%# "return confirm(\"Are you sure you want to deactivate Sports Card for " + Eval("MembershipNo") + "?\");" %>'
                                        style="background:#fee2e2; color:#b91c1c; border:1px solid #fca5a5; font-size:11px; font-weight:700; padding:3px 8px; border-radius:4px; text-decoration:none; display:inline-block;" />
                                </ItemTemplate>
                            </asp:TemplateField>

                        </Columns>
                    </asp:GridView>
                </div>

                <%-- Bottom Bar: Fee + Payment Mode + Save / Deactivate --%>
                <div class="assign-bar">
                    <div class="form-group">
                        <label style="font-size:11px; font-weight:700; margin-bottom:2px; display:block;">Fee (PKR)</label>
                        <asp:TextBox ID="txtFee" runat="server" CssClass="form-control" ReadOnly="true"
                            style="background:var(--gray-200); font-weight:bold;"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label style="font-size:11px; font-weight:700; margin-bottom:2px; display:block;">Payment Mode</label>
                        <asp:DropDownList ID="ddlPaymentMode" runat="server" CssClass="form-control" onchange="onPaymentModeChange(this)">
                            <asp:ListItem Text="Cash"           Value="Cash"></asp:ListItem>
                            <asp:ListItem Text="Credit Card"    Value="Credit Card"></asp:ListItem>
                            <asp:ListItem Text="Online Payment" Value="Online Payment"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <asp:Panel ID="pnlRefID" runat="server" CssClass="form-group" style="display:none;">
                        <label style="font-size:11px; font-weight:700; margin-bottom:2px; display:block;">Reference ID</label>
                        <asp:TextBox ID="txtRefID" runat="server" CssClass="form-control"></asp:TextBox>
                    </asp:Panel>
                    <div style="padding-bottom:1px; display:flex; gap:8px;">
                        <asp:Button ID="btnAssign" runat="server"
                            Text="💾 Save &amp; Assign Sports Card"
                            CssClass="btn btn-primary"
                            OnClick="btnAssign_Click"
                            OnClientClick="return validateSportsCardAssign();"
                            style="padding:0 18px; font-size:13px; font-weight:700; border-radius:6px; height:32px; white-space:nowrap; box-shadow:0 2px 6px rgba(37,99,235,.2);" />
                        <asp:Button ID="btnDeactivateSelected" runat="server"
                            Text="🛑 Deactivate Selected"
                            CssClass="btn"
                            OnClick="btnDeactivateSelected_Click"
                            OnClientClick="return confirmDeactivateSelected();"
                            style="padding:0 16px; font-size:13px; font-weight:700; border-radius:6px; height:32px; white-space:nowrap; background:#fee2e2; color:#b91c1c; border:1px solid #fca5a5;" />
                    </div>
                </div>

            </asp:Panel>

        </div>
    </asp:Panel>

    <!-- Manual Register / Card No Modal -->
    <div id="pnlSportsCardManualModal" class="modal-bg" style="display:none;">
        <div class="modal-content" style="max-width: 480px;">
            <div class="modal-header">
                <h3 class="modal-title"><i class="fas fa-id-card" style="color:#2563eb; margin-right:8px;"></i> Manual Register / Card No</h3>
                <button type="button" class="close-modal" onclick="closeSportsCardManualModal()">&times;</button>
            </div>
            <div style="background:#f0f7ff; border-left:4px solid #3b82f6; padding:10px 14px; border-radius:4px; margin-bottom:16px;">
                <div style="font-size:11px; color:#64748b; text-transform:uppercase; font-weight:700;">Assignment Summary</div>
                <div id="lblSportsCardSummary" style="font-size:13px; color:#1e3a8a; font-weight:700; margin-top:2px;"></div>
            </div>
            <div class="form-group" style="margin-bottom:18px;">
                <label style="font-weight:700; color:#1e3a8a; font-size:13px; display:block; margin-bottom:6px;">
                    Enter manual Register/Card No <span style="font-size:11px; color:#64748b; font-weight:normal;">(Digits or Alphabets)</span>
                </label>
                <asp:TextBox ID="txtManualCardNo" runat="server" CssClass="form-control" placeholder="e.g. 1024 or RC-45 or CARD-A01" style="font-size:14px; font-weight:700; height:38px;" onkeydown="if(event.keyCode===13){event.preventDefault();document.getElementById('<%= btnConfirmAssignModal.ClientID %>').click();}"></asp:TextBox>
            </div>
            <div style="display:flex; justify-content:flex-end; gap:10px; margin-top:20px;">
                <button type="button" class="btn btn-secondary" onclick="closeSportsCardManualModal()" style="font-size:12px; height:36px; padding:0 16px; border:1px solid #cbd5e1; background:#f1f5f9; color:#334155; font-weight:600; border-radius:6px; cursor:pointer;">Cancel</button>
                <asp:Button ID="btnConfirmAssignModal" runat="server" Text="Confirm &amp; Save" CssClass="btn btn-primary" OnClick="btnAssign_Click" style="font-weight:700; font-size:13px; height:36px; padding:0 20px; box-shadow:0 2px 6px rgba(37,99,235,.25); border-radius:6px; cursor:pointer;" />
            </div>
        </div>
    </div>

    <div style="display:none;">
        <uc:MemberSubInfo ID="ucMemberSubInfo" runat="server" />
    </div>
    <asp:Label ID="lblSelectedPerson" runat="server" style="display:none;"></asp:Label>

    <script type="text/javascript">
        /* ---- Client-side Payment Mode change toggle ---- */
        function onPaymentModeChange(sel) {
            var refPnl = document.getElementById('<%= pnlRefID.ClientID %>');
            if (refPnl) {
                refPnl.style.display = (sel.value !== 'Cash') ? 'block' : 'none';
            }
        }

        /* ---- Calculate and update fee based on global Card Type & checked rows ---- */
        function updateGridFee() {
            var feeElem = document.getElementById('<%= txtFee.ClientID %>');
            if (!feeElem) return;

            var checkedCbs = document.querySelectorAll('.act-cb:checked');
            if (!checkedCbs || checkedCbs.length === 0) {
                feeElem.value = '';
                return;
            }

            var cardTypeSel = document.getElementById('<%= ddlCardType.ClientID %>');
            var val = cardTypeSel ? parseInt(cardTypeSel.value) : 0;
            var feeMap = { 17: 9000, 18: 7000, 19: 6000, 20: 6000 };
            var fee = feeMap[val] || 0;

            feeElem.value = fee > 0 ? fee.toFixed(2) : '';
        }

        /* ---- Global Card Type dropdown change ---- */
        function onGlobalCardTypeChange(sel) {
            updateGridFee();
        }

        /* ---- Global Subscription Type dropdown change ---- */
        function onGlobalSubTypeChange(sel) {
            var val = sel ? sel.value : (document.getElementById('<%= ddlSubType.ClientID %>') ? document.getElementById('<%= ddlSubType.ClientID %>').value : 'Monthly');
            var isContinuous = (val === 'Continuous');
            var edInputs = document.querySelectorAll('input[name^="ed_"]');
            edInputs.forEach(function(edInput) {
                if (isContinuous) {
                    edInput.dataset.savedVal = edInput.value;
                    edInput.value = '';
                    edInput.disabled = true;
                } else {
                    edInput.disabled = false;
                    if (!edInput.value && edInput.dataset.savedVal) {
                        edInput.value = edInput.dataset.savedVal;
                    }
                }
            });
        }

        /* ---- Checkbox change ---- */
        function onCheckboxChange(cb) {
            updateGridFee();
        }

        /* ---- Select All toggle ---- */
        function toggleAll(masterCb) {
            document.querySelectorAll('.act-cb:not(:disabled)').forEach(function(c){
                c.checked = masterCb.checked;
            });
            updateGridFee();
        }

        /* ---- Validate before Save & Assign ---- */
        function validateSportsCardAssign() {
            var checked = document.querySelectorAll('.act-cb:checked');
            if (!checked || checked.length === 0) {
                alert('Please select at least one member from the grid.');
                return false;
            }

            var cardTypeSel = document.getElementById('<%= ddlCardType.ClientID %>');
            if (!cardTypeSel || cardTypeSel.value === '0') {
                alert('Please select a Sports Card Type.');
                return false;
            }

            var hfElem = document.getElementById('<%= hfHasActiveMonthly.ClientID %>');
            var activeSports = hfElem ? hfElem.value : 'none';
            if (activeSports && activeSports !== 'none') {
                if (!confirm('\u26a0 WARNING: Active sports detected:\n\n' + activeSports + '\n\nAre you sure you want to assign Sports Card?')) {
                    return false;
                }
            }

            return true;
        }

        function closeSportsCardManualModal() {
            var modal = document.getElementById('pnlSportsCardManualModal');
            if (modal) {
                modal.style.display = 'none';
            }
        }

        /* ---- Validate before Deactivate Selected ---- */
        function confirmDeactivateSelected() {
            var checked = document.querySelectorAll('.act-cb:checked');
            if (!checked || checked.length === 0) {
                alert('Please select at least one member to deactivate.');
                return false;
            }
            return confirm('Are you sure you want to deactivate Sports Card for the selected member(s)?');
        }

        window.addEventListener('DOMContentLoaded', function () {
            updateGridFee();
            onGlobalSubTypeChange();
        });
    </script>
</asp:Content>

