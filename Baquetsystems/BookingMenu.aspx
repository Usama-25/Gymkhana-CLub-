<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" AutoEventWireup="true" CodeFile="BookingMenu.aspx.cs" Inherits="Store_BookingMenu" %>

<%-- Register Assembly ReportViewer disabled --%>
<%--<%-- Register Assembly Infragistics disabled --%>
<%-- Register Assembly AjaxControlToolkit disabled --%>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet" />

    <style>
        /* ══════════════════════════════════════════
           TOKEN SYSTEM  — identical to CreateRecipe
           ══════════════════════════════════════════ */
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
            --row-even:    #f8fafc;
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
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--text-main);
        }
        .card-header .step-badge {
            background: var(--blue);
            color: #fff;
            border-radius: 50%;
            width: 20px; height: 20px;
            display: inline-flex;
            align-items: center; justify-content: center;
            font-size: 10px; font-weight: 700;
            flex-shrink: 0;
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
            transition: border-color .2s, box-shadow .2s;
        }
        .form-control:focus, .input-sm:focus {
            border-color: var(--blue) !important;
            box-shadow: 0 0 0 3px rgba(37,99,235,.1) !important;
            outline: none !important;
        }

        /* ── Buttons — exact match to CreateRecipe ── */
        .btn { border-radius: 6px !important; font-weight: 600; font-size: 12.5px; transition: all .2s; }
        .btn-primary  { background: var(--blue)    !important; border: none !important; color: #fff !important; box-shadow: 0 1px 4px rgba(37,99,235,.25); }
        .btn-primary:hover  { background: #1d4ed8  !important; transform: translateY(-1px); }
        .btn-success  { background: var(--green)   !important; border: none !important; color: #fff !important; }
        .btn-success:hover  { background: #15803d  !important; transform: translateY(-1px); }
        .btn-default  { background: #fff !important; border: 1px solid #cbd5e1 !important; color: var(--text-main) !important; }
        .btn-default:hover  { background: #f1f5f9  !important; border-color: var(--blue) !important; color: var(--blue) !important; }
        .btn-info     { background: #0284c7        !important; border: none !important; color: #fff !important; }
        .btn-info:hover     { background: #0369a1  !important; transform: translateY(-1px); }
        .btn-danger   { background: #dc2626        !important; border: none !important; color: #fff !important; }
        .btn-danger:hover   { background: #b91c1c  !important; transform: translateY(-1px); }

        /* ── Action column (matches CreateRecipe row-6 pattern) ── */
        .action-col { display: flex; gap: 10px; justify-content: center; align-items: center; }

        /* ── Totals Strip — matches CreateRecipe totals-strip ── */
        .totals-strip {
            background: #fff;
            border: 1px solid var(--card-border);
            border-radius: 10px;
            padding: 16px 22px;
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            align-items: center;
            box-shadow: 0 1px 4px rgba(0,0,0,.05);
            margin-bottom: 0;
        }
        .totals-strip .t-item  { text-align: center; flex: 1; min-width: 72px; }
        .totals-strip .t-sep   { font-size: 18px; color: var(--text-muted); flex: none; }
        .totals-strip .t-label { font-size: 10.5px; color: var(--text-muted); text-transform: uppercase; letter-spacing: .5px; font-weight: 600; }
        .totals-strip .t-value { font-size: 15px; font-weight: 700; color: var(--blue); margin-top: 3px; font-family: 'DM Mono', monospace; }
        .totals-strip .t-value.grand { font-size: 20px; color: var(--amber); }

        /* inline editable field inside totals strip */
        .totals-strip .t-input {
            width: 68px;
            text-align: center;
            border: 1px solid #cbd5e1;
            border-radius: 5px;
            padding: 4px 6px;
            font-family: 'DM Mono', monospace;
            font-size: 13px;
            color: var(--text-main);
            background: #f8fafc;
            font-weight: 700;
            display: inline-block;
            margin-top: 3px;
        }
        .totals-strip .t-input.balance {
            width: 84px;
            color: var(--red);
            background: #fef2f2;
            border-color: #fca5a5;
        }

        /* ── Billing Summary dark header card (CreateRecipe-style) ── */
        .billing-details-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 1px 4px rgba(0,0,0,.05);
            margin-bottom: 18px;
        }
        .billing-details-header {
            background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
            color: #fff;
            padding: 11px 18px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .billing-details-header .bh-title { font-weight: 700; font-size: 14px; }
        .billing-details-header .bh-sub   { font-size: 11px; color: rgba(255,255,255,.55); margin-top: 1px; }

        /* ── Menu DataList Cards — matches CreateRecipe addon-card aesthetic ── */
        .menu-section {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 10px;
            padding: 14px 16px;
            flex-shrink: 0;
            box-shadow: 0 1px 4px rgba(0,0,0,.05);
        }
        .menu-section h2 {
            font-size: 11px;
            font-weight: 700;
            color: var(--blue);
            text-transform: uppercase;
            letter-spacing: .6px;
            border-bottom: 2px solid var(--blue-mid);
            padding-bottom: 6px;
            margin: 0 0 10px 0;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .menu-inner   { overflow-y: auto; max-height: 240px; }
        .menu-row {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 5px 2px;
            border-bottom: 1px solid #f1f5f9;
            transition: background .15s;
        }
        .menu-row:last-child { border-bottom: none; }
        .menu-row:hover { background: var(--row-hover); border-radius: 4px; }
        .menu-item-name { flex: 1; font-size: 12px; color: var(--text-main); }
        .menu-item-amt  { font-size: 11.5px; font-family: 'DM Mono', monospace; color: var(--text-muted); width: 42px; text-align: right; }
        .menu-item-qty input {
            width: 42px;
            border: 1px solid #cbd5e1;
            border-radius: 4px;
            padding: 2px 4px;
            font-size: 11.5px;
            text-align: center;
            font-family: 'DM Mono', monospace;
            background: #f8fafc;
        }
        .menu-item-chk input[type=checkbox] {
            width: 16px; height: 16px;
            cursor: pointer;
            accent-color: var(--blue);
        }

        /* Menu package selector row */
        .menu-pkg-bar {
            background: #f8fafc;
            border: 1px solid var(--card-border);
            border-radius: 8px;
            padding: 12px 16px;
            margin-bottom: 16px;
            display: flex;
            align-items: flex-end;
            gap: 16px;
            flex-wrap: wrap;
        }
        .menu-pkg-bar .mpb-field { display: flex; flex-direction: column; gap: 4px; }
        .menu-pkg-bar .mpb-field label { font-size: 10.5px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; letter-spacing: .5px; }

        /* ── Menu Grid Wrapper ── */
        .menu-grid-wrapper { display: flex; flex-wrap: wrap; gap: 14px; }

        /* ── Status / Alerts ── */
        .status-label { font-size: 12px; color: var(--red); font-weight: 600; padding: 3px 0; display: block; }
        .alert-fixed {
            position: fixed; top: 24px; right: 24px; z-index: 9999;
            min-width: 320px; padding: 14px 18px 14px 16px;
            border-radius: 8px; box-shadow: 0 4px 16px rgba(0,0,0,.12);
            display: flex; align-items: flex-start; gap: 10px;
        }
        .alert-danger  { background: #fef2f2; color: #991b1b; border: 1px solid #fca5a5; }
        .alert-warning { background: #fffbeb; color: #92400e; border: 1px solid #fcd34d; }
        .alert-success { background: #f0fdf4; color: #166534; border: 1px solid #86efac; }
        .alert-info    { background: #eff6ff; color: #1e40af; border: 1px solid #93c5fd; }

        /* ── No items placeholder (matches CreateRecipe) ── */
        .no-items { text-align: center; color: var(--text-muted); padding: 32px 16px; font-style: italic; font-size: 13px; }

        @media (max-width: 767px) {
            .totals-strip  { gap: 12px; }
            .menu-section  { width: 100%; }
            .menu-pkg-bar  { flex-direction: column; }
            .action-col    { flex-direction: column; }
        }
    </style>

    <script type="text/javascript">
        function ClientItemSelected2(sender, e) {
            $get("<%= hfCategory.ClientID %>").value = e.get_value();
        }

        function validateBooking() {
            const partyDate = document.getElementById('<%= txtDate.ClientID %>').value;
            const partyName = document.getElementById('<%= dldName.ClientID %>').value;
            const partyHallId = document.getElementById('<%= DdlEvent.ClientID %>').value;

            if (!partyDate || !partyName || !partyHallId || partyHallId === "0") { return; }

            $.ajax({
                type: "POST",
                url: "BookingMenu.aspx/CheckExistingBookingAjax",
                data: JSON.stringify({ partyDate: partyDate, partyName: partyName, partyHallId: parseInt(partyHallId) }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === true) {
                        showAlert("warning", "⚠ A booking already exists for this hall and date!");
                    }
                },
                error: function (xhr, status, error) { console.error("Error calling CheckExistingBookingAjax:", error); }
            });
        }

        function showAlert(type, message) {
            $("#customAlert").remove();
            var icon = { success: "✔", danger: "✖", warning: "⚠", info: "ℹ" }[type] || "ℹ";
            var html = '<div id="customAlert" class="alert-fixed alert-' + type + '" style="display:none;">'
                + '<span style="font-size:16px;flex-shrink:0;">' + icon + '</span>'
                + '<span>' + message + '</span>'
                + '&nbsp;&nbsp;<button onclick="$(\'#customAlert\').fadeOut(300,function(){$(this).remove();});" '
                + 'style="background:none;border:none;cursor:pointer;font-size:14px;margin-left:auto;">✕</button>'
                + '</div>';
            $("body").append(html);
            $("#customAlert").fadeIn(250);
            setTimeout(function () { $("#customAlert").fadeOut(400, function () { $(this).remove(); }); }, 6000);
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">
    <asp:ScriptManager ID="ScrMn" runat="server"></asp:ScriptManager>

    <div class="container-fluid" style="max-width:1340px; margin:0 auto; padding:18px;">

        <%-- ══ HEADER ══ --%>
        <div class="page-header-bar">
            <div class="hdr-icon">🎉</div>
            <div>
                <h3>Event Booking</h3>
                <small>Banquet &amp; Catering · Booking Module</small>
            </div>
        </div>

        <%-- ══ ROW 1 — MEMBER + EVENT INFO ══ --%>
        <div class="row">

            <%-- Step 1 · Member --%>
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header"><span class="step-badge">1</span> Member</div>
                    <div class="card-body">
                        <div class="form-group">
                            <label class="ctrl-label">Member No</label>
                            <asp:TextBox ID="txtmemberNo" runat="server"
                                OnTextChanged="txtmemberNo_TextChanged"
                                AutoPostBack="true"
                                CssClass="form-control input-sm"></asp:TextBox>
                            <%-- AutoCompleteExtender disabled --%>
                            <asp:HiddenField ID="hfCategory" runat="server" />
                        </div>
                        <div class="form-group" style="margin-bottom:0;">
                            <label class="ctrl-label">Member Name</label>
                            <asp:DropDownList ID="ddlMember" runat="server" CssClass="form-control input-sm"></asp:DropDownList>
                            <asp:Label ID="lblStatus" ForeColor="Red" runat="server" Text="" CssClass="status-label"></asp:Label>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Step 2 · Event Details --%>
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header"><span class="step-badge">2</span> Event Details</div>
                    <div class="card-body">
                        <div class="form-group">
    <label class="ctrl-label">
        Event Name <span style="color:#dc2626">*</span>
    </label>

    <asp:DropDownList ID="dldName" runat="server"
        CssClass="form-control input-sm"
        onchange="validateBooking()">
    </asp:DropDownList>
</div>
                        <div class="row">
                            <div class="col-sm-6">
                                <div class="form-group" style="margin-bottom:0;">
                                    <label class="ctrl-label">Date <span style="color:#dc2626">*</span></label>
                                    <asp:TextBox ID="txtDate" runat="server"
                                        TextMode="Date"
                                        CssClass="form-control input-sm"
                                        onchange="validateBooking()"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <div class="form-group" style="margin-bottom:0;">
                                    <label class="ctrl-label">Total Persons</label>
                                    <asp:TextBox ID="txtPerson" runat="server"
                                        Text="1"
                                        CssClass="form-control input-sm"
                                        AutoPostBack="true"
                                        OnTextChanged="txtPerson_TextChanged"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Step 3 · Venue & Contact --%>
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header"><span class="step-badge">3</span> Venue &amp; Contact</div>
                    <div class="card-body">
                        <div class="form-group">
                            <label class="ctrl-label">Event Place <span style="color:#dc2626">*</span></label>
                            <asp:DropDownList ID="DdlEvent" runat="server"
                                CssClass="form-control input-sm"
                                onchange="validateBooking()"></asp:DropDownList>
                        </div>
                        <div class="form-group">
                            <label class="ctrl-label">Event Timing</label>
                            <asp:DropDownList ID="ddlTiming" runat="server"
                                CssClass="form-control input-sm"></asp:DropDownList>
                        </div>
                        <div class="row">
                            <div class="col-sm-6">
                                <div class="form-group" style="margin-bottom:0;">
                                    <label class="ctrl-label">Contact Person</label>
                                    <asp:TextBox ID="txtConperson" runat="server"
                                        CssClass="form-control input-sm"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <div class="form-group" style="margin-bottom:0;">
                                    <label class="ctrl-label">Contact No</label>
                                    <asp:TextBox ID="txtContact" runat="server"
                                        CssClass="form-control input-sm"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div><%-- /row 1 --%>

        <%-- ══ ROW 2 — MENU SELECTION ══ --%>
        <div class="row">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-header">
                        <span class="step-badge">4</span> Select Menu
                        <span style="margin-left:8px; font-size:11px; color:var(--text-muted); font-weight:400;">
                            · Check items to include in the booking
                        </span>
                    </div>
                    <div class="card-body" style="padding-bottom:12px;">

                        <%-- Menu Package picker bar --%>
                        <div class="menu-pkg-bar">
                            <div class="mpb-field" style="min-width:260px;">
                                <label>Menu Package</label>
                                <asp:DropDownList ID="DdlMenu" runat="server"
                                    CssClass="form-control input-sm"
                                    OnTextChanged="DdlMenu_TextChanged"
                                    AutoPostBack="true"></asp:DropDownList>
                            </div>
                            <div>
                                <asp:Label ID="Label1" runat="server" Text="" CssClass="status-label"></asp:Label>
                            </div>
                        </div>

                        <%-- Menu Items DataList --%>
                        <div class="menu-grid-wrapper">
                            <asp:DataList ID="DataList1" runat="server"
                                OnItemDataBound="DataList1_ItemDataBound"
                                OnPreRender="DataList1_PreRender"
                                RepeatColumns="4"
                                RepeatDirection="Horizontal"
                                Style="width:100%;">
                                <ItemTemplate>
                                    <div class="menu-section">
                                        <h2>
                                            <span style="font-size:13px;">🍽</span>
                                            <asp:Label ID="lblModuleName" runat="server" Text='<%# Eval("Manu") %>'></asp:Label>
                                        </h2>
                                        <asp:HiddenField ID="hfModuleID" runat="server" Value='<%# Eval("SelectItem") %>' />
                                        <asp:HiddenField ID="Hfreq"      runat="server" Value='<%# Eval("Requird") %>' />
                                        <asp:HiddenField ID="hfCat"      runat="server" Value='<%# Eval("Category") %>' />
                                        <div class="menu-inner">
                                            <asp:DataList ID="data" runat="server"
                                                OnItemDataBound="data_ItemDataBound"
                                                Width="100%">
                                                <ItemTemplate>
                                                    <div class="menu-row">
                                                        <span class="menu-item-name">
                                                            <asp:Label ID="lblManu_Name"   runat="server" Text='<%# Eval("Manu_Name") %>'></asp:Label>
                                                            <asp:HiddenField ID="hfRoleID"     runat="server" Value='<%# Eval("MenuList_Id") %>' />
                                                            <asp:HiddenField ID="itemCode"     runat="server" Value='<%# Eval("ItemCode") %>' />
                                                            <asp:HiddenField ID="hdfcategory"  runat="server" Value='<%# Eval("category") %>' />
                                                            <asp:HiddenField ID="hdfWeightage" runat="server" Value='<%# Eval("Weightage") %>' />
                                                        </span>
                                                        <span class="menu-item-amt">
                                                            <asp:Label ID="lblAmount" runat="server" Text='<%# Eval("Amount") %>'></asp:Label>
                                                        </span>
                                                        <span class="menu-item-qty">
                                                            <asp:TextBox ID="txtqtys" runat="server" Text="1"
                                                                OnTextChanged="txtqtys_TextChanged"
                                                                AutoPostBack="true"></asp:TextBox>
                                                        </span>
                                                        <span class="menu-item-chk">
                                                            <asp:CheckBox ID="chkboxOne" runat="server"
                                                                OnCheckedChanged="chkboxOne_CheckedChanged"
                                                                AutoPostBack="true" />
                                                        </span>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:DataList>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:DataList>
                        </div>

                    </div>
                </div>
            </div>
        </div>

        <%-- ══ ROW 3 — BILLING SUMMARY ══ --%>
        <div class="row">
            <div class="col-md-12">
                <div class="billing-details-card">

                    <%-- Dark gradient header — matches CreateRecipe recipe-details-header --%>
                    <div class="billing-details-header">
                        <span style="font-size:18px;">💰</span>
                        <div>
                            <div class="bh-title">Billing Summary</div>
                            <div class="bh-sub">Step 5 · Charges, taxes &amp; advance</div>
                        </div>
                        <span class="step-badge" style="margin-left:auto; background:rgba(255,255,255,.15); font-size:11px; width:auto; border-radius:6px; padding:2px 10px; border:1px solid rgba(255,255,255,.2); letter-spacing:.4px;">TOTALS</span>
                    </div>

                    <%-- Totals Strip --%>
                    <div style="padding:18px;">
                        <div class="totals-strip">

                            <div class="t-item">
                                <div class="t-label">Deal</div>
                                <div class="t-value">
                                    <asp:Label ID="txttotal" runat="server" Text="—"></asp:Label>
                                </div>
                            </div>

                            <div class="t-sep">+</div>

                            <div class="t-item">
                                <div class="t-label">Tax %</div>
                                <div class="t-value">
                                    <asp:TextBox ID="txtTax" runat="server" Text="16"
                                        AutoPostBack="true" OnTextChanged="txtTax_TextChanged"
                                        CssClass="t-input"></asp:TextBox>
                                </div>
                            </div>

                            <div class="t-sep">=</div>

                            <div class="t-item">
                                <div class="t-label">Deal With Tax</div>
                                <div class="t-value">
                                    <asp:Label ID="txtDealWithtax" runat="server" Text="—"></asp:Label>
                                </div>
                            </div>

                            <div class="t-sep">+</div>

                            <div class="t-item">
                                <div class="t-label">Additional</div>
                                <div class="t-value">
                                    <asp:Label ID="lblAdditional" runat="server" Text="—"></asp:Label>
                                </div>
                            </div>

                            <div class="t-sep">+</div>

                            <div class="t-item">
                                <div class="t-label">Venue</div>
                                <div class="t-value">
                                    <asp:TextBox ID="txtVenue" runat="server" Text="0"
                                        AutoPostBack="true" OnTextChanged="txtVenue_TextChanged"
                                        CssClass="t-input"></asp:TextBox>
                                </div>
                            </div>

                            <div class="t-sep">+</div>

                            <div class="t-item">
                                <div class="t-label">Other</div>
                                <div class="t-value">
                                    <asp:TextBox ID="txtother" runat="server" Text="0"
                                        AutoPostBack="true" OnTextChanged="txtother_TextChanged"
                                        CssClass="t-input"></asp:TextBox>
                                </div>
                            </div>

                            <div class="t-sep">+</div>

                            <div class="t-item">
                                <div class="t-label">W/H Tax %</div>
                                <div class="t-value">
                                    <asp:TextBox ID="txtWtax" runat="server" Text=""
                                        AutoPostBack="true" OnTextChanged="txtWtax_TextChanged"
                                        CssClass="t-input"></asp:TextBox>
                                </div>
                            </div>

                            <div class="t-sep">−</div>

                            <div class="t-item">
                                <div class="t-label">Advance</div>
                                <div class="t-value">
                                    <asp:TextBox ID="TxtAdvanc" runat="server" Text="0"
                                        AutoPostBack="true" OnTextChanged="TxtAdvanc_TextChanged"
                                        CssClass="t-input"></asp:TextBox>
                                </div>
                            </div>

                            <div class="t-sep">=</div>

                            <div class="t-item">
                                <div class="t-label" style="font-size:12px; font-weight:800;">Grand Total</div>
                                <div class="t-value grand">
                                    <asp:Label ID="lblGrandTotal" runat="server" Text="—"></asp:Label>
                                </div>
                            </div>

                            <div class="t-sep">·</div>

                            <div class="t-item">
                                <div class="t-label">Balance</div>
                                <div class="t-value">
                                    <asp:TextBox ID="txtBalance" runat="server"
                                        CssClass="t-input balance"></asp:TextBox>
                                </div>
                            </div>

                        </div><%-- /totals-strip --%>

                        <%-- Hidden Bill field — backend only --%>
                        <div style="display:none;">
                            <asp:TextBox ID="txtBil" runat="server"></asp:TextBox>
                        </div>
                    </div>

                </div>
            </div>
        </div>

        <%-- ══ ROW 4 — STATUS LABELS ══ --%>
        <div class="row" style="margin-bottom:8px;">
            <div class="col-md-12">
                <asp:Label ID="Label3"    runat="server" Text="" CssClass="status-label"></asp:Label>
                <asp:Label ID="Label2"    runat="server" Text="" CssClass="status-label"></asp:Label>
                <asp:Label ID="lblMessage" runat="server" Text="" CssClass="status-label"></asp:Label>
                <asp:HiddenField ID="hfOther" runat="server" Value="0" />
            </div>
        </div>

        <%-- ══ ROW 5 — ACTION BUTTONS — matches CreateRecipe col-md-4 action-col ══ --%>
        <div class="row" style="margin-bottom:22px;">
            <div class="col-md-4 col-md-offset-4">
                <div class="action-col">
                    <asp:Button ID="Button1" runat="server"
                        Text="✔ Save Booking"
                        CssClass="btn btn-primary btn-block"
                        OnClientClick="this.style.opacity=0.7;"
                        OnClick="btnSave_Click" />
                    <asp:Button ID="Button2" runat="server"
                        Text="📄 Report"
                        CssClass="btn btn-info btn-block"
                        OnClientClick="this.style.opacity=0.7;"
                        OnClick="Button2_Click1" />
                </div>
            </div>
        </div>

        <%-- ══ REPORT VIEWER ══ --%>
        <div style="width:100%; height:auto;">
            <%-- ReportViewer disabled --%>
        </div>

    </div><%-- /container --%>

    <!-- Duplicate-booking modal — structure unchanged -->
    <div class="modal fade" id="bookingExistsModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-sm">
            <div class="modal-content">
                <div class="modal-body text-center" style="padding:28px 20px;">
                    <div style="font-size:32px; margin-bottom:10px;">⚠️</div>
                    <h5 style="font-weight:700; color:var(--text-main); margin:0 0 16px;">Hall already booked for this date!</h5>
                    <button type="button" class="btn btn-primary" data-bs-dismiss="modal">OK, Got it</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-1.11.3.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>

</asp:Content>




