<%@ page title="" language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" autoeventwireup="true" inherits="Store_SelectedDateStockReport"
     CodeFile="SelectedDateStockReport.aspx.cs" enableEventValidation="false"  viewStateEncryptionMode="Never" maintainScrollPositionOnPostBack="true" %>
<%-- Register Assembly ReportViewer disabled --%>
<%-- Register Assembly AjaxControlToolkit disabled --%>
<%-- Register Assembly Infragistics disabled --%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <script type="text/javascript">
        function ClientItemSelected2(sender, e) {
            $get("<%=hfItemCode.ClientID %>").value = e.get_value();
         }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div class="bxmain inner_content" style="width: 100%; margin-bottom: 10px;">
        <h2><span>Stock Value Report</span></h2>
        <asp:ScriptManager ID="ToolkitScriptManager1" runat="server">
        </asp:ScriptManager>
        <table border="0" cellpadding="0" cellspacing="0" class="tbl_form" width="100%">
           <tr>
               <td align="right" >  Club:</td>
        <td align="left" >
            <asp:DropDownList ID="ddlHospital" runat="server" CssClass="dropbox" align="Left"
           Width="262px" DataSourceID="SDS_Company" DataTextField="Hospital_Name" 
           DataValueField="Hospital_ID" AutoPostBack="True" >
            </asp:DropDownList>
           <asp:SqlDataSource ID="SDS_Company" runat="server"
                        ConnectionString="<%$ ConnectionStrings:Basic_Data_ConnectionString %>"
                        SelectCommand="select 0 As Hospital_ID, '---ALL---' as Hospital_Name union select [Hospital_ID], [Hospital_Name] FROM [Hospital]">

                    </asp:SqlDataSource>
        </td>
 
        <td align="Right" >
            Department : 
        </td>
        <td align="left" >
            <asp:DropDownList ID="Dropdownlistdepartment" runat="server" align="Left"
					 DataSourceID="SqlDataSourceDepartment" DataTextField="Dept_Name"
                      DataValueField="Dept_ID"  CssClass="dropbox" Width="262px" 
            AutoPostBack="True" >
            </asp:DropDownList>
              <asp:SqlDataSource ID="SqlDataSourceDepartment" runat="server" ConnectionString="<%$ ConnectionStrings:Basic_Data_ConnectionString %>"
        ProviderName="<%$ ConnectionStrings:Basic_Data_ConnectionString.ProviderName %>"
        
        SelectCommand="usp_selectDepartment" SelectCommandType="StoredProcedure">
        <SelectParameters>
            <asp:ControlParameter ControlID="ddlHospital" Name="Hospital_ID" 
                PropertyName="SelectedValue" />
            <%--<asp:SessionParameter Name="Emp_ID" SessionField="emp_id" Type="Int32" />--%>
        </SelectParameters>
    </asp:SqlDataSource>
        </td>
   
                        <td align="Right" >
                          Sub Department :
                        </td>
                        <td >
                            <asp:DropDownList ID="DDL_Branch" runat="server"
                        CssClass="drop_down" DataSourceID="SDS_Branch" DataTextField="SubDept_Name"
                        DataValueField="SubDept_Id" AutoPostBack="True">
                    </asp:DropDownList>
                    <asp:SqlDataSource ID="SDS_Branch" runat="server"
                        ConnectionString="<%$ ConnectionStrings:Basic_Data_ConnectionString %>"
                        SelectCommand="datastckrptsbdeps" SelectCommandType="StoredProcedure">
                        <SelectParameters>
                            <asp:ControlParameter ControlID="ddlHospital" Name="HospitalID"
                                PropertyName="SelectedValue" />
                            <asp:ControlParameter ControlID="Dropdownlistdepartment" Name="DeptID"
                                PropertyName="SelectedValue" />
                             <asp:SessionParameter Name="emp_id" SessionField="emp_id" Type="String" />
                
                        </SelectParameters>
                    </asp:SqlDataSource>
                        </td>
             </tr>
              <%--<tr>
                <td align="right" >Sub Department :</td>
                <td align="left" >
                    <asp:DropDownList ID="ddlSubDepartment" runat="server"></asp:DropDownList></td>
            </tr>--%>
            
                          <tr>
                         <td align="right">
                    Item Category :
                </td>
                <td align="left">
                    <asp:DropDownList ID="DropDownList_Category" runat="server" Width="202px" DataSourceID="SqlDataSource_Item_Category"
                        DataTextField="Item_Type" DataValueField="Item_Type_Id" AutoPostBack="True">
                    </asp:DropDownList>
                     <asp:SqlDataSource ID="SqlDataSource_Item_Category" runat="server" ConnectionString="<%$ ConnectionStrings:STOREConnectionString %>"
            SelectCommand="category" SelectCommandType="StoredProcedure">
            <SelectParameters>
                <asp:Parameter DefaultValue="%" Name="Item_Category" Type="String" />
            </SelectParameters>
        </asp:SqlDataSource>
                    
                </td>
                 
                         <td align="right">
                    Item Sub Category :
                </td>
                <td align="left">
                    <asp:DropDownList ID="ddlSubCategory" runat="server" Width="202px" DataSourceID="SqlDataSource_Item_Sub_Category"
                        DataTextField="SubCategory" DataValueField="SubCatId">
                    </asp:DropDownList>
                    <asp:SqlDataSource ID="SqlDataSource_Item_Sub_Category" runat="server" ConnectionString="<%$ ConnectionStrings:STOREConnectionString %>"
            SelectCommand="select 0 as SubCatId,'---ALL---' as SubCategory union select Item_Type_Id as SubCatId,Item_Type as SubCategory from Sub_Category where (Category_id = @ItemTypeId or @ItemTypeId = 0)" >
            <SelectParameters>
               <asp:ControlParameter ControlID="DropDownList_Category" Name="ItemTypeId" PropertyName="SelectedValue" />
            </SelectParameters>
        </asp:SqlDataSource>
                    
                </td>
           
                <td align="right" >From Date :</td>
                <td align="left" >
                     <input type="text" id="txtStartDate" runat="server" class="drop_date" style="width:202px;" />
                </td>
            </tr>
            <tr>
                <td align="right" >To Date :</td>
                <td align="left" >
                     <input type="text" id="txtEndDate" runat="server" class="drop_date" style="width:202px;" />
                </td>
         
                <td align="right" >Item Name :</td>
                <td align="left" >
                    <asp:TextBox ID="txtItemName" runat="server"></asp:TextBox>
                    <%-- AutoCompleteExtender disabled --%>
                    <asp:HiddenField ID="hfItemCode" runat="server" />
                </td>
         <td>&nbsp</td>
                <td align="left" colspan="2">
                    <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click" />
                </td>

            </tr>
        </table>
    </div>
    <%-- ReportViewer disabled --%>
</asp:Content>





