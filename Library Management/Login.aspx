<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="Library_Login" %>
<%@ Register Src="~/MemberShipModule/Controls/LoginControl.ascx" TagPrefix="uc" TagName="LoginControl" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Login - Lahore Gymkhana Library</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
        <uc:LoginControl runat="server" ID="LoginCtrl" />
    </form>
</body>
</html>
