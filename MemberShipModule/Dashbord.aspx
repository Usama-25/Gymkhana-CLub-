<%@ Page Title="Member Dashboard" Language="C#" MasterPageFile="~/MemberShipModule/Site.master"
    AutoEventWireup="true" CodeFile="Dashbord.aspx.cs" Inherits="Dashbord" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
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
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">


        <style>


            .dashboard-container {
                max-width: 1200px;
                margin: 0 auto;
                padding: 1.5rem;
                font-family: 'Inter', sans-serif;
                background-color: #f8fafc;
                min-height: 100vh;
            }

            /* Hero Section */
            .hero-card {
                background: linear-gradient(135deg, #0f172a, #1e293b);
                border-radius: 12px;
                padding: 2.5rem;
                color: white;
                margin-bottom: 2rem;
                display: flex;
                align-items: center;
                box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
                position: relative;
                overflow: hidden;
            }

            .hero-card::after {
                content: '';
                position: absolute;
                top: -50%;
                right: -10%;
                width: 300px;
                height: 300px;
                background: radial-gradient(circle, rgba(255, 255, 255, 0.1) 0%, transparent 70%);
                border-radius: 50%;
            }

            .profile-image-container {
                position: relative;
                margin-right: 2rem;
                flex-shrink: 0;
            }

            .profile-image {
                width: 120px;
                height: 120px;
                border-radius: 50%;
                border: 4px solid rgba(255, 255, 255, 0.2);
                object-fit: cover;
                background-color: #eee;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            }

            .hero-info {
                flex-grow: 1;
            }
            .hero-info h1 {
                font-size: 2rem;
                font-weight: 700;
                margin: 0 0 0.5rem 0;
                letter-spacing: -0.025em;
            }

            .membership-badge {
                background: #f59e0b;
                color: #fff;
                padding: 0.25rem 0.75rem;
                border-radius: 9999px;
                font-size: 0.875rem;
                font-weight: 600;
                display: inline-block;
            }

            /* Action Grid */
            .action-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                gap: 1.5rem;
                margin-bottom: 2rem;
            }

            .action-card {
                background: white;
                border-radius: 12px;
                padding: 1.5rem;
                box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);
                border: 1px solid #e2e8f0;
                transition: all 0.3s ease;
                cursor: pointer;
                display: block;
                text-decoration: none;
            }

            .action-card:hover {
                transform: translateY(-4px);
                box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
                border-color: #cbd5e1;
            }

            .card-icon {
                width: 48px;
                height: 48px;
                background: #eff6ff;
                color: #003366;
                border-radius: 10px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.25rem;
                margin-bottom: 1rem;
            }

            .card-title {
                font-size: 1.125rem;
                font-weight: 600;
                color: #003366;
            }

            .card-desc {
                font-size: 0.875rem;
                color: #475569;
                line-height: 1.5;
            }

            /* Content Sections */
            .glass-panel {
                background: white;
                border-radius: 12px;
                border: 1px solid #e2e8f0;
                box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);
                overflow: hidden;
            }

            .panel-header {
                padding: 1.25rem 1.5rem;
                border-bottom: 1px solid #e2e8f0;
                display: flex;
                align-items: center;
                justify-content: space-between;
                background: #fcfcfc;
            }

            .panel-title {
                font-size: 1.25rem;
                font-weight: 700;
                color: #003366;
            }

            /* Info List */
            .info-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 1.5rem;
                padding: 1.5rem;
            }

            .info-item {
                padding: 1rem;
                background: #f8fafc;
                border-radius: 8px;
                border: 1px solid #e2e8f0;
            }

            .info-label {
                font-size: 0.75rem;
                font-weight: 600;
                color: #475569;
                text-transform: uppercase;
                letter-spacing: 0.05em;
                margin-bottom: 0.25rem;
                display: block;
            }

            .info-value {
                font-size: 1rem;
                font-weight: 600;
                color: #003366;
                display: block;
            }

            /* table Styles */
            .modern-table-container {
                overflow-x: auto;
                padding: 0;
            }

            .modern-table {
                width: 100%;
                border-collapse: collapse;
            }

            .modern-table th {
                background: #f1f5f9;
                color: #003366;
                font-weight: 600;
                text-align: left;
                padding: 1rem 1.5rem;
                font-size: 0.875rem;
            }

            .modern-table td {
                padding: 1rem 1.5rem;
                border-bottom: 1px solid #e2e8f0;
                font-size: 0.875rem;
                color: #334155;
            }

            /* Responsive Adjustments */
            @media (max-width: 768px) {
                .dashboard-container {
                    padding: 1rem;
                }

                .hero-card {
                    flex-direction: column;
                    text-align: center;
                    padding: 2rem 1.5rem;
                }

                .hero-info h1 {
                    font-size: 1.5rem;
                }

                .action-grid {
                    grid-template-columns: 1fr;
                }

                .info-grid {
                    grid-template-columns: 1fr;
                }
            }

            /* Animation */
            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(10px);
                }

                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .animate-fade-in {
                animation: fadeIn 0.5s ease-out forwards;
            }

            /* Button Variations */
            .btn-action {
                border: none;
                padding: 0.75rem 1.5rem;
                border-radius: 8px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.2s;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 0.5rem;
                font-size: 0.875rem;
            }

            .btn-primary-custom {
                background: hsl(var(--primary));
                color: white;
            }

            .btn-primary-custom:hover {
                background: hsl(210, 100%, 20%);
                transform: scale(1.02);
            }

            .btn-ghost {
                background: transparent;
                color: hsl(var(--primary));
                border: 1px solid hsl(var(--primary));
            }

            .btn-ghost:hover {
                background: hsl(var(--primary-light));
            }

            .hidden {
                display: none;
            }
        </style>

        <div class="dashboard-container">
            <!-- Hero Section -->
            <div class="hero-card animate-fade-in">
                <div class="profile-image-container">
                    <asp:Image ID="imgPhoto" runat="server" CssClass="profile-image"
                        ImageUrl="~/MemberShipModule/assets/images/user-placeholder.png" />
                </div>
                <div class="hero-info">
                    <div class="membership-badge">
                        <i class="fas fa-crown"></i>
                        <asp:Label ID="lblMemberNo" runat="server" Text="M-0000" />
                    </div>
                    <h1>Welcome,
                        <asp:Label ID="lblName" runat="server" Text="Member Name" />
                    </h1>
                    <p class="text-white/80 opacity-90"><i class="fas fa-map-marker-alt mr-2"></i> Lahore Gymkhana Club
                        Member</p>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="action-grid">
                <div class="action-card animate-fade-in"
                    onclick="document.getElementById('<%= btnProfile.ClientID %>').click();">
                    <div class="card-icon"><i class="fas fa-user-circle"></i></div>
                    <div class="card-title" style="font-size: 1.15rem; font-weight: 700; color: #0f172a;">My Profile</div>
                    <p class="card-desc">View and update your personal information, contact details, and professional
                        profile.</p>
                    <asp:LinkButton ID="btnProfile" runat="server" OnClick="btnProfile_Click" CssClass="hidden" />
                </div>
                <div class="action-card animate-fade-in"
                    onclick="document.getElementById('<%= btnAdBilling.ClientID %>').click();">
                    <div class="card-icon"><i class="fas fa-file-invoice-dollar"></i></div>
                    <div class="card-title" style="font-size: 1.15rem; font-weight: 700; color: #0f172a;">Billing & Payments</div>
                    <p class="card-desc">Check your current balance, view recent transactions, and download billing
                        statements.</p>
                    <asp:LinkButton ID="btnAdBilling" runat="server" OnClick="btnAdBilling_Click" CssClass="hidden" />
                </div>
                <div class="action-card animate-fade-in"
                    onclick="document.getElementById('<%= btn_records.ClientID %>').click();">
                    <div class="card-icon"><i class="fas fa-history"></i></div>
                    <div class="card-title" style="font-size: 1.15rem; font-weight: 700; color: #0f172a;">Club Records</div>
                    <p class="card-desc">Access your detailed history of club activities, restaurant bills, and facility
                        usage.</p>
                    <asp:LinkButton ID="btn_records" runat="server" OnClick="btn_records_Click" CssClass="hidden" />
                </div>
            </div>

            <!-- MAIN CONTENT AREA -->
            <asp:UpdatePanel ID="upMain" runat="server">
                <ContentTemplate>

                    <!-- PROFILE PANEL -->
                    <asp:Panel ID="pnlProfile" runat="server">
                        <div class="glass-panel animate-fade-in">
                            <div class="panel-header">
                                <h3 class="panel-title"><i class="fas fa-id-card"></i> Personal Information</h3>
                                <asp:Button ID="btnEdit" runat="server" Text="Edit Profile" OnClick="btnEdit_Click"
                                    CssClass="btn-action btn-primary-custom" />
                            </div>
                            <div class="info-grid">
                                <div class="info-item">
                                    <span class="info-label">NIC Number</span>
                                    <span class="info-value">
                                        <asp:Label ID="lblNIC" runat="server" />
                                    </span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">Designation</span>
                                    <span class="info-value">
                                        <asp:Label ID="lblDesignation" runat="server" />
                                    </span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">Mobile Number</span>
                                    <span class="info-value">
                                        <asp:Label ID="lblMobile" runat="server" />
                                    </span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">Email Address</span>
                                    <span class="info-value">
                                        <asp:Label ID="lblEmail" runat="server" />
                                    </span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">Membership Type</span>
                                    <span class="info-value">
                                        <asp:Label ID="lblMemberType" runat="server" />
                                    </span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">Profession</span>
                                    <span class="info-value">
                                        <asp:Label ID="lblProfession" runat="server" Text="N/A" />
                                    </span>
                                </div>
                            </div>
                        </div>
                    </asp:Panel>

                    <!-- BILLING PANEL -->
                    <asp:Panel ID="pnlAdBilling" runat="server" Visible="false">
                        <div class="glass-panel animate-fade-in">
                            <div class="panel-header">
                                <h3 class="panel-title"><i class="fas fa-receipt"></i> Recent Billing Information</h3>
                                <asp:Button ID="btnBackToProfile" runat="server" Text="Back to Profile"
                                    OnClick="btnProfile_Click" CssClass="btn-action btn-ghost" />
                            </div>
                            <div class="modern-table-container">
                                <asp:GridView ID="gvAdBilling" runat="server" AutoGenerateColumns="false"
                                    CssClass="modern-table" GridLines="None" ShowHeaderWhenEmpty="true">
                                    <Columns>
                                        <asp:BoundField DataField="Description" HeaderText="Description"
                                            HeaderStyle-CssClass="px-6 py-3" />
                                        <asp:BoundField DataField="Dept" HeaderText="Department" />
                                        <asp:BoundField DataField="Credit" HeaderText="Amount"
                                            DataFormatString="PKR {0:N0}"
                                            ItemStyle-CssClass="font-bold text-blue-900" />
                                    </Columns>
                                    <EmptyDataTemplate>
                                        <div class="p-8 text-center text-gray-400" style="padding: 2rem; text-align: center !important;">
                                            <i class="fas fa-box-open text-4xl mb-3 block"></i>
                                            <p>No billing records found for the current period.</p>
                                        </div>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                            </div>
                        </div>
                    </asp:Panel>

                </ContentTemplate>
            </asp:UpdatePanel>

            <!-- EDIT MODAL (Customized) -->
            <asp:Panel ID="pnlEdit" runat="server" Visible="false">
                <div class="fixed inset-0 z-[100] flex items-center justify-center p-4" style="align-items: center; justify-content: center; justify-content: center !important; padding: 1rem;">
                    <div
                        class="bg-white rounded-2xl shadow-2xl w-full max-w-4xl max-h-[90vh] overflow-hidden flex flex-col animate-fade-in">
                        <div class="p-6 border-b border-slate-100 flex justify-between items-center bg-slate-50" style="padding: 1.5rem; border-bottom: 1px solid #e2e8f0; justify-content: space-between; align-items: center;">
                            <div>
                                <h3 class="text-xl font-bold text-blue-950" style="font-weight: 700;">Update Your Profile</h3>
                                <p class="text-sm text-slate-500" style="font-size: 0.875rem; line-height: 1.25rem;">Ensure your contact information is up to date.</p>
                            </div>
                            <asp:Button ID="btnCancel" runat="server" Text="&times;" OnClick="btnCancel_Click" />
                        </div>

                        <div class="p-8 overflow-y-auto" style="padding: 2rem;">
                            <div>
                                <div class="space-y-2">
                                    <label>Designation</label>
                                    <asp:TextBox ID="txtDesignation" runat="server" />
                                </div>
                                <div class="space-y-2">
                                    <label>Mobile</label>
                                    <asp:TextBox ID="txtMobile" runat="server" />
                                </div>
                                <div class="space-y-2">
                                    <label>Email
                                        Address</label>
                                    <asp:TextBox ID="txtEmail" runat="server" />
                                </div>
                                <div class="space-y-2">
                                    <label>Profession</label>
                                    <asp:TextBox ID="txtProfession" runat="server" />
                                </div>
                            </div>
                            <div>
                                <label>Change
                                    Profile Photo</label>
                                <div>
                                    <div>
                                        <img id="imgPreview" src="#" alt="Preview" />
                                        <i id="previewIcon" class="fas fa-camera"></i>
                                    </div>
                                    <div>
                                        <asp:FileUpload ID="fuEditPhoto" runat="server"
                                            onchange="previewProfileImage(this);" />
                                        <p>PNG, JPG or
                                            GIF. Max size 2MB.</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="p-6 border-t border-slate-100 bg-slate-50 flex justify-end gap-3" style="padding: 1.5rem; justify-content: flex-end; justify-content: flex-end !important;">
                            <asp:Button ID="btnCancelModal" runat="server" Text="Discard Changes"
                                OnClick="btnCancel_Click" />
                            <asp:Button ID="btnSave" runat="server" Text="Update Profile" OnClick="btnSave_Click" />
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <!-- RECORDS MODAL (Customized) -->
            <div id="recordsModal"
                class="fixed inset-0 z-[110] flex items-center justify-center p-4" style="align-items: center; justify-content: center; justify-content: center !important; padding: 1rem;">
                <div
                    class="bg-white rounded-2xl shadow-2xl w-full max-w-6xl max-h-[90vh] flex flex-col overflow-hidden animate-fade-in">
                    <div class="p-6 bg-blue-950 text-white flex justify-between items-center" style="padding: 1.5rem; justify-content: space-between;">
                        <div>
                            <h3 class="text-xl font-bold" style="font-weight: 700;">Detailed Activity Records</h3>
                            <p>A full history of your interactions and
                                billing items.</p>
                        </div>
                        <button type="button" onclick="document.getElementById('recordsModal').style.display='none';"
                            onmouseover="this.style.opacity=1;" onmouseout="this.style.opacity=0.6;">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    <div class="p-0 overflow-y-auto flex-grow bg-slate-50">
                        <asp:GridView ID="gvRecords" runat="server" AutoGenerateColumns="true" CssClass="modern-table"
                            GridLines="None" ShowHeaderWhenEmpty="true">
                        </asp:GridView>
                    </div>
                    <div class="p-4 bg-white border-t border-slate-100 text-right" style="padding: 1rem;">
                        <button type="button" onclick="window.print();"><i
                                class="fas fa-print"></i>Print Statement</button>
                    </div>
                </div>
            </div>

        </div>

        <script type="text/javascript">
            function previewProfileImage(input) {
                if (input.files && input.files[0]) {
                    var reader = new FileReader();
                    reader.onload = function (e) {
                        var img = document.getElementById('imgPreview');
                        var icon = document.getElementById('previewIcon');
                        if (img) {
                            img.src = e.target.result;
                            img.style.display = 'block';
                            icon.style.display = 'none';
                        }
                    };
                    reader.readAsDataURL(input.files[0]);
                }
            }
        </script>

    </asp:Content>










