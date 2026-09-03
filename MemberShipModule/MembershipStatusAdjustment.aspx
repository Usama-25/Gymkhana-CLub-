<%@ Page Title="Membership Status Adjustment" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true" CodeFile="MembershipStatusAdjustment.aspx.cs" Inherits="MemberShipModule.MembershipStatusAdjustment" %>

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
        .status-deactive { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
        .status-blocked { background: #fef3c7; color: #92400e; border: 1px solid #fde68a; }
        .status-lost { background: #f3f4f6; color: #374151; border: 1px solid #d1d5db; }
        .status-replaced { background: #f5ecd5; color: #075985; border: 1px solid #e0d5c5; }
        
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center; }
        .modal-content { background: white; padding: 2rem; border-radius: 12px; width: 500px; max-width: 90%; box-shadow: 0 10px 25px rgba(0,0,0,0.2); }

        .dashboard-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 1.5rem; margin-bottom: 2rem; }
        .dashboard-card { background: white; padding: 1.5rem; border-radius: 12px; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
        .dashboard-card h3 { margin: 0 0 0.5rem 0; color: #7a7a7a; font-size: 0.875rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; }
        .dashboard-card p { margin: 0; color: #1A1A2E; font-size: 1.25rem; font-weight: 700; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-wrapper" style="padding: 1.5rem; width: 100%; max-width: 100%; margin: 0 auto; font-family: 'Outfit', sans-serif;">
        
        <!-- Alerts -->
        <div id="divAlert" runat="server" visible="false" style="padding: 1rem; border-radius: 8px; margin-bottom: 1.5rem; display: flex; align-items: center; gap: 0.75rem;">
            <asp:Label ID="lblAlertMsg" runat="server" style="font-weight: 500; font-size: 0.95rem;"></asp:Label>
        </div>

        <asp:HiddenField ID="hdnMemberProfileID" runat="server" Value="0" />
        <asp:HiddenField ID="hdnMID" runat="server" Value="0" />

        <!-- Panel: Member Search -->
        <asp:Panel ID="pnlMemberSearch" runat="server">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; margin-bottom: 2rem;">
                <div class="card-header" style="padding: 16px 26px; border-bottom: 1px solid #e0d5c5; background: linear-gradient(135deg, #1A1A2E, #2d2d5e);">
                    <h1 style="font-size: 1.5rem; font-weight: 700; color: #fff; margin: 0;">Find Member</h1>
                    <p style="color: #E8D5A3; font-size: 0.95rem; margin: 0.25rem 0 0 0;">Search for a member to adjust their status.</p>
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
                        <asp:GridView ID="gvMembers" runat="server" AutoGenerateColumns="False" 
                            CssClass="table" GridLines="None" Width="100%" DataKeyNames="MemberID" OnRowCommand="gvMembers_RowCommand">
                            <Columns>
                                <asp:BoundField DataField="MemberNo" HeaderText="Member No" />
                                <asp:BoundField DataField="MemberName" HeaderText="Member Name" />
                                <asp:BoundField DataField="NIC" HeaderText="CNIC" />
                                <asp:BoundField DataField="Mobile" HeaderText="Mobile" />
                                <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnManageStatus" runat="server" CommandName="ManageStatus" CommandArgument='<%# Eval("MemberNo") %>' 
                                           style="display: inline-flex; align-items: center; justify-content: center; padding: 6px 12px; border-radius: 6px; background: #faf7f2; border: 1px solid #f5ecd5; color: #C9A84C; font-weight: 600; text-decoration: none; transition: all 0.2s;">
                                           Manage Status
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

        <!-- Panel: Status Dashboard -->
        <asp:Panel ID="pnlDashboard" runat="server" Visible="false">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                <asp:Button ID="btnBackToSearch" runat="server" Text="← Back to Search" OnClick="btnBackToSearch_Click" style="background: transparent; border: none; padding: 0; color: #7a7a7a; font-weight: 600; font-size: 0.95rem; cursor: pointer;" />
            </div>

            <div class="card" style="background-color: #ffffff; border-radius: 12px; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; margin-bottom: 2rem;">
                <div class="card-header" style="padding: 1.5rem; border-bottom: 1px solid #e0d5c5; display: flex; justify-content: space-between; align-items: center; background: linear-gradient(135deg, #1A1A2E, #2d2d5e);">
                    <div>
                        <h1 style="font-size: 1.5rem; font-weight: 700; color: #fff; margin: 0;"><asp:Label ID="lblDashMemberName" runat="server"></asp:Label></h1>
                        <p style="color: #E8D5A3; font-size: 0.95rem; margin: 0.25rem 0 0 0;">Member No: <asp:Label ID="lblDashMemberNo" runat="server" style="font-weight: 600; color: #1A1A2E;"></asp:Label></p>
                    </div>
                    <div style="display: flex; gap: 0.5rem;">
                        <asp:Button ID="btnOpenAccountModal" runat="server" Text="Change Account Status" OnClick="btnOpenAccountModal_Click" style="padding: 0.75rem 1rem; border-radius: 6px; font-weight: 600; font-size: 0.9rem; cursor: pointer; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; border: none; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);" />
                        <asp:Button ID="btnOpenResidentialModal" runat="server" Text="Change Residential Status" OnClick="btnOpenResidentialModal_Click" style="padding: 0.75rem 1rem; border-radius: 6px; font-weight: 600; font-size: 0.9rem; cursor: pointer; background: linear-gradient(135deg, #10b981, #34d399); color: white; border: none; box-shadow: 0 4px 6px rgba(16, 185, 129, 0.2);" />
                        <asp:Button ID="btnOpenMembershipModal" runat="server" Text="Change Membership Status" OnClick="btnOpenMembershipModal_Click" style="padding: 0.75rem 1rem; border-radius: 6px; font-weight: 600; font-size: 0.9rem; cursor: pointer; background: linear-gradient(135deg, #f59e0b, #fbbf24); color: white; border: none; box-shadow: 0 4px 6px rgba(245, 158, 11, 0.2);" />
                    </div>
                </div>

                <div class="card-body" style="padding: 1.5rem;">
                    <!-- Dashboard Cards for Current Status -->
                    <div class="dashboard-grid">
                        <div class="dashboard-card">
                            <h3>Current Account Status</h3>
                            <p><asp:Label ID="lblCurrentAccountStatus" runat="server" Text="N/A"></asp:Label></p>
                        </div>
                        <div class="dashboard-card">
                            <h3>Current Residential Status</h3>
                            <p><asp:Label ID="lblCurrentResidentialStatus" runat="server" Text="N/A"></asp:Label></p>
                        </div>
                        <div class="dashboard-card">
                            <h3>Current Membership Status</h3>
                            <p><asp:Label ID="lblCurrentMembershipStatus" runat="server" Text="N/A"></asp:Label></p>
                        </div>
                    </div>

                    <!-- Change History Grid -->
                    <div style="margin-top: 2rem;">
                        <h2 style="font-size: 1.25rem; font-weight: 700; color: #1A1A2E; margin-bottom: 1rem;">Change History</h2>
                        <div style="border: 1px solid #e0d5c5; border-radius: 8px; overflow: hidden; width: 100%; overflow-x: auto;">
                            <asp:GridView ID="gvChangeLog" runat="server" AutoGenerateColumns="False"
                                Width="100%" GridLines="None" CssClass="table"
                                EmptyDataText="No change history found for this member.">
                                <Columns>
                                    <asp:BoundField DataField="ChangeType" HeaderText="Change Type" />
                                    <asp:BoundField DataField="OldValue" HeaderText="Old Value" />
                                    <asp:BoundField DataField="NewValue" HeaderText="New Value" />
                                    <asp:BoundField DataField="Reason" HeaderText="Reason" />
                                    <asp:BoundField DataField="ModifiedBy" HeaderText="Modified By" />
                                    <asp:BoundField DataField="ModifiedOn" HeaderText="Modified On" DataFormatString="{0:dd/MM/yyyy hh:mm tt}" />
                                    <asp:BoundField DataField="RequestNo" HeaderText="Request No" />
                                </Columns>
                                <EmptyDataRowStyle BackColor="#faf7f2" ForeColor="#a09080" HorizontalAlign="Center" Height="60px" />
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <!-- Popup 1: Account Status Modal -->
        <asp:Panel ID="pnlAccountStatusModal" runat="server" class="modal-overlay" Visible="false" style="display: flex;">
            <div class="modal-content">
                <h2 style="margin-top: 0; color: #1A1A2E; font-weight: 700; border-bottom: 1px solid #e0d5c5; padding-bottom: 1rem;">Change Account Status</h2>
                
                <div style="margin-top: 1.5rem; margin-bottom: 1rem;">
                    <label style="font-size: 0.9rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.5rem;">Current Account Status</label>
                    <asp:TextBox ID="txtModalCurrentAccountStatus" runat="server" ReadOnly="true" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none; background: #F7F3EE; color: #7a7a7a;" />
                </div>

                <div style="margin-bottom: 1rem;">
                    <label style="font-size: 0.9rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.5rem;">New Account Status *</label>
                    <asp:DropDownList ID="ddlNewAccountStatus" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none; background: white;">
                        <asp:ListItem Value="">Select Status</asp:ListItem>
                        <asp:ListItem Value="ACTIVE">ACTIVE</asp:ListItem>
                        <asp:ListItem Value="SUSPENDED">SUSPENDED</asp:ListItem>
                        <asp:ListItem Value="RESIGNED">RESIGNED</asp:ListItem>
                        <asp:ListItem Value="BLOCKED">BLOCKED</asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem;">
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Start Date *</label>
                        <asp:TextBox ID="txtAccountStatusStartDate" runat="server" TextMode="Date" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">End Date *</label>
                        <asp:TextBox ID="txtAccountStatusEndDate" runat="server" TextMode="Date" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                    </div>
                </div>

                <div style="margin-bottom: 1.5rem;">
                    <label style="font-size: 0.9rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.5rem;">Reason / Remarks</label>
                    <asp:TextBox ID="txtAccountStatusReason" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" TextMode="MultiLine" Rows="3" placeholder="Enter reason for change"></asp:TextBox>
                </div>
                
                <div style="display: flex; justify-content: flex-end; gap: 1rem;">
                    <asp:Button ID="btnCancelAccountStatus" runat="server" Text="Cancel" OnClick="btnCancelAccountStatus_Click" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background-color: white; color: #7a7a7a; border: 1px solid #e0d5c5;" />
                    <asp:Button ID="btnSaveAccountStatus" runat="server" Text="Save Changes" OnClick="btnSaveAccountStatus_Click" style="padding: 0.75rem 2rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; border: none; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);" />
                </div>
            </div>
        </asp:Panel>

        <!-- Popup 2: Residential Status Modal -->
        <asp:Panel ID="pnlResidentialStatusModal" runat="server" class="modal-overlay" Visible="false" style="display: flex;">
            <div class="modal-content">
                <h2 style="margin-top: 0; color: #1A1A2E; font-weight: 700; border-bottom: 1px solid #e0d5c5; padding-bottom: 1rem;">Change Residential Status</h2>
                
                <div style="margin-top: 1.5rem; margin-bottom: 1rem;">
                    <label style="font-size: 0.9rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.5rem;">Current Residential Status</label>
                    <asp:TextBox ID="txtModalCurrentResidentialStatus" runat="server" ReadOnly="true" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none; background: #F7F3EE; color: #7a7a7a;" />
                </div>

                <div style="margin-bottom: 1rem;">
                    <label style="font-size: 0.9rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.5rem;">New Residential Status *</label>
                    <asp:DropDownList ID="ddlNewResidentialStatus" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none; background: white;">
                        <asp:ListItem Value="">Select Status</asp:ListItem>
                        <asp:ListItem Value="LOCAL">LOCAL</asp:ListItem>
                        <asp:ListItem Value="NON RESIDENT">NON RESIDENT</asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem;">
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Start Date *</label>
                        <asp:TextBox ID="txtResidentialStatusStartDate" runat="server" TextMode="Date" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">End Date *</label>
                        <asp:TextBox ID="txtResidentialStatusEndDate" runat="server" TextMode="Date" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                    </div>
                </div>

                <div style="margin-bottom: 1.5rem;">
                    <label style="font-size: 0.9rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.5rem;">Reason / Remarks</label>
                    <asp:TextBox ID="txtResidentialStatusReason" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" TextMode="MultiLine" Rows="3" placeholder="Enter reason for change"></asp:TextBox>
                </div>
                
                <div style="display: flex; justify-content: flex-end; gap: 1rem;">
                    <asp:Button ID="btnCancelResidentialStatus" runat="server" Text="Cancel" OnClick="btnCancelResidentialStatus_Click" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background-color: white; color: #7a7a7a; border: 1px solid #e0d5c5;" />
                    <asp:Button ID="btnSaveResidentialStatus" runat="server" Text="Save Changes" OnClick="btnSaveResidentialStatus_Click" style="padding: 0.75rem 2rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: linear-gradient(135deg, #10b981, #34d399); color: white; border: none; box-shadow: 0 4px 6px rgba(16, 185, 129, 0.2);" />
                </div>
            </div>
        </asp:Panel>

        <!-- Popup 3: Membership Status Modal -->
        <asp:Panel ID="pnlMembershipStatusModal" runat="server" class="modal-overlay" Visible="false" style="display: flex;">
            <div class="modal-content">
                <h2 style="margin-top: 0; color: #1A1A2E; font-weight: 700; border-bottom: 1px solid #e0d5c5; padding-bottom: 1rem;">Change Membership Status</h2>
                
                <div style="margin-top: 1.5rem; margin-bottom: 1rem;">
                    <label style="font-size: 0.9rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.5rem;">Current Membership Status</label>
                    <asp:TextBox ID="txtModalCurrentMembershipStatus" runat="server" ReadOnly="true" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none; background: #F7F3EE; color: #7a7a7a;" />
                </div>

                <div style="margin-bottom: 1rem;">
                    <label style="font-size: 0.9rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.5rem;">New Membership Status *</label>
                    <asp:DropDownList ID="ddlNewMembershipStatus" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none; background: white;">
                        <asp:ListItem Value="">Select Status</asp:ListItem>
                        <asp:ListItem Value="ACTIVE">ACTIVE</asp:ListItem>
                        <asp:ListItem Value="ABSENT">ABSENT</asp:ListItem>
                        <asp:ListItem Value="BLOCKED">BLOCKED</asp:ListItem>
                        <asp:ListItem Value="CANCELLED">CANCELLED</asp:ListItem>
                        <asp:ListItem Value="CEASED">CEASED</asp:ListItem>
                        <asp:ListItem Value="CLOSED/TRANSFERRED">CLOSED/TRANSFERRED</asp:ListItem>
                        <asp:ListItem Value="DIED">DIED</asp:ListItem>
                        <asp:ListItem Value="INACTIVE">INACTIVE</asp:ListItem>
                        <asp:ListItem Value="RESIGNED">RESIGNED</asp:ListItem>
                        <asp:ListItem Value="SPOUSE TRANSFERRED">SPOUSE TRANSFERRED</asp:ListItem>
                        <asp:ListItem Value="SUSPENDED">SUSPENDED</asp:ListItem>
                        <asp:ListItem Value="TERMINATED">TERMINATED</asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem;">
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Start Date *</label>
                        <asp:TextBox ID="txtMembershipStatusStartDate" runat="server" TextMode="Date" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">End Date *</label>
                        <asp:TextBox ID="txtMembershipStatusEndDate" runat="server" TextMode="Date" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                    </div>
                </div>

                <div style="margin-bottom: 1.5rem;">
                    <label style="font-size: 0.9rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.5rem;">Reason / Remarks</label>
                    <asp:TextBox ID="txtMembershipStatusReason" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" TextMode="MultiLine" Rows="3" placeholder="Enter reason for change"></asp:TextBox>
                </div>
                
                <div style="display: flex; justify-content: flex-end; gap: 1rem;">
                    <asp:Button ID="btnCancelMembershipStatus" runat="server" Text="Cancel" OnClick="btnCancelMembershipStatus_Click" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background-color: white; color: #7a7a7a; border: 1px solid #e0d5c5;" />
                    <asp:Button ID="btnSaveMembershipStatus" runat="server" Text="Save Changes" OnClick="btnSaveMembershipStatus_Click" style="padding: 0.75rem 2rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: linear-gradient(135deg, #f59e0b, #fbbf24); color: white; border: none; box-shadow: 0 4px 6px rgba(245, 158, 11, 0.2);" />
                </div>
            </div>
        </asp:Panel>

    </div>
</asp:Content>
