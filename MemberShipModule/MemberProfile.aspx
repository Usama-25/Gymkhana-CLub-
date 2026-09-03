<%@ Page Title="Member Profile" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true" CodeFile="MemberProfile.aspx.cs" Inherits="Membership.MemberProfile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <!-- jQuery & jQuery UI for Calendar Datepicker -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.13.2/themes/base/jquery-ui.min.css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.13.2/jquery-ui.min.js"></script>

    <style>
        .gv-header { background: #faf7f2; color: #7a7a7a; font-weight: 600; text-align: left; padding: 12px 16px; border-bottom: 2px solid #e0d5c5; text-transform: uppercase; font-size: 12px; letter-spacing: 0.025em; }
        .gv-row { border-bottom: 1px solid #F7F3EE; }
        .gv-cell { padding: 12px 16px; }
        .gv-cell-sm { padding: 8px 10px; }
        .gv-cell-xs { padding: 6px 8px; }
        .gv-cell-center { padding: 12px 16px; text-align: center; }
        .gv-cell-right { padding: 12px 16px; text-align: right; }
        .gv-cell-right-bold { padding: 12px 16px; text-align: right; font-weight: 600; }
        
        /* GridView standard styles */
        .modern-grid { border-collapse: collapse; border: none; }
        .modern-grid td, .modern-grid th { border: none; }

        /* Premium jQuery UI Datepicker styling override to match Inter and Blue theme */
        .ui-datepicker {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif !important;
            background: #ffffff !important;
            border: 1px solid #e0d5c5 !important;
            border-radius: 12px !important;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05) !important;
            padding: 0.75rem !important;
            width: 280px !important;
            z-index: 9999 !important;
        }
        .ui-datepicker-header {
            background: transparent !important;
            border: none !important;
            padding-bottom: 0.5rem !important;
            border-bottom: 1px solid #F7F3EE !important;
        }
        .ui-datepicker-title select {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif !important;
            font-size: 0.875rem !important;
            font-weight: 600 !important;
            color: #1A1A2E !important;
            padding: 0.25rem 0.5rem !important;
            border: 1px solid #e0d5c5 !important;
            border-radius: 6px !important;
            background-color: #ffffff !important;
            margin: 0 2px !important;
            outline: none !important;
        }
        .ui-datepicker-prev, .ui-datepicker-next {
            cursor: pointer !important;
            border-radius: 6px !important;
            border: 1px solid #e0d5c5 !important;
            background: #ffffff !important;
            top: 10px !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            width: 28px !important;
            height: 28px !important;
        }
        .ui-datepicker-prev:hover, .ui-datepicker-next:hover {
            background: #F7F3EE !important;
            border-color: #e0d5c5 !important;
        }
        .ui-datepicker-prev span, .ui-datepicker-next span {
            background-image: none !important;
            text-indent: 0 !important;
            overflow: visible !important;
            position: static !important;
            margin: 0 !important;
        }
        .ui-datepicker-prev::after {
            content: '‹';
            font-size: 1.25rem;
            font-weight: bold;
            color: #8B5E3C;
        }
        .ui-datepicker-next::after {
            content: '›';
            font-size: 1.25rem;
            font-weight: bold;
            color: #8B5E3C;
        }
        .ui-datepicker th {
            font-size: 0.75rem !important;
            font-weight: 600 !important;
            color: #7a7a7a !important;
            text-transform: uppercase !important;
            padding: 0.5rem 0 !important;
        }
        .ui-datepicker td {
            padding: 1px !important;
        }
        .ui-datepicker td a {
            display: block !important;
            text-align: center !important;
            padding: 0.5rem !important;
            border-radius: 8px !important;
            font-size: 0.875rem !important;
            font-weight: 500 !important;
            color: #1A1A2E !important;
            text-decoration: none !important;
            border: none !important;
            background: transparent !important;
            transition: all 0.15s ease !important;
        }
        .ui-datepicker td a:hover {
            background: #faf7f2 !important;
            color: #C9A84C !important;
        }
        .ui-datepicker td.ui-datepicker-current-day a {
            background: #C9A84C !important;
            color: #ffffff !important;
            font-weight: 600 !important;
        }
        .ui-datepicker td.ui-datepicker-today a {
            border: 1px solid #C9A84C !important;
            color: #C9A84C !important;
        }

        /* Modern calendar icon on the far right of date input textboxes */
        input[id$="txtMemberSince"], input[id$="txtEffectiveDate"], input[id$="txtCategoryChange"], 
        input[id$="txtLedgerStartDate"], input[id$="txtLedgerEndDate"], input[id$="txtHistoryStartDate"], input[id$="txtHistoryEndDate"] {
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2364748b' stroke-width='2'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' d='M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z' /%3E%3C/svg%3E") !important;
            background-repeat: no-repeat !important;
            background-position: right 12px center !important;
            background-size: 18px 18px !important;
            padding-right: 2.5rem !important;
            cursor: pointer !important;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">
    <div style="padding: 24px; width: 100%; max-width: 100%; margin: 0 auto; background-color: #faf7f2; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;">
        <asp:UpdatePanel ID="upMain" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                
                <!-- Page Header -->
                <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); border-left: 4px solid #C9A84C; margin-bottom: 24px; overflow: hidden;">
                    <div style="padding: 20px 24px; display: flex; justify-content: space-between; align-items: center;">
                        <div style="display: flex; align-items: center; gap: 16px;">
                            <a href="MemberSearch.aspx" style="width: 40px; height: 40px; border-radius: 50%; background: #F7F3EE; display: flex; align-items: center; justify-content: center; color: #7a7a7a; text-decoration: none; transition: background 0.2s;">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="15 18 9 12 15 6"></polyline></svg>
                            </a>
                            <div>
                                <h1 style="font-size: 22px; font-weight: 700; color: #1A1A2E; margin: 0;">Member Profile</h1>
                                <p style="font-size: 13px; color: #7a7a7a; margin: 4px 0 0 0;">Comprehensive view and management of member records</p>
                            </div>
                        </div>
                        <div style="text-align: right; display: flex; flex-direction: column; gap: 6px; align-items: flex-end;">
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <span style="font-size: 11px; color: #7a7a7a; text-transform: uppercase; font-weight: 700; letter-spacing: 0.05em;">Member No</span>
                                <asp:Label ID="lblMemberNoTop" runat="server" style="font-size: 22px; font-weight: 800; color: #C9A84C; letter-spacing: -0.01em; line-height: 1;"></asp:Label>
                            </div>
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <span style="font-size: 11px; color: #7a7a7a; text-transform: uppercase; font-weight: 700; letter-spacing: 0.05em;">Member Name</span>
                                <asp:Label ID="lblMemberNameTop" runat="server" style="font-size: 22px; font-weight: 800; color: #1A1A2E; letter-spacing: -0.01em; line-height: 1;"></asp:Label>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Tab Navigation -->
                <div style="display: flex; gap: 8px; background: #F7F3EE; padding: 6px; border-radius: 12px; border: 1px solid #e0d5c5; margin-bottom: 24px;">
                    <asp:Button ID="btnTabPersonal" runat="server" style="flex: 1; padding: 10px 16px; border-radius: 8px; font-weight: 600; font-size: 14px; cursor: pointer; border: none; transition: all 0.2s;" CssClass="btn-active" Text="Personal" OnClick="SwitchTab_Click" CommandArgument="personal" UseSubmitBehavior="false" />
                    <asp:Button ID="btnTabContact" runat="server" style="flex: 1; padding: 10px 16px; border-radius: 8px; font-weight: 600; font-size: 14px; cursor: pointer; border: none; transition: all 0.2s;" CssClass="btn-inactive" Text="Contact" OnClick="SwitchTab_Click" CommandArgument="contact" UseSubmitBehavior="false" />
                    <asp:Button ID="btnTabMembership" runat="server" style="flex: 1; padding: 10px 16px; border-radius: 8px; font-weight: 600; font-size: 14px; cursor: pointer; border: none; transition: all 0.2s;" CssClass="btn-inactive" Text="Membership" OnClick="SwitchTab_Click" CommandArgument="membership" UseSubmitBehavior="false" />
                    <asp:Button ID="btnTabFamily" runat="server" style="flex: 1; padding: 10px 16px; border-radius: 8px; font-weight: 600; font-size: 14px; cursor: pointer; border: none; transition: all 0.2s;" CssClass="btn-inactive" Text="Family" OnClick="SwitchTab_Click" CommandArgument="family" UseSubmitBehavior="false" />
                    <asp:Button ID="btnTabBilling" runat="server" style="flex: 1; padding: 10px 16px; border-radius: 8px; font-weight: 600; font-size: 14px; cursor: pointer; border: none; transition: all 0.2s;" CssClass="btn-inactive" Text="Billing" OnClick="SwitchTab_Click" CommandArgument="billing" UseSubmitBehavior="false" />
                    <asp:Button ID="btnTabHistory" runat="server" style="flex: 1; padding: 10px 16px; border-radius: 8px; font-weight: 600; font-size: 14px; cursor: pointer; border: none; transition: all 0.2s;" CssClass="btn-inactive" Text="History" OnClick="SwitchTab_Click" CommandArgument="history" UseSubmitBehavior="false" />
                </div>

                <asp:MultiView ID="mvTabs" runat="server" ActiveViewIndex="0">
                    
                    <!-- PERSONAL VIEW -->
                    <asp:View ID="vPersonal" runat="server">
                        <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); margin-bottom: 24px; overflow: hidden;">
                            <div style="padding: 24px;">
                                <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 1px solid #F7F3EE;">
                                    <div style="width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; border-radius: 8px; background: #faf7f2; color: #8B5E3C;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                                    </div>
                                    <h2 style="font-size: 18px; font-weight: 700; color: #1A1A2E; margin: 0;">Basic Identification</h2>
                                </div>
                                <div style="display: flex; flex-wrap: wrap; margin: 0 -12px;">
                                    <div style="flex: 0 0 25%; max-width: 25%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Category</label>
                                        <asp:TextBox ID="txtMemberCategory" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #7a7a7a; background-color: #faf7f2; border: 1px solid #e0d5c5; border-radius: 8px; outline: none; cursor: not-allowed;" ReadOnly="true"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 25%; max-width: 25%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Type</label>
                                        <asp:TextBox ID="txtMemberType" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #7a7a7a; background-color: #faf7f2; border: 1px solid #e0d5c5; border-radius: 8px; outline: none; cursor: not-allowed;" ReadOnly="true"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 25%; max-width: 25%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Member Number</label>
                                        <asp:TextBox ID="txtMemberNo" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #7a7a7a; background-color: #faf7f2; border: 1px solid #e0d5c5; border-radius: 8px; outline: none; cursor: not-allowed;" ReadOnly="true"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 25%; max-width: 25%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Account Status</label>
                                        <asp:TextBox ID="txtAccountStatus" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #7a7a7a; background-color: #faf7f2; border: 1px solid #e0d5c5; border-radius: 8px; outline: none; cursor: not-allowed;" ReadOnly="true"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 16.666%; max-width: 16.666%; padding: 0 12px; margin-bottom: 20px; display:none;Old NIC
