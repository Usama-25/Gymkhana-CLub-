<%@ Page Title="Department Share Report" Language="C#" MasterPageFile="~/Sports_Management/SiteSports.master" AutoEventWireup="true" CodeFile="ReportDepartmentShares.aspx.cs" Inherits="ReportDepartmentShares" %>

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
            min-width: 180px;
        }

        /* Summary Cards */
        .report-summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        .report-stat {
            background: white;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            border: 1px solid var(--gray-200);
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
            transition: transform 0.2s;
        }
        .report-stat:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        }
        .report-stat .stat-icon {
            width: 45px;
            height: 45px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 10px;
            font-size: 18px;
        }
        .report-stat .stat-value {
            font-size: 22px;
            font-weight: 800;
            color: var(--primary);
        }
        .report-stat .stat-label {
            font-size: 11px;
            color: var(--gray-500);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-top: 4px;
        }

        .share-badge-pct {
            display: inline-block;
            background: #dbeafe;
            color: #1e40af;
            padding: 3px 10px;
            border-radius: 12px;
            font-weight: 700;
            font-size: 12px;
        }
        .share-badge-amt {
            display: inline-block;
            background: #d1fae5;
            color: #065f46;
            padding: 3px 10px;
            border-radius: 12px;
            font-weight: 700;
            font-size: 12px;
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

        @media print {
            .sidebar, .top-header, .filter-card, .btn, .nav-section, .logo, .sidebar-header, .report-summary {
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
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">
    <div class="page-header-card">
        <h2><i class="fas fa-chart-pie" style="margin-right:10px;"></i> Department Share Report</h2>
        <span class="badge">Revenue Allocation Analysis</span>
    </div>

    <!-- Filters -->
    <div class="filter-card">
        <div class="filter-row">
            <div class="filter-group">
                <label>Filter by Sport</label>
                <asp:DropDownList ID="ddlSports" runat="server" CssClass="form-control" AppendDataBoundItems="true">
                    <asp:ListItem Text="-- All Sports --" Value="0"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="filter-group">
                <label>Filter by Department</label>
                <asp:DropDownList ID="ddlDepartments" runat="server" CssClass="form-control" AppendDataBoundItems="true">
                    <asp:ListItem Text="-- All Departments --" Value="0"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="filter-group">
                <label>Filter by Package</label>
                <asp:DropDownList ID="ddlPackages" runat="server" CssClass="form-control" AppendDataBoundItems="true">
                    <asp:ListItem Text="-- All Packages --" Value="0"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="filter-group" style="flex: 0 0 auto;">
                <asp:Button ID="btnGenerate" runat="server" Text="Generate Report" CssClass="btn btn-primary" OnClick="btnGenerate_Click" />
            </div>
        </div>
    </div>

    <asp:Label ID="lblMessage" runat="server" Visible="false" Style="display:block; padding:10px; margin-bottom:15px; border-radius:5px;"></asp:Label>

    <!-- Summary Stats -->
    <asp:Panel ID="pnlSummary" runat="server" Visible="false">
        <div class="report-summary">
            <div class="report-stat">
                <div class="stat-icon" style="background:#dbeafe; color:#1e40af;">
                    <i class="fas fa-box"></i>
                </div>
                <div class="stat-value"><asp:Label ID="lblTotalPackages" runat="server" Text="0"></asp:Label></div>
                <div class="stat-label">Packages Configured</div>
            </div>
            <div class="report-stat">
                <div class="stat-icon" style="background:#fef3c7; color:#d97706;">
                    <i class="fas fa-building"></i>
                </div>
                <div class="stat-value"><asp:Label ID="lblTotalDepartments" runat="server" Text="0"></asp:Label></div>
                <div class="stat-label">Departments Involved</div>
            </div>
            <div class="report-stat">
                <div class="stat-icon" style="background:#d1fae5; color:#059669;">
                    <i class="fas fa-money-bill-wave"></i>
                </div>
                <div class="stat-value">PKR <asp:Label ID="lblTotalAmount" runat="server" Text="0"></asp:Label></div>
                <div class="stat-label">Total Allocated Amount</div>
            </div>
            <div class="report-stat">
                <div class="stat-icon" style="background:#ede9fe; color:#7c3aed;">
                    <i class="fas fa-share-alt"></i>
                </div>
                <div class="stat-value"><asp:Label ID="lblTotalShares" runat="server" Text="0"></asp:Label></div>
                <div class="stat-label">Total Share Entries</div>
            </div>
        </div>
    </asp:Panel>

    <!-- Report Grid -->
    <div class="card">
        <div class="card-header" style="display:flex; justify-content:space-between; align-items:center;">
            <span><i class="fas fa-table" style="margin-right:8px;"></i> Report Results</span>
            <div style="display:flex; gap:8px;">
                <asp:Button ID="btnPrint" runat="server" Text="Print Report" CssClass="btn btn-primary" style="padding: 5px 15px; font-size:12px; background:var(--info); color:white;" OnClientClick="window.print(); return false;" Visible="false" />
                <asp:Button ID="btnBackToSetup" runat="server" Text="Back to Setup" CssClass="btn" style="padding: 5px 15px; font-size:12px; background:var(--secondary); color:white;" OnClick="btnBackToSetup_Click" />
            </div>
        </div>
        <div class="card-body" style="overflow-x: auto;">
            <asp:GridView ID="gvReport" runat="server" AutoGenerateColumns="False" CssClass="grid-view" EmptyDataText="No department share records found." AllowPaging="True" PageSize="20" OnPageIndexChanging="gvReport_PageIndexChanging">
                <Columns>
                    <asp:BoundField DataField="SportName" HeaderText="Sport" />
                    <asp:BoundField DataField="PackageName" HeaderText="Package" />
                    <asp:BoundField DataField="SubscriptionType" HeaderText="Type" />
                    <asp:BoundField DataField="PackageFee" HeaderText="Package Fee" DataFormatString="PKR {0:N2}" />
                    <asp:BoundField DataField="DepartmentName" HeaderText="Department" />
                    <asp:TemplateField HeaderText="Share Mode">
                        <ItemTemplate>
                            <span class='<%# Eval("ShareMode").ToString() == "Percentage" ? "share-badge-pct" : "share-badge-amt" %>'>
                                <%# Eval("ShareMode") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Share Value">
                        <ItemTemplate>
                            <strong style="color:var(--primary);">
                                <%# Eval("ShareMode").ToString() == "Percentage" 
                                    ? Eval("ShareValue", "{0:N2}") + "%" 
                                    : "PKR " + Eval("ShareValue", "{0:N2}") %>
                            </strong>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Share Amount">
                        <ItemTemplate>
                            <strong style="color:var(--success);">PKR <%# Eval("ShareAmount", "{0:N2}") %></strong>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="CreatedOn" HeaderText="Created" DataFormatString="{0:dd-MMM-yyyy}" />
                </Columns>
                <PagerStyle CssClass="grid-pager" />
            </asp:GridView>
        </div>
    </div>

</asp:Content>
