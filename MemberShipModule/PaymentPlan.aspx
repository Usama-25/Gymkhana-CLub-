<%@ Page Title="card Payment Plan" Language="C#" MasterPageFile="~/MemberShipModule/Site.master" AutoEventWireup="true"
    CodeFile="PaymentPlan.aspx.cs" Inherits="RefundFee.PaymentPlan" %>

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
                <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

        <script>
            $(document).ready(function () {
                $('#<%= ddlArea.ClientID %>').select2({
                    placeholder: "Select Area",
                    allowClear: true,
                    width: '100%',
                    dropdownCssClass: 'custom-dropdown'
                });

                // Postback on selection change
                $('#<%= ddlArea.ClientID %>').change(function () {
                    __doPostBack('<%= ddlArea.UniqueID %>', '');
                });
            });
        </script>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="page-wrapper mt-6" style="margin-top: 0.75rem; /* Heavily reduced */;">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); transition: none; /* Removed hover effect */ position: relative; overflow: hidden; height: 100%; /* Slightly reduced padding */;">

                <div class="flex items-center justify-between mb-8 pb-6 border-b border-subtle" style="align-items: center; justify-content: space-between; margin-bottom: 2rem; margin-bottom: 2rem !important; padding-bottom: 1.5rem !important; border-bottom: 1px solid #e2e8f0; border-color: #e2e8f0 !important;">
                    <div>
                        <h1 class="text-2xl font-bold text-primary-900 m-0" style="font-size: 1.5rem !important; font-weight: 700; color: #0f172a !important; margin: 0;">Card Payment Plan</h1>
                        <p class="text-secondary mt-1" style="color: #475569 !important;">Configure payment intervals and amounts for areas</p>
                    </div>
                </div>

                <!-- Configuration Section -->
                <div class="bg-gray-50 rounded-lg p-6 border border-subtle mb-8" style="padding: 1.5rem; border-color: #e2e8f0 !important; margin-bottom: 2rem; margin-bottom: 2rem !important;">
                    <div class="form-group max-w-lg">
                        <label class="form-label">Select Allowed Area</label>
                        <asp:DropDownList ID="ddlArea" runat="server" CssClass="form-control" AutoPostBack="true"
                            OnSelectedIndexChanged="ddlArea_SelectedIndexChanged" SelectionMode="Multiple" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;">
                        </asp:DropDownList>
                    </div>
                </div>

                <!-- Input Grid -->
                <div class="table-container mb-8" style="margin-bottom: 2rem; margin-bottom: 2rem !important;">
                    <asp:GridView ID="gvPaymentPlan" runat="server" AutoGenerateColumns="False"
                        CssClass="table table-bordered table-hover" GridLines="None" style="width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left;">
                        <Columns>
                            <asp:BoundField HeaderText="Area" DataField="Area" ItemStyle-Font-Bold="true" />

                            <asp:TemplateField HeaderText="Payment Plan">
                                <ItemTemplate>
                                    <div class="py-1">
                                        <asp:RadioButtonList ID="rblPlan" runat="server" RepeatDirection="Horizontal"
                                            CssClass="radio-list-inline">
                                            <asp:ListItem Value="EveryVisit">Every Visit</asp:ListItem>
                                            <asp:ListItem Value="Weekly">Weekly</asp:ListItem>
                                            <asp:ListItem Value="Yearly">Yearly</asp:ListItem>
                                        </asp:RadioButtonList>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Amount">
                                <ItemTemplate>
                                    <div class="relative max-w-[150px]">
                                        <span class="absolute left-3 top-2 text-gray-500 font-bold" style="color: #64748b !important; font-weight: 700;">Rs.</span>
                                        <asp:TextBox ID="amountBox" runat="server" CssClass="form-control pl-10 h-9"
                                            placeholder="0"  style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;" />
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Active" ItemStyle-HorizontalAlign="Center"
                                ItemStyle-Width="100px">
                                <ItemTemplate>
                                    <div class="flex justify-center">
                                        <asp:CheckBox ID="chkSelect" runat="server"
                                            CssClass="form-checkbox h-5 w-5 text-primary-600" />
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="text-center p-4 text-gray-500" style="text-align: center !important; padding: 1rem;">Select an area above to configure plans.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

                <!-- Action Buttons -->
                <div class="flex items-center gap-4 mb-8" style="align-items: center; gap: 1rem; margin-bottom: 2rem; margin-bottom: 2rem !important;">
                    <asp:Button ID="btnSave" runat="server" Text="Save Configuration" OnClick="btnSave_Click"
                        CssClass="btn btn-primary min-w-[180px]"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #2563eb, #3b82f6); color: white; box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2);" />
                    <asp:Label ID="lblMessage" runat="server" CssClass="font-semibold" />
                </div>

                <!-- Existing Plans Grid -->
                <div class="mt-8 pt-8 border-t border-subtle" style="margin-top: 1rem; /* Heavily reduced */; border-color: #e2e8f0 !important;">
                    <h3 class="text-lg font-bold text-primary-900 mb-4" style="font-weight: 700; color: #0f172a !important; margin-bottom: 1rem;">Existing Configurations</h3>
                    <div class="table-container">
                        <asp:GridView ID="gvShowPlans" runat="server" AutoGenerateColumns="False" CssClass="table"
                            GridLines="None" EmptyDataText="No payment plans configured yet." style="width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left;">
                            <Columns>
                                <asp:TemplateField HeaderText="Area">
                                    <ItemTemplate>
                                        <span class="font-medium text-primary-900" style="color: #0f172a !important;">
                                            <%# Eval("Area") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Plan Type">
                                    <ItemTemplate>
                                        <span class="badge badge-gray">
                                            <%# Eval("PaymentPlan") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Amount">
                                    <ItemTemplate>
                                        <span class="font-mono">Rs. <%# Eval("Amount", "{0:N2}" ) %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="p-8 text-center text-gray-500" style="padding: 2rem; text-align: center !important;">
                                    <p>No existing configurations found.</p>
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>

            </div>
        </div>
    </asp:Content>











