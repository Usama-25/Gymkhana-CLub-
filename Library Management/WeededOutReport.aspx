<%@ page language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" autoeventwireup="true" CodeFile="WeededOutReport.aspx.cs" Inherits="GymkhanaLibrary.WeededOutReport" title="Weeding Log Report - Lahore Gymkhana Library" %>

<asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        /* Compress grid layout for both screen and print */
        #cphBody_gvLog th, 
        .gv-header th {
            padding: 8px 12px !important;
            font-size: 12.5px !important;
            border-bottom: 2px solid #e2e8f0 !important;
            white-space: nowrap !important;
        }
        #cphBody_gvLog td, 
        .gv-row td, 
        .gv-alt-row td {
            padding: 8px 12px !important;
            font-size: 12px !important;
            line-height: 1.4 !important;
            border-bottom: 1px solid #edf2f7 !important;
        }

        /* Further compress padding of container divs */
        .report-header {
            padding: 14px 20px !important;
            margin-bottom: 14px !important;
        }
        .report-card {
            padding: 16px 20px !important;
            margin-bottom: 16px !important;
            border-radius: 8px !important;
        }
        .report-filters {
            padding: 16px 20px !important;
            margin-bottom: 16px !important;
            border-radius: 8px !important;
        }
        
        @media print {
            @page {
                size: landscape;
                margin: 0.2in !important;
            }
            aside, header, #appSidebar, .no-print {
                display: none !important;
            }
            .print-only {
                display: block !important;
                margin-bottom: 10px !important;
            }
            body {
                background: #fff;
                padding: 0 !important;
                margin: 0 !important;
            }
            main {
                margin: 0 !important;
                padding: 0 !important;
            }
            #cphBody_gvLog {
                width: 100% !important;
                max-width: 100% !important;
                border: 1px solid #cbd5e1 !important;
                table-layout: auto !important;
            }
            #cphBody_gvLog th {
                background-color: #f8fafc !important;
                color: #1e293b !important;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
                padding: 4px 6px !important;
                font-size: 10px !important;
                border-bottom: 2px solid #cbd5e1 !important;
                white-space: nowrap !important;
            }
            #cphBody_gvLog td {
                padding: 4px 6px !important;
                font-size: 9.5px !important;
                border-bottom: 1px solid #e2e8f0 !important;
                line-height: 1.3 !important;
            }
            .print-container {
                padding: 0 !important;
                margin: 0 !important;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">
    
    <div style="background: linear-gradient(135deg, #0f1e36, #1c3254); color: #ffffff; padding: 20px 28px; border-radius: 8px; margin-bottom: 24px; border-bottom: 3px solid #c5a059; width: 100%; box-sizing: border-box;" class="no-print report-header">
        <h2 style="margin: 0; font-size: 22px; font-weight: 600; font-family: 'Playfair Display', serif;">Weeding & Restoration Audit Report</h2>
        <p style="margin: 4px 0 0; opacity: .8; font-size: 13px;">View history and audit logs of all weeded out books and their restorations with detailed remarks.</p>
    </div>

    <!-- Filters Panel -->
    <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);" class="no-print report-filters">
        <h3 style="font-family: 'Playfair Display', serif; font-size: 18px; color: #0f1e36; margin-top: 0; margin-bottom: 16px;">Filter Logs</h3>
        
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; align-items: end;">
            <div>
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">From Date</label>
                <asp:TextBox ID="txtFromDate" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" TextMode="Date" />
            </div>
            
            <div>
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">To Date</label>
                <asp:TextBox ID="txtToDate" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" TextMode="Date" />
            </div>

            <div>
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Action Type</label>
                <asp:DropDownList ID="ddlActionType" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';">
                    <asp:ListItem Value="" Selected="True">All Actions</asp:ListItem>
                    <asp:ListItem Value="WEED">Weeded Out</asp:ListItem>
                    <asp:ListItem Value="RESTORE">Restored</asp:ListItem>
                </asp:DropDownList>
            </div>

            <div>
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Search Logs</label>
                <asp:TextBox ID="txtSearch" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="Search Book, Book No, Barcode, Staff, or Remarks..." />
            </div>

        </div>
        <div style="display: flex; gap: 8px; margin-top: 16px; flex-wrap: wrap;">
            <asp:Button ID="btnFilter" runat="server" Text="Filter" style="padding: 10px 20px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block; height: 42px;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnFilter_Click" />
            <asp:Button ID="btnReset" runat="server" Text="Reset" style="padding: 10px 20px; border-radius: 8px; border: 1px solid #cbd5e1; cursor: pointer; font-size: 13px; font-weight: 600; background-color: #ffffff; color: #64748b; transition: all 0.2s ease; display: inline-block; height: 42px;" onmouseover="this.style.backgroundColor='#f1f5f9'; this.style.color='#1e293b';" onmouseout="this.style.backgroundColor='#ffffff'; this.style.color='#64748b';" OnClick="btnReset_Click" />
            <asp:Button ID="btnPrint" runat="server" Text="Print / Save PDF" style="padding: 10px 20px; border-radius: 8px; border: 1px solid #cbd5e1; cursor: pointer; font-size: 13px; font-weight: 600; background-color: #ffffff; color: #64748b; transition: all 0.2s ease; display: inline-block; height: 42px;" onmouseover="this.style.backgroundColor='#f1f5f9'; this.style.color='#1e293b';" onmouseout="this.style.backgroundColor='#ffffff'; this.style.color='#64748b';" OnClick="btnPrint_Click" />
        </div>
    </div>

    <!-- Print Header -->
    <div class="print-only" style="margin-bottom: 20px; border-bottom: 2px solid #cbd5e1; padding-bottom: 10px; text-align: left; width: 100%;">
        <img src='<%= ResolveUrl("~/Library Management/Images/logo_new.png") %>' alt="Lahore Gymkhana Logo" style="height: 65px; display: inline-block; margin: 0; object-fit: contain;" />
    </div>

    <!-- Results Panel -->
    <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);" class="report-card">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; margin-bottom: 12px;">
            <h3 style="font-family: 'Playfair Display', serif; font-size: 18px; color: #0f1e36; margin: 0;">Audit Log Entries</h3>
            <span style="font-size: 13px; color: #64748b;" class="no-print">Page size: 20 entries</span>
        </div>

        <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
            <asp:GridView ID="gvLog" runat="server" AutoGenerateColumns="false" GridLines="None"
                AllowPaging="true" PageSize="20" OnPageIndexChanging="gvLog_PageIndexChanging"
                style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;">
                <HeaderStyle CssClass="gv-header" />
                <RowStyle CssClass="gv-row" />
                <AlternatingRowStyle CssClass="gv-alt-row" />
                <PagerStyle CssClass="no-print pager-style"/>
                <Columns>
                    <asp:BoundField DataField="SR#" HeaderText="SR#">
                        <HeaderStyle CssClass="gv-header-left" Width="50px" />
                        <ItemStyle CssClass="gv-text-left" Width="50px" />
                    </asp:BoundField>
                    
                    <asp:TemplateField HeaderText="Book / Copy Details">
                        <HeaderStyle CssClass="gv-header-left" />
                        <ItemStyle CssClass="gv-text-left" />
                        <ItemTemplate>
                            <div style="font-weight: 600; color: #0f1e36;"><%# Eval("BookTitle") %></div>
                            <div style="font-size: 11px; font-family: monospace; color: #64748b; margin-top: 2px;">
                                <strong>Book No:</strong> <%# Eval("BookNo") %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Action">
                        <HeaderStyle CssClass="gv-header-left" Width="110px" />
                        <ItemStyle CssClass="gv-text-left" Width="110px" />
                        <ItemTemplate>
                            <span style='<%# Eval("ActionType").ToString() == "WEED" ? "display: inline-block; padding: 4px 8px; border-radius: 12px; font-size: 11px; font-weight: 600; text-transform: uppercase; background-color: #fee2e2; color: #991b1b;" : "display: inline-block; padding: 4px 8px; border-radius: 12px; font-size: 11px; font-weight: 600; text-transform: uppercase; background-color: #d1fae5; color: #065f46;" %>'>
                                <%# Eval("ActionType").ToString() == "WEED" ? "Weeded Out" : "Restored" %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Transition Summary">
                        <HeaderStyle CssClass="gv-header-left" />
                        <ItemStyle CssClass="gv-text-left" />
                        <ItemTemplate>
                            <div style="font-size: 12px;">
                                <strong>Condition:</strong> <%# Eval("OldCondition") %> -> <%# Eval("NewCondition") %><br/>
                                <strong>Location:</strong> <%# Eval("OldLocation") %> -> <%# Eval("NewLocation") %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="Remarks" HeaderText="Remarks / Reasons">
                        <HeaderStyle CssClass="gv-header-left" />
                        <ItemStyle CssClass="gv-text-left" />
                    </asp:BoundField>
                    
                    <asp:TemplateField HeaderText="Actioned By">
                        <HeaderStyle CssClass="gv-header-left" Width="150px" />
                        <ItemStyle CssClass="gv-text-left" Width="150px" />
                        <ItemTemplate>
                            <div style="font-weight: 600; color: #475569;"><%# Eval("ActionedByStaff") %></div>
                            <div style="font-size: 11px; color: #94a3b8; margin-top: 2px;"><%# Eval("ActionedAt", "{0:dd-MMM-yyyy hh:mm tt}") %></div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div style="text-align: center; padding: 40px; color: #94a3b8; font-size: 15px;">
                        No weeding log entries found matching the filter criteria.
                    </div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>

</asp:Content>
