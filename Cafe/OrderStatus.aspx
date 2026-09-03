<%@ Page Title="Order Status" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master"
    AutoEventWireup="true" CodeFile="OrderStatus.aspx.cs" Inherits="Pos" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        function confirmAction(msg) {
            return confirm(msg);
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:HiddenField ID="hfSelectedBillId" runat="server" />
    <div style="margin: 30px auto; background: #ffffff; border-radius: 12px; box-shadow: 0 8px 20px rgba(0,0,0,0.1); font-family: 'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;">
        <h3 style="background-color: #28a745; color: #fff; text-align: center;">Order Management</h3>
        <div style="display: flex; flex-wrap: wrap; margin: 10px;">
            <div style="margin-right: 10px;">
                <asp:Label runat="server" Text="Bill ID" Style="display: block;"></asp:Label>
                <asp:TextBox ID="txtBillId" runat="server" Style="border: 1px solid #ccc;"></asp:TextBox>
            </div>
            <div style="margin-right: 10px;">
                <asp:Label runat="server" Text="Member No" Style="display: block;"></asp:Label>
                <asp:TextBox ID="txtMemberNo" runat="server" Style="border: 1px solid #ccc;"></asp:TextBox>
            </div>
            <div style="align-self: flex-end;">
                <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click"
                    Style="background-color: #007bff; color: #fff; border: none; cursor: pointer;" />
            </div>
        </div>


        <div style="width: 100%; display: flex; margin: 10px;">

            <div style="flex: 0 0 30%; margin-right: 10px;">
                <h4>Orders (Pending)</h4>

                <asp:GridView ID="gvBills" runat="server"
                    AutoGenerateColumns="False"
                    DataKeyNames="Id"
                    OnRowCommand="gvBills_RowCommand"
                    Style="width: 100%; border-collapse: collapse; border: 1px solid #ccc;">

                    <Columns>
                        <asp:BoundField DataField="Id" HeaderText="Bill ID" />
                        <asp:BoundField DataField="MemberNo" HeaderText="Member No" />


                        <asp:TemplateField HeaderText="View">
                            <ItemTemplate>
                                <asp:Button ID="btnView" runat="server"
                                    Text="Open →"
                                    CommandName="ViewBill"
                                    CommandArgument='<%# Eval("Id") %>'
                                    Style="background: #6c757d; color: #fff; border: none; padding: 5px 8px; cursor: pointer;" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>


            <div style="flex: 0 0 70%;">

                <asp:Panel ID="pnlBillItems" runat="server" Visible="false">

                    <h4>Bill Items</h4>

                    <asp:GridView ID="gvBillItems" runat="server"
                        AutoGenerateColumns="False"
                        ShowFooter="true"
                        OnRowDataBound="gvBillItems_RowDataBound"
                        Style="border-collapse: collapse; width: 100%; border: 1px solid #ccc;">

                        <Columns>
                            <asp:BoundField DataField="Name" HeaderText="Item Name" />
                            <asp:BoundField DataField="Quantity" HeaderText="Qty" />

                            <asp:TemplateField HeaderText="Price">
                                <ItemTemplate>
                                    <%# Eval("Price") %>
                                </ItemTemplate>

                                <FooterTemplate>
                                    <span style="font-weight: bold;">Total:
                                        <asp:Label ID="lblFooterTotal" runat="server"></asp:Label>
                                    </span>
                                </FooterTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>




                    <div style="margin-top: 10px; text-align: center;">
                        <asp:Button ID="btnOrderReady" runat="server"
                            Text="Order Ready"
                            OnClick="btnOrderReady_Click"
                            Style="background: #ffc107; color: #000; border: none;" />

                        <asp:Button ID="btnMoveDine" runat="server"
                            Text="Move to Dine"
                            OnClick="btnMoveDine_Click"
                            Style="background: #17a2b8; color: #fff; border: none;" />
                    </div>

                </asp:Panel>

            </div>

        </div>


    </div>
</asp:Content>

