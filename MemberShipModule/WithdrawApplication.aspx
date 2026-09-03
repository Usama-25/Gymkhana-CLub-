<%@ Page Title="Withdraw Application" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true" CodeFile="WithdrawApplication.aspx.cs" Inherits="WithdrawApplication" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" Runat="Server">
    <style>
        /* Base Page Styling */
        .page-wrapper {
            padding: 30px;
            background-color: #f4f7f6;
            min-height: calc(100vh - 72px);
            font-family: 'Inter', sans-serif;
            animation: fadeIn 0.4s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Top Header Area */
        .top-header-area {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: linear-gradient(135deg, #ffffff 0%, #faf7f2 100%);
            padding: 20px 30px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
            margin-bottom: 25px;
            border-left: 5px solid #4f46e5;
        }

        .top-header-area h1 {
            margin: 0;
            font-size: 26px;
            font-weight: 700;
            color: #1e293b;
            letter-spacing: -0.5px;
        }

        .top-header-area p {
            margin: 5px 0 0 0;
            color: #7a7a7a;
            font-size: 14px;
        }

        /* Messaging */
        .msg-container {
            margin-bottom: 25px;
            border-radius: 8px;
            padding: 15px 20px;
            font-weight: 600;
            font-size: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.02);
            animation: fadeIn 0.3s ease-out;
        }
        .msg-success {
            background-color: #ecfdf5;
            color: #065f46;
            border-left: 4px solid #10b981;
        }
        .msg-error {
            background-color: #fef2f2;
            color: #991b1b;
            border-left: 4px solid #ef4444;
        }

        /* Search Panel Layout */
        .filter-panel {
            background: #ffffff;
            border-radius: 12px;
            padding: 25px 30px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.04);
            margin-bottom: 25px;
            transition: all 0.3s ease;
            border: 1px solid #F7F3EE;
        }

        .filter-panel:hover {
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.07);
        }

        .filter-header {
            font-size: 16px;
            font-weight: 600;
            color: #1A1A2E;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
            padding-bottom: 12px;
            border-bottom: 1px solid #F7F3EE;
        }

        .filter-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 20px;
            align-items: end;
        }

        .input-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .input-group label {
            font-weight: 600;
            font-size: 13px;
            color: #8B5E3C;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .styled-input {
            padding: 12px 15px;
            border: 1.5px solid #e0d5c5;
            border-radius: 8px;
            font-size: 14px;
            color: #1e293b;
            background-color: #faf7f2;
            transition: all 0.2s ease;
            font-family: inherit;
        }

        .styled-input:focus {
            outline: none;
            border-color: #4f46e5;
            background-color: #ffffff;
            box-shadow: 0 0 0 4px rgba(79, 70, 229, 0.1);
        }

        /* Buttons Styling */
        .btn-action-group {
            display: flex;
            gap: 12px;
            margin-top: 10px;
        }

        .btn-modern {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            text-decoration: none;
        }

        .btn-primary {
            background: linear-gradient(135deg, #4f46e5 0%, #4338ca 100%);
            color: #ffffff;
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.25);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(79, 70, 229, 0.35);
        }

        .btn-primary:active {
            transform: translateY(0);
        }

        .btn-secondary {
            background: #ffffff;
            color: #8B5E3C;
            border: 1.5px solid #e0d5c5;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.02);
        }

        .btn-secondary:hover {
            background: #F7F3EE;
            color: #1e293b;
            border-color: #a09080;
        }

        .btn-danger {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
            color: white;
            padding: 8px 16px;
            font-size: 13px;
            border-radius: 6px;
            box-shadow: 0 2px 8px rgba(239, 68, 68, 0.25);
        }

        .btn-danger:hover {
            background: linear-gradient(135deg, #dc2626 0%, #b91c1c 100%);
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.35);
        }

        /* Grid Styling */
        .data-panel {
            background: #ffffff;
            border-radius: 12px;
            padding: 25px 30px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.04);
            border: 1px solid #F7F3EE;
            overflow-x: auto;
        }

        .premium-grid {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            margin-top: 10px;
        }

        .premium-grid th {
            background: #faf7f2;
            color: #8B5E3C;
            font-weight: 700;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 16px 20px;
            text-align: left;
            border-bottom: 2px solid #e0d5c5;
            white-space: nowrap;
        }

        .premium-grid th:first-child { border-top-left-radius: 8px; }
        .premium-grid th:last-child { border-top-right-radius: 8px; }

        .premium-grid td {
            padding: 16px 20px;
            color: #1A1A2E;
            font-size: 14px;
            font-weight: 500;
            border-bottom: 1px solid #F7F3EE;
            vertical-align: middle;
            transition: background 0.2s ease;
        }

        .premium-grid tr:hover td {
            background-color: #faf7f2;
        }

        .premium-grid tr:last-child td {
            border-bottom: none;
        }

        /* Status Badges */
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            letter-spacing: 0.5px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.04);
        }

        .status-pending {
            background-color: #fef3c7;
            color: #b45309;
            border: 1px solid #fde68a;
        }

        .status-deferred {
            background-color: #fee2e2;
            color: #b91c1c;
            border: 1px solid #fecaca;
        }

        .status-withdrawn {
            background-color: #e0e7ff;
            color: #4338ca;
            border: 1px solid #c7d2fe;
        }

        /* Empty Data State */
        .empty-state {
            padding: 40px;
            text-align: center;
            color: #7a7a7a;
            font-size: 15px;
            font-weight: 500;
            background: #faf7f2;
            border-radius: 8px;
            border: 1px dashed #e0d5c5;
            margin-top: 15px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" Runat="Server">
    <div class="page-wrapper">
        <!-- Header -->
        <div class="top-header-area">
            <div>
                <h1>Withdraw Application</h1>
                <p>Manage and refund pending or deferred applicant records</p>
            </div>
            <div>
                <!-- Extra top header content if needed -->
            </div>
        </div>

        <!-- Messaging -->
        <asp:Panel ID="pnlMessage" runat="server" Visible="false">
            <asp:Label ID="lblMsg" runat="server"></asp:Label>
        </asp:Panel>

        <!-- Search Filters -->
        <div class="filter-panel">
            <div class="filter-header">
                <i class="fas fa-filter" style="color: #4f46e5;"></i> Filter Applications
            </div>
            <div class="filter-grid">
                <div class="input-group">
                    <label style="font-weight: 600; font-size: 13px; color: #8B5E3C; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px; display: block;">Track ID</label>
                    <asp:TextBox ID="txtTrackID" runat="server" style="padding: 12px 15px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; color: #1e293b; background-color: #faf7f2; width: 100%; box-sizing: border-box; transition: all 0.2s ease;" placeholder="e.g. 1042"></asp:TextBox>
                </div>
                
                <div class="input-group">
                    <label style="font-weight: 600; font-size: 13px; color: #8B5E3C; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px; display: block;">Applicant Name</label>
                    <asp:TextBox ID="txtApplicantName" runat="server" style="padding: 12px 15px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; color: #1e293b; background-color: #faf7f2; width: 100%; box-sizing: border-box; transition: all 0.2s ease;" placeholder="Search by name"></asp:TextBox>
                </div>
                
                <div class="input-group">
                    <label style="font-weight: 600; font-size: 13px; color: #8B5E3C; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px; display: block;">Status</label>
                    <asp:DropDownList ID="ddlStatus" runat="server" style="padding: 12px 15px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; color: #1e293b; background-color: #faf7f2; width: 100%; box-sizing: border-box; transition: all 0.2s ease; cursor: pointer; appearance: none;">
                        <asp:ListItem Value="" Text="-- All Eligible --"></asp:ListItem>
                        <asp:ListItem Value="Pending" Text="Pending"></asp:ListItem>
                        <asp:ListItem Value="Deferred" Text="Deferred"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="btn-action-group">
                    <asp:LinkButton ID="btnSearch" runat="server" CssClass="btn-modern btn-primary" OnClick="btnSearch_Click">
                        <i class="fas fa-search"></i> Search
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnClear" runat="server" CssClass="btn-modern btn-secondary" OnClick="btnClear_Click">
                        <i class="fas fa-redo-alt"></i> Clear
                    </asp:LinkButton>
                </div>
            </div>
        </div>

        <!-- Data Grid -->
        <div class="data-panel">
            <div class="filter-header" style="margin-bottom: 10px; border: none;">
                <i class="fas fa-list-ul" style="color: #4f46e5;"></i> Search Results
            </div>
            
            <asp:GridView ID="gvApplications" runat="server" AutoGenerateColumns="False" 
                GridLines="None" DataKeyNames="TrackID"
                OnRowCommand="gvApplications_RowCommand" ShowHeaderWhenEmpty="true"
                Width="100%" CellPadding="12" CellSpacing="0"
                style="width: 100%; border-collapse: separate; border-spacing: 0; margin-top: 10px; background-color: white; font-size: 14px;">
                
                <HeaderStyle BackColor="#faf7f2" ForeColor="#8B5E3C" Font-Bold="True" Height="50px" HorizontalAlign="Left" BorderStyle="None" />
                <RowStyle BackColor="#ffffff" ForeColor="#1A1A2E" Height="60px" BorderColor="#F7F3EE" BorderStyle="Solid" BorderWidth="1px" />
                <AlternatingRowStyle BackColor="#fafafa" />
                
                <EmptyDataTemplate>
                    <div class="empty-state" style="padding: 40px; text-align: center; color: #7a7a7a; font-size: 15px; font-weight: 500; background: #faf7f2; border-radius: 8px; border: 1px dashed #e0d5c5; margin-top: 15px;">
                        <i class="fas fa-box-open" style="font-size: 32px; color: #e0d5c5; margin-bottom: 12px; display: block;"></i>
                        No pending or deferred applications found matching your criteria.
                    </div>
                </EmptyDataTemplate>
                <Columns>
                    <asp:TemplateField HeaderText="Track ID" ItemStyle-Width="100px">
                        <ItemTemplate>
                            <span style="font-weight: 700; color: #1A1A2E; padding-left: 10px;">#<%# Eval("TrackID") %></span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Applicant Name">
                        <ItemTemplate>
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div style="width: 36px; height: 36px; border-radius: 50%; background: linear-gradient(135deg, #e0e7ff 0%, #c7d2fe 100%); color: #4338ca; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px; box-shadow: 0 2px 5px rgba(0,0,0,0.05);">
                                    <%# Eval("ApplicantName").ToString().Length > 0 ? Eval("ApplicantName").ToString().Substring(0, 1).ToUpper() : "?" %>
                                </div>
                                <span style="font-weight: 500;"><%# Eval("ApplicantName") %></span>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="NIC" HeaderText="NIC / CNIC" />
                    
                    <asp:TemplateField HeaderText="Membership Type">
                        <ItemTemplate>
                            <span style="background: #faf7f2; padding: 6px 12px; border-radius: 6px; border: 1px solid #e0d5c5; font-size: 13px; font-weight: 500; color: #8B5E3C;">
                                <%# Eval("MembershipType") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="ApplyDate" HeaderText="Apply Date" />
                    
                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <span class='<%# GetStatusClass(Eval("Status")) %>' style="padding: 6px 14px; border-radius: 20px; font-size: 12px; font-weight: 700; display: inline-block; text-align: center; min-width: 80px;">
                                <%# Eval("Status") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Action" ItemStyle-Width="180px">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnWithdraw" runat="server" CommandName="WithdrawApp" CommandArgument='<%# Eval("TrackID") %>'
                                style="background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); color: white; padding: 8px 16px; font-size: 13px; border-radius: 6px; box-shadow: 0 2px 8px rgba(239, 68, 68, 0.25); text-decoration: none; display: inline-flex; align-items: center; gap: 6px; font-weight: 600;" 
                                OnClientClick="return confirm('Are you sure you want to withdraw this application? This action will mark it as Withdrawn and generate a refund letter.');">
                                <i class="fas fa-undo"></i> Withdraw & Refund
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
