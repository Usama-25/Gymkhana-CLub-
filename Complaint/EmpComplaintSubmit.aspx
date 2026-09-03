<%@ Page Language="C#" MasterPageFile="~/Complaint/Complaint.Master" AutoEventWireup="true" CodeFile="EmpComplaintSubmit.aspx.cs" Inherits="GymkhanaLibrary.Pages_EmpComplaintSubmit" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="cphBody" runat="server">
    <div style="margin: 0 0 24px 0; width: 100%;">
        <h2 style="font-family: 'Playfair Display', serif; font-size: 28px; font-weight: 700; color: #0f1e36; margin: 0;">File Interdepartmental Complaint</h2>
        <p style="color: #64748b; font-size: 14px; margin-top: 6px; margin-bottom: 0;">Log a formal complaint from your department targeting another club department or services.</p>
    </div>

    <!-- Alert Message Panel -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false" style="margin: 0 0 20px 0; width: 100%;">
        <div style='padding: 16px 24px; border-radius: 8px; font-size: 14px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; border-left: 4px solid; width: 100%; box-sizing: border-box; <%= AlertCssClass == "alert-success" ? "background-color: #d1fae5; color: #065f46; border-left-color: #10b981;" : "background-color: #fee2e2; color: #991b1b; border-left-color: #ef4444;" %>'>
            <span><%= AlertMessage %></span>
        </div>
    </asp:Panel>

    <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 32px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); box-sizing: border-box; width: 100%;">
        <!-- Sender Employee Selection -->
        <div style="margin-bottom: 20px; width: 100%;">
            <!-- Shown when session is active: locked read-only badge -->
            <asp:Panel ID="pnlSessionEmployee" runat="server" Visible="false" style="width: 100%;">
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Your Identity (Filing This Complaint)</label>
                <div style="display: inline-flex; align-items: center; gap: 10px; background: #f0f9ff; border: 1px solid #bae6fd; border-radius: 8px; padding: 12px 18px; width: 100%; box-sizing: border-box;">
                    <span style="font-size: 20px;">&#128274;</span>
                    <div>
                        <div style="font-size: 15px; font-weight: 700; color: #0f1e36;">
                            <asp:Literal ID="litEmployeeName" runat="server" />
                        </div>
                        <div style="font-size: 12px; color: #64748b; margin-top: 2px;">Logged-in session &middot; Auto-selected &middot; Cannot be changed</div>
                    </div>
                </div>
            </asp:Panel>

            <!-- Shown only when no session: allow manual selection -->
            <asp:Panel ID="pnlDropdownEmployee" runat="server" Visible="true" style="width: 100%;">
                <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Select Your Employee Identity *</label>
                <asp:DropDownList ID="ddlSenderEmployee" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 44px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
            </asp:Panel>
        </div>

        <!-- Target Subdepartment selection -->
        <div style="margin-bottom: 20px; width: 100%;">
            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Target Subdepartment *</label>
            <asp:DropDownList ID="ddlTargetDept" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 44px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" />
        </div>

        <!-- Subject -->
        <div style="margin-bottom: 20px; width: 100%;">
            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Complaint Subject *</label>
            <asp:TextBox ID="txtSubject" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 44px; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" placeholder="e.g. Broken lights or service delay in Cafe..." />
        </div>

        <!-- Complaint Details -->
        <div style="margin-bottom: 24px; width: 100%;">
            <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Detailed Complaint Description *</label>
            <asp:TextBox ID="txtDetail" runat="server" style="width: 100%; padding: 12px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; transition: border-color 0.2s ease;" onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';" TextMode="MultiLine" Rows="6" placeholder="Provide complete information, including details of issue or departments affected..." />
        </div>

        <!-- Submit Button -->
        <asp:Button ID="btnSubmit" runat="server" Text="Register Complaint" style="width: 100%; padding: 12px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 14px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 4px 10px rgba(197, 160, 89, 0.25); display: inline-block; height: 46px; text-align: center;" onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 6px 14px rgba(197, 160, 89, 0.35)';" onmouseout="this.style.transform='none'; this.style.boxShadow='0 4px 10px rgba(197, 160, 89, 0.25)';" OnClick="btnSubmit_Click" />
    </div>
</asp:Content>
