<%@ Page Language="C#" %>
<%@ Import Namespace="System.Configuration" %>
<!DOCTYPE html>
<html>
<head><title>Test Connection String</title></head>
<body>
    <h1>Connection String: <%= ConfigurationManager.ConnectionStrings["GymkhanaLibraryDB"] != null ? ConfigurationManager.ConnectionStrings["GymkhanaLibraryDB"].ConnectionString : "null" %></h1>
    <h1>Basic Connection String: <%= ConfigurationManager.ConnectionStrings["Basic_Data_ConnectionString"] != null ? ConfigurationManager.ConnectionStrings["Basic_Data_ConnectionString"].ConnectionString : "null" %></h1>
</body>
</html>
