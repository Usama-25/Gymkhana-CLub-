<%@ Page Title="Dependents Details" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true" CodeFile="DependentsDetails.aspx.cs" Inherits="Membership.DependentsDetails" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Outfit', sans-serif !important; background-color: #faf7f2; }
        
        .table { width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left; }
        .table th { background: #1A1A2E; color: #C9A84C; font-weight: 700; padding: 0.75rem 1rem; border-bottom: 1px solid #e0d5c5; text-align: left; font-size: 0.875rem; }
        .table td { padding: 0.75rem 1rem; border-bottom: 1px solid #F7F3EE; color: #1A1A2E; vertical-align: middle; font-size: 0.9rem; }
        .table tr:hover { background-color: #faf7f2; }

        .status-badge { display: inline-flex; align-items: center; gap: 0.5rem; padding: 0.4rem 0.8rem; border-radius: 99px; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; }
        .status-active { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
        .status-blocked { background: #ffedd5; color: #c2410c; border: 1px solid #fed7aa; }
        .status-died { background: #F7F3EE; color: #8B5E3C; border: 1px solid #e0d5c5; }
        .status-suspend { background: #fef9c3; color: #854d0e; border: 1px solid #fef08a; }
        .status-cancle { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
        .status-deactive { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
        
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center; }
        .modal-content { background: white; padding: 2rem; border-radius: 12px; width: 600px; max-width: 90%; box-shadow: 0 10px 25px rgba(0,0,0,0.2); }
        .modal-content-sm { width: 450px; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-wrapper" style="padding: 1.5rem; width: 100%; max-width: 100%; margin: 0 auto; font-family: 'Outfit', sans-serif;">
        
        <!-- Alerts -->
        <div id="divAlert" runat="server" visible="false" style="padding: 1rem; border-radius: 8px; margin-bottom: 1.5rem; display: flex; align-items: center; gap: 0.75rem;">
            <asp:Label ID="lblAlertMsg" runat="server" style="font-weight: 500; font-size: 0.95rem;"></asp:Label>
        </div>

        <!-- Panel: Member Search -->
        <asp:Panel ID="pnlMemberSearch" runat="server">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; margin-bottom: 2rem;">
                <div class="card-header" style="padding: 16px 26px; border-bottom: 1px solid #e0d5c5; background: linear-gradient(135deg, #1A1A2E, #2d2d5e);">
                    <h1 style="font-size: 1.5rem; font-weight: 700; color: #fff; margin: 0;">Find Member</h1>
                    <p style="color: #E8D5A3; font-size: 0.95rem; margin: 0.25rem 0 0 0;">Search for a member to view or register their dependents (Spouses & Children).</p>
                </div>

                <div class="card-body" style="padding: 1.5rem;">
                    <!-- Member Search Filters -->
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-bottom: 1.5rem; background: #faf7f2; padding: 1rem; border-radius: 8px; border: 1px solid #e0d5c5;">
                        <div>
                            <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Member No</label>
                            <asp:TextBox ID="txtSearchMemberNo" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                        </div>
                        <div>
                            <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Member Name</label>
                            <asp:TextBox ID="txtSearchName" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                        </div>
                        <div>
                            <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">CNIC Number</label>
                            <asp:TextBox ID="txtSearchNIC" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                        </div>
                        <div>
                            <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Mobile No</label>
                            <asp:TextBox ID="txtSearchMobile" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                        </div>
                        <div style="display: flex; gap: 0.5rem; align-items: end;">
                            <asp:Button ID="btnSearchMember" runat="server" Text="Search" OnClick="btnSearchMember_Click" style="flex: 1; padding: 0.6rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; border: none; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);" />
                            <asp:Button ID="btnClearMemberSearch" runat="server" Text="Clear" OnClick="btnClearMemberSearch_Click" style="flex: 1; padding: 0.6rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background-color: white; color: #7a7a7a; border: 1px solid #e0d5c5;" />
                        </div>
                    </div>

                    <!-- Members Results Grid -->
                    <div style="border: 1px solid #e0d5c5; border-radius: 8px; overflow: hidden; width: 100%; overflow-x: auto;">
                        <asp:GridView ID="gvMembers" runat="server" AutoGenerateColumns="False" AllowPaging="True" AllowCustomPaging="True" PageSize="10" OnPageIndexChanging="gvMembers_PageIndexChanging" 
                            CssClass="table" GridLines="None" Width="100%" DataKeyNames="MemberID" OnRowCommand="gvMembers_RowCommand">
                            <Columns>
                                <asp:BoundField DataField="MemberNo" HeaderText="Member No" />
                                <asp:BoundField DataField="MemberName" HeaderText="Member Name" />
                                <asp:BoundField DataField="NIC" HeaderText="CNIC" />
                                <asp:BoundField DataField="Mobile" HeaderText="Mobile" />
                                <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnManageDependents" runat="server" CommandName="ManageDependents" CommandArgument='<%# Eval("MemberID") %>' 
                                           style="display: inline-flex; align-items: center; justify-content: center; padding: 6px 12px; border-radius: 6px; background: #faf7f2; border: 1px solid #f5ecd5; color: #C9A84C; font-weight: 600; text-decoration: none; transition: all 0.2s;">
                                           Manage Dependents
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div style="padding: 3rem; text-align: center;">
                                    <h3 style="color: #7a7a7a; font-weight: 600;">No members found matching your criteria.</h3>
                                    <p style="color: #a09080; font-size: 0.9rem;">Please adjust your search filters and try again.</p>
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <!-- Panel: Dependents Dashboard -->
        <asp:Panel ID="pnlDependentsDashboard" runat="server" Visible="false">
            <asp:HiddenField ID="hdnSelectedMemberID" runat="server" />
            <asp:HiddenField ID="hdnSelectedMemberNo" runat="server" />
            
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                <asp:Button ID="btnBackToSearch" runat="server" Text="← Back to Search" OnClick="btnBackToSearch_Click" style="background: transparent; border: none; padding: 0; color: #7a7a7a; font-weight: 600; font-size: 0.95rem; cursor: pointer;" />
            </div>

            <!-- Spouses Card -->
            <div class="card" style="background-color: #ffffff; border-radius: 12px; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; margin-bottom: 2rem;">
                <div class="card-header" style="padding: 1.5rem; border-bottom: 1px solid #e0d5c5; display: flex; justify-content: space-between; align-items: center; background: linear-gradient(135deg, #1A1A2E, #2d2d5e);">
                    <div>
                        <h1 style="font-size: 1.5rem; font-weight: 700; color: #fff; margin: 0;">Spouse Information</h1>
                        <p style="color: #E8D5A3; font-size: 0.95rem; margin: 0.25rem 0 0 0;">Primary Member: <asp:Label ID="lblDashMemberNameS" runat="server" style="font-weight: 600; color: #1A1A2E;"></asp:Label> (<asp:Label ID="lblDashMemberNoS" runat="server"></asp:Label>)</p>
                    </div>
                    <div>
                        <asp:Button ID="btnOpenAddSpouseModal" runat="server" Text="+ Register Spouse" OnClick="btnOpenAddSpouseModal_Click" style="padding: 0.75rem 2rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: linear-gradient(135deg, #8b5cf6, #a855f7); color: white; border: none; box-shadow: 0 4px 6px rgba(139, 92, 246, 0.2);" />
                    </div>
                </div>

                <div class="card-body" style="padding: 1.5rem;">
                    <div style="border: 1px solid #e0d5c5; border-radius: 8px; overflow: hidden; width: 100%; overflow-x: auto;">
                        <asp:GridView ID="gvSpouses" runat="server" AutoGenerateColumns="False" 
                            CssClass="table" GridLines="None" Width="100%" DataKeyNames="SpouseID" OnRowCommand="gvSpouses_RowCommand">
                            <Columns>
                                <asp:BoundField DataField="MembershipNo" HeaderText="Spouse Member No" />
                                <asp:BoundField DataField="SpouseName" HeaderText="Name" />
                                <asp:BoundField DataField="SpouseCNIC" HeaderText="CNIC" />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <span class='<%# GetStatusClass(Eval("RecordStatus")) %>'>
                                            <%# Eval("RecordStatus") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Remarks" HeaderText="Remarks" />
                                <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnEditSpouseDetails" runat="server" CommandName="EditDetails" CommandArgument='<%# Eval("SpouseID") %>' 
                                           style="color: #8B5E3C; font-weight: 600; text-decoration: none; margin-right: 1rem;">Edit</asp:LinkButton>
                                        <asp:LinkButton ID="btnEditSpouseStatus" runat="server" CommandName="EditStatus" CommandArgument='<%# Eval("SpouseID") %>' 
                                           style="color: #8b5cf6; font-weight: 600; text-decoration: none;">Update Status</asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div style="padding: 3rem; text-align: center;">
                                    <h3 style="color: #7a7a7a; font-weight: 600;">No spouses found for this member.</h3>
                                    <p style="color: #a09080; font-size: 0.9rem;">Click the "+ Register Spouse" button above to add one.</p>
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
            
            <!-- Children Card -->
            <div class="card" style="background-color: #ffffff; border-radius: 12px; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden;">
                <div class="card-header" style="padding: 1.5rem; border-bottom: 1px solid #e0d5c5; display: flex; justify-content: space-between; align-items: center; background: linear-gradient(135deg, #1A1A2E, #2d2d5e);">
                    <div>
                        <h1 style="font-size: 1.5rem; font-weight: 700; color: #fff; margin: 0;">Children Details</h1>
                        <p style="color: #E8D5A3; font-size: 0.95rem; margin: 0.25rem 0 0 0;">Manage child memberships and track auto-allocated dependent numbers.</p>
                    </div>
                    <div>
                        <asp:Button ID="btnOpenAddChildModal" runat="server" Text="+ Register Child" OnClick="btnOpenAddChildModal_Click" style="padding: 0.75rem 2rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: linear-gradient(135deg, #10b981, #14b8a6); color: white; border: none; box-shadow: 0 4px 6px rgba(16, 185, 129, 0.2);" />
                    </div>
                </div>

                <div class="card-body" style="padding: 1.5rem;">
                    <div style="border: 1px solid #e0d5c5; border-radius: 8px; overflow: hidden; width: 100%; overflow-x: auto;">
                        <asp:GridView ID="gvChildren" runat="server" AutoGenerateColumns="False" 
                            CssClass="table" GridLines="None" Width="100%" DataKeyNames="ChildID" OnRowCommand="gvChildren_RowCommand">
                            <Columns>
                                <asp:BoundField DataField="MembershipNo" HeaderText="Child Member No" />
                                <asp:BoundField DataField="ChildName" HeaderText="Name" />
                                <asp:BoundField DataField="Relationship" HeaderText="Relationship" />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <span class='<%# GetStatusClass(Eval("RecordStatus")) %>'>
                                            <%# Eval("RecordStatus") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Remarks" HeaderText="Remarks" />
                                <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnEditChildDetails" runat="server" CommandName="EditDetails" CommandArgument='<%# Eval("ChildID") %>' 
                                           style="color: #8B5E3C; font-weight: 600; text-decoration: none; margin-right: 1rem;">Edit</asp:LinkButton>
                                        <asp:LinkButton ID="btnEditChildStatus" runat="server" CommandName="EditStatus" CommandArgument='<%# Eval("ChildID") %>' 
                                           style="color: #10b981; font-weight: 600; text-decoration: none;">Update Status</asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div style="padding: 3rem; text-align: center;">
                                    <h3 style="color: #7a7a7a; font-weight: 600;">No children found for this member.</h3>
                                    <p style="color: #a09080; font-size: 0.9rem;">Click the "+ Register Child" button above to add one.</p>
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
            
        </asp:Panel>

        <!-- Add Spouse Modal -->
        <asp:Panel ID="pnlAddSpouseModal" runat="server" class="modal-overlay" Visible="false" style="display: flex;">
            <div class="modal-content" style="background: white; padding: 2rem; border-radius: 12px; width: 600px; max-width: 90%; box-shadow: 0 10px 25px rgba(0,0,0,0.2);">
                <asp:HiddenField ID="hdnEditSpouseID" runat="server" />
                <h2 style="margin-top: 0; color: #1A1A2E; font-weight: 700; border-bottom: 1px solid #e0d5c5; padding-bottom: 1rem;"><asp:Label ID="lblSpouseModalTitle" runat="server" Text="Register Spouse"></asp:Label></h2>
                <p style="font-size: 0.9rem; color: #E8D5A3; margin-bottom: 1.5rem;">Spouse Membership No: <strong><asp:Label ID="lblSpousePreviewNo" runat="server"></asp:Label></strong></p>
                
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1.5rem;">
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Spouse Name *</label>
                        <asp:TextBox ID="txtAddSpouseName" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" placeholder="Full Name" />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Spouse CNIC</label>
                        <asp:TextBox ID="txtAddSpouseCNIC" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" placeholder="00000-0000000-0" />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Phone</label>
                        <asp:TextBox ID="txtAddSpousePhone" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Profession</label>
                        <asp:TextBox ID="txtAddSpouseProfession" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                    </div>
                </div>
                
                <div style="display: flex; justify-content: flex-end; gap: 1rem;">
                    <asp:Button ID="btnCancelSpouseAdd" runat="server" Text="Cancel" OnClick="btnCancelSpouseAdd_Click" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background-color: white; color: #7a7a7a; border: 1px solid #e0d5c5;" />
                    <asp:Button ID="btnSaveNewSpouse" runat="server" Text="Save Spouse" OnClick="btnSaveNewSpouse_Click" style="padding: 0.75rem 2rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: linear-gradient(135deg, #8b5cf6, #a855f7); color: white; border: none; box-shadow: 0 4px 6px rgba(139, 92, 246, 0.2);" />
                </div>
            </div>
        </asp:Panel>
        
        <!-- Add Child Modal -->
        <asp:Panel ID="pnlAddChildModal" runat="server" class="modal-overlay" Visible="false" style="display: flex;">
            <div class="modal-content" style="background: white; padding: 2rem; border-radius: 12px; width: 600px; max-width: 90%; box-shadow: 0 10px 25px rgba(0,0,0,0.2);">
                <asp:HiddenField ID="hdnEditChildID" runat="server" />
                <h2 style="margin-top: 0; color: #1A1A2E; font-weight: 700; border-bottom: 1px solid #e0d5c5; padding-bottom: 1rem;"><asp:Label ID="lblChildModalTitle" runat="server" Text="Register Child"></asp:Label></h2>
                <p style="font-size: 0.9rem; color: #E8D5A3; margin-bottom: 1.5rem;">Child Membership No: <asp:Label ID="lblChildPreviewNo" runat="server" Font-Bold="true"></asp:Label> (auto-generated based on relationship)</p>
                
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1.5rem;">
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Child Name *</label>
                        <asp:TextBox ID="txtAddChildName" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" placeholder="Full Name" />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Relationship *</label>
                        <asp:DropDownList ID="ddlAddChildRelation" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none; background: white;">
                            <asp:ListItem Value="Son">Son</asp:ListItem>
                            <asp:ListItem Value="Daughter">Daughter</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">CNIC / B-Form</label>
                        <asp:TextBox ID="txtAddChildCNIC" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" placeholder="00000-0000000-0" />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Date of Birth</label>
                        <asp:TextBox ID="txtAddChildDOB" runat="server" TextMode="Date" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                    </div>
                </div>
                
                <div style="display: flex; justify-content: flex-end; gap: 1rem;">
                    <asp:Button ID="btnCancelChildAdd" runat="server" Text="Cancel" OnClick="btnCancelChildAdd_Click" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background-color: white; color: #7a7a7a; border: 1px solid #e0d5c5;" />
                    <asp:Button ID="btnSaveNewChild" runat="server" Text="Save Child" OnClick="btnSaveNewChild_Click" style="padding: 0.75rem 2rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: linear-gradient(135deg, #10b981, #14b8a6); color: white; border: none; box-shadow: 0 4px 6px rgba(16, 185, 129, 0.2);" />
                </div>
            </div>
        </asp:Panel>

        <!-- Status Update Modal (Shared for both Spouse and Child) -->
        <asp:Panel ID="statusModal" runat="server" class="modal-overlay" Visible="false" style="display: flex;">
            <div class="modal-content modal-content-sm" style="background: white; padding: 2rem; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.2);">
                <h2 style="margin-top: 0; color: #1A1A2E; font-weight: 700; border-bottom: 1px solid #e0d5c5; padding-bottom: 1rem;">Update Status</h2>
                <asp:HiddenField ID="hdnEditID" runat="server" />
                <asp:HiddenField ID="hdnEditType" runat="server" />
                
                <div style="margin-top: 1.5rem; margin-bottom: 1rem;">
                    <label style="font-size: 0.9rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.5rem;">New Status</label>
                    <asp:DropDownList ID="ddlEditStatus" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none; background: white;">
                        <asp:ListItem Text="Active" Value="Active"></asp:ListItem>
                        <asp:ListItem Text="Blocked" Value="Blocked"></asp:ListItem>
                        <asp:ListItem Text="Died" Value="Died"></asp:ListItem>
                        <asp:ListItem Text="Suspend" Value="Suspend"></asp:ListItem>
                        <asp:ListItem Text="Cancle" Value="Cancle"></asp:ListItem>
                        <asp:ListItem Text="Deactive" Value="Deactive"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                
                <div style="margin-bottom: 1.5rem;">
                    <label style="font-size: 0.9rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.5rem;">Remarks</label>
                    <asp:TextBox ID="txtEditRemarks" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" TextMode="MultiLine" Rows="3"></asp:TextBox>
                </div>
                
                <div style="display: flex; justify-content: flex-end; gap: 1rem;">
                    <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" OnClick="btnCancelEdit_Click" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background-color: white; color: #7a7a7a; border: 1px solid #e0d5c5;" />
                    <asp:Button ID="btnSaveStatus" runat="server" Text="Save Changes" OnClick="btnSaveStatus_Click" style="padding: 0.75rem 2rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; border: none; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);" />
                </div>
            </div>
        </asp:Panel>

    </div>
</asp:Content>
