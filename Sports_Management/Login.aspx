<%@ Page Language="C#" AutoEventWireup="true" CodeFile="~/Sports_Management/Login.aspx.cs" Inherits="Login" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Lahore Gymkhana - Login</title>
    
    <!-- Font Awesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #0f172a 0%, #1e3a5f 100%);
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #334155;
            overflow: hidden;
        }

        .login-container {
            width: 100%;
            max-width: 420px;
            padding: 20px;
        }

        .login-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 16px;
            padding: 40px 30px;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.3), 0 8px 10px -6px rgba(0, 0, 0, 0.3);
            border: 1px solid #c5a572; /* Gold border */
            position: relative;
            overflow: hidden;
        }

        .login-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 5px;
            background: linear-gradient(90deg, #c5a572, #ebd5b3);
        }

        .brand-section {
            text-align: center;
            margin-bottom: 30px;
        }

        .brand-logo {
            width: 80px;
            height: 80px;
            margin: 0 auto 15px;
            background: #1e3a5f;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px solid #c5a572;
            box-shadow: 0 4px 10px rgba(0,0,0,0.15);
        }

        .brand-logo img {
            width: 70%;
            height: 70%;
            object-fit: contain;
        }

        .brand-section h2 {
            color: #1e3a5f;
            font-size: 22px;
            font-weight: 700;
            margin-bottom: 5px;
        }

        .brand-section p {
            color: #c5a572;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 1.5px;
            text-transform: uppercase;
        }

        .form-group {
            margin-bottom: 20px;
            position: relative;
        }

        .form-label {
            display: block;
            font-size: 12px;
            font-weight: 600;
            color: #475569;
            margin-bottom: 6px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .input-wrapper {
            position: relative;
        }

        .input-icon {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
            font-size: 16px;
            transition: color 0.2s;
        }

        .form-control {
            width: 100%;
            padding: 12px 16px 12px 42px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 14px;
            color: #1e293b;
            outline: none;
            transition: all 0.2s ease-in-out;
            background-color: #f8fafc;
        }

        .form-control:focus {
            border-color: #1e3a5f;
            background-color: #fff;
            box-shadow: 0 0 0 3px rgba(30, 58, 95, 0.15);
        }

        .form-control:focus + .input-icon {
            color: #1e3a5f;
        }

        .btn-login {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #1e3a5f 0%, #0f2b48 100%);
            color: #ffffff;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease-in-out;
            box-shadow: 0 4px 6px -1px rgba(30, 58, 95, 0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            margin-top: 10px;
        }

        .btn-login:hover {
            transform: translateY(-1px);
            box-shadow: 0 10px 15px -3px rgba(30, 58, 95, 0.3);
            background: linear-gradient(135deg, #0f2b48 0%, #1e3a5f 100%);
        }

        .btn-login:active {
            transform: translateY(1px);
        }

        .alert-error {
            background-color: #fef2f2;
            border: 1px solid #fca5a5;
            color: #991b1b;
            padding: 12px 15px;
            border-radius: 8px;
            font-size: 13px;
            margin-bottom: 20px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .footer-text {
            text-align: center;
            margin-top: 25px;
            font-size: 11px;
            color: #64748b;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-card">
            <div class="brand-section">
                <div class="brand-logo">
                    <img src="images/lg-logo.png" alt="Lahore Gymkhana" onerror="this.style.display='none'; this.parentNode.innerHTML='<i class=\'fas fa-club\' style=\'color:var(--secondary);font-size:32px;\'></i>';" />
                </div>
                <h2>Lahore Gymkhana</h2>
                <p>Sports Portal Login</p>
            </div>

            <form id="loginForm" runat="server">
                <!-- Error Message -->
                <asp:Panel ID="pnlError" runat="server" CssClass="alert-error" Visible="false">
                    <i class="fas fa-exclamation-circle"></i>
                    <asp:Label ID="lblErrorMsg" runat="server"></asp:Label>
                </asp:Panel>

                <!-- Username -->
                <div class="form-group">
                    <label class="form-label" for="txtUsername">Username</label>
                    <div class="input-wrapper">
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="Enter username" autocomplete="off"></asp:TextBox>
                        <i class="fas fa-user input-icon"></i>
                    </div>
                </div>

                <!-- Password -->
                <div class="form-group">
                    <label class="form-label" for="txtPassword">Password</label>
                    <div class="input-wrapper">
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Enter password"></asp:TextBox>
                        <i class="fas fa-lock input-icon"></i>
                    </div>
                </div>

                <!-- Submit Button -->
                <asp:Button ID="btnLogin" runat="server" Text="Sign In" CssClass="btn-login" OnClick="btnLogin_Click" />
            </form>

            <div class="footer-text">
                &copy; <%= DateTime.Now.Year %> Lahore Gymkhana Club. All Rights Reserved.
            </div>
        </div>
    </div>
</body>
</html>
