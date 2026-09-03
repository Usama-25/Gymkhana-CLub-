<%@ Page Title="Cashier Page" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true"
    CodeFile="CashierPage.aspx.cs" Inherits="MemberShipModule.CashierPage" %>

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
                <style>
            .check-fields {
                display: none;
            }
        </style>
        <script>
            function togglePaymentMode() {
                var mode = document.getElementById('<%= ddlModeOfPayment.ClientID %>').value;
                var details = document.getElementById('chequeDetails');
                if (mode === '2') {
                    details.style.display = 'block';
                } else {
                    details.style.display = 'none';
                }
            }
        </script>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="page-wrapper mt-6" style="margin-top: 0.75rem; /* Heavily reduced */;">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); transition: none; /* Removed hover effect */ position: relative; overflow: hidden; height: 100%; /* Slightly reduced padding */;">
                <div class="flex items-center justify-between mb-8 pb-6 border-b border-subtle" style="align-items: center; justify-content: space-between; margin-bottom: 2rem; margin-bottom: 2rem !important; padding-bottom: 1.5rem !important; border-bottom: 1px solid #e2e8f0; border-color: #e2e8f0 !important;">
                    <div>
                        <h1 class="text-2xl font-bold text-primary-900 m-0" style="font-size: 1.5rem !important; font-weight: 700; color: #0f172a !important; margin: 0;">Cashier Transaction</h1>
                        <p class="text-secondary mt-1" style="color: #475569 !important;">Record new payment transaction</p>
                    </div>
                </div>

                <div class="form-grid" style="width: 100%;">
                    <div class="form-section" style="padding: 1rem; margin-bottom: 1rem;">
                        <div class="grid-2 gap-6" style="grid-template-columns: 1fr; /* Stack everything */; grid-template-columns: repeat(2, 1fr); gap: 2rem; /* Increased to 2rem for better spacing */;">
                            <div class="form-group">
                                <label>Receipt Mode</label>
                                <asp:DropDownList ID="ddlReceiptMode" runat="server" CssClass="form-control" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;">
                                </asp:DropDownList>
                            </div>
                            <div class="form-group">
                                <label>Receipt Date</label>
                                <asp:TextBox ID="txtReceiptDate" runat="server" CssClass="form-control" TextMode="Date" ReadOnly="true" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;"></asp:TextBox>
                            </div>
                        </div>

                        <div class="grid-2 gap-6 mt-6" style="grid-template-columns: 1fr; /* Stack everything */; grid-template-columns: repeat(2, 1fr); gap: 2rem; /* Increased to 2rem for better spacing */; margin-top: 0.75rem; /* Heavily reduced */;">
                            <div class="form-group">
                                <label>Amount</label>
                                <asp:TextBox ID="txtAmount" runat="server" CssClass="form-control" placeholder="0.00" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;"></asp:TextBox>
                            </div>
                            <div class="form-group">
                                <label>Tax Amount</label>
                                <asp:TextBox ID="txtTaxAmount" runat="server" CssClass="form-control" placeholder="0.00" Text="0.00" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;"></asp:TextBox>
                            </div>
                        </div>

                        <div class="grid-2 gap-6 mt-6" style="grid-template-columns: 1fr; /* Stack everything */; grid-template-columns: repeat(2, 1fr); gap: 2rem; /* Increased to 2rem for better spacing */; margin-top: 0.75rem; /* Heavily reduced */;">
                            <div class="form-group">
                                <label>Mode of Payment</label>
                                <asp:DropDownList ID="ddlModeOfPayment" runat="server" CssClass="form-control"
                                    onchange="togglePaymentMode()" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;">
                                    <asp:ListItem Text="Cash" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="Cheque" Value="2"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="form-group">
                                <label>Payment Head</label>
                                <asp:TextBox ID="txtPaymentHead" runat="server" CssClass="form-control" placeholder="Optional" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;"></asp:TextBox>
                            </div>
                        </div>

                        <!-- Cheque Details (Conditional) -->
                        <div id="chequeDetails">
                            <div class="grid-1 gap-6 mt-6" style="gap: 2rem; /* Increased to 2rem for better spacing */; margin-top: 0.75rem; /* Heavily reduced */;">
                                <div class="form-group">
                                    <label class="form-label">Payment Reference / Cheque No</label>
                                    <asp:TextBox ID="txtPaymentRefrence" runat="server" CssClass="form-control"
                                        placeholder="Enter Ref/Cheque Number"  style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;" />
                                </div>
                            </div>
                        </div>

                        <div class="grid-1 mt-6" style="margin-top: 0.75rem; /* Heavily reduced */;">
                            <div class="form-group">
                                <label>Notes (Include Name/CNIC if required)</label>
                                <asp:TextBox ID="txtNotes" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="Additional details..." style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="flex flex-wrap gap-4 mt-8 pt-6 border-t border-subtle" style="gap: 1rem; margin-top: 1rem; /* Heavily reduced */; padding-top: 1.5rem !important; border-color: #e2e8f0 !important;">
                    <asp:Button ID="btnSave" runat="server" Text="Save Transaction" OnClick="btnSave_Click"
                        CssClass="btn btn-primary"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #2563eb, #3b82f6); color: white; box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2);" />
                </div>

                <asp:Label ID="lblMessage" runat="server" CssClass="status-message block mt-4"  style="display: block !important; margin-top: 0.5rem; /* Heavily reduced */;" />
            </div>
        </div>
    </asp:Content>











