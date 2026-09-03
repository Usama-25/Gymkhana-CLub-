<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" AutoEventWireup="true" CodeFile="BanquetBookingsearch.aspx.cs" Inherits="BanquetBookingsearch" %>

<%-- Register Assembly ReportViewer disabled --%>

<%-- Register Assembly AjaxControlToolkit disabled --%>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
    
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">
   
    <div class="panel panel-default">
    <div class="panel-heading">
        <h4>Banquet Booking Search</h4>
    </div>

    <div class="panel-body">

        <div class="row">

            <div class="col-md-3">
                <label>Membership No</label>
                <asp:TextBox ID="txtMembershipNo" runat="server"
                    CssClass="form-control"></asp:TextBox>
            </div>

            <div class="col-md-3">
                <label>Party Date</label>
                <asp:TextBox ID="txtPartyDate" runat="server"
                    TextMode="Date"
                    CssClass="form-control"></asp:TextBox>
            </div>

            <div class="col-md-2" style="padding-top:25px;">
                <asp:Button ID="btnSearch"
                    runat="server"
                    Text="Search"
                    CssClass="btn btn-primary"
                    OnClick="btnSearch_Click" />
            </div>

        </div>

        <br />

        <asp:GridView ID="gvBooking"
    runat="server"
    AutoGenerateColumns="False"
    CssClass="table table-bordered table-striped"
    Width="100%">

    <Columns>

        <asp:BoundField DataField="BookingMain_Id" HeaderText="Booking ID" />
        <asp:BoundField DataField="MemberShipNo" HeaderText="Membership No" />
        <asp:BoundField DataField="MemberName" HeaderText="Member Name" />
        <asp:BoundField DataField="Contact_person" HeaderText="Contact Person" />
        <asp:BoundField DataField="Event_Place" HeaderText="Event Place" />
        <asp:BoundField DataField="PartyDate" HeaderText="Date" />
        <asp:BoundField DataField="EventName" HeaderText="Event Name" />
        <asp:BoundField DataField="Total_Person" HeaderText="Persons" />

       
        <asp:TemplateField HeaderText="Ingredients Report">
            <ItemTemplate>
                <asp:Button ID="btnIngredients"
                    runat="server"
                    Text="Print"
                    CssClass="btn btn-success btn-sm"
                    CommandArgument='<%# Eval("BookingMain_Id") %>'
                    OnClick="btnIngredients_Click" />
            </ItemTemplate>
        </asp:TemplateField>

    </Columns>

</asp:GridView>

    </div>
</div>

    
</asp:Content>



