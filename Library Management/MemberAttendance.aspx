<%@ Page Language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" AutoEventWireup="true" CodeFile="MemberAttendance.aspx.cs" Inherits="GymkhanaLibrary.MemberAttendance" Title="Member Attendance - Library Management System" %>

<asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
    <!-- Custom styling placeholder for page overrides if needed -->
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
                    <h1 style="margin: 0; font-size: 28px; font-weight: 700; letter-spacing: -0.5px; color: #ffffff;">Member Attendance Portal</h1>
                </td>
            </tr>
        </table>

        <!-- ====================================================
             DASHBOARD SUMMARY
             ==================================================== -->
        <table style="width: 100%; border-collapse: separate; border-spacing: 16px 0px; margin: 0 -16px 24px -16px;">
            <tr>
                <!-- Card 1: Today's Visitors -->
                <td style="width: 16.66%; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px; text-align: center; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); vertical-align: top;">
                    <span style="font-size: 12px; font-weight: 600; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 8px;">Today's Visitors</span>
                    <asp:Label ID="lblTodayVisitors" runat="server" Text="0" Style="font-size: 28px; font-weight: 700; color: #0f1e36; display: block;"></asp:Label>
                </td>
                <!-- Card 2: Current Members Inside -->
                <td style="width: 16.66%; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px; text-align: center; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); vertical-align: top;">
                    <span style="font-size: 12px; font-weight: 600; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 8px;">Members Inside</span>
                    <asp:Label ID="lblCurrentInside" runat="server" Text="0" Style="font-size: 28px; font-weight: 700; color: #10b981; display: block;"></asp:Label>
                </td>
                <!-- Card 3: Total Check-Ins Today -->
                <td style="width: 16.66%; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px; text-align: center; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); vertical-align: top;">
                    <span style="font-size: 12px; font-weight: 600; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 8px;">Today Check-Ins</span>
                    <asp:Label ID="lblTotalCheckIns" runat="server" Text="0" Style="font-size: 28px; font-weight: 700; color: #1c3254; display: block;"></asp:Label>
                </td>
                <!-- Card 4: Total Check-Outs Today -->
                <td style="width: 16.66%; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px; text-align: center; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); vertical-align: top;">
                    <span style="font-size: 12px; font-weight: 600; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 8px;">Today Check-Outs</span>
                    <asp:Label ID="lblTotalCheckOuts" runat="server" Text="0" Style="font-size: 28px; font-weight: 700; color: #ef4444; display: block;"></asp:Label>
                </td>
                <!-- Card 5: Average Stay Time -->
                <td style="width: 16.66%; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px; text-align: center; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); vertical-align: top;">
                    <span style="font-size: 12px; font-weight: 600; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 8px;">Avg Stay (Min)</span>
                    <asp:Label ID="lblAvgStayTime" runat="server" Text="0" Style="font-size: 28px; font-weight: 700; color: #f59e0b; display: block;"></asp:Label>
                </td>
                <!-- Card 6: Monthly Visitors -->
                <td style="width: 16.66%; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px; text-align: center; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); vertical-align: top;">
                    <span style="font-size: 12px; font-weight: 600; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; display: block; margin-bottom: 8px;">Monthly Visitors</span>
                    <asp:Label ID="lblMonthlyVisitors" runat="server" Text="0" Style="font-size: 28px; font-weight: 700; color: #6366f1; display: block;"></asp:Label>
                </td>
            </tr>
        </table>

        <!-- Alert messages block -->
        <asp:Panel ID="pnlAlertMessage" runat="server" Visible="false" Style="margin-bottom: 24px; padding: 16px; border-radius: 8px; border-width: 1px; border-style: solid; font-size: 14px; font-weight: 600;">
            <asp:Label ID="lblAlertText" runat="server"></asp:Label>
        </asp:Panel>

        <!-- ====================================================
             MAIN ROW: SEARCH & MEMBER PROFILE
             ==================================================== -->
        <table style="width: 100%; border-collapse: collapse; margin-bottom: 24px;">
            <tr>
                <!-- LEFT COLUMN: MEMBER SEARCH PANEL -->
                <td style="width: 40%; padding-right: 12px; vertical-align: top;">
                    <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); overflow: hidden; height: 100%;">
                        <div style="background-color: #0f1e36; color: #ffffff; padding: 14px 20px; font-size: 16px; font-weight: 700; border-bottom: 1px solid #e2e8f0;">
                            Attendance Entry & Search Panel
                        </div>
                        <div style="padding: 24px;">
                            <table style="width: 100%; border-collapse: collapse;">
                                <tr>
                                    <td style="padding-bottom: 16px;">
                                        <span style="font-size: 13px; font-weight: 600; color: #475569; display: block; margin-bottom: 8px;">Search Member By:</span>
                                        <asp:DropDownList ID="ddlSearchBy" runat="server" Style="width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; background-color: #f8fafc; font-size: 14px; color: #1e293b;">
                                            <asp:ListItem Value="MembershipNo" Selected="True">Membership Number</asp:ListItem>
                                            <asp:ListItem Value="RFID">RFID Card</asp:ListItem>
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding-bottom: 20px;">
                                        <span style="font-size: 13px; font-weight: 600; color: #475569; display: block; margin-bottom: 8px;">Enter Value:</span>
                                        <asp:TextBox ID="txtSearch" runat="server" placeholder="Enter scan or search query..." Style="width: 93%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; color: #1e293b;"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding-bottom: 20px;">
                                        <span style="font-size: 13px; font-weight: 600; color: #475569; display: block; margin-bottom: 8px;">Remarks (Optional):</span>
                                        <asp:TextBox ID="txtRemarks" runat="server" placeholder="Add entry notes here..." Style="width: 93%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; color: #1e293b;"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <table style="width: 100%; border-collapse: collapse;">
                                            <tr>
                                                <td style="width: 50%; padding-right: 8px;">
                                                    <asp:Button ID="btnSearch" runat="server" Text="Search Member" OnClick="btnSearch_Click" Style="width: 100%; padding: 11px; border: none; border-radius: 6px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; font-weight: 600; cursor: pointer; font-size: 14px; box-shadow: 0 2px 4px rgba(15,30,54,0.2);" />
                                                </td>
                                                <td style="width: 50%; padding-left: 8px;">
                                                    <asp:Button ID="btnClear" runat="server" Text="Clear Panel" OnClick="btnClear_Click" Style="width: 100%; padding: 11px; border: 1px solid #cbd5e1; border-radius: 6px; background-color: #f8fafc; color: #475569; font-weight: 600; cursor: pointer; font-size: 14px;" />
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </td>

                <!-- RIGHT COLUMN: MEMBER INFORMATION PANEL & ACTIONS -->
                <td style="width: 60%; padding-left: 12px; vertical-align: top;">
                    <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); overflow: hidden; height: 100%;">
                        <div style="background-color: #0f1e36; color: #ffffff; padding: 14px 20px; font-size: 16px; font-weight: 700; border-bottom: 1px solid #e2e8f0;">
                            Member Information & Attendance Actions
                        </div>
                        <div style="padding: 24px;">
                            <asp:Panel ID="pnlNoMemberSelected" runat="server" Style="text-align: center; padding: 40px 0; color: #64748b;">
                                <div style="font-size: 48px; margin-bottom: 12px; color: #cbd5e1;">👤</div>
                                <p style="margin: 0; font-size: 15px; font-weight: 500;">No member searched yet. Please scan an RFID card or search above.</p>
                            </asp:Panel>

                            <asp:Panel ID="pnlMemberDetails" runat="server" Visible="false">
                                
                                <!-- VALIDATIONS PANEL -->
                                <div style="margin-bottom: 20px;">
                                    <!-- Membership Expired Alert -->
                                    <asp:Panel ID="pnlExpiredAlert" runat="server" Visible="false" Style="margin-bottom: 10px; padding: 12px 16px; background-color: #fef2f2; border: 1px solid #fecaca; border-radius: 6px; color: #b91c1c; font-size: 13.5px; font-weight: 600;">
                                        ⚠️ WARNING: <asp:Label ID="lblExpiredAlertText" runat="server" Text="Library Membership is Expired. Access Denied."></asp:Label>
                                    </asp:Panel>
                                    <!-- Card Status Alert (BLOCKED / DEACTIVATE / LOST) -->
                                    <asp:Panel ID="pnlCardStatusAlert" runat="server" Visible="false" Style="margin-bottom: 10px; padding: 12px 16px; background-color: #fef2f2; border: 1px solid #fecaca; border-radius: 6px; color: #b91c1c; font-size: 13.5px; font-weight: 600;">
                                        🚫 CARD STATUS: <asp:Label ID="lblCardStatusAlertText" runat="server" Text=""></asp:Label>
                                    </asp:Panel>
                                    <!-- Account / Member Status Alert (SUSPENDED / Terminated) -->
                                    <asp:Panel ID="pnlAccountStatusAlert" runat="server" Visible="false" Style="margin-bottom: 10px; padding: 12px 16px; background-color: #fff7ed; border: 1px solid #ffedd5; border-radius: 6px; color: #c2410c; font-size: 13.5px; font-weight: 600;">
                                        ⚠️ WARNING: <asp:Label ID="lblAccountStatusAlertText" runat="server" Text=""></asp:Label>
                                    </asp:Panel>
                                    <!-- Inactive Member Alert -->
                                    <asp:Panel ID="pnlInactiveAlert" runat="server" Visible="false" Style="margin-bottom: 10px; padding: 12px 16px; background-color: #fff7ed; border: 1px solid #ffedd5; border-radius: 6px; color: #c2410c; font-size: 13.5px; font-weight: 600;">
                                        ⚠️ WARNING: Member account status is Inactive. Access Denied.
                                    </asp:Panel>
                                    <!-- Outstanding Fine Alert -->
                                    <asp:Panel ID="pnlFineAlert" runat="server" Visible="false" Style="margin-bottom: 10px; padding: 12px 16px; background-color: #fef9c3; border: 1px solid #fef08a; border-radius: 6px; color: #854d0e; font-size: 13.5px; font-weight: 600;">
                                        ⚠️ WARNING: Outstanding Fine exists. Display only, check-in allowed.
                                    </asp:Panel>
                                </div>

                                <table style="width: 100%; border-collapse: collapse;">
                                    <tr>
                                        <!-- Detailed Profile Grid -->
                                        <td style="vertical-align: top;">
                                            <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
                                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                                    <td style="padding: 8px 0; font-weight: 600; color: #64748b; width: 140px;">Member ID:</td>
                                                    <td style="padding: 8px 0; font-weight: 700; color: #475569;">
                                                        <asp:Label ID="lblMemberIdVal" runat="server" Text="-"></asp:Label>
                                                        <asp:HiddenField ID="hfMemberID" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                                    <td style="padding: 8px 0; font-weight: 600; color: #64748b; width: 140px;">Membership No:</td>
                                                    <td style="padding: 8px 0; font-weight: 700; color: #0f1e36;"><asp:Label ID="lblMemberNoVal" runat="server" Text="-"></asp:Label></td>
                                                </tr>
                                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                                    <td style="padding: 8px 0; font-weight: 600; color: #64748b;">Member Name:</td>
                                                    <td style="padding: 8px 0; font-weight: 700; color: #0f1e36;"><asp:Label ID="lblMemberNameVal" runat="server" Text="-"></asp:Label></td>
                                                </tr>
                                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                                    <td style="padding: 8px 0; font-weight: 600; color: #64748b;">Membership Type:</td>
                                                    <td style="padding: 8px 0; font-weight: 600; color: #334155;"><asp:Label ID="lblMemberTypeVal" runat="server" Text="-"></asp:Label></td>
                                                </tr>
                                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                                    <td style="padding: 8px 0; font-weight: 600; color: #64748b;">Phone / Email:</td>
                                                    <td style="padding: 8px 0; color: #334155;">
                                                        <asp:Label ID="lblPhoneVal" runat="server" Text="-"></asp:Label> / <asp:Label ID="lblEmailVal" runat="server" Text="-"></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                                    <td style="padding: 8px 0; font-weight: 600; color: #64748b;">Expiry Date:</td>
                                                    <td style="padding: 8px 0; font-weight: 600;"><asp:Label ID="lblExpiryVal" runat="server" Text="-"></asp:Label></td>
                                                </tr>
                                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                                    <td style="padding: 8px 0; font-weight: 600; color: #b91c1c;">Outstanding Fine:</td>
                                                    <td style="padding: 8px 0; font-weight: 700; color: #b91c1c;">Rs. <asp:Label ID="lblFineVal" runat="server" Text="0.00"></asp:Label></td>
                                                </tr>
                                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                                    <td style="padding: 8px 0; font-weight: 600; color: #64748b;">Books Issued:</td>
                                                    <td style="padding: 8px 0; font-weight: 600; color: #334155;"><asp:Label ID="lblBooksVal" runat="server" Text="0"></asp:Label> Book(s)</td>
                                                </tr>
                                                <tr>
                                                    <td style="padding: 8px 0; font-weight: 600; color: #64748b;">Current Status:</td>
                                                    <td style="padding: 8px 0; font-weight: 700;"><asp:Label ID="lblStatusVal" runat="server" Text="-"></asp:Label></td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>

                                <!-- ATTENDANCE ACTION BUTTONS -->
                                <div style="margin-top: 24px; padding-top: 20px; border-top: 1px solid #e2e8f0; text-align: right;">
                                    <asp:Button ID="btnCheckIn" runat="server" Text="Check In" OnClick="btnCheckIn_Click" Style="padding: 12px 28px; border: none; border-radius: 6px; background-color: #10b981; color: #ffffff; font-weight: 700; cursor: pointer; font-size: 15px; margin-right: 12px; box-shadow: 0 4px 6px -1px rgba(16,185,129,0.25);" />
                                    <asp:Button ID="btnCheckOut" runat="server" Text="Check Out" OnClick="btnCheckOut_Click" Style="padding: 12px 28px; border: none; border-radius: 6px; background-color: #ef4444; color: #ffffff; font-weight: 700; cursor: pointer; font-size: 15px; box-shadow: 0 4px 6px -1px rgba(239,68,68,0.25);" />
                                </div>

                            </asp:Panel>
                        </div>
                    </div>
                </td>
            </tr>
        </table>

        <!-- ====================================================
             CURRENT MEMBERS INSIDE (GRIDVIEW)
             ==================================================== -->
        <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); overflow: hidden; margin-bottom: 24px;">
            <div style="background-color: #0f1e36; color: #ffffff; padding: 14px 20px; font-size: 16px; font-weight: 700; border-bottom: 1px solid #e2e8f0;">
                Current Members Inside the Library
            </div>
            <div style="padding: 12px;">
                <asp:GridView ID="gvCurrentVisitors" runat="server" AutoGenerateColumns="False" OnRowCommand="gvCurrentVisitors_RowCommand" OnRowDataBound="gvCurrentVisitors_RowDataBound" Style="width: 100%; border-collapse: collapse; font-size: 14px; text-align: left;" GridLines="None" CellPadding="10">
                    <Columns>
                        <asp:BoundField DataField="MembershipNo" HeaderText="Membership No"></asp:BoundField>
                        <asp:BoundField DataField="FullName" HeaderText="Name"></asp:BoundField>
                        <asp:BoundField DataField="CheckInTime" HeaderText="Check In Time" DataFormatString="{0:dd-MMM-yyyy hh:mm tt}"></asp:BoundField>
                        <asp:TemplateField HeaderText="Duration">
                            <ItemTemplate>
                                <%# Eval("Duration") %> Mins
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span style="background-color: #d1fae5; color: #065f46; padding: 4px 8px; border-radius: 50px; font-size: 11px; font-weight: 700; text-transform: uppercase;"><%# Eval("Status") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Action">
                            <ItemTemplate>
                                <asp:Button ID="btnGvCheckout" runat="server" Text="Check Out" CommandName="CheckOutRow" CommandArgument='<%# Eval("MembershipNo") %>' Style="padding: 6px 12px; background-color: #ef4444; color: white; border: none; border-radius: 4px; font-size: 12px; font-weight: 600; cursor: pointer;" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="text-align: center; padding: 30px; color: #64748b;">No members are currently inside the library.</div>
                    </EmptyDataTemplate>
                    <AlternatingRowStyle BackColor="#f8fafc" />
                </asp:GridView>
            </div>
        </div>

        <!-- ====================================================
             TODAY'S ATTENDANCE GRIDVIEW
             ==================================================== -->
        <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); overflow: hidden; margin-bottom: 24px;">
            <div style="background-color: #0f1e36; color: #ffffff; padding: 14px 20px; font-size: 16px; font-weight: 700; border-bottom: 1px solid #e2e8f0;">
                Today's Attendance Log
            </div>
            <div style="padding: 12px;">
                <asp:GridView ID="gvTodayAttendance" runat="server" AutoGenerateColumns="False" OnRowDataBound="gvTodayAttendance_RowDataBound" Style="width: 100%; border-collapse: collapse; font-size: 14px; text-align: left;" GridLines="None" CellPadding="10">
                    <Columns>
                        <asp:BoundField DataField="AttendanceID" HeaderText="Att. ID"></asp:BoundField>
                        <asp:BoundField DataField="Date" HeaderText="Date" DataFormatString="{0:dd-MMM-yyyy}"></asp:BoundField>
                        <asp:BoundField DataField="MemberNo" HeaderText="Member No"></asp:BoundField>
                        <asp:BoundField DataField="MemberName" HeaderText="Member Name"></asp:BoundField>
                        <asp:BoundField DataField="CheckIn" HeaderText="Check In" DataFormatString="{0:hh:mm tt}"></asp:BoundField>
                        <asp:BoundField DataField="CheckOut" HeaderText="Check Out" DataFormatString="{0:hh:mm tt}"></asp:BoundField>
                        <asp:TemplateField HeaderText="Duration">
                            <ItemTemplate>
                                <%# Eval("Duration") != DBNull.Value ? Eval("Duration") + " Mins" : "-" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Operator" HeaderText="Operator"></asp:BoundField>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span style='<%# Eval("Status").ToString() == "Inside" ? "background-color: #d1fae5; color: #065f46; padding: 4px 8px; border-radius: 50px; font-size: 11px; font-weight: 700; text-transform: uppercase;" : "background-color: #f1f5f9; color: #475569; padding: 4px 8px; border-radius: 50px; font-size: 11px; font-weight: 700; text-transform: uppercase;" %>'><%# Eval("Status") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="text-align: center; padding: 30px; color: #64748b;">No attendance logs recorded for today.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

        <!-- ====================================================
             REPORTS & HISTORY QUICK LINK
             ==================================================== -->
        <div style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); overflow: hidden; padding: 24px; text-align: center;">
            <h3 style="margin: 0 0 8px 0; font-size: 16px; font-weight: 700; color: #0f1e36;">Access Historical Logs & Generate Reports</h3>
            <p style="margin: 0 0 16px 0; font-size: 13.5px; color: #64748b;">Search attendance logs, filter by membership details, view monthly records, and download Excel/PDF summaries.</p>
            <asp:Button ID="btnGoToHistory" runat="server" Text="Open Attendance History & Reports" OnClick="btnGoToHistory_Click" Style="padding: 12px 32px; border: none; border-radius: 6px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; font-weight: 700; cursor: pointer; font-size: 14.5px; box-shadow: 0 4px 6px -1px rgba(15,30,54,0.25);" />
        </div>

    </div>
</asp:Content>
