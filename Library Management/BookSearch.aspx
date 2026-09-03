<%@ page language="C#" MasterPageFile="~/Library Management/Masters/Site.Master" autoeventwireup="true"
    CodeFile="BookSearch.aspx.cs" Inherits="Pages_Books_BookSearch" title="Book Search - Lahore Gymkhana Library" %>

    <asp:Content ID="cHead" ContentPlaceHolderID="cphHead" runat="server">
        <style>
            /* Smooth scale-up and glow transitions on card hover */
            .search-card {
                background-color: #ffffff;
                border: 1px solid #e2e8f0;
                border-radius: 12px;
                padding: 20px;
                display: flex;
                gap: 24px;
                box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
                position: relative;
                overflow: hidden;
                width: 100%;
                box-sizing: border-box;
                flex-wrap: wrap;
                transition: transform 0.2s cubic-bezier(0.4, 0, 0.2, 1), box-shadow 0.2s cubic-bezier(0.4, 0, 0.2, 1), border-color 0.2s ease;
            }

            .search-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 12px 20px -8px rgba(15, 30, 54, 0.08);
                border-color: #c5a059;
            }

            /* Beautiful search input box shadow on focus */
            .google-search-input {
                width: 100%;
                max-width: 680px;
                padding: 14px 24px;
                border: 1px solid #cbd5e1;
                border-radius: 30px;
                font-size: 16px;
                outline: none;
                background-color: #ffffff;
                box-sizing: border-box;
                transition: all 0.25s ease;
                box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
            }

            .google-search-input:focus {
                border-color: #c5a059;
                box-shadow: 0 4px 12px rgba(197, 160, 89, 0.15), 0 2px 4px rgba(0, 0, 0, 0.05);
                background-color: #ffffff;
            }

            /* Clean transition for collapsible filter panel */
            .filter-panel {
                max-height: 0;
                overflow: hidden;
                transition: max-height 0.35s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.3s ease, margin-top 0.3s ease;
                opacity: 0;
                width: 100%;
                box-sizing: border-box;
            }

            .filter-panel.open {
                max-height: 1000px;
                opacity: 1;
                margin-top: 20px;
            }

            /* Dynamic buttons styling */
            .btn-gold-grad {
                padding: 10px 24px;
                border-radius: 8px;
                border: none;
                cursor: pointer;
                font-size: 13.5px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%);
                color: #0f1e36;
                transition: all 0.25s ease;
                box-shadow: 0 4px 12px rgba(197, 160, 89, 0.2);
                outline: none;
            }

            .btn-gold-grad:hover {
                transform: translateY(-1px);
                box-shadow: 0 6px 15px rgba(197, 160, 89, 0.3);
            }

            .btn-dark {
                padding: 10px 24px;
                border-radius: 8px;
                border: 1px solid #cbd5e1;
                cursor: pointer;
                font-size: 13.5px;
                font-weight: 600;
                background: #ffffff;
                color: #1e293b;
                transition: all 0.25s ease;
                outline: none;
            }

            .btn-dark:hover {
                background-color: #f8fafc;
                border-color: #94a3b8;
            }

            /* Autocomplete extender dropdown suggestions styling */
            .autocomplete-suggestions {
                position: absolute;
                top: 100%;
                left: 0;
                right: 0;
                z-index: 9999;
                background: #ffffff;
                border: 1px solid #c5a059;
                border-radius: 8px;
                margin-top: 4px;
                max-height: 220px;
                overflow-y: auto;
                box-shadow: 0 10px 25px -5px rgba(15, 30, 54, 0.2), 0 8px 10px -6px rgba(0, 0, 0, 0.08);
                box-sizing: border-box;
            }

            .autocomplete-suggestions div {
                padding: 10px 14px;
                font-size: 13.5px;
                color: #1e293b;
                cursor: pointer;
                transition: background-color 0.15s ease, color 0.15s ease;
                text-align: left;
                border-bottom: 1px solid #f1f5f9;
            }

            .autocomplete-suggestions div:last-child {
                border-bottom: none;
            }

            .autocomplete-suggestions div:hover,
            .autocomplete-suggestions div.selected {
                background-color: #f8fafc;
                color: #c5a059;
                font-weight: 600;
            }
        </style>
    </asp:Content>

    <asp:Content ID="cBody" ContentPlaceHolderID="cphBody" runat="server">

        <asp:UpdatePanel ID="upBookSearch" runat="server" UpdateMode="Conditional">
            <ContentTemplate>

                <!-- Header -->
                <div
                    style="background: linear-gradient(135deg, #0f1e36, #1c3254); color: #ffffff; padding: 20px 28px; border-radius: 8px; margin-bottom: 24px; border-bottom: 3px solid #c5a059; display: flex; justify-content: space-between; align-items: center; width: 100%; box-sizing: border-box;">
                    <div style="display: block;">
                        <h2 style="margin: 0; font-size: 22px; font-weight: 600;">BOOK Search Engine</h2>
                        <p style="margin: 4px 0 0; opacity: .8; font-size: 13px;">Lahore Gymkhana Club - Advanced
                            dynamic catalogue search portal</p>
                    </div>
                </div>

                <!-- Center-Aligned Google-Like Search Area (Placed at Top) -->
                <div
                    style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 36px 24px; margin-bottom: 30px; box-shadow: 0 1px 3px 0 rgba(0,0,0,0.05); width: 100%; box-sizing: border-box; display: flex; flex-direction: column; align-items: center;">

                    <!-- Logo Style header -->
                    <div
                        style="font-family: 'Playfair Display', serif; font-size: 32px; font-weight: 700; color: #0f1e36; margin-bottom: 24px; text-align: center; display: flex; align-items: center; gap: 8px;">
                        <span style="color: #0f1e36;">BOOK</span>
                        <span
                            style="color: #c5a059; font-style: italic; font-weight: 500; font-family: 'Playfair Display', serif;">Search</span>
                    </div>

                    <!-- Search box -->
                    <div
                        style="position: relative; width: 100%; max-width: 680px; display: flex; justify-content: center; margin-bottom: 16px;">
                        <asp:TextBox ID="txtGlobalSearch" runat="server" CssClass="google-search-input"
                            placeholder="Search book titles, authors, keywords or ISBN..."
                            autocomplete="off"
                            style="width: 100%; max-width: 680px; padding: 14px 24px; border: 1px solid #cbd5e1; border-radius: 30px; font-size: 16px; outline: none; background-color: #ffffff; box-sizing: border-box; transition: all 0.25s ease; box-shadow: 0 2px 5px rgba(0,0,0,0.05);"
                            onfocus="this.style.borderColor='#c5a059'; this.style.boxShadow='0 4px 12px rgba(197, 160, 89, 0.15), 0 2px 4px rgba(0, 0, 0, 0.05)';"
                            onblur="this.style.borderColor='#cbd5e1'; this.style.boxShadow='0 2px 5px rgba(0,0,0,0.05)';" />
                        <div id="globalSearchSuggestions" class="autocomplete-suggestions" style="display:none; border-radius: 12px;"></div>
                    </div>

                    <!-- Filter Toggle link -->
                    <div style="display: flex; gap: 20px; align-items: center;">
                        <button type="button" id="btnToggleFilters" onclick="toggleAdvancedFilters()"
                            style="background: none; border: none; font-size: 13px; font-weight: 700; text-transform: uppercase; color: #c5a059; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; letter-spacing: 0.5px; outline: none; transition: color 0.2s;">
                            Advanced Fields Search
                        </button>
                        <span style="color: #cbd5e1;">|</span>
                        <asp:LinkButton ID="lnkClearAll" runat="server" OnClick="lnkClearAll_Click"
                            style="font-size: 13px; font-weight: 700; text-transform: uppercase; color: #64748b; text-decoration: none; letter-spacing: 0.5px;">
                            Clear Filters</asp:LinkButton>
                    </div>

                    <!-- Collapsible Advanced Filters Panel -->
                    <div id="divFilters" class="filter-panel"
                        style="max-height: 0px; overflow: hidden; transition: max-height 0.35s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.3s ease, margin-top 0.3s ease; opacity: 0; width: 100%; box-sizing: border-box;">
                        <div
                            style="border-top: 1px solid #f1f5f9; padding-top: 24px; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; width: 100%; text-align: left;">

                            <div
                                style="position: relative; display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                                <label
                                    style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Author</label>
                                <asp:TextBox ID="txtAuthor" runat="server" autocomplete="off"
                                    style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box;"
                                    placeholder="e.g. Orwell" />
                                <div id="authorSuggestions" class="autocomplete-suggestions" style="display:none;"></div>
                            </div>

                            <div
                                style="position: relative; display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                                <label
                                    style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Book Title</label>
                                <asp:TextBox ID="txtBookName" runat="server" autocomplete="off"
                                    style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box;"
                                    placeholder="e.g. Animal Farm" />
                                <div id="bookTitleSuggestions" class="autocomplete-suggestions" style="display:none;"></div>
                            </div>

                            <div
                                style="position: relative; display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                                <label
                                    style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Edition</label>
                                <asp:TextBox ID="txtEdition" runat="server" autocomplete="off"
                                    style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box;"
                                    placeholder="e.g. Deluxe Edition" />
                                <div id="editionSuggestions" class="autocomplete-suggestions" style="display:none;"></div>
                            </div>

                            <div
                                style="position: relative; display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                                <label
                                    style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Publisher</label>
                                <asp:TextBox ID="txtPublisher" runat="server" autocomplete="off"
                                    style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box;"
                                    placeholder="e.g. Penguin" />
                                <div id="publisherSuggestions" class="autocomplete-suggestions" style="display:none;"></div>
                            </div>

                            <div
                                style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                                <label
                                    style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Subject Category</label>
                                <asp:DropDownList ID="ddlCategory" runat="server"
                                    style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px;" />
                            </div>

                            <div
                                style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                                <label
                                    style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Language</label>
                                <asp:DropDownList ID="ddlLanguage" runat="server"
                                    style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box; height: 42px;" />
                            </div>

                            <div
                                style="display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                                <label
                                    style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">Publish Year</label>
                                <asp:TextBox ID="txtYear" runat="server" autocomplete="off"
                                    style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box;"
                                    placeholder="e.g. 1984" TextMode="Number" />
                            </div>

                            <div
                                style="position: relative; display: flex; flex-direction: column; gap: 6px; width: 100%; box-sizing: border-box;">
                                <label
                                    style="font-size: 11px; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.6px; margin: 0;">DDC Call Number</label>
                                <asp:TextBox ID="txtDDC" runat="server" autocomplete="off"
                                    style="width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13.5px; outline: none; background-color: #ffffff; box-sizing: border-box;"
                                    placeholder="e.g. 823.912" />
                                <div id="ddcSuggestions" class="autocomplete-suggestions" style="display:none;"></div>
                            </div>

                        </div>
                    </div>

                    <!-- Submit Search Button -->
                    <div style="margin-top: 24px; display: flex; gap: 12px; justify-content: center; width: 100%;">
                        <asp:Button ID="btnSearch" runat="server" Text="Search Catalogue" CssClass="btn-gold-grad"
                            OnClick="btnSearch_Click"
                            style="padding: 10px 24px; border-radius: 8px; border: none; cursor: pointer; font-size: 13.5px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: linear-gradient(135deg, #c5a059 0%, #aa8441 100%); color: #0f1e36; transition: all 0.25s ease; box-shadow: 0 4px 12px rgba(197, 160, 89, 0.2); outline: none;"
                            onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 6px 15px rgba(197, 160, 89, 0.3)';"
                            onmouseout="this.style.transform='none'; this.style.boxShadow='0 4px 12px rgba(197, 160, 89, 0.2)';" />
                    </div>

                    <!-- State tracker for collapsible panel -->
                    <asp:HiddenField ID="hfFiltersState" runat="server" Value="closed" />
                </div>

                <!-- Search Results Header -->
                <div
                    style="margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; width: 100%;">
                    <h3
                        style="font-size: 16px; font-weight: 700; color: #0f1e36; margin: 0; text-transform: uppercase; letter-spacing: 0.5px;">
                        <asp:Literal ID="litResultsHeader" runat="server" Text="Catalogue Collection" />
                    </h3>
                </div>

                <!-- Single-Line Results Table -->
                <div style="width: 100%; overflow-x: auto; background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; margin-bottom: 40px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); text-transform: uppercase;">
                    <table style="width: 100%; border-collapse: collapse; font-size: 13.5px; text-transform: uppercase;">
                        <thead>
                            <tr style="background-color: #0f1e36; color: #ffffff; text-align: left; height: 44px; text-transform: uppercase;">
                                <th style="padding: 12px 16px; font-weight: 700; width: 30%;">Title</th>
                                <th style="padding: 12px 16px; font-weight: 700; width: 25%;">Author</th>
                                <th style="padding: 12px 16px; font-weight: 700; width: 15%;">DDC Number</th>
                                <th style="padding: 12px 16px; font-weight: 700; width: 15%;">Status</th>
                                <th style="padding: 12px 16px; font-weight: 700; width: 15%;">Category</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptBooks" runat="server" OnItemCommand="rptBooks_ItemCommand">
                                <ItemTemplate>
                                    <tr style="border-bottom: 1px solid #e2e8f0; text-transform: uppercase; transition: background-color 0.15s ease;" onmouseover="this.style.backgroundColor='#f8fafc';" onmouseout="this.style.backgroundColor='transparent';">
                                        <td style="padding: 12px 16px;">
                                            <asp:LinkButton ID="btnViewDetail" runat="server" CommandName="ViewDetail" CommandArgument='<%# Eval("BookID") %>'
                                                style="color: #0f1e36; font-weight: 700; text-decoration: underline; cursor: pointer; text-transform: uppercase;">
                                                <%# (Eval("Title") != null ? Eval("Title").ToString().ToUpper() : "") %>
                                            </asp:LinkButton>
                                        </td>
                                        <td style="padding: 12px 16px; color: #334155; text-transform: uppercase;"><%# (Eval("Authors") != null ? Eval("Authors").ToString().ToUpper() : "-") %></td>
                                        <td style="padding: 12px 16px; color: #334155; text-transform: uppercase;"><%# (Eval("DDC") == DBNull.Value || string.IsNullOrEmpty(Eval("DDC").ToString())) ? "-" : Eval("DDC").ToString().Replace("\r","").Replace("\n"," / ").ToUpper() %></td>
                                        <td style="padding: 12px 16px; text-transform: uppercase;">
                                            <%# Convert.ToInt32(Eval("AvailableCopies")) > 0 
                                                ? "<span style='color: #16a34a; font-weight: 700;'>AVAILABLE (" + Eval("AvailableCopies") + ")</span>" 
                                                : "<span style='color: #ef4444; font-weight: 700;'>CHECKED OUT</span>" %>
                                        </td>
                                        <td style="padding: 12px 16px; color: #334155; text-transform: uppercase;"><%# GetCategoryDisplay(Eval("IsReference"), Eval("IsAdults"), Eval("IsChildren")) %></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>

                <!-- Bibliographic Record & Cover Image Modal -->
                <asp:Panel ID="pnlBookDetailModal" runat="server" Visible="false" style="position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(15, 30, 54, 0.75); display: flex; align-items: center; justify-content: center; z-index: 99999; padding: 20px; box-sizing: border-box;">
                    <div style="background: #ffffff; border-radius: 12px; max-width: 820px; width: 100%; max-height: 90vh; overflow-y: auto; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.3); position: relative; padding: 28px; box-sizing: border-box;">
                        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #c5a059; padding-bottom: 12px; margin-bottom: 20px;">
                            <h3 style="margin: 0; font-size: 20px; font-weight: 700; color: #0f1e36; text-transform: uppercase;">
                                <asp:Literal ID="litModalTitle" runat="server" />
                            </h3>
                            <asp:Button ID="btnCloseModal" runat="server" Text="✕ CLOSE" OnClick="btnCloseModal_Click" style="background: #0f1e36; color: #ffffff; border: none; border-radius: 6px; padding: 8px 16px; cursor: pointer; font-weight: 700; font-size: 12px; text-transform: uppercase;" />
                        </div>
                        <div style="display: flex; gap: 24px; flex-wrap: wrap;">
                            <div style="width: 170px; height: 230px; border-radius: 8px; overflow: hidden; border: 1px solid #e2e8f0; background: #f8fafc; display: flex; align-items: center; justify-content: center; flex-shrink: 0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);">
                                <asp:Image ID="imgModalCover" runat="server" style="max-width: 100%; max-height: 100%; object-fit: contain;" />
                            </div>
                            <div style="flex: 1; min-width: 280px; font-size: 13.5px; line-height: 1.7; text-transform: uppercase;">
                                <asp:Literal ID="litModalContent" runat="server" />
                        </div>
                    </div>
                </asp:Panel>

                <!-- Empty State when no records are returned -->
                    <asp:Panel ID="pnlEmptyState" runat="server" Visible="false" style="width: 100%;">
                        <div
                            style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 48px; text-align: center; max-width: 600px; margin: 40px auto; box-shadow: 0 1px 2px 0 rgba(0,0,0,0.05); display: flex; flex-direction: column; align-items: center; justify-content: center; box-sizing: border-box;">
                            <h3
                                style="font-size: 18px; font-weight: 700; color: #0f1e36; margin-bottom: 6px; margin-top: 0;">
                                No books matched your criteria</h3>
                            <p style="font-size: 13.5px; color: #64748b; margin-bottom: 20px;">Try typing a different
                                keyword or relaxing your advanced search filters.</p>
                            <asp:LinkButton ID="btnClearAllFilters" runat="server"
                                style="display: inline-flex; align-items: center; padding: 9px 18px; border-radius: 8px; border: 1px solid #cbd5e1; color: #1e293b; text-decoration: none; background: #ffffff;"
                                OnClick="lnkClearAll_Click">Clear All Filters</asp:LinkButton>
                        </div>
                    </asp:Panel>
            </ContentTemplate>
        </asp:UpdatePanel>

        <script>
            // Helper to invoke page WebMethods
            function callWebMethod(method, data, onSuccess) {
                fetch('BookSearch.aspx/' + method, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json; charset=utf-8' },
                    body: JSON.stringify(data)
                })
                    .then(r => r.json())
                    .then(data => { if (onSuccess && data) onSuccess(data.d); })
                    .catch(err => console.error(err));
            }

            // Generic, high-performance AutoComplete extender implementation
            function setupAutoComplete(inputId, suggestionsId, webMethodName) {
                var input = document.getElementById(inputId);
                var suggestions = document.getElementById(suggestionsId);
                if (!input || !suggestions) return;

                var debounceTimer = null;
                var selectedIndex = -1;

                function closeSuggestions() {
                    suggestions.innerHTML = '';
                    suggestions.style.display = 'none';
                    selectedIndex = -1;
                }

                input.addEventListener('input', function () {
                    clearTimeout(debounceTimer);
                    var val = input.value;
                    if (!val || val.trim().length < 1) {
                        closeSuggestions();
                        return;
                    }

                    debounceTimer = setTimeout(function () {
                        callWebMethod(webMethodName, { query: val }, function (res) {
                            suggestions.innerHTML = '';
                            selectedIndex = -1;
                            if (res && res.length > 0) {
                                res.forEach(function (item, idx) {
                                    var div = document.createElement('div');
                                    div.textContent = item;
                                    div.setAttribute('data-index', idx);
                                    div.addEventListener('click', function () {
                                        input.value = item;
                                        closeSuggestions();
                                    });
                                    suggestions.appendChild(div);
                                });
                                suggestions.style.display = 'block';
                            } else {
                                closeSuggestions();
                            }
                        });
                    }, 200);
                });

                input.addEventListener('keydown', function (e) {
                    var items = suggestions.querySelectorAll('div');
                    if (suggestions.style.display === 'block' && items.length > 0) {
                        if (e.key === 'ArrowDown') {
                            e.preventDefault();
                            selectedIndex = (selectedIndex + 1) % items.length;
                            updateSelection(items);
                        } else if (e.key === 'ArrowUp') {
                            e.preventDefault();
                            selectedIndex = (selectedIndex - 1 + items.length) % items.length;
                            updateSelection(items);
                        } else if (e.key === 'Enter') {
                            if (selectedIndex >= 0 && selectedIndex < items.length) {
                                e.preventDefault();
                                input.value = items[selectedIndex].textContent;
                                closeSuggestions();
                            }
                        } else if (e.key === 'Escape') {
                            closeSuggestions();
                        }
                    }
                });

                function updateSelection(items) {
                    items.forEach(function (item, index) {
                        if (index === selectedIndex) {
                            item.classList.add('selected');
                            item.scrollIntoView({ block: 'nearest' });
                        } else {
                            item.classList.remove('selected');
                        }
                    });
                }

                document.addEventListener('click', function (e) {
                    if (e.target !== input && e.target !== suggestions && !suggestions.contains(e.target)) {
                        closeSuggestions();
                    }
                });
            }

            function initSearchAutocompletes() {
                setupAutoComplete('<%= txtGlobalSearch.ClientID %>', 'globalSearchSuggestions', 'GetGlobalSearchSuggestions');
                setupAutoComplete('<%= txtAuthor.ClientID %>', 'authorSuggestions', 'GetAuthorSuggestions');
                setupAutoComplete('<%= txtBookName.ClientID %>', 'bookTitleSuggestions', 'GetBookTitleSuggestions');
                setupAutoComplete('<%= txtEdition.ClientID %>', 'editionSuggestions', 'GetEditionSuggestions');
                setupAutoComplete('<%= txtPublisher.ClientID %>', 'publisherSuggestions', 'GetPublisherSuggestions');
                setupAutoComplete('<%= txtDDC.ClientID %>', 'ddcSuggestions', 'GetDdcSuggestions');
            }

            // Collapsible filters accordion toggle logic using inline styles to guarantee it works on live site
            function toggleAdvancedFilters() {
                var panel = document.getElementById("divFilters");
                var btn = document.getElementById("btnToggleFilters");
                var stateField = document.getElementById("<%= hfFiltersState.ClientID %>");

                if (stateField.value === "open") {
                    panel.style.maxHeight = "0px";
                    panel.style.opacity = "0";
                    panel.style.marginTop = "0px";
                    panel.style.overflow = "hidden";
                    if (btn) btn.style.color = "#c5a059";
                    stateField.value = "closed";
                    panel.classList.remove("open");
                } else {
                    panel.style.maxHeight = "1000px";
                    panel.style.opacity = "1";
                    panel.style.marginTop = "20px";
                    setTimeout(function() { panel.style.overflow = "visible"; }, 350);
                    if (btn) btn.style.color = "#aa8441";
                    stateField.value = "open";
                    panel.classList.add("open");
                }
            }

            // Restore state of filter panel using inline styles to guarantee it works on live site
            function restoreFiltersState() {
                var stateField = document.getElementById("<%= hfFiltersState.ClientID %>");
                var panel = document.getElementById("divFilters");
                var btn = document.getElementById("btnToggleFilters");

                if (stateField && panel) {
                    if (stateField.value === "open") {
                        panel.style.maxHeight = "1000px";
                        panel.style.opacity = "1";
                        panel.style.marginTop = "20px";
                        panel.style.overflow = "visible";
                        if (btn) btn.style.color = "#aa8441";
                        panel.classList.add("open");
                    } else {
                        panel.style.maxHeight = "0px";
                        panel.style.opacity = "0";
                        panel.style.marginTop = "0px";
                        panel.style.overflow = "hidden";
                        if (btn) btn.style.color = "#c5a059";
                        panel.classList.remove("open");
                    }
                }
            }

            // Run on initial load
            window.onload = function () {
                restoreFiltersState();
                initSearchAutocompletes();
            };

            // Run after ASP.NET AJAX partial postbacks
            if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                    restoreFiltersState();
                    initSearchAutocompletes();
                });
            }
        </script>

    </asp:Content>