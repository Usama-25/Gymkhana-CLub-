<%@ Page Title="Card Prefix Offers" Language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master"
    AutoEventWireup="true" CodeFile="Applydiscount.aspx.cs" Inherits="Pos" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700;14..32,800&family=Space+Grotesk:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'Inter',sans-serif;background:linear-gradient(135deg,#f5f7fa 0%,#e9edf2 100%);color:#1a2634;}
        .glass-panel{background:rgba(255,255,255,0.92);backdrop-filter:blur(2px);border-radius:24px;border:1px solid rgba(255,255,255,0.5);box-shadow:0 8px 32px rgba(0,0,0,0.05);}
        .page-shell{padding:1.8rem;max-width:1600px;margin:0 auto;}
        .page-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:2rem;flex-wrap:wrap;gap:1rem;}
        .page-title{font-family:'Space Grotesk',monospace;font-size:2rem;font-weight:700;background:linear-gradient(135deg,#1a2a3a,#2c3e4e);-webkit-background-clip:text;background-clip:text;color:transparent;letter-spacing:-0.02em;}
        .page-title span{background:linear-gradient(135deg,#e67e22,#d35400);-webkit-background-clip:text;background-clip:text;color:transparent;}
        .offers-badge{background:linear-gradient(135deg,#1a2a3a,#2c3e4e);color:white;font-size:0.8rem;font-weight:600;padding:8px 20px;border-radius:40px;box-shadow:0 4px 12px rgba(0,0,0,0.1);}
        .tab-bar{display:flex;gap:12px;margin-bottom:2rem;flex-wrap:wrap;}
        .tab-btn{border:none;padding:12px 28px;font-family:'Space Grotesk',monospace;font-weight:600;font-size:0.9rem;border-radius:60px;cursor:pointer;transition:all 0.25s;color:#5a6e7c;background:rgba(255,255,255,0.6);}
        .tab-btn i{margin-right:8px;}
        .tab-btn.active{background:linear-gradient(135deg,#1a2a3a,#2c3e4e);color:white;box-shadow:0 8px 20px rgba(0,0,0,0.15);transform:translateY(-2px);}
        .tab-btn:hover:not(.active){background:rgba(255,255,255,0.9);color:#1a2a3a;transform:translateY(-1px);}
        .alert-modern{display:none;align-items:center;gap:12px;padding:1rem 1.5rem;border-radius:20px;font-weight:500;margin-bottom:1.5rem;}
        .alert-modern.success{background:linear-gradient(135deg,#d4edda,#c3e6cb);border-left:5px solid #28a745;color:#155724;display:flex;}
        .alert-modern.error{background:linear-gradient(135deg,#f8d7da,#f5c6cb);border-left:5px solid #dc3545;color:#721c24;display:flex;}
        .field-group{margin-bottom:1.5rem;}
        .field-label{font-size:0.75rem;font-weight:700;text-transform:uppercase;letter-spacing:0.08em;color:#5a6e7c;margin-bottom:8px;}
        .field-input{width:100%;border:1.5px solid #e2e8f0;border-radius:16px;padding:0.7rem 1rem;font-family:'Inter',sans-serif;font-size:0.9rem;transition:all 0.2s;background:white;}
        .field-input:focus{outline:none;border-color:#2c3e4e;box-shadow:0 0 0 3px rgba(44,62,78,0.1);}
        .field-input.prefix-invalid{border-color:#dc3545!important;box-shadow:0 0 0 3px rgba(220,53,69,0.15)!important;}
        .prefix-error-msg{color:#dc3545;font-size:0.78rem;margin-top:5px;display:none;font-weight:500;}
        .radio-group-modern{display:flex;gap:24px;background:#f8fafc;padding:12px 20px;border-radius:60px;border:1px solid #e2e8f0;}
        .radio-group-modern label{display:flex;align-items:center;gap:8px;font-size:0.85rem;font-weight:500;cursor:pointer;}
        .radio-group-modern input[type="radio"]{width:18px;height:18px;accent-color:#2c3e4e;}
        .weekday-grid{display:flex;gap:10px;flex-wrap:wrap;}
        .day-chip{border:1.5px solid #e2e8f0;border-radius:40px;padding:8px 20px;font-size:0.8rem;font-weight:600;cursor:pointer;transition:all 0.2s;background:white;user-select:none;}
        .day-chip.selected{background:linear-gradient(135deg,#1a2a3a,#2c3e4e);color:white;border-color:#2c3e4e;}
        .toggle-row{display:flex;align-items:center;justify-content:space-between;background:#f8fafc;padding:12px 20px;border-radius:60px;margin-bottom:1.5rem;}
        .toggle-switch{position:relative;width:52px;height:26px;}
        .toggle-switch input{opacity:0;width:0;height:0;}
        .toggle-slider{position:absolute;top:0;left:0;right:0;bottom:0;background:#cbd5e1;border-radius:34px;cursor:pointer;transition:0.3s;}
        .toggle-slider:before{position:absolute;content:"";height:20px;width:20px;left:3px;bottom:3px;background:white;border-radius:50%;transition:0.3s;}
        input:checked+.toggle-slider{background:linear-gradient(135deg,#1a2a3a,#2c3e4e);}
        input:checked+.toggle-slider:before{transform:translateX(26px);}
        .btn-primary{background:linear-gradient(135deg,#1a2a3a,#2c3e4e);color:white;border:none;border-radius:40px;padding:12px 24px;font-weight:700;font-size:0.9rem;cursor:pointer;transition:all 0.2s;width:100%;}
        .btn-primary:hover{transform:translateY(-2px);box-shadow:0 8px 20px rgba(0,0,0,0.15);}
        .btn-secondary{background:transparent;border:1.5px solid #e2e8f0;border-radius:40px;padding:12px 24px;font-weight:600;cursor:pointer;transition:all 0.2s;width:100%;margin-top:12px;}
        .btn-secondary:hover{border-color:#2c3e4e;background:#f8fafc;}
        .btn-search{background:#2c3e4e;color:white;border:none;border-radius:40px;padding:8px 20px;font-weight:600;}
        .premium-card{background:linear-gradient(135deg,#0f172a,#1e293b);border-radius:28px;padding:1.8rem;color:white;position:relative;overflow:hidden;height:100%;box-shadow:0 20px 35px -10px rgba(0,0,0,0.2);}
        .premium-card::after{content:'';position:absolute;top:-30%;right:-20%;width:200px;height:200px;background:radial-gradient(circle,rgba(255,215,0,0.15),transparent);border-radius:50%;}
        .preview-prefix{font-size:1.6rem;font-weight:700;font-family:'Space Grotesk',monospace;background:linear-gradient(135deg,#fbbf24,#f59e0b);-webkit-background-clip:text;background-clip:text;color:transparent;}
        .preview-pct{font-size:3rem;font-weight:800;font-family:'Space Grotesk',monospace;color:#fbbf24;line-height:1;}
        .offers-table{width:100%;border-collapse:separate;border-spacing:0 10px;}
        .offers-table th{text-align:left;padding:14px 16px;color:#5a6e7c;font-weight:700;font-size:0.75rem;text-transform:uppercase;letter-spacing:0.05em;}
        .offers-table td{padding:16px;background:white;box-shadow:0 2px 8px rgba(0,0,0,0.03);vertical-align:middle;}
        .offers-table tr td:first-child{border-radius:20px 0 0 20px;}
        .offers-table tr td:last-child{border-radius:0 20px 20px 0;}
        .badge-status{display:inline-block;padding:5px 14px;border-radius:40px;font-size:0.7rem;font-weight:700;}
        .badge-active{background:#d4edda;color:#28a745;}
        .badge-inactive{background:#f8d7da;color:#dc3545;}
        .offer-result-card{background:white;border-radius:16px;padding:1rem;margin-bottom:0.75rem;border:1.5px solid #e2e8f0;transition:all 0.2s;cursor:pointer;}
        .offer-result-card:hover{border-color:#2c3e4e;transform:translateX(3px);}
        .offer-result-card.selected-offer{border-color:#2c3e4e;background:#f0f4f8;}
        .divider-light{height:1px;background:linear-gradient(90deg,transparent,#e2e8f0,transparent);margin:1rem 0;}

        /* ── DEPARTMENT CHECKBOX LIST ── */
        .dept-checkbox-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:10px;max-height:320px;overflow-y:auto;padding:4px;}
        .dept-checkbox-item{display:flex;align-items:center;gap:10px;background:#f8fafc;border:1.5px solid #e2e8f0;border-radius:14px;padding:10px 14px;transition:all 0.2s;cursor:pointer;}
        .dept-checkbox-item:hover{border-color:#2c3e4e;background:#eef2f7;}
        .dept-checkbox-item input[type="checkbox"]{width:17px;height:17px;accent-color:#2c3e4e;cursor:pointer;}
        .dept-checkbox-item label{cursor:pointer;font-size:0.88rem;font-weight:500;margin:0;}
        .dept-checkbox-item.checked-item{border-color:#2c3e4e;background:linear-gradient(135deg,rgba(26,42,58,0.05),rgba(44,62,78,0.08));}

        /* ── SELECTED OFFER BADGE ── */
        .selected-offer-banner{background:linear-gradient(135deg,#1a2a3a,#2c3e4e);color:white;border-radius:18px;padding:14px 20px;margin-bottom:1.5rem;}
        .selected-offer-banner .offer-tag{background:rgba(251,191,36,0.2);color:#fbbf24;border-radius:30px;padding:3px 12px;font-size:0.75rem;font-weight:700;}

        .tab-panel{display:none;animation:fadeIn 0.3s ease;}
        .tab-panel.active{display:block;}
        @keyframes fadeIn{from{opacity:0;transform:translateY(10px);}to{opacity:1;transform:translateY(0);}}
        @media(max-width:768px){.page-shell{padding:1rem;}.page-title{font-size:1.5rem;}.radio-group-modern{flex-direction:column;gap:10px;border-radius:20px;}.dept-checkbox-grid{grid-template-columns:1fr 1fr;}}
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <asp:HiddenField ID="hfSelectedDays"     runat="server" Value="" />
    <asp:HiddenField ID="hfSearchedOfferId"  runat="server" Value="" />
    <asp:HiddenField ID="hfActiveTab"        runat="server" Value="new" />

    <div class="page-shell">
        <div class="page-header">
            <div class="page-title"><span>Card</span> Prefix Offers</div>
            <div class="offers-badge">
                <i class="fa fa-bolt me-2"></i>
                <asp:Label ID="lblActiveOffers" runat="server" Text="0 Active" />
            </div>
        </div>

        <div id="alertMessage" class="alert-modern success" style="display:none;">
            <i class="fa fa-circle-check"></i><span id="successMsg"></span>
        </div>
        <div id="alertError" class="alert-modern error" style="display:none;">
            <i class="fa fa-circle-exclamation"></i><span id="errorMsg"></span>
        </div>

        <div class="tab-bar">
            <button type="button" class="tab-btn active" id="tabNewOffer"    onclick="switchTab('new')">
                <i class="fa fa-plus-circle"></i> Create Offer
            </button>
            <button type="button" class="tab-btn"        id="tabAssign"      onclick="switchTab('assign')">
                <i class="fa fa-link"></i> Assign to Dept
            </button>
            <button type="button" class="tab-btn"        id="tabViewOffers"  onclick="switchTab('view')">
                <i class="fa fa-table-list"></i> All Offers
            </button>
        </div>

        <!-- ══════════════════════════════════════════════════════════
             TAB 1 — CREATE OFFER
        ══════════════════════════════════════════════════════════ -->
        <div class="tab-panel active" id="panelNewOffer">
            <div class="row g-4">
                <div class="col-lg-7">
                    <div class="glass-panel p-4">
                        <h5 class="mb-4" style="font-weight:700">
                            <i class="fa fa-gem me-2" style="color:#e67e22"></i> Offer Configuration
                        </h5>

                        <div class="field-group">
                            <div class="field-label">OFFER NAME</div>
                            <asp:TextBox ID="txtOfferName" runat="server" CssClass="field-input" placeholder="e.g., Weekend Special Gold" />
                            <asp:RequiredFieldValidator ID="rfvOfferName" runat="server" ControlToValidate="txtOfferName"
                                ErrorMessage="Offer name is required" CssClass="text-danger small" Display="Dynamic" ValidationGroup="Save" />
                        </div>

                        <div class="field-group">
                            <div class="field-label">OFFER CODE</div>
                            <asp:TextBox ID="txtOfferCode" runat="server" CssClass="field-input" placeholder="e.g., GOLD-WKND-001" />
                        </div>

                        <div class="field-group">
                            <div class="field-label">CARD PREFIX TYPE</div>
                            <div class="radio-group-modern">
                                <label><asp:RadioButton ID="rbPrefix4" runat="server" GroupName="PrefixType" Checked="true" /> 4 Digits</label>
                                <label><asp:RadioButton ID="rbPrefix6" runat="server" GroupName="PrefixType" /> 6 Digits</label>
                                <label><asp:RadioButton ID="rbPrefix8" runat="server" GroupName="PrefixType" /> 8 Digits</label>
                            </div>
                        </div>

                        <div class="field-group">
                            <div class="field-label">CARD PREFIX(ES)</div>
                            <asp:TextBox ID="txtCardPrefix" runat="server" CssClass="field-input" placeholder="e.g., 4567, 4568" />
                            <small class="text-muted" id="prefixHint">Enter comma-separated 4-digit prefixes</small>
                            <div class="prefix-error-msg" id="prefixErrorMsg">
                                Each prefix must be exactly <span id="prefixLenLabel">4</span> digits and contain only numbers.
                            </div>
                            <asp:RequiredFieldValidator ID="rfvCardPrefix" runat="server" ControlToValidate="txtCardPrefix"
                                ErrorMessage="At least one prefix required" CssClass="text-danger small" Display="Dynamic" ValidationGroup="Save" />
                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="field-group">
                                    <div class="field-label">DISCOUNT %</div>
                                    <asp:TextBox ID="txtDiscountPercent" runat="server" CssClass="field-input" placeholder="15" />
                                    <asp:RequiredFieldValidator ID="rfvDiscountPercent" runat="server"
                                        ControlToValidate="txtDiscountPercent" ErrorMessage="Required"
                                        CssClass="text-danger small" Display="Dynamic" ValidationGroup="Save" />
                                    <asp:RangeValidator ID="rvDiscountPercent" runat="server"
                                        ControlToValidate="txtDiscountPercent" ErrorMessage="0-100 only"
                                        MinimumValue="0" MaximumValue="100" Type="Double"
                                        CssClass="text-danger small" Display="Dynamic" ValidationGroup="Save" />
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="field-group">
                                    <div class="field-label">PER DAY LIMIT</div>
                                    <asp:TextBox ID="txtPerDayLimit" runat="server" CssClass="field-input" placeholder="0 = unlimited" Text="0" />
                                </div>
                            </div>
                        </div>

                        <div class="field-group">
                            <div class="field-label">VALID ON (select days)</div>
                            <div class="weekday-grid" id="weekdayChips">
                                <div class="day-chip" data-val="1" onclick="toggleDay(this)">Mon</div>
                                <div class="day-chip" data-val="2" onclick="toggleDay(this)">Tue</div>
                                <div class="day-chip" data-val="3" onclick="toggleDay(this)">Wed</div>
                                <div class="day-chip" data-val="4" onclick="toggleDay(this)">Thu</div>
                                <div class="day-chip" data-val="5" onclick="toggleDay(this)">Fri</div>
                                <div class="day-chip" data-val="6" onclick="toggleDay(this)">Sat</div>
                                <div class="day-chip" data-val="7" onclick="toggleDay(this)">Sun</div>
                            </div>
                            <small class="text-muted">Leave unselected = valid all days</small>
                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="field-group">
                                    <div class="field-label">MIN BILL AMOUNT</div>
                                    <asp:TextBox ID="txtMinBill" runat="server" CssClass="field-input" placeholder="0.00" Text="0" />
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="field-group">
                                    <div class="field-label">MAX DISCOUNT CAP</div>
                                    <asp:TextBox ID="txtMaxDiscount" runat="server" CssClass="field-input" placeholder="500" />
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="field-group">
                                    <div class="field-label">VALID FROM</div>
                                    <asp:TextBox ID="txtValidFrom" runat="server" TextMode="Date" CssClass="field-input" />
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="field-group">
                                    <div class="field-label">VALID TO</div>
                                    <asp:TextBox ID="txtValidTo" runat="server" TextMode="Date" CssClass="field-input" />
                                </div>
                            </div>
                        </div>

                        <div class="toggle-row">
                            <span style="font-weight:600">Offer Active Status</span>
                            <label class="toggle-switch">
                                <asp:CheckBox ID="chkActive" runat="server" Checked="true" />
                                <span class="toggle-slider"></span>
                            </label>
                        </div>

                        <div class="divider-light"></div>
                        <div class="d-flex gap-3">
                            <asp:Button ID="btnSaveOffer" runat="server" Text="Publish Offer"
                                CssClass="btn-primary" OnClick="btnSaveOffer_Click" ValidationGroup="Save" />
                            <asp:Button ID="btnClear" runat="server" Text="Clear Form"
                                CssClass="btn-secondary" OnClick="btnClear_Click" CausesValidation="false" />
                        </div>
                    </div>
                </div>

                <div class="col-lg-5">
                    <div class="premium-card">
                        <div style="font-size:0.7rem;opacity:0.6;letter-spacing:0.1em;margin-bottom:12px;">LIVE PREVIEW</div>
                        <div class="preview-prefix" id="pvPrefix">0000</div>
                        <div class="preview-pct mt-2"><span id="pvPct">0</span>% OFF</div>
                        <div class="mt-2 mb-3" id="pvName" style="font-size:0.9rem;opacity:0.8">Offer Name</div>
                        <div class="divider-light" style="background:rgba(255,255,255,0.1)"></div>
                        <div class="row mt-3">
                            <div class="col-6"><small style="opacity:0.5">MIN BILL</small><div><strong id="pvMin">0</strong></div></div>
                            <div class="col-6"><small style="opacity:0.5">MAX CAP</small><div><strong id="pvMax">—</strong></div></div>
                        </div>
                        <div class="row mt-2">
                            <div class="col-6"><small style="opacity:0.5">DAILY LIMIT</small><div><strong id="pvLimit">Unlimited</strong></div></div>
                            <div class="col-6"><small style="opacity:0.5">VALID DAYS</small><div><strong id="pvDays">Any day</strong></div></div>
                        </div>
                        <div class="mt-3">
                            <span class="badge-status" id="pvStatus" style="background:rgba(251,191,36,0.2);color:#fbbf24">● ACTIVE</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ══════════════════════════════════════════════════════════
             TAB 2 — ASSIGN TO DEPARTMENT  (simplified, checkbox-based)
        ══════════════════════════════════════════════════════════ -->
        <div class="tab-panel" id="panelAssign">
            <div class="row g-4">

                <!-- STEP 1: Search & pick offer -->
                <div class="col-lg-5">
                    <div class="glass-panel p-4">
                        <h5 class="mb-3"><i class="fa fa-magnifying-glass me-2"></i> Step 1 — Find Offer</h5>
                        <div class="d-flex gap-2 mb-3">
                            <asp:TextBox ID="txtSearchOffer" runat="server" CssClass="field-input"
                                placeholder="Search by name, code or prefix…" />
                            <asp:Button ID="btnSearchOffer" runat="server" Text="Search"
                                CssClass="btn-search px-4" OnClick="btnSearchOffer_Click" CausesValidation="false" />
                        </div>

                        <asp:Panel ID="pnlSearchResults" runat="server" Visible="false">
                            <div style="max-height:380px;overflow-y:auto;">
                                <asp:Repeater ID="rptOfferResults" runat="server"
                                    OnItemCommand="rptOfferResults_ItemCommand">
                                    <ItemTemplate>
                                        <div class="offer-result-card">
                                            <div class="fw-bold"><%# Eval("offer_name") %></div>
                                            <div class="small text-muted mt-1">
                                                Code: <strong><%# Eval("offer_code") %></strong> &nbsp;|&nbsp;
                                                Prefix: <strong><%# Eval("card_prefix") %></strong> &nbsp;|&nbsp;
                                                <strong><%# Eval("discount_percent") %>%</strong> OFF
                                            </div>
                                            <asp:LinkButton ID="lbSelect" runat="server"
                                                CommandName="Select"
                                                CommandArgument='<%# Eval("offer_id") %>'
                                                CssClass="btn btn-sm btn-dark mt-2 px-3 rounded-pill">
                                                <i class="fa fa-check me-1"></i> Select this offer
                                            </asp:LinkButton>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </asp:Panel>

                        <asp:Panel ID="pnlNoResult" runat="server" Visible="false">
                            <div class="text-center p-4 text-muted">
                                <i class="fa fa-inbox fa-2x mb-2 d-block"></i>No offers found
                            </div>
                        </asp:Panel>
                    </div>

                    <!-- Selected offer banner -->
                    <asp:Panel ID="pnlSelectedOffer" runat="server" Visible="false">
                        <div class="selected-offer-banner mt-3">
                            <div class="d-flex align-items-start justify-content-between">
                                <div>
                                    <div class="small mb-1" style="opacity:0.6;letter-spacing:0.08em;font-size:0.7rem;">SELECTED OFFER</div>
                                    <div class="fw-bold fs-6">
                                        <asp:Label ID="lblSelOfferName" runat="server" />
                                    </div>
                                    <div class="small mt-1" style="opacity:0.7">
                                        Prefix: <asp:Label ID="lblSelPrefix" runat="server" /> &nbsp;•&nbsp;
                                        <asp:Label ID="lblSelDiscount" runat="server" />% OFF
                                    </div>
                                    <%-- Hidden labels used by CS code only --%>
                                    <asp:Label ID="lblSelOfferId"   runat="server" Visible="false" />
                                    <asp:Label ID="lblSelOfferCode" runat="server" Visible="false" />
                                </div>
                                <span class="offer-tag">✓ Ready</span>
                            </div>
                        </div>
                    </asp:Panel>
                </div>

                <!-- STEP 2: Pick departments (checkboxes) + assign button -->
                <div class="col-lg-7">
                    <asp:Panel ID="pnlDeptAssign" runat="server" Visible="false">
                        <div class="glass-panel p-4">
                            <h5 class="mb-1"><i class="fa fa-building me-2"></i> Step 2 — Select Department(s)</h5>
                            <p class="text-muted small mb-3">Tick one or more departments. If multiple are selected the offer will be cloned for each additional department.</p>

                            <!-- Select All / Clear All quick links -->
                            <div class="mb-2 d-flex gap-3">
                                <a href="#" onclick="selectAllDepts(true);return false;"
                                   class="small text-decoration-none" style="color:#2c3e4e;font-weight:600;">
                                    <i class="fa fa-check-double me-1"></i>Select All
                                </a>
                                <a href="#" onclick="selectAllDepts(false);return false;"
                                   class="small text-decoration-none text-muted">
                                    <i class="fa fa-xmark me-1"></i>Clear All
                                </a>
                            </div>

                            <div class="dept-checkbox-grid" id="deptGrid">
                                <%-- CheckBoxList rendered as styled items via JS wrapper --%>
                                <asp:CheckBoxList ID="cblDepartments" runat="server"
                                    RepeatLayout="Flow"
                                    CssClass="dept-cbl" />
                            </div>

                            <div class="mt-4">
                                <asp:Button ID="btnAssignSave" runat="server"
                                    Text="Assign to Selected Departments"
                                    CssClass="btn-primary"
                                    OnClick="btnAssignSave_Click" CausesValidation="false" />
                            </div>
                        </div>
                    </asp:Panel>

                    <!-- Placeholder when no offer selected yet -->
                    <div id="deptPlaceholder" class="glass-panel p-5 text-center text-muted h-100 d-flex align-items-center justify-content-center"
                         style="min-height:200px;">
                        <div>
                            <i class="fa fa-arrow-left fa-2x mb-3 d-block" style="opacity:0.3"></i>
                            Search and select an offer first, then pick departments here.
                        </div>
                    </div>
                </div>

            </div>
        </div>

        <!-- ══════════════════════════════════════════════════════════
             TAB 3 — VIEW ALL OFFERS
        ══════════════════════════════════════════════════════════ -->
        <div class="tab-panel" id="panelViewOffers">
            <div class="glass-panel p-4">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h5 class="mb-0"><i class="fa fa-list me-2"></i> All Offers</h5>
                  <%--  <asp:Button ID="btnRefreshGrid" runat="server" Text="↻ Refresh"
                        CssClass="btn-search px-4 py-2" OnClick="btnRefreshGrid_Click" CausesValidation="false" />--%>
                </div>
                <asp:GridView ID="gvOffers" runat="server" AutoGenerateColumns="False"
                    CssClass="offers-table" GridLines="None"
                    OnRowCommand="gvOffers_RowCommand"
                    OnPageIndexChanging="gvOffers_PageIndexChanging"
                    AllowPaging="True" PageSize="10">
                    <Columns>
                        <asp:BoundField DataField="offer_id"        HeaderText="ID" />
                        <asp:BoundField DataField="offer_name"      HeaderText="Offer Name" />
                        <asp:BoundField DataField="offer_code"      HeaderText="Code" />
                        <asp:BoundField DataField="card_prefix"     HeaderText="Prefix" />
                        <asp:BoundField DataField="discount_percent" HeaderText="%" />
                        <asp:BoundField DataField="min_bill_amount" HeaderText="Min Bill" DataFormatString="{0:N0}" />
                        <asp:BoundField DataField="dept_name"       HeaderText="Department(s)" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='badge-status <%# (bool)Eval("is_active") ? "badge-active" : "badge-inactive" %>'>
                                    <%# (bool)Eval("is_active") ? "ACTIVE" : "INACTIVE" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkToggle" runat="server"
                                    CommandName="ToggleStatus"
                                    CommandArgument='<%# Eval("offer_id") %>'
                                    CssClass="btn btn-sm btn-outline-dark rounded-pill me-1"
                                    Text='<%# (bool)Eval("is_active") ? "Deactivate" : "Activate" %>' />
                                <asp:LinkButton ID="lnkDelete" runat="server"
                                    CommandName="DeleteOffer"
                                    CommandArgument='<%# Eval("offer_id") %>'
                                    CssClass="btn btn-sm btn-outline-danger rounded-pill"
                                    Text="Delete"
                                    OnClientClick="return confirm('Delete this offer?');" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <PagerStyle CssClass="pagination justify-content-center pt-3" />
                </asp:GridView>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // ── TAB SWITCHING ─────────────────────────────────────────────────────────
        function switchTab(tab) {
            ['new', 'assign', 'view'].forEach(function (t) {
                var panelMap = { new: 'panelNewOffer', assign: 'panelAssign', view: 'panelViewOffers' };
                var btnMap = { new: 'tabNewOffer', assign: 'tabAssign', view: 'tabViewOffers' };
                document.getElementById(panelMap[t]).classList.toggle('active', t === tab);
                document.getElementById(btnMap[t]).classList.toggle('active', t === tab);
            });
            document.getElementById('<%= hfActiveTab.ClientID %>').value = tab;

            // Show/hide dept placeholder based on whether an offer is already selected
            if (tab === 'assign') refreshDeptPlaceholder();
        }

        function refreshDeptPlaceholder() {
            var offerSelected = document.getElementById('<%= hfSearchedOfferId.ClientID %>').value !== '';
            var placeholder = document.getElementById('deptPlaceholder');
            if (placeholder) placeholder.style.display = offerSelected ? 'none' : '';
        }

        // ── PREFIX ENFORCEMENT ────────────────────────────────────────────────────
        var selectedDays = [];
        var currentPrefixLength = 4;

        function getExpectedLength() {
            var rb6 = document.getElementById('<%= rbPrefix6.ClientID %>');
        var rb8 = document.getElementById('<%= rbPrefix8.ClientID %>');
            if (rb6 && rb6.checked) return 6;
            if (rb8 && rb8.checked) return 8;
            return 4;
        }

        function updatePrefixUI() {
            currentPrefixLength = getExpectedLength();
            var hint = document.getElementById('prefixHint');
            var lenLabel = document.getElementById('prefixLenLabel');
            if (hint) hint.innerHTML = 'Enter comma-separated ' + currentPrefixLength + '-digit prefixes (each must be exactly ' + currentPrefixLength + ' digits)';
            if (lenLabel) lenLabel.innerText = currentPrefixLength;
            var inp = document.getElementById('<%= txtCardPrefix.ClientID %>');
            if (inp) { inp.value = ''; inp.classList.remove('prefix-invalid'); }
            hidePrefixError();
            updatePreview();
        }

        function showPrefixError() {
            document.getElementById('prefixErrorMsg').style.display = 'block';
            document.getElementById('<%= txtCardPrefix.ClientID %>').classList.add('prefix-invalid');
        }
        function hidePrefixError() {
            document.getElementById('prefixErrorMsg').style.display = 'none';
            var inp = document.getElementById('<%= txtCardPrefix.ClientID %>');
            if (inp) inp.classList.remove('prefix-invalid');
        }

        function validateAndCleanPrefixInput(el) {
            var len = currentPrefixLength;
            var tokens = el.value.split(/[,\s]+/);
            var cleaned = [], hasError = false;
            tokens.forEach(function (t) {
                t = t.replace(/\D/g, '');
                if (!t) return;
                if (t.length > len) t = t.substring(0, len);
                cleaned.push(t);
                if (t.length !== len) hasError = true;
            });
            el.value = cleaned.join(', ');
            if (hasError && cleaned.length) showPrefixError(); else hidePrefixError();
            updatePreview();
        }

        function attachPrefixEvents() {
            var inp = document.getElementById('<%= txtCardPrefix.ClientID %>');
            if (!inp) return;

            inp.onkeydown = function (e) {
                var key = e.key;
                var ok = (key === 'Backspace' || key === 'Delete' || key === 'ArrowLeft' || key === 'ArrowRight' ||
                    key === 'Home' || key === 'End' || key === 'Tab' || key === ',' || key === ' ' || (key >= '0' && key <= '9'));
                if (!ok) { e.preventDefault(); return; }

                if (key >= '0' && key <= '9') {
                    var ss = inp.selectionStart, se = inp.selectionEnd;
                    var val = inp.value;
                    var bef = val.substring(0, ss);
                    var seg = bef.split(/[,\s]+/);
                    var cur = seg[seg.length - 1].replace(/\D/g, '');
                    if (cur.length >= currentPrefixLength && ss === se) {
                        e.preventDefault();
                        inp.value = val.substring(0, ss) + ', ' + key + val.substring(se);
                        var np = ss + 3;
                        inp.setSelectionRange(np, np);
                        hidePrefixError();
                        updatePreview();
                    }
                }
            };
            inp.oninput = function () { validateAndCleanPrefixInput(this); };
            inp.onblur = function () { validateAndCleanPrefixInput(this); };
        }

        // ── WEEKDAY CHIPS ─────────────────────────────────────────────────────────
        function toggleDay(el) {
            var val = el.getAttribute('data-val');
            var idx = selectedDays.indexOf(val);
            if (idx >= 0) { selectedDays.splice(idx, 1); el.classList.remove('selected'); }
            else { selectedDays.push(val); el.classList.add('selected'); }
            document.getElementById('<%= hfSelectedDays.ClientID %>').value = selectedDays.join(',');
        updatePreview();
    }

    function clearAllDays() {
        selectedDays = [];
        document.querySelectorAll('.day-chip').forEach(function(c){ c.classList.remove('selected'); });
        document.getElementById('<%= hfSelectedDays.ClientID %>').value = '';
        updatePreview();
    }

    // ── DEPT CHECKBOX STYLING (wraps ASP.NET CheckBoxList items) ─────────────
    function styleDeptCheckboxes() {
        // CheckBoxList emits <span><input><label> pairs — wrap each in a styled div
        var container = document.querySelector('.dept-cbl');
        if (!container) return;
        var spans = container.querySelectorAll('span');
        spans.forEach(function(span) {
            var inp = span.querySelector('input[type="checkbox"]');
            var lbl = span.querySelector('label');
            if (!inp || !lbl) return;
            var wrap = document.createElement('div');
            wrap.className = 'dept-checkbox-item' + (inp.checked ? ' checked-item' : '');
            span.parentNode.insertBefore(wrap, span);
            wrap.appendChild(inp);
            wrap.appendChild(lbl);
            span.remove();
            // Toggle styling on change
            inp.addEventListener('change', function() {
                wrap.classList.toggle('checked-item', inp.checked);
            });
        });
        // Move all .dept-checkbox-item into .dept-checkbox-grid
        var grid = document.getElementById('deptGrid');
        if (!grid) return;
        container.querySelectorAll('.dept-checkbox-item').forEach(function(item) {
            grid.appendChild(item);
        });
    }

    function selectAllDepts(state) {
        document.querySelectorAll('.dept-checkbox-item input[type="checkbox"]').forEach(function(cb) {
            cb.checked = state;
            cb.closest('.dept-checkbox-item').classList.toggle('checked-item', state);
        });
    }

    // ── LIVE PREVIEW ──────────────────────────────────────────────────────────
    function updatePreview() {
        var name     = (document.getElementById('<%= txtOfferName.ClientID %>')?.value)     || 'Offer Name';
        var prefInp  =  document.getElementById('<%= txtCardPrefix.ClientID %>');
        var prefix   = prefInp && prefInp.value ? (prefInp.value.split(',')[0].trim() || '0000') : '0000';
        var pct      = (document.getElementById('<%= txtDiscountPercent.ClientID %>')?.value) || '0';
        var minBill  = (document.getElementById('<%= txtMinBill.ClientID %>')?.value)         || '0';
        var maxDisc  = (document.getElementById('<%= txtMaxDiscount.ClientID %>')?.value)     || '—';
        var perDay   = (document.getElementById('<%= txtPerDayLimit.ClientID %>')?.value)     || '0';
        var active   =  document.getElementById('<%= chkActive.ClientID %>')?.checked;
        var daysMap  = {1:'Mon',2:'Tue',3:'Wed',4:'Thu',5:'Fri',6:'Sat',7:'Sun'};
        var daysStr  = selectedDays.length ? selectedDays.map(function(d){return daysMap[d];}).join(', ') : 'Any day';

        function set(id, v) { var e = document.getElementById(id); if(e) e.innerText = v; }
        set('pvName',  name);
        set('pvPrefix',prefix);
        set('pvPct',   pct);
        set('pvMin',   minBill);
        set('pvMax',   maxDisc || '—');
        set('pvLimit', (perDay==='0'||perDay==='') ? 'Unlimited' : perDay+'/day');
        set('pvDays',  daysStr);
        var ps = document.getElementById('pvStatus');
        if (ps) {
            ps.innerText        = active ? '● ACTIVE' : '● INACTIVE';
            ps.style.background = active ? 'rgba(251,191,36,0.2)' : 'rgba(156,163,175,0.2)';
            ps.style.color      = active ? '#fbbf24' : '#9ca3af';
        }
    }

    // ── ALERT ─────────────────────────────────────────────────────────────────
    function showAlert(type, message) {
        var s = document.getElementById('alertMessage');
        var er= document.getElementById('alertError');
        if (type === 'success') {
            document.getElementById('successMsg').innerText = message;
            s.style.display = 'flex'; er.style.display = 'none';
            setTimeout(function(){ s.style.display='none'; }, 5000);
        } else {
            document.getElementById('errorMsg').innerText = message;
            er.style.display= 'flex'; s.style.display = 'none';
            setTimeout(function(){ er.style.display='none'; }, 5000);
        }
    }

    // ── INIT ──────────────────────────────────────────────────────────────────
    document.addEventListener('DOMContentLoaded', function() {
        // Radio buttons
        ['<%= rbPrefix4.ClientID %>','<%= rbPrefix6.ClientID %>','<%= rbPrefix8.ClientID %>'].forEach(function(id){
            var el = document.getElementById(id);
            if (el) el.addEventListener('change', updatePrefixUI);
        });

        updatePrefixUI();
        attachPrefixEvents();
        styleDeptCheckboxes();

        // Preview inputs
        ['<%= txtOfferName.ClientID %>','<%= txtDiscountPercent.ClientID %>',
         '<%= txtMinBill.ClientID %>','<%= txtMaxDiscount.ClientID %>','<%= txtPerDayLimit.ClientID %>'].forEach(function(id) {
            var el = document.getElementById(id);
            if (el) { el.addEventListener('input', updatePreview); el.addEventListener('change', updatePreview); }
        });
        var chk = document.getElementById('<%= chkActive.ClientID %>');
        if (chk) chk.addEventListener('change', updatePreview);

        updatePreview();

        // Restore tab after postback
        var activeTab = document.getElementById('<%= hfActiveTab.ClientID %>').value || 'new';
        switchTab(activeTab);

        // Show/hide dept placeholder
        refreshDeptPlaceholder();
    });
    </script>
</asp:Content>

