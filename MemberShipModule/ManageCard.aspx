<%@ Page Title="Manage RFID Cards" Language="C#" MasterPageFile="~/MemberShipModule/Site.master"
    AutoEventWireup="true" CodeFile="ManageCard.aspx.cs" Inherits="Form_cell.Applicant_Form.ManageCard" %>

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
        .status-block { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
        .status-lost { background: #fef3c7; color: #92400e; border: 1px solid #fde68a; }
        .status-replaced { background: #f5ecd5; color: #075985; border: 1px solid #e0d5c5; }
        
        .modal-overlay { display: flex; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center; }
        .modal-content { background: white; padding: 2rem; border-radius: 12px; width: 500px; max-width: 90%; box-shadow: 0 10px 25px rgba(0,0,0,0.2); }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-wrapper" style="padding: 1.5rem; width: 100%; max-width: 100%; margin: 0 auto; font-family: 'Outfit', sans-serif;">
        
        <!-- Header Section -->
        <div class="card" style="background-color: #ffffff; border-radius: 12px; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; margin-bottom: 2rem;">
            <div class="card-header" style="padding: 16px 26px; border-bottom: 1px solid #e0d5c5; background: linear-gradient(135deg, #1A1A2E, #2d2d5e); display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <h1 style="font-size: 1.5rem; font-weight: 700; color: #fff; margin: 0;">RFID Card Management</h1>
                    <p style="color: #E8D5A3; font-size: 0.95rem; margin: 0.25rem 0 0 0;">Search, block, or update status of membership identification cards.</p>
                </div>
            </div>

            <div class="card-body" style="padding: 1.5rem;">
                <!-- Search Filters -->
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1rem; margin-bottom: 1.5rem; background: #faf7f2; padding: 1rem; border-radius: 8px; border: 1px solid #e0d5c5;">
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Card No / RFID Tag</label>
                        <asp:TextBox ID="txtSearchCardNo" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" placeholder="Scan or enter tag..." />
                    </div>
                    <div>
                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Member No</label>
                        <asp:TextBox ID="txtSearchMemberNo" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" placeholder="e.g. R-1234" />
                    </div>
                    <div style="display: flex; gap: 0.5rem; align-items: end;">
                        <asp:Button ID="btnSearch" runat="server" Text="Search Cards" OnClick="btnSearch_Click" 
                            style="flex: 2; padding: 0.6rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; border: none; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);" />
                    </div>
                </div>

                <!-- Results Grid -->
                <asp:Panel ID="resultsPanel" runat="server" Visible="false">
                    <div style="border: 1px solid #e0d5c5; border-radius: 8px; overflow: hidden; width: 100%; overflow-x: auto;">
                        <asp:GridView ID="gvCards" runat="server" AutoGenerateColumns="False" 
                            CssClass="table" GridLines="None" Width="100%" DataKeyNames="CardID" OnSelectedIndexChanged="gvCards_SelectedIndexChanged">
                            <Columns>
                                <asp:BoundField DataField="MemberNoWithSuffix" HeaderText="Member No" />
                                <asp:BoundField DataField="CardNo" HeaderText="RFID Tag" />
                                <asp:TemplateField HeaderText="Holder Name">
                                    <ItemTemplate>
                                        <div style="display: flex; flex-direction: column;">
                                            <span style="font-weight: 600;"><%# Eval("HolderName") %></span>
                                            <span style="font-size: 0.75rem; color: #7a7a7a;"><%# Eval("CardHolderType") %></span>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <span class='<%# "status-badge status-" + Eval("CardStatus").ToString().ToLower() %>'>
                                            <%# Eval("CardStatus") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="ExpiryDate" HeaderText="Expiry Date" DataFormatString="{0:dd MMM yyyy}" />
                                <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnEditStatus" runat="server" CommandName="Select" 
                                           style="display: inline-flex; align-items: center; justify-content: center; padding: 6px 12px; border-radius: 6px; background: #faf7f2; border: 1px solid #f5ecd5; color: #C9A84C; font-weight: 600; text-decoration: none; transition: all 0.2s;">
                                           Update Status
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div style="padding: 3rem; text-align: center;">
                                    <h3 style="color: #7a7a7a; font-weight: 600;">No cards found matching your criteria.</h3>
                                    <p style="color: #a09080; font-size: 0.9rem;">Please check the member number or tag and try again.</p>
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </asp:Panel>
            </div>
        </div>

        <!-- Status Update Modal -->
        <asp:Panel ID="pnlUpdateStatus" runat="server" class="modal-overlay" Visible="false">
            <div class="modal-content">
                <h2 style="margin-top: 0; color: #1A1A2E; font-weight: 700; border-bottom: 1px solid #e0d5c5; padding-bottom: 1rem;">Update Card Status</h2>
                
                <div style="background: #faf7f2; padding: 1rem; border-radius: 8px; border: 1px solid #e0d5c5; margin: 1.5rem 0;">
                    <p style="font-size: 0.9rem; color: #E8D5A3; margin: 0;">Current Selection:</p>
                    <p style="font-weight: 600; color: #1A1A2E; margin: 0.25rem 0 0 0;"><asp:Literal ID="litSelectedCardInfo" runat="server" /></p>
                </div>

                <div style="margin-bottom: 1rem;">
                    <label style="font-size: 0.9rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.5rem;">New Status</label>
                    <asp:DropDownList ID="ddlNewStatus" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none; background: white;">
                        <asp:ListItem Text="Active" Value="Active"></asp:ListItem>
                        <asp:ListItem Text="Blocked" Value="Block"></asp:ListItem>
                        <asp:ListItem Text="Lost" Value="Lost"></asp:ListItem>
                        <asp:ListItem Text="Replaced" Value="Replaced"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                
                <div style="margin-bottom: 1.5rem;">
                    <label style="font-size: 0.9rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.5rem;">Remarks / Reason</label>
                    <asp:TextBox ID="txtStatusRemarks" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" TextMode="MultiLine" Rows="3" placeholder="Enter reason for status change..."></asp:TextBox>
                </div>
                
                <div style="display: flex; justify-content: flex-end; gap: 1rem;">
                    <asp:Button ID="btnCancelUpdate" runat="server" Text="Cancel" OnClick="btnCancelUpdate_Click" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background-color: white; color: #7a7a7a; border: 1px solid #e0d5c5;" />
                    <asp:Button ID="btnSaveStatus" runat="server" Text="Save Changes" OnClick="btnSaveStatus_Click" style="padding: 0.75rem 2rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; border: none; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);" />
                </div>
            </div>
        </asp:Panel>

    </div>
</asp:Content>
