<%@ Page Title="Outgoing Club Members" Language="C#" MasterPageFile="~/MemberShipModule/Site.master"
    AutoEventWireup="true" CodeFile="OutgoingClubMembers.aspx.cs" Inherits="OutgoingClubMembers" %>
    <asp:Content ID="HeadStyles" ContentPlaceHolderID="HeadContent" runat="server">
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <style>
            body { font-family: 'Outfit', sans-serif !important; background-color: #faf7f2; }
            .table-container { background: #ffffff; border: 1px solid #e0d5c5; border-radius: 12px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
            .table { width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left; }
            .table th { background: #1A1A2E; color: #C9A84C; font-weight: 700; padding: 0.75rem 1rem; border-bottom: 1px solid #e0d5c5; text-align: left; font-size: 0.875rem; }
            .table td { padding: 0.75rem 1rem; border-bottom: 1px solid #F7F3EE; color: #1A1A2E; vertical-align: middle; font-size: 0.9rem; }
            .table tr:hover { background-color: #faf7f2; }
            .form-control { display: block; width: 100%; padding: 0.6rem 0.8rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #1A1A2E; background-color: white; border: 1px solid #e0d5c5; border-radius: 6px; outline: none; box-sizing: border-box; }
            .form-control:focus { border-color: #C9A84C; }
        </style>
    </asp:Content>


<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* ── Page Layout ── */
        .ocm-page { width: 98%; margin: 0 auto; padding: 1.5rem 0; font-family: 'Outfit', sans-serif; }
        .ocm-page-header { display: flex; align-items: center; gap: 14px; margin-bottom: 20px; padding-bottom: 16px; border-bottom: 1px solid #e0d5c5; }
        .ocm-page-header .icon-wrap { width: 48px; height: 48px; background: linear-gradient(135deg, #8B5E3C, #C9A84C); border-radius: 12px; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 1.3rem; flex-shrink: 0; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2); }
        .ocm-page-header h1 { font-size: 1.5rem; font-weight: 700; color: #1A1A2E; margin: 0; }
        .ocm-page-header p { color: #8B5E3C; margin: 2px 0 0; font-size: 0.875rem; font-weight: 500; }

        /* ── Cards ── */
        .ocm-card { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1); border: 1px solid #e0d5c5; margin-bottom: 16px; }
        .ocm-card-title { font-size: 0.95rem; font-weight: 700; color: #1A1A2E; margin: 0 0 14px; display: flex; align-items: center; gap: 8px; border-bottom: 1px solid #F7F3EE; padding-bottom: 8px; text-transform: uppercase; letter-spacing: 0.5px; }
        .ocm-card-title i { color: #8B5E3C; font-size: 0.9rem; }

        /* ── Form Layout ── */
        .ocm-form-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 14px 24px; margin-bottom: 10px; }
        .form-group { display: flex; flex-direction: column; margin-bottom: 2px; }
        .form-group label { font-size: 0.75rem; font-weight: 700; color: #8B5E3C; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px; }
        .form-group input, .form-group select, .form-group textarea { padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; font-size: 0.88rem; color: #1A1A2E; transition: border-color 0.15s, box-shadow 0.15s; outline: none; background: white; }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus { border-color: #C9A84C; }
        .form-group.full-width { grid-column: 1 / -1; }
        .form-row { display: flex; gap: 10px; align-items: center; }

        /* ── Status Badges ── */
        .badge-active { background: #dcfce7; color: #166534; padding: 4px 12px; border-radius: 12px; font-size: 0.75rem; font-weight: 700; border: 1px solid #bbf7d0; text-transform: uppercase; }
        .badge-inactive { background: #fee2e2; color: #991b1b; padding: 4px 12px; border-radius: 12px; font-size: 0.75rem; font-weight: 700; border: 1px solid #fecaca; text-transform: uppercase; }

        /* ── Buttons ── */
        .btn-primary { background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; border: none; padding: 10px 24px; border-radius: 7px; font-weight: 600; cursor: pointer; transition: 0.2s; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2); }
        .btn-primary:hover { box-shadow: 0 6px 10px rgba(201, 168, 76, 0.3); }
        .btn-secondary { background: #ffffff; color: #7a7a7a; border: 1px solid #e0d5c5; padding: 10px 24px; border-radius: 7px; font-weight: 600; cursor: pointer; transition: 0.2s; display: inline-flex; align-items: center; gap: 8px; }
        .btn-secondary:hover { background: #faf7f2; }
        .btn-accent { background: #1e293b; color: white; border: none; padding: 10px 24px; border-radius: 7px; font-weight: 600; cursor: pointer; transition: 0.2s; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); }
        .btn-accent:hover { background: #0f172a; }

        /* ── Grid View ── */
        .ocm-grid-container { overflow-x: auto; margin-top: 10px; }
        .ocm-grid { width: 100%; border-collapse: collapse; }
        .ocm-grid th { background: #1A1A2E; color: #C9A84C; font-size: 0.875rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; padding: 12px; border-bottom: 1px solid #e0d5c5; text-align: left; }
        .ocm-grid td { padding: 12px; border-bottom: 1px solid #F7F3EE; font-size: 0.9rem; color: #1A1A2E; vertical-align: middle; }
        .ocm-grid tr:hover td { background: #faf7f2; }

        /* ── Message Label ── */
        .msg-success { background: #ecfdf5; color: #065f46; padding: 12px 16px; border-radius: 8px; border-left: 4px solid #10b981; margin-bottom: 12px; display: block; font-weight: 500; font-size: 0.95rem; }
        .msg-error { background: #fef2f2; color: #991b1b; padding: 12px 16px; border-radius: 8px; border-left: 4px solid #ef4444; margin-bottom: 12px; display: block; font-weight: 500; font-size: 0.95rem; }

        .btn-icon-only { background: none; border: none; cursor: pointer; color: #7a7a7a; transition: 0.2s; }
        .btn-icon-only:hover { color: #8B5E3C; }
    </style>   .btn-icon-only:hover { color: #8B5E3C; }
    </style>

    <div class="ocm-page">
        <!-- Header -->
        <div class="ocm-page-header">
            <div class="icon-wrap">
                <i class="fas fa-paper-plane"></i>
            </div>
            <div>
                <h1>Outgoing Club Members</h1>
                <p>Register and manage our members visiting affiliated reciprocal clubs</p>
            </div>
        </div>

        <asp:UpdatePanel ID="upMsg" runat="server">
            <ContentTemplate>
                <asp:Label ID="lblMsg" runat="server" Visible="false" />
            </ContentTemplate>
        </asp:UpdatePanel>

        <!-- Form Section -->
        <asp:UpdatePanel ID="upMain" runat="server">
            <ContentTemplate>
                <div class="ocm-card">
                    <div class="ocm-card-title"><i class="fas fa-file-signature"></i> Outgoing Visit Registration</div>
                    
                    <div class="ocm-form-grid">
                        <!-- Column 1 -->
                        <div class="form-group">
                            <label>Letter No</label>
                            <asp:TextBox ID="txtIntroNo" runat="server" ReadOnly="true" placeholder="Auto-generated" BackColor="#faf7f2" />
                        </div>
                        <div class="form-group">
                            <label>Status</label>
                            <div class="form-row" style="margin-top: 5px;">
                                <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" Text="&nbsp;Active Letter" />
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Member Number <span style="color:red">*</span></label>
                            <asp:TextBox ID="txtMemberNo" runat="server" placeholder="Enter member no" AutoPostBack="true" OnTextChanged="txtMemberNo_TextChanged" />
                        </div>
                        <div class="form-group">
                            <label>Member Name <span style="color:red">*</span></label>
                            <asp:TextBox ID="txtMemberName" runat="server" placeholder="Member name will auto-fetch" ReadOnly="true" BackColor="#faf7f2" />
                        </div>

                        <div class="form-group">
                            <label>Destination Club <span style="color:red">*</span></label>
                            <asp:DropDownList ID="ddlClub" runat="server" />
                        </div>
                        <div class="form-group">
                            <label>For</label>
                            <div class="form-row">
                                <asp:RadioButtonList ID="rblFor" runat="server" RepeatDirection="Horizontal" BorderStyle="None">
                                    <asp:ListItem Text="&nbsp;Self&nbsp;&nbsp;&nbsp;&nbsp;" Value="Self" Selected="True" />
                                    <asp:ListItem Text="&nbsp;With Family" Value="With Family" />
                                </asp:RadioButtonList>
                            </div>
                        </div>

                        <!-- Date Row -->
                        <div class="form-group">
                            <label>Visit From Date <span style="color:red">*</span></label>
                            <asp:TextBox ID="txtDateFrom" runat="server" TextMode="Date" onchange="calculateToDate()" />
                        </div>
                        <div class="form-group">
                            <div style="display:grid; grid-template-columns: 80px 1fr; gap:10px;">
                                <div class="form-group">
                                    <label>Days</label>
                                    <asp:TextBox ID="txtDays" runat="server" TextMode="Number" onchange="calculateToDate()" Text="1" min="1" />
                                </div>
                                <div class="form-group">
                                    <label>To Date</label>
                                    <asp:TextBox ID="txtDateTo" runat="server" ReadOnly="true" BackColor="#faf7f2" />
                                </div>
                            </div>
                        </div>

                        <div class="form-group full-width">
                            <label>Special Remarks / Notes</label>
                            <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="2" />
                        </div>
                    </div>

                    <div style="display:flex; justify-content: space-between; align-items: center; margin-top: 10px; padding-top: 15px; border-top: 1px dashed #e0d5c5;">
                         <div style="display:flex; gap:10px;">
                            <asp:Button ID="btnSave" runat="server" Text="Save & Print" CssClass="btn-primary" OnClick="btnSave_Click" />
                            <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn-secondary" OnClick="btnClear_Click" />
                            <asp:HiddenField ID="hfId" runat="server" Value="0" />
                         </div>
                         <asp:Button ID="btnPrint" runat="server" Text="Print Introductory Letter" CssClass="btn-accent" OnClick="btnPrint_Click" />
                    </div>
                </div>
            </ContentTemplate>
            <Triggers>
                <asp:PostBackTrigger ControlID="btnSave" />
                <asp:PostBackTrigger ControlID="btnPrint" />
            </Triggers>
        </asp:UpdatePanel>

        <!-- Grid -->
        <asp:UpdatePanel ID="upGrid" runat="server">
            <ContentTemplate>
                <div class="ocm-card">
                    <div class="ocm-card-title"><i class="fas fa-list-alt"></i> Recent Outgoing Visits</div>
                    <div class="ocm-grid-container">
                        <asp:GridView ID="gvOutgoing" runat="server" AutoGenerateColumns="false" CssClass="ocm-grid"
                            DataKeyNames="Id" OnRowCommand="gvOutgoing_RowCommand" EmptyDataText="No visits recorded yet.">
                            <Columns>
                                <asp:BoundField DataField="IntroductoryNo" HeaderText="Letter No" ItemStyle-Width="120px" />
                                <asp:BoundField DataField="MemberNo" HeaderText="Member #" ItemStyle-Width="80px" />
                                <asp:BoundField DataField="MemberName" HeaderText="Member Name" />
                                <asp:BoundField DataField="ClubName" HeaderText="Destination Club" />
                                <asp:TemplateField HeaderText="Duration">
                                    <ItemTemplate>
                                        <%# Convert.ToDateTime(Eval("DateFrom")).ToString("dd-MMM") %> to 
                                        <%# Convert.ToDateTime(Eval("DateTo")).ToString("dd-MMM-yyyy") %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Status" ItemStyle-Width="100px">
                                    <ItemTemplate>
                                        <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                                            <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Closed" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Actions" ItemStyle-Width="140px">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditItem" 
                                            CommandArgument='<%# Eval("Id") %>' CssClass="btn-icon-only" ToolTip="Edit Details">
                                            <i class="fas fa-edit"></i>
                                        </asp:LinkButton>
                                        &nbsp;&nbsp;
                                        <asp:LinkButton ID="btnPrintGrid" runat="server" CommandName="PrintItem" 
                                            CommandArgument='<%# Eval("Id") %>' CssClass="btn-icon-only" ToolTip="Print Letter" ForeColor="#10b981">
                                            <i class="fas fa-print"></i>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </ContentTemplate>
            <Triggers>
                <asp:PostBackTrigger ControlID="gvOutgoing" />
            </Triggers>
        </asp:UpdatePanel>
    </div>

    <script type="text/javascript">
        function calculateToDate() {
            var dateFromInput = document.getElementById('<%= txtDateFrom.ClientID %>');
            var daysInput = document.getElementById('<%= txtDays.ClientID %>');
            var dateToInput = document.getElementById('<%= txtDateTo.ClientID %>');

            if (dateFromInput.value && daysInput.value) {
                var dateFrom = new Date(dateFromInput.value);
                var days = parseInt(daysInput.value);
                if (!isNaN(days) && days > 0) {
                    var dateTo = new Date(dateFrom);
                    dateTo.setDate(dateFrom.getDate() + (days - 1));
                    
                    var yyyy = dateTo.getFullYear();
                    var mm = (dateTo.getMonth() + 1).toString().padStart(2, '0');
                    var dd = dateTo.getDate().toString().padStart(2, '0');
                    
                    dateToInput.value = dd + '-' + mm + '-' + yyyy;
                }
            }
        }

        window.addEventListener('load', calculateToDate);
        
        if (typeof Sys !== 'undefined') {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                calculateToDate();
            });
        }
    </script>
</asp:Content>
