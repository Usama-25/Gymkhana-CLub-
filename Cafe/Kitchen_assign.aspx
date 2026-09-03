<%@ Page Title="Kitchen Department Assignment" Language="C#" 
    MasterPageFile="~/MasterPages/GymkhanaMaster.master"
    AutoEventWireup="true" CodeFile="Kitchen_assign.aspx.cs" 
    Inherits="Kitchen_assign" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700;800;900&family=Geist+Mono:wght@400;500;600&display=swap" rel="stylesheet" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

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
        --sh1: 0 1px 3px rgba(10,15,30,.07),0 1px 2px rgba(10,15,30,.05);
        --sh2: 0 4px 12px rgba(10,15,30,.08),0 2px 4px rgba(10,15,30,.05);
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
    ::-webkit-scrollbar-thumb:hover {
        background: var(--blue-mid);
    }
    
    /* ═══════════════════════════════════════════
       PAGE WRAPPER - Full Width
    ═══════════════════════════════════════════ */
    .ka-page {
        width: 100%;
        max-width: 100%;
        margin: 0;
        padding: 18px 20px;
    }
    
    /* ═══════════════════════════════════════════
       PAGE HEADER - Matches Finance.aspx
    ═══════════════════════════════════════════ */
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
    .phdr-right {
        display: flex;
        align-items: center;
        gap: 10px;
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
    
    /* ═══════════════════════════════════════════
       CARD COMPONENT - Matches Finance.aspx
    ═══════════════════════════════════════════ */
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
    
    /* ═══════════════════════════════════════════
       FORM STYLES
    ═══════════════════════════════════════════ */
    .form-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        margin-bottom: 20px;
    }
    
    @media (max-width: 768px) {
        .form-row {
            grid-template-columns: 1fr;
        }
    }
    
    .form-group {
        display: flex;
        flex-direction: column;
        gap: 6px;
    }
    
    .form-label {
        font-size: .67rem;
        font-weight: 800;
        color: #475569;
        text-transform: uppercase;
        letter-spacing: .8px;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    
    .form-label i {
        color: var(--blue);
        font-size: 10px;
    }
    
    /* Premium Inputs */
    .premium-select {
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
        cursor: pointer;
        appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%237A85A0' stroke-width='1.8' fill='none' stroke-linecap='round'/%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 13px center;
        background-size: 12px;
        padding-right: 34px;
    }
    
    .premium-select:focus {
        border-color: var(--blue);
        outline: none;
        box-shadow: 0 0 0 3px rgba(24,69,212,.1);
    }
    
    .form-text {
        font-size: 11px;
        color: var(--muted);
        margin-top: 4px;
    }
    
    /* Info Badge */
    .info-badge {
        background: var(--blue-light);
        color: var(--blue-dark);
        padding: 10px 16px;
        border-radius: var(--r);
        font-size: 12px;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 8px;
        border: 1px solid var(--line);
        height: 40px;
    }
    
    .info-badge i {
        font-size: 14px;
        color: var(--blue);
    }
    
    /* Checkbox Grid */
    .department-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 12px;
    }
    
    .checkbox-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        gap: 10px;
        padding: 16px;
        background: var(--surface);
        border-radius: var(--r);
        border: 1px solid var(--line);
        max-height: 350px;
        overflow-y: auto;
    }
    
    .checkbox-grid label {
        margin-left: 8px;
        cursor: pointer;
        user-select: none;
        font-size: 13px;
        color: var(--ink);
    }
    
    .checkbox-grid input[type="checkbox"] {
        cursor: pointer;
        width: 16px;
        height: 16px;
        accent-color: var(--blue);
    }
    
    /* Select All Button */
    .select-all-btn {
        background: var(--green);
        color: white;
        border: none;
        padding: 5px 16px;
        border-radius: var(--r-sm);
        cursor: pointer;
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: .5px;
        transition: all .2s;
        height: 30px;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }
    
    .select-all-btn:hover {
        background: var(--green-dark);
        transform: translateY(-1px);
    }
    
    /* Selected Count */
    .selected-count {
        font-weight: 800;
        color: var(--blue);
        background: var(--blue-light);
        padding: 2px 8px;
        border-radius: 20px;
        margin-left: 5px;
    }
    
    /* Save Button */
    .btn-save {
        padding: 0 28px;
        height: 42px;
        background: var(--blue);
        color: white;
        border: none;
        border-radius: var(--r-sm);
        font-weight: 700;
        font-size: 13px;
        cursor: pointer;
        transition: all .2s;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        box-shadow: 0 2px 8px rgba(24,69,212,.22);
    }
    
    .btn-save:hover {
        background: var(--blue-dark);
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(24,69,212,.3);
    }
    
    /* Message Label */
    .message-label {
        padding: 12px 16px;
        border-radius: var(--r-sm);
        margin-bottom: 20px;
        text-align: center;
        font-weight: 600;
        font-size: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
    }
    
    .message-success {
        background: var(--green-light);
        color: var(--green-dark);
        border: 1px solid #A7F3D0;
    }
    
    .message-error {
        background: var(--red-light);
        color: var(--red);
        border: 1px solid #FECACA;
    }
    
    .message-info {
        background: var(--blue-light);
        color: var(--blue-dark);
        border: 1px solid #BFDBFE;
    }
    
    /* Button Row */
    .button-row {
        display: flex;
        justify-content: center;
        margin-top: 24px;
        padding-top: 16px;
        border-top: 1px solid var(--line);
    }
    
    /* Responsive */
    @media (max-width: 640px) {
        .ka-page {
            padding: 12px;
        }
        .page-hdr {
            flex-direction: column;
            height: auto;
            padding: 12px;
            gap: 10px;
            border-radius: var(--r);
        }
        .checkbox-grid {
            grid-template-columns: 1fr;
        }
        .card-body {
            padding: 16px;
        }
    }
