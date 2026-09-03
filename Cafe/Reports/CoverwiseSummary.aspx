<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" AutoEventWireup="true" CodeFile="CoverwiseSummary.aspx.cs" Inherits="CoverwiseSummary" %>

<%-- Register Assembly Infragistics disabled --%>
<%-- Register Assembly ReportViewer disabled --%>
<%-- Register Assembly AjaxControlToolkit disabled --%>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <style type="text/css">
        .style1 {
            width: 100%;
            text-align: center;
        }

        .style2 {
            width: 50%;
            text-align: right;
        }

        .style3 {
            width: 50%;
            text-align: left;
        }

        .auto-style1 {
            width: 50%;
            text-align: right;
            font-weight: bold;
        }
    </style>
    <script type="text/javascript">
        function ClientItemSelected2(sender, e) {
            $get("<%=hfItemCode.ClientID %>").value = e.get_value();
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <asp:ScriptManager ID="ToolkitScriptManager1" runat="server">
    </asp:ScriptManager>


    <div class="bxmain inner_content" style="width: 100%;">
        <h2><span>Cash Sale Detail</span></h2>
        <table class="style1">
            <tr>
                 <td class="auto-style1">Location</td>
                <td class="style3">
                    <asp:DropDownList ID="ddlSubDept" runat="server"></asp:DropDownList>
                </td>
            </tr>
            <tr>
                <td class="auto-style1">Start Date :</td>
                <td class="style3">
                    <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date"  >
                    </asp:TextBox>
                </td>
            </tr>
            <tr>
                <td class="auto-style1">End Date :
                </td>
                <td class="style3">
                    <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date">
                    </asp:TextBox>
                </td>
            </tr>
            <tr>
                <td class="auto-style1">Item Name :
                </td>
                <td class="style3">
                    <asp:TextBox ID="txtItemName" runat="server" OnTextChanged="txtItemName_TextChanged"></asp:TextBox>
                    <%-- AutoCompleteExtender disabled --%>
                    <asp:HiddenField ID="hfItemCode" runat="server" />

                </td>
            </tr>
            <tr>
                <td colspan="2" align="center">
                    <asp:Button ID="Button_report" runat="server" Text="View Report"
                        OnClick="Button_Report_Click" CssClass="btn_1" />
                </td>
            </tr>

        </table>
    </div>
    <div>
        <%-- ReportViewer disabled --%>
    </div>
</asp:Content>





