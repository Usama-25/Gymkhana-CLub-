<%@ Page Title="" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true"
    CodeFile="SearchMemberPayment.aspx.cs" Inherits="RefundFee.PaymentPlan" %>

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
            </asp:Content>
 
    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="page-wrapper mt-6" style="margin-top: 0.75rem; /* Heavily reduced */;">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); transition: none; /* Removed hover effect */ position: relative; overflow: hidden; height: 100%; /* Slightly reduced padding */;">

                <div class="flex items-center justify-between mb-8 pb-6 border-b border-subtle" style="align-items: center; justify-content: space-between; margin-bottom: 2rem; margin-bottom: 2rem !important; padding-bottom: 1.5rem !important; border-bottom: 1px solid #e2e8f0; border-color: #e2e8f0 !important;">
                    <div>
                        <h1 class="text-2xl font-bold text-primary-900 m-0" style="font-size: 1.5rem !important; font-weight: 700; color: #0f172a !important; margin: 0;">Search Member Payment</h1>
                        <p class="text-secondary mt-1" style="color: #475569 !important;">Verify member details and process payment plans</p>
                    </div>
                </div>

                <!-- Search Section -->
                <div class="bg-gray-50 rounded-lg p-6 border border-subtle mb-8" style="padding: 1.5rem; border-color: #e2e8f0 !important; margin-bottom: 2rem; margin-bottom: 2rem !important;">
                    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 items-end" style="gap: 2rem; /* Increased to 2rem for better spacing */;">


                        <div class="form-group">
                            <label class="form-label">Member No</label>
                            <asp:TextBox ID="txtMemberNo" runat="server" CssClass="form-control"
                                placeholder="Member No"  style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;" />
                        </div>

                        <div class="form-group">
                            <label class="form-label">Member Name</label>
                            <asp:TextBox ID="txtMemberName" runat="server" CssClass="form-control"
                                placeholder="Member Name"  style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;" />
                        </div>

                        <div class="form-group">
                            <label class="form-label">Department</label>
                            <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-control"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlDepartment_SelectedIndexChanged" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;">
                            </asp:DropDownList>
                            <asp:HiddenField ID="hfSelectedDept" runat="server" />
                            <asp:HiddenField ID="hfCardNo" runat="server" />
                        </div>
                    </div>

                    <div class="mt-6 flex justify-end pt-4 border-t border-gray-200" style="margin-top: 0.75rem; /* Heavily reduced */; justify-content: flex-end; justify-content: flex-end !important;">
                        <asp:Button ID="btnSearch" runat="server" Text="Search Records" OnClick="btnSearch_Click"
                            CssClass="btn btn-primary min-w-[200px]"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #2563eb, #3b82f6); color: white; box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2);" />
                    </div>
                </div>

                <!-- Results Grid -->
                <div class="table-container mb-6" style="margin-bottom: 1.5rem;">
                    <asp:GridView ID="gvSearchResults" runat="server" AutoGenerateColumns="False"
                        CssClass="table table-bordered table-hover" GridLines="None"
                        OnRowCommand="gvSearchResults_RowCommand" EmptyDataText="No records found." style="width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left;">
                        <Columns>
                            <asp:TemplateField HeaderText="Action" ItemStyle-Width="100px"
                                ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <asp:Button ID="btnProceed" runat="server" Text="Proceed" CommandName="Proceed"
                                        CommandArgument='<%# Eval("MemberNo") %>' CssClass="btn btn-sm btn-primary" />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="ApplicantName" HeaderText="Member Name"
                                ItemStyle-Font-Bold="true" />

                            <asp:BoundField DataField="IssueDate" HeaderText="Issue Date"
                                DataFormatString="{0:dd/MM/yyyy}" />
                            <asp:BoundField DataField="ExpiryDate" HeaderText="Expiry Date"
                                DataFormatString="{0:dd/MM/yyyy}" />
                            <asp:BoundField DataField="Area" HeaderText="Area" />
                            <asp:BoundField DataField="Amount" HeaderText="Amount" DataFormatString="Rs {0:N2}"
                                ItemStyle-CssClass="font-mono text-right" HeaderStyle-CssClass="text-right" />
                            <asp:BoundField DataField="Dept" HeaderText="Department" />
                            <asp:BoundField DataField="Credit" HeaderText="Credit" DataFormatString="Rs {0:N2}"
                                ItemStyle-CssClass="font-mono text-right" HeaderStyle-CssClass="text-right" />
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="p-8 text-center text-gray-500" style="padding: 2rem; text-align: center !important;">
                                <p>No member records found matching your criteria.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

                <!-- Advanced Options -->
                <div
                    class="flex flex-wrap gap-6 justify-center mt-6 p-4 bg-gray-50 rounded-lg border border-dashed border-gray-300" style="gap: 2rem; /* Increased to 2rem for better spacing */; justify-content: center; justify-content: center !important; margin-top: 0.75rem; /* Heavily reduced */; padding: 1rem;">
                    <asp:CheckBox ID="Card" runat="server" Text="Active Member Check" AutoPostBack="true"
                        OnCheckedChanged="CardActive" CssClass="form-checkbox text-primary-600" Visible="false" />

                    <asp:CheckBox ID="chkExpireIssueBetween" runat="server" Text="Check Expiry/Issue"
                        AutoPostBack="true" OnCheckedChanged="activeCard_Check"
                        CssClass="form-checkbox text-primary-600" Visible="false" />

                    <asp:CheckBox ID="chkCheckBalance" runat="server" Text="Check Balance" AutoPostBack="true"
                        OnCheckedChanged="Check_Balance" CssClass="form-checkbox text-primary-600" Visible="false" />

                    <asp:CheckBox ID="chkAllowDepartment" runat="server" Text="Allow Department"
                        CssClass="form-checkbox text-primary-600" AutoPostBack="true"
                        OnCheckedChanged="Cheack_departments" Visible="false" />
                </div>

            </div>
        </div>
    </asp:Content>
