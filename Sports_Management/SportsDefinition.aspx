<%@ Page Title="Sports Definition" Language="C#" MasterPageFile="~/Sports_Management/SiteSports.master" AutoEventWireup="true" CodeFile="SportsDefinition.aspx.cs" Inherits="SportsDefinition" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="page-header-card">
        <h2><i class="fas fa-running" style="margin-right:10px;"></i> Sports Definition</h2>
        <span class="badge">Add / Manage Sports</span>
    </div>

    <!-- Alert Message -->
    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert" style="display:block; margin-bottom: 20px; padding: 15px; border-radius: 8px; font-weight: bold;"></asp:Label>

    <div style="display:flex; gap:20px; flex-wrap:wrap;">
        
        <!-- Add New Sport Card -->
        <div class="card" style="flex:1; min-width:300px;">
            <div class="card-header"><asp:Literal ID="litFormTitle" runat="server" Text="Add New Sport"></asp:Literal></div>
            <div class="card-body">
                <asp:HiddenField ID="hfSportID" runat="server" />
                
                <div class="form-group">
                    <label>Sport Name</label>
                    <asp:TextBox ID="txtSportName" runat="server" CssClass="form-control" placeholder="e.g. Cricket, Tennis, Golf"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>SubDept ID</label>
                    <asp:TextBox ID="txtSubDeptID" runat="server" CssClass="form-control" placeholder="e.g. 10, 20" TextMode="Number"></asp:TextBox>
                </div>

                <div style="display:flex; gap:10px;">
                    <div class="form-group" style="flex:1;">
                        <label>Monthly Rate (PKR)</label>
                        <asp:TextBox ID="txtMonthlyRate" runat="server" CssClass="form-control" TextMode="Number" step="0.01" placeholder="e.g. 4500.00"></asp:TextBox>
                    </div>

                    <div class="form-group" style="flex:1;">
                        <label>Continuous Rate (PKR)</label>
                        <asp:TextBox ID="txtContinuousRate" runat="server" CssClass="form-control" TextMode="Number" step="0.01" placeholder="e.g. 4500.00"></asp:TextBox>
                    </div>
                </div>

                <div class="form-group">
                    <label style="font-weight:700;">Applied Discount Policies (Select Multiple)</label>
                    <div style="max-height: 140px; overflow-y: auto; border: 1px solid var(--gray-300); border-radius: 6px; padding: 10px; background: #fafafa;">
                        <asp:CheckBoxList ID="cblDiscountPolicies" runat="server" CellPadding="3" CellSpacing="2">
                        </asp:CheckBoxList>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Description</label>
                    <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="Description of the facility..."></asp:TextBox>
                </div>
                
                <div class="form-group" style="display:flex; align-items:center; gap: 10px;">
                    <asp:CheckBox ID="chkStatus" runat="server" Checked="true" />
                    <label style="margin:0;">Active Status</label>
                </div>
                
                <div style="margin-top:20px; display:flex;">
                    <asp:Button ID="btnSave" runat="server" Text="Save Sport" CssClass="btn btn-primary" OnClick="btnSave_Click" />
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn" style="background-color:var(--gray-300); color:var(--gray-800); margin-left:10px;" OnClick="btnCancel_Click" Visible="false" />
                </div>
            </div>
        </div>

        <!-- List of Sports Card -->
        <div class="card" style="flex:2; min-width:400px;">
            <div class="card-header">Defined Sports</div>
            <div class="card-body" style="padding:0;">
                <asp:GridView ID="gvSports" runat="server" AutoGenerateColumns="False" CssClass="grid-view" GridLines="None" OnRowCommand="gvSports_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="SportID" HeaderText="ID" />
                        <asp:BoundField DataField="SportName" HeaderText="Sport" />
                        <asp:BoundField DataField="SubDeptID" HeaderText="SubDept ID" NullDisplayText="N/A" />
                        <asp:TemplateField HeaderText="Monthly Rate">
                            <ItemTemplate>
                                <strong style="color:#2563eb;"><%# Eval("MonthlyFee", "{0:N2}") %> PKR</strong>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Continuous Rate">
                            <ItemTemplate>
                                <strong style="color:#059669;"><%# Eval("ContinuousFee", "{0:N2}") %> PKR</strong>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Applied Policy">
                            <ItemTemplate>
                                <span style="font-weight:600; color:#4b5563; padding:2px 8px; background-color:#f3f4f6; border-radius:12px; font-size:12px;">
                                    <%# Eval("PolicyName") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Description" HeaderText="Description" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span style='<%# Convert.ToBoolean(Eval("Status")) ? "color:var(--success);font-weight:bold;" : "color:var(--danger);font-weight:bold;" %>'>
                                    <%# Convert.ToBoolean(Eval("Status")) ? "Active" : "Inactive" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditSport" CommandArgument='<%# Eval("SportID") %>' CssClass="btn-edit" style="color:var(--secondary); font-weight:bold; text-decoration:none;"><i class="fas fa-edit"></i> Edit</asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

    </div>
</asp:Content>
