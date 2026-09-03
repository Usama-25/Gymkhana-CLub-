<%@ Page Title="Active Members Report" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true"
    CodeFile="ActiveMembers.aspx.cs" Inherits="Membership.Reports.ActiveMembers" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
        <style>
            /* Essential Styles (Self-contained for server deployments) */
            .table-container { background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
            .table { width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left; }
            .table th { background: #1A1A2E; color: #C9A84C; font-weight: 600; padding: 0.75rem 1rem; border-bottom: 2px solid #e0d5c5; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.05em; }
            .table td { padding: 0.75rem 1rem; border-bottom: 1px solid #e0d5c5; color: #1A1A2E; vertical-align: middle; }
            .table tr:last-child td { border-bottom: none; }
            .empty-state { padding: 2rem; text-align: center; color: #8B5E3C; background-color: #faf7f2; border: 1px dashed #e0d5c5; border-radius: 12px; display: flex; flex-direction: column; align-items: center; gap: 0.75rem; margin-top: 1rem; }
            .empty-state svg { color: #8B5E3C; opacity: 0.6; margin-bottom: 0.5rem; }
            .table-input { width: 100%; padding: 0.5rem 0.75rem; border: 1px solid transparent; border-radius: 6px; background: transparent; font-size: 0.95rem; color: #1A1A2E; transition: all 0.2s ease; }
            .table-input:hover { background: #F7F3EE; border-color: #e0d5c5; }
            .table-input:focus { background: #ffffff; border-color: #8B5E3C; box-shadow: 0 0 0 2px #dbeafe; outline: none; }
            .form-control { display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; }
            .form-control:focus { border-color: #C9A84C; box-shadow: 0 0 0 3px rgba(201, 168, 76, 0.15); outline: none; }
            
            /* Button Styles */
            .btn { display: inline-block; text-align: center; vertical-align: middle; padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: all 0.15s ease; border: 1px solid transparent; line-height: 1; }
            .btn-primary { background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2); }
            .btn-primary:hover { box-shadow: 0 8px 12px rgba(201, 168, 76, 0.3); transform: translateY(-1px); }
            .btn-secondary { background-color: white; color: #8B5E3C; border-color: #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
            .btn-secondary:hover { background-color: #F7F3EE; border-color: #e0d5c5; color: #1A1A2E; }
            .btn-success { background-color: #10b981; color: white; border-color: #10b981; border: 1px solid #10b981; }
            .btn-danger { background-color: #ef4444; color: white; border-color: #ef4444; border: 1px solid #ef4444; }
            .btn-warning { background-color: #f59e0b; color: white; border-color: #f59e0b; border: 1px solid #f59e0b; }
            .btn-info { background-color: #8B5E3C; color: white; border-color: #8B5E3C; border: 1px solid #8B5E3C; }
            .btn-sm { padding: 0.4rem 0.8rem; font-size: 0.875rem; }
            .btn-sm.flex { display: inline-flex; align-items: center; justify-content: center; }
        </style>
                <!-- Global Styles are in Master Page -->
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="page-wrapper mt-6" style="margin-top: 0.75rem; /* Heavily reduced */;">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); transition: none; /* Removed hover effect */ position: relative; overflow: hidden; height: 100%; /* Slightly reduced padding */;">

                <div class="report-header">
                    <img src='<%= ResolveUrl("~/MemberShipModule/assets/images/report_logo.png") %>' alt="Club Logo"
                        class="report-logo" />
                    <h1 class="report-title">Lahore Gymkhana Club</h1>
                    <h2 class="report-title">
                        <%: Page.Title %>
                    </h2>
                    <p class="report-date">Generated on: <%= DateTime.Now.ToString("dd-MMM-yyyy HH:mm") %>
                    </p>
                </div>

                <div class="flex items-center justify-between mb-8 pb-6 border-b border-subtle" style="align-items: center; justify-content: space-between; margin-bottom: 2rem; margin-bottom: 2rem !important; padding-bottom: 1.5rem !important; border-bottom: 1px solid #e0d5c5; border-color: #e0d5c5 !important;">
                    <div>
                        <h1 class="text-2xl font-bold text-primary-900 m-0" style="font-size: 1.5rem !important; font-weight: 700; color: #1A1A2E !important; margin: 0;">Active Members Report</h1>
                        <p class="text-secondary mt-1" style="color: #8B5E3C !important;">Category-wise list of active members</p>
                    </div>
                    <div>
                        <asp:LinkButton ID="btnExport" runat="server" CssClass="btn btn-primary"
                            OnClick="btnExport_Click" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);">
                            <i class="fas fa-file-excel mr-2"></i> Export to Excel
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnPrintPDF" runat="server" CssClass="btn btn-secondary ml-2"
                            OnClick="btnPrintPDF_Click" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background-color: white; color: #8B5E3C; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);">
                            <i class="fas fa-file-pdf mr-2"></i> Print / PDF
                        </asp:LinkButton>
                    </div>
                </div>

                <!-- Results Grid -->
                <div class="table-container mb-6" style="margin-bottom: 1.5rem;">
                    <asp:GridView ID="gvActiveMembers" runat="server" AutoGenerateColumns="False"
                        CssClass="table table-bordered table-hover" GridLines="None"
                        EmptyDataText="No active members found." style="width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left;">
                        <Columns>
                            <asp:BoundField DataField="MemberNo" HeaderText="Member No" ItemStyle-Font-Bold="true" />
                            <asp:BoundField DataField="MemberName" HeaderText="Member Name" />
                            <asp:BoundField DataField="MemberCategory" HeaderText="Category" />
                            <asp:BoundField DataField="MemberType" HeaderText="Type" />
                            <asp:BoundField DataField="MemberSince" HeaderText="Member Since"
                                DataFormatString="{0:yyyy-MM-dd}" />
                            <asp:BoundField DataField="AccountStatus" HeaderText="Status"
                                ItemStyle-CssClass="text-green-600 font-semibold" />
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="p-8 text-center text-gray-500" style="padding: 2rem; text-align: center !important;">
                                <p>No active member records found.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

            </div>
        </div>
    </asp:Content>










