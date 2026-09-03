<%@ Control Language="C#" AutoEventWireup="true" CodeFile="MemberSubscriptionInfo.ascx.cs" Inherits="MemberSubscriptionInfo" %>

<style>
    .global-sub-card {
        background: white;
        border: 1px solid var(--gray-200);
        border-radius: 8px;
        padding: 15px;
        margin-top: 15px;
        margin-bottom: 20px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.05);
    }
    .global-sub-card h3 {
        color: var(--primary-dark);
        margin-bottom: 15px;
        font-size: 16px;
        border-bottom: 2px solid var(--primary-light);
        padding-bottom: 8px;
        display: flex;
        justify-content: space-between;
    }
    .sub-grid {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
    }
    .sub-grid th, .sub-grid td {
        padding: 10px;
        text-align: left;
        border-bottom: 1px solid var(--gray-200);
    }
    .sub-grid th {
        background-color: var(--gray-50);
        color: var(--gray-600);
        font-weight: 600;
        text-transform: uppercase;
        font-size: 11px;
    }
    .sub-grid tr:hover {
        background-color: #f8fafc;
    }
    .badge-status {
        padding: 4px 8px;
        border-radius: 12px;
        font-size: 11px;
        font-weight: bold;
    }
    .badge-active { background-color: #d1fae5; color: #065f46; }
    .badge-inactive { background-color: #fee2e2; color: #991b1b; }
</style>

<div class="global-sub-card" id="divContainer" runat="server" visible="false">
    <h3>
        <span><i class="fas fa-id-card-alt"></i> Active Subscriptions Summary</span>
        <span style="font-size:14px; font-weight:normal; color:var(--gray-500);">
            Family of Member: <asp:Label ID="lblMainMemberName" runat="server" Font-Bold="true" ForeColor="#1e293b"></asp:Label>
        </span>
    </h3>
    
    <div style="overflow-x:auto;">
        <asp:GridView ID="gvFamilySubs" runat="server" AutoGenerateColumns="False" CssClass="sub-grid" GridLines="None" ShowHeaderWhenEmpty="true">
            <Columns>
                <asp:TemplateField HeaderText="Member / Dependent">
                    <ItemTemplate>
                        <strong style="color:var(--primary);"><%# Eval("PersonName") %></strong><br />
                        <span style="font-size:11px; color:var(--gray-500);"><%# Eval("Relation") %></span>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="MemberNo" HeaderText="Member No." />
                <asp:TemplateField HeaderText="Member Status">
                    <ItemTemplate>
                        <span class='badge-status <%# Convert.ToString(Eval("MemberStatus")).Equals("Active", StringComparison.OrdinalIgnoreCase) ? "badge-active" : "badge-inactive" %>'>
                            <%# Eval("MemberStatus") %>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="SportName" HeaderText="Sport" />
                <asp:BoundField DataField="PackageName" HeaderText="Package" />
                <asp:BoundField DataField="SubscriptionType" HeaderText="Type" />
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate>
                        <span class='badge-status <%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                            <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Stopped" %>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
            <EmptyDataTemplate>
                <div style="text-align:center; padding: 20px; color: var(--gray-500);">
                    No active subscriptions found for this member's family.
                </div>
            </EmptyDataTemplate>
        </asp:GridView>
    </div>
</div>
