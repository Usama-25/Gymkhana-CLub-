<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/MemberShipModule/Site.master"
    AutoEventWireup="true" CodeFile="AdminDashboard.aspx.cs" Inherits="AdminDashboard" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
<script runat="server">
    protected override object SaveViewState()
    {
        ViewState.Remove("AlertsData");
        return base.SaveViewState();
    }

    private int GetSelectedAlertType()
    {
        string header = lblAlertHeader.Text;
        if (header.Contains("Sons")) return 1;
        if (header.Contains("Non-Earning")) return 2;
        if (header.Contains("Senior")) return 3;
        return 0;
    }

    private System.Data.DataTable GetAlertsData(int type)
    {
        System.Data.DataTable dtAlerts = new System.Data.DataTable();
        dtAlerts.Columns.Add("Title");
        dtAlerts.Columns.Add("Message");
        dtAlerts.Columns.Add("Type");
        dtAlerts.Columns.Add("BadgeBg");
        dtAlerts.Columns.Add("BadgeFg");

        var connSetting = System.Configuration.ConfigurationManager.ConnectionStrings["MemberShipConnection"];
        string conn = connSetting != null ? connSetting.ConnectionString : "";
        using (System.Data.SqlClient.SqlConnection con = new System.Data.SqlClient.SqlConnection(conn))
        {
            try { con.Open(); } catch { return dtAlerts; }

            using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand("usp_GetSpecificAlerts", con))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.Add("@Type", System.Data.SqlDbType.NVarChar, 50).Value = type;
                using (System.Data.SqlClient.SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        if (type == 1)
                        {
                            dtAlerts.Rows.Add(
                                "Son Reached 18",
                                string.Format("Member's Son <b>{0}</b> (Son of {1} - {2}) has reached the age of {3}.", dr["ChildName"], dr["MemberName"], dr["MemberNo"], dr["Age"]),
                                "Age Alert",
                                "#fee2e2",
                                "#991b1b"
                            );
                        }
                        else if (type == 2)
                        {
                            dtAlerts.Rows.Add(
                                "Non-Earning Member Reached 27",
                                string.Format("Member <b>{0}</b> ({1}) has reached the age of {2} under 'Non Earning MemberShip'.", dr["MemberName"], dr["MemberNo"], dr["Age"]),
                                "Category Alert",
                                "#fefce8",
                                "#854d0e"
                            );
                        }
                        else if (type == 3)
                        {
                            dtAlerts.Rows.Add(
                                "Senior Citizen (65+)",
                                string.Format("Member <b>{0}</b> ({1}) has reached the age of {2}.", dr["MemberName"], dr["MemberNo"], dr["Age"]),
                                "Senior Alert",
                                "#dcfce7",
                                "#166534"
                            );
                        }
                    }
                }
            }
        }
        return dtAlerts;
    }

    protected void btnExportExcel_CustomClick(object sender, EventArgs e)
    {
        int type = GetSelectedAlertType();
        if (type == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('No data available to export. Please select an alert category first.');", true);
            return;
        }

        System.Data.DataTable dt = GetAlertsData(type);
        if (dt == null || dt.Rows.Count == 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('No data available to export. Please select an alert category first.');", true);
            return;
        }

        System.Data.DataTable dtExport = new System.Data.DataTable();
        dtExport.Columns.Add("Alert Type");
        dtExport.Columns.Add("Message");
        dtExport.Columns.Add("Category");

        foreach (System.Data.DataRow row in dt.Rows)
        {
            dtExport.Rows.Add(
                row["Title"],
                row["Message"].ToString().Replace("<b>", "").Replace("</b>", ""),
                row["Type"]
            );
        }

        Response.Clear();
        Response.Buffer = true;
        Response.AddHeader("content-disposition", "attachment;filename=SystemAlerts.csv");
        Response.Charset = "utf-8";
        Response.ContentType = "text/csv";

        Response.BinaryWrite(new byte[] { 0xEF, 0xBB, 0xBF });

        StringBuilder sb = new StringBuilder();
        for (int k = 0; k < dtExport.Columns.Count; k++)
        {
            sb.Append(dtExport.Columns[k].ColumnName + (k < dtExport.Columns.Count - 1 ? "," : ""));
        }
        sb.Append("\r\n");

        foreach (System.Data.DataRow row in dtExport.Rows)
        {
            for (int k = 0; k < dtExport.Columns.Count; k++)
            {
                string value = row[k].ToString();
                if (value.Contains(",") || value.Contains("\"") || value.Contains("\n") || value.Contains("\r"))
                {
                    value = "\"" + value.Replace("\"", "\"\"") + "\"";
                }
                sb.Append(value + (k < dtExport.Columns.Count - 1 ? "," : ""));
            }
            sb.Append("\r\n");
        }

        Response.Write(sb.ToString());
        Response.End();
    }

    protected void btnExportPDF_CustomClick(object sender, EventArgs e)
    {
        int type = GetSelectedAlertType();
        if (type == 0) return;

        System.Data.DataTable dt = GetAlertsData(type);
        if (dt == null || dt.Rows.Count == 0) return;

        string generatedDate = DateTime.Now.ToString("dd-MMM-yyyy HH:mm");

        StringBuilder html = new StringBuilder();
        html.Append(@"<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <title>System Alerts Report</title>
    <style>
        @page { size: A4; margin: 15mm; }
        @media print { body { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; } }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', Arial, sans-serif; font-size: 11px; color: #1a202c; background: #fff; padding: 20px; }
        .header { text-align: center; margin-bottom: 25px; padding-bottom: 15px; border-bottom: 2px solid #2c5282; }
        .title { font-size: 20px; font-weight: bold; color: #1a365d; margin-bottom: 5px; }
        .subtitle { font-size: 16px; font-weight: 600; color: #2d3748; margin-bottom: 8px; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th { background: #2c5282; color: white; font-weight: 600; padding: 10px 8px; text-align: left; font-size: 10px; }
        td { padding: 8px; border-bottom: 1px solid #e2e8f0; font-size: 10px; }
        tr:nth-child(even) { background: #f7fafc; }
        tr:hover { background: #edf2f7; }
        .footer { margin-top: 25px; padding-top: 15px; border-top: 1px solid #e2e8f0; text-align: center; font-size: 9px; color: #718096; }
    </style>
</head>
<body>
    <div class='header'>
        <div class='title'>Lahore Gymkhana Club</div>
        <div class='subtitle'>" + lblAlertHeader.Text + @"</div>
    </div>
    <table>
        <thead>
            <tr>
                <th>Alert Type</th>
                <th>Message</th>
                <th>Category</th>
            </tr>
        </thead>
        <tbody>");

        foreach (System.Data.DataRow row in dt.Rows)
        {
            html.Append("<tr>");
            html.Append("<td>" + Server.HtmlEncode(row["Title"].ToString()) + "</td>");
            html.Append("<td>" + row["Message"].ToString() + "</td>");
            html.Append("<td>" + Server.HtmlEncode(row["Type"].ToString()) + "</td>");
            html.Append("</tr>");
        }

        html.Append(@"
        </tbody>
    </table>
    <div class='footer'>
        <p>Generated on: " + generatedDate + @" | Total Records: " + dt.Rows.Count + @"</p>
        <br/>
        <p><strong>Powered by MegaPlus Technologies</strong></p>
    </div>
    <script>window.onload = function() { window.print(); }</" + @"script>
</body>
</html>");

        Response.Clear();
        Response.ContentType = "text/html";
        Response.Write(html.ToString());
        Response.End();
    }
</script>
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
            .dashboard-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 16px;
                margin-bottom: 24px;
            }

            .stat-card {
                background: #fff;
                border-radius: 10px;
                padding: 16px;
                box-shadow: 0 2px 4px -1px rgba(0, 0, 0, 0.06), 0 4px 6px -1px rgba(0, 0, 0, 0.1);
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                transition: transform 0.2s ease, box-shadow 0.2s ease;
                cursor: pointer;
                border: 1px solid #eef2f7;
                position: relative;
                overflow: hidden;
            }

            .stat-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            }

            .stat-icon-wrapper {
                margin-bottom: 12px;
                width: 40px;
                height: 40px;
                border-radius: 8px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 20px;
            }

            .stat-value {
                font-size: 24px;
                font-weight: 700;
                color: #1e293b;
                margin-bottom: 2px;
            }

            .stat-label {
                font-size: 13px;
                color: #7a7a7a;
                font-weight: 500;
            }

            /* Color Themes */
            .card-blue .stat-icon-wrapper {
                background: #faf7f2;
                color: #8B5E3C;
            }

            .card-blue:hover {
                border-color: #8B5E3C;
            }

            .card-green .stat-icon-wrapper {
                background: #f0fdf4;
                color: #22c55e;
            }

            .card-green:hover {
                border-color: #22c55e;
            }

            .card-yellow .stat-icon-wrapper {
                background: #fefce8;
                color: #eab308;
            }

            .card-yellow:hover {
                border-color: #eab308;
            }

            .card-red .stat-icon-wrapper {
                background: #fef2f2;
                color: #ef4444;
            }

            .card-red:hover {
                border-color: #ef4444;
            }

            .card-purple .stat-icon-wrapper {
                background: #faf5ff;
                color: #a855f7;
            }

            .card-purple:hover {
                border-color: #a855f7;
            }


        </style>
        <!-- Use Font Awesome for icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">
        <div class="page-wrapper mt-6" style="margin-top: 0.75rem; ;">

            <div style="background: linear-gradient(135deg, #1A1A2E, #2d2d5e); color: #fff; padding: 16px 26px; border-radius: 10px; margin-bottom: 18px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 4px 15px rgba(0,0,0,0.2);">
                <div>
                    <h1 style="margin: 0; font-size: 1.35rem; font-weight: 700; color: #fff;">Hello, <asp:Literal ID="litUserName" runat="server"></asp:Literal></h1>
                    <p style="font-size: .8rem; color: #E8D5A3; margin: 3px 0 0 0;">Here is what's happening in your club today.</p>
                </div>
            </div>


            <!-- Statistics Grid -->
            <div class="dashboard-grid">

                <!-- Active Members -->
                <div class="stat-card card-blue" id="cardActiveMembers" runat="server">
                    <div class="stat-icon-wrapper">
                        <i class="fas fa-users"></i>
                    </div>
                    <div>
                        <div class="stat-value">
                            <asp:Literal ID="litActiveMembers" runat="server">0</asp:Literal>
                        </div>
                        <div class="stat-label">Active Members</div>
                    </div>
                </div>

                <!-- Pending Applications -->
                <div class="stat-card card-yellow" id="cardPendingApps" runat="server">
                    <div class="stat-icon-wrapper">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div>
                        <div class="stat-value">
                            <asp:Literal ID="litPendingApps" runat="server">0</asp:Literal>
                        </div>
                        <div class="stat-label">Pending Applications</div>
                    </div>
                </div>

                <!-- Approved Applications -->
                <div class="stat-card card-green" id="cardApprovedApps" runat="server">
                    <div class="stat-icon-wrapper">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <div>
                        <div class="stat-value">
                            <asp:Literal ID="litApprovedApps" runat="server">0</asp:Literal>
                        </div>
                        <div class="stat-label">Approved Applications</div>
                    </div>
                </div>

                <!-- Blocked Cards -->
                <div class="stat-card card-red" id="cardBlockedCards" runat="server">
                    <div class="stat-icon-wrapper">
                        <i class="fas fa-id-card-clip"></i>
                    </div>
                    <div>
                        <div class="stat-value">
                            <asp:Literal ID="litBlockedCards" runat="server">0</asp:Literal>
                        </div>
                        <div class="stat-label">Blocked Cards</div>
                    </div>
                </div>

                <!-- Blocked Vehicles -->
                <div class="stat-card card-red" id="cardBlockedVehicles" runat="server">
                    <div class="stat-icon-wrapper">
                        <i class="fas fa-car-crash"></i>
                    </div>
                    <div>
                        <div class="stat-value">
                            <asp:Literal ID="litBlockedVehicles" runat="server">0</asp:Literal>
                        </div>
                        <div class="stat-label">Blocked Vehicles</div>
                    </div>
                </div>

                <!-- Total card Stock -->
                <div class="stat-card card-purple" id="cardTotalCards" runat="server">
                    <div class="stat-icon-wrapper">
                        <i class="fas fa-layer-group"></i>
                    </div>
                    <div>
                        <div class="stat-value">
                            <asp:Literal ID="litTotalCards" runat="server">--</asp:Literal>
                        </div>
                        <div class="stat-label">Card Issuance (Today)</div>
                    </div>
                </div>

                <!-- Sons Reaching 18 -->
                <asp:LinkButton ID="lnkSonsAlert" runat="server" OnClick="lnkSonsAlert_Click" CssClass="stat-card card-red" style="text-decoration:none;">
                    <div class="stat-icon-wrapper" style="background: #fef2f2; color: #ef4444;">
                        <i class="fas fa-child"></i>
                    </div>
                    <div>
                        <div class="stat-value" style="color: #1e293b;">
                            <asp:Literal ID="litSonsCount" runat="server">0</asp:Literal>
                        </div>
                        <div class="stat-label" style="color: #7a7a7a;">Sons Reaching 18</div>
                    </div>
                </asp:LinkButton>

                <!-- Non-Earning Reaching 27 -->
                <asp:LinkButton ID="lnkNonEarningAlert" runat="server" OnClick="lnkNonEarningAlert_Click" CssClass="stat-card card-yellow" style="text-decoration:none;">
                    <div class="stat-icon-wrapper" style="background: #fefce8; color: #eab308;">
                        <i class="fas fa-user-clock"></i>
                    </div>
                    <div>
                        <div class="stat-value" style="color: #1e293b;">
                            <asp:Literal ID="litNonEarningCount" runat="server">0</asp:Literal>
                        </div>
                        <div class="stat-label" style="color: #7a7a7a;">Non-Earning reaching 27</div>
                    </div>
                </asp:LinkButton>

                <!-- Members 65+ -->
                <asp:LinkButton ID="lnkSeniorAlert" runat="server" OnClick="lnkSeniorAlert_Click" CssClass="stat-card card-green" style="text-decoration:none;">
                    <div class="stat-icon-wrapper" style="background: #f0fdf4; color: #22c55e;">
                        <i class="fas fa-user-plus"></i>
                    </div>
                    <div>
                        <div class="stat-value" style="color: #1e293b;">
                            <asp:Literal ID="litSeniorCount" runat="server">0</asp:Literal>
                        </div>
                        <div class="stat-label" style="color: #7a7a7a;">Members 65+</div>
                    </div>
                </asp:LinkButton>

            </div>

            <!-- Alerts Section -->
            <div id="alertsSection" class="table-container" style="margin-top: 2rem;">
                <div style="padding: 1rem 1.5rem; border-bottom: 1px solid #e0d5c5; background: #faf7f2; display: flex; justify-content: space-between; align-items: center;">
                    <h2 style="font-size: 1.1rem; font-weight: 700; color: #1e293b; margin: 0;">
                        <asp:Label ID="lblAlertHeader" runat="server" Text="System Alerts (Select a badge above)"></asp:Label>
                    </h2>
                    <div>
                        <asp:LinkButton ID="btnExportExcel" runat="server" CssClass="btn btn-sm btn-success" OnClick="btnExportExcel_CustomClick" style="margin-right: 0.5rem;">
                            <i class="fas fa-file-excel mr-1"></i> Export Excel
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnExportPDF" runat="server" CssClass="btn btn-sm btn-danger" OnClick="btnExportPDF_CustomClick">
                            <i class="fas fa-file-pdf mr-1"></i> Export PDF
                        </asp:LinkButton>
                    </div>
                </div>
                <div style="padding: 1rem;">
                    <asp:Panel ID="pnlSelectAlert" runat="server" CssClass="empty-state" style="margin-bottom: 1rem;">
                        <i class="fas fa-hand-pointer" style="font-size: 2rem; color: #a09080;"></i>
                        <div>Click on one of the alert badges above to view the list.</div>
                    </asp:Panel>
                    <asp:Repeater ID="rptAlerts" runat="server">
                        <ItemTemplate>
                            <div class="alert-item" style="padding: 0.75rem 1rem; border-bottom: 1px solid #e0d5c5; display: flex; align-items: center; justify-content: space-between;">
                                <div>
                                    <span style="font-weight: 600; color: #1e293b;"><%# Eval("Title") %></span>
                                    <div style="color: #7a7a7a; font-size: 0.9rem; margin-top: 0.25rem;"><%# Eval("Message") %></div>
                                </div>
                                <asp:Label ID="lblBadge" runat="server" CssClass="badge" Text='<%# Eval("Type") %>' style="padding: 0.25rem 0.5rem; border-radius: 4px; font-size: 0.75rem; font-weight: 600;"></asp:Label>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Panel ID="pnlNoAlerts" runat="server" CssClass="empty-state" Visible="false">
                        <i class="fas fa-bell-slash" style="font-size: 2rem; color: #a09080;"></i>
                        <div>No active alerts at this time.</div>
                    </asp:Panel>
                </div>
            </div>

        </div>
    </asp:Content>









