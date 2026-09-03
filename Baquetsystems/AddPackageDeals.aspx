<%@ Page Title="Add Package Deals" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" AutoEventWireup="true" CodeFile="AddPackageDeals.aspx.cs" Inherits="AddPackageDeals" %>

<asp:Content ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .add-package-deals-page {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }

        .add-package-deals-page .page-header {
            background-color: var(--surface);
            padding: 1.5rem;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
        }

        .add-package-deals-page .page-header h1 {
            font-size: 1.5rem;
            color: var(--primary-dark);
            font-weight: 700;
        }

        .add-package-deals-page .form-card {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            padding: 1.5rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
        }

        .add-package-deals-page .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 1.25rem;
            margin-bottom: 1.5rem;
        }

        .add-package-deals-page .form-group {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .add-package-deals-page .form-label {
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--text);
        }

        .add-package-deals-page .form-control {
            width: 100%;
            padding: 0.6rem 0.8rem;
            font-size: 0.9rem;
            font-family: inherit;
            color: var(--text);
            background-color: #f8fafc;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            transition: all 0.2s ease;
        }

        .add-package-deals-page .form-control:focus {
            outline: none;
            border-color: var(--primary-lt);
            background-color: var(--surface);
            box-shadow: 0 0 0 3px rgba(37, 99, 168, 0.15);
        }

        .add-package-deals-page .btn-submit {
            display: inline-block;
            background-color: var(--primary);
            color: var(--surface);
            padding: 0.6rem 1.5rem;
            border: none;
            border-radius: var(--radius);
            font-weight: 600;
            font-size: 0.9rem;
            cursor: pointer;
            transition: background-color 0.2s ease;
        }

        .add-package-deals-page .btn-submit:hover {
            background-color: var(--primary-lt);
        }
    </style>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="add-package-deals-page">
        <div class="page-header">
            <h1>Add Package Deals</h1>
        </div>

        <div class="form-card">
            <div class="form-grid">
                <div class="form-group">
                    <asp:Label runat="server" AssociatedControlID="DdlMenu" CssClass="form-label">Select Event</asp:Label>
                    <asp:DropDownList ID="DdlMenu" runat="server" CssClass="form-control" AutoPostBack="true" OnTextChanged="DdlMenu_TextChanged"></asp:DropDownList>
                </div>

                <div class="form-group">
                    <asp:Label runat="server" AssociatedControlID="ddlDealName" CssClass="form-label">Deal Name</asp:Label>
                    <asp:DropDownList ID="ddlDealName" runat="server" CssClass="form-control" AutoPostBack="true" OnTextChanged="ddlDealName_TextChanged"></asp:DropDownList>
                </div>

                <div class="form-group">
                    <asp:Label runat="server" AssociatedControlID="ddlRestorentCataloage" CssClass="form-label">Restaurant Catalog Item</asp:Label>
                    <asp:DropDownList ID="ddlRestorentCataloage" runat="server" CssClass="form-control"></asp:DropDownList>
                </div>

                <div class="form-group">
                    <asp:Label runat="server" AssociatedControlID="ddlCategory" CssClass="form-label">Category</asp:Label>
                    <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control">
                        <asp:ListItem Text="--Select--" Value="0"></asp:ListItem>
                        <asp:ListItem Text="Deal" Value="Deal"></asp:ListItem>
                        <asp:ListItem Text="Other" Value="Other"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="form-group">
                    <asp:Label runat="server" AssociatedControlID="Amount" CssClass="form-label">Amount</asp:Label>
                    <asp:TextBox ID="Amount" runat="server" CssClass="form-control" placeholder="Enter amount"></asp:TextBox>
                </div>
            </div>

            <div>
                <asp:Button ID="btnSave" runat="server" Text="Add to Package" CssClass="btn-submit" OnClick="btnSave_Click" />
            </div>
        </div>
    </div>
</asp:Content>
