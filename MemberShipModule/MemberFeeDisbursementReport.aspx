<%@ Page Title="Member Fee Disbursement Report" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true"
    CodeFile="MemberFeeDisbursementReport.aspx.cs" Inherits="Membership.MemberFeeDisbursementReport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <style>
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif !important;
            background-color: #faf7f2 !important;
            color: #1e293b !important;
            margin: 0 !important;
            padding: 0 !important;
        }

        /* Pager link styling */
        .custom-pager table { 
            margin: 0 auto !important; 
        }
        .custom-pager td { 
            padding: 2px 4px !important; 
            border: none !important; 
            background: transparent !important;
        }
        .custom-pager a, .custom-pager span {
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            min-width: 30px !important;
            height: 30px !important;
            padding: 0 8px !important;
            border-radius: 5px !important;
            font-weight: 600 !important;
            text-decoration: none !important;
            font-size: 0.78rem !important;
            transition: all 0.15s ease !important;
            box-sizing: border-box !important;
        }
        .custom-pager a {
            background: #ffffff !important;
            color: #0f1e36 !important;
            border: 1px solid #cbd5e1 !important;
        }
        .custom-pager a:hover {
            background: #f1f5f9 !important;
            color: #8B5E3C !important;
            border-color: #C9A84C !important;
        }
        .custom-pager span {
            background: #0f1e36 !important;
            color: #ffffff !important;
            border: 1px solid #0f1e36 !important;
            box-shadow: 0 1px 3px rgba(15, 30, 54, 0.25) !important;
        }

        .print-only { display: none !important; }

        /* Print and PDF Document Styling */
        @media print {
            @page { 
                size: A4 portrait; 
                margin: 10mm 12mm 15mm 12mm; 
            }
            body { 
                background: #ffffff !important; 
                font-size: 10pt !important; 
                color: #000000 !important;
                margin: 0 !important;
                padding: 0 !important;
            }
            header, aside, .sidebar, .sidebar-module, .navbar, #filterPanel, #pnlConversionSuccess, #pnlHeadCards, #pnlKPIs, .custom-pager, .no-print, .no-print * {
                display: none !important;
            }
            .print-only {
                display: block !important;
            }
            #printableReportSection {
                box-shadow: none !important;
                border: none !important;
                padding: 0 !important;
                margin: 0 !important;
                width: 100% !important;
            }
            table {
                width: 100% !important;
                border-collapse: collapse !important;
                page-break-inside: auto !important;
            }
            tr {
                page-break-inside: avoid !important;
            }
            thead {
                display: table-header-group !important;
            }
            th {
                background-color: #0f1e36 !important;
                color: #ffffff !important;
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
                border: 1px solid #0f1e36 !important;
                font-size: 9.5pt !important;
                padding: 6px 8px !important;
            }
            td {
                border: 1px solid #cbd5e1 !important;
                font-size: 9pt !important;
                padding: 6px 8px !important;
                color: #000000 !important;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div style="width: 100%; margin: 0 auto; padding: 1.25rem; box-sizing: border-box; font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background-color: #faf7f2; min-height: 100vh;">

        <!-- Print-only Clean Official Document Header (No KPIs, Pure Report Format) -->
        <div id="printReportHeader" class="print-only" style="margin-bottom: 18px; text-align: center; border-bottom: 2px solid #0f1e36; padding-bottom: 10px; box-sizing: border-box;">
            <h2 style="margin: 0; font-size: 20pt; font-weight: 800; color: #0f1e36; text-transform: uppercase; letter-spacing: 0.5px; font-family: 'Outfit', sans-serif;">Lahore Gymkhana Club</h2>
            <h3 style="margin: 3px 0 0 0; font-size: 13pt; font-weight: 700; color: #8B5E3C;">Member Fee Disbursement &amp; Head Allocation Report</h3>
            <div style="margin-top: 5px; font-size: 9pt; color: #475569; display: flex; justify-content: space-between; border-top: 1px solid #e2e8f0; padding-top: 4px; box-sizing: border-box;">
                <span style="font-weight: 600;">Report Scope: Grouped by Member</span>
                <span style="font-weight: 600;">Generated On: <%= DateTime.Now.ToString("dd-MMM-yyyy hh:mm tt") %></span>
            </div>
        </div>
        
        <!-- Header Banner Section (Warm Gymkhana Theme with Enforced Inline CSS) -->
        <div class="no-print" style="background: #ffffff; border-radius: 8px; padding: 1rem 1.25rem; margin-bottom: 1rem; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.025); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 0.75rem; box-sizing: border-box;">
            <div style="box-sizing: border-box;">
                <div style="display: flex; align-items: center; gap: 8px; box-sizing: border-box;">
                    <a href="SearchInterviewResult.aspx" style="background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; padding: 0.3rem 0.75rem; border-radius: 5px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; text-decoration: none; font-size: 0.78rem; box-sizing: border-box;">
                        &larr; Back to Interview Results
                    </a>
                    <span style="background: #ecfdf5; color: #059669; border: 1px solid #a7f3d0; padding: 2px 8px; border-radius: 12px; font-size: 11px; font-weight: 700; display: inline-block; box-sizing: border-box;">
                        Finance Audit &amp; Reconciliation
                    </span>
                </div>
                <div style="margin-top: 0.35rem; box-sizing: border-box;">
                    <h1 style="font-size: 1.35rem; font-weight: 700; color: #1A1A2E; margin: 0; font-family: 'Outfit', sans-serif; letter-spacing: -0.01em;">
                        Fee Disbursement Report
                    </h1>
                    <p style="color: #8B5E3C; margin: 0.15rem 0 0 0; font-size: 0.82rem; font-weight: 500;">
                        Consolidated records grouped by <strong style="color: #1A1A2E;">Application No, Member No, Name, CNIC &amp; Total Amount</strong>
                    </p>
                </div>
            </div>
            <div style="display: flex; gap: 0.5rem; align-items: center; flex-wrap: wrap; box-sizing: border-box;">
                <asp:LinkButton ID="btnExportExcel" runat="server" OnClick="btnExportExcel_Click"
                    style="background: #ffffff; color: #1A1A2E; border: 1px solid #e0d5c5; padding: 0.45rem 0.95rem; border-radius: 6px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; text-decoration: none; font-size: 0.82rem; box-sizing: border-box; box-shadow: 0 1px 2px rgba(0,0,0,0.03);">
                    Export to Excel
                </asp:LinkButton>
                <asp:LinkButton ID="btnPrintReport" runat="server" OnClick="btnPrintReport_Click"
                    style="background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: #ffffff; border: none; padding: 0.45rem 1rem; border-radius: 6px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; text-decoration: none; font-size: 0.82rem; box-sizing: border-box; box-shadow: 0 1px 3px rgba(139, 94, 60, 0.25);">
                    Print Report / PDF
                </asp:LinkButton>
            </div>
        </div>

        <!-- Success/Alert Notice if redirected after member conversion -->
        <asp:Panel ID="pnlConversionSuccess" runat="server" Visible="false"
            style="background: linear-gradient(135deg, #ecfdf5, #d1fae5); border: 1.5px solid #10b981; border-radius: 6px; padding: 10px 14px; margin-bottom: 1rem; display: flex; align-items: center; justify-content: space-between; gap: 10px; box-sizing: border-box;">
            <div style="box-sizing: border-box;">
                <h4 style="margin: 0; font-size: 13.5px; font-weight: 700; color: #065f46;">Member Converted &amp; Fee Distributed Successfully!</h4>
                <p style="margin: 2px 0 0 0; font-size: 12px; color: #047857;">
                    <asp:Literal ID="litSuccessDetails" runat="server" />
                </p>
            </div>
            <a href="MemberFeeDisbursementReport.aspx" style="color: #065f46; font-weight: 700; text-decoration: underline; font-size: 12px;">View All</a>
        </asp:Panel>

        <!-- Compact Filter Panel (Enforced Inline Styling) -->
        <div id="filterPanel" class="no-print" style="background: #ffffff; padding: 1rem 1.25rem; border-radius: 8px; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.025); margin-bottom: 1rem; box-sizing: border-box;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.75rem; border-bottom: 1px solid #f1e9dd; padding-bottom: 0.4rem; box-sizing: border-box;">
                <div style="font-weight: 700; font-size: 0.88rem; color: #1A1A2E; text-transform: uppercase; letter-spacing: 0.03em;">
                    Search &amp; Filter Criteria
                </div>
                <div style="font-size: 0.76rem; color: #8B5E3C;">
                    Enter search criteria and click <strong>'Filter Report'</strong> to display records
                </div>
            </div>

            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(145px, 1fr)); gap: 0.75rem; align-items: end; box-sizing: border-box;">
                <div style="box-sizing: border-box;">
                    <label style="display: block; font-size: 0.72rem; font-weight: 700; color: #1A1A2E; margin-bottom: 0.25rem; text-transform: uppercase; letter-spacing: 0.03em;">
                        Member No
                    </label>
                    <asp:TextBox ID="txtMemberNo" runat="server" placeholder="e.g. I-1042"
                        style="width: 100%; height: 34px; padding: 0 0.6rem; border-radius: 5px; border: 1.5px solid #e0d5c5; font-size: 0.82rem; box-sizing: border-box; background-color: #ffffff; color: #1e293b; outline: none; font-family: inherit;" />
                </div>
                <div style="box-sizing: border-box;">
                    <label style="display: block; font-size: 0.72rem; font-weight: 700; color: #1A1A2E; margin-bottom: 0.25rem; text-transform: uppercase; letter-spacing: 0.03em;">
                        Application No
                    </label>
                    <asp:TextBox ID="txtApplicationNo" runat="server" placeholder="e.g. 520"
                        style="width: 100%; height: 34px; padding: 0 0.6rem; border-radius: 5px; border: 1.5px solid #e0d5c5; font-size: 0.82rem; box-sizing: border-box; background-color: #ffffff; color: #1e293b; outline: none; font-family: inherit;" />
                </div>
                <div style="box-sizing: border-box;">
                    <label style="display: block; font-size: 0.72rem; font-weight: 700; color: #1A1A2E; margin-bottom: 0.25rem; text-transform: uppercase; letter-spacing: 0.03em;">
                        CNIC / NIC
                    </label>
                    <asp:TextBox ID="txtCNIC" runat="server" placeholder="35201-xxxxxxx-x"
                        style="width: 100%; height: 34px; padding: 0 0.6rem; border-radius: 5px; border: 1.5px solid #e0d5c5; font-size: 0.82rem; box-sizing: border-box; background-color: #ffffff; color: #1e293b; outline: none; font-family: inherit;" />
                </div>
                <div style="box-sizing: border-box;">
                    <label style="display: block; font-size: 0.72rem; font-weight: 700; color: #1A1A2E; margin-bottom: 0.25rem; text-transform: uppercase; letter-spacing: 0.03em;">
                        Member / Applicant Name
                    </label>
                    <asp:TextBox ID="txtMemberName" runat="server" placeholder="Search by name"
                        style="width: 100%; height: 34px; padding: 0 0.6rem; border-radius: 5px; border: 1.5px solid #e0d5c5; font-size: 0.82rem; box-sizing: border-box; background-color: #ffffff; color: #1e293b; outline: none; font-family: inherit;" />
                </div>
                <div style="box-sizing: border-box;">
                    <label style="display: block; font-size: 0.72rem; font-weight: 700; color: #1A1A2E; margin-bottom: 0.25rem; text-transform: uppercase; letter-spacing: 0.03em;">
                        Finance Head
                    </label>
                    <asp:DropDownList ID="ddlFinanceHead" runat="server"
                        style="width: 100%; height: 34px; padding: 0 0.5rem; border-radius: 5px; border: 1.5px solid #e0d5c5; font-size: 0.82rem; box-sizing: border-box; background-color: #ffffff; color: #1e293b; outline: none; font-family: inherit;" />
                </div>
                <div style="box-sizing: border-box;">
                    <label style="display: block; font-size: 0.72rem; font-weight: 700; color: #1A1A2E; margin-bottom: 0.25rem; text-transform: uppercase; letter-spacing: 0.03em;">
                        From Date
                    </label>
                    <asp:TextBox ID="txtFromDate" runat="server" TextMode="Date"
                        style="width: 100%; height: 34px; padding: 0 0.5rem; border-radius: 5px; border: 1.5px solid #e0d5c5; font-size: 0.82rem; box-sizing: border-box; background-color: #ffffff; color: #1e293b; outline: none; font-family: inherit;" />
                </div>
                <div style="box-sizing: border-box;">
                    <label style="display: block; font-size: 0.72rem; font-weight: 700; color: #1A1A2E; margin-bottom: 0.25rem; text-transform: uppercase; letter-spacing: 0.03em;">
                        To Date
                    </label>
                    <asp:TextBox ID="txtToDate" runat="server" TextMode="Date"
                        style="width: 100%; height: 34px; padding: 0 0.5rem; border-radius: 5px; border: 1.5px solid #e0d5c5; font-size: 0.82rem; box-sizing: border-box; background-color: #ffffff; color: #1e293b; outline: none; font-family: inherit;" />
                </div>
                <div style="display: flex; gap: 0.4rem; box-sizing: border-box;">
                    <asp:Button ID="btnSearch" runat="server" Text="Filter Report" OnClick="btnSearch_Click"
                        style="height: 34px; flex: 1; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: #ffffff; border: none; border-radius: 5px; font-weight: 600; cursor: pointer; font-size: 0.82rem; box-sizing: border-box; box-shadow: 0 1px 2px rgba(0,0,0,0.05);" />
                    <asp:Button ID="btnClear" runat="server" Text="Reset" OnClick="btnClear_Click"
                        style="height: 34px; background: #ffffff; color: #1A1A2E; border: 1px solid #e0d5c5; border-radius: 5px; font-weight: 600; cursor: pointer; font-size: 0.82rem; padding: 0 0.85rem; box-sizing: border-box;" />
                </div>
            </div>
        </div>

        <!-- Unified Single-Row KPI Strip in Requested Order: 
             1. ENTRANCE FEE, 2. CONTIGENCY FUND, 3. DEVELOPMENT FUND, 4. SALE OF MEMBERSHIP FORM, 5. Total Disbursed, 6. Avg per Member -->
        <asp:Panel ID="pnlKPIs" runat="server" Visible="false" class="no-print" style="margin-bottom: 0.85rem; box-sizing: border-box;">
            <div style="display: flex; gap: 6px; overflow-x: auto; padding-bottom: 2px; box-sizing: border-box;">
                <!-- 1 to 4 Finance Head Subtotals (ENTRANCE FEE, CONTIGENCY FUND, DEVELOPMENT FUND, SALE OF MEMBERSHIP FORM, etc.) -->
                <asp:Repeater ID="rptHeadCards" runat="server">
                    <ItemTemplate>
                        <div style="background: #ffffff; border-radius: 5px; border: 1px solid #e0d5c5; border-left: 3.5px solid #C9A84C; padding: 5px 9px; min-width: 135px; flex: 1; display: flex; flex-direction: column; justify-content: space-between; box-shadow: 0 1px 2px rgba(0,0,0,0.02); box-sizing: border-box;">
                            <div style="display: flex; justify-content: space-between; align-items: center; gap: 4px; margin-bottom: 1px; box-sizing: border-box;">
                                <span style="font-size: 0.7rem; font-weight: 700; color: #1e293b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title='<%# Eval("HeadType") %>'>
                                    <%# Eval("HeadType") %>
                                </span>
                                <span style="font-size: 0.66rem; font-weight: 700; color: #8B5E3C; background: #faf7f2; border: 1px solid #e0d5c5; border-radius: 3px; padding: 0.5px 4px; white-space: nowrap; display: inline-block;">
                                    <%# string.Format("{0:F1}%", Eval("Percentage")) %>
                                </span>
                            </div>
                            <div style="font-size: 0.94rem; font-weight: 800; color: #16a34a; margin: 1px 0; white-space: nowrap;">
                                Rs. <%# string.Format("{0:N0}", Eval("TotalAmount")) %>
                            </div>
                            <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.66rem; color: #64748b; border-top: 1px solid #f1f5f9; padding-top: 2px; margin-top: 1px; box-sizing: border-box;">
                                <span style="background: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd; border-radius: 2px; padding: 0.5px 3.5px; font-family: monospace; font-weight: 700; display: inline-block;"><%# Eval("ECode") %></span>
                                <span><strong style="color: #1A1A2E;"><%# Eval("MemberCount") %></strong> Mem</span>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <!-- 5. Total Disbursed KPI -->
                <div style="background: #ffffff; border-radius: 5px; border: 1px solid #e0d5c5; border-top: 3.5px solid #16a34a; box-shadow: 0 1px 2px rgba(0,0,0,0.02); padding: 5px 9px; min-width: 135px; flex: 1; display: flex; flex-direction: column; justify-content: space-between; box-sizing: border-box;">
                    <div style="display: flex; justify-content: space-between; align-items: center; gap: 4px; margin-bottom: 1px; box-sizing: border-box;">
                        <span style="font-size: 0.68rem; color: #8B5E3C; font-weight: 700; text-transform: uppercase; letter-spacing: 0.02em; white-space: nowrap;">Total Disbursed</span>
                        <span style="font-size: 0.66rem; font-weight: 700; color: #16a34a; background: #ecfdf5; border: 1px solid #a7f3d0; border-radius: 3px; padding: 0.5px 4px; white-space: nowrap;">100%</span>
                    </div>
                    <div style="font-size: 0.94rem; font-weight: 800; color: #1A1A2E; margin: 1px 0; white-space: nowrap;">
                        Rs. <asp:Literal ID="litTotalDisbursed" runat="server">0</asp:Literal>
                    </div>
                    <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.66rem; color: #64748b; border-top: 1px solid #f1f5f9; padding-top: 2px; margin-top: 1px; box-sizing: border-box;">
                        <span>All Heads</span>
                        <span style="color: #1A1A2E; font-weight: 600;">Grand Total</span>
                    </div>
                </div>

                <!-- 6. Avg per Member KPI -->
                <div style="background: #ffffff; border-radius: 5px; border: 1px solid #e0d5c5; border-top: 3.5px solid #6366f1; box-shadow: 0 1px 2px rgba(0,0,0,0.02); padding: 5px 9px; min-width: 135px; flex: 1; display: flex; flex-direction: column; justify-content: space-between; box-sizing: border-box;">
                    <div style="display: flex; justify-content: space-between; align-items: center; gap: 4px; margin-bottom: 1px; box-sizing: border-box;">
                        <span style="font-size: 0.68rem; color: #8B5E3C; font-weight: 700; text-transform: uppercase; letter-spacing: 0.02em; white-space: nowrap;">Avg per Member</span>
                        <span style="font-size: 0.66rem; font-weight: 700; color: #4338ca; background: #eef2ff; border: 1px solid #c7d2fe; border-radius: 3px; padding: 0.5px 4px; white-space: nowrap;">Avg</span>
                    </div>
                    <div style="font-size: 0.94rem; font-weight: 800; color: #16a34a; margin: 1px 0; white-space: nowrap;">
                        Rs. <asp:Literal ID="litAvgPerMember" runat="server">0</asp:Literal>
                    </div>
                    <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.66rem; color: #64748b; border-top: 1px solid #f1f5f9; padding-top: 2px; margin-top: 1px; box-sizing: border-box;">
                        <span>Per Applicant</span>
                        <span style="color: #16a34a; font-weight: 600;">Allocation</span>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <!-- Printable Member Report Section (Neat, Crisp Table for Screen, Print & PDF with Enforced Inline CSS) -->
        <div id="printableReportSection" style="background: #ffffff; border-radius: 8px; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.025); overflow: hidden; box-sizing: border-box;">
            
            <!-- Toolbar & Pagination Control Header (Screen Only) -->
            <div class="no-print" style="padding: 0.75rem 1.15rem; background: #faf7f2; border-bottom: 1px solid #e0d5c5; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px; box-sizing: border-box;">
                <div style="display: flex; align-items: center; gap: 8px; box-sizing: border-box;">
                    <div style="font-weight: 700; font-size: 0.92rem; color: #1A1A2E;">
                        Member Fee Disbursement Breakdown
                    </div>
                    <span style="background: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd; font-size: 11px; font-weight: 700; padding: 1.5px 7px; border-radius: 4px; display: inline-block;">
                        Grouped by Member
                    </span>
                </div>
                
                <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap; box-sizing: border-box;">
                    <div style="display: flex; align-items: center; gap: 5px; box-sizing: border-box;">
                        <span style="font-size: 0.78rem; color: #475569; font-weight: 600;">Rows per page:</span>
                        <asp:DropDownList ID="ddlPageSize" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged"
                            style="width: 70px; height: 28px; padding: 0 3px; font-size: 0.8rem; border-radius: 4px; border: 1.5px solid #e0d5c5; background-color: #ffffff; color: #1e293b; outline: none; font-family: inherit;">
                            <asp:ListItem Text="10" Value="10" />
                            <asp:ListItem Text="25" Value="25" Selected="True" />
                            <asp:ListItem Text="50" Value="50" />
                            <asp:ListItem Text="100" Value="100" />
                            <asp:ListItem Text="All" Value="5000" />
                        </asp:DropDownList>
                    </div>

                    <div style="font-size: 0.78rem; color: #8B5E3C; font-weight: 600; background: #ffffff; padding: 3px 8px; border-radius: 4px; border: 1px solid #e0d5c5; box-sizing: border-box;">
                        <asp:Literal ID="litPageInfo" runat="server">Page 1 of 1</asp:Literal>
                        <span style="color: #cbd5e1;">&bull;</span> Total <asp:Literal ID="litRecordsCount" runat="server">0</asp:Literal> Member(s)
                    </div>
                </div>
            </div>

            <div style="overflow-x: auto; width: 100%; box-sizing: border-box;">
                <asp:GridView ID="gvDisbursement" runat="server" AutoGenerateColumns="False"
                    GridLines="None" Width="100%" ShowFooter="true"
                    AllowPaging="True" PageSize="25" OnPageIndexChanging="gvDisbursement_PageIndexChanging"
                    EmptyDataText="Please select filter criteria above and click 'Filter Report' to search records."
                    style="border-collapse: collapse; width: 100%; box-sizing: border-box;">
                    <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="True" Height="38px" Font-Size="11px" HorizontalAlign="Left" />
                    <RowStyle BackColor="#ffffff" ForeColor="#1A1A2E" Font-Size="12px" Height="34px" VerticalAlign="Top" />
                    <AlternatingRowStyle BackColor="#fdfbf7" ForeColor="#1A1A2E" Font-Size="12px" Height="34px" VerticalAlign="Top" />
                    <FooterStyle BackColor="#f1ede4" ForeColor="#1A1A2E" Font-Bold="True" Font-Size="12.5px" Height="38px" />
                    <PagerSettings Mode="NumericFirstLast" PageButtonCount="10" FirstPageText="&laquo; First" LastPageText="Last &raquo;" NextPageText="Next &rsaquo;" PreviousPageText="&lsaquo; Prev" Position="Bottom" />
                    <PagerStyle CssClass="custom-pager" HorizontalAlign="Center" BackColor="#faf7f2" Height="44px" />
                    <Columns>
                        <asp:TemplateField HeaderText="Sr#" ItemStyle-Width="45px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                            <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="True" Height="38px" Font-Size="11px" HorizontalAlign="Center" Width="45px" />
                            <ItemStyle HorizontalAlign="Center" Width="45px" VerticalAlign="Top" />
                            <ItemTemplate>
                                <div style="padding: 6px 4px; font-weight: 600; color: #475569; box-sizing: border-box;"><%# Eval("SrNo") %></div>
                            </ItemTemplate>
                            <FooterTemplate>
                                <div style="padding: 6px 4px; font-weight: 800; color: #1A1A2E; text-align: center; box-sizing: border-box;">Total</div>
                            </FooterTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="App No" ItemStyle-Width="80px">
                            <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="True" Height="38px" Font-Size="11px" HorizontalAlign="Left" Width="80px" />
                            <ItemStyle Width="80px" VerticalAlign="Top" />
                            <ItemTemplate>
                                <div style="padding: 6px 4px; box-sizing: border-box;">
                                    <span style="font-weight: 700; color: #8B5E3C; font-family: monospace; font-size: 0.85rem; background: #faf7f2; padding: 1.5px 5px; border-radius: 3px; border: 1px solid #e0d5c5; display: inline-block;">
                                        #<%# Eval("ApplicationNo") %>
                                    </span>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Member No" ItemStyle-Width="100px">
                            <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="True" Height="38px" Font-Size="11px" HorizontalAlign="Left" Width="100px" />
                            <ItemStyle Width="100px" VerticalAlign="Top" />
                            <ItemTemplate>
                                <div style="padding: 6px 4px; box-sizing: border-box;">
                                    <span style="font-weight: 700; color: #1e293b; font-family: monospace; font-size: 0.85rem; background: #F7F3EE; padding: 1.5px 6px; border-radius: 3px; border: 1px solid #e0d5c5; display: inline-block;">
                                        <%# Eval("MemberNo") %>
                                    </span>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Member / Applicant Name" ItemStyle-Width="175px">
                            <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="True" Height="38px" Font-Size="11px" HorizontalAlign="Left" Width="175px" />
                            <ItemStyle Width="175px" VerticalAlign="Top" />
                            <ItemTemplate>
                                <div style="padding: 6px 4px; box-sizing: border-box;">
                                    <div style="font-weight: 700; color: #0f172a; font-size: 0.86rem;"><%# Eval("MemberName") %></div>
                                    <div style="font-size: 0.72rem; color: #8B5E3C; margin-top: 1px;">
                                        Category: <strong style="color: #475569;"><%# Eval("MembershipCategory") %></strong>
                                    </div>
                                </div>
                            </ItemTemplate>
                            <FooterTemplate>
                                <div style="padding: 6px 4px; box-sizing: border-box;">
                                    <span style="font-weight: 700; color: #8B5E3C;">
                                        <asp:Literal ID="litFooterMembersCount" runat="server" /> Members
                                    </span>
                                </div>
                            </FooterTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="CNIC" ItemStyle-Width="120px">
                            <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="True" Height="38px" Font-Size="11px" HorizontalAlign="Left" Width="120px" />
                            <ItemStyle Width="120px" VerticalAlign="Top" />
                            <ItemTemplate>
                                <div style="padding: 6px 4px; box-sizing: border-box;">
                                    <span style="font-family: monospace; font-size: 0.82rem; color: #334155; font-weight: 600;">
                                        <%# Eval("NIC") %>
                                    </span>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Disbursed Finance Heads &amp; Amount Breakdown">
                            <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="True" Height="38px" Font-Size="11px" HorizontalAlign="Left" />
                            <ItemStyle VerticalAlign="Top" />
                            <ItemTemplate>
                                <div style="display: flex; flex-direction: column; gap: 2.5px; padding: 4px; box-sizing: border-box;">
                                    <asp:Repeater ID="rptRowHeads" runat="server" DataSource='<%# Eval("Heads") %>'>
                                        <ItemTemplate>
                                            <div style="display: flex; justify-content: space-between; align-items: center; background: #faf7f2; padding: 2.5px 6px; border-radius: 3px; border: 1px solid #e0d5c5; gap: 6px; margin-bottom: 1px; box-sizing: border-box;">
                                                <div style="display: flex; align-items: center; gap: 5px; box-sizing: border-box;">
                                                    <span style="display: inline-block; background: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd; padding: 1px 3.5px; border-radius: 2px; font-family: monospace; font-weight: 700; font-size: 0.68rem;">
                                                        <%# Eval("ECode") %>
                                                    </span>
                                                    <span style="font-weight: 600; color: #1e293b; font-size: 11px;"><%# Eval("HeadType") %></span>
                                                </div>
                                                <span style="font-weight: 700; color: #16a34a; font-size: 11px; white-space: nowrap;">
                                                    Rs. <%# string.Format("{0:N2}", Eval("Amount")) %>
                                                </span>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Total Amount" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" ItemStyle-Width="125px">
                            <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="True" Height="38px" Font-Size="11px" HorizontalAlign="Right" Width="125px" />
                            <ItemStyle HorizontalAlign="Right" Width="125px" VerticalAlign="Top" />
                            <ItemTemplate>
                                <div style="padding: 6px 8px; text-align: right; box-sizing: border-box;">
                                    <span style="font-weight: 800; color: #1A1A2E; font-size: 0.94rem;">
                                        Rs. <%# string.Format("{0:N2}", Eval("TotalAmount")) %>
                                    </span>
                                </div>
                            </ItemTemplate>
                            <FooterTemplate>
                                <div style="padding: 6px 8px; text-align: right; box-sizing: border-box;">
                                    <span style="font-weight: 800; color: #16a34a; font-size: 0.98rem;">
                                        Rs. <asp:Literal ID="litFooterGrandTotal" runat="server" />
                                    </span>
                                </div>
                            </FooterTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Date" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" ItemStyle-Width="90px">
                            <HeaderStyle BackColor="#0f1e36" ForeColor="#ffffff" Font-Bold="True" Height="38px" Font-Size="11px" HorizontalAlign="Center" Width="90px" />
                            <ItemStyle HorizontalAlign="Center" Width="90px" VerticalAlign="Top" />
                            <ItemTemplate>
                                <div style="padding: 6px 4px; text-align: center; box-sizing: border-box;">
                                    <span style="font-size: 0.75rem; color: #64748b; font-weight: 500;">
                                        <%# Eval("CreatedDate", "{0:dd-MMM-yyyy}") %>
                                    </span>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="padding: 30px 20px; text-align: center; color: #64748b; box-sizing: border-box;">
                            <p style="margin: 0; font-size: 13px; font-weight: 600; color: #334155;">No records found or search not initiated</p>
                            <p style="margin: 3px 0 0 0; font-size: 11.5px; color: #64748b;">Please select filter criteria above and click 'Filter Report' to view disbursement data.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

        <!-- Print-only Signatures Section (Clean Official Document Footer: Prepared By & Checked By) -->
        <div id="printSignatureSection" class="print-only" style="margin-top: 50px; padding-top: 20px; page-break-inside: avoid; box-sizing: border-box;">
            <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-top: 35px; padding: 0 40px; box-sizing: border-box;">
                <div style="width: 38%; text-align: center; border-top: 1.5px solid #0f1e36; padding-top: 8px; font-size: 9.5pt; font-weight: 700; color: #1e293b; box-sizing: border-box;">
                    <div>Prepared By: <span style="font-weight: 600;"><%= GetPreparedByName() %></span></div>
                </div>
                <div style="width: 38%; text-align: center; border-top: 1.5px solid #0f1e36; padding-top: 8px; font-size: 9.5pt; font-weight: 700; color: #1e293b; box-sizing: border-box;">
                    <div>Checked By: <span style="font-weight: 600;"><%= GetCheckedByName() %></span></div>
                </div>
            </div>
        </div>

    </div>
</asp:Content>
