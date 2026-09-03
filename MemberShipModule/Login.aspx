<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="Login" %>
    <%@ Register Src="~/MemberShipModule/Controls/LoginControl.ascx" TagPrefix="uc" TagName="LoginControl" %>

        <!DOCTYPE html>
        <html>

        <head runat="server">
            <title>Login - Membership Management System</title>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        </head>

        <body>
            <form id="form1" runat="server">
                <asp:ScriptManager ID="ScriptManager1" runat="server" />
                <uc:LoginControl runat="server" ID="LoginCtrl" />
            </form>
        </body>

        </html>







