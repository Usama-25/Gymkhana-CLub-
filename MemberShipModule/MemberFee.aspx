<%@ Page Title="Receive Member Fee" Language="C#" MasterPageFile="~/MemberShipModule/Site.master"
    AutoEventWireup="true" CodeFile="MemberFee.aspx.cs" Inherits="MembershipProfile" %>
    <asp:Content ID="HeadStyles" ContentPlaceHolderID="HeadContent" runat="server">
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
            </asp:Content>


    <asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="Server">
        <div class="page-wrapper mt-6" style="margin-top: 0.75rem; /* Heavily reduced */;">
            <div class="card max-w-4xl mx-auto" style="background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); transition: none; /* Removed hover effect */ position: relative; overflow: hidden; height: 100%; /* Slightly reduced padding */;">

                <div class="flex items-center justify-between mb-8 pb-6 border-b border-subtle" style="align-items: center; justify-content: space-between; margin-bottom: 2rem; margin-bottom: 2rem !important; padding-bottom: 1.5rem !important; border-bottom: 1px solid #e2e8f0; border-color: #e2e8f0 !important;">
                    <div>
                        <h1 class="text-2xl font-bold text-primary-900 m-0" style="font-size: 1.5rem !important; font-weight: 700; color: #0f172a !important; margin: 0;">Receive Member Fee</h1>
                        <p class="text-secondary mt-1" style="color: #475569 !important;">Process fee payments and installments</p>
                    </div>
                </div>

                <!-- Information Section -->
                <div class="bg-gray-50 rounded-lg p-6 border border-subtle mb-6" style="padding: 1.5rem; border-color: #e2e8f0 !important; margin-bottom: 1.5rem;">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6" style="gap: 2rem; /* Increased to 2rem for better spacing */;">

                        <div class="form-group">
                            <label class="form-label">Purchase By</label>
                            <div class="p-3 bg-white border border-subtle rounded-lg text-primary-900 font-medium" style="border-color: #e2e8f0 !important; color: #0f172a !important;">
                                <asp:Label ID="lblPurchaseBy" runat="server" Text="--" />
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Payment Form -->


                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8" style="gap: 2rem; /* Increased to 2rem for better spacing */; margin-bottom: 2rem; margin-bottom: 2rem !important;">
                    <div class="form-group">
                        <label class="form-label">Form Fee </label>
                        <div class="relative">
                            <span class="absolute left-3 top-2.5 text-gray-500 font-bold" style="color: #64748b !important; font-weight: 700;">Rs.</span>
                            <asp:TextBox ID="txtPrice" runat="server"
                                CssClass="form-control pl-10 font-mono font-bold text-lg" placeholder="0.00" />
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Payment Mode</label>
                        <asp:UpdatePanel ID="upPaymentMode" runat="server">
                            <ContentTemplate>
                                <asp:DropDownList ID="ddlMode" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlMode_SelectedIndexChanged" CssClass="form-control" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;">
                                    <asp:ListItem Text="Cash" Value="Cash"></asp:ListItem>
                                    <asp:ListItem Text="Cheque" Value="Cheque"></asp:ListItem>
                                    <asp:ListItem Text="Online" Value="Online"></asp:ListItem>
                                </asp:DropDownList>

                                <!-- Conditional Fields -->
                                <div class="mt-4 space-y-4" style="margin-top: 0.5rem; /* Heavily reduced */;">
                                    <asp:Panel runat="server" ID="pnlCash" Visible="false">
                                        <%-- Logic handled by code-behind visibility --%>
                                            <asp:Label ID="lblCashType" runat="server" Text="Cash Type"
                                                CssClass="form-label block mb-1"  style="display: block !important;" />
                                            <asp:DropDownList ID="ddlCashType" runat="server" CssClass="form-control" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;">
                                                <asp:ListItem Text="Cash In Hand" Value="CashInHand"></asp:ListItem>
                                                <asp:ListItem Text="Petty Cash" Value="PettyCash"></asp:ListItem>
                                            </asp:DropDownList>
                                    </asp:Panel>

                                    <asp:Panel runat="server" ID="pnlCheque" Visible="false">
                                        <asp:Label ID="lblCheque" runat="server" Text="Cheque No"
                                            CssClass="form-label block mb-1"  style="display: block !important;" />
                                        <asp:TextBox ID="txtCheque" runat="server" CssClass="form-control"  style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;" />
                                    </asp:Panel>

                                    <asp:Panel runat="server" ID="pnlOnline" Visible="false">
                                        <asp:Label ID="lblBank" runat="server" Text="Bank Account"
                                            CssClass="form-label block mb-1"  style="display: block !important;" />
                                        <asp:TextBox ID="txtBankAccount" runat="server" CssClass="form-control"  style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;" />
                                    </asp:Panel>
                                </div>
                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="ddlMode" EventName="SelectedIndexChanged" />
                            </Triggers>
                        </asp:UpdatePanel>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div class="flex justify-center gap-4 pt-6 border-t border-subtle" style="justify-content: center; justify-content: center !important; gap: 1rem; padding-top: 1.5rem !important; border-color: #e2e8f0 !important;">
                    <asp:Button ID="btnSearch" runat="server" Text="Save Payment" OnClick="btnSave_Click"
                        CssClass="btn btn-primary min-w-[160px]"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #2563eb, #3b82f6); color: white; box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2);" />
                    <asp:Button ID="Button1" runat="server" Text="Add MemberShipFee"
                        OnClientClick="showModal(); return false;" CssClass="btn btn-success min-w-[160px]" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid #10b981; background-color: #10b981; color: white;" />
                </div>

                <!-- Feedback Message -->
                <div class="mt-4 text-center" style="margin-top: 0.5rem; /* Heavily reduced */;">
                    <asp:Label ID="lblMessage" runat="server" CssClass="font-semibold text-lg" />
                </div>
            </div>
        </div>

        <!-- Installment Modal -->
        <div id="installmentModal"
            class="fixed inset-0 bg-black bg-opacity-60 z-50 hidden items-center justify-center p-4" style="align-items: center; justify-content: center; justify-content: center !important; padding: 1rem;">
            <div class="bg-white rounded-xl shadow-2xl w-full max-w-sm transform transition-all scale-100 p-6" style="padding: 1.5rem;">
                <div class="flex justify-between items-center mb-6" style="justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                    <h3 class="text-xl font-bold text-primary-900 m-0" style="font-weight: 700; color: #0f172a !important; margin: 0;">Add Installment</h3>
                    <button type="button" onclick="hideModal()"
                        class="text-gray-400 hover:text-gray-600 text-2xl font-bold focus:outline-none" style="font-size: 1.5rem !important; font-weight: 700;">&times;</button>
                </div>

                <div class="form-group mb-6" style="margin-bottom: 1.5rem;">
                    <label class="form-label">Installment Amount</label>
                    <div class="relative">
                        <span class="absolute left-3 top-2.5 text-gray-500 font-bold" style="color: #64748b !important; font-weight: 700;">Rs.</span>
                        <asp:TextBox ID="txtInstallment" runat="server" CssClass="form-control pl-10"
                            placeholder="0.00"  style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;" />
                    </div>
                </div>

                <div class="flex flex-col gap-3">
                    <asp:Button ID="btnUpdateInstallment" runat="server" Text="Save Installment"
                        OnClick="UpdateInstallment_Click" CssClass="btn btn-success w-full" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid #10b981; background-color: #10b981; color: white;" />

                    <button type="button" onclick="hideModal()" class="btn btn-secondary w-full" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background-color: white; color: #334155; border: 1px solid #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);">Cancel</button>
                </div>
            </div>
        </div>

        <script type="text/javascript">
            function showModal() {
                const modal = document.getElementById('installmentModal');
                modal.classList.remove('hidden');
                modal.classList.add('flex');
            }

            function hideModal() {
                const modal = document.getElementById('installmentModal');
                modal.classList.add('hidden');
                modal.classList.remove('flex');
            }

            // Close on outside click
            window.onclick = function (event) {
                var modal = document.getElementById('installmentModal');
                if (event.target == modal) {
                    hideModal();
                }
            }
        </script>

    </asp:Content>










