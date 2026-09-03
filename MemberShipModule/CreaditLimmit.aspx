<%@ Page Title="LAHORE GYMKHANA" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true"
    CodeFile="CreaditLimmit.aspx.cs" Inherits="MembershipProfile" %>
    <asp:Content ID="HeadStyles" ContentPlaceHolderID="HeadContent" runat="server">
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


    <asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="Server">

        <div class="page-wrapper mt-6" style="margin-top: 0.75rem; /* Heavily reduced */;">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); transition: none; /* Removed hover effect */ position: relative; overflow: hidden; height: 100%; /* Slightly reduced padding */;">

                <div class="flex items-center justify-between mb-8 pb-6 border-b border-subtle" style="align-items: center; justify-content: space-between; margin-bottom: 2rem; margin-bottom: 2rem !important; padding-bottom: 1.5rem !important; border-bottom: 1px solid #e0d5c5; border-color: #e0d5c5 !important;">
                    <div>
                        <h1 class="text-2xl font-bold text-primary-900 m-0" style="font-size: 1.5rem !important; font-weight: 700; color: #1A1A2E !important; margin: 0;">Set Credit Limits</h1>
                        <p class="text-secondary mt-1" style="color: #8B5E3C !important;">Configure credit limits for membership categories</p>
                    </div>
                </div>

                <!-- Credit Limit Form Section -->
                <div class="form-section mb-8" style="padding: 1rem; margin-bottom: 1rem; margin-bottom: 2rem; margin-bottom: 2rem !important;">
                    <div class="section-header" style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem; padding-bottom: 0.75rem; border-bottom: 1px solid #e0d5c5; padding-bottom: 0.5rem;">
                        <div class="section-icon" style="width: 40px; height: 40px; background: transparent; color: #C9A84C; display: flex; align-items: center; justify-content: center;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2">
                                <rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect>
                                <line x1="1" y1="10" x2="23" y2="10"></line>
                            </svg>
                        </div>
                        <div>
                            <h2 class="section-title" style="font-size: 1.15rem; font-weight: 700; margin: 0; color: #1A1A2E;">Credit Limit Configuration</h2>
                            <p class="section-subtitle" style="font-size: 0.875rem; color: #8B5E3C; margin: 0;">Set limits for each membership category</p>
                        </div>
                    </div>

                    <div class="grid-3 gap-6 items-end" style="grid-template-columns: 1fr; /* Stack everything */; display: grid; gap: 1.5rem; grid-template-columns: repeat(3, 1fr); gap: 2rem; /* Increased to 2rem for better spacing */;">
                        <div class="form-group">
                            <label class="form-label">Membership Category</label>
                            <asp:DropDownList ID="ddlMembershipType" runat="server" AppendDataBoundItems="true"
                                CssClass="form-control" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #1A1A2E; background-color: white; background-clip: padding-box; border: 1px solid #e0d5c5; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;">
                                <asp:ListItem Value="">-- Select Category --</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Credit Limit (PKR)</label>
                            <asp:TextBox ID="txtCreditLimit" runat="server" CssClass="form-control"
                                placeholder="Enter credit limit" TextMode="Number" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #1A1A2E; background-color: white; background-clip: padding-box; border: 1px solid #e0d5c5; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;"></asp:TextBox>
                        </div>

                        <div class="form-group">
                            <asp:Button ID="btnSave" runat="server" Text="Save Limit" OnClick="btnSave_Click"
                                CssClass="btn btn-primary w-full"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);" />
                        </div>
                    </div>
                </div>

                <!-- Credit Limits Grid Section -->
                <div class="form-section" style="padding: 1rem; margin-bottom: 1rem;">
                    <div class="section-header" style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem; padding-bottom: 0.75rem; border-bottom: 1px solid #e0d5c5; padding-bottom: 0.5rem;">
                        <div class="section-icon" style="width: 40px; height: 40px; background: transparent; color: #C9A84C; display: flex; align-items: center; justify-content: center;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2">
                                <line x1="8" y1="6" x2="21" y2="6"></line>
                                <line x1="8" y1="12" x2="21" y2="12"></line>
                                <line x1="8" y1="18" x2="21" y2="18"></line>
                                <line x1="3" y1="6" x2="3.01" y2="6"></line>
                                <line x1="3" y1="12" x2="3.01" y2="12"></line>
                                <line x1="3" y1="18" x2="3.01" y2="18"></line>
                            </svg>
                        </div>
                        <div>
                            <h2 class="section-title" style="font-size: 1.15rem; font-weight: 700; margin: 0; color: #1A1A2E;">Current Credit Limits</h2>
                            <p class="section-subtitle" style="font-size: 0.875rem; color: #8B5E3C; margin: 0;">View all configured credit limits</p>
                        </div>
                    </div>

                    <div class="table-container">
                        <asp:GridView ID="gvCreditLimits" runat="server" AutoGenerateColumns="false" CssClass="table"
                            GridLines="None" style="width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left;">
                            <Columns>
                                <asp:BoundField DataField="MembershipCategory" HeaderText="Membership Category" />
                                <asp:BoundField DataField="CreditLimit" HeaderText="Credit Limit"
                                    DataFormatString="PKR {0:N0}" />
                                <asp:BoundField DataField="IsActive" HeaderText="Status" />
                            </Columns>
                            <EmptyDataTemplate>
                                <tr>
                                    <td colspan="3">
                                        <div class="empty-state">
                                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none"
                                                stroke="currentColor" stroke-width="2">
                                                <rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect>
                                                <line x1="1" y1="10" x2="23" y2="10"></line>
                                            </svg>
                                            <p>No credit limits configured yet</p>
                                        </div>
                                    </td>
                                </tr>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>


            </div>
        </div>

    </asp:Content>











