<%@ Page Title="" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true"
    CodeFile="SearchInterviewResult.aspx.cs" Inherits="RefundFee.SearchInterviewResult" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
        <style>
            body { font-family: 'Inter', sans-serif; background-color: #faf7f2; }
            .grid-3 { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
            @media (max-width: 1024px) { .grid-3 { grid-template-columns: repeat(2, 1fr); } }
            @media (max-width: 640px) { .grid-3 { grid-template-columns: 1fr; } }
            .gv-row:hover { background-color: #F7F3EE !important; }
            .btn-hover:hover { transform: translateY(-1px); opacity: 0.9; transition: all 0.2s; }
            
            .gv-header { background-color: #faf7f2; color: #7a7a7a; font-size: 12px; font-weight: 600; text-transform: uppercase; padding: 14px 16px; border-bottom: 2px solid #e0d5c5; text-align: left; }
            .gv-row { padding: 14px 16px; border-bottom: 1px solid #F7F3EE; font-size: 14px; color: #1A1A2E; }
            .gv-child-header { background: #faf7f2; color: #7a7a7a; font-size: 12px; font-weight: 600; text-transform: uppercase; padding: 12px 16px; text-align: left; border-bottom: 1px solid #e0d5c5; }
            .gv-child-row { padding: 12px 16px; border-bottom: 1px solid #F7F3EE; font-size: 13px; color: #1A1A2E; }

            /* Fee Distribution Modal Styles */
            .fee-modal-overlay {
                display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
                background: rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px);
                z-index: 99998; justify-content: center; align-items: center;
            }
            .fee-modal-overlay.active { display: flex; }
            .fee-modal-box {
                background: white; border-radius: 16px; width: 680px; max-width: 95vw;
                max-height: 85vh; overflow-y: auto; padding: 0;
                box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
                animation: fadeInModal 0.25s ease-out;
            }
            .fee-modal-header {
                padding: 24px 28px 18px; border-bottom: 1px solid #e0d5c5;
                background: linear-gradient(135deg, #fdfbf7, #f5f0e8);
                border-radius: 16px 16px 0 0;
            }
            .fee-modal-body { padding: 24px 28px; }
            .fee-modal-footer {
                padding: 18px 28px; border-top: 1px solid #e0d5c5;
                display: flex; justify-content: flex-end; gap: 12px;
                background: #faf7f2; border-radius: 0 0 16px 16px;
            }
            .fee-row {
                display: flex; align-items: center; gap: 12px; padding: 10px 14px;
                background: #faf7f2; border-radius: 10px; margin-bottom: 10px;
                border: 1px solid #e0d5c5; transition: all 0.2s;
            }
            .fee-row:hover { border-color: #C9A84C; }
            .fee-row-label { flex: 1; font-size: 13px; font-weight: 600; color: #1e293b; }
            .fee-row-code { font-size: 11px; color: #8B5E3C; background: #F7F3EE; padding: 2px 8px; border-radius: 4px; font-weight: 600; }
            .fee-row-input {
                width: 160px; padding: 8px 12px; border: 1.5px solid #cbd5e1;
                border-radius: 8px; font-size: 14px; font-weight: 600; text-align: right;
                outline: none; transition: border-color 0.2s;
            }
            .fee-row-input:focus { border-color: #C9A84C; box-shadow: 0 0 0 3px rgba(201,168,76,0.15); }
            .fee-row-input.error { border-color: #ef4444; background: #fef2f2; }
            .fee-row-remove {
                width: 30px; height: 30px; border-radius: 50%; border: none;
                background: #fef2f2; color: #ef4444; font-size: 16px; font-weight: 700;
                cursor: pointer; display: flex; align-items: center; justify-content: center;
                transition: all 0.2s;
            }
            .fee-row-remove:hover { background: #ef4444; color: white; }
            .fee-status-bar {
                padding: 12px 16px; border-radius: 10px; margin-top: 16px;
                display: flex; justify-content: space-between; align-items: center;
                font-size: 13px; font-weight: 600;
            }
            .fee-status-bar.balanced { background: #ecfdf5; border: 1px solid #a7f3d0; color: #059669; }
            .fee-status-bar.unbalanced { background: #fef2f2; border: 1px solid #fecaca; color: #dc2626; }
            .fee-status-bar.empty { background: #f8fafc; border: 1px solid #e2e8f0; color: #94a3b8; }
            .select2-container--default .select2-selection--single {
                height: 42px !important; border: 1.5px solid #cbd5e1 !important;
                border-radius: 8px !important; display: flex !important; align-items: center !important;
            }
            .select2-container--default .select2-selection--single .select2-selection__rendered {
                color: #1e293b !important; font-weight: 500 !important; font-size: 14px !important;
                padding-left: 12px !important;
            }
            .select2-container--default .select2-selection--single .select2-selection__arrow { height: 40px !important; }
            .select2-dropdown {
                border: 1.5px solid #cbd5e1 !important; border-radius: 8px !important;
                box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1) !important; z-index: 100000 !important;
            }
            @keyframes fadeInModal { from { opacity: 0; transform: scale(0.96); } to { opacity: 1; transform: scale(1); } }
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">
        <div style="padding: 40px 20px; width: 100%; max-width: 100%; margin: 0 auto;">
            
            <!-- Header Section -->
            <div style="background: white; border-radius: 16px; padding: 32px; border: 1px solid #e0d5c5; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); margin-bottom: 24px;">
                <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #F7F3EE; padding-bottom: 20px; margin-bottom: 24px; flex-wrap: wrap; gap: 12px;">
                    <div>
                        <h1 style="font-size: 28px; font-weight: 700; color: black; margin: 0;">Interview Results</h1>
                        <p style="font-size: 14px; color: black; margin: 4px 0 0 0;">Manage and convert applicant interview statuses</p>
                    </div>
                    <div>
                        <a href="MemberFeeDisbursementReport.aspx" class="btn-hover"
                            style="display: inline-flex; align-items: center; background: white; color: #8B5E3C; border: 1.5px solid #e0d5c5; padding: 10px 18px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 14px; box-shadow: 0 2px 6px rgba(0,0,0,0.04);">
                            Fee Disbursement Report
                        </a>
                    </div>
                </div>

                <asp:Label ID="lblMessage" runat="server" Visible="false" 
                    style="display: block; padding: 12px 16px; border-radius: 8px; background-color: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; margin-bottom: 24px; font-weight: 500; text-align: center;">
                </asp:Label>

                <!-- Search Controls -->
                <div style="background: #faf7f2; border-radius: 12px; padding: 24px; border: 1px solid #F7F3EE; display: flex; align-items: flex-end; gap: 20px; flex-wrap: wrap;">
                    <div style="flex: 1; min-width: 250px;">
                        <label style="display: block; font-size: 13px; font-weight: 600; color: #8B5E3C; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.025em;">Interview Status</label>
                        <asp:DropDownList ID="ddlMembershipType" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlMembershipType_SelectedIndexChanged"
                            style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; color: #1e293b; background-color: white; outline: none;">
                            <asp:ListItem Value="0">- Select Status -</asp:ListItem>
                            <asp:ListItem Value="Approved">Approved</asp:ListItem>
                            <asp:ListItem Value="Rejected">Rejected</asp:ListItem>
                            <asp:ListItem Value="Deferred">Deferred</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <asp:Button ID="btnSave" runat="server" Text="Search Records" OnClick="btnSave_Click" CssClass="btn-hover"
                        style="background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; padding: 11px 28px; border-radius: 8px; border: none; font-weight: 600; font-size: 14px; cursor: pointer; box-shadow: 0 4px 12px rgba(201, 168, 76, 0.2);" />
                </div>
            </div>

            <div style="background: white; border-radius: 16px; padding: 32px; border: 1px solid #e0d5c5; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); margin-bottom: 24px;">
                <div style="overflow-x: auto;">
                    <asp:GridView ID="gvResults" runat="server" AutoGenerateColumns="false" GridLines="None" EmptyDataText="No records found"
                        OnRowCommand="gvResults_RowCommand"
                        style="width: 100%; border-collapse: separate; border-spacing: 0; border-radius: 12px; overflow: hidden; border: 1px solid #e0d5c5;">
                        <HeaderStyle CssClass="gv-header" />
                        <RowStyle CssClass="gv-row" />
                        <Columns>
                            <asp:TemplateField HeaderText="Select" ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <asp:CheckBox ID="chkSelect" runat="server" style="width: 18px; height: 18px; cursor: pointer;" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="S.No" ItemStyle-Width="60px">
                                <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="App No" ItemStyle-Width="90px">
                                <ItemTemplate>
                                    <span style="font-weight: 700; color: #8B5E3C; font-family: monospace; font-size: 13.5px; background: #faf7f2; padding: 2px 8px; border-radius: 4px; border: 1px solid #e0d5c5;">
                                        #<%# Eval("ApplicationNo") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Name">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkOpenForm" runat="server" Text='<%# Eval("IName") %>' 
                                        CommandName="OpenForm" CommandArgument='<%# Eval("NIC") %>'
                                        style="color: #C9A84C; font-weight: 600; text-decoration: none;"></asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="NIC" HeaderText="CNIC" />
                            <asp:BoundField DataField="MemberShip" HeaderText="Membership" />
                            <asp:BoundField DataField="Email" HeaderText="Email" />
                            <asp:BoundField DataField="Remarks" HeaderText="Remarks" />
                        </Columns>
                        <EmptyDataTemplate>
                            <div style="padding: 40px; text-align: center; color: #a09080; font-style: italic;">
                                <p>No records found matching your selection.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

                <div style="margin-top: 24px; display: flex; justify-content: flex-end;">
                    <asp:Button ID="btnAction" runat="server" Text="Convert into Member" OnClick="btnAction_Click" Visible="false" CssClass="btn-hover"
                        style="background: linear-gradient(135deg, #059669, #10b981); color: white; padding: 12px 32px; border-radius: 8px; border: none; font-weight: 600; font-size: 15px; cursor: pointer; box-shadow: 0 4px 12px rgba(16, 185, 129, 0.2);" />
                </div>
            </div>

            <!-- Applicant Details Panel -->
            <asp:Panel ID="pnlApplicantDetails" runat="server" Visible="false" 
                style="background: white; border-radius: 16px; padding: 32px; border: 1px solid #e0d5c5; box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1); margin-top: 32px;">
                
                <div style="border-bottom: 1px solid #F7F3EE; padding-bottom: 20px; margin-bottom: 32px;">
                    <h2 style="font-size: 22px; font-weight: 700; color: #1e293b; margin: 0;">Applicant Details</h2>
                    <p style="font-size: 14px; color: #E8D5A3; margin-top: 4px;">Review and finalize applicant information for membership conversion</p>
                </div>

                <div class="grid-3">
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Membership Selection <span style="color: #ef4444;">*</span></label>
                        <asp:DropDownList ID="ddlMembershipTypeSelected" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlMembershipTypeSelected_SelectedIndexChanged"
                            style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                        <asp:RequiredFieldValidator ID="rfvMemType" runat="server" ControlToValidate="ddlMembershipTypeSelected" InitialValue="0"
                            ErrorMessage="Required" Display="Dynamic" ForeColor="#ef4444" style="font-size: 11px;" ValidationGroup="vgSave" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Form Type Main <span style="color: #ef4444;">*</span></label>
                        <asp:TextBox ID="txtFormTypeMain" runat="server" ReadOnly="true"
                            style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; background: #faf7f2; outline: none;" />
                         <asp:RequiredFieldValidator ID="rfvFormType" runat="server" ControlToValidate="txtFormTypeMain"
                            ErrorMessage="Required" Display="Dynamic" ForeColor="#ef4444" style="font-size: 11px;" ValidationGroup="vgSave" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Member No <span style="color: #ef4444;">*</span></label>
                        <div style="display: flex;">
                            <asp:Label ID="lblMemberPrefix" runat="server" Text="Prefix"
                                style="display: inline-flex; align-items: center; padding: 0 12px; background: #F7F3EE; border: 1.5px solid #e0d5c5; border-right: none; border-radius: 8px 0 0 8px; font-weight: 700; color: #7a7a7a;" />
                            <asp:TextBox ID="MmberNo" runat="server" placeholder="Enter Member No"
                                style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 0 8px 8px 0; font-size: 14px; outline: none;" />
                        </div>
                        <asp:RequiredFieldValidator ID="rfvMemNo" runat="server" ControlToValidate="MmberNo"
                            ErrorMessage="Required" Display="Dynamic" ForeColor="#ef4444" style="font-size: 11px;" ValidationGroup="vgSave" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Name</label>
                        <asp:TextBox ID="txtApplicantName" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Father Name</label>
                        <asp:TextBox ID="txtFatherName" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Date of Birth</label>
                        <asp:TextBox ID="txtDOB" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">CNIC</label>
                        <asp:TextBox ID="txtNIC" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Marital Status</label>
                        <asp:TextBox ID="txtMaritalStatus" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Profession</label>
                        <asp:TextBox ID="txtProfession" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Company Name</label>
                        <asp:TextBox ID="txtCompanyName" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Designation</label>
                        <asp:TextBox ID="txtDesignation" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Nationality</label>
                        <asp:TextBox ID="txtNationality" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Monthly Income</label>
                        <asp:TextBox ID="txtMonthlyIncome" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Currency</label>
                        <asp:TextBox ID="txtCurrency" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Address Type</label>
                        <asp:TextBox ID="txtAddressType" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div style="grid-column: span 2;">
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Address</label>
                        <asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" Rows="1" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">City</label>
                        <asp:TextBox ID="txtCity" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Province</label>
                        <asp:TextBox ID="txtProvince" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Country</label>
                        <asp:TextBox ID="txtCountry" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Zip Code</label>
                        <asp:TextBox ID="txtZipCode" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Phone</label>
                        <asp:TextBox ID="txtPhone" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Mobile</label>
                        <asp:TextBox ID="txtMobile" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Email</label>
                        <asp:TextBox ID="txtEmail" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Institute</label>
                        <asp:TextBox ID="txtInstitute" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Degree</label>
                        <asp:TextBox ID="txtDegree" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Year</label>
                        <asp:TextBox ID="txtYear" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div style="grid-column: span 2;">
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Work Experience</label>
                        <asp:TextBox ID="txtWorkExperience" runat="server" TextMode="MultiLine" Rows="2" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Area of Interest</label>
                        <asp:TextBox ID="txtAreaOfInterest" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Facilities</label>
                        <asp:TextBox ID="txtFacilities" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Other Memberships</label>
                        <asp:TextBox ID="txtOtherMemberships" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    
                    <div style="grid-column: 1 / -1; margin: 20px 0; border-top: 1px solid #F7F3EE; padding-top: 20px;">
                        <h3 style="font-size: 18px; font-weight: 700; color: #1A1A2E; margin: 0;">Spouse & Office Details</h3>
                    </div>

                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Spouse Name</label>
                        <asp:TextBox ID="txtSpouseName" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Spouse Profession</label>
                        <asp:TextBox ID="txtSpouseProfession" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Spouse Education</label>
                        <asp:TextBox ID="txtSpouseEducation" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Spouse CNIC</label>
                        <asp:TextBox ID="txtSpouseCNIC" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Spouse Phone</label>
                        <asp:TextBox ID="txtSpousePhone" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div style="grid-column: span 2;">
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Office Address</label>
                        <asp:TextBox ID="txtOfficeAddress" runat="server" TextMode="MultiLine" Rows="1" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Office City</label>
                        <asp:TextBox ID="txtOfficeCity" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Office Province</label>
                        <asp:TextBox ID="txtOfficeProvince" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Office Country</label>
                        <asp:TextBox ID="txtOfficeCountry" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>

                    <div style="grid-column: 1 / -1; margin: 20px 0; border-top: 1px solid #F7F3EE; padding-top: 20px;">
                        <h3 style="font-size: 18px; font-weight: 700; color: #1A1A2E; margin: 0;">Proposers & Children</h3>
                    </div>

                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Proposer 1</label>
                        <asp:TextBox ID="txtProposer1" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Relation 1</label>
                        <asp:TextBox ID="txtRelation1" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Proposer 2</label>
                        <asp:TextBox ID="txtProposer2" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Relation 2</label>
                        <asp:TextBox ID="txtRelation2" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">No Of Children</label>
                        <asp:TextBox ID="txtNoOfChildren" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Sons</label>
                        <asp:TextBox ID="txtNoOfSons" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Daughters</label>
                        <asp:TextBox ID="txtNoOfDaughters" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>

                    <div style="grid-column: 1 / -1; margin-top: 24px;">
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 12px; text-transform: uppercase;">Children Details Grid</label>
                        <div style="overflow-x: auto; border: 1px solid #e0d5c5; border-radius: 12px;">
                            <asp:GridView ID="gvChildren" runat="server" AutoGenerateColumns="false" GridLines="None" EmptyDataText="No children records found."
                                style="width: 100%; border-collapse: collapse;">
                                <HeaderStyle CssClass="gv-child-header" />
                                <RowStyle CssClass="gv-child-row" />
                                <Columns>
                                    <asp:BoundField DataField="ChildName" HeaderText="Name" />
                                    <asp:BoundField DataField="Relationship" HeaderText="Relation" />
                                    <asp:BoundField DataField="DOB" HeaderText="DOB" DataFormatString="{0:yyyy-MM-dd}" />
                                    <asp:BoundField DataField="Age" HeaderText="Age" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>

                    <div id="divSupplementaryLink" runat="server" style="grid-column: 1 / -1; display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px;">
                        <div>
                            <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Main Member No</label>
                            <asp:TextBox ID="txtMainMemberNo" runat="server" ReadOnly="true" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; background: #faf7f2; outline: none;" />
                        </div>
                        <div>
                            <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Main Member Name</label>
                            <asp:TextBox ID="txtMainMemberName" runat="server" ReadOnly="true" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; background: #faf7f2; outline: none;" />
                        </div>
                    </div>

                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Preferred Number</label>
                        <asp:TextBox ID="txtPreferredNo" runat="server" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Membership Fee</label>
                        <asp:TextBox ID="txtMFee" runat="server" ReadOnly="true" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; background: #faf7f2; outline: none;" />
                    </div>
                    <div>
                        <label style="display: none; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Membership Type</label>
                        <asp:TextBox ID="txtFormType" runat="server" ReadOnly="true" style="width: 100%; display:none; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; background: #faf7f2; outline: none;" />
                    </div>
                    <div>
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #7a7a7a; margin-bottom: 6px; text-transform: uppercase;">Interviewer Name</label>
                        <asp:TextBox ID="txtInterviewerName" runat="server" ReadOnly="true" style="width: 100%; padding: 10px 14px; border: 1.5px solid #e0d5c5; border-radius: 8px; font-size: 14px; background: #faf7f2; outline: none;" />
                    </div>
                </div>

                <!-- Hidden Fields Container -->
                <div style="display: none;">
                    <asp:TextBox ID="txtStatus" runat="server" Visible="false" />
                    <asp:TextBox ID="txtRemarks" runat="server" Visible="false" TextMode="MultiLine" Rows="2" />
                    <asp:HiddenField ID="hfPurchaseDate" runat="server" />
                    <asp:HiddenField ID="hfReceiptNo" runat="server" />
                    <asp:HiddenField ID="hfApplicantPhotoPath" runat="server" />
                    <asp:HiddenField ID="hfFeeDistributionJson" runat="server" />
                </div>

                <div style="margin-top: 40px; padding-top: 24px; border-top: 1px solid #F7F3EE; display: flex; justify-content: flex-end; gap: 16px;">
                    <asp:Button ID="btnClosePanel" runat="server" Text="Close" OnClick="btnClosePanel_Click" CssClass="btn-hover"
                        style="background: white; color: #7a7a7a; padding: 11px 28px; border-radius: 8px; border: 1.5px solid #e0d5c5; font-weight: 600; font-size: 14px; cursor: pointer;" />
                    <asp:Button ID="btnSaveApplicant" runat="server" Text="Save &amp; Convert Member" OnClick="btnSaveApplicant_Click" CssClass="btn-hover" ValidationGroup="vgSave"
                        OnClientClick="return openFeeDistributionModal();"
                        style="background: linear-gradient(135deg, #059669, #10b981); color: white; padding: 11px 32px; border-radius: 8px; border: none; font-weight: 600; font-size: 14px; cursor: pointer; box-shadow: 0 4px 12px rgba(16, 185, 129, 0.2);" />
                </div>
            </asp:Panel>

            <!-- Fee Distribution Modal -->
            <div id="feeDistributionModal" class="fee-modal-overlay">
                <div class="fee-modal-box">
                    <div class="fee-modal-header">
                        <h2 style="margin: 0 0 4px 0; font-size: 20px; font-weight: 700; color: #1e293b;">Fee Distribution</h2>
                        <p style="margin: 0; font-size: 13px; color: #64748b;">Allocate the membership fee across finance heads. Total must equal MFee exactly.</p>
                        <div style="display: flex; gap: 24px; margin-top: 14px;">
                            <div>
                                <span style="font-size: 11px; text-transform: uppercase; color: #94a3b8; font-weight: 600;">Applicant</span>
                                <div id="modalApplicantName" style="font-size: 14px; font-weight: 600; color: #1e293b;">—</div>
                            </div>
                            <div>
                                <span style="font-size: 11px; text-transform: uppercase; color: #94a3b8; font-weight: 600;">CNIC</span>
                                <div id="modalApplicantNIC" style="font-size: 14px; font-weight: 600; color: #1e293b;">—</div>
                            </div>
                            <div>
                                <span style="font-size: 11px; text-transform: uppercase; color: #94a3b8; font-weight: 600;">Required MFee</span>
                                <div id="modalMFee" style="font-size: 16px; font-weight: 700; color: #C9A84C;">0.00</div>
                            </div>
                        </div>
                    </div>
                    <div class="fee-modal-body">
                        <label style="display: block; font-size: 12px; font-weight: 600; color: #8B5E3C; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.03em;">Select Finance Head</label>
                        <asp:DropDownList ID="ddlFinanceHeads" runat="server" CssClass="fee-head-select"
                            style="width: 100%; font-size: 14px;">
                        </asp:DropDownList>

                        <div id="feeRowsContainer" style="margin-top: 20px; min-height: 40px;">
                            <div id="feeRowsEmpty" style="text-align: center; padding: 24px; color: #94a3b8; font-style: italic; font-size: 13px;">
                                Select a finance head above to add fee allocation rows
                            </div>
                        </div>

                        <div id="feeStatusBar" class="fee-status-bar empty">
                            <span id="feeStatusText">No heads selected yet</span>
                            <span id="feeStatusAmount">0.00 / 0.00</span>
                        </div>
                    </div>
                    <div class="fee-modal-footer">
                        <button type="button" onclick="closeFeeModal();"
                            style="background: white; color: #7a7a7a; padding: 10px 24px; border-radius: 8px; border: 1.5px solid #e0d5c5; font-weight: 600; font-size: 14px; cursor: pointer;">
                            Cancel
                        </button>
                        <button type="button" id="btnConfirmFeeDistribution" onclick="confirmFeeDistribution();" disabled
                            style="background: linear-gradient(135deg, #059669, #10b981); color: white; padding: 10px 28px; border-radius: 8px; border: none; font-weight: 600; font-size: 14px; cursor: pointer; box-shadow: 0 4px 12px rgba(16,185,129,0.2); opacity: 0.5;">
                            Confirm &amp; Convert Member
                        </button>
                    </div>
                </div>
            </div>

        </div>

        <script type="text/javascript">
            var feeModalAlreadyConfirmed = false;

            function openFeeDistributionModal() {
                // If already confirmed from modal, allow postback
                if (feeModalAlreadyConfirmed) {
                    feeModalAlreadyConfirmed = false;
                    return true;
                }

                // Client-side validation before opening modal
                if (typeof Page_ClientValidate === 'function') {
                    if (!Page_ClientValidate('vgSave')) return false;
                }

                // Fill modal header with applicant info
                var nameEl = document.getElementById('<%= txtApplicantName.ClientID %>');
                var nicEl = document.getElementById('<%= txtNIC.ClientID %>');
                var mfeeEl = document.getElementById('<%= txtMFee.ClientID %>');

                document.getElementById('modalApplicantName').innerText = nameEl ? nameEl.value : '—';
                document.getElementById('modalApplicantNIC').innerText = nicEl ? nicEl.value : '—';
                var mfeeVal = mfeeEl ? parseFloat(mfeeEl.value) || 0 : 0;
                document.getElementById('modalMFee').innerText = mfeeVal.toFixed(2);

                // Reset modal state
                document.getElementById('feeRowsContainer').innerHTML =
                    '<div id="feeRowsEmpty" style="text-align:center;padding:24px;color:#94a3b8;font-style:italic;font-size:13px;">Select a finance head above to add fee allocation rows</div>';
                updateFeeStatus();

                // Show modal
                document.getElementById('feeDistributionModal').classList.add('active');

                // Init Select2 on the finance heads dropdown
                var ddlId = '#<%= ddlFinanceHeads.ClientID %>';
                $(ddlId).val('0').trigger('change');
                $(ddlId).select2({
                    placeholder: 'Search or select a finance head...',
                    allowClear: true,
                    width: '100%',
                    dropdownParent: $('#feeDistributionModal .fee-modal-box')
                });

                // Bind selection event
                $(ddlId).off('select2:select').on('select2:select', function (e) {
                    var data = e.params.data;
                    if (data.id && data.id !== '0') {
                        addFeeRow(data.id, data.text);
                        $(ddlId).val('0').trigger('change');
                    }
                });

                return false; // Prevent postback
            }

            function closeFeeModal() {
                document.getElementById('feeDistributionModal').classList.remove('active');
            }

            function addFeeRow(headId, headText) {
                // Check if head already added
                if (document.getElementById('feeRow_' + headId)) {
                    alert('This head is already added!');
                    return;
                }

                // Remove empty placeholder
                var empty = document.getElementById('feeRowsEmpty');
                if (empty) empty.remove();

                // Parse head text to extract e_code and head_type
                // Format from dropdown: "e_code - Head_Type"
                var parts = headText.split(' - ');
                var eCode = parts.length > 0 ? parts[0].trim() : '';
                var headType = parts.length > 1 ? parts.slice(1).join(' - ').trim() : headText;

                var container = document.getElementById('feeRowsContainer');
                var row = document.createElement('div');
                row.className = 'fee-row';
                row.id = 'feeRow_' + headId;
                row.setAttribute('data-headid', headId);
                row.setAttribute('data-ecode', eCode);
                row.setAttribute('data-headtype', headType);

                row.innerHTML =
                    '<span class="fee-row-code">' + eCode + '</span>' +
                    '<span class="fee-row-label">' + headType + '</span>' +
                    '<input type="number" class="fee-row-input" placeholder="0.00" step="0.01" min="0" oninput="updateFeeStatus()" />' +
                    '<button type="button" class="fee-row-remove" onclick="removeFeeRow(\'' + headId + '\')" title="Remove">&times;</button>';

                container.appendChild(row);

                // Focus on the new input
                var input = row.querySelector('.fee-row-input');
                if (input) input.focus();

                updateFeeStatus();
            }

            function removeFeeRow(headId) {
                var row = document.getElementById('feeRow_' + headId);
                if (row) row.remove();

                var container = document.getElementById('feeRowsContainer');
                if (container.children.length === 0) {
                    container.innerHTML =
                        '<div id="feeRowsEmpty" style="text-align:center;padding:24px;color:#94a3b8;font-style:italic;font-size:13px;">Select a finance head above to add fee allocation rows</div>';
                }
                updateFeeStatus();
            }

            function updateFeeStatus() {
                var mfeeEl = document.getElementById('<%= txtMFee.ClientID %>');
                var requiredMFee = mfeeEl ? parseFloat(mfeeEl.value) || 0 : 0;
                var inputs = document.querySelectorAll('#feeRowsContainer .fee-row-input');
                var total = 0;
                inputs.forEach(function (inp) {
                    var v = parseFloat(inp.value) || 0;
                    total += v;
                    // Remove error class
                    inp.classList.remove('error');
                });

                var statusBar = document.getElementById('feeStatusBar');
                var statusText = document.getElementById('feeStatusText');
                var statusAmount = document.getElementById('feeStatusAmount');
                var confirmBtn = document.getElementById('btnConfirmFeeDistribution');
                var diff = requiredMFee - total;

                statusAmount.innerText = total.toFixed(2) + ' / ' + requiredMFee.toFixed(2);

                if (inputs.length === 0) {
                    statusBar.className = 'fee-status-bar empty';
                    statusText.innerText = 'No heads selected yet';
                    confirmBtn.disabled = true;
                    confirmBtn.style.opacity = '0.5';
                } else if (Math.abs(diff) < 0.01) {
                    statusBar.className = 'fee-status-bar balanced';
                    statusText.innerText = 'Balanced — Total matches MFee exactly';
                    confirmBtn.disabled = false;
                    confirmBtn.style.opacity = '1';
                } else {
                    statusBar.className = 'fee-status-bar unbalanced';
                    if (diff > 0) {
                        statusText.innerText = 'Short by ' + diff.toFixed(2) + ' — Allocate more';
                    } else {
                        statusText.innerText = 'Over by ' + Math.abs(diff).toFixed(2) + ' — Reduce amounts';
                    }
                    confirmBtn.disabled = true;
                    confirmBtn.style.opacity = '0.5';
                }
            }

            function confirmFeeDistribution() {
                var mfeeEl = document.getElementById('<%= txtMFee.ClientID %>');
                var requiredMFee = mfeeEl ? parseFloat(mfeeEl.value) || 0 : 0;
                var rows = document.querySelectorAll('#feeRowsContainer .fee-row');
                var distribution = [];
                var total = 0;

                rows.forEach(function (row) {
                    var input = row.querySelector('.fee-row-input');
                    var amount = parseFloat(input.value) || 0;
                    total += amount;
                    distribution.push({
                        HeadId: row.getAttribute('data-headid'),
                        ECode: row.getAttribute('data-ecode'),
                        HeadType: row.getAttribute('data-headtype'),
                        Amount: amount
                    });
                });

                if (Math.abs(requiredMFee - total) >= 0.01) {
                    alert('Total allocated (' + total.toFixed(2) + ') must equal MFee (' + requiredMFee.toFixed(2) + ').');
                    return;
                }

                if (distribution.length === 0) {
                    alert('Please add at least one fee head allocation.');
                    return;
                }

                // Save JSON to hidden field
                var hf = document.getElementById('<%= hfFeeDistributionJson.ClientID %>');
                hf.value = JSON.stringify(distribution);

                // Close modal
                closeFeeModal();

                // Set flag and trigger the server-side button click
                feeModalAlreadyConfirmed = true;
                var btn = document.getElementById('<%= btnSaveApplicant.ClientID %>');
                btn.click();
            }
        </script>
    </asp:Content>
