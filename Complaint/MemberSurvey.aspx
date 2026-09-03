<%@ Page Title="Member Complaint Portal | Survey" Language="C#" AutoEventWireup="true"
CodeFile="MemberSurvey.aspx.cs" Inherits="RefundFee.MemberSurvey" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />
    <title>Gymkhana Complaint Management</title>
    <style>
        /* Custom dropdown (unchanged) */
        .csd-wrapper { position: relative; width: 100%; }
        .csd-trigger {
            width: 100%; min-height: 46px; padding: 11px 40px 11px 16px;
            border-radius: 18px; border: 1px solid #e2e8f0; background: #fff;
            cursor: pointer; display: flex; align-items: center; justify-content: space-between;
            box-sizing: border-box; font-family: 'Segoe UI', sans-serif; font-size: 14px;
            color: #1e293b; user-select: none; transition: border-color 0.18s, box-shadow 0.18s;
        }
        .csd-trigger:hover { border-color: #f5b042; box-shadow: 0 0 0 3px rgba(245,176,66,0.12); }
        .csd-trigger.is-open { border-color: #f5b042; border-bottom-left-radius: 0; border-bottom-right-radius: 0; }
        .csd-arrow { font-size: 11px; color: #94a3b8; flex-shrink: 0; margin-left: 8px; transition: transform 0.18s; }
        .csd-trigger.is-open .csd-arrow { transform: rotate(180deg); color: #f5b042; }
        .csd-options {
            display: none; position: absolute; top: 100%; left: 0; right: 0; background: #fff;
            border: 1px solid #f5b042; border-top: 1px solid #f0e0c0;
            border-bottom-left-radius: 16px; border-bottom-right-radius: 16px;
            box-shadow: 0 10px 24px rgba(0,0,0,0.10); max-height: 220px; overflow-y: auto;
            z-index: 9999; scrollbar-width: thin; scrollbar-color: #f5b042 #f8fafc;
        }
        .csd-options::-webkit-scrollbar { width: 5px; }
        .csd-options::-webkit-scrollbar-thumb { background: #f5b042; border-radius: 3px; }
        .csd-options::-webkit-scrollbar-track { background: #f8fafc; }
        .csd-options.is-open { display: block; }
        .csd-option {
            padding: 10px 16px; cursor: pointer; font-size: 13.5px; color: #334155;
            transition: background 0.1s; border-bottom: 1px solid #f8fafc;
        }
        .csd-option:last-child { border-bottom: none; }
        .csd-option:hover { background: #fef9ec; color: #D97706; }
        .csd-option.is-selected { background: #FEFAE8; color: #B45309; font-weight: 600; }
        .csd-option.is-placeholder { color: #94a3b8; font-style: italic; }
        .csd-option.is-placeholder:hover { background: #f8fafc; color: #94a3b8; cursor: default; }

        /* Modal (unchanged) */
        .modal-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5); display: flex; align-items: flex-start; justify-content: center;
            z-index: 1000; visibility: hidden; opacity: 0; transition: visibility 0.2s, opacity 0.2s;
            overflow-y: auto; padding: 40px 16px; box-sizing: border-box;
        }
        .modal-overlay.active { visibility: visible; opacity: 1; }
        .modal-container {
            background: white; border-radius: 32px; width: 100%; width: 100%; margin: auto;
            box-shadow: 0 20px 35px rgba(0,0,0,0.2); border-top: 6px solid #f5b042; position: relative;
        }
        .modal-questions-wrapper { padding: 8px 28px 120px 28px; max-height: 60vh; overflow-y: auto; }

        /* Keyframes for popup animations */
        @keyframes popIn {
            0% { transform: scale(0.85); opacity: 0; }
            100% { transform: scale(1); opacity: 1; }
        }
        @keyframes circleDraw {
            to { stroke-dashoffset: 0; }
        }
        @keyframes tickDraw {
            to { stroke-dashoffset: 0; }
        }
    </style>
</head>
<body style="background:#f8fafc;font-family:'Segoe UI',sans-serif;margin:0;padding:32px;color:#1e293b;">

<form id="form1" runat="server">

    <!-- Hidden field that triggers the success popup -->
    <asp:HiddenField ID="hfShowPopup" runat="server" Value="0" />

<div style="width:100%;margin:0 auto;">

    <!-- HEADER WITH LOGO -->
    <div style="display:flex;align-items:center;gap:16px;border-left:5px solid #f5b042;padding-left:20px;margin-bottom:32px;">
        <img src="Images/logo.png" alt="Logo" style="width:48px;height:48px;object-fit:contain;" />
        <div>
            <h1 style="margin:0;font-size:1.9rem;font-weight:700;color:#D97706;">Gymkhana Complaint Management</h1>
            <div style="color:#5b6f82;font-size:0.95rem;font-weight:500;">Official feedback &amp; complaint submission</div>
        </div>
    </div>

    <asp:Label ID="lblMessage" runat="server" EnableViewState="false" style="display:block;margin-bottom:20px;" />

    <!-- WELCOME BANNER (only with URL parameters) -->
    <asp:Panel ID="pnlWelcomeBanner" runat="server" Visible="false"
        style="text-align:center;margin-bottom:24px;">
        <div style="display:inline-block;background:linear-gradient(105deg,#FFF7E0,#FFEDC0);border:1px solid #f5b042;border-radius:16px;padding:16px 28px;box-shadow:0 6px 18px rgba(245,176,66,0.15);">
            <span style="font-size:1.6rem;color:#e6a017;">??</span>
            <br />
            <asp:Literal ID="litSubDeptWelcome" runat="server" />
        </div>
    </asp:Panel>

    <!-- ==================== DIRECT ACCESS PANEL ==================== -->
    <asp:Panel ID="pnlDirectAccess" runat="server" Visible="false"
        style="width:100%;margin:0 auto;background:#fff;border-radius:28px;border:1px solid #eef2f8;border-top:4px solid #f5b042;padding:32px;box-shadow:0 4px 12px rgba(0,0,0,0.03);">

        <h3 style="margin-top:0;color:#D97706;font-weight:700;">?? Your Details</h3>

        <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;">
            <div>
                <span style="display:block;color:#5a6874;font-size:0.75rem;font-weight:600;margin-bottom:6px;text-transform:uppercase;letter-spacing:0.5px;">Member Number (optional)</span>
                <asp:TextBox ID="txtMemberNoDirect" runat="server" placeholder="e.g., MEM-10234"
                    style="width:100%;padding:12px 14px;border-radius:18px;border:1px solid #e2e8f0;background:#f9fbfd;font-family:inherit;font-size:14px;color:#1e293b;box-sizing:border-box;outline:none;" />
            </div>
            <div>
                <span style="display:block;color:#5a6874;font-size:0.75rem;font-weight:600;margin-bottom:6px;text-transform:uppercase;letter-spacing:0.5px;">Phone Number *</span>
                <asp:TextBox ID="txtPhoneNumberDirect" runat="server" placeholder="+92-300-1234567"
                    style="width:100%;padding:12px 14px;border-radius:18px;border:1px solid #e2e8f0;background:#f9fbfd;font-family:inherit;font-size:14px;color:#1e293b;box-sizing:border-box;outline:none;" />
                <asp:RequiredFieldValidator ID="rfvPhoneDirect" runat="server" ControlToValidate="txtPhoneNumberDirect"
                    ErrorMessage="Phone number is required." Display="Dynamic"
                    style="color:#e25c5c;font-size:0.75rem;margin-top:4px;" />
            </div>
        </div>

        <div style="margin-top:20px;">
            <span style="display:block;color:#5a6874;font-size:0.75rem;font-weight:600;margin-bottom:6px;text-transform:uppercase;letter-spacing:0.5px;">Remarks *</span>
            <asp:TextBox ID="txtRemarksDirect" runat="server" TextMode="MultiLine" Rows="2"
                placeholder="Any additional comments..."
                style="width:100%;padding:12px 14px;border-radius:18px;border:1px solid #e2e8f0;background:#f9fbfd;font-family:inherit;font-size:14px;color:#1e293b;box-sizing:border-box;outline:none;" />
            <asp:RequiredFieldValidator ID="rfvRemarksDirect" runat="server" ControlToValidate="txtRemarksDirect"
                ErrorMessage="Remarks are required." Display="Dynamic"
                style="color:#e25c5c;font-size:0.75rem;margin-top:4px;" />
        </div>

        <!-- Complaint & Feedback Details Section -->
        <div style="margin-top:36px;">
            <h3 style="color:#B45309;font-weight:700;margin-bottom:24px;border-bottom:2px solid #FDE68A;display:inline-block;padding-bottom:4px;">Complaint &amp; Feedback Details</h3>
            <asp:Repeater ID="rptQuestionsInline" runat="server" OnItemDataBound="rptQuestionsInline_ItemDataBound">
                <ItemTemplate>
                    <div style="background:#f9fbfd;border:1px solid #edf2f7;border-radius:16px;padding:18px 20px;margin-bottom:16px;">
                        <div style="font-weight:600;margin-bottom:12px;color:#1e293b;"><%# Eval("QuestionText") %></div>
                        <asp:HiddenField ID="hfQuestionIdInline"   runat="server" Value='<%# Eval("Id") %>' />
                        <asp:HiddenField ID="hfQuestionTypeInline" runat="server" Value='<%# Eval("QuestionType") %>' />
                        <asp:PlaceHolder ID="phOptionsInline" runat="server"></asp:PlaceHolder>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <!-- Submit Button -->
        <div style="margin-top:28px;text-align:right;">
            <asp:Button ID="btnSubmitInline" runat="server" Text="Submit Complaint" OnClick="btnSubmit_Click"
                style="background:linear-gradient(105deg,#f5b042,#e09d2e);border:none;color:white;font-weight:700;padding:14px 32px;border-radius:40px;cursor:pointer;font-size:1rem;box-shadow:0 4px 12px rgba(245,176,66,0.35);transition:transform 0.2s,filter 0.2s;" />
        </div>
    </asp:Panel>

    <!-- ==================== NORMAL FLOW PANELS (unchanged) ==================== -->
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:28px;">
        <asp:Panel ID="pnlMemberPanel" runat="server"
            style="background:#fff;padding:26px;border-radius:28px;border:1px solid #eef2f8;border-top:4px solid #f5b042;">

            <h3>?? Member Identity</h3>
            <asp:TextBox ID="txtMemberNo" runat="server" placeholder="e.g., MEM-10234 (optional)"
                style="width:100%;padding:12px;border-radius:18px;border:1px solid #e2e8f0;box-sizing:border-box;" />

            <asp:Button ID="btnFetchMember" runat="server" Text="Verify Member" OnClick="btnFetchMember_Click"
                style="margin-top:12px;background:#f5b042;color:#fff;border:none;padding:12px 20px;border-radius:40px;cursor:pointer;width:100%;" />

            <asp:Panel ID="pnlMemberInfo" runat="server" Visible="false"
                style="margin-top:20px;padding:14px;background:#FEFAE8;border-radius:20px;border-left:4px solid #f5b042;">
                <asp:Label ID="lblMemberName" runat="server" style="font-weight:600;color:#B45309;" />
            </asp:Panel>

            <div style="margin-top:20px;">
                <span style="display:block;color:#5a6874;font-size:0.75rem;font-weight:600;margin-bottom:6px;text-transform:uppercase;letter-spacing:0.5px;">Phone Number *</span>
                <asp:TextBox ID="txtPhoneNumber" runat="server" placeholder="+92-300-1234567"
                    style="width:100%;padding:12px 14px;border-radius:18px;border:1px solid #e2e8f0;background:#f9fbfd;font-family:inherit;font-size:14px;color:#1e293b;box-sizing:border-box;" />
                <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhoneNumber"
                    ErrorMessage="Phone number is required." Display="Dynamic"
                    style="color:#e25c5c;font-size:0.75rem;margin-top:4px;" />
            </div>
            <div style="margin-top:16px;">
                <span style="display:block;color:#5a6874;font-size:0.75rem;font-weight:600;margin-bottom:6px;text-transform:uppercase;letter-spacing:0.5px;">Remarks *</span>
                <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="2" placeholder="Any additional comments..."
                    style="width:100%;padding:12px 14px;border-radius:18px;border:1px solid #e2e8f0;background:#f9fbfd;font-family:inherit;font-size:14px;color:#1e293b;box-sizing:border-box;" />
                <asp:RequiredFieldValidator ID="rfvRemarks" runat="server" ControlToValidate="txtRemarks"
                    ErrorMessage="Remarks are required." Display="Dynamic"
                    style="color:#e25c5c;font-size:0.75rem;margin-top:4px;" />
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlDeptSelection" runat="server" Visible="false"
            style="background:#fff;padding:26px;border-radius:28px;border:1px solid #eef2f8;border-top:4px solid #f5b042;">

            <h3>?? Complaint Category</h3>
            <asp:Label ID="lblDept" runat="server" Text="Department" />
            <asp:DropDownList ID="ddlDepartment" runat="server" AutoPostBack="true"
                OnSelectedIndexChanged="ddlDepartment_SelectedIndexChanged"
                DataTextField="Dept_name" DataValueField="Dept_ID" AppendDataBoundItems="true"
                style="width:100%;padding:12px;border-radius:18px;" />
            <br /><br />
            <asp:Label ID="lblSubDept" runat="server" Text="Sub-Department / Service" />
            <asp:DropDownList ID="ddlSubDepartment" runat="server" AutoPostBack="true"
                OnSelectedIndexChanged="ddlSubDepartment_SelectedIndexChanged"
                DataTextField="SubDept_Name" DataValueField="SubDept_Id" AppendDataBoundItems="true"
                style="width:100%;padding:12px;border-radius:18px;" />
            <div style="margin-top:20px;">
                <asp:Button ID="btnOpenModal" runat="server" Text="?? Make Complaint"
                    OnClientClick="openModal(); return false;"
                    style="background:#f5b042;color:#fff;border:none;padding:12px 20px;border-radius:40px;cursor:pointer;width:100%;" />
            </div>
        </asp:Panel>
    </div>

    <!-- MODAL (normal flow) -->
    <div id="complaintModal" class="modal-overlay" runat="server">
        <div class="modal-container">
            <div style="padding:20px;border-bottom:1px solid #eee;display:flex;align-items:center;justify-content:space-between;">
                <h3 style="margin:0;">?? Complaint &amp; Evidence Details</h3>
                <button type="button" onclick="closeModal()"
                    style="background:none;border:1px solid #e2e8f0;border-radius:50%;width:32px;height:32px;cursor:pointer;font-size:14px;color:#64748b;display:flex;align-items:center;justify-content:center;">?</button>
            </div>
            <div class="modal-questions-wrapper">
                <asp:Repeater ID="rptQuestions" runat="server" OnItemDataBound="rptQuestions_ItemDataBound">
                    <ItemTemplate>
                        <div style="margin-bottom:20px;">
                            <%# Eval("QuestionText") %>
                            <asp:HiddenField ID="hfQuestionId"   runat="server" Value='<%# Eval("Id") %>' />
                            <asp:HiddenField ID="hfQuestionType" runat="server" Value='<%# Eval("QuestionType") %>' />
                            <asp:PlaceHolder ID="phOptions" runat="server"></asp:PlaceHolder>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
            <div style="padding:20px;">
                <asp:Button ID="btnSubmit" runat="server" Text="Submit Complaint" OnClick="btnSubmit_Click"
                    style="background:#f5b042;color:#fff;border:none;padding:14px 20px;border-radius:40px;width:100%;cursor:pointer;" />
            </div>
        </div>
    </div>

</div>
</form>

<!-- SUCCESS POPUP (modern) -->
<div id="successOverlay" style="position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.6);display:none;align-items:center;justify-content:center;z-index:2000;">
    <div style="background:white;border-radius:28px;padding:48px 56px;text-align:center;box-shadow:0 30px 60px rgba(0,0,0,0.3);width:100%;width:90%;animation:popIn 0.4s ease;">
        
        <!-- Animated Checkmark -->
        <div style="margin-bottom:24px;">
            <svg width="80" height="80" viewBox="0 0 80 80" style="display:block;margin:0 auto;">
                <circle cx="40" cy="40" r="36" fill="none" stroke="#2e7d32" stroke-width="4" stroke-dasharray="226.2" stroke-dashoffset="226.2" style="animation:circleDraw 0.6s ease forwards;" />
                <path d="M24 40 L34 50 L56 30" fill="none" stroke="#2e7d32" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="50" stroke-dashoffset="50" style="animation:tickDraw 0.4s 0.4s ease forwards;" />
            </svg>
        </div>
        
        <h2 style="color:#2e7d32;margin:0 0 10px 0;font-weight:700;font-size:1.8rem;">Thank You</h2>
        <p style="color:#5a6874;margin:0 0 28px 0;font-size:1rem;line-height:1.5;">Your complaint has been submitted successfully.</p>
        
        <!-- OK Button -->
        <button onclick="closeSuccessPopup()" style="background:linear-gradient(105deg,#f5b042,#e09d2e);border:none;color:white;font-weight:700;padding:12px 48px;border-radius:40px;cursor:pointer;font-size:1rem;box-shadow:0 4px 12px rgba(245,176,66,0.35);transition:transform 0.2s,filter 0.2s;"
            onmouseover="this.style.transform='translateY(-1px)';this.style.filter='brightness(1.05)';"
            onmouseout="this.style.transform='translateY(0)';this.style.filter='brightness(1)';">
            OK
        </button>
    </div>
</div>

<script>
    function openModal() {
        document.getElementById('complaintModal').classList.add('active');
    }
    function closeModal() {
        document.getElementById('complaintModal').classList.remove('active');
    }
    document.getElementById('complaintModal').addEventListener('click', function (e) {
        if (e.target === this) closeModal();
    });

    // Show the popup (no auto-close)
    function showSuccessPopup() {
        var overlay = document.getElementById('successOverlay');
        if (overlay) {
            overlay.style.display = 'flex';
        }
    }

    // Close the popup and then close the window
    function closeSuccessPopup() {
        var overlay = document.getElementById('successOverlay');
        if (overlay) {
            overlay.style.display = 'none';
        }
        window.close();
    }

    /* Custom dropdown script (unchanged) */
    (function () {
        'use strict';
        var activeOptList = null;
        function closeActive() {
            if (!activeOptList) return;
            activeOptList.classList.remove('is-open');
            var tr = activeOptList._trigger;
            if (tr) tr.classList.remove('is-open');
            activeOptList = null;
        }
        function buildDropdown(nativeSel) {
            if (!nativeSel) return;
            nativeSel.style.cssText = 'position:absolute!important;opacity:0!important;width:1px!important;height:1px!important;pointer-events:none!important;overflow:hidden!important;clip:rect(0,0,0,0)!important;white-space:nowrap!important;';
            var wrapper = document.createElement('div'); wrapper.className = 'csd-wrapper';
            nativeSel.parentNode.insertBefore(wrapper, nativeSel);
            wrapper.appendChild(nativeSel);
            var trigger = document.createElement('div'); trigger.className = 'csd-trigger';
            trigger.innerHTML = '<span class="csd-label"></span><span class="csd-arrow">&#9660;</span>';
            wrapper.appendChild(trigger);
            var optList = document.createElement('div'); optList.className = 'csd-options'; optList._trigger = trigger;
            wrapper.appendChild(optList);
            function syncLabel() {
                var idx = nativeSel.selectedIndex;
                var opt = idx >= 0 ? nativeSel.options[idx] : null;
                var lbl = trigger.querySelector('.csd-label');
                if (opt) { lbl.textContent = opt.text; lbl.style.color = (opt.value === '') ? '#94a3b8' : '#1e293b'; lbl.style.fontStyle = (opt.value === '') ? 'italic' : 'normal'; }
            }
            function buildOptionRows() {
                optList.innerHTML = '';
                for (var i = 0; i < nativeSel.options.length; i++) {
                    (function (i) {
                        var opt = nativeSel.options[i];
                        var item = document.createElement('div'); item.className = 'csd-option';
                        if (opt.value === '') item.classList.add('is-placeholder');
                        if (i === nativeSel.selectedIndex) item.classList.add('is-selected');
                        item.textContent = opt.text;
                        item.addEventListener('click', function (e) {
                            e.stopPropagation();
                            if (opt.value === '') return;
                            nativeSel.selectedIndex = i; syncLabel(); closeActive();
                            var ev = document.createEvent('HTMLEvents'); ev.initEvent('change', true, true);
                            nativeSel.dispatchEvent(ev);
                        });
                        optList.appendChild(item);
                    })(i);
                }
            }
            function openList() { closeActive(); buildOptionRows(); optList.classList.add('is-open'); trigger.classList.add('is-open'); activeOptList = optList; }
            trigger.addEventListener('click', function (e) { e.stopPropagation(); if (optList.classList.contains('is-open')) closeActive(); else openList(); });
            syncLabel();
        }
        document.addEventListener('click', function () { closeActive(); });
        function init() {
            buildDropdown(document.getElementById('<%= ddlDepartment.ClientID %>'));
            buildDropdown(document.getElementById('<%= ddlSubDepartment.ClientID %>'));
        }
        if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
        else init();
    })();

    // Trigger popup via hidden field
    window.addEventListener('load', function () {
        var hf = document.getElementById('<%= hfShowPopup.ClientID %>');
        if (hf && hf.value === '1') {
            showSuccessPopup();
        }
    });
</script>

</body>
</html>
