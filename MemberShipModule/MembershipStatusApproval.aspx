<%@ Page Title="Membership Status Approval" Language="C#" MasterPageFile="~/MemberShipModule/Site.master"
    AutoEventWireup="true" CodeFile="MembershipStatusApproval.aspx.cs"
    Inherits="MemberShipModule.MembershipStatusApproval" %>

<asp:Content ID="HeadStyles" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Outfit', sans-serif !important; background-color: #faf7f2; }
        /* Enforced styles using CSS classes since some properties are not available as inline attributes in GridView tags */
        .modern-header th { background: #1A1A2E !important; color: #C9A84C !important; font-weight: 700 !important; padding: 0.75rem 1rem !important; border-bottom: 1px solid #e0d5c5 !important; text-align: left !important; font-size: 0.875rem !important; }
        .modern-row td { padding: 0.75rem 1rem !important; border-bottom: 1px solid #F7F3EE !important; color: #1A1A2E !important; vertical-align: middle !important; font-size: 0.9rem !important; }
        .modern-row:hover { background-color: #faf7f2 !important; }
        .cell-padding { padding: 0.75rem 1rem !important; }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="Server">
    <div style="font-family: 'Outfit', sans-serif; background-color: #faf7f2; padding: 1.5rem 1rem; min-height: 100vh;">
        <div style="width: 100%; max-width: 100%; margin: 0 auto; background: #ffffff; border-radius: 12px; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden;">
            
            <!-- Page Header -->
            <div style="padding: 16px 26px; border-bottom: 1px solid #e0d5c5; background: linear-gradient(135deg, #1A1A2E, #2d2d5e);">
                <h1 style="font-size: 1.5rem; font-weight: 700; color: #fff; margin: 0; display: flex; align-items: center; gap: 0.75rem;">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                        <circle cx="8.5" cy="7" r="4"></circle>
                        <polyline points="17 11 19 13 23 9"></polyline>
                    </svg>
                    Membership Status Approvals
                </h1>
                <p style="color: #E8D5A3; margin: 0.25rem 0 0 0; font-size: 0.9rem;">Manage and audit pending membership status changes across the organization</p>
            </div>

            <!-- Enhanced Filters -->
            <div style="padding: 1.5rem 2rem; background-color: #ffffff; border-bottom: 1px solid #e0d5c5;">
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.25rem; align-items: end;">
                    <div style="display: flex; flex-direction: column; gap: 0.4rem;">
                        <label style="font-size: 0.8rem; font-weight: 600; color: #1A1A2E; text-transform: uppercase; letter-spacing: 0.025em;">Member No</label>
                        <asp:TextBox ID="txtFilterMemberNo" runat="server" style="width: 100%; padding: 0.5rem 0.75rem; font-size: 0.9rem; border: 1px solid #e0d5c5; border-radius: 8px; color: #1A1A2E;" placeholder="e.g. M-1234"></asp:TextBox>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 0.4rem;">
                        <label style="font-size: 0.8rem; font-weight: 600; color: #1A1A2E; text-transform: uppercase; letter-spacing: 0.025em;">Member Name</label>
                        <asp:TextBox ID="txtFilterName" runat="server" style="width: 100%; padding: 0.5rem 0.75rem; font-size: 0.9rem; border: 1px solid #e0d5c5; border-radius: 8px; color: #1A1A2E;" placeholder="Enter name..."></asp:TextBox>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 0.4rem;">
                        <label style="font-size: 0.8rem; font-weight: 600; color: #1A1A2E; text-transform: uppercase; letter-spacing: 0.025em;">Target Status</label>
                        <asp:DropDownList ID="ddlFilterStatus" runat="server" style="width: 100%; padding: 0.5rem 0.75rem; font-size: 0.9rem; border: 1px solid #e0d5c5; border-radius: 8px; color: #1A1A2E;">
                            <asp:ListItem Value="">All Statuses</asp:ListItem>
                            <asp:ListItem Value="ABSENT">ABSENT</asp:ListItem>
                            <asp:ListItem Value="SUSPENDED">SUSPENDED</asp:ListItem>
                            <asp:ListItem Value="RESIGNED">RESIGNED</asp:ListItem>
                            <asp:ListItem Value="BLOCKED">BLOCKED</asp:ListItem>
                            <asp:ListItem Value="CANCELLED">CANCELLED</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 0.4rem;">
                        <label style="font-size: 0.8rem; font-weight: 600; color: #1A1A2E; text-transform: uppercase; letter-spacing: 0.025em;">From Date</label>
                        <asp:TextBox ID="txtFilterStartDate" runat="server" style="width: 100%; padding: 0.5rem 0.75rem; font-size: 0.9rem; border: 1px solid #e0d5c5; border-radius: 8px; color: #1A1A2E;" TextMode="Date"></asp:TextBox>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 0.4rem;">
                        <label style="font-size: 0.8rem; font-weight: 600; color: #1A1A2E; text-transform: uppercase; letter-spacing: 0.025em;">To Date</label>
                        <asp:TextBox ID="txtFilterEndDate" runat="server" style="width: 100%; padding: 0.5rem 0.75rem; font-size: 0.9rem; border: 1px solid #e0d5c5; border-radius: 8px; color: #1A1A2E;" TextMode="Date"></asp:TextBox>
                    </div>
                    <div style="display: flex; gap: 0.75rem;">
                        <asp:LinkButton ID="btnSearch" runat="server" style="display: inline-flex; align-items: center; justify-content: center; padding: 0.65rem 1.25rem; border-radius: 8px; font-weight: 600; font-size: 0.875rem; cursor: pointer; transition: all 0.2s; border: 1px solid transparent; gap: 0.5rem; background-color: #C9A84C; color: white; flex: 1; text-decoration: none;" OnClick="btnSearch_Click">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                                <circle cx="11" cy="11" r="8"></circle>
                                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                            </svg>
                            Search
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnClearFilters" runat="server" style="display: inline-flex; align-items: center; justify-content: center; padding: 0.65rem 1.25rem; border-radius: 8px; font-weight: 600; font-size: 0.875rem; cursor: pointer; transition: all 0.2s; border: 1px solid #e0d5c5; background-color: white; color: #1A1A2E; text-decoration: none;" OnClick="btnClearFilters_Click">
                            Reset
                        </asp:LinkButton>
                    </div>
                </div>
            </div>

            <!-- Modern Data Grid -->
            <div style="padding: 0;">
                <asp:GridView ID="gvPendingRequests" runat="server" AutoGenerateColumns="False"
                    Width="100%" GridLines="None" style="width: 100%; border-collapse: collapse;"
                    DataKeyNames="RequestID" OnRowCommand="gvPendingRequests_RowCommand">
                    <HeaderStyle CssClass="modern-header" />
                    <RowStyle CssClass="modern-row" />
                    <Columns>
                        <asp:BoundField DataField="RequestNo" HeaderText="Req ID" ItemStyle-Width="80px" ItemStyle-Font-Bold="true" />
                        
                        <asp:TemplateField HeaderText="Member Information" ItemStyle-Width="250px">
                            <ItemTemplate>
                                <div style="display: flex; flex-direction: column;">
                                    <span style="font-weight: 700; color: #1A1A2E; font-size: 0.95rem;"><%# Eval("MemberNo") %></span>
                                    <span style="color: #8B5E3C; font-size: 0.85rem;"><%# Eval("MemberName") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Proposed Adjustment" ItemStyle-Width="200px">
                            <ItemTemplate>
                                <div style="margin-bottom: 0.5rem;">
                                    <span style="display: inline-flex; align-items: center; padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 700; background-color: #faf7f2; color: #1e40af; border: 1px solid #f5ecd5;"><%# Eval("NewStatus") %></span>
                                </div>
                                <div style="font-size: 0.75rem; color: #8B5E3C;">
                                    <strong>Residential:</strong> <%# Eval("NewAccountStatus") %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Timeline" ItemStyle-Width="180px">
                            <ItemTemplate>
                                <%# Eval("StartDate", "{0:dd MMM yyyy}") != "" ? 
                                    "<div style='font-size: 0.8rem;'><strong>Start:</strong> " + Eval("StartDate", "{0:dd MMM yyyy}") + "</div>" : "" %>
                                <%# Eval("EndDate", "{0:dd MMM yyyy}") != "" ? 
                                    "<div style='font-size: 0.8rem;'><strong>End:</strong> " + Eval("EndDate", "{0:dd MMM yyyy}") + "</div>" : "" %>
                                <%# (Eval("StartDate", "{0:dd MMM yyyy}") == "" && Eval("EndDate", "{0:dd MMM yyyy}") == "") ? "<span style='color:#e0d5c5'>N/A</span>" : "" %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Request Details">
                            <ItemTemplate>
                                <div style="font-size: 0.85rem; color: #1e293b; margin-bottom: 0.5rem; line-height: 1.4;">
                                    <%# Eval("Reason") %>
                                </div>
                                <div style="font-size: 0.7rem; color: #8B5E3C; display: flex; gap: 0.75rem;">
                                    <span><strong>By:</strong> <%# Eval("RequestedBy") %></span>
                                    <span><strong>On:</strong> <%# Eval("RequestedOn", "{0:dd/MM/yyyy HH:mm}") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Decision Remarks" ItemStyle-Width="200px">
                            <ItemTemplate>
                                <asp:TextBox ID="txtApprovalRemarks" runat="server" style="width: 100%; border: 1px solid #e0d5c5; border-radius: 6px; padding: 0.5rem; font-size: 0.85rem; background-color: #fafafa;" 
                                    placeholder="Add notes..." TextMode="MultiLine" Rows="2"></asp:TextBox>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Actions" ItemStyle-Width="120px" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnApprove" runat="server" CommandName="Approve" 
                                    CommandArgument='<%# Container.DisplayIndex %>' 
                                    style="padding: 0.4rem 0.75rem; font-size: 0.8rem; border-radius: 6px; font-weight: 600; cursor: pointer; border: 1px solid transparent; width: 100%; text-align: center; display: block; margin-bottom: 0.4rem; background-color: #10b981; color: white; text-decoration: none;"
                                    OnClientClick="return confirm('APPROVE this status change?');">
                                    Approve
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnReject" runat="server" CommandName="Reject" 
                                    CommandArgument='<%# Container.DisplayIndex %>' 
                                    style="padding: 0.4rem 0.75rem; font-size: 0.8rem; border-radius: 6px; font-weight: 600; cursor: pointer; border: 1px solid #fecaca; width: 100%; text-align: center; display: block; background-color: #fee2e2; color: #ef4444; text-decoration: none;"
                                    OnClientClick="return confirm('REJECT this status change?');">
                                    Reject
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="padding: 4rem 2rem; text-align: center; color: #8B5E3C;">
                            <span style="font-size: 3rem; color: #e0d5c5; margin-bottom: 1rem; display: block;">
                                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                    <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                                    <polyline points="22 4 12 14.01 9 11.01"></polyline>
                                </svg>
                            </span>
                            <h3 style="font-size: 1.1rem; color: #1A1A2E; margin-bottom: 0.5rem;">No Pending Requests</h3>
                            <p style="font-size: 0.9rem;">There are no status change requests waiting for approval.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>

        </div>
    </div>
</asp:Content>
