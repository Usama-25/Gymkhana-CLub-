<%@ Control Language="C#" AutoEventWireup="true" CodeFile="LoginControl.ascx.cs" Inherits="Controls_LoginControl" %>

<style>
    .login-container {
        background-color: white;
        width: 100%;
        height: 100%;
        display: flex;
        overflow: hidden;
    }
    .login-left {
        width: 40%;
        background-color: white;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        padding: 40px;
    }
    .login-left img {
        width: 100%;
        max-width: 450px;
        height: auto;
        object-fit: contain;
        opacity: 0.85;
        filter: drop-shadow(0 15px 25px rgba(0,0,0,0.1));
        transition: transform 0.3s ease, opacity 0.3s ease;
    }
    .login-left img:hover {
        transform: scale(1.03);
        opacity: 1;
    }
    .login-right {
        width: 60%;
        padding: 60px 10%;
        display: flex;
        flex-direction: column;
        justify-content: center;
        box-sizing: border-box;
    }
    .form-group {
        margin-bottom: 25px;
    }
    .form-label {
        display: block;
        margin-bottom: 8px;
        color: #4a5568;
        font-weight: 600;
        font-size: 14px;
        letter-spacing: 0.3px;
    }
    .form-control {
        width: 100%;
        padding: 14px 16px;
        border: 2px solid #e2e8f0;
        border-radius: 8px;
        font-size: 15px;
        transition: all 0.3s ease;
        box-sizing: border-box;
        color: #2d3748;
    }
    .form-control:focus {
        border-color: #667eea;
        outline: none;
        box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.15);
    }
    .form-control::placeholder {
        color: #a0aec0;
    }
    .btn-primary {
        width: 100%;
        padding: 14px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border: none;
        border-radius: 8px;
        font-size: 16px;
        font-weight: bold;
        cursor: pointer;
        transition: transform 0.2s, box-shadow 0.2s;
        letter-spacing: 0.5px;
    }
    .btn-primary:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(118, 75, 162, 0.3);
    }
    @media (max-width: 768px) {
        .login-container {
            flex-direction: column;
        }
        .login-left, .login-right {
            width: 100%;
        }
        .login-left {
            padding: 40px;
            border-right: none;
            border-bottom: 1px solid #e2e8f0;
        }
        .login-right {
            padding: 40px 25px;
        }
    }
</style>

<div class="login-container">
    <!-- Left Side: 40% -->
    <div class="login-left">
        <img src="<%= ResolveUrl("~/MemberShipModule/assets/images/logo_new.png") %>" alt="Logo" />
        <h2 style="margin-top: 35px; color: #2d3748; font-size: 26px; font-weight: 800; text-align: center; letter-spacing: 0.5px;">Membership System</h2>
        <p style="color: #718096; font-size: 15px; text-align: center; margin-top: 12px; line-height: 1.6; max-width: 90%;">Access the Club Management Module to securely manage your portal.</p>
    </div>

    <!-- Right Side: 60% -->
    <div class="login-right">
        <!-- Login Header -->
        <div style="text-align: left; margin-bottom: 40px;">
            <h1 style="margin: 0; color: #1a202c; font-size: 34px; font-weight: 800; letter-spacing: -0.5px;">Sign In</h1>
            <p style="margin: 10px 0 0 0; color: #718096; font-size: 16px;">Enter your credentials to continue</p>
        </div>

        <!-- Login Form -->
        <div class="form-group">
            <label class="form-label">Username / Employee No</label>
            <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="Enter Username or Employee No"></asp:TextBox>
            <asp:RequiredFieldValidator ID="rfvUsername" runat="server" ControlToValidate="txtUsername" 
                ErrorMessage="Username is required" Display="Dynamic" 
                style="color: #e53e3e; font-size: 13px; margin-top: 6px; display: block; font-weight: 500;"></asp:RequiredFieldValidator>
        </div>

        <div class="form-group">
            <label class="form-label">Password</label>
            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Enter your password"></asp:TextBox>
            <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" 
                ErrorMessage="Password is required" Display="Dynamic" 
                style="color: #e53e3e; font-size: 13px; margin-top: 6px; display: block; font-weight: 500;"></asp:RequiredFieldValidator>
        </div>

        <div class="form-group" style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 30px;">
            <div style="display: flex; align-items: center;">
                <asp:CheckBox ID="chkRememberMe" runat="server" style="margin-right: 8px; transform: scale(1.1);" />
                <label for="<%= chkRememberMe.ClientID %>" style="color: #4a5568; font-size: 14px; cursor: pointer; user-select: none;">Remember me</label>
            </div>
            <a href="#" style="color: #667eea; font-size: 14px; text-decoration: none; font-weight: 600; transition: color 0.2s;">Forgot Password?</a>
        </div>

        <asp:Button ID="btnLogin" runat="server" Text="Login" OnClick="btnLogin_Click" CssClass="btn-primary" />

        <asp:Label ID="lblMessage" runat="server" style="display: block; margin-top: 20px; padding: 12px; border-radius: 6px; text-align: center; font-size: 14px; font-weight: 500;"></asp:Label>

        <div style="text-align: center; margin-top: 40px; padding-top: 25px; border-top: 1px solid #e2e8f0;">
            <p style="color: #a0aec0; font-size: 13px; margin: 0;">Need help? <a href="#" style="color: #667eea; text-decoration: none; font-weight: 600;">Contact system administrator</a></p>
        </div>
    </div>
</div>
