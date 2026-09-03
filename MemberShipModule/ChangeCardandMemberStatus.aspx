<%@ Page Title="Application Tracking" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true"
    CodeFile="ChangeCardandMemberStatus.aspx.cs" Inherits="ApplicationProcessing" %>
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



    <asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="Server">
        <div class="page-wrapper mt-6" style="margin-top: 0.75rem; /* Heavily reduced */;">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); transition: none; /* Removed hover effect */ position: relative; overflow: hidden; height: 100%; /* Slightly reduced padding */;">

                <div class="flex items-center justify-between mb-8 pb-6 border-b border-subtle" style="align-items: center; justify-content: space-between; margin-bottom: 2rem; margin-bottom: 2rem !important; padding-bottom: 1.5rem !important; border-bottom: 1px solid #e2e8f0; border-color: #e2e8f0 !important;">
                    <div>
                        <h1 class="text-2xl font-bold text-primary-900 m-0" style="font-size: 1.5rem !important; font-weight: 700; color: #0f172a !important; margin: 0;">Change card & Member Status</h1>
                        <p class="text-secondary mt-1" style="color: #475569 !important;">Search and manage member profiles</p>
                    </div>
                </div>

                <!-- Search Form Section -->
                <div class="form-section mb-8" style="padding: 1rem; margin-bottom: 1rem; margin-bottom: 2rem; margin-bottom: 2rem !important;">
                    <div class="section-header" style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem; padding-bottom: 0.75rem; border-bottom: 1px solid #e2e8f0; padding-bottom: 0.5rem;">
                        <div class="section-icon" style="width: 40px; height: 40px; background: transparent; color: #2563eb; display: flex; align-items: center; justify-content: center;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2">
                                <circle cx="11" cy="11" r="8"></circle>
                                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                            </svg>
                        </div>
                        <div>
                            <h2 class="section-title" style="font-size: 1.15rem; font-weight: 700; margin: 0; color: #0f172a;">Search Criteria</h2>
                            <p class="section-subtitle" style="font-size: 0.875rem; color: #475569; margin: 0;">Filter members by various details</p>
                        </div>
                    </div>

                    <div class="grid-3 gap-6 mb-6" style="grid-template-columns: 1fr; /* Stack everything */; display: grid; gap: 1.5rem; grid-template-columns: repeat(3, 1fr); gap: 2rem; /* Increased to 2rem for better spacing */; margin-bottom: 1.5rem;">
                        <div class="form-group">
                            <label class="form-label">Member No</label>
                            <asp:TextBox ID="txtMemberNo" runat="server" CssClass="form-control"
                                placeholder="Enter Member No" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Member Name</label>
                            <asp:TextBox ID="txtMemberName" runat="server" CssClass="form-control"
                                placeholder="Enter Member Name" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Spouse Name</label>
                            <asp:TextBox ID="txtSpouseName" runat="server" CssClass="form-control"
                                placeholder="Enter Spouse Name" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label class="form-label">CNIC</label>
                            <asp:TextBox ID="txtCNIC" runat="server" CssClass="form-control"
                                placeholder="Enter CNIC (without dashes)"
                                onkeyup="this.value=this.value.replace(/-/g,'');" MaxLength="13" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Child Name</label>
                            <asp:TextBox ID="txtChildName" runat="server" CssClass="form-control"
                                placeholder="Enter Child Name" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;"></asp:TextBox>
                        </div>
                    </div>

                    <div class="flex justify-end">
                        <asp:Button ID="btnSearch" runat="server" Text="Search Members" CssClass="btn btn-primary"
                            OnClick="BtnSearch_Click"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #2563eb, #3b82f6); color: white; box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2);" />
                    </div>
                </div>

                <!-- Results Section -->
                <div class="form-section" style="padding: 1rem; margin-bottom: 1rem;">
                    <div class="section-header" style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem; padding-bottom: 0.75rem; border-bottom: 1px solid #e2e8f0; padding-bottom: 0.5rem;">
                        <div class="section-icon" style="width: 40px; height: 40px; background: transparent; color: #2563eb; display: flex; align-items: center; justify-content: center;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2">
                                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                                <circle cx="9" cy="7" r="4"></circle>
                                <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                                <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                            </svg>
                        </div>
                        <div>
                            <h2 class="section-title" style="font-size: 1.15rem; font-weight: 700; margin: 0; color: #0f172a;">Search Results</h2>
                            <p class="section-subtitle" style="font-size: 0.875rem; color: #475569; margin: 0;">Member profiles matching your criteria</p>
                        </div>
                    </div>

                    <asp:Repeater ID="rptMembers" runat="server" OnItemDataBound="rptMembers_ItemDataBound">
                        <ItemTemplate>
                            <div class="border border-subtle rounded-lg overflow-hidden mb-6 bg-white shadow-sm" style="border-color: #e2e8f0 !important; margin-bottom: 1.5rem;">
                                <div class="grid-2 gap-0" style="grid-template-columns: 1fr; /* Stack everything */; grid-template-columns: repeat(2, 1fr);">

                                    <!-- Member Profile Column -->
                                    <div class="p-6 border-r border-subtle bg-gray-50" style="padding: 1.5rem; border-color: #e2e8f0 !important;">
                                        <h3
                                            class="font-bold text-primary-700 mb-4 pb-2 border-b-2 border-primary-600 text-base" style="font-weight: 700; margin-bottom: 1rem;">
                                            MEMBER PROFILE</h3>

                                        <div class="space-y-3">
                                            <div class="flex items-center">
                                                <span class="font-semibold text-secondary w-32" style="color: #475569 !important;">Member No:</span>
                                                <span class="text-primary-900" style="color: #0f172a !important;">
                                                    <%# Eval("memberno") %>
                                                </span>
                                            </div>
                                            <div class="flex items-center">
                                                <span class="font-semibold text-secondary w-32" style="color: #475569 !important;">Name:</span>
                                                <span class="text-primary-900" style="color: #0f172a !important;">
                                                    <%# Eval("membername") %>
                                                </span>
                                            </div>
                                            <div class="flex items-center">
                                                <span class="font-semibold text-secondary w-32" style="color: #475569 !important;">Spouse:</span>
                                                <span class="text-primary-900" style="color: #0f172a !important;">
                                                    <%# Eval("spousename") %>
                                                </span>
                                            </div>
                                            <div class="flex items-center">
                                                <span class="font-semibold text-secondary w-32" style="color: #475569 !important;">CNIC:</span>
                                                <span class="text-primary-900" style="color: #0f172a !important;">
                                                    <%# Eval("nic") %>
                                                </span>
                                            </div>
                                            <div class="flex items-center">
                                                <span class="font-semibold text-secondary w-32" style="color: #475569 !important;">Account Status:</span>
                                                <span
                                                    class='<%# Eval("IsActive").ToString() == "True" ? "text-green-600 font-bold" : "text-red-600 font-bold" %>'>
                                                    <%# Eval("AccountStatus") %>
                                                </span>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Family Details Column -->
                                    <div class="p-6" style="padding: 1.5rem;">
                                        <h3
                                            class="font-bold text-green-600 mb-4 pb-2 border-b-2 border-green-500 text-base" style="font-weight: 700; margin-bottom: 1rem;">
                                            FAMILY DETAILS</h3>
                                        <asp:HiddenField ID="hfMID" runat="server" Value='<%# Eval("M_ID") %>' />

                                        <asp:GridView ID="gvChildren" runat="server" AutoGenerateColumns="False"
                                            Width="100%" GridLines="None" CssClass="table-simple">
                                            <Columns>
                                                <asp:TemplateField HeaderText="Child Full Name">
                                                    <ItemTemplate>
                                                        <div class="py-2 border-b border-subtle text-primary-900" style="border-bottom: 1px solid #e2e8f0; border-color: #e2e8f0 !important; color: #0f172a !important;">
                                                            <span class="mr-2">�</span>
                                                            <%# Eval("childname") %>
                                                        </div>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                            <EmptyDataTemplate>
                                                <div class="empty-state py-4">
                                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
                                                        stroke="currentColor" stroke-width="2">
                                                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                                                        <circle cx="9" cy="7" r="4"></circle>
                                                    </svg>
                                                    <p>No children registered for this member.</p>
                                                </div>
                                            </EmptyDataTemplate>
                                        </asp:GridView>
                                    </div>

                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

            </div>
        </div>
    </asp:Content>











