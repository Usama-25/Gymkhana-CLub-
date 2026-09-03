<%@ Page Title="Order Status" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master"
    AutoEventWireup="true" CodeFile="GenerateBill.aspx.cs" Inherits="Pos" %>

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
        <h3 style="background-color: #28a745; color: #fff; text-align: center;">Generate Bill</h3>
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
                <h4>Dine Orders</h4>

                <asp:GridView ID="gvBills" runat="server"
                    AutoGenerateColumns="False"
                    DataKeyNames="Id"
                    OnRowCommand="gvBills_RowCommand"
                    Style="width: 100%; border-collapse: collapse; border: 1px solid #ccc;">

                    <Columns>
                        <asp:BoundField DataField="Id" HeaderText="Bill ID" />
                        <asp:BoundField DataField="MemberNo" HeaderText="Member No" />
                        <asp:BoundField DataField="Total" HeaderText="Total" DataFormatString="{0:0.00}" />

                        <asp:TemplateField HeaderText="Select">
                            <ItemTemplate>
                                <asp:Button ID="btnSelect" runat="server"
                                    Text="Select"
                                    CommandName="SelectBill"
                                    CommandArgument='<%# Eval("Id") %>'
                                    Style="background: #28a745; color: #fff; border: none; padding: 5px 8px; cursor: pointer;" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>


            <div style="flex: 0 0 70%;">

                <asp:Panel ID="pnlBillItems" runat="server" Visible="false">

                    <h4>Bill Details</h4>

                    <asp:GridView ID="gvBillItems" runat="server"
                        AutoGenerateColumns="False"
                        ShowFooter="true"
                        OnRowDataBound="gvBillItems_RowDataBound"
                        Style="border-collapse: collapse; width: 100%; border: 1px solid #ccc;">

                        <Columns>
                            <asp:BoundField DataField="Name" HeaderText="Item Name" />
                            <asp:BoundField DataField="Quantity" HeaderText="Qty" />
                            <asp:BoundField DataField="Price" HeaderText="Price" DataFormatString="{0:0.00}" />
                            <asp:BoundField DataField="ItemTotal" HeaderText="Total" DataFormatString="{0:0.00}" />
                        </Columns>
                    </asp:GridView>

                    <div style="margin-top: 10px; text-align: center;">
                        <asp:Button ID="btnGenerateBill" runat="server"
                            Text="Generate Bill"
                            OnClick="btnGenerateBill_Click"
                            Style="background: #28a745; color: #fff; border: none; padding: 10px 20px; font-size: 16px; font-weight: bold; cursor: pointer;" />
                    </div>

                </asp:Panel>

            </div>

        </div>


    </div>
</asp:Content>
