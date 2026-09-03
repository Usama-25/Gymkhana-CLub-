<%@ Page Title="Extension Approval" Language="C#" MasterPageFile="SiteGuestroom.master"
    AutoEventWireup="true" CodeFile="ExtensionApproval.aspx.cs"
    Inherits="GuestRoomApp.GuestRoomM.ExtensionApproval" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .form-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px; background: linear-gradient(90deg, #C9A84C, #8B5E3C); border-radius: 10px 10px 0 0; }
    .btn-action { transition: all 0.2s; cursor: pointer; }
    .btn-action:hover { transform: scale(1.05); }
    .btn-approve { background: #2e7d32; color: white; border: none; padding: 5px 12px; border-radius: 4px; font-size: 0.8rem; }
    .btn-reject { background: #c62828; color: white; border: none; padding: 5px 12px; border-radius: 4px; font-size: 0.8rem; }
    .modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); display: none; align-items: center; justify-content: center; z-index: 1000; }
    .modal-content { background: white; padding: 25px; border-radius: 12px; width: 400px; box-shadow: 0 10px 25px rgba(0,0,0,0.3); }
    .grid-header th { background: #1A1A2E !important; color: #fff !important; padding: 12px 10px !important; text-align: left !important; font-weight: 600; }
    .grid-row td { padding: 10px !important; border-bottom: 1px solid #eee; }
</style>
<script>
    function showApprovalModal(requestId, resNo, newDate) {
        document.getElementById('<%= hfSelectedRequestId.ClientID %>').value = requestId;
        document.getElementById('modalTitle').innerText = 'Approve Extension: ' + resNo;
        document.getElementById('modalInfo').innerText = 'Extend until: ' + newDate;
        document.getElementById('divModal').style.display = 'flex';
        return false;
    }
    function hideModal() {
        document.getElementById('divModal').style.display = 'none';
        return false;
    }
</script>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
<div style="width: 100%; padding: 18px 22px; background: #F7F3EE; font-family: 'Segoe UI', sans-serif; min-height: 100vh;">

    <div style="background: linear-gradient(135deg, #1A1A2E 0%, #2d2d5e 100%); color: #fff; padding: 16px 26px; border-radius: 10px; margin-bottom: 18px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 4px 15px rgba(0,0,0,0.2);">
        <div>
            <h3 style="margin: 0; font-size: 1.35rem; letter-spacing: 1px;"><i class="fas fa-user-check" style="color:#C9A84C; margin-right:8px;"></i> Extension Approvals</h3>
            <div style="font-size: .77rem; color: #E8D5A3; margin-top: 3px; opacity: 0.9;">Manage pending stay extension requests</div>
        </div>
    </div>

    <asp:Label ID="lblMessage" runat="server" style="display:block; margin-bottom:15px;"></asp:Label>

    <div class="form-card" style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 18px 22px; box-shadow: 0 2px 10px rgba(0,0,0,0.06); position: relative;">
        <div style="font-size: .71rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 14px; padding-bottom: 8px; border-bottom: 1px solid #e0d5c5;">Pending Requests</div>
        
        <div style="overflow-x:auto;">
            <asp:GridView ID="gvRequests" runat="server" AutoGenerateColumns="False" 
                style="width: 100%; border-collapse: collapse; font-size: .85rem;" GridLines="None"
                OnRowCommand="gvRequests_RowCommand">
                <HeaderStyle CssClass="grid-header" />
                <RowStyle CssClass="grid-row" />
                <EmptyDataTemplate>
                    <div style="padding: 30px; text-align: center; color: #999;">No pending extension requests found.</div>
                </EmptyDataTemplate>
                <Columns>
                    <asp:BoundField DataField="RequestDate" HeaderText="Date" DataFormatString="{0:dd-MMM HH:mm}" />
                    <asp:BoundField DataField="ReservationNo" HeaderText="Res #" ItemStyle-Font-Bold="true" />
                    <asp:BoundField DataField="RoomNo" HeaderText="Room" />
                    <asp:BoundField DataField="CurrentToDate" HeaderText="Current To" DataFormatString="{0:dd-MMM}" />
                    <asp:BoundField DataField="NewToDate" HeaderText="Requested To" DataFormatString="{0:dd-MMM}" ItemStyle-ForeColor="#2e7d32" ItemStyle-Font-Bold="true" />
                    <asp:BoundField DataField="Remarks" HeaderText="Guest Remarks" />
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <asp:Button runat="server" Text="Review" CommandName="Review" CommandArgument='<%# Eval("RequestID") %>' CssClass="btn-approve btn-action" 
                                OnClientClick='<%# "return showApprovalModal(\"" + Eval("RequestID") + "\", \"" + Eval("ReservationNo") + "\", \"" + Eval("NewToDate", "{0:dd-MMM-yyyy}") + "\");" %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <%-- APPROVAL MODAL --%>
    <div id="divModal" class="modal-overlay">
        <div class="modal-content">
            <h4 id="modalTitle" style="margin-top:0; color:#1A1A2E;">Approve Extension</h4>
            <p id="modalInfo" style="font-size:0.9rem; color:#666;"></p>
            
            <div style="margin-top:15px;">
                <label style="font-size:0.8rem; font-weight:bold; display:block; margin-bottom:5px;">Approval/Rejection Remarks <span style="color:red;">*</span></label>
                <asp:TextBox ID="txtApprovalRemarks" runat="server" TextMode="MultiLine" Rows="3" 
                    style="width:100%; padding:10px; border:1px solid #ccc; border-radius:6px; font-family:sans-serif;" 
                    placeholder="Enter mandatory remarks here..."></asp:TextBox>
            </div>

            <div style="margin-top:20px; display:flex; gap:10px; justify-content:flex-end;">
                <asp:HiddenField ID="hfSelectedRequestId" runat="server" />
                <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClientClick="return hideModal();" 
                    style="background:#eee; border:none; padding:8px 15px; border-radius:6px; cursor:pointer;" />
                <asp:Button ID="btnReject" runat="server" Text="Reject" OnClick="btnReject_Click" CssClass="btn-reject btn-action" />
                <asp:Button ID="btnApprove" runat="server" Text="Approve" OnClick="btnApprove_Click" CssClass="btn-approve btn-action" />
            </div>
        </div>
    </div>

</div>
</asp:Content>
