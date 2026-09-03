<%@ Page Title="Member Allowed Areas" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true"
    CodeFile="MemberAllowedAreas.aspx.cs" Inherits="RefundFee.MemberSearch" %>

<asp:Content ID="HeadStyles" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Outfit', sans-serif !important; background-color: #faf7f2; }
        .table-container { background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        .table { width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left; }
        .table th { background: #1A1A2E; color: #C9A84C; font-weight: 700; padding: 0.75rem 1rem; border-bottom: 1px solid #e0d5c5; text-align: left; font-size: 0.875rem; }
        .table td { padding: 0.75rem 1rem; border-bottom: 1px solid #F7F3EE; color: #1A1A2E; vertical-align: middle; font-size: 0.9rem; }
        .table tr:hover { background-color: #faf7f2; }
        .form-control { display: block; width: 100%; padding: 0.6rem 0.8rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; outline: none; box-sizing: border-box; }
        .form-control:focus { border-color: #C9A84C; }
        
        /* Button Styles */
        .btn { display: inline-block; text-align: center; vertical-align: middle; padding: 0.6rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: all 0.15s ease; border: 1px solid transparent; line-height: 1; text-decoration: none; }
        .btn-primary { background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2); }
        .btn-secondary { background: #F7F3EE; color: #8B5E3C; border: 1px solid #e0d5c5; }
        .btn-danger { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
        .btn-danger:hover { background: #fecaca; }
        
        .card { background-color: #ffffff; border-radius: 12px; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; margin-bottom: 2rem; }
        .card-header { padding: 16px 26px; border-bottom: 1px solid #e0d5c5; background: linear-gradient(135deg, #1A1A2E, #2d2d5e); }
        .card-body { padding: 1.5rem; }
        .grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; }
        @media (max-width: 768px) {
            .grid-2 { grid-template-columns: 1fr; }
        }
    </style>
</asp:Content>

<asp:Content ID="ContentBody" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-wrapper" style="padding: 1.5rem; width: 100%; max-width: 100%; margin: 0 auto; font-family: 'Outfit', sans-serif;">
        
        <!-- Header Card -->
        <div class="card">
            <div class="card-header">
                <div>
                    <h1 style="font-size: 1.35rem; font-weight: 700; color: #fff; margin: 0;">Member Allowed Areas</h1>
                    <p style="color: #E8D5A3; font-size: 0.8rem; margin: 3px 0 0 0;">Membership Module · Configure Access Permissions for Members & Families</p>
                </div>
            </div>
            
            <div class="card-body">
                <!-- Status/Message Label -->
                <div style="margin-bottom: 1rem;">
                    <asp:Label ID="lblStatus" runat="server" Font-Bold="true" />
                </div>

                <!-- Search Section -->
                <div style="display: grid; grid-template-columns: 1fr auto; gap: 1rem; margin-bottom: 1.5rem; background: #faf7f2; padding: 1rem; border-radius: 8px; border: 1px solid #e0d5c5; align-items: end;">
                    <div>
                        <label style="font-size: 0.85rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.25rem;">Enter Member No</label>
                        <asp:TextBox ID="txtMemberNo" runat="server" placeholder="e.g. R-1234" CssClass="form-control" />
                    </div>
                    <div>
                        <asp:Button ID="btnSearch" runat="server" Text="Search Member" OnClick="btnSearch_Click" CssClass="btn btn-primary" />
                    </div>
                </div>

                <div class="grid-2">
                    <!-- Left Column: Member Select & Department Configuration -->
                    <div>
                        <!-- Family Dropdown Selector -->
                        <div class="card" style="margin-bottom: 1.5rem;">
                            <div class="card-body">
                                <h3 style="margin-top: 0; color: #1A1A2E; font-size: 1.1rem; border-bottom: 1px solid #F7F3EE; padding-bottom: 0.5rem;">Select Individual</h3>
                                <div style="margin-bottom: 1rem;">
                                    <label style="font-size: 0.85rem; font-weight: 600; color: #8B5E3C; display: block; margin-bottom: 0.25rem;">Select Person</label>
                                    <asp:DropDownList ID="ddlMember" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlMember_SelectedIndexChanged" />
                                </div>
                            </div>
                        </div>

                        <!-- Department/Area Actions Panel -->
                        <asp:Panel ID="pnlDepartment" runat="server" Visible="false" CssClass="card" style="margin-bottom: 1.5rem;">
                            <div class="card-body">
                                <h3 style="margin-top: 0; color: #1A1A2E; font-size: 1.1rem; border-bottom: 1px solid #F7F3EE; padding-bottom: 0.5rem;">Manage Area Access</h3>
                                <div style="margin-bottom: 1.5rem;">
                                    <label style="font-size: 0.85rem; font-weight: 600; color: #8B5E3C; display: block; margin-bottom: 0.25rem;">Select Department</label>
                                    <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-control" />
                                </div>
                                <div style="display: flex; gap: 1rem;">
                                    <asp:Button ID="btnAdd" runat="server" Text="Allow Access" OnClick="btnAdd_Click" CssClass="btn btn-primary" style="flex: 1;" />
                                    <asp:Button ID="btnRevoke" runat="server" Text="Revoke Access" OnClick="btnRevoke_Click" CssClass="btn btn-danger" style="flex: 1;" />
                                </div>
                            </div>
                        </asp:Panel>
                    </div>

                    <!-- Right Column: Family Member List -->
                    <div>
                        <div class="card">
                            <div class="card-body">
                                <h3 style="margin-top: 0; color: #1A1A2E; font-size: 1.1rem; border-bottom: 1px solid #F7F3EE; padding-bottom: 0.5rem;">Family Profile</h3>
                                <div class="table-container" style="max-height: 250px; overflow-y: auto;">
                                    <asp:GridView ID="gvFamily" runat="server" AutoGenerateColumns="False" CssClass="table" GridLines="None" Width="100%">
                                        <Columns>
                                            <asp:BoundField DataField="SpouseName" HeaderText="Spouse Name" NullDisplayText="-" />
                                            <asp:BoundField DataField="ChildName" HeaderText="Child Name" NullDisplayText="-" />
                                            <asp:BoundField DataField="Relationship" HeaderText="Relationship" NullDisplayText="Member" />
                                            <asp:BoundField DataField="MemberID" HeaderText="ID" ItemStyle-Width="60px" />
                                        </Columns>
                                        <EmptyDataTemplate>
                                            <div style="padding: 1rem; text-align: center; color: #8B5E3C;">No family members loaded.</div>
                                        </EmptyDataTemplate>
                                    </asp:GridView>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Allowed Areas Section -->
                <div class="card" style="margin-top: 1.5rem;">
                    <div class="card-body">
                        <h3 style="margin-top: 0; color: #1A1A2E; font-size: 1.15rem; border-bottom: 1px solid #F7F3EE; padding-bottom: 0.5rem;">Current Allowed Areas</h3>
                        <div class="table-container">
                            <asp:GridView ID="gvAllowedAreas" runat="server" AutoGenerateColumns="False" CssClass="table" GridLines="None" Width="100%">
                                <Columns>
                                    <asp:TemplateField HeaderText="S.No" ItemStyle-Width="60px">
                                        <ItemTemplate>
                                            <%# Container.DataItemIndex + 1 %>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="MemberName" HeaderText="Person Name" />
                                    <asp:BoundField DataField="Relation" HeaderText="Relation" />
                                    <asp:BoundField DataField="Areaname" HeaderText="Allowed Area / Department" />
                                    <asp:BoundField DataField="MemberNo" HeaderText="Member No" />
                                </Columns>
                                <EmptyDataTemplate>
                                    <div style="padding: 2rem; text-align: center; color: #8B5E3C;">No allowed areas configured for this member.</div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                </div>

            </div>
        </div>

    </div>
</asp:Content>
