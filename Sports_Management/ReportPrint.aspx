<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ReportPrint.aspx.cs" Inherits="ReportPrint" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Report Print View</title>
    <style>
        body {
            font-family: 'Inter', sans-serif;
            font-size: 12px;
            color: #333;
            background: white;
            padding: 20px;
        }
        .print-header {
            border-bottom: 2px solid #1e3a5f;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .print-header h2 {
            margin: 0 0 5px 0;
            color: #1e3a5f;
            font-size: 20px;
        }
        .print-header p {
            margin: 0;
            font-size: 10px;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .profile-section {
            background: #f8f9fa;
            border: 1px solid #ddd;
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 20px;
        }
        .profile-section h3 {
            margin: 0 0 10px 0;
            color: #1e3a5f;
        }
        .profile-section p {
            margin: 4px 0;
        }
        .card-title {
            font-size: 14px;
            font-weight: bold;
            color: #1e3a5f;
            margin: 20px 0 10px 0;
            text-transform: uppercase;
        }
        .grid-view {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        .grid-view th {
            background: #1e3a5f;
            color: white;
            padding: 8px 10px;
            text-align: left;
            font-weight: 600;
            border: 1px solid #1e3a5f;
            -webkit-print-color-adjust: exact;
            print-color-adjust: exact;
        }
        .grid-view td {
            padding: 8px 10px;
            border: 1px solid #ddd;
        }
        .badge-active {
            color: #10b981;
            font-weight: bold;
        }
        .badge-inactive {
            color: #ef4444;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="print-header">
            <h2><asp:Label ID="lblTitle" runat="server"></asp:Label></h2>
            <p><asp:Label ID="lblSubtitle" runat="server"></asp:Label></p>
        </div>

        <asp:Label ID="lblMessage" runat="server" Visible="false" Style="display:block; padding:10px; margin-bottom:15px; border-radius:5px; background-color:#f8d7da; color:#721c24; border:1px solid #f5c6cb;"></asp:Label>

        <!-- 1. Member Subscriptions View -->
        <asp:PlaceHolder ID="phSubs" runat="server" Visible="false">
            <asp:GridView ID="gvSubs" runat="server" AutoGenerateColumns="False" CssClass="grid-view">
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
            </asp:GridView>
        </asp:PlaceHolder>

        <!-- 2. Individual Member View -->
        <asp:PlaceHolder ID="phInd" runat="server" Visible="false">
            <div class="profile-section">
                <h3><asp:Label ID="lblIndName" runat="server"></asp:Label></h3>
                <p><strong>Member No:</strong> <asp:Label ID="lblIndMemberNo" runat="server"></asp:Label></p>
                <p><strong>Status:</strong> <asp:Label ID="lblIndStatus" runat="server"></asp:Label></p>
                <p><strong>Contact:</strong> <asp:Label ID="lblIndContact" runat="server"></asp:Label></p>
            </div>

            <div class="card-title">Subscriptions</div>
            <asp:GridView ID="gvIndSubs" runat="server" AutoGenerateColumns="False" CssClass="grid-view">
                <Columns>
                    <asp:BoundField DataField="SportName" HeaderText="Sport" />
                    <asp:BoundField DataField="PackageName" HeaderText="Package" />
                    <asp:BoundField DataField="SubscriptionType" HeaderText="Type" />
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
            </asp:GridView>

            <div class="card-title">Daily POS Transactions (Passes)</div>
            <asp:GridView ID="gvIndPOS" runat="server" AutoGenerateColumns="False" CssClass="grid-view">
                <Columns>
                    <asp:BoundField DataField="TransactionID" HeaderText="Trans ID" />
                    <asp:BoundField DataField="SportName" HeaderText="Sport" />
                    <asp:BoundField DataField="PackageName" HeaderText="Package" />
                    <asp:BoundField DataField="TransactionDate" HeaderText="Date" DataFormatString="{0:dd-MMM-yyyy hh:mm tt}" />
                    <asp:BoundField DataField="Amount" HeaderText="Amount" DataFormatString="{0:N2}" />
                    <asp:BoundField DataField="ValidityPeriod" HeaderText="Validity" />
                    <asp:BoundField DataField="Status" HeaderText="Status" />
                </Columns>
            </asp:GridView>
        </asp:PlaceHolder>

        <!-- 3. Access Logs Summary View -->
        <asp:PlaceHolder ID="phAccessSummary" runat="server" Visible="false">
            <asp:GridView ID="gvAccessSummary" runat="server" AutoGenerateColumns="False" CssClass="grid-view">
                <Columns>
                    <asp:BoundField DataField="MemberNo" HeaderText="Member No" />
                    <asp:BoundField DataField="MemberName" HeaderText="Member Name" />
                    <asp:BoundField DataField="SportName" HeaderText="Sport" />
                    <asp:BoundField DataField="TotalAccesses" HeaderText="Total Accesses" />
                    <asp:BoundField DataField="GrantedAccesses" HeaderText="Granted" />
                    <asp:BoundField DataField="DeniedAccesses" HeaderText="Denied" />
                </Columns>
            </asp:GridView>
        </asp:PlaceHolder>

        <!-- 4. Access Logs Detailed View -->
        <asp:PlaceHolder ID="phAccessDetails" runat="server" Visible="false">
            <asp:GridView ID="gvAccessDetails" runat="server" AutoGenerateColumns="False" CssClass="grid-view">
                <Columns>
                    <asp:BoundField DataField="LogID" HeaderText="Log ID" />
                    <asp:BoundField DataField="MemberNo" HeaderText="Member No" />
                    <asp:BoundField DataField="MemberName" HeaderText="Member Name" />
                    <asp:BoundField DataField="SportName" HeaderText="Sport" />
                    <asp:BoundField DataField="AccessTime" HeaderText="Access Time" DataFormatString="{0:dd-MMM-yyyy hh:mm tt}" />
                    <asp:BoundField DataField="AccessResult" HeaderText="Result" />
                    <asp:BoundField DataField="DenialReason" HeaderText="Reason (if denied)" />
                </Columns>
            </asp:GridView>
        </asp:PlaceHolder>
    </form>
    <script>
        window.onload = function() {
            setTimeout(function() {
                window.print();
            }, 500);
        };
    </script>
</body>
</html>
