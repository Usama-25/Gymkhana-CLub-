<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" AutoEventWireup="true" CodeFile="GodownLocation.aspx.cs" Inherits="Store_GodownLocation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
</asp:Content>
<asp:Content ID="ConDropDownList_Category2tent2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div class="bxmain">
 <div class="bxmain inner_content" >
        <h2>
            <span>Godown Location</span></h2>
           <table cellpadding="0" cellspacing="0" border="0" width="100%" class="tbl_form">
            <tr>
               
                <td width="25%" align="right">
                    Location Name :
                </td>
                <td width="25%">
                    <asp:TextBox ID="txtboxgodown" runat="server" Width="202px"></asp:TextBox>
                </td>
                 <td width="25%" align="right">
                    
                </td>
                <td width="25%">
                   
                </td>
            </tr>
           
            <tr>
                <td align="right">
                    Department :
                </td>
                <td>
                    <asp:DropDownList ID="ddlDepartment" runat="server" Width="202px"
                        AutoPostBack="True" DataSourceID="SqlDataSource1" DataTextField="SubDept_Name" DataValueField="SubDept_Id">
                    </asp:DropDownList>

                    <asp:SqlDataSource runat="server" ID="SqlDataSource1" 
                        ConnectionString='<%$ ConnectionStrings:Basic_Data_ConnectionString %>' 
                        SelectCommand="SELECT [SubDept_Id], [SubDept_Name] FROM [SubDepartment]"></asp:SqlDataSource>
                </td>
                <td align="right">
                    
                </td>
                <td>
                
                </td>
            </tr>
             
            <tr>
                <td align="right">
                  
                </td>
                <td>
                   <asp:Button runat="server" ID="btnSave" Text="Save" onclick="btnSave_Click" />
                    <asp:Label ID="lblText" runat="server"></asp:Label>
                </td>
                <td align="right">
                   
                </td>
                <td>
                   
                </td>
            </tr>
            </table>
            <br />
            </div>  
        <asp:GridView ID="gridGodownLocation" runat="server"
            Width="100%" AutoGenerateColumns="False" DataKeyNames="Location_ID" DataSourceID="SqlDataSource2">

            <Columns>
                <asp:CommandField ShowEditButton="True" ShowDeleteButton="True"></asp:CommandField>
                <asp:BoundField DataField="Location_ID" HeaderText="Location ID" ReadOnly="True" InsertVisible="False" SortExpression="Location_ID"></asp:BoundField>
                <asp:BoundField DataField="Location_Name" HeaderText="Location Name" SortExpression="Location_Name"></asp:BoundField>
                <asp:BoundField DataField="SubDept_Name" HeaderText="Department" ReadOnly="True" InsertVisible="False" SortExpression="Subdept_ID" ></asp:BoundField>
            </Columns>
        </asp:GridView>


        <asp:SqlDataSource runat="server" ID="SqlDataSource2" ConnectionString='<%$ ConnectionStrings:STOREConnectionString %>'
             DeleteCommand="DELETE FROM [GodownLocation] WHERE [Location_ID] = @Location_ID"
             InsertCommand="INSERT INTO [GodownLocation] ([Location_Name], [Subdept_ID]) VALUES (@Location_Name, @Subdept_ID)" 
            SelectCommand="SELECT G.Location_ID,G.Location_Name,S.SubDept_Name FROM GodownLocation as G INNER JOIN SubDepartment as S on G.Location_ID=S.SubDept_Id" 
            UpdateCommand="UPDATE [GodownLocation] SET [Location_Name] = @Location_Name, [Subdept_ID] = @Subdept_ID WHERE [Location_ID] = @Location_ID">
            <DeleteParameters>
                <asp:Parameter Name="Location_ID" Type="Int32"></asp:Parameter>
            </DeleteParameters>
            <InsertParameters>
                <asp:Parameter Name="Location_Name" Type="String"></asp:Parameter>
                <asp:Parameter Name="Subdept_ID" Type="Int32"></asp:Parameter>
            </InsertParameters>
            <UpdateParameters>
                <asp:Parameter Name="Location_Name" Type="String"></asp:Parameter>
                <asp:Parameter Name="Subdept_ID" Type="Int32"></asp:Parameter>
                <asp:Parameter Name="Location_ID" Type="Int32"></asp:Parameter>
            </UpdateParameters>
        </asp:SqlDataSource>
    </div>
</asp:Content>


