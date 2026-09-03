<%@ Page Title="Member Subscription" Language="C#"
    MasterPageFile="~/hacims_masterpage_admin.master"
    AutoEventWireup="true"
    CodeFile="MemberSearchForSubscription.aspx.cs"
    Inherits="RefundFee.MemberSearchFroSupport" %>

<%@ Register Assembly="AjaxControlToolkit"
    Namespace="AjaxControlToolkit"
    TagPrefix="asp" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <!-- Page Heading -->
    <div style="background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);color:white;text-align:center;border-radius:8px 8px 0 0;box-shadow:0 4px 6px rgba(0,0,0,0.1);">
        <h2 style="margin:0;font-weight:600;letter-spacing:1px;padding:12px;">Member Subscription</h2>
    </div>

    <!-- Subscription Type Selection -->
    <div style="margin-top:20px;background-color:#ffffff;border:1px solid #dee2e6;border-radius:6px;box-shadow:0 2px 4px rgba(0,0,0,0.05);">
        <div style="background-color:#f8f9fa;border-bottom:1px solid #dee2e6;">
            <h4 style="margin:0;font-weight:500;color:#495057;padding:8px 15px;">Select Subscription Type</h4>
        </div>
        <asp:RadioButtonList ID="rblSubscriptionType" runat="server" AutoPostBack="true"
            OnSelectedIndexChanged="rblSubscriptionType_SelectedIndexChanged"
            RepeatDirection="Horizontal"
            Style="margin:15px;display:flex;justify-content:space-around;">
            <asp:ListItem Text="Daily" Value="Daily" style="margin-right:20px;"></asp:ListItem>
            <asp:ListItem Text="Monthly" Value="Monthly" style="margin-right:20px;"></asp:ListItem>
            <asp:ListItem Text="Continue" Value="Continue"></asp:ListItem>
        </asp:RadioButtonList>
    </div>

    <!-- Flex container: Left 50% for subscription popup/read-only, Right 50% for final grid -->
    <div style="display:flex;margin-top:25px;gap:20px;">

        <!-- Left Panel: Popup & Read-only Subscription -->
        <div style="width:50%;">

            <!-- Popup Panel for entering subscription details -->
            <asp:Panel ID="pnlPopup" runat="server" 
                Style="border:1px solid #dee2e6;background-color:#ffffff;border-radius:6px;box-shadow:0 2px 8px rgba(0,0,0,0.08);margin-bottom:20px;"
                Visible="false">
                <div style="background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);color:white;text-align:center;border-radius:5px 5px 0 0;">
                    <h3 style="margin:0;font-weight:500;padding:10px;">Subscription Details</h3>
                </div>
                <table style="width:100%;margin-top:15px;border-collapse:separate;border-spacing:0 10px;">
                    <tr>
    <td style="font-weight:500;color:#495057;text-align:center;width:40%;">Start Date:</td>
    <td style="width:60%;">
        <asp:TextBox ID="txtStartDate" runat="server" AutoPostBack="true" OnTextChanged="txtStartDate_TextChanged" TextMode="Date"
            Style="border:1px solid #ced4da;border-radius:4px;height:34px;box-sizing:border-box;width:calc(100% - 20px);margin-left:10px;">
        </asp:TextBox>

        
        <asp:RequiredFieldValidator ID="rfvStartDate" runat="server"
            ControlToValidate="txtStartDate"
            ErrorMessage="* Start Date is required"
            ForeColor="Red"
            Display="Dynamic"
            Style="margin-left:10px;font-size:12px;">
        </asp:RequiredFieldValidator>
    </td>
