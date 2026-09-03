<%@ Page Title="Discount Policy Management" Language="C#" MasterPageFile="~/Sports_Management/SiteSports.master" AutoEventWireup="true" CodeFile="DiscountPolicy.aspx.cs" Inherits="DiscountPolicy" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="page-header-card">
        <h2><i class="fas fa-percent" style="margin-right:10px;"></i> Discount Policy Management</h2>
        <span class="badge">Dynamic Rules for Monthly & Continuous Subscriptions</span>
    </div>

    <!-- Alert Message -->
    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert" style="display:block; margin-bottom: 20px; padding: 15px; border-radius: 8px; font-weight: bold;"></asp:Label>

    <div style="display:flex; gap:20px; flex-wrap:wrap;">
        
        <!-- Add/Edit Discount Policy Card -->
        <div class="card" style="flex:1; min-width:320px;">
            <div class="card-header">
                <asp:Literal ID="litFormTitle" runat="server" Text="Add / Edit Discount Policy"></asp:Literal>
            </div>
            <div class="card-body">
                <asp:HiddenField ID="hfPolicyID" runat="server" />
                
                <div class="form-group">
                    <label>Policy Name</label>
                    <asp:TextBox ID="txtPolicyName" runat="server" CssClass="form-control" placeholder="e.g. Senior Citizen Discount"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Discount Percentage (%)</label>
                    <asp:TextBox ID="txtDiscountPercentage" runat="server" CssClass="form-control" TextMode="Number" step="0.01" placeholder="e.g. 50.00"></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <label>Minimum Age (Years)</label>
                    <asp:TextBox ID="txtMinAge" runat="server" CssClass="form-control" TextMode="Number" placeholder="Leave blank if not applicable (e.g. 65)"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Minimum Membership (Years)</label>
                    <asp:TextBox ID="txtMinMembershipYears" runat="server" CssClass="form-control" TextMode="Number" placeholder="Leave blank if not applicable (e.g. 30)"></asp:TextBox>
                </div>

                <div class="form-group" style="display:flex; align-items:center; gap: 10px; margin-top: 10px;">
                    <asp:CheckBox ID="chkIsChild" runat="server" />
                    <label style="margin:0;">Applies to Dependent Child Only</label>
                </div>

                <div class="form-group" style="margin-top: 15px;">
                    <label>Condition Match Logic</label>
                    <asp:DropDownList ID="ddlConditionOperator" runat="server" CssClass="form-control">
                        <asp:ListItem Text="OR (Any condition matches)" Value="OR" Selected="True"></asp:ListItem>
                        <asp:ListItem Text="AND (All specified conditions must match)" Value="AND"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="form-group" style="display:flex; align-items:center; gap: 10px; margin-top: 15px;">
                    <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" />
                    <label style="margin:0;">Active Status</label>
                </div>
                
                <div style="margin-top:20px; display:flex; gap:10px;">
                    <asp:Button ID="btnSave" runat="server" Text="Save Policy" CssClass="btn btn-primary" OnClick="btnSave_Click" />
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn" style="background:var(--gray-300); color:var(--gray-800);" OnClick="btnCancel_Click" Visible="false" />
                </div>
            </div>
        </div>

        <!-- List of Discount Policies Card -->
        <div class="card" style="flex:2; min-width:480px;">
            <div class="card-header">Configured Discount Policies</div>
            <div class="card-body" style="padding:0; overflow-x:auto;">
                <asp:GridView ID="gvPolicies" runat="server" AutoGenerateColumns="False" CssClass="grid-view" GridLines="None" OnRowCommand="gvPolicies_RowCommand" DataKeyNames="PolicyID">
                    <Columns>
                        <asp:BoundField DataField="PolicyID" HeaderText="ID" />
                        <asp:BoundField DataField="PolicyName" HeaderText="Policy Name" />
                        <asp:TemplateField HeaderText="Discount (%)">
                            <ItemTemplate>
                                <strong style="color: var(--primary); font-size: 1.05em;"><%# Eval("DiscountPercentage", "{0:N2}") %>%</strong>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Conditions">
                            <ItemTemplate>
                                <span style="font-size: 0.9em; color: var(--gray-700);">
                                    <%# GetConditionSummary(Eval("MinAge"), Eval("MinMembershipYears"), Eval("IsChild"), Eval("ConditionOperator")) %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span style='<%# Convert.ToBoolean(Eval("IsActive")) ? "color:var(--success);font-weight:bold;" : "color:var(--danger);font-weight:bold;" %>'>
                                    <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Action">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditPolicy" CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn" style="background:var(--secondary-light); color:var(--primary); padding:5px 10px; font-size:12px;">
                                    <i class="fas fa-edit"></i> Edit
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

    </div>

</asp:Content>
