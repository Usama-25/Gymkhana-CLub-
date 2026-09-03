<%@ page title="Application Tracking" language="C#" masterpagefile="~/MemberShipModule/Site.master"
    autoeventwireup="true" codefile="ApplicationProcessing_DirectApproval.aspx.cs" inherits="ApplicationProcessing_DirectApproval" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="Server">
        <!-- jQuery & jQuery UI for Calendar Datepicker -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.13.2/themes/base/jquery-ui.min.css" />
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.13.2/jquery-ui.min.js"></script>

        <style>
            /* Premium jQuery UI Datepicker styling override to match Inter and Blue theme */
            .ui-datepicker {
                font-family: 'Inter', system-ui, -apple-system, sans-serif !important;
                background: #ffffff !important;
                border: 1px solid #e0d5c5 !important;
                border-radius: 12px !important;
                box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05) !important;
                padding: 0.75rem !important;
                width: 280px !important;
                z-index: 9999 !important;
            }
            .ui-datepicker-header {
                background: transparent !important;
                border: none !important;
                padding-bottom: 0.5rem !important;
                border-bottom: 1px solid #F7F3EE !important;
            }
            .ui-datepicker-title select {
                font-family: 'Inter', system-ui, sans-serif !important;
                font-size: 0.875rem !important;
                font-weight: 600 !important;
                color: #1A1A2E !important;
                padding: 0.25rem 0.5rem !important;
                border: 1px solid #e0d5c5 !important;
                border-radius: 6px !important;
                background-color: #ffffff !important;
                margin: 0 2px !important;
                outline: none !important;
            }
            .ui-datepicker-prev, .ui-datepicker-next {
                cursor: pointer !important;
                border-radius: 6px !important;
                border: 1px solid #e0d5c5 !important;
                background: #ffffff !important;
                top: 10px !important;
                display: flex !important;
                align-items: center !important;
                justify-content: center !important;
                width: 28px !important;
                height: 28px !important;
            }
            .ui-datepicker-prev:hover, .ui-datepicker-next:hover {
                background: #F7F3EE !important;
                border-color: #e0d5c5 !important;
            }
            .ui-datepicker-prev span, .ui-datepicker-next span {
                background-image: none !important;
                text-indent: 0 !important;
                overflow: visible !important;
                position: static !important;
                margin: 0 !important;
            }
            .ui-datepicker-prev::after {
                content: '‹';
                font-size: 1.25rem;
                font-weight: bold;
                color: #8B5E3C;
            }
            .ui-datepicker-next::after {
                content: '›';
                font-size: 1.25rem;
                font-weight: bold;
                color: #8B5E3C;
            }
            .ui-datepicker th {
                font-size: 0.75rem !important;
                font-weight: 600 !important;
                color: #7a7a7a !important;
                text-transform: uppercase !important;
                padding: 0.5rem 0 !important;
            }
            .ui-datepicker td {
                padding: 1px !important;
            }
            .ui-datepicker td a {
                display: block !important;
                text-align: center !important;
                padding: 0.5rem !important;
                border-radius: 8px !important;
                font-size: 0.875rem !important;
                font-weight: 500 !important;
                color: #1A1A2E !important;
                text-decoration: none !important;
                border: none !important;
                background: transparent !important;
                transition: all 0.15s ease !important;
            }
            .ui-datepicker td a:hover {
                background: #faf7f2 !important;
                color: #C9A84C !important;
            }
            .ui-datepicker td.ui-datepicker-current-day a {
                background: #C9A84C !important;
                color: #ffffff !important;
                font-weight: 600 !important;
            }
            .ui-datepicker td.ui-datepicker-today a {
                border: 1px solid #C9A84C !important;
                color: #C9A84C !important;
            }

            /* Modern calendar icon on the far right of date input textboxes */
            input[id$="txtDOB"], input[id*="txtChildDOB"] {
                background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2364748b' stroke-width='2'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' d='M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z' /%3E%3C/svg%3E") !important;
                background-repeat: no-repeat !important;
                background-position: right 12px center !important;
                background-size: 18px 18px !important;
                padding-right: 2.5rem !important;
                cursor: pointer !important;
            }

            /* Essential Styles (Self-contained for server deployments) */
            .table-container {
                background: #ffffff;
                border: 1px solid #e0d5c5;
                border-radius: 12px;
                overflow: hidden;
                margin-bottom: 1rem;
                box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);
            }

            .table {
                width: 100%;
                border-collapse: collapse;
                font-size: 0.95rem;
                text-align: left;
            }

            .table th {
                background: #faf7f2;
                color: #8B5E3C;
                font-weight: 700;
                padding: 0.75rem 1rem;
                border-bottom: 1px solid #e0d5c5;
                text-align: left;
                font-size: 0.875rem;
            }

            .table td {
                padding: 0.75rem 1rem;
                border-bottom: 1px solid #F7F3EE;
                color: #1A1A2E;
                vertical-align: middle;
                font-size: 0.9rem;
            }

            .empty-state {
                padding: 2rem;
                text-align: center;
                color: #a09080;
                background-color: #faf7f2;
                border: 1px dashed #e0d5c5;
                border-radius: 12px;
                display: flex;
                flex-direction: column;
                align-items: center;
                gap: 0.75rem;
                margin-top: 1rem;
            }

            .empty-state svg {
                color: #a09080;
                opacity: 0.6;
                margin-bottom: 0.5rem;
            }

            .table-input {
                width: 100%;
                padding: 0.5rem 0.75rem;
                border: 1px solid transparent;
                border-radius: 6px;
                background: transparent;
                font-size: 0.95rem;
                color: #1A1A2E;
                transition: all 0.2s ease;
            }

            .table-input:hover {
                background: #F7F3EE;
                border-color: #e0d5c5;
            }

            .table-input:focus {
                background: #ffffff;
                border-color: #8B5E3C;
                box-shadow: 0 0 0 2px #f5ecd5;
                outline: none;
            }

            .form-control {
                display: block;
                width: 100%;
                padding: 0.35rem 0.5rem;
                font-size: 0.9rem;
                font-weight: 400;
                line-height: 1.2;
                color: #1A1A2E;
                background-color: white;
                border: 1px solid #e0d5c5;
                border-radius: 6px;
            }

            .form-control:focus {
                border-color: #C9A84C;
                box-shadow: 0 0 0 3px rgba(201, 168, 76, 0.15);
                outline: none;
            }

            /* Button Styles */
            .btn {
                display: inline-block;
                text-align: center;
                vertical-align: middle;
                padding: 0.75rem 1.5rem;
                border-radius: 6px;
                font-weight: 600;
                font-size: 0.95rem;
                cursor: pointer;
                transition: all 0.15s ease;
                border: 1px solid transparent;
                line-height: 1;
            }

            .btn-primary {
                background: linear-gradient(135deg, #C9A84C, #8B5E3C);
                color: white;
                box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);
            }

            .btn-primary:hover {
                box-shadow: 0 8px 12px rgba(201, 168, 76, 0.3);
                transform: translateY(-1px);
            }

            .btn-secondary {
                background-color: white;
                color: #1A1A2E;
                border-color: #e0d5c5;
                box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);
            }

            .btn-secondary:hover {
                background-color: #F7F3EE;
                border-color: #e0d5c5;
                color: #1A1A2E;
            }

            .btn-success {
                background-color: #10b981;
                color: white;
                border-color: #10b981;
                border: 1px solid #10b981;
            }

            .btn-danger {
                background-color: #ef4444;
                color: white;
                border-color: #ef4444;
                border: 1px solid #ef4444;
            }

            .btn-warning {
                background-color: #f59e0b;
                color: white;
                border-color: #f59e0b;
                border: 1px solid #f59e0b;
            }

            .btn-info {
                background-color: #8B5E3C;
                color: white;
                border-color: #8B5E3C;
                border: 1px solid #8B5E3C;
            }

            .btn-sm {
                padding: 0.4rem 0.8rem;
                font-size: 0.875rem;
            }

            .btn-sm.flex {
                display: inline-flex;
                align-items: center;
                justify-content: center;
            }
        </style>
        <style>
            .form-section {
                display: none;
            }

            .form-section.active {
                display: block;
            }

            .modal {
                display: none;
                position: fixed;
                z-index: 10000 !important;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                overflow: auto;
                background-color: rgba(0, 0, 0, 0.5);
                backdrop-filter: blur(4px);
                -webkit-backdrop-filter: blur(4px);
            }

            .modal-content {
                background-color: #ffffff;
                margin: 5% auto;
                padding: 2rem;
                border-radius: 1rem;
                width: 90%;
                max-width: 500px;
                box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
                position: relative;
                border: 1px solid #e0d5c5;
            }

            .close {
                color: #aaa;
                float: right;
                font-size: 28px;
                font-weight: bold;
                cursor: pointer;
            }

            .close:hover {
                color: black;
            }
        </style>
        <script type="text/javascript">
            function showSection(sectionId, button) {
                var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
                if (hf) hf.value = sectionId;

                var sections = document.querySelectorAll('.form-section');
                for (var i = 0; i < sections.length; i++) {
                    sections[i].style.display = 'none';
                    sections[i].classList.remove('active');
                }

                var buttons = document.querySelectorAll('.tab-btn');
                for (var j = 0; j < buttons.length; j++) {
                    buttons[j].style.background = '#ffffff';
                    buttons[j].style.color = '#7a7a7a';
                    buttons[j].style.borderColor = '#e0d5c5';
                    buttons[j].style.boxShadow = 'none';
                }

                var activeDiv = document.getElementById(sectionId);
                if (activeDiv) {
                    activeDiv.style.display = 'block';
                    activeDiv.classList.add('active');
                }

                if (!button) {
                    var idx = sectionsArray.indexOf(sectionId);
                    if (idx >= 0 && buttons[idx]) button = buttons[idx];
                }

                if (button) {
                    button.style.background = '#C9A84C';
                    button.style.color = '#ffffff';
                    button.style.borderColor = '#C9A84C';
                    button.style.boxShadow = '0 4px 6px -1px rgba(201, 168, 76, 0.2)';
                }
            }

            var sectionsArray = ['divPayment', 'divPersonal', 'divAddress', 'divFamily', 'divEducation', 'divReferences', 'divMembership'];

            function navigateSection(direction) {
                var activeSection = document.querySelector('.form-section.active');
                if (!activeSection) activeSection = document.getElementById('divPayment');

                var currentIndex = sectionsArray.indexOf(activeSection.id);

                if (direction === 'next' && currentIndex < sectionsArray.length - 1) {
                    currentIndex++;
                } else if (direction === 'previous' && currentIndex > 0) {
                    currentIndex--;
                }

                var btns = document.querySelectorAll('.tab-btn');
                showSection(sectionsArray[currentIndex], btns[currentIndex]);
            }
            function previewImage(input) {
                if (input.files && input.files[0]) {
                    var reader = new FileReader();
                    reader.onload = function (e) {
                        var img = document.getElementById('<%= Image1.ClientID %>');
                        if (img) img.src = e.target.result;
                    };
                    reader.readAsDataURL(input.files[0]);
                    }
                }

                function toggleFamilyFields() {
                    var ddl = document.getElementById('<%= ddlMaritalStatus.ClientID %>');
                var content = document.getElementById('family-content');
                var children = document.getElementById('childrenDetails');
                var msg = document.getElementById('family-message');

                if (!ddl || !content || !msg || !children) return;

                var status = ddl.value;
                if (status === 'Single') {
                    content.style.display = 'none';
                    children.style.display = 'none';
                    msg.classList.remove('hidden');
                    msg.style.display = 'block';
                } else {
                    content.style.display = 'block';
                    children.style.display = 'block';
                    msg.classList.add('hidden');
                    msg.style.display = 'none';
                }
            }

            function openReceiptModal() {
                document.getElementById('receiptModal').style.display = 'block';
            }

            function closeReceiptModal() {
                document.getElementById('receiptModal').style.display = 'none';
            }

            // Membership Receipt Modal logic
            function openMembershipModal() {
                document.getElementById('membershipModal').style.display = 'block';
            }

            function closeMembershipModal() {
                document.getElementById('membershipModal').style.display = 'none';
            }

            // Initialize
            function formatDateInput(input) {
                // Strip all non-numeric characters
                var val = input.value.replace(/\D/g, '');
                var formattedVal = '';
                
                if (val.length > 0) {
                    // Limit length to 8 characters (DDMMYYYY)
                    val = val.substring(0, 8);
                    
                    // Format the string dynamically
                    if (val.length <= 2) {
                        formattedVal = val;
                    } else if (val.length <= 4) {
                        formattedVal = val.substring(0, 2) + '-' + val.substring(2);
                    } else {
                        formattedVal = val.substring(0, 2) + '-' + val.substring(2, 4) + '-' + val.substring(4);
                    }
                }
                
                input.value = formattedVal;
            }

            function isValidDate(dateStr) {
                if (!dateStr) return true;
                
                // Format must be precisely DD-MM-YYYY
                var regex = /^(\d{2})-(\d{2})-(\d{4})$/;
                var match = dateStr.match(regex);
                if (!match) return false;
                
                var day = parseInt(match[1], 10);
                var month = parseInt(match[2], 10);
                var year = parseInt(match[3], 10);
                
                if (month < 1 || month > 12) return false;
                if (year < 1900 || year > 2100) return false; // Sensible historical and future limit for membership DOBs
                
                var daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
                
                // Handle Leap Years for February
                if ((year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0)) {
                    daysInMonth[1] = 29;
                }
                
                if (day < 1 || day > daysInMonth[month - 1]) return false;
                
                return true;
            }

            function validateDateInput(input) {
                var dateStr = input.value.trim();
                if (dateStr === '') {
                    // Clear calculated age if it is child DOB
                    var row = input.closest('tr');
                    if (row) {
                        var ageInput = row.querySelector('[id*="txtChildAge"]');
                        if (ageInput) ageInput.value = '';
                    }
                    return true;
                }
                
                if (!isValidDate(dateStr)) {
                    alert('Please enter a valid date in DD-MM-YYYY format (e.g., 25-03-2009).\nInvalid days (like 32) or months (like 13) are not allowed.');
                    input.value = '';
                    
                    var row = input.closest('tr');
                    if (row) {
                        var ageInput = row.querySelector('[id*="txtChildAge"]');
                        if (ageInput) ageInput.value = '';
                    }
                    
                    setTimeout(function() {
                        input.focus();
                    }, 10);
                    return false;
                }
                return true;
            }

            function initDatepickers() {
                // 1. Target DOB field
                var $dob = $("[id$='txtDOB']");
                if ($dob.length) {
                    $dob.datepicker({
                        dateFormat: 'dd-mm-yy',
                        changeMonth: true,
                        changeYear: true,
                        yearRange: 'c-100:c+0', // DOB can be past dates up to today
                        maxDate: 0,
                        onSelect: function(dateText) {
                            validateDateInput(this);
                        }
                    });

                    // Bind dynamic input formatter on user typing
                    $dob.off('input.format').on('input.format', function() {
                        formatDateInput(this);
                    });

                    // Bind change validation on blur / change
                    $dob.off('change.validate').on('change.validate', function() {
                        validateDateInput(this);
                    });
                }

                // 2. Target Child DOB fields
                var $childDOBs = $("[id*='txtChildDOB']");
                if ($childDOBs.length) {
                    $childDOBs.each(function() {
                        var $this = $(this);
                        $this.datepicker({
                            dateFormat: 'dd-mm-yy',
                            changeMonth: true,
                            changeYear: true,
                            yearRange: 'c-30:c+0', // Children generally 0-30 years old
                            maxDate: 0,
                            onSelect: function(dateText) {
                                if (validateDateInput(this)) {
                                    calculateChildAge(this);
                                }
                            }
                        });

                        // Bind dynamic input formatter and instant age calculator on user typing
                        $this.off('input.format').on('input.format', function() {
                            formatDateInput(this);
                            calculateChildAge(this);
                        });

                        // Bind change validation on blur / change
                        $this.off('change.validate').on('change.validate', function() {
                            if (validateDateInput(this)) {
                                calculateChildAge(this);
                            }
                        });
                    });
                }
            }

            function pageLoad() {
                var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
                if (hf && hf.value) {
                    showSection(hf.value, null);
                } else {
                    // Default
                    // showSection('divPersonal', null);
                }
                toggleFamilyFields();
                initDatepickers();
            }

            // Hook for UpdatePanel
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            prm.add_endRequest(function () {
                var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
                if (hf && hf.value) {
                    showSection(hf.value, null);
                }
                toggleFamilyFields();
                initDatepickers();
            });

            function calculateChildAge(input) {
                var dateString = input.value.trim();
                var parts = dateString.split('-');
                if (parts.length !== 3) return;
                var day = parseInt(parts[0], 10);
                var month = parseInt(parts[1], 10) - 1;
                var year = parseInt(parts[2], 10);
                var dob = new Date(year, month, day);
                if (isNaN(dob.getTime())) return;

                var today = new Date();
                var age = today.getFullYear() - dob.getFullYear();
                var m = today.getMonth() - dob.getMonth();
                if (m < 0 || (m === 0 && today.getDate() < dob.getDate())) {
                    age--;
                }

                var row = input.closest('tr');
                if (row) {
                    var ageInput = row.querySelector('[id*="txtChildAge"]');
                    if (ageInput) {
                        ageInput.value = age;
                    }
                }
            }

            function validateRequiredFields() {
                // Check file upload sizes to prevent 'Maximum request length exceeded' crash (4 MB limit)
                var maxFileSizeBytes = 4 * 1024 * 1024;
                
                var fuPhoto = document.getElementById('<%= FileUpload1.ClientID %>');
                if (fuPhoto && fuPhoto.files && fuPhoto.files.length > 0) {
                    var file = fuPhoto.files[0];
                    if (file.size > maxFileSizeBytes) {
                        alert('Error: The selected Applicant Photo ("' + file.name + '") exceeds the maximum size limit of 4 MB.\nPlease compress the image or select a smaller file.');
                        return false;
                    }
                }

                var fuCnicFile = document.getElementById('<%= fuCNIC.ClientID %>');
                if (fuCnicFile && fuCnicFile.files && fuCnicFile.files.length > 0) {
                    var file = fuCnicFile.files[0];
                    if (file.size > maxFileSizeBytes) {
                        alert('Error: The selected CNIC Copy ("' + file.name + '") exceeds the maximum size limit of 4 MB.\nPlease select a smaller file.');
                        return false;
                    }
                }

                var fuFormFile = document.getElementById('<%= fuForm.ClientID %>');
                if (fuFormFile && fuFormFile.files && fuFormFile.files.length > 0) {
                    var file = fuFormFile.files[0];
                    if (file.size > maxFileSizeBytes) {
                        alert('Error: The selected Application Form ("' + file.name + '") exceeds the maximum size limit of 4 MB.\nPlease select a smaller file.');
                        return false;
                    }
                }

                var errors = [];
                var fields = [
                    { id: '<%= txtApplicantName.ClientID %>', label: 'Applicant Name' },
                    { id: '<%= txtFatherName.ClientID %>', label: 'Father Name' },
                    { id: '<%= txtDOB.ClientID %>', label: 'Date of Birth' },
                    { id: '<%= txtNIC.ClientID %>', label: 'NIC #' }
                ];
                
                // Reset borders
                for (var i = 0; i < fields.length; i++) {
                    var el = document.getElementById(fields[i].id);
                    if (el) el.style.borderColor = '#e0d5c5';
                }
                var childDOBs = document.querySelectorAll("[id*='txtChildDOB']");
                for (var j = 0; j < childDOBs.length; j++) {
                    if (childDOBs[j]) childDOBs[j].style.borderColor = '#e0d5c5';
                }
                
                // Validate required fields
                for (var i = 0; i < fields.length; i++) {
                    var el = document.getElementById(fields[i].id);
                    if (!el || el.value.trim() === '') {
                        errors.push(fields[i].label);
                        if (el) el.style.borderColor = '#ef4444';
                    }
                }
                
                // Validate DOB format and validity if filled
                var dobEl = document.getElementById('<%= txtDOB.ClientID %>');
                if (dobEl && dobEl.value.trim() !== '') {
                    if (!isValidDate(dobEl.value.trim())) {
                        dobEl.style.borderColor = '#ef4444';
                        errors.push('Date of Birth (must be a valid date in DD-MM-YYYY format)');
                    }
                }
                
                // Validate Child DOB format and validity if filled
                for (var j = 0; j < childDOBs.length; j++) {
                    var childDobEl = childDOBs[j];
                    if (childDobEl && childDobEl.value.trim() !== '') {
                        if (!isValidDate(childDobEl.value.trim())) {
                            childDobEl.style.borderColor = '#ef4444';
                            errors.push('Child Date of Birth at row ' + (j + 1) + ' (must be a valid date in DD-MM-YYYY format)');
                        }
                    }
                }
                
                if (errors.length > 0) {
                    alert('Please fill in or correct the following fields:\n\n- ' + errors.join('\n- '));
                    return false;
                }
                return confirm('Are you sure you want to save this application?');
            }

            window.addEventListener('load', pageLoad);
        </script>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">


        <asp:UpdatePanel ID="upActiveTab" runat="server" UpdateMode="Conditional">
            <contenttemplate>
                <asp:HiddenField ID="hfActiveTab" runat="server" Value="divPayment" />
            </contenttemplate>
        </asp:UpdatePanel>
        <div class="page-wrapper mt-6" style="margin-top: 0.75rem; /* Heavily reduced */;">
            <div class="card"
                style="background-color: #ffffff; border-radius: 12px; padding: 1.25rem; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); transition: none; /* Removed hover effect */ position: relative; overflow: visible; height: 100%; /* Slightly reduced padding */;">

                <div class="card-header border-b border-subtle pb-6 mb-8 flex flex-col md:flex-row justify-between items-start md:items-center gap-4"
                    style="border-bottom: 1px solid #e0d5c5; border-color: #e0d5c5 !important; padding-bottom: 1.5rem !important; margin-bottom: 2rem; margin-bottom: 2rem !important; justify-content: space-between; gap: 1rem;">
                    <div>
                        <h1 class="text-2xl font-bold text-primary-900 m-0"
                            style="font-size: 1.5rem !important; font-weight: 700; color: #1A1A2E !important; margin: 0;">
                            Application Tracking</h1>
                        <p class="text-secondary mt-1" style="color: #8B5E3C !important;">Manage applicant processing
                            and details</p>
                    </div>
                    <div class="card-actions">
                        <asp:UpdatePanel ID="upHeaderActions" runat="server" UpdateMode="Conditional">
                            <contenttemplate>
                                <asp:Button ID="btnNewApplication" runat="server" Text="New Application"
                                    CssClass="btn btn-secondary" OnClick="btnNewApplication_Click"
                                    style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background-color: white; color: #1A1A2E; border: 1px solid #e0d5c5; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);" />
                                <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="btn btn-primary"
                                    OnClick="btnUpdate_Click" Visible="false"
                                    style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);" />
                                <asp:Button ID="btnApproveAndMove" runat="server" Text="Approved and Move to Convert to Member" CssClass="btn btn-success"
                                    OnClick="btnApproveAndMove_Click" Visible="false" CausesValidation="false"
                                    style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; text-align: center; display: inline-block; line-height: 1; border: 1px solid transparent; background-color: #10b981; color: white; box-shadow: 0 4px 6px rgba(16, 185, 129, 0.2);" />
                            </contenttemplate>
                            <Triggers>
                                <asp:PostBackTrigger ControlID="btnApproveAndMove" />
                            </Triggers>
                        </asp:UpdatePanel>
                    </div>
                </div>



                <asp:UpdatePanel ID="upMainFormContainer" runat="server" UpdateMode="Conditional">
                    <contenttemplate>
                        <asp:PlaceHolder ID="phFormContent" runat="server" Visible="false">
                            <!-- Top Basic Info -->
                                <div style="margin-bottom: 2rem; background: #faf7f2; padding: 1.5rem; border-radius: 0.75rem; border: 1px solid #e0d5c5;">
                                    <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1.5rem; padding-bottom: 1rem; border-bottom: 1px solid #e0d5c5;">
                                        <div style="width: 44px; height: 44px; background: #f5ecd5; color: #C9A84C; display: flex; align-items: center; justify-content: center; border-radius: 0.75rem;">
                                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <circle cx="12" cy="12" r="10"></circle>
                                                <line x1="12" y1="16" x2="12" y2="12"></line>
                                                <line x1="12" y1="8" x2="12.01" y2="8"></line>
                                            </svg>
                                        </div>
                                        <div>
                                            <h2 style="font-size: 1.25rem; font-weight: 700; margin: 0; color: #1A1A2E;">Basic Information</h2>
                                            <p style="font-size: 0.875rem; color: #7a7a7a; margin: 0;">Essential tracking and classification details</p>
                                        </div>
                                    </div>

                                <asp:UpdatePanel ID="upTopFees" runat="server" UpdateMode="Conditional">
                                    <contenttemplate>
                                        <!-- Hidden Financial Fields (Maintained for logic) -->
                                        <div style="display: none;">
                                            <asp:TextBox ID="txtFormReceiptNo" runat="server" />
                                            <asp:TextBox ID="txtFormReceiptDate" runat="server" />
                                            <asp:TextBox ID="txtMemberReceiptNo" runat="server" />
                                            <asp:TextBox ID="txtMemberReceiptDate" runat="server" />
                                            <asp:TextBox ID="txtFormFee" runat="server" />
                                            <asp:TextBox ID="txtMemberFee" runat="server" />
                                        </div>

                                        <!-- Visible Tracking Info in a single parallel line -->
                                        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.5rem;">
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">App Track No</label>
                                                <asp:UpdatePanel ID="upAppTrack" runat="server">
                                                    <contenttemplate>
                                                        <asp:TextBox ID="txtAppTrackNo" runat="server"
                                                            ReadOnly="true" AutoPostBack="true"
                                                            OnTextChanged="txtAppTrackNo_TextChanged"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #7a7a7a; background-color: #F7F3EE; border: 1px solid #e0d5c5; border-radius: 0.5rem; cursor: not-allowed;" />
                                                    </contenttemplate>
                                                </asp:UpdatePanel>
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Application Form Type</label>
                                                <asp:DropDownList ID="ddlMembershipClass" runat="server"
                                                    AutoPostBack="true"
                                                    OnSelectedIndexChanged="ddlMembershipClass_SelectedIndexChanged"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Application Types</label>
                                                <asp:DropDownList ID="ddlMemberTypes" runat="server"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                            </div>
                                        </div>
                                        
                                        <!-- Supplementary Membership Fields -->
                                        <div id="divSupplementary" runat="server" style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.5rem; margin-top: 1rem;" visible="false">
                                             <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                 <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Main Member No <span style="color: #ef4444;">*</span></label>
                                                 <div style="position: relative; display: flex; align-items: center;">
                                                     <asp:TextBox ID="txtMainMemberNo" runat="server" AutoPostBack="true" OnTextChanged="txtMainMemberNo_TextChanged"
                                                         style="width: 100%; padding: 0.625rem 6.5rem 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                                     <asp:Label ID="lblMainMemberBadge" runat="server" Visible="false"
                                                         style="position: absolute; right: 0.5rem; padding: 0.2rem 0.6rem; font-size: 0.75rem; font-weight: 700; border-radius: 9999px; text-transform: uppercase; letter-spacing: 0.03em; pointer-events: none;" />
                                                 </div>
                                             </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Member Name</label>
                                                <asp:TextBox ID="txtMainMemberName" runat="server" ReadOnly="true"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #7a7a7a; background-color: #F7F3EE; border: 1px solid #e0d5c5; border-radius: 0.5rem; cursor: not-allowed;" />
                                            </div>
                                            <div></div>
                                        </div>
                                    </contenttemplate>
                                </asp:UpdatePanel>
                            </div>

                            <!-- TAB BUTTONS -->
                            <div style="display: flex; flex-wrap: wrap; gap: 0.75rem; margin-bottom: 2rem; background: #F7F3EE; padding: 0.5rem; border-radius: 0.75rem; border: 1px solid #e0d5c5;">
                                <button type="button" class="tab-btn" onclick="showSection('divPayment', this)"
                                    style="padding: 0.625rem 1.25rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.875rem; cursor: pointer; transition: all 0.2s; border: none; background: #C9A84C; color: #ffffff; box-shadow: 0 4px 6px -1px rgba(201, 168, 76, 0.2);">
                                    Payment</button>
                                <button type="button" class="tab-btn" onclick="showSection('divPersonal', this)"
                                    style="padding: 0.625rem 1.25rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.875rem; cursor: pointer; transition: all 0.2s; border: none; background: transparent; color: #7a7a7a;">
                                    Personal Info</button>
                                <button type="button" class="tab-btn" onclick="showSection('divAddress', this)"
                                    style="padding: 0.625rem 1.25rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.875rem; cursor: pointer; transition: all 0.2s; border: none; background: transparent; color: #7a7a7a;">
                                    Address</button>
                                <button type="button" class="tab-btn" onclick="showSection('divFamily', this)"
                                    style="padding: 0.625rem 1.25rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.875rem; cursor: pointer; transition: all 0.2s; border: none; background: transparent; color: #7a7a7a;">
                                    Family Info</button>
                                <button type="button" class="tab-btn" onclick="showSection('divEducation', this)"
                                    style="padding: 0.625rem 1.25rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.875rem; cursor: pointer; transition: all 0.2s; border: none; background: transparent; color: #7a7a7a;">
                                    Education & Work</button>
                                <button type="button" class="tab-btn" onclick="showSection('divReferences', this)"
                                    style="padding: 0.625rem 1.25rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.875rem; cursor: pointer; transition: all 0.2s; border: none; background: transparent; color: #7a7a7a;">
                                    References</button>
                                <button type="button" class="tab-btn" onclick="showSection('divMembership', this)"
                                    style="padding: 0.625rem 1.25rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.875rem; cursor: pointer; transition: all 0.2s; border: none; background: transparent; color: #7a7a7a;">
                                    Membership Info</button>
                            </div>
                            <!-- MAIN UPDATE PANEL FOR FORM FIELDS -->
                            <asp:UpdatePanel ID="upApplicantForm" runat="server" UpdateMode="Conditional">
                                <contenttemplate>
                                    <!-- PERSONAL INFO -->
                                    <div id="divPersonal" class="form-section" style="padding: 1.5rem; background: #ffffff; border-radius: 1rem; border: 1px solid #e0d5c5; margin-bottom: 2rem;">
                                        <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 1px solid #F7F3EE;">
                                            <div style="width: 44px; height: 44px; background: #faf7f2; color: #8B5E3C; display: flex; align-items: center; justify-content: center; border-radius: 0.75rem;">
                                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                                    <circle cx="12" cy="7" r="4"></circle>
                                                </svg>
                                            </div>
                                            <div>
                                                <h2 style="font-size: 1.25rem; font-weight: 700; margin: 0; color: #1A1A2E;">Personal Information</h2>
                                                <p style="font-size: 0.875rem; color: #7a7a7a; margin: 0;">Provide your basic identity and professional details</p>
                                            </div>
                                        </div>

                                        <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 2.5rem;">
                                            <div style="display: flex; flex-direction: column; gap: 1.5rem;">
                                                <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1.5rem;">
                                                    <div style="display: flex; flex-direction: column; gap: 0.5rem; grid-column: span 2;">
                                                        <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">
                                                            Applicant Name <span style="color: #ef4444;">*</span></label>
                                                        <asp:TextBox ID="txtApplicantName" runat="server"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none; transition: all 0.2s;" />
                                                    </div>

                                                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                        <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">
                                                            Father Name <span style="color: #ef4444;">*</span></label>
                                                        <asp:TextBox ID="txtFatherName" runat="server"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                                    </div>
                                                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                        <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">
                                                            Date of Birth <span style="color: #ef4444;">*</span></label>
                                                        <asp:TextBox ID="txtDOB" runat="server" placeholder="DD-MM-YYYY"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                                    </div>

                                                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                        <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">CNIC #</label>
                                                        <asp:TextBox ID="txtNIC" runat="server"
                                                            AutoPostBack="true" OnTextChanged="txtNIC_TextChanged"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                                        <asp:Label ID="lblNICExists" runat="server" style="color: #ef4444; font-size: 0.75rem;"
                                                            Visible="false"></asp:Label>
                                                    </div>
                                                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                        <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">
                                                            Marital Status <span style="color: #ef4444;">*</span></label>
                                                        <asp:DropDownList ID="ddlMaritalStatus" runat="server"
                                                            onchange="toggleFamilyFields()"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;">
                                                            <asp:ListItem Text="--Select--" Value="" />
                                                            <asp:ListItem Text="Single" Value="Single" />
                                                            <asp:ListItem Text="Married" Value="Married" />
                                                            <asp:ListItem Text="Divorced" Value="Divorced" />
                                                            <asp:ListItem Text="Widow" Value="Widow" />
                                                        </asp:DropDownList>
                                                    </div>

                                                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                        <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">
                                                            Profession <span style="color: #ef4444;">*</span></label>
                                                        <asp:TextBox ID="txtProfession" runat="server"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                                    </div>
                                                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                        <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Company <span
                                                                style="color: #ef4444;">*</span></label>
                                                        <asp:TextBox ID="txtCompanyName" runat="server"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                                    </div>

                                                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                        <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">
                                                            Designation <span style="color: #ef4444;">*</span></label>
                                                        <asp:TextBox ID="txtDesignation" runat="server"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                                    </div>
                                                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                        <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">
                                                            Nationality <span style="color: #ef4444;">*</span></label>
                                                        <asp:DropDownList ID="ddlNationality" runat="server"
                                                            Enabled="false"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #7a7a7a; background-color: #F7F3EE; border: 1px solid #e0d5c5; border-radius: 0.5rem; cursor: not-allowed;">
                                                            <asp:ListItem Text="Pakistani" Value="Pakistani"
                                                                Selected="True" />
                                                        </asp:DropDownList>
                                                    </div>

                                                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                        <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">
                                                            Monthly Income <span style="color: #ef4444;">*</span></label>
                                                        <asp:TextBox ID="txtMonthlyIncome" runat="server" Text="0"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                                    </div>
                                                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                        <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">
                                                            Currency <span style="color: #ef4444;">*</span></label>
                                                        <asp:DropDownList ID="ddlCurrency" runat="server"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;">
                                                            <asp:ListItem Text="--Select--" Value="" />
                                                            <asp:ListItem Text="USD" Value="USD" />
                                                            <asp:ListItem Text="PKR" Value="PKR" />
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Photos Column -->
                                            <div style="background: #faf7f2; padding: 1.5rem; border-radius: 0.75rem; border: 1px solid #e0d5c5; display: flex; flex-direction: column; gap: 1.5rem;">
                                                <div>
                                                    <h4 style="font-size: 1rem; font-weight: 700; color: #1A1A2E; margin-bottom: 1rem;">Applicant Photo</h4>
                                                    <div style="display: flex; flex-direction: column; align-items: center; gap: 1rem;">
                                                        <asp:Image ID="Image1" runat="server"
                                                            style="width: 160px; height: 160px; border-radius: 0.75rem; border: 2px solid #ffffff; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); object-fit: cover; background: #e0d5c5;" />
                                                        <label style="width: 100%; display: block; background: #ffffff; border: 1px solid #e0d5c5; color: #8B5E3C; padding: 0.625rem; border-radius: 0.5rem; text-align: center; font-weight: 600; cursor: pointer; transition: all 0.2s;">
                                                            <span>Change Photo</span>
                                                            <asp:FileUpload ID="FileUpload1" runat="server" CssClass="hidden" onchange="previewImage(this)" />
                                                        </label>
                                                    </div>
                                                </div>

                                                <div style="border-top: 1px solid #e0d5c5; pt-4; margin-top: 0.5rem; padding-top: 1.5rem;">
                                                    <h4 style="font-size: 1rem; font-weight: 700; color: #1A1A2E; margin-bottom: 1.25rem;">Documents Upload</h4>
                                                    <div style="display: flex; flex-direction: column; gap: 1.25rem;">
                                                        <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                            <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">CNIC Copy</label>
                                                            <asp:FileUpload ID="fuCNIC" runat="server"
                                                                style="width: 100%; padding: 0.5rem; font-size: 0.875rem; color: #1A1A2E; background: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem;" />
                                                            <div id="divCNICLink" runat="server" visible="false" style="margin-top: 0.5rem; display: flex; align-items: center; gap: 0.5rem;">
                                                                <asp:HyperLink ID="lnkCNIC" runat="server" Target="_blank" Text="View CNIC" style="color: #C9A84C; font-weight: 600; font-size: 0.875rem; text-decoration: none;" />
                                                                <asp:Label ID="lblCNICStatus" runat="server" style="font-size: 0.75rem; color: #7a7a7a;" />
                                                            </div>
                                                        </div>
                                                        <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                            <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Application Form</label>
                                                            <asp:FileUpload ID="fuForm" runat="server"
                                                                style="width: 100%; padding: 0.5rem; font-size: 0.875rem; color: #1A1A2E; background: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem;" />
                                                            <div id="divFormLink" runat="server" visible="false" style="margin-top: 0.5rem; display: flex; align-items: center; gap: 0.5rem;">
                                                                <asp:HyperLink ID="lnkForm" runat="server" Target="_blank" Text="View Form" style="color: #C9A84C; font-weight: 600; font-size: 0.875rem; text-decoration: none;" />
                                                                <asp:Label ID="lblFormStatus" runat="server" style="font-size: 0.75rem; color: #7a7a7a;" />
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div style="display: flex; justify-content: center; gap: 1rem; margin-top: 2.5rem; padding-top: 1.5rem; border-top: 1px solid #F7F3EE;">
                                            <asp:Button ID="btnPrevPersonal" runat="server" Text="Previous"
                                                OnClientClick="navigateSection('previous'); return false;"
                                                style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #ffffff; color: #8B5E3C; border: 1px solid #e0d5c5; transition: all 0.2s;" />
                                            <asp:Button ID="btnNextPersonal" runat="server" Text="Next"
                                                OnClientClick="navigateSection('next'); return false;"
                                                style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #C9A84C; color: #ffffff; border: 1px solid #C9A84C; box-shadow: 0 4px 6px -1px rgba(201, 168, 76, 0.2); transition: all 0.2s;" />
                                            <asp:Button ID="btnSavePersonal" runat="server" Text="Save" Visible="false"
                                                OnClick="btnSaveMembership_Click"
                                                OnClientClick="return validateRequiredFields();"
                                                style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #10b981; color: #ffffff; border: 1px solid #10b981; box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.2); transition: all 0.2s;" />
                                        </div>
                                    </div>

                                    <!-- ADDRESS -->
                                    <div id="divAddress" class="form-section" style="padding: 1.5rem; background: #ffffff; border-radius: 1rem; border: 1px solid #e0d5c5; margin-bottom: 2rem;">
                                        <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 1px solid #F7F3EE;">
                                            <div style="width: 44px; height: 44px; background: #ecfdf5; color: #10b981; display: flex; align-items: center; justify-content: center; border-radius: 0.75rem;">
                                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                                                    <circle cx="12" cy="10" r="3"></circle>
                                                </svg>
                                            </div>
                                            <div>
                                                <h2 style="font-size: 1.25rem; font-weight: 700; margin: 0; color: #1A1A2E;">Address Information</h2>
                                                <p style="font-size: 0.875rem; color: #7a7a7a; margin: 0;">Residential and office contact details</p>
                                            </div>
                                        </div>

                                        <h3 style="font-size: 1rem; font-weight: 700; color: #1e293b; margin-bottom: 1.25rem; display: flex; align-items: center; gap: 0.5rem;">
                                            <span style="width: 8px; height: 8px; background: #10b981; border-radius: 50%;"></span>
                                            Residential Address
                                        </h3>
                                        <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1.5rem; margin-bottom: 2.5rem;">
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem; grid-column: span 2;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Address</label>
                                                <asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" Rows="2"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none; resize: none;" />
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Country</label>
                                                <asp:DropDownList ID="ddlCountry" runat="server"
                                                    AutoPostBack="true"
                                                    OnSelectedIndexChanged="ddlCountry_SelectedIndexChanged"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;">
                                                </asp:DropDownList>
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Province</label>
                                                <asp:DropDownList ID="ddlProvince" runat="server"
                                                    AutoPostBack="true"
                                                    OnSelectedIndexChanged="ddlProvince_SelectedIndexChanged"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;">
                                                </asp:DropDownList>
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">City</label>
                                                <asp:DropDownList ID="ddlCity" runat="server"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;">
                                                </asp:DropDownList>
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Zip Code</label>
                                                <asp:TextBox ID="txtZip" runat="server"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                            </div>
                                        </div>

                                        <h3 style="font-size: 1rem; font-weight: 700; color: #1e293b; margin-bottom: 1.25rem; display: flex; align-items: center; gap: 0.5rem;">
                                            <span style="width: 8px; height: 8px; background: #7a7a7a; border-radius: 50%;"></span>
                                            Office Address
                                        </h3>
                                        <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1.5rem; margin-bottom: 2.5rem;">
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem; grid-column: span 2;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Address</label>
                                                <asp:TextBox ID="txtOfficeAddress" runat="server" TextMode="MultiLine" Rows="2"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none; resize: none;" />
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Country</label>
                                                <asp:DropDownList ID="ddlOfficeCountry" runat="server"
                                                    AutoPostBack="true"
                                                    OnSelectedIndexChanged="ddlOfficeCountry_SelectedIndexChanged"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;">
                                                </asp:DropDownList>
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Province</label>
                                                <asp:DropDownList ID="ddlOfficeProvince" runat="server"
                                                    AutoPostBack="true"
                                                    OnSelectedIndexChanged="ddlOfficeProvince_SelectedIndexChanged"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;">
                                                </asp:DropDownList>
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">City</label>
                                                <asp:DropDownList ID="ddlOfficeCity" runat="server"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;">
                                                </asp:DropDownList>
                                            </div>
                                        </div>

                                        <h3 style="font-size: 1rem; font-weight: 700; color: #1e293b; margin-bottom: 1.25rem; display: flex; align-items: center; gap: 0.5rem;">
                                            <span style="width: 8px; height: 8px; background: #8B5E3C; border-radius: 50%;"></span>
                                            Contact Details
                                        </h3>
                                        <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1.5rem; margin-bottom: 2.5rem;">
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <asp:TextBox ID="txtPhone" runat="server"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Mobile</label>
                                                <asp:TextBox ID="txtMobile" runat="server"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem; grid-column: span 2;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Email</label>
                                                <asp:TextBox ID="txtEmail" runat="server"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                            </div>
                                        </div>

                                        <div style="display: flex; justify-content: center; gap: 1rem; margin-top: 2.5rem; padding-top: 1.5rem; border-top: 1px solid #F7F3EE;">
                                            <asp:Button ID="btnPrevAddress" runat="server" Text="Previous"
                                                OnClientClick="navigateSection('previous'); return false;"
                                                style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #ffffff; color: #8B5E3C; border: 1px solid #e0d5c5; transition: all 0.2s;" />
                                            <asp:Button ID="btnNextAddress" runat="server" Text="Next"
                                                OnClientClick="navigateSection('next'); return false;"
                                                style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #C9A84C; color: #ffffff; border: 1px solid #C9A84C; box-shadow: 0 4px 6px -1px rgba(201, 168, 76, 0.2); transition: all 0.2s;" />
                                            <asp:Button ID="btnSaveAddress" runat="server" Text="Save" Visible="false"
                                                OnClick="btnSaveMembership_Click"
                                                OnClientClick="return validateRequiredFields();"
                                                style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #10b981; color: #ffffff; border: 1px solid #10b981; box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.2); transition: all 0.2s;" />
                                        </div>
                                    </div>

                                    <!-- FAMILY INFO -->
                                    <div id="divFamily" class="form-section" style="padding: 1.5rem; background: #ffffff; border-radius: 1rem; border: 1px solid #e0d5c5; margin-bottom: 2rem;">
                                        <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 1px solid #F7F3EE;">
                                            <div style="width: 44px; height: 44px; background: #faf7f2; color: #8B5E3C; display: flex; align-items: center; justify-content: center; border-radius: 0.75rem;">
                                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                                                    <circle cx="9" cy="7" r="4"></circle>
                                                    <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                                                    <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                                                </svg>
                                            </div>
                                            <div>
                                                <h2 style="font-size: 1.25rem; font-weight: 700; margin: 0; color: #1A1A2E;">Family Information</h2>
                                                <p style="font-size: 0.875rem; color: #7a7a7a; margin: 0;">Spouse and dependents details</p>
                                            </div>
                                        </div>

                                        <div id="family-message" class="hidden" style="text-align: center; padding: 3rem 1.5rem; background: #faf7f2; border-radius: 0.75rem; border: 1px dashed #e0d5c5; margin-bottom: 2rem;">
                                            <div style="color: #a09080; margin-bottom: 1rem;">
                                                <svg style="margin: 0 auto;" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <circle cx="12" cy="12" r="10"></circle>
                                                    <line x1="12" y1="8" x2="12" y2="12"></line>
                                                    <line x1="12" y1="16" x2="12.01" y2="16"></line>
                                                </svg>
                                            </div>
                                            <h3 style="font-size: 1.125rem; font-weight: 600; color: #1e293b; margin-bottom: 0.5rem;">Not Applicable</h3>
                                            <p style="font-size: 0.875rem; color: #7a7a7a;">Family information is not required for single applicants.</p>
                                        </div>

                                        <div id="family-content">
                                            <div style="margin-bottom: 2.5rem;">
                                                <h3 style="font-size: 1rem; font-weight: 700; color: #1e293b; margin-bottom: 1.5rem; display: flex; align-items: center; gap: 0.5rem;">
                                                    <span style="width: 8px; height: 8px; background: #8B5E3C; border-radius: 50%;"></span>
                                                    Spouse Details
                                                </h3>
                                                <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1.5rem;">
                                                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                        <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Spouse Name</label>
                                                        <asp:TextBox ID="txtSpouseName" runat="server" placeholder="Enter Spouse Name"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                                    </div>
                                                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                        <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Spouse Profession</label>
                                                        <asp:DropDownList ID="ddlSpouseProfession" runat="server"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;">
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                        <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Spouse CNIC/B-Form No</label>
                                                        <asp:TextBox ID="txtSP_CNIC" runat="server" placeholder="Enter Spouse CNIC"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                                    </div>
                                                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                        <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Spouse Phone</label>
                                                        <asp:TextBox ID="txtSpousePhone" runat="server" placeholder="Spouse Phone No"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                                    </div>
                                                    <div style="display: flex; flex-direction: column; gap: 0.5rem; grid-column: span 2;">
                                                        <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Spouse Education</label>
                                                        <asp:DropDownList ID="ddlEducation" runat="server"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                            </div>
                                            <asp:UpdatePanel ID="upFamilyCounts" runat="server" UpdateMode="Conditional">
                                                <contenttemplate>
                                                    <div style="margin-bottom: 2.5rem;">
                                                        <h3 style="font-size: 1rem; font-weight: 700; color: #1e293b; margin-bottom: 1.5rem; display: flex; align-items: center; gap: 0.5rem;">
                                                            <span style="width: 8px; height: 8px; background: #10b981; border-radius: 50%;"></span>
                                                            Family Summary
                                                        </h3>
                                                        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.5rem;">
                                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">No. of Spouse</label>
                                                                <asp:TextBox ID="txtNumberOfSpouse" runat="server" TextMode="Number" Text="0" min="0"
                                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                                            </div>
                                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">No. of Sons</label>
                                                                <asp:TextBox ID="txtNumberOfSons" runat="server" TextMode="Number" Text="0" min="0"
                                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                                            </div>
                                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">No. of Daughters</label>
                                                                <asp:TextBox ID="txtNumberOfDaughters" runat="server" TextMode="Number" Text="0" min="0"
                                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                                            </div>
                                                            <asp:TextBox ID="txtChildren" runat="server" Text="0" style="display: none;" />
                                                        </div>
                                                    </div>
                                                </contenttemplate>
                                            </asp:UpdatePanel>
                                            </div>

                                            <div id="childrenDetails" style="display: none; margin-top: 2rem;">
                                                <h3 style="font-size: 1.15rem; font-weight: 700; color: #1A1A2E; margin-bottom: 1.5rem; padding-bottom: 0.5rem; border-bottom: 1px solid #e0d5c5;">Children Details</h3>
                                                <asp:UpdatePanel ID="upChildren" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true">
                                                    <contenttemplate>
                                                        <div style="background: #faf7f2; border: 1px solid #e0d5c5; border-radius: 0.75rem; padding: 1rem; margin-bottom: 1.5rem; overflow-x: auto;">
                                                            <asp:GridView ID="gvChildren" runat="server" AutoGenerateColumns="false" ShowHeader="true" OnRowCommand="gvChildren_RowCommand"
                                                                CssClass="table" GridLines="None"
                                                                style="width: 100%; border-collapse: collapse; background: #ffffff; border-radius: 0.5rem; overflow: hidden; border: 1px solid #e0d5c5;">
                                                                <Columns>
                                                                    <asp:TemplateField HeaderText="#">
                                                                        <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="Name">
                                                                        <ItemTemplate>
                                                                            <asp:TextBox ID="txtChildName" runat="server" Text='<%# Bind("ChildName") %>'
                                                                                style="width: 100%; padding: 0.5rem; border: 1px solid #e0d5c5; border-radius: 0.375rem;" />
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="Relationship">
                                                                        <ItemTemplate>
                                                                            <asp:DropDownList ID="ddlChildRelation" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlChildRelation_SelectedIndexChanged" SelectedValue='<%# Bind("Relationship") %>'
                                                                                style="width: 100%; padding: 0.5rem; border: 1px solid #e0d5c5; border-radius: 0.375rem;">
                                                                                <asp:ListItem Value="Son">Son</asp:ListItem>
                                                                                <asp:ListItem Value="Daughter">Daughter</asp:ListItem>
                                                                            </asp:DropDownList>
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="DOB">
                                                                        <ItemTemplate>
                                                                            <asp:TextBox ID="txtChildDOB" runat="server" placeholder="DD-MM-YYYY" Text='<%# Bind("DOB", "{0:dd-MM-yyyy}") %>' onchange="formatDateInput(this); calculateChildAge(this)"
                                                                                style="width: 100%; padding: 0.5rem; border: 1px solid #e0d5c5; border-radius: 0.375rem;" />
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="Age">
                                                                        <ItemTemplate>
                                                                            <asp:TextBox ID="txtChildAge" runat="server" Text='<%# Bind("Age") %>' ReadOnly="true"
                                                                                style="width: 60px; padding: 0.5rem; border: 1px solid #e0d5c5; border-radius: 0.375rem; background: #F7F3EE;" />
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="CNIC/B-Form">
                                                                        <ItemTemplate>
                                                                            <asp:TextBox ID="txtChildCNIC" runat="server" Text='<%# Bind("CNICNo") %>'
                                                                                style="width: 100%; padding: 0.5rem; border: 1px solid #e0d5c5; border-radius: 0.375rem;" />
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="Action">
                                                                        <ItemTemplate>
                                                                            <asp:Button ID="btnDeleteChild" runat="server" Text="Remove" CommandName="DeleteChild" CommandArgument='<%# Container.DataItemIndex %>' UseSubmitBehavior="false"
                                                                                style="padding: 0.375rem 0.75rem; background: #ef4444; color: #ffffff; border: none; border-radius: 0.375rem; font-size: 0.75rem; font-weight: 600; cursor: pointer;" />
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                </Columns>
                                                                <EmptyDataTemplate>
                                                                    <div style="padding: 2rem; text-align: center; color: #7a7a7a; font-style: italic;">No children added. Click 'Add Child' to start.</div>
                                                                </EmptyDataTemplate>
                                                            </asp:GridView>
                                                        </div>
                                                        <div style="display: flex; justify-content: flex-end;">
                                                            <asp:Button ID="btnAddChild" runat="server" Text="+ Add Child" OnClick="btnAddChild_Click" UseSubmitBehavior="false"
                                                                style="padding: 0.625rem 1.25rem; background: #C9A84C; color: #ffffff; border: none; border-radius: 0.5rem; font-weight: 600; cursor: pointer; transition: all 0.2s; box-shadow: 0 4px 6px -1px rgba(201, 168, 76, 0.2);" />
                                                        </div>
                                                    </contenttemplate>
                                                </asp:UpdatePanel>
                                            </div>
                                        </div>

                                        <div style="display: none; justify-content: center; gap: 1rem; margin-top: 2.5rem; padding-top: 1.5rem; border-top: 1px solid #F7F3EE;">
                                            <asp:Button ID="btnPrevFamily" runat="server" Text="Previous"
                                                OnClientClick="navigateSection('previous'); return false;"
                                                style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #ffffff; color: #8B5E3C; border: 1px solid #e0d5c5; transition: all 0.2s;" />
                                            <asp:Button ID="btnNextFamily" runat="server" Text="Next"
                                                OnClientClick="navigateSection('next'); return false;"
                                                style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #C9A84C; color: #ffffff; border: 1px solid #C9A84C; box-shadow: 0 4px 6px -1px rgba(201, 168, 76, 0.2); transition: all 0.2s;" />
                                            <asp:Button ID="btnSaveFamily" runat="server" Text="Save" Visible="false"
                                                OnClick="btnSaveMembership_Click"
                                                OnClientClick="return validateRequiredFields();"
                                                style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #10b981; color: #ffffff; border: 1px solid #10b981; box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.2); transition: all 0.2s;" />
                                        </div>
                                    </div>
                                    </div>

                                    <div id="divEducation" class="form-section" style="padding: 1.5rem; background: #ffffff; border-radius: 1rem; border: 1px solid #e0d5c5; margin-bottom: 2rem;">
                                        <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 1px solid #F7F3EE;">
                                            <div style="width: 44px; height: 44px; background: #fdf4ff; color: #a855f7; display: flex; align-items: center; justify-content: center; border-radius: 0.75rem;">
                                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <path d="M22 10v6M2 10l10-5 10 5-10 5z"></path>
                                                    <path d="M6 12v5c3 3 9 3 12 0v-5"></path>
                                                </svg>
                                            </div>
                                            <div>
                                                <h2 style="font-size: 1.25rem; font-weight: 700; margin: 0; color: #1A1A2E;">Education & Work Experience</h2>
                                                <p style="font-size: 0.875rem; color: #7a7a7a; margin: 0;">Academic and professional background</p>
                                            </div>
                                        </div>

                                        <h3 style="font-size: 1rem; font-weight: 700; color: #1e293b; margin-bottom: 1.25rem; display: flex; align-items: center; gap: 0.5rem;">
                                            <span style="width: 8px; height: 8px; background: #a855f7; border-radius: 50%;"></span>
                                            Academic History
                                        </h3>
                                        <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1.5rem; margin-bottom: 2.5rem;">
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem; grid-column: span 2;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Institute</label>
                                                <asp:TextBox ID="txtInstitute" runat="server"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Degree Obtained</label>
                                                <asp:DropDownList ID="ddlDegree" runat="server"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;">
                                                </asp:DropDownList>
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Year</label>
                                                <asp:TextBox ID="txtYear" runat="server"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                            </div>
                                        </div>

                                        <h3 style="font-size: 1rem; font-weight: 700; color: #1e293b; margin-bottom: 1.25rem; display: flex; align-items: center; gap: 0.5rem;">
                                            <span style="width: 8px; height: 8px; background: #8b5cf6; border-radius: 50%;"></span>
                                            Work Experience
                                        </h3>
                                        <div style="margin-bottom: 2rem;">
                                            <asp:TextBox ID="txtWorkExperience" runat="server" TextMode="MultiLine" Rows="3"
                                                style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none; resize: vertical;" />
                                        </div>

                                        <div style="display: flex; justify-content: center; gap: 1rem; margin-top: 2.5rem; padding-top: 1.5rem; border-top: 1px solid #F7F3EE;">
                                            <asp:Button ID="btnPrevEducation" runat="server" Text="Previous"
                                                OnClientClick="navigateSection('previous'); return false;"
                                                style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #ffffff; color: #8B5E3C; border: 1px solid #e0d5c5; transition: all 0.2s;" />
                                            <asp:Button ID="btnNextEducation" runat="server" Text="Next"
                                                OnClientClick="navigateSection('next'); return false;"
                                                style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #C9A84C; color: #ffffff; border: 1px solid #C9A84C; box-shadow: 0 4px 6px -1px rgba(201, 168, 76, 0.2); transition: all 0.2s;" />
                                            <asp:Button ID="btnSaveEducation" runat="server" Text="Save" Visible="false"
                                                OnClick="btnSaveMembership_Click"
                                                OnClientClick="return validateRequiredFields();"
                                                style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #10b981; color: #ffffff; border: 1px solid #10b981; box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.2); transition: all 0.2s;" />
                                        </div>
                                    </div>

                                    <!-- REFERENCES -->
                                    <div id="divReferences" class="form-section" style="padding: 1.5rem; background: #ffffff; border-radius: 1rem; border: 1px solid #e0d5c5; margin-bottom: 2rem;">
                                        <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 1px solid #F7F3EE;">
                                            <div style="width: 44px; height: 44px; background: #ecfdf5; color: #10b981; display: flex; align-items: center; justify-content: center; border-radius: 0.75rem;">
                                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                                                    <circle cx="8.5" cy="7" r="4"></circle>
                                                    <polyline points="17 11 19 13 23 9"></polyline>
                                                </svg>
                                            </div>
                                            <div>
                                                <h2 style="font-size: 1.25rem; font-weight: 700; margin: 0; color: #1A1A2E;">Members' References</h2>
                                                <p style="font-size: 0.875rem; color: #7a7a7a; margin: 0;">Referrals from existing members</p>
                                            </div>
                                        </div>

                                        <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1.5rem;">
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Proposer 1 (Member No)</label>
                                                <div style="position: relative; display: flex; align-items: center;">
                                                    <asp:TextBox ID="txtProposer1" runat="server" AutoPostBack="true" OnTextChanged="txtProposer1_TextChanged"
                                                        style="width: 100%; padding: 0.625rem 6.5rem 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                                    <asp:Label ID="lblProposer1Badge" runat="server" Visible="false"
                                                        style="position: absolute; right: 0.5rem; padding: 0.2rem 0.6rem; font-size: 0.75rem; font-weight: 700; border-radius: 9999px; text-transform: uppercase; letter-spacing: 0.03em; pointer-events: none;" />
                                                </div>
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Relation</label>
                                                <asp:TextBox ID="txtRelation1" runat="server"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Proposer 2 (Member No)</label>
                                                <div style="position: relative; display: flex; align-items: center;">
                                                    <asp:TextBox ID="txtProposer2" runat="server" AutoPostBack="true" OnTextChanged="txtProposer2_TextChanged"
                                                        style="width: 100%; padding: 0.625rem 6.5rem 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                                    <asp:Label ID="lblProposer2Badge" runat="server" Visible="false"
                                                        style="position: absolute; right: 0.5rem; padding: 0.2rem 0.6rem; font-size: 0.75rem; font-weight: 700; border-radius: 9999px; text-transform: uppercase; letter-spacing: 0.03em; pointer-events: none;" />
                                                </div>
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Relation</label>
                                                <asp:TextBox ID="txtRelation2" runat="server"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                            </div>
                                        </div>

                                        <div style="display: flex; justify-content: center; gap: 1rem; margin-top: 2.5rem; padding-top: 1.5rem; border-top: 1px solid #F7F3EE;">
                                            <asp:Button ID="btnPrevReferences" runat="server" Text="Previous"
                                                OnClientClick="navigateSection('previous'); return false;"
                                                style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #ffffff; color: #8B5E3C; border: 1px solid #e0d5c5; transition: all 0.2s;" />
                                            <asp:Button ID="btnNextReferences" runat="server" Text="Next"
                                                OnClientClick="navigateSection('next'); return false;"
                                                style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #C9A84C; color: #ffffff; border: 1px solid #C9A84C; box-shadow: 0 4px 6px -1px rgba(201, 168, 76, 0.2); transition: all 0.2s;" />
                                            <asp:Button ID="btnSaveReferences" runat="server" Text="Save" Visible="false"
                                                OnClick="btnSaveMembership_Click"
                                                OnClientClick="return validateRequiredFields();"
                                                style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #10b981; color: #ffffff; border: 1px solid #10b981; box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.2); transition: all 0.2s;" />
                                        </div>
                                    </div>

                                    <div id="divMembership" class="form-section" style="padding: 1.5rem; background: #ffffff; border-radius: 1rem; border: 1px solid #e0d5c5; margin-bottom: 2rem;">
                                        <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 1px solid #F7F3EE;">
                                            <div style="width: 44px; height: 44px; background: #fff7ed; color: #f59e0b; display: flex; align-items: center; justify-content: center; border-radius: 0.75rem;">
                                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"></path>
                                                </svg>
                                            </div>
                                            <div>
                                                <h2 style="font-size: 1.25rem; font-weight: 700; margin: 0; color: #1A1A2E;">Membership Details</h2>
                                                <p style="font-size: 0.875rem; color: #7a7a7a; margin: 0;">Interests and facilities</p>
                                            </div>
                                        </div>

                                        <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1.5rem;">
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem; grid-column: span 2;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Area of Interest</label>
                                                <asp:TextBox ID="txtAreaInterest" runat="server"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem; grid-column: span 2;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Facilities to be used</label>
                                                <asp:TextBox ID="txtFacilities" runat="server"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem; grid-column: span 2;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Other Memberships</label>
                                                <asp:TextBox ID="txtOtherMemberships" runat="server"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Preferred No.</label>
                                                <asp:TextBox ID="txtPreferredNo" runat="server"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                            </div>
                                            <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Total Payment</label>
                                                <asp:TextBox ID="txtMFee" runat="server" ReadOnly="true"
                                                    style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #7a7a7a; background-color: #F7F3EE; border: 1px solid #e0d5c5; border-radius: 0.5rem;" />
                                            </div>
                                        </div>

                                        <div style="display: flex; justify-content: center; gap: 1rem; margin-top: 2.5rem; padding-top: 1.5rem; border-top: 1px solid #F7F3EE;">
                                            <asp:Button ID="btnPrevMembership" runat="server" Text="Previous"
                                                OnClientClick="navigateSection('previous'); return false;"
                                                style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #ffffff; color: #8B5E3C; border: 1px solid #e0d5c5; transition: all 0.2s;" />
                                            <asp:Button ID="btnNextMembership" runat="server" Text="Next"
                                                OnClientClick="navigateSection('next'); return false;"
                                                style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #C9A84C; color: #ffffff; border: 1px solid #C9A84C; box-shadow: 0 4px 6px -1px rgba(201, 168, 76, 0.2); transition: all 0.2s;" />
                                            <asp:Button ID="btnSaveMembershipFinal" runat="server" Text="Save" Visible="false"
                                                OnClick="btnSaveMembership_Click"
                                                OnClientClick="return validateRequiredFields();"
                                                style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #10b981; color: #ffffff; border: 1px solid #10b981; box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.2); transition: all 0.2s;" />
                                        </div>
                                    </div>
                                </contenttemplate>
                                <triggers>
                                    <asp:AsyncPostBackTrigger ControlID="txtNIC" EventName="TextChanged" />
                                    <asp:AsyncPostBackTrigger ControlID="txtAppTrackNo" EventName="TextChanged" />
                                </triggers>
                            </asp:UpdatePanel>

                            <!-- PAYMENT INFO -->
                            <div id="divPayment" class="form-section"
                                style="padding: 1rem; margin-bottom: 1rem;">
                                <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 2.5rem; padding-bottom: 1rem; border-bottom: 1px solid #F7F3EE;">
                                    <div style="display: flex; align-items: center; gap: 1rem;">
                                        <div style="width: 44px; height: 44px; background: #faf7f2; color: #C9A84C; display: flex; align-items: center; justify-content: center; border-radius: 0.75rem;">
                                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <rect x="2" y="5" width="20" height="14" rx="2" ry="2"></rect>
                                                <line x1="2" y1="10" x2="22" y2="10"></line>
                                            </svg>
                                        </div>
                                        <div>
                                            <h2 style="font-size: 1.25rem; font-weight: 700; margin: 0; color: #1A1A2E;">Allocated Receipts</h2>
                                            <p style="font-size: 0.875rem; color: #7a7a7a; margin: 0;">Manage all receipts allocated to this application</p>
                                        </div>
                                    </div>
                                    <button type="button" onclick="openReceiptModal()"
                                        style="padding: 0.625rem 1.25rem; background: #C9A84C; color: #ffffff; border: none; border-radius: 0.5rem; font-weight: 600; cursor: pointer; transition: all 0.2s; display: flex; align-items: center; gap: 0.5rem; box-shadow: 0 4px 6px -1px rgba(201, 168, 76, 0.2);">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                                            <line x1="12" y1="5" x2="12" y2="19"></line>
                                            <line x1="5" y1="12" x2="19" y2="12"></line>
                                        </svg>
                                        Add Receipt
                                    </button>
                                </div>

                                <!-- Total Payments Summary Card -->
                                <asp:UpdatePanel ID="upPaymentSummary" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <div style="margin-bottom: 2rem; max-width: 420px;">
                                            <div style="background: #faf7f2; padding: 1.25rem; border-radius: 0.75rem; border: 1px solid #e0d5c5; display: flex; align-items: center; gap: 1rem; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                                                <div style="width: 48px; height: 48px; background: #ecfdf5; border: 1px solid #a7f3d0; color: #10b981; display: flex; align-items: center; justify-content: center; border-radius: 50%;">
                                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                        <rect x="2" y="4" width="20" height="16" rx="2" ry="2"></rect>
                                                        <line x1="12" y1="18" x2="12" y2="6"></line>
                                                        <line x1="8" y1="12" x2="16" y2="12"></line>
                                                    </svg>
                                                </div>
                                                <div style="flex-grow: 1;">
                                                     <label style="font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: #7a7a7a; font-weight: 600; display: block; margin-bottom: 0.25rem;">Total Payments</label>
                                                     <asp:TextBox ID="txtTotalPaymentsDisplay" runat="server" ReadOnly="true" Text="0"
                                                         style="font-size: 1.35rem; font-weight: 700; color: #1A1A2E; background: transparent; border: none; padding: 0; width: 100%; outline: none;" />
                                                 </div>
                                            </div>
                                        </div>
                                    </ContentTemplate>
                                </asp:UpdatePanel>

                                <!-- Receipt Entry Modal -->
                                <div id="receiptModal" class="modal" style="display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); backdrop-filter: blur(4px);">
                                    <div class="modal-content" style="background-color: #ffffff; margin: 5% auto; padding: 2rem; border-radius: 1rem; width: 90%; max-width: 500px; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25); position: relative;">
                                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 1px solid #F7F3EE;">
                                            <h3 style="font-size: 1.25rem; font-weight: 700; color: #1A1A2E; margin: 0;">Add Receipt Details</h3>
                                            <span style="font-size: 1.5rem; color: #7a7a7a; cursor: pointer; font-weight: 400;" onclick="closeReceiptModal()">&times;</span>
                                        </div>
                                        <asp:UpdatePanel ID="upPopup" runat="server">
                                            <contenttemplate>
                                                <div style="display: grid; gap: 1.5rem; margin-bottom: 2rem;">
                                                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                        <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Receipt No <span style="color: #ef4444;">*</span></label>
                                                        <asp:TextBox ID="txtPopupReceiptNo" runat="server" AutoPostBack="true" OnTextChanged="txtPopupReceiptNo_TextChanged"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #1A1A2E; background-color: #ffffff; border: 1px solid #e0d5c5; border-radius: 0.5rem; outline: none;" />
                                                    </div>
                                                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                        <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Receipt Date <span style="color: #ef4444;">*</span></label>
                                                        <asp:TextBox ID="txtPopupReceiptDate" runat="server" ReadOnly="true" placeholder="DD-MM-YYYY"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #7a7a7a; background-color: #F7F3EE; border: 1px solid #e0d5c5; border-radius: 0.5rem;" />
                                                    </div>
                                                    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
                                                        <label style="font-size: 0.875rem; font-weight: 600; color: #8B5E3C;">Receipt Amount <span style="color: #ef4444;">*</span></label>
                                                        <asp:TextBox ID="txtPopupReceiptAmount" runat="server" TextMode="Number" ReadOnly="true"
                                                            style="width: 100%; padding: 0.625rem 0.875rem; font-size: 0.95rem; color: #7a7a7a; background-color: #F7F3EE; border: 1px solid #e0d5c5; border-radius: 0.5rem;" />
                                                    </div>
                                                </div>
                                                <div style="display: flex; justify-content: flex-end; gap: 1rem; padding-top: 1.5rem; border-top: 1px solid #F7F3EE;">
                                                    <button type="button" onclick="closeReceiptModal()"
                                                        style="padding: 0.625rem 1.25rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #ffffff; color: #8B5E3C; border: 1px solid #e0d5c5; transition: all 0.2s;">
                                                        Cancel</button>
                                                    <asp:Button ID="btnSavePopupReceipt" runat="server" Text="Save Receipt" OnClick="btnSavePopupReceipt_Click"
                                                        style="padding: 0.625rem 1.25rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #C9A84C; color: #ffffff; border: 1px solid #C9A84C; box-shadow: 0 4px 6px -1px rgba(201, 168, 76, 0.2); transition: all 0.2s;" />
                                                </div>
                                            </contenttemplate>
                                        </asp:UpdatePanel>
                                    </div>
                                </div>

                                <div style="margin-bottom: 2rem; overflow-x: auto;">
                                    <asp:UpdatePanel ID="upPayment" runat="server" UpdateMode="Conditional">
                                        <contenttemplate>
                                            <h4 style="font-size: 1rem; font-weight: 700; color: #1e293b; margin-bottom: 1.25rem;">Allocated Receipts List</h4>
                                            <asp:GridView ID="gvPaymentReceipts" runat="server" AutoGenerateColumns="false" GridLines="None" ShowHeader="true" ShowHeaderWhenEmpty="true" EmptyDataText="No receipts added yet." OnRowCommand="gvAllocatedReceipts_RowCommand" OnRowDataBound="gvPaymentReceipts_RowDataBound"
                                                CssClass="table"
                                                style="width: 100%; border-collapse: collapse; background: #ffffff; border-radius: 0.5rem; overflow: hidden; border: 1px solid #e0d5c5;">
                                                <Columns>
                                                    <asp:BoundField DataField="ReceiptNo" HeaderText="Receipt No" />
                                                    <asp:BoundField DataField="ReceiptDate" HeaderText="Date" DataFormatString="{0:dd-MM-yyyy}" />
                                                    <asp:BoundField DataField="Amount" HeaderText="Amount" DataFormatString="{0:N2}" />
                                                    <asp:TemplateField HeaderText="Action">
                                                        <ItemTemplate>
                                                            <div style="display: flex; gap: 0.5rem;">
                                                                <asp:Button ID="btnViewRcp" runat="server" Text="View" CommandName="ViewReceipt" CommandArgument='<%# Eval("ReceiptNo") %>' UseSubmitBehavior="false"
                                                                    style="padding: 0.375rem 0.75rem; background: #ffffff; color: #8B5E3C; border: 1px solid #e0d5c5; border-radius: 0.375rem; font-size: 0.75rem; font-weight: 600; cursor: pointer;" />
                                                                <asp:Button ID="btnDeleteRcp" runat="server" Text="Delete" CommandName="DeleteReceipt" CommandArgument='<%# Eval("ReceiptNo") %>' OnClientClick="if (!confirm('Are you sure you want to remove this receipt?')) return false;" UseSubmitBehavior="false"
                                                                    style="padding: 0.375rem 0.75rem; background: #fee2e2; color: #ef4444; border: 1px solid #fecaca; border-radius: 0.375rem; font-size: 0.75rem; font-weight: 600; cursor: pointer;" />
                                                            </div>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </contenttemplate>
                                    </asp:UpdatePanel>
                                </div>


                                <div style="display: flex; justify-content: center; gap: 1rem; margin-top: 2.5rem; padding-top: 1.5rem; border-top: 1px solid #F7F3EE;">
                                    <asp:Button ID="btnPrevPayment" runat="server" Text="Previous"
                                        OnClientClick="navigateSection('previous'); return false;"
                                        style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #ffffff; color: #8B5E3C; border: 1px solid #e0d5c5; transition: all 0.2s;" />
                                    <asp:Button ID="btnSavePaymentTab" runat="server" Text="Save Application" Visible="false"
                                        OnClick="btnSaveMembership_Click"
                                        OnClientClick="return validateRequiredFields();"
                                        style="padding: 0.625rem 1.5rem; border-radius: 0.5rem; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: #10b981; color: #ffffff; border: 1px solid #10b981; box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.2); transition: all 0.2s;" />
                                </div>

                            </div>
                        </asp:PlaceHolder>
                    </contenttemplate>
                </asp:UpdatePanel>
            </div>
        </div>
    </asp:Content>
