<%@ page title="" language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" autoeventwireup="true" inherits="EventSetup" 
    CodeFile="EventSetup.aspx.cs" enableEventValidation="false"  viewStateEncryptionMode="Never" maintainScrollPositionOnPostBack="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet" />

    <style>
        :root {
            --blue:        #2563eb;
            --blue-light:  #eff6ff;
            --blue-mid:    #dbeafe;
            --green:       #16a34a;
            --amber:       #d97706;
            --red:         #dc2626;
            --text-main:   #1e293b;
            --text-muted:  #64748b;
            --border:      #e2e8f0;
            --card-bg:     #ffffff;
            --card-border: #e2e8f0;
            --row-hover:   #eff6ff;
            --page-bg:     #f1f5f9;
        }

        body {
            background: var(--page-bg);
            font-family: 'DM Sans', sans-serif;
            font-size: 13px;
            color: var(--text-main);
            min-height: 100vh;
        }

        /* ── Page Header ── */
        .page-header-bar {
            background: #fff;
            border: 1px solid var(--card-border);
            border-radius: 10px;
            padding: 16px 22px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 14px;
            box-shadow: 0 1px 4px rgba(0,0,0,.06);
        }
        .page-header-bar .hdr-icon {
            width: 42px; height: 42px;
            background: var(--blue-light);
            border: 1px solid var(--blue-mid);
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            font-size: 20px; flex-shrink: 0;
        }
        .page-header-bar h3  { margin: 0; font-size: 17px; font-weight: 700; color: var(--text-main); letter-spacing: .3px; }
        .page-header-bar small { color: var(--text-muted); font-size: 11.5px; display: block; margin-top: 1px; }

        /* ── Tabs ── */
        .tab-nav {
            display: flex;
            gap: 4px;
            border-bottom: 2px solid var(--border);
            margin-bottom: 18px;
            flex-wrap: wrap;
        }
        .tab-link {
            padding: 10px 22px;
            font-weight: 600;
            font-size: 13px;
            color: var(--text-muted) !important;
            text-decoration: none !important;
            border: 1px solid transparent;
            border-bottom: none;
            border-radius: 8px 8px 0 0;
            background: transparent;
            cursor: pointer;
            transition: all .2s;
        }
        .tab-link:hover { color: var(--blue) !important; background: var(--blue-light); }
        .tab-link.active {
            color: var(--blue) !important;
            background: #fff;
            border-color: var(--card-border);
            border-bottom: 2px solid #fff;
            margin-bottom: -2px;
            font-weight: 700;
        }

        /* ── Cards ── */
        .card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 10px;
            margin-bottom: 18px;
            box-shadow: 0 1px 4px rgba(0,0,0,.05);
            overflow: hidden;
        }
        .card-header {
            background: #f8fafc;
            border-bottom: 1px solid var(--card-border);
            padding: 10px 18px;
            font-weight: 600;
            font-size: 12.5px;
            color: var(--text-main);
        }
        .card-body { padding: 18px; }

        /* ── Form Controls ── */
        label.ctrl-label {
            font-weight: 600;
            color: var(--text-muted);
            margin-bottom: 5px;
            display: block;
            font-size: 11.5px;
            text-transform: uppercase;
            letter-spacing: .5px;
        }
        .form-control, .input-sm {
            background: #fff !important;
            border: 1px solid #cbd5e1 !important;
            color: var(--text-main) !important;
            border-radius: 6px !important;
            font-family: 'DM Sans', sans-serif;
            font-size: 13px !important;
        }
        .form-control:focus, .input-sm:focus {
            border-color: var(--blue) !important;
            box-shadow: 0 0 0 3px rgba(37,99,235,.1) !important;
            outline: none !important;
        }

        /* ── Buttons ── */
        .btn { border-radius: 6px !important; font-weight: 600; font-size: 12.5px; transition: all .2s; }
        .btn-primary  { background: var(--blue)    !important; border: none !important; color: #fff !important; box-shadow: 0 1px 4px rgba(37,99,235,.25); }
        .btn-primary:hover  { background: #1d4ed8  !important; transform: translateY(-1px); }
        .btn-success  { background: var(--green)   !important; border: none !important; color: #fff !important; }
        .btn-success:hover  { background: #15803d  !important; transform: translateY(-1px); }
        .btn-default  { background: #fff !important; border: 1px solid #cbd5e1 !important; color: var(--text-main) !important; }
        .btn-default:hover  { background: #f1f5f9  !important; border-color: var(--blue) !important; color: var(--blue) !important; }
        .btn-danger   { background: #dc2626        !important; border: none !important; color: #fff !important; }
        .btn-danger:hover   { background: #b91c1c  !important; transform: translateY(-1px); }
        .btn-xs { padding: 3px 8px !important; font-size: 11px !important; margin-right: 4px; }

        .action-col { display: flex; gap: 10px; }

        /* ── Setup Table ── */
        .table-setup { width: 100%; border-collapse: collapse; font-size: 12.5px; }
        .table-setup th {
            background: #f8fafc;
            border-bottom: 2px solid var(--border);
            padding: 8px 12px;
            text-align: left;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: .5px;
            color: var(--text-muted);
            font-weight: 700;
        }
        .table-setup td {
            padding: 8px 12px;
            border-bottom: 1px solid #f1f5f9;
            vertical-align: middle;
        }
        .table-setup tr:hover td { background: var(--row-hover); }

        /* ── Status / Alerts ── */
        .status-label { font-size: 12px; color: var(--red); font-weight: 600; padding: 3px 0; display: block; }
        .status-label.success { color: var(--green); }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">

    <div class="container-fluid" style="max-width:1200px; margin:0 auto; padding:18px;">

        <%-- ══ HEADER ══ --%>
        <div class="page-header-bar">
            <div class="hdr-icon">⚙️</div>
            <div>
                <h3>Booking Setup / Definitions</h3>
                <small>Manage Event Name, Timing, Place &amp; Menu Deals used in Event Booking</small>
            </div>
        </div>

        <asp:Label ID="lblSetupMessage" runat="server" Text="" CssClass="status-label"></asp:Label>

        <%-- ══ TAB NAV ══ --%>
        <div class="tab-nav">
            <asp:LinkButton ID="lnkTabEventName"   runat="server" CssClass="tab-link active" CausesValidation="false" OnClick="lnkTabEventName_Click">Event Name</asp:LinkButton>
            <asp:LinkButton ID="lnkTabEventTiming" runat="server" CssClass="tab-link"        CausesValidation="false" OnClick="lnkTabEventTiming_Click">Event Timing</asp:LinkButton>
            <asp:LinkButton ID="lnkTabEventPlace"  runat="server" CssClass="tab-link"        CausesValidation="false" OnClick="lnkTabEventPlace_Click">Event Place</asp:LinkButton>
            <asp:LinkButton ID="lnkTabMenu"        runat="server" CssClass="tab-link"        CausesValidation="false" OnClick="lnkTabMenu_Click">Menu (Deals)</asp:LinkButton>
        </div>

        <%-- ══════════════════════ TAB 1 : EVENT NAME ══════════════════════ --%>
        <asp:Panel ID="pnlEventName" runat="server">
            <div class="row">
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-header">Add / Edit Event Name</div>
                        <div class="card-body">
                            <asp:HiddenField ID="hfEventNameId" runat="server" Value="0" />
                            <div class="form-group">
                                <label class="ctrl-label">Event Name <span style="color:#dc2626">*</span></label>
                                <asp:TextBox ID="txtEventName" runat="server" CssClass="form-control input-sm" MaxLength="100"></asp:TextBox>
                                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEventName"
                                    ErrorMessage="Event Name is required." Display="Dynamic" CssClass="status-label"
                                    ValidationGroup="vgEventName"></asp:RequiredFieldValidator>
                            </div>
                            <div class="action-col">
                                <asp:Button ID="btnSaveEventName" runat="server" Text="💾 Save" CssClass="btn btn-success"
                                    OnClick="btnSaveEventName_Click" ValidationGroup="vgEventName" />
                                <asp:Button ID="btnClearEventName" runat="server" Text="✖ Clear" CssClass="btn btn-default"
                                    OnClick="btnClearEventName_Click" CausesValidation="false" />
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-8">
                    <div class="card">
                        <div class="card-header">Event Names</div>
                        <div class="card-body" style="padding:0;">
                            <asp:GridView ID="gvEventName" runat="server" AutoGenerateColumns="false" CssClass="table-setup"
                                GridLines="None" EmptyDataText="No records found." OnRowCommand="gvEventName_RowCommand">
                                <Columns>
                                    <asp:BoundField DataField="EventName_Id" HeaderText="ID" ItemStyle-Width="60px" />
                                    <asp:BoundField DataField="EventName" HeaderText="Event Name" />
                                    <asp:TemplateField HeaderText="Action" ItemStyle-Width="140px">
                                        <ItemTemplate>
                                            <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# Eval("EventName_Id") %>' CssClass="btn btn-default btn-xs">✎ Edit</asp:LinkButton>
                                            <asp:LinkButton runat="server" CommandName="DeleteRow" CommandArgument='<%# Eval("EventName_Id") %>' CssClass="btn btn-danger btn-xs" OnClientClick="return confirm('Delete this Event Name?');">🗑 Delete</asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <%-- ══════════════════════ TAB 2 : EVENT TIMING ══════════════════════ --%>
        <asp:Panel ID="pnlEventTiming" runat="server" Visible="false">
            <div class="row">
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-header">Add / Edit Event Timing</div>
                        <div class="card-body">
                            <asp:HiddenField ID="hfTimingId" runat="server" Value="0" />
                            <div class="form-group">
                                <label class="ctrl-label">Timing <span style="color:#dc2626">*</span></label>
                                <asp:TextBox ID="txtTiming" runat="server" CssClass="form-control input-sm" MaxLength="100" placeholder="e.g. Evening 7PM - 11PM"></asp:TextBox>
                                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtTiming"
                                    ErrorMessage="Timing is required." Display="Dynamic" CssClass="status-label"
                                    ValidationGroup="vgTiming"></asp:RequiredFieldValidator>
                            </div>
                            <div class="action-col">
                                <asp:Button ID="btnSaveTiming" runat="server" Text="💾 Save" CssClass="btn btn-success"
                                    OnClick="btnSaveTiming_Click" ValidationGroup="vgTiming" />
                                <asp:Button ID="btnClearTiming" runat="server" Text="✖ Clear" CssClass="btn btn-default"
                                    OnClick="btnClearTiming_Click" CausesValidation="false" />
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-8">
                    <div class="card">
                        <div class="card-header">Event Timings</div>
                        <div class="card-body" style="padding:0;">
                            <asp:GridView ID="gvEventTiming" runat="server" AutoGenerateColumns="false" CssClass="table-setup"
                                GridLines="None" EmptyDataText="No records found." OnRowCommand="gvEventTiming_RowCommand">
                                <Columns>
                                    <asp:BoundField DataField="Timing_Id" HeaderText="ID" ItemStyle-Width="60px" />
                                    <asp:BoundField DataField="Timing" HeaderText="Timing" />
                                    <asp:TemplateField HeaderText="Action" ItemStyle-Width="140px">
                                        <ItemTemplate>
                                            <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# Eval("Timing_Id") %>' CssClass="btn btn-default btn-xs">✎ Edit</asp:LinkButton>
                                            <asp:LinkButton runat="server" CommandName="DeleteRow" CommandArgument='<%# Eval("Timing_Id") %>' CssClass="btn btn-danger btn-xs" OnClientClick="return confirm('Delete this Timing?');">🗑 Delete</asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <%-- ══════════════════════ TAB 3 : EVENT PLACE ══════════════════════ --%>
        <asp:Panel ID="pnlEventPlace" runat="server" Visible="false">
            <div class="row">
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-header">Add / Edit Event Place</div>
                        <div class="card-body">
                            <asp:HiddenField ID="hfPlaceId" runat="server" Value="0" />
                            <div class="form-group">
                                <label class="ctrl-label">Event Place <span style="color:#dc2626">*</span></label>
                                <asp:TextBox ID="txtPlace" runat="server" CssClass="form-control input-sm" MaxLength="100" placeholder="e.g. Main Hall"></asp:TextBox>
                                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPlace"
                                    ErrorMessage="Event Place is required." Display="Dynamic" CssClass="status-label"
                                    ValidationGroup="vgPlace"></asp:RequiredFieldValidator>
                            </div>
                            <div class="action-col">
                                <asp:Button ID="btnSavePlace" runat="server" Text="💾 Save" CssClass="btn btn-success"
                                    OnClick="btnSavePlace_Click" ValidationGroup="vgPlace" />
                                <asp:Button ID="btnClearPlace" runat="server" Text="✖ Clear" CssClass="btn btn-default"
                                    OnClick="btnClearPlace_Click" CausesValidation="false" />
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-8">
                    <div class="card">
                        <div class="card-header">Event Places</div>
                        <div class="card-body" style="padding:0;">
                            <asp:GridView ID="gvEventPlace" runat="server" AutoGenerateColumns="false" CssClass="table-setup"
                                GridLines="None" EmptyDataText="No records found." OnRowCommand="gvEventPlace_RowCommand">
                                <Columns>
                                    <asp:BoundField DataField="Event_Id" HeaderText="ID" ItemStyle-Width="60px" />
                                    <asp:BoundField DataField="Event_Place" HeaderText="Event Place" />
                                    <asp:TemplateField HeaderText="Action" ItemStyle-Width="140px">
                                        <ItemTemplate>
                                            <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# Eval("Event_Id") %>' CssClass="btn btn-default btn-xs">✎ Edit</asp:LinkButton>
                                            <asp:LinkButton runat="server" CommandName="DeleteRow" CommandArgument='<%# Eval("Event_Id") %>' CssClass="btn btn-danger btn-xs" OnClientClick="return confirm('Delete this Place?');">🗑 Delete</asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <%-- ══════════════════════ TAB 4 : MENU (MAINDEALS) ══════════════════════ --%>
        <asp:Panel ID="pnlMenu" runat="server" Visible="false">
            <div class="row">
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-header">Add / Edit Menu Deal</div>
                        <div class="card-body">
                            <asp:HiddenField ID="hfMenuDID" runat="server" Value="0" />
                            <div class="form-group">
                                <label class="ctrl-label">Deal Name <span style="color:#dc2626">*</span></label>
                                <asp:TextBox ID="txtDealName" runat="server" CssClass="form-control input-sm" MaxLength="150"></asp:TextBox>
                                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtDealName"
                                    ErrorMessage="Deal Name is required." Display="Dynamic" CssClass="status-label"
                                    ValidationGroup="vgMenu"></asp:RequiredFieldValidator>
                            </div>
                            <div class="form-group">
                                <label class="ctrl-label">Deal Amount <span style="color:#dc2626">*</span></label>
                                <asp:TextBox ID="txtDealAmount" runat="server" CssClass="form-control input-sm" MaxLength="18"></asp:TextBox>
                                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtDealAmount"
                                    ErrorMessage="Deal Amount is required." Display="Dynamic" CssClass="status-label"
                                    ValidationGroup="vgMenu"></asp:RequiredFieldValidator>
                                <asp:CompareValidator runat="server" ControlToValidate="txtDealAmount"
                                    Operator="DataTypeCheck" Type="Double"
                                    ErrorMessage="Deal Amount must be numeric." Display="Dynamic" CssClass="status-label"
                                    ValidationGroup="vgMenu"></asp:CompareValidator>
                            </div>
                            <div class="form-group">
                                <label class="ctrl-label">Tax %</label>
                                <asp:TextBox ID="txtMenuTax" runat="server" CssClass="form-control input-sm" MaxLength="50"></asp:TextBox>
                            </div>
                            <div class="form-group">
                                <label class="ctrl-label">Timing</label>
                                <asp:TextBox ID="txtMenuTiming" runat="server" CssClass="form-control input-sm" MaxLength="50" placeholder="e.g. Lunch / Dinner"></asp:TextBox>
                            </div>
                            <div class="form-group">
                                <label class="ctrl-label">Remarks</label>
                                <asp:TextBox ID="txtMenuRemarks" runat="server" CssClass="form-control input-sm" TextMode="MultiLine" Rows="2" MaxLength="500"></asp:TextBox>
                            </div>
                            <div class="form-group">
                                <asp:CheckBox ID="chkMenuActive" runat="server" Checked="true" Text=" Active" />
                            </div>
                            <div class="action-col">
                                <asp:Button ID="btnSaveMenu" runat="server" Text="💾 Save" CssClass="btn btn-success"
                                    OnClick="btnSaveMenu_Click" ValidationGroup="vgMenu" />
                                <asp:Button ID="btnClearMenu" runat="server" Text="✖ Clear" CssClass="btn btn-default"
                                    OnClick="btnClearMenu_Click" CausesValidation="false" />
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-8">
                    <div class="card">
                        <div class="card-header">Menu Deals (MainDeals)</div>
                        <div class="card-body" style="padding:0;">
                            <asp:GridView ID="gvMenu" runat="server" AutoGenerateColumns="false" CssClass="table-setup"
                                GridLines="None" EmptyDataText="No records found." OnRowCommand="gvMenu_RowCommand">
                                <Columns>
                                    <asp:BoundField DataField="DID" HeaderText="DID" ItemStyle-Width="50px" />
                                    <asp:BoundField DataField="DealName" HeaderText="Deal Name" />
                                    <asp:BoundField DataField="DealAmount" HeaderText="Amount" DataFormatString="{0:N2}" ItemStyle-Width="80px" />
                                    <asp:BoundField DataField="Tax" HeaderText="Tax %" ItemStyle-Width="60px" />
                                    <asp:BoundField DataField="Timing" HeaderText="Timing" ItemStyle-Width="80px" />
                                    <asp:CheckBoxField DataField="ISActive" HeaderText="Active" ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center" />
                                    <asp:TemplateField HeaderText="Action" ItemStyle-Width="140px">
                                        <ItemTemplate>
                                            <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# Eval("DID") %>' CssClass="btn btn-default btn-xs">✎ Edit</asp:LinkButton>
                                            <asp:LinkButton runat="server" CommandName="DeleteRow" CommandArgument='<%# Eval("DID") %>' CssClass="btn btn-danger btn-xs" OnClientClick="return confirm('Delete this Deal?');">🗑 Delete</asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </asp:Panel>

    </div>

</asp:Content>



