<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="GymkhanaNew.Login" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Login - Gymkhana Club</title>
    <style>
        :root {
            --primary       : #1a4a7a;
            --primary-lt    : #2563a8;
            --primary-dark  : #0f2d4e;
            --accent        : #e8f0fb;
            --text          : #1e293b;
            --text-muted    : #64748b;
            --border        : #d1d5db;
            --surface       : #ffffff;
            --danger        : #dc2626;
            --success       : #16a34a;
            --warning       : #d97706;
            --radius        : 8px;
            --radius-lg     : 12px;
            --shadow        : 0 2px 8px rgba(0,0,0,.10);
            --shadow-lg     : 0 4px 16px rgba(0,0,0,.15);
            --font          : 'Segoe UI', system-ui, sans-serif;
        }

        *, *::before, *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: var(--font);
            background: linear-gradient(135deg, var(--primary-dark), var(--primary));
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1.5rem;
        }

        .login-page {
            width: 100%;
            max-width: 400px;
        }

        .login-page .card {
            background-color: var(--surface);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-lg);
            overflow: hidden;
        }

        .login-page .card-header {
            background-color: var(--primary);
            color: var(--surface);
            padding: 2rem 1.5rem;
            text-align: center;
        }

        .login-page .card-header h1 {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        .login-page .card-header p {
            font-size: 0.875rem;
            color: var(--accent);
        }

        .login-page .card-body {
            padding: 2rem 1.5rem;
        }

        .login-page .form-group {
            margin-bottom: 1.25rem;
        }

        .login-page .form-label {
            display: block;
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 0.5rem;
        }

        .login-page .form-control {
            width: 100%;
            padding: 0.75rem 1rem;
            font-size: 0.95rem;
            font-family: inherit;
            color: var(--text);
            background-color: #f8fafc;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            transition: all 0.2s ease;
        }

        .login-page .form-control:focus {
            outline: none;
            border-color: var(--primary-lt);
            background-color: var(--surface);
            box-shadow: 0 0 0 3px rgba(37, 99, 168, 0.15);
        }

        .login-page .btn-submit {
            width: 100%;
            padding: 0.75rem;
            font-size: 1rem;
            font-weight: 600;
            color: var(--surface);
            background-color: var(--primary);
            border: none;
            border-radius: var(--radius);
            cursor: pointer;
            transition: background-color 0.2s ease;
            margin-top: 0.5rem;
        }

        .login-page .btn-submit:hover {
            background-color: var(--primary-lt);
        }

        .login-page .alert-danger {
            background-color: #fef2f2;
            color: var(--danger);
            border: 1px solid #fecaca;
            padding: 0.75rem 1rem;
            border-radius: var(--radius);
            font-size: 0.875rem;
            margin-bottom: 1.25rem;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-page">
            <div class="card">
                <div class="card-header">
                    <h1>Gymkhana Club</h1>
                    <p>Sign in to access management modules</p>
                </div>
                <div class="card-body">
                    <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert-danger">
                        <asp:Label ID="lblErrorMessage" runat="server" />
                    </asp:Panel>

                    <div class="form-group">
                        <asp:Label runat="server" AssociatedControlID="txtUsername" CssClass="form-label">Username</asp:Label>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="Enter username" />
                    </div>

                    <div class="form-group">
                        <asp:Label runat="server" AssociatedControlID="txtPassword" CssClass="form-label">Password</asp:Label>
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Enter password" />
                    </div>

                    <asp:Button ID="btnLogin" runat="server" Text="Sign In" CssClass="btn-submit" OnClick="btnLogin_Click" />
                </div>
            </div>
        </div>
    </form>
</body>
</html>
