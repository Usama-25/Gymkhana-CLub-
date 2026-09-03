<%@ Page Title="Member Subscription Report" Language="C#" MasterPageFile="~/Sports_Management/SiteSports.master" AutoEventWireup="true" CodeFile="ReportMemberSubscriptions.aspx.cs" Inherits="ReportMemberSubscriptions" %>

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
        }
        .filter-group {
            flex: 1;
        }
        .badge-active { background: var(--success); color: white; padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: bold; }
        .badge-inactive { background: var(--danger); color: white; padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: bold; }

        @media print {
            .sidebar, .top-header, .filter-card, .btn, .nav-section, .logo, .sidebar-header {
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
    <div class="page-header-card">
        <h2>Member Subscription Report</h2>
    </div>

    <div class="filter-card">
        <div class="filter-row">
            <div class="filter-group">
                <label>Member No</label>
                <asp:TextBox ID="txtMemberNo" runat="server" CssClass="form-control" placeholder="Enter Member No (Optional)"></asp:TextBox>
            </div>
            <div class="filter-group">
                <label>Filter by Sport</label>
                <asp:DropDownList ID="ddlSports" runat="server" CssClass="form-control" AppendDataBoundItems="true">
                    <asp:ListItem Text="-- All Sports --" Value="0"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="filter-group">
                <label>Status</label>
                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                    <asp:ListItem Text="-- All Status --" Value="-1"></asp:ListItem>
                    <asp:ListItem Text="Active" Value="1"></asp:ListItem>
                    <asp:ListItem Text="Inactive" Value="0"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="filter-group" style="flex: 0 0 auto;">
                <asp:Button ID="btnGenerate" runat="server" Text="Generate Report" CssClass="btn btn-primary" OnClick="btnGenerate_Click" />
            </div>
        </div>
    </div>

    <asp:Label ID="lblMessage" runat="server" Visible="false" Style="display:block; padding:10px; margin-bottom:15px; border-radius:5px;"></asp:Label>

    <div class="card">
        <div class="card-header" style="display:flex; justify-content:space-between; align-items:center;">
            <span>Report Results</span>
            <asp:Button ID="btnPrint" runat="server" Text="Print / Save HTML" CssClass="btn btn-primary" style="padding: 5px 15px; font-size:12px; background:var(--info); color:white;" OnClick="btnPrint_Click" Visible="false" />
        </div>
        <div class="card-body" style="overflow-x: auto;">
            <asp:GridView ID="gvReport" runat="server" AutoGenerateColumns="False" CssClass="grid-view" EmptyDataText="No records found matching the criteria." AllowPaging="True" PageSize="15" OnPageIndexChanging="gvReport_PageIndexChanging">
                <Columns>
                    <asp:BoundField DataField="MemberNo" HeaderText="Member No" />
                    <asp:BoundField DataField="MemberName" HeaderText="Member Name" />
                    <asp:BoundField DataField="SportName" HeaderText="Sport" />
                    <asp:BoundField DataField="PackageName" HeaderText="Package" />
                    <asp:BoundField DataField="StartDate" HeaderText="Start Date" DataFormatString="{0:dd-MMM-yyyy}" />
                    <asp:BoundField DataField="EndDate" HeaderText="End Date" DataFormatString="{0:dd-MMM-yyyy}" NullDisplayText="Continuous" />
                    <asp:BoundField DataField="Fee" HeaderText="Fee" DataFormatString="{0:N2}" />
                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                                <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <PagerStyle CssClass="grid-pager" />
            </asp:GridView>
        </div>
    </div>
</asp:Content>
