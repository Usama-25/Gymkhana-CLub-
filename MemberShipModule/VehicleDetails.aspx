<%@ Page Title="Vehicle Management" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true" CodeFile="VehicleDetails.aspx.cs" Inherits="Membership.VehicleDetails" %>

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
                    <p style="color: #E8D5A3; font-size: 0.95rem; margin: 0.25rem 0 0 0;">Search for a member to view or register their vehicles.</p>
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
                                        <asp:LinkButton ID="btnManageVehicles" runat="server" CommandName="ManageVehicles" CommandArgument='<%# Eval("MemberID") %>' 
                                           style="display: inline-flex; align-items: center; justify-content: center; padding: 6px 12px; border-radius: 6px; background: #faf7f2; border: 1px solid #f5ecd5; color: #C9A84C; font-weight: 600; text-decoration: none; transition: all 0.2s;">
                                           Manage Vehicles
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

        <!-- Panel: Vehicle Dashboard -->
        <asp:Panel ID="pnlVehicleDashboard" runat="server" Visible="false">
            <asp:HiddenField ID="hdnSelectedMemberID" runat="server" />
            
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                <asp:Button ID="btnBackToSearch" runat="server" Text="← Back to Search" OnClick="btnBackToSearch_Click" style="background: transparent; border: none; padding: 0; color: #7a7a7a; font-weight: 600; font-size: 0.95rem; cursor: pointer;" />
            </div>

            <div class="card" style="background-color: #ffffff; border-radius: 12px; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden;">
                <div class="card-header" style="padding: 16px 26px; border-bottom: 1px solid #e0d5c5; display: flex; justify-content: space-between; align-items: center; background: linear-gradient(135deg, #1A1A2E, #2d2d5e);">
                    <div>
                        <h1 style="font-size: 1.35rem; font-weight: 700; color: #fff; margin: 0;"><asp:Label ID="lblDashMemberName" runat="server"></asp:Label></h1>
                        <p style="color: #E8D5A3; font-size: 0.8rem; margin: 3px 0 0 0;">Member No: <asp:Label ID="lblDashMemberNo" runat="server" style="font-weight: 600; color: #E8D5A3;"></asp:Label></p>
                    </div>
                    <div>
                        <asp:Button ID="btnOpenAddModal" runat="server" Text="+ Register New Vehicle" OnClick="btnOpenAddModal_Click" style="padding: 0.75rem 2rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; border: none; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);" />
                    </div>
                </div>

                <div class="card-body" style="padding: 1.5rem;">
                    <div style="border: 1px solid #e0d5c5; border-radius: 8px; overflow: hidden; width: 100%; overflow-x: auto;">
                        <asp:GridView ID="gvVehicles" runat="server" AutoGenerateColumns="False" 
                            CssClass="table" GridLines="None" Width="100%" DataKeyNames="VehicleID" OnRowCommand="gvVehicles_RowCommand">
                            <Columns>
                                <asp:BoundField DataField="StickerNo" HeaderText="Sticker No" />
                                <asp:BoundField DataField="RFIDTag" HeaderText="RFID Tag" />
                                <asp:BoundField DataField="VehicleNo" HeaderText="Vehicle No" />
                                <asp:BoundField DataField="Make" HeaderText="Make" />
                                <asp:BoundField DataField="Model" HeaderText="Model" />
                                <asp:BoundField DataField="IssueDate" HeaderText="Issue Date" DataFormatString="{0:dd MMM yyyy}" />
                                <asp:BoundField DataField="ExpiryDate" HeaderText="Expiry Date" DataFormatString="{0:dd MMM yyyy}" />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <span class='<%# "status-badge status-" + Eval("RecordStatus").ToString().ToLower() %>'>
                                            <%# Eval("RecordStatus") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Remarks" HeaderText="Remarks" />
                                <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <div style="display: flex; gap: 0.5rem; justify-content: center;">
                                            <asp:LinkButton ID="btnEditStatus" runat="server" CommandName="EditStatus" CommandArgument='<%# Eval("VehicleNo") %>' 
                                               style="color: #C9A84C; font-weight: 600; text-decoration: none;">Status</asp:LinkButton>
                                            <asp:LinkButton ID="btnReplaceSticker" runat="server" CommandName="ReplaceSticker" CommandArgument='<%# Eval("VehicleNo") %>' 
                                               style="color: #d97706; font-weight: 600; text-decoration: none;" OnClientClick="return confirm('Are you sure you want to register a NEW sticker for this vehicle?');">Replace</asp:LinkButton>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div style="padding: 3rem; text-align: center;">
                                    <h3 style="color: #7a7a7a; font-weight: 600;">No vehicles found for this member.</h3>
                                    <p style="color: #a09080; font-size: 0.9rem;">Click the "+ Register New Vehicle" button above to add one.</p>
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <!-- Add Vehicle Modal -->
        <asp:Panel ID="pnlAddVehicleModal" runat="server" class="modal-overlay" Visible="false" style="display: flex;">
            <div class="modal-content" style="background: white; padding: 2rem; border-radius: 12px; width: 500px; max-width: 90%; box-shadow: 0 10px 25px rgba(0,0,0,0.2);">
                <h2 style="margin-top: 0; color: #1A1A2E; font-weight: 700; border-bottom: 1px solid #e0d5c5; padding-bottom: 1rem;">Register New Vehicle</h2>
                <p style="font-size: 0.9rem; color: #E8D5A3; margin-bottom: 1.5rem;">Registering vehicle for Member No: <strong><asp:Label ID="lblModalMemberNo" runat="server"></asp:Label></strong></p>
                
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1.5rem;">
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Sticker No</label>
                        <asp:TextBox ID="txtAddStickerNo" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" placeholder="Enter Sticker No" />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">RFID Tag / Unique No</label>
                        <asp:TextBox ID="txtAddRFIDTag" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" placeholder="Enter RFID Tag" />
                    </div>
                    <div style="grid-column: span 2;">
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Vehicle No *</label>
                        <asp:TextBox ID="txtAddVehicleNo" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" placeholder="Enter Vehicle No" />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Make</label>
                        <asp:TextBox ID="txtAddMake" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" placeholder="e.g. Toyota" />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Model</label>
                        <asp:TextBox ID="txtAddModel" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" placeholder="e.g. Corolla" />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Color</label>
                        <asp:TextBox ID="txtAddColor" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" placeholder="Enter Color" />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Ownership</label>
                        <asp:TextBox ID="txtAddOwnership" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" placeholder="Enter Ownership" />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Issue Date</label>
                        <asp:TextBox ID="txtAddIssueDate" runat="server" TextMode="Date" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Expiry Date</label>
                        <asp:TextBox ID="txtAddExpiryDate" runat="server" TextMode="Date" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                    </div>
                </div>
                
                <div style="display: flex; justify-content: flex-end; gap: 1rem;">
                    <asp:Button ID="btnCancelAdd" runat="server" Text="Cancel" OnClick="btnCancelAdd_Click" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background-color: white; color: #7a7a7a; border: 1px solid #e0d5c5;" />
                    <asp:Button ID="btnSaveNewVehicle" runat="server" Text="Register Vehicle" OnClick="btnSaveNewVehicle_Click" style="padding: 0.75rem 2rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; border: none; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);" />
                </div>
            </div>
        </asp:Panel>

        <!-- Status Update Modal -->
        <asp:Panel ID="statusModal" runat="server" class="modal-overlay" Visible="false" style="display: flex;">
            <div class="modal-content" style="background: white; padding: 2rem; border-radius: 12px; width: 500px; max-width: 90%; box-shadow: 0 10px 25px rgba(0,0,0,0.2);">
                <h2 style="margin-top: 0; color: #1A1A2E; font-weight: 700; border-bottom: 1px solid #e0d5c5; padding-bottom: 1rem;">Update Vehicle Status</h2>
                <asp:HiddenField ID="hdnEditVehicleID" runat="server" />
                
                <div style="margin-top: 1.5rem; margin-bottom: 1rem;">
                    <label style="font-size: 0.9rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.5rem;">New Status</label>
                    <asp:DropDownList ID="ddlEditStatus" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none; background: white;">
                        <asp:ListItem Text="Active" Value="Active"></asp:ListItem>
                        <asp:ListItem Text="Blocked" Value="Blocked"></asp:ListItem>
                        <asp:ListItem Text="Lost" Value="Lost"></asp:ListItem>
                        <asp:ListItem Text="Replaced" Value="Replaced"></asp:ListItem>
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
