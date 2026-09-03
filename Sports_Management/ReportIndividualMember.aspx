<%@ Page Title="Individual Member Wise Report" Language="C#" MasterPageFile="~/Sports_Management/SiteSports.master" AutoEventWireup="true" CodeFile="ReportIndividualMember.aspx.cs" Inherits="ReportIndividualMember" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
    <style>
        .search-card {
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            border: 1px solid var(--secondary);
            display: flex;
            gap: 15px;
            align-items: flex-end;
        }
        .profile-card {
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            border: 1px solid var(--secondary);
            display: flex;
            justify-content: space-between;
        }
        .profile-info h3 { margin-bottom: 5px; color: var(--primary); }
        .profile-info p { margin-bottom: 5px; font-size: 13px; color: var(--gray-600); }
        .badge { padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: bold; }
        .badge-active { background: var(--success); color: white; }
        .badge-inactive { background: var(--danger); color: white; }

        @media print {
            .sidebar, .top-header, .search-card, .btn, .nav-section, .logo, .sidebar-header {
                display: none !important;
            }
            .app {
                display: block !important;
            }
            .main-content {
                margin: 0 !important;
                padding: 0 !important;
                width: 100% !important;
                overflow: visible !important;
            }
            .content-wrapper {
                padding: 0 !important;
                overflow: visible !important;
            }
            .card {
                border: none !important;
                box-shadow: none !important;
            }
            .card-header {
                font-size: 18px !important;
                font-weight: bold !important;
                border-bottom: 2px solid #333 !important;
                padding-bottom: 5px !important;
                margin-bottom: 15px !important;
                background: none !important;
                color: #000 !important;
            }
            .grid-view th {
                background-color: #1e3a5f !important;
                color: white !important;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }
        }

        /* Pager Styling */
        .grid-pager table {
            margin: 10px 0;
        }
        .grid-pager td {
            padding: 0 4px !important;
            border: none !important;
        }
        .grid-pager a, .grid-pager span {
            display: inline-block;
            padding: 6px 12px;
            border: 1px solid var(--gray-300);
            border-radius: 4px;
            text-decoration: none;
            font-weight: 600;
        }
        .grid-pager a {
            color: var(--primary);
            background: white;
        }
        .grid-pager a:hover {
            background: var(--primary-light);
            color: var(--primary-dark);
        }
        .grid-pager span {
            background: var(--primary);
            color: white;
            border-color: var(--primary);
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">
    <div class="page-header-card" style="display:flex; justify-content:space-between; align-items:center;">
        <h2>Individual Member Wise Report</h2>
        <asp:Button ID="btnPrint" runat="server" Text="Print / Save HTML" CssClass="btn btn-primary" style="padding: 5px 15px; font-size:12px; background:var(--info); color:white;" OnClick="btnPrint_Click" Visible="false" />
    </div>

    <div class="search-card">
        <div style="flex: 1;">
            <label style="font-weight: bold; display: block; margin-bottom: 5px;">Search Member No</label>
            <asp:TextBox ID="txtMemberNo" runat="server" CssClass="form-control" placeholder="Enter Member No"></asp:TextBox>
        </div>
        <div style="flex: 0 0 auto;">
            <asp:Button ID="btnSearch" runat="server" Text="Generate Report" CssClass="btn btn-primary" OnClick="btnSearch_Click" />
        </div>
    </div>

    <asp:Label ID="lblMessage" runat="server" Visible="false" Style="display:block; padding:10px; margin-bottom:15px; border-radius:5px;"></asp:Label>

    <asp:Panel ID="pnlReport" runat="server" Visible="false">
        <div class="profile-card">
            <div class="profile-info">
                <h3><asp:Label ID="lblName" runat="server"></asp:Label></h3>
                <p><strong>Member No:</strong> <asp:Label ID="lblMemberNo" runat="server"></asp:Label></p>
                <p><strong>Status:</strong> <asp:Label ID="lblStatus" runat="server" CssClass="badge"></asp:Label></p>
                <p><strong>Contact:</strong> <asp:Label ID="lblContact" runat="server"></asp:Label></p>
            </div>
        </div>

        <div class="card">
            <div class="card-header">Subscriptions</div>
            <div class="card-body" style="overflow-x: auto;">
                <asp:GridView ID="gvSubscriptions" runat="server" AutoGenerateColumns="False" CssClass="grid-view" EmptyDataText="No subscriptions found." AllowPaging="True" PageSize="15" OnPageIndexChanging="gvSubscriptions_PageIndexChanging">
                    <Columns>
                        <asp:BoundField DataField="SportName" HeaderText="Sport" />
                        <asp:BoundField DataField="PackageName" HeaderText="Package" />
                        <asp:BoundField DataField="SubscriptionType" HeaderText="Type" />
                        <asp:BoundField DataField="StartDate" HeaderText="Start Date" DataFormatString="{0:dd-MMM-yyyy}" />
                        <asp:BoundField DataField="EndDate" HeaderText="End Date" DataFormatString="{0:dd-MMM-yyyy}" NullDisplayText="Continuous" />
                        <asp:BoundField DataField="Fee" HeaderText="Fee" DataFormatString="{0:N2}" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge badge-active" : "badge badge-inactive" %>'>
                                    <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <PagerStyle CssClass="grid-pager" />
                </asp:GridView>
            </div>
        </div>

        <div class="card">
            <div class="card-header">Daily POS Transactions (Passes)</div>
            <div class="card-body" style="overflow-x: auto;">
                <asp:GridView ID="gvPOS" runat="server" AutoGenerateColumns="False" CssClass="grid-view" EmptyDataText="No POS transactions found." AllowPaging="True" PageSize="15" OnPageIndexChanging="gvPOS_PageIndexChanging">
                    <Columns>
                        <asp:BoundField DataField="TransactionID" HeaderText="Trans ID" />
                        <asp:BoundField DataField="SportName" HeaderText="Sport" />
                        <asp:BoundField DataField="PackageName" HeaderText="Package" />
                        <asp:BoundField DataField="TransactionDate" HeaderText="Date" DataFormatString="{0:dd-MMM-yyyy hh:mm tt}" />
                        <asp:BoundField DataField="Amount" HeaderText="Amount" DataFormatString="{0:N2}" />
                        <asp:BoundField DataField="ValidityPeriod" HeaderText="Validity" />
                        <asp:BoundField DataField="Status" HeaderText="Status" />
                    </Columns>
                    <PagerStyle CssClass="grid-pager" />
                </asp:GridView>
            </div>
        </div>
    </asp:Panel>
</asp:Content>
