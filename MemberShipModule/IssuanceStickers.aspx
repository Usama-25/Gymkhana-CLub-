<%@ Page Title="Receive Member Fee" Language="C#" MasterPageFile="~/MemberShipModule/Site.master"
    AutoEventWireup="true" CodeFile="IssuanceStickers.aspx.cs" Inherits="WebForms.MemberShipModule.IssuanceStickers" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
    <style>
        /* Essential base reset */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            background: #f0f4f9;
            font-family: 'Segoe UI', system-ui, -apple-system, 'Inter', Roboto, sans-serif;
        }
        
        .issuance-module {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0.25rem 0;
        }
        
        .table-responsive {
            overflow-x: auto;
            margin: 1.5rem 0 0.5rem;
            border-radius: 18px;
        }
        
        .table-input-sm {
            width: 100%;
            padding: 0.55rem 0.9rem;
            border: 1px solid #cfdfed;
            border-radius: 14px;
            background: white;
            font-size: 0.8rem;
            font-weight: 500;
            color: #1e293b;
            font-family: inherit;
        }
        
        .table-input-sm:focus {
            border-color: #3b82f6;
            outline: none;
            box-shadow: 0 0 0 2px rgba(59,130,246,0.1);
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">
    <div class="issuance-module">
        <!-- Hidden fields to store selected member info for adding vehicles -->
        <asp:HiddenField ID="hdnSelectedMemberID" runat="server" Value="" />
        <asp:HiddenField ID="hdnSelectedMemberNo" runat="server" Value="" />
        
        <!-- MAIN CARD -->
        <div style="background-color: #ffffff; border-radius: 28px; border: 1px solid #e9eef4; overflow: hidden; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.03);">
            
            <!-- Header Section -->
            <div style="padding: 1.5rem 2rem; border-bottom: 2px solid #eff3f8; background: #ffffff;">
                <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 1rem;">
                    <div>
                        <h1 style="font-size: 1.8rem; font-weight: 800; margin: 0; color: #0a2540; letter-spacing: -0.01em; background: linear-gradient(135deg, #1e3a5f, #2563eb); background-clip: text; -webkit-background-clip: text; color: transparent;">Issuance of Physical Stickers</h1>
                        <p style="margin: 0.25rem 0 0; color: #5b6e8c; font-size: 0.9rem; font-weight: 500;">Manage and track vehicle sticker issuance & status updates</p>
                    </div>
                </div>
            </div>
            
            <!-- Body Content -->
            <div style="padding: 2rem;">
                
                <!-- SEARCH SECTION -->
                <div style="background: #fbfdfe; border-radius: 24px; padding: 1.5rem; margin-bottom: 2rem; border: 1px solid #eef3fc;">
                    
                    <!-- Section title -->
                    <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 1.5rem; padding-bottom: 0.75rem; border-bottom: 1px solid #e9eff5;">
                        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#2c66c3" stroke-width="1.8" style="background: #eef3fe; padding: 6px; border-radius: 14px;">
                            <circle cx="11" cy="11" r="8"></circle>
                            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                        </svg>
                        <div>
                            <h3 style="font-size: 1.2rem; font-weight: 700; margin: 0; color: #1e2f4e;">Search Sticker Records</h3>
                            <p style="margin: 0; font-size: 0.75rem; color: #6c81a3;">Find by Member ID, Member No, Sticker No, or Vehicle No</p>
                        </div>
                    </div>
                    
                    <!-- Form Grid -->
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(210px, 1fr)); gap: 1.5rem; align-items: end;">
                        
                        <div style="display: flex; flex-direction: column; gap: 0.45rem;">
                            <label style="font-size: 0.7rem; font-weight: 800; text-transform: uppercase; letter-spacing: 0.5px; color: #4a5b7a;">MEMBER ID</label>
                            <asp:TextBox ID="txtMemberID" runat="server" 
                                style="width: 100%; padding: 0.7rem 1rem; font-size: 0.9rem; border: 1px solid #cfdfed; border-radius: 16px; background: white; transition: 0.2s; font-family: inherit;"
                                placeholder="e.g. 1001" 
                                onfocus="this.style.borderColor='#3b82f6'; this.style.boxShadow='0 0 0 3px rgba(59,130,246,0.1)'" 
                                onblur="this.style.borderColor='#cfdfed'; this.style.boxShadow='none'" />
                        </div>
                        
                        <div style="display: flex; flex-direction: column; gap: 0.45rem;">
                            <label style="font-size: 0.7rem; font-weight: 800; text-transform: uppercase; letter-spacing: 0.5px; color: #4a5b7a;">MEMBER NO</label>
                            <asp:TextBox ID="txtMemberNo" runat="server" 
                                style="width: 100%; padding: 0.7rem 1rem; font-size: 0.9rem; border: 1px solid #cfdfed; border-radius: 16px; background: white; transition: 0.2s;"
                                placeholder="e.g. M-1234" 
                                onfocus="this.style.borderColor='#3b82f6'; this.style.boxShadow='0 0 0 3px rgba(59,130,246,0.1)'" 
                                onblur="this.style.borderColor='#cfdfed'; this.style.boxShadow='none'" />
                        </div>
                        
                        <div style="display: flex; flex-direction: column; gap: 0.45rem;">
                            <label style="font-size: 0.7rem; font-weight: 800; text-transform: uppercase; letter-spacing: 0.5px; color: #4a5b7a;">STICKER NO</label>
                            <asp:TextBox ID="txtStickerNo" runat="server" 
                                style="width: 100%; padding: 0.7rem 1rem; font-size: 0.9rem; border: 1px solid #cfdfed; border-radius: 16px; background: white; transition: 0.2s;"
                                placeholder="e.g. S-2024-001"
                                onfocus="this.style.borderColor='#3b82f6'; this.style.boxShadow='0 0 0 3px rgba(59,130,246,0.1)'" 
                                onblur="this.style.borderColor='#cfdfed'; this.style.boxShadow='none'" />
                        </div>
                        
                        <div style="display: flex; flex-direction: column; gap: 0.45rem;">
                            <label style="font-size: 0.7rem; font-weight: 800; text-transform: uppercase; letter-spacing: 0.5px; color: #4a5b7a;">VEHICLE NO</label>
                            <asp:TextBox ID="txtVehicleNo" runat="server" 
                                style="width: 100%; padding: 0.7rem 1rem; font-size: 0.9rem; border: 1px solid #cfdfed; border-radius: 16px; background: white; transition: 0.2s;"
                                placeholder="e.g. ABC-123"
                                onfocus="this.style.borderColor='#3b82f6'; this.style.boxShadow='0 0 0 3px rgba(59,130,246,0.1)'" 
                                onblur="this.style.borderColor='#cfdfed'; this.style.boxShadow='none'" />
                        </div>
                        
                        <div style="display: flex; flex-direction: column; gap: 0.45rem;">
                            <label style="font-size: 0.7rem; font-weight: 800; text-transform: uppercase; letter-spacing: 0.5px; color: transparent;">&nbsp;</label>
                            <asp:Button ID="btnSearch" runat="server" Text="Search Records" OnClick="btnSearch_Click"
                                style="background: linear-gradient(135deg, #2563eb, #3b82f6); color: white; border: none; padding: 0.75rem 1.5rem; border-radius: 40px; font-weight: 700; font-size: 0.85rem; cursor: pointer; transition: all 0.2s ease; box-shadow: 0 2px 6px rgba(37,99,235,0.2); width: 100%;"
                                onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 8px 18px rgba(37,99,235,0.25)'"
                                onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(37,99,235,0.2)'" />
                        </div>
                    </div>
                </div>
                
                <!-- Add Vehicle Button with Member Info Display -->
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; flex-wrap: wrap; gap: 1rem;">
                    <asp:Button ID="btnAddVehicle" runat="server" Text="+ Add New Vehicle" 
                        OnClick="btnAddVehicle_Click" 
                        style="background: linear-gradient(135deg, #2563eb, #3b82f6); color: white; border: none; padding: 0.7rem 1.8rem; border-radius: 40px; font-weight: 600; font-size: 0.9rem; cursor: pointer; transition: all 0.2s ease; box-shadow: 0 2px 6px rgba(37,99,235,0.2);" />
                    
                    <asp:Label ID="lblSelectedMemberInfo" runat="server" 
                        style="font-size: 0.85rem; color: #5b6e8c; background: #f0f4f9; padding: 0.5rem 1rem; border-radius: 20px; display: inline-block;">
                    </asp:Label>
                </div>

                <!-- TABLE SECTION -->
                <div style="background: #ffffff; border-radius: 20px; border: 1px solid #eef2f9; overflow-x: auto; margin-bottom: 1.8rem;">
                    <asp:GridView ID="gvData" runat="server" AutoGenerateColumns="false"
    EmptyDataText="No sticker records found matching criteria" 
    OnRowDataBound="gvData_RowDataBound"
    DataKeyNames="VehicleID"
    GridLines="None"
    CellPadding="12"
    CellSpacing="0"
    Width="100%"
    BorderWidth="0"
    style="border-collapse: collapse; width: 100%; min-width: 900px;">
    
    <Columns>
        <asp:TemplateField HeaderText="ACTIONS" ItemStyle-Width="120px">
            <ItemTemplate>
                <asp:HiddenField ID="hfVehicleID" runat="server" Value='<%# Eval("VehicleID") %>' />
                <asp:HiddenField ID="hfMemberID" runat="server" Value='<%# Eval("MemberID") %>' />
                <asp:HiddenField ID="hfMemberNo" runat="server" Value='<%# Eval("MemberNo") %>' />
                <asp:Panel ID="pnlView" runat="server">
                    <asp:Button ID="btnEdit" runat="server" Text="Edit" 
                        CommandName="CustomEdit" CommandArgument='<%# Container.DataItemIndex %>'
                        OnClick="btnEdit_Click" 
                        style="background: #3b82f6; color: white; border: none; padding: 4px 12px; border-radius: 20px; margin-right: 5px; cursor: pointer; font-size: 0.75rem;" />
                    <asp:Button ID="btnDelete" runat="server" Text="Delete" 
                        CommandName="CustomDelete" CommandArgument='<%# Container.DataItemIndex %>'
                        OnClick="btnDelete_Click" 
                        style="background: #ef4444; color: white; border: none; padding: 4px 12px; border-radius: 20px; cursor: pointer; font-size: 0.75rem;" 
                        OnClientClick="return confirm('Are you sure you want to delete this vehicle?');" />
                </asp:Panel>
                <asp:Panel ID="pnlEdit" runat="server" Visible="false">
                    <asp:Button ID="btnUpdate" runat="server" Text="Save" 
                        OnClick="btnUpdate_Click" 
                        style="background: #10b981; color: white; border: none; padding: 4px 12px; border-radius: 20px; margin-right: 5px; cursor: pointer; font-size: 0.75rem;" />
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel" 
                        OnClick="btnCancel_Click" 
                        style="background: #6b7280; color: white; border: none; padding: 4px 12px; border-radius: 20px; cursor: pointer; font-size: 0.75rem;" />
                </asp:Panel>
            </ItemTemplate>
        </asp:TemplateField>
        
        
        <asp:TemplateField HeaderText="MEMBER ID">
            <ItemTemplate>
                <asp:Label ID="lblMemberID" runat="server" Text='<%# Eval("MemberID") %>'></asp:Label>
            </ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox ID="txtEditMemberID" runat="server" Text='<%# Eval("MemberID") %>' CssClass="table-input-sm" style="width: 70px;" ReadOnly="true" BackColor="#f5f5f5" />
            </EditItemTemplate>
        </asp:TemplateField>
        
        <asp:TemplateField HeaderText="MEMBER NO">
            <ItemTemplate>
                <asp:Label ID="lblMemberNo" runat="server" Text='<%# Eval("MemberNo") %>'></asp:Label>
            </ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox ID="txtEditMemberNo" runat="server" Text='<%# Eval("MemberNo") %>' CssClass="table-input-sm" ReadOnly="true" BackColor="#f5f5f5" />
            </EditItemTemplate>
        </asp:TemplateField>
        
        <asp:TemplateField HeaderText="STICKER NO">
            <ItemTemplate>
                <asp:Label ID="lblStickerNo" runat="server" Text='<%# Eval("StickerNo") %>'></asp:Label>
            </ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox ID="txtEditStickerNo" runat="server" Text='<%# Eval("StickerNo") %>' CssClass="table-input-sm" />
            </EditItemTemplate>
        </asp:TemplateField>
        
        <asp:TemplateField HeaderText="VEHICLE NO">
            <ItemTemplate>
                <asp:Label ID="lblVehicleNo" runat="server" Text='<%# Eval("VehicleNo") %>'></asp:Label>
            </ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox ID="txtEditVehicleNo" runat="server" Text='<%# Eval("VehicleNo") %>' CssClass="table-input-sm" />
            </EditItemTemplate>
        </asp:TemplateField>
        
        <asp:TemplateField HeaderText="MODEL">
            <ItemTemplate>
                <asp:Label ID="lblModel" runat="server" Text='<%# Eval("Model") %>'></asp:Label>
            </ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox ID="txtEditModel" runat="server" Text='<%# Eval("Model") %>' CssClass="table-input-sm" />
            </EditItemTemplate>
        </asp:TemplateField>
        
        <asp:TemplateField HeaderText="MAKE">
            <ItemTemplate>
                <asp:Label ID="lblMake" runat="server" Text='<%# Eval("Make") %>'></asp:Label>
            </ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox ID="txtEditMake" runat="server" Text='<%# Eval("Make") %>' CssClass="table-input-sm" />
            </EditItemTemplate>
        </asp:TemplateField>
        
        <asp:TemplateField HeaderText="ISSUE DATE">
            <ItemTemplate>
                <asp:Label ID="lblIssueDate" runat="server" Text='<%# Eval("IssueDate", "{0:yyyy-MM-dd}") %>'></asp:Label>
            </ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox ID="txtEditIssueDate" runat="server" Text='<%# Eval("IssueDate", "{0:yyyy-MM-dd}") %>' CssClass="table-input-sm" type="date" />
            </EditItemTemplate>
        </asp:TemplateField>
        
        <asp:TemplateField HeaderText="STATUS">
            <ItemTemplate>
                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="table-input-sm">
                    <asp:ListItem Text="Active" Value="Active" />
                    <asp:ListItem Text="Blocked" Value="Blocked" />
                    <asp:ListItem Text="Lost" Value="Lost" />
                    <asp:ListItem Text="Replaced" Value="Replaced" />
                </asp:DropDownList>
            </ItemTemplate>
            <EditItemTemplate>
                <asp:DropDownList ID="ddlEditStatus" runat="server" CssClass="table-input-sm">
                    <asp:ListItem Text="Active" Value="Active" />
                    <asp:ListItem Text="Blocked" Value="Blocked" />
                    <asp:ListItem Text="Lost" Value="Lost" />
                    <asp:ListItem Text="Replaced" Value="Replaced" />
                </asp:DropDownList>
            </EditItemTemplate>
        </asp:TemplateField>
        
        <asp:TemplateField HeaderText="REMARKS">
            <ItemTemplate>
                <asp:TextBox ID="txtRemarks" runat="server" Text='<%# Eval("Remarks") %>' 
                    TextMode="MultiLine" Rows="1" CssClass="table-input-sm" style="width: 150px;" />
            </ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox ID="txtEditRemarks" runat="server" Text='<%# Eval("Remarks") %>' 
                    TextMode="MultiLine" Rows="2" CssClass="table-input-sm" style="width: 150px;" />
            </EditItemTemplate>
        </asp:TemplateField>
    </Columns>
    
    <HeaderStyle BackColor="#F8FAFE" ForeColor="#334155" Font-Bold="True" Font-Size="11px" Height="45px" />
    <RowStyle BackColor="White" ForeColor="#1E2A44" Height="50px" />
    <AlternatingRowStyle BackColor="#FCFDFF" />
    
    <EmptyDataTemplate>
        <div style="text-align: center; padding: 3rem 1.5rem;">
            <p>No vehicle records found. Click "Add New Vehicle" to create one.</p>
        </div>
    </EmptyDataTemplate>
</asp:GridView>
                </div>
                
                <!-- SAVE BUTTON -->
                <div style="display: flex; justify-content: flex-end; padding-top: 0.5rem; border-top: 1px solid #eef2f8; margin-top: 0.5rem;">
                    <asp:Button ID="btnSave" runat="server" Text="Save Status Changes" OnClick="btnSave_Click"
                        style="background: #10b981; color: white; border: none; padding: 0.8rem 2.2rem; border-radius: 44px; font-weight: 700; font-size: 0.9rem; cursor: pointer; transition: all 0.2s ease; box-shadow: 0 2px 6px rgba(16,185,129,0.2); min-width: 210px;"
                        onmouseover="this.style.background='#059669'; this.style.transform='translateY(-1px)'; this.style.boxShadow='0 8px 18px rgba(16,185,129,0.25)'"
                        onmouseout="this.style.background='#10b981'; this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(16,185,129,0.2)'" />
                </div>
                
            </div>
        </div>
    </div>
</asp:Content>