">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Title</label>
                                        <asp:DropDownList ID="ddlTitle" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:DropDownList>
                                    </div>
                                    <div style="flex: 0 0 41.666%; max-width: 41.666%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Member Name</label>
                                        <asp:TextBox ID="txtMemberName" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 41.666%; max-width: 41.666%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Father / Husband Name</label>
                                        <asp:TextBox ID="txtFatherName" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 25%; max-width: 25%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Gender</label>
                                        <asp:DropDownList ID="ddlGender" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;">
                                            <asp:ListItem Value="Male">Male</asp:ListItem>
                                            <asp:ListItem Value="Female">Female</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div style="flex: 0 0 25%; max-width: 25%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Date of Birth</label>
                                        <asp:TextBox ID="txtDOB" runat="server" placeholder="DD-MM-YYYY" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #7a7a7a; background-color: #faf7f2; border: 1px solid #e0d5c5; border-radius: 8px; outline: none; cursor: not-allowed;" ReadOnly="true"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 25%; max-width: 25%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">CNIC</label>
                                        <asp:TextBox ID="txtNIC" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 25%; max-width: 25%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Member Since</label>
                                        <asp:TextBox ID="txtMemberSince" runat="server" placeholder="DD-MM-YYYY" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #7a7a7a; background-color: #faf7f2; border: 1px solid #e0d5c5; border-radius: 8px; outline: none; cursor: not-allowed;" ReadOnly="true"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 25%; max-width: 25%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Nationality</label>
                                        <asp:DropDownList ID="ddlNationality" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;">
                                            <asp:ListItem Value="PAKISTAN">PAKISTAN</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div style="flex: 0 0 25%; max-width: 25%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Marital Status</label>
                                        <asp:DropDownList ID="ddlMaritalStatus" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;">
                                            <asp:ListItem Value="">-- Select --</asp:ListItem>
                                            <asp:ListItem Value="SINGLE">SINGLE</asp:ListItem>
                                            <asp:ListItem Value="MARRIED">MARRIED</asp:ListItem>
                                            <asp:ListItem Value="DIVORCED">DIVORCED</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); margin-bottom: 24px; overflow: hidden;">
                            <div style="padding: 24px;">
                                <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 1px solid #F7F3EE;">
                                    <div style="width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; border-radius: 8px; background: #ecfdf5; color: #10b981;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
                                    </div>
                                    <h2 style="font-size: 18px; font-weight: 700; color: #1A1A2E; margin: 0;">Professional Details</h2>
                                </div>
                                <div style="display: flex; flex-wrap: wrap; margin: 0 -12px;">
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Education</label>
                                        <asp:TextBox ID="txtEducation" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Occupation</label>
                                        <asp:TextBox ID="txtOccupation" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Designation</label>
                                        <asp:TextBox ID="txtDesignation" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 50%; max-width: 50%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Company Name</label>
                                        <asp:TextBox ID="txtCompanyName" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 25%; max-width: 25%; padding: 0 12px; margin-bottom: 20px; display: none;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Monthly Income</label>
                                        <asp:TextBox ID="txtMonthlyIncome" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 25%; max-width: 25%; padding: 0 12px; margin-bottom: 20px; display: none;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Sector</label>
                                        <asp:DropDownList ID="ddlSector" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;">
                                            <asp:ListItem Value="Private">Private</asp:ListItem>
                                            <asp:ListItem Value="Public">Public</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); margin-bottom: 24px; overflow: hidden;">
                            <div style="padding: 24px;">
                                <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 1px solid #F7F3EE;">
                                    <div style="width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; border-radius: 8px; background: #fdf2f2; color: #ef4444;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h18a2 2 0 0 1 2 2z"></path><circle cx="8" cy="10" r="2"></circle><path d="M21 15l-5-5L5 21"></path></svg>
                                    </div>
                                    <h2 style="font-size: 18px; font-weight: 700; color: #1A1A2E; margin: 0;">Profile Media</h2>
                                </div>
                                <div style="display: flex; flex-wrap: wrap; margin: 0 -12px;">
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px; display:none;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Old NIC</label>
                                        <asp:TextBox ID="txtOldNIC" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Passport No</label>
                                        <asp:TextBox ID="txtPassportNo" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Religion</label>
                                        <asp:DropDownList ID="ddlReligion" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;">
                                            <asp:ListItem Value="">-- Select --</asp:ListItem>
                                            <asp:ListItem Value="ISLAM">ISLAM</asp:ListItem>
                                            <asp:ListItem Value="CHRISTIANITY">CHRISTIANITY</asp:ListItem>
                                            <asp:ListItem Value="HINDUISM">HINDUISM</asp:ListItem>
                                            <asp:ListItem Value="SIKHISM">SIKHISM</asp:ListItem>
                                            <asp:ListItem Value="PARSI">PARSI</asp:ListItem>
                                            <asp:ListItem Value="BUDDHISM">BUDDHISM</asp:ListItem>
                                            <asp:ListItem Value="OTHER">OTHER</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div style="flex: 0 0 50%; max-width: 50%; padding: 0 12px; margin-bottom: 20px;">
                                        <div style="background: #faf7f2; padding: 20px; border-radius: 12px; border: 1px dashed #e0d5c5; text-align: center;">
                                            <span style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 12px; text-transform: uppercase;">Member Photograph</span>
                                            <asp:Image ID="imgPicture" runat="server" style="width: 120px; height: 120px; border-radius: 12px; object-fit: cover; background: #e0d5c5; margin: 0 auto 16px; display: block; border: 3px solid white; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);" />
                                            <asp:FileUpload ID="fuPicture" runat="server" style="font-size: 12px; color: #7a7a7a; width: 100%;" />
                                        </div>
                                    </div>
                                    <div style="flex: 0 0 50%; max-width: 50%; padding: 0 12px; margin-bottom: 20px;">
                                        <div style="background: #faf7f2; padding: 20px; border-radius: 12px; border: 1px dashed #e0d5c5; text-align: center;">
                                            <span style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 12px; text-transform: uppercase;">Member Signature</span>
                                            <asp:Image ID="imgSignature" runat="server" style="width: 180px; height: 80px; border-radius: 8px; object-fit: contain; background: #ffffff; margin: 0 auto 16px; display: block; border: 1px solid #e0d5c5;" />
                                            <asp:FileUpload ID="fuSignature" runat="server" style="font-size: 12px; color: #7a7a7a; width: 100%;" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); margin-bottom: 24px; overflow: hidden;">
                            <div style="padding: 24px;">
                                <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 1px solid #F7F3EE;">
                                    <div style="width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; border-radius: 8px; background: #f5f3ff; color: #7c3aed;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="17 1 21 5 17 9"></polyline><path d="M3 11V9a4 4 0 0 1 4-4h14"></path><polyline points="7 23 3 19 7 15"></polyline><path d="M21 13v2a4 4 0 0 1-4 4H3"></path></svg>
                                    </div>
                                    <h2 style="font-size: 18px; font-weight: 700; color: #1A1A2E; margin: 0;">Additional Info</h2>
                                </div>
                                <div style="display: flex; flex-wrap: wrap; margin: 0 -12px;">
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Transfer From</label>
                                        <asp:TextBox ID="txtTransferFrom" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Transfer To</label>
                                        <asp:TextBox ID="txtTransferTo" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Effective Date</label>
                                        <asp:TextBox ID="txtEffectiveDate" runat="server" placeholder="DD-MM-YYYY" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Category Change Date</label>
                                        <asp:TextBox ID="txtCategoryChange" runat="server" placeholder="DD-MM-YYYY" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Transfer Fee</label>
                                        <asp:TextBox ID="txtTransferFee" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Co-Member No</label>
                                        <asp:TextBox ID="txtCoMemberNo" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #7a7a7a; background-color: #faf7f2; border: 1px solid #e0d5c5; border-radius: 8px; outline: none; cursor: not-allowed;" ReadOnly="true"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Emergency Contact</label>
                                        <asp:TextBox ID="txtEmergencyContact" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Preferred Contact</label>
                                        <asp:DropDownList ID="ddlPreferredContact" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;">
                                            <asp:ListItem Value="">-- Select --</asp:ListItem>
                                            <asp:ListItem Value="EMAIL">EMAIL</asp:ListItem>
                                            <asp:ListItem Value="SMS">SMS</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Residential Status</label>
                                        <asp:TextBox ID="txtResidentialStatus" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #7a7a7a; background-color: #faf7f2; border: 1px solid #e0d5c5; border-radius: 8px; outline: none; cursor: not-allowed;" ReadOnly="true"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 100%; max-width: 100%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Interest / Facilities</label>
                                        <asp:TextBox ID="txtInterestFacilities" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 100%; max-width: 100%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Other Memberships</label>
                                        <asp:TextBox ID="txtOtherMemberships" runat="server" TextMode="MultiLine" Rows="2" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="display:none;">
                                        <asp:TextBox ID="txtStatus" runat="server" Visible="false"></asp:TextBox>
                                        <asp:TextBox ID="txtSupplementary" runat="server" Visible="false"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </asp:View>

                    <!-- CONTACT VIEW -->
                    <asp:View ID="vContact" runat="server">
                        <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); margin-bottom: 24px; overflow: hidden;">
                            <div style="padding: 24px;">
                                <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 1px solid #F7F3EE;">
                                    <div style="width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; border-radius: 8px; background: #F7F3EE; color: #7a7a7a;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path></svg>
                                    </div>
                                    <h2 style="font-size: 18px; font-weight: 700; color: #1A1A2E; margin: 0;">Residential Address</h2>
                                </div>
                                <div style="display: flex; flex-wrap: wrap; margin: 0 -12px;">
                                    <div style="flex: 0 0 50%; max-width: 50%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Address Line 1</label>
                                        <asp:TextBox ID="txtResidentialAddress1" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 50%; max-width: 50%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Address Line 2</label>
                                        <asp:TextBox ID="txtResidentialAddress2" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">City</label>
                                        <asp:TextBox ID="txtResidentialCity" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Country</label>
                                        <asp:TextBox ID="txtResidentialCountry" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Phone 1</label>
                                        <asp:TextBox ID="txtResidentialPhone1" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Phone 2</label>
                                        <asp:TextBox ID="txtResidentialPhone2" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Mobile</label>
                                        <asp:TextBox ID="txtResidentialMobile" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Email</label>
                                        <asp:TextBox ID="txtResidentialEmail" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Fax</label>
                                        <asp:TextBox ID="txtResidentialFax" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 66.666%; max-width: 66.666%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Second Email</label>
                                        <asp:TextBox ID="txtResidentialEmail2" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                </div>

                                <div style="margin: 40px 0; border-top: 2px solid #F7F3EE; position: relative;">
                                    <div style="position: absolute; top: -14px; left: 50%; transform: translateX(-50%); background: white; padding: 0 20px; display: flex; gap: 32px;">
                                        <asp:CheckBox ID="cbCopyFromCompany" runat="server" Visible="false"  Text=" Copy from Company" AutoPostBack="true" OnCheckedChanged="cbCopyFromCompany_CheckedChanged" style="font-size: 13px; font-weight: 700; color: #C9A84C;" />
                                        <asp:CheckBox ID="cbCopyFromResidential" runat="server" Text=" Copy from Residential" AutoPostBack="true" OnCheckedChanged="cbCopyFromResidential_CheckedChanged" style="font-size: 13px; font-weight: 700; color: #C9A84C;" />
                                    </div>Sales References

                                </div>

                                <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 1px solid #F7F3EE; margin-top: 16px;">
                                    <div style="width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; border-radius: 8px; background: #F7F3EE; color: #7a7a7a;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
                                    </div>
                                    <h2 style="font-size: 18px; font-weight: 700; color: #1A1A2E; margin: 0;">Mailing Address</h2>
                                </div>
                                <div style="display: flex; flex-wrap: wrap; margin: 0 -12px;">
                                    <div style="flex: 0 0 50%; max-width: 50%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Address Line 1</label>
                                        <asp:TextBox ID="txtMailingAddress1" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 50%; max-width: 50%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Address Line 2</label>
                                        <asp:TextBox ID="txtMailingAddress2" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">City</label>
                                        <asp:TextBox ID="txtMailingCity" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Country</label>
                                        <asp:TextBox ID="txtMailingCountry" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Phone</label>
                                        <asp:TextBox ID="txtMailingPhone" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 100%; max-width: 100%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Email</label>
                                        <asp:TextBox ID="txtMailingEmail" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                </div>

                                <div style="margin: 40px 0; border-top: 2px solid #F7F3EE;"></div>
 
                                <div style="display: none; align-items: center; gap: 12px; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 1px solid #F7F3EE;">
                                    <div style="width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; border-radius: 8px; background: #F7F3EE; color: #7a7a7a;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect><line x1="8" y1="21" x2="16" y2="21"></line><line x1="12" y1="17" x2="12" y2="21"></line></svg>
                                    </div>
                                    <h2 style="font-size: 18px; font-weight: 700; color: #1A1A2E; margin: 0;">Company Address</h2>
                                </div>
                                <div style="display: none; flex-wrap: wrap; margin: 0 -12px;">
                                    <div style="flex: 0 0 50%; max-width: 50%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Address Line 1</label>
                                        <asp:TextBox ID="txtCompanyAddress1" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 50%; max-width: 50%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Address Line 2</label>
                                        <asp:TextBox ID="txtCompanyAddress2" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">City</label>
                                        <asp:TextBox ID="txtCompanyCity" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Country</label>
                                        <asp:DropDownList ID="ddlCompanyCountry" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:DropDownList>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Mobile</label>
                                        <asp:TextBox ID="txtCompanyMobile" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Phone 1</label>
                                        <asp:TextBox ID="txtCompanyPhone1" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Phone 2</label>
                                        <asp:TextBox ID="txtCompanyPhone2" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Fax</label>
                                        <asp:TextBox ID="txtCompanyFax" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 50%; max-width: 50%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Email 1</label>
                                        <asp:TextBox ID="txtCompanyEmail" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 50%; max-width: 50%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Email 2</label>
                                        <asp:TextBox ID="txtCompanyEmail2" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </asp:View>

                    <!-- MEMBERSHIP VIEW -->
                    <asp:View ID="vMembership" runat="server">
                        <div style="display: flex; flex-wrap: wrap; margin: 0 -12px;">
                            <div style="flex: 0 0 50%; max-width: 50%; padding: 0 12px; margin-bottom: 24px;">
                                <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); height: 100%; overflow: hidden;">
                                    <div style="padding: 24px;">
                                        <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 1px solid #F7F3EE;">
                                            <div style="width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; border-radius: 8px; background: #faf7f2; color: #8B5E3C;">
                                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                                            </div>
                                            <h2 style="font-size: 18px; font-weight: 700; color: #1A1A2E; margin: 0;">Financial Status</h2>
                                        </div>
                                        <div style="display: flex; flex-wrap: wrap; margin: 0 -12px;">
                                            <div style="flex: 0 0 50%; max-width: 50%; padding: 0 12px; margin-bottom: 20px;">
                                                <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Credit Limit</label>
                                                <asp:TextBox ID="txtCreditLimit" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none; font-weight: 700;"></asp:TextBox>
                                            </div>
                                            <div style="flex: 0 0 50%; max-width: 50%; padding: 0 12px; margin-bottom: 20px;">
                                                <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Remaining Balance</label>
                                                <asp:TextBox ID="txtRemainingBalance" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #dc2626; background-color: #fef2f2; border: 1px solid #fecaca; border-radius: 8px; outline: none; font-weight: 700;" ReadOnly="true"></asp:TextBox>
                                            </div>
                                            <div style="flex: 0 0 50%; max-width: 50%; padding: 0 12px; margin-bottom: 20px;">
                                                <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Ledger From</label>
                                                <asp:TextBox ID="txtLedgerStartDate" runat="server" placeholder="DD-MM-YYYY" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                            </div>
                                            <div style="flex: 0 0 50%; max-width: 50%; padding: 0 12px; margin-bottom: 20px;">
                                                <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Ledger To</label>
                                                <asp:TextBox ID="txtLedgerEndDate" runat="server" placeholder="DD-MM-YYYY" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                            </div>
                                            <div style="flex: 0 0 100%; max-width: 100%; padding: 0 12px; margin-top: 8px;">
                                                <asp:Button ID="btnViewLedger" runat="server" Text="View Member Ledger" OnClick="btnViewLedger_Click" style="width: 100%; padding: 12px; border-radius: 8px; font-weight: 600; cursor: pointer; border: none; background: #1A1A2E; color: white; transition: background 0.2s;" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div style="flex: 0 0 50%; max-width: 50%; padding: 0 12px; margin-bottom: 24px;">
                                <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); height: 100%; overflow: hidden;">
                                    <div style="padding: 24px;">
                                        <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 1px solid #F7F3EE;">
                                            <div style="width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; border-radius: 8px; background: #fdf2f2; color: #ef4444;">
                                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><line x1="20" y1="8" x2="20" y2="14"></line><line x1="23" y1="11" x2="17" y2="11"></line></svg>
                                            </div>
                                            <h2 style="font-size: 18px; font-weight: 700; color: #1A1A2E; margin: 0;">References</h2>
                                        </div>
                                        <div style="display: flex; flex-wrap: wrap; margin: 0 -12px;">
                                            <datalist id="dlProposers">
                                                <asp:Repeater ID="rptProposers" runat="server">
                                                    <ItemTemplate>
                                                        <option value='<%# Eval("MemberNo") %>'><%# Eval("MemberName") %></option>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                            </datalist>
                                            <div style="flex: 0 0 66.666%; max-width: 66.666%; padding: 0 12px; margin-bottom: 20px;">
                                                <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Proposer 1 Name</label>
                                                <asp:TextBox ID="txtProposer1" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #7a7a7a; background-color: #faf7f2; border: 1px solid #e0d5c5; border-radius: 8px; outline: none; cursor: not-allowed;" ReadOnly="true"></asp:TextBox>
                                            </div>
                                            <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                                <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Memb. No</label>
                                                <asp:TextBox ID="txtProposer1MemberNo" runat="server" list="dlProposers" AutoPostBack="true" OnTextChanged="txtProposer1MemberNo_TextChanged" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                            </div>
                                            <div style="flex: 0 0 66.666%; max-width: 66.666%; padding: 0 12px; margin-bottom: 20px;">
                                                <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Proposer 2 Name</label>
                                                <asp:TextBox ID="txtProposer2" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #7a7a7a; background-color: #faf7f2; border: 1px solid #e0d5c5; border-radius: 8px; outline: none; cursor: not-allowed;" ReadOnly="true"></asp:TextBox>
                                            </div>
                                            <div style="flex: 0 0 33.333%; max-width: 33.333%; padding: 0 12px; margin-bottom: 20px;">
                                                <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Memb. No</label>
                                                <asp:TextBox ID="txtProposer2MemberNo" runat="server" list="dlProposers" AutoPostBack="true" OnTextChanged="txtProposer2MemberNo_TextChanged" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                            </div>
                                            <div style="display:none;">
                                                <asp:TextBox ID="txtSalesOfficer" runat="server" Visible="false"></asp:TextBox>
                                                <asp:TextBox ID="txtCommission" runat="server" Visible="false"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div style="flex: 0 0 100%; max-width: 100%; padding: 0 12px; margin-bottom: 24px;">
                                <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); overflow: hidden;">
                                    <div style="padding: 24px;">
                                        <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 1px solid #F7F3EE;">
                                            <div style="display: flex; align-items: center; gap: 12px;">
                                                <div style="width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; border-radius: 8px; background: #fef3c7; color: #d97706;">
                                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="3" width="15" height="13"></rect><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"></polygon><circle cx="5.5" cy="18.5" r="2.5"></circle><circle cx="18.5" cy="18.5" r="2.5"></circle></svg>
                                                </div>
                                                <h2 style="font-size: 18px; font-weight: 700; color: #1A1A2E; margin: 0;">Vehicle Details</h2>
                                            </div>
                                        </div>
                                        <asp:UpdatePanel ID="upVehicles" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <div style="overflow-x: auto;">
                                                    <asp:GridView ID="gvVehicles" runat="server" AutoGenerateColumns="false" Width="100%" 
                                                        style="border-collapse: collapse; border: none; font-size: 14px; color: #1e293b;">
                                                        <HeaderStyle CssClass="gv-header" />
                                                        <RowStyle CssClass="gv-row" />
                                                        <Columns>
                                                            <asp:TemplateField HeaderText="Sticker No" ItemStyle-CssClass="gv-cell">
                                                                <ItemTemplate><asp:Label ID="lblStickerNo" runat="server" Text='<%# Eval("StickerNo") %>' style="padding: 4px; display: block;"></asp:Label></ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Vehicle No" ItemStyle-CssClass="gv-cell">
                                                                <ItemTemplate><asp:Label ID="lblVehicleNo" runat="server" Text='<%# Eval("VehicleNo") %>' style="padding: 4px; display: block;"></asp:Label></ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Model" ItemStyle-CssClass="gv-cell">
                                                                <ItemTemplate><asp:Label ID="lblVehicleModel" runat="server" Text='<%# Eval("Model") %>' style="padding: 4px; display: block;"></asp:Label></ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Make" ItemStyle-CssClass="gv-cell">
                                                                <ItemTemplate><asp:Label ID="lblVehicleMake" runat="server" Text='<%# Eval("Make") %>' style="padding: 4px; display: block;"></asp:Label></ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Issue Date" ItemStyle-CssClass="gv-cell">
                                                                <ItemTemplate><asp:Label ID="lblVehicleIssueDate" runat="server" Text='<%# Eval("IssueDate") %>' style="padding: 4px; display: block;"></asp:Label></ItemTemplate>
                                                            </asp:TemplateField>
                                                        </Columns>
                                                        <EmptyDataTemplate>
                                                            <div style="padding: 20px; text-align: center; color: #7a7a7a;">No vehicles linked to this member.</div>
                                                        </EmptyDataTemplate>
                                                    </asp:GridView>
                                                </div>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </div>
                                </div>
                            </div>

                            <div style="flex: 0 0 50%; max-width: 50%; padding: 0 12px; margin-bottom: 24px;">
                                <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); height: 100%; overflow: hidden;">
                                    <div style="padding: 24px;">
                                        <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 1px solid #F7F3EE;">
                                            <div style="display: flex; align-items: center; gap: 12px;">
                                                <div style="width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; border-radius: 8px; background: #F7F3EE; color: #7a7a7a;">
                                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle></svg>
                                                </div>
                                                <h2 style="font-size: 18px; font-weight: 700; color: #1A1A2E; margin: 0;">Club Memberships</h2>
                                            </div>
                                        </div>
                                        <asp:UpdatePanel ID="upClubs" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <div style="overflow-x: auto;">
                                                    <asp:GridView ID="gvClubs" runat="server" AutoGenerateColumns="false" Width="100%" 
                                                        style="border-collapse: collapse; border: none; font-size: 14px; color: #1e293b;">
                                                        <HeaderStyle CssClass="gv-header" />
                                                        <RowStyle CssClass="gv-row" />
                                                        <Columns>
                                                            <asp:TemplateField HeaderText="Club Name" ItemStyle-CssClass="gv-cell-sm">
                                                                <ItemTemplate><asp:Label ID="lblClubName" runat="server" Text='<%# Eval("ClubName") %>' style="padding: 4px; font-size: 13px;"></asp:Label></ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Memb. No" ItemStyle-CssClass="gv-cell-sm">
                                                                <ItemTemplate><asp:Label ID="lblClubMemberNo" runat="server" Text='<%# Eval("MembershipNo") %>' style="padding: 4px; font-size: 13px;"></asp:Label></ItemTemplate>
                                                            </asp:TemplateField>
                                                        </Columns>
                                                    </asp:GridView>
                                                </div>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </div>
                                </div>
                            </div>

                            <div style="flex: 0 0 50%; max-width: 50%; padding: 0 12px; margin-bottom: 24px;">
                                <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); height: 100%; overflow: hidden;">
                                    <div style="padding: 24px;">
                                        <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 1px solid #F7F3EE;">
                                            <div style="width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; border-radius: 8px; background: #F7F3EE; color: #7a7a7a;">
                                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
                                            </div>
                                            <h2 style="font-size: 18px; font-weight: 700; color: #1A1A2E; margin: 0;">Auto-Debit Setup</h2>
                                        </div>
                                        <div style="display: flex; flex-wrap: wrap; margin: 0 -12px;">
                                            <div style="flex: 0 0 100%; max-width: 100%; padding: 0 12px; margin-bottom: 20px;">
                                                <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Auto Debit Status</label>
                                                <asp:DropDownList ID="ddlAutoDebit" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;">
                                                    <asp:ListItem Value="No">Disabled</asp:ListItem>
                                                    <asp:ListItem Value="Yes">Enabled</asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                            <div style="flex: 0 0 100%; max-width: 100%; padding: 0 12px; margin-bottom: 20px;">
                                                <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Bank Name</label>
                                                <asp:TextBox ID="txtBankName" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                            </div>
                                            <div style="flex: 0 0 100%; max-width: 100%; padding: 0 12px; margin-bottom: 20px;">
                                                <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Account No</label>
                                                <asp:TextBox ID="txtBankAccountNo" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                            </div>
                                            <div style="flex: 0 0 100%; max-width: 100%; padding: 0 12px; margin-bottom: 20px;">
                                                <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Account Title</label>
                                                <asp:TextBox ID="txtBankAccountTitle" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </asp:View>

                    <!-- FAMILY VIEW -->
                    <asp:View ID="vFamily" runat="server">
                        <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); margin-bottom: 24px; overflow: hidden;">
                            <div style="padding: 24px;">
                                <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 1px solid #F7F3EE;">
                                    <div style="width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; border-radius: 8px; background: #fdf2f2; color: #ef4444;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle></svg>
                                    </div>
                                    <h2 style="font-size: 18px; font-weight: 700; color: #1A1A2E; margin: 0;">Spouse Information</h2>
                                </div>
                                <div style="display: flex; flex-wrap: wrap; margin: 0 -12px;">
                                    <div style="flex: 0 0 100%; max-width: 100%; padding: 0 12px;">
                                        <asp:UpdatePanel ID="upSpouses" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <div style="overflow-x: auto; border: 1px solid #e0d5c5; border-radius: 8px; margin-bottom: 20px;">
                                                    <asp:GridView ID="gvSpouses" runat="server" AutoGenerateColumns="false" Width="100%" 
                                                        style="border-collapse: collapse; border: none; font-size: 13px; color: #1e293b;">
                                                        <HeaderStyle CssClass="gv-header" />
                                                        <RowStyle CssClass="gv-row" />
                                                        <Columns>
                                                            <asp:TemplateField HeaderText="Mem No" ItemStyle-CssClass="gv-cell-sm">
                                                                <ItemTemplate><asp:Label ID="lblSpouseMemNoGrid" runat="server" Text='<%# Eval("MembershipNo") %>' style="padding: 4px; font-weight: 600;"></asp:Label></ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Name" ItemStyle-CssClass="gv-cell-sm">
                                                                <ItemTemplate><asp:Label ID="lblSpouseNameGrid" runat="server" Text='<%# Eval("SpouseName") %>' style="padding: 4px;"></asp:Label></ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="NIC" ItemStyle-CssClass="gv-cell-sm">
                                                                <ItemTemplate><asp:Label ID="lblSpouseCNICGrid" runat="server" Text='<%# Eval("SpouseCNIC") %>' style="padding: 4px;"></asp:Label></ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Phone" ItemStyle-CssClass="gv-cell-sm">
                                                                <ItemTemplate><asp:Label ID="lblSpousePhoneGrid" runat="server" Text='<%# Eval("SpousePhone") %>' style="padding: 4px;"></asp:Label></ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Profession" ItemStyle-CssClass="gv-cell-sm">
                                                                <ItemTemplate><asp:Label ID="lblSpouseProfessionGrid" runat="server" Text='<%# Eval("SpouseProfession") %>' style="padding: 4px;"></asp:Label></ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Education" ItemStyle-CssClass="gv-cell-sm">
                                                                <ItemTemplate><asp:Label ID="lblSpouseEducationGrid" runat="server" Text='<%# Eval("SpouseEducation") %>' style="padding: 4px;"></asp:Label></ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Status" ItemStyle-CssClass="gv-cell-sm">
                                                                <ItemTemplate>
                                                                    <asp:Label ID="lblSpouseStatusGrid" runat="server" Text='<%# Eval("RecordStatus") %>' 
                                                                        style='<%# Eval("RecordStatus").ToString() == "Active" ? "padding: 2px 8px; border-radius: 12px; background-color: #dcfce7; color: #166534; font-size: 11px; font-weight: 700;" : "padding: 2px 8px; border-radius: 12px; background-color: #fee2e2; color: #991b1b; font-size: 11px; font-weight: 700;" %>'></asp:Label>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Remarks" ItemStyle-CssClass="gv-cell-sm">
                                                                <ItemTemplate><asp:Label ID="lblSpouseRemarksGrid" runat="server" Text='<%# Eval("Remarks") %>' style="padding: 4px; font-size: 12px; color: #7a7a7a;"></asp:Label></ItemTemplate>
                                                            </asp:TemplateField>
                                                        </Columns>
                                                    </asp:GridView>
                                                </div>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </div>
                                </div>
                                <div style="margin: 32px 0; border-top: 1px solid #F7F3EE;"></div>
 
                                <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px;">
                                    <h3 style="font-size: 16px; font-weight: 700; color: #1A1A2E; margin: 0;">Children Details</h3>
                                </div>
                                <asp:UpdatePanel ID="upChildren" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <div style="overflow-x: auto; border: 1px solid #e0d5c5; border-radius: 8px;">
                                            <asp:GridView ID="gvChildren" runat="server" AutoGenerateColumns="false" Width="100%" 
                                                style="border-collapse: collapse; border: none; font-size: 13px; color: #1e293b;">
                                                <HeaderStyle CssClass="gv-header" />
                                                <RowStyle CssClass="gv-row" />
                                                <Columns>
                                                    <asp:TemplateField HeaderText="Mem No" ItemStyle-CssClass="gv-cell-sm">
                                                        <ItemTemplate><asp:Label ID="lblChildMemNo" runat="server" Text='<%# Eval("MembershipNo") %>' style="padding: 4px; font-weight: 600;"></asp:Label></ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Name" ItemStyle-CssClass="gv-cell-sm">
                                                        <ItemTemplate><asp:Label ID="lblChildName" runat="server" Text='<%# Eval("ChildName") %>' style="padding: 4px;"></asp:Label></ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Relation" ItemStyle-CssClass="gv-cell-sm">
                                                        <ItemTemplate><asp:Label ID="lblChildRelation" runat="server" Text='<%# Eval("Relationship") %>' style="padding: 4px;"></asp:Label></ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="DOB" ItemStyle-CssClass="gv-cell-sm">
                                                        <ItemTemplate><asp:Label ID="lblChildDOB" runat="server" Text='<%# Eval("DOB", "{0:dd-MM-yyyy}") %>' style="padding: 4px;"></asp:Label></ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="NIC / B-Form" ItemStyle-CssClass="gv-cell-sm">
                                                        <ItemTemplate><asp:Label ID="lblCNIC" runat="server" Text='<%# Eval("CNICNo") %>' style="padding: 4px;"></asp:Label></ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Phone" ItemStyle-CssClass="gv-cell-sm">
                                                        <ItemTemplate><asp:Label ID="lblChildPhone" runat="server" Text='<%# Eval("ChildPhone") %>' style="padding: 4px;"></asp:Label></ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Validity" ItemStyle-CssClass="gv-cell-sm">
                                                        <ItemTemplate><asp:Label ID="lblChildValidity" runat="server" Text='<%# Eval("ValidityPeriod", "{0:dd-MM-yyyy}") %>' style="padding: 4px;"></asp:Label></ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Status" ItemStyle-CssClass="gv-cell-sm">
                                                        <ItemTemplate>
                                                            <asp:Label ID="lblChildStatus" runat="server" Text='<%# Eval("RecordStatus") %>' 
                                                                style='<%# Eval("RecordStatus").ToString() == "Active" ? "padding: 2px 8px; border-radius: 12px; background-color: #dcfce7; color: #166534; font-size: 11px; font-weight: 700;" : "padding: 2px 8px; border-radius: 12px; background-color: #fee2e2; color: #991b1b; font-size: 11px; font-weight: 700;" %>'></asp:Label>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Remarks" ItemStyle-CssClass="gv-cell-sm">
                                                        <ItemTemplate><asp:Label ID="lblChildRemarks" runat="server" Text='<%# Eval("Remarks") %>' style="padding: 4px; font-size: 12px; color: #7a7a7a;"></asp:Label></ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </div>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                                <div style="margin: 32px 0; border-top: 1px solid #F7F3EE;"></div>

                                <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px;">
                                    <h3 style="font-size: 16px; font-weight: 700; color: #1A1A2E; margin: 0;">Supplementary Members</h3>
                                    <a href='<%# "SupplementaryDetails.aspx?MemberNo=" + txtMemberNo.Text %>' style="font-size: 13px; font-weight: 600; color: #C9A84C; text-decoration: none; display: flex; align-items: center; gap: 4px;">
                                        Manage
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path><polyline points="15 3 21 3 21 9"></polyline><line x1="10" y1="14" x2="21" y2="3"></line></svg>
                                    </a>
                                </div>
                                <asp:UpdatePanel ID="upSupplementary" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <div style="overflow-x: auto; border: 1px solid #e0d5c5; border-radius: 8px;">
                                            <asp:GridView ID="gvSupplementary" runat="server" AutoGenerateColumns="false" Width="100%" 
                                                style="border-collapse: collapse; border: none; font-size: 13px; color: #1e293b;">
                                                <HeaderStyle CssClass="gv-header" />
                                                <RowStyle CssClass="gv-row" />
                                                <Columns>
                                                    <asp:TemplateField HeaderText="Mem No" ItemStyle-CssClass="gv-cell-sm">
                                                        <ItemTemplate><asp:Label ID="lblSuppMemNo" runat="server" Text='<%# Eval("MembershipNo") %>' style="padding: 4px; font-weight: 600;"></asp:Label></ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Name" ItemStyle-CssClass="gv-cell-sm">
                                                        <ItemTemplate><asp:Label ID="lblSuppName" runat="server" Text='<%# Eval("SupplementaryName") %>' style="padding: 4px;"></asp:Label></ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Relation" ItemStyle-CssClass="gv-cell-sm">
                                                        <ItemTemplate><asp:Label ID="lblSuppRelation" runat="server" Text='<%# Eval("Relationship") %>' style="padding: 4px;"></asp:Label></ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Validity" ItemStyle-CssClass="gv-cell-sm">
                                                        <ItemTemplate><asp:Label ID="lblSuppValidity" runat="server" Text='<%# Eval("ValidityPeriod", "{0:dd-MM-yyyy}") %>' style="padding: 4px;"></asp:Label></ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Status" ItemStyle-CssClass="gv-cell-sm">
                                                        <ItemTemplate>
                                                            <asp:Label ID="lblSuppStatus" runat="server" Text='<%# Eval("RecordStatus") %>' 
                                                                style='<%# Eval("RecordStatus").ToString() == "Active" ? "padding: 2px 8px; border-radius: 12px; background-color: #dcfce7; color: #166534; font-size: 11px; font-weight: 700;" : "padding: 2px 8px; border-radius: 12px; background-color: #fee2e2; color: #991b1b; font-size: 11px; font-weight: 700;" %>'></asp:Label>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Remarks" ItemStyle-CssClass="gv-cell-sm">
                                                        <ItemTemplate><asp:Label ID="lblSuppRemarks" runat="server" Text='<%# Eval("Remarks") %>' style="padding: 4px; font-size: 12px; color: #7a7a7a;"></asp:Label></ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </div>
                                    </ContentTemplate>
                                </asp:UpdatePanel>                                <div style="margin: 32px 0; border-top: 1px solid #F7F3EE;"></div>
 
                                </div>
                            </div>
                        </div>
                                </div>
                            </div>
                        </div>
                    </asp:View>
 
                    <asp:View ID="vBilling" runat="server">
                        <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); margin-bottom: 24px; overflow: hidden;">
                            <div style="padding: 24px;">

                                
                                <div style="margin: 32px 0; border-top: 1px solid #F7F3EE;"></div>
 
                                <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 1px solid #F7F3EE;">
                                    <div style="width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; border-radius: 8px; background: #F7F3EE; color: #7a7a7a;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path></svg>
                                    </div>
                                    <h2 style="font-size: 18px; font-weight: 700; color: #1A1A2E; margin: 0;">Billing Preferences</h2>
                                </div>
                                <div style="display: flex; flex-wrap: wrap; margin: 0 -12px;">
                                    <div style="flex: 0 0 25%; max-width: 25%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Bill To</label>
                                        <asp:DropDownList ID="ddlBillTo" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;">
                                            <asp:ListItem Value="Member">Member</asp:ListItem>
                                            <asp:ListItem Value="Company">Company</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div style="flex: 0 0 25%; max-width: 25%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Frequency</label>
                                        <asp:DropDownList ID="ddlStatementFrequency" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;">
                                            <asp:ListItem Value="Monthly">Monthly</asp:ListItem>
                                            <asp:ListItem Value="Quarterly">Quarterly</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div style="flex: 0 0 25%; max-width: 25%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Email Statement</label>
                                        <asp:DropDownList ID="ddlEmailStatement" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;">
                                            <asp:ListItem Value="No">No</asp:ListItem>
                                            <asp:ListItem Value="Yes">Yes</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div style="flex: 0 0 25%; max-width: 25%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Print Statement</label>
                                        <asp:DropDownList ID="ddlPrintStatement" runat="server" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;">
                                            <asp:ListItem Value="Yes">Yes</asp:ListItem>
                                            <asp:ListItem Value="No">No</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div style="flex: 0 0 100%; max-width: 100%; padding: 0 12px; margin-bottom: 20px;">
                                        <label style="display: block; font-size: 13px; font-weight: 600; color: #7a7a7a; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Remarks</label>
                                        <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="2" style="width: 100%; padding: 10px 14px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none;"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </asp:View>

                    <!-- HISTORY VIEW -->
                    <asp:View ID="vHistory" runat="server">
                        <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); margin-bottom: 24px; overflow: hidden;">
                            <div style="padding: 24px;">
                                <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 1px solid #F7F3EE;">
                                    <div style="width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; border-radius: 8px; background: #F7F3EE; color: #7a7a7a;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                                    </div>
                                    <h2 style="font-size: 18px; font-weight: 700; color: #1A1A2E; margin: 0;">Audit History</h2>
                                </div>

                                <!-- Date Range Filter -->
                                <div style="display: flex; align-items: flex-end; gap: 16px; margin-bottom: 20px; padding: 16px; background: #faf7f2; border: 1px solid #e0d5c5; border-radius: 10px;">
                                    <div style="flex: 0 0 auto;">
                                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.03em;">Start Date</label>
                                        <asp:TextBox ID="txtHistoryStartDate" runat="server" placeholder="DD-MM-YYYY" style="padding: 8px 12px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none; min-width: 160px;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 auto;">
                                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.03em;">End Date</label>
                                        <asp:TextBox ID="txtHistoryEndDate" runat="server" placeholder="DD-MM-YYYY" style="padding: 8px 12px; font-size: 14px; color: #1e293b; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 8px; outline: none; min-width: 160px;"></asp:TextBox>
                                    </div>
                                    <div style="flex: 0 0 auto;">
                                        <asp:Button ID="btnSearchHistory" runat="server" Text="Search" OnClick="btnSearchHistory_Click" UseSubmitBehavior="false"
                                            style="padding: 8px 20px; border-radius: 8px; font-weight: 600; font-size: 14px; cursor: pointer; border: none; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 2px 4px rgba(201, 168, 76, 0.2);" />
                                    </div>
                                    <div style="flex: 0 0 auto;">
                                        <asp:Button ID="btnClearHistory" runat="server" Text="Show All" OnClick="btnClearHistory_Click" UseSubmitBehavior="false"
                                            style="padding: 8px 20px; border-radius: 8px; font-weight: 600; font-size: 14px; cursor: pointer; background: #ffffff; color: #7a7a7a; border: 1px solid #e0d5c5;" />
                                    </div>
                                </div>

                                <div style="overflow-x: auto; border: 1px solid #e0d5c5; border-radius: 8px;">
                                    <asp:GridView ID="gvAuditLog" runat="server" AutoGenerateColumns="false" Width="100%" 
                                        style="border-collapse: collapse; border: none; font-size: 14px; color: #1e293b;">
                                        <HeaderStyle CssClass="gv-header" />
                                        <RowStyle CssClass="gv-row" />
                                        <Columns>
                                            <asp:BoundField DataField="Timestamp" HeaderText="Date/Time" DataFormatString="{0:dd-MM-yyyy HH:mm}" ItemStyle-CssClass="gv-cell" />
                                            <asp:BoundField DataField="Action" HeaderText="Action" ItemStyle-CssClass="gv-cell" />
                                            <asp:BoundField DataField="UserName" HeaderText="User" ItemStyle-CssClass="gv-cell" />
                                            <asp:BoundField DataField="Details" HeaderText="Change Summary" ItemStyle-CssClass="gv-cell" />
                                        </Columns>
                                        <EmptyDataTemplate>
                                            <div style="padding: 24px; text-align: center; color: #a09080; font-size: 14px;">No audit records found for the selected criteria.</div>
                                        </EmptyDataTemplate>
                                    </asp:GridView>
                                </div>
                            </div>
                        </div>
                    </asp:View>

                </asp:MultiView>

                <!-- Sticky Footer -->
                <div class="sticky-footer">
                    <asp:Button ID="btnCancel" runat="server" Text="Discard Changes" OnClick="btnCancel_Click" style="padding: 0.625rem 1.25rem; border-radius: 8px; font-weight: 600; cursor: pointer; background: white; color: #7a7a7a; border: 1px solid #e0d5c5;" />
                    <asp:Button ID="btnUpdate" runat="server" Text="Update Profile" OnClick="btnUpdate_Click" Visible="false" OnClientClick="return validateRequiredFields();" style="padding: 0.625rem 1.25rem; border-radius: 8px; font-weight: 600; cursor: pointer; border: none; background: #f59e0b; color: white;" />
                    <asp:Button ID="btnSave" runat="server" Text="Save Member Data" OnClick="btnSave_Click" OnClientClick="return validateRequiredFields();" style="padding: 0.625rem 1.5rem; border-radius: 8px; font-weight: 700; cursor: pointer; border: none; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px -1px rgba(201, 168, 76, 0.2);" />
                </div>

                <!-- Ledger Overlay -->
                <div id="ledgerOverlay" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px); z-index:9999; align-items:center; justify-content:center;">
                    <div style="background:white; padding: 24px; border-radius: 16px; width: 90%; max-width: 900px; max-height: 85vh; overflow-y:auto; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);">
                        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; padding-bottom: 16px; border-bottom: 1px solid #F7F3EE;">
                            <h2 style="margin:0; font-size:20px; font-weight: 700; color: #1A1A2E;">Transaction Ledger</h2>
                            <button type="button" onclick="document.getElementById('ledgerOverlay').style.display='none'" style="border:none; background:#F7F3EE; color: #7a7a7a; width: 32px; height: 32px; border-radius: 50%; font-size:20px; cursor:pointer; display: flex; align-items: center; justify-content: center;">&times;</button>
                        </div>
                        <div style="overflow-x: auto; border: 1px solid #e0d5c5; border-radius: 8px;">
                            <asp:GridView ID="gvLedger" runat="server" AutoGenerateColumns="false" Width="100%" 
                                style="border-collapse: collapse; border: none; font-size: 14px; color: #1e293b;">
                                <HeaderStyle CssClass="gv-header" />
                                <RowStyle CssClass="gv-row" />
                                <Columns>
                                    <asp:BoundField DataField="Date" HeaderText="Date" DataFormatString="{0:dd-MM-yyyy}" ItemStyle-CssClass="gv-cell" />
                                    <asp:BoundField DataField="Description" HeaderText="Description" ItemStyle-CssClass="gv-cell" />
                                    <asp:BoundField DataField="Debit" HeaderText="Debit" ItemStyle-CssClass="gv-cell-right" />
                                    <asp:BoundField DataField="Credit" HeaderText="Credit" ItemStyle-CssClass="gv-cell-right" />
                                    <asp:BoundField DataField="Balance" HeaderText="Balance" ItemStyle-CssClass="gv-cell-right-bold" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>

            </ContentTemplate>
        </asp:UpdatePanel>

        <asp:HiddenField ID="hdnMemberID" runat="server" />
        <asp:HiddenField ID="hdnChildrenCount" runat="server" Value="0" />
        <asp:HiddenField ID="hdnVehiclesCount" runat="server" Value="0" />
        <asp:HiddenField ID="hdnSupplementaryCount" runat="server" Value="0" />
        <asp:HiddenField ID="hdnClubsCount" runat="server" Value="0" />
    </div>

    <!-- Client-Side Date Picker, Masking, and Strict Validation Logic -->
    <script type="text/javascript">
        function formatDateInput(input) {
            // Strip all non-numeric characters
            var val = input.value.replace(/\D/g, '');
            var formattedVal = '';
            
            if (val.length > 0) {
                // Limit length to 8 characters (DDMMYYYY)
                val = val.substring(0, 8);
                
                // Format the string dynamically
                if (val.length <= 2) {
                    formattedVal = val;
                } else if (val.length <= 4) {
                    formattedVal = val.substring(0, 2) + '-' + val.substring(2);
                } else {
                    formattedVal = val.substring(0, 2) + '-' + val.substring(2, 4) + '-' + val.substring(4);
                }
            }
            
            input.value = formattedVal;
        }

        function isValidDate(dateStr) {
            if (!dateStr) return true;
            
            // Format must be precisely DD-MM-YYYY
            var regex = /^(\d{2})-(\d{2})-(\d{4})$/;
            var match = dateStr.match(regex);
            if (!match) return false;
            
            var day = parseInt(match[1], 10);
            var month = parseInt(match[2], 10);
            var year = parseInt(match[3], 10);
            
            if (month < 1 || month > 12) return false;
            if (year < 1900 || year > 2100) return false; // Sensible limits
            
            var daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
            
            // Handle Leap Years for February
            if ((year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0)) {
                daysInMonth[1] = 29;
            }
            
            if (day < 1 || day > daysInMonth[month - 1]) return false;
            
            return true;
        }

        function validateDateInput(input) {
            var dateStr = input.value.trim();
            if (dateStr === '') {
                input.style.borderColor = '#e0d5c5';
                return true;
            }
            
            if (!isValidDate(dateStr)) {
                alert('Please enter a valid date in DD-MM-YYYY format (e.g., 25-03-2009).\nInvalid days (like 32) or months (like 13) are not allowed.');
                input.value = '';
                input.style.borderColor = '#ef4444';
                setTimeout(function() {
                    input.focus();
                }, 10);
                return false;
            }
            
            input.style.borderColor = '#e0d5c5';
            return true;
        }

        function initDatepickers() {
            var dateFields = [
                { id: '<%= txtMemberSince.ClientID %>', range: 'c-100:c+10', max: null },
                { id: '<%= txtEffectiveDate.ClientID %>', range: 'c-50:c+10', max: null },
                { id: '<%= txtCategoryChange.ClientID %>', range: 'c-50:c+10', max: null },
                { id: '<%= txtLedgerStartDate.ClientID %>', range: 'c-50:c+10', max: null },
                { id: '<%= txtLedgerEndDate.ClientID %>', range: 'c-50:c+10', max: null },
                { id: '<%= txtHistoryStartDate.ClientID %>', range: 'c-50:c+10', max: null },
                { id: '<%= txtHistoryEndDate.ClientID %>', range: 'c-50:c+10', max: null }
            ];

            dateFields.forEach(function(field) {
                var $el = $('#' + field.id);
                if ($el.length) {
                    var dpOptions = {
                        dateFormat: 'dd-mm-yy',
                        changeMonth: true,
                        changeYear: true,
                        yearRange: field.range
                    };
                    if (field.max !== null) {
                        dpOptions.maxDate = field.max;
                    }
                    dpOptions.onSelect = function(dateText) {
                        validateDateInput(this);
                    };

                    $el.datepicker(dpOptions);

                    // Bind dynamic input formatter on user typing
                    $el.off('input.format').on('input.format', function() {
                        formatDateInput(this);
                    });

                    // Bind change validation on blur / change
                    $el.off('change.validate').on('change.validate', function() {
                        validateDateInput(this);
                    });
                }
            });
        }

        function validateRequiredFields() {
            var errors = [];
            var dateFields = [
                { id: '<%= txtDOB.ClientID %>', label: 'Date of Birth' },
                { id: '<%= txtMemberSince.ClientID %>', label: 'Member Since' },
                { id: '<%= txtEffectiveDate.ClientID %>', label: 'Effective Date' },
                { id: '<%= txtCategoryChange.ClientID %>', label: 'Category Change Date' },
                { id: '<%= txtLedgerStartDate.ClientID %>', label: 'Ledger Start Date' },
                { id: '<%= txtLedgerEndDate.ClientID %>', label: 'Ledger End Date' },
                { id: '<%= txtHistoryStartDate.ClientID %>', label: 'Audit Start Date' },
                { id: '<%= txtHistoryEndDate.ClientID %>', label: 'Audit End Date' }
            ];

            // Reset borders
            dateFields.forEach(function(field) {
                var el = document.getElementById(field.id);
                if (el) el.style.borderColor = '#e0d5c5';
            });

            // Validate date format and validity if filled
            dateFields.forEach(function(field) {
                var el = document.getElementById(field.id);
                if (el && el.value.trim() !== '') {
                    if (!isValidDate(el.value.trim())) {
                        el.style.borderColor = '#ef4444';
                        errors.push(field.label + ' (must be a valid date in DD-MM-YYYY format)');
                    }
                }
            });

            if (errors.length > 0) {
                alert('Please fill in or correct the following fields:\n\n- ' + errors.join('\n- '));
                return false;
            }
            return true;
        }

        // Initialize
        function pageLoad() {
            initDatepickers();
        }

        // Hook for AJAX UpdatePanel postbacks
        if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            prm.add_endRequest(function () {
                initDatepickers();
            });
        }
    </script>
</asp:Content>