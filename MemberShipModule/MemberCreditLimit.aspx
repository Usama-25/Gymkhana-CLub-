<%@ Page Title="Member Credit Limit" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true"
    CodeFile="MemberCreditLimit.aspx.cs" Inherits="MemberCreditLimit" %>
    <asp:Content ID="HeadStyles" ContentPlaceHolderID="HeadContent" runat="server">
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <style>
            body { font-family: 'Outfit', sans-serif !important; background-color: #faf7f2; }
            .table-container { background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
            .table { width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left; }
            .table th { background: #1A1A2E !important; color: #C9A84C !important; font-weight: 700 !important; padding: 0.75rem 1rem !important; border-bottom: 1px solid #e0d5c5 !important; text-align: left !important; font-size: 0.875rem !important; }
            .table td { padding: 0.75rem 1rem !important; border-bottom: 1px solid #F7F3EE !important; color: #1A1A2E !important; vertical-align: middle !important; font-size: 0.9rem !important; text-align: left !important; }
            .table tr:hover { background-color: #faf7f2 !important; }
            .text-right { text-align: right !important; }
            .table th.text-right { text-align: right !important; }
            
            /* Pager Styles */
            .pager-style td { padding: 0 !important; border: none !important; }
            .pager-style table { margin: 1rem auto; background: #faf7f2; border: 1px solid #e0d5c5; border-radius: 8px; border-collapse: separate; overflow: hidden; }
            .pager-style span, .pager-style a { display: inline-block; padding: 0.5rem 0.85rem; text-decoration: none; font-size: 0.9rem; font-weight: 600; color: #1A1A2E; border-right: 1px solid #e0d5c5; transition: all 0.2s ease; }
            .pager-style span { background: #1A1A2E; color: #C9A84C; }
            .pager-style a:hover { background: #f5ecd5; color: #8B5E3C; }
            .pager-style tr td:last-child a, .pager-style tr td:last-child span { border-right: none; }
        </style>
    </asp:Content>

    <asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="Server">

        <div class="page-wrapper" style="padding: 1.5rem; width: 100%; max-width: 100%; margin: 0 auto; font-family: 'Outfit', sans-serif;">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; margin-bottom: 2rem;">

                <div class="card-header" style="padding: 16px 26px; border-bottom: 1px solid #e0d5c5; background: linear-gradient(135deg, #1A1A2E, #2d2d5e);">
                    <h1 style="font-size: 1.5rem; font-weight: 700; color: #fff; margin: 0;">Member Credit Limit</h1>
                    <p style="color: #E8D5A3; font-size: 0.95rem; margin: 0.25rem 0 0 0;">Configure specific overriding credit limits for individual members.</p>
                </div>

                <div class="card-body" style="padding: 1.5rem;">
                    <!-- Individual Member Credit Limit Section -->
                    <div style="margin-bottom: 2rem;">
                        <div style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 1.5rem; padding-bottom: 0.5rem; border-bottom: 1px solid #e0d5c5;">
                            <div style="color: #C9A84C; display: flex; align-items: center;">
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                    <circle cx="12" cy="7" r="4"></circle>
                                </svg>
                            </div>
                            <div>
                                <h2 style="font-size: 1.25rem; font-weight: 700; margin: 0; color: #1A1A2E;">Set Specific Credit Limit</h2>
                                <p style="font-size: 0.9rem; color: #8B5E3C; margin: 0.25rem 0 0 0;">Set a custom credit limit overriding the category defaults for specific members.</p>
                            </div>
                        </div>

                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; background: #faf7f2; padding: 1.25rem; border-radius: 8px; border: 1px solid #e0d5c5; align-items: end; margin-bottom: 1.5rem;">
                            <div>
                                <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Member No</label>
                                <asp:TextBox ID="txtMemberNoSearch" runat="server" placeholder="Enter Member No" style="display: block; width: 100%; padding: 0.6rem 0.8rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; outline: none; box-sizing: border-box;" />
                            </div>
                            <div>
                                <asp:Button ID="btnSearchMember" runat="server" Text="Search Member" OnClick="btnSearchMember_Click" style="display: inline-block; text-align: center; vertical-align: middle; padding: 0.6rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: all 0.15s ease; border: 1px solid #e0d5c5; line-height: 1; text-decoration: none; background-color: white; color: #7a7a7a; width: 100%;" />
                            </div>
                            <div>
                                <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Member Name</label>
                                <asp:TextBox ID="txtMemberName" runat="server" ReadOnly="true" style="display: block; width: 100%; padding: 0.6rem 0.8rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #1A1A2E; background-color: #f5ecd5; border: 1px solid #e0d5c5; border-radius: 6px; outline: none; box-sizing: border-box;" />
                            </div>
                            <div>
                                <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">Current Limit (PKR)</label>
                                <asp:TextBox ID="txtMemberCurrentLimit" runat="server" ReadOnly="true" style="display: block; width: 100%; padding: 0.6rem 0.8rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #1A1A2E; background-color: #f5ecd5; border: 1px solid #e0d5c5; border-radius: 6px; outline: none; box-sizing: border-box;" />
                            </div>
                        </div>

                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; align-items: end;">
                            <div>
                                <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C; display: block; margin-bottom: 0.4rem;">New Credit Limit (PKR)</label>
                                <asp:TextBox ID="txtMemberNewLimit" runat="server" placeholder="Enter new credit limit" TextMode="Number" style="display: block; width: 100%; padding: 0.6rem 0.8rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; outline: none; box-sizing: border-box;" />
                            </div>
                            <div>
                                <asp:HiddenField ID="hfMemberIDSearch" runat="server" />
                                <asp:Button ID="btnSaveMemberLimit" runat="server" Text="Save Individual Limit" OnClick="btnSaveMemberLimit_Click" style="display: inline-block; text-align: center; vertical-align: middle; padding: 0.6rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: all 0.15s ease; border: none; line-height: 1; text-decoration: none; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2); width: 100%;" />
                            </div>
                            <div style="display: flex; align-items: center; padding-bottom: 0.5rem;">
                                <asp:Label ID="lblMemberMessage" runat="server" ForeColor="Green" Font-Bold="true" style="font-size: 0.95rem;"></asp:Label>
                            </div>
                        </div>
                    </div>

                    <!-- Custom Member Limits Grid Section -->
                    <div style="padding-top: 1.5rem; border-top: 1px solid #e0d5c5;">
                        <div style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 1.5rem; padding-bottom: 0.5rem; border-bottom: 1px solid #e0d5c5;">
                            <div style="color: #C9A84C; display: flex; align-items: center;">
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                                    <line x1="8" y1="6" x2="21" y2="6"></line>
                                    <line x1="8" y1="12" x2="21" y2="12"></line>
                                    <line x1="8" y1="18" x2="21" y2="18"></line>
                                    <line x1="3" y1="6" x2="3.01" y2="6"></line>
                                    <line x1="3" y1="12" x2="3.01" y2="12"></line>
                                    <line x1="3" y1="18" x2="3.01" y2="18"></line>
                                </svg>
                            </div>
                            <div>
                                <h2 style="font-size: 1.25rem; font-weight: 700; margin: 0; color: #1A1A2E;">Custom Member Limits</h2>
                                <p style="font-size: 0.9rem; color: #8B5E3C; margin: 0.25rem 0 0 0;">Members with a specific overriding credit limit.</p>
                            </div>
                        </div>

                        <div class="table-container">
                            <asp:GridView ID="gvMemberCreditLimits" runat="server" AutoGenerateColumns="false" CssClass="table"
                                GridLines="None" Width="100%" AllowPaging="true" PageSize="10" OnPageIndexChanging="gvMemberCreditLimits_PageIndexChanging"
                                UseAccessibleHeader="true">
                                <PagerStyle CssClass="pager-style" />
                                <Columns>
                                    <asp:BoundField DataField="MemberNo" HeaderText="Member No" HeaderStyle-Width="20%" ItemStyle-Width="20%" />
                                    <asp:BoundField DataField="ApplicantName" HeaderText="Name" HeaderStyle-Width="40%" ItemStyle-Width="40%" />
                                    <asp:BoundField DataField="MembershipCategory" HeaderText="Category" HeaderStyle-Width="20%" ItemStyle-Width="20%" />
                                    <asp:BoundField DataField="CreditLimit" HeaderText="Specific Limit" DataFormatString="PKR {0:N0}" HeaderStyle-Width="20%" ItemStyle-Width="20%" HeaderStyle-CssClass="text-right" ItemStyle-CssClass="text-right" />
                                </Columns>
                                <EmptyDataTemplate>
                                    <div style="padding: 2rem; text-align: center; color: #a09080;">No specific member limits configured yet.</div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                </div>

            </div>
        </div>

    </asp:Content>
