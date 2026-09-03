<%@ page title="Application Tracking" language="C#" masterpagefile="~/MemberShipModule/Site.master" autoeventwireup="true"
    codefile="WorkingIList.aspx.cs" inherits="InterviewList.WorkingIList" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
        <style>
            /* Essential Styles (Self-contained for server deployments) */
            .table-container { background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
            .table { width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left; }
            .table th { background: #1A1A2E; color: #C9A84C; font-weight: 600; padding: 0.75rem 1rem; border-bottom: 2px solid #e0d5c5; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.05em; }
            .table td { padding: 0.75rem 1rem; border-bottom: 1px solid #e0d5c5; color: #1A1A2E; vertical-align: middle; }
            .table tr:last-child td { border-bottom: none; }
            .empty-state { padding: 2rem; text-align: center; color: #a09080; background-color: #faf7f2; border: 1px dashed #e0d5c5; border-radius: 12px; display: flex; flex-direction: column; align-items: center; gap: 0.75rem; margin-top: 1rem; }
            .empty-state svg { color: #a09080; opacity: 0.6; margin-bottom: 0.5rem; }
            .table-input { width: 100%; padding: 0.5rem 0.75rem; border: 1px solid transparent; border-radius: 6px; background: transparent; font-size: 0.95rem; color: #1A1A2E; transition: all 0.2s ease; }
            .table-input:hover { background: #F7F3EE; border-color: #e0d5c5; }
            .table-input:focus { background: #ffffff; border-color: #8B5E3C; box-shadow: 0 0 0 2px #f5ecd5; outline: none; }
            .form-control { display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; }
            .form-control:focus { border-color: #C9A84C; box-shadow: 0 0 0 3px rgba(201, 168, 76, 0.15); outline: none; }
            
            /* Button Styles */
            .btn { display: inline-block; text-align: center; vertical-align: middle; padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: all 0.15s ease; border: 1px solid transparent; line-height: 1; }
            .btn-primary { background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2); }
            .btn-primary:hover { box-shadow: 0 8px 12px rgba(201, 168, 76, 0.3); transform: translateY(-1px); }
            .btn-secondary { background-color: white; color: #1A1A2E; border-color: #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
            .btn-secondary:hover { background-color: #F7F3EE; border-color: #e0d5c5; color: #1A1A2E; }
            .btn-success { background-color: #10b981; color: white; border-color: #10b981; border: 1px solid #10b981; }
            .btn-danger { background-color: #ef4444; color: white; border-color: #ef4444; border: 1px solid #ef4444; }
            .btn-warning { background-color: #f59e0b; color: white; border-color: #f59e0b; border: 1px solid #f59e0b; }
            .btn-info { background-color: #8B5E3C; color: white; border-color: #8B5E3C; border: 1px solid #8B5E3C; }
            .btn-sm { padding: 0.4rem 0.8rem; font-size: 0.875rem; }
            .btn-sm.flex { display: inline-flex; align-items: center; justify-content: center; }

            /* Premium Grid Styles */
            .grid-header { text-transform: uppercase; font-size: 0.75rem !important; letter-spacing: 0.05em; border-bottom: 2px solid #e0d5c5 !important; }
            .grid-row { font-size: 0.9rem !important; border-bottom: 1px solid #F7F3EE !important; }
            .grid-row:hover { background-color: #faf7f2 !important; }
            .pl-1rem { padding-left: 1rem !important; }
            .pr-1rem { padding-right: 1.5rem !important; }
            .font-bold-navy { font-weight: 700 !important; color: #1A1A2E !important; }
            .font-mono-slate { font-family: monospace !important; color: #7a7a7a !important; }
            .font-mono-green { font-family: monospace !important; font-weight: 600 !important; color: #059669 !important; }
            .text-right { text-align: right !important; }
        </style>
            </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">
        <div class="page-wrapper mt-6" style="margin-top: 0.75rem; /* Heavily reduced */;">
            <div class="card" style="background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); transition: none; /* Removed hover effect */ position: relative; overflow: hidden; height: 100%; /* Slightly reduced padding */;">

                <div class="flex items-center justify-between mb-8 pb-6 border-b border-subtle" style="align-items: center; justify-content: space-between; margin-bottom: 2rem; margin-bottom: 2rem !important; padding-bottom: 1.5rem !important; border-bottom: 1px solid #e0d5c5; border-color: #e0d5c5 !important;">
                    <div>
                        <h1 class="text-2xl font-bold text-primary-900 m-0" style="font-size: 1.5rem !important; font-weight: 700; color: #1A1A2E !important; margin: 0;">Working Interview List</h1>
                        <p class="text-secondary mt-1" style="color: #8B5E3C !important;">Track and manage applicant interviews</p>
                    </div>
                </div>

                <!-- Filter Section -->
                <div style="background-color: #faf7f2; border: 1px solid #e0d5c5; border-radius: 12px; padding: 1.5rem; margin-bottom: 2rem;">
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; align-items: flex-end;">

                        <div class="form-group">
                            <label style="display: block; font-size: 0.85rem; font-weight: 600; color: #1A1A2E; margin-bottom: 0.5rem;">Form Type Main</label>
                            <asp:DropDownList ID="ddlFormTypeMain" runat="server" 
                                AutoPostBack="true" OnSelectedIndexChanged="ddlFormTypeMain_SelectedIndexChanged" 
                                style="display: block; width: 100%; padding: 0.5rem 0.75rem; font-size: 0.9rem; font-weight: 400; line-height: 1.4; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 6px; transition: all 0.2s;">
                            </asp:DropDownList>
                        </div>

                        <div class="form-group">
                            <label style="display: block; font-size: 0.85rem; font-weight: 600; color: #1A1A2E; margin-bottom: 0.5rem;">Membership Type</label>
                            <asp:DropDownList ID="ddlMembership" runat="server" 
                                AutoPostBack="true" OnSelectedIndexChanged="ddlMembership_SelectedIndexChanged" 
                                style="display: block; width: 100%; padding: 0.5rem 0.75rem; font-size: 0.9rem; font-weight: 400; line-height: 1.4; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 6px; transition: all 0.2s;">
                            </asp:DropDownList>
                        </div>

                        <div class="form-group">
                            <label style="display: block; font-size: 0.85rem; font-weight: 600; color: #1A1A2E; margin-bottom: 0.5rem;">Start Date</label>
                            <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" 
                                style="display: block; width: 100%; padding: 0.5rem 0.75rem; font-size: 0.9rem; font-weight: 400; line-height: 1.4; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 6px; transition: all 0.2s;" />
                        </div>

                        <div class="form-group">
                            <label style="display: block; font-size: 0.85rem; font-weight: 600; color: #1A1A2E; margin-bottom: 0.5rem;">End Date</label>
                            <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" 
                                style="display: block; width: 100%; padding: 0.5rem 0.75rem; font-size: 0.9rem; font-weight: 400; line-height: 1.4; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 6px; transition: all 0.2s;" />
                        </div>

                        <div class="form-group">
                            <asp:Button ID="btnFilter" runat="server" Text="Filter Records" OnClick="btnFilter_Click"
                                style="width: 100%; padding: 0.6rem 1.25rem; border-radius: 6px; font-weight: 600; font-size: 0.9rem; cursor: pointer; border: 1px solid transparent; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2); transition: all 0.2s;" />
                        </div>
                    </div>
                </div>

                <!-- Results Grid -->
                <div style="background-color: #ffffff; border-radius: 12px; border: 1px solid #e0d5c5; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 2rem;">
                    <asp:GridView ID="gvPendingInterviews" runat="server" AutoGenerateColumns="False" DataKeyNames="Id"
                        OnRowCommand="gvPendingInterviews_RowCommand" GridLines="None"
                        EmptyDataText="No pending interviews found." 
                        style="width: 100%; border-collapse: collapse; font-family: inherit;">
                        
                        <HeaderStyle BackColor="#faf7f2" Font-Bold="True" ForeColor="#8B5E3C" Height="48px" CssClass="grid-header" />
                        
                        <RowStyle Height="56px" ForeColor="#1e293b" CssClass="grid-row" />
                        
                        <AlternatingRowStyle BackColor="#fbfcfd" />

                        <Columns>
                            <asp:TemplateField HeaderText="Select">
                                <HeaderStyle Width="60px" HorizontalAlign="Center" />
                                <ItemStyle HorizontalAlign="Center" Width="60px" />
                                <ItemTemplate>
                                    <asp:CheckBox ID="chkSelect" runat="server"
                                        style="cursor: pointer; width: 18px; height: 18px; accent-color: #C9A84C;" />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="IName" HeaderText="Applicant Name">
                                <HeaderStyle CssClass="pl-1rem" />
                                <ItemStyle CssClass="pl-1rem font-bold-navy" />
                            </asp:BoundField>

                            <asp:BoundField DataField="FatherName" HeaderText="Father Name" />
                            
                            <asp:BoundField DataField="NIC" HeaderText="CNIC">
                                <ItemStyle CssClass="font-mono-slate" />
                            </asp:BoundField>

                            <asp:BoundField DataField="Membership" HeaderText="Type" />
                            
                            <asp:BoundField DataField="MFee" HeaderText="Fee" DataFormatString="PKR {0:N0}">
                                <HeaderStyle HorizontalAlign="Right" CssClass="pr-1rem" />
                                <ItemStyle HorizontalAlign="Right" CssClass="pr-1rem font-mono-green" />
                            </asp:BoundField>

                            <asp:BoundField DataField="Dated" HeaderText="Interview Date" DataFormatString="{0:yyyy-MM-dd}">
                                <ItemStyle ForeColor="#8B5E3C" />
                            </asp:BoundField>

                            <asp:BoundField DataField="InterviewerName" HeaderText="Interviewer" />

                            <asp:TemplateField HeaderText="Actions">
                                <HeaderStyle HorizontalAlign="Center" />
                                <ItemStyle Width="180px" HorizontalAlign="Center" />
                                <ItemTemplate>
                                    <div style="display: flex; gap: 0.5rem; justify-content: center; white-space: nowrap;">
                                        <asp:LinkButton ID="btnFinalize" runat="server" CommandName="Approve"
                                            CommandArgument='<%# Eval("Id") %>'
                                            ToolTip="Approve"
                                            style="display: inline-flex; align-items: center; justify-content: center; width: 32px; height: 32px; border-radius: 6px; background-color: #10b981; color: white; text-decoration: none; border: none; cursor: pointer; transition: all 0.2s;">
                                            <i class="fas fa-check"></i>
                                        </asp:LinkButton>

                                        <asp:LinkButton ID="btnPostpone" runat="server" CommandName="Postpone"
                                            CommandArgument='<%# Eval("Id") %>'
                                            ToolTip="Defer Application"
                                            style="display: inline-flex; align-items: center; justify-content: center; padding: 0 0.75rem; height: 32px; border-radius: 6px; background-color: #f59e0b; color: #1A1A2E; font-weight: 700; font-size: 0.75rem; text-decoration: none; border: none; cursor: pointer; transition: all 0.2s; box-shadow: 0 1px 2px rgba(0,0,0,0.1);">
                                            <i class="fas fa-clock" style="margin-right: 4px;"></i> DEFER
                                        </asp:LinkButton>

                                        <asp:LinkButton ID="btnReject" runat="server" CommandName="Reject"
                                            CommandArgument='<%# Eval("Id") %>'
                                            ToolTip="Reject"
                                            style="display: inline-flex; align-items: center; justify-content: center; width: 32px; height: 32px; border-radius: 6px; background-color: #ef4444; color: white; text-decoration: none; border: none; cursor: pointer; transition: all 0.2s;">
                                            <i class="fas fa-times"></i>
                                        </asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        
                        <EmptyDataTemplate>
                            <div style="padding: 4rem 2rem; text-align: center; color: #a09080;">
                                <i class="fas fa-search" style="font-size: 2.5rem; margin-bottom: 1rem; opacity: 0.5;"></i>
                                <p style="font-size: 1.1rem; font-weight: 500; margin: 0;">No pending interviews found.</p>
                                <p style="font-size: 0.9rem; margin-top: 0.5rem;">Try adjusting your filters to find what you're looking for.</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

                <!-- hidden Fields -->
                <div class="hidden">
                    <asp:HiddenField ID="hfRemarks" runat="server" />
                    <asp:HiddenField ID="hfActionType" runat="server" />
                    <asp:HiddenField ID="hfSelectedNIC" runat="server" />
                    <asp:HiddenField ID="hfDeferDate" runat="server" />
                    <asp:HiddenField ID="hfDeferYear" runat="server" />
                    <asp:Button ID="btnProcessAction" runat="server" OnClick="btnProcessAction_Click" />
                    <asp:Label ID="lblActionIndicator" runat="server" Text=""></asp:Label>
                </div>

            </div>
        </div>

        <!-- Remarks Modal -->
        <asp:Panel ID="pnlRemarks" runat="server" Visible="false" 
            style="position: fixed; top: 0; left: 0; right: 0; bottom: 0; background-color: rgba(0,0,0,0.6); z-index: 1000; display: flex; align-items: center; justify-content: center; padding: 1rem;">
            <div style="background-color: #ffffff; border-radius: 12px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04); width: 100%; max-width: 500px; padding: 1.5rem; transform: scale(1); transition: all 0.3s ease;">
                <h3 style="font-size: 1.25rem; font-weight: 700; color: #1A1A2E; margin-top: 0; margin-bottom: 1.5rem; padding-bottom: 0.75rem; border-bottom: 1px solid #e0d5c5;">
                    <asp:Label ID="lblPanelTitle" runat="server"></asp:Label>
                </h3>

                <div style="margin-bottom: 1.5rem;">
                    <label style="display: block; font-size: 0.85rem; font-weight: 600; color: #1A1A2E; margin-bottom: 0.5rem;">Remarks</label>
                    <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="5" placeholder="Enter remarks/reason here..." 
                        style="display: block; width: 100%; padding: 0.5rem 0.75rem; font-size: 0.9rem; font-weight: 400; line-height: 1.4; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 6px; transition: all 0.2s;">
                    </asp:TextBox>
                </div>

                <!-- Defer-only: Date Picker & Year Picker -->
                <asp:Panel ID="pnlDeferDateFields" runat="server" Visible="false">
                    <div style="display: flex; gap: 1rem; margin-bottom: 1.5rem;">
                        <div style="flex: 1;">
                            <label style="display: block; font-size: 0.85rem; font-weight: 600; color: #1A1A2E; margin-bottom: 0.4rem;">Deferred To Date</label>
                            <asp:TextBox ID="txtDeferDate" runat="server" TextMode="Date"
                                style="display: block; width: 100%; padding: 0.5rem 0.75rem; font-size: 0.9rem; font-weight: 400; line-height: 1.4; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 6px; transition: all 0.2s;" />
                        </div>
                        <div style="flex: 1;">
                            <label style="display: block; font-size: 0.85rem; font-weight: 600; color: #1A1A2E; margin-bottom: 0.4rem;">Deferred To Year</label>
                            <asp:DropDownList ID="ddlDeferYear" runat="server"
                                style="display: block; width: 100%; padding: 0.5rem 0.75rem; font-size: 0.9rem; font-weight: 400; line-height: 1.4; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 6px; transition: all 0.2s;">
                            </asp:DropDownList>
                        </div>
                    </div>
                </asp:Panel>

                <div style="display: flex; justify-content: flex-end; gap: 0.75rem;">
                    <asp:Button ID="btnCancelAction" runat="server" Text="Cancel" OnClick="btnCancelAction_Click"  
                        style="padding: 0.6rem 1.25rem; border-radius: 6px; font-weight: 600; font-size: 0.9rem; cursor: pointer; background-color: #ffffff; color: #1A1A2E; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px rgba(0,0,0,0.05); transition: all 0.2s;" />

                    <asp:Button ID="btnConfirmAction" runat="server" Text="Confirm" OnClick="btnConfirmAction_Click"  
                        style="padding: 0.6rem 1.25rem; border-radius: 6px; font-weight: 600; font-size: 0.9rem; cursor: pointer; border: 1px solid transparent; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2); transition: all 0.2s;" />
                </div>
            </div>
        </asp:Panel>

    </asp:Content>