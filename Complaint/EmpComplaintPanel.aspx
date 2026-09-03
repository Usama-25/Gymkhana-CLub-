<%@ Page Language="C#" MasterPageFile="~/Complaint/Complaint.Master" AutoEventWireup="true" CodeFile="EmpComplaintPanel.aspx.cs" Inherits="GymkhanaLibrary.Pages_EmpComplaintPanel" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphBody" runat="server">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; width: 100%;">
        <div>
            <h2 style="font-family: 'Playfair Display', serif; font-size: 28px; font-weight: 700; color: #0f1e36; margin: 0;">Interdepartmental Review Panel</h2>
            <p style="color: #64748b; font-size: 14px; margin-top: 6px; margin-bottom: 0;">Manage, review, track and resolve departmental complaints logged between departments.</p>
        </div>
    </div>

    <!-- Alert Message Panel -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false" style="width: 100%; margin-bottom: 20px;">
        <div style='padding: 16px 24px; border-radius: 8px; font-size: 14px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; border-left: 4px solid; width: 100%; box-sizing: border-box; <%= AlertCssClass == "alert-success" ? "background-color: #d1fae5; color: #065f46; border-left-color: #10b981;" : "background-color: #fee2e2; color: #991b1b; border-left-color: #ef4444;" %>'>
            <span><%= AlertMessage %></span>
        </div>
    </asp:Panel>

    <!-- Filters Section -->
    <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); width: 100%; box-sizing: border-box;">
        <h3 style="font-family: 'Playfair Display', serif; font-size: 16px; color: #0f1e36; margin-top: 0; margin-bottom: 16px;">Search & Filter Departmental Complaints</h3>
        
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 16px; align-items: end;">
            <div>
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Sender Department</label>
                <asp:DropDownList ID="ddlSenderDeptFilter" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
            </div>

            <div>
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Target Department</label>
                <asp:DropDownList ID="ddlTargetDeptFilter" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
            </div>

            <div>
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Status</label>
                <asp:DropDownList ID="ddlStatusFilter" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';">
                    <asp:ListItem Text="- All Statuses -" Value="" />
                    <asp:ListItem Text="Pending" Value="Pending" />
                    <asp:ListItem Text="In Progress" Value="In Progress" />
                    <asp:ListItem Text="Resolved" Value="Resolved" />
                    <asp:ListItem Text="Closed" Value="Closed" />
                </asp:DropDownList>
            </div>

            <div>
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">From Date</label>
                <asp:TextBox ID="txtFromDate" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" TextMode="Date" />
            </div>

            <div>
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">To Date</label>
                <asp:TextBox ID="txtToDate" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" TextMode="Date" />
            </div>

            <div style="display: flex; gap: 8px; height: 42px;">
                <asp:Button ID="btnSearch" runat="server" Text="Filter" style="flex: 1; padding: 10px 20px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); height: 42px;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';" OnClick="btnSearch_Click" />
                <asp:Button ID="btnReset" runat="server" Text="Reset" style="padding: 10px 20px; border-radius: 8px; border: 1px solid #cbd5e1; cursor: pointer; font-size: 13px; font-weight: 600; background-color: #ffffff; color: #64748b; transition: all 0.2s ease; height: 42px;" onmouseover="this.style.backgroundColor='#f1f5f9'; this.style.color='#1e293b';" onmouseout="this.style.backgroundColor='#ffffff'; this.style.color='#64748b';" OnClick="btnReset_Click" />
            </div>
        </div>
    </div>

    <!-- Complaints Grid Section -->
    <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); width: 100%; box-sizing: border-box;">
        <div style="width: 100%; overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 8px; background-color: #ffffff; -webkit-overflow-scrolling: touch;">
            <asp:GridView ID="gvComplaints" runat="server" AutoGenerateColumns="false" GridLines="None"
                OnRowCommand="gvComplaints_RowCommand"
                style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;">
                <HeaderStyle CssClass="gv-header" />
                <RowStyle CssClass="gv-row" />
                <AlternatingRowStyle CssClass="gv-alt-row" />
                <Columns>
                    <asp:BoundField DataField="EmpComplaintID" HeaderText="ID">
                        <HeaderStyle CssClass="gv-header-left" Width="60px" />
                        <ItemStyle CssClass="gv-text-left" Width="60px" />
                    </asp:BoundField>
                    
                    <asp:TemplateField HeaderText="Date Submitted">
                        <HeaderStyle CssClass="gv-header-left" Width="140px" />
                        <ItemStyle CssClass="gv-text-left" Width="140px" />
                        <ItemTemplate>
                            <%# Convert.ToDateTime(Eval("CreatedDate")).ToString("dd-MMM-yyyy hh:mm tt") %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Sender Employee">
                        <HeaderStyle CssClass="gv-header-left" />
                        <ItemStyle CssClass="gv-text-left" />
                        <ItemTemplate>
                            <div style="font-weight: 600; color: #0f1e36;"><%# Eval("SenderEmployeeName") %></div>
                            <div style="font-size: 12px; color: #64748b; margin-top: 2px;">Dept: <%# Eval("SenderDepartmentName") %></div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Target Department">
                        <HeaderStyle CssClass="gv-header-left" />
                        <ItemStyle CssClass="gv-text-left" />
                        <ItemTemplate>
                            <div style="font-weight: 600; color: #0f1e36;"><%# Eval("TargetDepartmentName") %></div>
                            <div style="font-size: 12px; color: #64748b; margin-top: 2px;">
                                <%# Eval("TargetSubDepartmentName") != DBNull.Value && !string.IsNullOrEmpty(Eval("TargetSubDepartmentName").ToString()) ? "&nbsp;&nbsp;&rdsh; " + Eval("TargetSubDepartmentName") : "Entire Dept" %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Subject & Detail">
                        <HeaderStyle CssClass="gv-header-left" />
                        <ItemStyle CssClass="gv-text-left" />
                        <ItemTemplate>
                            <div style="font-weight: 600; color: #0f1e36;"><%# Eval("Subject") %></div>
                            <div style="font-size: 13px; color: #475569; margin-top: 4px; max-width: 320px; white-space: normal; word-break: break-all;">
                                <%# Eval("Detail") %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Status">
                        <HeaderStyle CssClass="gv-header-left" Width="100px" />
                        <ItemStyle CssClass="gv-text-left" Width="100px" />
                        <ItemTemplate>
                            <span style='display: inline-block; padding: 4px 8px; border-radius: 9999px; font-size: 11px; font-weight: 600; text-transform: uppercase; <%# Eval("Status").ToString() == "Pending" ? "background-color: #fee2e2; color: #991b1b;" : (Eval("Status").ToString() == "In Progress" ? "background-color: #fef3c7; color: #92400e;" : (Eval("Status").ToString() == "Resolved" ? "background-color: #d1fae5; color: #065f46;" : "background-color: #f1f5f9; color: #475569;")) %>'>
                                <%# Eval("Status") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Actions">
                        <HeaderStyle CssClass="gv-header-left" Width="150px" />
                        <ItemStyle CssClass="gv-text-left" Width="150px" />
                        <ItemTemplate>
                            <asp:LinkButton ID="lnkAction" runat="server" CommandName="ManageComplaint" CommandArgument='<%# Eval("EmpComplaintID") %>' style="text-decoration: none; font-size: 13px; font-weight: 600; color: #c5a059;">Manage & Action</asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <div style="padding: 30px; text-align: center; color: #64748b;">No departmental complaints found matching filters.</div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>

    <!-- Complaint Action Modal Overlay (Visible on Row Command) -->
    <asp:Panel ID="pnlAction" runat="server" Visible="false" style="position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background-color: rgba(15, 30, 54, 0.6); backdrop-filter: blur(4px); z-index: 99999; display: flex; align-items: center; justify-content: center; padding: 20px; box-sizing: border-box;">
        <div style="background: #ffffff; border-radius: 16px; width: 100%; max-width: 650px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); overflow: hidden; display: flex; flex-direction: column; max-height: 90vh; font-family: 'Outfit', sans-serif;">
            <!-- Modal Header -->
            <div style="padding: 20px 24px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; display: flex; justify-content: space-between; align-items: center;">
                <div style="display: flex; align-items: center; gap: 10px;">
                    <div style="width: 32px; height: 32px; border-radius: 50%; background: rgba(197, 160, 89, 0.2); display: flex; align-items: center; justify-content: center; color: #c5a059; font-size: 14px;">
                        <i class="fas fa-tasks"></i>
                    </div>
                    <h3 style="font-family: 'Playfair Display', serif; font-size: 18px; font-weight: 700; color: #ffffff; margin: 0;">Manage Departmental Complaint</h3>
                </div>
                <asp:LinkButton ID="btnCloseModalX" runat="server" OnClick="btnCancelAction_Click" style="color: rgba(255,255,255,0.7); font-size: 18px; text-decoration: none; transition: color 0.2s ease;" onmouseover="this.style.color='#ffffff';" onmouseout="this.style.color='rgba(255,255,255,0.7)';">
                    <i class="fas fa-times"></i>
                </asp:LinkButton>
            </div>

            <!-- Modal Body -->
            <div style="padding: 24px; overflow-y: auto; flex: 1;">
                <asp:HiddenField ID="hfEmpComplaintID" runat="server" />

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 20px; background-color: #f8fafc; padding: 16px; border-radius: 10px; border: 1px solid #e2e8f0;">
                    <div>
                        <p style="margin: 0 0 4px 0; font-size: 11px; color: #64748b; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Complaint Subject</p>
                        <p style="margin: 0; font-size: 14.5px; font-weight: 700; color: #0f1e36;"><asp:Literal ID="litCompSubject" runat="server" /></p>
                    </div>
                    <div>
                        <p style="margin: 0 0 4px 0; font-size: 11px; color: #64748b; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Sender Employee</p>
                        <p style="margin: 0; font-size: 13.5px; font-weight: 600; color: #334155;"><asp:Literal ID="litCompSender" runat="server" /></p>
                    </div>
                </div>

                <div style="margin-bottom: 20px;">
                    <p style="margin: 0 0 6px 0; font-size: 11px; color: #64748b; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">Complaint Detail</p>
                    <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 14px; font-size: 13.5px; color: #334155; line-height: 1.5; white-space: pre-wrap; word-break: break-word;">
                        <asp:Literal ID="litCompDetail" runat="server" />
                    </div>
                </div>

                <div style="margin-bottom: 20px;">
                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Update Status <span style="color: #ef4444;">*</span></label>
                    <asp:DropDownList ID="ddlUpdateStatus" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; font-family: 'Outfit', sans-serif; outline: none; background-color: #ffffff; color: #1e293b; height: 42px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';">
                        <asp:ListItem Text="Pending" Value="Pending" />
                        <asp:ListItem Text="In Progress" Value="In Progress" />
                        <asp:ListItem Text="Resolved" Value="Resolved" />
                    </asp:DropDownList>
                </div>

                <div>
                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Action / Investigation Remarks <span style="color: #ef4444;">*</span></label>
                    <asp:TextBox ID="txtRemarks" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; font-family: 'Outfit', sans-serif; outline: none; background-color: #ffffff; color: #1e293b; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" TextMode="MultiLine" Rows="3" placeholder="Describe actions taken, resolutions, or details of the investigation..." />
                </div>
            </div>

            <!-- Modal Footer -->
            <div style="padding: 16px 24px; background-color: #f8fafc; border-top: 1px solid #e2e8f0; display: flex; gap: 12px; justify-content: flex-end;">
                <asp:Button ID="btnCancelAction" runat="server" Text="Cancel" style="padding: 10px 20px; border-radius: 8px; border: 1px solid #cbd5e1; cursor: pointer; font-size: 13px; font-family: 'Outfit', sans-serif; font-weight: 600; background-color: #ffffff; color: #64748b; transition: all 0.2s ease; height: 42px;" onmouseover="this.style.backgroundColor='#f1f5f9'; this.style.color='#1e293b';" onmouseout="this.style.backgroundColor='#ffffff'; this.style.color='#64748b';" OnClick="btnCancelAction_Click" />
                <asp:Button ID="btnSaveStatus" runat="server" Text="Save Status Update" style="padding: 10px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-family: 'Outfit', sans-serif; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); height: 42px;" OnClick="btnSaveStatus_Click" />
            </div>
        </div>
    </asp:Panel>
</asp:Content>
