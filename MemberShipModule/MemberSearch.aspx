<%@ Page Title="Advanced Member Search" Language="C#" MasterPageFile="~/MemberShipModule/site.master" AutoEventWireup="true"
    CodeFile="MemberSearch.aspx.cs" Inherits="Membership.MemberSearch" %>

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
                <style>
            /* ── Search Engine Styles ── */
            .search-engine-box {
                position: relative;
                max-width: 100%;
            }
            .search-engine-box .search-icon {
                position: absolute;
                left: 14px;
                top: 50%;
                transform: translateY(-50%);
                color: #a09080;
                pointer-events: none;
            }
            .search-engine-input {
                display: block;
                width: 100%;
                padding: 0.7rem 1rem 0.7rem 2.75rem;
                font-size: 1rem;
                font-weight: 400;
                line-height: 1.5;
                color: #1A1A2E;
                background-color: #fff;
                border: 2px solid #e0d5c5;
                border-radius: 10px;
                transition: border-color 0.2s, box-shadow 0.2s;
                box-sizing: border-box;
            }
            .search-engine-input:focus {
                border-color: #8B5E3C;
                box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15);
                outline: none;
            }
            .search-hint {
                font-size: 0.8rem;
                color: #a09080;
                margin-top: 0.35rem;
                display: flex;
                align-items: center;
                gap: 0.5rem;
                flex-wrap: wrap;
            }
            .search-hint code {
                background: #F7F3EE;
                padding: 1px 6px;
                border-radius: 4px;
                font-family: monospace;
                font-size: 0.78rem;
                color: #8B5E3C;
            }
            /* ── Collapsible advanced filters ── */
            .advanced-toggle {
                display: inline-flex;
                align-items: center;
                gap: 0.4rem;
                background: none;
                border: 1px solid #e0d5c5;
                border-radius: 8px;
                padding: 0.4rem 0.9rem;
                font-size: 0.85rem;
                color: #8B5E3C;
                cursor: pointer;
                transition: all 0.2s;
                margin-top: 0.75rem;
            }
            .advanced-toggle:hover {
                background: #faf7f2;
                border-color: #e0d5c5;
                color: #1e293b;
            }
            .advanced-toggle .chevron {
                transition: transform 0.25s;
                font-size: 0.7rem;
            }
            .advanced-toggle.open .chevron {
                transform: rotate(180deg);
            }
            .advanced-filters {
                display: none;
                margin-top: 1rem;
                padding-top: 1rem;
                border-top: 1px solid #F7F3EE;
                animation: slideDown 0.25s ease;
            }
            .advanced-filters.show {
                display: block;
            }
            @keyframes slideDown {
                from { opacity: 0; transform: translateY(-8px); }
                to { opacity: 1; transform: translateY(0); }
            }
            /* ── Filter grid ── */
            .filter-grid {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 1rem 1.5rem;
            }
            @media (max-width: 1200px) {
                .filter-grid { grid-template-columns: repeat(3, 1fr); }
            }
            @media (max-width: 768px) {
                .filter-grid { grid-template-columns: repeat(2, 1fr); }
            }
            @media (max-width: 480px) {
                .filter-grid { grid-template-columns: 1fr; }
            }
            .filter-grid .form-group { margin-bottom: 0; }
            .filter-grid .form-group label {
                display: block;
                font-size: 0.8rem;
                font-weight: 600;
                color: #8B5E3C;
                margin-bottom: 0.25rem;
                text-transform: uppercase;
                letter-spacing: 0.03em;
            }
            .filter-input {
                display: block;
                width: 100%;
                padding: 0.35rem 0.5rem;
                font-size: 0.88rem;
                font-weight: 400;
                line-height: 1.3;
                color: #1A1A2E;
                background-color: white;
                border: 1px solid #e0d5c5;
                border-radius: 6px;
                transition: border-color 0.15s, box-shadow 0.15s;
                box-sizing: border-box;
            }
            .filter-input:focus {
                border-color: #8B5E3C;
                box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.1);
                outline: none;
            }
            /* ── Result count badge ── */
            .result-badge {
                display: inline-flex;
                align-items: center;
                gap: 0.35rem;
                padding: 0.3rem 0.85rem;
                border-radius: 20px;
                font-size: 0.82rem;
                font-weight: 600;
            }
            .result-badge.ready {
                background: #F7F3EE;
                color: #7a7a7a;
            }
            .result-badge.found {
                background: #dcfce7;
                color: #166534;
            }
            .result-badge.empty {
                background: #fef3c7;
                color: #92400e;
            }
            /* ── Button row ── */
            .search-btn-row {
                display: flex;
                gap: 0.75rem;
                justify-content: flex-end;
                align-items: center;
                margin-top: 1rem;
                padding-top: 0.75rem;
                border-top: 1px solid #F7F3EE;
            }
            .btn-clear-filters {
                background: #faf7f2;
                color: #7a7a7a;
                border: 1px solid #e0d5c5;
                padding: 0.45rem 1.2rem;
                border-radius: 8px;
                font-size: 0.88rem;
                cursor: pointer;
                transition: all 0.15s;
            }
            .btn-clear-filters:hover {
                background: #F7F3EE;
                color: #1A1A2E;
            }
            /* ── Results highlight ── */
            .result-row-link {
                color: #C9A84C;
                text-decoration: none;
                font-weight: 500;
            }
            .result-row-link:hover {
                text-decoration: underline;
            }
            /* ── Pager row ── */
            .pagination-row {
                padding: 0.75rem;
                background: #faf7f2;
                border-top: 1px solid #e0d5c5;
            }
            .pagination-row td {
                padding: 0.5rem;
            }
            .pagination-row a, .pagination-row span {
                padding: 4px 10px;
                margin: 0 2px;
                border-radius: 4px;
                font-size: 0.85rem;
                text-decoration: none;
            }
            .pagination-row a {
                color: #C9A84C;
                background: #fff;
                border: 1px solid #e0d5c5;
            }
            .pagination-row a:hover {
                background: #faf7f2;
            }
            .pagination-row span {
                color: #fff;
                background: #C9A84C;
                font-weight: 600;
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="page-wrapper mt-6" style="margin-top: 0.75rem;">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); position: relative; overflow: hidden; height: 100%;">

                <!-- Header -->
                <div style="display: flex; align-items: center; justify-content: space-between; margin: -1.25rem -1.25rem 1.5rem -1.25rem; padding: 16px 26px; background: linear-gradient(135deg, #1A1A2E, #2d2d5e); border-radius: 10px 10px 0 0;">
                    <div>
                        <h1 style="font-size: 1.35rem; font-weight: 700; color: #fff; margin: 0;">Advanced Member Search</h1>
                        <p style="color: #E8D5A3; margin: 3px 0 0 0; font-size: 0.8rem;">Comprehensive search engine &mdash; search by any part of name, CNIC, phone, or any field</p>
                    </div>
                    <div>
                        <asp:Label ID="lblCount" runat="server" CssClass="result-badge ready" Text="Ready to search" />
                    </div>
                </div>

                <!-- Search Form -->
                <div style="background: #faf7f2; border-radius: 10px; padding: 1.25rem; border: 1px solid #F7F3EE; margin-bottom: 1.5rem;">

                    <!-- Universal Search Box -->
                    <div class="search-engine-box">
                        <div class="search-icon">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                                <circle cx="11" cy="11" r="8"></circle>
                                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                            </svg>
                        </div>
                        <asp:TextBox ID="txtUniversalSearch" runat="server" CssClass="search-engine-input" placeholder="Type anything: name, CNIC, phone, member no, company..." style="width: 100%; padding: 1rem 1rem 1rem 3rem; font-size: 1.1rem; color: #1A1A2E; background: #ffffff; border: 2px solid #e0d5c5; border-radius: 12px; box-sizing: border-box;" />
                    </div>
                    <div class="search-hint">
                        <span></span>
                        <span>Searches across all text fields.</span>
                        <span>Use <code>+</code> to combine terms: <code>ali+karachi</code></span>
                        <span>|</span>
                        <span>Use <code>%</code> as wildcard: <code>R-12%</code></span>
                    </div>

                    <!-- Toggle Advanced Filters -->
                    <button type="button" class="advanced-toggle" id="btnToggleAdvanced" onclick="toggleAdvanced()" style="display: inline-flex; align-items: center; gap: 0.5rem; padding: 0.5rem 1rem; margin-top: 1rem; background: transparent; border: 1px solid #e0d5c5; border-radius: 8px; color: #8B5E3C; font-size: 0.9rem; font-weight: 500; cursor: pointer;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <line x1="4" y1="21" x2="4" y2="14"></line>
                            <line x1="4" y1="10" x2="4" y2="3"></line>
                            <line x1="12" y1="21" x2="12" y2="12"></line>
                            <line x1="12" y1="8" x2="12" y2="3"></line>
                            <line x1="20" y1="21" x2="20" y2="16"></line>
                            <line x1="20" y1="12" x2="20" y2="3"></line>
                            <line x1="1" y1="14" x2="7" y2="14"></line>
                            <line x1="9" y1="8" x2="15" y2="8"></line>
                            <line x1="17" y1="16" x2="23" y2="16"></line>
                        </svg>
                        Advanced Filters
                        <span class="chevron">▼</span>
                    </button>

                    <!-- Advanced Filter Fields -->
                    <div class="advanced-filters" id="advancedFilters">
                        <div class="filter-grid">
                            <div class="form-group">
                                <label>Member No</label>
                                <asp:TextBox ID="txtMemberNo" runat="server" CssClass="filter-input" style="display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.88rem; font-weight: 400; line-height: 1.3; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box;" placeholder="e.g. R-12345" />
                            </div>
                            <div class="form-group">
                                <label>Member Name</label>
                                <asp:TextBox ID="txtName" runat="server" CssClass="filter-input" style="display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.88rem; font-weight: 400; line-height: 1.3; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box;" placeholder="Any part of name..." />
                            </div>
                            <div class="form-group">
                                <label>Father / Husband Name</label>
                                <asp:TextBox ID="txtFatherName" runat="server" CssClass="filter-input" style="display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.88rem; font-weight: 400; line-height: 1.3; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box;" placeholder="Any part..." />
                            </div>
                            <div class="form-group">
                                <label>CNIC</label>
                                <asp:TextBox ID="txtCNIC" runat="server" CssClass="filter-input" style="display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.88rem; font-weight: 400; line-height: 1.3; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box;" placeholder="12345-1234567-1" />
                            </div>
                            <div class="form-group">
                                <label>Mobile / Phone</label>
                                <asp:TextBox ID="txtMobile" runat="server" CssClass="filter-input" style="display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.88rem; font-weight: 400; line-height: 1.3; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box;" placeholder="0300..." />
                            </div>
                            <div class="form-group">
                                <label>Email</label>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="filter-input" style="display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.88rem; font-weight: 400; line-height: 1.3; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box;" placeholder="email@..." />
                            </div>
                            <div class="form-group">
                                <label>City</label>
                                <asp:TextBox ID="txtCity" runat="server" CssClass="filter-input" style="display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.88rem; font-weight: 400; line-height: 1.3; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box;" placeholder="e.g. Lahore" />
                            </div>
                            <div class="form-group">
                                <label>Occupation / Profession</label>
                                <asp:TextBox ID="txtOccupation" runat="server" CssClass="filter-input" style="display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.88rem; font-weight: 400; line-height: 1.3; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box;" placeholder="e.g. Doctor" />
                            </div>
                            <div class="form-group">
                                <label>Company Name</label>
                                <asp:TextBox ID="txtCompany" runat="server" CssClass="filter-input" style="display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.88rem; font-weight: 400; line-height: 1.3; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box;" placeholder="Company..." />
                            </div>
                            <div class="form-group">
                                <label>Spouse Name</label>
                                <asp:TextBox ID="txtSpouseName" runat="server" CssClass="filter-input" style="display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.88rem; font-weight: 400; line-height: 1.3; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box;" placeholder="Spouse..." />
                            </div>
                            <div class="form-group">
                                <label>Member Category</label>
                                <asp:DropDownList ID="ddlCategory" runat="server" CssClass="filter-input" style="display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.88rem; font-weight: 400; line-height: 1.3; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box;">
                                    <asp:ListItem Text="All Categories" Value=""></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="form-group">
                                <label>Member Type</label>
                                <asp:DropDownList ID="ddlMemberType" runat="server" CssClass="filter-input" style="display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.88rem; font-weight: 400; line-height: 1.3; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box;">
                                    <asp:ListItem Text="All Types" Value=""></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="form-group">
                                <label>Account Status</label>
                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="filter-input" style="display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.88rem; font-weight: 400; line-height: 1.3; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box;">
                                    <asp:ListItem Text="All Statuses" Value=""></asp:ListItem>
                                    <asp:ListItem Text="Active" Value="Active"></asp:ListItem>
                                    <asp:ListItem Text="Suspended" Value="Suspended"></asp:ListItem>
                                    <asp:ListItem Text="Absentee" Value="Absentee"></asp:ListItem>
                                    <asp:ListItem Text="Cancelled" Value="Cancelled"></asp:ListItem>
                                    <asp:ListItem Text="Resigned" Value="Resigned"></asp:ListItem>
                                    <asp:ListItem Text="Deceased" Value="Deceased"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="form-group">
                                <label>Nationality</label>
                                <asp:TextBox ID="txtNationality" runat="server" CssClass="filter-input" style="display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.88rem; font-weight: 400; line-height: 1.3; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box;" placeholder="e.g. Pakistani" />
                            </div>
                            <div class="form-group">
                                <label>Passport No</label>
                                <asp:TextBox ID="txtPassport" runat="server" CssClass="filter-input" style="display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.88rem; font-weight: 400; line-height: 1.3; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box;" placeholder="Passport..." />
                            </div>
                            <div class="form-group">
                                <label>Co-Member No</label>
                                <asp:TextBox ID="txtCoMemberNo" runat="server" CssClass="filter-input" style="display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.88rem; font-weight: 400; line-height: 1.3; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box;" placeholder="Co-Member No..." />
                            </div>
                        </div>
                    </div>

                    <!-- Buttons -->
                    <div class="search-btn-row">
                        <asp:Button ID="btnClear" runat="server" Text="Clear All" CssClass="btn-clear-filters" OnClick="btnClear_Click" style="background: #faf7f2; color: #7a7a7a; border: 1px solid #e0d5c5; padding: 0.45rem 1.2rem; border-radius: 8px; font-size: 0.88rem; cursor: pointer;" />
                        <asp:Button ID="btnSearch" runat="server" Text="  Search Members"
                            CssClass="btn btn-primary min-w-200" OnClick="btnSearch_Click"
                            style="background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2); min-width: 200px; padding: 0.5rem 1.5rem; border-radius: 8px; font-size: 0.95rem; border: none; cursor: pointer;" />
                    </div>
                </div>

                <!-- Results Grid -->
                <div class="table-container">
                    <asp:GridView ID="gvResults" runat="server" AutoGenerateColumns="False" CssClass="table"
                        GridLines="None" Width="100%" AllowPaging="true" PageSize="50"
                        OnPageIndexChanging="gvResults_PageIndexChanging"
                        style="width: 100%; border-collapse: collapse; font-size: 0.9rem; text-align: left;">
                                <HeaderStyle BackColor="#faf7f2" ForeColor="#1A1A2E" Font-Bold="True" Height="40px" HorizontalAlign="Left" BorderColor="#e0d5c5" BorderStyle="Solid" BorderWidth="1px" />
                                <RowStyle BackColor="White" ForeColor="#1A1A2E" BorderColor="#e0d5c5" BorderStyle="Solid" BorderWidth="1px" Height="48px" />
                                <AlternatingRowStyle BackColor="#faf7f2" ForeColor="#1A1A2E" BorderColor="#e0d5c5" BorderStyle="Solid" BorderWidth="1px" Height="48px" />
                        <PagerSettings Mode="NumericFirstLast" FirstPageText="« First" LastPageText="Last »" PageButtonCount="10" />
                        <PagerStyle CssClass="pagination-row" HorizontalAlign="Center" />
                        <Columns>
                            <asp:TemplateField HeaderText="Member No">
                                <ItemTemplate>
                                    <a href='MemberProfile.aspx?MemberID=<%# Eval("MemberID") %>' class="result-row-link"
                                        title="Open Profile"><%# Eval("MemberNo") %></a>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="MemberName" HeaderText="Member Name" />
                            <asp:BoundField DataField="FatherName" HeaderText="Father Name" />
                            <asp:BoundField DataField="NIC" HeaderText="CNIC" />
                            <asp:BoundField DataField="ResidentialMobile" HeaderText="Mobile" />
                            <asp:TemplateField HeaderText="DOB / Age">
                                <ItemTemplate>
                                    <div style="white-space: nowrap;"><%# Eval("DOB", "{0:dd-MMM-yyyy}") %></div>
                                    <div style="font-size: 0.8rem; color: #7a7a7a; margin-top: 2px;">
                                        <%# CalculateAge(Eval("DOB")) %>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="Occupation" HeaderText="Occupation" />
                            <asp:TemplateField HeaderText="Category">
                                <ItemTemplate>
                                    <span style="background-color: #f5ecd5; color: #C9A84C; padding: 2px 8px; border-radius: 12px; font-size: 0.78rem; font-weight: 600; white-space: nowrap;">
                                        <%# Eval("MemberCategory") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Type">
                                <ItemTemplate>
                                    <span style="background-color: #f3e8ff; color: #7c3aed; padding: 2px 8px; border-radius: 12px; font-size: 0.78rem; font-weight: 600; white-space: nowrap;">
                                        <%# Eval("MemberType") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <span style='<%# GetStatusStyle(Eval("AccountStatus")) %>'>
                                        <%# Eval("AccountStatus") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="" ItemStyle-Width="70px" ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <a href='MemberProfile.aspx?MemberID=<%# Eval("MemberID") %>'
                                        class="btn btn-sm btn-secondary"
                                        style="padding: 3px 10px; font-size: 0.78rem; border-radius: 6px; text-decoration: none; background: #F7F3EE; color: #8B5E3C; border: 1px solid #e0d5c5;">
                                        <i class="fas fa-eye" style="margin-right: 3px;"></i>View
                                    </a>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div style="padding: 3rem; text-align: center;">
                                <div style="font-size: 2.5rem; margin-bottom: 0.5rem;"></div>
                                <p style="color: #a09080; font-size: 1rem; margin: 0;">No members found matching your criteria.</p>
                                <p style="color: #e0d5c5; font-size: 0.85rem; margin: 0.3rem 0 0 0;">Try using fewer filters or the universal search box.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

            </div>
        </div>

        <script type="text/javascript">
            function toggleAdvanced() {
                var panel = document.getElementById('advancedFilters');
                var btn = document.getElementById('btnToggleAdvanced');
                if (panel.classList.contains('show')) {
                    panel.classList.remove('show');
                    btn.classList.remove('open');
                } else {
                    panel.classList.add('show');
                    btn.classList.add('open');
                }
            }
        </script>
    </asp:Content>
