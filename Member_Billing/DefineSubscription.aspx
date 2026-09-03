<%@ Page Title="Define Subscription - Member Billing" Language="C#" MasterPageFile="~/Member_Billing/SiteMemberBilling.master" AutoEventWireup="true" CodeFile="DefineSubscription.aspx.cs" Inherits="Member_Billing_DefineSubscription" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <!-- Inline styles enforced across all components -->
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="PageTitle" runat="server">
    Subscription Definition & Multi-Tier Pricing
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <asp:UpdatePanel ID="upMainSubscription" runat="server" UpdateMode="Always">
        <ContentTemplate>

            <!-- Ultra-Compact Top Header & KPI Strip -->
            <div style="background:#ffffff; border-radius:6px; padding:6px 14px; border:1px solid #cbd5e1; border-left:4px solid #1e3a5f; margin-bottom:8px; display:flex; align-items:center; justify-content:space-between; box-shadow:0 1px 3px rgba(0,0,0,0.03);">
                <div style="display:flex; align-items:center; gap:8px;">
                    <h2 style="font-size:14px; font-weight:800; color:#1e3a5f; margin:0;">
                        Define & Manage Subscriptions
                    </h2>
                </div>

                <!-- KPI Mini Strip -->
                <div style="display:flex; gap:8px; align-items:center;">
                    <div style="background:#f8fafc; border:1px solid #cbd5e1; border-radius:14px; padding:2px 10px; font-size:11px; font-weight:700; color:#475569; display:inline-flex; align-items:center; gap:4px;">
                        Total: <strong style="color:#0f172a; font-size:12px;"><asp:Label ID="lblTotalPackages" runat="server" Text="0"></asp:Label></strong>
                    </div>
                    <div style="background:#ecfdf5; border:1px solid #a7f3d0; border-radius:14px; padding:2px 10px; font-size:11px; font-weight:700; color:#065f46; display:inline-flex; align-items:center; gap:4px;">
                        Active: <strong style="color:#065f46; font-size:12px;"><asp:Label ID="lblActivePackages" runat="server" Text="0"></asp:Label></strong>
                    </div>
                    <div style="background:#e0f2fe; border:1px solid #bae6fd; border-radius:14px; padding:2px 10px; font-size:11px; font-weight:700; color:#0369a1; display:inline-flex; align-items:center; gap:4px;">
                        With Cat/Type Rates: <strong style="color:#0369a1; font-size:12px;"><asp:Label ID="lblCategoryRatesCount" runat="server" Text="0"></asp:Label></strong>
                    </div>
                    <div style="background:#ede9fe; border:1px solid #ddd6fe; border-radius:14px; padding:2px 10px; font-size:11px; font-weight:700; color:#5b21b6; display:inline-flex; align-items:center; gap:4px;">
                        With Age Slabs: <strong style="color:#5b21b6; font-size:12px;"><asp:Label ID="lblAgeBenefitCount" runat="server" Text="0"></asp:Label></strong>
                    </div>
                </div>
            </div>

            <!-- Alert / Toast Messages -->
            <asp:Panel ID="pnlAlert" runat="server" Visible="false">
                <div id="divAlertBox" runat="server" style="padding:6px 12px; border-radius:5px; margin-bottom:8px; font-size:12px; font-weight:600; display:flex; align-items:center; gap:8px; background-color:#ecfdf5; color:#065f46; border:1px solid #a7f3d0;">
                    <asp:Label ID="lblAlertText" runat="server"></asp:Label>
                </div>
            </asp:Panel>

            <!-- Main 2-Column Layout (Form on Left, Scrollable Directory on Right) -->
            <div style="display:grid; grid-template-columns:430px 1fr; gap:12px; align-items:start;">

                <!-- ============================================
                     LEFT COLUMN: SUBSCRIPTION DEFINITION FORM
                ============================================ -->
                <div>
                    <div style="background:#ffffff; border-radius:6px; border:1px solid #cbd5e1; box-shadow:0 1px 4px rgba(0,0,0,0.04); overflow:hidden;">
                        
                        <!-- Form Header -->
                        <div style="background:linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%); padding:7px 12px; border-bottom:1.5px solid #c5a572; font-weight:800; color:#0f2b48; font-size:12.5px; display:flex; align-items:center; justify-content:space-between; letter-spacing:0.2px;">
                            <span>
                                <asp:Literal ID="litFormTitle" runat="server" Text="Create New Subscription"></asp:Literal>
                            </span>
                            <asp:Label ID="lblEditModeBadge" runat="server" Visible="false" Text="EDIT MODE" style="background:#ede9fe; color:#5b21b6; border:1px solid #ddd6fe; padding:1px 6px; border-radius:8px; font-size:10px; font-weight:700;"></asp:Label>
                        </div>

                        <!-- Form Body -->
                        <div style="padding:10px 12px;">
                            <asp:HiddenField ID="hfSubscriptionID" runat="server" Value="0" />

                            <!-- Unique ID & Subscription Name Row -->
                            <div style="display:grid; grid-template-columns:110px 1fr; gap:8px; margin-bottom:8px;">
                                <!-- Unique ID -->
                                <div>
                                    <label style="font-size:11px; font-weight:700; color:#1e293b; margin-bottom:2px; display:block;">
                                        Unique ID <span style="color:#ef4444;">*</span>
                                    </label>
                                    <asp:TextBox ID="txtSubscriptionCode" runat="server" style="font-family:'Inter', sans-serif; font-size:11.5px; font-weight:800; color:#1e3a5f; background-color:#f8fafc; border:1px solid #cbd5e1; border-radius:4px; padding:4px 8px; height:30px; width:100%; display:block; outline:none; box-sizing:border-box; text-transform:uppercase;" placeholder="SUB-001" MaxLength="50"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvCode" runat="server" ControlToValidate="txtSubscriptionCode"
                                        ErrorMessage="ID required." Display="Dynamic" ForeColor="#ef4444"
                                        ValidationGroup="vgSubscription" Font-Size="10.5px" Font-Bold="true"></asp:RequiredFieldValidator>
                                </div>

                                <!-- Subscription Name -->
                                <div>
                                    <label style="font-size:11px; font-weight:700; color:#1e293b; margin-bottom:2px; display:block;">
                                        Subscription Name <span style="color:#ef4444;">*</span>
                                    </label>
                                    <asp:TextBox ID="txtSubscriptionName" runat="server" style="font-family:'Inter', sans-serif; font-size:11.5px; font-weight:700; color:#0f172a; background-color:#ffffff; border:1px solid #cbd5e1; border-radius:4px; padding:4px 8px; height:30px; width:100%; display:block; outline:none; box-sizing:border-box;" placeholder="e.g. Regular Annual Subscription" MaxLength="150"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtSubscriptionName"
                                        ErrorMessage="Name required." Display="Dynamic" ForeColor="#ef4444"
                                        ValidationGroup="vgSubscription" Font-Size="10.5px" Font-Bold="true"></asp:RequiredFieldValidator>
                                </div>
                            </div>

                            <!-- Amount & Financial Heads Row -->
                            <div style="display:grid; grid-template-columns:120px 1fr; gap:8px; margin-bottom:8px;">
                                <!-- Amount -->
                                <div>
                                    <label style="font-size:11px; font-weight:700; color:#1e293b; margin-bottom:2px; display:block;">
                                        Base Amount (PKR) <span style="color:#ef4444;">*</span>
                                    </label>
                                    <asp:TextBox ID="txtAmount" runat="server" TextMode="Number" step="0.01" style="font-family:'Inter', sans-serif; font-size:11.5px; font-weight:700; color:#0f172a; background-color:#ffffff; border:1px solid #cbd5e1; border-radius:4px; padding:4px 8px; height:30px; width:100%; display:block; outline:none; box-sizing:border-box;" placeholder="0.00" onkeyup="updateLiveDiscountPreview();" onchange="updateLiveDiscountPreview();"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvAmount" runat="server" ControlToValidate="txtAmount"
                                        ErrorMessage="Amount required." Display="Dynamic" ForeColor="#ef4444"
                                        ValidationGroup="vgSubscription" Font-Size="10.5px" Font-Bold="true"></asp:RequiredFieldValidator>
                                </div>

                                <!-- Financial Heads (Styled AutoExtender with Concatenated E_Code) -->
                                <div style="position:relative;">
                                    <label style="font-size:11px; font-weight:700; color:#1e293b; margin-bottom:2px; display:block;">
                                        Financial Head (COA) <span style="color:#ef4444;">*</span>
                                    </label>
                                    <div style="position:relative; display:flex; align-items:center;">
                                        <asp:TextBox ID="txtFinancialHead" runat="server" ClientIDMode="Static"
                                            style="font-family:'Inter', sans-serif; font-size:11.5px; font-weight:700; color:#0f172a; background-color:#ffffff; border:1px solid #cbd5e1; border-radius:4px; padding:4px 26px 4px 8px; height:30px; width:100%; display:block; outline:none; box-sizing:border-box;" 
                                            placeholder="Type code or title..." 
                                            autocomplete="off"
                                            onfocus="showHeadAutoExtender();" 
                                            oninput="filterHeadAutoExtender();" 
                                            onkeydown="navigateHeadAutoExtender(event);">
                                        </asp:TextBox>
                                        <span onclick="toggleHeadDropdown(event);" style="position:absolute; right:6px; cursor:pointer; color:#64748b; font-size:9px; padding:3px; user-select:none;" title="View all Financial Heads">
                                            &#9660;
                                        </span>
                                    </div>

                                    <asp:HiddenField ID="hfFinancialHeadsJson" runat="server" ClientIDMode="Static" />

                                    <!-- Styled AutoExtender Floating Panel -->
                                    <div id="pnlHeadAutoExtender" class="gym-autoextender" style="display:none;">
                                        <div id="headAutoExtenderList"></div>
                                    </div>

                                    <asp:RequiredFieldValidator ID="rfvFinancialHead" runat="server" ControlToValidate="txtFinancialHead"
                                        ErrorMessage="Head required." Display="Dynamic" ForeColor="#ef4444"
                                        ValidationGroup="vgSubscription" Font-Size="10.5px" Font-Bold="true"></asp:RequiredFieldValidator>
                                </div>
                            </div>

                            <!-- =========================================================
                                 SECTION A: CATEGORY & MEMBERSHIP TYPE RATES
                            ========================================================= -->
                            <div style="margin-top:8px;">
                                <div style="display:flex; align-items:center; justify-content:space-between; background:#f8fafc; padding:6px 10px; border-radius:4px; border:1px solid #cbd5e1;">
                                    <div style="display:flex; align-items:center; gap:6px;">
                                        <asp:CheckBox ID="chkCategoryPricing" runat="server" ClientIDMode="Static" onclick="toggleCategoryPricingPanel();" style="accent-color:#1e3a5f; cursor:pointer;" />
                                        <label for="chkCategoryPricing" style="margin:0; cursor:pointer; font-weight:800; color:#0f2b48; font-size:11.5px;">
                                            Rates by Category & Membership Type
                                        </label>
                                    </div>
                                    <span style="background:#e0f2fe; color:#0369a1; border:1px solid #93c5fd; padding:1px 6px; border-radius:10px; font-size:10px; font-weight:700;">
                                        Differential
                                    </span>
                                </div>

                                <!-- Expandable Category Rates Panel -->
                                <div id="pnlCategoryPricing" style="display:none; background:linear-gradient(135deg, #f0f7ff 0%, #f8fafc 100%); border:1.5px dashed #93c5fd; border-radius:6px; padding:10px; margin-top:6px;">
                                    
                                    <!-- Mode Switch Tabs -->
                                    <div style="display:flex; gap:6px; margin-bottom:8px;">
                                        <button type="button" id="btnTabQuick" onclick="switchCategoryMode('quick');" style="flex:1; font-family:'Inter',sans-serif; font-size:10px; font-weight:800; padding:4px 6px; border-radius:4px; border:1px solid #1e3a5f; background:#1e3a5f; color:#ffffff; cursor:pointer;">
                                            Quick Dropdown
                                        </button>
                                        <button type="button" id="btnTabBulk" onclick="switchCategoryMode('bulk');" style="flex:1; font-family:'Inter',sans-serif; font-size:10px; font-weight:700; padding:4px 6px; border-radius:4px; border:1px solid #cbd5e1; background:#ffffff; color:#475569; cursor:pointer;">
                                            Bulk Multi-Select
                                        </button>
                                    </div>

                                    <!-- Mode 1: Quick Dropdown Sub-form -->
                                    <div id="divQuickSelect" style="background:#ffffff; border:1px solid #bfdbfe; border-radius:4px; padding:8px; margin-bottom:8px;">
                                        <div style="margin-bottom:6px;">
                                            <label style="font-size:10px; font-weight:700; color:#1e3a5f; margin-bottom:1px; display:block;">Member Category (FormTypeMain)</label>
                                            <asp:DropDownList ID="ddlCategory" runat="server" style="font-family:'Inter', sans-serif; font-size:11px; font-weight:600; color:#0f172a; background:#ffffff; border:1px solid #cbd5e1; border-radius:3px; padding:3px 6px; height:28px; width:100%; display:block; outline:none; box-sizing:border-box;">
                                            </asp:DropDownList>
                                        </div>

                                        <div style="margin-bottom:6px;">
                                            <label style="font-size:10px; font-weight:700; color:#1e3a5f; margin-bottom:1px; display:block;">Membership Type (MembershipType)</label>
                                            <asp:DropDownList ID="ddlMembershipType" runat="server" style="font-family:'Inter', sans-serif; font-size:11px; font-weight:600; color:#0f172a; background:#ffffff; border:1px solid #cbd5e1; border-radius:3px; padding:3px 6px; height:28px; width:100%; display:block; outline:none; box-sizing:border-box;">
                                            </asp:DropDownList>
                                        </div>

                                        <div style="display:grid; grid-template-columns:1fr auto; gap:6px; align-items:flex-end;">
                                            <div>
                                                <label style="font-size:10px; font-weight:700; color:#1e3a5f; margin-bottom:1px; display:block;">Amount (PKR) <span style="color:#ef4444;">*</span></label>
                                                <asp:TextBox ID="txtCategoryRateAmount" runat="server" TextMode="Number" step="0.01" style="font-family:'Inter', sans-serif; font-size:11px; font-weight:700; color:#0f172a; background:#ffffff; border:1px solid #cbd5e1; border-radius:3px; padding:3px 6px; height:28px; width:100%; display:block; outline:none; box-sizing:border-box;" placeholder="e.g. 3500.00"></asp:TextBox>
                                            </div>
                                            <asp:Button ID="btnAddCategoryRate" runat="server" Text="+ Add Rate" CausesValidation="false" OnClick="btnAddCategoryRate_Click" style="font-family:'Inter', sans-serif; font-size:11px; font-weight:700; background-color:#1e3a5f; color:#ffffff; border:1px solid #1e3a5f; border-radius:3px; padding:3px 12px; height:28px; cursor:pointer;" />
                                        </div>
                                    </div>

                                    <!-- Mode 2: Bulk Multi-Select Sub-form -->
                                    <div id="divBulkSelect" style="display:none; background:#ffffff; border:1px solid #bfdbfe; border-radius:4px; padding:8px; margin-bottom:8px;">
                                        <div style="display:grid; grid-template-columns:1fr 1fr; gap:8px; margin-bottom:6px;">
                                            <div>
                                                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:2px;">
                                                    <label style="font-size:10px; font-weight:700; color:#1e3a5f;">Categories</label>
                                                    <a href="javascript:void(0);" onclick="toggleAllCbl('cblCategories');" style="font-size:9.5px; color:#1e3a5f; font-weight:700; text-decoration:underline;">Toggle All</a>
                                                </div>
                                                <div style="max-height:100px; overflow-y:auto; border:1px solid #cbd5e1; border-radius:3px; padding:4px; background:#f8fafc;">
                                                    <asp:CheckBoxList ID="cblCategories" runat="server" RepeatLayout="Flow" style="font-size:10.5px; font-weight:600; color:#334155;" />
                                                </div>
                                            </div>
                                            <div>
                                                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:2px;">
                                                    <label style="font-size:10px; font-weight:700; color:#1e3a5f;">Membership Types</label>
                                                    <a href="javascript:void(0);" onclick="toggleAllCbl('cblMembershipTypes');" style="font-size:9.5px; color:#1e3a5f; font-weight:700; text-decoration:underline;">Toggle All</a>
                                                </div>
                                                <div style="max-height:100px; overflow-y:auto; border:1px solid #cbd5e1; border-radius:3px; padding:4px; background:#f8fafc;">
                                                    <asp:CheckBoxList ID="cblMembershipTypes" runat="server" RepeatLayout="Flow" style="font-size:10.5px; font-weight:600; color:#334155;" />
                                                </div>
                                            </div>
                                        </div>

                                        <div style="display:grid; grid-template-columns:1fr auto; gap:6px; align-items:flex-end;">
                                            <div>
                                                <label style="font-size:10px; font-weight:700; color:#1e3a5f; margin-bottom:1px; display:block;">Bulk Amount (PKR)</label>
                                                <asp:TextBox ID="txtBulkRateAmount" runat="server" TextMode="Number" step="0.01" style="font-family:'Inter', sans-serif; font-size:11px; font-weight:700; color:#0f172a; background:#ffffff; border:1px solid #cbd5e1; border-radius:3px; padding:3px 6px; height:28px; width:100%; display:block; outline:none; box-sizing:border-box;" placeholder="Rate for all selected"></asp:TextBox>
                                            </div>
                                            <asp:Button ID="btnBulkAddCategoryRates" runat="server" Text="+ Add Selected" CausesValidation="false" OnClick="btnBulkAddCategoryRates_Click" style="font-family:'Inter', sans-serif; font-size:11px; font-weight:700; background-color:#059669; color:#ffffff; border:1px solid #059669; border-radius:3px; padding:3px 10px; height:28px; cursor:pointer;" />
                                        </div>
                                    </div>

                                    <!-- Configured Rates GridView -->
                                    <div style="font-size:10.5px; font-weight:800; color:#1e3a5f; margin-bottom:3px; display:flex; justify-content:space-between; align-items:center;">
                                        <span>Configured Rates (<asp:Literal ID="litCategoryRateCount" runat="server" Text="0"></asp:Literal>)</span>
                                        <asp:LinkButton ID="btnClearAllRates" runat="server" OnClick="btnClearAllCategoryRates_Click" CausesValidation="false" style="font-size:9.5px; color:#ef4444; font-weight:700; text-decoration:none;" OnClientClick="return confirm('Remove all configured rates?');">Clear All</asp:LinkButton>
                                    </div>
                                    <div style="max-height:120px; overflow-y:auto; background:#ffffff; border:1px solid #bfdbfe; border-radius:4px;">
                                        <asp:GridView ID="gvCategoryRates" runat="server" AutoGenerateColumns="False" 
                                            GridLines="None" 
                                            OnRowCommand="gvCategoryRates_RowCommand" 
                                            EmptyDataText="<div style='padding:6px; text-align:center; color:#94a3b8; font-size:10.5px;'>No category/type rates configured yet.</div>"
                                            style="width:100%; border-collapse:collapse; font-size:10.5px;">
                                            <HeaderStyle BackColor="#f8fafc" ForeColor="#1e3a5f" Font-Bold="true" Height="24px" HorizontalAlign="Left" />
                                            <RowStyle BackColor="#ffffff" Height="26px" />
                                            <Columns>
                                                <asp:TemplateField HeaderText="Category">
                                                    <ItemTemplate>
                                                        <span style="font-weight:700; color:#0f2b48;">
                                                            <%# Eval("CategoryName") %>
                                                        </span>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Membership Type">
                                                    <ItemTemplate>
                                                        <span style="font-weight:700; color:#1e3a5f;">
                                                            <%# Eval("MembershipTypeName") %>
                                                        </span>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Amount">
                                                    <ItemTemplate>
                                                        <strong style="color:#059669; font-size:11px;">
                                                            PKR <%# String.Format("{0:N2}", Eval("Amount")) %>
                                                        </strong>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="26px">
                                                    <ItemTemplate>
                                                        <asp:LinkButton ID="btnRemoveRate" runat="server" 
                                                            CommandName="RemoveRate" 
                                                            CommandArgument='<%# Container.DataItemIndex %>' 
                                                            style="color:#ef4444; font-size:14px; font-weight:700; text-decoration:none; cursor:pointer; line-height:1;" 
                                                            ToolTip="Remove Rate" 
                                                            CausesValidation="false">
                                                            &times;
                                                        </asp:LinkButton>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                        </asp:GridView>
                                    </div>
                                </div>
                            </div>

                            <!-- =========================================================
                                 SECTION B: AGE BENEFIT / CONCESSIONS
                            ========================================================= -->
                            <div style="margin-top:8px;">
                                <div style="display:flex; align-items:center; justify-content:space-between; background:#f8fafc; padding:6px 10px; border-radius:4px; border:1px solid #cbd5e1;">
                                    <div style="display:flex; align-items:center; gap:6px;">
                                        <asp:CheckBox ID="chkAgeBenefit" runat="server" ClientIDMode="Static" onclick="toggleAgeBenefitPanel();" style="accent-color:#1e3a5f; cursor:pointer;" />
                                        <label for="chkAgeBenefit" style="margin:0; cursor:pointer; font-weight:800; color:#0f2b48; font-size:11.5px;">
                                            Enable Age Benefit / Concession
                                        </label>
                                    </div>
                                    <span style="background:#fbf8f2; color:#0f2b48; border:1px solid #c5a572; padding:1px 6px; border-radius:10px; font-size:10px; font-weight:700;">
                                        Multi-Tier
                                    </span>
                                </div>

                                <!-- Expandable Age Benefit Multi-Slab Management Panel -->
                                <div id="pnlAgeBenefitRules" style="display:none; background:linear-gradient(135deg, #fbf8f2 0%, #fffbf5 100%); border:1.5px dashed #c5a572; border-radius:6px; padding:10px; margin-top:6px;">
                                    
                                    <!-- Sub-form to Add New Tier -->
                                    <div style="background:#ffffff; border:1px solid #e3d3b7; border-radius:4px; padding:8px; margin-bottom:8px;">
                                        <!-- Tier Title -->
                                        <div style="margin-bottom:6px;">
                                            <label style="font-size:10px; font-weight:700; color:#785a22; margin-bottom:1px; display:block;">Tier Title / Label (Optional)</label>
                                            <asp:TextBox ID="txtTierTitle" runat="server" style="font-family:'Inter', sans-serif; font-size:11px; font-weight:700; color:#0f172a; background:#ffffff; border:1px solid #cbd5e1; border-radius:3px; padding:3px 6px; height:26px; width:100%; display:block; outline:none; box-sizing:border-box;" placeholder="e.g. Senior Tier (65-74 yrs)"></asp:TextBox>
                                        </div>

                                        <!-- Min Age, Max Age, Min Member Yrs Row -->
                                        <div style="display:grid; grid-template-columns:1fr 1fr 1.2fr; gap:6px; margin-bottom:6px;">
                                            <div>
                                                <label style="font-size:10px; font-weight:700; color:#785a22; margin-bottom:1px; display:block;">Min Age</label>
                                                <asp:TextBox ID="txtMinAge" runat="server" ClientIDMode="Static" TextMode="Number" style="font-family:'Inter', sans-serif; font-size:11px; font-weight:700; color:#0f172a; background:#ffffff; border:1px solid #cbd5e1; border-radius:3px; padding:3px 6px; height:26px; width:100%; display:block; outline:none; box-sizing:border-box;" placeholder="65" min="0" max="150" onkeyup="updateLiveDiscountPreview();"></asp:TextBox>
                                            </div>
                                            <div>
                                                <label style="font-size:10px; font-weight:700; color:#785a22; margin-bottom:1px; display:block;">Max Age</label>
                                                <asp:TextBox ID="txtMaxAge" runat="server" ClientIDMode="Static" TextMode="Number" style="font-family:'Inter', sans-serif; font-size:11px; font-weight:700; color:#0f172a; background:#ffffff; border:1px solid #cbd5e1; border-radius:3px; padding:3px 6px; height:26px; width:100%; display:block; outline:none; box-sizing:border-box;" placeholder="74" min="0" max="150" onkeyup="updateLiveDiscountPreview();"></asp:TextBox>
                                            </div>
                                            <div>
                                                <label style="font-size:10px; font-weight:700; color:#785a22; margin-bottom:1px; display:block;">Min Mbr Yrs</label>
                                                <asp:TextBox ID="txtMinMembershipYears" runat="server" ClientIDMode="Static" TextMode="Number" style="font-family:'Inter', sans-serif; font-size:11px; font-weight:700; color:#0f172a; background:#ffffff; border:1px solid #cbd5e1; border-radius:3px; padding:3px 6px; height:26px; width:100%; display:block; outline:none; box-sizing:border-box;" placeholder="15" min="0" max="100"></asp:TextBox>
                                            </div>
                                        </div>

                                        <!-- Discount % and Fixed Row -->
                                        <div style="display:grid; grid-template-columns:1fr 1fr; gap:6px; margin-bottom:6px;">
                                            <div>
                                                <label style="font-size:10px; font-weight:700; color:#785a22; margin-bottom:1px; display:block;">Discount in %</label>
                                                <asp:TextBox ID="txtDiscountPercentage" runat="server" ClientIDMode="Static" TextMode="Number" step="0.01" style="font-family:'Inter', sans-serif; font-size:11px; font-weight:700; color:#0f172a; background:#ffffff; border:1px solid #cbd5e1; border-radius:3px; padding:3px 6px; height:26px; width:100%; display:block; outline:none; box-sizing:border-box;" placeholder="25 %" min="0" max="100" onkeyup="updateLiveDiscountPreview();"></asp:TextBox>
                                            </div>
                                            <div>
                                                <label style="font-size:10px; font-weight:700; color:#785a22; margin-bottom:1px; display:block;">Discount Fixed (PKR)</label>
                                                <asp:TextBox ID="txtDiscountFixed" runat="server" ClientIDMode="Static" TextMode="Number" step="0.01" style="font-family:'Inter', sans-serif; font-size:11px; font-weight:700; color:#0f172a; background:#ffffff; border:1px solid #cbd5e1; border-radius:3px; padding:3px 6px; height:26px; width:100%; display:block; outline:none; box-sizing:border-box;" placeholder="500" min="0" onkeyup="updateLiveDiscountPreview();"></asp:TextBox>
                                            </div>
                                        </div>

                                        <!-- Add Tier Button -->
                                        <div style="text-align:right;">
                                            <asp:Button ID="btnAddTier" runat="server" Text="+ Add Slab" CausesValidation="false" OnClick="btnAddTier_Click" style="font-family:'Inter', sans-serif; font-size:11px; font-weight:700; background-color:#c5a572; color:#0f2b48; border:1px solid #b38e55; border-radius:3px; padding:3px 10px; height:26px; cursor:pointer;" />
                                        </div>
                                    </div>

                                    <!-- Configured Tiers List with Internal Scrollbar -->
                                    <div style="font-size:10.5px; font-weight:800; color:#785a22; margin-bottom:3px; display:flex; justify-content:space-between;">
                                        <span>Configured Slabs (<asp:Literal ID="litTierCount" runat="server" Text="0"></asp:Literal>)</span>
                                    </div>
                                    <div style="max-height:120px; overflow-y:auto; background:#ffffff; border:1px solid #e3d3b7; border-radius:4px;">
                                        <asp:GridView ID="gvBenefitTiers" runat="server" AutoGenerateColumns="False" 
                                            GridLines="None" 
                                            OnRowCommand="gvBenefitTiers_RowCommand" 
                                            EmptyDataText="<div style='padding:6px; text-align:center; color:#94a3b8; font-size:10.5px;'>No slabs configured yet.</div>"
                                            style="width:100%; border-collapse:collapse; font-size:10.5px;">
                                            <HeaderStyle BackColor="#f8fafc" ForeColor="#785a22" Font-Bold="true" Height="24px" HorizontalAlign="Left" />
                                            <RowStyle BackColor="#ffffff" Height="26px" />
                                            <Columns>
                                                <asp:TemplateField HeaderText="Tier / Range">
                                                    <ItemTemplate>
                                                        <span style="font-weight:700; color:#0f2b48;">
                                                            <%# !string.IsNullOrEmpty(Eval("BenefitTitle").ToString()) ? Eval("BenefitTitle") : "Age " + Eval("MinAge") + "-" + Eval("MaxAge") %>
                                                        </span>
                                                        <span style="font-size:9.5px; color:#64748b; margin-left:4px;">
                                                            (Mbr: <%# Eval("MinMembershipYears") %>y)
                                                        </span>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="Discount">
                                                    <ItemTemplate>
                                                        <span style="font-weight:800; color:#1e3a5f;">
                                                            <%# (Convert.ToDecimal(Eval("DiscountPercentage")) > 0 ? Eval("DiscountPercentage") + "% " : "") +
                                                                (Convert.ToDecimal(Eval("DiscountFixed")) > 0 ? "Rs." + String.Format("{0:N0}", Eval("DiscountFixed")) : "") %>
                                                        </span>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField HeaderText="" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="30px">
                                                    <ItemTemplate>
                                                        <asp:LinkButton ID="btnRemoveTier" runat="server" 
                                                            CommandName="RemoveTier" 
                                                            CommandArgument='<%# Container.DataItemIndex %>' 
                                                            style="color:#ef4444; font-size:14px; font-weight:700; text-decoration:none; cursor:pointer; line-height:1;" 
                                                            ToolTip="Remove Slab" 
                                                            CausesValidation="false">
                                                            &times;
                                                        </asp:LinkButton>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                        </asp:GridView>
                                    </div>

                                    <!-- Live Preview -->
                                    <div style="background:#ffffff; border:1px solid #e3d3b7; border-radius:4px; padding:4px 8px; margin-top:6px; display:flex; align-items:center; justify-content:space-between; font-size:10.5px;">
                                        <span style="font-weight:700; color:#0f2b48;">Tier Net Preview:</span>
                                        <div id="lblCalculatedPreview" style="font-weight:800; color:#059669;">
                                            Net: PKR 0.00
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Description / Notes -->
                            <div style="margin-top:6px; margin-bottom:6px;">
                                <label style="font-size:11px; font-weight:700; color:#1e293b; margin-bottom:2px; display:block;">Description / Policy Notes (Optional)</label>
                                <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="1" style="font-family:'Inter', sans-serif; font-size:11px; font-weight:600; color:#0f172a; background-color:#ffffff; border:1px solid #cbd5e1; border-radius:4px; padding:4px 8px; width:100%; display:block; outline:none; resize:none; box-sizing:border-box; height:28px;" placeholder="Add special circular notes or remarks..." MaxLength="500"></asp:TextBox>
                            </div>

                            <!-- Active Checkbox -->
                            <div style="display:flex; align-items:center; gap:6px; margin-bottom:10px;">
                                <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" style="accent-color:#1e3a5f; cursor:pointer;" />
                                <label for="<%= chkIsActive.ClientID %>" style="margin:0; cursor:pointer; font-weight:700; color:#1e293b; font-size:11.5px;">
                                    Active Status (Available for Member Billing)
                                </label>
                            </div>

                            <!-- Action Buttons -->
                            <div style="display:flex; gap:8px; padding-top:8px; border-top:1px solid #cbd5e1;">
                                <asp:Button ID="btnSave" runat="server" Text="Save Subscription" ValidationGroup="vgSubscription" OnClick="btnSave_Click" style="font-family:'Inter', sans-serif; font-size:11.5px; font-weight:700; background-color:#1e3a5f; color:#ffffff; border:1px solid #1e3a5f; border-radius:4px; padding:4px 14px; height:30px; cursor:pointer; box-shadow:0 1px 3px rgba(30,58,95,0.2);" />
                                <asp:Button ID="btnReset" runat="server" Text="Reset Form" CausesValidation="false" OnClick="btnReset_Click" style="font-family:'Inter', sans-serif; font-size:11.5px; font-weight:700; background-color:#e2e8f0; color:#1e293b; border:1px solid #cbd5e1; border-radius:4px; padding:4px 12px; height:30px; cursor:pointer;" />
                                <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel Edit" CausesValidation="false" Visible="false" OnClick="btnCancelEdit_Click" style="font-family:'Inter', sans-serif; font-size:11.5px; font-weight:700; background-color:#ef4444; color:#ffffff; border:1px solid #ef4444; border-radius:4px; padding:4px 12px; height:30px; cursor:pointer;" />
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ============================================
                     RIGHT COLUMN: SUBSCRIPTIONS DIRECTORY & SCROLLABLE GRID
                ============================================ -->
                <div>
                    <!-- Compact Filters Toolbar -->
                    <div style="background:#ffffff; border:1px solid #cbd5e1; border-radius:6px; padding:6px 10px; margin-bottom:8px; display:flex; gap:8px; align-items:flex-end; flex-wrap:wrap; box-shadow:0 1px 3px rgba(0,0,0,0.02);">
                        
                        <div style="flex:1; min-width:140px;">
                            <label style="font-size:10.5px; font-weight:700; color:#1e293b; margin-bottom:1px; display:block;">Search Code / Name</label>
                            <asp:TextBox ID="txtSearchKeyword" runat="server" style="font-family:'Inter', sans-serif; font-size:11.5px; font-weight:700; color:#0f172a; background-color:#ffffff; border:1px solid #cbd5e1; border-radius:4px; padding:3px 6px; height:28px; width:100%; display:block; outline:none; box-sizing:border-box;" placeholder="Search Code, Name, COA..."></asp:TextBox>
                        </div>

                        <div style="min-width:130px;">
                            <label style="font-size:10.5px; font-weight:700; color:#1e293b; margin-bottom:1px; display:block;">Member Category</label>
                            <asp:DropDownList ID="ddlFilterCategory" runat="server" style="font-family:'Inter', sans-serif; font-size:11.5px; font-weight:700; color:#0f172a; background-color:#ffffff; border:1px solid #cbd5e1; border-radius:4px; padding:2px 4px; height:28px; width:100%; display:block; outline:none; box-sizing:border-box;">
                                <asp:ListItem Text="All Categories" Value=""></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div style="min-width:125px;">
                            <label style="font-size:10.5px; font-weight:700; color:#1e293b; margin-bottom:1px; display:block;">Membership Type</label>
                            <asp:DropDownList ID="ddlFilterMembershipType" runat="server" style="font-family:'Inter', sans-serif; font-size:11.5px; font-weight:700; color:#0f172a; background-color:#ffffff; border:1px solid #cbd5e1; border-radius:4px; padding:2px 4px; height:28px; width:100%; display:block; outline:none; box-sizing:border-box;">
                                <asp:ListItem Text="All Types" Value=""></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div style="min-width:130px;">
                            <label style="font-size:10.5px; font-weight:700; color:#1e293b; margin-bottom:1px; display:block;">Financial Head</label>
                            <asp:DropDownList ID="ddlFilterFinancialHead" runat="server" style="font-family:'Inter', sans-serif; font-size:11.5px; font-weight:700; color:#0f172a; background-color:#ffffff; border:1px solid #cbd5e1; border-radius:4px; padding:2px 4px; height:28px; width:100%; display:block; outline:none; box-sizing:border-box;">
                                <asp:ListItem Text="All Heads" Value=""></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div style="min-width:95px;">
                            <label style="font-size:10.5px; font-weight:700; color:#1e293b; margin-bottom:1px; display:block;">Status</label>
                            <asp:DropDownList ID="ddlFilterStatus" runat="server" style="font-family:'Inter', sans-serif; font-size:11.5px; font-weight:700; color:#0f172a; background-color:#ffffff; border:1px solid #cbd5e1; border-radius:4px; padding:2px 4px; height:28px; width:100%; display:block; outline:none; box-sizing:border-box;">
                                <asp:ListItem Text="All" Value="" Selected="True"></asp:ListItem>
                                <asp:ListItem Text="Active" Value="1"></asp:ListItem>
                                <asp:ListItem Text="Inactive" Value="0"></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div style="display:flex; gap:5px;">
                            <asp:Button ID="btnFilter" runat="server" Text="Filter" CausesValidation="false" OnClick="btnFilter_Click" style="font-family:'Inter', sans-serif; font-size:11px; font-weight:700; background-color:#1e3a5f; color:#ffffff; border:1px solid #1e3a5f; border-radius:4px; padding:4px 10px; height:28px; cursor:pointer;" />
                            <asp:Button ID="btnResetFilter" runat="server" Text="Reset" CausesValidation="false" OnClick="btnResetFilter_Click" style="font-family:'Inter', sans-serif; font-size:11px; font-weight:700; background-color:#e2e8f0; color:#1e293b; border:1px solid #cbd5e1; border-radius:4px; padding:4px 10px; height:28px; cursor:pointer;" />
                        </div>
                    </div>

                    <!-- Subscriptions Directory Table Card with Dedicated Grid Scroll -->
                    <div style="background:#ffffff; border-radius:6px; border:1px solid #cbd5e1; box-shadow:0 1px 4px rgba(0,0,0,0.04); overflow:hidden;">
                        
                        <!-- Table Card Header -->
                        <div style="background:linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%); padding:6px 12px; border-bottom:1.5px solid #c5a572; font-weight:800; color:#0f2b48; font-size:12px; display:flex; align-items:center; justify-content:space-between; letter-spacing:0.2px;">
                            <span>
                                Defined Subscriptions (<asp:Literal ID="litRecordCount" runat="server" Text="0"></asp:Literal>)
                            </span>

                            <button type="button" style="font-family:'Inter', sans-serif; font-size:10.5px; font-weight:700; background-color:#e2e8f0; color:#1e293b; border:1px solid #cbd5e1; border-radius:3px; padding:2px 8px; height:24px; cursor:pointer;" onclick="window.print();">
                                Print
                            </button>
                        </div>

                        <!-- Dedicated Scrollable Grid Container with Sticky Header -->
                        <div class="gym-grid-scroll-container" style="padding:0; max-height:calc(100vh - 205px); min-height:340px; overflow-y:auto; overflow-x:auto; position:relative; background:#ffffff;">
                            <asp:GridView ID="gvSubscriptions" runat="server" AutoGenerateColumns="False" 
                                GridLines="None" 
                                DataKeyNames="SubscriptionID" 
                                OnRowCommand="gvSubscriptions_RowCommand" 
                                EmptyDataText="<div style='padding:16px; text-align:center; color:#64748b; font-weight:600; font-size:11.5px;'>No subscription packages found matching your criteria.</div>"
                                style="width:100%; border-collapse:collapse; font-size:11.5px; background:#ffffff;">
                                
                                <HeaderStyle BackColor="#1e3a5f" ForeColor="#ffffff" Font-Bold="true" Height="30px" HorizontalAlign="Left" />
                                <RowStyle BackColor="#ffffff" Height="30px" />
                                <AlternatingRowStyle BackColor="#f8fafc" Height="30px" />
                                
                                <Columns>
                                    <asp:TemplateField HeaderText="ID / Code" ItemStyle-Width="75px" ItemStyle-HorizontalAlign="Center" ItemStyle-CssClass="cell-pad">
                                        <ItemTemplate>
                                            <span style="font-family:'Inter', sans-serif; font-weight:800; color:#1e3a5f; background:#e8f0fe; border:1px solid #bfdbfe; padding:2px 6px; border-radius:3px; font-size:10px;">
                                                <%# Eval("SubscriptionCode") %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Subscription Name & Financial Head" ItemStyle-CssClass="cell-pad">
                                        <ItemTemplate>
                                            <div style="font-weight:700; color:#1e3a5f; font-size:12px; line-height:1.2;">
                                                <%# Eval("SubscriptionName") %>
                                            </div>
                                            <div style="font-size:10px; color:#64748b; margin-top:1px;">
                                                <%# Eval("FinancialHeadName") != null && !string.IsNullOrEmpty(Eval("FinancialHeadName").ToString()) ? Eval("FinancialHeadName") : "Not Linked" %>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Base Amount" ItemStyle-CssClass="cell-pad" ItemStyle-Width="105px">
                                        <ItemTemplate>
                                            <div style="font-weight:800; color:#0f2b48; font-size:12px;">
                                                PKR <%# String.Format("{0:N2}", Eval("Amount")) %>
                                            </div>
                                            <%# Convert.ToBoolean(Eval("HasCategoryRates")) ? 
                                                "<div style='font-size:9.5px; color:#0369a1; font-weight:700; margin-top:1px;'>&#9679; Differential Rates</div>" : "" %>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Category & Type Rates" ItemStyle-CssClass="cell-pad">
                                        <ItemTemplate>
                                            <%# Convert.ToBoolean(Eval("HasCategoryRates")) ? 
                                                GetFormattedCategoryRates(Eval("SubscriptionID")) : 
                                                "<span style='color:#94a3b8; font-size:10px; font-weight:600;'>Standard Rate</span>" %>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Age Benefit Slabs" ItemStyle-CssClass="cell-pad">
                                        <ItemTemplate>
                                            <%# Convert.ToBoolean(Eval("HasAgeBenefit")) ? 
                                                GetFormattedAgeBenefitTiers(Eval("SubscriptionID")) : 
                                                "<span style='color:#94a3b8; font-size:10px; font-weight:600;'>Standard Rate</span>" %>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Status" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="65px" ItemStyle-CssClass="cell-pad">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnToggleStatus" runat="server" 
                                                CommandName="ToggleStatus" 
                                                CommandArgument='<%# Eval("SubscriptionID") %>' 
                                                CausesValidation="false"
                                                style="text-decoration:none;"
                                                ToolTip="Click to toggle status">
                                                <%# Convert.ToBoolean(Eval("IsActive")) ? 
                                                    "<span style='background:#d1fae5; color:#065f46; border:1px solid #a7f3d0; padding:1px 6px; border-radius:10px; font-size:10px; font-weight:700; display:inline-flex; align-items:center; gap:2px;'>Active</span>" : 
                                                    "<span style='background:#fee2e2; color:#991b1b; border:1px solid #fecaca; padding:1px 6px; border-radius:10px; font-size:10px; font-weight:700; display:inline-flex; align-items:center; gap:2px;'>Inactive</span>" %>
                                            </asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="50px" ItemStyle-CssClass="cell-pad">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnEdit" runat="server" 
                                                CommandName="EditRecord" 
                                                CommandArgument='<%# Eval("SubscriptionID") %>' 
                                                style="font-family:'Inter', sans-serif; font-size:10.5px; font-weight:700; background-color:#1e3a5f; color:#ffffff; border:1px solid #1e3a5f; border-radius:3px; padding:2px 8px; text-decoration:none; cursor:pointer;" 
                                                ToolTip="Edit Subscription" 
                                                CausesValidation="false">
                                                Edit
                                            </asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>

        </ContentTemplate>
    </asp:UpdatePanel>

    <style>
        .cell-pad {
            padding: 4px 8px !important;
            border-bottom: 1px solid #e2e8f0 !important;
            border-right: 1px solid #f1f5f9 !important;
            vertical-align: middle !important;
            font-weight: 600 !important;
        }
        
        /* Sticky Table Header for GridView */
        #<%= gvSubscriptions.ClientID %> th {
            position: sticky !important;
            top: 0 !important;
            z-index: 10 !important;
            background-color: #1e3a5f !important;
            color: #ffffff !important;
            padding: 6px 8px !important;
            border: none !important;
            font-size: 10.5px !important;
            text-transform: uppercase !important;
            letter-spacing: 0.4px !important;
            box-shadow: 0 2px 4px rgba(0,0,0,0.12) !important;
        }

        #<%= gvSubscriptions.ClientID %> tr:hover {
            background-color: #e8f0fe !important;
        }

        /* Custom Scrollbar for Grid Container */
        .gym-grid-scroll-container {
            scrollbar-width: thin;
            scrollbar-color: #cbd5e1 #f8fafc;
        }

        .gym-grid-scroll-container::-webkit-scrollbar {
            width: 6px;
            height: 6px;
        }
        .gym-grid-scroll-container::-webkit-scrollbar-track {
            background: #f8fafc;
        }
        .gym-grid-scroll-container::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 3px;
        }

        /* Auto-Extender Styling */
        .gym-autoextender {
            position: absolute !important;
            top: 33px !important;
            left: 0 !important;
            right: 0 !important;
            max-height: 200px !important;
            overflow-y: auto !important;
            background: #ffffff !important;
            border: 1.5px solid #1e3a5f !important;
            border-radius: 4px !important;
            box-shadow: 0 10px 25px rgba(15, 23, 42, 0.2) !important;
            z-index: 99999 !important;
            padding: 2px 0 !important;
            scrollbar-width: thin;
            scrollbar-color: #cbd5e1 #f8fafc;
        }

        .gym-autoextender-item {
            padding: 5px 10px !important;
            display: flex !important;
            align-items: center !important;
            justify-content: space-between !important;
            gap: 6px !important;
            cursor: pointer !important;
            font-size: 11.5px !important;
            font-weight: 600 !important;
            color: #1e293b !important;
            border-bottom: 1px solid #f1f5f9 !important;
            transition: background 0.1s ease, color 0.1s ease !important;
        }

        .gym-autoextender-item:last-child {
            border-bottom: none !important;
        }

        .gym-autoextender-item:hover,
        .gym-autoextender-item.active {
            background: #1e3a5f !important;
            color: #ffffff !important;
        }

        .gym-autoextender-item:hover .gym-code-badge,
        .gym-autoextender-item.active .gym-code-badge {
            background: #c5a572 !important;
            color: #0f2b48 !important;
            border-color: #b38e55 !important;
        }

        .gym-code-badge {
            font-family: 'Inter', sans-serif !important;
            font-size: 10px !important;
            font-weight: 800 !important;
            background: #e8f0fe !important;
            color: #1e3a5f !important;
            border: 1px solid #bfdbfe !important;
            padding: 1px 5px !important;
            border-radius: 3px !important;
            letter-spacing: 0.3px !important;
            display: inline-block !important;
            flex-shrink: 0 !important;
        }

        .gym-head-title {
            flex: 1 !important;
            white-space: nowrap !important;
            overflow: hidden !important;
            text-overflow: ellipsis !important;
            text-align: left !important;
        }
    </style>

    <!-- Client-side Interactive Scripts -->
    <script type="text/javascript">
        var headData = [];
        var activeHeadIndex = -1;

        function getHeadData() {
            var hf = document.getElementById('hfFinancialHeadsJson');
            if (hf && hf.value) {
                try {
                    headData = JSON.parse(hf.value);
                } catch (e) {
                    headData = [];
                }
            }
            return headData;
        }

        function showHeadAutoExtender() {
            filterHeadAutoExtender();
        }

        function toggleHeadDropdown(e) {
            if (e) {
                e.stopPropagation();
                e.preventDefault();
            }
            var pnl = document.getElementById('pnlHeadAutoExtender');
            if (!pnl) return;
            if (pnl.style.display === 'block') {
                pnl.style.display = 'none';
            } else {
                renderHeadOptions('', true);
            }
        }

        function filterHeadAutoExtender() {
            var txt = document.getElementById('txtFinancialHead');
            if (!txt) return;
            var q = txt.value.trim().toLowerCase();
            renderHeadOptions(q, false);
        }

        function renderHeadOptions(query, showAll) {
            var list = document.getElementById('headAutoExtenderList');
            var pnl = document.getElementById('pnlHeadAutoExtender');
            if (!list || !pnl) return;

            var items = getHeadData();
            var filtered = [];

            if (showAll || !query) {
                filtered = items;
            } else {
                filtered = items.filter(function(item) {
                    var c = (item.code || '').toLowerCase();
                    var n = (item.name || '').toLowerCase();
                    var full = (item.display || '').toLowerCase();
                    return c.indexOf(query) !== -1 || n.indexOf(query) !== -1 || full.indexOf(query) !== -1;
                });
            }

            if (filtered.length === 0) {
                list.innerHTML = "<div style='padding:8px 12px; color:#94a3b8; font-size:11px; font-weight:600; text-align:center;'>No matching heads found</div>";
                pnl.style.display = 'block';
                return;
            }

            var html = '';
            for (var i = 0; i < filtered.length; i++) {
                var itm = filtered[i];
                var code = escapeHtml(itm.code || '');
                var name = escapeHtml(itm.name || '');
                var val = escapeHtml(itm.display || (code + ' - ' + name));

                html += '<div class="gym-autoextender-item" data-val="' + val + '" onclick="selectHeadItem(this);">' +
                            '<span class="gym-head-title">' + name + '</span>' +
                            '<span class="gym-code-badge">' + code + '</span>' +
                        '</div>';
            }

            list.innerHTML = html;
            pnl.style.display = 'block';
            activeHeadIndex = -1;
        }

        function selectHeadItem(el) {
            var val = el.getAttribute('data-val');
            var txt = document.getElementById('txtFinancialHead');
            var pnl = document.getElementById('pnlHeadAutoExtender');
            if (txt && val) txt.value = val;
            if (pnl) pnl.style.display = 'none';
        }

        function navigateHeadAutoExtender(e) {
            var pnl = document.getElementById('pnlHeadAutoExtender');
            if (!pnl || pnl.style.display !== 'block') return;

            var items = pnl.querySelectorAll('.gym-autoextender-item');
            if (items.length === 0) return;

            if (e.key === 'ArrowDown') {
                e.preventDefault();
                activeHeadIndex = (activeHeadIndex + 1) % items.length;
                updateActiveHeadItem(items);
            } else if (e.key === 'ArrowUp') {
                e.preventDefault();
                activeHeadIndex = (activeHeadIndex - 1 + items.length) % items.length;
                updateActiveHeadItem(items);
            } else if (e.key === 'Enter') {
                if (activeHeadIndex >= 0 && activeHeadIndex < items.length) {
                    e.preventDefault();
                    items[activeHeadIndex].click();
                }
            } else if (e.key === 'Escape') {
                pnl.style.display = 'none';
            }
        }

        function updateActiveHeadItem(items) {
            for (var i = 0; i < items.length; i++) {
                if (i === activeHeadIndex) {
                    items[i].classList.add('active');
                    items[i].scrollIntoView({ block: 'nearest' });
                } else {
                    items[i].classList.remove('active');
                }
            }
        }

        function escapeHtml(str) {
            if (!str) return '';
            return str.replace(/&/g, '&amp;')
                      .replace(/</g, '&lt;')
                      .replace(/>/g, '&gt;')
                      .replace(/"/g, '&quot;')
                      .replace(/'/g, '&#039;');
        }

        // Close AutoExtender when clicking outside
        document.addEventListener('click', function(e) {
            var pnl = document.getElementById('pnlHeadAutoExtender');
            var txt = document.getElementById('txtFinancialHead');
            if (pnl && txt) {
                if (!pnl.contains(e.target) && !txt.contains(e.target)) {
                    pnl.style.display = 'none';
                }
            }
        });

        // Toggle Category Pricing Panel
        function toggleCategoryPricingPanel() {
            var chk = document.getElementById('chkCategoryPricing');
            var panel = document.getElementById('pnlCategoryPricing');
            if (chk && panel) {
                panel.style.display = chk.checked ? 'block' : 'none';
            }
        }

        // Switch Quick vs Bulk mode
        function switchCategoryMode(mode) {
            var divQuick = document.getElementById('divQuickSelect');
            var divBulk = document.getElementById('divBulkSelect');
            var btnQuick = document.getElementById('btnTabQuick');
            var btnBulk = document.getElementById('btnTabBulk');
            if (mode === 'bulk') {
                if (divQuick) divQuick.style.display = 'none';
                if (divBulk) divBulk.style.display = 'block';
                if (btnQuick) {
                    btnQuick.style.background = '#ffffff';
                    btnQuick.style.color = '#475569';
                    btnQuick.style.borderColor = '#cbd5e1';
                    btnQuick.style.fontWeight = '700';
                }
                if (btnBulk) {
                    btnBulk.style.background = '#1e3a5f';
                    btnBulk.style.color = '#ffffff';
                    btnBulk.style.borderColor = '#1e3a5f';
                    btnBulk.style.fontWeight = '800';
                }
            } else {
                if (divQuick) divQuick.style.display = 'block';
                if (divBulk) divBulk.style.display = 'none';
                if (btnQuick) {
                    btnQuick.style.background = '#1e3a5f';
                    btnQuick.style.color = '#ffffff';
                    btnQuick.style.borderColor = '#1e3a5f';
                    btnQuick.style.fontWeight = '800';
                }
                if (btnBulk) {
                    btnBulk.style.background = '#ffffff';
                    btnBulk.style.color = '#475569';
                    btnBulk.style.borderColor = '#cbd5e1';
                    btnBulk.style.fontWeight = '700';
                }
            }
        }

        function toggleAllCbl(cblId) {
            var container = document.getElementById('<%= cblCategories.ClientID %>');
            if (cblId === 'cblMembershipTypes') {
                container = document.getElementById('<%= cblMembershipTypes.ClientID %>');
            }
            if (!container) return;
            var checkboxes = container.getElementsByTagName('input');
            var allChecked = true;
            for (var i = 0; i < checkboxes.length; i++) {
                if (!checkboxes[i].checked) { allChecked = false; break; }
            }
            for (var i = 0; i < checkboxes.length; i++) {
                checkboxes[i].checked = !allChecked;
            }
        }

        // Toggle Age Benefit Panel
        function toggleAgeBenefitPanel() {
            var chk = document.getElementById('chkAgeBenefit');
            var panel = document.getElementById('pnlAgeBenefitRules');
            if (chk && panel) {
                panel.style.display = chk.checked ? 'block' : 'none';
            }
            updateLiveDiscountPreview();
        }

        function updateLiveDiscountPreview() {
            var txtAmount = document.getElementById('<%= txtAmount.ClientID %>');
            var chkAge = document.getElementById('chkAgeBenefit');
            var txtDiscPct = document.getElementById('txtDiscountPercentage');
            var txtDiscFixed = document.getElementById('txtDiscountFixed');
            var lblPreview = document.getElementById('lblCalculatedPreview');

            if (!txtAmount || !lblPreview) return;

            var baseAmount = parseFloat(txtAmount.value) || 0;
            if (baseAmount <= 0) {
                lblPreview.innerHTML = "Net: PKR 0.00";
                return;
            }

            if (!chkAge || !chkAge.checked) {
                lblPreview.innerHTML = "Base Amount: PKR " + baseAmount.toFixed(2);
                return;
            }

            var discPct = parseFloat(txtDiscPct ? txtDiscPct.value : 0) || 0;
            var discFixed = parseFloat(txtDiscFixed ? txtDiscFixed.value : 0) || 0;

            var pctDeduction = (baseAmount * discPct) / 100.0;
            var totalDeduction = pctDeduction + discFixed;
            var netAmount = Math.max(0, baseAmount - totalDeduction);

            lblPreview.innerHTML = "Base: " + baseAmount.toFixed(2) + " - Disc: " + totalDeduction.toFixed(2) + " = <strong style='color:#059669; font-size:11.5px;'>Net: PKR " + netAmount.toFixed(2) + "</strong>";
        }

        // Initialize state on page load
        document.addEventListener('DOMContentLoaded', function () {
            toggleCategoryPricingPanel();
            toggleAgeBenefitPanel();
            updateLiveDiscountPreview();
        });

        // Sys.WebForms partial postback handler
        if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                toggleCategoryPricingPanel();
                toggleAgeBenefitPanel();
                updateLiveDiscountPreview();
            });
        }
    </script>
</asp:Content>
