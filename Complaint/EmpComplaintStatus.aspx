<%@ Page Language="C#" MasterPageFile="~/Complaint/Complaint.Master" AutoEventWireup="true" CodeFile="EmpComplaintStatus.aspx.cs" Inherits="GymkhanaLibrary.Pages_EmpComplaintStatus" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        .premium-card {
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05), 0 2px 4px -1px rgba(0,0,0,0.02);
            border: 1px solid #e2e8f0;
            padding: 24px;
            margin-bottom: 24px;
        }
        .form-label {
            font-size: 13px;
            font-weight: 600;
            color: #475569;
            margin-bottom: 6px;
            display: block;
        }
        .form-control {
            width: 100%;
            max-width: 400px;
            padding: 10px 14px;
            background-color: #f8fafc;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 14px;
            color: #1e293b;
            outline: none;
            transition: all 0.2s ease;
            box-sizing: border-box;
        }
        .form-control:focus {
            background-color: #ffffff;
            border-color: #c5a059;
            box-shadow: 0 0 0 3px rgba(197, 160, 89, 0.15);
        }
        .grid-premium {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            margin-top: 15px;
        }
        .grid-premium th {
            background-color: #f8fafc;
            color: #475569;
            font-weight: 600;
            font-size: 13px;
            padding: 14px 16px;
            border-bottom: 2px solid #e2e8f0;
            text-align: left;
        }
        .grid-premium td {
            padding: 14px 16px;
            border-bottom: 1px solid #edf2f7;
            color: #334155;
            font-size: 14px;
            vertical-align: top;
        }
        .grid-premium tr:hover td {
            background-color: #f8fafc;
        }
        .status-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 9999px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
        }
        .status-pending {
            background-color: #fee2e2;
            color: #991b1b;
        }
        .status-inprogress {
            background-color: #fef3c7;
            color: #92400e;
        }
        .status-resolved {
            background-color: #d1fae5;
            color: #065f46;
        }
        .status-closed {
            background-color: #f1f5f9;
            color: #475569;
        }
        .btn-reminder {
            background-color: #fffbeb;
            color: #b45309;
            border: 1px solid #fde68a;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s ease;
            display: inline-block;
        }
        .btn-reminder:hover {
            background-color: #fef3c7;
            border-color: #fcd34d;
        }
        .btn-close-complaint {
            background-color: #ecfdf5;
            color: #047857;
            border: 1px solid #a7f3d0;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s ease;
            display: inline-block;
        }
        .btn-close-complaint:hover {
            background-color: #d1fae5;
            border-color: #6ee7b7;
            color: #065f46;
        }
        .alert-box {
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 14px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .alert-success {
            background-color: #ecfdf5;
            color: #065f46;
            border: 1px solid #a7f3d0;
        }
        .alert-error {
            background-color: #fef2f2;
            color: #991b1b;
            border: 1px solid #fca5a5;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphBody" runat="server">
    <div style="margin-bottom: 24px;">
        <h2 style="font-family: 'Playfair Display', serif; font-size: 28px; font-weight: 700; color: #0f1e36; margin: 0;">My Interdepartmental Complaints</h2>
        <p style="color: #64748b; font-size: 14px; margin-top: 6px; margin-bottom: 0;">Track the status of complaints you logged against other departments and send reminders if unresolved.</p>
    </div>

    <!-- Alert Message Panel -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false">
        <div class='alert-box <%= AlertCssClass %>'>
            <span><%= AlertMessage %></span>
        </div>
    </asp:Panel>

    <!-- Identity Selection -->
    <div class="premium-card" id="divIdentityCard" runat="server">
        <!-- Shown when session is active: locked read-only display -->
        <asp:Panel ID="pnlSessionEmployee" runat="server" Visible="false">
            <label class="form-label">Viewing Complaints As</label>
            <div style="display: flex; align-items: center; gap: 10px; margin-top: 4px;">
                <div style="display: inline-flex; align-items: center; gap: 8px; background: #f0f9ff; border: 1px solid #bae6fd; border-radius: 8px; padding: 10px 16px;">
                    <div>
                        <div style="font-size: 15px; font-weight: 700; color: #0f1e36;">
                            <asp:Literal ID="litEmployeeName" runat="server" />
                        </div>
                        <div style="font-size: 12px; color: #64748b; margin-top: 2px;">Logged-in session &middot; Auto-selected</div>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <!-- Shown only when no session: allow manual selection -->
        <asp:Panel ID="pnlDropdownEmployee" runat="server" Visible="true">
            <label class="form-label">Select Your Employee Identity *</label>
            <asp:DropDownList ID="ddlSenderEmployee" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlSenderEmployee_SelectedIndexChanged" />
        </asp:Panel>
    </div>

    <!-- Complaints Grid -->
    <div class="premium-card">
        <asp:GridView ID="gvComplaints" runat="server" AutoGenerateColumns="false" CssClass="grid-premium" GridLines="None" OnRowCommand="gvComplaints_RowCommand">
            <Columns>
                <asp:BoundField DataField="EmpComplaintID" HeaderText="ID" ItemStyle-Width="60px" />
                
                <asp:TemplateField HeaderText="Date Submitted" ItemStyle-Width="140px">
                    <ItemTemplate>
                        <%# Convert.ToDateTime(Eval("CreatedDate")).ToString("dd-MMM-yyyy hh:mm tt") %>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Target Department">
                    <ItemTemplate>
                        <div style="font-weight: 600;"><%# Eval("TargetDepartmentName") %></div>
                        <div style="font-size: 12px; color: #64748b; margin-top: 2px;">
                            <%# Eval("TargetSubDepartmentName") != DBNull.Value && !string.IsNullOrEmpty(Eval("TargetSubDepartmentName").ToString()) ? "&nbsp;&nbsp;&rdsh; " + Eval("TargetSubDepartmentName") : "Entire Dept" %>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Subject & Details">
                    <ItemTemplate>
                        <div style="font-weight: 600; color: #0f1e36;"><%# Eval("Subject") %></div>
                        <div style="font-size: 13px; color: #475569; margin-top: 4px; max-width: 350px; white-space: normal; word-break: break-all;">
                            <%# Eval("Detail") %>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Status" ItemStyle-Width="110px">
                    <ItemTemplate>
                        <span class='status-badge <%# "status-" + Eval("Status").ToString().Replace(" ", "").ToLower() %>'>
                            <%# Eval("Status") %>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Action Taken / Remarks">
                    <ItemTemplate>
                        <div style="font-size: 13px; color: #334155; font-style: italic; max-width: 250px; white-space: normal;">
                            <%# Eval("Remarks") != DBNull.Value && !string.IsNullOrEmpty(Eval("Remarks").ToString()) ? Eval("Remarks") : "<span style='color: #94a3b8;'>No remarks yet</span>" %>
                        </div>
                        <div style="font-size: 11px; color: #64748b; margin-top: 4px;">
                            <%# Eval("UpdatedDate") != DBNull.Value ? "Updated: " + Convert.ToDateTime(Eval("UpdatedDate")).ToString("dd-MMM-yyyy") : "" %>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Reminders" ItemStyle-Width="140px">
                    <ItemTemplate>
                        <div>Sent: <span style="font-weight: 600; color: #b45309;"><%# Eval("ReminderCount") %></span></div>
                        <div style="font-size: 11px; color: #64748b; margin-top: 2px;">
                            <%# Eval("LastReminderDate") != DBNull.Value ? "Last: " + Convert.ToDateTime(Eval("LastReminderDate")).ToString("dd-MMM hh:mm tt") : "" %>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Actions" ItemStyle-Width="140px">
                    <ItemTemplate>
                        <div style="display: flex; flex-direction: column; gap: 4px; align-items: flex-start;">
                            <asp:LinkButton ID="btnReminder" runat="server" CommandName="SendReminder" CommandArgument='<%# Eval("EmpComplaintID") %>' CssClass="btn-reminder" Visible='<%# Eval("Status").ToString() == "Pending" %>'>Send Reminder</asp:LinkButton>
                            <asp:LinkButton ID="btnCloseComplaint" runat="server" CommandName="CloseComplaint" CommandArgument='<%# Eval("EmpComplaintID") %>' CssClass="btn-close-complaint" Visible='<%# Eval("Status").ToString() != "Closed" %>' OnClientClick="return confirm('Are you sure you want to mark this complaint as Closed?');">Close Complaint</asp:LinkButton>
                            <span style="font-size: 12px; color: #10b981; font-weight: 600;" runat="server" visible='<%# Eval("Status").ToString() == "Closed" %>'>
                                &#10004; Closed
                            </span>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
            <EmptyDataTemplate>
                <div style="padding: 30px; text-align: center; color: #64748b;">No complaints logged yet.</div>
            </EmptyDataTemplate>
        </asp:GridView>
    </div>
</asp:Content>
