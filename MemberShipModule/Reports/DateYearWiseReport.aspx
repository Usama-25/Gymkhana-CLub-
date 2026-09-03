<%@ Page Title="Date / Year-Wise Receipt Report" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true"
    CodeFile="DateYearWiseReport.aspx.cs" Inherits="Membership.Reports.DateYearWiseReport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        .report-card {
            background: #ffffff;
            border-radius: 16px;
            border: 1px solid #e0d5c5;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
            padding: 1.5rem;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .report-card:hover {
            box-shadow: 0 6px 24px rgba(0, 0, 0, 0.06);
        }
        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
        }
        .btn-gold {
            background: linear-gradient(135deg, #c5a059, #8B5E3C);
            color: #ffffff;
            border: none;
            padding: 0.625rem 1.25rem;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: opacity 0.2s ease;
            text-decoration: none;
        }
        .btn-gold:hover {
            opacity: 0.92;
            color: #ffffff;
        }
        .btn-outline {
            background: #ffffff;
            color: #1A1A2E;
            border: 1px solid #e0d5c5;
            padding: 0.625rem 1.25rem;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            text-decoration: none;
        }
        .btn-outline:hover {
            background: #faf7f2;
        }
        .badge-balance-zero {
            background: #dcfce7;
            color: #166534;
            padding: 4px 10px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.82rem;
            display: inline-block;
        }
        .badge-balance-pending {
            background: #fee2e2;
            color: #991b1b;
            padding: 4px 10px;
            border-radius: 20px;
            font-weight: 700;
            font-size: 0.82rem;
            display: inline-block;
        }
        .receipt-chip {
            background: #f1f5f9;
            color: #0f172a;
            border: 1px solid #cbd5e1;
            padding: 3px 8px;
            border-radius: 6px;
            font-size: 0.8rem;
            display: inline-block;
            margin: 2px 0;
            font-family: monospace;
        }
        .custom-pager table {
            margin: 0 auto;
        }
        .custom-pager td {
            padding: 4px;
            border: none !important;
        }
        .custom-pager a, .custom-pager span {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 6px;
            font-weight: 600;
            text-decoration: none;
            font-size: 0.88rem;
        }
        .custom-pager a {
            background: #ffffff;
            color: #0f1e36;
            border: 1px solid #cbd5e1;
        }
        .custom-pager a:hover {
            background: #f1f5f9;
            color: #c5a059;
            border-color: #c5a059;
        }
        .custom-pager span {
            background: #0f1e36;
            color: #ffffff;
            border: 1px solid #0f1e36;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div style="width: 100%; margin: 0 auto; padding: 1.5rem; box-sizing: border-box;">
        
        <!-- Header Banner -->
        <div style="background: white; border-radius: 16px; padding: 2rem; margin-bottom: 2rem; border: 1px solid #e0d5c5; box-shadow: 0 2px 10px rgba(0,0,0,0.03); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
            <div>
                <h1 style="font-size: 1.875rem; font-weight: 700; color: #1A1A2E; margin: 0;">Date / Year-Wise Receipt Report</h1>
                <p style="color: #8B5E3C; margin: 0.4rem 0 0 0; font-size: 0.95rem;">Search and view attached receipts, fee structure, and balance details by Date Range or Year</p>
            </div>
            <div style="display: flex; gap: 0.75rem; align-items: center;">
                <asp:LinkButton ID="btnExportExcel" runat="server" OnClick="btnExportExcel_Click" CssClass="btn-outline">
                    <i class="fas fa-file-excel" style="color: #16a34a;"></i> Export Excel
                </asp:LinkButton>
                <asp:LinkButton ID="btnPrintReport" runat="server" OnClick="btnPrintReport_Click" CssClass="btn-gold">
                    <i class="fas fa-print"></i> Print Report
                </asp:LinkButton>
            </div>
        </div>

        <!-- Summary Statistics Cards -->
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1.25rem; margin-bottom: 1.75rem;">
            <div class="report-card" style="display: flex; align-items: center; gap: 1rem;">
                <div class="stat-icon" style="background: #f5ecd5; color: #C9A84C;">
                    <i class="fas fa-calendar-check"></i>
                </div>
                <div>
                    <h4 style="margin: 0; font-size: 0.85rem; color: #8B5E3C; font-weight: 500;">Total Entries</h4>
                    <span style="font-size: 1.4rem; font-weight: 700; color: #1A1A2E;"><asp:Literal ID="litTotalApplicants" runat="server">0</asp:Literal></span>
                </div>
            </div>

            <div class="report-card" style="display: flex; align-items: center; gap: 1rem;">
                <div class="stat-icon" style="background: #e0f2fe; color: #0284c7;">
                    <i class="fas fa-file-invoice-dollar"></i>
                </div>
                <div>
                    <h4 style="margin: 0; font-size: 0.85rem; color: #8B5E3C; font-weight: 500;">Total Form Fee</h4>
                    <span style="font-size: 1.3rem; font-weight: 700; color: #1A1A2E;">Rs. <asp:Literal ID="litTotalFormFee" runat="server">0</asp:Literal></span>
                </div>
            </div>

            <div class="report-card" style="display: flex; align-items: center; gap: 1rem;">
                <div class="stat-icon" style="background: #fef3c7; color: #d97706;">
                    <i class="fas fa-id-card"></i>
                </div>
                <div>
                    <h4 style="margin: 0; font-size: 0.85rem; color: #8B5E3C; font-weight: 500;">Total Membership Fee</h4>
                    <span style="font-size: 1.3rem; font-weight: 700; color: #1A1A2E;">Rs. <asp:Literal ID="litTotalMFee" runat="server">0</asp:Literal></span>
                </div>
            </div>

            <div class="report-card" style="display: flex; align-items: center; gap: 1rem;">
                <div class="stat-icon" style="background: #dcfce7; color: #16a34a;">
                    <i class="fas fa-receipt"></i>
                </div>
                <div>
                    <h4 style="margin: 0; font-size: 0.85rem; color: #8B5E3C; font-weight: 500;">Total Paid Amount</h4>
                    <span style="font-size: 1.3rem; font-weight: 700; color: #16a34a;">Rs. <asp:Literal ID="litTotalPaid" runat="server">0</asp:Literal></span>
                </div>
            </div>

            <div class="report-card" style="display: flex; align-items: center; gap: 1rem;">
                <div class="stat-icon" style="background: #fee2e2; color: #dc2626;">
                    <i class="fas fa-balance-scale-right"></i>
                </div>
                <div>
                    <h4 style="margin: 0; font-size: 0.85rem; color: #8B5E3C; font-weight: 500;">Total Balance Pending</h4>
                    <span style="font-size: 1.3rem; font-weight: 700; color: #dc2626;">Rs. <asp:Literal ID="litTotalBalance" runat="server">0</asp:Literal></span>
                </div>
            </div>
        </div>

        <!-- Filter Panel -->
        <div style="background: white; padding: 1.5rem; border-radius: 16px; border: 1px solid #e0d5c5; box-shadow: 0 2px 10px rgba(0,0,0,0.03); margin-bottom: 2rem;">
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.25rem; align-items: end;">
                <div>
                    <label style="display: block; font-size: 0.85rem; font-weight: 600; color: #1A1A2E; margin-bottom: 0.4rem;">From Date</label>
                    <asp:TextBox ID="txtFromDate" runat="server" TextMode="Date" CssClass="form-control"
                        style="width: 100%; height: 42px; padding: 0.5rem 1rem; border-radius: 8px; border: 1px solid #e0d5c5; font-size: 0.95rem; box-sizing: border-box;" />
                </div>
                <div>
                    <label style="display: block; font-size: 0.85rem; font-weight: 600; color: #1A1A2E; margin-bottom: 0.4rem;">To Date</label>
                    <asp:TextBox ID="txtToDate" runat="server" TextMode="Date" CssClass="form-control"
                        style="width: 100%; height: 42px; padding: 0.5rem 1rem; border-radius: 8px; border: 1px solid #e0d5c5; font-size: 0.95rem; box-sizing: border-box;" />
                </div>
                <div>
                    <label style="display: block; font-size: 0.85rem; font-weight: 600; color: #1A1A2E; margin-bottom: 0.4rem;">Select Year</label>
                    <asp:DropDownList ID="ddlYear" runat="server" CssClass="form-control"
                        style="width: 100%; height: 42px; padding: 0.5rem 1rem; border-radius: 8px; border: 1px solid #e0d5c5; font-size: 0.95rem; box-sizing: border-box;">
                    </asp:DropDownList>
                </div>
                <div style="display: flex; gap: 0.5rem;">
                    <asp:Button ID="btnSearch" runat="server" Text="Search Report" OnClick="btnSearch_Click" CssClass="btn-gold" style="height: 42px; border-radius: 8px; flex: 1;" />
                    <asp:Button ID="btnClear" runat="server" Text="Reset" OnClick="btnClear_Click" CssClass="btn-outline" style="height: 42px; border-radius: 8px;" />
                </div>
            </div>
        </div>

        <!-- Grid Results -->
        <div style="background: white; border-radius: 16px; border: 1px solid #e0d5c5; box-shadow: 0 2px 10px rgba(0,0,0,0.03); overflow: hidden;">
            <asp:GridView ID="gvReport" runat="server" AutoGenerateColumns="False"
                GridLines="None" Width="100%"
                AllowPaging="True" PageSize="100" OnPageIndexChanging="gvReport_PageIndexChanging"
                OnRowDataBound="gvReport_RowDataBound"
                EmptyDataText="No applicant receipt records found matching your selected date/year criteria."
                style="border-collapse: collapse;">
                <HeaderStyle BackColor="#0f1e36" Font-Bold="True" ForeColor="#ffffff" 
                    Height="48px" HorizontalAlign="Left" />
                <RowStyle Height="54px" BorderColor="#e2e8f0" BorderStyle="Solid" BorderWidth="1px" />
                <AlternatingRowStyle BackColor="#f8fafc" />
                <PagerSettings Mode="NumericFirstLast" PageButtonCount="10" FirstPageText="&laquo; First" LastPageText="Last &raquo;" NextPageText="Next &rsaquo;" PreviousPageText="&lsaquo; Prev" />
                <PagerStyle CssClass="custom-pager" HorizontalAlign="Center" BackColor="#f8fafc" Height="50px" />
                <Columns>
                    <asp:BoundField DataField="SrNo" HeaderText="Sr#" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                    
                    <asp:TemplateField HeaderText="ApplicantNo">
                        <ItemTemplate>
                            <span style="font-weight: 700; color: #c5a059; font-family: monospace; font-size: 0.95rem;">
                                <%# Eval("ApplicantNo") %>
                            </span>
                        </ItemTemplate>
                        <HeaderStyle Width="110px" />
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Applicant Name">
                        <ItemTemplate>
                            <div style="font-weight: 600; color: #0f172a;"><%# Eval("ApplicantName") %></div>
                            <div style="font-size: 0.8rem; color: #64748b;">
                                App Date: <%# Eval("ApplicationDate", "{0:dd-MMM-yyyy}") %> | CNIC: <%# Eval("CNIC") %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Receipt No & Details">
                        <ItemTemplate>
                            <asp:Literal ID="litAttachedReceipts" runat="server"></asp:Literal>
                        </ItemTemplate>
                        <HeaderStyle Width="220px" />
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Form Fee">
                        <ItemTemplate>
                            Rs. <%# Eval("FormFee", "{0:N0}") %>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" Width="100px" />
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Advance / MemberShip Fee">
                        <ItemTemplate>
                            Rs. <%# Eval("AdvanceOrMembershipFee", "{0:N0}") %>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" Width="160px" />
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Total Amount">
                        <ItemTemplate>
                            <span style="font-weight: 700; color: #0f172a;">Rs. <%# Eval("TotalAmount", "{0:N0}") %></span>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" Width="130px" />
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Balance / Remaining">
                        <ItemTemplate>
                            <asp:Literal ID="litBalance" runat="server"></asp:Literal>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" Width="140px" />
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div style="padding: 3rem 2rem; text-align: center; color: #64748b;">
                        <i class="fas fa-calendar-alt" style="font-size: 2.5rem; margin-bottom: 0.75rem; opacity: 0.4;"></i>
                        <h3 style="margin: 0; font-size: 1.1rem; font-weight: 600;">No Date/Year Records Found</h3>
                        <p style="margin-top: 0.3rem;">Use the date filters above to query applicant receipts.</p>
                    </div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>

    </div>
</asp:Content>
