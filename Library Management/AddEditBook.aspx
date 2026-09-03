<%@ page language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" autoeventwireup="true"
    enableeventvalidation="false" CodeFile="AddEditBook.aspx.cs" Inherits="Pages_Books_AddEditBook"
    title="Catalogue - Lahore Gymkhana Library" %>

    <asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
    </asp:Content>

    <asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">

        <style>
            body,
            form,
            html,
            #form1,
            .main-body {
                background-color: #f9f9f7 !important;
            }

            .autocomplete-suggestions div {
                padding: 8px 12px;
                font-size: 13.5px;
                color: #1e293b;
                cursor: pointer;
                transition: background-color 0.15s ease, color 0.15s ease;
                font-family: 'Outfit', sans-serif;
            }

            .autocomplete-suggestions div:hover {
                background-color: #f1f5f9;
                color: #0f1e36;
            }

            .autocomplete-suggestions div:active {
                background-color: #e2e8f0;
            }

            .form-grid-container {
                display: flex;
                gap: 24px;
                width: 100%;
                box-sizing: border-box;
            }

            .form-left-panel {
                flex: 1;
                background: #ffffff;
                border: 1px solid #dde3ea;
                border-radius: 8px;
                padding: 24px;
                box-sizing: border-box;
            }

            .form-right-panel {
                width: 140px;
                display: flex;
                flex-direction: column;
                gap: 10px;
                box-sizing: border-box;
                position: sticky;
                top: 80px;
                align-self: flex-start;
            }

            .form-row {
                display: flex;
                gap: 16px;
                margin-bottom: 12px;
                align-items: flex-end;
            }

            .form-group {
                display: flex;
                flex-direction: column;
                gap: 4px;
                box-sizing: border-box;
            }

            .form-group label {
                font-size: 12px;
                font-weight: 600;
                color: #475569;
                text-transform: uppercase;
                letter-spacing: .4px;
            }

            .form-control-input {
                padding: 8px 11px;
                border: 1px solid #c8d0da;
                border-radius: 6px;
                font-size: 14px;
                background-color: white;
                outline: none;
                box-sizing: border-box;
                transition: border-color 0.2s;
                height: 38px;
            }

            .form-control-input:focus {
                border-color: #0f1e36;
            }

            .v-btn {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 8px;
                width: 100%;
                height: 40px;
                border-radius: 6px;
                font-weight: 600;
                font-size: 13.5px;
                cursor: pointer;
                border: 1px solid #c8d0da;
                background-color: #ffffff;
                color: #0f1e36;
                transition: all 0.2s ease;
                box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
                text-decoration: none;
            }

            .v-btn:hover {
                background-color: #f8fafc;
                border-color: #94a3b8;
            }

            .v-btn-primary {
                background-color: #0f1e36;
                color: #ffffff;
                border: none;
            }

            .v-btn-primary:hover {
                background-color: #1e293b;
            }

            .v-btn-danger {
                background-color: #ef4444;
                color: #ffffff;
                border: none;
            }

            .v-btn-danger:hover {
                background-color: #dc2626;
            }
        </style>

        <asp:UpdatePanel ID="upAddEditBook" runat="server" UpdateMode="Conditional">
            <Triggers>
                <asp:PostBackTrigger ControlID="btnUploadCover" />
            </Triggers>
            <ContentTemplate>

                <div
                    style="background: linear-gradient(135deg, #0f1e36, #1c3254); color: #ffffff; padding: 20px 28px; border-radius: 8px; margin-bottom: 24px; border-bottom: 3px solid #c5a059; width: 100%; box-sizing: border-box;">
                    <h2 style="margin: 0; font-size: 22px; font-weight: 600;">
                        <asp:Literal ID="litPageTitle" runat="server" Text="Catalogue Creation Menu" />
                    </h2>
                    <p style="margin: 4px 0 0; opacity: .8; font-size: 13px;">Lahore Gymkhana Club Library - Book
                        Catalogue Management</p>
                </div>

                <!-- Alert panel -->
                <asp:Panel ID="pnlAlert" runat="server" Visible="false" style="width: 100%;">
                    <div id="divAlert" runat="server"
                        style="padding: 12px 20px; border-radius: 8px; font-size: 14px; margin-bottom: 20px; width: 100%; box-sizing: border-box;">
                    </div>
                </asp:Panel>

                <asp:HiddenField ID="hfBookID" runat="server" Value="0" />
                <asp:HiddenField ID="hfCoverPath" runat="server" />
                <asp:HiddenField ID="hfThumbPath" runat="server" />
                <asp:HiddenField ID="hfSelectedSlot" runat="server" />
                <asp:HiddenField ID="hfSelectedRack" runat="server" />

                <div class="form-grid-container" style="display: flex; gap: 24px; width: 100%; box-sizing: border-box;">
                    <!-- Left panel with all fields -->
                    <div class="form-left-panel"
                        style="flex: 1; background: #ffffff; border: 1px solid #dde3ea; border-radius: 8px; padding: 24px; box-sizing: border-box;">

                        <!-- Row 1: Book No, Acq No, Condition -->
                        <div class="form-row"
                            style="display: flex; gap: 16px; margin-bottom: 12px; align-items: flex-end;">
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 200px;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Book
                                    No</label>
                                <asp:TextBox ID="txtBookNo" runat="server" CssClass="form-control-input"
                                    style="width: 100%; background-color: #f1f5f9; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    ReadOnly="true" />
                            </div>
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 200px;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Acq
                                    No</label>
                                <asp:TextBox ID="txtAcqNo" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    onfocus="this.style.borderColor='#0f1e36';"
                                    onblur="this.style.borderColor='#c8d0da';" placeholder="Acquisition Number" />
                            </div>
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 200px; position: relative;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Condition</label>
                                <asp:DropDownList ID="ddlCopyCondition" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 0 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; height: 38px;">
                                    <asp:ListItem Value="">-- Select Condition --</asp:ListItem>
                                    <asp:ListItem Value="New">New</asp:ListItem>
                                    <asp:ListItem Value="Old">Old</asp:ListItem>
                                    <asp:ListItem Value="SH">SH</asp:ListItem>
                                </asp:DropDownList>
                                <div style="display:none;">
                                    <asp:TextBox ID="txtCopyCondition" runat="server" />
                                </div>
                            </div>
                        </div>

                        <!-- Row 2: DDC No, Location -->
                        <div class="form-row"
                            style="display: flex; gap: 16px; margin-bottom: 12px; align-items: flex-end;">
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 2 1 400px;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">DDC
                                    No <span style="color: #ef4444;">*</span></label>
                                <div style="display: flex; gap: 8px;">
                                    <asp:TextBox ID="txtDDC" runat="server" CssClass="form-control-input"
                                        style="flex: 2; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                        onfocus="this.style.borderColor='#0f1e36';"
                                        onblur="this.style.borderColor='#c8d0da';" placeholder="DDC Call Number" />
                                    <asp:TextBox ID="txtDdcSuffix1" runat="server" CssClass="form-control-input"
                                        style="flex: 1; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                        onfocus="this.style.borderColor='#0f1e36';"
                                        onblur="this.style.borderColor='#c8d0da';" placeholder="TUN" />
                                    <asp:TextBox ID="txtDdcSuffix2" runat="server" CssClass="form-control-input"
                                        style="flex: 0.5; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                        onfocus="this.style.borderColor='#0f1e36';"
                                        onblur="this.style.borderColor='#c8d0da';" placeholder="1" />
                                </div>
                                <asp:RequiredFieldValidator ID="rfvDDC" runat="server" ControlToValidate="txtDDC"
                                    Display="Dynamic" style="color: #ef4444; font-size: 11px;"
                                    ErrorMessage="DDC No is required." ValidationGroup="vgBook" />
                            </div>
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 200px; position: relative;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Location</label>
                                <asp:TextBox ID="txtLocation" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    onfocus="this.style.borderColor='#0f1e36';"
                                    onblur="this.style.borderColor='#c8d0da';" placeholder="Shelf / Rack Location" />
                                <div id="locationSuggestions" class="autocomplete-suggestions"
                                    style="display: none; position: absolute; top: 100%; left: 0; right: 0; background: white; border: 1px solid #cbd5e1; border-radius: 6px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); z-index: 1000; max-height: 150px; overflow-y: auto;">
                                </div>
                            </div>
                        </div>

                        <!-- Row 3: Classification (Hidden) -->
                        <div class="form-row"
                            style="display: flex; gap: 16px; margin-bottom: 12px; align-items: flex-end;">
                            <div class="form-group"
                                style="display: none; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 150px;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Classification</label>
                                <asp:TextBox ID="txtClassNo" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    onfocus="this.style.borderColor='#0f1e36';"
                                    onblur="this.style.borderColor='#c8d0da';" placeholder="Classification No." />
                            </div>
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 170px;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Language</label>
                                <div
                                    style="display: flex; gap: 4px; align-items: center; width: 100%; box-sizing: border-box;">
                                    <select id="ddlLanguage" class="form-control-input"
                                        style="flex: 1; min-width: 0; padding: 0 11px; height: 38px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box;"
                                        onchange="syncToTextBox('ddlLanguage', '<%= txtLanguage.ClientID %>')">
                                        <option value="">-- Language --</option>
                                    </select>
                                    <button type="button" onclick="openAddPopup('Language', 'ddlLanguage')"
                                        style="height: 38px; width: 34px; border-radius: 6px; border: 1px solid #cbd5e1; background: #f8fafc; font-weight: bold; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 16px; color: #0f1e36; flex-shrink: 0; outline: none;">+</button>
                                </div>
                                <div style="display: none;">
                                    <asp:TextBox ID="txtLanguage" runat="server" />
                                </div>
                            </div>
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 170px;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Format</label>
                                <div
                                    style="display: flex; gap: 4px; align-items: center; width: 100%; box-sizing: border-box;">
                                    <select id="ddlFormat" class="form-control-input"
                                        style="flex: 1; min-width: 0; padding: 0 11px; height: 38px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box;"
                                        onchange="syncToTextBox('ddlFormat', '<%= txtFormat.ClientID %>')">
                                        <option value="">-- Format --</option>
                                    </select>
                                    <button type="button" onclick="openAddPopup('Format', 'ddlFormat')"
                                        style="height: 38px; width: 34px; border-radius: 6px; border: 1px solid #cbd5e1; background: #f8fafc; font-weight: bold; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 16px; color: #0f1e36; flex-shrink: 0; outline: none;">+</button>
                                </div>
                                <div style="display: none;">
                                    <asp:TextBox ID="txtFormat" runat="server" />
                                </div>
                            </div>
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 170px;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Source</label>
                                <div
                                    style="display: flex; gap: 4px; align-items: center; width: 100%; box-sizing: border-box;">
                                    <select id="ddlSource" class="form-control-input"
                                        style="flex: 1; min-width: 0; padding: 0 11px; height: 38px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box;"
                                        onchange="syncToTextBox('ddlSource', '<%= txtSource.ClientID %>')">
                                        <option value="">-- Source --</option>
                                    </select>
                                    <button type="button" onclick="openAddPopup('Source', 'ddlSource')"
                                        style="height: 38px; width: 34px; border-radius: 6px; border: 1px solid #cbd5e1; background: #f8fafc; font-weight: bold; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 16px; color: #0f1e36; flex-shrink: 0; outline: none;">+</button>
                                </div>
                                <div style="display: none;">
                                    <asp:TextBox ID="txtSource" runat="server" />
                                </div>
                            </div>
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 150px; position: relative;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Status</label>
                                <asp:TextBox ID="txtStatus" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    onfocus="this.style.borderColor='#0f1e36';"
                                    onblur="this.style.borderColor='#c8d0da';" placeholder="On Shelf" Text="On Shelf" />
                                <div id="statusSuggestions" class="autocomplete-suggestions"
                                    style="display: none; position: absolute; top: 100%; left: 0; right: 0; background: white; border: 1px solid #cbd5e1; border-radius: 6px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); z-index: 1000; max-height: 150px; overflow-y: auto;">
                                </div>
                            </div>
                            <div class="form-group"
                                style="display: none; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 0.5 1 80px;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Seq</label>
                                <asp:TextBox ID="txtClassSeq" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    onfocus="this.style.borderColor='#0f1e36';"
                                    onblur="this.style.borderColor='#c8d0da';" placeholder="1" />
                            </div>
                        </div>

                        <!-- Subject Row -->
                        <div class="form-row"
                            style="display: flex; gap: 16px; margin-bottom: 12px; align-items: flex-end; width: 100%;">
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 100%; position: relative;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Subject
                                    <span style="color: #ef4444;">*</span></label>
                                <div
                                    style="display: flex; gap: 8px; align-items: center; width: 100%; box-sizing: border-box;">
                                    <select id="ddlCategory" class="form-control-input"
                                        style="flex: 1; min-width: 0; padding: 0 11px; height: 38px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box;"
                                        onchange="syncToTextBox('ddlCategory', '<%= txtCategory.ClientID %>')">
                                        <option value="">-- Select Subject --</option>
                                    </select>
                                    <button type="button" onclick="openAddPopup('Category', 'ddlCategory')"
                                        style="height: 38px; width: 38px; border-radius: 6px; border: 1px solid #cbd5e1; background: #f8fafc; font-weight: bold; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 18px; color: #0f1e36; flex-shrink: 0; outline: none;">+</button>
                                </div>
                                <div style="display: none;">
                                    <asp:TextBox ID="txtCategory" runat="server" />
                                </div>
                                <asp:RequiredFieldValidator ID="rfvCat" runat="server" ControlToValidate="txtCategory"
                                    Display="Dynamic" style="color: #ef4444; font-size: 11px;"
                                    ErrorMessage="Subject is required." ValidationGroup="vgBook" />
                            </div>
                        </div>

                        <!-- Row 4: Authors & Cover Image Side-by-Side (50% / 50%) -->
                        <div
                            style="display: flex; gap: 16px; margin-bottom: 12px; width: 100%; box-sizing: border-box; align-items: stretch;">
                            <!-- Left Side: Authors (50%) -->
                            <div
                                style="flex: 1 1 50%; display: flex; flex-direction: column; gap: 12px; box-sizing: border-box;">
                                <div style="display: flex; gap: 8px;">
                                    <div style="flex: 1; display: flex; flex-direction: column; gap: 4px; box-sizing: border-box;"
                                        class="form-group">
                                        <label
                                            style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Author
                                            (1) First Name</label>
                                        <asp:TextBox ID="txtAuthor1FN" runat="server" CssClass="form-control-input"
                                            style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                            onfocus="this.style.borderColor='#0f1e36';"
                                            onblur="this.style.borderColor='#c8d0da';" />
                                    </div>
                                    <div style="flex: 1; display: flex; flex-direction: column; gap: 4px; box-sizing: border-box;"
                                        class="form-group">
                                        <label
                                            style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Last
                                            Name</label>
                                        <asp:TextBox ID="txtAuthor1LN" runat="server" CssClass="form-control-input"
                                            style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                            onfocus="this.style.borderColor='#0f1e36';"
                                            onblur="this.style.borderColor='#c8d0da';" />
                                    </div>
                                </div>
                                <div style="display: flex; gap: 8px;">
                                    <div style="flex: 1; display: flex; flex-direction: column; gap: 4px; box-sizing: border-box;"
                                        class="form-group">
                                        <label
                                            style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Author
                                            (2) First Name</label>
                                        <asp:TextBox ID="txtAuthor2FN" runat="server" CssClass="form-control-input"
                                            style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                            onfocus="this.style.borderColor='#0f1e36';"
                                            onblur="this.style.borderColor='#c8d0da';" />
                                    </div>
                                    <div style="flex: 1; display: flex; flex-direction: column; gap: 4px; box-sizing: border-box;"
                                        class="form-group">
                                        <label
                                            style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Last
                                            Name</label>
                                        <asp:TextBox ID="txtAuthor2LN" runat="server" CssClass="form-control-input"
                                            style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                            onfocus="this.style.borderColor='#0f1e36';"
                                            onblur="this.style.borderColor='#c8d0da';" />
                                    </div>
                                </div>
                                <div style="display: flex; gap: 8px;">
                                    <div style="flex: 1; display: flex; flex-direction: column; gap: 4px; box-sizing: border-box;"
                                        class="form-group">
                                        <label
                                            style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Author
                                            (3) First Name</label>
                                        <asp:TextBox ID="txtAuthor3FN" runat="server" CssClass="form-control-input"
                                            style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                            onfocus="this.style.borderColor='#0f1e36';"
                                            onblur="this.style.borderColor='#c8d0da';" />
                                    </div>
                                    <div style="flex: 1; display: flex; flex-direction: column; gap: 4px; box-sizing: border-box;"
                                        class="form-group">
                                        <label
                                            style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Last
                                            Name</label>
                                        <asp:TextBox ID="txtAuthor3LN" runat="server" CssClass="form-control-input"
                                            style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                            onfocus="this.style.borderColor='#0f1e36';"
                                            onblur="this.style.borderColor='#c8d0da';" />
                                    </div>
                                </div>
                                <div class="form-group"
                                    style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; width: 100%;">
                                    <label
                                        style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Editor
                                        / Compiler</label>
                                    <asp:TextBox ID="txtEditorCompiler" runat="server" CssClass="form-control-input"
                                        style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                        onfocus="this.style.borderColor='#0f1e36';"
                                        onblur="this.style.borderColor='#c8d0da';" />
                                </div>
                            </div>

                            <!-- Right Side: Cover Image Upload (50%) -->
                            <div id="coverZone"
                                style="flex: 1 1 50%; background-color: #f8fafc; border: 1px dashed #cbd5e1; border-radius: 8px; padding: 16px; display: flex; align-items: center; gap: 16px; box-sizing: border-box;">
                                <div style="flex: 1;">
                                    <label
                                        style="font-weight: 600; margin-bottom: 4px; display: block; color: #0f1e36; font-size: 12px; text-transform: uppercase; letter-spacing: .4px;">Book
                                        Cover Image</label>
                                    <span
                                        style="font-size: 12px; color: #64748b; display: block; margin-bottom: 8px;">Upload
                                        a cover image for this book (all image formats allowed, max 2MB).</span>
                                    <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
                                        <asp:FileUpload ID="fuCover" runat="server" accept="image/*"
                                            onchange="previewCover(this)" style="font-size: 13px;" />
                                        <asp:Button ID="btnUploadCover" runat="server" Text="Upload Image"
                                            CssClass="v-btn v-btn-primary"
                                            style="display: flex; align-items: center; justify-content: center; gap: 8px; width: auto; height: 34px; border-radius: 6px; font-weight: 600; font-size: 12px; cursor: pointer; border: none; background-color: #0f1e36; color: #ffffff; transition: all 0.2s ease; box-shadow: 0 1px 3px rgba(0,0,0,0.05); text-decoration: none; padding: 0 16px;"
                                            onmouseover="this.style.backgroundColor='#1e293b';"
                                            onmouseout="this.style.backgroundColor='#0f1e36';"
                                            OnClick="btnUploadCover_Click" />
                                        <asp:Button ID="btnClearCover" runat="server" Text="Remove Image"
                                            CssClass="v-btn v-btn-danger"
                                            style="display: flex; align-items: center; justify-content: center; gap: 8px; width: auto; height: 34px; border-radius: 6px; font-weight: 600; font-size: 12px; cursor: pointer; border: none; background-color: #ef4444; color: #ffffff; transition: all 0.2s ease; box-shadow: 0 1px 3px rgba(0,0,0,0.05); text-decoration: none; padding: 0 16px;"
                                            onmouseover="this.style.backgroundColor='#dc2626';"
                                            onmouseout="this.style.backgroundColor='#ef4444';"
                                            OnClick="btnClearCover_Click" />
                                    </div>
                                    <asp:Label ID="lblCoverStatus" runat="server"
                                        style="display: block; font-size: 12px; margin-top: 6px; color: #0f1e36;" />
                                </div>
                                <div
                                    style="width: 120px; height: 150px; border: 1px solid #cbd5e1; border-radius: 6px; background-color: #f1f5f9; display: flex; align-items: center; justify-content: center; overflow: hidden; position: relative; flex-shrink: 0;">
                                    <span id="coverPlaceholder" runat="server"
                                        style="font-size: 11px; color: #94a3b8; text-align: center;">No Image</span>
                                    <asp:Image ID="imgCoverPreview" runat="server"
                                        style="max-width: 100%; max-height: 100%; display: none;" />
                                </div>
                            </div>
                        </div>

                        <!-- Title Row -->
                        <div class="form-row"
                            style="display: flex; gap: 16px; margin-bottom: 12px; align-items: flex-end; width: 100%;">
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 100%;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Title
                                    <span style="color: #ef4444;">*</span></label>
                                <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    onfocus="this.style.borderColor='#0f1e36';"
                                    onblur="this.style.borderColor='#c8d0da';" placeholder="Full book title" />
                                <asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtTitle"
                                    Display="Dynamic" style="color: #ef4444; font-size: 11px;"
                                    ErrorMessage="Title is required." ValidationGroup="vgBook" />
                            </div>
                        </div>

                        <!-- Sub Title Row -->
                        <div class="form-row"
                            style="display: flex; gap: 16px; margin-bottom: 12px; align-items: flex-end; width: 100%;">
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 100%;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Sub
                                    Title</label>
                                <asp:TextBox ID="txtSubTitle" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    onfocus="this.style.borderColor='#0f1e36';"
                                    onblur="this.style.borderColor='#c8d0da';" placeholder="Sub-title (if any)" />
                            </div>
                        </div>

                        <!-- Publisher | LI Date Row -->
                        <div class="form-row"
                            style="display: flex; gap: 16px; margin-bottom: 12px; align-items: flex-end;">
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 2 1 400px; position: relative;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Publisher</label>
                                <asp:TextBox ID="txtPublisher" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    onfocus="this.style.borderColor='#0f1e36';"
                                    onblur="this.style.borderColor='#c8d0da';" placeholder="Publisher" />
                                <div id="publisherSuggestions" class="autocomplete-suggestions"
                                    style="display: none; position: absolute; top: 100%; left: 0; right: 0; background: white; border: 1px solid #cbd5e1; border-radius: 6px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); z-index: 1000; max-height: 150px; overflow-y: auto;">
                                </div>
                            </div>
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 200px;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">LI.
                                    Date</label>
                                <asp:TextBox ID="txtLiDate" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    onfocus="this.style.borderColor='#0f1e36';"
                                    onblur="this.style.borderColor='#c8d0da';" placeholder="LI Date" />
                            </div>
                        </div>

                        <!-- Publishing Place | Publishing Year | Edition Row -->
                        <div class="form-row"
                            style="display: flex; gap: 16px; margin-bottom: 12px; align-items: flex-end;">
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 200px;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Publishing
                                    Place</label>
                                <asp:TextBox ID="txtPublishingPlace" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    onfocus="this.style.borderColor='#0f1e36';"
                                    onblur="this.style.borderColor='#c8d0da';" placeholder="City" />
                            </div>
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 200px;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Publishing
                                    Year</label>
                                <asp:TextBox ID="txtPubYear" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    onfocus="this.style.borderColor='#0f1e36';"
                                    onblur="this.style.borderColor='#c8d0da';" placeholder="2024" TextMode="Number" />
                            </div>
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 200px;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Edition</label>
                                <div
                                    style="display: flex; gap: 4px; align-items: center; width: 100%; box-sizing: border-box;">
                                    <select id="ddlEdition" class="form-control-input"
                                        style="flex: 1; min-width: 0; padding: 0 11px; height: 38px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box;"
                                        onchange="syncToTextBox('ddlEdition', '<%= txtEdition.ClientID %>')">
                                        <option value="">-- Edition --</option>
                                    </select>
                                    <button type="button" onclick="openAddPopup('Edition', 'ddlEdition')"
                                        style="height: 38px; width: 34px; border-radius: 6px; border: 1px solid #cbd5e1; background: #f8fafc; font-weight: bold; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 16px; color: #0f1e36; flex-shrink: 0; outline: none;">+</button>
                                </div>
                                <div style="display: none;">
                                    <asp:TextBox ID="txtEdition" runat="server" />
                                </div>
                            </div>
                        </div>

                        <!-- Collation | ISBN | Volume Row -->
                        <div class="form-row"
                            style="display: flex; gap: 16px; margin-bottom: 12px; align-items: flex-end;">
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 200px;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Collation
                                    (Pages)</label>
                                <asp:TextBox ID="txtPageCount" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    onfocus="this.style.borderColor='#0f1e36';"
                                    onblur="this.style.borderColor='#c8d0da';" placeholder="350" TextMode="Number" />
                            </div>
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 200px; position: relative;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">ISBN</label>
                                <asp:TextBox ID="txtISBN13" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    onfocus="this.style.borderColor='#0f1e36';"
                                    onblur="this.style.borderColor='#c8d0da';" placeholder="ISBN-13"
                                    onkeyup="liveValidateISBN(this.value)" />
                                <span id="isbnBadge"
                                    style="position: absolute; right: 10px; top: 55%; transform: translateY(-50%); font-size: 11px; font-weight: 700; padding: 2px 8px; border-radius: 12px; background: #e2e8f0; color: #555;">ISBN</span>
                            </div>
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 200px;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Volume</label>
                                <asp:TextBox ID="txtVolume" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    onfocus="this.style.borderColor='#0f1e36';"
                                    onblur="this.style.borderColor='#c8d0da';" placeholder="Volume" />
                            </div>
                        </div>

                        <!-- www Link | Series | No of copies Row -->
                        <div class="form-row"
                            style="display: flex; gap: 16px; margin-bottom: 12px; align-items: flex-end;">
                            <div class="form-group"
                                style="display: none; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 200px;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">www
                                    Link</label>
                                <asp:TextBox ID="txtWwwLink" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    onfocus="this.style.borderColor='#0f1e36';"
                                    onblur="this.style.borderColor='#c8d0da';" placeholder="http://" />
                            </div>
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 200px;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Series</label>
                                <asp:TextBox ID="txtSeries" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    onfocus="this.style.borderColor='#0f1e36';"
                                    onblur="this.style.borderColor='#c8d0da';" placeholder="Series" />
                            </div>
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 200px;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">No
                                    of copies</label>
                                <asp:TextBox ID="txtCopyCount" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    onfocus="this.style.borderColor='#0f1e36';"
                                    onblur="this.style.borderColor='#c8d0da';" Text="1" TextMode="Number" min="1" />
                            </div>
                        </div>

                        <!-- Donated By / Membership No / Donor Name Row -->
                        <div class="form-row"
                            style="display: flex; gap: 16px; margin-bottom: 12px; align-items: flex-end;">
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 200px;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Donated
                                    By</label>
                                <asp:TextBox ID="txtDonatedBy" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    onfocus="this.style.borderColor='#0f1e36';"
                                    onblur="this.style.borderColor='#c8d0da';" placeholder="Donated By" />
                            </div>
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 200px; position: relative;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Membership
                                    No</label>
                                <div style="position: relative; width: 100%;">
                                    <asp:TextBox ID="txtMSNo" runat="server" CssClass="form-control-input"
                                        style="width: 100%; padding: 8px 11px; padding-right: 75px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                        onfocus="this.style.borderColor='#0f1e36';"
                                        onblur="this.style.borderColor='#c8d0da'; lookupMemberByNo();" placeholder="Membership Number" />
                                    <span id="memberStatusBadge"
                                         style="position: absolute; right: 10px; top: 50%; transform: translateY(-50%); font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 12px; background: #e2e8f0; color: #555; display: none;"></span>
                                </div>
                            </div>
                            <div class="form-group"
                                style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box; flex: 1 1 200px;">
                                <label
                                    style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Member
                                    Name</label>
                                <asp:TextBox ID="txtDonatedByName" runat="server" CssClass="form-control-input"
                                    style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: #f1f5f9; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                    onfocus="this.style.borderColor='#0f1e36';"
                                    onblur="this.style.borderColor='#c8d0da';" placeholder="Auto-populated from Membership No" />
                            </div>
                        </div>



                        <!-- Bottom details: Price, Cost, Checkboxes, Subject Box -->
                        <div
                            style="display: flex; gap: 16px; margin-top: 16px; width: 100%; box-sizing: border-box; border-top: 1px solid #dde3ea; padding-top: 16px;">
                            <!-- Left: Pricing details -->
                            <div style="flex: 1; display: flex; flex-direction: column; gap: 12px;">
                                <div class="form-group"
                                    style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box;">
                                    <label
                                        style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Purchase
                                        Ref</label>
                                    <asp:TextBox ID="txtPurchaseRef" runat="server" CssClass="form-control-input"
                                        style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                        onfocus="this.style.borderColor='#0f1e36';"
                                        onblur="this.style.borderColor='#c8d0da';" />
                                </div>
                                <div class="form-group"
                                    style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box;">
                                    <label
                                        style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Date
                                        of Purchase</label>
                                    <asp:TextBox ID="txtPurchaseDate" runat="server" CssClass="form-control-input"
                                        style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                        onfocus="this.style.borderColor='#0f1e36';"
                                        onblur="this.style.borderColor='#c8d0da';" placeholder="dd/MM/yyyy" />
                                </div>
                                <div class="form-group"
                                    style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box;">
                                    <label
                                        style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Price
                                        (FCY)</label>
                                    <asp:TextBox ID="txtPriceFcy" runat="server" CssClass="form-control-input"
                                        style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                        onfocus="this.style.borderColor='#0f1e36';"
                                        onblur="this.style.borderColor='#c8d0da';" placeholder="0.00" />
                                </div>
                                <div class="form-group"
                                    style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box;">
                                    <label
                                        style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Price
                                        (PKR)</label>
                                    <asp:TextBox ID="txtPricePkr" runat="server" CssClass="form-control-input"
                                        style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                        onfocus="this.style.borderColor='#0f1e36';"
                                        onblur="this.style.borderColor='#c8d0da';" placeholder="0.00" />
                                </div>
                                <div class="form-group"
                                    style="display: flex; flex-direction: column; gap: 4px; box-sizing: border-box;">
                                    <label
                                        style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px;">Cost
                                        (PKR)</label>
                                    <asp:TextBox ID="txtCopyCost" runat="server" CssClass="form-control-input"
                                        style="width: 100%; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box; transition: border-color 0.2s; height: 38px;"
                                        onfocus="this.style.borderColor='#0f1e36';"
                                        onblur="this.style.borderColor='#c8d0da';" placeholder="0.00" />
                                </div>
                            </div>

                            <!-- Right: Checkboxes & Subjects listbox -->
                            <div style="flex: 1; display: flex; flex-direction: column; gap: 12px;">
                                <div style="display: flex; flex-direction: column; gap: 8px; font-size: 13px;">
                                    <label
                                        style="display: flex; align-items: center; gap: 8px; cursor: pointer; font-weight: 500;">
                                        <asp:CheckBox ID="cbReference" runat="server" /> Reference Book
                                    </label>
                                    <label
                                        style="display: none; align-items: center; gap: 8px; cursor: pointer; font-weight: 500;">
                                        <asp:CheckBox ID="cbNotIssued" runat="server" /> Not to be Issued
                                    </label>
                                    <label
                                        style="display: flex; align-items: center; gap: 8px; cursor: pointer; font-weight: 500;">
                                        <asp:CheckBox ID="cbPrintDetails" runat="server" /> Print Book Detail
                                    </label>
                                    <label
                                        style="display: flex; align-items: center; gap: 8px; cursor: pointer; font-weight: 500;">
                                        <asp:CheckBox ID="cbAdults" runat="server" /> Adults
                                    </label>
                                    <label
                                        style="display: flex; align-items: center; gap: 8px; cursor: pointer; font-weight: 500;">
                                        <asp:CheckBox ID="cbChildren" runat="server" /> Children
                                    </label>
                                </div>

                                <div class="form-group" style="flex: 1;">
                                    <label>Topics & Classification</label>
                                    <div
                                        style="border: 1px solid #c8d0da; border-radius: 6px; background: #f8fafc; padding: 12px; min-height: 120px; font-family: monospace; font-size: 12px; color: #334155; overflow-y: auto;">
                                        <strong>Subject:</strong> <span id="lblTopicSubject"
                                            style="color: #0f1e36; font-weight: bold;">(Select a Category)</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Styled Visible Physical Copies & QR Cards Panel -->
                        <asp:Panel ID="pnlExistingCopies" runat="server" Visible="false"
                            style="margin-top: 24px; border-top: 1px solid #dde3ea; padding-top: 24px;">
                            <h3 style="font-size: 16px; font-weight: 600; color: #0f1e36; margin: 0 0 12px;">Physical
                                Copies & QR Codes</h3>
                            <div
                                style="overflow-x: auto; background: #ffffff; border: 1px solid #dde3ea; border-radius: 8px;">
                                <table
                                    style="width: 100%; border-collapse: collapse; text-align: left; font-size: 13px;">
                                    <thead>
                                        <tr
                                            style="background: #f8fafc; border-bottom: 1px solid #dde3ea; color: #475569; font-weight: 600; font-family: 'Outfit', sans-serif;">
                                            <th style="padding: 10px 12px;">Book No</th>
                                            <th style="padding: 10px 12px;">Barcode</th>
                                            <th style="padding: 10px 12px;">Location</th>
                                            <th style="padding: 10px 12px;">Condition</th>
                                            <th style="padding: 10px 12px;">Status</th>
                                            <th style="padding: 10px 12px; text-align: right;">Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <asp:Repeater ID="rptCopies" runat="server" OnItemCommand="rptCopies_Command">
                                            <ItemTemplate>
                                                <tr
                                                    style="border-bottom: 1px solid #f1f5f9; font-family: 'Outfit', sans-serif;">
                                                    <td style="padding: 10px 12px; font-weight: bold;">
                                                        <%# Eval("BookNo") %>
                                                    </td>
                                                    <td
                                                        style="padding: 10px 12px; font-family: monospace; font-weight: bold;">
                                                        <%# Eval("Barcode") %>
                                                    </td>
                                                    <td style="padding: 10px 12px;">
                                                        <%# Eval("FullAddress") ?? "Not Assigned" %>
                                                    </td>
                                                    <td style="padding: 10px 12px;"><span
                                                            style='<%# GetConditionStyle(Eval("CondName")) %>'>
                                                            <%# GetConditionDisplayName(Eval("CondName")) %>
                                                        </span></td>
                                                    <td style="padding: 10px 12px;"><span
                                                            style='<%# GetAvailabilityStyle(Eval("IsAvailable")) %>'>
                                                            <%# Convert.ToBoolean(Eval("IsAvailable")) ? "Available"
                                                                : "On Loan" %>
                                                        </span></td>
                                                    <td style="padding: 10px 12px; text-align: right;">
                                                        <div style="display: flex; gap: 6px; justify-content: flex-end;">
                                                            <button type="button" class="v-btn"
                                                                style="display: inline-flex; width: auto; height: 30px; padding: 0 10px; font-size: 11px; align-items: center;"
                                                                onclick='<%# "editCopy(" + Eval("CopyID") + ", \"" + Server.HtmlEncode(GetConditionDisplayName(Eval("CondName"))) + "\", \"" + Server.HtmlEncode((Eval("FullAddress") ?? "").ToString()) + "\");" %>'>Edit</button>
                                                            <button type="button" class="v-btn"
                                                                style="display: inline-flex; width: auto; height: 30px; padding: 0 10px; font-size: 11px; align-items: center;"
                                                                onclick='<%# "printSingleCopyQR(\"" + Eval("Barcode") + "\", \"" + Eval("BookNo") + "\");" %>'>Print
                                                                QR</button>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </tbody>
                                </table>
                            </div>
                            <div style="margin-top: 12px; display: flex; justify-content: flex-end;">
                                <button type="button" class="v-btn v-btn-primary"
                                    style="width: auto; height: 36px; padding: 0 16px;"
                                    onclick="printAllCopyQRs()">Print All QR Codes</button>
                            </div>
                        </asp:Panel>

                        <div style="display:none;">
                            <!-- Hidden inputs to satisfy existing code-behind without UI changes -->
                            <asp:TextBox ID="txtDescription" runat="server" />
                            <asp:TextBox ID="txtRecBy" runat="server" />
                            <asp:TextBox ID="txtAcqDate" runat="server" />
                            <asp:TextBox ID="txtValue" runat="server" />
                            <asp:TextBox ID="txtRemarks" runat="server" />
                            <asp:Panel ID="pnlCurrentCover" runat="server">
                                <asp:Label ID="lblCurrentCoverFile" runat="server" />
                            </asp:Panel>
                            <asp:TextBox ID="txtISBN10" runat="server" />
                            <asp:TextBox ID="txtTags" runat="server" />
                            <asp:TextBox ID="txtCopyNotes" runat="server" />
                            <asp:TextBox ID="txtAuthorName" runat="server" />
                            <asp:DropDownList ID="ddlAuthorRole" runat="server">
                                <asp:ListItem>Author</asp:ListItem>
                            </asp:DropDownList>
                            <asp:Repeater ID="rptAuthors" runat="server"></asp:Repeater>
                            <asp:Button ID="btnGenerateISBN" runat="server" OnClick="btnGenerateISBN_Click" />
                            <asp:DropDownList ID="ddlHall" runat="server">
                                <asp:ListItem Value="0">H</asp:ListItem>
                            </asp:DropDownList>
                            <asp:DropDownList ID="ddlAisle" runat="server" Enabled="false">
                                <asp:ListItem Value="0">A</asp:ListItem>
                            </asp:DropDownList>
                            <asp:DropDownList ID="ddlShelfUnit" runat="server" Enabled="false">
                                <asp:ListItem Value="0">S</asp:ListItem>
                            </asp:DropDownList>
                            <asp:DropDownList ID="ddlRack" runat="server" Enabled="false">
                                <asp:ListItem Value="0">R</asp:ListItem>
                            </asp:DropDownList>
                            <asp:Panel ID="pnlRackSlots" runat="server"></asp:Panel>
                            <asp:Panel ID="pnlLocationSummary" runat="server"></asp:Panel>
                            <asp:Label ID="lblSelectedLocation" runat="server" />
                            <asp:Label ID="lblSelectedSlot" runat="server" />
                            <asp:LinkButton ID="lbClearLocation" runat="server" OnClick="lbClearLocation_Click" />
                            <asp:HiddenField ID="hfIsDdcEdited" runat="server" Value="false" />
                        </div>

                        <!-- Action Buttons Row -->
                        <div
                            style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 24px; border-top: 1px solid #dde3ea; padding-top: 16px; width: 100%; box-sizing: border-box;">
                            <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="v-btn v-btn-primary"
                                style="display: flex; align-items: center; justify-content: center; gap: 8px; width: auto; height: 40px; border-radius: 6px; font-weight: 600; font-size: 13.5px; cursor: pointer; border: none; background-color: #0f1e36; color: #ffffff; transition: all 0.2s ease; box-shadow: 0 1px 3px rgba(0,0,0,0.05); text-decoration: none; padding: 0 24px;"
                                onmouseover="this.style.backgroundColor='#1e293b';"
                                onmouseout="this.style.backgroundColor='#0f1e36';" ValidationGroup="vgBook"
                                OnClick="btnSave_Click" />
                            <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="v-btn"
                                style="display: flex; align-items: center; justify-content: center; gap: 8px; width: auto; height: 40px; border-radius: 6px; font-weight: 600; font-size: 13.5px; cursor: pointer; border: 1px solid #c8d0da; background-color: #ffffff; color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 1px 3px rgba(0,0,0,0.05); text-decoration: none; padding: 0 24px;"
                                onmouseover="this.style.backgroundColor='#f8fafc'; this.style.borderColor='#94a3b8';"
                                onmouseout="this.style.backgroundColor='#ffffff'; this.style.borderColor='#c8d0da';"
                                ValidationGroup="vgBook" OnClick="btnUpdate_Click" Visible="false" />
                            <asp:Button ID="btnSaveAddCopy" runat="server" Text="New" CssClass="v-btn"
                                style="display: flex; align-items: center; justify-content: center; gap: 8px; width: auto; height: 40px; border-radius: 6px; font-weight: 600; font-size: 13.5px; cursor: pointer; border: 1px solid #c8d0da; background-color: #ffffff; color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 1px 3px rgba(0,0,0,0.05); text-decoration: none; padding: 0 24px;"
                                onmouseover="this.style.backgroundColor='#f8fafc'; this.style.borderColor='#94a3b8';"
                                onmouseout="this.style.backgroundColor='#ffffff'; this.style.borderColor='#c8d0da';"
                                OnClick="btnSaveAddCopy_Click" />
                            <a href="AddEditBook.aspx" class="v-btn"
                                style="display: inline-flex; align-items: center; justify-content: center; gap: 8px; width: auto; height: 40px; border-radius: 6px; font-weight: 600; font-size: 13.5px; cursor: pointer; border: 1px solid #c8d0da; background-color: #ffffff; color: #0f1e36; transition: all 0.2s ease; box-shadow: 0 1px 3px rgba(0,0,0,0.05); text-decoration: none; padding: 0 24px; box-sizing: border-box;"
                                onmouseover="this.style.backgroundColor='#f8fafc'; this.style.borderColor='#94a3b8';"
                                onmouseout="this.style.backgroundColor='#ffffff'; this.style.borderColor='#c8d0da';">Refresh</a>

                            <!-- Modal Popup for adding new options -->
                            <div id="addOptionModal"
                                style="display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(15, 30, 54, 0.4); backdrop-filter: blur(4px); align-items: center; justify-content: center;">
                                <div
                                    style="background-color: #ffffff; margin: auto; padding: 24px; border: 1px solid #dde3ea; border-radius: 12px; width: 90%; max-width: 400px; box-shadow: 0 4px 20px rgba(0,0,0,0.15); box-sizing: border-box; font-family: 'Outfit', sans-serif;">
                                    <h3 id="modalTitle"
                                        style="margin-top: 0; margin-bottom: 12px; color: #0f1e36; font-size: 18px; font-weight: 600;">
                                        Add New Option</h3>
                                    <div style="margin-bottom: 20px;">
                                        <label id="modalFieldLabel"
                                            style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px; display: block; margin-bottom: 6px;">New
                                            Value</label>
                                        <input type="text" id="txtModalNewValue" class="form-control-input"
                                            style="width: 100%; height: 38px; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; outline: none; box-sizing: border-box;"
                                            placeholder="Enter new item name" />
                                        <span id="modalErrorMsg"
                                            style="color: #ef4444; font-size: 11px; display: none; margin-top: 4px;">Value
                                            cannot be empty.</span>
                                    </div>
                                    <div style="display: flex; justify-content: flex-end; gap: 10px;">
                                        <button type="button" class="v-btn"
                                            style="width: auto; height: 36px; padding: 0 16px; border: 1px solid #c8d0da; background: #ffffff; color: #0f1e36; border-radius: 6px; font-weight: 600; font-size: 12px; cursor: pointer;"
                                            onclick="closeAddPopup()">Cancel</button>
                                        <button type="button" class="v-btn v-btn-primary"
                                            style="width: auto; height: 36px; padding: 0 16px; border: none; background: #0f1e36; color: #ffffff; border-radius: 6px; font-weight: 600; font-size: 12px; cursor: pointer;"
                                            onclick="saveNewOption()">Save</button>
                                    </div>
                                </div>
                            </div>

                            <!-- Edit Copy Modal -->
                            <div id="editCopyModal"
                                style="display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(15, 30, 54, 0.4); backdrop-filter: blur(4px); align-items: center; justify-content: center;">
                                <div
                                    style="background-color: #ffffff; margin: auto; padding: 24px; border: 1px solid #dde3ea; border-radius: 12px; width: 90%; max-width: 420px; box-shadow: 0 4px 20px rgba(0,0,0,0.15); box-sizing: border-box; font-family: 'Outfit', sans-serif;">
                                    <h3 style="margin-top: 0; margin-bottom: 16px; color: #0f1e36; font-size: 18px; font-weight: 600;">Edit Copy Details</h3>
                                    <input type="hidden" id="editCopyId" value="0" />
                                    <div style="display: flex; flex-direction: column; gap: 12px; margin-bottom: 20px;">
                                        <div>
                                            <label style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px; display: block; margin-bottom: 4px;">Condition</label>
                                            <select id="editCopyCondition" class="form-control-input"
                                                style="width: 100%; height: 38px; padding: 0 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; background-color: white; outline: none; box-sizing: border-box;">
                                                <option value="New">New</option>
                                                <option value="Old">Old</option>
                                                <option value="SecondHand">SecondHand</option>
                                            </select>
                                        </div>
                                        <div>
                                            <label style="font-size: 12px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: .4px; display: block; margin-bottom: 4px;">Location</label>
                                            <input type="text" id="editCopyLocation" class="form-control-input"
                                                style="width: 100%; height: 38px; padding: 8px 11px; border: 1px solid #c8d0da; border-radius: 6px; font-size: 14px; outline: none; box-sizing: border-box;"
                                                placeholder="Shelf / Rack Location" />
                                        </div>
                                    </div>
                                    <div style="display: flex; justify-content: flex-end; gap: 10px;">
                                        <button type="button" class="v-btn"
                                            style="width: auto; height: 36px; padding: 0 16px; border: 1px solid #c8d0da; background: #ffffff; color: #0f1e36; border-radius: 6px; font-weight: 600; font-size: 12px; cursor: pointer;"
                                            onclick="closeCopyEditModal()">Cancel</button>
                                        <button type="button" class="v-btn v-btn-primary"
                                            style="width: auto; height: 36px; padding: 0 16px; border: none; background: #0f1e36; color: #ffffff; border-radius: 6px; font-weight: 600; font-size: 12px; cursor: pointer;"
                                            onclick="saveCopyEdit()">Save Changes</button>
                                    </div>
                                </div>
                            </div>

                        </div>
                    </div>

            </ContentTemplate>
        </asp:UpdatePanel>

        <script>
            // ISBN live validation (no fixed character limit or checksum)
            function liveValidateISBN(val) {
                var clean = val.replace(/[\s\-]/g, '');
                var badge = document.getElementById('isbnBadge');
                if (clean.length === 0) {
                    badge.style.background = '#e2e8f0';
                    badge.style.color = '#555';
                    badge.textContent = 'ISBN';
                    return;
                }

                if (/[a-zA-Z]/.test(clean)) {
                    // Check if it looks like a standard ISBN-10 ending with X/x
                    if (clean.length === 10 && /^\d{9}[Xx]$/.test(clean)) {
                        badge.style.background = '#d4edda';
                        badge.style.color = '#155724';
                        badge.textContent = 'ISBN-10';
                        return;
                    }
                    badge.style.background = '#eff6ff';
                    badge.style.color = '#1e40af';
                    badge.textContent = 'Custom';
                    return;
                }

                // If fully numeric and 13 digits, show ISBN-13
                if (clean.length === 13 && /^\d{13}$/.test(clean)) {
                    badge.style.background = '#d4edda';
                    badge.style.color = '#155724';
                    badge.textContent = 'ISBN-13';
                    return;
                }

                // If fully numeric and 10 digits, show ISBN-10
                if (clean.length === 10 && /^\d{10}$/.test(clean)) {
                    badge.style.background = '#d4edda';
                    badge.style.color = '#155724';
                    badge.textContent = 'ISBN-10';
                    return;
                }

                // Any other length — just show the count, no error
                badge.style.background = '#e2e8f0';
                badge.style.color = '#555';
                badge.textContent = clean.length + ' chars';
            }

            // Lookup member name by Membership No on blur
            function lookupMemberByNo() {
                var msNoEl = document.getElementById('<%= txtMSNo.ClientID %>');
                var donorNameEl = document.getElementById('<%= txtDonatedByName.ClientID %>');
                var badge = document.getElementById('memberStatusBadge');
                if (!msNoEl || !donorNameEl) return;
                var msNo = msNoEl.value.trim();
                if (!msNo) {
                    donorNameEl.value = '';
                    if (badge) badge.style.display = 'none';
                    return;
                }
                callWebMethod('GetMemberNameByNo', { memberNo: msNo }, function (result) {
                    if (result && result.indexOf('|') > -1) {
                        var parts = result.split('|');
                        var name = parts[0];
                        var status = parts[1];
                        donorNameEl.value = name || '';
                        if (badge) {
                            badge.textContent = status;
                            badge.style.display = 'inline-block';
                            if (status.toLowerCase() === 'active') {
                                badge.style.background = '#d1fae5';
                                badge.style.color = '#065f46';
                            } else {
                                badge.style.background = '#fee2e2';
                                badge.style.color = '#991b1b';
                            }
                        }
                    } else {
                        donorNameEl.value = result || '';
                        if (badge) badge.style.display = 'none';
                    }
                });
            }

            // Cover image preview
            function previewCover(input) {
                if (!input.files || !input.files[0]) return;
                var file = input.files[0];
                if (file.size > 2 * 1024 * 1024) { alert('Image must be under 2 MB.'); input.value = ''; return; }
                var reader = new FileReader();
                reader.onload = function (e) {
                    alert('Image loaded successfully for upload. Click Save to complete.');
                };
                reader.readAsDataURL(file);
            }

            // AJAX WebMethod helper
            function callWebMethod(method, data, onSuccess) {
                fetch('AddEditBook.aspx/' + method, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json; charset=utf-8'
                    },
                    body: JSON.stringify(data)
                })
                    .then(r => r.json())
                    .then(data => onSuccess(data.d))
                    .catch(err => console.error(err));
            }

            var generationTimeout;
            function debouncedGeneration() {
                clearTimeout(generationTimeout);
                generationTimeout = setTimeout(triggerParallelGeneration, 250);
            }

            function triggerParallelGeneration() {
                var category = document.getElementById('<%= txtCategory.ClientID %>').value;

                // Update the Topics & Classification box
                var topicSubject = document.getElementById('lblTopicSubject');
                if (topicSubject) {
                    topicSubject.textContent = category && category.trim() !== '' ? category : "(Select a Category)";
                }
            }

            var ddcSuffixTimeout;
            function debouncedUpdateDdcSuffix2() {
                clearTimeout(ddcSuffixTimeout);
                ddcSuffixTimeout = setTimeout(updateDdcSuffix2, 250);
            }

            function updateDdcSuffix2() {
                var ddcVal = document.getElementById('<%= txtDDC.ClientID %>').value.trim();
                var suffix1Val = document.getElementById('<%= txtDdcSuffix1.ClientID %>').value.trim();
                if (ddcVal && suffix1Val) {
                    callWebMethod('GetNextDdcSuffix2', { ddc: ddcVal, suffix1: suffix1Val }, function (nextVal) {
                        var txtDdcSuffix2 = document.getElementById('<%= txtDdcSuffix2.ClientID %>');
                        if (txtDdcSuffix2) {
                            if (nextVal !== "") {
                                txtDdcSuffix2.value = nextVal;
                            } else {
                                if (txtDdcSuffix2.value.trim() === "") {
                                    txtDdcSuffix2.value = "1";
                                }
                            }
                        }
                    });
                }
            }

            function setupAutocomplete(inputId, suggestionsId, webMethodName, onSelectCallback) {
                var input = document.getElementById(inputId);
                var suggestions = document.getElementById(suggestionsId);
                if (!input || !suggestions) return;

                input.addEventListener('input', function () {
                    var val = input.value;
                    if (!val || val.trim().length < 2) {
                        suggestions.innerHTML = '';
                        suggestions.style.display = 'none';
                        return;
                    }

                    callWebMethod(webMethodName, { query: val }, function (res) {
                        suggestions.innerHTML = '';
                        if (res && res.length > 0) {
                            res.forEach(function (item) {
                                var div = document.createElement('div');
                                div.textContent = item;
                                div.style.padding = "8px 12px";
                                div.style.fontSize = "13.5px";
                                div.style.color = "#1e293b";
                                div.style.cursor = "pointer";
                                div.style.fontFamily = "'Outfit', sans-serif";
                                div.style.transition = "background-color 0.15s ease, color 0.15s ease";
                                div.onmouseover = function () { this.style.backgroundColor = "#f1f5f9"; this.style.color = "#0f1e36"; };
                                div.onmouseout = function () { this.style.backgroundColor = ""; this.style.color = "#1e293b"; };
                                div.onmousedown = function () { this.style.backgroundColor = "#e2e8f0"; };
                                div.addEventListener('click', function () {
                                    input.value = item;
                                    suggestions.innerHTML = '';
                                    suggestions.style.display = 'none';
                                    if (onSelectCallback) onSelectCallback();
                                });
                                suggestions.appendChild(div);
                            });
                            suggestions.style.display = 'block';
                        } else {
                            suggestions.style.display = 'none';
                        }
                    });
                });

                document.addEventListener('click', function (e) {
                    if (e.target !== input && e.target !== suggestions && !suggestions.contains(e.target)) {
                        suggestions.style.display = 'none';
                    }
                });
            }

            function setupStaticAutocomplete(inputId, suggestionsId, staticList) {
                var input = document.getElementById(inputId);
                var suggestions = document.getElementById(suggestionsId);
                if (!input || !suggestions) return;

                input.addEventListener('input', function () {
                    var val = input.value.toLowerCase();
                    suggestions.innerHTML = '';
                    if (!val) {
                        suggestions.style.display = 'none';
                        return;
                    }
                    var filtered = staticList.filter(x => x.toLowerCase().includes(val));
                    if (filtered.length > 0) {
                        filtered.forEach(function (item) {
                            var div = document.createElement('div');
                            div.textContent = item;
                            div.style.padding = "8px 12px";
                            div.style.fontSize = "13.5px";
                            div.style.color = "#1e293b";
                            div.style.cursor = "pointer";
                            div.style.fontFamily = "'Outfit', sans-serif";
                            div.style.transition = "background-color 0.15s ease, color 0.15s ease";
                            div.onmouseover = function () { this.style.backgroundColor = "#f1f5f9"; this.style.color = "#0f1e36"; };
                            div.onmouseout = function () { this.style.backgroundColor = ""; this.style.color = "#1e293b"; };
                            div.onmousedown = function () { this.style.backgroundColor = "#e2e8f0"; };
                            div.addEventListener('click', function () {
                                input.value = item;
                                suggestions.innerHTML = '';
                                suggestions.style.display = 'none';
                            });
                            suggestions.appendChild(div);
                        });
                        suggestions.style.display = 'block';
                    } else {
                        suggestions.style.display = 'none';
                    }
                });

                document.addEventListener('click', function (e) {
                    if (e.target !== input && e.target !== suggestions && !suggestions.contains(e.target)) {
                        suggestions.style.display = 'none';
                    }
                });
            }

            function initAutocomplete() {
                setupAutocomplete('<%= txtPublisher.ClientID %>', 'publisherSuggestions', 'GetPublisherSuggestions', debouncedGeneration);
                setupAutocomplete('<%= txtCategory.ClientID %>', 'categorySuggestions', 'GetCategorySuggestions', debouncedGeneration);
                setupAutocomplete('<%= txtLanguage.ClientID %>', 'languageSuggestions', 'GetLanguageSuggestions', debouncedGeneration);

                setupStaticAutocomplete('<%= txtFormat.ClientID %>', 'formatSuggestions', ["Book", "Journal", "Magazine", "CD/DVD", "Manuscript"]);
                setupStaticAutocomplete('<%= txtSource.ClientID %>', 'sourceSuggestions', ["Donated", "Purchased", "Gift"]);
                setupStaticAutocomplete('<%= txtStatus.ClientID %>', 'statusSuggestions', ["On Shelf", "Issued", "Reference Only", "Lost", "Damaged"]);
                setupStaticAutocomplete('<%= txtCopyCondition.ClientID %>', 'conditionSuggestions', ["New", "Old", "SecondHand"]);
            }

            function registerLiveTriggers() {
                var inputs = [
                    '<%= txtCategory.ClientID %>',
                    '<%= txtAuthor1FN.ClientID %>',
                    '<%= txtAuthor1LN.ClientID %>',
                    '<%= txtPublisher.ClientID %>',
                    '<%= txtEdition.ClientID %>',
                    '<%= txtLanguage.ClientID %>',
                    '<%= txtPubYear.ClientID %>'
                ];
                inputs.forEach(function (id) {
                    var el = document.getElementById(id);
                    if (el) {
                        el.addEventListener('input', debouncedGeneration);
                        el.addEventListener('change', debouncedGeneration);
                    }
                });

                var ddcEl = document.getElementById('<%= txtDDC.ClientID %>');
                var suffix1El = document.getElementById('<%= txtDdcSuffix1.ClientID %>');
                if (ddcEl) {
                    ddcEl.addEventListener('input', debouncedUpdateDdcSuffix2);
                    ddcEl.addEventListener('change', updateDdcSuffix2);
                }
                if (suffix1El) {
                    suffix1El.addEventListener('input', debouncedUpdateDdcSuffix2);
                    suffix1El.addEventListener('change', updateDdcSuffix2);
                }
            }

            // Client-side QR and Slip Printing functions
            function printSingleCopyQR(barcode, bookNo) {
                var title = document.getElementById('<%= txtTitle.ClientID %>').value.trim();
                var fn = document.getElementById('<%= txtAuthor1FN.ClientID %>').value.trim();
                var ln = document.getElementById('<%= txtAuthor1LN.ClientID %>').value.trim();
                var authors = fn || ln ? (fn + ' ' + ln).trim() : 'Unknown';

                var condition = '';
                var panel = document.getElementById('<%= pnlExistingCopies.ClientID %>');
                if (panel) {
                    var table = panel.querySelector('table');
                    if (table) {
                        var rows = table.querySelectorAll('tbody tr');
                        for (var i = 0; i < rows.length; i++) {
                            var barcodeTd = rows[i].cells[1];
                            if (barcodeTd && barcodeTd.textContent.trim() === barcode) {
                                var conditionTd = rows[i].cells[3];
                                if (conditionTd) {
                                    condition = conditionTd.textContent.trim();
                                }
                                break;
                            }
                        }
                    }
                }

                printCopyQrs(title, authors, [{ Barcode: barcode, Condition: condition, BookNo: bookNo }]);
            }

            function printAllCopyQRs() {
                var title = document.getElementById('<%= txtTitle.ClientID %>').value.trim();
                var fn = document.getElementById('<%= txtAuthor1FN.ClientID %>').value.trim();
                var ln = document.getElementById('<%= txtAuthor1LN.ClientID %>').value.trim();
                var authors = fn || ln ? (fn + ' ' + ln).trim() : 'Unknown';

                var copies = [];
                var panel = document.getElementById('<%= pnlExistingCopies.ClientID %>');
                if (panel) {
                    var table = panel.querySelector('table');
                    if (table) {
                        var rows = table.querySelectorAll('tbody tr');
                        rows.forEach(function (row) {
                            var bookNoTd = row.cells[0];
                            var barcodeTd = row.cells[1];
                            var conditionTd = row.cells[3];
                            if (barcodeTd) {
                                copies.push({
                                    Barcode: barcodeTd.textContent.trim(),
                                    Condition: conditionTd ? conditionTd.textContent.trim() : '',
                                    BookNo: bookNoTd ? bookNoTd.textContent.trim() : ''
                                });
                            }
                        });
                    }
                }

                if (copies.length === 0) {
                    alert("No copies registered to print.");
                    return;
                }

                printCopyQrs(title, authors, copies);
            }

            function printCopyQrs(bookTitle, bookAuthors, copies) {
                var printDetails = document.getElementById('<%= cbPrintDetails.ClientID %>').checked;
                var isAdults = document.getElementById('<%= cbAdults.ClientID %>').checked;
                var isChildren = document.getElementById('<%= cbChildren.ClientID %>').checked;

                var suitability = "Adults only / Children";
                if (isAdults && isChildren) suitability = "Adults only / Children";
                else if (isAdults) suitability = "Adults only";
                else if (isChildren) suitability = "Children";

                var bookNoVal = document.getElementById('<%= txtAcqNo.ClientID %>').value.trim() || document.getElementById('<%= txtBookNo.ClientID %>').value.trim();
                if (printDetails) {
                    var hfBookIdVal = document.getElementById('<%= hfBookID.ClientID %>').value.trim();
                    if (hfBookIdVal && hfBookIdVal !== '0') {
                        bookNoVal = hfBookIdVal;
                    }
                }

                var receiptDate = document.getElementById('<%= txtPurchaseDate.ClientID %>').value.trim();
                if (!receiptDate) {
                    var today = new Date();
                    var dd = String(today.getDate()).padStart(2, '0');
                    var mm = String(today.getMonth() + 1).padStart(2, '0');
                    var yyyy = today.getFullYear();
                    receiptDate = dd + '/' + mm + '/' + yyyy;
                }

                var conditionVal = document.getElementById('<%= txtCopyCondition.ClientID %>').value.trim() || "New";

                var w = window.open('', 'PrintBookQRs', 'width=850,height=900,scrollbars=yes');
                var html = '<html><head><title>Print Book Details / QR Codes</title>';
                html += '<style>';
                html += '@import url("https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&display=swap");';
                html += 'body { font-family: "Outfit", sans-serif; padding: 20px; background: #ffffff; margin: 0; color: #1e293b; }';

                if (printDetails) {
                    html += '.slip-container { display: flex; flex-direction: column; gap: 30px; }';
                    html += '.slip { border: 1.5px solid #0f1e36; padding: 24px; border-radius: 4px; width: 440px; margin: 0 auto; page-break-inside: avoid; background: #fff; }';
                    html += '.slip-header { text-align: center; font-weight: 700; font-size: 15px; text-transform: uppercase; letter-spacing: 0.5px; color: #0f1e36; margin-bottom: 16px; border-bottom: 2px solid #0f1e36; padding-bottom: 6px; }';
                    html += '.slip-grid { display: grid; grid-template-columns: 110px 1fr; row-gap: 8px; font-size: 12.5px; align-items: baseline; }';
                    html += '.slip-label { font-weight: 500; color: #64748b; }';
                    html += '.slip-value { font-weight: 600; color: #0f1e36; border-bottom: 1px solid #cbd5e1; padding-bottom: 1px; }';
                    html += '.slip-row-split { display: grid; grid-template-columns: 1fr 1fr; column-gap: 12px; grid-column: 2; width: 100%; }';
                    html += '.slip-sub-grid { display: grid; grid-template-columns: 85px 1fr; align-items: baseline; }';
                    html += '.slip-sub-label { font-weight: 500; color: #64748b; }';
                    html += '.regulations-title { font-weight: 700; font-size: 11.5px; text-transform: uppercase; color: #000000; margin-top: 16px; margin-bottom: 6px; text-decoration: underline; letter-spacing: 0.3px; }';
                    html += '.regulations-list { font-size: 10.2px; color: #000000; line-height: 1.45; text-align: justify; margin: 0; padding: 0; }';
                    html += '.regulations-list ol { margin: 0; padding-left: 18px; }';
                    html += '.regulations-list li { margin-bottom: 6px; padding-left: 2px; }';
                    html += '.qr-side-wrapper { display: flex; justify-content: space-between; align-items: center; border-top: 1px dashed #cbd5e1; margin-top: 12px; padding-top: 12px; }';
                    html += '.qr-side-text { font-family: monospace; font-size: 12px; font-weight: 700; color: #0f1e36; }';
                    html += '.qr-side-img { width: 80px; height: 80px; display: block; border: 1px solid #e2e8f0; padding: 2px; border-radius: 4px; }';
                } else {
                    html += '.qr-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 20px; }';
                    html += '.qr-card { border: 1px solid #cbd5e1; border-radius: 8px; padding: 16px; text-align: center; background: #ffffff; page-break-inside: avoid; }';
                    html += '.qr-title { font-size: 13px; font-weight: 700; color: #0f1e36; margin-bottom: 2px; height: 36px; overflow: hidden; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; }';
                    html += '.qr-authors { font-size: 11px; color: #64748b; margin-bottom: 8px; height: 16px; overflow: hidden; white-space: nowrap; text-overflow: ellipsis; }';
                    html += '.qr-img-wrapper { display: flex; justify-content: center; align-items: center; margin-bottom: 8px; }';
                    html += '.qr-img-wrapper img { width: 140px; height: 140px; display: block; }';
                    html += '.qr-code-text { font-family: monospace; font-size: 12px; font-weight: 700; color: #334155; }';
                }

                html += '@media print {';
                html += '  body { padding: 0; }';
                if (printDetails) {
                    html += '  .slip { border-color: #000; }';
                } else {
                    html += '  .qr-card { border-color: #1a1a1a; }';
                }
                html += '}';
                html += '</style></head><body>';

                if (printDetails) {
                    html += '<div class="slip-container">';
                    copies.forEach(function (copy) {
                        var copyCond = copy.Condition || conditionVal || 'New';
                        var condPrefix = copyCond.trim().charAt(0).toUpperCase();
                        var finalBookNo = copy.BookNo || bookNoVal;
                        var qrData = copy.Barcode + '/' + finalBookNo + '/' + condPrefix;
                        var qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&ecc=H&data=' + encodeURIComponent(qrData);
                        var ddcDisplay = copy.Barcode;
                        if (ddcDisplay) {
                            ddcDisplay = ddcDisplay + '-' + condPrefix;
                        }

                        html += '<div class="slip">';
                        html += '<div class="slip-header">Lahore Gymkhana Library</div>';
                        html += '<div class="slip-grid">';

                        html += '<div class="slip-label">Title</div><div class="slip-value">' + bookTitle + '</div>';
                        html += '<div class="slip-label">Author</div><div class="slip-value">' + bookAuthors + '</div>';

                        html += '<div class="slip-label">Book number</div>';
                        html += '<div class="slip-row-split">';
                        html += '<div class="slip-value">' + finalBookNo + '</div>';
                        html += '<div class="slip-sub-grid"><div class="slip-sub-label">DDC Number</div><div class="slip-value">' + ddcDisplay + '</div></div>';
                        html += '</div>';

                        html += '<div class="slip-label">Date of Receipt</div>';
                        html += '<div class="slip-row-split">';
                        html += '<div class="slip-value">' + receiptDate + '</div>';
                        html += '<div class="slip-sub-grid"><div class="slip-sub-label">Condition</div><div class="slip-value">' + copyCond + '</div></div>';
                        html += '</div>';

                        html += '<div class="slip-label">New Book Until</div><div class="slip-value">&nbsp;</div>';
                        html += '<div class="slip-label">Book suitable for</div><div class="slip-value">' + suitability + '</div>';

                        html += '</div>';

                        html += '<div class="regulations-title">LIBRARY REGULATION:</div>';
                        html += '<div class="regulations-list">';
                        html += '<ol>';
                        html += '<li>Library cards must be made out by all members withdrawing books separate cards can be made for children.</li>';
                        html += '<li>Single members will be allowed to take out 3 books at one time. of which one can be a new book.</li>';
                        html += '<li>Family members are allowed to take out 3 books at one time in addition they can take out 2 children\'s books. Not more then one book of each category can be a new book.</li>';
                        html += '<li>New books can be kept for a maximum of 14 days and this period can only be extended anew for 7 days. if there is no demand for the book from another member</li>';
                        html += '<li>other books can be kept for 30 days</li>';
                        html += '<li>all books taken out must be returned to the Librarian and under no circumstances should be placed on shelves</li>';
                        html += '<li>FINES. as approved by the Club will be <u>automatically</u> charged if books are not returned on the due date. A book can be brought in to the Library within the due date and taken out again if there is no demand for it from another member</li>';
                        html += '<li>A member who returns a book in a damaged condition will be liable for the cost of (a) rebinding the book or (b) replacing the book. The decision of the Convenor Library as to in which category the damage falls. shell be final.</li>';
                        html += '<li>All books lost will be charged their original cost price plus 200% extra to cover enchance in price and the cost of replacement.</li>';
                        html += '<li>Books kept in the Reference section may not be taken from the Library. but must be read on the premises.</li>';
                        html += '<li>Books contained in the Rare Book section can only be read on the premises. However copies of pages can be make for members or scholars approaching through members. at a standard rate per page approved by the Library Committee from time to time.</li>';
                        html += '</ol>';
                        html += '</div>';

                        html += '<div class="qr-side-wrapper">';
                        html += '<div class="qr-side-text">Barcode: ' + qrData + '</div>';
                        html += '<img class="qr-side-img" src="' + qrUrl + '" alt="QR Code" />';
                        html += '</div>';

                        html += '</div>';
                    });
                    html += '</div>';
                } else {
                    html += '<div class="qr-grid">';
                    copies.forEach(function (copy) {
                        var copyCond = copy.Condition || conditionVal || 'New';
                        var condPrefix = copyCond.trim().charAt(0).toUpperCase();
                        var finalBookNo = copy.BookNo || bookNoVal;
                        var qrData = copy.Barcode + '/' + finalBookNo + '/' + condPrefix;
                        var qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&ecc=H&data=' + encodeURIComponent(qrData);
                        html += '<div class="qr-card">';
                        html += '<div class="qr-title">' + bookTitle + '</div>';
                        html += '<div class="qr-authors">' + bookAuthors + '</div>';
                        html += '<div class="qr-img-wrapper"><img src="' + qrUrl + '" alt="QR Code" /></div>';
                        html += '<div class="qr-code-text">' + qrData + '</div>';
                        html += '</div>';
                    });
                    html += '</div>';
                }

                html += '<script>window.onload = function() { window.print(); window.close(); };</' + 'script>';
                html += '</body></html>';

                w.document.write(html);
                w.document.close();
            }

            // Print QR codes by BookID (used after save success alert)
            function printBookCopies(bookID) {
                callWebMethod('GetBookCopiesForPrinting', { bookID: bookID }, function (res) {
                    if (!res) {
                        alert('Error: Book details not found (Book ID: ' + bookID + ').');
                        return;
                    }
                    printCopyQrsEx(
                        res.Title,
                        res.Authors,
                        res.Copies,
                        res.PrintBookDetail,
                        res.IsAdults,
                        res.IsChildren,
                        res.BookNo || res.AcqNo,
                        res.PurchaseDate,
                        res.Copies && res.Copies.length > 0 ? res.Copies[0].Condition : 'New',
                        res.BookNo
                    );
                });
            }

            function printCopyQrsEx(bookTitle, bookAuthors, copies, printDetails, isAdults, isChildren, bookNoVal, receiptDate, conditionVal, bookID) {
                var suitability = 'Adults & Children';
                if (isAdults && isChildren) suitability = 'Adults & Children';
                else if (isAdults) suitability = 'Adults only';
                else if (isChildren) suitability = 'Children';

                bookNoVal = bookNoVal || bookID;

                if (!receiptDate) {
                    var today = new Date();
                    var dd = String(today.getDate()).padStart(2, '0');
                    var mm = String(today.getMonth() + 1).padStart(2, '0');
                    var yyyy = today.getFullYear();
                    receiptDate = dd + '/' + mm + '/' + yyyy;
                }

                if (!conditionVal) conditionVal = 'New';

                var w = window.open('', 'PrintBookQRs', 'width=850,height=900,scrollbars=yes');
                var html = '<html><head><title>Print Book Details / QR Codes</title>';
                html += '<style>';
                html += '@import url("https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&display=swap");';
                html += 'body { font-family: "Outfit", sans-serif; padding: 20px; background: #ffffff; margin: 0; color: #1e293b; }';
                html += '.qr-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 20px; }';
                html += '.qr-card { border: 1px solid #cbd5e1; border-radius: 8px; padding: 16px; text-align: center; background: #ffffff; page-break-inside: avoid; }';
                html += '.qr-title { font-size: 13px; font-weight: 700; color: #0f1e36; margin-bottom: 2px; }';
                html += '.qr-authors { font-size: 11px; color: #64748b; margin-bottom: 8px; }';
                html += '.qr-img-wrapper { display: flex; justify-content: center; align-items: center; margin-bottom: 8px; }';
                html += '.qr-img-wrapper img { width: 140px; height: 140px; display: block; }';
                html += '.qr-code-text { font-family: monospace; font-size: 12px; font-weight: 700; color: #334155; }';
                html += '@media print { body { padding: 0; } .qr-card { border-color: #1a1a1a; } }';
                html += '</style></head><body>';

                html += '<div class="qr-grid">';
                copies.forEach(function (copy) {
                    var copyCond = copy.Condition || conditionVal || 'New';
                    var condPrefix = copyCond.trim().charAt(0).toUpperCase();
                    var finalBookNo = copy.BookNo || bookNoVal;
                    var qrData = copy.Barcode + '/' + finalBookNo + '/' + condPrefix;
                    var qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&ecc=H&data=' + encodeURIComponent(qrData);
                    html += '<div class="qr-card">';
                    html += '<div class="qr-title">' + bookTitle + '</div>';
                    html += '<div class="qr-authors">' + bookAuthors + '</div>';
                    html += '<div class="qr-img-wrapper"><img src="' + qrUrl + '" alt="QR Code" /></div>';
                    html += '<div class="qr-code-text">' + qrData + '</div>';
                    html += '</div>';
                });
                html += '</div>';

                html += '<scr' + 'ipt>window.onload = function() { window.print(); window.close(); };</scr' + 'ipt>';
                html += '</body></html>';

                w.document.write(html);
                w.document.close();
            }

            // Edit Copy inline modal functions
            function editCopy(copyID, condition, location) {
                document.getElementById('editCopyId').value = copyID;
                var condSelect = document.getElementById('editCopyCondition');
                var rawCond = (condition || 'New').toString().trim().toLowerCase();

                var targetVal = 'New';
                if (rawCond === 'old' || rawCond === 'good' || rawCond === 'o') {
                    targetVal = 'Old';
                } else if (rawCond === 'secondhand' || rawCond === 'second hand' || rawCond === 'sh' || rawCond === 'fair' || rawCond === 'poor' || rawCond === 's') {
                    targetVal = 'SecondHand';
                }

                for (var i = 0; i < condSelect.options.length; i++) {
                    if (condSelect.options[i].value === targetVal) {
                        condSelect.selectedIndex = i;
                        break;
                    }
                }

                document.getElementById('editCopyLocation').value = location || '';
                document.getElementById('editCopyModal').style.display = 'flex';
            }

            function closeCopyEditModal() {
                document.getElementById('editCopyModal').style.display = 'none';
            }

            function saveCopyEdit() {
                var copyID = parseInt(document.getElementById('editCopyId').value);
                var condition = document.getElementById('editCopyCondition').value;
                var location = document.getElementById('editCopyLocation').value;

                callWebMethod('UpdateBookCopyDetails', {
                    copyID: copyID,
                    condition: condition,
                    location: location,
                    status: ''
                }, function (res) {
                    if (res === 'OK') {
                        closeCopyEditModal();
                        window.location.reload();
                    } else {
                        alert('Error updating copy: ' + res);
                    }
                });
            }

            // Initial binding and WebMethods population
            var cachedData = {
                languages: null,
                categories: null,
                formats: null,
                sources: null,
                editions: null
            };

            var activeFieldName = "";
            var activeSelectId = "";

            function openAddPopup(fieldName, selectId) {
                activeFieldName = fieldName;
                activeSelectId = selectId;

                document.getElementById('modalTitle').textContent = "Add New " + fieldName;
                document.getElementById('modalFieldLabel').textContent = fieldName + " Name";
                document.getElementById('txtModalNewValue').value = "";
                document.getElementById('modalErrorMsg').style.display = "none";

                var modal = document.getElementById('addOptionModal');
                modal.style.display = "flex";
                document.getElementById('txtModalNewValue').focus();
            }

            function closeAddPopup() {
                document.getElementById('addOptionModal').style.display = "none";
            }

            function syncToTextBox(selectId, textBoxId) {
                var select = document.getElementById(selectId);
                var textBox = document.getElementById(textBoxId);
                if (select && textBox) {
                    textBox.value = select.value;
                    // Trigger live generation for client updates
                    if (selectId === 'ddlCategory') {
                        triggerParallelGeneration();
                    }
                }
            }

            function saveNewOption() {
                var val = document.getElementById('txtModalNewValue').value.trim();
                if (!val) {
                    document.getElementById('modalErrorMsg').style.display = "block";
                    return;
                }

                var select = document.getElementById(activeSelectId);
                if (!select) return;

                // Check if the value already exists in the select options
                var exists = false;
                for (var i = 0; i < select.options.length; i++) {
                    if (select.options[i].value.toLowerCase() === val.toLowerCase()) {
                        exists = true;
                        select.selectedIndex = i;
                        break;
                    }
                }

                if (exists) {
                    var textBoxId = getCorrespondingTextBoxId(activeSelectId);
                    syncToTextBox(activeSelectId, textBoxId);
                    closeAddPopup();
                    return;
                }

                if (activeFieldName === "Language") {
                    callWebMethod('AddLanguageWeb', { name: val }, function (res) {
                        if (res.slice(0, 3) === "OK:" || res.slice(0, 7) === "EXISTS:") {
                            var actualName = res.split(':')[1];
                            appendAndSelectOption(select, actualName);
                            syncToTextBox(activeSelectId, '<%= txtLanguage.ClientID %>');
                            if (cachedData.languages && cachedData.languages.indexOf(actualName) === -1) {
                                cachedData.languages.push(actualName);
                                cachedData.languages.sort();
                            }
                            closeAddPopup();
                        } else {
                            alert("Error saving: " + res);
                        }
                    });
                } else if (activeFieldName === "Category") {
                    callWebMethod('AddCategoryWeb', { name: val }, function (res) {
                        if (res.slice(0, 3) === "OK:" || res.slice(0, 7) === "EXISTS:") {
                            var actualName = res.split(':')[1];
                            appendAndSelectOption(select, actualName);
                            syncToTextBox(activeSelectId, '<%= txtCategory.ClientID %>');
                            if (cachedData.categories && cachedData.categories.indexOf(actualName) === -1) {
                                cachedData.categories.push(actualName);
                                cachedData.categories.sort();
                            }
                            closeAddPopup();
                        } else {
                            alert("Error saving: " + res);
                        }
                    });
                } else {
                    appendAndSelectOption(select, val);
                    var textBoxId = getCorrespondingTextBoxId(activeSelectId);
                    syncToTextBox(activeSelectId, textBoxId);
                    var cacheKey = activeFieldName.toLowerCase() + "s";
                    if (cachedData[cacheKey] && cachedData[cacheKey].indexOf(val) === -1) {
                        cachedData[cacheKey].push(val);
                        cachedData[cacheKey].sort();
                    }
                    closeAddPopup();
                }
            }

            function getCorrespondingTextBoxId(selectId) {
                if (selectId === 'ddlLanguage') return '<%= txtLanguage.ClientID %>';
                if (selectId === 'ddlFormat') return '<%= txtFormat.ClientID %>';
                if (selectId === 'ddlSource') return '<%= txtSource.ClientID %>';
                if (selectId === 'ddlEdition') return '<%= txtEdition.ClientID %>';
                if (selectId === 'ddlCategory') return '<%= txtCategory.ClientID %>';
                return '';
            }

            function appendAndSelectOption(select, value) {
                var opt = document.createElement("option");
                opt.value = value;
                opt.textContent = value;
                select.appendChild(opt);
                select.value = value;
            }

            function populateDropdown(selectId, dataList, currentVal) {
                var select = document.getElementById(selectId);
                if (!select) return;

                var defText = "Select Option";
                if (selectId === 'ddlLanguage') defText = "-- Language --";
                if (selectId === 'ddlFormat') defText = "-- Format --";
                if (selectId === 'ddlSource') defText = "-- Source --";
                if (selectId === 'ddlEdition') defText = "-- Edition --";
                if (selectId === 'ddlCategory') defText = "-- Select Category --";

                select.innerHTML = '<option value="">' + defText + '</option>';

                dataList.forEach(function (item) {
                    var opt = document.createElement("option");
                    opt.value = item;
                    opt.textContent = item;
                    select.appendChild(opt);
                });

                if (currentVal) {
                    var exists = false;
                    for (var i = 0; i < select.options.length; i++) {
                        if (select.options[i].value.toLowerCase() === currentVal.toLowerCase()) {
                            select.selectedIndex = i;
                            exists = true;
                            break;
                        }
                    }
                    if (!exists && currentVal.trim() !== "") {
                        appendAndSelectOption(select, currentVal);
                    }
                }
            }

            function loadAndSetupAllDropdowns() {
                var currentLangEL = document.getElementById('<%= txtLanguage.ClientID %>');
                var currentFormatEL = document.getElementById('<%= txtFormat.ClientID %>');
                var currentSourceEL = document.getElementById('<%= txtSource.ClientID %>');
                var currentEditionEL = document.getElementById('<%= txtEdition.ClientID %>');
                var currentCategoryEL = document.getElementById('<%= txtCategory.ClientID %>');

                var currentLang = currentLangEL ? currentLangEL.value : '';
                var currentFormat = currentFormatEL ? currentFormatEL.value : '';
                var currentSource = currentSourceEL ? currentSourceEL.value : '';
                var currentEdition = currentEditionEL ? currentEditionEL.value : '';
                var currentCategory = currentCategoryEL ? currentCategoryEL.value : '';

                if (cachedData.languages) {
                    populateDropdown('ddlLanguage', cachedData.languages, currentLang);
                } else {
                    callWebMethod('GetLanguagesList', {}, function (list) {
                        cachedData.languages = list;
                        populateDropdown('ddlLanguage', list, currentLang);
                    });
                }

                if (cachedData.categories) {
                    populateDropdown('ddlCategory', cachedData.categories, currentCategory);
                } else {
                    callWebMethod('GetCategoriesList', {}, function (list) {
                        cachedData.categories = list;
                        populateDropdown('ddlCategory', list, currentCategory);
                    });
                }

                if (cachedData.formats) {
                    populateDropdown('ddlFormat', cachedData.formats, currentFormat);
                } else {
                    callWebMethod('GetDistinctFormats', {}, function (list) {
                        cachedData.formats = list;
                        populateDropdown('ddlFormat', list, currentFormat);
                    });
                }

                if (cachedData.sources) {
                    populateDropdown('ddlSource', cachedData.sources, currentSource);
                } else {
                    callWebMethod('GetDistinctSources', {}, function (list) {
                        cachedData.sources = list;
                        populateDropdown('ddlSource', list, currentSource);
                    });
                }

                if (cachedData.editions) {
                    populateDropdown('ddlEdition', cachedData.editions, currentEdition);
                } else {
                    callWebMethod('GetDistinctEditions', {}, function (list) {
                        cachedData.editions = list;
                        populateDropdown('ddlEdition', list, currentEdition);
                    });
                }
            }

            // WebMethod helper
            function callWebMethod(methodName, data, successCallback) {
                var url = window.location.pathname + '/' + methodName;
                fetch(url, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json; charset=utf-8'
                    },
                    body: JSON.stringify(data)
                })
                    .then(function (response) {
                        return response.json();
                    })
                    .then(function (json) {
                        if (successCallback) successCallback(json.d);
                    })
                    .catch(function (err) {
                        console.error('WebMethod error (' + methodName + '):', err);
                    });
            }

            function setupEventManagement() {
                initAutocomplete();
                registerLiveTriggers();
                loadAndSetupAllDropdowns();
                triggerParallelGeneration();
            }

            document.addEventListener('keydown', function (e) {
                if (e.key === 'Enter' || e.keyCode === 13) {
                    var target = e.target;
                    if (target && target.tagName !== 'TEXTAREA' && target.type !== 'submit' && target.tagName !== 'BUTTON' && (!target.className || target.className.indexOf('v-btn') === -1)) {
                        e.preventDefault();
                        var focusable = Array.from(document.querySelectorAll('input:not([type=hidden]):not([readonly]):not([disabled]), select:not([disabled]), textarea:not([disabled])'))
                            .filter(function(el) { return el.offsetWidth > 0 && el.offsetHeight > 0; });
                        var index = focusable.indexOf(target);
                        if (index > -1 && index + 1 < focusable.length) {
                            focusable[index + 1].focus();
                        }
                        return false;
                    }
                }
            });

            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', setupEventManagement);
            } else {
                setupEventManagement();
            }

            if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                    setupEventManagement();
                    triggerParallelGeneration();
                });
            }
        </script>
    </asp:Content>