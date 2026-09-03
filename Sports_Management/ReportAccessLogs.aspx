<%@ Page Title="Access Logs Report" Language="C#" MasterPageFile="~/Sports_Management/SiteSports.master" AutoEventWireup="true" CodeFile="ReportAccessLogs.aspx.cs" Inherits="ReportAccessLogs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
    <style>
        .filter-card {
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            border: 1px solid var(--secondary);
        }
        .filter-row {
            display: flex;
            gap: 15px;
            align-items: flex-end;
            flex-wrap: wrap;
        }
        .filter-group {
            flex: 1;
            min-width: 200px;
        }
        .nav-tabs {
            display: flex;
            border-bottom: 1px solid var(--gray-300);
            margin-bottom: 20px;
        }
        .nav-link-tab {
            padding: 10px 20px;
            cursor: pointer;
            border-bottom: 2px solid transparent;
            font-weight: 600;
            color: var(--gray-600);
            background: none;
            border: none;
        }
        .nav-link-tab.active {
            border-bottom-color: var(--primary);
            color: var(--primary);
        }

        @media print {
            .sidebar, .top-header, .filter-card, .btn, .nav-section, .logo, .sidebar-header, .nav-tabs {
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
        <h2>Access Logs Report</h2>
        <asp:Button ID="btnPrint" runat="server" Text="Print / Save HTML" CssClass="btn btn-primary" style="padding: 5px 15px; font-size:12px; background:var(--info); color:white;" OnClick="btnPrint_Click" Visible="false" />
    </div>

    <div class="filter-card">
        <div class="filter-row">
            <div class="filter-group">
                <label>From Date</label>
                <asp:TextBox ID="txtFromDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
            </div>
            <div class="filter-group">
                <label>To Date</label>
                <asp:TextBox ID="txtToDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
            </div>
            <div class="filter-group">
                <label>Sport</label>
                <asp:DropDownList ID="ddlSports" runat="server" CssClass="form-control" AppendDataBoundItems="true">
                    <asp:ListItem Text="-- All Sports --" Value="0"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="filter-group">
                <label>Member No (Optional)</label>
                <asp:TextBox ID="txtMemberNo" runat="server" CssClass="form-control" placeholder="All Members"></asp:TextBox>
            </div>
            <div class="filter-group" style="flex: 0 0 auto;">
                <asp:Button ID="btnGenerate" runat="server" Text="Generate Report" CssClass="btn btn-primary" OnClick="btnGenerate_Click" />
            </div>
        </div>
    </div>

    <asp:Label ID="lblMessage" runat="server" Visible="false" Style="display:block; padding:10px; margin-bottom:15px; border-radius:5px;"></asp:Label>

    <div class="card">
        <div class="card-header">
            <div class="nav-tabs">
                <asp:LinkButton ID="lnkSummary" runat="server" CssClass="nav-link-tab active" OnClick="lnkSummary_Click">Summary View</asp:LinkButton>
                <asp:LinkButton ID="lnkDetails" runat="server" CssClass="nav-link-tab" OnClick="lnkDetails_Click">Detailed View</asp:LinkButton>
            </div>
        </div>
        <div class="card-body" style="overflow-x: auto;">
            
            <asp:MultiView ID="mvReports" runat="server" ActiveViewIndex="0">
                <asp:View ID="vSummary" runat="server">
                    <asp:GridView ID="gvSummary" runat="server" AutoGenerateColumns="False" CssClass="grid-view" EmptyDataText="No access logs found." AllowPaging="True" PageSize="15" OnPageIndexChanging="gvSummary_PageIndexChanging">
                        <Columns>
                            <asp:BoundField DataField="MemberNo" HeaderText="Member No" />
                            <asp:BoundField DataField="MemberName" HeaderText="Member Name" />
                            <asp:BoundField DataField="SportName" HeaderText="Sport" />
                            <asp:BoundField DataField="TotalAccesses" HeaderText="Total Accesses" />
                            <asp:BoundField DataField="GrantedAccesses" HeaderText="Granted" />
                            <asp:BoundField DataField="DeniedAccesses" HeaderText="Denied" />
                        </Columns>
                        <PagerStyle CssClass="grid-pager" />
                    </asp:GridView>
                </asp:View>

                <asp:View ID="vDetails" runat="server">
                    <asp:GridView ID="gvDetails" runat="server" AutoGenerateColumns="False" CssClass="grid-view" EmptyDataText="No access logs found." AllowPaging="True" PageSize="15" OnPageIndexChanging="gvDetails_PageIndexChanging">
                        <Columns>
                            <asp:BoundField DataField="LogID" HeaderText="Log ID" />
                            <asp:BoundField DataField="MemberNo" HeaderText="Member No" />
                            <asp:BoundField DataField="MemberName" HeaderText="Member Name" />
                            <asp:BoundField DataField="SportName" HeaderText="Sport" />
                            <asp:BoundField DataField="AccessTime" HeaderText="Access Time" DataFormatString="{0:dd-MMM-yyyy hh:mm tt}" />
                            <asp:BoundField DataField="AccessResult" HeaderText="Result" />
                            <asp:BoundField DataField="DenialReason" HeaderText="Reason (if denied)" />
                        </Columns>
                        <PagerStyle CssClass="grid-pager" />
                    </asp:GridView>
                </asp:View>
            </asp:MultiView>

        </div>
    </div>
</asp:Content>