</style>

<script type="text/javascript">
    // Function to style message label based on content (visual only)
    function styleMessageLabel() {
        var lbl = document.getElementById('<%= lblMessage.ClientID %>');
        if (lbl && lbl.innerText && lbl.innerText.trim() !== '') {
            var text = lbl.innerText.toLowerCase();
            lbl.classList.add('message-label');
            if (text.indexOf('success') >= 0 || text.indexOf('saved') >= 0 || text.indexOf('linked') >= 0) {
                lbl.classList.add('message-success');
            } else if (text.indexOf('error') >= 0 || text.indexOf('failed') >= 0) {
                lbl.classList.add('message-error');
            } else {
                lbl.classList.add('message-info');
            }
            lbl.style.display = 'flex';
        }
    }
    
    // Run on page load
    document.addEventListener('DOMContentLoaded', function() {
        styleMessageLabel();
    });
    
    // For UpdatePanel scenarios
    if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
        var prm = Sys.WebForms.PageRequestManager.getInstance();
        if (prm) {
            prm.add_endRequest(function() {
                styleMessageLabel();
            });
        }
    }
</script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div class="ka-page">

    <!-- PAGE HEADER - Matches Finance.aspx -->
    <div class="page-hdr">
        <div class="page-hdr-brand">
            <div class="phdr-icon"><i class="fas fa-utensils"></i></div>
            <div>
                <div class="phdr-name">Kitchen Department Mapping</div>
                <div class="phdr-sub">Kitchen Assignment Management</div>
            </div>
        </div>
        <div class="phdr-right">
            <div class="sel-pill">
                <i class="fas fa-link"></i>
                Department Assignment
            </div>
        </div>
    </div>

    <!-- MAIN CARD -->
    <div class="card">
        <div class="card-head">
            <h3><i class="fas fa-kitchen-set"></i> Kitchen to Department Link</h3>
        </div>
        <div class="card-body">
            
            <!-- Message Label (C# controlled - fully preserved) -->
            <asp:Label ID="lblMessage" runat="server" CssClass="" Visible="false"></asp:Label>
            
            <!-- Form Row -->
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">
                        <i class="fas fa-utensils"></i> Select Kitchen
                    </label>
                    <asp:DropDownList ID="ddlKitchen" runat="server" 
                        CssClass="premium-select" 
                        OnSelectedIndexChanged="ddlKitchen_SelectedIndexChanged"
                        AutoPostBack="true">
                    </asp:DropDownList>
                    <span class="form-text">
                        <i class="fas fa-info-circle"></i> Choose a kitchen to assign departments
                    </span>
                </div>
                <div class="form-group">
                    <div class="info-badge">
                        <i class="fas fa-building"></i>
                        Select departments that will be served by this kitchen
                    </div>
                </div>
            </div>
            
            <!-- Departments Section -->
            <div class="form-group">
                <div class="department-header">
                    <label class="form-label">
                        <i class="fas fa-folder-tree"></i> Departments
                    </label>
                    <asp:Button ID="btnSelectAll" runat="server" Text="Select All" 
                        CssClass="select-all-btn" OnClick="btnSelectAll_Click" 
                        UseSubmitBehavior="false" />
                </div>
                <div class="checkbox-grid">
                    <asp:CheckBoxList ID="chkDepartments" runat="server" 
                        RepeatLayout="Flow" RepeatDirection="Vertical"
                        AutoPostBack="true" OnSelectedIndexChanged="chkDepartments_SelectedIndexChanged">
                    </asp:CheckBoxList>
                </div>
                <div class="mt-2" style="margin-top: 10px;">
                    <span class="form-text">
                        <i class="fas fa-check-circle"></i> Selected departments: 
                        <asp:Label ID="lblSelectedCount" runat="server" CssClass="selected-count" Text="0"></asp:Label>
                    </span>
                </div>
            </div>
            
            <!-- Save Button Row -->
            <div class="button-row">
                <asp:Button ID="btnSave" runat="server" Text="Link Kitchen" 
                    CssClass="btn-save" OnClick="btnSave_Click" />
            </div>
            
        </div>
    </div>

</div>
</asp:Content>
