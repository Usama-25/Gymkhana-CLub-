<%@ page language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" autoeventwireup="true" CodeFile="StockTracking.aspx.cs" Inherits="Pages_Stock_StockTracking" title="Stock Tracking & Auditing - Lahore Gymkhana Library" %>

<asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        /* Modern Glassmorphic Statistics Cards */
        .stat-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 20px 24px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            display: flex;
            align-items: center;
            gap: 16px;
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }
        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 15px -3px rgba(15, 30, 54, 0.08);
            border-color: #c5a059;
        }
        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 100%;
            background-color: #e2e8f0;
            transition: background-color 0.25s ease;
        }
        .stat-card:hover::before {
            background-color: #c5a059;
        }

        /* Status colors */
        .sc-titles::before { background-color: #64748b; }
        .sc-copies::before { background-color: #0f1e36; }
        .sc-available::before { background-color: #10b981; }
        .sc-issued::before { background-color: #3b82f6; }
        .sc-reserved::before { background-color: #f59e0b; }
        .sc-overdue::before { background-color: #ef4444; }
        .sc-lost::before { background-color: #7f1d1d; }
        .sc-damaged::before { background-color: #f97316; }
        .sc-missing::before { background-color: #8b5cf6; }
        .sc-withdrawn::before { background-color: #1e293b; }

        /* Color-coded Status Badges */
        .badge-status {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: inline-block;
        }
        .badge-available { background-color: #d1fae5; color: #065f46; border: 1px solid #10b981; }
        .badge-issued { background-color: #dbeafe; color: #1e40af; border: 1px solid #3b82f6; }
        .badge-reserved { background-color: #fef3c7; color: #92400e; border: 1px solid #f59e0b; }
        .badge-overdue { background-color: #fee2e2; color: #991b1b; border: 1px solid #ef4444; }
        .badge-lost { background-color: #fca5a5; color: #7f1d1d; border: 1px solid #b91c1c; }
        .badge-damaged { background-color: #ffedd5; color: #9a3412; border: 1px solid #f97316; }
        .badge-missing { background-color: #f3e8ff; color: #5b21b6; border: 1px solid #8b5cf6; }
        .badge-repair { background-color: #fef3c7; color: #78350f; border: 1px solid #d97706; }
        .badge-withdrawn { background-color: #e2e8f0; color: #334155; border: 1px solid #64748b; }

        .gv-header-red {
            background-color: #7f1d1d !important;
        }
        .gv-header-mini {
            padding: 6px 10px !important;
            font-size: 11px !important;
        }

        /* Grid Header Link Styling */
        .gv-header a, .gv-header-left a, .gv-header-red a {
            color: #ffffff !important;
            text-decoration: none !important;
        }
        .gv-header a:hover, .gv-header-left a:hover, .gv-header-red a:hover {
            color: #c5a059 !important;
            text-decoration: underline !important;
        }

        /* Pager Styling for GridViews */
        .pager-style table {
            margin: 14px auto !important;
        }
        .pager-style td {
            padding: 2px 4px !important;
            border: none !important;
        }
        .pager-style a, .pager-style span {
            padding: 6px 12px !important;
            border-radius: 6px !important;
            font-size: 12.5px !important;
            font-weight: 600 !important;
            text-decoration: none !important;
            display: inline-block !important;
        }
        .pager-style a {
            background-color: #f1f5f9 !important;
            color: #0f1e36 !important;
            border: 1px solid #cbd5e1 !important;
        }
        .pager-style a:hover {
            background-color: #c5a059 !important;
            color: #ffffff !important;
            border-color: #c5a059 !important;
        }
        .pager-style span {
            background-color: #0f1e36 !important;
            color: #ffffff !important;
            border: 1px solid #0f1e36 !important;
        }

        /* Advanced collapse animation styling */
        .filter-panel-custom {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            transition: all 0.3s ease;
        }

        /* Clean and sleek search fields */
        .form-input-stock {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 13.5px;
            font-family: 'Outfit', sans-serif;
            outline: none;
            background-color: #ffffff;
            box-sizing: border-box;
            height: 42px;
            transition: all 0.2s ease;
        }
        .form-input-stock:focus {
            border-color: #c5a059;
            box-shadow: 0 0 0 3px rgba(197, 160, 89, 0.15);
        }

        /* Minimal stylesheet for print layout */
        @media print {
            @page {
                size: landscape;
                margin: 0.4in;
            }
            aside, header, .no-print, .filter-container, .btn-action-primary, .btn-action-gold, .tab-header-btn, #tabHeaders, .modal-overlay, #divSidebar {
                display: none !important;
            }
            .print-only {
                display: block !important;
            }
            main, #mainContent {
                margin-left: 0 !important;
                padding: 0 !important;
            }
            .tab-pane {
                display: none !important;
            }
            .tab-pane.active-print {
                display: block !important;
            }
            .report-grid {
                width: 100% !important;
                border: 1px solid #cbd5e1 !important;
                table-layout: auto !important;
            }
            .report-grid th {
                background-color: #0f1e36 !important;
                color: #ffffff !important;
                print-color-adjust: exact;
                -webkit-print-color-adjust: exact;
                padding: 6px 8px !important;
                font-size: 10px !important;
            }
            .report-grid td {
                padding: 6px 8px !important;
                font-size: 10px !important;
                border-bottom: 1px solid #e2e8f0 !important;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">
    
    <!-- Active Tab Hidden Field Tracker -->
    <asp:HiddenField ID="hfActiveTab" runat="server" Value="0" />

    <!-- Print-Only Header Logo -->
    <div class="print-only" style="margin-bottom: 20px; border-bottom: 2px solid #cbd5e1; padding-bottom: 10px; text-align: left; width: 100%; display: none;">
        <img src='<%= ResolveUrl("~/Library Management/Images/logo_new.png") %>' alt="Lahore Gymkhana Logo" style="height: 65px; display: inline-block; margin: 0; object-fit: contain;" />
        <h2 style="font-family: 'Playfair Display', serif; display: inline-block; float: right; margin-top: 15px; color: #0f1e36;">Lahore Gymkhana Club Library</h2>
    </div>

    <asp:UpdatePanel ID="upStockTracking" runat="server" UpdateMode="Conditional">
        <ContentTemplate>

            <!-- Alert Notification Area -->
            <asp:Panel ID="pnlAlert" runat="server" Visible="false" style="width: 100%; box-sizing: border-box; margin-bottom: 20px;" class="no-print">
                <div id="divAlert" runat="server" style="padding: 16px 24px; border-radius: 8px; font-size: 14px; border-left: 4px solid transparent; width: 100%; box-sizing: border-box;">
                    <asp:Literal ID="litAlertMsg" runat="server" />
                </div>
            </asp:Panel>

            <!-- Page Title Header (Club Branded) -->
            <div class="no-print" style="background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; padding: 22px 28px; border-radius: 8px; margin-bottom: 24px; border-bottom: 3px solid #c5a059; display: flex; justify-content: space-between; align-items: center; width: 100%; box-sizing: border-box;">
                <div style="display: block;">
                    <h2 style="margin: 0; font-family: 'Playfair Display', serif; font-size: 24px; font-weight: 600; letter-spacing: 0.5px;">Stock Tracking & Verification</h2>
                    <p style="margin: 4px 0 0; opacity: .8; font-size: 13px; font-weight: 300;">Librarian command center for copy tracking, physical auditing, condition logging, and shelf transfers.</p>
                </div>
            </div>

            <!-- Dashboard Statistics Strip -->
            <div class="no-print" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 30px; width: 100%; box-sizing: border-box;">
                
                <!-- Stat Card: Total Titles -->
                <div class="stat-card sc-titles">
                    <div style="width: 44px; height: 44px; border-radius: 50%; background-color: #f1f5f9; display: flex; align-items: center; justify-content: center; color: #64748b; font-size: 18px;"><i class="fas fa-book-open"></i></div>
                    <div>
                        <h4 style="font-size: 22px; font-weight: 700; color: #0f1e36; margin: 0;"><asp:Literal ID="litStatTitles" runat="server" Text="0" /></h4>
                        <span style="font-size: 11px; font-weight: 600; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Total Titles</span>
                    </div>
                </div>

                <!-- Stat Card: Total Copies -->
                <div class="stat-card sc-copies">
                    <div style="width: 44px; height: 44px; border-radius: 50%; background-color: #f1f5f9; display: flex; align-items: center; justify-content: center; color: #0f1e36; font-size: 18px;"><i class="fas fa-layer-group"></i></div>
                    <div>
                        <h4 style="font-size: 22px; font-weight: 700; color: #0f1e36; margin: 0;"><asp:Literal ID="litStatCopies" runat="server" Text="0" /></h4>
                        <span style="font-size: 11px; font-weight: 600; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Total Copies</span>
                    </div>
                </div>

                <!-- Stat Card: Available -->
                <div class="stat-card sc-available">
                    <div style="width: 44px; height: 44px; border-radius: 50%; background-color: #ecfdf5; display: flex; align-items: center; justify-content: center; color: #10b981; font-size: 18px;"><i class="fas fa-check-circle"></i></div>
                    <div>
                        <h4 style="font-size: 22px; font-weight: 700; color: #065f46; margin: 0;"><asp:Literal ID="litStatAvailable" runat="server" Text="0" /></h4>
                        <span style="font-size: 11px; font-weight: 600; text-transform: uppercase; color: #047857; letter-spacing: 0.5px;">Available</span>
                    </div>
                </div>

                <!-- Stat Card: Issued -->
                <div class="stat-card sc-issued">
                    <div style="width: 44px; height: 44px; border-radius: 50%; background-color: #eff6ff; display: flex; align-items: center; justify-content: center; color: #3b82f6; font-size: 18px;"><i class="fas fa-hand-holding-bookmark"></i></div>
                    <div>
                        <h4 style="font-size: 22px; font-weight: 700; color: #1e3a8a; margin: 0;"><asp:Literal ID="litStatIssued" runat="server" Text="0" /></h4>
                        <span style="font-size: 11px; font-weight: 600; text-transform: uppercase; color: #1d4ed8; letter-spacing: 0.5px;">Issued</span>
                    </div>
                </div>

                <!-- Stat Card: Reserved -->
                <div class="stat-card sc-reserved">
                    <div style="width: 44px; height: 44px; border-radius: 50%; background-color: #fffbef; display: flex; align-items: center; justify-content: center; color: #f59e0b; font-size: 18px;"><i class="fas fa-bookmark"></i></div>
                    <div>
                        <h4 style="font-size: 22px; font-weight: 700; color: #78350f; margin: 0;"><asp:Literal ID="litStatReserved" runat="server" Text="0" /></h4>
                        <span style="font-size: 11px; font-weight: 600; text-transform: uppercase; color: #b45309; letter-spacing: 0.5px;">Reserved</span>
                    </div>
                </div>

                <!-- Stat Card: Overdue -->
                <div class="stat-card sc-overdue">
                    <div style="width: 44px; height: 44px; border-radius: 50%; background-color: #fef2f2; display: flex; align-items: center; justify-content: center; color: #ef4444; font-size: 18px;"><i class="fas fa-clock"></i></div>
                    <div>
                        <h4 style="font-size: 22px; font-weight: 700; color: #7f1d1d; margin: 0;"><asp:Literal ID="litStatOverdue" runat="server" Text="0" /></h4>
                        <span style="font-size: 11px; font-weight: 600; text-transform: uppercase; color: #b91c1c; letter-spacing: 0.5px;">Overdue</span>
                    </div>
                </div>

                <!-- Stat Card: Lost -->
                <div class="stat-card sc-lost">
                    <div style="width: 44px; height: 44px; border-radius: 50%; background-color: #fef2f2; display: flex; align-items: center; justify-content: center; color: #7f1d1d; font-size: 18px;"><i class="fas fa-times-circle"></i></div>
                    <div>
                        <h4 style="font-size: 22px; font-weight: 700; color: #7f1d1d; margin: 0;"><asp:Literal ID="litStatLost" runat="server" Text="0" /></h4>
                        <span style="font-size: 11px; font-weight: 600; text-transform: uppercase; color: #7f1d1d; letter-spacing: 0.5px;">Lost</span>
                    </div>
                </div>

                <!-- Stat Card: Damaged -->
                <div class="stat-card sc-damaged">
                    <div style="width: 44px; height: 44px; border-radius: 50%; background-color: #fff7ed; display: flex; align-items: center; justify-content: center; color: #f97316; font-size: 18px;"><i class="fas fa-heart-broken"></i></div>
                    <div>
                        <h4 style="font-size: 22px; font-weight: 700; color: #7c2d12; margin: 0;"><asp:Literal ID="litStatDamaged" runat="server" Text="0" /></h4>
                        <span style="font-size: 11px; font-weight: 600; text-transform: uppercase; color: #c2410c; letter-spacing: 0.5px;">Damaged</span>
                    </div>
                </div>

                <!-- Stat Card: Missing -->
                <div class="stat-card sc-missing">
                    <div style="width: 44px; height: 44px; border-radius: 50%; background-color: #f5f3ff; display: flex; align-items: center; justify-content: center; color: #8b5cf6; font-size: 18px;"><i class="fas fa-question-circle"></i></div>
                    <div>
                        <h4 style="font-size: 22px; font-weight: 700; color: #4c1d95; margin: 0;"><asp:Literal ID="litStatMissing" runat="server" Text="0" /></h4>
                        <span style="font-size: 11px; font-weight: 600; text-transform: uppercase; color: #6d28d9; letter-spacing: 0.5px;">Missing</span>
                    </div>
                </div>

                <!-- Stat Card: Withdrawn -->
                <div class="stat-card sc-withdrawn">
                    <div style="width: 44px; height: 44px; border-radius: 50%; background-color: #f1f5f9; display: flex; align-items: center; justify-content: center; color: #1e293b; font-size: 18px;"><i class="fas fa-trash-alt"></i></div>
                    <div>
                        <h4 style="font-size: 22px; font-weight: 700; color: #0f172a; margin: 0;"><asp:Literal ID="litStatWithdrawn" runat="server" Text="0" /></h4>
                        <span style="font-size: 11px; font-weight: 600; text-transform: uppercase; color: #334155; letter-spacing: 0.5px;">Withdrawn</span>
                    </div>
                </div>

            </div>

            <!-- Page Main Working Tabs -->
            <div style="display: flex; flex-direction: column; width: 100%; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); overflow: hidden; margin-bottom: 30px; box-sizing: border-box;">
                
                <!-- Dynamic Sidebar/Tab Navigation Headers -->
                <div style="display: flex; background-color: #f8fafc; border-bottom: 1px solid #e2e8f0; width: 100%; box-sizing: border-box; overflow-x: auto; white-space: nowrap; scrollbar-width: thin;" id="tabHeaders" class="no-print">
                    <button type="button" class="tab-header-btn" style="padding: 16px 22px; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #c5a059; border-bottom: 3px solid #c5a059; background-color: #ffffff; cursor: pointer; transition: all 0.2s ease; outline: none;" onclick="switchTab(0)">Stock Directory</button>
                    <button type="button" class="tab-header-btn" style="padding: 16px 22px; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.2s ease; outline: none;" onclick="switchTab(1)">Inventory Audit (Verification)</button>
                    <button type="button" class="tab-header-btn" style="padding: 16px 22px; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.2s ease; outline: none;" onclick="switchTab(2)">Reconcile / Mark Missing</button>
                    <button type="button" class="tab-header-btn" style="padding: 16px 22px; background: none; border: none; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: #64748b; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.2s ease; outline: none;" onclick="switchTab(3)">Stock Reports & Exports</button>
                </div>

                <!-- Tabs Content Card -->
                <div style="padding: 24px; width: 100%; box-sizing: border-box;">

                    <!-- ==========================================
                         TAB 0: STOCK DIRECTORY
                         ========================================== -->
                    <div id="paneStockDirectory" class="tab-pane" style="display: block; width: 100%;">
                        
                        <!-- Search & Filter Container -->
                        <div class="filter-panel-custom no-print">
                            <h3 style="margin-top: 0; margin-bottom: 16px; font-size: 16px; font-weight: 600; color: #0f1e36; display: flex; align-items: center; gap: 8px;">
                                <i class="fas fa-filter" style="color: #c5a059;"></i> Advanced Search Filters
                            </h3>
                            <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 16px; width: 100%; box-sizing: border-box;">
                                
                                <!-- Filter: Title -->
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Book Title</label>
                                    <asp:TextBox ID="txtFilterTitle" runat="server" CssClass="form-input-stock" placeholder="Search Title..." />
                                </div>

                                <!-- Filter: Accession Number -->
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Accession Number</label>
                                    <asp:TextBox ID="txtFilterAcqNo" runat="server" CssClass="form-input-stock" placeholder="Accession No..." />
                                </div>

                                <!-- Filter: Book Number -->
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Book Number (BookNo)</label>
                                    <asp:TextBox ID="txtFilterBookNo" runat="server" CssClass="form-input-stock" placeholder="Book No..." />
                                </div>

                                <!-- Filter: Barcode -->
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Barcode</label>
                                    <asp:TextBox ID="txtFilterBarcode" runat="server" CssClass="form-input-stock" placeholder="Scanned Barcode..." />
                                </div>

                                <!-- Filter: ISBN -->
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">ISBN</label>
                                    <asp:TextBox ID="txtFilterISBN" runat="server" CssClass="form-input-stock" placeholder="ISBN-13 / ISBN-10..." />
                                </div>

                                <!-- Filter: Author -->
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Author</label>
                                    <asp:TextBox ID="txtFilterAuthor" runat="server" CssClass="form-input-stock" placeholder="Author name..." />
                                </div>

                                <!-- Filter: Category -->
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Category</label>
                                    <asp:DropDownList ID="ddlFilterCategory" runat="server" CssClass="form-input-stock" />
                                </div>

                                <!-- Filter: Subject -->
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Subject Tag</label>
                                    <asp:TextBox ID="txtFilterSubject" runat="server" CssClass="form-input-stock" placeholder="Subject tag..." />
                                </div>

                                <!-- Filter: Language -->
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Language</label>
                                    <asp:DropDownList ID="ddlFilterLanguage" runat="server" CssClass="form-input-stock" />
                                </div>

                                <!-- Filter: Publisher -->
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Publisher</label>
                                    <asp:TextBox ID="txtFilterPublisher" runat="server" CssClass="form-input-stock" placeholder="Type publisher..." />
                                </div>

                                <!-- Filter: DDC Call Number -->
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">DDC Number</label>
                                    <asp:TextBox ID="txtFilterDDC" runat="server" CssClass="form-input-stock" placeholder="DDC Call No..." />
                                </div>

                                <!-- Filter: Branch/Hall -->
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Branch / Hall</label>
                                    <asp:DropDownList ID="ddlFilterHall" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterHall_SelectedIndexChanged" CssClass="form-input-stock" />
                                </div>

                                <!-- Filter: Floor -->
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Floor</label>
                                    <asp:DropDownList ID="ddlFilterFloor" runat="server" CssClass="form-input-stock">
                                        <asp:ListItem Value="" Text="-- All Floors --" />
                                        <asp:ListItem Value="0" Text="Ground Floor" />
                                        <asp:ListItem Value="1" Text="First Floor" />
                                        <asp:ListItem Value="2" Text="Second Floor" />
                                        <asp:ListItem Value="3" Text="Third Floor" />
                                    </asp:DropDownList>
                                </div>

                                <!-- Filter: Section/Shelf Unit -->
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Section / Unit</label>
                                    <asp:TextBox ID="txtFilterSection" runat="server" CssClass="form-input-stock" placeholder="Section code or unit..." />
                                </div>

                                <!-- Filter: Rack -->
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Rack Number</label>
                                    <asp:DropDownList ID="ddlFilterRack" runat="server" CssClass="form-input-stock" />
                                </div>

                                <!-- Filter: Shelf Slot -->
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Shelf Slot</label>
                                    <asp:TextBox ID="txtFilterSlot" runat="server" CssClass="form-input-stock" placeholder="Slot index (1-100)..." Type="Number" />
                                </div>

                                <!-- Filter: Stock Status -->
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Stock Status</label>
                                    <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="form-input-stock">
                                        <asp:ListItem Value="" Text="-- All Statuses --" />
                                        <asp:ListItem Value="Available" Text="Available" />
                                        <asp:ListItem Value="Issued" Text="Issued" />
                                        <asp:ListItem Value="Reserved" Text="Reserved" />
                                        <asp:ListItem Value="Overdue" Text="Overdue" />
                                        <asp:ListItem Value="Lost" Text="Lost" />
                                        <asp:ListItem Value="Damaged" Text="Damaged" />
                                        <asp:ListItem Value="Missing" Text="Missing" />
                                        <asp:ListItem Value="Repair" Text="Repair" />
                                        <asp:ListItem Value="Withdrawn" Text="Withdrawn" />
                                    </asp:DropDownList>
                                </div>

                                <!-- Filter: Acq Date From -->
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Acquired From</label>
                                    <asp:TextBox ID="txtFilterDateFrom" runat="server" CssClass="form-input-stock" Type="Date" />
                                </div>

                                <!-- Filter: Acq Date To -->
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Acquired To</label>
                                    <asp:TextBox ID="txtFilterDateTo" runat="server" CssClass="form-input-stock" Type="Date" />
                                </div>

                                <!-- Filter Buttons -->
                                <div style="display: flex; gap: 10px; align-items: end; grid-column: span 2;">
                                    <asp:LinkButton ID="btnApplyFilters" runat="server" OnClick="btnApplyFilters_Click" style="flex: 1; text-align: center; padding: 11px 18px; border-radius: 8px; font-weight: 700; text-transform: uppercase; text-decoration: none; font-size: 13px; letter-spacing: 0.5px; background-color: #0f1e36; color: #ffffff; display: flex; align-items: center; justify-content: center; gap: 8px; height: 42px; box-sizing: border-box;">
                                        <i class="fas fa-search"></i> Search
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnClearFilters" runat="server" OnClick="btnClearFilters_Click" style="padding: 11px 18px; border: 1px solid #cbd5e1; border-radius: 8px; font-weight: 600; text-decoration: none; font-size: 13.5px; color: #334155; background-color: #ffffff; display: flex; align-items: center; justify-content: center; gap: 6px; height: 42px; box-sizing: border-box; transition: background-color 0.2s;" onmouseover="this.style.backgroundColor='#f8fafc';" onmouseout="this.style.backgroundColor='#ffffff';">
                                        <i class="fas fa-redo"></i> Reset
                                    </asp:LinkButton>
                                </div>

                            </div>
                        </div>

                        <!-- Grid Results Toolbar -->
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;" class="no-print">
                            <span style="font-size: 14px; font-weight: 500; color: #475569;">
                                Showing Stock Copies: <strong><asp:Literal ID="litGridRecordCount" runat="server" Text="0" /></strong> records found
                            </span>
                            <div style="display: flex; gap: 10px;">
                                <!-- Simple Quick Print -->
                                <button type="button" class="btn-action-primary" style="padding: 8px 16px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; font-weight: 600; background-color: #ffffff; color: #1e293b; cursor: pointer; transition: all 0.2s;" onclick="window.print()">
                                    <i class="fas fa-print" style="margin-right: 6px; color: #c5a059;"></i> Print Screen
                                </button>
                            </div>
                        </div>

                        <!-- Data GridView -->
                        <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; box-shadow: 0 1px 2px rgba(0,0,0,0.03);">
                            <asp:GridView ID="gvStock" runat="server" AutoGenerateColumns="False" AllowPaging="True" AllowSorting="True" PageSize="15"
                                OnPageIndexChanging="gvStock_PageIndexChanging" OnSorting="gvStock_Sorting" OnRowDataBound="gvStock_RowDataBound"
                                Width="100%" GridLines="None" CssClass="report-grid" DataKeyNames="BookID">
                                <HeaderStyle CssClass="gv-header" />
                                <RowStyle CssClass="gv-row" />
                                <AlternatingRowStyle CssClass="gv-alt-row" />
                                <PagerStyle CssClass="pager-style" />
                                <Columns>
                                    <asp:TemplateField HeaderText="Catalogue Stock Inventory (Grouped by Book Title)" HeaderStyle-CssClass="gv-header-left">
                                        <ItemTemplate>
                                            <!-- Parent Book Header Row -->
                                            <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 14px 18px; margin: 6px 0; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; box-sizing: border-box;">
                                                
                                                <div style="display: flex; gap: 14px; align-items: center; flex: 1; min-width: 280px;">
                                                    <!-- Expand/Collapse Button -->
                                                    <button type="button" onclick="toggleCopiesTable(this, 'copies_<%# Eval("BookID") %>');" style="width: 30px; height: 30px; border-radius: 6px; border: 1px solid #cbd5e1; background: #ffffff; color: #0f1e36; font-size: 12px; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; flex-shrink: 0; transition: all 0.2s;" title="Toggle Physical Copies">
                                                        <i class="fas fa-chevron-down"></i>
                                                    </button>

                                                    <!-- Book Cover Image -->
                                                    <div style="width: 44px; height: 58px; border-radius: 4px; overflow: hidden; border: 1px solid #e2e8f0; background-color: #f1f5f9; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                                                        <%# GetBookCover(Eval("CoverFile")) %>
                                                    </div>

                                                    <!-- Book Information -->
                                                    <div style="text-align: left;">
                                                        <h5 style="margin: 0; font-size: 15px; font-weight: 700; color: #0f1e36;"><%# Eval("Title") %></h5>
                                                        <span style="font-size: 12.5px; color: #64748b; display: block; margin-top: 2px;">By <strong><%# Eval("Authors") %></strong></span>
                                                        <span style="font-size: 11px; color: #94a3b8; display: block; margin-top: 1px;">ISBN: <%# Eval("ISBN13") %> | DDC: <%# Eval("DDC") %> | Category: <%# Eval("CatName") %></span>
                                                    </div>
                                                </div>

                                                <!-- Summary Badges -->
                                                <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
                                                    <span style="background-color: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; padding: 4px 10px; border-radius: 12px; font-size: 11.5px; font-weight: 700;">
                                                        Total Copies: <%# Eval("TotalCopies") %>
                                                    </span>
                                                    <span style="background-color: #d1fae5; color: #065f46; border: 1px solid #10b981; padding: 4px 10px; border-radius: 12px; font-size: 11.5px; font-weight: 700;">
                                                        Available: <%# Eval("AvailableCopies") %>
                                                    </span>
                                                </div>

                                            </div>

                                            <!-- Child Copies Table (Nested Grouping) -->
                                            <div id="copies_<%# Eval("BookID") %>" style="display: block; margin: 4px 0 14px 20px; padding: 12px; background: #ffffff; border: 1px solid #cbd5e1; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.03);">
                                                <h6 style="margin: 0 0 10px 0; font-size: 12px; font-weight: 700; text-transform: uppercase; color: #c5a059; letter-spacing: 0.5px; display: flex; align-items: center; gap: 6px; text-align: left;">
                                                    <i class="fas fa-book"></i> Physical Copies for this Book Title
                                                </h6>
                                                <asp:Repeater ID="rptChildCopies" runat="server">
                                                    <HeaderTemplate>
                                                        <table style="width: 100%; border-collapse: collapse; font-size: 12.5px; text-align: left;">
                                                            <thead>
                                                                <tr style="background-color: #0f1e36; color: #ffffff; font-weight: 700;">
                                                                    <th style="padding: 8px 12px; border-top-left-radius: 6px;">Book No</th>
                                                                    <th style="padding: 8px 12px;">Barcode</th>
                                                                    <th style="padding: 8px 12px;">Shelf Location</th>
                                                                    <th style="padding: 8px 12px;">Status</th>
                                                                    <th style="padding: 8px 12px;">Condition</th>
                                                                    <th style="padding: 8px 12px;">Acq Date</th>
                                                                    <th style="padding: 8px 12px; text-align: center; border-top-right-radius: 6px;" class="no-print">Actions</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <tr style="border-bottom: 1px solid #f1f5f9;">
                                                            <td style="padding: 8px 12px; font-weight: 700; color: #0f1e36;">Book #<%# Eval("BookNo") %></td>
                                                            <td style="padding: 8px 12px; font-weight: 700; color: #334155;"><%# Eval("Barcode") %></td>
                                                            <td style="padding: 8px 12px;">
                                                                <strong><%# (Eval("HallName") != DBNull.Value) ? Eval("HallName") : "Unassigned" %></strong>
                                                                <span style="font-size: 11px; color: #64748b; display: block;">
                                                                    <%# (Eval("UnitCode") != DBNull.Value) ? "Unit " + Eval("UnitCode") + " | Rack " + Eval("RackNo") + " | Slot " + Eval("SlotNo") : "No Location" %>
                                                                </span>
                                                            </td>
                                                            <td style="padding: 8px 12px;"><%# GetStatusBadge(Eval("ComputedStatus")) %></td>
                                                            <td style="padding: 8px 12px;"><%# Eval("CondName") %></td>
                                                            <td style="padding: 8px 12px;"><%# Eval("AcqDate", "{0:dd-MMM-yyyy}") %></td>
                                                            <td style="padding: 8px 12px; text-align: center;" class="no-print">
                                                                <div style="display: flex; gap: 6px; justify-content: center; align-items: center;">
                                                                    <asp:LinkButton ID="btnView" runat="server" OnCommand="btnCopyAction_Command" CommandName="ViewDetails" CommandArgument='<%# Eval("CopyID") %>' ToolTip="View Details & History" style="width: 28px; height: 28px; border-radius: 4px; border: 1px solid #e2e8f0; display: inline-flex; align-items: center; justify-content: center; color: #0f1e36; background: #ffffff;"><i class="fas fa-eye"></i></asp:LinkButton>
                                                                    <asp:LinkButton ID="btnTransfer" runat="server" OnCommand="btnCopyAction_Command" CommandName="TransferLocation" CommandArgument='<%# Eval("CopyID") %>' ToolTip="Relocate Copy" style="width: 28px; height: 28px; border-radius: 4px; border: 1px solid #e2e8f0; display: inline-flex; align-items: center; justify-content: center; color: #c5a059; background: #ffffff;"><i class="fas fa-exchange-alt"></i></asp:LinkButton>
                                                                    <asp:LinkButton ID="btnStatus" runat="server" OnCommand="btnCopyAction_Command" CommandName="ChangeStatus" CommandArgument='<%# Eval("CopyID") %>' ToolTip="Change Status / Condition" style="width: 28px; height: 28px; border-radius: 4px; border: 1px solid #e2e8f0; display: inline-flex; align-items: center; justify-content: center; color: #f97316; background: #ffffff;"><i class="fas fa-wrench"></i></asp:LinkButton>
                                                                    <asp:LinkButton ID="btnPrint" runat="server" OnCommand="btnCopyAction_Command" CommandName="PrintBarcode" CommandArgument='<%# Eval("CopyID") %>' ToolTip="Print Barcode Label" style="width: 28px; height: 28px; border-radius: 4px; border: 1px solid #e2e8f0; display: inline-flex; align-items: center; justify-content: center; color: #64748b; background: #ffffff;"><i class="fas fa-barcode"></i></asp:LinkButton>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </ItemTemplate>
                                                    <FooterTemplate>
                                                            </tbody>
                                                        </table>
                                                    </FooterTemplate>
                                                </asp:Repeater>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <EmptyDataTemplate>
                                    <div style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff;">No stock items match your search criteria.</div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>

                    </div>

                    <!-- ==========================================
                         TAB 1: INVENTORY AUDIT (VERIFICATION)
                         ========================================== -->
                    <div id="paneInventoryAudit" class="tab-pane" style="display: none; width: 100%;">
                        
                        <!-- Panel: No active session (form to start) -->
                        <asp:Panel ID="pnlStartAuditSession" runat="server" Visible="true">
                            <div style="max-width: 600px; margin: 40px auto; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 30px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); text-align: center; box-sizing: border-box;">
                                <div style="width: 64px; height: 64px; border-radius: 50%; background-color: #fef3c7; color: #d97706; display: flex; align-items: center; justify-content: center; font-size: 28px; margin: 0 auto 20px;"><i class="fas fa-clipboard-check"></i></div>
                                <h3 style="margin-top: 0; margin-bottom: 8px; font-family: 'Playfair Display', serif; font-size: 20px; color: #0f1e36;">Start Inventory Stock Audit</h3>
                                <p style="font-size: 13.5px; color: #64748b; margin-bottom: 24px; line-height: 1.5;">Relocates missing books, resolves anomalies, and reconciles catalog database entries with physical shelf contents.</p>
                                
                                <div style="display: flex; flex-direction: column; gap: 16px; text-align: left; margin-bottom: 24px;">
                                    <div style="display: flex; flex-direction: column; gap: 5px;">
                                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Audit Session Name</label>
                                        <asp:TextBox ID="txtAuditSessionName" runat="server" CssClass="form-input-stock" placeholder="e.g. Annual Library Stock Audit - July 2026" />
                                    </div>
                                    <div style="display: flex; flex-direction: column; gap: 5px;">
                                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Audit Scope / Target</label>
                                        <asp:DropDownList ID="ddlAuditScope" runat="server" CssClass="form-input-stock">
                                            <asp:ListItem Value="ALL" Text="All Active Catalogue Items" />
                                        </asp:DropDownList>
                                    </div>
                                    <div style="display: flex; flex-direction: column; gap: 5px;">
                                        <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Audit Notes / Remarks</label>
                                        <asp:TextBox ID="txtAuditRemarks" runat="server" CssClass="form-input-stock" style="height: 60px; padding: 10px; resize: none;" TextMode="MultiLine" placeholder="Additional audit instructions..." />
                                    </div>
                                </div>

                                <asp:Button ID="btnStartAudit" runat="server" Text="Start Session" OnClick="btnStartAudit_Click" class="btn-action-primary" style="padding: 12px 30px; font-size: 14px; font-weight: 700; text-transform: uppercase; border-radius: 8px; border: none; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #0f1e36; cursor: pointer; box-shadow: 0 4px 12px rgba(197, 160, 89, 0.25);" />
                            </div>
                        </asp:Panel>

                        <!-- Panel: Active session workflow -->
                        <asp:Panel ID="pnlActiveAuditWorkflow" runat="server" Visible="false">
                            
                            <!-- Audit Info Header Box -->
                            <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 18px 24px; margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px; box-sizing: border-box;">
                                <div>
                                    <span style="font-size: 10px; font-weight: 700; text-transform: uppercase; color: #c5a059; letter-spacing: 1px;">Active Audit Session</span>
                                    <h4 style="margin: 4px 0; font-size: 18px; font-weight: 700; color: #0f1e36;"><asp:Literal ID="litActiveSessionName" runat="server" Text="-" /></h4>
                                    <span style="font-size: 12px; color: #64748b;">Launched on: <asp:Literal ID="litActiveSessionDate" runat="server" Text="-" /></span>
                                </div>
                                <div style="display: flex; gap: 8px; flex-wrap: wrap;">
                                    <asp:LinkButton ID="btnViewActiveReport" runat="server" OnClick="btnViewActiveReport_Click" style="padding: 10px 16px; font-size: 13px; font-weight: 600; background-color: #0f1e36; color: #ffffff; border: none; border-radius: 6px; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 6px;"><i class="fas fa-file-alt"></i> Scanned Report</asp:LinkButton>
                                    <asp:LinkButton ID="btnViewActiveMissingReport" runat="server" OnClick="btnViewActiveMissingReport_Click" style="padding: 10px 16px; font-size: 13px; font-weight: 600; background-color: #7f1d1d; color: #ffffff; border: none; border-radius: 6px; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 6px;"><i class="fas fa-exclamation-circle"></i> Non-Scanned Report</asp:LinkButton>
                                    <asp:Button ID="btnCompleteAudit" runat="server" Text="Complete Session" OnClick="btnCompleteAudit_Click" class="btn-action-primary" style="padding: 10px 20px; font-size: 13px; font-weight: 700; background-color: #10b981; color: #ffffff; border: none; border-radius: 6px; cursor: pointer;" />
                                    <asp:Button ID="btnCancelAudit" runat="server" Text="Cancel Session" OnClick="btnCancelAudit_Click" class="btn-action-primary" style="padding: 10px 20px; font-size: 13px; font-weight: 600; background-color: #ffffff; color: #ef4444; border: 1px solid #fee2e2; border-radius: 6px; cursor: pointer;" />
                                </div>
                            </div>

                            <!-- Audit Progress & Live Scan input -->
                            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 24px; margin-bottom: 30px; box-sizing: border-box; align-items: start;">
                                
                                <!-- Barcode Scanning Box -->
                                <div style="background-color: #ffffff; border: 1px solid #cbd5e1; border-radius: 12px; padding: 24px; box-sizing: border-box; display: flex; flex-direction: column; gap: 16px;">
                                    <h5 style="margin: 0; font-size: 15px; font-weight: 700; color: #0f1e36; display: flex; align-items: center; gap: 8px;"><i class="fas fa-barcode" style="color: #c5a059; font-size: 18px;"></i> Scanner Log Input</h5>
                                    <p style="margin: 0; font-size: 12.5px; color: #64748b;">Set focus on this field and scan physical copy barcodes or enter Book Number (BookNo), then press Enter.</p>
                                    
                                    <div style="display: flex; gap: 12px;">
                                        <asp:TextBox ID="txtScanBarcode" runat="server" CssClass="form-input-stock" AutoPostBack="true" OnTextChanged="txtScanBarcode_TextChanged" style="flex: 1; font-size: 16px; font-weight: 700; height: 50px; text-transform: uppercase;" placeholder="Scan barcode or type BookNo..." autocomplete="off" />
                                        <asp:Button ID="btnVerifyManual" runat="server" Text="Verify" OnClick="btnVerifyManual_Click" style="padding: 0 24px; font-size: 14px; font-weight: 700; height: 50px; border-radius: 8px; border: none; background-color: #0f1e36; color: #ffffff; cursor: pointer;" />
                                    </div>
                                    <asp:Label ID="lblScanFeedback" runat="server" style="font-size: 13.5px; font-weight: 600;" />
                                </div>

                                <!-- Progress Gauge Card -->
                                <div style="background: linear-gradient(135deg, #0f1e36 0%, #172b4c 100%); color: #ffffff; border-radius: 12px; padding: 24px; box-sizing: border-box; display: flex; flex-direction: column; gap: 16px; justify-content: space-between; min-height: 180px;">
                                    <div>
                                        <h5 style="margin: 0; font-size: 13px; font-weight: 700; text-transform: uppercase; color: #c5a059; letter-spacing: 0.5px;">Verification Progress</h5>
                                        <h3 style="font-size: 26px; font-weight: 800; margin: 10px 0 0;"><asp:Literal ID="litAuditProgressPct" runat="server" Text="0.0%" /></h3>
                                        <span style="font-size: 12px; opacity: 0.8;"><asp:Literal ID="litAuditProgressRatio" runat="server" Text="0 / 0 items verified" /></span>
                                    </div>
                                    <!-- Progress Bar Container -->
                                    <div style="width: 100%; height: 8px; background-color: rgba(255,255,255,0.15); border-radius: 4px; overflow: hidden;">
                                        <div id="divAuditProgressBar" runat="server" style="height: 100%; background: linear-gradient(90deg, #c5a059 0%, #10b981 100%); width: 0%;"></div>
                                    </div>
                                </div>

                            </div>

                            <!-- Verification Items Split Tabs (Matches, Misplaced, Missing) -->
                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; margin-bottom: 20px; box-sizing: border-box;">
                                <!-- Verification Stat Card: Expected -->
                                <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 16px; text-align: center;">
                                    <span style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px;">Expected Stock</span>
                                    <h4 style="font-size: 20px; font-weight: 700; color: #0f1e36; margin: 4px 0 0;"><asp:Literal ID="litAuditCountExpected" runat="server" Text="0" /></h4>
                                </div>
                                <!-- Verification Stat Card: Verified Matches -->
                                <div style="background-color: #ecfdf5; border: 1px solid #d1fae5; border-radius: 8px; padding: 16px; text-align: center;">
                                    <span style="font-size: 11px; font-weight: 700; color: #047857; text-transform: uppercase; letter-spacing: 0.5px;">Verified Matches</span>
                                    <h4 style="font-size: 20px; font-weight: 700; color: #10b981; margin: 4px 0 0;"><asp:Literal ID="litAuditCountMatches" runat="server" Text="0" /></h4>
                                </div>
                                <!-- Verification Stat Card: Condition Warnings -->
                                <div style="background-color: #fffbef; border: 1px solid #fef3c7; border-radius: 8px; padding: 16px; text-align: center;">
                                    <span style="font-size: 11px; font-weight: 700; color: #b45309; text-transform: uppercase; letter-spacing: 0.5px;">Condition Warnings</span>
                                    <h4 style="font-size: 20px; font-weight: 700; color: #f59e0b; margin: 4px 0 0;"><asp:Literal ID="litAuditCountMisplaced" runat="server" Text="0" /></h4>
                                    <span style="font-size: 10px; color: #92400e;">(Lost / Weeded Out / Missing)</span>
                                </div>
                                <!-- Verification Stat Card: Missing expected -->
                                <div style="background-color: #fef2f2; border: 1px solid #fee2e2; border-radius: 8px; padding: 16px; text-align: center;">
                                    <span style="font-size: 11px; font-weight: 700; color: #b91c1c; text-transform: uppercase; letter-spacing: 0.5px;">Missing on shelves</span>
                                    <h4 style="font-size: 20px; font-weight: 700; color: #ef4444; margin: 4px 0 0;"><asp:Literal ID="litAuditCountMissing" runat="server" Text="0" /></h4>
                                </div>
                            </div>



                                <!-- Recently Verified Grid List -->
                                <div>
                                    <h4 style="margin-top: 0; margin-bottom: 12px; font-size: 15px; font-weight: 700; color: #0f1e36; display: flex; align-items: center; gap: 8px;">
                                        <i class="fas fa-list"></i> Verified Audited Items (Scan Log)
                                    </h4>
                                    <div style="overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px;">
                                        <asp:GridView ID="gvAuditVerified" runat="server" AutoGenerateColumns="False" AllowPaging="True" PageSize="15" OnPageIndexChanging="gvAuditVerified_PageIndexChanging" Width="100%" GridLines="None" CssClass="report-grid">
                                            <HeaderStyle CssClass="gv-header" />
                                            <RowStyle CssClass="gv-row" />
                                            <AlternatingRowStyle CssClass="gv-alt-row" />
                                            <PagerStyle CssClass="pager-style" />
                                            <Columns>
                                                <asp:BoundField DataField="ScannedBarcode" HeaderText="Scanned Barcode" ItemStyle-Font-Bold="true" HeaderStyle-CssClass="gv-header-left" />
                                                <asp:BoundField DataField="BookNo" HeaderText="Book No" HeaderStyle-CssClass="gv-header-left" />
                                                <asp:BoundField DataField="Title" HeaderText="Book Title" HeaderStyle-CssClass="gv-header-left" />
                                                <asp:BoundField DataField="ShelfAddress" HeaderText="Assigned Location" HeaderStyle-CssClass="gv-header-left" NullDisplayText="Unassigned" />
                                                <asp:BoundField DataField="CondName" HeaderText="Condition" />
                                                <asp:TemplateField HeaderText="Status">
                                                    <ItemTemplate>
                                                        <span style='color: #10b981; font-weight: 700;'><i class='fas fa-check-circle'></i> <%# Eval("CondName") %></span>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:BoundField DataField="VerifiedAt" HeaderText="Verified At" DataFormatString="{0:hh:mm:ss tt}" />
                                            </Columns>
                                            <EmptyDataTemplate>
                                                <div style="padding: 30px; text-align: center; color: #64748b; font-style: italic; font-size: 13.5px; background-color: #ffffff;">No verified items logged yet. Begin scanning copy barcodes.</div>
                                            </EmptyDataTemplate>
                                        </asp:GridView>
                                    </div>
                                </div>
                            </div>

                        </asp:Panel>

                    </div>

                    <!-- ==========================================
                         TAB 2: RECONCILE / MARK MISSING
                         ========================================== -->
                    <div id="paneReconcileMissing" class="tab-pane" style="display: none; width: 100%;">
                        
                        <!-- Panel: No active session -->
                        <asp:Panel ID="pnlReconcileNoActiveSession" runat="server" Visible="true">
                            <div style="max-width: 600px; margin: 40px auto; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 30px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); text-align: center; box-sizing: border-box;">
                                <div style="width: 64px; height: 64px; border-radius: 50%; background-color: #fee2e2; color: #ef4444; display: flex; align-items: center; justify-content: center; font-size: 28px; margin: 0 auto 20px;"><i class="fas fa-exclamation-triangle"></i></div>
                                <h3 style="margin-top: 0; margin-bottom: 8px; font-family: 'Playfair Display', serif; font-size: 20px; color: #0f1e36;">Reconcile Non-Verified Stock</h3>
                                <p style="font-size: 13.5px; color: #64748b; margin-bottom: 0; line-height: 1.5;">No active audit session in progress. Please launch an inventory stock audit session under the "Inventory Audit (Verification)" tab first.</p>
                            </div>
                        </asp:Panel>

                        <!-- Panel: Active session reconciliation -->
                        <asp:Panel ID="pnlReconcileActiveSession" runat="server" Visible="false">
                            <!-- Reconcile Header Info -->
                            <div style="margin-bottom: 20px; border-bottom: 1px solid #e2e8f0; padding-bottom: 15px;">
                                <h3 style="margin: 0 0 5px 0; font-family: 'Playfair Display', serif; font-size: 18px; color: #0f1e36;">Audit Reconciliation Panel</h3>
                                <p style="margin: 0; font-size: 13px; color: #64748b;">The grid below displays all copies expected on shelves (physically available conditions and not currently on loan) that have <strong>NOT</strong> been scanned/verified in the current session. You can bulk-select them to mark them as missing.</p>
                            </div>

                            <!-- Action buttons container -->
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; flex-wrap: wrap; gap: 10px; padding: 15px; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; box-sizing: border-box;">
                                <div style="display: flex; gap: 10px; align-items: center;">
                                    <asp:Button ID="btnMarkSelectedMissing" runat="server" Text="Mark Selected as Missing" OnClick="btnMarkSelectedMissing_Click" OnClientClick="return confirm('Are you sure you want to mark all selected copies as MISSING? This will update their condition and clear their shelf location.');" CssClass="btn-action-primary" style="padding: 10px 18px; font-size: 12.5px; font-weight: 700; background-color: #ef4444; color: #ffffff; border: none; border-radius: 6px; cursor: pointer; box-shadow: 0 2px 4px rgba(239, 68, 68, 0.15);" />
                                    <asp:Button ID="btnMarkAllMissing" runat="server" Text="Mark All Remaining as Missing" OnClick="btnMarkAllMissing_Click" OnClientClick="return confirm('WARNING: Are you sure you want to mark ALL expected but non-verified copies in this session as MISSING? This action will process all items currently not scanned.');" CssClass="btn-action-primary" style="padding: 10px 18px; font-size: 12.5px; font-weight: 700; background-color: #7f1d1d; color: #ffffff; border: none; border-radius: 6px; cursor: pointer; box-shadow: 0 2px 4px rgba(127, 29, 29, 0.15);" />
                                </div>
                                <div style="font-size: 12.5px; color: #0f1e36; font-weight: 600;">
                                    <asp:Literal ID="litReconcileSummaryText" runat="server" Text="0 expected items remaining to reconcile." />
                                </div>
                            </div>

                            <!-- The Non-Verified Grid -->
                            <div style="overflow-x: auto; border: 1px solid #fee2e2; border-radius: 8px;">
                                <asp:GridView ID="gvReconcileMissing" runat="server" AutoGenerateColumns="False" AllowPaging="True" PageSize="15" OnPageIndexChanging="gvReconcileMissing_PageIndexChanging" Width="100%" GridLines="None" CssClass="report-grid" DataKeyNames="CopyID">
                                    <HeaderStyle CssClass="gv-header gv-header-red" />
                                    <RowStyle CssClass="gv-row" />
                                    <AlternatingRowStyle CssClass="gv-alt-row" />
                                    <PagerStyle CssClass="pager-style" />
                                    <Columns>
                                        <asp:TemplateField HeaderStyle-Width="40px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                            <HeaderTemplate>
                                                <input type="checkbox" id="chkSelectAllReconcile" onclick="toggleAllReconcileCheckboxes(this);" style="cursor: pointer; transform: scale(1.15);" />
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <asp:CheckBox ID="chkSelectCopy" runat="server" style="cursor: pointer; transform: scale(1.15);" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField DataField="Barcode" HeaderText="Barcode" ItemStyle-Font-Bold="true" HeaderStyle-CssClass="gv-header-left" />
                                        <asp:BoundField DataField="BookNo" HeaderText="BookNo" HeaderStyle-CssClass="gv-header-left" />
                                        <asp:BoundField DataField="Title" HeaderText="Book Title" HeaderStyle-CssClass="gv-header-left" />
                                        <asp:BoundField DataField="ShelfAddress" HeaderText="Expected Location" HeaderStyle-CssClass="gv-header-left" NullDisplayText="Unassigned" />
                                        <asp:BoundField DataField="CondName" HeaderText="Current Condition" />
                                        <asp:BoundField DataField="AcqDate" HeaderText="Acquisition Date" DataFormatString="{0:dd-MMM-yyyy}" />
                                    </Columns>
                                    <EmptyDataTemplate>
                                        <div style="padding: 40px; text-align: center; color: #047857; font-style: italic; font-size: 14px; background-color: #ffffff; font-weight: 600;">
                                            <i class="fas fa-check-circle" style="font-size: 24px; margin-bottom: 10px; display: block;"></i>
                                            Perfect Shelf Harmony! All expected items in scope have been verified.
                                        </div>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                            </div>
                        </asp:Panel>

                    </div>

                    <!-- ==========================================
                         TAB 3: STOCK REPORTS & EXPORTS
                         ========================================== -->
                    <div id="paneStockReports" class="tab-pane" style="display: none; width: 100%;">
                        
                        <!-- Report Parameters Panel -->
                        <div class="filter-panel-custom no-print">
                            <h3 style="margin-top: 0; margin-bottom: 16px; font-size: 16px; font-weight: 600; color: #0f1e36; display: flex; align-items: center; gap: 8px;">
                                <i class="fas fa-chart-pie" style="color: #c5a059;"></i> Generate Inventory Listing Reports
                            </h3>
                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 20px; align-items: end; width: 100%; box-sizing: border-box;">
                                
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Report Segment Type</label>
                                    <asp:DropDownList ID="ddlReportType" runat="server" CssClass="form-input-stock" AutoPostBack="true" OnSelectedIndexChanged="ddlReportType_SelectedIndexChanged">
                                        <asp:ListItem Value="Inventory" Text="Complete Catalogue Inventory" />
                                        <asp:ListItem Value="Shelf-wise" Text="Shelf-Wise Allocation Report" />
                                        <asp:ListItem Value="Category-wise" Text="Category-Wise Inventory Summary" />
                                        <asp:ListItem Value="Author-wise" Text="Author-Wise Catalog Listing" />
                                        <asp:ListItem Value="Language-wise" Text="Language-Wise Catalog Listing" />
                                        <asp:ListItem Value="Missing" Text="Missing Books List" />
                                        <asp:ListItem Value="Damaged" Text="Damaged Physical Copies" />
                                        <asp:ListItem Value="Lost" Text="Lost Books Ledger" />
                                        <asp:ListItem Value="Issued" Text="Active Issued Copies" />
                                        <asp:ListItem Value="Available" Text="Active Available Copies" />
                                        <asp:ListItem Value="Withdrawn" Text="Weeded Out / Withdrawn Books" />
                                        <asp:ListItem Value="ActiveAuditScanned" Text="Active Audit - Scanned/Verified List" />
                                        <asp:ListItem Value="ActiveAuditMissing" Text="Active Audit - Expected but Not Scanned" />
                                    </asp:DropDownList>
                                </div>

                                <div style="display: flex; flex-direction: column; gap: 5px;" id="divReportFilterVal" runat="server">
                                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Segment Filter Keyword</label>
                                    <asp:TextBox ID="txtReportFilterVal" runat="server" CssClass="form-input-stock" placeholder="Enter shelf code, author, category name..." />
                                </div>

                                <div style="display: flex; gap: 10px;">
                                    <asp:Button ID="btnGenerateReport" runat="server" Text="Generate Report" OnClick="btnGenerateReport_Click" class="btn-action-primary" style="padding: 11px 24px; font-size: 13.5px; font-weight: 700; border-radius: 8px; border: none; background-color: #0f1e36; color: #ffffff; cursor: pointer; height: 42px; width: 100%; box-sizing: border-box;" />
                                </div>

                            </div>
                        </div>

                        <!-- Report Output Grid Header -->
                        <div style="background-color: #ffffff; border: 1px solid #cbd5e1; border-top: 4px solid #c5a059; border-radius: 8px; padding: 20px 24px; margin-bottom: 20px; box-sizing: border-box;">
                            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
                                <div>
                                    <h4 style="margin: 0; font-family: 'Playfair Display', serif; font-size: 18px; color: #0f1e36; font-weight: 700;" id="reportTitleContainer">
                                        <asp:Literal ID="litReportTitle" runat="server" Text="Complete Catalogue Inventory Summary" />
                                    </h4>
                                    <span style="font-size: 12px; color: #64748b;" class="no-print">Generated Date: <span id="printDate"><%= DateTime.Now.ToString("dd-MMM-yyyy hh:mm tt") %></span> | Matches: <strong><asp:Literal ID="litReportCount" runat="server" Text="0" /></strong> copies</span>
                                </div>
                                <div style="display: flex; gap: 8px;" class="no-print">
                                    <asp:LinkButton ID="btnExportExcel" runat="server" OnClick="btnExportExcel_Click" style="padding: 8px 16px; border: 1px solid #10b981; background-color: #ffffff; color: #10b981; border-radius: 6px; font-size: 13px; font-weight: 600; text-decoration: none; display: flex; align-items: center; gap: 6px;">
                                        <i class="fas fa-file-excel"></i> Excel
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnExportCSV" runat="server" OnClick="btnExportCSV_Click" style="padding: 8px 16px; border: 1px solid #0f1e36; background-color: #ffffff; color: #0f1e36; border-radius: 6px; font-size: 13px; font-weight: 600; text-decoration: none; display: flex; align-items: center; gap: 6px;">
                                        <i class="fas fa-file-csv"></i> CSV
                                    </asp:LinkButton>
                                    <button type="button" style="padding: 8px 16px; border: 1px solid #ef4444; background-color: #ffffff; color: #ef4444; border-radius: 6px; font-size: 13px; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 6px;" onclick="window.print()">
                                        <i class="fas fa-file-pdf"></i> Export / Print
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- Report Output Grid table -->
                        <div style="width: 100%; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden; background-color: #ffffff;">
                            <asp:GridView ID="gvReports" runat="server" AutoGenerateColumns="False" AllowPaging="True" PageSize="20" OnPageIndexChanging="gvReports_PageIndexChanging" Width="100%" GridLines="None" CssClass="report-grid">
                                <HeaderStyle CssClass="gv-header" />
                                <RowStyle CssClass="gv-row" />
                                <AlternatingRowStyle CssClass="gv-alt-row" />
                                <PagerStyle CssClass="pager-style" />
                                <Columns>
                                    <asp:BoundField DataField="Barcode" HeaderText="Barcode" ItemStyle-Font-Bold="true" HeaderStyle-CssClass="gv-header-left" />
                                    <asp:BoundField DataField="Title" HeaderText="Book Title" HeaderStyle-CssClass="gv-header-left" />
                                    <asp:BoundField DataField="Authors" HeaderText="Author" HeaderStyle-CssClass="gv-header-left" />
                                    <asp:BoundField DataField="CatName" HeaderText="Category" HeaderStyle-CssClass="gv-header-left" />
                                    <asp:TemplateField HeaderText="Shelf Location" HeaderStyle-CssClass="gv-header-left">
                                        <ItemTemplate>
                                            <%# (Eval("HallName") != DBNull.Value) ? Eval("HallName") + " | R" + Eval("RackNo") + " | S" + Eval("SlotNo") : "Unassigned" %>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="AcqDate" HeaderText="Acq Date" DataFormatString="{0:dd-MMM-yyyy}" />
                                    <asp:BoundField DataField="AcqCost" HeaderText="Acq Cost" DataFormatString="{0:N2}" />
                                    <asp:TemplateField HeaderText="Status">
                                        <ItemTemplate>
                                            <%# GetStatusBadge(Eval("ComputedStatus")) %>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="CondName" HeaderText="Condition" />
                                </Columns>
                                <EmptyDataTemplate>
                                    <div style="padding: 40px; text-align: center; color: #64748b; font-style: italic; font-size: 14px; background-color: #ffffff;">No records generated for the selected parameters.</div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>

                    </div>

                </div>

            </div>


            <!-- =======================================================
                 MODALS DIALOG LAYERS
                 ======================================================= -->

            <!-- MODAL 1: STOCK DETAIL DIALOG -->
            <asp:Panel ID="pnlDetailModal" runat="server" Visible="false" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.6); display: flex; justify-content: center; align-items: center; z-index: 1000;" class="no-print">
                <div style="background-color: #ffffff; border-radius: 12px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04); width: 100%; max-width: 900px; max-height: 85vh; display: flex; flex-direction: column; overflow: hidden; animation: modalSlideIn 0.3s ease-out; box-sizing: border-box;">
                    
                    <!-- Modal Header -->
                    <div style="background-color: #0f1e36; color: #ffffff; padding: 18px 24px; display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #c5a059;">
                        <h3 style="margin: 0; font-family: 'Playfair Display', serif; font-size: 18px; font-weight: 600;">Stock Copy Information</h3>
                        <asp:LinkButton ID="btnCloseDetailModal" runat="server" OnClick="btnCloseDetailModal_Click" style="color: #ffffff; font-size: 20px; text-decoration: none; opacity: 0.8; transition: opacity 0.2s;" onmouseover="this.style.opacity='1';" onmouseout="this.style.opacity='0.8';">&times;</asp:LinkButton>
                    </div>

                    <!-- Modal Body (Scrollable) -->
                    <div style="padding: 24px; overflow-y: auto; flex: 1; box-sizing: border-box; display: flex; flex-direction: column; gap: 24px;">
                        
                        <!-- Core Bibliographic Block -->
                        <div style="display: flex; gap: 20px; flex-wrap: wrap;">
                            <!-- Cover Preview -->
                            <div style="flex: 0 0 100px; height: 135px; border-radius: 6px; overflow: hidden; border: 1px solid #e2e8f0; background-color: #f8fafc; display: flex; align-items: center; justify-content: center; box-shadow: 0 1px 2px rgba(0,0,0,0.05);">
                                <asp:Literal ID="litModalCover" runat="server" />
                            </div>
                            <!-- Title & Metadata -->
                            <div style="flex: 1; min-width: 250px; display: flex; flex-direction: column; gap: 6px;">
                                <h4 style="margin: 0; font-size: 18px; font-weight: 700; color: #0f1e36;"><asp:Label ID="lblModalTitle" runat="server" /></h4>
                                <span style="font-size: 13px; color: #64748b; font-weight: 600;">By <asp:Label ID="lblModalAuthor" runat="server" /></span>
                                
                                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(130px, 1fr)); gap: 10px; margin-top: 10px; padding: 12px; background-color: #f8fafc; border-radius: 8px; border: 1px solid #e2e8f0; font-size: 12.5px;">
                                    <div>Barcode: <strong><asp:Label ID="lblModalBarcode" runat="server" /></strong></div>
                                    <div>ISBN-13: <strong><asp:Label ID="lblModalISBN" runat="server" /></strong></div>
                                    <div>Category: <strong><asp:Label ID="lblModalCategory" runat="server" /></strong></div>
                                    <div>Publisher: <strong><asp:Label ID="lblModalPublisher" runat="server" /></strong></div>
                                    <div>Acq. Date: <strong><asp:Label ID="lblModalAcqDate" runat="server" /></strong></div>
                                    <div>Acq. Cost: <strong>PKR <asp:Label ID="lblModalAcqCost" runat="server" /></strong></div>
                                    <div>DDC Call: <strong><asp:Label ID="lblModalDDC" runat="server" /></strong></div>
                                    <div>Accession: <strong><asp:Label ID="lblModalAcqNo" runat="server" /></strong></div>
                                    <div>Book Type: <strong><asp:Label ID="lblModalIsReference" runat="server" /></strong></div>
                                </div>
                            </div>
                        </div>

                        <!-- Current Physical Location & Status -->
                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; box-sizing: border-box;">
                            <!-- Physical location card -->
                            <div style="border: 1px solid #cbd5e1; border-radius: 8px; padding: 16px; background-color: #f8fafc;">
                                <h5 style="margin-top: 0; margin-bottom: 8px; font-size: 13px; font-weight: 700; color: #0f1e36; text-transform: uppercase; letter-spacing: 0.5px;"><i class="fas fa-map-marker-alt" style="color: #c5a059;"></i> Assigned Shelf Address</h5>
                                <div style="font-size: 13.5px; color: #334155;">
                                    <strong><asp:Label ID="lblModalLocationHall" runat="server" Text="Unassigned" /></strong><br />
                                    <span style="font-size: 12px; color: #64748b; display: block; margin-top: 4px;">
                                        <asp:Label ID="lblModalLocationDetails" runat="server" Text="No Location Details Assigned" />
                                    </span>
                                </div>
                            </div>
                            <!-- Current status card -->
                            <div style="border: 1px solid #cbd5e1; border-radius: 8px; padding: 16px; background-color: #f8fafc;">
                                <h5 style="margin-top: 0; margin-bottom: 8px; font-size: 13px; font-weight: 700; color: #0f1e36; text-transform: uppercase; letter-spacing: 0.5px;"><i class="fas fa-info-circle" style="color: #c5a059;"></i> State & Condition</h5>
                                <div style="display: flex; align-items: center; gap: 10px;">
                                    <asp:Literal ID="litModalStatusBadge" runat="server" />
                                    <span style="font-size: 13px; font-weight: 600; color: #475569;">Condition: <asp:Label ID="lblModalCondition" runat="server" /></span>
                                </div>
                                <div style="font-size: 12px; color: #64748b; margin-top: 6px; font-style: italic;">
                                    Notes: <asp:Label ID="lblModalNotes" runat="server" Text="None" />
                                </div>
                            </div>
                        </div>

                        <!-- Current Loan details (Visible only if copy is Checked Out / Overdue) -->
                        <asp:Panel ID="pnlModalActiveLoan" runat="server" Visible="false" style="border: 1px solid #fee2e2; border-left: 4px solid #ef4444; border-radius: 8px; padding: 16px; background-color: #fef2f2; box-sizing: border-box;">
                            <h5 style="margin-top: 0; margin-bottom: 8px; font-size: 13.5px; font-weight: 700; color: #991b1b;"><i class="fas fa-hand-holding-bookmark"></i> Active Loan Assignment</h5>
                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 10px; font-size: 13px; color: #7f1d1d;">
                                <div>Borrower: <strong><asp:Label ID="lblModalLoanMember" runat="server" /></strong></div>
                                <div>Membership No: <strong><asp:Label ID="lblModalLoanMemberNo" runat="server" /></strong></div>
                                <div>Issue Date: <strong><asp:Label ID="lblModalLoanIssueDate" runat="server" /></strong></div>
                                <div>Due Date: <strong><asp:Label ID="lblModalLoanDueDate" runat="server" /></strong></div>
                                <div>Renewals: <strong><asp:Label ID="lblModalLoanRenewals" runat="server" /></strong></div>
                                <div>Status: <strong><asp:Label ID="lblModalLoanStatus" runat="server" /></strong></div>
                            </div>
                        </asp:Panel>

                        <!-- Tab Sub-sections (Loan History, Transfer Log, Weeding History) -->
                        <div style="display: flex; flex-direction: column; width: 100%; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden; box-sizing: border-box;">
                            
                            <!-- Sub Tab Headers (Mini toggles using JS) -->
                            <div style="display: flex; background-color: #f8fafc; border-bottom: 1px solid #e2e8f0; font-size: 12px; font-weight: 700;" id="miniTabHeaders">
                                <button type="button" class="mini-tab-btn" style="padding: 12px 16px; background: none; border: none; border-bottom: 2px solid #0f1e36; color: #0f1e36; cursor: pointer;" onclick="switchMiniTab(0)">Loan History</button>
                                <button type="button" class="mini-tab-btn" style="padding: 12px 16px; background: none; border: none; border-bottom: 2px solid transparent; color: #64748b; cursor: pointer;" onclick="switchMiniTab(1)">Transfer Log</button>
                                <button type="button" class="mini-tab-btn" style="padding: 12px 16px; background: none; border: none; border-bottom: 2px solid transparent; color: #64748b; cursor: pointer;" onclick="switchMiniTab(2)">Weeding & State Log</button>
                            </div>

                            <div style="padding: 16px; box-sizing: border-box; max-height: 200px; overflow-y: auto;">
                                <!-- Sub Tab Content 0: Loan History -->
                                <div class="mini-tab-pane" style="display: block;">
                                    <asp:GridView ID="gvModalLoanHistory" runat="server" AutoGenerateColumns="False" Width="100%" GridLines="None" CssClass="report-grid" style="font-size: 12px;">
                                        <HeaderStyle CssClass="gv-header gv-header-mini" />
                                        <RowStyle CssClass="gv-row" />
                                        <AlternatingRowStyle CssClass="gv-alt-row" />
                                        <Columns>
                                            <asp:BoundField DataField="MembershipNo" HeaderText="Member No" HeaderStyle-CssClass="gv-header-left" />
                                            <asp:BoundField DataField="MemberName" HeaderText="Name" HeaderStyle-CssClass="gv-header-left" />
                                            <asp:BoundField DataField="IssueDate" HeaderText="Issue Date" DataFormatString="{0:dd-MMM-yyyy}" />
                                            <asp:BoundField DataField="ReturnDate" HeaderText="Returned Date" DataFormatString="{0:dd-MMM-yyyy}" NullDisplayText="Pending" />
                                            <asp:BoundField DataField="StatusName" HeaderText="Status" />
                                        </Columns>
                                        <EmptyDataTemplate>
                                            <div style="padding: 12px; text-align: center; color: #64748b; font-style: italic; font-size: 12px;">No loan transactions found for this copy.</div>
                                        </EmptyDataTemplate>
                                    </asp:GridView>
                                </div>

                                <!-- Sub Tab Content 1: Transfer Log -->
                                <div class="mini-tab-pane" style="display: none;">
                                    <asp:GridView ID="gvModalLocationHistory" runat="server" AutoGenerateColumns="False" Width="100%" GridLines="None" CssClass="report-grid" style="font-size: 12px;">
                                        <HeaderStyle CssClass="gv-header gv-header-mini" />
                                        <RowStyle CssClass="gv-row" />
                                        <AlternatingRowStyle CssClass="gv-alt-row" />
                                        <Columns>
                                            <asp:BoundField DataField="UpdatedAt" HeaderText="Date" DataFormatString="{0:dd-MMM-yyyy hh:mm tt}" HeaderStyle-CssClass="gv-header-left" />
                                            <asp:BoundField DataField="OldLocation" HeaderText="Old Shelf Address" HeaderStyle-CssClass="gv-header-left" />
                                            <asp:BoundField DataField="NewLocation" HeaderText="New Shelf Address" HeaderStyle-CssClass="gv-header-left" />
                                            <asp:BoundField DataField="Remarks" HeaderText="Remarks" HeaderStyle-CssClass="gv-header-left" />
                                        </Columns>
                                        <EmptyDataTemplate>
                                            <div style="padding: 12px; text-align: center; color: #64748b; font-style: italic; font-size: 12px;">No location transfers recorded.</div>
                                        </EmptyDataTemplate>
                                    </asp:GridView>
                                </div>

                                <!-- Sub Tab Content 2: Weeding Log -->
                                <div class="mini-tab-pane" style="display: none;">
                                    <asp:GridView ID="gvModalWeedingHistory" runat="server" AutoGenerateColumns="False" Width="100%" GridLines="None" CssClass="report-grid" style="font-size: 12px;">
                                        <HeaderStyle CssClass="gv-header gv-header-mini" />
                                        <RowStyle CssClass="gv-row" />
                                        <AlternatingRowStyle CssClass="gv-alt-row" />
                                        <Columns>
                                            <asp:BoundField DataField="ActionedAt" HeaderText="Date" DataFormatString="{0:dd-MMM-yyyy hh:mm tt}" HeaderStyle-CssClass="gv-header-left" />
                                            <asp:BoundField DataField="ActionType" HeaderText="Action Type" />
                                            <asp:BoundField DataField="OldCondition" HeaderText="Old Condition" />
                                            <asp:BoundField DataField="NewCondition" HeaderText="New Condition" />
                                            <asp:BoundField DataField="Remarks" HeaderText="Remarks" HeaderStyle-CssClass="gv-header-left" />
                                        </Columns>
                                        <EmptyDataTemplate>
                                            <div style="padding: 12px; text-align: center; color: #64748b; font-style: italic; font-size: 12px;">No condition logs found.</div>
                                        </EmptyDataTemplate>
                                    </asp:GridView>
                                </div>
                            </div>

                        </div>

                    </div>

                    <!-- Modal Footer -->
                    <div style="background-color: #f8fafc; border-top: 1px solid #e2e8f0; padding: 16px 24px; display: flex; justify-content: flex-end;">
                        <asp:Button ID="btnCloseDetail" runat="server" Text="Close Window" OnClick="btnCloseDetailModal_Click" style="padding: 9px 18px; border: 1px solid #cbd5e1; border-radius: 6px; background-color: #ffffff; color: #334155; font-size: 13.5px; font-weight: 600; cursor: pointer;" />
                    </div>

                </div>
            </asp:Panel>


            <!-- MODAL 2: PHYSICAL LOCATION TRANSFER DIALOG -->
            <asp:Panel ID="pnlTransferModal" runat="server" Visible="false" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.6); display: flex; justify-content: center; align-items: center; z-index: 1000;" class="no-print">
                <div style="background-color: #ffffff; border-radius: 12px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1); width: 100%; max-width: 500px; display: flex; flex-direction: column; overflow: hidden; animation: modalSlideIn 0.3s ease-out; box-sizing: border-box;">
                    
                    <!-- Modal Header -->
                    <div style="background-color: #0f1e36; color: #ffffff; padding: 18px 24px; display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #c5a059;">
                        <h3 style="margin: 0; font-family: 'Playfair Display', serif; font-size: 17px; font-weight: 600;">Relocate Stock Copy</h3>
                        <asp:LinkButton ID="btnCloseTransferModal" runat="server" OnClick="btnCloseTransferModal_Click" style="color: #ffffff; font-size: 20px; text-decoration: none;">&times;</asp:LinkButton>
                    </div>

                    <!-- Modal Body -->
                    <div style="padding: 24px; display: flex; flex-direction: column; gap: 16px; box-sizing: border-box;">
                        
                        <div style="font-size: 13.5px; color: #475569; border-bottom: 1px solid #cbd5e1; padding-bottom: 12px; margin-bottom: 4px;">
                            Relocating Barcode Copy: <strong><asp:Label ID="lblTransferBarcode" runat="server" /></strong><br />
                            Title: <span style="font-style: italic;"><asp:Label ID="lblTransferTitle" runat="server" /></span>
                        </div>

                        <!-- Input: Hall -->
                        <div style="display: flex; flex-direction: column; gap: 5px;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Target Hall / Branch</label>
                            <asp:DropDownList ID="ddlTransferHall" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlTransferHall_SelectedIndexChanged" CssClass="form-input-stock" />
                        </div>

                        <!-- Input: Unit -->
                        <div style="display: flex; flex-direction: column; gap: 5px;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Target Shelf Unit</label>
                            <asp:DropDownList ID="ddlTransferUnit" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlTransferUnit_SelectedIndexChanged" CssClass="form-input-stock" />
                        </div>

                        <!-- Input: Rack -->
                        <div style="display: flex; flex-direction: column; gap: 5px;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Target Rack Row</label>
                            <asp:DropDownList ID="ddlTransferRack" runat="server" CssClass="form-input-stock" />
                        </div>

                        <!-- Input: Slot -->
                        <div style="display: flex; flex-direction: column; gap: 5px;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Shelf Slot Position</label>
                            <asp:TextBox ID="txtTransferSlot" runat="server" CssClass="form-input-stock" Type="Number" placeholder="Slot Index (1-100)..." />
                        </div>

                        <!-- Input: Remarks -->
                        <div style="display: flex; flex-direction: column; gap: 5px;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Reason for Transfer</label>
                            <asp:TextBox ID="txtTransferRemarks" runat="server" CssClass="form-input-stock" placeholder="Remarks for relocation log..." />
                        </div>

                    </div>

                    <!-- Modal Footer -->
                    <div style="background-color: #f8fafc; border-top: 1px solid #e2e8f0; padding: 16px 24px; display: flex; justify-content: flex-end; gap: 10px;">
                        <asp:Button ID="btnCancelTransfer" runat="server" Text="Cancel" OnClick="btnCloseTransferModal_Click" style="padding: 9px 18px; border: 1px solid #cbd5e1; border-radius: 6px; background-color: #ffffff; color: #334155; font-size: 13px; font-weight: 600; cursor: pointer;" />
                        <asp:Button ID="btnSubmitTransfer" runat="server" Text="Apply Transfer" OnClick="btnSubmitTransfer_Click" style="padding: 9px 18px; border: none; border-radius: 6px; background-color: #0f1e36; color: #ffffff; font-size: 13px; font-weight: 700; cursor: pointer;" />
                    </div>

                </div>
            </asp:Panel>


            <!-- MODAL 3: STATUS / CONDITION CHANGE DIALOG -->
            <asp:Panel ID="pnlStatusModal" runat="server" Visible="false" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.6); display: flex; justify-content: center; align-items: center; z-index: 1000;" class="no-print">
                <div style="background-color: #ffffff; border-radius: 12px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1); width: 100%; max-width: 500px; display: flex; flex-direction: column; overflow: hidden; animation: modalSlideIn 0.3s ease-out; box-sizing: border-box;">
                    
                    <!-- Modal Header -->
                    <div style="background-color: #0f1e36; color: #ffffff; padding: 18px 24px; display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #c5a059;">
                        <h3 style="margin: 0; font-family: 'Playfair Display', serif; font-size: 17px; font-weight: 600;">Update Status & Condition</h3>
                        <asp:LinkButton ID="btnCloseStatusModal" runat="server" OnClick="btnCloseStatusModal_Click" style="color: #ffffff; font-size: 20px; text-decoration: none;">&times;</asp:LinkButton>
                    </div>

                    <!-- Modal Body -->
                    <div style="padding: 24px; display: flex; flex-direction: column; gap: 16px; box-sizing: border-box;">
                        
                        <div style="font-size: 13.5px; color: #475569; border-bottom: 1px solid #cbd5e1; padding-bottom: 12px; margin-bottom: 4px;">
                            Updating State of Copy: <strong><asp:Label ID="lblStatusBarcode" runat="server" /></strong><br />
                            Title: <span style="font-style: italic;"><asp:Label ID="lblStatusTitle" runat="server" /></span>
                        </div>

                        <!-- Input: Condition drop down -->
                        <div style="display: flex; flex-direction: column; gap: 5px;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Physical Condition</label>
                            <asp:DropDownList ID="ddlStatusCondition" runat="server" CssClass="form-input-stock">
                                <asp:ListItem Value="1" Text="New" />
                                <asp:ListItem Value="2" Text="Good" />
                                <asp:ListItem Value="3" Text="Fair" />
                                <asp:ListItem Value="4" Text="Worn" />
                                <asp:ListItem Value="5" Text="Damaged (In Repair)" />
                                <asp:ListItem Value="6" Text="Lost" />
                                <asp:ListItem Value="7" Text="Weeded Out / Withdrawn" />
                                <asp:ListItem Value="8" Text="Missing" />
                                <asp:ListItem Value="9" Text="Repair / Restoration" />
                            </asp:DropDownList>
                        </div>

                        <!-- Input: Availability toggle -->
                        <div style="display: flex; align-items: center; gap: 8px; margin-top: 4px;">
                            <asp:CheckBox ID="chkStatusAvailable" runat="server" style="width: 18px; height: 18px; accent-color: #c5a059;" />
                            <span style="font-size: 13.5px; font-weight: 600; color: #1e293b;">Mark Copy as Circulating/Available</span>
                        </div>
                        <p style="margin: 0; font-size: 11.5px; color: #64748b; line-height: 1.4; padding-left: 26px;">Unavailable items are locked from being issued to members (useful for damaged, missing, or withdrawn states).</p>

                        <!-- Input: Remarks -->
                        <div style="display: flex; flex-direction: column; gap: 5px;">
                            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">Condition / Status Notes</label>
                            <asp:TextBox ID="txtStatusRemarks" runat="server" CssClass="form-input-stock" placeholder="Provide reason/details for state update..." />
                        </div>

                    </div>

                    <!-- Modal Footer -->
                    <div style="background-color: #f8fafc; border-top: 1px solid #e2e8f0; padding: 16px 24px; display: flex; justify-content: flex-end; gap: 10px;">
                        <asp:Button ID="btnCancelStatus" runat="server" Text="Cancel" OnClick="btnCloseStatusModal_Click" style="padding: 9px 18px; border: 1px solid #cbd5e1; border-radius: 6px; background-color: #ffffff; color: #334155; font-size: 13px; font-weight: 600; cursor: pointer;" />
                        <asp:Button ID="btnSubmitStatus" runat="server" Text="Save Updates" OnClick="btnSubmitStatus_Click" style="padding: 9px 18px; border: none; border-radius: 6px; background-color: #0f1e36; color: #ffffff; font-size: 13px; font-weight: 700; cursor: pointer;" />
                    </div>

                </div>
            </asp:Panel>


            <!-- MODAL 4: BARCODE LABEL PRINT DIALOG -->
            <asp:Panel ID="pnlBarcodeModal" runat="server" Visible="false" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.6); display: flex; justify-content: center; align-items: center; z-index: 1000;" class="no-print">
                <div style="background-color: #ffffff; border-radius: 12px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1); width: 100%; max-width: 450px; display: flex; flex-direction: column; overflow: hidden; animation: modalSlideIn 0.3s ease-out; box-sizing: border-box;">
                    
                    <!-- Modal Header -->
                    <div style="background-color: #0f1e36; color: #ffffff; padding: 16px 24px; display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #c5a059;">
                        <h3 style="margin: 0; font-family: 'Playfair Display', serif; font-size: 16px; font-weight: 600;">Print Barcode Label Card</h3>
                        <asp:LinkButton ID="btnCloseBarcodeModal" runat="server" OnClick="btnCloseBarcodeModal_Click" style="color: #ffffff; font-size: 20px; text-decoration: none;">&times;</asp:LinkButton>
                    </div>

                    <!-- Modal Body -->
                    <div style="padding: 30px 24px; display: flex; flex-direction: column; align-items: center; gap: 20px; box-sizing: border-box;" id="printLabelSection">
                        
                        <!-- Real Printable Label Card Structure -->
                        <div style="width: 100%; max-width: 320px; border: 2px solid #0f1e36; border-radius: 8px; padding: 16px; background-color: #ffffff; box-shadow: 0 2px 4px rgba(0,0,0,0.05); text-align: center; font-family: 'Outfit', sans-serif;" id="labelCardDiv">
                            <span style="font-weight: 800; font-size: 11px; text-transform: uppercase; color: #c5a059; letter-spacing: 1px; display: block; margin-bottom: 4px;">Lahore Gymkhana Club</span>
                            <span style="font-size: 10px; color: #64748b; font-weight: 600; text-transform: uppercase; display: block; margin-bottom: 12px; border-bottom: 1px dashed #cbd5e1; padding-bottom: 4px;">Library Management Copy</span>
                            
                            <h4 style="margin: 0 0 6px; font-size: 14px; font-weight: 700; color: #0f1e36; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; width: 100%;"><asp:Label ID="lblPrintLabelTitle" runat="server" /></h4>
                            
                            <!-- Dummy CSS Barcode Representation -->
                            <div style="margin: 12px auto; display: flex; justify-content: center; height: 55px; background: repeating-linear-gradient(90deg, #000 0px, #000 2px, #fff 2px, #fff 6px, #000 6px, #000 9px, #fff 9px, #fff 11px); width: 200px; border-left: 3px solid #000; border-right: 3px solid #000;" title="EAN Barcode Graphic"></div>
                            
                            <strong style="font-size: 15px; font-family: monospace; letter-spacing: 3px; color: #000000; display: block; margin-bottom: 10px;"><asp:Label ID="lblPrintLabelBarcode" runat="server" /></strong>
                            
                            <div style="display: flex; justify-content: space-between; font-size: 10px; color: #475569; border-top: 1px dashed #cbd5e1; padding-top: 6px; margin-top: 4px;">
                                <span>Shelf: <asp:Label ID="lblPrintLabelLocation" runat="server" /></span>
                                <span>Acc No: <asp:Label ID="lblPrintLabelAcqNo" runat="server" /></span>
                            </div>
                        </div>

                    </div>

                    <!-- Modal Footer -->
                    <div style="background-color: #f8fafc; border-top: 1px solid #e2e8f0; padding: 16px 24px; display: flex; justify-content: flex-end; gap: 10px;">
                        <button type="button" onclick="printBarcodeLabel()" style="padding: 9px 18px; border: none; border-radius: 6px; background-color: #10b981; color: #ffffff; font-size: 13px; font-weight: 700; cursor: pointer; display: flex; align-items: center; gap: 6px;">
                            <i class="fas fa-print"></i> Send to Printer
                        </button>
                        <asp:Button ID="btnCloseBarcode" runat="server" Text="Close" OnClick="btnCloseBarcodeModal_Click" style="padding: 9px 18px; border: 1px solid #cbd5e1; border-radius: 6px; background-color: #ffffff; color: #334155; font-size: 13px; font-weight: 600; cursor: pointer;" />
                    </div>

                </div>
            </asp:Panel>

            <!-- Hidden Field holding session ID of active audit -->
            <asp:HiddenField ID="hfActiveSessionID" runat="server" Value="" />

        </ContentTemplate>
    </asp:UpdatePanel>

    <!-- Page Client Side Scripts -->
    <script>
        // Primary tab switching mechanism
        function switchTab(index) {
            var btns = document.querySelectorAll('.tab-header-btn');
            for (var i = 0; i < btns.length; i++) {
                btns[i].style.color = '#64748b';
                btns[i].style.borderBottomColor = 'transparent';
                btns[i].style.backgroundColor = 'transparent';
            }
            btns[index].style.color = '#c5a059';
            btns[index].style.borderBottomColor = '#c5a059';
            btns[index].style.backgroundColor = '#ffffff';

            var panes = document.querySelectorAll('.tab-pane');
            for (var i = 0; i < panes.length; i++) {
                panes[i].style.display = 'none';
                panes[i].classList.remove('active-print');
            }
            panes[index].style.display = 'block';
            panes[index].classList.add('active-print');

            var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
            if (hf) {
                hf.value = index;
            }
        }

        // Toggle parent-child physical copies grid container
        function toggleCopiesTable(btn, id) {
            var el = document.getElementById(id);
            if (el) {
                if (el.style.display === 'none') {
                    el.style.display = 'block';
                    btn.innerHTML = '<i class="fas fa-chevron-down"></i>';
                } else {
                    el.style.display = 'none';
                    btn.innerHTML = '<i class="fas fa-chevron-right"></i>';
                }
            }
        }

        // Toggle all checkboxes in reconciliation grid
        function toggleAllReconcileCheckboxes(master) {
            var grid = document.getElementById('<%= gvReconcileMissing.ClientID %>');
            if (grid) {
                var checkboxes = grid.getElementsByTagName('input');
                for (var i = 0; i < checkboxes.length; i++) {
                    if (checkboxes[i].type == 'checkbox' && checkboxes[i] != master) {
                        checkboxes[i].checked = master.checked;
                    }
                }
            }
        }

        // Sub Tab Modal history tabs switching
        function switchMiniTab(index) {
            var btns = document.querySelectorAll('.mini-tab-btn');
            for (var i = 0; i < btns.length; i++) {
                btns[i].style.color = '#64748b';
                btns[i].style.borderBottomColor = 'transparent';
            }
            btns[index].style.color = '#0f1e36';
            btns[index].style.borderBottomColor = '#0f1e36';

            var panes = document.querySelectorAll('.mini-tab-pane');
            for (var i = 0; i < panes.length; i++) {
                panes[i].style.display = 'none';
            }
            panes[index].style.display = 'block';
        }

        // Barcode card printing helper
        function printBarcodeLabel() {
            var card = document.getElementById('labelCardDiv');
            var printWin = window.open('', '_blank', 'width=450,height=300');
            printWin.document.write('<html><head><title>Print Barcode Card</title>');
            printWin.document.write('<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;800&display=swap" rel="stylesheet">');
            printWin.document.write('<style>');
            printWin.document.write('body { font-family: "Outfit", sans-serif; margin: 0; padding: 20px; display: flex; justify-content: center; align-items: center; }');
            printWin.document.write('</style></head><body>');
            printWin.document.write(card.outerHTML);
            printWin.document.write('</body></html>');
            printWin.document.close();
            printWin.focus();
            setTimeout(function() {
                printWin.print();
                printWin.close();
            }, 500);
        }

        // Restore tab layout on AJAX page load
        document.addEventListener('DOMContentLoaded', function() {
            restoreTabState();
        });

        // Handles retaining tabs after Sys.WebForms EndRequest
        var prm = Sys.WebForms.PageRequestManager.getInstance();
        prm.add_endRequest(function() {
            restoreTabState();
        });

        function restoreTabState() {
            var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
            if (hf && hf.value !== '') {
                var activeIdx = parseInt(hf.value);
                if (!isNaN(activeIdx)) {
                    switchTab(activeIdx);
                }
            }
        }
    </script>

</asp:Content>
