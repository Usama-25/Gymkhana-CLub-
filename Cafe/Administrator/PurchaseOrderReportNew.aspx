<%@ page language="VB" autoeventwireup="false" inherits="Store_Administrator_PurchaseOrderReportNew" CodeFile="PurchaseOrderReportNew.aspx.vb" 
    MasterPageFile="~/MasterPages/GymkhanaMaster.master" enableEventValidation="false"  viewStateEncryptionMode="Never" maintainScrollPositionOnPostBack="true" %>

<%-- Register Assembly ReportViewer disabled --%>

 <asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server"></asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <asp:ScriptManager ID="ScriptManager1" runat="server">
    </asp:ScriptManager>
    <%-- ReportViewer disabled --%>
        <asp:HiddenField ID="HiddenField_Discount" runat="server" />
        <asp:HiddenField ID="HiddenField_Tax" runat="server" />
    
</asp:Content>


