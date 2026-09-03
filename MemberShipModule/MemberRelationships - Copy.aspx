<%@ Page Title="Member Relationships" Language="C#" MasterPageFile="~/MemberShipModule/Site.master"
    AutoEventWireup="true" CodeFile="MemberRelationships.aspx.cs" Inherits="MemberShip.MemberRelationships" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
        <style>
            /* Essential Styles (Self-contained for server deployments) */
            .table-container { background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
            .table { width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left; }
            .table th { background: #1A1A2E; color: #C9A84C; font-weight: 600; padding: 0.75rem 1rem; border-bottom: 2px solid #e0d5c5; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.05em; }
            .table td { padding: 0.75rem 1rem; border-bottom: 1px solid #e0d5c5; color: #1A1A2E; vertical-align: middle; }
            .table tr:last-child td { border-bottom: none; }
            .empty-state { padding: 2rem; text-align: center; color: #a09080; background-color: #faf7f2; border: 1px dashed #e0d5c5; border-radius: 12px; display: flex; flex-direction: column; align-items: center; gap: 0.75rem; margin-top: 1rem; }
            .empty-state svg { color: #a09080; opacity: 0.6; margin-bottom: 0.5rem; }
            .table-input { width: 100%; padding: 0.5rem 0.75rem; border: 1px solid transparent; border-radius: 6px; background: transparent; font-size: 0.95rem; color: #1A1A2E; transition: all 0.2s ease; }
            .table-input:hover { background: #F7F3EE; border-color: #e0d5c5; }
            .table-input:focus { background: #ffffff; border-color: #8B5E3C; box-shadow: 0 0 0 2px #f5ecd5; outline: none; }
            .form-control { display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; }
            .form-control:focus { border-color: #C9A84C; box-shadow: 0 0 0 3px rgba(201, 168, 76, 0.15); outline: none; }
            
            /* Button Styles */
            .btn { display: inline-block; text-align: center; vertical-align: middle; padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: all 0.15s ease; border: 1px solid transparent; line-height: 1; }
            .btn-primary { background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2); }
            .btn-primary:hover { box-shadow: 0 8px 12px rgba(201, 168, 76, 0.3); transform: translateY(-1px); }
            .btn-secondary { background-color: white; color: #1A1A2E; border-color: #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
            .btn-secondary:hover { background-color: #F7F3EE; border-color: #e0d5c5; color: #1A1A2E; }
            .btn-success { background-color: #10b981; color: white; border-color: #10b981; border: 1px solid #10b981; }
            .btn-danger { background-color: #ef4444; color: white; border-color: #ef4444; border: 1px solid #ef4444; }
            .btn-warning { background-color: #f59e0b; color: white; border-color: #f59e0b; border: 1px solid #f59e0b; }
            .btn-info { background-color: #8B5E3C; color: white; border-color: #8B5E3C; border: 1px solid #8B5E3C; }
            .btn-sm { padding: 0.4rem 0.8rem; font-size: 0.875rem; }
            .btn-sm.flex { display: inline-flex; align-items: center; justify-content: center; }
        </style>
            </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

        <div class="page-wrapper mt-6" style="margin-top: 0.75rem; /* Heavily reduced */;">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); transition: none; /* Removed hover effect */ position: relative; overflow: hidden; height: 100%; /* Slightly reduced padding */;">

                <div class="flex items-center justify-between mb-8 pb-6 border-b border-subtle" style="align-items: center; justify-content: space-between; margin-bottom: 2rem; margin-bottom: 2rem !important; padding-bottom: 1.5rem !important; border-bottom: 1px solid #e0d5c5; border-color: #e0d5c5 !important;">
                    <div>
                        <h1 class="text-2xl font-bold text-primary-900 m-0" style="font-size: 1.5rem !important; font-weight: 700; color: #1A1A2E !important; margin: 0;">Member Relationships</h1>
                        <p class="text-secondary mt-1" style="color: #8B5E3C !important;">Link family members with separate memberships</p>
                    </div>
                </div>

                <!-- Search Primary Member Section -->
                <div class="form-section mb-6" style="padding: 1rem; margin-bottom: 1rem; margin-bottom: 1.5rem;">
                    <div class="section-header" style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem; padding-bottom: 0.75rem; border-bottom: 1px solid #e0d5c5; padding-bottom: 0.5rem;">
                        <div class="section-icon" style="width: 40px; height: 40px; background: transparent; color: #C9A84C; display: flex; align-items: center; justify-content: center;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2">
                                <circle cx="11" cy="11" r="8" />
                                <path d="m21 21-4.35-4.35" />
                            </svg>
                        </div>
                        <div>
                            <h2 class="section-title" style="font-size: 1.15rem; font-weight: 700; margin: 0; color: #1A1A2E;">Search Member</h2>
                            <p class="section-subtitle" style="font-size: 0.875rem; color: #8B5E3C; margin: 0;">Find the primary member to add relationships</p>
                        </div>
                    </div>

                    <div class="grid-responsive">
                        <div class="form-group">
                            <label>Member No:</label>
                            <asp:TextBox ID="txtMemberNo" runat="server" CssClass="form-control"
                                placeholder="Enter Member No" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #1A1A2E; background-color: white; background-clip: padding-box; border: 1px solid #e0d5c5; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label>Member Name:</label>
                            <asp:TextBox ID="txtMemberName" runat="server" CssClass="form-control"
                                placeholder="Enter Name" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #1A1A2E; background-color: white; background-clip: padding-box; border: 1px solid #e0d5c5; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <asp:Button ID="btnSearchMember" runat="server" Text="Search Member"
                                CssClass="btn btn-primary" OnClick="btnSearchMember_Click"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);" />
                        </div>
                    </div>

                    <!-- Selected Member Display -->
                    <asp:Panel ID="pnlSelectedMember" runat="server" Visible="false"
                        CssClass="bg-gray-50 rounded-lg p-4 border border-subtle mt-4" style="padding: 1rem; border-color: #e0d5c5 !important; margin-top: 0.5rem; /* Heavily reduced */;">
                        <div class="flex items-center justify-between" style="align-items: center;">
                            <div>
                                <h3 class="text-lg font-bold text-primary-900" style="font-weight: 700; color: #1A1A2E !important;">Selected Member</h3>
                                <p class="text-secondary" style="color: #8B5E3C !important;">
                                    <asp:Label ID="lblMemberNo" runat="server" CssClass="font-semibold"></asp:Label> -
                                    <asp:Label ID="lblMemberName" runat="server"></asp:Label>
                                </p>
                            </div>
                        </div>
                    </asp:Panel>
                </div>

                <!-- Add Relationship Section -->
                <asp:Panel ID="pnlAddRelationship" runat="server" Visible="false">
                    <div class="form-section mb-6" style="padding: 1rem; margin-bottom: 1rem; margin-bottom: 1.5rem;">
                        <div class="section-header" style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem; padding-bottom: 0.75rem; border-bottom: 1px solid #e0d5c5; padding-bottom: 0.5rem;">
                            <div class="section-icon" style="width: 40px; height: 40px; background: transparent; color: #C9A84C; display: flex; align-items: center; justify-content: center;">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2">
                                    <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" />
                                    <circle cx="9" cy="7" r="4" />
                                    <line x1="19" y1="8" x2="19" y2="14" />
                                    <line x1="22" y1="11" x2="16" y2="11" />
                                </svg>
                            </div>
                            <div>
                                <h2 class="section-title" style="font-size: 1.15rem; font-weight: 700; margin: 0; color: #1A1A2E;">Add Family Relationship</h2>
                                <p class="section-subtitle" style="font-size: 0.875rem; color: #8B5E3C; margin: 0;">Link another member as family relation</p>
                            </div>
                        </div>

                        <div class="grid-responsive">
                            <div class="form-group">
                                <label>Related Member No:</label>
                                <asp:TextBox ID="txtRelatedMemberNo" runat="server" CssClass="form-control"
                                    placeholder="Enter Member No" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #1A1A2E; background-color: white; background-clip: padding-box; border: 1px solid #e0d5c5; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;"></asp:TextBox>
                            </div>
                            <div class="form-group">
                                <label>Related Member Name:</label>
                                <asp:TextBox ID="txtRelatedMemberName" runat="server" CssClass="form-control"
                                    placeholder="Search by Name" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #1A1A2E; background-color: white; background-clip: padding-box; border: 1px solid #e0d5c5; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;"></asp:TextBox>
                            </div>
                            <div class="form-group">
                                <asp:Button ID="btnSearchRelated" runat="server" Text="Search"
                                    CssClass="btn btn-secondary" OnClick="btnSearchRelated_Click"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background-color: white; color: #1A1A2E; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);" />
                            </div>
                        </div>

                        <div class="grid-responsive mt-4" style="margin-top: 0.5rem; /* Heavily reduced */;">
                            <div class="form-group">
                                <label>Relationship Type:</label>
                                <asp:DropDownList ID="ddlRelationshipType" runat="server" CssClass="form-control" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #1A1A2E; background-color: white; background-clip: padding-box; border: 1px solid #e0d5c5; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;">
                                    <asp:ListItem Value="">-- Select Relationship --</asp:ListItem>
                                    <asp:ListItem Value="Father">Father</asp:ListItem>
                                    <asp:ListItem Value="Mother">Mother</asp:ListItem>
                                    <asp:ListItem Value="Brother">Brother</asp:ListItem>
                                    <asp:ListItem Value="Sister">Sister</asp:ListItem>
                                    <asp:ListItem Value="Son">Son</asp:ListItem>
                                    <asp:ListItem Value="Daughter">Daughter</asp:ListItem>
                                    <asp:ListItem Value="Spouse">Spouse</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="form-group">
                                <asp:Button ID="btnAddRelationship" runat="server" Text="Add Relationship"
                                    CssClass="btn btn-success" OnClick="btnAddRelationship_Click" />
                            </div>
                        </div>
                    </div>
                </asp:Panel>

                <!-- Existing Relationships Grid -->
                <asp:Panel ID="pnlRelationships" runat="server" Visible="false">
                    <div class="form-section full-width" style="padding: 1rem; margin-bottom: 1rem;">
                        <div class="section-header" style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem; padding-bottom: 0.75rem; border-bottom: 1px solid #e0d5c5; padding-bottom: 0.5rem;">
                            <div class="section-icon" style="width: 40px; height: 40px; background: transparent; color: #C9A84C; display: flex; align-items: center; justify-content: center;">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2">
                                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                                    <circle cx="9" cy="7" r="4" />
                                    <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
                                    <path d="M16 3.13a4 4 0 0 1 0 7.75" />
                                </svg>
                            </div>
                            <div>
                                <h2 class="section-title" style="font-size: 1.15rem; font-weight: 700; margin: 0; color: #1A1A2E;">Existing Relationships</h2>
                                <p class="section-subtitle" style="font-size: 0.875rem; color: #8B5E3C; margin: 0;">Family members linked to this account</p>
                            </div>
                        </div>

                        <asp:UpdatePanel ID="upRelationships" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <div class="table-container">
                                    <asp:GridView ID="gvRelationships" runat="server" AutoGenerateColumns="false"
                                        CssClass="table" DataKeyNames="RelationshipID"
                                        OnRowCommand="gvRelationships_RowCommand" style="width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left;">
                                        <Columns>
                                            <asp:BoundField DataField="RelatedMemberNo" HeaderText="Member No" />
                                            <asp:BoundField DataField="RelatedMemberName" HeaderText="Name" />
                                            <asp:BoundField DataField="RelationshipType" HeaderText="Relationship" />
                                            <asp:TemplateField HeaderText="Actions">
                                                <ItemTemplate>
                                                    <asp:Button ID="btnDelete" runat="server" Text="Delete"
                                                        CssClass="btn btn-danger btn-sm" CommandName="DeleteRelation"
                                                        CommandArgument='<%# Container.DataItemIndex % style="background-color: #ef4444; color: white; border: 1px solid #ef4444;">'
                                                        OnClientClick="return confirm('Are you sure you want to delete this relationship? This will also remove the reciprocal relationship.');" />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                        <EmptyDataTemplate>
                                            <tr>
                                                <td colspan="4">
                                                    <div class="empty-state">
                                                        <p>No relationships found for this member</p>
                                                    </div>
                                                </td>
                                            </tr>
                                        </EmptyDataTemplate>
                                    </asp:GridView>
                                </div>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                </asp:Panel>

            </div>
        </div>
    </asp:Content>










