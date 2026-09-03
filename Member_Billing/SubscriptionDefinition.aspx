<%@ Page Title="Subscription Definition" Language="C#" AutoEventWireup="true" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Redirect("DefineSubscription.aspx" + Request.Url.Query);
    }
</script>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Redirecting...</title>
    <meta http-equiv="refresh" content="0;url=DefineSubscription.aspx" />
</head>
<body>
    <p>Redirecting to <a href="DefineSubscription.aspx">DefineSubscription.aspx</a>...</p>
</body>
</html>