</tr>

                    <tr>
                        <td style="font-weight:500;color:#495057;text-align:center;">End Date:</td>
                        <td>
                            <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date"
                                Style="border:1px solid #ced4da;border-radius:4px;height:34px;box-sizing:border-box;width:calc(100% - 20px);margin-left:10px;"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td style="font-weight:500;color:#495057;text-align:center;">Amount:</td>
                        <td>
                            <asp:TextBox ID="txtAmount" runat="server" 
                                Style="border:1px solid #ced4da;border-radius:4px;height:34px;box-sizing:border-box;width:calc(100% - 20px);margin-left:10px;"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td style="font-weight:500;color:#495057;text-align:center;">Booking For:</td>
                        <td>
                            <asp:DropDownList ID="ddlBookingFor" runat="server" 
                                Style="border:1px solid #ced4da;border-radius:4px;height:34px;box-sizing:border-box;width:calc(100% - 20px);margin-left:10px;">
                                <asp:ListItem Text="Self" Value="Self"></asp:ListItem>
                                <asp:ListItem Text="Spouse" Value="Spouse"></asp:ListItem>
                                <asp:ListItem Text="Children" Value="Children"></asp:ListItem>
                                <asp:ListItem Text="Guest" Value="Guest"></asp:ListItem>
                            </asp:DropDownList>
                        </td>
                    </tr>
                    <tr>
                        <td style="font-weight:500;color:#495057;text-align:center;">Department:</td>
                        <td>
                            <asp:DropDownList ID="ddlDepartment" runat="server" AutoPostBack="true"
                                OnSelectedIndexChanged="ddlDepartment_SelectedIndexChanged" 
                                Style="border:1px solid #ced4da;border-radius:4px;height:34px;box-sizing:border-box;width:calc(100% - 20px);margin-left:10px;">
                            </asp:DropDownList>
                        </td>
                    </tr>
                </table>
            </asp:Panel>

            <!-- Read-only panel showing saved subscription -->
            <asp:Panel ID="pnlDisplay" runat="server" Visible="false" 
                Style="border:1px solid #dee2e6;background-color:#ffffff;border-radius:6px;box-shadow:0 2px 8px rgba(0,0,0,0.08);">
                <div style="background: linear-gradient(135deg, #6c757d 0%, #545b62 100%);color:white;text-align:center;border-radius:5px 5px 0 0;">
                    <h3 style="margin:0;font-weight:500;padding:10px;">Booking Details</h3>
                </div>
                <table style="width:100%;margin-top:15px;border-collapse:separate;border-spacing:0 8px;">
                    <tr>
                        <td style="font-weight:500;color:#495057;text-align:center;width:40%;">Subscription Type:</td>
                        <td style="width:60%;">
                            <asp:Label ID="lblSubscriptionType" runat="server"
                                Style="background-color:#f8f9fa;display:inline-block;width:calc(100% - 20px);margin-left:10px;border:1px solid #e9ecef;border-radius:4px;height:30px;line-height:30px;padding-left:8px;"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td style="font-weight:500;color:#495057;text-align:center;">Start Date:</td>
                        <td>
                            <asp:Label ID="lblStartDate" runat="server"
                                Style="background-color:#f8f9fa;display:inline-block;width:calc(100% - 20px);margin-left:10px;border:1px solid #e9ecef;border-radius:4px;height:30px;line-height:30px;padding-left:8px;"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td style="font-weight:500;color:#495057;text-align:center;">End Date:</td>
                        <td>
                            <asp:Label ID="lblEndDate" runat="server"
                                Style="background-color:#f8f9fa;display:inline-block;width:calc(100% - 20px);margin-left:10px;border:1px solid #e9ecef;border-radius:4px;height:30px;line-height:30px;padding-left:8px;"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td style="font-weight:500;color:#495057;text-align:center;">Amount:</td>
                        <td>
                            <asp:Label ID="lblAmount" runat="server"
                                Style="background-color:#f8f9fa;display:inline-block;width:calc(100% - 20px);margin-left:10px;border:1px solid #e9ecef;border-radius:4px;height:30px;line-height:30px;padding-left:8px;"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td style="font-weight:500;color:#495057;text-align:center;">Booking For:</td>
                        <td>
                            <asp:Label ID="lblBookingFor" runat="server"
                                Style="background-color:#f8f9fa;display:inline-block;width:calc(100% - 20px);margin-left:10px;border:1px solid #e9ecef;border-radius:4px;height:30px;line-height:30px;padding-left:8px;"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td style="font-weight:500;color:#495057;text-align:center;">Department:</td>
                        <td>
                            <asp:Label ID="lblDepartment" runat="server"
                                Style="background-color:#f8f9fa;display:inline-block;width:calc(100% - 20px);margin-left:10px;border:1px solid #e9ecef;border-radius:4px;height:30px;line-height:30px;padding-left:8px;"></asp:Label>
                        </td>
                    </tr>
                </table>
            </asp:Panel>
             <div>
                <asp:GridView ID="gvServices" runat="server" AutoGenerateColumns="false" 
                GridLines="Both" BorderStyle="Solid" BorderWidth="1px" 
                Style="width:100%;background-color:#fff;border:1px solid #dee2e6;border-top:none;border-radius:0 0 5px 5px;"
                OnRowCommand="gvServices_RowCommand"
                HeaderStyle-BackColor="#f8f9fa"
                HeaderStyle-Font-Bold="true"
                HeaderStyle-ForeColor="#495057"
                RowStyle-Height="35px"
                AlternatingRowStyle-BackColor="#f8f9fa">
                <Columns>
                    <asp:BoundField DataField="ServiceId" HeaderText="ID" ItemStyle-Width="15%" ItemStyle-HorizontalAlign="Center" />
                    <asp:BoundField DataField="ServiceName" HeaderText="Service Name" ItemStyle-Width="40%" />
                    <asp:BoundField DataField="Amount" HeaderText="Amount" ItemStyle-Width="20%" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="Dept_Name" HeaderText="Department" ItemStyle-Width="15%" />
                    <asp:TemplateField HeaderText="Action" ItemStyle-Width="10%" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <asp:LinkButton ID="lnkAdd" runat="server" CommandName="AddService"
                                CommandArgument='<%# Eval("ServiceId") %>' Text="Add"
                                Style="color:#28a745;text-decoration:none;font-weight:500;background-color:#d4edda;border:1px solid #c3e6cb;border-radius:3px;display:inline-block;height:24px;line-height:24px;width:50px;transition:all 0.2s ease;" 
                                onmouseover="this.style.backgroundColor='#c3e6cb';this.style.color='#155724';"
                                onmouseout="this.style.backgroundColor='#d4edda';this.style.color='#28a745';"></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            </div>

        </div>

        <!-- Right Panel: Final Selected Services -->
       <div style="width:50%;">
    <asp:GridView ID="gvSelectedServices" runat="server" AutoGenerateColumns="false" 
        GridLines="Both" BorderStyle="Solid" BorderWidth="1px" 
        Style="width:100%;background-color:#fff;border:1px solid #dee2e6;border-top:none;border-radius:0 0 5px 5px;"
        OnRowCommand="gvSelectedServices_RowCommand"
        HeaderStyle-BackColor="#f8f9fa"
        HeaderStyle-Font-Bold="true"
        HeaderStyle-ForeColor="#495057"
        RowStyle-Height="35px"
        AlternatingRowStyle-BackColor="#f8f9fa">
        <Columns>
            <asp:BoundField DataField="ServiceId" HeaderText="ID" ItemStyle-Width="15%" ItemStyle-HorizontalAlign="Center" />
            <asp:BoundField DataField="ServiceName" HeaderText="Service Name" ItemStyle-Width="40%" />
            <asp:BoundField DataField="Amount" HeaderText="Amount" ItemStyle-Width="20%" ItemStyle-HorizontalAlign="Right" />
            <asp:BoundField DataField="Dept_Name" HeaderText="Department" ItemStyle-Width="15%" />
            <asp:TemplateField HeaderText="Action" ItemStyle-Width="10%" ItemStyle-HorizontalAlign="Center">
                <ItemTemplate>
                    <asp:LinkButton ID="lnkRemove" runat="server" CommandName="RemoveService"
                        CommandArgument='<%# Eval("ServiceId") %>' Text="Remove" 
                        Style="color:#dc3545;text-decoration:none;font-weight:500;
                               background-color:#f8d7da;border:1px solid #f5c6cb;border-radius:3px;
                               display:inline-block;height:24px;line-height:24px;width:70px;
                               transition:all 0.2s ease;"
                        onmouseover="this.style.backgroundColor='#f5c6cb';this.style.color='#721c24';"
                        onmouseout="this.style.backgroundColor='#f8d7da';this.style.color='#dc3545';"></asp:LinkButton>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>

    <!-- Centered Save Subscription Button -->
    <div style="width:100%;display:flex;justify-content:center;margin-top:15px;">
        <asp:Button ID="btnSave" runat="server" Text="Save Subscription" OnClick="btnSave_Click" 
            Style="background: linear-gradient(135deg, #28a745 0%, #1e7e34 100%);
                   color:white;border:none;cursor:pointer;width:200px;height:40px;border-radius:4px;
                   font-weight:500;letter-spacing:0.5px;transition:all 0.3s ease;" />
    </div>
</div>

</asp:Content>