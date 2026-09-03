<%@ Page Language="C#" MasterPageFile="~/Complaint/Complaint.Master" AutoEventWireup="true" CodeFile="DefineFeedback.aspx.cs" Inherits="GymkhanaLibrary.Pages_DefineFeedback" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="cphHead" runat="server">
        <style>
            /* Standee layout styles (Print window only and layout wrappers) */
            .printable-card {
                background: #ffffff;
                border: 3px solid #c5a059;
                border-radius: 16px;
                padding: 22px 18px 14px 18px;
                text-align: center;
                width: 3.5in;
                height: 5.5in;
                box-sizing: border-box;
                margin: 0 auto;
                box-shadow: 0 8px 30px rgba(0, 0, 0, 0.08);
                position: relative;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: space-between;
            }

            .printable-card::before {
                content: '';
                position: absolute;
                top: 6px;
                left: 6px;
                right: 6px;
                bottom: 6px;
                border: 1.5px solid rgba(197, 160, 89, 0.35);
                border-radius: 12px;
                pointer-events: none;
            }

            .print-logo {
                display: block;
                width: 180px;
                height: auto;
                margin: 0 auto 14px auto;
            }

            .print-divider {
                width: 50px;
                height: 3px;
                background: linear-gradient(90deg, #c5a059, #dfc07a, #c5a059);
                border: none;
                margin: 8px auto 14px auto;
                border-radius: 2px;
            }

            .printable-card h3 {
                font-family: 'Playfair Display', serif;
                color: #0f1e36;
                margin: 0 0 4px 0;
                font-size: 20px;
                font-weight: 700;
                text-align: center;
                width: 100%;
            }

            .printable-card .print-subtitle {
                font-size: 12px;
                font-weight: 600;
                color: #c5a059;
                letter-spacing: 1px;
                text-transform: uppercase;
                margin: 0 0 16px 0;
                text-align: center;
                width: 100%;
            }

            .printable-card p {
                font-size: 13px;
                color: #64748b;
                margin: 0 0 16px 0;
                text-align: center;
                width: 100%;
            }

            .qr-wrapper {
                display: flex;
                justify-content: center;
                align-items: center;
                width: 100%;
                margin-bottom: 12px;
            }

            .qr-frame {
                background: #ffffff;
                border: 2px solid #e2e8f0;
                padding: 14px;
                border-radius: 10px;
                display: inline-block;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            }

            .qr-frame img {
                display: block;
                width: 220px;
                height: 220px;
            }

            .scan-me-wrapper {
                display: flex;
                justify-content: center;
                width: 100%;
                margin-bottom: 12px;
            }

            .scan-me-badge {
                display: inline-block;
                background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%);
                color: #ffffff;
                font-size: 15px;
                font-weight: 700;
                letter-spacing: 3px;
                text-transform: uppercase;
                padding: 9px 28px;
                border-radius: 30px;
                box-shadow: 0 4px 12px rgba(197, 160, 89, 0.35);
            }

            .print-footer-text {
                font-size: 11px;
                color: #94a3b8;
                line-height: 1.6;
                margin: 0;
                border-top: 1px solid #e2e8f0;
                padding-top: 12px;
                text-align: center;
                width: 100%;
            }

            /* Custom Grid Pager styling */
            .pager-style td {
                padding: 12px 4px !important;
                border-bottom: none !important;
            }

            .pager-style a,
            .pager-style span {
                display: inline-block !important;
                padding: 6px 12px !important;
                border-radius: 6px !important;
                text-decoration: none !important;
                font-weight: 600 !important;
                font-size: 13px !important;
                margin-left: 4px !important;
            }

            .pager-style a {
                background-color: #f1f5f9 !important;
                color: #475569 !important;
                border: 1px solid #e2e8f0 !important;
            }

            .pager-style a:hover {
                background-color: #e2e8f0 !important;
            }

            .pager-style span {
                background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%) !important;
                color: #ffffff !important;
                border: 1px solid #aa8441 !important;
                box-shadow: 0 2px 5px rgba(197, 160, 89, 0.2) !important;
            }

            /* Location Modal styles */
            .modal-overlay {
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background-color: rgba(15, 30, 54, 0.4);
                backdrop-filter: blur(4px);
                display: flex;
                justify-content: center;
                align-items: center;
                z-index: 10000;
            }
            .modal-content {
                background: #ffffff;
                border-radius: 16px;
                padding: 32px;
                width: 100%;
                max-width: 450px;
                box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
                box-sizing: border-box;
                border: 1px solid #e2e8f0;
            }
            
            /* Grid scroll container and sticky header styles */
            .grid-scroll-container {
                width: 100%;
                max-height: 280px;
                overflow-y: auto;
                overflow-x: auto;
                -webkit-overflow-scrolling: touch;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                position: relative;
            }
            .grid-scroll-container .gv-header, 
            .grid-scroll-container .gv-header-left {
                position: sticky !important;
                top: 0 !important;
                z-index: 10 !important;
                box-shadow: 0 2px 2px -1px rgba(0,0,0,0.1) !important;
            }

            /* Lock page scrolling and constrain main viewport content */
            html, body {
                height: 100vh !important;
                overflow: hidden !important;
            }
            #mainContent {
                height: 100vh !important;
                overflow: hidden !important;
            }
            #mainContent > div[style*="padding: 32px"] {
                flex: 1 !important;
                height: 0 !important;
                min-height: 0 !important;
                display: flex !important;
                flex-direction: column !important;
                overflow: hidden !important;
            }
        </style>
        <script>
            function toggleSelectAllQrs(masterChk) {
                var chks = document.querySelectorAll('.chk-qr-select');
                for (var i = 0; i < chks.length; i++) {
                    chks[i].checked = masterChk.checked;
                }
            }

            function printQrCard(title, subDeptLoc, qrUrl) {
                printMultipleQrCards([{ title: title, subDeptLoc: subDeptLoc, qrUrl: qrUrl }]);
            }

            function printSelectedQrCards() {
                var selectedChks = document.querySelectorAll('.chk-qr-select:checked');
                if (selectedChks.length === 0) {
                    alert('Please select at least one location or subdepartment using the checkboxes.');
                    return;
                }

                var items = [];
                for (var i = 0; i < selectedChks.length; i++) {
                    var chk = selectedChks[i];
                    items.push({
                        title: chk.getAttribute('data-title'),
                        subDeptLoc: chk.getAttribute('data-subdeptloc'),
                        qrUrl: chk.getAttribute('data-qrurl')
                    });
                }

                printMultipleQrCards(items);
            }

            function printMultipleQrCards(itemsList) {
                if (!itemsList || itemsList.length === 0) return;

                var logoUrl = window.location.href.substring(0, window.location.href.lastIndexOf('/') + 1) + 'Images/logo_new.png';

                function buildCardHtml(title, subDeptLoc, qrUrl) {
                    var standeeQrUrl = qrUrl.replace('size=400x400', 'size=600x600');
                    return '<div class="printable-card">' +
                        '<div class="card-header-block">' +
                        '<img src="' + logoUrl + '" alt="Lahore Gymkhana" class="print-logo" />' +
                        '<hr class="print-divider" />' +
                        '<h3><span class="print-for-tag">FOR</span>' + title + '</h3>' +
                        '</div>' +
                        '<div class="card-qr-block">' +
                        '<div class="qr-wrapper">' +
                        '<div class="qr-frame">' +
                        '<img src="' + standeeQrUrl + '" alt="Scan QR Code" />' +
                        '</div>' +
                        '</div>' +
                        '<div class="scan-me-wrapper">' +
                        '<div class="scan-me-badge">SCAN ME</div>' +
                        '</div>' +
                        '</div>' +
                        '<div class="print-footer-box">' +
                        '<p class="print-footer-headline">We Appreciate your feedback.</p>' +
                        '<div class="print-footer-bottom-flex">' +
                        '<span class="print-footer-powered">Powered by Megaplus Technologies</span>' +
                        (subDeptLoc ? '<span class="print-subdept-identity">' + subDeptLoc + '</span>' : '') +
                        '</div>' +
                        '</div>' +
                        '</div>';
                }

                // Render up to 4 cards per printable sheet in a 2x2 grid layout (preserving exact 3.5in x 5.5in dimensions)
                var pagesHtml = '';
                for (var k = 0; k < itemsList.length; k += 4) {
                    var cardsInPage = '';
                    for (var j = k; j < k + 4 && j < itemsList.length; j++) {
                        cardsInPage += buildCardHtml(itemsList[j].title, itemsList[j].subDeptLoc, itemsList[j].qrUrl);
                    }
                    
                    pagesHtml += '<div class="page-wrapper">' +
                        '<div class="print-container">' +
                        cardsInPage +
                        '</div>' +
                        '</div>';
                }

                var w = window.open('', 'PrintQR', 'width=1000,height=900,scrollbars=yes');
                w.document.write('<!DOCTYPE html>' +
                    '<html><head><meta charset="utf-8" />' +
                    '<title>Print QR Codes (' + itemsList.length + ' Location' + (itemsList.length > 1 ? 's' : '') + ')</title>' +
                    '<link rel="preconnect" href="https://fonts.googleapis.com">' +
                    '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>' +
                    '<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&family=Playfair+Display:wght@500;600;700&display=swap" rel="stylesheet">' +
                    '<style>' +
                    '@page { size: portrait; margin: 0.1in; }' +
                    'html, body { font-family: "Outfit", sans-serif; margin: 0; padding: 0; background: #ffffff; -webkit-font-smoothing: antialiased; -webkit-print-color-adjust: exact; print-color-adjust: exact; }' +
                    '.page-wrapper { display: flex; justify-content: center; align-items: center; width: 100%; min-height: 100vh; box-sizing: border-box; page-break-after: always; padding: 0; margin: 0; }' +
                    '.page-wrapper:last-child { page-break-after: auto; }' +
                    '.print-container { display: grid; grid-template-columns: repeat(2, 3.5in); grid-template-rows: repeat(2, 5.5in); gap: 0.2in 0.25in; justify-content: center; align-items: center; box-sizing: border-box; margin: 0 auto; page-break-inside: avoid; }' +
                    '.printable-card { background: #ffffff; border: 3px solid #c5a059; border-radius: 16px; padding: 18px 14px 12px 14px; text-align: center; width: 3.5in; height: 5.5in; max-width: 3.5in; max-height: 5.5in; min-width: 3.5in; min-height: 5.5in; box-sizing: border-box; position: relative; display: flex; flex-direction: column; align-items: center; justify-content: space-between; box-shadow: none; overflow: hidden; page-break-inside: avoid; }' +
                    '.printable-card::before { content: ""; position: absolute; top: 5px; left: 5px; right: 5px; bottom: 5px; border: 1.5px solid rgba(197,160,89,0.35); border-radius: 12px; pointer-events: none; }' +
                    '.card-header-block { width: 100%; display: flex; flex-direction: column; align-items: center; margin-bottom: 2px; }' +
                    '.card-qr-block { width: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; flex: 1; margin: 4px 0; }' +
                    '.print-logo { display: block; width: 2.1in; max-width: 85%; height: auto; margin: 0 auto 4px auto; }' +
                    '.print-divider { width: 45px; height: 2.5px; background: linear-gradient(90deg, #c5a059, #dfc07a, #c5a059); border: none; margin: 2px auto 6px auto; border-radius: 2px; }' +
                    'h3 { font-family: "Outfit", sans-serif; color: #0f1e36; margin: 0; font-size: 12.5px; font-weight: 700; text-align: center; width: 100%; letter-spacing: 0.5px; text-transform: uppercase; line-height: 1.3; }' +
                    '.print-for-tag { display: block; font-size: 9.5px; font-weight: 700; color: #0f1e36; letter-spacing: 2px; margin-bottom: 2px; }' +
                    '.qr-wrapper { display: flex; justify-content: center; align-items: center; width: 100%; margin-top: 4px; margin-bottom: 6px; }' +
                    '.qr-frame { background: #ffffff; border: 2px solid #e2e8f0; padding: 6px; border-radius: 12px; display: inline-block; box-shadow: 0 2px 6px rgba(0,0,0,0.03); }' +
                    '.qr-frame img { display: block; width: 1.85in; height: 1.85in; }' +
                    '.scan-me-wrapper { display: flex; justify-content: center; width: 100%; margin-top: 4px; margin-bottom: 0; }' +
                    '.scan-me-badge { display: inline-block; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; font-size: 11px; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; padding: 5px 20px; border-radius: 20px; box-shadow: 0 3px 8px rgba(197,160,89,0.3); }' +
                    '.print-footer-box { width: 100%; border-top: 1px solid #e2e8f0; padding-top: 6px; text-align: center; margin-top: 0; display: flex; flex-direction: column; justify-content: space-between; }' +
                    '.print-footer-headline { font-family: "Outfit", sans-serif; font-size: 11px; font-weight: 700; color: #0f1e36; letter-spacing: 0.5px; text-transform: uppercase; line-height: 1.3; margin: 0 0 4px 0; text-align: center; }' +
                    '.print-footer-bottom-flex { display: flex; justify-content: space-between; align-items: flex-end; width: 100%; margin-top: auto; }' +
                    '.print-footer-powered { font-size: 8px; color: #94a3b8; margin: 0; letter-spacing: 0.3px; text-align: left; }' +
                    '.print-subdept-identity { font-size: 8px; font-weight: 700; color: #475569; letter-spacing: 0.3px; text-transform: uppercase; text-align: right; max-width: 130px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }' +
                    '@media print {' +
                    'html, body { background: #ffffff; margin: 0; padding: 0; -webkit-print-color-adjust: exact; print-color-adjust: exact; }' +
                    '.page-wrapper { padding: 0; margin: 0; height: 100vh; min-height: 100vh; display: flex !important; justify-content: center !important; align-items: center !important; page-break-after: always !important; page-break-inside: avoid !important; }' +
                    '.page-wrapper:last-child { page-break-after: auto !important; }' +
                    '.print-container { display: grid !important; grid-template-columns: repeat(2, 3.5in) !important; grid-template-rows: repeat(2, 5.5in) !important; gap: 0.2in 0.25in !important; justify-content: center !important; align-items: center !important; margin: 0 auto !important; page-break-inside: avoid !important; }' +
                    '.printable-card { box-shadow: none !important; border-color: #c5a059 !important; width: 3.5in !important; height: 5.5in !important; max-width: 3.5in !important; max-height: 5.5in !important; min-width: 3.5in !important; min-height: 5.5in !important; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; page-break-inside: avoid !important; }' +
                    '.printable-card::before { border-color: rgba(197,160,89,0.35) !important; }' +
                    '.scan-me-badge { background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%) !important; color: #ffffff !important; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }' +
                    '.print-divider { background: linear-gradient(90deg, #c5a059, #dfc07a, #c5a059) !important; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }' +
                    '}' +
                    '</style>' +
                    '</head><body>' +
                    pagesHtml +
                    '</body></html>');
                w.document.close();

                var imgs = w.document.querySelectorAll('img');
                var loaded = 0;
                var total = imgs.length;
                if (total === 0) {
                    setTimeout(function () { w.print(); }, 200);
                } else {
                    for (var i = 0; i < total; i++) {
                        imgs[i].onload = imgs[i].onerror = function () {
                            loaded++;
                            if (loaded >= total) {
                                setTimeout(function () { w.print(); }, 300);
                            }
                        };
                        if (imgs[i].complete) {
                            loaded++;
                            if (loaded >= total) {
                                setTimeout(function () { w.print(); }, 300);
                            }
                        }
                    }
                }
            }
        </script>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="cphBody" runat="server">


        <div
            style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; width: 100%;">
            <div>
                <h2
                    style="font-family: 'Playfair Display', serif; font-size: 28px; font-weight: 700; color: #0f1e36; margin: 0;">
                    Feedback Setup & QRCodes</h2>
                <p style="color: #64748b; font-size: 14px; margin-top: 6px; margin-bottom: 0;">Define dynamic feedback
                    questions for departments & subdepartments and generate scan codes.</p>
            </div>
        </div>

        <!-- Alert Message Panel -->
        <asp:Panel ID="pnlAlert" runat="server" Visible="false" style="width: 100%; margin-bottom: 20px;">
            <div
                style='padding: 16px 24px; border-radius: 8px; font-size: 14px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; border-left: 4px solid; width: 100%; box-sizing: border-box; <%= AlertCssClass == "alert-success" ? "background-color: #d1fae5; color: #065f46; border-left-color: #10b981;" : "background-color: #fee2e2; color: #991b1b; border-left-color: #ef4444;" %>'>
                <span>
                    <%= AlertMessage %>
                </span>
            </div>
        </asp:Panel>

        <div style="flex: 1; height: 0; min-height: 0; display: grid; grid-template-columns: 350px 1fr; gap: 24px; width: 100%; margin-bottom: 10px;">

            <!-- Left Column: Add/Edit Form -->
            <div
                style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); width: 100%; box-sizing: border-box; height: 100%; overflow-y: auto;">
                <h3
                    style="font-family: 'Playfair Display', serif; font-size: 18px; color: #0f1e36; margin-top: 0; margin-bottom: 20px; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px;">
                    <asp:Literal ID="litFormTitle" runat="server" Text="Define Feedback Question" />
                </h3>

                <asp:HiddenField ID="hfQuestionID" runat="server" />

                <div style="margin-bottom: 16px; width: 100%;">
                    <label
                        style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Select
                        Department *</label>
                    <asp:DropDownList ID="ddlDepartment" runat="server"
                        style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;"
                        onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlDepartment_SelectedIndexChanged" />
                </div>

                <div style="margin-bottom: 16px; width: 100%;">
                    <label
                        style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Select
                        Subdepartment</label>
                    <asp:DropDownList ID="ddlSubDepartment" runat="server"
                        style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;"
                        onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';"
                        Enabled="false" AutoPostBack="true" OnSelectedIndexChanged="ddlSubDepartment_SelectedIndexChanged" />
                </div>

                <div style="margin-bottom: 16px; width: 100%;">
                    <label
                        style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Select
                        Location</label>
                    <div style="display: flex; gap: 8px; align-items: center; width: 100%;">
                        <asp:DropDownList ID="ddlLocation" runat="server"
                            style="flex: 1; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;"
                            onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';"
                            Enabled="false" />
                        <asp:LinkButton ID="btnAddLocation" runat="server" OnClick="btnAddLocation_Click"
                            style="display: flex; align-items: center; justify-content: center; width: 42px; height: 42px; border-radius: 8px; border: 1px solid #cbd5e1; background-color: #ffffff; color: #c5a059; font-size: 20px; font-weight: bold; text-decoration: none; transition: all 0.2s ease;"
                            onmouseover="this.style.backgroundColor='#f1f5f9'; this.style.borderColor='#c5a059';"
                            onmouseout="this.style.backgroundColor='#ffffff'; this.style.borderColor='#cbd5e1';">
                            +
                        </asp:LinkButton>
                    </div>
                </div>

                <div style="margin-bottom: 20px; width: 100%;">
                    <label
                        style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Feedback
                        Question Text *</label>
                    <asp:TextBox ID="txtQuestionText" runat="server"
                        style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;"
                        onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';"
                        placeholder="e.g. How was the food quality?" />
                </div>

                <div style="margin-bottom: 16px; width: 100%;">
                    <label
                        style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Question
                        Type *</label>
                    <asp:DropDownList ID="ddlQuestionType" runat="server"
                        style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;"
                        onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlQuestionType_SelectedIndexChanged">
                        <asp:ListItem Text="Rating (1 to 5 Stars)" Value="Rating" Selected="True" />
                        <asp:ListItem Text="Multiple Choice (MCQ)" Value="Multiple Choice" />
                        <asp:ListItem Text="True / False" Value="True / False" />
                        <asp:ListItem Text="Yes / No" Value="Yes / No" />
                    </asp:DropDownList>
                </div>

                <asp:Panel ID="pnlOptions" runat="server" Visible="false" style="margin-bottom: 20px; width: 100%;">
                    <label
                        style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Options
                        (Comma Separated - At least 2 required) *</label>
                    <asp:TextBox ID="txtOptions" runat="server"
                        style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px; transition: border-color 0.2s ease;"
                        onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';"
                        placeholder="e.g. Excellent, Good, Average, Poor" />
                    <span style="font-size: 11px; color: #94a3b8; margin-top: 4px; display: block;">Enter multiple
                        options separated by commas before saving.</span>
                </asp:Panel>

                <div style="margin-bottom: 20px; display: flex; align-items: center; gap: 8px; width: 100%;">
                    <asp:CheckBox ID="chkActive" runat="server" Checked="true" />
                    <label for="<%= chkActive.ClientID %>"
                        style="font-size: 13px; font-weight: 600; color: #475569; cursor: pointer; user-select: none;">Is
                        Active</label>
                </div>

                <div style="display: flex; gap: 12px; width: 100%;">
                    <asp:Button ID="btnSave" runat="server" Text="Save Question"
                        style="padding: 10px 20px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(197, 160, 89, 0.2); display: inline-block; height: 42px;"
                        onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(197, 160, 89, 0.3)';"
                        onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(197, 160, 89, 0.2)';"
                        OnClick="btnSave_Click" />
                    <asp:Button ID="btnClear" runat="server" Text="Clear"
                        style="padding: 10px 20px; border-radius: 8px; border: 1px solid #cbd5e1; cursor: pointer; font-size: 13px; font-weight: 600; background-color: #ffffff; color: #64748b; transition: all 0.2s ease; display: inline-block; height: 42px;"
                        onmouseover="this.style.backgroundColor='#f1f5f9'; this.style.color='#1e293b';"
                        onmouseout="this.style.backgroundColor='#ffffff'; this.style.color='#64748b';"
                        OnClick="btnClear_Click" Visible="false" />
                </div>
            </div>

            <!-- Right Column: List Grid Grouped by Subdepartment -->
            <div
                style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); width: 100%; box-sizing: border-box; height: 100%; display: flex; flex-direction: column; overflow: hidden;">
                <div
                    style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; gap: 16px; flex-wrap: wrap; width: 100%;">
                    <h3 style="font-family: 'Playfair Display', serif; font-size: 18px; color: #0f1e36; margin: 0;">
                        Defined Questions & QRCodes</h3>
                    <div style="display: flex; gap: 8px; align-items: center; max-width: 380px; width: 100%;">
                        <asp:TextBox ID="txtSearch" runat="server"
                            style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 36px; transition: border-color 0.2s ease;"
                            onfocus="this.style.borderColor='#c5a059';" onblur="this.style.borderColor='#cbd5e1';"
                            placeholder="Search questions or departments..." />
                        <asp:Button ID="btnSearch" runat="server" Text="Search"
                            style="padding: 8px 16px; border-radius: 8px; border: none; cursor: pointer; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); color: #ffffff; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(15, 30, 54, 0.1); display: inline-block; height: 36px;"
                            onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(15, 30, 54, 0.2)';"
                            onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 4px rgba(15, 30, 54, 0.1)';"
                            OnClick="btnSearch_Click" />
                        <asp:Button ID="btnReset" runat="server" Text="Reset"
                            style="padding: 8px 16px; border-radius: 8px; border: 1px solid #cbd5e1; cursor: pointer; font-size: 12px; font-weight: 600; background-color: #ffffff; color: #64748b; transition: all 0.2s ease; display: inline-block; height: 36px;"
                            onmouseover="this.style.backgroundColor='#f1f5f9'; this.style.color='#1e293b';"
                            onmouseout="this.style.backgroundColor='#ffffff'; this.style.color='#64748b';"
                            OnClick="btnReset_Click" />
                    </div>
                </div>

                <div style="flex: 1; overflow-y: auto; padding-right: 4px; min-height: 0;">
                    <!-- Multi-select Batch Print Toolbar -->
                    <div style="background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 10px; padding: 12px 18px; margin-bottom: 18px; display: flex; justify-content: space-between; align-items: center; gap: 12px; width: 100%; box-sizing: border-box;">
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <input type="checkbox" id="chkSelectAllQrs" onchange="toggleSelectAllQrs(this)" style="width: 18px; height: 18px; cursor: pointer; accent-color: #c5a059;" />
                            <label for="chkSelectAllQrs" style="font-size: 13px; font-weight: 700; color: #0f1e36; cursor: pointer; user-select: none;">Select All Locations / Subdepartments</label>
                        </div>
                        <button type="button" onclick="printSelectedQrCards()" style="display: inline-flex; align-items: center; gap: 8px; padding: 9px 20px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; border: none; border-radius: 8px; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; cursor: pointer; box-shadow: 0 2px 5px rgba(197, 160, 89, 0.3); transition: all 0.2s ease;"
                            onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(197, 160, 89, 0.4)';"
                            onmouseout="this.style.transform='none'; this.style.boxShadow='0 2px 5px rgba(197, 160, 89, 0.3)';">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <polyline points="6 9 6 2 18 2 18 9"></polyline>
                                <path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path>
                                <rect x="6" y="14" width="12" height="8"></rect>
                            </svg>
                            Print Selected QRCodes
                        </button>
                    </div>

                    <!-- Grouped Subdepartments Repeater -->
                    <asp:Repeater ID="rptSubDeptGroups" runat="server" OnItemDataBound="rptSubDeptGroups_ItemDataBound">
                    <ItemTemplate>
                        <div
                            style="background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; margin-bottom: 24px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.04);">
                            <!-- Subdepartment Group Header -->
                            <div
                                style="background: linear-gradient(135deg, #0f1e36 0%, #1c3254 100%); padding: 16px 20px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px; color: #ffffff;">
                                <div style="display: flex; align-items: center; gap: 14px;">
                                    <input type="checkbox" class="chk-qr-select" 
                                        data-title='<%# HttpUtility.HtmlEncode(GetStandeeTitle(Eval("DepartmentName"), Eval("SubDepartmentName"), Eval("LocationName"))) %>' 
                                        data-subdeptloc='<%# HttpUtility.HtmlEncode(GetPrintSubtitle(Eval("DepartmentName"), Eval("SubDepartmentName"), Eval("LocationName"))) %>' 
                                        data-qrurl='<%# HttpUtility.HtmlEncode(GetQrCodeUrl(Eval("DeptID"), Eval("SubDeptID"), Eval("LocationID"))) %>' 
                                        style="width: 20px; height: 20px; cursor: pointer; accent-color: #c5a059; flex-shrink: 0;" />
                                    <div>
                                        <div
                                            style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #c5a059; letter-spacing: 1px;">
                                            Department: <%# Eval("DepartmentName") %>
                                        </div>
                                        <div
                                            style="font-family: 'Playfair Display', serif; font-size: 19px; font-weight: 700; color: #ffffff; margin-top: 2px;">
                                            <%# Eval("SubDepartmentName") !=DBNull.Value &&
                                                !string.IsNullOrEmpty(Convert.ToString(Eval("SubDepartmentName"))) ? "" +
                                                Eval("SubDepartmentName") : "Entire Department" %>
                                            <%# Eval("LocationName") !=DBNull.Value &&
                                                !string.IsNullOrEmpty(Convert.ToString(Eval("LocationName"))) ? " - " +
                                                Eval("LocationName") : "" %>
                                        </div>
                                    </div>
                                </div>

                                <!-- Group QRCode Action & Preview (ONLY ONE PER SUBDEPARTMENT/LOCATION) -->
                                <div
                                    style="display: flex; align-items: center; gap: 14px; background: rgba(255,255,255,0.1); padding: 8px 14px; border-radius: 8px; border: 1px solid rgba(255,255,255,0.15);">
                                    <img src='<%# GetQrCodeUrl(Eval("DeptID"), Eval("SubDeptID"), Eval("LocationID")) %>' alt="QRCode"
                                        style="width: 55px; height: 55px; border-radius: 4px; background: #ffffff; padding: 2px; box-shadow: 0 2px 4px rgba(0,0,0,0.2);" />
                                    <a href="javascript:void(0);"
                                        onclick='<%# GetPrintClickEvent(Eval("DepartmentName"), Eval("SubDepartmentName"), Eval("LocationName"), Eval("DeptID"), Eval("SubDeptID"), Eval("LocationID")) %>'
                                        style="display: inline-flex; align-items: center; gap: 6px; padding: 8px 14px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff; text-decoration: none; border-radius: 6px; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; box-shadow: 0 2px 4px rgba(0,0,0,0.2); transition: all 0.2s ease;">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                                            stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                            stroke-linejoin="round">
                                            <polyline points="6 9 6 2 18 2 18 9"></polyline>
                                            <path
                                                d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2">
                                            </path>
                                            <rect x="6" y="14" width="12" height="8"></rect>
                                        </svg>
                                        Print QRCode
                                    </a>
                                </div>
                            </div>

                            <!-- Questions Grid for this Subdepartment -->
                            <div class="grid-scroll-container">
                                <asp:GridView ID="gvSubQuestions" runat="server" AutoGenerateColumns="false"
                                    GridLines="None" OnRowCommand="gvSubQuestions_RowCommand"
                                    style="width: 100%; border-collapse: collapse; background-color: #ffffff; font-size: 13.5px; color: #1e293b; margin: 0; border: none;">
                                    <HeaderStyle CssClass="gv-header" />
                                    <RowStyle CssClass="gv-row" />
                                    <AlternatingRowStyle CssClass="gv-alt-row" />
                                    <Columns>
                                        <asp:TemplateField HeaderText="SR#">
                                            <HeaderStyle CssClass="gv-header-left" Width="60px" />
                                            <ItemStyle CssClass="gv-text-left" Width="60px" />
                                            <ItemTemplate>
                                                <%# Container.DataItemIndex + 1 %>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:BoundField DataField="QuestionText" HeaderText="Feedback Question">
                                            <HeaderStyle CssClass="gv-header-left" />
                                            <ItemStyle CssClass="gv-text-left" />
                                        </asp:BoundField>

                                        <asp:TemplateField HeaderText="Type / Options">
                                            <HeaderStyle CssClass="gv-header-left" Width="180px" />
                                            <ItemStyle CssClass="gv-text-left" Width="180px" />
                                            <ItemTemplate>
                                                <div style="font-weight: 600; color: #0f1e36;">
                                                    <%# Eval("QuestionType") !=DBNull.Value &&
                                                        !string.IsNullOrEmpty(Eval("QuestionType").ToString()) ?
                                                        Eval("QuestionType") : "Rating" %>
                                                </div>
                                                <div style="font-size: 11px; color: #64748b; margin-top: 2px;">
                                                    <%# Eval("Options") !=DBNull.Value ? Eval("Options") : "" %>
                                                </div>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Status">
                                            <HeaderStyle CssClass="gv-header-left" Width="100px" />
                                            <ItemStyle CssClass="gv-text-left" Width="100px" />
                                            <ItemTemplate>
                                                <span
                                                    style='<%# Convert.ToBoolean(Eval("IsActive")) ? "display: inline-block; padding: 4px 8px; border-radius: 12px; font-size: 11px; font-weight: 600; text-transform: uppercase; background-color: #d1fae5; color: #065f46;" : "display: inline-block; padding: 4px 8px; border-radius: 12px; font-size: 11px; font-weight: 600; text-transform: uppercase; background-color: #fee2e2; color: #991b1b;" %>'>
                                                    <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                                </span>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Actions">
                                            <HeaderStyle CssClass="gv-header-left" Width="100px" />
                                            <ItemStyle CssClass="gv-text-left" Width="100px" />
                                            <ItemTemplate>
                                                <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditQuestion"
                                                    CommandArgument='<%# Eval("QuestionID") %>'
                                                    style="text-decoration: none; font-size: 13px; font-weight: 600; color: #c5a059;">
                                                    Edit</asp:LinkButton>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlNoQuestions" runat="server" Visible="false"
                    style="padding: 40px; text-align: center; color: #64748b; background: #f8fafc; border: 1px dashed #cbd5e1; border-radius: 12px;">
                    <p style="margin: 0; font-size: 15px; font-weight: 500;">No feedback questions defined yet or no
                        match found.</p>
                </asp:Panel>
                </div>
        </div>

        <!-- Add Location Modal Popup -->
        <asp:Panel ID="pnlLocationModal" runat="server" Visible="false" CssClass="modal-overlay">
            <div class="modal-content">
                <h3 style="font-family: 'Playfair Display', serif; font-size: 18px; color: #0f1e36; margin-top: 0; margin-bottom: 20px; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px;">Add New Location</h3>
                
                <div style="margin-bottom: 16px;">
                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Department</label>
                    <asp:TextBox ID="txtModalDept" runat="server" ReadOnly="true" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; background-color: #f1f5f9; box-sizing: border-box; height: 42px;" />
                </div>
                
                <div style="margin-bottom: 16px;">
                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Subdepartment</label>
                    <asp:TextBox ID="txtModalSubDept" runat="server" ReadOnly="true" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; background-color: #f1f5f9; box-sizing: border-box; height: 42px;" />
                </div>
                
                <div style="margin-bottom: 20px;">
                    <label style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px; margin-bottom: 6px; display: block;">Location Name *</label>
                    <asp:TextBox ID="txtModalLocationName" runat="server" style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px;" placeholder="e.g. Table 1, Room 204" />
                </div>
                
                <div style="display: flex; gap: 12px; justify-content: flex-end;">
                    <asp:Button ID="btnCancelLocation" runat="server" Text="Cancel" OnClick="btnCancelLocation_Click" style="padding: 10px 20px; border-radius: 8px; border: 1px solid #cbd5e1; cursor: pointer; font-size: 13px; font-weight: 600; background-color: #ffffff; color: #64748b;" />
                    <asp:Button ID="btnSaveLocation" runat="server" Text="Save" OnClick="btnSaveLocation_Click" style="padding: 10px 20px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 700; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #ffffff;" />
                </div>
            </div>
        </asp:Panel>
    </asp:Content>
