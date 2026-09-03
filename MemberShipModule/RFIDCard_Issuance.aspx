<%@ Page Title="RFID card Issuance" Language="C#" MasterPageFile="~/MemberShipModule/Site.master"
    AutoEventWireup="true" CodeFile="RFIDCard_Issuance.aspx.cs" Inherits="Form_cell.Applicant_Form.RFID" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <style>
            body { font-family: 'Outfit', sans-serif !important; background-color: #faf7f2; }
            
            .table { width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left; }
            .table th { background: #1A1A2E; color: #C9A84C; font-weight: 700; padding: 0.75rem 1rem; border-bottom: 1px solid #e0d5c5; text-align: left; font-size: 0.875rem; }
            .table td { padding: 0.75rem 1rem; border-bottom: 1px solid #F7F3EE; color: #1A1A2E; vertical-align: middle; font-size: 0.9rem; }
            .table tr:hover { background-color: #faf7f2; }

            .status-badge { display: inline-flex; align-items: center; gap: 0.5rem; padding: 0.4rem 0.8rem; border-radius: 99px; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; }
            .status-active { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
            .status-deactive { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
            .status-blocked { background: #fef3c7; color: #92400e; border: 1px solid #fde68a; }
            .status-lost { background: #f3f4f6; color: #374151; border: 1px solid #d1d5db; }
            .status-replaced { background: #f5ecd5; color: #075985; border: 1px solid #e0d5c5; }
            
            .modal-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center; }
            .modal-content { background: white; padding: 2rem; border-radius: 12px; width: 500px; max-width: 90%; box-shadow: 0 10px 25px rgba(0,0,0,0.2); }
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="page-wrapper" style="padding: 1.5rem; width: 100%; max-width: 100%; margin: 0 auto; font-family: 'Outfit', sans-serif;">
            
            <!-- Panel: Member Search -->
            <div class="card" style="background-color: #ffffff; border-radius: 12px; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; margin-bottom: 2rem;">
                <div class="card-header" style="padding: 16px 26px; border-bottom: 1px solid #e0d5c5; background: linear-gradient(135deg, #1A1A2E, #2d2d5e); display: flex; align-items: center; justify-content: space-between;">
                    <div>
                        <h1 style="font-size: 1.35rem; font-weight: 700; color: #fff; margin: 0;">RFID Card Issuance</h1>
                        <p style="color: #E8D5A3; font-size: 0.8rem; margin: 3px 0 0 0;">Membership Module · Identification & Access Cards</p>
                    </div>
                </div>


                <div class="card-body" style="padding: 1.5rem;">
                    <!-- Member Search Filters -->
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-bottom: 1.5rem; background: #faf7f2; padding: 1rem; border-radius: 8px; border: 1px solid #e0d5c5;">
                        <div>
                            <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Member No</label>
                            <asp:TextBox ID="txtMemberNo" runat="server" placeholder="e.g. R-1234" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                        </div>
                        <div>
                            <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Full Name</label>
                            <asp:TextBox ID="txtName" runat="server" placeholder="Search by name..." style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                        </div>
                        <div>
                            <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">CNIC / NIC</label>
                            <asp:TextBox ID="txtCNIC" runat="server" placeholder="12345-6789012-3" style="padding: 0.6rem 0.8rem; border: 1px solid #e0d5c5; border-radius: 6px; width: 100%; box-sizing: border-box; outline: none;" />
                        </div>
                        <div style="display: flex; gap: 0.5rem; align-items: end;">
                            <asp:LinkButton ID="btnSearch" runat="server" OnClick="btnSearch_Click" 
                                style="display: flex; align-items: center; justify-content: center; gap: 0.5rem; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; padding: 0.6rem 1.5rem; border-radius: 6px; font-weight: 600; text-decoration: none; border: none; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2); width: 100%;">
                                <i class="fas fa-search"></i> Search
                            </asp:LinkButton>
                        </div>
                    </div>

                    <!-- Members Results Grid -->
                    <div id="searchResultsSection" runat="server" visible="false" style="border: 1px solid #e0d5c5; border-radius: 8px; overflow: hidden; width: 100%; overflow-x: auto;">
                        <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" 
                            DataKeyNames="MemberID" OnSelectedIndexChanged="GridView1_SelectedIndexChanged"
                            CssClass="table" GridLines="None" Width="100%">
                            <Columns>
                                <asp:TemplateField HeaderText="Action" ItemStyle-Width="100px">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnSelect" runat="server" CommandName="Select" 
                                            style="display: inline-block; background: #F7F3EE; color: #8B5E3C; padding: 0.4rem 0.8rem; border-radius: 0.375rem; font-size: 0.875rem; font-weight: 600; text-decoration: none; border: 1px solid #e0d5c5;">
                                            Select
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="MemberNo" HeaderText="Member No" />
                                <asp:BoundField DataField="MemberName" HeaderText="Name" />
                                <asp:BoundField DataField="NIC" HeaderText="CNIC" />
                                <asp:BoundField DataField="SpouseName" HeaderText="Spouse Name" />
                            </Columns>
                            <SelectedRowStyle BackColor="#faf7f2" Font-Bold="true" />
                        </asp:GridView>
                    </div>
                </div>
            </div>

            <!-- Detailed Card Management -->
            <asp:Panel ID="pnlMemberDetails" runat="server" Visible="false">
                
                <!-- Member Account Status Info -->
                <div id="divStatusWarning" runat="server" visible="false" style="background: #f0f9ff; border: 1px solid #e0d5c5; padding: 1rem; border-radius: 0.75rem; margin-bottom: 2rem; display: flex; align-items: center; gap: 1rem; color: #0369a1;">
                    <div style="background: #f5ecd5; padding: 0.5rem; border-radius: 50%; color: #0284c7;">
                        <i class="fas fa-info-circle"></i>
                    </div>
                    <div>
                        <h4 style="margin: 0; font-size: 1rem; font-weight: 700;">Membership Info</h4>
                        <p style="margin: 0; font-size: 0.875rem;">Current Account Status: <strong id="lblMemberStatus" runat="server">Active</strong>. (Issuance is permitted for all statuses on this page)</p>
                    </div>
                </div>

                <!-- Grid Layout -->
                <div class="card" style="background-color: #ffffff; border-radius: 12px; border: 1px solid #e0d5c5; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; margin-bottom: 2rem;">
                    <div class="card-header" style="padding: 16px 26px; border-bottom: 1px solid #e0d5c5; background: linear-gradient(135deg, #1A1A2E, #2d2d5e);">
                        <h3 style="margin: 0; font-size: 1.125rem; font-weight: 700; color: #ffffff;">Family Members & Cards</h3>
                    </div>
                    <div class="card-body" style="padding: 1.5rem;">
                        <asp:GridView ID="gvFamilyMembers" runat="server" AutoGenerateColumns="False" 
                            CssClass="table" GridLines="None" Width="100%" OnRowCommand="gvFamilyMembers_RowCommand">
                            <Columns>
                                <asp:BoundField DataField="Name" HeaderText="Name" />
                                <asp:BoundField DataField="Relationship" HeaderText="Relationship" />
                                <asp:BoundField DataField="CardNo" HeaderText="Card No" />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <span class='<%# "status-badge status-" + Eval("Status").ToString().ToLower() %>'>
                                            <%# Eval("Status") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Action">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnIssueCard" runat="server" Text="Issue Card" 
                                            CommandName="IssueCard" CommandArgument='<%# Container.DataItemIndex %>'
                                            style="display: inline-block; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; padding: 0.4rem 0.8rem; border-radius: 0.375rem; font-size: 0.875rem; font-weight: 600; text-decoration: none; border: none; box-shadow: 0 4px 6px rgba(201, 168, 76, 0.2);" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>

                <!-- Popup Modal -->
                <asp:Panel ID="pnlCardPopup" runat="server" CssClass="modal-overlay" Visible="false" style="display: flex;">
                    <div class="modal-content">
                        <h3 style="margin-top: 0; color: #1A1A2E; font-weight: 700; border-bottom: 1px solid #e0d5c5; padding-bottom: 0.75rem;">Issue RFID Access Card</h3>
                        
                        <div style="display: grid; gap: 1rem;">
                            <div>
                                <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Member No</label>
                                <asp:Label ID="lblPopupMemberNo" runat="server" style="display: block; padding: 0.5rem; background: #faf7f2; border-radius: 4px;" />
                            </div>
                            <div>
                                <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Membership No</label>
                                <asp:Label ID="lblPopupMembershipNo" runat="server" style="display: block; padding: 0.5rem; background: #faf7f2; border-radius: 4px;" />
                            </div>
                            <div>
                                <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Name</label>
                                <asp:Label ID="lblPopupPersonName" runat="server" style="display: block; padding: 0.5rem; background: #faf7f2; border-radius: 4px;" />
                            </div>
                            <div>
                                <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Card No (RFID Tag)</label>
                                <asp:TextBox ID="txtPopupRFID" runat="server" onkeydown="if(event.keyCode==13) { event.preventDefault(); event.stopPropagation(); event.stopImmediatePropagation(); return false; }" oninput="this.value = this.value.replace(/[^a-zA-Z0-9]/g, '');" style="width: 100%; padding: 0.6rem; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box;" />
                            </div>
                            <div>
                                <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Issue Date</label>
                                <asp:TextBox ID="txtPopupIssueDate" runat="server" TextMode="Date" style="width: 100%; padding: 0.6rem; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box;" />
                            </div>
                            <div>
                                <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Expiry Date</label>
                                <asp:TextBox ID="txtPopupExpiryDate" runat="server" TextMode="Date" style="width: 100%; padding: 0.6rem; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box;" />
                            </div>
                            <div>
                                <label style="font-size: 0.8rem; font-weight: 700; color: #8B5E3C;">Status</label>
                                <asp:DropDownList ID="ddlPopupStatus" runat="server" style="width: 100%; padding: 0.6rem; border: 1px solid #e0d5c5; border-radius: 6px; box-sizing: border-box; background: white;">
                                    <asp:ListItem Text="Active" Value="Active" />
                                </asp:DropDownList>
                            </div>
                        </div>
                        
                        <div style="display: flex; gap: 1rem; justify-content: flex-end; margin-top: 1.5rem;">
                            <asp:Button ID="btnClosePopup" runat="server" Text="Cancel" OnClick="btnClosePopup_Click" style="padding: 0.6rem 1.2rem; background: #F7F3EE; color: #8B5E3C; border: 1px solid #e0d5c5; border-radius: 6px; font-weight: 600; cursor: pointer;" />
                            <asp:Button ID="btnPrintPopup" runat="server" Text="Print" OnClick="btnPrintPopup_Click" OnClientClick="return validateRFID();" style="padding: 0.6rem 1.2rem; background: white; color: #7a7a7a; border: 1px solid #e0d5c5; border-radius: 6px; font-weight: 600; cursor: pointer;" />
                            <asp:Button ID="btnSavePopup" runat="server" Text="Save" OnClick="btnSavePopup_Click" OnClientClick="return validateRFID();" style="padding: 0.6rem 1.2rem; background: linear-gradient(135deg, #C9A84C, #8B5E3C); color: white; border: none; border-radius: 6px; font-weight: 600; cursor: pointer;" />
                        </div>
                    </div>
                </asp:Panel>

                <!-- Footer Actions -->
                <div style="display: flex; justify-content: flex-end; gap: 1rem; padding-top: 1.5rem; border-top: 1px solid #e0d5c5;">
                    <asp:Button ID="btnCompleteIssuance" runat="server" Text="Finish & Close Member" OnClick="btnCompleteIssuance_Click" 
                        style="padding: 0.75rem 2rem; border-radius: 6px; font-weight: 600; font-size: 0.95rem; cursor: pointer; background: linear-gradient(135deg, #1A1A2E, #2d2d5e); color: white; border: none; box-shadow: 0 4px 6px rgba(26,26,46,0.2);" />
                </div>

            </asp:Panel>
        </div>

        <!-- Hidden Printable Structure -->
        <div id="printableCard" style="display: none;">
            <div class="card-side card-front">
                <img id="imgFrontBg" class="bg-img" src="" alt="Front" />
                <div class="content">
                    <div class="f-name-container">
                        <span class="f-label">Member Name</span>
                        <div id="txtFrontName" class="f-name"></div>
                    </div>
                    <img id="imgFrontPhoto" class="f-photo" src="" alt="Photo" />
                    <div id="txtFrontMemberNo" class="f-memberno"></div>
                    <div id="txtFrontValidUpto" class="f-validupto"></div>
                </div>
            </div>
            <div class="card-side card-back">
                <img id="imgBackBg" class="bg-img" src="" alt="Back" />
                <div class="content">
                    <div id="txtBackMemberNo" class="b-line b-no"></div>
                    <div id="txtBackTitle" class="b-line b-title"></div>
                    <div id="txtBackIssueDate" class="b-line b-date"></div>
                </div>
            </div>
        </div>

        <script type="text/javascript">
            function focusRFIDInput() {
                var rfidInput = document.getElementById('<%= txtPopupRFID.ClientID %>');
                if (rfidInput) rfidInput.focus();
            }

            function validateRFID() {
                var rfidInput = document.getElementById('<%= txtPopupRFID.ClientID %>');
                if (rfidInput) {
                    var val = rfidInput.value;
                    if (/[^a-zA-Z0-9]/.test(val)) {
                        alert('Only alphanumeric characters are allowed in the RFID Tag.');
                        rfidInput.focus();
                        return false;
                    }
                }
                return true;
            }

            function printCard(memberType, name, memberNo, photoSrc) {
                var bgFront = '<%= ResolveUrl("~/MemberShipModule/Images/CardLayouts/card_front_blank.png") %>';
                var bgBack = '<%= ResolveUrl("~/MemberShipModule/Images/CardLayouts/card_back_blank.png") %>';
                
                var today = new Date();
                var validThru = new Date();
                validThru.setFullYear(today.getFullYear() + 5);

                var dateOptions = { day: '2-digit', month: '2-digit', year: 'numeric' };
                var issueDateStr = today.toLocaleDateString('en-GB', dateOptions);
                var validThruStr = validThru.toLocaleDateString('en-GB', dateOptions);

                document.getElementById('imgFrontBg').src = bgFront;
                document.getElementById('imgFrontPhoto').src = photoSrc || "";
                document.getElementById('txtFrontName').innerText = name || "";
                document.getElementById('txtFrontMemberNo').innerText = memberNo || "";
                document.getElementById('txtFrontValidUpto').innerText = "Valid thru " + validThruStr;

                document.getElementById('imgBackBg').src = bgBack;
                document.getElementById('txtBackMemberNo').innerText = "M/Ship No.: " + memberNo;
                document.getElementById('txtBackTitle').innerText = "M/Ship Title: " + name;
                document.getElementById('txtBackIssueDate').innerText = "Issued on " + issueDateStr;

                window.print();
            }
        </script>

        <style>
            @media print {
                body * { visibility: hidden; }
                #printableCard, #printableCard * { visibility: visible; }
                #printableCard { display: block; position: absolute; left: 0; top: 0; width: 85.6mm; }
                .card-side { position: relative; width: 85.6mm; height: 53.98mm; overflow: hidden; page-break-after: always; -webkit-print-color-adjust: exact; }
                .bg-img { width: 100%; height: 100%; position: absolute; top: 0; left: 0; z-index: 1; }
                .content { position: relative; z-index: 2; width: 100%; height: 100%; font-family: 'Arial', sans-serif; color: #003366; }
                .f-name-container { position: absolute; top: 15mm; left: 5mm; }
                .f-label { font-size: 7pt; color: #666; }
                .f-name { font-size: 11pt; font-weight: bold; text-transform: uppercase; }
                .f-photo { position: absolute; top: 25mm; left: 5mm; width: 22mm; height: 27mm; object-fit: cover; border: 1px solid #ccc; }
                .f-memberno { position: absolute; bottom: 3mm; right: 3mm; font-size: 18pt; font-weight: bold; color: white; background: #1e40af; padding: 2px 10px; border-radius: 4px; }
                .f-validupto { position: absolute; bottom: 4mm; left: 35mm; font-size: 8pt; color: #444; }
                .card-back .content { padding-top: 20mm; padding-left: 5mm; }
                .b-line { font-size: 9pt; font-weight: bold; margin-bottom: 2px; }
            }
        </style>
    </asp:Content>
