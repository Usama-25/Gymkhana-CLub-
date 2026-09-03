<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" AutoEventWireup="true" CodeFile="EmployeeReferDepartment.aspx.cs" Inherits="Store_EmployeeReferDepartment" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style type="text/css">
        .auto-style1 {
            height: 18px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div class="bxmain">
        <div class="bxmain inner_content">     
    <h2>Employee Refer Department</h2>
        
    <div style="text-align: center;width:542px; margin-left: 370px; margin-top: 10px; height: 123px">
        <table runat="server">
           
            <tr>
                <td style="text-align: right" class="auto-style1"><label id="lblstatus" runat="server" style="font-size:medium; width: 196px;">Sub Department : </label></td>
                <td style="margin-left:10px" class="auto-style1">
                     <asp:TextBox ID="txtsubDept" runat="server" Width="45%" OnTextChanged="txtsubDept_TextChanged" AutoPostBack="True"></asp:TextBox>
                   &nbsp;&nbsp;&nbsp;
                    <asp:DropDownList ID="ddl_subDept" runat="server" Height="31px"  Width="45%" AutoPostBack="True"  >
                           
                        </asp:DropDownList>
                </td>
            </tr>
             <tr>
                <td style="text-align: right"><label style="font-size:medium; width: 196px;">Employee: </label>
                 </td>
                <td style="margin-left:10px">
                    <asp:TextBox ID="txtemployee" runat="server" Width="130px" OnTextChanged="txtemployee_TextChanged" AutoPostBack="True"></asp:TextBox>
                    &nbsp;&nbsp;&nbsp;
                    <asp:DropDownList ID="ddl_employee" runat="server" Height="31px" Width="130px">
                           
                        </asp:DropDownList>
                </td>
            </tr>
           
            <tr colspan="2">
                <td></td>
                <td>
                    &nbsp;
                    <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click" />
                &nbsp;
                    <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click" />
                </td>
            </tr>
        </table>
         
    </div>
    <div style="margin-top:50px;text-align:center;overflow-y:scroll">
        <asp:GridView ID="GridView1" CssClass="Grid_1" runat="server"  AutoGenerateColumns="false" EmptyDataText="No Record Found !!">
            <Columns >
               
                 <asp:TemplateField  HeaderText="ID">
                    <ItemTemplate >
                        <asp:Label ID="lblID" runat="server" Text='<% #Bind("ID") %>' ></asp:Label>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField  HeaderText="Employee Name">
                    <ItemTemplate >
                        <asp:Label ID="lblEmp_Name" runat="server" Text='<% #Bind("EmployeeName") %>' ></asp:Label>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField  HeaderText="Designation">
                    <ItemTemplate>
                        <asp:Label ID="lblDesignation" runat="server" Text='<% #Bind("Designation_Name") %>' ></asp:Label>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField  HeaderText="Assign Dept">
                    <ItemTemplate>
                        <asp:Label ID="lblSubDept_Name" runat="server" Text='<% #Bind("SubDept_Name") %>' ></asp:Label>
                    </ItemTemplate>
                </asp:TemplateField>
                

                <asp:TemplateField HeaderText="Delete">
                    <ItemTemplate>
                        <asp:LinkButton ID="btnDelete" runat="server" CommandArgument='<% #Bind("ID") %>' Text="Delete" onClick="btnDelete_Click"/>
                    </ItemTemplate>
                </asp:TemplateField>

            </Columns>
        </asp:GridView>
        
    </div>
           
</div>           
    </div>
</asp:Content> 



