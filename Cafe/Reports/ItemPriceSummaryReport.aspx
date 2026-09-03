<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master"
    AutoEventWireup="true" CodeFile="ItemPriceSummaryReport.aspx.cs"
    Inherits="ItemPriceSummaryReport" %>

<%-- Register Assembly ReportViewer disabled --%>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <style>
        .style1 { width: 100%; text-align: center; }
        .btn_1 { padding:10px 20px; font-size:14px; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <div class="bxmain inner_content" style="width: 100%;">
        <h2><span>Item Price Summary Report</span></h2>

        <table class="style1">
            <tr>
                <td>
                    <asp:Button ID="Button_report"
                        runat="server"
                        Text="View Report"
                        OnClick="Button_Report_Click"
                        CssClass="btn_1" />
                </td>
            </tr>
        </table>
    </div>

    <div style="margin-top:20px;">
        <%-- ReportViewer disabled --%>
    </div>

</asp:Content>

