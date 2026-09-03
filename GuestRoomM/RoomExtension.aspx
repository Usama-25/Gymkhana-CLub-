<%@ Page Language="C#" MasterPageFile="SiteGuestroom.master" AutoEventWireup="true" CodeFile="RoomExtension.aspx.cs" Inherits="GuestRoomApp.GuestRoomM.RoomExtension" Title="Stay Extension" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
<style>
    /* Rules that require pseudo-elements or media queries */
    .form-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px; background: linear-gradient(90deg, #C9A84C, #8B5E3C); border-radius: 10px 10px 0 0; }
    .form-control:focus { border-color: #C9A84C; outline: none; box-shadow: 0 0 0 3px rgba(201,168,76,0.15); }
    .btn:hover { transform: translateY(-2px); box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">
<div style="width: 100%; padding: 18px 22px; background: #F7F3EE; min-height: 100vh; font-family: 'Segoe UI', sans-serif;" class="res-container">
    <div style="background: linear-gradient(135deg, #1A1A2E, #2d2d5e); color: #fff; padding: 16px 26px; border-radius: 10px; margin-bottom: 18px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 4px 15px rgba(0,0,0,0.2);" class="page-header">
        <div>
            <h3 style="margin: 0; font-size: 1.35rem;">Check-Out Extension</h3>
            <div style="font-size: .77rem; color: #E8D5A3; margin-top: 3px;" class="page-header-sub">Extend Guest Stay · Maintain Room Continuity</div>
        </div>
        <div class="header-actions">
            <a href="RoomCheckOut.aspx" style="background: #6c757d; color: #fff; border: none; padding: 10px 20px; border-radius: 7px; font-size: 0.75rem; font-weight: 600; cursor: pointer; transition: all .2s; display: inline-flex; align-items: center; gap: 8px;" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to Checkout
            </a>
        </div>
    </div>

    <asp:Label ID="lblMessage" runat="server" CssClass="alert" EnableViewState="false"></asp:Label>

    <%-- STEP 1: Identification --%>
    <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 20px 22px; margin-bottom: 16px; box-shadow: 0 2px 10px rgba(0,0,0,0.06); position: relative;" class="form-card">
        <div style="font-size: .71rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 15px; padding-bottom: 8px; border-bottom: 1px solid #e0d5c5;" class="section-title">Step 1: Identify Reservation</div>
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-bottom: 15px; max-width: 500px;" class="form-row">
            <div style="display: flex; flex-direction: column;" class="form-group">
                <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;" class="form-label">Reservation / Receipt No</label>
                <div style="display: flex; gap: 10px;">
                    <asp:TextBox ID="txtSearch" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; transition: border-color .2s; width: 100%;" class="form-control" placeholder="e.g. RES-0001"></asp:TextBox>
                    <asp:LinkButton ID="btnSearch" runat="server" style="background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: #fff; border: none; padding: 10px 20px; border-radius: 7px; font-size: .87rem; font-weight: 600; cursor: pointer; transition: all .2s; display: inline-flex; align-items: center; gap: 8px;" class="btn btn-gold" OnClick="btnSearch_Click">
                        <i class="fas fa-search"></i> Search
                    </asp:LinkButton>
                </div>
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlExtensionForm" runat="server" Visible="false">
        <%-- Reservation Summary --%>
        <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 20px 22px; margin-bottom: 16px; box-shadow: 0 2px 10px rgba(0,0,0,0.06); position: relative;" class="form-card">
            <div style="font-size: .71rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 15px; padding-bottom: 8px; border-bottom: 1px solid #e0d5c5;" class="section-title">Current Stay Details</div>
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); background: #fafafb; border: 1px solid #eee; border-radius: 8px; padding: 15px; gap: 15px; margin-top: 10px;" class="info-grid">
                <div class="info-item">
                    <label style="display: block; font-size: 0.7rem; color: #888; text-transform: uppercase; margin-bottom: 2px;">Guest Name</label>
                    <asp:Label ID="lblGuestName" runat="server" style="display: block; font-size: 0.9rem; font-weight: 600; color: #1A1A2E;" Text="N/A"></asp:Label>
                </div>
                <div class="info-item">
                    <label style="display: block; font-size: 0.7rem; color: #888; text-transform: uppercase; margin-bottom: 2px;">Allocated Room(s)</label>
                    <asp:Label ID="lblRooms" runat="server" Text="N/A" style="padding: 4px 12px; border-radius: 15px; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; background: #e3f2fd; color: #1565C0;" class="status-badge status-occupied"></asp:Label>
                </div>
                <div class="info-item">
                    <label style="display: block; font-size: 0.7rem; color: #888; text-transform: uppercase; margin-bottom: 2px;">Current Check-In</label>
                    <asp:Label ID="lblFromDate" runat="server" style="display: block; font-size: 0.9rem; font-weight: 600; color: #1A1A2E;" Text="N/A"></asp:Label>
                </div>
                <div class="info-item">
                    <label style="display: block; font-size: 0.7rem; color: #888; text-transform: uppercase; margin-bottom: 2px;">Current Check-Out</label>
                    <asp:Label ID="lblToDate" runat="server" style="display: block; font-size: 0.9rem; font-weight: 600; color: #1A1A2E;" Text="N/A"></asp:Label>
                </div>
                <div class="info-item">
                    <label style="display: block; font-size: 0.7rem; color: #888; text-transform: uppercase; margin-bottom: 2px;">Total Rooms</label>
                    <asp:Label ID="lblNoOfRooms" runat="server" style="display: block; font-size: 0.9rem; font-weight: 600; color: #1A1A2E;" Text="0"></asp:Label>
                </div>
            </div>
        </div>

        <%-- Extension Inputs --%>
        <div style="background: #ffffff; border: 1px solid #e0d5c5; border-radius: 10px; padding: 20px 22px; margin-bottom: 16px; box-shadow: 0 2px 10px rgba(0,0,0,0.06); position: relative;" class="form-card">
            <div style="font-size: .71rem; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #8B5E3C; margin-bottom: 15px; padding-bottom: 8px; border-bottom: 1px solid #e0d5c5;" class="section-title">Step 2: Extension Period</div>
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-bottom: 15px;" class="form-row">
                <div style="display: flex; flex-direction: column;" class="form-group">
                    <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;" class="form-label">Room(s) to Extend</label>
                    <asp:DropDownList ID="ddlRoomToExtend" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; transition: border-color .2s; width: 100%;" class="form-control">
                    </asp:DropDownList>
                </div>
                <div style="display: flex; flex-direction: column;" class="form-group">
                    <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;" class="form-label">Extended Check-Out Date</label>
                    <asp:TextBox ID="txtNewToDate" runat="server" TextMode="Date" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #fff; transition: border-color .2s; width: 100%;" class="form-control" AutoPostBack="true" OnTextChanged="txtNewToDate_TextChanged"></asp:TextBox>
                </div>
                <div style="display: flex; flex-direction: column;" class="form-group">
                    <label style="font-size: .8rem; font-weight: 600; color: #1A1A2E; margin-bottom: 4px;" class="form-label">Additional Nights</label>
                    <asp:TextBox ID="txtAddNights" runat="server" style="padding: 8px 11px; border: 1.5px solid #e0d5c5; border-radius: 7px; font-size: .87rem; color: #1A1A2E; background: #f9f9f9; transition: border-color .2s; width: 100%; cursor: not-allowed;" class="form-control" ReadOnly="true" Text="0"></asp:TextBox>
                </div>
                <div style="display: flex; flex-direction: column; justify-content: flex-end;" class="form-group">
                    <asp:LinkButton ID="btnCheckAvailability" runat="server" style="background: #1565C0; color: #fff; border: none; padding: 10px 20px; border-radius: 7px; font-size: .87rem; font-weight: 600; cursor: pointer; transition: all .2s; display: inline-flex; align-items: center; gap: 8px;" class="btn btn-info" OnClick="btnCheckAvailability_Click">
                        <i class="fas fa-calendar-check"></i> Check Availability
                    </asp:LinkButton>
                </div>
            </div>
            
            <div style="margin-top:20px; display:flex; flex-direction:column; gap:4px;">
    <label style="font-size:.81rem; font-weight:600; color:#1A1A2E;">Extension Remarks</label>
    <asp:TextBox ID="txtRemarks" runat="server"
        TextMode="MultiLine"
        Rows="2"
        placeholder="Reason for extension..."
        style="padding:8px 11px; border:1.5px solid #e0d5c5; border-radius:7px; font-size:.87rem; color:#1A1A2E; background:#fff; font-family:'Segoe UI',sans-serif; resize:vertical; width:100%;">
    </asp:TextBox>
</div>
        </div>

        <div class="action-bar" style="text-align: right;">
            <asp:LinkButton ID="btnExtendStay" runat="server" style="background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: #fff; border: none; padding: 10px 20px; border-radius: 7px; font-size: .87rem; font-weight: 600; cursor: pointer; transition: all .2s; display: inline-flex; align-items: center; gap: 8px;" class="btn btn-gold" OnClick="btnExtendStay_Click" Enabled="false">
                <i class="fas fa-clock"></i> Confirm Stay Extension
            </asp:LinkButton>
        </div>
    </asp:Panel>

    <asp:HiddenField ID="hfReservationNo" runat="server" />
    <asp:HiddenField ID="hfCurrentToDate" runat="server" />
</div>

<script type="text/javascript">
    function showMsg(m, s) {
        var lbl = document.getElementById('<%= lblMessage.ClientID %>');
        if (lbl) {
            lbl.innerHTML = m;
            lbl.className = 'alert show ' + (s ? 'alert-success' : 'alert-error');
            setTimeout(function () { lbl.style.display = 'none'; }, 6000);
        }
    }
</script>

</asp:Content>
