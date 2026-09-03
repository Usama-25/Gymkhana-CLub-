<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Menu.aspx.cs" Inherits="Restaurant.Menu" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Restaurant Menu</title>
    <style>
        .menu-grid { display:flex; gap:12px; flex-wrap:wrap; }
        .menu-card { border:1px solid #ddd; padding:12px; width:220px; border-radius:6px; }
        .bill-table { width:100%; border-collapse:collapse; margin-top:12px }
        .bill-table th, .bill-table td { border:1px solid #ddd; padding:8px; }
        .action-btn { padding:6px 10px; margin:2px }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <h2>Menu</h2>
        <asp:Repeater ID="rptMenu" runat="server">
            <ItemTemplate>
                <div class="menu-card">
                    <h3><%# Eval("Name") %></h3>
                    <p><%# Eval("Description") %></p>
                    <p><strong><%# String.Format("{0:C}", Eval("Price")) %></strong></p>
                    <asp:Button runat="server" CommandName="Add" CommandArgument='<%# Eval("Id") %>'
                        Text="Add" CssClass="action-btn" OnCommand="Menu_Add" />
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <hr />

        <h2>Current Bill</h2>
        <asp:GridView ID="gvBill" runat="server" AutoGenerateColumns="False"
            DataKeyNames="MenuItemId"
            OnRowEditing="gvBill_RowEditing"
            OnRowCancelingEdit="gvBill_RowCancelingEdit"
            OnRowUpdating="gvBill_RowUpdating"
            OnRowDeleting="gvBill_RowDeleting">
            <Columns>
                <asp:BoundField DataField="Name" HeaderText="Item" ReadOnly="true" />
                <asp:BoundField DataField="Price" HeaderText="Price" DataFormatString="{0:C}" ReadOnly="true" />
                <asp:TemplateField HeaderText="Qty" ItemStyle-Width="80px">
                    <ItemTemplate>
                        <%# Eval("Quantity") %>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtQty" runat="server" Text='<%# Bind("Quantity") %>' Width="60px" />
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Notes">
                    <ItemTemplate>
                        <%# Eval("Notes") %>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtNotes" runat="server" Text='<%# Bind("Notes") %>' Width="100%" />
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="LineTotal" HeaderText="Line" DataFormatString="{0:C}" ReadOnly="true" />
                <asp:CommandField ShowEditButton="True" ShowDeleteButton="True" />
            </Columns>
        </asp:GridView>

        <asp:Panel runat="server" ID="pnlTotals" Visible="true">
            <h3>Total: <asp:Label ID="lblTotal" runat="server" Text="$0.00" /></h3>
        </asp:Panel>

        <asp:Button ID="btnFinalize" runat="server" Text="Finalize Bill" CssClass="action-btn" OnClick="btnFinalize_Click" />

        <asp:Label ID="lblMessage" runat="server" ForeColor="Green" />
        <asp:Label ID="lblError" runat="server" ForeColor="Red" />

        <asp:Panel runat="server" ID="pnlReceipt" Visible="false">
            <hr />
            <h2>Receipt (Saved)</h2>
            <asp:GridView ID="gvReceipt" runat="server" AutoGenerateColumns="False">
                <Columns>
                    <asp:BoundField DataField="Name" HeaderText="Item" />
                    <asp:BoundField DataField="Quantity" HeaderText="Qty" />
                    <asp:BoundField DataField="Notes" HeaderText="Notes" />
                    <asp:BoundField DataField="LineTotal" HeaderText="Line" DataFormatString="{0:C}" />
                </Columns>
            </asp:GridView>
            <h3>Total: <asp:Label ID="lblReceiptTotal" runat="server" /></h3>
        </asp:Panel>
    </form>
</body>
</html>