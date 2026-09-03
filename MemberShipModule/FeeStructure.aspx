<%@ Page Title="Fee Structure" Language="C#" MasterPageFile="~/MemberShipModule/Site.master"
    AutoEventWireup="true" CodeFile="FeeStructure.aspx.cs" Inherits="MemberShip_FeeStructure" %>
    <asp:Content ID="HeadStyles" ContentPlaceHolderID="HeadContent" runat="server">
        <style>
            /* Essential Styles (Self-contained for server deployments) */
            .table-container { background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
            .table { width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left; }
            .table th { background: #f8fafc; color: #334155; font-weight: 600; padding: 0.75rem 1rem; border-bottom: 2px solid #e2e8f0; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.05em; }
            .table td { padding: 0.75rem 1rem; border-bottom: 1px solid #e2e8f0; color: #0f172a; vertical-align: middle; }
            .table tr:last-child td { border-bottom: none; }
            .empty-state { padding: 2rem; text-align: center; color: #94a3b8; background-color: #f8fafc; border: 1px dashed #e2e8f0; border-radius: 12px; display: flex; flex-direction: column; align-items: center; gap: 0.75rem; margin-top: 1rem; }
            .empty-state svg { color: #94a3b8; opacity: 0.6; margin-bottom: 0.5rem; }
            .table-input { width: 100%; padding: 0.5rem 0.75rem; border: 1px solid transparent; border-radius: 6px; background: transparent; font-size: 0.95rem; color: #0f172a; transition: all 0.2s ease; }
            .table-input:hover { background: #f1f5f9; border-color: #e2e8f0; }
            .table-input:focus { background: #ffffff; border-color: #3b82f6; box-shadow: 0 0 0 2px #dbeafe; outline: none; }
            .form-control { display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #0f172a; background-color: white; border: 1px solid #cbd5e1; border-radius: 6px; }
            .form-control:focus { border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15); outline: none; }
            
            /* Button Styles */
            .btn { display: inline-block; text-align: center; vertical-align: middle; padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: all 0.15s ease; border: 1px solid transparent; line-height: 1; }
            .btn-primary { background: linear-gradient(135deg, #2563eb, #3b82f6); color: white; box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2); }
            .btn-primary:hover { box-shadow: 0 8px 12px rgba(37, 99, 235, 0.3); transform: translateY(-1px); }
            .btn-secondary { background-color: white; color: #334155; border-color: #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
            .btn-secondary:hover { background-color: #f1f5f9; border-color: #cbd5e1; color: #0f172a; }
            .btn-success { background-color: #10b981; color: white; border-color: #10b981; border: 1px solid #10b981; }
            .btn-danger { background-color: #ef4444; color: white; border-color: #ef4444; border: 1px solid #ef4444; }
            .btn-warning { background-color: #f59e0b; color: white; border-color: #f59e0b; border: 1px solid #f59e0b; }
            .btn-info { background-color: #3b82f6; color: white; border-color: #3b82f6; border: 1px solid #3b82f6; }
            .btn-sm { padding: 0.4rem 0.8rem; font-size: 0.875rem; }
            .btn-sm.flex { display: inline-flex; align-items: center; justify-content: center; }
        </style>
            </asp:Content>


    <asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="Server">


        <div class="page-wrapper mt-6" style="margin-top: 0.75rem;">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); position: relative; overflow: hidden; height: 100%;">

                <div class="flex items-center justify-between mb-8 pb-6 border-b border-subtle" style="align-items: center; justify-content: space-between; margin-bottom: 2rem !important; padding-bottom: 1.5rem !important; border-bottom: 1px solid #e2e8f0 !important;">
                    <div>
                        <h1 class="text-2xl font-bold text-primary-900 m-0" style="font-size: 1.5rem !important; font-weight: 700; color: #0f172a !important; margin: 0;">Membership Fee Configuration</h1>
                        <p class="text-secondary mt-1" style="color: #475569 !important;">Manage fee rates for different membership categories</p>
                    </div>
                </div>

                <div class="form-section mb-8" style="padding: 1rem; margin-bottom: 2rem !important;">
                    <asp:UpdatePanel ID="upFeeStructure" runat="server">
                        <ContentTemplate>
                            <!-- Add New Category Form -->
                            <div class="bg-gray-50 rounded-lg p-6 border border-subtle mb-8" style="padding: 1.5rem; border-color: #e2e8f0 !important; margin-bottom: 2rem !important;">
                                <div class="section-header mb-6" style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1.5rem; padding-bottom: 0.5rem; border-bottom: 1px solid #e2e8f0;">
                                    <div class="section-icon" style="width: 40px; height: 40px; background: transparent; color: #2563eb; display: flex; align-items: center; justify-content: center;">
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
                                            stroke="currentColor" stroke-width="2">
                                            <path d="M12 5v14M5 12h14"></path>
                                        </svg>
                                    </div>
                                    <div>
                                        <h3 class="font-bold text-primary-900" style="font-weight: 700; color: #0f172a !important;">Add New Category</h3>
                                        <p class="text-sm text-secondary" style="font-size: 0.875rem; line-height: 1.25rem; color: #475569 !important;">Define a new membership category and fee</p>
                                    </div>
                                </div>

                                <div class="grid-3 gap-6 items-end" style="display: grid; gap: 2rem; grid-template-columns: repeat(3, 1fr);">
                                    <div class="form-group">
                                        <label class="form-label">Category Name</label>
                                        <asp:TextBox ID="txtNewCategory" runat="server" CssClass="form-control"
                                            placeholder="e.g. Permanent" style="display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #0f172a; background-color: white; border: 1px solid #cbd5e1; border-radius: 6px;"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Fee Amount</label>
                                        <asp:TextBox ID="txtNewAmount" runat="server" CssClass="form-control"
                                            TextMode="Number" placeholder="0.00" style="display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #0f172a; background-color: white; border: 1px solid #cbd5e1; border-radius: 6px;"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <asp:Button ID="btnAddFee" runat="server" Text="Add Category"
                                            CssClass="btn btn-primary w-full" OnClick="btnAddFee_Click" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #2563eb, #3b82f6); color: white; box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2);" />
                                    </div>
                                </div>
                            </div>

                            <asp:Label ID="lblMessage" runat="server" CssClass="block mb-6 p-4 rounded-lg font-medium"
                                Visible="false" style="display: block !important; margin-bottom: 1.5rem; padding: 1rem;"></asp:Label>

                            <!-- Fee table -->
                            <div class="form-section" style="padding: 1rem; margin-bottom: 1rem;">
                                <div class="section-header" style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem; padding-bottom: 0.5rem; border-bottom: 1px solid #e2e8f0;">
                                    <div class="section-icon" style="width: 40px; height: 40px; background: transparent; color: #2563eb; display: flex; align-items: center; justify-content: center;">
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
                                            stroke="currentColor" stroke-width="2">
                                            <line x1="12" y1="1" x2="12" y2="23"></line>
                                            <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
                                        </svg>
                                    </div>
                                    <div>
                                        <h2 class="section-title" style="font-size: 1.15rem; font-weight: 700; margin: 0; color: #0f172a;">Fee Rates</h2>
                                        <p class="section-subtitle" style="font-size: 0.875rem; color: #475569; margin: 0;">Current fees by membership category</p>
                                    </div>
                                </div>

                                <div class="table-container">
                                    <asp:GridView ID="gvFeeStructure" runat="server" AutoGenerateColumns="false"
                                        DataKeyNames="FeeID" CssClass="table" OnRowEditing="gvFeeStructure_RowEditing"
                                        OnRowUpdating="gvFeeStructure_RowUpdating"
                                        OnRowCancelingEdit="gvFeeStructure_RowCancelingEdit"
                                        OnRowDeleting="gvFeeStructure_RowDeleting" GridLines="None" style="width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left;">
                                        <Columns>
                                            <asp:BoundField DataField="CategoryName" HeaderText="Category"
                                                HeaderStyle-Width="25%"
                                                ItemStyle-CssClass="font-semibold text-primary-900" />
                                            <asp:BoundField DataField="FeeAmount" HeaderText="Fee Amount"
                                                DataFormatString="{0:N2}" HeaderStyle-Width="20%" />
                                            <asp:BoundField DataField="Description" HeaderText="Description"
                                                HeaderStyle-Width="25%" />
                                            <asp:BoundField DataField="LastUpdated" HeaderText="Last Updated"
                                                ReadOnly="true" DataFormatString="{0:yyyy-MM-dd HH:mm}"
                                                HeaderStyle-Width="15%" />
                                            <asp:TemplateField HeaderText="Actions" HeaderStyle-Width="15%">
                                                <ItemTemplate>
                                                    <div class="flex gap-2" style="gap: 0.5rem;">
                                                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="Edit"
                                                            CssClass="text-blue-600 hover:text-blue-800 font-medium text-sm" style="font-size: 0.875rem; line-height: 1.25rem;">
                                                            <i class="fas fa-edit mr-1"></i>Edit
                                                        </asp:LinkButton>
                                                        <asp:LinkButton ID="btnDelete" runat="server"
                                                            CommandName="Delete"
                                                            CssClass="text-red-600 hover:text-red-800 font-medium text-sm ml-2"
                                                            OnClientClick="return confirm('Are you sure you want to delete this category?');" style="font-size: 0.875rem; line-height: 1.25rem;">
                                                            <i class="fas fa-trash mr-1"></i>Delete
                                                        </asp:LinkButton>
                                                    </div>
                                                </ItemTemplate>
                                                <EditItemTemplate>
                                                    <div class="flex gap-2" style="gap: 0.5rem;">
                                                        <asp:LinkButton ID="btnUpdate" runat="server"
                                                            CommandName="Update"
                                                            CssClass="text-green-600 hover:text-green-800 font-medium text-sm" style="font-size: 0.875rem; line-height: 1.25rem;">
                                                            <i class="fas fa-check mr-1"></i>Save
                                                        </asp:LinkButton>
                                                        <asp:LinkButton ID="btnCancel" runat="server"
                                                            CommandName="Cancel"
                                                            CssClass="text-gray-600 hover:ms-text-gray-800 font-medium text-sm ml-2" style="font-size: 0.875rem; line-height: 1.25rem;">
                                                            <i class="fas fa-times mr-1"></i>Cancel
                                                        </asp:LinkButton>
                                                    </div>
                                                </EditItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                        <EmptyDataTemplate>
                                            <div class="empty-state">
                                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none"
                                                    stroke="currentColor" stroke-width="2">
                                                    <circle cx="12" cy="12" r="10"></circle>
                                                    <line x1="12" y1="8" x2="12" y2="16"></line>
                                                    <line x1="8" y1="12" x2="16" y2="12"></line>
                                                </svg>
                                                <p>No fee categories configured yet.</p>
                                            </div>
                                        </EmptyDataTemplate>
                                    </asp:GridView>
                                </div>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>

            </div>
        </div>
    </asp:Content>
