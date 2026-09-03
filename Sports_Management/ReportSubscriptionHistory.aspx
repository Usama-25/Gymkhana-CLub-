

<%@ Page Title="Member Subscription & Unsubscription History" Language="C#" MasterPageFile="~/Sports_Management/SiteSports.master" AutoEventWireup="true" CodeFile="ReportSubscriptionHistory.aspx.cs" Inherits="ReportSubscriptionHistory" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
    <style>
        .page-header-card { margin-bottom: 12px; }
        .page-header-card h2 { font-size: 18px; margin: 0; color: #1e3a5f; font-weight: 800; display: flex; align-items: center; gap: 10px; }

        /* KPI Cards Grid */
        .kpi-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 12px;
            margin-bottom: 14px;
        }
        .kpi-card {
            background: #ffffff;
            border-radius: 8px;
            padding: 12px 16px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .kpi-card .kpi-info { display: flex; flex-direction: column; }
        .kpi-card .kpi-label { font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px; }
        .kpi-card .kpi-value { font-size: 20px; font-weight: 800; color: #0f172a; margin-top: 2px; }
        .kpi-card .kpi-icon {
            width: 38px;
            height: 38px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
        }
        .kpi-icon.total { background: #e0f2fe; color: #0284c7; }
        .kpi-icon.sub { background: #dcfce7; color: #16a34a; }
        .kpi-icon.unsub { background: #fee2e2; color: #dc2626; }
        .kpi-icon.members { background: #f3e8ff; color: #9333ea; }

        /* Filter Section */
        .filter-card {
            background: #ffffff;
            padding: 14px 16px;
            border-radius: 8px;
            border: 1px solid #cbd5e1;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            margin-bottom: 14px;
        }
        .filter-row {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            align-items: flex-end;
        }
        .filter-group { flex: 1; min-width: 140px; }
        .filter-group label { font-size: 11.5px; font-weight: 700; color: #1e3a5f; margin-bottom: 3px; display: block; }
        .filter-group .form-control { height: 32px; font-size: 12px; }

        /* Badges */
        .badge-sub {
            background: #dcfce7;
            color: #15803d;
            border: 1px solid #86efac;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        .badge-unsub {
            background: #fee2e2;
            color: #b91c1c;
            border: 1px solid #fca5a5;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        .badge-active-status { background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; padding: 2px 8px; border-radius: 4px; font-size: 10px; font-weight: 700; }
        .badge-inactive-status { background: #f3f4f6; color: #6b7280; border: 1px solid #e5e7eb; padding: 2px 8px; border-radius: 4px; font-size: 10px; font-weight: 700; }

        /* Grid */
        .custom-grid-container {
            max-height: 480px;
            overflow-y: auto;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            background: #fff;
        }
        .grid-view { width: 100%; border-collapse: collapse; }
        .grid-view th {
            position: sticky;
            top: 0;
            z-index: 5;
            background: #1e3a8a;
            color: #ffffff;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            padding: 9px 12px;
            text-align: left;
            white-space: nowrap;
        }
        .grid-view td {
            padding: 8px 12px;
            font-size: 12px;
            color: #334155;
            border-bottom: 1px solid #f1f5f9;
            vertical-align: middle;
        }
        .grid-view tr:hover { background-color: #f8fafc; }

        /* Pagination */
        .grid-pager table { margin: 10px 0; }
        .grid-pager td { padding: 0 3px !important; border: none !important; }
        .grid-pager a, .grid-pager span {
            display: inline-block;
            padding: 5px 11px;
            border: 1px solid #cbd5e1;
            border-radius: 4px;
            text-decoration: none;
            font-size: 12px;
            font-weight: 700;
        }
        .grid-pager a { color: #1e3a5f; background: #ffffff; }
        .grid-pager a:hover { background: #e8f0fe; color: #0f2b48; }
        .grid-pager span { background: #1e3a5f; color: #ffffff; border-color: #1e3a5f; }

        @page {
            size: landscape;
            margin: 6mm;
        }

        @media print {
            .filter-card, .kpi-container, .btn, .top-header, .sidebar, .sidebar-wrapper, .navbar, .page-header-card, .grid-pager, .footer, footer {
                display: none !important;
            }

            body, html {
                background: #ffffff !important;
                color: #000000 !important;
                margin: 0 !important;
                padding: 0 !important;
                width: 100% !important;
                font-family: Arial, sans-serif !important;
            }

            .main-content, .content-wrapper, .card, .card-body, .custom-grid-container {
                width: 100% !important;
                max-width: 100% !important;
                padding: 0 !important;
                margin: 0 !important;
                border: none !important;
                box-shadow: none !important;
                max-height: none !important;
                overflow: visible !important;
            }

            .print-only-header {
                display: block !important;
                margin-bottom: 10px !important;
                border-bottom: 2px solid #1e3a8a !important;
                padding-bottom: 6px !important;
            }

            .card-header {
                display: none !important;
            }

            .grid-view {
                width: 100% !important;
                border-collapse: collapse !important;
                table-layout: auto !important;
                font-size: 9px !important;
            }

            .grid-view th {
                background-color: #1e3a8a !important;
                color: #ffffff !important;
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
                font-size: 9px !important;
                padding: 4px 5px !important;
                border: 1px solid #94a3b8 !important;
                white-space: nowrap !important;
            }

            .grid-view td {
                padding: 4px 5px !important;
                font-size: 9px !important;
                color: #0f172a !important;
                border: 1px solid #cbd5e1 !important;
                word-break: normal !important;
                vertical-align: middle !important;
            }

            .grid-view tr {
                page-break-inside: avoid !important;
            }

            .badge-sub, .badge-unsub, .badge-active-status, .badge-inactive-status {
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
                font-size: 8.5px !important;
                padding: 1px 5px !important;
                border-radius: 3px !important;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">

    <div class="page-header-card" style="display:flex; justify-content:space-between; align-items:center;">
        <div>
            <h2><i class="fas fa-history" style="color:#2563eb;"></i> Subscription &amp; Unsubscription History Log</h2>
        </div>
    </div>

    <%-- KPI Stats Cards --%>
    <div class="kpi-container">
        <div class="kpi-card">
            <div class="kpi-info">
                <span class="kpi-label">Total Subscriptions</span>
                <span class="kpi-value"><asp:Label ID="lblTotalLogs" runat="server" Text="0"></asp:Label></span>
            </div>
            <div class="kpi-icon total"><i class="fas fa-list-check"></i></div>
        </div>

        <div class="kpi-card">
            <div class="kpi-info">
                <span class="kpi-label">Active Subscriptions</span>
                <span class="kpi-value" style="color:#16a34a;"><asp:Label ID="lblSubscribedCount" runat="server" Text="0"></asp:Label></span>
            </div>
            <div class="kpi-icon sub"><i class="fas fa-check-circle"></i></div>
        </div>

        <div class="kpi-card">
            <div class="kpi-info">
                <span class="kpi-label">Deactivated Count</span>
                <span class="kpi-value" style="color:#dc2626;"><asp:Label ID="lblUnsubscribedCount" runat="server" Text="0"></asp:Label></span>
            </div>
            <div class="kpi-icon unsub"><i class="fas fa-times-circle"></i></div>
        </div>

        <div class="kpi-card">
            <div class="kpi-info">
                <span class="kpi-label">Unique Members</span>
                <span class="kpi-value" style="color:#9333ea;"><asp:Label ID="lblUniqueMembers" runat="server" Text="0"></asp:Label></span>
            </div>
            <div class="kpi-icon members"><i class="fas fa-users"></i></div>
        </div>
    </div>

    <%-- Filters --%>
    <div class="filter-card">
        <div class="filter-row">
            <div class="filter-group" style="flex:1.2; min-width:180px;">
                <label>Member ID / Name</label>
                <asp:TextBox ID="txtSearchMember" runat="server" CssClass="form-control" placeholder="Enter MEM-001 or Name..."></asp:TextBox>
            </div>

            <div class="filter-group">
                <label>Filter by Department</label>
                <asp:DropDownList ID="ddlSports" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlSports_SelectedIndexChanged">
                </asp:DropDownList>
            </div>

            <div class="filter-group">
                <label>Sub Department</label>
                <asp:DropDownList ID="ddlSubDept" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlSubDept_SelectedIndexChanged">
                </asp:DropDownList>
            </div>

            <div class="filter-group">
                <label>Subscription Status</label>
                <asp:DropDownList ID="ddlActionType" runat="server" CssClass="form-control">
                    <asp:ListItem Text="-- All Status --" Value="ALL"></asp:ListItem>
                    <asp:ListItem Text="Active Only" Value="Active"></asp:ListItem>
                    <asp:ListItem Text="Deactivated Only" Value="Deactivated"></asp:ListItem>
                </asp:DropDownList>
            </div>

            <div class="filter-group">
                <label>From Date</label>
                <asp:TextBox ID="txtFromDate" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
            </div>

            <div class="filter-group">
                <label>To Date</label>
                <asp:TextBox ID="txtToDate" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
            </div>

            <div class="filter-group" style="flex:0 0 auto; display:flex; gap:8px;">
                <asp:Button ID="btnGenerate" runat="server" Text="🔍 Search Logs" CssClass="btn btn-primary" OnClick="btnGenerate_Click" style="height:32px; font-size:12px; font-weight:700;" />
                <asp:Button ID="btnReset" runat="server" Text="↺ Reset" CssClass="btn" OnClick="btnReset_Click" style="height:32px; font-size:12px; font-weight:700; background:#e2e8f0; color:#334155;" />
            </div>
        </div>
    </div>

    <asp:Label ID="lblMessage" runat="server" Visible="false" Style="display:block; padding:10px 14px; margin-bottom:12px; border-radius:6px; font-weight:bold; font-size:12px;"></asp:Label>

    <%-- Print Only Header --%>
    <div class="print-only-header" style="display:none;">
        <div style="display:flex; justify-content:space-between; align-items:flex-end; border-bottom:2px solid #1e3a8a; padding-bottom:8px; margin-bottom:10px;">
            <div>
                <h1 style="margin:0; font-size:18px; color:#1e3a8a; font-weight:800; text-transform:uppercase; letter-spacing:0.5px;">Lahore Gymkhana Club</h1>
                <h3 style="margin:2px 0 0 0; font-size:13px; color:#334155; font-weight:700;">Subscription &amp; Unsubscription History Report</h3>
            </div>
            <div style="font-size:10px; color:#475569; text-align:right;">
                <div><strong>Printed Date:</strong> <%= DateTime.Now.ToString("dd-MMM-yyyy hh:mm tt") %></div>
                <div><strong>Generated By:</strong> <%= Session["UserName"] != null ? Session["UserName"].ToString() : "Admin" %></div>
            </div>
        </div>
    </div>

    <%-- Log Results Grid --%>
    <div class="card">
        <div class="card-header" style="display:flex; justify-content:space-between; align-items:center; background:#1e3a8a; color:white; padding:8px 14px;">
            <span style="font-weight:700; font-size:13px;"><i class="fas fa-history"></i> Member Subscription &amp; Unsubscription History</span>
            <button type="button" onclick="window.print();" class="btn btn-primary" style="height:28px; padding:0 12px; font-size:11px; background:#3b82f6; border-color:#3b82f6;">
                <i class="fas fa-print"></i> Print Report
            </button>
        </div>
        <div class="card-body" style="padding:0;">
            <div class="custom-grid-container">
                <asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="False" CssClass="grid-view" 
                    EmptyDataText="No subscription history records found for the selected criteria." 
                    AllowPaging="True" PageSize="20" OnPageIndexChanging="gvHistory_PageIndexChanging" GridLines="None">
                    <Columns>
                        <%-- Manual Register / Card No --%>
                        <asp:TemplateField HeaderText="Manual Register / Card No" ItemStyle-Width="140px">
                            <ItemTemplate>
                                <span style="font-weight:700; color:#0f766e; background:#f0fdfa; padding:2px 8px; border-radius:4px; border:1px solid #ccfbf1; display:inline-block; font-size:11.5px;">
                                    <%# Eval("ManualCardNo") != DBNull.Value && !string.IsNullOrWhiteSpace(Eval("ManualCardNo").ToString()) ? Eval("ManualCardNo") : "-" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- Member No --%>
                        <asp:TemplateField HeaderText="Member No" ItemStyle-Width="90px">
                            <ItemTemplate>
                                <span style="font-weight:700; color:#1e3a8a;"><%# Eval("MemberNo") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- Name & Relation --%>
                        <asp:TemplateField HeaderText="Member Name">
                            <ItemTemplate>
                                <div style="font-weight:600;"><%# Eval("MemberName") %></div>
                                <div style="font-size:10px; color:#64748b; font-weight:700; text-transform:uppercase;"><%# Eval("Relationship") %></div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- Sport & Package --%>
                        <asp:TemplateField HeaderText="Sport / Package">
                            <ItemTemplate>
                                <div style="font-weight:700; color:#0f172a;"><%# GetSportDisplay(Eval("SportID"), Eval("SportName"), Eval("PackageName")) %></div>
                                <div style="font-size:11px; color:#64748b;"><%# GetPackageDisplay(Eval("SportID"), Eval("SportName"), Eval("PackageName"), Eval("SubscriptionType"), Eval("EndDate")) %></div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- Activation Date & Time --%>
                        <asp:TemplateField HeaderText="Activation Date &amp; Time" ItemStyle-Width="145px">
                            <ItemTemplate>
                                <span style="font-weight:700; color:#1e293b;">
                                    <%# Eval("ActivatedOn") != DBNull.Value ? Convert.ToDateTime(Eval("ActivatedOn")).ToString("dd-MMM-yyyy hh:mm tt") : "-" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- Deactivation Date & Time --%>
                        <asp:TemplateField HeaderText="Deactivation Date &amp; Time" ItemStyle-Width="155px">
                            <ItemTemplate>
                                <%# GetDeactivationDisplay(Eval("DeactivatedOn"), Eval("EndDate"), Eval("IsActive")) %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- Duration (Days/Hours/Mins) --%>
                        <asp:TemplateField HeaderText="Duration" ItemStyle-Width="105px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <%# GetDurationDisplay(Eval("ActivatedOn"), Eval("DeactivatedOn"), Eval("IsActive")) %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- Current Sub Status --%>
                        <asp:TemplateField HeaderText="Status" ItemStyle-Width="90px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active-status" : "badge-inactive-status" %>'>
                                    <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Deactivated" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <PagerStyle CssClass="grid-pager" HorizontalAlign="Right" />
                </asp:GridView>
            </div>
        </div>
    </div>

</asp:Content>
