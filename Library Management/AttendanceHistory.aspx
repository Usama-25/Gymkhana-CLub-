<%@ Page Language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" AutoEventWireup="true" CodeFile="AttendanceHistory.aspx.cs" Inherits="GymkhanaLibrary.AttendanceHistory" Title="Attendance History & Reports - Library Management System" %>

<asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">
    <div style="width: 100%; margin: 0 auto; padding: 10px; font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, Roboto, sans-serif; color: #1e293b;">
        
        <!-- ====================================================
             PAGE HEADER
             ==================================================== -->
        <table style="width: 100%; border-collapse: collapse; background: linear-gradient(135deg, #0f1e36, #1c3254); color: #ffffff; border-radius: 8px; border-bottom: 3px solid #c5a059; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -1px rgba(0,0,0,0.06); overflow: hidden; margin-bottom: 24px;">
            <tr>
                <td style="padding: 24px; vertical-align: middle; width: 100%;">
                    <span style="font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: 1px; color: #c5a059; display: block; margin-bottom: 4px;">Library Management System</span>
                    <h1 style="margin: 0; font-size: 28px; font-weight: 700; letter-spacing: -0.5px; color: #ffffff;">Attendance History & Reports</h1>
                </td>
            </tr>
        </table>

        <!-- ====================================================
             NAVIGATION & MESSAGES SECTION
             ==================================================== -->
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <div>
                <asp:Button ID="btnBackToEntry" runat="server" Text="← Back to Attendance Desk" OnClick="btnBackToEntry_Click" Style="padding: 10px 18px; border: 1px solid #cbd5e1; border-radius: 6px; background-color: #ffffff; color: #475569; font-weight: 600; cursor: pointer; font-size: 14px; box-shadow: 0 1px 2px rgba(0,0,0,0.05);" />
            </div>
            
            <!-- Alert Message Panel -->
            <asp:Panel ID="pnlAlertMessage" runat="server" Visible="false" Style="padding: 10px 20px; border-radius: 6px; font-size: 14px; font-weight: 600;">
                <asp:Label ID="lblAlertText" runat="server"></asp:Label>
            </asp:Panel>
        </div>

        <!-- ====================================================
             SEARCH FILTERS & EXPORT PARAMETERS (PANEL)
             ==================================================== -->
        <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); overflow: hidden; margin-bottom: 24px;">
            <div style="background-color: #0f1e36; color: #ffffff; padding: 14px 20px; font-size: 16px; font-weight: 700; border-bottom: 1px solid #e2e8f0;">
                Search Filters & Log Query Parameters
            </div>
            <div style="padding: 24px;">
                <table style="width: 100%; border-collapse: collapse;">
                    <tr>
                        <!-- Row 1 Filters -->
                        <td style="width: 33.3%; padding-right: 12px; padding-bottom: 16px;">
                            <span style="font-size: 13px; font-weight: 600; color: #475569; display: block; margin-bottom: 8px;">From Date:</span>
                            <asp:TextBox ID="txtFilterFromDate" runat="server" TextMode="Date" Style="width: 90%; padding: 9px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13.5px;"></asp:TextBox>
                        </td>
                        <td style="width: 33.3%; padding-left: 6px; padding-right: 12px; padding-bottom: 16px;">
                            <span style="font-size: 13px; font-weight: 600; color: #475569; display: block; margin-bottom: 8px;">To Date:</span>
                            <asp:TextBox ID="txtFilterToDate" runat="server" TextMode="Date" Style="width: 90%; padding: 9px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13.5px;"></asp:TextBox>
                        </td>
                        <td style="width: 33.4%; padding-left: 12px; padding-bottom: 16px;">
                            <span style="font-size: 13px; font-weight: 600; color: #475569; display: block; margin-bottom: 8px;">Membership Type:</span>
                            <asp:DropDownList ID="ddlFilterMemberType" runat="server" Style="width: 100%; padding: 9px; border: 1px solid #cbd5e1; border-radius: 6px; background-color: #ffffff; font-size: 13.5px;">
                                <asp:ListItem Value="" Selected="True">-- All Types --</asp:ListItem>
                                <asp:ListItem Value="Regular">Regular</asp:ListItem>
                                <asp:ListItem Value="Life">Life</asp:ListItem>
                                <asp:ListItem Value="Junior">Junior</asp:ListItem>
                                <asp:ListItem Value="Corporate">Corporate</asp:ListItem>
                                <asp:ListItem Value="Honorary">Honorary</asp:ListItem>
                                <asp:ListItem Value="Staff">Staff</asp:ListItem>
                            </asp:DropDownList>
                        </td>
                    </tr>
                    <tr>
                        <!-- Row 2 Filters -->
                        <td style="padding-right: 12px; padding-bottom: 20px;">
                            <span style="font-size: 13px; font-weight: 600; color: #475569; display: block; margin-bottom: 8px;">Attendance Status:</span>
                            <asp:DropDownList ID="ddlFilterStatus" runat="server" Style="width: 90%; padding: 9px; border: 1px solid #cbd5e1; border-radius: 6px; background-color: #ffffff; font-size: 13.5px;">
                                <asp:ListItem Value="" Selected="True">-- All Statuses --</asp:ListItem>
                                <asp:ListItem Value="Inside">Inside</asp:ListItem>
                                <asp:ListItem Value="Checked Out">Checked Out</asp:ListItem>
                            </asp:DropDownList>
                        </td>
                        <td style="padding-left: 6px; padding-right: 12px; padding-bottom: 20px;">
                            <span style="font-size: 13px; font-weight: 600; color: #475569; display: block; margin-bottom: 8px;">Member Name:</span>
                            <asp:TextBox ID="txtFilterName" runat="server" placeholder="Enter name keywords..." Style="width: 90%; padding: 9px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13.5px;"></asp:TextBox>
                        </td>
                        <td style="padding-left: 6px; padding-right: 12px; padding-bottom: 20px;">
                            <span style="font-size: 13px; font-weight: 600; color: #475569; display: block; margin-bottom: 8px;">Membership Number:</span>
                            <asp:TextBox ID="txtFilterMemberNo" runat="server" placeholder="e.g. LGC-2026-0001" Style="width: 90%; padding: 9px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13.5px;"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3" style="text-align: right; padding-top: 10px; border-top: 1px solid #f1f5f9;">
                            <asp:Button ID="btnFilterReset" runat="server" Text="Reset Filters" OnClick="btnFilterReset_Click" Style="padding: 10px 24px; border: 1px solid #cbd5e1; border-radius: 6px; background-color: #f8fafc; color: #475569; font-weight: 600; cursor: pointer; font-size: 13.5px; margin-right: 12px;" />
                            <asp:Button ID="btnFilterSearch" runat="server" Text="Apply Filter" OnClick="btnFilterSearch_Click" Style="padding: 10px 28px; border: none; border-radius: 6px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; font-weight: 600; cursor: pointer; font-size: 13.5px; box-shadow: 0 2px 4px rgba(15,30,54,0.2);" />
                        </td>
                    </tr>
                </table>
            </div>
        </div>

        <!-- ====================================================
             ATTENDANCE HISTORY GRIDVIEW
             ==================================================== -->
        <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); overflow: hidden; margin-bottom: 24px;">
            <div style="background-color: #0f1e36; color: #ffffff; padding: 14px 20px; font-size: 16px; font-weight: 700; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
                <span>Historical Attendance Log (Filtered)</span>
            </div>
            <div style="padding: 12px;">
                <asp:GridView ID="gvAttendanceHistory" runat="server" AutoGenerateColumns="False" OnRowDataBound="gvAttendanceHistory_RowDataBound" Style="width: 100%; border-collapse: collapse; font-size: 14px; text-align: left;" GridLines="None" CellPadding="10">
                    <Columns>
                        <asp:BoundField DataField="SrNo" HeaderText="Sr#"></asp:BoundField>
                        <asp:BoundField DataField="AttendanceDate" HeaderText="Attendance Date" DataFormatString="{0:dd-MMM-yyyy}"></asp:BoundField>
                        <asp:BoundField DataField="Member" HeaderText="Member"></asp:BoundField>
                        <asp:BoundField DataField="CheckIn" HeaderText="Check In" DataFormatString="{0:dd-MMM-yyyy hh:mm tt}"></asp:BoundField>
                        <asp:BoundField DataField="CheckOut" HeaderText="Check Out" DataFormatString="{0:dd-MMM-yyyy hh:mm tt}"></asp:BoundField>
                        <asp:TemplateField HeaderText="Duration">
                            <ItemTemplate>
                                <%# Eval("Duration") != DBNull.Value ? Eval("Duration") + " Mins" : "-" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Remarks" HeaderText="Remarks"></asp:BoundField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="text-align: center; padding: 30px; color: #64748b;">No historical attendance records found matching filters.</div>
                    </EmptyDataTemplate>
                    <AlternatingRowStyle BackColor="#f8fafc" />
                </asp:GridView>
            </div>
        </div>

        <!-- ====================================================
             REPORT & ACTION SECTION (EXPORT BUTTONS)
             ==================================================== -->
        <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); overflow: hidden; padding: 20px; text-align: center;">
            <span style="font-size: 13px; font-weight: 600; color: #64748b; display: block; margin-bottom: 12px; text-transform: uppercase; letter-spacing: 0.5px;">Attendance Reporting & Downloads</span>
            <div style="display: inline-block; margin: 4px;">
                <asp:Button ID="btnTodayReport" runat="server" Text="Today's Report" OnClick="btnTodayReport_Click" Style="padding: 10px 18px; border: 1px solid #0f1e36; border-radius: 6px; background-color: #ffffff; color: #0f1e36; font-weight: 600; cursor: pointer; font-size: 13.5px; margin-right: 8px;" />
                <asp:Button ID="btnMonthlyReport" runat="server" Text="Monthly Report" OnClick="btnMonthlyReport_Click" Style="padding: 10px 18px; border: 1px solid #0f1e36; border-radius: 6px; background-color: #ffffff; color: #0f1e36; font-weight: 600; cursor: pointer; font-size: 13.5px; margin-right: 8px;" />
                <asp:Button ID="btnSummaryReport" runat="server" Text="Attendance Summary" OnClick="btnSummaryReport_Click" Style="padding: 10px 18px; border: 1px solid #0f1e36; border-radius: 6px; background-color: #ffffff; color: #0f1e36; font-weight: 600; cursor: pointer; font-size: 13.5px; margin-right: 8px;" />
                <asp:Button ID="btnPrint" runat="server" Text="Print Report (Ctrl+P)" OnClick="btnPrint_Click" Style="padding: 10px 18px; border: none; border-radius: 6px; background-color: #f59e0b; color: #ffffff; font-weight: 600; cursor: pointer; font-size: 13.5px; margin-right: 8px; box-shadow: 0 2px 4px rgba(245,158,11,0.2);" />
                <asp:Button ID="btnExportExcel" runat="server" Text="Export to Excel" OnClick="btnExportExcel_Click" Style="padding: 10px 18px; border: none; border-radius: 6px; background-color: #10b981; color: #ffffff; font-weight: 600; cursor: pointer; font-size: 13.5px; margin-right: 8px; box-shadow: 0 2px 4px rgba(16,185,129,0.2);" />
                <asp:Button ID="btnExportPDF" runat="server" Text="Export to PDF" OnClick="btnExportPDF_Click" Style="padding: 10px 18px; border: none; border-radius: 6px; background-color: #ef4444; color: #ffffff; font-weight: 600; cursor: pointer; font-size: 13.5px; box-shadow: 0 2px 4px rgba(239,68,68,0.2);" />
            </div>
        </div>

    </div>
</asp:Content>
