<%@ Page Title="Application Tracking" Language="C#" MasterPageFile="~/MemberShipModule/Site.master"
    AutoEventWireup="true" CodeFile="ApplicantSearchAdmin.aspx.cs"
    Inherits="Form_cell.Applicant_Form.ApplicantSearchAdmin" %>
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



    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">

        <script type="text/javascript">
            function allowOnlyNumbers(evt) {
                var charCode = (evt.which) ? evt.which : evt.keyCode;
                if (charCode > 31 && (charCode < 48 || charCode > 57) && charCode !== 45) { // 45 is hyphen
                    return false;
                }
                return true;
            }
        </script>

        <div class="page-wrapper mt-6" style="margin-top: 0.75rem; /* Heavily reduced */;">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e2e8f0; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); transition: none; /* Removed hover effect */ position: relative; overflow: hidden; height: 100%; /* Slightly reduced padding */;">

                <div class="flex items-center justify-between mb-8 pb-6 border-b border-subtle" style="align-items: center; justify-content: space-between; margin-bottom: 2rem; margin-bottom: 2rem !important; padding-bottom: 1.5rem !important; border-bottom: 1px solid #e2e8f0; border-color: #e2e8f0 !important;">
                    <div>
                        <h1 class="text-2xl font-bold text-primary-900 m-0" style="font-size: 1.5rem !important; font-weight: 700; color: #0f172a !important; margin: 0;">Applicant Search (Admin)</h1>
                        <p class="text-secondary mt-1" style="color: #475569 !important;">Manage and proceed with applicant forms</p>
                    </div>
                </div>

                <div class="form-grid mb-8" style="width: 100%; margin-bottom: 2rem; margin-bottom: 2rem !important;">
                    <!-- Search Form -->
                    <div class="form-section" style="padding: 1rem; margin-bottom: 1rem;">
                        <div class="section-header" style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem; padding-bottom: 0.75rem; border-bottom: 1px solid #e2e8f0; padding-bottom: 0.5rem;">
                            <div class="section-icon" style="width: 40px; height: 40px; background: transparent; color: #2563eb; display: flex; align-items: center; justify-content: center;">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2">
                                    <path d="M12 20h9"></path>
                                    <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path>
                                </svg>
                            </div>
                            <div>
                                <h2 class="section-title" style="font-size: 1.15rem; font-weight: 700; margin: 0; color: #0f172a;">Search Criteria</h2>
                                <p class="section-subtitle" style="font-size: 0.875rem; color: #475569; margin: 0;">Locate forms by number, name, or CNIC</p>
                            </div>
                        </div>

                        <div class="grid-3 gap-6" style="grid-template-columns: 1fr; /* Stack everything */; display: grid; gap: 1.5rem; grid-template-columns: repeat(3, 1fr); gap: 2rem; /* Increased to 2rem for better spacing */;">


                            <div class="form-group">
                                <label for="txtPurchaseBy">Purchaser Name</label>
                                <asp:TextBox ID="txtPurchaseBy" runat="server" CssClass="form-control"
                                    placeholder="Enter Purchaser Name" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;">
                                </asp:TextBox>
                            </div>

                            <div class="form-group">
                                <label for="TxtIdCArd">CNIC No</label>
                                <asp:TextBox ID="TxtIdCArd" runat="server" CssClass="form-control"
                                    placeholder="12345-1234567-1" MaxLength="15"
                                    onkeypress="return allowOnlyNumbers(event);"
                                    oninput="this.value=this.value.replace(/[^0-9-]/g,'');" style="display: block; width: 100%; padding: 0.35rem 0.5rem; /* Make input boxes much thinner */ font-size: 0.9rem; font-weight: 400; line-height: 1.2; /* Tighter line height inside the box */ color: #0f172a; background-color: white; background-clip: padding-box; border: 1px solid #cbd5e1; border-radius: 6px; transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;">
                                </asp:TextBox>
                            </div>
                        </div>

                        <div class="flex justify-end mt-6" style="justify-content: flex-end; justify-content: flex-end !important; margin-top: 0.75rem; /* Heavily reduced */;">
                            <asp:Button ID="btnSearch" runat="server" Text="Search Records" CssClass="btn btn-primary"
                                OnClick="btnSearch_Click"  style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #2563eb, #3b82f6); color: white; box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2);" />
                        </div>

                        <asp:Label ID="lblResult" runat="server" CssClass="status-message block mt-4 text-center" style="display: block !important; margin-top: 0.5rem; /* Heavily reduced */;">
                        </asp:Label>
                    </div>
                </div>

                <!-- Results Grid -->
                <div class="form-section" style="padding: 1rem; margin-bottom: 1rem;">
                    <div class="section-header" style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem; padding-bottom: 0.75rem; border-bottom: 1px solid #e2e8f0; padding-bottom: 0.5rem;">
                        <div class="section-icon" style="width: 40px; height: 40px; background: transparent; color: #2563eb; display: flex; align-items: center; justify-content: center;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2">
                                <line x1="8" y1="6" x2="21" y2="6"></line>
                                <line x1="8" y1="12" x2="21" y2="12"></line>
                                <line x1="8" y1="18" x2="21" y2="18"></line>
                                <line x1="3" y1="6" x2="3.01" y2="6"></line>
                                <line x1="3" y1="12" x2="3.01" y2="12"></line>
                                <line x1="3" y1="18" x2="3.01" y2="18"></line>
                            </svg>
                        </div>
                        <div>
                            <h2 class="section-title" style="font-size: 1.15rem; font-weight: 700; margin: 0; color: #0f172a;">Search Results</h2>
                            <p class="section-subtitle" style="font-size: 0.875rem; color: #475569; margin: 0;">Found applicants matching criteria</p>
                        </div>
                    </div>

                    <div class="table-container">
                        <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" Visible="false"
                            CssClass="table" GridLines="None" OnRowCommand="GridView1_RowCommand" style="width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left;">

                            <Columns>
                                <asp:BoundField DataField="Id" HeaderText="ID" />

                                <asp:BoundField DataField="PurchaseBy" HeaderText="Purchase By" />
                                <asp:BoundField DataField="PhoneNo" HeaderText="Phone No" />
                                <asp:BoundField DataField="Price" HeaderText="Price" DataFormatString="PKR {0:N0}" />
                                <asp:BoundField DataField="Status" HeaderText="Status" />

                                <asp:TemplateField HeaderText="Actions">
                                    <ItemTemplate>
                                        <div class="flex gap-2 justify-center" style="gap: 0.5rem;">
                                            <asp:Button ID="btnRecive" runat="server" Text="Proceed"
                                                CommandName="Receive" CommandArgument='<%# Eval("id") %>'
                                                OnClick="Recived_Click" CssClass="btn btn-primary btn-sm" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #2563eb, #3b82f6); color: white; box-shadow: 0 4px 6px rgba(37, 99, 235, 0.2);" />

                                            <asp:Button ID="btnAdd" runat="server" Text="Receive Payment"
                                                CommandName="Add" CommandArgument='<%# Eval("Id") %>' OnClick="Addbtn"
                                                Visible="false" CssClass="btn btn-secondary btn-sm" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid #e2e8f0; background-color: white; color: #334155; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);" />
                                        </div>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" Width="250px" />
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <tr>
                                    <td colspan="6">
                                        <div class="empty-state">
                                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none"
                                                stroke="currentColor" stroke-width="2">
                                                <circle cx="11" cy="11" r="8"></circle>
                                                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                                            </svg>
                                            <p>No applicants found matching your criteria</p>
                                        </div>
                                    </td>
                                </tr>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>

                    <asp:Label ID="lblMessage" runat="server" CssClass="status-message block mt-4 text-center" style="display: block !important; margin-top: 0.5rem; /* Heavily reduced */;">
                    </asp:Label>
                </div>
            </div>
        </div>
    </asp:Content>










