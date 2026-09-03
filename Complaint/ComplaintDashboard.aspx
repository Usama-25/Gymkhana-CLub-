<%@ Page Language="C#" MasterPageFile="~/Complaint/Complaint.Master" AutoEventWireup="true" CodeFile="ComplaintDashboard.aspx.cs" Inherits="GymkhanaLibrary.Pages_ComplaintDashboard" Title="Member Complaints & Feedback Dashboard - Lahore Gymkhana Club" %>

<asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        /* Premium Dashboard CSS Styling */
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 16px;
            margin-bottom: 24px;
            width: 100%;
            box-sizing: border-box;
        }

        @media (max-width: 1200px) {
            .kpi-grid {
                grid-template-columns: repeat(3, 1fr);
            }
        }

        @media (max-width: 768px) {
            .kpi-grid {
                grid-template-columns: repeat(1, 1fr);
            }
        }

        .kpi-card {
            background-color: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 18px 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.02);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }
        .kpi-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 20px -5px rgba(15, 30, 54, 0.08);
        }
        .kpi-card::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 100%;
        }
        
        .kpi-card.blue::after { background-color: #3b82f6; }
        .kpi-card.purple::after { background-color: #8b5cf6; }
        .kpi-card.amber::after { background-color: #f59e0b; }
        .kpi-card.rose::after { background-color: #f43f5e; }
        .kpi-card.emerald::after { background-color: #10b981; }

        .kpi-title {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            color: #64748b;
            letter-spacing: 0.6px;
            margin-bottom: 8px;
        }
        .kpi-val-container {
            display: flex;
            align-items: baseline;
            gap: 8px;
        }
        .kpi-value {
            font-size: 28px;
            font-weight: 800;
            color: #0f1e36;
            line-height: 1;
        }
        .kpi-desc {
            font-size: 11px;
            color: #64748b;
            margin-top: 10px;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        /* Charts Section Layout */
        .charts-row-top {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 20px;
            margin-bottom: 24px;
            width: 100%;
            box-sizing: border-box;
        }
        .charts-row-bottom {
            display: grid;
            grid-template-columns: 1.2fr 1.8fr;
            gap: 20px;
            margin-bottom: 24px;
            width: 100%;
            box-sizing: border-box;
        }

        @media (max-width: 992px) {
            .charts-row-top, .charts-row-bottom {
                grid-template-columns: 1fr;
            }
        }

        .chart-container {
            background-color: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.02);
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
        }
        .chart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            border-bottom: 1px solid #f1f5f9;
            padding-bottom: 12px;
        }
        .chart-title {
            font-family: 'Playfair Display', serif;
            font-size: 16px;
            font-weight: 700;
            color: #0f1e36;
            margin: 0;
        }
        .chart-canvas-wrapper {
            position: relative;
            flex-grow: 1;
            min-height: 250px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* Status Badges */
        .status-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 9999px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        .status-badge.pending { background-color: #fee2e2; color: #991b1b; }
        .status-badge.progress { background-color: #fef3c7; color: #92400e; }
        .status-badge.resolved { background-color: #d1fae5; color: #065f46; }
        .status-badge.closed { background-color: #f1f5f9; color: #475569; }

        .type-badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 6px;
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
        }
        .type-badge.complaint { background-color: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd; }
        .type-badge.feedback { background-color: #faf5ff; color: #6b21a8; border: 1px solid #e9d5ff; }

        .gv-header {
            background-color: #f8fafc;
            color: #475569;
            font-weight: 700;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 10px 12px;
            border-bottom: 2px solid #e2e8f0;
        }
        .gv-row, .gv-alt-row {
            border-bottom: 1px solid #f1f5f9;
            transition: background-color 0.15s ease;
        }
        .gv-row:hover, .gv-alt-row:hover {
            background-color: #f8fafc;
        }
        .gv-text-left {
            padding: 10px 12px;
            vertical-align: middle;
        }
    </style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">
    <!-- Header -->
    <div style="background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; padding: 16px 28px; border-radius: 12px; margin-bottom: 24px; border-bottom: 3px solid #c5a059; display: flex; justify-content: space-between; align-items: center; width: 100%; box-sizing: border-box; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);">
        <div style="display: block;">
            <h2 style="margin: 0; font-family: 'Playfair Display', serif; font-size: 22px; font-weight: 700; letter-spacing: 0.5px;">Member Complaints & Feedback Dashboard</h2>
            <p style="margin: 4px 0 0 0; font-size: 12px; color: rgba(255, 255, 255, 0.7); font-weight: 300;">Real-time analytical overview of member complaints and feedback submissions.</p>
        </div>
        <div style="font-size: 11px; color: #c5a059; text-transform: uppercase; letter-spacing: 1px; font-weight: 600;">LGC Quality Control</div>
    </div>

    <!-- KPI Metric Cards Grid -->
    <div class="kpi-grid">
        <div class="kpi-card blue">
            <span class="kpi-title">Member Complaints</span>
            <div class="kpi-val-container">
                <div class="kpi-value"><asp:Literal ID="litMemberComplaints" runat="server" Text="0" /></div>
            </div>
            <span class="kpi-desc"><i class="fas fa-exclamation-circle" style="color: #3b82f6;"></i> Submissions by Club Members</span>
        </div>
        <div class="kpi-card purple">
            <span class="kpi-title">Member Feedbacks</span>
            <div class="kpi-val-container">
                <div class="kpi-value"><asp:Literal ID="litMemberFeedbacks" runat="server" Text="0" /></div>
            </div>
            <span class="kpi-desc"><i class="fas fa-comment-dots" style="color: #8b5cf6;"></i> Feedback & Survey Entries</span>
        </div>
        <div class="kpi-card rose">
            <span class="kpi-title">Pending Resolution</span>
            <div class="kpi-val-container">
                <div class="kpi-value" style="color: #ef4444;"><asp:Literal ID="litPendingCount" runat="server" Text="0" /></div>
            </div>
            <span class="kpi-desc"><i class="fas fa-clock" style="color: #ef4444;"></i> Awaiting Initial Action</span>
        </div>
        <div class="kpi-card amber">
            <span class="kpi-title">In Progress Cases</span>
            <div class="kpi-val-container">
                <div class="kpi-value" style="color: #f59e0b;"><asp:Literal ID="litProgressCount" runat="server" Text="0" /></div>
            </div>
            <span class="kpi-desc"><i class="fas fa-spinner fa-spin" style="color: #f59e0b;"></i> Under Active Review</span>
        </div>
        <div class="kpi-card emerald">
            <span class="kpi-title">Resolution Rate</span>
            <div class="kpi-val-container">
                <div class="kpi-value" style="color: #10b981;"><asp:Literal ID="litResolutionRate" runat="server" Text="0%" /></div>
            </div>
            <span class="kpi-desc"><i class="fas fa-check-circle" style="color: #10b981;"></i> Resolved / Closed Cases</span>
        </div>
    </div>

    <!-- Charts Layout Section 1 -->
    <div class="charts-row-top">
        <!-- Monthly Trend Chart -->
        <div class="chart-container">
            <div class="chart-header">
                <h3 class="chart-title">Submission Trend (Last 6 Months)</h3>
                <span style="font-size: 11px; color: #64748b; font-weight: 500; background-color: #f1f5f9; padding: 4px 8px; border-radius: 4px;">Monthly Volume</span>
            </div>
            <div class="chart-canvas-wrapper">
                <canvas id="trendChart"></canvas>
            </div>
        </div>

        <!-- Status Breakdown Chart -->
        <div class="chart-container">
            <div class="chart-header">
                <h3 class="chart-title">Status Distribution</h3>
                <span style="font-size: 11px; color: #64748b; font-weight: 500; background-color: #f1f5f9; padding: 4px 8px; border-radius: 4px;">Overall Summary</span>
            </div>
            <div class="chart-canvas-wrapper">
                <canvas id="statusChart"></canvas>
            </div>
        </div>
    </div>

    <!-- Charts Layout Section 2 -->
    <div class="charts-row-bottom">
        <!-- Top Departments Chart -->
        <div class="chart-container">
            <div class="chart-header">
                <h3 class="chart-title">Department Hotspots</h3>
                <span style="font-size: 11px; color: #ef4444; font-weight: 600; background-color: #fee2e2; padding: 4px 8px; border-radius: 4px;">Top 5 Departments</span>
            </div>
            <div class="chart-canvas-wrapper">
                <canvas id="deptChart"></canvas>
            </div>
        </div>

        <!-- Recent Member Submissions Grid -->
        <div class="chart-container">
            <div class="chart-header">
                <h3 class="chart-title">Recent Submissions (Last 5 Entries)</h3>
                <asp:HyperLink runat="server" NavigateUrl="~/Complaint/ComplaintPanel.aspx" style="font-size: 12px; font-weight: 600; color: #c5a059; text-decoration: none; display: flex; align-items: center; gap: 4px;">
                    <span>View All Panels</span>
                    <i class="fas fa-arrow-right" style="font-size: 10px;"></i>
                </asp:HyperLink>
            </div>
            <div style="flex-grow: 1; overflow-x: auto; -webkit-overflow-scrolling: touch; width: 100%;">
                <asp:GridView ID="gvRecentComplaints" runat="server" AutoGenerateColumns="false" GridLines="None"
                    OnRowCommand="gvRecentComplaints_RowCommand"
                    style="width: 100%; border-collapse: collapse; font-size: 12.5px; color: #1e293b; border: none; margin: 0;">
                    <HeaderStyle CssClass="gv-header" />
                    <RowStyle CssClass="gv-row" />
                    <AlternatingRowStyle CssClass="gv-alt-row" />
                    <Columns>
                        <asp:TemplateField HeaderText="Type">
                            <HeaderStyle CssClass="gv-header-left" Width="95px" />
                            <ItemStyle CssClass="gv-text-left" Width="95px" />
                            <ItemTemplate>
                                <span class='type-badge <%# Eval("RecordType").ToString().ToLower() %>'>
                                    <%# Eval("RecordType") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Date">
                            <HeaderStyle CssClass="gv-header-left" Width="100px" />
                            <ItemStyle CssClass="gv-text-left" Width="100px" />
                            <ItemTemplate>
                                <%# Convert.ToDateTime(Eval("CreatedDate")).ToString("dd-MMM hh:mm tt") %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Dept">
                            <HeaderStyle CssClass="gv-header-left" Width="110px" />
                            <ItemStyle CssClass="gv-text-left" Width="110px" />
                            <ItemTemplate>
                                <span style="font-weight: 600; color: #0f1e36;"><%# Eval("DepartmentName") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Subject / Sender">
                            <HeaderStyle CssClass="gv-header-left" />
                            <ItemStyle CssClass="gv-text-left" />
                            <ItemTemplate>
                                <div style="font-weight: 600; color: #0f1e36;"><%# Eval("Subject") %></div>
                                <div style="font-size: 11px; color: #64748b; margin-top: 2px;">
                                    By: <%# Eval("SenderName") %> <%# Eval("MemberNo") != DBNull.Value && !string.IsNullOrEmpty(Eval("MemberNo").ToString()) ? "(" + Eval("MemberNo") + ")" : "" %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Status">
                            <HeaderStyle CssClass="gv-header-left" Width="100px" />
                            <ItemStyle CssClass="gv-text-left" Width="100px" />
                            <ItemTemplate>
                                <span class='status-badge <%# Eval("Status").ToString() == "Pending" ? "pending" : (Eval("Status").ToString() == "In Progress" ? "progress" : (Eval("Status").ToString() == "Resolved" ? "resolved" : "closed")) %>'>
                                    <%# Eval("Status") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Action">
                            <HeaderStyle CssClass="gv-header-left" Width="80px" />
                            <ItemStyle CssClass="gv-text-left" Width="80px" />
                            <ItemTemplate>
                                <div style="text-align: center;">
                                    <asp:LinkButton ID="lnkManage" runat="server" CommandName="ViewDetails" CommandArgument='<%# Eval("RecordType") + "|" + Eval("ID") %>' style="text-decoration: none; font-size: 12px; font-weight: 700; color: #c5a059;">
                                        <i class="fas fa-edit"></i>
                                    </asp:LinkButton>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="padding: 20px; text-align: center; color: #64748b;">No member complaints or feedback submitted yet.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </div>

    <!-- Chart.js and Dashboard Init Script -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            // Parse JSON Chart Data passed from Code-behind
            var trendLabels = <%= TrendLabelsJson %>;
            var memberTrendData = <%= MemberTrendDataJson %>;
            var feedbackTrendData = <%= FeedbackTrendDataJson %>;

            var statusLabels = <%= StatusLabelsJson %>;
            var statusData = <%= StatusDataJson %>;

            var deptLabels = <%= DeptLabelsJson %>;
            var deptData = <%= DeptDataJson %>;

            // ══════════════════════════════════════════════════════════
            // 1. TREND LINE/BAR CHART (Complaints vs Feedbacks)
            // ═══════════════════════════════════════════════════════════
            var trendCtx = document.getElementById('trendChart').getContext('2d');
            new Chart(trendCtx, {
                type: 'bar',
                data: {
                    labels: trendLabels,
                    datasets: [
                        {
                            label: 'Member Complaints',
                            data: memberTrendData,
                            backgroundColor: 'rgba(59, 130, 246, 0.75)',
                            borderColor: 'rgba(59, 130, 246, 1)',
                            borderWidth: 1,
                            borderRadius: 4
                        },
                        {
                            label: 'Member Feedbacks',
                            data: feedbackTrendData,
                            backgroundColor: 'rgba(139, 92, 246, 0.75)',
                            borderColor: 'rgba(139, 92, 246, 1)',
                            borderWidth: 1,
                            borderRadius: 4
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                precision: 0,
                                color: '#64748b',
                                font: { family: "'Outfit', sans-serif" }
                            },
                            grid: { color: '#f1f5f9' }
                        },
                        x: {
                            ticks: {
                                color: '#64748b',
                                font: { family: "'Outfit', sans-serif" }
                            },
                            grid: { display: false }
                        }
                    },
                    plugins: {
                        legend: {
                            position: 'top',
                            labels: {
                                font: { family: "'Outfit', sans-serif', font-weight: 500" },
                                color: '#1e293b'
                            }
                        },
                        tooltip: {
                            padding: 10,
                            titleFont: { family: "'Outfit', sans-serif", weight: 'bold' },
                            bodyFont: { family: "'Outfit', sans-serif" }
                        }
                    }
                }
            });

            // ══════════════════════════════════════════════════════════
            // 2. STATUS DOUGHNUT CHART
            // ═══════════════════════════════════════════════════════════
            var statusCtx = document.getElementById('statusChart').getContext('2d');
            new Chart(statusCtx, {
                type: 'doughnut',
                data: {
                    labels: statusLabels,
                    datasets: [{
                        data: statusData,
                        backgroundColor: [
                            'rgba(244, 63, 94, 0.85)',   // Pending (Rose)
                            'rgba(245, 158, 11, 0.85)',  // In Progress (Amber)
                            'rgba(16, 185, 129, 0.85)',  // Resolved (Emerald)
                            'rgba(100, 116, 139, 0.85)'  // Closed (Slate)
                        ],
                        borderColor: '#ffffff',
                        borderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: '65%',
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                boxWidth: 12,
                                font: { family: "'Outfit', sans-serif", size: 11 },
                                color: '#475569',
                                padding: 14
                            }
                        },
                        tooltip: {
                            padding: 10,
                            titleFont: { family: "'Outfit', sans-serif" },
                            bodyFont: { family: "'Outfit', sans-serif" }
                        }
                    }
                }
            });

            // ══════════════════════════════════════════════════════════
            // 3. DEPARTMENTS HORIZONTAL BAR CHART
            // ═══════════════════════════════════════════════════════════
            var deptCtx = document.getElementById('deptChart').getContext('2d');
            new Chart(deptCtx, {
                type: 'bar',
                data: {
                    labels: deptLabels,
                    datasets: [{
                        label: 'Total Submissions',
                        data: deptData,
                        backgroundColor: 'rgba(15, 30, 54, 0.85)',
                        hoverBackgroundColor: 'rgba(197, 160, 89, 0.95)',
                        borderColor: '#0f1e36',
                        borderWidth: 1,
                        borderRadius: 6
                    }]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        x: {
                            beginAtZero: true,
                            ticks: {
                                precision: 0,
                                color: '#64748b',
                                font: { family: "'Outfit', sans-serif" }
                            },
                            grid: { color: '#f1f5f9' }
                        },
                        y: {
                            ticks: {
                                color: '#0f1e36',
                                font: { family: "'Outfit', sans-serif', font-weight: 600" }
                            },
                            grid: { display: false }
                        }
                    },
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            padding: 10,
                            titleFont: { family: "'Outfit', sans-serif" },
                            bodyFont: { family: "'Outfit', sans-serif" }
                        }
                    }
                }
            });
        });
    </script>
</asp:Content>
