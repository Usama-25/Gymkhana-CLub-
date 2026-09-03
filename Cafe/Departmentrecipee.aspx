<%@ Page Language="C#" AutoEventWireup="true" CodeFile="DepartmentRecipee.aspx.cs" Inherits="Pos" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Recipe DepartmentWise</title>
    <style>
        body {
            background: linear-gradient(135deg,#ffecd2,#fcb69f);
            font-family:'Segoe UI', sans-serif;
        }

        .card {
            background:#fff;
            width:95%;
            margin:30px auto;
            padding:25px;
            border-radius:15px;
            box-shadow:0 10px 30px rgba(0,0,0,0.2);
        }

        h2 {
            text-align:center;
            color:#ff512f;
            margin-bottom:25px;
        }

        .form-group {
            margin-bottom:20px;
        }

        .btn-save, .btn-add {
            background:linear-gradient(45deg,#ff512f,#dd2476);
            color:#fff;
            border:none;
            padding:10px 25px;
            font-size:16px;
            border-radius:25px;
            cursor:pointer;
            margin-top:10px;
        }

        .btn-save:hover, .btn-add:hover {
            opacity:0.9;
        }

        .grid th {
            background:#ff512f;
            color:#fff;
            padding:10px;
        }

        .grid td {
            padding:8px;
        }

        .gv-container {
            max-height:400px;
            overflow-y:auto;
        }

        .input-price {
            width:80px;
        }
    </style>
</head>
<body>
    <form runat="server">
        <div class="card">
            <h2>🍽️ Recipe DepartmentWise</h2>

            <div class="form-group">
                <label><b>Select Department:</b></label>
                <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-control" Width="300px"></asp:DropDownList>
            </div>

            <div class="gv-container">
                <asp:GridView ID="gvItems" runat="server" AutoGenerateColumns="false" CssClass="grid" Width="100%" GridLines="None"
                    OnRowDataBound="gvItems_RowDataBound">
                    <Columns>
                        <asp:TemplateField HeaderText="Select">
                            <ItemTemplate>
                                <asp:CheckBox ID="chkSelect" runat="server" />
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="ItemCode" HeaderText="Item Code" />
                        <asp:BoundField DataField="ItemName" HeaderText="Item Name" />

                        <asp:TemplateField HeaderText="Category">
                            <ItemTemplate>
                                <asp:DropDownList ID="ddlCategory" runat="server"></asp:DropDownList>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Half Price">
                            <ItemTemplate>
                                <asp:TextBox ID="txtHalfPrice" runat="server" CssClass="input-price" Text="0"></asp:TextBox>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Full Price">
                            <ItemTemplate>
                                <asp:TextBox ID="txtFullPrice" runat="server" CssClass="input-price" Text="0"></asp:TextBox>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <div style="text-align:center">
                <asp:Button ID="btnAddSelection" runat="server" Text="➕ Add Selected Items" CssClass="btn-add" OnClick="btnAddSelection_Click" />
            </div>

            <br />

            <h3 style="color:#ff512f;">Selected Items</h3>
            <div class="gv-container">
                <asp:GridView ID="gvSelected" runat="server" AutoGenerateColumns="false" CssClass="grid" Width="100%" GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="ItemCode" HeaderText="Item Code" />
                        <asp:BoundField DataField="ItemName" HeaderText="Item Name" />
                        <asp:BoundField DataField="Category" HeaderText="Category" />
                        <asp:BoundField DataField="HalfPrice" HeaderText="Half Price" DataFormatString="{0:N2}" />
                        <asp:BoundField DataField="FullPrice" HeaderText="Full Price" DataFormatString="{0:N2}" />
                    </Columns>
                </asp:GridView>
            </div>

            <div style="text-align:center">
                <asp:Button ID="btnFinalSave" runat="server" Text="💾 Save All Selected Items" CssClass="btn-save" OnClick="btnFinalSave_Click" />
            </div>
        </div>
    </form>
</body>
</html>
