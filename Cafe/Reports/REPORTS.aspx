<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master"
    AutoEventWireup="true" CodeFile="REPORTS.aspx.cs"
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

    


        <div style="text-align:center; margin-top:20px;">
            <asp:Button ID="btnShow"
                runat="server"
                Text="Show Report"
                OnClick="btnShow_Click"
                Width="150px" Height="40px" />
        </div>

        <div style="margin-top:20px;">
            <%-- ReportViewer disabled --%>
        </div>

    

</asp:Content>

