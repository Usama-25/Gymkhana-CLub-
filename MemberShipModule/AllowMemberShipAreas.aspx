<%@ Page Title="" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true"
    CodeFile="AllowMemberShipAreas.aspx.cs" Inherits="RefundFee.AllowMemberShipAreas" %>


    <asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
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

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">




        <div class="page-wrapper mt-6" style="margin-top: 0.75rem; /* Heavily reduced */;">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); transition: none; /* Removed hover effect */ position: relative; overflow: hidden; height: 100%;">

                <div class="card-header" style="padding: 16px 26px; border-bottom: 1px solid #e0d5c5; background: linear-gradient(135deg, #1A1A2E, #2d2d5e); display: flex; align-items: center; justify-content: space-between; margin-bottom: 1.5rem;">
                    <div>
                        <h1 style="font-size: 1.5rem; font-weight: 700; color: #fff; margin: 0;">Membership Areas Management</h1>
                        <p style="color: #E8D5A3; font-size: 0.95rem; margin: 0.25rem 0 0 0;">Configure allowed areas for member categories</p>
                    </div>
                </div>

                <div style="padding: 0 1.5rem 1.5rem 1.5rem;">

                <asp:Label ID="lblMessage" runat="server" CssClass="status-message block mb-6 text-center"
                    Visible="false"  style="display: block !important; margin-bottom: 1.5rem;" />

                <div class="form-grid mb-8" style="width: 100%; margin-bottom: 2rem; margin-bottom: 2rem !important;">
                    <!-- Configuration Form -->
                    <div class="form-section" style="padding: 1rem; margin-bottom: 1rem;">
                        <div class="section-header" style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem; padding-bottom: 0.75rem; border-bottom: 1px solid #e0d5c5; padding-bottom: 0.5rem;">
                            <div class="section-icon" style="width: 40px; height: 40px; background: transparent; color: #C9A84C; display: flex; align-items: center; justify-content: center;">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2">
                                    <path d="M12 20h9"></path>
                                    <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path>
                                </svg>
                            </div>
                            <div>
                                <h2 class="section-title" style="font-size: 1.15rem; font-weight: 700; margin: 0; color: #1A1A2E;">Add Area Configuration</h2>
                                <p class="section-subtitle" style="font-size: 0.875rem; color: #8B5E3C; margin: 0;">Link membership types to specific facility areas</p>
                            </div>
                        </div>

                        <div class="grid-2 gap-6 items-end" style="grid-template-columns: 1fr; /* Stack everything */; grid-template-columns: repeat(2, 1fr); gap: 2rem; /* Increased to 2rem for better spacing */;">
                            <div class="form-group">
                                <label for="ddlMembershipType">Membership Type</label>
                                <asp:DropDownList ID="ddlMembershipType" runat="server" CssClass="form-control"
                                    AutoPostBack="true" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #1A1A2E; background-color: white; background-clip: padding-box; border: 1px solid #e0d5c5; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;">
                                </asp:DropDownList>
                            </div>

                            <div class="form-group">
                                <label for="ddlAllowedAreas">Allowed Areas</label>
                                <asp:DropDownList ID="ddlAllowedAreas" runat="server" CssClass="form-control" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #1A1A2E; background-color: white; background-clip: padding-box; border: 1px solid #e0d5c5; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;">
                                </asp:DropDownList>
                            </div>
                        </div>

                        <div class="flex justify-end mt-6" style="justify-content: flex-end; justify-content: flex-end !important; margin-top: 0.75rem; /* Heavily reduced */;">
                            <asp:Button ID="btnAllow" runat="server" Text="Add Configuration" CssClass="btn btn-primary"
                                OnClick="btnAllow_Click"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);" />
                        </div>
                    </div>
                </div>

                <!-- Results Grid -->
                <div class="form-section" style="padding: 1rem; margin-bottom: 1rem;">
                    <div class="section-header" style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem; padding-bottom: 0.75rem; border-bottom: 1px solid #e0d5c5; padding-bottom: 0.5rem;">
                        <div class="section-icon" style="width: 40px; height: 40px; background: transparent; color: #C9A84C; display: flex; align-items: center; justify-content: center;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2">
                                <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
                                <line x1="3" y1="9" x2="21" y2="9"></line>
                                <line x1="9" y1="21" x2="9" y2="9"></line>
                            </svg>
                        </div>
                        <div>
                            <h2 class="section-title" style="font-size: 1.15rem; font-weight: 700; margin: 0; color: #1A1A2E;">Existing Configurations</h2>
                            <p class="section-subtitle" style="font-size: 0.875rem; color: #8B5E3C; margin: 0;">Manage currently allowed areas</p>
                        </div>
                    </div>

                    <div class="table-container">
                        <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="false" CssClass="table"
                            GridLines="None" OnRowCommand="GridView1_RowCommand" OnRowEditing="GridView1_RowEditing"
                            OnRowUpdating="GridView1_RowUpdating" OnRowCancelingEdit="GridView1_RowCancelingEdit"
                            DataKeyNames="RowIndex" style="width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left;">

                            <Columns>
                                <asp:TemplateField HeaderText="S.No">
                                    <ItemTemplate>
                                        <%# Container.DataItemIndex + 1 %>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" Width="60px" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Membership Type">
                                    <ItemTemplate>
                                        <asp:Label ID="lblFormType" runat="server" Text='<%# Eval("FormType") %>'>
                                        </asp:Label>
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <asp:DropDownList ID="ddlEditMembershipType" runat="server"
                                            CssClass="table-input">
                                        </asp:DropDownList>
                                    </EditItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Department Area">
                                    <ItemTemplate>
                                        <asp:Label ID="lblDeptName" runat="server" Text='<%# Eval("Dept_Name") %>'>
                                        </asp:Label>
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <asp:DropDownList ID="ddlEditDepartment" runat="server" CssClass="table-input">
                                        </asp:DropDownList>
                                    </EditItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" />
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Action">
                                    <ItemTemplate>
                                        <div class="flex gap-2" style="gap: 0.5rem;">
                                            <asp:Button ID="btnEdit" runat="server" Text="Edit" CommandName="Edit"
                                                CssClass="btn btn-secondary btn-sm"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background-color: white; color: #1A1A2E; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);" />
                                            <asp:Button ID="btnDelete" runat="server" Text="Delete"
                                                CommandName="DeleteRow" CommandArgument='<%# Container.DataItemIndex %>'
                                                CssClass="btn btn-danger btn-sm" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid #ef4444; background-color: #ef4444; color: white;" />
                                        </div>
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <div class="flex gap-2" style="gap: 0.5rem;">
                                            <asp:Button ID="btnUpdate" runat="server" Text="Update" CommandName="Update"
                                                CssClass="btn btn-primary btn-sm"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);" />
                                            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CommandName="Cancel"
                                                CssClass="btn btn-secondary btn-sm"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background-color: white; color: #1A1A2E; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);" />
                                        </div>
                                    </EditItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" Width="200px" />
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <tr>
                                    <td colspan="4">
                                        <div class="empty-state">
                                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none"
                                                stroke="currentColor" stroke-width="2">
                                                <path d="M12 20h9"></path>
                                                <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z">
                                                </path>
                                            </svg>
                                            <p>No area configurations found</p>
                                        </div>
                                    </td>
                                </tr>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>

                <!-- Save All Button -->
                <div class="flex justify-center mt-8 pt-6 border-t border-subtle" style="justify-content: center; justify-content: center !important; margin-top: 1rem; /* Heavily reduced */; padding-top: 1.5rem !important; border-color: #e0d5c5 !important;">
                    <asp:Button ID="btnSave" runat="server" Text="Save All Changes" CssClass="btn btn-primary btn-lg" OnClick="btnSave_Click"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);" />
                </div>
                </div>
            </div>
        </div>

    </asp:Content>









