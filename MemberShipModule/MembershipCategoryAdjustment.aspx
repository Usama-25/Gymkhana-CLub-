<%@ Page Title="Membership Category Adjustment" Language="C#" MasterPageFile="~/MemberShipModule/Site.master"
    AutoEventWireup="true" CodeFile="MembershipCategoryAdjustment.aspx.cs"
    Inherits="MemberShipModule.MembershipCategoryAdjustment" %>

<asp:Content ID="HeadStyles" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Outfit', sans-serif !important; background-color: #faf7f2; }
        
        .table { width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left; }
        .table th { background: #1A1A2E; color: #C9A84C; font-weight: 700; padding: 0.75rem 1rem; border-bottom: 1px solid #e0d5c5; text-align: left; font-size: 0.875rem; }
        .table td { padding: 0.75rem 1rem; border-bottom: 1px solid #F7F3EE; color: #1A1A2E; vertical-align: middle; font-size: 0.9rem; }
        .table tr:hover { background-color: #faf7f2; }

        .radio-group { display: flex; gap: 2rem; align-items: center; margin-bottom: 0.5rem; }
        .radio-group label { display: flex; align-items: center; gap: 0.5rem; cursor: pointer; font-weight: 500; color: #1A1A2E; font-size: 0.95rem; }
        .radio-group input[type="radio"] { width: 18px; height: 18px; accent-color: #C9A84C; cursor: pointer; }

        .comparison-box { background: #faf7f2; border: 1px solid #e0d5c5; border-radius: 8px; padding: 1rem; }
        .comparison-box h4 { font-weight: 700; font-size: 0.9rem; color: #1A1A2E; margin: 0 0 0.75rem 0; text-transform: uppercase; letter-spacing: 0.05em; border-bottom: 2px solid #e0d5c5; padding-bottom: 0.5rem; }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="Server">
    <div class="page-wrapper" style="padding: 1.5rem; width: 100%; max-width: 100%; margin: 0 auto; font-family: 'Outfit', sans-serif;">
        
        <!-- Panel: Member Search -->
        <asp:Panel ID="pnlMemberSearch" runat="server">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; margin-bottom: 2rem;">
                <div class="card-header" style="padding: 16px 26px; border-bottom: 1px solid #e0d5c5; background: linear-gradient(135deg, #1A1A2E, #2d2d5e);">
                    <h1 style="font-size: 1.5rem; font-weight: 700; color: #fff; margin: 0;">Find Member</h1>
                    <p style="color: #E8D5A3; font-size: 0.95rem; margin: 0.25rem 0 0 0;">Search for a member to adjust their category.</p>
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
                                        <asp:LinkButton ID="btnAdjustCategory" runat="server" CommandName="AdjustCategory" CommandArgument='<%# Eval("MemberNo") %>' 
                                           style="display: inline-flex; align-items: center; justify-content: center; padding: 6px 12px; border-radius: 6px; background: #faf7f2; border: 1px solid #f5ecd5; color: #C9A84C; font-weight: 600; text-decoration: none; transition: all 0.2s;">
                                           Adjust Category
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

        <!-- Panel: Category Adjustment Form -->
        <asp:Panel ID="pnlCategoryAdjustment" runat="server" Visible="false">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                <asp:Button ID="btnBackToSearch" runat="server" Text="← Back to Search" OnClick="btnBackToSearch_Click" style="background: transparent; border: none; padding: 0; color: #7a7a7a; font-weight: 600; font-size: 0.95rem; cursor: pointer;" />
            </div>

            <div class="card" style="background-color: #ffffff; border-radius: 12px; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; margin-bottom: 2rem;">
                <div class="card-header" style="padding: 16px 26px; border-bottom: 1px solid #e0d5c5; background: linear-gradient(135deg, #1A1A2E, #2d2d5e);">
                    <h1 style="font-size: 1.5rem; font-weight: 700; color: #fff; margin: 0;">Membership Category Adjustment</h1>
                    <p style="color: #E8D5A3; font-size: 0.95rem; margin: 0.25rem 0 0 0;">Change member's category and member type with full audit trail</p>
                </div>

                <div class="card-body" style="padding: 1.5rem;">
                    <asp:HiddenField ID="hdnMemberProfileID" runat="server" Value="0" />
                    <asp:HiddenField ID="hdnMID" runat="server" Value="0" />

                    <!-- Radio Buttons: Member Type Selection -->
                    <div style="margin-bottom: 1.5rem; background: #faf7f2; padding: 1rem; border-radius: 8px; border: 1px solid #e0d5c5;">
                        <div class="radio-group">
                            <label>
                                <asp:RadioButton ID="rbMember" runat="server" GroupName="MemberType" Checked="true" />
                                Member
                            </label>
                            <label>
                                <asp:RadioButton ID="rbSupplementary" runat="server" GroupName="MemberType" />
                                Supplementary
                            </label>
                        </div>
                    </div>

                    <!-- Request Info Section -->
                    <div style="margin-bottom: 2rem;">
                        <h2 style="font-size: 1.25rem; font-weight: 700; color: #1A1A2E; margin-bottom: 1rem;">Request Information</h2>
                        
                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-bottom: 1rem; background: #faf7f2; padding: 1rem; border-radius: 8px; border: 1px solid #e0d5c5;">
                            <div>
                                <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Request Date</label>
                                <asp:TextBox ID="txtRequestDate" runat="server" TextMode="Date" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                            </div>
                            <div>
                                <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Request No</label>
                                <asp:TextBox ID="txtRequestNo" runat="server" placeholder="Auto-generated" ReadOnly="true" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none; background: #F7F3EE; color: #7a7a7a;" />
                            </div>
                            <div>
                                <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Member No</label>
                                <asp:TextBox ID="txtMemberNo" runat="server" placeholder="Enter Member No" AutoPostBack="true" OnTextChanged="txtMemberNo_TextChanged" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                            </div>
                            <div>
                                <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Member Name</label>
                                <asp:TextBox ID="txtMemberName" runat="server" ReadOnly="true" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none; background: #F7F3EE; color: #7a7a7a;" />
                            </div>
                            <div>
                                <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">M_ID</label>
                                <asp:TextBox ID="txtDisplayMID" runat="server" ReadOnly="true" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none; background: #F7F3EE; color: #7a7a7a;" />
                            </div>
                            <div>
                                <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">A/C Status</label>
                                <asp:TextBox ID="txtACStatus" runat="server" ReadOnly="true" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none; background: #F7F3EE; color: #7a7a7a;" />
                            </div>
                        </div>


                    </div>

                    <!-- Membership Category Section -->
                    <div style="margin-bottom: 2rem;">
                        <h2 style="font-size: 1.25rem; font-weight: 700; color: #1A1A2E; margin-bottom: 1rem;">Membership Category</h2>
                        
                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1rem; margin-bottom: 1.5rem;">
                            <!-- Existing Membership Category -->
                            <div class="comparison-box">
                                <h4>Existing Membership Category</h4>
                                <div style="display: grid; gap: 0.75rem;">
                                    <div>
                                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Category</label>
                                        <asp:TextBox ID="txtExistingCategory" runat="server" ReadOnly="true" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none; background: #e0d5c5; color: #7a7a7a;" />
                                    </div>
                                    <div style="display: grid; grid-template-columns: 1fr auto auto; gap: 0.5rem; align-items: end;">
                                        <div>
                                            <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Member Type</label>
                                            <asp:TextBox ID="txtExistingMemberType" runat="server" ReadOnly="true" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none; background: #e0d5c5; color: #7a7a7a;" />
                                        </div>
                                        <div>
                                            <asp:TextBox ID="txtExistingTypeCode" runat="server" ReadOnly="true" Width="60px" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box; outline: none; background: #e0d5c5; color: #7a7a7a;" />
                                        </div>
                                        <div>
                                            <asp:TextBox ID="txtExistingTypeSeq" runat="server" ReadOnly="true" Width="40px" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box; outline: none; background: #e0d5c5; color: #7a7a7a;" />
                                        </div>
                                    </div>
                                    <div>
                                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Existing Member No</label>
                                        <asp:TextBox ID="txtExistingMemberNo" runat="server" ReadOnly="true" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none; background: #e0d5c5; color: #7a7a7a;" />
                                    </div>
                                </div>
                            </div>

                            <!-- New Membership Category -->
                            <div class="comparison-box" style="background: #faf7f2; border-color: #bfdbfe;">
                                <h4 style="color: #1e40af; border-color: #bfdbfe;">New Membership Details</h4>
                                <div style="display: grid; gap: 0.75rem;">
                                    <div style="display: grid; grid-template-columns: 1fr auto auto auto; gap: 0.5rem; align-items: end;">
                                        <div>
                                            <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Member Type</label>
                                            <asp:DropDownList ID="ddlNewMemberType" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlNewMemberType_SelectedIndexChanged" style="padding: 0.6rem 0.8rem; border: 1px solid #93c5fd; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none; background: white;">
                                                <asp:ListItem Value="">Select Type</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                        <div>
                                            <asp:TextBox ID="txtNewTypeCode" runat="server" Width="60px" placeholder="MCR" style="padding: 0.6rem 0.8rem; border: 1px solid #93c5fd; border-radius: 6px; box-sizing: border-box; outline: none;" />
                                        </div>
                                        <div>
                                            <asp:TextBox ID="txtNewTypeSeq" runat="server" Width="40px" placeholder="1" style="padding: 0.6rem 0.8rem; border: 1px solid #93c5fd; border-radius: 6px; box-sizing: border-box; outline: none;" />
                                        </div>
                                        <div>
                                            <asp:TextBox ID="txtNewTypeFlag" runat="server" Width="40px" placeholder="R" style="padding: 0.6rem 0.8rem; border: 1px solid #93c5fd; border-radius: 6px; box-sizing: border-box; outline: none;" />
                                        </div>
                                    </div>
                                    <div>
                                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">New Member No</label>
                                        <asp:TextBox ID="txtNewMemberNo" runat="server" style="padding: 0.6rem 0.8rem; border: 1px solid #93c5fd; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                                    </div>
                                    <div>
                                        <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Reason</label>
                                        <asp:TextBox ID="txtReason" runat="server" TextMode="MultiLine" Rows="2" placeholder="Enter reason for category change" style="padding: 0.6rem 0.8rem; border: 1px solid #93c5fd; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Action Buttons -->
                        <div style="display: flex; gap: 1rem;">
                            <asp:Button ID="btnSave" runat="server" Text="Save Changes" OnClick="btnSave_Click" style="padding: 0.75rem 2rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; border: none; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);" />
                            <asp:Button ID="btnClear" runat="server" Text="Clear" OnClick="btnClear_Click" style="padding: 0.75rem 2rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background-color: white; color: #7a7a7a; border: 1px solid #e0d5c5;" />
                        </div>
                    </div>

                    <!-- Change Log Section -->
                    <div>
                        <h2 style="font-size: 1.25rem; font-weight: 700; color: #1A1A2E; margin-bottom: 1rem;">Change History</h2>
                        <div style="border: 1px solid #e0d5c5; border-radius: 8px; overflow: hidden; width: 100%; overflow-x: auto;">
                            <asp:GridView ID="gvChangeLog" runat="server" AutoGenerateColumns="False" Width="100%" GridLines="None" CssClass="table" EmptyDataText="No change history found for this member.">
                                <Columns>
                                    <asp:BoundField DataField="ChangeType" HeaderText="Change Type" />
                                    <asp:BoundField DataField="FieldName" HeaderText="Field" />
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
    </div>
</asp:Content>
