<%@ Page Title="Refund Member Fee" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true"
    CodeFile="RefundMemberFee.aspx.cs" Inherits="RefundFee.Interviewlist1" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
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

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">
        <div class="page-wrapper mt-6" style="margin-top: 0.75rem; /* Heavily reduced */;">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); transition: none; /* Removed hover effect */ position: relative; overflow: hidden; height: 100%; /* Slightly reduced padding */;">

                <div class="flex items-center justify-between mb-8 pb-6 border-b border-subtle" style="align-items: center; justify-content: space-between; margin-bottom: 2rem; margin-bottom: 2rem !important; padding-bottom: 1.5rem !important; border-bottom: 1px solid #e2e8f0; border-color: #e2e8f0 !important;">
                    <div>
                        <h1 class="text-2xl font-bold text-primary-900 m-0" style="font-size: 1.5rem !important; font-weight: 700; color: #0f172a !important; margin: 0;">Refund Applicant</h1>
                        <p class="text-secondary mt-1" style="color: #475569 !important;">Search applicants and process refunds</p>
                    </div>
                </div>

                <!-- Search Section -->
                <div class="bg-gray-50 rounded-lg p-6 border border-subtle mb-8" style="padding: 1.5rem; border-color: #e2e8f0 !important; margin-bottom: 2rem; margin-bottom: 2rem !important;">
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 items-end" style="gap: 2rem; /* Increased to 2rem for better spacing */;">

                        <div class="form-group">
                            <label class="form-label">Applicant Name</label>
                            <asp:TextBox ID="txtApplicantName" runat="server" CssClass="form-control"
                                placeholder="Enter Applicant Name"  style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;" />
                        </div>

                        <div class="form-group">
                            <label class="form-label">Start Date</label>
                            <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control" TextMode="Date"  style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;" />
                        </div>

                        <div class="form-group">
                            <label class="form-label">End Date</label>
                            <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control" TextMode="Date"  style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;" />
                        </div>
                    </div>

                    <div class="mt-6 flex justify-end pt-4 border-t border-gray-200" style="margin-top: 0.75rem; /* Heavily reduced */; justify-content: flex-end; justify-content: flex-end !important;">
                        <asp:Button ID="btnSearch" runat="server" Text="Search Applicants"
                            CssClass="btn btn-primary min-w-[200px]" OnClick="btnSearch_Click"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #2563eb, #3b82f6); color: white; box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2);" />
                    </div>
                </div>

                <!-- Results Grid -->
                <div class="table-container">
                    <asp:GridView ID="gvApplicants" runat="server" CssClass="table" AutoGenerateColumns="False"
                        GridLines="None" OnRowCommand="gvApplicants_RowCommand"
                        EmptyDataText="No refundable applicants found." style="width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left;">
                        <Columns>
                            <asp:BoundField DataField="ApplicantID" HeaderText="Applicant ID" ItemStyle-Width="120px" />
                            <asp:BoundField DataField="ApplicantName" HeaderText="Name" ItemStyle-Font-Bold="true" />
                            <asp:BoundField DataField="NIC" HeaderText="CNIC" />
                            <asp:BoundField DataField="MFee" HeaderText="Fee Amount" DataFormatString="Rs {0:N2}"
                                ItemStyle-CssClass="font-mono" />
                            <asp:BoundField DataField="Remarks" HeaderText="Remarks" />
                            <asp:TemplateField HeaderText="Action" ItemStyle-HorizontalAlign="Center"
                                ItemStyle-Width="100px">
                                <ItemTemplate>
                                    <asp:Button ID="btnRefund" runat="server" Text="Refund" CommandName="Refund"
                                        CommandArgument='<%# Eval("ApplicantID") %>'
                                        CssClass="btn btn-sm btn-success" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="p-8 text-center text-gray-500" style="padding: 2rem; text-align: center !important;">
                                <p>No records found matching your criteria.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

            </div>
        </div>

        <!-- Modal -->
        <asp:Panel ID="pnlRefundModal" runat="server"
            CssClass="fixed inset-0 bg-black bg-opacity-60 z-50 flex items-center justify-center p-4" style="align-items: center; justify-content: center; justify-content: center !important; padding: 1rem;">
            <div class="bg-white rounded-xl shadow-2xl w-full max-w-md p-6 transform transition-all scale-100" style="padding: 1.5rem;">
                <h3 class="text-xl font-bold text-primary-900 mb-6 border-b pb-3" style="font-weight: 700; color: #0f172a !important; margin-bottom: 1.5rem; border-bottom: 1px solid #e2e8f0;">Process Refund</h3>

                <div class="space-y-4">
                    <div class="bg-blue-50 p-4 rounded-lg border border-blue-100" style="padding: 1rem;">
                        <div class="flex justify-between mb-2" style="justify-content: space-between; margin-bottom: 0.5rem;">
                            <span class="text-sm text-gray-600" style="font-size: 0.875rem; line-height: 1.25rem;">Applicant:</span>
                            <asp:Label ID="lblApplicantName" runat="server" CssClass="font-bold text-primary-900"  style="font-weight: 700; color: #0f172a !important;" />
                        </div>
                        <div class="flex justify-between">
                            <span class="text-sm text-gray-600" style="font-size: 0.875rem; line-height: 1.25rem;">Fee Amount:</span>
                            <asp:Label ID="lblMFee" runat="server" CssClass="font-bold text-success-700"  style="font-weight: 700;" />
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Refund Remarks</label>
                        <asp:TextBox ID="txtRefundRemarks" runat="server" TextMode="MultiLine" Rows="3"
                            CssClass="form-control" placeholder="Enter reason for refund..." style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;"></asp:TextBox>
                    </div>
                </div>

                <div class="flex gap-3 mt-8" style="margin-top: 1rem; /* Heavily reduced */;">
                    <asp:Button ID="btnOkRefund" runat="server" Text="Confirm Refund" OnClick="btnOkRefund_Click"
                        CssClass="btn btn-success flex-1"  style="flex: 1;" />
                    <asp:Button ID="btnCancelRefund" runat="server" Text="Cancel"
                        OnClientClick="closeModal(); return false;" CssClass="btn btn-secondary flex-1"  style="background-color: white; color: #334155; border-color: #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); flex: 1;" />
                </div>
            </div>
        </asp:Panel>

        <script type="text/javascript">
            function showModal() {
                var modal = document.getElementById('<%= pnlRefundModal.ClientID %>');
                modal.style.display = 'flex'; // Use flex to center
            }
            function closeModal() {
                document.getElementById('<%= pnlRefundModal.ClientID %>').style.display = 'none';
            }
        </script>

    </asp:Content>











