<%@ Page Title="Manage Member Card" Language="C#" MasterPageFile="~/MemberShipModule/siteMemberShip.master" AutoEventWireup="true" CodeFile="ManageMemberCard.aspx.cs" Inherits="ManageMemberCard" %>

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
        .card-management-container {
            width: 100%;
            margin: 1rem 0;
            padding: 2rem;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        }

        .search-section {
            background: #faf7f2;
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 2rem;
            border: 1px solid #e0d5c5;
        }

        .form-section {
            background: #fff;
            padding: 1.5rem;
            border-radius: 8px;
            border: 1px solid #e0d5c5;
        }

        .section-header {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 1.5rem;
            padding-bottom: 1rem;
            border-bottom: 2px solid #F7F3EE;
        }

        .section-icon {
            width: 40px;
            height: 40px;
            background: #faf7f2;
            color: #C9A84C;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
        }

        .section-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: #1e293b;
            margin: 0;
        }

        .grid-responsive {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 1.5rem;
        }

        .form-group {
            margin-bottom: 1.25rem;
        }

        .form-group label {
            display: block;
            font-size: 0.875rem;
            font-weight: 500;
            color: #7a7a7a;
            margin-bottom: 0.5rem;
        }

        .form-control {
            width: 100%;
            padding: 0.625rem 0.75rem;
            font-size: 0.95rem;
            border: 1px solid #e0d5c5;
            border-radius: 6px;
            transition: all 0.2s ease;
        }

        .form-control:focus {
            outline: none;
            border-color: #C9A84C;
            box-shadow: 0 0 0 3px rgba(201, 168, 76, 0.1);
        }

        .btn-primary {
            background: #C9A84C;
            color: #fff;
            padding: 0.625rem 1.5rem;
            border-radius: 6px;
            font-weight: 500;
            border: none;
            cursor: pointer;
            transition: background 0.2s ease;
        }

        .btn-primary:hover {
            background: #1d4ed8;
        }

        .btn-search {
            height: 42px;
            align-self: flex-end;
        }

        .alert {
            padding: 1rem;
            border-radius: 6px;
            margin-bottom: 1.5rem;
        }

        .alert-success {
            background: #f0fdf4;
            color: #166534;
            border: 1px solid #bbf7d0;
        }

        .alert-error {
            background: #fef2f2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }

        .member-info-badge {
            background: #F7F3EE;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            font-size: 0.875rem;
            font-weight: 600;
            color: #8B5E3C;
            margin-bottom: 1rem;
            display: inline-block;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="card-management-container">
        <div class="section-header">
            <div class="section-icon">
                <i class="fas fa-id-card"></i>
            </div>
            <div>
                <h2 class="section-title">Manage Member Card</h2>
                <p style="color: #E8D5A3; margin: 0; font-size: 0.875rem;">Issue and manage membership cards</p>
            </div>
        </div>

        <asp:UpdatePanel ID="upMain" runat="server">
            <ContentTemplate>
                <div class="search-section">
                    <div class="grid-responsive" style="align-items: end;">
                        <div class="form-group" style="margin-bottom: 0;">
                            <label>Search by Member ID / Member No:</label>
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Enter Member ID or No"></asp:TextBox>
                        </div>
                        <div class="form-group" style="margin-bottom: 0;">
                            <asp:Button ID="btnSearch" runat="server" Text="Search Member" CssClass="btn-primary btn-search" OnClick="btnSearch_Click" />
                        </div>
                    </div>
                </div>

                <asp:Panel ID="pnlCardDetails" runat="server" Visible="false">
                    <div class="member-info-badge">
                        Member: <asp:Label ID="lblMemberName" runat="server" Text=""></asp:Label> 
                        (<asp:Label ID="lblMemberNo" runat="server" Text=""></asp:Label>)
                    </div>

                    <div class="form-section">
                        <div class="grid-responsive">
                            <div class="form-group">
                                <label>Print Name:</label>
                                <asp:TextBox ID="txtPrintName" runat="server" CssClass="form-control" placeholder="Name to print on card"></asp:TextBox>
                            </div>
                        </div>

                        <div class="grid-responsive">
                            <div class="form-group">
                                <label>Card Issue Date:</label>
                                <asp:TextBox ID="txtCardIssueDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                            </div>
                            <div class="form-group">
                                <label>Card Expiry Date:</label>
                                <asp:TextBox ID="txtCardExpiryDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                            </div>
                        </div>

                        <div class="grid-responsive">
                            <div class="form-group">
                                <label>Card Status:</label>
                                <asp:DropDownList ID="ddlCardStatus" runat="server" CssClass="form-control">
                                    <asp:ListItem Value="1">Active</asp:ListItem>
                                    <asp:ListItem Value="2">Blocked</asp:ListItem>
                                    <asp:ListItem Value="3">Lost</asp:ListItem>
                                    <asp:ListItem Value="4">Replaced</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="form-group">
                                <label>RFID Label:</label>
                                <asp:TextBox ID="txtRFIDLabel" runat="server" CssClass="form-control" placeholder="Enter RFID Label"></asp:TextBox>
                            </div>
                        </div>

                        <div style="margin-top: 1.5rem; text-align: right;">
                            <asp:HiddenField ID="hdnMemberID" runat="server" Value="0" />
                            <asp:Button ID="btnSave" runat="server" Text="Save Card Details" CssClass="btn-primary" OnClick="btnSave_Click" />
                        </div>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                    <div id="divMessage" runat="server" class="alert">
                        <asp:Label ID="lblMessage" runat="server" Text=""></asp:Label>
                    </div>
                </asp:Panel>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
</asp:Content>
