<%@ Page Language="C#" MasterPageFile="~/GuestRoomM/GuestRoom.master" AutoEventWireup="true" CodeFile="Facility.aspx.cs" Inherits="GuestRoomApp.GuestRoomM.GuestRoomM_Facility" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
        <style type="text/css">

body{
    font-family: Segoe UI, Arial;
    background-color:#f4f6f9;
}

/* Form Container */
.form-table{
    width:100%;
    border-collapse:collapse;
    background:#ffffff;
    border:1px solid #dcdcdc;
    border-radius:5px;
    box-shadow:0 2px 6px rgba(0,0,0,0.08);
}

.form-table td{
    padding:8px 10px;
}

/* Labels */
.label-col{
    width:130px;
    font-weight:600;
    color:#333;
}

/* Textboxes */
input[type=text], textarea{
    padding:6px 8px;
    border:1px solid #c8c8c8;
    border-radius:3px;
    font-size:13px;
}

input[type=text]:focus{
    border-color:#0078d7;
    outline:none;
}

/* Readonly Fields */
.readonly-field{
    background:#eef1f5;
    border:1px solid #cfd6de;
}

/* Tabs */
.tab-button{
    background:#f0f0f0;
    border:1px solid #c8c8c8;
    padding:6px 15px;
    font-size:13px;
    cursor:pointer;
}

.tab-button:hover{
    background:#0078d7;
    color:white;
}

/* Bottom Buttons */
input[type=submit], input[type=button]{
    background:#0078d7;
    color:white;
    border:none;
    padding:6px 14px;
    border-radius:3px;
    font-size:13px;
    cursor:pointer;
}

input[type=submit]:hover,
input[type=button]:hover{
    background:#005fa3;
}

/* GridView */
table[id$="gvRooms"]{
    border-collapse:collapse;
    width:100%;
}

table[id$="gvRooms"] th{
    background:#0078d7;
    color:white;
    padding:6px;
    font-weight:600;
    border:1px solid #dcdcdc;
}

table[id$="gvRooms"] td{
    padding:6px;
    border:1px solid #e0e0e0;
}

table[id$="gvRooms"] tr:nth-child(even){
    background:#f7f9fc;
}

table[id$="gvRooms"] tr:hover{
    background:#e8f2ff;
}

</style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="Server">
    <div style="padding: 20px;">
        <h2>2. Facility Definition</h2>
        
        <div style="margin-bottom: 10px;">
            <asp:Button ID="btnTabFacility" runat="server" Text="Facility" OnClick="SwitchTab" CommandArgument="0" CssClass="tab-button" />
            <asp:Button ID="btnTabAll" runat="server" Text="All" OnClick="SwitchTab" CommandArgument="1" CssClass="tab-button" />
        </div>

        <asp:MultiView ID="mvFacility" runat="server" ActiveViewIndex="0">
            <asp:View ID="viewEntry" runat="server">
                <table class="form-table">
                    <tr>
                        <td class="label-col">Facility ID:</td>
                        <td>
                            <asp:TextBox ID="txtFacilityID" runat="server" MaxLength="5" Width="100px" />
                            <asp:RequiredFieldValidator ID="rfvID" runat="server" ControlToValidate="txtFacilityID" ErrorMessage="*" ForeColor="Red" ValidationGroup="save" />
                        </td>
                    </tr>
                    <tr>
                        <td class="label-col">Facility Name:</td>
                        <td>
                            <asp:TextBox ID="txtFacilityName" runat="server" Width="350px" MaxLength="100" />
                            <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtFacilityName" ErrorMessage="*" ForeColor="Red" ValidationGroup="save" />
                        </td>
                    </tr>
                    <tr>
                        <td class="label-col">Charges:</td>
                        <td>
                            <asp:TextBox ID="txtCharges" runat="server" MaxLength="9" />
                            <asp:RequiredFieldValidator ID="rfvCharges" runat="server" ControlToValidate="txtCharges" ErrorMessage="*" ForeColor="Red" ValidationGroup="save" />
                        </td>
                    </tr>
                </table>
            </asp:View>

            <asp:View ID="viewList" runat="server">
                <asp:GridView ID="gvFacilities" runat="server" AutoGenerateColumns="False" Width="100%" 
                    CssClass="form-table" OnSelectedIndexChanged="gvFacilities_SelectedIndexChanged">
                    <Columns>
                        <asp:CommandField ShowSelectButton="True" SelectText="Edit" />
                        <asp:BoundField DataField="FacilityID" HeaderText="ID" />
                        <asp:BoundField DataField="FacilityName" HeaderText="Name" />
                        <asp:BoundField DataField="Charges" HeaderText="Charges" />
                    </Columns>
                </asp:GridView>
            </asp:View>
        </asp:MultiView>

        <div style="margin-top: 15px; padding: 10px; border-top: 1px solid #ccc;">
            <asp:Button ID="btnAdd" runat="server" Text="Add New" OnClick="btnAdd_Click" />
            <asp:Button ID="btnModify" runat="server" Text="Modify" OnClick="btnModify_Click" />
            <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click" ValidationGroup="save" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
        </div>
    </div>
</asp:Content>
