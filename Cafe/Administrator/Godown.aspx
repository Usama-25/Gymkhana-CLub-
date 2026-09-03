<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" AutoEventWireup="true" CodeFile="Godown.aspx.cs" Inherits="Store_Godown" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
</asp:Content>
<asp:Content ID="ConDropDownList_Category2tent2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div class="bxmain">
 <div class="bxmain inner_content" >
        <h2>
            <span>GoDown</span></h2>
           <table cellpadding="0" cellspacing="0" border="0" width="100%" class="tbl_form">
            <tr>
               
                <td width="25%" align="right">
                    GoDown Name :
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
        <asp:GridView ID="gridGoDown" runat="server"
            Width="100%" AutoGenerateColumns="False" DataKeyNames="Godown_ID" DataSourceID="SqlDataSource2">

            <Columns>
                <asp:CommandField ShowEditButton="True" ShowDeleteButton="True"></asp:CommandField>
                <asp:BoundField DataField="Godown_ID" HeaderText="Godown ID" ReadOnly="True" InsertVisible="False" SortExpression="Godown_ID"></asp:BoundField>
                <asp:BoundField DataField="Godown_Name" HeaderText="Godown Name" SortExpression="Godown_Name"></asp:BoundField>
                <asp:BoundField DataField="SubDept_Name" HeaderText="Department" ReadOnly="True" InsertVisible="False" SortExpression="SubDept_Name"></asp:BoundField>
            </Columns>
        </asp:GridView>

        <asp:SqlDataSource runat="server" ID="SqlDataSource2" ConnectionString='<%$ConnectionStrings:STOREConnectionString %>'
             DeleteCommand="DELETE FROM [Godown] WHERE [Godown_ID] = @Godown_ID" 
            InsertCommand="INSERT INTO [Godown] ([Godown_Name]) VALUES (@Godown_Name)"
             SelectCommand="SELECT  G.Godown_ID,G.Godown_Name,S.SubDept_Name FROM Godown as G INNER JOIN SubDepartment as S on G.Godown_ID=S.SubDept_Id" 
            UpdateCommand="UPDATE [Godown] SET [Godown_Name] = @Godown_Name WHERE [Godown_ID] = @Godown_ID">
            <DeleteParameters>
                <asp:Parameter Name="Godown_ID" Type="Int32"></asp:Parameter>
            </DeleteParameters>
            <InsertParameters>
                <asp:Parameter Name="Godown_Name" Type="String"></asp:Parameter>
            </InsertParameters>
            <UpdateParameters>
                <asp:Parameter Name="Godown_Name" Type="String"></asp:Parameter>
                <asp:Parameter Name="Godown_ID" Type="Int32"></asp:Parameter>
            </UpdateParameters>
        </asp:SqlDataSource>
    </div>
</asp:Content>


