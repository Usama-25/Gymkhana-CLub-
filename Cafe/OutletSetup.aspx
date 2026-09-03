<%@ Page Title="Outlet Setup" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master"
    AutoEventWireup="true" CodeFile="OutletSetup.aspx.cs" Inherits="OutletSetup" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
   <style>
        .outlet-container {
            width: 100%;
            margin: 20px auto;
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .outlet-header {
            background: #ff5e62;
            color: white;
            padding: 15px;
            border-radius: 8px 8px 0 0;
            font-size: 20px;
            font-weight: bold;
            margin-bottom: 20px;
        }
        
        .info-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 25px;
        }
        
        .info-table td {
            padding: 12px 15px;
            border: 1px solid #ddd;
            vertical-align: top;
        }
        
        .info-table td:first-child {
            width: 150px;
            background: #f8f9fa;
            font-weight: 600;
            color: #555;
        }
        
        .info-table td:last-child {
            background: white;
        }
        
        .info-table input[type="text"], 
        .info-table input[type="number"] {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 14px;
        }
        
        .info-table textarea {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 14px;
            resize: vertical;
        }
        
        .section-title {
            background: #f0f0f0;
            padding: 12px 15px;
            font-weight: bold;
            color: #ff5e62;
            border-left: 4px solid #ff5e62;
            margin: 20px 0 15px 0;
        }
        
        .account-row {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            margin-bottom: 20px;
            padding: 15px;
            background: #f9f9f9;
            border-radius: 8px;
        }
        
        .account-item {
            flex: 1;
            min-width: 200px;
        }
        
        .account-item label {
            display: block;
            font-weight: 600;
            color: #555;
            margin-bottom: 5px;
            font-size: 13px;
        }
        
        .account-item input {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #ccc;
            border-radius: 6px;
        }
        
        .action-buttons {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 2px solid #eee;
            flex-wrap: wrap;
        }
        
        .action-btn {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            font-weight: 600;
            cursor: pointer;
            transition: 0.3s;
            min-width: 80px;
        }
        
        .action-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 3px 10px rgba(0,0,0,0.1);
        }
        
        .btn-refresh { background: #6c757d; color: white; }
        .btn-new { background: #007bff; color: white; }
        .btn-find { background: #17a2b8; color: white; }
        .btn-save { background: #28a745; color: white; }
        .btn-update { background: #ffc107; color: black; }
        .btn-delete { background: #dc3545; color: white; }
        .btn-close { background: #6c757d; color: white; }
        
        .status-message {
            padding: 12px;
            border-radius: 6px;
            margin: 15px 0;
            font-weight: 500;
        }
        
        .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .info { background: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb; }
        
        .outlet-id-box {
            background: #ff5e62;
            color: white;
            padding: 15px 20px;
            border-radius: 8px;
            display: inline-block;
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 20px;
        }
        
        .tax-row {
            display: flex;
            gap: 15px;
            align-items: center;
        }
        
        .tax-row input[type="text"] {
            flex: 2;
        }
        
        .tax-row input[type="number"] {
            flex: 1;
        }
        
        .search-panel {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            display: none;
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 1000;
            min-width: 500px;
            max-width: 800px;
            max-height: 80vh;
            overflow-y: auto;
        }
        
        .search-panel.active {
            display: block;
        }
        
        .search-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #eee;
        }
        
        .search-header h3 {
            margin: 0;
            color: #ff5e62;
        }
        
        .search-close {
            background: none;
            border: none;
            font-size: 20px;
            cursor: pointer;
            color: #666;
        }
        
        .search-close:hover {
            color: #ff5e62;
        }
        
        .search-grid {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        
        .search-grid th {
            background: #ff5e62;
            color: white;
            padding: 10px;
            text-align: left;
        }
        
        .search-grid td {
            padding: 8px 10px;
            border-bottom: 1px solid #eee;
            cursor: pointer;
        }
        
        .search-grid tr:hover td {
            background: #f5f5f5;
        }
        
        .search-input {
            width: 100%;
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            margin-bottom: 10px;
        }
        
        .overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0,0,0,0.5);
            z-index: 999;
        }
        
        .overlay.active {
            display: block;
        }
        
        .required:after {
            content: " *";
            color: #ff5e62;
            font-weight: bold;
        }
        
        .validation-error {
            color: #dc3545;
            font-size: 12px;
            margin-top: 5px;
        }
        
        @media (max-width: 768px) {
            .action-buttons {
                justify-content: center;
            }
            
            .search-panel {
                min-width: 90%;
                max-width: 95%;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
   <div class="outlet-container">
        
        <div class="outlet-header">
            🏢 Restaurant Outlet Setup
        </div>
        
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        
        <!-- Status Message -->
        <asp:Label ID="lblStatus" runat="server" CssClass="status-message" Visible="false"></asp:Label>
        
        <!-- Outlet ID Display -->
        <div class="outlet-id-box">
            Outlet ID: <asp:Label ID="lblOutletID" runat="server" Text="New"></asp:Label>
        </div>
        
        <!-- Main Information Table -->
        <table class="info-table">
            <tr>
                <td><span class="required">Message 1</span>:</td>
                <td>
                    <asp:TextBox ID="txtMessage1" runat="server" Text="WE HOPE YOU HAVE ENJOYED YOUR VISIT. WE WELCOME YOUR COMMENTS AND SUGGESTIONS." TextMode="MultiLine" Rows="2"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td>Message 2:</td>
                <td><asp:TextBox ID="txtMessage2" runat="server" TextMode="MultiLine" Rows="2"></asp:TextBox></td>
            </tr>
            <tr>
                <td>Message 3:</td>
                <td><asp:TextBox ID="txtMessage3" runat="server" TextMode="MultiLine" Rows="2"></asp:TextBox></td>
            </tr>
            <tr>
                <td><span class="required">Address 1</span>:</td>
                <td><asp:TextBox ID="txtAddress1" runat="server" Text="LAHORE GYMKHANA"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvAddress1" runat="server" ControlToValidate="txtAddress1"
                        ErrorMessage="Address 1 is required" CssClass="validation-error" Display="Dynamic"></asp:RequiredFieldValidator>
                </td>
            </tr>
            <tr>
                <td>Address 2:</td>
                <td><asp:TextBox ID="txtAddress2" runat="server" Text="UPPER SHAHRAH-E-QUAID-E-AZAM, LAHORE"></asp:TextBox></td>
            </tr>
            <tr>
                <td>Address 3:</td>
                <td><asp:TextBox ID="txtAddress3" runat="server" Text="PH: 111-111-231"></asp:TextBox></td>
            </tr>
            <tr>
                <td>Naration:</td>
                <td><asp:TextBox ID="txtNaration" runat="server" Text="OUTLET SALE"></asp:TextBox></td>
            </tr>
            <tr>
                <td>Cost/Budget ID:</td>
                <td><asp:TextBox ID="txtCostBudgetID" runat="server" Text="1323" type="number"></asp:TextBox>
                    <asp:RegularExpressionValidator ID="revCostBudgetID" runat="server" 
                        ControlToValidate="txtCostBudgetID" ValidationExpression="^\d*$" 
                        ErrorMessage="Must be numeric" CssClass="validation-error" Display="Dynamic"></asp:RegularExpressionValidator>
                </td>
            </tr>
            <tr>
                <td>Charge Code:</td>
                <td><asp:TextBox ID="txtChargeCode" runat="server" Text="1323" type="number"></asp:TextBox>
                    <asp:RegularExpressionValidator ID="revChargeCode" runat="server" 
                        ControlToValidate="txtChargeCode" ValidationExpression="^\d*$" 
                        ErrorMessage="Must be numeric" CssClass="validation-error" Display="Dynamic"></asp:RegularExpressionValidator>
                </td>
            </tr>
            <tr>
                <td>Cash ID:</td>
                <td><asp:TextBox ID="txtCashID" runat="server" Text="320113" type="number"></asp:TextBox>
                    <asp:RegularExpressionValidator ID="revCashID" runat="server" 
                        ControlToValidate="txtCashID" ValidationExpression="^\d*$" 
                        ErrorMessage="Must be numeric" CssClass="validation-error" Display="Dynamic"></asp:RegularExpressionValidator>
                </td>
            </tr>
            <tr>
                <td>Credit Card ID:</td>
                <td><asp:TextBox ID="txtCreditCardID" runat="server" Text="300901" type="number"></asp:TextBox>
                    <asp:RegularExpressionValidator ID="revCreditCardID" runat="server" 
                        ControlToValidate="txtCreditCardID" ValidationExpression="^\d*$" 
                        ErrorMessage="Must be numeric" CssClass="validation-error" Display="Dynamic"></asp:RegularExpressionValidator>
                </td>
            </tr>
            <tr>
                <td>Income:</td>
                <td><asp:TextBox ID="txtIncome" runat="server" Text="400105" type="number"></asp:TextBox>
                    <asp:RegularExpressionValidator ID="revIncome" runat="server" 
                        ControlToValidate="txtIncome" ValidationExpression="^\d*$" 
                        ErrorMessage="Must be numeric" CssClass="validation-error" Display="Dynamic"></asp:RegularExpressionValidator>
                </td>
            </tr>
            <tr>
                <td>Discount:</td>
                <td><asp:TextBox ID="txtDiscount" runat="server" Text="400105" type="number"></asp:TextBox>
                    <asp:RegularExpressionValidator ID="revDiscount" runat="server" 
                        ControlToValidate="txtDiscount" ValidationExpression="^\d*$" 
                        ErrorMessage="Must be numeric" CssClass="validation-error" Display="Dynamic"></asp:RegularExpressionValidator>
                </td>
            </tr>
            <tr>
                <td>Tax A/C 1:</td>
                <td>
                    <div class="tax-row">
                        <asp:TextBox ID="txtTaxAC1" runat="server" placeholder="Account Code"></asp:TextBox>
                        <asp:TextBox ID="txtTaxPercentage1" runat="server" placeholder="0.00" type="number" step="0.01"></asp:TextBox>
                        <span>%</span>
                    </div>
                </td>
            </tr>
            <tr>
                <td>Tax A/C 2:</td>
                <td>
                    <div class="tax-row">
                        <asp:TextBox ID="txtTaxAC2" runat="server" placeholder="Account Code"></asp:TextBox>
                        <asp:TextBox ID="txtTaxPercentage2" runat="server" placeholder="0.00" type="number" step="0.01"></asp:TextBox>
                        <span>%</span>
                    </div>
                </td>
            </tr>
            <tr>
                <td>Service Chr A/C:</td>
                <td>
                    <div class="tax-row">
                        <asp:TextBox ID="txtServiceChrAC" runat="server" Text="081914" placeholder="Account Code"></asp:TextBox>
                        <asp:TextBox ID="txtServiceChrPercentage" runat="server" placeholder="0.00" type="number" step="0.01"></asp:TextBox>
                        <span>%</span>
                    </div>
                </td>
            </tr>
        </table>
        
        <!-- Accounts Section -->
        <div class="section-title">
            📊 Accounts Configuration
        </div>
        
        <div class="account-row">
            <div class="account-item">
                <label>Member Account:</label>
                <asp:TextBox ID="txtMemberAccount" runat="server"></asp:TextBox>
            </div>
            <div class="account-item">
                <label>Sales Account:</label>
                <asp:TextBox ID="txtSalesAccount" runat="server"></asp:TextBox>
            </div>
            <div class="account-item">
                <label>Tax Payable Account:</label>
                <asp:TextBox ID="txtTaxPayableAccount" runat="server"></asp:TextBox>
            </div>
        </div>
        
        <div class="account-row">
            <div class="account-item">
                <label>Tr./Bank Charges:</label>
                <asp:TextBox ID="txtTrBankCharges" runat="server"></asp:TextBox>
            </div>
            <div class="account-item">
                <label>Lodder Account:</label>
                <asp:TextBox ID="txtLodderAccount" runat="server"></asp:TextBox>
            </div>
            <div class="account-item">
                <label>Other Account:</label>
                <asp:TextBox ID="txtOtherAccount" runat="server"></asp:TextBox>
            </div>
        </div>
        
        <!-- Action Buttons -->
        <div class="action-buttons">
            <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="action-btn btn-refresh" OnClick="btnRefresh_Click" />
            <asp:Button ID="btnNew" runat="server" Text="New" CssClass="action-btn btn-new" OnClick="btnNew_Click" />
            <asp:Button ID="btnFind" runat="server" Text="Find" CssClass="action-btn btn-find" OnClick="btnFind_Click" OnClientClick="showSearchPanel(); return false;" />
            <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="action-btn btn-save" OnClick="btnSave_Click" />
            <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="action-btn btn-update" OnClick="btnUpdate_Click" />
            <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="action-btn btn-delete" OnClick="btnDelete_Click" OnClientClick="return confirmDelete();" />
            <asp:Button ID="btnClose" runat="server" Text="Close" CssClass="action-btn btn-close" OnClientClick="window.close(); return false;" />
        </div>
        
        <!-- Hidden Buttons -->
        <asp:Button ID="btnConfirmDelete" runat="server" OnClick="btnConfirmDelete_Click" Style="display:none;" />
        
        <!-- Hidden Fields -->
        <asp:HiddenField ID="hdnOutletID" runat="server" Value="0" />
        
    </div>
    
    <!-- Search Panel -->
    <div class="overlay" id="overlay" onclick="hideSearchPanel()"></div>
    <div class="search-panel" id="searchPanel">
        <div class="search-header">
            <h3>🔍 Find Outlet</h3>
            <button class="search-close" onclick="hideSearchPanel()">✖</button>
        </div>
        
        <asp:UpdatePanel ID="upSearch" runat="server">
            <ContentTemplate>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" placeholder="Type to search..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                
                <asp:GridView ID="gvOutlets" runat="server" CssClass="search-grid" AutoGenerateColumns="false" 
                    OnRowCommand="gvOutlets_RowCommand" AllowPaging="true" PageSize="5" OnPageIndexChanging="gvOutlets_PageIndexChanging">
                    <Columns>
                        <asp:BoundField DataField="OutletID" HeaderText="ID" />
                        <asp:BoundField DataField="Address1" HeaderText="Address" />
                        <asp:BoundField DataField="Message1" HeaderText="Message" />
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:LinkButton ID="btnSelect" runat="server" CommandName="SelectOutlet" 
                                    CommandArgument='<%# Eval("OutletID") %>' Text="Select" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
    
    <script type="text/javascript">
        function showMessage(msg, type) {
            alert(msg);
        }
        
        function showSearchPanel() {
            document.getElementById('searchPanel').classList.add('active');
            document.getElementById('overlay').classList.add('active');
            document.getElementById('<%= txtSearch.ClientID %>').focus();
            return false;
        }
        
        function hideSearchPanel() {
            document.getElementById('searchPanel').classList.remove('active');
            document.getElementById('overlay').classList.remove('active');
            return false;
        }
        
        function confirmDelete() {
            var outletId = document.getElementById('<%= lblOutletID.ClientID %>').innerText;
            if (outletId === 'New') {
                alert('No record selected to delete');
                return false;
            }
            
            if (confirm('Are you sure you want to delete Outlet ID: ' + outletId + '?')) {
                document.getElementById('<%= btnConfirmDelete.ClientID %>').click();
            }
            return false;
        }
        
        // Close search panel on escape key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                hideSearchPanel();
            }
        });
    </script>
</asp:Content>
