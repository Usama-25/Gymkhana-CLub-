<%@ Page Title="Subscription Definition" Language="C#" MasterPageFile="~/Sports_Management/SiteSports.master" AutoEventWireup="true" CodeFile="SubscriptionDefinition.aspx.cs" Inherits="SubscriptionDefinition" %>


<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="page-header-card">
        <h2><i class="fas fa-tags" style="margin-right:10px;"></i> Daily (POS) Packages</h2>
        <span class="badge">Define Daily POS Rates</span>
    </div>

    <!-- Alert Message -->
    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert" style="display:block; margin-bottom: 20px; padding: 15px; border-radius: 8px; font-weight: bold;"></asp:Label>

    <div style="display:flex; gap:20px; flex-wrap:wrap;">
        
        <!-- Add New Subscription Card -->
        <div class="card" style="flex:1; min-width:320px;">
            <div class="card-header">New Daily (POS) Package</div>
            <div class="card-body">
                
                <div class="form-group">
                    <label>Select Department</label>
                    <asp:HiddenField ID="hfSubscriptionID" runat="server" />
                    <asp:DropDownList ID="ddlSports" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlSports_SelectedIndexChanged">
                    </asp:DropDownList>
                </div>
                
                <div class="form-group">
                    <label>Package Name</label>
                    <asp:TextBox ID="txtPackageName" runat="server" CssClass="form-control" placeholder="e.g. Golf Daily Guest"></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <label>Subscription Type</label>
                    <asp:DropDownList ID="ddlSubType" runat="server" CssClass="form-control" Enabled="false" style="background-color: #f1f5f9; cursor: not-allowed;">
                        <asp:ListItem Text="Daily (POS)" Value="Daily" Selected="True"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="form-group">
                    <label>Fee Amount (PKR)</label>
                    <asp:TextBox ID="txtFee" runat="server" CssClass="form-control" TextMode="Number" placeholder="0.00"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label style="font-weight:700;">Rate Mode (POS Grid Editing)</label>
                    <asp:RadioButtonList ID="rdoRateMode" runat="server" RepeatDirection="Horizontal" style="display:flex; gap:15px; margin-top:4px;">
                        <asp:ListItem Text="Editable (Can change rate in POS)" Value="1" Selected="True"></asp:ListItem>
                        <asp:ListItem Text="Fixed (Rate is fixed in POS)" Value="0"></asp:ListItem>
                    </asp:RadioButtonList>
                </div>
                
                <div class="form-group" style="display:flex; align-items:center; gap: 10px;">
                    <asp:CheckBox ID="chkStatus" runat="server" Checked="true" />
                    <label style="margin:0;">Active Status</label>
                </div>
                
                
                <div style="margin-top:20px; display:flex; gap:10px;">
                    <asp:Button ID="btnSave" runat="server" Text="Save Package" CssClass="btn btn-primary" OnClick="btnSave_Click" />
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn" style="background:var(--gray-300); color:var(--gray-800);" OnClick="btnCancel_Click" Visible="false" />
                </div>
                
                <hr style="margin: 30px 0; border-color: var(--gray-200);" />
                
                <h4 style="color: var(--primary); font-weight: bold; margin-bottom: 15px;"><i class="fas fa-credit-card" style="margin-right: 8px;"></i>New Bank Card Definition</h4>
                
                <div class="form-group">
                    <label>Bank Name</label>
                    <asp:HiddenField ID="hfBankID" runat="server" />
                    <asp:TextBox ID="txtBankName" runat="server" CssClass="form-control" placeholder="e.g. Meezan Bank"></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <label>Discount Percentage (%)</label>
                    <asp:TextBox ID="txtBankDiscount" runat="server" CssClass="form-control" TextMode="Number" step="0.01" placeholder="e.g. 10.00"></asp:TextBox>
                </div>
                
                <div class="form-group" style="display:flex; align-items:center; gap: 10px;">
                    <asp:CheckBox ID="chkBankActive" runat="server" Checked="true" />
                    <label style="margin:0;">Active Status</label>
                </div>
                
                <div style="margin-top:20px; display:flex; gap:10px;">
                    <asp:Button ID="btnSaveBank" runat="server" Text="Save Bank" CssClass="btn btn-primary" OnClick="btnSaveBank_Click" />
                    <asp:Button ID="btnCancelBank" runat="server" Text="Cancel" CssClass="btn" style="background:var(--gray-300); color:var(--gray-800);" OnClick="btnCancelBank_Click" Visible="false" />
                </div>
                
                <hr style="margin: 30px 0; border-color: var(--gray-200);" />

                <h4 style="color: var(--primary); font-weight: bold; margin-bottom: 15px;"><i class="fas fa-list" style="margin-right: 8px;"></i>Configured Bank Cards</h4>
                <div style="overflow-x:auto;">
                    <asp:GridView ID="gvBankCards" runat="server" AutoGenerateColumns="False" CssClass="grid-view" GridLines="None" OnRowCommand="gvBankCards_RowCommand" DataKeyNames="BankID">
                        <Columns>
                            <asp:BoundField DataField="BankID" HeaderText="ID" />
                            <asp:BoundField DataField="BankName" HeaderText="Bank Name" />
                            <asp:BoundField DataField="DiscountPercentage" HeaderText="Disc (%)" DataFormatString="{0:N2}" />
                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <span style='<%# Convert.ToBoolean(Eval("IsActive")) ? "color:var(--success);font-weight:bold;" : "color:var(--danger);font-weight:bold;" %>'>
                                        <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Action">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkEditBank" runat="server" CommandName="EditBank" CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn" style="background:var(--secondary-light); color:var(--primary); padding:5px 10px; font-size:12px;">
                                        <i class="fas fa-edit"></i> Edit
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>

                <hr style="margin: 30px 0; border-color: var(--gray-200);" />

                <h4 style="color: var(--primary); font-weight: bold; margin-bottom: 15px;"><i class="fas fa-box" style="margin-right: 8px;"></i>New Locker Definition</h4>
                
                <div class="form-group">
                    <label>Locker Name</label>
                    <asp:HiddenField ID="hfLockerID" runat="server" />
                    <asp:TextBox ID="txtLockerName" runat="server" CssClass="form-control" placeholder="e.g. Standard Locker"></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <label>Locker Fee (PKR)</label>
                    <asp:TextBox ID="txtLockerFee" runat="server" CssClass="form-control" TextMode="Number" step="0.01" placeholder="e.g. 500.00"></asp:TextBox>
                </div>
                
                <div class="form-group" style="display:flex; align-items:center; gap: 10px;">
                    <asp:CheckBox ID="chkLockerActive" runat="server" Checked="true" />
                    <label style="margin:0;">Active Status</label>
                </div>
                
                <div style="margin-top:20px; display:flex; gap:10px;">
                    <asp:Button ID="btnSaveLocker" runat="server" Text="Save Locker" CssClass="btn btn-primary" OnClick="btnSaveLocker_Click" />
                    <asp:Button ID="btnCancelLocker" runat="server" Text="Cancel" CssClass="btn" style="background:var(--gray-300); color:var(--gray-800);" OnClick="btnCancelLocker_Click" Visible="false" />
                </div>
                
                <hr style="margin: 30px 0; border-color: var(--gray-200);" />

                <h4 style="color: var(--primary); font-weight: bold; margin-bottom: 15px;"><i class="fas fa-list" style="margin-right: 8px;"></i>Configured Lockers</h4>
                <div style="overflow-x:auto;">
                    <asp:GridView ID="gvLockers" runat="server" AutoGenerateColumns="False" CssClass="grid-view" GridLines="None" OnRowCommand="gvLockers_RowCommand" DataKeyNames="LockerID">
                        <Columns>
                            <asp:BoundField DataField="LockerID" HeaderText="ID" />
                            <asp:BoundField DataField="LockerName" HeaderText="Locker Name" />
                            <asp:BoundField DataField="Fee" HeaderText="Fee (PKR)" DataFormatString="{0:N2}" />
                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <span style='<%# Convert.ToBoolean(Eval("IsActive")) ? "color:var(--success);font-weight:bold;" : "color:var(--danger);font-weight:bold;" %>'>
                                        <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Action">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkEditLocker" runat="server" CommandName="EditLocker" CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn" style="background:var(--secondary-light); color:var(--primary); padding:5px 10px; font-size:12px;">
                                        <i class="fas fa-edit"></i> Edit
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>

            </div>
        </div>

        <!-- List of Subscriptions Card -->
        <div class="card" style="flex:2; min-width:500px;">
            <div class="card-header">Available Daily (POS) Packages</div>
            <div class="card-body" style="padding:0; overflow-x:auto;">
                <asp:GridView ID="gvSubscriptions" runat="server" AutoGenerateColumns="False" CssClass="grid-view" GridLines="None" OnRowCommand="gvSubscriptions_RowCommand" DataKeyNames="SubscriptionID,SportID,DepartmentID,PolicyIDs,IsEditable">
                    <Columns>
                        <asp:BoundField DataField="SubscriptionID" HeaderText="ID" />
                        <asp:BoundField DataField="DepartmentName" HeaderText="Department" />
                        <asp:BoundField DataField="ItemCode" HeaderText="Item Code" />
                        <asp:BoundField DataField="PackageName" HeaderText="Package Name" />
                        <asp:BoundField DataField="SubscriptionType" HeaderText="Type" />
                        <asp:BoundField DataField="Fee" HeaderText="Fee (PKR)" DataFormatString="{0:N2}" />
                        <asp:TemplateField HeaderText="Rate Mode">
                            <ItemTemplate>
                                <span style='<%# Eval("IsEditable") != DBNull.Value && Convert.ToBoolean(Eval("IsEditable")) ? "color:#0284c7;font-weight:bold;" : "color:#64748b;font-weight:bold;" %>'>
                                    <%# Eval("IsEditable") != DBNull.Value && Convert.ToBoolean(Eval("IsEditable")) ? "Editable" : "Fixed" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span style='<%# Convert.ToBoolean(Eval("Status")) ? "color:var(--success);font-weight:bold;" : "color:var(--danger);font-weight:bold;" %>'>
                                    <%# Convert.ToBoolean(Eval("Status")) ? "Active" : "Inactive" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditSub" CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn" style="background:var(--secondary-light); color:var(--primary); padding:5px 10px; font-size:12px;">
                                    <i class="fas fa-edit"></i> Edit
                                </asp:LinkButton>
                                <asp:LinkButton ID="lnkDelete" runat="server" CommandName="DeleteSub" CommandArgument='<%# Container.DataItemIndex %>' OnClientClick="return confirm('Are you sure you want to delete this subscription package?');" CssClass="btn" style="background:#fee2e2; color:#dc2626; padding:5px 10px; font-size:12px; margin-left:5px;">
                                    <i class="fas fa-trash-alt"></i> Delete
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

    </div>

</asp:Content>

