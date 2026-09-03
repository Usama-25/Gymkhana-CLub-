<%@ page title="" language="C#" MasterPageFile="~/MasterPages/GymkhanaMaster.master" autoeventwireup="true" inherits="Store_Add_Unit" 
    CodeFile="ResturantMenusetup.aspx.cs" enableEventValidation="false"  viewStateEncryptionMode="Never" maintainScrollPositionOnPostBack="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700;800;900&family=Geist+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        /* ═══════════════════════════════════════════
           VARIABLES - Matches Finance.aspx
        ═══════════════════════════════════════════ */
        :root {
            --ink: #0A0F1E;
            --blue: #1845D4;
            --blue-light: #EEF3FF;
            --blue-dark: #0F2D8A;
            --blue-mid: #4070F4;
            --surface: #F4F6FB;
            --line: #DDE3EF;
            --line-mid: #C8D0E0;
            --muted: #7A85A0;
            --green: #0E9E52;
            --green-light: #EDFAF4;
            --green-dark: #075C30;
            --amber: #D4820A;
            --amber-light: #FFF8ED;
            --red: #D42B2B;
            --red-light: #FFF0F0;
            --purple: #6B35D4;
            --purple-light: #F3EEFF;
            --teal: #0A9E8E;
            --sh1: 0 1px 3px rgba(10,15,30,.07),0 1px 2px rgba(10,15,30,.05);
            --sh2: 0 4px 12px rgba(10,15,30,.08),0 2px 4px rgba(10,15,30,.05);
            --sh4: 0 24px 48px rgba(10,15,30,.12);
            --r: 10px;
            --r-sm: 7px;
            --r-lg: 14px;
            --r-xl: 18px;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body, .content-wrapper, .wrapper {
            font-family: 'Geist', system-ui, sans-serif !important;
            background: var(--surface) !important;
            color: var(--ink) !important;
            font-size: 13.5px;
            line-height: 1.5;
        }
        
        ::-webkit-scrollbar {
            width: 5px;
            height: 5px;
        }
        ::-webkit-scrollbar-track {
            background: transparent;
        }
        ::-webkit-scrollbar-thumb {
            background: var(--line-mid);
            border-radius: 5px;
        }
        
        /* Page Layout */
        .rc-page {
            width: 100%;
            max-width: 100%;
            margin: 0;
            padding: 18px 20px;
            background: var(--surface);
        }
        
        /* Page Header - Finance.aspx Style */
        .page-hdr {
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: var(--ink);
            padding: 0 22px;
            height: 56px;
            border-radius: var(--r-lg);
            margin-bottom: 18px;
            box-shadow: 0 4px 18px rgba(10,15,30,.2);
        }
        .page-hdr-brand {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .phdr-icon {
            width: 34px;
            height: 34px;
            background: linear-gradient(135deg, var(--blue), var(--blue-mid));
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 15px;
            color: white;
            box-shadow: 0 4px 10px rgba(24,69,212,.4);
        }
        .phdr-name {
            color: white;
            font-size: .9rem;
            font-weight: 800;
            letter-spacing: -.3px;
        }
        .phdr-sub {
            color: rgba(255,255,255,.38);
            font-size: .62rem;
            letter-spacing: .8px;
            text-transform: uppercase;
        }
        .sel-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(255,255,255,.08);
            border: 1px solid rgba(255,255,255,.12);
            color: rgba(255,255,255,.7);
            border-radius: 100px;
            padding: 4px 13px;
            font-size: .72rem;
            font-weight: 600;
            font-family: 'Geist Mono', monospace;
        }
        
        /* Card Component */
        .card {
            background: white;
            border-radius: var(--r-lg);
            box-shadow: var(--sh1);
            border: 1px solid var(--line);
            margin-bottom: 16px;
            overflow: hidden;
        }
        .card-head {
            background: linear-gradient(to right, #F7F9FF, white);
            padding: 11px 18px;
            border-bottom: 1px solid var(--line);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .card-head h3 {
            font-size: .88rem;
            font-weight: 800;
            color: var(--ink);
            display: flex;
            align-items: center;
            gap: 7px;
            margin: 0;
        }
        .card-head h3 i {
            color: var(--blue);
            font-size: 13px;
        }
        .card-body {
            padding: 20px 24px;
        }
        
        /* Tabs */
        .tabs-row {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            margin-bottom: 20px;
            border-bottom: 1px solid var(--line);
            padding-bottom: 12px;
        }
        .tab-btn {
            padding: 8px 20px;
            background: white;
            border: 1.5px solid var(--line);
            border-radius: 100px;
            font-family: 'Geist', sans-serif;
            font-weight: 600;
            font-size: 12px;
            color: var(--muted);
            cursor: pointer;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .tab-btn:hover {
            border-color: var(--blue);
            color: var(--blue);
            background: var(--blue-light);
        }
        .tab-btn.active {
            background: var(--blue);
            border-color: var(--blue);
            color: white;
            box-shadow: 0 2px 8px rgba(24,69,212,.25);
        }
        .tab-content {
            display: none;
        }
        
        /* Form Elements */
        .section-title {
            font-size: .75rem;
            font-weight: 800;
            color: var(--ink);
            margin: 0 0 16px;
            display: flex;
            align-items: center;
            gap: 8px;
            padding-bottom: 8px;
            border-bottom: 2px solid var(--blue);
            width: fit-content;
        }
        .section-title i {
            color: var(--blue);
        }
        
        .field-label {
            font-size: .67rem;
            font-weight: 800;
            color: #475569;
            text-transform: uppercase;
            letter-spacing: .8px;
            display: flex;
            align-items: center;
            gap: 5px;
            margin-bottom: 5px;
        }
        .field-label i {
            color: var(--blue);
            font-size: 10px;
        }
        
        .field-input, .field-select {
            width: 100%;
            padding: 9px 13px;
            border: 1.5px solid var(--line);
            border-radius: var(--r-sm);
            font-family: 'Geist', system-ui, sans-serif;
            font-size: 13px;
            color: var(--ink);
            background: white;
            transition: all .2s;
            box-shadow: var(--sh1);
            height: 40px;
            box-sizing: border-box;
        }
        
        .field-select {
            cursor: pointer;
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%237A85A0' stroke-width='1.8' fill='none' stroke-linecap='round'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 13px center;
            background-size: 12px;
            padding-right: 34px;
        }
        
        .field-input:focus, .field-select:focus {
            border-color: var(--blue);
            outline: none;
            box-shadow: 0 0 0 3px rgba(24,69,212,.1);
        }
        
        .input-row {
            display: flex;
            gap: 12px;
            align-items: flex-end;
            margin-bottom: 16px;
        }
        .input-row .field-input {
            flex: 1;
        }
        
        /* Buttons */
        .btn-save {
            padding: 0 24px;
            height: 40px;
            background: var(--blue);
            color: white;
            border: none;
            border-radius: var(--r-sm);
            font-weight: 700;
            font-size: 12px;
            cursor: pointer;
            transition: all .2s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-family: 'Geist', sans-serif;
            box-shadow: 0 2px 8px rgba(24,69,212,.22);
        }
        .btn-save:hover {
            background: var(--blue-dark);
            transform: translateY(-1px);
        }
        .btn-green {
            background: var(--green);
            box-shadow: 0 2px 8px rgba(14,158,82,.22);
        }
        .btn-green:hover {
            background: var(--green-dark);
        }
        .btn-blue {
            background: #0284C7;
            box-shadow: 0 2px 8px rgba(2,132,199,.22);
        }
        .btn-blue:hover {
            background: #0369A1;
        }
        
        /* Form Grids */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 20px;
        }
        .cols-4 { grid-template-columns: repeat(4, 1fr); }
        
        @media (max-width: 768px) {
            .form-grid, .cols-4 { grid-template-columns: repeat(2, 1fr); }
        }
        @media (max-width: 480px) {
            .form-grid, .cols-4 { grid-template-columns: 1fr; }
        }
        
        .field-col { display: flex; flex-direction: column; gap: 5px; }
        
        /* Messages */
        .message, .success-message, .error-message {
            padding: 10px 16px;
            border-radius: var(--r-sm);
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 16px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        .success-message, .sd-msg-success {
            background: var(--green-light);
            color: var(--green-dark);
            border: 1px solid #A7F3D0;
        }
        .error-message, .sd-msg-error {
            background: var(--red-light);
            color: var(--red);
            border: 1px solid #FECACA;
        }
        
        /* GridViews */
        .gv-custom, .modern-grid {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
            margin-top: 16px;
        }
        .gv-custom th, .modern-grid th {
            background: linear-gradient(to right, #F0F4FF, #F7F9FF);
            padding: 10px 14px;
            font-size: .64rem;
            font-weight: 800;
            color: #475569;
            text-transform: uppercase;
            letter-spacing: .7px;
            border-bottom: 2px solid var(--line);
            text-align: left;
        }
        .gv-custom td, .modern-grid td {
            padding: 10px 14px;
            border-bottom: 1px solid #F0F4FA;
            vertical-align: middle;
        }
        .gv-custom tr:hover td, .modern-grid tr:hover td {
            background: #F7F9FF;
        }
        .modern-grid tr.row-checked td {
            background: var(--green-light);
        }
        
        /* Grid Inputs */
        .grid-input {
            width: 80px;
            padding: 6px 8px;
            border: 1.5px solid var(--line);
            border-radius: var(--r-sm);
            text-align: center;
            font-family: 'Geist Mono', monospace;
            font-size: 12px;
            background: white;
        }
        .grid-input:focus {
            border-color: var(--blue);
            outline: none;
        }
        .grid-input.gst-input {
            border-color: var(--amber);
            background: var(--amber-light);
        }
        .grid-input.desc-input {
            width: 160px;
            text-align: left;
        }
        .cost-cell-live {
            width: 90px;
            padding: 6px 8px;
            border: 1.5px solid rgba(14,158,82,0.4);
            border-radius: var(--r-sm);
            text-align: center;
            background: var(--green-light);
            color: var(--green-dark);
            font-weight: 700;
            font-family: 'Geist Mono', monospace;
        }
        
        /* Dropdown Lock Styles */
        .ddl-locked {
            border-color: var(--green) !important;
            background: var(--green-light) !important;
        }
        .ddl-editable {
            border-color: var(--blue) !important;
            background: var(--blue-light) !important;
        }
        .ddl-status {
            font-size: 10px;
            margin-top: 4px;
        }
        .ddl-status.ok { color: var(--green); }
        .ddl-status.warn { color: var(--amber); }
        
        /* Special Components */
        .dropdown-row {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
            margin: 16px 0 20px;
        }
        @media (max-width: 640px) {
            .dropdown-row { grid-template-columns: 1fr; }
        }
        
        .gst-apply-bar, .set-price-bar {
            display: flex;
            align-items: center;
            gap: 12px;
            background: var(--surface);
            border: 1px solid var(--line);
            border-radius: var(--r);
            padding: 12px 16px;
            margin-bottom: 16px;
            flex-wrap: wrap;
        }
        .gst-global-input, .set-price-input {
            width: 100px;
            padding: 8px 12px;
            border: 1.5px solid var(--line);
            border-radius: var(--r-sm);
            font-family: 'Geist Mono', monospace;
            text-align: center;
        }
        .btn-apply-gst, .btn-set-price {
            padding: 0 16px;
            height: 36px;
            background: var(--amber);
            color: white;
            border: none;
            border-radius: 100px;
            font-weight: 700;
            font-size: 11px;
            cursor: pointer;
            transition: all .2s;
        }
        .btn-apply-gst:hover, .btn-set-price:hover {
            background: var(--green-dark);
            transform: translateY(-1px);
        }
        
        .recipe-weight-panel {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
            margin: 16px 0 20px;
            padding: 16px;
            background: var(--surface);
            border-radius: var(--r);
            border: 1px solid var(--line);
        }
        @media (max-width: 640px) {
            .recipe-weight-panel { grid-template-columns: 1fr; }
        }
        
        .selected-item-bar {
            background: var(--green-light);
            border: 1px solid #A7F3D0;
            border-radius: var(--r);
            padding: 12px 16px;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }
        
        .toggle-row {
            display: flex;
            align-items: center;
            gap: 20px;
            margin: 16px 0;
            flex-wrap: wrap;
        }
        .switch-wrap {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: var(--surface);
            border: 1px solid var(--line);
            border-radius: 100px;
            padding: 6px 16px;
        }
        .switch-modern {
            position: relative;
            display: inline-block;
            width: 46px;
            height: 24px;
        }
        .switch-modern input {
            opacity: 0;
            width: 0;
            height: 0;
        }
        .slider-modern {
            position: absolute;
            cursor: pointer;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: #CBD5E0;
            border-radius: 24px;
            transition: 0.3s;
        }
        .slider-modern:before {
            position: absolute;
            content: "";
            height: 18px;
            width: 18px;
            left: 3px;
            bottom: 3px;
            background: white;
            border-radius: 50%;
            transition: 0.3s;
        }
        input:checked + .slider-modern {
            background: var(--blue);
        }
        input:checked + .slider-modern:before {
            transform: translateX(22px);
        }
        
        .live-cost-box, .tax-box, .total-box {
            padding: 8px 16px;
            border-radius: var(--r);
            min-width: 120px;
        }
        .live-cost-box { background: var(--amber-light); }
        .tax-box { background: var(--blue-light); }
        .total-box { background: var(--green-light); }
        .cost-value {
            font-size: 1.4rem;
            font-weight: 800;
            font-family: 'Geist Mono', monospace;
        }
        .cost-label {
            font-size: 10px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--muted);
        }
        
        .save-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: var(--surface);
            border: 1px solid var(--line);
            border-radius: var(--r);
            padding: 14px 20px;
            margin-top: 20px;
            flex-wrap: wrap;
            gap: 12px;
        }
        
        .chk-select-all {
            width: 16px;
            height: 16px;
            accent-color: var(--blue);
        }
        .btn-view-report {
            background: var(--purple);
            box-shadow: 0 2px 8px rgba(107,53,212,.22);
        }
        .btn-view-report:hover {
            background: #5a2ab8;
        }
        
        .rc-divider {
            display: flex;
            align-items: center;
            gap: 12px;
            margin: 16px 0;
        }
        .rc-divider hr {
            flex: 1;
            border: none;
            border-top: 1px solid var(--line);
        }
        .rc-divider span {
            font-size: 10px;
            font-weight: 800;
            text-transform: uppercase;
            color: var(--muted);
        }
        
        .card-footer-strip {
            background: var(--surface);
            border-top: 1px solid var(--line);
            padding: 10px 20px;
            font-size: 11px;
            color: var(--muted);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .search-row {
            display: flex;
            align-items: flex-end;
            gap: 12px;
            margin-bottom: 16px;
            flex-wrap: wrap;
        }
        .search-wrap {
            flex: 1;
            min-width: 250px;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .rc-page { padding: 12px; }
            .page-hdr {
                flex-direction: column;
                height: auto;
                padding: 12px;
                gap: 10px;
                border-radius: var(--r);
            }
            .card-body { padding: 16px; }
            .tabs-row { gap: 6px; }
            .tab-btn { padding: 6px 14px; font-size: 11px; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>

    <asp:HiddenField ID="hdnSelectedOption"  runat="server" />
    <asp:HiddenField ID="hdnItemCode"        runat="server" />
    <asp:HiddenField ID="hdnSubMenuLocked"   runat="server" Value="0" />
    <asp:HiddenField ID="hdnMealTypeLocked"  runat="server" Value="0" />
    <asp:HiddenField ID="hdnCourseLocked"    runat="server" Value="0" />
    <asp:HiddenField ID="hdnLiveCost"        runat="server" Value="0" />

    <div class="rc-page">
        <!-- PAGE HEADER - Finance.aspx Style -->
        <div class="page-hdr">
            <div class="page-hdr-brand">
                <div class="phdr-icon"><i class="fa-solid fa-utensils"></i></div>
                <div>
                    <div class="phdr-name">Restaurant Menu Setup</div>
                    <div class="phdr-sub">Menu & Pricing Management</div>
                </div>
            </div>
            <div class="phdr-right">
                <div class="sel-pill">
                    <i class="fa-solid fa-scroll"></i>
                    Restaurant Configuration
                </div>
            </div>
        </div>

        <!-- MAIN CARD -->
        <div class="card">
            <div class="card-head">
                <h3><i class="fa-solid fa-burger"></i> Menu Configuration</h3>
            </div>
            <div class="card-body">
                <asp:Label ID="lblGlobalMessage" runat="server" CssClass="message" style="display:block;margin-bottom:1rem;"></asp:Label>

                <div class="tabs-row">
                    <button type="button" class="tab-btn" onclick="selectOption(this,'SubMenu')"><i class="fa-solid fa-list"></i> Sub Menu</button>
                    <button type="button" class="tab-btn" onclick="selectOption(this,'Course')"><i class="fa-solid fa-book"></i> Course</button>
                    <button type="button" class="tab-btn" onclick="selectOption(this,'MealType')"><i class="fa-solid fa-bowl-food"></i> Meal Type</button>
                    <button type="button" class="tab-btn" onclick="selectOption(this,'ItemGroup')"><i class="fa-solid fa-layer-group"></i> Item Group</button>
                    <button type="button" class="tab-btn" onclick="selectOption(this,'MenuItem')"><i class="fa-solid fa-tag"></i> Menu Item</button>
                </div>

                <!-- SUB MENU -->
                <div id="SubMenu" class="tab-content">
                    <div class="section-title"><i class="fa-solid fa-list"></i> Add Sub Menu</div>
                    <div class="input-row">
                        <asp:TextBox ID="txtSubMenuName" runat="server" CssClass="field-input" placeholder="Enter sub menu name..." />
                        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn-save" OnClick="btnSave_Click" />
                    </div>
                    <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>
                    <asp:GridView ID="gvSubMenu" runat="server" CssClass="gv-custom" AutoGenerateColumns="false">
                        <Columns>
                            <asp:BoundField DataField="Id" HeaderText="ID" />
                            <asp:BoundField DataField="SubMenu_Name" HeaderText="Sub Menu Name" />
                            <asp:BoundField DataField="Created" HeaderText="Created On" DataFormatString="{0:dd-MMM-yyyy}" />
                        </Columns>
                    </asp:GridView>
                </div>

                <!-- COURSE -->
                <div id="Course" class="tab-content">
                    <div class="section-title"><i class="fa-solid fa-book"></i> Add Course</div>
                    <div class="input-row">
                        <asp:TextBox ID="txtCourseName" runat="server" CssClass="field-input" placeholder="Enter course name..." />
                        <asp:Button ID="btnSaveCourse" runat="server" Text="Save" CssClass="btn-save" OnClick="btnSaveCourse_Click" />
                    </div>
                    <asp:Label ID="lblCourseMessage" runat="server" CssClass="message"></asp:Label>
                    <asp:GridView ID="gvCourses" runat="server" CssClass="gv-custom" AutoGenerateColumns="false">
                        <Columns>
                            <asp:BoundField DataField="Courseid" HeaderText="ID" />
                            <asp:BoundField DataField="Course_Name" HeaderText="Course Name" />
                            <asp:BoundField DataField="Created" HeaderText="Created On" DataFormatString="{0:dd-MMM-yyyy}" />
                        </Columns>
                    </asp:GridView>
                </div>

                <!-- MEAL TYPE -->
                <div id="MealType" class="tab-content">
                    <div class="section-title"><i class="fa-solid fa-bowl-food"></i> Add Meal Type</div>
                    <div class="input-row">
                        <asp:TextBox ID="txtMealTypeName" runat="server" CssClass="field-input" placeholder="Enter meal type name..." />
                        <asp:Button ID="btnSaveMealType" runat="server" Text="Save" CssClass="btn-save" OnClick="btnSaveMealType_Click" />
                    </div>
                    <asp:Label ID="lblMealTypeMessage" runat="server" CssClass="message"></asp:Label>
                    <asp:GridView ID="gvMealType" runat="server" CssClass="gv-custom" AutoGenerateColumns="false">
                        <Columns>
                            <asp:BoundField DataField="Id" HeaderText="ID" />
                            <asp:BoundField DataField="MealType_Name" HeaderText="Meal Type Name" />
                            <asp:BoundField DataField="Created" HeaderText="Created On" DataFormatString="{0:dd-MMM-yyyy}" />
                        </Columns>
                    </asp:GridView>
                </div>

                <!-- ITEM GROUP -->
                <div id="ItemGroup" class="tab-content">
                    <div class="section-title"><i class="fa-solid fa-layer-group"></i> Add Item Group</div>
                    <div class="form-grid cols-4">
                        <div class="field-col">
                            <div class="field-label"><i class="fa-solid fa-code"></i> Group Code</div>
                            <asp:TextBox ID="txtGroupCode" runat="server" CssClass="field-input" placeholder="Enter group code" />
                        </div>
                        <div class="field-col">
                            <div class="field-label"><i class="fa-solid fa-pen-line"></i> Description</div>
                            <asp:TextBox ID="txtDescription" runat="server" CssClass="field-input" placeholder="Enter description" />
                        </div>
                        <div class="field-col">
                            <div class="field-label"><i class="fa-solid fa-ruler"></i> Unit</div>
                            <asp:DropDownList ID="ddlUnit" runat="server" CssClass="field-select">
                                <asp:ListItem Text="Select Unit" Value="0"></asp:ListItem>
                                <asp:ListItem Text="KGS" Value="KGS"></asp:ListItem>
                                <asp:ListItem Text="PKT" Value="PKT"></asp:ListItem>
                                <asp:ListItem Text="BAG" Value="BAG"></asp:ListItem>
                                <asp:ListItem Text="TIN" Value="TIN"></asp:ListItem>
                                <asp:ListItem Text="BOTTLE" Value="BOTTLE"></asp:ListItem>
                                <asp:ListItem Text="JAR" Value="JAR"></asp:ListItem>
                                <asp:ListItem Text="BOX" Value="BOX"></asp:ListItem>
                                <asp:ListItem Text="GALLON" Value="GALLON"></asp:ListItem>
                                <asp:ListItem Text="NOS" Value="NOS"></asp:ListItem>
                                <asp:ListItem Text="LTR" Value="LTR"></asp:ListItem>
                                <asp:ListItem Text="GRM" Value="GRM"></asp:ListItem>
                                <asp:ListItem Text="ROLL" Value="ROLL"></asp:ListItem>
                                <asp:ListItem Text="BUNDLE" Value="BUNDLE"></asp:ListItem>
                                <asp:ListItem Text="DOZEN" Value="DOZEN"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="field-col">
                            <div class="field-label"><i class="fa-solid fa-circle-check"></i> Active</div>
                            <asp:CheckBox ID="chkActive" runat="server" Checked="true" />
                        </div>
                    </div>
                    <asp:Button ID="btnSaveGroup" runat="server" Text="Save Item Group" CssClass="btn-save" OnClick="btnSaveGroup_Click" />
                </div>

                <!-- MENU ITEM (CRITICAL - ALL FUNCTIONALITY PRESERVED) -->
                <div id="MenuItem" class="tab-content">
                    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
                    <script src="https://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.24/jquery-ui.min.js"></script>
                    <link href="https://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.24/themes/blitzer/jquery-ui.css" rel="stylesheet" />

                    <div class="section-title"><i class="fa-solid fa-tag"></i> Sub Department Pricing Setup</div>

                    <!-- SEARCH ROW -->
                    <div class="search-row">
                        <div class="search-wrap">
                            <div class="field-label"><i class="fa-solid fa-magnifying-glass"></i> Search Item</div>
                            <asp:TextBox ID="txtItem" runat="server" CssClass="field-input"
                                placeholder="Type item name or code then click Load Item..." />
                        </div>
                        <asp:Button ID="btnLoadItem" runat="server" Text="Load Item"
                            CssClass="btn-save btn-blue" OnClick="btnLoadItem_Click" />
                        
                        <asp:Button ID="btnViewReport" runat="server" Text="📄 View Report"
                            CssClass="btn-save btn-view-report" OnClick="btnViewReport_Click" 
                            OnClientClick="return validateBeforeReport();" />
                    </div>

                    <!-- Selected item badge -->
                    <asp:Panel ID="pnlItemBadge" runat="server" Visible="false" CssClass="selected-item-bar">
                        <i class="fa-solid fa-circle-check" style="color:var(--green);"></i>
                        <strong>Item Loaded:</strong>
                        <asp:Label ID="lblLoadedItem" runat="server" style="color:var(--green);font-weight:700;"></asp:Label>
                        &nbsp;|&nbsp; Code: <asp:Label ID="lblItemCode" runat="server" style="font-weight:700;"></asp:Label>
                        &nbsp;|&nbsp; <i class="fa-solid fa-calculator" style="color:var(--blue);"></i>
                        Live Cost (no tax): <strong style="color:var(--green);">&#8360; <asp:Label ID="lblServerLiveCost" runat="server" Text="0.00"></asp:Label></strong>
                    </asp:Panel>

                    <!-- RECIPE WEIGHT & PER PERSON SECTION -->
                    <div class="recipe-weight-panel">
                        <div class="field-col">
                            <div class="field-label"><i class="fa-solid fa-weight-scale"></i> Recipe Weight</div>
                            <asp:TextBox ID="txtRecipeWeight" runat="server" CssClass="field-input" placeholder="e.g. 250" />
                        </div>
                        <div class="field-col">
                            <div class="field-label"><i class="fa-solid fa-ruler"></i> Weight Unit</div>
                            <asp:DropDownList ID="ddlWeightUnit" runat="server" CssClass="field-select">
                                <asp:ListItem Text="-- Select Unit --" Value="0"></asp:ListItem>
                                <asp:ListItem Text="Grams (g)" Value="g"></asp:ListItem>
                                <asp:ListItem Text="Kilograms (kg)" Value="kg"></asp:ListItem>
                                <asp:ListItem Text="Milliliters (ml)" Value="ml"></asp:ListItem>
                                <asp:ListItem Text="Liters (L)" Value="L"></asp:ListItem>
                                <asp:ListItem Text="Ounces (oz)" Value="oz"></asp:ListItem>
                                <asp:ListItem Text="Pounds (lb)" Value="lb"></asp:ListItem>
                                <asp:ListItem Text="Piece(s)" Value="pcs"></asp:ListItem>
                                <asp:ListItem Text="Serving" Value="serving"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="field-col">
                            <div class="field-label"><i class="fa-solid fa-user"></i> Per Person</div>
                            <asp:TextBox ID="txtPerPerson" runat="server" CssClass="field-input" placeholder="e.g. 2" />
                        </div>
                    </div>

                   <%-- <!-- LIVE COST PANEL -->
                    <div id="liveCostPanel" style="display:none; margin:1rem 0; background:var(--surface); border-radius:var(--r); padding:1rem; border:2px solid var(--blue);">
                        <div class="field-label" style="color:var(--blue);"><i class="fa-solid fa-calculator"></i> Live Cost Breakdown</div>
                        <div style="display:flex; gap:1.5rem; flex-wrap:wrap; margin-top:0.5rem;">
                            <div class="live-cost-box">
                                <div class="cost-label"><i class="fa-solid fa-chart-simple"></i> LIVE COST</div>
                                <div class="cost-value" style="color:var(--blue);">&#8360; <span id="liveBaseCost">0.00</span></div>
                                <div style="font-size:0.65rem;">(Qty × Rate + Garnish + Topping + Wastage)</div>
                            </div>
                            <div class="tax-box">
                                <div class="cost-label"><i class="fa-solid fa-percent"></i> GST (16%)</div>
                                <div class="cost-value" style="color:var(--amber);font-size:1.4rem;">&#8360; <span id="liveGSTAmount">0.00</span></div>
                            </div>
                            <div class="total-box">
                                <div class="cost-label"><i class="fa-solid fa-receipt"></i> WITH TAX</div>
                                <div class="cost-value" style="color:var(--green);">&#8360; <span id="liveTotalWithTax">0.00</span></div>
                            </div>
                        </div>
                        <div style="margin-top:0.8rem; padding-top:0.8rem; border-top:1px dashed var(--line); font-size:0.7rem; color:var(--muted); cursor:pointer;" onclick="$('#ingGrid').toggle();">
                            <i class="fa-solid fa-list-ul"></i> View ingredients breakdown <i class="fa-solid fa-chevron-down"></i>
                        </div>
                        <div id="ingGrid" style="display:none; margin-top:0.6rem; max-height:260px; overflow-y:auto;">
                            <table class="gv-custom" style="width:100%; font-size:0.75rem;">
                                <thead>
                                    <tr>
                                        <th style="padding:6px;text-align:left;">Ingredient</th>
                                        <th style="padding:6px;text-align:center;">Qty</th>
                                        <th style="padding:6px;text-align:right;">Rate (per unit)</th>
                                        <th style="padding:6px;text-align:right;">Base Cost</th>
                                        <th style="padding:6px;text-align:center;">Garnish</th>
                                        <th style="padding:6px;text-align:center;">Topping</th>
                                        <th style="padding:6px;text-align:center;">Wastage</th>
                                        <th style="padding:6px;text-align:right;">Total</th>
                                    </tr>
                                </thead>
                                <tbody id="ingTableBody">
                                    <tr><td colspan="8" style="text-align:center;padding:10px;">Select an item first</td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>--%>

                    <!-- TOGGLE -->
                    <div class="toggle-row">
                        <div class="switch-wrap">
                            <span><i class="fa-solid fa-power-off"></i> Active / Deactive</span>
                            <label class="switch-modern">
                                <asp:CheckBox ID="chkIsSpecial" runat="server" AutoPostBack="true" OnCheckedChanged="chkIsSpecial_CheckedChanged" />
                                <span class="slider-modern"></span>
                            </label>
                        </div>
                        <button type="button" class="btn-apply-gst" onclick="refreshLiveCost();">
                            <i class="fa-solid fa-rotate-right"></i> Refresh Live Cost
                        </button>
                    </div>

                    <div class="rc-divider"><hr /><span>Pricing by Sub Department</span><hr /></div>

                    <!-- DROPDOWNS -->
                    <div class="dropdown-row">
                        <div class="field-col">
                            <div class="field-label"><i class="fa-solid fa-list"></i> Sub Menu <span style="color:red;">*</span></div>
                            <asp:DropDownList ID="ddlSubMenu" runat="server" CssClass="field-select"></asp:DropDownList>
                            <asp:Label ID="lblSubMenuStatus" runat="server" CssClass="ddl-status" Text=""></asp:Label>
                        </div>
                        <div class="field-col">
                            <div class="field-label"><i class="fa-solid fa-bowl-food"></i> Meal Type <span style="color:red;">*</span></div>
                            <asp:DropDownList ID="ddlMealType" runat="server" CssClass="field-select"></asp:DropDownList>
                            <asp:Label ID="lblMealTypeStatus" runat="server" CssClass="ddl-status" Text=""></asp:Label>
                        </div>
                        <div class="field-col">
                            <div class="field-label"><i class="fa-solid fa-book"></i> Course <span style="color:red;">*</span></div>
                            <asp:DropDownList ID="ddlCourse" runat="server" CssClass="field-select"></asp:DropDownList>
                            <asp:Label ID="lblCourseStatus" runat="server" CssClass="ddl-status" Text=""></asp:Label>
                        </div>
                    </div>

                    <!-- GST APPLY BAR -->
                    <div class="gst-apply-bar">
                        <div class="field-label" style="margin:0;"><i class="fa-solid fa-percent"></i> Apply GST % to All Rows</div>
                        <input type="text" id="txtGlobalGST" class="gst-global-input" placeholder="e.g. 16" maxlength="6"
                            oninput="this.value=this.value.replace(/[^0-9.]/g,'')" />
                        <button type="button" class="btn-apply-gst" onclick="applyGlobalGST();">
                            <i class="fa-solid fa-bolt"></i> Apply to All
                        </button>
                    </div>

                    <!-- SET PRICE BAR -->
                    <div class="set-price-bar">
                        <div class="field-label" style="margin:0;"><i class="fa-solid fa-tag"></i> Set Price to Checked Rows</div>
                        <input type="number" id="txtSetPrice" class="set-price-input" placeholder="e.g. 1500" min="0" step="0.01" />
                        <button type="button" class="btn-set-price" onclick="applySetPrice();">
                            <i class="fa-solid fa-check-double"></i> Apply to Checked
                        </button>
                        <span style="font-size:0.78rem;color:var(--muted);">Only applies to rows with checkbox ticked</span>
                    </div>

                    <!-- SUB DEPT GRID - ALL ORIGINAL PROPERTIES PRESERVED -->
                    <asp:GridView ID="gvSubDept" runat="server" DataKeyNames="SubDept_Id"
                        CssClass="modern-grid" AutoGenerateColumns="false">
                        <Columns>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <div style="display:flex;flex-direction:column;align-items:center;gap:4px;">
                                        <span style="font-size:0.65rem;letter-spacing:.05em;">ALL</span>
                                        <input type="checkbox" id="chkSelectAll" class="chk-select-all"
                                            title="Select / Deselect All" onclick="toggleSelectAll(this);" />
                                    </div>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:CheckBox ID="chkSelect" runat="server" AutoPostBack="false" />
                                    <asp:HiddenField ID="hdnSubDeptId" runat="server" Value='<%# Eval("SubDept_Id") %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="SubDept_Name" HeaderText="Sub Department" />
                            <asp:TemplateField HeaderText="Price">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtPrice" runat="server" CssClass="grid-input" placeholder="0.00" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Old Price">
    <ItemTemplate>
        <asp:TextBox ID="oldprice" runat="server" CssClass="grid-input" placeholder="0.00" />
    </ItemTemplate>
</asp:TemplateField>

                            <asp:TemplateField HeaderText="Live Cost (no tax)">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtCost" runat="server" CssClass="cost-cell-live" placeholder="0.00" ReadOnly="true" TabIndex="-1" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="GST %">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtGST" runat="server" CssClass="grid-input gst-input" Text="16" placeholder="16" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Description">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtRowDescription" runat="server" CssClass="grid-input desc-input" placeholder="Add description..." />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>

                    <!-- SAVE BAR -->
                    <div class="save-bar">
                        <div><strong id="saveBarInfo">Select an item and click Load Item to begin</strong></div>
                        <asp:Button ID="btnSaveMenuItems" runat="server" Text="Save Menu Items"
                            CssClass="btn-save btn-green" OnClick="btnSaveMenuItems_Click"
                            OnClientClick="return confirmSave();" />
                    </div>
                </div>
            </div>

            <div class="card-footer-strip">
                <i class="fa-solid fa-circle-info"></i>
                Live Cost = Σ(Qty × BaseCost from RecipeSub) + Garnish + Topping + Wastage from RecipeMain &nbsp;|&nbsp; With Tax = Live Cost + 16% GST
            </div>
        </div>
    </div>

    <!-- COMPLETE JAVASCRIPT - ALL ORIGINAL FUNCTIONS PRESERVED -->
    <script type="text/javascript">
        // Tab navigation - PRESERVED
        function selectOption(button, value) {
            document.querySelectorAll('.tab-btn').forEach(function (b) { b.classList.remove('active'); });
            button.classList.add('active');
            document.querySelectorAll('.tab-content').forEach(function (s) { s.style.display = 'none'; });
            document.getElementById(value).style.display = 'block';
            document.getElementById('<%= hdnSelectedOption.ClientID %>').value = value;
        }

        function validateBeforeReport() {
            var itemCode = document.getElementById('<%= hdnItemCode.ClientID %>').value;
            if (!itemCode || itemCode === '') {
                alert('Please load an item first before generating report.');
                return false;
            }
            return true;
        }

        window.onload = function () {
            var selected = document.getElementById('<%= hdnSelectedOption.ClientID %>').value;
            if (selected) {
                var btn = document.querySelector("button[onclick*='" + selected + "']");
                if (btn) selectOption(btn, selected);
                else selectOption(document.querySelector('.tab-btn'), 'SubMenu');
            } else {
                selectOption(document.querySelector('.tab-btn'), 'SubMenu');
            }

            applyDropdownLockStyles();
            highlightCheckedRows();
            syncSelectAllCheckbox();

            var loadedCode = document.getElementById('<%= hdnItemCode.ClientID %>').value;
            if (loadedCode && loadedCode !== '') {
                LoadItemLiveCost(loadedCode);
                updateSaveBarInfo();
                $('#liveCostPanel').show();
            } else {
                $('#liveCostPanel').hide();
            }
        };

        function applyDropdownLockStyles() {
            applyDdlStyle('<%= ddlSubMenu.ClientID %>', '<%= hdnSubMenuLocked.ClientID %>', '<%= lblSubMenuStatus.ClientID %>');
            applyDdlStyle('<%= ddlMealType.ClientID %>', '<%= hdnMealTypeLocked.ClientID %>', '<%= lblMealTypeStatus.ClientID %>');
            applyDdlStyle('<%= ddlCourse.ClientID %>', '<%= hdnCourseLocked.ClientID %>', '<%= lblCourseStatus.ClientID %>');
        }

        function applyDdlStyle(ddlId, hiddenId, statusLblId) {
            var ddl = document.getElementById(ddlId);
            var hidden = document.getElementById(hiddenId);
            if (!ddl || !hidden) return;
            var isLocked = (hidden.value === '1');
            ddl.classList.remove('ddl-locked', 'ddl-editable');
            ddl.classList.add(isLocked ? 'ddl-locked' : 'ddl-editable');
        }

        function highlightCheckedRows() {
            var rows = document.querySelectorAll('#<%= gvSubDept.ClientID %> tr');
            for (var i = 1; i < rows.length; i++) {
                var chk = rows[i].querySelector('input[type="checkbox"]');
                if (chk && chk.checked) rows[i].classList.add('row-checked');
                else if (chk) rows[i].classList.remove('row-checked');
            }
        }

        function toggleSelectAll(masterChk) {
            var rows = document.querySelectorAll('#<%= gvSubDept.ClientID %> tr');
            for (var i = 1; i < rows.length; i++) {
                var chk = rows[i].querySelector('input[type="checkbox"]');
                if (chk) {
                    chk.checked = masterChk.checked;
                    if (masterChk.checked) rows[i].classList.add('row-checked');
                    else rows[i].classList.remove('row-checked');
                }
            }
            updateSaveBarInfo();
        }

        function syncSelectAllCheckbox() {
            var masterChk = document.getElementById('chkSelectAll');
            if (!masterChk) return;
            var all = document.querySelectorAll('#<%= gvSubDept.ClientID %> tr td input[type="checkbox"]');
            var chkd = document.querySelectorAll('#<%= gvSubDept.ClientID %> tr td input[type="checkbox"]:checked');
            masterChk.indeterminate = (chkd.length > 0 && chkd.length < all.length);
            masterChk.checked = (all.length > 0 && chkd.length === all.length);
        }

        $(function () {
            $("#<%= txtItem.ClientID %>").autocomplete({
                source: function (request, response) {
                    $.ajax({
                        url: "ResturantMenusetup.aspx/GetItems",
                        data: "{ 'prefixText': '" + request.term + "'}",
                        dataType: "json", type: "POST",
                        contentType: "application/json; charset=utf-8",
                        success: function (data) {
                            response($.map(data.d, function (item) {
                                var parts = item.split('|');
                                return { label: parts[0], value: parts[0], code: parts[1] };
                            }));
                        }
                    });
                },
                select: function (e, i) {
                    document.getElementById('<%= hdnItemCode.ClientID %>').value = i.item.code;
                },
                minLength: 1
            });
        });

        $(document).on('change', '#<%= gvSubDept.ClientID %> input[type="checkbox"]', function () {
            var row = $(this).closest('tr');
            if ($(this).is(':checked')) row.addClass('row-checked');
            else row.removeClass('row-checked');
            updateSaveBarInfo();
            syncSelectAllCheckbox();
        });

        function updateSaveBarInfo() {
            var checked = $("#<%= gvSubDept.ClientID %> td input[type='checkbox']:checked").length;
            var total = $("#<%= gvSubDept.ClientID %> tr").length - 1;
            document.getElementById("saveBarInfo").innerHTML =
                "<strong>" + checked + " of " + total + "</strong> sub departments selected";
        }

        function applyGlobalGST() {
            var val = document.getElementById('txtGlobalGST').value.trim();
            if (!val) { alert('Please enter a GST % value first.'); return; }
            var num = parseFloat(val);
            if (isNaN(num) || num < 0) { alert('Please enter a valid GST %'); return; }
            document.querySelectorAll('#<%= gvSubDept.ClientID %> input[id*="txtGST"]').forEach(function (inp) {
                inp.value = num;
            });
        }

        function applySetPrice() {
            var val = document.getElementById('txtSetPrice').value.trim();
            if (!val) { alert('Please enter a price value first.'); return; }
            var num = parseFloat(val);
            if (isNaN(num) || num < 0) { alert('Please enter a valid price.'); return; }

            var rows = document.querySelectorAll('#<%= gvSubDept.ClientID %> tr');
            var applied = 0;
            for (var i = 1; i < rows.length; i++) {
                var chk = rows[i].querySelector('input[type="checkbox"]');
                if (chk && chk.checked) {
                    var priceInput = rows[i].querySelector('input[id*="txtPrice"]');
                    if (priceInput) { priceInput.value = num.toFixed(2); applied++; }
                }
            }
            if (applied === 0) alert('Please tick at least one row checkbox first.');
            else alert('Price ' + num.toFixed(2) + ' applied to ' + applied + ' row(s).');
        }

        function confirmSave() {
            var itemCode = document.getElementById('<%= hdnItemCode.ClientID %>').value;
            if (!itemCode) { alert('Please search and load an item first.'); return false; }

            var subMenu = document.getElementById('<%= ddlSubMenu.ClientID %>').value;
            var mealType = document.getElementById('<%= ddlMealType.ClientID %>').value;
            var course = document.getElementById('<%= ddlCourse.ClientID %>').value;

            if (!subMenu || subMenu === '0') { alert('Please select a Sub Menu'); return false; }
            if (!mealType || mealType === '0') { alert('Please select a Meal Type'); return false; }
            if (!course || course === '0') { alert('Please select a Course'); return false; }

            var checked = document.querySelectorAll('#<%= gvSubDept.ClientID %> td input[type="checkbox"]:checked').length;
            if (checked === 0) { alert('Please select at least one Sub Department'); return false; }

            var smText = document.getElementById('<%= ddlSubMenu.ClientID %>').options[document.getElementById('<%= ddlSubMenu.ClientID %>').selectedIndex].text;
            var mtText = document.getElementById('<%= ddlMealType.ClientID %>').options[document.getElementById('<%= ddlMealType.ClientID %>').selectedIndex].text;
            var crText = document.getElementById('<%= ddlCourse.ClientID %>').options[document.getElementById('<%= ddlCourse.ClientID %>').selectedIndex].text;

            return confirm('Save changes?\n\nSub Menu: ' + smText + '\nMeal Type: ' + mtText + '\nCourse: ' + crText + '\n\n' + checked + ' sub department(s) will be saved.\n\nContinue?');
        }

        function refreshLiveCost() {
            var code = document.getElementById('<%= hdnItemCode.ClientID %>').value;
            if (code) LoadItemLiveCost(code);
            else alert('Please load an item first.');
        }

        function LoadItemLiveCost(itemCode) {
            if (!itemCode || itemCode === '') { 
                $('#liveCostPanel').hide(); 
                return; 
            }
            $('#liveBaseCost,#liveGSTAmount,#liveTotalWithTax').text('...');
            $('#liveCostPanel').fadeIn(200);

            $.ajax({
                type: "POST", url: "ResturantMenusetup.aspx/GetItemLiveCost",
                data: JSON.stringify({ itemCode: itemCode }),
                contentType: "application/json; charset=utf-8", dataType: "json",
                success: function (r) {
                    var d = r.d;
                    if (d.success) {
                        var lc = d.liveCost.toFixed(2);
                        $('#liveBaseCost').text(lc);
                        $('#liveGSTAmount').text(d.gstAmount.toFixed(2));
                        $('#liveTotalWithTax').text(d.totalWithTax.toFixed(2));

                        if (d.recipeWeight && d.recipeWeight > 0) {
                            $('#<%= txtRecipeWeight.ClientID %>').val(d.recipeWeight);
                        } else {
                            $('#<%= txtRecipeWeight.ClientID %>').val('');
                        }

                        if (d.weightUnit && d.weightUnit !== '') {
                            $('#<%= ddlWeightUnit.ClientID %>').val(d.weightUnit);
                        } else {
                            $('#<%= ddlWeightUnit.ClientID %>').val('0');
                        }

                        if (d.perPerson && d.perPerson > 0) {
                            $('#<%= txtPerPerson.ClientID %>').val(d.perPerson);
                        } else {
                            $('#<%= txtPerPerson.ClientID %>').val('');
                        }

                        document.querySelectorAll('#<%= gvSubDept.ClientID %> input[id*="txtCost"]').forEach(function (inp) {
                            inp.value = lc;
                        });

                        var tbody = $('#ingTableBody').empty();
                        if (d.ingredientsList && d.ingredientsList.length) {
                            $.each(d.ingredientsList, function (i, ing) {
                                tbody.append('<tr style="border-bottom:1px solid var(--line);">'
                                    + '<td style="padding:6px;text-align:left;">' + ing.name + '</td>'
                                    + '<td style="padding:6px;text-align:center;">' + ing.quantity.toFixed(4) + '</td>'
                                    + '<td style="padding:6px;text-align:right;">' + ing.rate.toFixed(4) + '</td>'
                                    + '<td style="padding:6px;text-align:right;">' + ing.cost.toFixed(4) + '</td>'
                                    + '<td style="padding:6px;text-align:center;color:var(--amber);">' + ing.garnish.toFixed(4) + '</td>'
                                    + '<td style="padding:6px;text-align:center;color:var(--blue);">' + ing.topping.toFixed(4) + '</td>'
                                    + '<td style="padding:6px;text-align:center;color:var(--red);">' + ing.wastage.toFixed(4) + '</td>'
                                    + '<td style="padding:6px;text-align:right;font-weight:700;color:var(--green);">' + ing.totalCost.toFixed(4) + '</td>'
                                    + '</tr>');
                            });
                        } else {
                            tbody.append('<tr><td colspan="8" style="text-align:center;padding:10px;">No ingredients found</td></tr>');
                        }
                        $('#liveCostPanel').show();
                    } else {
                        $('#liveBaseCost,#liveGSTAmount,#liveTotalWithTax').text('0.00');
                        $('#ingTableBody').html('<tr><td colspan="8" style="text-align:center;color:red;padding:10px;">' + (d.message || 'No recipe found') + '</td></tr>');
                        $('#liveCostPanel').show();
                    }
                },
                error: function () {
                    $('#liveCostPanel').hide();
                }
            });
        }
    </script>
</asp:Content>
