<%@ Page Title="LAHORE GYMKHANA" Language="C#" MasterPageFile="~/MemberShipModule/Site.master"
    AutoEventWireup="true" CodeFile="Applicant-formsell.aspx.cs" Inherits="Form_cell.Applicant_Form.Applicant_formcell"
    %>


    <asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
        <style>
            /* Essential Styles (Self-contained for server deployments) */
            .table-container { background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
            .table { width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left; }
            .table th { background: #f8fafc; color: #334155; font-weight: 600; padding: 0.75rem 1rem; border-bottom: 2px solid #e2e8f0; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.05em; }
            .table td { padding: 0.75rem 1rem; border-bottom: 1px solid #e2e8f0; color: #0f172a; vertical-align: middle; }
            .table tr:last-child td { border-bottom: none; }
            .empty-state { padding: 2rem; text-align: center; color: #94a3b8; background-color: #f8fafc; border: 1px dashed #e2e8f0; border-radius: 12px; display: flex; flex-direction: column; align-items: center; gap: 0.75rem; margin-top: 1rem; }
            .empty-state svg { color: #94a3b8; opacity: 0.6; margin-bottom: 0.5rem; }
            .table-input { width: 100%; padding: 0.5rem 0.75rem; border: 1px solid transparent; border-radius: 6px; background: transparent; font-size: 0.95rem; color: #0f172a; transition: all 0.2s ease; }
            .table-input:hover { background: #f1f5f9; border-color: #e2e8f0; }
            .table-input:focus { background: #ffffff; border-color: #3b82f6; box-shadow: 0 0 0 2px #dbeafe; outline: none; }
            .form-control { display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #0f172a; background-color: white; border: 1px solid #cbd5e1; border-radius: 6px; }
            .form-control:focus { border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15); outline: none; }
            
            /* Button Styles */
            .btn { display: inline-block; text-align: center; vertical-align: middle; padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: all 0.15s ease; border: 1px solid transparent; line-height: 1; }
            .btn-primary { background: linear-gradient(135deg, #2563eb, #3b82f6); color: white; box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2); }
            .btn-primary:hover { box-shadow: 0 8px 12px rgba(37, 99, 235, 0.3); transform: translateY(-1px); }
            .btn-secondary { background-color: white; color: #334155; border-color: #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
            .btn-secondary:hover { background-color: #f1f5f9; border-color: #cbd5e1; color: #0f172a; }
            .btn-success { background-color: #10b981; color: white; border-color: #10b981; border: 1px solid #10b981; }
            .btn-danger { background-color: #ef4444; color: white; border-color: #ef4444; border: 1px solid #ef4444; }
            .btn-warning { background-color: #f59e0b; color: white; border-color: #f59e0b; border: 1px solid #f59e0b; }
            .btn-info { background-color: #3b82f6; color: white; border-color: #3b82f6; border: 1px solid #3b82f6; }
            .btn-sm { padding: 0.4rem 0.8rem; font-size: 0.875rem; }
            .btn-sm.flex { display: inline-flex; align-items: center; justify-content: center; }
        </style>
                <script>
            function formatCNICorPassport(input) {
                let value = input.value.toUpperCase();

                if (/^[A-Z]/.test(value)) {
                    input.value = value.replace(/[^A-Z0-9]/g, '').substring(0, 9);
                    return;
                }

                value = value.replace(/[^0-9]/g, '');

                if (value.length > 5 && value.length <= 12)
                    value = value.replace(/^(\d{5})(\d+)/, '$1-$2');
                else if (value.length > 12)
                    value = value.replace(/^(\d{5})(\d{7})(\d+)/, '$1-$2-$3');

                input.value = value.substring(0, 15);
            }
        </script>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">



        <div class="page-wrapper mt-6" style="margin-top: 0.75rem; /* Heavily reduced */;">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); transition: none; /* Removed hover effect */ position: relative; overflow: hidden; height: 100%; /* Slightly reduced padding */;">

                <div class="flex items-center justify-between mb-8 pb-6 border-b border-subtle" style="align-items: center; justify-content: space-between; margin-bottom: 2rem; margin-bottom: 2rem !important; padding-bottom: 1.5rem !important; border-bottom: 1px solid #e2e8f0; border-color: #e2e8f0 !important;">
                    <div>
                        <h1 class="text-2xl font-bold text-primary-900 m-0" style="font-size: 1.5rem !important; font-weight: 700; color: #0f172a !important; margin: 0;">Membership Application</h1>
                        <p class="text-secondary mt-1" style="color: #475569 !important;">New applicant registration form</p>
                    </div>
                    <div class="badge badge-info text-lg px-4 py-2" style="background-color: #dbeafe; color: #3b82f6;">
                        <span id="priceSpan" runat="server">Price: Rs. 0</span>
                    </div>
                </div>

                <div class="form-grid" style="width: 100%;">
                    <!-- Section 1 -->
                    <div class="form-section" style="padding: 1rem; margin-bottom: 1rem;">
                        <div class="section-header" style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem; padding-bottom: 0.75rem; border-bottom: 1px solid #e2e8f0; padding-bottom: 0.5rem;">
                            <div class="section-icon" style="width: 40px; height: 40px; background: transparent; color: #2563eb; display: flex; align-items: center; justify-content: center;">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2">
                                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                                    <polyline points="14 2 14 8 20 8"></polyline>
                                    <line x1="16" y1="13" x2="8" y2="13"></line>
                                    <line x1="16" y1="17" x2="8" y2="17"></line>
                                    <polyline points="10 9 9 9 8 9"></polyline>
                                </svg>
                            </div>
                            <div>
                                <h2 class="section-title" style="font-size: 1.15rem; font-weight: 700; margin: 0; color: #0f172a;">Application Details</h2>
                                <p class="section-subtitle" style="font-size: 0.875rem; color: #475569; margin: 0;">Form type and classification</p>
                            </div>
                        </div>

                        <div class="grid-2 gap-6" style="grid-template-columns: 1fr; /* Stack everything */; grid-template-columns: repeat(2, 1fr); gap: 2rem; /* Increased to 2rem for better spacing */;">
                            <div class="form-group">
                                <label>Form Type</label>
                                <asp:DropDownList ID="DropDownList1" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="DropDownList1_SelectedIndexChanged" CssClass="form-control" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;">
                                </asp:DropDownList>
                            </div>
                            <div class="form-group">
                                <label>Membership Class</label>
                                <asp:UpdatePanel ID="upMembershipClass" runat="server">
                                    <ContentTemplate>
                                        <asp:DropDownList ID="DropDownList2" runat="server" CssClass="form-control"
                                            AutoPostBack="true"
                                            OnSelectedIndexChanged="DropDownList2_SelectedIndexChanged" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;">
                                        </asp:DropDownList>

                                        <div id="divActiveMember" runat="server" visible="false"
                                            class="mt-4 p-4 bg-blue-50 border border-blue-100 rounded-lg" style="margin-top: 0.5rem; /* Heavily reduced */; padding: 1rem;">
                                            <div class="form-group">
                                                <label class="text-blue-900 font-semibold">Primary Member No
                                                    (Active):</label>
                                                <div class="flex gap-2" style="gap: 0.5rem;">
                                                    <asp:TextBox ID="txtActiveMemberNo" runat="server"
                                                        CssClass="form-control" placeholder="Enter Primary Member No"
                                                        AutoPostBack="true"
                                                        OnTextChanged="txtActiveMemberNo_TextChanged" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;"></asp:TextBox>
                                                </div>
                                                <asp:Label ID="lblActiveMemberName" runat="server"
                                                    CssClass="text-sm font-medium mt-1 block h-5" style="font-size: 0.875rem; line-height: 1.25rem; margin-top: 0.25rem !important; display: block !important;"></asp:Label>
                                            </div>
                                        </div>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="DropDownList2"
                                            EventName="SelectedIndexChanged" />
                                        <asp:AsyncPostBackTrigger ControlID="txtActiveMemberNo"
                                            EventName="TextChanged" />
                                    </Triggers>
                                </asp:UpdatePanel>
                            </div>
                        </div>


                    </div>

                    <!-- Section 2 -->
                    <div class="form-section" style="padding: 1rem; margin-bottom: 1rem;">
                        <div class="section-header" style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem; padding-bottom: 0.75rem; border-bottom: 1px solid #e2e8f0; padding-bottom: 0.5rem;">
                            <div class="section-icon" style="width: 40px; height: 40px; background: transparent; color: #2563eb; display: flex; align-items: center; justify-content: center;">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2">
                                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                    <circle cx="12" cy="7" r="4"></circle>
                                </svg>
                            </div>
                            <div>
                                <h2 class="section-title" style="font-size: 1.15rem; font-weight: 700; margin: 0; color: #0f172a;">Applicant Information</h2>
                                <p class="section-subtitle" style="font-size: 0.875rem; color: #475569; margin: 0;">Personal details and identification</p>
                            </div>
                        </div>

                        <div class="grid-2 gap-6" style="grid-template-columns: 1fr; /* Stack everything */; grid-template-columns: repeat(2, 1fr); gap: 2rem; /* Increased to 2rem for better spacing */;">
                            <div class="form-group">
                                <label>Applicant Name</label>
                                <asp:TextBox ID="txtPurchaseBy" runat="server" CssClass="form-control"
                                    placeholder="Full legal name" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;">
                                </asp:TextBox>
                            </div>
                            <div class="form-group">
                                <label>CNIC / Passport</label>
                                <asp:TextBox ID="CNIC" runat="server" MaxLength="15" AutoPostBack="true"
                                    OnTextChanged="CNIC_TextChanged" oninput="formatCNICorPassport(this);"
                                    placeholder="12345-1234567-1" CssClass="form-control" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;">
                                </asp:TextBox>
                                <small class="text-secondary text-sm mt-1 block" style="color: #475569 !important; font-size: 0.875rem; line-height: 1.25rem; margin-top: 0.25rem !important;">Format: 12345-1234567-1 or
                                    AB1234567</small>
                            </div>
                        </div>

                        <div class="grid-2 gap-6 mt-6" style="grid-template-columns: 1fr; /* Stack everything */; grid-template-columns: repeat(2, 1fr); gap: 2rem; /* Increased to 2rem for better spacing */; margin-top: 0.75rem; /* Heavily reduced */;">
                            <div class="form-group">
                                <label>Phone No</label>
                                <asp:TextBox ID="txtPhoneNo" runat="server" MaxLength="11"
                                    oninput="this.value=this.value.replace(/[^0-9]/g,'').slice(0,11);"
                                    CssClass="form-control" placeholder="03001234567" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;">
                                </asp:TextBox>
                            </div>
                            <div class="form-group flex flex-col justify-end">
                                <div class="bg-gray-50 border border-subtle rounded-lg p-3 text-center" style="border-color: #e2e8f0 !important;">
                                    <asp:Label ID="lblReceiptNo" runat="server" Text="Receipt: ---"
                                        CssClass="font-mono font-bold text-primary-700"></asp:Label>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div class="flex flex-wrap gap-4 mt-8 pt-6 border-t border-subtle" style="gap: 1rem; margin-top: 1rem; /* Heavily reduced */; padding-top: 1.5rem !important; border-color: #e2e8f0 !important;">
                    <asp:Button ID="btnSave" runat="server" Text="Save Application" OnClick="btnSave_Click"
                        CssClass="btn btn-primary"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #2563eb, #3b82f6); color: white; box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2);" /> <!-- Standardized class -->
                    <asp:Button ID="Search" runat="server" Text="Search Records" OnClick="btnSearch_Click"
                        CssClass="btn btn-secondary"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background-color: white; color: #334155; border: 1px solid #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);" />
                </div>

                <asp:Label ID="lblMessage" runat="server" CssClass="status-message block mt-4"  style="display: block !important; margin-top: 0.5rem; /* Heavily reduced */;" />
            </div>
        </div>
    </asp:Content>









