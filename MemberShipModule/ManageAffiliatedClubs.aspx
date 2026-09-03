<%@ Page Title="Manage Affiliated Clubs" Language="C#" MasterPageFile="~/MemberShipModule/Site.master"
    AutoEventWireup="true" CodeFile="ManageAffiliatedClubs.aspx.cs" Inherits="ManageAffiliatedClubs" %>

<asp:Content ID="HeadStyles" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* ==========================================================================
           Manage Affiliated Clubs (MAC) Custom Stylesheets
           ========================================================================== */

        /* ── Page Layout ── */
        .mac-page {
            width: 98%;
            margin: 0 auto;
            padding: 15px 0 30px;
            animation: macFadeIn 0.4s ease;
        }
        @keyframes macFadeIn {
            from { opacity: 0; transform: translateY(5px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* ── Page Header ── */
        .mac-page-header {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 24px;
            padding-bottom: 20px;
            border-bottom: 1px solid #e0d5c5;
        }

        .mac-page-header .icon-wrap {
            width: 52px;
            height: 52px;
            background: linear-gradient(135deg, #C9A84C, #8B5E3C);
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-size: 1.4rem;
            flex-shrink: 0;
            box-shadow: 0 4px 10px rgba(201, 168, 76, 0.25);
        }

        .mac-page-header h1 {
            font-size: 1.65rem;
            font-weight: 700;
            color: #1A1A2E;
            margin: 0;
            letter-spacing: -0.02em;
        }

        .mac-page-header p {
            color: #64748b;
            margin: 4px 0 0;
            font-size: 0.9rem;
        }

        /* ── Stats strip ── */
        .mac-stats {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }
        @media (max-width: 768px) {
            .mac-stats {
                grid-template-columns: 1fr;
            }
        }

        .mac-stat-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 16px 20px;
            border: 1px solid #e0d5c5;
            display: flex;
            align-items: center;
            gap: 16px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.02);
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .mac-stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 20px rgba(139, 94, 60, 0.08);
            border-color: #C9A84C;
        }

        .mac-stat-icon {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
            flex-shrink: 0;
            transition: all 0.25s ease;
        }
        .mac-stat-card:hover .mac-stat-icon {
            transform: scale(1.08);
        }

        .mac-stat-icon.blue   { background: #f5ecd5; color: #8B5E3C; }
        .mac-stat-icon.green  { background: #dcfce7; color: #16a34a; }
        .mac-stat-icon.orange { background: #fee2e2; color: #ef4444; }

        .mac-stat-value {
            font-size: 1.45rem;
            font-weight: 700;
            color: #1A1A2E;
            line-height: 1;
        }

        .mac-stat-label {
            font-size: 0.78rem;
            color: #64748b;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-top: 5px;
        }

        /* ── Cards ── */
        .mac-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 24px 28px;
            box-shadow: 0 4px 18px rgba(139, 94, 60, 0.03);
            border: 1px solid #e0d5c5;
            border-top: 4px solid #C9A84C;
            margin-bottom: 24px;
        }

        .mac-card-title {
            font-size: 1.1rem;
            font-weight: 700;
            color: #1A1A2E;
            margin: 0 0 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            padding-bottom: 12px;
            border-bottom: 1px solid #f5ecd5;
        }

        .mac-card-title i {
            color: #C9A84C;
            font-size: 1.05rem;
        }

        /* ── Form CSS Grid Layout ── */
        .mac-form-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px 20px;
        }
        .span-1 { grid-column: span 1; }
        .span-2 { grid-column: span 2; }
        .span-3 { grid-column: span 3; }
        .span-4 { grid-column: span 4; }

        @media (max-width: 1024px) {
            .mac-form-grid { grid-template-columns: repeat(2, 1fr); }
            .span-3, .span-4 { grid-column: span 2; }
        }
        @media (max-width: 640px) {
            .mac-form-grid { grid-template-columns: 1fr; }
            .span-2, .span-3, .span-4 { grid-column: span 1; }
        }

        .mac-form-group {
            display: flex;
            flex-direction: column;
            margin-bottom: 4px;
        }

        .mac-form-group label {
            font-size: 0.72rem;
            font-weight: 600;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 6px;
        }

        .mac-form-group input,
        .mac-form-group select,
        .mac-form-group textarea {
            padding: 10px 14px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 0.92rem;
            color: #1A1A2E;
            background: #ffffff;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            font-family: inherit;
        }

        .mac-form-group input:hover,
        .mac-form-group select:hover,
        .mac-form-group textarea:hover {
            border-color: #a09080;
        }

        .mac-form-group input:focus,
        .mac-form-group select:focus,
        .mac-form-group textarea:focus {
            border-color: #C9A84C;
            outline: none;
            box-shadow: 0 0 0 3px rgba(201, 168, 76, 0.18);
        }

        .mac-form-group input[readonly],
        .mac-form-group textarea[readonly] {
            background-color: #faf7f2;
            border-color: #e0d5c5;
            cursor: not-allowed;
        }

        /* ── Form Actions Footer ── */
        .mac-form-actions {
            grid-column: span 4;
            display: flex;
            gap: 12px;
            margin-top: 12px;
            padding-top: 20px;
            border-top: 1px dashed #e0d5c5;
        }
        @media (max-width: 1024px) {
            .mac-form-actions { grid-column: span 2; }
        }
        @media (max-width: 640px) {
            .mac-form-actions {
                grid-column: span 1;
                flex-direction: column;
            }
        }

        /* ── Button Styles ── */
        .btn, input[type="submit"].btn, input[type="button"].btn, .mac-btn {
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            gap: 8px !important;
            padding: 10px 24px !important;
            border-radius: 8px !important;
            font-weight: 600 !important;
            font-size: 0.9rem !important;
            cursor: pointer !important;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1) !important;
            border: 1px solid transparent !important;
            font-family: inherit !important;
            line-height: 1.2 !important;
            white-space: nowrap !important;
            text-decoration: none !important;
            text-align: center !important;
            vertical-align: middle !important;
        }

        .btn:active, input[type="submit"].btn:active {
            transform: scale(0.98) !important;
        }

        .btn-primary, input[type="submit"].btn-primary, .mac-btn-primary {
            background: linear-gradient(135deg, #C9A84C, #8B5E3C) !important;
            color: #ffffff !important;
            box-shadow: 0 4px 10px rgba(201, 168, 76, 0.2) !important;
        }
        .btn-primary:hover, input[type="submit"].btn-primary:hover, .mac-btn-primary:hover {
            box-shadow: 0 6px 16px rgba(201, 168, 76, 0.35) !important;
            transform: translateY(-1px) !important;
            color: #ffffff !important;
            background: linear-gradient(135deg, #d4b45c, #9c6c48) !important;
        }

        .btn-secondary, input[type="submit"].btn-secondary, .mac-btn-secondary {
            background-color: #faf7f2 !important;
            color: #1A1A2E !important;
            border: 1px solid #e0d5c5 !important;
            box-shadow: none !important;
            background-image: none !important;
        }
        .btn-secondary:hover, input[type="submit"].btn-secondary:hover, .mac-btn-secondary:hover {
            background-color: #F7F3EE !important;
            border-color: #a09080 !important;
            color: #1A1A2E !important;
        }

        /* ── Grid/Table Aesthetics ── */
        .mac-grid-container {
            overflow-x: auto;
            border: 1px solid #e0d5c5;
            border-radius: 10px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.02);
        }

        .mac-grid {
            width: 100%;
            border-collapse: collapse;
        }

        .mac-grid th {
            background: #1E1B4B !important;
            color: #C9A84C !important;
            font-size: 0.78rem !important;
            font-weight: 700 !important;
            text-transform: uppercase !important;
            letter-spacing: 0.05em !important;
            padding: 14px 16px !important;
            border: none !important;
            border-bottom: 2px solid #C9A84C !important;
            text-align: left !important;
        }

        .mac-grid td {
            padding: 12px 16px !important;
            border: none !important;
            border-bottom: 1px solid #F1F5F9 !important;
            font-size: 0.88rem !important;
            color: #334155 !important;
            vertical-align: middle !important;
        }

        .mac-grid tr:hover td {
            background-color: #f1f5f9 !important;
            transition: background 0.15s ease;
        }

        .mac-grid tr:last-child td {
            border-bottom: none;
        }

        /* ── Status Badges ── */
        .badge-active {
            background: #ecfdf5 !important;
            color: #10b981 !important;
            padding: 3px 12px !important;
            border-radius: 20px !important;
            font-size: 0.75rem !important;
            font-weight: 600 !important;
            display: inline-block !important;
            border: 1px solid #a7f3d0 !important;
            line-height: 1.4 !important;
        }

        .badge-inactive {
            background: #fef2f2 !important;
            color: #ef4444 !important;
            padding: 3px 12px !important;
            border-radius: 20px !important;
            font-size: 0.75rem !important;
            font-weight: 600 !important;
            display: inline-block !important;
            border: 1px solid #fecdd3 !important;
            line-height: 1.4 !important;
        }

        /* ── Row Action Buttons & Typography (Picture-Styled Grid) ── */
        .mac-grid-edit-btn {
            display: inline-flex !important;
            align-items: center !important;
            gap: 5px !important;
            padding: 4px 10px !important;
            background-color: #fffdf5 !important;
            border: 1px solid #b59410 !important;
            color: #b59410 !important;
            font-weight: 600 !important;
            font-size: 0.8rem !important;
            border-radius: 4px !important;
            text-decoration: none !important;
            transition: all 0.2s ease !important;
            margin-right: 6px !important;
        }
        .mac-grid-edit-btn:hover {
            background-color: #fcf6db !important;
            color: #8b720b !important;
            border-color: #8b720b !important;
            transform: translateY(-1px) !important;
        }
        .mac-grid-edit-btn i {
            color: #b59410 !important;
            font-size: 0.8rem !important;
        }

        .mac-grid-deactivate-btn {
            display: inline-flex !important;
            align-items: center !important;
            gap: 5px !important;
            padding: 4px 10px !important;
            background-color: #fff5f5 !important;
            border: 1px solid #feb2b2 !important;
            color: #c53030 !important;
            font-weight: 600 !important;
            font-size: 0.8rem !important;
            border-radius: 4px !important;
            text-decoration: none !important;
            transition: all 0.2s ease !important;
            cursor: pointer !important;
            outline: none !important;
        }
        .mac-grid-deactivate-btn:hover {
            background-color: #fed7d7 !important;
            color: #9b2c2c !important;
            border-color: #9b2c2c !important;
            transform: translateY(-1px) !important;
        }
        .mac-grid-deactivate-btn i {
            color: #c53030 !important;
        }

        .mac-grid-activate-btn {
            display: inline-flex !important;
            align-items: center !important;
            gap: 5px !important;
            padding: 4px 10px !important;
            background-color: #f0fff4 !important;
            border: 1px solid #9ae6b4 !important;
            color: #22543d !important;
            font-weight: 600 !important;
            font-size: 0.8rem !important;
            border-radius: 4px !important;
            text-decoration: none !important;
            transition: all 0.2s ease !important;
            cursor: pointer !important;
            outline: none !important;
        }
        .mac-grid-activate-btn:hover {
            background-color: #c6f6d5 !important;
            color: #2f855a !important;
            border-color: #2f855a !important;
            transform: translateY(-1px) !important;
        }
        .mac-grid-activate-btn i {
            color: #22543d !important;
        }

        .mac-grid-id {
            font-weight: 700 !important;
            color: #1e3a8a !important;
            font-size: 0.9rem !important;
        }

        .mac-grid-total {
            font-weight: 700 !important;
            color: #b45309 !important;
            font-size: 0.9rem !important;
        }

        /* ── Notification Messages ── */
        .mac-msg-success {
            display: block;
            background: #ecfdf5;
            color: #065f46;
            padding: 14px 18px;
            border-radius: 8px;
            border-left: 4px solid #10b981;
            margin-bottom: 20px;
            font-weight: 600;
            font-size: 0.9rem;
            animation: macSlideDown 0.3s ease;
        }

        .mac-msg-error {
            display: block;
            background: #fef2f2;
            color: #991b1b;
            padding: 14px 18px;
            border-radius: 8px;
            border-left: 4px solid #ef4444;
            margin-bottom: 20px;
            font-weight: 600;
            font-size: 0.9rem;
            animation: macSlideDown 0.3s ease;
        }
        @keyframes macSlideDown {
            from { opacity: 0; transform: translateY(-8px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* ── Toggle Status Modal ── */
        .mac-modal-overlay {
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(26, 26, 46, 0.6);
            backdrop-filter: blur(6px);
            -webkit-backdrop-filter: blur(6px);
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
            animation: macFadeInOverlay 0.25s ease;
        }
        @keyframes macFadeInOverlay {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .mac-modal {
            background: #ffffff;
            border-radius: 16px;
            width: 460px;
            max-width: 92vw;
            box-shadow: 0 20px 50px rgba(26, 26, 46, 0.18);
            border: 1px solid #e0d5c5;
            animation: macSlideUpModal 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
            overflow: hidden;
        }
        @keyframes macSlideUpModal {
            from { opacity: 0; transform: translateY(24px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .mac-modal-header {
            padding: 28px 28px 16px;
            text-align: center;
        }

        .mac-modal-icon {
            width: 56px;
            height: 56px;
            border-radius: 16px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            margin-bottom: 12px;
            transition: all 0.3s ease;
        }
        .mac-modal-icon.deactivate { background: #ffe4e6; color: #e11d48; }
        .mac-modal-icon.activate { background: #dcfce7; color: #16a34a; }

        .mac-modal-header h3 {
            font-size: 1.2rem;
            font-weight: 750;
            color: #1A1A2E;
            margin: 0 0 6px;
        }

        .mac-modal-subtitle {
            font-size: 0.88rem;
            color: #64748b;
            margin: 0;
        }

        .mac-modal-body {
            padding: 12px 28px 24px;
        }

        .mac-modal-footer {
            padding: 16px 28px;
            background: #faf7f2;
            border-top: 1px solid #e0d5c5;
            display: flex;
            justify-content: flex-end;
            gap: 12px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="mac-page">
        <!-- Header -->
        <div class="mac-page-header">
            <div class="icon-wrap">
                <i class="fas fa-building"></i>
            </div>
            <div>
                <h1>Manage Affiliated Clubs</h1>
                <p>Register and manage details of affiliated reciprocal clubs across the system</p>
            </div>
        </div>

        <!-- Stats -->
        <asp:UpdatePanel ID="upStats" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <div class="mac-stats">
                    <div class="mac-stat-card">
                        <div class="mac-stat-icon blue"><i class="fas fa-list-ul"></i></div>
                        <div>
                            <div class="mac-stat-value"><asp:Label ID="lblTotalClubs" runat="server" Text="0" /></div>
                            <div class="mac-stat-label">Total Clubs</div>
                        </div>
                    </div>
                    <div class="mac-stat-card">
                        <div class="mac-stat-icon green"><i class="fas fa-check-circle"></i></div>
                        <div>
                            <div class="mac-stat-value"><asp:Label ID="lblActiveClubs" runat="server" Text="0" /></div>
                            <div class="mac-stat-label">Active Clubs</div>
                        </div>
                    </div>
                    <div class="mac-stat-card">
                        <div class="mac-stat-icon orange"><i class="fas fa-times-circle"></i></div>
                        <div>
                            <div class="mac-stat-value"><asp:Label ID="lblDeactiveClubs" runat="server" Text="0" /></div>
                            <div class="mac-stat-label">Deactive Clubs</div>
                        </div>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>

        <!-- Message Label -->
        <asp:UpdatePanel ID="upMsg" runat="server">
            <ContentTemplate>
                <asp:Label ID="lblMsg" runat="server" Visible="false" />
            </ContentTemplate>
        </asp:UpdatePanel>

        <!-- Form Card -->
        <asp:UpdatePanel ID="upForm" runat="server">
            <ContentTemplate>
                <div class="mac-card">
                    <div class="mac-card-title"><i class="fas fa-plus-circle"></i> Club Information</div>
                    <asp:HiddenField ID="hfClubId" runat="server" Value="0" />
                    
                    <div class="mac-form-grid">
                        <div class="mac-form-group span-1">
                            <label>Club ID <span style="color:#ef4444">*</span></label>
                            <asp:TextBox ID="txtClubID" runat="server" placeholder="e.g. AC-001" />
                        </div>
                        
                        <div class="mac-form-group span-2">
                            <label>Club Name <span style="color:#ef4444">*</span></label>
                            <asp:TextBox ID="txtClubName" runat="server" placeholder="Enter affiliated club name" />
                        </div>
                        
                        <div class="mac-form-group span-1">
                            <label>Phone</label>
                            <asp:TextBox ID="txtPhone" runat="server" placeholder="Primary phone number" />
                        </div>
                        
                        <div class="mac-form-group span-1">
                            <label>Whatsapp No</label>
                            <asp:TextBox ID="txtWhatsapp" runat="server" placeholder="Whatsapp contact number" />
                        </div>
                        
                        <div class="mac-form-group span-1">
                            <label>Reception Phone</label>
                            <asp:TextBox ID="txtReceptionPhone" runat="server" placeholder="Reception contact" />
                        </div>
                        
                        <div class="mac-form-group span-2">
                            <label>Email Address</label>
                            <asp:TextBox ID="txtEmail" runat="server" placeholder="clubname@example.com" />
                        </div>
                        
                        <div class="mac-form-group span-1">
                            <label>Max Stay Days / Month</label>
                            <asp:TextBox ID="txtMaxDays" runat="server" TextMode="Number" placeholder="Default 15" Text="15" />
                        </div>
                        
                        <div class="mac-form-group span-1">
                            <label>Max Transactions / Month</label>
                            <asp:TextBox ID="txtMaxTx" runat="server" TextMode="Number" placeholder="Default 15" Text="15" />
                        </div>
                        
                        <div class="mac-form-group span-1">
                            <label>Max Visits / Year</label>
                            <asp:TextBox ID="txtMaxVisits" runat="server" TextMode="Number" placeholder="Default 3" Text="3" />
                        </div>

                        <div class="mac-form-group span-1">
                            <!-- Empty spacer space for clean layout grid alignment on wide screens -->
                        </div>
                        
                        <div class="mac-form-group span-4">
                            <label>Club Address</label>
                            <asp:TextBox ID="txtClubAddress" runat="server" TextMode="MultiLine" Rows="2" placeholder="Enter complete physical address..." />
                        </div>
                        
                        <div class="mac-form-actions">
                            <asp:Button ID="btnSave" runat="server" Text="Save Club" CssClass="btn btn-primary mac-btn mac-btn-primary"
                                OnClick="btnSave_Click" 
                                style="display: inline-flex; align-items: center; justify-content: center; gap: 8px; padding: 10px 24px; border-radius: 8px; font-weight: 600; font-size: 0.9rem; cursor: pointer; transition: all 0.2s; border: none; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 10px rgba(201, 168, 76, 0.2);" />
                            <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-secondary mac-btn mac-btn-secondary"
                                OnClick="btnClear_Click" 
                                style="display: inline-flex; align-items: center; justify-content: center; gap: 8px; padding: 10px 24px; border-radius: 8px; font-weight: 600; font-size: 0.9rem; cursor: pointer; transition: all 0.2s; border: 1px solid #e0d5c5; background: #faf7f2; color: #1A1A2E;" />
                        </div>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>

        <!-- Grid Card -->
        <asp:UpdatePanel ID="upGrid" runat="server">
            <ContentTemplate>
                <div class="mac-card">
                    <div class="mac-card-title"><i class="fas fa-list"></i> Affiliated Clubs Registry</div>
                    <div class="mac-grid-container">
                        <asp:GridView ID="gvClubs" runat="server" AutoGenerateColumns="false" CssClass="mac-grid"
                            DataKeyNames="Id" OnRowCommand="gvClubs_RowCommand" EmptyDataText="No affiliated reciprocal clubs found in the registry."
                            GridLines="None" CellSpacing="0" BorderWidth="0px" BorderStyle="None">
                            <HeaderStyle BackColor="#1E1B4B" ForeColor="#C9A84C" Font-Bold="True" Height="44px" HorizontalAlign="Left" />
                            <RowStyle BackColor="White" ForeColor="#334155" Height="48px" />
                            <AlternatingRowStyle BackColor="#F8FAFC" ForeColor="#334155" Height="48px" />
                            <Columns>
                                <asp:TemplateField HeaderText="Actions" ItemStyle-Width="180px">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditItem"
                                            CommandArgument='<%# Eval("Id") %>' CssClass="mac-grid-edit-btn" ToolTip="Edit Club Details"
                                            style="display: inline-flex; align-items: center; justify-content: center; gap: 5px; padding: 4px 10px; background-color: #fffdf5; border: 1px solid #b59410; color: #b59410; font-weight: 600; font-size: 0.8rem; border-radius: 4px; text-decoration: none; transition: all 0.2s ease; margin-right: 6px; cursor: pointer;">
                                            <i class="far fa-edit" style="color: #b59410; font-size: 0.8rem;"></i> Edit
                                        </asp:LinkButton>
                                        <button type="button"
                                            class='<%# Convert.ToInt32(Eval("Status")) == 1 ? "mac-grid-deactivate-btn" : "mac-grid-activate-btn" %>'
                                            onclick='openToggleModal("AffiliatedClubs", <%# Eval("Id") %>, "<%# Eval("ClubName") %>", <%# Eval("Status") %>)'
                                            style='<%# Convert.ToInt32(Eval("Status")) == 1 ? "display: inline-flex; align-items: center; justify-content: center; gap: 5px; padding: 4px 10px; background-color: #fff5f5; border: 1px solid #feb2b2; color: #c53030; font-weight: 600; font-size: 0.8rem; border-radius: 4px; text-decoration: none; transition: all 0.2s ease; cursor: pointer; outline: none;" : "display: inline-flex; align-items: center; justify-content: center; gap: 5px; padding: 4px 10px; background-color: #f0fff4; border: 1px solid #9ae6b4; color: #22543d; font-weight: 600; font-size: 0.8rem; border-radius: 4px; text-decoration: none; transition: all 0.2s ease; cursor: pointer; outline: none;" %>'>
                                            <i class='<%# Convert.ToInt32(Eval("Status")) == 1 ? "fas fa-ban" : "fas fa-check" %>' style='<%# Convert.ToInt32(Eval("Status")) == 1 ? "color: #c53030; font-size: 0.8rem;" : "color: #22543d; font-size: 0.8rem;" %>'></i>
                                            <%# Convert.ToInt32(Eval("Status")) == 1 ? "Deactivate" : "Activate" %>
                                        </button>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="ClubID" HeaderText="Club ID" ItemStyle-Width="100px" ItemStyle-CssClass="mac-grid-id" ItemStyle-Font-Bold="True" ItemStyle-ForeColor="#1e3a8a" ItemStyle-Font-Size="14px" />
                                <asp:BoundField DataField="ClubName" HeaderText="Club Name" />
                                <asp:BoundField DataField="Phone" HeaderText="Phone" />
                                <asp:BoundField DataField="Whatsapp" HeaderText="Whatsapp" />
                                <asp:BoundField DataField="Email" HeaderText="Email" />
                                <asp:BoundField DataField="MaxDaysPerMonth" HeaderText="Max Days/M" ItemStyle-Width="85px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                <asp:BoundField DataField="MaxTransactionsPerMonth" HeaderText="Max Tx/M" ItemStyle-Width="85px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                <asp:BoundField DataField="MaxVisitsPerYear" HeaderText="Max Visits/Y" ItemStyle-Width="85px" ItemStyle-CssClass="mac-grid-total" ItemStyle-Font-Bold="True" ItemStyle-ForeColor="#b45309" ItemStyle-Font-Size="14px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                <asp:TemplateField HeaderText="Status" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <span class='<%# Convert.ToInt32(Eval("Status")) == 1 ? "badge-active" : "badge-inactive" %>'
                                            style='<%# Convert.ToInt32(Eval("Status")) == 1 ? "background: #ecfdf5; color: #10b981; padding: 3px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; display: inline-block; border: 1px solid #a7f3d0; line-height: 1.4;" : "background: #fef2f2; color: #ef4444; padding: 3px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; display: inline-block; border: 1px solid #fecdd3; line-height: 1.4;" %>'>
                                            <%# Convert.ToInt32(Eval("Status")) == 1 ? "Active" : "Deactive" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>

    <!-- ═══════════════ TOGGLE STATUS MODAL ═══════════════ -->
    <div id="toggleModal" class="mac-modal-overlay" style="display:none;">
        <div class="mac-modal">
            <div class="mac-modal-header">
                <div class="mac-modal-icon" id="modalIcon">
                    <i class="fas fa-toggle-on"></i>
                </div>
                <h3 id="modalTitle">Confirm Status Change</h3>
                <p id="modalSubtitle" class="mac-modal-subtitle"></p>
            </div>
            <div class="mac-modal-body">
                <div class="mac-form-group">
                    <label>Reason for Status Change <span style="color:#ef4444;">*</span></label>
                    <asp:TextBox ID="txtToggleReason" runat="server" TextMode="MultiLine" Rows="3"
                        placeholder="Please enter a brief explanation for this status change..." 
                        style="width:100%; padding:10px 12px; border:1px solid #d1d5db; border-radius:8px; font-size:0.92rem; resize:vertical; font-family:inherit;" />
                </div>
            </div>
            <div class="mac-modal-footer">
                <button type="button" class="btn btn-secondary mac-btn mac-btn-secondary" onclick="closeToggleModal()" 
                    style="display: inline-flex; align-items: center; justify-content: center; gap: 8px; padding: 8px 20px; border-radius: 8px; font-weight: 600; font-size: 0.9rem; cursor: pointer; transition: all 0.2s; border: 1px solid #e0d5c5; background: #faf7f2; color: #1A1A2E;">Cancel</button>
                <asp:Button ID="btnConfirmToggle" runat="server" Text="Confirm" CssClass="btn btn-primary mac-btn mac-btn-primary"
                    OnClick="btnConfirmToggle_Click" 
                    style="display: inline-flex; align-items: center; justify-content: center; gap: 8px; padding: 8px 20px; border-radius: 8px; font-weight: 600; font-size: 0.9rem; cursor: pointer; transition: all 0.2s; border: none; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 10px rgba(201, 168, 76, 0.2);" />
            </div>
        </div>
    </div>

    <asp:HiddenField ID="hfToggleTable" runat="server" />
    <asp:HiddenField ID="hfToggleId" runat="server" />
    <asp:HiddenField ID="hfToggleCurrentStatus" runat="server" />

    <script type="text/javascript">
        function openToggleModal(tableName, id, itemName, currentStatus) {
            document.getElementById('<%= hfToggleTable.ClientID %>').value = tableName;
            document.getElementById('<%= hfToggleId.ClientID %>').value = id;
            document.getElementById('<%= hfToggleCurrentStatus.ClientID %>').value = currentStatus;
            document.getElementById('<%= txtToggleReason.ClientID %>').value = '';

            var action = (currentStatus == 1) ? 'Deactivate' : 'Activate';
            var icon = document.getElementById('modalIcon');
            icon.className = 'mac-modal-icon ' + (currentStatus == 1 ? 'deactivate' : 'activate');
            icon.innerHTML = currentStatus == 1 ? '<i class="fas fa-ban"></i>' : '<i class="fas fa-check"></i>';

            document.getElementById('modalTitle').innerText = action + ' Confirmation';
            document.getElementById('modalSubtitle').innerText = 'You are about to ' + action.toLowerCase() + ' "' + itemName + '"';

            document.getElementById('toggleModal').style.display = 'flex';
        }

        function closeToggleModal() {
            document.getElementById('toggleModal').style.display = 'none';
        }

        if (typeof Sys !== 'undefined') {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                closeToggleModal();
            });
        }
    </script>
</asp:Content>
