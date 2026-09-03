<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" AutoEventWireup="true" CodeFile="BookingMenuSearch.aspx.cs" Inherits="Store_BookingMenuSearch" %>

<%-- Register Assembly ReportViewer disabled --%>

<%-- Register Assembly AjaxControlToolkit disabled --%>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
      <script>
          function ClientItemSelected2(sender, e) {
              $get("<%=hfCategory.ClientID %>").value = e.get_value();
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">
    <asp:ScriptManager ID="ScrMn" runat="server"></asp:ScriptManager>
    <div class="bxmain inner_content" style="width: 100%;">

         <div>
<h2 style="color: red; 
           font-size: 24px; 
           font-family: 'Arial', sans-serif; 
           font-weight: bold; 
           display: block; 
           margin-bottom: 10px; 
           text-align: center; 
           text-transform: uppercase; 
           letter-spacing: 1px;">
    Booking Details
</h2>
      </div>
        <div>
            <table class="auto-style1" style="border-collapse: collapse; width: 100%; margin: 20px 0; border: 1px solid #ddd;">
                <tr style="background-color: #f2f2f2;">
                    <td style="border: 1px solid #ddd; padding: 3px;">
                        <h5>Member Ship No:</h5>
                    </td>
                    <td style="border: 1px solid #ddd; padding: 3px;">
                        <asp:TextBox ID="txtmemberNo" runat="server" OnTextChanged="txtmemberNo_TextChanged" AutoPostBack="true"  Width="300px"></asp:TextBox>
                        <%-- AutoCompleteExtender disabled --%>
                     <asp:HiddenField ID="hfCategory" runat="server" />
                                            <asp:Label ID="lblStatus" runat="server" ForeColor="Red"></asp:Label>    

                    </td>
                    <td style="border: 1px solid #ddd; padding: 3px;">
                        <h5>Member:</h5>
                    </td>
                    <td style="border: 1px solid #ddd; padding: 3px;">
                        <asp:DropDownList ID="ddlMember" Height="25px" Width="300px" runat="server"></asp:DropDownList>
                    </td>
                    <td style="border: 1px solid #ddd; padding: 3px;">
                        <h5>Event Place:</h5>
                    </td>
                    <td style="border: 1px solid #ddd; padding: 3px;">
                        <asp:DropDownList ID="DdlEvent" Height="25px" Width="300px" runat="server"></asp:DropDownList>
                    </td>
                   


                </tr>
                <tr style="background-color: #f9f9f9;">
                    <td style="border: 1px solid #ddd; display:none; padding: 3px;">
                       
                    </td>
                      
                    <td style="border: 1px solid #ddd; display:none; padding: 3px;">
                        <h5>Contact No:</h5>
                    </td>
                    
                    <td style="border: 1px solid #ddd; display:none; padding: 3px;">
                        <asp:TextBox ID="txtContact" Width="293px" runat="server"></asp:TextBox>
                    </td>
                    <td style="border: 1px solid #ddd; display:none; padding: 3px;">
                        <h5>Total Person:</h5>
                    </td>
                    <td style="border: 1px solid #ddd; display:none; padding: 3px;">
                        <asp:TextBox ID="txtPerson" Width="293px" Text="1" runat="server" AutoPostBack="true" ></asp:TextBox>
                    </td>
                </tr>
                <tr style="background-color: #f2f2f2;">

                     <td style="border: 1px solid #ddd; padding: 3px;">
                        <h5>Event Name:</h5>
                    </td>
                    <td style="border: 1px solid #ddd; padding: 3px;">
                        <asp:TextBox ID="txtName" Width="293px" runat="server"></asp:TextBox>
                    </td>
                    <td style="border: 1px solid #ddd;  padding: 3px;">
                        <h5>From Date:</h5>
                    </td>
                    <td style="border: 1px solid #ddd;  padding: 3px;">
                    <asp:TextBox ID="txtFromDate" runat="server" TextMode="Date" Width="293px"></asp:TextBox>
                    </td>
                     <td style="border: 1px solid #ddd;  padding: 3px;">
                        <h5>ToDate:</h5>
                    </td>
                    <td style="border: 1px solid #ddd;  padding: 3px;">
                    <asp:TextBox ID="txtToDate" runat="server" TextMode="Date" Width="293px"></asp:TextBox>
                    </td>
                    
                   
                </tr>
              
            </table>
        </div>


       <div style=" justify-content: center; align-items: center;">
    <table style="text-align: center; ">
        <tr>
            <td style="padding-left: 619px;" >
                <asp:Button ID="Button1" runat="server" Text="Search" OnClick="Button1_Click" />
                                <asp:Button ID="btnReport" runat="server" Text="Report" OnClick="btnReport_Click" />

            </td>
            
        </tr>
    </table>
</div>



        
        <table style="width: 100%; margin: auto">


            <tr>

                <td align="center" colspan="4">
                
     
    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False"
              Width="100%"  EmptyDataText="No Record(s) Found." ShowFooter="true" >
    <FooterStyle CssClass="GridPager" />
    <RowStyle CssClass="GridItem" />
    <HeaderStyle CssClass="GridHeader" />
    <AlternatingRowStyle CssClass="GridAltItem" />
    <Columns>
        <asp:TemplateField HeaderText="Sr#">
             <HeaderStyle Width="50px" />
            <ItemStyle Width="50px" />
            <ItemTemplate>
                <%# Container.DataItemIndex + 1 %>
            </ItemTemplate>
        </asp:TemplateField>
     <asp:BoundField DataField="MemberShipNo" HeaderText="MemberShip No" SortExpression="MemberShipNo" >  <ItemStyle Width="150px" />
</asp:BoundField>
        <asp:BoundField DataField="Member_Name" HeaderText="Member" SortExpression="Member_Name">  <ItemStyle Width="250px" /></asp:BoundField> 
<asp:BoundField DataField="Event_Place" HeaderText="Event Place" SortExpression="Event_Place"><ItemStyle Width="300px" /></asp:BoundField>        
    <asp:BoundField DataField="Party_Name" HeaderText="Event Name" SortExpression="Party_Name"><ItemStyle Width="300px" /></asp:BoundField>        
   
<asp:BoundField DataField="Total_Person" HeaderText="Total Person" SortExpression="Total_Person"><ItemStyle Width="300px" /></asp:BoundField>        

<%--<asp:BoundField DataField="ItemName" HeaderText="Item Name" SortExpression="ItemName"><ItemStyle Width="300px" /></asp:BoundField>--%>        

                <asp:TemplateField HeaderText="Generate" ItemStyle-Width="100px" HeaderStyle-Font-Size="14px" ItemStyle-HorizontalAlign="Center">
    <ItemTemplate>
        <asp:HyperLink 
            ID="hlViewDetails" 
            runat="server" 
      NavigateUrl  ='<%# "~/store/IPOItemWise.aspx?Ty=MR&BookingMain_Id=" + Eval("BookingMain_Id") %>'
            Text="Generate" />
    </ItemTemplate>
</asp:TemplateField>
     <asp:TemplateField HeaderText="Report" ItemStyle-Width="100px" HeaderStyle-Font-Size="14px" ItemStyle-HorizontalAlign="Center">
    <ItemTemplate>
        <asp:Button 
            ID="btnGenerateReport" 
            runat="server" 
            Text="Report" 
            OnClick="btnGenerateReport_Click" 
            CommandArgument='<%# Eval("BookingMain_Id") %>' />
    </ItemTemplate>
</asp:TemplateField>

      
    </Columns>
</asp:GridView>
                </td>
            </tr>
            <tr>
                <td>
                      <div style="width:100% ; height:auto">
        <%-- ReportViewer disabled --%>
    </div>
                </td>
            </tr>

        </table>
      
    </div>
      <div style="margin-top:20px; display: flex; justify-content: flex-end;">
    <td colspan="4" style="border: 1px solid #ddd; padding: 3px; text-align:start;">
        <asp:Button ID="btnSave" runat="server" Text="Save "
            Style="background-color:#209d85; color: black; padding: 0px 20px; margin-left:200px;color:white; border: none; border-radius: 5px; cursor: pointer; width: 100px"
            OnClientClick="this.style.opacity=0.7;"  Visible="false" />
    </td>
<asp:Label ID="lblMessage" runat="server" Text=""
           Style="color: #fff; font-size: 18px; padding: 10px; border-radius: 5px; font-family: Arial, sans-serif;"></asp:Label>
</div>


    <div>
        <%-- ReportViewer disabled --%>
    </div>
</asp:Content>




