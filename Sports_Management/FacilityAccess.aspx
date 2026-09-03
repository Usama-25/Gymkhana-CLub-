<%@ Page Title="Facility Access Control" Language="C#" MasterPageFile="~/Sports_Management/SiteSports.master" AutoEventWireup="true" CodeFile="FacilityAccess.aspx.cs" Inherits="FacilityAccess" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .access-container {
            max-width: 600px;
            margin: 0 auto;
        }

        .access-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 8px 15px rgba(0,0,0,0.1);
            overflow: hidden;
            margin-bottom: 25px;
            border: 1px solid var(--gray-200);
        }

        .access-header {
            background: var(--primary);
            color: white;
            padding: 20px;
            text-align: center;
        }
        
        .access-header h3 {
            margin: 0;
            font-size: 20px;
            font-weight: 700;
        }

        .access-body {
            padding: 30px;
        }

        .scan-input-group {
            position: relative;
            margin-bottom: 25px;
        }
        
        .scan-input-group i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--gray-400);
            font-size: 20px;
        }

        .scan-input {
            width: 100%;
            padding: 15px 15px 15px 45px;
            font-size: 18px;
            font-weight: 600;
            border: 2px solid var(--gray-300);
            border-radius: 8px;
            outline: none;
            transition: all 0.3s;
        }

        .scan-input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(30, 58, 95, 0.1);
        }

        /* Result Panel */
        .result-panel {
            border-radius: 8px;
            padding: 25px;
            text-align: center;
            display: none;
            margin-top: 20px;
        }

        .result-panel.granted {
            display: block;
            background-color: #ecfdf5;
            border: 2px solid #10b981;
        }
        
        .result-panel.denied {
            display: block;
            background-color: #fef2f2;
            border: 2px solid #ef4444;
        }

        .result-icon {
            font-size: 60px;
            margin-bottom: 15px;
        }
        
        .granted .result-icon { color: #10b981; }
        .denied .result-icon { color: #ef4444; }

        .result-title {
            font-size: 24px;
            font-weight: 800;
            margin-bottom: 10px;
            text-transform: uppercase;
        }

        .granted .result-title { color: #047857; }
        .denied .result-title { color: #b91c1c; }

        .result-reason {
            font-size: 16px;
            font-weight: 600;
            color: var(--gray-700);
            margin-bottom: 20px;
        }

        .member-details-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            background: white;
            padding: 15px;
            border-radius: 8px;
            text-align: left;
            border: 1px solid var(--gray-200);
            margin-top: 20px;
        }

        .md-item {
            display: flex;
            flex-direction: column;
        }
        
        .md-label {
            font-size: 11px;
            color: var(--gray-500);
            text-transform: uppercase;
            font-weight: 700;
        }
        
        .md-value {
            font-size: 14px;
            font-weight: 600;
            color: var(--gray-800);
        }
        
        .blink {
            animation: blinker 1s linear infinite;
        }
        
        @keyframes blinker {
            50% { opacity: 0; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="page-header-card">
        <h2><i class="fas fa-shield-alt" style="margin-right:10px;"></i> Facility Access Control</h2>
        <span class="badge">Gate Entry Simulation</span>
    </div>

    <div class="access-container">
        <div class="access-card">
            <div class="access-header">
                <img src="images/lg-logo.png" alt="Lahore Gymkhana" style="width: 55px; margin-bottom: 8px;" />
                <h3>Select Facility & Scan Member Card</h3>
            </div>
            
            <div class="access-body">
                <div class="form-group">
                    <label style="font-size: 14px; color: var(--gray-600); margin-bottom: 10px;">Gate Location / Facility</label>
                    <asp:DropDownList ID="ddlSports" runat="server" CssClass="form-control" style="font-size: 16px; padding: 12px;"></asp:DropDownList>
                </div>

                <div class="scan-input-group" style="margin-top: 20px;">
                    <i class="fas fa-id-card"></i>
                    <asp:TextBox ID="txtMemberNo" runat="server" CssClass="scan-input" placeholder="Scan or Enter Member No..." AutoPostBack="true" OnTextChanged="txtMemberNo_TextChanged"></asp:TextBox>
                </div>

                <div class="scan-input-group">
                    <i class="fas fa-wifi"></i>
                    <asp:TextBox ID="txtRFID" runat="server" CssClass="scan-input" placeholder="Scan RFID Card..." AutoPostBack="true" OnTextChanged="txtRFID_TextChanged"></asp:TextBox>
                </div>
                
                <p style="text-align: center; color: var(--gray-400); font-size: 12px; margin-top: -10px;">
                    <i class="fas fa-info-circle"></i> Scan RFID card or type Member No and press Enter.
                </p>

                <!-- Result Panel -->
                <asp:Panel ID="pnlResult" runat="server" CssClass="result-panel">
                    <div class="result-icon">
                        <i id="iconResult" runat="server" class="fas fa-check-circle"></i>
                    </div>
                    <div class="result-title">
                        <asp:Label ID="lblResultTitle" runat="server"></asp:Label>
                    </div>
                    <div class="result-reason">
                        <asp:Label ID="lblReason" runat="server"></asp:Label>
                    </div>

                    <div class="member-details-grid">
                        <div class="md-item">
                            <span class="md-label">Member Name</span>
                            <span class="md-value"><asp:Label ID="lblMemName" runat="server"></asp:Label></span>
                        </div>
                        <div class="md-item">
                            <span class="md-label">Member No</span>
                            <span class="md-value"><asp:Label ID="lblMemNo" runat="server"></asp:Label></span>
                        </div>
                        <div class="md-item">
                            <span class="md-label">Status</span>
                            <span class="md-value"><asp:Label ID="lblMemStatus" runat="server"></asp:Label></span>
                        </div>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </div>

    <!-- Script to set focus back to input after scan for continuous scanning -->
    <script type="text/javascript">
        function setFocusToInput() {
            var input = document.getElementById('<%= txtMemberNo.ClientID %>');
            if (input) {
                input.focus();
                input.select();
            }
        }
        
        // Call it after full postback
        window.onload = setFocusToInput;
    </script>
</asp:Content>
