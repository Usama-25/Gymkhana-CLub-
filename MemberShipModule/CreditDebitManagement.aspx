<%@ Page Title="Credit & Debit Management" Language="C#" MasterPageFile="~/MemberShipModule/Site.master"
    AutoEventWireup="true" CodeFile="CreditDebitManagement.aspx.cs" Inherits="CreditDebitManagement" %>
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

        <div class="page-wrapper mt-6" style="margin-top: 0.75rem; /* Heavily reduced */;">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); transition: none; /* Removed hover effect */ position: relative; overflow: hidden; height: 100%; /* Slightly reduced padding */;">

                <!-- Page Header -->
                <div class="flex items-center justify-between mb-8 pb-6 border-b border-subtle" style="align-items: center; justify-content: space-between; margin-bottom: 2rem; margin-bottom: 2rem !important; padding-bottom: 1.5rem !important; border-bottom: 1px solid #e2e8f0; border-color: #e2e8f0 !important;">
                    <div>
                        <h1 class="text-2xl font-bold text-primary-900 m-0" style="font-size: 1.5rem !important; font-weight: 700; color: #0f172a !important; margin: 0;">Credit & Debit Management</h1>
                        <p class="text-secondary mt-1" style="color: #475569 !important;">View member credits, debits, and transaction history (Information Only)</p>
                    </div>
                </div>

                <!-- Member Search Section -->
                <div class="form-section mb-8" style="padding: 1rem; margin-bottom: 1rem; margin-bottom: 2rem; margin-bottom: 2rem !important;">
                    <div class="section-header" style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem; padding-bottom: 0.75rem; border-bottom: 1px solid #e2e8f0; padding-bottom: 0.5rem;">
                        <div class="section-icon" style="width: 40px; height: 40px; background: transparent; color: #2563eb; display: flex; align-items: center; justify-content: center;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2">
                                <circle cx="11" cy="11" r="8"></circle>
                                <path d="M21 21l-4.35-4.35"></path>
                            </svg>
                        </div>
                        <div>
                            <h2 class="section-title" style="font-size: 1.15rem; font-weight: 700; margin: 0; color: #0f172a;">Search Member</h2>
                            <p class="section-subtitle" style="font-size: 0.875rem; color: #475569; margin: 0;">Find member by card No, Member No, or Name</p>
                        </div>
                    </div>

                    <div class="grid-responsive gap-6 items-end" style="gap: 2rem; /* Increased to 2rem for better spacing */;">

                        <div class="form-group">
                            <label class="form-label">Member No</label>
                            <asp:TextBox ID="txtMemberNo" runat="server" CssClass="form-control"
                                placeholder="Enter Member No"  style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;" />
                        </div>

                        <div class="form-group">
                            <label class="form-label">Member Name</label>
                            <asp:TextBox ID="txtMemberName" runat="server" CssClass="form-control"
                                placeholder="Enter Name"  style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;" />
                        </div>

                        <div class="form-group">
                            <asp:Button ID="btnSearch" runat="server" Text="Search Member" OnClick="btnSearch_Click"
                                CssClass="btn btn-primary w-full"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #2563eb, #3b82f6); color: white; box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2);" />
                        </div>
                    </div>
                </div>

                <asp:Label ID="lblMessage" runat="server" CssClass="mt-4 block text-center font-semibold"  style="margin-top: 0.5rem; /* Heavily reduced */; display: block !important; text-align: center !important;" />

                <!-- Member Info & Balance Cards (Hidden until member is found) -->
                <asp:Panel ID="pnlMemberDetails" runat="server" Visible="false">

                    <!-- Member Info Banner -->
                    <div class="member-info-banner mb-6" style="margin-bottom: 1.5rem;">
                        <div class="flex items-center gap-4" style="align-items: center; gap: 1rem;">
                            <div class="member-avatar">
                                <asp:Image ID="imgMemberPhoto" runat="server" CssClass="avatar-img" />
                            </div>
                            <div>
                                <h3 class="text-lg font-bold text-primary-900 m-0" style="font-weight: 700; color: #0f172a !important; margin: 0;">
                                    <asp:Label ID="lblMemberName" runat="server" />
                                </h3>
                                <p class="text-secondary m-0" style="color: #475569 !important; margin: 0;">
                                    Member No:
                                    <asp:Label ID="lblMemberNo" runat="server" CssClass="font-mono" />
                                </p>
                                <p class="text-secondary m-0" style="color: #475569 !important; margin: 0;">
                                    Type:
                                    <asp:Label ID="lblMemberType" runat="server" CssClass="badge badge-info"  style="background-color: #dbeafe; color: #3b82f6;" />
                                </p>
                            </div>
                        </div>
                        <asp:HiddenField ID="hfMemberId" runat="server" />
                        <asp:HiddenField ID="hfMemberNo" runat="server" />
                    </div>

                    <!-- Balance Overview Cards -->
                    <div class="balance-cards-grid mb-8" style="margin-bottom: 2rem; margin-bottom: 2rem !important;">
                        <!-- Total Credits card -->
                        <div class="balance-card balance-card-credit">
                            <div class="balance-icon">
                                <span>Rs</span>
                            </div>
                            <div class="balance-content">
                                <span class="balance-label">Total Credits</span>
                                <span class="balance-amount">
                                    <asp:Label ID="lblTotalCredit" runat="server" Text="Rs 0.00" />
                                </span>
                            </div>
                        </div>

                        <!-- Total Debits card -->
                        <div class="balance-card balance-card-debit">
                            <div class="balance-icon">
                                <span>Rs</span>
                            </div>
                            <div class="balance-content">
                                <span class="balance-label">Total Debits</span>
                                <span class="balance-amount">
                                    <asp:Label ID="lblTotalDebit" runat="server" Text="Rs 0.00" />
                                </span>
                            </div>
                        </div>

                        <!-- Current Balance card -->
                        <div class="balance-card balance-card-balance">
                            <div class="balance-icon">
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2">
                                    <rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect>
                                    <line x1="1" y1="10" x2="23" y2="10"></line>
                                </svg>
                            </div>
                            <div class="balance-content">
                                <span class="balance-label">Current Balance</span>
                                <span class="balance-amount">
                                    <asp:Label ID="lblCurrentBalance" runat="server" Text="Rs 0.00" />
                                </span>
                            </div>
                        </div>

                        <!-- Credit Limit card -->
                        <div class="balance-card balance-card-limit">
                            <div class="balance-icon">
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2">
                                    <path d="M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0z"></path>
                                    <path d="M9 12l2 2 4-4"></path>
                                </svg>
                            </div>
                            <div class="balance-content">
                                <span class="balance-label">Credit Limit</span>
                                <span class="balance-amount">
                                    <asp:Label ID="lblCreditLimit" runat="server" Text="Rs 0.00" />
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- Transaction History -->
                    <div class="form-section" style="padding: 1rem; margin-bottom: 1rem;">
                        <div class="section-header" style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem; padding-bottom: 0.75rem; border-bottom: 1px solid #e2e8f0; padding-bottom: 0.5rem;">
                            <div class="section-icon" style="width: 40px; height: 40px; background: transparent; color: #2563eb; display: flex; align-items: center; justify-content: center;">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2">
                                    <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline>
                                </svg>
                            </div>
                            <div>
                                <h2 class="section-title" style="font-size: 1.15rem; font-weight: 700; margin: 0; color: #0f172a;">Transaction History</h2>
                                <p class="section-subtitle" style="font-size: 0.875rem; color: #475569; margin: 0;">View all credit and debit transactions</p>
                            </div>
                        </div>

                        <!-- Filters -->
                        <div class="grid-responsive gap-4 mb-6" style="gap: 1rem; margin-bottom: 1.5rem;">
                            <div class="form-group">
                                <label class="form-label">Filter by Type</label>
                                <asp:DropDownList ID="ddlFilterType" runat="server" CssClass="form-control" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;">
                                    <asp:ListItem Value="">All Transactions</asp:ListItem>
                                    <asp:ListItem Value="Credit">Credits Only</asp:ListItem>
                                    <asp:ListItem Value="Debit">Debits Only</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="form-group flex items-end">
                                <asp:Button ID="btnFilter" runat="server" Text="Apply Filter" OnClick="btnFilter_Click"
                                    CssClass="btn btn-secondary w-full"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background-color: white; color: #334155; border: 1px solid #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);" />
                            </div>
                        </div>

                        <!-- Transaction Grid -->
                        <div class="table-container">
                            <asp:GridView ID="gvTransactions" runat="server" AutoGenerateColumns="false"
                                CssClass="table" GridLines="None" EmptyDataText="No transactions found." style="width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left;">
                                <Columns>
                                    <asp:BoundField DataField="TransactionType" HeaderText="Type" />
                                    <asp:BoundField DataField="Description" HeaderText="Description" />
                                    <asp:BoundField DataField="Department" HeaderText="Department" />
                                    <asp:BoundField DataField="Credit" HeaderText="Credit"
                                        ItemStyle-CssClass="font-mono text-right" HeaderStyle-CssClass="text-right" />
                                    <asp:BoundField DataField="DebitAmount" HeaderText="Debit"
                                        ItemStyle-CssClass="font-mono text-right" HeaderStyle-CssClass="text-right" />
                                </Columns>
                                <EmptyDataTemplate>
                                    <div class="empty-state">
                                        <svg width="48" height="48" viewBox="0 0 24 24" fill="none"
                                            stroke="currentColor" stroke-width="1.5">
                                            <rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect>
                                            <line x1="1" y1="10" x2="23" y2="10"></line>
                                        </svg>
                                        <p>No transactions found for this member</p>
                                    </div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>

                </asp:Panel>

            </div>
        </div>

        <style>
            /* Balance Cards Custom Styles */
            .balance-cards-grid {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: var(--space-6);
            }

            @media (max-width: 1200px) {
                .balance-cards-grid {
                    grid-template-columns: repeat(2, 1fr);
                }
            }

            @media (max-width: 640px) {
                .balance-cards-grid {
                    grid-template-columns: 1fr;
                }
            }

            .balance-card {
                background: var(--bg-surface);
                border-radius: var(--radius-lg);
                padding: var(--space-6);
                display: flex;
                align-items: center;
                gap: var(--space-4);
                border: 1px solid var(--border-subtle);
                box-shadow: var(--shadow-md);
                transition: transform 0.2s ease, box-shadow 0.2s ease;
                position: relative;
                overflow: hidden;
            }

            .balance-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 4px;
            }

            .balance-card:hover {
                transform: translateY(-2px);
                box-shadow: var(--shadow-lg);
            }

            .balance-card-credit::before {
                background: linear-gradient(90deg, #10b981, #34d399);
            }

            .balance-card-debit::before {
                background: linear-gradient(90deg, #ef4444, #f87171);
            }

            .balance-card-balance::before {
                background: linear-gradient(90deg, #2563eb, #3b82f6);
            }

            .balance-card-limit::before {
                background: linear-gradient(90deg, #8b5cf6, #a78bfa);
            }

            .balance-icon {
                width: 56px;
                height: 56px;
                border-radius: var(--radius-md);
                display: flex;
                align-items: center;
                justify-content: center;
                flex-shrink: 0;
            }

            .balance-card-credit .balance-icon {
                background: rgba(16, 185, 129, 0.1);
                color: #10b981;
            }

            .balance-card-debit .balance-icon {
                background: rgba(239, 68, 68, 0.1);
                color: #ef4444;
            }

            .balance-card-balance .balance-icon {
                background: rgba(37, 99, 235, 0.1);
                color: #2563eb;
            }

            .balance-card-limit .balance-icon {
                background: rgba(139, 92, 246, 0.1);
                color: #8b5cf6;
            }

            .balance-content {
                display: flex;
                flex-direction: column;
                gap: 4px;
            }

            .balance-label {
                font-size: 0.85rem;
                font-weight: 500;
                color: var(--text-secondary);
                text-transform: uppercase;
                letter-spacing: 0.05em;
            }

            .balance-amount {
                font-size: 1.5rem;
                font-weight: 700;
                font-family: 'Inter', monospace;
                color: var(--color-primary-900);
            }

            /* Member Info Banner */
            .member-info-banner {
                background: linear-gradient(135deg, var(--color-primary-50), var(--color-accent-50));
                border: 1px solid var(--border-subtle);
                border-radius: var(--radius-md);
                padding: var(--space-6);
            }

            .member-avatar {
                width: 64px;
                height: 64px;
                border-radius: 50%;
                overflow: hidden;
                border: 3px solid white;
                box-shadow: var(--shadow-md);
            }

            .avatar-img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

            /* Text Color Utilities */
            .text-success {
                color: #10b981 !important;
            }

            .text-danger {
                color: #ef4444 !important;
            }
        </style>

    </asp:Content>











